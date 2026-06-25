module ID_STAGE
#(parameter DW =32) 
(
    
    input clk,
    input rst,
    input stallM, 
    input [DW-1:0] in_inst,
    input [DW-1:0] oldpc,
    input [DW-1:0] pcplus4,
    
    input regwriteWB,
    input [DW-1:0] wd_wb,
    input [4:0] rd_wb,
    
    
    input       ex_regwrite,
    input [4:0] ex_rd,
    input [DW-1:0] ex_mem_out,
    input ex_memread,
    
    input [4:0] mem_rd,
    input       mem_regwrite,
    input [DW-1:0] mem_wb_out,
    input mem_memread,


    output [4:0] rs1_addrE,
    output [4:0] rs2_addrE,
    output [4:0] rd_addrE,
    output [DW-1:0] rs1_dataE,
    output [DW-1:0] rs2_dataE,
    output [DW-1:0] immE,
    
    output pc_stall,
    output if_id_stall,
    output if_id_flush,

    output [DW-1:0] pcplus4E,
    output [DW-1:0] pctarget,
    output pcsrc,
    output memwriteE,
    output regwriteE,
    output memreadE,
    output [1:0] resultsrcE,
    output alusrcE,
    output [3:0] alucontE    //내부 신호 immsrc 
);
wire [DW-1:0] rs1_data;
wire [DW-1:0] rs2_data;
wire [4:0] rd_addr;
wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire branch;
wire is_branch;
wire jump;
wire [DW-1:0] imm;

wire memwrite;
wire memread;
wire regwrite;
wire alusrc;
wire [1:0] resultsrc;
wire [3:0] alucont;
wire [1:0]immsrc;
wire [1:0]condsrc1;
wire [1:0]condsrc2;


wire stall;
wire flush;
wire stalli;
assign stalli = stallM || stall;

assign rd_addr = in_inst[11:7];
assign rs1_addr = in_inst[19:15];
assign rs2_addr = in_inst[24:20];




assign pctarget = oldpc + imm;
assign pcsrc = is_branch || jump;



imm_extend immgen
(
.inst(in_inst),
.immsrc(immsrc),
.immext(imm)
);


RF32 reg_file

(
.inst(in_inst),
.clk(clk),
.regwrite(regwriteWB),
.rst(rst),
.rf_wd(wd_wb),
.wb_rd(rd_wb),
.rf_out1(rs1_data),
.rf_out2(rs2_data)
);


control_unit controler
(
.inst(in_inst),
.branch(branch),
.memwrite(memwrite),
.memread(memread),
.regwrite(regwrite),
.alusrc(alusrc),
.immsrc(immsrc),
.jump(jump),
.resultsrc(resultsrc),
.alu_cont(alucont)
);

br_cond comprator
(   
    .branch(branch),
    .condsrc1(condsrc1),
    .condsrc2(condsrc2),
    .rf_out1(rs1_data),
    .rf_out2(rs2_data),
    .ex_mem_out(ex_mem_out),
    .mem_wb_out(mem_wb_out),

    .is_branch(is_branch)
);  
    
hazard_unit hazardunit
(
.branch(branch),
.jump(jump),
.is_branch(is_branch),
.ex_memread(ex_memread),
.ex_regwrite(ex_regwrite),
.mem_memread(mem_memread),

.ex_rd(ex_rd),
.rf_rs1(rs1_addr),
.rf_rs2(rs2_addr),
.mem_rd(mem_rd),


.id_ex_stall(stall),
.id_ex_flush(flush),
.pc_stall(pc_stall),
.if_id_stall(if_id_stall),
.if_id_flush(if_id_flush)

);


id_fowarding forwaring_unit
(

    .ex_rd(ex_rd),
    .mem_rd(mem_rd),
    .rf_rs1(rs1_addr),
    .rf_rs2(rs2_addr),
    .mem_regwrite(mem_regwrite),
    .ex_regwrite(ex_regwrite),
    .condsrc1(condsrc1),
    .condsrc2(condsrc2)
);

ID_EX_REG idexreg

(
    .clk(clk),
    .rst(rst),
    .stall(stalli),
    .flush(flush),
    .pcplus4(pcplus4),
    .imm(imm),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .memwrite(memwrite),
    .memread(memread),
    .regwrite(regwrite),
    .resultsrc(resultsrc),
    .alusrc(alusrc),
    .alucont(alucont),



    .rs1_addrD (rs1_addrE),
    .rs2_addrD (rs2_addrE),
    .rd_addrD  (rd_addrE),
    .rs1_dataD (rs1_dataE),
    .rs2_dataD (rs2_dataE),
    .immD(immE),
    
    .pcplus4D(pcplus4E),
    .memwriteD(memwriteE),
    .memreadD(memreadE), 
    .regwriteD(regwriteE),
    .resultsrcD(resultsrcE),
    .alusrcD(alusrcE),
    .alucontD(alucontE)


);
endmodule