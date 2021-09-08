# Tools
This is a repository of tools for working with SAT solvers on ComputeCanada's SHARCNET network and Slurm job queuing system.

## `download_instances.sh`
This script is used to fetch and decompress CNF instances from remote hosts.

Usage:  
`./download_instances.sh <BENCHMARK> <OUTPUT_DIR>`
* `<BENCHMARK>`: The name of the instance benchmark to download. There are currently two supported benchmarks:
  * `agile`: This benchmark is composed of all the Agile-track instances from the 2017 SAT Competition.
  * `sat2019`: This benchmark is composed of all the Main-track instances from the 2019 SAT Competition. 
* `<OUTPUT_DIR>`: The name of the output directory in which to store the downloaded instances.

## `queueArrayJob.sh`
This script is used to execute large numbers of SAT solver jobs using the "array job" functionality provided by the Slurm job queuing system. It generates a script for executing the job and queues it for execution using Slurm.

Usage:  
`./queueArrayJob.sh <INPUT_FILE> <SOLVER_NAME> <OUTPUT_FILE> <START_INDEX> <NUM_LINES>`
* `<INPUT_FILE>`: A file containing a list of paths to DIMACS-format CNF problem instances. Log files are written to the same directories by appending a suffix constructed from the solver name and `.log`
* `<SOLVER_NAME>`: The name of the solver to use for solving the problem instances. This solver must exist in the solver directory.
* `<OUTPUT_FILE>`: The name of the script to generate. Specifying different output files allows for multiple Slurm array jobs to be queued and execute in parallel.
* `<START_INDEX>`: The line number from which to read instances from the input file. This offset allows for multiple batches of jobs to be executed. This is useful for job quantities which surpass the ComputeCanada job limit.
* `<NUM_LINES>`: The number of lines to read (and therefore, the number of jobs to execute). Lines are read sequentially starting from the provided start index.

## `parse.sh`
This script is used to parse the log files generated by `queueArrayJob.sh` and format important data as a CSV, which is output to the terminal. The meanings of the parameters to this script are identical to the parameters for `queueArrayJob.sh`. 

Usage:  
`./parse.sh <SOLVER_NAME> <INPUT_FILE> <START_INDEX> <NUM_LINES>`
* `<SOLVER_NAME>`: The name of the solver to use for solving the problem instances. This solver must exist in the solver directory.
* `<INPUT_FILE>`: A file containing a list of paths to DIMACS-format CNF problem instances. Log files are written to the same directories by appending a suffix constructed from the solver name and `.log`
* `<START_INDEX>`: The line number from which to read instances from the input file. This offset allows for multiple batches of jobs to be executed. This is useful for job quantities which surpass the ComputeCanada job limit.
* `<NUM_LINES>`: The number of lines to read (and therefore, the number of jobs to execute). Lines are read sequentially starting from the provided start index.

## `./compare_satisfiability.sh`
This script is used to compare the satisfiability results reported by different solvers. It uses the CSV file format generated by the `parse.sh` script. Both input files should share the same set of CNF instances.

Usage:  
`./compare_satisfiability.sh <PARSED_FILE_1> <PARSED_FILE_2>`
* `<PARSED_FILE_1>`: The first file to compare.
* `<PARSED_FILE_2>`: The second file to compare.