`timescale 1ns/1ps

module imm_gen (
    input  wire [31:0] IR,
    output wire [31:0] imm_i,
    output wire [31:0] imm_u
);
    assign imm_i = {{20{IR[31]}}, IR[31:20]};
    assign imm_u = {IR[31:12], 12'b0};

endmodule
