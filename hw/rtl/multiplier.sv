// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// Simple 2s complement multiplier
//
// Parameters:
// - DATAW: number of bits of the input data
// - PIPES: number of pipeline stages, 0 means fully combinational
// - BACKPRESSURE: 0 if backpressure is not used, 1 if backpressure is used

`include "registers.svh"
`include "waivers.svh"

module multiplier #(
    parameter int DATAW = 32,
    parameter int PIPES = 0,
    parameter int BACKPRESSURE = 0
)(

    input logic clk_i,
    input logic rst_ni,

    input logic [DATAW-1:0] dataa_i,
    input logic [DATAW-1:0] datab_i,
    output logic [2*DATAW-1:0] prod_o,

    input logic valid_i,
    output logic valid_o,

    input logic ready_i,
    output logic ready_o
);
    logic signed [2*DATAW-1:0] prod;

    assign prod = $signed(dataa_i) * $signed(datab_i);

    generate
        if (PIPES > 0) begin : g_pipe
            if (BACKPRESSURE == 0) begin : g_pipe_nobackpressure
                logic [PIPES:0][2*DATAW-1:0] pipe_prod;
                logic [PIPES:0] pipe_valid;
                for (genvar i = 0; i < PIPES; i++) begin : g_pipe_stage
                    `FFL(pipe_prod[i+1], pipe_prod[i], pipe_valid[i], '0, clk_i, rst_ni);
                    `FF(pipe_valid[i+1], pipe_valid[i], '0, clk_i, rst_ni);
                end
                assign pipe_prod[0] = prod;
                assign pipe_valid[0] = valid_i;
                assign prod_o = pipe_prod[PIPES];
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
                    .data_i(prod),
                    .data_o(prod_o),
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
            assign prod_o = prod;
        end
    endgenerate

endmodule

