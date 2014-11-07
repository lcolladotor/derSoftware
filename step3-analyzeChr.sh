#!/bin/sh

## Usage
# sh step3-analyzeChr.sh brainspan run3-v1.0.6
# sh step3-analyzeChr.sh stem run1-v1.1.2

# Define variables
EXPERIMENT=$1
SHORT="derA-${EXPERIMENT}"
PREFIX=$2

# Directories
ROOTDIR=/dcs01/lieber/ajaffe/Brain/derRuns/derSoftware
MAINDIR=${ROOTDIR}/${EXPERIMENT}
WDIR=${MAINDIR}/derAnalysis
DATADIR=${MAINDIR}/CoverageInfo

# Construct shell files
for chrnum in 22 21 Y 20 19 18 17 16 15 14 13 12 11 10 9 8 X 7 6 5 4 3 2 1
do
	echo "Creating script for chromosome ${chrnum}"
    
    if [[ ${EXPERIMENT} == "stem" ]]
    then
        CORES=8
    else        
        if [[ ${chrnum} == "Y" ]]
        then
        	CORES=2
        elif [[ ${chrnum} == "1" ]]
        then
            CORES=40
        elif [[ ${chrnum} == "2" ]]
        then
            CORES=32
        elif [[ ${chrnum} == "3" ]]
        then
            CORES=27
        elif [[ ${chrnum} == "19" ]]
        then
            CORES=29
        else
        	CORES=20
        fi
    fi
    
	chr="chr${chrnum}"
	outdir="${PREFIX}/${chr}"
	sname="${SHORT}.${PREFIX}.${chr}"
	cat > ${ROOTDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=2G,h_vmem=10G,h_fsize=10G,h=!compute-04[3-5]*
#$ -N ${sname}
#$ -pe local ${CORES}
#$ -hold_jid derMod-${EXPERIMENT}.${PREFIX}

echo "**** Job starts ****"
date

# Create output directory 
mkdir -p ${WDIR}/${outdir}
# Make logs directory
mkdir -p ${WDIR}/${outdir}/logs

# run analyzeChr()
cd ${WDIR}/${PREFIX}/
module load R/3.1.x
Rscript ${ROOTDIR}/step3-analyzeChr.R -d "${DATADIR}/${chr}CovInfo.Rdata" -c "${chrnum}" -m ${CORES} -e "${EXPERIMENT}"

# Move log files into the logs directory
mv ${ROOTDIR}/${sname}.* ${WDIR}/${outdir}/logs/

echo "**** Job ends ****"
date
EOF
	call="qsub .${sname}.sh"
#	$call
done
