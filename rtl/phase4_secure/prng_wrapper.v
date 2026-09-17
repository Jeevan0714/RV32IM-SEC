// ============================================================
// PRNG Wrapper
// Adapts the 8-bit Grain-128 PRNG to a 32-bit memory bus
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 4
// ============================================================

module prng_wrapper (
    input  wire        clk,
    input  wire        rst_n,
    
    // Memory-mapped interface (for configuration, e.g. at 0x8000_0000)
    input  wire        prng_en,
    input  wire        prng_we,
    input  wire [31:0] cpu_wr_data,
    output reg  [31:0] prng_rd_data,
    
    // Keystream output (always active)
    output wire [31:0] keystream
);

    // PRNG Control Register
    // Bit 0: Enable PRNG
    reg prng_running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prng_running <= 1'b1; // Default to running for the demo
        end else if (prng_en && prng_we) begin
            prng_running <= cpu_wr_data[0];
        end
    end

    always @(*) begin
        if (prng_en && !prng_we) begin
            prng_rd_data = {31'b0, prng_running};
        end else begin
            prng_rd_data = 32'b0;
        end
    end

    // The underlying PRNG outputs 8 bits per cycle.
    // By feeding it 0 as plaintext, the ciphertext output is exactly 0 ^ Z = Z (the keystream).
    wire [7:0] z_out;
    
    lfsr_nfsr_top u_prng_core (
        .clk           (clk),
        .rst           (~rst_n),           // PRNG uses active-high reset
        .enable        (prng_running),
        .plaintext     (8'b0),             // 0 ^ Z = Z
        .ciphertext    (z_out),            // This is our keystream Z
        .decrypted_text()                  // Unused
    );

    // To avoid stalling the pipeline to accumulate 32 bits (4 cycles),
    // we duplicate the 8-bit keystream across the 32-bit word.
    // (In a production chip, you would either use a 32-bit PRNG or stall the CPU for 4 cycles)
    assign keystream = {z_out, z_out, z_out, z_out};

endmodule
