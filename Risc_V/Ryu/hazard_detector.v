module EX_MEM_REG
#(parameter DW =32)
(
input clk,
input rst,
input stall,
input           memwriteE,
input           memreadE,
input [DW-1:0]  pcplus4E,
input           regwriteE,
input [1:0]     resultsrcE,
input [4:0]     rs2_addrE,
input [4:0]     rd_addrE,
input [DW-1:0]  wd_dataE,
input [DW-1:0]  aluresultE,


output          memwriteM,
output          memreadM,
output [DW-1:0] pcplus4M,
output          regwriteM,
output [1:0]    resultsrcM,
output [4:0]    rd_addrM,
output [4:0]    rs2_addrM,
output [DW-1:0] wd_dataM,
output [DW-1:0] aluresultM
);
reg         ex_mem_reg_memwrite;
reg         ex_mem_reg_memread;
reg [DW-1:0]ex_mem_reg_pcplus4;
reg         ex_mem_reg_regwrite;
reg [1:0]   ex_mem_reg_resultsrc;
reg [4:0]   ex_mem_reg_rd_addr;
reg [DW-1:0]ex_mem_reg_wd_data;
reg [DW-1:0]ex_mem_reg_aluresult;
reg [4:0]   ex_mem_reg_rs2_addr;

always @(posedge clk or posedge rst)begin
  if(rst) begin  
ex_mem_reg_rs2_addr <=5'd0;
ex_mem_reg_memwrite <=1'd0;
ex_mem_reg_memread  <=1'd0;
ex_mem_reg_pcplus4  <={DW{1'd0}};
ex_mem_reg_regwrite <=1'd0;
ex_mem_reg_resultsrc<=2'd0;
ex_mem_reg_rd_addr  <=5'd0;
ex_mem_reg_wd_data  <={DW{1'd0}};
ex_mem_reg_aluresult<={DW{1'd0}};

end
else if(!stall) begin
ex_mem_reg_rs2_addr   <= rs2_addrE;
ex_mem_reg_memwrite   <= memwriteE;
ex_mem_reg_memread    <= memreadE;
ex_mem_reg_pcplus4    <= pcplus4E;
ex_mem_reg_regwrite   <= regwriteE;
ex_mem_reg_resultsrc  <= resultsrcE;
ex_mem_reg_rd_addr    <= rd_addrE;
ex_mem_reg_wd_data    <= wd_dataE;
ex_mem_reg_aluresult  <= aluresultE;
end
end 
assign rs2_addrM    =ex_mem_reg_rs2_addr;
assign memwriteM    =ex_mem_reg_memwrite;
assign memreadM     =ex_mem_reg_memread;
assign pcplus4M     =ex_mem_reg_pcplus4;
assign regwriteM    =ex_mem_reg_regwrite;
assign resultsrcM   =ex_mem_reg_resultsrc;
assign rd_addrM     =ex_mem_reg_rd_addr;
assign wd_dataM     =ex_mem_reg_wd_data;
assign aluresultM   =ex_mem_reg_aluresult;

endmodule 