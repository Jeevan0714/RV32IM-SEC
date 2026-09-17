// ============================================================
// Testbench for Phase 3 M-Extension RISC-V Core
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 3
// ============================================================

`timescale 1ns/1ps

module tb_riscv_mext();

    // Clock and Reset
    reg clk;
    reg rst_n;

    // Instantiate Phase 3 Core
    riscv_pipeline u_core (
        .clk  (clk),
        .rst_n(rst_n)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        $dumpfile("sim/phase3/tb_mext.vcd");
        $dumpvars(0, tb_riscv_mext);

        // Reset
        rst_n = 0;
        #20;
        rst_n = 1;

        // Run simulation for enough cycles
        // Multiplication and division take 32 cycles each, so we need more time
        #5000;
        
        $display("Simulation finished. Check sim/phase3/tb_mext.vcd for waveforms.");
        $finish;
    end

endmodule
