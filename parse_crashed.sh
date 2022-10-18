#!/bin/bash

# Input validation
if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <LIST_OF_CRASHED> <INSTANCE_FILE>"
	exit -1
fi

LIST_OF_CRASHED=${1}
INSTANCE_FILE=${2}

for errfile in $(cat ${LIST_OF_CRASHED}); do
	crash_time=(`grep "real" ${errfile}`)
	m=${crash_time[1]%m*}
	s=${crash_time[1]#*m}; s=${s%s}
	s=$(bc <<< "60 * ${m} + ${s}")
	id=${errfile#*.}; id=${id%.err}
	file=$(sed -n "${id}p" ${INSTANCE_FILE})	
	echo "${file},${s}"
done
