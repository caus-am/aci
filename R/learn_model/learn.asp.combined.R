learn.asp.iterativeCombined <- function(clingoCmd, clingoInputFiles, n, filename_template,
                       currentDir = "./../tmp/", debugOutput=FALSE, 
                       evalDirectCauses=FALSE,
                       parallelise=TRUE, verbose=1) {
  ## Note: almost the same as iterative, but since we are not computing the baseline,
  ## all the values are shifted by the baseline value.
  
  C <- array(0, c(n,n))
  G <- array(0, c(n,n))
  
  L <- learn.asp.short(clingoCmd, clingoInputFiles, n)
  if (L$timeout) {
    return (list(C=C, G=G, Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=-1, timeout=TRUE))
  }
  
  baselineClingoCmd <- paste(clingoCmd, clingoInputFiles)
  multipleMinimaTempDir <- paste(currentDir, "/multipleMinimaTemp/", sep ="")
  system(paste("mkdir -p", multipleMinimaTempDir))
  
  if (parallelise) {
    scoresC <- foreach (i = 1:length(L$C)) %do% { 
      learn.asp.iterativeCombined.loop(arg1 = (i-1)%% n + 1 , arg2 = (i-1)%/% n + 1, C=L$C, baselineClingoCmd=baselineClingoCmd,
                                     n=n, filename_template=filename_template, predicateToTest="causes",
                                     multipleMinimaTempDir=multipleMinimaTempDir, debugOutput=debugOutput, verbose=verbose)
    }
    if (evalDirectCauses) {
      scoresG <- foreach (i = 1:length(L$G)) %do% { 
        learn.asp.iterativeCombined.loop(arg1 = (i-1)%% n + 1 , arg2 = (i-1)%/% n + 1, C=L$G, baselineClingoCmd=baselineClingoCmd,
                                       n=n, filename_template=filename_template, predicateToTest="edge",
                                       multipleMinimaTempDir=multipleMinimaTempDir, debugOutput=debugOutput, verbose=verbose)
      }
    }
  } else {
    scoresC <- list()
    for (i in 1:length(L$C)) { 
      score <- learn.asp.iterativeCombined.loop(arg1 = (i-1)%% n + 1 , arg2 = (i-1)%/% n + 1, C=L$C, baselineClingoCmd=baselineClingoCmd,
                                       n=n, filename_template=filename_template, predicateToTest="causes",
                                       multipleMinimaTempDir=multipleMinimaTempDir, debugOutput=debugOutput, verbose=verbose)
      if (score$timeout) {
        # Unluckily cannot do in foreach.
        return (list(C=array(0, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=TRUE))
      }
      scoresC[[length(scoresC)+1]] <- score
    }
    if (evalDirectCauses) {
      scoresG <- list()
      for (i in 1:length(L$G)) { 
        score <- learn.asp.iterativeCombined.loop(arg1 = (i-1)%% n + 1 , arg2 = (i-1)%/% n + 1, C=L$G, baselineClingoCmd=baselineClingoCmd,
                                                  n=n, filename_template=filename_template, predicateToTest="edge",
                                                  multipleMinimaTempDir=multipleMinimaTempDir, debugOutput=debugOutput, verbose=verbose)
        if (score$timeout) {
          # Unluckily cannot do in foreach.
          return (list(C=array(0, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=TRUE))
        }
        scoresG[[length(scoresG)+1]] <- score
      }
    }
  }
  
  for (j in 1:length(C)){
    if (scoresC[[j]]$timeout) {
      # Unluckily cannot do in foreach.
      return (list(C=array(0, c(n,n)), G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=TRUE))
    }
    arg1 <- (j-1)%% n + 1 
    arg2 <- (j-1)%/% n + 1
    C[arg2, arg1] <- scoresC[[j]]$optimum
    if (evalDirectCauses) {
      G[arg2, arg1] <- scoresG[[j]]$optimum
    }
  }
  
  list(C=C, G=array(0, c(n,n)), Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=0, timeout=FALSE)
}

learn.asp.iterativeCombined.loop <- function(arg1, arg2, C, baselineClingoCmd, n, filename_template,
                                             predicateToTest= "causes",
                                             multipleMinimaTempDir, debugOutput=FALSE, verbose=FALSE) {
  if (C[arg2, arg1] > 0 ) {   
    learn.asp.iterative.loop.internal (n, filename_template, arg1 , arg2, 
                                       multipleMinimaTempDir, baselineClingoCmd, type="", 
                                       predicateToTest=predicateToTest, debugOutput=debugOutput, verbose=verbose)  
  } else if (C[arg2, arg1] < 0){
    if (arg1 == arg2){
      list(optimum=-Inf, timeout=FALSE)
    } else {
      optimum_or_timeout <- learn.asp.iterative.loop.internal (n, filename_template, arg1 , arg2,
                                                               multipleMinimaTempDir, baselineClingoCmd, type="not", 
                                                               predicateToTest=predicateToTest, debugOutput=debugOutput, verbose=verbose)
      list(optimum=-optimum_or_timeout$optimum, timeout=optimum_or_timeout$timeout)
    }
  } else {
    list(optimum=0, timeout=FALSE)
  }
}