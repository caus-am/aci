plot_dot <- function(learnedGraph, trueGraph, filename_template, dotFilesFolder, names=NULL, verbose=0) {
  # Function that prints out a dot representation for the learned and true graphs,
  # both for the independencies and causes edges.
  # Uses filename_template for file names and outputs plots in the dotFilesFolder.
  if (!is.null(learnedGraph$G)) {
    plot_dot.plot(learnedGraph, filename = file.path(dotFilesFolder, paste(filename_template, "_G.dot", sep="")), verbose=verbose, plotNotCauses=FALSE)
    if (!is.null(trueGraph)) {
      plot_dot.plot(trueGraph, filename = file.path(dotFilesFolder, "true_graph.dot"), 
                             plotNotCauses=FALSE, plotEffect=TRUE, verbose=verbose)
    }
  }
  plot_dot.plotCauses(learnedGraph$C, 
    filename = file.path(dotFilesFolder, paste(filename_template, ".dot", sep="")), names=names, verbose=verbose)
  if (!is.null(trueGraph)) {
    plot_dot.plotCauses(trueGraph$C, filename = file.path(dotFilesFolder, "true_causes.dot"), 
                                 names=names, plotNotCauses=FALSE, verbose=verbose)
  }
}

plot_dot.plot<-function(M, filename="../tmp/graph.dot", verbose, plotNotCauses=TRUE, plotEffect=FALSE) {
  # Function that prints out a dot representation for the model M that are output by the ASP solver.
  # In general, in the rest of the code:
  # - M$G is an array representing the adjaciency matrix for directed edges (direction of edges seems reversed), e.g. edge(1, 2).
  # - M$Gs is the adjaciency matrix for undirected edges (note: they don't seem to be present in the solution.)
  # - M$Ge is the adjaciency matrix for bidirected edges, e.g. conf(2, 3).
  #
  graphFile <- file(filename, "w")
  cat('digraph graphname {', file=graphFile)
  #cat('\n layout="circo";\n', file=graphFile)
  
  # Plot M$G and M$Ge on the same graph:
  # - M$G are directed edges;
  # - M$Ge are bidirected blue edges;
  
  # For each row:
  for (i in 1:dim(M$G)[1]) {
    # For each column:
    for (j in 1:dim(M$G)[2]) {
      if (i == j) next
      if (M$G[i,j] > 0){
        if (plotEffect) {
          cat(j, "->", i, "[color=green, label=\"", M$B[i,j] ,"\"];\n", file=graphFile)
        } else {
          cat(j, "->", i, "[color=green, label=\"", M$G[i,j] ,"\"];\n", file=graphFile) 
        }
      }
      if (M$G[i,j] < 0 && plotNotCauses){
        cat(j, "->", i, "[color=red, label=\"", M$G[i,j] ,"\"];\n", file=graphFile)
      }
      if (M$G[i,j] == 0){
        cat(j, "->", i, "[color=blue, label=0];\n", file=graphFile)
      }
    }
  }
  
  for (i in 1:dim(M$Ge)[1]) {
    # For each column:
    for (j in 1:dim(M$Ge)[2]) {
      if (i < j) next   
      if (!is.null(M$trueCe[i,j])) {
        effect <- M$trueCe[i,j]
      } else {
        effect <- M$Ge[i,j]
      }
      if (plotEffect && effect != 0) {
        cat(i, "->", j, "[color=cyan, dir=both, label=\"", effect, "\"];\n", file=graphFile)
      }
      if (!is.null(M$Ce[i,j]) && plotEffect && M$Ce[i,j] != 0) {
        cat(i, "->", j, "[color=orange, dir=both, label=\"", M$Ce[i,j], "\"];\n", file=graphFile)
      } else {
        if (i == j) next
        if (M$Ge[i,j] > 0){
          cat(i, "->", j, "[color=orange, dir=both, label=\"", M$Ge[i,j], "\"];\n", file=graphFile)
        }
      }
      #if (M$Ge[i,j] < 0 && plotNotCauses) {
      #  cat(j, "->", i, "[color=purple, dir=both, label=\"", M$Ge[i,j], "\"];\n", file=graphFile)
      #}
      #if (M$Ge[i,j] == 0) {
      #  cat(j, "->", i, "[color=cyan, dir=both, label=0];\n", file=graphFile)
      #}
    }
  }

  cat("\n}", file=graphFile)
  close(graphFile)
  #dotCmd <-paste('dot -Tps ', filename, "-o ", paste(filename,".pdf", sep=""))
  #system(dotCmd)
}

