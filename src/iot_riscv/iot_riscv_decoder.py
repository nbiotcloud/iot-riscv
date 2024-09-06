#
# MIT License
#
# Copyright (c) 2024 nbiotcloud
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

import ucdp as u

class IotRiscvDecoderMod(u.AMod):
    filelists: u.ClassVar[u.ModFileLists] = (
        u.ModFileList(
            name="hdl",
            # full, inplace, no
            gen="inplace",
            filepaths=("rtl/{mod.modname}.sv"),
            template_filepaths=("sv.mako",),
        ),
    )    

    def _build(self):
        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.UintType(32, default=0x00000000), "rv_op_i", title="Unsigned Input")
        self.add_port(u.BitType(), "break_o")
        self.add_port(u.UintType(5, default=0x0), "id_rd_index_o")
        self.add_port(u.UintType(12, default=0x000), "id_csr_addr_o")
        self.add_port(u.UintType(32, default=0x00000000), "id_imm_o")
        self.add_port(u.BitType(), "id_a_signed_o")
        self.add_port(u.BitType(), "id_b_signed_o")
        self.add_port(u.BitType(), "id_op_imm_o")
        self.add_port(u.UintType(4, default=0x00000000), "id_alu_op_o")
        self.add_port(u.BitType(), "load_o")
        self.add_port(u.BitType(), "store_o")
        self.add_port(u.BitType(), "id_mem_signed_o")
        self.add_port(u.UintType(2, default=0x0), "id_mem_size_o")
        self.add_port(u.UintType(3, default=0x0), "id_branch_o")
        self.add_port(u.BitType(), "id_reg_jump_o")
        self.add_port(u.BitType(), "id_lock_o")
        self.add_port(u.BitType(), "id_csrrw_o")
        self.add_port(u.BitType(), "id_mret_o")
        self.add_port(u.UintType(5, default=0x0), "id_ra_index_o")
        self.add_port(u.UintType(5, default=0x0), "id_rb_index_o")

        # -----------------------------
        # Signal List
        # -----------------------------
        self.add_signal(u.UintType(32, default=0x0000), "if_opcode_s")
        self.add_signal(u.UintType(7, default=0x0000), "op_s")
        self.add_signal(u.UintType(5, default=0x0000), "rd_s")
        self.add_signal(u.UintType(3, default=0x0000), "f3_s")
        self.add_signal(u.UintType(5, default=0x0000), "ra_s")
        self.add_signal(u.UintType(5, default=0x0000), "rb_s")
        self.add_signal(u.UintType(7, default=0x0000), "f7_s")
        self.add_signal(u.BitType(), "op_branch_s")
        self.add_signal(u.BitType(), "op_load_s")
        self.add_signal(u.BitType(), "op_store_s")
        self.add_signal(u.BitType(), "op_alu_imm_s")
        self.add_signal(u.BitType(), "op_alu_reg_s")
        self.add_signal(u.BitType(), "op_system_s")
        self.add_signal(u.BitType(), "op_f7_main_s")
        self.add_signal(u.BitType(), "op_f7_alt_s")
        self.add_signal(u.BitType(), "op_f7_mul_s")

        self.add_signal(u.BitType(), "lui_s")
        self.add_signal(u.BitType(), "auipc_s")
        self.add_signal(u.BitType(), "jal_s")
        self.add_signal(u.BitType(), "jalr_s")
        self.add_signal(u.BitType(), "beq_s")
        self.add_signal(u.BitType(), "bne_s")
        self.add_signal(u.BitType(), "blt_s")
        self.add_signal(u.BitType(), "bge_s")
        self.add_signal(u.BitType(), "bltu_s")

        self.add_signal(u.BitType(), "bgeu_s")
        self.add_signal(u.BitType(), "lb_s")
        self.add_signal(u.BitType(), "lh_s")
        self.add_signal(u.BitType(), "lw_s")
        self.add_signal(u.BitType(), "lbu_s")
        self.add_signal(u.BitType(), "lhu_s")
        self.add_signal(u.BitType(), "sb_s")
        self.add_signal(u.BitType(), "sh_s")
        self.add_signal(u.BitType(), "sw_s")

        self.add_signal(u.BitType(), "addi_s")
        self.add_signal(u.BitType(), "slti_s")
        self.add_signal(u.BitType(), "sltiu_s")
        self.add_signal(u.BitType(), "xori_s")
        self.add_signal(u.BitType(), "ori_s")
        self.add_signal(u.BitType(), "andi_s")
        self.add_signal(u.BitType(), "slli_s")
        self.add_signal(u.BitType(), "srli_s")
        self.add_signal(u.BitType(), "srai_s")

        self.add_signal(u.BitType(), "add_s")
        self.add_signal(u.BitType(), "sub_s")
        self.add_signal(u.BitType(), "slt_s")
        self.add_signal(u.BitType(), "sltu_s")
        self.add_signal(u.BitType(), "xor_s")
        self.add_signal(u.BitType(), "or_s")
        self.add_signal(u.BitType(), "and_s")
        self.add_signal(u.BitType(), "sll_s")
        self.add_signal(u.BitType(), "srl_s")

        self.add_signal(u.BitType(), "sra_s")
        self.add_signal(u.BitType(), "mul_s")
        self.add_signal(u.BitType(), "mulh_s")
        self.add_signal(u.BitType(), "mulhsu_s")
        self.add_signal(u.BitType(), "mulhu_s")
        self.add_signal(u.BitType(), "div_s")
        self.add_signal(u.BitType(), "divu_s")
        self.add_signal(u.BitType(), "rem_s")
        self.add_signal(u.BitType(), "remu_s")

        self.add_signal(u.BitType(), "break_s")
        self.add_signal(u.BitType(), "csrrw_s")
        self.add_signal(u.BitType(), "mret_s")

        self.add_signal(u.BitType(), "load_s")
        self.add_signal(u.BitType(), "store_s")
        self.add_signal(u.BitType(), "alu_imm_s")
        self.add_signal(u.BitType(), "alu_reg_s")

        self.add_signal(u.BitType(), "branch_s")
        self.add_signal(u.BitType(), "jump_s")
        self.add_signal(u.BitType(), "system_s")
        self.add_signal(u.BitType(), "id_illegal_s")

        self.add_signal(u.UintType(32, default=0x0000), "id_i_imm_s")
        self.add_signal(u.UintType(32, default=0x0000), "id_s_imm_s")
        self.add_signal(u.UintType(32, default=0x0000), "id_b_imm_s")
        self.add_signal(u.UintType(32, default=0x0000), "id_u_imm_s")

        self.add_signal(u.UintType(32, default=0x0000), "id_j_imm_s")
        self.add_signal(u.UintType(32, default=0x0000), "id_imm_s")
        self.add_signal(u.UintType(5, default=0x0000), "id_rd_index_s")
        self.add_signal(u.UintType(12, default=0x0000), "id_csr_addr_s")

        self.add_signal(u.UintType(5, default=0x0000), "id_ra_index_s")

        self.add_signal(u.UintType(5, default=0x0000), "id_rb_index_s")
        self.add_signal(u.UintType(4, default=0x0000), "id_alu_op_s")
        self.add_signal(u.UintType(3, default=0x0000), "id_branch_s")
        self.add_signal(u.UintType(2, default=0x0000), "id_mem_size_s")
