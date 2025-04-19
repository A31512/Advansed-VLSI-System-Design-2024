module IF_ID (
    input clk,
    input rst,
    input  bj_flush,
    input  load_use_IF_ID_maintain,
    input  [31:0] IF_ID_pc_reg,
    input  [31:0] instrction_SRAM_value,
    output logic [31:0] pc_in_IF,
    output logic [31:0] instrction_in_IF
);


always_ff @(posedge clk) begin
    if (rst) begin
        pc_in_IF            <= 32'b0;
        instrction_in_IF    <= 32'b0;
    end 
    else if (load_use_IF_ID_maintain) begin
        pc_in_IF            <= pc_in_IF;
        instrction_in_IF    <= instrction_in_IF;
    end 
    else if ((bj_flush)) begin
        pc_in_IF            <= 32'b0;
        instrction_in_IF    <= 32'b0;
    end
    else begin
        pc_in_IF            <= IF_ID_pc_reg;
        instrction_in_IF    <= instrction_SRAM_value;
    end
end


// logic flush_1;
// always_ff @(posedge clk) begin
//     if (rst) begin
//         flush_1<=1'b0;
//     end 
//     else if (load_use_IF_ID_maintain) begin
//         flush_1<=flush_1;
//     end 
//     else if (bj_flush) begin
//         flush_1<=1'b1;
//     end else begin
//         flush_1<=1'b0;
//     end
// end
// logic a123;
// assign a123=(bj_flush)||(flush_1);

// always_comb begin
//     if (a123) begin
//         pc_in_IF            = 32'b0;
//         instrction_in_IF    = 32'b0;
//     end else begin
//         pc_in_IF            = IF_ID_pc_reg;
//         instrction_in_IF    = instrction_SRAM_value;
//     end
// end

endmodule