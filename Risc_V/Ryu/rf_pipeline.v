module hazard_unit
#(parameter AW = 5)
(
input jump,
input is_branch,
input branch,
input ex_memread,
input ex_regwrite,
input mem_memread,

input [AW-1 : 0] ex_rd,
input [AW-1 : 0] rf_rs1,
input [AW-1 : 0] rf_rs2,
input [AW-1 : 0] mem_rd,


output reg id_ex_stall,
output reg id_ex_flush,
output reg pc_stall,
output reg if_id_stall,
output reg if_id_flush

);
localparam yes = 1'b1;
localparam no   = 1'b0;

wire load_use_hazard;
wire control_hazard;
wire branch_cond_hazard;
wire ex_rf_eq;
wire mem_rf_eq;
assign mem_rf_eq = ((mem_rd == rf_rs1) && rf_rs1 !=5'd0) || ((mem_rd == rf_rs2) && (rf_rs2 != 5'd0));
assign ex_rf_eq = (((ex_rd == rf_rs1) && rf_rs1 != 5'd0) || ((ex_rd == rf_rs2) && rf_rs2 != 5'd0));
assign control_hazard = (jump || is_branch);
assign load_use_hazard = ex_memread && ex_rf_eq;
assign branch_cond_hazard = branch && ((ex_rf_eq && ex_regwrite) || (mem_rf_eq && mem_memread));
//load-use hazard Unit   
always @(*) begin
   pc_stall      = no;
   if_id_stall = no;
   if_id_flush = no;
   id_ex_stall = no;
   id_ex_flush = no;

if(load_use_hazard || branch_cond_hazard) begin
      pc_stall =      yes;
      if_id_stall = yes;
      id_ex_flush = yes;
end
else if(control_hazard) begin
      if_id_flush = yes;
end 

end   
endmodule