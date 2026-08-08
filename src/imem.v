`timescale 1ns / 1ps

module imem (
    input  wire [31:0] pc,
    output wire [31:0] instr
);
    // 256 words of 32-bit memory (1KB total)
    reg [31:0] memory [0:255]; 

    initial begin
        // Loads machine code at simulation start
        $readmemh("instr.hex", memory);
    end

    // Fetch the instruction, ignoring the byte offsets (bits 1 and 0)
    assign instr = memory[pc[31:2]];

endmodule