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

"""IOT-Riscv Toplevel Configuration with AHB subsystem."""

import ucdp as u
from ucdp_amba.types import AMBA3, AmbaProto

# from solib.itertools import split


class IotRiscvAhbConfig(u.AConfig):
    """Mini RISC-V AHB subsystem configuration."""

    ahbproto: AmbaProto = AMBA3
    apbproto: AmbaProto = AMBA3
    has_icache: bool = False
    run_after_reset: bool = True
    has_prng_intf: bool = True
    dram_scrm_intf: bool = False
    reset_sp: u.Hex = 0
    reset_pc: u.Hex = 0
    irq_vec: u.Hex = 0
    apb_dbg_baseaddr: u.Hex = 0x00040000
    bus_baseaddr: u.Hex = 0x00040000
    hw_irqs: int = 16
    sw_irqs: int = 16
    irq_en_default: bool = True
    has_static_enable: bool = False
    core_id: u.Hex = 0x0000000
    riscv_gap_size: bytes = "0kB"
    secnames: tuple[str, ...] = tuple()
    ctrl_secnames: tuple[str, ...] = tuple()
    core_secname: str = ""
    enable_secnames: tuple[str, ...] = tuple()
    # add_progmems = u.field(factory=tuple)

    # BOZO
    # @reset_sp.default
    # def _reset_sp_default(self):
    #     return self.dmem_baseaddr + self.dmem_size - 4

    # @reset_pc.default
    # def _reset_pc_default(self):
    #     return self.imem_baseaddr

    # @irq_vec.default
    # def _irq_vec_default(self):
    #     return self.imem_baseaddr + 4

    @property
    def irqs(self):
        """Total number of software and hardware IRQs."""
        return self.hw_irqs + self.sw_irqs
