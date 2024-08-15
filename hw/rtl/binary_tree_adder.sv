// tree adder accepting only powers of 2 for amount of inputs
module binary_tree_adder #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input wire signed [P-1:0] inputs [INPUTS_AMOUNT],
    output wire signed [31:0] out
);

    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");

    localparam layerAmount = $clog2(INPUTS_AMOUNT);
    logic signed [P+layerAmount-1:0] temp_output ;
    generate
        genvar layer;
        for(layer = 0; layer < layerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
            localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
            logic signed [P+layer:0] connectingWires [NextWidth];
            if(layer == layerAmount-1) begin
                assign temp_output = connectingWires[0];
            end
            if(layer == 0) begin 
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P)
                ) binary_tree_adder_layer (
                    .inputs(inputs),
                    .outputs(connectingWires)
                );
            end else begin
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P+layer)
                ) binary_tree_adder_layer (
                    .inputs(gen_layer[layer-1].connectingWires),
                    .outputs(connectingWires)
                );
            end

            
        end
    endgenerate

    assign out = { {(32-P-layerAmount+1){temp_output[P+layerAmount-1]}}, temp_output[P+layerAmount-1:0] };

endmodule

module binary_tree_adder_layer #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input logic signed [P-1:0] inputs [INPUTS_AMOUNT],
    output logic signed [P:0] outputs [INPUTS_AMOUNT/2] // #outputs = #inputs halved
);
    localparam int OutputsAmount = INPUTS_AMOUNT/2;
    generate
        genvar adderIndex;
        for (adderIndex = 0; adderIndex < OutputsAmount; adderIndex = adderIndex + 1) begin: gen_adder
            assign outputs[adderIndex] = inputs[2*adderIndex] + inputs[2*adderIndex+1];
        end
    endgenerate
endmodule
