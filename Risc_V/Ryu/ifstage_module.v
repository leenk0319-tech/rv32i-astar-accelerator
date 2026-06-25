module ID_EX_REG 
#(parameter DW =32)

(
    input clk,
    input rst,
    input flush,
    input stall,
    input [DW-1:0] pcplus4,
    input [DW-1:0] imm,
    input [4:0]    rd_addr,
    input [4:0]    rs1_addr,
    input [4:0]    rs2_addr,
    input [DW-1:0] rs1_data,
    input [DW-1:0] rs2_data,
    input          memwrite,
    input          memread,
    input          regwrite,
    input [1:0]    resultsrc,
    input          alusrc,
    input [3:0]         alucont,



    output [4:0]    rs1_addrD,
    output [4:0]    rs2_addrD,
    output [4:0]    rd_addrD,
    output [DW-1:0] rs1_dataD,
    output [DW-1:0] rs2_dataD,
    output [DW-1:0]     immD,
    output [DW-1:0] pcplus4D,
    output          memwriteD,
    output          memreadD, 
    output          regwriteD,
    output [1:0]    resultsrcD,
    output          alusrcD,
    output [3:0]    alucontD


);
localparam NOP = 32'h0000_0013;

reg [DW-1:0]    idexreg_pcplus4; 
reg [DW-1:0]    idexreg_imm; 
reg [4:0]       idexreg_rs1_addr; 
reg [4:0]       idexreg_rs2_addr; 
reg [DW-1:0]    idexreg_rs1_data; 
reg [DW-1:0]    idexreg_rs2_data; 
reg             idexreg_memwrite; 
reg             idexreg_memread; 
reg             idexreg_regwrite; 
reg [1:0]       idexreg_resultsrc; 
reg             idexreg_alusrc; 
reg [3:0]       idexreg_alucont;  
reg [4:0]       idexreg_rd_addr;



always @ (posedge clk or posedge rst) begin
    if(rst) begin
idexreg_rd_addr   <= 5'd0  ;
idexreg_pcplus4   <= {DW{1'b0}};   
idexreg_imm       <= {DW{1'b0}};   
idexreg_rs1_addr  <= 5'd0  ; 
idexreg_rs2_addr  <= 5'd0  ; 
idexreg_rs1_data  <= {DW{1'b0}}; 
idexreg_rs2_data  <= {DW{1'b0}};   
idexreg_memwrite  <= 1'd0  ; 
idexreg_memread   <= 1'd0  ; 
idexreg_regwrite  <= 1'd0  ; 
idexreg_resultsrc <= 2'd0  ;
idexreg_alusrc    <= 1'd0  ; 
idexreg_alucont   <= 4'd0  ;      
    end
   else if(flush) begin 
idexreg_pcplus4   <= {DW{1'b0}};   
idexreg_imm       <= {DW{1'b0}}; 
idexreg_rd_addr   <= 5'd0  ;
idexreg_rs1_addr  <= 5'd0  ; 
idexreg_rs2_addr  <= 5'd0  ; 
idexreg_rs1_data  <= {DW{1'b0}};   
idexreg_rs2_data  <= {DW{1'b0}};   
idexreg_memwrite  <= 1'd0  ; 
idexreg_memread   <= 1'd0  ; 
idexreg_regwrite  <= 1'd0  ; 
idexreg_resultsrc <= 2'd0  ;
idexreg_alusrc    <= 1'd0  ; 
idexreg_alucont   <= 4'd0  ; 
   end 


    else if (!stall) begin
idexreg_rd_addr   <= rd_addr;
idexreg_pcplus4   <=  pcplus4;
idexreg_imm       <=      imm;
idexreg_rs1_addr  <= rs1_addr;
idexreg_rs2_addr  <= rs2_addr;
idexreg_rs1_data  <= rs1_data;
idexreg_rs2_data  <= rs2_data;
idexreg_memwrite  <= memwrite;
idexreg_memread   <=  memread;
idexreg_regwrite  <= regwrite;
idexreg_resultsrc <=resultsrc;
idexreg_alusrc    <=   alusrc;
idexreg_alucont   <=  alucont;

    end 
   end 
assign rd_addrD   = idexreg_rd_addr;
assign rs1_addrD  = idexreg_rs1_addr ;
assign rs2_addrD  = idexreg_rs2_addr ;

assign rs1_dataD  =idexreg_rs1_data ;
assign rs2_dataD  =idexreg_rs2_data ;
assign     immD   =idexreg_imm;
assign pcplus4D   = idexreg_pcplus4;
assign memwriteD  =idexreg_memwrite; 
assign memreadD   =idexreg_memread  ;
assign regwriteD  =idexreg_regwrite ;
assign resultsrcD =idexreg_resultsrc;
assign alusrcD    =idexreg_alusrc   ;
assign alucontD   =idexreg_alucont   ;  
   



 
endmodule