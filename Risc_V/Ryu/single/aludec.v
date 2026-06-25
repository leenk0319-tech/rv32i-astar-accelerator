module alu_dec
#(parameter DW = 32)
(
 input [1    :0] aluop,
 input [DW-1 :0] inst,
 output reg [3:0] alu_cont
);
    
localparam op_or =  4'b0001;
localparam op_add = 4'b0010; //add = 0010;
localparam op_sub = 4'b0110; //sub = 0110;
localparam op_slt = 4'b0111;
localparam op_srl = 4'b1000;
localparam op_sll = 4'b1001;
localparam op_sra = 4'b1010;
localparam op_and = 4'b1100; 
localparam op_xor = 4'b1101;
localparam op_sltu =4'b0011;
wire [2:0] funct3;
wire       funct7; // 5번 비트만 Op sel code
wire       op5;
assign funct3 = inst[14:12];
assign funct7 = inst [30]; 
assign op5    = inst [5];
wire [6:0] cond;
assign cond = {aluop,funct3,op5,funct7};
always @ (*) begin
casez(cond) 
    7'b00_???_?_? : alu_cont = op_add; //lw,sw
    7'b01_???_?_? : alu_cont = op_sub; //beq
    7'b10_000_1_1: alu_cont = op_sub; //r-type sub
    7'b10_000_1_0: alu_cont = op_add;//r-type add
    7'b10_000_0_?: alu_cont = op_add;//i-type add 
    7'b10_001_?_?: alu_cont = op_sll;
    7'b10_010_?_?: alu_cont = op_slt;
    7'b10_011_?_?: alu_cont = op_sltu;
    7'b10_100_?_?: alu_cont = op_xor;
    7'b10_101_?_0: alu_cont = op_srl;
    7'b10_101_?_1: alu_cont = op_sra;
    7'b10_110_?_?: alu_cont = op_or;
    7'b10_111_?_?: alu_cont = op_and;


    default : alu_cont = 4'b0000; //No op ALU result -> 32'd0; 



endcase


end
endmodule