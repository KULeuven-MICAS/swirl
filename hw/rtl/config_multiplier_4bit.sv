module config_multiplier_4bit (
    input logic signed [3:0] multiplier,
    input logic signed [3:0] multiplicand,
    input logic halvedPrecision,
    input logic continueHigher,
    input bit invertFirstBit,
    input bit invertSecondRow,
    output logic signed [7:0] product
);
    logic [3:0] partialMultTopRight;
    logic [3:0] partialMultTopLeft;
    logic [3:0] partialMultBottomRight;
    logic [3:0] partialMultBottomLeft;

    logic [7:0] partialMultTopRightExtend;
    logic [7:0] partialMultTopLeftExtend;
    logic [7:0] partialMultBottomRightExtend;
    logic [7:0] partialMultBottomLeftExtend;
    logic [7:0] correctionOnes8bit;
    logic [3:0] correctionOnes4bit;

    logic [7:0] fullProduct;
    logic [7:0] halvedProducts;

    assign partialMultTopRightExtend = {4'b0, partialMultTopRight};
    assign partialMultTopLeftExtend = {2'b0, partialMultTopLeft, 2'b0};
    assign partialMultBottomRightExtend = {2'b0, partialMultBottomRight, 2'b0};
    assign partialMultBottomLeftExtend = {partialMultBottomLeft, 4'b0};
    // For used algorithm logic, see modified Baugh-Wooley Algorithm
    assign correctionOnes8bit = continueHigher? 8'b0000_0000 : 8'b1001_0000;
    assign correctionOnes4bit = 4'b1100;

    assign fullProduct =
    partialMultTopRightExtend +
    partialMultTopLeftExtend +
    partialMultBottomRightExtend +
    partialMultBottomLeftExtend +
    correctionOnes8bit;

    assign halvedProducts = {
        partialMultBottomLeft + correctionOnes4bit,
        partialMultTopRight + correctionOnes4bit
        };

    assign product = halvedPrecision ? halvedProducts : fullProduct;

    mult_2bit multTopRight (
        .multiplier(multiplier[1:0]),
        .multiplicand(multiplicand[1:0]),
        .product(partialMultTopRight),
        .invertFirstBit(halvedPrecision),
        .invertSecondRow(halvedPrecision)
    );

    mult_2bit multTopLeft (
        .multiplier(multiplier[1:0]),
        .multiplicand(multiplicand[3:2]),
        .product(partialMultTopLeft),
        .invertFirstBit(invertFirstBit),
        .invertSecondRow(1'b0)
    );

    mult_2bit multBottomRight (
        .multiplier(multiplier[3:2]),
        .multiplicand(multiplicand[1:0]),
        .product(partialMultBottomRight),
        .invertFirstBit(1'b0),
        .invertSecondRow(invertSecondRow)
    );

    mult_2bit multBottomLeft (
        .multiplier(multiplier[3:2]),
        .multiplicand(multiplicand[3:2]),
        .product(partialMultBottomLeft),
        .invertFirstBit(halvedPrecision ? 1'b1 : invertFirstBit),
        .invertSecondRow(halvedPrecision ? 1'b1 : invertSecondRow)
    );

endmodule
