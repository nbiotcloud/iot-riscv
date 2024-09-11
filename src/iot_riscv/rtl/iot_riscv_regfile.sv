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
// Module:     iot_riscv.iot_riscv_regfile
// Data Model: iot_riscv.iot_riscv_regfile.IotRiscvRegfileMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_regfile ( // iot_riscv.iot_riscv_regfile.IotRiscvRegfileMod
  // main_i
  input  wire         main_clk_i,
  input  wire         main_rst_an_i,   // Async Reset (Low-Active)
  output logic [31:0] id_ra_value_o,
  output logic [31:0] id_rb_value_o,
  input  wire         id_flush_i,
  input  wire         id_ready_i,
  input  wire  [4:0]  id_ra_index_i,
  input  wire  [4:0]  id_rb_index_i,
  input  wire  [31:0] fwd_data_i,
  input  wire         fwd_a_en_i,
  input  wire         fwd_b_en_i,
  // rd_i
  input  wire  [4:0]  rd_index_i,
  input  wire  [31:0] rd_value_i,
  input  wire         rd_we_i,
  output logic [31:0] riscv_reg_x0_o,
  output logic [31:0] riscv_reg_x1_o,
  output logic [31:0] riscv_reg_x2_o,
  output logic [31:0] riscv_reg_x3_o,
  output logic [31:0] riscv_reg_x4_o,
  output logic [31:0] riscv_reg_x5_o,
  output logic [31:0] riscv_reg_x6_o,
  output logic [31:0] riscv_reg_x7_o,
  output logic [31:0] riscv_reg_x8_o,
  output logic [31:0] riscv_reg_x9_o,
  output logic [31:0] riscv_reg_x10_o,
  output logic [31:0] riscv_reg_x11_o,
  output logic [31:0] riscv_reg_x12_o,
  output logic [31:0] riscv_reg_x13_o,
  output logic [31:0] riscv_reg_x14_o,
  output logic [31:0] riscv_reg_x15_o,
  output logic [31:0] riscv_reg_x16_o,
  output logic [31:0] riscv_reg_x17_o,
  output logic [31:0] riscv_reg_x18_o,
  output logic [31:0] riscv_reg_x19_o,
  output logic [31:0] riscv_reg_x20_o,
  output logic [31:0] riscv_reg_x21_o,
  output logic [31:0] riscv_reg_x22_o,
  output logic [31:0] riscv_reg_x23_o,
  output logic [31:0] riscv_reg_x24_o,
  output logic [31:0] riscv_reg_x25_o,
  output logic [31:0] riscv_reg_x26_o,
  output logic [31:0] riscv_reg_x27_o,
  output logic [31:0] riscv_reg_x28_o,
  output logic [31:0] riscv_reg_x29_o,
  output logic [31:0] riscv_reg_x30_o,
  output logic [31:0] riscv_reg_x31_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================
// GENERATE INPLACE END logic ==================================================

  logic [31:0] reg_r [0:31];

  //lint_checking FFWNSR off
  //lint_checking FFWASR off
  //Write  logic
  always @(posedge clk_i) begin : proc_reg
    if ((rd_we_i == 1'b1) && (|rd_index_i == 1'b1)) begin
      reg_r[rd_index_i] <= #`dly rd_value_i;
    end
    reg_r[0] <= #`dly 32'h00000000; // as per ISA register 0 is a hardwired zero
  end
  //lint_checking FFWASR on
  //lint_checking FFWNSR on

  // Read wrt clock and only when necessary, saves power
  always @(posedge clk_i) begin : proc_reg_value
    if ((~id_flush_i & id_ready_i) == 1'b1) begin
      //lint_checking FFWNSR off
      //lint_checking FFWASR off
      //lint_checking RSTDAT off
      id_ra_value_o   <= #`dly fwd_a_en_i ? fwd_data_i : reg_r[id_ra_index_i];
      id_rb_value_o   <= #`dly fwd_b_en_i ? fwd_data_i : reg_r[id_rb_index_i];
      //lint_checking RSTDAT on
      //lint_checking FFWASR on
      //lint_checking FFWNSR on
    end
  end

  assign riscv_reg_x0_o = reg_r[0];
  assign riscv_reg_x1_o = reg_r[1];
  assign riscv_reg_x2_o = reg_r[2];
  assign riscv_reg_x3_o = reg_r[3];
  assign riscv_reg_x4_o = reg_r[4];
  assign riscv_reg_x5_o = reg_r[5];
  assign riscv_reg_x6_o = reg_r[6];
  assign riscv_reg_x7_o = reg_r[7];
  assign riscv_reg_x8_o = reg_r[8];
  assign riscv_reg_x9_o = reg_r[9];
  assign riscv_reg_x10_o = reg_r[10];
  assign riscv_reg_x11_o = reg_r[11];
  assign riscv_reg_x12_o = reg_r[12];
  assign riscv_reg_x13_o = reg_r[13];
  assign riscv_reg_x14_o = reg_r[14];
  assign riscv_reg_x15_o = reg_r[15];
  assign riscv_reg_x16_o = reg_r[16];
  assign riscv_reg_x17_o = reg_r[17];
  assign riscv_reg_x18_o = reg_r[18];
  assign riscv_reg_x19_o = reg_r[19];
  assign riscv_reg_x20_o = reg_r[20];
  assign riscv_reg_x21_o = reg_r[21];
  assign riscv_reg_x22_o = reg_r[22];
  assign riscv_reg_x23_o = reg_r[23];
  assign riscv_reg_x24_o = reg_r[24];
  assign riscv_reg_x25_o = reg_r[25];
  assign riscv_reg_x26_o = reg_r[26];
  assign riscv_reg_x27_o = reg_r[27];
  assign riscv_reg_x28_o = reg_r[28];
  assign riscv_reg_x29_o = reg_r[29];
  assign riscv_reg_x30_o = reg_r[30];
  assign riscv_reg_x31_o = reg_r[31];




// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_regfile
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
