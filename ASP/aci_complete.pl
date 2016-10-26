%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Ancestral Causal Inference (ACI)    %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Preliminaries:

%%% Define ancestral structures:
{ causes(X,Y) } :- node(X), node(Y), X!=Y.
:- causes(X,Y), causes(Y,X), node(X), node(Y), X < Y.
:- not causes(X,Z), causes(X,Y), causes(Y,Z), node(X), node(Y), node(Z).

%%% Define the extension of causes to sets.
% existsCauses(Z,W) means there exists I \in W that is caused by Z.
1{causes(Z, I): ismember(W,I)} :- existsCauses(Z,W), node(Z), set(W), not ismember(W,Z).
existsCauses(Z,W) :- causes(Z, I), ismember(W,I), node(I), node(Z), set(W), not ismember(W,Z), Z!=I.

%%% Generate in/dependences in each model based on the input in/dependences.
1{ dep(X,Y,Z); indep(X,Y,Z) }1 :- node(X), node(Y), set(Z), X!=Y, not ismember(Z,X), not ismember(Z,Y).

%%% To simplify the rules, add symmetry of in/dependences.
:- indep(X,Y,Z), dep(Y,X,Z).

%%%%% Rules from LoCI:

%%% Minimal independence rule (4) : X || Y | W u [Z] => Z -/-> X, Z -/-> Y, Z -/-> W
:- not causes(Z,X), not causes(Z,Y), not existsCauses(Z,W), dep(X,Y,W), indep(X,Y,U), U==W+2**(Z-1), set(W), node(Z), not ismember(W, Z), Y != Z, X != Z.

%%% Minimal dependence rule (5): X |/| Y | W u [Z] => Z --> X or Z-->Y or Z-->W 
:- causes(Z,X), indep(X,Y,W), dep(X,Y,U), U==W+2**(Z-1), set(W), set(U), node(X), node(Y), node(Z), not ismember(W, Z), not ismember(W, X), not ismember(W,Y), X != Y, Y != Z, X != Z.
% Note: the version with causes(Z,Y) is implied by the symmetry of in/dependences.
:- existsCauses(Z,W), indep(X,Y,W), dep(X,Y,U), U==W+2**(Z-1), set(W), set(U), node(X), node(Y), node(Z), not ismember(W, Z), not ismember(W, X), not ismember(W,Y), X != Y, Y != Z, X != Z.

%%%%% ACI rules:

%%% Rule 1: X || Y | U and X -/-> U => X -/->Y
:- causes(X,Y), indep(X,Y,U), not existsCauses(X,U), node(X), node(Y), set(U), X != Y, not ismember(U,X), not ismember(U,Y).

%%% Rule 2: X || Y | W u [Z] => X |/| Z | W 
:- indep(X,Z,W), indep(X,Y,W), dep(X,Y,U), U==W+2**(Z-1), set(W), set(U), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z, not ismember(W,X), not ismember(W,Y), not ismember(W,Z).

%%% Rule 3: X |/| Y | W u [Z] => X |/| Z | W
:- indep(X,Z,W), dep(X,Y,W), indep(X,Y,U), U==W+2**(Z-1), set(W), set(U), node(X), node(Y), node(Z), X != Y, Y != Z, X != Z, not ismember(W,X), not ismember(W,Y), not ismember(W,Z).

%%% Rule 4: X || Y | W u [Z] and X || Z | W u U => X || Y | W u U
:- dep(X,Y, WuU), dep(X,Y,WuZ), indep(X,Y,WuU), WuU==W+2**(U-1), WuZ==W+2**(Z-1), set(WuZ), set(WuU), set(W), not ismember(W,X), not ismember(W,Y), not ismember(W,Z), not ismember(W,U), node(X), node(Y), node(Z), node(U), X!=U, Y!=U, Z!=U, X != Y, Y != Z, X != Z.

%%% Rule 5: Z |/| X | W and Z |/| Y | W and X || Y | W => X |/| Y | W u Z
:- indep(X,Y,U), dep(Z,X,W), dep(Z,Y,W), indep(X,Y,W), node(X), node(Y), node(Z), U==W+2**(Z-1), set(W), set(U), X != Y, Y != Z, X != Z, not ismember(W,X), not ismember(W,Y), not ismember(W,Z).

%%% Rule 6: X |/| Y | Z and X |/| U |Z and Y || U | Z  => X -/-> Y.
:- dep(X,Y,Z), dep(X,U,Z), indep(Y,U,Z), causes(X,Y), node(X), node(Y), node(U), set(Z), not ismember(Z,X), not ismember(Z,Y), not ismember(Z,U),  X != Y, U != X, U != Y.


%%%%% Loss function and optimization.

%%% Trick to avoid "satisfiable" as answer.
fail(0,0,0,0). 

%%% Define the loss function as the incongruence between the input in/dependences and the in/dependences of the model.
fail(X,Y,Z,W) :- dep(X,Y,Z), indep(X,Y,Z,_,_,W).
fail(X,Y,Z,W) :- indep(X,Y,Z), dep(X,Y,Z,_,_,W).

%%% Include the weighted ancestral relations in the loss function.
fail(X,Y,-1,W) :- causes(X,Y), wnotcauses(X,Y,W), node(X), node(Y), X != Y.
fail(X,Y,-1,W) :- not causes(X,Y), wcauses(X,Y,W), node(X), node(Y), X != Y.

%%% Optimization part: minimize the sum of W of all fail predicates that are true.
#minimize{W,X,Y,C:fail(X,Y,C,W) }.

#show .
#show causes/2.

