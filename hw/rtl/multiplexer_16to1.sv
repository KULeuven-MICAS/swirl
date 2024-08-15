module multiplexer_2to1 #(
    parameter M
) (
    input [2*M-1:0] in,
    input sel,
    output [M-1:0] out
);
    assign out = sel ? in[2*M-1:M] : in[M-1:0];
endmodule

module multiplexer_4to1 #(
    parameter M
) (
    input [4*M-1:0] in,
    input [1:0] sel,
    output [M-1:0] out
);

    logic [M-1:0] out1, out2;
    multiplexer_2to1 #(
        .M(M)
    ) mux1 (
        .in(in[2*M-1:0]),
        .sel(sel[0]),
        .out(out1)
    );

    multiplexer_2to1 #(
        .M(M)
    ) mux2 (
        .in(in[4*M-1:2*M]),
        .sel(sel[0]),
        .out(out2)
    );

    multiplexer_2to1 #(
        .M(M)
    ) mux3 (
        .in({out2, out1}),
        .sel(sel[1]),
        .out(out)
    );

endmodule

module multiplexer_8to1 #(
    parameter M
) (
    input [8*M-1:0] in,
    input [2:0] sel,
    output [M-1:0] out
);

    logic [M-1:0] out1, out2;

    multiplexer_4to1 #(
        .M(M)
    ) mux1 (
        .in(in[4*M-1:0]),
        .sel(sel[1:0]),
        .out(out1)
    );

    multiplexer_4to1 #(
        .M(M)
    ) mux2 (
        .in(in[8*M-1:4*M]),
        .sel(sel[1:0]),
        .out(out2)
    );

    multiplexer_2to1 #(
        .M(M)
    ) mux3 (
        .in({out2, out1}),
        .sel(sel[2]),
        .out(out)
    );
endmodule

module multiplexer_16to1 #(
    parameter M
) (
    input [16*M-1:0] in,
    input [3:0] sel,
    output [M-1:0] out
);

    logic [M-1:0] out1, out2, out3, out4;

    multiplexer_4to1 #(
        .M(M)
    ) mux1 (
        .in(in[4*M-1:0]),
        .sel(sel[1:0]),
        .out(out1)
    );

    multiplexer_4to1 #(
        .M(M)
    ) mux2 (
        .in(in[8*M-1:4*M]),
        .sel(sel[1:0]),
        .out(out2)
    );

    multiplexer_4to1 #(
        .M(M)
    ) mux3 (
        .in(in[12*M-1:8*M]),
        .sel(sel[1:0]),
        .out(out3)
    );

    multiplexer_4to1 #(
        .M(M)
    ) mux4 (
        .in(in[16*M-1:12*M]),
        .sel(sel[1:0]),
        .out(out4)
    );

    multiplexer_4to1 #(
        .M(M)
    ) mux5 (
        .in({out1, out2, out3, out4}),
        .sel(sel[3:2]),
        .out(out)
    );
endmodule