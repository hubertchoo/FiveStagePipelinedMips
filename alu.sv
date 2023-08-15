module alu #(parameter WIDTH = 32) (
    input logic [WIDTH-1:0] srca, 
    input logic [WIDTH-1:0] srcb,
    input logic [2:0] alucontrol,
    output logic [WIDTH-1:0] aluout,
    output logic zero
);

    logic [WIDTH-1:0] s;
    always_comb 
    begin
        case (alucontrol)
            3'b000: aluout = srca & srcb;
            3'b001: aluout = srca | srcb;
            3'b010: aluout = srca + srcb;
            3'b011: aluout = 0;
            3'b100: aluout = srca & ~srcb;
            3'b101: aluout = srca | ~srcb;
            3'b110: aluout = srca - srcb;
            3'b111: 
            begin
                if (srca < srcb) aluout = 1;
                else aluout = 0;
            end
            default: aluout ={WIDTH{1'bx}};
        endcase

        zero = (aluout == 0);
    end
    
endmodule