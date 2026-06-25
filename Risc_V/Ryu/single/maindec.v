module main_dec
#(parameter DW = 32) 

(

input [DW-1 : 0] inst,

input zero,
output pcsrc,
output reg memwrite,regwrite,
output reg alusrc,
output reg [1:0] immsrc,
output reg [1:0] aluop,
output reg [1:0] resultsrc


);
localparam lw = 7'b000_0011;
localparam sw = 7'b010_0011;
localparam r  = 7'b011_0011;
localparam i  = 7'b001_0011;
localparam b  = 7'b110_0011;
localparam j  = 7'b110_1111;
  wire [6:0]opcode;
//wire funct3;
//wire funct7;
reg branch;
reg jump;

assign opcode = inst[6:0];
//assign funct3 = inst[12:14];
//assign funct7 = inst [30]; 
assign pcsrc = (zero && branch) || jump; 

always @ (*)begin
    case(opcode)
    lw : begin
        regwrite = 1'b1;
        immsrc  = 2'b00;
        alusrc = 1'b1;
        memwrite = 1'b0;
        resultsrc = 2'b01;
        branch = 1'b0;
        aluop = 2'b00;
        jump =  1'b0;
    end
    sw : begin
        regwrite = 1'b0;
        immsrc  = 2'b01;
        alusrc = 1'b1;
        memwrite = 1'b1;
        resultsrc = 2'b00;
        branch = 1'b0;
        aluop = 2'b00;
        jump =  1'b0;
    end
    r : begin
        regwrite = 1'b1;
        immsrc  = 2'b00;
        alusrc = 1'b0;
        memwrite = 1'b0;
        resultsrc = 2'b00;
        branch = 1'b0;
        aluop = 2'b10;
        jump =  1'b0;
    end

    b : begin
        regwrite = 1'b0;
        immsrc  = 2'b10;
        alusrc = 1'b0;
        memwrite = 1'b0;
        resultsrc = 2'b00;
        branch = 1'b1;
        aluop = 2'b01;
        jump =  1'b0;   
    end
    j : begin
        regwrite = 1'b1;
        immsrc  = 2'b11;
        alusrc = 1'b0;
        memwrite = 1'b0;
        resultsrc = 2'b10;
        branch = 1'b0;
        aluop = 2'b00;
        jump =  1'b1;
    end
    i : begin 
        regwrite = 1'b1;
        immsrc  = 2'b00;
        alusrc = 1'b1;
        memwrite = 1'b0;
        resultsrc = 2'b00;
        branch = 1'b0;
        aluop = 2'b10;
        jump =  1'b0;
    end 
    default : begin
        regwrite = 1'b0;
        immsrc  = 2'b00;
        alusrc = 1'b0;
        memwrite = 1'b0;
        resultsrc = 2'b00;
        branch = 1'b0;
        aluop = 2'b00;
        jump =  1'b0;

    end
    endcase

end
endmodule 
