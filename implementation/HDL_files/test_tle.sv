// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
//          Mats Vanhamel
// TODO:
// - Implement registers with elastic pipeline

module test_tle #(
    parameter int M = 8,
    parameter int N = 4,
    parameter int K = 16,
    parameter int P = 8
)(
    input logic clk_i,
    input logic rst_ni,
    input logic signed [P-1:0] A_i [M][K],
    input logic signed [P-1:0] B_i [K][N],
    input logic signed [4*P-1:0] C_i [M][N],
    input logic valid_i,
    output logic ready_o,
    output logic signed [4*P-1:0] D_o [M][N],
    input logic ready_i,
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

    logic valid_q1, valid_q2; 
    logic ready_q1, ready_q2;

    // Input assignment
    assign A_d = A_i;
    assign B_d = B_i;
    assign C_d = C_i;

    // Output assignment
    assign valid_o = valid_q2;
    assign ready_o = ready_q2;
    assign D_o = D_q;

    // Input operand registers
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin                      //reset
            A_q = '{default:0};
            B_q = '{default:0};
            C_q = '{default:0};
        end else if (valid_i && ready_o) begin  // clock gating
            A_q = A_d;
            B_q = B_d;
            C_q = C_d;
        end else begin                          // retain
            A_q = A_q;
            B_q = B_q;
            C_q = C_q;
        end
    end

    // 
    matrix_multiplication_accumulation #(
        .M(M),
        .N(N),
        .K(K),
        .P(P)
    ) mma (
        .A(A_q),
        .B(B_q),
        .C(C_q),
        .D(D_d)
    );

    // Output operand registers
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin                      //reset
            D_q = '{default:0};
        end else if (valid_q1 && ready_q1) begin  // clock gating
            D_q = D_d;
        end else begin                          // retain
            D_q = D_q;
        end
    end

    // Valid Backpressure
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            valid_q1 = 0;
            valid_q2 = 0;
        end else begin
            valid_q1 = valid_i  || (valid_q1 && ~ready_q1);
            valid_q2 = valid_q1 || (valid_q2 && ~ready_i);
        end
    end

    // Ready Backpressure
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            ready_q1 = 1;
            ready_q2 = 1;
        end else begin
            ready_q1 = ready_i;
            ready_q2 = ready_q1;
        end
    end
endmodule
