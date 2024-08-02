module tb_config_multiplier_8bit;

    logic signed [7:0] multiplier;
    logic signed [7:0] multiplicand;
    logic halvedPrecision;
    logic signed [15:0] product;

    config_multiplier_8bit config_multiplier_8bit (
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .halvedPrecision(halvedPrecision),
        .product(product)
    );

    initial begin
        //$monitor("mult1 = %b, mult2 = %b, product=%b", multiplier, multiplicand, product);
        logic signed [7:0] mult1;
        logic signed [7:0] mult2;
        logic signed [3:0] multiplier1;
        logic signed [3:0] multiplier2;
        logic signed [3:0] multiplicand1;
        logic signed [3:0] multiplicand2;
        assign mult1 = product[7:0];
        assign mult2 = product[15:8];
        assign multiplier1 = multiplier[3:0];
        assign multiplier2 = multiplier[7:4];
        assign multiplicand1 = multiplicand[3:0];
        assign multiplicand2 = multiplicand[7:4];
        $monitor("multiplier1 = %d, multiplicand1 = %d, product1=%d, multiplier2 = %d, multiplicand2 = %d, product2=%d", multiplier1, multiplicand1, mult1, multiplier2, multiplicand2, mult2);
        $dumpfile("tb_config_multiplier_8bit.vcd");
        $dumpvars(0, tb_config_multiplier_8bit);
        /*
        multiplicand = 3;
        multiplier = 3;
        halvedPrecision = 0;
        #10;
        multiplicand = -3;
        multiplier = 3;
        halvedPrecision = 0;
        #10;
        multiplicand = 96;
        multiplier = 96;
        halvedPrecision = 0;
        #10;
        multiplicand = 96;
        multiplier = 6;
        halvedPrecision = 0;
        #10;
        multiplicand = -1;
        multiplier = -1;
        halvedPrecision = 0;
        #10;
        multiplicand = -20;
        multiplier = -2;
        halvedPrecision = 0;
        #10;
        multiplicand = 100;
        multiplier = -10;
        halvedPrecision = 0;
        */
        #10;
        multiplicand = 8'b00010001;
        multiplier = 8'b00010001;
        halvedPrecision = 1;
        #10;
        multiplicand = 8'b11111111;
        multiplier = 8'b10101010;
        halvedPrecision = 1;
        #10;
        multiplicand = 8'b11101001;
        multiplier = 8'b10001000;
        halvedPrecision = 1;
        #10;
        multiplicand = 8'b11101001;
        multiplier = 8'b00000010;
        halvedPrecision = 1;
        #10;
        multiplicand = 0;
        multiplier = 0;
        halvedPrecision = 0;


    end
endmodule