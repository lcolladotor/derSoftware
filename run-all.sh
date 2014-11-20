#!/bin/sh

## Usage
# sh run-all.sh brainspan run3-v1.0.6
# sh run-all.sh stem run1-v1.1.2
# sh run-all.sh stem run2-v1.0.8 TRUE TRUE
# sh run-all.sh snyder run1-v1.0.8
# sh run-all.sh hippo run1-v1.0.8
# sh run-all.sh stem run3-v1.0.9 TRUE TRUE TRUE
# sh run-all.sh snyder run2-v1.0.9 TRUE TRUE TRUE
# sh run-all.sh hippo run2-v1.0.9 TRUE TRUE TRUE

## Skip fulLCov but run regionMatrix:
# sh run-all.sh brainspan run3-v1.0.6 TRUE FALSE

# Define variables
EXPERIMENT=$1
PREFIX=$2
SKIP1=${3-"FALSE"}
SKIP6=${4-"FALSE"}
SKIP8=${5-"FALSE"}

mkdir -p ${EXPERIMENT}/CoverageInfo
mkdir -p ${EXPERIMENT}/derAnalysis
mkdir -p ${EXPERIMENT}/regionMatrix
mkdir -p ${EXPERIMENT}/regionMatrix-vs-DERs
mkdir -p ${EXPERIMENT}/coverageToExon

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

if [[ $SKIP8 == "FALSE" ]]
then  
    sh step8-coverageToExon.sh ${EXPERIMENT}
fi

