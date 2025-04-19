module Control (
    input  [6:0] ctrl_opcode,
    input  [2:0] ctrl_funct3,
    input  [6:0] ctrl_funct7,
    input  [4:0] ctrl_rs1,//INST[19:15]
    input  [11:0] ctrl_imm_csr,
    output logic [2:0] ctrl_imm_sel,
    output logic [1:0] ctrl_alu_op1_sel,//前面多補0，多1bit
    output logic [1:0] ctrl_alu_op2_sel,//前面多補0，多1bit
    output logic [4:0] ctrl_alu_sel,
    output logic [2:0] ctrl_bj_sel,
    output logic       ctrl_DM_read_write_en,
    output logic [1:0] ctrl_wb_sel,
    output logic [2:0] ctrl_wb_sel_csr,
    output logic       ctrl_reg_write_en
    );



////////////////////////////////////////////////////////
//////////
/////////       ctrl_alu_sel      //這邊可以改成直接輸出bit(還沒改)
/////////
////////////////////////////////////////////////////////
logic [1:0]func3_7_connect;
assign func3_7_connect = ({ctrl_funct7[5],ctrl_funct7[0]});

always_comb begin
    if (ctrl_opcode==`R_TYPE) begin
        case (ctrl_funct3)
        3'b000: case (func3_7_connect)
                2'b10:  ctrl_alu_sel = `SUB;
                2'b01:  ctrl_alu_sel = `MUL;
                default:ctrl_alu_sel = `ADD;
                endcase
        3'b001: case (func3_7_connect)
                2'b00:  ctrl_alu_sel = `SLL;
                default:ctrl_alu_sel = `MULH;
                endcase
        3'b010: case (func3_7_connect)
                2'b00:  ctrl_alu_sel = `SLT;
                default:ctrl_alu_sel = `MULHSU;
                endcase
        3'b011: case (func3_7_connect)
                2'b00:  ctrl_alu_sel = `SLTU;
                default:ctrl_alu_sel = `MULHU;
                endcase
        3'b100: ctrl_alu_sel = `XOR;
        3'b101: case (func3_7_connect)
                2'b00:  ctrl_alu_sel = `SRL;
                default:ctrl_alu_sel = `SRA;
                endcase
        3'b110: ctrl_alu_sel = `OR;
        default:ctrl_alu_sel = `AND;//3'b111
        endcase
    end else if (ctrl_opcode==`I_TYPE) begin
        case (ctrl_funct3)
        3'b000: ctrl_alu_sel = `ADD;
        3'b001: ctrl_alu_sel = `SLL;
        3'b010: ctrl_alu_sel = `SLT;
        3'b011: ctrl_alu_sel = `SLTU;
        3'b100: ctrl_alu_sel = `XOR;
        3'b101: case (ctrl_funct7[5])
                1'b0:  ctrl_alu_sel = `SRL;
                default:ctrl_alu_sel = `SRA;
                endcase
        3'b110: ctrl_alu_sel = `OR;
        default:ctrl_alu_sel = `AND;//3'b111
        endcase
    end else if (ctrl_opcode==`F_TYPE) begin
        if (ctrl_funct7[2]==1'b1) begin
            ctrl_alu_sel = `FSUB;
        end else begin
            ctrl_alu_sel = `FADD;
        end
    end else begin
        ctrl_alu_sel = `ADD;
    end
end

////////////////////////////////////////////////////////
//////////
/////////       ctrl_imm_sel     
/////////
////////////////////////////////////////////////////////
always_comb begin
    if ((ctrl_opcode==`AUPIC)||(ctrl_opcode==`LUI)) begin
        ctrl_imm_sel = 3'b000;         //U_type
    end else if (ctrl_opcode==`JAL) begin
        ctrl_imm_sel = 3'b001;         //J_type
    end else if (ctrl_opcode==`B_TYPE) begin
        ctrl_imm_sel = 3'b010;         //B_TYPE
    end else if ((ctrl_opcode==`STORE)||(ctrl_opcode==`FSW)) begin
        ctrl_imm_sel = 3'b011;         //S_type + FSW
    end else begin
        if (ctrl_funct3==3'b011) begin
            ctrl_imm_sel = 3'b111;     //I_unsigned_immediate
        end else if ((ctrl_funct3==3'b001)||(ctrl_funct3==3'b101)) begin
            ctrl_imm_sel = 3'b101;     //I_shift_immediate
        end else begin
            ctrl_imm_sel = 3'b100;     //I_immediate + FLW
        end
    end
end

////////////////////////////////////////////////////////
//////////
/////////       ctrl_bj_sel     
/////////
////////////////////////////////////////////////////////
always_comb begin
    if ((ctrl_opcode==`JALR)||(ctrl_opcode==`JAL)) begin
        ctrl_bj_sel = 3'b011;
    end else if (ctrl_opcode==`B_TYPE) begin
        ctrl_bj_sel = ctrl_funct3;      
    end else begin
        ctrl_bj_sel = 3'b010;//NO
    end
