module MUL (
    input   [31:0] mul_in1,
    input   [31:0] mul_in2,
    input   [ 4:0] mul_sel,
    output logic [31:0] mul_out
);


logic [65:0] mul_mid64;

always_comb begin
    case (mul_sel)
        `MUL  :    mul_out = mul_mid64[31:0];
        // `MULH :    mul_out = mul_mid64[63:32];
        // `MULHS:   mul_out = mul_mid64[63:32];
        default:   mul_out = mul_mid64[63:32];//MULHSU
    endcase
end

always_comb begin 
    case (mul_sel)
        `MUL    :   mul_mid64 = $signed({34'b0,mul_in1})             * $signed({34'b0,mul_in2});          
        `MULH   :   mul_mid64 = $signed({{34{mul_in1[31]}},mul_in1}) * $signed({{34{mul_in2[31]}},mul_in2}); 
        `MULHU  :   mul_mid64 = $signed({34'b0,mul_in1})             * $signed({34'b0,mul_in2});          
        default:    mul_mid64 = $signed({{34{mul_in1[31]}},mul_in1}) * $signed({34'b0,mul_in2});//MULHSU
    endcase
end


endmodule






        