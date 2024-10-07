// Copyright 2024 KU Leuven.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Author: Mats Vanhamel <mats.vanhamel@student.kuleuven.be>
//
// Module description:
// Matrix MAC (Multiplication Accumulation A*B+C) module that calculates result bit-serially.
// The module uses the modified Baugh-Wooley algorithm (see doc/figs/modified_baugh_wooley.png) to calculate the multiplication of two numbers in steps
// of P bits (though only implemented for P=2) and accumulates these chunks of P(=2) bits to calculate the final result.
// 2- to 14-bit signed numbers are supported, with the width of the numbers being a multiple of P(=2) and inputs can have different widths.
//
// SEE doc/figs/seq_MAC.pdf FOR A GRAPHICAL REPRESENTATION OF THE MODULE
//
// Parameters:
// - M: number of rows of the A matrix
// - N: number of columns of the B matrix
// - K: number of columns of the A matrix and rows of the B matrix
// - MAX_WIDTH: maximum width bits of the input data
// - P: number of bits calculated in each step (only implemented for P=2)
// - MANUAL_PIPELINE: one pipeline stage added for minor frequency increase
//
// Possible improvements / explorations:
// - Remove internal accumulation inside sequential multipliers => place this in/after
//   tree adder. This is expected to reduce the unit's area significantly.
//   Possibility: push 2x2 mult 4-bit output straight to tree adder and remove
//   carry count and shifting of the seq_mult unit. Note: Baugh-Wooley correction ones
//   would need to be implemented outside of multipliers (now done in carry count).
// - Reconsider accumulation after tree adder. Right now this is done in 32 bits because
//   for two 16-bit inputs the multiplication result can be 32 bits, so tree output is shifted
//   and extended to 32 bits to be added in 32-bit adder. However if we assume a 16-bit total
//   input size, the multiplication result will be 16 bits max and we can maybe accumulate in
//   16-bit, then extend to 32-bit for output.
// - Detect zeros at start of inputs and change the bitsize input accordingly.
// - Accumulating from MSB to LSB could reduce the shifting logic after adder tree, but carries
//   would ripple more in the accumulation adder.
// - Pipelining to drive up clockspeed
//

