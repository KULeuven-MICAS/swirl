// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
//          Mats Vanhamel
// TODO:
// - Implement registers with elastic pipeline

module syn_tle #(
    parameter int M = 8,
    parameter int N = 4,
    parameter int K = 16,
    parameter int P = 8,
    parameter int PIPESTAGES = 1,
    parameter bit TREE = 0
)(
    input logic clk_i,
    input logic rst_ni,
    input logic signed [P-1:0] A_i [M][K],
    input logic signed [P-1:0] B_i [K][N],
    input logic signed [4*P-1:0] C_i [M][N],
    input logic valid_i,
    input logic ready_o,
    output logic signed [4*P-1:0] D_o [M][N],
    output logic ready_i,
    output logic valid_o
);

    logic signed [P-1:0] A_d [M][K];
    logic signed [P-1:0] A_q [M][K];
    logic signed [P-1:0] B_d [K][N];
    logic signed [P-1:0] B_q [K][N];
    logic signed [4*P-1:0] C_d [M][N];
    logic signed [4*P-1:0] C_q [M][N];
    logic signed [4*P-1:0] D_d [M][N];
    logic signed [4*P-1:0] D_q [M][N];

    // Elastic pipeline logic

    logic signed [P-1:0] A_stage [PIPESTAGES] [M][K];
    logic signed [P-1:0] B_stage [PIPESTAGES] [K][N];
    logic signed [4*P-1:0] C_stage [PIPESTAGES] [M][N];

    logic valid_q[PIPESTAGES], ready_q[PIPESTAGES];


    // Input assignment

    assign A_d = A_i;
    assign B_d = B_i;
    assign C_d = C_i;
    assign D_o = D_q;

    // Matmul input assignment

    assign A_q = A_stage[PIPESTAGES-1];
    assign B_q = B_stage[PIPESTAGES-1];
    assign C_q = C_stage[PIPESTAGES-1];

    initial begin
        $dumpfile($sformatf("syn_tle.vcd"));
        $dumpvars(0, syn_tle);

        // $monitor("At time %t, D_o = %p, A_i = %p, B_i = %p, C_i = %p", $time, D_o, A_i, B_i, C_i);
        // $monitor("At time %t, A_q = %p, B_q = %p, C_q = %p", $time, A_q, B_q, C_q);
        $monitor("At time %t, A_stage0 = %p, A_stage1 = %p, D_o = %p", $time, A_stage[0], A_stage[1], D_o);
    end

    genvar i;
    generate
        for (i = 0; i < PIPESTAGES - 1; i++) begin : BUFFER_GEN
            VX_pipe_buffer #(
                .DATAW   (P*M*K + P*K*N + 4*P*M*N),
                .PASSTHRU(0)
            ) buffer (
                .clk       (clk_i),
                .reset     (rst_ni),
                .valid_in  (valid_q[i]),
                .data_in   ({A_stage[i], B_stage[i], C_stage[i]}),
                .ready_in  (ready_q[i]),
                .valid_out (valid_q[i+1]),
                .data_out  ({A_stage[i+1], B_stage[i+1], C_stage[i+1]}),
                .ready_out (ready_q[i+1])
            );
        end
    endgenerate

    VX_pipe_buffer #(
        .DATAW   (P*M*K + P*K*N + 4*P*M*N),
        .PASSTHRU(0)
    ) input_buffer (
        .clk       (clk_i),
        .reset     (rst_ni),
        .valid_in  (valid_i),
        .data_in   ({A_d, B_d, C_d}),
        .ready_in  (ready_i),
        .valid_out (valid_q[0]),
        .data_out  ({A_stage[0], B_stage[0], C_stage[0]}),
        .ready_out (ready_q[0])
    );

    VX_pipe_buffer #(
        .DATAW   (4*P*M*N),
        .PASSTHRU(0)
    ) output_buffer (
        .clk       (clk_i),
        .reset     (rst_ni),
        .valid_in  (valid_q[PIPESTAGES-1]),
        .data_in   ({D_d}),
        .ready_in  (ready_q[PIPESTAGES-1]),
        .valid_out (valid_i),
        .data_out  ({D_q}),
        .ready_out (ready_i)
    );

    matrix_multiplication_accumulation #(
        .M(M),
        .N(N),
        .K(K),
        .P(P),
        .TREE(TREE)
    ) mma (
        .A(A_q),
        .B(B_q),
        .C(C_q),
        .D(D_d)
    );

endmodule
