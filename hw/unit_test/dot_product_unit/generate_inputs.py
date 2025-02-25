import random
import numpy as np

def generate_test_case(sparsity=0.5):
    assert 0 <= sparsity <= 1, "Sparsity should be between 0 and 1"
    
    size = 8  # Number of elements per input vector
    range_min, range_max = -128, 127  # 8-bit 2's complement range
    
    # Generate random vectors
    vec_a = [random.randint(range_min, range_max) for _ in range(size)]
    vec_b = [random.randint(range_min, range_max) for _ in range(size)]
    
    # Apply sparsity (set some values to zero)
    num_zero_a = int(sparsity * size)
    num_zero_b = int(sparsity * size)
    
    zero_indices_a = random.sample(range(size), num_zero_a)
    zero_indices_b = random.sample(range(size), num_zero_b)
    
    for idx in zero_indices_a:
        vec_a[idx] = 0
    for idx in zero_indices_b:
        vec_b[idx] = 0
    
    # Compute dot product
    dot_product = np.dot(vec_a, vec_b)
    
    return vec_a, vec_b, dot_product

def generate_dataset(num_cases=10, sparsity=0.5):
    vec_a_list = []
    vec_b_list = []
    results = []
    
    for _ in range(num_cases):
        vec_a, vec_b, dot_product = generate_test_case(sparsity)
        vec_a_list.append(vec_a)
        vec_b_list.append(vec_b)
        results.append(dot_product)
    
    return vec_a_list, vec_b_list, results

def main():
    num_cases = 5000  # Number of test cases
    sparsity = 0.6  # Sparse vectors
    
    vec_a_list, vec_b_list, results = generate_dataset(num_cases, sparsity)
    vec_a_list = str(vec_a_list)
    vec_b_list = str(vec_b_list)
    
    # print("{")
    vec_a_list = vec_a_list.replace("[", "{").replace("]", "}")
    # print(vec_a_list)
    # print("\n")
    vec_b_list = vec_b_list.replace("[", "{").replace("]", "}")
    # print(vec_b_list)
    # print("\n")
    # print("  {", ", ".join(map(str, results)), "}")
    # print("}")

    f = open("inputsa.txt", "w")
    f.write(vec_a_list)
    f.close()
    f = open("inputsb.txt", "w")
    f.write(vec_b_list)
    f.close()
    f = open("output.txt", "w")
    f.write("  {")
    f.write(", ".join(map(str, results)))
    f.write("}")
    f.close()

if __name__ == "__main__":
    main()
