`timescale 1ns/1ps

module tb_lui_jump;
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

        program_file = "program_lui_jump.hex";
        if ($value$plusargs("PROGRAM=%s", program_file))
            $display("PROGRAM=%0s", program_file);

        fd = $fopen(program_file, "r");
        if (fd == 0) begin
            program_file = "Risc_V/code_6_27-7_01/program_lui_jump.hex";
            fd = $fopen(program_file, "r");
        end
        if (fd == 0) begin
            $display("ERROR: could not open program_lui_jump.hex");
            $finish;
        end
        $fclose(fd);

        #1;

        for (i = 0; i < 1024; i = i + 1)
            dut.U_imem.mem[i] = 32'h00000013;
        $readmemh(program_file, dut.U_imem.mem);

        #16;
        rstn_i = 1'b1;

        repeat (100) @(posedge clk_i);

        check_reg(5'd1,  32'h12345000);
        check_reg(5'd2,  32'h12345678);
        check_reg(5'd3,  32'd12);
        check_reg(5'd4,  32'd111);
        check_reg(5'd5,  32'd7);
        check_reg(5'd6,  32'd24);
        check_reg(5'd7,  32'd0);
        check_reg(5'd8,  32'd0);
        check_reg(5'd9,  32'd26);
        check_reg(5'd10, 32'd48);
        check_reg(5'd11, 32'd0);
        check_reg(5'd12, 32'd0);
        check_reg(5'd13, 32'h1234567f);
        check_reg(5'd14, 32'd123);

        if (errors == 0)
            $display("PASS: LUI/JAL/JALR proof test");
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
endmodule
