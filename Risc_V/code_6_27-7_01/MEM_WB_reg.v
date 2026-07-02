module MEM_WB_reg(
    input  wire        clk_i,
    input  wire        rstn_i,
    input  wire        i_memtoreg,
    input  wire        i_regwrite,
    input  wire [1:0]  i_result_select,
    input  wire [4:0]  i_rd,
    input  wire [31:0] i_pc,
    input  wire [31:0] i_alu_out,
    input  wire [31:0] i_load_data,
    input  wire [31:0] i_imm,

    output reg         o_memtoreg,
    output reg         o_regwrite,
    output reg  [1:0]  o_result_select,
    output reg  [4:0]  o_rd,
    output reg  [31:0] o_pc,
    output reg  [31:0] o_alu_out,
    output reg  [31:0] o_load_data,
    output reg  [31:0] o_imm
);
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            o_memtoreg      <= 1'b0;
            o_regwrite      <= 1'b0;
            o_result_select <= 2'b00;
            o_rd            <= 5'd0;
            o_pc            <= 32'd0;
            o_alu_out       <= 32'd0;
            o_load_data     <= 32'd0;
            o_imm           <= 32'd0;
        end
        else begin
            o_memtoreg      <= i_memtoreg;
            o_regwrite      <= i_regwrite;
            o_result_select <= i_result_select;
            o_rd            <= i_rd;
            o_pc            <= i_pc;
            o_alu_out       <= i_alu_out;
            o_load_data     <= i_load_data;
            o_imm           <= i_imm;
        end
    end

endmodule
