`timescale 1ns/1ps

module tb_branch_nohazard;
    reg clk_i;
    reg rstn_i;
    integer errors;

    risc_V_CPU dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i)
    );

    always #5 clk_i = ~clk_i;

    initial begin
        clk_i = 1'b0;
        rstn_i = 1'b0;
        errors = 0;

        #17;
        rstn_i = 1'b1;

        repeat (80) @(posedge clk_i);

        check_reg(5'd1,  32'd5);
        check_reg(5'd2,  32'd5);
        check_reg(5'd3,  32'd0);
        check_reg(5'd4,  32'd0);
        check_reg(5'd5,  32'd1);
        check_reg(5'd6,  32'd2);
        check_reg(5'd7,  32'd0);
        check_reg(5'd8,  32'd0);
        check_reg(5'd9,  32'd3);
        check_reg(5'd11, 32'd0);
        check_reg(5'd12, 32'd0);
        check_reg(5'd13, 32'd4);

        if (errors == 0)
            $display("PASS: branch taken/not-taken flush test without RAW hazards");
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
