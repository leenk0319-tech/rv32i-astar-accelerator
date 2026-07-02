`timescale 1ns/1ps

module ID_EX_reg (
    input  wire        clk_i,
    input  wire        rstn_i,
    input  wire        load_hazard_bubble,
    input  wire        id_ex_bubble_branch,

    input  wire [1:0]  i_aluop,
    input  wire        i_alusrc,
    input  wire        i_memwrite,
    input  wire        i_memread,
    input  wire        i_memtoreg,
    input  wire        i_regwrite,
    input  wire [1:0]  i_result_select,

    input  wire [4:0]  i_rs1,
    input  wire [4:0]  i_rs2,
    input  wire [31:0] i_id_PC,
    input  wire [31:0] i_rdata1,
    input  wire [31:0] i_rdata2,
    input  wire [31:0] i_imm,
    input  wire [4:0]  i_rd,
    input  wire [3:0]  i_funct,

    output reg  [1:0]  o_aluop,
    output reg         o_alusrc,
    output reg         o_memwrite,
    output reg         o_memread,
    output reg         o_memtoreg,
    output reg         o_regwrite,
    output reg  [1:0]  o_result_select,

    output reg  [31:0] o_ex_pc,
    output reg  [31:0] o_rdata1,
    output reg  [31:0] o_rdata2,
    output reg  [31:0] o_imm,
    output reg  [4:0]  o_rs1,
    output reg  [4:0]  o_rs2,
    output reg  [4:0]  o_rd,
    output reg  [3:0]  o_funct
);

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            o_aluop         <= 2'd0;
            o_alusrc        <= 1'b0;
            o_memwrite      <= 1'b0;
            o_memread       <= 1'b0;
            o_memtoreg      <= 1'b0;
            o_regwrite      <= 1'b0;
            o_result_select <= 2'b00;

            o_ex_pc         <= 32'd0;
            o_rdata1        <= 32'd0;
            o_rdata2        <= 32'd0;
            o_imm           <= 32'd0;
            o_rs1           <= 5'd0;
            o_rs2           <= 5'd0;
            o_rd            <= 5'd0;
            o_funct         <= 4'd0;
        end
        else if (load_hazard_bubble || id_ex_bubble_branch) begin
            o_aluop         <= 2'd0;
            o_alusrc        <= 1'b0;
            o_memwrite      <= 1'b0;
            o_memread       <= 1'b0;
            o_memtoreg      <= 1'b0;
            o_regwrite      <= 1'b0;
            o_result_select <= 2'b00;

            o_ex_pc         <= 32'd0;
            o_rdata1        <= 32'd0;
            o_rdata2        <= 32'd0;
            o_imm           <= 32'd0;
            o_rs1           <= 5'd0;
            o_rs2           <= 5'd0;
            o_rd            <= 5'd0;
            o_funct         <= 4'd0;
        end
        else begin
            o_aluop         <= i_aluop;
            o_alusrc        <= i_alusrc;
            o_memwrite      <= i_memwrite;
            o_memread       <= i_memread;
            o_memtoreg      <= i_memtoreg;
            o_regwrite      <= i_regwrite;
            o_result_select <= i_result_select;

            o_ex_pc         <= i_id_PC;
            o_rdata1        <= i_rdata1;
            o_rdata2        <= i_rdata2;
            o_imm           <= i_imm;
            o_rs1           <= i_rs1;
            o_rs2           <= i_rs2;
            o_rd            <= i_rd;
            o_funct         <= i_funct;
        end
    end

endmodule
