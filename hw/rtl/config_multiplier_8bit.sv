// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Configurable 8-bit multiplier that can be configured to either:
// 1) perform a full signed 8-bit multiplication, when halvedPrecision is set to 00
// 2) perform 2 signed 4-bit multiplications, when halvedPrecision is set to 10
// 3) perform 4 signed 2-bit multiplications, when halvedPrecision is set to 01
// Inputs are split up equally for lower precision, 4_4 or 2_2_2_2, and placed accordingly
// in the output, 8_8 or 4_4_4_4
//
// The algorithm used is a modified Baugh-Wooley Algorithm (see doc/figs/modified_baugh_wooley.png),
// the invert signals are used to correctly perform this algorithm
// The multiplier is split up into 4 4-bit multipliers, which are instantiated in this module

module config_multiplier_8bit (
    input logic signed [7:0] multiplier,
    input logic signed [7:0] multiplicand,
    input logic [1:0] halvedPrecision,
    output logic signed [15:0] product
);
    logic [7:0] partialMultTopRight;
    logic [7:0] partialMultTopLeft;
    logic [7:0] partialMultBottomRight;
    logic [7:0] partialMultBottomLeft;

    logic [15:0] partialMultTopRightExtend;
    logic [15:0] partialMultTopLeftExtend;
    logic [15:0] partialMultBottomRightExtend;
    logic [15:0] partialMultBottomLeftExtend;
    logic [15:0] correctionOnes16bit;

    logic [15:0] fullProduct;
    logic [15:0] halvedProducts;

    assign partialMultTopRightExtend = {8'b0, partialMultTopRight};
    assign partialMultTopLeftExtend = {4'b0, partialMultTopLeft, 4'b0};
    assign partialMultBottomRightExtend = {4'b0, partialMultBottomRight, 4'b0};
    assign partialMultBottomLeftExtend = {partialMultBottomLeft, 8'b0};

    // See Modified Baugh-Wooley Algorithm for the correction term
    assign correctionOnes16bit = 16'b1000_0001_0000_0000;

    assign fullProduct =
    partialMultTopRightExtend +
    partialMultTopLeftExtend +
    partialMultBottomRightExtend +
    partialMultBottomLeftExtend +
    correctionOnes16bit;

    assign halvedProducts = {
        partialMultBottomLeft,
        partialMultTopRight
    } ;

    assign product = (halvedPrecision[1] | halvedPrecision[0]) ? halvedProducts : fullProduct;

    config_multiplier_4bit multTopRight (
        .multiplier(multiplier[3:0]),
        .multiplicand(multiplicand[3:0]),
        .product(partialMultTopRight),
        .invertFirstBit(halvedPrecision[1]),
        .invertSecondRow(halvedPrecision[1]),
        .halvedPrecision(halvedPrecision[0]),
        .continueHigher(halvedPrecision == 2'b0)
    );

    config_multiplier_4bit multTopLeft (
        .multiplier(multiplier[3:0]),
        .multiplicand(multiplicand[7:4]),
        .product(partialMultTopLeft),
        .invertFirstBit(1'b1),
        .invertSecondRow(1'b0),
        .halvedPrecision(halvedPrecision[0]),
        .continueHigher(halvedPrecision == 2'b0)
    );

    config_multiplier_4bit multBottomRight (
        .multiplier(multiplier[7:4]),
        .multiplicand(multiplicand[3:0]),
        .product(partialMultBottomRight),
        .invertFirstBit(1'b0),
        .invertSecondRow(1'b1),
        .halvedPrecision(halvedPrecision[0]),
        .continueHigher(halvedPrecision == 2'b0)
    );

    config_multiplier_4bit multBottomLeft (
        .multiplier(multiplier[7:4]),
        .multiplicand(multiplicand[7:4]),
        .product(partialMultBottomLeft),
        .invertFirstBit(halvedPrecision[1] ? 1'b1 : 1'b1),
        .invertSecondRow(halvedPrecision[1] ? 1'b1 : 1'b1),
        .halvedPrecision(halvedPrecision[0]),
        .continueHigher(halvedPrecision == 2'b0)
    );
endmodule
