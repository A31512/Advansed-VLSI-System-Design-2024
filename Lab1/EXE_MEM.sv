module EXE_MEM (
    input clk,
    input rst,

// input        give_Data_mem_ceb_exe,
// input        lud_LUI_fwrd_exe,
input  [2:0] funct3_exe_i,
input  [6:0] opcode_exe_i,
input  [4:0] instrction_in_exe_i,
input [31:0] pc_in_exe_i,
input [31:0] alu_in_exe_i,
input [31:0] immediate_in_exe_i,
input [31:0] data_in_exe_i,

input        data_MEM_sel_exe_i,
input        read_write_exe_i,
input [ 1:0] wb_sel_exe_i,
input [ 2:0] wb_sel_csr_exe_i,
input        reg_write_en_exe_i,

// output logic        give_Data_mem_ceb_EXE,
// output logic        lud_LUI_fwrd_EXE,
output logic [ 2:0] funct3_EXE,
output logic [ 6:0] opcode_EXE,
output logic [ 4:0] instrction_in_EXE,
output logic [31:0] pc_in_EXE,
output logic [31:0] alu_in_EXE,
output logic [31:0] immediate_in_EXE,
output logic [31:0] data_in_EXE,

output logic        data_MEM_sel_EXE,
output logic        read_write_EXE,
output logic [ 1:0] wb_sel_EXE,
output logic [ 2:0] wb_sel_csr_EXE,
output logic        reg_write_en_EXE
);


always_ff @(posedge clk) begin
    if (rst) begin
        // give_Data_mem_ceb_EXE       <=1'b0;
        // lud_LUI_fwrd_EXE <=1'b0;
        funct3_EXE       <=3'b0;
        opcode_EXE       <=7'b0;
        instrction_in_EXE<=5'b0;
        pc_in_EXE        <=32'b0;
        alu_in_EXE       <=32'b0;
        immediate_in_EXE <=32'b0;   
        data_in_EXE      <=32'b0;   
    end else begin
        // give_Data_mem_ceb_EXE         <=give_Data_mem_ceb_exe;
        // lud_LUI_fwrd_EXE <=lud_LUI_fwrd_exe;
        funct3_EXE       <=funct3_exe_i;
        opcode_EXE       <=opcode_exe_i;
        instrction_in_EXE<=instrction_in_exe_i;
        pc_in_EXE        <=pc_in_exe_i;
        alu_in_EXE       <=alu_in_exe_i;
        immediate_in_EXE <=immediate_in_exe_i;
        data_in_EXE      <=data_in_exe_i;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        data_MEM_sel_EXE <=1'b0;
        read_write_EXE   <=1'b0;
        wb_sel_EXE       <=2'b0;
        wb_sel_csr_EXE   <=3'b0;
        reg_write_en_EXE <=1'b0;
    end else begin
        data_MEM_sel_EXE <=data_MEM_sel_exe_i;
        read_write_EXE   <=read_write_exe_i;
        wb_sel_EXE       <=wb_sel_exe_i;
        wb_sel_csr_EXE   <=wb_sel_csr_exe_i;
        reg_write_en_EXE <=reg_write_en_exe_i;
    end
end

endmodule