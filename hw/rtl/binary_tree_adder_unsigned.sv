// tree adder accepting only powers of 2 for amount of inputs
module binary_tree_adder_unsigned #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input wire [P-1:0] inputs [INPUTS_AMOUNT],
    output wire [P+$clog2(INPUTS_AMOUNT)-1:0] out,
    input wire signedAddition
);

    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");

    localparam layerAmount = $clog2(INPUTS_AMOUNT);
    logic unsigned [P+layerAmount-1:0] temp_output ;
    generate
        if (INPUTS_AMOUNT == 1) begin
            assign temp_output = inputs[0];
        end else begin
            genvar layer;
            for(layer = 0; layer < layerAmount; layer = layer + 1) begin: gen_layer
                localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
                localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
                logic [P+layer:0] connectingWires [NextWidth];
                if(layer == layerAmount-1) begin
                    assign temp_output = connectingWires[0];
                end
                if(layer == 0) begin 
                    binary_tree_adder_layer_unsigned #(
                    .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                    .P(P)
                    ) binary_tree_adder_layer (
                        .inputs(inputs),
                        .outputs(connectingWires),
                        .signedAddition(signedAddition)
                    );
                end else begin
                    binary_tree_adder_layer_unsigned #(
                    .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                    .P(P+layer)
                    ) binary_tree_adder_layer (
                        .inputs(gen_layer[layer-1].connectingWires),
                        .outputs(connectingWires),
                        .signedAddition(signedAddition)
                    );
                end
            end

            
        end
    endgenerate

    assign out = temp_output[P+layerAmount-1:0];

endmodule

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
        genvar adderIndex;
        for (adderIndex = 0; adderIndex < OutputsAmount; adderIndex = adderIndex + 1) begin: gen_adder
            logic [P:0] input_extend_1; 
            logic [P:0] input_extend_2; 
            assign input_extend_1 = signedAddition ? {inputs[2*adderIndex][P-1], inputs[2*adderIndex]} : {1'b0, inputs[2*adderIndex]};
            assign input_extend_2 = signedAddition ? {inputs[2*adderIndex+1][P-1], inputs[2*adderIndex+1]} : {1'b0, inputs[2*adderIndex+1]};
            assign outputs[adderIndex] = input_extend_1 + input_extend_2;
        end
    endgenerate
endmodule
