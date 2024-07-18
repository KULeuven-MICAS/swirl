import unittest
import importlib
import numpy as np


model = importlib.import_module("highLevelModel")


class MultiplyTestCase(unittest.TestCase):

    def test_2x2x2_ones(self):
        A = np.ones((2, 2), dtype=np.int8)
        B = np.ones((2, 2), dtype=np.int8)
        C = np.ones((2, 2), dtype=np.int32)
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 2, 8)
        self.assertTrue(np.array_equal(D, np.array([[3, 3], [3, 3]])))
    
    def test_2x2x2_zeros(self):
        A = np.zeros((2, 2), dtype=np.int8)
        B = np.zeros((2, 2), dtype=np.int8)
        C = np.zeros((2, 2), dtype=np.int32)
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 2, 8)
        self.assertTrue(np.array_equal(D, np.array([[0, 0], [0, 0]])))

    def test_2x2x2_eye(self):
        A = np.eye(2, dtype=np.int8)
        B = np.eye(2, dtype=np.int8)
        C = np.eye(2, dtype=np.int32)
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 2, 8)
        self.assertTrue(np.array_equal(D, np.array([[2, 0], [0, 2]])))

    def test_8x4x16_range_positive(self):
        A = np.arange(8 * 16, dtype=np.int8).reshape(8, 16)
        B = np.arange(4 * 16, dtype=np.int8).reshape(16, 4)
        C = np.zeros((8, 4), dtype=np.int32)
        D = model.matrix_multiplication_accumulation(A, B, C, 8, 4, 16, 8)
        self.assertTrue(np.array_equal(
              D, np.matmul(np.int32(A), np.int32(B)) + C))
        
    def test_8x4x16_range_negative(self):
        A = np.arange(8 * 16, dtype=np.int8).reshape(8, 16) * -1
        B = np.arange(4 * 16, dtype=np.int8).reshape(16, 4)
        C = np.zeros((8, 4), dtype=np.int32)
        D = model.matrix_multiplication_accumulation(A, B, C, 8, 4, 16, 8)
        self.assertTrue(np.array_equal(
              D, np.matmul(np.int32(A), np.int32(B)) + C))

    def test_overflow_positive(self):
        A = np.ones((1, 134000), dtype=np.int8) * 127
        B = np.ones((134000, 1), dtype=np.int8) * 127
        C = np.ones((1, 1), dtype=np.int32) * 127
        D = model.matrix_multiplication_accumulation(A, B, C, 1, 1, 134000, 8)
        sat_val = 2**31-1  # Saturated value = max value
        self.assertTrue(np.array_equal(
            D, np.array([[sat_val]]))
            )
        
    def test_overflow_negative(self):
        A = np.ones((1, 134000), dtype=np.int8) * -127
        B = np.ones((134000, 1), dtype=np.int8) * 127
        C = np.ones((1, 1), dtype=np.int32) * 127
        D = model.matrix_multiplication_accumulation(A, B, C, 1, 1, 134000, 8)
        sat_val = -2**31  # Saturated value = min value
        self.assertTrue(np.array_equal(
            D, np.array([[sat_val]]))
            )
    
    def test_random(self):
        A = np.random.random_integers(-128, 127, 8 * 16).reshape(8, 16)
        B = np.random.random_integers(-128, 127, 4 * 16).reshape(16, 4)
        C = np.random.random_integers(-128, 127, 8 * 4).reshape(8, 4)
        D = model.matrix_multiplication_accumulation(A, B, C, 8, 4, 16, 8)
        self.assertTrue(np.array_equal(
              D, np.matmul(np.int32(A), np.int32(B)) + C))
        

if __name__ == "__main__":
    unittest.main()