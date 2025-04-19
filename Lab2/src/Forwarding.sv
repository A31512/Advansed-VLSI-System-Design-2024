module Forwarding (
    input [4:0] fwrd_ID_reg1,//INST[19:15]
    input [4:0] fwrd_ID_reg2,//INST[24:20]
    input [6:0] fwrd_opcode_ID,
    input [1:0] op1_sel,
    input [1:0] op2_sel,
    input [4:0] fwrd_WB_addr, //rd
    input [4:0] fwrd_MEM_addr,//rd
    input [4:0] fwrd_EXE_addr,//rd

    input reg_write_en_EXE,
    input reg_write_en_MEM,
    input reg_write_en_WB,
    
    input [6:0] fwrd_opcode_EXE,
    input [6:0] fwrd_opcode_MEM,
    // input [6:0] fwrd_opcode_WB,


    output logic            fwrd_LUI_1,
    output logic            fwrd_LUI_2,

    output logic       fwrd_data1_ID_sel,
    output logic       fwrd_data2_ID_sel,
    output logic [1:0] fwrd_data1_ALU_sel,
    output logic [1:0] fwrd_data2_ALU_sel,
    output logic [1:0] fwrd_data1_BJ_sel,
    output logic [1:0] fwrd_data2_BJ_sel,
    output logic [1:0] fwrd_data3_MID_sel,
    output logic       fwrd_data_MEM_sel);


