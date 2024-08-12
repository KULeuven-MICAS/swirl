module tb_seq_mult();
    
        // Inputs
        logic clk;
        logic rst_n;
        logic [15:0] a;
        logic [15:0] b;
        logic [3:0] bitsize;
        logic start;
    
        // Outputs
        logic [1:0] p;

        // Clock / Reset
        logic clk_i, rst_ni;
    
        // Instantiate the Unit Under Test (UUT)
        seq_mult #(
            .P(1)
            ) uut (
            .clk(clk_i),
            .rst_n(rst_ni),
            .start(start),
            .a(a),
            .b(b),
            .bitsize(bitsize),
            .p(p)
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

        initial begin
            $dumpfile($sformatf("tb_seq_mult.vcd"));
            $dumpvars(0, tb_seq_mult);

            a = 16'b0000000000101101;
            b = 16'b0000000010011101;
            bitsize = 8;
            #30;
            start = 1;
            #10;
            start = 0;
            #1000;  

        end
endmodule