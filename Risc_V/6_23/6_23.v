`timescale 1ns/1ps

module risc_V_CPU_draft # (
    parameter FIRMWARE = "" 
)(
    input clk_i, 
    input rstn_i
);

// ============================================================
// RV32I subset opcode / funct3 / funct7
// Instructions: 19개
// ADD, SUB, AND, OR, XOR
// ADDI, SLLI, XORI, ORI, ANDI
// LUI
// LW, SW
// BEQ, BNE, BLT, BGE
// JAL, JALR
// ============================================================


localparam IMSZ = 16;
// opcode
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

//IF stage
    //imem에서 데이터 읽어오는 방식으로.
    
    reg [31:0] PC;
    always @(posedge clk_i or negedge rstn_i) begin
        if(!rstn_i) begin
            PC <= 32'd0;
        end
        else 
            PC <= PC + 32'd4;
    end
    wire [31:0] IR;
    
    
    imem #(
        .INIT_FILE("program.hex"),
        .DEPTH(1024)
    ) 
    U_imem (
        .addr(PC),
        .instr(IR)
    );
//ID stage
    wire [6:0] OP = IR[6:0];
    wire [4:0] RD = IR[11:7];
    wire [2:0] funct3 = IR[14:12];
    wire [4:0] RS1 = IR[19:15];
    wire [4:0] RS2 = IR[24:20];
    wire [6:0] funct7 = IR [31:25];

    reg [31:0] GPR [0:31];   // 레지스터 32개임 5비트잖아 레지스터 번호가 
    wire W_WEN;
    wire [4:0] W_WA;
    wire [31:0] W_WD;
    integer k;
    always @(posedge clk_i or negedge rstn_i) begin
        if(!rstn_i) begin
            for(k=0; k<32; k=k+1)
                GPR[k] <= 32'd0;
        end
        else if(W_WEN) begin
            GPR[W_WA] <= W_WD;
        end
    end
//EX stage
    reg [31:0] alu_out;
    
    // 코드 검증 및 시뮬레이션을 위해 필요한 내부 와이어 정의 (임시 매핑)
    wire [31:0] src1 = GPR[RS1];
    wire [31:0] src2 = GPR[RS2];
    wire [31:0] imm = 32'd0; // 실제 구현 시 상단에 Immediate Generator 로직을 연결하세요.

    always @(*) begin
        alu_out = 32'd0;
        case(OP)
            OP_RTYPE: begin                 //R-type
                case(funct3)                 //R-type 애들 func3로 비교 
                    F3_ADD_SUB: begin
                        case(funct7)        //funct3까지 같은 애들 예) addsub이런애들 비교 funct 7로
                            F7_ADD:  alu_out = src1 + src2;
                            F7_SUB:  alu_out = src1 - src2;
                            default: alu_out = 32'd0;
                        endcase
                    end
                    F3_AND:  alu_out = src1 & src2;
                    F3_OR:   alu_out = src1 | src2;
                    F3_XOR:  alu_out = src1 ^ src2;
                    F3_SLL:  alu_out = src1 << src2[4:0];
                    default: alu_out = 32'd0;
                endcase
            end

            OP_ITYPE: begin                 //I-type
                case(funct3)
                    F3_ADD_SUB: alu_out = src1 + imm;
                    F3_AND:     alu_out = src1 & imm;
                    F3_OR:      alu_out = src1 | imm;
                    F3_XOR:     alu_out = src1 ^ imm;
                    F3_SLL:     alu_out = src1 << imm[4:0];
                    default:    alu_out = 32'd0;
                endcase
            end

            OP_LOAD: begin                  //I -type중 로드만
                case(funct3)
                    F3_LW:   alu_out = src1 + imm;
                    default: alu_out = 32'd0;
                endcase
            end

            OP_STORE: begin                 //S -type (store)
                case(funct3)
                    F3_SW:   alu_out = src1 + imm;
                    default: alu_out = 32'd0;
                endcase
            end

            OP_BRANCH: begin                //SB 타입
                case(funct3)
                    F3_BEQ:  alu_out = (src1 == src2) ? (PC + imm) : (PC + 32'd4);
                    F3_BNE:  alu_out = (src1 != src2) ? (PC + imm) : (PC + 32'd4);
                    F3_BLT:  alu_out = ($signed(src1) < $signed(src2)) ? (PC + imm) : (PC + 32'd4);
                    F3_BGE:  alu_out = ($signed(src1) >= $signed(src2)) ? (PC + imm) : (PC + 32'd4);
                    default: alu_out = 32'd0;
                endcase
            end

            OP_LUI: begin           //U type (LUI)
                alu_out = imm;
            end

            OP_JAL: begin           //UJ 타입 JAL
                alu_out = PC + 32'd4;
            end

            OP_JALR: begin      //I 타입 JALR
                case(funct3)
                    F3_JALR: alu_out = PC + 32'd4;
                    default: alu_out = 32'd0;
                endcase
            end

            default: begin              //래치 방지 
                alu_out = 32'd0;
            end
        endcase
    end


    //mem 일단 생략 로드 스토어는 나중에할게요

    //WB stage
    assign W_WEN = (OP == OP_RTYPE) || (OP == OP_ITYPE) || (OP == OP_LOAD); 
    assign W_WD = alu_out;
    assign W_WA = RD;


endmodule
