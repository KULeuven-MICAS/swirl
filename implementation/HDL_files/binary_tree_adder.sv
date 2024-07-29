// tree adder accepting only powers of 2 for amount of inputs
module binary_tree_adder #(
    parameter int INPUTS_AMOUNT,
    parameter int OUTPUTS_AMOUNT,
    parameter int P
) (
    input logic signed [P-1:0] inputs [INPUTS_AMOUNT],
    output logic signed [P-1:0] outputs [OUTPUTS_AMOUNT]
);
    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");
    if (OUTPUTS_AMOUNT - 1 & OUTPUTS_AMOUNT) $fatal("ERROR: Binary adder output not power of 2");

    localparam layerAmount = $clog2(INPUTS_AMOUNT/OUTPUTS_AMOUNT);
    logic signed [P-1:0] connectingWires [layerAmount+1][INPUTS_AMOUNT];
    assign connectingWires[0][0:(INPUTS_AMOUNT-1)] = inputs;
    generate
        genvar layer;
        for(layer = 0; layer < layerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
            localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
            binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P)
            ) binary_tree_adder_layer (
                .inputs(connectingWires[layer][0:(CurrentWidth-1)]),
                .outputs(connectingWires[layer+1][0:(NextWidth-1)])
            );
        end
    endgenerate
    assign outputs = connectingWires[layerAmount][0:OUTPUTS_AMOUNT-1];

endmodule

module binary_tree_adder_layer #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input logic signed [P-1:0] inputs [INPUTS_AMOUNT],
    output logic signed [P-1:0] outputs [INPUTS_AMOUNT/2] // #outputs = #inputs halved
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;
    generate
        genvar adderIndex;
        for (adderIndex = 0; adderIndex < OutputsAmount; adderIndex = adderIndex + 1) begin
            bitwise_add #(
                .P(P)
                ) add (
                    .a(inputs[2*adderIndex]),
                    .b(inputs[2*adderIndex+1]),
                    .sum(outputs[adderIndex])
                );
        end
    endgenerate
endmodule
