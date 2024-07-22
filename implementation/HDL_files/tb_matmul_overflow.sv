`timescale 1ns / 1ps


module tb_matmul_overflow;

  parameter M = 1;
  parameter N = 1;
  parameter K = 134000;
  parameter P = 16;
  
  // Testbench signals 2x2x2
  logic signed [(P-1):0] tb_A [(M-1):0][(K-1):0];
  logic signed [(P-1):0] tb_B [(K-1):0][(N-1):0];
  logic signed [(4*P-1):0] tb_C [(M-1):0][(N-1):0];
  logic signed [(4*P-1):0] tb_D [(M-1):0][(N-1):0];
  logic signed [(4*P-1):0] tb_expected_D [(M-1):0][(N-1):0];

  // Module instantiation
  matrix_multiplication_accumulation #(
    .M(M),
    .N(N),
    .K(K),
    .P(P)
  ) matmul_2x2x2 (
    .A(tb_A), .B(tb_B), .C(tb_C), .D(tb_D)
  );

  initial begin
    int file;
    string filename;

    $dumpfile("tb_matmul_overflow.vcd");
    $dumpvars(0,tb_matmul_overflow);

    for (int i = 0; i < K/2; i++) begin
      tb_A[0][i] = 127;
      tb_B[i][0] = 127;
    end
    for (int i = K/2; i < K; i++) begin
      tb_A[0][i] = 127;
      tb_B[i][0] = 127;
    end
    tb_C[0][0] = 127;
    tb_expected_D[0][0] = 2**31-1;

    assert(tb_D == tb_expected_D) else begin
        $display("\nTest #%0d failed\nExpected: %0d", 1, tb_expected_D[0][0]);
        $display("\nGot: %0d", tb_D[0][0]);
        $fatal();
    end
    $display("Overflow Test #%0d passed", 1);
    end

  endmodule