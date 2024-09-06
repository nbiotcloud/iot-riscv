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
// Module:     iot_riscv.iot_riscv_decoder
// Data Model: iot_riscv.iot_riscv_decoder.IotRiscvDecoderMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_decoder ( // iot_riscv.iot_riscv_decoder.IotRiscvDecoderMod
  input  wire  [31:0] rv_op_i,
  output logic        break_o,
  output logic [4:0]  id_rd_index_o,
  output logic [11:0] id_csr_addr_o,
  output logic [31:0] id_imm_o,
  output logic        id_a_signed_o,
  output logic        id_b_signed_o,
  output logic        id_op_imm_o,
  output logic [3:0]  id_alu_op_o,
  output logic        load_o,
  output logic        store_o,
  output logic        id_mem_signed_o,
  output logic [1:0]  id_mem_size_o,
  output logic [2:0]  id_branch_o,
  output logic        id_reg_jump_o,
  output logic        id_lock_o,
  output logic        id_csrrw_o,
  output logic        id_mret_o,
  output logic [4:0]  id_ra_index_o,
  output logic [4:0]  id_rb_index_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic [31:0] if_opcode_s;
logic [6:0]  op_s;
logic [4:0]  rd_s;
logic [2:0]  f3_s;
logic [4:0]  ra_s;
logic [4:0]  rb_s;
logic [6:0]  f7_s;
logic        op_branch_s;
logic        op_load_s;
logic        op_store_s;
logic        op_alu_imm_s;
logic        op_alu_reg_s;
logic        op_system_s;
logic        op_f7_main_s;
logic        op_f7_alt_s;
logic        op_f7_mul_s;
logic        lui_s;
logic        auipc_s;
logic        jal_s;
logic        jalr_s;
logic        beq_s;
logic        bne_s;
logic        blt_s;
logic        bge_s;
logic        bltu_s;
logic        bgeu_s;
logic        lb_s;
logic        lh_s;
logic        lw_s;
logic        lbu_s;
logic        lhu_s;
logic        sb_s;
logic        sh_s;
logic        sw_s;
logic        addi_s;
logic        slti_s;
logic        sltiu_s;
logic        xori_s;
logic        ori_s;
logic        andi_s;
logic        slli_s;
logic        srli_s;
logic        srai_s;
logic        add_s;
logic        sub_s;
logic        slt_s;
logic        sltu_s;
logic        xor_s;
logic        or_s;
logic        and_s;
logic        sll_s;
logic        srl_s;
logic        sra_s;
logic        mul_s;
logic        mulh_s;
logic        mulhsu_s;
logic        mulhu_s;
logic        div_s;
logic        divu_s;
logic        rem_s;
logic        remu_s;
logic        break_s;
logic        csrrw_s;
logic        mret_s;
logic        load_s;
logic        store_s;
logic        alu_imm_s;
logic        alu_reg_s;
logic        branch_s;
logic        jump_s;
logic        system_s;
logic        id_illegal_s;
logic [31:0] id_i_imm_s;
logic [31:0] id_s_imm_s;
logic [31:0] id_b_imm_s;
logic [31:0] id_u_imm_s;
logic [31:0] id_j_imm_s;
logic [31:0] id_imm_s;
logic [4:0]  id_rd_index_s;
logic [11:0] id_csr_addr_s;
logic [4:0]  id_ra_index_s;
logic [4:0]  id_rb_index_s;
logic [3:0]  id_alu_op_s;
logic [2:0]  id_branch_s;
logic [1:0]  id_mem_size_s;
// GENERATE INPLACE END logic ==================================================


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


assign if_opcode_s = rv_op_i;

assign op_s = if_opcode_s[6:0];
assign rd_s = if_opcode_s[11:7];
assign f3_s = if_opcode_s[14:12];
assign ra_s = if_opcode_s[19:15];
assign rb_s = if_opcode_s[24:20];
assign f7_s = if_opcode_s[31:25];

