# RV32IM Secure Processor — Project Documentation
**Author:** Jeevan
**Technology:** 45nm (same as PRNG project)

---

## What This Chip Is

A 32-bit RISC-V processor (RV32IM) with a hardware **memory scrambling engine**
powered by the Grain-128 PRNG already designed and taped out.

Every byte written to RAM is XOR'd with the PRNG keystream before storage.
Every byte read back is XOR'd again to restore original data.
An attacker physically probing the RAM sees only garbage — never real data.

This makes it a **Secure IoT Processor** — a processor that can run real programs
AND protect its memory from physical attacks, on a single chip.

---

## Final Product Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    RV32IM SECURE IoT SoC                        │
│                                                                 │
│   ┌──────────────────────────────────┐                          │
│   │        RV32IM CPU CORE           │                          │
│   │   5-stage in-order pipeline      │                          │
│   │   IF → ID → EX → MEM → WB       │                          │
│   └─────────────┬────────────────────┘                          │
│                 │  data bus (32-bit)                            │
│                 ▼                                               │
│   ┌─────────────────────────────────┐                           │
│   │       ADDRESS DECODER           │                           │
│   │  0x0000_0000 → Instruction ROM  │                           │
│   │  0x0001_0000 → Scrambled RAM    │                           │
│   │  0x8000_0000 → PRNG Control     │                           │
│   └──────┬──────────────┬───────────┘                           │
│          │              │                                       │
│          ▼              ▼                                       │
│   ┌────────────┐  ┌─────────────────────────────────────────┐  │
│   │ Instr ROM  │  │         SCRAMBLED RAM                   │  │
│   │ (program)  │  │                                         │  │
│   └────────────┘  │  CPU write → XOR(data, PRNG) → RAM      │  │
│                   │  CPU read  → XOR(RAM,  PRNG) → CPU      │  │
│                   │                   ↑                      │  │
│                   │          ┌────────┴──────────┐           │  │
│                   │          │  Grain-128 PRNG   │           │  │
│                   │          │  (already built!) │           │  │
│                   │          │  128-bit LFSR+NFSR│           │  │
│                   └──────────└───────────────────┘           │  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Build Phases

### Phase 1 — Single-Cycle RV32I Core  ← START HERE
Build a working CPU where every instruction takes exactly 1 clock cycle.
No pipeline. No hazards. Just a correct, working processor.

Files to build:
- `rtl/phase1_single_cycle/utils/alu.v`            ✅ done
- `rtl/phase1_single_cycle/utils/register_file.v`  ✅ done
- `rtl/phase1_single_cycle/utils/imm_gen.v`        ✅ done
- `rtl/phase1_single_cycle/memory/instr_mem.v`     ✅ done
- `rtl/phase1_single_cycle/memory/data_mem.v`      ✅ done
- `rtl/phase1_single_cycle/core/control_unit.v`    ✅ done
- `rtl/phase1_single_cycle/core/alu_control.v`     ✅ done
- `rtl/phase1_single_cycle/core/riscv_single_cycle.v` ✅ done
- `tb/phase1/tb_riscv_single_cycle.v`              ✅ done

Goal: Run a simple add/branch program. See correct result in simulation.

---

### Phase 2 — 5-Stage Pipelined RV32I
Convert the single-cycle CPU into a 5-stage pipeline so multiple instructions
run simultaneously (like an assembly line). Handle hazards.

Files to build:
- 4 pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
  - `rtl/phase2_pipeline/core/pipe_reg_IF_ID.v`   ✅ done (starter)
  - ID/EX, EX/MEM, MEM/WB registers               ← todo
- `rtl/phase2_pipeline/hazard/hazard_unit.v`       ✅ done
- `rtl/phase2_pipeline/hazard/forwarding_unit.v`   ✅ done
- Pipeline top-level core                          ← todo

Goal: Same programs run correctly, but now at much higher throughput.

---

### Phase 3 — M Extension (Multiply & Divide)
Add hardware multiply and divide so the chip can run real arithmetic
without faking it with thousands of add instructions.

Files to build:
- `rtl/phase3_mext/multiplier.v`     ← 32×32 → 64-bit
- `rtl/phase3_mext/divider.v`        ← non-restoring 32-bit divider
- Updated ALU control to detect M-ext opcodes

Goal: `MUL`, `DIV`, `REM` instructions work correctly.

---

### Phase 4 — Memory Scrambler + PRNG Integration
The main idea of this project. Connect the Grain-128 PRNG to the CPU
as a memory scrambling engine. All RAM data is XOR-encrypted with the
PRNG keystream at hardware level. No software change needed.

