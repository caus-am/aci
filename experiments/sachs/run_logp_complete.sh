cd ../../R/;
Rscript -e "source('load.R');loud(30);pipeline(indPath='/tmp/sachs.indep', n=11, schedule=1, multipleMinima='iterativeParallel', test='logp', p=0.05, solver_conf='--quiet=2', outputClingo='/tmp/sachs.txt', encode='aci_1.pl', tmpDir='/tmp/')"
