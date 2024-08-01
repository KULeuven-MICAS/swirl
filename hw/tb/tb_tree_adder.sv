`timescale 1ns / 1ps


module tb_tree_adder;

  // Testbench signals
  logic signed [7:0] inputs_8 [8];
  wire signed [7:0] out_1 [1];
  wire signed [7:0] out_4 [4];

  // Module instantiation
  binary_tree_adder #(
    .P(8),
    .INPUTS_AMOUNT(8),
    .OUTPUTS_AMOUNT(1)
  ) adder1 (
    .inputs(inputs_8),
    .outputs(out_1)
  );

  binary_tree_adder #(
    .P(8),
    .INPUTS_AMOUNT(8),
    .OUTPUTS_AMOUNT(4)
  ) adder2 (
    .inputs(inputs_8),
    .outputs(out_4)
  );

  // Run tests
  initial begin

    parameter int NUM_TESTS_8 = 5;
    logic signed [7:0] test_inputs_8[NUM_TESTS_8][8] =  '{
        '{1, 2, 3, 4, 5, 6, 7, 8},
        '{1, -2, 3, -4, 5, -6, 7, -8},
        '{127, -128, 0, 1, 0, 0, 0, 0},
        '{127, 5, 2, 1, 6, 1, 35, 6},
        '{-127, 5, 2, 1, -6, 1, -35, 6}
    };
    logic signed [7:0] expected_outputs_8[NUM_TESTS_8] = '{
        36,
        -4,
        0,
        127,
        -128
    };

    int i;
    int j;
    for (i = 0; i < NUM_TESTS_8; i++) begin
       for (j = 0; j < 8; j++) begin
        inputs_8[j] = test_inputs_8[i][j];
      end;
      #5;
      assert(out_1[0] == expected_outputs_8[i]) else $fatal(
        1, "Test %0d failed: expected_output=%0d, got %0d",
        i, expected_outputs_8[i], out_1[0]);
      assert(out_4[1] == inputs_8[2] + inputs_8[3]) else $fatal(
        1, "Test %0d failed: expected_output=%0d, got %0d",
        i, inputs_8[2] + inputs_8[3], out_4[1]);
    end

    $display("===============\nALL TESTS PASSED\n================");

    #10

    $finish;

  end

endmodule
