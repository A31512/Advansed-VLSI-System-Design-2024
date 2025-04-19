

module I_SRAM_wrapper (
input clk,
input rst,
input M1_first,
input [31:0] RDATA_M0,
input [3:0] M1_state,
output logic [1:0] M0_state,
output logic AXI_stall_M0,
input [31:0] Give_Instruct_mem_Addr,
//READ ADDRESS0
input ARREADY_M0, 
output [`AXI_ID_BITS-1:0] ARID_M0, 
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,  
output [`AXI_LEN_BITS-1:0] ARLEN_M0,       
output [`AXI_SIZE_BITS-1:0] ARSIZE_M0,   
output [1:0] ARBURST_M0,   
output logic ARVALID_M0,   
//READ DATA0
input [`AXI_ID_BITS-1:0] RID_M0,        
input [1:0] RRESP_M0,                   
input RLAST_M0,                         
input RVALID_M0,                        
output logic RREADY_M0,                 
output logic [31:0] RDATA_M0_out                 
);

localparam OKAY = 2'b00;
localparam READ_ADDR_M1           = 4'b0110;
localparam READ_ADDR_STABLE_M1    = 4'b0111;
localparam READ_DATA_M1           = 4'b1000;

    typedef enum logic [1:0] {
        IDLE                = 2'b00,
        READ_ADDR           = 2'b01,
        READ_ADDR_STABLE    = 2'b10,
        READ_DATA           = 2'b11
    } state_class;

    state_class state, next_state;


assign M0_state=state;

    always_comb begin
        case (state)
            IDLE: begin
                if (M1_state==READ_ADDR_M1 || M1_state== READ_ADDR_STABLE_M1 || M1_state== READ_DATA_M1) begin
                    next_state = IDLE;
                end else begin
                    next_state = READ_ADDR;
                end
            end
            READ_ADDR: begin
                if (ARREADY_M0 && ARVALID_M0) begin
                    next_state = READ_ADDR_STABLE;
                end else begin
                    next_state = READ_ADDR;
                end
            end
            READ_ADDR_STABLE: next_state = READ_DATA;
            READ_DATA: begin
                if (RREADY_M0 && RVALID_M0 && RLAST_M0 && (RRESP_M0==OKAY)) begin
                    next_state = IDLE;
                end else begin
                    next_state = READ_DATA;
                end
            end
            default: next_state = IDLE;
        endcase
    end



assign ARID_M0 = 4'b0;
assign ARLEN_M0= 4'b0;
assign ARSIZE_M0= 3'b010;
assign ARBURST_M0=2'b01;

    always_comb begin
        case (state)
            IDLE: begin
                ARVALID_M0=1'b0;
                AXI_stall_M0=(M1_first)?1'b0:1'b1;
                RREADY_M0=1'b0;
            end
            READ_ADDR: begin
                ARVALID_M0=1'b1;
                AXI_stall_M0=1'b1;
                RREADY_M0=1'b0;
            end
            READ_ADDR_STABLE: begin
                ARVALID_M0=1'b0;
                AXI_stall_M0=1'b1;
                RREADY_M0=1'b0;
            end
            READ_DATA: begin
                ARVALID_M0=1'b0;
                AXI_stall_M0=1'b0;
                RREADY_M0=1'b1;
            end
            default: begin
                ARVALID_M0=1'b0;
                AXI_stall_M0=1'b1;
                RREADY_M0=1'b0;
            end 
        endcase
    end


    always_ff @(posedge clk) begin
        if (~rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

logic [31:0] ARADDR_M0_reg;

always_ff @(posedge clk) begin
    if (~rst) begin
        ARADDR_M0_reg <= 32'b0;
    end 
    else if (state==IDLE && next_state==READ_ADDR) begin
        ARADDR_M0_reg <= Give_Instruct_mem_Addr;
    end 
    else begin
        ARADDR_M0_reg <= ARADDR_M0_reg;
    end
end
assign ARADDR_M0=ARADDR_M0_reg;

// assign ARADDR_M0=Give_Instruct_mem_Addr;


// assign RDATA_M0_out=RDATA_M0;

always_ff @(posedge clk) begin
    if (~rst) begin
        RDATA_M0_out <= 32'b0;
    end 
    else if (state==READ_ADDR_STABLE && next_state==READ_DATA) begin
        RDATA_M0_out <= RDATA_M0;
    end 
    else begin
        RDATA_M0_out <= RDATA_M0_out;
    end
end




endmodule
