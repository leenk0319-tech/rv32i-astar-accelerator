
module RISC_V_ALU #(
    parameter DW = 32
)(
    input  wire [3:0]      alu_cont,
    input  wire [DW-1 : 0] in_a, 
    input  wire [DW-1 : 0] in_b,
    output reg  [DW-1 : 0] alu_result,
    output wire [3:0]      flag
);

    // 내부 신호
    wire          is_sub;
    wire [DW : 0] sum;
    wire          zero, V, C, N;
    wire [DW-1:0] b_bar;

    // ALU Opcode Definition
    localparam op_and  = 4'b1100; // NOR -> AND
    localparam op_or   = 4'b0001;
    localparam op_add  = 4'b0010;
    localparam op_sub  = 4'b0110;
    localparam op_slt  = 4'b0111;
    localparam op_srl  = 4'b1000;
    localparam op_sll  = 4'b1001;
    localparam op_sra  = 4'b1010;
    localparam op_nop  = 4'b0000; // AND -> NOP
    localparam op_xor  = 4'b1101;
    localparam op_sltu = 4'b0011;
    //localparam op_nor  = 4'b0100; // UNUSED


    assign is_sub = (alu_cont == op_sub) || (alu_cont == op_slt) || (alu_cont == op_sltu);

    // Adder/Subtractor 결정 Logic. 
    assign b_bar = is_sub ? ~in_b : in_b; 
    assign sum   = {1'b0, in_a} + {1'b0, b_bar} + {{DW{1'b0}}, is_sub};

    always @(*) begin
        case(alu_cont) 
            op_and : alu_result = in_a & in_b;
            op_or  : alu_result = in_a | in_b;
            op_add : alu_result = sum[DW-1:0];
            op_sub : alu_result = sum[DW-1:0];
            
            // SLT: 부호 있는 비교 (음수 < 양수 등 처리)
            op_slt : alu_result = ($signed(in_a) < $signed(in_b)) ? 32'd1 : 32'd0;  
            
            op_srl : alu_result = in_a >> in_b[4:0];
            op_sll : alu_result = in_a << in_b[4:0];
            op_sra : alu_result = $signed(in_a) >>> in_b[4:0];
            
            //op_nor : alu_result = ~(in_a | in_b);
            
            op_sltu: alu_result = (in_a < in_b) ? 32'd1 : 32'd0; // Unsigned
            op_xor : alu_result = in_a ^ in_b;
            
            default: alu_result = {DW{1'b0}}; // [수정] 32'd0 대신 파라미터 활용
        endcase
    end

    // Flag Logic
    assign zero = (alu_result == 0);
    assign C    = sum[DW];           // Carry Out
    assign N    = alu_result[DW-1];  // Negative
    
    // Overflow (V): A와 B의 부호가 다르고(뺄셈시), 결과의 부호가 A와 다를 때
    // 또는: (A가 양수, B가 음수인데 결과가 음수) OR (A가 음수, B가 양수인데 결과가 양수)

    assign V = (in_a[DW-1] ^ sum[DW-1]) & ~(in_a[DW-1] ^ in_b[DW-1] ^ is_sub);

    assign flag = {N, zero, C, V}; 

endmodule