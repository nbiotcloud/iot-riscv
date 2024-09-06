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


class IotRiscvHazardUnitMod(u.AMod):
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

        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.BitType(), "ex_stall_i")
        self.add_port(u.UintType(32), "alu_res_i")
        self.add_port(u.BitType(), "id_csrrw_i")
        self.add_port(u.BitType(), "id_mem_rd_i")
        self.add_port(u.UintType(5), "exe_rd_index_i")

        self.add_port(u.BitType(), "mem_stall_i")
        self.add_port(u.UintType(5), "mem_rd_index_i")
        self.add_port(u.UintType(32), "mem_rd_value_i")

        self.add_port(u.UintType(5), "id_ra_index_i")
        self.add_port(u.UintType(5), "id_rb_index_i")
        self.add_port(u.BitType(), "branch_taken_i")
        self.add_port(u.BitType(), "id_lock_i")
        self.add_port(u.BitType(), "if_valid_i")
        self.add_port(u.BitType(), "if_hold_state_i")
        self.add_port(u.BitType(), "id_ready_o")
        self.add_port(u.BitType(), "ex_ready_o")
        self.add_port(u.BitType(), "id_clear_o")
        self.add_port(u.BitType(), "ex_clear_o")
        self.add_port(u.BitType(), "hazard_o")

        self.add_port(u.UintType(32), "fwd_data_o")
        self.add_port(u.BitType(), "fwd_a_en_o")
        self.add_port(u.BitType(), "fwd_b_en_o")
