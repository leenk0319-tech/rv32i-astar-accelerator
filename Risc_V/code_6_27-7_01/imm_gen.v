module imm_gen (
    input  wire [31:0] IR,
    input  wire [6:0]  OP,
    output reg  [31:0] o_imm
);
    always @(*) begin
        case (OP)
            7'b0000011: o_imm = {{20{IR[31]}}, IR[31:20]};                         // LW, JALR, I-type
            7'b0010011: o_imm = {{20{IR[31]}}, IR[31:20]};                         // ADDI, ANDI, ORI...
            7'b0100011: o_imm = {{20{IR[31]}}, IR[31:25], IR[11:7]};               // SW
            7'b1100011: o_imm = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};  // Branch   1bit shift
            7'b0110111: o_imm = {IR[31:12], 12'b0};                                // LUI
            7'b1101111: o_imm = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0}; // JAL      1bit shift
            7'b1100111: o_imm = {{20{IR[31]}}, IR[31:20]};                         // JALR
            default:    o_imm = 32'd0;
        endcase
    end
endmodule