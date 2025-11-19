`timescale 1ns/1ps

module tb;

  // ------------------------------------------------------------
  // Clock & reset
  // ------------------------------------------------------------
  reg clk;
  reg rst_sys;
  reg rst_cpu;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk; // 100 MHz
  end

  initial begin
    rst_sys = 1'b1;
    rst_cpu = 1'b1;
    repeat (10) @(posedge clk);
    rst_sys = 1'b0;
    repeat (10) @(posedge clk);
    rst_cpu = 1'b0;
  end

  // ------------------------------------------------------------
  // AXI tie-offs (we are not using external memory / DMA here)
  // ------------------------------------------------------------

  // Instruction-side AXI (external fabric)
  reg         axi_i_awready_i = 1'b0;
  reg         axi_i_wready_i  = 1'b0;
  reg         axi_i_bvalid_i  = 1'b0;
  reg  [1:0]  axi_i_bresp_i   = 2'b00;
  reg         axi_i_arready_i = 1'b0;
  reg         axi_i_rvalid_i  = 1'b0;
  reg  [31:0] axi_i_rdata_i   = 32'h0;
  reg  [1:0]  axi_i_rresp_i   = 2'b00;

  // TCM AXI (external master) – not used, drive zeros
  reg         axi_t_awvalid_i = 1'b0;
  reg  [31:0] axi_t_awaddr_i  = 32'h0;
  reg  [3:0]  axi_t_awid_i    = 4'h0;
  reg  [7:0]  axi_t_awlen_i   = 8'h0;
  reg  [1:0]  axi_t_awburst_i = 2'b00;
  reg         axi_t_wvalid_i  = 1'b0;
  reg  [31:0] axi_t_wdata_i   = 32'h0;
  reg  [3:0]  axi_t_wstrb_i   = 4'h0;
  reg         axi_t_wlast_i   = 1'b0;
  reg         axi_t_bready_i  = 1'b0;
  reg         axi_t_arvalid_i = 1'b0;
  reg  [31:0] axi_t_araddr_i  = 32'h0;
  reg  [3:0]  axi_t_arid_i    = 4'h0;
  reg  [7:0]  axi_t_arlen_i   = 8'h0;
  reg  [1:0]  axi_t_arburst_i = 2'b00;
  reg         axi_t_rready_i  = 1'b0;

  // Interrupts: none for now
  reg  [31:0] intr_i = 32'h0;

  // Outputs we don't care to drive in TB
  wire        axi_i_awvalid_o;
  wire [31:0] axi_i_awaddr_o;
  wire        axi_i_wvalid_o;
  wire [31:0] axi_i_wdata_o;
  wire [3:0]  axi_i_wstrb_o;
  wire        axi_i_bready_o;
  wire        axi_i_arvalid_o;
  wire [31:0] axi_i_araddr_o;
  wire        axi_i_rready_o;

  wire        axi_t_awready_o;
  wire        axi_t_wready_o;
  wire        axi_t_bvalid_o;
  wire [1:0]  axi_t_bresp_o;
  wire [3:0]  axi_t_bid_o;
  wire        axi_t_arready_o;
  wire        axi_t_rvalid_o;
  wire [31:0] axi_t_rdata_o;
  wire [1:0]  axi_t_rresp_o;
  wire [3:0]  axi_t_rid_o;
  wire        axi_t_rlast_o;

  // ------------------------------------------------------------
  // DUT: riscv_tcm_top
  //  - force BOOT_VECTOR = 0 so PC starts at address 0x0 where
  //    we have loaded program.hex into TCM.
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

    // AXI instruction port (to external system) – tied off
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

    // AXI TCM side (external master) – tied off
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
  // Load program.hex into TCM RAM using $readmemh
  // Limit the range 0..21 so we avoid the "not enough words" warning.
  // ------------------------------------------------------------
  initial begin
    $display("[TB] Loading program.hex into TCM...");
    // u_tcm : tcm_mem
    // u_ram : tcm_mem_ram containing 'ram' array
    $readmemh("program.hex", dut.u_tcm.u_ram.ram, 0, 21);
  end

  // ------------------------------------------------------------
  // Main stimulus: run for a while, then sample TCM + counters
  // ------------------------------------------------------------
  initial begin
    // wait for CPU reset deassert
    @(negedge rst_cpu);
    // extra settle
    repeat (50) @(posedge clk);

    // Run long enough for:
    //  - program to execute MMIO reads
    //  - 1000-iteration loop
    //  - final MMIO reads and stores to TCM
    repeat (200000) @(posedge clk);

    // --------------------------------------------------------
    // Read back the software-visible results from TCM
    // Addresses:
    //   0x80: mcycle_start
    //   0x84: minstret_start
    //   0x88: stall_start
    //   0x8C: mcycle_end
    //   0x90: minstret_end
    //   0x94: stall_end
    //   0x98: acc_final (x6)
    // --------------------------------------------------------
    $display("========================================");
    $display(" Software-visible telemetry from TCM");

    $display("  mcycle_start   = %h", dut.u_tcm.u_ram.ram[32'h80 >> 2]);
    $display("  minstret_start = %h", dut.u_tcm.u_ram.ram[32'h84 >> 2]);
    $display("  stall_start    = %h", dut.u_tcm.u_ram.ram[32'h88 >> 2]);

    $display("  mcycle_end     = %h", dut.u_tcm.u_ram.ram[32'h8c >> 2]);
    $display("  minstret_end   = %h", dut.u_tcm.u_ram.ram[32'h90 >> 2]);
    $display("  stall_end      = %h", dut.u_tcm.u_ram.ram[32'h94 >> 2]);

    $display("  acc_final      = %h", dut.u_tcm.u_ram.ram[32'h98 >> 2]);
    $display(" ");

    // --------------------------------------------------------
    // Also show the raw hardware counters from riscv_core
    // --------------------------------------------------------
    $display(" Hardware counters at end of sim");
    $display("  mcycle   = %0d", dut.tlm_mcycle_w);
    $display("  minstret = %0d", dut.tlm_minstret_w);
    $display("  stall    = %0d", dut.tlm_stall_w);
    $display("========================================");

    $finish;
  end

endmodule
