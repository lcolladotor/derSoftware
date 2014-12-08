#!/bin/bash
#$ -cwd
#$ -m e
#$ -N bigwig

module load R/3.1.x
Rscript -e "library('derfinder'); load('../CoverageInfo/fullCov.Rdata); createBw(fullCov, keepGR = FALSE); proc.time(); devtools::session_info()"
