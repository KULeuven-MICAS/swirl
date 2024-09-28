// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>

`ifndef DATAW
`define DATAW 8
`endif

`ifndef PIPES
`define PIPES 0
`endif

typedef struct packed {
    int dataa;
    int datab;
    int correct_sum;
} test_vector_t;

`define NUM_TESTS 6

test_vector_t smoke_test_nul = '{0, 0, 0};
test_vector_t smoke_test_pos = '{1, 2, 3};
test_vector_t smoke_test_neg = '{-1, -2, -3};
test_vector_t smoke_test_mix = '{-1, 2, 1};

//test_vector_t random_test = '{$urandom(), $urandom(), $urandom()};

test_vector_t test_ovf_pos = '{2**(`DATAW-1)-1, 1, 2**(`DATAW-1)-1};
test_vector_t test_ovf_neg = '{-2**(`DATAW-1), -1, -2**(`DATAW-1)};

// typedef enum test_codes {
//     SMOKE_TEST_NUL,
//     SMOKE_TEST_POS,
//     SMOKE_TEST_NEG,
//     SMOKE_TEST_MIX,
//     RANDOM_TEST,
//     TEST_OVF_POS,
//     TEST_OVF_NEG
// } test_codes_t;

test_vector_t test_vectors[`NUM_TESTS] = {
    smoke_test_nul,
    smoke_test_pos,
    smoke_test_neg,
    smoke_test_mix,
    test_ovf_pos,
    test_ovf_neg
};
