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

    // Register usage information for hazard detection
    output reg         uses_rs1,
    output reg         uses_rs2,

    // Sign-Extended Immediate Value
    output reg  [31:0] imm_out
);

    // RISC-V standard instruction slicing
    assign opcode   = instr[6:0];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign funct7   = instr[31:25];

    always @(*) begin
        // Defaults
        imm_out  = 32'b0;
        uses_rs1 = 1'b0;
        uses_rs2 = 1'b0;

        case (opcode)

            // I-type ALU instructions
            7'b0010011: begin
                imm_out  = {{20{instr[31]}}, instr[31:20]};
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b0;
            end

            // LOAD
            7'b0000011: begin
                imm_out  = {{20{instr[31]}}, instr[31:20]};
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b0;
            end

            // STORE
            7'b0100011: begin
                imm_out  = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            // BRANCH
            7'b1100011: begin
                imm_out = {{20{instr[31]}},
                           instr[7],
                           instr[30:25],
                           instr[11:8],
                           1'b0};

                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            // R-type
            7'b0110011: begin
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            default: begin
                imm_out  = 32'b0;
                uses_rs1 = 1'b0;
                uses_rs2 = 1'b0;
            end

        endcase
    end

endmodule
