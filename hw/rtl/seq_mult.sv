module seq_mult #(
    parameter P = 2,
    parameter MAX_WIDTH = 16
    ) (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [MAX_WIDTH-1:0] a,
    input logic [MAX_WIDTH-1:0] b,
    input logic [$clog2(MAX_WIDTH)-1:0] bitsize,
    output logic [P-1:0] p

);

    localparam MAX_WIDTH_BITS = $clog2(MAX_WIDTH);
    localparam M = MAX_WIDTH_BITS; // shorthand parameter

    logic countLast1, countLast2;
    logic ce1, ce2, rstCount1, rstCount2;
    logic [M-1:0] countOut1, countOut2;

    logic [P-1:0] input_a, input_b;

    reg [2*MAX_WIDTH-1:0] reg_a;
    reg [2*MAX_WIDTH-1:0] reg_b;
    reg countDown;

    assign input_a = reg_a[MAX_WIDTH+P-1:MAX_WIDTH];
    assign input_b = reg_b[MAX_WIDTH+P-1:MAX_WIDTH];

    always_ff @(posedge clk, negedge rst_n) begin
        if (rst_n) begin
            reg_a = 0;
            reg_b = 0;
            countDown = 0;
        end else if (start) begin
            reg_a[2*MAX_WIDTH-1:MAX_WIDTH] <= a;
            reg_b[2*MAX_WIDTH-1:MAX_WIDTH] <= b;
        end else begin
            if (countLast1 & countLast2 | countDown & countLast2) begin
                reg_a <= reg_a << countOut1 - P;
                reg_b <= reg_b >> countOut1;
            end else if (countLast2) begin
                reg_a <= reg_a << countOut1;
                reg_b <= reg_b >> countOut1 + P;
            end else begin
                reg_a <= reg_a >> P;
                reg_b <= reg_b << P;
            end
        end

        if (countLast1 & countLast2) begin
            countDown <= ~countDown;
        end
    end

    assign rstCount1 = start;
    assign rstCount2 = start;
    assign ce1 = countLast2;
    assign ce2 = 1'b1;

    counter_up_down #(.M(M), .P(P)) count1 (
        .clk(clk),
        .rst(rstCount1),
        .ce(ce1),
        .countSet(bitsize-P),
        .out(countOut1),
        .last(countLast1),
        .countDown(countDown)
    );

    counter_up_repeat #(.M(M), .P(P)) count2 (
        .clk(clk),
        .rst(rstCount2),
        .ce(ce2),
        .countSet(countOut1),
        .out(countOut2),
        .last(countLast2)
    );
    
    endmodule

module counter_up_repeat #(
    parameter M,
    parameter P
    ) (
    input clk, rst, ce,
    input [M-1:0] countSet,
    output [M-1:0] out,
    output last
    );

    logic [M-1:0] cnt;
    logic [M-1:0] cnt_next;
    logic       last_tmp;

    always @(posedge clk) begin
        if(rst) begin
            last_tmp <= 1'b0;
            cnt <= 1'b0;
        end
        else if(ce) begin
            if(cnt + P == countSet) begin
                cnt <= cnt_next;
                last_tmp <= 1'b1;
            end else if (cnt == countSet) begin
                cnt <= 0;
                last_tmp <= 1'b0;
            end else begin
                cnt <= cnt_next;
                last_tmp <= 1'b0;
            end
        end
    end

    assign out = cnt;
    assign cnt_next = cnt + P;
    assign last = (countSet==0)? 1'b1 : last_tmp;

endmodule

module counter_up_down #(
    parameter M,
    parameter P
    ) (
    input clk, rst, ce, countDown,
    input [M-1:0] countSet,
    output [M-1:0] out,
    output last
    );

    logic [M-1:0] cnt;
    logic [M-1:0] cnt_next;
    logic       last_tmp;

    always @(posedge clk) begin
        if(rst) begin
            last_tmp <= 1'b0;
            cnt <= 1'b0;
        end
        else if(ce) begin
            if( (cnt + P == countSet) & !countDown) begin
            cnt <= cnt_next;
            last_tmp <= 1'b1;
            end else if (cnt == countSet) begin
            cnt <= cnt - P;
            last_tmp <= 1'b0;
            end else begin
            cnt <= cnt_next;
            last_tmp <= 1'b0;
        end
        end
    end

    assign out = cnt;
    assign cnt_next = countDown? cnt - P : cnt + P;
    assign last = (countSet==0)? 1'b1 : last_tmp;

endmodule