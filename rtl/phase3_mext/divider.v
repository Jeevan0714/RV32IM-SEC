// ============================================================
// Hardware Divider (Iterative Restoring Division)
// Author  : Jeevan
// Project : RISC-V RV32IM Processor — Phase 3
// ============================================================

module divider (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] dividend,
    input  wire [31:0] divisor,
    input  wire [2:0]  funct3,
    output reg  [31:0] result,
    output reg         ready
);

    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE    = 2'b10;

    reg [1:0]  state;
    reg [5:0]  count;
    
    reg [63:0] A;       // Holds remainder in upper 32, quotient in lower 32
    reg [31:0] D;       // Divisor
    
    reg        is_signed;
    reg        N_neg;
    reg        D_neg;
    reg        Q_neg;
    reg        R_neg;
    reg        div_by_zero;
    reg        overflow;

    wire [32:0] sub_res = A[63:31] - {1'b0, D};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= IDLE;
            ready  <= 1'b0;
            result <= 32'b0;
            count  <= 6'b0;
            A      <= 64'b0;
            D      <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        state <= COMPUTE;
                        count <= 32;
                        
                        // funct3:
                        // 100: DIV  (signed Q)
                        // 101: DIVU (unsigned Q)
                        // 110: REM  (signed R)
                        // 111: REMU (unsigned R)
                        is_signed = (funct3 == 3'b100) || (funct3 == 3'b110);
                        
                        N_neg = is_signed && dividend[31];
                        D_neg = is_signed && divisor[31];
                        Q_neg = N_neg ^ D_neg;
                        R_neg = N_neg;
                        
                        div_by_zero = (divisor == 32'b0);
                        overflow    = is_signed && (dividend == 32'h8000_0000) && (divisor == 32'hFFFF_FFFF);
                        
                        A[31:0] <= N_neg ? -dividend : dividend;
                        A[63:32]<= 32'b0;
                        D       <= D_neg ? -divisor : divisor;
                        
                        if (div_by_zero || overflow) begin
                            // Fast path for exceptions
                            state <= DONE;
                            count <= 0;
                        end
                    end
                end
                
                COMPUTE: begin
                    if (count > 0) begin
                        // Shift and subtract
                        // Equivalent to A = A << 1; if (A[63:32] >= D) ...
                        if (!sub_res[32]) begin
                            // sub_res >= 0 (meaning A[63:31] >= D)
                            A[63:32] <= sub_res[31:0];
                            A[31:1]  <= A[30:0];
                            A[0]     <= 1'b1;
                        end else begin
                            A <= A << 1;
                        end
                        count <= count - 1;
                    end else begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    ready <= 1'b1;
                    state <= IDLE;
                    
                    if (div_by_zero) begin
                        if (funct3 == 3'b100 || funct3 == 3'b101) result <= 32'hFFFF_FFFF; // DIV, DIVU -> -1
                        else result <= dividend; // REM, REMU -> dividend
                    end else if (overflow) begin
                        if (funct3 == 3'b100) result <= 32'h8000_0000; // DIV -> -2^31
                        else result <= 32'b0; // REM -> 0
                    end else begin
                        if (funct3 == 3'b100 || funct3 == 3'b101) begin
                            // Quotient
                            result <= Q_neg ? -A[31:0] : A[31:0];
                        end else begin
                            // Remainder
                            result <= R_neg ? -A[63:32] : A[63:32];
                        end
                    end
                end
            endcase
        end
    end

endmodule
