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


class IotRiscvDbgMod(u.AMod):
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
        self.add_port(u.BitType(), "debug_halt_o")
        self.add_port(u.BitType(), "debug_halt_data_o")
        self.add_port(u.BitType(), "debug_single_step_o")
        self.add_port(u.UintType(pcwidth_p), "if_pc_i")
        self.add_port(u.BitType(), "branch_taken_i")
        self.add_port(u.BitType(), "riscv_debug_pause_i")
        self.add_port(u.BitType(), "riscv_debug_step_i")
        self.add_port(u.BitType(), "riscv_debug_break_o")
        self.add_port(u.BitType(), "debug_halt_comb_o")
        self.add_port(u.BitType(), "debug_halt_data_comb_o")

        self.add_port(u.UintType(32), "d_addr_i")
        self.add_port(u.BitType(), "d_rdy_i")
        self.add_port(u.BitType(), "ex_mem_rd_i")
        self.add_port(u.BitType(), "ex_mem_wr_i")
        self.add_port(u.BitType(), "mem_stall_i")
        self.add_port(u.BitType(), "id_exec_i")
        self.add_port(u.BitType(), "id_bubble_i")
        self.add_port(u.BitType(), "id_break_i")

        for i in range(2):
            self.add_port(u.UintType(31), f"riscv_bp{i}_bp_addr_i")
            self.add_port(u.BitType(), f"riscv_bp{i}_bp_en_i")

        for i in range(2):
            self.add_port(u.BitType(), f"riscv_dbp{i}_dbp_en_i")
            self.add_port(u.BitType(), f"riscv_dbp{i}_dbp_wr_i")
            self.add_port(u.UintType(30), f"riscv_dbp{i}_dbp_addr_i")

        # -----------------------------
        # Signal List
        # -----------------------------
        for i in range(2):
            self.add_signal(u.BitType(), f"bp{i}_addr_hit_s")
            self.add_signal(u.BitType(), f"bp{i}_hit_s")
            self.add_signal(u.BitType(), f"dbp{i}_hit_s")

        self.add_signal(u.BitType(), "debug_halt_s")
        self.add_signal(u.BitType(), "debug_halt_r")

        self.add_signal(u.BitType(), "debug_halt_data_s")
        self.add_signal(u.BitType(), "debug_halt_data_r")

        self.add_signal(u.BitType(), "debug_single_step_s")
        self.add_signal(u.BitType(), "debug_single_step_r")
