// ============================================================
// ALU Control Unit
// Decodes funct3/funct7 + ALUOp from main control
// to generate 4-bit ALU control signal
// Author  : Jeevan
// Project : RISC-V RV32IM Processor
// ============================================================

module alu_control (
    input  wire [1:0] alu_op,     // From main control unit
    input  wire [2:0] funct3,     // From instruction [14:12]
    input  wire       funct7_5,   // From instruction [30] (bit 5 of funct7)
    output reg  [3:0] alu_ctrl    // To ALU
);

// ── ALUOp Encodings (from main control) ──────────────────────
// 00 → Load/Store   → always ADD
// 01 → Branch       → always SUB (for comparison)
// 10 → R-type/I-type → look at funct3/funct7

// ── ALU ctrl encodings (must match alu.v) ────────────────────
localparam ALU_ADD  = 4'b0000;
localparam ALU_SUB  = 4'b0001;
localparam ALU_AND  = 4'b0010;
localparam ALU_OR   = 4'b0011;
localparam ALU_XOR  = 4'b0100;
localparam ALU_SLL  = 4'b0101;
localparam ALU_SRL  = 4'b0110;
localparam ALU_SRA  = 4'b0111;
localparam ALU_SLT  = 4'b1000;
localparam ALU_SLTU = 4'b1001;
localparam ALU_LUI  = 4'b1010;

always @(*) begin
    case (alu_op)
        2'b00: alu_ctrl = ALU_ADD;    // Load / Store
        2'b01: alu_ctrl = ALU_SUB;    // Branch

        2'b10: begin                   // R-type or I-type ALU
            case (funct3)
                3'b000: alu_ctrl = (funct7_5) ? ALU_SUB : ALU_ADD; // ADD/SUB
                3'b001: alu_ctrl = ALU_SLL;
                3'b010: alu_ctrl = ALU_SLT;
                3'b011: alu_ctrl = ALU_SLTU;
                3'b100: alu_ctrl = ALU_XOR;
                3'b101: alu_ctrl = (funct7_5) ? ALU_SRA : ALU_SRL; // SRA/SRL
                3'b110: alu_ctrl = ALU_OR;
                3'b111: alu_ctrl = ALU_AND;
                default: alu_ctrl = ALU_ADD;
            endcase
        end

        2'b11: alu_ctrl = ALU_LUI;    // LUI — pass immediate through
        default: alu_ctrl = ALU_ADD;
    endcase
end

endmodule
