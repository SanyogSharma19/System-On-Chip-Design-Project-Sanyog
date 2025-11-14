`timescale 1ns/1ps

// Use the same instruction encodings / masks as the core
`include "riscv_defs.v"

module tb_multiplier;

    // Clock / reset
    reg         clk_i;
    reg         rst_i;

    // Opcode interface
    reg         opcode_valid_i;
    reg  [31:0] opcode_opcode_i;
    reg  [31:0] opcode_pc_i;
    reg         opcode_invalid_i;
    reg  [4:0]  opcode_rd_idx_i;
    reg  [4:0]  opcode_ra_idx_i;
    reg  [4:0]  opcode_rb_idx_i;
    reg  [31:0] opcode_ra_operand_i;
    reg  [31:0] opcode_rb_operand_i;
    reg         hold_i;

    // Outputs
    wire [31:0] writeback_value_o;
    wire        busy_o;

    // DUT: your modified multiplier
    riscv_multiplier dut (
        .clk_i               (clk_i),
        .rst_i               (rst_i),
        .opcode_valid_i      (opcode_valid_i),
        .opcode_opcode_i     (opcode_opcode_i),
        .opcode_pc_i         (opcode_pc_i),
        .opcode_invalid_i    (opcode_invalid_i),
        .opcode_rd_idx_i     (opcode_rd_idx_i),
        .opcode_ra_idx_i     (opcode_ra_idx_i),
        .opcode_rb_idx_i     (opcode_rb_idx_i),
        .opcode_ra_operand_i (opcode_ra_operand_i),
        .opcode_rb_operand_i (opcode_rb_operand_i),
        .hold_i              (hold_i),

        .writeback_value_o   (writeback_value_o),
        .busy_o              (busy_o)
    );

    // 10 ns clock
    always #5 clk_i = ~clk_i;

    // Optional: VCD dump for GTKWave
    initial begin
        $dumpfile("tb_multiplier.vcd");
        $dumpvars(0, tb_multiplier);
    end

    // Simple monitor
    always @(posedge clk_i) begin
        $display("[%0t] busy=%0b result=0x%08x",
                 $time, busy_o, writeback_value_o);
    end

    // Helper task to fire one MUL-type instruction
    task automatic issue_mul;
        input [31:0] inst;
        input [31:0] op_a;
        input [31:0] op_b;
    begin
        // Drive inputs before the clock edge
        opcode_ra_operand_i = op_a;
        opcode_rb_operand_i = op_b;
        opcode_opcode_i     = inst;
        opcode_valid_i      = 1'b1;

        // One cycle of valid
        @(posedge clk_i);
        opcode_valid_i      = 1'b0;
    end
    endtask

    initial begin
        // Init
        clk_i               = 1'b0;
        rst_i               = 1'b1;
        opcode_valid_i      = 1'b0;
        opcode_opcode_i     = 32'd0;
        opcode_pc_i         = 32'd0;
        opcode_invalid_i    = 1'b0;
        opcode_rd_idx_i     = 5'd1;   // any non-zero RD index is fine
        opcode_ra_idx_i     = 5'd2;
        opcode_rb_idx_i     = 5'd3;
        opcode_ra_operand_i = 32'd0;
        opcode_rb_operand_i = 32'd0;
        hold_i              = 1'b0;

        // Reset for a few cycles
        repeat (3) @(posedge clk_i);
        rst_i = 1'b0;

        // ---------------------------------------------------------
        // Test 1: MUL 3 * 7 = 21
        // ---------------------------------------------------------
        issue_mul(`INST_MUL, 32'd3, 32'd7);

        // Wait for pipeline to produce result
        repeat (5) @(posedge clk_i);
        $display("MUL 3*7 => %0d (0x%08x)", writeback_value_o, writeback_value_o);

        // ---------------------------------------------------------
        // Test 2: MULH (-2 * 7), check high 32 bits
        // ---------------------------------------------------------
        issue_mul(`INST_MULH, -32'sd2, 32'd7);

        repeat (5) @(posedge clk_i);
        $display("MULH -2*7 (hi part) => 0x%08x", writeback_value_o);

        // ---------------------------------------------------------
        // Test 3: MULHU (unsigned) 0xFFFF0000 * 0x0000FFFF
        // ---------------------------------------------------------
        issue_mul(`INST_MULHU, 32'hFFFF0000, 32'h0000FFFF);

        repeat (5) @(posedge clk_i);
        $display("MULHU FFFF0000*0000FFFF (hi) => 0x%08x", writeback_value_o);

        // Done
        $finish;
    end

endmodule
