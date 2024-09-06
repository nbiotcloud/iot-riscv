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


class IotRiscvIntIrqMod(u.AMod):
    filelists: u.ClassVar[u.ModFileLists] = (
        u.ModFileList(
            name="hdl",
            # full, inplace, no
            gen="inplace",
            filepaths=("rtl/{mod.modname}.sv"),
            template_filepaths=("sv.mako",),
        ),
    )    

    def _build(self):
        # -----------------------------
        # Parameter List
        # -----------------------------
        irq_width_p = self.add_param(u.IntegerType(default=32), "irq_width_p")
        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        # IRQ lines
        self.add_port(u.EnaType(default=1), "irq_en_i")
        self.add_port(u.UintType(irq_width_p), "irq_i")
        self.add_port(u.UintType(irq_width_p), "irq_mask_i")
        self.add_port(u.BitType(), "irq_run_en_o")
        self.add_port(u.BitType(), "debug_halt_i")
        self.add_port(u.BitType(), "debug_single_step_i")
        self.add_port(u.BitType(), "debug_halt_data_i")
        self.add_port(u.BitType(), "id_irq_i")
        self.add_port(u.BitType(), "id_mret_i")
        self.add_port(u.BitType(), "irq_hot_o")

        # -----------------------------
        # Signal List
        # -----------------------------
        self.add_signal(u.BitType(), "irq_masked_s")
        self.add_signal(u.BitType(), "irq_hot_s")
        self.add_signal(u.BitType(), "dly_irq_hot_r")
        self.add_signal(u.BitType(), "in_irq_r")
