module mux5 (
    input  [31:0] in1,
    input  [31:0] in2,
    input  [31:0] in3,
    input  [31:0] in4,
    input  [31:0] in5,
    input  [ 2:0] sel,
    output logic [31:0] out
);

always_comb begin
    unique if (sel==3'b0) begin
        out=in1;
    end else if (sel==3'b1) begin
        out=in2;
    end else if (sel==3'd2) begin
        out=in3;
    end else if (sel==3'd3) begin
        out=in4;
    end else begin
        out=in5;
    end
end

endmodule