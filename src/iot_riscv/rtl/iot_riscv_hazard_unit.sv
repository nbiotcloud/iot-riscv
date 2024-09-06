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
// Module:     iot_riscv.iot_riscv_hazard_unit
// Data Model: iot_riscv.iot_riscv_hazard_unit.IotRiscvHazardUnitMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_hazard_unit ( // iot_riscv.iot_riscv_hazard_unit.IotRiscvHazardUnitMod
  input  wire         ex_stall_i,
  input  wire  [31:0] alu_res_i,
  input  wire         id_csrrw_i,
  input  wire         id_mem_rd_i,
  input  wire  [4:0]  exe_rd_index_i,
  input  wire         mem_stall_i,
  input  wire  [4:0]  mem_rd_index_i,
  input  wire  [31:0] mem_rd_value_i,
  input  wire  [4:0]  id_ra_index_i,
  input  wire  [4:0]  id_rb_index_i,
  input  wire         branch_taken_i,
  input  wire         id_lock_i,
  input  wire         if_valid_i,
  input  wire         if_hold_state_i,
  output logic        id_ready_o,
  output logic        ex_ready_o,
  output logic        id_clear_o,
  output logic        ex_clear_o,
  output logic        hazard_o,
  output logic [31:0] fwd_data_o,
  output logic        fwd_a_en_o,
  output logic        fwd_b_en_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================
// GENERATE INPLACE END logic ==================================================

  logic if_ready_s;
  logic exe_a_dep_s;
  logic exe_b_dep_s;
  logic mem_rd_a_dep_s;
  logic mem_rd_b_dep_s;
  logic exe_and_mem_dep_s;

  // This module checks for hazards in pipeline logic and performs the necessary actions.
  // Possible Hazards in Pipeline designs
  // 1. Data Hazards : Due to data dependencies from future stages which aren't completed.
  //  Here, only Read after write(RAW) Hazards possible and forwarding procedure ís used to check this.
  // WAR and WAW Hazards are not possible in In-order pipelines.
  // 2. Control Hazards - Happens due to branches and need to flush the decode stage to work on new
  // Instruction.
  // 3. Structural Hazards - Not póssible in this design as we halt the previous stages when the core is busy.

  //helper signals
  assign exe_a_dep_s = id_ra_index_i == exe_rd_index_i ? |(exe_rd_index_i) : 1'b0;
  assign exe_b_dep_s = id_rb_index_i == exe_rd_index_i ? |(exe_rd_index_i) : 1'b0;
  assign mem_rd_a_dep_s = id_ra_index_i == mem_rd_index_i ? |(mem_rd_index_i) : 1'b0;
  assign mem_rd_b_dep_s = id_rb_index_i == mem_rd_index_i ? |(mem_rd_index_i) : 1'b0;

  //needed to detect if there are two stacked dependencies in mem and execution stage, then we need to halt 1 cycle
  assign exe_and_mem_dep_s = (exe_a_dep_s | exe_b_dep_s) & (mem_rd_a_dep_s | mem_rd_b_dep_s);

  //Forwarding procedure for data dependencies.
  always_comb begin : proc_forwarding
    fwd_data_o = 32'd0;
    fwd_a_en_o = 1'd0;
    fwd_b_en_o = 1'd0;
    // TODO check if the if_valid_i is really needed
    if (!mem_stall_i && if_valid_i && (mem_rd_a_dep_s || mem_rd_b_dep_s))  begin
      fwd_a_en_o = mem_rd_a_dep_s;
      fwd_b_en_o = mem_rd_b_dep_s;
      fwd_data_o = mem_rd_value_i;
    // TODO check if the if_valid_i is really needed
    end else if (!(id_csrrw_i || id_mem_rd_i) && (exe_a_dep_s || exe_b_dep_s) && !ex_stall_i && if_valid_i) begin
      fwd_a_en_o = exe_a_dep_s;
      fwd_b_en_o = exe_b_dep_s;
      fwd_data_o = alu_res_i;
    end else begin
      fwd_data_o = 32'd0;
      fwd_a_en_o = 1'd0;
      fwd_b_en_o = 1'd0;
    end
  end

  // clear and ready signals for the pipeline registers
  always_comb begin : proc_hazard
    if_ready_s = 1'b1;
    id_ready_o = 1'b1;
    ex_ready_o = 1'b1;
    id_clear_o = 1'b0;
    ex_clear_o = 1'b0;

    // Stalls when ALU/memory is busy.
    if (mem_stall_i) begin
      if_ready_s = 1'b0;
      id_ready_o = 1'b0;
      ex_ready_o = 1'b0;
    end else if (ex_stall_i || id_lock_i) begin
      if_ready_s = 1'b0;
      id_ready_o = 1'b0;
      ex_clear_o = 1'b1;
    end else if (((id_csrrw_i || id_mem_rd_i) && (exe_a_dep_s || exe_b_dep_s)) || exe_and_mem_dep_s) begin
      if_ready_s = 1'b0;
      id_clear_o = 1'b1;
    end else if (branch_taken_i || if_hold_state_i || !if_valid_i) begin
      id_clear_o = 1'b1;
      id_ready_o = 1'b0;
    end else begin
      if_ready_s = 1'b1;
      id_ready_o = 1'b1;
      ex_ready_o = 1'b1;
      id_clear_o = 1'b0;
      ex_clear_o = 1'b0;
    end
  end

  assign hazard_o = !if_ready_s;





// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_hazard_unit
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
