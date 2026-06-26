`timescale 1ns/1ps

module tb_cpu_core;
    reg clk_i;
    reg rstn_i;
    integer errors;

    risc_V_CPU dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i)
    );

    initial begin
        clk_i = 1'b0;
        forever #5 clk_i = ~clk_i;
    end

    initial begin
        errors = 0;
        rstn_i = 1'b0;

        #12;
        rstn_i = 1'b1;

        repeat (10) @(posedge clk_i);

        check_reg(1, 32'd5);
        check_reg(2, 32'd7);
        check_reg(3, 32'd12);
        check_reg(4, 32'd7);
        check_reg(5, 32'd4);
        check_reg(6, 32'd7);
        check_reg(7, 32'd2);

        if (errors == 0)
            $display("PASS: basic ADDI/R-type register writeback test");
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
