// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>

`include "define.svh"
`include "assertions.svh"
`include "testbench.svh"

`timescale 1ns / 1ps

module tb_adder;

    parameter int DATAW = `DATAW;
    parameter int PIPES = `PIPES;

    // Testbench signals
    logic clk = 0;
    logic rst_n = 0;

    logic signed [DATAW-1:0] dataa;
    logic signed [DATAW-1:0] datab;
    logic signed [DATAW-1:0] correct_sum;
    logic signed [DATAW-1:0] sum;


    // Module instantiation
    adder #(
        .DATAW(DATAW),
        .PIPES(PIPES)
    ) DUT (
        .clk_i(clk),
        .rst_ni(rst_n),
        .dataa_i(dataa),
        .datab_i(datab),
        .sum_o(sum)
    );

    // Run tests
    initial begin
        $display("Running tests...");
        `DUMP_VARS(tb_adder);
        @(posedge rst_n);
        @(negedge clk);
        for (int i = 0; i < `NUM_TESTS; i++) begin
            dataa = test_vectors[i].dataa;
            datab = test_vectors[i].datab;
            correct_sum = test_vectors[i].correct_sum;
            @(posedge clk);
            if (PIPES > 0) begin
                @(posedge clk);
                for (int j = 0; j < PIPES; j++) begin
                    @(posedge clk);
                end
            end
            assert(sum == correct_sum) else
                $fatal("Test %d failed: %d + %d = %d, expected %d",
                       i, dataa, datab, sum, correct_sum);
            if (`DEBUG_LVL > 0) begin
                $display("TEST %d: dataa = %d, datab = %d, got = %d, expected = %d", i,
                                                                                     dataa,
                                                                                     datab,
                                                                                     sum,
                                                                                     correct_sum);
            end
        end
        #1;
        $display("All tests passed!");
        $finish;
  end

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
    end
endmodule
