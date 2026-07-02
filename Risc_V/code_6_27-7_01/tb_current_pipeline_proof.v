`timescale 1ns/1ps

module tb_current_pipeline_proof;
    reg clk_i;
    reg rstn_i;

    integer errors;
    integer i;
    integer fd;
    reg [1023:0] program_file;

    risc_V_CPU dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i)
    );

    always #5 clk_i = ~clk_i;

    initial begin
        clk_i = 1'b0;
        rstn_i = 1'b0;
        errors = 0;

        program_file = "program_proof_current.hex";
        if ($value$plusargs("PROGRAM=%s", program_file))
            $display("PROGRAM=%0s", program_file);

        fd = $fopen(program_file, "r");
        if (fd == 0) begin
            program_file = "Risc_V/code_6_27-7_01/program_proof_current.hex";
            fd = $fopen(program_file, "r");
        end
        if (fd == 0) begin
            $display("ERROR: could not open program_proof_current.hex");
            $finish;
        end
        $fclose(fd);

        #1;

        for (i = 0; i < 1024; i = i + 1)
            dut.U_imem.mem[i] = 32'h00000013;
        $readmemh(program_file, dut.U_imem.mem);

        for (i = 0; i < 1024; i = i + 1)
            dut.U_dmem.dmem[i] = 32'd0;

        dut.U_dmem.dmem[0] = 32'd7;
        dut.U_dmem.dmem[1] = 32'd3;
        dut.U_dmem.dmem[2] = 32'd9;

        #16;
        rstn_i = 1'b1;

        repeat (120) @(posedge clk_i);

        check_reg(5'd0,  32'd0);
        check_reg(5'd1,  32'd5);
        check_reg(5'd2,  32'd12);
        check_reg(5'd3,  32'd17);
        check_reg(5'd4,  32'd12);
        check_reg(5'd5,  32'd0);
        check_reg(5'd6,  32'd5);
        check_reg(5'd7,  32'd9);
        check_reg(5'd8,  32'd20);
        check_reg(5'd9,  32'd7);
        check_reg(5'd10, 32'd19);
        check_reg(5'd11, 32'd19);
        check_reg(5'd12, 32'd0);
        check_reg(5'd13, 32'd22);
        check_reg(5'd14, 32'd3);
        check_reg(5'd15, 32'd3);
        check_reg(5'd16, 32'd0);
        check_reg(5'd17, 32'd1);
        check_reg(5'd18, 32'd0);
        check_reg(5'd19, 32'd4);
        check_reg(5'd20, 32'd0);
        check_reg(5'd21, 32'd0);
        check_reg(5'd22, 32'd9);
        check_reg(5'd23, 32'd14);
        check_reg(5'd24, 32'd123);

        check_mem(0, 32'd7);
        check_mem(1, 32'd3);
        check_mem(2, 32'd9);
        check_mem(3, 32'd19);
        check_mem(4, 32'd9);

        if (errors == 0)
            $display("PASS: current pipeline proof test - ALU, LW/SW, forwarding, load-use stall, ID branch, flush");
        else
            $display("FAIL: %0d mismatches", errors);

        $finish;
    end

    task check_reg;
        input [4:0] idx;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            actual = dut.U_reg_file.regs[idx];
            if (actual !== expected) begin
                $display("ERROR: x%0d expected %0d (0x%08h), got %0d (0x%08h)",
                         idx, expected, expected, actual, actual);
                errors = errors + 1;
            end else begin
                $display("OK: x%0d = %0d (0x%08h)", idx, actual, actual);
            end
        end
    endtask

    task check_mem;
        input integer idx;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            actual = dut.U_dmem.dmem[idx];
            if (actual !== expected) begin
                $display("ERROR: dmem[%0d] expected %0d (0x%08h), got %0d (0x%08h)",
                         idx, expected, expected, actual, actual);
                errors = errors + 1;
            end else begin
                $display("OK: dmem[%0d] = %0d (0x%08h)", idx, actual, actual);
            end
        end
    endtask
endmodule
