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
// Module:     iot_riscv.iot_riscv_lsu
// Data Model: iot_riscv.iot_riscv_lsu.IotRiscvLsuMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_lsu ( // iot_riscv.iot_riscv_lsu.IotRiscvLsuMod
  // main_i
  input  wire         main_clk_i,
  input  wire         main_rst_an_i,    // Async Reset (Low-Active)
  input  wire  [31:0] ex_alu_res_i,
  input  wire  [31:0] ex_mem_data_i,
  input  wire  [1:0]  ex_mem_size_i,
  input  wire         ex_mem_signed_i,
  input  wire         ex_mem_rd_i,
  input  wire         ex_mem_wr_i,
  input  wire  [31:0] csr_rd_value_i,
  input  wire  [4:0]  ex_rd_index_i,
  input  wire         ex_csrrw_i,
  output logic        mem_stall_o,
  output logic        mem_stall_comb_o,
  // d_o
  output logic        d_rd_o,
  output logic [31:0] d_addr_o,
  output logic [31:0] d_wdata_o,
  output logic        d_wr_o,
  input  wire         d_rdy_i,
  input  wire         d_grant_i,
  input  wire  [31:0] d_rdata_i,
  output logic [1:0]  d_size_o,
  // rd_o
  output logic [4:0]  rd_index_o,
  output logic [31:0] rd_value_o,
  output logic        rd_we_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic        mem_access_s;
logic        mem_stall_s;
logic        mem_stall_r;
logic [31:0] mem_rdata_s;
// GENERATE INPLACE END logic ==================================================

  logic        mem_rd_type_r;
  logic        mem_wr_type_r;
  logic        mem_stall_comb_s;

  localparam SIZE_BYTE = 2'd0;
  localparam SIZE_HALF = 2'd1;
  localparam SIZE_WORD = 2'd2;
  /*------------------------------------------------------------------------------
  --  Memory
  ------------------------------------------------------------------------------*/

  assign d_addr_o  = ex_alu_res_i;
  assign d_wdata_o = ex_mem_data_i;
  assign d_size_o  = ex_mem_size_i;
  assign d_rd_o    = ex_mem_rd_i && (mem_rd_type_r == 1'b0); //&& run_en_i;
  assign d_wr_o    = ex_mem_wr_i; //&& run_en_i;

  assign mem_rdata_s =
    (SIZE_BYTE == ex_mem_size_i) ? { {24{ex_mem_signed_i & d_rdata_i[7]}}, d_rdata_i[7:0] } :
    (SIZE_HALF == ex_mem_size_i) ? { {16{ex_mem_signed_i & d_rdata_i[15]}}, d_rdata_i[15:0] } : d_rdata_i;

  //lint_checking PRMFSM off
  always @(posedge clk_i or negedge rst_an_i) begin : proc_mem_stall
    if (rst_an_i == 1'b0) begin
      mem_stall_r <= #`dly 1'b0;
      mem_rd_type_r <= #`dly 1'b0;
      mem_wr_type_r <= #`dly 1'b0;
    end else if (mem_access_s & ~mem_rd_type_r) begin  // do not allow interleaved reads
      mem_stall_r <= #`dly 1'b1;
      mem_wr_type_r <= #`dly ex_mem_wr_i;
      mem_rd_type_r <= #`dly ex_mem_rd_i;
    end else if (d_rdy_i) begin
      mem_stall_r <= #`dly 1'b0;
      mem_rd_type_r <= #`dly 1'b0;
      mem_wr_type_r <= #`dly 1'b0;
    end
  end
  //lint_checking PRMFSM on

  assign mem_access_s = ((ex_mem_rd_i) | (ex_mem_wr_i)) & d_grant_i;

  //lint_checking PTRMST off
  //lint_checking PUNRCS off
  //lint_checking VARTRN off
  assign mem_stall_s  = mem_stall_r ? ~d_rdy_i : (ex_mem_rd_i | (ex_mem_wr_i & ~d_grant_i));
  //lint_checking PTRMST on
  //lint_checking PUNRCS on
  //lint_checking VARTRN on

  /*------------------------------------------------------------------------------
  --  Writeback
  ------------------------------------------------------------------------------*/

  //regular registers
  assign rd_index_o = ex_rd_index_i;
  assign rd_value_o = mem_rd_type_r ? mem_rdata_s : (ex_csrrw_i ? csr_rd_value_i : ex_alu_res_i);
  assign rd_we_o    = (ex_rd_index_i != 5'd0) && (mem_stall_comb_s == 1'b0);
  assign mem_stall_o = mem_stall_r;
  assign mem_stall_comb_s = mem_stall_s | (ex_mem_rd_i & d_grant_i);
  assign mem_stall_comb_o = mem_stall_comb_s;




// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_lsu
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
