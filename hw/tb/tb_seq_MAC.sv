module tb_seq_MAC ();
    
        
        // Testbench signals
        logic signed [15:0] A [2][2];
        logic signed [15:0] B [2][2];

        logic signed [31:0] C [2][2];
        logic signed [31:0] D [2][2];

        reg valid_in;
        wire ready_in;
        wire valid_out;
        reg ready_out;
        logic clk_i;
        logic rst_ni;
    
        // Module instantiation
        seq_MAC #(
            .K(2),
            .P(2),
            .MAX_WIDTH(16)
        ) seq_MAC (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .A_mul(A),
            .B_mul(B),
            .C_mul(C),
            .D(D),
            .valid_in(valid_in),
            .ready_in(ready_in),
            .valid_out(valid_out),
            .ready_out(ready_out),
            .bitSizeA(4'b0100),
            .bitSizeB(4'b0100)
        );

        initial begin
            clk_i = 0;
            forever #5 clk_i = ~clk_i; // 100MHz clock
        end

        // Run tests
        initial begin
            // $monitor("A: %p, B: %p, C: %p, D: %p", A, B, C, D);
            valid_in = 0;
            ready_out = 0;
            rst_ni = 0;

            #10;

            rst_ni = 1;

            #10;

            A[0][0] = 1;
            A[0][1] = 2;
            A[1][0] = 3;
            A[1][1] = 4;

            B[0][0] = 5;
            B[0][1] = 6;
            B[1][0] = 7;
            B[1][1] = 8;

            C[0][0] = 9;
            C[0][1] = 10;
            C[1][0] = 11;
            C[1][1] = 12;
            
            valid_in = 1;

            #10;

            valid_in = 0;

            #500;

            ready_out = 1;

            #200

            A[0][0] = 0;
            A[0][1] = 0;
            A[1][0] = 0;
            A[1][1] = 0;

            B[0][0] = 0;
            B[0][1] = 0;
            B[1][0] = 0;
            B[1][1] = 0;

            C[0][0] = 0;
            C[0][1] = 0;
            C[1][0] = 0;
            C[1][1] = 0;
        end
endmodule