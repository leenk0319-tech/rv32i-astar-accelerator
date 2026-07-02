`timescale 1ns/1ps

module risc_V_CPU (
    input wire clk_i,
    input wire rstn_i
);
    localparam [6:0] OP_LOAD   = 7'b000_0011;
    localparam [6:0] OP_ITYPE  = 7'b001_0011;
    localparam [6:0] OP_STORE  = 7'b010_0011;
    localparam [6:0] OP_RTYPE  = 7'b011_0011;
    localparam [6:0] OP_LUI    = 7'b011_0111;
    localparam [6:0] OP_BRANCH = 7'b110_0011;
    localparam [6:0] OP_JALR   = 7'b110_0111;
    localparam [6:0] OP_JAL    = 7'b110_1111;

    reg  [31:0] PC;
    wire [31:0] next_PC;
    wire [31:0] target_address;
    wire        pc_redirect;

    wire PCwrite_load;
    wire PCwrite_branch;

    PC U_PC (
        .PC(PC),
        .target_address(target_address),
        .pc_redirect(pc_redirect),
        .PCwrite_load(PCwrite_load),
        .PCwrite_branch(PCwrite_branch),
        .next_PC(next_PC)
    );

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i)
            PC <= 32'd0;
        else
            PC <= next_PC;
    end

    // ============================================================
    // IF stage
    // ============================================================
    wire [31:0] F_IR;

    imem #(
        .INIT_FILE("program.hex"),
        .DEPTH(1024)
    ) U_imem (
        .addr(PC),
        .instr(F_IR)
    );

    wire F_flush;

    // ============================================================
    // IF/ID pipeline register
    // ============================================================
    wire [31:0] D_PC;
    wire [31:0] D_IR;
    wire        if_id_write_load;
    wire        if_id_write_branch;

    IF_ID_reg U_if_id_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .F_flush(F_flush),
        .if_id_write_load(if_id_write_load),
        .if_id_write_branch(if_id_write_branch),
        .i_F_PC(PC),
        .i_F_IR(F_IR),
        .o_D_PC(D_PC),
        .o_D_IR(D_IR)
    );

    // ============================================================
    // ID stage
    // ============================================================
    wire [6:0] D_OP     = D_IR[6:0];
    wire [4:0] D_RD     = D_IR[11:7];
    wire [2:0] D_funct3 = D_IR[14:12];
    wire [4:0] D_RS1    = D_IR[19:15];
    wire [4:0] D_RS2    = D_IR[24:20];
    wire [6:0] D_funct7 = D_IR[31:25];
    wire [3:0] D_funct  = {D_funct7[5], D_funct3};

    wire        D_alusrc;
    wire        D_branch;
    wire        D_jal;
    wire        D_jalr;
    wire        D_memwrite;
    wire        D_memread;
    wire        D_memtoreg;
    wire        D_regwrite;
    wire [1:0]  D_aluop;
    wire [1:0]  D_result_select;
    wire [31:0] D_rdata1;
    wire [31:0] D_rdata2;
    wire [31:0] D_imm;
    wire [31:0] D_forwarding1;
    wire [31:0] D_forwarding2;

    wire D_use_rs1;
    wire D_use_rs2;
    assign D_use_rs1 = (D_OP == OP_LOAD)   ||
                       (D_OP == OP_ITYPE)  ||
                       (D_OP == OP_STORE)  ||
                       (D_OP == OP_RTYPE)  ||
                       (D_OP == OP_BRANCH) ||
                       (D_OP == OP_JALR);
    assign D_use_rs2 = (D_OP == OP_STORE)  ||
                       (D_OP == OP_RTYPE)  ||
                       (D_OP == OP_BRANCH);

    // ============================================================
    // EX stage wires
    // ============================================================
    wire [1:0]  E_aluop;
    wire        E_alusrc;
    wire        E_memwrite;
    wire        E_memread;
    wire        E_memtoreg;
    wire        E_regwrite;
    wire [1:0]  E_result_select;
    wire [31:0] E_PC;
    wire [4:0]  E_rs1;
    wire [4:0]  E_rs2;
    wire [31:0] E_rdata1;
    wire [31:0] E_rdata2;
    wire [31:0] E_imm;
    wire [4:0]  E_rd;
    wire [3:0]  E_funct4;
    wire [3:0]  E_alu_signal;
    wire [31:0] E_alu_out;
    wire [31:0] E_store_data;

    // ============================================================
    // MEM stage wires
    // ============================================================
    wire        M_memwrite;
    wire        M_memread;
    wire        M_memtoreg;
    wire        M_regwrite;
    wire [1:0]  M_result_select;
    wire [31:0] M_PC;
    wire [31:0] M_store_data;
    wire [4:0]  M_rd;
    wire [31:0] M_alu_out;
    wire [31:0] M_dmem_alu_out;
    wire [31:0] M_load_data;
    wire [31:0] M_imm;
    wire [31:0] M_forward_data;

    assign M_forward_data = (M_result_select == 2'b10) ? (M_PC + 32'd4) :
                            (M_result_select == 2'b11) ? M_imm :
                            M_alu_out;

    // ============================================================
    // WB stage wires
    // ============================================================
    wire        WB_memtoreg;
    wire        WB_regwrite;
    wire [1:0]  WB_result_select;
    wire [4:0]  WB_rd;
    wire [31:0] WB_PC;
    wire [31:0] WB_alu_out;
    wire [31:0] WB_load_data;
    wire [31:0] WB_imm;

    wire        W_regwrite;
    wire [4:0]  W_rd;
    reg  [31:0] W_wdata;

    wire [1:0] mux_select_signal1;
    wire [1:0] mux_select_signal2;

    // ============================================================
    // Hazard detection unit
    // ============================================================
    wire load_hazard_bubble;

    hazard_detect U_hazard_unit(
        .f_d_r1(D_RS1),
        .f_d_r2(D_RS2),
        .use_rs1(D_use_rs1),
        .use_rs2(D_use_rs2),
        .d_e_rd(E_rd),
        .memread(E_memread),
        .PCwrite_load(PCwrite_load),
        .IF_ID_write_load(if_id_write_load),
        .bubble(load_hazard_bubble)
    );

    // ============================================================
    // Controller
    // ============================================================
    Control U_controller (
        .i_op(D_OP),
        .i_funct3(D_funct3),
        .i_funct7(D_funct7),
        .i_rs1(D_RS1),
        .i_rs2(D_RS2),
        .i_rd(D_RD),
        .alusrc(D_alusrc),
        .branch(D_branch),
        .jal(D_jal),
        .jalr(D_jalr),
        .aluop(D_aluop),
        .memwrite(D_memwrite),
        .memread(D_memread),
        .memtoreg(D_memtoreg),
        .regwrite(D_regwrite),
        .result_select(D_result_select)
    );

    // ============================================================
    // Register file
    // ============================================================
    reg_file U_reg_file (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .RS1(D_RS1),
        .RS2(D_RS2),
        .regwrite(W_regwrite),
        .W_WA(W_rd),
        .W_WD(W_wdata),
        .scr1(D_rdata1),
        .scr2(D_rdata2)
    );

    // ============================================================
    // Immediate generator
    // ============================================================
    imm_gen U_imm_gen (
        .IR(D_IR),
        .OP(D_OP),
        .o_imm(D_imm)
    );

    // ============================================================
    // ID forwarding / branch and jump redirect
    // ============================================================
    wire [1:0] id_mux_select1;
    wire [1:0] id_mux_select2;
    wire       id_ex_bubble_branch;
    wire       branch_condition;

    ID_fowarding_unit U_id_fowarding_unit(
        .e_regwrite(E_regwrite),
        .m_regwrite(M_regwrite),
        .D_rs1(D_RS1),
        .D_rs2(D_RS2),
        .i_e_rd(E_rd),
        .e_m_rd(M_rd),
        .D_branch(D_branch),
        .D_jalr(D_jalr),
        .m_memread(M_memread),
        .id_mux_select1(id_mux_select1),
        .id_mux_select2(id_mux_select2),
        .if_id_write_branch(if_id_write_branch),
        .PCwrite_branch(PCwrite_branch),
        .ID_EX_stall(id_ex_bubble_branch)
    );

    branch_detect U_branch_detect_unit(
        .load_data(M_load_data),
        .id_mux_select1(id_mux_select1),
        .id_mux_select2(id_mux_select2),
        .D_r1(D_rdata1),
        .D_r2(D_rdata2),
        .M_RD(M_forward_data),
        .branch(D_branch),
        .jal(D_jal),
        .jalr(D_jalr),
        .funct3(D_funct3),
        .ID_EX_stall(id_ex_bubble_branch),
        .D_forwarding1(D_forwarding1),
        .D_forwarding2(D_forwarding2),
        .if_id_flush(F_flush),
        .branch_condition(branch_condition),
        .pc_redirect(pc_redirect)
    );

    bta_jta U_bta_jta (
        .D_PC(D_PC),
        .i_imm(D_imm),
        .jalr(D_jalr),
        .rs1(D_forwarding1),
        .target_address(target_address)
    );

    // ============================================================
    // ID/EX pipeline register
    // ============================================================
    ID_EX_reg U_id_ex_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .load_hazard_bubble(load_hazard_bubble),
        .id_ex_bubble_branch(id_ex_bubble_branch),
        .i_aluop(D_aluop),
        .i_alusrc(D_alusrc),
        .i_memwrite(D_memwrite),
        .i_memread(D_memread),
        .i_memtoreg(D_memtoreg),
        .i_regwrite(D_regwrite),
        .i_result_select(D_result_select),
        .i_rs1(D_RS1),
        .i_rs2(D_RS2),
        .i_id_PC(D_PC),
        .i_rdata1(D_forwarding1),
        .i_rdata2(D_forwarding2),
        .i_imm(D_imm),
        .i_rd(D_RD),
        .i_funct(D_funct),
        .o_aluop(E_aluop),
        .o_alusrc(E_alusrc),
        .o_memwrite(E_memwrite),
        .o_memread(E_memread),
        .o_memtoreg(E_memtoreg),
        .o_regwrite(E_regwrite),
        .o_result_select(E_result_select),
        .o_ex_pc(E_PC),
        .o_rdata1(E_rdata1),
        .o_rdata2(E_rdata2),
        .o_imm(E_imm),
        .o_rs1(E_rs1),
        .o_rs2(E_rs2),
        .o_rd(E_rd),
        .o_funct(E_funct4)
    );

    // ============================================================
    // EX stage
    // ============================================================
    alu_controller U_alu_controller (
        .i_funct(E_funct4),
        .i_alu_op(E_aluop),
        .o_alu_signal(E_alu_signal)
    );

    EX_forwarding_unit U_forwarding(
        .e_m_regwrite(M_regwrite),
        .m_w_regwrite(W_regwrite),
        .i_e_rs1(E_rs1),
        .i_e_rs2(E_rs2),
        .e_m_rd(M_rd),
        .m_w_rd(W_rd),
        .mux_select_signal1(mux_select_signal1),
        .mux_select_signal2(mux_select_signal2)
    );

    alu U_alu (
        .mux_select_signal1(mux_select_signal1),
        .mux_select_signal2(mux_select_signal2),
        .m_alu_out(M_forward_data),
        .w_writedata(W_wdata),
        .funct3(E_funct4[2:0]),
        .i_alu_signal(E_alu_signal),
        .i_rdata1(E_rdata1),
        .i_rdata2(E_rdata2),
        .i_imm(E_imm),
        .i_alu_src(E_alusrc),
        .alu_out(E_alu_out),
        .o_rdata2(E_store_data)
    );

    // ============================================================
    // EX/MEM pipeline register
    // ============================================================
    EX_MEM_reg U_ex_mem_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .i_memwrite(E_memwrite),
        .i_memread(E_memread),
        .i_memtoreg(E_memtoreg),
        .i_regwrite(E_regwrite),
        .i_result_select(E_result_select),
        .i_id_PC(E_PC),
        .i_rdata2(E_store_data),
        .i_rd(E_rd),
        .i_alu_out(E_alu_out),
        .i_imm(E_imm),
        .o_memwrite(M_memwrite),
        .o_memread(M_memread),
        .o_memtoreg(M_memtoreg),
        .o_regwrite(M_regwrite),
        .o_result_select(M_result_select),
        .o_ex_pc(M_PC),
        .o_rdata2(M_store_data),
        .o_rd(M_rd),
        .o_alu_out(M_alu_out),
        .o_imm(M_imm)
    );

    // ============================================================
    // MEM stage
    // ============================================================
    dmem U_dmem (
        .clk_i(clk_i),
        .memread(M_memread),
        .memwrite(M_memwrite),
        .i_rdata2(M_store_data),
        .i_alu_out(M_alu_out),
        .o_alu_out(M_dmem_alu_out),
        .o_load_data(M_load_data)
    );

    // ============================================================
    // MEM/WB pipeline register
    // ============================================================
    MEM_WB_reg U_mem_wb_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .i_memtoreg(M_memtoreg),
        .i_regwrite(M_regwrite),
        .i_result_select(M_result_select),
        .i_rd(M_rd),
        .i_pc(M_PC),
        .i_alu_out(M_dmem_alu_out),
        .i_load_data(M_load_data),
        .i_imm(M_imm),
        .o_memtoreg(WB_memtoreg),
        .o_regwrite(WB_regwrite),
        .o_result_select(WB_result_select),
        .o_rd(WB_rd),
        .o_pc(WB_PC),
        .o_alu_out(WB_alu_out),
        .o_load_data(WB_load_data),
        .o_imm(WB_imm)
    );

    // ============================================================
    // WB stage
    // ============================================================
    assign W_regwrite = WB_regwrite;
    assign W_rd       = WB_rd;

    always @(*) begin
        case (WB_result_select)
            2'b00: W_wdata = WB_alu_out;
            2'b01: W_wdata = WB_load_data;
            2'b10: W_wdata = WB_PC + 32'd4; //복귀 주소 저장
            2'b11: W_wdata = WB_imm;        // LUI
            default: W_wdata = 32'd0;   
        endcase
    end

endmodule
