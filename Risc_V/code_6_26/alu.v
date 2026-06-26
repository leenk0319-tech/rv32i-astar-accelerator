//  추가해야될 내용: 데이터 포워딩
//  먹스로 선택하게 구현해야함 (00 10 01) -> 선택해서 alu에집어 넣어준다. 
//  입력이 muxselect signal 1 2 받아야함.
//  포워딩할 값 32비트를 받아야함. e_m_reg1,2 m_w_reg1 2
//  00: id/ex
//  10: ex/mem
//  01: mem/wb

module alu (
    input wire [1:0] mux_select_signal1, mux_select_signal2,
    input wire [31:0] m_alu_out,
    input wire [31:0] w_writedata,
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

    reg [31:0] forwarding_r1, forwarding_r2;
    wire [31:0] rdata2;

    assign rdata2 = (i_alu_src) ? i_imm : forwarding_r2;

    always @ (*) begin 
        case(mux_select_signal1)
            2'b00: forwarding_r1 = i_rdata1;
            2'b10: forwarding_r1 = m_alu_out;
            2'b01: forwarding_r1 = w_writedata;
            default: forwarding_r1 = 32'd0;
        endcase

        case(mux_select_signal2)
            2'b00: forwarding_r2 = i_rdata2;
            2'b10: forwarding_r2 = m_alu_out;
            2'b01: forwarding_r2 = w_writedata;
            default: forwarding_r2 = 32'd0;
        endcase
    end
    always @ (*) begin
        case(i_alu_signal)
            4'b0000: alu_out = forwarding_r1 & rdata2;  //and
            4'b0001: alu_out = forwarding_r1 | rdata2;  //or
            4'b0010: alu_out = forwarding_r1 + rdata2;  //add
            4'b0110: alu_out = forwarding_r1 - rdata2;  //sub
            4'b0011: alu_out = forwarding_r1 ^ rdata2;  //xor
            4'b0100: alu_out = forwarding_r1 << rdata2;  //sll
            default: alu_out =32'd0; 
        endcase
        o_rdata2 =forwarding_r2; // store용도 
    end


    always @ (*) begin
        branch_condition =1'd0;
        if(branch)
           case (funct3)
                3'b000: branch_condition = (forwarding_r1 == forwarding_r2); // BEQ
                3'b001: branch_condition = (forwarding_r1 != forwarding_r2); // BNE
                3'b100: branch_condition = ($signed(forwarding_r1) <  $signed(forwarding_r2)); // BLT
                3'b101: branch_condition = ($signed(forwarding_r1) >= $signed(forwarding_r2)); // BGE
                default: branch_condition = 1'd0;
            endcase
    end


endmodule
