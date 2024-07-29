module matrix_multiplication_accumulation #(
    parameter int M,
    parameter int N,
    parameter int K,
    parameter int P,
    parameter int TREE = 1
)(
    input wire signed [P-1:0] A [M][K],
    input wire signed [P-1:0] B [K][N],
    input wire signed [4*P-1:0] C [M][N],
    output wire signed [4*P-1:0] D [M][N]
);

    // Chain implementation
    if (TREE == 0) begin : gen_chain_adder
        genvar column, row, element;
        for (column = 0; column < N; column = column + 1) begin : gen_column_block
            for (row = 0; row < M; row = row + 1) begin: gen_row_block
                logic [4*P-1:0] temp_sum[K+1];
                assign temp_sum[0] = C[row][column];
                for (element = 0; element < K; element = element + 1) begin : gen_element_block
                    logic [4*P-1:0] mult;
                    assign mult = A[row][element] * B[element][column];
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
                logic signed [4*P-1:0] mults [K];
                for (element = 0; element < K; element = element + 1) begin : gen_element_block
                    assign mults[element] = A[row][element] * B[element][column];
                end // gen_element_block

                logic signed [4*P-1:0] mult_sum[1];
                logic signed [4*P-1:0] sum;

                binary_tree_adder #(
                    .P(4*P),
                    .INPUTS_AMOUNT(K),
                    .OUTPUTS_AMOUNT(1)
                ) tree_add (
                    .inputs(mults),
                    .outputs(mult_sum)
                );

                bitwise_add #(
                    .P(4*P)
                ) C_add (
                    .a(mult_sum[0]),
                    .b(C[row][column]),
                    .sum(sum)
                );

                assign D[row][column] = sum;
            end // gen_row_block
        end // gen_column_block
    end

endmodule
