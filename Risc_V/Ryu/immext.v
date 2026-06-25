module main_dec #(
    parameter DW = 32
)(
    input  wire [DW-1 : 0] inst,

	output              branch,
	output              jump,
    output              memwrite,
    output              memread,
    output              regwrite,
    output              alusrc,
    output   [1:0]      immsrc,
    output   [1:0]      aluop,
    output   [1:0]      resultsrc
);

    // Opcode 정의
    localparam lw = 7'b000_0011;
    localparam sw = 7'b010_0011;
    localparam r  = 7'b011_0011;
    localparam i  = 7'b001_0011;
    localparam b  = 7'b110_0011;
    localparam j  = 7'b110_1111;

    wire [6:0] opcode;

    
    // [핵심] 제어 신호를 한 방에 묶어서 관리하기 위한 임시 벡터
    // 순서: RegWrite | ImmSrc(2) | ALUSrc | MemWrite | ResultSrc(2) | Branch | ALUOp(2) | Jump
    reg [11:0] controls; 

    assign opcode = inst[6:0];

    // controls 벡터를 쪼개서 각 포트에 연결
 assign {regwrite, immsrc, alusrc, memwrite, resultsrc, branch, aluop, jump, memread} = controls;
   

    // 진리표를 그대로 옮긴 Case 문
    always @(*) begin
        case(opcode)
            //                   RegWr ImmSrc ALUSrc MemWr ResSrc Branch ALUOp Jump memread
            lw      : controls = 12'b1_00_1_0_01_0_00_0_1;
            sw      : controls = 12'b0_01_1_1_00_0_00_0_0; // ResSrc는 x 대신 00 (안전)
            r       : controls = 12'b1_00_0_0_00_0_10_0_0; // ImmSrc는 x 대신 00
            b       : controls = 12'b0_10_0_0_00_1_00_0_0;
            j       : controls = 12'b1_11_0_0_10_0_00_1_0; // Jal (ALUOp x 대신 00)
            i       : controls = 12'b1_00_1_0_00_0_10_0_0; // Addi
            
            default : controls = 12'b0_00_0_0_00_0_00_0_0; // NOP (안전하게 0 초기화)
        endcase
    end

endmodule

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


module control_unit
#(parameter DW = 32)
(
input [DW-1 : 0] inst,
output memwrite,
output regwrite,
output memread,
output  alusrc,
output  [1:0] immsrc,
//output reg [1:0] aluop, 내부 wire
output  [1:0] resultsrc,
output  [3:0] alu_cont,
output jump,
output branch
);

wire [1 :0] aluop;

main_dec U1
(
.inst(inst),
.jump(jump),
.branch(branch),
.memwrite(memwrite),
.memread(memread),
.regwrite(regwrite),
.alusrc(alusrc),
.immsrc(immsrc),
.aluop(aluop),
.resultsrc(resultsrc)
);

alu_dec U2
(
.aluop(aluop),
.inst(inst),
.alu_cont(alu_cont)


);
endmodule