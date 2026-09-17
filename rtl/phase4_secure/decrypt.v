// ============================================================
// Decryption — 8-bit Parallel
// P[7:0] = C[7:0] XOR Z[7:0]
// One full ASCII character decrypted per clock cycle
// ============================================================

module DECRYPT (
    input  wire [7:0] ciphertext,
    input  wire [7:0] Z,
    output wire [7:0] plaintext_out
);

    assign plaintext_out = ciphertext ^ Z;

endmodule
