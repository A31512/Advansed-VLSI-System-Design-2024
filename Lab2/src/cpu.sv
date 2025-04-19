`include "parameter.svh"

module cpu (
    input clk,
    input rst,
    input AXI_stall,
    input [31:0] Instruction_SRAM_receive_value,
    input [31:0] Data_SRAM_receive_value,
    output logic [31:0] Give_Instruct_mem_Addr,
    output logic [ 1:0] Give_read_write_EXE,
    output logic [31:0] Give_Data_mem_value,
    output logic [31:0] Give_Data_mem_addr,
    output logic [31:0] Give_Data_mem_BWEB,
    input [1:0] M0_state
    );




logic [31:0] pc_in_if_i;
logic [31:0] IF_ID_pc_reg;


logic [31:0] pc_in_IF;
logic [31:0] instrction_in_IF;


logic [31:0] data1_in_id_i;
logic [31:0] data2_in_id_i;
logic [31:0] immediate_in_id_i;
logic [ 1:0] data1_ALU_sel_id_i;
logic [ 1:0] data2_ALU_sel_id_i;
logic [ 1:0] data1_BJ_sel_id_i;
logic [ 1:0] data2_BJ_sel_id_i;
logic [ 1:0] data3_MID_sel_id_i;
logic [ 4:0] ALU_op_id_i;
logic [ 2:0] bj_sel_id_i;
logic        data_MEM_sel_id_i;
logic [ 1:0] read_write_id_i;
logic [ 1:0] wb_sel_id_i;
logic        reg_write_en_id_i;
logic [ 2:0] funct3_ID;
logic [ 6:0] opcode_ID;
logic [ 4:0] instrction_in_ID;
logic [31:0] pc_in_ID;
logic [31:0] data1_in_ID;
logic [31:0] data2_in_ID;
logic [31:0] immediate_in_ID;
logic [ 1:0] data1_ALU_sel_ID;
logic [ 1:0] data2_ALU_sel_ID;
logic [ 1:0] data1_BJ_sel_ID;
logic [ 1:0] data2_BJ_sel_ID;
logic [ 1:0] data3_MID_sel_ID;
logic [ 4:0] ALU_op_ID;
logic [ 2:0] bj_sel_ID;
logic        data_MEM_sel_ID;
logic [ 1:0] read_write_ID;
logic [ 1:0] wb_sel_ID;
logic        reg_write_en_ID;



logic [31:0] alu_in_exe_i;
logic [31:0] data_in_exe_i;

logic [ 2:0] funct3_EXE;
logic [ 6:0] opcode_EXE;
logic [ 4:0] instrction_in_EXE;
logic [31:0] pc_in_EXE;
logic [31:0] alu_in_EXE;
logic [31:0] immediate_in_EXE;
logic [31:0] data_in_EXE;
logic        data_MEM_sel_EXE;

logic [ 1:0] wb_sel_EXE;
logic        reg_write_en_EXE;

logic [31:0] pc_in_mem_i;

logic [ 6:0] opcode_MEM;
logic [ 4:0] instrction_in_MEM;
logic [ 31:0] alu_in_MEM;
logic [31:0] pc_in_MEM;
logic [31:0] immediate_in_MEM;
logic [31:0] Data_SRAM_value_in_MEM;  // Data_SRAM繞過去
logic [ 1:0] wb_sel_MEM;
logic        reg_write_en_MEM;





logic [31:0] forwarding_wb_red;
logic        bj_pc_sel,lud_IF_ID_maintain,lud_ID_EX_nop;
// logic        give_Data_mem_ceb_ID;
logic [2:0]   funct3_MEM;
// logic         lud_LUI_fwrd_ID;
// logic         lud_LUI_fwrd_EXE;
logic lud_LUI_fwrd_ID_1,lud_LUI_fwrd_ID_2;
logic [2:0] wb_sel_csr_id_i,wb_sel_csr_ID,wb_sel_csr_EXE,wb_sel_csr_MEM;
logic [31:0] csr_cycle_low,csr_cycle_high,csr_instret_low,csr_instret_high,out_mux4_WB;
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////        IF_ID_pc_reg      ///////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0] pc_in,add4_out;
Add4 add4_IF(.add4_in(pc_in_if_i),.add4_out(add4_out));
mux2 mux2_IF(.in1(add4_out),.in2(alu_in_exe_i),.sel(bj_pc_sel),.out(pc_in));
pc   pc(
    .clk(clk),
    .rst(rst),
    .pc_in(pc_in),
    .pc_maintain((lud_IF_ID_maintain)||(AXI_stall)),
    .pc_out(pc_in_if_i));

assign Give_Instruct_mem_Addr=pc_in_if_i;


// IF_ID_pc_reg IF_ID_pc_reg_(.clk(clk),.rst(rst),
// .bj_flush(bj_pc_sel),
// .load_use_maintain((lud_IF_ID_maintain)||(AXI_stall)),
// .pc_in_if_i(pc_in_if_i),



// .IF_ID_pc_reg(IF_ID_pc_reg));

assign IF_ID_pc_reg=pc_in_if_i;
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////    IF       ////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

//load_use_reg
logic load_use_reg;
always_ff @(posedge clk) begin
    if (rst) begin
        load_use_reg<=1'b0;
    end 
    else if (AXI_stall) begin
        load_use_reg<=load_use_reg;
    end 
    else if (lud_IF_ID_maintain) begin
        load_use_reg<=1'b1;
    end else if (bj_pc_sel) begin
        load_use_reg<=1'b0;
    end else begin
        load_use_reg<=1'b0;
    end
end

//SRAM_receive_value_reg
logic [31:0] SRAM_receive_value_reg;
always_ff @(posedge clk) begin
    if (rst) begin
        SRAM_receive_value_reg <= 32'b0;
    end else if ((!AXI_stall) && (lud_IF_ID_maintain)) begin
        SRAM_receive_value_reg<=Instruction_SRAM_receive_value;
    end else if ((!AXI_stall) && (bj_pc_sel)) begin
        SRAM_receive_value_reg <= 32'b0;
    end else begin
        SRAM_receive_value_reg<=SRAM_receive_value_reg;
    end
end
logic [31:0] SRAM_receive_value_MUX;
assign SRAM_receive_value_MUX=(load_use_reg)?SRAM_receive_value_reg:Instruction_SRAM_receive_value;
// //IF_ID_pc_regiester
// logic [31:0] IF_ID_pc_regiester;
// always_ff @(posedge clk) begin
//     if (rst) begin
//         IF_ID_pc_regiester <= 32'b0;
//     end else if ((!AXI_stall) && (lud_IF_ID_maintain)) begin
//         IF_ID_pc_regiester<=IF_ID_pc_reg;
//     end else if ((!AXI_stall) && (bj_pc_sel)) begin
//         IF_ID_pc_regiester <= 32'b0;
//     end else begin
//         IF_ID_pc_regiester<=IF_ID_pc_regiester;
//     end
// end
// //IF_ID_pc_reg_MUX
// logic [31:0] IF_ID_pc_reg_MUX;
// assign IF_ID_pc_reg_MUX=(load_use_reg)?IF_ID_pc_regiester:IF_ID_pc_reg;

// logic flush_1;
// always_ff @(posedge clk) begin
//     if (rst) begin
//         flush_1<=1'b0;
//     end else if ((lud_IF_ID_maintain)||(AXI_stall)) begin
//         flush_1<=flush_1;
//     end else if (bj_pc_sel) begin
//         flush_1<=1'b1;
//     end else begin
//         flush_1<=1'b0;
//     end
// end

// logic a123;
// assign a123=(bj_pc_sel)||(flush_1);

IF_ID IF_ID(.clk(clk),.rst(rst),.bj_flush(bj_pc_sel),
.load_use_IF_ID_maintain((lud_IF_ID_maintain)||(AXI_stall)),
.IF_ID_pc_reg(IF_ID_pc_reg),
.instrction_SRAM_value(SRAM_receive_value_MUX),


.pc_in_IF(pc_in_IF),
.instrction_in_IF(instrction_in_IF));
// assign pc_in_IF=IF_ID_pc_reg_MUX;
// assign instrction_in_IF=SRAM_receive_value_MUX;
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////  ID        ////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

logic [1:0] ctrl_alu_op1_sel,ctrl_alu_op2_sel;
logic fwrd_data1_ID_sel,fwrd_data2_ID_sel;

Load_Use_detection Load_Use_detection(
    .M0_state(M0_state),
    .lud_opcode(opcode_ID),
    .lud_IF_addr1(instrction_in_IF[19:15]),
    .lud_IF_addr2(instrction_in_IF[24:20]),
    .lud_ID_addr(instrction_in_ID),
    .lud_ID_EX_nop(lud_ID_EX_nop),
    .lud_IF_ID_maintain(lud_IF_ID_maintain)
);

Forwarding Forwarding(
    .fwrd_ID_reg1(instrction_in_IF[19:15]),//INST[19:15]
    .fwrd_ID_reg2(instrction_in_IF[24:20]),//INST[24:20]
    .fwrd_opcode_ID(instrction_in_IF[6:0]),
    .op1_sel(ctrl_alu_op1_sel),
    .op2_sel(ctrl_alu_op2_sel),
    .fwrd_WB_addr(instrction_in_MEM), //rd
    .fwrd_MEM_addr(instrction_in_EXE),//rd
    .fwrd_EXE_addr(instrction_in_ID),//rd

    .fwrd_opcode_EXE(opcode_ID),
    .fwrd_opcode_MEM(opcode_EXE),
    // .fwrd_opcode_WB(opcode_MEM),

    .fwrd_LUI_1(fwrd_LUI_1),
    .fwrd_LUI_2(fwrd_LUI_2),

    .reg_write_en_EXE(reg_write_en_ID),
    .reg_write_en_MEM(reg_write_en_EXE),
    .reg_write_en_WB(reg_write_en_MEM),


    .fwrd_data1_ID_sel(fwrd_data1_ID_sel),
    .fwrd_data2_ID_sel(fwrd_data2_ID_sel),
    .fwrd_data1_ALU_sel(data1_ALU_sel_id_i),
    .fwrd_data2_ALU_sel(data2_ALU_sel_id_i),
    .fwrd_data1_BJ_sel(data1_BJ_sel_id_i),
    .fwrd_data2_BJ_sel(data2_BJ_sel_id_i),
    .fwrd_data3_MID_sel(data3_MID_sel_id_i),
    .fwrd_data_MEM_sel(data_MEM_sel_id_i)
    );


logic [31:0]  g_reg_out1,g_reg_out2;
General_Reg General_Reg(
    .clk(clk),
    .rst(rst),
    .AXI_stall(AXI_stall),
    .reg_read_opcode(instrction_in_IF[6:0]),
    .reg_we_opcode(opcode_MEM),
    .reg_we(reg_write_en_MEM), //write_enable
    .reg_w_data(forwarding_wb_red),
    .reg_w_addr(instrction_in_MEM),
    .reg_in1(instrction_in_IF[19:15]),
    .reg_in2(instrction_in_IF[24:20]),
    .reg_out1(g_reg_out1),
    .reg_out2(g_reg_out2)
);

mux2 mux2_ID_1(.in1(g_reg_out1),.in2(forwarding_wb_red),.sel(fwrd_data1_ID_sel),.out(data1_in_id_i));

mux2 mux2_ID_2(.in1(g_reg_out2),.in2(forwarding_wb_red),.sel(fwrd_data2_ID_sel),.out(data2_in_id_i));

logic [2:0] imm_sel;
Imm_generator Imm_generator(
    .imm_in(instrction_in_IF[31:7]),
    .imm_sel(imm_sel),
    .imm_out(immediate_in_id_i)
    );

Control Control(
    .ctrl_opcode(instrction_in_IF[6:0]),
    .ctrl_funct3(instrction_in_IF[14:12]),
    .ctrl_funct7(instrction_in_IF[31:25]),
    .ctrl_rs1(instrction_in_IF[19:15]),
    .ctrl_imm_csr(instrction_in_IF[31:20]),
    .ctrl_imm_sel(imm_sel),
    .ctrl_alu_op1_sel(ctrl_alu_op1_sel),//前面多補0，多1bit
    .ctrl_alu_op2_sel(ctrl_alu_op2_sel),//前面多補0，多1bit
    .ctrl_alu_sel(ALU_op_id_i),
    .ctrl_bj_sel(bj_sel_id_i),
    .ctrl_DM_read_write_en(read_write_id_i),
    .ctrl_wb_sel(wb_sel_id_i),
    .ctrl_wb_sel_csr(wb_sel_csr_id_i),
    .ctrl_reg_write_en(reg_write_en_id_i)
    );




ID_EXE ID_EXE (
.clk(clk),
.rst(rst),
.stall(AXI_stall),
.bj_flush(bj_pc_sel),
.load_use_nop(lud_ID_EX_nop),
.lud_LUI_fwrd_id_1_i(fwrd_LUI_1),
.lud_LUI_fwrd_id_2_i(fwrd_LUI_2),
.funct3_id_i(instrction_in_IF[14:12]),
.opcode_id_i(instrction_in_IF[6:0]),
.instrction_in_id_i(instrction_in_IF[11:7]),
.pc_in_id_i(pc_in_IF),
.data1_in_id_i(data1_in_id_i),
.data2_in_id_i(data2_in_id_i),
.immediate_in_id_i(immediate_in_id_i),
.data1_ALU_sel_id_i(data1_ALU_sel_id_i),
.data2_ALU_sel_id_i(data2_ALU_sel_id_i),
.data1_BJ_sel_id_i(data1_BJ_sel_id_i),
.data2_BJ_sel_id_i(data2_BJ_sel_id_i),
.data3_MID_sel_id_i(data3_MID_sel_id_i),
.ALU_op_id_i(ALU_op_id_i),
.bj_sel_id_i(bj_sel_id_i),
.data_MEM_sel_id_i(data_MEM_sel_id_i),
.read_write_id_i(read_write_id_i),
.wb_sel_id_i(wb_sel_id_i),
.wb_sel_csr_id_i(wb_sel_csr_id_i),
.reg_write_en_id_i(reg_write_en_id_i),


// .give_Data_mem_ceb_ID(give_Data_mem_ceb_ID),
.lud_LUI_fwrd_ID_1(lud_LUI_fwrd_ID_1),
.lud_LUI_fwrd_ID_2(lud_LUI_fwrd_ID_2),
.funct3_ID(funct3_ID),
.opcode_ID(opcode_ID),
.instrction_in_ID(instrction_in_ID),
.pc_in_ID(pc_in_ID),
.data1_in_ID(data1_in_ID),
.data2_in_ID(data2_in_ID),
.immediate_in_ID(immediate_in_ID),
.data1_ALU_sel_ID(data1_ALU_sel_ID),
.data2_ALU_sel_ID(data2_ALU_sel_ID),
.data1_BJ_sel_ID(data1_BJ_sel_ID),
.data2_BJ_sel_ID(data2_BJ_sel_ID),
.data3_MID_sel_ID(data3_MID_sel_ID),
.ALU_op_ID(ALU_op_ID),
.bj_sel_ID(bj_sel_ID),
.data_MEM_sel_ID(data_MEM_sel_ID),
.read_write_ID(read_write_ID),
.wb_sel_ID(wb_sel_ID),
.wb_sel_csr_ID(wb_sel_csr_ID),
.reg_write_en_ID(reg_write_en_ID));
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////  EXE    ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////


logic [31:0] alu_in1,alu_in2;
logic [31:0] out_1,out_2;


mux4 mux4_EXE_1(
    .in1(data1_in_ID),
    .in2(pc_in_ID),
    .in3(forwarding_wb_red),
    .in4(Give_Data_mem_addr),
    .sel(data1_ALU_sel_ID),
    .out(out_1)
);                           
mux2 mux2_mux4_EXE_1(.in1(out_1),.in2(immediate_in_EXE),.sel(lud_LUI_fwrd_ID_1),.out(alu_in1));
mux4 mux4_EXE_2(
    .in1(data2_in_ID),
    .in2(immediate_in_ID),
    .in3(forwarding_wb_red),                 
    .in4(Give_Data_mem_addr),
    .sel(data2_ALU_sel_ID),
    .out(out_2)
);                       
mux2 mux2_mux4_EXE_2(.in1(out_2),.in2(immediate_in_EXE),.sel(lud_LUI_fwrd_ID_2),.out(alu_in2));


logic [31:0] alu_out_exe,mul_out_exe;

ALU ALU(
    .alu_in1(alu_in1),
    .alu_in2(alu_in2),
    .alu_sel(ALU_op_ID),
    .alu_opcode(opcode_ID),
    .alu_out(alu_out_exe)
);

assign alu_in_exe_i=((ALU_op_ID==`MUL)||(ALU_op_ID==`MULH)||
                   (ALU_op_ID==`MULHU)||(ALU_op_ID==`MULHSU))?mul_out_exe:alu_out_exe;


MUL MUL(
    .mul_in1(alu_in1),
    .mul_in2(alu_in2),
    .mul_sel(ALU_op_ID),
    .mul_out(mul_out_exe)
);

mux3 mux3_EXE_3(
    .in1(data2_in_ID),
    .in2(forwarding_wb_red),
    .in3(Give_Data_mem_addr),
    .sel(data3_MID_sel_ID),
    .out(data_in_exe_i)
);


logic [31:0] bj_in1,bj_in2;
logic [31:0] out_4,out_5;

mux3 mux3_EXE_4(
    .in1(data1_in_ID),
    .in2(forwarding_wb_red),
    .in3(Give_Data_mem_addr),
    .sel(data1_BJ_sel_ID),
    .out(out_4)
);mux2 mux2_mux3_EXE_4(.in1(out_4),.in2(immediate_in_EXE),.sel(lud_LUI_fwrd_ID_1),.out(bj_in1));



mux4 mux4_EXE_5(
    .in1(data2_in_ID),
    .in2(forwarding_wb_red),
    .in3(Give_Data_mem_addr),
    .in4(csr_instret_high),                           ////////////csr_instret_high不是很好_還要改
    .sel(data2_BJ_sel_ID),
    .out(out_5)
);mux2 mux2_mux3_EXE_5(.in1(out_5),.in2(immediate_in_EXE),.sel(lud_LUI_fwrd_ID_2),.out(bj_in2));



Branch_Jump Branch_Jump(
    .bj_in1(bj_in1),
    .bj_in2(bj_in2),
    .bj_sel(bj_sel_ID),
    .bj_func3(funct3_ID),
    .bj_opcode(opcode_ID),
    .bj_pc_sel(bj_pc_sel)      
);


EXE_MEM EXE_MEM (
.clk(clk),
.rst(rst),
.stall(AXI_stall),
.funct3_exe_i(funct3_ID),
.opcode_exe_i(opcode_ID),

// .give_Data_mem_ceb_exe(give_Data_mem_ceb_ID),
// .lud_LUI_fwrd_exe(lud_LUI_fwrd_ID),
.instrction_in_exe_i(instrction_in_ID),
.pc_in_exe_i(pc_in_ID),
.alu_in_exe_i(alu_in_exe_i),
.immediate_in_exe_i(immediate_in_ID),
.data_in_exe_i(data_in_exe_i),
.data_MEM_sel_exe_i(data_MEM_sel_ID),
.read_write_exe_i(read_write_ID),
.wb_sel_exe_i(wb_sel_ID),
.wb_sel_csr_exe_i(wb_sel_csr_ID),
.reg_write_en_exe_i(reg_write_en_ID),


// .give_Data_mem_ceb_EXE(Give_Data_mem_ceb),
// .lud_LUI_fwrd_EXE(lud_LUI_fwrd_EXE),
.funct3_EXE(funct3_EXE),
.opcode_EXE(opcode_EXE),
.instrction_in_EXE(instrction_in_EXE),
.pc_in_EXE(pc_in_EXE),
.alu_in_EXE(alu_in_EXE),
.immediate_in_EXE(immediate_in_EXE),
.data_in_EXE(data_in_EXE),
.data_MEM_sel_EXE(data_MEM_sel_EXE),
.read_write_EXE(Give_read_write_EXE),
.wb_sel_EXE(wb_sel_EXE),
.wb_sel_csr_EXE(wb_sel_csr_EXE),
.reg_write_en_EXE(reg_write_en_EXE));
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  MEM       ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////


Add4 Add4_MEM(.add4_in(pc_in_EXE),.add4_out(pc_in_mem_i));

logic [31:0]out_Data_SRAM;
mux2 Load_data_mem_value_in(
    .in1(data_in_EXE),
    .in2(forwarding_wb_red),
    .sel(data_MEM_sel_EXE),
    .out(out_Data_SRAM));//Give_Data_mem_value

always_comb begin
    if ((opcode_EXE==`STORE)&&(funct3_EXE==3'b001)) begin //SH
        if ((alu_in_EXE[1:0]==2'b10)||(alu_in_EXE[1:0]==2'b11)||(alu_in_EXE[1:0]==2'b10)) begin
            Give_Data_mem_value = {out_Data_SRAM[15:0],16'b0};
            Give_Data_mem_BWEB = {16'b0,{16{1'b1}}};
        end else begin
            Give_Data_mem_value = {16'b0,out_Data_SRAM[15:0]};
            Give_Data_mem_BWEB = {{16{1'b1}},16'b0};
        end
    end else if ((opcode_EXE==`STORE)&&(funct3_EXE==3'b000)) begin  //SB
        if (alu_in_EXE[1:0]==2'b11) begin
            Give_Data_mem_value = {out_Data_SRAM[7:0],24'b0};
            Give_Data_mem_BWEB = {8'b0,{24{1'b1}}};
        end else if (alu_in_EXE[1:0]==2'b10) begin
            Give_Data_mem_value = {8'b0,out_Data_SRAM[7:0],16'b0};
            Give_Data_mem_BWEB = {{8{1'b1}},8'b0,{16{1'b1}}};
        end else if (alu_in_EXE[1:0]==2'b01) begin
            Give_Data_mem_value = {16'b0,out_Data_SRAM[7:0],8'b0};
            Give_Data_mem_BWEB = {{16{1'b1}},8'b0,{8{1'b1}}};
        end else begin
            Give_Data_mem_value = {24'b0,out_Data_SRAM[7:0]};
            Give_Data_mem_BWEB = {{24{1'b1}},8'b0};
        end
    end else begin
        Give_Data_mem_value = out_Data_SRAM;
        Give_Data_mem_BWEB = 32'b0;
    end
end


// logic [31:0] alu_in_EXE_wire;
// always_ff @(posedge clk) begin
//     if (rst) begin
//         alu_in_EXE_wire <= 32'b0;
//     end else if ((!AXI_stall) && (lud_IF_ID_maintain)) begin
//         alu_in_EXE_wire<=alu_in_EXE_wire;
//     end else if ((!AXI_stall) && (bj_pc_sel)) begin
//         alu_in_EXE_wire <= 32'b0;
//     end else begin
//         alu_in_EXE_wire<=alu_in_EXE;
//     end
// end
// assign Give_Data_mem_addr = alu_in_EXE_wire;


assign Give_Data_mem_addr = alu_in_EXE;


logic [31:0] mux_1_to_5_L_wbh_out;



MEM_WB MEM_WB (
.clk(clk),
.rst(rst),
.stall(AXI_stall),
.opcode_mem_i(opcode_EXE),
.funct3_mem_i(funct3_EXE),
.instrction_in_mem_i(instrction_in_EXE),
.pc_in_mem_i(pc_in_mem_i),
.alu_in_mem_i(alu_in_EXE),
.immediate_in_mem_i(immediate_in_EXE),
.Data_SRAM_value(Data_SRAM_receive_value),   //  Data_SRAM繞過去
.wb_sel_mem_i(wb_sel_EXE),
.wb_sel_csr_mem_i(wb_sel_csr_EXE),
.reg_write_en_mem_i(reg_write_en_EXE),


.opcode_MEM(opcode_MEM),
.funct3_MEM(funct3_MEM),
.instrction_in_MEM(instrction_in_MEM),
.pc_in_MEM(pc_in_MEM),
.alu_in_MEM(alu_in_MEM),
.immediate_in_MEM(immediate_in_MEM),
.Data_SRAM_value_in_MEM(Data_SRAM_value_in_MEM),   //  Data_SRAM繞過去
.wb_sel_MEM(wb_sel_MEM),
.wb_sel_csr_MEM(wb_sel_csr_MEM),
.reg_write_en_MEM(reg_write_en_MEM));
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////  WB        ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////


mux4 mux4_WB(
    .in1(pc_in_MEM),
    .in2(alu_in_MEM),
    .in3(immediate_in_MEM),
    .in4(mux_1_to_5_L_wbh_out),
    .sel(wb_sel_MEM),
    .out(out_mux4_WB)
);

mux_1_to_5_L_wbh mux_1_to_5_L_wbh(
    .in1(Data_SRAM_value_in_MEM),
    .opcode(opcode_MEM),
    .funct3(funct3_MEM),
    .out(mux_1_to_5_L_wbh_out)
);

CSR CSR(
    .clk(clk),
    .rst(rst),
    .AXI_stall(AXI_stall),
    .csr_opcode(opcode_MEM),
    .flush(bj_pc_sel),
    .load_use_maintain(lud_IF_ID_maintain),
    .csr_cycle_low(csr_cycle_low),
    .csr_cycle_high(csr_cycle_high),
    .csr_instret_low(csr_instret_low),
    .csr_instret_high(csr_instret_high)
);

mux5 mux5_WB(
    .in1(csr_instret_high),
    .in2(csr_instret_low),
    .in3(csr_cycle_high),
    .in4(csr_cycle_low),
    .in5(out_mux4_WB),
    .sel(wb_sel_csr_MEM),
    .out(forwarding_wb_red)
);


endmodule