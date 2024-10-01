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
// - PIPES: number of pipeline stages, 0 means fully combinational
// - BACKPRESSURE: 0 if backpressure is not used, 1 if backpressure is used
//
// TODO:
// - Add support for configurable saturation
// - Add support for ovf_o

`include "registers.svh"
`include "waivers.svh"

module adder #(
    parameter int DATAW = 32,
    parameter int PIPES = 0,
    parameter int BACKPRESSURE = 0
)(

    input logic clk_i,
    input logic rst_ni,

    input logic [DATAW-1:0] dataa_i,
    input logic [DATAW-1:0] datab_i,
    output logic [DATAW-1:0] sum_o,

    input logic valid_i,
    output logic valid_o,

    input logic ready_i,
    output logic ready_o
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
            if (BACKPRESSURE == 0) begin : g_pipe_nobackpressure
                logic [PIPES:0][DATAW-1:0] pipe_sum;
                logic [PIPES:0] pipe_valid;
                for (genvar i = 0; i < PIPES; i++) begin : g_pipe_stage
                    `FF(pipe_sum[i+1], pipe_sum[i], '0, clk_i, rst_ni);
                    `FF(pipe_valid[i+1], pipe_valid[i], '0, clk_i, rst_ni);
                end
                assign pipe_sum[0] = sat_sum;
                assign pipe_valid[0] = valid_i;
                assign sum_o = pipe_sum[PIPES];
                assign valid_o = pipe_valid[PIPES];

                `UNUSED_VAR(ready_i);
                assign ready_o = 1'b1;
            end else begin : g_pipe_backpressure
                bp_pipe #(
                    .DATAW(DATAW),
                    .PIPES(PIPES)
                ) bp_pipe_inst (
                    .clk_i(clk_i),
                    .rst_ni(rst_ni),
                    .data_i(sat_sum),
                    .data_o(sum_o),
                    .valid_i(valid_i),
                    .valid_o(valid_o),
                    .ready_i(ready_i),
                    .ready_o(ready_o)
                );
            end
        end else begin : g_combinational
            assign valid_o = valid_i;
            assign ready_o = ready_i;
            `UNUSED_VAR(clk_i);
            `UNUSED_VAR(rst_ni);
            assign sum_o = sat_sum;
        end
    endgenerate

endmodule

