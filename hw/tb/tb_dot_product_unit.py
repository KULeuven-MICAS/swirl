# input generator for dot product unit given a certainy amount of sparsity
# makes testdatadotp.txt with on the first line in1 in the format {{}, {}, {}, {},...}
#   the same for in2 on the second line

import numpy as np
import os


def save_matrices_to_file(A, B, outputs, filepath):
    with open(filepath, 'w') as f:
        # Format: 1 input of A and one of B in curly-braces and seperated by a space
        for a_row, b_row, output_row in zip(A, B, outputs):
            formatted_line = (
                '{' + ', '.join(map(str, a_row)) + '} {' + ', '.join(map(str, b_row)) + '}'
                + ' ' + str(output_row)
            )
            f.write(formatted_line + '\n')


def generate_input_data(sparsity, num_elements, DATAW, num_tests, filepath):
    # Generate random data
    # limit_under = -2**(DATAW-1)
    # limit_over = 2**(DATAW-1) - 1
    A_list = []
    B_list = []
    output_list = []

    for i in range(num_tests):
        A = np.random.randint(low=-128, high=128, size=num_elements)
        B = np.random.randint(low=-128, high=128, size=num_elements)

        # Apply sparsity
        num_zeros = int(sparsity * num_elements)
        A[:num_zeros] = 0
        B[:num_zeros] = 0

        # Shuffle
        np.random.shuffle(A)
        np.random.shuffle(B)

        # Store output of dot product in output_list
        output = np.dot(A, B)

        A_list.append(A.tolist())
        B_list.append(B.tolist())
        output_list.append(output)

    return A_list, B_list, output_list


if __name__ == '__main__':
    sparsity = 0.6
    num_elements = 8
    DATAW = 8
    num_tests = 20
    filepath = os.path.join(os.path.dirname(__file__), 'testdatadotp.txt')

    A, B, outputs = generate_input_data(sparsity, num_elements, DATAW, num_tests, filepath)
    save_matrices_to_file(A, B, outputs, filepath)
