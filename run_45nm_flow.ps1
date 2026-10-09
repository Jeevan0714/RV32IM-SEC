# ==============================================================================
# Complete 45nm ASIC Flow: Synthesis, STA, & OpenROAD Physical Layout (PnR)
# ==============================================================================

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  RV32IM-SEC: Complete 45nm ASIC Physical Design Flow (OpenROAD)  " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Synthesize CPU Core & PRNG with Yosys
Write-Host "`n[1/4] Running Yosys Logic Synthesis (Nangate 45nm)..." -ForegroundColor Yellow
wsl -d Ubuntu bash -c "cd '/mnt/c/Users/WIN10/Desktop/my projects 1/RV32IM-SEC' && yosys -s synth/scripts/synth_core_45nm.ys && yosys -s synth/scripts/synth_prng_45nm.ys"

# 2. Run Static Timing Analysis with OpenSTA
Write-Host "`n[2/4] Running OpenSTA Static Timing Analysis (100 MHz Target)..." -ForegroundColor Yellow
wsl -d Ubuntu bash -c "cd '/mnt/c/Users/WIN10/Desktop/my projects 1/RV32IM-SEC' && export TOP_MODULE=riscv_core_bus && sta synth/scripts/sta_45nm.tcl"
wsl -d Ubuntu bash -c "cd '/mnt/c/Users/WIN10/Desktop/my projects 1/RV32IM-SEC' && export TOP_MODULE=lfsr_nfsr_top && sta synth/scripts/sta_45nm.tcl"

# 3. Run OpenROAD Physical Place & Route (Floorplan, Placement, Routing)
Write-Host "`n[3/4] Running OpenROAD Physical Place & Route (Nangate 45nm)..." -ForegroundColor Yellow
docker run --rm -v "${PWD}:/work" -w /work -e TOP_MODULE=riscv_core_bus efabless/openlane:2023.09.07 /build/bin/openroad synth/scripts/openroad_pnr.tcl
docker run --rm -v "${PWD}:/work" -w /work -e TOP_MODULE=lfsr_nfsr_top efabless/openlane:2023.09.07 /build/bin/openroad synth/scripts/openroad_pnr.tcl

# 4. Render Physical Layout Images (KLayout)
Write-Host "`n[4/4] Generating High-Resolution Physical Silicon Layout Images..." -ForegroundColor Yellow
docker run --rm -v "${PWD}:/work" -w /work -e QT_QPA_PLATFORM=offscreen efabless/openlane:2023.09.07 /build/bin/klayout -z -r synth/scripts/render_layout.py

Write-Host "`n=================================================================" -ForegroundColor Green
Write-Host "  SUCCESS: Full ASIC Physical Layout Flow Completed!             " -ForegroundColor Green
Write-Host "  • Placed & Routed DEF : synth/reports/riscv_core_bus_routed.def " -ForegroundColor Green
Write-Host "  • Placed & Routed DEF : synth/reports/lfsr_nfsr_top_routed.def  " -ForegroundColor Green
Write-Host "  • Silicon Layout View : synth/reports/riscv_core_bus_layout.png " -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
