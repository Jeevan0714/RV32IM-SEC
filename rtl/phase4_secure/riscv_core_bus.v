// ============================================================
// 5-Stage Pipelined RISC-V RV32I Top-Level Core
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module riscv_core_bus (
    input  wire        clk,
    input  wire        rst_n,
    
    // Instruction Memory Bus
    output wire [31:0] instr_addr,
    input  wire [31:0] instr_rdata,
    
    // Data Memory Bus
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    output wire        data_ren,
    output wire        data_wen,
    output wire [2:0]  data_funct3,
    input  wire [31:0] data_rdata
);

// ════════════════════════════════════════════════════════════
// INTERNAL WIRES
// ════════════════════════════════════════════════════════════

// ── Hazard & Forwarding Signals ──────────────────────────────
wire stall_IF_ID, stall_PC, flush_ID_EX;
wire [1:0] forwardA, forwardB;
wire take_branch;
wire flush_branch = take_branch | EX_jump; // Branch or Jump taken

// ── IF Stage ────────────────────────────────────────────────
reg  [31:0] IF_PC;
wire [31:0] IF_PC_next;
wire [31:0] IF_PC_plus4;
wire [31:0] IF_instr;

// ── ID Stage ────────────────────────────────────────────────
wire [31:0] ID_PC;
wire [31:0] ID_instr;
wire [31:0] ID_PC_plus4 = ID_PC + 32'd4;
wire [6:0]  ID_opcode   = ID_instr[6:0];
wire [4:0]  ID_rd_addr  = ID_instr[11:7];
wire [2:0]  ID_funct3   = ID_instr[14:12];
wire [4:0]  ID_rs1_addr = ID_instr[19:15];
wire [4:0]  ID_rs2_addr = ID_instr[24:20];
wire [6:0]  ID_funct7   = ID_instr[31:25];
wire ID_is_mext = (ID_opcode == 7'b0110011) && (ID_funct7 == 7'b0000001);

wire ID_reg_write, ID_mem_read, ID_mem_write, ID_mem_to_reg, ID_alu_src, ID_branch, ID_jump, ID_auipc;
wire [1:0] ID_alu_op;
wire [2:0] ID_imm_sel;
wire [31:0] ID_rs1_data, ID_rs2_data, ID_imm_ext;

// ── EX Stage ────────────────────────────────────────────────
wire EX_reg_write, EX_mem_to_reg, EX_mem_read, EX_mem_write, EX_branch, EX_jump, EX_alu_src, EX_auipc, EX_is_mext;
wire [1:0] EX_alu_op;
wire [31:0] EX_PC, EX_rs1_data, EX_rs2_data, EX_imm_ext;
wire [4:0] EX_rs1_addr, EX_rs2_addr, EX_rd_addr;
wire [2:0] EX_funct3;
wire EX_funct7_5;
wire [31:0] EX_PC_plus4 = EX_PC + 32'd4;

wire [31:0] EX_rs1_fwd, EX_rs2_fwd;
wire [31:0] EX_alu_A, EX_alu_B, EX_alu_result;
wire EX_alu_zero, EX_alu_neg, EX_alu_ovf;
wire [3:0] EX_alu_ctrl;
wire [31:0] EX_PC_branch, EX_PC_jump;

wire stall_mext;
wire [31:0] mul_result, div_result;
wire mul_ready, div_ready;
wire [31:0] EX_final_result;

// ── MEM Stage ───────────────────────────────────────────────
wire MEM_reg_write, MEM_mem_to_reg, MEM_jump, MEM_mem_read, MEM_mem_write;
wire [31:0] MEM_alu_result, MEM_rs2_data, MEM_mem_rd_data, MEM_PC_plus4;
wire [4:0] MEM_rd_addr;
wire [2:0] MEM_funct3;

// ── WB Stage ────────────────────────────────────────────────
wire WB_reg_write, WB_mem_to_reg, WB_jump;
wire [31:0] WB_alu_result, WB_mem_rd_data, WB_PC_plus4, WB_data;
wire [4:0] WB_rd_addr;


