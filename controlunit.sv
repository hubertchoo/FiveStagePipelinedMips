module controlunit(
    input [31:26] op,
    input [5:0] funct,
    output [2:0] alucontrol,
    output memtoreg, memwrite, branch, alusrc, regdst, regwrite
);
    
    logic [1:0] aluop;

    maindecoder MAINDECODER(
    .opcode(op),
    .memtoreg(memtoreg),
    .memwrite(memwrite),
    .branch(branch), 
    .alusrc(alusrc),
    .regdst(regdst),
    .regwrite(regwrite),
    .aluop(aluop)
    );

    aludecoder ALUDECODER(
    .aluop(aluop),
    .funct(funct),
    .alucontrol(alucontrol)
    );

endmodule