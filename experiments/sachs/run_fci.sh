cd ../../R/;
Rscript -e "source('load.R');loud(1); pipeline(indPath='/tmp/sachs.indep', test='logp', p=0.05, n=11, schedule=1, solver='pcalg-fci', outputClingo='/tmp/sachs.txt', tmpDir='/tmp/')"
