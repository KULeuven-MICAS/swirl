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
`ifndef CONFIGURABLE
`define CONFIGURABLE 0
`endif

module tb_syn_tle;

    // Parameters
    parameter int M = `M;
    parameter int N = `N;
    parameter int K = `K;
    parameter int P = `P;
    parameter int PIPESTAGES = 2;
    parameter bit TREE = `TREE;
    parameter bit CONFIGURABLE = `CONFIGURABLE;

    // Signals
    logic clk_i;
    logic rst_ni;
    logic signed [P-1:0] A_i [M][K];
    logic signed [P-1:0] B_i [K][N];
    logic signed [4*P-1:0] C_i [M][N];
    logic valid_i;
    logic ready_o;
    logic signed [4*P-1:0] D_o [M][N];
    logic ready_i;
    logic valid_o;
    logic halvedPrecision;

    // Instantiate the DUT (Device Under Test)
    syn_tle #(
        .M(M),
        .N(N),
        .K(K),
        .P(P),
        .PIPESTAGES(PIPESTAGES),
        .TREE(TREE),
        .CONFIGURABLE(CONFIGURABLE)
    ) dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .A_i(A_i),
        .B_i(B_i),
        .C_i(C_i),
        .valid_i(valid_i),
        .ready_o(ready_o),
        .D_o(D_o),
        .ready_i(ready_i),
        .valid_o(valid_o),
        .halvedPrecision(halvedPrecision)
    );
    

    // Clock generation
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; // 100MHz clock
    end

    // Reset generation
    initial begin
        rst_ni = 1;
        #20 rst_ni = 0;
    end

    // Stimulus
    initial begin
        $dumpfile($sformatf("tb_syn_tle.vcd"));
        $dumpvars(0, tb_syn_tle);
        // Initialize inputs
        valid_i = 0;
        ready_o = 0;
        halvedPrecision = 0;
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                A_i[i][j] = 0;
            end
        end
        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                B_i[i][j] = 0;
            end
        end
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                C_i[i][j] = 0;
            end
        end

        // Apply test vectors
        #30;
        valid_i = 1;
        ready_o = 0;
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                A_i[i][j] = 1;
            end
        end
        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                B_i[i][j] = 2;
            end
        end
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                C_i[i][j] = 3;
            end
        end
        #10
        valid_i = 0;
        halvedPrecision = 1;
        #10
        valid_i = 1;
        
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < K; j++) begin
                A_i[i][j] = 8'b00010001;
            end
        end
        for (int i = 0; i < K; i++) begin
            for (int j = 0; j < N; j++) begin
                B_i[i][j] = 8'b00010001;
            end
        end
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                C_i[i][j] = 8'b00010001;
            end
        end

        #50;
        ready_o = 1;

        // Wait for some time to observe the outputs
        #100;

        // End simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        // $monitor("At time %t, D_o = %p, A_i = %p, B_i = %p, C_i = %p", $time, D_o, A_i, B_i, C_i);
    end

endmodule