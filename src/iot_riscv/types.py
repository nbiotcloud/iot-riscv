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

class IotRiscvRomDataType(u.AStructType):
    """
    Memory Data.

    Args:
        addrwidth (uint): address width in bits.
        datawidth (uint): data width in bits.


    """

    addrwidth : u.Expr|int
    datawidth : u.Expr|int

    def _build(self):
        # FWD
        if self.addrwidth == 1:
            atype = u.BitType()
        else:
            atype = u.UintType(self.addrwidth)
        if self.datawidth == 1:
            dtype = u.BitType()
        else:
            dtype = u.UintType(self.datawidth)
        self._add("addr", atype, u.FWD, title="Address")
        self._add("rdata", dtype, u.BWD, title="Read Data")
        self._add("rd", u.BitType(), u.FWD, title="Read Enable")
        self._add("rdy", u.BitType(default=1), u.BWD, title="Ready")


class IotRiscvRamDataType(u.AStructType):

    """
    Memory Data.

    Args:
        addrwidth (uint): address width in bits.
        datawidth (uint): data width in bits.


    """

    addrwidth : u.Expr|int
    datawidth : u.Expr|int

    def _build(self):
        # FWD
        if self.addrwidth == 1:
            atype = u.BitType()
        else:
            atype = u.UintType(self.addrwidth)
        if self.datawidth == 1:
            dtype = u.BitType()
        else:
            dtype = u.UintType(self.datawidth)
        self._add("rd", u.BitType(), u.FWD, title="Read Enable")
        self._add("addr", atype, u.FWD, title="Address")
        self._add("wdata", dtype, u.FWD, title="Write Data")
        self._add("wr", u.BitType(), u.FWD, title="Write Enable")
        self._add("rdy", u.BitType(), u.BWD, title="Data Ready")
        self._add("grant", u.BitType(), u.BWD, title="Access Granted")
        self._add("rdata", dtype, u.BWD, title="Read Data")
        self._add("size", u.UintType(default=2), u.FWD, title="Size")


class WritebackType(u.AStructType):
    def _build(self):
        self._add("index", u.UintType(default=5), u.FWD, title="Address")
        self._add("value", u.UintType(default=32), u.FWD, title="Data")
        self._add("we", u.BitType(), u.FWD, title="Write Enable")
