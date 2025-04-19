module pc (
    input  clk,
    input  rst,
    input  [31:0] pc_in,
    input  pc_maintain,
    output logic [31:0] pc_out
);
    

always_ff @(posedge clk) begin
    if (rst) begin
        pc_out<=32'b0;
    end 
    else if (pc_maintain) begin
        pc_out<=pc_out;
    end 
    else begin
        pc_out<=pc_in;
    end
end

endmodule