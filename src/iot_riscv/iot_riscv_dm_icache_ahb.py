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
from ucdp_amba.cld_ahb_slv import AhbSlvStateType, CldAhbSlvMod
from ucdp_amba.types import AhbMstType, AhbSlvType
from ucdp_glbl.dft import DftModeType
from ucdp_glbl.cld_clk_mgate import CldClkMgateMod

from iot_riscv.iot_riscv_dm_icache import CacheStateType, IotRiscvDmIcacheMod

ROM_WORDS_WAIT = [0, 0]


class IotRiscvDmIcacheAhbMod(u.AMod):
    filelists: u.ClassVar[u.ModFileLists] = (
        u.ModFileList(
            name="hdl",
            # full, inplace, no
            gen="inplace",
            filepaths=("rtl/{mod.modname}.sv"),
            template_filepaths=("sv.mako",),
        ),
    )
    module_id = 0xE677
    major_version, minor_version = 1, 0
    tex_doc = ["entity", "ports"]

    def _build(self):
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        self.add_port(DftModeType(), "dft_mode_i")
        self.add_port(AhbSlvType(), "ahb_slv_i", title="AHB Input", descr="AHB Slave")
        self.add_port(AhbMstType(), "ahb_mst_o")

        # Flush indicator for invalidation
        self.add_port(u.BitType(), "flush_i", title="Flush Cache", descr="signal to invalid all cache entries")
        self.add_port(u.BitType(), "bypass_en_i", title="Bypass Cache", descr="enables the bypass for cache")

        CldClkMgateMod(self, "u_clk_mgate", maninst=True)

        icache = IotRiscvDmIcacheMod(self, "u_icache")
        icache.con("rst_an_i", "rst_an_i")
        icache.con("clk_i", "gclk_s")
        icache.con("dft_mode_i", "dft_mode_i")
        icache.con("mpcb_i", "create(mpcb_i)")
        icache.con("flush_i", "flush_i")

        self.add_signal(CacheStateType(), "cache_state_s", route="u_icache/cache_state_o")
        self.add_type_as_localparam(CacheStateType(), item_suffix="st")
        self.add_signal(u.BitType(), "cache_active_s")
        self.add_signal(u.BitType(), "gclk_s")

        # -----------------------------
        # AHB slave
        # -----------------------------

        addrwidth_p = 30
        CldAhbSlvMod(
            self,
            "u_ahb_slv",
            paramdict={
                "mode_p": "stall",
                "addrwidth_p": addrwidth_p,
            },
        )

        self.add_signal(AhbSlvStateType(), "ahb_slv_state_s", route="u_ahb_slv/ahb_slv_state_o")
        self.add_type_as_localparam(AhbSlvStateType(), item_suffix="st")

        self.route("", "u_ahb_slv/")
        # self.route("gclk_s", "u_ahb_slv/clk_i")
        self.route("u_ahb_slv/dft_mode_i", "dft_mode_i")
        self.route("ahb_slv_cache_s", "u_ahb_slv/ahb_slv_i")

        self.add_signal(u.UintType(32), "iaddr_s", route="u_icache/icache_data_ctrl_addr_i")
        self.add_signal(u.UintType(addrwidth_p), "ahb_addr_s", route="u_ahb_slv/ctrl_addr_o")

        self.route("u_ahb_slv/rdata_i", "u_icache/icache_rdata_o")
        self.route("u_ahb_slv/wdata_o", "u_icache/icache_wdata_i")

        self.route("u_ahb_slv/ctrl_byte_o", "u_icache/icache_data_ctrl_byte_i")
        self.route("u_ahb_slv/ctrl_ahb_slv_hburst_o", "u_icache/icache_data_ctrl_ahb_slv_hburst_i")
        self.route("u_ahb_slv/ctrl_error_i", "u_icache/icache_data_ctrl_error_o")

        self.route("ahb_mst_cache_s", "u_icache/ahb_mst_o")

        self.add_signal(AhbSlvType(), "ahb_slv_cache_s")
        self.add_signal(AhbMstType(), "ahb_mst_cache_s")
        self.add_signal(AhbSlvType(), "ahb_slv_bypass_s")
        self.add_signal(AhbMstType(), "ahb_mst_bypass_s")
