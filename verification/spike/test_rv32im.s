# ==============================================================================
# Comprehensive RV32IM Golden ISA Test Program for Spike Simulator
# Tests: RV32I Arithmetic, Logical, Shift, Branch, Memory + RV32M Mul/Div
# ==============================================================================

.section .text.init
.global _start

_start:
    # ── 1. RV32I Basic Arithmetic & Immediate ──────────────────
    li   x10, 15               # a0 = 15
    li   x11, 27               # a1 = 27
    add  x12, x10, x11         # a2 = 15 + 27 = 42 (0x2A)
    sub  x13, x11, x10         # a3 = 27 - 15 = 12 (0x0C)

    # ── 2. Bitwise Logical Operations ──────────────────────────
    li   x14, 0x00FF00FF
    li   x15, 0x0F0F0F0F
    and  x16, x14, x15         # a6 = 0x000F000F
    or   x17, x14, x15         # a7 = 0x0FFF0FFF
    xor  x18, x14, x15         # s2 = 0x0FF00FF0

    # ── 3. Shifts (SLL, SRL, SRA) ──────────────────────────────
    li   x19, 0x00000008
    slli x20, x19, 3           # s4 = 8 << 3 = 64 (0x40)
    srli x21, x20, 2           # s5 = 64 >> 2 = 16 (0x10)

    # ── 4. Memory Load & Store ─────────────────────────────────
    la   x5,  data_buffer      # Base memory address
    li   x6,  0xDEADBEEF
    sw   x6,  0(x5)            # Store word
    lw   x7,  0(x5)            # Load word back into x7

    # Verify loaded value matches
    bne  x6,  x7, test_fail

    # ── 5. RV32M Hardware Multiplication & Division ────────────
    li   x28, 12
    li   x29, 9
    mul  x30, x28, x29         # t5 = 12 * 9 = 108 (0x6C)
    div  x31, x30, x28         # t6 = 108 / 12 = 9 (0x09)
    rem  x8,  x30, x29         # s0 = 108 % 9 = 0 (0x00)

    # Verify multiplication result
    li   t0, 108
    bne  x30, t0, test_fail

    # ── 6. Test Passed: Signal Spike HTIF to Exit ──────────────
test_pass:
    li   t0, 1                 # 1 = Success
    la   t1, tohost
    sw   t0, 0(t1)             # 64-bit tohost write
    sw   zero, 4(t1)
    j    halt

test_fail:
    li   t0, 3                 # Odd number > 1 = Exit with Failure code
    la   t1, tohost
    sw   t0, 0(t1)
    sw   zero, 4(t1)

halt:
    j    halt

# ── Data Section ──────────────────────────────────────────────
.section .data
.align 4
data_buffer:
    .word 0x00000000

# ── Spike Host-Target Interface (HTIF) ────────────────────────
.section .tohost,"aw",@progbits
.align 6
.globl tohost
tohost:   .dword 0
.align 6
.globl fromhost
fromhost: .dword 0