assign op_branch_s  = (7'b1100011 == op_s);
assign op_load_s    = (7'b0000011 == op_s);
assign op_store_s   = (7'b0100011 == op_s);
assign op_alu_imm_s = (7'b0010011 == op_s);
assign op_alu_reg_s = (7'b0110011 == op_s);
assign op_system_s =  (7'b1110011 == op_s);

assign op_f7_main_s = (7'b0000000 == f7_s);
assign op_f7_alt_s  = (7'b0100000 == f7_s);
assign op_f7_mul_s  = (7'b0000001 == f7_s);

assign lui_s    = (7'b0110111 == op_s);
assign auipc_s  = (7'b0010111 == op_s);
assign jal_s    = (7'b1101111 == op_s);
assign jalr_s   = (7'b1100111 == op_s) && (3'b000 == f3_s);

assign beq_s    = op_branch_s  && (3'b000 == f3_s);
assign bne_s    = op_branch_s  && (3'b001 == f3_s);
assign blt_s    = op_branch_s  && (3'b100 == f3_s);
assign bge_s    = op_branch_s  && (3'b101 == f3_s);
assign bltu_s   = op_branch_s  && (3'b110 == f3_s);
assign bgeu_s   = op_branch_s  && (3'b111 == f3_s);

assign lb_s     = op_load_s    && (3'b000 == f3_s);
assign lh_s     = op_load_s    && (3'b001 == f3_s);
assign lw_s     = op_load_s    && (3'b010 == f3_s);
assign lbu_s    = op_load_s    && (3'b100 == f3_s);
assign lhu_s    = op_load_s    && (3'b101 == f3_s);

assign sb_s     = op_store_s   && (3'b000 == f3_s);
assign sh_s     = op_store_s   && (3'b001 == f3_s);
assign sw_s     = op_store_s   && (3'b010 == f3_s);

assign addi_s   = op_alu_imm_s && (3'b000 == f3_s);
assign slti_s   = op_alu_imm_s && (3'b010 == f3_s);
assign sltiu_s  = op_alu_imm_s && (3'b011 == f3_s);
assign xori_s   = op_alu_imm_s && (3'b100 == f3_s);
assign ori_s    = op_alu_imm_s && (3'b110 == f3_s);
assign andi_s   = op_alu_imm_s && (3'b111 == f3_s);
assign slli_s   = op_alu_imm_s && (3'b001 == f3_s) && op_f7_main_s;
assign srli_s   = op_alu_imm_s && (3'b101 == f3_s) && op_f7_main_s;
assign srai_s   = op_alu_imm_s && (3'b101 == f3_s) && op_f7_alt_s;

assign add_s    = op_alu_reg_s && (3'b000 == f3_s) && op_f7_main_s;
assign sub_s    = op_alu_reg_s && (3'b000 == f3_s) && op_f7_alt_s;
assign slt_s    = op_alu_reg_s && (3'b010 == f3_s) && op_f7_main_s;
assign sltu_s   = op_alu_reg_s && (3'b011 == f3_s) && op_f7_main_s;
assign xor_s    = op_alu_reg_s && (3'b100 == f3_s) && op_f7_main_s;
assign or_s     = op_alu_reg_s && (3'b110 == f3_s) && op_f7_main_s;
assign and_s    = op_alu_reg_s && (3'b111 == f3_s) && op_f7_main_s;
assign sll_s    = op_alu_reg_s && (3'b001 == f3_s) && op_f7_main_s;
assign srl_s    = op_alu_reg_s && (3'b101 == f3_s) && op_f7_main_s;
assign sra_s    = op_alu_reg_s && (3'b101 == f3_s) && op_f7_alt_s;

assign mul_s    = op_alu_reg_s && (3'b000 == f3_s) && op_f7_mul_s;
assign mulh_s   = op_alu_reg_s && (3'b001 == f3_s) && op_f7_mul_s;
assign mulhsu_s = op_alu_reg_s && (3'b010 == f3_s) && op_f7_mul_s;
assign mulhu_s  = op_alu_reg_s && (3'b011 == f3_s) && op_f7_mul_s;
assign div_s    = op_alu_reg_s && (3'b100 == f3_s) && op_f7_mul_s;
assign divu_s   = op_alu_reg_s && (3'b101 == f3_s) && op_f7_mul_s;
assign rem_s    = op_alu_reg_s && (3'b110 == f3_s) && op_f7_mul_s;
assign remu_s   = op_alu_reg_s && (3'b111 == f3_s) && op_f7_mul_s;

assign break_s  = op_system_s && (3'b000 == f3_s) && (5'b00001 == rb_s) && op_f7_main_s;
assign csrrw_s  = (op_system_s && (3'b001 == f3_s));
assign mret_s   = op_system_s && (3'b000 == f3_s) && (5'b00010 == rb_s) && (7'b0011000 == f7_s);



//-----------------------------------------------------------------------------

assign load_s    = lb_s || lh_s || lw_s || lbu_s || lhu_s;
assign store_s   = sb_s || sh_s || sw_s;

assign alu_imm_s = addi_s || slti_s || sltiu_s || xori_s || ori_s || andi_s ||
                 slli_s || srli_s || srai_s || lui_s || auipc_s;

assign alu_reg_s = add_s || sub_s || slt_s || sltu_s || xor_s || or_s || and_s ||
                 sll_s || srl_s || sra_s || mul_s || mulh_s || mulhsu_s ||
                 mulhu_s || div_s || divu_s || rem_s || remu_s;

assign branch_s  = beq_s || bne_s || blt_s || bge_s || bltu_s || bgeu_s;
assign jump_s    = jal_s || jalr_s;
assign system_s  = break_s || csrrw_s || mret_s;

assign id_illegal_s = !(load_s || store_s || alu_imm_s || alu_reg_s || jump_s || branch_s || system_s);

assign id_i_imm_s = { {20{if_opcode_s[31]}}, if_opcode_s[31:20] };
assign id_s_imm_s = { {20{if_opcode_s[31]}}, if_opcode_s[31:25], if_opcode_s[11:7] };
assign id_b_imm_s = { {19{if_opcode_s[31]}}, if_opcode_s[31], if_opcode_s[7], if_opcode_s[30:25], if_opcode_s[11:8], 1'b0 };
assign id_u_imm_s = { if_opcode_s[31:12], 12'h000 };
assign id_j_imm_s = { {11{if_opcode_s[31]}}, if_opcode_s[31], if_opcode_s[19:12], if_opcode_s[20], if_opcode_s[30:21], 1'b0 };

assign id_imm_s =
    (lui_s || auipc_s)              ? id_u_imm_s :
    (branch_s)                      ? id_b_imm_s :
    (load_s || jalr_s || alu_imm_s) ? id_i_imm_s :
    (store_s)                       ? id_s_imm_s :
    (jal_s)                         ? id_j_imm_s : {32{1'b0}};

assign id_rd_index_s = (branch_s || store_s)           ? 5'd0 : rd_s;
assign id_ra_index_s = (lui_s || auipc_s || jal_s)     ? 5'd0 : ra_s;
assign id_rb_index_s = (load_s || jump_s || alu_imm_s) ? 5'd0 : rb_s;

assign id_csr_addr_s = (csrrw_s) ? if_opcode_s[31:20] : 12'h000;

assign id_alu_op_s =
    (add_s || addi_s || lui_s || load_s || store_s) ? ALU_ADD :
    (andi_s || and_s)                    ? ALU_AND :
    (ori_s || or_s)                      ? ALU_OR :
    (xori_s || xor_s)                    ? ALU_XOR :
    (slti_s || slt_s)                    ? ALU_SLT :
    (sltiu_s || sltu_s)                  ? ALU_SLTU :
    (sll_s || slli_s)                    ? ALU_SHL :
    (srl_s || srli_s || sra_s || srai_s) ? ALU_SHR :
    (mulh_s || mulhsu_s || mulhu_s)      ? ALU_MULH :
    (mul_s)                              ? ALU_MULL :
    (div_s || divu_s)                    ? ALU_DIV :
    (rem_s || remu_s)                    ? ALU_REM :
    (jal_s || jalr_s)                    ? ALU_NPC :
    (auipc_s)                            ? ALU_AUIPC :
    (csrrw_s)                            ? ALU_RA : ALU_SUB;

assign id_branch_s =
    beq_s  ? BR_EQ :
    bne_s  ? BR_NE :
    blt_s  ? BR_LT :
    bge_s  ? BR_GE :
    bltu_s ? BR_LTU :
    bgeu_s ? BR_GEU :
    jump_s ? BR_JUMP : BR_NONE;

assign id_mem_size_s =
    (lb_s || lbu_s || sb_s) ? SIZE_BYTE :
    (lh_s || lhu_s || sh_s) ? SIZE_HALF : SIZE_WORD;


assign break_o = break_s;
assign id_rd_index_o = id_rd_index_s;
assign id_csr_addr_o = id_csr_addr_s;
assign id_imm_o = id_imm_s;
assign id_a_signed_o = mulh_s || mulhsu_s || div_s || rem_s || sra_s || srai_s;
assign id_b_signed_o = mulh_s || div_s || rem_s;
assign id_op_imm_o = alu_imm_s || jal_s || load_s || store_s;
assign id_alu_op_o = id_alu_op_s;
assign load_o  = load_s;
assign store_o = store_s;
assign id_mem_signed_o = !lbu_s && !lhu_s;
assign id_mem_size_o = id_mem_size_s;
assign id_branch_o = id_branch_s;
assign id_reg_jump_o =  jalr_s;
assign id_lock_o     =  id_illegal_s;
assign id_csrrw_o =  csrrw_s;
assign id_mret_o = mret_s;


assign id_ra_index_o= id_ra_index_s;
assign id_rb_index_o =id_rb_index_s;



// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_decoder
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
