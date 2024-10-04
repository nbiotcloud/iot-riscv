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
from ucdp_amba.types import AmbaProto
from solib import typecast
from solib.itertools import split

from iot_riscv.iot_riscv_mem_config import IotRiscvMemConfig


class IotRiscvAhbConfig(IotRiscvAhbConfig):

    """Mini RISC-V AHB subsystem configuration."""

    ahbproto: AmbaProto = u.field(kw_only=True)
    apbproto: AmbaProto = u.field(kw_only=True)
    has_icache = u.field(converter=bool, default=False)
    run_after_reset = u.field(converter=bool, default=True)
    has_prng_intf = u.field(converter=bool, default=True)
    dram_scrm_intf = u.field(converter=bool, default=False)
    reset_sp = u.field(converter=typecast.hex_)
    reset_pc = u.field(converter=typecast.hex_)
    irq_vec = u.field(converter=typecast.hex_)
    apb_dbg_baseaddr = u.field(converter=typecast.hex_, default=0x00040000)
    bus_baseaddr = u.field(converter=typecast.hex_, default=0x00040000)
    hw_irqs = u.field(converter=int, default=16)
    sw_irqs = u.field(converter=int, default=16)
    irq_en_default = u.field(converter=bool, default=True)
    has_static_enable = u.field(converter=bool, default=False)
    core_id = u.field(converter=typecast.hex_, default=0x0000000)
    riscv_gap_size = u.field(converter=typecast.bytes_, default="0kB")
    secnames = u.field(converter=split, default=None)
    ctrl_secnames = u.field(converter=split, default=None)
    core_secname = u.field(kw_only=True)
    enable_secnames = u.field(converter=split, default=None)
    add_progmems = u.field(factory=tuple)

    @reset_sp.default
    def _reset_sp_default(self):
        return self.dmem_baseaddr + self.dmem_size - 4

    @reset_pc.default
    def _reset_pc_default(self):
        return self.imem_baseaddr

    @irq_vec.default
    def _irq_vec_default(self):
        return self.imem_baseaddr + 4

    @property
    def irqs(self):
        """Total number of software and hardware IRQs."""
        return self.hw_irqs + self.sw_irqs
