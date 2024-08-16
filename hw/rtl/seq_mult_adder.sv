module seq_mult_adder #(
    parameter int K = 2,
    parameter int MAX_WIDTH = 16,
    parameter int P = 2
)(
    input logic clk_i,
    input logic rst_ni,
    input logic signed [MAX_WIDTH-1:0] row [K],
    input logic signed [MAX_WIDTH-1:0] column [K],
    input logic [31:0] C_in,
    input logic unsigned [$clog2(MAX_WIDTH/P)+1:0] bitSize,
    input wire valid_in,
    output wire ready_in,
    output wire valid_out,
    input wire ready_out
);

    localparam MAX_WIDTH_BITS = $clog2(MAX_WIDTH/P) + 1; // bits needed to represent bitSize in steps of P
    localparam M = MAX_WIDTH_BITS; // shorthand parameter


    logic countLast1, countLast2, countLastBoth;
    logic ce1, ce2, rstCount;
    logic [M-1:0] countOut1, countOut2;
    logic [M:0] shiftCount;
    logic busy;
    logic invertFirstBit, invertSecondRow;
    logic [2:0] muxSelA, muxSelB;
    logic [M-1:0] muxSelOffset;
    logic placeOne;
    logic start;
    logic newOut;

    reg lastOut;
    reg lastMultAccum;
    reg valid_out_reg;
    reg countDown;

    assign valid_out = valid_out_reg;
    assign stall = (valid_out & ~ready_out) | busy;
    assign start = valid_in & ~stall;
    assign ready_in = ~stall;

    assign invertFirstBit = (countLast1 & countOut2 == 0) | (countDown & countOut2 == 0);
    assign invertSecondRow = (countLastBoth) | (countDown & countLast2);

    assign muxSelOffset = countDown? bitSize - 1 - countOut1 : 0;
    assign muxSelA = countOut2 + muxSelOffset;
    assign muxSelB = countOut1 - countOut2 + muxSelOffset;

    assign countLastBoth = countLast1 & countLast2;
    assign placeOne = (shiftCount == bitSize | shiftCount == 2*bitSize) ? 1'b1 : 1'b0;

    assign rstCount = start;
    assign ce1 = countLast2 & busy;
    assign ce2 = busy;

always_ff @(posedge clk_i, negedge rst_ni) begin
         if (!rst_ni) begin
            countDown <= 0;
            lastOut <= 0;
            valid_out_reg <= 0;
            busy <= 0;
            newOut <= 0;
         end else if (start) begin
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
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(rstCount),
        .en_i(ce1),
        .load_i(1'b0),
        .down_i(countDown),
        .countSet(count1_start),
        .d_i(),
        .q_o(countOut1),
        .last_o(countLast1)
    );

    programmable_counter #(.WIDTH(M), .UPDOWN(1'b0)) count2 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(rstCount),
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
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(1'b0),
        .en_i(1'b1),
        .load_i(start),
        .down_i(1'b0),
        .countSet(total_product_width),
        .d_i(count3_start),
        .q_o(shiftCount),
        .last_o()
    );

    initial begin
            $dumpfile("tb_seq_mult_adder.vcd");
            $dumpvars(0, seq_mult_adder);
        end


    genvar element;
    logic signed [P-1:0] partial_mults [K];

    for (element = 0; element < K; element = element + 1) begin : gen_element_block
 
        seq_mult #(
            .P(P),
            .MAX_WIDTH(MAX_WIDTH)
        ) seq_mult1 (
            .clk(clk_i),
            .rst_n(rst_ni),
            .a(row[element]),
            .b(column[element]),
            .bitSize(bitSize),
            .p(partial_mults[element]),
            .countDown(countDown),
            .countLast2(countLast2),
            .invertFirstBit(invertFirstBit),
            .invertSecondRow(invertSecondRow),
            .muxSelA(muxSelA),
            .muxSelB(muxSelB),
            .start(start),
            .placeOne(placeOne),
            .lastOut(lastOut)
        );
    end

    logic unsigned [P + $clog2(K)-1:0] mult_sum;
    logic unsigned [31:0] sum;

    binary_tree_adder_unsigned #(
        .P(2),
        .INPUTS_AMOUNT(K)
    ) tree_add (
        .inputs(partial_mults),
        .out(mult_sum)
    );


    reg [31:0] accum_mult;
    logic [31:0] accum_mult_next;

    logic [4:0] offsetCount;
    logic [31:0] mult_sum_extend;
    assign mult_sum_extend = mult_sum << offsetCount;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            accum_mult <= 0;
        end else if (start) begin
            accum_mult <= C_in;
            offsetCount <= 0;
        end else if (newOut) begin
            accum_mult <= accum_mult_next;
            offsetCount <= offsetCount + P;
        end
    end

    bitwise_add #(
        .P(32)
    ) C_add (
        .a(accum_mult),
        .b(mult_sum_extend),
        .sum(accum_mult_next)
    );

endmodule