module D_SRAM_wrapper (
input clk,
input rst,
// input lud_IF_ID_maintain_M1,
output logic AXI_stall_M1,
input [31:0] AXI_Give_Data_mem_BWEB,  //影響output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
input [1:0] Give_read_write_EXE,
input [31:0] Give_Data_mem_value,
input [31:0] Give_Data_mem_addr,
//READ ADDRESS1
input ARREADY_M1,
output [`AXI_ID_BITS-1:0] ARID_M1,
output [`AXI_LEN_BITS-1:0] ARLEN_M1,
output [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
output [1:0] ARBURST_M1,
output logic ARVALID_M1,
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
output logic BREADY_M1,
output logic M1_first,
output logic [31:0] ARADDR_M1,
output logic [31:0] AWADDR_M1,
output logic [31:0] RDATA_M1_out,
output logic [3:0] M1_state

);

localparam OKAY = 2'b00;

    typedef enum logic [3:0] {
        IDLE                = 4'b0000,
        WRITE_ADDR          = 4'b0001,
        WRITE_ADDR_STABLE   = 4'b0010,WRITE_ADDR_STABLE2 = 4'b1001,WRITE_ADDR_STABLE3 = 4'b1010,
        WRITE_DATA          = 4'b0011,
        WRITE_RESP_STABLE   = 4'b0100,
        WRITE_RESP          = 4'b0101,
        READ_ADDR           = 4'b0110,
        READ_ADDR_STABLE    = 4'b0111,
        READ_DATA           = 4'b1000
    } state_class;

    state_class state, next_state;

logic [3:0] WSTRB_M1_wire;
logic [31:0] WDATA_M1_reg;
logic [3:0] WSTRB_M1_reg;

assign ARID_M1 = 4'b0;
assign ARLEN_M1= 4'b0;
assign ARSIZE_M1= 3'b010;
assign ARBURST_M1=2'b01;
assign AWID_M1 = 4'b0;
assign AWLEN_M1= 4'b0;
assign AWSIZE_M1= 3'b010;
assign AWBURST_M1=2'b01;

assign M1_state=state;

always_ff @(posedge clk) begin
        if (~rst) begin
            M1_first <= 1'b0;
        end 
        else if (state==READ_ADDR_STABLE && next_state==READ_DATA) begin
            M1_first <= 1'b1;
        end 
        else begin
		    M1_first <= 1'b0;
	    end
    end


logic [31:0] ARADDR_M1_reg,AWADDR_M1_reg;

always_ff @(posedge clk) begin
    if (~rst) begin
        ARADDR_M1_reg <= 32'b0;
    end 
    else if (state==IDLE && next_state==READ_ADDR) begin
        ARADDR_M1_reg <= Give_Data_mem_addr;
    end 
    else begin
        ARADDR_M1_reg <= ARADDR_M1_reg;
    end
end
always_ff @(posedge clk) begin
    if (~rst) begin
        AWADDR_M1_reg <= 32'b0;
    end 
    else if (state==IDLE && next_state==WRITE_ADDR) begin
        AWADDR_M1_reg <= Give_Data_mem_addr;
    end 
    else begin
        AWADDR_M1_reg <= AWADDR_M1_reg;
    end
end

assign ARADDR_M1=ARADDR_M1_reg;
assign AWADDR_M1=AWADDR_M1_reg;


        always_comb begin
            case (state)
            IDLE: begin  //IDLE
                AXI_stall_M1   =1'b0;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            WRITE_ADDR: begin
                AXI_stall_M1   =1'b1;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b1;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            WRITE_ADDR_STABLE,WRITE_ADDR_STABLE2,WRITE_ADDR_STABLE3: begin
                AXI_stall_M1   =1'b1;////////////////////
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            WRITE_DATA: begin
                AXI_stall_M1   =1'b1;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b1;
                BREADY_M1   =1'b0;
                WSTRB_M1    =WSTRB_M1_reg;
                WLAST_M1    =1'b1;
            end
            WRITE_RESP_STABLE: begin
                AXI_stall_M1   =1'b1;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            WRITE_RESP: begin
                AXI_stall_M1   =1'b0;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b1;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            READ_ADDR: begin
                AXI_stall_M1   =1'b1;
                ARVALID_M1  =1'b1;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            READ_ADDR_STABLE: begin
                AXI_stall_M1   =1'b1;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            READ_DATA: begin
                AXI_stall_M1   =1'b0;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b1;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            default: begin
                AXI_stall_M1   =1'b0;
                ARVALID_M1  =1'b0;
                RREADY_M1   =1'b0;
                AWVALID_M1  =1'b0;
                WVALID_M1   =1'b0;
                BREADY_M1   =1'b0;
                WSTRB_M1    =4'b1111;
                WLAST_M1    =1'b0;
            end
            endcase
        end

    always_comb begin
        case (state)
            IDLE: begin
                if (Give_read_write_EXE==2'b10) begin
                    next_state = READ_ADDR;
                end else if (Give_read_write_EXE==2'b11) begin
                    next_state = WRITE_ADDR;
                end else begin
                    next_state = IDLE;//00
                end
            end
            WRITE_ADDR: begin
                if (AWREADY_M1 && AWVALID_M1) begin
                    next_state = WRITE_ADDR_STABLE;
                end else begin
                    next_state = WRITE_ADDR;
                end
            end
            WRITE_ADDR_STABLE: begin
                next_state = WRITE_ADDR_STABLE2;
            end
            WRITE_ADDR_STABLE2: begin
                next_state = WRITE_ADDR_STABLE3;
            end
            WRITE_ADDR_STABLE3: begin
                next_state = WRITE_DATA;
            end
            WRITE_DATA: begin
                if (WREADY_M1 && WVALID_M1 && WLAST_M1) begin
                    next_state = WRITE_RESP_STABLE;
                end else begin
                    next_state = WRITE_DATA;
                end
            end
            WRITE_RESP_STABLE: begin
                next_state = WRITE_RESP;
            end
            WRITE_RESP: begin
                // if (BVALID_M1 && BREADY_M1 && (BRESP_M1==OKAY) && (Give_read_write_EXE==2'b10)) begin
                //     next_state = READ_ADDR;
                // end else 
                if (BVALID_M1 && BREADY_M1 && (BRESP_M1==OKAY)) begin 
                    next_state = IDLE;
                end else begin
                    next_state = WRITE_RESP;
                end
            end
            READ_ADDR: begin
                if (ARREADY_M1 && ARVALID_M1) begin
                    next_state = READ_ADDR_STABLE;
                end else begin
                    next_state = READ_ADDR;
                end
            end
            READ_ADDR_STABLE: begin
                next_state = READ_DATA;
            end
            READ_DATA: begin
                // if (RREADY_M1 && RVALID_M1 && RLAST_M1 && (RRESP_M1==OKAY) && (Give_read_write_EXE==2'b10)) begin
                //     next_state = READ_ADDR;
                // end else 
                if (RREADY_M1 && RVALID_M1 && RLAST_M1 && (RRESP_M1==OKAY)) begin 
                    next_state = IDLE;
                end else begin
                    next_state = READ_DATA;
                end
            end
            default: next_state = IDLE;
        endcase
    end

assign WSTRB_M1_wire = {~AXI_Give_Data_mem_BWEB[31],~AXI_Give_Data_mem_BWEB[23],~AXI_Give_Data_mem_BWEB[15],~AXI_Give_Data_mem_BWEB[7]};

    // always_comb begin
    //     if (AXI_Give_Data_mem_BWEB=={8'b0,{24{1'b1}}}) begin//SB
    //         WSTRB_M1_wire=4'b1000;
    //     end else if (AXI_Give_Data_mem_BWEB=={{8{1'b1}},8'b0,{16{1'b1}}}) begin//SB
    //         WSTRB_M1_wire=4'b0100;
    //     end else if (AXI_Give_Data_mem_BWEB=={{16{1'b1}},8'b0,{8{1'b1}}}) begin//SB
    //         WSTRB_M1_wire=4'b0010;
    //     end else if (AXI_Give_Data_mem_BWEB=={{24{1'b1}},8'b0}) begin//SB
    //         WSTRB_M1_wire=4'b0001;
    //     end else if (AXI_Give_Data_mem_BWEB=={16'b0,{16{1'b1}}}) begin//SH
    //         WSTRB_M1_wire=4'b1100;
    //     end else if (AXI_Give_Data_mem_BWEB=={{16{1'b1}},16'b0}) begin//SH
    //         WSTRB_M1_wire=4'b0011;
    //     end else begin
    //         WSTRB_M1_wire=4'b1111;
    //     end
    // end

    always_ff @(posedge clk) begin
        if (~rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk) begin
        if (~rst) begin
            WDATA_M1_reg <= 32'b0;
        end  
        else if (state==IDLE && next_state==WRITE_ADDR) begin
            WDATA_M1_reg <= Give_Data_mem_value;
        end 
        else begin
		WDATA_M1_reg <= WDATA_M1_reg;
	end
end

assign WDATA_M1=WDATA_M1_reg;


    always_ff @(posedge clk) begin
        if (~rst) begin
            WSTRB_M1_reg <= 4'b0;
        end 
        else if (state==WRITE_ADDR_STABLE3 && next_state==WRITE_DATA) begin
            WSTRB_M1_reg <= WSTRB_M1_wire;
        end 
        else begin
		    WSTRB_M1_reg <= WSTRB_M1_reg;
	end
    end


always_ff @(posedge clk) begin
    if (~rst) begin
        RDATA_M1_out <= 32'b0;
    end 
    else if (state==READ_ADDR_STABLE && next_state==READ_DATA) begin
        RDATA_M1_out <= RDATA_M1;
    end 
    else begin
        RDATA_M1_out <= RDATA_M1_out;
    end
end



endmodule
