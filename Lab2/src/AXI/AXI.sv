//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Autor: 			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:		 AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////

//`include "AR_Master_arbiter.sv"
//`include "AR_Slave_decoder.sv"
//`include "Decide_next_AR.sv"
//`include "R_arbiter.sv"
//`include "AW_arbiter.sv"
//`include "W_arbiter.sv"
//`include "B_arbiter.sv"
//`include "DefaultSlave.sv"

`include "../include/AXI_define.svh"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic RLAST_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RVALID_M1,
	input RREADY_M1,
	
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1

);

//AR_Master_arbiter to AR_Slave_decoder
logic [31:0]ARADDR;
logic [7:0] ARID;
logic [3:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
logic ARVALID;
logic [7:0]BID_M1_8;
assign BID_M1 = BID_M1_8[3:0];
 
logic [7:0] ARID_DS;
logic ARREADY_DS;
logic ARVALID_DS;
logic [3:0]ARLEN_DS;
	
logic RREADY_DS;
logic [7:0] RID_DS;
logic RVALID_DS;


logic AWVALID_DS;
logic AWREADY_DS;
	
logic BREADY_DS;
logic BVALID_DS;
logic [7:0] AWID_DS;
logic [7:0] BID_DS;
	
logic WVALID_DS;
logic WREADY_DS; 
logic RLAST_DS;
logic decide_next_AR;
   
AR_Master_arbiter AR_Master_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.ARREADY_M0(ARREADY_M0),
	.ARREADY_M1(ARREADY_M1),
	
	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	
	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	
	.ARADDR(ARADDR),
	.ARID(ARID),	
	.ARLEN(ARLEN),
	.ARSIZE(ARSIZE),
	.ARBURST(ARBURST),
	.ARVALID(ARVALID)
);

AR_Slave_decoder AR_Slave_decoder(
	.ACLK(ACLK),
	.ARESETn(ARESETn),	
	.ARADDR(ARADDR),
	.ARID(ARID),
	.ARLEN(ARLEN),
	.ARSIZE(ARSIZE),
	.ARBURST(ARBURST),
	.ARVALID(ARVALID),
	
	.ARREADY_S0(ARREADY_S0),
	.ARREADY_S1(ARREADY_S1),
	.ARREADY_DS(ARREADY_DS), 
	
	.RLAST_S0(RLAST_S0),
	.RLAST_S1(RLAST_S1),
	.RLAST_DS(RLAST_DS),	
	
	.RVALID_S0(RVALID_S0),
	.RVALID_S1(RVALID_S1),
	.RVALID_DS(RVALID_DS),

	.RREADY_S0(RREADY_S0),
	.RREADY_S1(RREADY_S1),
	.RREADY_DS(RREADY_DS),
	
	.ARADDR_S0(ARADDR_S0),
	.ARID_S0(ARID_S0),
	.ARLEN_S0(ARLEN_S0),
	.ARSIZE_S0(ARSIZE_S0),
	.ARBURST_S0(ARBURST_S0),
	.ARVALID_S0(ARVALID_S0),
	
	.ARADDR_S1(ARADDR_S1),
	.ARID_S1(ARID_S1),
	.ARLEN_S1(ARLEN_S1),
	.ARSIZE_S1(ARSIZE_S1),
	.ARBURST_S1(ARBURST_S1),
	.ARVALID_S1(ARVALID_S1),

	
	.ARID_DS(ARID_DS),
	.ARLEN_DS(ARLEN_DS),
	.ARVALID_DS(ARVALID_DS),
	
	.decide_next_AR(decide_next_AR),
	.ARREADY_M0(ARREADY_M0),
	.ARREADY_M1(ARREADY_M1)
);	


Decide_next_AR Decide_next_AR(
	.ACLK(ACLK),
	.ARESETn(ARESETn),

	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),
	
	.ARVALID_M1(ARVALID_M1),
	.ARREADY_M1(ARREADY_M1),
	
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),
	
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),

	.RLAST_M0(RLAST_M0),
	.RLAST_M1(RLAST_M1),
	
	.decide_next_AR(decide_next_AR)
);	

R_arbiter R_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	
	.RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),
	
	.RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),



	.RID_DS(RID_DS),
	.RVALID_DS(RVALID_DS),	

	.RREADY_M0(RREADY_M0),	
	.RREADY_M1(RREADY_M1),	
	
	
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	
	
	.RREADY_S0(RREADY_S0),
	.RREADY_S1(RREADY_S1),
	.RREADY_DS(RREADY_DS),
	.RLAST_DS(RLAST_DS)
);

AW_arbiter	AW_arbiter(	
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	
	.AWID_M1(AWID_M1),
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1),
	.AWSIZE_M1(AWSIZE_M1),
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	
	.AWREADY_S0(AWREADY_S0),
	.AWREADY_S1(AWREADY_S1),
	.AWREADY_DS(AWREADY_DS),
	.AWREADY_M1(AWREADY_M1),
	
	.AWADDR_S0(AWADDR_S0),
	.AWID_S0(AWID_S0),	
	.AWLEN_S0(AWLEN_S0),
	.AWSIZE_S0(AWSIZE_S0),
	.AWBURST_S0(AWBURST_S0),
	.AWVALID_S0(AWVALID_S0),
	
	.AWADDR_S1(AWADDR_S1),
	.AWID_S1(AWID_S1),	
	.AWLEN_S1(AWLEN_S1),
	.AWSIZE_S1(AWSIZE_S1),
	.AWBURST_S1(AWBURST_S1),
	.AWVALID_S1(AWVALID_S1),
	
	.AWID_DS(AWID_DS),	
	.AWVALID_DS(AWVALID_DS)
);

W_arbiter W_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.AWVALID_M1(AWVALID_M1),
	.AWREADY_M1(AWREADY_M1),
	
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	
	.AWADDR_M1(AWADDR_M1),

	.WREADY_S0(WREADY_S0),
	.WREADY_S1(WREADY_S1),
	.WREADY_DS(WREADY_DS),
	
	.WDATA_S0(WDATA_S0),
	.WSTRB_S0(WSTRB_S0),
	.WLAST_S0(WLAST_S0),
	.WVALID_S0(WVALID_S0),
	
	.WDATA_S1(WDATA_S1),
	.WSTRB_S1(WSTRB_S1),
	.WLAST_S1(WLAST_S1),
	.WVALID_S1(WVALID_S1),

	.WVALID_DS(WVALID_DS),
	
	.WREADY_M1(WREADY_M1)	
);

B_arbiter B_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	
	.BID_S0(BID_S0),
	.BRESP_S0(BRESP_S0),
	.BVALID_S0(BVALID_S0),
	
	.BID_S1(BID_S1),
	.BRESP_S1(BRESP_S1),
	.BVALID_S1(BVALID_S1),

	.BID_DS(BID_DS),
	.BVALID_DS(BVALID_DS),
	
	.BREADY_M1(BREADY_M1),
	
	.BID_M1(BID_M1_8),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	
	.BREADY_S0(BREADY_S0),
	.BREADY_S1(BREADY_S1),
	.BREADY_DS(BREADY_DS)
);

DefaultSlave DefaultSlave(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.ARVALID_DS(ARVALID_DS),
	.ARID_DS(ARID_DS),
	.ARREADY_DS(ARREADY_DS),
	.ARLEN_DS(ARLEN_DS),
	.RREADY_DS(RREADY_DS),
	.RID_DS(RID_DS),
	.RVALID_DS(RVALID_DS),

	.AWVALID_DS(AWVALID_DS),
	.AWID_DS(AWID_DS),
	.AWREADY_DS(AWREADY_DS),

	.WREADY_DS(WREADY_DS),
	.WVALID_DS(WVALID_DS),
	
	.BREADY_DS(BREADY_DS),
	.BVALID_DS(BVALID_DS),
	.BID_DS(BID_DS),
	.RLAST_DS(RLAST_DS)
);

endmodule





module AR_Master_arbiter(
	
	input ACLK,
	input ARESETn,
	//Master0 to AXI
	input [3:0] ARID_M0,
	input [31:0] ARADDR_M0,
	input [3:0] ARLEN_M0,
	input [2:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	
	//Master1 to AXI
	input [3:0] ARID_M1,
	input [31:0] ARADDR_M1,
	input [3:0] ARLEN_M1,
	input [2:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	
	//AXI to Master 
	input ARREADY_M0,
	input ARREADY_M1,
	
	//Mux output result
	output logic [7:0] ARID,
	output logic [31:0] ARADDR,
	output logic [3:0] ARLEN,
	output logic [2:0] ARSIZE,
	output logic [1:0] ARBURST,
	output logic ARVALID
);


logic Master_sel;	
logic transaction_finish;
logic decide_M_first;
logic transaction_M0,transaction_M1;

always_comb begin
	case({ARVALID_M1, ARVALID_M0})
		2'b00: Master_sel = 1'b0;
		2'b01: Master_sel = 1'b0;
		2'b10: Master_sel = 1'b1;
		2'b11: Master_sel = decide_M_first;	
		default: Master_sel = 1'b0;
	endcase
end

assign transaction_M0 = (ARVALID_M0 && ARREADY_M0 && (~Master_sel));
assign transaction_M1 = (ARVALID_M1 & ARREADY_M1 & Master_sel);

always_ff @(posedge ACLK) begin
	if(!ARESETn) begin
		transaction_finish <= 1'b0;
	end else begin
		transaction_finish <= (transaction_M0 || transaction_M1)? 1'b1: 1'b0;
	end
end

always_ff @(posedge ACLK) begin
	if(!ARESETn) begin
		decide_M_first <= 1'b0;
	end else begin
		case({ARVALID_M1, ARVALID_M0})
			2'b00: decide_M_first <= 1'b0;
			2'b01: decide_M_first <= 1'b0;
			2'b10: decide_M_first <= 1'b1;
			2'b11: decide_M_first <= (transaction_finish)? ~decide_M_first : decide_M_first;	
		default: decide_M_first <= 1'b0;
	endcase
	end
end

always_comb begin
	ARID		=	(Master_sel) ? {4'b1000,ARID_M1} : {4'b0000,ARID_M0}; 
	ARADDR		=	(Master_sel) ? ARADDR_M1  : ARADDR_M0;
	ARLEN		=	(Master_sel) ? ARLEN_M1   : ARLEN_M0;
	ARBURST		=	(Master_sel) ? ARBURST_M1 : ARBURST_M0;
	ARSIZE		=	(Master_sel) ? ARSIZE_M1  : ARSIZE_M0;
	ARVALID		=	(Master_sel) ? ARVALID_M1 : ARVALID_M0;
end


endmodule



module AR_Slave_decoder(

	input ACLK,
	input ARESETn,
	//READ ADDRESS//		
	input [31:0] ARADDR,
	input [7:0] ARID,
	input [3:0] ARLEN,
	input [2:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	
	input ARREADY_S0,
	input ARREADY_S1,
	input ARREADY_DS,
	
	input RLAST_S0,
	input RLAST_S1,
	input RLAST_DS,
	
	input RVALID_S0,
	input RVALID_S1,
	input RVALID_DS,
	input decide_next_AR,
	//AXI to slave 
	input RREADY_S0,
	input RREADY_S1,
	input RREADY_DS,
	
	output logic [31:0] ARADDR_S0,
	output logic [7:0] ARID_S0,	
	output logic [3:0] ARLEN_S0,
	output logic [2:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	
	output logic [31:0] ARADDR_S1,
	output logic [7:0] ARID_S1,	
	output logic [3:0] ARLEN_S1,
	output logic [2:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	
	
	output logic [3:0]ARLEN_DS,
	output logic [7:0] ARID_DS,
	output logic ARVALID_DS,
	
	//AXI to master
	output logic ARREADY_M0,
	output logic ARREADY_M1
);

logic ARREADY;

assign 	ARADDR_S0	=	ARADDR;
assign	ARID_S0		=	ARID;
assign	ARLEN_S0	=	ARLEN;
assign	ARSIZE_S0	=	ARSIZE;
assign	ARBURST_S0	=	ARBURST;
	
assign 	ARADDR_S1	=	ARADDR;
assign	ARID_S1		=	ARID;
assign	ARLEN_S1	=	ARLEN;
assign	ARSIZE_S1	=	ARSIZE;
assign	ARBURST_S1	=	ARBURST;

assign  ARLEN_DS = ARLEN;
assign	ARID_DS	=	ARID;

always_comb begin						
	case(ARADDR[31:16]) 
		16'h0000 : begin //ROM
			ARVALID_S0 = decide_next_AR?ARVALID:1'b0;
			ARVALID_S1 = 1'b0;
			ARVALID_DS = 1'b0;
		end
		16'h0001 : begin //IM
			ARVALID_S0 = 1'b0;
			ARVALID_S1 = decide_next_AR?ARVALID:1'b0;
			ARVALID_DS = 1'b0;
		end
		default : begin
			ARVALID_S0 = 1'b0;
			ARVALID_S1 = 1'b0;
			ARVALID_DS = decide_next_AR?ARVALID:1'b0;
		end			
	endcase
end

always_comb begin	
	case({ARVALID_S0, ARVALID_S1, ARVALID_DS})
			3'b100:ARREADY = ARREADY_S0;
			3'b010:ARREADY = ARREADY_S1;
			3'b001:ARREADY = ARREADY_DS;
			default:ARREADY = 1'b0;
	endcase
end

always_comb begin			
		case(ARID[7:6]) 
			2'b00: begin 
				ARREADY_M0 = ARREADY;
				ARREADY_M1 = 1'b0;
			end
			2'b10: begin 
				ARREADY_M0 = 1'b0;
				ARREADY_M1 = ARREADY;
			end
			default: begin
				ARREADY_M0 = 1'b0;
				ARREADY_M1 = 1'b0;
			end
		endcase
	end	

endmodule



module AW_arbiter(

	// only for S1

	input ACLK,
	input ARESETn,
	input [3:0] AWID_M1,
	input [31:0] AWADDR_M1,
	input [3:0] AWLEN_M1,
	input [2:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	
	input AWREADY_S0,
	input AWREADY_S1,
	input AWREADY_DS,
	
	output logic AWREADY_M1,
	
	output logic [31:0] AWADDR_S0,
	output logic [7:0] AWID_S0,	
	output logic [3:0] AWLEN_S0,
	output logic [2:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	
	output logic [31:0] AWADDR_S1,
	output logic [7:0] AWID_S1,	
	output logic [3:0] AWLEN_S1,
	output logic [2:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,

	
	output logic [7:0] AWID_DS,	
	output logic AWVALID_DS
	
);

assign	 AWADDR_S0	= AWADDR_M1;
assign	 AWID_S0	= {4'b1000,AWID_M1};
assign	 AWLEN_S0	= AWLEN_M1;
assign	 AWSIZE_S0	= AWSIZE_M1;
assign	 AWBURST_S0	= AWBURST_M1;

assign	 AWADDR_S1	= AWADDR_M1;
assign	 AWID_S1	= {4'b1000,AWID_M1};
assign	 AWLEN_S1	= AWLEN_M1;
assign	 AWSIZE_S1	= AWSIZE_M1;
assign	 AWBURST_S1	= AWBURST_M1;

assign	 AWID_DS	= {4'b1000,AWID_M1};


always_comb begin	
		case(AWADDR_M1[31:16])
			16'h0000:begin 
					AWVALID_S0 = AWVALID_M1;
					AWVALID_S1 = 1'b0;
					AWVALID_DS = 1'b0;
				end
			16'h0001:begin 
					AWVALID_S0 = 1'b0;
					AWVALID_S1 = AWVALID_M1;
					AWVALID_DS = 1'b0;
				end
			default:begin
					AWVALID_S0 = 1'b0;
					AWVALID_S1 = 1'b0;
					AWVALID_DS = AWVALID_M1;
				end
	endcase
end

always_comb begin
	case({AWVALID_S0,AWVALID_S1,AWVALID_DS})
		3'b100 : AWREADY_M1 = AWREADY_S0;
		3'b010 : AWREADY_M1 = AWREADY_S1;
		3'b001 : AWREADY_M1 = AWREADY_DS;		
		default : AWREADY_M1 = 1'b0;
	endcase
end

endmodule


					
module B_arbiter(
	input ACLK,
	input ARESETn,	

	input [7:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	
	input [7:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	
	input [7:0] BID_DS,
	input BVALID_DS,
	
	input BREADY_M1,
	
	output logic [7:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	
	output logic BREADY_S0,
	output logic BREADY_S1,
	output logic BREADY_DS
);

localparam S0 = 3'd0;
localparam S1 = 3'd1;
localparam DS = 3'd2;

logic transaction_S0;
logic transaction_S1;
logic transaction_DS;

logic [2:0]Slave_sel;
logic [2:0]next_Slave_sel;
logic [2:0]decide_Slave_first;
logic [1:0]last_Slave_sel;


always_ff@(posedge ACLK)begin
	if(~ARESETn)begin
		decide_Slave_first 	<= 3'b0;
		last_Slave_sel 		<= 3'b0;
	end
	else begin
		decide_Slave_first 	<= next_Slave_sel;
		last_Slave_sel 		<= decide_Slave_first;
	end
end

always_comb begin
	case({BVALID_S0, BVALID_S1, BVALID_DS})
		3'b100 :  Slave_sel = S0;
		3'b010 :  Slave_sel = S1;
		3'b001 :  Slave_sel = DS;
		default:  Slave_sel = decide_Slave_first;
	endcase
end

assign transaction_S0 = (BVALID_S0 & BREADY_S0 & (last_Slave_sel==S0));
assign transaction_S1 = (BVALID_S1 & BREADY_S1 & (last_Slave_sel==S1));
assign transaction_DS = (BVALID_DS & BREADY_DS & (last_Slave_sel==DS));
	
always_comb begin
	if (Slave_sel == S0) begin
		if (transaction_S0) begin
			if (BVALID_S1)
				next_Slave_sel = S1;
			else
				next_Slave_sel = DS;
		end 
		else begin
			next_Slave_sel = Slave_sel;
		end
	end 
	else if (Slave_sel == S1) begin
		if (transaction_S1) begin
            if (BVALID_DS)
				next_Slave_sel = DS;
			else
				next_Slave_sel = S0;
		end 
		else begin
			next_Slave_sel = Slave_sel;
		end
	end  
	else if (Slave_sel == DS) begin
		if (transaction_DS) begin
			if (BVALID_S0)
				next_Slave_sel = S0;
			else if (BVALID_S1)
				next_Slave_sel = S1;
		end 
		else begin
			next_Slave_sel = Slave_sel;
		end
	end 
	else begin
		next_Slave_sel = Slave_sel;
	end
end

	
always_comb begin
	case(Slave_sel)
		S0 : begin
			BID_M1		= {BID_S0[7:6], 2'b00, BID_S0[3:0]};
			BRESP_M1	= BRESP_S0;
			BVALID_M1	= BVALID_S0;
		end
		S1 : begin
			BID_M1		= {BID_S1[7:6], 2'b01, BID_S1[3:0]};
			BRESP_M1    = BRESP_S1;
			BVALID_M1   = BVALID_S1;
		end
		DS : begin
			BID_M1		= {BID_DS[7:6], 2'b10, BID_DS[3:0]};
			BRESP_M1    = 2'b11;
			BVALID_M1   = BVALID_DS;
		end
		default : begin
			BID_M1		= {BID_DS[7:6], 2'b11, BID_DS[3:0]};
			BRESP_M1	= 2'b11;
			BVALID_M1	= 1'b0;
		end
	endcase
end
	
always_comb begin
	case(BID_M1[5:4])
		2'b00 : begin
			BREADY_S0	= BREADY_M1;
			BREADY_S1	= 1'b0;
			BREADY_DS	= 1'b0;
		end
		2'b01 : begin
			BREADY_S0	= 1'b0;
			BREADY_S1	= BREADY_M1;
			BREADY_DS	= 1'b0;
		end
		2'b10 : begin
			BREADY_S0	= 1'b0;
			BREADY_S1	= 1'b0;
			BREADY_DS	= BREADY_M1;
		end
		default : begin
			BREADY_S0	= 1'b0;
			BREADY_S1	= 1'b0;
			BREADY_DS	= 1'b0;
		end
	endcase
end
	
endmodule
	


module Decide_next_AR(
	input ACLK,
	input ARESETn,

	input ARVALID_M0,
	input ARREADY_M0,
	
	input ARVALID_M1,
	input ARREADY_M1,
	
	input RVALID_M0,
	input RREADY_M0,
	
	input RVALID_M1,
	input RREADY_M1,

	input RLAST_M0,
	input RLAST_M1,
	
	output logic decide_next_AR
);

parameter state0 = 2'd0;
parameter state1 = 2'd1; 
parameter state2 = 2'd2;

logic [1:0]state,next_state;

always_ff @(posedge ACLK) begin
	if(!ARESETn) begin
		state <= state0;
	end else begin
		state <= next_state;
	end
end

assign Handshake_M0 = ARVALID_M0 & ARREADY_M0;
assign Handshake_M1 = ARVALID_M1 & ARREADY_M1;

always_comb begin
	case(state)
		state0:begin
				case({Handshake_M1, Handshake_M0})
					2'b01  :next_state = state1;
					2'b10  :next_state = state2;
					default:next_state = state0;
				endcase
		end
		state1 : next_state = (RVALID_M0 & RREADY_M0 & RLAST_M0)? state0 : state1;
		state2 : next_state = (RVALID_M1 & RREADY_M1 & RLAST_M1)? state0 : state2;
		default: next_state = state0;
	endcase
end

always_comb begin
	case(state)
		state0 : decide_next_AR = 1'b1;
		state1 : decide_next_AR = 1'b0;
		state2 : decide_next_AR = 1'b0;
		default: decide_next_AR = 1'b1;
	endcase
end

endmodule



module DefaultSlave(
	input ACLK,
	input ARESETn,
	//WRITE ADDRESS DEFAULT
	input [7:0] AWID_DS,
	input AWVALID_DS,
	output logic AWREADY_DS,
	//WRITE DATA DEFAULT
	input WVALID_DS,
	output logic WREADY_DS,
	//WRITE RESPONSE Default
	output logic [7:0] BID_DS,
	output logic BVALID_DS,
	input BREADY_DS,
	//READ ADDRESS DEFAULT
	input [7:0] ARID_DS,
	input ARVALID_DS,
	input [3:0]ARLEN_DS,		
	output logic RLAST_DS,		

	output logic ARREADY_DS,

	//READ DATA Default
	output logic [7:0] RID_DS,
	output logic RVALID_DS,
	input RREADY_DS
);

parameter R_IDLE   = 2'b00;
parameter R_IDLE_2 = 2'b01;
parameter R_DATA   = 2'b10;
parameter R_DATA_2 = 2'b11;

parameter W_IDLE = 2'd0;
parameter W_DATA = 2'd1;
parameter W_BACK = 2'd2;
parameter W_STABLE = 2'd2;

logic [1:0] W_state;
logic [1:0] W_next_state;

logic R_state;
logic R_next_state;

logic [7:0] RID;
logic [7:0] n_RID;
logic [7:0] BID;
logic [7:0] next_BID;

logic [3:0]ARLEN;
assign RLAST_DS = (ARLEN==4'b0);

always_ff@(posedge ACLK) begin
	if(~ARESETn) begin
		R_state <= 1'b0;
		W_state <= 2'b0;
		RID <= 8'd0;
		BID <= 8'd0;
	end
	else begin
		R_state <= R_next_state;
		W_state <= W_next_state;
		RID <= n_RID;
		BID <= next_BID;	
	end
end

always_ff @(posedge ACLK)begin
	if(!ARESETn)
		ARLEN <= 4'b0;
	else if(R_state == R_IDLE && ARVALID_DS)
		ARLEN <= ARLEN_DS;
	else if(R_state == R_DATA && RREADY_DS)begin
		if(ARLEN == 4'h0)
			ARLEN <= ARLEN;
		else	
			ARLEN <= ARLEN - 4'h1;
	end
end

always_comb begin
	case(R_state)
		R_IDLE:	R_next_state = (ARVALID_DS)?R_IDLE_2:R_IDLE;
		R_IDLE_2 : R_next_state = R_DATA;
		R_DATA: R_next_state = (RREADY_DS & RLAST_DS)?R_DATA_2:R_DATA;
		R_DATA_2 : R_next_state = R_IDLE;
	endcase
end

always_comb begin
case(R_state)
		R_IDLE:begin
			ARREADY_DS = 1'b1;
			n_RID = (ARVALID_DS)?ARID_DS:RID;	
			RID_DS = 8'd0;		
			RVALID_DS = 1'b0;
		end
		R_IDLE_2:begin
			ARREADY_DS = 1'b1;
			n_RID = (ARVALID_DS)?ARID_DS:RID;	
			RID_DS = 8'd0;		
			RVALID_DS = 1'b0;
		end
		R_DATA:begin
			ARREADY_DS = 1'b0;
			n_RID = RID;
			RID_DS = RID;
			RVALID_DS = 1'b1;
		end
		R_DATA_2:begin
			ARREADY_DS = 1'b0;
			n_RID = RID;
			RID_DS = RID;
			RVALID_DS = 1'b1;
		end	
	endcase
end

always_comb begin
	case(W_state)
		W_IDLE:	 W_next_state = (AWVALID_DS)?W_DATA:W_IDLE;
		W_DATA:	 W_next_state = (WVALID_DS)?W_BACK:W_DATA;
		W_BACK:  W_next_state = (BREADY_DS)?W_STABLE:W_BACK;
        W_STABLE:W_next_state = W_IDLE;
		default: W_next_state = 2'd0;
	endcase
end

//Write
always_comb begin
	case(W_state)
		W_IDLE:begin
			AWREADY_DS = 1'b1;
			WREADY_DS = 1'b0;
			next_BID = (AWVALID_DS)?AWID_DS:BID;
			BID_DS = 8'd0;		
			BVALID_DS = 1'b0;
		end
		W_DATA:begin
			AWREADY_DS = 1'b1;
			WREADY_DS = 1'b1;	
			next_BID = (AWVALID_DS)?AWID_DS:BID;
			BID_DS = 8'd0;		
			BVALID_DS = 1'b0;		
		end
		W_STABLE:begin
			AWREADY_DS = 1'b0;
			WREADY_DS = 1'b0;
			next_BID = 8'b0;
			BID_DS = 8'b0;
			BVALID_DS = 1'b0;
		end
		W_BACK:begin
			AWREADY_DS = 1'b0;
			WREADY_DS = 1'b0;
			next_BID = BID;
			BID_DS = BID;
			BVALID_DS = 1'b1;
		end
		default:begin
			AWREADY_DS = 1'b0;
			WREADY_DS = 1'b0;
			next_BID = 8'd0;
			BID_DS = 8'd0;
			BVALID_DS = 1'b1;
		end
	endcase
end

endmodule



module R_arbiter(
	
	input ACLK,
	input ARESETn,
	
	input [7:0] RID_S0,
	input [31:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	
	input [7:0] RID_S1,
	input [31:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	


	
	input [7:0] RID_DS,
	input RVALID_DS,
	
	input RREADY_M0,
	input RREADY_M1,
		
	output logic [3:0] RID_M0,
	output logic [31:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	
	output logic [3:0] RID_M1,
	output logic [31:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	
	output logic RREADY_S0,
	output logic RREADY_S1,
	output logic RREADY_DS,
	input logic RLAST_DS
);
localparam S0 = 3'd0;
localparam S1 = 3'd1;
localparam DS = 3'd2;

logic transaction_S0;
logic transaction_S1;
logic transaction_DS; 

logic [2:0]Slave_sel;
logic [2:0]decide_Slave_first;
logic [2:0]next_Slave_sel;
logic [2:0]last_Slave_sel;

logic [7:0] RID;
logic [31:0] RDATA;
logic [1:0] RRESP;
logic RLAST;
logic RVALID;
logic RREADY;

assign	RID_M0	 = RID[3:0];
assign	RDATA_M0 = RDATA;
assign	RRESP_M0 = RRESP;
assign	RLAST_M0 = RLAST;
 
assign	RID_M1	 = RID[3:0];
assign	RDATA_M1 = RDATA;
assign	RRESP_M1 = RRESP;
assign	RLAST_M1 = RLAST;

assign transaction_S0 = (RVALID_S0 & RREADY_S0 & (last_Slave_sel==S0));// last_Slave_sel
assign transaction_S1 = (RVALID_S1 & RREADY_S1 & (last_Slave_sel==S1));
assign transaction_DS = (RVALID_DS & RREADY_DS & (last_Slave_sel==DS));	

always_comb begin
	case({RVALID_S0, RVALID_S1, RVALID_DS})
		3'b100 : Slave_sel = S0;
		3'b010 : Slave_sel = S1;
		3'b001 : Slave_sel = DS;
		default :Slave_sel = decide_Slave_first;
	endcase
end

always_ff@(posedge ACLK)begin
	if(~ARESETn)begin
		decide_Slave_first 	<= S0;
		last_Slave_sel 		<= S0;
	end
	else begin
		decide_Slave_first 	<= next_Slave_sel;
		last_Slave_sel 		<= decide_Slave_first;
	end
end
	
always_comb begin
	if (Slave_sel == S0) begin
		if (transaction_S0) begin
			if (RVALID_S1)
				next_Slave_sel = S1;
			else if (RVALID_DS)
				next_Slave_sel = DS;
			else
				next_Slave_sel = S0;
		end 
		else begin
			next_Slave_sel = Slave_sel;
		end
	end 
	else if (Slave_sel == S1) begin
		if (transaction_S1) begin
            if (RVALID_DS)
				next_Slave_sel = DS;
			else if (RVALID_S0)
				next_Slave_sel = S0;
			else
				next_Slave_sel = S1;
		end 
		else begin
			next_Slave_sel = Slave_sel;
		end
	end 
	else if (Slave_sel == DS) begin
		if (transaction_DS) begin
			if (RVALID_S0)
				next_Slave_sel = S0;
			else if (RVALID_S1)
				next_Slave_sel = S1;
			else
				next_Slave_sel = DS;
		end 
		else begin
			next_Slave_sel = Slave_sel;
		end
	end 
	else begin
		next_Slave_sel = Slave_sel;
	end
end

//valid decoder
always_comb begin
	case(Slave_sel) 
		S0:begin 
				RID	    =  	{RID_S0[7:6],2'b00,RID_S0[3:0]};
				RDATA	=	RDATA_S0;
				RRESP	=	RRESP_S0;
				RLAST	=	RLAST_S0;
				RVALID	=	RVALID_S0;				
			end
		S1:begin
				RID		=	{RID_S1[7:6],2'b01,RID_S1[3:0]};
				RDATA	=	RDATA_S1;
				RRESP	=	RRESP_S1;
				RLAST	=	RLAST_S1;
				RVALID	=	RVALID_S1;		
			end
		DS:begin		
				RID		=	{RID_DS[7:6],2'b10,RID_DS[3:0]};
				RDATA	=	32'd0;
				RRESP	=	2'b11; //Decode error
				RLAST	=	RLAST_DS;
				RVALID	=	RVALID_DS;
			end		
		default:begin 
				RID		=	{RID_DS[7:6],2'b11,RID_DS[3:0]};
				RDATA	=	32'd0;
				RRESP	=	2'b11;
				RLAST	=	1'b0;
				RVALID	=	1'b0;
			end			
	endcase
end

always_comb begin
	case(RID[5:4])
		2'd0 : begin
					RREADY_S0	=	RREADY;
					RREADY_S1	=	1'b0;
					RREADY_DS	=	1'b0;	
				end
		
		2'd1 : begin
					RREADY_S0	=	1'b0;
					RREADY_S1	=	RREADY;
					RREADY_DS	=	1'b0;	
				end					
		2'd2 : begin
					RREADY_S0	=	1'b0;
					RREADY_S1	=	1'b0;
					RREADY_DS	=	RREADY;	
				end
		default : begin
					RREADY_S0	=	1'b0;
					RREADY_S1	=	1'b0;
					RREADY_DS	=	1'b0;	
				end
	endcase
end

always_comb begin
	case (RID[7:6])
		2'b00: begin
			RVALID_M0 = RVALID;
			RVALID_M1 = 1'b0;
		end
		2'b10: begin
			RVALID_M0 = 1'b0;
			RVALID_M1 = RVALID;
		end
        default: begin
			RVALID_M0 = 1'b0;
			RVALID_M1 = 1'b0;
		end
	endcase	
end		

always_comb begin
	case({RVALID_M0,RVALID_M1})
		2'b10 : RREADY = RREADY_M0;
		2'b01 : RREADY = RREADY_M1;
		default : RREADY = 1'b0;
	endcase
end


endmodule



module W_arbiter(

	// only for S1

	input ACLK,
	input ARESETn,
	
	input AWVALID_M1,
	input AWREADY_M1,
	
	input [31:0] WDATA_M1,
	input [3:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,

	input [31:0] AWADDR_M1, // from AW address channel
	
	input WREADY_S0,
	input WREADY_S1,
	input WREADY_DS,
	
	output logic [31:0] WDATA_S0,
	output logic [3:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	
	output logic [31:0] WDATA_S1,
	output logic [3:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	
	output logic WVALID_DS,
	
	output logic WREADY_M1
);	

logic Handshake_M1;
logic [31:0]AWADDR_M1_reg;

assign WDATA_S0		= WDATA_M1;
assign WSTRB_S0		= WSTRB_M1;
assign WLAST_S0		= WLAST_M1;

assign WDATA_S1		= WDATA_M1;
assign WSTRB_S1		= WSTRB_M1;
assign WLAST_S1		= WLAST_M1;

assign Handshake_M1 = (AWVALID_M1 && AWREADY_M1);

always_ff@(posedge ACLK)begin	//write addr沒有握手, 維持同一個slave Wvalid
	if(~ARESETn)
		AWADDR_M1_reg <= 32'b0;
	else if(Handshake_M1)
		AWADDR_M1_reg <= AWADDR_M1;
	else 
		AWADDR_M1_reg <= AWADDR_M1_reg;
end

always_comb begin
	if(AWVALID_M1 && AWREADY_M1)begin
		case(AWADDR_M1[31:16])
			16'h0000 : begin
				WVALID_S0 = WVALID_M1;
				WVALID_S1 = 1'b0;
				WVALID_DS = 1'b0;
			end
			16'h0001 : begin
				WVALID_S0 = 1'b0;
				WVALID_S1 = WVALID_M1;
				WVALID_DS = 1'b0;
			end
			default : begin
				WVALID_S0 = 1'b0;
				WVALID_S1 = 1'b0;
				WVALID_DS = WVALID_M1;
			end
		endcase
	end
	else begin
		case(AWADDR_M1_reg[31:16])
			16'h0000 : begin
				WVALID_S0 = WVALID_M1;
				WVALID_S1 = 1'b0;
				WVALID_DS = 1'b0;
			end
			16'h0001 : begin
				WVALID_S0 = 1'b0;
				WVALID_S1 = WVALID_M1;
				WVALID_DS = 1'b0;
			end
			default : begin
				WVALID_S0 = 1'b0;
				WVALID_S1 = 1'b0;
				WVALID_DS = WVALID_M1;
			end
		endcase
	end
end
	
always_comb begin
	case({WVALID_S0, WVALID_S1, WVALID_DS})
		3'b100 : WREADY_M1 = WREADY_S0;
		3'b010 : WREADY_M1 = WREADY_S1;
		3'b001 : WREADY_M1 = WREADY_DS;
		default: WREADY_M1 = 1'b0;
	endcase
end
	
endmodule

