// ============================================================
// 128-bit NFSR — 8-bit Parallel Mode
// Register simply loads the 8-step-ahead state (computed in KEYSTREAM)
// Advances 8 steps per clock → processes 1 full byte per cycle
// Glitch-Free Enable retained
// ============================================================

module NFSR (
    input  wire         clk,
    input  wire         rst,
    input  wire         enable,
    input  wire [127:0] N_next,   // 8-step-ahead state from KEYSTREAM module
    output reg  [127:0] N
);

    always @(posedge clk) begin
        if (rst)
            N <= 128'h1234_5678_9ABC_DEF0_1234_5678_9ABC_DEF0;
        else if (enable)
            N <= N_next;   // jump 8 states per clock (8-bit parallel)
    end

endmodule
