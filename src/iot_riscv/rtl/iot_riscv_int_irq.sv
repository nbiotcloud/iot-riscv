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
// Module:     iot_riscv.iot_riscv_int_irq
// Data Model: iot_riscv.iot_riscv_int_irq.IotRiscvIntIrqMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_int_irq #( // iot_riscv.iot_riscv_int_irq.IotRiscvIntIrqMod
  parameter integer irq_width_p = 32
) (
  // main_i
  input  wire                    main_clk_i,
  input  wire                    main_rst_an_i,       // Async Reset (Low-Active)
  input  wire                    irq_en_i,
  input  wire  [irq_width_p-1:0] irq_i,
  input  wire  [irq_width_p-1:0] irq_mask_i,
  output logic                   irq_run_en_o,
  input  wire                    debug_halt_i,
  input  wire                    debug_single_step_i,
  input  wire                    debug_halt_data_i,
  input  wire                    id_irq_i,
  input  wire                    id_mret_i,
  output logic                   irq_hot_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic irq_masked_s;
logic irq_hot_s;
logic dly_irq_hot_r;
logic in_irq_r;
// GENERATE INPLACE END logic ==================================================


  /*------------------------------------------------------------------------------
  --  IRQ Indicator
  ------------------------------------------------------------------------------*/

  // hold irq hot signal one clk more for step cases
  always @(posedge clk_i or negedge rst_an_i) begin : proc_irq_hot
    if (rst_an_i == 1'b0) begin
      dly_irq_hot_r <= #`dly 1'b0;
    end else begin
      dly_irq_hot_r <= #`dly (irq_hot_s & debug_single_step_i);
    end
  end

  always @(posedge clk_i or negedge rst_an_i) begin : proc_irq
    if (rst_an_i == 1'b0) begin
      in_irq_r <= #`dly 1'b0;
    end else begin
      if ((in_irq_r == 1'b0) && (id_irq_i == 1'b1)) begin
        in_irq_r <= #`dly irq_hot_s | dly_irq_hot_r;
      end else if (id_mret_i == 1'b1) begin
        in_irq_r <= #`dly 1'b0;
      end
    end
  end
  /*------------------------------------------------------------------------------
  --  IRQ signals
  ------------------------------------------------------------------------------*/

  assign irq_masked_s = |(irq_i & irq_mask_i);
  //this explicitly ignores the state of global interrupt disable to avoid a race condition
  //where software could lock itself into a WAITI with IRQs globally disabled
  assign irq_run_en_o = irq_masked_s;

  //lint_checking REDOPR off
  assign irq_hot_s = irq_masked_s & irq_en_i & ~in_irq_r & ((~debug_halt_i) | debug_single_step_i) &  (~debug_halt_data_i);
  //lint_checking REDOPR on
  // GENERATE INLINE BEGIN muxes()
  // GENERATE INLINE END muxes
  assign irq_hot_o = irq_hot_s;



// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_int_irq
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
