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


  logic        mul_request_s;
  logic        branch_taken_s;
  logic        adder_req_s;
  logic        sh_left_req_s;
  logic        sh_right_req_s;

  // GENERATE INLINE BEGIN muxes()
  // GENERATE INLINE END muxes


`define USE_NATIVE_MULTIPLIER
`define dly 1


`ifdef USE_NATIVE_MULTIPLIER
logic [63:0] mul_opa_a_s;
logic [63:0] mul_opa_b_s;
logic [63:0] mul_res_s;
`else // Slow sequential multiplier
logic         mul_busy_r;
logic         mul_ready_r;
logic   [4:0] mul_count_r;
logic  [63:0] mul_res_r;

logic [32:0] mul_sum_s;
logic [63:0] mul_res_s;
logic mul_request_s;
`endif

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

/*------------------------------------------------------------------------------
--  ALU
------------------------------------------------------------------------------*/

assign alu_opb_s = id_op_imm_i ? id_imm_i : id_rb_value_i;

/*------------------------------------------------------------------------------
--  Adder
------------------------------------------------------------------------------*/

assign adder_sub_s = (ALU_SUB == id_alu_op_i || ALU_SLT == id_alu_op_i || ALU_SLTU == id_alu_op_i);
assign adder_req_s = (adder_sub_s == 1'b1) || (ALU_ADD == id_alu_op_i) || (ALU_AND == id_alu_op_i) || (ALU_OR == id_alu_op_i) || (ALU_XOR == id_alu_op_i);
assign adder_opa_s = (adder_req_s == 1'b1) ? id_ra_value_i : {32{1'b0}};
assign adder_opb_s = (adder_req_s == 1'b1) ? (adder_sub_s ? ~alu_opb_s : alu_opb_s) : {32{1'b0}};
assign adder_cin_s = (adder_sub_s == 1'b1) ? 1'b1 : 1'b0;
assign adder_n_s = adder_out_s[31];
assign adder_v_s = (adder_opa_s[31] == adder_opb_s[31]) && (adder_out_s[31] != adder_opb_s[31]);
assign adder_z_s = ({32{1'b0}} == adder_out_s);

//lint_checking LRGOPR off
//lint_checking UELOPR off
assign {adder_c_s, adder_out_s} = {1'b0, adder_opa_s} + {1'b0, adder_opb_s} + adder_cin_s;
//lint_checking UELOPR on
//lint_checking LRGOPR on

/*------------------------------------------------------------------------------
--  Shifter
------------------------------------------------------------------------------*/

assign sh_fill_s = id_a_signed_i & id_ra_value_i[31];

assign sh_left_req_s = (id_alu_op_i == ALU_SHL);
assign sh_right_req_s = (id_alu_op_i == ALU_SHR);

assign sh_left_s  = sl_4_s;
assign sh_right_s = sr_4_s;

assign sl_0_s = (sh_left_req_s == 1'b1) ? (alu_opb_s[0] ? {id_ra_value_i[30:0],1'b0} : id_ra_value_i) : {32{1'b0}};
assign sl_1_s = (sh_left_req_s == 1'b1) ? (alu_opb_s[1] ? {sl_0_s[29:0],2'h0} : sl_0_s) : {32{1'b0}};
assign sl_2_s = (sh_left_req_s == 1'b1) ? (alu_opb_s[2] ? {sl_1_s[27:0],4'h0} : sl_1_s) : {32{1'b0}};
assign sl_3_s = (sh_left_req_s == 1'b1) ? (alu_opb_s[3] ? {sl_2_s[23:0],8'h00} : sl_2_s) : {32{1'b0}};
assign sl_4_s = (sh_left_req_s == 1'b1) ? (alu_opb_s[4] ? {sl_3_s[15:0],16'h0000 } : sl_3_s) : {32{1'b0}};

assign sr_0_s = (sh_right_req_s == 1'b1) ? (alu_opb_s[0] ? {{1{sh_fill_s}},id_ra_value_i[31:1]} : id_ra_value_i) : {32{1'b0}};
assign sr_1_s = (sh_right_req_s == 1'b1) ? (alu_opb_s[1] ? {{2{sh_fill_s}},sr_0_s[31:2]} : sr_0_s) : {32{1'b0}};
assign sr_2_s = (sh_right_req_s == 1'b1) ? (alu_opb_s[2] ? {{4{sh_fill_s}},sr_1_s[31:4]} : sr_1_s) : {32{1'b0}};
assign sr_3_s = (sh_right_req_s == 1'b1) ? (alu_opb_s[3] ? {{8{sh_fill_s}},sr_2_s[31:8]} : sr_2_s) : {32{1'b0}};
assign sr_4_s = (sh_right_req_s == 1'b1) ? (alu_opb_s[4] ? {{16{sh_fill_s}},sr_3_s[31:16]} : sr_3_s) : {32{1'b0}};


/*------------------------------------------------------------------------------
--  Multiplier and Divider Common
------------------------------------------------------------------------------*/
`ifdef USE_NATIVE_MULTIPLIER
assign mul_or_div_req_s = div_request_s; // with native mult signals below onl matter for div
`else
assign mul_or_div_req_s = mul_request_s | div_request_s;
`endif

