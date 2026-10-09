# ==============================================================================
# SDC Timing Constraints for RV32IM-SEC on 45nm Technology
# ==============================================================================

# Target Clock: 100 MHz (Period = 10.0 ns)
create_clock -name clk -period 10.0 [get_ports clk]

# Clock Uncertainty / Jitter
set_clock_uncertainty 0.1 [get_clocks clk]

# Input / Output Delays
set_input_delay -clock clk 1.5 [all_inputs]
set_output_delay -clock clk 1.5 [all_outputs]

# Output Load capacitance (5 fF for 45nm standard load)
set_load 0.005 [all_outputs]
