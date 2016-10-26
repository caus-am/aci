%%%% Iterative parallel method, requires clingo compiled with python support.

#external extCauses(X,Y) : causes(X,Y).
#external extNotCauses(X,Y) : causes(X,Y).

:- extCauses(X,Y), not causes(X,Y).
:- extNotCauses(X,Y), causes(X,Y).

#script(python)
from gringo import Fun, SolveResult
import json
def main(prg):
	prg.ground([("base", [])])
	n = prg.get_const("n")
	timeout = prg.get_const("timeout")
	baseline_future = prg.solve_async()
	future_causes =  dict()
	future_notcauses =  dict()

	for i in range(1,n+1):
	  for j in range(1,n+1):
	  	if i != j:
			prg.assign_external(Fun("extCauses", [i,j]), True)
			causes_future = prg.solve_async()
			future_causes[(i,j)] = causes_future
			prg.release_external(Fun("extCauses", [i,j]))
			
			prg.assign_external(Fun("extNotCauses", [i,j]), True)
			notcauses_future = prg.solve_async()
			future_notcauses[(i,j)] = notcauses_future
		
	baseline_future.wait(timeout)
	baseline_opt= int(prg.stats["costs"][0])
	for i in range(1,n+1):
	  for j in range(1,n+1):
	  	if i != j:
	  		future_causes[(i,j)].wait(timeout)
			if future_causes[(i,j)].get() == SolveResult.UNSAT :
				causes_opt = 1000000000000
			else:
				causes_opt= int(prg.stats["costs"][0])
			
			if causes_opt == baseline_future.get():
				future_notcauses[(i,j)].wait(timeout)
				if future_notcauses[(i,j)].get() == SolveResult.UNSAT :
					notcauses_opt= 1000000000000
				else:
					notcauses_opt= int(prg.stats["costs"][0])
				prg.release_external(Fun("extNotCauses", [i,j]))
			else:
				notcauses_opt = baseline_opt

			score = notcauses_opt-causes_opt

			if (score > 0): 
				print('causes('+str(i) + ',' + str(j)+ ')= ' + str(score))
			else:
				print('-causes('+str(i) + ',' + str(j)+ ')= ' + str(-score))
		else:
			print('-causes('+str(i) + ',' + str(j)+ ')= 1000000000000')
#end.