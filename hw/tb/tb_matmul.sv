`timescale 1ns / 1ps

`ifndef P
`define P 8
`endif
`ifndef M
`define M 2
`endif
`ifndef N
`define N 2
`endif
`ifndef K
`define K 2
`endif
`ifndef TREE
`define TREE 0
`endif
`ifndef MODE
`define MODE 0
`endif


module tb_matmul;

    parameter int M = `M;
    parameter int N = `N;
    parameter int K = `K;
    parameter int P = `P;
    parameter int TREE = `TREE;
    parameter int MODE = `MODE;

    // Testbench signals 2x2x2
    logic signed [(P-1):0] tb_A [M][K];
    logic signed [(P-1):0] tb_B [K][N];
    logic signed [31:0] tb_C [M][N];
    logic signed [31:0] tb_D [M][N];
    logic signed [31:0] tb_expected_D [M][N];
    logic [1:0] halvedPrecision;
    logic clk_i;
    logic rst_ni;
    logic valid_in;
    logic ready_in;
    logic valid_out;
    logic ready_out;
    logic [3:0] bitSizeA;
    logic [3:0] bitSizeB;

  // Module instantiation

  matrix_multiplication_accumulation #(
    .M(M),
    .N(N),
    .K(K),
    .P(P),
    .TREE(TREE),
    .MODE(MODE)
  ) matmul (
    .A(tb_A),
    .B(tb_B),
    .C(tb_C),
    .D(tb_D),
    .halvedPrecision(halvedPrecision),
    .valid_in(valid_in),
    .ready_in(ready_in),
    .valid_out(valid_out),
    .ready_out(ready_out),
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .bitSizeA(bitSizeA),
    .bitSizeB(bitSizeB)
  );

  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i; // 100MHz clock
  end


  initial begin
    int file;
    string filename;

    bitSizeA = 4;
    bitSizeB = 4;

    halvedPrecision = 2'b00;
    rst_ni = 0;
    ready_out = 1;
    #10;
    rst_ni = 1;

    $dumpfile($sformatf("tb_matmul_%0dx%0dx%0d.vcd", M, N, K));
    $dumpvars(0,tb_matmul);

    if (MODE == 1) begin
        filename = $sformatf("matrix_data_%0dx%0dx%0d_halved.txt", M, N, K);
        file = $fopen({"./test_data/",filename}, "r");
        if (file == 0) begin
            $display ("ERROR: Could not open file %s", filename);
            $finish;
        end

        halvedPrecision = 2'b10;
        for(int testIndex = 1; !$feof(file); testIndex++) begin
            read_next_test_from_file(file, M, N, K, halvedPrecision);
            #10
            assert(tb_D == tb_expected_D) else begin
                $display("\nTest #%0d failed\nExpected:", testIndex);
                display_2d_array(tb_expected_D, M, N);
                $display("\nGot:");
                display_2d_array(tb_D, M, N);
                #10
                $fatal();
            end
            $display("4-bit %0dx%0dx%0d Test #%0d passed", M, N, K, testIndex);
        end
    end

    if (MODE == 2) begin
        filename = $sformatf("matrix_data_%0dx%0dx%0d_mixed8x4.txt", M, N, K);
        file = $fopen({"./test_data/",filename}, "r");
        if (file == 0) begin
            $display ("ERROR: Could not open file %s", filename);
            $finish;
        end

        bitSizeA = 4;
        bitSizeB = 2;
        for(int testIndex = 1; !$feof(file); testIndex++) begin
            read_next_test_from_file(file, M, N, K, halvedPrecision);
            valid_in = 1;
            #15;
            valid_in = 0;
            wait (valid_out == 1);
            assert(tb_D == tb_expected_D) else begin
                $display("\nTest #%0d failed\nExpected:", testIndex);
                display_2d_array(tb_expected_D, M, N);
                $display("\nGot:");
                display_2d_array(tb_D, M, N);
                #10
                $fatal();
            end
            $display("mixed 8x4-bit %0dx%0dx%0d Test #%0d passed", M, N, K, testIndex);
        end
    end

    filename = $sformatf("matrix_data_%0dx%0dx%0d.txt", M, N, K);
    file = $fopen({"./test_data/",filename}, "r");
    if (file == 0) begin
         $display ("ERROR: Could not open file %s", filename);
         $finish;
    end

    bitSizeA = 4;
    bitSizeB = 4;
    halvedPrecision = 2'b00;
    for(int testIndex = 1; !$feof(file); testIndex++) begin
        read_next_test_from_file(file, M, N, K, halvedPrecision);
        valid_in = 1;
        #15;
        valid_in = 0;
        wait (valid_out == 1);
        assert(tb_D == tb_expected_D) else begin
            $display("\nTest #%0d failed\nExpected:", testIndex);
            display_2d_array(tb_expected_D, M, N);
            $display("\nGot:");
            display_2d_array(tb_D, M, N);
            $fatal();
        end
        $display("8-bit %0dx%0dx%0d Test #%0d passed", M, N, K, testIndex);
        #15;
    end
  end

  task automatic read_next_test_from_file (
      input int file,
      input int M,
      input int N,
      input int K,
      input logic [1:0] halvedPrecision
  );
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
        if (halvedPrecision[1]) begin
            K = 2 * K;
        end
        if (read_M != M || read_N != N || read_K != K) begin
            $display ("ERROR: dimensions not matching: expected: %0d %0d %0d, got: %0d %0d %0d",
            M, N, K, read_M, read_N, read_K);
            $fclose(file);
            $finish;
        end

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin

                if (halvedPrecision[1]) begin
                    if (j % 2 == 0) begin
                        status = $fscanf(file, "%d ", tb_A[i][j/2][7:4]);
                    end else begin
                        status = $fscanf(file, "%d ", tb_A[i][(j-1)/2][3:0]);
                    end
                end else begin
                status = $fscanf(file, "%d ", tb_A[i][j]);
                end

                if (status != 1) begin
                $display("ERROR: reading value for A[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end

        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin

                if (halvedPrecision[1]) begin
                    if (i % 2 == 0) begin
                        status = $fscanf(file, "%d ", tb_B[i/2][j][7:4]);
                    end else begin
                        status = $fscanf(file, "%d ", tb_B[(i-1)/2][j][3:0]);
                    end
                end else begin
                status = $fscanf(file, "%d ", tb_B[i][j]);
                end

                if (status != 1) begin
                $display("ERROR: reading value for B[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                status = $fscanf(file, "%d ", tb_C[i][j]);
                if (status != 1) begin
                $display("ERROR: reading value for C[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end

        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                status = $fscanf(file, "%d ", tb_expected_D[i][j]);
                if (status != 1) begin
                $display("ERROR: reading value for D[%0d][%0d]", i, j);
                $fclose(file);
                $finish;
                end
            end
        end
    endtask

    task automatic display_2d_array(input logic signed [31:0] arr [][],
                                    input int rows,
                                    input int cols);
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
