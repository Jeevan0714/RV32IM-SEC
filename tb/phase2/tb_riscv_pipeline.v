// ============================================================
// Testbench for Phase 2 Pipeline RISC-V Core
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

`timescale 1ns/1ps

module tb_riscv_pipeline();

    // Clock and Reset
    reg clk;
    reg rst_n;

    // Instantiate Phase 2 Core
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
        $dumpfile("sim/phase2/tb_pipeline.vcd");
        $dumpvars(0, tb_riscv_pipeline);

        // Reset
        rst_n = 0;
        #20;
        rst_n = 1;

        // Run simulation for enough cycles
        #1000;
        
        $display("Simulation finished. Check sim/phase2/tb_pipeline.vcd for waveforms.");
        $finish;
    end

endmodule
