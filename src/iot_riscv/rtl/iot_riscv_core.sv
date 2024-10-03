// =============================================================================
//
// THIS FILE IS GENERATED!!! DO NOT EDIT MANUALLY. CHANGES ARE LOST.
//
// =============================================================================
//
//  MIT License
//
//  Copyright (c) 2024 nbiotcloud
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
// =============================================================================
//
// Module:     iot_riscv.iot_riscv_core
// Data Model: iot_riscv.iot_riscv_core.IotRiscvCoreMod
//
// =============================================================================

`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden

module iot_riscv_core #( // iot_riscv.iot_riscv_core.IotRiscvCoreMod
  parameter integer        irq_width_p = 32,
  parameter logic   [31:0] pc_size_p   = 32'h00000020,
  parameter logic   [31:0] reset_sp_p  = 32'h00002000,
  parameter logic   [31:0] reset_vec_p = 32'h00000000
) (
  // main_i
  input  wire                    main_clk_i,
  input  wire                    main_rst_an_i,         // Async Reset (Low-Active)
  output logic                   lock_o,
  // i_o
  output logic                   i_rd_o,
  output logic [31:0]            i_addr_o,
  output logic [31:0]            i_wdata_o,
  output logic                   i_wr_o,
  input  wire                    i_rdy_i,
  input  wire                    i_grant_i,
  input  wire  [31:0]            i_rdata_i,
  output logic [1:0]             i_size_o,
  // d_o
  output logic                   d_rd_o,
  output logic [31:0]            d_addr_o,
  output logic [31:0]            d_wdata_o,
  output logic                   d_wr_o,
  input  wire                    d_rdy_i,
  input  wire                    d_grant_i,
  input  wire  [31:0]            d_rdata_i,
  output logic [1:0]             d_size_o,
  output logic                   debug_halt_o,
  output logic                   debug_halt_data_o,
  output logic [31:0]            mscratch_o,
  output logic [31:0]            mepc_o,
  output logic [31:0]            mtvec_o,
  output logic [31:0]            riscv_reg_x0_o,
  output logic [31:0]            riscv_reg_x1_o,
  output logic [31:0]            riscv_reg_x2_o,
  output logic [31:0]            riscv_reg_x3_o,
  output logic [31:0]            riscv_reg_x4_o,
  output logic [31:0]            riscv_reg_x5_o,
  output logic [31:0]            riscv_reg_x6_o,
  output logic [31:0]            riscv_reg_x7_o,
  output logic [31:0]            riscv_reg_x8_o,
  output logic [31:0]            riscv_reg_x9_o,
  output logic [31:0]            riscv_reg_x10_o,
  output logic [31:0]            riscv_reg_x11_o,
  output logic [31:0]            riscv_reg_x12_o,
  output logic [31:0]            riscv_reg_x13_o,
  output logic [31:0]            riscv_reg_x14_o,
  output logic [31:0]            riscv_reg_x15_o,
  output logic [31:0]            riscv_reg_x16_o,
  output logic [31:0]            riscv_reg_x17_o,
  output logic [31:0]            riscv_reg_x18_o,
  output logic [31:0]            riscv_reg_x19_o,
  output logic [31:0]            riscv_reg_x20_o,
  output logic [31:0]            riscv_reg_x21_o,
  output logic [31:0]            riscv_reg_x22_o,
  output logic [31:0]            riscv_reg_x23_o,
  output logic [31:0]            riscv_reg_x24_o,
  output logic [31:0]            riscv_reg_x25_o,
  output logic [31:0]            riscv_reg_x26_o,
  output logic [31:0]            riscv_reg_x27_o,
  output logic [31:0]            riscv_reg_x28_o,
  output logic [31:0]            riscv_reg_x29_o,
  output logic [31:0]            riscv_reg_x30_o,
  output logic [31:0]            riscv_reg_x31_o,
  output logic [31:0]            riscv_reg_pc_o,
  input  wire                    riscv_debug_pause_i,
  input  wire                    riscv_debug_step_i,
  output logic                   riscv_debug_break_o,
  input  wire  [30:0]            riscv_bp0_bp_addr_i,
  input  wire                    riscv_bp0_bp_en_i,
  input  wire  [30:0]            riscv_bp1_bp_addr_i,
  input  wire                    riscv_bp1_bp_en_i,
  input  wire                    riscv_dbp0_dbp_en_i,
  input  wire                    riscv_dbp0_dbp_wr_i,
  input  wire  [29:0]            riscv_dbp0_dbp_addr_i,
  input  wire                    riscv_dbp1_dbp_en_i,
  input  wire                    riscv_dbp1_dbp_wr_i,
  input  wire  [29:0]            riscv_dbp1_dbp_addr_i,
  input  wire                    irq_en_i,
  input  wire  [irq_width_p-1:0] irq_i,
  input  wire  [irq_width_p-1:0] irq_mask_i,
  output logic                   irq_run_en_o
);

  

  // ------------------------------------------------------
  //  Signals
  // ------------------------------------------------------
  logic [pc_size_p-32'h00000001:0] if_next_pc_s;
  logic                            id_hazard_r;
  logic                            ex_hazard_r;
  logic [4:0]                      id_rd_index_r;
  logic [11:0]                     id_csr_addr_r;
  logic                            id_mem_rd_r;
  logic                            id_mem_wr_r;
  logic                            id_mem_signed_r;
  logic [1:0]                      id_mem_size_r;
  logic                            id_csrrw_r;
  logic                            ex_bubble_s;
  logic                            ex_ready_s;
  logic                            branch_hold_r;
  // rd_s
  logic [4:0]                      rd_index_s;
  logic [31:0]                     rd_value_s;
  logic                            rd_we_s;
  logic                            debug_halt_s;
  logic                            debug_halt_data_s;
  logic                            debug_single_step_s;
  logic                            branch_taken_s;
  logic [31:0]                     jump_addr_s;
  logic                            hazard_s;
  logic                            if_rv_s;
  logic                            if_valid_s;
  logic [31:0]                     if_rv_op_s;
  logic                            if_break_exit_r;
  logic                            if_hold_state_s;
  logic [31:0]                     if_rvc_dec_s;
  logic [31:0]                     if_opcode_s;
  logic                            break_s;
  logic [4:0]                      id_rd_index_s;
  logic [11:0]                     id_csr_addr_s;
  logic [31:0]                     id_imm_s;
  logic                            id_a_signed_s;
  logic                            id_b_signed_s;
  logic                            id_op_imm_s;
  logic [3:0]                      id_alu_op_s;
  logic                            load_s;
  logic                            store_s;
  logic                            id_mem_signed_s;
  logic [1:0]                      id_mem_size_s;
  logic [2:0]                      id_branch_s;
  logic                            jalr_s;
  logic                            id_illegal_s;
  logic                            csrrw_s;
  logic                            mret_s;
  logic [4:0]                      id_ra_index_s;
  logic [4:0]                      id_rb_index_s;
  logic [31:0]                     id_ra_value_s;
  logic [31:0]                     id_rb_value_s;
  logic                            id_ready_s;
  logic                            id_op_imm_r;
  logic [31:0]                     id_imm_r;
  logic [3:0]                      id_alu_op_r;
  logic                            id_a_signed_r;
  logic                            id_b_signed_r;
  logic                            id_break_r;
  logic [pc_size_p-1:0]            id_pc_r;
  logic                            id_irq_r;
  logic                            id_mret_r;
  logic [2:0]                      id_branch_r;
  logic                            id_reg_jump_r;
  logic [31:0]                     ex_alu_res_s;
  logic                            ex_stall_s;
  logic [pc_size_p-1:0]            id_next_pc_r;
  logic [31:0]                     ex_alu_res_r;
  logic [31:0]                     ex_mem_data_r;
  logic [1:0]                      ex_mem_size_r;
  logic                            ex_mem_signed_r;
  logic                            ex_mem_rd_r;
  logic                            ex_mem_wr_r;
  logic [4:0]                      ex_rd_index_r;
  logic                            ex_csrrw_r;
  logic                            mem_stall_r;
  logic                            mem_stall_s;
  logic [11:0]                     ex_csr_addr_r;
  logic                            debug_halt_r;
  logic                            debug_halt_data_r;
  logic [pc_size_p-1:0]            if_pc_r;
  logic                            irq_hot_s;
  logic                            id_lock_r;
  logic                            id_clear_s;
  logic                            ex_clear_s;
  logic [15:0]                     compressed_decoder_rvc_op_i_s;
  logic [31:0]                     lsu_csr_rd_value_i_s;
  logic [31:0]                     hazard_unit_fwd_data_o_s;
  logic                            hazard_unit_fwd_a_en_o_s;
  logic                            hazard_unit_fwd_b_en_o_s;


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_fetch: u_fetch
  // ------------------------------------------------------
  iot_riscv_fetch #(
    .pc_size_p  (32'h00000020),
    .reset_vec_p(32'h00000000)
  ) u_fetch (
    // main_i
    .main_clk_i         (main_clk_i                   ),
    .main_rst_an_i      (main_rst_an_i                ), // Async Reset (Low-Active)
    // i_o
    .i_rd_o             (i_rd_o                       ),
    .i_addr_o           (i_addr_o                     ),
    .i_wdata_o          (i_wdata_o                    ),
    .i_wr_o             (i_wr_o                       ),
    .i_rdy_i            (i_rdy_i                      ),
    .i_grant_i          (i_grant_i                    ),
    .i_rdata_i          (i_rdata_i                    ),
    .i_size_o           (i_size_o                     ),
    .debug_halt_i       (debug_halt_s                 ),
    .debug_halt_data_i  (debug_halt_data_s            ),
    .debug_single_step_i(debug_single_step_s          ),
    .branch_taken_i     (branch_taken_s               ),
    .jump_addr_i        (jump_addr_s                  ),
    .if_pc_i            (if_pc_r                      ),
    .hazard_i           (hazard_s                     ),
    .if_rv_o            (if_rv_s                      ),
    .if_valid_o         (if_valid_s                   ),
    .if_rv_op_o         (if_rv_op_s                   ),
    .if_rvc_op_o        (compressed_decoder_rvc_op_i_s),
    .if_break_exit_o    (if_break_exit_r              ),
    .if_hold_state_o    (if_hold_state_s              )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_compressed_decoder: u_compressed_decoder
  // ------------------------------------------------------
  iot_riscv_compressed_decoder u_compressed_decoder (
    .rvc_op_i (compressed_decoder_rvc_op_i_s),
    .rvc_dec_o(if_rvc_dec_s                 )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_decoder: u_decoder
  // ------------------------------------------------------
  iot_riscv_decoder u_decoder (
    .rv_op_i        (if_opcode_s    ),
    .break_o        (break_s        ),
    .id_rd_index_o  (id_rd_index_s  ),
    .id_csr_addr_o  (id_csr_addr_s  ),
    .id_imm_o       (id_imm_s       ),
    .id_a_signed_o  (id_a_signed_s  ),
    .id_b_signed_o  (id_b_signed_s  ),
    .id_op_imm_o    (id_op_imm_s    ),
    .id_alu_op_o    (id_alu_op_s    ),
    .load_o         (load_s         ),
    .store_o        (store_s        ),
    .id_mem_signed_o(id_mem_signed_s),
    .id_mem_size_o  (id_mem_size_s  ),
    .id_branch_o    (id_branch_s    ),
    .id_reg_jump_o  (jalr_s         ),
    .id_lock_o      (id_illegal_s   ),
    .id_csrrw_o     (csrrw_s        ),
    .id_mret_o      (mret_s         ),
    .id_ra_index_o  (id_ra_index_s  ),
    .id_rb_index_o  (id_rb_index_s  )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_regfile: u_regfile
  // ------------------------------------------------------
  iot_riscv_regfile u_regfile (
    // main_i
    .main_clk_i     (main_clk_i              ),
    .main_rst_an_i  (main_rst_an_i           ), // Async Reset (Low-Active)
    .id_ra_value_o  (id_ra_value_s           ),
    .id_rb_value_o  (id_rb_value_s           ),
    .id_flush_i     (id_clear_s              ),
    .id_ready_i     (id_ready_s              ),
    .id_ra_index_i  (id_ra_index_s           ),
    .id_rb_index_i  (id_rb_index_s           ),
    .fwd_data_i     (hazard_unit_fwd_data_o_s),
    .fwd_a_en_i     (hazard_unit_fwd_a_en_o_s),
    .fwd_b_en_i     (hazard_unit_fwd_b_en_o_s),
    // rd_i
    .rd_index_i     (rd_index_s              ),
    .rd_value_i     (rd_value_s              ),
    .rd_we_i        (rd_we_s                 ),
    .riscv_reg_x0_o (riscv_reg_x0_o          ),
    .riscv_reg_x1_o (riscv_reg_x1_o          ),
    .riscv_reg_x2_o (riscv_reg_x2_o          ),
    .riscv_reg_x3_o (riscv_reg_x3_o          ),
    .riscv_reg_x4_o (riscv_reg_x4_o          ),
    .riscv_reg_x5_o (riscv_reg_x5_o          ),
    .riscv_reg_x6_o (riscv_reg_x6_o          ),
    .riscv_reg_x7_o (riscv_reg_x7_o          ),
    .riscv_reg_x8_o (riscv_reg_x8_o          ),
    .riscv_reg_x9_o (riscv_reg_x9_o          ),
    .riscv_reg_x10_o(riscv_reg_x10_o         ),
    .riscv_reg_x11_o(riscv_reg_x11_o         ),
    .riscv_reg_x12_o(riscv_reg_x12_o         ),
    .riscv_reg_x13_o(riscv_reg_x13_o         ),
    .riscv_reg_x14_o(riscv_reg_x14_o         ),
    .riscv_reg_x15_o(riscv_reg_x15_o         ),
    .riscv_reg_x16_o(riscv_reg_x16_o         ),
    .riscv_reg_x17_o(riscv_reg_x17_o         ),
    .riscv_reg_x18_o(riscv_reg_x18_o         ),
    .riscv_reg_x19_o(riscv_reg_x19_o         ),
    .riscv_reg_x20_o(riscv_reg_x20_o         ),
    .riscv_reg_x21_o(riscv_reg_x21_o         ),
    .riscv_reg_x22_o(riscv_reg_x22_o         ),
    .riscv_reg_x23_o(riscv_reg_x23_o         ),
    .riscv_reg_x24_o(riscv_reg_x24_o         ),
    .riscv_reg_x25_o(riscv_reg_x25_o         ),
    .riscv_reg_x26_o(riscv_reg_x26_o         ),
    .riscv_reg_x27_o(riscv_reg_x27_o         ),
    .riscv_reg_x28_o(riscv_reg_x28_o         ),
    .riscv_reg_x29_o(riscv_reg_x29_o         ),
    .riscv_reg_x30_o(riscv_reg_x30_o         ),
    .riscv_reg_x31_o(riscv_reg_x31_o         )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_alu: u_alu
  // ------------------------------------------------------
  iot_riscv_alu #(
    .pc_size_p(32'h00000020)
  ) u_alu (
    // main_i
    .main_clk_i    (main_clk_i    ),
    .main_rst_an_i (main_rst_an_i ), // Async Reset (Low-Active)
    .id_op_imm_i   (id_op_imm_r   ),
    .id_imm_i      (id_imm_r      ),
    .id_rb_value_i (id_rb_value_s ),
    .id_ra_value_i (id_ra_value_s ),
    .id_alu_op_i   (id_alu_op_r   ),
    .id_a_signed_i (id_a_signed_r ),
    .id_b_signed_i (id_b_signed_r ),
    .id_break_i    (id_break_r    ),
    .id_pc_i       (id_pc_r       ),
    .id_irq_i      (id_irq_r      ),
    .id_mret_i     (id_mret_r     ),
    .mtvec_i       (mtvec_o       ),
    .mepc_i        (mepc_o        ),
    .id_next_pc_i  (id_next_pc_r  ),
    .id_branch_i   (id_branch_r   ),
    .id_reg_jump_i (id_reg_jump_r ),
    .branch_taken_o(branch_taken_s),
    .jump_addr_o   (jump_addr_s   ),
    .ex_alu_res_o  (ex_alu_res_s  ),
    .ex_stall_o    (ex_stall_s    )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_lsu: u_lsu
  // ------------------------------------------------------
  iot_riscv_lsu u_lsu (
    // main_i
    .main_clk_i      (main_clk_i          ),
    .main_rst_an_i   (main_rst_an_i       ), // Async Reset (Low-Active)
    .ex_alu_res_i    (ex_alu_res_r        ),
    .ex_mem_data_i   (ex_mem_data_r       ),
    .ex_mem_size_i   (ex_mem_size_r       ),
    .ex_mem_signed_i (ex_mem_signed_r     ),
    .ex_mem_rd_i     (ex_mem_rd_r         ),
    .ex_mem_wr_i     (ex_mem_wr_r         ),
    .csr_rd_value_i  (lsu_csr_rd_value_i_s),
    .ex_rd_index_i   (ex_rd_index_r       ),
    .ex_csrrw_i      (ex_csrrw_r          ),
    .mem_stall_o     (mem_stall_r         ),
    .mem_stall_comb_o(mem_stall_s         ),
    // d_o
    .d_rd_o          (d_rd_o              ),
    .d_addr_o        (d_addr_o            ),
    .d_wdata_o       (d_wdata_o           ),
    .d_wr_o          (d_wr_o              ),
    .d_rdy_i         (d_rdy_i             ),
    .d_grant_i       (d_grant_i           ),
    .d_rdata_i       (d_rdata_i           ),
    .d_size_o        (d_size_o            ),
    // rd_o
    .rd_index_o      (rd_index_s          ),
    .rd_value_o      (rd_value_s          ),
    .rd_we_o         (rd_we_s             )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_csr: u_csr
  // ------------------------------------------------------
  iot_riscv_csr #(
    .pc_size_p(32'h00000020)
  ) u_csr (
    // main_i
    .main_clk_i    (main_clk_i          ),
    .main_rst_an_i (main_rst_an_i       ), // Async Reset (Low-Active)
    .ex_csr_addr_i (ex_csr_addr_r       ),
    .ex_alu_res_i  (ex_alu_res_r        ),
    .id_pc_i       (id_pc_r             ),
    .csr_rd_value_o(lsu_csr_rd_value_i_s),
    .mscratch_o    (mscratch_o          ),
    .mepc_o        (mepc_o              ),
    .mtvec_o       (mtvec_o             )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_dbg: u_dbg
  // ------------------------------------------------------
  iot_riscv_dbg #(
    .pc_size_p(32'h00000020)
  ) u_dbg (
    // main_i
    .main_clk_i            (main_clk_i           ),
    .main_rst_an_i         (main_rst_an_i        ), // Async Reset (Low-Active)
    .debug_halt_o          (debug_halt_r         ),
    .debug_halt_data_o     (debug_halt_data_r    ),
    .debug_single_step_o   (debug_single_step_s  ),
    .if_pc_i               (if_pc_r              ),
    .branch_taken_i        (branch_taken_s       ),
    .riscv_debug_pause_i   (riscv_debug_pause_i  ),
    .riscv_debug_step_i    (riscv_debug_step_i   ),
    .riscv_debug_break_o   (riscv_debug_break_o  ),
    .debug_halt_comb_o     (debug_halt_s         ),
    .debug_halt_data_comb_o(debug_halt_data_s    ),
    .d_addr_i              (d_addr_o             ),
    .d_rdy_i               (d_rdy_i              ),
    .ex_mem_rd_i           (ex_mem_rd_r          ),
    .ex_mem_wr_i           (ex_mem_wr_r          ),
    .mem_stall_i           (mem_stall_r          ),
    .id_exec_i             (id_ready_s           ),
    .id_bubble_i           (id_clear_s           ),
    .id_break_i            (id_break_r           ),
    .riscv_bp0_bp_addr_i   (riscv_bp0_bp_addr_i  ),
    .riscv_bp0_bp_en_i     (riscv_bp0_bp_en_i    ),
    .riscv_bp1_bp_addr_i   (riscv_bp1_bp_addr_i  ),
    .riscv_bp1_bp_en_i     (riscv_bp1_bp_en_i    ),
    .riscv_dbp0_dbp_en_i   (riscv_dbp0_dbp_en_i  ),
    .riscv_dbp0_dbp_wr_i   (riscv_dbp0_dbp_wr_i  ),
    .riscv_dbp0_dbp_addr_i (riscv_dbp0_dbp_addr_i),
    .riscv_dbp1_dbp_en_i   (riscv_dbp1_dbp_en_i  ),
    .riscv_dbp1_dbp_wr_i   (riscv_dbp1_dbp_wr_i  ),
    .riscv_dbp1_dbp_addr_i (riscv_dbp1_dbp_addr_i)
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_int_irq: u_int_irq
  // ------------------------------------------------------
  iot_riscv_int_irq #(
    .irq_width_p(32)
  ) u_int_irq (
    // main_i
    .main_clk_i         (main_clk_i         ),
    .main_rst_an_i      (main_rst_an_i      ), // Async Reset (Low-Active)
    .irq_en_i           (irq_en_i           ),
    .irq_i              (irq_i              ),
    .irq_mask_i         (irq_mask_i         ),
    .irq_run_en_o       (irq_run_en_o       ),
    .debug_halt_i       (debug_halt_s       ),
    .debug_single_step_i(debug_single_step_s),
    .debug_halt_data_i  (debug_halt_data_s  ),
    .id_irq_i           (id_irq_r           ),
    .id_mret_i          (id_mret_r          ),
    .irq_hot_o          (irq_hot_s          )
  );


  // ------------------------------------------------------
  //  iot_riscv.iot_riscv_hazard_unit: u_hazard_unit
  // ------------------------------------------------------
  iot_riscv_hazard_unit u_hazard_unit (
    .ex_stall_i     (ex_stall_s              ),
    .alu_res_i      (ex_alu_res_s            ),
    .id_csrrw_i     (id_csrrw_r              ),
    .id_mem_rd_i    (id_mem_rd_r             ),
    .exe_rd_index_i (id_rd_index_r           ),
    .mem_stall_i    (mem_stall_s             ),
    .mem_rd_index_i (ex_rd_index_r           ),
    .mem_rd_value_i (rd_value_s              ),
    .id_ra_index_i  (id_ra_index_s           ),
    .id_rb_index_i  (id_rb_index_s           ),
    .branch_taken_i (branch_taken_s          ),
    .id_lock_i      (id_lock_r               ),
    .if_valid_i     (if_valid_s              ),
    .if_hold_state_i(if_hold_state_s         ),
    .id_ready_o     (id_ready_s              ),
    .ex_ready_o     (ex_ready_s              ),
    .id_clear_o     (id_clear_s              ),
    .ex_clear_o     (ex_clear_s              ),
    .hazard_o       (hazard_s                ),
    .fwd_data_o     (hazard_unit_fwd_data_o_s),
    .fwd_a_en_o     (hazard_unit_fwd_a_en_o_s),
    .fwd_b_en_o     (hazard_unit_fwd_b_en_o_s)
  );

`define ENABLE_COMPRESSED_ISA
`define USE_BARREL_SHIFTER
`define USE_NATIVE_MULTIPLIER

