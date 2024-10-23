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
import attr
from ucdp_amba.ucdp_ahb_ml import UcdpAhbMlMod
from ucdp_regf.ucdp_regf import UcdpRegfMod, Field, ModuleIdReg, Reg
from ucdp_amba.types import AhbMstType, AmbaProto, AhbSlvType, ApbSlvType, ASecIdType
from ucdp_glbl.dft import DftModeType
# from ucdp_glbl.ucdp_clk_mgate import CldClkMgateMod
# from ucdp_glbl.irq import IrqType
# from cld_mon.monmux import MonMux
# from sidehwgxconfig import ProgMem, create_gxmodule
# from sideutil.num import calc_next_power_of, calc_unsigned_width
from tabulate import tabulate

from iot_riscv.iot_riscv_ahb_config import IotRiscvAhbConfig
from iot_riscv.iot_riscv_ahb_mst import IotRiscvAhbMstMod
from iot_riscv.iot_riscv_core import IotRiscvCoreMod
from iot_riscv.iot_riscv_dm_icache_ahb import IotRiscvDmIcacheAhbMod
from iot_riscv.iot_riscv_mem import IotRiscvMemMod
from iot_riscv.iot_riscv_irq import IotRiscvIrqMod
from iot_riscv.iot_riscv_prng_intf import IotRiscvPrngIntfMod


