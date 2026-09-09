// ============================================================
// Testbench — Single-Cycle RV32I Core
// Runs basic RV32I instruction tests
// Author  : Jeevan
// ============================================================

`timescale 1ns/1ps

module tb_riscv_single_cycle;

// ── DUT Signals ───────────────────────────────────────────────
reg clk, rst_n;

// ── DUT Instantiation ─────────────────────────────────────────
riscv_single_cycle dut (
    .clk   (clk),
    .rst_n (rst_n)
);

// ── Clock: 10ns period (100 MHz) ─────────────────────────────
initial clk = 0;
always #5 clk = ~clk;

// ── Waveform Dump ─────────────────────────────────────────────
initial begin
    $dumpfile("sim/phase1/tb_single_cycle.vcd");
    $dumpvars(0, tb_riscv_single_cycle);
end

// ── Reset Sequence ────────────────────────────────────────────
initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
    $display("[%0t] Reset deasserted — CPU starting", $time);
end

// ── Monitor: print PC and instruction each cycle ──────────────
always @(posedge clk) begin
    if (rst_n)
        $display("[%0t] PC=0x%08h | INSTR=0x%08h | RF[10]=0x%08h",
                  $time,
                  dut.PC,
                  dut.instr,
                  dut.u_rf.regs[10]);  // a0 register
end

// ── Timeout ───────────────────────────────────────────────────
initial begin
    #10000;
    $display("TIMEOUT: simulation ended at %0t ns", $time);
    $finish;
end

// ── Pass/Fail Check ───────────────────────────────────────────
// Convention: test passes if register a0 (x10) = 0x1 at end
// (can be customized per test program)
initial begin
    #9990;
    if (dut.u_rf.regs[10] === 32'h1)
        $display("✅ PASS: a0 = 0x%08h", dut.u_rf.regs[10]);
    else
        $display("❌ FAIL: a0 = 0x%08h (expected 0x00000001)", dut.u_rf.regs[10]);
end

endmodule
