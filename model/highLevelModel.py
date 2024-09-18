import numpy as np


def adder(a, b, precision):
    sum = a + b
    if (not a & np.int32(1) << (precision-1) and
       not b & np.int32(1) << (precision-1) and
       sum & np.int32(1) << (precision-1)):  # Check positive overflow
        return (2 ** (precision - 1) - 1)  # Return positive saturated value
    elif (a & np.int32(1) << (precision-1) and
          b & np.int32(1) << (precision-1) and
          not sum & np.int32(1) << (precision-1)):  # Check negative overflow
        return -(2 ** (precision - 1))  # Return negative saturated value
    else:
        return sum


def multiply(multiplicand, multiplier):
    multiplicand = np.int32(multiplicand)  # Extend to 32 bits
    multiplier = np.int32(multiplier)
    return multiplicand * multiplier


def matrix_multiplication_accumulation(A, B, C, M, N, K, P):
    D = np.copy(C)
    for column in range(N):
        for row in range(M):
            for element in range(K):
                D[row, column] = adder(
                    D[row, column],
                    multiply(
                        A[row][element],
                        B[element][column]), 4*P)
    return D
