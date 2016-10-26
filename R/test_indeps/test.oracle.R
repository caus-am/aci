test.oracle<-function(vars,C,test_data) {
  # Function that returns the oracle independence result by checking what is reachable in the true model.
  #
  # Inputs:
  # vars: variables used to test the independence
  # C: conditining set as a list of variable indexes
  # test_data: data for the test:  
  #             test_data$M: true model
  # Outputs:
  # test_result
  #            test_result$vars sorted variables (standard ass. in the rest of the code)
  #            test_result$C conditioning set
  #            test_result$independent TRUE or FALSE
  #            test_results$p p-value of test
  #            test_results$w weight of the in/dependence
  
  test_result<-list()
  test_result$vars<-sort(vars)
  test_result$C<-C
  
  reachable<-directed_reachable(vars[1],vars[2],C,J=c(),test_data$M)
  
  # Independence is the negation of reachable
  test_result$independent<- !reachable
  
  # Probability of independence is 1 or 0
  test_result$p<-1*test_result$independent
  test_result$w<-1
  test_result
}