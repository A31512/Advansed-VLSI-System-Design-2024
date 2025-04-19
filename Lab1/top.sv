
`include "cpu.sv"
`include "SRAM_wrapper.sv"



module top (
    input clk,
    input rst
    );


logic [31:0] Instruction_SRAM_receive_value;
logic [31:0] Data_SRAM_receive_value;
logic [31:0] Give_Instruct_mem_Addr;
logic        Give_read_write_EXE;
logic [31:0] Give_Data_mem_value;
logic [31:0] Give_Data_mem_addr;
logic        Give_instruction_mem_ceb;
// logic        Give_Data_mem_ceb;

SRAM_wrapper IM1(.CLK(clk),.RST(rst),.CEB(Give_instruction_mem_ceb),.WEB(1'b1),
                                .BWEB(32'b11111111_11111111_11111111_11111111),
                                .A(Give_Instruct_mem_Addr[15:2]),.DI(32'b0),.DO(Instruction_SRAM_receive_value));

cpu cpu(.clk(clk),.rst(rst),
         .Instruction_SRAM_receive_value(Instruction_SRAM_receive_value),
         .Data_SRAM_receive_value(Data_SRAM_receive_value),
         .Give_Instruct_mem_Addr(Give_Instruct_mem_Addr),
         .Give_read_write_EXE(Give_read_write_EXE),
         .Give_Data_mem_value(Give_Data_mem_value),
         .Give_Data_mem_addr(Give_Data_mem_addr),
         .Give_instruction_mem_ceb(Give_instruction_mem_ceb)
        //  .Give_Data_mem_ceb(Give_Data_mem_ceb)
         );


SRAM_wrapper DM1(.CLK(clk),.RST(rst),.CEB(1'b0),.WEB(Give_read_write_EXE),
                         .BWEB(32'b0),
                         .A(Give_Data_mem_addr[15:2]),
                         .DI(Give_Data_mem_value),
                         .DO(Data_SRAM_receive_value));


endmodule

