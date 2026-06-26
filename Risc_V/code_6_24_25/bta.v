module bta (
    input wire [31:0] E_PC,
    input wire [31:0] i_imm,
    output wire [31:0] bta
);
    assign bta = E_PC + i_imm;
endmodule