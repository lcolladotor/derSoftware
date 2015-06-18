#!/bin/sh

# Directories
MAINDIR=/dcl01/lieber/ajaffe/PublicData/SRA_GTEX
WDIR=${MAINDIR}/alignments
DATADIR=/dcl01/lieber/ajaffe/PublicData/SRA_GTEX/FASTQ

# Define variables
P=4
INDEX=/dcs01/ajaffe/Annotation/hg19_hisat/hg19_hisat

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
    sname="${libname}.hisat"
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

## load samtools
module load samtools/1.1

## run hisat
hisat --version
hisat -x ${INDEX} -1 ${DATADIR}/${file1} -2 ${DATADIR}/${file2} --time -p ${P} -S ${libname}.sam

echo "**** Starting BAM file creation ****"
date
samtools view -bS ${libname}.sam > ${libname}-unsorted.bam

echo "**** Starting BAM file sorting ****"
date
samtools sort ${libname}-unsorted.bam  ${libname}

echo "**** Creating BAM file index ****"
date
samtools index ${libname}.bam

mv ${WDIR}/${sname}.* ${WDIR}/logs/


echo "**** Job ends ****"
date
EOF
	call="qsub ${WDIR}/.${sname}.sh"
	echo $call
	$call
done
