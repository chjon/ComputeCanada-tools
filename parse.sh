#!/bin/bash

# Input validation
if [[ $# -ne 4 ]]; then
	echo "Usage: $0 <SOLVER_NAME> <INPUT_FILE> <START_INDEX> <NUM_LINES>"
	exit -1
fi

# Check that file exists
INPUT_FILE=$2
if [[ ! -f $INPUT_FILE ]]; then
	echo "File '${INPUT_FILE}' does not exist"
	exit -1
fi

# Get parameters
SOLVER_NAME=$1
START_INDEX=$3
END_INDEX=$((START_INDEX + $4 - 1))

# Global config
GLOBAL_SAT="SATISFIABLE"
GLOBAL_UNSAT="UNSATISFIABLE"
GLOBAL_INDET="INDETERMINATE"

# Parse maplesat log files
parse_maplesat() {
	PROBLEM=$1
	LOG_FILE=$2

	# Parse solver results
	RESTARTS=(`grep "restarts" ${LOG_FILE}`); RESTARTS=${RESTARTS[2]}
	CONFLICTS=(`grep "conflicts" ${LOG_FILE}`); CONFLICTS=${CONFLICTS[2]}
	DECISIONS=(`grep "decisions" ${LOG_FILE}`); DECISIONS=${DECISIONS[2]}
	PROPAGATIONS=(`grep "propagations" ${LOG_FILE}`); PROPAGATIONS=${PROPAGATIONS[2]}
	CONF_LITS=(`grep "conflict literals" ${LOG_FILE}`); CONF_LITS=${CONF_LITS[3]}
	TOTAL_EXT_VARS=0
	DELETED_EXT_VARS=0
	MAX_EXT_VARS=0
	EXT_DECISIONS=0
	CONF_EXT_CLAUSES=0
	LEARNT_EXT_CLAUSES=0
	LEARNT_LBD=""
	MEM_USED=(`grep "Memory used" ${LOG_FILE}`); MEM_USED=${MEM_USED[3]}
	CPU_TIME=(`grep "CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[3]}
	ER0_TIME=0
	ER1_TIME=0
	ER2_TIME=0
	ER3_TIME=0
	ER4_TIME=0
	ER5_TIME=0
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
	RESTARTS=(`grep "restarts" ${LOG_FILE}`); RESTARTS=${RESTARTS[2]}
	CONFLICTS=(`grep "conflicts" ${LOG_FILE}`); CONFLICTS=${CONFLICTS[2]}
	DECISIONS=(`grep "decisions" ${LOG_FILE}`); DECISIONS=${DECISIONS[2]}
	PROPAGATIONS=(`grep "propagations" ${LOG_FILE}`); PROPAGATIONS=${PROPAGATIONS[2]}
	CONF_LITS=(`grep "conflict literals" ${LOG_FILE}`); CONF_LITS=${CONF_LITS[3]}
	TOTAL_EXT_VARS=(`grep "total ext vars" ${LOG_FILE}`); TOTAL_EXT_VARS=${TOTAL_EXT_VARS[4]}
	DELETED_EXT_VARS=(`grep "deleted ext vars" ${LOG_FILE}`); DELETED_EXT_VARS=${DELETED_EXT_VARS[4]}
	MAX_EXT_VARS=(`grep "max ext vars" ${LOG_FILE}`); MAX_EXT_VARS=${MAX_EXT_VARS[4]}
	EXT_DECISIONS=(`grep "decisions on ext vars" ${LOG_FILE}`); EXT_DECISIONS=${EXT_DECISIONS[5]}
	CONF_EXT_CLAUSES=(`grep "conflict ext clauses" ${LOG_FILE}`); CONF_EXT_CLAUSES=${CONF_EXT_CLAUSES[4]}
	LEARNT_EXT_CLAUSES=(`grep "learnt ext clauses" ${LOG_FILE}`); LEARNT_EXT_CLAUSES=${LEARNT_EXT_CLAUSES[4]}
	LEARNT_LBD=(`grep "total lbd of learnts" ${LOG_FILE}`); LEARNT_LBD=${LEARNT_LBD[5]}
	MEM_USED=(`grep "Memory used" ${LOG_FILE}`); MEM_USED=${MEM_USED[3]}
	CPU_TIME=(`grep "CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[3]}
	ER0_TIME=(`grep "ER_sel time" ${LOG_FILE}`); ER0_TIME=${ER0_TIME[3]}
	ER1_TIME=(`grep "ER_add time" ${LOG_FILE}`); ER1_TIME=${ER1_TIME[3]}
	ER2_TIME=(`grep "ER_delC time" ${LOG_FILE}`); ER2_TIME=${ER2_TIME[3]}
	ER3_TIME=(`grep "ER_delV time" ${LOG_FILE}`); ER3_TIME=${ER3_TIME[3]}
	ER4_TIME=(`grep "ER_sub time" ${LOG_FILE}`); ER4_TIME=${ER4_TIME[3]}
	ER5_TIME=(`grep "ER_stat time" ${LOG_FILE}`); ER5_TIME=${ER5_TIME[3]}
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
	RESTARTS=(`grep "c restarts" ${LOG_FILE}`); RESTARTS=${RESTARTS[3]}
	CONFLICTS=(`grep "c conflicts" ${LOG_FILE}`); CONFLICTS=${CONFLICTS[3]}
	DECISIONS=(`grep "c decisions" ${LOG_FILE}`); DECISIONS=${DECISIONS[3]}
	PROPAGATIONS=(`grep "c propagations" ${LOG_FILE}`); PROPAGATIONS=${PROPAGATIONS[3]}
	CONF_LITS=(`grep "c conflict literals" ${LOG_FILE}`); CONF_LITS=${CONF_LITS[4]}
	TOTAL_EXT_VARS=0
	DELETED_EXT_VARS=0
	EXT_DECISIONS=0
	CONF_EXT_CLAUSES=0
	LEARNT_EXT_CLAUSES=0
	LEARNT_LBD=""
	MEM_USED=(`grep "c Memory used" ${LOG_FILE}`); MEM_USED=${MEM_USED[4]}
	CPU_TIME=(`grep "c CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[4]}
	ER0_TIME=0
	ER1_TIME=0
	ER2_TIME=0
	ER3_TIME=0
	ER4_TIME=0
	ER5_TIME=0
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
	RESTARTS=(`grep "c restarts" ${LOG_FILE}`); RESTARTS=${RESTARTS[3]}
	CONFLICTS=(`grep "c conflicts" ${LOG_FILE}`); CONFLICTS=${CONFLICTS[3]}
	DECISIONS=(`grep "c decisions" ${LOG_FILE}`); DECISIONS=${DECISIONS[3]}
	PROPAGATIONS=(`grep "c propagations" ${LOG_FILE}`); PROPAGATIONS=${PROPAGATIONS[3]}
	CONF_LITS=(`grep "c conflict literals" ${LOG_FILE}`); CONF_LITS=${CONF_LITS[4]}
	TOTAL_EXT_VARS=(`grep "c total ext vars" ${LOG_FILE}`); TOTAL_EXT_VARS=${TOTAL_EXT_VARS[5]}
	DELETED_EXT_VARS=(`grep "c deleted ext vars" ${LOG_FILE}`); DELETED_EXT_VARS=${DELETED_EXT_VARS[5]}
	MAX_EXT_VARS=(`grep "c max ext vars" ${LOG_FILE}`); MAX_EXT_VARS=${MAX_EXT_VARS[5]}
	EXT_DECISIONS=(`grep "c decisions on ext vars" ${LOG_FILE}`); EXT_DECISIONS=${EXT_DECISIONS[6]}
	CONF_EXT_CLAUSES=(`grep "c conflict ext clauses" ${LOG_FILE}`); CONF_EXT_CLAUSES=${CONF_EXT_CLAUSES[5]}
	LEARNT_EXT_CLAUSES=(`grep "c learnt ext clauses" ${LOG_FILE}`); LEARNT_EXT_CLAUSES=${LEARNT_EXT_CLAUSES[5]}
	LEARNT_LBD=(`grep "c total lbd of learnts" ${LOG_FILE}`); LEARNT_LBD=${LEARNT_LBD[6]}
	MEM_USED=(`grep "c Memory used" ${LOG_FILE}`); MEM_USED=${MEM_USED[4]}
	CPU_TIME=(`grep "c CPU time" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[4]}
	ER0_TIME=(`grep "c ER_sel time" ${LOG_FILE}`); ER0_TIME=${ER0_TIME[4]}
	ER1_TIME=(`grep "c ER_add time" ${LOG_FILE}`); ER1_TIME=${ER1_TIME[4]}
	ER2_TIME=(`grep "c ER_delC time" ${LOG_FILE}`); ER2_TIME=${ER2_TIME[4]}
	ER3_TIME=(`grep "c ER_delV time" ${LOG_FILE}`); ER3_TIME=${ER3_TIME[4]}
	ER4_TIME=(`grep "c ER_sub time" ${LOG_FILE}`); ER4_TIME=${ER4_TIME[4]}
	ER5_TIME=(`grep "c ER_stat time" ${LOG_FILE}`); ER5_TIME=${ER5_TIME[4]}
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
	RESTARTS=(`grep "c restarts:" ${LOG_FILE}`); RESTARTS=${RESTARTS[2]}
	CONFLICTS=(`grep "c conflicts:" ${LOG_FILE}`); CONFLICTS=${CONFLICTS[2]}
	DECISIONS=(`grep "c decisions:" ${LOG_FILE}`); DECISIONS=${DECISIONS[2]}
	PROPAGATIONS=(`grep "c propagations:" ${LOG_FILE}`); PROPAGATIONS=${PROPAGATIONS[2]}
	CONF_LITS=(`grep "c literals_learned:" ${LOG_FILE}`); CONF_LITS=${CONF_LITS[2]}
	TOTAL_EXT_VARS=0
	DELETED_EXT_VARS=0
	MAX_EXT_VARS=0
	EXT_DECISIONS=0
	CONF_EXT_CLAUSES=0
	LEARNT_EXT_CLAUSES=0
	LEARNT_LBD=""
	MEM_USED=(`grep "c maximum-resident-set-size:" ${LOG_FILE}`); MEM_USED=${MEM_USED[-2]}
	CPU_TIME=(`grep "c process-time:" ${LOG_FILE}`); CPU_TIME=${CPU_TIME[-2]}
	ER0_TIME=0
	ER1_TIME=0
	ER2_TIME=0
	ER3_TIME=0
	ER4_TIME=0
	ER5_TIME=0
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
for line in $(sed "${START_INDEX},${END_INDEX}p;d" "${INPUT_FILE}"); do
	PROBLEM="${line}"
	LOG_FILE="${line}.${SOLVER_NAME}.log"
	${PARSE_FUNCTION} "${PROBLEM}" "${LOG_FILE}"	
	echo "${SOLVER_NAME},${PROBLEM},${RESTARTS},${CONFLICTS},${DECISIONS},${PROPAGATIONS},${CONF_LITS},${TOTAL_EXT_VARS},${DELETED_EXT_VARS},${MAX_EXT_VARS},${EXT_DECISIONS},${CONF_EXT_CLAUSES},${LEARNT_EXT_CLAUSES},${LEARNT_LBD},${MEM_USED},${CPU_TIME},${ER0_TIME},${ER1_TIME},${ER2_TIME},${ER3_TIME},${ER4_TIME},${ER5_TIME},${SATISFIABILITY}"
done
