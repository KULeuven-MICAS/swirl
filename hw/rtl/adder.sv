// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
//
// Module description:
// Simple 2s complement adder that applies saturated value on overflow
//
// Parameters:
// - DATAW: number of bits of the input data
//
// TODO:
// - Add backpressure signals

`include "registers.svh"

module adder #(
    parameter int DATAW = 32,
    parameter int PIPES = 0
)(

    input logic clk_i,
    input logic rst_ni,

    input logic [DATAW-1:0] dataa_i,
    input logic [DATAW-1:0] datab_i,
    output logic [DATAW-1:0] sum_o
);
    logic [DATAW-1:0] sum, sat_sum;
    logic overflow_pos, overflow_neg;

    assign sum = dataa_i + datab_i;
    assign overflow_pos = !dataa_i[DATAW-1] && !datab_i[DATAW-1] && sum[DATAW-1];
    assign overflow_neg = dataa_i[DATAW-1] && datab_i[DATAW-1] && !sum[DATAW-1];

    always_comb begin : saturate
        if (overflow_pos) begin
            sat_sum = {1'b0, {(DATAW-1){1'b1}}};
        end else if (overflow_neg) begin
            sat_sum = {1'b1, {(DATAW-1){1'b0}}};
        end else begin
            sat_sum = sum;
        end
    end
    generate
        if (PIPES > 0) begin : g_pipe
            logic [PIPES:0][DATAW-1:0] pipe_sum;
            for (genvar i = 0; i < PIPES; i++) begin : g_pipe_stage
                `FF(pipe_sum[i+1], pipe_sum[i], '0, clk_i, rst_ni);
            end
            assign pipe_sum[0] = sat_sum;
            assign sum_o = pipe_sum[PIPES];
        end else begin : g_nopipe
            assign sum_o = sat_sum;
        end
    endgenerate

endmodule

