// prog_tlm.S  - Telemetry demo for riscv_tcm_top
// - Reads mcycle/minstret/stall via MMIO before & after a loop
// - Stores results into TCM at 0x80..0x98

    .section .text.entry
    .globl _start

// ---------------------------------------------------------------------
// Address map
// ---------------------------------------------------------------------
// Telemetry MMIO base (matches dport_mux TELEMETRY_BASE)
#define TLM_BASE        0x80001000

// MMIO offsets (low 32 bits only)
#define TLM_MCYCLE_LO   0x00
#define TLM_MINSTRET_LO 0x08
#define TLM_STALL_LO    0x10

// TCM scratch locations (what tb_riscv_tcm_tlm.sv reads)
//   0x80: mcycle_start
//   0x84: minstret_start
//   0x88: stall_start
//   0x8C: mcycle_end
//   0x90: minstret_end
//   0x94: stall_end
//   0x98: acc_final
#define TCM_TLM_BASE    0x00000080

_start:
    // --------------------------------------------------------------
    // t0 = TLM_BASE (MMIO)
    // t1 = TCM_TLM_BASE (scratch area in TCM)
    // --------------------------------------------------------------
    li      t0, TLM_BASE
    li      t1, TCM_TLM_BASE

    // --------------------------------------------------------------
    // Read starting counters via MMIO and store to TCM
    // --------------------------------------------------------------
    // mcycle_start
    lw      t2, TLM_MCYCLE_LO(t0)
    sw      t2, 0(t1)

    // minstret_start
    lw      t2, TLM_MINSTRET_LO(t0)
    sw      t2, 4(t1)

    // stall_start
    lw      t2, TLM_STALL_LO(t0)
    sw      t2, 8(t1)

    // --------------------------------------------------------------
    // Big loop to make counters grow
    //   t3 = loop counter
    //   t4 = accumulator (final value goes to 0x98)
    // --------------------------------------------------------------
    li      t3, 50000          // loop iterations
    li      t4, 0              // acc = 0

1:  addi    t4, t4, 1          // acc++
    addi    t3, t3, -1         // cnt--
    bnez    t3, 1b             // repeat until t3 == 0

    // --------------------------------------------------------------
    // Read ending counters and store to TCM
    // --------------------------------------------------------------
    // mcycle_end
    lw      t2, TLM_MCYCLE_LO(t0)
    sw      t2, 12(t1)         // 0x8C

    // minstret_end
    lw      t2, TLM_MINSTRET_LO(t0)
    sw      t2, 16(t1)         // 0x90

    // stall_end
    lw      t2, TLM_STALL_LO(t0)
    sw      t2, 20(t1)         // 0x94

    // acc_final
    sw      t4, 24(t1)         // 0x98

    // --------------------------------------------------------------
    // Park the core in an infinite loop so TB can read everything
    // --------------------------------------------------------------
2:  j       2b                 // while(1);