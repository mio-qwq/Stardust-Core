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
	assign MM_IO2 = MEM [1022];
	assign MM_IO1 = MEM [1023];
	assign READ_INSTRUCTION = MEM [ADDR_OF_INSTRUCTION[11:2]];
    assign READ = MEM [ADDR[11:2]];
	always @(posedge CLK)
	begin
        if(WRITE_ENABLE)
			MEM [ADDR[11:2]] <= WRITE;
	end
endmodule