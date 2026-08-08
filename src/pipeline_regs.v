`timescale 1ns / 1ps

module id_ex_reg (
    input wire clk, rst, flush,
    // Control Signals
    input wire wb_reg_write_in, wb_mem_to_reg_in,
    input wire m_mem_write_in, m_mem_read_in,
    input wire ex_alu_src_in, ex_branch_in,
    input wire [1:0] ex_alu_op_in,
    
    // Data & Prediction Signals
    input wire [31:0] pc_in, reg_data1_in, reg_data2_in, imm_in,
    input wire [4:0] rs1_in, rs2_in, rd_in,
    input wire id_pred_taken,
    input wire [31:0] id_pred_target,
    
    // Outputs
    output reg wb_reg_write, wb_mem_to_reg,
    output reg m_mem_write, m_mem_read,
    output reg ex_alu_src, ex_branch,
    output reg [1:0] ex_alu_op,
    output reg [31:0] pc, reg_data1, reg_data2, imm,
    output reg [4:0] rs1, rs2, rd,
    output reg ex_pred_taken,
    output reg [31:0] ex_pred_target
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            wb_reg_write<=0; wb_mem_to_reg<=0; m_mem_write<=0; m_mem_read<=0;
            ex_alu_src<=0; ex_branch<=0; ex_alu_op<=0;
            pc<=0; reg_data1<=0; reg_data2<=0; imm<=0; rs1<=0; rs2<=0; rd<=0;
            ex_pred_taken<=0; ex_pred_target<=0;
        end else begin
            wb_reg_write<=wb_reg_write_in; wb_mem_to_reg<=wb_mem_to_reg_in;
            m_mem_write<=m_mem_write_in; m_mem_read<=m_mem_read_in;
            ex_alu_src<=ex_alu_src_in; ex_branch<=ex_branch_in; ex_alu_op<=ex_alu_op_in;
            pc<=pc_in; reg_data1<=reg_data1_in; reg_data2<=reg_data2_in; imm<=imm_in;
            rs1<=rs1_in; rs2<=rs2_in; rd<=rd_in;
            ex_pred_taken<=id_pred_taken; ex_pred_target<=id_pred_target;
        end
    end
endmodule

module ex_mem_reg (
    input wire clk, rst,
    input wire wb_reg_write_in, wb_mem_to_reg_in, m_mem_write_in, m_mem_read_in,
    input wire [31:0] alu_result_in, reg_data2_in,
    input wire [4:0] rd_in,
    
    output reg wb_reg_write, wb_mem_to_reg, m_mem_write, m_mem_read,
    output reg [31:0] alu_result, reg_data2,
    output reg [4:0] rd
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_reg_write<=0; wb_mem_to_reg<=0; m_mem_write<=0; m_mem_read<=0;
            alu_result<=0; reg_data2<=0; rd<=0;
        end else begin
            wb_reg_write<=wb_reg_write_in; wb_mem_to_reg<=wb_mem_to_reg_in;
            m_mem_write<=m_mem_write_in; m_mem_read<=m_mem_read_in;
            alu_result<=alu_result_in; reg_data2<=reg_data2_in; rd<=rd_in;
        end
    end
endmodule

module mem_wb_reg (
    input wire clk, rst,
    input wire wb_reg_write_in, wb_mem_to_reg_in,
    input wire [31:0] read_data_in, alu_result_in,
    input wire [4:0] rd_in,
    
    output reg wb_reg_write, wb_mem_to_reg,
    output reg [31:0] read_data, alu_result,
    output reg [4:0] rd
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_reg_write<=0; wb_mem_to_reg<=0; read_data<=0; alu_result<=0; rd<=0;
        end else begin
            wb_reg_write<=wb_reg_write_in; wb_mem_to_reg<=wb_mem_to_reg_in;
            read_data<=read_data_in; alu_result<=alu_result_in; rd<=rd_in;
        end
    end
endmodule