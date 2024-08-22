`timescale 1ns / 1ps


module tb_tree_adder;

  initial begin
    $dumpfile("tb_tree_adder.vcd");
    $dumpvars(0, tb_tree_adder);
  end
  // Testbench signals
  logic signed [7:0] inputs_8 [8];
  wire signed [31:0] out;

  // Module instantiation
  binary_tree_adder #(
    .P(8),
    .INPUTS_AMOUNT(8)
  ) adder1 (
    .inputs(inputs_8),
    .out(out)
  );

  // Run tests
  initial begin
    

    parameter int NUM_TESTS_8 = 5;
    static logic signed [7:0] test_inputs_8[NUM_TESTS_8][8] =  '{
        '{1, 2, 3, 4, 5, 6, 7, 8},
        '{1, -2, 3, -4, 5, -6, 7, -8},
        '{127, -128, 0, 1, 0, 0, 0, 0},
        '{127, 5, 2, 1, 6, 1, 35, 6},
        '{-127, 5, 2, 1, -6, 1, -35, 6}
    };
    static logic signed [31:0] expected_outputs_8[NUM_TESTS_8] = '{
        36,
        -4,
        0,
        183,
        -153
    };

    int i;
    int j;
    automatic int expected_output = 0;
    for (i = 0; i < NUM_TESTS_8; i++) begin
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

    $display("===============\nALL TESTS PASSED\n================");

    #10

    $finish;

  end

endmodule
