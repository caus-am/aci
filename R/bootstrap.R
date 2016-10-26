bootstrap <- function(repeat_bootstrap=10,
                   N=500, # sampling properties
                   solverConfig,
                   testConfig,        
                   filename_template,
                   tmpDir = "../tmp/",
                   bckg_file=NULL, # background knowledge file if available.
                   parallelize=FALSE,
                   verbose=0){ # how much information to print
  # Perform independence tests.
  if (parallelize) {
    listOfModels <- foreach (bootstrap_iter=1:repeat_bootstrap) %dopar% {
      bootstrap.loop(N=N, solverConfig=solverConfig, testConfig=testConfig, 
                     filename_template=filename_template, tmpDir=tmpDir, bckg_file=bckg_file, 
                     bootstrap_iter=bootstrap_iter, verbose=verbose)
    }
  } else {
    listOfModels <- list()
    for (i in 1:repeat_bootstrap) {
      m <- bootstrap.loop(N=N, solverConfig=solverConfig, testConfig=testConfig, 
                     filename_template=filename_template, tmpDir=tmpDir, bckg_file=bckg_file, 
                     bootstrap_iter=i, verbose=verbose)
      listOfModels[[length(listOfModels)+1]] <- m
    }
  }
  
  # Reduce all models:
  cadd <- function(x) Reduce("+", x, accumulate = FALSE)
  L <- list()
  L$C <- cadd(lapply(listOfModels, function(x) x$C))
  L$G <- cadd(lapply(listOfModels, function(x) x$G))
  L$Ge <- cadd(lapply(listOfModels, function(x) x$Ge))
  L$solving_time <- cadd(lapply(listOfModels, function(x) x$solving_time))
  L$test_time <- cadd(lapply(listOfModels, function(x) x$test_time))
  L$M <- solverConfig$MD$M
  
  # Average
  L$C <- L$C/repeat_bootstrap
  L$G <- L$G/repeat_bootstrap
  L$Ge <- L$Ge/repeat_bootstrap
  L$objective <- -1

  L
}


bootstrap.loop <- function(data_proportion=0.5, N, solverConfig, testConfig, 
                           filename_template, tmpDir, bckg_file, bootstrap_iter, verbose) {
  MD <- solverConfig$MD
  
  filename_template_i <- paste(filename_template, "_", bootstrap_iter, sep="")
  
  # Pick randomly data_proportion (e.g. half) of the samples.
  indices <- as.integer(runif(N*data_proportion)*N*data_proportion)
  halfD <- MD$D
  if (is.null(MD$D)) {
    stop("Raw data not provided, cannot bootstrap.")
  }
  halfD[[1]]$data <- MD$D[[1]]$data[indices, ]
  halfD[[1]]$N <- halfD[[1]]$N*data_proportion
  #halfD[[1]]$Cx <- cov(halfD[[1]]$data)
  halfMD <- list(D=halfD, M=MD$M)
  
  test_time <- tic()
  t <- test_indeps(D=halfD, testConfig=testConfig, verbose=verbose)
  test_time <- toc(test_time)
  
  solverConfig_tmp <- solverConfig
  solverConfig_tmp$MD <- halfMD
  solverConfig_tmp$tested_independences <- t$tested_independences
  
  L <- learn_model(solverConfig_tmp, currentDir=tmpDir, filename_template=filename_template_i, 
                   indPath=t$indPath, bckg_file=bckg_file, verbose=verbose)
  L$test_time <- test_time
  L
}
