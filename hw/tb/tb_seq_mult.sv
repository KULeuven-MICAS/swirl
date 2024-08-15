module tb_seq_mult();
        localparam P = 2;
        localparam W = 8;
    
        // Inputs
        logic clk;
        logic rst_n;
        logic [15:0] a;
        logic [15:0] b;
        logic [3:0] bitSize;
        logic start;

    
        // Outputs
        logic [P-1:0] p;
        logic newOut;
        logic done;

        // Clock / Reset
        logic clk_i, rst_ni;
    
        // Instantiate the Unit Under Test (UUT)
        seq_mult #(
            .P(P)
            ) uut (
            .clk(clk_i),
            .rst_n(rst_ni),
            .start(start),
            .a(a),
            .b(b),
            .bitSize(bitSize),
            .p(p),
            .newOut(newOut),
            .done(done)
        );

        logic signed [2*W-1:0] fullProduct = 0;
        always @(posedge clk_i) begin
            if (newOut) begin
                fullProduct <= {p, fullProduct[2*W-1:P]};
            end
        end
    
            // Clock generation
        initial begin
            clk_i = 0;
            forever #5 clk_i = ~clk_i; // 100MHz clock
        end

        // Reset generation
        initial begin
            rst_ni = 0;
            #20 rst_ni = 1;
        end

        initial begin
            $dumpfile($sformatf("tb_seq_mult.vcd"));
            $dumpvars(0, tb_seq_mult);
            $monitor("Fullproduct: %b, DONE = $b", fullProduct, done);

            a = 16'b0000000000101101;
            b = 16'b0000000010011101;
            // a = 16'b0000000001000011;
            // b = 16'b0000111100111111;
            bitSize = W/2;
            #30;
            start = 1;
            #10;
            start = 0;
            #3000;  

        end
endmodule