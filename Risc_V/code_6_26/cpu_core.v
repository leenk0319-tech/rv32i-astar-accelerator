`timescale 1ns/1ps

module risc_V_CPU (
    input wire clk_i,
    input wire rstn_i
);
    reg [31:0] PC;
    wire [31:0] next_PC;
    wire E_branch;
    wire E_branch_condition;
    wire [31:0] bta;

    wire PCwrite;
    PC U_PC (
        .PC(PC),
        .bta(bta),
        .branch(E_branch),
        .branch_condition(E_branch_condition),
        .PCwrite(PCwrite),
        .next_PC(next_PC)
    );
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i)
            PC <= 32'd0;
        else
            PC <= next_PC;
    end
    wire branch_taken;
    assign branch_taken = E_branch && E_branch_condition;
    // ============================================================
    // IF stage (inst mem)
    // ============================================================
    
    wire [31:0] F_IR;

    imem #(
        .INIT_FILE("program.hex"),
        .DEPTH(1024)
    ) U_imem (
        .addr(PC),
        .instr(F_IR)
    );

    // ============================================================
    // IF/ID pipeline register
    // ============================================================
    wire [31:0] D_PC;
    wire [31:0] D_IR;
    wire if_id_write;

    IF_ID_reg U_if_id_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .F_flush(branch_taken),
        .if_id_write(if_id_write),
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

    // ID-stage control / datapath wires
    wire        D_alusrc;
    wire        D_branch;
    wire        D_memwrite;
    wire        D_memread;
    wire        D_memtoreg;
    wire        D_regwrite;
    wire [1:0]  D_aluop;
    wire [31:0] D_rdata1;
    wire [31:0] D_rdata2;
    wire [31:0] D_imm;

    // Forward declarations for hazard / forwarding logic
    wire        bubble;

    wire [1:0]  E_aluop;
    wire        E_alusrc;
    wire        E_memwrite;
    wire        E_memread;
    wire        E_memtoreg;
    wire        E_regwrite;
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

    wire        M_branch;
    wire        M_memwrite;
    wire        M_memread;
    wire        M_memtoreg;
    wire        M_regwrite;
    wire [31:0] M_PC;
    wire [31:0] M_store_data;
    wire [4:0]  M_rd;
    wire [31:0] M_alu_out;
    wire [31:0] M_dmem_alu_out;
    wire [31:0] M_load_data;

    wire        WB_memtoreg;
    wire        WB_regwrite;
    wire [4:0]  WB_rd;
    wire [31:0] WB_alu_out;
    wire [31:0] WB_load_data;

    wire        W_regwrite;
    wire [4:0]  W_rd;
    wire [31:0] W_wdata;

    wire [1:0] mux_select_signal1, mux_select_signal2;

    // ============================================================
    // hazard detection unit
    // ============================================================

    hazard_detect U_hazard_unit(
        .f_d_r1(D_RS1),
        .f_d_r2(D_RS2),
        .d_e_rd(E_rd),
        .memread(E_memread),
        .PCwrite(PCwrite),
        .IF_ID_write(if_id_write),
        .bubble(bubble)
    );


    // ============================================================
    // controller
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
        .aluop(D_aluop),
        .memwrite(D_memwrite),
        .memread(D_memread),
        .memtoreg(D_memtoreg),
        .regwrite(D_regwrite)
    );

    // ============================================================
    // register file
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
    // imm generator
    // ============================================================
    imm_gen U_imm_gen (
        .IR(D_IR),
        .OP(D_OP),
        .o_imm(D_imm)
    );

    // ============================================================
    // ID/EX pipeline register
    // ============================================================
    ID_EX_reg U_id_ex_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .bubble(bubble),
        .i_aluop(D_aluop),
        .i_alusrc(D_alusrc),
        .i_branch(D_branch),
        .i_memwrite(D_memwrite),
        .i_memread(D_memread),
        .i_memtoreg(D_memtoreg),
        .i_regwrite(D_regwrite),
        .i_rs1(D_RS1),
        .i_rs2(D_RS2),
        .i_id_PC(D_PC),
        .i_rdata1(D_rdata1),
        .i_rdata2(D_rdata2),
        .i_imm(D_imm),
        .i_rd(D_RD),
        .i_funct(D_funct),
        .i_flush(branch_taken),
        .o_aluop(E_aluop),
        .o_alusrc(E_alusrc),
        .o_branch(E_branch),
        .o_memwrite(E_memwrite),
        .o_memread(E_memread),
        .o_memtoreg(E_memtoreg),
        .o_regwrite(E_regwrite),
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
    // ============================================================
    // alu controller -> alu
    // ============================================================
    alu_controller U_alu_controller (
        .i_funct(E_funct4),
        .i_alu_op(E_aluop),
        .o_alu_signal(E_alu_signal)
    );

    Forwarding_unit U_forwarding(
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
        .m_alu_out(M_alu_out),
        .w_writedata(W_wdata),
        .funct3(E_funct4[2:0]),
        .i_alu_signal(E_alu_signal),
        .i_rdata1(E_rdata1),
        .i_rdata2(E_rdata2),
        .i_imm(E_imm),
        .i_alu_src(E_alusrc),
        .branch(E_branch),
        .alu_out(E_alu_out),
        .o_rdata2(E_store_data),
        .branch_condition(E_branch_condition)
    );

    bta U_bta (
        .E_PC(E_PC),
        .i_imm(E_imm),
        .bta(bta)
    );

    // ============================================================
    // EX/MEM pipeline register
    // ============================================================
    EX_MEM_reg U_ex_mem_reg (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .i_branch(E_branch),
        .i_memwrite(E_memwrite),
        .i_memread(E_memread),
        .i_memtoreg(E_memtoreg),
        .i_regwrite(E_regwrite),
        .i_id_PC(E_PC),
        .i_rdata2(E_store_data),
        .i_rd(E_rd),
        .i_alu_out(E_alu_out),
        .o_branch(M_branch),
        .o_memwrite(M_memwrite),
        .o_memread(M_memread),
        .o_memtoreg(M_memtoreg),
        .o_regwrite(M_regwrite),
        .o_ex_pc(M_PC),
        .o_rdata2(M_store_data),
        .o_rd(M_rd),
        .o_alu_out(M_alu_out)
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
        .i_rd(M_rd),
        .i_alu_out(M_dmem_alu_out),
        .i_load_data(M_load_data),
        .o_memtoreg(WB_memtoreg),
        .o_regwrite(WB_regwrite),
        .o_rd(WB_rd),
        .o_alu_out(WB_alu_out),
        .o_load_data(WB_load_data)
    );

    // ============================================================
    // WB stage
    // ============================================================
    assign W_regwrite = WB_regwrite;
    assign W_rd       = WB_rd;
    assign W_wdata    = WB_memtoreg ? WB_load_data : WB_alu_out;

endmodule
