// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda16@esat.kuleuven.be
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// Binary tree adder supporting 2^n inputs, giving 1 summed output (no overflows).
// Inputs are expected to be in 2's complement format for signed addition.
//
// Parameters:
// - NUM_INPUTS: number of inputs, needs to be a power of 2
// - DATAW: number of bits of each seperate element of the inputs
//
// TODO:
// - Add backpressure signals
// - Add pipeline support

`include "assertions.svh"

module adder_tree #(
    parameter int NUM_INPUTS,
    parameter int DATAW,
    parameter int PIPES = 0,
    parameter int BACKPRESSURE = 0,
    // Derived
    parameter int NUM_LAYERS = $clog2(NUM_INPUTS),
    parameter int OUT_DATAW = DATAW + NUM_LAYERS
) (
    input logic clk,
    input logic rst_n,

    input logic [DATAW-1:0] data_i [NUM_INPUTS],
    input logic sign_unsign_ni,
    output logic [OUT_DATAW-1:0] data_o,

    input logic valid_i,
    output logic valid_o,

    input logic ready_i,
    output logic ready_o
);

    `ASSERT_INIT(PowerOf2Error, ~((NUM_INPUTS-1) & NUM_INPUTS));


    generate
        if (NUM_INPUTS == 1) begin : gen_single_input
            assign temp_output = data_i[0];
        end else begin : gen_tree
            for(genvar layer = 0; layer < NUM_LAYERS; layer = layer + 1) begin: gen_layer
                localparam int LayerInputCnt = NUM_INPUTS >> layer;
                localparam int NextLayerInputCnt = NUM_INPUTS >> (layer+1);
                localparam int LayerDataW = DATAW + layer;
                logic [LayerDataW:0] mid_data [NextLayerInputCnt];
                logic mid_valid_o;
                logic mid_ready_o;

                if(layer == NUM_LAYERS-1) begin : gen_last_layer
                    assign data_o = mid_data[0];
                    assign valid_o = gen_layer[layer-1].mid_valid_o;
                    assign ready_o = gen_layer[layer-1].mid_ready_o;
                end else if(layer == 0) begin : gen_first_layer
                    adder_tree_layer #(
                        .NUM_INPUTS(NUM_INPUTS),
                        .DATAW(DATAW),
                        .PIPES(PIPES),
                        .BACKPRESSURE(BACKPRESSURE)
                    ) adder_tree_layer (
                        .clk(clk),
                        .rst_n(rst_n),

                        .data_i(data_i),
                        .data_o(mid_data),
                        .sign_unsign_ni(sign_unsign_ni),

                        .valid_i(valid_i),
                        .valid_o(mid_valid_o),

                        .ready_i(ready_i),
                        .ready_o(mid_ready_o)
                    );
                end else begin : gen_mid_layers
                    adder_tree_layer #(
                        .NUM_INPUTS(NUM_INPUTS>>layer),
                        .DATAW(LayerDataW),
                        .PIPES(PIPES),
                        .BACKPRESSURE(BACKPRESSURE)
                    ) adder_tree_layer (
                        .clk(clk),
                        .rst_n(rst_n),

                        .data_i(gen_layer[layer-1].mid_data),
                        .data_o(mid_data),
                        .sign_unsign_ni(sign_unsign_ni),

                        .valid_i(gen_layer[layer-1].mid_valid_o),
                        .valid_o(mid_valid_o),

                        .ready_i(gen_layer[layer-1].mid_ready_o),
                        .ready_o(mid_ready_o)
                    );
                end
            end
        end
    endgenerate


endmodule
