module seq_mult_adder #(
    parameter int K = 2,
    parameter int P = 8
)(
    input logic clk_i,
    input logic rst_ni,
    input logic signed [P-1:0] row [K],
    input logic signed [P-1:0] column [K],
    input logic [31:0] C_in,
    input wire valid_in_sequential,
    output wire ready_in_sequential,
    output wire valid_out_sequential,
    input wire ready_out_sequential
);

    wire start;
    wire newOut;

    initial begin
            $dumpfile("tb_seq_mult_adder.vcd");
            $dumpvars(0, seq_mult_adder);
        end

    localparam int P_seq_mult = 2;
    localparam int MAX_WIDTH = 16;
    genvar element;
    logic signed [P_seq_mult-1:0] partial_mults [K];

    for (element = 0; element < K; element = element + 1) begin : gen_element_block
 
        seq_mult #(
            .P(P_seq_mult),
            .MAX_WIDTH(MAX_WIDTH)
        ) seq_mult1 (
            .clk(clk_i),
            .rst_n(rst_ni),
            .a({8'b00000000, row[element]}),
            .b({8'b00000000, column[element]}),
            .bitSize(4'b0100),
            .p(partial_mults[element]),
            .newOut(newOut),
            .valid_in(valid_in_sequential),
            .ready_in(ready_in_sequential),
            .valid_out(valid_out_sequential),
            .ready_out(ready_out_sequential),
            .start(start)
        );
    end

    logic unsigned [P_seq_mult + $clog2(K)-1:0] mult_sum;
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
            offsetCount <= offsetCount + P_seq_mult;
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