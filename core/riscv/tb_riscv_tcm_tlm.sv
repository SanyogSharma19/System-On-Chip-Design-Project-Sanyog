`timescale 1ns/1ps

module tb;

  // ------------------------------------------------------------
  // Clock & reset
  // ------------------------------------------------------------
  logic clk;
  logic rst_sys;
  logic rst_cpu;

  // 100 MHz clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // System + core reset
  initial begin
    rst_sys = 1'b1;
    rst_cpu = 1'b1;
    repeat (10) @(posedge clk);
    rst_sys = 1'b0;
    repeat (10) @(posedge clk);
    rst_cpu = 1'b0;
  end

  // ------------------------------------------------------------
  // AXI tie-offs (no external memory / DMA in this TB)
  // ------------------------------------------------------------

  // Instruction-side AXI (external fabric)
  logic         axi_i_awready_i = 1'b0;
  logic         axi_i_wready_i  = 1'b0;
  logic         axi_i_bvalid_i  = 1'b0;
  logic [1:0]   axi_i_bresp_i   = 2'b00;
  logic         axi_i_arready_i = 1'b0;
  logic         axi_i_rvalid_i  = 1'b0;
  logic [31:0]  axi_i_rdata_i   = 32'h0;
  logic [1:0]   axi_i_rresp_i   = 2'b00;

  // TCM AXI (external master) – unused, tie low
  logic         axi_t_awvalid_i = 1'b0;
  logic [31:0]  axi_t_awaddr_i  = 32'h0;
  logic [3:0]   axi_t_awid_i    = 4'h0;
  logic [7:0]   axi_t_awlen_i   = 8'h0;
  logic [1:0]   axi_t_awburst_i = 2'b00;
  logic         axi_t_wvalid_i  = 1'b0;
  logic [31:0]  axi_t_wdata_i   = 32'h0;
  logic [3:0]   axi_t_wstrb_i   = 4'h0;
  logic         axi_t_wlast_i   = 1'b0;
  logic         axi_t_bready_i  = 1'b0;
  logic         axi_t_arvalid_i = 1'b0;
  logic [31:0]  axi_t_araddr_i  = 32'h0;
  logic [3:0]   axi_t_arid_i    = 4'h0;
  logic [7:0]   axi_t_arlen_i   = 8'h0;
  logic [1:0]   axi_t_arburst_i = 2'b00;
  logic         axi_t_rready_i  = 1'b0;

  // No interrupts in this TB
  logic [31:0]  intr_i          = 32'h0;

  // AXI outputs (we just declare wires; TB doesn’t use them)
  wire          axi_i_awvalid_o;
  wire [31:0]   axi_i_awaddr_o;
  wire          axi_i_wvalid_o;
  wire [31:0]   axi_i_wdata_o;
  wire [3:0]    axi_i_wstrb_o;
  wire          axi_i_bready_o;
  wire          axi_i_arvalid_o;
  wire [31:0]   axi_i_araddr_o;
  wire          axi_i_rready_o;

  wire          axi_t_awready_o;
  wire          axi_t_wready_o;
  wire          axi_t_bvalid_o;
  wire [1:0]    axi_t_bresp_o;
  wire [3:0]    axi_t_bid_o;
  wire          axi_t_arready_o;
  wire          axi_t_rvalid_o;
  wire [31:0]   axi_t_rdata_o;
  wire [1:0]    axi_t_rresp_o;
  wire [3:0]    axi_t_rid_o;
  wire          axi_t_rlast_o;

  // ------------------------------------------------------------
  // DUT: riscv_tcm_top
  //  BOOT_VECTOR = 0 so PC starts at 0x0000_0000 in TCM
  // ------------------------------------------------------------
  riscv_tcm_top #(
    .BOOT_VECTOR        (32'h0000_0000),
    .CORE_ID            (0),
    .TCM_MEM_BASE       (32'h0000_0000),
    .MEM_CACHE_ADDR_MIN (32'h0000_0000),
    .MEM_CACHE_ADDR_MAX (32'hffff_ffff)
  ) dut (
    .clk_i           (clk),
    .rst_i           (rst_sys),
    .rst_cpu_i       (rst_cpu),

    // AXI instruction port (unused in TB)
    .axi_i_awready_i (axi_i_awready_i),
    .axi_i_wready_i  (axi_i_wready_i),
    .axi_i_bvalid_i  (axi_i_bvalid_i),
    .axi_i_bresp_i   (axi_i_bresp_i),
    .axi_i_arready_i (axi_i_arready_i),
    .axi_i_rvalid_i  (axi_i_rvalid_i),
    .axi_i_rdata_i   (axi_i_rdata_i),
    .axi_i_rresp_i   (axi_i_rresp_i),

    .axi_i_awvalid_o (axi_i_awvalid_o),
    .axi_i_awaddr_o  (axi_i_awaddr_o),
    .axi_i_wvalid_o  (axi_i_wvalid_o),
    .axi_i_wdata_o   (axi_i_wdata_o),
    .axi_i_wstrb_o   (axi_i_wstrb_o),
    .axi_i_bready_o  (axi_i_bready_o),
    .axi_i_arvalid_o (axi_i_arvalid_o),
    .axi_i_araddr_o  (axi_i_araddr_o),
    .axi_i_rready_o  (axi_i_rready_o),

    // AXI TCM side (unused)
    .axi_t_awvalid_i (axi_t_awvalid_i),
    .axi_t_awaddr_i  (axi_t_awaddr_i),
    .axi_t_awid_i    (axi_t_awid_i),
    .axi_t_awlen_i   (axi_t_awlen_i),
    .axi_t_awburst_i (axi_t_awburst_i),
    .axi_t_wvalid_i  (axi_t_wvalid_i),
    .axi_t_wdata_i   (axi_t_wdata_i),
    .axi_t_wstrb_i   (axi_t_wstrb_i),
    .axi_t_wlast_i   (axi_t_wlast_i),
    .axi_t_bready_i  (axi_t_bready_i),
    .axi_t_arvalid_i (axi_t_arvalid_i),
    .axi_t_araddr_i  (axi_t_araddr_i),
    .axi_t_arid_i    (axi_t_arid_i),
    .axi_t_arlen_i   (axi_t_arlen_i),
    .axi_t_arburst_i (axi_t_arburst_i),
    .axi_t_rready_i  (axi_t_rready_i),

    .axi_t_awready_o (axi_t_awready_o),
    .axi_t_wready_o  (axi_t_wready_o),
    .axi_t_bvalid_o  (axi_t_bvalid_o),
    .axi_t_bresp_o   (axi_t_bresp_o),
    .axi_t_bid_o     (axi_t_bid_o),
    .axi_t_arready_o (axi_t_arready_o),
    .axi_t_rvalid_o  (axi_t_rvalid_o),
    .axi_t_rdata_o   (axi_t_rdata_o),
    .axi_t_rresp_o   (axi_t_rresp_o),
    .axi_t_rid_o     (axi_t_rid_o),
    .axi_t_rlast_o   (axi_t_rlast_o),

    // Interrupts
    .intr_i          (intr_i)
  );

  // ------------------------------------------------------------
  // Load program.hex into TCM RAM
  // ------------------------------------------------------------
  initial begin
    $display("[TB] Loading program.hex into TCM...");
    // Load entire RAM; warning about "not enough words" is harmless
    $readmemh("program.hex", dut.u_tcm.u_ram.ram);

    // Show first few words so we know it matches the assembled program
    $display("[DBG] RAM[0] = %08x", dut.u_tcm.u_ram.ram[0]);
    $display("[DBG] RAM[1] = %08x", dut.u_tcm.u_ram.ram[1]);
    $display("[DBG] RAM[2] = %08x", dut.u_tcm.u_ram.ram[2]);
    $display("[DBG] RAM[3] = %08x", dut.u_tcm.u_ram.ram[3]);
  end

  // ------------------------------------------------------------
  // Debug: first fetch + DPORT traffic (MMIO + data writes)
  // ------------------------------------------------------------
  logic seen_first_fetch = 1'b0;

  // riscv_tcm_top wires: ifetch_valid_w / ifetch_pc_w
  always @(posedge clk) begin
    if (!seen_first_fetch && dut.ifetch_valid_w) begin
      seen_first_fetch <= 1'b1;
      $display("[DBG] Time %0t: first fetch at PC=%08x",
               $time, dut.ifetch_pc_w);
    end
  end

  // Monitor data-port accesses (through dport_mux)
  always @(posedge clk) begin
    if (dut.u_dmux.mem_ack_o) begin
      $display("[DBG] t=%0t DPORT: addr=%08x rd=%0d wr=%0d data_wr=%08x",
               $time,
               dut.u_dmux.mem_addr_i,
               dut.u_dmux.mem_rd_i,
               (dut.u_dmux.mem_wr_i != 4'b0),
               dut.u_dmux.mem_data_wr_i);
    end
  end

  // ------------------------------------------------------------
  // Main stimulus: run, then dump SW-visible + HW-visible counters
  // ------------------------------------------------------------
  initial begin
    // wait for CPU reset to deassert
    @(negedge rst_cpu);
    repeat (50) @(posedge clk);

    // Run long enough for:
    //  - program to do MMIO reads before/after loop
    //  - loop to complete
    //  - final stores into TCM at 0x80..0x98
    repeat (800000) @(posedge clk);

    // Read back software-visible results from TCM
    // (each is 32-bit word addressed by byte_addr >> 2)
    $display("========================================");
    $display(" Software-visible telemetry from TCM");

    $display("  mcycle_start   = %08x", dut.u_tcm.u_ram.ram[32'h80 >> 2]);
    $display("  minstret_start = %08x", dut.u_tcm.u_ram.ram[32'h84 >> 2]);
    $display("  stall_start    = %08x", dut.u_tcm.u_ram.ram[32'h88 >> 2]);
    $display("  mcycle_end     = %08x", dut.u_tcm.u_ram.ram[32'h8c >> 2]);
    $display("  minstret_end   = %08x", dut.u_tcm.u_ram.ram[32'h90 >> 2]);
    $display("  stall_end      = %08x", dut.u_tcm.u_ram.ram[32'h94 >> 2]);
    $display("  acc_final      = %08x", dut.u_tcm.u_ram.ram[32'h98 >> 2]);
    $display(" ");

    // Raw hardware counters from riscv_core (telemetry_counters)
    $display(" Hardware counters at end of sim");
    $display("  mcycle   = %0d", dut.tlm_mcycle_w);
    $display("  minstret = %0d", dut.tlm_minstret_w);
    $display("  stall    = %0d", dut.tlm_stall_w);
    $display("========================================");

    $finish;
  end

endmodule