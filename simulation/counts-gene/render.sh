#!/bin/bash	
#$ -cwd
#$ -m e
#$ -l mem_free=5G,h_vmem=10G
#$ -N summOv-simulation
echo "**** Job starts ****"
date

# Generate HTML
Rscript -e "rmarkdown::render('counts-gene.Rmd')"

echo "**** Job ends ****"
date
