`timescale 1ns / 1ps

module if_id_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,       
    input  wire        flush,    
    input  wire [31:0] if_pc,
    input  wire [31:0] if_instr,
    input  wire        if_pred_taken,
    input  wire [31:0] if_pred_target,
    
    output reg  [31:0] id_pc,
    output reg  [31:0] id_instr,
    output reg         id_pred_taken,
    output reg  [31:0] id_pred_target
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            id_pc          <= 32'b0;
            id_instr       <= 32'h00000013; // NOP
            id_pred_taken  <= 1'b0;
            id_pred_target <= 32'b0;
        end else if (en) begin
            id_pc          <= if_pc;
            id_instr       <= if_instr;
            id_pred_taken  <= if_pred_taken;
            id_pred_target <= if_pred_target;
        end
    end
endmodule