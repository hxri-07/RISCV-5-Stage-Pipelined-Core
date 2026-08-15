`timescale 1ns / 1ps

module tb_cpu_core;

    reg clk;
    reg rst;

    integer errors;

    cpu_core uut (
        .clk(clk),
        .rst(rst)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // CHECK REGISTER TASK
    task check_reg;
        input integer reg_num;
        input [31:0] expected;
        input [127:0] reg_name;

        begin

            if (uut.reg_file_inst.registers[reg_num] !== expected) begin

                $display(
                    "FAIL: %s expected = %0d (0x%08h), got = %0d (0x%08h)",
                    reg_name,
                    $signed(expected),
                    expected,
                    $signed(uut.reg_file_inst.registers[reg_num]),
                    uut.reg_file_inst.registers[reg_num]
                );

                errors = errors + 1;

            end

            else begin

                $display(
                    "PASS: %s = %0d (0x%08h)",
                    reg_name,
                    $signed(uut.reg_file_inst.registers[reg_num]),
                    uut.reg_file_inst.registers[reg_num]
                );

            end

        end
    endtask

    // CHECK MEMORY TASK
    task check_mem;
        input integer mem_index;
        input [31:0] expected;

        begin

            if (uut.dmem_inst.memory[mem_index] !== expected) begin

                $display(
                    "FAIL: memory[%0d] expected = %0d (0x%08h), got = %0d (0x%08h)",
                    mem_index,
                    $signed(expected),
                    expected,
                    $signed(uut.dmem_inst.memory[mem_index]),
                    uut.dmem_inst.memory[mem_index]
                );

                errors = errors + 1;

            end

            else begin

                $display(
                    "PASS: memory[%0d] = %0d (0x%08h)",
                    mem_index,
                    $signed(uut.dmem_inst.memory[mem_index]),
                    uut.dmem_inst.memory[mem_index]
                );

            end

        end
    endtask
    
    // TEST
    initial begin

        $dumpfile("cpu_core.vcd");
        $dumpvars(0, tb_cpu_core);

        errors = 0;

        clk = 1'b0;
        rst = 1'b1;

        // Hold reset
        #20;

        rst = 1'b0;
        
        // Allow the complete program to execute.
        // 800 ns = 80 clock cycles.
        #800;


        $display("");
        $display("================================================");
        $display("        RV32I CPU COMPREHENSIVE TEST");
        $display("================================================");
        $display("");
    
        // REGISTER CHECKS
        check_reg(0,  32'd0,    "x0");
        check_reg(1,  32'd10,   "x1");
        check_reg(2,  32'd5,    "x2");
        check_reg(3,  32'd15,   "x3");
        check_reg(4,  32'd10,   "x4");
        check_reg(5,  32'd0,    "x5");
        check_reg(6,  32'd15,   "x6");
        check_reg(7,  32'd15,   "x7");
        check_reg(8,  32'd5120, "x8");
        check_reg(9,  32'd0,    "x9");

        check_reg(10, 32'd20,   "x10");
        check_reg(11, 32'd15,   "x11");
        check_reg(12, 32'd1,    "x12");
        check_reg(13, 32'd20,   "x13");
        check_reg(14, 32'd25,   "x14");

        check_reg(15, 32'd10,   "x15");
        check_reg(16, 32'd20,   "x16");

        check_reg(17, 32'd5,    "x17");
        check_reg(18, 32'd5,    "x18");
        check_reg(19, 32'd10,   "x19");
        check_reg(20, 32'd20,   "x20");
        check_reg(21, 32'd30,   "x21");
        check_reg(22, 32'd40,   "x22");
        check_reg(23, 32'd0,    "x23");

        check_reg(24, 32'hfffffff6, "x24");  // -10
        check_reg(25, 32'd5,        "x25");
        check_reg(26, 32'hfffffff1, "x26");  // -15
        check_reg(27, 32'hfffffffb, "x27");  // -5

        check_reg(28, 32'd0,    "x28");
        check_reg(29, 32'd10,   "x29");
        check_reg(30, 32'd77,   "x30");
        check_reg(31, 32'd77,   "x31");
        
        // DATA MEMORY CHECKS
        check_mem(0, 32'd10);
        check_mem(1, 32'd77);

        // FINAL RESULT
        $display("");
        $display("================================================");

        if (errors == 0) begin

            $display("           ALL TESTS PASSED");
            $display("================================================");
            $display("");

        end

        else begin

            $display(
                "           TEST FAILED: %0d ERROR(S)",
                errors
            );

            $display("================================================");
            $display("");

        end
        // Useful debug summary
        $display("Final register state:");
        $display("x0  = %0d", $signed(uut.reg_file_inst.registers[0]));
        $display("x1  = %0d", $signed(uut.reg_file_inst.registers[1]));
        $display("x2  = %0d", $signed(uut.reg_file_inst.registers[2]));
        $display("x3  = %0d", $signed(uut.reg_file_inst.registers[3]));
        $display("x4  = %0d", $signed(uut.reg_file_inst.registers[4]));
        $display("x5  = %0d", $signed(uut.reg_file_inst.registers[5]));
        $display("x6  = %0d", $signed(uut.reg_file_inst.registers[6]));
        $display("x7  = %0d", $signed(uut.reg_file_inst.registers[7]));
        $display("x8  = %0d", $signed(uut.reg_file_inst.registers[8]));
        $display("x9  = %0d", $signed(uut.reg_file_inst.registers[9]));

        $display("x10 = %0d", $signed(uut.reg_file_inst.registers[10]));
        $display("x11 = %0d", $signed(uut.reg_file_inst.registers[11]));
        $display("x12 = %0d", $signed(uut.reg_file_inst.registers[12]));
        $display("x13 = %0d", $signed(uut.reg_file_inst.registers[13]));
        $display("x14 = %0d", $signed(uut.reg_file_inst.registers[14]));
        $display("x15 = %0d", $signed(uut.reg_file_inst.registers[15]));
        $display("x16 = %0d", $signed(uut.reg_file_inst.registers[16]));

        $display("x17 = %0d", $signed(uut.reg_file_inst.registers[17]));
        $display("x18 = %0d", $signed(uut.reg_file_inst.registers[18]));
        $display("x19 = %0d", $signed(uut.reg_file_inst.registers[19]));
        $display("x20 = %0d", $signed(uut.reg_file_inst.registers[20]));
        $display("x21 = %0d", $signed(uut.reg_file_inst.registers[21]));
        $display("x22 = %0d", $signed(uut.reg_file_inst.registers[22]));
        $display("x23 = %0d", $signed(uut.reg_file_inst.registers[23]));

        $display("x24 = %0d", $signed(uut.reg_file_inst.registers[24]));
        $display("x25 = %0d", $signed(uut.reg_file_inst.registers[25]));
        $display("x26 = %0d", $signed(uut.reg_file_inst.registers[26]));
        $display("x27 = %0d", $signed(uut.reg_file_inst.registers[27]));
        $display("x28 = %0d", $signed(uut.reg_file_inst.registers[28]));
        $display("x29 = %0d", $signed(uut.reg_file_inst.registers[29]));
        $display("x30 = %0d", $signed(uut.reg_file_inst.registers[30]));
        $display("x31 = %0d", $signed(uut.reg_file_inst.registers[31]));

        $display("");
        $display("memory[0] = %0d",
                 $signed(uut.dmem_inst.memory[0]));

        $display("memory[1] = %0d",
                 $signed(uut.dmem_inst.memory[1]));

        $display("");


        $finish;

    end

endmodule
