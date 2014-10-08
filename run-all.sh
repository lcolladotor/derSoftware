#!/bin/sh

## Usage
# sh run-all.sh brainspan run1-v0.99.6
# sh run-all.sh stem run1-v0.99.6

# Define variables
EXPERIMENT=$1
PREFIX=$2

sh step1-fullCoverage.sh ${EXPERIMENT}
sh step2-makeModels.sh ${EXPERIMENT} ${PREFIX}
sh step3-analyzeChr.sh ${EXPERIMENT} ${PREFIX}
sh step4-mergeResults.sh ${EXPERIMENT} ${PREFIX}
sh step5-derfinderReport.sh ${EXPERIMENT} ${PREFIX}
sh step6-regionMatrix.sh ${EXPERIMENT}
sh step7-regMatVsDERs.sh ${EXPERIMENT} ${PREFIX}
