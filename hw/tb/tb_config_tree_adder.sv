`timescale 1ns / 1ps


module tb_config_tree_adder;

  initial begin
    $dumpfile("tb_config_tree_adder.vcd");
    $dumpvars(0, tb_config_tree_adder);
  end
  // Testbench signals
  logic signed [15:0] inputs_8 [8];
  wire signed [31:0] out;
  logic halvedPrecision;
  logic signed [7:0] input1;
  logic signed [7:0] input2;

  // Module instantiation
  config_binary_tree_adder #(
    .P(16),
    .INPUTS_AMOUNT(8)
  ) adder1 (
    .inputs(inputs_8),
    .out(out),
    .halvedPrecision(halvedPrecision)
  );

  

  // Run tests
  initial begin
    

    parameter int NUM_TESTS_16BIT = 5;
    logic signed [7:0] test_inputs_8[NUM_TESTS_16BIT][8] =  '{
        '{1, 2, 3, 4, 5, 6, 7, 8},
        '{1, -2, 3, -4, 5, -6, 7, -8},
        '{127, -128, 0, 1, 0, 0, 0, 0},
        '{127, 5, 2, 1, 6, 1, 35, 6},
        '{-127, 5, 2, 1, -6, 1, -35, 6}
    };
    logic signed [31:0] expected_outputs_8[NUM_TESTS_16BIT] = '{
        36,
        -4,
        0,
        183,
        -153
    };
    parameter int NUM_TESTS_8BIT = 5;
    logic signed [7:0] test_inputs_4bit[NUM_TESTS_8BIT][16] = '{
      '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      '{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
      '{-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16},
      '{-1, 1, -2, 2, -3, 3, -4, 4, -5, 5, -6, 6, -7, 7, -8, 8},
      '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
      
    };
    logic signed [31:0] expected_outputs_4bit[NUM_TESTS_8BIT] = '{
      0,
      136,
      -136,
      0,
      0
    };

    int i;
    int j;
    int expected_output = 0;
    halvedPrecision = 0;
    for (i = 0; i < NUM_TESTS_16BIT; i++) begin
       for (j = 0; j < 8; j++) begin
        inputs_8[j] = test_inputs_8[i][j];
      end;
      #5;
      assert(out == expected_outputs_8[i]) else $fatal(
        1, "Test %0d failed: expected_output=%b, got %b",
        i, expected_outputs_8[i], out);
    end

    
    for (i = 0; i < 50; i++) begin
      expected_output = 0;
       for (j = 0; j < 8; j++) begin
        inputs_8[j] = $random;
        expected_output += inputs_8[j];
      end;
      #5;
      assert(out == expected_output) else $fatal(
        1, "Test %0d failed: expected_output=%b, got %b",
        i, expected_output, out);
    end

    halvedPrecision = 1;
    for (i = 0; i < NUM_TESTS_8BIT; i++) begin
       for (j = 0; j < 8; j++) begin
        inputs_8[j] = {test_inputs_4bit[i][j*2], test_inputs_4bit[i][j*2+1]};
      end;
      #5;
      $display("out: %d, expected_out: %d", out, expected_outputs_4bit[i]);
      assert(out == expected_outputs_4bit[i]) else $fatal(
        1, "Test %0d failed: expected_output=%b, got %b",
        i, expected_outputs_4bit[i], out);
    end

    for (i = 0; i < 50; i++) begin
      expected_output = 0;
       for (j = 0; j < 8; j++) begin
        input1 = $random;
        input2 = $random;
        inputs_8[j] = {input1, input2};
        expected_output += input1;
        expected_output += input2;
      end;
      #5;
      $display("out: %d, expected_out: %d", out, expected_output);
      assert(out == expected_output) else $fatal(
        1, "Test %0d failed: expected_output=%b, got %b",
        i, expected_output, out);
    end

    $display("===============\nALL TESTS PASSED\n================");

    #10

    $finish;

  end

endmodule
