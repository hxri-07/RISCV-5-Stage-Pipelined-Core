`timescale 1ns / 1ps

module tb_cpu_core;
    reg clk;
    reg rst;

    cpu_core uut (
        .clk(clk),
        .rst(rst)
    );

    // Generate 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        
        // Hold reset for a few cycles
        #20;
        rst = 0;
        
        // Let the CPU execute the instructions from instr.hex
        #500;
        
        $finish;
    end
endmodule