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
from ucdp_amba.types import AMBA3, AmbaProto
# from solib import typecast

# =============================================================================
#
#  Conventions:
#
#    *_baseaddr: Base Address, hex notation  (type_=typecast.hex_)
#    *_size:     Size in Bytes, byte notation (type_=typecast.bytes_)
#                  '2 KB'   ==>  '2048 bytes'
#    *_width:    Width in Bits (type_=typecast.uint)
#    *_depth:    Depth in Words, NOT bytes (type_=typecast.uint)
#
# =============================================================================


class IotRiscvMemConfig(u.AConfig):

    """RiscV TC Memory Configuration."""

    # rom_image=u.field()#type_=str, default=lambda config: config.name, is_readonly=True),
    # Sizes
    drom_size = u.field(converter=typecast.bytes_, default="8kB")  # type_=typecast.bytes_, default="8kB"),
    dram_size = u.field(converter=typecast.bytes_, default="256kB")  # type_=typecast.bytes_, default="256kB"),
    irom_size = u.field(converter=typecast.bytes_, default="8kB")  # type_=typecast.bytes_, default="8kB"),
    iram_size = u.field(converter=typecast.bytes_, default="0")  # type_=typecast.bytes_, default=0),
    # Base addresses
    dmem_baseaddr = u.field(converter=typecast.hex_, default=0x10040000)  # type_=typecast.hex_, default=0x40000),
    imem_baseaddr = u.field(converter=typecast.hex_, default=0x10100000)  # type_=typecast.hex_, default=0x100000),
    # Widths
    dmem_width = u.field(converter=int, default=32)  # type_=int, default=32),
    imem_width = u.field(converter=int, default=32)  # type_=int, default=32),
    # add_progmems=u.field(converter=)#type_=typecast.Instance(ProgMem), is_list=True),
    ahbproto: AmbaProto = u.field(default=AMBA3)
    dram_scrm_intf: bool = u.field(converter=bool, default=False)

    # DMEM
    @property
    def drom_baseaddr(self):
        """DROM at the beginning of DMEM."""
        return self.dmem_baseaddr

    @property
    def dram_baseaddr(self):
        """DRAM behind DROM."""
        return self.dmem_baseaddr + self.drom_size

    @property
    def dmem_size(self):
        """DMEM size."""
        return self.drom_size + self.dram_size

    # IMEM
    @property
    def irom_baseaddr(self):
        """IROM at the beginning of IMEM."""
        return self.imem_baseaddr

    @property
    def iram_baseaddr(self):
        """IRAM behind IROM."""
        return self.imem_baseaddr + self.irom_size

    @property
    def imem_size(self):
        """IMEM size."""
        return self.irom_size + self.iram_size
