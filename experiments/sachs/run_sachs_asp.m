datafile='data/sachs.csv'
%expsfile='exps/safe_choice.exps'   
%expsfile ='exps/safe_choice_icam.exps'
expsfile='exps/safe_choice_more.exps'
%expsfile='exps/safe_choice_icam_more.exps'

takeLog=1
init_sachs

%% Consensus network:
% Transitive closure including all cycles.
% praf", "pmek","plcg","PIP2","PIP3","p44.42","pakts473","PKA","PKC","P38","pjnk
Wground = [0 0 1 1 1 0 1 1 1 0 0; 
1 0 1 1 1 0 1 1 1 0 0; 
0 0 0 1 1 0 0 0 0 0 0; 
0 0 1 0 1 0 0 0 0 0 0;
0 0 1 1 0 0 0 0 0 0 0; 
1 1 1 1 1 0 1 1 1 0 0; 
0 0 1 1 1 0 0 1 0 0 0; 
0 0 0 0 0 0 0 0 0 0 0; 
0 0 1 1 1 0 0 0 0 0 0; 
0 0 1 1 1 0 0 1 1 0 0; 
0 0 1 1 1 0 0 1 1 0 0]

Wground = Wground*2000 - 1000
Wground= Wground'

[Wcauses, Windep] = sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',1,1,0);

%% ASP:
setenv( 'LD_LIBRARY_PATH', strcat( '/usr/lib64/:', getenv( 'LD_LIBRARY_PATH' ) ) )

run_asp = './run_logp_complete.sh'
run_direct = './run_aci_direct.sh'

sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',0,1,1);
system('./run_fci.sh');
WoutFCI = parse_sachs_asp('/tmp/sachs.txt',D);
system('./run_cfci.sh');
WoutCFCI = parse_sachs_asp('/tmp/sachs.txt',D);
WoutCFCI = 1000 * WoutCFCI;

system('./run_bfci.sh');
WoutBFCI = parse_sachs_asp('/tmp/sachs.txt',D);
system('./run_bcfci.sh');
WoutBCFCI = parse_sachs_asp('/tmp/sachs.txt',D);

% first, only weighted causes as inputs from interventional data
sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',1,0,0);
system(run_asp);
WoutA10 = parse_sachs_asp('/tmp/sachs.txt',D);

% only independences
sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',0,1,1);
system(run_asp);
WoutA01 = parse_sachs_asp('/tmp/sachs.txt',D);

tic()
% independences + weighted causes
sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',1,1,1);
system(run_asp);
WoutA11 = parse_sachs_asp('/tmp/sachs.txt',D);
toc()

tic()
% independences + weighted causes
sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',1,1,1);
system(run_direct);
WoutD11 = parse_sachs_asp('/tmp/sachs.txt',D);
toc()

% Alternative version of ACI
tic()
sachs_asp(X,N,exps,labels,0.05,0.05,0.05,'/tmp/sachs.indep',1,0,0);
system('./run_aci.sh');
WoutAlt = parse_sachs_asp('/tmp/sachs.txt',D);
toc()

% visualize results as causal heat maps
cmap = colormap();
for i=1:32
  cmap(i,:) = [255-(i-1)*240/31, 0, 0] / 255;
end
for i=33:64
  cmap(i,:) = [0, 255-(64-i)*240/31, 0] / 255;
end
cmap(33,:) = [0,0,0];


figure; 
plot_sachs_asp(1,3,3,Wcauses,cmap,'Ancestral relations',D,labels, 1000);
plot_sachs_asp(2,3,3,Windep,cmap,'Independences (order 0)',D,labels, 1000);
%plot_sachs_asp(3,3,3,Wground,cmap,'Consensus graph',D,labels, 1000); 

plot_sachs_asp(4,3,3, WoutA01,cmap,'ACI (independences <= 1)',D,labels, 1000);
plot_sachs_asp(5,3,3, WoutA10,cmap,'ACI (ancestral relations)',D,labels, 1000);
plot_sachs_asp(6,3,3,WoutA11,cmap,'ACI (ancestral r. + indep. <= 1)',D,labels, 1000);

plot_sachs_asp(7,3,3,WoutFCI,cmap,'FCI (independences <= 1)',D,labels, 1000);
plot_sachs_asp(8,3,3,WoutCFCI,cmap,'CFCI (independences <= 1)',D,labels, 1000);
plot_sachs_asp(9,3,3,WoutD11,cmap,'ACI direct (ancestral r. + indep. <= 1)',D,labels, 1000);

print('figure_noicam','-depsc')

save results_noicam.mat