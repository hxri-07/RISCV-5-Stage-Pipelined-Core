`timescale 1ns / 1ps

module decode_stage (
    input  wire [31:0] instr,
    
    // Register file connections
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd_addr,
    
    // Control / Function Signals
    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    
    // Sign-Extended Immediate Value
    output reg  [31:0] imm_out
);
    // RISC-V Standard Instruction Slicing
    assign opcode   = instr[6:0];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign funct7   = instr[31:25];

    // Immediate Generation (Sign-Extended)
    always @(*) begin
        case (opcode)
            7'b0010011: // I-Type (e.g., ADDI, LW)
                imm_out = {{20{instr[31]}}, instr[31:20]};
                
            7'b0100011: // S-Type (e.g., SW)
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                
            7'b1100011: // B-Type (e.g., BEQ, BNE)
                imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                
            7'b0110111, 7'b0010111: // U-Type (LUI, AUIPC)
                imm_out = {instr[31:12], 12'b0};
                
            7'b1101111: // J-Type (JAL)
                imm_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
                
            default: 
                imm_out = 32'b0;
        endcase
    end
endmodule