// tree adder accepting only powers of 2 for amount of inputs
module binary_tree_adder #(
    parameter int INPUTS_AMOUNT,
    parameter int P
) (
    input wire signed [P-1:0] inputs [INPUTS_AMOUNT],
    output wire signed [31:0] out
);

    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");

    localparam int LayerAmount = $clog2(INPUTS_AMOUNT);
    logic signed [P+LayerAmount-1:0] temp_output ;
    generate
        genvar layer;
        for(layer = 0; layer < LayerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
            localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
            logic signed [P+layer:0] connectingWires [NextWidth];
            if(layer == LayerAmount-1) begin : gen_last_layer
                assign temp_output = connectingWires[0];
            end
            if(layer == 0) begin : gen_first_layer
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P)
                ) binary_tree_adder_layer (
                    .inputs(inputs),
                    .outputs(connectingWires)
                );
            end else begin : gen_mid_layers
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

    assign out = {
        {(32-P-LayerAmount+1){temp_output[P+LayerAmount-1]}},
        temp_output[P+LayerAmount-1:0] };

endmodule


