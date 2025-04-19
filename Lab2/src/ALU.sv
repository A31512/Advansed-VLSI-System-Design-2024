module ALU (
    input   [31:0] alu_in1,
    input   [31:0] alu_in2,
    input   [ 4:0] alu_sel,
    input   [ 6:0] alu_opcode,
    output logic [31:0] alu_out
);

logic [31:0] alu_out_wire,in1,in2;
logic [31:0] complement_1,complement_2,alu_out_wire_normalize;
logic [ 7:0] sum_exp;
logic [22:0] sum_frac;
logic [ 4:0] shift_normalize;

always_comb begin 
    case (alu_sel)
        // ADD: result = in1 + in2;                
        `SUB : alu_out_wire = in1 - in2;                  
        `SLL : alu_out_wire = in1 << in2[4:0];             
        `SLT : alu_out_wire = ($signed(in1)<$signed(in2))?32'b1:32'b0; 
        `SLTU: alu_out_wire = (in1<in2)?32'b1:32'b0; 
        `XOR : alu_out_wire = in1 ^ in2;                  
        `SRL : alu_out_wire = in1 >> in2[4:0];             
        `SRA : alu_out_wire = $signed(in1) >>> in2[4:0];   
        `OR  : alu_out_wire = in1 | in2;                   
        `AND : alu_out_wire = in1 & in2;                  


        // 5'b00001: result = in1          * in2;          //MUL
        // 5'b00101: result = $signed(in1) * $signed(in2); //MULH
        // 5'b01001: result = $signed(in1) * in2;          //MULHSU
        // 5'b01101: result = in1          * $signed(in2); //MULHU

        // `FADD: result = 
        // `FSUB: result = 

        // 5'b11001:沒用到
        // 5'b11101:沒用到

        default: alu_out_wire = in1 + in2;           //ADD + FADD + FSUB
    endcase
end

always_comb begin
    if (alu_opcode==`JALR) begin
        alu_out = alu_out_wire & (~32'b1);
    end else if (alu_opcode==`F_TYPE) begin
            if (shift_normalize==5'd30) begin
                alu_out = 32'b0;
            end else begin
                alu_out = {alu_out_wire[31],sum_exp,sum_frac};
            end
    end else begin
        alu_out = alu_out_wire;
    end
end


always_comb begin
    if (alu_opcode==`F_TYPE) begin
        in1=complement_1;
        in2=complement_2;
    end else begin
        in1=alu_in1;
        in2=alu_in2;
    end
end


//swap
logic       sign_1,sign_2;
logic [7:0] exp_1,exp_2;
logic [31:0] frac_1,frac_2;
always_comb begin
    if (alu_in1[30:23]>=alu_in2[30:23]) begin
        sign_1=alu_in1[31]; 
        exp_1 =alu_in1[30:23];
        frac_1={3'b001,alu_in1[22:0],6'b000000};

        sign_2=(alu_sel[2]==1'b1)?~alu_in2[31]:alu_in2[31];
        exp_2 =alu_in2[30:23];
        frac_2={3'b001,alu_in2[22:0],6'b000000}; 

    end else begin
        sign_1=alu_in2[31];
        exp_1 =alu_in2[30:23];
        frac_1={3'b001,alu_in2[22:0],6'b000000};

        sign_2=(alu_sel[2]==1'b1)?~alu_in1[31]:alu_in1[31];
        exp_2 =alu_in1[30:23];
        frac_2={3'b001,alu_in1[22:0],6'b000000};
    end
end
//shift
logic [ 7:0] shift_amount;
logic [31:0] in_smaller_shift;
assign shift_amount = exp_1 - exp_2;
assign in_smaller_shift = frac_2>>shift_amount;
//complement
assign complement_1=(sign_1==1'b1)?(~frac_1)+32'b1          :frac_1;
assign complement_2=(sign_2==1'b1)?(~in_smaller_shift)+32'b1:in_smaller_shift;
//normalize
assign alu_out_wire_normalize=(alu_out_wire[31]==1'b1)?~alu_out_wire+32'b1:alu_out_wire;
assign sum_exp =(alu_out_wire_normalize[30]==1'b1)?exp_1+8'b1:exp_1-{3'b0,shift_normalize};


logic [31:0]alu_out_normalize_shift_wire;
assign alu_out_normalize_shift_wire=alu_out_wire_normalize<<shift_normalize;

always_comb begin
    if (alu_out_wire_normalize[30]==1'b1) begin
        if (alu_out_wire_normalize[5]==1'b1) begin
            sum_frac=alu_out_wire_normalize[29:7]+23'b1;
        end else begin
            sum_frac=alu_out_wire_normalize[29:7];
        end
    end else begin
        if (alu_out_normalize_shift_wire[5]==1'b1) begin
            sum_frac=alu_out_normalize_shift_wire[28:6]+23'b1;
        end else begin
            sum_frac=alu_out_normalize_shift_wire[28:6];
        end
    end
end

always_comb begin
    casez (alu_out_wire_normalize[29:0])
        30'b0000000000_0000000000_0000000001: shift_normalize = 5'd29; 
        30'b0000000000_0000000000_000000001?: shift_normalize = 5'd28; 
        30'b0000000000_0000000000_00000001??: shift_normalize = 5'd27; 
        30'b0000000000_0000000000_0000001???: shift_normalize = 5'd26; 
        30'b0000000000_0000000000_000001????: shift_normalize = 5'd25; 
        30'b0000000000_0000000000_00001?????: shift_normalize = 5'd24; 
        30'b0000000000_0000000000_0001??????: shift_normalize = 5'd23; 
        30'b0000000000_0000000000_001???????: shift_normalize = 5'd22; 
        30'b0000000000_0000000000_01????????: shift_normalize = 5'd21; 
        30'b0000000000_0000000000_1?????????: shift_normalize = 5'd20; 
        30'b0000000000_0000000001_??????????: shift_normalize = 5'd19; 
        30'b0000000000_000000001?_??????????: shift_normalize = 5'd18; 
        30'b0000000000_00000001??_??????????: shift_normalize = 5'd17; 
        30'b0000000000_0000001???_??????????: shift_normalize = 5'd16; 
        30'b0000000000_000001????_??????????: shift_normalize = 5'd15; 
        30'b0000000000_00001?????_??????????: shift_normalize = 5'd14; 
        30'b0000000000_0001??????_??????????: shift_normalize = 5'd13; 
        30'b0000000000_001???????_??????????: shift_normalize = 5'd12; 
        30'b0000000000_01????????_??????????: shift_normalize = 5'd11; 
        30'b0000000000_1?????????_??????????: shift_normalize = 5'd10; 
        30'b0000000001_??????????_??????????: shift_normalize = 5'd9; 
        30'b000000001?_??????????_??????????: shift_normalize = 5'd8; 
        30'b00000001??_??????????_??????????: shift_normalize = 5'd7; 
        30'b0000001???_??????????_??????????: shift_normalize = 5'd6; 
        30'b000001????_??????????_??????????: shift_normalize = 5'd5; 
        30'b00001?????_??????????_??????????: shift_normalize = 5'd4; 
        30'b0001??????_??????????_??????????: shift_normalize = 5'd3; 
        30'b001???????_??????????_??????????: shift_normalize = 5'd2; 
        30'b01????????_??????????_??????????: shift_normalize = 5'd1; 
        30'b1?????????_??????????_??????????: shift_normalize = 5'd0;
        default: shift_normalize = 5'd30;      //zero
    endcase
end


endmodule




