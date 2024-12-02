// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// Binary dot product unit that multiplies 2 vectors and then adds those multiplied elemants thru an adder tree.
// Inputs are expected to be in 2's complement format or decimal format for signed multiplication and addition.
// Testbench provides: corner cases, normal cases for positive and negative numbers, zero cases.
// Testbench also provides a maximum simulation time limit.
//
// Parameters:
// - DATAW: number of bits of the input data
// - PIPES: number of pipeline stages, 0 means fully combinational
// - BACKPRESSURE: 0 if backpressure is not used, 1 if backpressure is used


`timescale 1ns / 1ps

`define MAX_SIM 5000

module tb_dot_product_unit;

  initial begin
    $dumpfile("tb_dot_product_unit.vcd");
    $dumpvars(0, tb_dot_product_unit);
  end
  // Testbench signals
  logic clk_i = 0;
  logic rst_n;
  logic unsigned [15:0] timer=0;

  // parameters
  parameter int DATAW = 8;
  parameter int PIPES_MUL = 1;
  parameter int PIPES_TREE = 1;
  parameter int BACKPRESSURE = 1;
  parameter int NUM_INPUTS = 8;
  parameter int NUM_LAYERS = $clog2(NUM_INPUTS);
  parameter int OUT_DATAW = (2 * DATAW) + NUM_LAYERS;

  //signals
  logic signed [DATAW-1:0] data_i_a [NUM_INPUTS];
  logic signed [DATAW-1:0] data_i_b [NUM_INPUTS];
  logic signed sign_unsign_ni;
  logic [OUT_DATAW-1:0] data_o;

  logic valid_i;
  logic valid_o;
  logic ready_i;
  logic ready_o;

  parameter int NUM_TESTS_8 = 8;

// Updated test inputs with 8-element vectors
  logic signed [DATAW-1:0] test_inputs_a[NUM_TESTS_8][NUM_INPUTS] =  '{
    {1, 2, -3, 4, -5, 6, -7, 8},
    {1, -2, 3, -4, 5, -6, 7, -8},
    {127, -128, 127, -128, 64, -64, 32, -32},
    {127, 5, -12, 8, -6, 9, -4, 11},
    {-8, 127, -127, 8, 3, -3, 10, -10},
    {0, 0, 0, 0, 0, 0, 0, 0},
    {7, 0, -7, 14, -14, 21, -21, 28},
    {7, 0, 0, 14, -14, 21, -21, 28}
  };

  logic signed [DATAW-1:0] test_inputs_b[NUM_TESTS_8][NUM_INPUTS] =  '{
    {1, 2, 3, 4, 5, 6, 7, 8},
    {1, 2, -3, -4, -5, -6, -7, -8},
    {127, 127, 64, 64, 32, 32, 16, 16},
    {127, 5, 12, -8, 6, -9, 4, -11},
    {127, 8, -8, 127, -3, 3, -10, 10},
    {0, 0, 0, 0, 0, 0, 0, 0},
    {7, 0, 7, -14, 14, -21, 21, -28},
    {7, 0, 7, -14, 14, -21, 21, -28}
  };

  // Calculated expected outputs based on the element-wise multiplication and summation
  static logic signed [OUT_DATAW-1:0] expected_outputs[NUM_TESTS_8] = '{
    38,          // (1*1) + (2*2) + (-3*3) + (4*4) + (-5*5) + (6*6) + (-7*7) + (8*8)
    30,         // (1*1) + (-2*2) + (3*-3) + (-4*-4) + (5*-5) + (-6*-6) + (7*-7) + (-8*-8)
    -191,       // (127*127) + (-128*127) + (127*64) + (-128*64) + (64*32) + (-64*32) + (32*16) + (-32*16)
    15692,         // (127*127) + (5*5) + (-12*12) + (8*-8) + (-6*6) + (9*-9) + (-4*4) + (11*-11)
    1814,         // (-8*127) + (127*8) + (-127*-8) + (8*127) + (3*-3) + (-3*3) + (10*-10) + (-10*10)
    0,            // all zeros
    -2058,           // (7*7) + (0*0) + (-7*7) + (14*-14) + (-14*14) + (21*-21) + (-21*21) + (28*-28)
    -2009           // (7*7) + (0*0) + (0*7) + (14*-14) + (-14*14) + (21*-21) + (-21*21) + (28*-28)
  };

  static logic signed sign_unsign_ni_8[NUM_TESTS_8] = '{
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  };


  int i;
  int j;

  // Simulation signals
  logic sim_done = 0;

  // Module instantiation
  generate
    if (BACKPRESSURE == 0) begin : g_no_backpressure
      dot_product_unit #(
        .DATAW(DATAW),
        .PIPES_MUL(PIPES_MUL),
        .PIPES_TREE(PIPES_TREE),
        .BACKPRESSURE(0),
        .NUM_INPUTS(NUM_INPUTS)
      ) dot_product_unit1 (
        .clk(clk_i),
        .rst_n(rst_n),
        .sign_unsign(sign_unsign_ni),
        .valid_i(valid_i),
        .valid_o(valid_o),
        .ready_i(ready_i),
        .ready_o(ready_o),
        .in1(data_i_a),
        .in2(data_i_b),
        .out(data_o)
      );
    end else begin : g_backpressure
      dot_product_unit #(
        .DATAW(DATAW),
        .PIPES_MUL(PIPES_MUL),
        .PIPES_TREE(PIPES_TREE),
        .BACKPRESSURE(1),
        .NUM_INPUTS(NUM_INPUTS)
      ) dot_product_unit1 (
        .clk(clk_i),
        .rst_n(rst_n),
        .sign_unsign(sign_unsign_ni),
        .valid_i(valid_i),
        .valid_o(valid_o),
        .ready_i(ready_i),
        .ready_o(ready_o),
        .in1(data_i_a),
        .in2(data_i_b),
        .out(data_o)
      );
    end
  endgenerate


  initial begin
    $display("Running tests...");
    $display("DATAW = %d", DATAW);
    $display("PIPES_MUL = %d", PIPES_MUL);
    $display("PIPES_TREE = %d", PIPES_TREE);
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
    valid_i = 0;
    ready_i = 0;

    //reset sequence
    #11 rst_n = 1'b1;

    //apply test signals and check outputs
    $display("Running tests...");

    for (int i = 0; i < NUM_TESTS_8; i++) begin
      //apply inputs
      data_i_a = test_inputs_a[i];
      data_i_b = test_inputs_b[i];
      sign_unsign_ni = sign_unsign_ni_8[i];

      //apply sign_unsign_ni

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
      if ($signed(data_o) !== expected_outputs[i]) begin
        $display("Test %0d failed: expected %0d, got %0d", i, expected_outputs[i], $signed(data_o));
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
