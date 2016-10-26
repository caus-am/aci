load results_icam_NEW

WoutFCI = 10000*WoutFCI;
plot_one_sachs(WoutFCI,cmap,'FCI (independences <= 1)',D,labels, 10000);
print('NEW_icam_FCI','-dpdf', '-r0')

WoutCFCI = 10 * WoutCFCI;
plot_one_sachs(WoutCFCI,cmap,'CFCI (independences <= 1)',D,labels, 10000);
print('NEW_icam_CFCI','-dpdf', '-r0')

WoutBFCI = 1000*WoutBFCI;
plot_one_sachs(WoutBFCI,cmap,'BFCI (independences <= 1)',D,labels, 10000);
print('NEW_icam_BFCI','-dpdf', '-r0')

WoutBCFCI = 1000*WoutBCFCI;
plot_one_sachs(WoutBCFCI,cmap,'BCFCI (independences <= 1)',D,labels, 10000);
print('NEW_icam_BCFCI','-dpdf', '-r0')

plot_one_sachs(Wcauses,cmap,'Ancestral relations',D,labels, 10000);
print('NEW_icam_causes','-dpdf', '-r0')

plot_one_sachs(Windep,cmap,'Independences (order 0)',D,labels, 10000);
print('NEW_icam_indep0','-dpdf', '-r0')

plot_one_sachs(WoutA01,cmap,'ACI (independences <= 1)',D,labels, 10000);
print('NEW_icam_aci_indep','-dpdf', '-r0')

plot_one_sachs(WoutA10,cmap,'ACI (ancestral relations)',D,labels, 10000);
print('NEW_icam_aci_causes','-dpdf', '-r0')

plot_one_sachs(WoutA11,cmap,'ACI (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_icam_aci','-dpdf', '-r0')

plot_one_sachs(WoutD11,cmap,'ACI + HEJ (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_icam_aci_direct','-dpdf', '-r0')

plot_one_sachs(WoutAlt,cmap,'ACI (alt) (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_icam_aci_alt','-dpdf', '-r0')

WoutFCI_icam = WoutFCI
WoutCFCI_icam = WoutCFCI
WoutBFCI_icam =  WoutBFCI
WoutBCFCI_icam = WoutBCFCI
Wcauses_icam = Wcauses
Windep_icam = Windep
WoutA01_icam = WoutA01
WoutA10_icam = WoutA10
WoutA11_icam = WoutA11
WoutD11_icam = WoutD11
WoutAlt_icam = WoutAlt

load results_noicam_NEW

WoutFCI = 10000*WoutFCI;
plot_one_sachs(WoutFCI,cmap,'FCI (independences <= 1)',D,labels, 10000);
print('NEW_noicam_FCI','-dpdf', '-r0')

WoutCFCI = 10 * WoutCFCI;
plot_one_sachs(WoutCFCI,cmap,'CFCI (independences <= 1)',D,labels, 10000);
print('NEW_noicam_CFCI','-dpdf', '-r0')

WoutBFCI = 1000*WoutBFCI;
plot_one_sachs(WoutBFCI,cmap,'BFCI (independences <= 1)',D,labels, 10000);
print('NEW_noicam_BFCI','-dpdf', '-r0')

WoutBCFCI = 1000*WoutBCFCI;
plot_one_sachs(WoutBCFCI,cmap,'BCFCI (independences <= 1)',D,labels, 10000);
print('NEW_noicam_BCFCI','-dpdf', '-r0')

plot_one_sachs(Wcauses,cmap,'Ancestral relations',D,labels, 10000);
print('NEW_noicam_causes','-dpdf', '-r0')

plot_one_sachs(Windep,cmap,'Independences (order 0)',D,labels, 10000);
print('NEW_noicam_indep0','-dpdf', '-r0')

plot_one_sachs(WoutA01,cmap,'ACI (independences <= 1)',D,labels, 10000);
print('NEW_noicam_aci_indep','-dpdf', '-r0')

plot_one_sachs(WoutA10,cmap,'ACI (ancestral relations)',D,labels, 10000);
print('NEW_noicam_aci_causes','-dpdf', '-r0')

plot_one_sachs(WoutA11,cmap,'ACI (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_noicam_aci','-dpdf', '-r0')

plot_one_sachs(WoutD11,cmap,'ACI + HEJ (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_noicam_aci_direct','-dpdf', '-r0')

plot_one_sachs(WoutAlt,cmap,'ACI (alt) (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_noicam_aci_alt','-dpdf', '-r0')

WoutFCI_all = WoutFCI + WoutFCI_icam
WoutCFCI_all = WoutCFCI + WoutCFCI_icam
WoutBFCI_all =  WoutBFCI + WoutBFCI_icam
WoutBCFCI_all = WoutBCFCI + WoutBCFCI_icam
Wcauses_all = Wcauses + Wcauses_icam
Windep_all = Windep + Windep_icam
WoutA01_all = WoutA01 + WoutA01_icam
WoutA10_all = WoutA10 + WoutA10_icam
WoutA11_all = WoutA11 + WoutA11_icam
WoutD11_all = WoutD11 + WoutD11_icam
WoutAlt_all = WoutAlt + WoutAlt_icam

plot_one_sachs(WoutFCI_all,cmap,'FCI (independences <= 1)',D,labels, 10000);
print('NEW_all_FCI','-dpdf', '-r0')

plot_one_sachs(WoutCFCI_all,cmap,'CFCI (independences <= 1)',D,labels, 10000);
print('NEW_all_CFCI','-dpdf', '-r0')

