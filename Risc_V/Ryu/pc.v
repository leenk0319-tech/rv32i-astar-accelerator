module imm_extend

#(

    parameter DW = 32,
    parameter imm_type = 2
)

(

    input [DW-1 : 0] inst,

    input [(imm_type)-1 :0] immsrc,

  

    output reg [DW-1 :0] immext

);

  
  

localparam I = 2'b00;

localparam S = 2'b01;

localparam B = 2'b10;

localparam J = 2'b11;

  

wire msb;

assign msb= inst[DW-1];

  
  

always @(*) begin

    case(immsrc)

    I : immext = {{20{msb}}, inst[31:20]};

    S : immext = {{20{msb}}, inst[31:25],inst[11:7]};

    B : immext = {{20{msb}}, inst[7],inst[30:25],inst[11:8],1'b0};

    J : immext = {{12{msb}}, inst[19:12],inst[20],inst[30:21],1'b0};

  
  

    default : immext = 0;

  

    endcase

  

end

  

endmodule
