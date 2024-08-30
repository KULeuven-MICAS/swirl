// tree adder accepting only powers of 2 for amount of inputs
module binary_tree_adder #(
    parameter int INPUTS_AMOUNT,
    parameter int P,
    parameter int MODE
) (
    input wire [P-1:0] inputs [INPUTS_AMOUNT],
    input wire signedAddition,
    output wire [31:0] out_32bit,
    output wire [P+$clog2(INPUTS_AMOUNT)-1:0] out

);

    if (INPUTS_AMOUNT - 1 & INPUTS_AMOUNT) $fatal("ERROR: Binary adder input not power of 2");

    localparam int LayerAmount = $clog2(INPUTS_AMOUNT);
    logic signed [P+LayerAmount-1:0] temp_output ;
    generate
        genvar layer;
        for(layer = 0; layer < LayerAmount; layer = layer + 1) begin: gen_layer
            localparam int CurrentWidth = INPUTS_AMOUNT >> layer;
            localparam int NextWidth = INPUTS_AMOUNT >> (layer+1);
            logic [P+layer:0] connectingWires [NextWidth];
            if(layer == LayerAmount-1) begin : gen_last_layer
                assign temp_output = connectingWires[0];
            end
            if(layer == 0) begin : gen_first_layer
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P),
                .MODE(MODE)
                ) binary_tree_adder_layer (
                    .inputs(inputs),
                    .outputs(connectingWires),
                    .signedAddition(signedAddition)
                );
            end else begin : gen_mid_layers
                binary_tree_adder_layer #(
                .INPUTS_AMOUNT(INPUTS_AMOUNT>>layer),
                .P(P+layer),
                .MODE(MODE)
                ) binary_tree_adder_layer (
                    .inputs(gen_layer[layer-1].connectingWires),
                    .outputs(connectingWires),
                    .signedAddition(signedAddition)
                );
            end
        end
    endgenerate

    if (MODE==0) begin
        assign out_32bit = {
        {(32-P-LayerAmount+1){temp_output[P+LayerAmount-1]}},
        temp_output[P+LayerAmount-1:0] };
    end else if (MODE==1) begin
        assign out = temp_output[P+LayerAmount-1:0];
    end


endmodule


