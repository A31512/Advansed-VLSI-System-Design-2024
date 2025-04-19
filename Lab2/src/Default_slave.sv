module Default_slave(
    input ACLK,
    input ARESETn,
    input [7:0] AWID_DS,
    input       AWVALID_DS,
    input       WVALID_DS,
    input       BREADY_DS,
    input [7:0] ARID_DS,
    input       ARVALID_DS,
    input       RREADY_DS,

    output logic [7:0] BID_DS,
    output logic       ARREADY_DS,
    output logic       BVALID_DS,
    output logic       WREADY_DS,
    output logic       AWREADY_DS,
    output logic [7:0] RID_DS,
    output logic       RVALID_DS
);

// Parameters for state encoding
parameter R_DS = 1'd0, R_DATA = 1'd1;
parameter W_DS = 2'd0, W_DATA = 2'd1, W_RESP = 2'd2;

// State registers
logic R_current_state, R_next_state;
logic [1:0] W_current_state, W_next_state;
logic [7:0] RID, next_RID;
logic [7:0] BID, next_BID;

// Sequential logic for state and data update on clock edge or reset
always_ff @(posedge ACLK or negedge ARESETn) begin
    if (~ARESETn) begin
        R_current_state <= R_DS;
        W_current_state <= W_DS;
        RID <= 8'd0;
        BID <= 8'd0;
    end else begin
        R_current_state <= R_next_state;
        W_current_state <= W_next_state;
        RID <= next_RID;
        BID <= next_BID;    
    end
end

//for read

// Next-state logic for Read
always_comb begin
    case(R_current_state)
        R_DS:  R_next_state = (ARVALID_DS) ? R_DATA : R_DS;
        R_DATA:  R_next_state = (RREADY_DS) ? R_DS : R_DATA;
    endcase
end

// Output and action logic for Read
always_comb begin
    case(R_current_state)
        R_DS: begin
            ARREADY_DS = 1'b1;                  // Ready to accept a read address
            next_RID = (ARVALID_DS) ? ARID_DS : RID; // Capture ARID if valid
            RID_DS = 8'd0;                      // No data to output yet
            RVALID_DS = 1'b0;                   // Data is not valid
        end
        R_DATA: begin
            ARREADY_DS = 1'b0;                  // Stop accepting addresses
            next_RID = RID;                        // Keep currentent RID
            RID_DS = RID;                       // Output captured RID as data ID
            RVALID_DS = 1'b1;                   // Data is now valid
        end
    endcase
end

//for write

// Next-state logic for Write
always_comb begin
    case(W_current_state)
        W_DS:  W_next_state = (AWVALID_DS) ? W_DATA : W_DS;
        W_DATA:  W_next_state = (WVALID_DS) ? W_RESP : W_DATA;
        W_RESP:  W_next_state = (BREADY_DS) ? W_DS : W_RESP;
        default: W_next_state = W_DS;
    endcase
end

// Output and action logic for Write
always_comb begin
    case(W_current_state)
        W_DS: begin
            AWREADY_DS = 1'b1;                // Ready to accept a write address
            next_BID = (AWVALID_DS) ? AWID_DS : BID; // Capture AWID if valid
            WREADY_DS = 1'b0;                 // Not ready for data yet
            BID_DS = 8'b0;                    // No response ID yet
            BVALID_DS = 1'b0;                 // Response is not valid
        end
        W_DATA: begin
            AWREADY_DS = 1'b1;                // Keep accepting addresses
            next_BID = (AWVALID_DS) ? AWID_DS : BID; // Update BID if new address arrives
            WREADY_DS = 1'b1;                 // Ready to accept data
            BID_DS = 8'b0;                    // No response ID yet
            BVALID_DS = 1'b0;                 // Response is not valid
        end
        W_RESP: begin
            AWREADY_DS = 1'b0;                // Stop accepting addresses
            next_BID = BID;                      // Keep currentent BID
            WREADY_DS = 1'b0;                 // Stop accepting data
            BID_DS = BID;                     // Output captured BID as response ID
            BVALID_DS = 1'b1;                 // Response is now valid
        end
        default: begin
            AWREADY_DS = 1'b0;                // Default no address ready
            next_BID = 8'b0;
            WREADY_DS = 1'b0;
            BID_DS = 8'b0;
            BVALID_DS = 1'b0;
        end
    endcase
end

endmodule
