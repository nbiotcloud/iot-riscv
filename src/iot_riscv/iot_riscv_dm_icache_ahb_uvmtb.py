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
from ucdp_amba.types import AHB3, AhbMstType, AhbSlvType
from uvm_lib.cdn_ahb_uvm_user import CdnAhbUvmUserMod
from uvm_lib.gpio_uvm_user import GpioUserMod

from iot_riscv.iot_riscv_dm_icache_ahb import IotRiscvDmIcacheAhbMod


class IotRiscvDmIcacheAhbUvmtbMod(u.AGenericTbMod):
    tex_doc = None
    copyright_end_year = 2023
    hdl_incvariants = (
        "scbd",
        "top",
        "test",
        "sve",
        "vseq_lib",
        "vsequencer",
        "agent",
        "env",
    )

    dut_mods = (IotRiscvDmIcacheAhbMod,)

    def _build(self):
        dut = self.dut
        self.add_signal(AhbMstType(proto=AHB3), "ahb_mst_s")
        self.add_signal(AhbSlvType(proto=AHB3), "ahb_slv_s")

        dut.con("ahb_mst_o", "cast(ahb_slv_s)")
        dut.con("ahb_slv_i", "cast(ahb_mst_s)")

        dut.con("clk_i", "create(clk_s)")
        dut.con("rst_an_i", "create(rst_an_s)")
        dut.con("flush_i", "create(vif_flush_s)")
        dut.con("bypass_en_i", "create(vif_bypass_en_s)")

        CdnAhbUvmUserMod(self, "u_cdn_ahb_uvm_user")
        GpioUserMod(self, "u_gpio_uvm_user")

    @staticmethod
    def build_dut(**kwargs):
        """Build DUT."""

        return IotRiscvDmIcacheAhbMod()

    def iter_tests(self):
        """Iterate over Tests."""
        yield u.Test(
            "uvm_test",
            options={
                "title": "RISCV_ICACHE UVM Test",
                "tags": ["MOD"],
                "method": "uvm",
                "regression": f"{self.dut.out_libname}-uvm",
                # See iot_riscv_dm_icache_uvmtb.testsimcfg.py.mako for other options
                "paramsets": [
                    ["UVM_TESTNAME=cld_mini_riscv_dm_icache_ahb_uvm_base_test"],
                ],
            },
        )