class IotRiscvAhbMod(u.ATailoredMod):
    """Mini 3-stage RISC-V 32 IMC with AHB."""

    addrmap_name = ""
    copyright_start_year = 2018
    tex_doc = ["entity", "ports"]
    major_version, minor_version = 1, 0
    module_id = 0x1338
    config = u.field(kw_only=True)
    # monmux = MonMux.field()

    @staticmethod
    def build_top(**kwargs):
        """Build top using example config."""
        return IotRiscvAhbExampleMod()

    def _build(self):
        config = self.config

        self.add_port(u.ClkRstAnType(), "main_i", "Clock and Reset")
        self.add_port(DftModeType(), "dft_mode_i")
        self.add_port(AhbMstType(), "ahb_mst_o")
        self.add_port(ApbSlvType(config.ahbproto), "apb_slv_i")
        self.add_port(AhbSlvType(config.ahbproto), "ahb_slv_i")
        self.add_port(u.BitType(), "exception_o")
        self.add_port(u.BitType(), "tim_halt_o")

    #     reset_vec = self.add_localparam(u.UintType(32, default=config.reset_pc), "reset_vec_p")
    #     reset_sp = self.add_localparam(u.UintType(32, default=config.reset_sp), "reset_sp_p")

    #     # Clock Gate for Core/Cache/
    #     rungate = CldClkMgateMod(self, "u_run_gate")
    #     self.add_signal(u.BitType(), "static_core_en_s")
    #     rungate.con("clk_i", "clk_i")
    #     rungate.con("dft_mode_i", "dft_mode_i")
    #     rungate.con("en_i", "create(clk_en_s)")
    #     rungate.con("gclk_o", "create(gclk_s)")
    #     # this is used to gate the mem request signals to avoid blocking the mems while core is halted
    #     # self.route("u_mini_riscv_core/run_en_i", "clk_en_s")

    #     memgate = CldClkMgateMod(self, "u_mem_gate")
    #     memgate.con("clk_i", "clk_i")
    #     memgate.con("dft_mode_i", "dft_mode_i")
    #     memgate.con("en_i", "create(clk_en_mem_s)")
    #     memgate.con("gclk_o", "create(mem_gclk_s)")

    #     # Subsystem Multilayer
    #     ml = CldMlMod(self, "u_ml")
    #     ml.con("", "")
    #     ml.con("dft_mode_i", "dft_mode_i")
    #     ml.add_master("imem")
    #     ml.add_master("dmem")
    #     ml.add_master("ext", route="cast(ahb_slv_i)")  # only connected inside mem module for FPGA

    #     slv = ml.add_slave("ahb_out", masternames=["imem", "dmem"], route="create(ahb_slv_ext_s)")
    #     self.route("ahb_mst_o", "cast(ahb_slv_ext_s)")

    #     slv.add_addrrange(baseaddr=0, size=2**32)

    #     slv.add_exclude_addrrange(config.imem_baseaddr, size=calc_next_power_of(config.irom_size + config.iram_size))
    #     slv.add_exclude_addrrange((config.dmem_baseaddr), size=calc_next_power_of(config.drom_size + config.dram_size))
    #     slv = ml.add_slave("imem", masternames="ext, dmem", route="u_mem/ahb_slv_imem_i")
    #     slv.add_addrrange(baseaddr=config.imem_baseaddr, size=calc_next_power_of(config.irom_size + config.iram_size))
    #     slv = ml.add_slave("dmem", masternames="ext", route="u_mem/ahb_slv_dmem_i")
    #     slv.add_addrrange(baseaddr=(config.dmem_baseaddr), size=calc_next_power_of(config.drom_size + config.dram_size))

    #     # RISC-V Core
    #     riscv = IotRiscvCoreMod(
    #         self,
    #         "u_mini_riscv_core",
    #         paramdict={
    #             "pc_size_p": 32,
    #             "reset_sp_p": reset_sp,
    #             "reset_vec_p": reset_vec,
    #             "irq_width_p": max(1, config.irqs),
    #         },
    #     )

    #     riscv.con("clk_i", "gclk_s")
    #     riscv.con("rst_an_i", "rst_an_i")
    #     riscv.con("dft_mode_i", "dft_mode_i")
    #     riscv.con("lock_o", "u_regf/regf_riscv_except_instr_illegal_val_i")

    #     if config.has_icache:
    #         cache = IotRiscvDmIcacheAhbMod(self, "u_icache")
    #         cache.con("clk_i", "mem_gclk_s")
    #         cache.con("rst_an_i", "rst_an_i")
    #         cache.con("dft_mode_i", "dft_mode_i")
    #         cache.con("mpcb_i", "create(mpcb_icache_i)")
    #         cache.con("ahb_mst_o", "u_ml/ahb_mst_imem_i")

    #     if config.has_prng_intf:
    #         prng_intf = IotRiscvPrngIntfMod(self, "u_prng_intf")
    #         prng_intf.con("clk_i", "gclk_s")
    #         prng_intf.con("dft_mode_i", "dft_mode_i")
    #         prng_intf.con("rst_an_i", "rst_an_i")

    #     mem = IotRiscvMemMod(self, "u_mem", config=config)
    #     mem.con("mpcb_i", "create(mpcb_mem_i)")
    #     mem.con("clk_i", "mem_gclk_s")
    #     mem.con("rst_an_i", "rst_an_i")
    #     mem.con("dft_mode_i", "dft_mode_i")

    #     # memory interface signals, to AHB adapter
    #     dmst = IotRiscvAhbMstMod(
    #         self,
    #         "u_d_ahb_mst",
    #         datawidth=32,
    #         mem_addrwidth=calc_unsigned_width((config.drom_size + config.dram_size) - 1),
    #         mem_baseaddr=config.dmem_baseaddr,
    #         # sec_mem_addrwidth=calc_unsigned_width((config.irom_size + config.iram_size) - 1),
    #         # sec_mem_baseaddr=config.imem_baseaddr,
    #     )
    #     dmst.con("clk_i", "gclk_s")
    #     dmst.con("rst_an_i", "rst_an_i")
    #     dmst.con("r2a_mem_i", "u_mini_riscv_core/d_o")
    #     dmst.con("ahb_mst_o", "u_ml/ahb_mst_dmem_i")
    #     dmst.con("a2m_mem_o", "u_mem/dmem_i")
    #     # dmst.con("a2m_sec_mem_o", "u_mem/d2imem_i")
    #     dmst.con("align_except_o", "u_regf/regf_riscv_except_data_align_val_i")
    #     dmst.con("resp_except_o", "u_regf/regf_riscv_except_data_resp_val_i")
    #     dmst.con("except_addr_o", "u_regf/regf_riscv_data_exaddr_data_exaddr_val_i")
    #     imst = IotRiscvAhbMstMod(
    #         self,
    #         "u_i_ahb_mst",
    #         datawidth=32,
    #         checkx=True,
    #         mem_addrwidth=calc_unsigned_width((config.irom_size + config.iram_size) - 1),
    #         mem_baseaddr=config.imem_baseaddr,
    #         sec_mem_addrwidth=0,
    #         sec_mem_baseaddr=0x00000000,
    #     )
    #     imst.con("clk_i", "gclk_s")
    #     imst.con("rst_an_i", "rst_an_i")
    #     imst.con("r2a_mem_i", "u_mini_riscv_core/i_o")
    #     imst.con("a2m_mem_o", "u_mem/imem_i")
    #     imst.con("align_except_o", "u_regf/regf_riscv_except_instr_align_val_i")
    #     imst.con("resp_except_o", "u_regf/regf_riscv_except_instr_resp_val_i")
    #     imst.con("except_addr_o", "u_regf/regf_riscv_instr_exaddr_instr_exaddr_val_i")
    #     if config.has_icache:
    #         imst.con("ahb_mst_o", "cast(u_icache/ahb_slv_i)")
    #     else:
    #         imst.con("ahb_mst_o", "u_ml/ahb_mst_imem_i")

    #     # APB Debug and Control System
    #     regf = UcdpRegfMod(self, "u_regf", proto=config.apbproto, secnames=config.secnames, addrmap_name="misc")

    #     regf.con("apb_slv_i", "apb_slv_i")
    #     regf.con("clk_i", "clk_i")
    #     regf.con("rst_an_i", "rst_an_i")
    #     regf.con("dft_mode_i", "dft_mode_i")

    #     reg = Reg(regf, "riscv_ctrl", title="RISC-V Control", secnames=(config.core_secname,) + config.ctrl_secnames)
    #     Field(reg, "run_en", u.BitType(default=int(config.run_after_reset)), "RW", title="RISC-V run enable")
    #     self.add_signal(u.BitType(), "regf_run_en_s", route="u_regf/regf_riscv_ctrl_run_en_val_o")

    #     reg = Reg(regf, "riscv_irq_en", title="RISC-V IRQ Enable", secnames=(config.core_secname,))
    #     Field(
    #         reg,
    #         "irq_en",
    #         u.BitType(default=int(config.irq_en_default)),
    #         "RW",
    #         title="IRQ Enable",
    #         route="u_mini_riscv_core/irq_en_i",
    #     )

    #     reg = Reg(regf, "riscv_irq", title="RISC-V IRQs", secnames=(config.core_secname,) + config.ctrl_secnames)
    #     if config.sw_irqs:
    #         Field(reg, "sw_irq", u.UintType(config.sw_irqs), "RO", title="RISC-V Software IRQs", incore=False)
    #         self.route("u_regf/regf_riscv_irq_sw_irq_val_o", "create(sw_irq_s)")
    #         self.route("u_regf/regf_riscv_irq_sw_irq_core_val_i", "create(sw_irq_nxt_s)")
    #         self.route("u_regf/regf_riscv_irq_sw_irq_core_ld_i", "create(sw_irq_ld_s)")
    #     if config.hw_irqs:
    #         self.add_signal(u.UintType(config.hw_irqs), "hw_irq_s")
    #         Field(
    #             reg,
    #             "hw_irq",
    #             u.UintType(config.hw_irqs),
    #             "RO",
    #             route="hw_irq_s",
    #             title="RISC-V Hardware IRQs",
    #         )
    #     if config.irqs:
    #         self.add_signal(u.UintType(config.irqs), "irq_s", route="u_mini_riscv_core/irq_i")

    #     if config.sw_irqs:
    #         reg = Reg(
    #             regf,
    #             "riscv_irq_ctrl",
    #             title="RISC-V SW IRQ Controls",
    #             secnames=(config.core_secname,) + config.ctrl_secnames,
    #         )
    #         Field(
    #             reg,
    #             "sw_irq_set",
    #             u.UintType(config.sw_irqs),
    #             "WO",
    #             title="Set RISC-V Software IRQs",
    #             route="create(set_sw_irq_s)",
    #             updatestrobe=False,
    #         )
    #         Field(
    #             reg,
    #             "sw_irq_clear",
    #             u.UintType(config.sw_irqs),
    #             "WO",
    #             title="Clear RISC-V Software IRQs",
    #             route="create(clear_sw_irq_s)",
    #             updatestrobe=False,
    #         )

    #     reg = Reg(regf, "riscv_irq_mask", title="RISC-V IRQ Masks", secnames=(config.core_secname,))
    #     if config.sw_irqs:
    #         Field(
    #             reg,
    #             "sw_mask",
    #             u.UintType(config.sw_irqs),
    #             "RW",
    #             title="RISC-V Software IRQ mask",
    #             route="create(sw_irq_mask_s)",
    #         )
    #     if config.hw_irqs:
    #         Field(
    #             reg,
    #             "hw_mask",
    #             u.UintType(config.hw_irqs),
    #             "RW",
    #             title="RISC-V Hardware IRQ mask",
    #             route="create(hw_irq_mask_s)",
    #         )
    #     if config.irqs:
    #         self.add_signal(u.UintType(config.irqs), "irq_mask_s", route="u_mini_riscv_core/irq_mask_i")

    #     self.add_signal(u.BitType(), "irq_run_en_s", route="u_mini_riscv_core/irq_run_en_o")
    #     # debug status
    #     reg = Reg(regf, "riscv_debug_status", title="RISC-V Debug Status")
    #     Field(reg, "debug_halt", u.BitType(), "RO", title="Halted by Breakpoint")
    #     Field(reg, "debug_halt_data", u.BitType(), "RO", title="Halted by Data-Breakpoint")

    #     # create debug controls for pausing, stepping and continuing
    #     reg = Reg(
    #         regf,
    #         "riscv_debug_ctrl",
    #         title="RISC-V Debug Controls",
    #         descr="pause and step will perform a single step\nnot pause and step will let the core continue\n"
    #         "pause and not step will halt the core",
    #     )
    #     Field(reg, "step", u.BitType(), "WO", title="Step out of breakpoint")
    #     Field(reg, "pause", u.BitType(), "RW", title="Halt at next instruction")
    #     Field(reg, "rom_unlock", u.BitType(), "RW", title="Unlock ROMs for preloading. Not available on ASIC.")
    #     self.route("u_regf/regf_riscv_debug_ctrl_rom_unlock_val_o", "u_mem/debug_rom_unlock_i")

    #     if config.has_icache:
    #         reg = Reg(regf, "cache_ctrl", title="Cache Controls", secnames=(config.core_secname,))
    #         Field(reg, "flush", u.BitType(), "WO", title="Force I-cache flush")
    #         self.route("u_regf/regf_cache_ctrl_flush_bus_val_o", "u_icache/flush_i")
    #         Field(reg, "bypass", u.BitType(), "RW", title="Force Cache Bypass")
    #         self.route("u_regf/regf_cache_ctrl_bypass_val_o", "u_icache/bypass_en_i")

    #     # effective debug halt signals
    #     self.add_signal(u.BitType(), "debug_halt_s", route="u_regf/regf_riscv_debug_status_debug_halt_val_i")
    #     self.add_signal(u.BitType(), "debug_halt_data_s", route="u_regf/regf_riscv_debug_status_debug_halt_data_val_i")
    #     if config.has_prng_intf:
    #         self.route("u_regf/regf_riscv_debug_ctrl_pause_val_o", "u_prng_intf/prng_intf_debug_pause_i")
    #         self.route("u_regf/regf_riscv_debug_ctrl_step_bus_val_o", "u_prng_intf/prng_intf_debug_step_i")
    #         self.route("u_prng_intf/prng_intf_debug_halt_o", "debug_halt_s")
    #         self.route("u_prng_intf/prng_intf_debug_halt_data_o", "debug_halt_data_s")

    #         self.route("u_prng_intf/prng_intf_debug_pause_o", "u_mini_riscv_core/riscv_debug_pause_i")
    #         self.route("u_prng_intf/prng_intf_debug_step_o", "u_mini_riscv_core/riscv_debug_step_i")
    #         self.route("u_prng_intf/prng_intf_debug_halt_i", "u_mini_riscv_core/debug_halt_o")
    #         self.route("u_prng_intf/prng_intf_debug_halt_data_i", "u_mini_riscv_core/debug_halt_data_o")
    #         self.route("u_prng_intf/prng_intf_debug_break_i", "u_mini_riscv_core/riscv_debug_break_o")
    #         reg = Reg(
    #             regf,
    #             "prng_intf",
    #             title="RISC-V PRNG Interface Controls",
    #             secnames=(config.core_secname,),
    #             descr="Control signals to enable and update Prng Interface.",
    #         )
    #         Field(
    #             reg,
    #             "en",
    #             u.UintType(4, default=0x9),
    #             "RW",
    #             title=" Random Breakpoint Insertion enable",
    #             descr="At default disabled by magic word 0x9. Any other value is enable.",
    #         )
    #         Field(
    #             reg,
    #             "update",
    #             u.BitType(),
    #             "WO",
    #             title=" Update LFSR with prng_intf_lfsr Value with lfsr ",
    #             descr="Control signal to update the LFRS of the PRNG Interface",
    #         )
    #         Field(
    #             reg,
    #             "lfsr",
    #             u.UintType(16),
    #             "RW",
    #             title=" Value to update LFSR",
    #             descr="Value to update the LFRS of the PRNG Interface",
    #         )
    #         self.route("u_regf/regf_prng_intf_en_val_o", "u_prng_intf/prng_intf_en_i")
    #         self.route("u_regf/regf_prng_intf_update_bus_val_o", "u_prng_intf/prng_intf_update_i")
    #         self.route("u_regf/regf_prng_intf_lfsr_val_o", "u_prng_intf/prng_intf_lfsr_i")
    #     else:
    #         self.route("u_regf/regf_riscv_debug_ctrl_pause_val_o", "u_mini_riscv_core/riscv_debug_pause_i")
    #         self.route("u_regf/regf_riscv_debug_ctrl_step_bus_val_o", "u_mini_riscv_core/riscv_debug_step_i")
    #         self.route("u_mini_riscv_core/debug_halt_o", "debug_halt_s")
    #         self.route("u_mini_riscv_core/debug_halt_data_o", "debug_halt_data_s")

    #     if config.dram_scrm_intf:
    #         reg = Reg(regf, "riscv_dram_scram_addr", title="Address scramble mask", secnames=(config.core_secname,))
    #         Field(
    #             reg,
    #             "mask",
    #             u.UintType(11),
    #             "WO",
    #             incore=False,
    #             updatestrobe=False,
    #             title="XOR mask for DRAM address scrambling",
    #         )
    #         self.route("u_regf/regf_riscv_dram_scram_addr_mask_val_o", "create(u_mem/addr_scram_mask_i)")
    #         self.route("u_mem/addr_scram_mask_i", "u_mem/u_mem_scram/addr_scram_mask_i")

    #         reg = Reg(regf, "riscv_dram_scram_data", title="Data scramble mask", secnames=(config.core_secname,))
    #         Field(
    #             reg,
    #             "mask",
    #             u.UintType(32),
    #             "WO",
    #             incore=False,
    #             updatestrobe=False,
    #             title="XOR mask for DRAM data scrambling",
    #         )
    #         self.route("u_regf/regf_riscv_dram_scram_data_mask_val_o", "create(u_mem/data_scram_mask_i)")
    #         self.route("u_mem/data_scram_mask_i", "u_mem/u_mem_scram/data_scram_mask_i")

    #     # construct 2 hardware breakpoint registers
    #     for i in range(2):
    #         reg = Reg(regf, f"riscv_bp{i}", title=f"RISC-V Breakpoint Register {i}")
    #         Field(reg, "bp_en", u.BitType(), "RW", title="Breakpoint enable")
    #         Field(reg, "bp_addr", u.UintType(31), "RW", title="Breakpoint word address")
    #         self.route(f"u_regf/regf_riscv_bp{i}_bp_addr_val_o", f"u_mini_riscv_core/riscv_bp{i}_bp_addr_i")
    #         self.route(f"u_regf/regf_riscv_bp{i}_bp_en_val_o", f"u_mini_riscv_core/riscv_bp{i}_bp_en_i")

    #     # construct 2 hardware data-breakpoint registers
    #     for i in range(2):
    #         reg = Reg(regf, f"riscv_dbp{i}", title=f"RISC-V Data-Breakpoint Register {i}")
    #         Field(reg, "dbp_en", u.BitType(), "RW", title="Data-Breakpoint enable")
    #         Field(reg, "dbp_wr", u.BitType(), "RW", title="Data-Breakpoint on write")
    #         Field(reg, "dbp_addr", u.UintType(30), "RW", title="Data-Breakpoint word address")
    #         self.route(f"u_regf/regf_riscv_dbp{i}_dbp_en_val_o", f"u_mini_riscv_core/riscv_dbp{i}_dbp_en_i")
    #         self.route(f"u_regf/regf_riscv_dbp{i}_dbp_wr_val_o", f"u_mini_riscv_core/riscv_dbp{i}_dbp_wr_i")
    #         self.route(f"u_regf/regf_riscv_dbp{i}_dbp_addr_val_o", f"u_mini_riscv_core/riscv_dbp{i}_dbp_addr_i")

    #     # create read-only regf connections for all 32 core registers and the current program counter
    #     for i in range(32):
    #         reg = Reg(regf, f"riscv_reg_x{i}", title=f"RISC-V Internal Register {i}")
    #         Field(reg, "val", u.UintType(32), "RO", title="RISC-V Register Value")
    #         self.route(f"u_regf/regf_riscv_reg_x{i}_val_val_i", f"u_mini_riscv_core/riscv_reg_x{i}_o")
    #     reg = Reg(regf, "riscv_pc", title="RISC-V Internal PC Register")
    #     Field(reg, "val", u.UintType(32), "RO", title="RISC-V PC Value")
    #     self.route("u_regf/regf_riscv_pc_val_val_i", "u_mini_riscv_core/riscv_reg_pc_o")

    #     reg = Reg(regf, "riscv_mscratch", title="RISC-V mscratch Register")
    #     Field(reg, "mscratch", u.UintType(32), "RO", title="RISC-V mscratch")
    #     self.route("u_regf/regf_riscv_mscratch_mscratch_val_i", "u_mini_riscv_core/mscratch_o")

    #     reg = Reg(regf, "riscv_mtvec", title="RISC-V mtvec Register")
    #     Field(reg, "mtvec", u.UintType(32), "RO", title="RISC-V mtvec")
    #     self.route("u_regf/regf_riscv_mtvec_mtvec_val_i", "u_mini_riscv_core/mtvec_o")

    #     reg = Reg(regf, "riscv_mepc", title="RISC-V mepc Register")
    #     Field(reg, "mepc", u.UintType(32), "RO", title="RISC-V mepc")
    #     self.route("u_regf/regf_riscv_mepc_mepc_val_i", "u_mini_riscv_core/mepc_o")

    #     reg = Reg(regf, "riscv_misa", title="RISC-V misa Register")
    #     Field(reg, "misa", u.UintType(32, default=0x40001104), "RO", title="RISC-V misa")  # make this a type
    #     self.add_signal(u.UintType(32), "riscv_misa_s")
    #     self.route("u_regf/regf_riscv_misa_misa_val_i", "riscv_misa_s")

    #     reg = Reg(regf, "riscv_mvendorid", title="RISC-V mvendorid Register")
    #     Field(reg, "mvendorid", u.UintType(32), "RO", title="RISC-V mvendorid")
    #     self.add_signal(u.UintType(32), "riscv_mvendorid_s")
    #     self.route("u_regf/regf_riscv_mvendorid_mvendorid_val_i", "riscv_mvendorid_s")

    #     reg = Reg(regf, "riscv_marchid", title="RISC-V marchid Register")
    #     Field(reg, "marchid", u.UintType(32), "RO", title="RISC-V marchid")
    #     self.add_signal(u.UintType(32), "riscv_marchid_s")
    #     self.route("u_regf/regf_riscv_marchid_marchid_val_i", "riscv_marchid_s")

    #     reg = Reg(regf, "riscv_mimpid", title="RISC-V mimpid Register")
    #     Field(reg, "mimpid", u.UintType(32), "RO", title="RISC-V mimpid")
    #     self.add_signal(u.UintType(32), "riscv_mimpid_s")
    #     self.route("u_regf/regf_riscv_mimpid_mimpid_val_i", "riscv_mimpid_s")

    #     reg = Reg(regf, "riscv_mhartid", title="RISC-V mhartid Register")
    #     Field(reg, "mhartid", u.UintType(32), "RO", title="RISC-V mhartid")
    #     self.add_signal(u.UintType(32), "riscv_mhartid_s")
    #     self.route("u_regf/regf_riscv_mhartid_mhartid_val_i", "riscv_mhartid_s")

    #     reg = Reg(regf, "riscv_except", title="RISC-V Exception Indicator Register")
    #     Field(reg, "instr_align", u.BitType(), "RO", title="RISC-V Instruction Alignment Exception")
    #     Field(reg, "instr_resp", u.BitType(), "RO", title="RISC-V Instruction Response Exception")
    #     Field(reg, "instr_illegal", u.BitType(), "RO", title="RISC-V Instruction Illegal Exception")
    #     Field(reg, "data_align", u.BitType(), "RO", title="RISC-V Data Alignment Exception")
    #     Field(reg, "data_resp", u.BitType(), "RO", title="RISC-V Data Response Exception")

    #     reg = Reg(regf, "riscv_instr_exaddr", title="RISC-V Exception Address Register")
    #     Field(
    #         reg,
    #         "instr_exaddr",
    #         u.UintType(32),
    #         "RO",
    #         title="RISC-V Instruction Exception Address",
    #         descr="This does not indicate position of an illegal instruction, refer to PC debug register for that.",
    #     )

    #     reg = Reg(regf, "riscv_data_exaddr", title="RISC-V Exception Indicator Register")
    #     Field(reg, "data_exaddr", u.UintType(32), "RO", title="RISC-V Instruction Exception Address")

    #     if config.has_static_enable:
    #         reg = Reg(regf, "core_en", title="RISC-V static core enable", secnames=config.enable_secnames)
    #         Field(reg, "en", u.BitType(), "RW", title="RISC-V static core enable", route="static_core_en_s")

    #     reg = Reg(regf, "core_id", title="RISC-V Core ID", offs=0xFF8)
    #     Field(reg, "id", u.UintType(16, default=config.core_id), "RO", title="RISC-V Core ID")

    #     ModuleIdReg(regf, secnames=(config.core_secname,) + config.enable_secnames + config.ctrl_secnames)

    #     if config.hw_irqs:
    #         irqmap = IotRiscvIrqMod(self, "u_irqmap", num_of_irqs=config.hw_irqs)
    #         irqmap.con("", "")
    #         irqmap.con("dft_mode_i", "dft_mode_i")
    #         # irqmap.con("irq_o", "hw_irq_s")

    #     # -----------------------------
    #     # Monitoring
    #     # -----------------------------

    #     # self.monmux.init(4)
    #     # self.monmux.create_ports()
    #     # self.monmux.add_module_id(self.module_id)

    #     # vec = self.monmux.add_vector("ahb", title="AHB Interface")
    #     # vec.add_slice("htrans", "ahb_mst_htrans_o")
    #     # vec.add_slice("hwrite", "ahb_mst_hwrite_o")
    #     # vec.add_slice("hready", "ahb_mst_hready_i")
    #     # vec.add_slice("hresp", "ahb_mst_hresp_i")

    #     # self.monmux.add_vector("irq", title="Hardware IRQ's")

    # def add_irq(self, name, title=None, descr=None, comment=None, route=None, sync=False):
    #     """
    #     Add interrupt.

    #     Args:
    #         name (str): Name

    #     Keyword Args:
    #         title (str): Display Name.
    #         descr (str):    Description.
    #         comment (str):  Source Code Comment.
    #         route (str): Name of signal to route interrupt from.
    #         createroute (str): Name of port to create and route interrupt from.
    #         sync (bool): Synchronize interrupt to current clock domain.
    #     """
    #     irqmap = self.insts["u_irqmap"]
    #     portname = f"irq_{name}_i"
    #     port = self.add_port(IrqType(), portname, title=title, descr=descr, comment=comment)
    #     assert self.config.hw_irqs
    #     irqmap.add_irq(name, title=title, descr=descr, comment=comment, route=portname, sync=sync)
    #     # vec = self.monmux.monvectors["irq"]
    #     # vec.add_slice(f"irq_{name}", port)
    #     if route:
    #         self.con(portname, route)

    # def iter_addrmap(self, is_fpga=False, is_hwdrv=False, user=None, **kwargs):
    #     """Iterate over Addressmap."""
    #     # if is_fpga or (is_hwdrv and user in (None, self.config.core_sec_id)):
    #     yield from self.get_inst("u_mem").iter_addrmap()
    #     #     is_fpga=is_fpga, is_hwdrv=is_hwdrv, user=user, **kwargs
    #     # )

    # def get_gxmodule(self, **kwargs):
    #     """Program Memory Descriptor."""
    #     config = self.config
    #     attrs = {
    #         "irq_vec": config.irq_vec,
    #     }
    #     return create_gxmodule(self, progmems=self.iter_progmems(), attrs=attrs)

    # def iter_progmems(self):
    #     config = self.config
    #     name = self.addrmap_hiername
    #     if config.drom_size:
    #         yield ProgMem(f"{name}_drom", config.drom_baseaddr, config.drom_size, "r", localname="drom")
    #     if config.dram_size:
    #         yield ProgMem(f"{name}_dram", config.dram_baseaddr, config.dram_size, "rw", localname="dram")
    #     if config.irom_size:
    #         yield ProgMem(f"{name}_irom", config.irom_baseaddr, config.irom_size, "r", localname="irom")
    #     if config.iram_size:
    #         yield ProgMem(f"{name}_iram", config.iram_baseaddr, config.iram_size, "rw", localname="iram")
    #     yield from config.add_progmems

    # def get_overview(self):
    #     def _iter(config):
    #         yield from attr.asdict(config, recurse=False).items()

    #     return tabulate(_iter(self.config), headers=("Parameter", "Value"))


