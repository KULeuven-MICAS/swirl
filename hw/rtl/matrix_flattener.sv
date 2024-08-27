// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Module that flattens a 2D (packed) matrix into a 1D (unpacked) vector
// used specifically for synthesis tool restrictions regarding packed types
//
// Parameters:
// - WIDTH: width of the matrix
// - HEIGHT: height of the matrix
// - P: number of bits of the seperate elements of the matrix

module matrix_flattener #(
    parameter int WIDTH = 8,
    parameter int HEIGHT = 4,
    parameter int P = 8
)(
    input logic signed [P-1:0] A [HEIGHT][WIDTH],
    output logic [(WIDTH*HEIGHT)*P-1:0] data_out
);

    always_comb begin
        automatic int index = 0;
        // Flatten A
        for (int i = 0; i < HEIGHT; i++) begin
            for (int j = 0; j < WIDTH; j++) begin
                data_out[(WIDTH*HEIGHT)*P-index-1 -: P] = A[i][j];
                index += P;
            end
        end
    end

endmodule
