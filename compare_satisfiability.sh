# Input validation
if [[ $# -lt 2 ]] || [[ $# -gt 3 ]]; then
	echo "Usage: $0 <PARSED_FILE_1> <PARSED_FILE_2> [INSTANCE_FILE]"
	exit -1
fi

# Set up parameters
FILE_1="${1}"
FILE_2="${2}"
INSTANCE_FILE="${3}"
TRUE="true"
SKIP_INDETERMINATE="false"

check_file_exists() {
	FILE_TO_CHECK="${1}"
	if [[ ! -f ${FILE_TO_CHECK} ]]; then
		echo "Could not find file '${FILE_TO_CHECK}'"
		exit -1
	fi
}

# Check that all required files exist
check_file_exists ${FILE_1}
check_file_exists ${FILE_2}

# Check that compared files are the same length
FILE_1_LENGTH=($(wc -l ${FILE_1})); FILE_1_LENGTH=${FILE_1_LENGTH[0]}
FILE_2_LENGTH=($(wc -l ${FILE_2})); FILE_2_LENGTH=${FILE_2_LENGTH[0]}

if [[ ${FILE_1_LENGTH} -ne ${FILE_2_LENGTH} ]]; then
	echo "Parsed files are different lengths (${FILE_1_LENGTH} and ${FILE_2_LENGTH})"
	exit -1
fi

if [[ -n ${INSTANCE_FILE} ]]; then
	check_file_exists ${INSTANCE_FILE}
	INSTANCE_FILE_LENGTH=($(wc -l ${INSTANCE_FILE})); INSTANCE_FILE_LENGTH=${INSTANCE_FILE_LENGTH[0]}
	
	if [[ ${FILE_1_LENGTH} -gt ${INSTANCE_FILE_LENGTH} ]]; then
		echo "Instance file is shorter than parsed file (${INSTANCE_FILE_LENGTH} < ${FILE_1_LENGTH})"
		exit -1
	fi
fi

# Read files
i=0
exec 3<"${FILE_1}"
exec 4<"${FILE_2}"

if [[ -n ${INSTANCE_FILE} ]]; then
	exec 5<"${INSTANCE_FILE}"
fi

while read LINE_1 <&3; do
	read LINE_2 <&4
	if [[ -n ${INSTANCE_FILE} ]]; then
		read LINE_3 <& 5
	fi
	
	# Ensure that the lines compare the same CNF
	CNF_1=${LINE_1#*,}; CNF_1=${CNF_1%%,*}
	CNF_2=${LINE_2#*,}; CNF_2=${CNF_2%%,*}
	
	if [[ ${CNF_1} != ${CNF_2} ]]; then
		echo "Files compare different CNFs: '${CNF_1}' and '${CNF_2}'"
		exit -1
	fi
	
	# Compare satisfiability
	SAT_1=${LINE_1##*,}
	SAT_2=${LINE_2##*,}

	i=$((i + 1))
	if [[ ${SAT_1} != ${SAT_2} ]]; then
		if [[ ${SKIP_INDETERMINATE} == $TRUE ]]; then
			if [[ -n ${INSTANCE_FILE} ]]; then
				echo "${LINE_3}"
			else
				echo "${i},${SAT_1},${SAT_2}"
			fi
		elif [[ ${SAT_1} != INDETERMINATE && ${SAT_2} != INDETERMINATE ]]; then
			if [[ -n ${INSTANCE_FILE} ]]; then
				echo "${LINE_3}"
			else
				echo "${i},${SAT_1},${SAT_2}"
			fi
		fi
	fi
done
