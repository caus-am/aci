Ancestral Causal Inference (ACI): 
=====================================================
Ancestral Causal Inference (ACI) is a logic-based causal discovered algorithm for causal systems with latent confounders and no feedback.
ACI is described in an upcoming NIPS 2016 publication:

*Sara Magliacane, Tom Claassen, Joris M. Mooij:
"Ancestral Causal Inference", NIPS 2016*.

Also available at: <a href="arxiv.org/abs/1606.07035">arxiv.org/abs/1606.07035</a>

ACI uses the Answer Set Programming solver clingo 4, also available at <a href="https://github.com/potassco/clingo"> https://github.com/potassco/clingo </a>

Practical information
---------------------
Installation instructions can be found in the INSTALL file.

The repository is organized as follows:
- The ASP folder contains various Answer Set Programming encodings of causal discovery algorithms.
- The R folder contains most of the code (surprisingly, in R).
- The experiments folder contains various Matlab code that we used to plot the evaluation graphs, or run the experiments on the Sachs2005 dataset.

Acknowledgements
-------------------------------------
The code of ACI builds heavily on the code from the following publication:

*Antti Hyttinen, Frederick Eberhardt, Matti Järvisalo:
"Constraint-Based Causal Discovery: Conflict Resolution with Answer Set Programming", UAI 2014.*

In the NIPS 2016 paper we refer to this implementation as HEJ (from the surnames of the authors).
The original code of HEJ is available at: <a href=" https://sites.google.com/site/ajhyttin/publications">https://sites.google.com/site/ajhyttin/publications</a>
