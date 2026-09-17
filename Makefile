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

# ── Phase 2: Pipeline ────────────────────────────────────────
P2_SRCS = rtl/phase2_pipeline/core/riscv_pipeline.v          \
           rtl/phase2_pipeline/core/pipe_reg_IF_ID.v          \
           rtl/phase2_pipeline/core/pipe_reg_ID_EX.v          \
           rtl/phase2_pipeline/core/pipe_reg_EX_MEM.v         \
           rtl/phase2_pipeline/core/pipe_reg_MEM_WB.v         \
           rtl/phase2_pipeline/hazard/hazard_unit.v           \
           rtl/phase2_pipeline/hazard/forwarding_unit.v       \
           rtl/phase1_single_cycle/core/control_unit.v        \
           rtl/phase1_single_cycle/core/alu_control.v         \
           rtl/phase1_single_cycle/utils/alu.v                \
           rtl/phase1_single_cycle/utils/register_file.v      \
           rtl/phase1_single_cycle/utils/imm_gen.v            \
           rtl/phase1_single_cycle/memory/instr_mem.v         \
           rtl/phase1_single_cycle/memory/data_mem.v          \
           tb/phase2/tb_riscv_pipeline.v

P2_TOP  = tb_riscv_pipeline
P2_OUT  = sim/phase2/sim_pipeline

# ── Phase 3: M-Extension ─────────────────────────────────────
P3_SRCS = rtl/phase3_mext/multiplier.v                       \
           rtl/phase3_mext/divider.v                          \
           rtl/phase2_pipeline/core/riscv_pipeline.v          \
           rtl/phase2_pipeline/core/pipe_reg_IF_ID.v          \
           rtl/phase2_pipeline/core/pipe_reg_ID_EX.v          \
           rtl/phase2_pipeline/core/pipe_reg_EX_MEM.v         \
           rtl/phase2_pipeline/core/pipe_reg_MEM_WB.v         \
           rtl/phase2_pipeline/hazard/hazard_unit.v           \
           rtl/phase2_pipeline/hazard/forwarding_unit.v       \
           rtl/phase1_single_cycle/core/control_unit.v        \
           rtl/phase1_single_cycle/core/alu_control.v         \
           rtl/phase1_single_cycle/utils/alu.v                \
           rtl/phase1_single_cycle/utils/register_file.v      \
           rtl/phase1_single_cycle/utils/imm_gen.v            \
           rtl/phase1_single_cycle/memory/instr_mem.v         \
           rtl/phase1_single_cycle/memory/data_mem.v          \
           tb/phase3/tb_riscv_mext.v

P3_TOP  = tb_riscv_mext
P3_OUT  = sim/phase3/sim_mext

# ── Phase 4: Secure SoC ──────────────────────────────────────
P4_SRCS = rtl/phase4_secure/secure_soc_top.v                 \
           rtl/phase4_secure/riscv_core_bus.v                 \
           rtl/phase4_secure/address_decoder.v                \
           rtl/phase4_secure/mem_scrambler.v                  \
           rtl/phase4_secure/prng_wrapper.v                   \
           rtl/phase4_secure/lfsr_nfsr_top.v                  \
           rtl/phase4_secure/LFSR.v                           \
           rtl/phase4_secure/NFSR.v                           \
           rtl/phase4_secure/keystream.v                      \
           rtl/phase4_secure/encrypt.v                        \
           rtl/phase4_secure/decrypt.v                        \
           rtl/phase3_mext/multiplier.v                       \
           rtl/phase3_mext/divider.v                          \
           rtl/phase2_pipeline/core/pipe_reg_IF_ID.v          \
           rtl/phase2_pipeline/core/pipe_reg_ID_EX.v          \
           rtl/phase2_pipeline/core/pipe_reg_EX_MEM.v         \
           rtl/phase2_pipeline/core/pipe_reg_MEM_WB.v         \
           rtl/phase2_pipeline/hazard/hazard_unit.v           \
           rtl/phase2_pipeline/hazard/forwarding_unit.v       \
           rtl/phase1_single_cycle/core/control_unit.v        \
           rtl/phase1_single_cycle/core/alu_control.v         \
           rtl/phase1_single_cycle/utils/alu.v                \
           rtl/phase1_single_cycle/utils/register_file.v      \
           rtl/phase1_single_cycle/utils/imm_gen.v            \
           rtl/phase1_single_cycle/memory/instr_mem.v         \
           rtl/phase1_single_cycle/memory/data_mem.v          \
           tb/phase4/tb_secure_soc.v

