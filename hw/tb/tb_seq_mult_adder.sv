module tb_seq_mult_adder ();

    localparam int K = 1;

        // Testbench signals
        logic signed [15:0] row [K];
        logic signed [15:0] column [K];
        logic signed [31:0] C_in;
        logic signed [31:0] D;
        logic unsigned [4:0] bitSizeA;
        logic unsigned [4:0] bitSizeB;
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

        logic signed [15:0] a_list [8];
        logic signed [15:0] b_list [8];

        // Module instantiation
        seq_mult_adder #(
            .K(K),
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
            .bitSizeA(bitSizeA),
            .bitSizeB(bitSizeB)
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

            // // 2-BIT //

            // bitSizeA = 1; // 4-bit = 2*P
            // bitSizeB = 1; // 4-bit = 2*P

            // a_2bit = $urandom;
            // b_2bit = $urandom;

            // product = a_2bit * b_2bit;

            // row = '{{14'b0, a_2bit}};
            // column = '{{14'b0, b_2bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit:     %d x     %d = %d  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_2bit, b_2bit, product, D, D);

            // // 4-BIT //

            // bitSizeA = 2; // 4-bit = 2*P
            // bitSizeB = 2; // 4-bit = 2*P

            // a_4bit = $urandom;
            // b_4bit = $urandom;

            // product = a_4bit * b_4bit;

            // row = '{{12'b0, a_4bit}};
            // column = '{{12'b0, b_4bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit:    %d x    %d = %d  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_4bit, b_4bit, product, D, D);

            // // 6-BIT //

            // bitSizeA = 3;
            // bitSizeB = 3;

            // a_6bit = $urandom;
            // b_6bit = $urandom;

            // product = a_6bit * b_6bit;

            // row = '{{10'b0, a_6bit}};
            // column = '{{10'b0, b_6bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit:    %d x    %d = %d  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_6bit, b_6bit, product, D, D);

            // // 8-BIT //

            // bitSizeA = 4;
            // bitSizeB = 4;

            // a_8bit = $urandom;
            // b_8bit = $urandom;

            // product = a_8bit * b_8bit;

            // row = '{{8'b0, a_8bit}};
            // column = '{{8'b0, b_8bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit:   %d x   %d = %d  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_8bit, b_8bit, product, D, D);

            // // 10-BIT //

            // bitSizeA = 5;
            // bitSizeB = 5;

            // a_10bit = $urandom;
            // b_10bit = $urandom;

            // product = a_10bit * b_10bit;

            // row = '{{6'b0, a_10bit}};
            // column = '{{6'b0, b_10bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit:  %d x  %d = %d  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_10bit, b_10bit, product, D, D);

            // // 12-BIT //

            // bitSizeA = 6;
            // bitSizeB = 6;

            // a_12bit = $urandom;
            // b_12bit = $urandom;

            // product = a_12bit * b_12bit;

            // row = '{{4'b0, a_12bit}};
            // column = '{{4'b0, b_12bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("#####TEST %dx%d-bit FAILED#######", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit:  %d x  %d = %d  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_12bit, b_12bit, product, D, D);

            // // 14-BIT //


            // bitSizeA = 7;
            // bitSizeB = 7;

            // a_14bit = $urandom;
            // b_14bit = $urandom;

            // product = a_14bit * b_14bit;

            // row = '{{2'b0, a_14bit}};
            // column = '{{2'b0, b_14bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit: %d x %d = %d   %b  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_14bit, b_14bit, product, product, D, D);

            // // // 16-BIT //

            // // bitSize = 8;

            // // a_16bit = $urandom;
            // // b_16bit = $urandom;

            // // product = a_16bit * b_16bit;

            // // row = '{a_16bit, 0};
            // // column = '{b_16bit, 0};

            // // C_in = 0;
            // // valid_in = 1;
            // // #20;

            // // wait(valid_out==1);
            // // #1;
            // // assert(D == product) else $display("TEST %d-bit FAILED", 2*bitSize);
            // // $display("%d-bit: %d x %d = %d  OUT: %d    %b",2*bitSize, a_16bit, b_16bit, product, D, D);

            //             // 16-BIT //

            // bitSizeA = 6;
            // bitSizeB = 5;

            // a_12bit = $urandom;
            // b_10bit = $urandom;

            // product = a_12bit * b_10bit;

            // row = '{{4'b0, a_12bit}};
            // column = '{{6'b0, b_10bit}};

            // C_in = 0;
            // valid_in = 1;
            // #20;

            // wait(valid_out==1);
            // #1;
            // assert(D == product) else $display("TEST %dx%d-bit FAILED", 2*bitSizeA, 2*bitSizeB);
            // $display("%dx%d-bit: %d x %d = %d   %b  OUT: %d    %b",2*bitSizeA, 2*bitSizeB, a_12bit, b_10bit, product, product, D, D);

            for (logic [4:0] i = 1; i < 8; i = i + 1) begin
                for (logic [4:0] j = 1; j < 8; j = j + 1) begin
                    a_16bit = $urandom;
                    a_14bit = $urandom;
                    a_12bit = $urandom;
                    a_10bit = $urandom;
                    a_8bit = $urandom;
                    a_6bit = $urandom;
                    a_4bit = $urandom;
                    a_2bit = $urandom;

                    a_list = '{a_2bit, a_4bit, a_6bit, a_8bit, a_10bit, a_12bit, a_14bit, a_16bit};

                    b_16bit = $urandom;
                    b_14bit = $urandom;
                    b_12bit = $urandom;
                    b_10bit = $urandom;
                    b_8bit = $urandom;
                    b_6bit = $urandom;
                    b_4bit = $urandom;
                    b_2bit = $urandom;

                    b_list = '{b_2bit, b_4bit, b_6bit, b_8bit, b_10bit, b_12bit, b_14bit, b_16bit};

                    bitSizeA = i;
                    bitSizeB = j;

                    product = a_list[i-1] * b_list[j-1];

                    case (i)
                        1: begin
                            row = '{{14'b0, a_2bit}};
                        end
                        2: begin
                            row = '{{12'b0, a_4bit}};
                        end
                        3: begin
                            row = '{{10'b0, a_6bit}};
                        end
                        4: begin
                            row = '{{8'b0, a_8bit}};
                        end
                        5: begin
                            row = '{{6'b0, a_10bit}};
                        end
                        6: begin
                            row = '{{4'b0, a_12bit}};
                        end
                        7: begin
                            row = '{{2'b0, a_14bit}};
                        end
                        default: begin
                            row = '{0};
                        end
                    endcase

                    case (j)
                        1: begin
                            column = '{{14'b0, b_2bit}};
                        end
                        2: begin
                            column = '{{12'b0, b_4bit}};
                        end
                        3: begin
                            column = '{{10'b0, b_6bit}};
                        end
                        4: begin
                            column = '{{8'b0, b_8bit}};
                        end
                        5: begin
                            column = '{{6'b0, b_10bit}};
                        end
                        6: begin
                            column = '{{4'b0, b_12bit}};
                        end
                        7: begin
                            column = '{{2'b0, b_14bit}};
                        end
                        default: begin
                            column = '{0};
                        end
                    endcase

                    C_in = 0;
                    valid_in = 1;
                    #20;

                    wait(valid_out==1);
                    #1;
                    assert(D == product) else begin
                        $display("TEST %2d x %2d-bit FAILED:   %4d x %4d = %8d OUT: %8d",
                        2*i, 2*j, a_list[i-1], b_list[j-1], product, D);
                        $fatal();
                    end
                    $display("TEST %2d x %2d-bit SUCCEEDED:   %4d x %4d = %8d OUT: %8d",
                    2*i, 2*j, a_list[i-1], b_list[j-1], product, D);
                end
            end

            #10;

            row = '{0};
            column = '{0};
        end
endmodule
