// ============================================================
// Pipeline Register: EX/MEM
// Holds data and control signals between Execute and Memory
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module pipe_reg_EX_MEM (
    input  wire        clk,
    input  wire        rst_n,
    
    // ── Inputs (from EX stage) ────────────────────────────────
    // Control: WB
    input  wire        EX_reg_write,
    input  wire        EX_mem_to_reg,
    input  wire        EX_jump,
    // Control: MEM
    input  wire        EX_mem_read,
    input  wire        EX_mem_write,

    // Data / Instr
    input  wire [31:0] EX_alu_result,
    input  wire [31:0] EX_rs2_data_fwd, // Forwarded rs2 data for store
    input  wire [4:0]  EX_rd_addr,
    input  wire [2:0]  EX_funct3,
    input  wire [31:0] EX_PC_plus4,

    // ── Outputs (to MEM stage) ────────────────────────────────
    // Control: WB
    output reg         MEM_reg_write,
    output reg         MEM_mem_to_reg,
    output reg         MEM_jump,
    // Control: MEM
    output reg         MEM_mem_read,
    output reg         MEM_mem_write,

    // Data / Instr
    output reg [31:0]  MEM_alu_result,
    output reg [31:0]  MEM_rs2_data,
    output reg [4:0]   MEM_rd_addr,
    output reg [2:0]   MEM_funct3,
    output reg [31:0]  MEM_PC_plus4
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        MEM_reg_write  <= 1'b0;
        MEM_mem_to_reg <= 1'b0;
        MEM_jump       <= 1'b0;
        MEM_mem_read   <= 1'b0;
        MEM_mem_write  <= 1'b0;
        
        MEM_alu_result <= 32'b0;
        MEM_rs2_data   <= 32'b0;
        MEM_rd_addr    <= 5'b0;
        MEM_funct3     <= 3'b0;
        MEM_PC_plus4   <= 32'b0;
    end else begin
        MEM_reg_write  <= EX_reg_write;
        MEM_mem_to_reg <= EX_mem_to_reg;
        MEM_jump       <= EX_jump;
        MEM_mem_read   <= EX_mem_read;
        MEM_mem_write  <= EX_mem_write;
        
        MEM_alu_result <= EX_alu_result;
        MEM_rs2_data   <= EX_rs2_data_fwd;
        MEM_rd_addr    <= EX_rd_addr;
        MEM_funct3     <= EX_funct3;
        MEM_PC_plus4   <= EX_PC_plus4;
    end
end

endmodule
