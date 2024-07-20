`timescale 1ns / 1ps


module tb_;

  logic[7:0] a;
  logic[7:0] b;
  wire[7:0] out;

  logic [7:0] A [1:0][1:0];
  logic [7:0] B [1:0][1:0];
  logic [31:0] C [1:0][1:0];
  logic [31:0] D [1:0][1:0];

  matrix_multiplication_accumulation #(
    .M(2),
    .N(2),
    .K(2),
    .P(8)
  ) matmul (
    .A(A), .B(B), .C(C), .D(D)
  );


  bitwise_add #(
    .P(8)
  ) adder1 (
    .a(a),
    .b(b), 
    .sum(out)
  );

  initial begin
    $dumpfile("tb_.vcd");
    $dumpvars(0,tb_);

    A[0][0] = 123;
    A[0][1] = 127;
    A[1][0] = -2;
    A[1][1] = -5;

    B[0][0] = 8'd1;
    B[0][1] = 8'd2;
    B[1][0] = 8'd3;
    B[1][1] = 8'd4;

    C[0][0] = 8'd1;
    C[0][1] = 8'd2;
    C[1][0] = 8'd3;
    C[1][1] = 8'd4;

    $monitor("D00 = %d \n D01 = %d \n D10 = %d \n D11 = %d",
            D[0][0], D[0][1], D[1][0], D[1][1]);

    #10

    $finish;

  end

endmodule
