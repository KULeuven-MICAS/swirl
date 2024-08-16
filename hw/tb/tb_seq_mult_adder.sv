module tb_seq_mult_adder ();
    
        
        // Testbench signals
        logic signed [7:0] row [2];
        logic signed [7:0] column [2];
        logic signed [31:0] C_in;
        reg valid_in_sequential;
        wire ready_in_sequential;
        wire valid_out_sequential;
        reg ready_out_sequential;
        logic clk_i;
        logic rst_ni;
    
        // Module instantiation
        seq_mult_adder #(
            .K(2),
            .P(8)
        ) seq_mult_adder (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .row(row),
            .column(column),
            .C_in(C_in),
            .valid_in_sequential(valid_in_sequential),
            .ready_in_sequential(ready_in_sequential),
            .valid_out_sequential(valid_out_sequential),
            .ready_out_sequential(ready_out_sequential)
        );

        initial begin
            clk_i = 0;
            forever #5 clk_i = ~clk_i; // 100MHz clock
        end

        // Run tests
        initial begin
            valid_in_sequential = 0;
            ready_out_sequential = 1;
            rst_ni = 0;

            #10;

            rst_ni = 1;
            row = '{45, -1};
            column = '{-99, 1};
            C_in = 1;

            #5;

            valid_in_sequential = 1;

            #100;

            row = '{0, 0};
            column = '{0, 0};
        end
endmodule