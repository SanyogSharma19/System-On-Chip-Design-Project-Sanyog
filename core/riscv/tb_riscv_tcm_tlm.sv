`timescale 1ns/1ps

module tb;

  // Clock + reset
  reg clk;
  reg rst;
  reg rst_cpu;

  // AXI to external memory (unused in this test, tie off)
  reg         axi_i_awready_i;
  reg         axi_i_wready_i;
  reg         axi_i_bvalid_i;
  reg  [1:0]  axi_i_bresp_i;
  reg         axi_i_arready_i;
  reg         axi_i_rvalid_i;
  reg  [31:0] axi_i_rdata_i;
  reg  [1:0]  axi_i_rresp_i;

  // AXI target side (TCM external port) inputs
  reg         axi_t_awvalid_i;
  reg  [31:0] axi_t_awaddr_i;
  reg  [3:0]  axi_t_awid_i;
  reg  [7:0]  axi_t_awlen_i;
  reg  [1:0]  axi_t_awburst_i;
  reg         axi_t_wvalid_i;
  reg  [31:0] axi_t_wdata_i;
  reg  [3:0]  axi_t_wstrb_i;
  reg         axi_t_wlast_i;
  reg         axi_t_bready_i;
  reg         axi_t_arvalid_i;
  reg  [31:0] axi_t_araddr_i;
  reg  [3:0]  axi_t_arid_i;
  reg  [7:0]  axi_t_arlen_i;
  reg  [1:0]  axi_t_arburst_i;
  reg         axi_t_rready_i;

  // Interrupts
  reg  [31:0] intr_i;

  // AXI outputs (ignored in TB, but need wires)
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

  // DUT
  riscv_tcm_top #(
    .BOOT_VECTOR(32'h0000_0000),
    .CORE_ID(0),
    .TCM_MEM_BASE(0),
    .MEM_CACHE_ADDR_MIN(32'h0000_0000),
    .MEM_CACHE_ADDR_MAX(32'hFFFF_FFFF)
  ) dut (
    .clk_i           (clk),
    .rst_i           (rst),
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

  // Clock generation: 100 MHz
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk; // 10 ns period
  end

  // Initial conditions + program load
  localparam int DUMP_IDX = 32; // 0x80 / 4

  initial begin
    // AXI fabric idle
    axi_i_awready_i = 1'b0;
    axi_i_wready_i  = 1'b0;
    axi_i_bvalid_i  = 1'b0;
    axi_i_bresp_i   = 2'b00;
    axi_i_arready_i = 1'b0;
    axi_i_rvalid_i  = 1'b0;
    axi_i_rdata_i   = 32'b0;
    axi_i_rresp_i   = 2'b00;

    axi_t_awvalid_i = 1'b0;
    axi_t_awaddr_i  = 32'b0;
    axi_t_awid_i    = 4'b0;
    axi_t_awlen_i   = 8'b0;
    axi_t_awburst_i = 2'b01;
    axi_t_wvalid_i  = 1'b0;
    axi_t_wdata_i   = 32'b0;
    axi_t_wstrb_i   = 4'b0;
    axi_t_wlast_i   = 1'b0;
    axi_t_bready_i  = 1'b1;
    axi_t_arvalid_i = 1'b0;
    axi_t_araddr_i  = 32'b0;
    axi_t_arid_i    = 4'b0;
    axi_t_arlen_i   = 8'b0;
    axi_t_arburst_i = 2'b01;
    axi_t_rready_i  = 1'b1;

    intr_i          = 32'b0;

    rst      = 1'b1;
    rst_cpu  = 1'b1;

    // Load program into TCM
    $display("[TB] Loading program.hex into TCM...");
    $readmemh("program.hex", dut.u_tcm.u_ram.ram);

    // Hold reset for a few cycles
    repeat (10) @(posedge clk);
    rst     = 1'b0;
    rst_cpu = 1'b0;

    // Let the core run for a while (enough for loop + MMIO reads)
    repeat (200000) @(posedge clk);

    $display("========================================");
    $display(" Software-visible telemetry from TCM");
    $display("  mcycle_start   = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 0]);
    $display("  mcycle_end     = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 1]);
    $display("  minstret_start = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 2]);
    $display("  minstret_end   = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 3]);
    $display("  stall_start    = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 4]);
    $display("  stall_end      = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 5]);
    $display("  acc_final      = %0d", dut.u_tcm.u_ram.ram[DUMP_IDX + 6]);

    $display(" ");
    $display(" Hardware counters at end of sim");
    $display("  mcycle   = %0d", dut.tlm_mcycle_w);
    $display("  minstret = %0d", dut.tlm_minstret_w);
    $display("  stall    = %0d", dut.tlm_stall_w);
    $display("========================================");

    $finish;
  end

endmodule
