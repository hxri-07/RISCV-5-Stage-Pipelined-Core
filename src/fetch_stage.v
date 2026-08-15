`timescale 1ns / 1ps

module fetch_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,            
    
    // Predictor Inputs (from Branch Predictor)
    input  wire        predict_taken,
    input  wire [31:0] predict_target,

    // Branch Correction Signals (from EX stage)
    input  wire        ex_branch_mispredict, 
    input  wire [31:0] ex_correct_pc,        
    
    // Outputs
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [31:0] pc_plus_4_out,
    output wire        pred_taken_out,
    output wire [31:0] pred_target_out
);
    wire [31:0] current_pc;
    wire [31:0] next_pc;
    wire [31:0] pc_plus_4;
    
    assign pc_plus_4 = current_pc + 32'd4;
    
    // The New PC MUX Logic:
    // Priority 1: Mispredict Recovery (EX Stage)
    // Priority 2: BTB Prediction
    // Priority 3: Normal PC + 4
    assign next_pc = ex_branch_mispredict ? ex_correct_pc : 
                     (predict_taken ? predict_target : pc_plus_4);

    pc_reg pc_inst (
        .clk(clk),
        .rst(rst),
        .en(~stall),
        .next_pc(next_pc),
        .pc(current_pc)
    );

    imem imem_inst (
        .pc(current_pc),
        .instr(instr_out)
    );

    assign pc_out = current_pc;
    assign pc_plus_4_out = pc_plus_4;
    assign pred_taken_out = predict_taken;
    assign pred_target_out = predict_target;

endmodule