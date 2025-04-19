module Branch_Jump (
    input   [31:0] bj_in1,
    input   [31:0] bj_in2,
    input   [ 2:0] bj_sel,
    input   [ 2:0] bj_func3,
    input   [ 6:0] bj_opcode,
    output  logic  bj_pc_sel      //bj_pc_sel=0 :PC+4
);                                //bj_pc_sel=1 :ALU


logic bj_equal,bj_less_than;

always_comb begin
    if ((bj_func3==3'b100)||(bj_func3==3'b101)) begin
        if ($signed(bj_in1) < $signed(bj_in2)) begin
        bj_equal = 1'b0;
        bj_less_than = 1'b1;
    end else begin
        bj_equal = 1'b0;
        bj_less_than = 1'b0;
    end
    end else begin
        if (bj_in1 == bj_in2) begin
        bj_equal = 1'b1;
        bj_less_than = 1'b0;
    end else if (bj_in1 < bj_in2) begin
        bj_equal = 1'b0;
        bj_less_than = 1'b1;
    end else begin
        bj_equal = 1'b0;
        bj_less_than = 1'b0;
    end
    end
    
end

logic [1:0] a ;
assign a= {bj_equal,bj_less_than};

always_comb begin
    if ((bj_opcode==`B_TYPE)||(bj_opcode==`JAL)||(bj_opcode==`JALR)) begin
        case (bj_sel)
        3'b000: bj_pc_sel=(bj_equal)?1'b1:1'b0;//BEQ      
        3'b001: bj_pc_sel=(bj_equal)?1'b0:1'b1;//BNE     
   
        3'b011: bj_pc_sel = 1'b1;           //J
        3'b100: bj_pc_sel=(bj_less_than)?1'b1:1'b0;    //BLT
        3'b101: bj_pc_sel=(a ==2'b01)?1'b0:1'b1;       //BGE,
        3'b110: bj_pc_sel=(bj_less_than)?1'b1:1'b0;    //BLTU 
        3'b111: bj_pc_sel=(a ==2'b01)?1'b0:1'b1;       //BGEU
        default: bj_pc_sel = 1'b0;  //NO //3'b010 
        endcase
    end else begin
        bj_pc_sel = 1'b0;
    end
end

endmodule