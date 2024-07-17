import numpy as np


def bitwise_add(a, b, precision):
    sum = a + b
    if ((sum) >> precision):  # If true, there is overflow
        return (2 ** precision - 1)  # Return saturated value
    else:
        return sum


def bitwise_multiply(multiplicand, multiplier, precision):
    result = 0
    for i in range(precision):
        if multiplier & 1 << i:
            result += multiplicand << i
    return result


def matrix_multiplication_accumulation(A, B, C, M, N, K, P):
    D = np.copy(C)
    for column in range(N):
        for row in range(M):
            for element in range(K):
                D[row, column] = bitwise_add(
                    D[row, column], 
                    bitwise_multiply(
                        A[row][element], 
                        B[element][column], P), 4*P) 
    return D