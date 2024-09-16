// Module description:
// Simple full adder module

module full_adder (
    input logic a,
    input logic b,
    input logic cin,
    output logic sum,
    output logic cout
);
    assign {cout, sum} = a + b + cin;
endmodule
