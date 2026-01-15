import subprocess
import os
import sys
import concurrent.futures
import itertools
import yaml
import time

# Specify the path to openscad.exe
openscad_path = os.environ.get('OPENSCAD', 'C:/Program Files/OpenSCAD (Nightly)/openscad.exe')

# Check if openscad.exe exists
if not os.path.isfile(openscad_path):
    print(f"Error: openscad.exe not found at {openscad_path}")
    sys.exit(1)

# Define the output directory
output_dir = 'Output3MF'

# Create the directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Add variables for parallel processing
parallel = True
num_processes = 15

# Initialize counters for logging
error_count = 0
success_count = 0
start_time = time.time()

def generate_output(task):
    global error_count, success_count
    scad_file = task['scad_file']
    params = task['params']
    output_file = os.path.join(output_dir, task['output_file'])
    command = [
        openscad_path,
        '--enable=lazy-union',
        '-o', output_file
    ]
    # Ensure manifold and lazy_unions are enabled
    command.extend(['--backend=manifold'])
    for key, value in params.items():
        if isinstance(value, list):
            value = value[0]  # Fix for list values
        if isinstance(value, (int, float)):
            command.extend(['-D', f'{key}={value}'])
        else:
            command.extend(['-D', f'{key}="{value}"'])
    command.append(scad_file)
    # Log the raw task call
    #print(f"Executing command: {' '.join(command)}")
    # Call openscad.exe and handle errors
    try:
        subprocess.run(command, check=True)
        print(f"Generated {output_file}")
        success_count += 1
    except subprocess.CalledProcessError as e:
        print(f"Error generating {output_file}: {e}")
        error_count += 1
        sys.exit(1)

if __name__ == "__main__":
    # Load configurations from YAML file
    with open('configuration.yaml', 'r') as file:
        config = yaml.safe_load(file)
    tasks = []
    for scad in config['scad_files']:
        if not scad.get('enabled', True):
            continue  # Skip if the SCAD file is not enabled
        scad_file = scad['filename']
        output_prefix = scad.get('output_prefix', '')
        parameters = scad['parameters']
        for group in scad['groups']:
            if not group.get('enabled', True):
                continue  # Skip if the group is not enabled
            fixed_params = group['fixed_parameters']
            variable_params = {k: parameters[k] for k in group.get('variable_parameters', [])}
            output_folder = group.get('output_folder', '')
            if variable_params:
                param_names, param_values = zip(*variable_params.items())
                combinations = itertools.product(*param_values)
            else:
                param_names = []
                combinations = [()]
            for values in combinations:
                params = dict(zip(param_names, values)) if variable_params else {}
                params.update(fixed_params)
                output_file = os.path.join(output_folder, output_prefix)
                os.makedirs(os.path.join(output_dir, output_folder), exist_ok=True)
                param_order = config.get('parameter_order', [])
                ordered_params = {k: params[k] for k in param_order if k in params}
                for key, value in ordered_params.items():
                    if isinstance(value, list):
                        value = value[0]  # Fix for list values
                    param_prefix = config['parameter_prefixes'].get(key, key)
                    value_abbreviation = config['value_abbreviations'].get(value, value)
                    output_file += f'_{param_prefix}{value_abbreviation}'
                output_file += '.3mf'
                task = {
                    'scad_file': scad_file,
                    'params': params,
                    'output_file': output_file
                }
                tasks.append(task)
    # Modify the loop to run in parallel if enabled
    if parallel:
        with concurrent.futures.ProcessPoolExecutor(max_workers=num_processes) as executor:
            executor.map(generate_output, tasks)
    else:
        for task in tasks:
            generate_output(task)
    
    # Calculate total and average time
    end_time = time.time()
    total_time = end_time - start_time
    average_time = total_time / (success_count + error_count) if (success_count + error_count) > 0 else 0

    # Log summary
    print(f"Summary:")
    print(f"Total files generated: {success_count}")
    print(f"Total errors encountered: {error_count}")
    print(f"Total time taken: {total_time:.2f} seconds")
    print(f"Average time per file: {average_time:.2f} seconds")
