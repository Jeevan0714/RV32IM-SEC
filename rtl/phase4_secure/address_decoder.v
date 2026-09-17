// ============================================================
// Memory Address Decoder
// Routes memory access to ROM, RAM, or PRNG based on address
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 4
// ============================================================

module address_decoder (
    input  wire [31:0] cpu_addr,
    input  wire        cpu_mem_read,
    input  wire        cpu_mem_write,
    input  wire [31:0] cpu_wr_data,
    
    // To Instruction ROM (0x0000_0000)
    output wire        rom_en,
    
    // To RAM Scrambler (0x0001_0000)
    output wire        ram_en,
    output wire        ram_we,
    
    // To PRNG Control (0x8000_0000)
    output wire        prng_en,
    output wire        prng_we
);

    // Data Address Map:
    // 0x8000_XXXX -> PRNG Wrapper
    // Everything else -> RAM (Data Memory via Scrambler)
    // (Note: Instruction fetches go directly to ROM in SoC top, not through this decoder)

    assign prng_en = (cpu_addr[31:16] == 16'h8000) & (cpu_mem_read | cpu_mem_write);
    assign prng_we = (cpu_addr[31:16] == 16'h8000) & cpu_mem_write;

    assign rom_en  = 1'b0; // Not used for data accesses
    
    assign ram_en  = ~prng_en & (cpu_mem_read | cpu_mem_write);
    assign ram_we  = ~prng_en & cpu_mem_write;

endmodule
