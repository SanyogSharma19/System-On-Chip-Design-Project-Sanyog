`timescale 1ns/1ps

module tb_mmio;

    // -----------------------------------------
    // Clock & reset new honda si
    // -----------------------------------------
    reg clk_i;
    reg rst_i;
    reg rst_cpu_i;

    // -----------------------------------------
    // AXI-Lite master (CPU -> peripherals) - axi_i_*
    // -----------------------------------------
    wire          axi_i_awvalid_o;
    wire [31:0]   axi_i_awaddr_o;
    wire          axi_i_wvalid_o;
    wire [31:0]   axi_i_wdata_o;
    wire [3:0]    axi_i_wstrb_o;
    wire          axi_i_bready_o;
    wire          axi_i_arvalid_o;
    wire [31:0]   axi_i_araddr_o;
    wire          axi_i_rready_o;

    reg           axi_i_awready_i;
    reg           axi_i_wready_i;
    reg           axi_i_bvalid_i;
    reg [1:0]     axi_i_bresp_i;
    reg           axi_i_arready_i;
    reg           axi_i_rvalid_i;
    reg [31:0]    axi_i_rdata_i;
    reg [1:0]     axi_i_rresp_i;

    // -----------------------------------------
    // AXI4 slave (host -> TCM) - axi_t_*
    // For this TB we don't drive bursts; we just keep it idle.
    // TCM itself will do the $readmemh of program.hex.
    // -----------------------------------------
    reg           axi_t_awvalid_i;
    reg [31:0]    axi_t_awaddr_i;
    reg [3:0]     axi_t_awid_i;
    reg [7:0]     axi_t_awlen_i;
    reg [1:0]     axi_t_awburst_i;
    reg           axi_t_wvalid_i;
    reg [31:0]    axi_t_wdata_i;
    reg [3:0]     axi_t_wstrb_i;
    reg           axi_t_wlast_i;
    reg           axi_t_bready_i;
    reg           axi_t_arvalid_i;
    reg [31:0]    axi_t_araddr_i;
    reg [3:0]     axi_t_arid_i;
    reg [7:0]     axi_t_arlen_i;
    reg [1:0]     axi_t_arburst_i;
    reg           axi_t_rready_i;

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

    // -----------------------------------------
    // Interrupt
    // -----------------------------------------
    reg  [31:0]   intr_i;

    // -----------------------------------------
    // Trace buffer ports
    // -----------------------------------------
    wire          trace_triggered_o;
    wire [5:0]    trace_wr_ptr_o;
    reg  [5:0]    trace_rd_addr_i;
    wire [63:0]   trace_rd_data_o;

    integer idx;

    // -----------------------------------------
    // DUT: RISC-V core + TCM top
    // -----------------------------------------
    riscv_tcm_top #(
        .BOOT_VECTOR        (32'h0000_0000),
        .CORE_ID            (0),
        .TCM_MEM_BASE       (32'h0000_0000),
        .MEM_CACHE_ADDR_MIN (32'h8000_0000),
        .MEM_CACHE_ADDR_MAX (32'hFFFF_FFFF)
    ) dut (
        // Clocks / resets
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .rst_cpu_i      (rst_cpu_i),

        // AXI-Lite master (CPU -> peripherals)
        .axi_i_awready_i(axi_i_awready_i),
        .axi_i_wready_i (axi_i_wready_i),
        .axi_i_bvalid_i (axi_i_bvalid_i),
        .axi_i_bresp_i  (axi_i_bresp_i),
        .axi_i_arready_i(axi_i_arready_i),
        .axi_i_rvalid_i (axi_i_rvalid_i),
        .axi_i_rdata_i  (axi_i_rdata_i),
        .axi_i_rresp_i  (axi_i_rresp_i),

        .axi_i_awvalid_o(axi_i_awvalid_o),
        .axi_i_awaddr_o (axi_i_awaddr_o),
        .axi_i_wvalid_o (axi_i_wvalid_o),
        .axi_i_wdata_o  (axi_i_wdata_o),
        .axi_i_wstrb_o  (axi_i_wstrb_o),
        .axi_i_bready_o (axi_i_bready_o),
        .axi_i_arvalid_o(axi_i_arvalid_o),
        .axi_i_araddr_o (axi_i_araddr_o),
        .axi_i_rready_o (axi_i_rready_o),

        // AXI4 slave (host -> TCM)
        .axi_t_awvalid_i(axi_t_awvalid_i),
        .axi_t_awaddr_i (axi_t_awaddr_i),
        .axi_t_awid_i   (axi_t_awid_i),
        .axi_t_awlen_i  (axi_t_awlen_i),
        .axi_t_awburst_i(axi_t_awburst_i),
        .axi_t_wvalid_i (axi_t_wvalid_i),
        .axi_t_wdata_i  (axi_t_wdata_i),
        .axi_t_wstrb_i  (axi_t_wstrb_i),
        .axi_t_wlast_i  (axi_t_wlast_i),
        .axi_t_bready_i (axi_t_bready_i),
        .axi_t_arvalid_i(axi_t_arvalid_i),
        .axi_t_araddr_i (axi_t_araddr_i),
        .axi_t_arid_i   (axi_t_arid_i),
        .axi_t_arlen_i  (axi_t_arlen_i),
        .axi_t_arburst_i(axi_t_arburst_i),
        .axi_t_rready_i (axi_t_rready_i),

        .axi_t_awready_o(axi_t_awready_o),
        .axi_t_wready_o (axi_t_wready_o),
        .axi_t_bvalid_o (axi_t_bvalid_o),
        .axi_t_bresp_o  (axi_t_bresp_o),
        .axi_t_bid_o    (axi_t_bid_o),
        .axi_t_arready_o(axi_t_arready_o),
        .axi_t_rvalid_o (axi_t_rvalid_o),
        .axi_t_rdata_o  (axi_t_rdata_o),
        .axi_t_rresp_o  (axi_t_rresp_o),
        .axi_t_rid_o    (axi_t_rid_o),
        .axi_t_rlast_o  (axi_t_rlast_o),

        // Interrupt
        .intr_i         (intr_i),

        // Trace buffer
        .trace_triggered_o (trace_triggered_o),
        .trace_wr_ptr_o    (trace_wr_ptr_o),
        .trace_rd_addr_i   (trace_rd_addr_i),
        .trace_rd_data_o   (trace_rd_data_o)
    );

    // -----------------------------------------
    // Clock generation: 100 MHz
    // -----------------------------------------
    initial begin
        clk_i = 1'b0;
        forever #5 clk_i = ~clk_i;
    end

    // -----------------------------------------
    // TB stimulus
    // -----------------------------------------
    initial begin
        // Defaults
        rst_i      = 1'b1;
        rst_cpu_i  = 1'b1;
        intr_i     = 32'd0;

        // AXI-lite side: always ready, never responding with errors
        axi_i_awready_i = 1'b1;
        axi_i_wready_i  = 1'b1;
        axi_i_bvalid_i  = 1'b0;
        axi_i_bresp_i   = 2'b00;
        axi_i_arready_i = 1'b1;
        axi_i_rvalid_i  = 1'b0;
        axi_i_rdata_i   = 32'd0;
        axi_i_rresp_i   = 2'b00;

        // AXI TCM host side: idle
        axi_t_awvalid_i = 1'b0;
        axi_t_awaddr_i  = 32'd0;
        axi_t_awid_i    = 4'd0;
        axi_t_awlen_i   = 8'd0;
        axi_t_awburst_i = 2'd0;
        axi_t_wvalid_i  = 1'b0;
        axi_t_wdata_i   = 32'd0;
        axi_t_wstrb_i   = 4'd0;
        axi_t_wlast_i   = 1'b0;
        axi_t_bready_i  = 1'b1;
        axi_t_arvalid_i = 1'b0;
        axi_t_araddr_i  = 32'd0;
        axi_t_arid_i    = 4'd0;
        axi_t_arlen_i   = 8'd0;
        axi_t_arburst_i = 2'd0;
        axi_t_rready_i  = 1'b1;

        trace_rd_addr_i = 6'd0;

        // Give memory / TCM some reset time
        repeat (10) @(posedge clk_i);
        rst_i <= 1'b0;

        // After memory is out of reset, release CPU reset
        repeat (10) @(posedge clk_i);
        rst_cpu_i <= 1'b0;

        // Let the core run for a while
        repeat (200000) @(posedge clk_i);

        // -------------------------------------
        // Dump trace buffer
        // -------------------------------------
        $display("========================================");
        $display("[TB] Trace buffer status after 200000 cycles:");
        $display("  triggered = %0d", trace_triggered_o);
        $display("  wr_ptr    = %0d", trace_wr_ptr_o);
        $display("========================================");
        $display("[TB] Dumping all 64 entries from trace buffer...");

        for (idx = 0; idx < 64; idx = idx + 1) begin
            trace_rd_addr_i = idx[5:0];
            @(posedge clk_i);
            $display("TRACE[%0d]: PC=0x%08x  INSTR=0x%08x",
                     idx, trace_rd_data_o[63:32], trace_rd_data_o[31:0]);
        end

        $finish;
    end

endmodule