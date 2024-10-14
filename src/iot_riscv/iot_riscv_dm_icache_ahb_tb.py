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
from ucdp_amba.cld_ahb_ram import CldAhbRamMod
from ucdp_amba.ucdp_ahb_ml import UcdpAhbMlMod
from ucdp_tb.cld_tb_stub import CldTbStub

from iot_riscv.iot_riscv_dm_icache_ahb import IotRiscvDmIcacheAhbMod


class IotRiscvDmIcacheAhbTbMod(u.ATbMod):

    """Example Module Testbench."""

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
        tb_stub = CldTbStub(self, tbfreq=48e6)
        # =================================================
        # DUT
        # =================================================
        dut = self.dut
        tb_stub.autoconnect_clk_rst_in(dut, basename="dm_icache_ahb")
        tb_stub.autoconnect_gpio(dut, basename="dm_icache_ahb")

        tb_stub.ml.add_slave(
            "icache_in",
            masternames="tb_mst",
            route=f"{dut.name}/ahb_slv_i",
            baseaddr=0xC0000000,
            size=2**28,
        )

        ram = CldAhbRamMod(self, "u_ahb_ram", size="16Kb", has_clk_gate=False)
        tb_stub.autoconnect_clk_rst_in(ram)

        ml = UcdpAhbMlMod(self, "u_ml")
        ml.con("", "tb_s")
        ml.add_master("icache_out", route=f"{dut.name}/ahb_mst_o")
        ml.add_slave(
            "flash",
            masternames="icache_out",
            route="u_ahb_ram/ahb_slv_i",
            mod=ram,
            baseaddr=0xC0000000,
            size=2**28,
        )

    @staticmethod
    def build_dut(**kwargs):
        return IotRiscvDmIcacheAhbMod()

    def iter_addrmap(self):
        yield from self.get_inst("u_tb_ml").iter_addrmap()
        yield from self.get_inst("u_ml").iter_addrmap()
