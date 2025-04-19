module General_Reg (
    input clk,
    input rst,
    input AXI_stall,
    input [ 6:0] reg_read_opcode,
    input [ 6:0] reg_we_opcode,
    input        reg_we, //write_enable
    input [31:0] reg_w_data,
    input [ 4:0] reg_w_addr,
    input [ 4:0] reg_in1,
    input [ 4:0] reg_in2,
    output logic [31:0] reg_out1,
    output logic [31:0] reg_out2
);

logic [31:0] g_reg [31:0];//gerneral_reg
integer i;
logic [31:0] f_reg [31:0];//floating_reg
integer j;
logic [31:0] g_reg_out1,g_reg_out2;
logic [31:0] f_reg_out1,f_reg_out2;


always_ff @(posedge clk) begin
    if (rst) begin
        for (i=0 ; i<32 ; i=i+1) begin
           g_reg [i] <= 32'b0;
        end
    end else if ((!AXI_stall)&&(reg_we)&&((reg_we_opcode!=`F_TYPE)&&(reg_we_opcode!=`FLW))) begin
        if (reg_w_addr==5'b0) begin
            g_reg [reg_w_addr] <= 32'b0;
        end else begin
            g_reg [reg_w_addr] <= reg_w_data;
        end 
    end
end

assign g_reg_out1 = g_reg[reg_in1];
assign g_reg_out2 = g_reg[reg_in2];

always_ff @(posedge clk) begin
    if (rst) begin
        for (j=0 ; j<32 ; j=j+1) begin
           f_reg [j] <= 32'b0;
        end
    end else if ((!AXI_stall)&&(reg_we)&&((reg_we_opcode==`F_TYPE)||(reg_we_opcode==`FLW))) begin
           f_reg [reg_w_addr] <= reg_w_data;
    end
end

assign f_reg_out1 = f_reg[reg_in1];
assign f_reg_out2 = f_reg[reg_in2];



assign reg_out1=((reg_read_opcode==`F_TYPE)                         )?f_reg_out1:g_reg_out1;
assign reg_out2=((reg_read_opcode==`F_TYPE)||(reg_read_opcode==`FSW))?f_reg_out2:g_reg_out2;


endmodule