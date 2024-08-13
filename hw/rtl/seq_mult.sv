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
    output logic [P-1:0] p,
    output logic newOut,
    output logic done

);

    localparam MAX_WIDTH_BITS = $clog2(MAX_WIDTH);
    localparam M = MAX_WIDTH_BITS; // shorthand parameter

    logic countLast1, countLast2;
    logic ce1, ce2, rstCount;
    logic [M-1:0] countOut1, countOut2;

    logic [P-1:0] input_a, input_b;
    logic [2*P-1:0] prod;
    logic invertFirstBit, invertSecondRow;

    logic [2*P-1:0] nextAccumSum;
    logic unsigned [2*P-1:0] nextCarryCount;
    logic adderCout;

    logic placeOne;
    reg lastOut;
    reg doneReg;
    assign done = doneReg;
    

    reg [2*MAX_WIDTH-1:0] reg_a;
    reg [2*MAX_WIDTH-1:0] reg_b;
    reg [2*P-1:0] accumSum;
    reg unsigned [2*P-1:0] carryCount;
    reg [P-1:0] out;
    reg countDown;

    assign p = out;

    assign invertFirstBit = (countLast1 & countOut2 == 0) | (countDown & countOut2 == 0);
    assign invertSecondRow = (countLast1 & countLast2) | (countDown & countLast2);

    assign nextCarryCount = adderCout? carryCount + 1'b1 : carryCount;

    assign input_a = reg_a[MAX_WIDTH+P-1:MAX_WIDTH];
    assign input_b = reg_b[MAX_WIDTH+P-1:MAX_WIDTH];

    // MULTIPLIER IS NOT YET PARAMETRIZED FOR DIFFERENT P !!!
    if (P == 1) begin
        assign prod = (invertFirstBit ^ invertSecondRow)? ~(input_a & input_b) : input_a & input_b;
    end
    else if (P == 2) begin
    mult_2bit mult_2bit (
        .multiplier(input_a),
        .multiplicand(input_b),
        .product(prod),
        .invertFirstBit(invertFirstBit),
        .invertSecondRow(invertSecondRow)
    );
    end

    adder #(2*P) adder (
        .a(prod),
        .b(accumSum),
        .sum(nextAccumSum),
        .cout(adderCout)
    );

    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n | start) begin
            out <= 0;
        end else if (countLast2 | lastOut) begin
            out <= nextAccumSum[P-1:0];
        end else begin
            out <= out;
        end
    end

    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n | start) begin
            accumSum <= 0;
        end else if (countLast2) begin
            accumSum <= {nextCarryCount[P-1:0], nextAccumSum[2*P-1:P]};
        end else begin
            accumSum <= nextAccumSum;
        end
    end

    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n | start) begin
            carryCount <= 0;
        end else if (countLast2) begin
            if (placeOne) begin
                carryCount <= {{(P-1){1'b0}}, 1'b1, nextCarryCount[2*P-1:P]};
            end else begin
                carryCount <= {{P{1'b0}}, nextCarryCount[2*P-1:P]};
            end
            
        end else begin
            carryCount <= nextCarryCount;
        end
    end

    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n) begin
            reg_a <= 0;
            reg_b <= 0;
            countDown <= 0;
            lastOut <= 0;
            doneReg <= 0;
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

        if (countOut1 == 0 & countDown) begin
            lastOut <= 1'b1;
        end else begin 
            lastOut <= 1'b0;
        end

        if (lastOut) begin
            doneReg <= 1'b1;
        end else begin 
            doneReg <= 1'b0;
        end

        if (countLast2 | lastOut) begin
            newOut <= 1'b1;
        end else begin
            newOut <= 1'b0;
        end
    end

    assign rstCount = start;
    assign ce1 = countLast2;
    assign ce2 = 1'b1;

    counter_up_down #(.M(M), .P(P)) count1 (
        .clk(clk),
        .rst(rstCount),
        .ce(ce1),
        .countSet(bitsize-P),
        .out(countOut1),
        .last(countLast1),
        .countDown(countDown)
    );

    counter_up_repeat #(.M(M), .P(P)) count2 (
        .clk(clk),
        .rst(rstCount),
        .ce(ce2),
        .countSet(countOut1),
        .out(countOut2),
        .last(countLast2)
    );

    counter_carry #(.M(M), .P(P)) countCarry (
        .clk(clk),
        .rst(rstCount),
        .ce(countLast2),
        .bitSize(bitsize),
        .placeOne(placeOne)
    );
    
    endmodule

module counter_carry #(
    parameter M, 
    parameter P
) (
    input clk, rst, ce,
    input [M-1:0] bitSize,
    output placeOne
);
    logic [M:0] cnt;
    logic [M:0] cnt_next;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 4*P;
        end else if (ce) begin
            cnt <= cnt_next;
        end
    end

    assign cnt_next = cnt + P;
    assign placeOne = (cnt == bitSize | cnt == 2*bitSize) ? 1'b1 : 1'b0;

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

module adder #(P) (
    input logic [P-1:0] a,
    input logic [P-1:0] b,
    output logic [P-1:0] sum,
    output logic cout
);
    logic [P-1:0] carryWires;
    assign cout = carryWires[P-1];

    half_adder ha (.a(a[0]), .b(b[0]), .sum(sum[0]), .carry(carryWires[0]));

    genvar i;
    for (i = 1; i < P; i = i + 1) begin
        full_adder fa(
            .a(a[i]),
            .b(b[i]),
            .sum(sum[i]),
            .cin(carryWires[i-1]),
            .cout(carryWires[i])
        );
    end

endmodule
