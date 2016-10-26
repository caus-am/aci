write_independence_constraint <- function(test_result, write_data, file_connection, verbose=FALSE) {
  # Function for writing the independence constraints.
  # test_result - the result of the test see conductIndepTests.
  # write_data$weight - either "constant" or "log".
  # file_connection   - the connection to the file where to write to.
  # called by "pipeline.do_test()" function.
  x<-min(test_result$vars)
  y<-max(test_result$vars)

  #this is to make sure no jset is read from write_data
  write_data$jset<-NA
  
  if ( write_data$weight=="constant") {
    weight<-'1'
  } else if ( write_data$weight=="log" ) {
    weight<-format(round(1000*test_result$w),scientific=FALSE)
  }
  
  if (is.na(test_result$independent)) {
    cat('% UNKNOWN indep(',x,',',y,',',test_result$cset,',',
        test_result$jset,',',test_result$mset,',',
        weight,').\n', sep='', file = file_connection)
  } else {
    if ( test_result$independent ) { #writing the independence
      options(scipen = 999)
      cat('indep(',x,',',y,',',test_result$cset,',',
            test_result$jset,',',test_result$mset,',',
            weight,').', sep='', file = file_connection)
      options(scipen = 0)  
      cat('%p=',test_result$p,' w=',test_result$w, #' condset=',paste(test_result$C, collapse=","),
            '\n',sep='', file = file_connection)
    } else {
      options(scipen = 999)
      cat('dep(',x,',',y,',',test_result$cset,',',
          test_result$jset,',',test_result$mset,',',
          weight,').', sep='', file = file_connection)
      options(scipen = 0)
      cat('%p=',test_result$p,' w=',test_result$w, #' condset=',paste(test_result$C, collapse=","), 
          '\n',sep='', file = file_connection)
      
    }
  }
}

write_independence_constraint.human_readable <- function(independent, x, y, C, J, weight, p, file_connection) {
  weight <- format(round(1000*weight),scientific=FALSE)
  if (is.na(independent)) {
    cat('% UNKNOWN indep(',x,', ',y,', {',paste(C, collapse=","),'}, {',paste(J, collapse=","),'}).',
        '%p=',p,' w=',weight,
        '\n',sep='', file = file_connection)
  } else {
    if (independent ) { #writing the independence
      cat('indep(',x,', ',y,', {',paste(C, collapse=","),'}, {',paste(J, collapse=","),'}).',
          '%p=',p,' w=',weight,
          '\n',sep='', file = file_connection)
    } else {
      cat('dep(',x,', ',y,', {',paste(C, collapse=","),'}, {',paste(J, collapse=","),'}).',
          '%p=',p,' w=',weight, #' condset=',, 
          '\n',sep='', file = file_connection)
    }
  }
}