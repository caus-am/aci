%%%% Enumerate and sum weights of all possible worlds.
%%%% Computes the exact marginal probability.

#script(python)
from gringo import Fun
import json, math

costs = dict()

def on_model(model):
	opt_i = int(model.optimization()[0])
	opt = math.exp(-float(opt_i)/1000.0)
	global costs
	costs["total"] = costs["total"] + opt
	#print "total:", costs["total"], opt, costs["total"] + opt
	#if len(model.atoms()) == 0:
	#	costs["emptycauses"] = costs["emptycauses"]  + opt
	for x in model.atoms():
		s = str(x)
		if "causes" in s:
			#print s, ":", costs[s], opt, costs[s] + opt
			costs[s] = costs[s] + opt

def main(prg):
	prg.ground([("base", [])])
	global costs

	for x in prg.domains.by_signature("causes", 2):
		costs[str(x.atom)] = 0
	costs["total"] = 0
	#costs["emptycauses"] = 0
	
	prg.conf.solve.opt_mode="enum"
	prg.conf.solve.models="0"
	prg.solve(None, on_model)

	for c in costs.keys():
		if "causes" in c:
			score = float(costs[c])/costs["total"]
			score -= 0.5
			if score > 0: 
				print(c + '= ' + str(score))
			else:
				print('-' + c + '= ' + str(-score))

	print prg.stats
#end.

