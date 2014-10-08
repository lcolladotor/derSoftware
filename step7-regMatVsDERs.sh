## Usage
# sh step7-regMatVsDERs.sh brainspan run1-v0.99.6
# sh step7-regMatVsDERs.sh stem run1-v0.99.6

# Define variables
EXPERIMENT=$1
PREFIX=$2
SHORT="regMat-${EXPERIMENT}"
ncore=5
cores="${ncore}cores"

# Directories
ROOTDIR=/dcs01/lieber/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/regionMatrix-vs-DERs

# Construct shell files
sname="${SHORT}"
echo "Creating script ${sname}"

cat > ${WDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=200G,h_vmem=400G,h_fsize=30G
#$ -N ${sname}
#$ -hold_jid regMat-${EXPERIMENT},derM-${EXPERIMENT}.${PREFIX}
echo "**** Job starts ****"
date

# Make logs directory
mkdir -p ${WDIR}/logs

# Compare DERs vs regionMatrix
cd ${WDIR}
module load R/3.1.x
Rscript -e "library(rmarkdown); library(knitrBootstrap); render('${ROOTDIR}/step7-regMatVsDERs.Rmd', output_file='${WDIR}/step7-regMatVsDERs.html')"

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/logs/

echo "**** Job ends ****"
date
EOF

call="qsub .${sname}.sh"
echo $call
$call
