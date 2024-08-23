module tb_config_multiplier_4bit;

    logic signed [3:0] multiplier;
    logic signed [1:0] multiplierPart1;
    logic signed [1:0] multiplierPart2;
    logic signed [3:0] multiplicand;
    logic signed [1:0] multiplicandPart1;
    logic signed [1:0] multiplicandPart2;
    logic signed [7:0] testOut8bit;
    logic signed [3:0] testOut4bit1;
    logic signed [3:0] testOut4bit2;
    
    logic halvedPrecision;
    logic signed [7:0] product;

    config_multiplier_4bit multiplier_4bit (
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .halvedPrecision(halvedPrecision),
        .continueHigher(1'b0),
        .product(product),
        .invertFirstBit(1'b1),
        .invertSecondRow(1'b1)
    );

    localparam RANDOM_TESTS = 10;

    initial begin
        $dumpfile("config_multiplier_4bit.vcd");
        $dumpvars(0, tb_config_multiplier_4bit);

        halvedPrecision = 0;
        $display("#### Running random full precision tests ####");
        for (int i = 0; i < RANDOM_TESTS; i++) begin
            multiplicand = $random;
            multiplier = $random;
            testOut8bit = multiplicand * multiplier;
            #10;
            assert(product == testOut8bit) else begin
                $display("Error: %0d * %0d = %2d, but got %2d", multiplicand, multiplier, testOut8bit, product);
                $fatal;
            end
            $display("Success: %0d * %0d = %0d", multiplicand, multiplier, product);
        end

        $display("#### Running edge case tests ####");
        multiplicand = -8;
        multiplier = -8;
        testOut8bit = multiplicand * multiplier;
        #10;
        assert(product == testOut8bit) else begin
            $display("Error: %0d * %0d = %2d, but got %2d", multiplicand, multiplier, testOut8bit, product);
            $fatal;
        end
        $display("Success: %0d * %0d = %0d", multiplicand, multiplier, product);

        multiplicand = 7;
        multiplier = 7;
        testOut8bit = multiplicand * multiplier;
        #10;
        assert(product == testOut8bit) else begin
            $display("Error: %0d * %0d = %2d, but got %2d", multiplicand, multiplier, testOut8bit, product);
            $fatal;
        end
        $display("Success: %0d * %0d = %0d", multiplicand, multiplier, product);

        multiplicand = -8;
        multiplier = 0;
        testOut8bit = multiplicand * multiplier;
        #10;
        assert(product == testOut8bit) else begin
            $display("Error: %0d * %0d = %2d, but got %2d", multiplicand, multiplier, testOut8bit, product);
            $fatal;
        end
        $display("Success: %0d * %0d = %0d", multiplicand, multiplier, product);

        halvedPrecision = 1;

        multiplicandPart1 = 0;
        multiplicandPart2 = 0;
        multiplierPart1 = 0;
        multiplierPart2 = 0;
        multiplicand = {multiplicandPart1, multiplicandPart2};
        multiplier = {multiplierPart1, multiplierPart2};

        testOut4bit1 = multiplicandPart1 * multiplierPart1;
        testOut4bit2 = multiplicandPart2 * multiplierPart2;
        testOut8bit = {testOut4bit1, testOut4bit2};

        #10;

        $display("#### Running random halved precision tests ####");
        for (int i = 0; i < RANDOM_TESTS; i++) begin
            multiplicandPart1 = $random;
            multiplicandPart2 = $random;
            multiplierPart1 = $random;
            multiplierPart2 = $random;
            multiplicand = {multiplicandPart1, multiplicandPart2};
            multiplier = {multiplierPart1, multiplierPart2};

            testOut4bit1 = multiplicandPart1 * multiplierPart1;
            testOut4bit2 = multiplicandPart2 * multiplierPart2;
            testOut8bit = {testOut4bit1, testOut4bit2};

            #10;
            assert(product == testOut8bit) else begin
                $display("Error: %0d * %0d = %0d and %0d * %0d = %0d, but got %0d and %0d", multiplicandPart1, multiplierPart1,testOut4bit1, multiplicandPart2, multiplierPart2,testOut4bit2, product[7:4], product[3:0]);
                $fatal;
            end
            $display("Succes: %0d * %0d = %0d and %0d * %0d = %0d", multiplicandPart1, multiplierPart1, signed'(product[7:4]), multiplicandPart2, multiplierPart2, signed'(product[3:0]));
        end

    end
endmodule