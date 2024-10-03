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
from ucdp_amba.types import AHB3
from ucdp_tb.cld_tb_stub import CldTbStub

from iot_riscv.iot_riscv_ahb import IotRiscvAhbExampleMod


class IotRiscvAhbTbMod(u.ATbMod):
    """Mini RISC-V AHB Testbench."""

    copyright_start_year = 2023
    copyright_end_year = 2024

    def _build(self):
        dut = self.dut
        config = dut.config
        extprogmem = config.add_progmems[0]
        tb_stub = CldTbStub(
            self,
            tbfreq=64e6,
            tbrambaseaddr=extprogmem.baseaddr,
            tbramsize=extprogmem.size,
            ahbproto=config.ahbproto,
            tbwdogfreq=100_000_000,
        )

        dut.con("", "tb_s")
        ml = tb_stub.ml
        tb_stub.autoconnect_gpio(dut)
        tb_stub.autoconnect_apb_slv_in(dut, mod=f"{dut.name}/u_regf")

        ml.add_master("dut", route=f"{dut.name}/ahb_mst_o", slavenames="tb_ram; tb_ahb2apb", proto=AHB3)

        ml.add_slave(
            "dut",
            masternames="tb_mst",
            route=f"{dut.name}/ahb_slv_i",
            mod=f"{dut.name}",
            baseaddr=0x00000000,
            size=0x20000000,
        )

    @staticmethod
    def build_dut(**kwargs):
        return IotRiscvAhbExampleMod().insts["u_riscv"]
