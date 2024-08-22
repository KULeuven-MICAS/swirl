module config_adder #(parameter P = 8) (
    input logic [P-1:0] a,
    input logic [P-1:0] b,
    input logic halvedPrecision,
    output logic [P+1:0] sum
);

    logic [P-1:0] carry;
    logic halfwayCarry;
    logic [P-1:0] halfwaySum;

    assign halfwayCarry = halvedPrecision ? 0 : carry[P/2-1];
    assign sum[P/2-1:0] = halfwaySum[P/2-1:0];
    assign sum[P+1] = (a[P-1] ^ b[P-1]) ? halfwaySum[P-1] : carry[P-1];

    always_comb begin

        if (halvedPrecision) begin
            sum[P/2] = (a[P/2-1] ^ b[P/2-1]) ? sum[P/2-1] : carry[P/2-1];
            sum[P:P/2+1] = halfwaySum[P-1:P/2];
        end else begin
            sum[P/2] = halfwaySum[P/2];
            sum[P-1:P/2] = halfwaySum[P-1:P/2];
            sum[P] = sum[P+1];
        end
    end

    // Instantiate half adders and full adders
    genvar i;
    generate
            half_adder ha (
                .a(a[0]),
                .b(b[0]),
                .sum(halfwaySum[0]),
                .carry(carry[0])
            );

        for (i = 1; i < P/2; i++) begin : ADDER_GEN_LSB
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i-1]),
                .sum(halfwaySum[i]),
                .cout(carry[i])
            );
        end

        full_adder fa (
                .a(a[P/2]),
                .b(b[P/2]),
                .cin(halfwayCarry),
                .sum(halfwaySum[P/2]),
                .cout(carry[P/2])
            );

        for (i = P/2+1; i < P; i++) begin : ADDER_GEN_MSB
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i-1]),
                .sum(halfwaySum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

endmodule

module half_adder (
    input logic a,
    input logic b,
    output logic sum,
    output logic carry
);
    assign {carry, sum} = a + b;
endmodule

module full_adder (
    input logic a,
    input logic b,
    input logic cin,
    output logic sum,
    output logic cout
);
    assign {cout, sum} = a + b + cin;
endmodule