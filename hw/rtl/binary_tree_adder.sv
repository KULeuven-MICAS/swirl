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
// - INPUTS_AMOUNT: number of inputs, needs to be a power of 2
// - P: number of bits of each seperate element of the inputs
// - MODE: 0 for always signed addition, 1 for signed/unsigned addition according to the signedAddition input

module binary_tree_adder #(
    parameter int INPUTS_AMOUNT,
    parameter int P,
    parameter int MODE
) (
    input wire [P-1:0] inputs [INPUTS_AMOUNT],
    input wire signedAddition,
    output wire [31:0] out_32bit,
    output wire [P+$clog2(INPUTS_AMOUNT)-1:0] out

);

    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");

    localparam int LayerAmount = $clog2(INPUTS_AMOUNT);
    logic signed [P+LayerAmount-1:0] temp_output ;
    generate
        if (INPUTS_AMOUNT == 1) begin : gen_single_input
            assign temp_output = inputs[0];
        end else begin : gen_tree
        genvar layer;
        for(layer = 0; layer < LayerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
            localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
            logic [P+layer:0] connectingWires [NextWidth];
            if(layer == LayerAmount-1) begin : gen_last_layer
                assign temp_output = connectingWires[0];
            end
            if(layer == 0) begin : gen_first_layer
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P),
                .MODE(MODE)
                ) binary_tree_adder_layer (
                    .inputs(inputs),
                    .outputs(connectingWires),
                    .signedAddition(signedAddition)
                );
            end else begin : gen_mid_layers
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P+layer),
                .MODE(MODE)
                ) binary_tree_adder_layer (
                    .inputs(gen_layer[layer-1].connectingWires),
                    .outputs(connectingWires),
                    .signedAddition(signedAddition)
                );
            end
        end
        end
    endgenerate

    if (MODE==0) begin
        if (P+LayerAmount > 32) begin : gen_limit_precision
            assign out_32bit = temp_output[31:0];
        end else begin
            assign out_32bit = {
            {(32-P-LayerAmount+1){temp_output[P+LayerAmount-1]}},
            temp_output[P+LayerAmount-1:0] };
        end
    end else if (MODE==1) begin
        assign out = temp_output[P+LayerAmount-1:0];
    end


endmodule