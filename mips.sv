module mips(
    input logic clk,
    input logic [31:0] instr, readdata,
    output logic [31:0] pc, writedata, aluresult,
    output logic memwrite
);
    
    logic [31:0] pcplusfour, pcin; // 8 bit address
    logic zero;
    logic [31:0] pcbranch;
    logic [31:0] reg1out, reg2out;
    logic [31:0] signimm;
    logic [31:0] srcb;
    logic [31:0] result;
    logic [4:0] writereg;
    logic[2:0] alucontrol;
    logic memtoreg, branch, alusrc, regdst, regwrite;

    /*
    initial begin
        pc = 0;
        pcplusfour = 4;
    end
    */

    always_ff @(posedge clk) begin
        pc <= pcin;
    end

    alu #(32) PCALU(
    .srca(pc),
    .srcb(4),
    .alucontrol(3'b010),
    .aluout(pcplusfour),
    .zero()
    );

    
    mux2 PCSRCMUX(
    .srca(pcplusfour),
    .srcb(pcbranch),
    .cntrl(branch & zero),
    .out(pcin)     
    );


    regfile REGFILE(
    .clk(clk),
    .ra1(instr[25:21]),
    .rd1(reg1out),
    .ra2(instr[20:16]),
    .rd2(reg2out),
    .wa3(writereg),
    .wd3(result),
    .we3(regwrite)
    );


    signext SIGNEXT(
    .a(instr[15:0]),
    .y(signimm)
    );

    mux2 ALUSRCMUX(
    .srca(reg2out),
    .srcb(signimm),
    .cntrl(alusrc),
    .out(srcb)
    );

    alu #(32) ALU(
    .srca(reg1out),
    .srcb(srcb),
    .alucontrol(alucontrol),
    .aluout(aluresult),
    .zero(zero)
    );

    
    mux2 MEMTOREGMUX(
    .srca(aluresult),
    .srcb(readdata),
    .cntrl(memtoreg),
    .out(result) 
    );

    mux2 #(5) REGDSTMUX(
    .srca(instr[20:16]),
    .srcb(instr[15:11]),
    .cntrl(regdst),
    .out(writereg)     
    );

    alu #(32) PCBRANCHALU(
    .srca(signimm << 2),
    .srcb(pcplusfour),
    .alucontrol(3'b010),
    .aluout(pcbranch),
    .zero()
    );

    controlunit CONTROLUNIT(
    .op(instr[31:26]),
    .funct(instr[5:0]),
    .memtoreg(memtoreg), 
    .memwrite(memwrite), 
    .branch(branch), 
    .alucontrol(alucontrol), 
    .alusrc(alusrc), 
    .regdst(regdst), 
    .regwrite(regwrite)
    );

endmodule