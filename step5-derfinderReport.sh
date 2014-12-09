#!/bin/sh

## Usage
# sh step5-derfinderReport.sh brainspan run4-v1.0.10
# sh step5-derfinderReport.sh stem run4-v1.0.10
# sh step5-derfinderReport.sh snyder run3-v1.0.10
# sh step5-derfinderReport.sh hippo run3-v1.0.10
# sh step5-derfinderReport.sh simulation run2-v1.0.10

# Define variables
EXPERIMENT=$1
SHORT="derR-${EXPERIMENT}"
PREFIX=$2

# Directories
ROOTDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/derAnalysis


# Construct shell files
outdir="${PREFIX}"
sname="${SHORT}.${PREFIX}"
echo "Creating script ${sname}"
cat > ${ROOTDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=150G,h_vmem=250G,h_fsize=20G
#$ -N ${sname}
#$ -hold_jid derM-${EXPERIMENT}.${PREFIX}

echo "**** Job starts ****"
date

mkdir -p ${WDIR}/${outdir}/logs

# merge results
cd ${WDIR}
module load R/3.1.x
Rscript -e "library(regionReport); load('${MAINDIR}/CoverageInfo/fullCov.Rdata'); derfinderReport(prefix='${PREFIX}', browse=FALSE, nBestRegions = ifelse('${EXPERIMENT}' == 'simulation', 469, 100),  nBestClusters=ifelse('${EXPERIMENT}' == 'simulation', 66, 20), fullCov=fullCov, device='CairoPNG'); Sys.time(); proc.time(); options(width = 90); devtools::session_info()"

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/${outdir}/logs/

echo "**** Job ends ****"
date
EOF
call="qsub .${sname}.sh"
echo $call
$call
