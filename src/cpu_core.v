`timescale 1ns / 1ps

module cpu_core (
    input wire clk,
    input wire rst
);

    // HAZARD / FLUSH WIRES
    wire stall;
    wire ex_branch_mispredict;

    wire if_id_flush = ex_branch_mispredict;
    wire id_ex_flush = stall | ex_branch_mispredict;

    // STAGE 1: FETCH
    wire [31:0] if_pc;
    wire [31:0] if_instr;
    wire [31:0] if_pc_plus_4;

    wire [31:0] ex_correct_pc;

    wire        if_pred_taken;
    wire [31:0] if_pred_target;

    wire        bp_predict_taken;
    wire [31:0] bp_predict_target;

    fetch_stage fetch_inst (
        .clk(clk),
        .rst(rst),
        .stall(stall),

        .predict_taken(bp_predict_taken),
        .predict_target(bp_predict_target),

        .ex_branch_mispredict(ex_branch_mispredict),
        .ex_correct_pc(ex_correct_pc),

        .pc_out(if_pc),
        .instr_out(if_instr),
        .pc_plus_4_out(if_pc_plus_4),

        .pred_taken_out(if_pred_taken),
        .pred_target_out(if_pred_target)
    );

    // IF / ID REGISTER
    wire [31:0] id_pc;
    wire [31:0] id_instr;
    wire [31:0] id_pred_target;
    wire        id_pred_taken;

    if_id_reg if_id_inst (
        .clk(clk),
        .rst(rst),
        .en(~stall),
        .flush(if_id_flush),

        .if_pc(if_pc),
        .if_instr(if_instr),

        .if_pred_taken(if_pred_taken),
        .if_pred_target(if_pred_target),

        .id_pc(id_pc),
        .id_instr(id_instr),

        .id_pred_taken(id_pred_taken),
        .id_pred_target(id_pred_target)
    );

    // STAGE 2: DECODE
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [4:0] id_rd;

    wire [6:0] id_opcode;
    wire [2:0] id_funct3;
    wire [6:0] id_funct7;

    wire [31:0] id_imm;

    wire id_uses_rs1;
    wire id_uses_rs2;

    wire [31:0] id_read_data1;
    wire [31:0] id_read_data2;

    decode_stage decode_inst (
        .instr(id_instr),

        .rs1_addr(id_rs1),
        .rs2_addr(id_rs2),
        .rd_addr(id_rd),

        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7),

        .uses_rs1(id_uses_rs1),
        .uses_rs2(id_uses_rs2),

        .imm_out(id_imm)
    );

    // CONTROL
    wire ctrl_reg_write;
    wire ctrl_mem_to_reg;
    wire ctrl_mem_write;
    wire ctrl_mem_read;
    wire ctrl_alu_src;
    wire ctrl_branch;

    wire [1:0] ctrl_alu_op;

    control_unit ctrl_inst (
        .opcode(id_opcode),

        .reg_write(ctrl_reg_write),
        .mem_to_reg(ctrl_mem_to_reg),
        .mem_write(ctrl_mem_write),
        .mem_read(ctrl_mem_read),

        .alu_src(ctrl_alu_src),
        .branch(ctrl_branch),

        .alu_op(ctrl_alu_op)
    );

    // REGISTER FILE
    wire        wb_reg_write;
    wire [4:0]  wb_rd;
    wire [31:0] wb_write_data;

    reg_file reg_file_inst (
        .clk(clk),
        .rst(rst),

        .we(wb_reg_write),

        .read_reg1(id_rs1),
        .read_reg2(id_rs2),

        .write_reg(wb_rd),
        .write_data(wb_write_data),

        .read_data1(id_read_data1),
        .read_data2(id_read_data2)
    );

    // ID / EX REGISTER
    wire ex_wb_reg_write;
    wire ex_wb_mem_to_reg;
    wire ex_m_mem_write;
    wire ex_m_mem_read;

    wire ex_alu_src;
    wire ex_branch;
    wire [1:0] ex_alu_op;

    wire [31:0] ex_pc;
    wire [31:0] ex_reg_data1;
    wire [31:0] ex_reg_data2;
    wire [31:0] ex_imm;

    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;

    wire [2:0] ex_funct3;
    wire       ex_funct7_5;

    wire       ex_pred_taken;
    wire [31:0] ex_pred_target;

    id_ex_reg id_ex_inst (
        .clk(clk),
        .rst(rst),
        .flush(id_ex_flush),

        .wb_reg_write_in(ctrl_reg_write),
        .wb_mem_to_reg_in(ctrl_mem_to_reg),

        .m_mem_write_in(ctrl_mem_write),
        .m_mem_read_in(ctrl_mem_read),

        .ex_alu_src_in(ctrl_alu_src),
        .ex_branch_in(ctrl_branch),
        .ex_alu_op_in(ctrl_alu_op),

        .pc_in(id_pc),
        .reg_data1_in(id_read_data1),
        .reg_data2_in(id_read_data2),
        .imm_in(id_imm),

        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rd_in(id_rd),

        .funct3_in(id_funct3),
        .funct7_5_in(id_funct7[5]),

        .id_pred_taken(id_pred_taken),
        .id_pred_target(id_pred_target),

        .wb_reg_write(ex_wb_reg_write),
        .wb_mem_to_reg(ex_wb_mem_to_reg),

        .m_mem_write(ex_m_mem_write),
        .m_mem_read(ex_m_mem_read),

        .ex_alu_src(ex_alu_src),
        .ex_branch(ex_branch),
        .ex_alu_op(ex_alu_op),

        .pc(ex_pc),
        .reg_data1(ex_reg_data1),
        .reg_data2(ex_reg_data2),
        .imm(ex_imm),

        .rs1(ex_rs1),
        .rs2(ex_rs2),
        .rd(ex_rd),

        .funct3(ex_funct3),
        .funct7_5(ex_funct7_5),

        .ex_pred_taken(ex_pred_taken),
        .ex_pred_target(ex_pred_target)
    );

    // STAGE 3: EXECUTE
    wire [1:0] forward_a;
    wire [1:0] forward_b;

    reg [31:0] alu_in_a;
    reg [31:0] alu_in_b_fw;

    wire [31:0] alu_in_b;
    wire [31:0] alu_result;
    wire [31:0] mem_alu_result;

    wire alu_zero;

    // Forwarding mux A
    always @(*) begin

        case (forward_a)
            2'b10: alu_in_a = mem_alu_result;
            2'b01: alu_in_a = wb_write_data;
            default: alu_in_a = ex_reg_data1;
        endcase

    end

    // Forwarding mux B
    always @(*) begin

        case (forward_b)
            2'b10: alu_in_b_fw = mem_alu_result;
            2'b01: alu_in_b_fw = wb_write_data;
            default: alu_in_b_fw = ex_reg_data2;
        endcase

    end

    // Select immediate or register operand
    assign alu_in_b =
        ex_alu_src ? ex_imm : alu_in_b_fw;

    // ALU CONTROL
    reg [2:0] dynamic_alu_ctrl;

    always @(*) begin

        // Default
        dynamic_alu_ctrl = 3'b000;

        if (ex_branch) begin

            // All currently-supported branches compare
            // using subtraction.
            dynamic_alu_ctrl = 3'b001;

        end

        else begin

            case (ex_alu_op)

                // ADD / address calculation
                2'b00: begin

                    if (ex_alu_src) begin

                        // I-type ALU instruction
                        case (ex_funct3)

                            3'b000: dynamic_alu_ctrl = 3'b000; // ADDI
                            3'b111: dynamic_alu_ctrl = 3'b010; // ANDI
                            3'b110: dynamic_alu_ctrl = 3'b011; // ORI
                            3'b100: dynamic_alu_ctrl = 3'b100; // XORI
                            3'b001: dynamic_alu_ctrl = 3'b101; // SLLI
                            3'b101: dynamic_alu_ctrl = 3'b110; // SRLI

                            default: dynamic_alu_ctrl = 3'b000;

                        endcase
                    end

                    else begin
                        dynamic_alu_ctrl = 3'b000;
                    end
                end


                // Branch
                2'b01: begin
                    dynamic_alu_ctrl = 3'b001;
                end


                // R-type
                2'b10: begin

                    case (ex_funct3)

                        3'b000: begin
                            // ADD/SUB
                            dynamic_alu_ctrl =
                                ex_funct7_5 ? 3'b001 : 3'b000;
                        end

                        3'b111: dynamic_alu_ctrl = 3'b010; // AND
                        3'b110: dynamic_alu_ctrl = 3'b011; // OR
                        3'b100: dynamic_alu_ctrl = 3'b100; // XOR
                        3'b001: dynamic_alu_ctrl = 3'b101; // SLL
                        3'b101: dynamic_alu_ctrl = 3'b110; // SRL

                        default: dynamic_alu_ctrl = 3'b000;

                    endcase
                end

                default: begin
                    dynamic_alu_ctrl = 3'b000;
                end

            endcase

        end
    end


    alu alu_inst (
        .a(alu_in_a),
        .b(alu_in_b),
        .alu_ctrl(dynamic_alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // BRANCH RESOLUTION
    reg ex_actual_taken;

    always @(*) begin

        ex_actual_taken = 1'b0;

        if (ex_branch) begin

            case (ex_funct3)

                // BEQ
                3'b000:
                    ex_actual_taken = alu_zero;

                // BNE
                3'b001:
                    ex_actual_taken = ~alu_zero;

                default:
                    ex_actual_taken = 1'b0;

            endcase
        end
    end


    // IMPORTANT:
    // decode_stage already creates the correctly-shifted
    // B-immediate, including the low zero bit.
    wire [31:0] ex_branch_target =
        ex_pc + ex_imm;

    // BRANCH MISPREDICTION
    assign ex_branch_mispredict =
        ex_branch &&
        (
            (ex_actual_taken != ex_pred_taken) ||
            (
                ex_actual_taken &&
                (ex_branch_target != ex_pred_target)
            )
        );


    // Correct PC after a misprediction
    assign ex_correct_pc =
        ex_actual_taken ?
        ex_branch_target :
        (ex_pc + 32'd4);

    // BRANCH PREDICTOR
    branch_predictor bp_inst (
        .clk(clk),
        .rst(rst),

        .fetch_pc(if_pc),

        .predict_taken(bp_predict_taken),
        .predict_target(bp_predict_target),

        .ex_pc(ex_pc),
        .ex_is_branch(ex_branch),
        .ex_actual_taken(ex_actual_taken),
        .ex_branch_target(ex_branch_target)
    );

    // EX / MEM
    wire mem_wb_reg_write;
    wire mem_wb_mem_to_reg;

    wire mem_m_mem_write;
    wire mem_m_mem_read;

    wire [31:0] mem_reg_data2;
    wire [4:0] mem_rd;

    ex_mem_reg ex_mem_inst (
        .clk(clk),
        .rst(rst),

        .wb_reg_write_in(ex_wb_reg_write),
        .wb_mem_to_reg_in(ex_wb_mem_to_reg),

        .m_mem_write_in(ex_m_mem_write),
        .m_mem_read_in(ex_m_mem_read),

        .alu_result_in(alu_result),

        // Store data must come from the forwarded register operand
        .reg_data2_in(alu_in_b_fw),

        .rd_in(ex_rd),

        .wb_reg_write(mem_wb_reg_write),
        .wb_mem_to_reg(mem_wb_mem_to_reg),

        .m_mem_write(mem_m_mem_write),
        .m_mem_read(mem_m_mem_read),

        .alu_result(mem_alu_result),
        .reg_data2(mem_reg_data2),
        .rd(mem_rd)
    );

    // STAGE 4: MEMORY
    wire [31:0] mem_read_data;

    data_memory dmem_inst (
        .clk(clk),

        .mem_write(mem_m_mem_write),
        .mem_read(mem_m_mem_read),

        .addr(mem_alu_result),
        .write_data(mem_reg_data2),

        .read_data(mem_read_data)
    );

    // MEM / WB
    wire wb_mem_to_reg;

    wire [31:0] wb_read_data;
    wire [31:0] wb_alu_result;

    mem_wb_reg mem_wb_inst (
        .clk(clk),
        .rst(rst),

        .wb_reg_write_in(mem_wb_reg_write),
        .wb_mem_to_reg_in(mem_wb_mem_to_reg),

        .read_data_in(mem_read_data),
        .alu_result_in(mem_alu_result),
        .rd_in(mem_rd),

        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),

        .read_data(wb_read_data),
        .alu_result(wb_alu_result),
        .rd(wb_rd)
    );

    // STAGE 5: WRITE-BACK
    assign wb_write_data =
        wb_mem_to_reg ?
        wb_read_data :
        wb_alu_result;

    // HAZARD UNIT
    hazard_unit hu_inst (

        // Forwarding
        .rs1_id_ex(ex_rs1),
        .rs2_id_ex(ex_rs2),

        .rd_ex_mem(mem_rd),
        .rd_mem_wb(wb_rd),

        .reg_write_ex_mem(mem_wb_reg_write),
        .reg_write_mem_wb(wb_reg_write),

        // Stall
        .rs1_if_id(id_rs1),
        .rs2_if_id(id_rs2),

        .uses_rs1_if_id(id_uses_rs1),
        .uses_rs2_if_id(id_uses_rs2),

        .mem_read_id_ex(ex_m_mem_read),
        .rd_id_ex(ex_rd),

        .forward_a(forward_a),
        .forward_b(forward_b),

        .stall(stall)
    );

endmodule