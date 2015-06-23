#!/bin/sh

## Usage
# sh optional3-summOv.sh stem
# sh optional3-summOv.sh snyder
# sh optional3-summOv.sh hippo

# Define variables
EXPERIMENT=$1
SHORT="summOv-${EXPERIMENT}"

# Directories
ROOTDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/summOv

if [[ "${EXPERIMENT}" == "stem" ]]
then
    CORES=10
    DATADIR=/dcs01/ajaffe/UCSC_Epigenome/RNAseq/TopHat
elif [[ "${EXPERIMENT}" == "snyder" ]]
then
    CORES=10
    DATADIR=/dcs01/ajaffe/Snyder/RNAseq/TopHat
elif [[ "${EXPERIMENT}" == "hippo" ]]
then
    CORES=24
    DATADIR=/dcs01/ajaffe/Hippo/TopHat
else
    echo "Specify a valid experiment: stem, snyder, or hippo"
fi


# Construct shell files
sname="${SHORT}"
echo "Creating script ${sname}"
cat > ${ROOTDIR}/.${sname}.sh <<EOF
#!/bin/bash	
#$ -cwd
#$ -m e
#$ -l mem_free=3G,h_vmem=15G,h_fsize=30G
#$ -pe local ${CORES}
#$ -N ${sname}

echo "**** Job starts ****"
date

mkdir -p ${WDIR}/logs

## Summarize overlaps
module load R/3.2
Rscript -e "datadir <- '$DATADIR'; cores <- '$CORES'; source('optional3-summOv.R')"

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/logs/

### Done
echo "**** Job ends ****"
date
EOF

call="qsub .${sname}.sh"
echo $call
$call
