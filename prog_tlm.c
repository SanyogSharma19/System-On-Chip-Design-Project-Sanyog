// prog_tlm.c – telemetry MMIO test in TCM
#include <stdint.h>

#define TCM_BASE   0x00000000u
#define TLM_BASE   0x80001000u

// TCM locations where we'll store results for the TB to read
#define OFF_MCYCLE_START    0x80
#define OFF_MINSTRET_START  0x84
#define OFF_STALL_START     0x88
#define OFF_MCYCLE_END      0x8C
#define OFF_MINSTRET_END    0x90
#define OFF_STALL_END       0x94
#define OFF_ACC_FINAL       0x98

static inline uint32_t mmio_read32(uint32_t addr)
{
    return *(volatile uint32_t *)addr;
}

static inline void tcm_write32(uint32_t addr, uint32_t value)
{
    *(volatile uint32_t *)(TCM_BASE + addr) = value;
}

// Bare-metal entry point (no libc / no main)
void _start(void) __attribute__((noreturn));

void _start(void)
{
    // --- Read performance counters at start via MMIO ---
    uint32_t mcycle_start   = mmio_read32(TLM_BASE + 0x00);
    uint32_t minstret_start = mmio_read32(TLM_BASE + 0x08);
    uint32_t stall_start    = mmio_read32(TLM_BASE + 0x10);

    tcm_write32(OFF_MCYCLE_START,   mcycle_start);
    tcm_write32(OFF_MINSTRET_START, minstret_start);
    tcm_write32(OFF_STALL_START,    stall_start);

    // --- Do a big loop so counters grow nicely ---
    volatile uint32_t acc = 0;
    for (uint32_t i = 0; i < 100000; ++i)
        acc += i;

    // --- Read performance counters at end via MMIO ---
    uint32_t mcycle_end   = mmio_read32(TLM_BASE + 0x00);
    uint32_t minstret_end = mmio_read32(TLM_BASE + 0x08);
    uint32_t stall_end    = mmio_read32(TLM_BASE + 0x10);

    tcm_write32(OFF_MCYCLE_END,   mcycle_end);
    tcm_write32(OFF_MINSTRET_END, minstret_end);
    tcm_write32(OFF_STALL_END,    stall_end);
    tcm_write32(OFF_ACC_FINAL,    acc);

    // Park CPU forever
    for (;;)
        ;
}