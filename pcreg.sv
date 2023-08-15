module pcreg #(parameter WIDTH = 32)
(
    input logic clk,
    input logic reset,
    output logic [WIDTH-1:0] pcnext,
    input logic [WIDTH-1:0] pc
);

    always_ff@(posedge clk)
    begin
        if (reset) pcnext = 0;
        else pcnext = pc + 4;
    end

endmodule