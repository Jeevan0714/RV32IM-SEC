/* ==============================================================================
 * Linker Script for Spike RISC-V Golden ISA Simulation (RV32IM)
 * ============================================================================== */
OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init : { *(.text.init) }
  .text : { *(.text) }
  
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}
