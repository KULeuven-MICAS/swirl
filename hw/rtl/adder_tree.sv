// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Binary tree adder supporting 2^n inputs, giving 1 summed output,
// MODE 0 for always signed addition, MODE 1 for signed/unsigned addition according to the signedAddition input.
// Inputs are expected to be in 2's complement format for signed addition.
// The output is a 32-bit value for MODE 0, and a P-bit value for MODE 1 as for this projects specific needs.
//
// Parameters:
// - NUM_INPUTS: number of inputs, needs to be a power of 2
// - DATAW: number of bits of each seperate element of the inputs
// - MODE: 0 for always signed addition, 1 for signed/unsigned addition according to the signedAddition input

module adder_tree #(
    parameter int NUM_INPUTS,
    parameter int DATAW,
    parameter int MODE,
    // Derived
    parameter int OUT_DATAW = DATAW + $clog2(NUM_INPUTS)
) (
    input wire [DATAW-1:0] inputs [NUM_INPUTS],
    input wire signedAddition,
    output wire [31:0] out_32bit,
    output wire [OUT_DATAW-1:0] out

);

    if (NUM_INPUTS - 1 & NUM_INPUTS) $fatal("ERROR: Binary adder input not power of 2");

    localparam int LayerAmount = $clog2(NUM_INPUTS);
    logic signed [P+LayerAmount-1:0] temp_output ;
    generate
        if (NUM_INPUTS == 1) begin : gen_single_input
            assign temp_output = inputs[0];
        end else begin : gen_tree
        genvar layer;
        for(layer = 0; layer < LayerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = NUM_INPUTS >> layer;
            localparam int NextWidth = NUM_INPUTS >> (layer+1);
            logic [P+layer:0] connectingWires [NextWidth];
            if(layer == LayerAmount-1) begin : gen_last_layer
                assign temp_output = connectingWires[0];
            end
            if(layer == 0) begin : gen_first_layer
                adder_tree_layer #(
                .NUM_INPUTS(NUM_INPUTS>>layer),
                .DATAW(P)
                ) adder_tree_layer (
                    .data_i(inputs),
                    .data_o(connectingWires),
                    .sign_unsign_ni(signedAddition)
                );
            end else begin : gen_mid_layers
                adder_tree_layer #(
                .NUM_INPUTS(NUM_INPUTS>>layer),
                .DATAW(P+layer)
                ) adder_tree_layer (
                    .data_i(gen_layer[layer-1].connectingWires),
                    .data_o(connectingWires),
                    .sign_unsign_ni(signedAddition)
                );
            end
        end
        end
    endgenerate

    if (MODE==0) begin
        assign out_32bit = {
        {(32-P-LayerAmount+1){temp_output[P+LayerAmount-1]}},
        temp_output[P+LayerAmount-1:0] };
    end else if (MODE==1) begin
        assign out = temp_output[P+LayerAmount-1:0];
    end


endmodule


