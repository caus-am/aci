writeAspSets <- function(n, aspSetsFullPath, tested_independences) {
  # Writes down the set definitions for the older encoding.
  # Predicates and "cset", "jset" and "ismember".
  aspSetsFile <- file(aspSetsFullPath, "w")
  
  cat('node(1..', n, ').\n', sep='', file = aspSetsFile)
  # Only write the necessary sets..
  jset_written <- rep(FALSE, 2^n) 
  cset_written <- rep(FALSE, 2^n)
  
  for ( indep in tested_independences ) {
    if ( !cset_written[indep$cset+1] ) {
      # Writing cset only when it is needed
      cat('cset(',indep$cset,'). ',sep='', file = aspSetsFile)
      for ( el in indep$C) {
        cat('ismember(',indep$cset,',',el,'). ',sep='', file = aspSetsFile)        
      }
      cat('\n', file = aspSetsFile)
      cset_written[indep$cset+1]<-TRUE
    }
    
    if ( !jset_written[indep$jset+1] ) {
      cat('jset(',indep$jset,'). ',sep='', file = aspSetsFile)      
      for ( el in indep$J) {
        cat('ismember(',indep$jset,',',el,'). ',sep='', file = aspSetsFile)       
      }
      cat('\n', file = aspSetsFile)
      jset_written[indep$jset+1]<-TRUE      
    }
    
  }#for indep
  cat('\n', file = aspSetsFile)
  close(aspSetsFile)
}

writeAspSets.aci <- function(n, aspSetsFullPath){
  # Writes down the nodes.
  aspSetsFile <- file(aspSetsFullPath, "a")
  # Only write the necessary sets..
  cset_written <- rep(FALSE, 2^n)
  
  for ( cset in index(0,2^n-1) ) {
    if ( !cset_written[cset+1] ) {
      # Writing cset only when it is needed
      cat('\n', file = aspSetsFile)
      cat('set(', cset,'). ',sep='', file = aspSetsFile)
      cset_written[cset+1]<-TRUE
      if (cset == 0){
        cat('\n', file = aspSetsFile)
        next
      }
      csetbin<-rev(dec.to.bin(cset,n))
      C <- which(csetbin ==1)
      for ( el in C) {
        cat('ismember(',cset,',',el,'). ',sep='', file = aspSetsFile)        
      }
    }
    
  }#for indep
  cat('\n', file = aspSetsFile)
  
  close(aspSetsFile)
}

writeAspSets.nodes <- function(n, aspSetsFullPath) {
  aspSetsFile <- file(aspSetsFullPath, "w")
  cat('node(1..', n, ').\n',sep='', file = aspSetsFile)
  close(aspSetsFile)
}

