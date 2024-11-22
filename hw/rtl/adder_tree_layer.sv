// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// One layer of a binary tree adder, MODE 0 for always signed addition, MODE 1 for signed/unsigned addition
// according to the sign_unsign_ni input. Every layer halves the amount of inputs by summing adjoining pairs.
// Inputs are expected to be in 2's complement format for signed addition.
//
// Parameters:
// - NUM_INPUTS: number of inputs, needs to be a power of 2
// - DATAW: number of bits of each seperate element of the inputs

// TODO:
// - Move to packed array for data_i and data_o

module adder_tree_layer #(
    parameter int NUM_INPUTS,
    parameter int DATAW,
    parameter int PIPES = 0,
    parameter int BACKPRESSURE = 0,
    // Derived
    parameter int NUM_OUTPUTS = NUM_INPUTS/2
) (
    input logic clk_i,
    input logic rst_n,

    input logic [DATAW-1:0] data_i [NUM_INPUTS],
    output logic [DATAW:0] data_o_layer [NUM_OUTPUTS], // #outputs = #inputs halved
    input logic sign_unsign_ni,

    input logic valid_i,
    output logic valid_o,

    input logic ready_i,
    output logic ready_o
);

    logic [DATAW:0] extd_data_i [NUM_INPUTS];
    logic [NUM_OUTPUTS-1:0] valid_o_array_layer;
    logic [NUM_OUTPUTS-1:0] ready_o_array_layer;

    generate
        for (genvar i = 0; i < NUM_INPUTS; i = i + 1) begin: gen_sign_extension
            assign extd_data_i[i] = sign_unsign_ni ?
                {data_i[i][DATAW-1], data_i[i]} :   // sign extension
                {1'b0, data_i[i]};                  // zero extension
        end
        for (genvar i = 0; i < NUM_OUTPUTS; i = i + 1) begin: gen_adder
            adder #(
                .DATAW(DATAW+1),
                .PIPES(PIPES),
                .BACKPRESSURE(BACKPRESSURE)
            ) adder (
                .clk_i(clk_i),
                .rst_ni(rst_n),

                .dataa_i(extd_data_i[2*i]),
                .datab_i(extd_data_i[2*i+1]),
                .sum_o(data_o_layer[i]),

                .valid_i(valid_i),
                .valid_o(valid_o_array_layer[i]),

                .ready_i(ready_i),
                .ready_o(ready_o_array_layer[i])
            );
        end

    endgenerate

    assign ready_o = &ready_o_array_layer;
    assign valid_o = &valid_o_array_layer;
    //always_comb begin
    //    if (ready_o_array_layer.sum() == NUM_OUTPUTS) begin
    //        ready_o = 1'b1;
    //    end else begin
    //        ready_o = 1'b0;
    //    end
//
    //    if (valid_o_array_layer.sum() == NUM_OUTPUTS) begin
    //        valid_o = 1'b1;
    //    end else begin
    //        valid_o = 1'b0;
    //    end
    //end

endmodule
