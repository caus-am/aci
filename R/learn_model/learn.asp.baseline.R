learn.asp.baseline <- function(clingoCmd, clingoInputFiles, n, filename_template,
                       tested_independences,
                       currentDir,
                       debugOutput=FALSE,
                       parallelise=TRUE,
                       evalDirectCauses=FALSE,
                       returnNothingIfTimeout=FALSE,
                       verbose=1){
  tempResultDir <- file.path(currentDir, "tempResults")
  dir.create(tempResultDir, showWarnings = FALSE, recursive = TRUE)
  
  C <- array(0, c(n,n))
  G <- array(0, c(n,n))
  
  baselineClingoCmd <- paste(clingoCmd, clingoInputFiles)
  if (debugOutput) {
    optCmd <- paste(baselineClingoCmd, "|tee",  file.path(tempResultDir, paste(filename_template, "_baseline.txt", sep="")))
  } else {
    optCmd <- paste(baselineClingoCmd)
  }
  optResult <- system(optCmd, intern = TRUE)
  
  if (length(grep("INTERRUPTED", optResult))> 0 || length(grep("TIME LIMIT", optResult))> 0){
    if (returnNothingIfTimeout) {
      return (list(C=C, G=G, Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=-1, timeout=TRUE))
    }
    baselineTimeout = TRUE
  } else {
    baselineTimeout = FALSE
  }
  
  if (length(grep("UNSATISFIABLE", optResult))> 0) {
    # The optimization is unsatisfiable.
    return (list(C=array(-Inf, c(n,n)), G=G, Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=-1, timeout=FALSE))
  } else if (length(grep("OPTIMUM FOUND", optResult))> 0){
    optimumLine <- optResult[grep('Optimization : ', optResult)]
    optimum_baseline <- as.numeric(gsub('Optimization : ','', optimumLine))
  } else if (length(grep("SATISFIABLE", optResult))> 0){
    optimumLine <- optResult[grep('Optimization : ', optResult)]
    optimum_baseline <- as.numeric(gsub('Optimization : ','', optimumLine))
  } else if (baselineTimeout) {
    optimum <- -2
  } else {
    stop("Strange behaviour of solver:", optResult)
  }
  
  list(C=C, G=G, Ge=array(0, c(n,n)), Gs=array(0, c(n,n)), objective=optimum_baseline, timeout=baselineTimeout)
}