`timescale 1ns / 1ps

module reg_file (
    input  wire        clk,
    input  wire        we,         // Write Enable (from Write-Back stage)
    input  wire [4:0]  read_reg1,  // rs1
    input  wire [4:0]  read_reg2,  // rs2
    input  wire [4:0]  write_reg,  // rd
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] registers [0:31];

    // RISC-V x0 is strictly hardwired to 0
    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : registers[read_reg2];

    // Write on falling edge to prevent internal structural hazards
    always @(negedge clk) begin
        if (we && write_reg != 5'b0) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule