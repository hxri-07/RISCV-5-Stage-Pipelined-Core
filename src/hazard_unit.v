`timescale 1ns / 1ps

module hazard_unit (
    // Forwarding Inputs
    input  wire [4:0] rs1_id_ex,
    input  wire [4:0] rs2_id_ex,
    input  wire [4:0] rd_ex_mem,
    input  wire [4:0] rd_mem_wb,
    input  wire       reg_write_ex_mem,
    input  wire       reg_write_mem_wb,
    
    // Stall Inputs
    input  wire [4:0] rs1_if_id,
    input  wire [4:0] rs2_if_id,
    input  wire       mem_read_id_ex,
    input  wire [4:0] rd_id_ex,
    
    // Outputs
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b,
    output reg        stall
);

    // 1. Data Forwarding Logic (EX and MEM Hazards)
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // EX Hazard (Forward from ALU Output)
        if (reg_write_ex_mem && (rd_ex_mem != 0) && (rd_ex_mem == rs1_id_ex)) 
            forward_a = 2'b10;
        else if (reg_write_mem_wb && (rd_mem_wb != 0) && (rd_mem_wb == rs1_id_ex)) 
            forward_a = 2'b01; // MEM Hazard (Forward from Memory/WB)
            
        if (reg_write_ex_mem && (rd_ex_mem != 0) && (rd_ex_mem == rs2_id_ex)) 
            forward_b = 2'b10;
        else if (reg_write_mem_wb && (rd_mem_wb != 0) && (rd_mem_wb == rs2_id_ex)) 
            forward_b = 2'b01;
    end

    // 2. Load-Use Hazard Detection (Pipeline Stall)
    always @(*) begin
        if (mem_read_id_ex && ((rd_id_ex == rs1_if_id) || (rd_id_ex == rs2_if_id))) begin
            stall = 1'b1; // Freeze PC and IF/ID, inject bubble into ID/EX
        end else begin
            stall = 1'b0;
        end
    end
endmodule