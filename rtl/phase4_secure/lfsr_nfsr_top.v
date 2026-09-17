// ============================================================
// Top Integration Module — 128-bit Grain-128 + 8-bit Parallel Processing
//
// Architecture:
//   LFSR (128-bit reg) ──► KEYSTREAM ──► Z[7:0] ──► ENCRYPT ──► ciphertext[7:0]
//   NFSR (128-bit reg) ──►            │              Z[7:0] ──► DECRYPT ──► decrypted[7:0]
//                         │           │
//                         └─ L_next ──► LFSR (8-step advance per clock)
//                         └─ N_next ──► NFSR (8-step advance per clock)
//
// Throughput: 8 bits (1 ASCII char) per clock cycle
// Security  : 128-bit keystream (Grain-128 standard)
// ============================================================

module lfsr_nfsr_top (
    input  wire       clk,
    input  wire       rst,
    input  wire       enable,          // Glitch-Free Enable (1=Active, 0=Sleep)
    input  wire [7:0] plaintext,       // 8-bit parallel plaintext input (1 char/cycle)
    output wire [7:0] ciphertext,      // 8-bit parallel ciphertext output
    output wire [7:0] decrypted_text   // 8-bit parallel decrypted output (verify)
);

    wire [127:0] L, N;
    wire [127:0] L_next, N_next;
    wire [7:0]   Z;

    // 128-bit LFSR — advances 8 steps per clock (feeds L_next from KEYSTREAM)
    LFSR lfsr_inst (
        .clk    (clk),
        .rst    (rst),
        .enable (enable),
        .L_next (L_next),
        .L      (L)
    );

    // 128-bit NFSR — advances 8 steps per clock (feeds N_next from KEYSTREAM)
    NFSR nfsr_inst (
        .clk    (clk),
        .rst    (rst),
        .enable (enable),
        .N_next (N_next),
        .N      (N)
    );

    // 8-bit Parallel Keystream (unrolls 8 Grain-128 steps combinationally)
    KEYSTREAM ks_inst (
        .L      (L),
        .N      (N),
        .Z      (Z),
        .L_next (L_next),
        .N_next (N_next)
    );

    // 8-bit Parallel Encryption: C[7:0] = P[7:0] XOR Z[7:0]
    ENCRYPT enc_inst (
        .plaintext  (plaintext),
        .Z          (Z),
        .ciphertext (ciphertext)
    );

    // 8-bit Parallel Decryption: P[7:0] = C[7:0] XOR Z[7:0]
    DECRYPT dec_inst (
        .ciphertext   (ciphertext),
        .Z            (Z),
        .plaintext_out(decrypted_text)
    );

endmodule
