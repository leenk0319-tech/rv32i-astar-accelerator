module ex_stage
#(parameter DW = 32)
(
    input clk,
    input rst,
    input stall,
    input [4:0] rs1_addrE,
    input [4:0] rs2_addrE, //
    input [4:0] rd_addrE,

    input [4:0]    ex_mem_rd,
    input [4:0]    mem_wb_rd,
    input [DW-1:0] ex_mem_data,
    input [DW-1:0] mem_wb_data,
    input ex_mem_regwrite,
    input mem_wb_regwrite,

    input [DW-1:0] rs1_dataE,
    input [DW-1:0] rs2_dataE,
    input [DW-1:0] immE,
    input alusrcE,
    input [3:0] alucontE,

    input [DW-1:0] pcplus4E,
    input          memwriteE,
    input          memreadE,
    input          regwriteE,
    input [1:0]    resultsrcE,
    
    
    
 
    output[DW-1:0]  wd_dataM,
    output [4:0]    rd_addrM,
    output [4:0]    rs2_addrM,
    output          regwriteM,
    output [1:0]    resultsrcM,
    output [DW-1:0] pcplus4M,
    output [DW-1:0] aluresultM,
    output          memwriteM,
    output          memreadM,


    output       ex_memread,
    output       ex_regwrite,
    output [4:0] ex_rd,
    output [3:0] flag //not used
);
wire [DW-1:0] wd_dataE;
assign wd_dataE = rs2_dataE; //SW용 메모리 저장 데이터 

assign ex_rd = rd_addrE;
assign ex_memread = memreadE;
assign ex_regwrite = regwriteE;

wire [DW-1:0] alu_result;
reg [DW-1:0] in_a;
reg [DW-1:0] in_b;
reg [DW-1:0] in_b_b; 
assign in_b = alusrcE ? immE : in_b_b;

always @(*) begin 
    case(condsrc1)
    2'b00   : in_a = rs1_dataE;
    2'b01   : in_a = ex_mem_data;
    2'b10   : in_a = mem_wb_data;
    default : in_a = rs1_dataE;

    endcase

    case(condsrc2) 
    2'b00   : in_b_b = rs2_dataE;
    2'b01   : in_b_b = ex_mem_data;
    2'b10   : in_b_b = mem_wb_data;
    default : in_b_b = rs2_dataE;

    endcase

end 
wire [1:0] condsrc1;
wire [1:0] condsrc2;


ex_fowarding fwd_unit
(

    .ex_mem_rd(ex_mem_rd),
    .mem_wb_rd(mem_wb_rd),
    .ex_rs1(rs1_addrE),
    .ex_rs2(rs2_addrE),
    .mem_regwrite(ex_mem_regwrite),
    .wb_regwrite(mem_wb_regwrite),
    .condsrc1(condsrc1),
    .condsrc2(condsrc2)
);




RISC_V_ALU ALU_UNIT
(
    .alu_cont(alucontE),
    .in_a(in_a), 
    .in_b(in_b),
    .alu_result(alu_result),
    .flag(flag)
);

EX_MEM_REG exmemreg
(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .rs2_addrE(rs2_addrE),
    .memwriteE(memwriteE),
    .memreadE(memreadE),
    .pcplus4E(pcplus4E),                      
    .regwriteE(regwriteE),
    .resultsrcE(resultsrcE),
    .rd_addrE(rd_addrE),
    .wd_dataE(wd_dataE),
    .aluresultE(alu_result),

    .rs2_addrM(rs2_addrM),
    .memwriteM(memwriteM),
    .memreadM(memreadM),
    .wd_dataM(wd_dataM),
    .rd_addrM(rd_addrM),
    .regwriteM(regwriteM),
    .resultsrcM(resultsrcM),
    .pcplus4M(pcplus4M),
    .aluresultM(aluresultM)    
);







endmodule
