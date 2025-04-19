`include "../include/AXI_define.svh"
`include "I_SRAM_wrapper.sv"
`include "D_SRAM_wrapper.sv"
`include "cpu.sv"

// `include "parameter.svh"
`include "pc.sv"
`include "Add4.sv"
`include "ALU.sv"
`include "Branch_Jump.sv"
`include "Control.sv"
`include "Forwarding.sv"
`include "General_Reg.sv"
`include "Imm_generator.sv"
`include "Load_Use_detection.sv"
`include "MUL.sv"
`include "IF_ID_pc_reg.sv"
`include "IF_ID.sv"
`include "ID_EXE.sv"
`include "EXE_MEM.sv"
`include "MEM_WB.sv"
`include "mux2.sv"
`include "mux3.sv"
`include "mux4.sv"
`include "mux5.sv"
`include "mux_1_to_5_L_wbh.sv"
`include "CSR.sv"


module CPU_wrapper (
//READ ADDRESS0
input ACLK,
input ARESETn,
input ARREADY_M0, 
output [`AXI_ID_BITS-1:0] ARID_M0, 
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,  
output [`AXI_LEN_BITS-1:0] ARLEN_M0,       
output [`AXI_SIZE_BITS-1:0] ARSIZE_M0,   
output [1:0] ARBURST_M0,   
output logic ARVALID_M0,   
//READ ADDRESS1
input ARREADY_M1,
output [`AXI_ID_BITS-1:0] ARID_M1,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,  
output [`AXI_LEN_BITS-1:0] ARLEN_M1,
output [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
output [1:0] ARBURST_M1,
output logic ARVALID_M1,
//READ DATA0
input [`AXI_ID_BITS-1:0] RID_M0,       
input [`AXI_DATA_BITS-1:0] RDATA_M0,  
input [1:0] RRESP_M0,                  
input RLAST_M0,                         
input RVALID_M0,                        
output logic RREADY_M0,                
//READ DATA1
input [`AXI_ID_BITS-1:0] RID_M1,
input [`AXI_DATA_BITS-1:0] RDATA_M1,   
input [1:0] RRESP_M1,
input RLAST_M1,
input RVALID_M1,
output logic RREADY_M1,
//WRITE ADDRESS
input AWREADY_M1,
output [`AXI_ID_BITS-1:0] AWID_M1,
output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
output [`AXI_LEN_BITS-1:0] AWLEN_M1,
output [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
output [1:0] AWBURST_M1,
output logic AWVALID_M1,
//WRITE DATA
input WREADY_M1,
output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
output logic WLAST_M1,
output logic WVALID_M1,
//WRITE RESPONSE
input [`AXI_ID_BITS-1:0] BID_M1,
input [1:0] BRESP_M1,
input BVALID_M1,
output logic BREADY_M1
);



logic AXI_stall_M0,AXI_stall_M1,M1_first;
logic [31:0] AXI_Give_Data_mem_BWEB,Give_Data_mem_addr,Data_SRAM_receive_value,
             Instruction_SRAM_receive_value,Give_Instruct_mem_Addr,Give_Data_mem_value;
logic [1:0]Give_read_write_EXE;


logic lud_IF_ID_maintain;

logic [3:0]M1_state;
logic [1:0]M0_state;


cpu cpu(
    .clk(ACLK),
    .rst(~ARESETn),
    .AXI_stall((AXI_stall_M0)||(AXI_stall_M1)),
    .Instruction_SRAM_receive_value(Instruction_SRAM_receive_value),
    .Data_SRAM_receive_value(Data_SRAM_receive_value),
    .Give_Instruct_mem_Addr(Give_Instruct_mem_Addr),
    .Give_read_write_EXE(Give_read_write_EXE),
    .Give_Data_mem_value(Give_Data_mem_value),
    .Give_Data_mem_addr(Give_Data_mem_addr),
    .Give_Data_mem_BWEB(AXI_Give_Data_mem_BWEB),
    .M0_state(M0_state)
    );

// assign ARADDR_M1=Give_Data_mem_addr;
// assign AWADDR_M1=Give_Data_mem_addr;



I_SRAM_wrapper I_SRAM_wrapper(
    .clk(ACLK),
    .rst(ARESETn),
.M1_first(M1_first),
.RDATA_M0(RDATA_M0),
.M0_state(M0_state),
    .AXI_stall_M0(AXI_stall_M0),
.Give_Instruct_mem_Addr(Give_Instruct_mem_Addr),
    .ARREADY_M0(ARREADY_M0), 
    .ARID_M0(ARID_M0), 
.ARADDR_M0(ARADDR_M0),
    .ARLEN_M0(ARLEN_M0),
    .ARSIZE_M0(ARSIZE_M0),
    .ARBURST_M0(ARBURST_M0),
    .ARVALID_M0(ARVALID_M0),
    .RID_M0(RID_M0),
    .RRESP_M0(RRESP_M0),
    .RLAST_M0(RLAST_M0),
    .RVALID_M0(RVALID_M0),
    .RREADY_M0(RREADY_M0),
.RDATA_M0_out(Instruction_SRAM_receive_value),
.M1_state(M1_state)            
);

D_SRAM_wrapper D_SRAM_wrapper(
    .clk(ACLK),
    .rst(ARESETn),
    .AXI_stall_M1(AXI_stall_M1),
    .AXI_Give_Data_mem_BWEB(AXI_Give_Data_mem_BWEB), 
    .Give_read_write_EXE(Give_read_write_EXE),
.Give_Data_mem_value(Give_Data_mem_value),
.Give_Data_mem_addr(Give_Data_mem_addr),
.RDATA_M1(RDATA_M1),
    .ARREADY_M1(ARREADY_M1),
    .ARID_M1(ARID_M1),
    .ARLEN_M1(ARLEN_M1),
    .ARSIZE_M1(ARSIZE_M1),
    .ARBURST_M1(ARBURST_M1),
    .ARVALID_M1(ARVALID_M1),
    .RID_M1(RID_M1),
    .RRESP_M1(RRESP_M1),
    .RLAST_M1(RLAST_M1),
    .RVALID_M1(RVALID_M1),
    .RREADY_M1(RREADY_M1),
    .AWREADY_M1(AWREADY_M1),
    .AWID_M1(AWID_M1),
    .AWLEN_M1(AWLEN_M1),
    .AWSIZE_M1(AWSIZE_M1),
    .AWBURST_M1(AWBURST_M1),
    .AWVALID_M1(AWVALID_M1),
    .WREADY_M1(WREADY_M1),
.WDATA_M1(WDATA_M1),
    .WSTRB_M1(WSTRB_M1),
    .WLAST_M1(WLAST_M1),
    .WVALID_M1(WVALID_M1),
    .BID_M1(BID_M1),
    .BRESP_M1(BRESP_M1),
    .BVALID_M1(BVALID_M1),
    .BREADY_M1(BREADY_M1),
.M1_first(M1_first),
.ARADDR_M1(ARADDR_M1),
.AWADDR_M1(AWADDR_M1),
.RDATA_M1_out(Data_SRAM_receive_value),
.M1_state(M1_state)
);

    
endmodule

