
module REG_UNIT(
    input CLK,
    input RST,
    input [4:0]REG_NUM1,
    input [4:0]REG_NUM2,
    input WE,
    input [31:0]WRITE,
    output [31:0]READ1,
    output [31:0]READ2
    );
    reg [31:0] REG_FILE [1:31];
    assign READ1 = (REG_NUM1==0)?0:REG_FILE[REG_NUM1];
    assign READ2 = (REG_NUM2==0)?0:REG_FILE[REG_NUM2];
    integer i;
    always @(posedge CLK or negedge RST)
    begin
        if(!RST)
        begin
            for (i = 1; i < 32; i = i + 1)
                REG_FILE[i] <= 0;
        end
        else if(WE)
            REG_FILE[REG_NUM1]<=WRITE;

    end
    
    
endmodule
