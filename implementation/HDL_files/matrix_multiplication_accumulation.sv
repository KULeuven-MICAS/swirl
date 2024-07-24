module matrix_multiplication_accumulation #(
    parameter int M,
    parameter int N,
    parameter int K,
    parameter int P
)(
    input logic signed [P-1:0] A [M][K],
    input logic signed [P-1:0] B [K][N],
    input logic signed [4*P-1:0] C [M][N],
    output logic signed [4*P-1:0] D [M][N]
);
    generate
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
                    end
                    assign D[row][column] = temp_sum[K];
                end
            end
        endgenerate
endmodule
