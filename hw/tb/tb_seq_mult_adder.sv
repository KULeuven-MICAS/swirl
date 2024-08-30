module tb_seq_mult_adder ();

    localparam int K = 1;
    localparam int PIPELINED = 1;
    localparam int SWEEP = 1;

        // Testbench signals
        logic signed [15:0] row [1][K];
        logic signed [15:0] column [K][1];
        logic signed [31:0] C_in [1][1];
        logic signed [31:0] D[1][1];
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
        seq_MAC #(
            .M(1),
            .N(1),
            .K(K),
            .P(2),
            .MAX_WIDTH(16),
            .PIPELINED(PIPELINED)
        ) seq_mult_adder (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .A_mul(row),
            .B_mul(column),
            .C_mul(C_in),
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
            if (PIPELINED) begin
                $dumpfile("tb_seq_mult_adder_pipelined.vcd");
                $dumpvars(0, tb_seq_mult_adder);
            end else begin
            $dumpfile("tb_seq_mult_adder.vcd");
            $dumpvars(0, tb_seq_mult_adder);
            end

            valid_in = 0;
            ready_out = 1;
            rst_ni = 0;

            #10;
            rst_ni = 1;

            if (SWEEP) begin
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
                            row[0][0] = '{{14'b0, a_2bit}};
                        end
                        2: begin
                            row[0][0] = '{{12'b0, a_4bit}};
                        end
                        3: begin
                            row[0][0] = '{{10'b0, a_6bit}};
                        end
                        4: begin
                            row[0][0] = '{{8'b0, a_8bit}};
                        end
                        5: begin
                            row[0][0] = '{{6'b0, a_10bit}};
                        end
                        6: begin
                            row[0][0] = '{{4'b0, a_12bit}};
                        end
                        7: begin
                            row[0][0] = '{{2'b0, a_14bit}};
                        end
                        default: begin
                            row[0][0] = 0;
                        end
                    endcase

                    case (j)
                        1: begin
                            column[0][0] = '{{14'b0, b_2bit}};
                        end
                        2: begin
                            column[0][0] = '{{12'b0, b_4bit}};
                        end
                        3: begin
                            column[0][0] = '{{10'b0, b_6bit}};
                        end
                        4: begin
                            column[0][0] = '{{8'b0, b_8bit}};
                        end
                        5: begin
                            column[0][0] = '{{6'b0, b_10bit}};
                        end
                        6: begin
                            column[0][0] = '{{4'b0, b_12bit}};
                        end
                        7: begin
                            column[0][0] = '{{2'b0, b_14bit}};
                        end
                        default: begin
                            column[0][0] = 0;
                        end
                    endcase

                    C_in[0][0] = 0;
                    valid_in = 1;
                    #20;

                    wait(valid_out==1);
                    #1;
                    assert(D[0][0] == product) else begin
                        $display("TEST %2d x %2d-bit FAILED:   %4d x %4d = %8d OUT: %8d",
                        2*i, 2*j, a_list[i-1], b_list[j-1], product, D[0][0]);
                        $fatal();
                    end
                    $display("TEST %2d x %2d-bit SUCCEEDED:   %4d x %4d = %8d OUT: %8d",
                    2*i, 2*j, a_list[i-1], b_list[j-1], product, D[0][0]);
                end
                end

            end else begin
                bitSizeA = 5;
                bitSizeB = 5;
                row[0][0] = -455;
                column[0][0] = 239;
                C_in[0][0] = 0;
                    valid_in = 1;
                    #20;

                    wait(valid_out==1);
                assert(D[0][0] == row[0][0]*column[0][0]) else begin
                    $display("TEST FAILED: %0d x %0d = %b OUT: %b",row[0][0],
                     column[0][0], row[0][0]*column[0][0], D[0][0]);

                end
                $display("TEST SUCCEEDED: %0d x %0d = %d OUT: %d",row[0][0],
                column[0][0], row[0][0]*column[0][0], D[0][0]);

            end


            #10;

            row[0][0] = 0;
            column[0][0] = 0;
 
            #10;

            $finish;
        end
endmodule
