`include "../include/AXI_define.svh"

module SRAM_wrapper (  
input ACLK,
input ARESETn,
//MASTER INTERFACE FOR SLAVES
//WRITE ADDRESS0
input [`AXI_IDS_BITS-1:0] AWID_S,
input [`AXI_ADDR_BITS-1:0] AWADDR_S,
input [`AXI_LEN_BITS-1:0] AWLEN_S,
input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
input [1:0] AWBURST_S,
input AWVALID_S,
output logic AWREADY_S,
//WRITE DATA0
input [`AXI_DATA_BITS-1:0] WDATA_S,
input [`AXI_STRB_BITS-1:0] WSTRB_S,
input WLAST_S,
input WVALID_S,
output logic WREADY_S,
//WRITE RESPONSE0
output logic[`AXI_IDS_BITS-1:0] BID_S,
output logic[1:0] BRESP_S,
output logic BVALID_S,
input BREADY_S,

//READ ADDRESS0
input [`AXI_IDS_BITS-1:0] ARID_S,
input [`AXI_ADDR_BITS-1:0] ARADDR_S,
input [`AXI_LEN_BITS-1:0] ARLEN_S,
input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
input [1:0] ARBURST_S,
input ARVALID_S,
output logic ARREADY_S,
//READ DATA0
output logic [`AXI_IDS_BITS-1:0] RID_S,
output logic[`AXI_DATA_BITS-1:0] RDATA_S,
output logic[1:0] RRESP_S,
output logic RLAST_S,
output logic RVALID_S,
input RREADY_S
);

localparam OKAY = 2'b00;
localparam SLVERR = 2'b10;

    typedef enum logic [2:0] {
        IDLE          = 3'b000,
        WRITE_ADDR    = 3'b001,
        WRITE_DATA    = 3'b010,
        WRITE_RESPONSE= 3'b011,
        READ_ADDR     = 3'b100,
        READ_DATA     = 3'b101
    } state_class;

    state_class state, next_state;

    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

