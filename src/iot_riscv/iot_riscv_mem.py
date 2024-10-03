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
import logging

import tabulate
from ucdp_amba.ucdp_ahb_slv import AhbSlvStateType, UcdpAhbSlvMod
from ucdp_amba.types import AHB3, AmbaProto, AhbSlvType
# from cld_dft.types import DftModeType
from ucdp_mem.cld_mem_scram import CldMemScramMod
from cld_mem.cld_mmpm import Mmpm
from cld_mem.cld_prio_ram_arbiter import CldPrioRamArbiterMod, MemPortType
from cld_mem.cld_ram import CldRamMod
from cld_mem.cld_rom import CldRomMod, RomContent
from sideutil.addrmap import AddrMap
from sideutil.num import calc_unsigned_width

from iot_riscv.iot_riscv_mem_config import IotRiscvMemConfig

# from ic_util.progmem import ProgMem

BYTE = 8
WORD = 32

IROM_WORDS_WAIT = [0x0000_0000, 0x0000_0000]
LOGGER = logging.getLogger(__name__)

class IotRiscvMemMod(u.AConfigurableMod):
    """Tightly coupled Memory Wrapper for Mini RISC-V."""

    module_id = 0x15C1
    copyright_start_year = 2023
    copyright_end_year = 2023
    tex_doc = ["entity", "ports", "mmpm", "config"]
    addrmap_name = None
    dmem_crossover = False  # we do not support this in the master port of the core right now anymore
    ahbproto: AmbaProto = u.field(default=AHB3)
    addrmap = u.field(init=False, factory=lambda: AddrMap(addrwidth=32))
    mmpm = Mmpm.field()

    @staticmethod
    def build_top(**kwargs):
        """Build example top module and return it."""
        config = CldMiniRiscvMemConfig("test")
        return CldMiniRiscvMemMod(config=config)

    def _build(self):
        """Build."""
        config = self.config
        imem_size = config.iram_size + config.irom_size
        dmem_size = config.dram_size + config.drom_size
        imem_addrwidth = calc_unsigned_width(imem_size / 4 - 1)
        dmem_addrwidth = calc_unsigned_width(dmem_size / 4 - 1)
        # =====================================================================
        # Port List
        # =====================================================================
        self.add_port(u.ClkRstAnType(), "", title="Clock and Reset")
        self.add_port(DftModeType(), "dft_mode_i")
        self.add_port(
            MemPortType(addrwidth=imem_addrwidth, datawidth=32, wselwidth=4, backpressure=False),
            "imem_i",
        )

        self.add_port(
            MemPortType(
                addrwidth=dmem_addrwidth,
                datawidth=32,
                wselwidth=4,
                backpressure=False,
            ),
            "dmem_i",
        )
        if self.dmem_crossover:
            self.add_port(
                MemPortType(addrwidth=imem_addrwidth, datawidth=32, wselwidth=4, backpressure=True),
                "d2imem_i",
            )
        self.add_port(AhbSlvType(), "ahb_slv_imem_i", title="AHB Input", descr="AHB Slave")
        self.add_port(AhbSlvType(), "ahb_slv_dmem_i", title="AHB Input", descr="AHB Slave")
        self.add_port(u.BitType(), "debug_rom_unlock_i")

        # =====================================================================
        # Memories
        # =====================================================================
        self._create_progmem(
            config,
            "drom",
            config.drom_baseaddr,
            config.drom_size,
            32,
            writable=False,
            writewidth=BYTE,
            title="Data ROM",
        )
        self._create_progmem(
            config,
            "dram",
            config.dram_baseaddr,
            config.dram_size,
            32,
            writable=True,
            writewidth=BYTE,
            title="Data RAM",
        )
        self._create_progmem(
            config,
            "irom",
            config.irom_baseaddr,
            config.irom_size,
            32,
            writable=False,
            writewidth=BYTE,
            title="Instruction ROM",
            default=IROM_WORDS_WAIT,
        )
        self._create_progmem(
            config,
            "iram",
            config.iram_baseaddr,
            config.iram_size,
            config.imem_width,
            writable=True,
            writewidth=BYTE,
            title="Instruction RAM",
            retention=True,
            default=IROM_WORDS_WAIT,  # in case there is no ROM and iram is the base
        )

        if config.iram_size or config.irom_size:
            imem_arbiter = CldPrioRamArbiterMod(
                self, "u_imem_arbiter", addrwidth=imem_addrwidth, datawidth=32, wselwidth=4
            )
            imem_arbiter.add_prio0master("ahb")
            if self.dmem_crossover:
                imem_arbiter.add_prio0master("d")
                imem_arbiter.con("", "")
                imem_arbiter.con("mem_d_prio0_i", "d2imem_i")

            imem_arbiter.con("mem_prio1_i", "imem_i")
            imem_arbiter.con("mem_o", "create(imem_s)")
            imem_arbiter.con("mem_ahb_prio0_ena_i", "create(ahb_slv_imem_ena_s)")

        if config.dram_size or config.drom_size:
            dmem_addrwidth = calc_unsigned_width((config.drom_size + config.dram_size) / 4 - 1)
            dmem_arbiter = CldPrioRamArbiterMod(
                self, "u_dmem_arbiter", addrwidth=dmem_addrwidth, datawidth=32, wselwidth=4
            )
            dmem_arbiter.add_prio0master("ahb")
            self.add_signal(
                MemPortType(
                    addrwidth=(calc_unsigned_width(dmem_size / 4 - 1)),
                    datawidth=32,
                    wselwidth=4,
                    backpressure=False,
                ),
                "dmem_s",
            )
            self.route("dmem_i", "u_dmem_arbiter/mem_prio1_i")
            self.route("dmem_s", "u_dmem_arbiter/mem_o")
            self.add_signal(u.BitType(), "ahb_slv_dmem_ena_s")
            self.route("u_dmem_arbiter/mem_ahb_prio0_ena_i", "ahb_slv_dmem_ena_s")

        # -----------------------------
        # Module Memory Power Manager
        # -----------------------------
        self.mmpm.auto()

        # -----------------------------
        # AHB slave
        # -----------------------------

        CldAhbSlvMod(
            self,
            "u_ahb_slv_imem",
            config=self.ahbproto,
            paramdict={
                "addrwidth_p": imem_addrwidth,
                "mode_p": "stall",
            },
        )
        self.route("", "u_ahb_slv_imem/")
        self.route("ahb_slv_imem_i", "u_ahb_slv_imem/ahb_slv_i")
        self.route("u_ahb_slv_imem/wdata_data_o", "u_imem_arbiter/mem_ahb_prio0_wdata_i")
        self.route("u_ahb_slv_imem/wdata_vld_o", "u_imem_arbiter/mem_ahb_prio0_wena_i")
        self.route("u_ahb_slv_imem/rdata_data_i", "u_imem_arbiter/mem_ahb_prio0_rdata_o")
        self.add_signal(u.UintType(imem_addrwidth), "ahb_slv_imem_ctrl_addr_o_s")
        self.route("u_ahb_slv_imem/ctrl_addr_o", "ahb_slv_imem_ctrl_addr_o_s")
        self.route("ahb_slv_imem_ctrl_addr_o_s", "u_imem_arbiter/mem_ahb_prio0_addr_i")
        self.route("u_ahb_slv_imem/ctrl_byte_o", "u_imem_arbiter/mem_ahb_prio0_wsel_i")
        self.add_signal(AhbSlvStateType(), "ahb_slv_imem_state_s")
        self.route("u_ahb_slv_imem/ahb_slv_state_o", "ahb_slv_imem_state_s")
        self.route("u_ahb_slv_imem/dft_mode_i", "dft_mode_i")
        self.add_signal(u.BitType(), "ahb_slv_imem_rdata_rdy_o_s")
        self.route("u_ahb_slv_imem/rdata_rdy_o", "ahb_slv_imem_rdata_rdy_o_s")
        self.add_signal(u.BitType(), "imem_data_rdy_s")
        self.route("u_imem_arbiter/mem_ahb_prio0_vld_o", "imem_data_rdy_s")
        self.route("imem_data_rdy_s", "u_ahb_slv_imem/wdata_rdy_i")
        self.route("imem_data_rdy_s", "u_ahb_slv_imem/rdata_vld_i")

        CldAhbSlvMod(
            self,
            "u_ahb_slv_dmem",
            paramdict={
                "addrwidth_p": dmem_addrwidth,
                "mode_p": "stall",
            },
        )
        self.route("", "u_ahb_slv_dmem/")
        self.route("ahb_slv_dmem_i", "u_ahb_slv_dmem/ahb_slv_i")
        self.route("u_ahb_slv_dmem/wdata_data_o", "u_dmem_arbiter/mem_ahb_prio0_wdata_i")
        self.route("u_ahb_slv_dmem/wdata_vld_o", "u_dmem_arbiter/mem_ahb_prio0_wena_i")
        self.route("u_ahb_slv_dmem/rdata_data_i", "u_dmem_arbiter/mem_ahb_prio0_rdata_o")
        self.add_signal(u.UintType(dmem_addrwidth), "ahb_slv_dmem_ctrl_addr_o_s")
        self.route("u_ahb_slv_dmem/ctrl_addr_o", "ahb_slv_dmem_ctrl_addr_o_s")
        self.route("ahb_slv_dmem_ctrl_addr_o_s", "u_dmem_arbiter/mem_ahb_prio0_addr_i")
        self.route("u_ahb_slv_dmem/ctrl_byte_o", "u_dmem_arbiter/mem_ahb_prio0_wsel_i")
        self.add_signal(AhbSlvStateType(), "ahb_slv_dmem_state_s")
        self.route("u_ahb_slv_dmem/ahb_slv_state_o", "ahb_slv_dmem_state_s")
        self.route("u_ahb_slv_dmem/dft_mode_i", "dft_mode_i")
        self.add_signal(u.BitType(), "ahb_slv_dmem_rdata_rdy_o_s")
        self.route("u_ahb_slv_dmem/rdata_rdy_o", "ahb_slv_dmem_rdata_rdy_o_s")
        self.add_signal(u.BitType(), "dmem_data_rdy_s")
        self.route("u_dmem_arbiter/mem_ahb_prio0_vld_o", "dmem_data_rdy_s")
        self.route("dmem_data_rdy_s", "u_ahb_slv_dmem/wdata_rdy_i")
        self.route("dmem_data_rdy_s", "u_ahb_slv_dmem/rdata_vld_i")

    def iter_addrmap(self, **kwargs):
        """Return Address Ranges."""
        return iter(self.addrmap)

    def get_overview(self):
        """Nice Overview Table."""

        def _iter(config):
            for name in ("irom", "iram", "drom", "dram"):
                size = getattr(config, f"{name}_size")
                baseaddr = getattr(config, f"{name}_baseaddr")
                if size:
                    yield name, str(baseaddr), f"0x{size:X} ({size!s})"
                else:
                    yield name, "-", "-"

        headers = ("Memory", "Base Address", "Size")
        return tabulate.tabulate(_iter(self.config), headers=headers)

    def _create_progmem(
        self,
        config,
        name,
        baseaddr,
        size,
        width,
        writable,
        writewidth=None,
        retention=False,
        pwrlanedefs=None,
        title=None,
        default=None,
    ):
        if size:
            modname = "u_%s" % name
            if writable:
                mem = CldRamMod(
                    self,
                    modname,
                    size=size,
                    width=width,
                    title=title,
                    writewidth=writewidth,
                    retention=retention,
                    pwrlanedefs=pwrlanedefs,
                )
                self.add_signal(
                    MemPortType(addrwidth=mem.addrwidth, datawidth=width, wselwidth=mem.wordslices, backpressure=False),
                    "%s_s" % name,
                )

            else:
                content = RomContent(width=width, size=size)
                content.load(f"{self.addrmap_hiername}_{name}", default=default)
                mem = CldRomMod(
                    self,
                    modname,
                    content,
                    writewidth=writewidth,
                    rewritable=True,
                    title=title,
                )
                assert retention is False and pwrlanedefs is None
                self.add_signal(
                    MemPortType(
                        addrwidth=calc_unsigned_width(size / 4 - 1), datawidth=32, wselwidth=4, backpressure=False
                    ),
                    "%s_s" % name,
                )

            self.addrmap.add(mem, baseaddr=baseaddr, size=size)
            mem.con("", "")
            mem.con("dft_mode_i", "dft_mode_i")
            if writable:
                if config.dram_scrm_intf & ("dram" in name):
                    CldMemScramMod(
                        self, "u_mem_scram", addrwidth=mem.addrwidth, datawidth=width, wselwidth=mem.wordslices
                    )
                    self.route("", "u_mem_scram/")
                    mem.con("mem_wdata_i", "u_mem_scram/mem_wdata_o")
                    mem.con("mem_wsel_i", "u_mem_scram/mem_wsel_o")
                    mem.con("mem_wena_i", "u_mem_scram/mem_wena_o")
                    mem.con("mem_ena_i", "u_mem_scram/mem_ena_o")
                    mem.con("mem_rdata_o", "u_mem_scram/mem_rdata_i")
                    mem.con("mem_addr_i", "u_mem_scram/mem_addr_o")

                    self.route("u_mem_scram/mem_wdata_i", f"{name}_wdata_s")
                    self.route("u_mem_scram/mem_wsel_i", f"{name}_wsel_s")
                    self.route("u_mem_scram/mem_wena_i", f"{name}_wena_s")
                    self.route("u_mem_scram/mem_ena_i", f"{name}_ena_s")
                    self.route("u_mem_scram/mem_rdata_o", f"{name}_rdata_s")
                    self.route("u_mem_scram/mem_addr_i", f"{name}_addr_s")
                else:
                    mem.con("mem_wdata_i", f"{name}_wdata_s")
                    mem.con("mem_wsel_i", f"{name}_wsel_s")
                    mem.con("mem_wena_i", f"{name}_wena_s")
                    mem.con("mem_ena_i", f"{name}_ena_s")
                    mem.con("mem_rdata_o", f"{name}_rdata_s")
                    mem.con("mem_addr_i", f"{name}_addr_s")
            else:
                mem.con("mem_ena_i", f"{name}_ena_s")
                mem.con("mem_rdata_o", f"{name}_rdata_s")
                mem.con("mem_addr_i", f"{name}_addr_s")
