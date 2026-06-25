module alu (
    input wire [2:0] funct3,
    input wire [3:0] i_alu_signal,
    input wire [31:0] i_rdata1, i_rdata2,
    input wire [31:0] i_imm,  //imm_gen에서 오는거 id_ex 레그에 저장했다가 받음 mux로 i_data2랑 imm중에서 선택
    input wire i_alu_src,  //선택하는 컨트롤 신호 
    input wire branch,     // branch
    output reg  [31:0] alu_out,
    output reg  [31:0] o_rdata2,
    output reg branch_condition
);

//나중에 이코드를 쪼개야될듯 모듈 별로 세세하게 
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
    
    // 일단 이번에는 ADD SUB AND OR XOR SLL만 구현
    reg [31:0] rdata2;
    always @ (*) begin
        if(i_alu_src)  //1이면 imm 0이면 rdata2
            rdata2 = i_imm;
        else
            rdata2 = i_rdata2;
        case(i_alu_signal)
            4'b0000: alu_out = i_rdata1 & rdata2;  //and
            4'b0001: alu_out = i_rdata1 | rdata2;  //or
            4'b0010: alu_out = i_rdata1 + rdata2;  //add
            4'b0110: alu_out = i_rdata1 - rdata2;  //sub
            4'b0011: alu_out = i_rdata1 ^ rdata2;  //xor
            4'b0100: alu_out = i_rdata1 << rdata2;  //sll
            default: alu_out =4'd0; 
        endcase
        o_rdata2 =i_rdata2; // store용도 
    end
    always @ (*) begin
        branch_condition =1'd0;
        if(branch)
           case (funct3)
                3'b000: branch_condition = (i_rdata1 == rdata2); // BEQ
                3'b001: branch_condition = (i_rdata1 != rdata2); // BNE
                3'b100: branch_condition = ($signed(i_rdata1) <  $signed(rdata2)); // BLT
                3'b101: branch_condition = ($signed(i_rdata1) >= $signed(rdata2)); // BGE
                default: branch_condition = 1'd0;
            endcase
    end


endmodule