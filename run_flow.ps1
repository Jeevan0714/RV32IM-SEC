# ==============================================================================
# RV32IM-SEC: Unified Windows PowerShell Flow Runner
# ==============================================================================
param (
    [ValidateSet("p1", "p2", "p3", "p4", "all", "wave_p1", "wave_p2", "wave_p3", "wave_p4", "clean")]
    [string]$Target = "p4"
)

$ErrorActionPreference = "Stop"
$Workspace = $PSScriptRoot

function Run-Phase1 {
    Write-Host "━━━ Compiling Phase 1: Single-Cycle Core ━━━" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$Workspace\sim\phase1" | Out-Null
    $srcs = @(
        "rtl/phase1_single_cycle/core/riscv_single_cycle.v",
        "rtl/phase1_single_cycle/core/control_unit.v",
        "rtl/phase1_single_cycle/core/alu_control.v",
        "rtl/phase1_single_cycle/utils/alu.v",
        "rtl/phase1_single_cycle/utils/register_file.v",
        "rtl/phase1_single_cycle/utils/imm_gen.v",
        "rtl/phase1_single_cycle/memory/instr_mem.v",
        "rtl/phase1_single_cycle/memory/data_mem.v",
        "tb/phase1/tb_riscv_single_cycle.v"
    )
    & iverilog -o "$Workspace\sim\phase1\sim_single_cycle.vvp" -g2012 $srcs
    Write-Host "━━━ Running Phase 1 Simulation ━━━" -ForegroundColor Green
    & vvp "$Workspace\sim\phase1\sim_single_cycle.vvp"
}

function Run-Phase2 {
    Write-Host "━━━ Compiling Phase 2: Pipelined Core ━━━" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$Workspace\sim\phase2" | Out-Null
    $srcs = @(
        "rtl/phase2_pipeline/core/riscv_pipeline.v",
        "rtl/phase2_pipeline/core/pipe_reg_IF_ID.v",
        "rtl/phase2_pipeline/core/pipe_reg_ID_EX.v",
        "rtl/phase2_pipeline/core/pipe_reg_EX_MEM.v",
        "rtl/phase2_pipeline/core/pipe_reg_MEM_WB.v",
        "rtl/phase2_pipeline/hazard/hazard_unit.v",
        "rtl/phase2_pipeline/hazard/forwarding_unit.v",
        "rtl/phase1_single_cycle/core/control_unit.v",
        "rtl/phase1_single_cycle/core/alu_control.v",
        "rtl/phase1_single_cycle/utils/alu.v",
        "rtl/phase1_single_cycle/utils/register_file.v",
        "rtl/phase1_single_cycle/utils/imm_gen.v",
        "rtl/phase1_single_cycle/memory/instr_mem.v",
        "rtl/phase1_single_cycle/memory/data_mem.v",
        "tb/phase2/tb_riscv_pipeline.v"
    )
    & iverilog -o "$Workspace\sim\phase2\sim_pipeline.vvp" -g2012 $srcs
    Write-Host "━━━ Running Phase 2 Simulation ━━━" -ForegroundColor Green
    & vvp "$Workspace\sim\phase2\sim_pipeline.vvp"
}

function Run-Phase3 {
    Write-Host "━━━ Compiling Phase 3: M-Extension ━━━" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$Workspace\sim\phase3" | Out-Null
    $srcs = @(
        "rtl/phase3_mext/multiplier.v",
        "rtl/phase3_mext/divider.v",
        "rtl/phase2_pipeline/core/riscv_pipeline.v",
        "rtl/phase2_pipeline/core/pipe_reg_IF_ID.v",
        "rtl/phase2_pipeline/core/pipe_reg_ID_EX.v",
        "rtl/phase2_pipeline/core/pipe_reg_EX_MEM.v",
        "rtl/phase2_pipeline/core/pipe_reg_MEM_WB.v",
        "rtl/phase2_pipeline/hazard/hazard_unit.v",
        "rtl/phase2_pipeline/hazard/forwarding_unit.v",
        "rtl/phase1_single_cycle/core/control_unit.v",
        "rtl/phase1_single_cycle/core/alu_control.v",
        "rtl/phase1_single_cycle/utils/alu.v",
        "rtl/phase1_single_cycle/utils/register_file.v",
        "rtl/phase1_single_cycle/utils/imm_gen.v",
        "rtl/phase1_single_cycle/memory/instr_mem.v",
        "rtl/phase1_single_cycle/memory/data_mem.v",
        "tb/phase3/tb_riscv_mext.v"
    )
    & iverilog -o "$Workspace\sim\phase3\sim_mext.vvp" -g2012 $srcs
    Write-Host "━━━ Running Phase 3 Simulation ━━━" -ForegroundColor Green
    & vvp "$Workspace\sim\phase3\sim_mext.vvp"
}

