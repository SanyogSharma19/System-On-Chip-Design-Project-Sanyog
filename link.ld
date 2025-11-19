ENTRY(_start)

MEMORY
{
  TCM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
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

  .bss : {
    *(.bss*)
    *(.sbss*)
    *(COMMON)
  } > TCM
}
