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
	bunzip2 *.bz2

# Download SAT 2002 benchmark
elif [[ ${BENCHMARK} == sat2002 ]]; then
	echo "Downloading..." && \	
	wget https://www.cs.ubc.ca/~hoos/SATLIB/Benchmarks/SAT/New/Competition-02/sat-2002-beta.tgz && \
	echo "Unzipping archive..." && \
	gunzip sat-2002-beta.tgz && \
	echo "Decompressing files..." && \
	tar -xvf sat-2002-beta.tar && \
	mv ./sat-2002-beta ${OUTPUT_DIR} && \
	rm sat-2022-beta.tar

# Download SAT 2003 benchmark
elif [[ ${BENCHMARK} == sat2003 ]]; then
	echo "Downloading..." && \	
	wget https://www.cs.ubc.ca/~hoos/SATLIB/Benchmarks/SAT/New/Competition-03/distrib-shuffled.tar.bz2 && \
	mv ./distrib-shuffled.tar.bz2 ${OUTPUT_DIR} && \
	echo "Unzipping archive..." && \
	cd ${OUTPUT_DIR} && \
	bunzip2 distrib-shuffled.tar.bz2 && \
	echo "Extracting archive..." && \
	tar -xvf distrib-shuffled.tar && \
	rm distrib-shuffled.tar && \
	echo "Decompressing files..." && \
	find . -name "*.gz" -exec gunzip {} \;

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
	unxz *.xz

# Download SAT 2020 benchmark
elif [[ ${BENCHMARK} == sat2020 ]]; then
	mkdir ${OUTPUT_DIR}	
	cd ${OUTPUT_DIR}

	echo "Downloading..."
	wget https://satcompetition.github.io/2020/downloads/sc2020-main.uri && \
	wget --content-disposition -i sc2020-main.uri && \
	rm sc2020-main.uri && \
	echo "Decompressing files..." && \
	unxz *.xz

# Download SAT 2021 benchmark
elif [[ ${BENCHMARK} == sat2021 ]]; then
	mkdir ${OUTPUT_DIR}
	cd ${OUTPUT_DIR}

	echo "Downloading..."
	wget https://satcompetition.github.io/2021/downloads/main2021.url && \
	wget --content-disposition -i main2021.url && \
	rm main2021.url && \
	echo "Decompressing files..." && \
	unxz *.xz

# Download SAT 2022 benchmark
elif [[ ${BENCHMARK} == sat2022 ]]; then
	mkdir ${OUTPUT_DIR}
	cd ${OUTPUT_DIR}

	echo "Downloading..."
	wget -O track_main_2022.uri https://gbd.iti.kit.edu/getinstances?track=main_2022 && \
	wget --content-disposition -i track_main_2022.uri && \
	rm track_main_2022.uri && \
	echo "Decompressing files..." && \
	unxz *.xz

# Generate random 3-CNF and 5-CNF benchmarks
elif [[ ${BENCHMARK} == random ]]; then
	mkdir ${OUTPUT_DIR}
	source ~/sat2/bin/activate

	# Note: starting values of n are chosen such that the maximum number of possible clauses allows the hardness threshold to be met
	
	# Each clause uses k variables, so for n variables, the number of possible clauses is: choose(n, k) * 2^k
	# We require m / n >= THRESHOLD, so:
	# choose(n, k) >= THRESHOLD * n


	# 3-CNF
	echo "Generating 3-CNFs"
	K=3
	THRESHOLD=4.26
	for ((n=100;n<=500;n+=25)); do
		m=$(printf "%.0f" $(bc -l <<< "${n} * ${THRESHOLD}"))
		echo "n=${n}, m=${m}"
		for ((i=0;i<10;i++)); do
			cnfgen randkcnf ${K} ${n} ${m} > ${OUTPUT_DIR}/rand3_${n}_${m}_${i}.cnf
		done
	done

	# 5-CNF
	echo "Generating 5-CNFs"
	K=5
	THRESHOLD=21.12
	for ((n=100;n<=500;n+=25)); do
		m=$(printf "%.0f" $(bc -l <<< "${n} * ${THRESHOLD}"))
		echo "n=${n}, m=${m}"
		for ((i=0;i<10;i++)); do
			cnfgen randkcnf ${K} ${n} ${m} > ${OUTPUT_DIR}/rand5_${n}_${m}_${i}.cnf
		done
	done

	deactivate

