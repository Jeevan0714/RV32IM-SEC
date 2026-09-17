// ============================================================
// Secure System-on-Chip (SoC) Top Level
// Integrates CPU, Memory Scrambler, PRNG, and Memories
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 4
// ============================================================

module secure_soc_top (
    input wire clk,
    input wire rst_n
);

    // ── CPU Bus Signals ─────────────────────────────────────────
    wire [31:0] cpu_instr_addr;
    wire [31:0] cpu_instr_rdata;
    
    wire [31:0] cpu_data_addr;
    wire [31:0] cpu_data_wdata;
    wire        cpu_data_ren;
    wire        cpu_data_wen;
    wire [2:0]  cpu_data_funct3;
    wire [31:0] cpu_data_rdata;
    
    // ── Address Decoder Signals ────────────────────────────────
    wire rom_en;
    wire ram_en;
    wire ram_we;
    wire prng_en;
    wire prng_we;

    // ── Memory Data Buses ──────────────────────────────────────
    wire [31:0] rom_rdata;
    wire [31:0] ram_rdata_scrambled;
    wire [31:0] ram_wdata_scrambled;
    wire [31:0] prng_rdata;
    wire [31:0] keystream;
    
    // ── 1. CPU Core ────────────────────────────────────────────
    riscv_core_bus u_cpu (
        .clk        (clk),
        .rst_n      (rst_n),
        .instr_addr (cpu_instr_addr),
        .instr_rdata(cpu_instr_rdata),
        .data_addr  (cpu_data_addr),
        .data_wdata (cpu_data_wdata),
        .data_ren   (cpu_data_ren),
        .data_wen   (cpu_data_wen),
        .data_funct3(cpu_data_funct3),
        .data_rdata (cpu_data_rdata)
    );

    // ── 2. Address Decoder ─────────────────────────────────────
    address_decoder u_decoder (
        .cpu_addr     (cpu_data_addr),
        .cpu_mem_read (cpu_data_ren),
        .cpu_mem_write(cpu_data_wen),
        .cpu_wr_data  (cpu_data_wdata),
        .rom_en       (rom_en),
        .ram_en       (ram_en),
        .ram_we       (ram_we),
        .prng_en      (prng_en),
        .prng_we      (prng_we)
    );
    
    // Multiplex CPU read data based on address range
    // If it's a RAM read, use scrambled data (unscrambled by scrambler), else if PRNG use PRNG rd data.
    assign cpu_data_rdata = prng_en ? prng_rdata : 
                            ram_en  ? (ram_rdata_scrambled ^ keystream) : 
                            32'b0;

    // ── 3. PRNG Wrapper ────────────────────────────────────────
    prng_wrapper u_prng (
        .clk         (clk),
        .rst_n       (rst_n),
        .prng_en     (prng_en),
        .prng_we     (prng_we),
        .cpu_wr_data (cpu_data_wdata),
        .prng_rd_data(prng_rdata),
        .keystream   (keystream)
    );

    // ── 4. Memory Scrambler ────────────────────────────────────
    mem_scrambler u_scrambler (
        .keystream  (keystream),
        .cpu_wr_data(cpu_data_wdata),
        .cpu_rd_data(), // (Handled in the assign mux above for simplicity)
        .ram_wr_data(ram_wdata_scrambled),
        .ram_rd_data(ram_rdata_scrambled)
    );

    // ── 5. Instruction ROM ─────────────────────────────────────
    instr_mem #(.MEM_FILE("program.hex")) u_rom (
        .addr  (cpu_instr_addr),
        .instr (cpu_instr_rdata)
    );

    // ── 6. Scrambled Data RAM ──────────────────────────────────
    data_mem u_ram (
        .clk      (clk),
        .mem_read (ram_en & ~ram_we),
        .mem_write(ram_we),
        .addr     (cpu_data_addr), // The physical RAM sees the true address, just scrambled data
        .wr_data  (ram_wdata_scrambled),
        .funct3   (cpu_data_funct3),
        .rd_data  (ram_rdata_scrambled)
    );

endmodule