assign mul_div_negative_s = (id_a_signed_i & id_ra_value_i[31]) ^ (id_b_signed_i & id_rb_value_i[31]);
assign mul_div_a_s = (mul_or_div_req_s == 1'b1) ? ((id_a_signed_i & id_ra_value_i[31]) ? -id_ra_value_i : id_ra_value_i) : {32{1'b0}};
assign mul_div_b_s = (mul_or_div_req_s == 1'b1) ? ((id_b_signed_i & id_rb_value_i[31]) ? -id_rb_value_i : id_rb_value_i) : {32{1'b0}};

/*------------------------------------------------------------------------------
--  Multiplier
------------------------------------------------------------------------------*/

assign mul_request_s  = (ALU_MULL == id_alu_op_i || ALU_MULH == id_alu_op_i);

`ifdef USE_NATIVE_MULTIPLIER

assign mul_opa_a_s = (mul_request_s == 1'b1) ? { {32{id_a_signed_i & id_ra_value_i[31]}}, id_ra_value_i } : {64{1'b0}};
assign mul_opa_b_s = (mul_request_s == 1'b1) ? { {32{id_b_signed_i & id_rb_value_i[31]}}, id_rb_value_i } : {64{1'b0}};
//lint_checking LMULOP off
assign mul_res_s = mul_opa_a_s * mul_opa_b_s;
//lint_checking LMULOP on
assign ex_stall_mul_s = 1'b0;

`else // Slow sequential multiplier

