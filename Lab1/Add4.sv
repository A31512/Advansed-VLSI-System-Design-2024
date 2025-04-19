// Add4 m1(.add4_in(),.add4_out());

module Add4 (
    input [31:0] add4_in,
    output [31:0] add4_out
);

assign add4_out = add4_in + 32'b100;

endmodule