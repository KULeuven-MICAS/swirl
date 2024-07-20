module bitwise_add #(
    parameter int P = 32
)(
    input logic [P-1:0] a,
    input logic [P-1:0] b,
    output logic [P-1:0] sum
);
    always_comb begin
        sum = a + b;
        if (a[P-1] == 0 && b[P-1] == 0 && sum[P-1] == 1) begin
        sum = {1'b0, {(P-1){1'b1}}};
        end
        else if (a[P-1] == 1 && b[P-1] == 1 && sum[P-1] == 0) begin
        sum = {1'b1, {(P-1){1'b0}}};
        end
    end
endmodule

