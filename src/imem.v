`timescale 1ns / 1ps

module imem (
    input wire [31:0] pc,
    output wire [31:0] instr
);

    // 256 x 32-bit = 1 KB
    reg [31:0] memory [0:255];

    integer i;

    initial begin

        // Default everything to NOP
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        // Load program
        $readmemh(
            "D:/Personal/Vivado Projects/project_3/project_3.srcs/sources_1/new/instr.hex",
            memory
        );

    end

    // Word aligned
    assign instr = memory[pc[31:2]];

endmodule