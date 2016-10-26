test_indeps <- function(D, testConfig, verbose=0) {
  # Function to compute all the independence tests from the different datasets in D.
  # - D : list of data matrices, one for each experimental setting. Columns are variables and each row is a sample.
  # - testConfig$test: type of test used to generate data, outputs a value between 0 and 1?
  #          -"classic" classic correlation test (p-value = 0.05)
  #          -"oracle" independence facts determined by Patrik's oracle
  #          -"oracle+" independence facts determined by Patrik's oracle, plus ancestral relations from perfect interventions from oracle
  #          -"BIC" BIC-based calculation
  #          -"bayes" integrating over the parameters introduced in the paper
  #          -"bayes+" integrating over the parameters introduced in the paper, plus ancestral relations from perfect interventions from oracle
  # - testConfig$schedule: maximum conditioning set. 
  #          -if a number T it means all tests up to intervention tests size T
  #           (can be Inf, default = 3)
  # - testConfig$weight: how to determine the weights from the dependencies:
  #          -"log" take log of the probability
  #          -"constant" the most likely option gets weight 1
  #          -"simulate_greedy" changes the weights to 2**rank of the (in)dependence to simulate the greedy algorithm.
  # - testConfig$p: for bayes and BIC tests the apriori probability of 
  #          -for classic test using algorithms the p-value threshold
  #          -for BIC-based score based learning the prior parameter
  # - testConfig$alpha: for bayes test the eq. sample size
  # - testConfig$conditioning_vars: NULL by default, otherwise it means that instead of conditioning on all vars, we use only some.
  #          The second option shouldn't be used yet, because it requires a bit more work for making sure we encode the sets correctly in ASP.
  
  schedule <- testConfig$schedule
  test <- testConfig$test
  
  if (verbose) {
    cat(" - Conducting independence tests: schedule/cmax=", schedule,", test=", test,".\n",sep='')
  }
  
  tested_independences <- list()
  test_data<-list()
  
  skel <- NULL
  
  jindex <- 0
  for (data in D) {
    n <- ncol(data$data)
    if (is.null(n)) {
      n <- ncol(data$M$G)
    }
    
    # Preparing for writing indep constraints.
    jindex<-jindex+1
    
    test_data$jset <- bin.to.dec(rev(1*(data$e==1)))
    test_data$J <- which(data$e==1)
    test_data$names <- colnames(data$data)
    test_data$indPath <- NULL

    # Putting in the test data as it should be.
    if (test == "classic") {
      test_data$Cx<-cov(data$data)
      test_data$N<-data$N
      test_data$p_threshold<-testConfig$p
      test_function<-test.classic 
    } else if (test == "oracle") {
      test_data$M<-data$M #should take out the Js here  
      test_data$N<-Inf
      # Dummy threshold, mostly used for FCI schedule.
      test_data$p_threshold<-0.5 # independent vars have p-value 1, dependent 0.
      test_function<-test.oracle
      # Delete all the edges with intervened vars.
      test_data$M$G[test_data$J,]<-0 
      test_data$M$Ge[test_data$J,]<-0
      test_data$M$Ge[,test_data$J]<-0        
    } else if (test == "BIC") {
      test_data$X<-data$data
      test_data$p_threshold<-testConfig$p
      test_function<-test.BIC      
    } else if (test == "bayes") {
      test_data$X<-data$data
      test_data$p_threshold<-testConfig$p # prior probability of ind.
      test_function<-test.bayes
      test_data$alpha<-testConfig$alpha # eq. sample size for the prior
      test_data$discrete<-testConfig$discrete
    } else if (test == "logp") {
      test_data$Cx<-cov(data$data)
      test_data$N<-data$N
      test_data$p_threshold<-testConfig$p # significance level.
      test_function<-test.logp
    }
    
    if (any(grepl("fci", schedule)> 0) ) {
      test_data$test_function <- test_function
      test_data$tested_independences <- list()
      test_data$indPath <- file.path(testConfig$currentDir, paste("fci_indeps.ind", sep=""))
      test_data$n <- n
      
      if (length(schedule) > 1){
        m.max = as.numeric(schedule[2])
      } else {
        m.max = Inf
      }
      
      skel <- pcalg::skeleton(suffStat=test_data,  indepTest=test.wrapper, alpha=testConfig$alpha, labels = as.character(seq_len(n)), 
                              fixedGaps = NULL, fixedEdges = NULL, 
                              NAdelete = TRUE, m.max = m.max, verbose = FALSE,  method = "stable")
      system(paste("cat ", test_data$indPath, " | sort -u > ", test_data$indPath, ".sorted.txt", sep=""))
      
      indFile <- file(test_data$indPath, "w")
      cat('node(1..', n, ').\n', sep='', file = indFile)
      cat('%independences and dependences\n', file = indFile)
      close(indFile)
      system(paste("cat ", test_data$indPath, ".sorted.txt >> ", test_data$indPath, sep=""))
      parsed_indeps <- parse_asp_indeps(test_data$indPath)
      tested_independences <- parsed_indeps$tested_independences
    } else {
      tested_independences <- test_indeps.loop(test_function, test_data,  maxcset=schedule, n=n, 
                                                   tested_independences=tested_independences, conditioning_vars=testConfig$conditioning_vars)
    }
  }
  list(tested_independences=tested_independences, indPath=test_data$indPath, skel=skel)
}


