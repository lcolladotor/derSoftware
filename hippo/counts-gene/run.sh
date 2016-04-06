#!/bin/bash	
#$ -cwd
#$ -m e
#$ -l mem_free=3G,h_vmem=15G,h_fsize=30G
#$ -pe local 24
#$ -N summOv-hippo-rerun

echo "**** Job starts ****"
date

mkdir -p /dcl01/lieber/ajaffe/derRuns/derSoftware/hippo/counts-gene/logs

## Summarize overlaps
module load R/3.1.x
Rscript counts-gene.R

# Move log files into the logs directory
mv /dcl01/lieber/ajaffe/derRuns/derSoftware/hippo/counts-gene/summOv-hippo-rerun.* /dcl01/lieber/ajaffe/derRuns/derSoftware/hippo/counts-gene/logs/

### Done
echo "**** Job ends ****"
date
