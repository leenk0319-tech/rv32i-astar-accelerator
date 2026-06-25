module Program_counter #(
  parameter DW = 32,
  parameter PC_BASE = 32'h00000000)
  (
  input 				PCSrc,
  input 				clk,rst,en,
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
    else if(en)
      PC <= PCNext;
    end 

endmodule