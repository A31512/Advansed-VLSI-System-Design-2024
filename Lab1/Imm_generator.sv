module Imm_generator (
    input [24:0] imm_in,
    input [ 2:0] imm_sel,
    output logic [31:0] imm_out);

always_comb begin
    case (imm_sel)
        3'b000: imm_out = {imm_in[24:5]    ,12'b0}; //U_type
        3'b001: imm_out = {{12{imm_in[24]}},imm_in[12:5],imm_in[13],imm_in[23:14],1'b0};//J_type_小變1'b0
        3'b010: imm_out = {{20{imm_in[24]}},imm_in[0],imm_in[23:18],imm_in[4:1],1'b0};//B_type_小變1'b0
        3'b011: imm_out = {{21{imm_in[24]}},imm_in[23:18],imm_in[4:0]};//S_type_左21    + FSW
        3'b100: imm_out = {{20{imm_in[24]}},imm_in[24:13]};//I_immediate            + FLW
        3'b101: imm_out = {{27{imm_in[24]}},imm_in[17:13]};//I_shift_immediate
        default:imm_out = {{20{imm_in[24]}}  ,imm_in[24:13]};    //I_unsigned_immediate
    endcase
end


endmodule