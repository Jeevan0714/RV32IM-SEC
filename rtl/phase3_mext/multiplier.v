// ============================================================
// Hardware Multiplier (Iterative Shift-and-Add)
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 3
// ============================================================

module multiplier (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [2:0]  funct3,
    output reg  [31:0] result,
    output reg         ready
);

    // States
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE    = 2'b10;

    reg [1:0]  state;
    reg [5:0]  count;
    
    reg [63:0] mcand;
    reg [31:0] mpler;
    reg [63:0] prod;
    
    reg        is_signed_rs1;
    reg        is_signed_rs2;
    reg        rs1_neg;
    reg        rs2_neg;
    reg        result_neg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= IDLE;
            ready  <= 1'b0;
            result <= 32'b0;
            count  <= 6'b0;
            mcand  <= 64'b0;
            mpler  <= 32'b0;
            prod   <= 64'b0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        state <= COMPUTE;
                        count <= 32;
                        prod  <= 64'b0;
                        
                        // Determine signedness based on funct3
                        // 000: MUL    (signed x signed or unsign x unsign - lower 32 doesn't matter)
                        // 001: MULH   (signed x signed)
                        // 010: MULHSU (signed x unsigned)
                        // 011: MULHU  (unsigned x unsigned)
                        is_signed_rs1 = (funct3 == 3'b001) || (funct3 == 3'b010) || (funct3 == 3'b000);
                        is_signed_rs2 = (funct3 == 3'b001) || (funct3 == 3'b000);
                        
                        rs1_neg = is_signed_rs1 && rs1[31];
                        rs2_neg = is_signed_rs2 && rs2[31];
                        result_neg = rs1_neg ^ rs2_neg;
                        
                        mcand <= rs1_neg ? {32'b0, -rs1} : {32'b0, rs1};
                        mpler <= rs2_neg ? -rs2 : rs2;
                    end
                end
                
                COMPUTE: begin
                    if (count > 0) begin
                        if (mpler[0]) begin
                            prod <= prod + mcand;
                        end
                        mcand <= mcand << 1;
                        mpler <= mpler >> 1;
                        count <= count - 1;
                    end else begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    ready <= 1'b1;
                    state <= IDLE;
                    
                    // Final result formatting
                    if (funct3 == 3'b000) begin
                        // MUL: lower 32 bits
                        result <= result_neg ? -prod[31:0] : prod[31:0];
                    end else begin
                        // MULH, MULHSU, MULHU: upper 32 bits
                        // Note: If result is negative, we negate the full 64-bit product and take upper 32
                        if (result_neg) begin
                            result <= (~prod + 1'b1) >> 32;
                        end else begin
                            result <= prod[63:32];
                        end
                    end
                end
            endcase
        end
    end

endmodule