Files to build:
- `rtl/phase4_secure/address_decoder.v`   ← routes bus to ROM/RAM/PRNG
- `rtl/phase4_secure/mem_scrambler.v`     ← XOR gate between CPU and RAM
- `rtl/phase4_secure/prng_wrapper.v`      ← adapts Grain-128 to memory bus
- `rtl/phase4_secure/secure_soc_top.v`   ← top-level wiring everything

Goal: Run a program, dump RAM contents, show scrambled vs unscrambled data.
Proof: attacker reading RAM sees garbage. CPU sees correct values.

---

## What You Learn at Each Phase

| Phase | Key Concepts |
|-------|-------------|
| 1 | Datapath, control signals, instruction encoding, ISA |
| 2 | Pipelining, data hazards, forwarding, branch hazards |
| 3 | Multi-cycle units, stall logic, functional units |
| 4 | Memory-mapped I/O, bus architecture, security design |

---

## How to Simulate

```bash
cd "/home/jeevan/Desktop/my projects/RV32IM-SEC"
make sim_p1      # compile and run Phase 1
make wave_p1     # open waveform in GTKWave
```

---

## Tools

All tools below are free and open-source.

### Stage 1 — Writing RTL (Now)
| Tool | Purpose | Install |
|------|---------|---------|
| VS Code | Write Verilog files | Already installed |
| Verilator | Lint RTL — catches errors before simulation | `sudo apt install verilator` |

```bash
# Check a file for errors before simulating
verilator --lint-only rtl/phase1_single_cycle/core/riscv_single_cycle.v
```

### Stage 2 — Simulation (Phases 1–4)
| Tool | Purpose | Install |
|------|---------|---------|
| Icarus Verilog (iverilog) | Compiles and runs Verilog testbenches | `sudo apt install iverilog` |
| GTKWave | Opens `.vcd` waveform files — see signals visually | `sudo apt install gtkwave` |
| Spike | Golden RISC-V ISA simulator — verify your output is correct | build from source |

```bash
# Simulate
iverilog -o sim_out tb/phase1/tb_riscv_single_cycle.v rtl/...
vvp sim_out

# Open waveform
gtkwave sim/phase1/tb.vcd
```

### Stage 3 — Writing Test Programs (Phases 1–4)
| Tool | Purpose | Install |
|------|---------|---------|
| riscv64-unknown-elf-gcc | Compile C programs → RISC-V binary | `sudo apt install gcc-riscv64-unknown-elf` |
| riscv64-unknown-elf-objcopy | Convert compiled binary → `.hex` for simulation | same package |
| riscv64-unknown-elf-objdump | Disassemble — see what assembly your C became | same package |

```bash
# Compile C → RISC-V binary
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib -o prog.elf prog.c

# Convert to hex file your instr_mem.v can load
riscv64-unknown-elf-objcopy -O verilog prog.elf program.hex

# See the assembly your C produced
riscv64-unknown-elf-objdump -d prog.elf
```

### Stage 4 — Formal Verification (Phase 2+, optional but powerful)
| Tool | Purpose | Install |
|------|---------|---------|
| SymbiYosys | Formally proves RTL correctness — finds bugs simulation misses | build from source |
| Yosys | Used inside SymbiYosys | `sudo apt install yosys` |

> Especially useful for verifying forwarding unit and hazard detection logic is provably correct.

### Stage 5 — Synthesis + GDS-II (After Phase 4)
| Tool | Purpose | Install |
|------|---------|---------|
| OpenLane | Full RTL → GDS-II automated flow (replaces Synopsys DC) | Docker + git clone |
| Yosys | Synthesis (RTL → gate netlist) — bundled inside OpenLane | included |
| OpenSTA | Static Timing Analysis — checks if design meets target clock | included |
| OpenROAD | Floorplan + Place + Route — bundled inside OpenLane | included |
| Magic | Layout DRC check — bundled inside OpenLane | included |
| KLayout | View and inspect the final GDS-II file | `sudo apt install klayout` |
| Sky130 PDK | Google/SkyWater 130nm open-source process design kit | included with OpenLane |

```bash
# Install OpenLane (do this when reaching synthesis phase)
git clone https://github.com/The-OpenROAD-Project/OpenLane
cd OpenLane && make

# Run full RTL → GDS flow on your design
./flow.tcl -design rv32im_secure

# View the final GDS file
klayout output/rv32im_secure.gds
```

> After Phase 4, the final GDS can be submitted to the **Google MPW shuttle**
> — a free tapeout program where Google pays for fabrication and mails you
> real silicon chips. Uses Sky130 PDK (130nm).

### Quick Install — Everything for Phases 1–4

```bash
sudo apt install iverilog gtkwave verilator yosys klayout \
                 gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```
