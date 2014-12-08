#!/bin/bash
#$ -cwd
#$ -m e
#$ -N makeBai-Sim
#$ -hold_jid sample*th

module load samtools/1.1
for i in sample*; do echo $i; cd $i; pwd; samtools index accepted_hits.bam ; cd ..; done
