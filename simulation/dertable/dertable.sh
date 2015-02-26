#!/bin/sh

## Based on 
# /amber2/scratch/jleek/orbFrontal/scripts/makeTHtable-all.R
# makeTHtable-all.R on derfinder GitHub repo
# /amber2/scratch/jleek/orbFrontal/scripts/makeTHtable-all.sh
# ../dercount/dercount.sh
#
## Most recently, based on:
# /dcs01/stanley/work/brain_rna/dertable/dertable.sh

# Directories
MAINDIR=/dcs01/ajaffe/Brain/derRuns/derSoftware/simulation
WDIR=${MAINDIR}/dertable
DATADIR=${MAINDIR}/dercount

# Define variables
SHORT='derT-sim'

# Construct shell files
#for chrnum in 22 21 Y 20 19 18 17 16 15 14 13 12 11 10 9 8 X 7 6 5 4 3 2 1
for chrnum in 22
do
	echo "Creating script for chromosome ${chrnum}"
	chr="chr${chrnum}"
	cat > ${WDIR}/.${SHORT}.${chr}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m e
#$ -l mem_free=40G,h_vmem=80G,h_fsize=50G
#$ -N ${SHORT}.${chr}

echo "**** Job starts ****"
date

# Create output directory 
mkdir -p ${WDIR}/${chr}
# Make logs directory
mkdir -p ${WDIR}/${chr}/logs

# Copy files to a scratch disk
TDIR=\${TMPDIR}/dercount
cd ${DATADIR}
for thout in sample*
do
	# Emulate the original file structure
	mkdir -p \${TDIR}/\${thout}
	
	# Specify file names
	orifile=${DATADIR}/\${thout}/${chr}-bybp
	newfile=\${TDIR}/\${thout}/${chr}-bybp
	
	# Actually do the copying
	echo "Copying \${orifile} to scratch disk \${newfile}"
	cp \${orifile} \${newfile}
done

# Create temp output directory
mkdir -p \${TMPDIR}/dertable

# Work on the temp output directory
cd \${TMPDIR}/dertable

# Create actual temp output
mkdir -p ${chr}

# run makeTableDB.R
module load R/2.15.x
Rscript --min-vsize=3G --min-nsize=10M ${WDIR}/makeTableDB.R -d \${TDIR} -s "sample" -f ${chr}-bybp -m ${chr}/${chr}.merged.txt -o ${chr}/${chr}.db -t ${chr} -v TRUE

# Copy files back to original disk
echo "Copying results back to ${WDIR}"
cp ${chr}/${chr}.merged.txt.gz ${WDIR}/${chr}/${chr}.merged.txt.gz
cp ${chr}/${chr}.db ${WDIR}/${chr}/${chr}.db

## Move log files into the logs directory
mv ${WDIR}/${SHORT}.${chr}.* ${WDIR}/${chr}/logs/

echo "**** Job ends ****"
date
EOF
	call="qsub ${WDIR}/.${SHORT}.${chr}.sh"
	echo $call
	$call
done
