## Usage
# sh step9-summaryInfo.sh brainspan run4-v1.0.10
# sh step9-summaryInfo.sh stem run4-v1.0.10
# sh step9-summaryInfo.sh snyder run3-v1.0.10
# sh step9-summaryInfo.sh hippo run3-v1.0.10
# sh step9-summaryInfo.sh simulation run2-v1.0.10

# Define variables
EXPERIMENT=$1
PREFIX=$2
SHORT="summInfo-${EXPERIMENT}"

# Directories
ROOTDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}

# Construct shell files
sname="${SHORT}.${PREFIX}"
echo "Creating script ${sname}"

if [[ "${EXPERIMENT}" == "stem" ]]
then
    EXAMPLES='c("potentially new alternative transcript" = 1, "coverage dips" = 4, "and a long region matching DERs with known exons" = 5)'
elif [[ "${EXPERIMENT}" == "brainspan" ]]
    EXAMPLES='c("the complexity induced by alternative transcription" = 5, "coverage dips" = 16, "and coverage variability even on long single exon regions" = 18)'
then
    EXAMPLES=''
elif [[ "${EXPERIMENT}" == "snyder" ]]
then
    EXAMPLES='c("coverage dips" = 1, "alternative splicing" = 7, "and less pronounced coverage dips" = 13)'
elif [[ "${EXPERIMENT}" == "hippo" ]]
then
    EXAMPLES='c("a coverage dip" = 3, "the complex relationship with annotation" = 4, "and a potentially extended UTR" = 8)'
elif [[ "${EXPERIMENT}" == "simulation" ]]
then
    EXAMPLES='c("a two transcript gene with both differentially expressed" = 1, "a candidate DER overlapping exons from both strand" = 13, "a two transcript gene with only one differentially expressed" = 32)'
else
    echo "Specify a valid experiment: stem, brainspan, snyder, hippo or simulation"
fi

WDIR=${MAINDIR}/summaryInfo/${PREFIX}

cat > ${ROOTDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=50G,h_vmem=200G,h_fsize=10G
#$ -N ${sname}
#$ -hold_jid derM-${EXPERIMENT}.${PREFIX}
echo "**** Job starts ****"
date

# Make logs directory
mkdir -p ${WDIR}/logs

# Compare DERs vs regionMatrix
cd ${WDIR}
module load R/3.1.x
Rscript ${ROOTDIR}/step9-summaryInfo.R -s '${EXPERIMENT}' -r '${PREFIX}' -p '${EXAMPLES}' -v TRUE

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/logs/

echo "**** Job ends ****"
date
EOF

call="qsub .${sname}.sh"
echo $call
$call
