// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Sequential multiplication module. The module calculates the result of a*b sequentially,
// outputting the next P least significant of the product after varying amount of clock cycles, which
// are need to be shifted to the output with the control signal 'shift'. Inputs of this module are mostly
// controlled by logic in the seq_MAC module, which is shared by all seq_mult modules, only differing in
// a and b input. The module uses a modified Baugh-Wooley algorithm to calculate the product of a and b.
// (doc/figs/modified_baugh_wooley.png for example of the algorithm)
//
// SEE doc/figs/seq_MAC.pdf FOR A GRAPHICAL REPRESENTATION OF THE MODULE
//
// Parameters:
// - P: number of bits calculated sequentially at a time (WARNING: only P=2 is supported at the time, but can be easily extended)
// - MAX_WIDTH: maximum width of the input data
// - MANUAL_PIPELINE: 0 for no extra pipeline stage, 1 for extra pipeline stage and slight timing improvement

// defining default values for synthesis parameters
//
`ifndef MANUAL_PIPELINE
`define MANUAL_PIPELINE 0
`endif

module seq_mult #(
    parameter unsigned P = 2,
    parameter unsigned [4:0] MAX_WIDTH = 16,
    parameter logic MANUAL_PIPELINE = `MANUAL_PIPELINE
    ) (
    input logic clk_i,
    input logic rst_n,
    input logic [1:0] a_i,
    input logic [1:0] b_i,
    input logic countDown,
    input logic shift,
    input logic lastOut,
    input logic invertFirstBit,
    input logic invertSecondRow,
    input logic start,
    input logic placeOne,
    input logic [1:0] countShiftInput,
    input logic [4*P-1:0] initSum,
    output logic [P-1:0] p

);
    logic [2*P-1:0] prod_out;
    logic [2*P-1:0] nextAccumSum;
    logic unsigned [2*P-1:0] nextCarryCount;
    logic adderCout;

    reg [2*P-1:0] accumSum;
    reg unsigned [2*P-1:0] carryCount;
    reg [P-1:0] out;

    assign p = out;
    assign nextCarryCount = adderCout? carryCount + 1'b1 : carryCount;

    // MULTIPLIER IS NOT YET PARAMETRIZED FOR DIFFERENT P !!!
    if (P == 2) begin : gen_mult_2bit
    mult_2bit mult_2bit (
        .multiplier(a_i),
        .multiplicand(b_i),
        .product(prod_out),
        .invertFirstBit(invertFirstBit),
        .invertSecondRow(invertSecondRow)
    );
    end

    logic [2*P:0] sumWithCarry;
    logic enableAdder;
    logic [2*P-1:0] prod;

    if (MANUAL_PIPELINE) begin : gen_pipeline_adder
        reg [2*P-1:0] prod_pipe;

        always_ff @(posedge clk_i, negedge rst_n) begin
            if (!rst_n) begin
                prod_pipe <= 0;
            end else if (start) begin
                prod_pipe <= 0;
            end else begin
                prod_pipe <= prod_out;
            end
        end

        assign prod = prod_pipe;

    end else begin : gen_no_pipeline_adder

        assign prod = prod_out;
    end

    assign enableAdder = ~lastOut;

    assign sumWithCarry = enableAdder ? accumSum + prod : accumSum;

    assign adderCout = sumWithCarry[2*P];
    assign nextAccumSum = sumWithCarry[2*P-1:0];


    logic shiftAccumSum;
    if (MANUAL_PIPELINE) begin : gen_pipeline_shift
        reg shiftAccumSum_pipe;
        always @(posedge clk_i, negedge rst_n) begin
            if (!rst_n) begin
                shiftAccumSum_pipe <= 0;
            end else begin
                shiftAccumSum_pipe <= shift;
            end
        end
        assign shiftAccumSum = shiftAccumSum_pipe;
    end else begin : gen_no_pipeline_shift
        assign shiftAccumSum = shift;
    end

    always_ff @(posedge clk_i, negedge rst_n) begin
        if (!rst_n) begin
            out <= 0;
        end else if (start) begin
            out <= 0;
        end else if (shiftAccumSum | lastOut) begin
            out <= nextAccumSum[P-1:0];
        end else begin
            out <= out;
        end
    end


    always_ff @(posedge clk_i, negedge rst_n) begin
        if (!rst_n) begin
            accumSum <= 0;
        end else if (start) begin
            accumSum <= initSum[3:0];
        end else if (shiftAccumSum) begin
            accumSum <= {nextCarryCount[P-1:0], nextAccumSum[2*P-1:P]};
        end else begin
            accumSum <= nextAccumSum;
        end
    end

    always_ff @(posedge clk_i, negedge rst_n) begin
        if (!rst_n) begin
            carryCount <= 0;
        end else if (start) begin
            carryCount <= initSum[7:4];
        end else if (shiftAccumSum) begin
            carryCount <= {countShiftInput, nextCarryCount[2*P-1:P]};
        end else begin
            carryCount <= nextCarryCount;
        end
    end

endmodule

