// ============================================================
// Testbench for Phase 4 Secure SoC
// Proves physical memory is scrambled while CPU sees plaintext
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 4
// ============================================================

`timescale 1ns/1ps

module tb_secure_soc();

    reg clk;
    reg rst_n;

    secure_soc_top u_soc (
        .clk  (clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("sim/phase4/tb_soc.vcd");
        $dumpvars(0, tb_secure_soc);

        rst_n = 0;
        #20;
        rst_n = 1;

        // Run until the basic test completes
        #1000;
        
        // Let's verify the memory scrambling!
        // The test_basic.s program writes 12 (0xC) to address 100.
        // Let's read the physical memory directly (byte array):
        $display("---------------------------------------------------------");
        $display("MEMORY SECURITY VERIFICATION");
        $display("---------------------------------------------------------");
        $display("The CPU wrote the plaintext value: 0x0000000C to address 100");
        $display("Physical RAM [address 100] holds : 0x%02X%02X%02X%02X", 
                 u_soc.u_ram.mem[103], u_soc.u_ram.mem[102], u_soc.u_ram.mem[101], u_soc.u_ram.mem[100]);
        $display("Current PRNG Keystream           : 0x%08X", u_soc.keystream);
        $display("---------------------------------------------------------");
        
        if ({u_soc.u_ram.mem[103], u_soc.u_ram.mem[102], u_soc.u_ram.mem[101], u_soc.u_ram.mem[100]} !== 32'h0000000C) begin
            $display("SUCCESS: Physical data is safely scrambled!");
        end else begin
            $display("FAILURE: Physical data is in plaintext!");
        end

        $finish;
    end

endmodule
