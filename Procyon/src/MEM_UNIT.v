module MEM_UNIT(
	//input RST,
	input [11:0] ADDR,
	input [31:0] WRITE,
	input WRITE_ENABLE,
	input CLK,
	output  [31:0] READ,
	input [11:0] ADDR_OF_INSTRUCTION,
	output  [31:0] READ_INSTRUCTION
	
);	
	reg [31:0] MEM [0:4095];
	assign READ_INSTRUCTION = MEM [ADDR_OF_INSTRUCTION];
    assign READ = MEM [ADDR];
	always @(posedge CLK)
	begin
        if(WRITE_ENABLE)
			MEM [ADDR] <= WRITE;
	end
endmodule