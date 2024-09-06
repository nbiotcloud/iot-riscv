// GENERATE INPLACE BEGIN copyright() =========================================
// GENERATE INPLACE END copyright =============================================

// GENERATE INPLACE BEGIN fileheader() =========================================
//
// Module:     iot_riscv.iot_riscv_csr
// Data Model: iot_riscv.iot_riscv_csr.IotRiscvCsrMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_csr #( // iot_riscv.iot_riscv_csr.IotRiscvCsrMod
  parameter integer pc_size_p = 32
) (
  // main_i
  input  wire                  main_clk_i,
  input  wire                  main_rst_an_i,  // Async Reset (Low-Active)
  input  wire  [11:0]          ex_csr_addr_i,
  input  wire  [31:0]          ex_alu_res_i,
  input  wire  [pc_size_p-1:0] id_pc_i,
  output logic [31:0]          csr_rd_value_o,
  output logic [31:0]          mscratch_o,
  output logic [31:0]          mepc_o,
  output logic [31:0]          mtvec_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic [11:0] csr_index_s;
logic [31:0] mtvec_r;
logic [31:0] mscratch_r;
logic [31:0] mepc_r;
// GENERATE INPLACE END logic ==================================================


//CSR Registers
assign csr_index_s = ex_csr_addr_i;
//lint_checking FFWNSR off
//lint_checking FFWASR off
always @(posedge clk_i) begin : proc_csr_seq
  case(csr_index_s)
    12'h305: mtvec_r <= #`dly ex_alu_res_i;
    12'h340: mscratch_r <= #`dly ex_alu_res_i;
    12'h341: mepc_r <= #`dly id_pc_i;
    default: ;
  endcase
end
//lint_checking FFWASR on
//lint_checking FFWNSR on
always_comb begin : proc_csr_comb
  case(csr_index_s)
    12'h305: csr_rd_value_o = mtvec_r;
    12'h340: csr_rd_value_o = mscratch_r;
    12'h341: csr_rd_value_o = mepc_r;
    default: csr_rd_value_o = {32{1'b0}};
  endcase
end
assign mscratch_o = mscratch_r;
assign mepc_o = mepc_r;
assign mtvec_o = mtvec_r;




// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_csr
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
