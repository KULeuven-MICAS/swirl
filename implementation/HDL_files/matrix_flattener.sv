module matrix_flattener #(
    parameter int WIDTH = 8, // Example dimensions, adjust as needed
    parameter int HEIGHT = 4,
    parameter int P = 8  // Example bit-width, adjust as needed
)(
    input logic signed [P-1:0] A [HEIGHT-1:0][WIDTH-1:0],
    output logic [(WIDTH*HEIGHT)*P-1:0] data_out
);

    always_comb begin
        automatic int index = 0;
        // Flatten A
        for (int i = 0; i < HEIGHT; i++) begin
            for (int j = 0; j < WIDTH; j++) begin
                data_out[index +: P] = A[i][j];
                index += P;
            end
        end
    end

endmodule