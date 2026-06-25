module EX_MEM_reg(
    input  wire        clk_i,
    input  wire        rstn_i,

    input  wire        i_branch,
    input  wire        i_memwrite,
    input  wire        i_memread,
    input  wire        i_memtoreg,
    input  wire        i_regwrite,

   
    input  wire [31:0] i_id_PC,
    input  wire [31:0] i_rdata2,  //store할 데이터 
    input  wire [4:0]  i_rd,
    input  wire [31:0] i_alu_out,


    output reg         o_branch,
    output reg         o_memwrite,
    output reg         o_memread,
    output reg         o_memtoreg,
    output reg         o_regwrite,

   
    output reg  [31:0] o_ex_pc,
    output  reg [31:0]  o_rdata2,
    output reg  [4:0]  o_rd,
    output reg  [31:0] o_alu_out
);
     always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            o_branch   <= 1'b0;
            o_memwrite <= 1'b0;
            o_memread  <= 1'b0;
            o_memtoreg <= 1'b0;
            o_regwrite <= 1'b0;

            o_ex_pc    <= 32'd0;
            o_rdata2   <= 32'd0;
            o_rd       <= 5'd0;
            o_alu_out   <= 32'd0;
        end
        else begin
            o_branch   <= i_branch;
            o_memwrite <= i_memwrite;
            o_memread  <= i_memread;
            o_memtoreg <= i_memtoreg;
            o_regwrite <= i_regwrite;

            o_ex_pc    <= i_id_PC;
            o_rdata2   <= i_rdata2;
            o_rd       <= i_rd;
            o_alu_out   <= i_alu_out;
        end
    end

    
endmodule