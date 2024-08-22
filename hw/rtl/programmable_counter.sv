module programmable_counter #(
    parameter int unsigned WIDTH = 4, // max bitwidth of counter
    parameter UPDOWN = 0 // make counter revert at top
    ) (
    input clk_i,
    input rst_ni,
    input clear_i,
    input en_i,
    input load_i,
    input down_i,
    input logic [WIDTH-1:0] countSet, 
    input logic [WIDTH-1:0] d_i,
    output logic [WIDTH-1:0] q_o,
    output logic last_o
    
    );

    logic [WIDTH-1:0] counter_q, counter_d;
    logic [WIDTH-1:0] cnt_next;
    reg hold;

    assign q_o = counter_q;

    assign last_o = down_i ? counter_q == 0 : counter_q == countSet;

    always_comb begin
        counter_d = counter_q;

        if (clear_i) begin
            counter_d = '0;
            hold <= 0;
        end else if (load_i) begin
            counter_d = d_i;
        end else if (en_i) begin
                if (down_i) begin
                    counter_d = counter_q - 1; 
                end else begin
                    if (UPDOWN) begin
                        if (countSet == 0) begin
                            if (hold) begin
                                counter_d = counter_q - 1;
                            end else begin
                                hold <= 1;
                            end
                        end else begin
                        if (counter_q == countSet) begin
                            counter_d = counter_q - 1;
                        end else begin
                            counter_d = counter_q + 1;
                        end
                        end
                    end else begin
                        if (counter_q == countSet) begin
                            counter_d = 0;
                        end else begin
                            counter_d = counter_q + 1;
                        end
                    end
                end

        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
           counter_q <= '0;
        end else begin
           counter_q <= counter_d;
        end
    end

endmodule