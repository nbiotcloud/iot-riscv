// GENERATE INPLACE BEGIN copyright() ==========================================
//
//  MIT License
//
//  Copyright (c) 2024 nbiotcloud
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
// GENERATE INPLACE END copyright ==============================================

// GENERATE INPLACE BEGIN fileheader() =========================================
//
// Module:     iot_riscv.iot_riscv_compressed_decoder
// Data Model: iot_riscv.iot_riscv_compressed_decoder.IotRiscvCompressedDecoderMod
//
// GENERATE INPLACE END fileheader =============================================

// GENERATE INPLACE BEGIN header() =============================================
`begin_keywords "1800-2009"
`default_nettype none  // implicit wires are forbidden
// GENERATE INPLACE END header =================================================

// GENERATE INPLACE BEGIN beginmod() ===========================================
module iot_riscv_compressed_decoder ( // iot_riscv.iot_riscv_compressed_decoder.IotRiscvCompressedDecoderMod
  input  wire  [15:0] rvc_op_i,
  output logic [31:0] rvc_dec_o
);
// GENERATE INPLACE END beginmod ===============================================

// GENERATE INPLACE BEGIN logic() ==============================================


// ------------------------------------------------------
//  Signals
// ------------------------------------------------------
logic [15:0] if_rvc_op_s;
logic [31:0] if_rvc_dec_s;
// GENERATE INPLACE END logic ==================================================


localparam ebreak_p = { 11'h000, 1'b1, 13'h0000, 7'b1110011 };
assign if_rvc_op_s =  rvc_op_i;
assign rvc_dec_o =  if_rvc_dec_s;

