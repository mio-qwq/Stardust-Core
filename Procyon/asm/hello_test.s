        .text
        .globl _start

_start:
        # x10 = MMIO1 (0xFFC)
        lui     x10, 0x1
        addi    x10, x10, -4
        
        # x11 = 数据缓冲区 (0x400)
        addi    x11, x0, 0x400
        
        # ====== 生成 HELLO WORLD! 并存入内存 ======
        # 基础值 0x40
        lui     x1, 0x1
        srli    x1, x1, 6           # x1 = 0x40
        
        # H = 0x48 (addi)
        addi    x2, x1, 8
        sb      x2, 0(x11)
        
        # E = 0x45 (sub)
        addi    x3, x0, 3
        sub     x4, x2, x3
        sb      x4, 1(x11)
        
        # L = 0x4C (ori)
        ori     x5, x1, 0x0C
        sb      x5, 2(x11)
        
        # L = 0x4C (sll + srli)
        slli    x6, x5, 4
        srli    x6, x6, 4
        sb      x6, 3(x11)
        
        # O = 0x4F (add)
        add     x7, x6, x3
        sb      x7, 4(x11)
        
        # space = 0x20 (xori)
        xori    x8, x7, 0x6F
        sb      x8, 5(x11)
        
        # W = 0x57 (addi)
        addi    x9, x8, 0x37
        sb      x9, 6(x11)
        
        # O = 0x4F (sub)
        addi    x12, x0, 8
        sub     x13, x9, x12
        sb      x13, 7(x11)
        
        # R = 0x52 (add)
        add     x14, x13, x3
        sb      x14, 8(x11)
        
        # L = 0x4C (sub)
        addi    x15, x0, 6
        sub     x16, x14, x15
        sb      x16, 9(x11)
        
        # D = 0x44 (sub)
        sub     x17, x16, x12
        sb      x17, 10(x11)
        
        # ! = 0x21 (sub)
        addi    x18, x0, 0x23
        sub     x19, x17, x18
        sb      x19, 11(x11)
        
        # 测试 sh：写入 0x4C48
        slli    x20, x5, 8
        add     x20, x20, x2
        sh      x20, 16(x11)
        
        # 测试 and / xor / slt / sltu / srai / andi
        and     x21, x2, x5
        xor     x22, x2, x5
        addi    x23, x0, -1
        slt     x24, x23, x0
        sltu    x25, x23, x0
        srai    x26, x23, 4
        andi    x27, x2, 0x7F
        
        # 测试 auipc
        auipc   x28, 0
        
        # ====== 输出循环 (测试 jal / 分支) ======
        addi    x29, x0, 0          # i = 0
        addi    x30, x0, 12         # len = 12
        
        jal     x1, print           # 调用 print，测试 jal
        
        # 测试分支全家桶
        addi    x4, x0, 5
        addi    x5, x0, 10
        blt     x4, x5, L1
        sw      x0, 0(x10)
L1:     bge     x5, x4, L2
        sw      x0, 0(x10)
L2:     bltu    x4, x23, L3
        sw      x0, 0(x10)
L3:     bgeu    x23, x4, L4
        sw      x0, 0(x10)
        
L4:     # 测试 lhu / lh / lbu / lw
        lhu     x6, 16(x11)
        lh      x7, 16(x11)
        lbu     x8, 0(x11)
        lw      x9, 0(x11)
        
        j       end

# ====== print 子程序 (测试 jalr 返回) ======
print:
        beq     x29, x30, print_done
        add     x31, x11, x29
        lb      x3, 0(x31)
        sw      x3, 0(x10)
        addi    x29, x29, 1
        bne     x29, x30, print
print_done:
        jalr    x0, x1, 0           # 返回，测试 jalr

end:    j       end