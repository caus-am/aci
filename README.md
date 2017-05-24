Ancestral Causal Inference (ACI): 
=====================================================
Ancestral Causal Inference (ACI) is a logic-based causal discovered algorithm for causal systems with latent confounders and no feedback.
You can find a short introduction <a href="https://github.com/caus-am/aci/blob/master/INTRO.md"> here </a>.

ACI is described in more detail in the NIPS 2016 publication:
<pre>
@InProceedings{ACI,
  author =    {Sara Magliacane and Tom Claassen and Joris M. Mooij},
  title =     {Ancestral Causal Inference},
  Booktitle = {{A}dvances in {N}eural {I}nformation {P}rocessing {S}ystems 27 ({NIPS}-16)},
	Pages = {4466--4474},
  year =      {2016},
}
</pre>

Also available at: <a href="http://arxiv.org/abs/1606.07035">arxiv.org/abs/1606.07035</a>

ACI uses the Answer Set Programming solver clingo 4, also available at <a href="https://github.com/potassco/clingo"> https://github.com/potassco/clingo </a>

Practical information
---------------------
Installation instructions can be found in the <a href="https://github.com/caus-am/aci/blob/master/INSTALL"> INSTALL </a> file.

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
