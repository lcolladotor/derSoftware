#!/bin/sh

## Based on 
# ../dertable/dertable.sh
#
## Most recently, based on:
# /dcs01/stanley/work/brain_rna/deranalysis/deranalysis.sh

# Directories
MAINDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware/simulation
WDIR=${MAINDIR}/deranalysis-original
DATADIR=${MAINDIR}/dertable

# Define variables
SHORT='derA-ori-sim'

# Construct shell files
#for chrnum in 22 21 Y 20 19 18 17 16 15 14 13 12 11 10 9 8 X 7 6 5 4 3 2 1
for chrnum in 22
do
    for group in AB AC BC
    do
    	echo "Creating script for chromosome ${chrnum} comparing groups $group"
    	chr="chr${chrnum}"
    	cat > ${WDIR}/.${SHORT}.${group}.${chr}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=100G,h_vmem=150G,h_fsize=50G
#$ -N ${SHORT}.${group}.${chr}

echo "**** Job starts ****"
date

# Create output directory 
mkdir -p ${WDIR}/${chr}
# Make logs directory
mkdir -p ${WDIR}/${chr}/logs

# Copy database to scratch disk
cp ${DATADIR}/${chr}/${chr}.db \${TMPDIR}/

# run derfinder-analysis.R
cd ${WDIR}/${chr}
module load R/2.15.x
Rscript ${WDIR}/derfinder-analysis.R -o "/dcs01/ajaffe/Brain/derRuns/derSoftware/simulation/dercount" -s "sample" -d "\${TMPDIR}/${chr}.db" -t ${chr} -c "${group}" -v TRUE

# Move log files into the logs directory
mv ${WDIR}/${SHORT}.${group}.${chr}.* ${WDIR}/${chr}/logs/

echo "**** Job ends ****"
date
EOF
    	call="qsub ${WDIR}/.${SHORT}.${group}.${chr}.sh"
    	echo $call
    	$call
    done
done
