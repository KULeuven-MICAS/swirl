import numpy as np

M = 2
N = 2
K = 2
P = 8
T = 32


def bitwise_add(a, b, precision):
    if ((a+b) >> precision):
        print("Overflow")
        return (a+b >> 1)
    else:
        return a+b


def bitwise_multiply(multiplicand, multiplier, precision):
    result = 0
    for i in range(precision):
        if multiplier & 1 << i:
            result += multiplicand << i
    return result


def matrix_multiplication_accumulation(A, B, C, M, N, K, P):
    for column in range(N):
        for row in range(M):
            for element in range(K):
                C[row, column] = bitwise_add(
                    C[row, column], 
                    bitwise_multiply(
                        A[row][element], 
                        B[element][column], P), 4*P) 
    return C

     
def main():
    A = np.array([[1, 2], [3, 4]])
    B = np.array([[1, 2], [3, 4]])
    C = np.array([[1, 2], [3, 4]])
    D = matrix_multiplication_accumulation(A, B, C, M, N, K, P)
    print(D)


if __name__ == "__main__":
    main()