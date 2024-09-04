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

class IotRiscvCompressedDecoderMod(u.AMod):
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
        # Port List
        # -----------------------------

        self.add_port(
            u.UintType(16, default=0x0000),
            "rvc_op_i",
            title="Unsigned Input",
        )
        self.add_port(
            u.UintType(32, default=0x00000000),
            "rvc_dec_o",
            title="Unsigned Output",
        )

        # -----------------------------
        # signal List
        # -----------------------------

        self.add_signal(
            u.UintType(16, default=0x0000),
            "if_rvc_op_s",
            title="Unsigned Input",
        )
        self.add_signal(
            u.UintType(32, default=0x0000),
            "if_rvc_dec_s",
            title="Unsigned Output",
        )
