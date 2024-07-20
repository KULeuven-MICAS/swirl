module matrix_multiplication_accumulation #(
    parameter M,
    parameter N,
    parameter K,
    parameter P
)(
    input logic [P-1:0] A [M-1:0][K-1:0],
    input logic [P-1:0] B [K-1:0][N-1:0],
    input logic [4*P-1:0] C [M-1:0][N-1:0],
    output logic [4*P-1:0] D [M-1:0][N-1:0]
);
    generate 
            genvar column, row, element;
            for (column = 0; column < N; column = column + 1) begin : column_block
                for (row = 0; row < M; row = row + 1) begin: row_block
                    logic [4*P-1:0] temp_sum[K:0];
                    assign temp_sum[0] = C[row][column];
                    for (element = 0; element < K; element = element + 1) begin : element_block
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
