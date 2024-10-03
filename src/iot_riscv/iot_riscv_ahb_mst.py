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
from ucdp_amba.types import AhbMstType, add_ahb_localparams
from ucdp_mem.cld_prio_ram_arbiter import MemPortType

from iot_riscv.types import IotRiscvRamDataType

class IotRiscvAhbMstMod(u.ATailoredMod):
    """
    RISCV AHB Master Adapter with tightly coupled memory splitter.

    Args:
        parent (AMod): Parent Module
        name (str): Instance Name

    Keyword Args:
        title (str): Display Name.
        descr (str):    Description.
        comment (str):  Comment
        mem_addrwidth(int): RAM Address port width (default is 12)
        sec_mem_addrwidth(int): Second RAM Address port width (default is 0, not used)
        datawidth(int): Data port width (default is 32)
        mem_baseaddr(int): Base address of tigthly coupled memory window
        sec_mem_baseaddr(int): Second base address of tigthly coupled memory window
    """

    datawidth: int = u.field(kw_only=True, default=32)
    checkx = u.field(kw_only=True, default=False)
    mem_addrwidth: int = u.field(kw_only=True, default=12)
    mem_baseaddr = u.field(kw_only=True, default=0x00000000)
    sec_mem_addrwidth: int = u.field(kw_only=True, default=0)
    sec_mem_baseaddr = u.field(kw_only=True, default=0x00000000)

    @property
    def mem_byte_addrwidth(self):
        return self.mem_addrwidth - 2

    @property
    def sec_mem_byte_addrwidth(self):
        return self.sec_mem_addrwidth - 2

    @staticmethod
    def build_top(**kwargs):
        """Build example top module and return it."""
        return IotRiscvAhbMstExampleMod()

    def _build(self):
        assert not self.sec_mem_addrwidth, "Secondary memory port with backpressure is not supported right now."

        # hdl_incfilenames = ["ahb_def.vh"]
        # -----------------------------
        # Parameter List
        # -----------------------------
        self.add_localparam(u.UintType(32, default=self.datawidth), "datawidth_p")
        self.add_localparam(u.UintType(32, default=self.mem_addrwidth), "mem_addrwidth_p")
        self.add_localparam(u.UintType(32, default=self.mem_baseaddr), "mem_baseaddr_p")
        self.add_localparam(u.UintType(32, default=self.sec_mem_addrwidth), "sec_mem_addrwidth_p")
        self.add_localparam(u.UintType(32, default=self.sec_mem_baseaddr), "sec_mem_baseaddr_p")
        add_ahb_localparams(self)
        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")

        self.add_port(AhbMstType(), "ahb_mst_o", title="AHB Master Out", descr="AHB master output")

        self.add_port(
            MiniRiscvRamDataType(datawidth=self.datawidth, addrwidth=32),
            "r2a_mem_i",
            # wselwidth=self.datawidth / 8, backpressure=False),
            title="Riscv2AhbMst memory input",
        )
        self.add_port(
            MemPortType(
                addrwidth=self.mem_byte_addrwidth,
                datawidth=self.datawidth,
                wselwidth=self.datawidth / 8,
                backpressure=False,
            ),
            "a2m_mem_o",
            title="AhbMst2Mem memory output",
        )
        if self.sec_mem_addrwidth:
            self.add_port(
                MemPortType(
                    addrwidth=self.sec_mem_byte_addrwidth,
                    datawidth=self.datawidth,
                    wselwidth=self.datawidth / 8,
                    backpressure=True,
                ),
                "a2m_sec_mem_o",
                title="AhbMst2Mem secondary memory output",
            )

        self.add_port(u.BitType(), "align_except_o", title="Alignment exception caught")
        self.add_port(u.BitType(), "resp_except_o", title="Response exception caught")
        self.add_port(u.UintType(32), "except_addr_o", title="Exception address")


class IotRiscvAhbMstExampleMod(u.AMod):
    tex_doc = None

    def _build(self):
        IotRiscvAhbMstMod(
            self,
            "u_top",
            datawidth=32,
            mem_addrwidth=13,
            mem_baseaddr=0xC0008000,
            # sec_mem_addrwidth=15,
            # sec_mem_baseaddr=0xC0001000,
        )
