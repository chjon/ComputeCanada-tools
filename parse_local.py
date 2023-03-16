import os, re, sys

TIMEOUT = 5000
GLOBAL_SAT="SATISFIABLE"
GLOBAL_UNSAT="UNSATISFIABLE"
GLOBAL_INDET="INDETERMINATE"

class SolverResults:
    def __init__(self):
        self.restarts           = ''
        self.conflicts          = ''
        self.decisions          = ''
        self.propagations       = ''
        self.conf_lits          = ''
        self.total_ext_vars     = 0
        self.deleted_ext_vars   = 0
        self.max_ext_vars       = 0
        self.ext_decisions      = 0
        self.conf_ext_clauses   = 0
        self.learnt_ext_clauses = 0
        self.learnt_lbd         = 0
        self.mem_used           = ''
        self.cpu_time           = 5000
        self.er_0_time          = 0
        self.er_1_time          = 0
        self.er_2_time          = 0
        self.er_3_time          = 0
        self.er_4_time          = 0
        self.er_5_time          = 0
        self.satisfiability     = GLOBAL_INDET

    def __str__(self):
        return ','.join([
            f'{self.restarts          }',
            f'{self.conflicts         }',
            f'{self.decisions         }',
            f'{self.propagations      }',
            f'{self.conf_lits         }',
            f'{self.total_ext_vars    }',
            f'{self.deleted_ext_vars  }',
            f'{self.max_ext_vars      }',
            f'{self.ext_decisions     }',
            f'{self.conf_ext_clauses  }',
            f'{self.learnt_ext_clauses}',
            f'{self.learnt_lbd        }', 
            f'{self.mem_used          }', 
            f'{self.cpu_time          }', 
            f'{self.er_0_time         }', 
            f'{self.er_1_time         }', 
            f'{self.er_2_time         }', 
            f'{self.er_3_time         }', 
            f'{self.er_4_time         }', 
            f'{self.er_5_time         }', 
            f'{self.satisfiability    }',
        ])

def parse_kissat(log_lines):
    SECTION_REGEX = re.compile(r'c ---- \[ (.+) \]')
    CPU_TIME_REGEX       = re.compile(r'real (\d+\.\d+)')
    MEM_USED_REGEX       = re.compile(r'c maximum-resident-set-size:\s+(\d+) bytes')
    SATISFIABILITY_REGEX = re.compile(r's (.+)')
    CONFLICTS_REGEX      = re.compile(r'c conflicts:\s+(\d+)')
    DECISIONS_REGEX      = re.compile(r'c decisions:\s+(\d+)')
    CONF_LITS_REGEX      = re.compile(r'c literals_learned:\s+(\d+)')
    PROPAGATIONS_REGEX   = re.compile(r'c propagations:\s+(\d+)')
    RESTARTS_REGEX       = re.compile(r'c restarts:\s+(\d+)')

    results = SolverResults()

    # Get results
    i = 0
    while i < len(log_lines):
        while log_lines[i][0] == 'c' and SECTION_REGEX.match(log_lines[i]) == None:
            i = i + 1

        if log_lines[i][0] != 'c': break 

        section = SECTION_REGEX.match(log_lines[i]).group(1)
        if section == 'result':
            # Read satisfiability
            i = i + 2
            m = SATISFIABILITY_REGEX.match(log_lines[i])
            results.satisfiability = m.group(1)

            # Skip variable assignment
            while log_lines[i][0] == 'v': i = i + 1

        elif section == 'statistics':
            i = i + 1

            while CONFLICTS_REGEX.match(log_lines[i]) == None: i = i + 1
            results.conflicts = CONFLICTS_REGEX.match(log_lines[i]).group(1)

            while DECISIONS_REGEX.match(log_lines[i]) == None: i = i + 1
            results.decisions = DECISIONS_REGEX.match(log_lines[i]).group(1)

            while CONF_LITS_REGEX.match(log_lines[i]) == None: i = i + 1
            results.conf_lits = CONF_LITS_REGEX.match(log_lines[i]).group(1)

            while PROPAGATIONS_REGEX.match(log_lines[i]) == None: i = i + 1
            results.propagations = PROPAGATIONS_REGEX.match(log_lines[i]).group(1)

            while RESTARTS_REGEX.match(log_lines[i]) == None: i = i + 1
            results.restarts = RESTARTS_REGEX.match(log_lines[i]).group(1)

        elif section == 'resources':
            i = i + 2
            m = MEM_USED_REGEX.match(log_lines[i])
            if m != None:
                results.mem_used = m.group(1)

        elif section == 'shutting down':
            i = i + 4
            break
        else:
            i = i + 1

    # Read CPU time
    for line in log_lines[i:]:
        m = CPU_TIME_REGEX.match(line)
        if m != None:
            results.cpu_time = float(m.group(1))
            break
    
    return results