end

////////////////////////////////////////////////////////
//////////
/////////       ctrl_DM_read_write_en     //read:high write:low
/////////
////////////////////////////////////////////////////////
always_comb begin
    if ((ctrl_opcode==`STORE)||(ctrl_opcode==`FSW)) begin
        ctrl_DM_read_write_en = 1'b0;
    end else begin
        ctrl_DM_read_write_en = 1'b1;
    end
end

////////////////////////////////////////////////////////
//////////
/////////       ctrl_wb_sel
/////////
////////////////////////////////////////////////////////
always_comb begin
    if ((ctrl_opcode==`AUPIC)||(ctrl_opcode==`I_TYPE)||(ctrl_opcode==`R_TYPE)||(ctrl_opcode==`F_TYPE)) begin
        ctrl_wb_sel = 2'b01;
    end else if ((ctrl_opcode==`LOAD)||(ctrl_opcode==`FLW)) begin
        ctrl_wb_sel = 2'b11;
    end else if (ctrl_opcode==`LUI) begin
        ctrl_wb_sel = 2'b10;
    end else begin  //JAL & Jalr
        ctrl_wb_sel = 2'b00;
    end
end


////////////////////////////////////////////////////////
//////////
/////////       ctrl_wb_sel_csr
/////////
////////////////////////////////////////////////////////
always_comb begin
    if ((ctrl_opcode==`CSR_TYPE)&&(ctrl_funct3==3'b010)&&(ctrl_rs1==5'b0)) begin
        unique if ((ctrl_imm_csr[7]==1'b1)&&(ctrl_imm_csr[1]==1'b1)) begin
            ctrl_wb_sel_csr = 3'd0;
        end else if ((ctrl_imm_csr[7]==1'b0)&&(ctrl_imm_csr[1]==1'b1)) begin
            ctrl_wb_sel_csr = 3'd1;
        end else if ((ctrl_imm_csr[7]==1'b1)&&(ctrl_imm_csr[1]==1'b0)) begin
            ctrl_wb_sel_csr = 3'd2;
        end else begin
            ctrl_wb_sel_csr = 3'd3;
        end
    end else begin
        ctrl_wb_sel_csr = 3'd4;
    end
end



////////////////////////////////////////////////////////
/////////
/////////       ctrl_reg_write_en
/////////
////////////////////////////////////////////////////////
assign ctrl_reg_write_en = (|{ctrl_opcode==`R_TYPE,
                              ctrl_opcode==`I_TYPE,
                              ctrl_opcode==`JALR,
                              ctrl_opcode==`LOAD,
                              ctrl_opcode==`AUPIC,
                              ctrl_opcode==`LUI,
                              ctrl_opcode==`JAL,
                              ctrl_opcode==`F_TYPE,
                              ctrl_opcode==`FLW,
                              ctrl_opcode==`CSR_TYPE
                              })?1'b1:1'b0;



////////////////////////////////////////////////////////
//////////
/////////       ctrl_alu_op1_sel,ctrl_alu_op2_sel
/////////
////////////////////////////////////////////////////////
assign ctrl_alu_op1_sel = ((ctrl_opcode==`AUPIC)||(ctrl_opcode==`JAL)||(ctrl_opcode==`B_TYPE))?2'b01:2'b00;
assign ctrl_alu_op2_sel = ((ctrl_opcode==`R_TYPE)||(ctrl_opcode==`F_TYPE))?2'b00:2'b01;



endmodule