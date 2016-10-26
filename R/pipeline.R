pipeline<-function(n=4, topology="random", # model properties
                   exconf="passive", N=500, # sampling properties
                   pedge = 1/((n-1)*2), # probablity of edge in the generated model.
                   restrict = c('acyclic'), # type of generated model.
                   confounder_proportion=0.5,
                   test="bayes", schedule=1, # testing properties
                   p=0.5, alpha=1.5, # eq. sample size for the bayes test
                   weight="log", # how to compute the weights of the inputs.
                   encode="aci_complete.pl", # how to encode them, encode=NULL for only tests.
                   solver="clingo", # which solver to use
                   solver_conf="--time-limit=2000 --quiet=1",
                   #solver_conf="--configuration=crafty --time-limit=25000 --quiet=1,0",
                   multipleMinima = "iterative",
                   repeat_bootstrap=0, # run bootstrap and if so how many iterations
                   model=NULL, # input model if given
                   samples=NULL, # input sample data if given
                   indPath = NULL, # input .ind file if given
                   bckg_file=NULL, # background knowledge file if available.
                   # what restrictions apply to model space, note that encode file 
                   # tells which restrictions are forced by the learned model space,
                   intervened_variables = c(),
                   tmpDir = "../tmp/",
                   evalDirectCauses=FALSE,
                   outputCsv=FALSE,
                   outputClingo = NULL, # file in which optionally write the output clingo-style.
                   plotGraphs = TRUE,
                   verbose=1){ # how much information to print
  # Pipeline for running the algorithm inference. This first creates model and data, then runs
  # the requested inference and finally assesses and prints out the quality of the inference.
  # Use "set.seed()" before this function to compare the performance of several algorithms.
  #
  # Model properties:
  ###################
  # n  - number of observed variables (default=4)
  #
  #Data properties:
  #################
  #exconf   - experiment configuration, "passive" (default) or "single" or "random"
  # N       -total number of data samples (divided equally to all experiments) (default=1000)
  #
  #Independence test properties:
  ##############################
  #test     -type of test used to generate data, outputs a value between 0 and 1?
  #         -"classic" classic correlation test (p-value = 0.05)
  #         -"oracle" independence facts determined by Patrik's oracle
  #         -"bayes" integrating over the parameters
  #         -"BIC" (default) BIC-based approximation of the bayes test, faster and almost as good
  #         -the prior parameters are a little different, only p as the prior prob. is needed.
  #schedule -independence test scheduling
  #         -maximum conditioning set size for the independence tests
  #         -if a number T it means all tests up to intervention tests size T
  #           (can be Inf, default n-2 so all possible conditioning test sizes)
  #weight   -how to determine the weights from the dependencies:
  #         -"log" take log of the probability
  #         -"constant" the most likely option (dep or indep) gets weight 1
  #         -"hard-deps" put dependencies as hard constraints
  #         -for competing algorithms, pc and so on, use any of the above.
  ###############################
  #encode   - which encoding to use, gives the file in the ASP/ directory
  #solver   -"clingo", or "pcalg-fci","pcalg-cfci" or "bnlearn" for score based learning
  #p        -for bayes and BIC tests the apriori probability of 
  #         -for classic test using algorithms the p-value threshold
  #         -for BIC-based score based learning the prior parameter
  #alpha    -for bayes test the eq. sample size
  ###############################
  # solver_conf  - a string which defines additional parameters to clingo
  #Printing options:
  #verbose  -0 to not print anything, 1 to some printing
  ##############################################################################
  
  if (missing(tmpDir)) tmpDir <- file.path(tmpDir, as.numeric(Sys.time()))
  dir.create(tmpDir, showWarnings = FALSE, recursive = TRUE)

  if (is.na(p) || p < 0 || p > 1) p <- 0.5
  simulationConfig <- list(n=n, topology=topology, exconf=exconf, N=N, pedge=pedge, restrict=restrict, confounder_proportion=confounder_proportion)
  testConfig <- list(n=n, test=test, schedule=schedule, p=p, alpha=alpha, weight=weight, currentDir=tmpDir)
  
  # Use a template for all the files related to each run.
  filename_template <- filename_template_name(c(as.list(match.call()), formals()))
  
  # Simulate or use the provided data.
  MD <- simulate_data(simulationConfig=simulationConfig, samples=samples, model=model, indPath=indPath, 
                     isOracle= (test=="oracle"), verbose=verbose) 
  
  solverConfig <- list(n=n, schedule=schedule, weight=weight, p=p, solver=solver, encode=encode, 
                       solver_conf=solver_conf, multipleMinima=multipleMinima, evalDirectCauses=evalDirectCauses, MD=MD,
                       outputClingo=outputClingo, intervened_variables=intervened_variables)
  
  if (repeat_bootstrap == 0) {
    # Perform independence tests or read them from .ind.
    # Note: if we use a solver from the pcalg package the tests are supposed to be done incrementally by the algorithm, so we will fake it by using
    # the tests we performed here.
    test_time <- tic()
    if (!is.null(indPath)) {
      parsed_indeps <- parse_asp_indeps(indPath)
      tested_independences <- parsed_indeps$tested_independences
      testConfig$n <- parsed_indeps$n
    } else {
      t <- test_indeps(D=MD$D, testConfig=testConfig, verbose=verbose)
      tested_independences <- t$tested_independences
      indPath <- t$indPath
    }
    test_time <- toc(test_time)
    
    if (is.null(encode)) { 
      # Use only to compute tested independences.
      return (list(solving_time=0, testing_time=test_time, encoding_time=0, 
                   objective=NA, tested_independences=tested_independences))
    }
    
    # Try to learn a model.
    solverConfig$tested_independences<- tested_independences
    L <- learn_model(solverConfig, currentDir = tmpDir, filename_template=filename_template, indPath=indPath, 
               bckg_file=bckg_file, verbose=verbose)
    L$testing_time <- test_time
  } else {
    # Learn several models on different samples of the data and then average them.
    L <- bootstrap(repeat_bootstrap=repeat_bootstrap, N=N, solverConfig=solverConfig, testConfig=testConfig,
               filename_template=filename_template, tmpDir=tmpDir, bckg_file=bckg_file, verbose=verbose)
  }
  
  # Print the learned and true graph to dot files.
  if (plotGraphs) {
    plot_dot(learnedGraph=L, trueGraph=MD$M, filename_template=filename_template, 
                    dotFilesFolder=tmpDir, names=colnames(MD$D[[1]]$data), verbose=verbose)
  }
  
  if (outputCsv) {
    write.csv(x=L$C, file=file.path(tmpDir, paste(filename_template, ".csv", sep="")))
    write.csv(x=MD$D[[1]]$data, file=file.path(tmpDir, paste(filename_template, "_data.csv", sep="")))
  }
  
  invisible(L)
}

filename_template_name <- function(opt_list) {
  evalDirectCauses_string <- if (is.null(opt_list$evalDirectCauses)){""} else {if (opt_list$evalDirectCauses==TRUE) {"direct"} else {""}}
  mm_string <- if (opt_list$multipleMinima != FALSE) {opt_list$multipleMinima} else {""}
  
  paste(paste(opt_list$test, paste(opt_list$intervened_variables, collapse="",sep=""), sep=''), 
        opt_list$p, opt_list$N,
        paste(opt_list$schedule, collapse=""), gsub("./","", opt_list$encode) , opt_list$solver, 
        mm_string, opt_list$repeat_bootstrap, evalDirectCauses_string, sep="_")
}

short_template_name <- function(test, encode, solver, multipleMinima, repeat_bootstrap, evalDirectCauses=FALSE) {
  evalDirectCauses_string <- if (is.null(evalDirectCauses)){""} else if (evalDirectCauses) {"direct"} else {""}
  paste("v", test, gsub("./","", encode) , solver, if (multipleMinima != FALSE) {multipleMinima} else {""}, repeat_bootstrap, evalDirectCauses_string, sep="_")
}
