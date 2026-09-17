// ============================================================
// Encryption — 8-bit Parallel
// C[7:0] = P[7:0] XOR Z[7:0]
// One full ASCII character encrypted per clock cycle
// ============================================================

module ENCRYPT (
    input  wire [7:0] plaintext,
    input  wire [7:0] Z,
    output wire [7:0] ciphertext
);

    assign ciphertext = plaintext ^ Z;

endmodule