logic [`AXI_IDS_BITS-1:0] BID_S_reg,RID_S_reg;
logic [3:0] cnt_ARLEN_S;
logic [3:0] ARLEN_S_reg;
logic WEB;
logic [13:0] addr_SRAM;
logic CLK,CEB;
logic [31:0] DI,DO;
logic [13:0] A;
logic [3:0] WSTRB_S_wire;
logic [31:0] BWEB;

assign BID_S=BID_S_reg;
assign RID_S=RID_S_reg;

    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            BID_S_reg <= 8'b0;
        end else if ((state==WRITE_ADDR)&&(next_state==WRITE_DATA)) begin
            BID_S_reg <= AWID_S;
        end else begin
            BID_S_reg <= BID_S_reg;
        end
    end
    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            RID_S_reg <= 8'b0;
        end else if ((state==READ_ADDR)&&(next_state==READ_DATA)) begin
            RID_S_reg <= ARID_S;
        end else begin
            RID_S_reg <= RID_S_reg;
        end
    end
    
// logic [31:0] RDATA_S_reg_tmp;                /////////有burst要改喔
// logic [31:0] RDATA_S_reg;                /////////有burst要改喔
//     always_ff @(posedge ACLK) begin
//         if (~ARESETn) begin
//             RDATA_S_reg_tmp <= 32'b0;
//         end else if (((state==READ_DATA)&&(next_state==READ_DATA))) begin
//             RDATA_S_reg_tmp <= DO;
//         end else begin
//             RDATA_S_reg_tmp <= RDATA_S_reg_tmp;
//         end
//     end
// // assign RDATA_S_reg=RDATA_S_reg_tmp;
// logic obsrve_wire;
// assign obsrve_wire=(state==IDLE)&&(next_state==IDLE);
// assign RDATA_S_reg=(obsrve_wire)?RDATA_S_reg_tmp:DO;
// assign RDATA_S_reg=((state==READ_DATA))?DO:RDATA_S_reg_tmp;

    always_comb begin
        case (state)
            IDLE: begin
                if (ARVALID_S) begin
                  next_state = READ_ADDR;
                end else if (AWVALID_S) begin
                  next_state = WRITE_ADDR;
                end  else begin
                  next_state = IDLE;
                end
            end
            WRITE_ADDR: begin
                if (AWVALID_S && AWREADY_S) begin
                  next_state = WRITE_DATA;
                end else begin
                  next_state = WRITE_ADDR;
                end
            end
            WRITE_DATA: begin
                if (WVALID_S && WREADY_S && WLAST_S) begin
                  next_state = WRITE_RESPONSE;
                end else begin
                  next_state = WRITE_DATA;
                end
            end
            WRITE_RESPONSE: begin
                if (BREADY_S && BVALID_S) begin
                    next_state = IDLE;
                end else begin
                  next_state = WRITE_RESPONSE;
                end
            end
            READ_ADDR: begin
                if (ARVALID_S && ARREADY_S) begin
                  next_state = READ_DATA;
                end else begin
                  next_state = READ_ADDR;
                end
            end
            READ_DATA: begin
                if (RREADY_S && RVALID_S && RLAST_S) begin
                    next_state = IDLE;
                end else begin
                  next_state = READ_DATA;
                end
            end
            default: next_state = IDLE;
        endcase
    end



    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            cnt_ARLEN_S <= 4'b0;
        end else if (((state==READ_DATA) && (next_state==READ_DATA))) begin 
            if (RREADY_S && RVALID_S) begin
                cnt_ARLEN_S <= cnt_ARLEN_S + 4'b1; 
            end else begin
                cnt_ARLEN_S <= cnt_ARLEN_S; 
            end
        end else begin
            cnt_ARLEN_S <= 4'b0;
        end
    end

    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            ARLEN_S_reg <= 4'b0;
        end else if ((state==READ_ADDR)&&(next_state==READ_DATA)) begin
            ARLEN_S_reg <= ARLEN_S;
        end else begin
            ARLEN_S_reg <= ARLEN_S_reg;
        end
    end

logic [31:0] AWADDR_S_reg;                
    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            AWADDR_S_reg <= 32'b0;
        end else if (((state==IDLE)&&(next_state==WRITE_ADDR))) begin
            AWADDR_S_reg <= AWADDR_S;
        end else begin
            AWADDR_S_reg <= AWADDR_S_reg;
        end
    end
logic [31:0] ARADDR_S_reg;                
    always_ff @(posedge ACLK) begin
        if (~ARESETn) begin
            ARADDR_S_reg <= 32'b0;
        end else if (((state==IDLE)&&(next_state==READ_ADDR))) begin
            ARADDR_S_reg <= ARADDR_S;
        end else begin
            ARADDR_S_reg <= ARADDR_S_reg;
        end
    end


    always_comb begin
          case (state)
                IDLE: begin
                    AWREADY_S =1'b0;
                    WREADY_S  =1'b0;
                    BVALID_S  =1'b0;
                    ARREADY_S =1'b0;
                    RLAST_S   =1'b0;
                    RVALID_S  =1'b0;
                    RRESP_S   =SLVERR;
                    BRESP_S   =SLVERR;
                    //SRAM
                    WEB       =1'b1;//不能寫
                    addr_SRAM =14'b0;
                end
                WRITE_ADDR: begin
                    AWREADY_S =1'b1;
                    WREADY_S  =1'b0;
                    BVALID_S  =1'b0;
                    ARREADY_S =1'b0;
                    RLAST_S   =1'b0;
                    RVALID_S  =1'b0;
                    RRESP_S   =SLVERR;
                    BRESP_S   =OKAY;
                    //SRAM
                    WEB       =1'b1;//不能寫
                    addr_SRAM =AWADDR_S_reg[15:2];
                end
                WRITE_DATA: begin
                    AWREADY_S =1'b0;
                    WREADY_S  =1'b1;
                    BVALID_S  =1'b0;
                    ARREADY_S =1'b0;
                    RLAST_S   =1'b0;
                    RVALID_S  =1'b0;
                    RRESP_S   =SLVERR;
                    BRESP_S   =SLVERR;
                    //SRAM
                    WEB       =1'b0;//可以寫
                    addr_SRAM =AWADDR_S_reg[15:2];
                end
                WRITE_RESPONSE: begin
                    AWREADY_S =1'b0;
                    WREADY_S  =1'b0;
                    BVALID_S  =1'b1;
                    ARREADY_S =1'b0;
                    RLAST_S   =1'b0;
                    RVALID_S  =1'b0;
                    RRESP_S   =SLVERR;
                    BRESP_S   =OKAY;
                    //SRAM
                    WEB       =1'b1;//不能寫
                    addr_SRAM =14'b0;
                end
                READ_ADDR: begin
                    AWREADY_S =1'b0;
                    WREADY_S  =1'b0;
                    BVALID_S  =1'b0;
                    ARREADY_S =1'b1;
                    RLAST_S   =1'b0;
                    RVALID_S  =1'b0;
                    RRESP_S   =SLVERR;
                    BRESP_S   =OKAY;
                    //SRAM
                    WEB       =1'b1;//不能寫
                    addr_SRAM =ARADDR_S_reg[15:2];
                end
                READ_DATA: begin
                    AWREADY_S =1'b0;
                    WREADY_S  =1'b0;
                    BVALID_S  =1'b0;
                    ARREADY_S =1'b0;
                    if (cnt_ARLEN_S == ARLEN_S_reg) begin
                        RLAST_S   =1'b1;
                    end else begin
                        RLAST_S   =1'b0;
                    end
                    RVALID_S  =1'b1;
                    RRESP_S   =OKAY;
                    BRESP_S   =SLVERR;
                    //SRAM
                    WEB       =1'b1;//不能寫
                    addr_SRAM =ARADDR_S_reg[15:2];
                end
                default: begin
                    AWREADY_S =1'b0;
                    WREADY_S  =1'b0;
                    BVALID_S  =1'b0;
                    ARREADY_S =1'b0;
                    RLAST_S   =1'b0;
                    RVALID_S  =1'b0;
                    RRESP_S   =SLVERR;
                    BRESP_S   =SLVERR;
                    //SRAM
                    WEB       =1'b1;//不能寫
                    addr_SRAM =14'b0;
                end
          endcase
        end


assign WSTRB_S_wire = ~ WSTRB_S;
assign BWEB = {{8{WSTRB_S_wire[3]}},{8{WSTRB_S_wire[2]}},{8{WSTRB_S_wire[1]}},{8{WSTRB_S_wire[0]}}};



assign CLK=ACLK;
assign CEB=1'b0;
assign A=addr_SRAM;
assign DI=WDATA_S;
// assign RDATA_S=RDATA_S_reg;
assign RDATA_S=DO;

  TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
    .SLP(1'b0),
    .DSLP(1'b0),
    .SD(1'b0),
    .PUDELAY(),
    .CLK(CLK),
	.CEB(CEB),
	.WEB(WEB),
    .A(A),
	.D(DI),
    .BWEB(BWEB),
    .RTSEL(2'b01),
    .WTSEL(2'b01),
    .Q(DO)
);

endmodule


