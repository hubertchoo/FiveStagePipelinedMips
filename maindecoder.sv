module maindecoder(
    input logic [5:0] opcode,
    output logic memtoreg, memwrite, branch, alusrc, regdst, regwrite,
    output logic [1:0] aluop
);
    logic [8:0] controls;
    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, aluop} = controls;
    always_comb
        case(opcode)
            6'b000000: controls <= 8'b11000010; // RTYPE
            6'b100011: controls <= 8'b10100100; // LW
            6'b101011: controls <= 8'b0x101x00; // SW
            6'b000100: controls <= 8'b0x010x01; // BEQ
            6'b001000: controls <= 8'b10100000; // ADDI
            default: controls <= 8'bxxxxxxxx; // illegal op
        endcase
endmodule