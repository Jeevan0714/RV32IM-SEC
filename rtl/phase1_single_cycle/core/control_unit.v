// ============================================================
// Main Control Unit
// Decodes the opcode and generates all control signals
// Author  : Jeevan
// Project : RISC-V RV32IM Processor
// ============================================================

module control_unit (
    input  wire [6:0] opcode,      // Instruction [6:0]

    // ── Datapath Control Signals ──────────────────────────────
    output reg        reg_write,   // 1 = write to register file
    output reg        mem_read,    // 1 = read from data memory
    output reg        mem_write,   // 1 = write to data memory
    output reg        mem_to_reg,  // 1 = WB data comes from memory, 0 = ALU
    output reg        alu_src,     // 1 = ALU B from immediate, 0 = from rs2
    output reg        branch,      // 1 = instruction is a branch
    output reg        jump,        // 1 = unconditional jump (JAL/JALR)
    output reg        auipc,       // 1 = AUIPC (PC + upper imm)
    output reg [1:0]  alu_op,      // ALU operation class (to alu_control)
    output reg [2:0]  imm_sel      // Immediate type selector (to imm_gen)
);

// ── RV32I Opcode Map ─────────────────────────────────────────
localparam OP_R      = 7'b0110011; // R-type (ADD, SUB, AND...)
localparam OP_I_ALU  = 7'b0010011; // I-type ALU (ADDI, ANDI...)
localparam OP_LOAD   = 7'b0000011; // Load (LW, LB, LH...)
localparam OP_STORE  = 7'b0100011; // Store (SW, SB, SH)
localparam OP_BRANCH = 7'b1100011; // Branch (BEQ, BNE, BLT...)
localparam OP_JAL    = 7'b1101111; // JAL
localparam OP_JALR   = 7'b1100111; // JALR
localparam OP_LUI    = 7'b0110111; // LUI
localparam OP_AUIPC  = 7'b0010111; // AUIPC

// Immediate type encodings — must match imm_gen.v
localparam IMM_I = 3'b000;
localparam IMM_S = 3'b001;
localparam IMM_B = 3'b010;
localparam IMM_U = 3'b011;
localparam IMM_J = 3'b100;

always @(*) begin
    // Default all signals to safe values (avoid latches)
    reg_write  = 1'b0;
    mem_read   = 1'b0;
    mem_write  = 1'b0;
    mem_to_reg = 1'b0;
    alu_src    = 1'b0;
    branch     = 1'b0;
    jump       = 1'b0;
    auipc      = 1'b0;
    alu_op     = 2'b00;
    imm_sel    = IMM_I;

    case (opcode)
        OP_R: begin
            reg_write  = 1'b1;
            alu_op     = 2'b10;    // R-type → check funct3/funct7
        end

        OP_I_ALU: begin
            reg_write  = 1'b1;
            alu_src    = 1'b1;     // Use immediate as B
            alu_op     = 2'b10;
            imm_sel    = IMM_I;
        end

        OP_LOAD: begin
            reg_write  = 1'b1;
            mem_read   = 1'b1;
            mem_to_reg = 1'b1;
            alu_src    = 1'b1;
            alu_op     = 2'b00;    // ADD for address calc
            imm_sel    = IMM_I;
        end

        OP_STORE: begin
            mem_write  = 1'b1;
            alu_src    = 1'b1;
            alu_op     = 2'b00;
            imm_sel    = IMM_S;
        end

        OP_BRANCH: begin
            branch     = 1'b1;
            alu_op     = 2'b01;    // SUB for comparison
            imm_sel    = IMM_B;
        end

        OP_JAL: begin
            reg_write  = 1'b1;
            jump       = 1'b1;
            imm_sel    = IMM_J;
        end

        OP_JALR: begin
            reg_write  = 1'b1;
            jump       = 1'b1;
            alu_src    = 1'b1;
            alu_op     = 2'b00;
            imm_sel    = IMM_I;
        end

        OP_LUI: begin
            reg_write  = 1'b1;
            alu_src    = 1'b1;
            alu_op     = 2'b11;    // Pass immediate through ALU (LUI)
            imm_sel    = IMM_U;
        end

        OP_AUIPC: begin
            reg_write  = 1'b1;
            auipc      = 1'b1;
            imm_sel    = IMM_U;
        end

        default: begin
            // All signals remain 0 (NOP behavior)
        end
    endcase
end

endmodule