// ════════════════════════════════════════════════════════════
// INSTRUCTION FETCH STAGE (IF)
// ════════════════════════════════════════════════════════════
assign IF_PC_plus4 = IF_PC + 32'd4;
assign IF_PC_next  = EX_jump      ? EX_PC_jump :
                     take_branch  ? EX_PC_branch :
                                    IF_PC_plus4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        IF_PC <= 32'h0000_0000;
    else if (!(stall_PC | stall_mext))
        IF_PC <= IF_PC_next;
end

assign instr_addr = IF_PC;
assign IF_instr   = instr_rdata;

pipe_reg_IF_ID u_pipe_IF_ID (
    .clk      (clk),
    .rst_n    (rst_n),
    .stall    (stall_IF_ID | stall_mext),
    .flush    (flush_branch),
    .IF_PC    (IF_PC),
    .IF_instr (IF_instr),
    .ID_PC    (ID_PC),
    .ID_instr (ID_instr)
);

// ════════════════════════════════════════════════════════════
// INSTRUCTION DECODE STAGE (ID)
// ════════════════════════════════════════════════════════════
control_unit u_ctrl (
    .opcode    (ID_opcode),
    .reg_write (ID_reg_write),
    .mem_read  (ID_mem_read),
    .mem_write (ID_mem_write),
    .mem_to_reg(ID_mem_to_reg),
    .alu_src   (ID_alu_src),
    .branch    (ID_branch),
    .jump      (ID_jump),
    .auipc     (ID_auipc),
    .alu_op    (ID_alu_op),
    .imm_sel   (ID_imm_sel)
);

register_file u_rf (
    .clk  (clk),
    .we   (WB_reg_write),
    .rs1  (ID_rs1_addr),
    .rs2  (ID_rs2_addr),
    .rd   (WB_rd_addr),
    .wd   (WB_data),
    .rd1  (ID_rs1_data),
    .rd2  (ID_rs2_data)
);

imm_gen u_immgen (
    .instr   (ID_instr),
    .imm_sel (ID_imm_sel),
    .imm_out (ID_imm_ext)
);

hazard_unit u_hazard (
    .ID_rs1     (ID_rs1_addr),
    .ID_rs2     (ID_rs2_addr),
    .EX_mem_read(EX_mem_read),
    .EX_rd      (EX_rd_addr),
    .stall_IF_ID(stall_IF_ID),
    .stall_PC   (stall_PC),
    .flush_ID_EX(flush_ID_EX)
);

pipe_reg_ID_EX u_pipe_ID_EX (
    .clk           (clk),
    .rst_n         (rst_n),
    .stall         (stall_mext),
    .flush         (flush_ID_EX | flush_branch),
    .ID_reg_write  (ID_reg_write),
    .ID_mem_to_reg (ID_mem_to_reg),
    .ID_mem_read   (ID_mem_read),
    .ID_mem_write  (ID_mem_write),
    .ID_branch     (ID_branch),
    .ID_jump       (ID_jump),
    .ID_alu_src    (ID_alu_src),
    .ID_alu_op     (ID_alu_op),
    .ID_auipc      (ID_auipc),
    .ID_is_mext    (ID_is_mext),
    .ID_PC         (ID_PC),
    .ID_rs1_data   (ID_rs1_data),
    .ID_rs2_data   (ID_rs2_data),
    .ID_imm_ext    (ID_imm_ext),
    .ID_rs1_addr   (ID_rs1_addr),
    .ID_rs2_addr   (ID_rs2_addr),
    .ID_rd_addr    (ID_rd_addr),
    .ID_funct3     (ID_funct3),
    .ID_funct7_5   (ID_funct7[5]),
    .EX_reg_write  (EX_reg_write),
    .EX_mem_to_reg (EX_mem_to_reg),
    .EX_mem_read   (EX_mem_read),
    .EX_mem_write  (EX_mem_write),
    .EX_branch     (EX_branch),
    .EX_jump       (EX_jump),
    .EX_alu_src    (EX_alu_src),
    .EX_alu_op     (EX_alu_op),
    .EX_auipc      (EX_auipc),
    .EX_is_mext    (EX_is_mext),
    .EX_PC         (EX_PC),
    .EX_rs1_data   (EX_rs1_data),
    .EX_rs2_data   (EX_rs2_data),
    .EX_imm_ext    (EX_imm_ext),
    .EX_rs1_addr   (EX_rs1_addr),
    .EX_rs2_addr   (EX_rs2_addr),
    .EX_rd_addr    (EX_rd_addr),
    .EX_funct3     (EX_funct3),
    .EX_funct7_5   (EX_funct7_5)
);

