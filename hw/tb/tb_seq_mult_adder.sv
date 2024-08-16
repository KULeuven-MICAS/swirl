module tb_seq_mult_adder ();
    
        
        // Testbench signals
        logic signed [15:0] row [2];
        logic signed [15:0] column [2];
        logic signed [31:0] C_in;
        reg valid_in;
        wire ready_in;
        wire valid_out;
        reg ready_out;
        logic clk_i;
        logic rst_ni;
    
        // Module instantiation
        seq_mult_adder #(
            .K(2),
            .P(2),
            .MAX_WIDTH(16)
        ) seq_mult_adder (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .row(row),
            .column(column),
            .C_in(C_in),
            .valid_in(valid_in),
            .ready_in(ready_in),
            .valid_out(valid_out),
            .ready_out(ready_out),
            .bitSize(5'b00100)
        );

        initial begin
            clk_i = 0;
            forever #5 clk_i = ~clk_i; // 100MHz clock
        end

        // Run tests
        initial begin
            valid_in = 0;
            ready_out = 1;
            rst_ni = 0;

            #10;

            rst_ni = 1;
            row = '{29, -13};
            column = '{-56, -98};
            C_in = 71;

            #5;

            valid_in = 1;

            #100;

            row = '{0, 0};
            column = '{0, 0};
        end
endmodule