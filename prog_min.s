    .section .text.entry
    .globl _start

_start:
    li   t1, 0x80          # TCM address
    li   t2, 0x12345678    # test pattern
    sw   t2, 0(t1)         # store to 0x80
1:  j    1b                # infinite loop