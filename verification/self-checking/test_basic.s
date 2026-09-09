# 🔥 test program — adds two numbers, stores result
# Assemble with: riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o test.o test.s
# Convert hex: riscv64-unknown-elf-objcopy -O verilog test.o program.hex

.section .text
.global _start

_start:
    # x10 (a0) = 5 + 7 = 12 = 0xC
    addi  x10, x0, 5       # x10 = 5
    addi  x11, x0, 7       # x11 = 7
    add   x12, x10, x11    # x12 = 12

    # Store and reload (tests LW/SW)
    addi  x5,  x0,  100    # x5  = base address 100
    sw    x12, 0(x5)        # mem[100] = 12
    lw    x13, 0(x5)        # x13 = mem[100] = 12

    # Branch test: if x12 == 12 → x10 = 1 (pass)
    addi  x14, x0, 12
    beq   x12, x14, pass
    addi  x10, x0, 0        # FAIL: x10 = 0
    j     done

pass:
    addi  x10, x0, 1        # PASS: x10 = 1

done:
    j     done              # infinite loop (halt)
