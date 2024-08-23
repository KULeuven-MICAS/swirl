module seq_mult #(
    parameter unsigned P = 2,
    parameter unsigned [4:0] MAX_WIDTH = 16
    ) (
    input logic clk,
    input logic rst_n,
    input logic [MAX_WIDTH-1:0] a,
    input logic [MAX_WIDTH-1:0] b,
    input logic unsigned [$clog2(MAX_WIDTH/P):0] bitSize,
    input logic countDown,
    input logic countLast2,
    input logic lastOut,
    input logic [2:0] muxSelA,
    input logic [2:0] muxSelB,
    input logic invertFirstBit,
    input logic invertSecondRow,
    input logic start,
    input logic placeOne,
    input logic [1:0] countShiftInput,
    input logic [4*P-1:0] initSum,
    output logic [P-1:0] p

);
    logic [P-1:0] input_a, input_b;
    logic [2*P-1:0] prod;
    logic [2*P-1:0] nextAccumSum;
    logic unsigned [2*P-1:0] nextCarryCount;
    logic adderCout;

    reg [MAX_WIDTH-1:0] reg_a;
    reg [MAX_WIDTH-1:0] reg_b;
    reg [2*P-1:0] accumSum;
    reg unsigned [2*P-1:0] carryCount;
    reg [P-1:0] out;

    assign p = out;
    assign nextCarryCount = adderCout? carryCount + 1'b1 : carryCount;

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
    if (P == 2) begin : gen_mult_2bit
    mult_2bit mult_2bit (
        .multiplier(input_a),
        .multiplicand(input_b),
        .product(prod),
        .invertFirstBit(invertFirstBit),
        .invertSecondRow(invertSecondRow)
    );
    end

    adder #(2*P) adder (
        .a(accumSum),
        .b(prod),
        .en(~lastOut),
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
            accumSum <= initSum[3:0];
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
            carryCount <= initSum[7:4];
        end else if (countLast2) begin
            carryCount <= {countShiftInput, nextCarryCount[2*P-1:P]};
        end else begin
            carryCount <= nextCarryCount;
        end
    end

     always_ff @(posedge clk, negedge rst_n) begin
         if (!rst_n) begin
             reg_a <= 0;
             reg_b <= 0;
         end else if (start) begin
             reg_a <= a;
             reg_b <= b;
         end
     end




endmodule

module adder #(parameter int P) (
    input logic [P-1:0] a,
    input logic [P-1:0] b,
    input logic en,
    output logic [P-1:0] sum,
    output logic cout
);
    logic [P-1:0] carryWires;
    logic [P-1:0] sumWires;
    assign cout = carryWires[P-1];

    half_adder ha (.a(a[0]), .b(b[0]), .sum(sumWires[0]), .carry(carryWires[0]));

    genvar i;
    for (i = 1; i < P; i = i + 1) begin : gen_adder
        full_adder fa(
            .a(a[i]),
            .b(b[i]),
            .sum(sumWires[i]),
            .cin(carryWires[i-1]),
            .cout(carryWires[i])
        );
    end

    assign sum = en? sumWires : a;

endmodule
