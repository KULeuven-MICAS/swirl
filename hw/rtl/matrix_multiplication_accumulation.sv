// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Module performing a matrix multiplication and accumulation operation: D = A * B + C
// with dimensions: A[M][K], B[K][N], C[M][N], D[M][N]
// Three different implementations are supported, configured using MODE:
// 0: Single-precision design, supporting only P-bit input for A and B
// 1: Partitioned design, supporting 8-/4-bit symmetric input for A and B
// 2: Sequential design, supporting 2- to 14-bit and assymetric input for A and B
// For MODE=0 the design can be configured to use a tree adder or chain adder for the accumulation operation,
// other designs use a tree adder.
//
// Parameters:
// - M: number of rows of the A matrix
// - N: number of columns of the B matrix
// - K: number of columns of the A matrix and rows of the B matrix
// - P: number of bits of the input data
// - TREE: 1 if the tree adder is used, 0 if chain adder is used
// - PIPESTAGES: number of pipeline stages, 1 means no extra pipeline registers
// - MODE: 0 for unpartitioned design, 1 for partitioned design, 2 for sequential design

module matrix_multiplication_accumulation #(
    parameter int M,
    parameter int N,
    parameter int K,
    parameter int P,
    parameter int TREE = 1,
    parameter int PIPESTAGES = 2,
    parameter int MODE,
    parameter int MANUAL_PIPELINE = 0
)(
    
    // Input and output matrices
    input wire signed [P-1:0] A [M][K],
    input wire signed [P-1:0] B [K][N],
    input wire signed [31:0] C [M][N],
    output wire signed [31:0] D [M][N],

    // Handshake signals
    input wire valid_in, ready_out,
    output wire ready_in, valid_out,

    // Clock and reset signals
    input wire clk_i,
    input wire rst_ni,

    // Used in partitioned design, 1 if halved precision is used
    input wire [1:0] halvedPrecision = 0,

    // Used in sequential design, bit size !DIVIDED BY 2! of the input data
    input wire [3:0] bitSizeA = 4,
    input wire [3:0] bitSizeB = 4
);

    
    logic signed [P-1:0] A_mul [M][K];
    logic signed [P-1:0] B_mul [K][N];
    logic signed [31:0] C_mul [M][N];
    assign A_mul = A;
    assign B_mul = B;
    assign C_mul = C;

    if (MODE == 0 | MODE == 1) begin : gen_pipeline_combinatorial
        assign ready_in = ready_out;
        assign valid_out = valid_in;
    end

    if (MODE == 0) begin : gen_non_config
        // Chain implementation
        if (TREE == 0) begin : gen_chain_adder
            genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : gen_column_block
                for (row = 0; row < M; row = row + 1) begin: gen_row_block
                    logic [31:0] temp_sum[K+1];
                    assign temp_sum[0] = C_mul[row][column];
                    for (element = 0; element < K; element = element + 1) begin : gen_element_block
                        logic [31:0] mult;
                        assign mult = A_mul[row][element] * B_mul[element][column];
                        bitwise_add #(
                            .P(32)
                            ) add (
                                .a(temp_sum[element]),
                                .b(mult),
                                .sum(temp_sum[element+1])
                            );
                    end // gen_element_block
                    assign D[row][column] = temp_sum[K];
                end // gen_row_block
            end // gen_column_block
        end
        // Tree implementation
        else begin : gen_tree_adder
            genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : gen_column_block
                for (row = 0; row < M; row = row + 1) begin: gen_row_block
                    logic [2*P-1:0] mults [K];
                    for (element = 0; element < K; element = element + 1) begin : gen_element_block
                        assign mults[element] = A_mul[row][element] * B_mul[element][column];
                    end // gen_element_block

                    logic signed [31:0] mult_sum;
                    logic signed [31:0] sum;

                    binary_tree_adder #(
                        .P(2*P),
                        .INPUTS_AMOUNT(K),
                        .MODE(0) // signed mode
                    ) tree_add (
                        .inputs(mults),
                        .out_32bit(mult_sum),
                        .out(), // not used
                        .signedAddition() // not used
                    );

                    bitwise_add #(
                        .P(32)
                    ) C_add (
                        .a(mult_sum),
                        .b(C_mul[row][column]),
                        .sum(sum)
                    );

                    assign D[row][column] = sum;
                end // gen_row_block
            end // gen_column_block
        end
    end else if (MODE == 1) begin : gen_partitioned
        genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : gen_column_block
                for (row = 0; row < M; row = row + 1) begin: gen_row_block
                    logic [2*P-1:0] mults [K];
                    for (element = 0; element < K; element = element + 1) begin : gen_element_block
                        config_multiplier_8bit mult (
                            .multiplier(A_mul[row][element]),
                            .multiplicand(B_mul[element][column]),
                            .product(mults[element]),
                            .halvedPrecision(halvedPrecision)
                        );

                    end

                    logic [31:0] mult_sum;
                    logic [31:0] sum;

                    config_binary_tree_adder #(
                        .P(2*P),
                        .INPUTS_AMOUNT(K)
                    ) tree_add (
                        .inputs(mults),
                        .out(mult_sum),
                        .halvedPrecision(halvedPrecision[1])
                    );

                    bitwise_add #(
                        .P(32)
                    ) C_add (
                        .a(mult_sum),
                        .b(C_mul[row][column]),
                        .sum(sum)
                    );

                    assign D[row][column] = sum;
                end // gen_row_block
            end // gen_column_block
    end else if (MODE == 2) begin : gen_sequential

        logic signed [15:0] A_seq [M][K];
        logic signed [15:0] B_seq [K][N];

        genvar i, j;
        // Padding the input matrices to 16 bits
        for ( i = 0; i < M; i = i + 1) begin : gen_seq_A_padding_row
            for ( j = 0; j < K; j = j + 1) begin : gen_seq_A_padding_column
                assign A_seq[i][j] = {{(16-P){1'b0}}, A_mul[i][j]};
            end
        end
        for ( i = 0; i < K; i = i + 1) begin : gen_seq_B_padding_row
            for ( j = 0; j < N; j = j + 1) begin : gen_seq_B_padding_column
                assign B_seq[i][j] = {{(16-P){1'b0}}, B_mul[i][j]};
            end
        end
        seq_MAC #(
            .M(M),
            .N(N),
            .K(K),
            .P(2),
            .MAX_WIDTH(16),
            .MANUAL_PIPELINE(MANUAL_PIPELINE)
        ) seq_MAC (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .A_mul(A_seq),
            .B_mul(B_seq),
            .C_mul(C_mul),
            .D(D),
            .valid_in(valid_in),
            .ready_in(ready_in),
            .valid_out(valid_out),
            .ready_out(ready_out),
            .bitSizeA(bitSizeA),
            .bitSizeB(bitSizeB)
        );
    end

endmodule
