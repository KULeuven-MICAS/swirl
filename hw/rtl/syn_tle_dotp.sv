// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// Top level module used for synthesis of dot_product_unit module
// with input/output buffers and ready valid logic
//
// Parameters:
// - M: number of rows of the A matrix
// - N: number of columns of the B matrix
// - K: number of columns of the A matrix and rows of the B matrix
// - P: number of bits of the input data
// - PIPESTAGESTREE: number of pipeline stages for adder tree, 1 means no extra pipeline registers
// - PIPESTAGESMUL: number of pipeline stages for multiplier, 1 means no extra pipeline registers
// - MODE: 0 for unpartitioned design, 1 for partitioned design, 2 for sequential design

`ifndef DATAW
`define DATAW 8
`endif
`ifndef K
`define K 8
`endif
`ifndef PIPESTAGESTREE
`define PIPESTAGESTREE 2
`endif
`ifndef PIPESTAGESMUL
`define PIPESTAGESMUL 2
`endif


module syn_tle_dotp #(
    parameter int DATAW = `DATAW,
    parameter int NUM_INPUTS = `K,
    parameter int PIPESTAGESTREE = `PIPESTAGESTREE,
    parameter int PIPESTAGESMUL = `PIPESTAGESMUL,

    parameter int OUT_DATAW = (2 * DATAW) + $clog2(NUM_INPUTS)
)(
    input logic clk_i,
    input logic rst_n,
    input logic sign_unsign,

    input logic valid_i,
    output logic valid_o,

    input logic ready_i,
    output logic ready_o,

    input logic signed [DATAW-1:0] in1 [NUM_INPUTS],
    input logic signed [DATAW-1:0] in2 [NUM_INPUTS],
    output logic signed [OUT_DATAW-1:0] out
);

    logic signed [OUT_DATAW-1:0] out_temp;
    logic signed [DATAW-1:0] in1_passed [NUM_INPUTS];
    logic signed [DATAW-1:0] in2_passed [NUM_INPUTS];
    logic valid_o_temp;
    logic ready_o_temp;
    logic valid_i_passed;
    logic ready_i_passed;

    initial begin
        // $dumpfile($sformatf("syn_tle_dotp.vcd"));
        // $dumpvars(0, syn_tle_dotp);

        // $monitor("At time %t, D_o = %p, A_i = %p, B_i = %p, C_i = %p", $time, D_o, A_i, B_i, C_i);
        // $monitor("At time %t, A_in_matmul = %p, B_in_matmul = %p, C_in_matmul = %p", $time, A_in_matmul, B_in_matmul, C_in_matmul);
        // $monitor("At time %t, A_stage0 = %p, A_stage1 = %p, D_o = %p, ready_o = %p, valid_i = %p, valid_o = %p",
        // $time, A_stage[0], A_stage[1], D_o, ready_o, valid_i, valid_o);
        //  $monitor("At time %t, ready_i = %p, valid_o = %p, reset = %p, D_o = %p",
        //  $time, ready_i, valid_o, rst_ni, D_o);
        // $monitor("At time %t, ready_i = %p, ready_i_matmul = %p, ready_o_matmul = %p, valid_i = %p, valid_i_matmul = %p,  valid_o_matmul = %p",
        // $time, ready_i, ready_i_matmul,  ready_o_matmul, valid_i, valid_i_matmul,valid_o_matmul);
    end

    for (genvar i = 0; i < NUM_INPUTS-1; i++) begin : g_input_registers
        bq_pipe #(
            .DATAW(DATAW),
            .PIPES(1)
        ) bq_pipe_1 (
            .clk_i(clk_i),
            .rst_ni(rst_n),
            .data_i(in1[i]),
            .data_o(in1_passed[i]),
            .valid_i(1),
            .valid_o(),
            .ready_i(1),
            .ready_o()
        );

        bq_pipe #(
            .DATAW(DATAW),
            .PIPES(1)
        ) bq_pipe_2 (
            .clk_i(clk_i),
            .rst_ni(rst_n),
            .data_i(in2[i]),
            .data_o(in2_passed[i]),
            .valid_i(1),
            .valid_o(),
            .ready_i(1),
            .ready_o()
        );
    end

    bq_pipe #(
        .DATAW(DATAW),
        .PIPES(1)
    ) bq_pipe_1 (
        .clk_i(clk_i),
        .rst_ni(rst_n),
        .data_i(in1[NUM_INPUTS-1]),
        .data_o(in1_passed[NUM_INPUTS-1]),
        .valid_i(valid_i),
        .valid_o(valid_i_passed),
        .ready_i(ready_i),
        .ready_o(ready_i_passed)
    );

    bq_pipe #(
        .DATAW(DATAW),
        .PIPES(1)
    ) bq_pipe_2 (
        .clk_i(clk_i),
        .rst_ni(rst_n),
        .data_i(in2[NUM_INPUTS-1]),
        .data_o(in2_passed[NUM_INPUTS-1]),
        .valid_i(valid_i),
        .valid_o(valid_i_passed),
        .ready_i(ready_i),
        .ready_o(ready_i_passed)
    );

    dot_product_unit #(
        .DATAW(DATAW),
        .PIPES_TREE(PIPESTAGESTREE),
        .PIPES_MUL(PIPESTAGESMUL),
        .NUM_INPUTS(NUM_INPUTS),
        .BACKPRESSURE(1)
    ) dot_product_unit (
        .clk(clk_i),
        .rst_n(rst_n),
        .sign_unsign(sign_unsign),
        .valid_i(valid_i_passed),
        .valid_o(valid_o_temp),
        .ready_i(ready_i_passed),
        .ready_o(ready_o_temp),
        .in1(in1_passed),
        .in2(in2_passed),
        .out(out_temp)
    );

    bq_pipe #(
        .DATAW(OUT_DATAW),
        .PIPES(1)
    ) bq_pipe (
        .clk_i(clk_i),
        .rst_ni(rst_n),
        .data_i(out_temp),
        .data_o(out),
        .valid_i(valid_o_temp),
        .valid_o(valid_o),
        .ready_i(ready_o_temp),
        .ready_o(ready_o)
    );

endmodule
