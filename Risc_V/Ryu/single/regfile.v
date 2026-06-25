module RF32 
#(      
    parameter DW = 32,
     parameter RL = 32,
  parameter AW = $clog2(RL)
   
)
(
input [AW-1 :0] rs1,
input [AW-1 :0] rs2,
input [AW-1 :0] rd,
input [DW-1 :0] wd,

input clk,
input we,
input rst,

  output [DW-1 :0] gpr_rs1,
  output [DW-1 :0] gpr_rs2
);

reg [DW-1:0] rf [0 : RL-1];
integer i;
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i=0; i < RL ; i= i+1) begin
        rf[i] <= 0;
      end 
    end
  else if(we) begin
        rf[rd] <= (rd == 0) ? 0 : wd; //이 부분을 정~말 잘짰다.
    end
end

  assign gpr_rs1 = rf[rs1];
  assign gpr_rs2 = rf[rs2];
                   

endmodule