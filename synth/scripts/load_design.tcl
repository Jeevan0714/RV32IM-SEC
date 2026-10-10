# ==============================================================================
# OpenROAD GUI Design Loader (Nangate 45nm)
# ==============================================================================
set TECH_LEF "synth/lib/NangateOpenCellLibrary.tech.lef"
set MACRO_LEF "synth/lib/NangateOpenCellLibrary.macro.lef"
set LIB_FILE  "synth/lib/NangateOpenCellLibrary_typical.lib"

if { [info exists env(TOP_MODULE)] } {
    set MODULE $env(TOP_MODULE)
} else {
    set MODULE "riscv_core_bus"
}

set DEF_FILE "synth/reports/${MODULE}_routed.def"
if { ![file exists $DEF_FILE] } {
    set DEF_FILE "synth/reports/${MODULE}_placed.def"
}

puts "Loading 45nm LEF technology and standard cell macros..."
read_lef $TECH_LEF
read_lef $MACRO_LEF

puts "Loading 45nm timing library..."
read_liberty $LIB_FILE

puts "Loading physical layout: $DEF_FILE"
read_def $DEF_FILE

puts "=========================================================="
puts "  SUCCESS: $MODULE layout loaded into OpenROAD GUI!"
puts "=========================================================="
