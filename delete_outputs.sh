#!/bin/bash

# Input validation
if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <INSTANCE_LIST> <SOLVER_NAME>"
	exit -1
fi

# Check that file exists
INPUT_FILE=$1
if [[ ! -f $INPUT_FILE ]]; then
	echo "File '${INPUT_FILE}' does not exist"
	exit -1
fi

# Get parameters
SOLVER_NAME=$2

# Parse files
while read -r line; do
	PROBLEM="${line}"
	LOG_FILE="${line}.${SOLVER_NAME}.log"
	rm -f ${LOG_FILE}
done < "${INPUT_FILE}"
