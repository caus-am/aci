# Timer, modified implementation without global vars.

tic <- function() {
  proc.time()[3]
}

toc <- function(start_time) {
  proc.time()[3] - start_time
}