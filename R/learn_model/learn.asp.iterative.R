learn.asp.iterative <- function(clingoCmd, clingoInputFiles, n, filename_template,
                       tested_independences,
                       currentDir = "./../tmp/",
                       debugOutput=FALSE,
                       parallelise=TRUE,
                       evalDirectCauses=FALSE,
                       causesThreshold=0,
                       notCausesThreshold=0,
                       returnNothingIfTimeout=FALSE,
                       verbose=1){
  tempResultDir <- file.path(currentDir, "tempResults")
  dir.create(tempResultDir, showWarnings = FALSE, recursive = TRUE)
  
  C <- array(0, c(n,n))
  G <- array(0, c(n,n))
  solving_time_direct <- NULL
  
  baselineClingoCmd <- paste(clingoCmd, clingoInputFiles)
  if (debugOutput) {
    optCmd <- paste(baselineClingoCmd, "|tee",  file.path(tempResultDir, paste(filename_template, "_baseline.txt", sep="")))
  } else {
    optCmd <- paste(baselineClingoCmd)
  }
  optResult <- system(optCmd, intern = TRUE)
  
  if (length(grep("INTERRUPTED", optResult))> 0 || length(grep("TIME LIMIT", optResult))> 0){
    if (returnNothingIfTimeout) {
      return (list(C=C, G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=-1, timeout=TRUE))
    }
    baselineTimeout = TRUE
  } else {
    baselineTimeout = FALSE
  }
  
  if (length(grep("UNSATISFIABLE", optResult))> 0) {
    # The optimization is unsatisfiable.
    return (list(C=array(-Inf, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=-1, timeout=FALSE))
  } else if (length(grep("OPTIMUM FOUND", optResult))> 0){
    optimumLine <- optResult[grep('Optimization : ', optResult)]
    optimum_baseline <- as.numeric(gsub('Optimization : ','', optimumLine))
  } else if (length(grep("SATISFIABLE", optResult))> 0){
    optimumLine <- optResult[grep('Optimization : ', optResult)]
    optimum_baseline <- as.numeric(gsub('Optimization : ','', optimumLine))
  } else if (baselineTimeout) {
    optimum <- 0
  } else {
    stop("Strange behaviour of solver:", optResult)
  }
  
  if (parallelise) {
    scoresC <- foreach (i = 1:length(C)) %dopar% {
      learn.asp.iterative.loop (n, filename_template,  (i-1)%% n + 1 , (i-1)%/% n + 1, predicateToTest= "causes",
                                tempResultDir, baselineClingoCmd, optimum_baseline=optimum_baseline, debugOutput=debugOutput, verbose=verbose)
    }
    if (evalDirectCauses) {
      solving_time_direct <- tic()
      directBaselineClingoCmd <- learn.asp.iterative.prepare_direct(n=n, scoresC=scoresC, 
                              tested_independences=tested_independences, currentDir=currentDir, 
                              filename_template=filename_template, clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, 
                              causesThreshold=causesThreshold, notCausesThreshold=notCausesThreshold)
      
      scoresG <- foreach (i = 1:length(G)) %dopar% {
        learn.asp.iterative.loop (n, filename_template,  (i-1)%% n + 1 , (i-1)%/% n + 1, predicateToTest= "edge",
                                  tempResultDir, directBaselineClingoCmd, optimum_baseline=optimum_baseline, baselineTimeout=baselineTimeout, debugOutput=debugOutput, verbose=verbose)
      }
      solving_time_direct <- toc(solving_time_direct)
    }
  } else {
    scoresC <- list()
    for (i in 1:length(C)) {
      score <- learn.asp.iterative.loop (n, filename_template,  (i-1)%% n + 1 , (i-1)%/% n + 1, predicateToTest= "causes",
                                         tempResultDir, baselineClingoCmd, optimum_baseline=optimum_baseline, debugOutput=debugOutput, verbose=verbose)
      if (returnNothingIfTimeout && score$timeout) {
        return (list(C=array(0, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=TRUE))
      }
      scoresC[[length(scoresC)+1]] <- score
    }
    
    if (evalDirectCauses) {     
      solving_time_direct <- tic()
      directBaselineClingoCmd <- learn.asp.iterative.prepare_direct(n=n, scoresC=scoresC, 
                                tested_independences=tested_independences, currentDir=currentDir, 
                                filename_template=filename_template, clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, 
                                causesThreshold=causesThreshold, notCausesThreshold=notCausesThreshold)
      
      scoresG <- list()
      for (i in 1:length(G)) {
        score <- learn.asp.iterative.loop (n, filename_template,  (i-1)%% n + 1 , (i-1)%/% n + 1, predicateToTest= "edge",
                                           tempResultDir, directBaselineClingoCmd, optimum_baseline=optimum_baseline, debugOutput=debugOutput, verbose=verbose)
        if (returnNothingIfTimeout && score$timeout) {
          return (list(C=array(0, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=TRUE))
        }
        scoresG[[length(scoresG)+1]] <- score
      }
      solving_time_direct <- toc(solving_time_direct)
    }
  }

  # The previous loop was in parallel, once it's done we can use the values to populate C.
  for (i in 1:length(C)){
    if (returnNothingIfTimeout && scoresC[[i]]$timeout) {
      # Unluckily cannot do in parallel foreach.
      return (list(C=array(0, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=TRUE))
    }
    arg1 <- (i-1)%% n + 1 
    arg2 <- (i-1)%/% n + 1
    if (scoresC[[i]]$timeout) {
      C[arg2, arg1] <- 0
    } else {
      C[arg2, arg1] <- scoresC[[i]]$score
    }
    if (evalDirectCauses) {
      G[arg2, arg1] <- scoresG[[i]]$score
    } 
  }
  
  list(C=C, G=G, Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=optimum_baseline, solving_time_direct=solving_time_direct, timeout=FALSE)
}

learn.asp.iterative.loop <- function (n, filename_template,
                                      arg1, arg2,
                                      tempResultDir, originalClingoCmd,
                                      optimum_baseline,
                                      predicateToTest= "causes",
                                      baselineTimeout = FALSE,
                                      debugOutput=FALSE,
                                      returnNothingIfTimeout=FALSE,
                                      verbose=1) {
  if (arg1 == arg2){
    L <- list(score=-Inf, timeout=FALSE)
    return(L)
  }
  
  optimum_causes <- 0
  optimum_not_causes <- 0
  
  atLeastOneTimeout <- FALSE
  
  for (type in list("", "not")) {    
    optimum_or_timeout <- learn.asp.iterative.loop.internal(n, filename_template, arg1, arg2,
                                      tempResultDir, originalClingoCmd, predicateToTest=predicateToTest,
                                      type=type, debugOutput=debugOutput, verbose=verbose)
    
    if (optimum_or_timeout$timeout){
      atLeastOneTimeout <- TRUE
      if (returnNothingIfTimeout){
        return (list(score=0, timeout=TRUE))
      }
    }
    
    optimum <- optimum_or_timeout$optimum
    
    if (type != "not") {
      optimum_not_causes <- optimum
    } else {
      optimum_causes <- optimum
    }
    
    if (!baselineTimeout && optimum != optimum_baseline) {
      # No need to do the next minimization, we already found the score.
      next
    }
  }
  
  list(score=optimum_not_causes-optimum_causes, timeout=atLeastOneTimeout)
}

learn.asp.iterative.loop.internal <- function (n, filename_template,
                                      arg1, arg2,
                                      tempResultDir, originalClingoCmd,
                                      type,
                                      predicateToTest= "causes",
                                      debugOutput=FALSE,
                                      returnNothingIfTimeout=FALSE,
                                      verbose=1){
  
  extraAspBaseName <- file.path(tempResultDir, paste(filename_template, type, arg1, arg2, sep="_"))
  extraAspProgram <- paste(extraAspBaseName, ".pl", sep="")
  cat(paste(":- ", type, " ", predicateToTest, "(", arg1, ",", arg2, ").",sep =""), file=extraAspProgram)
  
  if (debugOutput) {
    optCmd <- paste(originalClingoCmd, extraAspProgram, "|tee ", paste(extraAspBaseName, ".txt", sep=""))
  } else {
    optCmd <- paste(originalClingoCmd, extraAspProgram)
  }
  optResult <- system(optCmd, intern = TRUE)
  
  if ((length(grep("INTERRUPTED", optResult))> 0 || length(grep("TIME LIMIT", optResult)))> 0){
    # Timeout
    if (returnNothingIfTimeout) {return (list(optimum=0, timeout=TRUE))}
    optTimeout = TRUE
  } else {
    optTimeout = FALSE
  }

  if (length(grep("UNSATISFIABLE", optResult))> 0) {
    # The optimization is unsatisfiable.
    return (list(optimum=Inf, timeout=FALSE))
  } else if (length(grep("OPTIMUM FOUND", optResult))> 0){
    optimumLine <- optResult[grep('Optimization : ', optResult)]
    optimum <- as.numeric(gsub('Optimization : ','', optimumLine))
  } else if (length(grep("SATISFIABLE", optResult))> 0){
    optimumLine <- optResult[grep('Optimization : ', optResult)]
    optimum <- as.numeric(gsub('Optimization : ','', optimumLine))
  } else if (optTimeout) {
    optimum <- 0
  }  else {
    stop("Strange behaviour of solver:", optResult)
  }
  list(optimum=optimum, timeout=optTimeout)
}

learn.asp.iterative.prepare_direct <- function(n, scoresC, tested_independences, 
                                               currentDir, filename_template, 
                                               clingoCmd, clingoInputFiles, 
                                               causesThreshold=0, notCausesThreshold=0){
  if (grepl("aci", clingoInputFiles) > 0){
    ancestralResults <-   file.path(currentDir, paste(filename_template, "_ancestral.txt", sep=""))
    ancFile <- file(ancestralResults, "w")
    for (i in 1:length(scoresC)){
      arg1 <- (i-1)%% n + 1 
      arg2 <- (i-1)%/% n + 1
      if(scoresC[[i]]$score > causesThreshold) {
        cat(":- not causes(",arg1,",", arg2,").\n", sep="", file=ancFile)
      } else if(scoresC[[i]]$score < notCausesThreshold) {
        cat(":- causes(",arg1,",", arg2,").\n", sep="", file=ancFile)
      }   
    }
    close(ancFile)
    clingoInputFiles <- gsub("ASP/aci_complete.pl", "ASP/hej_mod.pl", clingoInputFiles)
    clingoInputFiles <- gsub("ASP/aci_1.pl", "ASP/hej_mod.pl", clingoInputFiles)
    aspSetsFullPathDirect <-  file.path(currentDir, paste(filename_template, "_direct.pre.asp", sep=""))
    writeAspSets(n=n, aspSetsFullPath = aspSetsFullPathDirect, tested_independences=tested_independences)
    build_tree(n=n, aspSetsFullPath = aspSetsFullPathDirect, tested_independences=tested_independences)   
    paste(clingoCmd, clingoInputFiles, aspSetsFullPathDirect, ancestralResults)
  } else {
    paste(clingoCmd, clingoInputFiles)
  }
}