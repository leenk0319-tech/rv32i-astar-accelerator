module Control(
    input  wire [6:0] i_op,
    input  wire [2:0] i_funct3,
    input  wire [6:0] i_funct7,
    input  wire [4:0] i_rs1,
    input  wire [4:0] i_rs2,
    input  wire [4:0] i_rd,

    output reg        alusrc,        // 0: rs2, 1: imm
    output reg        branch,        // only conditional branch
    output reg        jal,
    output reg        jalr,
    output reg [1:0]  aluop,         // 00: add, 01: branch, 10: R-type, 11: I-type
    output reg        memwrite,
    output reg        memread,
    output reg        memtoreg,
    output reg        regwrite,
    output reg [1:0]  result_select  // 00: ALU, 01: load, 10: PC+4, 11: imm
);

    localparam [6:0] OP_LOAD   = 7'b000_0011; // LW
    localparam [6:0] OP_ITYPE  = 7'b001_0011; // ADDI, SLLI, XORI, ORI, ANDI
    localparam [6:0] OP_STORE  = 7'b010_0011; // SW
    localparam [6:0] OP_RTYPE  = 7'b011_0011; // ADD, SUB, XOR, OR, AND
    localparam [6:0] OP_LUI    = 7'b011_0111; // LUI
    localparam [6:0] OP_BRANCH = 7'b110_0011; // BEQ, BNE, BLT, BGE
    localparam [6:0] OP_JALR   = 7'b110_0111; // JALR
    localparam [6:0] OP_JAL    = 7'b110_1111; // JAL

    always @(*) begin
        alusrc        = 1'b0;
        branch        = 1'b0;
        jal           = 1'b0;
        jalr          = 1'b0;
        aluop         = 2'b00;
        memwrite      = 1'b0;
        memread       = 1'b0;
        memtoreg      = 1'b0;
        regwrite      = 1'b0;
        result_select = 2'b00;

        case (i_op)
            OP_LOAD: begin
                alusrc        = 1'b1;
                aluop         = 2'b00;
                memread       = 1'b1;
                memtoreg      = 1'b1;
                regwrite      = 1'b1;
                result_select = 2'b01;
            end

            OP_STORE: begin
                alusrc        = 1'b1;
                aluop         = 2'b00;
                memwrite      = 1'b1;
            end

            OP_RTYPE: begin
                alusrc        = 1'b0;
                aluop         = 2'b10;
                regwrite      = 1'b1;
                result_select = 2'b00;
            end

            OP_ITYPE: begin
                alusrc        = 1'b1;
                aluop         = 2'b11;
                regwrite      = 1'b1;
                result_select = 2'b00;
            end

            OP_BRANCH: begin
                alusrc        = 1'b0;
                branch        = 1'b1;
                aluop         = 2'b01;
            end

            OP_LUI: begin
                alusrc        = 1'b1;
                aluop         = 2'b00;
                regwrite      = 1'b1;
                result_select = 2'b11;
            end

            OP_JAL: begin
                jal           = 1'b1;
                regwrite      = 1'b1;
                result_select = 2'b10;
            end

            OP_JALR: begin
                alusrc        = 1'b1;
                jalr          = 1'b1;
                aluop         = 2'b00;
                regwrite      = 1'b1;
                result_select = 2'b10;
            end
        endcase
    end

endmodule
