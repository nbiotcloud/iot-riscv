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
from ucdp_amba.cld   import DataCtrlType, WDataIfType
from ucdp_amba.types import AMBA3, AhbMstType, AmbaProto
from ucdp_glbl.dft import DftModeType
# from solib import typecast


class FSMType(u.AEnumType):
    """SPI Slave FSM States."""

    keytype: u.UintType = u.UintType(1)
    # valuetype = typecast.Name()

    def _build(self):
        self._add(0, "ahb_idle", descr="Idle state")
        self._add(1, "ahb_cmd", descr="AHB Command state")


class IotRiscvDmIcacheAhbMstMod(u.AMod):
    """AHB Master for Mini RISC-V Cache."""
    filelists: u.ClassVar[u.ModFileLists] = (
        u.ModFileList(
            name="hdl",
            # full, inplace, no
            gen="inplace",
            filepaths=("rtl/{mod.modname}.sv"),
            template_filepaths=("sv.mako",),
        ),
    )

    ahbproto: AmbaProto = u.field(default=AMBA3)

    def _build(self):
        self.add_port(u.ClkRstAnType(), "main_i", "CLock and Reset")
        self.add_port(DftModeType(), "dft_mode_i", title="DFT Mode")

        self.add_port(DataCtrlType(addrwidth=32, proto=self.ahbproto), "data_ctrl_i")
        self.add_port(WDataIfType(), "wdata_o")
        self.add_port(AhbMstType(), "ahb_mst_o")

        self.add_type_as_localparam(FSMType(), item_suffix="st")
        self.add_flipflop(FSMType(), "state_r")
