// ============================================================
// Immediate Generator
// Handles all RISC-V immediate formats:
//   I-type, S-type, B-type, U-type, J-type
// Author  : Jeevan
// Project : RISC-V RV32IM Processor
// ============================================================

module imm_gen (
    input  wire [31:0] instr,     // Full 32-bit instruction
    input  wire [2:0]  imm_sel,   // Immediate type selector
    output reg  [31:0] imm_out    // Sign-extended immediate
);

// ── Immediate Type Encodings ──────────────────────────────────
localparam IMM_I = 3'b000;  // I-type: ADDI, LW, JALR, etc.
localparam IMM_S = 3'b001;  // S-type: SW, SB, SH
localparam IMM_B = 3'b010;  // B-type: BEQ, BNE, BLT, BGE
localparam IMM_U = 3'b011;  // U-type: LUI, AUIPC
localparam IMM_J = 3'b100;  // J-type: JAL

always @(*) begin
    case (imm_sel)
        // I-type: bits [31:20], sign-extended
        IMM_I: imm_out = {{20{instr[31]}}, instr[31:20]};

        // S-type: bits [31:25] | [11:7], sign-extended
        IMM_S: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

        // B-type: bits [31] | [7] | [30:25] | [11:8] | 0
        // NOTE: LSB is always 0 (2-byte aligned)
        IMM_B: imm_out = {{19{instr[31]}}, instr[31], instr[7],
                           instr[30:25], instr[11:8], 1'b0};

        // U-type: bits [31:12] shifted left 12
        IMM_U: imm_out = {instr[31:12], 12'b0};

        // J-type: bits [31]|[19:12]|[20]|[30:21]|0
        // NOTE: LSB is always 0 (2-byte aligned)
        IMM_J: imm_out = {{11{instr[31]}}, instr[31], instr[19:12],
                           instr[20], instr[30:21], 1'b0};

        default: imm_out = 32'b0;
    endcase
end

endmodule
