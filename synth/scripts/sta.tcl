# ==============================================================================
# OpenSTA Static Timing Analysis Script for RV32IM-SEC (SkyWater 130nm)
# ==============================================================================

if { [info exists env(TOP_MODULE)] } {
    set TOP_MODULE $env(TOP_MODULE)
} else {
    set TOP_MODULE "riscv_core_bus"
}

set LIB_FILE "synth/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set NETLIST_FILE "synth/reports/${TOP_MODULE}_netlist.v"
set SDC_FILE "synth/scripts/constraints.sdc"
set REPORT_DIR "synth/reports"

# 1. Read Liberty Timing Model & Gate Netlist
read_liberty $LIB_FILE
read_verilog $NETLIST_FILE
link_design $TOP_MODULE

# 2. Read Timing Constraints
read_sdc $SDC_FILE

# 3. Timing Checks & Reports
puts "=== Generating Timing Reports for $TOP_MODULE ==="

# Check unconstrained paths
check_setup -verbose > "$REPORT_DIR/${TOP_MODULE}_timing_checks.rpt"

# Worst Setup Slack & Critical Path Report (top 5 worst paths)
report_checks -path_delay max -fields {input_pin slew cap delay} -endpoint_count 5 -digits 3 > "$REPORT_DIR/${TOP_MODULE}_setup_timing.rpt"

# Worst Hold Slack Report (top 5 worst paths)
report_checks -path_delay min -fields {input_pin slew cap delay} -endpoint_count 5 -digits 3 > "$REPORT_DIR/${TOP_MODULE}_hold_timing.rpt"

# Power Estimation Report
report_power > "$REPORT_DIR/${TOP_MODULE}_power.rpt"

puts "=== STA Completed Successfully for $TOP_MODULE ==="
exit
