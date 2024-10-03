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
#from iot_dft.types import DftModeType

from iot_riscv.iot_riscv_alu import IotRiscvAluMod
from iot_riscv.iot_riscv_compressed_decoder import IotRiscvCompressedDecoderMod
from iot_riscv.iot_riscv_csr import IotRiscvCsrMod
from iot_riscv.iot_riscv_dbg import IotRiscvDbgMod
from iot_riscv.iot_riscv_decoder import IotRiscvDecoderMod
from iot_riscv.iot_riscv_fetch import IotRiscvFetchMod
from iot_riscv.iot_riscv_hazard_unit import IotRiscvHazardUnitMod
from iot_riscv.iot_riscv_int_irq import IotRiscvIntIrqMod

from iot_riscv.iot_riscv_lsu import IotRiscvLsuMod
from iot_riscv.iot_riscv_regfile import IotRiscvRegfileMod
from iot_riscv.types import IotRiscvRamDataType
from iot_riscv.types import WritebackType


class IotRiscvCoreMod(u.AMod):
    filelists: u.ClassVar[u.ModFileLists] = (
        u.ModFileList(
            name="hdl",
            # full, inplace, no
            gen="full",
            filepaths=("rtl/{mod.modname}.sv"),
            template_filepaths=("rtl/{modref.modname}.sv.mako","sv.mako"),
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
        self.add_port(u.ClkRstAnType(), "main_i")
#        self.add_port(DftModeType(), "dft_mode_i", title="DFT Mode")
        self.add_port(u.BitType(), "lock_o")
        # self.add_port(u.BitType(), "run_en_i")
        # IMEM related ports
        self.add_port(IotRiscvRamDataType(addrwidth=32, datawidth=32), "i_o")
        # DMEM related ports
        self.add_port(IotRiscvRamDataType(addrwidth=32, datawidth=32), "d_o")
        # Debug
        self.add_port(u.BitType(), "debug_halt_o")
        self.add_port(u.BitType(), "debug_halt_data_o")
        # CSRs
        self.add_port(u.UintType(32), "mscratch_o")
        self.add_port(u.UintType(32), "mepc_o")
        self.add_port(u.UintType(32), "mtvec_o")

        # Verilog Parameters
        pc_width = self.add_param(u.UintType(32, default=32), "pc_size_p")
        self.add_param(u.UintType(32, default=0x00002000), "reset_sp_p")
        reset_vec = self.add_param(u.UintType(32, default=0x00000000), "reset_vec_p")

        # Debug Interface
        # create read-only regf connections for all 32 core registers and the current program counter
        for i in range(32):
            self.add_port(u.UintType(32), f"riscv_reg_x{i}_o")
        self.add_port(u.UintType(32), "riscv_reg_pc_o")

        # pause and step controls
        self.add_port(u.BitType(), "riscv_debug_pause_i")
        self.add_port(u.BitType(), "riscv_debug_step_i")
        self.add_port(u.BitType(), "riscv_debug_break_o")

        # construct 2 hardware breakpoint ports
        for i in range(2):
            self.add_port(u.UintType(31), f"riscv_bp{i}_bp_addr_i")
            self.add_port(u.BitType(), f"riscv_bp{i}_bp_en_i")

        # construct 2 hardware data-breakpoint registers
        for i in range(2):
            self.add_port(u.BitType(), f"riscv_dbp{i}_dbp_en_i")
            self.add_port(u.BitType(), f"riscv_dbp{i}_dbp_wr_i")
            self.add_port(u.UintType(30), f"riscv_dbp{i}_dbp_addr_i")

        # IRQ lines
        self.add_port(u.EnaType(default=1), "irq_en_i")
        self.add_port(u.UintType(irq_width_p), "irq_i")
        self.add_port(u.UintType(irq_width_p), "irq_mask_i")
        self.add_port(u.BitType(), "irq_run_en_o")

        self.add_signal(u.UintType(pc_width), "if_next_pc_s")
        self.add_signal(u.BitType(), "id_hazard_r")
        self.add_signal(u.BitType(), "ex_hazard_r")
        self.add_signal(u.UintType(5), "id_rd_index_r")
        self.add_signal(u.UintType(12), "id_csr_addr_r")
        self.add_signal(u.BitType(), "id_mem_rd_r")
        self.add_signal(u.BitType(), "id_mem_wr_r")
        self.add_signal(u.BitType(), "id_mem_signed_r")
        self.add_signal(u.UintType(2), "id_mem_size_r")
        self.add_signal(u.BitType(), "id_csrrw_r")

        self.add_signal(u.BitType(), "ex_bubble_s")
        self.add_signal(u.BitType(), "ex_ready_s")

        self.add_signal(u.BitType(), "branch_hold_r")

        self.add_signal(WritebackType(), "rd_s")

        # Modules instantiation

        # FETCH Unit

        fetch = IotRiscvFetchMod(
            self,
            "u_fetch",
            paramdict={
                "pc_size_p": pc_width,
                "reset_vec_p": reset_vec,
            },
        )
        fetch.con("main_i", "main_i")
        fetch.con("i_o", "i_o")
        fetch.con("debug_halt_i", "create(debug_halt_s)")
        fetch.con("debug_halt_data_i", "create(debug_halt_data_s)")
        fetch.con("debug_single_step_i", "create(debug_single_step_s)")
        fetch.con("branch_taken_i", "create(branch_taken_s)")
        fetch.con("jump_addr_i", "create(jump_addr_s)")
        fetch.con("if_pc_i", "if_pc_r")
        fetch.con("hazard_i", "create(hazard_s)")
        fetch.con("if_rv_o", "create(if_rv_s)")
        fetch.con("if_valid_o", "create(if_valid_s)")
        fetch.con("if_rv_op_o", "create(if_rv_op_s)")
        fetch.con("if_break_exit_o", "create(if_break_exit_r)")
        # fetch.con("run_en_i", "run_en_i")
        fetch.con("if_hold_state_o", "create(if_hold_state_s)")

        # COMPRESSED DECODER
        comp_decoder = IotRiscvCompressedDecoderMod(self, "u_compressed_decoder")
        comp_decoder.con("rvc_op_i", "u_fetch/if_rvc_op_o")
        comp_decoder.con("rvc_dec_o", "create(if_rvc_dec_s)")

        decoder = IotRiscvDecoderMod(self, "u_decoder")
        decoder.con("rv_op_i", "create(if_opcode_s)")
        decoder.con("break_o", "create(break_s)")
        decoder.con("id_rd_index_o", "create(id_rd_index_s)")
        decoder.con("id_csr_addr_o", "create(id_csr_addr_s)")
        decoder.con("id_imm_o", "create(id_imm_s)")
        decoder.con("id_a_signed_o", "create(id_a_signed_s)")
        decoder.con("id_b_signed_o", "create(id_b_signed_s)")
        decoder.con("id_op_imm_o", "create(id_op_imm_s)")
        decoder.con("id_alu_op_o", "create(id_alu_op_s)")
        decoder.con("load_o", "create(load_s)")
        decoder.con("store_o", "create(store_s)")
        decoder.con("id_mem_signed_o", "create(id_mem_signed_s)")
        decoder.con("id_mem_size_o", "create(id_mem_size_s)")
        decoder.con("id_branch_o", "create(id_branch_s)")
        decoder.con("id_reg_jump_o", "create(jalr_s)")
        decoder.con("id_lock_o", "create(id_illegal_s)")
        decoder.con("id_csrrw_o", "create(csrrw_s)")
        decoder.con("id_mret_o", "create(mret_s)")
        decoder.con("id_ra_index_o", "create(id_ra_index_s)")
        decoder.con("id_rb_index_o", "create(id_rb_index_s)")

        regfile = IotRiscvRegfileMod(self, "u_regfile")
        regfile.con("main_i", "main_i")
        regfile.con("id_ra_value_o", "create(id_ra_value_s)")
        regfile.con("id_rb_value_o", "create(id_rb_value_s)")
        for i in range(32):
            regfile.con(f"riscv_reg_x{i}_o", f"riscv_reg_x{i}_o")
        regfile.con("id_flush_i", "id_clear_s")
        regfile.con("id_ready_i", "create(id_ready_s)")
        regfile.con("id_ra_index_i", "id_ra_index_s")
        regfile.con("id_rb_index_i", "id_rb_index_s")
#        regfile.con("rd_i", "u_lsu/rd_o")
        regfile.con("rd_i", "rd_s")

        alu = IotRiscvAluMod(
            self,
            "u_alu",
            paramdict={
                "pc_size_p": pc_width,
            },
        )
        alu.con("main_i", "main_i")
        alu.con("id_rb_value_i", "id_rb_value_s")
        alu.con("id_ra_value_i", "id_ra_value_s")
        alu.con("id_op_imm_i", "create(id_op_imm_r)")
        alu.con("id_imm_i", "create(id_imm_r)")
        alu.con("id_alu_op_i", "create(id_alu_op_r)")
        alu.con("id_a_signed_i", "create(id_a_signed_r)")
        alu.con("id_b_signed_i", "create(id_b_signed_r)")
        alu.con("id_break_i", "create(id_break_r)")
        alu.con("id_pc_i", "create(id_pc_r)")
        alu.con("id_irq_i", "create(id_irq_r)")
        alu.con("id_mret_i", "create(id_mret_r)")
        alu.con("id_branch_i", "create(id_branch_r)")
        alu.con("id_reg_jump_i", "create(id_reg_jump_r)")
        alu.con("mtvec_i", "mtvec_o")
        alu.con("mepc_i", "mepc_o")
        alu.con("branch_taken_o", "branch_taken_s")
        alu.con("jump_addr_o", "jump_addr_s")
        alu.con("ex_alu_res_o", "create(ex_alu_res_s)")
        alu.con("ex_stall_o", "create(ex_stall_s)")
        alu.con("id_next_pc_i", "create(id_next_pc_r)")

        lsu = IotRiscvLsuMod(self, "u_lsu")
        lsu.con("main_i", "main_i")
        lsu.con("d_o", "d_o")
        lsu.con("ex_alu_res_i", "create(ex_alu_res_r)")
        lsu.con("ex_mem_data_i", "create(ex_mem_data_r)")
        lsu.con("ex_mem_size_i", "create(ex_mem_size_r)")
        lsu.con("ex_mem_signed_i", "create(ex_mem_signed_r)")
        lsu.con("ex_mem_rd_i", "create(ex_mem_rd_r)")
        lsu.con("ex_mem_wr_i", "create(ex_mem_wr_r)")
        lsu.con("ex_rd_index_i", "create(ex_rd_index_r)")
        lsu.con("ex_csrrw_i", "create(ex_csrrw_r)")
        lsu.con("csr_rd_value_i", "u_csr/csr_rd_value_o")
        lsu.con("mem_stall_o", "create(mem_stall_r)")
        lsu.con("mem_stall_comb_o", "create(mem_stall_s)")
        lsu.con("rd_o", "rd_s")
        # lsu.con("run_en_i", "run_en_i")

        csr = IotRiscvCsrMod(
            self,
            "u_csr",
            paramdict={
                "pc_size_p": pc_width,
            },
        )
        csr.con("main_i", "main_i")
        csr.con("ex_csr_addr_i", "create(ex_csr_addr_r)")
        csr.con("ex_alu_res_i", "ex_alu_res_r")
        csr.con("id_pc_i", "id_pc_r")

        csr.con("mscratch_o", "mscratch_o")
        csr.con("mepc_o", "mepc_o")
        csr.con("mtvec_o", "mtvec_o")

        dbg = IotRiscvDbgMod(
            self,
            "u_dbg",
            paramdict={
                "pc_size_p": pc_width,
            },
        )
        dbg.con("main_i", "main_i")
        dbg.con("debug_halt_comb_o", "debug_halt_s")
        dbg.con("debug_halt_data_comb_o", "debug_halt_data_s")
        dbg.con("debug_single_step_o", "debug_single_step_s")
        dbg.con("debug_halt_o", "create(debug_halt_r)")
        dbg.con("debug_halt_data_o", "create(debug_halt_data_r)")
        dbg.con("if_pc_i", "create(if_pc_r)")
        dbg.con("branch_taken_i", "branch_taken_s")
        dbg.con("riscv_debug_pause_i", "riscv_debug_pause_i")
        dbg.con("riscv_debug_step_i", "riscv_debug_step_i")
        dbg.con("riscv_debug_break_o", "riscv_debug_break_o")
        dbg.con("d_addr_i", "d_addr_o")
        dbg.con("d_rdy_i", "d_rdy_i")
        dbg.con("ex_mem_rd_i", "ex_mem_rd_r")
        dbg.con("ex_mem_wr_i", "ex_mem_wr_r")
        dbg.con("mem_stall_i", "mem_stall_r")

        dbg.con("id_exec_i", "id_ready_s")
        dbg.con("id_bubble_i", "id_clear_s")
        dbg.con("id_break_i", "id_break_r")

        # construct 2 hardware breakpoint ports
        for i in range(2):
            dbg.con(f"riscv_bp{i}_bp_addr_i", f"riscv_bp{i}_bp_addr_i")
            dbg.con(f"riscv_bp{i}_bp_en_i", f"riscv_bp{i}_bp_en_i")

        # construct 2 hardware data-breakpoint registers
        for i in range(2):
            dbg.con(f"riscv_dbp{i}_dbp_en_i", f"riscv_dbp{i}_dbp_en_i")
            dbg.con(f"riscv_dbp{i}_dbp_wr_i", f"riscv_dbp{i}_dbp_wr_i")
            dbg.con(f"riscv_dbp{i}_dbp_addr_i", f"riscv_dbp{i}_dbp_addr_i")

        int_irq = IotRiscvIntIrqMod(
            self,
            "u_int_irq",
            paramdict={
                "irq_width_p": irq_width_p,
            },
        )
        int_irq.con("main_i", "main_i")
        int_irq.con("irq_en_i", "irq_en_i")
        int_irq.con("irq_i", "irq_i")
        int_irq.con("irq_mask_i", "irq_mask_i")
        int_irq.con("irq_run_en_o", "irq_run_en_o")

        int_irq.con("debug_halt_i", "debug_halt_s")
        int_irq.con("debug_single_step_i", "debug_single_step_s")
        int_irq.con("debug_halt_data_i", "debug_halt_data_s")
        int_irq.con("irq_hot_o", "create(irq_hot_s)")
        int_irq.con("id_irq_i", "id_irq_r")
        int_irq.con("id_mret_i", "id_mret_r")

        hz_unit = IotRiscvHazardUnitMod(self, "u_hazard_unit")
        hz_unit.con("id_ra_index_i", "id_ra_index_s")
        hz_unit.con("id_rb_index_i", "id_rb_index_s")

        hz_unit.con("ex_stall_i", "ex_stall_s")
        hz_unit.con("alu_res_i", "ex_alu_res_s")
        hz_unit.con("id_csrrw_i", "id_csrrw_r")
        hz_unit.con("id_mem_rd_i", "id_mem_rd_r")
        hz_unit.con("exe_rd_index_i", "id_rd_index_r")

        hz_unit.con("mem_stall_i", "mem_stall_s")
        hz_unit.con("mem_rd_index_i", "ex_rd_index_r")
#        hz_unit.con("mem_rd_value_i", "regfile_rd_i_value_s")
        hz_unit.con("mem_rd_value_i","rd_value_s")

        hz_unit.con("hazard_o", "hazard_s")
        hz_unit.con("branch_taken_i", "branch_taken_s")
        hz_unit.con("id_lock_i", "create(id_lock_r)")
        hz_unit.con("if_valid_i", "if_valid_s")
        hz_unit.con("id_ready_o", "id_ready_s")
        hz_unit.con("ex_ready_o", "ex_ready_s")

        hz_unit.con("id_clear_o", "create(id_clear_s)")
        hz_unit.con("ex_clear_o", "create(ex_clear_s)")

        hz_unit.con("fwd_data_o", "u_regfile/fwd_data_i")
        hz_unit.con("fwd_a_en_o", "u_regfile/fwd_a_en_i")
        hz_unit.con("fwd_b_en_o", "u_regfile/fwd_b_en_i")
        hz_unit.con("if_hold_state_i", "if_hold_state_s")

        # hz_unit.con("branch_hold_i", "branch_hold_r")
        # hz_unit.con("branch_sent_i", "create(branch_sent_r)")
