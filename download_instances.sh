#!/bin/bash

# Input validation
if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <BENCHMARK> <OUTPUT_DIR>"
	exit -1
fi

BENCHMARK="${1}"
OUTPUT_DIR="${2}"

# Check whether output directory already exists
if [[ -d ${OUTPUT_DIR} ]]; then
	echo "${OUTPUT_DIR} exists - exiting"
	exit 1
fi

# Download regression benchmark (SAT 2017 Agile)
if [[ ${BENCHMARK} == agile ]]; then
	echo "Downloading..." && \
	wget https://baldur.iti.kit.edu/sat-competition-2017/benchmarks/Agile.zip && \
	echo "Unzipping archive..." && \
	unzip Agile.zip && \
	mv ./Agile ${OUTPUT_DIR} && \
	echo "Decompressing files..." && \
	cd ${OUTPUT_DIR} && \
	bunzip2 *.bz2 && \
	;
	
# Download SAT 2019 benchmark
elif [[ ${BENCHMARK} == sat2019 ]]; then
	echo "Downloading..." && \
	wget satcompetition.org/sr2019benchmarks.zip && \
	echo "Unzipping archive..." && \
	unzip sr2019benchmarks.zip && \
	echo "Flattening archive" && \
	mkdir ${OUTPUT_DIR} && \
	find ./sr2019 -mindepth 2 -type f -exec mv -t ${OUTPUT_DIR} -i '{}' + && \
	rm -rf ./sr2019 && \
	echo "Decompressing files..." && \
	cd ${OUTPUT_DIR} && \
	unxz *.xz && \
	;

else
	echo "Benchmark '${BENCHMARK}' is not supported!"
	exit 1
fi

echo "Finished fetching benchmark '${BENCHMARK}'"
