module MEM_WB (
    input clk,
    input rst,

input  [6:0] opcode_mem_i,
input  [2:0] funct3_mem_i,
input  [4:0] instrction_in_mem_i,
input [31:0] pc_in_mem_i,
input [31:0] alu_in_mem_i,
input [31:0] immediate_in_mem_i,
// input [31:0] Data_SRAM_value,              Data_SRAM繞過去


input [ 1:0] wb_sel_mem_i,
input [ 2:0] wb_sel_csr_mem_i,
input        reg_write_en_mem_i,


output logic [ 6:0] opcode_MEM,
output logic [ 2:0] funct3_MEM,
output logic [ 4:0] instrction_in_MEM,
output logic [31:0] pc_in_MEM,
output logic [31:0] alu_in_MEM,
output logic [31:0] immediate_in_MEM,
// output logic [31:0] Data_SRAM_value_in_MEM,      Data_SRAM繞過去


output logic [ 1:0] wb_sel_MEM,
output logic [ 2:0] wb_sel_csr_MEM,
output logic        reg_write_en_MEM
);


always_ff @(posedge clk) begin
    if (rst) begin
        opcode_MEM       <=7'b0;
        funct3_MEM       <=3'b0;
        instrction_in_MEM<=5'b0;
        pc_in_MEM        <=32'b0;
        alu_in_MEM       <=32'b0;
        immediate_in_MEM <=32'b0;   
        // Data_SRAM_value_in_MEM      <=32'b0;   
    end else begin
        opcode_MEM       <=opcode_mem_i;
        funct3_MEM       <=funct3_mem_i;
        instrction_in_MEM<=instrction_in_mem_i;
        pc_in_MEM        <=pc_in_mem_i;
        alu_in_MEM       <=alu_in_mem_i;
        immediate_in_MEM <=immediate_in_mem_i;
        // Data_SRAM_value_in_MEM      <=Data_SRAM_value;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        wb_sel_MEM       <=2'b0;
        wb_sel_csr_MEM   <=3'b0;
        reg_write_en_MEM <=1'b0;
    end else begin
        wb_sel_MEM       <=wb_sel_mem_i;
        wb_sel_csr_MEM   <=wb_sel_csr_mem_i;
        reg_write_en_MEM <=reg_write_en_mem_i;
    end
end

endmodule