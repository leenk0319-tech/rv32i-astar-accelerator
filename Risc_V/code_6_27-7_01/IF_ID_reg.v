module IF_ID_reg  (
    input clk_i,
    input rstn_i,
    input F_flush,
    input if_id_write_load,   //애가 0이면 똑같은거 한번 더하게끔. (ID/EX에는 버블 들어가게)
    input if_id_write_branch,
    input [31:0] i_F_PC,
    input [31:0] i_F_IR,

    output reg [31:0] o_D_PC,
    output reg [31:0] o_D_IR
);

    localparam [31:0] NOP = 32'h00000013;

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            o_D_PC <= 32'd0;
            o_D_IR <= NOP; // NOP
        end
        else if ((!if_id_write_load) || (!if_id_write_branch)) begin
            o_D_IR <= o_D_IR;
            o_D_PC <= o_D_PC;
        end
        else if (F_flush) begin
            o_D_PC <= 32'd0;
            o_D_IR <= NOP; // NOP
        end
        else begin
            o_D_PC <= i_F_PC;
            o_D_IR <= i_F_IR;
        end
    end
endmodule

// NOP 처리방식  (000000000000 00000 000 00000 0010011)  -> 16진수로 00000013
// imm[11:0] = 000000000000
// rs1       = 00000  // x0
// funct3    = 000
// rd        = 00000  // x0
// opcode    = 0010011 // I-type ALU
