# ============================================================
# Simulation Makefile — RISC-V Processor (Icarus Verilog)
# Author  : Jeevan
# ============================================================

# ── Simulator ────────────────────────────────────────────────
SIM     = iverilog
WAVE    = gtkwave

# ── Phase 1: Single-Cycle ────────────────────────────────────
P1_SRCS = rtl/phase1_single_cycle/core/riscv_single_cycle.v  \
           rtl/phase1_single_cycle/core/control_unit.v        \
           rtl/phase1_single_cycle/core/alu_control.v         \
           rtl/phase1_single_cycle/utils/alu.v                \
           rtl/phase1_single_cycle/utils/register_file.v      \
           rtl/phase1_single_cycle/utils/imm_gen.v            \
           rtl/phase1_single_cycle/memory/instr_mem.v         \
           rtl/phase1_single_cycle/memory/data_mem.v          \
           tb/phase1/tb_riscv_single_cycle.v

P1_TOP  = tb_riscv_single_cycle
P1_OUT  = sim/phase1/sim_single_cycle

# ── Targets ──────────────────────────────────────────────────
.PHONY: all sim_p1 wave_p1 clean help

all: sim_p1

# Run Phase 1 simulation
sim_p1:
	@echo "━━━ Compiling Phase 1: Single-Cycle Core ━━━"
	@mkdir -p sim/phase1
	$(SIM) -o $(P1_OUT) -g2012 $(P1_SRCS) -I rtl/phase1_single_cycle
	@echo "━━━ Running simulation ━━━"
	vvp $(P1_OUT)

# Open waveform
wave_p1:
	$(WAVE) sim/phase1/tb_single_cycle.vcd &

# Clean all outputs
clean:
	rm -rf sim/phase1/*.vcd sim/phase1/sim_*
	rm -rf sim/phase2/*.vcd sim/phase2/sim_*

# Help
help:
	@echo "Targets:"
	@echo "  sim_p1   — Compile and simulate Phase 1 (single-cycle)"
	@echo "  wave_p1  — Open Phase 1 waveform in GTKWave"
	@echo "  clean    — Remove all simulation outputs"
