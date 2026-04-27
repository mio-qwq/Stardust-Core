module MEM_UNIT(
	//input RST,
	input [11:0] ADDR,
	input [31:0] WRITE,
	input WRITE_ENABLE,
	input CLK,
	output  [31:0] READ,
	input [11:0] ADDR_OF_INSTRUCTION,
	output  [31:0] READ_INSTRUCTION,
	output [31:0]MM_IO1,
	output [31:0]MM_IO2
);	

	reg [31:0] MEM [0:1023];
	reg [31:0]MM_IO1_REG;
	reg [31:0]MM_IO2_REG;
	
	assign MM_IO1 = MM_IO1_REG;
	assign MM_IO2 = MM_IO2_REG;
	assign READ_INSTRUCTION = MEM [ADDR_OF_INSTRUCTION[11:2]];
    assign READ =(ADDR[11:2]<1022)? MEM [ADDR[11:2]]:
                 (ADDR[11:2]==1022)?MM_IO2_REG:MM_IO1_REG;
	always @(posedge CLK)
	begin
        if((WRITE_ENABLE)&&(ADDR[11:2]<1022))
			MEM [ADDR[11:2]] <= WRITE;
		else if((WRITE_ENABLE)&&(ADDR[11:2]==1022))
		    MM_IO2_REG<= WRITE;
		else if((WRITE_ENABLE)&&(ADDR[11:2]==1023))
		    MM_IO1_REG<= WRITE;
	end
endmodule