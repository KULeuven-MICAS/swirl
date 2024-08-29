// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Counter that counts up/down to/from a runtime value countSet.
// Last_o is high when the counter reaches the countSet value when counting up, or 0 when counting down.
// The counter can be cleared, loaded with a value, enabled, and switch between counting up or down.
//
// Parameters:
// - WIDTH: max bitwidth of the counter
// - UPDOWN: make counter take step down when reaching top, used for special cases

module programmable_counter #(
    parameter int unsigned WIDTH = 4, // max bitwidth of counter
    parameter int UPDOWN = 0 // make counter revert at top
    ) (
    input clk_i,
    input rst_ni,
    input clear_i, // clear counter
    input en_i, // enable counter
    input load_i, // load value
    input down_i, // 0 for counting up, 1 for counting down
    input logic [WIDTH-1:0] countSet, // value to count to
    input logic [WIDTH-1:0] d_i, // value to load
    output logic [WIDTH-1:0] q_o, // counter output
    output logic last_o // high when counter reaches countSet or 0 when counting down
    );

    logic [WIDTH-1:0] counter_q, counter_d;
    logic [WIDTH-1:0] cnt_next;

    assign q_o = counter_q;

    assign last_o = down_i ? counter_q == 0 : counter_q == countSet;

    always_comb begin
        counter_d = counter_q;

        if (clear_i) begin
            counter_d = '0;
        end else if (load_i) begin
            counter_d = d_i;
        end else if (en_i) begin
                if (down_i) begin
                    counter_d = counter_q - 1;
                end else begin
                    if (UPDOWN) begin
                        if (counter_q == countSet) begin
                            counter_d = counter_q - 1;
                        end else begin
                            counter_d = counter_q + 1;
                        end
                    end else begin
                        if (counter_q == countSet) begin
                            counter_d = 0;
                        end else begin
                            counter_d = counter_q + 1;
                        end
                    end
                end
            end
        end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
           counter_q <= '0;
        end else begin
           counter_q <= counter_d;
        end
    end

endmodule
