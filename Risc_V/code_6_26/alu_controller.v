module alu_controller (
    input wire [3:0] i_funct,
    input wire [1:0] i_alu_op,
    output reg [3:0] o_alu_signal
);
    always @ (*) begin
        case(i_alu_op)
            2'd0: o_alu_signal = 4'b0010;        //sd -> add
            2'd1: o_alu_signal =4'b0110;         //beq -> sub
            2'd2: begin case(i_funct)                 //rtype -> case별로 또 나눠야함.
                4'b0000: o_alu_signal = 4'b0010; // ADD
                4'b1000: o_alu_signal = 4'b0110; // SUB
                4'b0111: o_alu_signal = 4'b0000; // AND
                4'b0110: o_alu_signal = 4'b0001; // OR
                4'b0100: o_alu_signal = 4'b0011; // XOR
                4'b0001: o_alu_signal = 4'b0100; // SLL
                default: o_alu_signal = 4'b0010;
            endcase
            end
            2'd3: begin case(i_funct[2:0]) //itype  funct3 만으로도 구분 가능
                3'b000: o_alu_signal = 4'b0010; // ADDI
                3'b111: o_alu_signal = 4'b0000; // ANDI
                3'b110: o_alu_signal = 4'b0001; // ORI
                3'b100: o_alu_signal = 4'b0011; // XORI
                3'b001: o_alu_signal = 4'b0100; // SLLI
                default: o_alu_signal = 4'b0010;
                endcase
            end
        endcase
    end
    
endmodule