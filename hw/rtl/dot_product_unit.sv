// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// A module to calculate the dot product of 2 vectors.
// input sign_unsign: 1 for signed, 0 for unsigned
// Inputs are expected to be in 2's complement format for signed addition and multiplication.
// The dotproduct is calculated by multiplying the corresponding elements of the 2 vectors and adding them together in a addertree.
// The adder tree distributes the pipes over the adders to reduce the critical path.
//
// Parameters:
// - NUM_INPUTS: number of inputs of each vector, needs to be a power of 2 and need to be the same for both vectors
// - DATAW: number of bits of each seperate element of the inputs
// - PIPES_TREE: number of pipeline stages in the adder tree
// - PIPEs_MUL: number of pipeline stages in the multiplier

module dot_product_unit #(
    parameter int NUM_INPUTS = 16,
    parameter int DATAW = 8,
    parameter int PIPES_TREE = 0,
    parameter int PIPES_MUL = 0,
    parameter int BACKPRESSURE = 0,

    parameter int NUM_LAYERS = $clog2(NUM_INPUTS),
    parameter int OUT_DATAW = (2 * DATAW) + NUM_LAYERS
)(
    input logic clk,
    input logic rst_n,
    input logic sign_unsign,

    input logic valid_i,
    output logic valid_o,

    input logic ready_i,
    output logic ready_o,

    input logic [DATAW-1:0] in1 [NUM_INPUTS],
    input logic [DATAW-1:0] in2 [NUM_INPUTS],
    output logic [OUT_DATAW-1:0] out
);

    logic [DATAW*2-1:0] mul_out [NUM_INPUTS];
    logic ready_o_mult [NUM_INPUTS];
    logic valid_o_mult [NUM_INPUTS];
    logic valid_i_tree;
    logic ready_i_tree;

    generate
        for (genvar i = 0; i < NUM_INPUTS; i = i + 1) begin : gen_mul
            multiplier #(
                .DATAW(DATAW),
                .PIPES(PIPES_MUL),
                .BACKPRESSURE(BACKPRESSURE)
            ) mul (
                .clk_i(clk),
                .rst_ni(rst_n),
                .dataa_i(in1[i]),
                .datab_i(in2[i]),
                .valid_i(valid_i),
                .ready_i(ready_i),
                .prod_o(mul_out[i]),
                .valid_o(valid_o_mult[i]),
                .ready_o(ready_o_mult[i])
            );
        end
        assign valid_i_tree = &valid_o_mult;
        assign ready_i_tree = &ready_o_mult;

        if (valid_i_tree & ready_i_tree) begin : gen_adder_tree
            adder_tree #(
                .NUM_INPUTS(NUM_INPUTS),
                .DATAW(DATAW*2),
                .PIPES(PIPES_TREE),
                .BACKPRESSURE(BACKPRESSURE)
            ) adder_tree_inst (
                .clk_i(clk),
                .rst_n(rst_n),
                .data_i(mul_out),
                .sign_unsign_ni(sign_unsign),
                .valid_i(valid_i_tree),
                .ready_i(ready_i_tree),
                .data_o(out),
                .valid_o(valid_o),
                .ready_o(ready_o)
            );
        end

    endgenerate

endmodule
