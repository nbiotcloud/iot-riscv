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

  // ------------------------------------------------------
  //  Signals
  // ------------------------------------------------------
  `ifdef SIM
  logic                     if_seq_err_r;
  logic                     if_comb_err_s;
  `endif
  logic [2:0]               if_state_r;
  logic                     if_break_exit_r;
  logic                     if_lo_is_rv_s;
  logic                     if_lo_is_rvc_s;
  logic                     if_hi_is_rv_s;
  logic                     if_hi_is_rvc_s;
  logic                     if_hold_state_r;
  logic [31:0]              if_rv_op_s;
  logic [15:0]              if_rvc_op_s;
  logic                     if_rv_s;
  logic                     if_valid_s;
  logic [(pc_size_p-2)-1:0] if_next_addr_s;
  logic [31:0]              i_rdata_s;
  logic [31:0]              if_word_s;
  logic [31:0]              if_buf_word_s;
  logic [2:0]               next_if_state_s;
  logic                     clear_if_buf_s;
  logic                     if_enter_break_s;
  logic                     clear_break_exit_s;
  logic                     if_advance_s;
  logic                     if_hi_is_unalign_rv_s;
  logic                     if_in_flight_r;
  logic                     if_drop_incoming_r;
  logic                     i_rd_s;
  logic [1:0]               if_pc_offs_s;
  logic [63:0]              if_buf_r;
  logic [15:0]              if_hi_buf_r;
  logic [1:0]               if_buf_valid_r;
  logic                     if_buf_idx_r;
  logic                     if_ext_save_s;
  logic                     if_int_save_s;
  logic                     if_flush_buf_s;
  logic                     if_wait_unalign_s;


  localparam size_word_p = 2'd2;

  localparam reset_st       = 3'd0;
  localparam low_st         = 3'd1;
  localparam high_st        = 3'd2;
  localparam unalign_st     = 3'd3;
  localparam break_st       = 3'd4;
  localparam branch_exit_st = 3'd5;

  /*------------------------------------------------------------------------------
  --  Tied Write Signals for IMEM Port
  ------------------------------------------------------------------------------*/

  assign i_wdata_o = {32{1'b0}};
  assign i_wr_o = 1'b0;
  assign i_size_o = size_word_p;

  /*------------------------------------------------------------------------------
  --  Instruction Fetch State Machine and Buffers
  ------------------------------------------------------------------------------*/

  always @(posedge clk_i or negedge rst_an_i) begin : proc_if_state
    if (rst_an_i == 1'b0) begin
      if_state_r <= #`dly reset_st;
      if_buf_r <= #`dly {64{1'b0}};
      if_hi_buf_r <= #`dly 16'h0000;
      if_buf_valid_r <= #`dly 2'b00;
      if_break_exit_r <= #`dly 1'b0;
      if_buf_idx_r <= #`dly 1'b0;
      `ifdef SIM
      if_seq_err_r <= #`dly 1'b0;
      `endif
    end else begin
      // advance the FSM
      if_state_r <= #`dly next_if_state_s;
      // manage the set/clear of the fetch buffers
      // fill the buffer when the input cannot be directly consumed
      // reset it based on state transitions
      if (if_flush_buf_s == 1'b1) begin
        if_buf_valid_r <= #`dly 2'b00;
        `ifdef SIM
        // in simulation kill the buffer contents to make sure we do not use them
        // we don't reset the buffer in ASIC to save power
        if_buf_r <= #`dly {64{1'bx}};
        `endif
      end else if ((if_ext_save_s == 1'b1) || (clear_if_buf_s == 1'b1)) begin
        case (if_buf_valid_r)
          2'b00: begin
            // save power and only register when we are not clearing
            if (if_ext_save_s == 1'b1) begin
              if_buf_r[31:0] <= #`dly i_rdata_s;
            end
            // set prevails over clear
            if_buf_valid_r <= #`dly {1'b0,if_ext_save_s};
          end
          2'b01: begin
            if (if_ext_save_s == 1'b1) begin
              if_buf_r[63:32] <= #`dly i_rdata_s;
            end
            `ifdef SIM
            // in simulation kill the buffer contents to make sure we do not use them
            // we don't reset the buffer in ASIC to save power
            if (clear_if_buf_s == 1'b1) begin
              if_buf_r[31:0] <= #`dly 32'hxxxxxxxx;
            end
            `endif
            // set prevails over clear
            if_buf_valid_r <= #`dly {if_ext_save_s,~clear_if_buf_s};
            if_buf_idx_r <= #`dly 1'b0; // lower is older, must be consumed first
          end
          2'b10: begin
            if (if_ext_save_s == 1'b1) begin
              if_buf_r[31:0] <= #`dly i_rdata_s;
            end
            `ifdef SIM
            // in simulation kill the buffer contents to make sure we do not use them
            // we don't reset the buffer in ASIC to save power
            if (clear_if_buf_s == 1'b1) begin
              if_buf_r[63:32] <= #`dly 32'hxxxxxxxx;
            end
            `endif
            // set prevails over clear
            if_buf_valid_r <= #`dly {~clear_if_buf_s,if_ext_save_s};
            if_buf_idx_r <= #`dly 1'b1; // higher is older, must be consumed first
          end
          2'b11: begin
            // we only end up here to clear buffers as they are consumed
            // we tell which one based on sequence index
            if_buf_valid_r[if_buf_idx_r] <= #`dly 1'b0;
            `ifdef SIM
            // in simulation kill the buffer contents to make sure we do not use them
            // we don't reset the buffer in ASIC to save power
            if (clear_if_buf_s == 1'b1) begin
              if (if_buf_idx_r == 1'b0) begin
                if_buf_r[31:0] <= #`dly 32'hxxxxxxxx;
              end else begin
                if_buf_r[63:32] <= #`dly 32'hxxxxxxxx;
              end
            end
            // should we get here because of an ext_save, error out in simulation
            // because we simply have no space to store the stuff that is coming in
            if ((if_seq_err_r == 1'b0) && (if_ext_save_s == 1'b1)) begin
              $display($time, "ps\tSIMERROR: Attempted load of if_buf_r in fetch unit although already full.");
              if_buf_r[63:0] <= #`dly {64{1'bx}};
              if_seq_err_r <= #`dly 1'b1;
            end
            `endif
          end
        endcase
      end
      if (if_int_save_s == 1'b1) begin
        // no valid indicator for the high buffer, as it must be valid
        // in the case it is consumed (part of unaligned or high state)
        if_hi_buf_r <= #`dly if_word_s[31:16];
      end
      // manage break state
      if (branch_taken_i == 1'b1) begin
        if_break_exit_r <= #`dly if_state_r == break_st;
      end else if (clear_break_exit_s == 1'b1) begin
        if_break_exit_r <= #`dly 1'b0;
      end
    end
  end

  //lint_checking CDEFNC off
  always_comb begin : proc_if_comb
    // control defaults
    clear_if_buf_s = 1'b0;
    next_if_state_s = if_state_r;
    clear_break_exit_s = 1'b0;
    if_flush_buf_s = 1'b0;

    // state decoder
    if (if_enter_break_s == 1'b1) begin // enter debug mode, ignore everything else
      next_if_state_s = break_st;
    end else begin // regular mode
      if ((branch_taken_i == 1'b1) && (if_hold_state_r == 1'b0)) begin
        next_if_state_s = jump_addr_i[1] ? branch_exit_st : low_st;
        if_flush_buf_s = 1'b1;
        // whatever we saved is worthless after branching
      end else if (if_advance_s == 1'b1) begin
        case (if_state_r)
          reset_st: begin
            next_if_state_s = low_st;
          end

          low_st: begin
            clear_break_exit_s = 1'b1;
            if (branch_taken_i == 1'b0) begin  // guard against running away in a branch with a hazard
              clear_if_buf_s = 1'b1;
              if (if_lo_is_rvc_s == 1'b1) begin
                if(if_hi_is_rvc_s == 1'b1) begin
                  next_if_state_s = high_st;
                end else if (if_hi_is_rv_s) begin
                  next_if_state_s = unalign_st;
                end
              end
            end
          end

          high_st: begin
            if (branch_taken_i == 1'b0) begin // guard against running away in a branch with a hazard
              clear_break_exit_s = 1'b1;
              next_if_state_s = low_st;
            end
          end

          unalign_st: begin
            if (branch_taken_i == 1'b0) begin // guard against running away in a branch with a hazard
              clear_break_exit_s = 1'b1;
              if (if_hi_is_rvc_s) begin
                next_if_state_s = high_st;
              end
              clear_if_buf_s = 1'b1;
            end
          end

          branch_exit_st: begin
            if ((i_rdy_i == 1'b1) && (if_drop_incoming_r == 1'b0)) begin // we need the first fetch after jump to know what to do
              clear_break_exit_s = 1'b1;
              if (if_hi_is_rv_s == 1'b1) begin
                next_if_state_s = unalign_st;
              end else begin
                if ((branch_taken_i == 1'b0) && (hazard_i == 1'b0)) begin
                  next_if_state_s = low_st; // we act as the high state and go to low
                end else begin
                  next_if_state_s = high_st; // still stuck in the branch because of a hazard, so we got time to go to the real high state
                end
              end
            end
          end

          break_st: ;
          default:;
        endcase
      end
    end
  end
  //lint_checking CDEFNC on

  always_comb begin : proc_i_rd
    if (if_state_r != reset_st) begin
      if (if_enter_break_s == 1'b1) begin
        i_rd_s = 1'b0;
      end else begin
        // we want to fetch as much as possible
        i_rd_s = !(((if_in_flight_r == 1'b1) && (|if_buf_valid_r == 1'b1)) || // not when one in flight and one in buffer
                 (&if_buf_valid_r == 1'b1)) || // not when buffer full
                 ((branch_taken_i == 1'b1) && (if_hold_state_r == 1'b0)); //first cycle in branch, ignore the buffer levels as they get cleared
      end
    end else begin
      i_rd_s = 1'b0;
    end
  end

  assign i_rd_o = i_rd_s;

  always_ff @(posedge clk_i or negedge rst_an_i) begin : proc_if_in_flight
    // track if there is an outstanding fetch
    if (rst_an_i == 1'b0) begin
      if_in_flight_r <= #`dly 1'b0;
    end else if ((i_rd_s == 1'b1) && (i_grant_i == 1'b1)) begin
      if_in_flight_r <= #`dly 1'b1;
    end else if (i_rdy_i == 1'b1) begin
      if_in_flight_r <= #`dly 1'b0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_an_i) begin : proc_if_drop_incoming
    // track if we need to throw away fetch data from before a branch occured
    if (rst_an_i == 1'b0) begin
      if_drop_incoming_r <= #`dly 1'b0;
    // this condition only occurs in the first cycle when entering a branch
    // if something is in flight and did not yet arrive, we need to drop it when it does, as it is from before the branch
    end else if ((branch_taken_i == 1'b1) && (if_in_flight_r == 1'b1) && (i_rdy_i == 1'b0) && (if_hold_state_r == 1'b0)) begin
      if_drop_incoming_r <= #`dly 1'b1;
    end else if (i_rdy_i == 1'b1) begin
      if_drop_incoming_r <= #`dly 1'b0;
    end
  end

  assign if_pc_offs_s = ((if_state_r == branch_exit_st) && (if_in_flight_r == 1'b1) && (if_drop_incoming_r == 1'b0)) ? 2'b01 : // when branching, fetch next after jump address, or when in high and nothing left
                        ((((if_in_flight_r == 1'b1) && (if_drop_incoming_r == 1'b0)) || (|if_buf_valid_r == 1'b1)) && (if_pc_i[1] == 1'b1)) ? 2'b10 : // using high buffer and incoming or stored, next is +8 (round up)
                        (((if_in_flight_r == 1'b1) && (if_drop_incoming_r == 1'b0)) || (|if_buf_valid_r == 1'b1)) ? 2'b01 : // something is incoming or already there, so next is +4
                        2'b00; // reset case, fetch directly with if_pc_r

  // only immidiately after a branch is announced we take the jump_addr from the ALU, in all other cases the
  // if_pc_r is up to date and must be used
  assign if_next_addr_s = ((branch_taken_i == 1'b1) && (if_hold_state_r == 1'b0)) ? jump_addr_i[pc_size_p-1:2] :
                          if_pc_i[pc_size_p-1:2] + {28'h00000000, if_pc_offs_s};

  always @(posedge clk_i or negedge rst_an_i) begin : proc_fsm_hold
    if (rst_an_i == 1'b0) begin
      if_hold_state_r <= #`dly 1'b1;
    end else if ((branch_taken_i & hazard_i) == 1'b1) begin
      if_hold_state_r <= #`dly 1'b1;
    end else if (if_advance_s == 1'b1) begin
      if_hold_state_r <= #`dly 1'b0;
    end
  end

  /*------------------------------------------------------------------------------
  --  Instruction Fetch
  ------------------------------------------------------------------------------*/

  always_comb begin : proc_if_word_s
    // first figure out what to take from the buffer
    case (if_buf_valid_r)
      2'b00: begin
        if_buf_word_s = i_rdata_s; //bypass
      end
      2'b01: begin
        if_buf_word_s = if_buf_r[31:0];
      end
      2'b10: begin
        if_buf_word_s = if_buf_r[63:32];
      end
      2'b11: begin
        //buffer is full, take the older word of the two to stay in sequence
        if_buf_word_s = (if_buf_idx_r == 1'b0) ? if_buf_r[31:0] : if_buf_r[63:32];
      end
      `ifdef SIM
      default: begin
        if_buf_word_s = 32'hxxxxxxxx; //we should not be here
      end
      `endif
    endcase
  end

  assign if_word_s = (if_state_r == high_st) ? {if_hi_buf_r,if_buf_word_s[15:0]} : if_buf_word_s;

  // helper signals to indicate we have to save things in the buffers
  assign if_ext_save_s = ((if_valid_s == 1'b0) || (if_advance_s == 1'b0) || (|if_buf_valid_r == 1'b1) || (if_state_r == high_st) || (if_hold_state_r == 1'b1)) &&
                         (i_rdy_i == 1'b1) &&
                         (if_drop_incoming_r == 1'b0) &&
                         (if_state_r != branch_exit_st);
  assign if_int_save_s = (if_advance_s == 1'b1) && // prevent loading if not running
                         (next_if_state_s != low_st) && // there is no point in saving as low state does not use the high buffer
                         (if_state_r != high_st) && // prevent overriding our high buffer during a stall
                         !((if_hold_state_r == 1'b1) && (if_state_r != branch_exit_st)); // prevent override during a branching stall

  // the fetch FSM advances on valid instruction input, initially out of reset and after a branch event
  assign if_advance_s = ((if_valid_s == 1'b1) & (hazard_i == 1'b0)) ||
                        (if_state_r == reset_st) ||
                        (if_state_r == branch_exit_st);

  // this instruction fetch valid indicator tells the hazard unit and PC if there is a valid instruction to consume
  assign if_valid_s = ((((i_rdy_i == 1'b1) && (if_drop_incoming_r == 1'b0)) || (|if_buf_valid_r == 1'b1)) && (if_wait_unalign_s == 1'b0)) ||
                      (if_state_r == high_st); // in high state there must be something in the high buffer

  // we always fetch aligned to word-boundaries
  assign i_addr_o = {if_next_addr_s, 2'b00};

  // indicators
  assign if_enter_break_s = ((debug_halt_data_i | debug_halt_i) == 1'b1) && (debug_single_step_i == 1'b0);
  assign if_wait_unalign_s = (if_hi_is_rv_s == 1'b1) && (if_state_r == branch_exit_st);
  assign if_lo_is_rv_s  = (if_buf_word_s[1:0] == 2'b11); // in high_st this is x and must be masked
  assign if_lo_is_rvc_s = ~if_lo_is_rv_s; // in high_st this is x and must be masked
  assign if_hi_is_rv_s  = (if_buf_word_s[17:16] == 2'b11);
  assign if_hi_is_rvc_s = ~if_hi_is_rv_s;
  assign if_hi_is_unalign_rv_s = if_lo_is_rvc_s & if_hi_is_rv_s;

  // determine if we are in 32-bit or 16-bit compressed mode for this instruction (selects between if_rv_op_s and if_rvc_op_s below)
  assign if_rv_s = (if_state_r == unalign_st) ||
                   ((if_state_r == low_st) && (if_lo_is_rv_s == 1'b1)) ||
                   (if_wait_unalign_s == 1'b1);
  // assemble the decoder inputs in case of unaligned execution, take the preselected input otherwise
  assign if_rv_op_s  = (if_pc_i[1] == 1'b1) ? {if_word_s[15:0], if_hi_buf_r} : // unaligned 32-bit, assemble from high-buffer and input
                       if_word_s; // regular input
  assign if_rvc_op_s = (if_pc_i[1] == 1'b1) ? if_word_s[31:16] : //upper word needed (PC at halfword-boundary)
                       if_word_s[15:0]; // lower word needed (PC at word-boundary)

  // forwards signals to outputs which are needed somewhere else
  assign if_rv_o = if_rv_s; // select for decoder
  assign if_rv_op_o = if_rv_op_s; // to normal 32-bit decoder
  assign if_rvc_op_o = if_rvc_op_s; // to compressed decoder
  assign if_valid_o = if_valid_s; // to hazard unit and if_pc to determine if to advance
  assign if_break_exit_o = if_break_exit_r; // debugger control
  assign if_hold_state_o = if_hold_state_r; // special hold condition during a combined branch and hazard condition

  `ifdef SIM
  // simulation trick to assure we are not using invalid input data
  assign i_rdata_s = (i_rdy_i == 1'b0) ? 32'hxxxxxxxx : i_rdata_i;
  // some sanity checks to ease debugging
  always_comb begin : proc_err_detect
    if ((if_valid_s == 1'b1) && (if_rv_s == 1'bx)) begin
      $display($time, "ps\tSIMERROR: The if_valid_s indicator was asserted while if_rv_s was invalid.");
      if_comb_err_s = 1'b1;
    end else begin
      if_comb_err_s = 1'b0;
    end
  end
  `else
  assign i_rdata_s = i_rdata_i;
  `endif


// GENERATE INPLACE BEGIN endmod() =============================================
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
// GENERATE INPLACE END footer =================================================
