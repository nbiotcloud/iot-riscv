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

from iot_riscv.types import IotRiscvRamDataType, WritebackType


class IotRiscvLsuMod(u.AMod):
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
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        self.add_port(u.UintType(32), "ex_alu_res_i")
        self.add_port(u.UintType(32), "ex_mem_data_i")
        self.add_port(u.UintType(2), "ex_mem_size_i")
        self.add_port(u.BitType(), "ex_mem_signed_i")
        self.add_port(u.BitType(), "ex_mem_rd_i")
        self.add_port(u.BitType(), "ex_mem_wr_i")

        self.add_port(u.UintType(32), "csr_rd_value_i")
        self.add_port(u.UintType(5), "ex_rd_index_i")
        self.add_port(u.BitType(), "ex_csrrw_i")
        self.add_port(u.BitType(), "mem_stall_o")
        self.add_port(u.BitType(), "mem_stall_comb_o")
        # self.add_port(u.BitType(), "run_en_i")
        # DMEM related ports
        self.add_port(IotRiscvRamDataType(addrwidth=32, datawidth=32), "d_o")

        self.add_port(WritebackType(), "rd_o")
        # -----------------------------
        # Signal List
        # -----------------------------
        self.add_signal(u.BitType(), "mem_access_s")
        self.add_signal(u.BitType(), "mem_stall_s")
        self.add_signal(u.BitType(), "mem_stall_r")
        self.add_signal(u.UintType(32), "mem_rdata_s")
