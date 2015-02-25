#!/bin/sh

## Based on a combination of
# /amber2/scratch/jleek/orbFrontal/scripts/tophatCount.sh
# /amber2/scratch/jleek/orbFrontal/scripts/count_all15.sh
#
## Most recently, based on:
# /dcs01/stanley/work/brain_rna/dercount/dercount.sh

# Directories
MAINDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware/simulation
WDIR=${MAINDIR}/dercount
DATADIR=${MAINDIR}/thout

# A clone of https://github.com/alyssafrazee/derfinder
# More specifically from https://github.com/lcolladotor/derfinder-original
SDIR=/dcs01/ajaffe/Brain/derRuns/derfinder-original

# Define variables
SHORT='derC-sim'

# Construct shell files
cd ${DATADIR}
for thout in sample*
do
	cd ${WDIR}
	#for chrnum in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y
    for chrnum in 22
	do
        chr="chr${chrnum}"
		echo "Creating script for sample ${thout} and chromosome ${chr}"
		cat > ${WDIR}/.${thout}.${SHORT}.${chr}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=30G,h_vmem=40G,h_fsize=20G
#$ -N ${thout}.${SHORT}.${chr}

echo "**** Job starts ****"
date

# Get the md5sum of the script I'm using
md5sum ${SDIR}/countReads.py

# Create output directory 
mkdir -p ${WDIR}/${thout}
# Make logs directory
mkdir -p ${WDIR}/${thout}/logs

# run countTophatReads.py
module load python/2.7.6
python ${SDIR}/countReads.py --file ${DATADIR}/${thout}/accepted_hits.bam --output ${WDIR}/${thout}/${chr}-bybp --kmer 100 --chrom ${chr}

## Print the version of pysam used
python -c "import pysam; print pysam.__version__"

## Move log files into the logs directory
mv ${thout}.${SHORT}.${chr}.* ${WDIR}/${thout}/logs/

echo "**** Job ends ****"
date
EOF
		call="qsub ${WDIR}/.${thout}.${SHORT}.${chr}.sh"
		echo $call
		$call
	done
done
