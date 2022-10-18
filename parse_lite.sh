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

# Global config
GLOBAL_SAT="SATISFIABLE"
GLOBAL_UNSAT="UNSATISFIABLE"
GLOBAL_INDET="INDETERMINATE"

# Parse maplesat log files
parse_maplesat() {
	PROBLEM=$1
	LOG_FILE=$2

	# Parse solver results
	CPU_TIME=(`grep "CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[3]}
	SATISFIABILITY=`tail -n 1 ${LOG_FILE}`

	# Normalize reported satisfiability values
	if [[ ${SATISFIABILITY} != ${GLOBAL_SAT} && ${SATISFIABILITY} != ${GLOBAL_UNSAT} ]]; then
		SATISFIABILITY=${GLOBAL_INDET}
	fi
}

# Parse xMaplesat log files
parse_xmaplesat() {
	PROBLEM=$1
	LOG_FILE=$2

	# Parse solver results
	CPU_TIME=(`grep "CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[3]}
	SATISFIABILITY=(`grep "^s " ${LOG_FILE}`); SATISFIABILITY=${SATISFIABILITY[1]}
	
	# Normalize reported satisfiability values
	if [[ ${SATISFIABILITY} != ${GLOBAL_SAT} && ${SATISFIABILITY} != ${GLOBAL_UNSAT} ]]; then
		SATISFIABILITY=${GLOBAL_INDET}
	fi
}

# Parse MapleLCM log files
parse_maplelcm() {	
	PROBLEM=$1
	LOG_FILE=$2

	# Parse solver results
	CPU_TIME=(`grep "c CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[4]}
	SATISFIABILITY=(`grep "^s " ${LOG_FILE}`); SATISFIABILITY=${SATISFIABILITY[1]}

	# Normalize reported satisfiability values
	if [[ ${SATISFIABILITY} != ${GLOBAL_SAT} && ${SATISFIABILITY} != ${GLOBAL_UNSAT} ]]; then
		SATISFIABILITY=${GLOBAL_INDET}
	fi
}

# Parse xMapleLCM log files
parse_xmaplelcm() {	
	PROBLEM=$1
	LOG_FILE=$2

	# Parse solver results
	CPU_TIME=(`grep "c CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[4]}
	SATISFIABILITY=(`grep "^s " ${LOG_FILE}`); SATISFIABILITY=${SATISFIABILITY[1]}

	# Normalize reported satisfiability values
	if [[ ${SATISFIABILITY} != ${GLOBAL_SAT} && ${SATISFIABILITY} != ${GLOBAL_UNSAT} ]]; then
		SATISFIABILITY=${GLOBAL_INDET}
	fi
}

# Parse kissat log files
parse_kissat() {
	PROBLEM=$1
	LOG_FILE=$2

	# Parse solver results
	CPU_TIME=(`grep "c process-time:" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[-2]}
	SATISFIABILITY=(`grep "^s " ${LOG_FILE}`); SATISFIABILITY=${SATISFIABILITY[1]}
	
	# Normalize reported satisfiability values
	if [[ ${SATISFIABILITY} != ${GLOBAL_SAT} && ${SATISFIABILITY} != ${GLOBAL_UNSAT} ]]; then
		SATISFIABILITY=${GLOBAL_INDET}
	fi
}

# Select parse function
if [[ ${SOLVER_NAME} == maplesat ]]; then
	PARSE_FUNCTION="parse_maplesat"
elif [[ ${SOLVER_NAME} == xmaplesat* ]]; then
	PARSE_FUNCTION="parse_xmaplesat"
elif [[ ${SOLVER_NAME} == maplelcm ]]; then
	PARSE_FUNCTION="parse_maplelcm"
elif [[ ${SOLVER_NAME} == xmaplelcm* ]]; then
	PARSE_FUNCTION="parse_xmaplelcm"
elif [[ ${SOLVER_NAME} == kissat ]]; then
	PARSE_FUNCTION="parse_kissat"
else
	echo "Solver '${SOLVER_NAME}' is unsupported!"
	exit -1
fi

# Parse files
while read -r line; do
	PROBLEM="${line}"
	LOG_FILE="${line}.${SOLVER_NAME}.log"
	${PARSE_FUNCTION} "${PROBLEM}" "${LOG_FILE}"	
	echo "${PROBLEM},${CPU_TIME},${SATISFIABILITY}"
done < "${INPUT_FILE}"
