module control_unit
#(
    parameter DW = 32
)
(
    input [DW-1:0] inst,
    input zero,
    output pcsrc,
    output memwrite,
    output regwrite,
    output alusrc,
    output [1:0] immsrc,
    output [1:0] resultsrc,
    output [3:0] alu_cont
);

wire [1:0] aluop;

main_dec #(.DW(DW)) U1 (
    .inst(inst),
    .zero(zero),
    .pcsrc(pcsrc),
    .memwrite(memwrite),
    .regwrite(regwrite),
    .alusrc(alusrc),
    .immsrc(immsrc),
    .aluop(aluop),
    .resultsrc(resultsrc)
);

alu_dec #(.DW(DW)) U2 (
    .aluop(aluop),
    .inst(inst),
    .alu_cont(alu_cont)
);

endmodule
