module Load_Use_detection (
    input  [1:0] M0_state,
    input  [6:0] lud_opcode,
    input  [4:0] lud_IF_addr1,
    input  [4:0] lud_IF_addr2,
    input  [4:0] lud_ID_addr,
    output logic lud_ID_EX_nop,
    output logic lud_IF_ID_maintain
);
    


always_comb begin
    if (((lud_opcode==`LOAD)||(lud_opcode==`FLW))&&
        ((lud_IF_addr1==lud_ID_addr)||(lud_IF_addr2==lud_ID_addr))) begin
        lud_ID_EX_nop=1'b1;
        lud_IF_ID_maintain=1'b1;      
    end 
    else begin
        lud_ID_EX_nop=1'b0;
        lud_IF_ID_maintain=1'b0;
    end
end


endmodule