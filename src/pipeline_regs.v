`timescale 1ns / 1ps

// ID / EX PIPELINE REGISTER
module id_ex_reg (
    input wire clk,
    input wire rst,
    input wire flush,

    // Control Signals
    input wire        wb_reg_write_in,
    input wire        wb_mem_to_reg_in,
    input wire        m_mem_write_in,
    input wire        m_mem_read_in,
    input wire        ex_alu_src_in,
    input wire        ex_branch_in,
    input wire [1:0]  ex_alu_op_in,

    // Data
    input wire [31:0] pc_in,
    input wire [31:0] reg_data1_in,
    input wire [31:0] reg_data2_in,
    input wire [31:0] imm_in,

    // Register identifiers
    input wire [4:0]  rs1_in,
    input wire [4:0]  rs2_in,
    input wire [4:0]  rd_in,

    // Instruction decode information
    input wire [2:0]  funct3_in,
    input wire        funct7_5_in,

    // Branch prediction information
    input wire        id_pred_taken,
    input wire [31:0] id_pred_target,

    // Outputs
    output reg        wb_reg_write,
    output reg        wb_mem_to_reg,
    output reg        m_mem_write,
    output reg        m_mem_read,

    output reg        ex_alu_src,
    output reg        ex_branch,
    output reg [1:0]  ex_alu_op,

    output reg [31:0] pc,
    output reg [31:0] reg_data1,
    output reg [31:0] reg_data2,
    output reg [31:0] imm,

    output reg [4:0]  rs1,
    output reg [4:0]  rs2,
    output reg [4:0]  rd,

    output reg [2:0]  funct3,
    output reg        funct7_5,

    output reg        ex_pred_taken,
    output reg [31:0] ex_pred_target
);

    always @(posedge clk or posedge rst) begin

        if (rst || flush) begin
            wb_reg_write <= 1'b0;
            wb_mem_to_reg <= 1'b0;
            m_mem_write <= 1'b0;
            m_mem_read <= 1'b0;

            ex_alu_src <= 1'b0;
            ex_branch <= 1'b0;
            ex_alu_op <= 2'b00;

            pc <= 32'b0;
            reg_data1 <= 32'b0;
            reg_data2 <= 32'b0;
            imm <= 32'b0;

            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= 5'b0;

            funct3 <= 3'b000;
            funct7_5 <= 1'b0;

            ex_pred_taken <= 1'b0;
            ex_pred_target <= 32'b0;
        end

        else begin
            wb_reg_write <= wb_reg_write_in;
            wb_mem_to_reg <= wb_mem_to_reg_in;
            m_mem_write <= m_mem_write_in;
            m_mem_read <= m_mem_read_in;

            ex_alu_src <= ex_alu_src_in;
            ex_branch <= ex_branch_in;
            ex_alu_op <= ex_alu_op_in;

            pc <= pc_in;
            reg_data1 <= reg_data1_in;
            reg_data2 <= reg_data2_in;
            imm <= imm_in;

            rs1 <= rs1_in;
            rs2 <= rs2_in;
            rd <= rd_in;

            funct3 <= funct3_in;
            funct7_5 <= funct7_5_in;

            ex_pred_taken <= id_pred_taken;
            ex_pred_target <= id_pred_target;
        end
    end

endmodule

// EX / MEM PIPELINE REGISTER
module ex_mem_reg (
    input wire clk,
    input wire rst,

    input wire        wb_reg_write_in,
    input wire        wb_mem_to_reg_in,
    input wire        m_mem_write_in,
    input wire        m_mem_read_in,

    input wire [31:0] alu_result_in,
    input wire [31:0] reg_data2_in,
    input wire [4:0]  rd_in,

    output reg        wb_reg_write,
    output reg        wb_mem_to_reg,
    output reg        m_mem_write,
    output reg        m_mem_read,

    output reg [31:0] alu_result,
    output reg [31:0] reg_data2,
    output reg [4:0]  rd
);

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            wb_reg_write <= 1'b0;
            wb_mem_to_reg <= 1'b0;
            m_mem_write <= 1'b0;
            m_mem_read <= 1'b0;

            alu_result <= 32'b0;
            reg_data2 <= 32'b0;
            rd <= 5'b0;
        end

        else begin
            wb_reg_write <= wb_reg_write_in;
            wb_mem_to_reg <= wb_mem_to_reg_in;
            m_mem_write <= m_mem_write_in;
            m_mem_read <= m_mem_read_in;

            alu_result <= alu_result_in;
            reg_data2 <= reg_data2_in;
            rd <= rd_in;
        end
    end

endmodule

// MEM / WB PIPELINE REGISTER
module mem_wb_reg (
    input wire clk,
    input wire rst,

    input wire        wb_reg_write_in,
    input wire        wb_mem_to_reg_in,

    input wire [31:0] read_data_in,
    input wire [31:0] alu_result_in,
    input wire [4:0]  rd_in,

    output reg        wb_reg_write,
    output reg        wb_mem_to_reg,

    output reg [31:0] read_data,
    output reg [31:0] alu_result,
    output reg [4:0]  rd
);

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            wb_reg_write <= 1'b0;
            wb_mem_to_reg <= 1'b0;

            read_data <= 32'b0;
            alu_result <= 32'b0;
            rd <= 5'b0;
        end

        else begin
            wb_reg_write <= wb_reg_write_in;
            wb_mem_to_reg <= wb_mem_to_reg_in;

            read_data <= read_data_in;
            alu_result <= alu_result_in;
            rd <= rd_in;
        end
    end

endmodule