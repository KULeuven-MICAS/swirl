from parsers import ParserClass

parser = ParserClass()
file_list = []
vars_dict = {}

with open(parser.args.file, 'r') as file:
    IN_FILE_LIST = False
    for line in file:
        # MAybe try 'endswith(list)' instead of 'startswith'
        if line.startswith('set HDL_FILES') or line.startswith('set INCLUDE_DIRS'):
            IN_FILE_LIST = True
            continue
        elif line.startswith(']'):
            IN_FILE_LIST = False
        elif line.startswith('set'):
            var, value = line.split()[1:]
            vars_dict[var] = value

        if IN_FILE_LIST:
            file_list.append(line.strip().split()[0].strip('"'))

# Substitute variables ${VARS} in file_list with values from vars_dict
exp_file_list = []
for file in file_list:
    for var in vars_dict.keys():
        if '${' + var + '}' in file:
            file = file.replace('${' + var + '}', vars_dict[var])
    exp_file_list.append(file)

file_list_str = ' '.join(exp_file_list)

print(file_list_str)
