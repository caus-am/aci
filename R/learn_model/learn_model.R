learn_model <- function(solverConfig, currentDir, filename_template, indPath, bckg_file, verbose=0){ 
  # Function that learns the model.
  # Returns the learned model L.
  # available_solvers <- c(learn.asp.available_solvers, learn.pcalg.available_solvers)
  sc <- solverConfig
  
  if (sc$solver %in% learn.pcalg.available_solvers) {
    L <- learn.pcalg(solverConfig=sc, filename_template=filename_template,
                         currentDir=currentDir, indPath=indPath, bckg_file=bckg_file, verbose=verbose)
  } else if (sc$solver %in% learn.asp.available_solvers) {   
    L <- learn.asp(solverConfig=sc, filename_template=filename_template,
                   currentDir=currentDir, indPath=indPath, bckg_file=bckg_file, verbose=verbose)
  } else if (sc$solver == "bnlearn"){
    L <- learn.bnlearn(solverConfig=sc, filename_template=filename_template,
                       currentDir=currentDir, indPath=indPath, bckg_file=bckg_file, verbose=verbose)
  } else{
    stop("Solver ", solver, " not found.")
  }
  L$tested_independences <- sc$tested_independences
  # Save also the true model.
  L$M <- sc$MD$M
  
  # Works also for FCI.
  if (!is.null(sc$outputClingo)){
    G <- if (sc$evalDirectCauses) {L$G} else {L$C}
    
    outputFile <- file(sc$outputClingo, "w")
    for (i in 1:nrow(G)){
      for (j in 1:ncol(G)){
        if (G[i,j] < 0) {
          cat("-", file=outputFile)
        }
        cat("causes(",j,",", i,")=", abs(G[i,j]), sep="", file=outputFile)
        if (!is.infinite(G[i,j])){
          cat(".00000", sep="", file=outputFile)
        }
        cat("\n", sep="", file=outputFile)
      }
    }
    close(outputFile)
  }
  
  if (verbose) {
    cat("Printing true and learned model.")
    cat("\nTrue model - direct causes :\n"); print(L$M$G)
    cat("\nLearned direct relations:\n"); print(L$G)
    cat("\n\nTrue model - ancestral relations:\n"); print(L$M$C)
    cat("\nLearned ancestral relations:\n"); print(L$C)
  }
  
  L
}
