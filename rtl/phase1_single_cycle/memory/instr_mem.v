// ============================================================
// Instruction Memory — ROM (Read-Only during execution)
// Word-addressed, 4KB default (1024 × 32-bit words)
// Author  : Jeevan
// Project : RISC-V RV32IM Processor
// ============================================================

module instr_mem #(
    parameter MEM_DEPTH = 1024,           // Number of 32-bit words
    parameter MEM_FILE  = "program.hex"   // Hex file to load
)(
    input  wire [31:0] addr,  // Byte address (PC value)
    output wire [31:0] instr  // 32-bit instruction output
);

// ── Memory Array ─────────────────────────────────────────────
reg [31:0] mem [0:MEM_DEPTH-1];

// Load program from hex file at simulation start
initial begin
    $readmemh(MEM_FILE, mem);
end

// ── Word-Aligned Read ────────────────────────────────────────
// PC is byte-addressed, divide by 4 to get word index
// [31:2] gives the word address (ignore bottom 2 bits)
assign instr = mem[addr[31:2]];

endmodule
