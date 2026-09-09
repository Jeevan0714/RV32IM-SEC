// ============================================================
// Hazard Detection Unit
// Detects: Load-Use hazards → inserts stall + bubble
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module hazard_unit (
    // ── ID stage instruction ──────────────────────────────────
    input  wire [4:0] ID_rs1,          // Source register 1
    input  wire [4:0] ID_rs2,          // Source register 2

    // ── EX stage (previous instruction) ──────────────────────
    input  wire       EX_mem_read,     // Is EX instr a load?
    input  wire [4:0] EX_rd,           // EX destination register

    // ── Outputs ───────────────────────────────────────────────
    output wire       stall_IF_ID,     // Freeze IF/ID register
    output wire       stall_PC,        // Freeze PC
    output wire       flush_ID_EX      // Insert bubble into EX
);

// ── Load-Use Hazard Detection ─────────────────────────────────
// Occurs when: EX stage is a LOAD AND its rd matches ID's rs1 or rs2
// Solution   : stall for 1 cycle + insert NOP bubble into EX stage
wire load_use_hazard;

assign load_use_hazard = EX_mem_read &&
                         ((EX_rd == ID_rs1) || (EX_rd == ID_rs2)) &&
                         (EX_rd != 5'b0);  // x0 never causes hazard

assign stall_PC    = load_use_hazard;
assign stall_IF_ID = load_use_hazard;
assign flush_ID_EX = load_use_hazard;

endmodule