always @ (*) begin  : proc_instr_dec
  // An illegal RVC opcode is decoded into 32'h0, which is also an illegal RV opcode.
  // We don't explicitly detect illegal RVC opcodes, but let RV decoder deal with them.
  if_rvc_dec_s = {32{1'b0}};

  case ({if_rvc_op_s[15:13], if_rvc_op_s[1:0]})
    5'b00000: begin
      if (if_rvc_op_s[12:2] != 11'h000 && if_rvc_op_s[12:5] != 8'h00) // c.add14spn
        begin
        if_rvc_dec_s = { 2'b00, if_rvc_op_s[10:7], if_rvc_op_s[12:11], if_rvc_op_s[5],
            if_rvc_op_s[6], 2'b00, 5'd2, 3'b000, 2'b01, if_rvc_op_s[4:2], 7'b0010011 };
        end
    end

    5'b01000: begin // c.lw
      if_rvc_dec_s = { 5'b00000, if_rvc_op_s[5], if_rvc_op_s[12:10], if_rvc_op_s[6],
          2'b00, 2'b01, if_rvc_op_s[9:7], 3'b010, 2'b01, if_rvc_op_s[4:2], 7'b0000011 };
    end

    5'b11000: begin // c.sw
      if_rvc_dec_s = { 5'b00000, if_rvc_op_s[5], if_rvc_op_s[12], 2'b01, if_rvc_op_s[4:2],
          2'b01, if_rvc_op_s[9:7], 3'b010, if_rvc_op_s[11:10], if_rvc_op_s[6], 2'b00, 7'b0100011 };
    end

    5'b00001: begin
      if (if_rvc_op_s[12:2] == 11'h000) // c.nop
        begin
          if_rvc_dec_s = { 25'h0000000, 7'b0010011 };
        end
      else if (if_rvc_op_s[12] != 1'b0 || if_rvc_op_s[6:2] != 5'h00) // c.addi
        begin
          if_rvc_dec_s = { {7{if_rvc_op_s[12]}}, if_rvc_op_s[6:2], if_rvc_op_s[11:7],
            3'b000, if_rvc_op_s[11:7], 7'b0010011 };
        end
    end

    5'b00101: begin // c.jal
      if_rvc_dec_s = { if_rvc_op_s[12], if_rvc_op_s[8], if_rvc_op_s[10:9], if_rvc_op_s[6],
          if_rvc_op_s[7], if_rvc_op_s[2], if_rvc_op_s[11], if_rvc_op_s[5:3], if_rvc_op_s[12],
          {8{if_rvc_op_s[12]}}, 5'd1, 7'b1101111 };
    end

    5'b01001: begin
      if (if_rvc_op_s[11:7] != 5'd0) // c.li
        begin
          if_rvc_dec_s = { {7{if_rvc_op_s[12]}}, if_rvc_op_s[6:2], 5'd0, 3'b000,
            if_rvc_op_s[11:7], 7'b0010011 };
        end
    end

    5'b01101: begin
      if ((if_rvc_op_s[12] != 1'b0 || if_rvc_op_s[6:2] != 5'h00) && if_rvc_op_s[11:7] != 5'd0) begin
        if (if_rvc_op_s[11:7] == 5'd2) // c.addi16sp
          begin
            if_rvc_dec_s = { {3{if_rvc_op_s[12]}}, if_rvc_op_s[4], if_rvc_op_s[3], if_rvc_op_s[5],
              if_rvc_op_s[2], if_rvc_op_s[6], 4'b0000, 5'd2, 3'b000, 5'd2, 7'b0010011 };
          end
        else // c.lui
          begin
            if_rvc_dec_s = { {15{if_rvc_op_s[12]}}, if_rvc_op_s[6:2], if_rvc_op_s[11:7], 7'b0110111 };
          end
      end
    end

    5'b10001: begin
      if (if_rvc_op_s[12:10] == 3'b011 && if_rvc_op_s[6:5] == 2'b00) // c.sub
        begin
          if_rvc_dec_s = { 7'b0100000, 2'b01, if_rvc_op_s[4:2], 2'b01, if_rvc_op_s[9:7],
            3'b000, 2'b01, if_rvc_op_s[9:7], 7'b0110011 };
        end
      else begin
        if (if_rvc_op_s[12:10] == 3'b011 && if_rvc_op_s[6:5] == 2'b01) // c.xor
          begin
            if_rvc_dec_s = { 7'b0000000, 2'b01, if_rvc_op_s[4:2], 2'b01, if_rvc_op_s[9:7],
              3'b100, 2'b01, if_rvc_op_s[9:7], 7'b0110011 };
          end
        else begin
          if (if_rvc_op_s[12:10] == 3'b011 && if_rvc_op_s[6:5] == 2'b10) // c.or
            begin
              if_rvc_dec_s = { 7'b0000000, 2'b01, if_rvc_op_s[4:2], 2'b01, if_rvc_op_s[9:7],
                  3'b110, 2'b01, if_rvc_op_s[9:7], 7'b0110011 };
            end
          else begin
            if (if_rvc_op_s[12:10] == 3'b011 && if_rvc_op_s[6:5] == 2'b11) // c.and
              begin
                if_rvc_dec_s = { 7'b0000000, 2'b01, if_rvc_op_s[4:2], 2'b01, if_rvc_op_s[9:7],
                    3'b111, 2'b01, if_rvc_op_s[9:7], 7'b0110011 };
              end
            else begin
              if (if_rvc_op_s[11:10] == 2'b10) // c.andi
                begin
                  if_rvc_dec_s = { {7{if_rvc_op_s[12]}}, if_rvc_op_s[6:2], 2'b01, if_rvc_op_s[9:7],
                      3'b111, 2'b01, if_rvc_op_s[9:7], 7'b0010011 };
                end
              else begin
                if (if_rvc_op_s[12] == 1'b0 && if_rvc_op_s[6:2] == 5'h00)
                  begin
                    if_rvc_dec_s = {32{1'b0}};
                  end
                else begin
                  if (if_rvc_op_s[11:10] == 2'b00) // c.srli
                    begin
                      if_rvc_dec_s = { 7'b0000000, if_rvc_op_s[6:2], 2'b01, if_rvc_op_s[9:7],
                        3'b101, 2'b01, if_rvc_op_s[9:7], 7'b0010011 };
                    end
                  else begin
                    if (if_rvc_op_s[11:10] == 2'b01) // c.srai
                      begin
                        if_rvc_dec_s = { 7'b0100000, if_rvc_op_s[6:2], 2'b01, if_rvc_op_s[9:7],
                          3'b101, 2'b01, if_rvc_op_s[9:7], 7'b0010011 };
                      end
                  end
                end
              end
            end
          end
        end
      end
    end

    5'b10101: begin // c.j
      if_rvc_dec_s = { if_rvc_op_s[12], if_rvc_op_s[8], if_rvc_op_s[10:9], if_rvc_op_s[6],
          if_rvc_op_s[7], if_rvc_op_s[2], if_rvc_op_s[11], if_rvc_op_s[5:3], if_rvc_op_s[12],
          {8{if_rvc_op_s[12]}}, 5'd0, 7'b1101111 };
    end

    5'b11001: begin // c.beqz
      if_rvc_dec_s = { {4{if_rvc_op_s[12]}}, if_rvc_op_s[6], if_rvc_op_s[5], if_rvc_op_s[2],
          5'd0, 2'b01, if_rvc_op_s[9:7], 3'b000, if_rvc_op_s[11], if_rvc_op_s[10],
          if_rvc_op_s[4], if_rvc_op_s[3], if_rvc_op_s[12], 7'b1100011 };
    end

    5'b11101: begin // c.bnez
      if_rvc_dec_s = { {4{if_rvc_op_s[12]}}, if_rvc_op_s[6], if_rvc_op_s[5], if_rvc_op_s[2],
          5'd0, 2'b01, if_rvc_op_s[9:7], 3'b001, if_rvc_op_s[11], if_rvc_op_s[10],
          if_rvc_op_s[4], if_rvc_op_s[3], if_rvc_op_s[12], 7'b1100011 };
    end

    5'b00010: begin
      if (if_rvc_op_s[11:7] != 5'd0) // c.slli
        begin
          if_rvc_dec_s = { 7'b0000000, if_rvc_op_s[6:2], if_rvc_op_s[11:7], 3'b001,
            if_rvc_op_s[11:7], 7'b0010011 };
        end
    end

    5'b01010: begin
      if (if_rvc_op_s[11:7] != 5'h00) // c.lwsp
        begin
          if_rvc_dec_s = { 4'b0000, if_rvc_op_s[3:2], if_rvc_op_s[12], if_rvc_op_s[6:4],
            2'h0, 5'd2, 3'b010, if_rvc_op_s[11:7], 7'b0000011 };
        end
    end

    5'b11010: begin // c.swsp
      if_rvc_dec_s = { 4'b0000, if_rvc_op_s[8:7], if_rvc_op_s[12], if_rvc_op_s[6:2],
          5'd2, 3'b010, if_rvc_op_s[11:9], 2'b00, 7'b0100011 };
    end

    5'b10010: begin
      if (if_rvc_op_s[6:2] == 5'd0) begin
        if (if_rvc_op_s[11:7] == 5'h00) begin
          if (if_rvc_op_s[12] == 1'b1) // c.ebreak
            begin
              if_rvc_dec_s = ebreak_p;
            end
        end else begin
          if (if_rvc_op_s[12]) begin
            if_rvc_dec_s = { 12'h000, if_rvc_op_s[11:7], 3'b000, 5'd1, 7'b1100111 }; // c.jalr
          end else begin
            if_rvc_dec_s = { 12'h000, if_rvc_op_s[11:7], 3'b000, 5'd0, 7'b1100111 }; // c.jr
          end
        end
      end else begin
        if (if_rvc_op_s[11:7] != 5'h00) begin
          if (if_rvc_op_s[12] == 1'b0) begin // c.mv
            if_rvc_dec_s = { 7'b0000000, if_rvc_op_s[6:2], 5'd0, 3'b000,
            if_rvc_op_s[11:7], 7'b0110011 };
          end else begin // c.add
            if_rvc_dec_s = { 7'b0000000, if_rvc_op_s[6:2], if_rvc_op_s[11:7],
              3'b000, if_rvc_op_s[11:7], 7'b0110011 };
          end
        end
      end
    end

    default: ;
  endcase
end



// GENERATE INPLACE BEGIN endmod() =============================================
endmodule // iot_riscv_compressed_decoder
// GENERATE INPLACE END endmod =================================================

// GENERATE INPLACE BEGIN footer() =============================================
`default_nettype wire
`end_keywords
// GENERATE INPLACE END footer =================================================
