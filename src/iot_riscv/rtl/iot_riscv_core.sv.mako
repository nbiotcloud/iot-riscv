<%inherit file="sv.mako"/>\
<%def name="logic(*args, **kwargs)">\
  ${parent.logic(*args, **kwargs)}\

`define ENABLE_COMPRESSED_ISA
`define USE_BARREL_SHIFTER
`define USE_NATIVE_MULTIPLIER

localparam ALU_ADD   = 4'd0;
localparam ALU_SUB   = 4'd1;
localparam ALU_AND   = 4'd2;
localparam ALU_OR    = 4'd3;
localparam ALU_XOR   = 4'd4;
localparam ALU_SLT   = 4'd5;
localparam ALU_SLTU  = 4'd6;
localparam ALU_SHL   = 4'd7;
localparam ALU_SHR   = 4'd8;
localparam ALU_MULL  = 4'd9;
localparam ALU_MULH  = 4'd10;
localparam ALU_DIV   = 4'd11;
localparam ALU_REM   = 4'd12;
localparam ALU_NPC   = 4'd13;
localparam ALU_AUIPC = 4'd14;
localparam ALU_RA    = 4'd15;

localparam BR_NONE   = 3'd0;
localparam BR_JUMP   = 3'd1;
localparam BR_EQ     = 3'd2;
localparam BR_NE     = 3'd3;
localparam BR_LT     = 3'd4;
localparam BR_GE     = 3'd5;
localparam BR_LTU    = 3'd6;
localparam BR_GEU    = 3'd7;

localparam SIZE_BYTE = 2'd0;
localparam SIZE_HALF = 2'd1;
localparam SIZE_WORD = 2'd2;


localparam ebreak_p = { 11'h000, 1'b1, 13'h0000, 7'b1110011 };
localparam irq_p    = { 12'h341, 5'h00, 3'h1, 5'h00, 7'b1110011 };

/*------------------------------------------------------------------------------
--  Instruction Fetch Pipeline Registers
------------------------------------------------------------------------------*/

always @(posedge clk_i or negedge rst_an_i) begin : proc_if_pc
  if (rst_an_i == 1'b0) begin
    if_pc_r <= #`dly reset_vec_p;
  end else if (branch_taken_s == 1'b1) begin
    if_pc_r <= #`dly jump_addr_s[pc_size_p-1:0];
  end else if ((~hazard_s & if_valid_s & ~if_break_exit_r) == 1'b1) begin
    if_pc_r <= #`dly if_next_pc_s;
  end
end

assign if_next_pc_s = if_hold_state_s ? if_pc_r : if_pc_r + (if_rv_s ? 'd4 : 'd2);

// To select instruction for decoding
always_comb begin : proc_if_opcode
  if (((debug_halt_r | debug_halt_data_r) & ~debug_single_step_s) == 1'b1) begin //breakpoint or pause
    if_opcode_s = ebreak_p;
  end else if (irq_hot_s == 1'b1) begin //interrupt
    if_opcode_s = irq_p;
  end else if (if_rv_s == 1'b1) begin //generic instruction
    if_opcode_s = if_rv_op_s;
  end else begin //compressed instruction
    if_opcode_s = if_rvc_dec_s;
  end
end

/*------------------------------------------------------------------------------
--  Instruction Decoder Pipeline Registers
------------------------------------------------------------------------------*/

always @(posedge clk_i or negedge rst_an_i) begin  : proc_id_regs
  if (rst_an_i == 1'b0) begin
    id_pc_r         <= #`dly 'h0;
    id_break_r      <= #`dly 1'b0;
    id_next_pc_r    <= #`dly 'h0;
    id_rd_index_r   <= #`dly 5'd0;
    id_csr_addr_r   <= #`dly 12'h000;
    id_imm_r        <= #`dly {32{1'b0}};
    id_a_signed_r   <= #`dly 1'b0;
    id_b_signed_r   <= #`dly 1'b0;
    id_op_imm_r     <= #`dly 1'b0;
    id_alu_op_r     <= #`dly ALU_ADD;
    id_mem_rd_r     <= #`dly 1'b0;
    id_mem_wr_r     <= #`dly 1'b0;
    id_mem_signed_r <= #`dly 1'b0;
    id_mem_size_r   <= #`dly SIZE_BYTE;
    id_branch_r     <= #`dly BR_NONE;
    id_reg_jump_r   <= #`dly 1'b0;
    id_lock_r       <= #`dly 1'b0;
    id_csrrw_r      <= #`dly 1'b0;
    id_irq_r        <= #`dly 1'b0;
    id_mret_r       <= #`dly 1'b0;
  end else if (id_clear_s) begin
    // id_pc_r         <= #`dly 'h0;
    id_break_r      <= #`dly 1'b0;
    id_next_pc_r    <= #`dly 'h0;
    id_rd_index_r   <= #`dly 5'd0;
    id_csr_addr_r   <= #`dly 12'h000;
    id_imm_r        <= #`dly {32{1'b0}};
    id_a_signed_r   <= #`dly 1'b0;
    id_b_signed_r   <= #`dly 1'b0;
    id_op_imm_r     <= #`dly 1'b0;
    id_alu_op_r     <= #`dly ALU_ADD;
    id_mem_rd_r     <= #`dly 1'b0;
    id_mem_wr_r     <= #`dly 1'b0;
    id_mem_signed_r <= #`dly 1'b0;
    id_mem_size_r   <= #`dly SIZE_BYTE;
    id_branch_r     <= #`dly BR_NONE;
    id_reg_jump_r   <= #`dly 1'b0;
    id_lock_r       <= #`dly 1'b0;
    id_csrrw_r      <= #`dly 1'b0;
    id_irq_r        <= #`dly 1'b0;
    id_mret_r       <= #`dly 1'b0;
  end else if (id_ready_s) begin
    id_break_r      <= #`dly break_s;
    id_pc_r         <= #`dly if_pc_r;
    id_next_pc_r    <= #`dly if_next_pc_s;
    id_rd_index_r   <= #`dly id_rd_index_s;
    id_csr_addr_r   <= #`dly id_csr_addr_s;
    id_imm_r        <= #`dly id_imm_s;
    id_a_signed_r   <= #`dly id_a_signed_s;
    id_b_signed_r   <= #`dly id_b_signed_s;
    id_op_imm_r     <= #`dly id_op_imm_s;
    id_alu_op_r     <= #`dly id_alu_op_s;
    id_mem_rd_r     <= #`dly load_s;
    id_mem_wr_r     <= #`dly store_s;
    id_mem_signed_r <= #`dly id_mem_signed_s;
    id_mem_size_r   <= #`dly id_mem_size_s;
    id_branch_r     <= #`dly id_branch_s;
    id_reg_jump_r   <= #`dly jalr_s;
    id_lock_r       <= #`dly id_illegal_s;
    id_csrrw_r      <= #`dly csrrw_s;
    id_irq_r        <= #`dly irq_hot_s;
    id_mret_r       <= #`dly mret_s;
  end
end


/*------------------------------------------------------------------------------
--  Execute Pipeline Registers
------------------------------------------------------------------------------*/

always @(posedge clk_i or negedge rst_an_i) begin : proc_ex
  if (rst_an_i == 1'b0) begin
    ex_rd_index_r   <= #`dly 5'd2; // SP
    ex_alu_res_r    <= #`dly reset_sp_p;
    ex_csrrw_r      <= #`dly 1'b0;
    ex_csr_addr_r   <= #`dly 12'h000;
    ex_mem_data_r   <= #`dly {32{1'b0}};
    ex_mem_rd_r     <= #`dly 1'b0;
    ex_mem_wr_r     <= #`dly 1'b0;
    ex_mem_signed_r <= #`dly 1'b0;
    ex_mem_size_r   <= #`dly SIZE_BYTE;
  end else if (ex_clear_s) begin
    ex_rd_index_r   <= #`dly 5'd0; //different to rst_an_i state on pupose
    ex_alu_res_r    <= #`dly {32{1'b0}}; //different to rst_an_i state on pupose
    ex_csrrw_r      <= #`dly 1'b0;
    ex_csr_addr_r   <= #`dly 12'h000;
    ex_mem_data_r   <= #`dly {32{1'b0}};
    ex_mem_rd_r     <= #`dly 1'b0;
    ex_mem_wr_r     <= #`dly 1'b0;
    ex_mem_signed_r <= #`dly 1'b0;
    ex_mem_size_r   <= #`dly SIZE_BYTE;
  end else if (ex_ready_s) begin
    ex_rd_index_r   <= #`dly id_rd_index_r;
    ex_alu_res_r    <= #`dly ex_alu_res_s;
    ex_csrrw_r      <= #`dly id_csrrw_r;
    ex_csr_addr_r   <= #`dly id_csr_addr_r;
    ex_mem_data_r   <= #`dly id_rb_value_s;
    ex_mem_rd_r     <= #`dly id_mem_rd_r;
    ex_mem_wr_r     <= #`dly id_mem_wr_r;
    ex_mem_signed_r <= #`dly id_mem_signed_r;
    ex_mem_size_r   <= #`dly id_mem_size_r;
  end
end

assign riscv_reg_pc_o = if_pc_r;
assign debug_halt_data_o = debug_halt_data_r;
assign debug_halt_o = debug_halt_r;
assign lock_o =  id_lock_r;

</%def>
