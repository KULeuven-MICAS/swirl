module seq_MAC #(
    parameter int M = 2,
    parameter int N = 2,
    parameter int K = 2,
    parameter int MAX_WIDTH = 16,
    parameter int P = 2
)(
    input logic clk_i,
    input logic rst_ni,
    input wire signed [MAX_WIDTH-1:0] A_mul [M][K],
    input wire signed [MAX_WIDTH-1:0] B_mul [K][N],
    input wire signed [31:0] C_mul [M][N],
    input logic unsigned [$clog2(MAX_WIDTH/P)+1:0] bitSize,
    input wire valid_in,
    output wire ready_in,
    output wire valid_out,
    output wire [31:0] D [M][N],
    input wire ready_out
);

// initial begin
//     $monitor("A: %p, B: %p, C: %p, D: %p, valid_out = %d", A_mul, B_mul, C_mul, D, valid_out);
// end

    localparam MAX_WIDTH_BITS = $clog2(MAX_WIDTH/P) + 1; // bits needed to represent bitSize in steps of P
    localparam MB = MAX_WIDTH_BITS; // shorthand parameter


    logic countLast1, countLast2, countLastBoth;
    logic ce1, ce2, rstCount;
    logic [MB-1:0] countOut1, countOut2;
    logic [MB:0] shiftCount;
    logic busy;
    logic invertFirstBit, invertSecondRow;
    logic [2:0] muxSelA, muxSelB;
    logic [MB-1:0] muxSelOffset;
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
            lastMultAccum <= 0;
         end else if (start) begin
            busy <= 1'b1;
            countDown <= 0;
            newOut <= 0;
            lastMultAccum <= 0;
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
            lastMultAccum <= 1'b0;
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

    
    logic unsigned [MB-1:0] count1_start;
    assign count1_start =  bitSize - 1'b1;

    programmable_counter #(.WIDTH(MB), .UPDOWN(1'b1)) count1 (
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

    programmable_counter #(.WIDTH(MB), .UPDOWN(1'b0)) count2 (
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

    localparam [MB:0] total_product_width = 2*MAX_WIDTH/P; // width in chunks of P
    logic [MB:0] count3_start = 4;

    programmable_counter #(.WIDTH(MB+1), .UPDOWN(1'b0)) count3 (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .clear_i(1'b0),
        .en_i(countLast2),
        .load_i(start),
        .down_i(1'b0),
        .countSet(total_product_width),
        .d_i(count3_start),
        .q_o(shiftCount),
        .last_o()
    );

    // initial begin
    //     $dumpfile("seq_MAC.vcd");
    //     $dumpvars(0, seq_MAC);
    // end


    genvar column, row, element;
        for (column = 0; column < N; column = column + 1) begin : gen_column_block
            for (row = 0; row < M; row = row + 1) begin: gen_row_block

                logic [P-1:0] partial_mults [K];
                for (element = 0; element < K; element = element + 1) begin : gen_element_block
                    seq_mult #(
                    .P(P),
                    .MAX_WIDTH(MAX_WIDTH)
                ) seq_mult (
                    .clk(clk_i),
                    .rst_n(rst_ni),
                    .a(A_mul[row][element]),
                    .b(B_mul[element][column]),
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
                    .out(mult_sum),
                    .signedAddition(lastMultAccum)
                );


                reg [31:0] accum_mult;
                logic [31:0] accum_mult_next;

                logic [4:0] offsetCount;
                logic [31:0] mult_sum_extend;

                logic signed [P + $clog2(K):0] mult_sum_signed;
                assign mult_sum_signed = lastMultAccum & mult_sum[P + $clog2(K)-1]? {1'b1, mult_sum} : {1'b0, mult_sum};
                assign mult_sum_extend = mult_sum_signed << offsetCount;

                always_ff @(posedge clk_i or negedge rst_ni) begin
                    if (~rst_ni) begin
                        accum_mult <= 0;
                    end else if (start) begin
                        accum_mult <= C_mul[row][column];
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

                assign D[row][column] = accum_mult;

            end
        end


    

    

endmodule