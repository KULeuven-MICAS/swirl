module config_multiplier_2bit (
    input logic [1:0] multiplier,
    input logic [1:0] multiplicand,
    input logic halvedPrecision,
    output logic [3:0] product
);

logic [1:0] sumTerm1, sumTerm2;
logic [3:0] fullProduct;
logic [3:0] halvedProduct;

logic carry1, carry2;


logic rightProduct;
always_comb begin
    assign sumTerm1 = multiplier[0] & multiplicand;
    assign sumTerm2 = multiplier[1] & multiplicand;

    assign fullProduct = multiplier * multiplicand;
    assign halvedProduct = {1'b0, sumTerm2[1], 1'b0, sumTerm1[0]};

    assign product = halvedPrecision ? halvedProduct : fullProduct;

end
endmodule