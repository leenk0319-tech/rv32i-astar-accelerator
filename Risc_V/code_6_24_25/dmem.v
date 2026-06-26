module dmem #(
    parameter DEPTH = 1024
) (
    input  wire        clk_i,
    input  wire        memread,
    input  wire        memwrite,
    input  wire [31:0] i_rdata2,    // store data
    input  wire [31:0] i_alu_out,   // byte address from ALU
    output wire [31:0] o_alu_out,   // pass ALU result to MEM/WB reg
    output wire [31:0] o_load_data  // load data
);
    
    reg [31:0] dmem [0:DEPTH-1];

    localparam ADDR_WIDTH = $clog2(DEPTH);  //2^DEPTH

    wire [ADDR_WIDTH-1:0] word_addr;
    assign word_addr = i_alu_out[ADDR_WIDTH+1:2];
    assign o_alu_out   = i_alu_out;
    assign o_load_data = memread ? dmem[word_addr] : 32'd0;

    always @(posedge clk_i) begin
        if (memwrite) begin
            dmem[word_addr] <= i_rdata2;
        end
    end

endmodule
