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

    generic_mux #(
        .WIDTH(P),
        .NUMBER(8)
    ) mux_a (
        .mux_in('{reg_a[P-1:0], reg_a[2*P-1:P], reg_a[3*P-1:2*P], reg_a[4*P-1:3*P],
        reg_a[5*P-1:4*P], reg_a[6*P-1:5*P], reg_a[7*P-1:6*P], reg_a[8*P-1:7*P]}),
        .sel(muxSelA),
        .out(input_a)
    );

    generic_mux #(
        .WIDTH(P),
        .NUMBER(8)
    ) mux_b (
        .mux_in('{reg_b[P-1:0], reg_b[2*P-1:P], reg_b[3*P-1:2*P], reg_b[4*P-1:3*P],
        reg_b[5*P-1:4*P], reg_b[6*P-1:5*P], reg_b[7*P-1:6*P], reg_b[8*P-1:7*P]}),
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

    logic [2*P:0] sumWithCarry;
    logic enableAdder;
    assign enableAdder = ~lastOut;
    assign sumWithCarry = enableAdder ? accumSum + prod : accumSum;
    assign adderCout = sumWithCarry[2*P];
    assign nextAccumSum = sumWithCarry[2*P-1:0];

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

