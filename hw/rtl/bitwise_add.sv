// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Simple adder that applies saturated value on overflow
//
// Parameters:
// - P: number of bits of the input data

module bitwise_add #(
    parameter int P = 32
)(
    input logic [P-1:0] a,
    input logic [P-1:0] b,
    output logic [P-1:0] sum
);
    always_comb begin
        sum = a + b;
        if (a[P-1] == 0 && b[P-1] == 0 && sum[P-1] == 1) begin // Check positive overflow
        sum = {1'b0, {(P-1){1'b1}}};
        end
        else if (a[P-1] == 1 && b[P-1] == 1 && sum[P-1] == 0) begin // Check negative overflow
        sum = {1'b1, {(P-1){1'b0}}};
        end
    end
endmodule

