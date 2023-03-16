import multiprocessing, os, resource, subprocess, sys, time

# Constants
TIMEOUT = 5000 # time to run solver
EXTRA_TIME = 60 # extra time to respond to SIGTERM and exit gracefully

MEM_LIMIT_GB = 8
MEM_LIMIT_B = MEM_LIMIT_GB * (2**30)

def runJob(solver_name, solver_exec, instance, index):
    outfile_path = f"output/out_{solver_name}_{index + 1}.log"
    outfile = open(outfile_path, 'w')
    print(f"Running {solver_name} on instance {index}")

    try:
        resource.setrlimit(resource.RLIMIT_AS, (MEM_LIMIT_B, MEM_LIMIT_B))
        p = subprocess.run(
            f"time -p timeout -s SIGINT {TIMEOUT}s {solver_exec} {instance}".split(),
            stdout=outfile,
            stderr=outfile,
            encoding='ascii',
            timeout=(TIMEOUT + EXTRA_TIME)
        )
        p.check_returncode()
    except subprocess.TimeoutExpired:
        outfile.write("Process aborted -- timeout\n")
    except subprocess.CalledProcessError as e:
        outfile.write(f"Process aborted -- exited with returncode {e.returncode}\n")
    else:
        outfile.close()

if __name__ == '__main__':
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <INSTANCE_LIST> <SOLVER_PATH> <START_INDEX> <NUM_FILES>")
        exit(1)

    # Check whether instance list exists
    instance_list = sys.argv[1]
    if not os.path.isfile(instance_list):
        print(f"Could not find file {instance_list}")
        exit(1)

    # Check whether solver exists
    solver_path = sys.argv[2]
    solver_name = solver_path[solver_path.rfind('/') + 1:]
    if not os.path.isfile(solver_path):
        print(f"Could not find file {solver_path}")
        exit(1)

    # Read list of instances and check whether start/end are valid
    instances = [line.strip() for line in open(instance_list).readlines()]

    start_index = int(sys.argv[3])
    if start_index < 0 or start_index >= len(instances):
        print(f"Expected start index to be between 0 and {len(instances) - 1}")
        exit(1)

    num_files = int(sys.argv[4])
    if num_files < 1 or num_files > len(instances) - start_index:
        print(f"Expected num files to be between {1} and {len(instances) - start_index}")
        exit(1)
    end_index = start_index + num_files
    instances = instances[start_index:end_index]

    # Check whether instance file exists
    for instance in instances:
        if not os.path.isfile(instance):
            print(f"Could not find file {instance}")
            exit(1)

    # Queue a job for each instance
    with multiprocessing.Pool() as tpool:
        job_args = [(solver_name, solver_path, instance, i) for i, instance in enumerate(instances)]
        tpool.starmap(runJob, job_args)