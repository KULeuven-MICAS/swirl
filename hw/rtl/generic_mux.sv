module generic_mux #(parameter int WIDTH = 1,
                     parameter int NUMBER = 2,
                     localparam int SelectW = $clog2(NUMBER))
 (input logic [SelectW-1:0] sel,
  input logic [WIDTH-1:0] mux_in [NUMBER],
  output logic [WIDTH-1:0] out);
  assign out = mux_in[sel];
endmodule
