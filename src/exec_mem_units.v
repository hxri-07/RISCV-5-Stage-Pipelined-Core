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
        // Default values to prevent latches
        reg_write = 0; mem_to_reg = 0; mem_write = 0; 
        mem_read = 0; alu_src = 0; branch = 0; alu_op = 2'b00;
        
        case(opcode)
            7'b0110011: begin // R-Type (ADD, SUB, AND)
                reg_write = 1; alu_op = 2'b10;
            end
            7'b0010011: begin // I-Type (ADDI)
                reg_write = 1; alu_src = 1; alu_op = 2'b00;
            end
            7'b0000011: begin // Load (LW)
                reg_write = 1; mem_to_reg = 1; mem_read = 1; alu_src = 1; alu_op = 2'b00;
            end
            7'b0100011: begin // Store (SW)
                mem_write = 1; alu_src = 1; alu_op = 2'b00;
            end
            7'b1100011: begin // Branch (BEQ)
                branch = 1; alu_op = 2'b01;
            end
        endcase
    end
endmodule

// ARITHMETIC LOGIC UNIT (ALU)
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);
    assign zero = (result == 32'b0);
    always @(*) begin
        case(alu_ctrl)
            3'b000: result = a + b;       // ADD
            3'b001: result = a - b;       // SUB
            3'b010: result = a & b;       // AND
            3'b011: result = a | b;       // OR
            3'b100: result = a ^ b;       // XOR
            3'b101: result = a << b[4:0]; // SLL
            3'b110: result = a >> b[4:0]; // SRL
            default: result = 32'b0;
        endcase
    end
endmodule

// DATA MEMORY (L1 CACHE MOCKUP)
module data_memory (
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] memory [0:255]; // 1KB Data Memory
    
    // Word-aligned read
    assign read_data = (mem_read) ? memory[addr[31:2]] : 32'b0;
    
    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[31:2]] <= write_data;
        end
    end
endmodule