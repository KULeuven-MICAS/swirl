import unittest
import importlib
import numpy as np


model = importlib.import_module("highLevelModel")


class MultiplyTestCase(unittest.TestCase):

    def test_2x2x2_ones(self):
        A = np.ones((2, 2), dtype=int)
        B = np.ones((2, 2), dtype=int)
        C = np.ones((2, 2), dtype=int)
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 2, 8)
        self.assertTrue(np.array_equal(D, np.array([[3, 3], [3, 3]])))
    
    def test_2x2x2_zeros(self):
        A = np.zeros((2, 2), dtype=int)
        B = np.zeros((2, 2), dtype=int)
        C = np.zeros((2, 2), dtype=int)
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 2, 8)
        self.assertTrue(np.array_equal(D, np.array([[0, 0], [0, 0]])))

    def test_2x2x2_eye(self):
        A = np.eye(2, dtype=int)
        B = np.eye(2, dtype=int)
        C = np.eye(2, dtype=int)
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 2, 8)
        self.assertTrue(np.array_equal(D, np.array([[2, 0], [0, 2]])))

    def test_8x4x16_range(self):
        A = np.arange(8 * 16, dtype=int).reshape(8, 16)
        B = np.arange(4 * 16, dtype=int).reshape(16, 4)
        C = np.zeros((8, 4), dtype=int)
        D = model.matrix_multiplication_accumulation(A, B, C, 8, 4, 16, 8)
        self.assertTrue(np.array_equal(D, np.matmul(A, B) + C))

    def test_overflow(self):
        A = np.ones((2, 67000), dtype=int) * 255
        B = np.ones((67000, 2), dtype=int) * 255
        C = np.ones((2, 2), dtype=int) * 255
        D = model.matrix_multiplication_accumulation(A, B, C, 2, 2, 67000, 8)
        sat_val = 2**32-1  # Saturated value = max value
        self.assertTrue(np.array_equal(
            D, np.array([[sat_val, sat_val], [sat_val, sat_val]]))
            )