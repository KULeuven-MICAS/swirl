module tb_config_multiplier_8bit;

    logic signed [7:0] multiplier;
    logic signed [7:0] multiplicand;
    logic [1:0] halvedPrecision;
    logic signed [15:0] product;
    logic signed [15:0] expected_output;

    config_multiplier_8bit config_multiplier_8bit (
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .halvedPrecision(halvedPrecision),
        .product(product)
    );

    parameter int NUM_TESTS_8bit = 8;
    logic signed [7:0] test_multiplier_8bit[NUM_TESTS_8bit] =   '{0, -128, 1, 127,    -1, -1, -128, -128};
    logic signed [7:0] test_multiplicand_8bit[NUM_TESTS_8bit] = '{0, 16, 2, 127,     5, -1,   -1, 16};
    logic signed [15:0] expected_outputs_8bit[NUM_TESTS_8bit] = '{0, -2048, 2, 16129,  -5,  1,  128, -2048};

    parameter int NUM_TESTS_4bit = 6;
    logic signed [3:0] test_multiplier1_4bit[NUM_TESTS_4bit] =   '{0, 1, 7,   -1,  4, -8};
    logic signed [3:0] test_multiplicand1_4bit[NUM_TESTS_4bit] = '{0, 2, 7,    5, -2,  -8};
    logic signed [7:0] expected_outputs1_4bit[NUM_TESTS_4bit] =  '{0, 2, 49,  -5, -8, 64};

    logic signed [3:0] test_multiplier2_4bit[NUM_TESTS_4bit] =   '{0,  3,  7,  -1,  4,  -8};
    logic signed [3:0] test_multiplicand2_4bit[NUM_TESTS_4bit] = '{0,  4, -7,  5,  2,   7};
    logic signed [7:0] expected_outputs2_4bit[NUM_TESTS_4bit] =  '{0, 12, -49,  -5,  8, -56};

    parameter int NUM_TESTS_2bit = 4;
    logic signed [1:0] test_multiplier1_2bit[NUM_TESTS_2bit] =   '{0, 1, -2,  0};
    logic signed [1:0] test_multiplicand1_2bit[NUM_TESTS_2bit] = '{0, -2,  1, -2};
    logic signed [3:0] expected_outputs1_2bit[NUM_TESTS_2bit] =  '{0, -2, -2, 0};

    // Run tests
    initial begin
        $dumpfile("tb_config_multiplier_8bit.vcd");
        $dumpvars(0, tb_config_multiplier_8bit);

        for (int i = 0; i < NUM_TESTS_8bit; i++) begin
        multiplier = test_multiplier_8bit[i];
        multiplicand = test_multiplicand_8bit[i];
        halvedPrecision = 2'b00;
        expected_output = expected_outputs_8bit[i];
        #5;
        assert(product == expected_output) else $fatal(
            1, "Test %0d failed: multiplier=%0d, multiplicand=%0d, expected_output=%b, got %b",
            i, test_multiplier_8bit[i], test_multiplicand_8bit[i], expected_outputs_8bit[i], product);
         end

        for (int i = 0; i < NUM_TESTS_4bit; i++) begin
        multiplier = {test_multiplier1_4bit[i], test_multiplier2_4bit[i]};
        multiplicand = {test_multiplicand1_4bit[i], test_multiplicand2_4bit[i]};
        halvedPrecision = 2'b10;
        expected_output = {expected_outputs1_4bit[i], expected_outputs2_4bit[i]};
        #5;
        assert(product == expected_output) else $fatal(
            1, "Test %0d failed: \n multiplier1=%0d, multiplicand1=%0d, expected_output1=%b, got1 %b \n multiplier2=%0d, multiplicand2=%0d, expected_output2=%b, got2 %b",
            i, test_multiplier1_4bit[i], test_multiplicand1_4bit[i], expected_outputs1_4bit[i], product[15:8], test_multiplier2_4bit[i], test_multiplicand2_4bit[i], expected_outputs2_4bit[i], product[7:0]);
        end
        #10;

        for (int i = 0; i < NUM_TESTS_2bit; i++) begin
        multiplier = {4{test_multiplier1_2bit[i]}};
        multiplicand = {4{test_multiplicand1_2bit[i]}};
        halvedPrecision = 2'b01;
        expected_output = {4{expected_outputs1_2bit[i]}};
        #5;
        assert(product == expected_output) else $fatal(
            1, "Test %0d failed: \n multiplier1=%0d, multiplicand1=%0d, expected_output1=%b, got1 %b",
            i, test_multiplier1_2bit[i], test_multiplicand1_2bit[i], expected_output, product);
        end

        #10;
        for (int i = 0; i < 10; i++) begin
            multiplier = $random;
            multiplicand = $random;
            halvedPrecision = 2'b00;
            expected_output = multiplier * multiplicand;
            #5;
            assert(product == expected_output) else $fatal(
                1, "Test %0d failed: multiplier=%0d, multiplicand=%0d, expected_output=%b, got %b",
                i, multiplier, multiplicand, expected_output, product);
        end

        $display("###### ALL TESTS PASSED ######");

        #10;
        $finish;

    end
endmodule