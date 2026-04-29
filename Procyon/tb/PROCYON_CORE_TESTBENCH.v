`timescale 1ns / 1ps

module PROCYON_CORE_TESTBENCH;
    reg CLK = 0;
    reg RST = 0;
    wire [31:0] MMIO1, MMIO2;
    
    PROCYON_CORE __PROCYON_CORE(
        .CLK(CLK),
        .RST(RST),
        .MMIO1(MMIO1),
        .MMIO2(MMIO2)
    );
/*
关于运行的测试程序:
Stardust-Core/
└── Procyon/
    ├── tb/  
    │   └── TEST.mem            # 测试汇编程序编译后的机器码
    └── asm/ 
        └── hello_test.s        # 测试汇编程序源码


*/
    always #5 CLK = ~CLK;
    initial begin
        $readmemh("TEST.mem", __PROCYON_CORE.__MEM_UNIT.MEM);
        RST = 0; #20;
        RST = 1;
        #2000;
        $finish;
    end
        
endmodule
