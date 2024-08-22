module tb_config_multiplier_2bit;

    logic [1:0] multiplier;
    logic [1:0] multiplicand;
    logic halvedPrecision;
    logic [3:0] product;

    config_multiplier_2bit multiplier_2bit (
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .halvedPrecision(halvedPrecision),
        .product(product)
    );

    initial begin
        $monitor("multiplier=%d, multiplicand=%d, halvedPrecision=%d, product=%d, halfmultiplier1=%d, halfmultiplicand1=%d, halfproduct1=%d, halfmultiplier2=%d, halfmultiplicand2=%d, halfproduct2=%d", multiplier, multiplicand, halvedPrecision, product, multiplier[1], multiplicand[1], product[3:2], multiplier[0], multiplicand[0], product[1:0]);
        multiplier = 2'b00;
        multiplicand = 2'b00;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b00;
        multiplicand = 2'b01;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b00;
        multiplicand = 2'b10;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b00;
        multiplicand = 2'b11;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b00;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b01;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b10;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b11;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b00;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b01;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b10;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b11;
        halvedPrecision = 1'b0;
        #10;
        multiplier = 2'b11;
        multiplicand = 2'b00;
        halvedPrecision = 1'b0;
        #10;
        
        multiplier = 2'b00;
        multiplicand = 2'b00;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b00;
        multiplicand = 2'b01;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b00;
        multiplicand = 2'b10;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b00;
        multiplicand = 2'b11;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b00;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b01;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b10;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b01;
        multiplicand = 2'b11;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b00;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b01;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b10;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b10;
        multiplicand = 2'b11;
        halvedPrecision = 1'b1;
        #10;
        multiplier = 2'b11;
        multiplicand = 2'b00;
        halvedPrecision = 1'b1;
    end
endmodule