plot_dot.plotCauses<-function(C, filename="../tmp/graph.dot", names=NULL, verbose=1, plotTred=FALSE, plotNotCauses=TRUE, threshold = 0, 
                                       topN=NULL) {
  if (!is.null(topN)) {
    min <- C[order(C, decreasing=T)[topN]]
    C[which(C < min)] <- -Inf
  }
  graphFile <- file(filename, "w")
  cat('digraph graphname {', file=graphFile)
  #cat('\n layout="circo";\n', file=graphFile)
  
  if (!is.null(names)) {
    cat('node [shape = rect];', file=graphFile)
    hasInts <- FALSE
    # If there are intervention variables, show them as rectangles.
    for (i in 1:length(names)){
      if (grepl("^i",names[i])){
        hasInts <- TRUE
        cat(gsub("\\.", "", names[i]), "_", i, " ", sep="", file=graphFile)
      }
    }
    if (hasInts) cat(';\n', file=graphFile)
  }
  cat('node [shape = oval];\n', file=graphFile)
  
  # For each row:
  for (i in 1:dim(C)[1]) {
    # For each column:
    for (j in 1:dim(C)[2]) {
      if (is.null(names)) {
        label_i <- i
        label_j <- j
      } else {
        label_i <- paste(gsub("\\.", "", names[i]), "_", i, sep="")
        label_j <- paste(gsub("\\.", "", names[j]), "_", j, sep="")
      }
      if (i==j) {
        next
      }
      
      if (C[i,j] == threshold) {
        cat(label_j, "->", label_i, "[color=blue, label=0];\n", file=graphFile)
      }
      if (C[i,j] > threshold) {
        if (grepl("^i",label_j)){
          cat(label_j, "->", label_i, "[color=green, style=dotted, label=\"", C[i,j], "\"];\n", file=graphFile)
        } else {
          cat(label_j, "->", label_i, "[color=green,label=\"", C[i,j], "\"];\n", file=graphFile) 
        }
      }
      if (C[i,j] < threshold && plotNotCauses) {
        if (is.infinite(C[i,j])){
          # skip for now.
          next
          # Dot does not like -Inf.
          cat(label_j, "->", label_i, "[color=red, style=dotted];\n", file=graphFile)
        } else {
          cat(label_j, "->", label_i, "[color=red, label=\"", C[i,j], "\"];\n", file=graphFile)
        }     
      }
    }
  }
  
  cat("\n}", file=graphFile)
  close(graphFile)
  if (plotTred) {
    dotCmd <-paste('tred ', filename, ">", paste(filename,".tred.dot", sep=""))
    system(dotCmd)
  }
}

plot_dot.plotCausalEffects<-function(C, filenameBase="graph_effects", tmpDir="../tmp/", multipleMinima="iterative", names=NULL, verbose=1) {  
  # Initialize graphs:
  for (i in 1:dim(C)[2]) {
    if (is.null(names)) {
      label_i <- i
    } else {
      label_i <- paste(gsub("\\.", "", names[i]), "_", i, sep="")
    }
    graphFile <- file(paste(tmpDir, "/", label_i, "_", filenameBase, ".dot", sep=""), "w")
    cat('digraph graphname {\nrankdir=LR;\n', file=graphFile)
    # Add intervention nodes.
    for (j in 1:dim(C)[2]) {
      if (is.null(names)) {
        label_j <- j
      } else {
        label_j <- paste(gsub("\\.", "", names[j]), "_", j, sep="")
      }
      if (grepl("^i",label_j)){
        cat('node [shape = rect];', label_j, ";\n", file=graphFile)
        cat('node [shape = oval];\n', file=graphFile)
      }
    } 
    close(graphFile)
  }
  
  # For each row:
  for (j in 1:dim(C)[2]) {
    if (is.null(names)) {
      label_j <- j
    } else {
      label_j <- paste(gsub("\\.", "", names[j]), "_", j, sep="")
    }
    descendantsFile <- file(paste(tmpDir, "/", label_j, "_", filenameBase, ".dot", sep=""), "a")
    
    # For each column:
    for (i in 1:dim(C)[1]) {
      if (i==j) {
        next
      }
      
      if (is.null(names)) {
        label_i <- i
      } else {
        label_i <- paste(gsub("\\.", "", names[i]), "_", i, sep="")      
      }
      parentsFile <- file(paste(tmpDir, "/", label_i, "_", filenameBase, ".dot", sep=""), "a")
      
      hasNewScores <- multipleMinima=="iterative" || multipleMinima=="iterativeParallel" || multipleMinima=="loci++"
      
      # Unknown.
      if ((hasNewScores && C[i,j] == 0) || (!hasNewScores && C[i,j] > 0 && C[i,j] < 1) || (!hasNewScores && C[i,j] == 2)) {
          cat(label_j, "->", label_i, "[color=blue, label=0];\n", file=descendantsFile)
          cat(label_j, "->", label_i, "[color=blue, label=0];\n", file=parentsFile)
      }
      
      # Causes.
      if ((hasNewScores && C[i,j] > 0) || (!hasNewScores && C[i,j] == 1)) {
        if (grepl("^i",label_j)){
          cat(label_j, "->", label_i, "[color=green, style=dotted, label=\"", C[i,j], "\"];\n", file=descendantsFile)
          cat(label_j, "->", label_i, "[color=green, style=dotted, label=\"", C[i,j], "\"];\n", file=parentsFile)
        } else {
          cat(label_j, "->", label_i, "[color=green,label=\"", C[i,j], "\"];\n", file=descendantsFile) 
          cat(label_j, "->", label_i, "[color=green,label=\"", C[i,j], "\"];\n", file=parentsFile) 
        }
      }
      
      # Not causes.
      #if ((hasNewScores && C[i,j] < 0) || (!hasNewScores && C[i,j] == 0)) {
      if ((hasNewScores && C[i,j] < 0)) {
        if (is.infinite(C[i,j])){
          next
          # Dot does not like -Inf.
          cat(label_j, "->", label_i, "[color=red, style=dotted];\n", file=descendantsFile)
          cat(label_j, "->", label_i, "[color=red, style=dotted];\n", file=parentsFile)
        } else {
          cat(label_j, "->", label_i, "[color=red,label=\"", C[i,j], "\"];\n", file=descendantsFile)
          cat(label_j, "->", label_i, "[color=red,label=\"", C[i,j], "\"];\n", file=parentsFile)
        }     
      }
      close(parentsFile)
    }
    close(descendantsFile)
  }
  
  # Footer.
  for (j in 1:dim(C)[2]) {
    if (is.null(names)) {
      label_j <- j
    } else {
      label_j <- paste(gsub("\\.", "", names[j]), "_", j, sep="")
    }
    graphFile <- file(paste(tmpDir, "/", label_j, "_", filenameBase, ".dot", sep=""), "a")
    cat('\n}', file=graphFile)
    close(graphFile)
  }
}