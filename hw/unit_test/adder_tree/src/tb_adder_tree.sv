// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// Binary tree adder testbench supporting 2^n inputs, giving 1 summed output (no overflows).
// Inputs are expected to be in 2's complement format or decimal format for signed addition.
// Testbench provides: corner cases for overflow, normal cases for positive and negative numbers.
// Testbench also provides a maximum simulation time limit.
//
// Parameters:
// - NUM_INPUTS: number of inputs, needs to be a power of 2 (8 taken as example for this testbench here)
// - DATAW: number of bits of each seperate element of the inputs
// - PIPES: number of pipeline stages
// - BACKPRESSURE: 0 for no backpressure, 1 for backpressure
// - NUM_TESTS_8: number of tests for 8 inputs
// - test_inputs_8: test inputs for 8 inputs
// - sign_unsign_ni_8: signed or unsigned for 8 inputs
// - expected_outputs_8: expected outputs for 8 inputs

`timescale 1ns / 1ps

`define MAX_SIM 5000

module tb_adder_tree;

  initial begin
    $dumpfile("tb_adder_tree.vcd");
    $dumpvars(0, tb_adder_tree);
  end
  // Testbench signals
  logic clk_i = 0;
  logic rst_n;
  logic unsigned [15:0] timer=0;

  // parameters
  parameter int NUM_INPUTS = 16;
  parameter int DATAW = 8;
  parameter int PIPES = 8;
  parameter int BACKPRESSURE = 0;

  //derived params
  parameter int NUM_LAYERS = $clog2(NUM_INPUTS);
  parameter int OUT_DATAW = DATAW + NUM_LAYERS;

  //signals
  logic [DATAW-1:0] data_i [NUM_INPUTS];
  logic [OUT_DATAW-1:0] data_o;
  logic sign_unsign_ni;

  logic valid_i;
  logic valid_o;
  logic ready_i;
  logic ready_o;

  parameter int NUM_TESTS_8 = 5;

  logic signed [DATAW-1:0] test_inputs_8[NUM_TESTS_8][NUM_INPUTS] =  '{
    {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
    {1, -2, 3, -4, 5, -6, 7, -8, 9, -10, 11, -12, 13, -14, 15, -16},
    {127, -128, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 6, 0, 0, 1},
    {127, 5, 2, 1, 6, 1, 35, 6, 127, 5, 2, 1, 6, 1, 35, 6},
    {-127, 5, 2, 1, -6, 1, -35, 6, 0, 0, 0, 0, 0, 0, 0, 0}
  };

  static logic signed sign_unsign_ni_8[NUM_TESTS_8] = '{
    1,
    1,
    1,
    1,
    1
  };

  static logic signed [31:0] expected_outputs_8[NUM_TESTS_8] = '{
    136,
    -8,
    8,
    366,
    -153
  };

  int i;
  int j;

  // Simulation signals
  logic sim_done = 0;

  // Module instantiation
  generate
    if (BACKPRESSURE == 0) begin : g_no_backpressure
      adder_tree #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATAW(DATAW),
        .PIPES(PIPES),
        .BACKPRESSURE(0)
      ) addertree1 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i(data_i),
        .data_o(data_o),
        .sign_unsign_ni(sign_unsign_ni),
        .valid_i(valid_i),
        .valid_o(valid_o),
        .ready_i(1'b1),
        .ready_o(ready_o)
      );
    end else begin : g_backpressure
      adder_tree #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATAW(DATAW),
        .PIPES(PIPES),
        .BACKPRESSURE(1)
      ) addertree1 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i(data_i),
        .data_o(data_o),
        .sign_unsign_ni(sign_unsign_ni),
        .valid_i(valid_i),
        .valid_o(valid_o),
        .ready_i(ready_i),
        .ready_o(ready_o)
      );
    end
  endgenerate


  initial begin
    $display("Running tests...");
    $display("DATAW = %d", DATAW);
    $display("PIPES = %d", PIPES);
    $display("BACKPRESSURE = %d", BACKPRESSURE);
  end

  always begin
    #5 clk_i = ~clk_i;
  end

  always begin
    @(posedge clk_i);
    if (timer >= `MAX_SIM) begin
      $display("Simulation reached maximum time limit of %0d", `MAX_SIM);
      $finish(3);
    end else begin
      timer = timer + 1;
    end
  end

  //initialize signals
  initial begin
    rst_n = 1'b0;
    sign_unsign_ni = 0;
    valid_i = 0;
    ready_i = 0;

    //reset sequence
    #11 rst_n = 1'b1;

    //apply test signals and check outputs
    $display("Running tests...");

    for (int i = 0; i < NUM_TESTS_8; i++) begin
      //apply inputs
      for (int j = 0; j < NUM_INPUTS; j++) begin
        data_i[j] = test_inputs_8[i][j];
      end

      //apply sign_unsign_ni
      sign_unsign_ni = sign_unsign_ni_8[i];

      valid_i = 1;
      ready_i = 1;


      //wait for output
      @(posedge clk_i);
      while (valid_o != 1'b1) begin
        @(posedge clk_i);
      end

      valid_i = 0;
      ready_i = 0;


      //check output
      if ($signed(data_o) !== expected_outputs_8[i]) begin
        $display("Test %0d failed: expected %0d, got %0d", i, expected_outputs_8[i], $signed(data_o));
        rst_n = 1'b0;
        #5
        rst_n = 1'b1;
        $finish(1);
      end else begin
        $display("Test %0d passed: Output %0d is correct", i, $signed(data_o));
        rst_n = 1'b0;
        #5
        rst_n = 1'b1;
      end

      if (i == NUM_TESTS_8-1) begin
        sim_done = 1;
      end else begin
        sim_done = 0;
      end
    end
  end


  //simulation finished
  initial begin
      while (!sim_done) begin
          @(negedge clk_i);
      end
      $display("Simulation finished");
      $finish(2);
  end

endmodule