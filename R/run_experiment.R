run_experiment.unitTestOracleSchedule1 <- function(howmany=1, n=4, tmpDir = "../tmp/unitTest1/", 
                                  runLongMultipleMinima=TRUE, local=FALSE){
  # These have to agree all.
  run_experiment(howmany = howmany, n=n, test="oracle", schedule = 1,
                 runHEJRules = FALSE, runFci=TRUE, runcFci=FALSE, tmpDir=tmpDir, runComparison=TRUE)
}


run_experiment <- function(howmany=1, n=4, N=500, repeat_bootstrap=10, exconf='passive', 
                          confounder_proportion=0.5, pedge=1/(n-1),
                          schedule=1, # schedule=n-2
                          restrict =c('acyclic'), 
                          topology='random', 
                          weight = 'log',
                          intervened_variables = c(),
                          seed_offset = 0,
                          p=c(0.05),
                          tmpDir = "../tmp/unitTest/",
                          indPath = NULL, # input .ind file if given
                          test="logp",
                          runHEJRules=TRUE,
                          runACIRules=TRUE,
                          runIterOpt=TRUE,
                          runDirectEval=FALSE,
                          runOracle=TRUE,
                          runFci=TRUE,
                          runcFci=TRUE,
                          runBnlearn=FALSE,
                          runComparison=FALSE,
                          plotRocCurve=TRUE,
                          plotSingleRocCurves=FALSE,
                          useSimplerEncoding=TRUE,
                          solver_conf="--time-limit=2000 --quiet=1"){
  dir.create(tmpDir, showWarnings = FALSE, recursive = TRUE)

  encodingACI <- if (schedule != 1 && !useSimplerEncoding) { "aci_complete.pl"} else { "aci_1.pl"}
  encodingHEJ <- "hej_mod.pl"
  
  # Initialization of option list, containing all configurations for the experiment.
  opt_list_all <- list()
  opt_list_template <- list(n=n,exconf=exconf, p=p,weight=weight, intervened_variables=intervened_variables,
                            N=N,alpha=1.5,restrict=restrict, indPath=indPath,
                            solver_conf=solver_conf)
  
  if (runACIRules){
    if (runIterOpt) {
      opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
           list(test=test, schedule=schedule, solver="clingo", multipleMinima="iterative", encode=encodingACI, repeat_bootstrap=0))
      if (runOracle && test != "oracle") {
        opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
            list(test="oracle", schedule=schedule, solver="clingo", multipleMinima="iterative", encode=encodingACI, repeat_bootstrap=0))
      }
      if (runDirectEval) {
        opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template,
           list(evalDirectCauses=TRUE, test=test, schedule=schedule, solver="clingo", multipleMinima="iterative", encode=encodingACI, repeat_bootstrap=0))
      }
    }
  }
  
  if (runHEJRules) {
    if (runIterOpt) {
      opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
          list(test=test, schedule=schedule, solver="clingo", multipleMinima="iterative", encode=encodingHEJ, repeat_bootstrap=0))
      if (runOracle && test != "oracle") {
        opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
          list(test="oracle", schedule=schedule, solver="clingo", multipleMinima="iterative", encode=encodingHEJ, repeat_bootstrap=0))
      }
      if (runDirectEval) {
        opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, evalDirectCauses=TRUE,
          list(test=test, schedule=schedule, solver="clingo", multipleMinima="iterative", encode=encodingHEJ, repeat_bootstrap=0))
      }
    }
  }
  
  if (runFci) {
    opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
        list(test=test, schedule=n-2, solver="pcalg-fci", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=0))
    opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
      list(test=test, schedule=n-2, solver="pcalg-fci", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=repeat_bootstrap))
    if (runOracle && test != "oracle") {
      opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
        list(test="oracle", schedule=n-2,solver="pcalg-fci", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=0))
    }
  }
  
  if (runcFci) {
    opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
        list(test=test, schedule=n-2, solver="pcalg-cfci", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=0))
    opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
        list(test=test, schedule=n-2, solver="pcalg-cfci", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=repeat_bootstrap))
    if (runOracle && test != "oracle") {
      opt_list_all[[length(opt_list_all)+1]] <- c(opt_list_template, 
        list(test="oracle", schedule=n-2, solver="pcalg-cfci", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=0))
    }
  }
  
  if (runBnlearn) {
    opt_list <- c(opt_list_template, list(test=test, schedule=n-2, solver="bnlearn", multipleMinima=FALSE, encode="no-encoding", repeat_bootstrap=repeat_bootstrap))
    opt_list_all[[length(opt_list_all)+1]] <- opt_list
  }
  
  #for(i in 1:howmany) {
  foreach(i=1:howmany) %dopar% {
    currentDir <- file.path(tmpDir, i)
    dir.create(currentDir, showWarnings = FALSE, recursive = TRUE)
    
    sink(file.path(currentDir, "run_log.txt"), append=TRUE)
    timesFile <- file(file.path(currentDir, "time.txt"), "a")
    
    # Compare on the same true model.
    set.seed(i + seed_offset)
    simulationConfig <- list(n=n, topology=topology, exconf=exconf, N=N, pedge = pedge, restrict = restrict, confounder_proportion=confounder_proportion)
    MD <- simulate_data(simulationConfig=simulationConfig, samples=NULL, model=NULL, indPath=NULL, returnData=TRUE) 
    M <- MD$M
    save(MD, file=file.path(currentDir, "true.Rdata"))
        
    for (opt_1 in opt_list_all){    
        # Fix seed to have same sample data for all algorithms.
        set.seed(i + seed_offset)
        o <- c(opt_1, list(model=M, samples=MD$D$data, tmpDir=currentDir))
        filename_template <- filename_template_name(o)
        RdataFile <- file.path(currentDir, paste(filename_template, '.Rdata',sep=''))
        if (!file.exists(RdataFile)) {
          # Name of the variable where the learnt model will be stored.
          nameC <- short_template_name(o$test, o$encode, o$solver, o$multipleMinima, o$repeat_bootstrap, o$evalDirectCauses)
          assign(nameC, do.call(pipeline, o))
          save(list=nameC, file=RdataFile)
          evalDirectCauses_string <- if (is.null(o$evalDirectCauses)){"ancestral"} else {if (o$evalDirectCauses) {"direct"} else {"ancestral"}}
          solving_time_direct_string <- if (is.null(get(nameC)$solving_time_direct)){"0"} else {get(nameC)$solving_time_direct}
          
          cat("\n", n, "&", i, "&", schedule, "&", o$test, " & ", o$multipleMinima, "& ", o$encode, " & ", o$solver, " & ",
              o$repeat_bootstrap, "&", get(nameC)$solving_time, "&", get(nameC)$testing_time,  
              "&", evalDirectCauses_string, "&", solving_time_direct_string, "&", get(nameC)$timeout, file=timesFile)  
        } else {
          if (runComparison) {
            load(file=RdataFile)
          }
        }
    }
    close(timesFile)

    if (runComparison) {
      ACIname <- short_template_name(test, encodingACI, "clingo", "iterative", 0)
      HEJname <- short_template_name(test, encodingHEJ, "clingo", "iterative", 0)
      FCIname <- short_template_name(test, "no-encoding", "pcalg-fci", FALSE, repeat_bootstrap)
      CFCIname <- short_template_name(test, "no-encoding", "pcalg-cfci", FALSE, repeat_bootstrap)
      
      if (runACIRules & runIterOpt) {  
        logFile <- file(paste(currentDir, "log_aci.txt", sep=""), "a")
        if (runFci) {
          compare(i, get(ACIname)$C, "iterOpt", encodingACI, get(FCIname)$C, "fci", "no-encoding", logFile)
        }
        if (runcFci) {
          compare(i, get(ACIname)$C, "iterOpt", encodingACI, get(CFCIname)$C, "cfci", "no-encoding", logFile)
        }
        close(logFile)
      }


      if (runHEJRules & runIterOpt) {  
        logFile <- file(paste(currentDir, "log_others.txt", sep=""), "a")
        if (runACIRules) 
          compare(i, get(ACIname)$C, "iterOpt", encodingACI, get(HEJname)$C, "iterOpt", encodingHEJ, logFile)
        if (runFci) {
          compare(i, get(HEJname)$C, "iterOpt", encodingHEJ, get(FCIname)$C, "fci", "no-encoding", logFile)
          compare(i, get(HEJname)$G, "iterOptG", encodingHEJ, get(FCIname)$G, "fciG", "no-encoding", logFile)
        }
        if (runcFci) {
          compare(i, get(HEJname)$C, "iterOpt", encodingHEJ, get(CFCIname)$C, "cfci", "no-encoding", logFile)
          compare(i, get(HEJname)$G, "iterOptG", encodingHEJ, get(CFCIname)$G, "cfciG", "no-encoding", logFile)
        }
        close(logFile)
      }
    }
    
    if (plotSingleRocCurves) {
      plotRocCurves(howmany=1, n=n, seed_offset=seed_offset + i-1, tmpDir=tmpDir, opt_list_all=opt_list_all)
    }
    sink()
  }
  
  if (plotRocCurve) {
    plotRocCurves(howmany=howmany, n=n, seed_offset=seed_offset, tmpDir=tmpDir, opt_list_all=opt_list_all)
  }

}

