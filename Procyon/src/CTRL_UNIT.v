/*
计划编写一个单周期CPU
这里将会是控制单元
*/
module CTRL_UNIT(
    input CLK,
    input RST,
    
    
    input [31:0]INSTRUCTION,
    output [11:0]INSTRUCTION_ADDR,
    //
    
    output [11:0]WHICH_RAM,//12位地址空间
    input [31:0]READ_RAM,
    output [31:0]WRITE_RAM,
    output RAM_WE,
    
    //其实控制单元最主要就是控制怎么读写内存和寄存器了
    //↑内存读写   ↓寄存器读写
    output [4:0]WHICH_REG1,
    input [31:0]READ_REG1,
    output [4:0]WHICH_REG2,
    input [31:0]READ_REG2, //计划专门做一个寄存器单元,里面放所有寄存器
    output [31:0]WRITE_REG,
    output REG_WE      //寄存器写使能
    );
    wire ALU_IN1,ALU_IN2,ALU_IF_SRA,ALU_OPT_CODE,ALU_OUT;
    ALU_UNIT ALU(
        .IN1(ALU_IN1),
        .IN2(ALU_IN2),
        .IF_SRA(ALU_IF_SRA),
        .OPT_CODE(ALU_OPT_CODE),
        .OUT(ALU_OUT)
    );
    //最最最最最最重要的instruction pointer 
    //冯诺依曼计算机必有的
    reg [11:0]INSTRUCTION_POINTER;
    assign INSTRUCTION_ADDR=INSTRUCTION_POINTER;
    //单周期处理器 仅仅只是储存器之间连了一堆组合逻辑
    //异步读,同步写
    //所以只需要在写入相关用always
    always @(posedge CLK or negedge RST)
    begin
        if(!RST)
            INSTRUCTION_POINTER=12'b0000_0000_0000;//初始地址
        else if(INSTRUCTION[6:0]==7'b0110011)
        begin
            if(INSTRUCTION[30]==0)
            begin
                ALU_IN1=
            end
        end
        
    end
    
    
endmodule
