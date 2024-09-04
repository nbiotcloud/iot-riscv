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


class IotRiscvAluMod(u.AMod):
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
        # Parameter List
        # -----------------------------
        pcwidth_p = self.add_param(u.IntegerType(default=32), "pc_size_p", title="PC Width.")

        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        self.add_port(
            u.BitType(),
            "id_op_imm_i",
        )
        self.add_port(u.UintType(32), "id_imm_i")
        self.add_port(u.UintType(32), "id_rb_value_i")
        self.add_port(u.UintType(32), "id_ra_value_i")
        self.add_port(u.UintType(4), "id_alu_op_i")
        self.add_port(u.BitType(), "id_a_signed_i")
        self.add_port(u.BitType(), "id_b_signed_i")
        self.add_port(u.BitType(), "id_break_i")
        self.add_port(u.UintType(pcwidth_p), "id_pc_i")
        self.add_port(u.BitType(), "id_irq_i")
        self.add_port(u.BitType(), "id_mret_i")
        self.add_port(u.UintType(32), "mtvec_i")
        self.add_port(u.UintType(32), "mepc_i")

        self.add_port(u.UintType(pcwidth_p), "id_next_pc_i")
        self.add_port(u.UintType(3), "id_branch_i")
        self.add_port(u.BitType(), "id_reg_jump_i")
        self.add_port(u.BitType(), "branch_taken_o")
        self.add_port(u.UintType(32), "jump_addr_o")
        self.add_port(u.UintType(32), "ex_alu_res_o")
        self.add_port(u.BitType(), "ex_stall_o")
        # -----------------------------
        # signal List
        # -----------------------------
        self.add_signal(u.UintType(32), "alu_opb_s")

        self.add_signal(u.UintType(32), "adder_opa_s")
        self.add_signal(u.UintType(32), "adder_opb_s")

        self.add_signal(u.BitType(), "adder_sub_s")
        self.add_signal(u.BitType(), "adder_cin_s")
        self.add_signal(u.BitType(), "adder_n_s")
        self.add_signal(u.BitType(), "adder_v_s")
        self.add_signal(u.BitType(), "adder_z_s")
        self.add_signal(u.UintType(32), "adder_out_s")
        self.add_signal(u.BitType(), "adder_c_s")
        # SHIFTER
        self.add_signal(u.BitType(), "sh_fill_s")
        self.add_signal(u.UintType(32), "sh_left_s")
        self.add_signal(u.UintType(32), "sh_right_s")
        for i in range(5):
            self.add_signal(u.UintType(32), f"sl_{i}_s")
            self.add_signal(u.UintType(32), f"sr_{i}_s")

        self.add_signal(u.BitType(), "mul_div_negative_s")
        self.add_signal(u.UintType(32), "mul_div_a_s")
        self.add_signal(u.UintType(32), "mul_div_b_s")

        self.add_signal(u.BitType(), "ex_stall_mul_s")

        # Divider
        self.add_signal(u.UintType(33), "div_sub_s")
        self.add_signal(u.UintType(32), "div_quotient_s")
        self.add_signal(u.UintType(32), "div_remainder_s")
        self.add_signal(u.BitType(), "div_request_s")
        self.add_signal(u.BitType(), "ex_stall_div_s")

        self.add_signal(u.BitType(), "div_busy_r")
        self.add_signal(u.BitType(), "div_ready_r")
        self.add_signal(u.UintType(5), "div_count_r")
        self.add_signal(u.UintType(32), "div_rem_r")
        self.add_signal(u.UintType(32), "div_quot_r")

        self.add_signal(u.UintType(32), "ex_alu_res_s")
        self.add_signal(u.BitType(), "ex_stall_s")
