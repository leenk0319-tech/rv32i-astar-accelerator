module IF_ID_REG 
#(parameter DW =32)

(
input clk,
input flush,
input stall, //en_bar
input global_rst, // asyncronous reset
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

always @ (posedge clk or posedge global_rst) begin
    if(global_rst) begin
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