def parse_maplelcm(log_lines):
    SECTION_REGEX        = re.compile(r'c ={75}')
    CPU_TIME_REGEX       = re.compile(r'real (\d+\.\d+)')
    SATISFIABILITY_REGEX = re.compile(r's (.+)')
    RESTARTS_REGEX       = re.compile(r'c restarts\s+:\s+(\d+)')
    CONFLICTS_REGEX      = re.compile(r'c conflicts\s+:\s+(\d+)')
    DECISIONS_REGEX      = re.compile(r'c decisions\s+:\s+(\d+)')
    PROPAGATIONS_REGEX   = re.compile(r'c propagations\s+:\s+(\d+)')
    CONF_LITS_REGEX      = re.compile(r'c conflict literals\s+:\s+(\d+)')
    MEM_USED_REGEX       = re.compile(r'c Memory used\s+:\s+(\d+\.\d+) MB')

    results = SolverResults()

    # Skip to results
    i = 0
    while SECTION_REGEX.match(log_lines[i]) == None: i = i + 1
    i = i + 1
    while SECTION_REGEX.match(log_lines[i]) == None: i = i + 1
    # while i < len(log_lines) and SECTION_REGEX.match(log_lines[i]) == None: i = i + 1
    # if i == len(log_lines) or SECTION_REGEX.match(log_lines[i]) == None: return results
    # Parse stats
    results.restarts     = RESTARTS_REGEX    .match(log_lines[i + 1]).group(1)
    results.conflicts    = CONFLICTS_REGEX   .match(log_lines[i + 2]).group(1)
    results.decisions    = DECISIONS_REGEX   .match(log_lines[i + 3]).group(1)
    results.propagations = PROPAGATIONS_REGEX.match(log_lines[i + 4]).group(1)
    results.conf_lits    = CONF_LITS_REGEX   .match(log_lines[i + 5]).group(1)
    results.mem_used     = float(MEM_USED_REGEX    .match(log_lines[i + 6]).group(1)) * 2**20

    i = i + 7

    # Read satisifiability
    while SATISFIABILITY_REGEX.match(log_lines[i]) == None: i = i + 1
    results.satisfiability = SATISFIABILITY_REGEX.match(log_lines[i]).group(1)

    if results.satisfiability != GLOBAL_SAT and results.satisfiability != GLOBAL_UNSAT:
        results.satisfiability = GLOBAL_INDET

    # Read CPU time
    for line in log_lines[i:]:
        m = CPU_TIME_REGEX.match(line)
        if m != None:
            results.cpu_time = float(m.group(1))
            break

    return results
    
if __name__ == '__main__':
    if len(sys.argv) != 6:
        print(f"Usage: {sys.argv[0]} <INSTANCE_LIST> <LOG_DIR> <SOLVER_NAME> <START_INDEX> <NUM_FILES>")
        exit(1)

    # Check whether instance list exists
    instance_list = sys.argv[1]
    if not os.path.isfile(instance_list):
        print(f"Could not find file {instance_list}")
        exit(1)

    # Check whether log directory exists
    log_dir = sys.argv[2]
    if not os.path.isdir(log_dir):
        print(f"Could not find directory {log_dir}")
        exit(1)

    solver_name = sys.argv[3]

    # Read list of instances and check whether start/end are valid
    instances = [line.strip() for line in open(instance_list).readlines()]

    start_index = int(sys.argv[4])
    if start_index < 0 or start_index >= len(instances):
        print(f"Expected start index to be between 0 and {len(instances) - 1}")
        exit(1)

    num_files = int(sys.argv[5])
    if num_files < 1 or num_files > len(instances) - start_index:
        print(f"Expected num files to be between {1} and {len(instances) - start_index}")
        exit(1)
    end_index = start_index + num_files

    # Remove instance location prefix
    PREFIX = '/data/priority_bcp/instances/'
    for i in range(start_index, end_index):
        instance = instances[i]
        if not instance.startswith(PREFIX):
            print(f"Instance {i} does not start with expected prefix: '{instance}'")
            exit(1)
    instances = [line[len(PREFIX):] for line in instances]

    parser = None
    if solver_name.startswith('kissat'):
        parser = parse_kissat
    elif solver_name.startswith('maplelcm'):
        parser = parse_maplelcm
    else:
        print(f"Solver '{solver_name}' is not supported!")
        exit(1)
    
    # Parse log files
    for i in range(start_index, end_index):
        log_file = f"{log_dir}/out_{solver_name}_{i+1}.log"
        log_lines = [line.strip() for line in open(log_file).readlines()]

        try:
            results = parser(log_lines)
        except Exception as e:
            results = SolverResults()

        print(f"{solver_name},{instances[i]},{results}")

    # print(instances)