module config_binary_tree_adder_layer #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input logic [P-1:0] inputs [INPUTS_AMOUNT],
    output logic [P+1:0] outputs [INPUTS_AMOUNT/2], // #outputs = #inputs halved
    input logic halvedPrecision
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;
    generate
        genvar i;
        for (i = 0; i < OutputsAmount; i = i + 1) begin : gen_adders
            config_adder #(
                .P(P)
                ) add (
                    .a(inputs[2*i]),
                    .b(inputs[2*i+1]),
                    .sum(outputs[i]),
                    .halvedPrecision(halvedPrecision)
                );
        end
    endgenerate
endmodule
