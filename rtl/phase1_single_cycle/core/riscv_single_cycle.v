// ============================================================
// Single-Cycle RISC-V RV32I Top-Level Core
// Implements: R, I, S, B, U, J type instructions
// Does NOT handle: interrupts, exceptions (Phase 1 scope)
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 1
// ============================================================

module riscv_single_cycle (
    input  wire        clk,
    input  wire        rst_n      // Active-low reset
);

// ════════════════════════════════════════════════════════════
// INTERNAL SIGNALS
// ════════════════════════════════════════════════════════════

// ── Program Counter ──────────────────────────────────────────
reg  [31:0] PC;
wire [31:0] PC_next;
wire [31:0] PC_plus4;
wire [31:0] PC_branch;
wire [31:0] PC_jump;
wire        take_branch;

// ── Instruction Fields ────────────────────────────────────────
wire [31:0] instr;
wire [6:0]  opcode   = instr[6:0];
wire [4:0]  rd_addr  = instr[11:7];
wire [2:0]  funct3   = instr[14:12];
wire [4:0]  rs1_addr = instr[19:15];
wire [4:0]  rs2_addr = instr[24:20];
wire [6:0]  funct7   = instr[31:25];

// ── Control Signals ───────────────────────────────────────────
wire        reg_write, mem_read, mem_write;
wire        mem_to_reg, alu_src, branch, jump, auipc;
wire [1:0]  alu_op;
wire [2:0]  imm_sel;
wire [3:0]  alu_ctrl;

// ── Datapath Signals ──────────────────────────────────────────
wire [31:0] rs1_data, rs2_data;
wire [31:0] imm_ext;
wire [31:0] alu_A, alu_B;
wire [31:0] alu_result;
wire        alu_zero, alu_neg, alu_ovf;
wire [31:0] mem_rd_data;
wire [31:0] wb_data;

// ════════════════════════════════════════════════════════════
// PROGRAM COUNTER
// ════════════════════════════════════════════════════════════
assign PC_plus4  = PC + 32'd4;
assign PC_branch = PC + imm_ext;                         // Branch target
assign PC_jump   = (opcode == 7'b1100111) ?              // JALR uses rs1+imm
                   (rs1_data + imm_ext) & 32'hFFFFFFFE : // Clear LSB
                   PC + imm_ext;                         // JAL uses PC+imm

// Branch condition: evaluate based on funct3
reg branch_taken;
always @(*) begin
    case (funct3)
        3'b000: branch_taken = alu_zero;                 // BEQ
        3'b001: branch_taken = ~alu_zero;                // BNE
        3'b100: branch_taken = alu_neg ^ alu_ovf;        // BLT (signed)
        3'b101: branch_taken = ~(alu_neg ^ alu_ovf);     // BGE (signed)
        3'b110: branch_taken = ~alu_zero & ~alu_result[31]; // BLTU (unsigned hack)
        3'b111: branch_taken = alu_zero | ~alu_result[31];  // BGEU
        default: branch_taken = 1'b0;
    endcase
end

assign take_branch = branch & branch_taken;
assign PC_next = jump         ? PC_jump   :
                 take_branch  ? PC_branch :
                                PC_plus4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        PC <= 32'h0000_0000;
    else
        PC <= PC_next;
end

// ════════════════════════════════════════════════════════════
// INSTRUCTION MEMORY
// ════════════════════════════════════════════════════════════
instr_mem #(.MEM_FILE("program.hex")) u_imem (
    .addr  (PC),
    .instr (instr)
);

// ════════════════════════════════════════════════════════════
// CONTROL UNIT
// ════════════════════════════════════════════════════════════
control_unit u_ctrl (
    .opcode    (opcode),
    .reg_write (reg_write),
    .mem_read  (mem_read),
    .mem_write (mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src   (alu_src),
    .branch    (branch),
    .jump      (jump),
    .auipc     (auipc),
    .alu_op    (alu_op),
    .imm_sel   (imm_sel)
);

// ════════════════════════════════════════════════════════════
// REGISTER FILE
// ════════════════════════════════════════════════════════════
register_file u_rf (
    .clk  (clk),
    .we   (reg_write),
    .rs1  (rs1_addr),
    .rs2  (rs2_addr),
    .rd   (rd_addr),
    .wd   (wb_data),
    .rd1  (rs1_data),
    .rd2  (rs2_data)
);

// ════════════════════════════════════════════════════════════
// IMMEDIATE GENERATOR
// ════════════════════════════════════════════════════════════
imm_gen u_immgen (
    .instr   (instr),
    .imm_sel (imm_sel),
    .imm_out (imm_ext)
);

// ════════════════════════════════════════════════════════════
// ALU
// ════════════════════════════════════════════════════════════
// A input: rs1_data (or PC for AUIPC)
assign alu_A = auipc ? PC : rs1_data;

// B input: rs2_data or immediate
assign alu_B = alu_src ? imm_ext : rs2_data;

alu_control u_aluctrl (
    .alu_op  (alu_op),
    .funct3  (funct3),
    .funct7_5(funct7[5]),
    .alu_ctrl(alu_ctrl)
);

alu u_alu (
    .A       (alu_A),
    .B       (alu_B),
    .alu_ctrl(alu_ctrl),
    .result  (alu_result),
    .zero    (alu_zero),
    .negative(alu_neg),
    .overflow(alu_ovf)
);

// ════════════════════════════════════════════════════════════
// DATA MEMORY
// ════════════════════════════════════════════════════════════
data_mem u_dmem (
    .clk      (clk),
    .mem_read (mem_read),
    .mem_write(mem_write),
    .addr     (alu_result),
    .wr_data  (rs2_data),
    .funct3   (funct3),
    .rd_data  (mem_rd_data)
);

// ════════════════════════════════════════════════════════════
// WRITE-BACK MUX
// ════════════════════════════════════════════════════════════
// mem_to_reg=1 → data from memory
// jump=1       → return address (PC+4) for JAL/JALR
assign wb_data = jump       ? PC_plus4   :
                 mem_to_reg ? mem_rd_data :
                               alu_result;

endmodule
