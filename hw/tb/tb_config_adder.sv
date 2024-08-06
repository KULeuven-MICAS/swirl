`timescale 1ns / 1ps

module tb_config_adder;

  // Testbench signals
  logic signed [7:0] a;
  logic signed [7:0] b;
  logic signed [3:0] a1, a2, b1, b2;
  logic signed [9:5] expected_out1;
  logic signed [4:0] expected_out2;
  logic signed [9:0] expected_output;
  logic halvedPrecision;
  wire signed [9:0] out;
  logic signed [4:0] out1, out2;

  // Module instantiation
  config_adder #(
    .P(8)
  ) adder1 (
    .a(a),
    .b(b),
    .halvedPrecision(halvedPrecision),
    .sum(out)
  );

  // Testcases
  parameter int NUM_TESTS_8bit = 7; // Renamed parameter
  parameter int RANDOM_TESTS = 100;
  logic signed [7:0] test_a[NUM_TESTS_8bit] =           '{0, 1, 8,  124, 124, -127, -127};
  logic signed [7:0] test_b[NUM_TESTS_8bit] =           '{0, 2, -8, 3,   4,   -1,   -100};
  logic signed [9:0] expected_outputs[NUM_TESTS_8bit] = '{0, 3, 0,  127, 128, -128, -227}; 

  // Run tests
  initial begin
    $dumpfile("tb_config_adder.vcd");
    $dumpvars(0, tb_config_adder);
    
    for (int i = 0; i < NUM_TESTS_8bit; i++) begin // Updated loop condition
      a = test_a[i];
      b = test_b[i];
      expected_output = expected_outputs[i];
      halvedPrecision = 0;
      #5;
      $display("a = %d    b = %d    out = %d    expected out = %d", a, b, out, expected_output);
      assert(out == expected_output) else $fatal(
        1, "Test %0d failed: a=%0d, b=%0d, expected_output=%0d, got %0d",
        i, test_a[i], test_b[i], expected_outputs[i], out);
    end

    for (int i = 0; i < RANDOM_TESTS; i++) begin
      a = $random;
      b = $random;
      expected_output = a + b;
      halvedPrecision = 0;
      #5;
      $display("a = %d    b = %d    out = %d    expected out = %d", a, b, out, expected_output);
      assert(out == expected_output) else $fatal(
        1, "Test %0d failed: a=%0d, b=%0d, expected_output=%0d, got %0d",
        i, a, b, expected_output, out);
    end
    #10
    for (int i = 0; i < RANDOM_TESTS; i++) begin
      a1 = $random;
      b1 = $random;
      a2 = $random;
      b2 = $random;
      expected_out1 = a1 + b1;
      expected_out2 = a2 + b2;
      halvedPrecision = 1;
      
      a = {a1, a2};
      b = {b1, b2};
      expected_output = {expected_out1, expected_out2};

      #5;
      out1 = out[9:5];
      out2 = out[4:0];
      $display("a1 = %d    b1 = %d    out1 = %d    expected out1 = %d    a2 = %d    b2 = %d    out2 = %d    expected out2 = %d", a1, b1, out1, expected_out1, a2, b2, out2, expected_out2);
      assert(out == expected_output) else $fatal(
        1, "Test %d failed: a1=%d, b1=%d, expected_output1=%d, got1 %d, a2=%d, b2=%d, expected_output2=%d, got2 %d",
        i, a1, b1, expected_out1, out1, a2, b2, expected_out2, out2);
    end

    $finish;
  end
endmodule
