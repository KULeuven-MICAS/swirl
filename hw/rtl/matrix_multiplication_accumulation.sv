module matrix_multiplication_accumulation #(
    parameter int M,
    parameter int N,
    parameter int K,
    parameter int P,
    parameter int TREE = 1,
    parameter int PIPESTAGES = 1,
    parameter int MODE = 0 // 0 = 8-bit, 1 = partitioned 4-/8-bit, 2 = sequential
)(
    input wire signed [P-1:0] A [M][K],
    input wire signed [P-1:0] B [K][N],
    input wire signed [4*P-1:0] C [M][N],
    output wire signed [4*P-1:0] D [M][N],

    input wire valid_in, ready_out,
    output wire ready_in, valid_out,

    input wire clk_i,
    input wire rst_ni,

    input wire halvedPrecision = 0,
    input wire [3:0] bitSizeA = 4,
    input wire [3:0] bitSizeB = 4
);
    logic signed [P-1:0] A_stage [PIPESTAGES] [M][K];
    logic signed [P-1:0] B_stage [PIPESTAGES] [K][N];
    logic signed [4*P-1:0] C_stage [PIPESTAGES] [M][N];
    logic valid_stage[PIPESTAGES], ready_stage[PIPESTAGES];

    wire valid_out_sequential;
    wire ready_out_sequential;
    wire valid_in_sequential;
    wire ready_in_sequential;

    initial begin
        // $dumpfile("tb_matmul_module.vcd"); 
        // $dumpvars(0, matrix_multiplication_accumulation);
        // $monitor("At time %t, ready_stage = %p, valid_stage = %p, A_in = %p, B_in = %p, C_in = %p, reset = %p, D_o = %p",
        // $time, ready_stage[0], valid_stage[0], A_stage[1], B_stage[1], C_stage[1], rst_ni, D);
    end

    assign A_stage[0] = A;
    assign B_stage[0] = B;
    assign C_stage[0] = C;

    assign ready_in = ready_stage[0];
    assign valid_stage[0] = valid_in;
    
    if (MODE == 0 | MODE == 1) begin
        assign ready_stage[PIPESTAGES-1] = ready_out;
        assign valid_out = valid_stage[PIPESTAGES-1];
    end else begin
        assign ready_out_sequential = ready_out;
        assign valid_out = valid_out_sequential;
        assign ready_stage[PIPESTAGES-1] = ready_in_sequential;
        assign valid_in_sequential = valid_stage[PIPESTAGES-1];
    end
    

     // Elastic pipeline logic
    localparam int total_width_A = M * K * P;
    localparam int total_width_B = K * N * P;
    localparam int total_width_C = M * N * 4 * P;
    localparam int total_width_D = M * N * 4 * P;
    localparam int total_width = total_width_A + total_width_B + total_width_C;
    logic [0:total_width-1] data_stage [PIPESTAGES];

    genvar i;
    generate
        for (i = 0; i < PIPESTAGES-1; i = i + 1) begin : gen_pipeline
            matrix_flattener #(
                .WIDTH(K),
                .HEIGHT(M),
                .P(P)
            ) A_flattener_stage (
                .A(A_stage[i]),
                .data_out(data_stage[i][0:total_width_A-1])
            );

            matrix_flattener #(
                .WIDTH(N),
                .HEIGHT(K),
                .P(P)
            ) B_flattener_stage (
                .A(B_stage[i]),
                .data_out(data_stage[i][total_width_A:total_width_A+total_width_B-1])
            );

            matrix_flattener #(
                .WIDTH(N),
                .HEIGHT(M),
                .P(4*P)
            ) C_flattener_stage (
                .A(C_stage[i]),
                .data_out(data_stage[i][total_width_A+total_width_B:total_width_A+total_width_B+total_width_C-1])
            );

            VX_pipe_buffer #(
                .DATAW   (P*M*K + P*K*N + 4*P*M*N),
                .PASSTHRU(0)
            ) buffer (
                .clk       (clk_i),
                .reset     (~rst_ni),
                .valid_in  (valid_stage[i]),
                .data_in   (data_stage[i]),
                .ready_in  (ready_stage[i]),
                .valid_out (valid_stage[i+1]),
                .data_out  ({A_stage[i+1], B_stage[i+1], C_stage[i+1]}),
                .ready_out (ready_stage[i+1])
            );
        end
    endgenerate

    logic signed [P-1:0] A_mul [M][K];
    logic signed [P-1:0] B_mul [K][N];
    logic signed [4*P-1:0] C_mul [M][N];
    assign A_mul = A_stage[PIPESTAGES-1];
    assign B_mul = B_stage[PIPESTAGES-1];
    assign C_mul = C_stage[PIPESTAGES-1];

    if (MODE == 0) begin : gen_non_config
        // Chain implementation
        if (TREE == 0) begin : gen_chain_adder
            genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : gen_column_block
                for (row = 0; row < M; row = row + 1) begin: gen_row_block
                    logic [4*P-1:0] temp_sum[K+1];
                    assign temp_sum[0] = C_mul[row][column];
                    for (element = 0; element < K; element = element + 1) begin : gen_element_block
                        logic [4*P-1:0] mult;
                        assign mult = A_mul[row][element] * B_mul[element][column];
                        bitwise_add #(
                            .P(4*P)
                            ) add (
                                .a(temp_sum[element]),
                                .b(mult),
                                .sum(temp_sum[element+1])
                            );
                    end // gen_element_block
                    assign D[row][column] = temp_sum[K];
                end // gen_row_block
            end // gen_column_block
        end
        // Tree implementation
        else begin : gen_tree_adder
            genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : gen_column_block
                for (row = 0; row < M; row = row + 1) begin: gen_row_block
                    logic signed [2*P-1:0] mults [K];
                    for (element = 0; element < K; element = element + 1) begin : gen_element_block
                        assign mults[element] = A_mul[row][element] * B_mul[element][column];
                    end // gen_element_block

                    logic signed [4*P-1:0] mult_sum;
                    logic signed [4*P-1:0] sum;

                    binary_tree_adder #(
                        .P(2*P),
                        .INPUTS_AMOUNT(K)
                    ) tree_add (
                        .inputs(mults),
                        .out(mult_sum)
                    );

                    bitwise_add #(
                        .P(4*P)
                    ) C_add (
                        .a(mult_sum),
                        .b(C_mul[row][column]),
                        .sum(sum)
                    );

                    assign D[row][column] = sum;
                end // gen_row_block
            end // gen_column_block
        end
    end else if (MODE == 1) begin
        genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : gen_column_block
                for (row = 0; row < M; row = row + 1) begin: gen_row_block
                    logic signed [2*P-1:0] mults [K];
                    for (element = 0; element < K; element = element + 1) begin : gen_element_block
                        config_multiplier_8bit mult (
                            .multiplier(A_mul[row][element]),
                            .multiplicand(B_mul[element][column]),
                            .product(mults[element]),
                            .halvedPrecision(halvedPrecision)
                        );

                    end 

                    logic signed [4*P-1:0] mult_sum;
                    logic signed [31:0] sum;

                    config_binary_tree_adder #(
                        .P(2*P),
                        .INPUTS_AMOUNT(K)
                    ) tree_add (
                        .inputs(mults),
                        .out(mult_sum),
                        .halvedPrecision(halvedPrecision)
                    );

                    bitwise_add #(
                        .P(32)
                    ) C_add (
                        .a(mult_sum),
                        .b(C_mul[row][column]),
                        .sum(sum)
                    );

                    assign D[row][column] = sum;
                end // gen_row_block
            end // gen_column_block
    end else if (MODE == 2) begin

        logic signed [15:0] A_seq [M][K];
        logic signed [15:0] B_seq [K][N];

        genvar i, j;
        for ( i = 0; i < M; i = i + 1) begin
            for ( j = 0; j < K; j = j + 1) begin
                assign A_seq[i][j] = {{(16-P){1'b0}}, A_mul[i][j]};
            end
        end
        for ( i = 0; i < K; i = i + 1) begin
            for ( j = 0; j < N; j = j + 1) begin
                assign B_seq[i][j] = {{(16-P){1'b0}}, B_mul[i][j]};
            end
        end
        seq_MAC #(
            .M(M),
            .N(N),
            .K(K),
            .P(2),
            .MAX_WIDTH(16)
        ) seq_MAC (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .A_mul(A_seq),
            .B_mul(B_seq),
            .C_mul(C_mul),
            .D(D),
            .valid_in(valid_in_sequential),
            .ready_in(ready_in_sequential),
            .valid_out(valid_out_sequential),
            .ready_out(ready_out_sequential),
            .bitSizeA(bitSizeA),
            .bitSizeB(bitSizeB)
        );
    end

endmodule
