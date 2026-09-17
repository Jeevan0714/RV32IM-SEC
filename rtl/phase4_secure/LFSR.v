// ============================================================
// 128-bit LFSR — 8-bit Parallel Mode
// Register simply loads the 8-step-ahead state (computed in KEYSTREAM)
// Advances 8 steps per clock → processes 1 full byte per cycle
// Glitch-Free Enable retained
// ============================================================

module LFSR (
    input  wire         clk,
    input  wire         rst,
    input  wire         enable,
    input  wire [127:0] L_next,   // 8-step-ahead state from KEYSTREAM module
    output reg  [127:0] L
);

    always @(posedge clk) begin
        if (rst)
            L <= 128'hACE1_2345_6789_ABCD_EF01_2345_6789_ABCE;
        else if (enable)
            L <= L_next;   // jump 8 states per clock (8-bit parallel)
    end

endmodule
