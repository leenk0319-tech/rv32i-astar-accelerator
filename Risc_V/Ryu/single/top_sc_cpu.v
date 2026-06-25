`timescale 1ns / 1ps

module TOP_SC_CPU
#(
    parameter DW = 32
)
(
    input rst,
    input clk,
    input PC_en,
    output wire [DW-1:0] debug_result,
    output wire [DW-1:0] debug_PC,
    output wire [3:0] flag
);

wire [DW-1:0] PCTarget;
wire [DW-1:0] PCPlus4;
wire [DW-1:0] PC;
wire PCSrc;
wire [DW-1:0] inst;
wire [1:0] immsrc;
wire [DW-1:0] immext;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
reg [DW-1:0] result;
wire regwrite;
wire [DW-1:0] gpr_rs1;
wire [DW-1:0] gpr_rs2;
wire zero;
wire [DW-1:0] in_b;
wire [DW-1:0] alu_result;
wire memwrite;
wire [DW-1:0] read_data;
wire [1:0] resultsrc;
wire alusrc;
wire [3:0] alu_cont;

Program_counter #(.DW(DW)) pcunit (
    .PCSrc(PCSrc),
    .clk(clk),
    .rst(rst),
    .en(PC_en),
    .PCTarget(PCTarget),
    .PC(PC),
    .PCPlus4(PCPlus4)
);

inst_mem #(.DW(DW)) memunit1 (
    .PC(PC),
    .inst(inst)
);

imm_extend #(.DW(DW)) immunit (
    .inst(inst),
    .immsrc(immsrc),
    .immext(immext)
);

assign PCTarget = PC + immext;
assign rs1 = inst[19:15];
assign rs2 = inst[24:20];
assign rd = inst[11:7];

RF32 #(.DW(DW)) regfileunit (
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(result),
    .clk(clk),
    .we(regwrite),
    .rst(rst),
    .gpr_rs1(gpr_rs1),
    .gpr_rs2(gpr_rs2)
);

assign in_b = alusrc ? immext : gpr_rs2;

RISC_V_ALU #(.DW(DW)) aluunit (
    .alu_cont(alu_cont),
    .in_a(gpr_rs1),
    .in_b(in_b),
    .alu_result(alu_result),
    .flag(flag)
);

assign zero = flag[2];

data_mem #(.DW(DW)) memunit2 (
    .clk(clk),
    .memwrite(memwrite),
    .rst(rst),
    .byte_addr(alu_result),
    .wd(gpr_rs2),
    .read_data(read_data)
);

control_unit #(.DW(DW)) control (
    .inst(inst),
    .zero(zero),
    .pcsrc(PCSrc),
    .memwrite(memwrite),
    .regwrite(regwrite),
    .alusrc(alusrc),
    .immsrc(immsrc),
    .resultsrc(resultsrc),
    .alu_cont(alu_cont)
);

always @(*) begin
    case (resultsrc)
        2'b00: result = alu_result;
        2'b01: result = read_data;
        2'b10: result = PCPlus4;
        default: result = {DW{1'b0}};
    endcase
end

assign debug_result = result;
assign debug_PC = PC;

endmodule
