module seq_mult #(
    parameter unsigned P = 2,
    parameter unsigned [4:0] MAX_WIDTH = 16
    ) (
    input logic clk,
    input logic rst_n,
    input logic [MAX_WIDTH-1:0] a,
    input logic [MAX_WIDTH-1:0] b,
    input logic unsigned [$clog2(MAX_WIDTH/P):0] bitSize,
    output logic [P-1:0] p,
    output logic newOut,
    output logic ready_in, valid_out,
    input wire ready_out, valid_in,
    output logic start

);

    logic busy;

    assign stall = (valid_out & ~ready_out) | busy;
    assign start = valid_in & ~stall;
    assign ready_in = ~stall;

    

    localparam MAX_WIDTH_BITS = $clog2(MAX_WIDTH/P) + 1; // bits needed to represent bitSize in steps of P
    localparam M = MAX_WIDTH_BITS; // shorthand parameter

    logic countLast1, countLast2, countLastBoth;
    logic ce1, ce2, rstCount;
    logic [M-1:0] countOut1, countOut2;
    logic [M:0] shiftCount;

    logic [P-1:0] input_a, input_b;
    logic [2*P-1:0] prod;
    logic invertFirstBit, invertSecondRow;

    logic [2*P-1:0] nextAccumSum;
    logic unsigned [2*P-1:0] nextCarryCount;
    logic adderCout;

    logic [2:0] muxSelA, muxSelB;
    logic [M-1:0] muxSelOffset;

    logic placeOne;
    reg lastOut;
    reg lastMultAccum;
    reg valid_out_reg;
    assign valid_out = valid_out_reg;
    

    reg [MAX_WIDTH-1:0] reg_a;
    reg [MAX_WIDTH-1:0] reg_b;
    reg [2*P-1:0] accumSum;
    reg unsigned [2*P-1:0] carryCount;
    reg [P-1:0] out;
    reg countDown;

    assign p = out;

    assign invertFirstBit = (countLast1 & countOut2 == 0) | (countDown & countOut2 == 0);
    assign invertSecondRow = (countLastBoth) | (countDown & countLast2);

    assign nextCarryCount = adderCout? carryCount + 1'b1 : carryCount;

    assign muxSelOffset = countDown? bitSize - 1 - countOut1 : 0;
    assign muxSelA = countOut2 + muxSelOffset;
    assign muxSelB = countOut1 - countOut2 + muxSelOffset;

    assign countLastBoth = countLast1 & countLast2;
    assign placeOne = (shiftCount == bitSize | shiftCount == 2*bitSize) ? 1'b1 : 1'b0;

    assign rstCount = ~start;
    assign ce1 = countLast2 & busy;
    assign ce2 = busy;


    multiplexer_8to1 #(
        .M(P)
    ) mux_a (
        .in(reg_a),
        .sel(muxSelA),
        .out(input_a)
    );

    multiplexer_8to1 #(
        .M(P)
    ) mux_b (
        .in(reg_b),
        .sel(muxSelB),
        .out(input_b)
    );


    // MULTIPLIER IS NOT YET PARAMETRIZED FOR DIFFERENT P !!!
    if (P == 2) begin
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

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n | start) begin
            out <= 0;
        end else if (countLast2 | lastOut) begin
            out <= nextAccumSum[P-1:0];
        end else begin
            out <= out;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            accumSum <= 0;
        end else if (start) begin
            if (bitSize == 1) begin // assign correct ones for 2 bit width
                accumSum <= 4'b0100;
            end else begin
                accumSum <= 0;
            end
        end else if (countLast2) begin
            accumSum <= {nextCarryCount[P-1:0], nextAccumSum[2*P-1:P]};
        end else begin
            accumSum <= nextAccumSum;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            carryCount <= 0;
        end else if (start) begin
            if (bitSize == 1 | bitSize == 2) begin // assign correct ones for 2 bit width
                carryCount <= 4'b0001;
            end else if (bitSize == 3) begin
                carryCount <= 4'b0100;
            end else begin
                carryCount <= 0;
            end
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

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            reg_a <= 0;
            reg_b <= 0;
            countDown <= 0;
            lastOut <= 0;
            valid_out_reg <= 0;
            busy <= 0;
            newOut <= 0;
        end else if (start) begin
            reg_a <= a;
            reg_b <= b;
            busy <= 1'b1;
            countDown <= 0;
            newOut <= 0;
        end

        if (countLastBoth & ~countDown) begin
            countDown <= ~countDown;
        end

        if (countOut1 == 0 & countDown) begin
            lastOut <= 1'b1;
        end else begin 
            lastOut <= 1'b0;
        end

        if (lastOut) begin
            lastMultAccum <= 1'b1;
            lastOut <= 1'b0;
        end
        

        if (lastMultAccum) begin
            valid_out_reg <= 1'b1;
            busy <= 1'b0;
        end else if (valid_out & stall) begin 
            valid_out_reg <= 1'b1;
        end else begin
            valid_out_reg <= 1'b0;
        end

        if ( (countLast2 | lastOut) & busy) begin
            newOut <= 1'b1;
        end else begin
            newOut <= 1'b0;
        end
    end

    logic unsigned [M-1:0] count1_start;
    assign count1_start =  bitSize - 1'b1;

    programmable_counter #(.WIDTH(M), .UPDOWN(1'b1)) count1 (
        .clk_i(clk),
        .rst_ni(rst_n),
        .clear_i(~rstCount),
        .en_i(ce1),
        .load_i(1'b0),
        .down_i(countDown),
        .countSet(count1_start),
        .d_i(),
        .q_o(countOut1),
        .last_o(countLast1)
    );

    programmable_counter #(.WIDTH(M), .UPDOWN(1'b0)) count2 (
        .clk_i(clk),
        .rst_ni(rst_n),
        .clear_i(~rstCount),
        .en_i(ce2),
        .load_i(1'b0),
        .down_i(1'b0),
        .countSet(countOut1),
        .d_i(),
        .q_o(countOut2),
        .last_o(countLast2)
    );

    localparam [M:0] total_product_width = 2*MAX_WIDTH/P; // width in chunks of P
    logic [M:0] count3_start = 4;

    programmable_counter #(.WIDTH(M+1), .UPDOWN(1'b0)) count3 (
        .clk_i(clk),
        .rst_ni(rst_n),
        .clear_i(1'b0),
        .en_i(1'b1),
        .load_i(start),
        .down_i(1'b0),
        .countSet(total_product_width),
        .d_i(count3_start),
        .q_o(shiftCount),
        .last_o()
    );

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