// ════════════════════════════════════════════════════════════
// EXECUTE STAGE (EX)
// ════════════════════════════════════════════════════════════
forwarding_unit u_forwarding (
    .EX_rs1       (EX_rs1_addr),
    .EX_rs2       (EX_rs2_addr),
    .MEM_reg_write(MEM_reg_write),
    .MEM_rd       (MEM_rd_addr),
    .WB_reg_write (WB_reg_write),
    .WB_rd        (WB_rd_addr),
    .forwardA     (forwardA),
    .forwardB     (forwardB)
);

assign EX_rs1_fwd = (forwardA == 2'b10) ? MEM_alu_result :
                    (forwardA == 2'b01) ? WB_data :
                                          EX_rs1_data;

assign EX_rs2_fwd = (forwardB == 2'b10) ? MEM_alu_result :
                    (forwardB == 2'b01) ? WB_data :
                                          EX_rs2_data;

assign EX_alu_A = EX_auipc   ? EX_PC : EX_rs1_fwd;
assign EX_alu_B = EX_alu_src ? EX_imm_ext : EX_rs2_fwd;

alu_control u_aluctrl (
    .alu_op  (EX_alu_op),
    .funct3  (EX_funct3),
    .funct7_5(EX_funct7_5),
    .alu_ctrl(EX_alu_ctrl)
);

alu u_alu (
    .A       (EX_alu_A),
    .B       (EX_alu_B),
    .alu_ctrl(EX_alu_ctrl),
    .result  (EX_alu_result),
    .zero    (EX_alu_zero),
    .negative(EX_alu_neg),
    .overflow(EX_alu_ovf)
);

// Branch condition logic
reg branch_taken;
always @(*) begin
    case (EX_funct3)
        3'b000: branch_taken = EX_alu_zero;                 // BEQ
        3'b001: branch_taken = ~EX_alu_zero;                // BNE
        3'b100: branch_taken = EX_alu_neg ^ EX_alu_ovf;        // BLT (signed)
        3'b101: branch_taken = ~(EX_alu_neg ^ EX_alu_ovf);     // BGE (signed)
        3'b110: branch_taken = ~EX_alu_zero & ~EX_alu_result[31]; // BLTU 
        3'b111: branch_taken = EX_alu_zero | ~EX_alu_result[31];  // BGEU
        default: branch_taken = 1'b0;
    endcase
end

assign take_branch = EX_branch & branch_taken;
assign EX_PC_branch = EX_PC + EX_imm_ext;
assign EX_PC_jump   = EX_alu_src ? (EX_rs1_fwd + EX_imm_ext) & 32'hFFFFFFFE : EX_PC + EX_imm_ext;

// ── M-Extension Logic ─────────────────────────────────────────
wire is_mul = EX_is_mext && (EX_funct3[2] == 1'b0);
wire is_div = EX_is_mext && (EX_funct3[2] == 1'b1);

reg mext_running;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) mext_running <= 1'b0;
    else if (mul_ready || div_ready) mext_running <= 1'b0;
    else if (EX_is_mext && !mext_running) mext_running <= 1'b1;
end

wire mul_start = is_mul && !mext_running;
wire div_start = is_div && !mext_running;
assign stall_mext = EX_is_mext && !(mul_ready || div_ready);

multiplier u_mul (
    .clk   (clk),
    .rst_n (rst_n),
    .start (mul_start),
    .rs1   (EX_rs1_fwd),
    .rs2   (EX_rs2_fwd),
    .funct3(EX_funct3),
    .result(mul_result),
    .ready (mul_ready)
);

divider u_div (
    .clk     (clk),
    .rst_n   (rst_n),
    .start   (div_start),
    .dividend(EX_rs1_fwd),
    .divisor (EX_rs2_fwd),
    .funct3  (EX_funct3),
    .result  (div_result),
    .ready   (div_ready)
);

assign EX_final_result = is_mul ? mul_result :
                         is_div ? div_result :
                                  EX_alu_result;

// Block writes if we are stalling (inject NOP)
wire EX_MEM_reg_write = EX_reg_write & ~stall_mext;
wire EX_MEM_mem_write = EX_mem_write & ~stall_mext;

pipe_reg_EX_MEM u_pipe_EX_MEM (
    .clk            (clk),
    .rst_n          (rst_n),
    .EX_reg_write   (EX_MEM_reg_write),
    .EX_mem_to_reg  (EX_mem_to_reg),
    .EX_jump        (EX_jump),
    .EX_mem_read    (EX_mem_read),
    .EX_mem_write   (EX_MEM_mem_write),
    .EX_alu_result  (EX_final_result),
    .EX_rs2_data_fwd(EX_rs2_fwd),
    .EX_rd_addr     (EX_rd_addr),
    .EX_funct3      (EX_funct3),
    .EX_PC_plus4    (EX_PC_plus4),
    .MEM_reg_write  (MEM_reg_write),
    .MEM_mem_to_reg (MEM_mem_to_reg),
    .MEM_jump       (MEM_jump),
    .MEM_mem_read   (MEM_mem_read),
    .MEM_mem_write  (MEM_mem_write),
    .MEM_alu_result (MEM_alu_result),
    .MEM_rs2_data   (MEM_rs2_data),
    .MEM_rd_addr    (MEM_rd_addr),
    .MEM_funct3     (MEM_funct3),
    .MEM_PC_plus4   (MEM_PC_plus4)
);

// ════════════════════════════════════════════════════════════
// MEMORY STAGE (MEM)
// ════════════════════════════════════════════════════════════
assign data_addr   = MEM_alu_result;
assign data_wdata  = MEM_rs2_data;
assign data_ren    = MEM_mem_read;
assign data_wen    = MEM_mem_write;
assign data_funct3 = MEM_funct3;
assign MEM_mem_rd_data = data_rdata;

pipe_reg_MEM_WB u_pipe_MEM_WB (
    .clk            (clk),
    .rst_n          (rst_n),
    .MEM_reg_write  (MEM_reg_write),
    .MEM_mem_to_reg (MEM_mem_to_reg),
    .MEM_jump       (MEM_jump),
    .MEM_alu_result (MEM_alu_result),
    .MEM_mem_rd_data(MEM_mem_rd_data),
    .MEM_rd_addr    (MEM_rd_addr),
    .MEM_PC_plus4   (MEM_PC_plus4),
    .WB_reg_write   (WB_reg_write),
    .WB_mem_to_reg  (WB_mem_to_reg),
    .WB_jump        (WB_jump),
    .WB_alu_result  (WB_alu_result),
    .WB_mem_rd_data (WB_mem_rd_data),
    .WB_rd_addr     (WB_rd_addr),
    .WB_PC_plus4    (WB_PC_plus4)
);

// ════════════════════════════════════════════════════════════
// WRITEBACK STAGE (WB)
// ════════════════════════════════════════════════════════════
assign WB_data = WB_jump       ? WB_PC_plus4 :
                 WB_mem_to_reg ? WB_mem_rd_data :
                                 WB_alu_result;

endmodule