assign mul_sum_s = { 1'b0, mul_res_r[63:32] } + { 1'b0, mul_res_r[0] ? mul_div_b_s : {32{1'b0}} };
assign mul_res_s = mul_div_negative_s ? -mul_res_r : mul_res_r;
assign ex_stall_mul_s = mul_request_s && !mul_ready_r;

always @(posedge clk_i or negedge rst_an_i) begin : proc_mul
  if (rst_an_i == 1'b0) begin
    mul_busy_r  <= #`dly 1'b0;
    mul_ready_r <= #`dly 1'b0;
    mul_count_r <= #`dly 5'd0;
    mul_res_r   <= #`dly 64'h0000000000000000;
  end else begin
    if (mul_busy_r) begin
      mul_count_r <= #`dly mul_count_r - 5'd1;
      mul_res_r   <= #`dly { mul_sum_s, mul_res_r[31:1] };

      if (mul_count_r == 5'd0) begin
        mul_busy_r  <= #`dly 1'b0;
        mul_ready_r <= #`dly 1'b1;
      end

    end else if (mul_ready_r) begin
      mul_ready_r <= #`dly 1'b0;

    end else if (mul_request_s) begin
      mul_count_r <= #`dly 5'd31;
      mul_busy_r  <= #`dly 1'b1;
      mul_res_r   <= #`dly { {32{1'b0}}, mul_div_a_s };
    end
  end
end
`endif

/*------------------------------------------------------------------------------
--  Divider
------------------------------------------------------------------------------*/

//lint_checking LRGOPR off
assign div_sub_s = { 1'b0, div_rem_r[30:0], div_quot_r[31] } - { 1'b0, mul_div_b_s };
//lint_checking LRGOPR on
assign div_quotient_s  = mul_div_negative_s ? -div_quot_r : div_quot_r;
assign div_remainder_s = mul_div_negative_s ? -div_rem_r : div_rem_r;
assign div_request_s  = (ALU_DIV == id_alu_op_i || ALU_REM == id_alu_op_i);
assign ex_stall_div_s = div_request_s & ~div_ready_r;

//lint_checking PRMFSM off
always @(posedge clk_i or negedge rst_an_i) begin : proc_div
  if (rst_an_i == 1'b0) begin
    div_busy_r  <= #`dly 1'b0;
    div_ready_r <= #`dly 1'b0;
    div_count_r <= #`dly 5'd0;
    div_quot_r  <= #`dly {32{1'b0}};
    div_rem_r   <= #`dly {32{1'b0}};
  end else begin
    if (div_busy_r) begin
      div_count_r <= #`dly div_count_r - 5'd1;
      div_quot_r  <= #`dly { div_quot_r[30:0], !div_sub_s[32] };

      if (div_sub_s[32]) begin
        div_rem_r <= #`dly { div_rem_r[30:0], div_quot_r[31] };
      end else begin
        div_rem_r <= #`dly div_sub_s[31:0];
      end

      if (div_count_r == 5'd0) begin
        div_busy_r  <= #`dly 1'b0;
        div_ready_r <= #`dly 1'b1;
      end

    end else if (div_ready_r) begin
      div_ready_r <= #`dly 1'b0;

    end else if (div_request_s) begin
      div_count_r <= #`dly 5'd31;
      div_busy_r  <= #`dly 1'b1;
      div_quot_r  <= #`dly mul_div_a_s;
      div_rem_r   <= #`dly {32{1'b0}};
    end
  end
end
//lint_checking PRMFSM on

/*------------------------------------------------------------------------------
--  ALU Result Multiplexer
------------------------------------------------------------------------------*/

always_comb begin : proc_alu_comb
  case (id_alu_op_i)
    ALU_ADD   : ex_alu_res_s = adder_out_s;
    ALU_SUB   : ex_alu_res_s = adder_out_s;
    ALU_AND   : ex_alu_res_s = id_ra_value_i & alu_opb_s;
    ALU_OR    : ex_alu_res_s = id_ra_value_i | alu_opb_s;
    ALU_XOR   : ex_alu_res_s = id_ra_value_i ^ alu_opb_s;
    ALU_SLT   : ex_alu_res_s = (adder_n_s != adder_v_s) ? 32'h00000001 : {32{1'b0}};
    ALU_SLTU  : ex_alu_res_s = (adder_c_s == 1'b0) ? 32'h00000001 : {32{1'b0}};
    ALU_SHL   : ex_alu_res_s = sh_left_s;
    ALU_SHR   : ex_alu_res_s = sh_right_s;
    ALU_MULL  : ex_alu_res_s = mul_res_s[31:0];
    ALU_MULH  : ex_alu_res_s = mul_res_s[63:32];
    ALU_DIV   : ex_alu_res_s = div_quotient_s;
    ALU_REM   : ex_alu_res_s = div_remainder_s;
    ALU_NPC   : ex_alu_res_s = id_next_pc_i;
    ALU_AUIPC : ex_alu_res_s = jump_addr_o;
    default   : ex_alu_res_s = id_ra_value_i; // ALU_RA
  endcase
end

assign ex_stall_s =  ex_stall_mul_s || ex_stall_div_s || id_break_i;


/*------------------------------------------------------------------------------
--  Jump and Branch Logic
------------------------------------------------------------------------------*/

assign branch_taken_s =
    (id_break_i == 1'b1)     ? 1'b1 :
    (id_irq_i   == 1'b1)     ? 1'b1 :
    (id_mret_i  == 1'b1)     ? 1'b1 :
    (BR_JUMP == id_branch_i) ? 1'b1 :
    (BR_EQ   == id_branch_i) ? adder_z_s :
    (BR_NE   == id_branch_i) ? !adder_z_s :
    (BR_LT   == id_branch_i) ? (adder_n_s != adder_v_s) :
    (BR_GE   == id_branch_i) ? (adder_n_s == adder_v_s) :
    (BR_LTU  == id_branch_i) ? !adder_c_s :
    (BR_GEU  == id_branch_i) ? adder_c_s : 1'b0;

assign branch_taken_o = branch_taken_s;
assign jump_addr_o = ((branch_taken_s == 1'b1) || (ALU_AUIPC == id_alu_op_i)) ? ( // any branching event
                       (id_reg_jump_i ? id_ra_value_i : // normal jump
                         (id_irq_i ? mtvec_i : // IRQ entry, jump to mtvec
                           (id_mret_i ? mepc_i : // IRQ return, jump to saved exception PC
                             id_pc_i // jumps with immediate offset from PC
                           )
                         )
                       )
                       + id_imm_i // always apply immediate offset if present
                     ) : {32{1'b0}}; // no branch, don't toggle
assign ex_alu_res_o = ex_alu_res_s;
assign ex_stall_o = ex_stall_s;

// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_alu
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
