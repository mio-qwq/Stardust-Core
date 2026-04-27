module PROCYON_CORE(
    input CLK,
    input RST,
    output [31:0]MMIO1,
    output  [31:0]MMIO2
);
    //wire [31:0]mmio1;
    //wire [31:0]mmio2;
    wire [31:0]instruction;
    wire [11:0]instruction_addr;
    wire [11:0]which_ram;
    wire [31:0]read_ram;
    wire [31:0]write_ram;
    wire ram_we;
    wire [4:0]which_reg1;
    wire [31:0]read_reg1;
    wire [4:0]which_reg2;
    wire [31:0]read_reg2;
    wire [4:0]which_reg_write;
    wire [31:0]write_reg;
    wire reg_we;
 
    CTRL_UNIT __CTRL_UNIT(
        .CLK(CLK),
        .RST(RST),
        .INSTRUCTION(instruction),
        .INSTRUCTION_ADDR(instruction_addr),
        .WHICH_RAM(which_ram),
        .READ_RAM(read_ram),
        .WRITE_RAM(write_ram),
        .RAM_WE(ram_we),
        .WHICH_REG1(which_reg1),
        .READ_REG1(read_reg1),
        .WHICH_REG2(which_reg2),
        .READ_REG2(read_reg2),
        .WHICH_REG_WRITE(which_reg_write),
        .WRITE_REG(write_reg),
        .REG_WE(reg_we)
    );

    MEM_UNIT __MEM_UNIT(
        .ADDR(which_ram),
        .WRITE(write_ram),
        .WRITE_ENABLE(ram_we),
        .CLK(CLK),
        .READ(read_ram),
        .ADDR_OF_INSTRUCTION(instruction_addr),
        .READ_INSTRUCTION(instruction),
        .MM_IO1(MMIO1),
        .MM_IO2(MMIO2)
    );

    REG_UNIT __REG_UNIT(
        .CLK(CLK),
        .RST(RST),
        .REG_NUM1(which_reg1),
        .REG_NUM2(which_reg2),          
        .READ1(read_reg1),
        .READ2(read_reg2),
        .WE(reg_we),
        .REG_WRITE(which_reg_write),
        .WRITE(write_reg)
    );


endmodule