module seq_MAC #(
    parameter int M = 2,
    parameter int N = 2,
    parameter int K = 2,
    parameter int MAX_WIDTH = 16,
    parameter int P = 2,
    parameter logic MANUAL_PIPELINE = 0
)(
    input logic clk_i,
    input logic rst_ni,
    input wire signed [MAX_WIDTH-1:0] A_mul [M][K],
    input wire signed [MAX_WIDTH-1:0] B_mul [K][N],
    input wire signed [31:0] C_mul [M][N],
    input logic unsigned [3:0] bitSizeA,
    input logic unsigned [3:0] bitSizeB,
    input wire valid_in,
    output wire ready_in,
    output wire valid_out,
    output wire [31:0] D [M][N],
    input wire ready_out
);
    // initial begin
    //     $dumpfile("seq_MAC.vcd");
    //     $dumpvars(0, B_mul_reg);
    // end

    // bits needed to represent bitSize in steps of P
    localparam int MaxBitWidth = $clog2(MAX_WIDTH/P) + 1;

    // shorthand parameter
    localparam int MB = MaxBitWidth;


    logic countLast1Active, countLast2Active, countLast3Active;
    logic countLast1, countLast2, countLast3;
    logic ce1, ce2, ce3, rstCount;
    logic [MB-1:0] countOut1, countOut2, countOut3;
    logic [MB:0] shiftCount;
    logic busy;
    logic invertFirstBit, invertSecondRow;
    logic [2:0] muxSelA, muxSelB;
    logic [MB-1:0] muxSelOffsetCountdown;
    logic [MB-1:0] muxSelOffsetDiff;
    logic [MB-1:0] muxSelOffsetA;
    logic [MB-1:0] muxSelOffsetB;
    logic placeOne;
    logic start;
    logic newOut;
    logic [1:0] countShiftInput;
    logic [MB-1:0] bitSizeMin;
    logic [MB-1:0] bitSizeDiff;
    logic largerA;
    logic [4*P-1:0] initSum;

    reg lastOut;
    reg lastMultAccum;
    reg valid_out_reg;
    reg countDown;

    reg [MAX_WIDTH-1:0] A_mul_reg [M][K];
    reg [MAX_WIDTH-1:0] B_mul_reg [K][N];

    reg [MB-1:0] bitSizeB_reg;
    reg [MB-1:0] bitSizeA_reg;

    assign countLast1Active = countLast1 & busy;
    assign countLast2Active = countLast2 & busy;
    assign countLast3Active = countLast3 & busy;

    assign valid_out = valid_out_reg;
    assign stall = (valid_out & ~ready_out) | busy;
    assign start = valid_in & ~stall;
    assign ready_in = ~stall;

    assign invertFirstBit = muxSelB == (bitSizeB_reg - 1);
    assign invertSecondRow = muxSelA == (bitSizeA_reg -1);

    assign muxSelOffsetCountdown = countDown? bitSizeMin - 1 - countOut1 : 0;
    assign muxSelOffsetDiff = countOut3;

    assign muxSelA = largerA ?
    countOut2 + muxSelOffsetCountdown + muxSelOffsetDiff :
    countOut2 + muxSelOffsetCountdown;

    assign muxSelB = largerA ?
    countOut1 - countOut2 + muxSelOffsetCountdown :
    countOut1 - countOut2 + muxSelOffsetCountdown + muxSelOffsetDiff;

    logic placeOne1, placeOne2, placeOne3;

    assign placeOne1 = (bitSizeDiff == 0)?
    ( (shiftCount == bitSizeB_reg) ? 1'b1 : 1'b0 ) :
    ( (shiftCount == bitSizeB_reg-1) ? 1'b1 : 1'b0 );

    assign placeOne2 = (bitSizeDiff == 0)?
    ( (shiftCount == bitSizeA_reg) ? 1'b1 : 1'b0 ) :
    ( (shiftCount == bitSizeA_reg-1) ? 1'b1 : 1'b0 );

    assign placeOne3 = (shiftCount == bitSizeA_reg + bitSizeB-1) ? 1'b1 : 1'b0;


    assign placeOne = placeOne1 | placeOne2 | placeOne3;

    assign rstCount = start;
    assign ce1 = countLast2Active & ~ce3;
    assign ce2 = busy;
    assign ce3 = countLast1Active & countLast2Active & ~countLast3Active;

    assign largerA = bitSizeA_reg > bitSizeB_reg;
    assign bitSizeMin = largerA? bitSizeB_reg : bitSizeA_reg;
    assign bitSizeDiff = largerA? (bitSizeA_reg - bitSizeB_reg) : (bitSizeB_reg - bitSizeA_reg);

    assign initSum =
    (8'b00000010 << (2*(bitSizeA-1))) +
    (8'b00000010 << (2*(bitSizeB-1))) +
    (8'b00000010 << (2*(bitSizeA+bitSizeB-1)));

    always_ff @(posedge clk_i, negedge rst_ni) begin
            if (~rst_ni) begin
                bitSizeB_reg <= 0;
                bitSizeA_reg <= 0;
            end else if (start) begin
                bitSizeB_reg <= bitSizeB;
                bitSizeA_reg <= bitSizeA;
            end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                busy <= 0;
            end else if (start) begin
                busy <= 1'b1;
            end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                countDown <= 1'b0;
            end else if (start) begin
                if (bitSizeA == 1 | bitSizeB == 1) begin
                    countDown <= 1'b1;
                end else begin
                    countDown <= 1'b0;
                end
            end else if (countLast1Active & countLast2Active & countLast3Active & ~countDown) begin
                countDown <= 1'b1;
            end else begin
                countDown <= countDown;
            end
    end

    if (MANUAL_PIPELINE) begin : gen_pipeline_lastOut

        reg [1:0] countShiftInput_pipe;
        always_ff @(posedge clk_i or negedge rst_ni) begin
            if (~rst_ni) begin
                countShiftInput_pipe <= 2'b00;
            end else begin
                countShiftInput_pipe <= placeOne1 ? (
                placeOne2 ? 2'b01 : 2'b10
                ) : placeOne2 ? 2'b10 :
                placeOne3 ? 2'b10 : 2'b00;
            end
        end

        assign countShiftInput = countShiftInput_pipe;

        reg lastOut_pipe;
        always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                lastOut_pipe <= 1'b0;
            end else if (start) begin
                lastOut_pipe <= 1'b0;
            end else if (countOut1 == 0 & countDown & countLast3Active) begin
                lastOut_pipe <= 1'b1;
            end else begin
                lastOut_pipe <= 1'b0;
            end
        end

        always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                lastOut <= 1'b0;
            end else begin
                lastOut <= lastOut_pipe;
            end
        end

        reg newOut_pipe;
        always_ff @(posedge clk_i, negedge rst_ni) begin
                if (!rst_ni) begin
                    newOut_pipe <= 1'b0;
                end else if (start) begin
                    newOut_pipe <= 1'b0;
                end else if ( (countLast2Active | lastOut_pipe) & busy) begin
                    newOut_pipe <= 1'b1;
                end else begin
                    newOut_pipe <= 1'b0;
                end
            end
        always_ff @(posedge clk_i, negedge rst_ni) begin
                if (!rst_ni) begin
                    newOut <= 1'b0;
                end else begin
                    newOut <= newOut_pipe;
                end
        end

    end else begin : gen_no_pipeline_lastOut

        assign countShiftInput = placeOne1 ? (
            placeOne2 ? 2'b01 : 2'b10
        ) : placeOne2 ? 2'b10 :
        placeOne3 ? 2'b10 : 2'b00;

        always_ff @(posedge clk_i, negedge rst_ni) begin
                if (!rst_ni) begin
                    lastOut <= 1'b0;
                end else if (start) begin
                    lastOut <= 1'b0;
                end else if (countOut1 == 0 & countDown & countLast3Active) begin
                    lastOut <= 1'b1;
                end else begin
                    lastOut <= 1'b0;
                end
        end

        always_ff @(posedge clk_i, negedge rst_ni) begin
                if (!rst_ni) begin
                    newOut <= 1'b0;
                end else if (start) begin
                    newOut <= 1'b0;
                end else if ( (countLast2Active | lastOut) & busy) begin
                    newOut <= 1'b1;
                end else begin
                    newOut <= 1'b0;
                end
            end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                lastMultAccum <= 1'b0;
            end else if (start) begin
                lastMultAccum <= 1'b0;
            end else if (lastOut) begin
                lastOut <= 1'b0;
                lastMultAccum <= 1'b1;
            end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                valid_out_reg <= 1'b0;
            end else if (lastMultAccum) begin
                valid_out_reg <= 1'b1;
                lastMultAccum <= 1'b0;
                busy <= 1'b0;
            end else if (valid_out & stall) begin
                valid_out_reg <= 1'b1;
            end else begin
                valid_out_reg <= 1'b0;
            end
    end

    logic unsigned [MB-1:0] count1_start;
    assign count1_start =  bitSizeMin - 1'b1;

    programmable_counter #(.WIDTH(MB), .UPDOWN(1'b1)) count1 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(rstCount),
        .en_i(ce1),
        .load_i(1'b0),
        .down_i(countDown),
        .countSet(count1_start),
        .d_i(),
        .q_o(countOut1),
        .last_o(countLast1)
    );

    programmable_counter #(.WIDTH(MB), .UPDOWN(1'b0)) count2 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(rstCount),
        .en_i(ce2),
        .load_i(1'b0),
        .down_i(1'b0),
        .countSet(countOut1),
        .d_i(),
        .q_o(countOut2),
        .last_o(countLast2)
    );

    programmable_counter #(.WIDTH(MB), .UPDOWN(1'b0)) count3 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(rstCount),
        .en_i(ce3),
        .load_i(1'b0),
        .down_i(1'b0),
        .countSet(bitSizeDiff),
        .d_i(),
        .q_o(countOut3),
        .last_o(countLast3)
    );

    localparam logic [MB:0] TotalProductWidth = 2*MAX_WIDTH/P; // width in chunks of P
    logic [MB:0] count4_start = 4;

    programmable_counter #(.WIDTH(MB+1), .UPDOWN(1'b0)) count4 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(1'b0),
        .en_i(countLast2Active),
        .load_i(start),
        .down_i(1'b0),
        .countSet(TotalProductWidth),
        .d_i(count4_start),
        .q_o(shiftCount),
        .last_o()
    );

        genvar n, m, k;

        logic [1:0] a_i[M][K];

        for (m = 0; m < M; m = m + 1) begin : gen_A_row
            for (k = 0; k < K; k = k + 1) begin : gen_A_column
                always_ff @(posedge clk_i, negedge rst_ni) begin
                    if (~rst_ni) begin
                        A_mul_reg[m][k] <= 0;
                    end else if (start) begin
                        A_mul_reg[m][k] <= A_mul[m][k];
                    end
                end

                generic_mux #(
                    .WIDTH(P),
                    .NUMBER(8)
                ) mux_a (
                    .mux_in('{
                        A_mul_reg[m][k][P-1:0], A_mul_reg[m][k][2*P-1:P],
                        A_mul_reg[m][k][3*P-1:2*P], A_mul_reg[m][k][4*P-1:3*P],
                        A_mul_reg[m][k][5*P-1:4*P], A_mul_reg[m][k][6*P-1:5*P],
                        A_mul_reg[m][k][7*P-1:6*P], A_mul_reg[m][k][8*P-1:7*P]}),
                    .sel(muxSelA),
                    .out(a_i[m][k])
                );
            end
        end

        logic [1:0] b_i[K][N];

        for (k = 0; k < K; k = k + 1) begin : gen_B_row
            for (n = 0; n < N; n = n + 1) begin : gen_B_column
                always_ff @(posedge clk_i, negedge rst_ni) begin
                    if (~rst_ni) begin
                        B_mul_reg[k][n] <= 0;
                    end else if (start) begin
                        B_mul_reg[k][n] <= B_mul[k][n];
                    end
                end

                generic_mux #(
                    .WIDTH(P),
                    .NUMBER(8)
                ) mux_b (
                    .mux_in('{
                        B_mul_reg[k][n][P-1:0], B_mul_reg[k][n][2*P-1:P],
                        B_mul_reg[k][n][3*P-1:2*P], B_mul_reg[k][n][4*P-1:3*P],
                        B_mul_reg[k][n][5*P-1:4*P], B_mul_reg[k][n][6*P-1:5*P],
                        B_mul_reg[k][n][7*P-1:6*P], B_mul_reg[k][n][8*P-1:7*P]}),
                    .sel(muxSelB),
                    .out(b_i[k][n])
                );
            end
        end



        for (n = 0; n < N; n = n + 1) begin : gen_column_block
            for (m = 0; m < M; m = m + 1) begin: gen_row_block

                logic [P-1:0] partial_mults [K];

                for (k = 0; k < K; k = k + 1) begin : gen_element_block
                seq_mult #(
                .P(P),
                .MAX_WIDTH(MAX_WIDTH),
                .MANUAL_PIPELINE(MANUAL_PIPELINE)
                ) seq_mult (
                    .clk_i(clk_i),
                    .rst_n(rst_ni),
                    .a_i(a_i[m][k]),
                    .b_i(b_i[k][n]),
                    .p(partial_mults[k]),
                    .countDown(countDown),
                    .shift(countLast2Active),
                    .invertFirstBit(invertFirstBit),
                    .invertSecondRow(invertSecondRow),
                    .start(start),
                    .placeOne(placeOne),
                    .lastOut(lastOut),
                    .countShiftInput(countShiftInput),
                    .initSum(initSum)
                );
            end

                logic unsigned [P + $clog2(K)-1:0] mult_sum;
                logic unsigned [31:0] sum;

                binary_tree_adder #(
                    .P(2),
                    .INPUTS_AMOUNT(K),
                    .MODE(1) // unsigned or signed mode (signedAddition set to 0 or 1)
                ) tree_add (
                    .inputs(partial_mults),
                    .out(mult_sum),
                    .signedAddition(lastMultAccum),
                    .out_32bit() // not used
                );


                reg [31:0] accum_mult;
                logic [31:0] accum_mult_next;

                logic [4:0] offsetCount;
                logic [31:0] mult_sum_extend;

                logic signed [P + $clog2(K):0] mult_sum_signed;
                assign mult_sum_signed = lastMultAccum & mult_sum[P + $clog2(K)-1] ?
                {1'b1, mult_sum} : {1'b0, mult_sum};
                assign mult_sum_extend = mult_sum_signed << offsetCount;

                always_ff @(posedge clk_i or negedge rst_ni) begin
                    if (~rst_ni) begin
                        accum_mult <= 0;
                    end else if (start) begin
                        accum_mult <= C_mul[m][n];
                        offsetCount <= 0;
                    end else if (newOut) begin
                        accum_mult <= accum_mult_next;
                        offsetCount <= offsetCount + P;
                    end
                end

                bitwise_add #(
                    .P(32)
                ) C_add (
                    .a(accum_mult),
                    .b(mult_sum_extend),
                    .sum(accum_mult_next)
                );

                assign D[m][n] = accum_mult;
        end
    end
endmodule
