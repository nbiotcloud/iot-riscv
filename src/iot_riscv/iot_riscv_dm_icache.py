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
from ucdp_amba.cld_ahb_slv import DataCtrlType, RDataIfType
from ucdp_amba.types import AMBA3, AhbMstType, AmbaProto, add_ahb_localparams
from ucdp_glbl.dft import DftModeType
from ucdp_glbl.mem import Mmpm
from ucdp_glbl.mem import CldRamMod
from solib import typecast


class CacheStateType(u.AEnumType):

    """Cache States."""

    keytype = u.UintType(2)
    valuetype = typecast.Name()

    def _build(self):
        self._add(0, "idle", title="Idle", descr="SIM is unpowered.")
        self._add(1, "fill", title="Fill Cache", descr="Cache Miss, AHB Wrap4 communication reads cacheline")
        self._add(2, "hit", title="Cache hit", descr="Cache Hit, no AHB Wrap4 communication")
        self._add(
            3, "error", title="Error", descr="AHB Wrap4 communication detects Error, cacheline will be invalidated."
        )


class IotRiscvDmIcacheMod(u.AMod):
    """Direct Mapped Instruction Cache for Mini RISC-V Core."""

    copyright_start_year = 2019
    copyright_end_year = 2023
    ahbproto: AmbaProto = u.field(default=AMBA3)
    mmpm = Mmpm.field()
    hdl_gen = u.Gen.INLINE
    addrmap_name = ""

    def _build(self):
        self.add_port(u.ClkRstAnType(), "main_i", "CLock and Reset")
        self.add_port(DftModeType(), "dft_mode_i", title="DFT Mode")

        # IMEM related ports, to outside

        self.add_port(DataCtrlType(addrwidth=32, proto=self.ahbproto), "icache_data_ctrl_i")
        self.add_port(RDataIfType(), "icache_rdata_o")
        self.add_port(RDataIfType(), "icache_wdata_i")

        # IMEM related ports, to core

        self.add_port(AhbMstType(), "ahb_mst_o")

        # Flush indicator for invalidation
        self.add_port(u.BitType(), "flush_i")

        self.add_port(CacheStateType(), "cache_state_o")

        # -----------------------------
        # Module RAM
        # -----------------------------
        self.add_localparam(u.UintType(32, default=2**6), "imem_size_p")
        self.add_type_as_localparam(CacheStateType(), item_suffix="st")
        add_ahb_localparams(self)

        CldRamMod(self, "u_ram", size=1024, width=32, writewidth=32, addrmap_name=None)
        self.route("", "u_ram/")
        self.route("dft_mode_i", "u_ram/dft_mode_i")
        self.add_signal(u.BitType(), "en_s")
        self.route("en_s", "u_ram/mem_ena_i")
        self.add_signal(u.BitType(), "wen_s")
        self.route("wen_s", "u_ram/mem_wena_i")
        self.add_signal(u.BitType(), "wsel_s")
        self.route("wsel_s", "u_ram/mem_wsel_i")
        self.add_signal(u.UintType(8), "addr_s")
        self.route("addr_s", "u_ram/mem_addr_i")
        self.add_signal(u.UintType(32), "icache_rdata_s")
        self.route("icache_rdata_s", "u_ram/mem_rdata_o")
        self.add_signal(u.UintType(32), "wdata_s")
        self.route("wdata_s", "u_ram/mem_wdata_i")

        # -----------------------------
        # Module Memory Power Manager
        # -----------------------------
        self.mmpm.auto()
