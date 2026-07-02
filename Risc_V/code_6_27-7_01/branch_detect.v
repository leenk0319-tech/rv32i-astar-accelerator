module branch_detect (
    input  wire [31:0] load_data,
    input  wire [1:0]  id_mux_select1,
    input  wire [1:0]  id_mux_select2,
    input  wire [31:0] D_r1,
    input  wire [31:0] D_r2,
    input  wire [31:0] M_RD,
    input  wire        branch,
    input  wire        jal,
    input  wire        jalr,
    input  wire [2:0]  funct3,
    input  wire        ID_EX_stall,
    output reg  [31:0] D_forwarding1,
    output reg  [31:0] D_forwarding2,
    output wire        if_id_flush,
    output reg         branch_condition,
    output wire        pc_redirect
);

    always @(*) begin
        case (id_mux_select1)
            2'b00: D_forwarding1 = D_r1;
            2'b01: D_forwarding1 = M_RD;
            2'b11: D_forwarding1 = load_data;
            default: D_forwarding1 = D_r1;
        endcase

        case (id_mux_select2)
            2'b00: D_forwarding2 = D_r2;
            2'b01: D_forwarding2 = M_RD;
            2'b11: D_forwarding2 = load_data;
            default: D_forwarding2 = D_r2;
        endcase
    end

    always @(*) begin
        branch_condition = 1'b0;
        if (branch) begin
            case (funct3)
                3'b000: branch_condition = (D_forwarding1 == D_forwarding2);                  // BEQ
                3'b001: branch_condition = (D_forwarding1 != D_forwarding2);                  // BNE
                3'b100: branch_condition = ($signed(D_forwarding1) <  $signed(D_forwarding2)); // BLT
                3'b101: branch_condition = ($signed(D_forwarding1) >= $signed(D_forwarding2)); // BGE
                default: branch_condition = 1'b0;
            endcase
        end
    end

    assign pc_redirect = ((branch && branch_condition) || jal || jalr) && !ID_EX_stall;
    assign if_id_flush = pc_redirect;

endmodule
