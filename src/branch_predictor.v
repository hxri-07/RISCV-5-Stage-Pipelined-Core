`timescale 1ns / 1ps

module branch_predictor (
    input  wire        clk,
    input  wire        rst,
    
    // Read Port (Instruction Fetch Stage)
    input  wire [31:0] fetch_pc,
    output wire        predict_taken,
    output wire [31:0] predict_target,
    
    // Write/Update Port (Execute Stage)
    input  wire [31:0] ex_pc,           
    input  wire        ex_is_branch,    
    input  wire        ex_actual_taken, 
    input  wire [31:0] ex_branch_target 
);

    // 16-entry Branch Target Buffer (BTB) & Branch History Table (BHT)
    reg [31:0] btb [0:15];
    reg [1:0]  bht [0:15];
    
    wire [3:0] fetch_idx = fetch_pc[5:2];
    wire [3:0] ex_idx    = ex_pc[5:2];
    
    // Predict Phase (Combinational)
    assign predict_taken  = bht[fetch_idx][1]; 
    assign predict_target = btb[fetch_idx];

    // Declare integer outside the always block to satisfy Verilog standards
    integer i;

    // Update Phase (Sequential)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all states to Weakly Not Taken (01)
            for (i = 0; i < 16; i = i + 1) begin
                bht[i] <= 2'b01;
                btb[i] <= 32'b0;
            end
        end else if (ex_is_branch) begin
            btb[ex_idx] <= ex_branch_target;
            
            // 2-bit Saturating Counter State Machine
            if (ex_actual_taken) begin
                if (bht[ex_idx] != 2'b11) 
                    bht[ex_idx] <= bht[ex_idx] + 1; 
            end else begin
                if (bht[ex_idx] != 2'b00) 
                    bht[ex_idx] <= bht[ex_idx] - 1; 
            end
        end
    end
endmodule