always_comb begin
    if ((((reg_write_en_EXE)||(fwrd_opcode_ID==`STORE)||(fwrd_opcode_ID==`FSW)))&&  
        (fwrd_EXE_addr!=5'b0)&&
        (fwrd_ID_reg1==fwrd_EXE_addr)&&
        ((fwrd_opcode_ID!=`JAL)&&(fwrd_opcode_ID!=`JALR)&&(fwrd_opcode_ID!=`AUPIC)&&(fwrd_opcode_ID!=`LUI))
        &&(fwrd_opcode_EXE==`LUI)
        )  begin
        fwrd_LUI_1=1'b1;
    end else begin
        fwrd_LUI_1=1'b0;
    end
end
always_comb begin
    if ((reg_write_en_EXE)&&
        (fwrd_EXE_addr!=5'b0)&&
        (fwrd_ID_reg2==fwrd_EXE_addr)&&
        (fwrd_opcode_ID!=`JAL)&&(fwrd_opcode_ID!=`JALR)&&(fwrd_opcode_ID!=`AUPIC)&&(fwrd_opcode_ID!=`LUI)
        
        // &&(fwrd_opcode_ID!=`I_TYPE)

        &&(fwrd_opcode_ID!=`STORE)&&(fwrd_opcode_ID!=`FSW)
        &&(fwrd_opcode_EXE==`LUI)
        ) begin
        fwrd_LUI_2=1'b1;
    end else begin
        fwrd_LUI_2=1'b0;
    end
end

always_comb begin                     
    if ((((reg_write_en_EXE)||(fwrd_opcode_ID==`STORE)||(fwrd_opcode_ID==`FSW)))&&  
        (fwrd_EXE_addr!=5'b0)&&       (fwrd_opcode_ID!=`B_TYPE)&&  (fwrd_ID_reg1!=5'd0)&&
        
        ((fwrd_opcode_EXE!=`F_TYPE)||(fwrd_opcode_MEM!=`I_TYPE))&& //prog6

        (fwrd_ID_reg1==fwrd_EXE_addr)&&
        ((fwrd_opcode_ID!=`JAL)&&(fwrd_opcode_ID!=`AUPIC)&&(fwrd_opcode_ID!=`LUI)))     
        fwrd_data1_ALU_sel=2'd3;//EXE-->EXE

    else if((reg_write_en_MEM)&&  (fwrd_opcode_ID!=`B_TYPE)&&  (fwrd_ID_reg1!=5'd0)&&
            (fwrd_MEM_addr!=5'b0)&&
            (fwrd_ID_reg1==fwrd_MEM_addr)
            &&
            ((fwrd_opcode_ID!=`JAL)&&(fwrd_opcode_ID!=`AUPIC)
            &&(fwrd_opcode_ID!=`LUI))) fwrd_data1_ALU_sel=2'd2; //MEM-->EXE

    else fwrd_data1_ALU_sel=op1_sel;

end
always_comb begin
    if ((reg_write_en_EXE)&&   ((fwrd_opcode_ID!=`FSW)&&(fwrd_opcode_ID!=`FLW))&&
        (fwrd_EXE_addr!=5'b0)&&   (fwrd_opcode_ID!=`B_TYPE)&& (fwrd_ID_reg1!=5'd0)&&

       

        ((fwrd_opcode_ID!=`F_TYPE)||(fwrd_opcode_EXE!=`I_TYPE)||(fwrd_opcode_MEM!=`LUI))&& //prog6


        (fwrd_ID_reg2==fwrd_EXE_addr)&&
        ((fwrd_opcode_ID!=`JAL)&&(fwrd_opcode_ID!=`JALR)&&(fwrd_opcode_ID!=`AUPIC)
        &&(fwrd_opcode_ID!=`LUI)&&(fwrd_opcode_ID!=`I_TYPE))&&
        (fwrd_opcode_ID!=`STORE)&&(fwrd_opcode_ID!=`FSW)&&(fwrd_opcode_ID!=`B_TYPE))       
        fwrd_data2_ALU_sel=2'd3;

    else if ((reg_write_en_MEM)&&   ((fwrd_opcode_ID!=`FSW)&&(fwrd_opcode_ID!=`FLW))&&
             (fwrd_MEM_addr!=5'b0)&&   (fwrd_opcode_ID!=`B_TYPE)&& (fwrd_ID_reg1!=5'd0)&&

             ((fwrd_opcode_ID!=`F_TYPE)||(fwrd_opcode_EXE!=`I_TYPE))&& //prog6

             (fwrd_ID_reg2==fwrd_MEM_addr)&&
             ((fwrd_opcode_ID!=`JAL)&&(fwrd_opcode_ID!=`JALR)
             &&(fwrd_opcode_ID!=`AUPIC)&&(fwrd_opcode_ID!=`LUI)&&(fwrd_opcode_ID!=`I_TYPE))&&
             (fwrd_opcode_ID!=`STORE)&&(fwrd_opcode_ID!=`FSW)&&(fwrd_opcode_ID!=`B_TYPE))  
             fwrd_data2_ALU_sel=2'd2;

    else fwrd_data2_ALU_sel=op2_sel;

end


always_comb begin
    if ((fwrd_WB_addr!=5'b0)&&
        (reg_write_en_WB)&&
        (fwrd_ID_reg1==fwrd_WB_addr)) begin   //MEM-->ID
        fwrd_data1_ID_sel =1'b1;
    end else begin
        fwrd_data1_ID_sel =1'b0;
    end
end
always_comb begin
    if ((fwrd_WB_addr!=5'b0)&&
        (reg_write_en_WB)&&
        (fwrd_ID_reg2==fwrd_WB_addr)) begin
        fwrd_data2_ID_sel =1'b1;
    end else begin
        fwrd_data2_ID_sel =1'b0;
    end
end


always_comb begin
    if ((reg_write_en_EXE)&&     (fwrd_opcode_EXE!=`CSR_TYPE)&&
        (fwrd_EXE_addr!=5'b0)&&
        (fwrd_ID_reg1==fwrd_EXE_addr)      //EXE-->EXE      
        ) begin                
        fwrd_data1_BJ_sel =2'd2;
    end else if ((reg_write_en_MEM)&&           
                 (fwrd_MEM_addr!=5'b0)&&
                 (fwrd_ID_reg1==fwrd_MEM_addr)) begin     //MEM-->EXE    
        fwrd_data1_BJ_sel =2'b1;
    end else begin
        fwrd_data1_BJ_sel =2'b0;
    end
end
always_comb begin
    if ((reg_write_en_EXE)&&     (fwrd_opcode_ID==`B_TYPE)&&(fwrd_opcode_EXE==`CSR_TYPE)&&  
        (fwrd_EXE_addr!=5'b0)&&
        (fwrd_ID_reg2==fwrd_EXE_addr)) begin
        fwrd_data2_BJ_sel =2'd3;
    end 
    else if ((reg_write_en_EXE)&&     (fwrd_opcode_EXE!=`CSR_TYPE)&&  
        (fwrd_EXE_addr!=5'b0)&&
        (fwrd_ID_reg2==fwrd_EXE_addr)) begin
        fwrd_data2_BJ_sel =2'd2;
    end else if ((reg_write_en_MEM)&&
                 (fwrd_MEM_addr!=5'b0)&&
                 (fwrd_ID_reg2==fwrd_MEM_addr)) begin
        fwrd_data2_BJ_sel =2'b1;
    end else begin
        fwrd_data2_BJ_sel =2'b0;
    end
end


always_comb begin
    if ((reg_write_en_EXE)&&     (fwrd_opcode_EXE!=`CSR_TYPE)&&  

        ((fwrd_opcode_ID!=`FSW)||(fwrd_opcode_EXE!=`LUI)||(fwrd_opcode_MEM!=`F_TYPE))&& //prog6

        (fwrd_EXE_addr!=5'b0)&&
        (fwrd_ID_reg2==fwrd_EXE_addr)) begin
        fwrd_data3_MID_sel =2'd2;
    end else if ((reg_write_en_MEM)&&
                 
                 // (fwrd_opcode_MEM!=`F_TYPE)&& //prog6

                 (fwrd_MEM_addr!=5'b0)&&
                 (fwrd_ID_reg2==fwrd_MEM_addr)) begin
        fwrd_data3_MID_sel =2'b1;
    end else begin
        fwrd_data3_MID_sel =2'b0;
    end
end


//MEM--->MEM
always_comb begin 
    if ((fwrd_opcode_ID==`STORE)&&(fwrd_ID_reg2==fwrd_EXE_addr)&&
        ((fwrd_opcode_EXE==`LOAD)||((fwrd_opcode_EXE==`I_TYPE)))
        
        ||((fwrd_opcode_ID==`FSW)&&(fwrd_ID_reg2==fwrd_EXE_addr)&&
           ((fwrd_opcode_EXE==`FLW)||((fwrd_opcode_EXE==`I_TYPE))))

        ) begin   
        fwrd_data_MEM_sel =1'b1;
    end else begin
        fwrd_data_MEM_sel =1'b0;
    end
end


endmodule