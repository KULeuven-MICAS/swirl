module tb_config_shiftadder_4bit;

    logic signed [3:0] multiplier;
    logic signed [3:0] multiplicand;
    logic halvedPrecision;
    logic signed [7:0] product;

    config_shiftadder_4bit #(
        .configurable(1),
        .zeroExtend(1) 
    ) shiftadder_4bit (
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .halvedPrecision(halvedPrecision),
        .product(product)
    );

    initial begin
        $monitor("product=%b", product);
        $dumpfile("config_shiftadder_4bit.vcd");
        $dumpvars(0, tb_config_shiftadder_4bit);
        multiplicand = 3;
        multiplier = 3;
        halvedPrecision = 1;
        #10;
        multiplicand = -3;
        multiplier = 3;
        halvedPrecision = 1;
        #10;
        multiplicand = -3;
        multiplier = -3;
        halvedPrecision = 1;
        #10;
        multiplicand = 4'b1011;
        multiplier = 4'b1011;
        halvedPrecision = 0;
        #10;
        multiplicand = 4'b1111;
        multiplier = 4'b1111;
        halvedPrecision = 0;
        #10;
        multiplicand = 4'b0;
        multiplier = 4'b0;
        halvedPrecision = 0;
        #10;

    end
endmodule