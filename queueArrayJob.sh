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

SOLVER_DIR="/home/jt2chung/solvers/"
SOLVER_PATH="${SOLVER_DIR}/${SOLVER_NAME}"
SCRIPT="${SOLVER_PATH} \"\${INSTANCE_NAME}\" > \"\${INSTANCE_NAME}.${SOLVER_NAME}.log\""

# Check that solver exists
if [[ ! -f ${SOLVER_PATH} ]]; then
	echo "Could not find solver '${SOLVER_PATH}'"
	exit -1
fi

# Generate script for sbatch
echo "#!/bin/bash"                                                              > "${SCRIPT_FILE}"
echo "#SBATCH --account=def-vganesh"                                           >> "${SCRIPT_FILE}"
echo "#SBATCH --time=0:00:5050"                                                >> "${SCRIPT_FILE}"
echo "#SBATCH --mem=10G"                                                       >> "${SCRIPT_FILE}"
echo "#SBATCH --array=${START_INDEX}-${END_INDEX}"                             >> "${SCRIPT_FILE}"
echo "#SBATCH --exclude=gra[801-1325]"                                         >> "${SCRIPT_FILE}"
echo ""                                                                        >> "${SCRIPT_FILE}"
echo "echo \"Using node \${SLURMD_NODENAME} for job \${SLURM_ARRAY_TASK_ID}\"" >> "${SCRIPT_FILE}"
echo "source /home/jt2chung/sat/bin/activate"                                  >> "${SCRIPT_FILE}"
echo "INSTANCE_NAME=\`sed -n \${SLURM_ARRAY_TASK_ID}p ${INPUT_FILE}\`"         >> "${SCRIPT_FILE}"
echo "timeout -s SIGINT 5000s ${SCRIPT}"                                       >> "${SCRIPT_FILE}"

# Queue script
sbatch ${SCRIPT_FILE}
