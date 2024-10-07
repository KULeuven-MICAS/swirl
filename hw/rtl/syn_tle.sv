// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Top level module used for synthesis of matrix_multiplication_accumulation module
// with input/output buffers and ready valid logic
//
// Parameters:
// - M: number of rows of the A matrix
// - N: number of columns of the B matrix
// - K: number of columns of the A matrix and rows of the B matrix
// - P: number of bits of the input data
// - TREE: 1 if the tree adder is used, 0 if chain adder is used
// - PIPESTAGES: number of pipeline stages, 1 means no extra pipeline registers
// - MODE: 0 for unpartitioned design, 1 for partitioned design, 2 for sequential design

`ifndef P
`define P 8
`endif
`ifndef M
`define M 8
`endif
`ifndef N
`define N 4
`endif
`ifndef K
`define K 16
`endif
`ifndef TREE
`define TREE 1
`endif
`ifndef PIPESTAGES
`define PIPESTAGES 2
`endif
`ifndef MODE
`define MODE 2
`endif
`ifndef MANUAL_PIPELINE
`define MANUAL_PIPELINE 0
`endif


module syn_tle #(
    parameter int M = `M,
    parameter int N = `N,
    parameter int K = `K,
    parameter int P = `P,
    parameter int PIPESTAGES = `PIPESTAGES,
    parameter bit TREE = `TREE,
    parameter bit MODE = `MODE,
    parameter logic MANUAL_PIPELINE = `MANUAL_PIPELINE
)(
    input logic clk_i,
    input logic rst_ni,
    input wire signed [P-1:0] A_i [M][K],
    input wire signed [P-1:0] B_i [K][N],
    input wire signed [31:0] C_i [M][N],
    input logic valid_i,
    input logic ready_o,
    input logic halvedPrecision,
    input logic [3:0] bitSizeA = 4,
    input logic [3:0] bitSizeB = 4,
    output logic signed [31:0] D_o [M][N],
    output logic ready_i,
    output logic valid_o
);

    logic signed [P-1:0] A_d [M][K];
    logic signed [P-1:0] A_in_matmul [M][K];
    logic signed [P-1:0] B_d [K][N];
    logic signed [P-1:0] B_in_matmul [K][N];
    logic signed [31:0] C_d [M][N];
    logic signed [31:0] C_in_matmul [M][N];
    logic signed [31:0] D_out_matmul [M][N];
    logic signed [31:0] D_q [M][N];

    // Elastic pipeline logic
    logic valid_o_matmul, ready_o_matmul, valid_i_matmul, ready_i_matmul;


    // Input assignment
    // Regroup B matrix elements for partitioned input

    if (MODE==1) begin : gen_partitioned_input
        genvar row, column;
        for (row = 0; row < K; row++) begin : gen_column_loop
            for (column = 0; column < N; column++) begin : gen_row_loop
                localparam int Index = N + column;
                always_comb begin
                    if (halvedPrecision) begin
                        if (column % 2 == 0) begin
                            B_d[row][column][P-1:P/2] = B_i[row][column/2][P-1:P/2];
                        end else begin
                            B_d[row][column][P-1:P/2] = B_i[row][column/2][P/2-1:0];
                        end

                        if (Index % 2 == 0) begin
                            B_d[row][column][P/2-1:0] = B_i[row][Index/2][P-1:P/2];
                        end else begin
                            B_d[row][column][P/2-1:0] = B_i[row][Index/2][P/2-1:0];
                        end
                    end else begin
                        B_d[row][column] = B_i[row][column];
                    end
                end
            end
        end
    end else begin : gen_unpartitioned_input
        assign B_d = B_i;
    end

    assign A_d = A_i;
    assign C_d = C_i;
    assign D_o = D_q;


    initial begin
        // $dumpfile($sformatf("syn_tle.vcd"));
        // $dumpvars(0, syn_tle);

        // $monitor("At time %t, D_o = %p, A_i = %p, B_i = %p, C_i = %p", $time, D_o, A_i, B_i, C_i);
        // $monitor("At time %t, A_in_matmul = %p, B_in_matmul = %p, C_in_matmul = %p", $time, A_in_matmul, B_in_matmul, C_in_matmul);
        // $monitor("At time %t, A_stage0 = %p, A_stage1 = %p, D_o = %p, ready_o = %p, valid_i = %p, valid_o = %p",
        // $time, A_stage[0], A_stage[1], D_o, ready_o, valid_i, valid_o);
        //  $monitor("At time %t, ready_i = %p, valid_o = %p, reset = %p, D_o = %p",
        //  $time, ready_i, valid_o, rst_ni, D_o);
        // $monitor("At time %t, ready_i = %p, ready_i_matmul = %p, ready_o_matmul = %p, valid_i = %p, valid_i_matmul = %p,  valid_o_matmul = %p",
        // $time, ready_i, ready_i_matmul,  ready_o_matmul, valid_i, valid_i_matmul,valid_o_matmul);
    end

    // Elastic pipeline logic
    localparam int TotalWidthA = M * K * P;
    localparam int TotalWidthB = K * N * P;
    localparam int TotalWidthC = M * N * 4 * P;
    localparam int TotalWidthD = M * N * 4 * P;
    localparam int TotalWidth = TotalWidthA + TotalWidthB + TotalWidthC;

    logic [TotalWidth-1:0] data_in;
    logic [TotalWidthD-1:0] data_out;

    logic signed [P-1:0] A_stage [PIPESTAGES] [M][K];
    logic signed [P-1:0] B_stage [PIPESTAGES] [K][N];
    logic signed [31:0] C_stage [PIPESTAGES] [M][N];

    logic valid_stage[PIPESTAGES];
    logic ready_stage[PIPESTAGES];
    logic [TotalWidth-1:0] data_stage [PIPESTAGES];



    matrix_flattener #(.WIDTH(K),.HEIGHT(M),.P(P)
    ) A_flattener_input (
        .A(A_d),
        .data_out(data_in[TotalWidthA-1:0])
    );

    matrix_flattener #(.WIDTH(N),.HEIGHT(K),.P(P)
    ) B_flattener_input (
        .A(B_d),
        .data_out(data_in[TotalWidthA+TotalWidthB-1:TotalWidthA])
    );

    matrix_flattener #(.WIDTH(N),.HEIGHT(M),.P(32)
    ) C_flattener_input (
        .A(C_d),
        .data_out(data_in[TotalWidthA+TotalWidthB+TotalWidthC-1:TotalWidthA+TotalWidthB])
    );

    VX_pipe_buffer #(
        .DATAW   (P*M*K + P*K*N + 32*M*N),
        .PASSTHRU(0)
    ) input_buffer (
        .clk       (clk_i),
        .reset     (~rst_ni),
        .valid_in  (valid_i),
        .data_in   (data_in),
        .ready_in  (ready_i),
        .valid_out (valid_stage[0]),
        .data_out  ({C_stage[0], B_stage[0], A_stage[0]}),
        .ready_out (ready_stage[0])
    );

    genvar i;
    generate
        for (i = 0; i < PIPESTAGES-1; i = i + 1) begin : gen_pipeline
            // Packed matrix data needs to be unpacked for synthesis tool,
            // for simulation matrix concatenation can be used e.g. {A, B, C}
            matrix_flattener #(.WIDTH(K),.HEIGHT(M),.P(P))
            A_flattener_stage (
                .A(A_stage[i]),
                .data_out(data_stage[i][TotalWidthA-1:0])
            );

            matrix_flattener #(.WIDTH(N),.HEIGHT(K),.P(P)
            ) B_flattener_stage (
                .A(B_stage[i]),
                .data_out(data_stage[i][TotalWidthA+TotalWidthB-1:TotalWidthA])
            );

            matrix_flattener #(.WIDTH(N),.HEIGHT(M),.P(32)
            ) C_flattener_stage (
                .A(C_stage[i]),
                .data_out(
                    data_stage[i][TotalWidthA+TotalWidthB+TotalWidthC-1:TotalWidthA+TotalWidthB])
            );

            VX_pipe_buffer #(
                .DATAW   (P*M*K + P*K*N + 32*M*N),
                .PASSTHRU(0)
            ) buffer (
                .clk       (clk_i),
                .reset     (~rst_ni),
                .valid_in  (valid_stage[i]),
                .data_in   (data_stage[i]),
                .ready_in  (ready_stage[i]),
                .valid_out (valid_stage[i+1]),
                .data_out  ({C_stage[i+1], B_stage[i+1], A_stage[i+1]}),
                .ready_out (ready_stage[i+1])
            );
        end
    endgenerate

    assign A_in_matmul = A_stage[PIPESTAGES-1];
    assign B_in_matmul = B_stage[PIPESTAGES-1];
    assign C_in_matmul = C_stage[PIPESTAGES-1];

    assign valid_i_matmul = valid_stage[PIPESTAGES-1];
    assign ready_stage[PIPESTAGES-1] = ready_i_matmul;

    matrix_flattener #(
        .WIDTH(N),
        .HEIGHT(M),
        .P(32)
    ) D_flattener_output (
        .A(D_out_matmul),
        .data_out(data_out)
    );

    VX_pipe_buffer #(
        .DATAW   (32*M*N),
        .PASSTHRU(0)
    ) output_buffer (
        .clk       (clk_i),
        .reset     (~rst_ni),
        .valid_in  (valid_o_matmul),
        .data_in   (data_out),
        .ready_in  (ready_o_matmul),
        .valid_out (valid_o),
        .data_out  ({D_q}),
        .ready_out (ready_o)
    );

    matrix_multiplication_accumulation #(
        .M(M),
        .N(N),
        .K(K),
        .P(P),
        .TREE(TREE),
        .PIPESTAGES(PIPESTAGES),
        .MODE(MODE),
        .MANUAL_PIPELINE(MANUAL_PIPELINE)
    ) mma (
        .A(A_in_matmul),
        .B(B_in_matmul),
        .C(C_in_matmul),
        .D(D_out_matmul),
        .valid_in(valid_i_matmul),
        .ready_in(ready_i_matmul),
        .valid_out(valid_o_matmul),
        .ready_out(ready_o_matmul),
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .halvedPrecision(halvedPrecision),
        .bitSizeA(bitSizeA),
        .bitSizeB(bitSizeB)
    );

endmodule
