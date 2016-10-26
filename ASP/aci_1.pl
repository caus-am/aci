%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Ancestral Causal Inference (ACI)   %%%%%
%%%%%  Specialized version for order <=1  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Preliminaries:

%%% Define ancestral structures:
{ causes(X,Y) } :- node(X), node(Y), X!=Y.
:- causes(X,Y), causes(Y,X), node(X), node(Y), X < Y.
:- not causes(X,Z), causes(X,Y), causes(Y,Z), node(X), node(Y), node(Z).

%%% Generate in/dependences in each model.
1{ dep(X,Y);indep(X,Y) }1 :- node(X), node(Y), X!=Y.
1{ dep(X,Y,Z);indep(X,Y,Z) }1 :- node(X), node(Y), node(Z), X!=Y, Y!=Z, X!=Z.

%%% To simplify the rules, add symmetry of in/dependences.
indep(X,Y) :- indep(Y,X), node(X), node(Y), X != Y.
indep(X,Y,Z) :- indep(Y,X,Z), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%%%% Rules from LoCI:
  
%%% Minimal independence rule (4) : X || Y |[Z] => Z -/-> X, Z -/-> Y
:- not causes(Z,Y), not causes(Z,X), dep(X,Y), indep(X,Y,Z), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%% Minimal dependence rule (5): X |/| Y | [Z] => Z --> X or Z-->Y
:- causes(Z,X), indep(X,Y), dep(X,Y,Z), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%%%% ACI rules:

%%% Rule 1: X || Y | Z and X -/-> Z => X -/->Y
:- causes(X,Y), indep(X,Y), node(X), node(Y), X != Y.
:- causes(X,Y), indep(X,Y,Z), dep(X,Y), not causes(X,Z), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%% Rule 2: X || Y | [Z] => X |/| Z 
dep(X,Z) :- dep(X,Y), indep(X,Y,Z), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%% Rule 3: X |/| Y | [Z] => X |/| Z
dep(X,Z) :- indep(X,Y), dep(X,Y,Z), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%% Rule 4: X || Y | [Z] and X || Z | U => X || Y | U
indep(X,Y,U) :- dep(X,Y), indep(X,Y,Z), indep(X,Z,U), node(X), node(Y), node(Z), node(U), X != Y, Y != Z, X != Z, U != X, U != Y, U != Z.

%%% Rule 5: Z |/| X  and Z |/| Y  and X || Y  => X |/| Y | Z
dep(X,Y,Z) :- dep(Z,X), dep(Z,Y), indep(X,Y), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z.

%%% Rule 6: X |/| Y | Z and X |/| U |Z and Y || U | Z  => X -/-> Y.
:- dep(X,Y,Z), dep(X,U,Z), indep(Y,U,Z), causes(X,Y), node(X), node(Y), node(Z), node(U), X != Y, Y != Z, X != Z, U != X, U != Y, U != Z.

%%%%% Loss function and optimization.

%%% Trick to avoid "satisfiable" as answer.
fail(0,0,0,0). 

%%% Define the loss function as the incongruence between the input in/dependences and the in/dependences of the model.
fail(X,Y,0,W) :- dep(X,Y), indep(X,Y,0,J,M,W), node(X), node(Y), X != Y.
fail(X,Y,0,W) :- indep(X,Y), dep(X,Y,0,J,M,W), node(X), node(Y), X != Y.
fail(X,Y,Z,W) :- dep(X,Y,Z), indep(X,Y,C,J,M,W) , node(X), node(Y), node(Z), X != Y, X != Z, Y != Z, C==2**(Z-1).
fail(X,Y,Z,W) :- indep(X,Y,Z), dep(X,Y,C,J,M,W), node(X), node(Y), node(Z), X != Y, X != Z, Y != Z, C==2**(Z-1).

%%% Include the weighted ancestral relations in the loss function.
fail(X,Y,-1,W) :- causes(X,Y), wnotcauses(X,Y,W), node(X), node(Y), X != Y.
fail(X,Y,-1,W) :- not causes(X,Y), wcauses(X,Y,W), node(X), node(Y), X != Y.

%%% Optimization part: minimize the sum of W of all fail predicates that are true.
#minimize{W,X,Y,C:fail(X,Y,C,W) }.

#show .
#show causes/2.
