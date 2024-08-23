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