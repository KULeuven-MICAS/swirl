`timescale 1ns / 1ps

`ifndef NUM_INPUTS
`define NUM_INPUTS 8
`endif
`ifndef DATAW
`define DATAW 8
`endif
`ifndef PIPES_TREE
`define PIPES_TREE 0
`endif
`ifndef PIPES_MUL
`define PIPES_MUL 0
`endif
`ifndef BACKPRESSURE
`define BACKPRESSURE 1
`endif

module tb_dot_product_unit;

    parameter int NUM_INPUTS = `NUM_INPUTS;
    parameter int DATAW = `DATAW;
    parameter int PIPES_TREE = `PIPES_TREE;
    parameter int PIPES_MUL = `PIPES_MUL;
    parameter int BACKPRESSURE = `BACKPRESSURE;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic sign_unsign;
    logic valid_i;
    logic ready_i;
    logic valid_o;
    logic ready_o;
    logic status;
    logic file;
    logic expected_output;
    reg signed [DATAW-1:0] in1 [NUM_INPUTS];
    reg signed [DATAW-1:0] in2 [NUM_INPUTS];
    logic signed [(2*DATAW)+$clog2(NUM_INPUTS)-1:0] out;

    // Module instantiation
    syn_tle_dotp #(
    ) dp_unit (
        .clk_i(clk),
        .rst_n(rst_n),
        .sign_unsign(sign_unsign),
        .valid_i(valid_i),
        .ready_i(ready_i),
        .valid_o(valid_o),
        .ready_o(ready_o),
        .\in1[7] (in1[7]),
        .\in1[6] (in1[6]),
        .\in1[5] (in1[5]),
        .\in1[4] (in1[4]),
        .\in1[3] (in1[3]),
        .\in1[2] (in1[2]),
        .\in1[1] (in1[1]),
        .\in1[0] (in1[0]),
        .\in2[7] (in2[7]),
        .\in2[6] (in2[6]),
        .\in2[5] (in2[5]),
        .\in2[4] (in2[4]),
        .\in2[3] (in2[3]),
        .\in2[2] (in2[2]),
        .\in2[1] (in2[1]),
        .\in2[0] (in2[0]),
        .out(out)
    );

    initial begin
        clk = 0;
        sign_unsign = 1;
        forever begin
            #5 clk = ~clk; // 100MHz clock
        end
    end

    initial begin
        file = $fopen("./testdatadotp.txt", "r");
        rst_n = 0;
        #10;
        rst_n = 1;

        $dumpfile("tb_dot_product_unit.vcd");
        $dumpvars(0,tb_dot_product_unit);

        if (file == 0) begin
            $display("Error: Could not open file");
            $finish;
        end

        for (int testindex = 1; !$feof(file); testindex++) begin
            // Read one line at a time
            status = $fscanf(file, "{%d, %d, %d, %d} {%d, %d, %d, %d} %d\n",
                             in1[0], in1[1], in1[2], in1[3],
                             in2[0], in2[1], in2[2], in2[3],
                             expected_output);

            if (status == 9) begin
                // Successfully read a line, print values
                $display("Read A = {%0d, %0d, %0d, %0d}", in1[0], in1[1], in1[2], in1[3]);
                $display("Read B = {%0d, %0d, %0d, %0d}", in2[0], in2[1], in2[2], in2[3]);
                $display("Expected output = %0d", expected_output);

                // Perform dot product or pass to your unit
            end else begin
                $display("Error: Could not parse line or invalid format.");
            end
            valid_i = 1;
            #10;
            valid_i = 0;
            wait (valid_o == 1);
            assert(out == expected_output) else begin
                $display("\nTest #%0d failed\nExpected:%d\nGot:%d", testindex, expected_output, out);
                $fatal();
            end
            $display("Test #%0d passed", testindex);
            #15;
        end
    end

endmodule
