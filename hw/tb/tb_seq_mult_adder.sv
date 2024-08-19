module tb_seq_mult_adder ();
    
        
        // Testbench signals
        logic signed [15:0] row [2];
        logic signed [15:0] column [2];
        logic signed [31:0] C_in;
        logic signed [31:0] D;
        logic unsigned [4:0] bitSize;
        reg valid_in;
        wire ready_in;
        wire valid_out;
        reg ready_out;
        logic clk_i;
        logic rst_ni;

        logic signed [1:0] a_2bit;
        logic signed [1:0] b_2bit;
        logic signed [3:0] a_4bit;
        logic signed [3:0] b_4bit;
        logic signed [5:0] a_6bit;
        logic signed [5:0] b_6bit;
        logic signed [7:0] a_8bit;
        logic signed [7:0] b_8bit;
        logic signed [9:0] a_10bit;
        logic signed [9:0] b_10bit;
        logic signed [11:0] a_12bit;
        logic signed [11:0] b_12bit;
        logic signed [13:0] a_14bit;
        logic signed [13:0] b_14bit;
        logic signed [15:0] a_16bit;
        logic signed [15:0] b_16bit;

        logic signed [31:0] product;
    
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
            .D(D),
            .valid_in(valid_in),
            .ready_in(ready_in),
            .valid_out(valid_out),
            .ready_out(ready_out),
            .bitSize(bitSize)
        );


        initial begin
            clk_i = 0;
            forever #5 clk_i = ~clk_i; // 100MHz clock
        end

        // Run tests
        initial begin
            $dumpfile("tb_seq_mult_adder.vcd");
            $dumpvars(0, tb_seq_mult_adder);

            valid_in = 0;
            ready_out = 1;
            rst_ni = 0;

            #10;
            rst_ni = 1;

            // 2-BIT //

            bitSize = 1; // 4-bit = 2*P

            a_2bit = $random;
            b_2bit = $random;

            product = a_2bit * b_2bit;

            row = '{{14'b0, a_2bit}, 0};
            column = '{{14'b0, b_2bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit:     %d x     %d = %d  OUT: %d    %b",2*bitSize, a_2bit, b_2bit, product, D, D);

            // 4-BIT //

            bitSize = 2; // 4-bit = 2*P

            a_4bit = $random;
            b_4bit = $random;

            product = a_4bit * b_4bit;

            row = '{{12'b0, a_4bit}, 0};
            column = '{{12'b0, b_4bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit:    %d x    %d = %d  OUT: %d    %b",2*bitSize, a_4bit, b_4bit, product, D, D);

            // 6-BIT //

            bitSize = 3;

            a_6bit = $random;
            b_6bit = $random;

            product = a_6bit * b_6bit;

            row = '{{10'b0, a_6bit}, 0};
            column = '{{10'b0, b_6bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit:    %d x    %d = %d  OUT: %d    %b",2*bitSize, a_6bit, b_6bit, product, D, D);

            // 8-BIT //

            bitSize = 4;

            a_8bit = $random;
            b_8bit = $random;

            product = a_8bit * b_8bit;

            row = '{{8'b0, a_8bit}, 0};
            column = '{{8'b0, b_8bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit:   %d x   %d = %d  OUT: %d    %b",2*bitSize, a_8bit, b_8bit, product, D, D);

            // 10-BIT //

            bitSize = 5;

            a_10bit = $random;
            b_10bit = $random;

            product = a_10bit * b_10bit;

            row = '{{6'b0, a_10bit}, 0};
            column = '{{6'b0, b_10bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit:  %d x  %d = %d  OUT: %d    %b",2*bitSize, a_10bit, b_10bit, product, D, D);

            // 12-BIT //

            bitSize = 6;

            a_12bit = $random;
            b_12bit = $random;

            product = a_12bit * b_12bit;

            row = '{{4'b0, a_12bit}, 0};
            column = '{{4'b0, b_12bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("#####TEST %d-bit FAILED#######", 2*bitSize);
            $display("%d-bit:  %d x  %d = %d  OUT: %d    %b",2*bitSize, a_12bit, b_12bit, product, D, D);

            // 14-BIT //

            bitSize = 7;

            a_14bit = $random;
            b_14bit = $random;

            product = a_14bit * b_14bit;

            row = '{{2'b0, a_14bit}, 0};
            column = '{{2'b0, b_14bit}, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit: %d x %d = %d  OUT: %d    %b",2*bitSize, a_14bit, b_14bit, product, D, D);

            // 16-BIT //

            bitSize = 8;

            a_16bit = 2**15-1;
            b_16bit = 2**15-1;

            product = a_16bit * b_16bit;

            row = '{a_16bit, 0};
            column = '{b_16bit, 0};

            C_in = 0;
            valid_in = 1;
            #20;

            wait(valid_out==1);
            #1;
            assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            $display("%d-bit: %d x %d = %d  OUT: %d    %b",2*bitSize, a_16bit, b_16bit, product, D, D);

            

            #10;

            row = '{0, 0};
            column = '{0, 0};
        end
endmodule