module binary_tree_adder_layer_unsigned #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input logic [P-1:0] inputs [INPUTS_AMOUNT],
    output logic [P:0] outputs [INPUTS_AMOUNT/2], // #outputs = #inputs halved
    input wire signedAddition
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;
    generate
        genvar i;
        for (i = 0; i < OutputsAmount; i = i + 1) begin: gen_adder
            logic [P:0] input_extend_1;
            logic [P:0] input_extend_2;

            assign input_extend_1 = signedAddition ?
            {inputs[2*i][P-1], inputs[2*i]} :
            {1'b0, inputs[2*i]};

            assign input_extend_2 = signedAddition ?
            {inputs[2*i+1][P-1], inputs[2*i+1]} :
            {1'b0, inputs[2*i+1]};

            assign outputs[i] = input_extend_1 + input_extend_2;
        end
    endgenerate
endmodule
