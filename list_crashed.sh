# Input validation
if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <SOLVER>"
	exit -1
fi

# Set up parameters
SOLVER=$1

grep -li "timeout" output_${SOLVER}.*.err
