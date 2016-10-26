%%%% Iterative method, requires clingo compiled with python support.

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
	prg.solve()
	baseline_opt= int(prg.stats["costs"][0])
	for i in range(1,n+1):
	  for j in range(1,n+1):
	  	if i != j:
			prg.assign_external(Fun("extCauses", [i,j]), True)
			s = prg.solve()			
			if s == SolveResult.UNSAT :
				causes_opt = 1000000000000
			else:
				causes_opt= int(prg.stats["costs"][0])
			prg.release_external(Fun("extCauses", [i,j]))
			if causes_opt == baseline_opt:
				prg.assign_external(Fun("extNotCauses", [i,j]), True)
				s = prg.solve()
				if s == SolveResult.UNSAT :
					notcauses_opt= 1000000000000
				else:
					notcauses_opt= int(prg.stats["costs"][0])
				prg.release_external(Fun("extNotCauses", [i,j]))
			else:
				notcauses_opt= baseline_opt
			score = notcauses_opt-causes_opt
			if (score > 0): 
				print('causes('+str(i) + ',' + str(j)+ ')= ' + str(score))
			else:
				print('-causes('+str(i) + ',' + str(j)+ ')= ' + str(-score))
		else:
			print('-causes('+str(i) + ',' + str(j)+ ')= 1000000000000')
#end.