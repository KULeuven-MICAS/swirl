module binary_tree_adder_layer #(
    parameter int INPUTS_AMOUNT,
    parameter int P,
    parameter int MODE
) (
    input logic [P-1:0] inputs [INPUTS_AMOUNT],
    output logic [P:0] outputs [INPUTS_AMOUNT/2], // #outputs = #inputs halved
    input logic signedAddition
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;

    if (MODE==0) begin : gen_signed_tree_layer
        genvar i;
        for (i = 0; i < OutputsAmount; i = i + 1) begin: gen_adder
            assign outputs[i] = signed'(inputs[2*i]) + signed'(inputs[2*i+1]);
        end
    end else if (MODE==1) begin : gen_unsiged_tree_layer
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
    end
endmodule
