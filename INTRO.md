ACI Introduction
================

Discovering causal relations from data is at the foundation of the scientific method. 
Traditionally, cause-effect relations have been recovered from experimental data in which the variable of interest is perturbed, 
but seminal work like the do-calculus and the PC/FCI algorithms demonstrate that, under certain assumptions, 
it is already possible to obtain significant causal information by using only observational data. 


Recently, there have been several proposals for combining observational and experimental data to discover causal relations. 
These causal discovery methods are usually divided into two categories: constraint-based and score-based methods. 
Score-based methods typically evaluate models using a penalized likelihood score, while constraint-based methods 
use statistical independences to express constraints over possible causal models. 
The advantages of constraint-based over score-based methods are the ability to handle latent confounders naturally, 
no need for parametric modeling assumptions and an easy integration of complex background knowledge, 
especially in the logic-based methods.


Two major disadvantages of constraint-based methods are: 
- vulnerability to errors in statistical independence test results, which are quite common in real-world applications,
- no ranking or estimation of the confidence in the causal predictions. Several approaches address the first issue and improve the reliability of constraint-based methods by exploiting redundancy in the independence information. Unfortunately, existing approaches have to choose to sacrifice either accuracy by using a greedy method, or scalability by formulating a discrete optimization problem on a super-exponentially large search space. 
Additionally, the second issue is addressed only in limited cases.


We propose Ancestral Causal Inference (ACI), a logic-based method that provides a comparable accuracy to the 
best state-of-the-art constraint-based methods, but improves on their scalability by using a more coarse-grained representation of 
causal information, which, though still super-exponentially large, drastically reduces computation time. 
Instead of representing all possible direct causal relations, in ACI we represent and reason only with ancestral relations 
(“indirect” causal relations). This representation turns out to be very convenient, because in real-world applications the 
distinction between direct causal relations and ancestral relations is not always clear or necessary. 
Moreover, once we reconstruct ancestral relations, we can always refine the prediction to direct causal relations by constraining 
standard methods to a much smaller search space.


Furthermore, we propose a method to score predictions according to their confidence. The confidence score is an approximation of 
the marginal probability of an ancestral relation. Scoring predictions enables one to rank them according to their reliability. 
This is very important for practical applications, as the low reliability of the predictions of constraint-based methods has been 
a major impediment to their widespread usage. 


We provide some theoretical guarantees for ACI, like soundness and asymptotic consistency, and demonstrate that it can outperform 
the state-of-the-art on synthetic data, achieving a speedup of several orders of magnitude. 
We illustrate its practical feasibility by applying it on a challenging protein data set that so far had only been addressed with 
score-based methods.
