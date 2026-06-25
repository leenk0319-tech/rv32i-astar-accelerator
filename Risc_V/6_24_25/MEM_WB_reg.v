module MEM_WB_reg(
    input  wire        clk_i,
    input  wire        rstn_i,
    input  wire        i_memtoreg,
    input  wire        i_regwrite,
    input  wire [4:0]  i_rd,
    input  wire [31:0] i_alu_out,
    input  wire [31:0] i_load_data,

    output reg         o_memtoreg,
    output reg         o_regwrite,
    output reg  [4:0]  o_rd,
    output reg  [31:0] o_alu_out,
    output reg  [31:0] o_load_data

);
     always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
      
            o_memtoreg <= 1'b0;
            o_regwrite <= 1'b0;
            o_rd       <= 5'd0;
            o_alu_out  <= 32'd0;
            o_load_data <= 32'd0;
        end
        else begin
            o_memtoreg <= i_memtoreg;
            o_regwrite <= i_regwrite;
            o_rd       <= i_rd;
            o_alu_out  <= i_alu_out;
            o_load_data <= i_load_data;
        end
    end

    
endmodule
