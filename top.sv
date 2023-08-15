module top(
    input logic clk
);

    logic [31:0] pc, instr, writedata, aluresult, readdata;
    logic memwrite;

    mips MIPS(
    .clk(clk),
    .instr(instr),
    .pc(pc),
    .writedata(writedata),
    .aluresult(aluresult),
    .readdata(readdata),
    .memwrite(memwrite)
    );

    datamem	DATAMEM(
	.address (aluresult[7:0]),
	.clock (clk),
	.data (writedata),
	.wren (memwrite),
	.q (readdata)
	);

    instructionmem	INSTRUCTIONMEM (
	.address (pc[7:0]),
	.clock(clk),
	.q(instr)
	);
    
endmodule