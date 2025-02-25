import re

def convert_saif_questa_to_cadence(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    cadence_saif = []
    module_hierarchy = []
    
    for line in lines:
        line = line.strip()
        
        # Convert hierarchy from QuestaSim to Cadence style (if needed)
        line = re.sub(r'/', '.', line)  # Replace / with . for hierarchy
        
        # Handling hierarchy begin/end
        if line.startswith('(INSTANCE '):
            module_name = line.split()[1]
            module_hierarchy.append(module_name)
            cadence_saif.append(line)
        elif line.startswith(')'):  # Closing a module
            if module_hierarchy:
                module_hierarchy.pop()
            cadence_saif.append(line)
        else:
            cadence_saif.append(line)
    
    with open(output_file, 'w') as f:
        f.write('\n'.join(cadence_saif))
    
    print(f'Converted SAIF file saved as {output_file}')

# Example usage
convert_saif_questa_to_cadence('tb_dot_product_unit.saif', 'converted_cadence.saif')
