module control_unit
#(parameter DW = 32)
(
input [DW-1 : 0] inst,
input zero,
output pcsrc,
output memwrite,regwrite,
output  alusrc,
output  [1:0] immsrc,
//output reg [1:0] aluop, 내부 wire
output  [1:0] resultsrc,
	output  [3:0] alu_cont
);

wire [1 :0] aluop;

main_dec U1
#(.DW(DW))
(
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

alu_dec U2
#(.DW(DW))(
.aluop(aluop),  
.inst(inst),
.alu_cont(alu_cont)
);
endmodule