# If there is another strategy for getting conditional independences instead of all possible subsets of a given size, 
# it is just necessary to write a similar function to the one underneath.

test_indeps.loop <- function(test_function, test_data, maxcset=Inf, n, tested_independences, conditioning_vars=NULL) {
  # Function for conducting all independence tests for one data set.
  for (csetsize in index(0,maxcset) ) { #go from simpler to more complicated tests       
    for ( i in 1:(n-1)) {
      tested_independences_j <- foreach (j = (i+1):n) %do% {
        test_indeps.parallel.loop(test_function, test_data, n, i, j, csetsize, conditioning_vars)
      } #for j
      for (test_result_list in tested_independences_j) {
        for (test_result in test_result_list) {
          tested_independences[[length(tested_independences) + 1]] <- test_result
        }        
      }
    } # for i
  } # for csetsize
  tested_independences
}  

test_indeps.parallel.loop <- function(test_function, test_data, n, i, j, csetsize, conditioning_vars=NULL) {
  #start with empty set
  if (is.null(conditioning_vars)) {
    csetvec <- rep(0, n)
  } else {
    csetvec <- rep(0, length(conditioning_vars))
  }
  csetvec[index(1,csetsize)]<-1
  tested_independences <- list() 
  
  while ( !any(is.na(csetvec) ) ) {
    if (is.null(conditioning_vars)) {
      runTest <- csetvec[i]==0 && csetvec[j] == 0 
      cond_vars <- which(csetvec==1)
      cset<-bin.to.dec(rev(csetvec))
    } else {
      cond_vars <- conditioning_vars[which(csetvec==1)]
      runTest <- !(i %in% cond_vars || j %in% cond_vars)
      cset <- rep(0, n)
      cset[cond_vars] <- 1
      cset<-bin.to.dec(rev(cset))
    }
    
    if (runTest) { #only if neither x and y are cond.
      cat(i, " ", j , "|", cond_vars, "\n")
      
      #calling the test function
      test_result<-test_function(c(i,j), cond_vars, test_data)

      #put some parameters right
      test_result$J<-test_data$J
      test_result$jset<-test_data$jset
      test_result$cset<-cset
      test_result$M<-setdiff((1:n),c(test_result$vars,test_result$C))
      test_result$mset <- getm( test_result$vars, test_result$C, n=n)
      #cat(paste(test_result$M,collapse=','),'=',test_result$mset,'\n')
      
      #adding the test result also to tested_independences vector
      tested_independences[[length(tested_independences) + 1]] <- test_result
    } #if x and y are not in the conditioning set
    
    #consider next csetvec given by the following function
    csetvec<-next_colex_comb(csetvec)
  } #while csetvec != NA
  tested_independences
}

test_indeps._test1 <- function() {
  MD <- pipeline.simulate_data._test1()
  testConfig <- list(test="bayes", schedule=2, p=0.5, alpha=1.15, weight="log", conditioning_vars=NULL)
  test_indeps(D=MD$D, testConfig=testConfig, verbose=0)
}

test_indeps._test2 <- function() {
  MD <- pipeline.simulate_data._test2()
  testConfig <- list(test="bayes", schedule=2, p=0.5, alpha=1.15, weight="log", conditioning_vars=NULL)
  test_indeps(D=MD$D, testConfig=testConfig, verbose=0)
}

test_indeps._test3 <- function() {
  MD <- pipeline.simulate_data._test3()
  testConfig <- list(test="oracle", schedule=2, p=0.5, alpha=1.15, weight="log", conditioning_vars=NULL)
  test_indeps(D=MD$D, testConfig=testConfig, verbose=0)
}