plotRocCurves <- function(howmany=1, n, seed_offset = 0, tmpDir = "../tmp/unitTest/", opt_list_all, plotSingleRocCurves=FALSE){
    true_models <- list(C=numeric(), G=numeric())
    learned <- list()
    learnedG <- list()
    learnedGprime <- list()
    
    for (i in 1:howmany) {  
      # Fix seed to have same sample data for all algorithms.
      set.seed(i + seed_offset)
      currentDir <- file.path(tmpDir, i)
      RdataFile <- file.path(currentDir, "true.Rdata")
      load(file=RdataFile)
      
      M <- MD$M
      trueC <- M$C
      trueC[which(trueC<0)] = 0
      trueG <- M$G
      trueG[which(trueG<0)] = 0
      true_models$C <- append(true_models$C, as.vector(trueC))
      true_models$G <- append(true_models$G, as.vector(trueG))
      
      for (opt1 in opt_list_all){    
        o <- c(opt1, list(model=M, samples=MD$D$data, tmpDir=currentDir))
        filename_template <- filename_template_name(o)
        RdataFile <- file.path(currentDir, paste(filename_template, '.Rdata',sep=''))
        load(file=RdataFile)
        
        # Name of the variable where the learnt model will be stored.
        nameC <- short_template_name(o$test, o$encode, o$solver, o$multipleMinima, o$repeat_bootstrap, o$evalDirectCauses)
        G <- as.vector(get(nameC)$G)
        C <- as.vector(get(nameC)$C)
        learned[[nameC]] <- append(learned[[nameC]], C)
        learnedG[[nameC]] <- append(learnedG[[nameC]], G)
        G[which(is.infinite(G))] <- C[which(is.infinite(G))]
        learnedGprime[[nameC]] <- append(learnedGprime[[nameC]], G)
      }
    }
    
    sink(file.path(tmpDir, "stats.txt"), append=TRUE)
    cat("\nNumber causes in true models:", length(which(true_models$C == 1)))
    cat("\nNumber not causes in true models:", length(which(true_models$C == 0)))
    sink()
    
    matlab <- TRUE
    if (matlab) {
      printMatlabStyleCurves(n=n, true_models=true_models$C, learned=learned, tmpDir=tmpDir, type="ancestral")
      printMatlabStyleCurves(n=n, true_models=true_models$G, learned=learnedG, tmpDir=tmpDir, type="direct")
      printMatlabStyleCurves(n=n, true_models=true_models$G, learned=learnedGprime, tmpDir=tmpDir, type="direct2")
    }
    printSingleRocCurve(unlist(learned), true_models$C, unlist(names(learned)), file.path(tmpDir, paste("rocCurve", seed_offset, "_", howmany, ".pdf", sep="")))
    printSingleRocCurve(unlist(learnedG), true_models$G, unlist(names(learnedG)), file.path(tmpDir, paste("rocCurve", seed_offset, "_", howmany, "_direct.pdf", sep="")))
    printSingleRocCurve(unlist(learnedGprime), true_models$G, unlist(names(learnedGprime)), file.path(tmpDir, paste("rocCurve", seed_offset, "_", howmany, "_direct2.pdf", sep="")))
}

