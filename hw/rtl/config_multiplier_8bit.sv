module config_multiplier_8bit (
    input logic signed [7:0] multiplier,
    input logic signed [7:0] multiplicand,
    input bit halvedPrecision = 0,
    output logic signed [15:0] product
); 
    logic [7:0] partProduct1;
    logic [11:0] partProduct2;
    logic [7:0] partProduct3;
    logic [7:0] partProduct4;

    config_shiftadder_4bit #(
        .configurable(1),
        .zeroExtend(1)
    ) shiftadder1 (
        .multiplier(multiplier[3:0]),
        .multiplicand(multiplicand[3:0]),
        .halvedPrecision(halvedPrecision),
        .product(partProduct1)
    );

    config_shiftadder_4bit #(
        .configurable(0),
        .zeroExtend(0),
        .lengthOutput(12)
    ) shiftadder2 (
        .multiplier(multiplier[3:0]),
        .multiplicand(multiplicand[7:4]),
        .halvedPrecision(halvedPrecision),
        .product(partProduct2)
    );


    logic [7:0] term1, term2, term3, term4;
    assign term1 = multiplier[4] ? {{4'b0}, multiplicand[3:0]} :  0;
    assign term2 = multiplier[5] ? {{3'b0}, multiplicand[3:0], 1'b0} : 0;
    assign term3 = multiplier[6] ? {{2'b0}, multiplicand[3:0], 2'b0} : 0;
    assign term4 = multiplier[7] ? {1'b0, ~multiplicand[3:0], 3'b0} + {8'b00001000} : 0;
    assign partProduct3 = term1 + term2 + term3 + term4 ;

     config_shiftadder_4bit #(
        .configurable(1),
        .zeroExtend(0),
        .invertLast(1)
    ) shiftadder4 (
        .multiplier(multiplier[7:4]),
        .multiplicand(multiplicand[7:4]),
        .halvedPrecision(halvedPrecision),
        .product(partProduct4)
    );

    assign product = halvedPrecision ? {partProduct4, partProduct1} : (partProduct1 + (partProduct2 << 4) + (partProduct3 << 4) + (partProduct4 << 8));

    
endmodule