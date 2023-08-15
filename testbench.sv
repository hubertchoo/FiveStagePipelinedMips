`timescale 1 ns/10 ps
module testbench();
    
    logic clk, reset;

    top dut(clk);

    initial
    begin
        reset <= 1; 
        # 5; 
        reset <= 0;
    end

    //clk
    initial begin
        clk = 1'b0;
        repeat(10000*2) #5 clk = ~clk; // generate a clock
    end

endmodule