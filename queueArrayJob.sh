# Input validation
if [[ $# -ne 5 ]]; then
	echo "Usage: $0 <INPUT_FILE> <SOLVER_NAME> <OUTPUT_FILE> <START_INDEX> <NUM_LINES>"
	exit -1
fi

# Set up parameters
INPUT_FILE="${1}"
SOLVER_NAME="${2}"
SCRIPT_FILE="${3}"
START_INDEX="${4}"
END_INDEX=$((START_INDEX + $5 - 1))

# Set up solver-specific parameters
SOLVER_PARAMS=""
if [[ ${SOLVER_NAME} == xmaple* ]]; then
	# Standard extension parameters
	SOLVER_PARAMS="${SOLVER_PARAMS} -ext-freq=2000 -ext-wndw=100 -ext-sub-min-width=3 -ext-sub-max-width=7 -ext-sign"
	if [[ ${SOLVER_NAME} == *_rnd_* ]]; then
		SOLVER_PARAMS="${SOLVER_PARAMS} -ext-num=10"
	elif [[ ${SOLVER_NAME} == *_sub_* ]]; then
		SOLVER_PARAMS="${SOLVER_PARAMS} -ext-num=10"
	fi

	# Set up clause width range filter parameters
	if [[ ${SOLVER_NAME} == *_rng* ]]; then
		SOLVER_PARAMS="${SOLVER_PARAMS} -ext-min-width=3 -ext-max-width=7"

	# Set up LBD limits filter parameters
	elif [[ ${SOLVER_NAME} == *_lbd* ]]; then
		SOLVER_PARAMS="${SOLVER_PARAMS} -ext-min-lbd=0 -ext-max-lbd=5"
	fi
elif [[ ${SOLVER_NAME} == maplesdcl* ]]; then
	SOLVER_PARAMS="${SOLVER_PARAMS} -SDCL-mode -SDCL-width-lower=6 -SDCL-width-upper=10 -cpu-lim=5000"

	if [[ ${SOLVER_NAME} == *_rnd ]]; then
		SOLVER_PARAMS="${SOLVER_PARAMS} -SDCL-frequency=1 -SDCL-mode-seq -SDCL-restart-probability=0.05"
	else
		if [[ ${SOLVER_NAME} == *_seq ]]; then
			SOLVER_PARAMS="${SOLVER_PARAMS} -SDCL-frequency=1 -SDCL-mode-seq"
		else
			SOLVER_PARAMS="${SOLVER_PARAMS} -SDCL-frequency=1 -SDCL-nof-children=1"
		fi
		SOLVER_NAME="maplesdcl"
	fi
fi

# Check that solver exists
SOLVER_DIR="/home/${USER}/solvers/"
SOLVER_PATH="${SOLVER_DIR}/${SOLVER_NAME}"
if [[ ! -f ${SOLVER_PATH} ]]; then
	echo "Could not find solver '${SOLVER_PATH}'"
	exit -1
fi

# Generate command to execute
SCRIPT="${SOLVER_PATH} ${SOLVER_PARAMS} \"\${INSTANCE_NAME}\" > \"\${INSTANCE_NAME}.${2}.log\" 2>&1"

# Generate script for sbatch
echo "#!/bin/bash"                                                              > "${SCRIPT_FILE}"
echo "#SBATCH --account=def-vganesh"                                           >> "${SCRIPT_FILE}"
echo "#SBATCH --time=0:00:5050"                                                >> "${SCRIPT_FILE}"
echo "#SBATCH --mem=10G"                                                       >> "${SCRIPT_FILE}"
echo "#SBATCH --array=${START_INDEX}-${END_INDEX}"                             >> "${SCRIPT_FILE}"
echo "#SBATCH --exclude=gra[801-1043]"                                         >> "${SCRIPT_FILE}"
echo "#SBATCH --output=output_${2}.%a.out"                                     >> "${SCRIPT_FILE}"
echo "#SBATCH --error=output_${2}.%a.err"                                      >> "${SCRIPT_FILE}"
echo ""                                                                        >> "${SCRIPT_FILE}"
echo "echo \"Using node \${SLURMD_NODENAME} for job \${SLURM_ARRAY_TASK_ID}\"" >> "${SCRIPT_FILE}"
echo "INSTANCE_NAME=\`sed -n \${SLURM_ARRAY_TASK_ID}p ${INPUT_FILE}\`"         >> "${SCRIPT_FILE}"
echo "time (timeout -s SIGINT 5000s ${SCRIPT})"                                >> "${SCRIPT_FILE}"

# Queue script
sbatch ${SCRIPT_FILE}
