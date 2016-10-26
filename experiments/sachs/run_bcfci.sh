cd ../../R/;
Rscript -e "schedule=1; source('load.R');loud(30); samples <- read.csv('../experiments/sachs/data/sachs.csv', sep = '\t'); obs_samples <- samples[which(samples[['experiment']]==1), 1:11]; obs_samples<- log(obs_samples); pipeline(repeat_bootstrap=100, samples=obs_samples, test='logp', p=0.05, n=11, schedule=schedule, solver='pcalg-cfci', outputClingo='/tmp/sachs.txt', tmpDir='/tmp/')"
