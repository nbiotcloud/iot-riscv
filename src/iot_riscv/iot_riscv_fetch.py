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

from iot_riscv.types import IotRiscvRamDataType


class IotRiscvFetchMod(u.AMod):
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
        self.add_param(u.IntegerType(default=32), "pc_size_p", title="PC Width.")
        self.add_param(u.UintType(32, default=0x00000000), "reset_vec_p")

        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        # IMEM related ports
        self.add_port(IotRiscvRamDataType(addrwidth=32, datawidth=32), "i_o")

        self.add_port(u.BitType(), "debug_halt_i")
        self.add_port(u.BitType(), "debug_halt_data_i")
        self.add_port(u.BitType(), "debug_single_step_i")

        self.add_port(u.BitType(), "branch_taken_i")
        self.add_port(u.UintType(32), "jump_addr_i")
        self.add_port(u.UintType(32), "if_pc_i")
        self.add_port(u.BitType(), "hazard_i")

        # self.add_port(u.BitType(), "run_en_i")
        self.add_port(u.BitType(), "if_rv_o")
        self.add_port(u.BitType(), "if_valid_o")
        self.add_port(u.UintType(32), "if_rv_op_o")
        self.add_port(u.UintType(16), "if_rvc_op_o")
        self.add_port(u.BitType(), "if_break_exit_o")
        self.add_port(u.BitType(), "if_hold_state_o")
