#!/bin/sh

## Usage
# sh optional1-sortSam.sh stem
# sh optional1-sortSam.sh snyder
# sh optional1-sortSam.sh hippo

# Define variables
EXPERIMENT=$1
SHORT="sortSam-${EXPERIMENT}"

# Directories
ROOTDIR=/dcs01/lieber/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/sortSam

if [[ "${EXPERIMENT}" == "stem" ]]
then
    SAMFILES='/dcs01/lieber/ajaffe/UCSC_Epigenome/RNAseq/TopHat/*out/accepted_hits.bam'
elif [[ "${EXPERIMENT}" == "snyder" ]]
then
    SAMFILES='/dcs01/lieber/ajaffe/Snyder/RNAseq/TopHat/*out/accepted_hits.bam'
elif [[ "${EXPERIMENT}" == "hippo" ]]
then
    SAMFILES='/dcs01/lieber/ajaffe/Hippo/TopHat/*out/accepted_hits.bam'
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
#$ -l mem_free=100G,h_vmem=200G,h_fsize=100G

echo "**** Job starts ****"
date

# Make logs directory
mkdir -p ${WDIR}/logs

## Transform BAM files to SAM files
for file in ${SAMFILES}
do 
	echo ${file}
	samtools sort -n $file ${file/.bam/_sorted}
	samtools view -h ${file/.bam/_sorted.bam} > ${file/.bam/_sorted.sam}
done

## Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/logs/

echo "**** Job ends ****"
date
EOF

call="qsub .${sname}.sh"
echo $call
$call
