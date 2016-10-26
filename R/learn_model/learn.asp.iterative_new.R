learn.asp.iterative_new <- function(clingoCmd, clingoInputFiles, n, filename_template,
                       currentDir = "./../tmp/", p,
                       verbose=1){
  M<-list()
  M$G<-array(0, c(n,n))
  M$Ge<-array(0, c(n,n))
  M$C<-array(0, c(n,n))
  
  baselineClingoCmd <- gsub("--quiet=1", "--outf=3", clingoCmd)
  if (grepl("time-limit", baselineClingoCmd)){
    baselineClingoCmd <- gsub("time-limit", "const timeout", baselineClingoCmd)
  } else {
    baselineClingoCmd <- paste(baselineClingoCmd, "--const timeout=-1")
  }
  baselineClingoCmd <- paste(baselineClingoCmd, " ", clingoInputFiles, "./../ASP/iterative.pl |grep causes")
  cat(baselineClingoCmd)
  optResult <- system(baselineClingoCmd, intern = TRUE)
  M <- parse_single_solution(M, optResult) 
  diag(M$C) <- -Inf
  diag(M$G) <- -Inf
  
  list(C=M$C, G=M$G, Ge=M$Ge, Gs=array(0, c(n,n)), objective=0, timeout=FALSE)
}