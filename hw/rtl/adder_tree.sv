// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda16@esat.kuleuven.be
//
// Module description:
// Binary tree adder supporting 2^n inputs, giving 1 summed output (no overflows).
// Inputs are expected to be in 2's complement format for signed addition.
//
// Parameters:
// - NUM_INPUTS: number of inputs, needs to be a power of 2
// - DATAW: number of bits of each seperate element of the inputs

`include "platform.vh"

module adder_tree #(
    parameter int NUM_INPUTS,
    parameter int DATAW,
    // Derived
    parameter int NUM_LAYERS = $clog2(NUM_INPUTS),
    parameter int OUT_DATAW = DATAW + NUM_LAYERS
) (
    input wire [DATAW-1:0] data_i [NUM_INPUTS],
    input wire sign_unsign_ni,
    output wire [OUT_DATAW-1:0] data_o
);

    if(NUM_INPUTS-1 & NUM_INPUTS) $error("NUM_INPUTS must be a power of 2");

    generate
        if (NUM_INPUTS == 1) begin : gen_single_input
            assign temp_output = data_i[0];
        end else begin : gen_tree
            for(genvar layer = 0; layer < NUM_LAYERS; layer = layer + 1) begin: gen_layer
                localparam int LayerInputCnt = NUM_INPUTS >> layer;
                localparam int NextLayerInputCnt = NUM_INPUTS >> (layer+1);
                localparam int LayerDataW = DATAW + layer;
                logic [LayerDataW:0] data [NextLayerInputCnt];

                if(layer == NUM_LAYERS-1) begin : gen_last_layer
                    assign data_o = data[0];
                end else if(layer == 0) begin : gen_first_layer
                    adder_tree_layer #(
                        .NUM_INPUTS(NUM_INPUTS),
                        .DATAW(DATAW)
                    ) adder_tree_layer (
                        .data_i(inputs),
                        .data_o(data),
                        .sign_unsign_ni(sign_unsign_ni)
                    );
                end else begin : gen_mid_layers
                    adder_tree_layer #(
                        .NUM_INPUTS(NUM_INPUTS>>layer),
                        .DATAW(LayerDataW)
                    ) adder_tree_layer (
                        .data_i(gen_layer[layer-1].data),
                        .data_o(data),
                        .sign_unsign_ni(sign_unsign_ni)
                    );
                end
            end
        end
    endgenerate
endmodule
