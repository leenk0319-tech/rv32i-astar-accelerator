module ID_fowarding_unit (
    input  wire       e_regwrite,
    input  wire       m_regwrite,
    input  wire [4:0] D_rs1,
    input  wire [4:0] D_rs2,
    input  wire [4:0] i_e_rd,
    input  wire [4:0] e_m_rd,
    input  wire       D_branch,
    input  wire       D_jalr,
    input  wire       m_memread,
    output reg  [1:0] id_mux_select1,
    output reg  [1:0] id_mux_select2,
    output reg        if_id_write_branch,
    output reg        PCwrite_branch,
    output reg        ID_EX_stall
);
    wire need_rs1_in_id;
    wire need_rs2_in_id;

    assign need_rs1_in_id = D_branch || D_jalr;
    assign need_rs2_in_id = D_branch;

    always @(*) begin
        id_mux_select1     = 2'b00;
        id_mux_select2     = 2'b00;
        if_id_write_branch = 1'b1;
        PCwrite_branch     = 1'b1;
        ID_EX_stall        = 1'b0;

        if (need_rs1_in_id) begin
            if (m_regwrite && (e_m_rd != 5'd0) && (e_m_rd == D_rs1)) begin
                if (m_memread) begin
                    id_mux_select1     = 2'b11;
                    if_id_write_branch = 1'b0;
                    PCwrite_branch     = 1'b0;
                    ID_EX_stall        = 1'b1;
                end else begin
                    id_mux_select1 = 2'b01;
                end
            end

            if (e_regwrite && (i_e_rd != 5'd0) && (i_e_rd == D_rs1)) begin
                id_mux_select1     = 2'b00;
                if_id_write_branch = 1'b0;
                PCwrite_branch     = 1'b0;
                ID_EX_stall        = 1'b1;
            end
        end

        if (need_rs2_in_id) begin
            if (m_regwrite && (e_m_rd != 5'd0) && (e_m_rd == D_rs2)) begin
                if (m_memread) begin
                    id_mux_select2     = 2'b11;
                    if_id_write_branch = 1'b0;
                    PCwrite_branch     = 1'b0;
                    ID_EX_stall        = 1'b1;
                end else begin
                    id_mux_select2 = 2'b01;
                end
            end

            if (e_regwrite && (i_e_rd != 5'd0) && (i_e_rd == D_rs2)) begin
                id_mux_select2     = 2'b00;
                if_id_write_branch = 1'b0;
                PCwrite_branch     = 1'b0;
                ID_EX_stall        = 1'b1;
            end
        end
    end

endmodule
