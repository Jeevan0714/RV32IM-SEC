// ============================================================
// Pipeline Register: ID/EX
// Holds data and control signals between Decode and Execute
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 2
// ============================================================

module pipe_reg_ID_EX (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,      // 1 = freeze this register (for multi-cycle M-ext)
    input  wire        flush,      // 1 = insert NOP (load-use hazard or branch mispredict)

    // ── Inputs (from ID stage) ────────────────────────────────
    // Control: WB
    input  wire        ID_reg_write,
    input  wire        ID_mem_to_reg,
    // Control: MEM
    input  wire        ID_mem_read,
    input  wire        ID_mem_write,
    // Control: EX
    input  wire        ID_branch,
    input  wire        ID_jump,
    input  wire        ID_alu_src,
    input  wire [1:0]  ID_alu_op,
    input  wire        ID_auipc,
    input  wire        ID_is_mext,

    // Data / Instr
    input  wire [31:0] ID_PC,
    input  wire [31:0] ID_rs1_data,
    input  wire [31:0] ID_rs2_data,
    input  wire [31:0] ID_imm_ext,
    input  wire [4:0]  ID_rs1_addr,
    input  wire [4:0]  ID_rs2_addr,
    input  wire [4:0]  ID_rd_addr,
    input  wire [2:0]  ID_funct3,
    input  wire        ID_funct7_5,

    // ── Outputs (to EX stage) ─────────────────────────────────
    // Control: WB
    output reg         EX_reg_write,
    output reg         EX_mem_to_reg,
    // Control: MEM
    output reg         EX_mem_read,
    output reg         EX_mem_write,
    // Control: EX
    output reg         EX_branch,
    output reg         EX_jump,
    output reg         EX_alu_src,
    output reg [1:0]   EX_alu_op,
    output reg         EX_auipc,
    output reg         EX_is_mext,

    // Data / Instr
    output reg [31:0]  EX_PC,
    output reg [31:0]  EX_rs1_data,
    output reg [31:0]  EX_rs2_data,
    output reg [31:0]  EX_imm_ext,
    output reg [4:0]   EX_rs1_addr,
    output reg [4:0]   EX_rs2_addr,
    output reg [4:0]   EX_rd_addr,
    output reg [2:0]   EX_funct3,
    output reg         EX_funct7_5
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all control signals to 0 (NOP)
        EX_reg_write  <= 1'b0;
        EX_mem_to_reg <= 1'b0;
        EX_mem_read   <= 1'b0;
        EX_mem_write  <= 1'b0;
        EX_branch     <= 1'b0;
        EX_jump       <= 1'b0;
        EX_alu_src    <= 1'b0;
        EX_alu_op     <= 2'b00;
        EX_auipc      <= 1'b0;
        EX_is_mext    <= 1'b0;
        // Data can be zeroed
        EX_PC         <= 32'b0;
        EX_rs1_data   <= 32'b0;
        EX_rs2_data   <= 32'b0;
        EX_imm_ext    <= 32'b0;
        EX_rs1_addr   <= 5'b0;
        EX_rs2_addr   <= 5'b0;
        EX_rd_addr    <= 5'b0;
        EX_funct3     <= 3'b0;
        EX_funct7_5   <= 1'b0;
    end else if (flush) begin
        // Flush clears control signals (inserts NOP)
        EX_reg_write  <= 1'b0;
        EX_mem_to_reg <= 1'b0;
        EX_mem_read   <= 1'b0;
        EX_mem_write  <= 1'b0;
        EX_branch     <= 1'b0;
        EX_jump       <= 1'b0;
        EX_alu_src    <= 1'b0;
        EX_alu_op     <= 2'b00;
        EX_auipc      <= 1'b0;
        EX_is_mext    <= 1'b0;
    end else if (!stall) begin
        // Normal operation
        EX_reg_write  <= ID_reg_write;
        EX_mem_to_reg <= ID_mem_to_reg;
        EX_mem_read   <= ID_mem_read;
        EX_mem_write  <= ID_mem_write;
        EX_branch     <= ID_branch;
        EX_jump       <= ID_jump;
        EX_alu_src    <= ID_alu_src;
        EX_alu_op     <= ID_alu_op;
        EX_auipc      <= ID_auipc;
        EX_is_mext    <= ID_is_mext;
        
        EX_PC         <= ID_PC;
        EX_rs1_data   <= ID_rs1_data;
        EX_rs2_data   <= ID_rs2_data;
        EX_imm_ext    <= ID_imm_ext;
        EX_rs1_addr   <= ID_rs1_addr;
        EX_rs2_addr   <= ID_rs2_addr;
        EX_rd_addr    <= ID_rd_addr;
        EX_funct3     <= ID_funct3;
        EX_funct7_5   <= ID_funct7_5;
    end
end

endmodule
