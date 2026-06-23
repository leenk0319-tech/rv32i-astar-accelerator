`timescale 1ns/1ps

// module moduleName #(
//     parameters
// ) (
//     ports
// );
// endmodule


module risc_V_CPU (
    input wire clk_i,
    input wire rstn_i
);
    localparam [6:0] OP_ITYPE = 7'b001_0011;
    localparam [6:0] OP_RTYPE = 7'b011_0011;
    localparam [6:0] OP_LUI   = 7'b011_0111;

    reg [31:0] PC;
    wire [31:0] IR;

    imem #(
        .INIT_FILE("program.hex"),
        .DEPTH(1024)
    ) U_imem (
        .addr(PC),
        .instr(IR)
    );

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i)
            PC <= 32'd0;
        else
            PC <= PC + 32'd4;
    end

    wire [6:0] OP     = IR[6:0];
    wire [4:0] RD     = IR[11:7];
    wire [2:0] funct3 = IR[14:12];
    wire [4:0] RS1    = IR[19:15];
    wire [4:0] RS2    = IR[24:20];
    wire [6:0] funct7 = IR[31:25];

    wire        W_WEN;
    wire [4:0]  W_WA;
    wire [31:0] W_WD;

    wire [31:0] gpr_r1;
    wire [31:0] gpr_r2;

    reg_file U_reg_file (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .RS1(RS1),
        .RS2(RS2),
        .W_WEN(W_WEN),
        .W_WA(W_WA),
        .W_WD(W_WD),
        .scr1(gpr_r1),
        .scr2(gpr_r2)
    );

    wire [31:0] imm_i;
    wire [31:0] imm_u;
    wire [31:0] imm;

    imm_gen U_imm_gen (
        .IR(IR),
        .imm_i(imm_i),
        .imm_u(imm_u)
    );

    assign imm = (OP == OP_LUI) ? imm_u : imm_i;

    wire [31:0] alu_out;

    alu U_alu (
        .src1(gpr_r1),
        .src2(gpr_r2),
        .imm(imm),
        .PC(PC),
        .funct3(funct3),
        .funct7(funct7),
        .OP(OP),
        .alu_out(alu_out)
    );

    assign W_WEN = (OP == OP_RTYPE) || (OP == OP_ITYPE) || (OP == OP_LUI);
    assign W_WA  = RD;
    assign W_WD  = alu_out;

endmodule
