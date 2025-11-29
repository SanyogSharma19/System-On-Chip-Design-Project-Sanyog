`timescale 1ns/1ps

module tb_mmio;

  // ------------------------------------------------------------
  // Clock & reset new tbesh gnsh pls
  // ------------------------------------------------------------
  reg clk;
  reg rst_sys;
  reg rst_cpu;

  localparam TRACE_DEPTH    = 64;
  localparam TRACE_PTR_BITS = $clog2(TRACE_DEPTH); // 6

  // 100 MHz clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // ------------------------------------------------------------
  // AXI tie-offs
  // ------------------------------------------------------------
  // Instruction AXI (external)
  reg         axi_i_awready_i = 1'b0;
  reg         axi_i_wready_i  = 1'b0;
  reg         axi_i_bvalid_i  = 1'b0;
  reg  [1:0]  axi_i_bresp_i   = 2'b00;
  reg         axi_i_arready_i = 1'b0;
  reg         axi_i_rvalid_i  = 1'b0;
  reg  [31:0] axi_i_rdata_i   = 32'h0;
  reg  [1:0]  axi_i_rresp_i   = 2'b00;

  // TCM AXI slave (from external fabric) – left idle
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

  // AXI outputs (ignored)
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
  // Trace buffer ports from top
  // ------------------------------------------------------------
  wire                      trace_triggered;
  wire [TRACE_PTR_BITS-1:0] trace_wr_ptr;
  reg  [TRACE_PTR_BITS-1:0] trace_rd_addr;
  wire [63:0]               trace_rd_data;

  // ------------------------------------------------------------
  // DUT
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
    .axi_t_rlast_o   (axi_t_rlast_o),

    .trace_triggered_o (trace_triggered),
    .trace_wr_ptr_o    (trace_wr_ptr),
    .trace_rd_addr_i   (trace_rd_addr),
    .trace_rd_data_o   (trace_rd_data)
  );

  // ------------------------------------------------------------
  // Reset + memory preload + FULL trace dump
  // ------------------------------------------------------------
  initial begin
    rst_sys       = 1'b1;
    rst_cpu       = 1'b1;
    trace_rd_addr = '0;

    // Preload ITCM via TSMC macro task.
    // Hierarchy you already used successfully:
    //   tb_mmio.dut.u_tcm.u_itcm.g_sram[0].u_sram.preloadData(...)
    #1;
    dut.u_tcm.u_itcm.g_sram[0].u_sram.preloadData(
      "/home/ss18852/System-On-Chip-Design-Project-Sanyog/program.hex"
    );

    // Release resets after a few cycles
    repeat (10) @(posedge clk);
    rst_sys = 1'b0;
    repeat (10) @(posedge clk);
    rst_cpu = 1'b0;

    // Let core run for some cycles
    repeat (200000) @(posedge clk);

    // Print trace buffer status
    $display("========================================");
    $display("[TB] Trace buffer status after 200000 cycles:");
    $display("  triggered = %0d", trace_triggered);
    $display("  wr_ptr    = %0d", trace_wr_ptr);
    $display("========================================");

    // --- ALWAYS dump the full TRACE_DEPTH entries ---
    begin
      integer i;
      $display("[TB] Dumping all %0d entries from trace buffer...", TRACE_DEPTH);

      for (i = 0; i < TRACE_DEPTH; i = i + 1) begin
        trace_rd_addr = i[TRACE_PTR_BITS-1:0];
        @(posedge clk); // synchronous read
        $display("TRACE[%0d]: PC=0x%08x  INSTR=0x%08x",
                 i,
                 trace_rd_data[63:32],
                 trace_rd_data[31:0]);
      end
    end

    $finish;
  end

  // Wave dump
  initial begin
    $dumpfile("tb_mmio_trace.vcd");
    $dumpvars(0, tb_mmio);
  end

endmodule