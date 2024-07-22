`timescale 1ns / 1ps


module tb_matmul;

  parameter M = 2;
  parameter N = 2;
  parameter K = 2;
  parameter P = 8;
  
  // Testbench signals 2x2
  logic signed [(P-1):0] tb_A_2x2 [(M-1):0][(K-1):0];
  logic signed [(P-1):0] tb_B_2x2 [(K-1):0][(N-1):0];
  logic signed [(4*P-1):0] tb_C_2x2 [(M-1):0][(N-1):0];
  logic signed [(4*P-1):0] tb_D_2x2 [(M-1):0][(N-1):0];
  logic signed [(4*P-1):0] tb_expected_D_2x2 [(M-1):0][(N-1):0];

  // Module instantiation
  matrix_multiplication_accumulation #(
    .M(M),
    .N(N),
    .K(K),
    .P(P)
  ) matmul_2x2 (
    .A(tb_A_2x2), .B(tb_B_2x2), .C(tb_C_2x2), .D(tb_D_2x2)
  );


  initial begin
    int file;
    string filename;

    $dumpfile("tb_matmul.vcd");
    $dumpvars(0,tb_matmul);
    //$monitor("D00 = %d \n D01 = %d \n D10 = %d \n D11 = %d",
    //        tb_D_2x2[0][0], tb_D_2x2[0][1], tb_D_2x2[1][0], tb_D_2x2[1][1]);

    filename = "matrix_data_2x2.txt";
    file = $fopen({"./test_data/",filename}, "r");
    if (file == 0) begin
         $display ("ERROR: Could not open file %s", filename);
         $finish;
    end

    
    
    for(int testIndex = 1; !$feof(file); testIndex++) begin
        read_next_test_from_file(file, M, N, K);
        #10
        assert(tb_D_2x2 == tb_expected_D_2x2) else begin
            $display("\nTest #%0d failed\nExpected:", testIndex);
            display_2d_array(tb_expected_D_2x2, 2, 2);
            $display("\nGot:");
            display_2d_array(tb_D_2x2, 2, 2);
            $fatal();
        end
        $display("Test #%0d passed", testIndex);
    end
  end

    task read_next_test_from_file(input int file, input int M, input int N, input int K);
        int status;
        int read_M;
        int read_N;
        int read_K;

        status = $fscanf(file, "%d %d %d\n", read_M, read_N, read_K);
        if (status != 3) begin
            $display ("ERROR: read error");
            $fclose(file);
            $finish;
        end
        if (read_M != M || read_N != N || read_K != K) begin
            $display ("ERROR: dimensions not matching: expected: %0d %0d %0d, got: %0d %0d %0d", M, N, K, read_M, read_N, read_K);
            $fclose(file);
            $finish;
        end

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                status = $fscanf(file, "%d ", tb_A_2x2[i][j]);
                if (status != 1) begin
                $display("ERROR: reading value for A[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end

        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                status = $fscanf(file, "%d ", tb_B_2x2[i][j]);
                if (status != 1) begin
                $display("ERROR: reading value for B[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                status = $fscanf(file, "%d ", tb_C_2x2[i][j]);
                if (status != 1) begin
                $display("ERROR: reading value for C[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                status = $fscanf(file, "%d ", tb_expected_D_2x2[i][j]);
                if (status != 1) begin
                $display("ERROR: reading value for D[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end
    endtask

    task display_2d_array(input logic signed [31:0] arr [][], input int rows, input int cols);
    // Local variables
    int i, j;
    foreach (arr[i]) begin
      foreach (arr[i][j]) begin
        $write("%0d ", arr[i][j]);
      end
      $display(""); // Newline after each row
    end
  endtask

endmodule
