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
    
    
    output [4:0]WHICH_REG_WRITE,
    output [31:0]WRITE_REG,
    output REG_WE      //寄存器写使能
    );
    wire [31:0]ALU_IN1,ALU_IN2,ALU_OUT;
    wire [2:0]ALU_OPT_CODE;
    wire ALU_IF_SRA;
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
    
    //R-type instructions
    assign WHICH_REG1 =( (INSTRUCTION[6:0]==7'b0110011)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000))||(INSTRUCTION[6:0]==7'b1100011))
    ?INSTRUCTION[19:15]: 0;
    assign WHICH_REG2 = ((INSTRUCTION[6:0]==7'b0110011)||(INSTRUCTION[6:0]==7'b1100011))? INSTRUCTION[24:20]: 0;
    assign ALU_IF_SRA = (INSTRUCTION[30]==1)?1:0;
    assign ALU_IN2 = ((INSTRUCTION[6:0] == 7'b0110011) && (INSTRUCTION[30] == 0))
                     ?READ_REG2:
                     (INSTRUCTION[30]==1?((INSTRUCTION[14:12]==3'b000)?~READ_REG2+1:READ_REG2)
                     :0);
    assign ALU_IN1 = (INSTRUCTION[6:0]==7'b0110011)?READ_REG1:0;
    assign ALU_OPT_CODE = (INSTRUCTION[6:0]==7'b0110011)? INSTRUCTION[14:12]:0;
    assign REG_WE = ((INSTRUCTION[6:0]==7'b0110011)||(INSTRUCTION[6:0]==7'b1101111)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000)))? 1: 0;
    assign WHICH_REG_WRITE = 
    ((INSTRUCTION[6:0]==7'b0110011)||(INSTRUCTION[6:0]==7'b1101111)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000)))?
     INSTRUCTION[11:7]:0;
     
    assign WRITE_REG = (INSTRUCTION[6:0]==7'b0110011)? ALU_OUT://ALU OPT
                        ((INSTRUCTION[6:0]==7'b1101111)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000)))
                        ?INSTRUCTION_POINTER+4//JAL
                        :0;
    
    wire [11:0]INSTRUCTION_POINTER_NEXT;
    wire IF_BRANCH;
    
    assign IF_BRANCH = (INSTRUCTION[6:0]==7'b1100011)?
                       ((INSTRUCTION[14:12]==3'b000)?(READ_REG1==READ_REG2?1:0)://BEQ
                       (INSTRUCTION[14:12]==3'b001)?(READ_REG1!=READ_REG2?1:0)://BNE
                       (INSTRUCTION[14:12]==3'b100)?($signed(READ_REG1)<$signed(READ_REG2)?1:0)://BLT
                       (INSTRUCTION[14:12]==3'b101)?($signed(READ_REG1)>=$signed(READ_REG2)?1:0)://BGE
                       (INSTRUCTION[14:12]==3'b110)?(READ_REG1<READ_REG2?1:0)://BLTU
                       (INSTRUCTION[14:12]==3'b111)?(READ_REG1>=READ_REG2?1:0)://BGEU
                       0):
                       
                       0;
    
    assign INSTRUCTION_POINTER_NEXT=(INSTRUCTION[6:0]==7'b1101111)?
    INSTRUCTION_POINTER+{INSTRUCTION[31],INSTRUCTION[30:21],INSTRUCTION[20],INSTRUCTION[19:12],1'b0}://JAL
    ((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000))?
    (READ_REG1[11:0] + {{20{INSTRUCTION[31]}}, INSTRUCTION[31:20]}) & ~12'b1://JALR 
    (IF_BRANCH==1)?0/*占位 还不知道怎么加*/:INSTRUCTION_POINTER+4;                             
    
    always @(posedge CLK or negedge RST)
    begin
        if(!RST)
            INSTRUCTION_POINTER<=12'b0000_0000_0000;
        else
            INSTRUCTION_POINTER<=INSTRUCTION_POINTER_NEXT;
    end    
    
endmodule
