module inst_mem 
#(parameter DW     = 32,
  parameter DEPTH = 256)
(
input       [DW-1 : 0]    PC,
output wire [DW-1 :0]     inst
);

localparam AW = $clog2(DEPTH);

wire [AW-1 :0 ] addr;
assign addr = PC[AW +1 : 2];

reg [DW-1 :0] rom [0:DEPTH -1];
assign inst = rom[addr];
initial begin 
 $readmemh("program.hex", rom); 
end

endmodule