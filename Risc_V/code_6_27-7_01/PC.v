module PC (
    input  wire [31:0] PC,
    input  wire [31:0] target_address,
    input  wire        pc_redirect,
    input  wire        PCwrite_load,
    input  wire        PCwrite_branch,
    output wire [31:0] next_PC
);
    assign next_PC = (PCwrite_load && PCwrite_branch) ?
                     (pc_redirect ? target_address : PC + 32'd4) :
                     PC;
endmodule