class IotRiscvAhbExampleMod(u.AMod):
    # tex_doc = None
    # copyright_end_year = 2022
    # addrmap_name = ""

    def _build(self):
    #     class SecIdType(ASecIdType):
    #         def _build(self):
    #             self._add(0, "riscv")
    #             self._add(2, "apps")
    #             self._add(5, "dbg")

    #     ahb5 = AmbaProto("ahb5", secidtype=SecIdType(default=5))
    #     apb5 = AmbaProto("apb5", secidtype=SecIdType(default=5))
    #     exampleconfig = IotRiscvAhbConfig(
    #         "example",
    #         ahbproto=ahb5,
    #         apbproto=apb5,
    #         has_icache=True,
    #         run_after_reset=False,
    #         has_prng_intf=True,
    #         irq_vec=0xC0040000,
    #         drom_size=0,
    #         dram_size="8kB",
    #         irom_size="8kB",
    #         iram_size=0,
    #         dmem_width=32,
    #         imem_width=32,
    #         has_static_enable=True,
    #         secnames="dbg; riscv",
    #         core_secname="riscv",
    #         add_progmems=[ProgMem("tb_ram", 0xC0040000, "64kB")],
    #     )

    #     mod = IotRiscvAhbMod(self, "u_riscv", config=exampleconfig, addrmap_name="riscv")
    #     mod.add_irq("abc")
    #     mod.add_irq("foo", sync=True)
    #     mod.add_irq("bar", sync=True)

    #     return mod
