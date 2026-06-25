module inst_mem
#(
    parameter DW = 32,
    parameter DEPTH = 256,
    parameter AW = $clog2(DEPTH)
)
(
    input [DW-1:0] PC,
    output [DW-1:0] inst
);

reg [DW-1:0] rom [0:DEPTH-1];
wire [AW-1:0] word_addr;
integer i;

assign word_addr = PC[AW+1:2];
assign inst = rom[word_addr];

initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
        rom[i] = {DW{1'b0}};
    end
    $readmemh("program.hex", rom);
end

endmodule
