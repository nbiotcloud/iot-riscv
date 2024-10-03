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

import collections

import ucdp as u
from ucdp_glbl.dft import DftModeType
from ucdp_glbl.irq import IrqType, IrqVecType
from ip_common.cld_sync import CldSyncMod
from solib import typecast
from tabulate import tabulate

Irq = collections.namedtuple("Irq", "number name title descr sync")
_lowercasename = typecast.LowerCaseName()


class IotRiscvIrqMod(u.ATailoredMod):
    copyright_start_year = 2023
    tex_doc = [""]
    num_of_irqs = u.field(kw_only=True, default=16)
    irqs: u.Namespace = u.field(factory=u.Namespace, init=False)
    copyright_end_year = 2022
    """
    IRQ Mapping.

    Combine all IRQ sources to one IRQ Vector.

    Args:
        parent (AMod): Parent Module
        name (str):                Instance Name
        num_of_irqs (int):         Number of IRQs.

    Keyword Args:
        title (str): Display Name.
        descr (str):    Description.
        comment (str):  Comment
    """

    def _build(self):
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        self.add_port(DftModeType(), "dft_mode_i")
        self.add_port(IrqVecType(self.num_of_irqs), "irq_o", title="Interrupts to RISCV")

    def add_irq(self, name, title=None, descr=None, comment=None, route=None, sync=False):
        """
        Add interrupt.

        Args:
            name (str): Name

        Keyword Args:
            title (str): Display Name.
            descr (str):    Description.
            comment (str):  Source Code Comment.
            route (str): Name of signal to route interrupt from.
            createroute (str): Name of port to create and route interrupt from.
            sync (bool): Synchronize interrupt to current clock domain.
        """
        number = len(self.irqs)
        name = _lowercasename(name)
        sync = bool(sync)
        irq = Irq(number, name, title=title, descr=descr, sync=sync)
        # connect
        portname = f"irq_{irq.name}_i"
        self.add_port(IrqType(), portname, title=title, descr=descr, comment=comment)
        if irq.sync:
            modname = f"u_sync_{irq.name}"
            signalname = f"irq_{irq.name}_sync_s"
            self.add_signal(u.BitType(), signalname)
            sync = CldSyncMod(self, modname, comment=f"Synchronizer for interrupt {irq.name}.")
            sync.con("", "")
            sync.con("dft_mode_i", "dft_mode_i")
            sync.con("d_i", portname)
            sync.con("q_o", signalname)
        if route:
            self.con(portname, route)

        # add
        self.irqs.add(irq)
        return irq

    def get_overview(self):
        """Return Overview Table."""
        headers = ("Number", "Name")
        return tabulate(self._iter_overview(), headers=headers)

    def _iter_overview(self):
        for irq in sorted(self.irqs, key=lambda irq: irq.number):
            yield irq.number, irq.name
