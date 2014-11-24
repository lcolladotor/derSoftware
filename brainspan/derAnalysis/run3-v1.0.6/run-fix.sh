#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=50G,h_vmem=200G,h_fsize=40G,h=!compute-04[3-5]*
#$ -N fix-brainspan-run3-v1.0.6

echo "**** Job starts ****"
date

# Make logs directory
mkdir -p logs

# Fix results
module load R/3.1.x
Rscript fix-results.R

# Move log files into the logs directory
mv fix-brainspan-run3-v1.0.6.* logs/

echo "**** Job ends ****"
date
