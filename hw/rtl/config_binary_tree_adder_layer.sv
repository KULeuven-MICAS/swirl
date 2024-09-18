// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// One layer of a configurable binary tree adder, supporting P-bit or P/2-bit inputs.
// The halvedPrecision input can be used to select between the two modes at runtime.
// For halved precision, the P-bit inputs are expected to be filled up with two P/2-bit inputs,
// with the output giving the same format.
// Every layer halves the amount of inputs by summing adjoining pairs.
// Inputs are expected to be in 2's complement format for signed addition.
//
// Parameters:
// - INPUTS_AMOUNT: number of inputs, needs to be a power of 2
// - P: number of bits of each seperate element of the inputs

module config_adder_tree_layer #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input logic [P-1:0] inputs [INPUTS_AMOUNT],
    output logic [P+1:0] outputs [INPUTS_AMOUNT/2], // #outputs = #inputs halved
    input logic halvedPrecision
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;
    generate
        genvar i;
        for (i = 0; i < OutputsAmount; i = i + 1) begin : gen_adders
            config_adder #(
                .P(P)
                ) add (
                    .a(inputs[2*i]),
                    .b(inputs[2*i+1]),
                    .sum(outputs[i]),
                    .halvedPrecision(halvedPrecision)
                );
        end
    endgenerate
endmodule
