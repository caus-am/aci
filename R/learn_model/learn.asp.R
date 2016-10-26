learn.asp.available_solvers <- c("clingo")
learn.clingo <- c("./../ASP/clingo")

learn.asp <- function (solverConfig,
                       filename_template,
                       currentDir = "./../tmp/",
                       indPath = NULL,
                       bckg_file = NULL,
                       verbose=1) {
  # Function that prepares inputs and calls the ASP solver.
  #
  # Results options (where to store the results and tmp files):
  # currentDir           - the tmp folder where the results are stored.
  # aspSetsFilename      - the serialized version of sets, default: "pipeline.pre.asp",
  # indFilename          - the serialized version of independences, default: "pipeline.ind",
  # outputFilename       - the clingo/foxPSL output file, default: "pipeline.ind.clingo"
  sc <- solverConfig
  
  # Write independence tests results to file.
  if (is.null(indPath)) {
    indPath <- file.path(currentDir, paste(filename_template, '.ind', sep=''))
    writeIndepsToFile(n=sc$n, tested_independences=sc$tested_independences, write_function=write_independence_constraint, 
                      write_data=list(weight=sc$weight), indFilenameFullPath = indPath)    
    if (length(sc$intervened_variables) > 0) {
      # Check causal oracle and write causes and not causes relations.
      write_ancestral_constraint(sc$MD$M$C, append=TRUE, ints = sc$intervened_variables, indPath=indPath)
    }
  }
  
  # Encoding sets and write them in a different file (so we can reuse the independences file).
  aspSetsFullPath <- file.path(currentDir, paste(filename_template, '.pre.asp', sep=''))
  n <- sc$n
  
  encoding_time <- tic()
  if (sc$solver == "clingo") {
    if(grepl('hej_', sc$encode)) { 
      writeAspSets(n=n, aspSetsFullPath = aspSetsFullPath, tested_independences=sc$tested_independences)
      build_tree(n=n, aspSetsFullPath = aspSetsFullPath, tested_independences=sc$tested_independences)
    } else if (grepl('aci_',sc$encode) & grepl('complete',sc$encode)) {
      writeAspSets.aci(n=n, aspSetsFullPath = aspSetsFullPath)
    } else if (grepl('aci_',sc$encode) & !grepl('complete',sc$encode)) {
      # Check maxschedule.
      writeAspSets.nodes(n=n, aspSetsFullPath = aspSetsFullPath)
    }
  }
  encoding_time <- toc(encoding_time)
  
  # Create the fullpaths for each of the tmp files using the current directory.
  outputFullPath <- file.path(currentDir, paste(filename_template, '.ind.clingo', sep=''))

  ##############################################################################
  if (verbose) {
    printConfig <- sc; printConfig$MD <- NULL; printConfig$tested_independences <- NULL
    cat(" - Solving with config", paste(printConfig, collapse=","), "\n")
  }

  solving_time <- tic()
  if (sc$solver == "clingo") {
    clingoCmd <- paste(learn.clingo, " ", sc$solver_conf, " --const n=", n, sep="")
    clingoInputFiles <- paste(aspSetsFullPath, " ", indPath, " ./../ASP/", sc$encode, " ", bckg_file, sep="")
    
    if (sc$multipleMinima == FALSE){
      cmd <- paste(clingoCmd, clingoInputFiles, "| tee " , outputFullPath)
      cat(cmd)
      system(cmd, ignore.stdout = TRUE)
    } else if (sc$multipleMinima == "long" || sc$multipleMinima == "short") {
      L <- learn.asp.short(clingoCmd, clingoInputFiles, n=n)              
    } else if (sc$multipleMinima == "iterative" || sc$multipleMinima == "iterativeParallel") {
      L <- learn.asp.iterative(clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, n=n, filename_template=filename_template,
                               tested_independences=sc$tested_independences, evalDirectCauses=sc$evalDirectCauses, 
                               currentDir=currentDir, parallelise=(sc$multipleMinima == "iterativeParallel"))   
    }  else if (sc$multipleMinima == "iterativeCombined" || sc$multipleMinima == "iterativeCombinedParallel") {
      L <- learn.asp.iterativeCombined(clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, n=n, 
                                       filename_template=filename_template, currentDir=currentDir,
                                       parallelise=(sc$multipleMinima == "iterativeCombinedParallel"))   
    } else if (sc$multipleMinima == "iterative_new") {
      L <- learn.asp.iterative_new(clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, n=n, filename_template=filename_template,
                               currentDir=currentDir)   
    } else if (sc$multipleMinima == "iterative_comb_new") {
      L <- learn.asp.iterative_comb_new(clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, n=n, filename_template=filename_template,
                                   currentDir=currentDir)   
    } else if (sc$multipleMinima == "marginal") {
      L <- learn.asp.marginal(clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, n=n, filename_template=filename_template,
                                 currentDir=currentDir, p=sc$p)   
    } else if (sc$multipleMinima == "baseline") {
      L <- learn.asp.baseline(clingoCmd=clingoCmd, clingoInputFiles=clingoInputFiles, n=n, filename_template=filename_template,
                              currentDir=currentDir, p=sc$p)   
    }
    
  }
  
  sol_file<- outputFullPath
  solving_time <- toc(solving_time) 
    
  if (all(is.na(L)) ) {
    L<-list()
    solving_time<-Inf
  }
  
  L$encoding_time <- encoding_time
  L$solving_time <- solving_time
  
  L
}