compare <- function(i, C1, algC1, encoding1, C2, algC2, encoding2, logFile){
  # normalize positives to +1, negatives to -1
  if (!all(sign(C1) == sign(C2))) {
    cat("\nModels", i,  " with encodings: ", encoding1, ",", encoding2,"disagree among them.", file=logFile)
    cat("\n", algC1, ":", encoding1, "\n",file=logFile)
    write.table(C1, file=logFile, sep=" ")
    cat("\n", algC2, ":", encoding2, "\n",file=logFile)
    write.table(C2, file=logFile, sep=" ")
  }
}

printSingleRocCurve<- function(learned_model, true_model, header, pdf_name) {
  if (any(true_model) == 1){
    learnedMatrix <- matrix(learned_model, nrow=length(true_model))
    colnames(learnedMatrix) <- header
    pdf(pdf_name)
    AUC <- colAUC(learnedMatrix, true_model, plotROC=TRUE, alg=c("ROC"))
    dev.off()
    write.csv(x=AUC, file=paste(pdf_name, "_auc.csv", sep=""))
  }
}

printMatlabStyleCurves <- function(n, true_models, learned, tmpDir, type="ancestral") {
  matricesFile <- file.path(tmpDir, paste("matrices", "_", type,".txt", sep=""))
  matrices <- file(matricesFile, "w")
  cat("true = [", paste(true_models, collapse= " "), "];\n", "n = ", n, ";\n", file=matrices)
  for (i in 1:length(learned)) {
    if (translateNames(names(learned)[i]) =="aci_hej" || translateNames(names(learned)[i]) =="hej_direct") {
      cat(translateNames(names(learned)[i]), "= [", paste(learned[[i]], collapse=" "), "];\n", file=matrices)
    }
  }
  close(matrices)
  
  prPosFile <- file.path(tmpDir, paste("pr_pos", "_", type,".eps", sep=""))
  matlab_cmd <- paste("addpath('../experiments/plots/'); eval(fileread('", matricesFile, "')); hasASP=1; roc=0; pos=1; xlimit=[0,1]; ylimit=[0,1]; plotAllGraphs; saveas(f, '", prPosFile,"', 'epsc'); exit", sep="")
  cat(paste('. ~/.bashrc; matlab -r "', matlab_cmd,'"', sep=""))
  system(paste('. ~/.bashrc; matlab -r "', matlab_cmd,'"', sep=""))
  
  prPosFileZoom <- file.path(tmpDir, paste("pr_pos_zoom", "_", type,".eps", sep=""))
  matlab_cmd <- paste("addpath('../experiments/plots/');eval(fileread('", matricesFile, "')); hasASP=1; roc=0; pos=1; xlimit=[0,0.2]; ylimit=[0,1]; plotAllGraphs; saveas(f, '", prPosFileZoom,"', 'epsc'); exit", sep="")
  system(paste('. ~/.bashrc; matlab -r "', matlab_cmd,'"', sep=""))
  
  prPosFileZoomMore <- file.path(tmpDir, paste("pr_pos_zoom_more", "_", type,".eps", sep=""))
  matlab_cmd <- paste("addpath('../experiments/plots/');eval(fileread('", matricesFile, "')); hasASP=1; roc=0; pos=1; xlimit=[0,0.02]; ylimit=[0,1]; plotAllGraphs; saveas(f, '", prPosFileZoomMore,"', 'epsc'); exit", sep="")
  system(paste('. ~/.bashrc; matlab -r "', matlab_cmd,'"', sep=""))
  
  prNegFile <- file.path(tmpDir, paste("pr_neg", "_", type,".eps", sep=""))
  matlab_cmd <- paste("addpath('../experiments/plots/');eval(fileread('", matricesFile, "')); hasASP=1; roc=0; pos=0; xlimit=[0,1]; ylimit=[0,1]; plotAllGraphs; saveas(f, '", prNegFile,"', 'epsc'); exit", sep="")
  system(paste('. ~/.bashrc; matlab -r "', matlab_cmd,'"', sep=""))
  
  prNegFileZoom <- file.path(tmpDir, paste("pr_neg_zoom", "_", type,".eps", sep=""))
  matlab_cmd <- paste("addpath('../experiments/plots/');eval(fileread('", matricesFile, "')); hasASP=1; roc=0; pos=0; xlimit=[0,1]; ylimit=[0.8,1]; plotAllGraphs; saveas(f, '", prNegFileZoom,"', 'epsc'); exit", sep="")
  system(paste('. ~/.bashrc; matlab -r "', matlab_cmd,'"', sep=""))
}

