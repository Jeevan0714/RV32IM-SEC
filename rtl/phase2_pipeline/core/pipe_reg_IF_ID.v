// ============================================================
// Pipeline Register: IF/ID
// Holds instruction and PC between Fetch and Decode stages
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module pipe_reg_IF_ID (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,      // 1 = freeze this register (load-use hazard)
    input  wire        flush,      // 1 = insert NOP (branch misprediction)
    // ── Inputs (from IF stage) ────────────────────────────────
    input  wire [31:0] IF_PC,
    input  wire [31:0] IF_instr,
    // ── Outputs (to ID stage) ─────────────────────────────────
    output reg  [31:0] ID_PC,
    output reg  [31:0] ID_instr
);

localparam NOP = 32'h0000_0013; // ADDI x0, x0, 0

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ID_PC    <= 32'b0;
        ID_instr <= NOP;
    end else if (flush) begin
        ID_PC    <= 32'b0;
        ID_instr <= NOP;          // Insert bubble
    end else if (!stall) begin
        ID_PC    <= IF_PC;
        ID_instr <= IF_instr;
    end
    // If stall: hold current values (do nothing)
end

endmodule
