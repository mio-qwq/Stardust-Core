module ALU_UNIT(
    input [31:0]IN1,
    input [31:0]IN2,
    input IF_SRA,//SRA 算数右移 $signed()>>>
    input [2:0]OPT_CODE,//其实就是RISC V的funct3
    output [31:0]OUT
    );
    assign OUT=(OPT_CODE==3'B000)?IN1+IN2://ADD / SUB
               (OPT_CODE==3'B001)?IN1<<IN2[4:0]://SLL 左移
               (OPT_CODE==3'B010)?($signed(IN1)<$signed(IN2)?1:0)://SLT 有符号小于置位
               (OPT_CODE==3'B011)?(IN1<IN2?1:0): //SLTU 无符号小于置位
               (OPT_CODE==3'B100)?IN1 ^ IN2://XOR
               (OPT_CODE==3'B101)?(IF_SRA?($signed(IN1) >>> IN2[4:0]):(IN1 >> IN2[4:0])):
               (OPT_CODE==3'B110)?IN1|IN2:
               (OPT_CODE==3'B111)?IN1&IN2:0;
endmodule
