#!/bin/sh

## Usage
# sh run-all.sh brainspan run1-v0.99.6
# sh run-all.sh stem run1-v0.99.6

## Skip fulLCov but run regionMatrix:
# sh run-all.sh brainspan run1-v0.99.6 TRUE FALSE

# Define variables
EXPERIMENT=$1
PREFIX=$2
SKIP1=${3-"FALSE"}
SKIP6=${4-"FALSE"}

mkdir -p ${EXPERIMENT}/CoverageInfo
mkdir -p ${EXPERIMENT}/derAnalysis
mkdir -p ${EXPERIMENT}/regionMatrix
mkdir -p ${EXPERIMENT}/regionMatrix-vs-DERs

if [[ $SKIP1 == "FALSE" ]]
then  
    sh step1-fullCoverage.sh ${EXPERIMENT}
fi
sh step2-makeModels.sh ${EXPERIMENT} ${PREFIX}
sh step3-analyzeChr.sh ${EXPERIMENT} ${PREFIX}
sh step4-mergeResults.sh ${EXPERIMENT} ${PREFIX}
sh step5-derfinderReport.sh ${EXPERIMENT} ${PREFIX}

if [[ $SKIP6 == "FALSE" ]]
then  
    sh step6-regionMatrix.sh ${EXPERIMENT}
fi
sh step7-regMatVsDERs.sh ${EXPERIMENT} ${PREFIX}