plot_one_sachs(WoutBFCI_all,cmap,'BFCI (independences <= 1)',D,labels, 10000);
print('NEW_all_BFCI','-dpdf', '-r0')

plot_one_sachs(WoutBCFCI_all,cmap,'BCFCI (independences <= 1)',D,labels, 10000);
print('NEW_all_BCFCI','-dpdf', '-r0')

plot_one_sachs(Wcauses_all,cmap,'Ancestral relations',D,labels, 10000);
print('NEW_all_causes','-dpdf', '-r0')

plot_one_sachs(Windep_all,cmap,'Independences (order 0)',D,labels, 10000);
print('NEW_all_indep0','-dpdf', '-r0')

plot_one_sachs(WoutA01_all,cmap,'ACI (independences <= 1)',D,labels, 10000);
print('NEW_all_aci_indep','-dpdf', '-r0')

plot_one_sachs(WoutA10_all,cmap,'ACI (ancestral relations)',D,labels, 10000);
print('NEW_all_aci_causes','-dpdf', '-r0')

plot_one_sachs(WoutA11_all,cmap,'ACI (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_all_aci','-dpdf', '-r0')

plot_one_sachs(WoutD11_all,cmap,'ACI + HEJ (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_all_aci_direct','-dpdf', '-r0')

plot_one_sachs(WoutAlt_all,cmap,'ACI (alt) (ancestral r. + indep. <= 1)',D,labels, 10000);
print('NEW_all_aci_alt','-dpdf', '-r0')

[value,index]=sort(WoutA11_all(:));
WoutA11_top17_all = WoutA11_all >=  value(121-16)
plot_one_sachs(WoutA11_top17_all,cmap,'ACI (top 17 all) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_all_aci_17','-dpdf', '-r0')

[value,index]=sort(WoutA11_all(:));
WoutA11_top21_all = WoutA11_all >=  value(121-20)
plot_one_sachs(WoutA11_top21_all,cmap,'ACI (top 21 all) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_all_aci_21','-dpdf', '-r0')

[value,index]=sort(WoutD11_all(:));
WoutD11_top17_all = WoutD11_all >=  value(121-16)
plot_one_sachs(WoutD11_top17_all,cmap,'ACI + HEJ (top 17 all) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_all_aci_direct_17','-dpdf', '-r0')


% praf", "pmek","plcg","PIP2","PIP3","p44.42","pakts473","PKA","PKC","P38","pjnk
Wacyclic17_mooij = [  
0    1    0    0    0    0    0    0    1     0     0;
0    0    0    0    0    0    0    1    1     0     0;
0    0    0    1    0    0    0    0    1     0     0;
0    0    0    0    1    0    0    0    1     0     0;
0    0    0    0    0    0    0    0    0     0     0;
0    1    0    0    0    0    1    0    0     0     0;
0    0    0    0    0    0    0    1    1     0     0;
0    0    0    0    0    0    0    0    1     0     0;
0    0    0    0    0    0    0    0    0     0     0;
0    0    0    0    0    0    0    1    1     0     0;
0    0    0    0    0    0    0    1    1     0     0]

Wacyclic17_mooij = Wacyclic17_mooij'
plot_one_sachs(Wacyclic17_mooij,cmap,'MooijHeskes13 (top 17 acyclic) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_Wacyclic17_mooij','-dpdf', '-r0')

% praf", "pmek","plcg","PIP2","PIP3","p44.42","pakts473","PKA","PKC","P38","pjnk
Wacyclic17_transitive_mooij = [  
0    1    0    0    0    0    0    1    1     0     0;
0    0    0    0    0    0    0    1    1     0     0;
0    0    0    1    1    0    0    0    1     0     0;
0    0    0    0    1    0    0    0    1     0     0;
0    0    0    0    0    0    0    0    0     0     0;
0    1    0    0    0    0    1    1    1     0     0;
0    0    0    0    0    0    0    1    1     0     0;
0    0    0    0    0    0    0    0    1     0     0;
0    0    0    0    0    0    0    0    0     0     0;
0    0    0    0    0    0    0    1    1     0     0;
0    0    0    0    0    0    0    1    1     0     0]

Wacyclic17_transitive_mooij = Wacyclic17_transitive_mooij'
plot_one_sachs(Wacyclic17_transitive_mooij,cmap,'MooijHeskes13 (top 17 acyclic, transitive closure) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_Wacyclic17_transitive_mooij','-dpdf', '-r0')

[value,index]=sort(WoutA11(:));
WoutA11_top17_noicam = WoutA11 >=  value(121-16)
plot_one_sachs(WoutA11_top17_noicam,cmap,'ACI (top 17 all) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_noicam_aci_17','-dpdf', '-r0')

[value,index]=sort(WoutA11(:));
WoutA11_top21_noicam = WoutA11 >=  value(121-20)
plot_one_sachs(WoutA11_top21_noicam,cmap,'ACI (top 21 all) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_noicam_aci_21','-dpdf', '-r0')

[value,index]=sort(WoutD11(:));
WoutD11_top17_noicam = WoutD11 >=  value(121-16)
plot_one_sachs(WoutD11_top17_noicam,cmap,'ACI + HEJ (top 17 all) (ancestral r. + indep. <= 1)',D,labels, 1);
print('NEW_noicam_aci_direct_17','-dpdf', '-r0')


plot_one_sachs(A,cmap,'ACI (top 21 all) - MooijHeskes13 transitive',D,labels, 1);
print('NEW_aci_diff','-dpdf', '-r0')