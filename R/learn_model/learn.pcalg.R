learn.pcalg.available_solvers <- c("pcalg-fci", "pcalg-cfci")

learn.pcalg <- function(solverConfig, filename_template, currentDir = "./../tmp/",
                        indPath = NULL, bckg_file = NULL, verbose=1) {
  
  # Function for running fci and similar algorithms from pcalg.
  # - solver: "pcalg-fci","pcalg-cfci"
  # - alpha: threshold for independence on p-value
  # - n: number of vars
  # - tested_independences: tested_independences from previous steps
  
  # FCI performs the independence tests incrementally, but we want to reuse the independence
  # tests we already performed in the previous phase.
  # So we simulate this approach by providing a dummy test that just reuses the old results.
  schedule <- solverConfig$schedule
  p <- solverConfig$p
  n <- solverConfig$n
  
  indepTest <- test.fake
  suffStat <- list(tested_independences=solverConfig$tested_independences)
  
  if (any(schedule < (n-2))) {
    # Sometimes works, sometimes doesn't...
    type <- "anytime"
    if (length(schedule)>1)
      m.max <- as.integer(schedule[2])
    else 
      m.max <- as.integer(schedule[1])
  } else {
    type <- "normal"
    m.max <- Inf
  }
  
  #skel <- pcalg::skeleton(suffStat, indepTest, alpha=alpha, labels = as.character(seq_len(n)), fixedGaps = NULL, fixedEdges = NULL, 
  #                 NAdelete = TRUE, m.max = schedule, verbose = TRUE)
  
  solving_time <- tic()
  if (solverConfig$solver=="pcalg-fci") {  
    fci.fit <- fci_mod2(suffStat, indepTest, type=type, p=n, alpha=p, verbose = verbose, m.max=m.max, pdsep.max=m.max)
  } else if (solverConfig$solver == "pcalg-cfci") {
    fci.fit <- fci_mod2(suffStat, indepTest, type=type, p=n, alpha=p, verbose = verbose, conservative=c(TRUE), m.max=m.max, pdsep.max=m.max)
    if (is.null(fci.fit)) {
      return (list(solving_time=Inf))      
    }
  }
  
  G <- fci.fit@amat
  G <- t(G)
  
  # The edge marks are encoded by numbers: 0 = no edge, 1 = circle, 2 = arrowhead, 3 = tail.
  L <- cpag_to_mc(G)
  L$fci_fit <- fci.fit
  
  # Scale it to make it more comparable to the other algorithms.
  L$C <- 1000 * L$C
  
  L$solving_time <- toc(solving_time)    
  L$objective <- NA
  
  L
}
