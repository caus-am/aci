%%%% New iterative combined method, requires clingo compiled with python support.

#external extCauses(X,Y) : causes(X,Y).
#external extNotCauses(X,Y) : causes(X,Y).

:- extCauses(X,Y), not causes(X,Y).
:- extNotCauses(X,Y), causes(X,Y).

#script(python)
brave = set()
cautious = set()

def brave_model(model):
	global brave
	brave = set()
	for a in model.atoms():
		brave.add(str(a))

def cautious_model(model):
	global cautious
	cautious = set()
	for a in model.atoms():
		cautious.add(str(a))

from gringo import Fun
import json
def main(prg):
	prg.ground([("base", [])])
	n = prg.get_const("n")
	prg.solve()
	baseline_opt= int(prg.stats["costs"][0])
	
	prg.conf.solve.opt_mode="optN"
	prg.conf.solve.enum_mode="brave"
	prg.solve(None, brave_model)

	prg.conf.solve.opt_mode="optN"
	prg.conf.solve.enum_mode="cautious"
	prg.solve(None, cautious_model)

	positives = brave.intersection(cautious)
	unknowns = brave.difference(cautious)

	prg.conf.solve.opt_mode="opt"
	prg.conf.solve.enum_mode="auto"
	
	for i in range(1,n+1):
	  for j in range(1,n+1):
	  	if i != j:
	  		statement = "causes(" + str(i) + ","+ str(j)+ ")"
	  		if statement not in positives:
				prg.assign_external(Fun("extCauses", [i,j]), True)
				prg.solve()
				causes_opt= int(prg.stats["costs"][0])
				prg.release_external(Fun("extCauses", [i,j]))
			else:
				causes_opt= baseline_opt
			
			if (statement in positives or statement in unknowns) and causes_opt == baseline_opt:
				prg.assign_external(Fun("extNotCauses", [i,j]), True)
				prg.solve()
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