//  id/ex pipeline reg에서 rs1 rs2, 
//  ex/mem의 rd 와 controll signal(regwrite), mem/wb의 rd 와 control signal(regwrite)
//  출력으로는 alu의 mux에서 선택하는 신호를 주면됨. 
//  00: id/ex
//  10: ex/mem
//  01: mem/wb
module Forwarding_unit (
    input wire e_m_regwrite, m_w_regwrite,
    input wire [4:0] i_e_rs1, i_e_rs2,
    input wire [4:0] e_m_rd, m_w_rd,
    output reg [1:0] mux_select_signal1,
    output reg [1:0] mux_select_signal2
);
    always @(*) begin
    mux_select_signal1 = 2'b00;
    mux_select_signal2 = 2'b00;

    //우선순위가 e_m에서 포워딩하는게 먼저임 그래서 뒤에 e_m을 배치해서 덮어써지게 구현했음
    
    if (m_w_regwrite && (m_w_rd != 5'd0) && (i_e_rs1 == m_w_rd))
        mux_select_signal1 = 2'b01;
    if (m_w_regwrite && (m_w_rd != 5'd0) && (i_e_rs2 == m_w_rd))
        mux_select_signal2 = 2'b01;

    if (e_m_regwrite && (e_m_rd != 5'd0) && (i_e_rs1 == e_m_rd))
        mux_select_signal1 = 2'b10;
    if (e_m_regwrite && (e_m_rd != 5'd0) && (i_e_rs2 == e_m_rd))
        mux_select_signal2 = 2'b10;
    end
endmodule