localparam ALU_ADD   = 4'd0;
localparam ALU_SUB   = 4'd1;
localparam ALU_AND   = 4'd2;
localparam ALU_OR    = 4'd3;
localparam ALU_XOR   = 4'd4;
localparam ALU_SLT   = 4'd5;
localparam ALU_SLTU  = 4'd6;
localparam ALU_SHL   = 4'd7;
localparam ALU_SHR   = 4'd8;
localparam ALU_MULL  = 4'd9;
localparam ALU_MULH  = 4'd10;
localparam ALU_DIV   = 4'd11;
localparam ALU_REM   = 4'd12;
localparam ALU_NPC   = 4'd13;
localparam ALU_AUIPC = 4'd14;
localparam ALU_RA    = 4'd15;

localparam BR_NONE   = 3'd0;
localparam BR_JUMP   = 3'd1;
localparam BR_EQ     = 3'd2;
localparam BR_NE     = 3'd3;
localparam BR_LT     = 3'd4;
localparam BR_GE     = 3'd5;
localparam BR_LTU    = 3'd6;
localparam BR_GEU    = 3'd7;

localparam SIZE_BYTE = 2'd0;
localparam SIZE_HALF = 2'd1;
localparam SIZE_WORD = 2'd2;


localparam ebreak_p = { 11'h000, 1'b1, 13'h0000, 7'b1110011 };
localparam irq_p    = { 12'h341, 5'h00, 3'h1, 5'h00, 7'b1110011 };

/*------------------------------------------------------------------------------
--  Instruction Fetch Pipeline Registers
------------------------------------------------------------------------------*/

always @(posedge clk_i or negedge rst_an_i) begin : proc_if_pc
  if (rst_an_i == 1'b0) begin
    if_pc_r <= #`dly reset_vec_p;
  end else if (branch_taken_s == 1'b1) begin
    if_pc_r <= #`dly jump_addr_s[pc_size_p-1:0];
  end else if ((~hazard_s & if_valid_s & ~if_break_exit_r) == 1'b1) begin
    if_pc_r <= #`dly if_next_pc_s;
  end
end

assign if_next_pc_s = if_hold_state_s ? if_pc_r : if_pc_r + (if_rv_s ? 'd4 : 'd2);

// To select instruction for decoding
always_comb begin : proc_if_opcode
  if (((debug_halt_r | debug_halt_data_r) & ~debug_single_step_s) == 1'b1) begin //breakpoint or pause
    if_opcode_s = ebreak_p;
  end else if (irq_hot_s == 1'b1) begin //interrupt
    if_opcode_s = irq_p;
  end else if (if_rv_s == 1'b1) begin //generic instruction
    if_opcode_s = if_rv_op_s;
  end else begin //compressed instruction
    if_opcode_s = if_rvc_dec_s;
  end
end

/*------------------------------------------------------------------------------
--  Instruction Decoder Pipeline Registers
------------------------------------------------------------------------------*/

always @(posedge clk_i or negedge rst_an_i) begin  : proc_id_regs
  if (rst_an_i == 1'b0) begin
    id_pc_r         <= #`dly 'h0;
    id_break_r      <= #`dly 1'b0;
    id_next_pc_r    <= #`dly 'h0;
    id_rd_index_r   <= #`dly 5'd0;
    id_csr_addr_r   <= #`dly 12'h000;
    id_imm_r        <= #`dly {32{1'b0}};
    id_a_signed_r   <= #`dly 1'b0;
    id_b_signed_r   <= #`dly 1'b0;
    id_op_imm_r     <= #`dly 1'b0;
    id_alu_op_r     <= #`dly ALU_ADD;
    id_mem_rd_r     <= #`dly 1'b0;
    id_mem_wr_r     <= #`dly 1'b0;
    id_mem_signed_r <= #`dly 1'b0;
    id_mem_size_r   <= #`dly SIZE_BYTE;
    id_branch_r     <= #`dly BR_NONE;
    id_reg_jump_r   <= #`dly 1'b0;
    id_lock_r       <= #`dly 1'b0;
    id_csrrw_r      <= #`dly 1'b0;
    id_irq_r        <= #`dly 1'b0;
    id_mret_r       <= #`dly 1'b0;
  end else if (id_clear_s) begin
    // id_pc_r         <= #`dly 'h0;
    id_break_r      <= #`dly 1'b0;
    id_next_pc_r    <= #`dly 'h0;
    id_rd_index_r   <= #`dly 5'd0;
    id_csr_addr_r   <= #`dly 12'h000;
    id_imm_r        <= #`dly {32{1'b0}};
    id_a_signed_r   <= #`dly 1'b0;
    id_b_signed_r   <= #`dly 1'b0;
    id_op_imm_r     <= #`dly 1'b0;
    id_alu_op_r     <= #`dly ALU_ADD;
    id_mem_rd_r     <= #`dly 1'b0;
    id_mem_wr_r     <= #`dly 1'b0;
    id_mem_signed_r <= #`dly 1'b0;
    id_mem_size_r   <= #`dly SIZE_BYTE;
    id_branch_r     <= #`dly BR_NONE;
    id_reg_jump_r   <= #`dly 1'b0;
    id_lock_r       <= #`dly 1'b0;
    id_csrrw_r      <= #`dly 1'b0;
    id_irq_r        <= #`dly 1'b0;
    id_mret_r       <= #`dly 1'b0;
  end else if (id_ready_s) begin
    id_break_r      <= #`dly break_s;
    id_pc_r         <= #`dly if_pc_r;
    id_next_pc_r    <= #`dly if_next_pc_s;
    id_rd_index_r   <= #`dly id_rd_index_s;
    id_csr_addr_r   <= #`dly id_csr_addr_s;
    id_imm_r        <= #`dly id_imm_s;
    id_a_signed_r   <= #`dly id_a_signed_s;
    id_b_signed_r   <= #`dly id_b_signed_s;
    id_op_imm_r     <= #`dly id_op_imm_s;
    id_alu_op_r     <= #`dly id_alu_op_s;
    id_mem_rd_r     <= #`dly load_s;
    id_mem_wr_r     <= #`dly store_s;
    id_mem_signed_r <= #`dly id_mem_signed_s;
    id_mem_size_r   <= #`dly id_mem_size_s;
    id_branch_r     <= #`dly id_branch_s;
    id_reg_jump_r   <= #`dly jalr_s;
    id_lock_r       <= #`dly id_illegal_s;
    id_csrrw_r      <= #`dly csrrw_s;
    id_irq_r        <= #`dly irq_hot_s;
    id_mret_r       <= #`dly mret_s;
  end
end


/*------------------------------------------------------------------------------
--  Execute Pipeline Registers
------------------------------------------------------------------------------*/

always @(posedge clk_i or negedge rst_an_i) begin : proc_ex
  if (rst_an_i == 1'b0) begin
    ex_rd_index_r   <= #`dly 5'd2; // SP
    ex_alu_res_r    <= #`dly reset_sp_p;
    ex_csrrw_r      <= #`dly 1'b0;
    ex_csr_addr_r   <= #`dly 12'h000;
    ex_mem_data_r   <= #`dly {32{1'b0}};
    ex_mem_rd_r     <= #`dly 1'b0;
    ex_mem_wr_r     <= #`dly 1'b0;
    ex_mem_signed_r <= #`dly 1'b0;
    ex_mem_size_r   <= #`dly SIZE_BYTE;
  end else if (ex_clear_s) begin
    ex_rd_index_r   <= #`dly 5'd0; //different to rst_an_i state on pupose
    ex_alu_res_r    <= #`dly {32{1'b0}}; //different to rst_an_i state on pupose
    ex_csrrw_r      <= #`dly 1'b0;
    ex_csr_addr_r   <= #`dly 12'h000;
    ex_mem_data_r   <= #`dly {32{1'b0}};
    ex_mem_rd_r     <= #`dly 1'b0;
    ex_mem_wr_r     <= #`dly 1'b0;
    ex_mem_signed_r <= #`dly 1'b0;
    ex_mem_size_r   <= #`dly SIZE_BYTE;
  end else if (ex_ready_s) begin
    ex_rd_index_r   <= #`dly id_rd_index_r;
    ex_alu_res_r    <= #`dly ex_alu_res_s;
    ex_csrrw_r      <= #`dly id_csrrw_r;
    ex_csr_addr_r   <= #`dly id_csr_addr_r;
    ex_mem_data_r   <= #`dly id_rb_value_s;
    ex_mem_rd_r     <= #`dly id_mem_rd_r;
    ex_mem_wr_r     <= #`dly id_mem_wr_r;
    ex_mem_signed_r <= #`dly id_mem_signed_r;
    ex_mem_size_r   <= #`dly id_mem_size_r;
  end
end

assign riscv_reg_pc_o = if_pc_r;
assign debug_halt_data_o = debug_halt_data_r;
assign debug_halt_o = debug_halt_r;
assign lock_o =  id_lock_r;


endmodule // iot_riscv_core

`default_nettype wire
`end_keywords
