module IF_STAGE 
#(parameter DW =32)
(
    input pcsrc,
    input clk,
    input rst,
    input [DW-1:0] pctarget,
    input flush,
    input stall,
    output [DW-1:0] out_oldpc,
    output [DW-1:0] out_pcplus4,
    output [DW-1:0] out_inst

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

module Program_counter #(
  parameter DW = 32,
  parameter PC_BASE = 32'h00000000)
  (
  input 				PCSrc,
  input 				clk,rst,stall,
    input      [DW-1 : 0] PCTarget,
  output reg [DW-1 : 0] PC,
  output     [DW-1 : 0] PCPlus4
 
);
  wire [DW-1 :0] PCNext;
 assign PCPlus4 = PC + 4;
  assign PCNext = PCSrc ? PCTarget : PCPlus4;
  always @(posedge clk or posedge rst) begin
    if(rst)
      PC <= PC_BASE;
    else if(!stall)
      PC <= PCNext;
    end 

endmodule

module IF_ID_REG 
#(parameter DW =32)

(
input clk,
input flush,
input stall, //en_bar
input rst, // asyncronous reset
input [DW-1:0] in_pcplus4,
input [DW-1:0] in_oldpc,
input [DW-1:0] in_inst,

output  [DW-1:0] out_pcplus4,
output  [DW-1:0] out_oldpc,
output  [DW-1:0] out_inst



);
localparam NOP = 32'h0000_0013;

reg [DW-1:0] ifidreg_pcplus4; 
reg [DW-1:0] ifidreg_oldpc;
reg [DW-1:0] ifidreg_inst;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
    ifidreg_pcplus4 <= {DW{1'b0}}; 
    ifidreg_oldpc   <= {DW{1'b0}};
    ifidreg_inst    <=  NOP;
   end
   else if(flush) begin
    ifidreg_pcplus4 <= {DW{1'b0}}; 
    ifidreg_oldpc   <= {DW{1'b0}};
    ifidreg_inst    <=  NOP;
   end 


    else if (!stall) begin
    ifidreg_pcplus4 <= in_pcplus4;
    ifidreg_oldpc   <= in_oldpc;
    ifidreg_inst    <= in_inst;
    end 
   end 
   
   

assign out_pcplus4 = ifidreg_pcplus4;
assign out_oldpc   = ifidreg_oldpc;
assign out_inst    = ifidreg_inst;
 
endmodule

module inst_mem 
#(parameter DW     = 32,
  parameter DEPTH = 256)
(
input       [DW-1 : 0]    PC,
output wire [DW-1 :0]     inst
);

localparam AW = $clog2(DEPTH);

wire [AW-1 :0 ] addr;
assign addr = PC[AW +1 : 2];

reg [DW-1 :0] rom [0:DEPTH -1];
assign inst = rom[addr];
initial begin 
 $readmemh("program.hex", rom); 
end

endmodule