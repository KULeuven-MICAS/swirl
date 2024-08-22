module config_shiftadder_4bit # (
    parameter bit configurable = 0,
    parameter bit zeroExtend = 0,
    parameter bit invertLast = 0,
    parameter int lengthOutput = 8
    ) (
    input logic signed [3:0] multiplier,
    input logic signed [3:0] multiplicand,
    input bit halvedPrecision = 0,
    output logic signed [lengthOutput-1:0] product
);
    
    logic [lengthOutput-1:0] extendTerm1;
    logic [lengthOutput-1:0] extendTerm2;
    logic [lengthOutput-1:0] extendTerm3;
    logic [lengthOutput-1:0] extendTerm4;

    logic signExtend;
    logic [lengthOutput-1:0] multiplicandInv;

    always_comb begin
    if (configurable) begin

        if (zeroExtend) begin
            signExtend = halvedPrecision ? multiplicand[3] : 0;
        end else begin
            signExtend = multiplicand[3];
        end
        extendTerm1 = multiplier[0] ? {{4{signExtend}}, multiplicand} :  0;
        extendTerm2 = multiplier[1] ? {{3{signExtend}}, multiplicand, 1'b0} : 0;
        extendTerm3 = multiplier[2] ? {{2{signExtend}}, multiplicand, 2'b0} : 0;

        multiplicandInv = ~multiplicand;

        if(halvedPrecision) begin
            extendTerm4 = multiplier[3] ? (multiplicandInv + 1) << 3 : 0;
        end else begin
            if (invertLast) begin
                extendTerm4 = multiplier[3] ? ((multiplicandInv) << 3) : 0;
            end else if (zeroExtend) begin
                extendTerm4 = multiplier[3] ? {1'b0, multiplicand, 3'b0} : 0;
            end else begin
                extendTerm4 = multiplier[3] ? {signExtend, multiplicand, 3'b0} : 0;
            end
            
        end
    end else begin
        automatic bit signExtend;
        if (zeroExtend) begin
            signExtend = 0;
        end else begin
            signExtend = multiplicand[3];
        end
        if (lengthOutput != 12) begin
        extendTerm1 = multiplier[0] ? {{4{signExtend}}, multiplicand} :  0;
        extendTerm2 = multiplier[1] ? {{3{signExtend}}, multiplicand, 1'b0} : 0;
        extendTerm3 = multiplier[2] ? {{2{signExtend}}, multiplicand, 2'b0} : 0;
        extendTerm4 = multiplier[3] ? {-multiplicand, 3'b0} << 3 :  0;
        end else begin
        extendTerm1 = multiplier[0] ? {{8{signExtend}}, multiplicand} :  0;
        extendTerm2 = multiplier[1] ? {{7{signExtend}}, multiplicand, 1'b0} : 0;
        extendTerm3 = multiplier[2] ? {{6{signExtend}}, multiplicand, 2'b0} : 0;
        extendTerm4 = multiplier[3] ? {{5{signExtend}}, multiplicand, 3'b0} : 0;
        end

    end
    end
    
    assign product = extendTerm1 + extendTerm2 + extendTerm3 + extendTerm4;
endmodule