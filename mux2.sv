module mux2 #(parameter WIDTH = 32) (
    input logic cntrl,
    input logic [WIDTH-1:0] srca,
    input logic [WIDTH-1:0] srcb,
    output logic [WIDTH-1:0] out
);

always_comb
begin
    case(cntrl)
        1'b0: out = srca;
        1'b1: out = srcb;
    endcase
end
    
endmodule