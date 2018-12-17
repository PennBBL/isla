# submit the Extrapolate script with qsub

for i in /data/jux/BBL/projects/isla/results/Reproducibility/*/*/*/*/reproduced/ ; do 
	
	Rscript /data/jux/BBL/projects/isla/code/ReproduceExtrapolate.R $i;
done
