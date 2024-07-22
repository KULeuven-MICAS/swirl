import numpy as np
import os


def save_matrices_to_file(A, B, C, D, filepath):

    with open(filepath, 'a') as f:
        M = A.shape[0]
        N = B.shape[1]
        K = A.shape[1]
        f.write(str(M) + " " + str(N) + " " + str(K) + "\n")
        for row in A:
            f.write(' '.join(map(str, row.flat)) + '\n')
        for row in B:
            f.write(' '.join(map(str, row.flat)) + '\n')
        for row in C:
            f.write(' '.join(map(str, row.flat)) + '\n')
        for row in D:
            f.write(' '.join(map(str, row.flat)) + '\n')


if __name__ == '__main__':
    
    directory = "./test_data"
    filename = 'matrix_data_2x2.txt'
    filepath = os.path.join(directory, filename)

    # Ensure the directory exists
    os.makedirs(directory, exist_ok=True)

    with open(filepath, 'w') as f:
        pass  # Opening in 'w' mode clears the file

    A = np.matrix([[1, 2], [3, 4]])
    B = np.matrix([[1, 2], [3, 4]])
    C = np.matrix([[1, 2], [3, 4]])
    D = np.matrix([[8, 12], [18, 26]])
    save_matrices_to_file(A, B, C, D, filepath)
    A = np.matrix([[1, 1], [1, 1]])
    B = np.matrix([[1, 1], [1, 1]])
    C = np.matrix([[1, 1], [1, 1]])
    D = np.matrix([[3, 3], [3, 3]])
    save_matrices_to_file(A, B, C, D, filepath)