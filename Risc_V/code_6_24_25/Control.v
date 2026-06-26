module Control(
    input wire [6:0] i_op,
    input wire [2:0] i_funct3,
    input wire [6:0] i_funct7,
    input wire [4:0] i_rs1, i_rs2,
    input wire [4:0] i_rd,

    output reg alusrc,  //   0: rs2 1: imm
    output reg branch,  
    output reg [1:0] aluop, // 00:sd ld, 01: beq 10: rtype
    // output wire zero, 이건 alu에서 하는게 맞는듯 
    output reg memwrite,
    output reg memread,
    output reg memtoreg,
    output reg regwrite   //regwrite alusrc zero(애는 beq용) alucontrol branch memwrite memread memtoreg 
);

    localparam [6:0] OP_LOAD   = 7'b000_0011; // LW
    localparam [6:0] OP_ITYPE  = 7'b001_0011; // ADDI, SLLI, XORI, ORI, ANDI
    localparam [6:0] OP_STORE  = 7'b010_0011; // SW
    localparam [6:0] OP_RTYPE  = 7'b011_0011; // ADD, SUB, XOR, OR, AND
    localparam [6:0] OP_LUI    = 7'b011_0111; // LUI
    localparam [6:0] OP_BRANCH = 7'b110_0011; // BEQ, BNE, BLT, BGE
    localparam [6:0] OP_JALR   = 7'b110_0111; // JALR
    localparam [6:0] OP_JAL    = 7'b110_1111; // JAL

    // funct3 - ALU / I-type
    localparam [2:0] F3_ADD_SUB = 3'b000; // ADD, SUB, ADDI
    localparam [2:0] F3_SLL     = 3'b001; // SLLI
    localparam [2:0] F3_XOR     = 3'b100; // XOR, XORI
    localparam [2:0] F3_OR      = 3'b110; // OR, ORI
    localparam [2:0] F3_AND     = 3'b111; // AND, ANDI

    // funct3 - memory
    localparam [2:0] F3_LW = 3'b010;
    localparam [2:0] F3_SW = 3'b010;

    // funct3 - branch
    localparam [2:0] F3_BEQ = 3'b000;
    localparam [2:0] F3_BNE = 3'b001;
    localparam [2:0] F3_BLT = 3'b100;
    localparam [2:0] F3_BGE = 3'b101;

    // funct3 - JALR
    localparam [2:0] F3_JALR = 3'b000;

    // funct7
    localparam [6:0] F7_ADD  = 7'b000_0000;
    localparam [6:0] F7_SUB  = 7'b010_0000;
    localparam [6:0] F7_LOGIC = 7'b000_0000; // AND, OR, XOR
    localparam [6:0] F7_SLLI = 7'b000_0000;

    always@(*) begin
        case (i_op) 
            OP_LOAD: begin
                // LW: rd = MEM[rs1 + imm]
                alusrc   = 1'b1;
                branch   = 1'b0;
                aluop    = 2'b00;   // ADD 주소계산
                memwrite = 1'b0;
                memread  = 1'b1;
                memtoreg = 1'b1;
                regwrite = 1'b1;
            end

            OP_STORE: begin
                // SW: MEM[rs1 + imm] = rs2
                alusrc   = 1'b1;
                branch   = 1'b0;
                aluop    = 2'b00;   // ADD 주소계산
                memwrite = 1'b1;
                memread  = 1'b0;
                memtoreg = 1'b0;    // 의미 없음
                regwrite = 1'b0;
            end

            OP_RTYPE: begin
                // ADD, SUB, AND, OR, XOR
                alusrc   = 1'b0;
                branch   = 1'b0;
                aluop    = 2'b10;   // R-type은 funct3/funct7로 ALUControl에서 결정
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;
                regwrite = 1'b1;
            end

            OP_ITYPE: begin
                // ADDI, ANDI, ORI, XORI
                alusrc   = 1'b1;
                branch   = 1'b0;
                aluop    = 2'b11;   // I-type은 funct3로 ALUControl에서 결정
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;
                regwrite = 1'b1;
            end

            OP_BRANCH: begin
                // BEQ, BNE, BLT, BGE
                alusrc   = 1'b0;
                branch   = 1'b1;
                aluop    = 2'b01;   // branch 비교용
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;
                regwrite = 1'b0;
            end

            OP_LUI: begin
                // LUI: rd = imm << 12
                alusrc   = 1'b1;
                branch   = 1'b0;
                aluop    = 2'b11;   // 주의: LUI는 ALUControl에서 따로 처리 필요
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;
                regwrite = 1'b1;
            end

            OP_JAL: begin
                // JAL: rd = PC + 4, PC = PC + imm
                alusrc   = 1'b0;
                branch   = 1'b1;    // 일단 PC 변경 계열로 표시
                aluop    = 2'b00;
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;    // 주의: PC+4 writeback mux 따로 필요
                regwrite = 1'b1;
            end

            OP_JALR: begin
                // JALR: rd = PC + 4, PC = rs1 + imm
                alusrc   = 1'b1;
                branch   = 1'b1;    // 일단 PC 변경 계열로 표시
                aluop    = 2'b00;   // rs1 + imm
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;    // 주의: PC+4 writeback mux 따로 필요
                regwrite = 1'b1;
            end

            default: begin
                // illegal instruction or NOP
                alusrc   = 1'b0;
                branch   = 1'b0;
                aluop    = 2'b00;
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;
                regwrite = 1'b0;
            end

        endcase
    end


endmodule
