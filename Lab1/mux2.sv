//mux2 mux2(.in1(),.in2(),.sel(),.out());

module mux2 (
    input  [31:0] in1,
    input  [31:0] in2,
    input         sel,
    output logic [31:0] out
);

always_comb begin
    unique if (sel==1'b0) begin
        out=in1;
    end else begin
        out=in2;
    end
end

endmodule