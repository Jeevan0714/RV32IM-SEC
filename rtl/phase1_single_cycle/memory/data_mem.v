// ============================================================
// Data Memory — RAM (Read/Write)
// Byte-addressable, word-aligned access
// Supports: LW/SW (word), LH/SH (half), LB/SB (byte)
// Author  : Jeevan
// Project : RISC-V RV32IM Processor
// ============================================================

module data_mem #(
    parameter MEM_DEPTH = 1024   // Number of bytes
)(
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,       // Byte address
    input  wire [31:0] wr_data,    // Data to write
    input  wire [2:0]  funct3,     // Width control (from instr[14:12])
    output reg  [31:0] rd_data     // Data read out
);

// ── Memory Array (byte-addressable) ──────────────────────────
reg [7:0] mem [0:MEM_DEPTH-1];

integer i;
initial begin
    for (i = 0; i < MEM_DEPTH; i = i + 1)
        mem[i] = 8'b0;
end

// ── Read (Asynchronous) ───────────────────────────────────────
// funct3: 000=LB, 001=LH, 010=LW, 100=LBU, 101=LHU
always @(*) begin
    rd_data = 32'b0;
    if (mem_read) begin
        case (funct3)
            3'b000: rd_data = {{24{mem[addr][7]}}, mem[addr]};              // LB  (sign-ext byte)
            3'b001: rd_data = {{16{mem[addr+1][7]}},
                                mem[addr+1], mem[addr]};                     // LH  (sign-ext half)
            3'b010: rd_data = {mem[addr+3], mem[addr+2],
                                mem[addr+1], mem[addr]};                     // LW  (full word)
            3'b100: rd_data = {24'b0, mem[addr]};                           // LBU (zero-ext byte)
            3'b101: rd_data = {16'b0, mem[addr+1], mem[addr]};              // LHU (zero-ext half)
            default: rd_data = 32'b0;
        endcase
    end
end

// ── Write (Synchronous) ───────────────────────────────────────
// funct3: 000=SB, 001=SH, 010=SW
always @(posedge clk) begin
    if (mem_write) begin
        case (funct3)
            3'b000: begin                                                    // SB
                mem[addr] <= wr_data[7:0];
            end
            3'b001: begin                                                    // SH
                mem[addr]   <= wr_data[7:0];
                mem[addr+1] <= wr_data[15:8];
            end
            3'b010: begin                                                    // SW
                mem[addr]   <= wr_data[7:0];
                mem[addr+1] <= wr_data[15:8];
                mem[addr+2] <= wr_data[23:16];
                mem[addr+3] <= wr_data[31:24];
            end
            default: ; // No-op for unsupported funct3 values
        endcase
    end
end

endmodule
