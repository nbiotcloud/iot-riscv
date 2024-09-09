// GENERATE INPLACE BEGIN copyright() =========================================
// GENERATE INPLACE END copyright =============================================

// GENERATE INPLACE BEGIN fileheader() =========================================
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================
// GENERATE INPLACE END logic ==================================================

  logic        mem_rd_type_r;
  logic        mem_wr_type_r;
  logic        mem_stall_comb_s;

  localparam SIZE_BYTE = 2'd0;
  localparam SIZE_HALF = 2'd1;
  localparam SIZE_WORD = 2'd2;
  /*------------------------------------------------------------------------------
  --  Memory
  ------------------------------------------------------------------------------*/

  assign d_addr_o  = ex_alu_res_i;
  assign d_wdata_o = ex_mem_data_i;
  assign d_size_o  = ex_mem_size_i;
  assign d_rd_o    = ex_mem_rd_i && (mem_rd_type_r == 1'b0); //&& run_en_i;
  assign d_wr_o    = ex_mem_wr_i; //&& run_en_i;

  assign mem_rdata_s =
    (SIZE_BYTE == ex_mem_size_i) ? { {24{ex_mem_signed_i & d_rdata_i[7]}}, d_rdata_i[7:0] } :
    (SIZE_HALF == ex_mem_size_i) ? { {16{ex_mem_signed_i & d_rdata_i[15]}}, d_rdata_i[15:0] } : d_rdata_i;

  //lint_checking PRMFSM off
  always @(posedge clk_i or negedge rst_an_i) begin : proc_mem_stall
    if (rst_an_i == 1'b0) begin
      mem_stall_r <= #`dly 1'b0;
      mem_rd_type_r <= #`dly 1'b0;
      mem_wr_type_r <= #`dly 1'b0;
    end else if (mem_access_s & ~mem_rd_type_r) begin  // do not allow interleaved reads
      mem_stall_r <= #`dly 1'b1;
      mem_wr_type_r <= #`dly ex_mem_wr_i;
      mem_rd_type_r <= #`dly ex_mem_rd_i;
    end else if (d_rdy_i) begin
      mem_stall_r <= #`dly 1'b0;
      mem_rd_type_r <= #`dly 1'b0;
      mem_wr_type_r <= #`dly 1'b0;
    end
  end
  //lint_checking PRMFSM on

  assign mem_access_s = ((ex_mem_rd_i) | (ex_mem_wr_i)) & d_grant_i;

  //lint_checking PTRMST off
  //lint_checking PUNRCS off
  //lint_checking VARTRN off
  assign mem_stall_s  = mem_stall_r ? ~d_rdy_i : (ex_mem_rd_i | (ex_mem_wr_i & ~d_grant_i));
  //lint_checking PTRMST on
  //lint_checking PUNRCS on
  //lint_checking VARTRN on

  /*------------------------------------------------------------------------------
  --  Writeback
  ------------------------------------------------------------------------------*/

  //regular registers
  assign rd_index_o = ex_rd_index_i;
  assign rd_value_o = mem_rd_type_r ? mem_rdata_s : (ex_csrrw_i ? csr_rd_value_i : ex_alu_res_i);
  assign rd_we_o    = (ex_rd_index_i != 5'd0) && (mem_stall_comb_s == 1'b0);
  assign mem_stall_o = mem_stall_r;
  assign mem_stall_comb_s = mem_stall_s | (ex_mem_rd_i & d_grant_i);
  assign mem_stall_comb_o = mem_stall_comb_s;




// GENERATE INPLACE BEGIN endmod() =============================================
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
// GENERATE INPLACE END footer =================================================
