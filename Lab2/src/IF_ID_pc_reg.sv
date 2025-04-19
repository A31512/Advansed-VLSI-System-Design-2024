module IF_ID_pc_reg (
    input clk,
    input rst,
    input  bj_flush,
    input  load_use_maintain,
    input  [31:0] pc_in_if_i,
    output logic [31:0] IF_ID_pc_reg
);

always_ff @(posedge clk) begin
    if (rst) begin
        IF_ID_pc_reg <= 32'b0;
    end 
    else if (load_use_maintain) begin
        IF_ID_pc_reg <= IF_ID_pc_reg;
    end 
    else if (bj_flush) begin
        IF_ID_pc_reg <= 32'b0;
    end 
    else begin
        IF_ID_pc_reg <= pc_in_if_i;
    end
end

endmodule