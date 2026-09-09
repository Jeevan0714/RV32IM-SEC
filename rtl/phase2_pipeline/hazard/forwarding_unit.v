// ============================================================
// Forwarding Unit
// Resolves EX-EX and MEM-EX data hazards via forwarding
// Eliminates need for stalls when data is in pipeline registers
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module forwarding_unit (
    // ── EX stage: current instruction sources ─────────────────
    input  wire [4:0] EX_rs1,
    input  wire [4:0] EX_rs2,

    // ── MEM stage: previous instruction destination ───────────
    input  wire       MEM_reg_write,
    input  wire [4:0] MEM_rd,

    // ── WB stage: two-cycles-ago instruction destination ──────
    input  wire       WB_reg_write,
    input  wire [4:0] WB_rd,

    // ── Forwarding MUX selects ────────────────────────────────
    // 00 → from register file (no hazard)
    // 10 → forward from MEM stage (EX-EX hazard)
    // 01 → forward from WB  stage (MEM-EX hazard)
    output reg  [1:0] forwardA,
    output reg  [1:0] forwardB
);

always @(*) begin
    // ── Forward A (rs1) ──────────────────────────────────────
    if (MEM_reg_write && (MEM_rd != 0) && (MEM_rd == EX_rs1))
        forwardA = 2'b10;           // EX-EX: from MEM/WB ALU result
    else if (WB_reg_write && (WB_rd != 0) && (WB_rd == EX_rs1) &&
             !(MEM_reg_write && (MEM_rd != 0) && (MEM_rd == EX_rs1)))
        forwardA = 2'b01;           // MEM-EX: from WB stage
    else
        forwardA = 2'b00;           // No hazard: use register file

    // ── Forward B (rs2) ──────────────────────────────────────
    if (MEM_reg_write && (MEM_rd != 0) && (MEM_rd == EX_rs2))
        forwardB = 2'b10;
    else if (WB_reg_write && (WB_rd != 0) && (WB_rd == EX_rs2) &&
             !(MEM_reg_write && (MEM_rd != 0) && (MEM_rd == EX_rs2)))
        forwardB = 2'b01;
    else
        forwardB = 2'b00;
end

endmodule
