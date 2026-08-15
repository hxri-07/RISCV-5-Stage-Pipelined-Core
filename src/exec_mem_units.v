`timescale 1ns / 1ps

// CONTROL UNIT
module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        mem_to_reg,
    output reg        mem_write,
    output reg        mem_read,
    output reg        alu_src,
    output reg        branch,
    output reg  [1:0] alu_op
);

    always @(*) begin
        // Defaults
        reg_write  = 1'b0;
        mem_to_reg = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        alu_op     = 2'b00;

        case (opcode)

            // R-type
            7'b0110011: begin
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end

            // I-type ALU
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end

            // LW
            7'b0000011: begin
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                alu_op     = 2'b00;
            end

            // SW
            7'b0100011: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end

            // Conditional branches
            7'b1100011: begin
                branch = 1'b1;
                alu_op = 2'b01;
            end

            default: begin
                // Keep defaults
            end
        endcase
    end

endmodule

// ARITHMETIC LOGIC UNIT
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)

            3'b000: result = a + b;          // ADD
            3'b001: result = a - b;          // SUB
            3'b010: result = a & b;          // AND
            3'b011: result = a | b;          // OR
            3'b100: result = a ^ b;          // XOR
            3'b101: result = a << b[4:0];    // SLL
            3'b110: result = a >> b[4:0];    // SRL

            default: result = 32'b0;

        endcase
    end

endmodule

// DATA MEMORY
module data_memory (
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    // 256 x 32-bit = 1 KB
    reg [31:0] memory [0:255];

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'b0;
    end

    // Word-aligned combinational read
    assign read_data =
        mem_read ? memory[addr[31:2]] : 32'b0;

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write)
            memory[addr[31:2]] <= write_data;
    end

endmodule