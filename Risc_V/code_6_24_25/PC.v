module PC (
    input  wire [31:0] PC,
    input  wire [31:0] bta,
    input  wire        branch,
    input  wire        branch_condition,
    output wire [31:0] next_PC
);

    assign next_PC = (branch && branch_condition) ? bta : PC + 32'd4;
endmodule