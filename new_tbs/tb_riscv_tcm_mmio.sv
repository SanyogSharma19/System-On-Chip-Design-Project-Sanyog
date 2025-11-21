`timescale 1ns/1ps

module tb_mmio;

  // ------------------------------------------------------------
  // Clock & resets
  // ------------------------------------------------------------
  reg clk;
  reg rst_sys;
  reg rst_cpu;

  // 100 MHz clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
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
  // AXI tie-offs (no external fabric / DMA)
  // ------------------------------------------------------------
  // Instruction AXI
  reg         axi_i_awready_i = 1'b0;
  reg         axi_i_wready_i  = 1'b0;
  reg         axi_i_bvalid_i  = 1'b0;
  reg  [1:0]  axi_i_bresp_i   = 2'b00;
  reg         axi_i_arready_i = 1'b0;
  reg         axi_i_rvalid_i  = 1'b0;
  reg  [31:0] axi_i_rdata_i   = 32'h0;
  reg  [1:0]  axi_i_rresp_i   = 2'b00;

  // TCM AXI slave
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

  reg  [31:0] intr_i          = 32'h0;

  // AXI outputs (unused)
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
  // DUT: telemetry-enabled riscv_tcm_top
  // ------------------------------------------------------------
  riscv_tcm_top #(
    .BOOT_VECTOR        (32'h0000_0000),
    .CORE_ID            (0),
    .TCM_MEM_BASE       (32'h0000_0000),
    .MEM_CACHE_ADDR_MIN (32'h0000_0000),
    .MEM_CACHE_ADDR_MAX (32'hFFFF_FFFF)
  ) dut (
    .clk_i           (clk),
    .rst_i           (rst_sys),
    .rst_cpu_i       (rst_cpu),

    .axi_i_awready_i (axi_i_awready_i),
    .axi_i_wready_i  (axi_i_wready_i),
    .axi_i_bvalid_i  (axi_i_bvalid_i),
    .axi_i_bresp_i   (axi_i_bresp_i),
    .axi_i_arready_i (axi_i_arready_i),
    .axi_i_rvalid_i  (axi_i_rvalid_i),
    .axi_i_rdata_i   (axi_i_rdata_i),
    .axi_i_rresp_i   (axi_i_rresp_i),

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

    .intr_i          (intr_i),

    .axi_i_awvalid_o (axi_i_awvalid_o),
    .axi_i_awaddr_o  (axi_i_awaddr_o),
    .axi_i_wvalid_o  (axi_i_wvalid_o),
    .axi_i_wdata_o   (axi_i_wdata_o),
    .axi_i_wstrb_o   (axi_i_wstrb_o),
    .axi_i_bready_o  (axi_i_bready_o),
    .axi_i_arvalid_o (axi_i_arvalid_o),
    .axi_i_araddr_o  (axi_i_araddr_o),
    .axi_i_rready_o  (axi_i_rready_o),

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
    .axi_t_rlast_o   (axi_t_rlast_o)
  );

  // ------------------------------------------------------------
  // Load program.hex into TCM RAM
  // ------------------------------------------------------------
  initial begin
    $display("[TB] Loading program.hex into TCM...");
    $readmemh("program.hex", dut.u_tcm.u_ram.ram);

    $display("[DBG] RAM[0] = %08x", dut.u_tcm.u_ram.ram[0]);
    $display("[DBG] RAM[1] = %08x", dut.u_tcm.u_ram.ram[1]);
    $display("[DBG] RAM[2] = %08x", dut.u_tcm.u_ram.ram[2]);
    $display("[DBG] RAM[3] = %08x", dut.u_tcm.u_ram.ram[3]);
  end

  // ------------------------------------------------------------
  // Parameters: where SW stores telemetry snapshots
  // ------------------------------------------------------------
  localparam [31:0] MCYCLE_TLM_ADDR   = 32'h0000008C;
  localparam [31:0] MINSTRET_TLM_ADDR = 32'h00000090;
  localparam [31:0] STALL_TLM_ADDR    = 32'h00000094;
  localparam [31:0] ACC_ADDR          = 32'h00000098;
  localparam [31:0] EXPECTED_ACC      = 32'd50000;
  localparam [31:0] TOLERANCE         = 32'd1000;

  // snapshot registers
  reg [31:0] mcycle_mmio;
  reg [31:0] minstret_mmio;
  reg [31:0] stall_mmio;
  reg [31:0] acc_final;

  // ------------------------------------------------------------
  // Optional: see DPORT MMIO transactions
  // ------------------------------------------------------------
  always @(posedge clk) begin
    if (dut.u_dmux.mem_ack_o) begin
      $display("[DBG] t=%0t DPORT: addr=%08x rd=%0d wr=%0d data_wr=%08x",
               $time,
               dut.u_dmux.mem_addr_i,
               dut.u_dmux.mem_rd_i,
               (dut.u_dmux.mem_wr_i != 4'b0000),
               dut.u_dmux.mem_data_wr_i);
    end
  end

  // ------------------------------------------------------------
  // Main check: compare HW counters vs MMIO snapshot in TCM
  // ------------------------------------------------------------
  initial begin
    // Wait for core reset release
    @(negedge rst_cpu);
    repeat (50) @(posedge clk);

    // Let firmware run: loop + MMIO reads + stores
    repeat (200000) @(posedge clk);

    // --- Read back telemetry snapshot from TCM ---
    mcycle_mmio   = dut.u_tcm.u_ram.ram[MCYCLE_TLM_ADDR   >> 2];
    minstret_mmio = dut.u_tcm.u_ram.ram[MINSTRET_TLM_ADDR >> 2];
    stall_mmio    = dut.u_tcm.u_ram.ram[STALL_TLM_ADDR    >> 2];
    acc_final     = dut.u_tcm.u_ram.ram[ACC_ADDR          >> 2];

    $display("========================================");
    $display(" Telemetry values captured via MMIO");
    $display("  mcycle   (MMIO) = %08x (%0d)", mcycle_mmio,   mcycle_mmio);
    $display("  minstret (MMIO) = %08x (%0d)", minstret_mmio, minstret_mmio);
    $display("  stall    (MMIO) = %08x (%0d)", stall_mmio,    stall_mmio);
    $display("  acc_final       = %08x (%0d)", acc_final,     acc_final);
    $display(" ");

    $display(" Hardware counters at end of sim");
    $display("  mcycle   = %0d (0x%016x)", dut.tlm_mcycle_w,   dut.tlm_mcycle_w);
    $display("  minstret = %0d (0x%016x)", dut.tlm_minstret_w, dut.tlm_minstret_w);
    $display("  stall    = %0d (0x%016x)", dut.tlm_stall_w,    dut.tlm_stall_w);
    $display("========================================");

    // --- Functional checks ---
    if (acc_final !== EXPECTED_ACC) begin
      $error("MMIO FAIL: acc_final (%0d) != EXPECTED_ACC (%0d)",
             acc_final, EXPECTED_ACC);
    end

    if ( (dut.tlm_mcycle_w   < mcycle_mmio)   ||
         (dut.tlm_minstret_w < minstret_mmio) ||
         (dut.tlm_stall_w    < stall_mmio) ) begin
      $error("MMIO FAIL: HW counters smaller than MMIO snapshot (impossible).");
    end

    if ( (dut.tlm_mcycle_w   - mcycle_mmio)   > TOLERANCE ||
         (dut.tlm_minstret_w - minstret_mmio) > TOLERANCE ||
         (dut.tlm_stall_w    - stall_mmio)    > TOLERANCE ) begin
      $error("MMIO FAIL: MMIO snapshot too far from HW counters.");
    end
    else begin
      $display("[TB] MMIO vs telemetry comparison PASSED");
    end

    $finish;
  end

endmodule