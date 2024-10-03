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
from ucdp_glbl.dft import DftModeType
from ucdp_glbl.cld_clk_gate import CldClkGateMod


class IotRiscvPrngIntfMod(u.AMod):
    copyright_start_year = 2019
    copyright_end_year = 2024
    module_id = 0x012D
    major_version, minor_version = 1, 0
    tex_doc = ["ports", "entity"]
    hdl_gen = u.Gen.INLINE

    def _build(self):
        # -----------------------------
        # Port List
        # -----------------------------
        self.add_port(u.ClkRstAnType(), "main_i", title="Clock and Reset")
        self.add_port(DftModeType(), "dft_mode_i", title="DFT Mode")

        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_pause_o",
            title=" Prng Interface Pause",
            descr="Pause signal of Prng Interface. Randomly sets pause signal until core is halted",
        )
        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_step_o",
            title=" Prng Interface Step",
            descr="Step signal of Prng Interface. Starts core after core is halted by Prng Interface Pause",
        )
        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_halt_data_o",
            title=" RISC-V Debug Data Halt",
            descr="Signals the halting core, by data breakpoint",
        )
        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_halt_o",
            title=" RISC-V Debug Halt",
            descr="Signals the halting core, by pause, hardware breakpoint or software breakpoint.\n"
            "Halts caused by Prng Interface will be removed",
        )

        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_pause_i",
            title=" RISC-V Debug Pause",
            descr="Pause signal of debug interface. At high will feedthrough as Prng Interface Pause",
        )
        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_step_i",
            title=" RISC-V Debug Step",
            descr="Step signal of debug interface. At high will feedthrough as Prng Interface Step.\n "
            "While active Debug Pause, Debug step controls Prng Interface step",
        )
        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_halt_data_i",
            title=" RISC-V Debug Data Halt",
            descr="Signals the halting core, by data breakpoint",
        )
        self.add_port(
            u.BitType(default=1),
            "prng_intf_debug_halt_i",
            title=" RISC-V Debug Halt",
            descr="Signals the halting core, by pause, hardware breakpoint or software breakpoint",
        )

        self.add_port(
            u.UintType(4, default=0x9),
            "prng_intf_en_i",
            title=" Prng Interface Enable",
            descr="At default disabled by magic word 0x9. Any other value is enable.",
        )

        self.add_port(
            u.BitType(),
            "prng_intf_debug_break_i",
            title=" Prng Interface Break",
            descr="Signals the halted core, by any source.",
        )

        self.add_port(
            u.BitType(),
            "prng_intf_update_i",
            title=" Prng Interface Update",
            descr="Controll signal to update the LFRS of the PRNG Interface",
        )

        self.add_port(
            u.UintType(16, default=0xFFFF),
            "prng_intf_lfsr_i",
            title=" Prng Interface LFSR",
            descr="Value to update the LFRS of the PRNG Interface",
        )
        self.add_signal(u.BitType(), "gclk_prng_intf_s")
        CldClkGateMod(self, "u_prng_intf_clk_gate", maninst=True)
