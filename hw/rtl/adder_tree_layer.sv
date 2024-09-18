// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
//
// Module description:
// One layer of a binary tree adder, MODE 0 for always signed addition, MODE 1 for signed/unsigned addition
// according to the sign_unsign_ni input. Every layer halves the amount of inputs by summing adjoining pairs.
// Inputs are expected to be in 2's complement format for signed addition.
//
// Parameters:
// - NUM_INPUTS: number of inputs, needs to be a power of 2
// - DATAW: number of bits of each seperate element of the inputs
// - MODE:
//      0 for always signed addition
//      1 for signed/unsigned addition according to the sign_unsign_ni input

module adder_tree_layer #(
    parameter int NUM_INPUTS,
    parameter int DATAW,
    parameter int MODE,
    // Derived
    parameter int NUM_OUTPUTS = NUM_INPUTS/2
) (
    input logic [DATAW-1:0] data_i [NUM_INPUTS],
    output logic [DATAW:0] data_o [NUM_OUTPUTS], // #outputs = #inputs halved
    input logic sign_unsign_ni
);
    if (MODE==0) begin : gen_signed_tree_layer
        genvar i;
        for (i = 0; i < NUM_OUTPUTS; i = i + 1) begin: gen_adder
            assign data_o[i] = signed'(data_i[2*i]) + signed'(data_i[2*i+1]);
        end
    end else if (MODE==1) begin : gen_unsiged_tree_layer

        logic [DATAW:0] extd_data_i [NUM_INPUTS];
        genvar i;

        for (genvar i = 0; i < NUM_INPUTS; i = i + 1) begin: gen_extender
            assign extd_data_i[i] = sign_unsign_ni ?
                {data_i[i][DATAW-1], data_i[i]} :   // sign extension
                {1'b0, data_i[i]};                  // zero extension
        end

        for (i = 0; i < NUM_OUTPUTS; i = i + 1) begin: gen_adder
            assign data_o[i] = extd_data_i[2*i] + extd_data_i[2*i+1];
        end
    end
endmodule