translateNames<- function(alg_name) {
  if (alg_name == "v_logp_aci_1.pl_clingo_iterative_0_") {
    return ("aci")
  }
  
  if (alg_name == "v_logp_aci_1.pl_clingo_iterative_0_direct") {
    return ("aci_hej")
  }
  
  if (alg_name == "v_logp_hej_mod.pl_clingo_iterative_0_direct") {
    return ("hej_direct")
  }
  
  if (alg_name == "v_logp_aci_complete.pl_clingo_iterative_0_") {
    return ("aci_4")
  }
  if (alg_name == "v_oracle_aci_1.pl_clingo_iterative_0_") {
    return ("oracle_aci")
  }
  if (alg_name == "v_oracle_aci_complete.pl_clingo_iterative_0_") {
    return ("oracle_aci_4")
  }
  if (alg_name == "v_logp_hej_mod.pl_clingo_iterative_0_") {
    return ("hej")
  }
  
  if (alg_name == "v_oracle_hej_mod.pl_clingo_iterative_0_") {
    return ("oracle_hej")
  }
  if (alg_name == "v_logp_no-encoding_pcalg-fci__0_") {
    return ("vanilla_fci")
  }
  if (alg_name == "v_logp_no-encoding_pcalg-fci__10_") {
    return ("fci")
  }
  if (alg_name == "v_logp_no-encoding_pcalg-cfci__0_") {
    return ("vanilla_cfci")
  }
  if (alg_name == "v_logp_no-encoding_pcalg-cfci__10_") {
    return ("cfci")
  }
  return(gsub("-", "_", gsub("\\.", "_", alg_name)))
}