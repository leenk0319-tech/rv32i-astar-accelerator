`timescale 1ns/1ps

module reg_file (
    input  wire        clk_i,
    input  wire        rstn_i,
    input  wire [4:0]  RS1,
    input  wire [4:0]  RS2,
    input  wire        W_WEN,
    input  wire [4:0]  W_WA,
    input  wire [31:0] W_WD,
    output wire [31:0] scr1,
    output wire [31:0] scr2
);
    reg [31:0] regs [0:31];
    integer k;

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            for (k = 0; k < 32; k = k + 1)
                regs[k] <= 32'd0;
        end else if (W_WEN && (W_WA != 5'd0)) begin
            regs[W_WA] <= W_WD;
        end
    end

    assign scr1 = (RS1 == 5'd0) ? 32'd0 : regs[RS1];
    assign scr2 = (RS2 == 5'd0) ? 32'd0 : regs[RS2];

endmodule
