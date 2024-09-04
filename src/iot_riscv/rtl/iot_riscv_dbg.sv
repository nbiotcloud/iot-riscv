// GENERATE INPLACE BEGIN fileheader() =========================================
//
// Module:     iot_riscv.iot_riscv_dbg
// Data Model: iot_riscv.iot_riscv_dbg.IotRiscvDbgMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_dbg #( // iot_riscv.iot_riscv_dbg.IotRiscvDbgMod
  parameter integer pc_size_p = 32
) (
  // main_i
  input  wire                  main_clk_i,
  input  wire                  main_rst_an_i,          // Async Reset (Low-Active)
  output logic                 debug_halt_o,
  output logic                 debug_halt_data_o,
  output logic                 debug_single_step_o,
  input  wire  [pc_size_p-1:0] if_pc_i,
  input  wire                  branch_taken_i,
  input  wire                  riscv_debug_pause_i,
  input  wire                  riscv_debug_step_i,
  output logic                 riscv_debug_break_o,
  output logic                 debug_halt_comb_o,
  output logic                 debug_halt_data_comb_o,
  input  wire  [31:0]          d_addr_i,
  input  wire                  d_rdy_i,
  input  wire                  ex_mem_rd_i,
  input  wire                  ex_mem_wr_i,
  input  wire                  mem_stall_i,
  input  wire                  id_exec_i,
  input  wire                  id_bubble_i,
  input  wire                  id_break_i,
  input  wire  [30:0]          riscv_bp0_bp_addr_i,
  input  wire                  riscv_bp0_bp_en_i,
  input  wire  [30:0]          riscv_bp1_bp_addr_i,
  input  wire                  riscv_bp1_bp_en_i,
  input  wire                  riscv_dbp0_dbp_en_i,
  input  wire                  riscv_dbp0_dbp_wr_i,
  input  wire  [29:0]          riscv_dbp0_dbp_addr_i,
  input  wire                  riscv_dbp1_dbp_en_i,
  input  wire                  riscv_dbp1_dbp_wr_i,
  input  wire  [29:0]          riscv_dbp1_dbp_addr_i
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic bp0_addr_hit_s;
logic bp0_hit_s;
logic dbp0_hit_s;
logic bp1_addr_hit_s;
logic bp1_hit_s;
logic dbp1_hit_s;
logic debug_halt_s;
logic debug_halt_r;
logic debug_halt_data_s;
logic debug_halt_data_r;
logic debug_single_step_s;
logic debug_single_step_r;
// GENERATE INPLACE END logic ==================================================



  /*------------------------------------------------------------------------------
  --  Debug
  ------------------------------------------------------------------------------*/

  assign bp0_addr_hit_s = if_pc_i[31:1] == riscv_bp0_bp_addr_i;
  assign bp0_hit_s = (bp0_addr_hit_s && (riscv_bp0_bp_en_i == 1'b1) && (branch_taken_i == 1'b0));

  assign bp1_addr_hit_s = if_pc_i[31:1] == riscv_bp1_bp_addr_i;
  assign bp1_hit_s = (bp1_addr_hit_s && (riscv_bp1_bp_en_i == 1'b1) && (branch_taken_i == 1'b0));

  assign debug_halt_s = (bp0_hit_s | bp1_hit_s | debug_halt_r) & ~riscv_debug_step_i;

  assign dbp0_hit_s = ((d_addr_i[31:2] == riscv_dbp0_dbp_addr_i) && (riscv_dbp0_dbp_en_i == 1'b1) &&
                       (((ex_mem_rd_i == 1'b1) && (riscv_dbp0_dbp_wr_i == 1'b0))  ||
                        ((ex_mem_wr_i == 1'b1) && (riscv_dbp0_dbp_wr_i == 1'b1))) &&
                       (mem_stall_i == 1'b0));
  assign dbp1_hit_s = ((d_addr_i[31:2] == riscv_dbp1_dbp_addr_i) && (riscv_dbp1_dbp_en_i == 1'b1) &&
                       (((ex_mem_rd_i == 1'b1) && (riscv_dbp1_dbp_wr_i == 1'b0))  ||
                        ((ex_mem_wr_i == 1'b1) && (riscv_dbp1_dbp_wr_i == 1'b1))) &&
                       (mem_stall_i == 1'b0));
  assign debug_halt_data_s = (dbp0_hit_s | dbp1_hit_s | debug_halt_data_r) & ~riscv_debug_step_i;

  assign debug_single_step_s = riscv_debug_pause_i & riscv_debug_step_i;

  always @(posedge clk_i or negedge rst_an_i) begin : proc_debugger
    if (rst_an_i == 1'b0) begin
      debug_halt_r <= #`dly 1'b0;
      debug_halt_data_r <= #`dly 1'b0;
      debug_single_step_r <= #`dly 1'b0;
    end else begin
      //step out of breakpoint when requested, halt when pause or breakpoint matches
      if (riscv_debug_step_i == 1'b1) begin
        debug_halt_r <= #`dly 1'b0;
      end else if (bp0_hit_s || bp1_hit_s || (riscv_debug_pause_i == 1'b1)) begin
        debug_halt_r <= #`dly 1'b1;
      end
      //step out of breakpoint when requested, halt when data breakpoint and read/write matches
      if (riscv_debug_step_i == 1'b1) begin
        debug_halt_data_r <= #`dly 1'b0;
      end else if (dbp0_hit_s || dbp1_hit_s) begin
        debug_halt_data_r <= #`dly 1'b1;
      end
      //mark a single step to allow one instruction to execute before halting again
      if (debug_single_step_s == 1'b1) begin
        debug_single_step_r <= #`dly 1'b1;
      end else if ((id_exec_i == 1'b1) && (id_bubble_i == 1'b0)) begin
        debug_single_step_r <= #`dly 1'b0;
      end
    end
  end

  assign debug_halt_data_o = debug_halt_data_r;
  assign debug_halt_o = debug_halt_r;
  assign debug_single_step_o = debug_single_step_r;
  assign riscv_debug_break_o = id_break_i;

  assign debug_halt_comb_o = debug_halt_s;
  assign debug_halt_data_comb_o = debug_halt_data_s;

  
// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_dbg
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
