`timescale 1ns / 1ps

module reg_file (
    input wire        clk,
    input wire        rst,
    input wire        we,

    input wire [4:0]  read_reg1,
    input wire [4:0]  read_reg2,
    input wire [4:0]  write_reg,

    input wire [31:0] write_data,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] registers [0:31];

    integer i;

    // Initialize all registers on reset
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end

    end

    // Combinational reads
    assign read_data1 =
        (read_reg1 == 5'b0) ? 32'b0 : registers[read_reg1];

    assign read_data2 =
        (read_reg2 == 5'b0) ? 32'b0 : registers[read_reg2];

    // Write on falling edge
    always @(negedge clk) begin

        if (we && (write_reg != 5'b0))
            registers[write_reg] <= write_data;

    end

endmodule