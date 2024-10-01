// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//  Giuseppe Sarda <giuseppe.sarda@esat.kuleuven.be>
//
// Testbench for the adder module
// Configurable parameters:
// - DATAW: data width (not working for odd DATAW) (default: 8)
// - PIPES: number of pipeline stages (default: 0)
// - BACKPRESSURE: enable backpressure (default: 0)
// - RND_VALID: randomize valid signal in tests (only if BACKPRESSURE is enabled) (default: 0)
// - RND_READY: randomize ready signal in tests (only if BACKPRESSURE is enabled) (default: 0)
// - NUM_TESTS: number of tests to run (fixed to 6 for smoke test) (default: 100)

// TODO:
// - Add sh script to run different configurations
// - no pipe test is broken
// - refactor (?)

`include "define.svh"
`include "assertions.svh"
`include "testbench.svh"
`include "waivers.svh"

`timescale 1ns / 1ps

module tb_adder;

    parameter int DATAW = `DATAW;
    parameter int PIPES = `PIPES;
    parameter int BACKPRESSURE = `BACKPRESSURE;
    parameter int RND_VALID = `RND_VALID;
    parameter int RND_READY = `RND_READY;

    `WARNING_INIT(RandomReadyWoBackpressure, (!RND_READY || BACKPRESSURE))

    // Testbench signals
    logic clk = 0;
    logic rst_n = 0;

    logic valid_i;
    logic valid_o;
    logic ready_i;
    logic ready_o;

    logic signed [DATAW-1:0] dataa;
    logic signed [DATAW-1:0] datab;
    logic signed [DATAW-1:0] correct_sum = 0;
    logic signed [DATAW-1:0] sum;
    logic signed [DATAW-1:0] got_sum = 0;

    // Simulation signals
    logic input_gen_done = 0;
    logic sim_done = 0;

    // Module instantiation
    generate
        if (BACKPRESSURE == 0) begin : g_no_backpressure
            adder #(
                .DATAW(DATAW),
                .PIPES(PIPES),
                .BACKPRESSURE(0)
            ) DUT (
                .clk_i(clk),
                .rst_ni(rst_n),
                .dataa_i(dataa),
                .datab_i(datab),
                .sum_o(sum),
                .valid_i(valid_i),
                .valid_o(valid_o),
                .ready_i(1'b1),
                `UNUSED_PIN(ready_o)
            );
        end else begin : g_backpressure
            adder #(
                .DATAW(DATAW),
                .PIPES(PIPES),
                .BACKPRESSURE(1)
            ) DUT (
                .clk_i(clk),
                .rst_ni(rst_n),
                .dataa_i(dataa),
                .datab_i(datab),
                .sum_o(sum),
                .valid_i(valid_i),
                .valid_o(valid_o),
                .ready_i(ready_i),
                .ready_o(ready_o)
            );
        end
    endgenerate

    // Run simulation
    initial begin
        $display("Running tests...");
        $display("DATAW = %d", DATAW);
        $display("PIPES = %d", PIPES);
        $display("BACKPRESSURE = %d", BACKPRESSURE);
        $display("NUM_TESTS = %d", `NUM_TESTS);
        $display("RND_VALID = %d", `RND_VALID);
        $display("RND_READY = %d", `RND_READY);
        `DUMP_VARS(tb_adder);
  end

    // Clock generation
    always begin
        #`CLK_T_2 clk = ~clk;
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #(2*`CLK_T_2 + 1);
        rst_n = 1;
    end

    // Valid generation
    initial begin
        valid_i = 0;
        @(posedge rst_n);
        @(negedge clk);
        if (`RND_VALID == 0) begin
            valid_i = 1;
        end else begin
            while(!input_gen_done) begin
                valid_i = $urandom_range(0, 1);
                @(negedge clk);
            end
        end
    end

    // Ready generation
    initial begin
        ready_i = 1;
        @(posedge rst_n);
        @(negedge clk);
        if (BACKPRESSURE == 0) begin
            ready_i = 1;
        end else begin
            if (`RND_READY == 0) begin
                ready_i = 1;
            end else begin
                while(!sim_done) begin
                    ready_i = $urandom_range(0, 1);
                    @(negedge clk);
                end
            end
        end
    end

    // Input generation
    initial begin
        dataa = 0;
        datab = 0;
        if (`RND_TEST) begin : random_test_init
            for (int i = 0; i < `NUM_TESTS; i++) begin
                test_vectors[i] = adder_gen_test();
            end
        end
        @(posedge rst_n);
        @(negedge clk);
        #1; // a bit later than valid_i generation
        for (int i = 0; i < `NUM_TESTS; i++) begin
            dataa = test_vectors[i].dataa;
            datab = test_vectors[i].datab;
            while (valid_i == 0 || ready_o == 0) begin
                @(posedge clk);
            end
            @(negedge clk);
            #1;
        end
        input_gen_done = 1;
    end

    // Output monitor
    initial begin
        @(posedge rst_n);
        for (int i = 0; i < `NUM_TESTS; i++) begin
            correct_sum = test_vectors[i].correct_sum; // for vcd visibility
            while ((valid_o == 0) || (ready_i == 0)) begin
                @(negedge clk);
                #1;
            end
            got_sum = sum;
            @(negedge clk);
            #1;
            assert(got_sum == correct_sum) else
                $fatal(1,"Test %d failed: %d + %d = %d, expected %d",
                        i,
                        test_vectors[i].dataa,
                        test_vectors[i].datab,
                        got_sum,
                        correct_sum);
            if (`DBG_MSG > 0) begin
                $display("TEST %d: dataa = %d, datab = %d, got = %d, expected = %d",
                    i,
                    test_vectors[i].dataa,
                    test_vectors[i].datab,
                    got_sum,
                    correct_sum);
            end
        end
        sim_done = 1;
    end

    // Simulation end
    initial begin
        while (!sim_done) begin
            @(negedge clk);
        end
        $display("Simulation finished");
        $finish(2);
    end
endmodule