function Run-Phase4 {
    Write-Host "━━━ Compiling Phase 4: Secure SoC ━━━" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$Workspace\sim\phase4" | Out-Null
    $srcs = @(
        "rtl/phase4_secure/secure_soc_top.v",
        "rtl/phase4_secure/riscv_core_bus.v",
        "rtl/phase4_secure/address_decoder.v",
        "rtl/phase4_secure/mem_scrambler.v",
        "rtl/phase4_secure/prng_wrapper.v",
        "rtl/phase4_secure/lfsr_nfsr_top.v",
        "rtl/phase4_secure/LFSR.v",
        "rtl/phase4_secure/NFSR.v",
        "rtl/phase4_secure/keystream.v",
        "rtl/phase4_secure/encrypt.v",
        "rtl/phase4_secure/decrypt.v",
        "rtl/phase3_mext/multiplier.v",
        "rtl/phase3_mext/divider.v",
        "rtl/phase2_pipeline/core/pipe_reg_IF_ID.v",
        "rtl/phase2_pipeline/core/pipe_reg_ID_EX.v",
        "rtl/phase2_pipeline/core/pipe_reg_EX_MEM.v",
        "rtl/phase2_pipeline/core/pipe_reg_MEM_WB.v",
        "rtl/phase2_pipeline/hazard/hazard_unit.v",
        "rtl/phase2_pipeline/hazard/forwarding_unit.v",
        "rtl/phase1_single_cycle/core/control_unit.v",
        "rtl/phase1_single_cycle/core/alu_control.v",
        "rtl/phase1_single_cycle/utils/alu.v",
        "rtl/phase1_single_cycle/utils/register_file.v",
        "rtl/phase1_single_cycle/utils/imm_gen.v",
        "rtl/phase1_single_cycle/memory/instr_mem.v",
        "rtl/phase1_single_cycle/memory/data_mem.v",
        "tb/phase4/tb_secure_soc.v"
    )
    & iverilog -o "$Workspace\sim\phase4\sim_soc.vvp" -g2012 $srcs
    Write-Host "━━━ Running Phase 4 Simulation ━━━" -ForegroundColor Green
    & vvp "$Workspace\sim\phase4\sim_soc.vvp"
}

switch ($Target) {
    "p1" { Run-Phase1 }
    "p2" { Run-Phase2 }
    "p3" { Run-Phase3 }
    "p4" { Run-Phase4 }
    "all" {
        Run-Phase1
        Run-Phase2
        Run-Phase3
        Run-Phase4
    }
    "wave_p1" { & gtkwave "$Workspace\sim\phase1\tb_single_cycle.vcd" }
    "wave_p2" { & gtkwave "$Workspace\sim\phase2\tb_pipeline.vcd" }
    "wave_p3" { & gtkwave "$Workspace\sim\phase3\tb_mext.vcd" }
    "wave_p4" { & gtkwave "$Workspace\sim\phase4\tb_soc.vcd" }
    "clean" {
        Remove-Item -Recurse -Force "$Workspace\sim\phase1\*", "$Workspace\sim\phase2\*", "$Workspace\sim\phase3\*", "$Workspace\sim\phase4\*" -ErrorAction SilentlyContinue
        Write-Host "Cleaned simulation artifacts." -ForegroundColor Yellow
    }
}
