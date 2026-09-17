// ============================================================
// Pipeline Register: MEM/WB
// Holds data and control signals between Memory and Writeback
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module pipe_reg_MEM_WB (
    input  wire        clk,
    input  wire        rst_n,
    
    // ── Inputs (from MEM stage) ───────────────────────────────
    // Control
    input  wire        MEM_reg_write,
    input  wire        MEM_mem_to_reg,
    input  wire        MEM_jump,

    // Data
    input  wire [31:0] MEM_alu_result,
    input  wire [31:0] MEM_mem_rd_data,
    input  wire [4:0]  MEM_rd_addr,
    input  wire [31:0] MEM_PC_plus4,

    // ── Outputs (to WB stage) ─────────────────────────────────
    // Control
    output reg         WB_reg_write,
    output reg         WB_mem_to_reg,
    output reg         WB_jump,

    // Data
    output reg [31:0]  WB_alu_result,
    output reg [31:0]  WB_mem_rd_data,
    output reg [4:0]   WB_rd_addr,
    output reg [31:0]  WB_PC_plus4
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        WB_reg_write   <= 1'b0;
        WB_mem_to_reg  <= 1'b0;
        WB_jump        <= 1'b0;
        
        WB_alu_result  <= 32'b0;
        WB_mem_rd_data <= 32'b0;
        WB_rd_addr     <= 5'b0;
        WB_PC_plus4    <= 32'b0;
    end else begin
        WB_reg_write   <= MEM_reg_write;
        WB_mem_to_reg  <= MEM_mem_to_reg;
        WB_jump        <= MEM_jump;
        
        WB_alu_result  <= MEM_alu_result;
        WB_mem_rd_data <= MEM_mem_rd_data;
        WB_rd_addr     <= MEM_rd_addr;
        WB_PC_plus4    <= MEM_PC_plus4;
    end
end

endmodule
