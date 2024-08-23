module binary_tree_adder_layer #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input logic signed [P-1:0] inputs [INPUTS_AMOUNT],
    output logic signed [P:0] outputs [INPUTS_AMOUNT/2] // #outputs = #inputs halved
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;
    generate
        genvar i;
        for (i = 0; i < OutputsAmount; i = i + 1) begin: gen_adder
            assign outputs[i] = inputs[2*i] + inputs[2*i+1];
        end
    endgenerate
endmodule
