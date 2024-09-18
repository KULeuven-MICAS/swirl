// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// A configurable binary tree adder, supporting P-bit or P/2-bit inputs and giving 1 summed output.
// The halvedPrecision input can be used to select between the two modes at runtime.
// For halved precision, the P-bit inputs are expected to be filled up with two P/2-bit inputs,
// with the output giving the same format.
// Inputs are expected to be in 2's complement format for signed addition.
//
// Parameters:
// - INPUTS_AMOUNT: number of inputs, needs to be a power of 2
// - P: number of bits of each seperate element of the inputs

module config_binary_tree_adder #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input wire [P-1:0] inputs [INPUTS_AMOUNT],
    output wire [31:0] out,
    input wire halvedPrecision
);

    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");

    localparam int LayerAmount = $clog2(INPUTS_AMOUNT);
    logic [P+2*LayerAmount-1:0] temp_out;
    generate
        genvar layer;
        for(layer = 0; layer < LayerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
            localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
            logic [P+1+2*layer:0] connectingWires [NextWidth];
            if(layer == LayerAmount-1) begin : gen_pass_through
                assign temp_out = connectingWires[0];
            end
            if(layer == 0) begin : gen_first_tree_layer
                config_adder_tree_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P)
                ) adder_tree_layer (
                    .inputs(inputs),
                    .outputs(connectingWires),
                    .halvedPrecision(halvedPrecision)
                );
            end else begin : gen_tree_layers
                config_adder_tree_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P+2*layer)
                ) adder_tree_layer (
                    .inputs(gen_layer[layer-1].connectingWires),
                    .outputs(connectingWires),
                    .halvedPrecision(halvedPrecision)
                );
            end
        end
    endgenerate

    logic [P/2+LayerAmount:0] halved_precision_out;
    logic [(P+2*LayerAmount)/2-1:0] term1;
    assign term1 = temp_out[P+2*LayerAmount-1:(P+2*LayerAmount)/2];
    logic [(P+2*LayerAmount)/2-1:0] term2;
    assign term2 = temp_out[(P+2*LayerAmount)/2-1:0];
    assign halved_precision_out = signed'(term1) + signed'(term2);

    assign out = halvedPrecision ?
    { {(32-P/2-LayerAmount-1){halved_precision_out[P/2+LayerAmount]}},
    halved_precision_out[P/2+LayerAmount:0] } :
    { {(32-P-2*LayerAmount){temp_out[P+2*LayerAmount-1]}}, temp_out[P+2*LayerAmount-1:0] };

endmodule

