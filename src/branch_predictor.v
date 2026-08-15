`timescale 1ns / 1ps

module branch_predictor (
    input wire        clk,
    input wire        rst,

    // Fetch lookup
    input wire [31:0] fetch_pc,
    output wire       predict_taken,
    output wire [31:0] predict_target,

    // EX update
    input wire [31:0] ex_pc,
    input wire        ex_is_branch,
    input wire        ex_actual_taken,
    input wire [31:0] ex_branch_target
);

    // 16-entry BTB/BHT
    reg [31:0] btb [0:15];
    reg [1:0]  bht [0:15];

    // Tag = upper bits above the index
    reg [25:0] btb_tag [0:15];

    reg        btb_valid [0:15];

    wire [3:0] fetch_idx = fetch_pc[5:2];
    wire [3:0] ex_idx    = ex_pc[5:2];

    wire [25:0] fetch_tag = fetch_pc[31:6];
    wire [25:0] ex_tag    = ex_pc[31:6];

    // Prediction is valid only when the BTB entry matches
    assign predict_taken =
        btb_valid[fetch_idx] &&
        (btb_tag[fetch_idx] == fetch_tag) &&
        bht[fetch_idx][1];

    assign predict_target =
        btb[fetch_idx];

    integer i;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            for (i = 0; i < 16; i = i + 1) begin
                btb[i]       <= 32'b0;
                btb_tag[i]   <= 26'b0;
                btb_valid[i] <= 1'b0;
                bht[i]       <= 2'b01;   // Weakly not taken
            end

        end

        else if (ex_is_branch) begin

            // Update BTB
            btb[ex_idx]       <= ex_branch_target;
            btb_tag[ex_idx]   <= ex_tag;
            btb_valid[ex_idx] <= 1'b1;

            // Update 2-bit saturating counter
            if (ex_actual_taken) begin

                if (bht[ex_idx] != 2'b11)
                    bht[ex_idx] <= bht[ex_idx] + 1'b1;

            end

            else begin

                if (bht[ex_idx] != 2'b00)
                    bht[ex_idx] <= bht[ex_idx] - 1'b1;

            end
        end

    end

endmodule