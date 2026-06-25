module RF32 
#(      
    parameter  DW = 32,
     parameter RL = 32,
  parameter    AW = $clog2(RL)
   
)
(
/*input [AW-1 :0] rs1,
input [AW-1 :0] rs2,
input [AW-1 :0] rd,
*/ 

input [DW-1:0] inst
,
input clk,
input regwrite,
input rst,
input  [DW-1 :0] rf_wd,

input  [AW-1 :0] wb_rd,
output [DW-1 :0] rf_out1,
output [DW-1 :0] rf_out2
);
wire [AW-1:0] rs1;
wire [AW-1:0] rs2;
assign rs1 = inst[19:15];
assign rs2 = inst[24:20];


reg [DW-1:0] rf [0 : RL-1];
integer i;
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i=0; i < RL ; i= i+1) begin
        rf[i] <= 0;
      end 
    end
  else if(regwrite) begin
        rf[wb_rd] <= (wb_rd == 0) ? 0 : rf_wd; //이 부분을 정~말 잘짰다.
    end
end
//internal Forwarding logic 원래는 Clock cycle 전반부에 (negedge clk) 로 짜려햇는데
//물어보니까 FPGA에서 위험할 수도 있다고 하니, 이렇게 추가 logic을 달앗다.
  assign rf_out1 = (regwrite && (wb_rd != 5'd0)) && (rs1== wb_rd) ? rf_wd : rf[rs1];
  assign rf_out2 = (regwrite && (wb_rd != 5'd0)) && (rs2== wb_rd) ? rf_wd : rf[rs2]; 
            

endmodule