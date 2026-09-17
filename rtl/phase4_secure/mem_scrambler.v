// ============================================================
// Memory Scrambler
// XORs CPU data with PRNG keystream to protect physical RAM
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 4
// ============================================================

module mem_scrambler (
    // From PRNG
    input  wire [31:0] keystream,
    
    // CPU Interface
    input  wire [31:0] cpu_wr_data,
    output wire [31:0] cpu_rd_data,
    
    // Physical RAM Interface
    output wire [31:0] ram_wr_data,
    input  wire [31:0] ram_rd_data
);

    // Scramble on write to RAM
    assign ram_wr_data = cpu_wr_data ^ keystream;
    
    // Unscramble on read from RAM
    assign cpu_rd_data = ram_rd_data ^ keystream;

endmodule