P4_TOP  = tb_secure_soc
P4_OUT  = sim/phase4/sim_soc

# ── Targets ──────────────────────────────────────────────────
.PHONY: all sim_p1 wave_p1 sim_p2 wave_p2 sim_p3 wave_p3 sim_p4 wave_p4 clean help hex

all: hex sim_p1

# Assemble test_basic.s to 32-bit hex format expected by Verilog $readmemh
hex:
	@echo "━━━ Assembling verification/self-checking/test_basic.s ━━━"
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o sim/test.o verification/self-checking/test_basic.s
	riscv64-unknown-elf-objcopy -O verilog sim/test.o sim/program.raw.hex
	python3 -c 'with open("sim/program.raw.hex") as f: b = [t for t in f.read().split() if not t.startswith("@")]; w = [b[i+3]+b[i+2]+b[i+1]+b[i] for i in range(0, len(b), 4)]; open("program.hex", "w").write("\n".join(w)+"\n")'
	@rm -f sim/test.o sim/program.raw.hex

# Run Phase 1 simulation
sim_p1: hex
	@echo "━━━ Compiling Phase 1: Single-Cycle Core ━━━"
	@mkdir -p sim/phase1
	$(SIM) -o $(P1_OUT) -g2012 $(P1_SRCS) -I rtl/phase1_single_cycle
	@echo "━━━ Running simulation ━━━"
	vvp $(P1_OUT)

# Open waveform
wave_p1:
	$(WAVE) sim/phase1/tb_single_cycle.vcd &

# Run Phase 2 simulation
sim_p2: hex
	@echo "━━━ Compiling Phase 2: Pipelined Core ━━━"
	@mkdir -p sim/phase2
	$(SIM) -o $(P2_OUT) -g2012 $(P2_SRCS) -I rtl/phase1_single_cycle -I rtl/phase2_pipeline/core -I rtl/phase2_pipeline/hazard
	@echo "━━━ Running simulation ━━━"
	vvp $(P2_OUT)

# Open waveform for Phase 2
wave_p2:
	$(WAVE) sim/phase2/tb_pipeline.vcd &

# Run Phase 3 simulation
sim_p3: hex
	@echo "━━━ Compiling Phase 3: M-Extension ━━━"
	@mkdir -p sim/phase3
	$(SIM) -o $(P3_OUT) -g2012 $(P3_SRCS) -I rtl/phase1_single_cycle -I rtl/phase2_pipeline/core -I rtl/phase2_pipeline/hazard -I rtl/phase3_mext
	@echo "━━━ Running simulation ━━━"
	vvp $(P3_OUT)

# Open waveform for Phase 3
wave_p3:
	$(WAVE) sim/phase3/tb_mext.vcd &

# Run Phase 4 simulation
sim_p4: hex
	@echo "━━━ Compiling Phase 4: Secure SoC ━━━"
	@mkdir -p sim/phase4
	$(SIM) -o $(P4_OUT) -g2012 $(P4_SRCS) -I rtl/phase1_single_cycle -I rtl/phase2_pipeline/core -I rtl/phase2_pipeline/hazard -I rtl/phase3_mext -I rtl/phase4_secure
	@echo "━━━ Running simulation ━━━"
	vvp $(P4_OUT)

# Open waveform for Phase 4
wave_p4:
	$(WAVE) sim/phase4/tb_soc.vcd &

# Clean all outputs
clean:
	rm -rf sim/phase1/*.vcd sim/phase1/sim_* sim/phase2/*.vcd sim/phase2/sim_* sim/phase3/*.vcd sim/phase3/sim_* sim/phase4/*.vcd sim/phase4/sim_* program.hex sim/*.o sim/*.hex

# Help
help:
	@echo "Targets:"
	@echo "  sim_p1   — Compile assembly, build 32-bit hex, and simulate Phase 1"
	@echo "  sim_p2   — Compile and simulate Phase 2 Pipeline"
	@echo "  sim_p3   — Compile and simulate Phase 3 M-Extension"
	@echo "  sim_p4   — Compile and simulate Phase 4 Secure SoC"
	@echo "  hex      — Assemble test_basic.s to program.hex"
	@echo "  wave_p1  — Open Phase 1 waveform in GTKWave"
	@echo "  wave_p2  — Open Phase 2 waveform in GTKWave"
	@echo "  wave_p3  — Open Phase 3 waveform in GTKWave"
	@echo "  wave_p4  — Open Phase 4 waveform in GTKWave"
	@echo "  clean    — Remove all simulation outputs"
