// prog_tlm.c - exercise telemetry counters via MMIO and dump to TCM

#define TLM_BASE      0x80001000u
#define MCYCLE_LO     (*(volatile unsigned int *)(TLM_BASE + 0x00))
#define MINSTRET_LO   (*(volatile unsigned int *)(TLM_BASE + 0x08))
#define STALL_LO      (*(volatile unsigned int *)(TLM_BASE + 0x10))

// TCM dump address (must match what TB reads: 0x80)
#define DUMP_BASE     ((volatile unsigned int *)0x00000080u)

int main(void)
{
    volatile unsigned int *dump = DUMP_BASE;

    // 1) Read counters at start
    unsigned mcycle_start   = MCYCLE_LO;
    unsigned minstret_start = MINSTRET_LO;
    unsigned stall_start    = STALL_LO;

    // 2) "Do work" - big loop so counters grow a lot
    volatile unsigned acc = 0;
    for (unsigned i = 0; i < 100000; ++i) {
        acc += i ^ (i << 1);
    }

    // 3) Read counters at end
    unsigned mcycle_end   = MCYCLE_LO;
    unsigned minstret_end = MINSTRET_LO;
    unsigned stall_end    = STALL_LO;

    // 4) Dump into TCM so testbench can inspect
    dump[0] = mcycle_start;
    dump[1] = mcycle_end;
    dump[2] = minstret_start;
    dump[3] = minstret_end;
    dump[4] = stall_start;
    dump[5] = stall_end;
    dump[6] = acc;   // optional: some computed value

    // 5) Spin forever
    while (1) { }

    return 0;
}

// Simple entry point placed at start of .text
__attribute__((section(".text.entry")))
void _start(void)
{
    (void)main();
    while (1) { }
}
