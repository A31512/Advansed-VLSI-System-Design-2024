module ID_EXE (
    input clk,
    input rst,
    input  bj_flush,
    input  load_use_nop,


input        lud_LUI_fwrd_id_1_i,
input        lud_LUI_fwrd_id_2_i,
input  [2:0] funct3_id_i,
input  [6:0] opcode_id_i,
input  [4:0] instrction_in_id_i,
input [31:0] pc_in_id_i,
input [31:0] data1_in_id_i,
input [31:0] data2_in_id_i,
input [31:0] immediate_in_id_i,

input [ 1:0] data1_ALU_sel_id_i,
input [ 1:0] data2_ALU_sel_id_i,
input [ 1:0] data1_BJ_sel_id_i,
input [ 1:0] data2_BJ_sel_id_i,
input [ 1:0] data3_MID_sel_id_i,
input [ 4:0] ALU_op_id_i,
input [ 2:0] bj_sel_id_i,

input        data_MEM_sel_id_i,
input        read_write_id_i,
input [ 1:0] wb_sel_id_i,
input [ 2:0] wb_sel_csr_id_i,
input        reg_write_en_id_i,

output logic        lud_LUI_fwrd_ID_1,
output logic        lud_LUI_fwrd_ID_2,
// output logic        give_Data_mem_ceb_ID,
output logic [ 2:0] funct3_ID,
output logic [ 6:0] opcode_ID,
output logic [ 4:0] instrction_in_ID,
output logic [31:0] pc_in_ID,
output logic [31:0] data1_in_ID,
output logic [31:0] data2_in_ID,
output logic [31:0] immediate_in_ID,

output logic [ 1:0] data1_ALU_sel_ID,
output logic [ 1:0] data2_ALU_sel_ID,
output logic [ 1:0] data1_BJ_sel_ID,
output logic [ 1:0] data2_BJ_sel_ID,
output logic [ 1:0] data3_MID_sel_ID,
output logic [ 4:0] ALU_op_ID,
output logic [ 2:0] bj_sel_ID,

output logic        data_MEM_sel_ID,
output logic        read_write_ID,
output logic [ 1:0] wb_sel_ID,
output logic [ 2:0] wb_sel_csr_ID,
output logic        reg_write_en_ID
);


always_ff @(posedge clk) begin
    if (rst) begin
        lud_LUI_fwrd_ID_1            <=1'b0;
        lud_LUI_fwrd_ID_2            <=1'b0;
        // give_Data_mem_ceb_ID       <=1'b0;
        funct3_ID       <=3'b0;
        opcode_ID       <=7'b0;
        instrction_in_ID<=5'b0;
        pc_in_ID        <=32'b0;
        data1_in_ID     <=32'b0;
        data2_in_ID     <=32'b0;
        immediate_in_ID <=32'b0;   
    end else if ((bj_flush)||(load_use_nop)) begin
        lud_LUI_fwrd_ID_1            <=1'b0;
        lud_LUI_fwrd_ID_2            <=1'b0;
        // give_Data_mem_ceb_ID       <=1'b1;
        funct3_ID       <=3'b0;
        opcode_ID       <=7'b0;
        instrction_in_ID<=5'b0;
        pc_in_ID        <=32'b0;
        data1_in_ID     <=32'b0;
        data2_in_ID     <=32'b0;
        immediate_in_ID <=32'b0;
    end else begin
        lud_LUI_fwrd_ID_1            <=lud_LUI_fwrd_id_1_i;
        lud_LUI_fwrd_ID_2            <=lud_LUI_fwrd_id_2_i;
        // give_Data_mem_ceb_ID       <=1'b0;
        funct3_ID       <=funct3_id_i;
        opcode_ID       <=opcode_id_i;
        instrction_in_ID<=instrction_in_id_i;
        pc_in_ID        <=pc_in_id_i;
        data1_in_ID     <=data1_in_id_i;
        data2_in_ID     <=data2_in_id_i;
        immediate_in_ID <=immediate_in_id_i;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        data1_ALU_sel_ID<=2'b0;
        data2_ALU_sel_ID<=2'b0;
        data1_BJ_sel_ID <=2'b0;
        data2_BJ_sel_ID <=2'b0;
        data3_MID_sel_ID<=2'b0;
        ALU_op_ID       <=5'b0;
        bj_sel_ID       <=3'b0;
    end else if ((bj_flush)||(load_use_nop)) begin
        data1_ALU_sel_ID<=2'b0;
        data2_ALU_sel_ID<=2'b0;
        data1_BJ_sel_ID <=2'b0;
        data2_BJ_sel_ID <=2'b0;
        data3_MID_sel_ID<=2'b0;
        ALU_op_ID       <=5'b0;
        bj_sel_ID       <=3'b0;
    end else begin
        data1_ALU_sel_ID<=data1_ALU_sel_id_i;
        data2_ALU_sel_ID<=data2_ALU_sel_id_i;
        data1_BJ_sel_ID <=data1_BJ_sel_id_i;
        data2_BJ_sel_ID <=data2_BJ_sel_id_i;
        data3_MID_sel_ID<=data3_MID_sel_id_i;
        ALU_op_ID       <=ALU_op_id_i;
        bj_sel_ID       <=bj_sel_id_i;
    end
end
always_ff @(posedge clk) begin
    if (rst) begin
        data_MEM_sel_ID <=1'b0;
        read_write_ID   <=1'b0;
        wb_sel_ID       <=2'b0;
        wb_sel_csr_ID   <=3'b0;
        reg_write_en_ID <=1'b0;
    end else if ((bj_flush)||(load_use_nop)) begin
        data_MEM_sel_ID <=1'b0;
        read_write_ID   <=1'b1;
        wb_sel_ID       <=2'b0;
        wb_sel_csr_ID   <=3'b0;
        reg_write_en_ID <=1'b0;
    end else begin
        data_MEM_sel_ID <=data_MEM_sel_id_i;
        read_write_ID   <=read_write_id_i;
        wb_sel_ID       <=wb_sel_id_i;
        wb_sel_csr_ID   <=wb_sel_csr_id_i;
        reg_write_en_ID <=reg_write_en_id_i;
    end
end

endmodule