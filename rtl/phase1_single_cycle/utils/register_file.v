// ============================================================
// Register File — 32 × 32-bit Registers
// x0 is hardwired to 0 (RISC-V spec requirement)
// 2 async read ports, 1 sync write port
// Author  : Jeevan
// Project : RISC-V RV32IM Processor
// ============================================================

module register_file (
    input  wire        clk,
    input  wire        we,         // Write Enable
    input  wire [4:0]  rs1,        // Source register 1 address
    input  wire [4:0]  rs2,        // Source register 2 address
    input  wire [4:0]  rd,         // Destination register address
    input  wire [31:0] wd,         // Write data
    output wire [31:0] rd1,        // Read data 1
    output wire [31:0] rd2         // Read data 2
);

// ── Register Array ───────────────────────────────────────────
reg [31:0] regs [31:0];

// Initialize all registers to 0
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1)
        regs[i] = 32'b0;
end

// ── Write Port (Synchronous, rising edge) ────────────────────
// x0 is NEVER written (hardwired to 0 per RISC-V spec)
always @(posedge clk) begin
    if (we && (rd != 5'b0))
        regs[rd] <= wd;
end

// ── Read Ports (Asynchronous) ────────────────────────────────
// x0 always reads as 0
assign rd1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
assign rd2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

// ── Debug: Named register aliases (ABI names) ────────────────
// Useful for waveform viewing
// x0=zero, x1=ra, x2=sp, x3=gp, x4=tp
// x5-x7=t0-t2, x8-x9=s0-s1, x10-x17=a0-a7
// x18-x27=s2-s11, x28-x31=t3-t6

endmodule
