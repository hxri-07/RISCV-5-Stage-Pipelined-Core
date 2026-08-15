`timescale 1ns / 1ps

module hazard_unit (
    // Forwarding Inputs
    input wire [4:0] rs1_id_ex,
    input wire [4:0] rs2_id_ex,

    input wire [4:0] rd_ex_mem,
    input wire [4:0] rd_mem_wb,

    input wire       reg_write_ex_mem,
    input wire       reg_write_mem_wb,

    // Stall Inputs
    input wire [4:0] rs1_if_id,
    input wire [4:0] rs2_if_id,

    input wire       uses_rs1_if_id,
    input wire       uses_rs2_if_id,

    input wire       mem_read_id_ex,
    input wire [4:0] rd_id_ex,

    // Outputs
    output reg [1:0] forward_a,
    output reg [1:0] forward_b,
    output reg       stall
);

    // FORWARDING
    always @(*) begin

        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX/MEM has priority
        if (reg_write_ex_mem &&
            (rd_ex_mem != 5'b0) &&
            (rd_ex_mem == rs1_id_ex)) begin

            forward_a = 2'b10;
        end

        else if (reg_write_mem_wb &&
                 (rd_mem_wb != 5'b0) &&
                 (rd_mem_wb == rs1_id_ex)) begin

            forward_a = 2'b01;
        end


        if (reg_write_ex_mem &&
            (rd_ex_mem != 5'b0) &&
            (rd_ex_mem == rs2_id_ex)) begin

            forward_b = 2'b10;
        end

        else if (reg_write_mem_wb &&
                 (rd_mem_wb != 5'b0) &&
                 (rd_mem_wb == rs2_id_ex)) begin

            forward_b = 2'b01;
        end

    end

    // LOAD-USE HAZARD
    always @(*) begin

        stall = 1'b0;

        if (mem_read_id_ex &&
            (rd_id_ex != 5'b0) &&
            ((uses_rs1_if_id && (rd_id_ex == rs1_if_id)) ||
             (uses_rs2_if_id && (rd_id_ex == rs2_if_id)))) begin

            stall = 1'b1;
        end
    end

endmodule