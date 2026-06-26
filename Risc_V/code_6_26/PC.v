module PC (
    input  wire [31:0] PC,
    input  wire [31:0] bta,
    input  wire        branch,
    input  wire        branch_condition,
    input  wire        PCwrite,
    output wire [31:0] next_PC
);

    assign next_PC = (PCwrite) ? ((branch && branch_condition) ? bta : PC + 32'd4) :
                      PC;
endmodule
