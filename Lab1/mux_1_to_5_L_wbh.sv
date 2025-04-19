module mux_1_to_5_L_wbh (
    input  [31:0] in1,
    input  [ 6:0] opcode,
    input  [ 2:0] funct3,
    output logic [31:0] out
);


always_comb begin
    if ((opcode==`LOAD)&&(funct3==3'b000)) begin//LB
        out={{24{in1[7]}},in1[7:0]};
    end else if ((opcode==`LOAD)&&(funct3==3'b001)) begin//LH
        out={{16{in1[15]}},in1[15:0]};
    end else if ((opcode==`LOAD)&&(funct3==3'b100)) begin//LBU
        out={24'b0,in1[7:0]};
    end else if ((opcode==`LOAD)&&(funct3==3'b101)) begin//LHU
        out={16'b0,in1[15:0]};
    end else begin                              //LW
        out=in1;
    end
end

endmodule