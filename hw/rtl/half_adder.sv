// Module description:
// Simple half adder module

module half_adder (
    input logic a,
    input logic b,
    output logic sum,
    output logic carry
);
    assign {carry, sum} = a + b;
endmodule
