module CSR (
    input        clk,
    input        rst,
    input        AXI_stall,
    input  [6:0] csr_opcode,
    input        flush,
    input        load_use_maintain,
    output logic [31:0] csr_cycle_low,
    output logic [31:0] csr_cycle_high,
    output logic [31:0] csr_instret_low,
    output logic [31:0] csr_instret_high
);

logic [63:0] csr_cycle;
logic [63:0] csr_instret;

assign csr_cycle_low   =csr_cycle  [31: 0];
assign csr_cycle_high  =csr_cycle  [63:32];
assign csr_instret_low =csr_instret[31: 0];
assign csr_instret_high=csr_instret[63:32];

always_ff @(posedge clk) begin
    if (rst) begin
        csr_cycle <= 64'b0;
    end else begin
        csr_cycle <= csr_cycle + 64'b1;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        csr_instret <= 64'd1;
    end
    else if ((!AXI_stall)&&(csr_opcode!=7'b0)&&(csr_opcode!=`CSR_TYPE)) begin
        csr_instret <= csr_instret + 64'b1;
    end
end


endmodule