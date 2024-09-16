// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Configurable 2-bit multiplier that can be configured to perform signed 2-bit multiplication
// or be part of a higher precision multiplication.
// The algorithm used is a modified Baugh-Wooley Algorithm (see doc/figs/modified_baugh_wooley.png),
// the invert signals are used to correctly perform this algorithm for higher precision multiplications

module mult_2bit (
    input logic [1:0] multiplier,
    input logic [1:0] multiplicand,
    output logic [3:0] product,

    input logic invertFirstBit,
    input logic invertSecondRow
);
    logic [1:0] firstTerm;
    logic [1:0] secondTerm;
    logic [1:0] tempFirstTerm;
    logic [1:0] tempSecondTerm;

    assign tempFirstTerm = multiplier[0] ? multiplicand : 0;
    assign firstTerm = invertFirstBit ? {~tempFirstTerm[1], tempFirstTerm[0]} : tempFirstTerm;

    assign tempSecondTerm = multiplier[1] ?
    (invertSecondRow ? ~multiplicand : multiplicand) :
    (invertSecondRow ? 2'b11 : 2'b00);

    assign secondTerm = invertFirstBit ? {~tempSecondTerm[1], tempSecondTerm[0]} : tempSecondTerm;

    assign product = {1'b0, firstTerm} + {secondTerm, 1'b0};

endmodule
