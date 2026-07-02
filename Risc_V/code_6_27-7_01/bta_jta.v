module bta_jta (
    input  wire [31:0] D_PC,
    input  wire [31:0] i_imm,
    input  wire        jalr,
    input  wire [31:0] rs1,
    output wire [31:0] target_address
);
    assign target_address = jalr ? ((rs1 + i_imm) & 32'hffff_fffe) :
                            (D_PC + i_imm);
endmodule
