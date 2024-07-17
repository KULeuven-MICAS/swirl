import numpy as np


def bitwise_add(a, b, precision):
    sum = a + b
    if (not a & 1 << (precision-1) and
       not b & 1 << (precision-1) and
       sum & 1 << (precision-1)):  # Check positive overflow
        return (2 ** (precision - 1) - 1)  # Return positive saturated value
    elif (a & 1 << (precision-1) and
          b & 1 << (precision-1) and
          not sum & 1 << (precision-1)):  # Check for negative overflow
        return -(2 ** (precision - 1))  # Return negative saturated value
    else:
        return sum


def bitwise_multiply(multiplicand, multiplier, precision):
    result = np.int16(0)
    multiplicand = np.int16(multiplicand) # Extend to signed int16
    multiplier = np.int16(multiplier)
    for i in range(2 * precision):
        if multiplier & 1 << i:
            result += multiplicand << i
    return np.int16(result)


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


def main():
    print(bitwise_multiply(-5, -5, 8))


if __name__ == "__main__":
    main()