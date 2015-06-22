#!/bin/sh

# Directories
MAINDIR=/dcl01/lieber/ajaffe/PublicData/SRA_GTEX
WDIR=${MAINDIR}/tophat
DATADIR=/dcl01/lieber/ajaffe/PublicData/SRA_GTEX/FASTQ

# Define variables
P=4
TRANSINDEX=/amber2/scratch/jleek/iGenomes-index/Homo_sapiens/UCSC/hg19/Annotation/Transcriptome/known
GENOMEINDEX=/amber2/scratch/jleek/iGenomes-index/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome

mkdir -p ${WDIR}
mkdir -p ${WDIR}/logs

# Construct shell files
cat paired.txt | while read x
	do
	cd ${WDIR}
	libname=$(echo "$x" | cut -f3)
	# Setting paired file names
	file1=$(echo "$x" | cut -f1)
	file2=$(echo "$x" | cut -f2)
	# Actually create the script
	echo "Creating script for ${libname}"
    sname="${libname}.tophat"
	cat > ${WDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=3G,h_vmem=15G,h_fsize=30G
#$ -pe local ${P}
#$ -N ${sname}
echo "**** Job starts ****"
date

cd ${WDIR}


# run tophat
module load tophat/2.0.13
tophat -p ${P} --transcriptome-index=${TRANSINDEX} -o ${libname} ${GENOMEINDEX} ${DATADIR}/${file1} ${DATADIR}/${file2}

echo "**** Creating BAM file index ****"
date

## load samtools
module load samtools/1.1

cd ${libname}
samtools index accepted_hits.bam

mv ${WDIR}/${sname}.* ${WDIR}/logs/


echo "**** Job ends ****"
date
EOF
	call="qsub ${WDIR}/.${sname}.sh"
	echo $call
	$call
done
