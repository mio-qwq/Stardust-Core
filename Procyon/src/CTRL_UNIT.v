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
    
    //U-Type instructons
    wire IF_LUI;
    assign IF_LUI=(INSTRUCTION[6:0]==7'b0110111)?1:0;
    wire IF_AUIPC;
    assign IF_AUIPC=(INSTRUCTION[6:0]==7'b0010111)?1:0;
    
    //R-type instructions
    assign WHICH_REG1 =( (INSTRUCTION[6:0]==7'b0110011)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000))||(INSTRUCTION[6:0]==7'b1100011)||(INSTRUCTION[6:0]==7'b0100011)||(INSTRUCTION[6:0]==7'b0000011))
    ?INSTRUCTION[19:15]: 0;
    assign WHICH_REG2 = ((INSTRUCTION[6:0]==7'b0110011)||(INSTRUCTION[6:0]==7'b1100011)||(INSTRUCTION[6:0]==7'b0100011))? INSTRUCTION[24:20]: 0;
    assign ALU_IF_SRA = (INSTRUCTION[30]==1)?1:0;
    assign ALU_IN2 = ((INSTRUCTION[6:0] == 7'b0110011) && (INSTRUCTION[30] == 0))
                     ?READ_REG2:
                     (((INSTRUCTION[30]==1)&&1/*可能需要补充*/)?((INSTRUCTION[14:12]==3'b000)?~READ_REG2+1:READ_REG2)
                     :0);
    assign ALU_IN1 = (INSTRUCTION[6:0]==7'b0110011)?READ_REG1:0;
    assign ALU_OPT_CODE = (INSTRUCTION[6:0]==7'b0110011)? INSTRUCTION[14:12]:0;
    assign REG_WE = ((INSTRUCTION[6:0]==7'b0110011)||(INSTRUCTION[6:0]==7'b1101111)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000))||(IF_LUI)||(IF_AUIPC)||(INSTRUCTION[6:0]==7'b0000011))? 1: 0;
    assign WHICH_REG_WRITE = 
    ((INSTRUCTION[6:0]==7'b0110011)||(INSTRUCTION[6:0]==7'b1101111)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000))||(IF_LUI)||(IF_AUIPC)||(INSTRUCTION[6:0]==7'b0000011))?
     INSTRUCTION[11:7]:0;
     
    assign WRITE_REG = (INSTRUCTION[6:0]==7'b0110011)? ALU_OUT://ALU OPT
                        ((INSTRUCTION[6:0]==7'b1101111)||((INSTRUCTION[6:0]==7'b1100111)&&(INSTRUCTION[14:12]==3'b000)))
                        ?INSTRUCTION_POINTER+4//JAL
                        :(IF_LUI)? {INSTRUCTION[31:12],12'b0}
                        :(IF_AUIPC)? (INSTRUCTION_POINTER + {INSTRUCTION[31:12],12'b0}):((INSTRUCTION[6:0]==7'b0000011)?
                        
                        //load mem
                        ((INSTRUCTION[14:12]==3'b000)?(
                        
                        (WHICH_RAM[1:0]==2'b00)?
                        {{24{READ_RAM[7]}},{READ_RAM[7:0]}}:
                        (WHICH_RAM[1:0]==2'b01)?
                        {{24{READ_RAM[15]}},{READ_RAM[15:8]}}:
                        (WHICH_RAM[1:0]==2'b10)?
                        {{24{READ_RAM[23]}},{READ_RAM[23:16]}}:
                        (WHICH_RAM[1:0]==2'b11)?
                        {{24{READ_RAM[31]}},{READ_RAM[31:24]}}:0
                        
                        ):
                        (INSTRUCTION[14:12]==3'b001)?(
                        (WHICH_RAM[1]==1'b0)?
                        
                        
                        {{16{READ_RAM[15]}},{READ_RAM[15:0]}}:{{16{READ_RAM[31]}},{READ_RAM[31:16]}}
                        
                        
                        
                        ):
                        (INSTRUCTION[14:12]==3'b010)?READ_RAM:
                        (INSTRUCTION[14:12]==3'b100)?(
                        (WHICH_RAM[1:0]==2'b00)?
                        {READ_RAM[7:0]}:
                        (WHICH_RAM[1:0]==2'b01)?
                        {READ_RAM[15:8]}:
                        (WHICH_RAM[1:0]==2'b10)?
                        {READ_RAM[23:16]}:
                        (WHICH_RAM[1:0]==2'b11)?
                        {READ_RAM[31:24]}:0
                        ):
                        (INSTRUCTION[14:12]==3'b101)?(
                        (WHICH_RAM[1]==1'b0)?
                        
                        
                        {READ_RAM[15:0]}:{READ_RAM[31:16]}):
                        0
                        )
                        
                        :0);
    
    
    assign RAM_WE=(INSTRUCTION[6:0]==7'b0100011)?1:0;
    assign WHICH_RAM=((INSTRUCTION[6:0]==7'b0100011)&&1)?
    ((INSTRUCTION[14:12]==3'b010)?((READ_REG1)+{{20{INSTRUCTION[31]}}, INSTRUCTION[31:25], INSTRUCTION[11:7]})
    :((INSTRUCTION[14:12]==3'b001)?((READ_REG1)+{{20{INSTRUCTION[31]}}, INSTRUCTION[31:25], INSTRUCTION[11:7]})
    :((INSTRUCTION[14:12]==3'b000)?((READ_REG1)+{{20{INSTRUCTION[31]}}, INSTRUCTION[31:25], INSTRUCTION[11:7]})
    
    :0))//其他情况
    ):(((INSTRUCTION[6:0]==7'b0000011)?(READ_REG1+{{20{INSTRUCTION[31]}}, INSTRUCTION[31:20]}):0));//load
    
    
    assign WRITE_RAM=((INSTRUCTION[6:0]==7'b0100011)&&1)?
    ((INSTRUCTION[14:12]==3'b010)?READ_REG2://SW
    ((INSTRUCTION[14:12]==3'b000)?((WHICH_RAM[1:0]==2'b00)?//SB
    {READ_RAM[31:8],READ_REG2[7:0]}
    :((WHICH_RAM[1:0]==2'b01)?
    {READ_RAM[31:16],READ_REG2[7:0],READ_RAM[7:0]}
    :((WHICH_RAM[1:0]==2'b10)?
    {READ_RAM[31:24],READ_REG2[7:0],READ_RAM[15:0]}:
    ((WHICH_RAM[1:0]==2'b11)?{READ_REG2[7:0],READ_RAM[23:0]}:0)//
    )//
    )):
    ((INSTRUCTION[14:12]==3'b001)?(((WHICH_RAM[1]==1'b1)?{READ_REG2[15:0],READ_RAM[15:0]}
    :{READ_RAM[31:16],READ_REG2[15:0]}))://SH
    0))
    ):0;
 
    
    
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
    (IF_BRANCH==1)?(INSTRUCTION_POINTER + {{20{INSTRUCTION[31]}}, INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8],1'b0}) //图灵完备!!!!!!2026/4/28/13:18
    :INSTRUCTION_POINTER+4;                             
    
    

    
    
    
    always @(posedge CLK or negedge RST)
    begin
        if(!RST)
            INSTRUCTION_POINTER<=12'b0000_0000_0000;
        else
            INSTRUCTION_POINTER<=INSTRUCTION_POINTER_NEXT;
    end    
    
endmodule