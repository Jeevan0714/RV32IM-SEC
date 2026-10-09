# ==============================================================================
# SDC Timing Constraints for RV32IM-SEC
# ==============================================================================

# Target Clock: 50 MHz (Period = 20.0 ns)
create_clock -name clk -period 20.0 [get_ports clk]

# Clock Uncertainty / Jitter
set_clock_uncertainty 0.2 [get_clocks clk]

# Input / Output Delays (External interfaces)
set_input_delay -clock clk 3.0 [all_inputs]
set_output_delay -clock clk 3.0 [all_outputs]

# Output Load capacitance (0.035 pF per output pin)
set_load 0.035 [all_outputs]
