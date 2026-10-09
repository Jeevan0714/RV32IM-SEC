# ==============================================================================
# OpenROAD Physical Layout Place & Route Script (Nangate 45nm)
# ==============================================================================

if { [info exists env(TOP_MODULE)] } {
    set TOP_MODULE $env(TOP_MODULE)
} else {
    set TOP_MODULE "riscv_core_bus"
}

set TECH_LEF "synth/lib/NangateOpenCellLibrary.tech.lef"
set MACRO_LEF "synth/lib/NangateOpenCellLibrary.macro.lef"
set LIB_FILE "synth/lib/NangateOpenCellLibrary_typical.lib"
set NETLIST_FILE "synth/reports/${TOP_MODULE}_45nm_netlist.v"
set SDC_FILE "synth/scripts/constraints_45nm.sdc"
set REPORT_DIR "synth/reports"

# 1. Read Technology & Standard Cell LEF
read_lef $TECH_LEF
read_lef $MACRO_LEF

# 2. Read Timing Library & Synthesized Gate Netlist
read_liberty $LIB_FILE
read_verilog $NETLIST_FILE
link_design $TOP_MODULE

# 3. Read Timing Constraints
read_sdc $SDC_FILE

# 4. Floorplanning: 45% Core Utilization, 5um margin
puts "=== 1. Initializing Floorplan ==="
initialize_floorplan -utilization 45 -aspect_ratio 1.0 -core_space 5.0 -site FreePDK45_38x28_10R_NP_162NW_34O

# 5. Generate Routing Tracks
puts "=== 2. Creating Routing Tracks ==="
make_tracks

# 6. IO Pin Placement
puts "=== 3. Placing IO Pins ==="
place_pins -hor_layers metal3 -ver_layers metal2

# 7. Global Placement
puts "=== 4. Running Global Placement ==="
global_placement -density 0.60

# 8. Detailed Placement (Legalization onto standard cell grid)
puts "=== 5. Running Detailed Placement ==="
detailed_placement

# 9. Check Placement
check_placement

# 10. Write Placed DEF Layout File
puts "=== 6. Writing Placed DEF Layout File ==="
write_def "$REPORT_DIR/${TOP_MODULE}_placed.def"

# 11. Global Routing
puts "=== 7. Global Routing ==="
set_global_routing_layer_adjustment metal1-metal10 0.5
global_route -guide_file "$REPORT_DIR/${TOP_MODULE}.guide"

write_def "$REPORT_DIR/${TOP_MODULE}_routed.def"

puts "=== Physical Layout Generation Completed Successfully for $TOP_MODULE ==="
exit