# Generate hash function inversion benchmarks
elif [[ ${BENCHMARK} == crypto ]]; then
	mkdir ${OUTPUT_DIR} ${OUTPUT_DIR}/sha1 ${OUTPUT_DIR}/sha256

	GENERATOR=~/SAT-encoding/crypto/main
	ADDERS=(two_operand counter_chain dot_matrix)

	echo "Generating SHA-1 inversion instances"
	MIN_ROUNDS=18
	MAX_ROUNDS=22
	NUM_INSTANCES=5
	for ((i=${MIN_ROUNDS};i<=${MAX_ROUNDS};i++)); do
		for ADDER in ADDERS; do
			for ((j=0;j<${NUM_INSTANCES};j++)); do
				${GENERATOR} --function sha1 --rounds ${i} --target random --adder_type ${ADDER} > ${OUTPUT_DIR}/sha1/preimg_${i}_${ADDER}_${j}.cnf
			done
		done
	done
	
	echo "Generating SHA-256 inversion instances"
	MIN_ROUNDS=18
	MAX_ROUNDS=22
	NUM_INSTANCES=5
	for ((i=${MIN_ROUNDS};i<=${MAX_ROUNDS};i++)); do
		for ADDER in ADDERS; do
			for ((j=0;j<${NUM_INSTANCES};j++)); do
				${GENERATOR} --function sha256 --rounds ${i} --target random --adder_type ${ADDER} > ${OUTPUT_DIR}/sha256/preimg_${i}_${ADDER}_${j}.cnf
			done
		done
	done

# Generate PHP benchmarks
elif [[ ${BENCHMARK} == php ]]; then
	mkdir ${OUTPUT_DIR} ${OUTPUT_DIR}/php ${OUTPUT_DIR}/fphp ${OUTPUT_DIR}/xphp
	
	MIN_HOLES=4
	MAX_HOLES=25

	echo "Generating PHP instances"
	for ((i=${MIN_HOLES};i<=${MAX_HOLES};i++)); do
		NUM_PIGEONS=$((i + 1))
		NUM_HOLES=${i}
		
		# Generate normal PHP instances
		python ~/generators/generate_PHP.py ${NUM_PIGEONS} ${NUM_HOLES} 0 0 0 >> ${OUTPUT_DIR}/php/php_${NUM_PIGEONS}_${NUM_HOLES}.cnf
		
		# Generate functional PHP instances
		python ~/generators/generate_PHP.py ${NUM_PIGEONS} ${NUM_HOLES} 1 0 0 >> ${OUTPUT_DIR}/fphp/fphp_${NUM_PIGEONS}_${NUM_HOLES}.cnf

		# Generate normal PHP instances with extension variables included
		python ~/generators/generate_PHP.py ${NUM_PIGEONS} ${NUM_HOLES} 0 1 1 >> ${OUTPUT_DIR}/xphp/xphp1_${NUM_PIGEONS}_${NUM_HOLES}.cnf
		python ~/generators/generate_PHP.py ${NUM_PIGEONS} ${NUM_HOLES} 0 2 1 >> ${OUTPUT_DIR}/xphp/xphp2_${NUM_PIGEONS}_${NUM_HOLES}.cnf	
	done
else
	echo "Benchmark '${BENCHMARK}' is not supported!"
	exit 1
fi

echo "Finished fetching benchmark '${BENCHMARK}'"
