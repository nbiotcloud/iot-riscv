// GENERATE INPLACE BEGIN copyright() ==========================================
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
// GENERATE INPLACE END copyright ==============================================

// GENERATE INPLACE BEGIN fileheader() =========================================
//
// Module:     iot_riscv.iot_riscv_alu
// Data Model: iot_riscv.iot_riscv_alu.IotRiscvAluMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_alu #( // iot_riscv.iot_riscv_alu.IotRiscvAluMod
  parameter integer pc_size_p = 32
) (
  // main_i
  input  wire                  main_clk_i,
  input  wire                  main_rst_an_i,  // Async Reset (Low-Active)
  input  wire                  id_op_imm_i,
  input  wire  [31:0]          id_imm_i,
  input  wire  [31:0]          id_rb_value_i,
  input  wire  [31:0]          id_ra_value_i,
  input  wire  [3:0]           id_alu_op_i,
  input  wire                  id_a_signed_i,
  input  wire                  id_b_signed_i,
  input  wire                  id_break_i,
  input  wire  [pc_size_p-1:0] id_pc_i,
  input  wire                  id_irq_i,
  input  wire                  id_mret_i,
  input  wire  [31:0]          mtvec_i,
  input  wire  [31:0]          mepc_i,
  input  wire  [pc_size_p-1:0] id_next_pc_i,
  input  wire  [2:0]           id_branch_i,
  input  wire                  id_reg_jump_i,
  output logic                 branch_taken_o,
  output logic [31:0]          jump_addr_o,
  output logic [31:0]          ex_alu_res_o,
  output logic                 ex_stall_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic [31:0] alu_opb_s;
logic [31:0] adder_opa_s;
logic [31:0] adder_opb_s;
logic        adder_sub_s;
logic        adder_cin_s;
logic        adder_n_s;
logic        adder_v_s;
logic        adder_z_s;
logic [31:0] adder_out_s;
logic        adder_c_s;
logic        sh_fill_s;
logic [31:0] sh_left_s;
logic [31:0] sh_right_s;
logic [31:0] sl_0_s;
logic [31:0] sr_0_s;
logic [31:0] sl_1_s;
logic [31:0] sr_1_s;
logic [31:0] sl_2_s;
logic [31:0] sr_2_s;
logic [31:0] sl_3_s;
logic [31:0] sr_3_s;
logic [31:0] sl_4_s;
logic [31:0] sr_4_s;
logic        mul_div_negative_s;
logic [31:0] mul_div_a_s;
logic [31:0] mul_div_b_s;
logic        ex_stall_mul_s;
logic [32:0] div_sub_s;
logic [31:0] div_quotient_s;
logic [31:0] div_remainder_s;
logic        div_request_s;
logic        ex_stall_div_s;
logic        div_busy_r;
logic        div_ready_r;
logic [4:0]  div_count_r;
logic [31:0] div_rem_r;
logic [31:0] div_quot_r;
logic [31:0] ex_alu_res_s;
logic        ex_stall_s;
// GENERATE INPLACE END logic ==================================================





// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_alu
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
