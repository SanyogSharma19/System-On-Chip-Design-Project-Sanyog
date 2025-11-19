/* link.ld - simple TCM-only linker script */

ENTRY(_start)

MEMORY
{
  TCM (rxw) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
  .text : {
      *(.text.entry)
      *(.text*)
      *(.rodata*)
  } > TCM

  .data : {
      *(.data*)
      *(.sdata*)
  } > TCM

  .bss (NOLOAD) : {
      *(.bss*)
      *(.sbss*)
      *(COMMON)
  } > TCM
}