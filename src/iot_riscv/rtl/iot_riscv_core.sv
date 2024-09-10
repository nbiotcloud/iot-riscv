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
  parameter logic [31:0] pc_size_p   = 32'h00000020,
  parameter logic [31:0] reset_sp_p  = 32'h00002000,
  parameter logic [31:0] reset_vec_p = 32'h00000000
) (
  // main_i
  input  wire         main_clk_i,
  input  wire         main_rst_an_i,     // Async Reset (Low-Active)
  output logic        lock_o,
  output logic        debug_halt_o,
  output logic        debug_halt_data_o,
  output logic [31:0] mscratch_o,
  output logic [31:0] mepc_o,
  output logic [31:0] mtvec_o
);


endmodule // iot_riscv_core

`default_nettype wire
`end_keywords
