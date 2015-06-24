#!/bin/sh

## Usage
# sh step6-regionMatrix.sh brainspan
# sh step6-regionMatrix.sh stem
# sh step6-regionMatrix.sh snyder
# sh step6-regionMatrix.sh hippo
# sh step6-regionMatrix.sh simulation

# Define variables
EXPERIMENT=$1
SHORT="regMat-${EXPERIMENT}"
ncore=5
cores="${ncore}cores"

# Directories
ROOTDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/regionMatrix

if [[ "${EXPERIMENT}" == "stem" ]]
then
    CUTOFF=5
    RLENGTH=101
elif [[ "${EXPERIMENT}" == "brainspan" ]]
then
    CUTOFF=0.1
    RLENGTH=100
elif [[ "${EXPERIMENT}" == "snyder" ]]
then
    CUTOFF=5
    RLENGTH=101
elif [[ "${EXPERIMENT}" == "hippo" ]]
then
    CUTOFF=3
    RLENGTH=36
elif [[ "${EXPERIMENT}" == "simulation" ]]
then
    CUTOFF=5
    RLENGTH=100
else
    echo "Specify a valid experiment: stem, brainspan, snyder, hippo or simulation"
fi


# Construct shell files
sname="${SHORT}"
echo "Creating script ${sname}"

cat > ${ROOTDIR}/.${sname}.sh <<EOF
#!/bin/bash	
#$ -cwd
#$ -m e
#$ -l mem_free=50G,h_vmem=100G,h_fsize=30G
#$ -N ${sname}
#$ -pe local ${ncore}
#$ -hold_jid fullCov-${EXPERIMENT}

echo "**** Job starts ****"
date

# Make logs directory
mkdir -p ${WDIR}/logs

# Load coverage & get region matrix
cd ${WDIR}
module load R/3.2.x
R -e "library(derfinder); message(Sys.time()); timeinfo <- NULL; timeinfo <- c(timeinfo, list(Sys.time())); load('${MAINDIR}/CoverageInfo/fullCov.Rdata'); timeinfo <- c(timeinfo, list(Sys.time())); proc.time(); message(Sys.time()); if('${EXPERIMENT}' == 'simulation') fullCov <- fullCov[c(22)]; regionMat <- regionMatrix(fullCov, maxClusterGap = 3000L, L = ${RLENGTH}, mc.cores = ${ncore}, cutoff = ${CUTOFF}, returnBP = FALSE); timeinfo <- c(timeinfo, list(Sys.time())); save(regionMat, file='regionMat-cut${CUTOFF}.Rdata'); timeinfo <- c(timeinfo, list(Sys.time())); save(timeinfo, file='timeinfo-${cores}.Rdata'); proc.time(); message(Sys.time()); options(width = 90); devtools::session_info()"

## Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/logs/

echo "**** Job ends ****"
date
EOF

call="qsub .${sname}.sh"
echo $call
$call
