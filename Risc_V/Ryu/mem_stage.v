module IF_STAGE 
#(parameter DW =32)
(
    input pcsrc,
    input clk,
    input rst,
    input pctarget,
    input flush,
    input stall,
    output out_oldpc,
    output out_pcplus4,
    output out_inst

);


wire [DW-1:0] pc;
wire [DW-1:0] pcplus4;
wire [DW-1:0] inst;
wire [DW-1:0] oldpc;

Program_counter PC_UNIT(
  .PCSrc(pcsrc),
  .clk(clk),
  .rst(rst),
  .stall(stall),
  .PCTarget(pctarget),
  .PC(pc),
  .PCPlus4(pcplus4)
);

inst_mem IM_UNIT
(
 .PC(pc),
 .inst(inst)
);
IF_ID_REG REG_U1
(
.clk(clk),
.flush(flush),
.stall(stall), //en_bar
.rst(rst), // asyncronous reset
.in_pcplus4(pcplus4),
.in_oldpc(pc),
.in_inst(inst),

.out_pcplus4(out_pcplus4),
.out_oldpc(out_oldpc),
.out_inst(out_inst)

);

endmodule