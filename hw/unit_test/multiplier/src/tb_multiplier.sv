// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author:
//  Quinten Guelinckx <quinten.guelinckx@student.kuleuven.be>
//
// Module description:
// Binary multiplier testbench supporting 2 inputs, giving 1 multiplied output.
// Inputs are expected to be in 2's complement format or decimal format for signed multiplication.
// Testbench provides: corner cases, normal cases for positive and negative numbers, zero cases.
// Testbench also provides a maximum simulation time limit.
//
// Parameters:
// - DATAW: number of bits of the input data
// - PIPES: number of pipeline stages, 0 means fully combinational
// - BACKPRESSURE: 0 if backpressure is not used, 1 if backpressure is used


`timescale 1ns / 1ps

`define MAX_SIM 5000

module tb_multiplier;

  initial begin
    $dumpfile("tb_multiplier.vcd");
    $dumpvars(0, tb_multiplier);
  end
  // Testbench signals
  logic clk_i = 0;
  logic rst_n;
  logic unsigned [15:0] timer=0;

  // parameters
  parameter int DATAW = 8;
  parameter int PIPES = 0;
  parameter int BACKPRESSURE = 0;

  //signals
  logic signed [DATAW-1:0] data_i [2];
  logic [2*DATAW-1:0] data_o;

  logic valid_i;
  logic valid_o;
  logic ready_i;
  logic ready_o;

  parameter int NUM_TESTS_8 = 7;

  logic signed [DATAW-1:0] test_inputs[NUM_TESTS_8][2] =  '{
    {1, 2},
    {1, -2},
    {127, -128},
    {127, 5},
    {-127, 5},
    {0, 0},
    {7, 0}
  };

  static logic signed [2*DATAW-1:0] expected_outputs[NUM_TESTS_8] = '{
    2,
    -2,
    -16256,
    635,
    -635,
    0,
    0
  };

  int i;
  int j;

  // Simulation signals
  logic sim_done = 0;

  // Module instantiation
  generate
    if (BACKPRESSURE == 0) begin : g_no_backpressure
      multiplier #(
        .DATAW(DATAW),
        .PIPES(PIPES),
        .BACKPRESSURE(0)
      ) multiplier1 (
        .clk_i(clk_i),
        .rst_ni(rst_n),
        .dataa_i(data_i[0]),
        .datab_i(data_i[1]),
        .prod_o(data_o),
        .valid_i(valid_i),
        .valid_o(valid_o),
        .ready_i(ready_i),
        .ready_o(ready_o)
      );
    end else begin : g_backpressure
      multiplier #(
        .DATAW(DATAW),
        .PIPES(PIPES),
        .BACKPRESSURE(1)
      ) multiplier1 (
        .clk_i(clk_i),
        .rst_ni(rst_n),
        .dataa_i(data_i[0]),
        .datab_i(data_i[1]),
        .prod_o(data_o),
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
    valid_i = 0;
    ready_i = 0;

    //reset sequence
    #11 rst_n = 1'b1;

    //apply test signals and check outputs
    $display("Running tests...");

    for (int i = 0; i < NUM_TESTS_8; i++) begin
      //apply inputs
      data_i = test_inputs[i];

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
        $display("Test %0d failed: expected %0d from inputs %0d and %0d, got %0d", i, expected_outputs[i], $signed(data_i[0]), $signed(data_i[1]), $signed(data_o));
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
