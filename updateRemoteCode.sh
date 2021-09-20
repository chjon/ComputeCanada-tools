DST_ADDRESS="jt2chung@graham.computecanada.ca"
DST_ROOT="/home/jt2chung/solver_src/xmaplesat"
SRC_ROOT="/mnt/f/Programming/Research/xMapleSAT/"

# Ensure that the source root directory exists
if [[ ! -d ${SRC_ROOT} ]]; then
	echo "Source directory ${SRC_ROOT} is not a directory"
	exit 1
fi
SRC_ROOT=$(readlink -f ${SRC_ROOT})

# Input validation
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <SRC_FILE_1> [SRC_FILE_2 [...]]"
	exit 1
fi

FAILURE="false"
OUT_STR=""
for REL_PATH in $@; do
	ABS_PATH=$(readlink -f ${REL_PATH})
	# Ensure that the files are listed under the source directory
	if [[ ${ABS_PATH} != ${SRC_ROOT}/* ]]; then
		echo "File '${ABS_PATH}' is not under '${SRC_ROOT}'"
		FAILURE="true"
	# Generate SFTP command
	else
		REL_PATH=${ABS_PATH#${SRC_ROOT}/}
		OUT_STR="${OUT_STR}put ${ABS_PATH} ${DST_ROOT}/${REL_PATH}"$'\n'
	fi
done

# Early exit if not all the files are under the source directory
if [[ ${FAILURE} == "true" ]]; then
	exit 1
fi

# Transfer files
sftp "${DST_ADDRESS}" << EOF
	${OUT_STR}
EOF
