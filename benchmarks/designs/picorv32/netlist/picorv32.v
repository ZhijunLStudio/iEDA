/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 15 00:10:49 2025
/////////////////////////////////////////////////////////////


module picorv32 ( clk, resetn, trap, mem_valid, mem_instr, mem_ready, mem_addr, 
        mem_wdata, mem_wstrb, mem_rdata, mem_la_read, mem_la_write, 
        mem_la_addr, mem_la_wdata, mem_la_wstrb, pcpi_valid, pcpi_insn, 
        pcpi_rs1, pcpi_rs2, pcpi_wr, pcpi_rd, pcpi_wait, pcpi_ready, irq, eoi, 
        trace_valid, trace_data );
  output [31:0] mem_addr;
  output [31:0] mem_wdata;
  output [3:0] mem_wstrb;
  input [31:0] mem_rdata;
  output [31:0] mem_la_addr;
  output [31:0] mem_la_wdata;
  output [3:0] mem_la_wstrb;
  output [31:0] pcpi_insn;
  output [31:0] pcpi_rs1;
  output [31:0] pcpi_rs2;
  input [31:0] pcpi_rd;
  input [31:0] irq;
  output [31:0] eoi;
  output [35:0] trace_data;
  input clk, resetn, mem_ready, pcpi_wr, pcpi_wait, pcpi_ready;
  output trap, mem_valid, mem_instr, mem_la_read, mem_la_write, pcpi_valid,
         trace_valid;
  wire   mem_do_rinst, mem_do_prefetch, mem_do_rdata, mem_do_wdata, N188, N189,
         N190, N191, N192, N193, N194, N195, N196, N197, N198, N199, N200,
         N201, N202, N203, instr_lui, instr_auipc, instr_jal, instr_jalr,
         instr_beq, instr_bne, instr_blt, instr_bge, instr_bltu, instr_bgeu,
         instr_lb, instr_lh, instr_lw, instr_lbu, instr_lhu, instr_sb,
         instr_sh, instr_sw, instr_addi, instr_slti, instr_sltiu, instr_xori,
         instr_ori, instr_andi, instr_slli, instr_srli, instr_srai, instr_add,
         instr_sub, instr_sll, instr_slt, instr_sltu, instr_xor, instr_srl,
         instr_sra, instr_or, instr_and, instr_rdcycle, instr_rdcycleh,
         instr_rdinstr, instr_rdinstrh, instr_fence,
         is_beq_bne_blt_bge_bltu_bgeu, is_lb_lh_lw_lbu_lhu, is_sb_sh_sw,
         is_alu_reg_imm, is_alu_reg_reg, N254, is_lui_auipc_jal,
         is_lui_auipc_jal_jalr_addi_add_sub, N256, is_slti_blt_slt, N257,
         is_sltiu_bltu_sltu, N258, is_lbu_lhu_lw, is_compare, decoder_trigger,
         decoder_pseudo_trigger, is_slli_srli_srai,
         is_jalr_addi_slti_sltiu_xori_ori_andi, is_sll_srl_sra, N351,
         latched_store, latched_branch, latched_compr, latched_stalu,
         \cpuregs[1][31] , \cpuregs[1][30] , \cpuregs[1][29] ,
         \cpuregs[1][28] , \cpuregs[1][27] , \cpuregs[1][26] ,
         \cpuregs[1][25] , \cpuregs[1][24] , \cpuregs[1][23] ,
         \cpuregs[1][22] , \cpuregs[1][21] , \cpuregs[1][20] ,
         \cpuregs[1][19] , \cpuregs[1][18] , \cpuregs[1][17] ,
         \cpuregs[1][16] , \cpuregs[1][15] , \cpuregs[1][14] ,
         \cpuregs[1][13] , \cpuregs[1][12] , \cpuregs[1][11] ,
         \cpuregs[1][10] , \cpuregs[1][9] , \cpuregs[1][8] , \cpuregs[1][7] ,
         \cpuregs[1][6] , \cpuregs[1][5] , \cpuregs[1][4] , \cpuregs[1][3] ,
         \cpuregs[1][2] , \cpuregs[1][1] , \cpuregs[1][0] , \cpuregs[2][31] ,
         \cpuregs[2][30] , \cpuregs[2][29] , \cpuregs[2][28] ,
         \cpuregs[2][27] , \cpuregs[2][26] , \cpuregs[2][25] ,
         \cpuregs[2][24] , \cpuregs[2][23] , \cpuregs[2][22] ,
         \cpuregs[2][21] , \cpuregs[2][20] , \cpuregs[2][19] ,
         \cpuregs[2][18] , \cpuregs[2][17] , \cpuregs[2][16] ,
         \cpuregs[2][15] , \cpuregs[2][14] , \cpuregs[2][13] ,
         \cpuregs[2][12] , \cpuregs[2][11] , \cpuregs[2][10] , \cpuregs[2][9] ,
         \cpuregs[2][8] , \cpuregs[2][7] , \cpuregs[2][6] , \cpuregs[2][5] ,
         \cpuregs[2][4] , \cpuregs[2][3] , \cpuregs[2][2] , \cpuregs[2][1] ,
         \cpuregs[2][0] , \cpuregs[3][31] , \cpuregs[3][30] , \cpuregs[3][29] ,
         \cpuregs[3][28] , \cpuregs[3][27] , \cpuregs[3][26] ,
         \cpuregs[3][25] , \cpuregs[3][24] , \cpuregs[3][23] ,
         \cpuregs[3][22] , \cpuregs[3][21] , \cpuregs[3][20] ,
         \cpuregs[3][19] , \cpuregs[3][18] , \cpuregs[3][17] ,
         \cpuregs[3][16] , \cpuregs[3][15] , \cpuregs[3][14] ,
         \cpuregs[3][13] , \cpuregs[3][12] , \cpuregs[3][11] ,
         \cpuregs[3][10] , \cpuregs[3][9] , \cpuregs[3][8] , \cpuregs[3][7] ,
         \cpuregs[3][6] , \cpuregs[3][5] , \cpuregs[3][4] , \cpuregs[3][3] ,
         \cpuregs[3][2] , \cpuregs[3][1] , \cpuregs[3][0] , \cpuregs[4][31] ,
         \cpuregs[4][30] , \cpuregs[4][29] , \cpuregs[4][28] ,
         \cpuregs[4][27] , \cpuregs[4][26] , \cpuregs[4][25] ,
         \cpuregs[4][24] , \cpuregs[4][23] , \cpuregs[4][22] ,
         \cpuregs[4][21] , \cpuregs[4][20] , \cpuregs[4][19] ,
         \cpuregs[4][18] , \cpuregs[4][17] , \cpuregs[4][16] ,
         \cpuregs[4][15] , \cpuregs[4][14] , \cpuregs[4][13] ,
         \cpuregs[4][12] , \cpuregs[4][11] , \cpuregs[4][10] , \cpuregs[4][9] ,
         \cpuregs[4][8] , \cpuregs[4][7] , \cpuregs[4][6] , \cpuregs[4][5] ,
         \cpuregs[4][4] , \cpuregs[4][3] , \cpuregs[4][2] , \cpuregs[4][1] ,
         \cpuregs[4][0] , \cpuregs[5][31] , \cpuregs[5][30] , \cpuregs[5][29] ,
         \cpuregs[5][28] , \cpuregs[5][27] , \cpuregs[5][26] ,
         \cpuregs[5][25] , \cpuregs[5][24] , \cpuregs[5][23] ,
         \cpuregs[5][22] , \cpuregs[5][21] , \cpuregs[5][20] ,
         \cpuregs[5][19] , \cpuregs[5][18] , \cpuregs[5][17] ,
         \cpuregs[5][16] , \cpuregs[5][15] , \cpuregs[5][14] ,
         \cpuregs[5][13] , \cpuregs[5][12] , \cpuregs[5][11] ,
         \cpuregs[5][10] , \cpuregs[5][9] , \cpuregs[5][8] , \cpuregs[5][7] ,
         \cpuregs[5][6] , \cpuregs[5][5] , \cpuregs[5][4] , \cpuregs[5][3] ,
         \cpuregs[5][2] , \cpuregs[5][1] , \cpuregs[5][0] , \cpuregs[6][31] ,
         \cpuregs[6][30] , \cpuregs[6][29] , \cpuregs[6][28] ,
         \cpuregs[6][27] , \cpuregs[6][26] , \cpuregs[6][25] ,
         \cpuregs[6][24] , \cpuregs[6][23] , \cpuregs[6][22] ,
         \cpuregs[6][21] , \cpuregs[6][20] , \cpuregs[6][19] ,
         \cpuregs[6][18] , \cpuregs[6][17] , \cpuregs[6][16] ,
         \cpuregs[6][15] , \cpuregs[6][14] , \cpuregs[6][13] ,
         \cpuregs[6][12] , \cpuregs[6][11] , \cpuregs[6][10] , \cpuregs[6][9] ,
         \cpuregs[6][8] , \cpuregs[6][7] , \cpuregs[6][6] , \cpuregs[6][5] ,
         \cpuregs[6][4] , \cpuregs[6][3] , \cpuregs[6][2] , \cpuregs[6][1] ,
         \cpuregs[6][0] , \cpuregs[7][31] , \cpuregs[7][30] , \cpuregs[7][29] ,
         \cpuregs[7][28] , \cpuregs[7][27] , \cpuregs[7][26] ,
         \cpuregs[7][25] , \cpuregs[7][24] , \cpuregs[7][23] ,
         \cpuregs[7][22] , \cpuregs[7][21] , \cpuregs[7][20] ,
         \cpuregs[7][19] , \cpuregs[7][18] , \cpuregs[7][17] ,
         \cpuregs[7][16] , \cpuregs[7][15] , \cpuregs[7][14] ,
         \cpuregs[7][13] , \cpuregs[7][12] , \cpuregs[7][11] ,
         \cpuregs[7][10] , \cpuregs[7][9] , \cpuregs[7][8] , \cpuregs[7][7] ,
         \cpuregs[7][6] , \cpuregs[7][5] , \cpuregs[7][4] , \cpuregs[7][3] ,
         \cpuregs[7][2] , \cpuregs[7][1] , \cpuregs[7][0] , \cpuregs[8][31] ,
         \cpuregs[8][30] , \cpuregs[8][29] , \cpuregs[8][28] ,
         \cpuregs[8][27] , \cpuregs[8][26] , \cpuregs[8][25] ,
         \cpuregs[8][24] , \cpuregs[8][23] , \cpuregs[8][22] ,
         \cpuregs[8][21] , \cpuregs[8][20] , \cpuregs[8][19] ,
         \cpuregs[8][18] , \cpuregs[8][17] , \cpuregs[8][16] ,
         \cpuregs[8][15] , \cpuregs[8][14] , \cpuregs[8][13] ,
         \cpuregs[8][12] , \cpuregs[8][11] , \cpuregs[8][10] , \cpuregs[8][9] ,
         \cpuregs[8][8] , \cpuregs[8][7] , \cpuregs[8][6] , \cpuregs[8][5] ,
         \cpuregs[8][4] , \cpuregs[8][3] , \cpuregs[8][2] , \cpuregs[8][1] ,
         \cpuregs[8][0] , \cpuregs[9][31] , \cpuregs[9][30] , \cpuregs[9][29] ,
         \cpuregs[9][28] , \cpuregs[9][27] , \cpuregs[9][26] ,
         \cpuregs[9][25] , \cpuregs[9][24] , \cpuregs[9][23] ,
         \cpuregs[9][22] , \cpuregs[9][21] , \cpuregs[9][20] ,
         \cpuregs[9][19] , \cpuregs[9][18] , \cpuregs[9][17] ,
         \cpuregs[9][16] , \cpuregs[9][15] , \cpuregs[9][14] ,
         \cpuregs[9][13] , \cpuregs[9][12] , \cpuregs[9][11] ,
         \cpuregs[9][10] , \cpuregs[9][9] , \cpuregs[9][8] , \cpuregs[9][7] ,
         \cpuregs[9][6] , \cpuregs[9][5] , \cpuregs[9][4] , \cpuregs[9][3] ,
         \cpuregs[9][2] , \cpuregs[9][1] , \cpuregs[9][0] , \cpuregs[10][31] ,
         \cpuregs[10][30] , \cpuregs[10][29] , \cpuregs[10][28] ,
         \cpuregs[10][27] , \cpuregs[10][26] , \cpuregs[10][25] ,
         \cpuregs[10][24] , \cpuregs[10][23] , \cpuregs[10][22] ,
         \cpuregs[10][21] , \cpuregs[10][20] , \cpuregs[10][19] ,
         \cpuregs[10][18] , \cpuregs[10][17] , \cpuregs[10][16] ,
         \cpuregs[10][15] , \cpuregs[10][14] , \cpuregs[10][13] ,
         \cpuregs[10][12] , \cpuregs[10][11] , \cpuregs[10][10] ,
         \cpuregs[10][9] , \cpuregs[10][8] , \cpuregs[10][7] ,
         \cpuregs[10][6] , \cpuregs[10][5] , \cpuregs[10][4] ,
         \cpuregs[10][3] , \cpuregs[10][2] , \cpuregs[10][1] ,
         \cpuregs[10][0] , \cpuregs[11][31] , \cpuregs[11][30] ,
         \cpuregs[11][29] , \cpuregs[11][28] , \cpuregs[11][27] ,
         \cpuregs[11][26] , \cpuregs[11][25] , \cpuregs[11][24] ,
         \cpuregs[11][23] , \cpuregs[11][22] , \cpuregs[11][21] ,
         \cpuregs[11][20] , \cpuregs[11][19] , \cpuregs[11][18] ,
         \cpuregs[11][17] , \cpuregs[11][16] , \cpuregs[11][15] ,
         \cpuregs[11][14] , \cpuregs[11][13] , \cpuregs[11][12] ,
         \cpuregs[11][11] , \cpuregs[11][10] , \cpuregs[11][9] ,
         \cpuregs[11][8] , \cpuregs[11][7] , \cpuregs[11][6] ,
         \cpuregs[11][5] , \cpuregs[11][4] , \cpuregs[11][3] ,
         \cpuregs[11][2] , \cpuregs[11][1] , \cpuregs[11][0] ,
         \cpuregs[12][31] , \cpuregs[12][30] , \cpuregs[12][29] ,
         \cpuregs[12][28] , \cpuregs[12][27] , \cpuregs[12][26] ,
         \cpuregs[12][25] , \cpuregs[12][24] , \cpuregs[12][23] ,
         \cpuregs[12][22] , \cpuregs[12][21] , \cpuregs[12][20] ,
         \cpuregs[12][19] , \cpuregs[12][18] , \cpuregs[12][17] ,
         \cpuregs[12][16] , \cpuregs[12][15] , \cpuregs[12][14] ,
         \cpuregs[12][13] , \cpuregs[12][12] , \cpuregs[12][11] ,
         \cpuregs[12][10] , \cpuregs[12][9] , \cpuregs[12][8] ,
         \cpuregs[12][7] , \cpuregs[12][6] , \cpuregs[12][5] ,
         \cpuregs[12][4] , \cpuregs[12][3] , \cpuregs[12][2] ,
         \cpuregs[12][1] , \cpuregs[12][0] , \cpuregs[13][31] ,
         \cpuregs[13][30] , \cpuregs[13][29] , \cpuregs[13][28] ,
         \cpuregs[13][27] , \cpuregs[13][26] , \cpuregs[13][25] ,
         \cpuregs[13][24] , \cpuregs[13][23] , \cpuregs[13][22] ,
         \cpuregs[13][21] , \cpuregs[13][20] , \cpuregs[13][19] ,
         \cpuregs[13][18] , \cpuregs[13][17] , \cpuregs[13][16] ,
         \cpuregs[13][15] , \cpuregs[13][14] , \cpuregs[13][13] ,
         \cpuregs[13][12] , \cpuregs[13][11] , \cpuregs[13][10] ,
         \cpuregs[13][9] , \cpuregs[13][8] , \cpuregs[13][7] ,
         \cpuregs[13][6] , \cpuregs[13][5] , \cpuregs[13][4] ,
         \cpuregs[13][3] , \cpuregs[13][2] , \cpuregs[13][1] ,
         \cpuregs[13][0] , \cpuregs[14][31] , \cpuregs[14][30] ,
         \cpuregs[14][29] , \cpuregs[14][28] , \cpuregs[14][27] ,
         \cpuregs[14][26] , \cpuregs[14][25] , \cpuregs[14][24] ,
         \cpuregs[14][23] , \cpuregs[14][22] , \cpuregs[14][21] ,
         \cpuregs[14][20] , \cpuregs[14][19] , \cpuregs[14][18] ,
         \cpuregs[14][17] , \cpuregs[14][16] , \cpuregs[14][15] ,
         \cpuregs[14][14] , \cpuregs[14][13] , \cpuregs[14][12] ,
         \cpuregs[14][11] , \cpuregs[14][10] , \cpuregs[14][9] ,
         \cpuregs[14][8] , \cpuregs[14][7] , \cpuregs[14][6] ,
         \cpuregs[14][5] , \cpuregs[14][4] , \cpuregs[14][3] ,
         \cpuregs[14][2] , \cpuregs[14][1] , \cpuregs[14][0] ,
         \cpuregs[15][31] , \cpuregs[15][30] , \cpuregs[15][29] ,
         \cpuregs[15][28] , \cpuregs[15][27] , \cpuregs[15][26] ,
         \cpuregs[15][25] , \cpuregs[15][24] , \cpuregs[15][23] ,
         \cpuregs[15][22] , \cpuregs[15][21] , \cpuregs[15][20] ,
         \cpuregs[15][19] , \cpuregs[15][18] , \cpuregs[15][17] ,
         \cpuregs[15][16] , \cpuregs[15][15] , \cpuregs[15][14] ,
         \cpuregs[15][13] , \cpuregs[15][12] , \cpuregs[15][11] ,
         \cpuregs[15][10] , \cpuregs[15][9] , \cpuregs[15][8] ,
         \cpuregs[15][7] , \cpuregs[15][6] , \cpuregs[15][5] ,
         \cpuregs[15][4] , \cpuregs[15][3] , \cpuregs[15][2] ,
         \cpuregs[15][1] , \cpuregs[15][0] , \cpuregs[16][31] ,
         \cpuregs[16][30] , \cpuregs[16][29] , \cpuregs[16][28] ,
         \cpuregs[16][27] , \cpuregs[16][26] , \cpuregs[16][25] ,
         \cpuregs[16][24] , \cpuregs[16][23] , \cpuregs[16][22] ,
         \cpuregs[16][21] , \cpuregs[16][20] , \cpuregs[16][19] ,
         \cpuregs[16][18] , \cpuregs[16][17] , \cpuregs[16][16] ,
         \cpuregs[16][15] , \cpuregs[16][14] , \cpuregs[16][13] ,
         \cpuregs[16][12] , \cpuregs[16][11] , \cpuregs[16][10] ,
         \cpuregs[16][9] , \cpuregs[16][8] , \cpuregs[16][7] ,
         \cpuregs[16][6] , \cpuregs[16][5] , \cpuregs[16][4] ,
         \cpuregs[16][3] , \cpuregs[16][2] , \cpuregs[16][1] ,
         \cpuregs[16][0] , \cpuregs[17][31] , \cpuregs[17][30] ,
         \cpuregs[17][29] , \cpuregs[17][28] , \cpuregs[17][27] ,
         \cpuregs[17][26] , \cpuregs[17][25] , \cpuregs[17][24] ,
         \cpuregs[17][23] , \cpuregs[17][22] , \cpuregs[17][21] ,
         \cpuregs[17][20] , \cpuregs[17][19] , \cpuregs[17][18] ,
         \cpuregs[17][17] , \cpuregs[17][16] , \cpuregs[17][15] ,
         \cpuregs[17][14] , \cpuregs[17][13] , \cpuregs[17][12] ,
         \cpuregs[17][11] , \cpuregs[17][10] , \cpuregs[17][9] ,
         \cpuregs[17][8] , \cpuregs[17][7] , \cpuregs[17][6] ,
         \cpuregs[17][5] , \cpuregs[17][4] , \cpuregs[17][3] ,
         \cpuregs[17][2] , \cpuregs[17][1] , \cpuregs[17][0] ,
         \cpuregs[18][31] , \cpuregs[18][30] , \cpuregs[18][29] ,
         \cpuregs[18][28] , \cpuregs[18][27] , \cpuregs[18][26] ,
         \cpuregs[18][25] , \cpuregs[18][24] , \cpuregs[18][23] ,
         \cpuregs[18][22] , \cpuregs[18][21] , \cpuregs[18][20] ,
         \cpuregs[18][19] , \cpuregs[18][18] , \cpuregs[18][17] ,
         \cpuregs[18][16] , \cpuregs[18][15] , \cpuregs[18][14] ,
         \cpuregs[18][13] , \cpuregs[18][12] , \cpuregs[18][11] ,
         \cpuregs[18][10] , \cpuregs[18][9] , \cpuregs[18][8] ,
         \cpuregs[18][7] , \cpuregs[18][6] , \cpuregs[18][5] ,
         \cpuregs[18][4] , \cpuregs[18][3] , \cpuregs[18][2] ,
         \cpuregs[18][1] , \cpuregs[18][0] , \cpuregs[19][31] ,
         \cpuregs[19][30] , \cpuregs[19][29] , \cpuregs[19][28] ,
         \cpuregs[19][27] , \cpuregs[19][26] , \cpuregs[19][25] ,
         \cpuregs[19][24] , \cpuregs[19][23] , \cpuregs[19][22] ,
         \cpuregs[19][21] , \cpuregs[19][20] , \cpuregs[19][19] ,
         \cpuregs[19][18] , \cpuregs[19][17] , \cpuregs[19][16] ,
         \cpuregs[19][15] , \cpuregs[19][14] , \cpuregs[19][13] ,
         \cpuregs[19][12] , \cpuregs[19][11] , \cpuregs[19][10] ,
         \cpuregs[19][9] , \cpuregs[19][8] , \cpuregs[19][7] ,
         \cpuregs[19][6] , \cpuregs[19][5] , \cpuregs[19][4] ,
         \cpuregs[19][3] , \cpuregs[19][2] , \cpuregs[19][1] ,
         \cpuregs[19][0] , \cpuregs[20][31] , \cpuregs[20][30] ,
         \cpuregs[20][29] , \cpuregs[20][28] , \cpuregs[20][27] ,
         \cpuregs[20][26] , \cpuregs[20][25] , \cpuregs[20][24] ,
         \cpuregs[20][23] , \cpuregs[20][22] , \cpuregs[20][21] ,
         \cpuregs[20][20] , \cpuregs[20][19] , \cpuregs[20][18] ,
         \cpuregs[20][17] , \cpuregs[20][16] , \cpuregs[20][15] ,
         \cpuregs[20][14] , \cpuregs[20][13] , \cpuregs[20][12] ,
         \cpuregs[20][11] , \cpuregs[20][10] , \cpuregs[20][9] ,
         \cpuregs[20][8] , \cpuregs[20][7] , \cpuregs[20][6] ,
         \cpuregs[20][5] , \cpuregs[20][4] , \cpuregs[20][3] ,
         \cpuregs[20][2] , \cpuregs[20][1] , \cpuregs[20][0] ,
         \cpuregs[21][31] , \cpuregs[21][30] , \cpuregs[21][29] ,
         \cpuregs[21][28] , \cpuregs[21][27] , \cpuregs[21][26] ,
         \cpuregs[21][25] , \cpuregs[21][24] , \cpuregs[21][23] ,
         \cpuregs[21][22] , \cpuregs[21][21] , \cpuregs[21][20] ,
         \cpuregs[21][19] , \cpuregs[21][18] , \cpuregs[21][17] ,
         \cpuregs[21][16] , \cpuregs[21][15] , \cpuregs[21][14] ,
         \cpuregs[21][13] , \cpuregs[21][12] , \cpuregs[21][11] ,
         \cpuregs[21][10] , \cpuregs[21][9] , \cpuregs[21][8] ,
         \cpuregs[21][7] , \cpuregs[21][6] , \cpuregs[21][5] ,
         \cpuregs[21][4] , \cpuregs[21][3] , \cpuregs[21][2] ,
         \cpuregs[21][1] , \cpuregs[21][0] , \cpuregs[22][31] ,
         \cpuregs[22][30] , \cpuregs[22][29] , \cpuregs[22][28] ,
         \cpuregs[22][27] , \cpuregs[22][26] , \cpuregs[22][25] ,
         \cpuregs[22][24] , \cpuregs[22][23] , \cpuregs[22][22] ,
         \cpuregs[22][21] , \cpuregs[22][20] , \cpuregs[22][19] ,
         \cpuregs[22][18] , \cpuregs[22][17] , \cpuregs[22][16] ,
         \cpuregs[22][15] , \cpuregs[22][14] , \cpuregs[22][13] ,
         \cpuregs[22][12] , \cpuregs[22][11] , \cpuregs[22][10] ,
         \cpuregs[22][9] , \cpuregs[22][8] , \cpuregs[22][7] ,
         \cpuregs[22][6] , \cpuregs[22][5] , \cpuregs[22][4] ,
         \cpuregs[22][3] , \cpuregs[22][2] , \cpuregs[22][1] ,
         \cpuregs[22][0] , \cpuregs[23][31] , \cpuregs[23][30] ,
         \cpuregs[23][29] , \cpuregs[23][28] , \cpuregs[23][27] ,
         \cpuregs[23][26] , \cpuregs[23][25] , \cpuregs[23][24] ,
         \cpuregs[23][23] , \cpuregs[23][22] , \cpuregs[23][21] ,
         \cpuregs[23][20] , \cpuregs[23][19] , \cpuregs[23][18] ,
         \cpuregs[23][17] , \cpuregs[23][16] , \cpuregs[23][15] ,
         \cpuregs[23][14] , \cpuregs[23][13] , \cpuregs[23][12] ,
         \cpuregs[23][11] , \cpuregs[23][10] , \cpuregs[23][9] ,
         \cpuregs[23][8] , \cpuregs[23][7] , \cpuregs[23][6] ,
         \cpuregs[23][5] , \cpuregs[23][4] , \cpuregs[23][3] ,
         \cpuregs[23][2] , \cpuregs[23][1] , \cpuregs[23][0] ,
         \cpuregs[24][31] , \cpuregs[24][30] , \cpuregs[24][29] ,
         \cpuregs[24][28] , \cpuregs[24][27] , \cpuregs[24][26] ,
         \cpuregs[24][25] , \cpuregs[24][24] , \cpuregs[24][23] ,
         \cpuregs[24][22] , \cpuregs[24][21] , \cpuregs[24][20] ,
         \cpuregs[24][19] , \cpuregs[24][18] , \cpuregs[24][17] ,
         \cpuregs[24][16] , \cpuregs[24][15] , \cpuregs[24][14] ,
         \cpuregs[24][13] , \cpuregs[24][12] , \cpuregs[24][11] ,
         \cpuregs[24][10] , \cpuregs[24][9] , \cpuregs[24][8] ,
         \cpuregs[24][7] , \cpuregs[24][6] , \cpuregs[24][5] ,
         \cpuregs[24][4] , \cpuregs[24][3] , \cpuregs[24][2] ,
         \cpuregs[24][1] , \cpuregs[24][0] , \cpuregs[25][31] ,
         \cpuregs[25][30] , \cpuregs[25][29] , \cpuregs[25][28] ,
         \cpuregs[25][27] , \cpuregs[25][26] , \cpuregs[25][25] ,
         \cpuregs[25][24] , \cpuregs[25][23] , \cpuregs[25][22] ,
         \cpuregs[25][21] , \cpuregs[25][20] , \cpuregs[25][19] ,
         \cpuregs[25][18] , \cpuregs[25][17] , \cpuregs[25][16] ,
         \cpuregs[25][15] , \cpuregs[25][14] , \cpuregs[25][13] ,
         \cpuregs[25][12] , \cpuregs[25][11] , \cpuregs[25][10] ,
         \cpuregs[25][9] , \cpuregs[25][8] , \cpuregs[25][7] ,
         \cpuregs[25][6] , \cpuregs[25][5] , \cpuregs[25][4] ,
         \cpuregs[25][3] , \cpuregs[25][2] , \cpuregs[25][1] ,
         \cpuregs[25][0] , \cpuregs[26][31] , \cpuregs[26][30] ,
         \cpuregs[26][29] , \cpuregs[26][28] , \cpuregs[26][27] ,
         \cpuregs[26][26] , \cpuregs[26][25] , \cpuregs[26][24] ,
         \cpuregs[26][23] , \cpuregs[26][22] , \cpuregs[26][21] ,
         \cpuregs[26][20] , \cpuregs[26][19] , \cpuregs[26][18] ,
         \cpuregs[26][17] , \cpuregs[26][16] , \cpuregs[26][15] ,
         \cpuregs[26][14] , \cpuregs[26][13] , \cpuregs[26][12] ,
         \cpuregs[26][11] , \cpuregs[26][10] , \cpuregs[26][9] ,
         \cpuregs[26][8] , \cpuregs[26][7] , \cpuregs[26][6] ,
         \cpuregs[26][5] , \cpuregs[26][4] , \cpuregs[26][3] ,
         \cpuregs[26][2] , \cpuregs[26][1] , \cpuregs[26][0] ,
         \cpuregs[27][31] , \cpuregs[27][30] , \cpuregs[27][29] ,
         \cpuregs[27][28] , \cpuregs[27][27] , \cpuregs[27][26] ,
         \cpuregs[27][25] , \cpuregs[27][24] , \cpuregs[27][23] ,
         \cpuregs[27][22] , \cpuregs[27][21] , \cpuregs[27][20] ,
         \cpuregs[27][19] , \cpuregs[27][18] , \cpuregs[27][17] ,
         \cpuregs[27][16] , \cpuregs[27][15] , \cpuregs[27][14] ,
         \cpuregs[27][13] , \cpuregs[27][12] , \cpuregs[27][11] ,
         \cpuregs[27][10] , \cpuregs[27][9] , \cpuregs[27][8] ,
         \cpuregs[27][7] , \cpuregs[27][6] , \cpuregs[27][5] ,
         \cpuregs[27][4] , \cpuregs[27][3] , \cpuregs[27][2] ,
         \cpuregs[27][1] , \cpuregs[27][0] , \cpuregs[28][31] ,
         \cpuregs[28][30] , \cpuregs[28][29] , \cpuregs[28][28] ,
         \cpuregs[28][27] , \cpuregs[28][26] , \cpuregs[28][25] ,
         \cpuregs[28][24] , \cpuregs[28][23] , \cpuregs[28][22] ,
         \cpuregs[28][21] , \cpuregs[28][20] , \cpuregs[28][19] ,
         \cpuregs[28][18] , \cpuregs[28][17] , \cpuregs[28][16] ,
         \cpuregs[28][15] , \cpuregs[28][14] , \cpuregs[28][13] ,
         \cpuregs[28][12] , \cpuregs[28][11] , \cpuregs[28][10] ,
         \cpuregs[28][9] , \cpuregs[28][8] , \cpuregs[28][7] ,
         \cpuregs[28][6] , \cpuregs[28][5] , \cpuregs[28][4] ,
         \cpuregs[28][3] , \cpuregs[28][2] , \cpuregs[28][1] ,
         \cpuregs[28][0] , \cpuregs[29][31] , \cpuregs[29][30] ,
         \cpuregs[29][29] , \cpuregs[29][28] , \cpuregs[29][27] ,
         \cpuregs[29][26] , \cpuregs[29][25] , \cpuregs[29][24] ,
         \cpuregs[29][23] , \cpuregs[29][22] , \cpuregs[29][21] ,
         \cpuregs[29][20] , \cpuregs[29][19] , \cpuregs[29][18] ,
         \cpuregs[29][17] , \cpuregs[29][16] , \cpuregs[29][15] ,
         \cpuregs[29][14] , \cpuregs[29][13] , \cpuregs[29][12] ,
         \cpuregs[29][11] , \cpuregs[29][10] , \cpuregs[29][9] ,
         \cpuregs[29][8] , \cpuregs[29][7] , \cpuregs[29][6] ,
         \cpuregs[29][5] , \cpuregs[29][4] , \cpuregs[29][3] ,
         \cpuregs[29][2] , \cpuregs[29][1] , \cpuregs[29][0] ,
         \cpuregs[30][31] , \cpuregs[30][30] , \cpuregs[30][29] ,
         \cpuregs[30][28] , \cpuregs[30][27] , \cpuregs[30][26] ,
         \cpuregs[30][25] , \cpuregs[30][24] , \cpuregs[30][23] ,
         \cpuregs[30][22] , \cpuregs[30][21] , \cpuregs[30][20] ,
         \cpuregs[30][19] , \cpuregs[30][18] , \cpuregs[30][17] ,
         \cpuregs[30][16] , \cpuregs[30][15] , \cpuregs[30][14] ,
         \cpuregs[30][13] , \cpuregs[30][12] , \cpuregs[30][11] ,
         \cpuregs[30][10] , \cpuregs[30][9] , \cpuregs[30][8] ,
         \cpuregs[30][7] , \cpuregs[30][6] , \cpuregs[30][5] ,
         \cpuregs[30][4] , \cpuregs[30][3] , \cpuregs[30][2] ,
         \cpuregs[30][1] , \cpuregs[30][0] , \cpuregs[31][31] ,
         \cpuregs[31][30] , \cpuregs[31][29] , \cpuregs[31][28] ,
         \cpuregs[31][27] , \cpuregs[31][26] , \cpuregs[31][25] ,
         \cpuregs[31][24] , \cpuregs[31][23] , \cpuregs[31][22] ,
         \cpuregs[31][21] , \cpuregs[31][20] , \cpuregs[31][19] ,
         \cpuregs[31][18] , \cpuregs[31][17] , \cpuregs[31][16] ,
         \cpuregs[31][15] , \cpuregs[31][14] , \cpuregs[31][13] ,
         \cpuregs[31][12] , \cpuregs[31][11] , \cpuregs[31][10] ,
         \cpuregs[31][9] , \cpuregs[31][8] , \cpuregs[31][7] ,
         \cpuregs[31][6] , \cpuregs[31][5] , \cpuregs[31][4] ,
         \cpuregs[31][3] , \cpuregs[31][2] , \cpuregs[31][1] ,
         \cpuregs[31][0] , N890, N1570, N1571, latched_is_lu, latched_is_lh,
         latched_is_lb, N1877, N1878, N1879, N1880, N1881, N1882, N1883, N1884,
         N1885, N1886, N1887, N1888, N1889, N1890, N1891, N1892, N1893, N1894,
         N1895, N1896, N1897, N1898, N1899, N1900, N1901, N1902, N1903, N1904,
         N1905, N1906, N1907, N1908, N1909, N1910, N1911, N1912, N1913, N2068,
         N2077, N2078, n2732, n2734, n2735, n2736, n2737, n2738, n2739, n2740,
         n2741, n2742, n2743, n2744, n2745, n2746, n2747, n2748, n2749, n2750,
         n2751, n2752, n2753, n2754, n2755, n2756, n2757, n2758, n2759, n2760,
         n2761, n2762, n2763, n2764, n2765, n2766, n2767, n2768, n2769, n2770,
         n2771, n2772, n2773, n2774, n2775, n2776, n2777, n2778, n2779, n2780,
         n2781, n2782, n2783, n2784, n2785, n2786, n2787, n2788, n2789, n2790,
         n2791, n2792, n2793, n2794, n2795, n2796, n2797, n2798, n2799, n2800,
         n2801, n2802, n2803, n2804, n2805, n2806, n2807, n2808, n2809, n2810,
         n2811, n2812, n2813, n2814, n2815, n2816, n2817, n2818, n2819, n2820,
         n2821, n2822, n2823, n2824, n2825, n2826, n2827, n2828, n2829, n2830,
         n2831, n2832, n2833, n2834, n2835, n2836, n2837, n2838, n2839, n2840,
         n2841, n2842, n2843, n2844, n2845, n2846, n2847, n2848, n2849, n2850,
         n2851, n2852, n2853, n2854, n2855, n2856, n2857, n2858, n2859, n2860,
         n2861, n2862, n2863, n2864, n2865, n2866, n2867, n2868, n2869, n2870,
         n2871, n2872, n2873, n2874, n2875, n2876, n2877, n2878, n2879, n2880,
         n2881, n2882, n2883, n2884, n2885, n2886, n2887, n2888, n2889, n2890,
         n2891, n2893, n2895, n2896, n2897, n2898, n2899, n2900, n2901, n2902,
         n2903, n2904, n2905, n2906, n2907, n2908, n2909, n2910, n2913, n2914,
         n2915, n2916, n2917, n2918, n2919, n2920, n2921, n2922, n2923, n2924,
         n2925, n2926, n2927, n2928, n2929, n2930, n2931, n2933, n2934, n2935,
         n2936, n2937, n2938, n2939, n2940, n2941, n2942, n2943, n2944, n2945,
         n2946, n2947, n2948, n2949, n2950, n2951, n2952, n2953, n2954, n2955,
         n2956, n2957, n2958, n2959, n2960, n2961, n2962, n2963, n2964, n2965,
         n2966, n2967, n2968, n2969, n2970, n2971, n2972, n2973, n2974, n2975,
         n2976, n2977, n2978, n2979, n2980, n2981, n2982, n2983, n2984, n2985,
         n2986, n2987, n2988, n2989, n2990, n2991, n2992, n2993, n2994, n2995,
         n2996, n2997, n2998, n2999, n3000, n3001, n3002, n3003, n3004, n3005,
         n3006, n3007, n3008, n3009, n3010, n3011, n3012, n3013, n3014, n3015,
         n3016, n3017, n3018, n3019, n3020, n3021, n3022, n3023, n3024, n3025,
         n3026, n3027, n3028, n3029, n3030, n3031, n3032, n3033, n3034, n3035,
         n3036, n3037, n3038, n3039, n3040, n3041, n3042, n3043, n3044, n3045,
         n3046, n3047, n3048, n3049, n3050, n3051, n3052, n3053, n3054, n3055,
         n3056, n3057, n3058, n3059, n3060, n3061, n3062, n3063, n3064, n3065,
         n3066, n3067, n3068, n3069, n3070, n3071, n3072, n3073, n3074, n3075,
         n3076, n3077, n3078, n3079, n3080, n3081, n3082, n3083, n3084, n3085,
         n3086, n3087, n3088, n3089, n3090, n3091, n3092, n3093, n3094, n3095,
         n3096, n3097, n3098, n3099, n3100, n3101, n3102, n3103, n3104, n3105,
         n3106, n3107, n3108, n3109, n3110, n3111, n3112, n3113, n3114, n3115,
         n3116, n3117, n3118, n3119, n3120, n3121, n3122, n3123, n3124, n3125,
         n3126, n3127, n3128, n3129, n3130, n3131, n3132, n3133, n3134, n3135,
         n3136, n3137, n3138, n3139, n3140, n3141, n3142, n3143, n3144, n3145,
         n3146, n3147, n3148, n3149, n3150, n3151, n3152, n3153, n3154, n3155,
         n3156, n3157, n3158, n3159, n3160, n3161, n3162, n3163, n3164, n3165,
         n3166, n3167, n3168, n3169, n3170, n3171, n3172, n3173, n3174, n3175,
         n3176, n3177, n3178, n3179, n3180, n3181, n3182, n3183, n3184, n3185,
         n3186, n3187, n3188, n3189, n3190, n3191, n3192, n3193, n3194, n3195,
         n3196, n3197, n3198, n3199, n3200, n3201, n3202, n3203, n3204, n3205,
         n3206, n3207, n3208, n3209, n3210, n3211, n3212, n3213, n3214, n3215,
         n3216, n3217, n3218, n3219, n3220, n3221, n3222, n3223, n3224, n3225,
         n3226, n3227, n3228, n3229, n3230, n3231, n3232, n3233, n3234, n3235,
         n3236, n3237, n3238, n3239, n3240, n3241, n3242, n3243, n3244, n3245,
         n3246, n3247, n3248, n3249, n3250, n3251, n3252, n3253, n3254, n3255,
         n3256, n3257, n3258, n3259, n3260, n3261, n3262, n3263, n3264, n3265,
         n3266, n3267, n3268, n3269, n3270, n3271, n3272, n3273, n3274, n3275,
         n3276, n3277, n3278, n3279, n3280, n3281, n3282, n3283, n3284, n3285,
         n3286, n3287, n3288, n3289, n3290, n3291, n3292, n3293, n3294, n3295,
         n3296, n3297, n3298, n3299, n3300, n3301, n3302, n3303, n3304, n3305,
         n3306, n3307, n3308, n3309, n3310, n3311, n3312, n3313, n3314, n3315,
         n3316, n3317, n3318, n3319, n3320, n3321, n3322, n3323, n3324, n3325,
         n3326, n3327, n3328, n3329, n3330, n3331, n3332, n3333, n3334, n3335,
         n3336, n3337, n3338, n3339, n3340, n3341, n3342, n3343, n3344, n3345,
         n3346, n3347, n3348, n3349, n3350, n3351, n3352, n3353, n3354, n3355,
         n3356, n3357, n3358, n3359, n3360, n3361, n3362, n3363, n3364, n3365,
         n3366, n3367, n3368, n3369, n3370, n3371, n3372, n3373, n3374, n3375,
         n3376, n3377, n3378, n3379, n3380, n3381, n3382, n3383, n3384, n3385,
         n3386, n3387, n3388, n3389, n3390, n3391, n3392, n3393, n3394, n3395,
         n3396, n3397, n3398, n3399, n3400, n3401, n3402, n3403, n3404, n3405,
         n3406, n3407, n3408, n3409, n3410, n3411, n3412, n3413, n3414, n3415,
         n3416, n3417, n3418, n3419, n3420, n3421, n3422, n3423, n3424, n3425,
         n3426, n3427, n3428, n3429, n3430, n3431, n3432, n3433, n3434, n3435,
         n3436, n3437, n3438, n3439, n3440, n3441, n3442, n3443, n3444, n3445,
         n3446, n3447, n3448, n3449, n3450, n3451, n3452, n3453, n3454, n3455,
         n3456, n3457, n3458, n3459, n3460, n3461, n3462, n3463, n3464, n3465,
         n3466, n3467, n3468, n3469, n3470, n3471, n3472, n3473, n3474, n3475,
         n3476, n3477, n3478, n3479, n3480, n3481, n3482, n3483, n3484, n3485,
         n3486, n3487, n3488, n3489, n3490, n3491, n3492, n3493, n3494, n3495,
         n3496, n3497, n3498, n3499, n3500, n3501, n3502, n3503, n3504, n3505,
         n3506, n3507, n3508, n3509, n3510, n3511, n3512, n3513, n3514, n3515,
         n3516, n3517, n3518, n3519, n3520, n3521, n3522, n3523, n3524, n3525,
         n3526, n3527, n3528, n3529, n3530, n3531, n3532, n3533, n3534, n3535,
         n3536, n3537, n3538, n3539, n3540, n3541, n3542, n3543, n3544, n3545,
         n3546, n3547, n3548, n3549, n3550, n3551, n3552, n3553, n3554, n3555,
         n3556, n3557, n3558, n3559, n3560, n3561, n3562, n3563, n3564, n3565,
         n3566, n3567, n3568, n3569, n3570, n3571, n3572, n3573, n3574, n3575,
         n3576, n3577, n3578, n3579, n3580, n3581, n3582, n3583, n3584, n3585,
         n3586, n3587, n3588, n3589, n3590, n3591, n3592, n3593, n3594, n3595,
         n3596, n3597, n3598, n3599, n3600, n3601, n3602, n3603, n3604, n3605,
         n3606, n3607, n3608, n3609, n3610, n3611, n3612, n3613, n3614, n3615,
         n3616, n3617, n3618, n3619, n3620, n3621, n3622, n3623, n3624, n3625,
         n3626, n3627, n3628, n3629, n3630, n3631, n3632, n3633, n3634, n3635,
         n3636, n3637, n3638, n3639, n3640, n3641, n3642, n3643, n3644, n3645,
         n3646, n3647, n3648, n3649, n3650, n3651, n3652, n3653, n3654, n3655,
         n3656, n3657, n3658, n3659, n3660, n3661, n3662, n3663, n3664, n3665,
         n3666, n3667, n3668, n3669, n3670, n3671, n3672, n3673, n3674, n3675,
         n3676, n3677, n3678, n3679, n3680, n3681, n3682, n3683, n3684, n3685,
         n3686, n3687, n3688, n3689, n3690, n3691, n3692, n3693, n3694, n3695,
         n3696, n3697, n3698, n3699, n3700, n3701, n3702, n3703, n3704, n3705,
         n3706, n3707, n3708, n3709, n3710, n3711, n3712, n3713, n3714, n3715,
         n3716, n3717, n3718, n3719, n3720, n3721, n3722, n3723, n3724, n3725,
         n3726, n3727, n3728, n3729, n3730, n3731, n3732, n3733, n3734, n3735,
         n3736, n3737, n3738, n3739, n3740, n3741, n3742, n3743, n3744, n3745,
         n3746, n3747, n3748, n3749, n3750, n3751, n3752, n3753, n3754, n3755,
         n3756, n3757, n3758, n3759, n3760, n3761, n3762, n3763, n3764, n3765,
         n3766, n3767, n3768, n3769, n3770, n3771, n3772, n3773, n3774, n3775,
         n3776, n3777, n3778, n3779, n3780, n3781, n3782, n3783, n3784, n3785,
         n3786, n3787, n3788, n3789, n3790, n3791, n3792, n3793, n3794, n3795,
         n3796, n3797, n3798, n3799, n3800, n3801, n3802, n3803, n3804, n3805,
         n3806, n3807, n3808, n3809, n3810, n3811, n3812, n3813, n3814, n3815,
         n3816, n3817, n3818, n3819, n3820, n3821, n3822, n3823, n3824, n3825,
         n3826, n3827, n3828, n3829, n3830, n3831, n3832, n3833, n3834, n3835,
         n3836, n3837, n3838, n3839, n3840, n3841, n3842, n3843, n3844, n3845,
         n3846, n3847, n3848, n3849, n3850, n3851, n3852, n3853, n3854, n3855,
         n3856, n3857, n3858, n3859, n3860, n3861, n3862, n3863, n3864, n3865,
         n3866, n3867, n3868, n3869, n3870, n3871, n3872, n3873, n3874, n3875,
         n3876, n3877, n3878, n3879, n3880, n3881, n3882, n3883, n3884, n3885,
         n3886, n3887, n3888, n3889, n3890, n3891, n3892, n3893, n3894, n3895,
         n3896, n3897, n3898, n3899, n3900, n3901, n3902, n3903, n3904, n3905,
         n3906, n3907, n3908, n3909, n3910, n3911, n3912, n3913, n3914, n3915,
         n3916, n3917, n3918, n3919, n3920, n3921, n3922, n3923, n3924, n3925,
         n3926, n3927, n3928, n3929, n3930, n3931, n3932, n3933, n3934, n3935,
         n3936, n3937, n3938, n3939, n3940, n3941, n3942, n3943, n3944, n3945,
         n3946, n3947, n3948, n3949, n3950, n3951, n3952, n3953, n3954, n3955,
         n3956, n3957, n3958, n3959, n3960, n3961, n3962, n3963, n3964, n3965,
         n3966, n3967, n3968, n3969, n3970, n3971, n3972, n3973, n3974, n3975,
         n3976, n3977, n3978, n3979, n3980, n3981, n3982, n3983, n3984, n3985,
         n3986, n3987, n3988, n3989, n3990, n3991, n3992, n3993, n3994, n3995,
         n3996, n3997, n3998, n3999, n4000, n4001, n4002, n4003, n4004, n4005,
         n4006, n4007, n4008, n4009, n4010, n4011, n4012, n4013, n4014, n4015,
         n4016, n4017, n4018, n4025, n4026, n4027, n4028, n4029, n4031, n4032,
         n4033, n4034, n4035, n4036, n4037, n4038, n4039, n4040, n4041, n4042,
         n4043, n4044, n4045, n4046, n4047, n4048, n4049, n4050, n4052, n4053,
         n4054, n4055, n4056, n4057, n4058, n4059, n4060, n4061, n4062, n4063,
         n4064, n4065, n4066, n4067, n4068, n4069, n4070, n4071, n4072, n4073,
         n4074, n4075, n4076, n4077, n4078, n4079, n4080, n4081, n4082, n4083,
         n4084, n4085, n4086, n4087, n4088, n4089, n4090, n4091, n4092, n4093,
         n4094, n4095, n4096, n4097, n4098, n4099, n4100, n4101, n4102, n4103,
         n4104, n4105, n4106, n4107, n4108, n4109, n4110, n4111, n4112, n4113,
         n4114, n4115, n4116, n4117, n4118, n4119, n4120, n4121, n4122, n4126,
         n4127, n4128, n4129, n4130, n4131, n4132, n4133, n4134, n4135, n4136,
         n4137, n4138, n4139, n4140, n4141, n4142, n4143, n4144, n4145, n4146,
         n4147, n4148, n4149, n4150, n4151, n4152, n4153, n4154, n4155, n4156,
         n4157, n4158, n4159, n4160, n4161, n4162, n4163, n4164, n4165, n4166,
         n4167, n4168, n4170, n4172, n4173, n4174, n4175, n4176, n4177, n4178,
         n4179, n4180, n4181, n4182, n4183, n4184, n4185, n4186, n4187, n4188,
         n4189, n4190, n4191, n4192, n4193, n4194, n4195, n4196, n4197, n4198,
         n4199, n4200, n4201, n4202, n4203, n4204, n4205, n4206, n4207, n4208,
         n4209, n4210, n4211, n4212, n4213, n4214, n4215, n4216, n4217, n4218,
         n4219, n4220, n4221, n4222, n4223, n4224, n4225, n4226, n4227, n4228,
         n4229, n4230, n4231, n4232, n4233, n4234, n4235, n4236, n4237, n4238,
         n4239, n4240, n4241, n4242, n4243, n4244, n4245, n4246, n4247, n4248,
         n4249, n4250, n4251, n4252, n4253, n4254, n4255, n4256, n4257, n4258,
         n4259, n4260, n4261, n4262, n4263, n4264, n4265, n4266, n4267, n4268,
         n4269, n4270, n4271, n4272, n4273, n4274, n4275, n4276, n4277, n4278,
         n4279, n4280, n4281, n4282, n4283, n4284, n4285, n4286, n4287, n4288,
         n4289, n4290, n4291, n4292, n4293, n4294, n4295, n4296, n4297, n4298,
         n4299, n4300, n4301, n4302, n4303, n4304, n4305, n4306, n4307, n4308,
         n4309, n4310, n4311, n4312, n4313, n4314, n4315, n4316, n4317, n4318,
         n4319, n4320, n4321, n4322, n4323, n4324, n4325, n4326, n4327, n4328,
         n4329, n4330, n4331, n4332, n4333, n4334, n4335, n4336, n4337, n4338,
         n4339, n4340, n4341, n4342, n4343, n4344, n4345, n4346, n4347, n4348,
         n4349, n4350, n4351, n4352, n4353, n4354, n4355, n4356, n4357, n4358,
         n4359, n4360, n4361, n4362, n4363, n4364, n4365, n4366, n4367, n4368,
         n4369, n4370, n4371, n4372, n4373, n4374, n4375, n4376, n4377, n4378,
         n4379, n4380, n4381, n4382, n4383, n4384, n4385, n4386, n4387, n4388,
         n4389, n4390, n4391, n4392, n4393, n4394, n4395, n4396, n4397, n4398,
         n4399, n4400, n4401, n4402, n4403, n4404, n4405, n4406, n4407, n4408,
         n4409, n4410, n4411, n4412, n4413, n4414, n4415, n4416, n4417, n4418,
         n4419, n4420, n4421, n4422, n4423, n4424, n4425, n4426, n4427, n4428,
         n4429, n4430, n4431, n4432, n4433, n4434, n4435, n4436, n4437, n4438,
         n4439, n4440, n4441, n4442, n4443, n4444, n4445, n4446, n4447, n4448,
         n4449, n4450, n4451, n4452, n4453, n4454, n4455, n4456, n4457, n4458,
         n4459, n4460, n4461, n4462, n4463, n4464, n4465, n4466, n4467, n4468,
         n4469, n4470, n4471, n4472, n4473, n4474, n4475, n4476, n4477, n4478,
         n4479, n4480, n4481, n4482, n4483, n4484, n4485, n4486, n4487, n4488,
         n4489, n4490, n4491, n4492, n4493, n4494, n4495, n4496, n4497, n4498,
         n4499, n4500, n4501, n4502, n4503, n4504, n4505, n4506, n4507, n4508,
         n4509, n4510, n4511, n4512, n4513, n4514, n4515, n4516, n4517, n4518,
         n4519, n4520, n4521, n4522, n4523, n4524, n4525, n4526, n4527, n4528,
         n4529, n4530, n4531, n4532, n4533, n4534, n4535, n4536, n4537, n4538,
         n4539, n4540, n4541, n4542, n4543, n4544, n4545, n4546, n4547, n4548,
         n4549, n4550, n4551, n4552, n4553, n4554, n4555, n4556, n4557, n4558,
         n4559, n4560, n4561, n4562, n4563, n4564, n4565, n4566, n4567, n4568,
         n4569, n4570, n4571, n4572, n4573, n4574, n4575, n4576, n4577, n4578,
         n4579, n4580, n4581, n4582, n4583, n4584, n4585, n4586, n4587, n4588,
         n4589, n4590, n4591, n4592, n4593, n4594, n4595, n4596, n4597, n4598,
         n4599, n4600, n4601, n4602, n4603, n4604, n4605, n4606, n4607, n4608,
         n4609, n4610, n4611, n4612, n4613, n4614, n4615, n4616, n4617, n4618,
         n4619, n4620, n4621, n4622, n4623, n4624, n4625, n4626, n4627, n4628,
         n4629, n4630, n4631, n4632, n4633, n4634, n4635, n4636, n4637, n4638,
         n4639, n4640, n4641, n4642, n4643, n4644, n4645, n4646, n4647, n4648,
         n4649, n4650, n4651, n4652, n4653, n4654, n4655, n4656, n4657, n4658,
         n4659, n4660, n4661, n4662, n4663, n4664, n4665, n4666, n4667, n4668,
         n4669, n4670, n4671, n4672, n4673, n4674, n4675, n4676, n4677, n4678,
         n4679, n4680, n4681, n4682, n4683, n4684, n4685, n4686, n4687, n4688,
         n4689, n4690, n4691, n4692, n4693, n4694, n4695, n4696, n4697, n4698,
         n4699, n4700, n4701, n4702, n4703, n4704, n4705, n4706, n4707, n4708,
         n4709, n4710, n4711, n4712, n4713, n4714, n4715, n4716, n4717, n4718,
         n4719, n4720, n4721, n4722, n4723, n4724, n4725, n4726, n4727, n4728,
         n4729, n4730, n4731, n4732, n4733, n4734, n4735, n4736, n4737, n4738,
         n4739, n4740, n4741, n4742, n4743, n4744, n4745, n4746, n4747, n4748,
         n4749, n4750, n4751, n4752, n4753, n4754, n4755, n4756, n4757, n4758,
         n4759, n4760, n4761, n4762, n4763, n4764, n4765, n4766, n4767, n4768,
         n4769, n4770, n4771, n4772, n4773, n4774, n4775, n4776, n4777, n4778,
         n4779, n4780, n4781, n4782, n4783, n4784, n4785, n4786, n4787, n4788,
         n4789, n4790, n4791, n4792, n4793, n4794, n4795, n4796, n4797, n4798,
         n4799, n4800, n4801, n4802, n4803, n4804, n4805, n4806, n4807, n4808,
         n4809, n4810, n4811, n4812, n4813, n4814, n4815, n4816, n4817, n4818,
         n4819, n4820, n4821, n4822, n4823, n4824, n4825, n4826, n4827, n4828,
         n4829, n4830, n4831, n4832, n4833, n4834, n4835, n4836, n4837, n4838,
         n4839, n4840, n4841, n4842, n4843, n4844, n4845, n4846, n4847, n4848,
         n4849, n4850, n4851, n4852, n4853, n4854, n4855, n4856, n4857, n4858,
         n4859, n4860, n4861, n4862, n4863, n4864, n4865, n4866, n4867, n4868,
         n4869, n4870, n4871, n4872, n4873, n4874, n4875, n4876, n4877, n4878,
         n4879, n4880, n4881, n4882, n4883, n4884, n4885, n4886, n4887, n4888,
         n4889, n4890, n4891, n4892, n4893, n4894, n4895, n4896, n4897, n4898,
         n4899, n4900, n4901, n4902, n4903, n4904, n4905, n4906, n4907, n4908,
         n4909, n4910, n4911, n4912, n4913, n4914, n4915, n4916, n4917, n4918,
         n4919, n4920, n4921, n4922, n4923, n4924, n4925, n4926, n4927, n4928,
         n4929, n4930, n4931, n4932, n4933, n4934, n4935, n4936, n4937, n4938,
         n4939, n4940, n4941, n4942, n4943, n4944, n4945, n4946, n4947, n4948,
         n4949, n4950, n4951, n4952, n4953, n4954, n4955, n4956, n4957, n4958,
         n4959, n4960, n4961, n4962, n4963, n4964, n4965, n4966, n4967, n4968,
         n4969, n4970, n4971, n4972, n4973, n4974, n4975, n4976, n4977, n4978,
         n4979, n4980, n4981, n4982, n4983, n4984, n4985, n4986, n4987, n4988,
         n4989, n4990, n4991, n4992, n4993, n4994, n4995, n4996, n4997, n4998,
         n4999, n5000, n5001, n5002, n5003, n5004, n5005, n5006, n5007, n5008,
         n5009, n5010, n5011, n5012, n5013, n5014, n5015, n5016, n5017, n5018,
         n5019, n5020, n5021, n5022, n5023, n5024, n5025, n5026, n5027, n5028,
         n5029, n5030, n5031, n5032, n5033, n5034, n5035, n5036, n5037, n5038,
         n5039, n5040, n5041, n5042, n5043, n5044, n5045, n5046, n5047, n5048,
         n5049, n5050, n5051, n5052, n5053, n5054, n5055, n5056, n5057, n5058,
         n5059, n5060, n5061, n5062, n5063, n5064, n5065, n5066, n5067, n5068,
         n5069, n5070, n5071, n5072, n5073, n5074, n5075, n5076, n5077, n5078,
         n5079, n5080, n5081, n5082, n5083, n5084, n5085, n5086, n5087, n5088,
         n5089, n5090, n5091, n5092, n5093, n5094, n5095, n5096, n5097, n5098,
         n5099, n5100, n5101, n5102, n5103, n5104, n5105, n5106, n5107, n5108,
         n5109, n5110, n5111, n5112, n5113, n5114, n5115, n5116, n5117, n5118,
         n5119, n5120, n5121, n5122, n5123, n5124, n5125, n5126, n5127, n5128,
         n5129, n5130, n5131, n5132, n5133, n5134, n5135, n5136, n5137, n5138,
         n5139, n5140, n5141, n5142, n5143, n5144, n5145, n5146, n5147, n5148,
         n5149, n5150, n5151, n5152, n5153, n5154, n5155, n5156, n5157, n5158,
         n5159, n5160, n5161, n5162, n5163, n5164, n5165, n5166, n5167, n5168,
         n5169, n5170, n5171, n5172, n5173, n5174, n5175, n5176, n5177, n5178,
         n5179, n5180, n5181, n5182, n5183, n5184, n5185, n5186, n5187, n5188,
         n5189, n5190, n5191, n5192, n5193, n5194, n5195, n5196, n5197, n5198,
         n5199, n5200, n5201, n5202, n5203, n5204, n5205, n5206, n5207, n5208,
         n5209, n5210, n5211, n5212, n5213, n5214, n5215, n5216, n5217, n5218,
         n5219, n5220, n5221, n5222, n5223, n5224, n5225, n5226, n5227, n5228,
         n5229, n5230, n5231, n5232, n5233, n5234, n5235, n5236, n5237, n5238,
         n5239, n5240, n5241, n5242, n5243, n5244, n5245, n5246, n5247, n5248,
         n5249, n5250, n5251, n5252, n5253, n5254, n5255, n5256, n5257, n5258,
         n5259, n5260, n5261, n5262, n5263, n5264, n5265, n5266, n5267, n5268,
         n5269, n5270, n5271, n5272, n5273, n5274, n5275, n5276, n5277, n5278,
         n5279, n5280, n5281, n5282, n5283, n5284, n5285, n5286, n5287, n5288,
         n5289, n5290, n5291, n5292, n5293, n5294, n5295, n5296, n5297, n5298,
         n5299, n5300, n5301, n5302, n5303, n5304, n5305, n5306, n5307, n5308,
         n5309, n5310, n5311, n5312, n5313, n5314, n5315, n5316, n5317, n5318,
         n5319, n5320, n5321, n5322, n5323, n5324, n5325, n5326, n5327, n5328,
         n5329, n5330, n5331, n5332, n5333, n5334, n5335, n5336, n5337, n5338,
         n5339, n5340, n5341, n5342, n5343, n5344, n5345, n5346, n5347, n5348,
         n5349, n5350, n5351, n5352, n5353, n5354, n5355, n5356, n5357, n5358,
         n5359, n5360, n5361, n5362, n5363, n5364, n5365, n5366, n5367, n5368,
         n5369, n5370, n5371, n5372, n5373, n5374, n5375, n5376, n5377, n5378,
         n5379, n5380, n5381, n5382, n5383, n5384, n5385, n5386, n5387, n5388,
         n5389, n5390, n5391, n5392, n5393, n5394, n5395, n5396, n5397, n5398,
         n5399, n5400, n5401, n5402, n5403, n5404, n5405, n5406, n5407, n5408,
         n5409, n5410, n5411, n5412, n5413, n5414, n5415, n5416, n5417, n5418,
         n5419, n5420, n5421, n5422, n5423, n5424, n5425, n5426, n5427, n5428,
         n5429, n5430, n5431, n5432, n5433, n5434, n5435, n5436, n5437, n5438,
         n5439, n5440, n5441, n5442, n5443, n5444, n5445, n5446, n5447, n5448,
         n5449, n5450, n5451, n5452, n5453, n5454, n5455, n5456, n5457, n5458,
         n5459, n5460, n5461, n5462, n5463, n5464, n5465, n5466, n5467, n5468,
         n5469, n5470, n5471, n5472, n5473, n5474, n5475, n5476, n5477, n5478,
         n5479, n5480, n5481, n5482, n5483, n5484, n5485, n5486, n5487, n5488,
         n5489, n5490, n5491, n5492, n5493, n5494, n5495, n5496, n5497, n5498,
         n5499, n5500, n5501, n5502, n5503, n5504, n5505, n5506, n5507, n5508,
         n5509, n5510, n5511, n5512, n5513, n5514, n5515, n5516, n5517, n5518,
         n5519, n5520, n5521, n5522, n5523, n5524, n5525, n5526, n5527, n5528,
         n5529, n5530, n5531, n5532, n5533, n5534, n5535, n5536, n5537, n5538,
         n5539, n5540, n5541, n5542, n5543, n5544, n5545, n5546, n5547, n5548,
         n5549, n5550, n5551, n5552, n5553, n5554, n5555, n5556, n5557, n5558,
         n5559, n5560, n5561, n5562, n5563, n5564, n5565, n5566, n5567, n5568,
         n5569, n5570, n5571, n5572, n5573, n5574, n5575, n5576, n5577, n5578,
         n5579, n5580, n5581, n5582, n5583, n5584, n5585, n5586, n5587, n5588,
         n5589, n5590, n5591, n5592, n5593, n5594, n5595, n5596, n5597, n5598,
         n5599, n5600, n5601, n5602, n5603, n5604, n5605, n5606, n5607, n5608,
         n5609, n5610, n5611, n5612, n5613, n5614, n5615, n5616, n5617, n5618,
         n5619, n5620, n5621, n5622, n5623, n5624, n5625, n5626, n5627, n5628,
         n5629, n5630, n5631, n5632, n5633, n5634, n5635, n5636, n5637, n5638,
         n5639, n5640, n5641, n5642, n5643, n5644, n5645, n5646, n5647, n5648,
         n5649, n5650, n5651, n5652, n5653, n5654, n5655, n5656, n5657, n5658,
         n5659, n5660, n5661, n5662, n5663, n5664, n5665, n5666, n5667, n5668,
         n5669, n5670, n5671, n5672, n5673, n5674, n5675, n5676, n5677, n5678,
         n5679, n5680, n5681, n5682, n5683, n5684, n5685, n5686, n5687, n5688,
         n5689, n5690, n5691, n5692, n5693, n5694, n5695, n5696, n5697, n5698,
         n5699, n5700, n5701, n5702, n5703, n5704, n5705, n5706, n5707, n5708,
         n5709, n5710, n5711, n5712, n5713, n5714, n5715, n5716, n5717, n5718,
         n5719, n5720, n5721, n5722, n5723, n5724, n5725, n5726, n5727, n5728,
         n5729, n5730, n5731, n5732, n5733, n5734, n5735, n5736, n5737, n5738,
         n5739, n5740, n5741, n5742, n5743, n5744, n5745, n5746, n5747, n5748,
         n5749, n5750, n5751, n5752, n5753, n5754, n5755, n5756, n5757, n5758,
         n5759, n5760, n5761, n5762, n5763, n5764, n5765, n5766, n5767, n5768,
         n5769, n5770, n5771, n5772, n5773, n5774, n5775, n5776, n5777, n5778,
         n5779, n5780, n5781, n5782, n5783, n5784, n5785, n5786, n5787, n5788,
         n5789, n5790, n5791, n5792, n5793, n5794, n5795, n5796, n5797, n5798,
         n5799, n5800, n5801, n5802, n5803, n5804, n5805, n5806, n5807, n5808,
         n5809, n5810, n5811, n5812, n5813, n5814, n5815, n5816, n5817, n5818,
         n5819, n5820, n5821, n5822, n5823, n5824, n5825, n5826, n5827, n5828,
         n5829, n5830, n5831, n5832, n5833, n5834, n5835, n5836, n5837, n5838,
         n5839, n5840, n5841, n5842, n5843, n5844, n5845, n5846, n5847, n5848,
         n5849, n5850, n5851, n5852, n5853, n5854, n5855, n5856, n5857, n5858,
         n5859, n5860, n5861, n5862, n5863, n5864, n5865, n5866, n5867, n5868,
         n5869, n5870, n5871, n5872, n5873, n5874, n5875, n5876, n5877, n5878,
         n5879, n5880, n5881, n5882, n5883, n5884, n5885, n5886, n5887, n5888,
         n5889, n5890, n5891, n5892, n5893, n5894, n5895, n5896, n5897, n5898,
         n5899, n5900, n5901, n5902, n5903, n5904, n5905, n5906, n5907, n5908,
         n5909, n5910, n5911, n5912, n5913, n5914, n5915, n5916, n5917, n5918,
         n5919, n5920, n5921, n5922, n5923, n5924, n5925, n5926, n5927, n5928,
         n5929, n5930, n5931, n5932, n5933, n5934, n5935, n5936, n5937, n5938,
         n5939, n5940, n5941, n5942, n5943, n5944, n5945, n5946, n5947, n5948,
         n5949, n5950, n5951, n5952, n5953, n5954, n5955, n5956, n5957, n5958,
         n5959, n5960, n5961, n5962, n5963, n5964, n5965, n5966, n5967, n5968,
         n5969, n5970, n5971, n5972, n5973, n5974, n5975, n5976, n5977, n5978,
         n5979, n5980, n5981, n5982, n5983, n5984, n5985, n5986, n5987, n5988,
         n5989, n5990, n5991, n5992, n5993, n5994, n5995, n5996, n5997, n5998,
         n5999, n6000, n6001, n6002, n6003, n6004, n6005, n6006, n6007, n6008,
         n6009, n6010, n6011, n6012, n6013, n6014, n6015, n6016, n6017, n6018,
         n6019, n6020, n6021, n6022, n6023, n6024, n6025, n6026, n6027, n6028,
         n6029, n6030, n6031, n6032, n6033, n6034, n6035, n6036, n6037, n6038,
         n6039, n6040, n6041, n6042, n6043, n6044, n6045, n6046, n6047, n6048,
         n6049, n6050, n6051, n6052, n6053, n6054, n6055, n6056, n6057, n6058,
         n6059, n6060, n6061, n6062, n6063, n6064, n6065, n6066, n6067, n6068,
         n6069, n6070, n6071, n6072, n6073, n6074, n6075, n6076, n6077, n6078,
         n6079, n6080, n6081, n6082, n6083, n6084, n6085, n6086, n6087, n6088,
         n6089, n6090, n6091, n6092, n6093, n6094, n6095, n6096, n6097, n6098,
         n6099, n6100, n6101, n6102, n6103, n6104, n6105, n6106, n6107, n6108,
         n6109, n6110, n6111, n6112, n6113, n6114, n6115, n6116, n6117, n6118,
         n6119, n6120, n6121, n6122, n6123, n6124, n6125, n6126, n6127, n6128,
         n6129, n6130, n6131, n6132, n6133, n6134, n6135, n6136, n6137, n6138,
         n6139, n6140, n6141, n6142, n6143, n6144, n6145, n6146, n6147, n6148,
         n6149, n6150, n6151, n6152, n6153, n6154, n6155, n6156, n6157, n6158,
         n6159, n6160, n6161, n6162, n6163, n6164, n6165, n6166, n6167, n6168,
         n6169, n6170, n6171, n6172, n6173, n6174, n6175, n6176, n6177, n6178,
         n6179, n6180, n6181, n6182, n6183, n6184, n6185, n6186, n6187, n6188,
         n6189, n6190, n6191, n6192, n6193, n6194, n6195, n6196, n6197, n6198,
         n6199, n6200, n6201, n6202, n6203, n6204, n6205, n6206, n6207, n6208,
         n6209, n6210, n6211, n6212, n6213, n6214, n6215, n6216, n6217, n6218,
         n6219, n6220, n6221, n6222, n6223, n6224, n6225, n6226, n6227, n6228,
         n6229, n6230, n6231, n6232, n6233, n6234, n6235, n6236, n6237, n6238,
         n6239, n6240, n6241, n6242, n6243, n6244, n6245, n6246, n6247, n6248,
         n6249, n6250, n6251, n6252, n6253, n6254, n6255, n6256, n6257, n6258,
         n6259, n6260, n6261, n6262, n6263, n6264, n6265, n6266, n6267, n6268,
         n6269, n6270, n6271, n6272, n6273, n6274, n6275, n6276, n6277, n6278,
         n6279, n6280, n6281, n6282, n6283, n6284, n6285, n6286, n6287, n6288,
         n6289, n6290, n6291, n6292, n6293, n6294, n6295, n6296, n6297, n6298,
         n6299, n6300, n6301, n6302, n6303, n6304, n6305, n6306, n6307, n6308,
         n6309, n6310, n6311, n6312, n6313, n6314, n6315, n6316, n6317, n6318,
         n6319, n6320, n6321, n6322, n6323, n6324, n6325, n6326, n6327, n6328,
         n6329, n6330, n6331, n6332, n6333, n6334, n6335, n6336, n6337, n6338,
         n6339, n6340, n6341, n6342, n6343, n6344, n6345, n6346, n6347, n6348,
         n6349, n6350, n6351, n6352, n6353, n6354, n6355, n6356, n6357, n6358,
         n6359, n6360, n6361, n6362, n6363, n6364, n6365, n6366, n6367, n6368,
         n6369, n6370, n6371, n6372, n6373, n6374, n6375, n6376, n6377, n6378,
         n6379, n6380, n6381, n6382, n6383, n6384, n6385, n6386, n6387, n6388,
         n6389, n6390, n6391, n6392, n6393, n6394, n6395, n6396, n6397, n6398,
         n6399, n6400, n6401, n6402, n6403, n6404, n6405, n6406, n6407, n6408,
         n6409, n6410, n6411, n6412, n6413, n6414, n6415, n6416, n6417, n6418,
         n6419, n6420, n6421, n6422, n6423, n6424, n6425, n6426, n6427, n6428,
         n6429, n6430, n6431, n6432, n6433, n6434, n6435, n6436, n6437, n6438,
         n6439, n6440, n6441, n6442, n6443, n6444, n6445, n6446, n6447, n6448,
         n6449, n6450, n6451, n6452, n6453, n6454, n6455, n6456, n6457, n6458,
         n6459, n6460, n6461, n6462, n6463, n6464, n6465, n6466, n6467, n6468,
         n6469, n6470, n6471, n6472, n6473, n6474, n6475, n6476, n6477, n6478,
         n6479, n6480, n6481, n6482, n6483, n6484, n6485, n6486, n6487, n6488,
         n6489, n6490, n6491, n6492, n6493, n6494, n6495, n6496, n6497, n6498,
         n6499, n6500, n6501, n6502, n6503, n6504, n6505, n6506, n6507, n6508,
         n6509, n6510, n6511, n6512, n6513, n6514, n6515, n6516, n6517, n6518,
         n6519, n6520, n6521, n6522, n6523, n6524, n6525, n6526, n6527, n6528,
         n6529, n6530, n6531, n6532, n6533, n6534, n6535, n6536, n6537, n6538,
         n6539, n6540, n6541, n6542, n6543, n6544, n6545, n6546, n6547, n6548,
         n6549, n6550, n6551, n6552, n6553, n6554, n6555, n6556, n6557, n6558,
         n6559, n6560, n6561, n6562, n6563, n6564, n6565, n6566, n6567, n6568,
         n6569, n6570, n6571, n6572, n6573, n6574, n6575, n6576, n6577, n6578,
         n6579, n6580, n6581, n6582, n6583, n6584, n6585, n6586, n6587, n6588,
         n6589, n6590, n6591, n6592, n6593, n6594, n6595, n6596, n6597, n6598,
         n6599, n6600, n6601, n6602, n6603, n6604, n6605, n6606, n6607, n6608,
         n6609, n6610, n6611, n6612, n6613, n6614, n6615, n6616, n6617, n6618,
         n6619, n6620, n6621, n6622, n6623, n6624, n6625, n6626, n6627, n6628,
         n6629, n6630, n6631, n6632, n6633, n6634, n6635, n6636, n6637, n6638,
         n6639, n6640, n6641, n6642, n6643, n6644, n6645, n6646, n6647, n6648,
         n6649, n6650, n6651, n6652, n6653, n6654, n6655, n6656, n6657, n6658,
         n6659, n6660, n6661, n6662, n6663, n6664, n6665, n6666, n6667, n6668,
         n6669, n6670, n6671, n6672, n6673, n6674, n6675, n6676, n6677, n6678,
         n6679, n6680, n6681, n6682, n6683, n6684, n6685, n6686, n6687, n6688,
         n6689, n6690, n6691, n6692, n6693, n6694, n6695, n6696, n6697, n6698,
         n6699, n6700, n6701, n6702, n6703, n6704, n6705, n6706, n6707, n6708,
         n6709, n6710, n6711, n6712, n6713, n6714, n6715, n6716, n6717, n6718,
         n6719, n6720, n6721, n6722, n6723, n6724, n6725, n6726, n6727, n6728,
         n6729, n6730, n6731, n6732, n6733, n6734, n6735, n6736, n6737, n6738,
         n6739, n6740, n6741, n6742, n6743, n6744, n6745, n6746, n6747, n6748,
         n6749, n6750, n6751, n6752, n6753, n6754, n6755, n6756, n6757, n6758,
         n6759, n6760, n6761, n6762, n6763, n6764, n6765, n6766, n6767, n6768,
         n6769, n6770, n6771, n6772, n6773, n6774, n6775, n6776, n6777, n6778,
         n6779, n6780, n6781, n6782, n6783, n6784, n6785, n6786, n6787, n6788,
         n6789, n6790, n6791, n6792, n6793, n6794, n6795, n6796, n6797, n6798,
         n6799, n6800, n6801, n6802, n6803, n6804, n6805, n6806, n6807, n6808,
         n6809, n6810, n6811, n6812, n6813, n6814, n6815, n6816, n6817, n6818,
         n6819, n6820, n6821, n6822, n6823, n6824, n6825, n6826, n6827, n6828,
         n6829, n6830, n6831, n6832, n6833, n6834, n6835, n6836, n6837, n6838,
         n6839, n6840, n6841, n6842, n6843, n6844, n6845, n6846, n6847, n6848,
         n6849, n6850, n6851, n6852, n6853, n6854, n6855, n6856, n6857, n6858,
         n6859, n6860, n6861, n6862, n6863, n6864, n6865, n6866, n6867, n6868,
         n6869, n6870, n6871, n6872, n6873, n6874, n6875, n6876, n6877, n6878,
         n6879, n6880, n6881, n6882, n6883, n6884, n6885, n6886, n6887, n6888,
         n6889, n6890, n6891, n6892, n6893, n6894, n6895, n6896, n6897, n6898,
         n6899, n6900, n6901, n6902, n6903, n6904, n6905, n6906, n6907, n6908,
         n6909, n6910, n6911, n6912, n6913, n6914, n6915, n6916, n6917, n6918,
         n6919, n6920, n6921, n6922, n6923, n6924, n6925, n6926, n6927, n6928,
         n6929, n6930, n6931, n6932, n6933, n6934, n6935, n6936, n6937, n6938,
         n6939, n6940, n6941, n6942, n6943, n6944, n6945, n6946, n6947, n6948,
         n6949, n6950, n6951, n6952, n6953, n6954, n6955, n6956, n6957, n6958,
         n6959, n6960, n6961, n6962, n6963, n6964, n6965, n6966, n6967, n6968,
         n6969, n6970, n6971, n6972, n6973, n6974, n6975, n6976, n6977, n6978,
         n6979, n6980, n6981, n6982, n6983, n6984, n6985, n6986, n6987, n6988,
         n6989, n6990, n6991, n6992, n6993, n6994, n6995, n6996, n6997, n6998,
         n6999, n7000, n7001, n7002, n7003, n7004, n7005, n7006, n7007, n7008,
         n7009, n7010, n7011, n7012, n7013, n7014, n7015, n7016, n7017, n7018,
         n7019, n7020, n7021, n7022, n7023, n7024, n7025, n7026, n7027, n7028,
         n7029, n7030, n7031, n7032, n7033, n7034, n7035, n7036, n7037, n7038,
         n7039, n7040, n7041, n7042, n7043, n7044, n7045, n7046, n7047, n7048,
         n7049, n7050, n7051, n7052, n7053, n7054, n7055, n7056, n7057, n7058,
         n7059, n7060, n7061, n7062, n7063, n7064, n7065, n7066, n7067, n7068,
         n7069, n7070, n7071, n7072, n7073, n7074, n7075, n7076, n7077, n7078,
         n7079, n7080, n7081, n7082, n7083, n7084, n7085, n7086, n7087, n7088,
         n7089, n7090, n7091, n7092, n7093, n7094, n7095, n7096, n7097, n7098,
         n7099, n7100, n7101, n7102, n7103, n7104, n7105, n7106, n7107, n7108,
         n7109, n7110, n7111, n7112, n7113, n7114, n7115, n7116, n7117, n7118,
         n7119, n7120, n7121, n7122, n7123, n7124, n7125, n7126, n7127, n7128,
         n7129, n7130, n7131, n7132, n7133, n7134, n7135, n7136, n7137, n7138,
         n7139, n7140, n7141, n7142, n7143, n7144, n7145, n7146, n7147, n7148,
         n7149, n7150, n7151, n7152, n7153, n7154, n7155, n7156, n7157, n7158,
         n7159, n7160, n7161, n7162, n7163, n7164, n7165, n7166, n7167, n7168,
         n7169, n7170, n7171, n7172, n7173, n7174, n7175, n7176, n7177, n7178,
         n7179, n7180, n7181, n7182, n7183, n7184, n7185, n7186, n7187, n7188,
         n7189, n7190, n7191, n7192, n7193, n7194, n7195, n7196, n7197, n7198,
         n7199, n7200, n7201, n7202, n7203, n7204, n7205, n7206, n7207, n7208,
         n7209, n7210, n7211, n7212, n7213, n7214, n7215, n7216, n7217, n7218,
         n7219, n7220, n7221, n7222, n7223, n7224, n7225, n7226, n7227, n7228,
         n7229, n7230, n7231, n7232, n7233, n7234, n7235, n7236, n7237, n7238,
         n7239, n7240, n7241, n7242, n7243, n7244, n7245, n7246, n7247, n7248,
         n7249, n7250, n7251, n7252, n7253, n7254, n7255, n7256, n7257, n7258,
         n7259, n7260, n7261, n7262, n7263, n7264, n7265, n7266, n7267, n7268,
         n7269, n7270, n7271, n7272, n7273, n7274, n7275, n7276, n7277, n7278,
         n7279, n7280, n7281, n7282, n7283, n7284, n7285, n7286, n7287, n7288,
         n7289, n7290, n7291, n7292, n7293, n7294, n7295, n7296, n7297, n7298,
         n7299, n7300, n7301, n7302, n7303, n7304, n7305, n7306, n7307, n7308,
         n7309, n7310, n7311, n7312, n7313, n7314, n7315, n7316, n7317, n7318,
         n7319, n7320, n7321, n7322, n7323, n7324, n7325, n7326, n7327, n7328,
         n7329, n7330, n7331, n7332, n7333, n7334, n7335, n7336, n7337, n7338,
         n7339, n7340, n7341, n7342, n7343, n7344, n7345, n7346, n7347, n7348,
         n7349, n7350, n7351, n7352, n7353, n7354, n7355, n7356, n7357, n7358,
         n7359, n7360, n7361, n7362, n7363, n7364, n7365, n7366, n7367, n7368,
         n7369, n7370, n7371, n7372, n7373, n7374, n7375, n7376, n7377, n7378,
         n7379, n7380, n7381, n7382, n7383, n7384, n7385, n7386, n7387, n7388,
         n7389, n7390, n7391, n7392, n7393, n7394, n7395, n7396, n7397, n7398,
         n7399, n7400, n7401, n7402, n7403, n7404, n7405, n7406, n7407, n7408,
         n7409, n7410, n7411, n7412, n7413, n7414, n7415, n7416, n7417, n7418,
         n7419, n7420, n7421, n7422, n7423, n7424, n7425, n7426, n7427, n7428,
         n7429, n7430, n7431, n7432, n7433, n7434, n7435, n7436, n7437, n7438,
         n7439, n7440, n7441, n7442, n7443, n7444, n7445, n7446, n7447, n7448,
         n7449, n7450, n7451, n7452, n7453, n7454, n7455, n7456, n7457, n7458,
         n7459, n7460, n7461, n7462, n7463, n7464, n7465, n7466, n7467, n7468,
         n7469, n7470, n7471, n7472, n7473, n7474, n7475, n7476, n7477, n7478,
         n7479, n7480, n7481, n7482, n7483, n7484, n7485, n7486, n7487, n7488,
         n7489, n7490, n7491, n7492, n7493, n7494, n7495, n7496, n7497, n7498,
         n7499, n7500, n7501, n7502, n7503, n7504, n7505, n7506, n7507, n7508,
         n7509, n7510, n7511, n7512, n7513, n7514, n7515, n7516, n7517, n7518,
         n7519, n7520, n7521, n7522, n7523, n7524, n7525, n7526, n7527, n7528,
         n7529, n7530, n7531, n7532, n7533, n7534, n7535, n7536, n7537, n7538,
         n7539, n7540, n7541, n7542, n7543, n7544, n7545, n7546, n7547, n7548,
         n7549, n7550, n7551, n7552, n7553, n7554, n7555, n7556, n7557, n7558,
         n7559, n7560, n7561, n7562, n7563, n7564, n7565, n7566, n7567, n7568,
         n7569, n7570, n7571, n7572, n7573, n7574, n7575, n7576, n7577, n7578,
         n7579, n7580, n7581, n7582, n7583, n7584, n7585, n7586, n7587, n7588,
         n7589, n7590, n7591, n7592, n7593, n7594, n7595, n7596, n7597, n7598,
         n7599, n7600, n7601, n7602, n7603, n7604, n7605, n7606, n7607, n7608,
         n7609, n7610, n7611, n7612, n7613, n7614, n7615, n7616, n7617, n7618,
         n7619, n7620, n7621, n7622, n7623, n7624, n7625, n7626, n7627, n7628,
         n7629, n7630, n7631, n7632, n7633, n7634, n7635, n7636, n7637, n7638,
         n7639, n7640, n7641, n7642, n7643, n7644, n7645, n7646, n7647, n7648,
         n7649, n7650, n7651, n7652, n7653, n7654, n7655, n7656, n7657, n7658,
         n7659, n7660, n7661, n7662, n7663, n7664, n7665, n7666, n7667, n7668,
         n7669, n7670, n7671, n7672, n7673, n7674, n7675, n7676, n7677, n7678,
         n7679, n7680, n7681, n7682, n7683, n7684, n7685, n7686, n7687, n7688,
         n7689, n7690, n7691, n7692, n7693, n7694, n7695, n7696, n7697, n7698,
         n7699, n7700, n7701, n7702, n7703, n7704, n7705, n7706, n7707, n7708,
         n7709, n7710, n7711, n7712, n7713, n7714, n7715, n7716, n7717, n7718,
         n7719, n7720, n7721, n7722, n7723, n7724, n7725, n7726, n7727, n7728,
         n7729, n7730, n7731, n7732, n7733, n7734, n7735, n7736, n7737, n7738,
         n7739, n7740, n7741, n7742, n7743, n7744, n7745, n7746, n7747, n7748,
         n7749, n7750, n7751, n7752, n7753, n7754, n7755, n7756, n7757, n7758,
         n7759, n7760, n7761, n7762, n7763, n7764, n7765, n7766, n7767, n7768,
         n7769, n7770, n7771, n7772, n7773, n7774, n7775, n7776, n7777, n7778,
         n7779, n7780, n7781, n7782, n7783, n7784, n7785, n7786, n7787, n7788,
         n7789, n7790, n7791, n7792, n7793, n7794, n7795, n7796, n7797, n7798,
         n7799, n7800, n7801, n7802, n7803, n7804, n7805, n7806, n7807, n7808,
         n7809, n7810, n7811, n7812, n7813, n7814, n7815, n7816, n7817, n7818,
         n7819, n7820, n7821, n7822, n7823, n7824, n7825, n7826, n7827, n7828,
         n7829, n7830, n7831, n7832, n7833, n7834, n7835, n7836, n7837, n7838,
         n7839, n7840, n7841, n7842, n7843, n7844, n7845, n7846, n7847, n7848,
         n7849, n7850, n7851, n7852, n7853, n7854, n7855, n7856, n7857, n7858,
         n7859, n7860, n7861, n7862, n7863, n7864, n7865, n7866, n7867, n7868,
         n7869, n7870, n7871, n7872, n7873, n7874, n7875, n7876, n7877, n7878,
         n7879, n7880, n7881, n7882, n7883, n7884, n7885, n7886, n7887, n7888,
         n7889, n7890, n7891, n7892, n7893, n7894, n7895, n7896, n7897, n7898,
         n7899, n7900, n7901, n7902, n7903, n7904, n7905, n7906, n7907, n7908,
         n7909, n7910, n7911, n7912, n7913, n7914, n7915, n7916, n7917, n7918,
         n7919, n7920, n7921, n7922, n7923, n7924, n7925, n7926, n7927, n7928,
         n7929, n7930, n7931, n7932, n7933, n7934, n7935, n7936, n7937, n7938,
         n7939, n7940, n7941, n7942, n7943, n7944, n7945, n7946, n7947, n7948,
         n7949, n7950, n7951, n7952, n7953, n7954, n7955, n7956, n7957, n7958,
         n7959, n7960, n7961, n7962, n7963, n7964, n7965, n7966, n7967, n7968,
         n7969, n7970, n7971, n7972, n7973, n7974, n7975, n7976, n7977, n7978,
         n7979, n7980, n7981, n7982, n7983, n7984, n7985, n7986, n7987, n7988,
         n7989, n7990, n7991, n7992, n7993, n7994, n7995, n7996, n7997, n7998,
         n7999, n8000, n8001, n8002, n8003, n8004, n8005, n8006, n8007, n8008,
         n8009, n8010, n8011, n8012, n8013, n8014, n8015, n8016, n8017, n8018,
         n8019, n8020, n8021, n8022, n8023, n8024, n8025, n8026, n8027, n8028,
         n8029, n8030, n8031, n8032, n8033, n8034, n8035, n8036, n8037, n8038,
         n8039, n8040, n8041, n8042, n8043, n8044, n8045, n8046, n8047, n8048,
         n8049, n8050, n8051, n8052, n8053, n8054, n8055, n8056, n8057, n8058,
         n8059, n8060, n8061, n8062, n8063, n8064, n8065, n8066, n8067, n8068,
         n8069, n8070, n8071, n8072, n8073, n8074, n8075, n8076, n8077, n8078,
         n8079, n8080, n8081, n8082, n8083, n8084, n8085, n8086, n8087, n8088,
         n8089, n8090, n8091, n8092, n8093, n8094, n8095, n8096, n8097, n8098,
         n8099, n8100, n8101, n8102, n8103, n8104, n8105, n8106, n8107, n8108,
         n8109, n8110, n8111, n8112, n8113, n8114, n8115, n8116, n8117, n8118,
         n8119, n8120, n8121, n8122, n8123, n8124, n8125, n8126, n8127, n8128,
         n8129, n8130, n8131, n8132, n8133, n8134, n8135, n8136, n8137, n8138,
         n8139, n8140, n8141, n8142, n8143, n8144, n8145, n8146, n8147, n8148,
         n8149, n8150, n8151, n8152, n8153, n8154, n8155, n8156, n8157, n8158,
         n8159, n8160, n8161, n8162, n8163, n8164, n8165, n8166, n8167, n8168,
         n8169, n8170, n8171, n8172, n8173, n8174, n8175, n8176, n8177, n8178,
         n8179, n8180, n8181, n8182, n8183, n8184, n8185, n8186, n8187, n8188,
         n8189, n8190, n8191, n8192, n8193, n8194, n8195, n8196, n8197, n8198,
         n8199, n8200, n8201, n8202, n8203, n8204, n8205, n8206, n8207, n8208,
         n8209, n8210, n8211, n8212, n8213, n8214, n8215, n8216, n8217, n8218,
         n8219, n8220, n8221, n8222, n8223, n8224, n8225, n8226, n8227, n8228,
         n8229, n8230, n8231, n8232, n8233, n8234, n8235, n8236, n8237, n8238,
         n8239, n8240, n8241, n8242, n8243, n8244, n8245, n8246, n8247, n8248,
         n8249, n8250, n8251, n8252, n8253, n8254, n8255, n8256, n8257, n8258,
         n8259, n8260, n8261, n8262, n8263, n8264, n8265, n8266, n8267, n8268,
         n8269, n8270, n8271, n8272, n8273, n8274, n8275, n8276, n8277, n8278,
         n8279, n8280, n8281, n8282, n8283, n8284, n8285, n8286, n8287, n8288,
         n8289, n8290, n8291, n8292, n8293, n8294, n8295, n8296, n8297, n8298,
         n8299, n8300, n8301, n8302, n8303, n8304, n8305, n8306, n8307, n8308,
         n8309, n8310, n8311, n8312, n8313, n8314, n8315, n8316, n8317, n8318,
         n8319, n8320, n8321, n8322, n8323, n8324, n8325, n8326, n8327, n8328,
         n8329, n8330, n8331, n8332, n8333, n8334, n8335, n8336, n8337, n8338,
         n8339, n8340, n8341, n8342, n8343, n8344, n8345, n8346, n8347, n8348,
         n8349, n8350, n8351, n8352, n8353, n8354, n8355, n8356, n8357, n8358,
         n8359, n8360, n8361, n8362, n8363, n8364, n8365, n8366, n8367, n8368,
         n8369, n8370, n8371, n8372, n8373, n8374, n8375, n8376, n8377, n8378,
         n8379, n8380, n8381, n8382, n8383, n8384, n8385, n8386, n8387, n8388,
         n8389, n8390, n8391, n8392, n8393, n8394, n8395, n8396, n8397, n8398,
         n8399, n8400, n8401, n8402, n8403, n8404, n8405, n8406, n8407, n8408,
         n8409, n8410, n8411, n8412, n8413, n8414, n8415, n8416, n8417, n8418,
         n8419, n8420, n8421, n8422, n8423, n8424, n8425, n8426, n8427, n8428,
         n8429, n8430, n8431, n8432, n8433, n8434, n8435, n8436, n8437, n8438,
         n8439, n8440, n8441, n8442, n8443, n8444, n8445, n8446, n8447, n8448,
         n8449, n8450, n8451, n8452, n8453, n8454, n8455, n8456, n8457, n8458,
         n8459, n8460, n8461, n8462, n8463, n8464, n8465, n8466, n8467, n8468,
         n8469, n8470, n8471, n8472, n8473, n8474, n8475, n8476, n8477, n8478,
         n8479, n8480, n8481, n8482, n8483, n8484, n8485, n8486, n8487, n8488,
         n8489, n8490, n8491, n8492, n8493, n8494, n8495, n8496, n8497, n8498,
         n8499, n8500, n8501, n8502, n8503, n8504, n8505, n8506, n8507, n8508,
         n8509, n8510, n8511, n8512, n8513, n8514, n8515, n8516, n8517, n8518,
         n8519, n8520, n8521, n8522, n8523, n8524, n8525, n8526, n8527, n8528,
         n8529, n8530, n8531, n8532, n8533, n8534, n8535, n8536, n8537, n8538,
         n8539, n8540, n8541, n8542, n8543, n8544, n8545, n8546, n8547, n8548,
         n8549, n8550, n8551, n8552, n8553, n8554, n8555, n8556, n8557, n8558,
         n8559, n8560, n8561, n8562, n8563, n8564, n8565, n8566, n8567, n8568,
         n8569, n8570, n8571, n8572, n8573, n8574, n8575, n8576, n8577, n8578,
         n8579, n8580, n8581, n8582, n8583, n8584, n8585, n8586, n8587, n8588,
         n8589, n8590, n8591, n8592, n8593, n8594, n8595, n8596, n8597, n8598,
         n8599, n8600, n8601, n8602, n8603, n8604, n8605, n8606, n8607, n8608,
         n8609, n8610, n8611, n8612, n8613, n8614, n8615, n8616, n8617, n8618,
         n8619, n8620, n8621, n8622, n8623, n8624, n8625, n8626, n8627, n8628,
         n8629, n8630, n8631, n8632, n8633, n8634, n8635, n8636, n8637, n8638,
         n8639, n8640, n8641, n8642, n8643, n8644, n8645, n8646, n8647, n8648,
         n8649, n8650, n8651, n8652, n8653, n8654, n8655, n8656, n8657, n8658,
         n8659, n8660, n8661, n8662, n8663, n8664, n8665, n8666, n8667, n8668,
         n8669, n8670, n8671, n8672, n8673, n8674, n8675, n8676, n8677, n8678,
         n8679, n8680, n8681, n8682, n8683, n8684, n8685, n8686, n8687, n8688,
         n8689, n8690, n8691, n8692, n8693, n8694, n8695, n8696, n8697, n8698,
         n8699, n8700, n8701, n8702, n8703, n8704, n8705, n8706, n8707, n8708,
         n8709, n8710, n8711, n8712, n8713, n8714, n8715, n8716, n8717, n8718,
         n8719, n8720, n8721, n8722, n8723, n8724, n8725, n8726, n8727, n8728,
         n8729, n8730, n8731, n8732, n8733, n8734, n8735, n8736, n8737, n8738,
         n8739, n8740, n8741, n8742, n8743, n8744, n8745, n8746, n8747, n8748,
         n8749, n8750, n8751, n8752, n8753, n8754, n8755, n8756, n8757, n8758,
         n8759, n8760, n8761, n8762, n8763, n8764, n8765, n8766, n8767, n8768,
         n8769, n8770, n8771, n8772, n8773, n8774, n8775, n8776, n8777, n8778,
         n8779, n8780, n8781, n8782, n8783, n8784, n8785, n8786, n8787, n8788,
         n8789, n8790, n8791, n8792, n8793, n8794, n8795, n8796, n8797, n8798,
         n8799, n8800, n8801, n8802, n8803, n8804, n8805, n8806, n8807, n8808,
         n8809, n8810, n8811, n8812, n8813, n8814, n8815, n8816, n8817, n8818,
         n8819, n8820, n8821, n8822, n8823, n8824, n8825, n8826, n8827, n8828,
         n8829, n8830, n8831, n8832, n8833, n8834, n8835, n8836, n8837, n8838,
         n8839, n8840, n8841, n8842, n8843, n8844, n8845, n8846, n8847, n8848,
         n8849, n8850, n8851, n8852, n8853, n8854, n8855, n8856, n8857, n8858,
         n8859, n8860, n8861, n8862, n8863, n8864, n8865, n8866, n8867, n8868,
         n8869, n8870, n8871, n8872, n8873, n8874, n8875, n8876, n8877, n8878,
         n8879, n8880, n8881, n8882, n8883, n8884, n8885, n8886, n8887, n8888,
         n8889, n8890, n8891, n8892, n8893, n8894, n8895, n8896, n8897, n8898,
         n8899, n8900, n8901, n8902, n8903, n8904, n8905, n8906, n8907, n8908,
         n8909, n8910, n8911, n8912, n8913, n8914, n8915, n8916, n8917, n8918,
         n8919, n8920, n8921, n8922, n8923, n8924, n8925, n8926, n8927, n8928,
         n8929, n8930, n8931, n8932, n8933, n8934, n8935, n8936, n8937, n8938,
         n8939, n8940, n8941, n8942, n8943, n8944, n8945, n8946, n8947, n8948,
         n8949, n8950, n8951, n8952, n8953, n8954, n8955, n8956, n8957, n8958,
         n8959, n8960, n8961, n8962, n8963, n8964, n8965, n8966, n8967, n8968,
         n8969, n8970, n8971, n8972, n8973, n8974, n8975, n8976, n8977, n8978,
         n8979, n8980, n8981, n8982, n8983, n8984, n8985, n8986, n8987, n8988,
         n8989, n8990, n8991, n8992, n8993, n8994, n8995, n8996, n8997, n8998,
         n8999, n9000, n9001, n9002, n9003, n9004, n9005, n9006, n9007, n9008,
         n9009, n9010, n9011, n9012, n9013, n9014, n9015, n9016, n9017, n9018,
         n9019, n9020, n9021, n9022, n9023, n9024, n9025, n9026, n9027, n9028,
         n9029, n9030, n9031, n9032, n9033, n9034, n9035, n9036, n9037, n9038,
         n9039, n9040, n9041, n9042, n9043, n9044, n9045, n9046, n9047, n9048,
         n9049, n9050, n9051, n9052, n9053, n9054, n9055, n9056, n9057, n9058,
         n9059, n9060, n9061, n9062, n9063, n9064, n9065, n9066, n9067, n9068,
         n9069, n9070, n9071, n9072, n9073, n9074, n9075, n9076, n9077, n9078,
         n9079, n9080, n9081, n9082, n9083, n9084, n9085, n9086, n9087, n9088,
         n9089, n9090, n9091, n9092, n9093, n9094, n9095, n9096, n9097, n9098,
         n9099, n9100, n9101, n9102, n9103, n9104, n9105, n9106, n9107, n9108,
         n9109, n9110, n9111, n9112, n9113, n9114, n9115, n9116, n9117, n9118,
         n9119, n9120, n9121, n9122, n9123, n9124, n9125, n9126, n9127, n9128,
         n9129, n9130, n9131, n9132, n9133, n9134, n9135, n9136, n9137, n9138,
         n9139, n9140, n9141, n9142, n9143, n9144, n9145, n9146, n9147, n9148,
         n9149, n9150, n9151, n9152, n9153, n9154, n9155, n9156, n9157, n9158,
         n9159, n9160, n9161, n9162, n9163, n9164, n9165, n9166, n9167, n9168,
         n9169, n9170, n9171, n9172, n9173, n9174, n9175, n9176, n9177, n9178,
         n9179, n9180, n9181, n9182, n9183, n9184, n9185, n9186, n9187, n9188,
         n9189, n9190, n9191, n9192, n9193, n9194, n9195, n9196, n9197, n9198,
         n9199, n9200, n9201, n9202, n9203, n9204, n9205, n9206, n9207, n9208,
         n9209, n9210, n9211, n9212, n9213, n9214, n9215, n9216, n9217, n9218,
         n9219, n9220, n9221, n9222, n9223, n9224, n9225, n9226, n9227, n9228,
         n9229, n9230, n9231, n9232, n9233, n9234, n9235, n9236, n9237, n9238,
         n9239, n9240, n9241, n9242, n9243, n9244, n9245, n9246, n9247, n9248,
         n9249, n9250, n9251, n9252, n9253, n9254, n9255, n9256, n9257, n9258,
         n9259, n9260, n9261, n9262, n9263, n9264, n9265, n9266, n9267, n9268,
         n9269, n9270, n9271, n9272, n9273, n9274, n9275, n9276, n9277, n9278,
         n9279, n9280, n9281, n9282, n9283, n9284, n9285, n9286, n9287, n9288,
         n9289, n9290, n9291, n9292, n9293, n9294, n9295, n9296, n9297, n9298,
         n9299, n9300, n9301, n9302, n9303, n9304, n9305, n9306, n9307, n9308,
         n9309, n9310, n9311, n9312, n9313, n9314, n9315, n9316, n9317, n9318,
         n9319, n9320, n9321, n9322, n9323, n9324, n9325, n9326, n9327, n9328,
         n9329, n9330, n9331, n9332, n9333, n9334, n9335, n9336, n9337, n9338,
         n9339, n9340, n9341, n9342, n9343, n9344, n9345, n9346, n9347, n9348,
         n9349, n9350, n9351, n9352, n9353, n9354, n9355, n9356, n9357, n9358,
         n9359, n9360, n9361, n9362, n9363, n9364, n9365, n9366, n9367, n9368,
         n9369, n9370, n9371, n9372, n9373, n9374, n9375, n9376, n9377, n9378,
         n9379, n9380, n9381, n9382, n9383, n9384, n9385, n9386, n9387, n9388,
         n9389, n9390, n9391, n9392, n9393, n9394, n9395, n9396, n9397, n9398,
         n9399, n9400, n9401, n9402, n9403, n9404, n9405, n9406, n9407, n9408,
         n9409, n9410, n9411, n9412, n9413, n9414, n9415, n9416, n9417, n9418,
         n9419, n9420, n9421, n9422, n9423, n9424, n9425, n9426, n9427, n9428,
         n9429, n9430, n9431, n9432, n9433, n9434, n9435, n9436, n9437, n9438,
         n9439, n9440, n9441, n9442, n9443, n9444, n9445, n9446, n9447, n9448,
         n9449, n9450, n9451, n9452, n9453, n9454, n9455, n9456, n9457, n9458,
         n9459, n9460, n9461, n9462, n9463, n9464, n9465, n9466, n9467, n9468,
         n9469, n9470, n9471, n9472, n9473, n9474, n9475, n9476, n9477, n9478,
         n9479, n9480, n9481, n9482, n9483, n9484, n9485, n9486, n9487, n9488,
         n9489, n9490, n9491, n9492, n9493, n9494, n9495, n9496, n9497, n9498,
         n9499, n9500, n9501, n9502, n9503, n9504, n9505, n9506, n9507, n9508,
         n9509, n9510, n9511, n9512, n9513, n9514, n9515, n9516, n9517, n9518,
         n9519, n9520, n9521, n9522, n9523, n9524, n9525, n9526, n9527, n9528,
         n9529, n9530, n9531, n9532, n9533, n9534, n9535, n9536, n9537, n9538,
         n9539, n9540, n9541, n9542, n9543, n9544, n9545, n9546, n9547, n9548,
         n9549, n9550, n9551, n9552, n9553, n9554, n9555, n9556, n9557, n9558,
         n9559, n9560, n9561, n9562, n9563, n9564, n9565, n9566, n9567, n9568,
         n9569, n9570, n9571, n9572, n9573, n9574, n9575, n9576, n9577, n9578,
         n9579, n9580, n9581, n9582, n9583, n9584, n9585, n9586, n9587, n9588,
         n9589, n9590, n9591, n9592, n9593, n9594, n9595, n9596, n9597, n9598,
         n9599, n9600, n9601, n9602, n9603, n9604, n9605, n9606, n9607, n9608,
         n9609, n9610, n9611, n9612, n9613, n9614, n9615, n9616, n9617, n9618,
         n9619, n9620, n9621, n9622, n9623, n9624, n9625, n9626, n9627, n9628,
         n9629, n9630, n9631, n9632, n9633, n9634, n9635, n9636, n9637, n9638,
         n9639, n9640, n9641, n9642, n9643, n9644, n9645, n9646, n9647, n9648,
         n9649, n9650, n9651, n9652, n9653, n9654, n9655, n9656, n9657, n9658,
         n9659, n9660, n9661, n9662, n9663, n9664, n9665, n9666, n9667, n9668,
         n9669, n9670, n9671, n9672, n9673, n9674, n9675, n9676, n9677, n9678,
         n9679, n9680, n9681, n9682, n9683, n9684, n9685, n9686, n9687, n9688,
         n9689, n9690, n9691, n9692, n9693, n9694, n9695, n9696, n9697, n9698,
         n9699, n9700, n9701, n9702, n9703, n9704, n9705, n9706, n9707, n9708,
         n9709, n9710, n9711, n9712, n9713, n9714, n9715, n9716, n9717, n9718,
         n9719, n9720, n9721, n9722, n9723, n9724, n9725, n9726, n9727, n9728,
         n9729, n9730, n9731, n9732, n9733, n9734, n9735, n9736, n9737, n9738,
         n9739, n9740, n9741, n9742, n9743, n9744, n9745, n9746, n9747, n9748,
         n9749, n9750, n9751, n9752, n9753, n9754, n9755, n9756, n9757, n9758,
         n9759, n9760, n9761, n9762, n9763, n9764, n9765, n9766, n9767, n9768,
         n9769, n9770, n9771, n9772, n9773, n9774, n9775, n9776, n9777, n9778,
         n9779, n9780, n9781, n9782, n9783, n9784, n9785, n9786, n9787, n9788,
         n9789, n9790, n9791, n9792, n9793, n9794, n9795, n9796, n9797, n9798,
         n9799, n9800, n9801, n9802, n9803, n9804, n9805, n9806, n9807, n9808,
         n9809, n9810, n9811, n9812, n9813, n9814, n9815, n9816, n9817, n9818,
         n9819, n9820, n9821, n9822, n9823, n9824, n9825, n9826, n9827, n9828,
         n9829, n9830, n9831, n9832, n9833, n9834, n9835, n9836, n9837, n9838,
         n9839, n9840, n9841, n9842, n9843, n9844, n9845, n9846, n9847, n9848,
         n9849, n9850, n9851, n9852, n9853, n9854, n9855, n9856, n9857, n9858,
         n9859, n9860, n9861, n9862, n9863, n9864, n9865, n9866, n9867, n9868,
         n9869, n9870, n9871, n9872, n9873, n9874, n9875, n9876, n9877, n9878,
         n9879, n9880, n9881, n9882, n9883, n9884, n9885, n9886, n9887, n9888,
         n9889, n9890, n9891, n9892, n9893, n9894, n9895, n9896, n9897, n9898,
         n9899, n9900, n9901, n9902, n9903, n9904, n9905, n9906, n9907, n9908,
         n9909, n9910, n9911, n9912, n9913, n9914, n9915, n9916, n9917, n9918,
         n9919, n9920, n9921, n9922, n9923, n9924, n9925, n9926, n9927, n9928,
         n9929, n9930, n9931, n9932, n9933, n9934, n9935, n9936, n9937, n9938,
         n9939, n9940, n9941, n9942, n9943, n9944, n9945, n9946, n9947, n9948,
         n9949, n9950, n9951, n9952, n9953, n9954, n9955, n9956, n9957, n9958,
         n9959, n9960, n9961, n9962, n9963, n9964, n9965, n9966, n9967, n9968,
         n9969, n9970, n9971, n9972, n9973, n9974, n9975, n9976, n9977, n9978,
         n9979, n9980, n9981, n9982, n9983, n9984, n9985, n9986, n9987, n9988,
         n9989, n9990, n9991, n9992, n9993, n9994, n9995, n9996, n9997, n9998,
         n9999, n10000, n10001, n10002, n10003, n10004, n10005, n10006, n10007,
         n10008, n10009, n10010, n10011, n10012, n10013, n10014, n10015,
         n10016, n10017, n10018, n10019, n10020, n10021, n10022, n10023,
         n10024, n10025, n10026, n10027, n10028, n10029, n10030, n10031,
         n10032, n10033, n10034, n10035, n10036, n10037, n10038, n10039,
         n10040, n10041, n10042, n10043, n10044, n10045, n10046, n10047,
         n10048, n10049, n10050, n10051, n10052, n10053, n10054, n10055,
         n10056, n10057, n10058, n10059, n10060, n10061, n10062, n10063,
         n10064, n10065, n10066, n10067, n10068, n10069, n10070, n10071,
         n10072, n10073, n10074, n10075, n10076, n10077, n10078, n10079,
         n10080, n10081, n10082, n10083, n10084, n10085, n10086, n10087,
         n10088, n10089, n10090, n10091, n10092, n10093, n10094, n10095,
         n10096, n10097, n10098, n10099, n10100, n10101, n10102, n10103,
         n10104, n10105, n10106, n10107, n10108, n10109, n10110, n10111,
         n10112, n10113, n10114, n10115, n10116, n10117, n10118, n10119,
         n10120, n10121, n10122, n10123, n10124, n10125, n10126, n10127,
         n10128, n10129, n10130, n10131, n10132, n10133, n10134, n10135,
         n10136, n10137, n10138, n10139, n10140, n10141, n10142, n10143,
         n10144, n10145, n10146, n10147, n10148, n10149, n10150, n10151,
         n10152, n10153, n10154, n10155, n10156, n10157, n10158, n10159,
         n10160, n10161, n10162, n10163, n10164, n10165, n10166, n10167,
         n10168, n10169, n10170, n10171, n10172, n10173, n10174, n10175,
         n10176, n10177, n10178, n10179, n10180, n10181, n10182, n10183,
         n10184, n10185, n10186, n10187, n10188, n10189, n10190, n10191,
         n10192, n10193, n10194, n10195, n10196, n10197, n10198, n10199,
         n10200, n10201, n10202, n10203, n10204, n10205, n10206, n10207;
  wire   [1:0] mem_state;
  wire   [31:0] mem_rdata_q;
  wire   [1:0] mem_wordsize;
  wire   [31:0] mem_rdata_word;
  wire   [31:0] decoded_imm;
  wire   [4:0] decoded_rd;
  wire   [31:0] decoded_imm_j;
  wire   [7:0] cpu_state;
  wire   [31:0] reg_out;
  wire   [31:0] reg_next_pc;
  wire   [31:0] alu_out;
  wire   [31:0] reg_pc;
  wire   [31:0] alu_out_q;
  wire   [4:0] latched_rd;
  wire   [63:0] count_cycle;
  wire   [63:0] count_instr;
  wire   [4:0] reg_sh;
  assign mem_la_addr[1] = latched_compr;
  assign mem_la_addr[0] = latched_compr;
  assign pcpi_valid = latched_compr;
  assign eoi[31] = latched_compr;
  assign eoi[30] = latched_compr;
  assign eoi[29] = latched_compr;
  assign eoi[28] = latched_compr;
  assign eoi[27] = latched_compr;
  assign eoi[26] = latched_compr;
  assign eoi[25] = latched_compr;
  assign eoi[24] = latched_compr;
  assign eoi[23] = latched_compr;
  assign eoi[22] = latched_compr;
  assign eoi[21] = latched_compr;
  assign eoi[20] = latched_compr;
  assign eoi[19] = latched_compr;
  assign eoi[18] = latched_compr;
  assign eoi[17] = latched_compr;
  assign eoi[16] = latched_compr;
  assign eoi[15] = latched_compr;
  assign eoi[14] = latched_compr;
  assign eoi[13] = latched_compr;
  assign eoi[12] = latched_compr;
  assign eoi[11] = latched_compr;
  assign eoi[10] = latched_compr;
  assign eoi[9] = latched_compr;
  assign eoi[8] = latched_compr;
  assign eoi[7] = latched_compr;
  assign eoi[6] = latched_compr;
  assign eoi[5] = latched_compr;
  assign eoi[4] = latched_compr;
  assign eoi[3] = latched_compr;
  assign eoi[2] = latched_compr;
  assign eoi[1] = latched_compr;
  assign eoi[0] = latched_compr;
  assign trace_valid = latched_compr;
  assign trace_data[35] = latched_compr;
  assign trace_data[34] = latched_compr;
  assign trace_data[33] = latched_compr;
  assign trace_data[32] = latched_compr;
  assign trace_data[31] = latched_compr;
  assign trace_data[30] = latched_compr;
  assign trace_data[29] = latched_compr;
  assign trace_data[28] = latched_compr;
  assign trace_data[27] = latched_compr;
  assign trace_data[26] = latched_compr;
  assign trace_data[25] = latched_compr;
  assign trace_data[24] = latched_compr;
  assign trace_data[23] = latched_compr;
  assign trace_data[22] = latched_compr;
  assign trace_data[21] = latched_compr;
  assign trace_data[20] = latched_compr;
  assign trace_data[19] = latched_compr;
  assign trace_data[18] = latched_compr;
  assign trace_data[17] = latched_compr;
  assign trace_data[16] = latched_compr;
  assign trace_data[15] = latched_compr;
  assign trace_data[14] = latched_compr;
  assign trace_data[13] = latched_compr;
  assign trace_data[12] = latched_compr;
  assign trace_data[11] = latched_compr;
  assign trace_data[10] = latched_compr;
  assign trace_data[9] = latched_compr;
  assign trace_data[8] = latched_compr;
  assign trace_data[7] = latched_compr;
  assign trace_data[6] = latched_compr;
  assign trace_data[5] = latched_compr;
  assign trace_data[4] = latched_compr;
  assign trace_data[3] = latched_compr;
  assign trace_data[2] = latched_compr;
  assign trace_data[1] = latched_compr;
  assign trace_data[0] = latched_compr;
  assign pcpi_insn[9] = latched_compr;
  assign pcpi_insn[8] = latched_compr;
  assign pcpi_insn[7] = latched_compr;
  assign pcpi_insn[6] = latched_compr;
  assign pcpi_insn[5] = latched_compr;
  assign pcpi_insn[4] = latched_compr;
  assign pcpi_insn[3] = latched_compr;
  assign pcpi_insn[2] = latched_compr;
  assign pcpi_insn[1] = latched_compr;
  assign pcpi_insn[31] = latched_compr;
  assign pcpi_insn[30] = latched_compr;
  assign pcpi_insn[29] = latched_compr;
  assign pcpi_insn[28] = latched_compr;
  assign pcpi_insn[27] = latched_compr;
  assign pcpi_insn[26] = latched_compr;
  assign pcpi_insn[25] = latched_compr;
  assign pcpi_insn[24] = latched_compr;
  assign pcpi_insn[23] = latched_compr;
  assign pcpi_insn[22] = latched_compr;
  assign pcpi_insn[21] = latched_compr;
  assign pcpi_insn[20] = latched_compr;
  assign pcpi_insn[19] = latched_compr;
  assign pcpi_insn[18] = latched_compr;
  assign pcpi_insn[17] = latched_compr;
  assign pcpi_insn[16] = latched_compr;
  assign pcpi_insn[15] = latched_compr;
  assign pcpi_insn[14] = latched_compr;
  assign pcpi_insn[13] = latched_compr;
  assign pcpi_insn[12] = latched_compr;
  assign pcpi_insn[11] = latched_compr;
  assign pcpi_insn[10] = latched_compr;
  assign pcpi_insn[0] = latched_compr;
  assign mem_addr[1] = latched_compr;
  assign mem_addr[0] = latched_compr;

  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[63]  ( .D(n10142), .CLK(clk), .Q(
        count_cycle[63]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[62]  ( .D(n10143), .CLK(clk), .Q(
        count_cycle[62]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[61]  ( .D(n10154), .CLK(clk), .Q(
        count_cycle[61]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[60]  ( .D(n10171), .CLK(clk), .Q(
        count_cycle[60]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[59]  ( .D(n10186), .CLK(clk), .Q(
        count_cycle[59]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[58]  ( .D(n10145), .CLK(clk), .Q(
        count_cycle[58]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[57]  ( .D(n10144), .CLK(clk), .Q(
        count_cycle[57]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[56]  ( .D(n10158), .CLK(clk), .Q(
        count_cycle[56]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[55]  ( .D(n10148), .CLK(clk), .Q(
        count_cycle[55]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[54]  ( .D(n10161), .CLK(clk), .Q(
        count_cycle[54]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[53]  ( .D(n10152), .CLK(clk), .Q(
        count_cycle[53]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[52]  ( .D(n10165), .CLK(clk), .Q(
        count_cycle[52]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[51]  ( .D(n10149), .CLK(clk), .Q(
        count_cycle[51]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[50]  ( .D(n10162), .CLK(clk), .Q(
        count_cycle[50]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[49]  ( .D(n10166), .CLK(clk), .Q(
        count_cycle[49]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[48]  ( .D(n10175), .CLK(clk), .Q(
        count_cycle[48]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[47]  ( .D(n10147), .CLK(clk), .Q(
        count_cycle[47]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[46]  ( .D(n10160), .CLK(clk), .Q(
        count_cycle[46]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[45]  ( .D(n10151), .CLK(clk), .Q(
        count_cycle[45]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[44]  ( .D(n10164), .CLK(clk), .Q(
        count_cycle[44]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[43]  ( .D(n10153), .CLK(clk), .Q(
        count_cycle[43]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[42]  ( .D(n10167), .CLK(clk), .Q(
        count_cycle[42]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[41]  ( .D(n10168), .CLK(clk), .Q(
        count_cycle[41]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[40]  ( .D(n10176), .CLK(clk), .Q(
        count_cycle[40]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[39]  ( .D(n10156), .CLK(clk), .Q(
        count_cycle[39]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[38]  ( .D(n10169), .CLK(clk), .Q(
        count_cycle[38]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[37]  ( .D(n10174), .CLK(clk), .Q(
        count_cycle[37]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[36]  ( .D(n10178), .CLK(clk), .Q(
        count_cycle[36]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[35]  ( .D(n10173), .CLK(clk), .Q(
        count_cycle[35]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[34]  ( .D(n10179), .CLK(clk), .Q(
        count_cycle[34]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[33]  ( .D(n10183), .CLK(clk), .Q(
        count_cycle[33]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[32]  ( .D(n10190), .CLK(clk), .Q(
        count_cycle[32]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[31]  ( .D(n10146), .CLK(clk), .Q(
        count_cycle[31]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[30]  ( .D(n10159), .CLK(clk), .Q(
        count_cycle[30]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[29]  ( .D(n10150), .CLK(clk), .Q(
        count_cycle[29]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[28]  ( .D(n10163), .CLK(clk), .Q(
        count_cycle[28]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[27]  ( .D(n10155), .CLK(clk), .Q(
        count_cycle[27]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[26]  ( .D(n10170), .CLK(clk), .Q(
        count_cycle[26]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[25]  ( .D(n10182), .CLK(clk), .Q(
        count_cycle[25]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[24]  ( .D(n10180), .CLK(clk), .Q(
        count_cycle[24]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[23]  ( .D(n10157), .CLK(clk), .Q(
        count_cycle[23]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[22]  ( .D(n10172), .CLK(clk), .Q(
        count_cycle[22]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[21]  ( .D(n10181), .CLK(clk), .Q(
        count_cycle[21]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[20]  ( .D(n10184), .CLK(clk), .Q(
        count_cycle[20]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[19]  ( .D(n10177), .CLK(clk), .Q(
        count_cycle[19]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[18]  ( .D(n10187), .CLK(clk), .Q(
        count_cycle[18]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[17]  ( .D(n10189), .CLK(clk), .Q(
        count_cycle[17]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[16]  ( .D(n10193), .CLK(clk), .Q(
        count_cycle[16]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[15]  ( .D(n10185), .CLK(clk), .Q(
        count_cycle[15]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[14]  ( .D(n10188), .CLK(clk), .Q(
        count_cycle[14]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[13]  ( .D(n10192), .CLK(clk), .Q(
        count_cycle[13]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[12]  ( .D(n10195), .CLK(clk), .Q(
        count_cycle[12]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[11]  ( .D(n10191), .CLK(clk), .Q(
        count_cycle[11]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[10]  ( .D(n10196), .CLK(clk), .Q(
        count_cycle[10]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[9]  ( .D(n10197), .CLK(clk), .Q(
        count_cycle[9]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[8]  ( .D(n10200), .CLK(clk), .Q(
        count_cycle[8]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[7]  ( .D(n10194), .CLK(clk), .Q(
        count_cycle[7]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[6]  ( .D(n10198), .CLK(clk), .Q(
        count_cycle[6]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[5]  ( .D(n10199), .CLK(clk), .Q(
        count_cycle[5]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[4]  ( .D(n10201), .CLK(clk), .Q(
        count_cycle[4]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[3]  ( .D(n10202), .CLK(clk), .Q(
        count_cycle[3]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[2]  ( .D(n10203), .CLK(clk), .Q(
        count_cycle[2]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[1]  ( .D(n10204), .CLK(clk), .Q(
        count_cycle[1]) );
  sky130_fd_sc_hd__dfxtp_1 \count_cycle_reg[0]  ( .D(N890), .CLK(clk), .Q(
        count_cycle[0]) );
  sky130_fd_sc_hd__dfxtp_1 mem_do_wdata_reg ( .D(n4122), .CLK(clk), .Q(
        mem_do_wdata) );
  sky130_fd_sc_hd__dfxtp_1 mem_do_rinst_reg ( .D(n2840), .CLK(clk), .Q(
        mem_do_rinst) );
  sky130_fd_sc_hd__dfxtp_1 \mem_state_reg[1]  ( .D(n2929), .CLK(clk), .Q(
        mem_state[1]) );
  sky130_fd_sc_hd__dfxtp_1 is_beq_bne_blt_bge_bltu_bgeu_reg ( .D(n3964), .CLK(
        clk), .Q(is_beq_bne_blt_bge_bltu_bgeu) );
  sky130_fd_sc_hd__dfxtp_1 is_lb_lh_lw_lbu_lhu_reg ( .D(n2910), .CLK(clk), .Q(
        is_lb_lh_lw_lbu_lhu) );
  sky130_fd_sc_hd__dfxtp_1 is_sb_sh_sw_reg ( .D(n2904), .CLK(clk), .Q(
        is_sb_sh_sw) );
  sky130_fd_sc_hd__dfxtp_1 instr_lui_reg ( .D(n2921), .CLK(clk), .Q(instr_lui)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_auipc_reg ( .D(n2920), .CLK(clk), .Q(
        instr_auipc) );
  sky130_fd_sc_hd__dfxtp_1 is_lui_auipc_jal_reg ( .D(N254), .CLK(clk), .Q(
        is_lui_auipc_jal) );
  sky130_fd_sc_hd__dfxtp_1 is_alu_reg_reg_reg ( .D(n2922), .CLK(clk), .Q(
        is_alu_reg_reg) );
  sky130_fd_sc_hd__dfxtp_1 is_alu_reg_imm_reg ( .D(n2900), .CLK(clk), .Q(
        is_alu_reg_imm) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_rd_reg[4]  ( .D(n2927), .CLK(clk), .Q(
        decoded_rd[4]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_rd_reg[3]  ( .D(n2926), .CLK(clk), .Q(
        decoded_rd[3]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_rd_reg[2]  ( .D(n2925), .CLK(clk), .Q(
        decoded_rd[2]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_rd_reg[1]  ( .D(n2924), .CLK(clk), .Q(
        decoded_rd[1]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_rd_reg[0]  ( .D(n2923), .CLK(clk), .Q(
        decoded_rd[0]) );
  sky130_fd_sc_hd__dfxtp_1 instr_jalr_reg ( .D(n2918), .CLK(clk), .Q(
        instr_jalr) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[5]  ( .D(n2887), .CLK(clk), .Q(
        decoded_imm_j[5]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[6]  ( .D(n2886), .CLK(clk), .Q(
        decoded_imm_j[6]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[7]  ( .D(n2885), .CLK(clk), .Q(
        decoded_imm_j[7]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[8]  ( .D(n2884), .CLK(clk), .Q(
        decoded_imm_j[8]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[9]  ( .D(n2883), .CLK(clk), .Q(
        decoded_imm_j[9]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[10]  ( .D(n2882), .CLK(clk), .Q(
        decoded_imm_j[10]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[12]  ( .D(n2880), .CLK(clk), .Q(
        decoded_imm_j[12]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[13]  ( .D(n2879), .CLK(clk), .Q(
        decoded_imm_j[13]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[14]  ( .D(n2878), .CLK(clk), .Q(
        decoded_imm_j[14]) );
  sky130_fd_sc_hd__dfxtp_1 mem_do_prefetch_reg ( .D(n2799), .CLK(clk), .Q(
        mem_do_prefetch) );
  sky130_fd_sc_hd__dfxtp_1 decoder_pseudo_trigger_reg ( .D(N2078), .CLK(clk), 
        .Q(decoder_pseudo_trigger) );
  sky130_fd_sc_hd__dfxtp_1 is_jalr_addi_slti_sltiu_xori_ori_andi_reg ( .D(
        n2895), .CLK(clk), .Q(is_jalr_addi_slti_sltiu_xori_ori_andi) );
  sky130_fd_sc_hd__dfxtp_1 instr_bgeu_reg ( .D(n3982), .CLK(clk), .Q(
        instr_bgeu) );
  sky130_fd_sc_hd__dfxtp_1 instr_sltiu_reg ( .D(n3979), .CLK(clk), .Q(
        instr_sltiu) );
  sky130_fd_sc_hd__dfxtp_1 instr_andi_reg ( .D(n3976), .CLK(clk), .Q(
        instr_andi) );
  sky130_fd_sc_hd__dfxtp_1 instr_sra_reg ( .D(n3968), .CLK(clk), .Q(instr_sra)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_sll_reg ( .D(n3973), .CLK(clk), .Q(instr_sll)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_srl_reg ( .D(n3969), .CLK(clk), .Q(instr_srl)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_add_reg ( .D(n3975), .CLK(clk), .Q(instr_add)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_slt_reg ( .D(n3972), .CLK(clk), .Q(instr_slt)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_xor_reg ( .D(n3970), .CLK(clk), .Q(instr_xor)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_or_reg ( .D(n3967), .CLK(clk), .Q(instr_or)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_sltu_reg ( .D(n3971), .CLK(clk), .Q(
        instr_sltu) );
  sky130_fd_sc_hd__dfxtp_1 instr_and_reg ( .D(n3966), .CLK(clk), .Q(instr_and)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_blt_reg ( .D(n3985), .CLK(clk), .Q(instr_blt)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_slti_reg ( .D(n3980), .CLK(clk), .Q(
        instr_slti) );
  sky130_fd_sc_hd__dfxtp_1 is_compare_reg ( .D(N351), .CLK(clk), .Q(is_compare) );
  sky130_fd_sc_hd__dfxtp_1 is_slti_blt_slt_reg ( .D(N256), .CLK(clk), .Q(
        is_slti_blt_slt) );
  sky130_fd_sc_hd__dfxtp_1 instr_xori_reg ( .D(n3978), .CLK(clk), .Q(
        instr_xori) );
  sky130_fd_sc_hd__dfxtp_1 instr_bltu_reg ( .D(n3983), .CLK(clk), .Q(
        instr_bltu) );
  sky130_fd_sc_hd__dfxtp_1 is_sltiu_bltu_sltu_reg ( .D(N257), .CLK(clk), .Q(
        is_sltiu_bltu_sltu) );
  sky130_fd_sc_hd__dfxtp_1 instr_ori_reg ( .D(n3977), .CLK(clk), .Q(instr_ori)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_beq_reg ( .D(n3987), .CLK(clk), .Q(instr_beq)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_addi_reg ( .D(n3981), .CLK(clk), .Q(
        instr_addi) );
  sky130_fd_sc_hd__dfxtp_1 instr_fence_reg ( .D(n3965), .CLK(clk), .Q(
        instr_fence) );
  sky130_fd_sc_hd__dfxtp_1 instr_rdinstrh_reg ( .D(n2916), .CLK(clk), .Q(
        instr_rdinstrh) );
  sky130_fd_sc_hd__dfxtp_1 instr_rdcycleh_reg ( .D(n2914), .CLK(clk), .Q(
        instr_rdcycleh) );
  sky130_fd_sc_hd__dfxtp_1 instr_rdinstr_reg ( .D(n2915), .CLK(clk), .Q(
        instr_rdinstr) );
  sky130_fd_sc_hd__dfxtp_1 instr_rdcycle_reg ( .D(n2913), .CLK(clk), .Q(
        instr_rdcycle) );
  sky130_fd_sc_hd__dfxtp_1 instr_lb_reg ( .D(n2909), .CLK(clk), .Q(instr_lb)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_lw_reg ( .D(n2907), .CLK(clk), .Q(instr_lw)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_lbu_reg ( .D(n2906), .CLK(clk), .Q(instr_lbu)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_sb_reg ( .D(n2903), .CLK(clk), .Q(instr_sb)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_sw_reg ( .D(n2901), .CLK(clk), .Q(instr_sw)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_bne_reg ( .D(n3986), .CLK(clk), .Q(instr_bne)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_bge_reg ( .D(n3984), .CLK(clk), .Q(instr_bge)
         );
  sky130_fd_sc_hd__dfxtp_1 is_sll_srl_sra_reg ( .D(n2917), .CLK(clk), .Q(
        is_sll_srl_sra) );
  sky130_fd_sc_hd__dfxtp_1 instr_lh_reg ( .D(n2908), .CLK(clk), .Q(instr_lh)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_lhu_reg ( .D(n2905), .CLK(clk), .Q(instr_lhu)
         );
  sky130_fd_sc_hd__dfxtp_1 is_lbu_lhu_lw_reg ( .D(N258), .CLK(clk), .Q(
        is_lbu_lhu_lw) );
  sky130_fd_sc_hd__dfxtp_1 instr_sh_reg ( .D(n2902), .CLK(clk), .Q(instr_sh)
         );
  sky130_fd_sc_hd__dfxtp_1 instr_slli_reg ( .D(n2899), .CLK(clk), .Q(
        instr_slli) );
  sky130_fd_sc_hd__dfxtp_1 instr_srli_reg ( .D(n2898), .CLK(clk), .Q(
        instr_srli) );
  sky130_fd_sc_hd__dfxtp_1 instr_srai_reg ( .D(n2897), .CLK(clk), .Q(
        instr_srai) );
  sky130_fd_sc_hd__dfxtp_1 is_slli_srli_srai_reg ( .D(n2896), .CLK(clk), .Q(
        is_slli_srli_srai) );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[2]  ( .D(n2837), .CLK(clk), .Q(
        cpu_state[2]) );
  sky130_fd_sc_hd__dfxtp_1 latched_is_lb_reg ( .D(n4121), .CLK(clk), .Q(
        latched_is_lb) );
  sky130_fd_sc_hd__dfxtp_1 latched_is_lh_reg ( .D(n4120), .CLK(clk), .Q(
        latched_is_lh) );
  sky130_fd_sc_hd__dfxtp_1 latched_is_lu_reg ( .D(n4119), .CLK(clk), .Q(
        latched_is_lu) );
  sky130_fd_sc_hd__dfxtp_1 mem_do_rdata_reg ( .D(n2928), .CLK(clk), .Q(
        mem_do_rdata) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wordsize_reg[0]  ( .D(n2832), .CLK(clk), .Q(
        mem_wordsize[0]) );
  sky130_fd_sc_hd__dfxtp_1 trap_reg ( .D(N2068), .CLK(clk), .Q(trap) );
  sky130_fd_sc_hd__dfxtp_1 \latched_rd_reg[0]  ( .D(n3963), .CLK(clk), .Q(
        latched_rd[0]) );
  sky130_fd_sc_hd__dfxtp_1 \latched_rd_reg[1]  ( .D(n3962), .CLK(clk), .Q(
        latched_rd[1]) );
  sky130_fd_sc_hd__dfxtp_1 \latched_rd_reg[2]  ( .D(n3961), .CLK(clk), .Q(
        latched_rd[2]) );
  sky130_fd_sc_hd__dfxtp_1 \latched_rd_reg[3]  ( .D(n3960), .CLK(clk), .Q(
        latched_rd[3]) );
  sky130_fd_sc_hd__dfxtp_1 \latched_rd_reg[4]  ( .D(n3959), .CLK(clk), .Q(
        latched_rd[4]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[0]  ( .D(n2893), .CLK(clk), .Q(
        decoded_imm[0]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[1]  ( .D(n2871), .CLK(clk), .Q(
        decoded_imm[1]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[2]  ( .D(n2870), .CLK(clk), .Q(
        decoded_imm[2]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[3]  ( .D(n2869), .CLK(clk), .Q(
        decoded_imm[3]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[4]  ( .D(n2868), .CLK(clk), .Q(
        decoded_imm[4]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[5]  ( .D(n2867), .CLK(clk), .Q(
        decoded_imm[5]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[6]  ( .D(n2866), .CLK(clk), .Q(
        decoded_imm[6]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[7]  ( .D(n2865), .CLK(clk), .Q(
        decoded_imm[7]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[8]  ( .D(n2864), .CLK(clk), .Q(
        decoded_imm[8]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[9]  ( .D(n2863), .CLK(clk), .Q(
        decoded_imm[9]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[10]  ( .D(n2862), .CLK(clk), .Q(
        decoded_imm[10]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[11]  ( .D(n2861), .CLK(clk), .Q(
        decoded_imm[11]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[12]  ( .D(n2860), .CLK(clk), .Q(
        decoded_imm[12]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[13]  ( .D(n2859), .CLK(clk), .Q(
        decoded_imm[13]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[14]  ( .D(n2858), .CLK(clk), .Q(
        decoded_imm[14]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[15]  ( .D(n2857), .CLK(clk), .Q(
        decoded_imm[15]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[16]  ( .D(n2856), .CLK(clk), .Q(
        decoded_imm[16]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[17]  ( .D(n2855), .CLK(clk), .Q(
        decoded_imm[17]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[18]  ( .D(n2854), .CLK(clk), .Q(
        decoded_imm[18]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[19]  ( .D(n2853), .CLK(clk), .Q(
        decoded_imm[19]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[0]  ( .D(n4115), .CLK(clk), .Q(
        count_instr[0]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[1]  ( .D(n4114), .CLK(clk), .Q(
        count_instr[1]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[2]  ( .D(n4113), .CLK(clk), .Q(
        count_instr[2]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[3]  ( .D(n4112), .CLK(clk), .Q(
        count_instr[3]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[4]  ( .D(n4111), .CLK(clk), .Q(
        count_instr[4]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[5]  ( .D(n4110), .CLK(clk), .Q(
        count_instr[5]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[6]  ( .D(n4109), .CLK(clk), .Q(
        count_instr[6]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[7]  ( .D(n4108), .CLK(clk), .Q(
        count_instr[7]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[8]  ( .D(n4107), .CLK(clk), .Q(
        count_instr[8]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[9]  ( .D(n4106), .CLK(clk), .Q(
        count_instr[9]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[10]  ( .D(n4105), .CLK(clk), .Q(
        count_instr[10]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[11]  ( .D(n4104), .CLK(clk), .Q(
        count_instr[11]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[12]  ( .D(n4103), .CLK(clk), .Q(
        count_instr[12]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[13]  ( .D(n4102), .CLK(clk), .Q(
        count_instr[13]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[14]  ( .D(n4101), .CLK(clk), .Q(
        count_instr[14]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[15]  ( .D(n4100), .CLK(clk), .Q(
        count_instr[15]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[16]  ( .D(n4099), .CLK(clk), .Q(
        count_instr[16]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[17]  ( .D(n4098), .CLK(clk), .Q(
        count_instr[17]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[18]  ( .D(n4097), .CLK(clk), .Q(
        count_instr[18]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[19]  ( .D(n4096), .CLK(clk), .Q(
        count_instr[19]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[20]  ( .D(n4095), .CLK(clk), .Q(
        count_instr[20]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[21]  ( .D(n4094), .CLK(clk), .Q(
        count_instr[21]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[22]  ( .D(n4093), .CLK(clk), .Q(
        count_instr[22]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[23]  ( .D(n4092), .CLK(clk), .Q(
        count_instr[23]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[24]  ( .D(n4091), .CLK(clk), .Q(
        count_instr[24]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[25]  ( .D(n4090), .CLK(clk), .Q(
        count_instr[25]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[26]  ( .D(n4089), .CLK(clk), .Q(
        count_instr[26]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[27]  ( .D(n4088), .CLK(clk), .Q(
        count_instr[27]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[28]  ( .D(n4087), .CLK(clk), .Q(
        count_instr[28]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[29]  ( .D(n4086), .CLK(clk), .Q(
        count_instr[29]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[30]  ( .D(n4085), .CLK(clk), .Q(
        count_instr[30]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[31]  ( .D(n4084), .CLK(clk), .Q(
        count_instr[31]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[32]  ( .D(n4083), .CLK(clk), .Q(
        count_instr[32]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[33]  ( .D(n4082), .CLK(clk), .Q(
        count_instr[33]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[34]  ( .D(n4081), .CLK(clk), .Q(
        count_instr[34]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[35]  ( .D(n4080), .CLK(clk), .Q(
        count_instr[35]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[36]  ( .D(n4079), .CLK(clk), .Q(
        count_instr[36]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[37]  ( .D(n4078), .CLK(clk), .Q(
        count_instr[37]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[38]  ( .D(n4077), .CLK(clk), .Q(
        count_instr[38]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[39]  ( .D(n4076), .CLK(clk), .Q(
        count_instr[39]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[40]  ( .D(n4075), .CLK(clk), .Q(
        count_instr[40]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[41]  ( .D(n4074), .CLK(clk), .Q(
        count_instr[41]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[42]  ( .D(n4073), .CLK(clk), .Q(
        count_instr[42]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[43]  ( .D(n4072), .CLK(clk), .Q(
        count_instr[43]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[44]  ( .D(n4071), .CLK(clk), .Q(
        count_instr[44]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[45]  ( .D(n4070), .CLK(clk), .Q(
        count_instr[45]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[46]  ( .D(n4069), .CLK(clk), .Q(
        count_instr[46]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[47]  ( .D(n4068), .CLK(clk), .Q(
        count_instr[47]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[48]  ( .D(n4067), .CLK(clk), .Q(
        count_instr[48]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[49]  ( .D(n4066), .CLK(clk), .Q(
        count_instr[49]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[50]  ( .D(n4065), .CLK(clk), .Q(
        count_instr[50]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[51]  ( .D(n4064), .CLK(clk), .Q(
        count_instr[51]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[52]  ( .D(n4063), .CLK(clk), .Q(
        count_instr[52]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[53]  ( .D(n4062), .CLK(clk), .Q(
        count_instr[53]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[54]  ( .D(n4061), .CLK(clk), .Q(
        count_instr[54]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[55]  ( .D(n4060), .CLK(clk), .Q(
        count_instr[55]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[56]  ( .D(n4059), .CLK(clk), .Q(
        count_instr[56]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[57]  ( .D(n4058), .CLK(clk), .Q(
        count_instr[57]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[58]  ( .D(n4057), .CLK(clk), .Q(
        count_instr[58]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[59]  ( .D(n4056), .CLK(clk), .Q(
        count_instr[59]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[60]  ( .D(n4055), .CLK(clk), .Q(
        count_instr[60]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[61]  ( .D(n4054), .CLK(clk), .Q(
        count_instr[61]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[62]  ( .D(n4053), .CLK(clk), .Q(
        count_instr[62]) );
  sky130_fd_sc_hd__dfxtp_1 \count_instr_reg[63]  ( .D(n4052), .CLK(clk), .Q(
        count_instr[63]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[7]  ( .D(N1884), .CLK(clk), .Q(
        reg_out[7]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][7]  ( .D(n3709), .CLK(clk), .Q(
        \cpuregs[31][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][7]  ( .D(n3708), .CLK(clk), .Q(
        \cpuregs[30][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][7]  ( .D(n3707), .CLK(clk), .Q(
        \cpuregs[29][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][7]  ( .D(n3706), .CLK(clk), .Q(
        \cpuregs[28][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][7]  ( .D(n3705), .CLK(clk), .Q(
        \cpuregs[27][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][7]  ( .D(n3704), .CLK(clk), .Q(
        \cpuregs[26][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][7]  ( .D(n3703), .CLK(clk), .Q(
        \cpuregs[25][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][7]  ( .D(n3702), .CLK(clk), .Q(
        \cpuregs[24][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][7]  ( .D(n3701), .CLK(clk), .Q(
        \cpuregs[23][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][7]  ( .D(n3700), .CLK(clk), .Q(
        \cpuregs[22][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][7]  ( .D(n3699), .CLK(clk), .Q(
        \cpuregs[21][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][7]  ( .D(n3698), .CLK(clk), .Q(
        \cpuregs[20][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][7]  ( .D(n3697), .CLK(clk), .Q(
        \cpuregs[19][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][7]  ( .D(n3696), .CLK(clk), .Q(
        \cpuregs[18][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][7]  ( .D(n3695), .CLK(clk), .Q(
        \cpuregs[17][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][7]  ( .D(n3694), .CLK(clk), .Q(
        \cpuregs[16][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][7]  ( .D(n3693), .CLK(clk), .Q(
        \cpuregs[15][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][7]  ( .D(n3692), .CLK(clk), .Q(
        \cpuregs[14][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][7]  ( .D(n3691), .CLK(clk), .Q(
        \cpuregs[13][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][7]  ( .D(n3690), .CLK(clk), .Q(
        \cpuregs[12][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][7]  ( .D(n3689), .CLK(clk), .Q(
        \cpuregs[11][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][7]  ( .D(n3688), .CLK(clk), .Q(
        \cpuregs[10][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][7]  ( .D(n3687), .CLK(clk), .Q(
        \cpuregs[9][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][7]  ( .D(n3686), .CLK(clk), .Q(
        \cpuregs[8][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][7]  ( .D(n3685), .CLK(clk), .Q(
        \cpuregs[7][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][7]  ( .D(n3684), .CLK(clk), .Q(
        \cpuregs[6][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][7]  ( .D(n3683), .CLK(clk), .Q(
        \cpuregs[5][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][7]  ( .D(n3682), .CLK(clk), .Q(
        \cpuregs[4][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][7]  ( .D(n3681), .CLK(clk), .Q(
        \cpuregs[3][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][7]  ( .D(n3680), .CLK(clk), .Q(
        \cpuregs[2][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][7]  ( .D(n3679), .CLK(clk), .Q(
        \cpuregs[1][7] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[7]  ( .D(alu_out[7]), .CLK(clk), .Q(
        alu_out_q[7]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[7]  ( .D(n4044), .CLK(clk), .Q(
        reg_next_pc[7]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[7]  ( .D(n4012), .CLK(clk), .Q(
        reg_pc[7]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[8]  ( .D(N1885), .CLK(clk), .Q(
        reg_out[8]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][8]  ( .D(n3678), .CLK(clk), .Q(
        \cpuregs[31][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][8]  ( .D(n3677), .CLK(clk), .Q(
        \cpuregs[30][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][8]  ( .D(n3676), .CLK(clk), .Q(
        \cpuregs[29][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][8]  ( .D(n3675), .CLK(clk), .Q(
        \cpuregs[28][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][8]  ( .D(n3674), .CLK(clk), .Q(
        \cpuregs[27][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][8]  ( .D(n3673), .CLK(clk), .Q(
        \cpuregs[26][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][8]  ( .D(n3672), .CLK(clk), .Q(
        \cpuregs[25][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][8]  ( .D(n3671), .CLK(clk), .Q(
        \cpuregs[24][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][8]  ( .D(n3670), .CLK(clk), .Q(
        \cpuregs[23][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][8]  ( .D(n3669), .CLK(clk), .Q(
        \cpuregs[22][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][8]  ( .D(n3668), .CLK(clk), .Q(
        \cpuregs[21][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][8]  ( .D(n3667), .CLK(clk), .Q(
        \cpuregs[20][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][8]  ( .D(n3666), .CLK(clk), .Q(
        \cpuregs[19][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][8]  ( .D(n3665), .CLK(clk), .Q(
        \cpuregs[18][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][8]  ( .D(n3664), .CLK(clk), .Q(
        \cpuregs[17][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][8]  ( .D(n3663), .CLK(clk), .Q(
        \cpuregs[16][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][8]  ( .D(n3662), .CLK(clk), .Q(
        \cpuregs[15][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][8]  ( .D(n3661), .CLK(clk), .Q(
        \cpuregs[14][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][8]  ( .D(n3660), .CLK(clk), .Q(
        \cpuregs[13][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][8]  ( .D(n3659), .CLK(clk), .Q(
        \cpuregs[12][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][8]  ( .D(n3658), .CLK(clk), .Q(
        \cpuregs[11][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][8]  ( .D(n3657), .CLK(clk), .Q(
        \cpuregs[10][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][8]  ( .D(n3656), .CLK(clk), .Q(
        \cpuregs[9][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][8]  ( .D(n3655), .CLK(clk), .Q(
        \cpuregs[8][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][8]  ( .D(n3654), .CLK(clk), .Q(
        \cpuregs[7][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][8]  ( .D(n3653), .CLK(clk), .Q(
        \cpuregs[6][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][8]  ( .D(n3652), .CLK(clk), .Q(
        \cpuregs[5][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][8]  ( .D(n3651), .CLK(clk), .Q(
        \cpuregs[4][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][8]  ( .D(n3650), .CLK(clk), .Q(
        \cpuregs[3][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][8]  ( .D(n3649), .CLK(clk), .Q(
        \cpuregs[2][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][8]  ( .D(n3648), .CLK(clk), .Q(
        \cpuregs[1][8] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[8]  ( .D(alu_out[8]), .CLK(clk), .Q(
        alu_out_q[8]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[8]  ( .D(n4043), .CLK(clk), .Q(
        reg_next_pc[8]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[8]  ( .D(n4011), .CLK(clk), .Q(
        reg_pc[8]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[9]  ( .D(N1886), .CLK(clk), .Q(
        reg_out[9]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][9]  ( .D(n3647), .CLK(clk), .Q(
        \cpuregs[31][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][9]  ( .D(n3646), .CLK(clk), .Q(
        \cpuregs[30][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][9]  ( .D(n3645), .CLK(clk), .Q(
        \cpuregs[29][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][9]  ( .D(n3644), .CLK(clk), .Q(
        \cpuregs[28][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][9]  ( .D(n3643), .CLK(clk), .Q(
        \cpuregs[27][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][9]  ( .D(n3642), .CLK(clk), .Q(
        \cpuregs[26][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][9]  ( .D(n3641), .CLK(clk), .Q(
        \cpuregs[25][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][9]  ( .D(n3640), .CLK(clk), .Q(
        \cpuregs[24][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][9]  ( .D(n3639), .CLK(clk), .Q(
        \cpuregs[23][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][9]  ( .D(n3638), .CLK(clk), .Q(
        \cpuregs[22][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][9]  ( .D(n3637), .CLK(clk), .Q(
        \cpuregs[21][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][9]  ( .D(n3636), .CLK(clk), .Q(
        \cpuregs[20][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][9]  ( .D(n3635), .CLK(clk), .Q(
        \cpuregs[19][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][9]  ( .D(n3634), .CLK(clk), .Q(
        \cpuregs[18][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][9]  ( .D(n3633), .CLK(clk), .Q(
        \cpuregs[17][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][9]  ( .D(n3632), .CLK(clk), .Q(
        \cpuregs[16][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][9]  ( .D(n3631), .CLK(clk), .Q(
        \cpuregs[15][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][9]  ( .D(n3630), .CLK(clk), .Q(
        \cpuregs[14][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][9]  ( .D(n3629), .CLK(clk), .Q(
        \cpuregs[13][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][9]  ( .D(n3628), .CLK(clk), .Q(
        \cpuregs[12][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][9]  ( .D(n3627), .CLK(clk), .Q(
        \cpuregs[11][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][9]  ( .D(n3626), .CLK(clk), .Q(
        \cpuregs[10][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][9]  ( .D(n3625), .CLK(clk), .Q(
        \cpuregs[9][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][9]  ( .D(n3624), .CLK(clk), .Q(
        \cpuregs[8][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][9]  ( .D(n3623), .CLK(clk), .Q(
        \cpuregs[7][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][9]  ( .D(n3622), .CLK(clk), .Q(
        \cpuregs[6][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][9]  ( .D(n3621), .CLK(clk), .Q(
        \cpuregs[5][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][9]  ( .D(n3620), .CLK(clk), .Q(
        \cpuregs[4][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][9]  ( .D(n3619), .CLK(clk), .Q(
        \cpuregs[3][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][9]  ( .D(n3618), .CLK(clk), .Q(
        \cpuregs[2][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][9]  ( .D(n3617), .CLK(clk), .Q(
        \cpuregs[1][9] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[9]  ( .D(alu_out[9]), .CLK(clk), .Q(
        alu_out_q[9]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[9]  ( .D(n4042), .CLK(clk), .Q(
        reg_next_pc[9]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[9]  ( .D(n4010), .CLK(clk), .Q(
        reg_pc[9]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[10]  ( .D(N1887), .CLK(clk), .Q(
        reg_out[10]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][10]  ( .D(n3616), .CLK(clk), .Q(
        \cpuregs[31][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][10]  ( .D(n3615), .CLK(clk), .Q(
        \cpuregs[30][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][10]  ( .D(n3614), .CLK(clk), .Q(
        \cpuregs[29][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][10]  ( .D(n3613), .CLK(clk), .Q(
        \cpuregs[28][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][10]  ( .D(n3612), .CLK(clk), .Q(
        \cpuregs[27][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][10]  ( .D(n3611), .CLK(clk), .Q(
        \cpuregs[26][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][10]  ( .D(n3610), .CLK(clk), .Q(
        \cpuregs[25][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][10]  ( .D(n3609), .CLK(clk), .Q(
        \cpuregs[24][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][10]  ( .D(n3608), .CLK(clk), .Q(
        \cpuregs[23][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][10]  ( .D(n3607), .CLK(clk), .Q(
        \cpuregs[22][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][10]  ( .D(n3606), .CLK(clk), .Q(
        \cpuregs[21][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][10]  ( .D(n3605), .CLK(clk), .Q(
        \cpuregs[20][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][10]  ( .D(n3604), .CLK(clk), .Q(
        \cpuregs[19][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][10]  ( .D(n3603), .CLK(clk), .Q(
        \cpuregs[18][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][10]  ( .D(n3602), .CLK(clk), .Q(
        \cpuregs[17][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][10]  ( .D(n3601), .CLK(clk), .Q(
        \cpuregs[16][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][10]  ( .D(n3600), .CLK(clk), .Q(
        \cpuregs[15][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][10]  ( .D(n3599), .CLK(clk), .Q(
        \cpuregs[14][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][10]  ( .D(n3598), .CLK(clk), .Q(
        \cpuregs[13][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][10]  ( .D(n3597), .CLK(clk), .Q(
        \cpuregs[12][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][10]  ( .D(n3596), .CLK(clk), .Q(
        \cpuregs[11][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][10]  ( .D(n3595), .CLK(clk), .Q(
        \cpuregs[10][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][10]  ( .D(n3594), .CLK(clk), .Q(
        \cpuregs[9][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][10]  ( .D(n3593), .CLK(clk), .Q(
        \cpuregs[8][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][10]  ( .D(n3592), .CLK(clk), .Q(
        \cpuregs[7][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][10]  ( .D(n3591), .CLK(clk), .Q(
        \cpuregs[6][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][10]  ( .D(n3590), .CLK(clk), .Q(
        \cpuregs[5][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][10]  ( .D(n3589), .CLK(clk), .Q(
        \cpuregs[4][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][10]  ( .D(n3588), .CLK(clk), .Q(
        \cpuregs[3][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][10]  ( .D(n3587), .CLK(clk), .Q(
        \cpuregs[2][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][10]  ( .D(n3586), .CLK(clk), .Q(
        \cpuregs[1][10] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[10]  ( .D(alu_out[10]), .CLK(clk), 
        .Q(alu_out_q[10]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[10]  ( .D(n4041), .CLK(clk), .Q(
        reg_next_pc[10]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[10]  ( .D(n4009), .CLK(clk), .Q(
        reg_pc[10]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[11]  ( .D(N1888), .CLK(clk), .Q(
        reg_out[11]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][11]  ( .D(n3585), .CLK(clk), .Q(
        \cpuregs[31][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][11]  ( .D(n3584), .CLK(clk), .Q(
        \cpuregs[30][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][11]  ( .D(n3583), .CLK(clk), .Q(
        \cpuregs[29][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][11]  ( .D(n3582), .CLK(clk), .Q(
        \cpuregs[28][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][11]  ( .D(n3581), .CLK(clk), .Q(
        \cpuregs[27][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][11]  ( .D(n3580), .CLK(clk), .Q(
        \cpuregs[26][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][11]  ( .D(n3579), .CLK(clk), .Q(
        \cpuregs[25][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][11]  ( .D(n3578), .CLK(clk), .Q(
        \cpuregs[24][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][11]  ( .D(n3577), .CLK(clk), .Q(
        \cpuregs[23][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][11]  ( .D(n3576), .CLK(clk), .Q(
        \cpuregs[22][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][11]  ( .D(n3575), .CLK(clk), .Q(
        \cpuregs[21][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][11]  ( .D(n3574), .CLK(clk), .Q(
        \cpuregs[20][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][11]  ( .D(n3573), .CLK(clk), .Q(
        \cpuregs[19][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][11]  ( .D(n3572), .CLK(clk), .Q(
        \cpuregs[18][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][11]  ( .D(n3571), .CLK(clk), .Q(
        \cpuregs[17][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][11]  ( .D(n3570), .CLK(clk), .Q(
        \cpuregs[16][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][11]  ( .D(n3569), .CLK(clk), .Q(
        \cpuregs[15][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][11]  ( .D(n3568), .CLK(clk), .Q(
        \cpuregs[14][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][11]  ( .D(n3567), .CLK(clk), .Q(
        \cpuregs[13][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][11]  ( .D(n3566), .CLK(clk), .Q(
        \cpuregs[12][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][11]  ( .D(n3565), .CLK(clk), .Q(
        \cpuregs[11][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][11]  ( .D(n3564), .CLK(clk), .Q(
        \cpuregs[10][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][11]  ( .D(n3563), .CLK(clk), .Q(
        \cpuregs[9][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][11]  ( .D(n3562), .CLK(clk), .Q(
        \cpuregs[8][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][11]  ( .D(n3561), .CLK(clk), .Q(
        \cpuregs[7][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][11]  ( .D(n3560), .CLK(clk), .Q(
        \cpuregs[6][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][11]  ( .D(n3559), .CLK(clk), .Q(
        \cpuregs[5][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][11]  ( .D(n3558), .CLK(clk), .Q(
        \cpuregs[4][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][11]  ( .D(n3557), .CLK(clk), .Q(
        \cpuregs[3][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][11]  ( .D(n3556), .CLK(clk), .Q(
        \cpuregs[2][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][11]  ( .D(n3555), .CLK(clk), .Q(
        \cpuregs[1][11] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[11]  ( .D(alu_out[11]), .CLK(clk), 
        .Q(alu_out_q[11]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[11]  ( .D(n4040), .CLK(clk), .Q(
        reg_next_pc[11]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[11]  ( .D(n4008), .CLK(clk), .Q(
        reg_pc[11]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[12]  ( .D(N1889), .CLK(clk), .Q(
        reg_out[12]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][12]  ( .D(n3554), .CLK(clk), .Q(
        \cpuregs[31][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][12]  ( .D(n3553), .CLK(clk), .Q(
        \cpuregs[30][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][12]  ( .D(n3552), .CLK(clk), .Q(
        \cpuregs[29][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][12]  ( .D(n3551), .CLK(clk), .Q(
        \cpuregs[28][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][12]  ( .D(n3550), .CLK(clk), .Q(
        \cpuregs[27][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][12]  ( .D(n3549), .CLK(clk), .Q(
        \cpuregs[26][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][12]  ( .D(n3548), .CLK(clk), .Q(
        \cpuregs[25][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][12]  ( .D(n3547), .CLK(clk), .Q(
        \cpuregs[24][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][12]  ( .D(n3546), .CLK(clk), .Q(
        \cpuregs[23][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][12]  ( .D(n3545), .CLK(clk), .Q(
        \cpuregs[22][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][12]  ( .D(n3544), .CLK(clk), .Q(
        \cpuregs[21][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][12]  ( .D(n3543), .CLK(clk), .Q(
        \cpuregs[20][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][12]  ( .D(n3542), .CLK(clk), .Q(
        \cpuregs[19][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][12]  ( .D(n3541), .CLK(clk), .Q(
        \cpuregs[18][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][12]  ( .D(n3540), .CLK(clk), .Q(
        \cpuregs[17][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][12]  ( .D(n3539), .CLK(clk), .Q(
        \cpuregs[16][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][12]  ( .D(n3538), .CLK(clk), .Q(
        \cpuregs[15][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][12]  ( .D(n3537), .CLK(clk), .Q(
        \cpuregs[14][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][12]  ( .D(n3536), .CLK(clk), .Q(
        \cpuregs[13][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][12]  ( .D(n3535), .CLK(clk), .Q(
        \cpuregs[12][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][12]  ( .D(n3534), .CLK(clk), .Q(
        \cpuregs[11][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][12]  ( .D(n3533), .CLK(clk), .Q(
        \cpuregs[10][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][12]  ( .D(n3532), .CLK(clk), .Q(
        \cpuregs[9][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][12]  ( .D(n3531), .CLK(clk), .Q(
        \cpuregs[8][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][12]  ( .D(n3530), .CLK(clk), .Q(
        \cpuregs[7][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][12]  ( .D(n3529), .CLK(clk), .Q(
        \cpuregs[6][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][12]  ( .D(n3528), .CLK(clk), .Q(
        \cpuregs[5][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][12]  ( .D(n3527), .CLK(clk), .Q(
        \cpuregs[4][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][12]  ( .D(n3526), .CLK(clk), .Q(
        \cpuregs[3][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][12]  ( .D(n3525), .CLK(clk), .Q(
        \cpuregs[2][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][12]  ( .D(n3524), .CLK(clk), .Q(
        \cpuregs[1][12] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[12]  ( .D(alu_out[12]), .CLK(clk), 
        .Q(alu_out_q[12]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[12]  ( .D(n4039), .CLK(clk), .Q(
        reg_next_pc[12]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[12]  ( .D(n4007), .CLK(clk), .Q(
        reg_pc[12]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[13]  ( .D(N1890), .CLK(clk), .Q(
        reg_out[13]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][13]  ( .D(n3523), .CLK(clk), .Q(
        \cpuregs[31][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][13]  ( .D(n3522), .CLK(clk), .Q(
        \cpuregs[30][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][13]  ( .D(n3521), .CLK(clk), .Q(
        \cpuregs[29][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][13]  ( .D(n3520), .CLK(clk), .Q(
        \cpuregs[28][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][13]  ( .D(n3519), .CLK(clk), .Q(
        \cpuregs[27][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][13]  ( .D(n3518), .CLK(clk), .Q(
        \cpuregs[26][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][13]  ( .D(n3517), .CLK(clk), .Q(
        \cpuregs[25][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][13]  ( .D(n3516), .CLK(clk), .Q(
        \cpuregs[24][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][13]  ( .D(n3515), .CLK(clk), .Q(
        \cpuregs[23][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][13]  ( .D(n3514), .CLK(clk), .Q(
        \cpuregs[22][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][13]  ( .D(n3513), .CLK(clk), .Q(
        \cpuregs[21][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][13]  ( .D(n3512), .CLK(clk), .Q(
        \cpuregs[20][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][13]  ( .D(n3511), .CLK(clk), .Q(
        \cpuregs[19][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][13]  ( .D(n3510), .CLK(clk), .Q(
        \cpuregs[18][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][13]  ( .D(n3509), .CLK(clk), .Q(
        \cpuregs[17][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][13]  ( .D(n3508), .CLK(clk), .Q(
        \cpuregs[16][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][13]  ( .D(n3507), .CLK(clk), .Q(
        \cpuregs[15][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][13]  ( .D(n3506), .CLK(clk), .Q(
        \cpuregs[14][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][13]  ( .D(n3505), .CLK(clk), .Q(
        \cpuregs[13][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][13]  ( .D(n3504), .CLK(clk), .Q(
        \cpuregs[12][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][13]  ( .D(n3503), .CLK(clk), .Q(
        \cpuregs[11][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][13]  ( .D(n3502), .CLK(clk), .Q(
        \cpuregs[10][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][13]  ( .D(n3501), .CLK(clk), .Q(
        \cpuregs[9][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][13]  ( .D(n3500), .CLK(clk), .Q(
        \cpuregs[8][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][13]  ( .D(n3499), .CLK(clk), .Q(
        \cpuregs[7][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][13]  ( .D(n3498), .CLK(clk), .Q(
        \cpuregs[6][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][13]  ( .D(n3497), .CLK(clk), .Q(
        \cpuregs[5][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][13]  ( .D(n3496), .CLK(clk), .Q(
        \cpuregs[4][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][13]  ( .D(n3495), .CLK(clk), .Q(
        \cpuregs[3][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][13]  ( .D(n3494), .CLK(clk), .Q(
        \cpuregs[2][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][13]  ( .D(n3493), .CLK(clk), .Q(
        \cpuregs[1][13] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[13]  ( .D(alu_out[13]), .CLK(clk), 
        .Q(alu_out_q[13]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[13]  ( .D(n4038), .CLK(clk), .Q(
        reg_next_pc[13]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[13]  ( .D(n4006), .CLK(clk), .Q(
        reg_pc[13]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[14]  ( .D(N1891), .CLK(clk), .Q(
        reg_out[14]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][14]  ( .D(n3492), .CLK(clk), .Q(
        \cpuregs[31][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][14]  ( .D(n3491), .CLK(clk), .Q(
        \cpuregs[30][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][14]  ( .D(n3490), .CLK(clk), .Q(
        \cpuregs[29][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][14]  ( .D(n3489), .CLK(clk), .Q(
        \cpuregs[28][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][14]  ( .D(n3488), .CLK(clk), .Q(
        \cpuregs[27][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][14]  ( .D(n3487), .CLK(clk), .Q(
        \cpuregs[26][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][14]  ( .D(n3486), .CLK(clk), .Q(
        \cpuregs[25][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][14]  ( .D(n3485), .CLK(clk), .Q(
        \cpuregs[24][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][14]  ( .D(n3484), .CLK(clk), .Q(
        \cpuregs[23][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][14]  ( .D(n3483), .CLK(clk), .Q(
        \cpuregs[22][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][14]  ( .D(n3482), .CLK(clk), .Q(
        \cpuregs[21][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][14]  ( .D(n3481), .CLK(clk), .Q(
        \cpuregs[20][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][14]  ( .D(n3480), .CLK(clk), .Q(
        \cpuregs[19][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][14]  ( .D(n3479), .CLK(clk), .Q(
        \cpuregs[18][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][14]  ( .D(n3478), .CLK(clk), .Q(
        \cpuregs[17][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][14]  ( .D(n3477), .CLK(clk), .Q(
        \cpuregs[16][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][14]  ( .D(n3476), .CLK(clk), .Q(
        \cpuregs[15][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][14]  ( .D(n3475), .CLK(clk), .Q(
        \cpuregs[14][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][14]  ( .D(n3474), .CLK(clk), .Q(
        \cpuregs[13][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][14]  ( .D(n3473), .CLK(clk), .Q(
        \cpuregs[12][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][14]  ( .D(n3472), .CLK(clk), .Q(
        \cpuregs[11][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][14]  ( .D(n3471), .CLK(clk), .Q(
        \cpuregs[10][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][14]  ( .D(n3470), .CLK(clk), .Q(
        \cpuregs[9][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][14]  ( .D(n3469), .CLK(clk), .Q(
        \cpuregs[8][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][14]  ( .D(n3468), .CLK(clk), .Q(
        \cpuregs[7][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][14]  ( .D(n3467), .CLK(clk), .Q(
        \cpuregs[6][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][14]  ( .D(n3466), .CLK(clk), .Q(
        \cpuregs[5][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][14]  ( .D(n3465), .CLK(clk), .Q(
        \cpuregs[4][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][14]  ( .D(n3464), .CLK(clk), .Q(
        \cpuregs[3][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][14]  ( .D(n3463), .CLK(clk), .Q(
        \cpuregs[2][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][14]  ( .D(n3462), .CLK(clk), .Q(
        \cpuregs[1][14] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[14]  ( .D(alu_out[14]), .CLK(clk), 
        .Q(alu_out_q[14]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[14]  ( .D(n4037), .CLK(clk), .Q(
        reg_next_pc[14]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[14]  ( .D(n4005), .CLK(clk), .Q(
        reg_pc[14]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[15]  ( .D(N1892), .CLK(clk), .Q(
        reg_out[15]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][15]  ( .D(n3461), .CLK(clk), .Q(
        \cpuregs[31][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][15]  ( .D(n3460), .CLK(clk), .Q(
        \cpuregs[30][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][15]  ( .D(n3459), .CLK(clk), .Q(
        \cpuregs[29][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][15]  ( .D(n3458), .CLK(clk), .Q(
        \cpuregs[28][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][15]  ( .D(n3457), .CLK(clk), .Q(
        \cpuregs[27][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][15]  ( .D(n3456), .CLK(clk), .Q(
        \cpuregs[26][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][15]  ( .D(n3455), .CLK(clk), .Q(
        \cpuregs[25][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][15]  ( .D(n3454), .CLK(clk), .Q(
        \cpuregs[24][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][15]  ( .D(n3453), .CLK(clk), .Q(
        \cpuregs[23][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][15]  ( .D(n3452), .CLK(clk), .Q(
        \cpuregs[22][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][15]  ( .D(n3451), .CLK(clk), .Q(
        \cpuregs[21][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][15]  ( .D(n3450), .CLK(clk), .Q(
        \cpuregs[20][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][15]  ( .D(n3449), .CLK(clk), .Q(
        \cpuregs[19][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][15]  ( .D(n3448), .CLK(clk), .Q(
        \cpuregs[18][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][15]  ( .D(n3447), .CLK(clk), .Q(
        \cpuregs[17][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][15]  ( .D(n3446), .CLK(clk), .Q(
        \cpuregs[16][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][15]  ( .D(n3445), .CLK(clk), .Q(
        \cpuregs[15][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][15]  ( .D(n3444), .CLK(clk), .Q(
        \cpuregs[14][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][15]  ( .D(n3443), .CLK(clk), .Q(
        \cpuregs[13][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][15]  ( .D(n3442), .CLK(clk), .Q(
        \cpuregs[12][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][15]  ( .D(n3441), .CLK(clk), .Q(
        \cpuregs[11][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][15]  ( .D(n3440), .CLK(clk), .Q(
        \cpuregs[10][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][15]  ( .D(n3439), .CLK(clk), .Q(
        \cpuregs[9][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][15]  ( .D(n3438), .CLK(clk), .Q(
        \cpuregs[8][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][15]  ( .D(n3437), .CLK(clk), .Q(
        \cpuregs[7][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][15]  ( .D(n3436), .CLK(clk), .Q(
        \cpuregs[6][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][15]  ( .D(n3435), .CLK(clk), .Q(
        \cpuregs[5][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][15]  ( .D(n3434), .CLK(clk), .Q(
        \cpuregs[4][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][15]  ( .D(n3433), .CLK(clk), .Q(
        \cpuregs[3][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][15]  ( .D(n3432), .CLK(clk), .Q(
        \cpuregs[2][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][15]  ( .D(n3431), .CLK(clk), .Q(
        \cpuregs[1][15] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[15]  ( .D(alu_out[15]), .CLK(clk), 
        .Q(alu_out_q[15]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[15]  ( .D(n4036), .CLK(clk), .Q(
        reg_next_pc[15]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[15]  ( .D(n4004), .CLK(clk), .Q(
        reg_pc[15]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[16]  ( .D(N1893), .CLK(clk), .Q(
        reg_out[16]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][16]  ( .D(n3430), .CLK(clk), .Q(
        \cpuregs[31][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][16]  ( .D(n3429), .CLK(clk), .Q(
        \cpuregs[30][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][16]  ( .D(n3428), .CLK(clk), .Q(
        \cpuregs[29][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][16]  ( .D(n3427), .CLK(clk), .Q(
        \cpuregs[28][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][16]  ( .D(n3426), .CLK(clk), .Q(
        \cpuregs[27][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][16]  ( .D(n3425), .CLK(clk), .Q(
        \cpuregs[26][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][16]  ( .D(n3424), .CLK(clk), .Q(
        \cpuregs[25][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][16]  ( .D(n3423), .CLK(clk), .Q(
        \cpuregs[24][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][16]  ( .D(n3422), .CLK(clk), .Q(
        \cpuregs[23][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][16]  ( .D(n3421), .CLK(clk), .Q(
        \cpuregs[22][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][16]  ( .D(n3420), .CLK(clk), .Q(
        \cpuregs[21][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][16]  ( .D(n3419), .CLK(clk), .Q(
        \cpuregs[20][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][16]  ( .D(n3418), .CLK(clk), .Q(
        \cpuregs[19][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][16]  ( .D(n3417), .CLK(clk), .Q(
        \cpuregs[18][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][16]  ( .D(n3416), .CLK(clk), .Q(
        \cpuregs[17][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][16]  ( .D(n3415), .CLK(clk), .Q(
        \cpuregs[16][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][16]  ( .D(n3414), .CLK(clk), .Q(
        \cpuregs[15][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][16]  ( .D(n3413), .CLK(clk), .Q(
        \cpuregs[14][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][16]  ( .D(n3412), .CLK(clk), .Q(
        \cpuregs[13][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][16]  ( .D(n3411), .CLK(clk), .Q(
        \cpuregs[12][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][16]  ( .D(n3410), .CLK(clk), .Q(
        \cpuregs[11][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][16]  ( .D(n3409), .CLK(clk), .Q(
        \cpuregs[10][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][16]  ( .D(n3408), .CLK(clk), .Q(
        \cpuregs[9][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][16]  ( .D(n3407), .CLK(clk), .Q(
        \cpuregs[8][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][16]  ( .D(n3406), .CLK(clk), .Q(
        \cpuregs[7][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][16]  ( .D(n3405), .CLK(clk), .Q(
        \cpuregs[6][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][16]  ( .D(n3404), .CLK(clk), .Q(
        \cpuregs[5][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][16]  ( .D(n3403), .CLK(clk), .Q(
        \cpuregs[4][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][16]  ( .D(n3402), .CLK(clk), .Q(
        \cpuregs[3][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][16]  ( .D(n3401), .CLK(clk), .Q(
        \cpuregs[2][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][16]  ( .D(n3400), .CLK(clk), .Q(
        \cpuregs[1][16] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[16]  ( .D(alu_out[16]), .CLK(clk), 
        .Q(alu_out_q[16]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[16]  ( .D(n4035), .CLK(clk), .Q(
        reg_next_pc[16]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[16]  ( .D(n4003), .CLK(clk), .Q(
        reg_pc[16]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[17]  ( .D(N1894), .CLK(clk), .Q(
        reg_out[17]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][17]  ( .D(n3399), .CLK(clk), .Q(
        \cpuregs[31][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][17]  ( .D(n3398), .CLK(clk), .Q(
        \cpuregs[30][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][17]  ( .D(n3397), .CLK(clk), .Q(
        \cpuregs[29][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][17]  ( .D(n3396), .CLK(clk), .Q(
        \cpuregs[28][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][17]  ( .D(n3395), .CLK(clk), .Q(
        \cpuregs[27][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][17]  ( .D(n3394), .CLK(clk), .Q(
        \cpuregs[26][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][17]  ( .D(n3393), .CLK(clk), .Q(
        \cpuregs[25][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][17]  ( .D(n3392), .CLK(clk), .Q(
        \cpuregs[24][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][17]  ( .D(n3391), .CLK(clk), .Q(
        \cpuregs[23][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][17]  ( .D(n3390), .CLK(clk), .Q(
        \cpuregs[22][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][17]  ( .D(n3389), .CLK(clk), .Q(
        \cpuregs[21][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][17]  ( .D(n3388), .CLK(clk), .Q(
        \cpuregs[20][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][17]  ( .D(n3387), .CLK(clk), .Q(
        \cpuregs[19][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][17]  ( .D(n3386), .CLK(clk), .Q(
        \cpuregs[18][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][17]  ( .D(n3385), .CLK(clk), .Q(
        \cpuregs[17][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][17]  ( .D(n3384), .CLK(clk), .Q(
        \cpuregs[16][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][17]  ( .D(n3383), .CLK(clk), .Q(
        \cpuregs[15][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][17]  ( .D(n3382), .CLK(clk), .Q(
        \cpuregs[14][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][17]  ( .D(n3381), .CLK(clk), .Q(
        \cpuregs[13][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][17]  ( .D(n3380), .CLK(clk), .Q(
        \cpuregs[12][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][17]  ( .D(n3379), .CLK(clk), .Q(
        \cpuregs[11][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][17]  ( .D(n3378), .CLK(clk), .Q(
        \cpuregs[10][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][17]  ( .D(n3377), .CLK(clk), .Q(
        \cpuregs[9][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][17]  ( .D(n3376), .CLK(clk), .Q(
        \cpuregs[8][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][17]  ( .D(n3375), .CLK(clk), .Q(
        \cpuregs[7][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][17]  ( .D(n3374), .CLK(clk), .Q(
        \cpuregs[6][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][17]  ( .D(n3373), .CLK(clk), .Q(
        \cpuregs[5][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][17]  ( .D(n3372), .CLK(clk), .Q(
        \cpuregs[4][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][17]  ( .D(n3371), .CLK(clk), .Q(
        \cpuregs[3][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][17]  ( .D(n3370), .CLK(clk), .Q(
        \cpuregs[2][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][17]  ( .D(n3369), .CLK(clk), .Q(
        \cpuregs[1][17] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[17]  ( .D(alu_out[17]), .CLK(clk), 
        .Q(alu_out_q[17]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[17]  ( .D(n4034), .CLK(clk), .Q(
        reg_next_pc[17]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[17]  ( .D(n4002), .CLK(clk), .Q(
        reg_pc[17]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[18]  ( .D(N1895), .CLK(clk), .Q(
        reg_out[18]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][18]  ( .D(n3368), .CLK(clk), .Q(
        \cpuregs[31][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][18]  ( .D(n3367), .CLK(clk), .Q(
        \cpuregs[30][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][18]  ( .D(n3366), .CLK(clk), .Q(
        \cpuregs[29][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][18]  ( .D(n3365), .CLK(clk), .Q(
        \cpuregs[28][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][18]  ( .D(n3364), .CLK(clk), .Q(
        \cpuregs[27][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][18]  ( .D(n3363), .CLK(clk), .Q(
        \cpuregs[26][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][18]  ( .D(n3362), .CLK(clk), .Q(
        \cpuregs[25][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][18]  ( .D(n3361), .CLK(clk), .Q(
        \cpuregs[24][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][18]  ( .D(n3360), .CLK(clk), .Q(
        \cpuregs[23][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][18]  ( .D(n3359), .CLK(clk), .Q(
        \cpuregs[22][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][18]  ( .D(n3358), .CLK(clk), .Q(
        \cpuregs[21][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][18]  ( .D(n3357), .CLK(clk), .Q(
        \cpuregs[20][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][18]  ( .D(n3356), .CLK(clk), .Q(
        \cpuregs[19][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][18]  ( .D(n3355), .CLK(clk), .Q(
        \cpuregs[18][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][18]  ( .D(n3354), .CLK(clk), .Q(
        \cpuregs[17][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][18]  ( .D(n3353), .CLK(clk), .Q(
        \cpuregs[16][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][18]  ( .D(n3352), .CLK(clk), .Q(
        \cpuregs[15][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][18]  ( .D(n3351), .CLK(clk), .Q(
        \cpuregs[14][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][18]  ( .D(n3350), .CLK(clk), .Q(
        \cpuregs[13][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][18]  ( .D(n3349), .CLK(clk), .Q(
        \cpuregs[12][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][18]  ( .D(n3348), .CLK(clk), .Q(
        \cpuregs[11][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][18]  ( .D(n3347), .CLK(clk), .Q(
        \cpuregs[10][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][18]  ( .D(n3346), .CLK(clk), .Q(
        \cpuregs[9][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][18]  ( .D(n3345), .CLK(clk), .Q(
        \cpuregs[8][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][18]  ( .D(n3344), .CLK(clk), .Q(
        \cpuregs[7][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][18]  ( .D(n3343), .CLK(clk), .Q(
        \cpuregs[6][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][18]  ( .D(n3342), .CLK(clk), .Q(
        \cpuregs[5][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][18]  ( .D(n3341), .CLK(clk), .Q(
        \cpuregs[4][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][18]  ( .D(n3340), .CLK(clk), .Q(
        \cpuregs[3][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][18]  ( .D(n3339), .CLK(clk), .Q(
        \cpuregs[2][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][18]  ( .D(n3338), .CLK(clk), .Q(
        \cpuregs[1][18] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[18]  ( .D(alu_out[18]), .CLK(clk), 
        .Q(alu_out_q[18]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[18]  ( .D(n4033), .CLK(clk), .Q(
        reg_next_pc[18]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[18]  ( .D(n4001), .CLK(clk), .Q(
        reg_pc[18]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[19]  ( .D(N1896), .CLK(clk), .Q(
        reg_out[19]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][19]  ( .D(n3337), .CLK(clk), .Q(
        \cpuregs[31][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][19]  ( .D(n3336), .CLK(clk), .Q(
        \cpuregs[30][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][19]  ( .D(n3335), .CLK(clk), .Q(
        \cpuregs[29][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][19]  ( .D(n3334), .CLK(clk), .Q(
        \cpuregs[28][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][19]  ( .D(n3333), .CLK(clk), .Q(
        \cpuregs[27][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][19]  ( .D(n3332), .CLK(clk), .Q(
        \cpuregs[26][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][19]  ( .D(n3331), .CLK(clk), .Q(
        \cpuregs[25][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][19]  ( .D(n3330), .CLK(clk), .Q(
        \cpuregs[24][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][19]  ( .D(n3329), .CLK(clk), .Q(
        \cpuregs[23][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][19]  ( .D(n3328), .CLK(clk), .Q(
        \cpuregs[22][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][19]  ( .D(n3327), .CLK(clk), .Q(
        \cpuregs[21][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][19]  ( .D(n3326), .CLK(clk), .Q(
        \cpuregs[20][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][19]  ( .D(n3325), .CLK(clk), .Q(
        \cpuregs[19][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][19]  ( .D(n3324), .CLK(clk), .Q(
        \cpuregs[18][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][19]  ( .D(n3323), .CLK(clk), .Q(
        \cpuregs[17][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][19]  ( .D(n3322), .CLK(clk), .Q(
        \cpuregs[16][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][19]  ( .D(n3321), .CLK(clk), .Q(
        \cpuregs[15][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][19]  ( .D(n3320), .CLK(clk), .Q(
        \cpuregs[14][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][19]  ( .D(n3319), .CLK(clk), .Q(
        \cpuregs[13][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][19]  ( .D(n3318), .CLK(clk), .Q(
        \cpuregs[12][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][19]  ( .D(n3317), .CLK(clk), .Q(
        \cpuregs[11][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][19]  ( .D(n3316), .CLK(clk), .Q(
        \cpuregs[10][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][19]  ( .D(n3315), .CLK(clk), .Q(
        \cpuregs[9][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][19]  ( .D(n3314), .CLK(clk), .Q(
        \cpuregs[8][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][19]  ( .D(n3313), .CLK(clk), .Q(
        \cpuregs[7][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][19]  ( .D(n3312), .CLK(clk), .Q(
        \cpuregs[6][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][19]  ( .D(n3311), .CLK(clk), .Q(
        \cpuregs[5][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][19]  ( .D(n3310), .CLK(clk), .Q(
        \cpuregs[4][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][19]  ( .D(n3309), .CLK(clk), .Q(
        \cpuregs[3][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][19]  ( .D(n3308), .CLK(clk), .Q(
        \cpuregs[2][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][19]  ( .D(n3307), .CLK(clk), .Q(
        \cpuregs[1][19] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[19]  ( .D(alu_out[19]), .CLK(clk), 
        .Q(alu_out_q[19]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[19]  ( .D(n4032), .CLK(clk), .Q(
        reg_next_pc[19]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[19]  ( .D(n4000), .CLK(clk), .Q(
        reg_pc[19]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[20]  ( .D(N1897), .CLK(clk), .Q(
        reg_out[20]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[21]  ( .D(N1898), .CLK(clk), .Q(
        reg_out[21]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[22]  ( .D(N1899), .CLK(clk), .Q(
        reg_out[22]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[23]  ( .D(N1900), .CLK(clk), .Q(
        reg_out[23]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[24]  ( .D(N1901), .CLK(clk), .Q(
        reg_out[24]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[25]  ( .D(N1902), .CLK(clk), .Q(
        reg_out[25]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[26]  ( .D(N1903), .CLK(clk), .Q(
        reg_out[26]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[27]  ( .D(N1904), .CLK(clk), .Q(
        reg_out[27]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[28]  ( .D(N1905), .CLK(clk), .Q(
        reg_out[28]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[29]  ( .D(N1906), .CLK(clk), .Q(
        reg_out[29]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[30]  ( .D(N1907), .CLK(clk), .Q(
        reg_out[30]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[31]  ( .D(N1908), .CLK(clk), .Q(
        reg_out[31]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[6]  ( .D(N1883), .CLK(clk), .Q(
        reg_out[6]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][6]  ( .D(n3740), .CLK(clk), .Q(
        \cpuregs[31][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][6]  ( .D(n3739), .CLK(clk), .Q(
        \cpuregs[30][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][6]  ( .D(n3738), .CLK(clk), .Q(
        \cpuregs[29][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][6]  ( .D(n3737), .CLK(clk), .Q(
        \cpuregs[28][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][6]  ( .D(n3736), .CLK(clk), .Q(
        \cpuregs[27][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][6]  ( .D(n3735), .CLK(clk), .Q(
        \cpuregs[26][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][6]  ( .D(n3734), .CLK(clk), .Q(
        \cpuregs[25][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][6]  ( .D(n3733), .CLK(clk), .Q(
        \cpuregs[24][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][6]  ( .D(n3732), .CLK(clk), .Q(
        \cpuregs[23][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][6]  ( .D(n3731), .CLK(clk), .Q(
        \cpuregs[22][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][6]  ( .D(n3730), .CLK(clk), .Q(
        \cpuregs[21][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][6]  ( .D(n3729), .CLK(clk), .Q(
        \cpuregs[20][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][6]  ( .D(n3728), .CLK(clk), .Q(
        \cpuregs[19][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][6]  ( .D(n3727), .CLK(clk), .Q(
        \cpuregs[18][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][6]  ( .D(n3726), .CLK(clk), .Q(
        \cpuregs[17][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][6]  ( .D(n3725), .CLK(clk), .Q(
        \cpuregs[16][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][6]  ( .D(n3724), .CLK(clk), .Q(
        \cpuregs[15][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][6]  ( .D(n3723), .CLK(clk), .Q(
        \cpuregs[14][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][6]  ( .D(n3722), .CLK(clk), .Q(
        \cpuregs[13][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][6]  ( .D(n3721), .CLK(clk), .Q(
        \cpuregs[12][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][6]  ( .D(n3720), .CLK(clk), .Q(
        \cpuregs[11][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][6]  ( .D(n3719), .CLK(clk), .Q(
        \cpuregs[10][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][6]  ( .D(n3718), .CLK(clk), .Q(
        \cpuregs[9][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][6]  ( .D(n3717), .CLK(clk), .Q(
        \cpuregs[8][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][6]  ( .D(n3716), .CLK(clk), .Q(
        \cpuregs[7][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][6]  ( .D(n3715), .CLK(clk), .Q(
        \cpuregs[6][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][6]  ( .D(n3714), .CLK(clk), .Q(
        \cpuregs[5][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][6]  ( .D(n3713), .CLK(clk), .Q(
        \cpuregs[4][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][6]  ( .D(n3712), .CLK(clk), .Q(
        \cpuregs[3][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][6]  ( .D(n3711), .CLK(clk), .Q(
        \cpuregs[2][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][6]  ( .D(n3710), .CLK(clk), .Q(
        \cpuregs[1][6] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[6]  ( .D(alu_out[6]), .CLK(clk), .Q(
        alu_out_q[6]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[6]  ( .D(n4045), .CLK(clk), .Q(
        reg_next_pc[6]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[6]  ( .D(n4013), .CLK(clk), .Q(
        reg_pc[6]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[5]  ( .D(N1882), .CLK(clk), .Q(
        reg_out[5]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][5]  ( .D(n3771), .CLK(clk), .Q(
        \cpuregs[31][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][5]  ( .D(n3770), .CLK(clk), .Q(
        \cpuregs[30][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][5]  ( .D(n3769), .CLK(clk), .Q(
        \cpuregs[29][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][5]  ( .D(n3768), .CLK(clk), .Q(
        \cpuregs[28][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][5]  ( .D(n3767), .CLK(clk), .Q(
        \cpuregs[27][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][5]  ( .D(n3766), .CLK(clk), .Q(
        \cpuregs[26][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][5]  ( .D(n3765), .CLK(clk), .Q(
        \cpuregs[25][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][5]  ( .D(n3764), .CLK(clk), .Q(
        \cpuregs[24][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][5]  ( .D(n3763), .CLK(clk), .Q(
        \cpuregs[23][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][5]  ( .D(n3762), .CLK(clk), .Q(
        \cpuregs[22][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][5]  ( .D(n3761), .CLK(clk), .Q(
        \cpuregs[21][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][5]  ( .D(n3760), .CLK(clk), .Q(
        \cpuregs[20][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][5]  ( .D(n3759), .CLK(clk), .Q(
        \cpuregs[19][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][5]  ( .D(n3758), .CLK(clk), .Q(
        \cpuregs[18][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][5]  ( .D(n3757), .CLK(clk), .Q(
        \cpuregs[17][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][5]  ( .D(n3756), .CLK(clk), .Q(
        \cpuregs[16][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][5]  ( .D(n3755), .CLK(clk), .Q(
        \cpuregs[15][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][5]  ( .D(n3754), .CLK(clk), .Q(
        \cpuregs[14][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][5]  ( .D(n3753), .CLK(clk), .Q(
        \cpuregs[13][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][5]  ( .D(n3752), .CLK(clk), .Q(
        \cpuregs[12][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][5]  ( .D(n3751), .CLK(clk), .Q(
        \cpuregs[11][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][5]  ( .D(n3750), .CLK(clk), .Q(
        \cpuregs[10][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][5]  ( .D(n3749), .CLK(clk), .Q(
        \cpuregs[9][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][5]  ( .D(n3748), .CLK(clk), .Q(
        \cpuregs[8][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][5]  ( .D(n3747), .CLK(clk), .Q(
        \cpuregs[7][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][5]  ( .D(n3746), .CLK(clk), .Q(
        \cpuregs[6][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][5]  ( .D(n3745), .CLK(clk), .Q(
        \cpuregs[5][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][5]  ( .D(n3744), .CLK(clk), .Q(
        \cpuregs[4][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][5]  ( .D(n3743), .CLK(clk), .Q(
        \cpuregs[3][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][5]  ( .D(n3742), .CLK(clk), .Q(
        \cpuregs[2][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][5]  ( .D(n3741), .CLK(clk), .Q(
        \cpuregs[1][5] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[5]  ( .D(alu_out[5]), .CLK(clk), .Q(
        alu_out_q[5]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[5]  ( .D(n4046), .CLK(clk), .Q(
        reg_next_pc[5]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[5]  ( .D(n4014), .CLK(clk), .Q(
        reg_pc[5]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[4]  ( .D(N1881), .CLK(clk), .Q(
        reg_out[4]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][4]  ( .D(n3802), .CLK(clk), .Q(
        \cpuregs[31][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][4]  ( .D(n3801), .CLK(clk), .Q(
        \cpuregs[30][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][4]  ( .D(n3800), .CLK(clk), .Q(
        \cpuregs[29][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][4]  ( .D(n3799), .CLK(clk), .Q(
        \cpuregs[28][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][4]  ( .D(n3798), .CLK(clk), .Q(
        \cpuregs[27][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][4]  ( .D(n3797), .CLK(clk), .Q(
        \cpuregs[26][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][4]  ( .D(n3796), .CLK(clk), .Q(
        \cpuregs[25][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][4]  ( .D(n3795), .CLK(clk), .Q(
        \cpuregs[24][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][4]  ( .D(n3794), .CLK(clk), .Q(
        \cpuregs[23][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][4]  ( .D(n3793), .CLK(clk), .Q(
        \cpuregs[22][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][4]  ( .D(n3792), .CLK(clk), .Q(
        \cpuregs[21][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][4]  ( .D(n3791), .CLK(clk), .Q(
        \cpuregs[20][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][4]  ( .D(n3790), .CLK(clk), .Q(
        \cpuregs[19][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][4]  ( .D(n3789), .CLK(clk), .Q(
        \cpuregs[18][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][4]  ( .D(n3788), .CLK(clk), .Q(
        \cpuregs[17][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][4]  ( .D(n3787), .CLK(clk), .Q(
        \cpuregs[16][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][4]  ( .D(n3786), .CLK(clk), .Q(
        \cpuregs[15][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][4]  ( .D(n3785), .CLK(clk), .Q(
        \cpuregs[14][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][4]  ( .D(n3784), .CLK(clk), .Q(
        \cpuregs[13][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][4]  ( .D(n3783), .CLK(clk), .Q(
        \cpuregs[12][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][4]  ( .D(n3782), .CLK(clk), .Q(
        \cpuregs[11][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][4]  ( .D(n3781), .CLK(clk), .Q(
        \cpuregs[10][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][4]  ( .D(n3780), .CLK(clk), .Q(
        \cpuregs[9][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][4]  ( .D(n3779), .CLK(clk), .Q(
        \cpuregs[8][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][4]  ( .D(n3778), .CLK(clk), .Q(
        \cpuregs[7][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][4]  ( .D(n3777), .CLK(clk), .Q(
        \cpuregs[6][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][4]  ( .D(n3776), .CLK(clk), .Q(
        \cpuregs[5][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][4]  ( .D(n3775), .CLK(clk), .Q(
        \cpuregs[4][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][4]  ( .D(n3774), .CLK(clk), .Q(
        \cpuregs[3][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][4]  ( .D(n3773), .CLK(clk), .Q(
        \cpuregs[2][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][4]  ( .D(n3772), .CLK(clk), .Q(
        \cpuregs[1][4] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[4]  ( .D(alu_out[4]), .CLK(clk), .Q(
        alu_out_q[4]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[4]  ( .D(n4047), .CLK(clk), .Q(
        reg_next_pc[4]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[4]  ( .D(n4015), .CLK(clk), .Q(
        reg_pc[4]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[3]  ( .D(N1880), .CLK(clk), .Q(
        reg_out[3]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][3]  ( .D(n3833), .CLK(clk), .Q(
        \cpuregs[31][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][3]  ( .D(n3832), .CLK(clk), .Q(
        \cpuregs[30][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][3]  ( .D(n3831), .CLK(clk), .Q(
        \cpuregs[29][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][3]  ( .D(n3830), .CLK(clk), .Q(
        \cpuregs[28][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][3]  ( .D(n3829), .CLK(clk), .Q(
        \cpuregs[27][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][3]  ( .D(n3828), .CLK(clk), .Q(
        \cpuregs[26][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][3]  ( .D(n3827), .CLK(clk), .Q(
        \cpuregs[25][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][3]  ( .D(n3826), .CLK(clk), .Q(
        \cpuregs[24][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][3]  ( .D(n3825), .CLK(clk), .Q(
        \cpuregs[23][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][3]  ( .D(n3824), .CLK(clk), .Q(
        \cpuregs[22][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][3]  ( .D(n3823), .CLK(clk), .Q(
        \cpuregs[21][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][3]  ( .D(n3822), .CLK(clk), .Q(
        \cpuregs[20][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][3]  ( .D(n3821), .CLK(clk), .Q(
        \cpuregs[19][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][3]  ( .D(n3820), .CLK(clk), .Q(
        \cpuregs[18][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][3]  ( .D(n3819), .CLK(clk), .Q(
        \cpuregs[17][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][3]  ( .D(n3818), .CLK(clk), .Q(
        \cpuregs[16][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][3]  ( .D(n3817), .CLK(clk), .Q(
        \cpuregs[15][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][3]  ( .D(n3816), .CLK(clk), .Q(
        \cpuregs[14][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][3]  ( .D(n3815), .CLK(clk), .Q(
        \cpuregs[13][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][3]  ( .D(n3814), .CLK(clk), .Q(
        \cpuregs[12][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][3]  ( .D(n3813), .CLK(clk), .Q(
        \cpuregs[11][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][3]  ( .D(n3812), .CLK(clk), .Q(
        \cpuregs[10][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][3]  ( .D(n3811), .CLK(clk), .Q(
        \cpuregs[9][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][3]  ( .D(n3810), .CLK(clk), .Q(
        \cpuregs[8][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][3]  ( .D(n3809), .CLK(clk), .Q(
        \cpuregs[7][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][3]  ( .D(n3808), .CLK(clk), .Q(
        \cpuregs[6][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][3]  ( .D(n3807), .CLK(clk), .Q(
        \cpuregs[5][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][3]  ( .D(n3806), .CLK(clk), .Q(
        \cpuregs[4][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][3]  ( .D(n3805), .CLK(clk), .Q(
        \cpuregs[3][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][3]  ( .D(n3804), .CLK(clk), .Q(
        \cpuregs[2][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][3]  ( .D(n3803), .CLK(clk), .Q(
        \cpuregs[1][3] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[3]  ( .D(alu_out[3]), .CLK(clk), .Q(
        alu_out_q[3]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[3]  ( .D(n4048), .CLK(clk), .Q(
        reg_next_pc[3]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[2]  ( .D(N1879), .CLK(clk), .Q(
        reg_out[2]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][2]  ( .D(n3864), .CLK(clk), .Q(
        \cpuregs[31][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][2]  ( .D(n3863), .CLK(clk), .Q(
        \cpuregs[30][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][2]  ( .D(n3862), .CLK(clk), .Q(
        \cpuregs[29][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][2]  ( .D(n3861), .CLK(clk), .Q(
        \cpuregs[28][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][2]  ( .D(n3860), .CLK(clk), .Q(
        \cpuregs[27][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][2]  ( .D(n3859), .CLK(clk), .Q(
        \cpuregs[26][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][2]  ( .D(n3858), .CLK(clk), .Q(
        \cpuregs[25][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][2]  ( .D(n3857), .CLK(clk), .Q(
        \cpuregs[24][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][2]  ( .D(n3856), .CLK(clk), .Q(
        \cpuregs[23][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][2]  ( .D(n3855), .CLK(clk), .Q(
        \cpuregs[22][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][2]  ( .D(n3854), .CLK(clk), .Q(
        \cpuregs[21][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][2]  ( .D(n3853), .CLK(clk), .Q(
        \cpuregs[20][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][2]  ( .D(n3852), .CLK(clk), .Q(
        \cpuregs[19][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][2]  ( .D(n3851), .CLK(clk), .Q(
        \cpuregs[18][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][2]  ( .D(n3850), .CLK(clk), .Q(
        \cpuregs[17][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][2]  ( .D(n3849), .CLK(clk), .Q(
        \cpuregs[16][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][2]  ( .D(n3848), .CLK(clk), .Q(
        \cpuregs[15][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][2]  ( .D(n3847), .CLK(clk), .Q(
        \cpuregs[14][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][2]  ( .D(n3846), .CLK(clk), .Q(
        \cpuregs[13][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][2]  ( .D(n3845), .CLK(clk), .Q(
        \cpuregs[12][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][2]  ( .D(n3844), .CLK(clk), .Q(
        \cpuregs[11][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][2]  ( .D(n3843), .CLK(clk), .Q(
        \cpuregs[10][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][2]  ( .D(n3842), .CLK(clk), .Q(
        \cpuregs[9][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][2]  ( .D(n3841), .CLK(clk), .Q(
        \cpuregs[8][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][2]  ( .D(n3840), .CLK(clk), .Q(
        \cpuregs[7][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][2]  ( .D(n3839), .CLK(clk), .Q(
        \cpuregs[6][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][2]  ( .D(n3838), .CLK(clk), .Q(
        \cpuregs[5][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][2]  ( .D(n3837), .CLK(clk), .Q(
        \cpuregs[4][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][2]  ( .D(n3836), .CLK(clk), .Q(
        \cpuregs[3][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][2]  ( .D(n3835), .CLK(clk), .Q(
        \cpuregs[2][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][2]  ( .D(n3834), .CLK(clk), .Q(
        \cpuregs[1][2] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[2]  ( .D(alu_out[2]), .CLK(clk), .Q(
        alu_out_q[2]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[2]  ( .D(n4049), .CLK(clk), .Q(
        reg_next_pc[2]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[1]  ( .D(N1878), .CLK(clk), .Q(
        reg_out[1]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][1]  ( .D(n3895), .CLK(clk), .Q(
        \cpuregs[31][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][1]  ( .D(n3894), .CLK(clk), .Q(
        \cpuregs[30][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][1]  ( .D(n3893), .CLK(clk), .Q(
        \cpuregs[29][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][1]  ( .D(n3892), .CLK(clk), .Q(
        \cpuregs[28][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][1]  ( .D(n3891), .CLK(clk), .Q(
        \cpuregs[27][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][1]  ( .D(n3890), .CLK(clk), .Q(
        \cpuregs[26][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][1]  ( .D(n3889), .CLK(clk), .Q(
        \cpuregs[25][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][1]  ( .D(n3888), .CLK(clk), .Q(
        \cpuregs[24][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][1]  ( .D(n3887), .CLK(clk), .Q(
        \cpuregs[23][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][1]  ( .D(n3886), .CLK(clk), .Q(
        \cpuregs[22][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][1]  ( .D(n3885), .CLK(clk), .Q(
        \cpuregs[21][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][1]  ( .D(n3884), .CLK(clk), .Q(
        \cpuregs[20][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][1]  ( .D(n3883), .CLK(clk), .Q(
        \cpuregs[19][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][1]  ( .D(n3882), .CLK(clk), .Q(
        \cpuregs[18][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][1]  ( .D(n3881), .CLK(clk), .Q(
        \cpuregs[17][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][1]  ( .D(n3880), .CLK(clk), .Q(
        \cpuregs[16][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][1]  ( .D(n3879), .CLK(clk), .Q(
        \cpuregs[15][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][1]  ( .D(n3878), .CLK(clk), .Q(
        \cpuregs[14][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][1]  ( .D(n3877), .CLK(clk), .Q(
        \cpuregs[13][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][1]  ( .D(n3876), .CLK(clk), .Q(
        \cpuregs[12][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][1]  ( .D(n3875), .CLK(clk), .Q(
        \cpuregs[11][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][1]  ( .D(n3874), .CLK(clk), .Q(
        \cpuregs[10][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][1]  ( .D(n3873), .CLK(clk), .Q(
        \cpuregs[9][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][1]  ( .D(n3872), .CLK(clk), .Q(
        \cpuregs[8][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][1]  ( .D(n3871), .CLK(clk), .Q(
        \cpuregs[7][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][1]  ( .D(n3870), .CLK(clk), .Q(
        \cpuregs[6][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][1]  ( .D(n3869), .CLK(clk), .Q(
        \cpuregs[5][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][1]  ( .D(n3868), .CLK(clk), .Q(
        \cpuregs[4][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][1]  ( .D(n3867), .CLK(clk), .Q(
        \cpuregs[3][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][1]  ( .D(n3866), .CLK(clk), .Q(
        \cpuregs[2][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][1]  ( .D(n3865), .CLK(clk), .Q(
        \cpuregs[1][1] ) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[1]  ( .D(alu_out[1]), .CLK(clk), .Q(
        alu_out_q[1]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[1]  ( .D(n4050), .CLK(clk), .Q(
        reg_next_pc[1]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[1]  ( .D(n4018), .CLK(clk), .Q(
        reg_pc[1]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_out_reg[0]  ( .D(N1877), .CLK(clk), .Q(
        reg_out[0]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[0]  ( .D(alu_out[0]), .CLK(clk), .Q(
        alu_out_q[0]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][0]  ( .D(n3926), .CLK(clk), .Q(
        \cpuregs[31][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][0]  ( .D(n3925), .CLK(clk), .Q(
        \cpuregs[30][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][0]  ( .D(n3924), .CLK(clk), .Q(
        \cpuregs[29][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][0]  ( .D(n3923), .CLK(clk), .Q(
        \cpuregs[28][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][0]  ( .D(n3922), .CLK(clk), .Q(
        \cpuregs[27][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][0]  ( .D(n3921), .CLK(clk), .Q(
        \cpuregs[26][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][0]  ( .D(n3920), .CLK(clk), .Q(
        \cpuregs[25][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][0]  ( .D(n3919), .CLK(clk), .Q(
        \cpuregs[24][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][0]  ( .D(n3918), .CLK(clk), .Q(
        \cpuregs[23][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][0]  ( .D(n3917), .CLK(clk), .Q(
        \cpuregs[22][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][0]  ( .D(n3916), .CLK(clk), .Q(
        \cpuregs[21][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][0]  ( .D(n3915), .CLK(clk), .Q(
        \cpuregs[20][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][0]  ( .D(n3914), .CLK(clk), .Q(
        \cpuregs[19][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][0]  ( .D(n3913), .CLK(clk), .Q(
        \cpuregs[18][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][0]  ( .D(n3912), .CLK(clk), .Q(
        \cpuregs[17][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][0]  ( .D(n3911), .CLK(clk), .Q(
        \cpuregs[16][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][0]  ( .D(n3910), .CLK(clk), .Q(
        \cpuregs[15][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][0]  ( .D(n3909), .CLK(clk), .Q(
        \cpuregs[14][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][0]  ( .D(n3908), .CLK(clk), .Q(
        \cpuregs[13][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][0]  ( .D(n3907), .CLK(clk), .Q(
        \cpuregs[12][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][0]  ( .D(n3906), .CLK(clk), .Q(
        \cpuregs[11][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][0]  ( .D(n3905), .CLK(clk), .Q(
        \cpuregs[10][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][0]  ( .D(n3904), .CLK(clk), .Q(
        \cpuregs[9][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][0]  ( .D(n3903), .CLK(clk), .Q(
        \cpuregs[8][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][0]  ( .D(n3902), .CLK(clk), .Q(
        \cpuregs[7][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][0]  ( .D(n3901), .CLK(clk), .Q(
        \cpuregs[6][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][0]  ( .D(n3900), .CLK(clk), .Q(
        \cpuregs[5][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][0]  ( .D(n3899), .CLK(clk), .Q(
        \cpuregs[4][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][0]  ( .D(n3898), .CLK(clk), .Q(
        \cpuregs[3][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][0]  ( .D(n3897), .CLK(clk), .Q(
        \cpuregs[2][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][0]  ( .D(n3896), .CLK(clk), .Q(
        \cpuregs[1][0] ) );
  sky130_fd_sc_hd__dfxtp_1 \reg_sh_reg[0]  ( .D(N1909), .CLK(clk), .Q(N1570)
         );
  sky130_fd_sc_hd__dfxtp_1 \reg_sh_reg[4]  ( .D(N1913), .CLK(clk), .Q(
        reg_sh[4]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_sh_reg[1]  ( .D(N1910), .CLK(clk), .Q(N1571)
         );
  sky130_fd_sc_hd__dfxtp_1 \reg_sh_reg[2]  ( .D(N1911), .CLK(clk), .Q(
        reg_sh[2]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_sh_reg[3]  ( .D(N1912), .CLK(clk), .Q(
        reg_sh[3]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[0]  ( .D(n3958), .CLK(clk), .Q(
        pcpi_rs2[0]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[31]  ( .D(n2872), .CLK(clk), .Q(
        decoded_imm_j[31]) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[20]  ( .D(n2852), .CLK(clk), .Q(
        decoded_imm[20]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[20]  ( .D(alu_out[20]), .CLK(clk), 
        .Q(alu_out_q[20]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[20]  ( .D(n4031), .CLK(clk), .Q(
        reg_next_pc[20]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[20]  ( .D(n3999), .CLK(clk), .Q(
        reg_pc[20]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][20]  ( .D(n3306), .CLK(clk), .Q(
        \cpuregs[31][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][20]  ( .D(n3305), .CLK(clk), .Q(
        \cpuregs[30][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][20]  ( .D(n3304), .CLK(clk), .Q(
        \cpuregs[29][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][20]  ( .D(n3303), .CLK(clk), .Q(
        \cpuregs[28][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][20]  ( .D(n3302), .CLK(clk), .Q(
        \cpuregs[27][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][20]  ( .D(n3301), .CLK(clk), .Q(
        \cpuregs[26][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][20]  ( .D(n3300), .CLK(clk), .Q(
        \cpuregs[25][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][20]  ( .D(n3299), .CLK(clk), .Q(
        \cpuregs[24][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][20]  ( .D(n3298), .CLK(clk), .Q(
        \cpuregs[23][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][20]  ( .D(n3297), .CLK(clk), .Q(
        \cpuregs[22][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][20]  ( .D(n3296), .CLK(clk), .Q(
        \cpuregs[21][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][20]  ( .D(n3295), .CLK(clk), .Q(
        \cpuregs[20][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][20]  ( .D(n3294), .CLK(clk), .Q(
        \cpuregs[19][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][20]  ( .D(n3293), .CLK(clk), .Q(
        \cpuregs[18][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][20]  ( .D(n3292), .CLK(clk), .Q(
        \cpuregs[17][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][20]  ( .D(n3291), .CLK(clk), .Q(
        \cpuregs[16][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][20]  ( .D(n3290), .CLK(clk), .Q(
        \cpuregs[15][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][20]  ( .D(n3289), .CLK(clk), .Q(
        \cpuregs[14][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][20]  ( .D(n3288), .CLK(clk), .Q(
        \cpuregs[13][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][20]  ( .D(n3287), .CLK(clk), .Q(
        \cpuregs[12][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][20]  ( .D(n3286), .CLK(clk), .Q(
        \cpuregs[11][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][20]  ( .D(n3285), .CLK(clk), .Q(
        \cpuregs[10][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][20]  ( .D(n3284), .CLK(clk), .Q(
        \cpuregs[9][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][20]  ( .D(n3283), .CLK(clk), .Q(
        \cpuregs[8][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][20]  ( .D(n3282), .CLK(clk), .Q(
        \cpuregs[7][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][20]  ( .D(n3281), .CLK(clk), .Q(
        \cpuregs[6][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][20]  ( .D(n3280), .CLK(clk), .Q(
        \cpuregs[5][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][20]  ( .D(n3279), .CLK(clk), .Q(
        \cpuregs[4][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][20]  ( .D(n3278), .CLK(clk), .Q(
        \cpuregs[3][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][20]  ( .D(n3277), .CLK(clk), .Q(
        \cpuregs[2][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][20]  ( .D(n3276), .CLK(clk), .Q(
        \cpuregs[1][20] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[21]  ( .D(n2851), .CLK(clk), .Q(
        decoded_imm[21]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[21]  ( .D(alu_out[21]), .CLK(clk), 
        .Q(alu_out_q[21]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[21]  ( .D(n5239), .CLK(clk), .Q(
        reg_next_pc[21]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[21]  ( .D(n3998), .CLK(clk), .Q(
        reg_pc[21]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][21]  ( .D(n3275), .CLK(clk), .Q(
        \cpuregs[31][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][21]  ( .D(n3274), .CLK(clk), .Q(
        \cpuregs[30][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][21]  ( .D(n3273), .CLK(clk), .Q(
        \cpuregs[29][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][21]  ( .D(n3272), .CLK(clk), .Q(
        \cpuregs[28][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][21]  ( .D(n3271), .CLK(clk), .Q(
        \cpuregs[27][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][21]  ( .D(n3270), .CLK(clk), .Q(
        \cpuregs[26][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][21]  ( .D(n3269), .CLK(clk), .Q(
        \cpuregs[25][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][21]  ( .D(n3268), .CLK(clk), .Q(
        \cpuregs[24][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][21]  ( .D(n3267), .CLK(clk), .Q(
        \cpuregs[23][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][21]  ( .D(n3266), .CLK(clk), .Q(
        \cpuregs[22][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][21]  ( .D(n3265), .CLK(clk), .Q(
        \cpuregs[21][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][21]  ( .D(n3264), .CLK(clk), .Q(
        \cpuregs[20][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][21]  ( .D(n3263), .CLK(clk), .Q(
        \cpuregs[19][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][21]  ( .D(n3262), .CLK(clk), .Q(
        \cpuregs[18][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][21]  ( .D(n3261), .CLK(clk), .Q(
        \cpuregs[17][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][21]  ( .D(n3260), .CLK(clk), .Q(
        \cpuregs[16][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][21]  ( .D(n3259), .CLK(clk), .Q(
        \cpuregs[15][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][21]  ( .D(n3258), .CLK(clk), .Q(
        \cpuregs[14][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][21]  ( .D(n3257), .CLK(clk), .Q(
        \cpuregs[13][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][21]  ( .D(n3256), .CLK(clk), .Q(
        \cpuregs[12][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][21]  ( .D(n3255), .CLK(clk), .Q(
        \cpuregs[11][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][21]  ( .D(n3254), .CLK(clk), .Q(
        \cpuregs[10][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][21]  ( .D(n3253), .CLK(clk), .Q(
        \cpuregs[9][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][21]  ( .D(n3252), .CLK(clk), .Q(
        \cpuregs[8][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][21]  ( .D(n3251), .CLK(clk), .Q(
        \cpuregs[7][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][21]  ( .D(n3250), .CLK(clk), .Q(
        \cpuregs[6][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][21]  ( .D(n3249), .CLK(clk), .Q(
        \cpuregs[5][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][21]  ( .D(n3248), .CLK(clk), .Q(
        \cpuregs[4][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][21]  ( .D(n3247), .CLK(clk), .Q(
        \cpuregs[3][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][21]  ( .D(n3246), .CLK(clk), .Q(
        \cpuregs[2][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][21]  ( .D(n3245), .CLK(clk), .Q(
        \cpuregs[1][21] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[22]  ( .D(n2850), .CLK(clk), .Q(
        decoded_imm[22]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[22]  ( .D(alu_out[22]), .CLK(clk), 
        .Q(alu_out_q[22]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[22]  ( .D(n4029), .CLK(clk), .Q(
        reg_next_pc[22]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[22]  ( .D(n3997), .CLK(clk), .Q(
        reg_pc[22]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][22]  ( .D(n3244), .CLK(clk), .Q(
        \cpuregs[31][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][22]  ( .D(n3243), .CLK(clk), .Q(
        \cpuregs[30][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][22]  ( .D(n3242), .CLK(clk), .Q(
        \cpuregs[29][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][22]  ( .D(n3241), .CLK(clk), .Q(
        \cpuregs[28][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][22]  ( .D(n3240), .CLK(clk), .Q(
        \cpuregs[27][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][22]  ( .D(n3239), .CLK(clk), .Q(
        \cpuregs[26][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][22]  ( .D(n3238), .CLK(clk), .Q(
        \cpuregs[25][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][22]  ( .D(n3237), .CLK(clk), .Q(
        \cpuregs[24][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][22]  ( .D(n3236), .CLK(clk), .Q(
        \cpuregs[23][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][22]  ( .D(n3235), .CLK(clk), .Q(
        \cpuregs[22][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][22]  ( .D(n3234), .CLK(clk), .Q(
        \cpuregs[21][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][22]  ( .D(n3233), .CLK(clk), .Q(
        \cpuregs[20][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][22]  ( .D(n3232), .CLK(clk), .Q(
        \cpuregs[19][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][22]  ( .D(n3231), .CLK(clk), .Q(
        \cpuregs[18][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][22]  ( .D(n3230), .CLK(clk), .Q(
        \cpuregs[17][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][22]  ( .D(n3229), .CLK(clk), .Q(
        \cpuregs[16][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][22]  ( .D(n3228), .CLK(clk), .Q(
        \cpuregs[15][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][22]  ( .D(n3227), .CLK(clk), .Q(
        \cpuregs[14][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][22]  ( .D(n3226), .CLK(clk), .Q(
        \cpuregs[13][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][22]  ( .D(n3225), .CLK(clk), .Q(
        \cpuregs[12][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][22]  ( .D(n3224), .CLK(clk), .Q(
        \cpuregs[11][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][22]  ( .D(n3223), .CLK(clk), .Q(
        \cpuregs[10][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][22]  ( .D(n3222), .CLK(clk), .Q(
        \cpuregs[9][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][22]  ( .D(n3221), .CLK(clk), .Q(
        \cpuregs[8][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][22]  ( .D(n3220), .CLK(clk), .Q(
        \cpuregs[7][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][22]  ( .D(n3219), .CLK(clk), .Q(
        \cpuregs[6][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][22]  ( .D(n3218), .CLK(clk), .Q(
        \cpuregs[5][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][22]  ( .D(n3217), .CLK(clk), .Q(
        \cpuregs[4][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][22]  ( .D(n3216), .CLK(clk), .Q(
        \cpuregs[3][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][22]  ( .D(n3215), .CLK(clk), .Q(
        \cpuregs[2][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][22]  ( .D(n3214), .CLK(clk), .Q(
        \cpuregs[1][22] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[23]  ( .D(n2849), .CLK(clk), .Q(
        decoded_imm[23]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[23]  ( .D(alu_out[23]), .CLK(clk), 
        .Q(alu_out_q[23]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[23]  ( .D(n4028), .CLK(clk), .Q(
        reg_next_pc[23]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[23]  ( .D(n3996), .CLK(clk), .Q(
        reg_pc[23]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][23]  ( .D(n3213), .CLK(clk), .Q(
        \cpuregs[31][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][23]  ( .D(n3212), .CLK(clk), .Q(
        \cpuregs[30][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][23]  ( .D(n3211), .CLK(clk), .Q(
        \cpuregs[29][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][23]  ( .D(n3210), .CLK(clk), .Q(
        \cpuregs[28][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][23]  ( .D(n3209), .CLK(clk), .Q(
        \cpuregs[27][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][23]  ( .D(n3208), .CLK(clk), .Q(
        \cpuregs[26][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][23]  ( .D(n3207), .CLK(clk), .Q(
        \cpuregs[25][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][23]  ( .D(n3206), .CLK(clk), .Q(
        \cpuregs[24][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][23]  ( .D(n3205), .CLK(clk), .Q(
        \cpuregs[23][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][23]  ( .D(n3204), .CLK(clk), .Q(
        \cpuregs[22][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][23]  ( .D(n3203), .CLK(clk), .Q(
        \cpuregs[21][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][23]  ( .D(n3202), .CLK(clk), .Q(
        \cpuregs[20][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][23]  ( .D(n3201), .CLK(clk), .Q(
        \cpuregs[19][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][23]  ( .D(n3200), .CLK(clk), .Q(
        \cpuregs[18][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][23]  ( .D(n3199), .CLK(clk), .Q(
        \cpuregs[17][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][23]  ( .D(n3198), .CLK(clk), .Q(
        \cpuregs[16][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][23]  ( .D(n3197), .CLK(clk), .Q(
        \cpuregs[15][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][23]  ( .D(n3196), .CLK(clk), .Q(
        \cpuregs[14][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][23]  ( .D(n3195), .CLK(clk), .Q(
        \cpuregs[13][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][23]  ( .D(n3194), .CLK(clk), .Q(
        \cpuregs[12][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][23]  ( .D(n3193), .CLK(clk), .Q(
        \cpuregs[11][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][23]  ( .D(n3192), .CLK(clk), .Q(
        \cpuregs[10][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][23]  ( .D(n3191), .CLK(clk), .Q(
        \cpuregs[9][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][23]  ( .D(n3190), .CLK(clk), .Q(
        \cpuregs[8][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][23]  ( .D(n3189), .CLK(clk), .Q(
        \cpuregs[7][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][23]  ( .D(n3188), .CLK(clk), .Q(
        \cpuregs[6][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][23]  ( .D(n3187), .CLK(clk), .Q(
        \cpuregs[5][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][23]  ( .D(n3186), .CLK(clk), .Q(
        \cpuregs[4][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][23]  ( .D(n3185), .CLK(clk), .Q(
        \cpuregs[3][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][23]  ( .D(n3184), .CLK(clk), .Q(
        \cpuregs[2][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][23]  ( .D(n3183), .CLK(clk), .Q(
        \cpuregs[1][23] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[24]  ( .D(n2848), .CLK(clk), .Q(
        decoded_imm[24]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[24]  ( .D(alu_out[24]), .CLK(clk), 
        .Q(alu_out_q[24]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[24]  ( .D(n4027), .CLK(clk), .Q(
        reg_next_pc[24]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[24]  ( .D(n3995), .CLK(clk), .Q(
        reg_pc[24]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][24]  ( .D(n3182), .CLK(clk), .Q(
        \cpuregs[31][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][24]  ( .D(n3181), .CLK(clk), .Q(
        \cpuregs[30][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][24]  ( .D(n3180), .CLK(clk), .Q(
        \cpuregs[29][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][24]  ( .D(n3179), .CLK(clk), .Q(
        \cpuregs[28][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][24]  ( .D(n3178), .CLK(clk), .Q(
        \cpuregs[27][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][24]  ( .D(n3177), .CLK(clk), .Q(
        \cpuregs[26][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][24]  ( .D(n3176), .CLK(clk), .Q(
        \cpuregs[25][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][24]  ( .D(n3175), .CLK(clk), .Q(
        \cpuregs[24][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][24]  ( .D(n3174), .CLK(clk), .Q(
        \cpuregs[23][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][24]  ( .D(n3173), .CLK(clk), .Q(
        \cpuregs[22][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][24]  ( .D(n3172), .CLK(clk), .Q(
        \cpuregs[21][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][24]  ( .D(n3171), .CLK(clk), .Q(
        \cpuregs[20][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][24]  ( .D(n3170), .CLK(clk), .Q(
        \cpuregs[19][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][24]  ( .D(n3169), .CLK(clk), .Q(
        \cpuregs[18][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][24]  ( .D(n3168), .CLK(clk), .Q(
        \cpuregs[17][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][24]  ( .D(n3167), .CLK(clk), .Q(
        \cpuregs[16][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][24]  ( .D(n3166), .CLK(clk), .Q(
        \cpuregs[15][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][24]  ( .D(n3165), .CLK(clk), .Q(
        \cpuregs[14][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][24]  ( .D(n3164), .CLK(clk), .Q(
        \cpuregs[13][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][24]  ( .D(n3163), .CLK(clk), .Q(
        \cpuregs[12][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][24]  ( .D(n3162), .CLK(clk), .Q(
        \cpuregs[11][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][24]  ( .D(n3161), .CLK(clk), .Q(
        \cpuregs[10][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][24]  ( .D(n3160), .CLK(clk), .Q(
        \cpuregs[9][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][24]  ( .D(n3159), .CLK(clk), .Q(
        \cpuregs[8][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][24]  ( .D(n3158), .CLK(clk), .Q(
        \cpuregs[7][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][24]  ( .D(n3157), .CLK(clk), .Q(
        \cpuregs[6][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][24]  ( .D(n3156), .CLK(clk), .Q(
        \cpuregs[5][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][24]  ( .D(n3155), .CLK(clk), .Q(
        \cpuregs[4][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][24]  ( .D(n3154), .CLK(clk), .Q(
        \cpuregs[3][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][24]  ( .D(n3153), .CLK(clk), .Q(
        \cpuregs[2][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][24]  ( .D(n3152), .CLK(clk), .Q(
        \cpuregs[1][24] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[25]  ( .D(n2847), .CLK(clk), .Q(
        decoded_imm[25]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[25]  ( .D(alu_out[25]), .CLK(clk), 
        .Q(alu_out_q[25]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[25]  ( .D(n4026), .CLK(clk), .Q(
        reg_next_pc[25]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[25]  ( .D(n3994), .CLK(clk), .Q(
        reg_pc[25]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][25]  ( .D(n3151), .CLK(clk), .Q(
        \cpuregs[31][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][25]  ( .D(n3150), .CLK(clk), .Q(
        \cpuregs[30][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][25]  ( .D(n3149), .CLK(clk), .Q(
        \cpuregs[29][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][25]  ( .D(n3148), .CLK(clk), .Q(
        \cpuregs[28][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][25]  ( .D(n3147), .CLK(clk), .Q(
        \cpuregs[27][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][25]  ( .D(n3146), .CLK(clk), .Q(
        \cpuregs[26][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][25]  ( .D(n3145), .CLK(clk), .Q(
        \cpuregs[25][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][25]  ( .D(n3144), .CLK(clk), .Q(
        \cpuregs[24][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][25]  ( .D(n3143), .CLK(clk), .Q(
        \cpuregs[23][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][25]  ( .D(n3142), .CLK(clk), .Q(
        \cpuregs[22][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][25]  ( .D(n3141), .CLK(clk), .Q(
        \cpuregs[21][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][25]  ( .D(n3140), .CLK(clk), .Q(
        \cpuregs[20][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][25]  ( .D(n3139), .CLK(clk), .Q(
        \cpuregs[19][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][25]  ( .D(n3138), .CLK(clk), .Q(
        \cpuregs[18][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][25]  ( .D(n3137), .CLK(clk), .Q(
        \cpuregs[17][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][25]  ( .D(n3136), .CLK(clk), .Q(
        \cpuregs[16][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][25]  ( .D(n3135), .CLK(clk), .Q(
        \cpuregs[15][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][25]  ( .D(n3134), .CLK(clk), .Q(
        \cpuregs[14][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][25]  ( .D(n3133), .CLK(clk), .Q(
        \cpuregs[13][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][25]  ( .D(n3132), .CLK(clk), .Q(
        \cpuregs[12][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][25]  ( .D(n3131), .CLK(clk), .Q(
        \cpuregs[11][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][25]  ( .D(n3130), .CLK(clk), .Q(
        \cpuregs[10][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][25]  ( .D(n3129), .CLK(clk), .Q(
        \cpuregs[9][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][25]  ( .D(n3128), .CLK(clk), .Q(
        \cpuregs[8][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][25]  ( .D(n3127), .CLK(clk), .Q(
        \cpuregs[7][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][25]  ( .D(n3126), .CLK(clk), .Q(
        \cpuregs[6][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][25]  ( .D(n3125), .CLK(clk), .Q(
        \cpuregs[5][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][25]  ( .D(n3124), .CLK(clk), .Q(
        \cpuregs[4][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][25]  ( .D(n3123), .CLK(clk), .Q(
        \cpuregs[3][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][25]  ( .D(n3122), .CLK(clk), .Q(
        \cpuregs[2][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][25]  ( .D(n3121), .CLK(clk), .Q(
        \cpuregs[1][25] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[26]  ( .D(n2846), .CLK(clk), .Q(
        decoded_imm[26]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[26]  ( .D(alu_out[26]), .CLK(clk), 
        .Q(alu_out_q[26]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[26]  ( .D(n4025), .CLK(clk), .Q(
        reg_next_pc[26]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[26]  ( .D(n3993), .CLK(clk), .Q(
        reg_pc[26]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][26]  ( .D(n3120), .CLK(clk), .Q(
        \cpuregs[31][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][26]  ( .D(n3119), .CLK(clk), .Q(
        \cpuregs[30][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][26]  ( .D(n3118), .CLK(clk), .Q(
        \cpuregs[29][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][26]  ( .D(n3117), .CLK(clk), .Q(
        \cpuregs[28][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][26]  ( .D(n3116), .CLK(clk), .Q(
        \cpuregs[27][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][26]  ( .D(n3115), .CLK(clk), .Q(
        \cpuregs[26][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][26]  ( .D(n3114), .CLK(clk), .Q(
        \cpuregs[25][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][26]  ( .D(n3113), .CLK(clk), .Q(
        \cpuregs[24][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][26]  ( .D(n3112), .CLK(clk), .Q(
        \cpuregs[23][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][26]  ( .D(n3111), .CLK(clk), .Q(
        \cpuregs[22][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][26]  ( .D(n3110), .CLK(clk), .Q(
        \cpuregs[21][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][26]  ( .D(n3109), .CLK(clk), .Q(
        \cpuregs[20][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][26]  ( .D(n3108), .CLK(clk), .Q(
        \cpuregs[19][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][26]  ( .D(n3107), .CLK(clk), .Q(
        \cpuregs[18][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][26]  ( .D(n3106), .CLK(clk), .Q(
        \cpuregs[17][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][26]  ( .D(n3105), .CLK(clk), .Q(
        \cpuregs[16][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][26]  ( .D(n3104), .CLK(clk), .Q(
        \cpuregs[15][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][26]  ( .D(n3103), .CLK(clk), .Q(
        \cpuregs[14][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][26]  ( .D(n3102), .CLK(clk), .Q(
        \cpuregs[13][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][26]  ( .D(n3101), .CLK(clk), .Q(
        \cpuregs[12][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][26]  ( .D(n3100), .CLK(clk), .Q(
        \cpuregs[11][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][26]  ( .D(n3099), .CLK(clk), .Q(
        \cpuregs[10][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][26]  ( .D(n3098), .CLK(clk), .Q(
        \cpuregs[9][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][26]  ( .D(n3097), .CLK(clk), .Q(
        \cpuregs[8][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][26]  ( .D(n3096), .CLK(clk), .Q(
        \cpuregs[7][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][26]  ( .D(n3095), .CLK(clk), .Q(
        \cpuregs[6][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][26]  ( .D(n3094), .CLK(clk), .Q(
        \cpuregs[5][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][26]  ( .D(n3093), .CLK(clk), .Q(
        \cpuregs[4][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][26]  ( .D(n3092), .CLK(clk), .Q(
        \cpuregs[3][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][26]  ( .D(n3091), .CLK(clk), .Q(
        \cpuregs[2][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][26]  ( .D(n3090), .CLK(clk), .Q(
        \cpuregs[1][26] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[27]  ( .D(n2845), .CLK(clk), .Q(
        decoded_imm[27]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[27]  ( .D(alu_out[27]), .CLK(clk), 
        .Q(alu_out_q[27]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[27]  ( .D(n4245), .CLK(clk), .Q(
        reg_next_pc[27]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[27]  ( .D(n3992), .CLK(clk), .Q(
        reg_pc[27]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][27]  ( .D(n3089), .CLK(clk), .Q(
        \cpuregs[31][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][27]  ( .D(n3088), .CLK(clk), .Q(
        \cpuregs[30][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][27]  ( .D(n3087), .CLK(clk), .Q(
        \cpuregs[29][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][27]  ( .D(n3086), .CLK(clk), .Q(
        \cpuregs[28][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][27]  ( .D(n3085), .CLK(clk), .Q(
        \cpuregs[27][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][27]  ( .D(n3084), .CLK(clk), .Q(
        \cpuregs[26][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][27]  ( .D(n3083), .CLK(clk), .Q(
        \cpuregs[25][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][27]  ( .D(n3082), .CLK(clk), .Q(
        \cpuregs[24][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][27]  ( .D(n3081), .CLK(clk), .Q(
        \cpuregs[23][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][27]  ( .D(n3080), .CLK(clk), .Q(
        \cpuregs[22][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][27]  ( .D(n3079), .CLK(clk), .Q(
        \cpuregs[21][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][27]  ( .D(n3078), .CLK(clk), .Q(
        \cpuregs[20][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][27]  ( .D(n3077), .CLK(clk), .Q(
        \cpuregs[19][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][27]  ( .D(n3076), .CLK(clk), .Q(
        \cpuregs[18][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][27]  ( .D(n3075), .CLK(clk), .Q(
        \cpuregs[17][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][27]  ( .D(n3074), .CLK(clk), .Q(
        \cpuregs[16][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][27]  ( .D(n3073), .CLK(clk), .Q(
        \cpuregs[15][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][27]  ( .D(n3072), .CLK(clk), .Q(
        \cpuregs[14][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][27]  ( .D(n3071), .CLK(clk), .Q(
        \cpuregs[13][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][27]  ( .D(n3070), .CLK(clk), .Q(
        \cpuregs[12][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][27]  ( .D(n3069), .CLK(clk), .Q(
        \cpuregs[11][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][27]  ( .D(n3068), .CLK(clk), .Q(
        \cpuregs[10][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][27]  ( .D(n3067), .CLK(clk), .Q(
        \cpuregs[9][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][27]  ( .D(n3066), .CLK(clk), .Q(
        \cpuregs[8][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][27]  ( .D(n3065), .CLK(clk), .Q(
        \cpuregs[7][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][27]  ( .D(n3064), .CLK(clk), .Q(
        \cpuregs[6][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][27]  ( .D(n3063), .CLK(clk), .Q(
        \cpuregs[5][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][27]  ( .D(n3062), .CLK(clk), .Q(
        \cpuregs[4][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][27]  ( .D(n3061), .CLK(clk), .Q(
        \cpuregs[3][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][27]  ( .D(n3060), .CLK(clk), .Q(
        \cpuregs[2][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][27]  ( .D(n3059), .CLK(clk), .Q(
        \cpuregs[1][27] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[28]  ( .D(n2844), .CLK(clk), .Q(
        decoded_imm[28]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[28]  ( .D(alu_out[28]), .CLK(clk), 
        .Q(alu_out_q[28]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[28]  ( .D(n4243), .CLK(clk), .Q(
        reg_next_pc[28]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[28]  ( .D(n3991), .CLK(clk), .Q(
        reg_pc[28]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][28]  ( .D(n3058), .CLK(clk), .Q(
        \cpuregs[31][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][28]  ( .D(n3057), .CLK(clk), .Q(
        \cpuregs[30][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][28]  ( .D(n3056), .CLK(clk), .Q(
        \cpuregs[29][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][28]  ( .D(n3055), .CLK(clk), .Q(
        \cpuregs[28][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][28]  ( .D(n3054), .CLK(clk), .Q(
        \cpuregs[27][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][28]  ( .D(n3053), .CLK(clk), .Q(
        \cpuregs[26][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][28]  ( .D(n3052), .CLK(clk), .Q(
        \cpuregs[25][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][28]  ( .D(n3051), .CLK(clk), .Q(
        \cpuregs[24][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][28]  ( .D(n3050), .CLK(clk), .Q(
        \cpuregs[23][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][28]  ( .D(n3049), .CLK(clk), .Q(
        \cpuregs[22][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][28]  ( .D(n3048), .CLK(clk), .Q(
        \cpuregs[21][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][28]  ( .D(n3047), .CLK(clk), .Q(
        \cpuregs[20][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][28]  ( .D(n3046), .CLK(clk), .Q(
        \cpuregs[19][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][28]  ( .D(n3045), .CLK(clk), .Q(
        \cpuregs[18][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][28]  ( .D(n3044), .CLK(clk), .Q(
        \cpuregs[17][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][28]  ( .D(n3043), .CLK(clk), .Q(
        \cpuregs[16][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][28]  ( .D(n3042), .CLK(clk), .Q(
        \cpuregs[15][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][28]  ( .D(n3041), .CLK(clk), .Q(
        \cpuregs[14][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][28]  ( .D(n3040), .CLK(clk), .Q(
        \cpuregs[13][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][28]  ( .D(n3039), .CLK(clk), .Q(
        \cpuregs[12][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][28]  ( .D(n3038), .CLK(clk), .Q(
        \cpuregs[11][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][28]  ( .D(n3037), .CLK(clk), .Q(
        \cpuregs[10][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][28]  ( .D(n3036), .CLK(clk), .Q(
        \cpuregs[9][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][28]  ( .D(n3035), .CLK(clk), .Q(
        \cpuregs[8][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][28]  ( .D(n3034), .CLK(clk), .Q(
        \cpuregs[7][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][28]  ( .D(n3033), .CLK(clk), .Q(
        \cpuregs[6][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][28]  ( .D(n3032), .CLK(clk), .Q(
        \cpuregs[5][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][28]  ( .D(n3031), .CLK(clk), .Q(
        \cpuregs[4][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][28]  ( .D(n3030), .CLK(clk), .Q(
        \cpuregs[3][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][28]  ( .D(n3029), .CLK(clk), .Q(
        \cpuregs[2][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][28]  ( .D(n3028), .CLK(clk), .Q(
        \cpuregs[1][28] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[29]  ( .D(n2843), .CLK(clk), .Q(
        decoded_imm[29]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[29]  ( .D(alu_out[29]), .CLK(clk), 
        .Q(alu_out_q[29]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[29]  ( .D(n4241), .CLK(clk), .Q(
        reg_next_pc[29]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[29]  ( .D(n3990), .CLK(clk), .Q(
        reg_pc[29]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][29]  ( .D(n3027), .CLK(clk), .Q(
        \cpuregs[31][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][29]  ( .D(n3026), .CLK(clk), .Q(
        \cpuregs[30][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][29]  ( .D(n3025), .CLK(clk), .Q(
        \cpuregs[29][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][29]  ( .D(n3024), .CLK(clk), .Q(
        \cpuregs[28][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][29]  ( .D(n3023), .CLK(clk), .Q(
        \cpuregs[27][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][29]  ( .D(n3022), .CLK(clk), .Q(
        \cpuregs[26][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][29]  ( .D(n3021), .CLK(clk), .Q(
        \cpuregs[25][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][29]  ( .D(n3020), .CLK(clk), .Q(
        \cpuregs[24][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][29]  ( .D(n3019), .CLK(clk), .Q(
        \cpuregs[23][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][29]  ( .D(n3018), .CLK(clk), .Q(
        \cpuregs[22][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][29]  ( .D(n3017), .CLK(clk), .Q(
        \cpuregs[21][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][29]  ( .D(n3016), .CLK(clk), .Q(
        \cpuregs[20][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][29]  ( .D(n3015), .CLK(clk), .Q(
        \cpuregs[19][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][29]  ( .D(n3014), .CLK(clk), .Q(
        \cpuregs[18][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][29]  ( .D(n3013), .CLK(clk), .Q(
        \cpuregs[17][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][29]  ( .D(n3012), .CLK(clk), .Q(
        \cpuregs[16][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][29]  ( .D(n3011), .CLK(clk), .Q(
        \cpuregs[15][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][29]  ( .D(n3010), .CLK(clk), .Q(
        \cpuregs[14][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][29]  ( .D(n3009), .CLK(clk), .Q(
        \cpuregs[13][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][29]  ( .D(n3008), .CLK(clk), .Q(
        \cpuregs[12][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][29]  ( .D(n3007), .CLK(clk), .Q(
        \cpuregs[11][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][29]  ( .D(n3006), .CLK(clk), .Q(
        \cpuregs[10][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][29]  ( .D(n3005), .CLK(clk), .Q(
        \cpuregs[9][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][29]  ( .D(n3004), .CLK(clk), .Q(
        \cpuregs[8][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][29]  ( .D(n3003), .CLK(clk), .Q(
        \cpuregs[7][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][29]  ( .D(n3002), .CLK(clk), .Q(
        \cpuregs[6][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][29]  ( .D(n3001), .CLK(clk), .Q(
        \cpuregs[5][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][29]  ( .D(n3000), .CLK(clk), .Q(
        \cpuregs[4][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][29]  ( .D(n2999), .CLK(clk), .Q(
        \cpuregs[3][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][29]  ( .D(n2998), .CLK(clk), .Q(
        \cpuregs[2][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][29]  ( .D(n2997), .CLK(clk), .Q(
        \cpuregs[1][29] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[30]  ( .D(n2842), .CLK(clk), .Q(
        decoded_imm[30]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[30]  ( .D(alu_out[30]), .CLK(clk), 
        .Q(alu_out_q[30]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[30]  ( .D(n4244), .CLK(clk), .Q(
        reg_next_pc[30]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[30]  ( .D(n3989), .CLK(clk), .Q(
        reg_pc[30]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][30]  ( .D(n2996), .CLK(clk), .Q(
        \cpuregs[31][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][30]  ( .D(n2995), .CLK(clk), .Q(
        \cpuregs[30][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][30]  ( .D(n2994), .CLK(clk), .Q(
        \cpuregs[29][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][30]  ( .D(n2993), .CLK(clk), .Q(
        \cpuregs[28][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][30]  ( .D(n2992), .CLK(clk), .Q(
        \cpuregs[27][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][30]  ( .D(n2991), .CLK(clk), .Q(
        \cpuregs[26][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][30]  ( .D(n2990), .CLK(clk), .Q(
        \cpuregs[25][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][30]  ( .D(n2989), .CLK(clk), .Q(
        \cpuregs[24][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][30]  ( .D(n2988), .CLK(clk), .Q(
        \cpuregs[23][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][30]  ( .D(n2987), .CLK(clk), .Q(
        \cpuregs[22][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][30]  ( .D(n2986), .CLK(clk), .Q(
        \cpuregs[21][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][30]  ( .D(n2985), .CLK(clk), .Q(
        \cpuregs[20][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][30]  ( .D(n2984), .CLK(clk), .Q(
        \cpuregs[19][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][30]  ( .D(n2983), .CLK(clk), .Q(
        \cpuregs[18][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][30]  ( .D(n2982), .CLK(clk), .Q(
        \cpuregs[17][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][30]  ( .D(n2981), .CLK(clk), .Q(
        \cpuregs[16][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][30]  ( .D(n2980), .CLK(clk), .Q(
        \cpuregs[15][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][30]  ( .D(n2979), .CLK(clk), .Q(
        \cpuregs[14][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][30]  ( .D(n2978), .CLK(clk), .Q(
        \cpuregs[13][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][30]  ( .D(n2977), .CLK(clk), .Q(
        \cpuregs[12][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][30]  ( .D(n2976), .CLK(clk), .Q(
        \cpuregs[11][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][30]  ( .D(n2975), .CLK(clk), .Q(
        \cpuregs[10][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][30]  ( .D(n2974), .CLK(clk), .Q(
        \cpuregs[9][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][30]  ( .D(n2973), .CLK(clk), .Q(
        \cpuregs[8][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][30]  ( .D(n2972), .CLK(clk), .Q(
        \cpuregs[7][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][30]  ( .D(n2971), .CLK(clk), .Q(
        \cpuregs[6][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][30]  ( .D(n2970), .CLK(clk), .Q(
        \cpuregs[5][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][30]  ( .D(n2969), .CLK(clk), .Q(
        \cpuregs[4][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][30]  ( .D(n2968), .CLK(clk), .Q(
        \cpuregs[3][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][30]  ( .D(n2967), .CLK(clk), .Q(
        \cpuregs[2][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][30]  ( .D(n2966), .CLK(clk), .Q(
        \cpuregs[1][30] ) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_reg[31]  ( .D(n2841), .CLK(clk), .Q(
        decoded_imm[31]) );
  sky130_fd_sc_hd__dfxtp_1 \alu_out_q_reg[31]  ( .D(alu_out[31]), .CLK(clk), 
        .Q(alu_out_q[31]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[31]  ( .D(n3988), .CLK(clk), .Q(
        reg_pc[31]) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[31][31]  ( .D(n2965), .CLK(clk), .Q(
        \cpuregs[31][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[30][31]  ( .D(n2964), .CLK(clk), .Q(
        \cpuregs[30][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[29][31]  ( .D(n2963), .CLK(clk), .Q(
        \cpuregs[29][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[28][31]  ( .D(n2962), .CLK(clk), .Q(
        \cpuregs[28][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[27][31]  ( .D(n2961), .CLK(clk), .Q(
        \cpuregs[27][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[26][31]  ( .D(n2960), .CLK(clk), .Q(
        \cpuregs[26][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[25][31]  ( .D(n2959), .CLK(clk), .Q(
        \cpuregs[25][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[24][31]  ( .D(n2958), .CLK(clk), .Q(
        \cpuregs[24][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[23][31]  ( .D(n2957), .CLK(clk), .Q(
        \cpuregs[23][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[22][31]  ( .D(n2956), .CLK(clk), .Q(
        \cpuregs[22][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[21][31]  ( .D(n2955), .CLK(clk), .Q(
        \cpuregs[21][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[20][31]  ( .D(n2954), .CLK(clk), .Q(
        \cpuregs[20][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[19][31]  ( .D(n2953), .CLK(clk), .Q(
        \cpuregs[19][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[18][31]  ( .D(n2952), .CLK(clk), .Q(
        \cpuregs[18][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[17][31]  ( .D(n2951), .CLK(clk), .Q(
        \cpuregs[17][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[16][31]  ( .D(n2950), .CLK(clk), .Q(
        \cpuregs[16][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[15][31]  ( .D(n2949), .CLK(clk), .Q(
        \cpuregs[15][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[14][31]  ( .D(n2948), .CLK(clk), .Q(
        \cpuregs[14][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[13][31]  ( .D(n2947), .CLK(clk), .Q(
        \cpuregs[13][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[12][31]  ( .D(n2946), .CLK(clk), .Q(
        \cpuregs[12][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[11][31]  ( .D(n2945), .CLK(clk), .Q(
        \cpuregs[11][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[10][31]  ( .D(n2944), .CLK(clk), .Q(
        \cpuregs[10][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[9][31]  ( .D(n2943), .CLK(clk), .Q(
        \cpuregs[9][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[8][31]  ( .D(n2942), .CLK(clk), .Q(
        \cpuregs[8][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[7][31]  ( .D(n2941), .CLK(clk), .Q(
        \cpuregs[7][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[6][31]  ( .D(n2940), .CLK(clk), .Q(
        \cpuregs[6][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[5][31]  ( .D(n2939), .CLK(clk), .Q(
        \cpuregs[5][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[4][31]  ( .D(n2938), .CLK(clk), .Q(
        \cpuregs[4][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[3][31]  ( .D(n2937), .CLK(clk), .Q(
        \cpuregs[3][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[2][31]  ( .D(n2936), .CLK(clk), .Q(
        \cpuregs[2][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \cpuregs_reg[1][31]  ( .D(n2935), .CLK(clk), .Q(
        \cpuregs[1][31] ) );
  sky130_fd_sc_hd__dfxtp_1 \mem_state_reg[0]  ( .D(n2930), .CLK(clk), .Q(
        mem_state[0]) );
  sky130_fd_sc_hd__dfxtp_1 mem_instr_reg ( .D(n2798), .CLK(clk), .Q(mem_instr)
         );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[2]  ( .D(n2763), .CLK(clk), .Q(
        mem_addr[2]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[3]  ( .D(n2762), .CLK(clk), .Q(
        mem_addr[3]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[4]  ( .D(n2761), .CLK(clk), .Q(
        mem_addr[4]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[5]  ( .D(n2760), .CLK(clk), .Q(
        mem_addr[5]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[6]  ( .D(n2759), .CLK(clk), .Q(
        mem_addr[6]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[7]  ( .D(n2758), .CLK(clk), .Q(
        mem_addr[7]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[8]  ( .D(n2757), .CLK(clk), .Q(
        mem_addr[8]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[9]  ( .D(n2756), .CLK(clk), .Q(
        mem_addr[9]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[10]  ( .D(n2755), .CLK(clk), .Q(
        mem_addr[10]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[11]  ( .D(n2754), .CLK(clk), .Q(
        mem_addr[11]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[12]  ( .D(n2753), .CLK(clk), .Q(
        mem_addr[12]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[13]  ( .D(n2752), .CLK(clk), .Q(
        mem_addr[13]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[14]  ( .D(n2751), .CLK(clk), .Q(
        mem_addr[14]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[15]  ( .D(n2750), .CLK(clk), .Q(
        mem_addr[15]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[16]  ( .D(n2749), .CLK(clk), .Q(
        mem_addr[16]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[17]  ( .D(n2748), .CLK(clk), .Q(
        mem_addr[17]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[18]  ( .D(n2747), .CLK(clk), .Q(
        mem_addr[18]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[19]  ( .D(n2746), .CLK(clk), .Q(
        mem_addr[19]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[20]  ( .D(n2745), .CLK(clk), .Q(
        mem_addr[20]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[21]  ( .D(n2744), .CLK(clk), .Q(
        mem_addr[21]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[22]  ( .D(n2743), .CLK(clk), .Q(
        mem_addr[22]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[23]  ( .D(n2742), .CLK(clk), .Q(
        mem_addr[23]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[24]  ( .D(n2741), .CLK(clk), .Q(
        mem_addr[24]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[25]  ( .D(n2740), .CLK(clk), .Q(
        mem_addr[25]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[26]  ( .D(n2739), .CLK(clk), .Q(
        mem_addr[26]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[27]  ( .D(n2738), .CLK(clk), .Q(
        mem_addr[27]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[28]  ( .D(n2737), .CLK(clk), .Q(
        mem_addr[28]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[29]  ( .D(n2736), .CLK(clk), .Q(
        mem_addr[29]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[30]  ( .D(n2735), .CLK(clk), .Q(
        mem_addr[30]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_addr_reg[31]  ( .D(n2734), .CLK(clk), .Q(
        mem_addr[31]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[0]  ( .D(n2830), .CLK(clk), .Q(
        mem_wdata[0]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[7]  ( .D(n2829), .CLK(clk), .Q(
        mem_wdata[7]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[6]  ( .D(n2828), .CLK(clk), .Q(
        mem_wdata[6]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[5]  ( .D(n2827), .CLK(clk), .Q(
        mem_wdata[5]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[4]  ( .D(n2826), .CLK(clk), .Q(
        mem_wdata[4]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[3]  ( .D(n2825), .CLK(clk), .Q(
        mem_wdata[3]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[2]  ( .D(n2824), .CLK(clk), .Q(
        mem_wdata[2]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[1]  ( .D(n2823), .CLK(clk), .Q(
        mem_wdata[1]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[16]  ( .D(n2822), .CLK(clk), .Q(
        mem_wdata[16]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[17]  ( .D(n2821), .CLK(clk), .Q(
        mem_wdata[17]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[18]  ( .D(n2820), .CLK(clk), .Q(
        mem_wdata[18]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[19]  ( .D(n2819), .CLK(clk), .Q(
        mem_wdata[19]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[20]  ( .D(n2818), .CLK(clk), .Q(
        mem_wdata[20]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[21]  ( .D(n2817), .CLK(clk), .Q(
        mem_wdata[21]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[22]  ( .D(n2816), .CLK(clk), .Q(
        mem_wdata[22]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[23]  ( .D(n2815), .CLK(clk), .Q(
        mem_wdata[23]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[8]  ( .D(n2814), .CLK(clk), .Q(
        mem_wdata[8]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[24]  ( .D(n2813), .CLK(clk), .Q(
        mem_wdata[24]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[9]  ( .D(n2812), .CLK(clk), .Q(
        mem_wdata[9]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[25]  ( .D(n2811), .CLK(clk), .Q(
        mem_wdata[25]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[10]  ( .D(n2810), .CLK(clk), .Q(
        mem_wdata[10]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[26]  ( .D(n2809), .CLK(clk), .Q(
        mem_wdata[26]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[11]  ( .D(n2808), .CLK(clk), .Q(
        mem_wdata[11]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[27]  ( .D(n2807), .CLK(clk), .Q(
        mem_wdata[27]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[12]  ( .D(n2806), .CLK(clk), .Q(
        mem_wdata[12]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[28]  ( .D(n2805), .CLK(clk), .Q(
        mem_wdata[28]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[13]  ( .D(n2804), .CLK(clk), .Q(
        mem_wdata[13]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[29]  ( .D(n2803), .CLK(clk), .Q(
        mem_wdata[29]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[14]  ( .D(n2802), .CLK(clk), .Q(
        mem_wdata[14]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[30]  ( .D(n2801), .CLK(clk), .Q(
        mem_wdata[30]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[15]  ( .D(n2800), .CLK(clk), .Q(
        mem_wdata[15]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wstrb_reg[0]  ( .D(n2797), .CLK(clk), .Q(
        mem_wstrb[0]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wstrb_reg[1]  ( .D(n2796), .CLK(clk), .Q(
        mem_wstrb[1]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wstrb_reg[2]  ( .D(n2795), .CLK(clk), .Q(
        mem_wstrb[2]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wstrb_reg[3]  ( .D(n2794), .CLK(clk), .Q(
        mem_wstrb[3]) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wdata_reg[31]  ( .D(n2732), .CLK(clk), .Q(
        mem_wdata[31]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[1]  ( .D(mem_rdata[1]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[1]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[2]  ( .D(mem_rdata[2]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[2]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[3]  ( .D(mem_rdata[3]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[3]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[4]  ( .D(mem_rdata[4]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[4]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[5]  ( .D(mem_rdata[5]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[5]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[6]  ( .D(mem_rdata[6]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[6]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[7]  ( .D(mem_rdata[7]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[7]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[8]  ( .D(mem_rdata[8]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[8]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[9]  ( .D(mem_rdata[9]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[9]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[10]  ( .D(mem_rdata[10]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[10]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[11]  ( .D(mem_rdata[11]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[11]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[12]  ( .D(mem_rdata[12]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[12]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[13]  ( .D(mem_rdata[13]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[13]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[14]  ( .D(mem_rdata[14]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[14]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[15]  ( .D(mem_rdata[15]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[15]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[16]  ( .D(mem_rdata[16]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[16]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[17]  ( .D(mem_rdata[17]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[17]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[18]  ( .D(mem_rdata[18]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[18]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[19]  ( .D(mem_rdata[19]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[19]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[20]  ( .D(mem_rdata[20]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[20]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[21]  ( .D(mem_rdata[21]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[21]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[22]  ( .D(mem_rdata[22]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[22]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[23]  ( .D(mem_rdata[23]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[23]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[24]  ( .D(mem_rdata[24]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[24]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[25]  ( .D(mem_rdata[25]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[25]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[26]  ( .D(mem_rdata[26]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[26]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[27]  ( .D(mem_rdata[27]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[27]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[28]  ( .D(mem_rdata[28]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[28]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[29]  ( .D(mem_rdata[29]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[29]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[30]  ( .D(mem_rdata[30]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[30]) );
  sky130_fd_sc_hd__edfxtp_1 \mem_rdata_q_reg[0]  ( .D(mem_rdata[0]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[0]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[16]  ( .GATE(n4150), .D(N188), 
        .Q(mem_rdata_word[16]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[17]  ( .GATE(n4150), .D(N189), 
        .Q(mem_rdata_word[17]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[18]  ( .GATE(n4150), .D(N190), 
        .Q(mem_rdata_word[18]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[19]  ( .GATE(n4150), .D(N191), 
        .Q(mem_rdata_word[19]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[20]  ( .GATE(n4150), .D(N192), 
        .Q(mem_rdata_word[20]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[21]  ( .GATE(n4150), .D(N193), 
        .Q(mem_rdata_word[21]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[22]  ( .GATE(n4150), .D(N194), 
        .Q(mem_rdata_word[22]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[23]  ( .GATE(n4150), .D(N195), 
        .Q(mem_rdata_word[23]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[24]  ( .GATE(n4150), .D(N196), 
        .Q(mem_rdata_word[24]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[25]  ( .GATE(n4150), .D(N197), 
        .Q(mem_rdata_word[25]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[26]  ( .GATE(n4150), .D(N198), 
        .Q(mem_rdata_word[26]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[27]  ( .GATE(n4150), .D(N199), 
        .Q(mem_rdata_word[27]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[28]  ( .GATE(n4150), .D(N200), 
        .Q(mem_rdata_word[28]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[29]  ( .GATE(n4150), .D(N201), 
        .Q(mem_rdata_word[29]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[30]  ( .GATE(n4150), .D(N202), 
        .Q(mem_rdata_word[30]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[31]  ( .GATE(n4150), .D(N203), 
        .Q(mem_rdata_word[31]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[15]  ( .GATE(n4150), .D(n4166), 
        .Q(mem_rdata_word[15]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[14]  ( .GATE(n4150), .D(n4165), 
        .Q(mem_rdata_word[14]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[13]  ( .GATE(n4150), .D(n4164), 
        .Q(mem_rdata_word[13]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[12]  ( .GATE(n4150), .D(n4163), 
        .Q(mem_rdata_word[12]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[11]  ( .GATE(n4150), .D(n4162), 
        .Q(mem_rdata_word[11]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[10]  ( .GATE(n4150), .D(n4161), 
        .Q(mem_rdata_word[10]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[9]  ( .GATE(n4150), .D(n4160), 
        .Q(mem_rdata_word[9]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[8]  ( .GATE(n4150), .D(n4159), 
        .Q(mem_rdata_word[8]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wstrb_reg[1]  ( .GATE(n4150), .D(n4170), 
        .Q(mem_la_wstrb[1]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wstrb_reg[3]  ( .GATE(n4150), .D(n4168), 
        .Q(mem_la_wstrb[3]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wstrb_reg[2]  ( .GATE(n4150), .D(n4167), 
        .Q(mem_la_wstrb[2]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wstrb_reg[0]  ( .GATE(n4150), .D(n10205), 
        .Q(mem_la_wstrb[0]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[7]  ( .GATE(n4150), .D(n4158), 
        .Q(mem_rdata_word[7]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[7]  ( .GATE(n4150), .D(
        pcpi_rs2[7]), .Q(mem_la_wdata[7]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[15]  ( .GATE(n4150), .D(n4142), 
        .Q(mem_la_wdata[15]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[6]  ( .GATE(n4150), .D(n4157), 
        .Q(mem_rdata_word[6]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[6]  ( .GATE(n4150), .D(
        pcpi_rs2[6]), .Q(mem_la_wdata[6]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[14]  ( .GATE(n4150), .D(n4143), 
        .Q(mem_la_wdata[14]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[5]  ( .GATE(n4150), .D(n4156), 
        .Q(mem_rdata_word[5]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[5]  ( .GATE(n4150), .D(
        pcpi_rs2[5]), .Q(mem_la_wdata[5]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[13]  ( .GATE(n4150), .D(n4144), 
        .Q(mem_la_wdata[13]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[4]  ( .GATE(n4150), .D(n4155), 
        .Q(mem_rdata_word[4]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[4]  ( .GATE(n4150), .D(
        pcpi_rs2[4]), .Q(mem_la_wdata[4]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[12]  ( .GATE(n4150), .D(n4145), 
        .Q(mem_la_wdata[12]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[3]  ( .GATE(n4150), .D(n4154), 
        .Q(mem_rdata_word[3]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[3]  ( .GATE(n4150), .D(
        pcpi_rs2[3]), .Q(mem_la_wdata[3]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[11]  ( .GATE(n4150), .D(n4146), 
        .Q(mem_la_wdata[11]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[19]  ( .GATE(n4150), .D(n4138), 
        .Q(mem_la_wdata[19]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[2]  ( .GATE(n4150), .D(n4153), 
        .Q(mem_rdata_word[2]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[2]  ( .GATE(n4150), .D(
        pcpi_rs2[2]), .Q(mem_la_wdata[2]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[10]  ( .GATE(n4150), .D(n4147), 
        .Q(mem_la_wdata[10]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[18]  ( .GATE(n4150), .D(n4139), 
        .Q(mem_la_wdata[18]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[1]  ( .GATE(n4150), .D(n4152), 
        .Q(mem_rdata_word[1]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[1]  ( .GATE(n4150), .D(
        pcpi_rs2[1]), .Q(mem_la_wdata[1]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[9]  ( .GATE(n4150), .D(n4148), 
        .Q(mem_la_wdata[9]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[17]  ( .GATE(n4150), .D(n4140), 
        .Q(mem_la_wdata[17]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_rdata_word_reg[0]  ( .GATE(n4150), .D(n4151), 
        .Q(mem_rdata_word[0]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[0]  ( .GATE(n4150), .D(
        pcpi_rs2[0]), .Q(mem_la_wdata[0]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[8]  ( .GATE(n4150), .D(n4149), 
        .Q(mem_la_wdata[8]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[16]  ( .GATE(n4150), .D(n4141), 
        .Q(mem_la_wdata[16]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[20]  ( .GATE(n4150), .D(n4137), 
        .Q(mem_la_wdata[20]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[21]  ( .GATE(n4150), .D(n4136), 
        .Q(mem_la_wdata[21]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[22]  ( .GATE(n4150), .D(n4135), 
        .Q(mem_la_wdata[22]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[23]  ( .GATE(n4150), .D(n4134), 
        .Q(mem_la_wdata[23]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[24]  ( .GATE(n4150), .D(n4133), 
        .Q(mem_la_wdata[24]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[25]  ( .GATE(n4150), .D(n4132), 
        .Q(mem_la_wdata[25]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[26]  ( .GATE(n4150), .D(n4131), 
        .Q(mem_la_wdata[26]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[27]  ( .GATE(n4150), .D(n4130), 
        .Q(mem_la_wdata[27]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[28]  ( .GATE(n4150), .D(n4129), 
        .Q(mem_la_wdata[28]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[29]  ( .GATE(n4150), .D(n4128), 
        .Q(mem_la_wdata[29]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[30]  ( .GATE(n4150), .D(n4127), 
        .Q(mem_la_wdata[30]) );
  sky130_fd_sc_hd__dlxtp_1 \mem_la_wdata_reg[31]  ( .GATE(n4150), .D(n4126), 
        .Q(mem_la_wdata[31]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[31]  ( .D(n2764), .CLK(clk), .Q(
        pcpi_rs1[31]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[30]  ( .D(n2765), .CLK(clk), .Q(
        pcpi_rs1[30]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[29]  ( .D(n2766), .CLK(clk), .Q(
        pcpi_rs1[29]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[28]  ( .D(n2767), .CLK(clk), .Q(
        pcpi_rs1[28]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[27]  ( .D(n2768), .CLK(clk), .Q(
        pcpi_rs1[27]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[26]  ( .D(n2769), .CLK(clk), .Q(
        pcpi_rs1[26]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[25]  ( .D(n2770), .CLK(clk), .Q(
        pcpi_rs1[25]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[24]  ( .D(n2771), .CLK(clk), .Q(
        pcpi_rs1[24]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[23]  ( .D(n2772), .CLK(clk), .Q(
        pcpi_rs1[23]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[22]  ( .D(n2773), .CLK(clk), .Q(
        pcpi_rs1[22]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[21]  ( .D(n2774), .CLK(clk), .Q(
        pcpi_rs1[21]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[20]  ( .D(n2775), .CLK(clk), .Q(
        pcpi_rs1[20]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[19]  ( .D(n2776), .CLK(clk), .Q(
        pcpi_rs1[19]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[18]  ( .D(n2777), .CLK(clk), .Q(
        pcpi_rs1[18]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[17]  ( .D(n2778), .CLK(clk), .Q(
        pcpi_rs1[17]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[16]  ( .D(n2779), .CLK(clk), .Q(
        pcpi_rs1[16]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[15]  ( .D(n2780), .CLK(clk), .Q(
        pcpi_rs1[15]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[14]  ( .D(n2781), .CLK(clk), .Q(
        pcpi_rs1[14]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[13]  ( .D(n2782), .CLK(clk), .Q(
        pcpi_rs1[13]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[12]  ( .D(n2783), .CLK(clk), .Q(
        pcpi_rs1[12]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[11]  ( .D(n2784), .CLK(clk), .Q(
        pcpi_rs1[11]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[10]  ( .D(n2785), .CLK(clk), .Q(
        pcpi_rs1[10]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[9]  ( .D(n2786), .CLK(clk), .Q(
        pcpi_rs1[9]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[8]  ( .D(n2787), .CLK(clk), .Q(
        pcpi_rs1[8]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[7]  ( .D(n2788), .CLK(clk), .Q(
        pcpi_rs1[7]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[6]  ( .D(n2789), .CLK(clk), .Q(
        pcpi_rs1[6]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[5]  ( .D(n2790), .CLK(clk), .Q(
        pcpi_rs1[5]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[4]  ( .D(n2791), .CLK(clk), .Q(
        pcpi_rs1[4]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[3]  ( .D(n2792), .CLK(clk), .Q(
        pcpi_rs1[3]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[2]  ( .D(n2793), .CLK(clk), .Q(
        pcpi_rs1[2]) );
  sky130_fd_sc_hd__dfxtp_1 instr_jal_reg ( .D(n2919), .CLK(clk), .Q(instr_jal)
         );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[1]  ( .D(n2933), .CLK(clk), .Q(
        pcpi_rs1[1]) );
  sky130_fd_sc_hd__dfxtp_1 is_lui_auipc_jal_jalr_addi_add_sub_reg ( .D(n10141), 
        .CLK(clk), .Q(is_lui_auipc_jal_jalr_addi_add_sub) );
  sky130_fd_sc_hd__dfxtp_1 \mem_wordsize_reg[1]  ( .D(n2831), .CLK(clk), .Q(
        mem_wordsize[1]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op1_reg[0]  ( .D(n2934), .CLK(clk), .Q(
        pcpi_rs1[0]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[7]  ( .D(n3951), .CLK(clk), .Q(
        pcpi_rs2[7]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[8]  ( .D(n3950), .CLK(clk), .Q(
        pcpi_rs2[8]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[9]  ( .D(n3949), .CLK(clk), .Q(
        pcpi_rs2[9]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[10]  ( .D(n3948), .CLK(clk), .Q(
        pcpi_rs2[10]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[11]  ( .D(n3947), .CLK(clk), .Q(
        pcpi_rs2[11]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[12]  ( .D(n3946), .CLK(clk), .Q(
        pcpi_rs2[12]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[13]  ( .D(n3945), .CLK(clk), .Q(
        pcpi_rs2[13]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[14]  ( .D(n3944), .CLK(clk), .Q(
        pcpi_rs2[14]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[15]  ( .D(n3943), .CLK(clk), .Q(
        pcpi_rs2[15]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[16]  ( .D(n3942), .CLK(clk), .Q(
        pcpi_rs2[16]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[17]  ( .D(n3941), .CLK(clk), .Q(
        pcpi_rs2[17]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[18]  ( .D(n3940), .CLK(clk), .Q(
        pcpi_rs2[18]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[19]  ( .D(n3939), .CLK(clk), .Q(
        pcpi_rs2[19]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[6]  ( .D(n3952), .CLK(clk), .Q(
        pcpi_rs2[6]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[5]  ( .D(n3953), .CLK(clk), .Q(
        pcpi_rs2[5]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[4]  ( .D(n3954), .CLK(clk), .Q(
        pcpi_rs2[4]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[3]  ( .D(n3955), .CLK(clk), .Q(
        pcpi_rs2[3]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[2]  ( .D(n3956), .CLK(clk), .Q(
        pcpi_rs2[2]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[1]  ( .D(n3957), .CLK(clk), .Q(
        pcpi_rs2[1]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[20]  ( .D(n3938), .CLK(clk), .Q(
        pcpi_rs2[20]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[21]  ( .D(n3937), .CLK(clk), .Q(
        pcpi_rs2[21]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[22]  ( .D(n3936), .CLK(clk), .Q(
        pcpi_rs2[22]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[23]  ( .D(n3935), .CLK(clk), .Q(
        pcpi_rs2[23]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[24]  ( .D(n3934), .CLK(clk), .Q(
        pcpi_rs2[24]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[25]  ( .D(n3933), .CLK(clk), .Q(
        pcpi_rs2[25]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[26]  ( .D(n3932), .CLK(clk), .Q(
        pcpi_rs2[26]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[27]  ( .D(n3931), .CLK(clk), .Q(
        pcpi_rs2[27]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[28]  ( .D(n3930), .CLK(clk), .Q(
        pcpi_rs2[28]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[29]  ( .D(n3929), .CLK(clk), .Q(
        pcpi_rs2[29]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[30]  ( .D(n3928), .CLK(clk), .Q(
        pcpi_rs2[30]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_op2_reg[31]  ( .D(n3927), .CLK(clk), .Q(
        pcpi_rs2[31]) );
  sky130_fd_sc_hd__dfxtp_1 latched_stalu_reg ( .D(n4117), .CLK(clk), .Q(
        latched_stalu) );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[5]  ( .D(n2835), .CLK(clk), .Q(
        cpu_state[5]) );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[3]  ( .D(n2836), .CLK(clk), .Q(
        cpu_state[3]) );
  sky130_fd_sc_hd__dfxtp_1 latched_store_reg ( .D(n4116), .CLK(clk), .Q(
        latched_store) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[2]  ( .D(n4017), .CLK(clk), .Q(
        reg_pc[2]) );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[6]  ( .D(n2834), .CLK(clk), .Q(
        cpu_state[6]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_next_pc_reg[31]  ( .D(n5403), .CLK(clk), .Q(
        reg_next_pc[31]) );
  sky130_fd_sc_hd__dfxtp_1 \reg_pc_reg[3]  ( .D(n4016), .CLK(clk), .Q(
        reg_pc[3]) );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[1]  ( .D(n2838), .CLK(clk), .Q(
        cpu_state[1]) );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[0]  ( .D(n2839), .CLK(clk), .Q(
        cpu_state[0]) );
  sky130_fd_sc_hd__dfxtp_1 latched_branch_reg ( .D(n4118), .CLK(clk), .Q(
        latched_branch) );
  sky130_fd_sc_hd__dfxtp_1 instr_sub_reg ( .D(n3974), .CLK(clk), .Q(instr_sub)
         );
  sky130_fd_sc_hd__dfxtp_1 \cpu_state_reg[7]  ( .D(n2833), .CLK(clk), .Q(
        cpu_state[7]) );
  sky130_fd_sc_hd__dfxtp_4 \decoded_imm_j_reg[3]  ( .D(n2889), .CLK(clk), .Q(
        decoded_imm_j[3]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[4]  ( .D(n2888), .CLK(clk), .Q(
        decoded_imm_j[4]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[15]  ( .D(n2877), .CLK(clk), .Q(
        decoded_imm_j[15]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[2]  ( .D(n2890), .CLK(clk), .Q(
        decoded_imm_j[2]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[19]  ( .D(n2873), .CLK(clk), .Q(
        decoded_imm_j[19]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[18]  ( .D(n2874), .CLK(clk), .Q(
        decoded_imm_j[18]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[1]  ( .D(n2891), .CLK(clk), .Q(
        decoded_imm_j[1]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[16]  ( .D(n2876), .CLK(clk), .Q(
        decoded_imm_j[16]) );
  sky130_fd_sc_hd__dfxtp_2 \decoded_imm_j_reg[17]  ( .D(n2875), .CLK(clk), .Q(
        decoded_imm_j[17]) );
  sky130_fd_sc_hd__edfxbp_1 \mem_rdata_q_reg[31]  ( .D(mem_rdata[31]), .DE(
        n10206), .CLK(clk), .Q(mem_rdata_q[31]), .Q_N(n10207) );
  sky130_fd_sc_hd__dfxtp_1 \decoded_imm_j_reg[11]  ( .D(n2881), .CLK(clk), .Q(
        decoded_imm_j[11]) );
  sky130_fd_sc_hd__dfxtp_1 mem_valid_reg ( .D(n2931), .CLK(clk), .Q(mem_valid)
         );
  sky130_fd_sc_hd__dfxtp_1 decoder_trigger_reg ( .D(N2077), .CLK(clk), .Q(
        decoder_trigger) );
  sky130_fd_sc_hd__buf_2 U4398 ( .A(n6533), .X(n4197) );
  sky130_fd_sc_hd__buf_2 U4399 ( .A(n6205), .X(n4201) );
  sky130_fd_sc_hd__buf_2 U4400 ( .A(n6238), .X(n7247) );
  sky130_fd_sc_hd__buf_2 U4401 ( .A(n6367), .X(n4173) );
  sky130_fd_sc_hd__buf_2 U4402 ( .A(n6523), .X(n4180) );
  sky130_fd_sc_hd__buf_2 U4403 ( .A(n6517), .X(n4174) );
  sky130_fd_sc_hd__buf_2 U4404 ( .A(n6388), .X(n4175) );
  sky130_fd_sc_hd__buf_2 U4405 ( .A(n6399), .X(n4176) );
  sky130_fd_sc_hd__buf_2 U4406 ( .A(n6379), .X(n4192) );
  sky130_fd_sc_hd__buf_2 U4407 ( .A(n6390), .X(n4195) );
  sky130_fd_sc_hd__buf_4 U4408 ( .A(n6365), .X(n7452) );
  sky130_fd_sc_hd__nand2_2 U4409 ( .A(n6237), .B(n6241), .Y(n4219) );
  sky130_fd_sc_hd__inv_2 U4410 ( .A(n10089), .Y(n7928) );
  sky130_fd_sc_hd__inv_2 U4411 ( .A(n10136), .Y(n10066) );
  sky130_fd_sc_hd__nand2_1 U4412 ( .A(n10055), .B(decoder_trigger), .Y(n5883)
         );
  sky130_fd_sc_hd__nand2_2 U4413 ( .A(n9340), .B(n4455), .Y(n9506) );
  sky130_fd_sc_hd__and2_1 U4414 ( .A(n8662), .B(n8669), .X(n8487) );
  sky130_fd_sc_hd__and2_1 U4415 ( .A(n8661), .B(n8649), .X(n8478) );
  sky130_fd_sc_hd__and2_1 U4416 ( .A(n8662), .B(n8668), .X(n8500) );
  sky130_fd_sc_hd__inv_2 U4417 ( .A(n10029), .Y(n9530) );
  sky130_fd_sc_hd__inv_2 U4418 ( .A(n4835), .Y(n9532) );
  sky130_fd_sc_hd__buf_2 U4419 ( .A(n8659), .X(n4215) );
  sky130_fd_sc_hd__nand2_1 U4420 ( .A(decoded_imm_j[15]), .B(decoded_imm_j[16]), .Y(n4270) );
  sky130_fd_sc_hd__or2_1 U4421 ( .A(decoded_imm_j[15]), .B(decoded_imm_j[16]), 
        .X(n4266) );
  sky130_fd_sc_hd__nor2_2 U4422 ( .A(cpu_state[3]), .B(cpu_state[5]), .Y(n4314) );
  sky130_fd_sc_hd__clkinv_1 U4423 ( .A(n6001), .Y(n6003) );
  sky130_fd_sc_hd__inv_2 U4424 ( .A(n9459), .Y(n4398) );
  sky130_fd_sc_hd__inv_2 U4425 ( .A(n9470), .Y(n4748) );
  sky130_fd_sc_hd__inv_2 U4426 ( .A(n9460), .Y(n4515) );
  sky130_fd_sc_hd__clkinv_1 U4427 ( .A(n4398), .Y(n9289) );
  sky130_fd_sc_hd__clkinv_1 U4428 ( .A(n4545), .Y(n6851) );
  sky130_fd_sc_hd__inv_2 U4429 ( .A(n9276), .Y(n4339) );
  sky130_fd_sc_hd__clkinv_1 U4430 ( .A(n5353), .Y(n5355) );
  sky130_fd_sc_hd__clkinv_1 U4431 ( .A(pcpi_rs1[19]), .Y(n8890) );
  sky130_fd_sc_hd__clkinv_1 U4432 ( .A(n7180), .Y(n8959) );
  sky130_fd_sc_hd__clkinv_1 U4433 ( .A(n8848), .Y(n4736) );
  sky130_fd_sc_hd__clkinv_1 U4434 ( .A(n6015), .Y(n8669) );
  sky130_fd_sc_hd__clkinv_1 U4435 ( .A(pcpi_rs1[14]), .Y(n8889) );
  sky130_fd_sc_hd__clkinv_1 U4436 ( .A(n9872), .Y(n8386) );
  sky130_fd_sc_hd__clkinv_1 U4437 ( .A(pcpi_rs1[10]), .Y(n8813) );
  sky130_fd_sc_hd__clkinv_1 U4438 ( .A(pcpi_rs1[8]), .Y(n8786) );
  sky130_fd_sc_hd__clkinv_1 U4439 ( .A(pcpi_rs1[12]), .Y(n8778) );
  sky130_fd_sc_hd__clkinv_1 U4440 ( .A(pcpi_rs1[22]), .Y(n8955) );
  sky130_fd_sc_hd__inv_2 U4441 ( .A(n4865), .Y(n4214) );
  sky130_fd_sc_hd__clkinv_1 U4442 ( .A(n6657), .Y(n7294) );
  sky130_fd_sc_hd__nand3_1 U4443 ( .A(n4920), .B(n4919), .C(n4918), .Y(n8119)
         );
  sky130_fd_sc_hd__and2_1 U4444 ( .A(n9524), .B(instr_rdcycle), .X(n9860) );
  sky130_fd_sc_hd__and3_1 U4445 ( .A(n9524), .B(instr_rdcycleh), .C(n5411), 
        .X(n9861) );
  sky130_fd_sc_hd__inv_2 U4446 ( .A(n9519), .Y(n4840) );
  sky130_fd_sc_hd__clkinv_1 U4447 ( .A(latched_stalu), .Y(n5967) );
  sky130_fd_sc_hd__inv_2 U4448 ( .A(n9538), .Y(n8514) );
  sky130_fd_sc_hd__clkinv_1 U4449 ( .A(pcpi_rs1[4]), .Y(n9455) );
  sky130_fd_sc_hd__clkinv_1 U4450 ( .A(pcpi_rs1[1]), .Y(n9907) );
  sky130_fd_sc_hd__clkinv_1 U4451 ( .A(mem_state[0]), .Y(n10073) );
  sky130_fd_sc_hd__clkinv_1 U4452 ( .A(n9434), .Y(n9431) );
  sky130_fd_sc_hd__buf_2 U4453 ( .A(n6510), .X(n4199) );
  sky130_fd_sc_hd__buf_2 U4454 ( .A(n6386), .X(n7084) );
  sky130_fd_sc_hd__buf_2 U4455 ( .A(n6363), .X(n4177) );
  sky130_fd_sc_hd__clkinv_1 U4456 ( .A(instr_lbu), .Y(n10104) );
  sky130_fd_sc_hd__clkinv_1 U4457 ( .A(instr_jal), .Y(n5985) );
  sky130_fd_sc_hd__clkinv_1 U4458 ( .A(n5426), .Y(n2881) );
  sky130_fd_sc_hd__clkinv_1 U4459 ( .A(n7318), .Y(n4035) );
  sky130_fd_sc_hd__clkinv_1 U4460 ( .A(n6960), .Y(n4036) );
  sky130_fd_sc_hd__clkinv_1 U4461 ( .A(n7809), .Y(n4037) );
  sky130_fd_sc_hd__clkinv_1 U4462 ( .A(n6356), .Y(n4038) );
  sky130_fd_sc_hd__clkinv_1 U4463 ( .A(n7892), .Y(n4039) );
  sky130_fd_sc_hd__clkinv_1 U4464 ( .A(n7984), .Y(n4040) );
  sky130_fd_sc_hd__clkinv_1 U4465 ( .A(n8078), .Y(n4041) );
  sky130_fd_sc_hd__and4_1 U4466 ( .A(n4303), .B(n4302), .C(n4317), .D(n4301), 
        .X(n4172) );
  sky130_fd_sc_hd__inv_2 U4467 ( .A(n9945), .Y(n10140) );
  sky130_fd_sc_hd__and2_1 U4468 ( .A(n6233), .B(n6241), .X(n4218) );
  sky130_fd_sc_hd__mux2i_1 U4469 ( .A0(n9306), .A1(pcpi_rs1[31]), .S(n9452), 
        .Y(n9309) );
  sky130_fd_sc_hd__inv_2 U4470 ( .A(n4321), .Y(n9280) );
  sky130_fd_sc_hd__inv_2 U4471 ( .A(n4371), .Y(n9307) );
  sky130_fd_sc_hd__inv_2 U4472 ( .A(n4342), .Y(n4456) );
  sky130_fd_sc_hd__or2_0 U4473 ( .A(n8555), .B(n10058), .X(n4239) );
  sky130_fd_sc_hd__buf_4 U4474 ( .A(n6515), .X(n6897) );
  sky130_fd_sc_hd__buf_4 U4475 ( .A(n6369), .X(n7069) );
  sky130_fd_sc_hd__inv_2 U4476 ( .A(n4236), .Y(n4194) );
  sky130_fd_sc_hd__nand2_4 U4477 ( .A(n6224), .B(n6241), .Y(n4226) );
  sky130_fd_sc_hd__inv_2 U4478 ( .A(n4223), .Y(n4178) );
  sky130_fd_sc_hd__inv_2 U4479 ( .A(n4221), .Y(n4179) );
  sky130_fd_sc_hd__or2_0 U4480 ( .A(n5385), .B(n5384), .X(n4242) );
  sky130_fd_sc_hd__nand3_1 U4481 ( .A(n4864), .B(n4863), .C(n4862), .Y(n7783)
         );
  sky130_fd_sc_hd__or2_0 U4482 ( .A(n5381), .B(n9031), .X(n5383) );
  sky130_fd_sc_hd__clkinv_1 U4483 ( .A(n7061), .Y(n7628) );
  sky130_fd_sc_hd__o2bb2ai_1 U4484 ( .B1(n6188), .B2(n10054), .A1_N(n10055), 
        .A2_N(decoded_rd[4]), .Y(n3959) );
  sky130_fd_sc_hd__o21ai_2 U4485 ( .A1(alu_out_q[0]), .A2(n4814), .B1(n4813), 
        .Y(n10059) );
  sky130_fd_sc_hd__or2_0 U4486 ( .A(n7303), .B(n7319), .X(n7305) );
  sky130_fd_sc_hd__clkinv_1 U4487 ( .A(n10137), .Y(n9962) );
  sky130_fd_sc_hd__or2_0 U4488 ( .A(pcpi_rs1[31]), .B(n9018), .X(n9020) );
  sky130_fd_sc_hd__or2_0 U4489 ( .A(pcpi_rs1[29]), .B(n6075), .X(n8676) );
  sky130_fd_sc_hd__or2_0 U4490 ( .A(pcpi_rs1[28]), .B(n6111), .X(n6160) );
  sky130_fd_sc_hd__or2_0 U4491 ( .A(pcpi_rs1[27]), .B(n6110), .X(n7170) );
  sky130_fd_sc_hd__nand3_1 U4492 ( .A(n4315), .B(n4314), .C(n4313), .Y(n10124)
         );
  sky130_fd_sc_hd__clkinv_1 U4493 ( .A(decoder_trigger), .Y(n5616) );
  sky130_fd_sc_hd__or2_0 U4494 ( .A(decoded_imm[28]), .B(reg_pc[28]), .X(n7557) );
  sky130_fd_sc_hd__or2_0 U4495 ( .A(decoded_imm[26]), .B(reg_pc[26]), .X(n7571) );
  sky130_fd_sc_hd__clkinv_1 U4496 ( .A(decoder_pseudo_trigger), .Y(n4775) );
  sky130_fd_sc_hd__or2_0 U4497 ( .A(decoded_imm[31]), .B(reg_pc[31]), .X(n5940) );
  sky130_fd_sc_hd__or2_0 U4498 ( .A(decoded_imm[30]), .B(reg_pc[30]), .X(n5969) );
  sky130_fd_sc_hd__or2_0 U4499 ( .A(decoded_imm[1]), .B(reg_pc[1]), .X(n9158)
         );
  sky130_fd_sc_hd__clkinv_1 U4500 ( .A(reg_next_pc[26]), .Y(n9940) );
  sky130_fd_sc_hd__or2_0 U4501 ( .A(decoded_imm[31]), .B(pcpi_rs1[31]), .X(
        n9272) );
  sky130_fd_sc_hd__clkinv_1 U4502 ( .A(decoded_imm_j[15]), .Y(n4251) );
  sky130_fd_sc_hd__clkinv_1 U4503 ( .A(mem_do_prefetch), .Y(n9909) );
  sky130_fd_sc_hd__or2_0 U4504 ( .A(decoded_imm[30]), .B(pcpi_rs1[30]), .X(
        n9269) );
  sky130_fd_sc_hd__or2_0 U4505 ( .A(decoded_imm[26]), .B(pcpi_rs1[26]), .X(
        n8961) );
  sky130_fd_sc_hd__or2_0 U4506 ( .A(decoded_imm[28]), .B(pcpi_rs1[28]), .X(
        n4709) );
  sky130_fd_sc_hd__buf_2 U4507 ( .A(n7385), .X(n4181) );
  sky130_fd_sc_hd__inv_1 U4508 ( .A(n5394), .Y(n5323) );
  sky130_fd_sc_hd__clkinv_1 U4509 ( .A(n5887), .Y(n2890) );
  sky130_fd_sc_hd__clkinv_1 U4510 ( .A(n6183), .Y(n2876) );
  sky130_fd_sc_hd__clkinv_1 U4511 ( .A(n5889), .Y(n2889) );
  sky130_fd_sc_hd__clkinv_1 U4512 ( .A(n5427), .Y(n2891) );
  sky130_fd_sc_hd__clkinv_1 U4513 ( .A(n5888), .Y(n2888) );
  sky130_fd_sc_hd__clkinv_1 U4514 ( .A(n6187), .Y(n2874) );
  sky130_fd_sc_hd__clkinv_1 U4515 ( .A(n6184), .Y(n2877) );
  sky130_fd_sc_hd__clkinv_1 U4516 ( .A(n6186), .Y(n2873) );
  sky130_fd_sc_hd__clkinv_1 U4517 ( .A(n7929), .Y(n2880) );
  sky130_fd_sc_hd__clkinv_1 U4518 ( .A(n5390), .Y(n5368) );
  sky130_fd_sc_hd__clkinv_1 U4519 ( .A(n5386), .Y(n5369) );
  sky130_fd_sc_hd__buf_6 U4520 ( .A(n4498), .X(n9340) );
  sky130_fd_sc_hd__clkinv_1 U4521 ( .A(n5978), .Y(n2872) );
  sky130_fd_sc_hd__clkinv_1 U4522 ( .A(n5296), .Y(n5356) );
  sky130_fd_sc_hd__buf_2 U4523 ( .A(n6703), .X(n4182) );
  sky130_fd_sc_hd__buf_4 U4524 ( .A(n6212), .X(n4183) );
  sky130_fd_sc_hd__buf_4 U4525 ( .A(n6374), .X(n4184) );
  sky130_fd_sc_hd__clkinv_1 U4526 ( .A(n5335), .Y(n5336) );
  sky130_fd_sc_hd__buf_4 U4527 ( .A(n6401), .X(n4185) );
  sky130_fd_sc_hd__clkinv_1 U4528 ( .A(n5332), .Y(n5333) );
  sky130_fd_sc_hd__buf_4 U4529 ( .A(n6531), .X(n4186) );
  sky130_fd_sc_hd__clkinv_1 U4530 ( .A(n5288), .Y(n5275) );
  sky130_fd_sc_hd__clkinv_1 U4531 ( .A(n5284), .Y(n5276) );
  sky130_fd_sc_hd__a21oi_1 U4532 ( .A1(n4954), .A2(n5288), .B1(n4953), .Y(
        n5297) );
  sky130_fd_sc_hd__clkinv_1 U4533 ( .A(n9032), .Y(n8175) );
  sky130_fd_sc_hd__buf_2 U4534 ( .A(n7079), .X(n4187) );
  sky130_fd_sc_hd__clkinv_1 U4535 ( .A(n8399), .Y(alu_out[4]) );
  sky130_fd_sc_hd__clkinv_1 U4536 ( .A(n6952), .Y(n7799) );
  sky130_fd_sc_hd__buf_2 U4537 ( .A(n6520), .X(n4188) );
  sky130_fd_sc_hd__clkinv_1 U4538 ( .A(n8296), .Y(alu_out[5]) );
  sky130_fd_sc_hd__clkinv_1 U4539 ( .A(mem_rdata_word[7]), .Y(n5944) );
  sky130_fd_sc_hd__clkinv_1 U4540 ( .A(n5346), .Y(n5348) );
  sky130_fd_sc_hd__clkinv_1 U4541 ( .A(n5777), .Y(n5782) );
  sky130_fd_sc_hd__clkinv_1 U4542 ( .A(n7034), .Y(n7392) );
  sky130_fd_sc_hd__clkinv_1 U4543 ( .A(n5357), .Y(n5358) );
  sky130_fd_sc_hd__buf_2 U4544 ( .A(n6614), .X(n4189) );
  sky130_fd_sc_hd__clkinv_1 U4545 ( .A(n5233), .Y(n5359) );
  sky130_fd_sc_hd__clkinv_1 U4546 ( .A(n5050), .Y(n5100) );
  sky130_fd_sc_hd__buf_2 U4547 ( .A(n8985), .X(n4190) );
  sky130_fd_sc_hd__buf_2 U4548 ( .A(n7643), .X(n4191) );
  sky130_fd_sc_hd__clkinv_1 U4549 ( .A(n5042), .Y(n5094) );
  sky130_fd_sc_hd__clkinv_1 U4550 ( .A(n7977), .Y(n7980) );
  sky130_fd_sc_hd__buf_2 U4551 ( .A(n7245), .X(n4193) );
  sky130_fd_sc_hd__buf_2 U4552 ( .A(n7464), .X(n4196) );
  sky130_fd_sc_hd__clkinv_1 U4553 ( .A(n5245), .Y(n4844) );
  sky130_fd_sc_hd__buf_2 U4554 ( .A(n9831), .X(n4198) );
  sky130_fd_sc_hd__clkinv_1 U4555 ( .A(n5683), .Y(n5688) );
  sky130_fd_sc_hd__clkinv_1 U4556 ( .A(n6541), .Y(n4200) );
  sky130_fd_sc_hd__clkinv_1 U4557 ( .A(n8172), .Y(n9036) );
  sky130_fd_sc_hd__buf_2 U4558 ( .A(n6381), .X(n4202) );
  sky130_fd_sc_hd__clkinv_1 U4559 ( .A(n8313), .Y(n8315) );
  sky130_fd_sc_hd__buf_2 U4560 ( .A(n6991), .X(n4203) );
  sky130_fd_sc_hd__clkinv_1 U4561 ( .A(n5599), .Y(n5603) );
  sky130_fd_sc_hd__clkinv_1 U4562 ( .A(n7783), .Y(n7784) );
  sky130_fd_sc_hd__clkinv_1 U4563 ( .A(n8263), .Y(n2867) );
  sky130_fd_sc_hd__clkinv_1 U4564 ( .A(n8205), .Y(n8207) );
  sky130_fd_sc_hd__clkinv_1 U4565 ( .A(n8138), .Y(n2864) );
  sky130_fd_sc_hd__clkinv_1 U4566 ( .A(n7975), .Y(n7886) );
  sky130_fd_sc_hd__clkinv_1 U4567 ( .A(n7881), .Y(n7956) );
  sky130_fd_sc_hd__clkinv_1 U4568 ( .A(n8213), .Y(n2866) );
  sky130_fd_sc_hd__clkinv_1 U4569 ( .A(n8203), .Y(n8257) );
  sky130_fd_sc_hd__clkinv_1 U4570 ( .A(n7882), .Y(n7884) );
  sky130_fd_sc_hd__clkinv_1 U4571 ( .A(n8250), .Y(n8251) );
  sky130_fd_sc_hd__clkinv_1 U4572 ( .A(N2078), .Y(n9545) );
  sky130_fd_sc_hd__clkinv_1 U4573 ( .A(n7046), .Y(n7322) );
  sky130_fd_sc_hd__clkinv_1 U4574 ( .A(n4785), .Y(n10030) );
  sky130_fd_sc_hd__clkinv_1 U4575 ( .A(n7885), .Y(n7976) );
  sky130_fd_sc_hd__buf_2 U4576 ( .A(n9791), .X(n4204) );
  sky130_fd_sc_hd__buf_2 U4577 ( .A(n7345), .X(n4205) );
  sky130_fd_sc_hd__clkinv_1 U4578 ( .A(n6492), .Y(n6494) );
  sky130_fd_sc_hd__clkinv_1 U4579 ( .A(n5723), .Y(n5735) );
  sky130_fd_sc_hd__buf_2 U4580 ( .A(n6901), .X(n4206) );
  sky130_fd_sc_hd__inv_6 U4581 ( .A(n5883), .Y(n5794) );
  sky130_fd_sc_hd__clkinv_1 U4582 ( .A(n5385), .Y(n5367) );
  sky130_fd_sc_hd__clkinv_1 U4583 ( .A(n7307), .Y(n7309) );
  sky130_fd_sc_hd__clkinv_1 U4584 ( .A(n5127), .Y(n5141) );
  sky130_fd_sc_hd__clkinv_1 U4585 ( .A(n8178), .Y(n8180) );
  sky130_fd_sc_hd__buf_2 U4586 ( .A(n7826), .X(n4207) );
  sky130_fd_sc_hd__clkinv_1 U4587 ( .A(n9514), .Y(n9440) );
  sky130_fd_sc_hd__buf_2 U4588 ( .A(n8417), .X(n4208) );
  sky130_fd_sc_hd__or3_1 U4589 ( .A(n4832), .B(n9278), .C(n9276), .X(n8848) );
  sky130_fd_sc_hd__clkinv_1 U4590 ( .A(n5054), .Y(n5134) );
  sky130_fd_sc_hd__clkinv_1 U4591 ( .A(n5673), .Y(n5701) );
  sky130_fd_sc_hd__clkinv_1 U4592 ( .A(n7310), .Y(n6951) );
  sky130_fd_sc_hd__clkinv_1 U4593 ( .A(n8316), .Y(n8689) );
  sky130_fd_sc_hd__clkinv_1 U4594 ( .A(n5030), .Y(n5131) );
  sky130_fd_sc_hd__clkinv_1 U4595 ( .A(n5244), .Y(n5322) );
  sky130_fd_sc_hd__clkinv_1 U4596 ( .A(n5321), .Y(n4958) );
  sky130_fd_sc_hd__clkinv_1 U4597 ( .A(n6152), .Y(n6155) );
  sky130_fd_sc_hd__clkinv_1 U4598 ( .A(n6153), .Y(n6154) );
  sky130_fd_sc_hd__clkinv_1 U4599 ( .A(n8694), .Y(n8695) );
  sky130_fd_sc_hd__clkinv_1 U4600 ( .A(n9441), .Y(n9444) );
  sky130_fd_sc_hd__ha_1 U4601 ( .A(n8970), .B(reg_pc[29]), .COUT(n9228), .SUM(
        n8403) );
  sky130_fd_sc_hd__clkinv_1 U4602 ( .A(n5154), .Y(n5148) );
  sky130_fd_sc_hd__clkinv_1 U4603 ( .A(n8262), .Y(n8462) );
  sky130_fd_sc_hd__clkinv_1 U4604 ( .A(n6125), .Y(n6126) );
  sky130_fd_sc_hd__buf_2 U4605 ( .A(n9717), .X(n4209) );
  sky130_fd_sc_hd__clkinv_1 U4606 ( .A(n5150), .Y(n5162) );
  sky130_fd_sc_hd__buf_2 U4607 ( .A(n7726), .X(n4210) );
  sky130_fd_sc_hd__clkinv_1 U4608 ( .A(n6352), .Y(n7802) );
  sky130_fd_sc_hd__clkinv_1 U4609 ( .A(n5304), .Y(n5306) );
  sky130_fd_sc_hd__clkinv_1 U4610 ( .A(n5609), .Y(n5610) );
  sky130_fd_sc_hd__clkinv_1 U4611 ( .A(n5281), .Y(n5283) );
  sky130_fd_sc_hd__clkinv_1 U4612 ( .A(n5791), .Y(n5797) );
  sky130_fd_sc_hd__buf_2 U4613 ( .A(n8001), .X(n4211) );
  sky130_fd_sc_hd__clkinv_1 U4614 ( .A(n8297), .Y(n8298) );
  sky130_fd_sc_hd__o2bb2ai_1 U4615 ( .B1(n8463), .B2(n5410), .A1_N(n10122), 
        .A2_N(instr_rdcycleh), .Y(n2914) );
  sky130_fd_sc_hd__buf_2 U4616 ( .A(n7909), .X(n4212) );
  sky130_fd_sc_hd__clkinv_1 U4617 ( .A(n7800), .Y(n7801) );
  sky130_fd_sc_hd__clkinv_1 U4618 ( .A(n10054), .Y(n10056) );
  sky130_fd_sc_hd__clkinv_1 U4619 ( .A(n8119), .Y(n8120) );
  sky130_fd_sc_hd__clkinv_1 U4620 ( .A(n7796), .Y(n7798) );
  sky130_fd_sc_hd__clkinv_1 U4621 ( .A(n5274), .Y(n5287) );
  sky130_fd_sc_hd__clkinv_1 U4622 ( .A(n5808), .Y(n5813) );
  sky130_fd_sc_hd__ha_1 U4623 ( .A(n5171), .B(count_cycle[59]), .COUT(n5117), 
        .SUM(n5172) );
  sky130_fd_sc_hd__buf_2 U4624 ( .A(n6211), .X(n4213) );
  sky130_fd_sc_hd__clkinv_1 U4625 ( .A(n5190), .Y(n5202) );
  sky130_fd_sc_hd__clkinv_1 U4626 ( .A(n8074), .Y(n6295) );
  sky130_fd_sc_hd__clkinv_1 U4627 ( .A(n7519), .Y(n7520) );
  sky130_fd_sc_hd__clkinv_1 U4628 ( .A(n8359), .Y(n8609) );
  sky130_fd_sc_hd__nor2_1 U4629 ( .A(n6684), .B(n9774), .Y(n7061) );
  sky130_fd_sc_hd__clkinv_1 U4630 ( .A(n6478), .Y(n7221) );
  sky130_fd_sc_hd__o2bb2ai_1 U4631 ( .B1(n10099), .B2(n9006), .A1_N(n10122), 
        .A2_N(instr_lh), .Y(n2908) );
  sky130_fd_sc_hd__o2bb2ai_1 U4632 ( .B1(n10111), .B2(n9006), .A1_N(n10122), 
        .A2_N(instr_sh), .Y(n2902) );
  sky130_fd_sc_hd__o2bb2ai_1 U4633 ( .B1(mem_rdata_q[14]), .B2(n10117), .A1_N(
        n10122), .A2_N(instr_slli), .Y(n2899) );
  sky130_fd_sc_hd__clkinv_1 U4634 ( .A(n7402), .Y(n7403) );
  sky130_fd_sc_hd__clkinv_1 U4635 ( .A(n4796), .Y(n10043) );
  sky130_fd_sc_hd__clkinv_1 U4636 ( .A(n4826), .Y(n9443) );
  sky130_fd_sc_hd__clkinv_1 U4637 ( .A(n6440), .Y(n6441) );
  sky130_fd_sc_hd__clkinv_1 U4638 ( .A(n6883), .Y(n7810) );
  sky130_fd_sc_hd__clkinv_1 U4639 ( .A(n9913), .Y(mem_la_addr[29]) );
  sky130_fd_sc_hd__clkinv_1 U4640 ( .A(n9915), .Y(mem_la_addr[31]) );
  sky130_fd_sc_hd__clkinv_1 U4641 ( .A(n9914), .Y(mem_la_addr[30]) );
  sky130_fd_sc_hd__clkinv_1 U4642 ( .A(n5613), .Y(n5614) );
  sky130_fd_sc_hd__inv_1 U4643 ( .A(n8467), .Y(n8469) );
  sky130_fd_sc_hd__clkinv_1 U4644 ( .A(n9912), .Y(mem_la_addr[28]) );
  sky130_fd_sc_hd__clkinv_1 U4645 ( .A(n5838), .Y(n5842) );
  sky130_fd_sc_hd__clkinv_1 U4646 ( .A(n5766), .Y(n5826) );
  sky130_fd_sc_hd__clkinv_1 U4647 ( .A(n9166), .Y(n9376) );
  sky130_fd_sc_hd__and2_0 U4648 ( .A(n4966), .B(n10122), .X(n10141) );
  sky130_fd_sc_hd__o2bb2ai_1 U4649 ( .B1(n10111), .B2(n10098), .A1_N(n10122), 
        .A2_N(instr_sw), .Y(n2901) );
  sky130_fd_sc_hd__clkinv_1 U4650 ( .A(n6284), .Y(n6285) );
  sky130_fd_sc_hd__clkinv_1 U4651 ( .A(n6283), .Y(n6286) );
  sky130_fd_sc_hd__clkinv_1 U4652 ( .A(n8613), .Y(n8637) );
  sky130_fd_sc_hd__clkinv_1 U4653 ( .A(n6077), .Y(n4585) );
  sky130_fd_sc_hd__clkinv_1 U4654 ( .A(n6082), .Y(n4584) );
  sky130_fd_sc_hd__clkinv_1 U4655 ( .A(n6030), .Y(n4835) );
  sky130_fd_sc_hd__nand2b_1 U4656 ( .A_N(n9531), .B(resetn), .Y(n4827) );
  sky130_fd_sc_hd__clkinv_1 U4657 ( .A(n5012), .Y(n5195) );
  sky130_fd_sc_hd__clkinv_1 U4658 ( .A(n6159), .Y(n6112) );
  sky130_fd_sc_hd__clkinv_1 U4659 ( .A(n7182), .Y(n7183) );
  sky130_fd_sc_hd__clkinv_1 U4660 ( .A(n6579), .Y(n6582) );
  sky130_fd_sc_hd__clkinv_1 U4661 ( .A(n9023), .Y(n8679) );
  sky130_fd_sc_hd__clkinv_1 U4662 ( .A(n8674), .Y(n8675) );
  sky130_fd_sc_hd__clkinv_1 U4663 ( .A(n10106), .Y(n4783) );
  sky130_fd_sc_hd__clkinv_1 U4664 ( .A(n7295), .Y(n7297) );
  sky130_fd_sc_hd__clkinv_1 U4665 ( .A(n7181), .Y(n7184) );
  sky130_fd_sc_hd__clkinv_1 U4666 ( .A(n7291), .Y(n7292) );
  sky130_fd_sc_hd__clkinv_1 U4667 ( .A(n7132), .Y(n7133) );
  sky130_fd_sc_hd__clkinv_1 U4668 ( .A(n6945), .Y(n7293) );
  sky130_fd_sc_hd__clkinv_1 U4669 ( .A(n5001), .Y(n5002) );
  sky130_fd_sc_hd__clkinv_1 U4670 ( .A(n7393), .Y(n7035) );
  sky130_fd_sc_hd__clkinv_1 U4671 ( .A(n7506), .Y(n7508) );
  sky130_fd_sc_hd__clkinv_1 U4672 ( .A(n7169), .Y(n6158) );
  sky130_fd_sc_hd__clkinv_1 U4673 ( .A(n5164), .Y(n5217) );
  sky130_fd_sc_hd__clkinv_1 U4674 ( .A(n6282), .Y(n8106) );
  sky130_fd_sc_hd__clkinv_1 U4675 ( .A(n8161), .Y(n8163) );
  sky130_fd_sc_hd__clkinv_1 U4676 ( .A(n10101), .Y(n10103) );
  sky130_fd_sc_hd__clkinv_1 U4677 ( .A(n7511), .Y(n7122) );
  sky130_fd_sc_hd__clkinv_1 U4678 ( .A(n9377), .Y(n9165) );
  sky130_fd_sc_hd__clkinv_1 U4679 ( .A(n6357), .Y(n9736) );
  sky130_fd_sc_hd__clkinv_1 U4680 ( .A(n9372), .Y(n9374) );
  sky130_fd_sc_hd__clkinv_1 U4681 ( .A(n7692), .Y(n6661) );
  sky130_fd_sc_hd__clkinv_1 U4682 ( .A(n9041), .Y(n9043) );
  sky130_fd_sc_hd__clkinv_1 U4683 ( .A(n7131), .Y(n7134) );
  sky130_fd_sc_hd__clkinv_1 U4684 ( .A(n7769), .Y(n7771) );
  sky130_fd_sc_hd__clkinv_1 U4685 ( .A(n5828), .Y(n5856) );
  sky130_fd_sc_hd__clkinv_1 U4686 ( .A(n4799), .Y(n8048) );
  sky130_fd_sc_hd__clkinv_1 U4687 ( .A(n5916), .Y(n8305) );
  sky130_fd_sc_hd__clkinv_1 U4688 ( .A(n6080), .Y(n4589) );
  sky130_fd_sc_hd__clkinv_1 U4689 ( .A(n8287), .Y(n8289) );
  sky130_fd_sc_hd__clkinv_1 U4690 ( .A(n8390), .Y(n8392) );
  sky130_fd_sc_hd__clkinv_1 U4691 ( .A(n8515), .Y(n8389) );
  sky130_fd_sc_hd__clkinv_1 U4692 ( .A(n8388), .Y(n8516) );
  sky130_fd_sc_hd__clkinv_1 U4693 ( .A(n8047), .Y(n4800) );
  sky130_fd_sc_hd__clkinv_1 U4694 ( .A(n9522), .Y(n4831) );
  sky130_fd_sc_hd__clkinv_1 U4695 ( .A(n4802), .Y(n4804) );
  sky130_fd_sc_hd__clkinv_1 U4696 ( .A(n7388), .Y(n7390) );
  sky130_fd_sc_hd__clkinv_1 U4697 ( .A(n5705), .Y(n5706) );
  sky130_fd_sc_hd__clkinv_1 U4698 ( .A(n10093), .Y(n10090) );
  sky130_fd_sc_hd__clkinv_1 U4699 ( .A(n10129), .Y(n4323) );
  sky130_fd_sc_hd__clkinv_1 U4700 ( .A(n4532), .Y(n4376) );
  sky130_fd_sc_hd__clkinv_1 U4701 ( .A(n5660), .Y(n5661) );
  sky130_fd_sc_hd__clkinv_1 U4702 ( .A(n6076), .Y(n6432) );
  sky130_fd_sc_hd__clkinv_1 U4703 ( .A(n7608), .Y(n6748) );
  sky130_fd_sc_hd__clkinv_1 U4704 ( .A(n10094), .Y(n5414) );
  sky130_fd_sc_hd__clkinv_1 U4705 ( .A(n7603), .Y(n7605) );
  sky130_fd_sc_hd__clkinv_1 U4706 ( .A(n8108), .Y(n8110) );
  sky130_fd_sc_hd__clkinv_1 U4707 ( .A(n8104), .Y(n8105) );
  sky130_fd_sc_hd__clkinv_1 U4708 ( .A(mem_la_wdata[3]), .Y(n9953) );
  sky130_fd_sc_hd__clkinv_1 U4709 ( .A(mem_la_wdata[2]), .Y(n9951) );
  sky130_fd_sc_hd__clkinv_1 U4710 ( .A(mem_la_wdata[1]), .Y(n9949) );
  sky130_fd_sc_hd__clkinv_1 U4711 ( .A(mem_la_wdata[0]), .Y(n9947) );
  sky130_fd_sc_hd__clkinv_1 U4712 ( .A(mem_la_wdata[7]), .Y(n9961) );
  sky130_fd_sc_hd__clkinv_1 U4713 ( .A(mem_la_wdata[6]), .Y(n9959) );
  sky130_fd_sc_hd__clkinv_1 U4714 ( .A(mem_la_wdata[5]), .Y(n9957) );
  sky130_fd_sc_hd__clkinv_1 U4715 ( .A(n9587), .Y(n9662) );
  sky130_fd_sc_hd__clkinv_1 U4716 ( .A(n5006), .Y(n5007) );
  sky130_fd_sc_hd__clkinv_1 U4717 ( .A(n9277), .Y(n4529) );
  sky130_fd_sc_hd__and2_0 U4718 ( .A(decoded_imm_j[15]), .B(n5988), .X(n4942)
         );
  sky130_fd_sc_hd__or2_1 U4719 ( .A(n9813), .B(n5967), .X(n4814) );
  sky130_fd_sc_hd__clkinv_1 U4720 ( .A(n5029), .Y(n5031) );
  sky130_fd_sc_hd__or2_1 U4721 ( .A(n9813), .B(latched_stalu), .X(n7893) );
  sky130_fd_sc_hd__clkinv_1 U4722 ( .A(n4487), .Y(n4488) );
  sky130_fd_sc_hd__clkinv_1 U4723 ( .A(n6034), .Y(n10044) );
  sky130_fd_sc_hd__clkinv_1 U4724 ( .A(n10138), .Y(n9944) );
  sky130_fd_sc_hd__clkinv_1 U4725 ( .A(n4484), .Y(n4489) );
  sky130_fd_sc_hd__clkinv_1 U4726 ( .A(n6865), .Y(n6866) );
  sky130_fd_sc_hd__clkinv_1 U4727 ( .A(n6863), .Y(n6867) );
  sky130_fd_sc_hd__and2_0 U4728 ( .A(decoded_imm_j[16]), .B(n5988), .X(n7303)
         );
  sky130_fd_sc_hd__clkinv_1 U4729 ( .A(n5704), .Y(n5707) );
  sky130_fd_sc_hd__clkinv_1 U4730 ( .A(n5657), .Y(n5662) );
  sky130_fd_sc_hd__clkinv_1 U4731 ( .A(n5020), .Y(n5023) );
  sky130_fd_sc_hd__inv_2 U4732 ( .A(n10122), .Y(n5983) );
  sky130_fd_sc_hd__clkinv_1 U4733 ( .A(n5859), .Y(n5871) );
  sky130_fd_sc_hd__clkinv_1 U4734 ( .A(n4536), .Y(n4377) );
  sky130_fd_sc_hd__clkinv_1 U4735 ( .A(n4531), .Y(n4378) );
  sky130_fd_sc_hd__clkinv_1 U4736 ( .A(n8719), .Y(n9338) );
  sky130_fd_sc_hd__clkinv_1 U4737 ( .A(n5799), .Y(n5800) );
  sky130_fd_sc_hd__clkinv_1 U4738 ( .A(n9885), .Y(n4660) );
  sky130_fd_sc_hd__clkinv_1 U4739 ( .A(n5011), .Y(n5014) );
  sky130_fd_sc_hd__inv_2 U4740 ( .A(n10133), .Y(n9943) );
  sky130_fd_sc_hd__and2_0 U4741 ( .A(decoded_imm_j[3]), .B(n5988), .X(n4896)
         );
  sky130_fd_sc_hd__clkinv_1 U4742 ( .A(n7043), .Y(n7047) );
  sky130_fd_sc_hd__clkinv_1 U4743 ( .A(n7044), .Y(n7045) );
  sky130_fd_sc_hd__clkinv_1 U4744 ( .A(n5072), .Y(n5073) );
  sky130_fd_sc_hd__and2_0 U4745 ( .A(decoded_imm_j[4]), .B(n5988), .X(n4897)
         );
  sky130_fd_sc_hd__and2_0 U4746 ( .A(n5988), .B(decoded_imm_j[18]), .X(n4951)
         );
  sky130_fd_sc_hd__clkinv_1 U4747 ( .A(n5197), .Y(n5221) );
  sky130_fd_sc_hd__clkinv_1 U4748 ( .A(n7957), .Y(n7960) );
  sky130_fd_sc_hd__clkinv_1 U4749 ( .A(n6196), .Y(n6191) );
  sky130_fd_sc_hd__clkinv_1 U4750 ( .A(n9871), .Y(n9876) );
  sky130_fd_sc_hd__clkinv_1 U4751 ( .A(n4415), .Y(n4416) );
  sky130_fd_sc_hd__clkinv_1 U4752 ( .A(n6683), .Y(n6684) );
  sky130_fd_sc_hd__and2_0 U4753 ( .A(decoded_imm_j[19]), .B(n5988), .X(n4952)
         );
  sky130_fd_sc_hd__clkinv_1 U4754 ( .A(n4413), .Y(n4417) );
  sky130_fd_sc_hd__clkinv_1 U4755 ( .A(n9267), .Y(n9268) );
  sky130_fd_sc_hd__clkinv_1 U4756 ( .A(n5690), .Y(n5691) );
  sky130_fd_sc_hd__clkinv_1 U4757 ( .A(n7039), .Y(n5445) );
  sky130_fd_sc_hd__clkinv_1 U4758 ( .A(n5830), .Y(n5831) );
  sky130_fd_sc_hd__clkinv_1 U4759 ( .A(n7961), .Y(n8059) );
  sky130_fd_sc_hd__clkinv_1 U4760 ( .A(n8168), .Y(n5446) );
  sky130_fd_sc_hd__clkinv_1 U4761 ( .A(n6868), .Y(n7786) );
  sky130_fd_sc_hd__clkinv_1 U4762 ( .A(n5055), .Y(n5056) );
  sky130_fd_sc_hd__clkinv_1 U4763 ( .A(n7785), .Y(n6869) );
  sky130_fd_sc_hd__clkinv_1 U4764 ( .A(n7219), .Y(n6480) );
  sky130_fd_sc_hd__clkinv_1 U4765 ( .A(n6322), .Y(n6324) );
  sky130_fd_sc_hd__clkinv_1 U4766 ( .A(n6481), .Y(n6483) );
  sky130_fd_sc_hd__clkinv_1 U4767 ( .A(n7048), .Y(n7618) );
  sky130_fd_sc_hd__clkinv_1 U4768 ( .A(n4530), .Y(n8923) );
  sky130_fd_sc_hd__clkinv_1 U4769 ( .A(n8960), .Y(n4541) );
  sky130_fd_sc_hd__clkinv_1 U4770 ( .A(n6791), .Y(n7427) );
  sky130_fd_sc_hd__clkinv_1 U4771 ( .A(n5724), .Y(n5725) );
  sky130_fd_sc_hd__clkinv_1 U4772 ( .A(n5708), .Y(n5709) );
  sky130_fd_sc_hd__clkinv_1 U4773 ( .A(n8922), .Y(n4379) );
  sky130_fd_sc_hd__clkinv_1 U4774 ( .A(n7426), .Y(n6792) );
  sky130_fd_sc_hd__clkinv_1 U4775 ( .A(n6793), .Y(n6795) );
  sky130_fd_sc_hd__clkinv_1 U4776 ( .A(n6585), .Y(n6587) );
  sky130_fd_sc_hd__clkinv_1 U4777 ( .A(n7320), .Y(n6584) );
  sky130_fd_sc_hd__clkinv_1 U4778 ( .A(n5024), .Y(n5025) );
  sky130_fd_sc_hd__clkinv_1 U4779 ( .A(n9352), .Y(n9354) );
  sky130_fd_sc_hd__clkinv_1 U4780 ( .A(n4276), .Y(n4277) );
  sky130_fd_sc_hd__clkinv_1 U4781 ( .A(n5968), .Y(n5938) );
  sky130_fd_sc_hd__clkinv_1 U4782 ( .A(n4420), .Y(n4422) );
  sky130_fd_sc_hd__clkinv_1 U4783 ( .A(n7135), .Y(n7137) );
  sky130_fd_sc_hd__inv_2 U4784 ( .A(n4817), .Y(n10206) );
  sky130_fd_sc_hd__clkinv_1 U4785 ( .A(n9074), .Y(n9076) );
  sky130_fd_sc_hd__clkinv_1 U4786 ( .A(n8815), .Y(n4419) );
  sky130_fd_sc_hd__clkinv_1 U4787 ( .A(n4418), .Y(n8816) );
  sky130_fd_sc_hd__clkinv_1 U4788 ( .A(n7556), .Y(n5937) );
  sky130_fd_sc_hd__clkinv_1 U4789 ( .A(n5873), .Y(n5877) );
  sky130_fd_sc_hd__clkinv_1 U4790 ( .A(n7699), .Y(n7701) );
  sky130_fd_sc_hd__and2_1 U4791 ( .A(latched_rd[0]), .B(n6207), .X(n6232) );
  sky130_fd_sc_hd__clkinv_1 U4792 ( .A(n5015), .Y(n5016) );
  sky130_fd_sc_hd__clkinv_1 U4793 ( .A(n6358), .Y(n6359) );
  sky130_fd_sc_hd__clkinv_1 U4794 ( .A(n4670), .Y(n4672) );
  sky130_fd_sc_hd__clkinv_1 U4795 ( .A(n4372), .Y(n6850) );
  sky130_fd_sc_hd__clkinv_1 U4796 ( .A(n6338), .Y(n7871) );
  sky130_fd_sc_hd__clkinv_1 U4797 ( .A(n6848), .Y(n6849) );
  sky130_fd_sc_hd__clkinv_1 U4798 ( .A(n7050), .Y(n7052) );
  sky130_fd_sc_hd__clkinv_1 U4799 ( .A(n7617), .Y(n7049) );
  sky130_fd_sc_hd__clkinv_1 U4800 ( .A(n8851), .Y(n4491) );
  sky130_fd_sc_hd__clkinv_1 U4801 ( .A(n4492), .Y(n4494) );
  sky130_fd_sc_hd__clkinv_1 U4802 ( .A(n5675), .Y(n5676) );
  sky130_fd_sc_hd__clkinv_1 U4803 ( .A(n7613), .Y(n5453) );
  sky130_fd_sc_hd__clkinv_1 U4804 ( .A(n5223), .Y(n5227) );
  sky130_fd_sc_hd__clkinv_1 U4805 ( .A(n5845), .Y(n5846) );
  sky130_fd_sc_hd__clkinv_1 U4806 ( .A(n7438), .Y(n7440) );
  sky130_fd_sc_hd__clkinv_1 U4807 ( .A(n5067), .Y(n5068) );
  sky130_fd_sc_hd__clkinv_1 U4808 ( .A(n8752), .Y(n9110) );
  sky130_fd_sc_hd__clkinv_1 U4809 ( .A(n4767), .Y(n4769) );
  sky130_fd_sc_hd__clkinv_1 U4810 ( .A(n7963), .Y(n7965) );
  sky130_fd_sc_hd__clkinv_1 U4811 ( .A(n8058), .Y(n7962) );
  sky130_fd_sc_hd__clkinv_1 U4812 ( .A(n8191), .Y(n8193) );
  sky130_fd_sc_hd__clkinv_1 U4813 ( .A(n7870), .Y(n6339) );
  sky130_fd_sc_hd__clkinv_1 U4814 ( .A(n6340), .Y(n6342) );
  sky130_fd_sc_hd__clkinv_1 U4815 ( .A(n9028), .Y(n5454) );
  sky130_fd_sc_hd__clkinv_1 U4816 ( .A(n6752), .Y(n5436) );
  sky130_fd_sc_hd__clkinv_1 U4817 ( .A(n6467), .Y(n6469) );
  sky130_fd_sc_hd__clkinv_1 U4818 ( .A(n6122), .Y(n5439) );
  sky130_fd_sc_hd__clkinv_1 U4819 ( .A(n7516), .Y(n5434) );
  sky130_fd_sc_hd__clkinv_1 U4820 ( .A(n5769), .Y(n5770) );
  sky130_fd_sc_hd__clkinv_1 U4821 ( .A(n8303), .Y(n4633) );
  sky130_fd_sc_hd__clkinv_1 U4822 ( .A(n9334), .Y(n9336) );
  sky130_fd_sc_hd__clkinv_1 U4823 ( .A(n6500), .Y(n6501) );
  sky130_fd_sc_hd__clkinv_1 U4824 ( .A(n6464), .Y(n8782) );
  sky130_fd_sc_hd__clkinv_1 U4825 ( .A(n6756), .Y(n6758) );
  sky130_fd_sc_hd__clkinv_1 U4826 ( .A(n5032), .Y(n5033) );
  sky130_fd_sc_hd__clkinv_1 U4827 ( .A(n8781), .Y(n6465) );
  sky130_fd_sc_hd__clkinv_1 U4828 ( .A(n8716), .Y(n8718) );
  sky130_fd_sc_hd__clkinv_1 U4829 ( .A(n5166), .Y(n5167) );
  sky130_fd_sc_hd__clkinv_1 U4830 ( .A(n7126), .Y(n5440) );
  sky130_fd_sc_hd__clkinv_1 U4831 ( .A(n5037), .Y(n5038) );
  sky130_fd_sc_hd__clkinv_1 U4832 ( .A(n6479), .Y(n7220) );
  sky130_fd_sc_hd__clkinv_1 U4833 ( .A(n8322), .Y(n9549) );
  sky130_fd_sc_hd__clkinv_1 U4834 ( .A(n4648), .Y(n8304) );
  sky130_fd_sc_hd__clkinv_1 U4835 ( .A(n5739), .Y(n5740) );
  sky130_fd_sc_hd__clkinv_1 U4836 ( .A(n6437), .Y(n5435) );
  sky130_fd_sc_hd__clkinv_1 U4837 ( .A(reg_next_pc[2]), .Y(n9917) );
  sky130_fd_sc_hd__clkinv_1 U4838 ( .A(count_cycle[10]), .Y(n5205) );
  sky130_fd_sc_hd__clkinv_1 U4839 ( .A(count_cycle[3]), .Y(n5224) );
  sky130_fd_sc_hd__clkinv_1 U4840 ( .A(mem_addr[7]), .Y(n9976) );
  sky130_fd_sc_hd__clkinv_1 U4841 ( .A(count_cycle[14]), .Y(n5176) );
  sky130_fd_sc_hd__clkinv_1 U4842 ( .A(pcpi_rs2[4]), .Y(n9897) );
  sky130_fd_sc_hd__clkinv_1 U4843 ( .A(mem_addr[8]), .Y(n9978) );
  sky130_fd_sc_hd__clkinv_1 U4844 ( .A(mem_do_rinst), .Y(n9910) );
  sky130_fd_sc_hd__clkinv_1 U4845 ( .A(instr_sb), .Y(n10128) );
  sky130_fd_sc_hd__clkinv_1 U4846 ( .A(count_cycle[25]), .Y(n5155) );
  sky130_fd_sc_hd__clkinv_1 U4847 ( .A(pcpi_rs2[22]), .Y(n9901) );
  sky130_fd_sc_hd__clkinv_1 U4848 ( .A(mem_addr[6]), .Y(n9974) );
  sky130_fd_sc_hd__clkinv_1 U4849 ( .A(pcpi_rs2[5]), .Y(n9899) );
  sky130_fd_sc_hd__clkinv_1 U4850 ( .A(mem_addr[5]), .Y(n9972) );
  sky130_fd_sc_hd__clkinv_1 U4851 ( .A(mem_wordsize[0]), .Y(n9906) );
  sky130_fd_sc_hd__clkinv_1 U4852 ( .A(pcpi_rs2[15]), .Y(n5450) );
  sky130_fd_sc_hd__clkinv_1 U4853 ( .A(count_cycle[16]), .Y(n5194) );
  sky130_fd_sc_hd__clkinv_1 U4854 ( .A(count_cycle[32]), .Y(n5183) );
  sky130_fd_sc_hd__clkinv_1 U4855 ( .A(reg_pc[9]), .Y(n9701) );
  sky130_fd_sc_hd__clkinv_1 U4856 ( .A(mem_addr[3]), .Y(n9968) );
  sky130_fd_sc_hd__clkinv_1 U4857 ( .A(latched_rd[4]), .Y(n6188) );
  sky130_fd_sc_hd__clkinv_1 U4858 ( .A(count_cycle[24]), .Y(n5147) );
  sky130_fd_sc_hd__clkinv_1 U4859 ( .A(count_cycle[33]), .Y(n5158) );
  sky130_fd_sc_hd__clkinv_1 U4860 ( .A(reg_pc[8]), .Y(n9664) );
  sky130_fd_sc_hd__clkinv_1 U4861 ( .A(instr_srli), .Y(n10115) );
  sky130_fd_sc_hd__clkinv_1 U4862 ( .A(count_cycle[13]), .Y(n5192) );
  sky130_fd_sc_hd__clkinv_1 U4863 ( .A(count_cycle[8]), .Y(n5218) );
  sky130_fd_sc_hd__clkinv_1 U4864 ( .A(count_cycle[11]), .Y(n5188) );
  sky130_fd_sc_hd__clkinv_1 U4865 ( .A(mem_addr[2]), .Y(n9966) );
  sky130_fd_sc_hd__clkinv_1 U4866 ( .A(count_cycle[18]), .Y(n5174) );
  sky130_fd_sc_hd__clkinv_1 U4867 ( .A(count_instr[1]), .Y(n5880) );
  sky130_fd_sc_hd__clkinv_1 U4868 ( .A(reg_out[28]), .Y(n5262) );
  sky130_fd_sc_hd__clkinv_1 U4869 ( .A(cpu_state[5]), .Y(n9449) );
  sky130_fd_sc_hd__clkinv_1 U4870 ( .A(count_cycle[23]), .Y(n5075) );
  sky130_fd_sc_hd__clkinv_1 U4871 ( .A(count_cycle[5]), .Y(n5215) );
  sky130_fd_sc_hd__clkinv_1 U4872 ( .A(reg_next_pc[8]), .Y(n9929) );
  sky130_fd_sc_hd__clkinv_1 U4873 ( .A(reg_next_pc[9]), .Y(n9931) );
  sky130_fd_sc_hd__clkinv_1 U4874 ( .A(reg_pc[2]), .Y(n9389) );
  sky130_fd_sc_hd__clkinv_1 U4875 ( .A(reg_next_pc[10]), .Y(n9933) );
  sky130_fd_sc_hd__clkinv_1 U4876 ( .A(reg_next_pc[7]), .Y(n9927) );
  sky130_fd_sc_hd__clkinv_1 U4877 ( .A(count_cycle[4]), .Y(n5220) );
  sky130_fd_sc_hd__clkinv_1 U4878 ( .A(count_cycle[21]), .Y(n5151) );
  sky130_fd_sc_hd__clkinv_1 U4879 ( .A(reg_next_pc[6]), .Y(n9925) );
  sky130_fd_sc_hd__clkinv_1 U4880 ( .A(reg_pc[1]), .Y(n9181) );
  sky130_fd_sc_hd__clkinv_1 U4881 ( .A(latched_is_lu), .Y(n5947) );
  sky130_fd_sc_hd__clkinv_1 U4882 ( .A(reg_pc[27]), .Y(n9811) );
  sky130_fd_sc_hd__clkinv_1 U4883 ( .A(count_cycle[28]), .Y(n5093) );
  sky130_fd_sc_hd__clkinv_1 U4884 ( .A(reg_pc[19]), .Y(n6976) );
  sky130_fd_sc_hd__clkinv_1 U4885 ( .A(reg_pc[11]), .Y(n7985) );
  sky130_fd_sc_hd__clkinv_1 U4886 ( .A(mem_rdata_q[22]), .Y(n8584) );
  sky130_fd_sc_hd__clkinv_1 U4887 ( .A(reg_next_pc[11]), .Y(n9935) );
  sky130_fd_sc_hd__clkinv_1 U4888 ( .A(count_cycle[6]), .Y(n5212) );
  sky130_fd_sc_hd__clkinv_1 U4889 ( .A(reg_pc[22]), .Y(n7627) );
  sky130_fd_sc_hd__clkinv_1 U4890 ( .A(N1570), .Y(n9222) );
  sky130_fd_sc_hd__clkinv_1 U4891 ( .A(count_cycle[1]), .Y(n5230) );
  sky130_fd_sc_hd__clkinv_1 U4892 ( .A(reg_next_pc[12]), .Y(n9937) );
  sky130_fd_sc_hd__inv_2 U4893 ( .A(decoded_imm_j[4]), .Y(n9432) );
  sky130_fd_sc_hd__clkinv_1 U4894 ( .A(count_cycle[31]), .Y(n5018) );
  sky130_fd_sc_hd__clkinv_1 U4895 ( .A(mem_addr[26]), .Y(n10014) );
  sky130_fd_sc_hd__clkinv_1 U4896 ( .A(count_cycle[20]), .Y(n5161) );
  sky130_fd_sc_hd__clkinv_1 U4897 ( .A(instr_bne), .Y(n9008) );
  sky130_fd_sc_hd__clkinv_1 U4898 ( .A(count_cycle[27]), .Y(n5063) );
  sky130_fd_sc_hd__clkinv_1 U4899 ( .A(pcpi_rs2[0]), .Y(n9888) );
  sky130_fd_sc_hd__clkinv_1 U4900 ( .A(reg_next_pc[5]), .Y(n9923) );
  sky130_fd_sc_hd__clkinv_1 U4901 ( .A(instr_srai), .Y(n5895) );
  sky130_fd_sc_hd__clkinv_1 U4902 ( .A(pcpi_rs2[9]), .Y(n5433) );
  sky130_fd_sc_hd__clkinv_1 U4903 ( .A(reg_pc[29]), .Y(n6127) );
  sky130_fd_sc_hd__clkinv_1 U4904 ( .A(count_cycle[30]), .Y(n5081) );
  sky130_fd_sc_hd__clkinv_1 U4905 ( .A(latched_is_lh), .Y(n6251) );
  sky130_fd_sc_hd__clkinv_1 U4906 ( .A(mem_do_wdata), .Y(n10139) );
  sky130_fd_sc_hd__clkinv_1 U4907 ( .A(reg_next_pc[4]), .Y(n9921) );
  sky130_fd_sc_hd__inv_2 U4908 ( .A(decoded_imm_j[3]), .Y(n6004) );
  sky130_fd_sc_hd__clkinv_1 U4909 ( .A(count_cycle[19]), .Y(n5138) );
  sky130_fd_sc_hd__clkinv_1 U4910 ( .A(count_cycle[12]), .Y(n5203) );
  sky130_fd_sc_hd__clkinv_1 U4911 ( .A(count_cycle[2]), .Y(n5228) );
  sky130_fd_sc_hd__clkinv_1 U4912 ( .A(latched_rd[3]), .Y(n4809) );
  sky130_fd_sc_hd__clkinv_1 U4913 ( .A(mem_addr[12]), .Y(n9986) );
  sky130_fd_sc_hd__clkinv_1 U4914 ( .A(reg_next_pc[3]), .Y(n9919) );
  sky130_fd_sc_hd__clkinv_1 U4915 ( .A(count_cycle[26]), .Y(n5115) );
  sky130_fd_sc_hd__clkinv_1 U4916 ( .A(count_cycle[9]), .Y(n5208) );
  sky130_fd_sc_hd__clkinv_1 U4917 ( .A(count_cycle[17]), .Y(n5180) );
  sky130_fd_sc_hd__clkinv_1 U4918 ( .A(mem_addr[10]), .Y(n9982) );
  sky130_fd_sc_hd__clkinv_1 U4919 ( .A(pcpi_rs2[12]), .Y(n4822) );
  sky130_fd_sc_hd__clkinv_1 U4920 ( .A(mem_addr[9]), .Y(n9980) );
  sky130_fd_sc_hd__clkinv_1 U4921 ( .A(pcpi_rs2[16]), .Y(n9889) );
  sky130_fd_sc_hd__clkinv_1 U4922 ( .A(reg_pc[23]), .Y(n7063) );
  sky130_fd_sc_hd__clkinv_1 U4923 ( .A(is_alu_reg_imm), .Y(n10120) );
  sky130_fd_sc_hd__clkinv_1 U4924 ( .A(count_instr[18]), .Y(n5820) );
  sky130_fd_sc_hd__clkinv_1 U4925 ( .A(mem_rdata_q[24]), .Y(n8362) );
  sky130_fd_sc_hd__clkinv_1 U4926 ( .A(instr_sub), .Y(n6035) );
  sky130_fd_sc_hd__clkinv_1 U4927 ( .A(count_instr[9]), .Y(n5853) );
  sky130_fd_sc_hd__clkinv_1 U4928 ( .A(count_instr[38]), .Y(n5744) );
  sky130_fd_sc_hd__clkinv_1 U4929 ( .A(is_alu_reg_reg), .Y(n10091) );
  sky130_fd_sc_hd__clkinv_1 U4930 ( .A(instr_sltiu), .Y(n10042) );
  sky130_fd_sc_hd__clkinv_1 U4931 ( .A(is_lui_auipc_jal), .Y(n5991) );
  sky130_fd_sc_hd__clkinv_1 U4932 ( .A(count_instr[37]), .Y(n5749) );
  sky130_fd_sc_hd__clkinv_1 U4933 ( .A(count_instr[36]), .Y(n5752) );
  sky130_fd_sc_hd__clkinv_1 U4934 ( .A(count_cycle[51]), .Y(n5040) );
  sky130_fd_sc_hd__clkinv_1 U4935 ( .A(count_instr[8]), .Y(n5857) );
  sky130_fd_sc_hd__clkinv_1 U4936 ( .A(count_instr[19]), .Y(n5816) );
  sky130_fd_sc_hd__clkinv_1 U4937 ( .A(instr_lui), .Y(n5420) );
  sky130_fd_sc_hd__clkinv_1 U4938 ( .A(count_instr[35]), .Y(n5757) );
  sky130_fd_sc_hd__clkinv_1 U4939 ( .A(count_cycle[50]), .Y(n5090) );
  sky130_fd_sc_hd__clkinv_1 U4940 ( .A(instr_bgeu), .Y(n9004) );
  sky130_fd_sc_hd__clkinv_1 U4941 ( .A(count_instr[34]), .Y(n5884) );
  sky130_fd_sc_hd__clkinv_1 U4942 ( .A(count_instr[20]), .Y(n5812) );
  sky130_fd_sc_hd__clkinv_1 U4943 ( .A(count_instr[33]), .Y(n5759) );
  sky130_fd_sc_hd__clkinv_1 U4944 ( .A(reg_out[23]), .Y(n4849) );
  sky130_fd_sc_hd__clkinv_1 U4945 ( .A(count_instr[32]), .Y(n5763) );
  sky130_fd_sc_hd__clkinv_1 U4946 ( .A(count_cycle[38]), .Y(n5111) );
  sky130_fd_sc_hd__clkinv_1 U4947 ( .A(reg_pc[13]), .Y(n6462) );
  sky130_fd_sc_hd__clkinv_1 U4948 ( .A(count_instr[7]), .Y(n5861) );
  sky130_fd_sc_hd__clkinv_1 U4949 ( .A(count_instr[31]), .Y(n5772) );
  sky130_fd_sc_hd__clkinv_1 U4950 ( .A(mem_rdata_q[27]), .Y(n8463) );
  sky130_fd_sc_hd__clkinv_1 U4951 ( .A(count_cycle[39]), .Y(n5070) );
  sky130_fd_sc_hd__clkinv_1 U4952 ( .A(mem_rdata_q[21]), .Y(n8612) );
  sky130_fd_sc_hd__clkinv_1 U4953 ( .A(reg_pc[5]), .Y(n9550) );
  sky130_fd_sc_hd__clkinv_1 U4954 ( .A(count_instr[5]), .Y(n5868) );
  sky130_fd_sc_hd__clkinv_1 U4955 ( .A(count_cycle[53]), .Y(n5052) );
  sky130_fd_sc_hd__clkinv_1 U4956 ( .A(count_instr[57]), .Y(n5667) );
  sky130_fd_sc_hd__clkinv_1 U4957 ( .A(count_cycle[47]), .Y(n5027) );
  sky130_fd_sc_hd__clkinv_1 U4958 ( .A(count_instr[47]), .Y(n5711) );
  sky130_fd_sc_hd__clkinv_1 U4959 ( .A(count_cycle[57]), .Y(n5004) );
  sky130_fd_sc_hd__clkinv_1 U4960 ( .A(count_cycle[56]), .Y(n5078) );
  sky130_fd_sc_hd__clkinv_1 U4961 ( .A(count_instr[16]), .Y(n5825) );
  sky130_fd_sc_hd__clkinv_1 U4962 ( .A(count_instr[48]), .Y(n5702) );
  sky130_fd_sc_hd__clkinv_1 U4963 ( .A(count_cycle[46]), .Y(n5084) );
  sky130_fd_sc_hd__clkinv_1 U4964 ( .A(count_instr[46]), .Y(n5713) );
  sky130_fd_sc_hd__clkinv_1 U4965 ( .A(reg_pc[17]), .Y(n6846) );
  sky130_fd_sc_hd__clkinv_1 U4966 ( .A(count_instr[49]), .Y(n5698) );
  sky130_fd_sc_hd__clkinv_1 U4967 ( .A(count_instr[15]), .Y(n5833) );
  sky130_fd_sc_hd__clkinv_1 U4968 ( .A(count_cycle[44]), .Y(n5096) );
  sky130_fd_sc_hd__clkinv_1 U4969 ( .A(count_instr[45]), .Y(n5718) );
  sky130_fd_sc_hd__clkinv_1 U4970 ( .A(count_instr[50]), .Y(n5695) );
  sky130_fd_sc_hd__clkinv_1 U4971 ( .A(instr_xor), .Y(n4300) );
  sky130_fd_sc_hd__clkinv_1 U4972 ( .A(instr_slt), .Y(n10045) );
  sky130_fd_sc_hd__clkinv_1 U4973 ( .A(count_cycle[45]), .Y(n5048) );
  sky130_fd_sc_hd__clkinv_1 U4974 ( .A(instr_jalr), .Y(n10119) );
  sky130_fd_sc_hd__clkinv_1 U4975 ( .A(instr_slti), .Y(n10039) );
  sky130_fd_sc_hd__clkinv_1 U4976 ( .A(count_instr[44]), .Y(n5720) );
  sky130_fd_sc_hd__clkinv_1 U4977 ( .A(count_instr[14]), .Y(n5835) );
  sky130_fd_sc_hd__clkinv_1 U4978 ( .A(count_instr[52]), .Y(n5687) );
  sky130_fd_sc_hd__clkinv_1 U4979 ( .A(reg_pc[4]), .Y(n8323) );
  sky130_fd_sc_hd__clkinv_1 U4980 ( .A(is_lb_lh_lw_lbu_lhu), .Y(n10099) );
  sky130_fd_sc_hd__clkinv_1 U4981 ( .A(reg_pc[14]), .Y(n7811) );
  sky130_fd_sc_hd__or2_0 U4982 ( .A(decoded_imm[0]), .B(pcpi_rs1[0]), .X(n9451) );
  sky130_fd_sc_hd__clkinv_1 U4983 ( .A(count_instr[43]), .Y(n5727) );
  sky130_fd_sc_hd__clkinv_1 U4984 ( .A(instr_beq), .Y(n9548) );
  sky130_fd_sc_hd__clkinv_1 U4985 ( .A(is_slli_srli_srai), .Y(n10118) );
  sky130_fd_sc_hd__clkinv_1 U4986 ( .A(count_instr[53]), .Y(n5685) );
  sky130_fd_sc_hd__clkinv_1 U4987 ( .A(count_cycle[42]), .Y(n5105) );
  sky130_fd_sc_hd__clkinv_1 U4988 ( .A(count_instr[12]), .Y(n5843) );
  sky130_fd_sc_hd__clkinv_1 U4989 ( .A(mem_rdata_q[3]), .Y(n4793) );
  sky130_fd_sc_hd__clkinv_1 U4990 ( .A(mem_rdata_q[14]), .Y(n10096) );
  sky130_fd_sc_hd__clkinv_1 U4991 ( .A(count_instr[54]), .Y(n5680) );
  sky130_fd_sc_hd__clkinv_1 U4992 ( .A(count_cycle[48]), .Y(n5132) );
  sky130_fd_sc_hd__clkinv_1 U4993 ( .A(reg_out[14]), .Y(n4922) );
  sky130_fd_sc_hd__clkinv_1 U4994 ( .A(count_instr[17]), .Y(n5823) );
  sky130_fd_sc_hd__clkinv_1 U4995 ( .A(reg_pc[25]), .Y(n6688) );
  sky130_fd_sc_hd__clkinv_1 U4996 ( .A(reg_out[13]), .Y(n4925) );
  sky130_fd_sc_hd__clkinv_1 U4997 ( .A(count_cycle[43]), .Y(n5058) );
  sky130_fd_sc_hd__clkinv_1 U4998 ( .A(count_instr[42]), .Y(n5729) );
  sky130_fd_sc_hd__clkinv_1 U4999 ( .A(count_instr[11]), .Y(n5848) );
  sky130_fd_sc_hd__clkinv_1 U5000 ( .A(instr_bltu), .Y(n10037) );
  sky130_fd_sc_hd__clkinv_1 U5001 ( .A(count_cycle[41]), .Y(n5108) );
  sky130_fd_sc_hd__clkinv_1 U5002 ( .A(mem_rdata_q[20]), .Y(n4781) );
  sky130_fd_sc_hd__clkinv_1 U5003 ( .A(instr_sltu), .Y(n10047) );
  sky130_fd_sc_hd__clkinv_1 U5004 ( .A(count_instr[41]), .Y(n5732) );
  sky130_fd_sc_hd__clkinv_1 U5005 ( .A(reg_pc[15]), .Y(n6885) );
  sky130_fd_sc_hd__clkinv_1 U5006 ( .A(count_instr[55]), .Y(n5678) );
  sky130_fd_sc_hd__clkinv_1 U5007 ( .A(count_cycle[49]), .Y(n5102) );
  sky130_fd_sc_hd__clkinv_1 U5008 ( .A(count_instr[40]), .Y(n5736) );
  sky130_fd_sc_hd__clkinv_1 U5009 ( .A(count_instr[56]), .Y(n5669) );
  sky130_fd_sc_hd__clkinv_1 U5010 ( .A(count_cycle[40]), .Y(n5135) );
  sky130_fd_sc_hd__clkinv_1 U5011 ( .A(instr_and), .Y(n4294) );
  sky130_fd_sc_hd__clkinv_1 U5012 ( .A(cpu_state[1]), .Y(n9884) );
  sky130_fd_sc_hd__clkinv_1 U5013 ( .A(count_instr[10]), .Y(n5850) );
  sky130_fd_sc_hd__clkinv_1 U5014 ( .A(count_instr[39]), .Y(n5742) );
  sky130_fd_sc_hd__clkinv_1 U5015 ( .A(is_sb_sh_sw), .Y(n10111) );
  sky130_fd_sc_hd__clkinv_1 U5016 ( .A(instr_andi), .Y(n4293) );
  sky130_fd_sc_hd__clkinv_1 U5017 ( .A(count_instr[2]), .Y(n5878) );
  sky130_fd_sc_hd__clkinv_1 U5018 ( .A(instr_rdcycle), .Y(n5411) );
  sky130_fd_sc_hd__clkinv_1 U5019 ( .A(count_instr[27]), .Y(n5785) );
  sky130_fd_sc_hd__clkinv_1 U5020 ( .A(count_cycle[58]), .Y(n5009) );
  sky130_fd_sc_hd__clkinv_1 U5021 ( .A(reg_pc[12]), .Y(n8779) );
  sky130_fd_sc_hd__clkinv_1 U5022 ( .A(reg_pc[3]), .Y(n8723) );
  sky130_fd_sc_hd__clkinv_1 U5023 ( .A(count_instr[3]), .Y(n5874) );
  sky130_fd_sc_hd__clkinv_1 U5024 ( .A(count_instr[25]), .Y(n5792) );
  sky130_fd_sc_hd__clkinv_1 U5025 ( .A(trap), .Y(n10061) );
  sky130_fd_sc_hd__clkinv_1 U5026 ( .A(count_instr[22]), .Y(n5806) );
  sky130_fd_sc_hd__clkinv_1 U5027 ( .A(mem_rdata_q[30]), .Y(n8081) );
  sky130_fd_sc_hd__inv_2 U5028 ( .A(cpu_state[2]), .Y(n5423) );
  sky130_fd_sc_hd__clkinv_1 U5029 ( .A(reg_out[26]), .Y(n4843) );
  sky130_fd_sc_hd__clkinv_1 U5030 ( .A(count_cycle[34]), .Y(n5144) );
  sky130_fd_sc_hd__clkinv_1 U5031 ( .A(count_instr[4]), .Y(n5870) );
  sky130_fd_sc_hd__clkinv_1 U5032 ( .A(count_instr[30]), .Y(n5774) );
  sky130_fd_sc_hd__clkinv_1 U5033 ( .A(count_instr[28]), .Y(n5781) );
  sky130_fd_sc_hd__clkinv_1 U5034 ( .A(latched_rd[0]), .Y(n4664) );
  sky130_fd_sc_hd__clkinv_1 U5035 ( .A(count_instr[26]), .Y(n5789) );
  sky130_fd_sc_hd__clkinv_1 U5036 ( .A(count_cycle[35]), .Y(n5125) );
  sky130_fd_sc_hd__clkinv_1 U5037 ( .A(instr_blt), .Y(n10035) );
  sky130_fd_sc_hd__clkinv_1 U5038 ( .A(count_instr[24]), .Y(n5796) );
  sky130_fd_sc_hd__clkinv_1 U5039 ( .A(reg_pc[24]), .Y(n7542) );
  sky130_fd_sc_hd__clkinv_1 U5040 ( .A(instr_srl), .Y(n10053) );
  sky130_fd_sc_hd__clkinv_1 U5041 ( .A(mem_state[1]), .Y(n10076) );
  sky130_fd_sc_hd__clkinv_1 U5042 ( .A(latched_rd[1]), .Y(n6194) );
  sky130_fd_sc_hd__clkinv_1 U5043 ( .A(instr_lw), .Y(n10100) );
  sky130_fd_sc_hd__clkinv_1 U5044 ( .A(count_cycle[36]), .Y(n5142) );
  sky130_fd_sc_hd__clkinv_1 U5045 ( .A(count_cycle[54]), .Y(n5087) );
  sky130_fd_sc_hd__clkinv_1 U5046 ( .A(latched_branch), .Y(n4665) );
  sky130_fd_sc_hd__clkinv_1 U5047 ( .A(count_instr[23]), .Y(n5802) );
  sky130_fd_sc_hd__clkinv_1 U5048 ( .A(reg_pc[7]), .Y(n9626) );
  sky130_fd_sc_hd__clkinv_1 U5049 ( .A(reg_pc[6]), .Y(n9624) );
  sky130_fd_sc_hd__clkinv_1 U5050 ( .A(count_cycle[55]), .Y(n5035) );
  sky130_fd_sc_hd__clkinv_1 U5051 ( .A(reg_pc[18]), .Y(n8881) );
  sky130_fd_sc_hd__nor2_2 U5052 ( .A(n4306), .B(n4637), .Y(n9524) );
  sky130_fd_sc_hd__nand2_4 U5053 ( .A(latched_branch), .B(latched_store), .Y(
        n4841) );
  sky130_fd_sc_hd__inv_2 U5054 ( .A(n4845), .Y(n9911) );
  sky130_fd_sc_hd__inv_2 U5055 ( .A(n4498), .Y(n9452) );
  sky130_fd_sc_hd__nand2_2 U5056 ( .A(n4319), .B(n6030), .Y(n4498) );
  sky130_fd_sc_hd__nor2_1 U5057 ( .A(n6004), .B(n6000), .Y(n8659) );
  sky130_fd_sc_hd__buf_4 U5058 ( .A(n5387), .X(n4216) );
  sky130_fd_sc_hd__nor2_1 U5059 ( .A(n4957), .B(n5296), .Y(n5387) );
  sky130_fd_sc_hd__and2_1 U5060 ( .A(n8658), .B(n8650), .X(n6059) );
  sky130_fd_sc_hd__and2_1 U5061 ( .A(n8660), .B(n8649), .X(n8471) );
  sky130_fd_sc_hd__inv_2 U5062 ( .A(n4215), .Y(n6019) );
  sky130_fd_sc_hd__buf_6 U5063 ( .A(n6496), .X(n4217) );
  sky130_fd_sc_hd__a21oi_1 U5064 ( .A1(n6294), .A2(n4949), .B1(n4948), .Y(
        n6496) );
  sky130_fd_sc_hd__nor2_2 U5065 ( .A(n9223), .B(n9218), .Y(n9276) );
  sky130_fd_sc_hd__nor2_2 U5066 ( .A(n9964), .B(n10069), .Y(n10136) );
  sky130_fd_sc_hd__nor2_2 U5067 ( .A(n6203), .B(n6202), .Y(n6237) );
  sky130_fd_sc_hd__nand2_4 U5068 ( .A(n10055), .B(n4662), .Y(n6202) );
  sky130_fd_sc_hd__and2_2 U5069 ( .A(n8657), .B(n8649), .X(n8489) );
  sky130_fd_sc_hd__and2_2 U5070 ( .A(n8657), .B(n8650), .X(n8465) );
  sky130_fd_sc_hd__and2_2 U5071 ( .A(n8657), .B(n8668), .X(n8472) );
  sky130_fd_sc_hd__and2_2 U5072 ( .A(n8657), .B(n8669), .X(n6412) );
  sky130_fd_sc_hd__inv_2 U5073 ( .A(instr_rdcycleh), .Y(n4626) );
  sky130_fd_sc_hd__clkinv_1 U5074 ( .A(n4414), .Y(n6326) );
  sky130_fd_sc_hd__clkinv_1 U5075 ( .A(n4999), .Y(n5182) );
  sky130_fd_sc_hd__clkinv_1 U5076 ( .A(decoded_imm_j[16]), .Y(n4250) );
  sky130_fd_sc_hd__inv_2 U5077 ( .A(n9870), .Y(n4563) );
  sky130_fd_sc_hd__clkinv_1 U5078 ( .A(n6596), .Y(n9774) );
  sky130_fd_sc_hd__inv_2 U5079 ( .A(n9304), .Y(n4701) );
  sky130_fd_sc_hd__and2_0 U5080 ( .A(decoded_imm_j[1]), .B(n5988), .X(n9175)
         );
  sky130_fd_sc_hd__inv_2 U5081 ( .A(pcpi_rs1[5]), .Y(n9106) );
  sky130_fd_sc_hd__and2_0 U5082 ( .A(decoded_imm_j[17]), .B(n5988), .X(n4950)
         );
  sky130_fd_sc_hd__nor2_1 U5083 ( .A(n5947), .B(n10124), .Y(n7705) );
  sky130_fd_sc_hd__and2_0 U5084 ( .A(n5988), .B(decoded_imm_j[13]), .X(n4940)
         );
  sky130_fd_sc_hd__and2_0 U5085 ( .A(decoded_imm_j[11]), .B(n5988), .X(n4936)
         );
  sky130_fd_sc_hd__inv_2 U5086 ( .A(n4801), .Y(n8050) );
  sky130_fd_sc_hd__and2_0 U5087 ( .A(n5988), .B(decoded_imm_j[9]), .X(n4934)
         );
  sky130_fd_sc_hd__inv_2 U5088 ( .A(n7705), .Y(n6876) );
  sky130_fd_sc_hd__inv_2 U5089 ( .A(N254), .Y(n5982) );
  sky130_fd_sc_hd__inv_2 U5090 ( .A(instr_rdinstrh), .Y(n4291) );
  sky130_fd_sc_hd__nand2_1 U5091 ( .A(n5404), .B(n4311), .Y(n9531) );
  sky130_fd_sc_hd__clkinv_1 U5092 ( .A(n9939), .Y(n9942) );
  sky130_fd_sc_hd__nand2_1 U5093 ( .A(n9340), .B(n4698), .Y(n9454) );
  sky130_fd_sc_hd__inv_2 U5094 ( .A(decoded_imm_j[11]), .Y(n9227) );
  sky130_fd_sc_hd__inv_2 U5095 ( .A(n10124), .Y(n9859) );
  sky130_fd_sc_hd__nand2_1 U5096 ( .A(n9174), .B(n9175), .Y(n9367) );
  sky130_fd_sc_hd__a21boi_0 U5097 ( .A1(n9857), .A2(count_instr[5]), .B1_N(
        n4641), .Y(n4642) );
  sky130_fd_sc_hd__nand2_1 U5098 ( .A(n9521), .B(resetn), .Y(n10029) );
  sky130_fd_sc_hd__nand2_1 U5099 ( .A(n4556), .B(n4555), .Y(n9877) );
  sky130_fd_sc_hd__and2_1 U5100 ( .A(n10055), .B(n5616), .X(n9370) );
  sky130_fd_sc_hd__and2_0 U5101 ( .A(n4655), .B(n4654), .X(n4240) );
  sky130_fd_sc_hd__clkinv_1 U5102 ( .A(n5658), .Y(n5762) );
  sky130_fd_sc_hd__inv_2 U5103 ( .A(cpu_state[6]), .Y(n9883) );
  sky130_fd_sc_hd__and2_0 U5104 ( .A(n5229), .B(resetn), .X(n10203) );
  sky130_fd_sc_hd__and2_0 U5105 ( .A(n5213), .B(resetn), .X(n10198) );
  sky130_fd_sc_hd__and2_0 U5106 ( .A(n5219), .B(resetn), .X(n10200) );
  sky130_fd_sc_hd__and2_0 U5107 ( .A(n5175), .B(resetn), .X(n10187) );
  sky130_fd_sc_hd__and2_0 U5108 ( .A(n5163), .B(resetn), .X(n10184) );
  sky130_fd_sc_hd__and2_0 U5109 ( .A(n5121), .B(resetn), .X(n10172) );
  sky130_fd_sc_hd__and2_0 U5110 ( .A(n5149), .B(resetn), .X(n10180) );
  sky130_fd_sc_hd__and2_0 U5111 ( .A(n5116), .B(resetn), .X(n10170) );
  sky130_fd_sc_hd__and2_0 U5112 ( .A(n5184), .B(resetn), .X(n10190) );
  sky130_fd_sc_hd__and2_0 U5113 ( .A(n5136), .B(resetn), .X(n10176) );
  sky130_fd_sc_hd__and2_0 U5114 ( .A(n5133), .B(resetn), .X(n10175) );
  sky130_fd_sc_hd__clkinv_1 U5115 ( .A(n8650), .Y(n6016) );
  sky130_fd_sc_hd__clkinv_1 U5116 ( .A(n4748), .Y(n8937) );
  sky130_fd_sc_hd__nor2_1 U5117 ( .A(n8402), .B(n8401), .Y(n8970) );
  sky130_fd_sc_hd__clkinv_1 U5118 ( .A(n6014), .Y(n8660) );
  sky130_fd_sc_hd__nor2_1 U5119 ( .A(decoded_imm_j[3]), .B(n5994), .Y(n8657)
         );
  sky130_fd_sc_hd__clkinv_1 U5120 ( .A(n6009), .Y(n8658) );
  sky130_fd_sc_hd__clkinv_1 U5121 ( .A(decoded_imm_j[2]), .Y(n5993) );
  sky130_fd_sc_hd__and2_0 U5122 ( .A(latched_rd[0]), .B(n6196), .X(n6222) );
  sky130_fd_sc_hd__a21oi_1 U5123 ( .A1(n10076), .A2(n10073), .B1(n4817), .Y(
        n10063) );
  sky130_fd_sc_hd__clkinv_1 U5124 ( .A(n4966), .Y(n4303) );
  sky130_fd_sc_hd__and2_1 U5125 ( .A(n8660), .B(n8668), .X(n8502) );
  sky130_fd_sc_hd__nor2_1 U5126 ( .A(n6015), .B(n6003), .Y(n8499) );
  sky130_fd_sc_hd__and2_1 U5127 ( .A(n8661), .B(n8669), .X(n8501) );
  sky130_fd_sc_hd__nor2_1 U5128 ( .A(n6015), .B(n6014), .Y(n8477) );
  sky130_fd_sc_hd__and2_1 U5129 ( .A(n8658), .B(n8668), .X(n8482) );
  sky130_fd_sc_hd__and2_1 U5130 ( .A(n8658), .B(n8649), .X(n8480) );
  sky130_fd_sc_hd__clkinv_1 U5131 ( .A(\cpuregs[26][7] ), .Y(n8468) );
  sky130_fd_sc_hd__nor2_1 U5132 ( .A(n6015), .B(n6009), .Y(n8464) );
  sky130_fd_sc_hd__nor2_1 U5133 ( .A(n6020), .B(n6003), .Y(n8488) );
  sky130_fd_sc_hd__and2_1 U5134 ( .A(n8662), .B(n8650), .X(n8490) );
  sky130_fd_sc_hd__nor2_1 U5135 ( .A(n6014), .B(n6016), .Y(n8492) );
  sky130_fd_sc_hd__clkinv_1 U5136 ( .A(n4254), .Y(n9316) );
  sky130_fd_sc_hd__inv_2 U5137 ( .A(pcpi_rs1[26]), .Y(n8918) );
  sky130_fd_sc_hd__nor2_1 U5138 ( .A(n4270), .B(n4281), .Y(n9482) );
  sky130_fd_sc_hd__inv_2 U5139 ( .A(pcpi_rs1[29]), .Y(n5562) );
  sky130_fd_sc_hd__nor2_1 U5140 ( .A(n4267), .B(n4280), .Y(n9471) );
  sky130_fd_sc_hd__nor2_1 U5141 ( .A(n4270), .B(n4267), .Y(n9321) );
  sky130_fd_sc_hd__and2_0 U5142 ( .A(n5988), .B(decoded_imm_j[5]), .X(n4900)
         );
  sky130_fd_sc_hd__and2_0 U5143 ( .A(n5988), .B(decoded_imm_j[6]), .X(n4901)
         );
  sky130_fd_sc_hd__and2_0 U5144 ( .A(n5988), .B(decoded_imm_j[14]), .X(n4941)
         );
  sky130_fd_sc_hd__and2_0 U5145 ( .A(n5988), .B(decoded_imm_j[12]), .X(n4937)
         );
  sky130_fd_sc_hd__and2_0 U5146 ( .A(n5988), .B(decoded_imm_j[10]), .X(n4935)
         );
  sky130_fd_sc_hd__inv_2 U5147 ( .A(pcpi_rs1[9]), .Y(n8819) );
  sky130_fd_sc_hd__and2_0 U5148 ( .A(n5988), .B(decoded_imm_j[8]), .X(n4903)
         );
  sky130_fd_sc_hd__and2_0 U5149 ( .A(n5988), .B(decoded_imm_j[7]), .X(n4902)
         );
  sky130_fd_sc_hd__nand2_1 U5150 ( .A(n6224), .B(n6232), .Y(n6365) );
  sky130_fd_sc_hd__nand2_1 U5151 ( .A(n6224), .B(n6229), .Y(n6515) );
  sky130_fd_sc_hd__and2_0 U5152 ( .A(n6237), .B(n6220), .X(n4225) );
  sky130_fd_sc_hd__inv_2 U5153 ( .A(n4814), .Y(n9815) );
  sky130_fd_sc_hd__and2_0 U5154 ( .A(n10120), .B(n10099), .X(n5981) );
  sky130_fd_sc_hd__nand2b_1 U5155 ( .A_N(n10063), .B(n10068), .Y(n5404) );
  sky130_fd_sc_hd__inv_2 U5156 ( .A(n4665), .Y(n9813) );
  sky130_fd_sc_hd__inv_2 U5157 ( .A(cpu_state[0]), .Y(n5232) );
  sky130_fd_sc_hd__or2_0 U5158 ( .A(n4765), .B(n9506), .X(n4238) );
  sky130_fd_sc_hd__inv_2 U5159 ( .A(pcpi_rs1[24]), .Y(n7541) );
  sky130_fd_sc_hd__inv_2 U5160 ( .A(pcpi_rs1[27]), .Y(n8931) );
  sky130_fd_sc_hd__inv_2 U5161 ( .A(pcpi_rs1[25]), .Y(n8932) );
  sky130_fd_sc_hd__inv_2 U5162 ( .A(pcpi_rs1[28]), .Y(n7191) );
  sky130_fd_sc_hd__and2_0 U5163 ( .A(n4511), .B(n4510), .X(n4232) );
  sky130_fd_sc_hd__clkinv_1 U5164 ( .A(pcpi_rs2[1]), .Y(n9890) );
  sky130_fd_sc_hd__clkinv_1 U5165 ( .A(pcpi_rs2[2]), .Y(n9892) );
  sky130_fd_sc_hd__clkinv_1 U5166 ( .A(pcpi_rs2[6]), .Y(n9900) );
  sky130_fd_sc_hd__clkinv_1 U5167 ( .A(pcpi_rs2[7]), .Y(n9903) );
  sky130_fd_sc_hd__clkinv_1 U5168 ( .A(n9234), .Y(n9264) );
  sky130_fd_sc_hd__inv_2 U5169 ( .A(n4216), .Y(n5324) );
  sky130_fd_sc_hd__nand3_1 U5170 ( .A(n4852), .B(n4851), .C(n4850), .Y(n7698)
         );
  sky130_fd_sc_hd__inv_2 U5171 ( .A(n9543), .Y(n9881) );
  sky130_fd_sc_hd__and3_1 U5172 ( .A(n9184), .B(n9183), .C(n9182), .X(n9217)
         );
  sky130_fd_sc_hd__and2_0 U5173 ( .A(n9158), .B(n9356), .X(n9159) );
  sky130_fd_sc_hd__and2_1 U5174 ( .A(n4668), .B(n4667), .X(n8555) );
  sky130_fd_sc_hd__nand2_1 U5175 ( .A(n8131), .B(n5946), .Y(n7707) );
  sky130_fd_sc_hd__clkinv_1 U5176 ( .A(mem_rdata_word[15]), .Y(n6877) );
  sky130_fd_sc_hd__a21oi_1 U5177 ( .A1(n4923), .A2(n4922), .B1(n4921), .Y(
        n7869) );
  sky130_fd_sc_hd__and2_0 U5178 ( .A(pcpi_rs2[14]), .B(pcpi_rs1[14]), .X(n5437) );
  sky130_fd_sc_hd__inv_2 U5179 ( .A(n4225), .Y(n9621) );
  sky130_fd_sc_hd__inv_2 U5180 ( .A(n4220), .Y(n10057) );
  sky130_fd_sc_hd__and2_1 U5181 ( .A(n9740), .B(n9739), .X(n9773) );
  sky130_fd_sc_hd__clkinv_1 U5182 ( .A(n8683), .Y(n9873) );
  sky130_fd_sc_hd__nor2_1 U5183 ( .A(n4560), .B(n4559), .Y(n9872) );
  sky130_fd_sc_hd__inv_2 U5184 ( .A(n4200), .Y(n9772) );
  sky130_fd_sc_hd__inv_2 U5185 ( .A(n4237), .Y(n9820) );
  sky130_fd_sc_hd__and2_1 U5186 ( .A(n9629), .B(n9628), .X(n9661) );
  sky130_fd_sc_hd__inv_2 U5187 ( .A(n5989), .Y(n7932) );
  sky130_fd_sc_hd__nor2_1 U5188 ( .A(n4837), .B(n4836), .Y(n4305) );
  sky130_fd_sc_hd__clkinv_1 U5189 ( .A(instr_lb), .Y(n10097) );
  sky130_fd_sc_hd__and2_0 U5190 ( .A(mem_rdata_q[1]), .B(mem_rdata_q[0]), .X(
        n4815) );
  sky130_fd_sc_hd__clkinv_1 U5191 ( .A(n10052), .Y(n10050) );
  sky130_fd_sc_hd__clkinv_1 U5192 ( .A(mem_rdata[29]), .Y(n10025) );
  sky130_fd_sc_hd__clkinv_1 U5193 ( .A(mem_rdata[28]), .Y(n10024) );
  sky130_fd_sc_hd__clkinv_1 U5194 ( .A(mem_rdata[27]), .Y(n10023) );
  sky130_fd_sc_hd__clkinv_1 U5195 ( .A(mem_rdata[26]), .Y(n10022) );
  sky130_fd_sc_hd__clkinv_1 U5196 ( .A(mem_rdata[8]), .Y(n10085) );
  sky130_fd_sc_hd__clkinv_1 U5197 ( .A(mem_rdata[9]), .Y(n10083) );
  sky130_fd_sc_hd__clkinv_1 U5198 ( .A(mem_rdata[10]), .Y(n10081) );
  sky130_fd_sc_hd__clkinv_1 U5199 ( .A(mem_rdata[11]), .Y(n10079) );
  sky130_fd_sc_hd__inv_2 U5200 ( .A(n4827), .Y(n4816) );
  sky130_fd_sc_hd__nand3_1 U5201 ( .A(n4316), .B(n10129), .C(n10139), .Y(n5406) );
  sky130_fd_sc_hd__clkinv_1 U5202 ( .A(n9990), .Y(mem_la_addr[14]) );
  sky130_fd_sc_hd__clkinv_1 U5203 ( .A(n9992), .Y(mem_la_addr[15]) );
  sky130_fd_sc_hd__clkinv_1 U5204 ( .A(n9994), .Y(mem_la_addr[16]) );
  sky130_fd_sc_hd__clkinv_1 U5205 ( .A(n9996), .Y(mem_la_addr[17]) );
  sky130_fd_sc_hd__clkinv_1 U5206 ( .A(n9998), .Y(mem_la_addr[18]) );
  sky130_fd_sc_hd__clkinv_1 U5207 ( .A(n10000), .Y(mem_la_addr[19]) );
  sky130_fd_sc_hd__clkinv_1 U5208 ( .A(n10002), .Y(mem_la_addr[20]) );
  sky130_fd_sc_hd__clkinv_1 U5209 ( .A(n10004), .Y(mem_la_addr[21]) );
  sky130_fd_sc_hd__clkinv_1 U5210 ( .A(n10006), .Y(mem_la_addr[22]) );
  sky130_fd_sc_hd__clkinv_1 U5211 ( .A(n10008), .Y(mem_la_addr[23]) );
  sky130_fd_sc_hd__clkinv_1 U5212 ( .A(n10010), .Y(mem_la_addr[24]) );
  sky130_fd_sc_hd__clkinv_1 U5213 ( .A(n10016), .Y(mem_la_addr[27]) );
  sky130_fd_sc_hd__and2_0 U5214 ( .A(n9451), .B(n9450), .X(n9510) );
  sky130_fd_sc_hd__clkinv_1 U5215 ( .A(pcpi_rs2[23]), .Y(n9904) );
  sky130_fd_sc_hd__clkinv_1 U5216 ( .A(pcpi_rs2[21]), .Y(n9898) );
  sky130_fd_sc_hd__clkinv_1 U5217 ( .A(pcpi_rs2[20]), .Y(n9896) );
  sky130_fd_sc_hd__clkinv_1 U5218 ( .A(pcpi_rs2[17]), .Y(n9891) );
  sky130_fd_sc_hd__clkinv_1 U5219 ( .A(pcpi_rs2[18]), .Y(n9893) );
  sky130_fd_sc_hd__clkinv_1 U5220 ( .A(pcpi_rs2[10]), .Y(n4823) );
  sky130_fd_sc_hd__clkinv_1 U5221 ( .A(pcpi_rs2[19]), .Y(n9895) );
  sky130_fd_sc_hd__clkinv_1 U5222 ( .A(pcpi_rs2[11]), .Y(n4820) );
  sky130_fd_sc_hd__clkinv_1 U5223 ( .A(pcpi_rs2[13]), .Y(n4819) );
  sky130_fd_sc_hd__clkinv_1 U5224 ( .A(pcpi_rs2[14]), .Y(n4821) );
  sky130_fd_sc_hd__and2_0 U5225 ( .A(n9176), .B(n9367), .X(n9177) );
  sky130_fd_sc_hd__and2_0 U5226 ( .A(n4643), .B(n4642), .X(n4235) );
  sky130_fd_sc_hd__clkinv_1 U5227 ( .A(n6498), .Y(n4034) );
  sky130_fd_sc_hd__clkinv_1 U5228 ( .A(n6298), .Y(n4042) );
  sky130_fd_sc_hd__and2_0 U5229 ( .A(n4656), .B(n4240), .X(n4234) );
  sky130_fd_sc_hd__and2_0 U5230 ( .A(n5231), .B(resetn), .X(n10204) );
  sky130_fd_sc_hd__and2_0 U5231 ( .A(n5226), .B(resetn), .X(n10202) );
  sky130_fd_sc_hd__and2_0 U5232 ( .A(n5222), .B(resetn), .X(n10201) );
  sky130_fd_sc_hd__and2_0 U5233 ( .A(n5216), .B(resetn), .X(n10199) );
  sky130_fd_sc_hd__and2_0 U5234 ( .A(n5201), .B(resetn), .X(n10194) );
  sky130_fd_sc_hd__and2_0 U5235 ( .A(n5210), .B(resetn), .X(n10197) );
  sky130_fd_sc_hd__and2_0 U5236 ( .A(n5207), .B(resetn), .X(n10196) );
  sky130_fd_sc_hd__and2_0 U5237 ( .A(n5189), .B(resetn), .X(n10191) );
  sky130_fd_sc_hd__and2_0 U5238 ( .A(n5204), .B(resetn), .X(n10195) );
  sky130_fd_sc_hd__and2_0 U5239 ( .A(n5193), .B(resetn), .X(n10192) );
  sky130_fd_sc_hd__and2_0 U5240 ( .A(n5178), .B(resetn), .X(n10188) );
  sky130_fd_sc_hd__and2_0 U5241 ( .A(n5170), .B(resetn), .X(n10185) );
  sky130_fd_sc_hd__and2_0 U5242 ( .A(n5196), .B(resetn), .X(n10193) );
  sky130_fd_sc_hd__and2_0 U5243 ( .A(n5181), .B(resetn), .X(n10189) );
  sky130_fd_sc_hd__and2_0 U5244 ( .A(n5140), .B(resetn), .X(n10177) );
  sky130_fd_sc_hd__and2_0 U5245 ( .A(n5153), .B(resetn), .X(n10181) );
  sky130_fd_sc_hd__and2_0 U5246 ( .A(n5077), .B(resetn), .X(n10157) );
  sky130_fd_sc_hd__and2_0 U5247 ( .A(n5157), .B(resetn), .X(n10182) );
  sky130_fd_sc_hd__and2_0 U5248 ( .A(n5065), .B(resetn), .X(n10155) );
  sky130_fd_sc_hd__and2_0 U5249 ( .A(n5095), .B(resetn), .X(n10163) );
  sky130_fd_sc_hd__and2_0 U5250 ( .A(n5045), .B(resetn), .X(n10150) );
  sky130_fd_sc_hd__and2_0 U5251 ( .A(n5083), .B(resetn), .X(n10159) );
  sky130_fd_sc_hd__and2_0 U5252 ( .A(n5019), .B(resetn), .X(n10146) );
  sky130_fd_sc_hd__and2_0 U5253 ( .A(n5160), .B(resetn), .X(n10183) );
  sky130_fd_sc_hd__and2_0 U5254 ( .A(n5146), .B(resetn), .X(n10179) );
  sky130_fd_sc_hd__and2_0 U5255 ( .A(n5126), .B(resetn), .X(n10173) );
  sky130_fd_sc_hd__and2_0 U5256 ( .A(n5143), .B(resetn), .X(n10178) );
  sky130_fd_sc_hd__and2_0 U5257 ( .A(n5130), .B(resetn), .X(n10174) );
  sky130_fd_sc_hd__and2_0 U5258 ( .A(n5113), .B(resetn), .X(n10169) );
  sky130_fd_sc_hd__and2_0 U5259 ( .A(n5071), .B(resetn), .X(n10156) );
  sky130_fd_sc_hd__and2_0 U5260 ( .A(n5110), .B(resetn), .X(n10168) );
  sky130_fd_sc_hd__and2_0 U5261 ( .A(n5107), .B(resetn), .X(n10167) );
  sky130_fd_sc_hd__and2_0 U5262 ( .A(n5059), .B(resetn), .X(n10153) );
  sky130_fd_sc_hd__and2_0 U5263 ( .A(n5098), .B(resetn), .X(n10164) );
  sky130_fd_sc_hd__and2_0 U5264 ( .A(n5049), .B(resetn), .X(n10151) );
  sky130_fd_sc_hd__and2_0 U5265 ( .A(n5086), .B(resetn), .X(n10160) );
  sky130_fd_sc_hd__and2_0 U5266 ( .A(n5028), .B(resetn), .X(n10147) );
  sky130_fd_sc_hd__and2_0 U5267 ( .A(n5104), .B(resetn), .X(n10166) );
  sky130_fd_sc_hd__and2_0 U5268 ( .A(n5092), .B(resetn), .X(n10162) );
  sky130_fd_sc_hd__and2_0 U5269 ( .A(n5041), .B(resetn), .X(n10149) );
  sky130_fd_sc_hd__and2_0 U5270 ( .A(n5101), .B(resetn), .X(n10165) );
  sky130_fd_sc_hd__and2_0 U5271 ( .A(n5053), .B(resetn), .X(n10152) );
  sky130_fd_sc_hd__and2_0 U5272 ( .A(n5089), .B(resetn), .X(n10161) );
  sky130_fd_sc_hd__and2_0 U5273 ( .A(n5036), .B(resetn), .X(n10148) );
  sky130_fd_sc_hd__and2_0 U5274 ( .A(n5080), .B(resetn), .X(n10158) );
  sky130_fd_sc_hd__and2_0 U5275 ( .A(n5005), .B(resetn), .X(n10144) );
  sky130_fd_sc_hd__and2_0 U5276 ( .A(n5010), .B(resetn), .X(n10145) );
  sky130_fd_sc_hd__and2_0 U5277 ( .A(n5172), .B(resetn), .X(n10186) );
  sky130_fd_sc_hd__and2_0 U5278 ( .A(n5118), .B(resetn), .X(n10171) );
  sky130_fd_sc_hd__and2_0 U5279 ( .A(n5061), .B(resetn), .X(n10154) );
  sky130_fd_sc_hd__and2_0 U5280 ( .A(n4998), .B(resetn), .X(n10143) );
  sky130_fd_sc_hd__and2_0 U5281 ( .A(n4996), .B(resetn), .X(n10142) );
  sky130_fd_sc_hd__nor2_2 U5282 ( .A(n10206), .B(n10086), .Y(n10087) );
  sky130_fd_sc_hd__nor2_2 U5283 ( .A(n4270), .B(n4278), .Y(n9473) );
  sky130_fd_sc_hd__nor2_2 U5284 ( .A(n4266), .B(n4281), .Y(n9492) );
  sky130_fd_sc_hd__nand2_4 U5285 ( .A(n6242), .B(n6232), .Y(n6396) );
  sky130_fd_sc_hd__nor2_2 U5286 ( .A(n4266), .B(n4278), .Y(n9480) );
  sky130_fd_sc_hd__nor2_2 U5287 ( .A(n4280), .B(n4278), .Y(n9485) );
  sky130_fd_sc_hd__nor2_4 U5288 ( .A(decoded_imm_j[3]), .B(n6000), .Y(n6001)
         );
  sky130_fd_sc_hd__nor2_2 U5289 ( .A(n4279), .B(n4278), .Y(n9495) );
  sky130_fd_sc_hd__nor2_2 U5290 ( .A(n4270), .B(n4271), .Y(n9457) );
  sky130_fd_sc_hd__nor2_2 U5291 ( .A(n4270), .B(n4282), .Y(n9497) );
  sky130_fd_sc_hd__nor2_2 U5292 ( .A(n4266), .B(n4271), .Y(n9468) );
  sky130_fd_sc_hd__nor2_2 U5293 ( .A(n4279), .B(n4282), .Y(n9481) );
  sky130_fd_sc_hd__and2_1 U5294 ( .A(n6237), .B(n6214), .X(n4220) );
  sky130_fd_sc_hd__and2_1 U5295 ( .A(n6242), .B(n6241), .X(n4221) );
  sky130_fd_sc_hd__a22oi_1 U5296 ( .A1(pcpi_rs1[18]), .A2(n8927), .B1(n4774), 
        .B2(n9511), .Y(n4222) );
  sky130_fd_sc_hd__nand2_2 U5297 ( .A(n10029), .B(n5617), .Y(n5648) );
  sky130_fd_sc_hd__inv_2 U5298 ( .A(n7893), .Y(n9816) );
  sky130_fd_sc_hd__and2_1 U5299 ( .A(n6242), .B(n6220), .X(n4223) );
  sky130_fd_sc_hd__a22o_1 U5300 ( .A1(n9307), .A2(pcpi_rs1[7]), .B1(
        pcpi_rs1[12]), .B2(n4456), .X(n4224) );
  sky130_fd_sc_hd__nand2_2 U5301 ( .A(n4498), .B(n4736), .Y(n4342) );
  sky130_fd_sc_hd__nor2_4 U5302 ( .A(n4638), .B(n4637), .Y(n4639) );
  sky130_fd_sc_hd__nand2_2 U5303 ( .A(n4775), .B(decoder_trigger), .Y(n10122)
         );
  sky130_fd_sc_hd__clkinv_1 U5304 ( .A(resetn), .Y(n10060) );
  sky130_fd_sc_hd__o21a_1 U5305 ( .A1(n7548), .A2(n9454), .B1(n4766), .X(n4227) );
  sky130_fd_sc_hd__o22a_1 U5306 ( .A1(n8849), .A2(n4371), .B1(n7549), .B2(
        n4342), .X(n4228) );
  sky130_fd_sc_hd__o22a_1 U5307 ( .A1(n4321), .A2(n6127), .B1(n7191), .B2(
        n4340), .X(n4229) );
  sky130_fd_sc_hd__mux2_2 U5308 ( .A0(n5562), .A1(n4734), .S(n9340), .X(n4230)
         );
  sky130_fd_sc_hd__inv_2 U5309 ( .A(n9009), .Y(n4627) );
  sky130_fd_sc_hd__clkinv_1 U5310 ( .A(mem_rdata[7]), .Y(n5907) );
  sky130_fd_sc_hd__a22o_1 U5311 ( .A1(\cpuregs[22][29] ), .A2(n8482), .B1(
        n8503), .B2(\cpuregs[24][29] ), .X(n4231) );
  sky130_fd_sc_hd__nor2_1 U5312 ( .A(n6016), .B(n6019), .Y(n4233) );
  sky130_fd_sc_hd__nor2_2 U5313 ( .A(n5413), .B(n4629), .Y(n9857) );
  sky130_fd_sc_hd__clkinv_1 U5314 ( .A(n8204), .Y(n8256) );
  sky130_fd_sc_hd__nor2_1 U5315 ( .A(n4280), .B(n4271), .Y(n9456) );
  sky130_fd_sc_hd__and2_1 U5316 ( .A(n6233), .B(n6222), .X(n4236) );
  sky130_fd_sc_hd__and2_1 U5317 ( .A(n6233), .B(n6220), .X(n4237) );
  sky130_fd_sc_hd__clkinv_1 U5318 ( .A(pcpi_rs1[7]), .Y(n9079) );
  sky130_fd_sc_hd__o21ai_1 U5319 ( .A1(n5883), .A2(n5375), .B1(n5374), .Y(
        n4241) );
  sky130_fd_sc_hd__o21ai_1 U5320 ( .A1(n5883), .A2(n5345), .B1(n5344), .Y(
        n4243) );
  sky130_fd_sc_hd__o21ai_1 U5321 ( .A1(n5883), .A2(n5273), .B1(n5272), .Y(
        n4244) );
  sky130_fd_sc_hd__o21ai_1 U5322 ( .A1(n5883), .A2(n5252), .B1(n5251), .Y(
        n4245) );
  sky130_fd_sc_hd__a22o_1 U5323 ( .A1(n9280), .A2(reg_pc[23]), .B1(n9345), 
        .B2(pcpi_rs1[27]), .X(n4246) );
  sky130_fd_sc_hd__nand3_1 U5324 ( .A(n5402), .B(n5401), .C(n5400), .Y(n5403)
         );
  sky130_fd_sc_hd__clkinv_1 U5325 ( .A(pcpi_rs1[31]), .Y(n5581) );
  sky130_fd_sc_hd__clkinv_1 U5326 ( .A(pcpi_rs2[31]), .Y(n5566) );
  sky130_fd_sc_hd__clkinv_1 U5327 ( .A(is_slti_blt_slt), .Y(n5598) );
  sky130_fd_sc_hd__clkinv_1 U5328 ( .A(n5911), .Y(n4647) );
  sky130_fd_sc_hd__clkinv_1 U5329 ( .A(n4650), .Y(n4634) );
  sky130_fd_sc_hd__clkinv_1 U5330 ( .A(n6572), .Y(n5449) );
  sky130_fd_sc_hd__clkinv_1 U5331 ( .A(n4534), .Y(n4380) );
  sky130_fd_sc_hd__clkinv_1 U5332 ( .A(n5310), .Y(n5311) );
  sky130_fd_sc_hd__clkinv_1 U5333 ( .A(n7570), .Y(n5932) );
  sky130_fd_sc_hd__clkinv_1 U5334 ( .A(n6953), .Y(n7306) );
  sky130_fd_sc_hd__clkinv_1 U5335 ( .A(n5597), .Y(n5606) );
  sky130_fd_sc_hd__nor2_1 U5336 ( .A(n4786), .B(n4297), .Y(n4302) );
  sky130_fd_sc_hd__inv_2 U5337 ( .A(n8656), .Y(n6017) );
  sky130_fd_sc_hd__clkinv_1 U5338 ( .A(n4539), .Y(n4375) );
  sky130_fd_sc_hd__clkinv_1 U5339 ( .A(n9472), .Y(n4254) );
  sky130_fd_sc_hd__clkinv_1 U5340 ( .A(n4619), .Y(n4548) );
  sky130_fd_sc_hd__clkinv_1 U5341 ( .A(n4708), .Y(n4547) );
  sky130_fd_sc_hd__clkinv_1 U5342 ( .A(reg_pc[28]), .Y(n8402) );
  sky130_fd_sc_hd__clkinv_1 U5343 ( .A(n6685), .Y(n6686) );
  sky130_fd_sc_hd__clkinv_1 U5344 ( .A(n5285), .Y(n5286) );
  sky130_fd_sc_hd__clkinv_1 U5345 ( .A(n9356), .Y(n4631) );
  sky130_fd_sc_hd__clkinv_1 U5346 ( .A(n6580), .Y(n6581) );
  sky130_fd_sc_hd__o21ai_1 U5347 ( .A1(n8072), .A2(n8069), .B1(n8070), .Y(
        n7978) );
  sky130_fd_sc_hd__clkinv_1 U5348 ( .A(instr_xori), .Y(n4299) );
  sky130_fd_sc_hd__nor2_1 U5349 ( .A(n6018), .B(n6003), .Y(n8479) );
  sky130_fd_sc_hd__clkinv_1 U5350 ( .A(n9144), .Y(n9146) );
  sky130_fd_sc_hd__clkinv_1 U5351 ( .A(n9112), .Y(n9114) );
  sky130_fd_sc_hd__clkinv_1 U5352 ( .A(n9108), .Y(n9109) );
  sky130_fd_sc_hd__clkinv_1 U5353 ( .A(n6327), .Y(n4433) );
  sky130_fd_sc_hd__clkinv_1 U5354 ( .A(n4490), .Y(n8852) );
  sky130_fd_sc_hd__clkinv_1 U5355 ( .A(n6852), .Y(n6854) );
  sky130_fd_sc_hd__clkinv_1 U5356 ( .A(n8883), .Y(n8885) );
  sky130_fd_sc_hd__clkinv_1 U5357 ( .A(n7544), .Y(n7546) );
  sky130_fd_sc_hd__nor2_1 U5358 ( .A(n4279), .B(n4271), .Y(n9459) );
  sky130_fd_sc_hd__clkinv_1 U5359 ( .A(n7185), .Y(n7187) );
  sky130_fd_sc_hd__clkinv_1 U5360 ( .A(n4515), .Y(n8946) );
  sky130_fd_sc_hd__clkinv_1 U5361 ( .A(n5384), .Y(n5256) );
  sky130_fd_sc_hd__clkinv_1 U5362 ( .A(n5329), .Y(n5331) );
  sky130_fd_sc_hd__clkinv_1 U5363 ( .A(n5334), .Y(n5243) );
  sky130_fd_sc_hd__clkinv_1 U5364 ( .A(n5309), .Y(n5295) );
  sky130_fd_sc_hd__clkinv_1 U5365 ( .A(reg_pc[21]), .Y(n6598) );
  sky130_fd_sc_hd__clkinv_1 U5366 ( .A(decoded_imm_j[1]), .Y(n5995) );
  sky130_fd_sc_hd__clkinv_1 U5367 ( .A(n9866), .Y(n9868) );
  sky130_fd_sc_hd__clkinv_1 U5368 ( .A(n9364), .Y(n9366) );
  sky130_fd_sc_hd__clkinv_1 U5369 ( .A(n5956), .Y(n5958) );
  sky130_fd_sc_hd__clkinv_1 U5370 ( .A(n8236), .Y(n8238) );
  sky130_fd_sc_hd__clkinv_1 U5371 ( .A(n6039), .Y(n6041) );
  sky130_fd_sc_hd__clkinv_1 U5372 ( .A(n6670), .Y(n6672) );
  sky130_fd_sc_hd__clkinv_1 U5373 ( .A(n6583), .Y(n7321) );
  sky130_fd_sc_hd__clkinv_1 U5374 ( .A(n6962), .Y(n6964) );
  sky130_fd_sc_hd__clkinv_1 U5375 ( .A(n7774), .Y(n6569) );
  sky130_fd_sc_hd__clkinv_1 U5376 ( .A(reg_pc[16]), .Y(n7229) );
  sky130_fd_sc_hd__clkinv_1 U5377 ( .A(n6870), .Y(n6872) );
  sky130_fd_sc_hd__clkinv_1 U5378 ( .A(n7958), .Y(n7959) );
  sky130_fd_sc_hd__clkinv_1 U5379 ( .A(n6244), .Y(n6246) );
  sky130_fd_sc_hd__clkinv_1 U5380 ( .A(n8123), .Y(n8125) );
  sky130_fd_sc_hd__clkinv_1 U5381 ( .A(n6207), .Y(n6208) );
  sky130_fd_sc_hd__clkinv_1 U5382 ( .A(n5672), .Y(n5674) );
  sky130_fd_sc_hd__clkinv_1 U5383 ( .A(n5765), .Y(n5768) );
  sky130_fd_sc_hd__clkinv_1 U5384 ( .A(n9534), .Y(n9525) );
  sky130_fd_sc_hd__clkinv_1 U5385 ( .A(n5021), .Y(n5022) );
  sky130_fd_sc_hd__nor2_1 U5386 ( .A(n6066), .B(n4231), .Y(n6067) );
  sky130_fd_sc_hd__clkinv_1 U5387 ( .A(pcpi_rs1[0]), .Y(n9149) );
  sky130_fd_sc_hd__clkinv_1 U5388 ( .A(pcpi_rs1[3]), .Y(n9342) );
  sky130_fd_sc_hd__clkinv_1 U5389 ( .A(n4673), .Y(n9111) );
  sky130_fd_sc_hd__clkinv_1 U5390 ( .A(pcpi_rs1[2]), .Y(n9341) );
  sky130_fd_sc_hd__clkinv_1 U5391 ( .A(pcpi_rs1[6]), .Y(n9117) );
  sky130_fd_sc_hd__clkinv_1 U5392 ( .A(n6466), .Y(n8784) );
  sky130_fd_sc_hd__clkinv_1 U5393 ( .A(pcpi_rs1[18]), .Y(n8880) );
  sky130_fd_sc_hd__clkinv_1 U5394 ( .A(pcpi_rs1[21]), .Y(n7430) );
  sky130_fd_sc_hd__clkinv_1 U5395 ( .A(n6790), .Y(n7428) );
  sky130_fd_sc_hd__clkinv_1 U5396 ( .A(pcpi_rs1[17]), .Y(n8888) );
  sky130_fd_sc_hd__clkinv_1 U5397 ( .A(pcpi_rs1[20]), .Y(n7549) );
  sky130_fd_sc_hd__clkinv_1 U5398 ( .A(pcpi_rs1[23]), .Y(n7548) );
  sky130_fd_sc_hd__clkinv_1 U5399 ( .A(n4322), .Y(n9278) );
  sky130_fd_sc_hd__clkinv_1 U5400 ( .A(reg_out[24]), .Y(n4847) );
  sky130_fd_sc_hd__clkinv_1 U5401 ( .A(n7687), .Y(n7689) );
  sky130_fd_sc_hd__clkinv_1 U5402 ( .A(reg_out[20]), .Y(n4858) );
  sky130_fd_sc_hd__clkinv_1 U5403 ( .A(reg_sh[4]), .Y(n4249) );
  sky130_fd_sc_hd__clkinv_1 U5404 ( .A(N1571), .Y(n4309) );
  sky130_fd_sc_hd__clkinv_1 U5405 ( .A(reg_out[1]), .Y(n4891) );
  sky130_fd_sc_hd__clkinv_1 U5406 ( .A(n7130), .Y(n7569) );
  sky130_fd_sc_hd__a21oi_1 U5407 ( .A1(n6089), .A2(n6088), .B1(n6087), .Y(
        n6657) );
  sky130_fd_sc_hd__clkinv_1 U5408 ( .A(n6431), .Y(n4587) );
  sky130_fd_sc_hd__clkinv_1 U5409 ( .A(pcpi_rs1[13]), .Y(n8785) );
  sky130_fd_sc_hd__clkinv_1 U5410 ( .A(n6864), .Y(n7873) );
  sky130_fd_sc_hd__nand2b_1 U5411 ( .A_N(n4917), .B(reg_out[10]), .Y(n4920) );
  sky130_fd_sc_hd__clkinv_1 U5412 ( .A(n4559), .Y(n4556) );
  sky130_fd_sc_hd__clkinv_1 U5413 ( .A(n6247), .Y(n8127) );
  sky130_fd_sc_hd__clkinv_1 U5414 ( .A(n5754), .Y(n5755) );
  sky130_fd_sc_hd__clkinv_1 U5415 ( .A(n9447), .Y(n9442) );
  sky130_fd_sc_hd__clkinv_1 U5416 ( .A(mem_do_rdata), .Y(n10071) );
  sky130_fd_sc_hd__clkinv_1 U5417 ( .A(n5185), .Y(n5186) );
  sky130_fd_sc_hd__clkinv_1 U5418 ( .A(n5122), .Y(n5123) );
  sky130_fd_sc_hd__clkinv_1 U5419 ( .A(n5985), .Y(n5988) );
  sky130_fd_sc_hd__o2bb2ai_1 U5420 ( .B1(n4457), .B2(n9506), .A1_N(pcpi_rs1[9]), .A2_N(n4456), .Y(n4458) );
  sky130_fd_sc_hd__clkinv_1 U5421 ( .A(pcpi_rs1[11]), .Y(n8820) );
  sky130_fd_sc_hd__clkinv_1 U5422 ( .A(n4732), .Y(n4308) );
  sky130_fd_sc_hd__clkinv_1 U5423 ( .A(n9506), .Y(n8921) );
  sky130_fd_sc_hd__nand3_1 U5424 ( .A(n4386), .B(n4385), .C(n4384), .Y(n4387)
         );
  sky130_fd_sc_hd__clkinv_1 U5425 ( .A(pcpi_rs1[30]), .Y(n9305) );
  sky130_fd_sc_hd__o211ai_1 U5426 ( .A1(n8932), .A2(n4371), .B1(n4229), .C1(
        n4230), .Y(n4552) );
  sky130_fd_sc_hd__clkinv_1 U5427 ( .A(mem_wordsize[1]), .Y(n9905) );
  sky130_fd_sc_hd__a22oi_1 U5428 ( .A1(reg_next_pc[30]), .A2(n9530), .B1(n9370), .B2(n6038), .Y(n5272) );
  sky130_fd_sc_hd__a22oi_1 U5429 ( .A1(reg_next_pc[29]), .A2(n9530), .B1(n9370), .B2(n6125), .Y(n5374) );
  sky130_fd_sc_hd__a22oi_1 U5430 ( .A1(reg_next_pc[27]), .A2(n9530), .B1(n9370), .B2(n7179), .Y(n5251) );
  sky130_fd_sc_hd__clkinv_1 U5431 ( .A(reg_out[25]), .Y(n4870) );
  sky130_fd_sc_hd__clkinv_1 U5432 ( .A(n6747), .Y(n7510) );
  sky130_fd_sc_hd__nand2_1 U5433 ( .A(n8608), .B(decoded_imm_j[31]), .Y(n5986)
         );
  sky130_fd_sc_hd__clkinv_1 U5434 ( .A(n9433), .Y(n9428) );
  sky130_fd_sc_hd__clkinv_1 U5435 ( .A(n4832), .Y(n9224) );
  sky130_fd_sc_hd__clkinv_1 U5436 ( .A(n8387), .Y(n8397) );
  sky130_fd_sc_hd__clkinv_1 U5437 ( .A(n8286), .Y(n8294) );
  sky130_fd_sc_hd__clkinv_1 U5438 ( .A(reg_out[19]), .Y(n4860) );
  sky130_fd_sc_hd__clkinv_1 U5439 ( .A(pcpi_rs1[16]), .Y(n7431) );
  sky130_fd_sc_hd__clkinv_1 U5440 ( .A(pcpi_rs1[15]), .Y(n8849) );
  sky130_fd_sc_hd__clkinv_1 U5441 ( .A(n6288), .Y(n6290) );
  sky130_fd_sc_hd__clkinv_1 U5442 ( .A(n9877), .Y(n9382) );
  sky130_fd_sc_hd__clkinv_1 U5443 ( .A(count_instr[58]), .Y(n5664) );
  sky130_fd_sc_hd__clkinv_1 U5444 ( .A(count_instr[51]), .Y(n5693) );
  sky130_fd_sc_hd__clkinv_1 U5445 ( .A(n5716), .Y(n5721) );
  sky130_fd_sc_hd__clkinv_1 U5446 ( .A(n5747), .Y(n5751) );
  sky130_fd_sc_hd__clkinv_1 U5447 ( .A(count_instr[29]), .Y(n5779) );
  sky130_fd_sc_hd__clkinv_1 U5448 ( .A(count_instr[21]), .Y(n5809) );
  sky130_fd_sc_hd__clkinv_1 U5449 ( .A(count_instr[13]), .Y(n5840) );
  sky130_fd_sc_hd__clkinv_1 U5450 ( .A(count_instr[6]), .Y(n5865) );
  sky130_fd_sc_hd__clkinv_1 U5451 ( .A(n4639), .Y(n9010) );
  sky130_fd_sc_hd__clkinv_1 U5452 ( .A(n5404), .Y(n5899) );
  sky130_fd_sc_hd__clkinv_1 U5453 ( .A(count_cycle[7]), .Y(n5199) );
  sky130_fd_sc_hd__clkinv_1 U5454 ( .A(count_cycle[15]), .Y(n5169) );
  sky130_fd_sc_hd__clkinv_1 U5455 ( .A(count_cycle[22]), .Y(n5120) );
  sky130_fd_sc_hd__clkinv_1 U5456 ( .A(count_cycle[29]), .Y(n5044) );
  sky130_fd_sc_hd__clkinv_1 U5457 ( .A(count_cycle[37]), .Y(n5129) );
  sky130_fd_sc_hd__clkinv_1 U5458 ( .A(n5046), .Y(n5097) );
  sky130_fd_sc_hd__clkinv_1 U5459 ( .A(count_cycle[52]), .Y(n5099) );
  sky130_fd_sc_hd__mux2i_1 U5460 ( .A0(mem_rdata[3]), .A1(mem_rdata_q[3]), .S(
        n4817), .Y(n5429) );
  sky130_fd_sc_hd__a22oi_1 U5461 ( .A1(reg_pc[7]), .A2(n9280), .B1(n9452), 
        .B2(pcpi_rs1[7]), .Y(n4706) );
  sky130_fd_sc_hd__nor2_1 U5462 ( .A(n4387), .B(n4246), .Y(n4388) );
  sky130_fd_sc_hd__clkinv_1 U5463 ( .A(pcpi_rs2[8]), .Y(n4824) );
  sky130_fd_sc_hd__clkinv_1 U5464 ( .A(pcpi_rs2[3]), .Y(n9894) );
  sky130_fd_sc_hd__clkinv_1 U5465 ( .A(mem_rdata[6]), .Y(n8190) );
  sky130_fd_sc_hd__clkinv_1 U5466 ( .A(mem_rdata[15]), .Y(n5908) );
  sky130_fd_sc_hd__clkinv_1 U5467 ( .A(mem_la_wdata[4]), .Y(n9955) );
  sky130_fd_sc_hd__clkinv_1 U5468 ( .A(mem_addr[11]), .Y(n9984) );
  sky130_fd_sc_hd__clkinv_1 U5469 ( .A(mem_addr[4]), .Y(n9970) );
  sky130_fd_sc_hd__clkinv_1 U5470 ( .A(n9234), .Y(n9266) );
  sky130_fd_sc_hd__clkinv_1 U5471 ( .A(reg_pc[26]), .Y(n9776) );
  sky130_fd_sc_hd__clkinv_1 U5472 ( .A(reg_pc[20]), .Y(n7424) );
  sky130_fd_sc_hd__clkinv_1 U5473 ( .A(is_compare), .Y(n9882) );
  sky130_fd_sc_hd__clkinv_1 U5474 ( .A(n4200), .Y(n9209) );
  sky130_fd_sc_hd__and3_1 U5475 ( .A(n9392), .B(n9391), .C(n9390), .X(n9424)
         );
  sky130_fd_sc_hd__and2_1 U5476 ( .A(n8326), .B(n8325), .X(n8358) );
  sky130_fd_sc_hd__and2_1 U5477 ( .A(n9554), .B(n9553), .X(n9586) );
  sky130_fd_sc_hd__and2_1 U5478 ( .A(n9590), .B(n9589), .X(n9623) );
  sky130_fd_sc_hd__clkinv_1 U5479 ( .A(n6577), .Y(n6578) );
  sky130_fd_sc_hd__clkinv_1 U5480 ( .A(reg_pc[10]), .Y(n9737) );
  sky130_fd_sc_hd__clkinv_1 U5481 ( .A(n6299), .Y(n6300) );
  sky130_fd_sc_hd__clkinv_1 U5482 ( .A(n8185), .Y(n8186) );
  sky130_fd_sc_hd__and2_1 U5483 ( .A(n9667), .B(n9666), .X(n9699) );
  sky130_fd_sc_hd__clkinv_1 U5484 ( .A(mem_rdata_q[13]), .Y(n10095) );
  sky130_fd_sc_hd__clkinv_1 U5485 ( .A(mem_rdata_q[12]), .Y(n7933) );
  sky130_fd_sc_hd__clkinv_1 U5486 ( .A(mem_rdata_q[23]), .Y(n8558) );
  sky130_fd_sc_hd__clkinv_1 U5487 ( .A(instr_lhu), .Y(n10107) );
  sky130_fd_sc_hd__clkinv_1 U5488 ( .A(is_beq_bne_blt_bge_bltu_bgeu), .Y(
        n10034) );
  sky130_fd_sc_hd__clkinv_1 U5489 ( .A(instr_sra), .Y(n5898) );
  sky130_fd_sc_hd__clkinv_1 U5490 ( .A(mem_rdata[30]), .Y(n10026) );
  sky130_fd_sc_hd__clkinv_1 U5491 ( .A(mem_rdata[25]), .Y(n10021) );
  sky130_fd_sc_hd__nand2b_1 U5492 ( .A_N(n10086), .B(n10206), .Y(n10089) );
  sky130_fd_sc_hd__clkinv_1 U5493 ( .A(n10086), .Y(n10114) );
  sky130_fd_sc_hd__clkinv_1 U5494 ( .A(n6185), .Y(n2875) );
  sky130_fd_sc_hd__o2bb2ai_1 U5495 ( .B1(n10131), .B2(n4790), .A1_N(n10131), 
        .A2_N(mem_wordsize[1]), .Y(n2831) );
  sky130_fd_sc_hd__o211ai_1 U5496 ( .A1(n9455), .A2(n4371), .B1(n4462), .C1(
        n4461), .Y(n2787) );
  sky130_fd_sc_hd__a21o_1 U5497 ( .A1(n4348), .A2(n9340), .B1(n4347), .X(n2779) );
  sky130_fd_sc_hd__clkinv_1 U5498 ( .A(n10017), .Y(n10205) );
  sky130_fd_sc_hd__a21o_1 U5499 ( .A1(n9030), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n9029), .X(alu_out[31]) );
  sky130_fd_sc_hd__a21o_1 U5500 ( .A1(n4965), .A2(n5794), .B1(n4964), .X(n4025) );
  sky130_fd_sc_hd__a21o_1 U5501 ( .A1(n6754), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n6753), .X(alu_out[25]) );
  sky130_fd_sc_hd__clkinv_1 U5502 ( .A(n9371), .Y(n4049) );
  sky130_fd_sc_hd__clkinv_1 U5503 ( .A(n8693), .Y(n4048) );
  sky130_fd_sc_hd__clkinv_1 U5504 ( .A(n8321), .Y(n4047) );
  sky130_fd_sc_hd__clkinv_1 U5505 ( .A(n8260), .Y(n4046) );
  sky130_fd_sc_hd__nand3_1 U5506 ( .A(n4645), .B(n4644), .C(n4235), .Y(N1882)
         );
  sky130_fd_sc_hd__clkinv_1 U5507 ( .A(n8211), .Y(n4045) );
  sky130_fd_sc_hd__clkinv_1 U5508 ( .A(n8184), .Y(n4043) );
  sky130_fd_sc_hd__clkinv_1 U5509 ( .A(n9040), .Y(n4044) );
  sky130_fd_sc_hd__nand3_1 U5510 ( .A(n4658), .B(n4657), .C(n4234), .Y(N1884)
         );
  sky130_fd_sc_hd__clkinv_1 U5511 ( .A(n6259), .Y(n2863) );
  sky130_fd_sc_hd__clkinv_1 U5512 ( .A(n8639), .Y(n2893) );
  sky130_fd_sc_hd__clkinv_1 U5513 ( .A(n7845), .Y(n2878) );
  sky130_fd_sc_hd__clkinv_1 U5514 ( .A(n6406), .Y(n2879) );
  sky130_fd_sc_hd__clkinv_1 U5515 ( .A(n9988), .Y(mem_la_addr[13]) );
  sky130_fd_sc_hd__clkinv_1 U5516 ( .A(n10012), .Y(mem_la_addr[25]) );
  sky130_fd_sc_hd__conb_1 U5517 ( .LO(latched_compr) );
  sky130_fd_sc_hd__nor2_1 U5518 ( .A(instr_lui), .B(instr_auipc), .Y(n5987) );
  sky130_fd_sc_hd__nand2_1 U5519 ( .A(n5987), .B(n5985), .Y(N254) );
  sky130_fd_sc_hd__nand3_1 U5520 ( .A(n10042), .B(n10047), .C(n10037), .Y(N257) );
  sky130_fd_sc_hd__nand3_1 U5521 ( .A(n10039), .B(n10045), .C(n10035), .Y(N256) );
  sky130_fd_sc_hd__nor2_1 U5522 ( .A(instr_sll), .B(instr_slli), .Y(n4322) );
  sky130_fd_sc_hd__nand2_1 U5523 ( .A(n4314), .B(cpu_state[2]), .Y(n4247) );
  sky130_fd_sc_hd__nor2_2 U5524 ( .A(cpu_state[7]), .B(cpu_state[1]), .Y(n4659) );
  sky130_fd_sc_hd__nand3_2 U5525 ( .A(n4659), .B(n5232), .C(n9883), .Y(n4637)
         );
  sky130_fd_sc_hd__nor2_1 U5526 ( .A(n4247), .B(n4637), .Y(n4248) );
  sky130_fd_sc_hd__buf_6 U5527 ( .A(n4248), .X(n9858) );
  sky130_fd_sc_hd__nor2_1 U5528 ( .A(reg_sh[2]), .B(reg_sh[3]), .Y(n9433) );
  sky130_fd_sc_hd__nand2_1 U5529 ( .A(n9433), .B(n4249), .Y(n4832) );
  sky130_fd_sc_hd__nand2_2 U5530 ( .A(n9858), .B(n4832), .Y(n9427) );
  sky130_fd_sc_hd__nor2_1 U5531 ( .A(n4322), .B(n9427), .Y(n4732) );
  sky130_fd_sc_hd__nand2_1 U5532 ( .A(n4250), .B(decoded_imm_j[15]), .Y(n4280)
         );
  sky130_fd_sc_hd__nor2_1 U5533 ( .A(decoded_imm_j[18]), .B(decoded_imm_j[19]), 
        .Y(n4252) );
  sky130_fd_sc_hd__inv_2 U5534 ( .A(decoded_imm_j[17]), .Y(n4261) );
  sky130_fd_sc_hd__nand2_1 U5535 ( .A(n4252), .B(n4261), .Y(n4253) );
  sky130_fd_sc_hd__nor2_1 U5536 ( .A(n4280), .B(n4253), .Y(n9478) );
  sky130_fd_sc_hd__nor2_1 U5537 ( .A(n4270), .B(n4253), .Y(n9496) );
  sky130_fd_sc_hd__a22oi_1 U5538 ( .A1(n9478), .A2(\cpuregs[1][16] ), .B1(
        n9496), .B2(\cpuregs[3][16] ), .Y(n4258) );
  sky130_fd_sc_hd__nand2_1 U5539 ( .A(n4251), .B(decoded_imm_j[16]), .Y(n4279)
         );
  sky130_fd_sc_hd__nand2_1 U5540 ( .A(n4252), .B(decoded_imm_j[17]), .Y(n4268)
         );
  sky130_fd_sc_hd__nor2_1 U5541 ( .A(n4279), .B(n4268), .Y(n9493) );
  sky130_fd_sc_hd__inv_2 U5542 ( .A(decoded_imm_j[19]), .Y(n4260) );
  sky130_fd_sc_hd__nor2_1 U5543 ( .A(decoded_imm_j[18]), .B(n4260), .Y(n4259)
         );
  sky130_fd_sc_hd__nand2_1 U5544 ( .A(n4259), .B(n4261), .Y(n4271) );
  sky130_fd_sc_hd__a22oi_1 U5545 ( .A1(n9493), .A2(\cpuregs[6][16] ), .B1(
        n9456), .B2(\cpuregs[17][16] ), .Y(n4257) );
  sky130_fd_sc_hd__nand2_1 U5546 ( .A(decoded_imm_j[17]), .B(decoded_imm_j[18]), .Y(n4276) );
  sky130_fd_sc_hd__or2_1 U5547 ( .A(decoded_imm_j[19]), .B(n4276), .X(n4282)
         );
  sky130_fd_sc_hd__nor2_2 U5548 ( .A(n4266), .B(n4282), .Y(n9484) );
  sky130_fd_sc_hd__nand2_1 U5549 ( .A(n9484), .B(\cpuregs[12][16] ), .Y(n4256)
         );
  sky130_fd_sc_hd__nor2_1 U5550 ( .A(n4279), .B(n4253), .Y(n9462) );
  sky130_fd_sc_hd__nor2_1 U5551 ( .A(n4266), .B(n4268), .Y(n9472) );
  sky130_fd_sc_hd__a22oi_1 U5552 ( .A1(n9462), .A2(\cpuregs[2][16] ), .B1(
        n9316), .B2(\cpuregs[4][16] ), .Y(n4255) );
  sky130_fd_sc_hd__nand4_1 U5553 ( .A(n4258), .B(n4257), .C(n4256), .D(n4255), 
        .Y(n4290) );
  sky130_fd_sc_hd__nand2_1 U5554 ( .A(n4259), .B(decoded_imm_j[17]), .Y(n4278)
         );
  sky130_fd_sc_hd__a22oi_1 U5555 ( .A1(n9480), .A2(\cpuregs[20][16] ), .B1(
        n9473), .B2(\cpuregs[23][16] ), .Y(n4265) );
  sky130_fd_sc_hd__nand3_1 U5556 ( .A(n4261), .B(n4260), .C(decoded_imm_j[18]), 
        .Y(n4269) );
  sky130_fd_sc_hd__nor2_1 U5557 ( .A(n4270), .B(n4269), .Y(n9490) );
  sky130_fd_sc_hd__nor2_1 U5558 ( .A(n4269), .B(n4279), .Y(n9491) );
  sky130_fd_sc_hd__a22oi_1 U5559 ( .A1(n9490), .A2(\cpuregs[11][16] ), .B1(
        n9491), .B2(\cpuregs[10][16] ), .Y(n4264) );
  sky130_fd_sc_hd__nand3_1 U5560 ( .A(n4261), .B(decoded_imm_j[18]), .C(
        decoded_imm_j[19]), .Y(n4267) );
  sky130_fd_sc_hd__a22oi_1 U5561 ( .A1(n9321), .A2(\cpuregs[27][16] ), .B1(
        n9471), .B2(\cpuregs[25][16] ), .Y(n4263) );
  sky130_fd_sc_hd__nor2_1 U5562 ( .A(n4267), .B(n4266), .Y(n9460) );
  sky130_fd_sc_hd__a22oi_1 U5563 ( .A1(n9460), .A2(\cpuregs[24][16] ), .B1(
        n9485), .B2(\cpuregs[21][16] ), .Y(n4262) );
  sky130_fd_sc_hd__nand4_1 U5564 ( .A(n4265), .B(n4264), .C(n4263), .D(n4262), 
        .Y(n4289) );
  sky130_fd_sc_hd__a22oi_1 U5565 ( .A1(n9468), .A2(\cpuregs[16][16] ), .B1(
        n9459), .B2(\cpuregs[18][16] ), .Y(n4275) );
  sky130_fd_sc_hd__nor2_1 U5566 ( .A(n4267), .B(n4279), .Y(n9467) );
  sky130_fd_sc_hd__nor2_2 U5567 ( .A(n4269), .B(n4266), .Y(n9494) );
  sky130_fd_sc_hd__a22oi_1 U5568 ( .A1(n9467), .A2(\cpuregs[26][16] ), .B1(
        n9494), .B2(\cpuregs[8][16] ), .Y(n4274) );
  sky130_fd_sc_hd__nor2_1 U5569 ( .A(n4270), .B(n4268), .Y(n9483) );
  sky130_fd_sc_hd__nor2_1 U5570 ( .A(n4280), .B(n4268), .Y(n9461) );
  sky130_fd_sc_hd__a22oi_1 U5571 ( .A1(n9483), .A2(\cpuregs[7][16] ), .B1(
        n9461), .B2(\cpuregs[5][16] ), .Y(n4273) );
  sky130_fd_sc_hd__nor2_1 U5572 ( .A(n4269), .B(n4280), .Y(n9469) );
  sky130_fd_sc_hd__a22oi_1 U5573 ( .A1(n9469), .A2(\cpuregs[9][16] ), .B1(
        n9457), .B2(\cpuregs[19][16] ), .Y(n4272) );
  sky130_fd_sc_hd__nand4_1 U5574 ( .A(n4275), .B(n4274), .C(n4273), .D(n4272), 
        .Y(n4288) );
  sky130_fd_sc_hd__nor2_1 U5575 ( .A(n4280), .B(n4282), .Y(n9470) );
  sky130_fd_sc_hd__a22oi_1 U5576 ( .A1(n9481), .A2(\cpuregs[14][16] ), .B1(
        n9470), .B2(\cpuregs[13][16] ), .Y(n4286) );
  sky130_fd_sc_hd__nand2_1 U5577 ( .A(n4277), .B(decoded_imm_j[19]), .Y(n4281)
         );
  sky130_fd_sc_hd__a22oi_1 U5578 ( .A1(n9482), .A2(\cpuregs[31][16] ), .B1(
        n9495), .B2(\cpuregs[22][16] ), .Y(n4285) );
  sky130_fd_sc_hd__nor2_1 U5579 ( .A(n4279), .B(n4281), .Y(n9458) );
  sky130_fd_sc_hd__nor2_1 U5580 ( .A(n4280), .B(n4281), .Y(n9479) );
  sky130_fd_sc_hd__a22oi_1 U5581 ( .A1(n9458), .A2(\cpuregs[30][16] ), .B1(
        n9479), .B2(\cpuregs[29][16] ), .Y(n4284) );
  sky130_fd_sc_hd__a22oi_1 U5582 ( .A1(n9492), .A2(\cpuregs[28][16] ), .B1(
        n9497), .B2(\cpuregs[15][16] ), .Y(n4283) );
  sky130_fd_sc_hd__nand4_1 U5583 ( .A(n4286), .B(n4285), .C(n4284), .D(n4283), 
        .Y(n4287) );
  sky130_fd_sc_hd__nor4_1 U5584 ( .A(n4290), .B(n4289), .C(n4288), .D(n4287), 
        .Y(n4307) );
  sky130_fd_sc_hd__nor2_1 U5585 ( .A(instr_rdinstr), .B(instr_rdcycle), .Y(
        n4292) );
  sky130_fd_sc_hd__nand3_1 U5586 ( .A(n4292), .B(n4291), .C(n4626), .Y(n9009)
         );
  sky130_fd_sc_hd__nand2_1 U5587 ( .A(n4294), .B(n4293), .Y(n4555) );
  sky130_fd_sc_hd__nor2_1 U5588 ( .A(instr_ori), .B(instr_or), .Y(n4560) );
  sky130_fd_sc_hd__nand2b_1 U5589 ( .A_N(n4555), .B(n4560), .Y(n4837) );
  sky130_fd_sc_hd__nor2_1 U5590 ( .A(instr_jalr), .B(instr_add), .Y(n4296) );
  sky130_fd_sc_hd__nor2_1 U5591 ( .A(instr_addi), .B(instr_sub), .Y(n4295) );
  sky130_fd_sc_hd__nand3_1 U5592 ( .A(n5982), .B(n4296), .C(n4295), .Y(n4966)
         );
  sky130_fd_sc_hd__nand2_1 U5593 ( .A(n10104), .B(n10097), .Y(n10126) );
  sky130_fd_sc_hd__nor2_1 U5594 ( .A(instr_lhu), .B(instr_lh), .Y(n10125) );
  sky130_fd_sc_hd__nand3b_1 U5595 ( .A_N(n10126), .B(n10125), .C(n10100), .Y(
        n4786) );
  sky130_fd_sc_hd__nor3_1 U5596 ( .A(instr_sb), .B(instr_sh), .C(instr_sw), 
        .Y(n4788) );
  sky130_fd_sc_hd__nand2_1 U5597 ( .A(n4627), .B(n4788), .Y(n4297) );
  sky130_fd_sc_hd__nor2_1 U5598 ( .A(instr_srl), .B(instr_srli), .Y(n4528) );
  sky130_fd_sc_hd__nor2_1 U5599 ( .A(instr_sra), .B(instr_srai), .Y(n4298) );
  sky130_fd_sc_hd__and3_1 U5600 ( .A(n4322), .B(n4528), .C(n4298), .X(n4317)
         );
  sky130_fd_sc_hd__nand2_1 U5601 ( .A(n4300), .B(n4299), .Y(n4558) );
  sky130_fd_sc_hd__nor4_1 U5602 ( .A(instr_fence), .B(N257), .C(N256), .D(
        n4558), .Y(n4301) );
  sky130_fd_sc_hd__nor4_1 U5603 ( .A(instr_beq), .B(instr_bge), .C(instr_bgeu), 
        .D(instr_bne), .Y(n4304) );
  sky130_fd_sc_hd__nand2_1 U5604 ( .A(n4172), .B(n4304), .Y(n4836) );
  sky130_fd_sc_hd__nor2_2 U5605 ( .A(n9009), .B(n4305), .Y(n6029) );
  sky130_fd_sc_hd__inv_1 U5606 ( .A(cpu_state[3]), .Y(n9518) );
  sky130_fd_sc_hd__nand3_1 U5607 ( .A(n5423), .B(n9518), .C(cpu_state[5]), .Y(
        n4306) );
  sky130_fd_sc_hd__nand3_1 U5608 ( .A(n6029), .B(n9524), .C(n5991), .Y(n9302)
         );
  sky130_fd_sc_hd__o22ai_1 U5609 ( .A1(n8778), .A2(n4308), .B1(n4307), .B2(
        n9302), .Y(n4348) );
  sky130_fd_sc_hd__inv_6 U5610 ( .A(n9858), .Y(n9437) );
  sky130_fd_sc_hd__nor2_2 U5611 ( .A(n4309), .B(n9437), .Y(n9223) );
  sky130_fd_sc_hd__nand2_1 U5612 ( .A(n9858), .B(N1570), .Y(n4310) );
  sky130_fd_sc_hd__nand2_1 U5613 ( .A(n9427), .B(n4310), .Y(n9218) );
  sky130_fd_sc_hd__nand2_2 U5614 ( .A(mem_ready), .B(mem_valid), .Y(n4817) );
  sky130_fd_sc_hd__nand3_1 U5615 ( .A(mem_state[1]), .B(mem_state[0]), .C(
        mem_do_rinst), .Y(n10068) );
  sky130_fd_sc_hd__nor2_1 U5616 ( .A(mem_do_wdata), .B(mem_do_rdata), .Y(n4830) );
  sky130_fd_sc_hd__nand2_1 U5617 ( .A(n4830), .B(n9910), .Y(n4311) );
  sky130_fd_sc_hd__nand2_1 U5618 ( .A(n4827), .B(mem_do_prefetch), .Y(n4316)
         );
  sky130_fd_sc_hd__nor2_1 U5619 ( .A(cpu_state[7]), .B(cpu_state[6]), .Y(n4313) );
  sky130_fd_sc_hd__nand2_1 U5620 ( .A(n4313), .B(cpu_state[1]), .Y(n4312) );
  sky130_fd_sc_hd__nand3_2 U5621 ( .A(n4314), .B(n5423), .C(n5232), .Y(n9885)
         );
  sky130_fd_sc_hd__nor2_1 U5622 ( .A(n4312), .B(n9885), .Y(n10129) );
  sky130_fd_sc_hd__and3_1 U5623 ( .A(n9884), .B(n5423), .C(cpu_state[0]), .X(
        n4315) );
  sky130_fd_sc_hd__nand3_1 U5624 ( .A(n4316), .B(n9859), .C(n10071), .Y(n4785)
         );
  sky130_fd_sc_hd__o211ai_2 U5625 ( .A1(n4317), .A2(n9276), .B1(n5406), .C1(
        n4785), .Y(n4318) );
  sky130_fd_sc_hd__nand2_1 U5626 ( .A(n4318), .B(resetn), .Y(n4319) );
  sky130_fd_sc_hd__nand2_1 U5627 ( .A(n9524), .B(resetn), .Y(n6030) );
  sky130_fd_sc_hd__nor2b_1 U5628 ( .B_N(is_lui_auipc_jal), .A(instr_lui), .Y(
        n4320) );
  sky130_fd_sc_hd__nand3_1 U5629 ( .A(n6029), .B(n4835), .C(n4320), .Y(n4321)
         );
  sky130_fd_sc_hd__nor2_1 U5630 ( .A(n9278), .B(n9427), .Y(n4698) );
  sky130_fd_sc_hd__inv_4 U5631 ( .A(n9454), .Y(n9345) );
  sky130_fd_sc_hd__a22oi_1 U5632 ( .A1(n9280), .A2(reg_pc[16]), .B1(n9345), 
        .B2(pcpi_rs1[20]), .Y(n4346) );
  sky130_fd_sc_hd__nand2_1 U5633 ( .A(n4323), .B(n10124), .Y(n4826) );
  sky130_fd_sc_hd__and2_4 U5634 ( .A(n9340), .B(n4826), .X(n9511) );
  sky130_fd_sc_hd__nor2_1 U5635 ( .A(decoded_imm[16]), .B(pcpi_rs1[16]), .Y(
        n4372) );
  sky130_fd_sc_hd__nand2_1 U5636 ( .A(pcpi_rs1[16]), .B(decoded_imm[16]), .Y(
        n6848) );
  sky130_fd_sc_hd__nand2_1 U5637 ( .A(n6850), .B(n6848), .Y(n4338) );
  sky130_fd_sc_hd__nor2_1 U5638 ( .A(decoded_imm[5]), .B(pcpi_rs1[5]), .Y(
        n9112) );
  sky130_fd_sc_hd__nor2_1 U5639 ( .A(decoded_imm[4]), .B(pcpi_rs1[4]), .Y(
        n8752) );
  sky130_fd_sc_hd__nor2_1 U5640 ( .A(n9112), .B(n8752), .Y(n4675) );
  sky130_fd_sc_hd__nor2_1 U5641 ( .A(decoded_imm[7]), .B(pcpi_rs1[7]), .Y(
        n4670) );
  sky130_fd_sc_hd__nor2_1 U5642 ( .A(decoded_imm[6]), .B(pcpi_rs1[6]), .Y(
        n9074) );
  sky130_fd_sc_hd__nor2_1 U5643 ( .A(n4670), .B(n9074), .Y(n4327) );
  sky130_fd_sc_hd__nand2_1 U5644 ( .A(n4675), .B(n4327), .Y(n4329) );
  sky130_fd_sc_hd__nand2_1 U5645 ( .A(pcpi_rs1[0]), .B(decoded_imm[0]), .Y(
        n9450) );
  sky130_fd_sc_hd__nor2_1 U5646 ( .A(decoded_imm[1]), .B(pcpi_rs1[1]), .Y(
        n9144) );
  sky130_fd_sc_hd__nand2_1 U5647 ( .A(pcpi_rs1[1]), .B(decoded_imm[1]), .Y(
        n9145) );
  sky130_fd_sc_hd__o21ai_1 U5648 ( .A1(n9450), .A2(n9144), .B1(n9145), .Y(
        n8719) );
  sky130_fd_sc_hd__nor2_1 U5649 ( .A(decoded_imm[3]), .B(pcpi_rs1[3]), .Y(
        n8716) );
  sky130_fd_sc_hd__nor2_1 U5650 ( .A(decoded_imm[2]), .B(pcpi_rs1[2]), .Y(
        n9334) );
  sky130_fd_sc_hd__nor2_1 U5651 ( .A(n8716), .B(n9334), .Y(n4325) );
  sky130_fd_sc_hd__nand2_1 U5652 ( .A(pcpi_rs1[2]), .B(decoded_imm[2]), .Y(
        n9335) );
  sky130_fd_sc_hd__nand2_1 U5653 ( .A(pcpi_rs1[3]), .B(decoded_imm[3]), .Y(
        n8717) );
  sky130_fd_sc_hd__o21ai_1 U5654 ( .A1(n9335), .A2(n8716), .B1(n8717), .Y(
        n4324) );
  sky130_fd_sc_hd__a21oi_1 U5655 ( .A1(n8719), .A2(n4325), .B1(n4324), .Y(
        n4673) );
  sky130_fd_sc_hd__nand2_1 U5656 ( .A(pcpi_rs1[4]), .B(decoded_imm[4]), .Y(
        n9108) );
  sky130_fd_sc_hd__nand2_1 U5657 ( .A(pcpi_rs1[5]), .B(decoded_imm[5]), .Y(
        n9113) );
  sky130_fd_sc_hd__o21ai_1 U5658 ( .A1(n9108), .A2(n9112), .B1(n9113), .Y(
        n4674) );
  sky130_fd_sc_hd__nand2_1 U5659 ( .A(pcpi_rs1[6]), .B(decoded_imm[6]), .Y(
        n9075) );
  sky130_fd_sc_hd__nand2_1 U5660 ( .A(pcpi_rs1[7]), .B(decoded_imm[7]), .Y(
        n4671) );
  sky130_fd_sc_hd__o21ai_1 U5661 ( .A1(n9075), .A2(n4670), .B1(n4671), .Y(
        n4326) );
  sky130_fd_sc_hd__a21oi_1 U5662 ( .A1(n4327), .A2(n4674), .B1(n4326), .Y(
        n4328) );
  sky130_fd_sc_hd__o21ai_1 U5663 ( .A1(n4329), .A2(n4673), .B1(n4328), .Y(
        n4414) );
  sky130_fd_sc_hd__nor2_1 U5664 ( .A(decoded_imm[10]), .B(pcpi_rs1[10]), .Y(
        n4418) );
  sky130_fd_sc_hd__nor2_1 U5665 ( .A(decoded_imm[11]), .B(pcpi_rs1[11]), .Y(
        n4420) );
  sky130_fd_sc_hd__nor2_1 U5666 ( .A(n4418), .B(n4420), .Y(n4331) );
  sky130_fd_sc_hd__nor2_1 U5667 ( .A(decoded_imm[9]), .B(pcpi_rs1[9]), .Y(
        n6322) );
  sky130_fd_sc_hd__nor2_1 U5668 ( .A(decoded_imm[8]), .B(pcpi_rs1[8]), .Y(
        n6327) );
  sky130_fd_sc_hd__nor2_1 U5669 ( .A(n6322), .B(n6327), .Y(n4413) );
  sky130_fd_sc_hd__nand2_1 U5670 ( .A(n4331), .B(n4413), .Y(n4486) );
  sky130_fd_sc_hd__nor2_1 U5671 ( .A(decoded_imm[13]), .B(pcpi_rs1[13]), .Y(
        n6467) );
  sky130_fd_sc_hd__nor2_1 U5672 ( .A(decoded_imm[12]), .B(pcpi_rs1[12]), .Y(
        n6464) );
  sky130_fd_sc_hd__nor2_1 U5673 ( .A(n6467), .B(n6464), .Y(n4484) );
  sky130_fd_sc_hd__nor2_1 U5674 ( .A(decoded_imm[15]), .B(pcpi_rs1[15]), .Y(
        n4492) );
  sky130_fd_sc_hd__nor2_1 U5675 ( .A(decoded_imm[14]), .B(pcpi_rs1[14]), .Y(
        n4490) );
  sky130_fd_sc_hd__nor2_1 U5676 ( .A(n4492), .B(n4490), .Y(n4333) );
  sky130_fd_sc_hd__nand2_1 U5677 ( .A(n4484), .B(n4333), .Y(n4335) );
  sky130_fd_sc_hd__nor2_1 U5678 ( .A(n4486), .B(n4335), .Y(n4337) );
  sky130_fd_sc_hd__nand2_1 U5679 ( .A(pcpi_rs1[8]), .B(decoded_imm[8]), .Y(
        n6325) );
  sky130_fd_sc_hd__nand2_1 U5680 ( .A(pcpi_rs1[9]), .B(decoded_imm[9]), .Y(
        n6323) );
  sky130_fd_sc_hd__o21ai_1 U5681 ( .A1(n6325), .A2(n6322), .B1(n6323), .Y(
        n4415) );
  sky130_fd_sc_hd__nand2_1 U5682 ( .A(pcpi_rs1[10]), .B(decoded_imm[10]), .Y(
        n8815) );
  sky130_fd_sc_hd__nand2_1 U5683 ( .A(pcpi_rs1[11]), .B(decoded_imm[11]), .Y(
        n4421) );
  sky130_fd_sc_hd__o21ai_1 U5684 ( .A1(n8815), .A2(n4420), .B1(n4421), .Y(
        n4330) );
  sky130_fd_sc_hd__a21oi_1 U5685 ( .A1(n4331), .A2(n4415), .B1(n4330), .Y(
        n4485) );
  sky130_fd_sc_hd__nand2_1 U5686 ( .A(pcpi_rs1[12]), .B(decoded_imm[12]), .Y(
        n8781) );
  sky130_fd_sc_hd__nand2_1 U5687 ( .A(pcpi_rs1[13]), .B(decoded_imm[13]), .Y(
        n6468) );
  sky130_fd_sc_hd__o21ai_1 U5688 ( .A1(n8781), .A2(n6467), .B1(n6468), .Y(
        n4487) );
  sky130_fd_sc_hd__nand2_1 U5689 ( .A(pcpi_rs1[14]), .B(decoded_imm[14]), .Y(
        n8851) );
  sky130_fd_sc_hd__nand2_1 U5690 ( .A(pcpi_rs1[15]), .B(decoded_imm[15]), .Y(
        n4493) );
  sky130_fd_sc_hd__o21ai_1 U5691 ( .A1(n8851), .A2(n4492), .B1(n4493), .Y(
        n4332) );
  sky130_fd_sc_hd__a21oi_1 U5692 ( .A1(n4333), .A2(n4487), .B1(n4332), .Y(
        n4334) );
  sky130_fd_sc_hd__o21ai_1 U5693 ( .A1(n4335), .A2(n4485), .B1(n4334), .Y(
        n4336) );
  sky130_fd_sc_hd__a21oi_1 U5694 ( .A1(n4414), .A2(n4337), .B1(n4336), .Y(
        n4545) );
  sky130_fd_sc_hd__xnor2_1 U5695 ( .A(n4338), .B(n6851), .Y(n4341) );
  sky130_fd_sc_hd__nand3_1 U5696 ( .A(n4339), .B(n9224), .C(n9278), .Y(n9304)
         );
  sky130_fd_sc_hd__nand2_1 U5697 ( .A(n4498), .B(n4701), .Y(n4340) );
  sky130_fd_sc_hd__inv_2 U5698 ( .A(n4340), .Y(n8927) );
  sky130_fd_sc_hd__a22oi_1 U5699 ( .A1(n9511), .A2(n4341), .B1(pcpi_rs1[15]), 
        .B2(n8927), .Y(n4345) );
  sky130_fd_sc_hd__nand2_1 U5700 ( .A(n4456), .B(pcpi_rs1[17]), .Y(n4344) );
  sky130_fd_sc_hd__nand2b_1 U5701 ( .A_N(n9340), .B(pcpi_rs1[16]), .Y(n4343)
         );
  sky130_fd_sc_hd__nand4_1 U5702 ( .A(n4346), .B(n4345), .C(n4344), .D(n4343), 
        .Y(n4347) );
  sky130_fd_sc_hd__a22oi_1 U5703 ( .A1(n9478), .A2(\cpuregs[1][23] ), .B1(
        n9496), .B2(\cpuregs[3][23] ), .Y(n4352) );
  sky130_fd_sc_hd__a22oi_1 U5704 ( .A1(n9493), .A2(\cpuregs[6][23] ), .B1(
        n9456), .B2(\cpuregs[17][23] ), .Y(n4351) );
  sky130_fd_sc_hd__nand2_1 U5705 ( .A(n9484), .B(\cpuregs[12][23] ), .Y(n4350)
         );
  sky130_fd_sc_hd__a22oi_1 U5706 ( .A1(n9462), .A2(\cpuregs[2][23] ), .B1(
        n9472), .B2(\cpuregs[4][23] ), .Y(n4349) );
  sky130_fd_sc_hd__nand4_1 U5707 ( .A(n4352), .B(n4351), .C(n4350), .D(n4349), 
        .Y(n4368) );
  sky130_fd_sc_hd__a22oi_1 U5708 ( .A1(n9480), .A2(\cpuregs[20][23] ), .B1(
        n9473), .B2(\cpuregs[23][23] ), .Y(n4356) );
  sky130_fd_sc_hd__a22oi_1 U5709 ( .A1(n9490), .A2(\cpuregs[11][23] ), .B1(
        n9491), .B2(\cpuregs[10][23] ), .Y(n4355) );
  sky130_fd_sc_hd__a22oi_1 U5710 ( .A1(n9321), .A2(\cpuregs[27][23] ), .B1(
        n9471), .B2(\cpuregs[25][23] ), .Y(n4354) );
  sky130_fd_sc_hd__a22oi_1 U5711 ( .A1(n9460), .A2(\cpuregs[24][23] ), .B1(
        n9485), .B2(\cpuregs[21][23] ), .Y(n4353) );
  sky130_fd_sc_hd__nand4_1 U5712 ( .A(n4356), .B(n4355), .C(n4354), .D(n4353), 
        .Y(n4367) );
  sky130_fd_sc_hd__a22oi_1 U5713 ( .A1(n9481), .A2(\cpuregs[14][23] ), .B1(
        n9470), .B2(\cpuregs[13][23] ), .Y(n4360) );
  sky130_fd_sc_hd__a22oi_1 U5714 ( .A1(n9482), .A2(\cpuregs[31][23] ), .B1(
        n9495), .B2(\cpuregs[22][23] ), .Y(n4359) );
  sky130_fd_sc_hd__a22oi_1 U5715 ( .A1(n9458), .A2(\cpuregs[30][23] ), .B1(
        n9479), .B2(\cpuregs[29][23] ), .Y(n4358) );
  sky130_fd_sc_hd__a22oi_1 U5716 ( .A1(n9492), .A2(\cpuregs[28][23] ), .B1(
        n9497), .B2(\cpuregs[15][23] ), .Y(n4357) );
  sky130_fd_sc_hd__nand4_1 U5717 ( .A(n4360), .B(n4359), .C(n4358), .D(n4357), 
        .Y(n4366) );
  sky130_fd_sc_hd__a22oi_1 U5718 ( .A1(n9468), .A2(\cpuregs[16][23] ), .B1(
        n9459), .B2(\cpuregs[18][23] ), .Y(n4364) );
  sky130_fd_sc_hd__a22oi_1 U5719 ( .A1(n9467), .A2(\cpuregs[26][23] ), .B1(
        n9494), .B2(\cpuregs[8][23] ), .Y(n4363) );
  sky130_fd_sc_hd__a22oi_1 U5720 ( .A1(n9483), .A2(\cpuregs[7][23] ), .B1(
        n9461), .B2(\cpuregs[5][23] ), .Y(n4362) );
  sky130_fd_sc_hd__a22oi_1 U5721 ( .A1(n9469), .A2(\cpuregs[9][23] ), .B1(
        n9457), .B2(\cpuregs[19][23] ), .Y(n4361) );
  sky130_fd_sc_hd__nand4_1 U5722 ( .A(n4364), .B(n4363), .C(n4362), .D(n4361), 
        .Y(n4365) );
  sky130_fd_sc_hd__nor4_1 U5723 ( .A(n4368), .B(n4367), .C(n4366), .D(n4365), 
        .Y(n4369) );
  sky130_fd_sc_hd__o22ai_1 U5724 ( .A1(n7541), .A2(n8848), .B1(n4369), .B2(
        n9302), .Y(n4370) );
  sky130_fd_sc_hd__nand2_1 U5725 ( .A(n4370), .B(n9340), .Y(n4389) );
  sky130_fd_sc_hd__nand2_1 U5726 ( .A(n4498), .B(n4732), .Y(n4371) );
  sky130_fd_sc_hd__a22oi_1 U5727 ( .A1(n9307), .A2(pcpi_rs1[19]), .B1(
        pcpi_rs1[22]), .B2(n8927), .Y(n4386) );
  sky130_fd_sc_hd__nor2_1 U5728 ( .A(decoded_imm[21]), .B(pcpi_rs1[21]), .Y(
        n6793) );
  sky130_fd_sc_hd__nor2_1 U5729 ( .A(decoded_imm[20]), .B(pcpi_rs1[20]), .Y(
        n6791) );
  sky130_fd_sc_hd__nor2_1 U5730 ( .A(n6793), .B(n6791), .Y(n4531) );
  sky130_fd_sc_hd__nor2_1 U5731 ( .A(decoded_imm[17]), .B(pcpi_rs1[17]), .Y(
        n6852) );
  sky130_fd_sc_hd__nor2_1 U5732 ( .A(n4372), .B(n6852), .Y(n4771) );
  sky130_fd_sc_hd__nor2_1 U5733 ( .A(decoded_imm[19]), .B(pcpi_rs1[19]), .Y(
        n4767) );
  sky130_fd_sc_hd__nor2_1 U5734 ( .A(decoded_imm[18]), .B(pcpi_rs1[18]), .Y(
        n8883) );
  sky130_fd_sc_hd__nor2_1 U5735 ( .A(n4767), .B(n8883), .Y(n4374) );
  sky130_fd_sc_hd__nand2_1 U5736 ( .A(n4771), .B(n4374), .Y(n4532) );
  sky130_fd_sc_hd__nand2_1 U5737 ( .A(pcpi_rs1[17]), .B(decoded_imm[17]), .Y(
        n6853) );
  sky130_fd_sc_hd__o21ai_1 U5738 ( .A1(n6848), .A2(n6852), .B1(n6853), .Y(
        n4770) );
  sky130_fd_sc_hd__nand2_1 U5739 ( .A(pcpi_rs1[18]), .B(decoded_imm[18]), .Y(
        n8884) );
  sky130_fd_sc_hd__nand2_1 U5740 ( .A(pcpi_rs1[19]), .B(decoded_imm[19]), .Y(
        n4768) );
  sky130_fd_sc_hd__o21ai_1 U5741 ( .A1(n8884), .A2(n4767), .B1(n4768), .Y(
        n4373) );
  sky130_fd_sc_hd__a21oi_1 U5742 ( .A1(n4374), .A2(n4770), .B1(n4373), .Y(
        n4539) );
  sky130_fd_sc_hd__a21oi_1 U5743 ( .A1(n6851), .A2(n4376), .B1(n4375), .Y(
        n6790) );
  sky130_fd_sc_hd__nand2_1 U5744 ( .A(pcpi_rs1[20]), .B(decoded_imm[20]), .Y(
        n7426) );
  sky130_fd_sc_hd__nand2_1 U5745 ( .A(pcpi_rs1[21]), .B(decoded_imm[21]), .Y(
        n6794) );
  sky130_fd_sc_hd__o21ai_1 U5746 ( .A1(n7426), .A2(n6793), .B1(n6794), .Y(
        n4536) );
  sky130_fd_sc_hd__o21ai_1 U5747 ( .A1(n4378), .A2(n6790), .B1(n4377), .Y(
        n8924) );
  sky130_fd_sc_hd__nor2_1 U5748 ( .A(decoded_imm[22]), .B(pcpi_rs1[22]), .Y(
        n4530) );
  sky130_fd_sc_hd__nand2_1 U5749 ( .A(pcpi_rs1[22]), .B(decoded_imm[22]), .Y(
        n8922) );
  sky130_fd_sc_hd__a21oi_1 U5750 ( .A1(n8924), .A2(n8923), .B1(n4379), .Y(
        n4382) );
  sky130_fd_sc_hd__nor2_1 U5751 ( .A(decoded_imm[23]), .B(pcpi_rs1[23]), .Y(
        n4534) );
  sky130_fd_sc_hd__nand2_1 U5752 ( .A(pcpi_rs1[23]), .B(decoded_imm[23]), .Y(
        n4533) );
  sky130_fd_sc_hd__nand2_1 U5753 ( .A(n4380), .B(n4533), .Y(n4381) );
  sky130_fd_sc_hd__xor2_1 U5754 ( .A(n4382), .B(n4381), .X(n4383) );
  sky130_fd_sc_hd__nand2_1 U5755 ( .A(n4383), .B(n9511), .Y(n4385) );
  sky130_fd_sc_hd__nand2b_1 U5756 ( .A_N(n9340), .B(pcpi_rs1[23]), .Y(n4384)
         );
  sky130_fd_sc_hd__nand2_1 U5757 ( .A(n4389), .B(n4388), .Y(n2772) );
  sky130_fd_sc_hd__a22oi_1 U5758 ( .A1(n9478), .A2(\cpuregs[1][11] ), .B1(
        n9496), .B2(\cpuregs[3][11] ), .Y(n4393) );
  sky130_fd_sc_hd__a22oi_1 U5759 ( .A1(n9493), .A2(\cpuregs[6][11] ), .B1(
        n9456), .B2(\cpuregs[17][11] ), .Y(n4392) );
  sky130_fd_sc_hd__nand2_1 U5760 ( .A(n9484), .B(\cpuregs[12][11] ), .Y(n4391)
         );
  sky130_fd_sc_hd__a22oi_1 U5761 ( .A1(n9462), .A2(\cpuregs[2][11] ), .B1(
        n9472), .B2(\cpuregs[4][11] ), .Y(n4390) );
  sky130_fd_sc_hd__nand4_1 U5762 ( .A(n4393), .B(n4392), .C(n4391), .D(n4390), 
        .Y(n4410) );
  sky130_fd_sc_hd__a22oi_1 U5763 ( .A1(n9480), .A2(\cpuregs[20][11] ), .B1(
        n9473), .B2(\cpuregs[23][11] ), .Y(n4397) );
  sky130_fd_sc_hd__a22oi_1 U5764 ( .A1(n9490), .A2(\cpuregs[11][11] ), .B1(
        n9491), .B2(\cpuregs[10][11] ), .Y(n4396) );
  sky130_fd_sc_hd__a22oi_1 U5765 ( .A1(n9321), .A2(\cpuregs[27][11] ), .B1(
        n9471), .B2(\cpuregs[25][11] ), .Y(n4395) );
  sky130_fd_sc_hd__a22oi_1 U5766 ( .A1(n9460), .A2(\cpuregs[24][11] ), .B1(
        n9485), .B2(\cpuregs[21][11] ), .Y(n4394) );
  sky130_fd_sc_hd__nand4_1 U5767 ( .A(n4397), .B(n4396), .C(n4395), .D(n4394), 
        .Y(n4409) );
  sky130_fd_sc_hd__a22oi_1 U5768 ( .A1(n9468), .A2(\cpuregs[16][11] ), .B1(
        n9289), .B2(\cpuregs[18][11] ), .Y(n4402) );
  sky130_fd_sc_hd__a22oi_1 U5769 ( .A1(n9467), .A2(\cpuregs[26][11] ), .B1(
        n9494), .B2(\cpuregs[8][11] ), .Y(n4401) );
  sky130_fd_sc_hd__a22oi_1 U5770 ( .A1(n9483), .A2(\cpuregs[7][11] ), .B1(
        n9461), .B2(\cpuregs[5][11] ), .Y(n4400) );
  sky130_fd_sc_hd__a22oi_1 U5771 ( .A1(n9469), .A2(\cpuregs[9][11] ), .B1(
        n9457), .B2(\cpuregs[19][11] ), .Y(n4399) );
  sky130_fd_sc_hd__nand4_1 U5772 ( .A(n4402), .B(n4401), .C(n4400), .D(n4399), 
        .Y(n4408) );
  sky130_fd_sc_hd__a22oi_1 U5773 ( .A1(n9481), .A2(\cpuregs[14][11] ), .B1(
        n9470), .B2(\cpuregs[13][11] ), .Y(n4406) );
  sky130_fd_sc_hd__a22oi_1 U5774 ( .A1(n9482), .A2(\cpuregs[31][11] ), .B1(
        n9495), .B2(\cpuregs[22][11] ), .Y(n4405) );
  sky130_fd_sc_hd__a22oi_1 U5775 ( .A1(n9492), .A2(\cpuregs[28][11] ), .B1(
        n9497), .B2(\cpuregs[15][11] ), .Y(n4404) );
  sky130_fd_sc_hd__a22oi_1 U5776 ( .A1(n9458), .A2(\cpuregs[30][11] ), .B1(
        n9479), .B2(\cpuregs[29][11] ), .Y(n4403) );
  sky130_fd_sc_hd__nand4_1 U5777 ( .A(n4406), .B(n4405), .C(n4404), .D(n4403), 
        .Y(n4407) );
  sky130_fd_sc_hd__nor4_1 U5778 ( .A(n4410), .B(n4409), .C(n4408), .D(n4407), 
        .Y(n4411) );
  sky130_fd_sc_hd__o22ai_1 U5779 ( .A1(n9304), .A2(n8813), .B1(n4411), .B2(
        n9302), .Y(n4412) );
  sky130_fd_sc_hd__nand2_1 U5780 ( .A(n4412), .B(n9340), .Y(n4431) );
  sky130_fd_sc_hd__a22oi_1 U5781 ( .A1(n9280), .A2(reg_pc[11]), .B1(n9345), 
        .B2(pcpi_rs1[15]), .Y(n4430) );
  sky130_fd_sc_hd__o21ai_1 U5782 ( .A1(n4417), .A2(n6326), .B1(n4416), .Y(
        n8817) );
  sky130_fd_sc_hd__a21oi_1 U5783 ( .A1(n8817), .A2(n8816), .B1(n4419), .Y(
        n4424) );
  sky130_fd_sc_hd__nand2_1 U5784 ( .A(n4422), .B(n4421), .Y(n4423) );
  sky130_fd_sc_hd__xor2_1 U5785 ( .A(n4424), .B(n4423), .X(n4425) );
  sky130_fd_sc_hd__nand2_1 U5786 ( .A(n9511), .B(n4425), .Y(n4427) );
  sky130_fd_sc_hd__nand2b_1 U5787 ( .A_N(n9340), .B(pcpi_rs1[11]), .Y(n4426)
         );
  sky130_fd_sc_hd__nand2_1 U5788 ( .A(n4427), .B(n4426), .Y(n4428) );
  sky130_fd_sc_hd__nor2_1 U5789 ( .A(n4428), .B(n4224), .Y(n4429) );
  sky130_fd_sc_hd__nand3_1 U5790 ( .A(n4431), .B(n4430), .C(n4429), .Y(n2784)
         );
  sky130_fd_sc_hd__o22ai_1 U5791 ( .A1(n4321), .A2(n9664), .B1(n8786), .B2(
        n9340), .Y(n4432) );
  sky130_fd_sc_hd__a21oi_1 U5792 ( .A1(n9345), .A2(pcpi_rs1[12]), .B1(n4432), 
        .Y(n4462) );
  sky130_fd_sc_hd__nand2_1 U5793 ( .A(n4433), .B(n6325), .Y(n4434) );
  sky130_fd_sc_hd__xor2_1 U5794 ( .A(n6326), .B(n4434), .X(n4460) );
  sky130_fd_sc_hd__nor2_1 U5795 ( .A(n9079), .B(n4340), .Y(n4459) );
  sky130_fd_sc_hd__a22oi_1 U5796 ( .A1(n9491), .A2(\cpuregs[10][8] ), .B1(
        n9316), .B2(\cpuregs[4][8] ), .Y(n4438) );
  sky130_fd_sc_hd__a22oi_1 U5797 ( .A1(n9492), .A2(\cpuregs[28][8] ), .B1(
        n9484), .B2(\cpuregs[12][8] ), .Y(n4437) );
  sky130_fd_sc_hd__a22oi_1 U5798 ( .A1(n9485), .A2(\cpuregs[21][8] ), .B1(
        n9461), .B2(\cpuregs[5][8] ), .Y(n4436) );
  sky130_fd_sc_hd__nand2_1 U5799 ( .A(n9456), .B(\cpuregs[17][8] ), .Y(n4435)
         );
  sky130_fd_sc_hd__nand4_1 U5800 ( .A(n4438), .B(n4437), .C(n4436), .D(n4435), 
        .Y(n4454) );
  sky130_fd_sc_hd__a22oi_1 U5801 ( .A1(n9495), .A2(\cpuregs[22][8] ), .B1(
        n9483), .B2(\cpuregs[7][8] ), .Y(n4442) );
  sky130_fd_sc_hd__a22oi_1 U5802 ( .A1(n9480), .A2(\cpuregs[20][8] ), .B1(
        n9496), .B2(\cpuregs[3][8] ), .Y(n4441) );
  sky130_fd_sc_hd__a22oi_1 U5803 ( .A1(n9471), .A2(\cpuregs[25][8] ), .B1(
        n9458), .B2(\cpuregs[30][8] ), .Y(n4440) );
  sky130_fd_sc_hd__a22oi_1 U5804 ( .A1(n9467), .A2(\cpuregs[26][8] ), .B1(
        n9482), .B2(\cpuregs[31][8] ), .Y(n4439) );
  sky130_fd_sc_hd__nand4_1 U5805 ( .A(n4442), .B(n4441), .C(n4440), .D(n4439), 
        .Y(n4453) );
  sky130_fd_sc_hd__a22oi_1 U5806 ( .A1(n9473), .A2(\cpuregs[23][8] ), .B1(
        n9478), .B2(\cpuregs[1][8] ), .Y(n4446) );
  sky130_fd_sc_hd__a22oi_1 U5807 ( .A1(n9481), .A2(\cpuregs[14][8] ), .B1(
        n9460), .B2(\cpuregs[24][8] ), .Y(n4445) );
  sky130_fd_sc_hd__a22oi_1 U5808 ( .A1(n9468), .A2(\cpuregs[16][8] ), .B1(
        n9462), .B2(\cpuregs[2][8] ), .Y(n4444) );
  sky130_fd_sc_hd__a22oi_1 U5809 ( .A1(n9490), .A2(\cpuregs[11][8] ), .B1(
        n9479), .B2(\cpuregs[29][8] ), .Y(n4443) );
  sky130_fd_sc_hd__nand4_1 U5810 ( .A(n4446), .B(n4445), .C(n4444), .D(n4443), 
        .Y(n4452) );
  sky130_fd_sc_hd__a22oi_1 U5811 ( .A1(n9321), .A2(\cpuregs[27][8] ), .B1(
        n9469), .B2(\cpuregs[9][8] ), .Y(n4450) );
  sky130_fd_sc_hd__a22oi_1 U5812 ( .A1(n9457), .A2(\cpuregs[19][8] ), .B1(
        n9493), .B2(\cpuregs[6][8] ), .Y(n4449) );
  sky130_fd_sc_hd__a22oi_1 U5813 ( .A1(n9494), .A2(\cpuregs[8][8] ), .B1(n9470), .B2(\cpuregs[13][8] ), .Y(n4448) );
  sky130_fd_sc_hd__a22oi_1 U5814 ( .A1(n9497), .A2(\cpuregs[15][8] ), .B1(
        n9459), .B2(\cpuregs[18][8] ), .Y(n4447) );
  sky130_fd_sc_hd__nand4_1 U5815 ( .A(n4450), .B(n4449), .C(n4448), .D(n4447), 
        .Y(n4451) );
  sky130_fd_sc_hd__nor4_1 U5816 ( .A(n4454), .B(n4453), .C(n4452), .D(n4451), 
        .Y(n4457) );
  sky130_fd_sc_hd__inv_1 U5817 ( .A(n9302), .Y(n4455) );
  sky130_fd_sc_hd__a211oi_1 U5818 ( .A1(n9511), .A2(n4460), .B1(n4459), .C1(
        n4458), .Y(n4461) );
  sky130_fd_sc_hd__nand2_1 U5819 ( .A(n9484), .B(\cpuregs[12][15] ), .Y(n4466)
         );
  sky130_fd_sc_hd__a22oi_1 U5820 ( .A1(n9478), .A2(\cpuregs[1][15] ), .B1(
        n9496), .B2(\cpuregs[3][15] ), .Y(n4465) );
  sky130_fd_sc_hd__a22oi_1 U5821 ( .A1(n9462), .A2(\cpuregs[2][15] ), .B1(
        n9316), .B2(\cpuregs[4][15] ), .Y(n4464) );
  sky130_fd_sc_hd__a22oi_1 U5822 ( .A1(n9493), .A2(\cpuregs[6][15] ), .B1(
        n9456), .B2(\cpuregs[17][15] ), .Y(n4463) );
  sky130_fd_sc_hd__nand4_1 U5823 ( .A(n4466), .B(n4465), .C(n4464), .D(n4463), 
        .Y(n4482) );
  sky130_fd_sc_hd__a22oi_1 U5824 ( .A1(n9468), .A2(\cpuregs[16][15] ), .B1(
        n9459), .B2(\cpuregs[18][15] ), .Y(n4470) );
  sky130_fd_sc_hd__a22oi_1 U5825 ( .A1(n9467), .A2(\cpuregs[26][15] ), .B1(
        n9494), .B2(\cpuregs[8][15] ), .Y(n4469) );
  sky130_fd_sc_hd__a22oi_1 U5826 ( .A1(n9483), .A2(\cpuregs[7][15] ), .B1(
        n9461), .B2(\cpuregs[5][15] ), .Y(n4468) );
  sky130_fd_sc_hd__a22oi_1 U5827 ( .A1(n9469), .A2(\cpuregs[9][15] ), .B1(
        n9457), .B2(\cpuregs[19][15] ), .Y(n4467) );
  sky130_fd_sc_hd__nand4_1 U5828 ( .A(n4470), .B(n4469), .C(n4468), .D(n4467), 
        .Y(n4481) );
  sky130_fd_sc_hd__a22oi_1 U5829 ( .A1(n9481), .A2(\cpuregs[14][15] ), .B1(
        n9470), .B2(\cpuregs[13][15] ), .Y(n4474) );
  sky130_fd_sc_hd__a22oi_1 U5830 ( .A1(n9482), .A2(\cpuregs[31][15] ), .B1(
        n9495), .B2(\cpuregs[22][15] ), .Y(n4473) );
  sky130_fd_sc_hd__a22oi_1 U5831 ( .A1(n9458), .A2(\cpuregs[30][15] ), .B1(
        n9479), .B2(\cpuregs[29][15] ), .Y(n4472) );
  sky130_fd_sc_hd__a22oi_1 U5832 ( .A1(n9492), .A2(\cpuregs[28][15] ), .B1(
        n9497), .B2(\cpuregs[15][15] ), .Y(n4471) );
  sky130_fd_sc_hd__nand4_1 U5833 ( .A(n4474), .B(n4473), .C(n4472), .D(n4471), 
        .Y(n4480) );
  sky130_fd_sc_hd__a22oi_1 U5834 ( .A1(n9473), .A2(\cpuregs[23][15] ), .B1(
        n9480), .B2(\cpuregs[20][15] ), .Y(n4478) );
  sky130_fd_sc_hd__a22oi_1 U5835 ( .A1(n9485), .A2(\cpuregs[21][15] ), .B1(
        n9460), .B2(\cpuregs[24][15] ), .Y(n4477) );
  sky130_fd_sc_hd__a22oi_1 U5836 ( .A1(n9490), .A2(\cpuregs[11][15] ), .B1(
        n9491), .B2(\cpuregs[10][15] ), .Y(n4476) );
  sky130_fd_sc_hd__a22oi_1 U5837 ( .A1(n9321), .A2(\cpuregs[27][15] ), .B1(
        n9471), .B2(\cpuregs[25][15] ), .Y(n4475) );
  sky130_fd_sc_hd__nand4_1 U5838 ( .A(n4478), .B(n4477), .C(n4476), .D(n4475), 
        .Y(n4479) );
  sky130_fd_sc_hd__nor4_1 U5839 ( .A(n4482), .B(n4481), .C(n4480), .D(n4479), 
        .Y(n4483) );
  sky130_fd_sc_hd__o22ai_1 U5840 ( .A1(n4483), .A2(n9506), .B1(n8820), .B2(
        n4371), .Y(n4505) );
  sky130_fd_sc_hd__nand2_1 U5841 ( .A(n9345), .B(pcpi_rs1[19]), .Y(n4504) );
  sky130_fd_sc_hd__o21ai_1 U5842 ( .A1(n4486), .A2(n6326), .B1(n4485), .Y(
        n6466) );
  sky130_fd_sc_hd__o21ai_1 U5843 ( .A1(n4489), .A2(n8784), .B1(n4488), .Y(
        n8853) );
  sky130_fd_sc_hd__a21oi_1 U5844 ( .A1(n8853), .A2(n8852), .B1(n4491), .Y(
        n4496) );
  sky130_fd_sc_hd__nand2_1 U5845 ( .A(n4494), .B(n4493), .Y(n4495) );
  sky130_fd_sc_hd__xor2_1 U5846 ( .A(n4496), .B(n4495), .X(n4497) );
  sky130_fd_sc_hd__nand2_1 U5847 ( .A(n4497), .B(n9511), .Y(n4500) );
  sky130_fd_sc_hd__a22oi_1 U5848 ( .A1(n9280), .A2(reg_pc[15]), .B1(n9452), 
        .B2(pcpi_rs1[15]), .Y(n4499) );
  sky130_fd_sc_hd__nand2_1 U5849 ( .A(n4500), .B(n4499), .Y(n4502) );
  sky130_fd_sc_hd__o22ai_1 U5850 ( .A1(n7431), .A2(n4342), .B1(n8889), .B2(
        n4340), .Y(n4501) );
  sky130_fd_sc_hd__nor2_1 U5851 ( .A(n4502), .B(n4501), .Y(n4503) );
  sky130_fd_sc_hd__nand3b_1 U5852 ( .A_N(n4505), .B(n4504), .C(n4503), .Y(
        n2780) );
  sky130_fd_sc_hd__nand2_1 U5853 ( .A(n9484), .B(\cpuregs[12][29] ), .Y(n4509)
         );
  sky130_fd_sc_hd__a22oi_1 U5854 ( .A1(n9478), .A2(\cpuregs[1][29] ), .B1(
        n9496), .B2(\cpuregs[3][29] ), .Y(n4508) );
  sky130_fd_sc_hd__a22oi_1 U5855 ( .A1(n9462), .A2(\cpuregs[2][29] ), .B1(
        n9472), .B2(\cpuregs[4][29] ), .Y(n4507) );
  sky130_fd_sc_hd__a22oi_1 U5856 ( .A1(n9493), .A2(\cpuregs[6][29] ), .B1(
        n9456), .B2(\cpuregs[17][29] ), .Y(n4506) );
  sky130_fd_sc_hd__nand4_1 U5857 ( .A(n4509), .B(n4508), .C(n4507), .D(n4506), 
        .Y(n4527) );
  sky130_fd_sc_hd__nand2_1 U5858 ( .A(n9494), .B(\cpuregs[8][29] ), .Y(n4514)
         );
  sky130_fd_sc_hd__a22oi_1 U5859 ( .A1(n9469), .A2(\cpuregs[9][29] ), .B1(
        n9457), .B2(\cpuregs[19][29] ), .Y(n4513) );
  sky130_fd_sc_hd__a22oi_1 U5860 ( .A1(n9483), .A2(\cpuregs[7][29] ), .B1(
        n9461), .B2(\cpuregs[5][29] ), .Y(n4512) );
  sky130_fd_sc_hd__a22oi_1 U5861 ( .A1(n9468), .A2(\cpuregs[16][29] ), .B1(
        n9459), .B2(\cpuregs[18][29] ), .Y(n4511) );
  sky130_fd_sc_hd__nand2_1 U5862 ( .A(n9467), .B(\cpuregs[26][29] ), .Y(n4510)
         );
  sky130_fd_sc_hd__nand4_1 U5863 ( .A(n4514), .B(n4513), .C(n4512), .D(n4232), 
        .Y(n4526) );
  sky130_fd_sc_hd__a22oi_1 U5864 ( .A1(n9473), .A2(\cpuregs[23][29] ), .B1(
        n9480), .B2(\cpuregs[20][29] ), .Y(n4519) );
  sky130_fd_sc_hd__a22oi_1 U5865 ( .A1(n9485), .A2(\cpuregs[21][29] ), .B1(
        n8946), .B2(\cpuregs[24][29] ), .Y(n4518) );
  sky130_fd_sc_hd__a22oi_1 U5866 ( .A1(n9490), .A2(\cpuregs[11][29] ), .B1(
        n9491), .B2(\cpuregs[10][29] ), .Y(n4517) );
  sky130_fd_sc_hd__a22oi_1 U5867 ( .A1(n9321), .A2(\cpuregs[27][29] ), .B1(
        n9471), .B2(\cpuregs[25][29] ), .Y(n4516) );
  sky130_fd_sc_hd__nand4_1 U5868 ( .A(n4519), .B(n4518), .C(n4517), .D(n4516), 
        .Y(n4525) );
  sky130_fd_sc_hd__a22oi_1 U5869 ( .A1(n9481), .A2(\cpuregs[14][29] ), .B1(
        n9470), .B2(\cpuregs[13][29] ), .Y(n4523) );
  sky130_fd_sc_hd__a22oi_1 U5870 ( .A1(n9482), .A2(\cpuregs[31][29] ), .B1(
        n9495), .B2(\cpuregs[22][29] ), .Y(n4522) );
  sky130_fd_sc_hd__a22oi_1 U5871 ( .A1(n9458), .A2(\cpuregs[30][29] ), .B1(
        n9479), .B2(\cpuregs[29][29] ), .Y(n4521) );
  sky130_fd_sc_hd__a22oi_1 U5872 ( .A1(n9492), .A2(\cpuregs[28][29] ), .B1(
        n9497), .B2(\cpuregs[15][29] ), .Y(n4520) );
  sky130_fd_sc_hd__nand4_1 U5873 ( .A(n4523), .B(n4522), .C(n4521), .D(n4520), 
        .Y(n4524) );
  sky130_fd_sc_hd__nor4_1 U5874 ( .A(n4527), .B(n4526), .C(n4525), .D(n4524), 
        .Y(n4554) );
  sky130_fd_sc_hd__nand2_1 U5875 ( .A(n4528), .B(pcpi_rs1[31]), .Y(n9277) );
  sky130_fd_sc_hd__nand2_1 U5876 ( .A(n4698), .B(n4529), .Y(n4734) );
  sky130_fd_sc_hd__nor2_1 U5877 ( .A(n4534), .B(n4530), .Y(n4537) );
  sky130_fd_sc_hd__nand2_1 U5878 ( .A(n4531), .B(n4537), .Y(n4540) );
  sky130_fd_sc_hd__nor2_1 U5879 ( .A(n4532), .B(n4540), .Y(n6760) );
  sky130_fd_sc_hd__nor2_1 U5880 ( .A(decoded_imm[27]), .B(pcpi_rs1[27]), .Y(
        n7185) );
  sky130_fd_sc_hd__nor2_1 U5881 ( .A(decoded_imm[25]), .B(pcpi_rs1[25]), .Y(
        n6756) );
  sky130_fd_sc_hd__nor2_1 U5882 ( .A(decoded_imm[24]), .B(pcpi_rs1[24]), .Y(
        n7544) );
  sky130_fd_sc_hd__nor2_1 U5883 ( .A(n6756), .B(n7544), .Y(n8958) );
  sky130_fd_sc_hd__nand2_1 U5884 ( .A(n8958), .B(n8961), .Y(n7181) );
  sky130_fd_sc_hd__nor2_1 U5885 ( .A(n7185), .B(n7181), .Y(n4543) );
  sky130_fd_sc_hd__nand2_1 U5886 ( .A(n6760), .B(n4543), .Y(n4546) );
  sky130_fd_sc_hd__o21ai_1 U5887 ( .A1(n8922), .A2(n4534), .B1(n4533), .Y(
        n4535) );
  sky130_fd_sc_hd__a21oi_1 U5888 ( .A1(n4537), .A2(n4536), .B1(n4535), .Y(
        n4538) );
  sky130_fd_sc_hd__o21ai_1 U5889 ( .A1(n4540), .A2(n4539), .B1(n4538), .Y(
        n6759) );
  sky130_fd_sc_hd__nand2_1 U5890 ( .A(pcpi_rs1[24]), .B(decoded_imm[24]), .Y(
        n7545) );
  sky130_fd_sc_hd__nand2_1 U5891 ( .A(pcpi_rs1[25]), .B(decoded_imm[25]), .Y(
        n6757) );
  sky130_fd_sc_hd__o21ai_1 U5892 ( .A1(n7545), .A2(n6756), .B1(n6757), .Y(
        n8957) );
  sky130_fd_sc_hd__nand2_1 U5893 ( .A(pcpi_rs1[26]), .B(decoded_imm[26]), .Y(
        n8960) );
  sky130_fd_sc_hd__a21oi_1 U5894 ( .A1(n8957), .A2(n8961), .B1(n4541), .Y(
        n7182) );
  sky130_fd_sc_hd__nand2_1 U5895 ( .A(pcpi_rs1[27]), .B(decoded_imm[27]), .Y(
        n7186) );
  sky130_fd_sc_hd__o21ai_1 U5896 ( .A1(n7185), .A2(n7182), .B1(n7186), .Y(
        n4542) );
  sky130_fd_sc_hd__a21oi_1 U5897 ( .A1(n6759), .A2(n4543), .B1(n4542), .Y(
        n4544) );
  sky130_fd_sc_hd__o21ai_1 U5898 ( .A1(n4546), .A2(n4545), .B1(n4544), .Y(
        n4710) );
  sky130_fd_sc_hd__nand2_1 U5899 ( .A(pcpi_rs1[28]), .B(decoded_imm[28]), .Y(
        n4708) );
  sky130_fd_sc_hd__a21oi_1 U5900 ( .A1(n4710), .A2(n4709), .B1(n4547), .Y(
        n4618) );
  sky130_fd_sc_hd__nor2_1 U5901 ( .A(decoded_imm[29]), .B(pcpi_rs1[29]), .Y(
        n4619) );
  sky130_fd_sc_hd__nand2_1 U5902 ( .A(pcpi_rs1[29]), .B(decoded_imm[29]), .Y(
        n4617) );
  sky130_fd_sc_hd__nand2_1 U5903 ( .A(n4548), .B(n4617), .Y(n4549) );
  sky130_fd_sc_hd__xor2_1 U5904 ( .A(n4618), .B(n4549), .X(n4550) );
  sky130_fd_sc_hd__o2bb2ai_1 U5905 ( .B1(n9305), .B2(n4342), .A1_N(n9511), 
        .A2_N(n4550), .Y(n4551) );
  sky130_fd_sc_hd__nor2_1 U5906 ( .A(n4552), .B(n4551), .Y(n4553) );
  sky130_fd_sc_hd__o21ai_1 U5907 ( .A1(n9506), .A2(n4554), .B1(n4553), .Y(
        n2766) );
  sky130_fd_sc_hd__nor2_1 U5908 ( .A(pcpi_rs1[14]), .B(pcpi_rs2[14]), .Y(n5438) );
  sky130_fd_sc_hd__nor2_1 U5909 ( .A(is_lui_auipc_jal_jalr_addi_add_sub), .B(
        is_compare), .Y(n4557) );
  sky130_fd_sc_hd__nand2b_1 U5910 ( .A_N(n4558), .B(n4557), .Y(n4559) );
  sky130_fd_sc_hd__nand2_1 U5911 ( .A(n4558), .B(n4557), .Y(n8683) );
  sky130_fd_sc_hd__o21ai_1 U5912 ( .A1(n5437), .A2(n8683), .B1(n8386), .Y(
        n4561) );
  sky130_fd_sc_hd__a21oi_1 U5913 ( .A1(n5437), .A2(n9382), .B1(n4561), .Y(
        n4593) );
  sky130_fd_sc_hd__buf_4 U5914 ( .A(instr_sub), .X(n4562) );
  sky130_fd_sc_hd__xor2_1 U5915 ( .A(n4562), .B(pcpi_rs2[12]), .X(n4583) );
  sky130_fd_sc_hd__nor2_1 U5916 ( .A(pcpi_rs1[12]), .B(n4583), .Y(n4802) );
  sky130_fd_sc_hd__xor2_1 U5917 ( .A(n4562), .B(pcpi_rs2[11]), .X(n4582) );
  sky130_fd_sc_hd__nor2_1 U5918 ( .A(pcpi_rs1[11]), .B(n4582), .Y(n4799) );
  sky130_fd_sc_hd__nor2_1 U5919 ( .A(n4802), .B(n4799), .Y(n6077) );
  sky130_fd_sc_hd__xor2_1 U5920 ( .A(n4562), .B(pcpi_rs2[8]), .X(n4577) );
  sky130_fd_sc_hd__nor2_1 U5921 ( .A(pcpi_rs1[8]), .B(n4577), .Y(n8161) );
  sky130_fd_sc_hd__xor2_1 U5922 ( .A(n4562), .B(pcpi_rs2[7]), .X(n4576) );
  sky130_fd_sc_hd__nor2_1 U5923 ( .A(pcpi_rs1[7]), .B(n4576), .Y(n9041) );
  sky130_fd_sc_hd__nor2_1 U5924 ( .A(n8161), .B(n9041), .Y(n6283) );
  sky130_fd_sc_hd__xor2_1 U5925 ( .A(n4562), .B(pcpi_rs2[10]), .X(n4579) );
  sky130_fd_sc_hd__nor2_1 U5926 ( .A(pcpi_rs1[10]), .B(n4579), .Y(n8108) );
  sky130_fd_sc_hd__xor2_1 U5927 ( .A(n4562), .B(pcpi_rs2[9]), .X(n4578) );
  sky130_fd_sc_hd__nor2_1 U5928 ( .A(pcpi_rs1[9]), .B(n4578), .Y(n6282) );
  sky130_fd_sc_hd__nor2_1 U5929 ( .A(n8108), .B(n6282), .Y(n4581) );
  sky130_fd_sc_hd__nand2_1 U5930 ( .A(n6283), .B(n4581), .Y(n6078) );
  sky130_fd_sc_hd__xor2_1 U5931 ( .A(n4562), .B(pcpi_rs2[4]), .X(n4569) );
  sky130_fd_sc_hd__nor2_1 U5932 ( .A(pcpi_rs1[4]), .B(n4569), .Y(n8390) );
  sky130_fd_sc_hd__xor2_1 U5933 ( .A(n4562), .B(pcpi_rs2[3]), .X(n4568) );
  sky130_fd_sc_hd__nor2_1 U5934 ( .A(pcpi_rs1[3]), .B(n4568), .Y(n8388) );
  sky130_fd_sc_hd__nor2_1 U5935 ( .A(n8390), .B(n8388), .Y(n8241) );
  sky130_fd_sc_hd__xor2_1 U5936 ( .A(n4562), .B(pcpi_rs2[6]), .X(n4571) );
  sky130_fd_sc_hd__nor2_1 U5937 ( .A(pcpi_rs1[6]), .B(n4571), .Y(n8236) );
  sky130_fd_sc_hd__xor2_1 U5938 ( .A(n4562), .B(pcpi_rs2[5]), .X(n4570) );
  sky130_fd_sc_hd__nor2_1 U5939 ( .A(pcpi_rs1[5]), .B(n4570), .Y(n8287) );
  sky130_fd_sc_hd__nor2_1 U5940 ( .A(n8236), .B(n8287), .Y(n4573) );
  sky130_fd_sc_hd__nand2_1 U5941 ( .A(n8241), .B(n4573), .Y(n4575) );
  sky130_fd_sc_hd__xor2_1 U5942 ( .A(n4562), .B(pcpi_rs2[2]), .X(n4565) );
  sky130_fd_sc_hd__nor2_1 U5943 ( .A(pcpi_rs1[2]), .B(n4565), .Y(n9372) );
  sky130_fd_sc_hd__xor2_1 U5944 ( .A(n4562), .B(pcpi_rs2[1]), .X(n4564) );
  sky130_fd_sc_hd__nor2_1 U5945 ( .A(pcpi_rs1[1]), .B(n4564), .Y(n9377) );
  sky130_fd_sc_hd__nor2_1 U5946 ( .A(n9372), .B(n9377), .Y(n4567) );
  sky130_fd_sc_hd__buf_4 U5947 ( .A(instr_sub), .X(n9017) );
  sky130_fd_sc_hd__nor2_1 U5948 ( .A(pcpi_rs1[0]), .B(n9017), .Y(n9866) );
  sky130_fd_sc_hd__xor2_1 U5949 ( .A(n4562), .B(pcpi_rs2[0]), .X(n9870) );
  sky130_fd_sc_hd__nand2_1 U5950 ( .A(n9017), .B(pcpi_rs1[0]), .Y(n9867) );
  sky130_fd_sc_hd__o21ai_1 U5951 ( .A1(n9866), .A2(n4563), .B1(n9867), .Y(
        n9166) );
  sky130_fd_sc_hd__nand2_1 U5952 ( .A(n4564), .B(pcpi_rs1[1]), .Y(n9375) );
  sky130_fd_sc_hd__nand2_1 U5953 ( .A(n4565), .B(pcpi_rs1[2]), .Y(n9373) );
  sky130_fd_sc_hd__o21ai_1 U5954 ( .A1(n9375), .A2(n9372), .B1(n9373), .Y(
        n4566) );
  sky130_fd_sc_hd__a21oi_1 U5955 ( .A1(n4567), .A2(n9166), .B1(n4566), .Y(
        n8239) );
  sky130_fd_sc_hd__nand2_1 U5956 ( .A(n4568), .B(pcpi_rs1[3]), .Y(n8515) );
  sky130_fd_sc_hd__nand2_1 U5957 ( .A(n4569), .B(pcpi_rs1[4]), .Y(n8391) );
  sky130_fd_sc_hd__o21ai_1 U5958 ( .A1(n8515), .A2(n8390), .B1(n8391), .Y(
        n8240) );
  sky130_fd_sc_hd__nand2_1 U5959 ( .A(n4570), .B(pcpi_rs1[5]), .Y(n8288) );
  sky130_fd_sc_hd__nand2_1 U5960 ( .A(n4571), .B(pcpi_rs1[6]), .Y(n8237) );
  sky130_fd_sc_hd__o21ai_1 U5961 ( .A1(n8288), .A2(n8236), .B1(n8237), .Y(
        n4572) );
  sky130_fd_sc_hd__a21oi_1 U5962 ( .A1(n4573), .A2(n8240), .B1(n4572), .Y(
        n4574) );
  sky130_fd_sc_hd__o21ai_1 U5963 ( .A1(n4575), .A2(n8239), .B1(n4574), .Y(
        n6089) );
  sky130_fd_sc_hd__inv_1 U5964 ( .A(n6089), .Y(n9045) );
  sky130_fd_sc_hd__nand2_1 U5965 ( .A(n4576), .B(pcpi_rs1[7]), .Y(n9042) );
  sky130_fd_sc_hd__nand2_1 U5966 ( .A(n4577), .B(pcpi_rs1[8]), .Y(n8162) );
  sky130_fd_sc_hd__o21ai_1 U5967 ( .A1(n9042), .A2(n8161), .B1(n8162), .Y(
        n6284) );
  sky130_fd_sc_hd__nand2_1 U5968 ( .A(n4578), .B(pcpi_rs1[9]), .Y(n8104) );
  sky130_fd_sc_hd__nand2_1 U5969 ( .A(n4579), .B(pcpi_rs1[10]), .Y(n8109) );
  sky130_fd_sc_hd__o21ai_1 U5970 ( .A1(n8104), .A2(n8108), .B1(n8109), .Y(
        n4580) );
  sky130_fd_sc_hd__a21oi_1 U5971 ( .A1(n4581), .A2(n6284), .B1(n4580), .Y(
        n6085) );
  sky130_fd_sc_hd__o21ai_1 U5972 ( .A1(n6078), .A2(n9045), .B1(n6085), .Y(
        n4801) );
  sky130_fd_sc_hd__nand2_1 U5973 ( .A(n4582), .B(pcpi_rs1[11]), .Y(n8047) );
  sky130_fd_sc_hd__nand2_1 U5974 ( .A(n4583), .B(pcpi_rs1[12]), .Y(n4803) );
  sky130_fd_sc_hd__o21ai_1 U5975 ( .A1(n8047), .A2(n4802), .B1(n4803), .Y(
        n6082) );
  sky130_fd_sc_hd__o21ai_1 U5976 ( .A1(n4585), .A2(n8050), .B1(n4584), .Y(
        n6433) );
  sky130_fd_sc_hd__xor2_1 U5977 ( .A(n9017), .B(pcpi_rs2[13]), .X(n4586) );
  sky130_fd_sc_hd__nor2_1 U5978 ( .A(pcpi_rs1[13]), .B(n4586), .Y(n6076) );
  sky130_fd_sc_hd__nand2_1 U5979 ( .A(n4586), .B(pcpi_rs1[13]), .Y(n6431) );
  sky130_fd_sc_hd__a21oi_1 U5980 ( .A1(n6433), .A2(n6432), .B1(n4587), .Y(
        n4591) );
  sky130_fd_sc_hd__xor2_1 U5981 ( .A(n9017), .B(pcpi_rs2[14]), .X(n4588) );
  sky130_fd_sc_hd__nor2_1 U5982 ( .A(pcpi_rs1[14]), .B(n4588), .Y(n6080) );
  sky130_fd_sc_hd__nand2_1 U5983 ( .A(n4588), .B(pcpi_rs1[14]), .Y(n6079) );
  sky130_fd_sc_hd__nand2_1 U5984 ( .A(n4589), .B(n6079), .Y(n4590) );
  sky130_fd_sc_hd__xor2_1 U5985 ( .A(n4591), .B(n4590), .X(n4592) );
  sky130_fd_sc_hd__o2bb2ai_1 U5986 ( .B1(n5438), .B2(n4593), .A1_N(
        is_lui_auipc_jal_jalr_addi_add_sub), .A2_N(n4592), .Y(alu_out[14]) );
  sky130_fd_sc_hd__a22oi_1 U5987 ( .A1(n9478), .A2(\cpuregs[1][30] ), .B1(
        n9496), .B2(\cpuregs[3][30] ), .Y(n4597) );
  sky130_fd_sc_hd__a22oi_1 U5988 ( .A1(n9493), .A2(\cpuregs[6][30] ), .B1(
        n9456), .B2(\cpuregs[17][30] ), .Y(n4596) );
  sky130_fd_sc_hd__nand2_1 U5989 ( .A(n9484), .B(\cpuregs[12][30] ), .Y(n4595)
         );
  sky130_fd_sc_hd__a22oi_1 U5990 ( .A1(n9462), .A2(\cpuregs[2][30] ), .B1(
        n9316), .B2(\cpuregs[4][30] ), .Y(n4594) );
  sky130_fd_sc_hd__nand4_1 U5991 ( .A(n4597), .B(n4596), .C(n4595), .D(n4594), 
        .Y(n4613) );
  sky130_fd_sc_hd__a22oi_1 U5992 ( .A1(n9480), .A2(\cpuregs[20][30] ), .B1(
        n9473), .B2(\cpuregs[23][30] ), .Y(n4601) );
  sky130_fd_sc_hd__a22oi_1 U5993 ( .A1(n9490), .A2(\cpuregs[11][30] ), .B1(
        n9491), .B2(\cpuregs[10][30] ), .Y(n4600) );
  sky130_fd_sc_hd__a22oi_1 U5994 ( .A1(n9321), .A2(\cpuregs[27][30] ), .B1(
        n9471), .B2(\cpuregs[25][30] ), .Y(n4599) );
  sky130_fd_sc_hd__a22oi_1 U5995 ( .A1(n9460), .A2(\cpuregs[24][30] ), .B1(
        n9485), .B2(\cpuregs[21][30] ), .Y(n4598) );
  sky130_fd_sc_hd__nand4_1 U5996 ( .A(n4601), .B(n4600), .C(n4599), .D(n4598), 
        .Y(n4612) );
  sky130_fd_sc_hd__a22oi_1 U5997 ( .A1(n9468), .A2(\cpuregs[16][30] ), .B1(
        n9459), .B2(\cpuregs[18][30] ), .Y(n4605) );
  sky130_fd_sc_hd__a22oi_1 U5998 ( .A1(n9467), .A2(\cpuregs[26][30] ), .B1(
        n9494), .B2(\cpuregs[8][30] ), .Y(n4604) );
  sky130_fd_sc_hd__a22oi_1 U5999 ( .A1(n9483), .A2(\cpuregs[7][30] ), .B1(
        n9461), .B2(\cpuregs[5][30] ), .Y(n4603) );
  sky130_fd_sc_hd__a22oi_1 U6000 ( .A1(n9469), .A2(\cpuregs[9][30] ), .B1(
        n9457), .B2(\cpuregs[19][30] ), .Y(n4602) );
  sky130_fd_sc_hd__nand4_1 U6001 ( .A(n4605), .B(n4604), .C(n4603), .D(n4602), 
        .Y(n4611) );
  sky130_fd_sc_hd__a22oi_1 U6002 ( .A1(n9481), .A2(\cpuregs[14][30] ), .B1(
        n9470), .B2(\cpuregs[13][30] ), .Y(n4609) );
  sky130_fd_sc_hd__a22oi_1 U6003 ( .A1(n9482), .A2(\cpuregs[31][30] ), .B1(
        n9495), .B2(\cpuregs[22][30] ), .Y(n4608) );
  sky130_fd_sc_hd__a22oi_1 U6004 ( .A1(n9458), .A2(\cpuregs[30][30] ), .B1(
        n9479), .B2(\cpuregs[29][30] ), .Y(n4607) );
  sky130_fd_sc_hd__a22oi_1 U6005 ( .A1(n9492), .A2(\cpuregs[28][30] ), .B1(
        n9497), .B2(\cpuregs[15][30] ), .Y(n4606) );
  sky130_fd_sc_hd__nand4_1 U6006 ( .A(n4609), .B(n4608), .C(n4607), .D(n4606), 
        .Y(n4610) );
  sky130_fd_sc_hd__nor4_1 U6007 ( .A(n4613), .B(n4612), .C(n4611), .D(n4610), 
        .Y(n4615) );
  sky130_fd_sc_hd__nand2_1 U6008 ( .A(n4701), .B(pcpi_rs1[29]), .Y(n4614) );
  sky130_fd_sc_hd__o211ai_1 U6009 ( .A1(n4615), .A2(n9302), .B1(n4734), .C1(
        n4614), .Y(n4616) );
  sky130_fd_sc_hd__nand2_1 U6010 ( .A(n4616), .B(n9340), .Y(n4625) );
  sky130_fd_sc_hd__nand2_1 U6011 ( .A(pcpi_rs1[30]), .B(decoded_imm[30]), .Y(
        n9267) );
  sky130_fd_sc_hd__nand2_1 U6012 ( .A(n9269), .B(n9267), .Y(n4620) );
  sky130_fd_sc_hd__o21ai_1 U6013 ( .A1(n4619), .A2(n4618), .B1(n4617), .Y(
        n9270) );
  sky130_fd_sc_hd__xnor2_1 U6014 ( .A(n4620), .B(n9270), .Y(n4621) );
  sky130_fd_sc_hd__a22oi_1 U6015 ( .A1(pcpi_rs1[26]), .A2(n9307), .B1(n4621), 
        .B2(n9511), .Y(n4624) );
  sky130_fd_sc_hd__a22oi_1 U6016 ( .A1(n9280), .A2(reg_pc[30]), .B1(n4456), 
        .B2(pcpi_rs1[31]), .Y(n4623) );
  sky130_fd_sc_hd__nand2b_1 U6017 ( .A_N(n9340), .B(pcpi_rs1[30]), .Y(n4622)
         );
  sky130_fd_sc_hd__nand4_1 U6018 ( .A(n4625), .B(n4624), .C(n4623), .D(n4622), 
        .Y(n2765) );
  sky130_fd_sc_hd__nand3_1 U6019 ( .A(n9524), .B(n5411), .C(n4626), .Y(n4629)
         );
  sky130_fd_sc_hd__nor3_2 U6020 ( .A(instr_rdinstr), .B(n4627), .C(n4629), .Y(
        n9856) );
  sky130_fd_sc_hd__nand2_1 U6021 ( .A(n9856), .B(count_instr[37]), .Y(n4645)
         );
  sky130_fd_sc_hd__a22o_1 U6022 ( .A1(n9859), .A2(mem_rdata_word[5]), .B1(
        n9858), .B2(pcpi_rs1[5]), .X(n4628) );
  sky130_fd_sc_hd__a21oi_1 U6023 ( .A1(n9861), .A2(count_cycle[37]), .B1(n4628), .Y(n4644) );
  sky130_fd_sc_hd__nand2_1 U6024 ( .A(n9860), .B(count_cycle[5]), .Y(n4643) );
  sky130_fd_sc_hd__inv_1 U6025 ( .A(instr_rdinstr), .Y(n5413) );
  sky130_fd_sc_hd__nor2_1 U6026 ( .A(decoded_imm[3]), .B(reg_pc[3]), .Y(n5956)
         );
  sky130_fd_sc_hd__nor2_1 U6027 ( .A(decoded_imm[2]), .B(reg_pc[2]), .Y(n9352)
         );
  sky130_fd_sc_hd__nor2_1 U6028 ( .A(n5956), .B(n9352), .Y(n4632) );
  sky130_fd_sc_hd__nand2_1 U6029 ( .A(reg_pc[1]), .B(decoded_imm[1]), .Y(n9356) );
  sky130_fd_sc_hd__nand2_1 U6030 ( .A(reg_pc[2]), .B(decoded_imm[2]), .Y(n9353) );
  sky130_fd_sc_hd__nand2_1 U6031 ( .A(reg_pc[3]), .B(decoded_imm[3]), .Y(n5957) );
  sky130_fd_sc_hd__o21ai_1 U6032 ( .A1(n9353), .A2(n5956), .B1(n5957), .Y(
        n4630) );
  sky130_fd_sc_hd__a21oi_1 U6033 ( .A1(n4632), .A2(n4631), .B1(n4630), .Y(
        n5916) );
  sky130_fd_sc_hd__nor2_1 U6034 ( .A(decoded_imm[4]), .B(reg_pc[4]), .Y(n4648)
         );
  sky130_fd_sc_hd__nand2_1 U6035 ( .A(reg_pc[4]), .B(decoded_imm[4]), .Y(n8303) );
  sky130_fd_sc_hd__a21oi_1 U6036 ( .A1(n8305), .A2(n8304), .B1(n4633), .Y(
        n4636) );
  sky130_fd_sc_hd__nor2_1 U6037 ( .A(decoded_imm[5]), .B(reg_pc[5]), .Y(n4650)
         );
  sky130_fd_sc_hd__nand2_1 U6038 ( .A(reg_pc[5]), .B(decoded_imm[5]), .Y(n4649) );
  sky130_fd_sc_hd__nand2_1 U6039 ( .A(n4634), .B(n4649), .Y(n4635) );
  sky130_fd_sc_hd__xor2_1 U6040 ( .A(n4636), .B(n4635), .X(n4640) );
  sky130_fd_sc_hd__nand3_1 U6041 ( .A(n9449), .B(n5423), .C(cpu_state[3]), .Y(
        n4638) );
  sky130_fd_sc_hd__nand2_1 U6042 ( .A(n4640), .B(n4639), .Y(n4641) );
  sky130_fd_sc_hd__nand2_1 U6043 ( .A(n9856), .B(count_instr[39]), .Y(n4658)
         );
  sky130_fd_sc_hd__o22ai_1 U6044 ( .A1(n10124), .A2(n5944), .B1(n9079), .B2(
        n9437), .Y(n4646) );
  sky130_fd_sc_hd__a21oi_1 U6045 ( .A1(n9861), .A2(count_cycle[39]), .B1(n4646), .Y(n4657) );
  sky130_fd_sc_hd__nand2_1 U6046 ( .A(n9860), .B(count_cycle[7]), .Y(n4656) );
  sky130_fd_sc_hd__nor2_1 U6047 ( .A(decoded_imm[7]), .B(reg_pc[7]), .Y(n5911)
         );
  sky130_fd_sc_hd__nand2_1 U6048 ( .A(reg_pc[7]), .B(decoded_imm[7]), .Y(n5910) );
  sky130_fd_sc_hd__nand2_1 U6049 ( .A(n4647), .B(n5910), .Y(n4652) );
  sky130_fd_sc_hd__nor2_1 U6050 ( .A(decoded_imm[6]), .B(reg_pc[6]), .Y(n8191)
         );
  sky130_fd_sc_hd__nor2_1 U6051 ( .A(n4650), .B(n4648), .Y(n5909) );
  sky130_fd_sc_hd__o21ai_1 U6052 ( .A1(n8303), .A2(n4650), .B1(n4649), .Y(
        n5913) );
  sky130_fd_sc_hd__a21oi_1 U6053 ( .A1(n8305), .A2(n5909), .B1(n5913), .Y(
        n8195) );
  sky130_fd_sc_hd__nand2_1 U6054 ( .A(reg_pc[6]), .B(decoded_imm[6]), .Y(n8192) );
  sky130_fd_sc_hd__o21ai_1 U6055 ( .A1(n8191), .A2(n8195), .B1(n8192), .Y(
        n4651) );
  sky130_fd_sc_hd__xnor2_1 U6056 ( .A(n4652), .B(n4651), .Y(n4653) );
  sky130_fd_sc_hd__nand2_1 U6057 ( .A(n4653), .B(n4639), .Y(n4655) );
  sky130_fd_sc_hd__nand2_1 U6058 ( .A(n9857), .B(count_instr[7]), .Y(n4654) );
  sky130_fd_sc_hd__nand2_1 U6059 ( .A(n4809), .B(latched_rd[4]), .Y(n4663) );
  sky130_fd_sc_hd__nand3_2 U6060 ( .A(n4660), .B(n4659), .C(cpu_state[6]), .Y(
        n9521) );
  sky130_fd_sc_hd__or2_4 U6061 ( .A(n10060), .B(n9521), .X(n9387) );
  sky130_fd_sc_hd__inv_6 U6062 ( .A(n9387), .Y(n10055) );
  sky130_fd_sc_hd__inv_1 U6063 ( .A(latched_store), .Y(n4661) );
  sky130_fd_sc_hd__nand2_1 U6064 ( .A(n4661), .B(n4665), .Y(n4662) );
  sky130_fd_sc_hd__nor2_1 U6065 ( .A(n4663), .B(n6202), .Y(n6233) );
  sky130_fd_sc_hd__nand2_1 U6066 ( .A(n4664), .B(latched_rd[2]), .Y(n4811) );
  sky130_fd_sc_hd__nor2_1 U6067 ( .A(latched_rd[1]), .B(n4811), .Y(n6241) );
  sky130_fd_sc_hd__nand2_1 U6068 ( .A(n10058), .B(\cpuregs[20][3] ), .Y(n4669)
         );
  sky130_fd_sc_hd__xnor2_1 U6069 ( .A(reg_pc[2]), .B(n8723), .Y(n4666) );
  sky130_fd_sc_hd__nand2_1 U6070 ( .A(n4666), .B(n9813), .Y(n4668) );
  sky130_fd_sc_hd__a22oi_1 U6071 ( .A1(n9816), .A2(reg_out[3]), .B1(n9815), 
        .B2(alu_out_q[3]), .Y(n4667) );
  sky130_fd_sc_hd__inv_2 U6072 ( .A(n4218), .Y(n10058) );
  sky130_fd_sc_hd__nand2_1 U6073 ( .A(n4669), .B(n4239), .Y(n3822) );
  sky130_fd_sc_hd__nand2_1 U6074 ( .A(n4672), .B(n4671), .Y(n4677) );
  sky130_fd_sc_hd__a21oi_1 U6075 ( .A1(n9111), .A2(n4675), .B1(n4674), .Y(
        n9078) );
  sky130_fd_sc_hd__o21ai_1 U6076 ( .A1(n9074), .A2(n9078), .B1(n9075), .Y(
        n4676) );
  sky130_fd_sc_hd__xnor2_1 U6077 ( .A(n4677), .B(n4676), .Y(n4705) );
  sky130_fd_sc_hd__a22oi_1 U6078 ( .A1(n9497), .A2(\cpuregs[15][7] ), .B1(
        n9469), .B2(\cpuregs[9][7] ), .Y(n4681) );
  sky130_fd_sc_hd__a22oi_1 U6079 ( .A1(n9461), .A2(\cpuregs[5][7] ), .B1(n9316), .B2(\cpuregs[4][7] ), .Y(n4680) );
  sky130_fd_sc_hd__a22oi_1 U6080 ( .A1(n9457), .A2(\cpuregs[19][7] ), .B1(
        n9496), .B2(\cpuregs[3][7] ), .Y(n4679) );
  sky130_fd_sc_hd__a22oi_1 U6081 ( .A1(n9321), .A2(\cpuregs[27][7] ), .B1(
        n8946), .B2(\cpuregs[24][7] ), .Y(n4678) );
  sky130_fd_sc_hd__nand4_1 U6082 ( .A(n4681), .B(n4680), .C(n4679), .D(n4678), 
        .Y(n4697) );
  sky130_fd_sc_hd__a22oi_1 U6083 ( .A1(n9473), .A2(\cpuregs[23][7] ), .B1(
        n9479), .B2(\cpuregs[29][7] ), .Y(n4685) );
  sky130_fd_sc_hd__a22oi_1 U6084 ( .A1(n9484), .A2(\cpuregs[12][7] ), .B1(
        n9456), .B2(\cpuregs[17][7] ), .Y(n4684) );
  sky130_fd_sc_hd__a22oi_1 U6085 ( .A1(n9471), .A2(\cpuregs[25][7] ), .B1(
        n9491), .B2(\cpuregs[10][7] ), .Y(n4683) );
  sky130_fd_sc_hd__a22oi_1 U6086 ( .A1(n9480), .A2(\cpuregs[20][7] ), .B1(
        n9478), .B2(\cpuregs[1][7] ), .Y(n4682) );
  sky130_fd_sc_hd__nand4_1 U6087 ( .A(n4685), .B(n4684), .C(n4683), .D(n4682), 
        .Y(n4696) );
  sky130_fd_sc_hd__a22oi_1 U6088 ( .A1(n9490), .A2(\cpuregs[11][7] ), .B1(
        n9483), .B2(\cpuregs[7][7] ), .Y(n4689) );
  sky130_fd_sc_hd__a22oi_1 U6089 ( .A1(n9493), .A2(\cpuregs[6][7] ), .B1(n9494), .B2(\cpuregs[8][7] ), .Y(n4688) );
  sky130_fd_sc_hd__a22oi_1 U6090 ( .A1(n9481), .A2(\cpuregs[14][7] ), .B1(
        n9462), .B2(\cpuregs[2][7] ), .Y(n4687) );
  sky130_fd_sc_hd__nand2_1 U6091 ( .A(n9468), .B(\cpuregs[16][7] ), .Y(n4686)
         );
  sky130_fd_sc_hd__nand4_1 U6092 ( .A(n4689), .B(n4688), .C(n4687), .D(n4686), 
        .Y(n4695) );
  sky130_fd_sc_hd__a22oi_1 U6093 ( .A1(n9495), .A2(\cpuregs[22][7] ), .B1(
        n9482), .B2(\cpuregs[31][7] ), .Y(n4693) );
  sky130_fd_sc_hd__a22oi_1 U6094 ( .A1(n9459), .A2(\cpuregs[18][7] ), .B1(
        n9470), .B2(\cpuregs[13][7] ), .Y(n4692) );
  sky130_fd_sc_hd__a22oi_1 U6095 ( .A1(n9492), .A2(\cpuregs[28][7] ), .B1(
        n9467), .B2(\cpuregs[26][7] ), .Y(n4691) );
  sky130_fd_sc_hd__a22oi_1 U6096 ( .A1(n9485), .A2(\cpuregs[21][7] ), .B1(
        n9458), .B2(\cpuregs[30][7] ), .Y(n4690) );
  sky130_fd_sc_hd__nand4_1 U6097 ( .A(n4693), .B(n4692), .C(n4691), .D(n4690), 
        .Y(n4694) );
  sky130_fd_sc_hd__nor4_1 U6098 ( .A(n4697), .B(n4696), .C(n4695), .D(n4694), 
        .Y(n4703) );
  sky130_fd_sc_hd__a22oi_1 U6099 ( .A1(n4698), .A2(pcpi_rs1[11]), .B1(n4732), 
        .B2(pcpi_rs1[3]), .Y(n4699) );
  sky130_fd_sc_hd__o21ai_1 U6100 ( .A1(n8786), .A2(n8848), .B1(n4699), .Y(
        n4700) );
  sky130_fd_sc_hd__a21oi_1 U6101 ( .A1(n4701), .A2(pcpi_rs1[6]), .B1(n4700), 
        .Y(n4702) );
  sky130_fd_sc_hd__o21ai_1 U6102 ( .A1(n9302), .A2(n4703), .B1(n4702), .Y(
        n4704) );
  sky130_fd_sc_hd__a21oi_1 U6103 ( .A1(n4705), .A2(n4826), .B1(n4704), .Y(
        n4707) );
  sky130_fd_sc_hd__o21ai_1 U6104 ( .A1(n9452), .A2(n4707), .B1(n4706), .Y(
        n2788) );
  sky130_fd_sc_hd__nand2_1 U6105 ( .A(n4709), .B(n4708), .Y(n4711) );
  sky130_fd_sc_hd__xnor2_1 U6106 ( .A(n4711), .B(n4710), .Y(n4740) );
  sky130_fd_sc_hd__a22oi_1 U6107 ( .A1(n9478), .A2(\cpuregs[1][28] ), .B1(
        n9496), .B2(\cpuregs[3][28] ), .Y(n4715) );
  sky130_fd_sc_hd__a22oi_1 U6108 ( .A1(n9493), .A2(\cpuregs[6][28] ), .B1(
        n9456), .B2(\cpuregs[17][28] ), .Y(n4714) );
  sky130_fd_sc_hd__nand2_1 U6109 ( .A(n9484), .B(\cpuregs[12][28] ), .Y(n4713)
         );
  sky130_fd_sc_hd__a22oi_1 U6110 ( .A1(n9462), .A2(\cpuregs[2][28] ), .B1(
        n9316), .B2(\cpuregs[4][28] ), .Y(n4712) );
  sky130_fd_sc_hd__nand4_1 U6111 ( .A(n4715), .B(n4714), .C(n4713), .D(n4712), 
        .Y(n4731) );
  sky130_fd_sc_hd__a22oi_1 U6112 ( .A1(n9480), .A2(\cpuregs[20][28] ), .B1(
        n9473), .B2(\cpuregs[23][28] ), .Y(n4719) );
  sky130_fd_sc_hd__a22oi_1 U6113 ( .A1(n9490), .A2(\cpuregs[11][28] ), .B1(
        n9491), .B2(\cpuregs[10][28] ), .Y(n4718) );
  sky130_fd_sc_hd__a22oi_1 U6114 ( .A1(n9321), .A2(\cpuregs[27][28] ), .B1(
        n9471), .B2(\cpuregs[25][28] ), .Y(n4717) );
  sky130_fd_sc_hd__a22oi_1 U6115 ( .A1(n9460), .A2(\cpuregs[24][28] ), .B1(
        n9485), .B2(\cpuregs[21][28] ), .Y(n4716) );
  sky130_fd_sc_hd__nand4_1 U6116 ( .A(n4719), .B(n4718), .C(n4717), .D(n4716), 
        .Y(n4730) );
  sky130_fd_sc_hd__a22oi_1 U6117 ( .A1(n9468), .A2(\cpuregs[16][28] ), .B1(
        n9459), .B2(\cpuregs[18][28] ), .Y(n4723) );
  sky130_fd_sc_hd__a22oi_1 U6118 ( .A1(n9467), .A2(\cpuregs[26][28] ), .B1(
        n9494), .B2(\cpuregs[8][28] ), .Y(n4722) );
  sky130_fd_sc_hd__a22oi_1 U6119 ( .A1(n9483), .A2(\cpuregs[7][28] ), .B1(
        n9461), .B2(\cpuregs[5][28] ), .Y(n4721) );
  sky130_fd_sc_hd__a22oi_1 U6120 ( .A1(n9469), .A2(\cpuregs[9][28] ), .B1(
        n9457), .B2(\cpuregs[19][28] ), .Y(n4720) );
  sky130_fd_sc_hd__nand4_1 U6121 ( .A(n4723), .B(n4722), .C(n4721), .D(n4720), 
        .Y(n4729) );
  sky130_fd_sc_hd__a22oi_1 U6122 ( .A1(n9481), .A2(\cpuregs[14][28] ), .B1(
        n9470), .B2(\cpuregs[13][28] ), .Y(n4727) );
  sky130_fd_sc_hd__a22oi_1 U6123 ( .A1(n9482), .A2(\cpuregs[31][28] ), .B1(
        n9495), .B2(\cpuregs[22][28] ), .Y(n4726) );
  sky130_fd_sc_hd__a22oi_1 U6124 ( .A1(n9458), .A2(\cpuregs[30][28] ), .B1(
        n9479), .B2(\cpuregs[29][28] ), .Y(n4725) );
  sky130_fd_sc_hd__a22oi_1 U6125 ( .A1(n9492), .A2(\cpuregs[28][28] ), .B1(
        n9497), .B2(\cpuregs[15][28] ), .Y(n4724) );
  sky130_fd_sc_hd__nand4_1 U6126 ( .A(n4727), .B(n4726), .C(n4725), .D(n4724), 
        .Y(n4728) );
  sky130_fd_sc_hd__nor4_1 U6127 ( .A(n4731), .B(n4730), .C(n4729), .D(n4728), 
        .Y(n4738) );
  sky130_fd_sc_hd__nand2_1 U6128 ( .A(n4732), .B(pcpi_rs1[24]), .Y(n4733) );
  sky130_fd_sc_hd__o211ai_1 U6129 ( .A1(n8931), .A2(n9304), .B1(n4734), .C1(
        n4733), .Y(n4735) );
  sky130_fd_sc_hd__a21oi_1 U6130 ( .A1(pcpi_rs1[29]), .A2(n4736), .B1(n4735), 
        .Y(n4737) );
  sky130_fd_sc_hd__o21ai_1 U6131 ( .A1(n4738), .A2(n9302), .B1(n4737), .Y(
        n4739) );
  sky130_fd_sc_hd__a21oi_1 U6132 ( .A1(n4740), .A2(n4826), .B1(n4739), .Y(
        n4743) );
  sky130_fd_sc_hd__nand2_1 U6133 ( .A(n9280), .B(reg_pc[28]), .Y(n4741) );
  sky130_fd_sc_hd__o21a_1 U6134 ( .A1(n7191), .A2(n9340), .B1(n4741), .X(n4742) );
  sky130_fd_sc_hd__o21ai_1 U6135 ( .A1(n9452), .A2(n4743), .B1(n4742), .Y(
        n2767) );
  sky130_fd_sc_hd__a22oi_1 U6136 ( .A1(n9472), .A2(\cpuregs[4][19] ), .B1(
        n9480), .B2(\cpuregs[20][19] ), .Y(n4747) );
  sky130_fd_sc_hd__a22oi_1 U6137 ( .A1(n9491), .A2(\cpuregs[10][19] ), .B1(
        n9458), .B2(\cpuregs[30][19] ), .Y(n4746) );
  sky130_fd_sc_hd__a22oi_1 U6138 ( .A1(n9492), .A2(\cpuregs[28][19] ), .B1(
        n9473), .B2(\cpuregs[23][19] ), .Y(n4745) );
  sky130_fd_sc_hd__nand2_1 U6139 ( .A(n9467), .B(\cpuregs[26][19] ), .Y(n4744)
         );
  sky130_fd_sc_hd__nand4_1 U6140 ( .A(n4747), .B(n4746), .C(n4745), .D(n4744), 
        .Y(n4764) );
  sky130_fd_sc_hd__a22oi_1 U6141 ( .A1(n9460), .A2(\cpuregs[24][19] ), .B1(
        n9478), .B2(\cpuregs[1][19] ), .Y(n4752) );
  sky130_fd_sc_hd__a22oi_1 U6142 ( .A1(n9321), .A2(\cpuregs[27][19] ), .B1(
        n8937), .B2(\cpuregs[13][19] ), .Y(n4751) );
  sky130_fd_sc_hd__a22oi_1 U6143 ( .A1(n9469), .A2(\cpuregs[9][19] ), .B1(
        n9456), .B2(\cpuregs[17][19] ), .Y(n4750) );
  sky130_fd_sc_hd__a22oi_1 U6144 ( .A1(n9481), .A2(\cpuregs[14][19] ), .B1(
        n9495), .B2(\cpuregs[22][19] ), .Y(n4749) );
  sky130_fd_sc_hd__nand4_1 U6145 ( .A(n4752), .B(n4751), .C(n4750), .D(n4749), 
        .Y(n4763) );
  sky130_fd_sc_hd__a22oi_1 U6146 ( .A1(n9490), .A2(\cpuregs[11][19] ), .B1(
        n9482), .B2(\cpuregs[31][19] ), .Y(n4756) );
  sky130_fd_sc_hd__a22oi_1 U6147 ( .A1(n9462), .A2(\cpuregs[2][19] ), .B1(
        n9457), .B2(\cpuregs[19][19] ), .Y(n4755) );
  sky130_fd_sc_hd__a22oi_1 U6148 ( .A1(n9484), .A2(\cpuregs[12][19] ), .B1(
        n9459), .B2(\cpuregs[18][19] ), .Y(n4754) );
  sky130_fd_sc_hd__a22oi_1 U6149 ( .A1(n9496), .A2(\cpuregs[3][19] ), .B1(
        n9493), .B2(\cpuregs[6][19] ), .Y(n4753) );
  sky130_fd_sc_hd__nand4_1 U6150 ( .A(n4756), .B(n4755), .C(n4754), .D(n4753), 
        .Y(n4762) );
  sky130_fd_sc_hd__a22oi_1 U6151 ( .A1(n9494), .A2(\cpuregs[8][19] ), .B1(
        n9461), .B2(\cpuregs[5][19] ), .Y(n4760) );
  sky130_fd_sc_hd__a22oi_1 U6152 ( .A1(n9471), .A2(\cpuregs[25][19] ), .B1(
        n9479), .B2(\cpuregs[29][19] ), .Y(n4759) );
  sky130_fd_sc_hd__a22oi_1 U6153 ( .A1(n9497), .A2(\cpuregs[15][19] ), .B1(
        n9468), .B2(\cpuregs[16][19] ), .Y(n4758) );
  sky130_fd_sc_hd__a22oi_1 U6154 ( .A1(n9483), .A2(\cpuregs[7][19] ), .B1(
        n9485), .B2(\cpuregs[21][19] ), .Y(n4757) );
  sky130_fd_sc_hd__nand4_1 U6155 ( .A(n4760), .B(n4759), .C(n4758), .D(n4757), 
        .Y(n4761) );
  sky130_fd_sc_hd__nor4_1 U6156 ( .A(n4764), .B(n4763), .C(n4762), .D(n4761), 
        .Y(n4765) );
  sky130_fd_sc_hd__a22oi_1 U6157 ( .A1(n9280), .A2(reg_pc[19]), .B1(n9452), 
        .B2(pcpi_rs1[19]), .Y(n4766) );
  sky130_fd_sc_hd__nand2_1 U6158 ( .A(n4769), .B(n4768), .Y(n4773) );
  sky130_fd_sc_hd__a21oi_1 U6159 ( .A1(n6851), .A2(n4771), .B1(n4770), .Y(
        n8887) );
  sky130_fd_sc_hd__o21ai_1 U6160 ( .A1(n8883), .A2(n8887), .B1(n8884), .Y(
        n4772) );
  sky130_fd_sc_hd__xnor2_1 U6161 ( .A(n4773), .B(n4772), .Y(n4774) );
  sky130_fd_sc_hd__nand4_1 U6162 ( .A(n4238), .B(n4227), .C(n4228), .D(n4222), 
        .Y(n2776) );
  sky130_fd_sc_hd__nand4_1 U6163 ( .A(mem_rdata_q[5]), .B(mem_rdata_q[6]), .C(
        mem_rdata_q[4]), .D(n4793), .Y(n4780) );
  sky130_fd_sc_hd__nor2_1 U6164 ( .A(mem_rdata_q[14]), .B(n8081), .Y(n4792) );
  sky130_fd_sc_hd__nand4_1 U6165 ( .A(n4815), .B(mem_rdata_q[31]), .C(n4792), 
        .D(n8362), .Y(n4779) );
  sky130_fd_sc_hd__nor4_1 U6166 ( .A(mem_rdata_q[25]), .B(mem_rdata_q[26]), 
        .C(mem_rdata_q[28]), .D(mem_rdata_q[29]), .Y(n4791) );
  sky130_fd_sc_hd__nor2_1 U6167 ( .A(mem_rdata_q[12]), .B(n10122), .Y(n10101)
         );
  sky130_fd_sc_hd__nor4_1 U6168 ( .A(mem_rdata_q[16]), .B(mem_rdata_q[15]), 
        .C(mem_rdata_q[17]), .D(n10095), .Y(n4777) );
  sky130_fd_sc_hd__nor4_1 U6169 ( .A(mem_rdata_q[22]), .B(mem_rdata_q[23]), 
        .C(mem_rdata_q[18]), .D(mem_rdata_q[19]), .Y(n4776) );
  sky130_fd_sc_hd__nand4_1 U6170 ( .A(n4791), .B(n10101), .C(n4777), .D(n4776), 
        .Y(n4778) );
  sky130_fd_sc_hd__nor4_1 U6171 ( .A(mem_rdata_q[2]), .B(n4780), .C(n4779), 
        .D(n4778), .Y(n4784) );
  sky130_fd_sc_hd__nor2b_1 U6172 ( .B_N(n4784), .A(n8612), .Y(n4782) );
  sky130_fd_sc_hd__nand2_1 U6173 ( .A(n4782), .B(n4781), .Y(n5412) );
  sky130_fd_sc_hd__o2bb2ai_1 U6174 ( .B1(n8463), .B2(n5412), .A1_N(n10122), 
        .A2_N(instr_rdinstrh), .Y(n2916) );
  sky130_fd_sc_hd__nand2_1 U6175 ( .A(n4639), .B(is_beq_bne_blt_bge_bltu_bgeu), 
        .Y(n9544) );
  sky130_fd_sc_hd__nand2b_1 U6176 ( .A_N(n9544), .B(resetn), .Y(n5613) );
  sky130_fd_sc_hd__nand2_1 U6177 ( .A(n5613), .B(n9387), .Y(n10054) );
  sky130_fd_sc_hd__nor2_1 U6178 ( .A(mem_rdata_q[13]), .B(n7933), .Y(n10121)
         );
  sky130_fd_sc_hd__nand2b_1 U6179 ( .A_N(n10122), .B(n10121), .Y(n10106) );
  sky130_fd_sc_hd__nand2_1 U6180 ( .A(n4783), .B(n10096), .Y(n9006) );
  sky130_fd_sc_hd__nand3_1 U6181 ( .A(mem_rdata_q[13]), .B(n10101), .C(n10096), 
        .Y(n10098) );
  sky130_fd_sc_hd__nand2_1 U6182 ( .A(n4784), .B(n8612), .Y(n5410) );
  sky130_fd_sc_hd__nand2_1 U6183 ( .A(n10030), .B(n4786), .Y(n4787) );
  sky130_fd_sc_hd__o211ai_1 U6184 ( .A1(n4788), .A2(n5406), .B1(n9521), .C1(
        n4787), .Y(n4789) );
  sky130_fd_sc_hd__nand2_1 U6185 ( .A(n4789), .B(resetn), .Y(n10131) );
  sky130_fd_sc_hd__a22oi_1 U6186 ( .A1(n9859), .A2(n10126), .B1(n10129), .B2(
        instr_sb), .Y(n4790) );
  sky130_fd_sc_hd__nand3_1 U6187 ( .A(n4791), .B(n8463), .C(n10207), .Y(n5892)
         );
  sky130_fd_sc_hd__nor3_1 U6188 ( .A(n4792), .B(n5892), .C(n10106), .Y(n10092)
         );
  sky130_fd_sc_hd__nand2_1 U6189 ( .A(is_alu_reg_imm), .B(n10092), .Y(n10117)
         );
  sky130_fd_sc_hd__nor2_1 U6190 ( .A(mem_wordsize[1]), .B(mem_wordsize[0]), 
        .Y(n4825) );
  sky130_fd_sc_hd__clkinv_1 U6191 ( .A(n4825), .Y(n10027) );
  sky130_fd_sc_hd__nor2b_1 U6192 ( .B_N(mem_rdata[23]), .A(n10027), .Y(N195)
         );
  sky130_fd_sc_hd__nor2b_1 U6193 ( .B_N(mem_rdata[21]), .A(n10027), .Y(N193)
         );
  sky130_fd_sc_hd__nor2b_1 U6194 ( .B_N(mem_rdata[20]), .A(n10027), .Y(N192)
         );
  sky130_fd_sc_hd__nor2b_1 U6195 ( .B_N(mem_rdata[17]), .A(n10027), .Y(N189)
         );
  sky130_fd_sc_hd__nor2b_1 U6196 ( .B_N(mem_rdata[19]), .A(n10027), .Y(N191)
         );
  sky130_fd_sc_hd__nor2b_1 U6197 ( .B_N(mem_rdata[22]), .A(n10027), .Y(N194)
         );
  sky130_fd_sc_hd__nor2b_1 U6198 ( .B_N(mem_rdata[16]), .A(n10027), .Y(N188)
         );
  sky130_fd_sc_hd__nor2b_1 U6199 ( .B_N(mem_rdata[18]), .A(n10027), .Y(N190)
         );
  sky130_fd_sc_hd__nand3_1 U6200 ( .A(n7933), .B(n10095), .C(n10096), .Y(n6034) );
  sky130_fd_sc_hd__nor2_1 U6201 ( .A(n10060), .B(n10122), .Y(n4797) );
  sky130_fd_sc_hd__nand2_1 U6202 ( .A(n10044), .B(n4797), .Y(n9547) );
  sky130_fd_sc_hd__nor4_1 U6203 ( .A(mem_rdata_q[6]), .B(mem_rdata_q[5]), .C(
        mem_rdata_q[4]), .D(n4793), .Y(n4794) );
  sky130_fd_sc_hd__nand3_1 U6204 ( .A(mem_rdata_q[2]), .B(n4815), .C(n4794), 
        .Y(n4795) );
  sky130_fd_sc_hd__nand2_1 U6205 ( .A(n10122), .B(resetn), .Y(n10052) );
  sky130_fd_sc_hd__o2bb2ai_1 U6206 ( .B1(n9547), .B2(n4795), .A1_N(instr_fence), .A2_N(n10050), .Y(n3965) );
  sky130_fd_sc_hd__o2bb2ai_1 U6207 ( .B1(n10120), .B2(n9547), .A1_N(instr_addi), .A2_N(n10050), .Y(n3981) );
  sky130_fd_sc_hd__nor2_1 U6208 ( .A(mem_rdata_q[13]), .B(n10096), .Y(n10102)
         );
  sky130_fd_sc_hd__nand3_1 U6209 ( .A(resetn), .B(n10102), .C(n10101), .Y(
        n10033) );
  sky130_fd_sc_hd__o2bb2ai_1 U6210 ( .B1(n10120), .B2(n10033), .A1_N(
        instr_xori), .A2_N(n10050), .Y(n3978) );
  sky130_fd_sc_hd__nor3b_1 U6211 ( .C_N(n4797), .A(n10091), .B(n5892), .Y(
        n5896) );
  sky130_fd_sc_hd__nand2_1 U6212 ( .A(n5896), .B(n8081), .Y(n4796) );
  sky130_fd_sc_hd__nand3_1 U6213 ( .A(mem_rdata_q[13]), .B(mem_rdata_q[12]), 
        .C(n10043), .Y(n10048) );
  sky130_fd_sc_hd__o2bb2ai_1 U6214 ( .B1(n10096), .B2(n10048), .A1_N(instr_and), .A2_N(n10050), .Y(n3966) );
  sky130_fd_sc_hd__nor2_1 U6215 ( .A(mem_rdata_q[12]), .B(n4796), .Y(n10049)
         );
  sky130_fd_sc_hd__nand2_1 U6216 ( .A(mem_rdata_q[13]), .B(n10049), .Y(n10046)
         );
  sky130_fd_sc_hd__o2bb2ai_1 U6217 ( .B1(n10096), .B2(n10046), .A1_N(instr_or), 
        .A2_N(n10050), .Y(n3967) );
  sky130_fd_sc_hd__nand2_1 U6218 ( .A(mem_rdata_q[14]), .B(is_alu_reg_imm), 
        .Y(n5894) );
  sky130_fd_sc_hd__nand3_1 U6219 ( .A(mem_rdata_q[12]), .B(mem_rdata_q[13]), 
        .C(n4797), .Y(n10040) );
  sky130_fd_sc_hd__o2bb2ai_1 U6220 ( .B1(n5894), .B2(n10040), .A1_N(instr_andi), .A2_N(n10050), .Y(n3976) );
  sky130_fd_sc_hd__nand3_1 U6221 ( .A(resetn), .B(mem_rdata_q[13]), .C(n10101), 
        .Y(n10038) );
  sky130_fd_sc_hd__o2bb2ai_1 U6222 ( .B1(n5894), .B2(n10038), .A1_N(instr_ori), 
        .A2_N(n10050), .Y(n3977) );
  sky130_fd_sc_hd__nand2_1 U6223 ( .A(n10043), .B(n10121), .Y(n10051) );
  sky130_fd_sc_hd__o2bb2ai_1 U6224 ( .B1(mem_rdata_q[14]), .B2(n10051), .A1_N(
        instr_sll), .A2_N(n10050), .Y(n3973) );
  sky130_fd_sc_hd__nor2_1 U6225 ( .A(pcpi_rs1[12]), .B(pcpi_rs2[12]), .Y(n5451) );
  sky130_fd_sc_hd__nor2_1 U6226 ( .A(n8778), .B(n4822), .Y(n5452) );
  sky130_fd_sc_hd__o21ai_1 U6227 ( .A1(n5452), .A2(n8683), .B1(n8386), .Y(
        n4798) );
  sky130_fd_sc_hd__a21oi_1 U6228 ( .A1(n5452), .A2(n9382), .B1(n4798), .Y(
        n4808) );
  sky130_fd_sc_hd__a21oi_1 U6229 ( .A1(n4801), .A2(n8048), .B1(n4800), .Y(
        n4806) );
  sky130_fd_sc_hd__nand2_1 U6230 ( .A(n4804), .B(n4803), .Y(n4805) );
  sky130_fd_sc_hd__xor2_1 U6231 ( .A(n4806), .B(n4805), .X(n4807) );
  sky130_fd_sc_hd__o2bb2ai_1 U6232 ( .B1(n5451), .B2(n4808), .A1_N(
        is_lui_auipc_jal_jalr_addi_add_sub), .A2_N(n4807), .Y(alu_out[12]) );
  sky130_fd_sc_hd__nand2_1 U6233 ( .A(n4809), .B(n6188), .Y(n4810) );
  sky130_fd_sc_hd__nor2_1 U6234 ( .A(n4810), .B(n6202), .Y(n6242) );
  sky130_fd_sc_hd__nor2_1 U6235 ( .A(n6194), .B(n4811), .Y(n6229) );
  sky130_fd_sc_hd__nand2_1 U6236 ( .A(n6242), .B(n6229), .Y(n6541) );
  sky130_fd_sc_hd__nor2_1 U6237 ( .A(n7893), .B(reg_out[0]), .Y(n4812) );
  sky130_fd_sc_hd__nor2_1 U6238 ( .A(n4812), .B(n9813), .Y(n4813) );
  sky130_fd_sc_hd__o2bb2ai_1 U6239 ( .B1(n9209), .B2(n10059), .A1_N(n9209), 
        .A2_N(\cpuregs[6][0] ), .Y(n3901) );
  sky130_fd_sc_hd__a22oi_1 U6240 ( .A1(n10206), .A2(mem_rdata[2]), .B1(n4817), 
        .B2(mem_rdata_q[2]), .Y(n10094) );
  sky130_fd_sc_hd__a22oi_1 U6241 ( .A1(n10206), .A2(mem_rdata[4]), .B1(n4817), 
        .B2(mem_rdata_q[4]), .Y(n10093) );
  sky130_fd_sc_hd__nand2_1 U6242 ( .A(n5414), .B(n10090), .Y(n5419) );
  sky130_fd_sc_hd__o22ai_1 U6243 ( .A1(n10206), .A2(mem_rdata_q[5]), .B1(n4817), .B2(mem_rdata[5]), .Y(n5418) );
  sky130_fd_sc_hd__a32oi_1 U6244 ( .A1(mem_rdata[1]), .A2(n10206), .A3(
        mem_rdata[0]), .B1(n4815), .B2(n4817), .Y(n5408) );
  sky130_fd_sc_hd__o22ai_1 U6245 ( .A1(n10206), .A2(mem_rdata_q[6]), .B1(n4817), .B2(mem_rdata[6]), .Y(n5407) );
  sky130_fd_sc_hd__nand2_2 U6246 ( .A(n4816), .B(mem_do_rinst), .Y(n10086) );
  sky130_fd_sc_hd__nand3_1 U6247 ( .A(n5407), .B(n10114), .C(n5429), .Y(n4818)
         );
  sky130_fd_sc_hd__nor2_1 U6248 ( .A(n5408), .B(n4818), .Y(n5417) );
  sky130_fd_sc_hd__nand2_1 U6249 ( .A(n5418), .B(n5417), .Y(n10113) );
  sky130_fd_sc_hd__o2bb2ai_1 U6250 ( .B1(n5419), .B2(n10113), .A1_N(n10086), 
        .A2_N(instr_auipc), .Y(n2920) );
  sky130_fd_sc_hd__nand2_1 U6251 ( .A(mem_wordsize[1]), .B(n9906), .Y(n9887)
         );
  sky130_fd_sc_hd__o22ai_1 U6252 ( .A1(mem_wordsize[1]), .A2(n5450), .B1(n9903), .B2(n9887), .Y(n4142) );
  sky130_fd_sc_hd__a22o_1 U6253 ( .A1(pcpi_rs2[31]), .A2(n4825), .B1(n10027), 
        .B2(n4142), .X(n4126) );
  sky130_fd_sc_hd__o22ai_1 U6254 ( .A1(mem_wordsize[1]), .A2(n4819), .B1(n9899), .B2(n9887), .Y(n4144) );
  sky130_fd_sc_hd__a22o_1 U6255 ( .A1(pcpi_rs2[29]), .A2(n4825), .B1(n10027), 
        .B2(n4144), .X(n4128) );
  sky130_fd_sc_hd__o22ai_1 U6256 ( .A1(mem_wordsize[1]), .A2(n4820), .B1(n9887), .B2(n9894), .Y(n4146) );
  sky130_fd_sc_hd__a22o_1 U6257 ( .A1(pcpi_rs2[27]), .A2(n4825), .B1(n10027), 
        .B2(n4146), .X(n4130) );
  sky130_fd_sc_hd__o22ai_1 U6258 ( .A1(mem_wordsize[1]), .A2(n4821), .B1(n9900), .B2(n9887), .Y(n4143) );
  sky130_fd_sc_hd__a22o_1 U6259 ( .A1(pcpi_rs2[30]), .A2(n4825), .B1(n10027), 
        .B2(n4143), .X(n4127) );
  sky130_fd_sc_hd__o22ai_1 U6260 ( .A1(mem_wordsize[1]), .A2(n4822), .B1(n9897), .B2(n9887), .Y(n4145) );
  sky130_fd_sc_hd__a22o_1 U6261 ( .A1(pcpi_rs2[28]), .A2(n4825), .B1(n10027), 
        .B2(n4145), .X(n4129) );
  sky130_fd_sc_hd__o22ai_1 U6262 ( .A1(mem_wordsize[1]), .A2(n4823), .B1(n9892), .B2(n9887), .Y(n4147) );
  sky130_fd_sc_hd__a22o_1 U6263 ( .A1(pcpi_rs2[26]), .A2(n4825), .B1(n10027), 
        .B2(n4147), .X(n4131) );
  sky130_fd_sc_hd__o22ai_1 U6264 ( .A1(mem_wordsize[1]), .A2(n5433), .B1(n9890), .B2(n9887), .Y(n4148) );
  sky130_fd_sc_hd__a22o_1 U6265 ( .A1(pcpi_rs2[25]), .A2(n4825), .B1(n10027), 
        .B2(n4148), .X(n4132) );
  sky130_fd_sc_hd__o22ai_1 U6266 ( .A1(mem_wordsize[1]), .A2(n4824), .B1(n9888), .B2(n9887), .Y(n4149) );
  sky130_fd_sc_hd__a22o_1 U6267 ( .A1(pcpi_rs2[24]), .A2(n4825), .B1(n10027), 
        .B2(n4149), .X(n4133) );
  sky130_fd_sc_hd__nor3_1 U6268 ( .A(mem_do_prefetch), .B(n9443), .C(n4827), 
        .Y(N2078) );
  sky130_fd_sc_hd__a21oi_1 U6269 ( .A1(n9906), .A2(pcpi_rs1[1]), .B1(
        pcpi_rs1[0]), .Y(n4829) );
  sky130_fd_sc_hd__nand2_1 U6270 ( .A(reg_pc[1]), .B(mem_do_rinst), .Y(n4828)
         );
  sky130_fd_sc_hd__o31a_1 U6271 ( .A1(mem_wordsize[1]), .A2(n4830), .A3(n4829), 
        .B1(n4828), .X(n9447) );
  sky130_fd_sc_hd__nor2_1 U6272 ( .A(n5988), .B(n5616), .Y(n9522) );
  sky130_fd_sc_hd__nor2_1 U6273 ( .A(n4831), .B(n9521), .Y(n5891) );
  sky130_fd_sc_hd__nor4_1 U6274 ( .A(n9524), .B(n10060), .C(n9442), .D(n5891), 
        .Y(n4833) );
  sky130_fd_sc_hd__or4_1 U6275 ( .A(N1571), .B(N1570), .C(n4832), .D(n9437), 
        .X(n9529) );
  sky130_fd_sc_hd__nand2_1 U6276 ( .A(n4639), .B(n10034), .Y(n9012) );
  sky130_fd_sc_hd__and3_1 U6277 ( .A(n4833), .B(n9529), .C(n9012), .X(n4834)
         );
  sky130_fd_sc_hd__o211ai_1 U6278 ( .A1(n9531), .A2(n9010), .B1(n4834), .C1(
        n9545), .Y(n9519) );
  sky130_fd_sc_hd__nor3_1 U6279 ( .A(n9532), .B(n4837), .C(n4836), .Y(n4839)
         );
  sky130_fd_sc_hd__nor2_1 U6280 ( .A(n9447), .B(n10060), .Y(n4838) );
  sky130_fd_sc_hd__a211o_1 U6281 ( .A1(n4840), .A2(cpu_state[7]), .B1(n4839), 
        .C1(n4838), .X(n2833) );
  sky130_fd_sc_hd__and2_2 U6282 ( .A(n5988), .B(decoded_imm_j[31]), .X(n5381)
         );
  sky130_fd_sc_hd__inv_2 U6283 ( .A(n4841), .Y(n4845) );
  sky130_fd_sc_hd__nor2_4 U6284 ( .A(latched_stalu), .B(n4841), .Y(n5376) );
  sky130_fd_sc_hd__inv_2 U6285 ( .A(n5376), .Y(n4865) );
  sky130_fd_sc_hd__nor2_4 U6286 ( .A(n5967), .B(n4841), .Y(n4926) );
  sky130_fd_sc_hd__inv_2 U6287 ( .A(n4926), .Y(n4871) );
  sky130_fd_sc_hd__inv_2 U6288 ( .A(n4871), .Y(n4930) );
  sky130_fd_sc_hd__buf_2 U6289 ( .A(n4930), .X(n4861) );
  sky130_fd_sc_hd__a22oi_1 U6290 ( .A1(reg_next_pc[26]), .A2(n4841), .B1(n4861), .B2(alu_out_q[26]), .Y(n4842) );
  sky130_fd_sc_hd__o21ai_1 U6291 ( .A1(n4843), .A2(n4865), .B1(n4842), .Y(
        n4963) );
  sky130_fd_sc_hd__nor2_1 U6292 ( .A(n5381), .B(n4963), .Y(n5245) );
  sky130_fd_sc_hd__nand2_1 U6293 ( .A(n4963), .B(n5381), .Y(n5246) );
  sky130_fd_sc_hd__nand2_1 U6294 ( .A(n4844), .B(n5246), .Y(n4962) );
  sky130_fd_sc_hd__inv_2 U6295 ( .A(n4926), .Y(n5260) );
  sky130_fd_sc_hd__o22ai_1 U6296 ( .A1(n4845), .A2(reg_next_pc[24]), .B1(
        alu_out_q[24]), .B2(n5260), .Y(n4846) );
  sky130_fd_sc_hd__a21oi_1 U6297 ( .A1(n4214), .A2(n4847), .B1(n4846), .Y(
        n7519) );
  sky130_fd_sc_hd__nor2_1 U6298 ( .A(n5381), .B(n7519), .Y(n5304) );
  sky130_fd_sc_hd__o22ai_1 U6299 ( .A1(n4845), .A2(reg_next_pc[23]), .B1(
        alu_out_q[23]), .B2(n5260), .Y(n4848) );
  sky130_fd_sc_hd__a21oi_1 U6300 ( .A1(n4214), .A2(n4849), .B1(n4848), .Y(
        n7129) );
  sky130_fd_sc_hd__nor2_1 U6301 ( .A(n5381), .B(n7129), .Y(n5309) );
  sky130_fd_sc_hd__nor2_1 U6302 ( .A(n5304), .B(n5309), .Y(n4856) );
  sky130_fd_sc_hd__inv_2 U6303 ( .A(n5376), .Y(n4917) );
  sky130_fd_sc_hd__inv_2 U6304 ( .A(n4917), .Y(n5263) );
  sky130_fd_sc_hd__nand2_1 U6305 ( .A(n5263), .B(reg_out[22]), .Y(n4852) );
  sky130_fd_sc_hd__nand2_1 U6306 ( .A(n4861), .B(alu_out_q[22]), .Y(n4851) );
  sky130_fd_sc_hd__nand2_1 U6307 ( .A(n4841), .B(reg_next_pc[22]), .Y(n4850)
         );
  sky130_fd_sc_hd__nor2_1 U6308 ( .A(n5381), .B(n7698), .Y(n5353) );
  sky130_fd_sc_hd__nand2_1 U6309 ( .A(n5376), .B(reg_out[21]), .Y(n4855) );
  sky130_fd_sc_hd__nand2_1 U6310 ( .A(n4861), .B(alu_out_q[21]), .Y(n4854) );
  sky130_fd_sc_hd__nand2_1 U6311 ( .A(n4841), .B(reg_next_pc[21]), .Y(n4853)
         );
  sky130_fd_sc_hd__nand3_1 U6312 ( .A(n4855), .B(n4854), .C(n4853), .Y(n6669)
         );
  sky130_fd_sc_hd__nor2_1 U6313 ( .A(n5381), .B(n6669), .Y(n5233) );
  sky130_fd_sc_hd__nor2_1 U6314 ( .A(n5353), .B(n5233), .Y(n5307) );
  sky130_fd_sc_hd__nand2_1 U6315 ( .A(n4856), .B(n5307), .Y(n4957) );
  sky130_fd_sc_hd__o22ai_1 U6316 ( .A1(n4845), .A2(reg_next_pc[20]), .B1(
        alu_out_q[20]), .B2(n5260), .Y(n4857) );
  sky130_fd_sc_hd__a21oi_1 U6317 ( .A1(n5263), .A2(n4858), .B1(n4857), .Y(
        n7402) );
  sky130_fd_sc_hd__nor2_1 U6318 ( .A(n5381), .B(n7402), .Y(n5281) );
  sky130_fd_sc_hd__o22ai_1 U6319 ( .A1(n4845), .A2(reg_next_pc[19]), .B1(
        alu_out_q[19]), .B2(n5260), .Y(n4859) );
  sky130_fd_sc_hd__a21oi_1 U6320 ( .A1(n4214), .A2(n4860), .B1(n4859), .Y(
        n7042) );
  sky130_fd_sc_hd__nor2_1 U6321 ( .A(n4952), .B(n7042), .Y(n5274) );
  sky130_fd_sc_hd__nor2_1 U6322 ( .A(n5281), .B(n5274), .Y(n4954) );
  sky130_fd_sc_hd__nand2_1 U6323 ( .A(n5263), .B(reg_out[18]), .Y(n4864) );
  sky130_fd_sc_hd__nand2_1 U6324 ( .A(n4861), .B(alu_out_q[18]), .Y(n4863) );
  sky130_fd_sc_hd__nand2_1 U6325 ( .A(n4841), .B(reg_next_pc[18]), .Y(n4862)
         );
  sky130_fd_sc_hd__nor2_1 U6326 ( .A(n4951), .B(n7783), .Y(n5346) );
  sky130_fd_sc_hd__nand2_1 U6327 ( .A(n4214), .B(reg_out[17]), .Y(n4868) );
  sky130_fd_sc_hd__nand2_1 U6328 ( .A(n5377), .B(alu_out_q[17]), .Y(n4867) );
  sky130_fd_sc_hd__nand2_1 U6329 ( .A(n4841), .B(reg_next_pc[17]), .Y(n4866)
         );
  sky130_fd_sc_hd__nand3_1 U6330 ( .A(n4868), .B(n4867), .C(n4866), .Y(n6577)
         );
  sky130_fd_sc_hd__nor2_1 U6331 ( .A(n4950), .B(n6577), .Y(n6492) );
  sky130_fd_sc_hd__nor2_1 U6332 ( .A(n5346), .B(n6492), .Y(n5284) );
  sky130_fd_sc_hd__nand2_1 U6333 ( .A(n4954), .B(n5284), .Y(n5296) );
  sky130_fd_sc_hd__o22ai_1 U6334 ( .A1(n4845), .A2(reg_next_pc[25]), .B1(
        alu_out_q[25]), .B2(n5260), .Y(n4869) );
  sky130_fd_sc_hd__a21oi_1 U6335 ( .A1(n5263), .A2(n4870), .B1(n4869), .Y(
        n6755) );
  sky130_fd_sc_hd__nor2_1 U6336 ( .A(n5381), .B(n6755), .Y(n5244) );
  sky130_fd_sc_hd__nand2_1 U6337 ( .A(n4216), .B(n5322), .Y(n4960) );
  sky130_fd_sc_hd__inv_2 U6338 ( .A(n4917), .Y(n4923) );
  sky130_fd_sc_hd__nand2_1 U6339 ( .A(n4923), .B(reg_out[6]), .Y(n4874) );
  sky130_fd_sc_hd__inv_2 U6340 ( .A(n4871), .Y(n5377) );
  sky130_fd_sc_hd__nand2_1 U6341 ( .A(n5377), .B(alu_out_q[6]), .Y(n4873) );
  sky130_fd_sc_hd__nand2_1 U6342 ( .A(n4841), .B(reg_next_pc[6]), .Y(n4872) );
  sky130_fd_sc_hd__nand3_1 U6343 ( .A(n4874), .B(n4873), .C(n4872), .Y(n8202)
         );
  sky130_fd_sc_hd__nor2_1 U6344 ( .A(n4901), .B(n8202), .Y(n8205) );
  sky130_fd_sc_hd__nand2_1 U6345 ( .A(n4214), .B(reg_out[5]), .Y(n4877) );
  sky130_fd_sc_hd__nand2_1 U6346 ( .A(n5377), .B(alu_out_q[5]), .Y(n4876) );
  sky130_fd_sc_hd__nand2_1 U6347 ( .A(n4841), .B(reg_next_pc[5]), .Y(n4875) );
  sky130_fd_sc_hd__nand3_1 U6348 ( .A(n4877), .B(n4876), .C(n4875), .Y(n8297)
         );
  sky130_fd_sc_hd__nor2_1 U6349 ( .A(n4900), .B(n8297), .Y(n8203) );
  sky130_fd_sc_hd__nor2_1 U6350 ( .A(n8205), .B(n8203), .Y(n9033) );
  sky130_fd_sc_hd__nand2_1 U6351 ( .A(n5376), .B(reg_out[8]), .Y(n4880) );
  sky130_fd_sc_hd__nand2_1 U6352 ( .A(n9911), .B(reg_next_pc[8]), .Y(n4879) );
  sky130_fd_sc_hd__nand2_1 U6353 ( .A(n4930), .B(alu_out_q[8]), .Y(n4878) );
  sky130_fd_sc_hd__nand3_1 U6354 ( .A(n4880), .B(n4879), .C(n4878), .Y(n8185)
         );
  sky130_fd_sc_hd__nor2_1 U6355 ( .A(n4903), .B(n8185), .Y(n8178) );
  sky130_fd_sc_hd__nand2_1 U6356 ( .A(n4214), .B(reg_out[7]), .Y(n4883) );
  sky130_fd_sc_hd__nand2_1 U6357 ( .A(n5377), .B(alu_out_q[7]), .Y(n4882) );
  sky130_fd_sc_hd__nand2_1 U6358 ( .A(n4841), .B(reg_next_pc[7]), .Y(n4881) );
  sky130_fd_sc_hd__nand3_1 U6359 ( .A(n4883), .B(n4882), .C(n4881), .Y(n9052)
         );
  sky130_fd_sc_hd__nor2_1 U6360 ( .A(n4902), .B(n9052), .Y(n8172) );
  sky130_fd_sc_hd__nor2_1 U6361 ( .A(n8178), .B(n8172), .Y(n4905) );
  sky130_fd_sc_hd__nand2_1 U6362 ( .A(n9033), .B(n4905), .Y(n4907) );
  sky130_fd_sc_hd__nand2_1 U6363 ( .A(n4214), .B(reg_out[4]), .Y(n4886) );
  sky130_fd_sc_hd__nand2_1 U6364 ( .A(n5377), .B(alu_out_q[4]), .Y(n4885) );
  sky130_fd_sc_hd__nand2_1 U6365 ( .A(n4841), .B(reg_next_pc[4]), .Y(n4884) );
  sky130_fd_sc_hd__nand3_1 U6366 ( .A(n4886), .B(n4885), .C(n4884), .Y(n8400)
         );
  sky130_fd_sc_hd__nor2_1 U6367 ( .A(n4897), .B(n8400), .Y(n8313) );
  sky130_fd_sc_hd__nand2_1 U6368 ( .A(n4214), .B(reg_out[3]), .Y(n4889) );
  sky130_fd_sc_hd__nand2_1 U6369 ( .A(n5377), .B(alu_out_q[3]), .Y(n4888) );
  sky130_fd_sc_hd__nand2_1 U6370 ( .A(n4841), .B(reg_next_pc[3]), .Y(n4887) );
  sky130_fd_sc_hd__nand3_1 U6371 ( .A(n4889), .B(n4888), .C(n4887), .Y(n8694)
         );
  sky130_fd_sc_hd__nor2_1 U6372 ( .A(n4896), .B(n8694), .Y(n8316) );
  sky130_fd_sc_hd__nor2_1 U6373 ( .A(n8313), .B(n8316), .Y(n4899) );
  sky130_fd_sc_hd__a22oi_1 U6374 ( .A1(reg_next_pc[1]), .A2(n9911), .B1(n4930), 
        .B2(alu_out_q[1]), .Y(n4890) );
  sky130_fd_sc_hd__o21ai_1 U6375 ( .A1(n4891), .A2(n4917), .B1(n4890), .Y(
        n9174) );
  sky130_fd_sc_hd__nand2_1 U6376 ( .A(n5993), .B(n5988), .Y(n4895) );
  sky130_fd_sc_hd__nand2_1 U6377 ( .A(n4923), .B(reg_out[2]), .Y(n4894) );
  sky130_fd_sc_hd__nand2_1 U6378 ( .A(n5377), .B(alu_out_q[2]), .Y(n4893) );
  sky130_fd_sc_hd__nand2_1 U6379 ( .A(n4841), .B(reg_next_pc[2]), .Y(n4892) );
  sky130_fd_sc_hd__nand3_1 U6380 ( .A(n4894), .B(n4893), .C(n4892), .Y(n9363)
         );
  sky130_fd_sc_hd__nor2_1 U6381 ( .A(n4895), .B(n9363), .Y(n9364) );
  sky130_fd_sc_hd__nand2_1 U6382 ( .A(n9363), .B(n4895), .Y(n9365) );
  sky130_fd_sc_hd__o21ai_1 U6383 ( .A1(n9367), .A2(n9364), .B1(n9365), .Y(
        n8317) );
  sky130_fd_sc_hd__nand2_1 U6384 ( .A(n8694), .B(n4896), .Y(n8688) );
  sky130_fd_sc_hd__nand2_1 U6385 ( .A(n8400), .B(n4897), .Y(n8314) );
  sky130_fd_sc_hd__o21ai_1 U6386 ( .A1(n8688), .A2(n8313), .B1(n8314), .Y(
        n4898) );
  sky130_fd_sc_hd__a21oi_2 U6387 ( .A1(n4899), .A2(n8317), .B1(n4898), .Y(
        n8171) );
  sky130_fd_sc_hd__nand2_1 U6388 ( .A(n8297), .B(n4900), .Y(n8204) );
  sky130_fd_sc_hd__nand2_1 U6389 ( .A(n8202), .B(n4901), .Y(n8206) );
  sky130_fd_sc_hd__o21ai_1 U6390 ( .A1(n8204), .A2(n8205), .B1(n8206), .Y(
        n8174) );
  sky130_fd_sc_hd__nand2_1 U6391 ( .A(n9052), .B(n4902), .Y(n9035) );
  sky130_fd_sc_hd__nand2_1 U6392 ( .A(n8185), .B(n4903), .Y(n8179) );
  sky130_fd_sc_hd__o21ai_1 U6393 ( .A1(n8178), .A2(n9035), .B1(n8179), .Y(
        n4904) );
  sky130_fd_sc_hd__a21oi_1 U6394 ( .A1(n8174), .A2(n4905), .B1(n4904), .Y(
        n4906) );
  sky130_fd_sc_hd__o21ai_2 U6395 ( .A1(n4907), .A2(n8171), .B1(n4906), .Y(
        n6294) );
  sky130_fd_sc_hd__nand2_1 U6396 ( .A(n4923), .B(reg_out[12]), .Y(n4910) );
  sky130_fd_sc_hd__nand2_1 U6397 ( .A(n5377), .B(alu_out_q[12]), .Y(n4909) );
  sky130_fd_sc_hd__nand2_1 U6398 ( .A(n4841), .B(reg_next_pc[12]), .Y(n4908)
         );
  sky130_fd_sc_hd__nand3_1 U6399 ( .A(n4910), .B(n4909), .C(n4908), .Y(n7881)
         );
  sky130_fd_sc_hd__nor2_1 U6400 ( .A(n4937), .B(n7881), .Y(n7882) );
  sky130_fd_sc_hd__nand2_1 U6401 ( .A(n5263), .B(reg_out[11]), .Y(n4913) );
  sky130_fd_sc_hd__nand2_1 U6402 ( .A(n5377), .B(alu_out_q[11]), .Y(n4912) );
  sky130_fd_sc_hd__nand2_1 U6403 ( .A(n4841), .B(reg_next_pc[11]), .Y(n4911)
         );
  sky130_fd_sc_hd__nand3_1 U6404 ( .A(n4913), .B(n4912), .C(n4911), .Y(n8057)
         );
  sky130_fd_sc_hd__nor2_1 U6405 ( .A(n4936), .B(n8057), .Y(n7885) );
  sky130_fd_sc_hd__nor2_1 U6406 ( .A(n7882), .B(n7885), .Y(n4939) );
  sky130_fd_sc_hd__nand2_1 U6407 ( .A(n5376), .B(reg_out[9]), .Y(n4916) );
  sky130_fd_sc_hd__nand2_1 U6408 ( .A(n4841), .B(reg_next_pc[9]), .Y(n4915) );
  sky130_fd_sc_hd__nand2_1 U6409 ( .A(n4926), .B(alu_out_q[9]), .Y(n4914) );
  sky130_fd_sc_hd__nand3_1 U6410 ( .A(n4916), .B(n4915), .C(n4914), .Y(n6299)
         );
  sky130_fd_sc_hd__nor2_1 U6411 ( .A(n4934), .B(n6299), .Y(n8074) );
  sky130_fd_sc_hd__nand2_1 U6412 ( .A(n4930), .B(alu_out_q[10]), .Y(n4919) );
  sky130_fd_sc_hd__nand2_1 U6413 ( .A(n9911), .B(reg_next_pc[10]), .Y(n4918)
         );
  sky130_fd_sc_hd__nor2_1 U6414 ( .A(n4935), .B(n8119), .Y(n8069) );
  sky130_fd_sc_hd__nor2_1 U6415 ( .A(n8074), .B(n8069), .Y(n7977) );
  sky130_fd_sc_hd__nand2_1 U6416 ( .A(n4939), .B(n7977), .Y(n6952) );
  sky130_fd_sc_hd__o22ai_1 U6417 ( .A1(n4845), .A2(reg_next_pc[14]), .B1(
        alu_out_q[14]), .B2(n5260), .Y(n4921) );
  sky130_fd_sc_hd__nor2_1 U6418 ( .A(n4941), .B(n7869), .Y(n7796) );
  sky130_fd_sc_hd__o22ai_1 U6419 ( .A1(n4845), .A2(reg_next_pc[13]), .B1(
        alu_out_q[13]), .B2(n5260), .Y(n4924) );
  sky130_fd_sc_hd__a21oi_1 U6420 ( .A1(n5263), .A2(n4925), .B1(n4924), .Y(
        n6440) );
  sky130_fd_sc_hd__nor2_1 U6421 ( .A(n4940), .B(n6440), .Y(n6352) );
  sky130_fd_sc_hd__nor2_1 U6422 ( .A(n7796), .B(n6352), .Y(n6953) );
  sky130_fd_sc_hd__nand2_1 U6423 ( .A(n5376), .B(reg_out[16]), .Y(n4929) );
  sky130_fd_sc_hd__nand2_1 U6424 ( .A(n4841), .B(reg_next_pc[16]), .Y(n4928)
         );
  sky130_fd_sc_hd__nand2_1 U6425 ( .A(n4926), .B(alu_out_q[16]), .Y(n4927) );
  sky130_fd_sc_hd__nand3_1 U6426 ( .A(n4929), .B(n4928), .C(n4927), .Y(n7319)
         );
  sky130_fd_sc_hd__nor2_1 U6427 ( .A(n7303), .B(n7319), .Y(n4943) );
  sky130_fd_sc_hd__nand2_1 U6428 ( .A(n4214), .B(reg_out[15]), .Y(n4933) );
  sky130_fd_sc_hd__nand2_1 U6429 ( .A(n4930), .B(alu_out_q[15]), .Y(n4932) );
  sky130_fd_sc_hd__nand2_1 U6430 ( .A(n4841), .B(reg_next_pc[15]), .Y(n4931)
         );
  sky130_fd_sc_hd__nand3_1 U6431 ( .A(n4933), .B(n4932), .C(n4931), .Y(n6961)
         );
  sky130_fd_sc_hd__nor2_1 U6432 ( .A(n4942), .B(n6961), .Y(n7310) );
  sky130_fd_sc_hd__nor2_1 U6433 ( .A(n4943), .B(n7310), .Y(n4945) );
  sky130_fd_sc_hd__nand2_1 U6434 ( .A(n6953), .B(n4945), .Y(n4947) );
  sky130_fd_sc_hd__nor2_1 U6435 ( .A(n6952), .B(n4947), .Y(n4949) );
  sky130_fd_sc_hd__nand2_1 U6436 ( .A(n6299), .B(n4934), .Y(n8072) );
  sky130_fd_sc_hd__nand2_1 U6437 ( .A(n8119), .B(n4935), .Y(n8070) );
  sky130_fd_sc_hd__nand2_1 U6438 ( .A(n8057), .B(n4936), .Y(n7975) );
  sky130_fd_sc_hd__nand2_1 U6439 ( .A(n7881), .B(n4937), .Y(n7883) );
  sky130_fd_sc_hd__o21ai_1 U6440 ( .A1(n7975), .A2(n7882), .B1(n7883), .Y(
        n4938) );
  sky130_fd_sc_hd__a21oi_1 U6441 ( .A1(n4939), .A2(n7978), .B1(n4938), .Y(
        n6954) );
  sky130_fd_sc_hd__nand2_1 U6442 ( .A(n6440), .B(n4940), .Y(n7800) );
  sky130_fd_sc_hd__nand2_1 U6443 ( .A(n7869), .B(n4941), .Y(n7797) );
  sky130_fd_sc_hd__o21ai_1 U6444 ( .A1(n7800), .A2(n7796), .B1(n7797), .Y(
        n7307) );
  sky130_fd_sc_hd__nand2_1 U6445 ( .A(n6961), .B(n4942), .Y(n7308) );
  sky130_fd_sc_hd__nand2_1 U6446 ( .A(n7319), .B(n7303), .Y(n7304) );
  sky130_fd_sc_hd__o21ai_1 U6447 ( .A1(n4943), .A2(n7308), .B1(n7304), .Y(
        n4944) );
  sky130_fd_sc_hd__a21oi_1 U6448 ( .A1(n7307), .A2(n4945), .B1(n4944), .Y(
        n4946) );
  sky130_fd_sc_hd__o21ai_1 U6449 ( .A1(n4947), .A2(n6954), .B1(n4946), .Y(
        n4948) );
  sky130_fd_sc_hd__nand2_1 U6450 ( .A(n6577), .B(n4950), .Y(n6493) );
  sky130_fd_sc_hd__nand2_1 U6451 ( .A(n7783), .B(n4951), .Y(n5347) );
  sky130_fd_sc_hd__o21ai_1 U6452 ( .A1(n6493), .A2(n5346), .B1(n5347), .Y(
        n5288) );
  sky130_fd_sc_hd__nand2_1 U6453 ( .A(n7042), .B(n4952), .Y(n5285) );
  sky130_fd_sc_hd__nand2_1 U6454 ( .A(n7402), .B(n5381), .Y(n5282) );
  sky130_fd_sc_hd__o21ai_1 U6455 ( .A1(n5285), .A2(n5281), .B1(n5282), .Y(
        n4953) );
  sky130_fd_sc_hd__nand2_1 U6456 ( .A(n7698), .B(n5381), .Y(n5354) );
  sky130_fd_sc_hd__nand2_1 U6457 ( .A(n6669), .B(n5381), .Y(n5357) );
  sky130_fd_sc_hd__nand2_1 U6458 ( .A(n5354), .B(n5357), .Y(n5310) );
  sky130_fd_sc_hd__nand2_1 U6459 ( .A(n7519), .B(n5381), .Y(n5305) );
  sky130_fd_sc_hd__nand2_1 U6460 ( .A(n7129), .B(n5381), .Y(n5312) );
  sky130_fd_sc_hd__nand2_1 U6461 ( .A(n5305), .B(n5312), .Y(n4955) );
  sky130_fd_sc_hd__nor2_1 U6462 ( .A(n5310), .B(n4955), .Y(n4956) );
  sky130_fd_sc_hd__o21ai_2 U6463 ( .A1(n4957), .A2(n5297), .B1(n4956), .Y(
        n5394) );
  sky130_fd_sc_hd__nand2_1 U6464 ( .A(n6755), .B(n5381), .Y(n5321) );
  sky130_fd_sc_hd__a21oi_1 U6465 ( .A1(n5394), .A2(n5322), .B1(n4958), .Y(
        n4959) );
  sky130_fd_sc_hd__o21ai_1 U6466 ( .A1(n4960), .A2(n4217), .B1(n4959), .Y(
        n4961) );
  sky130_fd_sc_hd__xnor2_1 U6467 ( .A(n4962), .B(n4961), .Y(n4965) );
  sky130_fd_sc_hd__nand2_1 U6468 ( .A(n4963), .B(n10055), .Y(n7616) );
  sky130_fd_sc_hd__o22ai_1 U6469 ( .A1(n9940), .A2(n10029), .B1(
        decoder_trigger), .B2(n7616), .Y(n4964) );
  sky130_fd_sc_hd__nand2_1 U6470 ( .A(count_cycle[26]), .B(count_cycle[27]), 
        .Y(n4967) );
  sky130_fd_sc_hd__nand2_1 U6471 ( .A(count_cycle[24]), .B(count_cycle[25]), 
        .Y(n5062) );
  sky130_fd_sc_hd__nor2_1 U6472 ( .A(n4967), .B(n5062), .Y(n5011) );
  sky130_fd_sc_hd__nand2_1 U6473 ( .A(count_cycle[30]), .B(count_cycle[31]), 
        .Y(n4968) );
  sky130_fd_sc_hd__nand2_1 U6474 ( .A(count_cycle[28]), .B(count_cycle[29]), 
        .Y(n5015) );
  sky130_fd_sc_hd__nor2_1 U6475 ( .A(n4968), .B(n5015), .Y(n4969) );
  sky130_fd_sc_hd__nand2_1 U6476 ( .A(n5011), .B(n4969), .Y(n4973) );
  sky130_fd_sc_hd__nand2_1 U6477 ( .A(count_cycle[18]), .B(count_cycle[19]), 
        .Y(n4970) );
  sky130_fd_sc_hd__nand2_1 U6478 ( .A(count_cycle[16]), .B(count_cycle[17]), 
        .Y(n5137) );
  sky130_fd_sc_hd__nor2_1 U6479 ( .A(n4970), .B(n5137), .Y(n5072) );
  sky130_fd_sc_hd__nand2_1 U6480 ( .A(count_cycle[22]), .B(count_cycle[23]), 
        .Y(n4971) );
  sky130_fd_sc_hd__nand2_1 U6481 ( .A(count_cycle[20]), .B(count_cycle[21]), 
        .Y(n5074) );
  sky130_fd_sc_hd__nor2_1 U6482 ( .A(n4971), .B(n5074), .Y(n4972) );
  sky130_fd_sc_hd__nand2_1 U6483 ( .A(n5072), .B(n4972), .Y(n5013) );
  sky130_fd_sc_hd__nor2_1 U6484 ( .A(n4973), .B(n5013), .Y(n4981) );
  sky130_fd_sc_hd__nand2_1 U6485 ( .A(count_cycle[6]), .B(count_cycle[7]), .Y(
        n4974) );
  sky130_fd_sc_hd__nand2_1 U6486 ( .A(count_cycle[4]), .B(count_cycle[5]), .Y(
        n5198) );
  sky130_fd_sc_hd__nor2_1 U6487 ( .A(n4974), .B(n5198), .Y(n4976) );
  sky130_fd_sc_hd__nand2_1 U6488 ( .A(count_cycle[1]), .B(count_cycle[0]), .Y(
        n5223) );
  sky130_fd_sc_hd__nand2_1 U6489 ( .A(count_cycle[2]), .B(count_cycle[3]), .Y(
        n4975) );
  sky130_fd_sc_hd__nor2_1 U6490 ( .A(n5223), .B(n4975), .Y(n5197) );
  sky130_fd_sc_hd__nand2_1 U6491 ( .A(n4976), .B(n5197), .Y(n5164) );
  sky130_fd_sc_hd__nand2_1 U6492 ( .A(count_cycle[10]), .B(count_cycle[11]), 
        .Y(n4977) );
  sky130_fd_sc_hd__nand2_1 U6493 ( .A(count_cycle[8]), .B(count_cycle[9]), .Y(
        n5185) );
  sky130_fd_sc_hd__nor2_1 U6494 ( .A(n4977), .B(n5185), .Y(n5165) );
  sky130_fd_sc_hd__nand2_1 U6495 ( .A(count_cycle[14]), .B(count_cycle[15]), 
        .Y(n4978) );
  sky130_fd_sc_hd__nand2_1 U6496 ( .A(count_cycle[12]), .B(count_cycle[13]), 
        .Y(n5166) );
  sky130_fd_sc_hd__nor2_1 U6497 ( .A(n4978), .B(n5166), .Y(n4979) );
  sky130_fd_sc_hd__nand2_1 U6498 ( .A(n5165), .B(n4979), .Y(n4980) );
  sky130_fd_sc_hd__nor2_1 U6499 ( .A(n5164), .B(n4980), .Y(n5012) );
  sky130_fd_sc_hd__nand2_1 U6500 ( .A(n4981), .B(n5012), .Y(n4999) );
  sky130_fd_sc_hd__nand2_1 U6501 ( .A(count_cycle[42]), .B(count_cycle[43]), 
        .Y(n4982) );
  sky130_fd_sc_hd__nand2_1 U6502 ( .A(count_cycle[40]), .B(count_cycle[41]), 
        .Y(n5055) );
  sky130_fd_sc_hd__nor2_1 U6503 ( .A(n4982), .B(n5055), .Y(n5020) );
  sky130_fd_sc_hd__nand2_1 U6504 ( .A(count_cycle[46]), .B(count_cycle[47]), 
        .Y(n4983) );
  sky130_fd_sc_hd__nand2_1 U6505 ( .A(count_cycle[44]), .B(count_cycle[45]), 
        .Y(n5024) );
  sky130_fd_sc_hd__nor2_1 U6506 ( .A(n4983), .B(n5024), .Y(n4984) );
  sky130_fd_sc_hd__nand2_1 U6507 ( .A(n5020), .B(n4984), .Y(n4988) );
  sky130_fd_sc_hd__nand2_1 U6508 ( .A(count_cycle[34]), .B(count_cycle[35]), 
        .Y(n4985) );
  sky130_fd_sc_hd__nand2_1 U6509 ( .A(count_cycle[32]), .B(count_cycle[33]), 
        .Y(n5122) );
  sky130_fd_sc_hd__nor2_1 U6510 ( .A(n4985), .B(n5122), .Y(n5066) );
  sky130_fd_sc_hd__nand2_1 U6511 ( .A(count_cycle[38]), .B(count_cycle[39]), 
        .Y(n4986) );
  sky130_fd_sc_hd__nand2_1 U6512 ( .A(count_cycle[36]), .B(count_cycle[37]), 
        .Y(n5067) );
  sky130_fd_sc_hd__nor2_1 U6513 ( .A(n4986), .B(n5067), .Y(n4987) );
  sky130_fd_sc_hd__nand2_1 U6514 ( .A(n5066), .B(n4987), .Y(n5021) );
  sky130_fd_sc_hd__nor2_1 U6515 ( .A(n4988), .B(n5021), .Y(n5000) );
  sky130_fd_sc_hd__nor2_1 U6516 ( .A(n5004), .B(n5078), .Y(n5006) );
  sky130_fd_sc_hd__nand2_1 U6517 ( .A(n5006), .B(count_cycle[58]), .Y(n4992)
         );
  sky130_fd_sc_hd__nand2_1 U6518 ( .A(count_cycle[50]), .B(count_cycle[51]), 
        .Y(n4989) );
  sky130_fd_sc_hd__nand2_1 U6519 ( .A(count_cycle[48]), .B(count_cycle[49]), 
        .Y(n5037) );
  sky130_fd_sc_hd__nor2_1 U6520 ( .A(n4989), .B(n5037), .Y(n5029) );
  sky130_fd_sc_hd__nand2_1 U6521 ( .A(count_cycle[54]), .B(count_cycle[55]), 
        .Y(n4990) );
  sky130_fd_sc_hd__nand2_1 U6522 ( .A(count_cycle[52]), .B(count_cycle[53]), 
        .Y(n5032) );
  sky130_fd_sc_hd__nor2_1 U6523 ( .A(n4990), .B(n5032), .Y(n4991) );
  sky130_fd_sc_hd__nand2_1 U6524 ( .A(n5029), .B(n4991), .Y(n5001) );
  sky130_fd_sc_hd__nor2_1 U6525 ( .A(n4992), .B(n5001), .Y(n4993) );
  sky130_fd_sc_hd__nand2_1 U6526 ( .A(n5000), .B(n4993), .Y(n4994) );
  sky130_fd_sc_hd__nor2_1 U6527 ( .A(n4999), .B(n4994), .Y(n5171) );
  sky130_fd_sc_hd__xor2_1 U6528 ( .A(count_cycle[63]), .B(n4995), .X(n4996) );
  sky130_fd_sc_hd__ha_1 U6529 ( .A(n4997), .B(count_cycle[62]), .COUT(n4995), 
        .SUM(n4998) );
  sky130_fd_sc_hd__nand2_1 U6530 ( .A(n5182), .B(n5000), .Y(n5030) );
  sky130_fd_sc_hd__nand2_1 U6531 ( .A(n5131), .B(n5002), .Y(n5079) );
  sky130_fd_sc_hd__nor2_1 U6532 ( .A(n5078), .B(n5079), .Y(n5003) );
  sky130_fd_sc_hd__xnor2_1 U6533 ( .A(n5004), .B(n5003), .Y(n5005) );
  sky130_fd_sc_hd__nor2_1 U6534 ( .A(n5007), .B(n5079), .Y(n5008) );
  sky130_fd_sc_hd__xnor2_1 U6535 ( .A(n5009), .B(n5008), .Y(n5010) );
  sky130_fd_sc_hd__nor2_1 U6536 ( .A(n5013), .B(n5195), .Y(n5154) );
  sky130_fd_sc_hd__nor2_1 U6537 ( .A(n5014), .B(n5148), .Y(n5042) );
  sky130_fd_sc_hd__nand2_1 U6538 ( .A(n5042), .B(n5016), .Y(n5082) );
  sky130_fd_sc_hd__nor2_1 U6539 ( .A(n5081), .B(n5082), .Y(n5017) );
  sky130_fd_sc_hd__xnor2_1 U6540 ( .A(n5018), .B(n5017), .Y(n5019) );
  sky130_fd_sc_hd__nand2_1 U6541 ( .A(n5182), .B(n5022), .Y(n5054) );
  sky130_fd_sc_hd__nor2_1 U6542 ( .A(n5023), .B(n5054), .Y(n5046) );
  sky130_fd_sc_hd__nand2_1 U6543 ( .A(n5046), .B(n5025), .Y(n5085) );
  sky130_fd_sc_hd__nor2_1 U6544 ( .A(n5084), .B(n5085), .Y(n5026) );
  sky130_fd_sc_hd__xnor2_1 U6545 ( .A(n5027), .B(n5026), .Y(n5028) );
  sky130_fd_sc_hd__nor2_1 U6546 ( .A(n5031), .B(n5030), .Y(n5050) );
  sky130_fd_sc_hd__nand2_1 U6547 ( .A(n5050), .B(n5033), .Y(n5088) );
  sky130_fd_sc_hd__nor2_1 U6548 ( .A(n5087), .B(n5088), .Y(n5034) );
  sky130_fd_sc_hd__xnor2_1 U6549 ( .A(n5035), .B(n5034), .Y(n5036) );
  sky130_fd_sc_hd__nand2_1 U6550 ( .A(n5131), .B(n5038), .Y(n5091) );
  sky130_fd_sc_hd__nor2_1 U6551 ( .A(n5090), .B(n5091), .Y(n5039) );
  sky130_fd_sc_hd__xnor2_1 U6552 ( .A(n5040), .B(n5039), .Y(n5041) );
  sky130_fd_sc_hd__nor2_1 U6553 ( .A(n5093), .B(n5094), .Y(n5043) );
  sky130_fd_sc_hd__xnor2_1 U6554 ( .A(n5044), .B(n5043), .Y(n5045) );
  sky130_fd_sc_hd__nor2_1 U6555 ( .A(n5096), .B(n5097), .Y(n5047) );
  sky130_fd_sc_hd__xnor2_1 U6556 ( .A(n5048), .B(n5047), .Y(n5049) );
  sky130_fd_sc_hd__nor2_1 U6557 ( .A(n5099), .B(n5100), .Y(n5051) );
  sky130_fd_sc_hd__xnor2_1 U6558 ( .A(n5052), .B(n5051), .Y(n5053) );
  sky130_fd_sc_hd__nand2_1 U6559 ( .A(n5134), .B(n5056), .Y(n5106) );
  sky130_fd_sc_hd__nor2_1 U6560 ( .A(n5105), .B(n5106), .Y(n5057) );
  sky130_fd_sc_hd__xnor2_1 U6561 ( .A(n5058), .B(n5057), .Y(n5059) );
  sky130_fd_sc_hd__ha_1 U6562 ( .A(n5060), .B(count_cycle[61]), .COUT(n4997), 
        .SUM(n5061) );
  sky130_fd_sc_hd__nor2_1 U6563 ( .A(n5062), .B(n5148), .Y(n5114) );
  sky130_fd_sc_hd__nand2_1 U6564 ( .A(n5114), .B(count_cycle[26]), .Y(n5064)
         );
  sky130_fd_sc_hd__xor2_1 U6565 ( .A(n5064), .B(n5063), .X(n5065) );
  sky130_fd_sc_hd__nand2_1 U6566 ( .A(n5182), .B(n5066), .Y(n5127) );
  sky130_fd_sc_hd__nand2_1 U6567 ( .A(n5141), .B(n5068), .Y(n5112) );
  sky130_fd_sc_hd__nor2_1 U6568 ( .A(n5111), .B(n5112), .Y(n5069) );
  sky130_fd_sc_hd__xnor2_1 U6569 ( .A(n5070), .B(n5069), .Y(n5071) );
  sky130_fd_sc_hd__nor2_1 U6570 ( .A(n5073), .B(n5195), .Y(n5150) );
  sky130_fd_sc_hd__nor2_1 U6571 ( .A(n5074), .B(n5162), .Y(n5119) );
  sky130_fd_sc_hd__nand2_1 U6572 ( .A(n5119), .B(count_cycle[22]), .Y(n5076)
         );
  sky130_fd_sc_hd__xor2_1 U6573 ( .A(n5076), .B(n5075), .X(n5077) );
  sky130_fd_sc_hd__xor2_1 U6574 ( .A(n5079), .B(n5078), .X(n5080) );
  sky130_fd_sc_hd__xor2_1 U6575 ( .A(n5082), .B(n5081), .X(n5083) );
  sky130_fd_sc_hd__xor2_1 U6576 ( .A(n5085), .B(n5084), .X(n5086) );
  sky130_fd_sc_hd__xor2_1 U6577 ( .A(n5088), .B(n5087), .X(n5089) );
  sky130_fd_sc_hd__xor2_1 U6578 ( .A(n5091), .B(n5090), .X(n5092) );
  sky130_fd_sc_hd__xor2_1 U6579 ( .A(n5094), .B(n5093), .X(n5095) );
  sky130_fd_sc_hd__xor2_1 U6580 ( .A(n5097), .B(n5096), .X(n5098) );
  sky130_fd_sc_hd__xor2_1 U6581 ( .A(n5100), .B(n5099), .X(n5101) );
  sky130_fd_sc_hd__nand2_1 U6582 ( .A(n5131), .B(count_cycle[48]), .Y(n5103)
         );
  sky130_fd_sc_hd__xor2_1 U6583 ( .A(n5103), .B(n5102), .X(n5104) );
  sky130_fd_sc_hd__xor2_1 U6584 ( .A(n5106), .B(n5105), .X(n5107) );
  sky130_fd_sc_hd__nand2_1 U6585 ( .A(n5134), .B(count_cycle[40]), .Y(n5109)
         );
  sky130_fd_sc_hd__xor2_1 U6586 ( .A(n5109), .B(n5108), .X(n5110) );
  sky130_fd_sc_hd__xor2_1 U6587 ( .A(n5112), .B(n5111), .X(n5113) );
  sky130_fd_sc_hd__xnor2_1 U6588 ( .A(n5115), .B(n5114), .Y(n5116) );
  sky130_fd_sc_hd__ha_1 U6589 ( .A(n5117), .B(count_cycle[60]), .COUT(n5060), 
        .SUM(n5118) );
  sky130_fd_sc_hd__xnor2_1 U6590 ( .A(n5120), .B(n5119), .Y(n5121) );
  sky130_fd_sc_hd__nand2_1 U6591 ( .A(n5182), .B(n5123), .Y(n5145) );
  sky130_fd_sc_hd__nor2_1 U6592 ( .A(n5144), .B(n5145), .Y(n5124) );
  sky130_fd_sc_hd__xnor2_1 U6593 ( .A(n5125), .B(n5124), .Y(n5126) );
  sky130_fd_sc_hd__nor2_1 U6594 ( .A(n5142), .B(n5127), .Y(n5128) );
  sky130_fd_sc_hd__xnor2_1 U6595 ( .A(n5129), .B(n5128), .Y(n5130) );
  sky130_fd_sc_hd__xnor2_1 U6596 ( .A(n5132), .B(n5131), .Y(n5133) );
  sky130_fd_sc_hd__xnor2_1 U6597 ( .A(n5135), .B(n5134), .Y(n5136) );
  sky130_fd_sc_hd__nor2_1 U6598 ( .A(n5137), .B(n5195), .Y(n5173) );
  sky130_fd_sc_hd__nand2_1 U6599 ( .A(n5173), .B(count_cycle[18]), .Y(n5139)
         );
  sky130_fd_sc_hd__xor2_1 U6600 ( .A(n5139), .B(n5138), .X(n5140) );
  sky130_fd_sc_hd__xnor2_1 U6601 ( .A(n5142), .B(n5141), .Y(n5143) );
  sky130_fd_sc_hd__xor2_1 U6602 ( .A(n5145), .B(n5144), .X(n5146) );
  sky130_fd_sc_hd__xor2_1 U6603 ( .A(n5148), .B(n5147), .X(n5149) );
  sky130_fd_sc_hd__nand2_1 U6604 ( .A(n5150), .B(count_cycle[20]), .Y(n5152)
         );
  sky130_fd_sc_hd__xor2_1 U6605 ( .A(n5152), .B(n5151), .X(n5153) );
  sky130_fd_sc_hd__nand2_1 U6606 ( .A(n5154), .B(count_cycle[24]), .Y(n5156)
         );
  sky130_fd_sc_hd__xor2_1 U6607 ( .A(n5156), .B(n5155), .X(n5157) );
  sky130_fd_sc_hd__nand2_1 U6608 ( .A(n5182), .B(count_cycle[32]), .Y(n5159)
         );
  sky130_fd_sc_hd__xor2_1 U6609 ( .A(n5159), .B(n5158), .X(n5160) );
  sky130_fd_sc_hd__xor2_1 U6610 ( .A(n5162), .B(n5161), .X(n5163) );
  sky130_fd_sc_hd__nand2_1 U6611 ( .A(n5217), .B(n5165), .Y(n5190) );
  sky130_fd_sc_hd__nand2_1 U6612 ( .A(n5202), .B(n5167), .Y(n5177) );
  sky130_fd_sc_hd__nor2_1 U6613 ( .A(n5176), .B(n5177), .Y(n5168) );
  sky130_fd_sc_hd__xnor2_1 U6614 ( .A(n5169), .B(n5168), .Y(n5170) );
  sky130_fd_sc_hd__xnor2_1 U6615 ( .A(n5174), .B(n5173), .Y(n5175) );
  sky130_fd_sc_hd__xor2_1 U6616 ( .A(n5177), .B(n5176), .X(n5178) );
  sky130_fd_sc_hd__nor2_1 U6617 ( .A(n5194), .B(n5195), .Y(n5179) );
  sky130_fd_sc_hd__xnor2_1 U6618 ( .A(n5180), .B(n5179), .Y(n5181) );
  sky130_fd_sc_hd__xnor2_1 U6619 ( .A(n5183), .B(n5182), .Y(n5184) );
  sky130_fd_sc_hd__nand2_1 U6620 ( .A(n5217), .B(n5186), .Y(n5206) );
  sky130_fd_sc_hd__nor2_1 U6621 ( .A(n5205), .B(n5206), .Y(n5187) );
  sky130_fd_sc_hd__xnor2_1 U6622 ( .A(n5188), .B(n5187), .Y(n5189) );
  sky130_fd_sc_hd__nor2_1 U6623 ( .A(n5203), .B(n5190), .Y(n5191) );
  sky130_fd_sc_hd__xnor2_1 U6624 ( .A(n5192), .B(n5191), .Y(n5193) );
  sky130_fd_sc_hd__xor2_1 U6625 ( .A(n5195), .B(n5194), .X(n5196) );
  sky130_fd_sc_hd__nor2_1 U6626 ( .A(n5198), .B(n5221), .Y(n5211) );
  sky130_fd_sc_hd__nand2_1 U6627 ( .A(n5211), .B(count_cycle[6]), .Y(n5200) );
  sky130_fd_sc_hd__xor2_1 U6628 ( .A(n5200), .B(n5199), .X(n5201) );
  sky130_fd_sc_hd__xnor2_1 U6629 ( .A(n5203), .B(n5202), .Y(n5204) );
  sky130_fd_sc_hd__xor2_1 U6630 ( .A(n5206), .B(n5205), .X(n5207) );
  sky130_fd_sc_hd__nand2_1 U6631 ( .A(n5217), .B(count_cycle[8]), .Y(n5209) );
  sky130_fd_sc_hd__xor2_1 U6632 ( .A(n5209), .B(n5208), .X(n5210) );
  sky130_fd_sc_hd__xnor2_1 U6633 ( .A(n5212), .B(n5211), .Y(n5213) );
  sky130_fd_sc_hd__nor2_1 U6634 ( .A(n5220), .B(n5221), .Y(n5214) );
  sky130_fd_sc_hd__xnor2_1 U6635 ( .A(n5215), .B(n5214), .Y(n5216) );
  sky130_fd_sc_hd__xnor2_1 U6636 ( .A(n5218), .B(n5217), .Y(n5219) );
  sky130_fd_sc_hd__xor2_1 U6637 ( .A(n5221), .B(n5220), .X(n5222) );
  sky130_fd_sc_hd__nand2_1 U6638 ( .A(n5227), .B(count_cycle[2]), .Y(n5225) );
  sky130_fd_sc_hd__xor2_1 U6639 ( .A(n5225), .B(n5224), .X(n5226) );
  sky130_fd_sc_hd__xnor2_1 U6640 ( .A(n5228), .B(n5227), .Y(n5229) );
  sky130_fd_sc_hd__xnor2_1 U6641 ( .A(count_cycle[0]), .B(n5230), .Y(n5231) );
  sky130_fd_sc_hd__nor2_1 U6642 ( .A(is_lui_auipc_jal), .B(n10099), .Y(n9512)
         );
  sky130_fd_sc_hd__nand2_1 U6643 ( .A(n6029), .B(n9512), .Y(n9534) );
  sky130_fd_sc_hd__nor2_1 U6644 ( .A(n9532), .B(n9442), .Y(n9514) );
  sky130_fd_sc_hd__o22ai_1 U6645 ( .A1(n9534), .A2(n9440), .B1(n5232), .B2(
        n9519), .Y(n2839) );
  sky130_fd_sc_hd__nand2_1 U6646 ( .A(n5359), .B(n5357), .Y(n5235) );
  sky130_fd_sc_hd__o21ai_1 U6647 ( .A1(n5296), .A2(n4217), .B1(n5297), .Y(
        n5234) );
  sky130_fd_sc_hd__xnor2_1 U6648 ( .A(n5235), .B(n5234), .Y(n5236) );
  sky130_fd_sc_hd__nand2_1 U6649 ( .A(n5236), .B(n5794), .Y(n5238) );
  sky130_fd_sc_hd__a22oi_1 U6650 ( .A1(reg_next_pc[21]), .A2(n9530), .B1(n9370), .B2(n6669), .Y(n5237) );
  sky130_fd_sc_hd__nand2_1 U6651 ( .A(n5238), .B(n5237), .Y(n5239) );
  sky130_fd_sc_hd__nand2_1 U6652 ( .A(n4214), .B(reg_out[27]), .Y(n5242) );
  sky130_fd_sc_hd__nand2_1 U6653 ( .A(n5377), .B(alu_out_q[27]), .Y(n5241) );
  sky130_fd_sc_hd__nand2_1 U6654 ( .A(n4841), .B(reg_next_pc[27]), .Y(n5240)
         );
  sky130_fd_sc_hd__nand3_1 U6655 ( .A(n5242), .B(n5241), .C(n5240), .Y(n7179)
         );
  sky130_fd_sc_hd__nor2_1 U6656 ( .A(n5381), .B(n7179), .Y(n5334) );
  sky130_fd_sc_hd__nand2_1 U6657 ( .A(n7179), .B(n5381), .Y(n5337) );
  sky130_fd_sc_hd__nand2_1 U6658 ( .A(n5243), .B(n5337), .Y(n5250) );
  sky130_fd_sc_hd__nor2_1 U6659 ( .A(n5245), .B(n5244), .Y(n5332) );
  sky130_fd_sc_hd__nand2_1 U6660 ( .A(n4216), .B(n5332), .Y(n5248) );
  sky130_fd_sc_hd__nand2_1 U6661 ( .A(n5246), .B(n5321), .Y(n5335) );
  sky130_fd_sc_hd__a21oi_1 U6662 ( .A1(n5394), .A2(n5332), .B1(n5335), .Y(
        n5247) );
  sky130_fd_sc_hd__o21ai_1 U6663 ( .A1(n5248), .A2(n4217), .B1(n5247), .Y(
        n5249) );
  sky130_fd_sc_hd__xor2_1 U6664 ( .A(n5250), .B(n5249), .X(n5252) );
  sky130_fd_sc_hd__nand2_1 U6665 ( .A(n4214), .B(reg_out[30]), .Y(n5255) );
  sky130_fd_sc_hd__nand2_1 U6666 ( .A(n5377), .B(alu_out_q[30]), .Y(n5254) );
  sky130_fd_sc_hd__nand2_1 U6667 ( .A(n4841), .B(reg_next_pc[30]), .Y(n5253)
         );
  sky130_fd_sc_hd__nand3_1 U6668 ( .A(n5255), .B(n5254), .C(n5253), .Y(n6038)
         );
  sky130_fd_sc_hd__nor2_1 U6669 ( .A(n5381), .B(n6038), .Y(n5384) );
  sky130_fd_sc_hd__nand2_1 U6670 ( .A(n6038), .B(n5381), .Y(n5389) );
  sky130_fd_sc_hd__nand2_1 U6671 ( .A(n5256), .B(n5389), .Y(n5271) );
  sky130_fd_sc_hd__nand2_1 U6672 ( .A(n5376), .B(reg_out[29]), .Y(n5259) );
  sky130_fd_sc_hd__nand2_1 U6673 ( .A(n4841), .B(reg_next_pc[29]), .Y(n5258)
         );
  sky130_fd_sc_hd__nand2_1 U6674 ( .A(n5377), .B(alu_out_q[29]), .Y(n5257) );
  sky130_fd_sc_hd__nand3_1 U6675 ( .A(n5259), .B(n5258), .C(n5257), .Y(n6125)
         );
  sky130_fd_sc_hd__nor2_1 U6676 ( .A(n5381), .B(n6125), .Y(n5385) );
  sky130_fd_sc_hd__o22ai_1 U6677 ( .A1(n4845), .A2(reg_next_pc[28]), .B1(
        alu_out_q[28]), .B2(n5260), .Y(n5261) );
  sky130_fd_sc_hd__a21oi_1 U6678 ( .A1(n5263), .A2(n5262), .B1(n5261), .Y(
        n7566) );
  sky130_fd_sc_hd__nor2_1 U6679 ( .A(n5381), .B(n7566), .Y(n5329) );
  sky130_fd_sc_hd__nor2_1 U6680 ( .A(n5334), .B(n5329), .Y(n5264) );
  sky130_fd_sc_hd__nand2_1 U6681 ( .A(n5264), .B(n5332), .Y(n5386) );
  sky130_fd_sc_hd__nor2_1 U6682 ( .A(n5385), .B(n5386), .Y(n5267) );
  sky130_fd_sc_hd__nand2_1 U6683 ( .A(n4216), .B(n5267), .Y(n5269) );
  sky130_fd_sc_hd__nand2_1 U6684 ( .A(n6125), .B(n5381), .Y(n5388) );
  sky130_fd_sc_hd__nand2_1 U6685 ( .A(n7566), .B(n5381), .Y(n5330) );
  sky130_fd_sc_hd__nand2_1 U6686 ( .A(n5330), .B(n5337), .Y(n5265) );
  sky130_fd_sc_hd__nor2_1 U6687 ( .A(n5335), .B(n5265), .Y(n5390) );
  sky130_fd_sc_hd__nand2_1 U6688 ( .A(n5388), .B(n5390), .Y(n5266) );
  sky130_fd_sc_hd__a21oi_1 U6689 ( .A1(n5394), .A2(n5267), .B1(n5266), .Y(
        n5268) );
  sky130_fd_sc_hd__o21ai_1 U6690 ( .A1(n5269), .A2(n4217), .B1(n5268), .Y(
        n5270) );
  sky130_fd_sc_hd__xor2_1 U6691 ( .A(n5271), .B(n5270), .X(n5273) );
  sky130_fd_sc_hd__nand2_1 U6692 ( .A(n5287), .B(n5285), .Y(n5278) );
  sky130_fd_sc_hd__o21ai_1 U6693 ( .A1(n5276), .A2(n4217), .B1(n5275), .Y(
        n5277) );
  sky130_fd_sc_hd__xnor2_1 U6694 ( .A(n5278), .B(n5277), .Y(n5279) );
  sky130_fd_sc_hd__a222oi_1 U6695 ( .A1(n9530), .A2(reg_next_pc[19]), .B1(
        n9370), .B2(n7042), .C1(n5279), .C2(n5794), .Y(n5280) );
  sky130_fd_sc_hd__inv_1 U6696 ( .A(n5280), .Y(n4032) );
  sky130_fd_sc_hd__nand2_1 U6697 ( .A(n5283), .B(n5282), .Y(n5292) );
  sky130_fd_sc_hd__nand2_1 U6698 ( .A(n5284), .B(n5287), .Y(n5290) );
  sky130_fd_sc_hd__a21oi_1 U6699 ( .A1(n5288), .A2(n5287), .B1(n5286), .Y(
        n5289) );
  sky130_fd_sc_hd__o21ai_1 U6700 ( .A1(n5290), .A2(n4217), .B1(n5289), .Y(
        n5291) );
  sky130_fd_sc_hd__xnor2_1 U6701 ( .A(n5292), .B(n5291), .Y(n5293) );
  sky130_fd_sc_hd__a222oi_1 U6702 ( .A1(n9530), .A2(reg_next_pc[20]), .B1(
        n9370), .B2(n7402), .C1(n5293), .C2(n5794), .Y(n5294) );
  sky130_fd_sc_hd__inv_1 U6703 ( .A(n5294), .Y(n4031) );
  sky130_fd_sc_hd__nand2_1 U6704 ( .A(n5295), .B(n5312), .Y(n5301) );
  sky130_fd_sc_hd__nand2_1 U6705 ( .A(n5356), .B(n5307), .Y(n5299) );
  sky130_fd_sc_hd__inv_2 U6706 ( .A(n5297), .Y(n5360) );
  sky130_fd_sc_hd__a21oi_1 U6707 ( .A1(n5360), .A2(n5307), .B1(n5310), .Y(
        n5298) );
  sky130_fd_sc_hd__o21ai_1 U6708 ( .A1(n5299), .A2(n4217), .B1(n5298), .Y(
        n5300) );
  sky130_fd_sc_hd__xnor2_1 U6709 ( .A(n5301), .B(n5300), .Y(n5302) );
  sky130_fd_sc_hd__a222oi_1 U6710 ( .A1(n9530), .A2(reg_next_pc[23]), .B1(
        n9370), .B2(n7129), .C1(n5302), .C2(n5794), .Y(n5303) );
  sky130_fd_sc_hd__inv_1 U6711 ( .A(n5303), .Y(n4028) );
  sky130_fd_sc_hd__nand2_1 U6712 ( .A(n5306), .B(n5305), .Y(n5318) );
  sky130_fd_sc_hd__inv_1 U6713 ( .A(n5307), .Y(n5308) );
  sky130_fd_sc_hd__nor2_1 U6714 ( .A(n5309), .B(n5308), .Y(n5314) );
  sky130_fd_sc_hd__nand2_1 U6715 ( .A(n5314), .B(n5356), .Y(n5316) );
  sky130_fd_sc_hd__nand2_1 U6716 ( .A(n5312), .B(n5311), .Y(n5313) );
  sky130_fd_sc_hd__a21oi_1 U6717 ( .A1(n5360), .A2(n5314), .B1(n5313), .Y(
        n5315) );
  sky130_fd_sc_hd__o21ai_1 U6718 ( .A1(n5316), .A2(n4217), .B1(n5315), .Y(
        n5317) );
  sky130_fd_sc_hd__xnor2_1 U6719 ( .A(n5318), .B(n5317), .Y(n5319) );
  sky130_fd_sc_hd__a222oi_1 U6720 ( .A1(n9530), .A2(reg_next_pc[24]), .B1(
        n9370), .B2(n7519), .C1(n5319), .C2(n5794), .Y(n5320) );
  sky130_fd_sc_hd__inv_1 U6721 ( .A(n5320), .Y(n4027) );
  sky130_fd_sc_hd__nand2_1 U6722 ( .A(n5322), .B(n5321), .Y(n5326) );
  sky130_fd_sc_hd__o21ai_1 U6723 ( .A1(n5324), .A2(n4217), .B1(n5323), .Y(
        n5325) );
  sky130_fd_sc_hd__xnor2_1 U6724 ( .A(n5326), .B(n5325), .Y(n5327) );
  sky130_fd_sc_hd__a222oi_1 U6725 ( .A1(n9530), .A2(reg_next_pc[25]), .B1(
        n9370), .B2(n6755), .C1(n5327), .C2(n5794), .Y(n5328) );
  sky130_fd_sc_hd__inv_1 U6726 ( .A(n5328), .Y(n4026) );
  sky130_fd_sc_hd__nand2_1 U6727 ( .A(n5331), .B(n5330), .Y(n5343) );
  sky130_fd_sc_hd__nor2_1 U6728 ( .A(n5334), .B(n5333), .Y(n5339) );
  sky130_fd_sc_hd__nand2_1 U6729 ( .A(n4216), .B(n5339), .Y(n5341) );
  sky130_fd_sc_hd__nand2_1 U6730 ( .A(n5337), .B(n5336), .Y(n5338) );
  sky130_fd_sc_hd__a21oi_1 U6731 ( .A1(n5394), .A2(n5339), .B1(n5338), .Y(
        n5340) );
  sky130_fd_sc_hd__o21ai_1 U6732 ( .A1(n5341), .A2(n4217), .B1(n5340), .Y(
        n5342) );
  sky130_fd_sc_hd__xor2_1 U6733 ( .A(n5343), .B(n5342), .X(n5345) );
  sky130_fd_sc_hd__a22oi_1 U6734 ( .A1(reg_next_pc[28]), .A2(n9530), .B1(n9370), .B2(n7566), .Y(n5344) );
  sky130_fd_sc_hd__nand2_1 U6735 ( .A(n5348), .B(n5347), .Y(n5350) );
  sky130_fd_sc_hd__o21ai_1 U6736 ( .A1(n6492), .A2(n4217), .B1(n6493), .Y(
        n5349) );
  sky130_fd_sc_hd__xnor2_1 U6737 ( .A(n5350), .B(n5349), .Y(n5351) );
  sky130_fd_sc_hd__a222oi_1 U6738 ( .A1(n7783), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[18]), .C1(n5351), .C2(n5794), .Y(n5352) );
  sky130_fd_sc_hd__inv_1 U6739 ( .A(n5352), .Y(n4033) );
  sky130_fd_sc_hd__nand2_1 U6740 ( .A(n5355), .B(n5354), .Y(n5364) );
  sky130_fd_sc_hd__nand2_1 U6741 ( .A(n5356), .B(n5359), .Y(n5362) );
  sky130_fd_sc_hd__a21oi_1 U6742 ( .A1(n5360), .A2(n5359), .B1(n5358), .Y(
        n5361) );
  sky130_fd_sc_hd__o21ai_1 U6743 ( .A1(n5362), .A2(n4217), .B1(n5361), .Y(
        n5363) );
  sky130_fd_sc_hd__xnor2_1 U6744 ( .A(n5364), .B(n5363), .Y(n5365) );
  sky130_fd_sc_hd__a222oi_1 U6745 ( .A1(n7698), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[22]), .C1(n5365), .C2(n5794), .Y(n5366) );
  sky130_fd_sc_hd__inv_1 U6746 ( .A(n5366), .Y(n4029) );
  sky130_fd_sc_hd__nand2_1 U6747 ( .A(n5367), .B(n5388), .Y(n5373) );
  sky130_fd_sc_hd__nand2_1 U6748 ( .A(n4216), .B(n5369), .Y(n5371) );
  sky130_fd_sc_hd__a21oi_1 U6749 ( .A1(n5394), .A2(n5369), .B1(n5368), .Y(
        n5370) );
  sky130_fd_sc_hd__o21ai_1 U6750 ( .A1(n5371), .A2(n4217), .B1(n5370), .Y(
        n5372) );
  sky130_fd_sc_hd__xor2_1 U6751 ( .A(n5373), .B(n5372), .X(n5375) );
  sky130_fd_sc_hd__nand2_1 U6752 ( .A(n5376), .B(reg_out[31]), .Y(n5380) );
  sky130_fd_sc_hd__nand2_1 U6753 ( .A(n4841), .B(reg_next_pc[31]), .Y(n5379)
         );
  sky130_fd_sc_hd__nand2_1 U6754 ( .A(n5377), .B(alu_out_q[31]), .Y(n5378) );
  sky130_fd_sc_hd__nand3_1 U6755 ( .A(n5380), .B(n5379), .C(n5378), .Y(n9031)
         );
  sky130_fd_sc_hd__nand2_1 U6756 ( .A(n9031), .B(n5381), .Y(n5382) );
  sky130_fd_sc_hd__nand2_1 U6757 ( .A(n5383), .B(n5382), .Y(n5398) );
  sky130_fd_sc_hd__nor2_1 U6758 ( .A(n4242), .B(n5386), .Y(n5393) );
  sky130_fd_sc_hd__nand2_1 U6759 ( .A(n4216), .B(n5393), .Y(n5396) );
  sky130_fd_sc_hd__and2_0 U6760 ( .A(n5389), .B(n5388), .X(n5391) );
  sky130_fd_sc_hd__nand2_1 U6761 ( .A(n5391), .B(n5390), .Y(n5392) );
  sky130_fd_sc_hd__a21oi_1 U6762 ( .A1(n5394), .A2(n5393), .B1(n5392), .Y(
        n5395) );
  sky130_fd_sc_hd__o21ai_1 U6763 ( .A1(n5396), .A2(n4217), .B1(n5395), .Y(
        n5397) );
  sky130_fd_sc_hd__xnor2_1 U6764 ( .A(n5398), .B(n5397), .Y(n5399) );
  sky130_fd_sc_hd__nand2_1 U6765 ( .A(n5399), .B(n5794), .Y(n5402) );
  sky130_fd_sc_hd__nand2_1 U6766 ( .A(n9370), .B(n9031), .Y(n5401) );
  sky130_fd_sc_hd__nand2_1 U6767 ( .A(n9530), .B(reg_next_pc[31]), .Y(n5400)
         );
  sky130_fd_sc_hd__nand2_1 U6768 ( .A(n5899), .B(mem_do_wdata), .Y(n5405) );
  sky130_fd_sc_hd__a21oi_1 U6769 ( .A1(n5406), .A2(n5405), .B1(n10060), .Y(
        n4122) );
  sky130_fd_sc_hd__nand2_1 U6770 ( .A(is_beq_bne_blt_bge_bltu_bgeu), .B(resetn), .Y(n9007) );
  sky130_fd_sc_hd__nor4_1 U6771 ( .A(n5418), .B(n5408), .C(n5407), .D(n10090), 
        .Y(n5415) );
  sky130_fd_sc_hd__nand4_1 U6772 ( .A(n10114), .B(n5415), .C(n5429), .D(n10094), .Y(n5409) );
  sky130_fd_sc_hd__o21ai_1 U6773 ( .A1(n9007), .A2(n10114), .B1(n5409), .Y(
        n3964) );
  sky130_fd_sc_hd__o22ai_1 U6774 ( .A1(n5983), .A2(n5411), .B1(mem_rdata_q[27]), .B2(n5410), .Y(n2913) );
  sky130_fd_sc_hd__o22ai_1 U6775 ( .A1(n5983), .A2(n5413), .B1(mem_rdata_q[27]), .B2(n5412), .Y(n2915) );
  sky130_fd_sc_hd__nand2_1 U6776 ( .A(n5415), .B(n5414), .Y(n5431) );
  sky130_fd_sc_hd__nand2_1 U6777 ( .A(n10086), .B(n5988), .Y(n5416) );
  sky130_fd_sc_hd__o31ai_1 U6778 ( .A1(n5429), .A2(n5431), .A3(n10086), .B1(
        n5416), .Y(n2919) );
  sky130_fd_sc_hd__nand2b_1 U6779 ( .A_N(n5418), .B(n5417), .Y(n10109) );
  sky130_fd_sc_hd__o22ai_1 U6780 ( .A1(n10114), .A2(n5420), .B1(n5419), .B2(
        n10109), .Y(n2921) );
  sky130_fd_sc_hd__inv_1 U6781 ( .A(n6029), .Y(n5425) );
  sky130_fd_sc_hd__nor2_1 U6782 ( .A(is_lb_lh_lw_lbu_lhu), .B(n10118), .Y(
        n5422) );
  sky130_fd_sc_hd__nand2_1 U6783 ( .A(is_sll_srl_sra), .B(n10111), .Y(n9537)
         );
  sky130_fd_sc_hd__nor3_1 U6784 ( .A(is_lb_lh_lw_lbu_lhu), .B(
        is_jalr_addi_slti_sltiu_xori_ori_andi), .C(n9537), .Y(n5421) );
  sky130_fd_sc_hd__o211ai_1 U6785 ( .A1(n5422), .A2(n5421), .B1(n5991), .C1(
        n9514), .Y(n5424) );
  sky130_fd_sc_hd__o22ai_1 U6786 ( .A1(n5425), .A2(n5424), .B1(n5423), .B2(
        n9519), .Y(n2837) );
  sky130_fd_sc_hd__a222oi_1 U6787 ( .A1(n10086), .A2(decoded_imm_j[11]), .B1(
        n7928), .B2(mem_rdata[20]), .C1(n10087), .C2(mem_rdata_q[20]), .Y(
        n5426) );
  sky130_fd_sc_hd__a222oi_1 U6788 ( .A1(n10086), .A2(decoded_imm_j[1]), .B1(
        n10087), .B2(mem_rdata_q[21]), .C1(mem_rdata[21]), .C2(n7928), .Y(
        n5427) );
  sky130_fd_sc_hd__nor4_1 U6789 ( .A(mem_rdata[13]), .B(mem_rdata[14]), .C(
        mem_rdata[12]), .D(n10089), .Y(n5428) );
  sky130_fd_sc_hd__a32oi_1 U6790 ( .A1(n10044), .A2(n5429), .A3(n10087), .B1(
        n5428), .B2(n5429), .Y(n5430) );
  sky130_fd_sc_hd__o22ai_1 U6791 ( .A1(n10114), .A2(n10119), .B1(n5431), .B2(
        n5430), .Y(n2918) );
  sky130_fd_sc_hd__nor3_1 U6792 ( .A(n10060), .B(n10119), .C(n9012), .Y(n5432)
         );
  sky130_fd_sc_hd__a31oi_1 U6793 ( .A1(n9813), .A2(n9530), .A3(n9010), .B1(
        n5432), .Y(n5615) );
  sky130_fd_sc_hd__xnor2_1 U6794 ( .A(pcpi_rs1[11]), .B(pcpi_rs2[11]), .Y(
        n8052) );
  sky130_fd_sc_hd__xnor2_1 U6795 ( .A(pcpi_rs1[20]), .B(pcpi_rs2[20]), .Y(
        n7397) );
  sky130_fd_sc_hd__xnor2_1 U6796 ( .A(pcpi_rs1[18]), .B(pcpi_rs2[18]), .Y(
        n7778) );
  sky130_fd_sc_hd__xnor2_1 U6797 ( .A(pcpi_rs1[28]), .B(pcpi_rs2[28]), .Y(
        n6164) );
  sky130_fd_sc_hd__nand4_1 U6798 ( .A(n8052), .B(n7397), .C(n7778), .D(n6164), 
        .Y(n5464) );
  sky130_fd_sc_hd__xnor2_1 U6799 ( .A(pcpi_rs1[10]), .B(pcpi_rs2[10]), .Y(
        n8114) );
  sky130_fd_sc_hd__xnor2_1 U6800 ( .A(pcpi_rs1[27]), .B(pcpi_rs2[27]), .Y(
        n7174) );
  sky130_fd_sc_hd__xnor2_1 U6801 ( .A(pcpi_rs1[21]), .B(pcpi_rs2[21]), .Y(
        n6664) );
  sky130_fd_sc_hd__xnor2_1 U6802 ( .A(pcpi_rs1[30]), .B(pcpi_rs2[30]), .Y(
        n8682) );
  sky130_fd_sc_hd__nand4_1 U6803 ( .A(n8114), .B(n7174), .C(n6664), .D(n8682), 
        .Y(n5463) );
  sky130_fd_sc_hd__nand2_1 U6804 ( .A(n5433), .B(n8819), .Y(n6288) );
  sky130_fd_sc_hd__nand2_1 U6805 ( .A(pcpi_rs2[9]), .B(pcpi_rs1[9]), .Y(n6291)
         );
  sky130_fd_sc_hd__nand2_1 U6806 ( .A(n9889), .B(n7431), .Y(n7302) );
  sky130_fd_sc_hd__nand2_1 U6807 ( .A(pcpi_rs2[16]), .B(pcpi_rs1[16]), .Y(
        n7290) );
  sky130_fd_sc_hd__a22o_1 U6808 ( .A1(n6288), .A2(n6291), .B1(n7302), .B2(
        n7290), .X(n5444) );
  sky130_fd_sc_hd__nor2_1 U6809 ( .A(pcpi_rs1[13]), .B(pcpi_rs2[13]), .Y(n6436) );
  sky130_fd_sc_hd__nand2_1 U6810 ( .A(pcpi_rs2[13]), .B(pcpi_rs1[13]), .Y(
        n6437) );
  sky130_fd_sc_hd__nand2_1 U6811 ( .A(pcpi_rs2[24]), .B(pcpi_rs1[24]), .Y(
        n7516) );
  sky130_fd_sc_hd__nor2_1 U6812 ( .A(pcpi_rs1[24]), .B(pcpi_rs2[24]), .Y(n7515) );
  sky130_fd_sc_hd__o22ai_1 U6813 ( .A1(n6436), .A2(n5435), .B1(n5434), .B2(
        n7515), .Y(n5443) );
  sky130_fd_sc_hd__nor2_1 U6814 ( .A(pcpi_rs1[25]), .B(pcpi_rs2[25]), .Y(n6751) );
  sky130_fd_sc_hd__nand2_1 U6815 ( .A(pcpi_rs2[25]), .B(pcpi_rs1[25]), .Y(
        n6752) );
  sky130_fd_sc_hd__o22ai_1 U6816 ( .A1(n5438), .A2(n5437), .B1(n6751), .B2(
        n5436), .Y(n5442) );
  sky130_fd_sc_hd__nor2_1 U6817 ( .A(pcpi_rs1[23]), .B(pcpi_rs2[23]), .Y(n7125) );
  sky130_fd_sc_hd__nand2_1 U6818 ( .A(pcpi_rs2[23]), .B(pcpi_rs1[23]), .Y(
        n7126) );
  sky130_fd_sc_hd__nor2_1 U6819 ( .A(pcpi_rs1[29]), .B(pcpi_rs2[29]), .Y(n6121) );
  sky130_fd_sc_hd__nand2_1 U6820 ( .A(pcpi_rs2[29]), .B(pcpi_rs1[29]), .Y(
        n6122) );
  sky130_fd_sc_hd__o22ai_1 U6821 ( .A1(n7125), .A2(n5440), .B1(n6121), .B2(
        n5439), .Y(n5441) );
  sky130_fd_sc_hd__nor4_1 U6822 ( .A(n5444), .B(n5443), .C(n5442), .D(n5441), 
        .Y(n5461) );
  sky130_fd_sc_hd__xnor2_1 U6823 ( .A(pcpi_rs1[17]), .B(pcpi_rs2[17]), .Y(
        n6572) );
  sky130_fd_sc_hd__nor2_1 U6824 ( .A(pcpi_rs1[8]), .B(pcpi_rs2[8]), .Y(n8167)
         );
  sky130_fd_sc_hd__nand2_1 U6825 ( .A(pcpi_rs2[8]), .B(pcpi_rs1[8]), .Y(n8168)
         );
  sky130_fd_sc_hd__nand2_1 U6826 ( .A(pcpi_rs2[19]), .B(pcpi_rs1[19]), .Y(
        n7039) );
  sky130_fd_sc_hd__nor2_1 U6827 ( .A(pcpi_rs1[19]), .B(pcpi_rs2[19]), .Y(n7038) );
  sky130_fd_sc_hd__o22ai_1 U6828 ( .A1(n8167), .A2(n5446), .B1(n5445), .B2(
        n7038), .Y(n5448) );
  sky130_fd_sc_hd__nor2_1 U6829 ( .A(pcpi_rs1[5]), .B(pcpi_rs2[5]), .Y(n8286)
         );
  sky130_fd_sc_hd__nor2_1 U6830 ( .A(n9106), .B(n9899), .Y(n8292) );
  sky130_fd_sc_hd__nor2_1 U6831 ( .A(n9455), .B(n9897), .Y(n8395) );
  sky130_fd_sc_hd__nor2_1 U6832 ( .A(pcpi_rs1[4]), .B(pcpi_rs2[4]), .Y(n8387)
         );
  sky130_fd_sc_hd__o22ai_1 U6833 ( .A1(n8286), .A2(n8292), .B1(n8395), .B2(
        n8387), .Y(n5447) );
  sky130_fd_sc_hd__nor3_1 U6834 ( .A(n5449), .B(n5448), .C(n5447), .Y(n5460)
         );
  sky130_fd_sc_hd__xor2_1 U6835 ( .A(pcpi_rs1[1]), .B(pcpi_rs2[1]), .X(n9169)
         );
  sky130_fd_sc_hd__nand2_1 U6836 ( .A(n5450), .B(n8849), .Y(n6949) );
  sky130_fd_sc_hd__nand2_1 U6837 ( .A(pcpi_rs2[15]), .B(pcpi_rs1[15]), .Y(
        n6944) );
  sky130_fd_sc_hd__nand2_1 U6838 ( .A(pcpi_rs2[22]), .B(pcpi_rs1[22]), .Y(
        n7686) );
  sky130_fd_sc_hd__nand2_1 U6839 ( .A(n9901), .B(n8955), .Y(n7697) );
  sky130_fd_sc_hd__a22o_1 U6840 ( .A1(n6949), .A2(n6944), .B1(n7686), .B2(
        n7697), .X(n5457) );
  sky130_fd_sc_hd__nor2_1 U6841 ( .A(pcpi_rs1[26]), .B(pcpi_rs2[26]), .Y(n7612) );
  sky130_fd_sc_hd__nand2_1 U6842 ( .A(pcpi_rs2[26]), .B(pcpi_rs1[26]), .Y(
        n7613) );
  sky130_fd_sc_hd__o22ai_1 U6843 ( .A1(n7612), .A2(n5453), .B1(n5452), .B2(
        n5451), .Y(n5456) );
  sky130_fd_sc_hd__nor2_1 U6844 ( .A(pcpi_rs1[31]), .B(pcpi_rs2[31]), .Y(n9027) );
  sky130_fd_sc_hd__nand2_1 U6845 ( .A(pcpi_rs2[31]), .B(pcpi_rs1[31]), .Y(
        n9028) );
  sky130_fd_sc_hd__nor2_1 U6846 ( .A(pcpi_rs1[0]), .B(pcpi_rs2[0]), .Y(n9875)
         );
  sky130_fd_sc_hd__nor2_1 U6847 ( .A(n9149), .B(n9888), .Y(n9871) );
  sky130_fd_sc_hd__o22ai_1 U6848 ( .A1(n9027), .A2(n5454), .B1(n9875), .B2(
        n9871), .Y(n5455) );
  sky130_fd_sc_hd__nor4_1 U6849 ( .A(n9169), .B(n5457), .C(n5456), .D(n5455), 
        .Y(n5459) );
  sky130_fd_sc_hd__xor2_1 U6850 ( .A(pcpi_rs1[7]), .B(pcpi_rs2[7]), .X(n9047)
         );
  sky130_fd_sc_hd__xor2_1 U6851 ( .A(pcpi_rs1[3]), .B(pcpi_rs2[3]), .X(n8520)
         );
  sky130_fd_sc_hd__xor2_1 U6852 ( .A(pcpi_rs1[2]), .B(pcpi_rs2[2]), .X(n9381)
         );
  sky130_fd_sc_hd__xor2_1 U6853 ( .A(pcpi_rs1[6]), .B(pcpi_rs2[6]), .X(n8245)
         );
  sky130_fd_sc_hd__nor4_1 U6854 ( .A(n9047), .B(n8520), .C(n9381), .D(n8245), 
        .Y(n5458) );
  sky130_fd_sc_hd__nand4_1 U6855 ( .A(n5461), .B(n5460), .C(n5459), .D(n5458), 
        .Y(n5462) );
  sky130_fd_sc_hd__or3_1 U6856 ( .A(n5464), .B(n5463), .C(n5462), .X(n5609) );
  sky130_fd_sc_hd__nor2_1 U6857 ( .A(pcpi_rs2[16]), .B(n7431), .Y(n5465) );
  sky130_fd_sc_hd__nor2_1 U6858 ( .A(pcpi_rs2[17]), .B(n8888), .Y(n5533) );
  sky130_fd_sc_hd__nor2_1 U6859 ( .A(n5465), .B(n5533), .Y(n5467) );
  sky130_fd_sc_hd__nor2_1 U6860 ( .A(pcpi_rs2[19]), .B(n8890), .Y(n5536) );
  sky130_fd_sc_hd__nor2_1 U6861 ( .A(pcpi_rs2[18]), .B(n8880), .Y(n5466) );
  sky130_fd_sc_hd__nor2_1 U6862 ( .A(n5536), .B(n5466), .Y(n5540) );
  sky130_fd_sc_hd__nand2_1 U6863 ( .A(n5467), .B(n5540), .Y(n5471) );
  sky130_fd_sc_hd__nor2_1 U6864 ( .A(pcpi_rs2[21]), .B(n7430), .Y(n5542) );
  sky130_fd_sc_hd__nor2_1 U6865 ( .A(pcpi_rs2[20]), .B(n7549), .Y(n5468) );
  sky130_fd_sc_hd__nor2_1 U6866 ( .A(n5542), .B(n5468), .Y(n5470) );
  sky130_fd_sc_hd__nor2_1 U6867 ( .A(pcpi_rs2[23]), .B(n7548), .Y(n5545) );
  sky130_fd_sc_hd__nor2_1 U6868 ( .A(pcpi_rs2[22]), .B(n8955), .Y(n5469) );
  sky130_fd_sc_hd__nor2_1 U6869 ( .A(n5545), .B(n5469), .Y(n5549) );
  sky130_fd_sc_hd__nand2_1 U6870 ( .A(n5470), .B(n5549), .Y(n5552) );
  sky130_fd_sc_hd__nor2_1 U6871 ( .A(n5471), .B(n5552), .Y(n5580) );
  sky130_fd_sc_hd__nor2_1 U6872 ( .A(pcpi_rs2[29]), .B(n5562), .Y(n5564) );
  sky130_fd_sc_hd__nor2_1 U6873 ( .A(pcpi_rs2[28]), .B(n7191), .Y(n5472) );
  sky130_fd_sc_hd__nor2_1 U6874 ( .A(n5564), .B(n5472), .Y(n5578) );
  sky130_fd_sc_hd__nor2_1 U6875 ( .A(pcpi_rs1[31]), .B(n5566), .Y(n5568) );
  sky130_fd_sc_hd__nor2_1 U6876 ( .A(pcpi_rs2[30]), .B(n9305), .Y(n5577) );
  sky130_fd_sc_hd__nor2_1 U6877 ( .A(n5568), .B(n5577), .Y(n5570) );
  sky130_fd_sc_hd__nand2_1 U6878 ( .A(n5578), .B(n5570), .Y(n5572) );
  sky130_fd_sc_hd__nor2_1 U6879 ( .A(pcpi_rs2[25]), .B(n8932), .Y(n5554) );
  sky130_fd_sc_hd__nor2_1 U6880 ( .A(pcpi_rs2[24]), .B(n7541), .Y(n5473) );
  sky130_fd_sc_hd__nor2_1 U6881 ( .A(n5554), .B(n5473), .Y(n5475) );
  sky130_fd_sc_hd__nor2_1 U6882 ( .A(pcpi_rs2[27]), .B(n8931), .Y(n5557) );
  sky130_fd_sc_hd__nor2_1 U6883 ( .A(pcpi_rs2[26]), .B(n8918), .Y(n5474) );
  sky130_fd_sc_hd__nor2_1 U6884 ( .A(n5557), .B(n5474), .Y(n5561) );
  sky130_fd_sc_hd__nand2_1 U6885 ( .A(n5475), .B(n5561), .Y(n5579) );
  sky130_fd_sc_hd__nor2_1 U6886 ( .A(n5572), .B(n5579), .Y(n5574) );
  sky130_fd_sc_hd__nand2_1 U6887 ( .A(n5580), .B(n5574), .Y(n5576) );
  sky130_fd_sc_hd__nor2_1 U6888 ( .A(pcpi_rs2[5]), .B(n9106), .Y(n5490) );
  sky130_fd_sc_hd__nor2_1 U6889 ( .A(pcpi_rs2[4]), .B(n9455), .Y(n5476) );
  sky130_fd_sc_hd__nor2_1 U6890 ( .A(n5490), .B(n5476), .Y(n5478) );
  sky130_fd_sc_hd__nor2_1 U6891 ( .A(pcpi_rs2[7]), .B(n9079), .Y(n5493) );
  sky130_fd_sc_hd__nor2_1 U6892 ( .A(pcpi_rs2[6]), .B(n9117), .Y(n5477) );
  sky130_fd_sc_hd__nor2_1 U6893 ( .A(n5493), .B(n5477), .Y(n5497) );
  sky130_fd_sc_hd__nand2_1 U6894 ( .A(n5478), .B(n5497), .Y(n5500) );
  sky130_fd_sc_hd__nand2_1 U6895 ( .A(n9149), .B(pcpi_rs2[0]), .Y(n5481) );
  sky130_fd_sc_hd__nor2_1 U6896 ( .A(pcpi_rs2[1]), .B(n9907), .Y(n5480) );
  sky130_fd_sc_hd__nand2_1 U6897 ( .A(n9907), .B(pcpi_rs2[1]), .Y(n5479) );
  sky130_fd_sc_hd__o21ai_1 U6898 ( .A1(n5481), .A2(n5480), .B1(n5479), .Y(
        n5488) );
  sky130_fd_sc_hd__nor2_1 U6899 ( .A(pcpi_rs2[3]), .B(n9342), .Y(n5484) );
  sky130_fd_sc_hd__nor2_1 U6900 ( .A(pcpi_rs2[2]), .B(n9341), .Y(n5482) );
  sky130_fd_sc_hd__nor2_1 U6901 ( .A(n5484), .B(n5482), .Y(n5487) );
  sky130_fd_sc_hd__nand2_1 U6902 ( .A(n9341), .B(pcpi_rs2[2]), .Y(n5485) );
  sky130_fd_sc_hd__nand2_1 U6903 ( .A(n9342), .B(pcpi_rs2[3]), .Y(n5483) );
  sky130_fd_sc_hd__o21ai_1 U6904 ( .A1(n5485), .A2(n5484), .B1(n5483), .Y(
        n5486) );
  sky130_fd_sc_hd__a21oi_1 U6905 ( .A1(n5488), .A2(n5487), .B1(n5486), .Y(
        n5499) );
  sky130_fd_sc_hd__nand2_1 U6906 ( .A(n9455), .B(pcpi_rs2[4]), .Y(n5491) );
  sky130_fd_sc_hd__nand2_1 U6907 ( .A(n9106), .B(pcpi_rs2[5]), .Y(n5489) );
  sky130_fd_sc_hd__o21ai_1 U6908 ( .A1(n5491), .A2(n5490), .B1(n5489), .Y(
        n5496) );
  sky130_fd_sc_hd__nand2_1 U6909 ( .A(n9117), .B(pcpi_rs2[6]), .Y(n5494) );
  sky130_fd_sc_hd__nand2_1 U6910 ( .A(n9079), .B(pcpi_rs2[7]), .Y(n5492) );
  sky130_fd_sc_hd__o21ai_1 U6911 ( .A1(n5494), .A2(n5493), .B1(n5492), .Y(
        n5495) );
  sky130_fd_sc_hd__a21oi_1 U6912 ( .A1(n5497), .A2(n5496), .B1(n5495), .Y(
        n5498) );
  sky130_fd_sc_hd__o21ai_1 U6913 ( .A1(n5500), .A2(n5499), .B1(n5498), .Y(
        n5531) );
  sky130_fd_sc_hd__nor2_1 U6914 ( .A(pcpi_rs2[10]), .B(n8813), .Y(n5501) );
  sky130_fd_sc_hd__nor2_1 U6915 ( .A(pcpi_rs2[11]), .B(n8820), .Y(n5512) );
  sky130_fd_sc_hd__nor2_1 U6916 ( .A(n5501), .B(n5512), .Y(n5516) );
  sky130_fd_sc_hd__nor2_1 U6917 ( .A(pcpi_rs2[9]), .B(n8819), .Y(n5509) );
  sky130_fd_sc_hd__nor2_1 U6918 ( .A(pcpi_rs2[8]), .B(n8786), .Y(n5502) );
  sky130_fd_sc_hd__nor2_1 U6919 ( .A(n5509), .B(n5502), .Y(n5503) );
  sky130_fd_sc_hd__nand2_1 U6920 ( .A(n5516), .B(n5503), .Y(n5507) );
  sky130_fd_sc_hd__nor2_1 U6921 ( .A(pcpi_rs2[13]), .B(n8785), .Y(n5518) );
  sky130_fd_sc_hd__nor2_1 U6922 ( .A(pcpi_rs2[12]), .B(n8778), .Y(n5504) );
  sky130_fd_sc_hd__nor2_1 U6923 ( .A(n5518), .B(n5504), .Y(n5506) );
  sky130_fd_sc_hd__nor2_1 U6924 ( .A(pcpi_rs2[15]), .B(n8849), .Y(n5521) );
  sky130_fd_sc_hd__nor2_1 U6925 ( .A(pcpi_rs2[14]), .B(n8889), .Y(n5505) );
  sky130_fd_sc_hd__nor2_1 U6926 ( .A(n5521), .B(n5505), .Y(n5525) );
  sky130_fd_sc_hd__nand2_1 U6927 ( .A(n5506), .B(n5525), .Y(n5528) );
  sky130_fd_sc_hd__nor2_1 U6928 ( .A(n5507), .B(n5528), .Y(n5530) );
  sky130_fd_sc_hd__nand2_1 U6929 ( .A(n8786), .B(pcpi_rs2[8]), .Y(n5510) );
  sky130_fd_sc_hd__nand2_1 U6930 ( .A(n8819), .B(pcpi_rs2[9]), .Y(n5508) );
  sky130_fd_sc_hd__o21ai_1 U6931 ( .A1(n5510), .A2(n5509), .B1(n5508), .Y(
        n5515) );
  sky130_fd_sc_hd__nand2_1 U6932 ( .A(n8813), .B(pcpi_rs2[10]), .Y(n5513) );
  sky130_fd_sc_hd__nand2_1 U6933 ( .A(n8820), .B(pcpi_rs2[11]), .Y(n5511) );
  sky130_fd_sc_hd__o21ai_1 U6934 ( .A1(n5513), .A2(n5512), .B1(n5511), .Y(
        n5514) );
  sky130_fd_sc_hd__a21oi_1 U6935 ( .A1(n5516), .A2(n5515), .B1(n5514), .Y(
        n5527) );
  sky130_fd_sc_hd__nand2_1 U6936 ( .A(n8778), .B(pcpi_rs2[12]), .Y(n5519) );
  sky130_fd_sc_hd__nand2_1 U6937 ( .A(n8785), .B(pcpi_rs2[13]), .Y(n5517) );
  sky130_fd_sc_hd__o21ai_1 U6938 ( .A1(n5519), .A2(n5518), .B1(n5517), .Y(
        n5524) );
  sky130_fd_sc_hd__nand2_1 U6939 ( .A(n8889), .B(pcpi_rs2[14]), .Y(n5522) );
  sky130_fd_sc_hd__nand2_1 U6940 ( .A(n8849), .B(pcpi_rs2[15]), .Y(n5520) );
  sky130_fd_sc_hd__o21ai_1 U6941 ( .A1(n5522), .A2(n5521), .B1(n5520), .Y(
        n5523) );
  sky130_fd_sc_hd__a21oi_1 U6942 ( .A1(n5525), .A2(n5524), .B1(n5523), .Y(
        n5526) );
  sky130_fd_sc_hd__o21ai_1 U6943 ( .A1(n5528), .A2(n5527), .B1(n5526), .Y(
        n5529) );
  sky130_fd_sc_hd__a21oi_1 U6944 ( .A1(n5531), .A2(n5530), .B1(n5529), .Y(
        n5595) );
  sky130_fd_sc_hd__nand2_1 U6945 ( .A(n7431), .B(pcpi_rs2[16]), .Y(n5534) );
  sky130_fd_sc_hd__nand2_1 U6946 ( .A(n8888), .B(pcpi_rs2[17]), .Y(n5532) );
  sky130_fd_sc_hd__o21ai_1 U6947 ( .A1(n5534), .A2(n5533), .B1(n5532), .Y(
        n5539) );
  sky130_fd_sc_hd__nand2_1 U6948 ( .A(n8880), .B(pcpi_rs2[18]), .Y(n5537) );
  sky130_fd_sc_hd__nand2_1 U6949 ( .A(n8890), .B(pcpi_rs2[19]), .Y(n5535) );
  sky130_fd_sc_hd__o21ai_1 U6950 ( .A1(n5537), .A2(n5536), .B1(n5535), .Y(
        n5538) );
  sky130_fd_sc_hd__a21oi_1 U6951 ( .A1(n5540), .A2(n5539), .B1(n5538), .Y(
        n5551) );
  sky130_fd_sc_hd__nand2_1 U6952 ( .A(n7549), .B(pcpi_rs2[20]), .Y(n5543) );
  sky130_fd_sc_hd__nand2_1 U6953 ( .A(n7430), .B(pcpi_rs2[21]), .Y(n5541) );
  sky130_fd_sc_hd__o21ai_1 U6954 ( .A1(n5543), .A2(n5542), .B1(n5541), .Y(
        n5548) );
  sky130_fd_sc_hd__nand2_1 U6955 ( .A(n8955), .B(pcpi_rs2[22]), .Y(n5546) );
  sky130_fd_sc_hd__nand2_1 U6956 ( .A(n7548), .B(pcpi_rs2[23]), .Y(n5544) );
  sky130_fd_sc_hd__o21ai_1 U6957 ( .A1(n5546), .A2(n5545), .B1(n5544), .Y(
        n5547) );
  sky130_fd_sc_hd__a21oi_1 U6958 ( .A1(n5549), .A2(n5548), .B1(n5547), .Y(
        n5550) );
  sky130_fd_sc_hd__o21ai_1 U6959 ( .A1(n5552), .A2(n5551), .B1(n5550), .Y(
        n5593) );
  sky130_fd_sc_hd__nand2_1 U6960 ( .A(n7541), .B(pcpi_rs2[24]), .Y(n5555) );
  sky130_fd_sc_hd__nand2_1 U6961 ( .A(n8932), .B(pcpi_rs2[25]), .Y(n5553) );
  sky130_fd_sc_hd__o21ai_1 U6962 ( .A1(n5555), .A2(n5554), .B1(n5553), .Y(
        n5560) );
  sky130_fd_sc_hd__nand2_1 U6963 ( .A(n8918), .B(pcpi_rs2[26]), .Y(n5558) );
  sky130_fd_sc_hd__nand2_1 U6964 ( .A(n8931), .B(pcpi_rs2[27]), .Y(n5556) );
  sky130_fd_sc_hd__o21ai_1 U6965 ( .A1(n5558), .A2(n5557), .B1(n5556), .Y(
        n5559) );
  sky130_fd_sc_hd__a21oi_1 U6966 ( .A1(n5561), .A2(n5560), .B1(n5559), .Y(
        n5589) );
  sky130_fd_sc_hd__nand2_1 U6967 ( .A(n7191), .B(pcpi_rs2[28]), .Y(n5565) );
  sky130_fd_sc_hd__nand2_1 U6968 ( .A(n5562), .B(pcpi_rs2[29]), .Y(n5563) );
  sky130_fd_sc_hd__o21ai_1 U6969 ( .A1(n5565), .A2(n5564), .B1(n5563), .Y(
        n5586) );
  sky130_fd_sc_hd__nand2_1 U6970 ( .A(n9305), .B(pcpi_rs2[30]), .Y(n5584) );
  sky130_fd_sc_hd__nand2_1 U6971 ( .A(n5566), .B(pcpi_rs1[31]), .Y(n5567) );
  sky130_fd_sc_hd__o21ai_1 U6972 ( .A1(n5584), .A2(n5568), .B1(n5567), .Y(
        n5569) );
  sky130_fd_sc_hd__a21oi_1 U6973 ( .A1(n5586), .A2(n5570), .B1(n5569), .Y(
        n5571) );
  sky130_fd_sc_hd__o21ai_1 U6974 ( .A1(n5572), .A2(n5589), .B1(n5571), .Y(
        n5573) );
  sky130_fd_sc_hd__a21oi_1 U6975 ( .A1(n5593), .A2(n5574), .B1(n5573), .Y(
        n5575) );
  sky130_fd_sc_hd__o21ai_1 U6976 ( .A1(n5576), .A2(n5595), .B1(n5575), .Y(
        n5597) );
  sky130_fd_sc_hd__nor2_1 U6977 ( .A(pcpi_rs2[31]), .B(n5581), .Y(n5583) );
  sky130_fd_sc_hd__nor2_1 U6978 ( .A(n5583), .B(n5577), .Y(n5587) );
  sky130_fd_sc_hd__nand2_1 U6979 ( .A(n5578), .B(n5587), .Y(n5590) );
  sky130_fd_sc_hd__nor2_1 U6980 ( .A(n5590), .B(n5579), .Y(n5592) );
  sky130_fd_sc_hd__nand2_1 U6981 ( .A(n5580), .B(n5592), .Y(n5596) );
  sky130_fd_sc_hd__nand2_1 U6982 ( .A(n5581), .B(pcpi_rs2[31]), .Y(n5582) );
  sky130_fd_sc_hd__o21ai_1 U6983 ( .A1(n5584), .A2(n5583), .B1(n5582), .Y(
        n5585) );
  sky130_fd_sc_hd__a21oi_1 U6984 ( .A1(n5587), .A2(n5586), .B1(n5585), .Y(
        n5588) );
  sky130_fd_sc_hd__o21ai_1 U6985 ( .A1(n5590), .A2(n5589), .B1(n5588), .Y(
        n5591) );
  sky130_fd_sc_hd__a21oi_1 U6986 ( .A1(n5593), .A2(n5592), .B1(n5591), .Y(
        n5594) );
  sky130_fd_sc_hd__o21ai_1 U6987 ( .A1(n5596), .A2(n5595), .B1(n5594), .Y(
        n5599) );
  sky130_fd_sc_hd__nand2_1 U6988 ( .A(n5597), .B(is_slti_blt_slt), .Y(n5601)
         );
  sky130_fd_sc_hd__nand3_1 U6989 ( .A(n5599), .B(is_sltiu_bltu_sltu), .C(n5598), .Y(n5600) );
  sky130_fd_sc_hd__a21oi_1 U6990 ( .A1(n5601), .A2(n5600), .B1(instr_bgeu), 
        .Y(n5602) );
  sky130_fd_sc_hd__a21oi_1 U6991 ( .A1(instr_bgeu), .A2(n5603), .B1(n5602), 
        .Y(n5604) );
  sky130_fd_sc_hd__nor2_1 U6992 ( .A(instr_bge), .B(n5604), .Y(n5605) );
  sky130_fd_sc_hd__a21oi_1 U6993 ( .A1(instr_bge), .A2(n5606), .B1(n5605), .Y(
        n5607) );
  sky130_fd_sc_hd__nor2_1 U6994 ( .A(instr_bne), .B(n5607), .Y(n5608) );
  sky130_fd_sc_hd__a21oi_1 U6995 ( .A1(instr_bne), .A2(n5609), .B1(n5608), .Y(
        n5612) );
  sky130_fd_sc_hd__nand2_1 U6996 ( .A(n5610), .B(instr_beq), .Y(n5611) );
  sky130_fd_sc_hd__o21ai_1 U6997 ( .A1(instr_beq), .A2(n5612), .B1(n5611), .Y(
        n9543) );
  sky130_fd_sc_hd__nand2_1 U6998 ( .A(n9543), .B(n5614), .Y(n9542) );
  sky130_fd_sc_hd__o211ai_1 U6999 ( .A1(n5883), .A2(n5985), .B1(n5615), .C1(
        n9542), .Y(n4118) );
  sky130_fd_sc_hd__nand2_1 U7000 ( .A(n5616), .B(resetn), .Y(n5617) );
  sky130_fd_sc_hd__nand2_1 U7001 ( .A(count_instr[26]), .B(count_instr[27]), 
        .Y(n5618) );
  sky130_fd_sc_hd__nand2_1 U7002 ( .A(count_instr[24]), .B(count_instr[25]), 
        .Y(n5784) );
  sky130_fd_sc_hd__nor2_1 U7003 ( .A(n5618), .B(n5784), .Y(n5765) );
  sky130_fd_sc_hd__nand2_1 U7004 ( .A(count_instr[30]), .B(count_instr[31]), 
        .Y(n5619) );
  sky130_fd_sc_hd__nand2_1 U7005 ( .A(count_instr[28]), .B(count_instr[29]), 
        .Y(n5769) );
  sky130_fd_sc_hd__nor2_1 U7006 ( .A(n5619), .B(n5769), .Y(n5620) );
  sky130_fd_sc_hd__nand2_1 U7007 ( .A(n5765), .B(n5620), .Y(n5624) );
  sky130_fd_sc_hd__nand2_1 U7008 ( .A(count_instr[18]), .B(count_instr[19]), 
        .Y(n5621) );
  sky130_fd_sc_hd__nand2_1 U7009 ( .A(count_instr[16]), .B(count_instr[17]), 
        .Y(n5815) );
  sky130_fd_sc_hd__nor2_1 U7010 ( .A(n5621), .B(n5815), .Y(n5799) );
  sky130_fd_sc_hd__nand2_1 U7011 ( .A(count_instr[22]), .B(count_instr[23]), 
        .Y(n5622) );
  sky130_fd_sc_hd__nand2_1 U7012 ( .A(count_instr[20]), .B(count_instr[21]), 
        .Y(n5801) );
  sky130_fd_sc_hd__nor2_1 U7013 ( .A(n5622), .B(n5801), .Y(n5623) );
  sky130_fd_sc_hd__nand2_1 U7014 ( .A(n5799), .B(n5623), .Y(n5767) );
  sky130_fd_sc_hd__nor2_1 U7015 ( .A(n5624), .B(n5767), .Y(n5632) );
  sky130_fd_sc_hd__nand2_1 U7016 ( .A(count_instr[6]), .B(count_instr[7]), .Y(
        n5625) );
  sky130_fd_sc_hd__nand2_1 U7017 ( .A(count_instr[4]), .B(count_instr[5]), .Y(
        n5860) );
  sky130_fd_sc_hd__nor2_1 U7018 ( .A(n5625), .B(n5860), .Y(n5627) );
  sky130_fd_sc_hd__nand2_1 U7019 ( .A(count_instr[1]), .B(count_instr[0]), .Y(
        n5873) );
  sky130_fd_sc_hd__nand2_1 U7020 ( .A(count_instr[2]), .B(count_instr[3]), .Y(
        n5626) );
  sky130_fd_sc_hd__nor2_1 U7021 ( .A(n5873), .B(n5626), .Y(n5859) );
  sky130_fd_sc_hd__nand2_1 U7022 ( .A(n5627), .B(n5859), .Y(n5828) );
  sky130_fd_sc_hd__nand2_1 U7023 ( .A(count_instr[10]), .B(count_instr[11]), 
        .Y(n5628) );
  sky130_fd_sc_hd__nand2_1 U7024 ( .A(count_instr[8]), .B(count_instr[9]), .Y(
        n5845) );
  sky130_fd_sc_hd__nor2_1 U7025 ( .A(n5628), .B(n5845), .Y(n5829) );
  sky130_fd_sc_hd__nand2_1 U7026 ( .A(count_instr[14]), .B(count_instr[15]), 
        .Y(n5629) );
  sky130_fd_sc_hd__nand2_1 U7027 ( .A(count_instr[12]), .B(count_instr[13]), 
        .Y(n5830) );
  sky130_fd_sc_hd__nor2_1 U7028 ( .A(n5629), .B(n5830), .Y(n5630) );
  sky130_fd_sc_hd__nand2_1 U7029 ( .A(n5829), .B(n5630), .Y(n5631) );
  sky130_fd_sc_hd__nor2_1 U7030 ( .A(n5828), .B(n5631), .Y(n5766) );
  sky130_fd_sc_hd__nand2_1 U7031 ( .A(n5632), .B(n5766), .Y(n5658) );
  sky130_fd_sc_hd__nand2_1 U7032 ( .A(count_instr[42]), .B(count_instr[43]), 
        .Y(n5633) );
  sky130_fd_sc_hd__nand2_1 U7033 ( .A(count_instr[40]), .B(count_instr[41]), 
        .Y(n5724) );
  sky130_fd_sc_hd__nor2_1 U7034 ( .A(n5633), .B(n5724), .Y(n5704) );
  sky130_fd_sc_hd__nand2_1 U7035 ( .A(count_instr[46]), .B(count_instr[47]), 
        .Y(n5634) );
  sky130_fd_sc_hd__nand2_1 U7036 ( .A(count_instr[44]), .B(count_instr[45]), 
        .Y(n5708) );
  sky130_fd_sc_hd__nor2_1 U7037 ( .A(n5634), .B(n5708), .Y(n5635) );
  sky130_fd_sc_hd__nand2_1 U7038 ( .A(n5704), .B(n5635), .Y(n5639) );
  sky130_fd_sc_hd__nand2_1 U7039 ( .A(count_instr[34]), .B(count_instr[35]), 
        .Y(n5636) );
  sky130_fd_sc_hd__nand2_1 U7040 ( .A(count_instr[32]), .B(count_instr[33]), 
        .Y(n5754) );
  sky130_fd_sc_hd__nor2_1 U7041 ( .A(n5636), .B(n5754), .Y(n5738) );
  sky130_fd_sc_hd__nand2_1 U7042 ( .A(count_instr[38]), .B(count_instr[39]), 
        .Y(n5637) );
  sky130_fd_sc_hd__nand2_1 U7043 ( .A(count_instr[36]), .B(count_instr[37]), 
        .Y(n5739) );
  sky130_fd_sc_hd__nor2_1 U7044 ( .A(n5637), .B(n5739), .Y(n5638) );
  sky130_fd_sc_hd__nand2_1 U7045 ( .A(n5738), .B(n5638), .Y(n5705) );
  sky130_fd_sc_hd__nor2_1 U7046 ( .A(n5639), .B(n5705), .Y(n5659) );
  sky130_fd_sc_hd__nor2_1 U7047 ( .A(n5667), .B(n5669), .Y(n5657) );
  sky130_fd_sc_hd__nand2_1 U7048 ( .A(n5657), .B(count_instr[58]), .Y(n5643)
         );
  sky130_fd_sc_hd__nand2_1 U7049 ( .A(count_instr[50]), .B(count_instr[51]), 
        .Y(n5640) );
  sky130_fd_sc_hd__nand2_1 U7050 ( .A(count_instr[48]), .B(count_instr[49]), 
        .Y(n5690) );
  sky130_fd_sc_hd__nor2_1 U7051 ( .A(n5640), .B(n5690), .Y(n5672) );
  sky130_fd_sc_hd__nand2_1 U7052 ( .A(count_instr[54]), .B(count_instr[55]), 
        .Y(n5641) );
  sky130_fd_sc_hd__nand2_1 U7053 ( .A(count_instr[52]), .B(count_instr[53]), 
        .Y(n5675) );
  sky130_fd_sc_hd__nor2_1 U7054 ( .A(n5641), .B(n5675), .Y(n5642) );
  sky130_fd_sc_hd__nand2_1 U7055 ( .A(n5672), .B(n5642), .Y(n5660) );
  sky130_fd_sc_hd__nor2_1 U7056 ( .A(n5643), .B(n5660), .Y(n5644) );
  sky130_fd_sc_hd__nand2_1 U7057 ( .A(n5659), .B(n5644), .Y(n5645) );
  sky130_fd_sc_hd__nor2_1 U7058 ( .A(n5658), .B(n5645), .Y(n5655) );
  sky130_fd_sc_hd__xor2_1 U7059 ( .A(count_instr[63]), .B(n5646), .X(n5647) );
  sky130_fd_sc_hd__a22o_1 U7060 ( .A1(count_instr[63]), .A2(n5648), .B1(n5647), 
        .B2(n5794), .X(n4052) );
  sky130_fd_sc_hd__ha_1 U7061 ( .A(n5649), .B(count_instr[62]), .COUT(n5646), 
        .SUM(n5650) );
  sky130_fd_sc_hd__a22o_1 U7062 ( .A1(count_instr[62]), .A2(n5648), .B1(n5650), 
        .B2(n5794), .X(n4053) );
  sky130_fd_sc_hd__ha_1 U7063 ( .A(n5651), .B(count_instr[61]), .COUT(n5649), 
        .SUM(n5652) );
  sky130_fd_sc_hd__a22o_1 U7064 ( .A1(count_instr[61]), .A2(n5648), .B1(n5652), 
        .B2(n5794), .X(n4054) );
  sky130_fd_sc_hd__ha_1 U7065 ( .A(n5653), .B(count_instr[60]), .COUT(n5651), 
        .SUM(n5654) );
  sky130_fd_sc_hd__a22o_1 U7066 ( .A1(count_instr[60]), .A2(n5648), .B1(n5654), 
        .B2(n5794), .X(n4055) );
  sky130_fd_sc_hd__ha_1 U7067 ( .A(n5655), .B(count_instr[59]), .COUT(n5653), 
        .SUM(n5656) );
  sky130_fd_sc_hd__a22o_1 U7068 ( .A1(count_instr[59]), .A2(n5648), .B1(n5656), 
        .B2(n5794), .X(n4056) );
  sky130_fd_sc_hd__nand2_1 U7069 ( .A(n5762), .B(n5659), .Y(n5673) );
  sky130_fd_sc_hd__nand2_1 U7070 ( .A(n5701), .B(n5661), .Y(n5670) );
  sky130_fd_sc_hd__nor2_1 U7071 ( .A(n5662), .B(n5670), .Y(n5663) );
  sky130_fd_sc_hd__xnor2_1 U7072 ( .A(n5664), .B(n5663), .Y(n5665) );
  sky130_fd_sc_hd__a22o_1 U7073 ( .A1(count_instr[58]), .A2(n5648), .B1(n5665), 
        .B2(n5794), .X(n4057) );
  sky130_fd_sc_hd__nor2_1 U7074 ( .A(n5669), .B(n5670), .Y(n5666) );
  sky130_fd_sc_hd__xnor2_1 U7075 ( .A(n5667), .B(n5666), .Y(n5668) );
  sky130_fd_sc_hd__a22o_1 U7076 ( .A1(count_instr[57]), .A2(n5648), .B1(n5668), 
        .B2(n5794), .X(n4058) );
  sky130_fd_sc_hd__xor2_1 U7077 ( .A(n5670), .B(n5669), .X(n5671) );
  sky130_fd_sc_hd__a22o_1 U7078 ( .A1(count_instr[56]), .A2(n5648), .B1(n5671), 
        .B2(n5794), .X(n4059) );
  sky130_fd_sc_hd__nor2_1 U7079 ( .A(n5674), .B(n5673), .Y(n5683) );
  sky130_fd_sc_hd__nand2_1 U7080 ( .A(n5683), .B(n5676), .Y(n5681) );
  sky130_fd_sc_hd__nor2_1 U7081 ( .A(n5680), .B(n5681), .Y(n5677) );
  sky130_fd_sc_hd__xnor2_1 U7082 ( .A(n5678), .B(n5677), .Y(n5679) );
  sky130_fd_sc_hd__a22o_1 U7083 ( .A1(count_instr[55]), .A2(n5648), .B1(n5679), 
        .B2(n5794), .X(n4060) );
  sky130_fd_sc_hd__xor2_1 U7084 ( .A(n5681), .B(n5680), .X(n5682) );
  sky130_fd_sc_hd__a22o_1 U7085 ( .A1(count_instr[54]), .A2(n5648), .B1(n5682), 
        .B2(n5794), .X(n4061) );
  sky130_fd_sc_hd__nor2_1 U7086 ( .A(n5687), .B(n5688), .Y(n5684) );
  sky130_fd_sc_hd__xnor2_1 U7087 ( .A(n5685), .B(n5684), .Y(n5686) );
  sky130_fd_sc_hd__a22o_1 U7088 ( .A1(count_instr[53]), .A2(n5648), .B1(n5686), 
        .B2(n5794), .X(n4062) );
  sky130_fd_sc_hd__xor2_1 U7089 ( .A(n5688), .B(n5687), .X(n5689) );
  sky130_fd_sc_hd__a22o_1 U7090 ( .A1(count_instr[52]), .A2(n5648), .B1(n5689), 
        .B2(n5794), .X(n4063) );
  sky130_fd_sc_hd__nand2_1 U7091 ( .A(n5701), .B(n5691), .Y(n5696) );
  sky130_fd_sc_hd__nor2_1 U7092 ( .A(n5695), .B(n5696), .Y(n5692) );
  sky130_fd_sc_hd__xnor2_1 U7093 ( .A(n5693), .B(n5692), .Y(n5694) );
  sky130_fd_sc_hd__a22o_1 U7094 ( .A1(count_instr[51]), .A2(n5648), .B1(n5694), 
        .B2(n5794), .X(n4064) );
  sky130_fd_sc_hd__xor2_1 U7095 ( .A(n5696), .B(n5695), .X(n5697) );
  sky130_fd_sc_hd__a22o_1 U7096 ( .A1(count_instr[50]), .A2(n5648), .B1(n5697), 
        .B2(n5794), .X(n4065) );
  sky130_fd_sc_hd__nand2_1 U7097 ( .A(n5701), .B(count_instr[48]), .Y(n5699)
         );
  sky130_fd_sc_hd__xor2_1 U7098 ( .A(n5699), .B(n5698), .X(n5700) );
  sky130_fd_sc_hd__a22o_1 U7099 ( .A1(count_instr[49]), .A2(n5648), .B1(n5700), 
        .B2(n5794), .X(n4066) );
  sky130_fd_sc_hd__xnor2_1 U7100 ( .A(n5702), .B(n5701), .Y(n5703) );
  sky130_fd_sc_hd__a22o_1 U7101 ( .A1(count_instr[48]), .A2(n5648), .B1(n5703), 
        .B2(n5794), .X(n4067) );
  sky130_fd_sc_hd__nand2_1 U7102 ( .A(n5762), .B(n5706), .Y(n5723) );
  sky130_fd_sc_hd__nor2_1 U7103 ( .A(n5707), .B(n5723), .Y(n5716) );
  sky130_fd_sc_hd__nand2_1 U7104 ( .A(n5716), .B(n5709), .Y(n5714) );
  sky130_fd_sc_hd__nor2_1 U7105 ( .A(n5713), .B(n5714), .Y(n5710) );
  sky130_fd_sc_hd__xnor2_1 U7106 ( .A(n5711), .B(n5710), .Y(n5712) );
  sky130_fd_sc_hd__a22o_1 U7107 ( .A1(count_instr[47]), .A2(n5648), .B1(n5712), 
        .B2(n5794), .X(n4068) );
  sky130_fd_sc_hd__xor2_1 U7108 ( .A(n5714), .B(n5713), .X(n5715) );
  sky130_fd_sc_hd__a22o_1 U7109 ( .A1(count_instr[46]), .A2(n5648), .B1(n5715), 
        .B2(n5794), .X(n4069) );
  sky130_fd_sc_hd__nor2_1 U7110 ( .A(n5720), .B(n5721), .Y(n5717) );
  sky130_fd_sc_hd__xnor2_1 U7111 ( .A(n5718), .B(n5717), .Y(n5719) );
  sky130_fd_sc_hd__a22o_1 U7112 ( .A1(count_instr[45]), .A2(n5648), .B1(n5719), 
        .B2(n5794), .X(n4070) );
  sky130_fd_sc_hd__xor2_1 U7113 ( .A(n5721), .B(n5720), .X(n5722) );
  sky130_fd_sc_hd__a22o_1 U7114 ( .A1(count_instr[44]), .A2(n5648), .B1(n5722), 
        .B2(n5794), .X(n4071) );
  sky130_fd_sc_hd__nand2_1 U7115 ( .A(n5735), .B(n5725), .Y(n5730) );
  sky130_fd_sc_hd__nor2_1 U7116 ( .A(n5729), .B(n5730), .Y(n5726) );
  sky130_fd_sc_hd__xnor2_1 U7117 ( .A(n5727), .B(n5726), .Y(n5728) );
  sky130_fd_sc_hd__a22o_1 U7118 ( .A1(count_instr[43]), .A2(n5648), .B1(n5728), 
        .B2(n5794), .X(n4072) );
  sky130_fd_sc_hd__xor2_1 U7119 ( .A(n5730), .B(n5729), .X(n5731) );
  sky130_fd_sc_hd__a22o_1 U7120 ( .A1(count_instr[42]), .A2(n5648), .B1(n5731), 
        .B2(n5794), .X(n4073) );
  sky130_fd_sc_hd__nand2_1 U7121 ( .A(n5735), .B(count_instr[40]), .Y(n5733)
         );
  sky130_fd_sc_hd__xor2_1 U7122 ( .A(n5733), .B(n5732), .X(n5734) );
  sky130_fd_sc_hd__a22o_1 U7123 ( .A1(count_instr[41]), .A2(n5648), .B1(n5734), 
        .B2(n5794), .X(n4074) );
  sky130_fd_sc_hd__xnor2_1 U7124 ( .A(n5736), .B(n5735), .Y(n5737) );
  sky130_fd_sc_hd__a22o_1 U7125 ( .A1(count_instr[40]), .A2(n5648), .B1(n5737), 
        .B2(n5794), .X(n4075) );
  sky130_fd_sc_hd__nand2_1 U7126 ( .A(n5762), .B(n5738), .Y(n5747) );
  sky130_fd_sc_hd__nand2_1 U7127 ( .A(n5751), .B(n5740), .Y(n5745) );
  sky130_fd_sc_hd__nor2_1 U7128 ( .A(n5744), .B(n5745), .Y(n5741) );
  sky130_fd_sc_hd__xnor2_1 U7129 ( .A(n5742), .B(n5741), .Y(n5743) );
  sky130_fd_sc_hd__a22o_1 U7130 ( .A1(count_instr[39]), .A2(n5648), .B1(n5743), 
        .B2(n5794), .X(n4076) );
  sky130_fd_sc_hd__xor2_1 U7131 ( .A(n5745), .B(n5744), .X(n5746) );
  sky130_fd_sc_hd__a22o_1 U7132 ( .A1(count_instr[38]), .A2(n5648), .B1(n5746), 
        .B2(n5794), .X(n4077) );
  sky130_fd_sc_hd__nor2_1 U7133 ( .A(n5752), .B(n5747), .Y(n5748) );
  sky130_fd_sc_hd__xnor2_1 U7134 ( .A(n5749), .B(n5748), .Y(n5750) );
  sky130_fd_sc_hd__a22o_1 U7135 ( .A1(count_instr[37]), .A2(n5648), .B1(n5750), 
        .B2(n5794), .X(n4078) );
  sky130_fd_sc_hd__xnor2_1 U7136 ( .A(n5752), .B(n5751), .Y(n5753) );
  sky130_fd_sc_hd__a22o_1 U7137 ( .A1(count_instr[36]), .A2(n5648), .B1(n5753), 
        .B2(n5794), .X(n4079) );
  sky130_fd_sc_hd__nand2_1 U7138 ( .A(n5762), .B(n5755), .Y(n5885) );
  sky130_fd_sc_hd__nor2_1 U7139 ( .A(n5884), .B(n5885), .Y(n5756) );
  sky130_fd_sc_hd__xnor2_1 U7140 ( .A(n5757), .B(n5756), .Y(n5758) );
  sky130_fd_sc_hd__a22o_1 U7141 ( .A1(count_instr[35]), .A2(n5648), .B1(n5758), 
        .B2(n5794), .X(n4080) );
  sky130_fd_sc_hd__nand2_1 U7142 ( .A(n5762), .B(count_instr[32]), .Y(n5760)
         );
  sky130_fd_sc_hd__xor2_1 U7143 ( .A(n5760), .B(n5759), .X(n5761) );
  sky130_fd_sc_hd__a22o_1 U7144 ( .A1(count_instr[33]), .A2(n5648), .B1(n5761), 
        .B2(n5794), .X(n4082) );
  sky130_fd_sc_hd__xnor2_1 U7145 ( .A(n5763), .B(n5762), .Y(n5764) );
  sky130_fd_sc_hd__a22o_1 U7146 ( .A1(count_instr[32]), .A2(n5648), .B1(n5764), 
        .B2(n5794), .X(n4083) );
  sky130_fd_sc_hd__nor2_1 U7147 ( .A(n5767), .B(n5826), .Y(n5791) );
  sky130_fd_sc_hd__nor2_1 U7148 ( .A(n5768), .B(n5797), .Y(n5777) );
  sky130_fd_sc_hd__nand2_1 U7149 ( .A(n5777), .B(n5770), .Y(n5775) );
  sky130_fd_sc_hd__nor2_1 U7150 ( .A(n5774), .B(n5775), .Y(n5771) );
  sky130_fd_sc_hd__xnor2_1 U7151 ( .A(n5772), .B(n5771), .Y(n5773) );
  sky130_fd_sc_hd__a22o_1 U7152 ( .A1(count_instr[31]), .A2(n5648), .B1(n5773), 
        .B2(n5794), .X(n4084) );
  sky130_fd_sc_hd__xor2_1 U7153 ( .A(n5775), .B(n5774), .X(n5776) );
  sky130_fd_sc_hd__a22o_1 U7154 ( .A1(count_instr[30]), .A2(n5648), .B1(n5776), 
        .B2(n5794), .X(n4085) );
  sky130_fd_sc_hd__nor2_1 U7155 ( .A(n5781), .B(n5782), .Y(n5778) );
  sky130_fd_sc_hd__xnor2_1 U7156 ( .A(n5779), .B(n5778), .Y(n5780) );
  sky130_fd_sc_hd__a22o_1 U7157 ( .A1(count_instr[29]), .A2(n5648), .B1(n5780), 
        .B2(n5794), .X(n4086) );
  sky130_fd_sc_hd__xor2_1 U7158 ( .A(n5782), .B(n5781), .X(n5783) );
  sky130_fd_sc_hd__a22o_1 U7159 ( .A1(count_instr[28]), .A2(n5648), .B1(n5783), 
        .B2(n5794), .X(n4087) );
  sky130_fd_sc_hd__nor2_1 U7160 ( .A(n5784), .B(n5797), .Y(n5788) );
  sky130_fd_sc_hd__nand2_1 U7161 ( .A(n5788), .B(count_instr[26]), .Y(n5786)
         );
  sky130_fd_sc_hd__xor2_1 U7162 ( .A(n5786), .B(n5785), .X(n5787) );
  sky130_fd_sc_hd__a22o_1 U7163 ( .A1(count_instr[27]), .A2(n5648), .B1(n5787), 
        .B2(n5794), .X(n4088) );
  sky130_fd_sc_hd__xnor2_1 U7164 ( .A(n5789), .B(n5788), .Y(n5790) );
  sky130_fd_sc_hd__a22o_1 U7165 ( .A1(count_instr[26]), .A2(n5648), .B1(n5790), 
        .B2(n5794), .X(n4089) );
  sky130_fd_sc_hd__nand2_1 U7166 ( .A(n5791), .B(count_instr[24]), .Y(n5793)
         );
  sky130_fd_sc_hd__xor2_1 U7167 ( .A(n5793), .B(n5792), .X(n5795) );
  sky130_fd_sc_hd__a22o_1 U7168 ( .A1(count_instr[25]), .A2(n5648), .B1(n5795), 
        .B2(n5794), .X(n4090) );
  sky130_fd_sc_hd__xor2_1 U7169 ( .A(n5797), .B(n5796), .X(n5798) );
  sky130_fd_sc_hd__a22o_1 U7170 ( .A1(count_instr[24]), .A2(n5648), .B1(n5798), 
        .B2(n5794), .X(n4091) );
  sky130_fd_sc_hd__nor2_1 U7171 ( .A(n5800), .B(n5826), .Y(n5808) );
  sky130_fd_sc_hd__nor2_1 U7172 ( .A(n5801), .B(n5813), .Y(n5805) );
  sky130_fd_sc_hd__nand2_1 U7173 ( .A(n5805), .B(count_instr[22]), .Y(n5803)
         );
  sky130_fd_sc_hd__xor2_1 U7174 ( .A(n5803), .B(n5802), .X(n5804) );
  sky130_fd_sc_hd__a22o_1 U7175 ( .A1(count_instr[23]), .A2(n5648), .B1(n5804), 
        .B2(n5794), .X(n4092) );
  sky130_fd_sc_hd__xnor2_1 U7176 ( .A(n5806), .B(n5805), .Y(n5807) );
  sky130_fd_sc_hd__a22o_1 U7177 ( .A1(count_instr[22]), .A2(n5648), .B1(n5807), 
        .B2(n5794), .X(n4093) );
  sky130_fd_sc_hd__nand2_1 U7178 ( .A(n5808), .B(count_instr[20]), .Y(n5810)
         );
  sky130_fd_sc_hd__xor2_1 U7179 ( .A(n5810), .B(n5809), .X(n5811) );
  sky130_fd_sc_hd__a22o_1 U7180 ( .A1(count_instr[21]), .A2(n5648), .B1(n5811), 
        .B2(n5794), .X(n4094) );
  sky130_fd_sc_hd__xor2_1 U7181 ( .A(n5813), .B(n5812), .X(n5814) );
  sky130_fd_sc_hd__a22o_1 U7182 ( .A1(count_instr[20]), .A2(n5648), .B1(n5814), 
        .B2(n5794), .X(n4095) );
  sky130_fd_sc_hd__nor2_1 U7183 ( .A(n5815), .B(n5826), .Y(n5819) );
  sky130_fd_sc_hd__nand2_1 U7184 ( .A(n5819), .B(count_instr[18]), .Y(n5817)
         );
  sky130_fd_sc_hd__xor2_1 U7185 ( .A(n5817), .B(n5816), .X(n5818) );
  sky130_fd_sc_hd__a22o_1 U7186 ( .A1(count_instr[19]), .A2(n5648), .B1(n5818), 
        .B2(n5794), .X(n4096) );
  sky130_fd_sc_hd__xnor2_1 U7187 ( .A(n5820), .B(n5819), .Y(n5821) );
  sky130_fd_sc_hd__a22o_1 U7188 ( .A1(count_instr[18]), .A2(n5648), .B1(n5821), 
        .B2(n5794), .X(n4097) );
  sky130_fd_sc_hd__nor2_1 U7189 ( .A(n5825), .B(n5826), .Y(n5822) );
  sky130_fd_sc_hd__xnor2_1 U7190 ( .A(n5823), .B(n5822), .Y(n5824) );
  sky130_fd_sc_hd__a22o_1 U7191 ( .A1(count_instr[17]), .A2(n5648), .B1(n5824), 
        .B2(n5794), .X(n4098) );
  sky130_fd_sc_hd__xor2_1 U7192 ( .A(n5826), .B(n5825), .X(n5827) );
  sky130_fd_sc_hd__a22o_1 U7193 ( .A1(count_instr[16]), .A2(n5648), .B1(n5827), 
        .B2(n5794), .X(n4099) );
  sky130_fd_sc_hd__nand2_1 U7194 ( .A(n5856), .B(n5829), .Y(n5838) );
  sky130_fd_sc_hd__nand2_1 U7195 ( .A(n5842), .B(n5831), .Y(n5836) );
  sky130_fd_sc_hd__nor2_1 U7196 ( .A(n5835), .B(n5836), .Y(n5832) );
  sky130_fd_sc_hd__xnor2_1 U7197 ( .A(n5833), .B(n5832), .Y(n5834) );
  sky130_fd_sc_hd__a22o_1 U7198 ( .A1(count_instr[15]), .A2(n5648), .B1(n5834), 
        .B2(n5794), .X(n4100) );
  sky130_fd_sc_hd__xor2_1 U7199 ( .A(n5836), .B(n5835), .X(n5837) );
  sky130_fd_sc_hd__a22o_1 U7200 ( .A1(count_instr[14]), .A2(n5648), .B1(n5837), 
        .B2(n5794), .X(n4101) );
  sky130_fd_sc_hd__nor2_1 U7201 ( .A(n5843), .B(n5838), .Y(n5839) );
  sky130_fd_sc_hd__xnor2_1 U7202 ( .A(n5840), .B(n5839), .Y(n5841) );
  sky130_fd_sc_hd__a22o_1 U7203 ( .A1(count_instr[13]), .A2(n5648), .B1(n5841), 
        .B2(n5794), .X(n4102) );
  sky130_fd_sc_hd__xnor2_1 U7204 ( .A(n5843), .B(n5842), .Y(n5844) );
  sky130_fd_sc_hd__a22o_1 U7205 ( .A1(count_instr[12]), .A2(n5648), .B1(n5844), 
        .B2(n5794), .X(n4103) );
  sky130_fd_sc_hd__nand2_1 U7206 ( .A(n5856), .B(n5846), .Y(n5851) );
  sky130_fd_sc_hd__nor2_1 U7207 ( .A(n5850), .B(n5851), .Y(n5847) );
  sky130_fd_sc_hd__xnor2_1 U7208 ( .A(n5848), .B(n5847), .Y(n5849) );
  sky130_fd_sc_hd__a22o_1 U7209 ( .A1(count_instr[11]), .A2(n5648), .B1(n5849), 
        .B2(n5794), .X(n4104) );
  sky130_fd_sc_hd__xor2_1 U7210 ( .A(n5851), .B(n5850), .X(n5852) );
  sky130_fd_sc_hd__a22o_1 U7211 ( .A1(count_instr[10]), .A2(n5648), .B1(n5852), 
        .B2(n5794), .X(n4105) );
  sky130_fd_sc_hd__nand2_1 U7212 ( .A(n5856), .B(count_instr[8]), .Y(n5854) );
  sky130_fd_sc_hd__xor2_1 U7213 ( .A(n5854), .B(n5853), .X(n5855) );
  sky130_fd_sc_hd__a22o_1 U7214 ( .A1(count_instr[9]), .A2(n5648), .B1(n5855), 
        .B2(n5794), .X(n4106) );
  sky130_fd_sc_hd__xnor2_1 U7215 ( .A(n5857), .B(n5856), .Y(n5858) );
  sky130_fd_sc_hd__a22o_1 U7216 ( .A1(count_instr[8]), .A2(n5648), .B1(n5858), 
        .B2(n5794), .X(n4107) );
  sky130_fd_sc_hd__nor2_1 U7217 ( .A(n5860), .B(n5871), .Y(n5864) );
  sky130_fd_sc_hd__nand2_1 U7218 ( .A(n5864), .B(count_instr[6]), .Y(n5862) );
  sky130_fd_sc_hd__xor2_1 U7219 ( .A(n5862), .B(n5861), .X(n5863) );
  sky130_fd_sc_hd__a22o_1 U7220 ( .A1(count_instr[7]), .A2(n5648), .B1(n5863), 
        .B2(n5794), .X(n4108) );
  sky130_fd_sc_hd__xnor2_1 U7221 ( .A(n5865), .B(n5864), .Y(n5866) );
  sky130_fd_sc_hd__a22o_1 U7222 ( .A1(count_instr[6]), .A2(n5648), .B1(n5866), 
        .B2(n5794), .X(n4109) );
  sky130_fd_sc_hd__nor2_1 U7223 ( .A(n5870), .B(n5871), .Y(n5867) );
  sky130_fd_sc_hd__xnor2_1 U7224 ( .A(n5868), .B(n5867), .Y(n5869) );
  sky130_fd_sc_hd__a22o_1 U7225 ( .A1(count_instr[5]), .A2(n5648), .B1(n5869), 
        .B2(n5794), .X(n4110) );
  sky130_fd_sc_hd__xor2_1 U7226 ( .A(n5871), .B(n5870), .X(n5872) );
  sky130_fd_sc_hd__a22o_1 U7227 ( .A1(count_instr[4]), .A2(n5648), .B1(n5872), 
        .B2(n5794), .X(n4111) );
  sky130_fd_sc_hd__nand2_1 U7228 ( .A(n5877), .B(count_instr[2]), .Y(n5875) );
  sky130_fd_sc_hd__xor2_1 U7229 ( .A(n5875), .B(n5874), .X(n5876) );
  sky130_fd_sc_hd__a22o_1 U7230 ( .A1(count_instr[3]), .A2(n5648), .B1(n5876), 
        .B2(n5794), .X(n4112) );
  sky130_fd_sc_hd__xnor2_1 U7231 ( .A(n5878), .B(n5877), .Y(n5879) );
  sky130_fd_sc_hd__a22o_1 U7232 ( .A1(count_instr[2]), .A2(n5648), .B1(n5794), 
        .B2(n5879), .X(n4113) );
  sky130_fd_sc_hd__xnor2_1 U7233 ( .A(count_instr[0]), .B(n5880), .Y(n5881) );
  sky130_fd_sc_hd__a22o_1 U7234 ( .A1(count_instr[1]), .A2(n5648), .B1(n5794), 
        .B2(n5881), .X(n4114) );
  sky130_fd_sc_hd__nand2_1 U7235 ( .A(n5648), .B(count_instr[0]), .Y(n5882) );
  sky130_fd_sc_hd__o21ai_1 U7236 ( .A1(count_instr[0]), .A2(n5883), .B1(n5882), 
        .Y(n4115) );
  sky130_fd_sc_hd__xor2_1 U7237 ( .A(n5885), .B(n5884), .X(n5886) );
  sky130_fd_sc_hd__a22o_1 U7238 ( .A1(count_instr[34]), .A2(n5648), .B1(n5886), 
        .B2(n5794), .X(n4081) );
  sky130_fd_sc_hd__nor2_1 U7239 ( .A(n10060), .B(count_cycle[0]), .Y(N890) );
  sky130_fd_sc_hd__a222oi_1 U7240 ( .A1(n10086), .A2(decoded_imm_j[2]), .B1(
        n10087), .B2(mem_rdata_q[22]), .C1(mem_rdata[22]), .C2(n7928), .Y(
        n5887) );
  sky130_fd_sc_hd__a222oi_1 U7241 ( .A1(n10086), .A2(decoded_imm_j[4]), .B1(
        n10087), .B2(mem_rdata_q[24]), .C1(mem_rdata[24]), .C2(n7928), .Y(
        n5888) );
  sky130_fd_sc_hd__a222oi_1 U7242 ( .A1(n10086), .A2(decoded_imm_j[3]), .B1(
        n10087), .B2(mem_rdata_q[23]), .C1(mem_rdata[23]), .C2(n7928), .Y(
        n5889) );
  sky130_fd_sc_hd__nor2_1 U7243 ( .A(mem_do_prefetch), .B(n5891), .Y(n5890) );
  sky130_fd_sc_hd__nand2_1 U7244 ( .A(n9531), .B(resetn), .Y(n9526) );
  sky130_fd_sc_hd__a211oi_1 U7245 ( .A1(instr_jalr), .A2(n5891), .B1(n5890), 
        .C1(n9526), .Y(n2799) );
  sky130_fd_sc_hd__nor2_1 U7246 ( .A(n5892), .B(n10106), .Y(n5893) );
  sky130_fd_sc_hd__nand2b_1 U7247 ( .A_N(n5894), .B(n5893), .Y(n10116) );
  sky130_fd_sc_hd__o22ai_1 U7248 ( .A1(n5983), .A2(n5895), .B1(n8081), .B2(
        n10116), .Y(n2897) );
  sky130_fd_sc_hd__nand2_1 U7249 ( .A(mem_rdata_q[12]), .B(n10102), .Y(n5897)
         );
  sky130_fd_sc_hd__nand2_1 U7250 ( .A(n5896), .B(mem_rdata_q[30]), .Y(n6033)
         );
  sky130_fd_sc_hd__o22ai_1 U7251 ( .A1(n5898), .A2(n10052), .B1(n5897), .B2(
        n6033), .Y(n3968) );
  sky130_fd_sc_hd__a21oi_1 U7252 ( .A1(mem_do_rdata), .A2(n5899), .B1(n10030), 
        .Y(n5900) );
  sky130_fd_sc_hd__nor2_1 U7253 ( .A(n10060), .B(n5900), .Y(n2928) );
  sky130_fd_sc_hd__nand2_1 U7254 ( .A(mem_wordsize[1]), .B(mem_wordsize[0]), 
        .Y(n4150) );
  sky130_fd_sc_hd__o21a_1 U7255 ( .A1(pcpi_rs1[0]), .A2(mem_wordsize[0]), .B1(
        mem_wordsize[1]), .X(n5901) );
  sky130_fd_sc_hd__nor2_1 U7256 ( .A(n9907), .B(n5901), .Y(n10018) );
  sky130_fd_sc_hd__nand2_1 U7257 ( .A(n10018), .B(n10027), .Y(n5903) );
  sky130_fd_sc_hd__clkinv_1 U7258 ( .A(n5901), .Y(n5902) );
  sky130_fd_sc_hd__nand2_1 U7259 ( .A(n5903), .B(n5902), .Y(n10017) );
  sky130_fd_sc_hd__clkinv_1 U7260 ( .A(n5903), .Y(n9853) );
  sky130_fd_sc_hd__clkinv_1 U7261 ( .A(mem_rdata[31]), .Y(n10028) );
  sky130_fd_sc_hd__clkinv_1 U7262 ( .A(n9887), .Y(n5904) );
  sky130_fd_sc_hd__nand3_1 U7263 ( .A(pcpi_rs1[1]), .B(pcpi_rs1[0]), .C(n5904), 
        .Y(n9851) );
  sky130_fd_sc_hd__nand3_1 U7264 ( .A(pcpi_rs1[0]), .B(n9907), .C(n5904), .Y(
        n9850) );
  sky130_fd_sc_hd__o22ai_1 U7265 ( .A1(n10028), .A2(n9851), .B1(n5908), .B2(
        n9850), .Y(n5905) );
  sky130_fd_sc_hd__a21oi_1 U7266 ( .A1(mem_rdata[23]), .A2(n9853), .B1(n5905), 
        .Y(n5906) );
  sky130_fd_sc_hd__o21ai_1 U7267 ( .A1(n10017), .A2(n5907), .B1(n5906), .Y(
        n4158) );
  sky130_fd_sc_hd__nand3_1 U7268 ( .A(pcpi_rs1[1]), .B(mem_wordsize[0]), .C(
        n9905), .Y(n8121) );
  sky130_fd_sc_hd__nand2_1 U7269 ( .A(n9905), .B(n8121), .Y(n8122) );
  sky130_fd_sc_hd__o22ai_1 U7270 ( .A1(n5908), .A2(n8122), .B1(n10028), .B2(
        n8121), .Y(n4166) );
  sky130_fd_sc_hd__nor2_1 U7271 ( .A(decoded_imm[29]), .B(reg_pc[29]), .Y(
        n6039) );
  sky130_fd_sc_hd__nor2_1 U7272 ( .A(decoded_imm[21]), .B(reg_pc[21]), .Y(
        n6585) );
  sky130_fd_sc_hd__nor2_1 U7273 ( .A(decoded_imm[20]), .B(reg_pc[20]), .Y(
        n6583) );
  sky130_fd_sc_hd__nor2_1 U7274 ( .A(n6585), .B(n6583), .Y(n7043) );
  sky130_fd_sc_hd__nor2_1 U7275 ( .A(decoded_imm[23]), .B(reg_pc[23]), .Y(
        n7050) );
  sky130_fd_sc_hd__nor2_1 U7276 ( .A(decoded_imm[22]), .B(reg_pc[22]), .Y(
        n7048) );
  sky130_fd_sc_hd__nor2_1 U7277 ( .A(n7050), .B(n7048), .Y(n5929) );
  sky130_fd_sc_hd__nand2_1 U7278 ( .A(n7043), .B(n5929), .Y(n5931) );
  sky130_fd_sc_hd__nor2_1 U7279 ( .A(decoded_imm[17]), .B(reg_pc[17]), .Y(
        n6481) );
  sky130_fd_sc_hd__nor2_1 U7280 ( .A(decoded_imm[16]), .B(reg_pc[16]), .Y(
        n6479) );
  sky130_fd_sc_hd__nor2_1 U7281 ( .A(n6481), .B(n6479), .Y(n6966) );
  sky130_fd_sc_hd__nor2_1 U7282 ( .A(decoded_imm[19]), .B(reg_pc[19]), .Y(
        n6962) );
  sky130_fd_sc_hd__nor2_1 U7283 ( .A(decoded_imm[18]), .B(reg_pc[18]), .Y(
        n7699) );
  sky130_fd_sc_hd__nor2_1 U7284 ( .A(n6962), .B(n7699), .Y(n5927) );
  sky130_fd_sc_hd__nand2_1 U7285 ( .A(n6966), .B(n5927), .Y(n6579) );
  sky130_fd_sc_hd__nor2_1 U7286 ( .A(n5931), .B(n6579), .Y(n6674) );
  sky130_fd_sc_hd__nor2_1 U7287 ( .A(decoded_imm[27]), .B(reg_pc[27]), .Y(
        n7135) );
  sky130_fd_sc_hd__nor2_1 U7288 ( .A(decoded_imm[25]), .B(reg_pc[25]), .Y(
        n6670) );
  sky130_fd_sc_hd__nor2_1 U7289 ( .A(decoded_imm[24]), .B(reg_pc[24]), .Y(
        n7438) );
  sky130_fd_sc_hd__nor2_1 U7290 ( .A(n6670), .B(n7438), .Y(n7568) );
  sky130_fd_sc_hd__nand2_1 U7291 ( .A(n7568), .B(n7571), .Y(n7131) );
  sky130_fd_sc_hd__nor2_1 U7292 ( .A(n7135), .B(n7131), .Y(n5934) );
  sky130_fd_sc_hd__nand2_1 U7293 ( .A(n6674), .B(n5934), .Y(n5936) );
  sky130_fd_sc_hd__nor2_1 U7294 ( .A(n5911), .B(n8191), .Y(n5914) );
  sky130_fd_sc_hd__nand2_1 U7295 ( .A(n5909), .B(n5914), .Y(n5917) );
  sky130_fd_sc_hd__o21ai_1 U7296 ( .A1(n8192), .A2(n5911), .B1(n5910), .Y(
        n5912) );
  sky130_fd_sc_hd__a21oi_1 U7297 ( .A1(n5914), .A2(n5913), .B1(n5912), .Y(
        n5915) );
  sky130_fd_sc_hd__o21ai_1 U7298 ( .A1(n5917), .A2(n5916), .B1(n5915), .Y(
        n6247) );
  sky130_fd_sc_hd__nor2_1 U7299 ( .A(decoded_imm[13]), .B(reg_pc[13]), .Y(
        n6340) );
  sky130_fd_sc_hd__nor2_1 U7300 ( .A(decoded_imm[12]), .B(reg_pc[12]), .Y(
        n6338) );
  sky130_fd_sc_hd__nor2_1 U7301 ( .A(n6340), .B(n6338), .Y(n6863) );
  sky130_fd_sc_hd__nor2_1 U7302 ( .A(decoded_imm[15]), .B(reg_pc[15]), .Y(
        n6870) );
  sky130_fd_sc_hd__nor2_1 U7303 ( .A(decoded_imm[14]), .B(reg_pc[14]), .Y(
        n6868) );
  sky130_fd_sc_hd__nor2_1 U7304 ( .A(n6870), .B(n6868), .Y(n5921) );
  sky130_fd_sc_hd__nand2_1 U7305 ( .A(n6863), .B(n5921), .Y(n5923) );
  sky130_fd_sc_hd__nor2_1 U7306 ( .A(decoded_imm[9]), .B(reg_pc[9]), .Y(n6244)
         );
  sky130_fd_sc_hd__nor2_1 U7307 ( .A(decoded_imm[8]), .B(reg_pc[8]), .Y(n8123)
         );
  sky130_fd_sc_hd__nor2_1 U7308 ( .A(n6244), .B(n8123), .Y(n7957) );
  sky130_fd_sc_hd__nor2_1 U7309 ( .A(decoded_imm[11]), .B(reg_pc[11]), .Y(
        n7963) );
  sky130_fd_sc_hd__nor2_1 U7310 ( .A(decoded_imm[10]), .B(reg_pc[10]), .Y(
        n7961) );
  sky130_fd_sc_hd__nor2_1 U7311 ( .A(n7963), .B(n7961), .Y(n5919) );
  sky130_fd_sc_hd__nand2_1 U7312 ( .A(n7957), .B(n5919), .Y(n6337) );
  sky130_fd_sc_hd__nor2_1 U7313 ( .A(n5923), .B(n6337), .Y(n5925) );
  sky130_fd_sc_hd__nand2_1 U7314 ( .A(reg_pc[8]), .B(decoded_imm[8]), .Y(n8124) );
  sky130_fd_sc_hd__nand2_1 U7315 ( .A(reg_pc[9]), .B(decoded_imm[9]), .Y(n6245) );
  sky130_fd_sc_hd__o21ai_1 U7316 ( .A1(n8124), .A2(n6244), .B1(n6245), .Y(
        n7958) );
  sky130_fd_sc_hd__nand2_1 U7317 ( .A(reg_pc[10]), .B(decoded_imm[10]), .Y(
        n8058) );
  sky130_fd_sc_hd__nand2_1 U7318 ( .A(reg_pc[11]), .B(decoded_imm[11]), .Y(
        n7964) );
  sky130_fd_sc_hd__o21ai_1 U7319 ( .A1(n8058), .A2(n7963), .B1(n7964), .Y(
        n5918) );
  sky130_fd_sc_hd__a21oi_1 U7320 ( .A1(n5919), .A2(n7958), .B1(n5918), .Y(
        n6336) );
  sky130_fd_sc_hd__nand2_1 U7321 ( .A(reg_pc[12]), .B(decoded_imm[12]), .Y(
        n7870) );
  sky130_fd_sc_hd__nand2_1 U7322 ( .A(reg_pc[13]), .B(decoded_imm[13]), .Y(
        n6341) );
  sky130_fd_sc_hd__o21ai_1 U7323 ( .A1(n7870), .A2(n6340), .B1(n6341), .Y(
        n6865) );
  sky130_fd_sc_hd__nand2_1 U7324 ( .A(reg_pc[14]), .B(decoded_imm[14]), .Y(
        n7785) );
  sky130_fd_sc_hd__nand2_1 U7325 ( .A(reg_pc[15]), .B(decoded_imm[15]), .Y(
        n6871) );
  sky130_fd_sc_hd__o21ai_1 U7326 ( .A1(n7785), .A2(n6870), .B1(n6871), .Y(
        n5920) );
  sky130_fd_sc_hd__a21oi_1 U7327 ( .A1(n5921), .A2(n6865), .B1(n5920), .Y(
        n5922) );
  sky130_fd_sc_hd__o21ai_1 U7328 ( .A1(n5923), .A2(n6336), .B1(n5922), .Y(
        n5924) );
  sky130_fd_sc_hd__a21oi_1 U7329 ( .A1(n6247), .A2(n5925), .B1(n5924), .Y(
        n6478) );
  sky130_fd_sc_hd__nand2_1 U7330 ( .A(reg_pc[16]), .B(decoded_imm[16]), .Y(
        n7219) );
  sky130_fd_sc_hd__nand2_1 U7331 ( .A(reg_pc[17]), .B(decoded_imm[17]), .Y(
        n6482) );
  sky130_fd_sc_hd__o21ai_1 U7332 ( .A1(n7219), .A2(n6481), .B1(n6482), .Y(
        n6965) );
  sky130_fd_sc_hd__nand2_1 U7333 ( .A(reg_pc[18]), .B(decoded_imm[18]), .Y(
        n7700) );
  sky130_fd_sc_hd__nand2_1 U7334 ( .A(reg_pc[19]), .B(decoded_imm[19]), .Y(
        n6963) );
  sky130_fd_sc_hd__o21ai_1 U7335 ( .A1(n7700), .A2(n6962), .B1(n6963), .Y(
        n5926) );
  sky130_fd_sc_hd__a21oi_1 U7336 ( .A1(n5927), .A2(n6965), .B1(n5926), .Y(
        n6580) );
  sky130_fd_sc_hd__nand2_1 U7337 ( .A(reg_pc[20]), .B(decoded_imm[20]), .Y(
        n7320) );
  sky130_fd_sc_hd__nand2_1 U7338 ( .A(reg_pc[21]), .B(decoded_imm[21]), .Y(
        n6586) );
  sky130_fd_sc_hd__o21ai_1 U7339 ( .A1(n7320), .A2(n6585), .B1(n6586), .Y(
        n7044) );
  sky130_fd_sc_hd__nand2_1 U7340 ( .A(reg_pc[22]), .B(decoded_imm[22]), .Y(
        n7617) );
  sky130_fd_sc_hd__nand2_1 U7341 ( .A(reg_pc[23]), .B(decoded_imm[23]), .Y(
        n7051) );
  sky130_fd_sc_hd__o21ai_1 U7342 ( .A1(n7617), .A2(n7050), .B1(n7051), .Y(
        n5928) );
  sky130_fd_sc_hd__a21oi_1 U7343 ( .A1(n5929), .A2(n7044), .B1(n5928), .Y(
        n5930) );
  sky130_fd_sc_hd__o21ai_1 U7344 ( .A1(n5931), .A2(n6580), .B1(n5930), .Y(
        n6673) );
  sky130_fd_sc_hd__nand2_1 U7345 ( .A(reg_pc[24]), .B(decoded_imm[24]), .Y(
        n7439) );
  sky130_fd_sc_hd__nand2_1 U7346 ( .A(reg_pc[25]), .B(decoded_imm[25]), .Y(
        n6671) );
  sky130_fd_sc_hd__o21ai_1 U7347 ( .A1(n7439), .A2(n6670), .B1(n6671), .Y(
        n7567) );
  sky130_fd_sc_hd__nand2_1 U7348 ( .A(reg_pc[26]), .B(decoded_imm[26]), .Y(
        n7570) );
  sky130_fd_sc_hd__a21oi_1 U7349 ( .A1(n7567), .A2(n7571), .B1(n5932), .Y(
        n7132) );
  sky130_fd_sc_hd__nand2_1 U7350 ( .A(reg_pc[27]), .B(decoded_imm[27]), .Y(
        n7136) );
  sky130_fd_sc_hd__o21ai_1 U7351 ( .A1(n7135), .A2(n7132), .B1(n7136), .Y(
        n5933) );
  sky130_fd_sc_hd__a21oi_1 U7352 ( .A1(n6673), .A2(n5934), .B1(n5933), .Y(
        n5935) );
  sky130_fd_sc_hd__o21ai_1 U7353 ( .A1(n5936), .A2(n6478), .B1(n5935), .Y(
        n7558) );
  sky130_fd_sc_hd__nand2_1 U7354 ( .A(reg_pc[28]), .B(decoded_imm[28]), .Y(
        n7556) );
  sky130_fd_sc_hd__a21oi_1 U7355 ( .A1(n7558), .A2(n7557), .B1(n5937), .Y(
        n6043) );
  sky130_fd_sc_hd__nand2_1 U7356 ( .A(reg_pc[29]), .B(decoded_imm[29]), .Y(
        n6040) );
  sky130_fd_sc_hd__o21ai_1 U7357 ( .A1(n6039), .A2(n6043), .B1(n6040), .Y(
        n5970) );
  sky130_fd_sc_hd__nand2_1 U7358 ( .A(reg_pc[30]), .B(decoded_imm[30]), .Y(
        n5968) );
  sky130_fd_sc_hd__a21oi_1 U7359 ( .A1(n5970), .A2(n5969), .B1(n5938), .Y(
        n5942) );
  sky130_fd_sc_hd__nand2_1 U7360 ( .A(reg_pc[31]), .B(decoded_imm[31]), .Y(
        n5939) );
  sky130_fd_sc_hd__nand2_1 U7361 ( .A(n5940), .B(n5939), .Y(n5941) );
  sky130_fd_sc_hd__xor2_1 U7362 ( .A(n5942), .B(n5941), .X(n5943) );
  sky130_fd_sc_hd__nand2_1 U7363 ( .A(n5943), .B(n4639), .Y(n5952) );
  sky130_fd_sc_hd__a22oi_1 U7364 ( .A1(n9861), .A2(count_cycle[63]), .B1(n9860), .B2(count_cycle[31]), .Y(n5951) );
  sky130_fd_sc_hd__nor2_1 U7365 ( .A(n5944), .B(latched_is_lh), .Y(n5945) );
  sky130_fd_sc_hd__nand4_1 U7366 ( .A(n9859), .B(n5945), .C(latched_is_lb), 
        .D(n5947), .Y(n8131) );
  sky130_fd_sc_hd__nand4_1 U7367 ( .A(n9859), .B(latched_is_lh), .C(
        mem_rdata_word[15]), .D(n5947), .Y(n5946) );
  sky130_fd_sc_hd__a22o_1 U7368 ( .A1(pcpi_rs1[31]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[31]), .X(n5948) );
  sky130_fd_sc_hd__a211oi_1 U7369 ( .A1(n9857), .A2(count_instr[31]), .B1(
        n7707), .C1(n5948), .Y(n5950) );
  sky130_fd_sc_hd__nand2_1 U7370 ( .A(n9856), .B(count_instr[63]), .Y(n5949)
         );
  sky130_fd_sc_hd__nand4_1 U7371 ( .A(n5952), .B(n5951), .C(n5950), .D(n5949), 
        .Y(N1908) );
  sky130_fd_sc_hd__clkinv_1 U7372 ( .A(mem_rdata[3]), .Y(n5955) );
  sky130_fd_sc_hd__o22ai_1 U7373 ( .A1(n10023), .A2(n9851), .B1(n9850), .B2(
        n10079), .Y(n5953) );
  sky130_fd_sc_hd__a21oi_1 U7374 ( .A1(mem_rdata[19]), .A2(n9853), .B1(n5953), 
        .Y(n5954) );
  sky130_fd_sc_hd__o21ai_1 U7375 ( .A1(n5955), .A2(n10017), .B1(n5954), .Y(
        n4154) );
  sky130_fd_sc_hd__nand2_1 U7376 ( .A(n5958), .B(n5957), .Y(n5960) );
  sky130_fd_sc_hd__o21ai_1 U7377 ( .A1(n9352), .A2(n9356), .B1(n9353), .Y(
        n5959) );
  sky130_fd_sc_hd__xnor2_1 U7378 ( .A(n5960), .B(n5959), .Y(n5961) );
  sky130_fd_sc_hd__nand2_1 U7379 ( .A(n5961), .B(n4639), .Y(n5966) );
  sky130_fd_sc_hd__a22o_1 U7380 ( .A1(n9859), .A2(mem_rdata_word[3]), .B1(
        n9858), .B2(pcpi_rs1[3]), .X(n5962) );
  sky130_fd_sc_hd__a21oi_1 U7381 ( .A1(n9861), .A2(count_cycle[35]), .B1(n5962), .Y(n5965) );
  sky130_fd_sc_hd__a22oi_1 U7382 ( .A1(n9857), .A2(count_instr[3]), .B1(n9856), 
        .B2(count_instr[35]), .Y(n5964) );
  sky130_fd_sc_hd__nand2_1 U7383 ( .A(n9860), .B(count_cycle[3]), .Y(n5963) );
  sky130_fd_sc_hd__nand4_1 U7384 ( .A(n5966), .B(n5965), .C(n5964), .D(n5963), 
        .Y(N1880) );
  sky130_fd_sc_hd__a21oi_1 U7385 ( .A1(n9012), .A2(n5967), .B1(n10029), .Y(
        n4117) );
  sky130_fd_sc_hd__nand2_1 U7386 ( .A(n5969), .B(n5968), .Y(n5971) );
  sky130_fd_sc_hd__xnor2_1 U7387 ( .A(n5971), .B(n5970), .Y(n5972) );
  sky130_fd_sc_hd__nand2_1 U7388 ( .A(n5972), .B(n4639), .Y(n5977) );
  sky130_fd_sc_hd__a22oi_1 U7389 ( .A1(n9861), .A2(count_cycle[62]), .B1(n9860), .B2(count_cycle[30]), .Y(n5976) );
  sky130_fd_sc_hd__a22o_1 U7390 ( .A1(n9858), .A2(pcpi_rs1[30]), .B1(n7705), 
        .B2(mem_rdata_word[30]), .X(n5973) );
  sky130_fd_sc_hd__a211oi_1 U7391 ( .A1(n9857), .A2(count_instr[30]), .B1(
        n7707), .C1(n5973), .Y(n5975) );
  sky130_fd_sc_hd__nand2_1 U7392 ( .A(n9856), .B(count_instr[62]), .Y(n5974)
         );
  sky130_fd_sc_hd__nand4_1 U7393 ( .A(n5977), .B(n5976), .C(n5975), .D(n5974), 
        .Y(N1907) );
  sky130_fd_sc_hd__a222oi_1 U7394 ( .A1(n10086), .A2(decoded_imm_j[31]), .B1(
        n10087), .B2(mem_rdata_q[31]), .C1(mem_rdata[31]), .C2(n7928), .Y(
        n5978) );
  sky130_fd_sc_hd__nor2_1 U7395 ( .A(instr_jalr), .B(n10122), .Y(n5979) );
  sky130_fd_sc_hd__and3_1 U7396 ( .A(n5981), .B(n5982), .C(n5979), .X(n8020)
         );
  sky130_fd_sc_hd__nand2_1 U7397 ( .A(n10111), .B(n10034), .Y(n5980) );
  sky130_fd_sc_hd__nand2_1 U7398 ( .A(n8020), .B(n5980), .Y(n8359) );
  sky130_fd_sc_hd__nand2_1 U7399 ( .A(n5981), .B(n10119), .Y(n5984) );
  sky130_fd_sc_hd__nand3_1 U7400 ( .A(n5984), .B(n5983), .C(n5982), .Y(n8613)
         );
  sky130_fd_sc_hd__nand2_1 U7401 ( .A(n8359), .B(n8613), .Y(n8262) );
  sky130_fd_sc_hd__nand2_1 U7402 ( .A(n8262), .B(mem_rdata_q[31]), .Y(n7930)
         );
  sky130_fd_sc_hd__nor2_1 U7403 ( .A(n5985), .B(n10122), .Y(n8608) );
  sky130_fd_sc_hd__and2_1 U7404 ( .A(n7930), .B(n5986), .X(n8437) );
  sky130_fd_sc_hd__nor3_1 U7405 ( .A(n5988), .B(n10122), .C(n5987), .Y(n5989)
         );
  sky130_fd_sc_hd__a22oi_1 U7406 ( .A1(decoded_imm[30]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[30]), .Y(n5990) );
  sky130_fd_sc_hd__nand2_1 U7407 ( .A(n8437), .B(n5990), .Y(n2842) );
  sky130_fd_sc_hd__nor3_1 U7408 ( .A(is_slli_srli_srai), .B(
        is_lb_lh_lw_lbu_lhu), .C(is_jalr_addi_slti_sltiu_xori_ori_andi), .Y(
        n5992) );
  sky130_fd_sc_hd__nand3_1 U7409 ( .A(n6029), .B(n5992), .C(n5991), .Y(n9513)
         );
  sky130_fd_sc_hd__nor2_1 U7410 ( .A(n9532), .B(n9513), .Y(n9538) );
  sky130_fd_sc_hd__nand2_1 U7411 ( .A(decoded_imm_j[3]), .B(decoded_imm_j[2]), 
        .Y(n6002) );
  sky130_fd_sc_hd__nor2_1 U7412 ( .A(decoded_imm_j[4]), .B(n6002), .Y(n8661)
         );
  sky130_fd_sc_hd__nand2_1 U7413 ( .A(decoded_imm_j[11]), .B(decoded_imm_j[1]), 
        .Y(n6015) );
  sky130_fd_sc_hd__nand2_1 U7414 ( .A(n5993), .B(decoded_imm_j[4]), .Y(n5994)
         );
  sky130_fd_sc_hd__a22oi_1 U7415 ( .A1(n8501), .A2(\cpuregs[15][30] ), .B1(
        n6412), .B2(\cpuregs[19][30] ), .Y(n5999) );
  sky130_fd_sc_hd__nor2_1 U7416 ( .A(decoded_imm_j[1]), .B(n9227), .Y(n8649)
         );
  sky130_fd_sc_hd__nand2_1 U7417 ( .A(n5993), .B(n9432), .Y(n6000) );
  sky130_fd_sc_hd__nor2_1 U7418 ( .A(n6015), .B(n6019), .Y(n8481) );
  sky130_fd_sc_hd__a22oi_1 U7419 ( .A1(\cpuregs[13][30] ), .A2(n8478), .B1(
        n8481), .B2(\cpuregs[11][30] ), .Y(n5998) );
  sky130_fd_sc_hd__nand3_1 U7420 ( .A(n6004), .B(decoded_imm_j[4]), .C(
        decoded_imm_j[2]), .Y(n6009) );
  sky130_fd_sc_hd__nor2_1 U7421 ( .A(decoded_imm_j[1]), .B(decoded_imm_j[11]), 
        .Y(n8650) );
  sky130_fd_sc_hd__nor2_4 U7422 ( .A(n6004), .B(n5994), .Y(n8656) );
  sky130_fd_sc_hd__nor2_1 U7423 ( .A(n6016), .B(n6017), .Y(n8503) );
  sky130_fd_sc_hd__a22oi_1 U7424 ( .A1(\cpuregs[20][30] ), .A2(n6059), .B1(
        n8503), .B2(\cpuregs[24][30] ), .Y(n5997) );
  sky130_fd_sc_hd__nor2_1 U7425 ( .A(decoded_imm_j[11]), .B(n5995), .Y(n8668)
         );
  sky130_fd_sc_hd__inv_2 U7426 ( .A(n8668), .Y(n6018) );
  sky130_fd_sc_hd__nor2_1 U7427 ( .A(n6018), .B(n6019), .Y(n8470) );
  sky130_fd_sc_hd__nand2_1 U7428 ( .A(n8470), .B(\cpuregs[10][30] ), .Y(n5996)
         );
  sky130_fd_sc_hd__nand4_1 U7429 ( .A(n5999), .B(n5998), .C(n5997), .D(n5996), 
        .Y(n6028) );
  sky130_fd_sc_hd__and2_1 U7430 ( .A(n8661), .B(n8668), .X(n8498) );
  sky130_fd_sc_hd__inv_2 U7431 ( .A(n8649), .Y(n6020) );
  sky130_fd_sc_hd__a22oi_1 U7432 ( .A1(\cpuregs[14][30] ), .A2(n8498), .B1(
        n8488), .B2(\cpuregs[1][30] ), .Y(n6008) );
  sky130_fd_sc_hd__nor2_1 U7433 ( .A(n9432), .B(n6002), .Y(n8662) );
  sky130_fd_sc_hd__a22oi_1 U7434 ( .A1(\cpuregs[30][30] ), .A2(n8500), .B1(
        n8479), .B2(\cpuregs[2][30] ), .Y(n6007) );
  sky130_fd_sc_hd__a22oi_1 U7435 ( .A1(\cpuregs[31][30] ), .A2(n8487), .B1(
        n8499), .B2(\cpuregs[3][30] ), .Y(n6006) );
  sky130_fd_sc_hd__nand3_1 U7436 ( .A(n6004), .B(n9432), .C(decoded_imm_j[2]), 
        .Y(n6014) );
  sky130_fd_sc_hd__a22oi_1 U7437 ( .A1(\cpuregs[4][30] ), .A2(n8492), .B1(
        n8489), .B2(\cpuregs[17][30] ), .Y(n6005) );
  sky130_fd_sc_hd__nand4_1 U7438 ( .A(n6008), .B(n6007), .C(n6006), .D(n6005), 
        .Y(n6027) );
  sky130_fd_sc_hd__nor2_1 U7439 ( .A(n6020), .B(n6017), .Y(n8466) );
  sky130_fd_sc_hd__a22oi_1 U7440 ( .A1(\cpuregs[21][30] ), .A2(n8480), .B1(
        n8466), .B2(\cpuregs[25][30] ), .Y(n6013) );
  sky130_fd_sc_hd__a22oi_1 U7441 ( .A1(\cpuregs[23][30] ), .A2(n8464), .B1(
        n8502), .B2(\cpuregs[6][30] ), .Y(n6012) );
  sky130_fd_sc_hd__and2_1 U7442 ( .A(n8662), .B(n8649), .X(n6137) );
  sky130_fd_sc_hd__a22oi_1 U7443 ( .A1(n6137), .A2(\cpuregs[29][30] ), .B1(
        n8465), .B2(\cpuregs[16][30] ), .Y(n6011) );
  sky130_fd_sc_hd__nor2_1 U7444 ( .A(n6015), .B(n6017), .Y(n8497) );
  sky130_fd_sc_hd__a22oi_1 U7445 ( .A1(\cpuregs[5][30] ), .A2(n8471), .B1(
        n8497), .B2(\cpuregs[27][30] ), .Y(n6010) );
  sky130_fd_sc_hd__nand4_1 U7446 ( .A(n6013), .B(n6012), .C(n6011), .D(n6010), 
        .Y(n6026) );
  sky130_fd_sc_hd__a22oi_1 U7447 ( .A1(\cpuregs[7][30] ), .A2(n8477), .B1(
        n4233), .B2(\cpuregs[8][30] ), .Y(n6024) );
  sky130_fd_sc_hd__a22oi_1 U7448 ( .A1(\cpuregs[22][30] ), .A2(n8482), .B1(
        n8472), .B2(\cpuregs[18][30] ), .Y(n6023) );
  sky130_fd_sc_hd__and2_1 U7449 ( .A(n8661), .B(n8650), .X(n8491) );
  sky130_fd_sc_hd__a22oi_1 U7450 ( .A1(n8491), .A2(\cpuregs[12][30] ), .B1(
        \cpuregs[28][30] ), .B2(n8490), .Y(n6022) );
  sky130_fd_sc_hd__nor2_1 U7451 ( .A(n6018), .B(n6017), .Y(n8467) );
  sky130_fd_sc_hd__nor2_1 U7452 ( .A(n6020), .B(n6019), .Y(n8036) );
  sky130_fd_sc_hd__a22oi_1 U7453 ( .A1(n8467), .A2(\cpuregs[26][30] ), .B1(
        n8036), .B2(\cpuregs[9][30] ), .Y(n6021) );
  sky130_fd_sc_hd__nand4_1 U7454 ( .A(n6024), .B(n6023), .C(n6022), .D(n6021), 
        .Y(n6025) );
  sky130_fd_sc_hd__nor4_1 U7455 ( .A(n6028), .B(n6027), .C(n6026), .D(n6025), 
        .Y(n6032) );
  sky130_fd_sc_hd__a32oi_1 U7456 ( .A1(is_jalr_addi_slti_sltiu_xori_ori_andi), 
        .A2(n6029), .A3(n10118), .B1(is_lui_auipc_jal), .B2(n6029), .Y(n9533)
         );
  sky130_fd_sc_hd__nor3_1 U7457 ( .A(n9512), .B(n9533), .C(n6030), .Y(n7385)
         );
  sky130_fd_sc_hd__a22oi_1 U7458 ( .A1(pcpi_rs2[30]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[30]), .Y(n6031) );
  sky130_fd_sc_hd__o21ai_1 U7459 ( .A1(n8514), .A2(n6032), .B1(n6031), .Y(
        n3928) );
  sky130_fd_sc_hd__o22ai_1 U7460 ( .A1(n10052), .A2(n6035), .B1(n6034), .B2(
        n6033), .Y(n3974) );
  sky130_fd_sc_hd__nor2_1 U7461 ( .A(instr_sltu), .B(instr_sltiu), .Y(n6037)
         );
  sky130_fd_sc_hd__nor2_1 U7462 ( .A(instr_slt), .B(instr_slti), .Y(n6036) );
  sky130_fd_sc_hd__a31oi_1 U7463 ( .A1(n6037), .A2(n6036), .A3(n10034), .B1(
        n10052), .Y(N351) );
  sky130_fd_sc_hd__a22o_1 U7464 ( .A1(n10055), .A2(n6038), .B1(n9530), .B2(
        reg_pc[30]), .X(n3989) );
  sky130_fd_sc_hd__nand2_1 U7465 ( .A(n6041), .B(n6040), .Y(n6042) );
  sky130_fd_sc_hd__xor2_1 U7466 ( .A(n6043), .B(n6042), .X(n6044) );
  sky130_fd_sc_hd__nand2_1 U7467 ( .A(n6044), .B(n4639), .Y(n6049) );
  sky130_fd_sc_hd__a22oi_1 U7468 ( .A1(n9861), .A2(count_cycle[61]), .B1(n9860), .B2(count_cycle[29]), .Y(n6048) );
  sky130_fd_sc_hd__a22o_1 U7469 ( .A1(pcpi_rs1[29]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[29]), .X(n6045) );
  sky130_fd_sc_hd__a211oi_1 U7470 ( .A1(n9857), .A2(count_instr[29]), .B1(
        n7707), .C1(n6045), .Y(n6047) );
  sky130_fd_sc_hd__nand2_1 U7471 ( .A(n9856), .B(count_instr[61]), .Y(n6046)
         );
  sky130_fd_sc_hd__nand4_1 U7472 ( .A(n6049), .B(n6048), .C(n6047), .D(n6046), 
        .Y(N1906) );
  sky130_fd_sc_hd__a22oi_1 U7473 ( .A1(decoded_imm[29]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[29]), .Y(n6050) );
  sky130_fd_sc_hd__nand2_1 U7474 ( .A(n8437), .B(n6050), .Y(n2843) );
  sky130_fd_sc_hd__a22oi_1 U7475 ( .A1(n4233), .A2(\cpuregs[8][29] ), .B1(
        \cpuregs[2][29] ), .B2(n8479), .Y(n6054) );
  sky130_fd_sc_hd__a22oi_1 U7476 ( .A1(n8491), .A2(\cpuregs[12][29] ), .B1(
        n8489), .B2(\cpuregs[17][29] ), .Y(n6053) );
  sky130_fd_sc_hd__a22oi_1 U7477 ( .A1(n8500), .A2(\cpuregs[30][29] ), .B1(
        n8472), .B2(\cpuregs[18][29] ), .Y(n6052) );
  sky130_fd_sc_hd__nand2_1 U7478 ( .A(n8467), .B(\cpuregs[26][29] ), .Y(n6051)
         );
  sky130_fd_sc_hd__nand4_1 U7479 ( .A(n6054), .B(n6053), .C(n6052), .D(n6051), 
        .Y(n6072) );
  sky130_fd_sc_hd__a22oi_1 U7480 ( .A1(n8492), .A2(\cpuregs[4][29] ), .B1(
        n8471), .B2(\cpuregs[5][29] ), .Y(n6058) );
  sky130_fd_sc_hd__a22oi_1 U7481 ( .A1(\cpuregs[6][29] ), .A2(n8502), .B1(
        n8488), .B2(\cpuregs[1][29] ), .Y(n6057) );
  sky130_fd_sc_hd__a22oi_1 U7482 ( .A1(\cpuregs[21][29] ), .A2(n8480), .B1(
        n8036), .B2(\cpuregs[9][29] ), .Y(n6056) );
  sky130_fd_sc_hd__a22oi_1 U7483 ( .A1(n6412), .A2(\cpuregs[19][29] ), .B1(
        n8466), .B2(\cpuregs[25][29] ), .Y(n6055) );
  sky130_fd_sc_hd__nand4_1 U7484 ( .A(n6058), .B(n6057), .C(n6056), .D(n6055), 
        .Y(n6071) );
  sky130_fd_sc_hd__a22oi_1 U7485 ( .A1(n8478), .A2(\cpuregs[13][29] ), .B1(
        \cpuregs[31][29] ), .B2(n8487), .Y(n6063) );
  sky130_fd_sc_hd__a22oi_1 U7486 ( .A1(n8481), .A2(\cpuregs[11][29] ), .B1(
        \cpuregs[10][29] ), .B2(n8470), .Y(n6062) );
  sky130_fd_sc_hd__a22oi_1 U7487 ( .A1(n6059), .A2(\cpuregs[20][29] ), .B1(
        n8490), .B2(\cpuregs[28][29] ), .Y(n6061) );
  sky130_fd_sc_hd__a22oi_1 U7488 ( .A1(n8498), .A2(\cpuregs[14][29] ), .B1(
        \cpuregs[15][29] ), .B2(n8501), .Y(n6060) );
  sky130_fd_sc_hd__nand4_1 U7489 ( .A(n6063), .B(n6062), .C(n6061), .D(n6060), 
        .Y(n6070) );
  sky130_fd_sc_hd__a22oi_1 U7490 ( .A1(n8465), .A2(\cpuregs[16][29] ), .B1(
        n8499), .B2(\cpuregs[3][29] ), .Y(n6068) );
  sky130_fd_sc_hd__a22oi_1 U7491 ( .A1(\cpuregs[7][29] ), .A2(n8477), .B1(
        n8497), .B2(\cpuregs[27][29] ), .Y(n6065) );
  sky130_fd_sc_hd__a22oi_1 U7492 ( .A1(\cpuregs[23][29] ), .A2(n8464), .B1(
        n6137), .B2(\cpuregs[29][29] ), .Y(n6064) );
  sky130_fd_sc_hd__nand2_1 U7493 ( .A(n6065), .B(n6064), .Y(n6066) );
  sky130_fd_sc_hd__nand2_1 U7494 ( .A(n6068), .B(n6067), .Y(n6069) );
  sky130_fd_sc_hd__nor4_1 U7495 ( .A(n6072), .B(n6071), .C(n6070), .D(n6069), 
        .Y(n6074) );
  sky130_fd_sc_hd__a22oi_1 U7496 ( .A1(pcpi_rs2[29]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[29]), .Y(n6073) );
  sky130_fd_sc_hd__o21ai_1 U7497 ( .A1(n8514), .A2(n6074), .B1(n6073), .Y(
        n3929) );
  sky130_fd_sc_hd__xor2_1 U7498 ( .A(n9017), .B(pcpi_rs2[29]), .X(n6075) );
  sky130_fd_sc_hd__nand2_1 U7499 ( .A(n6075), .B(pcpi_rs1[29]), .Y(n8674) );
  sky130_fd_sc_hd__nand2_1 U7500 ( .A(n8676), .B(n8674), .Y(n6119) );
  sky130_fd_sc_hd__xor2_1 U7501 ( .A(n9017), .B(pcpi_rs2[20]), .X(n6097) );
  sky130_fd_sc_hd__nor2_1 U7502 ( .A(pcpi_rs1[20]), .B(n6097), .Y(n7388) );
  sky130_fd_sc_hd__xor2_1 U7503 ( .A(n9017), .B(pcpi_rs2[19]), .X(n6096) );
  sky130_fd_sc_hd__nor2_1 U7504 ( .A(pcpi_rs1[19]), .B(n6096), .Y(n7393) );
  sky130_fd_sc_hd__nor2_1 U7505 ( .A(n7388), .B(n7393), .Y(n6660) );
  sky130_fd_sc_hd__xor2_1 U7506 ( .A(n9017), .B(pcpi_rs2[22]), .X(n6099) );
  sky130_fd_sc_hd__nor2_1 U7507 ( .A(pcpi_rs1[22]), .B(n6099), .Y(n7687) );
  sky130_fd_sc_hd__xor2_1 U7508 ( .A(n9017), .B(pcpi_rs2[21]), .X(n6098) );
  sky130_fd_sc_hd__nor2_1 U7509 ( .A(pcpi_rs1[21]), .B(n6098), .Y(n7692) );
  sky130_fd_sc_hd__nor2_1 U7510 ( .A(n7687), .B(n7692), .Y(n6101) );
  sky130_fd_sc_hd__nand2_1 U7511 ( .A(n6660), .B(n6101), .Y(n6103) );
  sky130_fd_sc_hd__xor2_1 U7512 ( .A(n9017), .B(pcpi_rs2[16]), .X(n6091) );
  sky130_fd_sc_hd__nor2_1 U7513 ( .A(pcpi_rs1[16]), .B(n6091), .Y(n7295) );
  sky130_fd_sc_hd__xor2_1 U7514 ( .A(n9017), .B(pcpi_rs2[15]), .X(n6090) );
  sky130_fd_sc_hd__nor2_1 U7515 ( .A(pcpi_rs1[15]), .B(n6090), .Y(n6945) );
  sky130_fd_sc_hd__nor2_1 U7516 ( .A(n7295), .B(n6945), .Y(n6568) );
  sky130_fd_sc_hd__xor2_1 U7517 ( .A(n9017), .B(pcpi_rs2[18]), .X(n6093) );
  sky130_fd_sc_hd__nor2_1 U7518 ( .A(pcpi_rs1[18]), .B(n6093), .Y(n7769) );
  sky130_fd_sc_hd__xor2_1 U7519 ( .A(n9017), .B(pcpi_rs2[17]), .X(n6092) );
  sky130_fd_sc_hd__nor2_1 U7520 ( .A(pcpi_rs1[17]), .B(n6092), .Y(n7774) );
  sky130_fd_sc_hd__nor2_1 U7521 ( .A(n7769), .B(n7774), .Y(n6095) );
  sky130_fd_sc_hd__nand2_1 U7522 ( .A(n6568), .B(n6095), .Y(n6658) );
  sky130_fd_sc_hd__nor2_1 U7523 ( .A(n6103), .B(n6658), .Y(n6152) );
  sky130_fd_sc_hd__xor2_1 U7524 ( .A(n9017), .B(pcpi_rs2[27]), .X(n6110) );
  sky130_fd_sc_hd__xor2_1 U7525 ( .A(n9017), .B(pcpi_rs2[28]), .X(n6111) );
  sky130_fd_sc_hd__nand2_1 U7526 ( .A(n7170), .B(n6160), .Y(n6114) );
  sky130_fd_sc_hd__xor2_1 U7527 ( .A(n9017), .B(pcpi_rs2[24]), .X(n6105) );
  sky130_fd_sc_hd__nor2_1 U7528 ( .A(pcpi_rs1[24]), .B(n6105), .Y(n7506) );
  sky130_fd_sc_hd__xor2_1 U7529 ( .A(n9017), .B(pcpi_rs2[23]), .X(n6104) );
  sky130_fd_sc_hd__nor2_1 U7530 ( .A(pcpi_rs1[23]), .B(n6104), .Y(n7511) );
  sky130_fd_sc_hd__nor2_1 U7531 ( .A(n7506), .B(n7511), .Y(n6746) );
  sky130_fd_sc_hd__xor2_1 U7532 ( .A(n9017), .B(pcpi_rs2[26]), .X(n6107) );
  sky130_fd_sc_hd__nor2_1 U7533 ( .A(pcpi_rs1[26]), .B(n6107), .Y(n7603) );
  sky130_fd_sc_hd__xor2_1 U7534 ( .A(n9017), .B(pcpi_rs2[25]), .X(n6106) );
  sky130_fd_sc_hd__nor2_1 U7535 ( .A(pcpi_rs1[25]), .B(n6106), .Y(n7608) );
  sky130_fd_sc_hd__nor2_1 U7536 ( .A(n7603), .B(n7608), .Y(n6109) );
  sky130_fd_sc_hd__nand2_1 U7537 ( .A(n6746), .B(n6109), .Y(n6157) );
  sky130_fd_sc_hd__nor2_1 U7538 ( .A(n6114), .B(n6157), .Y(n6116) );
  sky130_fd_sc_hd__nand2_1 U7539 ( .A(n6152), .B(n6116), .Y(n6118) );
  sky130_fd_sc_hd__nor2_1 U7540 ( .A(n6080), .B(n6076), .Y(n6083) );
  sky130_fd_sc_hd__nand2_1 U7541 ( .A(n6077), .B(n6083), .Y(n6086) );
  sky130_fd_sc_hd__nor2_1 U7542 ( .A(n6086), .B(n6078), .Y(n6088) );
  sky130_fd_sc_hd__o21ai_1 U7543 ( .A1(n6431), .A2(n6080), .B1(n6079), .Y(
        n6081) );
  sky130_fd_sc_hd__a21oi_1 U7544 ( .A1(n6083), .A2(n6082), .B1(n6081), .Y(
        n6084) );
  sky130_fd_sc_hd__o21ai_1 U7545 ( .A1(n6086), .A2(n6085), .B1(n6084), .Y(
        n6087) );
  sky130_fd_sc_hd__nand2_1 U7546 ( .A(n6090), .B(pcpi_rs1[15]), .Y(n7291) );
  sky130_fd_sc_hd__nand2_1 U7547 ( .A(n6091), .B(pcpi_rs1[16]), .Y(n7296) );
  sky130_fd_sc_hd__o21ai_1 U7548 ( .A1(n7291), .A2(n7295), .B1(n7296), .Y(
        n6567) );
  sky130_fd_sc_hd__nand2_1 U7549 ( .A(n6092), .B(pcpi_rs1[17]), .Y(n7772) );
  sky130_fd_sc_hd__nand2_1 U7550 ( .A(n6093), .B(pcpi_rs1[18]), .Y(n7770) );
  sky130_fd_sc_hd__o21ai_1 U7551 ( .A1(n7772), .A2(n7769), .B1(n7770), .Y(
        n6094) );
  sky130_fd_sc_hd__a21oi_1 U7552 ( .A1(n6095), .A2(n6567), .B1(n6094), .Y(
        n6656) );
  sky130_fd_sc_hd__nand2_1 U7553 ( .A(n6096), .B(pcpi_rs1[19]), .Y(n7391) );
  sky130_fd_sc_hd__nand2_1 U7554 ( .A(n6097), .B(pcpi_rs1[20]), .Y(n7389) );
  sky130_fd_sc_hd__o21ai_1 U7555 ( .A1(n7391), .A2(n7388), .B1(n7389), .Y(
        n6659) );
  sky130_fd_sc_hd__nand2_1 U7556 ( .A(n6098), .B(pcpi_rs1[21]), .Y(n7690) );
  sky130_fd_sc_hd__nand2_1 U7557 ( .A(n6099), .B(pcpi_rs1[22]), .Y(n7688) );
  sky130_fd_sc_hd__o21ai_1 U7558 ( .A1(n7690), .A2(n7687), .B1(n7688), .Y(
        n6100) );
  sky130_fd_sc_hd__a21oi_1 U7559 ( .A1(n6101), .A2(n6659), .B1(n6100), .Y(
        n6102) );
  sky130_fd_sc_hd__o21ai_1 U7560 ( .A1(n6103), .A2(n6656), .B1(n6102), .Y(
        n6153) );
  sky130_fd_sc_hd__nand2_1 U7561 ( .A(n6104), .B(pcpi_rs1[23]), .Y(n7509) );
  sky130_fd_sc_hd__nand2_1 U7562 ( .A(n6105), .B(pcpi_rs1[24]), .Y(n7507) );
  sky130_fd_sc_hd__o21ai_1 U7563 ( .A1(n7509), .A2(n7506), .B1(n7507), .Y(
        n6745) );
  sky130_fd_sc_hd__nand2_1 U7564 ( .A(n6106), .B(pcpi_rs1[25]), .Y(n7606) );
  sky130_fd_sc_hd__nand2_1 U7565 ( .A(n6107), .B(pcpi_rs1[26]), .Y(n7604) );
  sky130_fd_sc_hd__o21ai_1 U7566 ( .A1(n7606), .A2(n7603), .B1(n7604), .Y(
        n6108) );
  sky130_fd_sc_hd__a21oi_1 U7567 ( .A1(n6109), .A2(n6745), .B1(n6108), .Y(
        n6156) );
  sky130_fd_sc_hd__nand2_1 U7568 ( .A(n6110), .B(pcpi_rs1[27]), .Y(n7169) );
  sky130_fd_sc_hd__nand2_1 U7569 ( .A(n6111), .B(pcpi_rs1[28]), .Y(n6159) );
  sky130_fd_sc_hd__a21oi_1 U7570 ( .A1(n6160), .A2(n6158), .B1(n6112), .Y(
        n6113) );
  sky130_fd_sc_hd__o21ai_1 U7571 ( .A1(n6114), .A2(n6156), .B1(n6113), .Y(
        n6115) );
  sky130_fd_sc_hd__a21oi_1 U7572 ( .A1(n6153), .A2(n6116), .B1(n6115), .Y(
        n6117) );
  sky130_fd_sc_hd__o21ai_1 U7573 ( .A1(n6118), .A2(n6657), .B1(n6117), .Y(
        n8677) );
  sky130_fd_sc_hd__xnor2_1 U7574 ( .A(n6119), .B(n8677), .Y(n6124) );
  sky130_fd_sc_hd__a21oi_1 U7575 ( .A1(n9873), .A2(n6122), .B1(n9872), .Y(
        n6120) );
  sky130_fd_sc_hd__o22ai_1 U7576 ( .A1(n9877), .A2(n6122), .B1(n6121), .B2(
        n6120), .Y(n6123) );
  sky130_fd_sc_hd__a21o_1 U7577 ( .A1(n6124), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n6123), .X(alu_out[29]) );
  sky130_fd_sc_hd__o22ai_1 U7578 ( .A1(n10029), .A2(n6127), .B1(n6126), .B2(
        n9387), .Y(n3990) );
  sky130_fd_sc_hd__a22oi_1 U7579 ( .A1(decoded_imm[28]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[28]), .Y(n6128) );
  sky130_fd_sc_hd__nand2_1 U7580 ( .A(n8437), .B(n6128), .Y(n2844) );
  sky130_fd_sc_hd__a22oi_1 U7581 ( .A1(n6059), .A2(\cpuregs[20][28] ), .B1(
        \cpuregs[22][28] ), .B2(n8482), .Y(n6132) );
  sky130_fd_sc_hd__a22oi_1 U7582 ( .A1(\cpuregs[21][28] ), .A2(n8480), .B1(
        n8499), .B2(\cpuregs[3][28] ), .Y(n6131) );
  sky130_fd_sc_hd__a22oi_1 U7583 ( .A1(\cpuregs[7][28] ), .A2(n8477), .B1(
        n8501), .B2(\cpuregs[15][28] ), .Y(n6130) );
  sky130_fd_sc_hd__nand2_1 U7584 ( .A(n8500), .B(\cpuregs[30][28] ), .Y(n6129)
         );
  sky130_fd_sc_hd__nand4_1 U7585 ( .A(n6132), .B(n6131), .C(n6130), .D(n6129), 
        .Y(n6149) );
  sky130_fd_sc_hd__a22oi_1 U7586 ( .A1(n8478), .A2(\cpuregs[13][28] ), .B1(
        n8489), .B2(\cpuregs[17][28] ), .Y(n6136) );
  sky130_fd_sc_hd__a22oi_1 U7587 ( .A1(\cpuregs[23][28] ), .A2(n8464), .B1(
        n8490), .B2(\cpuregs[28][28] ), .Y(n6135) );
  sky130_fd_sc_hd__a22oi_1 U7588 ( .A1(n8497), .A2(\cpuregs[27][28] ), .B1(
        n8481), .B2(\cpuregs[11][28] ), .Y(n6134) );
  sky130_fd_sc_hd__a22oi_1 U7589 ( .A1(n8503), .A2(\cpuregs[24][28] ), .B1(
        n8036), .B2(\cpuregs[9][28] ), .Y(n6133) );
  sky130_fd_sc_hd__nand4_1 U7590 ( .A(n6136), .B(n6135), .C(n6134), .D(n6133), 
        .Y(n6148) );
  sky130_fd_sc_hd__a22oi_1 U7591 ( .A1(n8488), .A2(\cpuregs[1][28] ), .B1(
        \cpuregs[10][28] ), .B2(n8470), .Y(n6141) );
  sky130_fd_sc_hd__a22oi_1 U7592 ( .A1(n8492), .A2(\cpuregs[4][28] ), .B1(
        n8487), .B2(\cpuregs[31][28] ), .Y(n6140) );
  sky130_fd_sc_hd__a22oi_1 U7593 ( .A1(\cpuregs[29][28] ), .A2(n6137), .B1(
        n8479), .B2(\cpuregs[2][28] ), .Y(n6139) );
  sky130_fd_sc_hd__a22oi_1 U7594 ( .A1(n8491), .A2(\cpuregs[12][28] ), .B1(
        n8465), .B2(\cpuregs[16][28] ), .Y(n6138) );
  sky130_fd_sc_hd__nand4_1 U7595 ( .A(n6141), .B(n6140), .C(n6139), .D(n6138), 
        .Y(n6147) );
  sky130_fd_sc_hd__a22oi_1 U7596 ( .A1(n8502), .A2(\cpuregs[6][28] ), .B1(
        n6412), .B2(\cpuregs[19][28] ), .Y(n6145) );
  sky130_fd_sc_hd__a22oi_1 U7597 ( .A1(\cpuregs[5][28] ), .A2(n8471), .B1(
        n8467), .B2(\cpuregs[26][28] ), .Y(n6144) );
  sky130_fd_sc_hd__a22oi_1 U7598 ( .A1(n8472), .A2(\cpuregs[18][28] ), .B1(
        n4233), .B2(\cpuregs[8][28] ), .Y(n6143) );
  sky130_fd_sc_hd__a22oi_1 U7599 ( .A1(\cpuregs[14][28] ), .A2(n8498), .B1(
        n8466), .B2(\cpuregs[25][28] ), .Y(n6142) );
  sky130_fd_sc_hd__nand4_1 U7600 ( .A(n6145), .B(n6144), .C(n6143), .D(n6142), 
        .Y(n6146) );
  sky130_fd_sc_hd__nor4_1 U7601 ( .A(n6149), .B(n6148), .C(n6147), .D(n6146), 
        .Y(n6151) );
  sky130_fd_sc_hd__a22oi_1 U7602 ( .A1(pcpi_rs2[28]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[28]), .Y(n6150) );
  sky130_fd_sc_hd__o21ai_1 U7603 ( .A1(n8514), .A2(n6151), .B1(n6150), .Y(
        n3930) );
  sky130_fd_sc_hd__o21ai_1 U7604 ( .A1(n6155), .A2(n6657), .B1(n6154), .Y(
        n6747) );
  sky130_fd_sc_hd__o21ai_1 U7605 ( .A1(n6157), .A2(n7510), .B1(n6156), .Y(
        n7171) );
  sky130_fd_sc_hd__a21oi_1 U7606 ( .A1(n7171), .A2(n7170), .B1(n6158), .Y(
        n6162) );
  sky130_fd_sc_hd__nand2_1 U7607 ( .A(n6160), .B(n6159), .Y(n6161) );
  sky130_fd_sc_hd__xor2_1 U7608 ( .A(n6162), .B(n6161), .X(n6163) );
  sky130_fd_sc_hd__nand2_1 U7609 ( .A(n6163), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n6168) );
  sky130_fd_sc_hd__nor2_1 U7610 ( .A(n8683), .B(n6164), .Y(n6165) );
  sky130_fd_sc_hd__a31oi_1 U7611 ( .A1(n9382), .A2(pcpi_rs1[28]), .A3(
        pcpi_rs2[28]), .B1(n6165), .Y(n6167) );
  sky130_fd_sc_hd__o21ai_1 U7612 ( .A1(pcpi_rs1[28]), .A2(pcpi_rs2[28]), .B1(
        n9872), .Y(n6166) );
  sky130_fd_sc_hd__nand3_1 U7613 ( .A(n6168), .B(n6167), .C(n6166), .Y(
        alu_out[28]) );
  sky130_fd_sc_hd__nand2_1 U7614 ( .A(n6233), .B(n6229), .Y(n6386) );
  sky130_fd_sc_hd__nand2_1 U7615 ( .A(reg_pc[8]), .B(reg_pc[9]), .Y(n6169) );
  sky130_fd_sc_hd__nand2_1 U7616 ( .A(reg_pc[6]), .B(reg_pc[7]), .Y(n9663) );
  sky130_fd_sc_hd__nor2_1 U7617 ( .A(n6169), .B(n9663), .Y(n6171) );
  sky130_fd_sc_hd__nand2_1 U7618 ( .A(reg_pc[3]), .B(reg_pc[2]), .Y(n8322) );
  sky130_fd_sc_hd__nand2_1 U7619 ( .A(reg_pc[4]), .B(reg_pc[5]), .Y(n6170) );
  sky130_fd_sc_hd__nor2_1 U7620 ( .A(n8322), .B(n6170), .Y(n9587) );
  sky130_fd_sc_hd__nand2_1 U7621 ( .A(n6171), .B(n9587), .Y(n6357) );
  sky130_fd_sc_hd__nand2_1 U7622 ( .A(reg_pc[12]), .B(reg_pc[13]), .Y(n6172)
         );
  sky130_fd_sc_hd__nand2_1 U7623 ( .A(reg_pc[10]), .B(reg_pc[11]), .Y(n6358)
         );
  sky130_fd_sc_hd__nor2_1 U7624 ( .A(n6172), .B(n6358), .Y(n6499) );
  sky130_fd_sc_hd__nand2_1 U7625 ( .A(reg_pc[16]), .B(reg_pc[17]), .Y(n6173)
         );
  sky130_fd_sc_hd__nand2_1 U7626 ( .A(reg_pc[14]), .B(reg_pc[15]), .Y(n6500)
         );
  sky130_fd_sc_hd__nor2_1 U7627 ( .A(n6173), .B(n6500), .Y(n6174) );
  sky130_fd_sc_hd__nand2_1 U7628 ( .A(n6499), .B(n6174), .Y(n6175) );
  sky130_fd_sc_hd__nor2_1 U7629 ( .A(n6357), .B(n6175), .Y(n6596) );
  sky130_fd_sc_hd__nand2_1 U7630 ( .A(reg_pc[26]), .B(reg_pc[27]), .Y(n6179)
         );
  sky130_fd_sc_hd__nand2_1 U7631 ( .A(reg_pc[20]), .B(reg_pc[21]), .Y(n6176)
         );
  sky130_fd_sc_hd__nand2_1 U7632 ( .A(reg_pc[18]), .B(reg_pc[19]), .Y(n6597)
         );
  sky130_fd_sc_hd__nor2_1 U7633 ( .A(n6176), .B(n6597), .Y(n6683) );
  sky130_fd_sc_hd__nand2_1 U7634 ( .A(reg_pc[24]), .B(reg_pc[25]), .Y(n6177)
         );
  sky130_fd_sc_hd__nand2_1 U7635 ( .A(reg_pc[22]), .B(reg_pc[23]), .Y(n6685)
         );
  sky130_fd_sc_hd__nor2_1 U7636 ( .A(n6177), .B(n6685), .Y(n6178) );
  sky130_fd_sc_hd__nand2_1 U7637 ( .A(n6683), .B(n6178), .Y(n9775) );
  sky130_fd_sc_hd__nor2_1 U7638 ( .A(n6179), .B(n9775), .Y(n6180) );
  sky130_fd_sc_hd__nand2_1 U7639 ( .A(n6596), .B(n6180), .Y(n8401) );
  sky130_fd_sc_hd__xnor2_1 U7640 ( .A(reg_pc[28]), .B(n8401), .Y(n6181) );
  sky130_fd_sc_hd__a222oi_1 U7641 ( .A1(alu_out_q[28]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[28]), .C1(n6181), .C2(n9813), .Y(n6211) );
  sky130_fd_sc_hd__nand2_1 U7642 ( .A(n7084), .B(\cpuregs[22][28] ), .Y(n6182)
         );
  sky130_fd_sc_hd__o21ai_1 U7643 ( .A1(n7084), .A2(n4213), .B1(n6182), .Y(
        n3049) );
  sky130_fd_sc_hd__a222oi_1 U7644 ( .A1(n10086), .A2(decoded_imm_j[16]), .B1(
        n10087), .B2(mem_rdata_q[16]), .C1(mem_rdata[16]), .C2(n7928), .Y(
        n6183) );
  sky130_fd_sc_hd__a222oi_1 U7645 ( .A1(n10086), .A2(decoded_imm_j[15]), .B1(
        n10087), .B2(mem_rdata_q[15]), .C1(mem_rdata[15]), .C2(n7928), .Y(
        n6184) );
  sky130_fd_sc_hd__a222oi_1 U7646 ( .A1(n10086), .A2(decoded_imm_j[17]), .B1(
        n10087), .B2(mem_rdata_q[17]), .C1(mem_rdata[17]), .C2(n7928), .Y(
        n6185) );
  sky130_fd_sc_hd__a222oi_1 U7647 ( .A1(n10086), .A2(decoded_imm_j[19]), .B1(
        n10087), .B2(mem_rdata_q[19]), .C1(mem_rdata[19]), .C2(n7928), .Y(
        n6186) );
  sky130_fd_sc_hd__a222oi_1 U7648 ( .A1(n10086), .A2(decoded_imm_j[18]), .B1(
        n10087), .B2(mem_rdata_q[18]), .C1(mem_rdata[18]), .C2(n7928), .Y(
        n6187) );
  sky130_fd_sc_hd__nand2_1 U7649 ( .A(n6188), .B(latched_rd[3]), .Y(n6189) );
  sky130_fd_sc_hd__nor2_1 U7650 ( .A(n6189), .B(n6202), .Y(n6224) );
  sky130_fd_sc_hd__nand2_1 U7651 ( .A(n4226), .B(\cpuregs[12][28] ), .Y(n6190)
         );
  sky130_fd_sc_hd__o21ai_1 U7652 ( .A1(n4226), .A2(n4213), .B1(n6190), .Y(
        n3039) );
  sky130_fd_sc_hd__nor2_1 U7653 ( .A(latched_rd[2]), .B(n6194), .Y(n6196) );
  sky130_fd_sc_hd__nor2_1 U7654 ( .A(n6191), .B(latched_rd[0]), .Y(n6220) );
  sky130_fd_sc_hd__nand2_1 U7655 ( .A(n4178), .B(\cpuregs[2][28] ), .Y(n6192)
         );
  sky130_fd_sc_hd__o21ai_1 U7656 ( .A1(n4178), .A2(n4213), .B1(n6192), .Y(
        n3029) );
  sky130_fd_sc_hd__nor2_1 U7657 ( .A(latched_rd[2]), .B(latched_rd[1]), .Y(
        n6207) );
  sky130_fd_sc_hd__nand2_1 U7658 ( .A(n7452), .B(\cpuregs[9][28] ), .Y(n6193)
         );
  sky130_fd_sc_hd__o21ai_1 U7659 ( .A1(n7452), .A2(n4213), .B1(n6193), .Y(
        n3036) );
  sky130_fd_sc_hd__nand2_1 U7660 ( .A(latched_rd[2]), .B(latched_rd[0]), .Y(
        n6199) );
  sky130_fd_sc_hd__nor2_1 U7661 ( .A(n6194), .B(n6199), .Y(n6236) );
  sky130_fd_sc_hd__nand2_1 U7662 ( .A(n6224), .B(n6236), .Y(n6369) );
  sky130_fd_sc_hd__nand2_1 U7663 ( .A(n7069), .B(\cpuregs[15][28] ), .Y(n6195)
         );
  sky130_fd_sc_hd__o21ai_1 U7664 ( .A1(n7069), .A2(n4213), .B1(n6195), .Y(
        n3042) );
  sky130_fd_sc_hd__nand2_1 U7665 ( .A(n4194), .B(\cpuregs[19][28] ), .Y(n6197)
         );
  sky130_fd_sc_hd__o21ai_1 U7666 ( .A1(n4194), .A2(n4213), .B1(n6197), .Y(
        n3046) );
  sky130_fd_sc_hd__nand2_1 U7667 ( .A(n6242), .B(n6236), .Y(n6510) );
  sky130_fd_sc_hd__nand2_1 U7668 ( .A(n4199), .B(\cpuregs[7][28] ), .Y(n6198)
         );
  sky130_fd_sc_hd__o21ai_1 U7669 ( .A1(n4199), .A2(n4213), .B1(n6198), .Y(
        n3034) );
  sky130_fd_sc_hd__nor2_1 U7670 ( .A(latched_rd[1]), .B(n6199), .Y(n6226) );
  sky130_fd_sc_hd__nand2_1 U7671 ( .A(n6242), .B(n6226), .Y(n6523) );
  sky130_fd_sc_hd__nand2_1 U7672 ( .A(n4180), .B(\cpuregs[5][28] ), .Y(n6200)
         );
  sky130_fd_sc_hd__o21ai_1 U7673 ( .A1(n4180), .A2(n4213), .B1(n6200), .Y(
        n3032) );
  sky130_fd_sc_hd__nand2_1 U7674 ( .A(n9820), .B(\cpuregs[18][28] ), .Y(n6201)
         );
  sky130_fd_sc_hd__o21ai_1 U7675 ( .A1(n9820), .A2(n4213), .B1(n6201), .Y(
        n3045) );
  sky130_fd_sc_hd__nand2_1 U7676 ( .A(latched_rd[3]), .B(latched_rd[4]), .Y(
        n6203) );
  sky130_fd_sc_hd__nand2_1 U7677 ( .A(n4219), .B(\cpuregs[28][28] ), .Y(n6204)
         );
  sky130_fd_sc_hd__o21ai_1 U7678 ( .A1(n4219), .A2(n4213), .B1(n6204), .Y(
        n3055) );
  sky130_fd_sc_hd__nand2_1 U7679 ( .A(n6242), .B(n6222), .Y(n6205) );
  sky130_fd_sc_hd__nand2_1 U7680 ( .A(n4201), .B(\cpuregs[3][28] ), .Y(n6206)
         );
  sky130_fd_sc_hd__o21ai_1 U7681 ( .A1(n4201), .A2(n4213), .B1(n6206), .Y(
        n3030) );
  sky130_fd_sc_hd__nor2_1 U7682 ( .A(n6208), .B(latched_rd[0]), .Y(n6214) );
  sky130_fd_sc_hd__nand2_1 U7683 ( .A(n6233), .B(n6214), .Y(n6533) );
  sky130_fd_sc_hd__nand2_1 U7684 ( .A(n4197), .B(\cpuregs[16][28] ), .Y(n6209)
         );
  sky130_fd_sc_hd__o21ai_1 U7685 ( .A1(n4197), .A2(n4213), .B1(n6209), .Y(
        n3043) );
  sky130_fd_sc_hd__nand2_1 U7686 ( .A(n9621), .B(\cpuregs[26][28] ), .Y(n6210)
         );
  sky130_fd_sc_hd__o21ai_1 U7687 ( .A1(n9621), .A2(n4213), .B1(n6210), .Y(
        n3053) );
  sky130_fd_sc_hd__nand2_1 U7688 ( .A(n6224), .B(n6214), .Y(n6212) );
  sky130_fd_sc_hd__nand2_1 U7689 ( .A(n4183), .B(\cpuregs[8][28] ), .Y(n6213)
         );
  sky130_fd_sc_hd__o21ai_1 U7690 ( .A1(n4183), .A2(n4213), .B1(n6213), .Y(
        n3035) );
  sky130_fd_sc_hd__nand2_1 U7691 ( .A(n10057), .B(\cpuregs[24][28] ), .Y(n6215) );
  sky130_fd_sc_hd__o21ai_1 U7692 ( .A1(n10057), .A2(n4213), .B1(n6215), .Y(
        n3051) );
  sky130_fd_sc_hd__nand2_1 U7693 ( .A(n6233), .B(n6226), .Y(n6517) );
  sky130_fd_sc_hd__nand2_1 U7694 ( .A(n4174), .B(\cpuregs[21][28] ), .Y(n6216)
         );
  sky130_fd_sc_hd__o21ai_1 U7695 ( .A1(n4174), .A2(n4213), .B1(n6216), .Y(
        n3048) );
  sky130_fd_sc_hd__nand2_1 U7696 ( .A(n6237), .B(n6222), .Y(n6388) );
  sky130_fd_sc_hd__nand2_1 U7697 ( .A(n4175), .B(\cpuregs[27][28] ), .Y(n6217)
         );
  sky130_fd_sc_hd__o21ai_1 U7698 ( .A1(n4175), .A2(n4213), .B1(n6217), .Y(
        n3054) );
  sky130_fd_sc_hd__nand2_1 U7699 ( .A(n6237), .B(n6232), .Y(n6379) );
  sky130_fd_sc_hd__nand2_1 U7700 ( .A(n4192), .B(\cpuregs[25][28] ), .Y(n6218)
         );
  sky130_fd_sc_hd__o21ai_1 U7701 ( .A1(n4192), .A2(n4213), .B1(n6218), .Y(
        n3052) );
  sky130_fd_sc_hd__nand2_1 U7702 ( .A(n6224), .B(n6226), .Y(n6531) );
  sky130_fd_sc_hd__nand2_1 U7703 ( .A(n4186), .B(\cpuregs[13][28] ), .Y(n6219)
         );
  sky130_fd_sc_hd__o21ai_1 U7704 ( .A1(n4186), .A2(n4213), .B1(n6219), .Y(
        n3040) );
  sky130_fd_sc_hd__nand2_1 U7705 ( .A(n6224), .B(n6220), .Y(n6374) );
  sky130_fd_sc_hd__nand2_1 U7706 ( .A(n4184), .B(\cpuregs[10][28] ), .Y(n6221)
         );
  sky130_fd_sc_hd__o21ai_1 U7707 ( .A1(n4184), .A2(n4213), .B1(n6221), .Y(
        n3037) );
  sky130_fd_sc_hd__nand2_1 U7708 ( .A(n6224), .B(n6222), .Y(n6401) );
  sky130_fd_sc_hd__nand2_1 U7709 ( .A(n4185), .B(\cpuregs[11][28] ), .Y(n6223)
         );
  sky130_fd_sc_hd__o21ai_1 U7710 ( .A1(n4185), .A2(n4213), .B1(n6223), .Y(
        n3038) );
  sky130_fd_sc_hd__nand2_1 U7711 ( .A(n6897), .B(\cpuregs[14][28] ), .Y(n6225)
         );
  sky130_fd_sc_hd__o21ai_1 U7712 ( .A1(n6897), .A2(n4213), .B1(n6225), .Y(
        n3041) );
  sky130_fd_sc_hd__nand2_1 U7713 ( .A(n6237), .B(n6226), .Y(n6399) );
  sky130_fd_sc_hd__nand2_1 U7714 ( .A(n4176), .B(\cpuregs[29][28] ), .Y(n6227)
         );
  sky130_fd_sc_hd__o21ai_1 U7715 ( .A1(n4176), .A2(n4213), .B1(n6227), .Y(
        n3056) );
  sky130_fd_sc_hd__nand2_1 U7716 ( .A(n6396), .B(\cpuregs[1][28] ), .Y(n6228)
         );
  sky130_fd_sc_hd__o21ai_1 U7717 ( .A1(n6396), .A2(n4213), .B1(n6228), .Y(
        n3028) );
  sky130_fd_sc_hd__nand2_1 U7718 ( .A(n6237), .B(n6229), .Y(n6363) );
  sky130_fd_sc_hd__nand2_1 U7719 ( .A(n4177), .B(\cpuregs[30][28] ), .Y(n6230)
         );
  sky130_fd_sc_hd__o21ai_1 U7720 ( .A1(n4177), .A2(n4213), .B1(n6230), .Y(
        n3057) );
  sky130_fd_sc_hd__nand2_1 U7721 ( .A(n6233), .B(n6236), .Y(n6367) );
  sky130_fd_sc_hd__nand2_1 U7722 ( .A(n4173), .B(\cpuregs[23][28] ), .Y(n6231)
         );
  sky130_fd_sc_hd__o21ai_1 U7723 ( .A1(n4173), .A2(n4213), .B1(n6231), .Y(
        n3050) );
  sky130_fd_sc_hd__nand2_1 U7724 ( .A(n6233), .B(n6232), .Y(n6390) );
  sky130_fd_sc_hd__nand2_1 U7725 ( .A(n4195), .B(\cpuregs[17][28] ), .Y(n6234)
         );
  sky130_fd_sc_hd__o21ai_1 U7726 ( .A1(n4195), .A2(n4213), .B1(n6234), .Y(
        n3044) );
  sky130_fd_sc_hd__nand2_1 U7727 ( .A(n10058), .B(\cpuregs[20][28] ), .Y(n6235) );
  sky130_fd_sc_hd__o21ai_1 U7728 ( .A1(n10058), .A2(n4213), .B1(n6235), .Y(
        n3047) );
  sky130_fd_sc_hd__nand2_1 U7729 ( .A(n6237), .B(n6236), .Y(n6238) );
  sky130_fd_sc_hd__nand2_1 U7730 ( .A(n7247), .B(\cpuregs[31][28] ), .Y(n6239)
         );
  sky130_fd_sc_hd__o21ai_1 U7731 ( .A1(n7247), .A2(n4213), .B1(n6239), .Y(
        n3058) );
  sky130_fd_sc_hd__nand2_1 U7732 ( .A(n9772), .B(\cpuregs[6][28] ), .Y(n6240)
         );
  sky130_fd_sc_hd__o21ai_1 U7733 ( .A1(n9772), .A2(n4213), .B1(n6240), .Y(
        n3033) );
  sky130_fd_sc_hd__nand2_1 U7734 ( .A(n4179), .B(\cpuregs[4][28] ), .Y(n6243)
         );
  sky130_fd_sc_hd__o21ai_1 U7735 ( .A1(n4179), .A2(n4213), .B1(n6243), .Y(
        n3031) );
  sky130_fd_sc_hd__o22ai_1 U7736 ( .A1(n10021), .A2(n8121), .B1(n10083), .B2(
        n8122), .Y(n4160) );
  sky130_fd_sc_hd__nand2_1 U7737 ( .A(n6246), .B(n6245), .Y(n6249) );
  sky130_fd_sc_hd__o21ai_1 U7738 ( .A1(n8123), .A2(n8127), .B1(n8124), .Y(
        n6248) );
  sky130_fd_sc_hd__xnor2_1 U7739 ( .A(n6249), .B(n6248), .Y(n6250) );
  sky130_fd_sc_hd__nand2_1 U7740 ( .A(n6250), .B(n4639), .Y(n6257) );
  sky130_fd_sc_hd__o21ai_1 U7741 ( .A1(n6251), .A2(n10124), .B1(n6876), .Y(
        n8129) );
  sky130_fd_sc_hd__a22oi_1 U7742 ( .A1(n8129), .A2(mem_rdata_word[9]), .B1(
        n9856), .B2(count_instr[41]), .Y(n6256) );
  sky130_fd_sc_hd__nand2_1 U7743 ( .A(n9861), .B(count_cycle[41]), .Y(n6252)
         );
  sky130_fd_sc_hd__o211ai_1 U7744 ( .A1(n9437), .A2(n8819), .B1(n8131), .C1(
        n6252), .Y(n6253) );
  sky130_fd_sc_hd__a21oi_1 U7745 ( .A1(n9860), .A2(count_cycle[9]), .B1(n6253), 
        .Y(n6255) );
  sky130_fd_sc_hd__nand2_1 U7746 ( .A(n9857), .B(count_instr[9]), .Y(n6254) );
  sky130_fd_sc_hd__nand4_1 U7747 ( .A(n6257), .B(n6256), .C(n6255), .D(n6254), 
        .Y(N1886) );
  sky130_fd_sc_hd__a22oi_1 U7748 ( .A1(decoded_imm_j[9]), .A2(n10086), .B1(
        n10087), .B2(mem_rdata_q[29]), .Y(n6258) );
  sky130_fd_sc_hd__o21ai_1 U7749 ( .A1(n10025), .A2(n10089), .B1(n6258), .Y(
        n2883) );
  sky130_fd_sc_hd__a222oi_1 U7750 ( .A1(n10122), .A2(decoded_imm[9]), .B1(
        decoded_imm_j[9]), .B2(n8608), .C1(n8262), .C2(mem_rdata_q[29]), .Y(
        n6259) );
  sky130_fd_sc_hd__a22oi_1 U7751 ( .A1(\cpuregs[14][9] ), .A2(n8498), .B1(
        \cpuregs[5][9] ), .B2(n8471), .Y(n6263) );
  sky130_fd_sc_hd__a22oi_1 U7752 ( .A1(\cpuregs[19][9] ), .A2(n6412), .B1(
        \cpuregs[22][9] ), .B2(n8482), .Y(n6262) );
  sky130_fd_sc_hd__a22oi_1 U7753 ( .A1(\cpuregs[26][9] ), .A2(n8467), .B1(
        \cpuregs[30][9] ), .B2(n8500), .Y(n6261) );
  sky130_fd_sc_hd__a22oi_1 U7754 ( .A1(\cpuregs[17][9] ), .A2(n8489), .B1(
        \cpuregs[18][9] ), .B2(n8472), .Y(n6260) );
  sky130_fd_sc_hd__nand4_1 U7755 ( .A(n6263), .B(n6262), .C(n6261), .D(n6260), 
        .Y(n6279) );
  sky130_fd_sc_hd__a22oi_1 U7756 ( .A1(\cpuregs[1][9] ), .A2(n8488), .B1(
        \cpuregs[7][9] ), .B2(n8477), .Y(n6267) );
  sky130_fd_sc_hd__a22oi_1 U7757 ( .A1(\cpuregs[28][9] ), .A2(n8490), .B1(
        \cpuregs[4][9] ), .B2(n8492), .Y(n6266) );
  sky130_fd_sc_hd__a22oi_1 U7758 ( .A1(\cpuregs[2][9] ), .A2(n8479), .B1(
        \cpuregs[23][9] ), .B2(n8464), .Y(n6265) );
  sky130_fd_sc_hd__a22oi_1 U7759 ( .A1(\cpuregs[8][9] ), .A2(n4233), .B1(
        \cpuregs[9][9] ), .B2(n8036), .Y(n6264) );
  sky130_fd_sc_hd__nand4_1 U7760 ( .A(n6267), .B(n6266), .C(n6265), .D(n6264), 
        .Y(n6278) );
  sky130_fd_sc_hd__a22oi_1 U7761 ( .A1(\cpuregs[27][9] ), .A2(n8497), .B1(
        \cpuregs[20][9] ), .B2(n6059), .Y(n6271) );
  sky130_fd_sc_hd__a22oi_1 U7762 ( .A1(\cpuregs[21][9] ), .A2(n8480), .B1(
        \cpuregs[11][9] ), .B2(n8481), .Y(n6270) );
  sky130_fd_sc_hd__a22oi_1 U7763 ( .A1(\cpuregs[13][9] ), .A2(n8478), .B1(
        \cpuregs[15][9] ), .B2(n8501), .Y(n6269) );
  sky130_fd_sc_hd__nand2_1 U7764 ( .A(\cpuregs[10][9] ), .B(n8470), .Y(n6268)
         );
  sky130_fd_sc_hd__nand4_1 U7765 ( .A(n6271), .B(n6270), .C(n6269), .D(n6268), 
        .Y(n6277) );
  sky130_fd_sc_hd__a22oi_1 U7766 ( .A1(\cpuregs[16][9] ), .A2(n8465), .B1(
        \cpuregs[25][9] ), .B2(n8466), .Y(n6275) );
  sky130_fd_sc_hd__a22oi_1 U7767 ( .A1(\cpuregs[3][9] ), .A2(n8499), .B1(
        \cpuregs[24][9] ), .B2(n8503), .Y(n6274) );
  sky130_fd_sc_hd__a22oi_1 U7768 ( .A1(\cpuregs[12][9] ), .A2(n8491), .B1(
        \cpuregs[6][9] ), .B2(n8502), .Y(n6273) );
  sky130_fd_sc_hd__a22oi_1 U7769 ( .A1(\cpuregs[29][9] ), .A2(n6137), .B1(
        \cpuregs[31][9] ), .B2(n8487), .Y(n6272) );
  sky130_fd_sc_hd__nand4_1 U7770 ( .A(n6275), .B(n6274), .C(n6273), .D(n6272), 
        .Y(n6276) );
  sky130_fd_sc_hd__nor4_1 U7771 ( .A(n6279), .B(n6278), .C(n6277), .D(n6276), 
        .Y(n6281) );
  sky130_fd_sc_hd__a22oi_1 U7772 ( .A1(pcpi_rs2[9]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[9]), .Y(n6280) );
  sky130_fd_sc_hd__o21ai_1 U7773 ( .A1(n8514), .A2(n6281), .B1(n6280), .Y(
        n3949) );
  sky130_fd_sc_hd__nand2_1 U7774 ( .A(n8106), .B(n8104), .Y(n6287) );
  sky130_fd_sc_hd__o21ai_1 U7775 ( .A1(n6286), .A2(n9045), .B1(n6285), .Y(
        n8107) );
  sky130_fd_sc_hd__xnor2_1 U7776 ( .A(n6287), .B(n8107), .Y(n6293) );
  sky130_fd_sc_hd__a21oi_1 U7777 ( .A1(n9873), .A2(n6291), .B1(n9872), .Y(
        n6289) );
  sky130_fd_sc_hd__o22ai_1 U7778 ( .A1(n9877), .A2(n6291), .B1(n6290), .B2(
        n6289), .Y(n6292) );
  sky130_fd_sc_hd__a21o_1 U7779 ( .A1(n6293), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n6292), .X(alu_out[9]) );
  sky130_fd_sc_hd__inv_1 U7780 ( .A(n6294), .Y(n8073) );
  sky130_fd_sc_hd__nand2_1 U7781 ( .A(n6295), .B(n8072), .Y(n6296) );
  sky130_fd_sc_hd__xor2_1 U7782 ( .A(n8073), .B(n6296), .X(n6297) );
  sky130_fd_sc_hd__a222oi_1 U7783 ( .A1(n6299), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[9]), .C1(n5794), .C2(n6297), .Y(n6298) );
  sky130_fd_sc_hd__o22ai_1 U7784 ( .A1(n10029), .A2(n9701), .B1(n6300), .B2(
        n9387), .Y(n4010) );
  sky130_fd_sc_hd__a22oi_1 U7785 ( .A1(n9485), .A2(\cpuregs[21][9] ), .B1(
        n9456), .B2(\cpuregs[17][9] ), .Y(n6304) );
  sky130_fd_sc_hd__a22oi_1 U7786 ( .A1(n9289), .A2(\cpuregs[18][9] ), .B1(
        n9496), .B2(\cpuregs[3][9] ), .Y(n6303) );
  sky130_fd_sc_hd__a22oi_1 U7787 ( .A1(n9481), .A2(\cpuregs[14][9] ), .B1(
        n9494), .B2(\cpuregs[8][9] ), .Y(n6302) );
  sky130_fd_sc_hd__nand2_1 U7788 ( .A(n9484), .B(\cpuregs[12][9] ), .Y(n6301)
         );
  sky130_fd_sc_hd__nand4_1 U7789 ( .A(n6304), .B(n6303), .C(n6302), .D(n6301), 
        .Y(n6320) );
  sky130_fd_sc_hd__a22oi_1 U7790 ( .A1(n9460), .A2(\cpuregs[24][9] ), .B1(
        n9490), .B2(\cpuregs[11][9] ), .Y(n6308) );
  sky130_fd_sc_hd__a22oi_1 U7791 ( .A1(n9492), .A2(\cpuregs[28][9] ), .B1(
        n9316), .B2(\cpuregs[4][9] ), .Y(n6307) );
  sky130_fd_sc_hd__a22oi_1 U7792 ( .A1(n9457), .A2(\cpuregs[19][9] ), .B1(
        n9461), .B2(\cpuregs[5][9] ), .Y(n6306) );
  sky130_fd_sc_hd__a22oi_1 U7793 ( .A1(n9479), .A2(\cpuregs[29][9] ), .B1(
        n9478), .B2(\cpuregs[1][9] ), .Y(n6305) );
  sky130_fd_sc_hd__nand4_1 U7794 ( .A(n6308), .B(n6307), .C(n6306), .D(n6305), 
        .Y(n6319) );
  sky130_fd_sc_hd__a22oi_1 U7795 ( .A1(n9491), .A2(\cpuregs[10][9] ), .B1(
        n9482), .B2(\cpuregs[31][9] ), .Y(n6312) );
  sky130_fd_sc_hd__a22oi_1 U7796 ( .A1(n9493), .A2(\cpuregs[6][9] ), .B1(n9470), .B2(\cpuregs[13][9] ), .Y(n6311) );
  sky130_fd_sc_hd__a22oi_1 U7797 ( .A1(n9468), .A2(\cpuregs[16][9] ), .B1(
        n9497), .B2(\cpuregs[15][9] ), .Y(n6310) );
  sky130_fd_sc_hd__a22oi_1 U7798 ( .A1(n9462), .A2(\cpuregs[2][9] ), .B1(n9471), .B2(\cpuregs[25][9] ), .Y(n6309) );
  sky130_fd_sc_hd__nand4_1 U7799 ( .A(n6312), .B(n6311), .C(n6310), .D(n6309), 
        .Y(n6318) );
  sky130_fd_sc_hd__a22oi_1 U7800 ( .A1(n9467), .A2(\cpuregs[26][9] ), .B1(
        n9469), .B2(\cpuregs[9][9] ), .Y(n6316) );
  sky130_fd_sc_hd__a22oi_1 U7801 ( .A1(n9495), .A2(\cpuregs[22][9] ), .B1(
        n9473), .B2(\cpuregs[23][9] ), .Y(n6315) );
  sky130_fd_sc_hd__a22oi_1 U7802 ( .A1(n9321), .A2(\cpuregs[27][9] ), .B1(
        n9458), .B2(\cpuregs[30][9] ), .Y(n6314) );
  sky130_fd_sc_hd__a22oi_1 U7803 ( .A1(n9480), .A2(\cpuregs[20][9] ), .B1(
        n9483), .B2(\cpuregs[7][9] ), .Y(n6313) );
  sky130_fd_sc_hd__nand4_1 U7804 ( .A(n6316), .B(n6315), .C(n6314), .D(n6313), 
        .Y(n6317) );
  sky130_fd_sc_hd__nor4_1 U7805 ( .A(n6320), .B(n6319), .C(n6318), .D(n6317), 
        .Y(n6335) );
  sky130_fd_sc_hd__o22ai_1 U7806 ( .A1(n4321), .A2(n9701), .B1(n8819), .B2(
        n9340), .Y(n6321) );
  sky130_fd_sc_hd__a21oi_1 U7807 ( .A1(n9345), .A2(pcpi_rs1[13]), .B1(n6321), 
        .Y(n6334) );
  sky130_fd_sc_hd__nand2_1 U7808 ( .A(n6324), .B(n6323), .Y(n6329) );
  sky130_fd_sc_hd__o21ai_1 U7809 ( .A1(n6327), .A2(n6326), .B1(n6325), .Y(
        n6328) );
  sky130_fd_sc_hd__xnor2_1 U7810 ( .A(n6329), .B(n6328), .Y(n6332) );
  sky130_fd_sc_hd__nor2_1 U7811 ( .A(n8786), .B(n4340), .Y(n6331) );
  sky130_fd_sc_hd__o22ai_1 U7812 ( .A1(n9106), .A2(n4371), .B1(n4342), .B2(
        n8813), .Y(n6330) );
  sky130_fd_sc_hd__a211oi_1 U7813 ( .A1(n9511), .A2(n6332), .B1(n6331), .C1(
        n6330), .Y(n6333) );
  sky130_fd_sc_hd__o211ai_1 U7814 ( .A1(n6335), .A2(n9506), .B1(n6334), .C1(
        n6333), .Y(n2786) );
  sky130_fd_sc_hd__clkinv_1 U7815 ( .A(mem_rdata[13]), .Y(n8252) );
  sky130_fd_sc_hd__o22ai_1 U7816 ( .A1(n10025), .A2(n8121), .B1(n8252), .B2(
        n8122), .Y(n4164) );
  sky130_fd_sc_hd__o21ai_1 U7817 ( .A1(n6337), .A2(n8127), .B1(n6336), .Y(
        n6864) );
  sky130_fd_sc_hd__a21oi_1 U7818 ( .A1(n6864), .A2(n7871), .B1(n6339), .Y(
        n6344) );
  sky130_fd_sc_hd__nand2_1 U7819 ( .A(n6342), .B(n6341), .Y(n6343) );
  sky130_fd_sc_hd__xor2_1 U7820 ( .A(n6344), .B(n6343), .X(n6345) );
  sky130_fd_sc_hd__nand2_1 U7821 ( .A(n6345), .B(n4639), .Y(n6351) );
  sky130_fd_sc_hd__a22oi_1 U7822 ( .A1(n8129), .A2(mem_rdata_word[13]), .B1(
        n9856), .B2(count_instr[45]), .Y(n6350) );
  sky130_fd_sc_hd__nand2_1 U7823 ( .A(n9861), .B(count_cycle[45]), .Y(n6346)
         );
  sky130_fd_sc_hd__o211ai_1 U7824 ( .A1(n9437), .A2(n8785), .B1(n8131), .C1(
        n6346), .Y(n6347) );
  sky130_fd_sc_hd__a21oi_1 U7825 ( .A1(n9860), .A2(count_cycle[13]), .B1(n6347), .Y(n6349) );
  sky130_fd_sc_hd__nand2_1 U7826 ( .A(n9857), .B(count_instr[13]), .Y(n6348)
         );
  sky130_fd_sc_hd__nand4_1 U7827 ( .A(n6351), .B(n6350), .C(n6349), .D(n6348), 
        .Y(N1890) );
  sky130_fd_sc_hd__nand2_1 U7828 ( .A(n7802), .B(n7800), .Y(n6354) );
  sky130_fd_sc_hd__o21ai_1 U7829 ( .A1(n6952), .A2(n8073), .B1(n6954), .Y(
        n6353) );
  sky130_fd_sc_hd__xnor2_1 U7830 ( .A(n6354), .B(n6353), .Y(n6355) );
  sky130_fd_sc_hd__a222oi_1 U7831 ( .A1(n9530), .A2(reg_next_pc[13]), .B1(
        n9370), .B2(n6440), .C1(n6355), .C2(n5794), .Y(n6356) );
  sky130_fd_sc_hd__nand2_1 U7832 ( .A(n9736), .B(n6359), .Y(n7894) );
  sky130_fd_sc_hd__nor2_1 U7833 ( .A(n8779), .B(n7894), .Y(n6360) );
  sky130_fd_sc_hd__xnor2_1 U7834 ( .A(n6462), .B(n6360), .Y(n6361) );
  sky130_fd_sc_hd__a222oi_1 U7835 ( .A1(alu_out_q[13]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[13]), .C1(n6361), .C2(n9813), .Y(n6381) );
  sky130_fd_sc_hd__nand2_1 U7836 ( .A(n10057), .B(\cpuregs[24][13] ), .Y(n6362) );
  sky130_fd_sc_hd__o21ai_1 U7837 ( .A1(n10057), .A2(n4202), .B1(n6362), .Y(
        n3516) );
  sky130_fd_sc_hd__nand2_1 U7838 ( .A(n4177), .B(\cpuregs[30][13] ), .Y(n6364)
         );
  sky130_fd_sc_hd__o21ai_1 U7839 ( .A1(n4177), .A2(n4202), .B1(n6364), .Y(
        n3522) );
  sky130_fd_sc_hd__nand2_1 U7840 ( .A(n7452), .B(\cpuregs[9][13] ), .Y(n6366)
         );
  sky130_fd_sc_hd__o21ai_1 U7841 ( .A1(n7452), .A2(n4202), .B1(n6366), .Y(
        n3501) );
  sky130_fd_sc_hd__nand2_1 U7842 ( .A(n4173), .B(\cpuregs[23][13] ), .Y(n6368)
         );
  sky130_fd_sc_hd__o21ai_1 U7843 ( .A1(n4173), .A2(n4202), .B1(n6368), .Y(
        n3515) );
  sky130_fd_sc_hd__nand2_1 U7844 ( .A(n7069), .B(\cpuregs[15][13] ), .Y(n6370)
         );
  sky130_fd_sc_hd__o21ai_1 U7845 ( .A1(n7069), .A2(n4202), .B1(n6370), .Y(
        n3507) );
  sky130_fd_sc_hd__nand2_1 U7846 ( .A(n4219), .B(\cpuregs[28][13] ), .Y(n6371)
         );
  sky130_fd_sc_hd__o21ai_1 U7847 ( .A1(n4219), .A2(n4202), .B1(n6371), .Y(
        n3520) );
  sky130_fd_sc_hd__nand2_1 U7848 ( .A(n4199), .B(\cpuregs[7][13] ), .Y(n6372)
         );
  sky130_fd_sc_hd__o21ai_1 U7849 ( .A1(n4199), .A2(n4202), .B1(n6372), .Y(
        n3499) );
  sky130_fd_sc_hd__nand2_1 U7850 ( .A(n4226), .B(\cpuregs[12][13] ), .Y(n6373)
         );
  sky130_fd_sc_hd__o21ai_1 U7851 ( .A1(n4226), .A2(n4202), .B1(n6373), .Y(
        n3504) );
  sky130_fd_sc_hd__nand2_1 U7852 ( .A(n4184), .B(\cpuregs[10][13] ), .Y(n6375)
         );
  sky130_fd_sc_hd__o21ai_1 U7853 ( .A1(n4184), .A2(n4202), .B1(n6375), .Y(
        n3502) );
  sky130_fd_sc_hd__nand2_1 U7854 ( .A(n9820), .B(\cpuregs[18][13] ), .Y(n6376)
         );
  sky130_fd_sc_hd__o21ai_1 U7855 ( .A1(n9820), .A2(n4202), .B1(n6376), .Y(
        n3510) );
  sky130_fd_sc_hd__nand2_1 U7856 ( .A(n6897), .B(\cpuregs[14][13] ), .Y(n6377)
         );
  sky130_fd_sc_hd__o21ai_1 U7857 ( .A1(n6897), .A2(n4202), .B1(n6377), .Y(
        n3506) );
  sky130_fd_sc_hd__nand2_1 U7858 ( .A(n4174), .B(\cpuregs[21][13] ), .Y(n6378)
         );
  sky130_fd_sc_hd__o21ai_1 U7859 ( .A1(n4174), .A2(n4202), .B1(n6378), .Y(
        n3513) );
  sky130_fd_sc_hd__nand2_1 U7860 ( .A(n4192), .B(\cpuregs[25][13] ), .Y(n6380)
         );
  sky130_fd_sc_hd__o21ai_1 U7861 ( .A1(n4192), .A2(n4202), .B1(n6380), .Y(
        n3517) );
  sky130_fd_sc_hd__nand2_1 U7862 ( .A(n4178), .B(\cpuregs[2][13] ), .Y(n6382)
         );
  sky130_fd_sc_hd__o21ai_1 U7863 ( .A1(n4178), .A2(n4202), .B1(n6382), .Y(
        n3494) );
  sky130_fd_sc_hd__nand2_1 U7864 ( .A(n7247), .B(\cpuregs[31][13] ), .Y(n6383)
         );
  sky130_fd_sc_hd__o21ai_1 U7865 ( .A1(n7247), .A2(n4202), .B1(n6383), .Y(
        n3523) );
  sky130_fd_sc_hd__nand2_1 U7866 ( .A(n4180), .B(\cpuregs[5][13] ), .Y(n6384)
         );
  sky130_fd_sc_hd__o21ai_1 U7867 ( .A1(n4180), .A2(n4202), .B1(n6384), .Y(
        n3497) );
  sky130_fd_sc_hd__nand2_1 U7868 ( .A(n4183), .B(\cpuregs[8][13] ), .Y(n6385)
         );
  sky130_fd_sc_hd__o21ai_1 U7869 ( .A1(n4183), .A2(n4202), .B1(n6385), .Y(
        n3500) );
  sky130_fd_sc_hd__nand2_1 U7870 ( .A(n7084), .B(\cpuregs[22][13] ), .Y(n6387)
         );
  sky130_fd_sc_hd__o21ai_1 U7871 ( .A1(n7084), .A2(n4202), .B1(n6387), .Y(
        n3514) );
  sky130_fd_sc_hd__nand2_1 U7872 ( .A(n4175), .B(\cpuregs[27][13] ), .Y(n6389)
         );
  sky130_fd_sc_hd__o21ai_1 U7873 ( .A1(n4175), .A2(n4202), .B1(n6389), .Y(
        n3519) );
  sky130_fd_sc_hd__nand2_1 U7874 ( .A(n4195), .B(\cpuregs[17][13] ), .Y(n6391)
         );
  sky130_fd_sc_hd__o21ai_1 U7875 ( .A1(n4195), .A2(n4202), .B1(n6391), .Y(
        n3509) );
  sky130_fd_sc_hd__nand2_1 U7876 ( .A(n4179), .B(\cpuregs[4][13] ), .Y(n6392)
         );
  sky130_fd_sc_hd__o21ai_1 U7877 ( .A1(n4179), .A2(n4202), .B1(n6392), .Y(
        n3496) );
  sky130_fd_sc_hd__nand2_1 U7878 ( .A(n4201), .B(\cpuregs[3][13] ), .Y(n6393)
         );
  sky130_fd_sc_hd__o21ai_1 U7879 ( .A1(n4201), .A2(n4202), .B1(n6393), .Y(
        n3495) );
  sky130_fd_sc_hd__nand2_1 U7880 ( .A(n4186), .B(\cpuregs[13][13] ), .Y(n6394)
         );
  sky130_fd_sc_hd__o21ai_1 U7881 ( .A1(n4186), .A2(n4202), .B1(n6394), .Y(
        n3505) );
  sky130_fd_sc_hd__nand2_1 U7882 ( .A(n4197), .B(\cpuregs[16][13] ), .Y(n6395)
         );
  sky130_fd_sc_hd__o21ai_1 U7883 ( .A1(n4197), .A2(n4202), .B1(n6395), .Y(
        n3508) );
  sky130_fd_sc_hd__nand2_1 U7884 ( .A(n6396), .B(\cpuregs[1][13] ), .Y(n6397)
         );
  sky130_fd_sc_hd__o21ai_1 U7885 ( .A1(n6396), .A2(n4202), .B1(n6397), .Y(
        n3493) );
  sky130_fd_sc_hd__nand2_1 U7886 ( .A(n4194), .B(\cpuregs[19][13] ), .Y(n6398)
         );
  sky130_fd_sc_hd__o21ai_1 U7887 ( .A1(n4194), .A2(n4202), .B1(n6398), .Y(
        n3511) );
  sky130_fd_sc_hd__nand2_1 U7888 ( .A(n4176), .B(\cpuregs[29][13] ), .Y(n6400)
         );
  sky130_fd_sc_hd__o21ai_1 U7889 ( .A1(n4176), .A2(n4202), .B1(n6400), .Y(
        n3521) );
  sky130_fd_sc_hd__nand2_1 U7890 ( .A(n4185), .B(\cpuregs[11][13] ), .Y(n6402)
         );
  sky130_fd_sc_hd__o21ai_1 U7891 ( .A1(n4185), .A2(n4202), .B1(n6402), .Y(
        n3503) );
  sky130_fd_sc_hd__nand2_1 U7892 ( .A(n10058), .B(\cpuregs[20][13] ), .Y(n6403) );
  sky130_fd_sc_hd__o21ai_1 U7893 ( .A1(n10058), .A2(n4202), .B1(n6403), .Y(
        n3512) );
  sky130_fd_sc_hd__nand2_1 U7894 ( .A(n9621), .B(\cpuregs[26][13] ), .Y(n6404)
         );
  sky130_fd_sc_hd__o21ai_1 U7895 ( .A1(n9621), .A2(n4202), .B1(n6404), .Y(
        n3518) );
  sky130_fd_sc_hd__nand2_1 U7896 ( .A(n9209), .B(\cpuregs[6][13] ), .Y(n6405)
         );
  sky130_fd_sc_hd__o21ai_1 U7897 ( .A1(n6541), .A2(n4202), .B1(n6405), .Y(
        n3498) );
  sky130_fd_sc_hd__a222oi_1 U7898 ( .A1(n10086), .A2(decoded_imm_j[13]), .B1(
        n10087), .B2(mem_rdata_q[13]), .C1(mem_rdata[13]), .C2(n7928), .Y(
        n6406) );
  sky130_fd_sc_hd__a22oi_1 U7899 ( .A1(decoded_imm[13]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[13]), .Y(n6407) );
  sky130_fd_sc_hd__o211ai_1 U7900 ( .A1(n10095), .A2(n7932), .B1(n6407), .C1(
        n7930), .Y(n2859) );
  sky130_fd_sc_hd__a22oi_1 U7901 ( .A1(n6137), .A2(\cpuregs[29][13] ), .B1(
        n8503), .B2(\cpuregs[24][13] ), .Y(n6411) );
  sky130_fd_sc_hd__a22oi_1 U7902 ( .A1(n8478), .A2(\cpuregs[13][13] ), .B1(
        n8487), .B2(\cpuregs[31][13] ), .Y(n6410) );
  sky130_fd_sc_hd__a22oi_1 U7903 ( .A1(n8498), .A2(\cpuregs[14][13] ), .B1(
        n8491), .B2(\cpuregs[12][13] ), .Y(n6409) );
  sky130_fd_sc_hd__a22oi_1 U7904 ( .A1(n8501), .A2(\cpuregs[15][13] ), .B1(
        n8490), .B2(\cpuregs[28][13] ), .Y(n6408) );
  sky130_fd_sc_hd__nand4_1 U7905 ( .A(n6411), .B(n6410), .C(n6409), .D(n6408), 
        .Y(n6428) );
  sky130_fd_sc_hd__a22oi_1 U7906 ( .A1(n8467), .A2(\cpuregs[26][13] ), .B1(
        n8481), .B2(\cpuregs[11][13] ), .Y(n6416) );
  sky130_fd_sc_hd__a22oi_1 U7907 ( .A1(n6059), .A2(\cpuregs[20][13] ), .B1(
        n8502), .B2(\cpuregs[6][13] ), .Y(n6415) );
  sky130_fd_sc_hd__a22oi_1 U7908 ( .A1(n6412), .A2(\cpuregs[19][13] ), .B1(
        n8488), .B2(\cpuregs[1][13] ), .Y(n6414) );
  sky130_fd_sc_hd__nand2_1 U7909 ( .A(n8500), .B(\cpuregs[30][13] ), .Y(n6413)
         );
  sky130_fd_sc_hd__nand4_1 U7910 ( .A(n6416), .B(n6415), .C(n6414), .D(n6413), 
        .Y(n6427) );
  sky130_fd_sc_hd__a22oi_1 U7911 ( .A1(n8497), .A2(\cpuregs[27][13] ), .B1(
        n8499), .B2(\cpuregs[3][13] ), .Y(n6420) );
  sky130_fd_sc_hd__a22oi_1 U7912 ( .A1(n8492), .A2(\cpuregs[4][13] ), .B1(
        n8465), .B2(\cpuregs[16][13] ), .Y(n6419) );
  sky130_fd_sc_hd__a22oi_1 U7913 ( .A1(n8489), .A2(\cpuregs[17][13] ), .B1(
        n4233), .B2(\cpuregs[8][13] ), .Y(n6418) );
  sky130_fd_sc_hd__a22oi_1 U7914 ( .A1(n8482), .A2(\cpuregs[22][13] ), .B1(
        n8471), .B2(\cpuregs[5][13] ), .Y(n6417) );
  sky130_fd_sc_hd__nand4_1 U7915 ( .A(n6420), .B(n6419), .C(n6418), .D(n6417), 
        .Y(n6426) );
  sky130_fd_sc_hd__a22oi_1 U7916 ( .A1(n8466), .A2(\cpuregs[25][13] ), .B1(
        n8479), .B2(\cpuregs[2][13] ), .Y(n6424) );
  sky130_fd_sc_hd__a22oi_1 U7917 ( .A1(n8480), .A2(\cpuregs[21][13] ), .B1(
        n8470), .B2(\cpuregs[10][13] ), .Y(n6423) );
  sky130_fd_sc_hd__a22oi_1 U7918 ( .A1(n8477), .A2(\cpuregs[7][13] ), .B1(
        n8472), .B2(\cpuregs[18][13] ), .Y(n6422) );
  sky130_fd_sc_hd__a22oi_1 U7919 ( .A1(n8464), .A2(\cpuregs[23][13] ), .B1(
        n8036), .B2(\cpuregs[9][13] ), .Y(n6421) );
  sky130_fd_sc_hd__nand4_1 U7920 ( .A(n6424), .B(n6423), .C(n6422), .D(n6421), 
        .Y(n6425) );
  sky130_fd_sc_hd__nor4_1 U7921 ( .A(n6428), .B(n6427), .C(n6426), .D(n6425), 
        .Y(n6430) );
  sky130_fd_sc_hd__a22oi_1 U7922 ( .A1(pcpi_rs2[13]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[13]), .Y(n6429) );
  sky130_fd_sc_hd__o21ai_1 U7923 ( .A1(n6430), .A2(n8514), .B1(n6429), .Y(
        n3945) );
  sky130_fd_sc_hd__nand2_1 U7924 ( .A(n6432), .B(n6431), .Y(n6434) );
  sky130_fd_sc_hd__xnor2_1 U7925 ( .A(n6434), .B(n6433), .Y(n6439) );
  sky130_fd_sc_hd__a21oi_1 U7926 ( .A1(n9873), .A2(n6437), .B1(n9872), .Y(
        n6435) );
  sky130_fd_sc_hd__o22ai_1 U7927 ( .A1(n9877), .A2(n6437), .B1(n6436), .B2(
        n6435), .Y(n6438) );
  sky130_fd_sc_hd__a21o_1 U7928 ( .A1(n6439), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n6438), .X(alu_out[13]) );
  sky130_fd_sc_hd__o22ai_1 U7929 ( .A1(n10029), .A2(n6462), .B1(n9387), .B2(
        n6441), .Y(n4006) );
  sky130_fd_sc_hd__a22oi_1 U7930 ( .A1(n9471), .A2(\cpuregs[25][13] ), .B1(
        n9472), .B2(\cpuregs[4][13] ), .Y(n6445) );
  sky130_fd_sc_hd__a22oi_1 U7931 ( .A1(n9460), .A2(\cpuregs[24][13] ), .B1(
        n9495), .B2(\cpuregs[22][13] ), .Y(n6444) );
  sky130_fd_sc_hd__a22oi_1 U7932 ( .A1(n9490), .A2(\cpuregs[11][13] ), .B1(
        n9462), .B2(\cpuregs[2][13] ), .Y(n6443) );
  sky130_fd_sc_hd__nand2_1 U7933 ( .A(n9458), .B(\cpuregs[30][13] ), .Y(n6442)
         );
  sky130_fd_sc_hd__nand4_1 U7934 ( .A(n6445), .B(n6444), .C(n6443), .D(n6442), 
        .Y(n6461) );
  sky130_fd_sc_hd__a22oi_1 U7935 ( .A1(n9482), .A2(\cpuregs[31][13] ), .B1(
        n9485), .B2(\cpuregs[21][13] ), .Y(n6449) );
  sky130_fd_sc_hd__a22oi_1 U7936 ( .A1(n9494), .A2(\cpuregs[8][13] ), .B1(
        n9481), .B2(\cpuregs[14][13] ), .Y(n6448) );
  sky130_fd_sc_hd__a22oi_1 U7937 ( .A1(n9492), .A2(\cpuregs[28][13] ), .B1(
        n9497), .B2(\cpuregs[15][13] ), .Y(n6447) );
  sky130_fd_sc_hd__a22oi_1 U7938 ( .A1(n9484), .A2(\cpuregs[12][13] ), .B1(
        n9468), .B2(\cpuregs[16][13] ), .Y(n6446) );
  sky130_fd_sc_hd__nand4_1 U7939 ( .A(n6449), .B(n6448), .C(n6447), .D(n6446), 
        .Y(n6460) );
  sky130_fd_sc_hd__a22oi_1 U7940 ( .A1(n9321), .A2(\cpuregs[27][13] ), .B1(
        n9493), .B2(\cpuregs[6][13] ), .Y(n6453) );
  sky130_fd_sc_hd__a22oi_1 U7941 ( .A1(n9483), .A2(\cpuregs[7][13] ), .B1(
        n9473), .B2(\cpuregs[23][13] ), .Y(n6452) );
  sky130_fd_sc_hd__a22oi_1 U7942 ( .A1(n9469), .A2(\cpuregs[9][13] ), .B1(
        n9479), .B2(\cpuregs[29][13] ), .Y(n6451) );
  sky130_fd_sc_hd__a22oi_1 U7943 ( .A1(n9491), .A2(\cpuregs[10][13] ), .B1(
        n9456), .B2(\cpuregs[17][13] ), .Y(n6450) );
  sky130_fd_sc_hd__nand4_1 U7944 ( .A(n6453), .B(n6452), .C(n6451), .D(n6450), 
        .Y(n6459) );
  sky130_fd_sc_hd__a22oi_1 U7945 ( .A1(n9478), .A2(\cpuregs[1][13] ), .B1(
        n9470), .B2(\cpuregs[13][13] ), .Y(n6457) );
  sky130_fd_sc_hd__a22oi_1 U7946 ( .A1(n9459), .A2(\cpuregs[18][13] ), .B1(
        n9457), .B2(\cpuregs[19][13] ), .Y(n6456) );
  sky130_fd_sc_hd__a22oi_1 U7947 ( .A1(n9496), .A2(\cpuregs[3][13] ), .B1(
        n9461), .B2(\cpuregs[5][13] ), .Y(n6455) );
  sky130_fd_sc_hd__a22oi_1 U7948 ( .A1(n9467), .A2(\cpuregs[26][13] ), .B1(
        n9480), .B2(\cpuregs[20][13] ), .Y(n6454) );
  sky130_fd_sc_hd__nand4_1 U7949 ( .A(n6457), .B(n6456), .C(n6455), .D(n6454), 
        .Y(n6458) );
  sky130_fd_sc_hd__nor4_1 U7950 ( .A(n6461), .B(n6460), .C(n6459), .D(n6458), 
        .Y(n6477) );
  sky130_fd_sc_hd__o22ai_1 U7951 ( .A1(n4321), .A2(n6462), .B1(n8785), .B2(
        n9340), .Y(n6463) );
  sky130_fd_sc_hd__a21oi_1 U7952 ( .A1(n9345), .A2(pcpi_rs1[17]), .B1(n6463), 
        .Y(n6476) );
  sky130_fd_sc_hd__a21oi_1 U7953 ( .A1(n6466), .A2(n8782), .B1(n6465), .Y(
        n6471) );
  sky130_fd_sc_hd__nand2_1 U7954 ( .A(n6469), .B(n6468), .Y(n6470) );
  sky130_fd_sc_hd__xor2_1 U7955 ( .A(n6471), .B(n6470), .X(n6474) );
  sky130_fd_sc_hd__nor2_1 U7956 ( .A(n8778), .B(n4340), .Y(n6473) );
  sky130_fd_sc_hd__o22ai_1 U7957 ( .A1(n8819), .A2(n4371), .B1(n8889), .B2(
        n4342), .Y(n6472) );
  sky130_fd_sc_hd__a211oi_1 U7958 ( .A1(n9511), .A2(n6474), .B1(n6473), .C1(
        n6472), .Y(n6475) );
  sky130_fd_sc_hd__o211ai_1 U7959 ( .A1(n6477), .A2(n9506), .B1(n6476), .C1(
        n6475), .Y(n2782) );
  sky130_fd_sc_hd__a21oi_1 U7960 ( .A1(n7221), .A2(n7220), .B1(n6480), .Y(
        n6485) );
  sky130_fd_sc_hd__nand2_1 U7961 ( .A(n6483), .B(n6482), .Y(n6484) );
  sky130_fd_sc_hd__xor2_1 U7962 ( .A(n6485), .B(n6484), .X(n6486) );
  sky130_fd_sc_hd__nand2_1 U7963 ( .A(n6486), .B(n4639), .Y(n6491) );
  sky130_fd_sc_hd__a22oi_1 U7964 ( .A1(n9861), .A2(count_cycle[49]), .B1(n9860), .B2(count_cycle[17]), .Y(n6490) );
  sky130_fd_sc_hd__a22o_1 U7965 ( .A1(n9858), .A2(pcpi_rs1[17]), .B1(n7705), 
        .B2(mem_rdata_word[17]), .X(n6487) );
  sky130_fd_sc_hd__a211oi_1 U7966 ( .A1(n9857), .A2(count_instr[17]), .B1(
        n7707), .C1(n6487), .Y(n6489) );
  sky130_fd_sc_hd__nand2_1 U7967 ( .A(n9856), .B(count_instr[49]), .Y(n6488)
         );
  sky130_fd_sc_hd__nand4_1 U7968 ( .A(n6491), .B(n6490), .C(n6489), .D(n6488), 
        .Y(N1894) );
  sky130_fd_sc_hd__nand2_1 U7969 ( .A(n6494), .B(n6493), .Y(n6495) );
  sky130_fd_sc_hd__xor2_1 U7970 ( .A(n4217), .B(n6495), .X(n6497) );
  sky130_fd_sc_hd__a222oi_1 U7971 ( .A1(n6577), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[17]), .C1(n5794), .C2(n6497), .Y(n6498) );
  sky130_fd_sc_hd__nand2_1 U7972 ( .A(n9736), .B(n6499), .Y(n6883) );
  sky130_fd_sc_hd__nand2_1 U7973 ( .A(n7810), .B(n6501), .Y(n7230) );
  sky130_fd_sc_hd__nor2_1 U7974 ( .A(n7229), .B(n7230), .Y(n6502) );
  sky130_fd_sc_hd__xnor2_1 U7975 ( .A(n6846), .B(n6502), .Y(n6503) );
  sky130_fd_sc_hd__a222oi_1 U7976 ( .A1(reg_out[17]), .A2(n9816), .B1(
        alu_out_q[17]), .B2(n9815), .C1(n6503), .C2(n9813), .Y(n6520) );
  sky130_fd_sc_hd__nand2_1 U7977 ( .A(n10057), .B(\cpuregs[24][17] ), .Y(n6504) );
  sky130_fd_sc_hd__o21ai_1 U7978 ( .A1(n10057), .A2(n4188), .B1(n6504), .Y(
        n3392) );
  sky130_fd_sc_hd__nand2_1 U7979 ( .A(n4177), .B(\cpuregs[30][17] ), .Y(n6505)
         );
  sky130_fd_sc_hd__o21ai_1 U7980 ( .A1(n4177), .A2(n4188), .B1(n6505), .Y(
        n3398) );
  sky130_fd_sc_hd__nand2_1 U7981 ( .A(n7452), .B(\cpuregs[9][17] ), .Y(n6506)
         );
  sky130_fd_sc_hd__o21ai_1 U7982 ( .A1(n7452), .A2(n4188), .B1(n6506), .Y(
        n3377) );
  sky130_fd_sc_hd__nand2_1 U7983 ( .A(n4173), .B(\cpuregs[23][17] ), .Y(n6507)
         );
  sky130_fd_sc_hd__o21ai_1 U7984 ( .A1(n4173), .A2(n4188), .B1(n6507), .Y(
        n3391) );
  sky130_fd_sc_hd__nand2_1 U7985 ( .A(n7069), .B(\cpuregs[15][17] ), .Y(n6508)
         );
  sky130_fd_sc_hd__o21ai_1 U7986 ( .A1(n7069), .A2(n4188), .B1(n6508), .Y(
        n3383) );
  sky130_fd_sc_hd__nand2_1 U7987 ( .A(n4219), .B(\cpuregs[28][17] ), .Y(n6509)
         );
  sky130_fd_sc_hd__o21ai_1 U7988 ( .A1(n4219), .A2(n4188), .B1(n6509), .Y(
        n3396) );
  sky130_fd_sc_hd__nand2_1 U7989 ( .A(n4199), .B(\cpuregs[7][17] ), .Y(n6511)
         );
  sky130_fd_sc_hd__o21ai_1 U7990 ( .A1(n4199), .A2(n4188), .B1(n6511), .Y(
        n3375) );
  sky130_fd_sc_hd__nand2_1 U7991 ( .A(n4226), .B(\cpuregs[12][17] ), .Y(n6512)
         );
  sky130_fd_sc_hd__o21ai_1 U7992 ( .A1(n4226), .A2(n4188), .B1(n6512), .Y(
        n3380) );
  sky130_fd_sc_hd__nand2_1 U7993 ( .A(n4184), .B(\cpuregs[10][17] ), .Y(n6513)
         );
  sky130_fd_sc_hd__o21ai_1 U7994 ( .A1(n4184), .A2(n4188), .B1(n6513), .Y(
        n3378) );
  sky130_fd_sc_hd__nand2_1 U7995 ( .A(n9820), .B(\cpuregs[18][17] ), .Y(n6514)
         );
  sky130_fd_sc_hd__o21ai_1 U7996 ( .A1(n9820), .A2(n4188), .B1(n6514), .Y(
        n3386) );
  sky130_fd_sc_hd__nand2_1 U7997 ( .A(n6897), .B(\cpuregs[14][17] ), .Y(n6516)
         );
  sky130_fd_sc_hd__o21ai_1 U7998 ( .A1(n6897), .A2(n4188), .B1(n6516), .Y(
        n3382) );
  sky130_fd_sc_hd__nand2_1 U7999 ( .A(n4174), .B(\cpuregs[21][17] ), .Y(n6518)
         );
  sky130_fd_sc_hd__o21ai_1 U8000 ( .A1(n4174), .A2(n4188), .B1(n6518), .Y(
        n3389) );
  sky130_fd_sc_hd__nand2_1 U8001 ( .A(n4192), .B(\cpuregs[25][17] ), .Y(n6519)
         );
  sky130_fd_sc_hd__o21ai_1 U8002 ( .A1(n4192), .A2(n4188), .B1(n6519), .Y(
        n3393) );
  sky130_fd_sc_hd__nand2_1 U8003 ( .A(n4178), .B(\cpuregs[2][17] ), .Y(n6521)
         );
  sky130_fd_sc_hd__o21ai_1 U8004 ( .A1(n4178), .A2(n4188), .B1(n6521), .Y(
        n3370) );
  sky130_fd_sc_hd__nand2_1 U8005 ( .A(n7247), .B(\cpuregs[31][17] ), .Y(n6522)
         );
  sky130_fd_sc_hd__o21ai_1 U8006 ( .A1(n7247), .A2(n4188), .B1(n6522), .Y(
        n3399) );
  sky130_fd_sc_hd__nand2_1 U8007 ( .A(n4180), .B(\cpuregs[5][17] ), .Y(n6524)
         );
  sky130_fd_sc_hd__o21ai_1 U8008 ( .A1(n4180), .A2(n4188), .B1(n6524), .Y(
        n3373) );
  sky130_fd_sc_hd__nand2_1 U8009 ( .A(n4183), .B(\cpuregs[8][17] ), .Y(n6525)
         );
  sky130_fd_sc_hd__o21ai_1 U8010 ( .A1(n4183), .A2(n4188), .B1(n6525), .Y(
        n3376) );
  sky130_fd_sc_hd__nand2_1 U8011 ( .A(n7084), .B(\cpuregs[22][17] ), .Y(n6526)
         );
  sky130_fd_sc_hd__o21ai_1 U8012 ( .A1(n7084), .A2(n4188), .B1(n6526), .Y(
        n3390) );
  sky130_fd_sc_hd__nand2_1 U8013 ( .A(n4175), .B(\cpuregs[27][17] ), .Y(n6527)
         );
  sky130_fd_sc_hd__o21ai_1 U8014 ( .A1(n4175), .A2(n4188), .B1(n6527), .Y(
        n3395) );
  sky130_fd_sc_hd__nand2_1 U8015 ( .A(n4195), .B(\cpuregs[17][17] ), .Y(n6528)
         );
  sky130_fd_sc_hd__o21ai_1 U8016 ( .A1(n4195), .A2(n4188), .B1(n6528), .Y(
        n3385) );
  sky130_fd_sc_hd__nand2_1 U8017 ( .A(n4179), .B(\cpuregs[4][17] ), .Y(n6529)
         );
  sky130_fd_sc_hd__o21ai_1 U8018 ( .A1(n4179), .A2(n4188), .B1(n6529), .Y(
        n3372) );
  sky130_fd_sc_hd__nand2_1 U8019 ( .A(n4201), .B(\cpuregs[3][17] ), .Y(n6530)
         );
  sky130_fd_sc_hd__o21ai_1 U8020 ( .A1(n4201), .A2(n4188), .B1(n6530), .Y(
        n3371) );
  sky130_fd_sc_hd__nand2_1 U8021 ( .A(n4186), .B(\cpuregs[13][17] ), .Y(n6532)
         );
  sky130_fd_sc_hd__o21ai_1 U8022 ( .A1(n4186), .A2(n4188), .B1(n6532), .Y(
        n3381) );
  sky130_fd_sc_hd__nand2_1 U8023 ( .A(n4197), .B(\cpuregs[16][17] ), .Y(n6534)
         );
  sky130_fd_sc_hd__o21ai_1 U8024 ( .A1(n4197), .A2(n4188), .B1(n6534), .Y(
        n3384) );
  sky130_fd_sc_hd__nand2_1 U8025 ( .A(n6396), .B(\cpuregs[1][17] ), .Y(n6535)
         );
  sky130_fd_sc_hd__o21ai_1 U8026 ( .A1(n6396), .A2(n4188), .B1(n6535), .Y(
        n3369) );
  sky130_fd_sc_hd__nand2_1 U8027 ( .A(n4194), .B(\cpuregs[19][17] ), .Y(n6536)
         );
  sky130_fd_sc_hd__o21ai_1 U8028 ( .A1(n4194), .A2(n4188), .B1(n6536), .Y(
        n3387) );
  sky130_fd_sc_hd__nand2_1 U8029 ( .A(n4176), .B(\cpuregs[29][17] ), .Y(n6537)
         );
  sky130_fd_sc_hd__o21ai_1 U8030 ( .A1(n4176), .A2(n4188), .B1(n6537), .Y(
        n3397) );
  sky130_fd_sc_hd__nand2_1 U8031 ( .A(n4185), .B(\cpuregs[11][17] ), .Y(n6538)
         );
  sky130_fd_sc_hd__o21ai_1 U8032 ( .A1(n4185), .A2(n4188), .B1(n6538), .Y(
        n3379) );
  sky130_fd_sc_hd__nand2_1 U8033 ( .A(n10058), .B(\cpuregs[20][17] ), .Y(n6539) );
  sky130_fd_sc_hd__o21ai_1 U8034 ( .A1(n10058), .A2(n4188), .B1(n6539), .Y(
        n3388) );
  sky130_fd_sc_hd__nand2_1 U8035 ( .A(n9621), .B(\cpuregs[26][17] ), .Y(n6540)
         );
  sky130_fd_sc_hd__o21ai_1 U8036 ( .A1(n9621), .A2(n4188), .B1(n6540), .Y(
        n3394) );
  sky130_fd_sc_hd__nand2_1 U8037 ( .A(n9772), .B(\cpuregs[6][17] ), .Y(n6542)
         );
  sky130_fd_sc_hd__o21ai_1 U8038 ( .A1(n9772), .A2(n4188), .B1(n6542), .Y(
        n3374) );
  sky130_fd_sc_hd__a22oi_1 U8039 ( .A1(decoded_imm[17]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[17]), .Y(n6544) );
  sky130_fd_sc_hd__nand2_1 U8040 ( .A(n5989), .B(mem_rdata_q[17]), .Y(n6543)
         );
  sky130_fd_sc_hd__nand3_1 U8041 ( .A(n7930), .B(n6544), .C(n6543), .Y(n2855)
         );
  sky130_fd_sc_hd__a22oi_1 U8042 ( .A1(n6137), .A2(\cpuregs[29][17] ), .B1(
        n8503), .B2(\cpuregs[24][17] ), .Y(n6548) );
  sky130_fd_sc_hd__a22oi_1 U8043 ( .A1(n8478), .A2(\cpuregs[13][17] ), .B1(
        n8487), .B2(\cpuregs[31][17] ), .Y(n6547) );
  sky130_fd_sc_hd__a22oi_1 U8044 ( .A1(n8498), .A2(\cpuregs[14][17] ), .B1(
        n8491), .B2(\cpuregs[12][17] ), .Y(n6546) );
  sky130_fd_sc_hd__a22oi_1 U8045 ( .A1(n8501), .A2(\cpuregs[15][17] ), .B1(
        n8490), .B2(\cpuregs[28][17] ), .Y(n6545) );
  sky130_fd_sc_hd__nand4_1 U8046 ( .A(n6548), .B(n6547), .C(n6546), .D(n6545), 
        .Y(n6564) );
  sky130_fd_sc_hd__a22oi_1 U8047 ( .A1(n8467), .A2(\cpuregs[26][17] ), .B1(
        n8481), .B2(\cpuregs[11][17] ), .Y(n6552) );
  sky130_fd_sc_hd__a22oi_1 U8048 ( .A1(n6059), .A2(\cpuregs[20][17] ), .B1(
        n8502), .B2(\cpuregs[6][17] ), .Y(n6551) );
  sky130_fd_sc_hd__a22oi_1 U8049 ( .A1(n6412), .A2(\cpuregs[19][17] ), .B1(
        n8488), .B2(\cpuregs[1][17] ), .Y(n6550) );
  sky130_fd_sc_hd__nand2_1 U8050 ( .A(n8500), .B(\cpuregs[30][17] ), .Y(n6549)
         );
  sky130_fd_sc_hd__nand4_1 U8051 ( .A(n6552), .B(n6551), .C(n6550), .D(n6549), 
        .Y(n6563) );
  sky130_fd_sc_hd__a22oi_1 U8052 ( .A1(n8497), .A2(\cpuregs[27][17] ), .B1(
        n8499), .B2(\cpuregs[3][17] ), .Y(n6556) );
  sky130_fd_sc_hd__a22oi_1 U8053 ( .A1(n8492), .A2(\cpuregs[4][17] ), .B1(
        n8465), .B2(\cpuregs[16][17] ), .Y(n6555) );
  sky130_fd_sc_hd__a22oi_1 U8054 ( .A1(n8489), .A2(\cpuregs[17][17] ), .B1(
        n4233), .B2(\cpuregs[8][17] ), .Y(n6554) );
  sky130_fd_sc_hd__a22oi_1 U8055 ( .A1(n8482), .A2(\cpuregs[22][17] ), .B1(
        n8471), .B2(\cpuregs[5][17] ), .Y(n6553) );
  sky130_fd_sc_hd__nand4_1 U8056 ( .A(n6556), .B(n6555), .C(n6554), .D(n6553), 
        .Y(n6562) );
  sky130_fd_sc_hd__a22oi_1 U8057 ( .A1(n8466), .A2(\cpuregs[25][17] ), .B1(
        n8479), .B2(\cpuregs[2][17] ), .Y(n6560) );
  sky130_fd_sc_hd__a22oi_1 U8058 ( .A1(n8480), .A2(\cpuregs[21][17] ), .B1(
        n8470), .B2(\cpuregs[10][17] ), .Y(n6559) );
  sky130_fd_sc_hd__a22oi_1 U8059 ( .A1(n8477), .A2(\cpuregs[7][17] ), .B1(
        n8472), .B2(\cpuregs[18][17] ), .Y(n6558) );
  sky130_fd_sc_hd__a22oi_1 U8060 ( .A1(n8464), .A2(\cpuregs[23][17] ), .B1(
        n8036), .B2(\cpuregs[9][17] ), .Y(n6557) );
  sky130_fd_sc_hd__nand4_1 U8061 ( .A(n6560), .B(n6559), .C(n6558), .D(n6557), 
        .Y(n6561) );
  sky130_fd_sc_hd__nor4_1 U8062 ( .A(n6564), .B(n6563), .C(n6562), .D(n6561), 
        .Y(n6566) );
  sky130_fd_sc_hd__a22oi_1 U8063 ( .A1(pcpi_rs2[17]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[17]), .Y(n6565) );
  sky130_fd_sc_hd__o21ai_1 U8064 ( .A1(n6566), .A2(n8514), .B1(n6565), .Y(
        n3941) );
  sky130_fd_sc_hd__a21oi_1 U8065 ( .A1(n7294), .A2(n6568), .B1(n6567), .Y(
        n7773) );
  sky130_fd_sc_hd__nand2_1 U8066 ( .A(n6569), .B(n7772), .Y(n6570) );
  sky130_fd_sc_hd__xor2_1 U8067 ( .A(n7773), .B(n6570), .X(n6571) );
  sky130_fd_sc_hd__nand2_1 U8068 ( .A(n6571), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n6576) );
  sky130_fd_sc_hd__nor2_1 U8069 ( .A(n8683), .B(n6572), .Y(n6573) );
  sky130_fd_sc_hd__a31oi_1 U8070 ( .A1(n9382), .A2(pcpi_rs1[17]), .A3(
        pcpi_rs2[17]), .B1(n6573), .Y(n6575) );
  sky130_fd_sc_hd__o21ai_1 U8071 ( .A1(pcpi_rs1[17]), .A2(pcpi_rs2[17]), .B1(
        n9872), .Y(n6574) );
  sky130_fd_sc_hd__nand3_1 U8072 ( .A(n6576), .B(n6575), .C(n6574), .Y(
        alu_out[17]) );
  sky130_fd_sc_hd__o22ai_1 U8073 ( .A1(n10029), .A2(n6846), .B1(n6578), .B2(
        n9387), .Y(n4002) );
  sky130_fd_sc_hd__a21oi_1 U8074 ( .A1(n7221), .A2(n6582), .B1(n6581), .Y(
        n7046) );
  sky130_fd_sc_hd__a21oi_1 U8075 ( .A1(n7322), .A2(n7321), .B1(n6584), .Y(
        n6589) );
  sky130_fd_sc_hd__nand2_1 U8076 ( .A(n6587), .B(n6586), .Y(n6588) );
  sky130_fd_sc_hd__xor2_1 U8077 ( .A(n6589), .B(n6588), .X(n6590) );
  sky130_fd_sc_hd__nand2_1 U8078 ( .A(n6590), .B(n4639), .Y(n6595) );
  sky130_fd_sc_hd__a22oi_1 U8079 ( .A1(n9861), .A2(count_cycle[53]), .B1(n9860), .B2(count_cycle[21]), .Y(n6594) );
  sky130_fd_sc_hd__a22o_1 U8080 ( .A1(n9858), .A2(pcpi_rs1[21]), .B1(n7705), 
        .B2(mem_rdata_word[21]), .X(n6591) );
  sky130_fd_sc_hd__a211oi_1 U8081 ( .A1(n9857), .A2(count_instr[21]), .B1(
        n7707), .C1(n6591), .Y(n6593) );
  sky130_fd_sc_hd__nand2_1 U8082 ( .A(n9856), .B(count_instr[53]), .Y(n6592)
         );
  sky130_fd_sc_hd__nand4_1 U8083 ( .A(n6595), .B(n6594), .C(n6593), .D(n6592), 
        .Y(N1898) );
  sky130_fd_sc_hd__nor2_1 U8084 ( .A(n6597), .B(n9774), .Y(n7330) );
  sky130_fd_sc_hd__nand2_1 U8085 ( .A(n7330), .B(reg_pc[20]), .Y(n6599) );
  sky130_fd_sc_hd__xor2_1 U8086 ( .A(n6599), .B(n6598), .X(n6600) );
  sky130_fd_sc_hd__a222oi_1 U8087 ( .A1(reg_out[21]), .A2(n9816), .B1(
        alu_out_q[21]), .B2(n9815), .C1(n6600), .C2(n9813), .Y(n6614) );
  sky130_fd_sc_hd__nand2_1 U8088 ( .A(n10057), .B(\cpuregs[24][21] ), .Y(n6601) );
  sky130_fd_sc_hd__o21ai_1 U8089 ( .A1(n10057), .A2(n4189), .B1(n6601), .Y(
        n3268) );
  sky130_fd_sc_hd__nand2_1 U8090 ( .A(n4177), .B(\cpuregs[30][21] ), .Y(n6602)
         );
  sky130_fd_sc_hd__o21ai_1 U8091 ( .A1(n4177), .A2(n4189), .B1(n6602), .Y(
        n3274) );
  sky130_fd_sc_hd__nand2_1 U8092 ( .A(n7452), .B(\cpuregs[9][21] ), .Y(n6603)
         );
  sky130_fd_sc_hd__o21ai_1 U8093 ( .A1(n7452), .A2(n4189), .B1(n6603), .Y(
        n3253) );
  sky130_fd_sc_hd__nand2_1 U8094 ( .A(n4173), .B(\cpuregs[23][21] ), .Y(n6604)
         );
  sky130_fd_sc_hd__o21ai_1 U8095 ( .A1(n4173), .A2(n4189), .B1(n6604), .Y(
        n3267) );
  sky130_fd_sc_hd__nand2_1 U8096 ( .A(n7069), .B(\cpuregs[15][21] ), .Y(n6605)
         );
  sky130_fd_sc_hd__o21ai_1 U8097 ( .A1(n7069), .A2(n4189), .B1(n6605), .Y(
        n3259) );
  sky130_fd_sc_hd__nand2_1 U8098 ( .A(n4219), .B(\cpuregs[28][21] ), .Y(n6606)
         );
  sky130_fd_sc_hd__o21ai_1 U8099 ( .A1(n4219), .A2(n4189), .B1(n6606), .Y(
        n3272) );
  sky130_fd_sc_hd__nand2_1 U8100 ( .A(n4199), .B(\cpuregs[7][21] ), .Y(n6607)
         );
  sky130_fd_sc_hd__o21ai_1 U8101 ( .A1(n4199), .A2(n4189), .B1(n6607), .Y(
        n3251) );
  sky130_fd_sc_hd__nand2_1 U8102 ( .A(n4226), .B(\cpuregs[12][21] ), .Y(n6608)
         );
  sky130_fd_sc_hd__o21ai_1 U8103 ( .A1(n4226), .A2(n4189), .B1(n6608), .Y(
        n3256) );
  sky130_fd_sc_hd__nand2_1 U8104 ( .A(n4184), .B(\cpuregs[10][21] ), .Y(n6609)
         );
  sky130_fd_sc_hd__o21ai_1 U8105 ( .A1(n4184), .A2(n4189), .B1(n6609), .Y(
        n3254) );
  sky130_fd_sc_hd__nand2_1 U8106 ( .A(n9820), .B(\cpuregs[18][21] ), .Y(n6610)
         );
  sky130_fd_sc_hd__o21ai_1 U8107 ( .A1(n9820), .A2(n4189), .B1(n6610), .Y(
        n3262) );
  sky130_fd_sc_hd__nand2_1 U8108 ( .A(n6897), .B(\cpuregs[14][21] ), .Y(n6611)
         );
  sky130_fd_sc_hd__o21ai_1 U8109 ( .A1(n6897), .A2(n4189), .B1(n6611), .Y(
        n3258) );
  sky130_fd_sc_hd__nand2_1 U8110 ( .A(n4174), .B(\cpuregs[21][21] ), .Y(n6612)
         );
  sky130_fd_sc_hd__o21ai_1 U8111 ( .A1(n4174), .A2(n4189), .B1(n6612), .Y(
        n3265) );
  sky130_fd_sc_hd__nand2_1 U8112 ( .A(n4192), .B(\cpuregs[25][21] ), .Y(n6613)
         );
  sky130_fd_sc_hd__o21ai_1 U8113 ( .A1(n4192), .A2(n4189), .B1(n6613), .Y(
        n3269) );
  sky130_fd_sc_hd__nand2_1 U8114 ( .A(n4178), .B(\cpuregs[2][21] ), .Y(n6615)
         );
  sky130_fd_sc_hd__o21ai_1 U8115 ( .A1(n4178), .A2(n4189), .B1(n6615), .Y(
        n3246) );
  sky130_fd_sc_hd__nand2_1 U8116 ( .A(n7247), .B(\cpuregs[31][21] ), .Y(n6616)
         );
  sky130_fd_sc_hd__o21ai_1 U8117 ( .A1(n7247), .A2(n4189), .B1(n6616), .Y(
        n3275) );
  sky130_fd_sc_hd__nand2_1 U8118 ( .A(n4180), .B(\cpuregs[5][21] ), .Y(n6617)
         );
  sky130_fd_sc_hd__o21ai_1 U8119 ( .A1(n4180), .A2(n4189), .B1(n6617), .Y(
        n3249) );
  sky130_fd_sc_hd__nand2_1 U8120 ( .A(n4183), .B(\cpuregs[8][21] ), .Y(n6618)
         );
  sky130_fd_sc_hd__o21ai_1 U8121 ( .A1(n4183), .A2(n4189), .B1(n6618), .Y(
        n3252) );
  sky130_fd_sc_hd__nand2_1 U8122 ( .A(n7084), .B(\cpuregs[22][21] ), .Y(n6619)
         );
  sky130_fd_sc_hd__o21ai_1 U8123 ( .A1(n7084), .A2(n4189), .B1(n6619), .Y(
        n3266) );
  sky130_fd_sc_hd__nand2_1 U8124 ( .A(n4175), .B(\cpuregs[27][21] ), .Y(n6620)
         );
  sky130_fd_sc_hd__o21ai_1 U8125 ( .A1(n4175), .A2(n4189), .B1(n6620), .Y(
        n3271) );
  sky130_fd_sc_hd__nand2_1 U8126 ( .A(n4195), .B(\cpuregs[17][21] ), .Y(n6621)
         );
  sky130_fd_sc_hd__o21ai_1 U8127 ( .A1(n4195), .A2(n4189), .B1(n6621), .Y(
        n3261) );
  sky130_fd_sc_hd__nand2_1 U8128 ( .A(n4179), .B(\cpuregs[4][21] ), .Y(n6622)
         );
  sky130_fd_sc_hd__o21ai_1 U8129 ( .A1(n4179), .A2(n4189), .B1(n6622), .Y(
        n3248) );
  sky130_fd_sc_hd__nand2_1 U8130 ( .A(n4201), .B(\cpuregs[3][21] ), .Y(n6623)
         );
  sky130_fd_sc_hd__o21ai_1 U8131 ( .A1(n4201), .A2(n4189), .B1(n6623), .Y(
        n3247) );
  sky130_fd_sc_hd__nand2_1 U8132 ( .A(n4186), .B(\cpuregs[13][21] ), .Y(n6624)
         );
  sky130_fd_sc_hd__o21ai_1 U8133 ( .A1(n4186), .A2(n4189), .B1(n6624), .Y(
        n3257) );
  sky130_fd_sc_hd__nand2_1 U8134 ( .A(n4197), .B(\cpuregs[16][21] ), .Y(n6625)
         );
  sky130_fd_sc_hd__o21ai_1 U8135 ( .A1(n4197), .A2(n4189), .B1(n6625), .Y(
        n3260) );
  sky130_fd_sc_hd__nand2_1 U8136 ( .A(n6396), .B(\cpuregs[1][21] ), .Y(n6626)
         );
  sky130_fd_sc_hd__o21ai_1 U8137 ( .A1(n6396), .A2(n4189), .B1(n6626), .Y(
        n3245) );
  sky130_fd_sc_hd__nand2_1 U8138 ( .A(n4194), .B(\cpuregs[19][21] ), .Y(n6627)
         );
  sky130_fd_sc_hd__o21ai_1 U8139 ( .A1(n4194), .A2(n4189), .B1(n6627), .Y(
        n3263) );
  sky130_fd_sc_hd__nand2_1 U8140 ( .A(n4176), .B(\cpuregs[29][21] ), .Y(n6628)
         );
  sky130_fd_sc_hd__o21ai_1 U8141 ( .A1(n4176), .A2(n4189), .B1(n6628), .Y(
        n3273) );
  sky130_fd_sc_hd__nand2_1 U8142 ( .A(n4185), .B(\cpuregs[11][21] ), .Y(n6629)
         );
  sky130_fd_sc_hd__o21ai_1 U8143 ( .A1(n4185), .A2(n4189), .B1(n6629), .Y(
        n3255) );
  sky130_fd_sc_hd__nand2_1 U8144 ( .A(n10058), .B(\cpuregs[20][21] ), .Y(n6630) );
  sky130_fd_sc_hd__o21ai_1 U8145 ( .A1(n10058), .A2(n4189), .B1(n6630), .Y(
        n3264) );
  sky130_fd_sc_hd__nand2_1 U8146 ( .A(n9621), .B(\cpuregs[26][21] ), .Y(n6631)
         );
  sky130_fd_sc_hd__o21ai_1 U8147 ( .A1(n9621), .A2(n4189), .B1(n6631), .Y(
        n3270) );
  sky130_fd_sc_hd__nand2_1 U8148 ( .A(n9772), .B(\cpuregs[6][21] ), .Y(n6632)
         );
  sky130_fd_sc_hd__o21ai_1 U8149 ( .A1(n9772), .A2(n4189), .B1(n6632), .Y(
        n3250) );
  sky130_fd_sc_hd__a22oi_1 U8150 ( .A1(decoded_imm[21]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[21]), .Y(n6633) );
  sky130_fd_sc_hd__nand2_1 U8151 ( .A(n8437), .B(n6633), .Y(n2851) );
  sky130_fd_sc_hd__a22oi_1 U8152 ( .A1(n6137), .A2(\cpuregs[29][21] ), .B1(
        n8503), .B2(\cpuregs[24][21] ), .Y(n6637) );
  sky130_fd_sc_hd__a22oi_1 U8153 ( .A1(n8478), .A2(\cpuregs[13][21] ), .B1(
        n8487), .B2(\cpuregs[31][21] ), .Y(n6636) );
  sky130_fd_sc_hd__a22oi_1 U8154 ( .A1(n8498), .A2(\cpuregs[14][21] ), .B1(
        n8491), .B2(\cpuregs[12][21] ), .Y(n6635) );
  sky130_fd_sc_hd__a22oi_1 U8155 ( .A1(n8501), .A2(\cpuregs[15][21] ), .B1(
        n8490), .B2(\cpuregs[28][21] ), .Y(n6634) );
  sky130_fd_sc_hd__nand4_1 U8156 ( .A(n6637), .B(n6636), .C(n6635), .D(n6634), 
        .Y(n6653) );
  sky130_fd_sc_hd__a22oi_1 U8157 ( .A1(n8467), .A2(\cpuregs[26][21] ), .B1(
        n8481), .B2(\cpuregs[11][21] ), .Y(n6641) );
  sky130_fd_sc_hd__a22oi_1 U8158 ( .A1(n6059), .A2(\cpuregs[20][21] ), .B1(
        n8502), .B2(\cpuregs[6][21] ), .Y(n6640) );
  sky130_fd_sc_hd__a22oi_1 U8159 ( .A1(n6412), .A2(\cpuregs[19][21] ), .B1(
        n8488), .B2(\cpuregs[1][21] ), .Y(n6639) );
  sky130_fd_sc_hd__nand2_1 U8160 ( .A(n8500), .B(\cpuregs[30][21] ), .Y(n6638)
         );
  sky130_fd_sc_hd__nand4_1 U8161 ( .A(n6641), .B(n6640), .C(n6639), .D(n6638), 
        .Y(n6652) );
  sky130_fd_sc_hd__a22oi_1 U8162 ( .A1(n8497), .A2(\cpuregs[27][21] ), .B1(
        n8499), .B2(\cpuregs[3][21] ), .Y(n6645) );
  sky130_fd_sc_hd__a22oi_1 U8163 ( .A1(n8492), .A2(\cpuregs[4][21] ), .B1(
        n8465), .B2(\cpuregs[16][21] ), .Y(n6644) );
  sky130_fd_sc_hd__a22oi_1 U8164 ( .A1(n8489), .A2(\cpuregs[17][21] ), .B1(
        n4233), .B2(\cpuregs[8][21] ), .Y(n6643) );
  sky130_fd_sc_hd__a22oi_1 U8165 ( .A1(n8482), .A2(\cpuregs[22][21] ), .B1(
        n8471), .B2(\cpuregs[5][21] ), .Y(n6642) );
  sky130_fd_sc_hd__nand4_1 U8166 ( .A(n6645), .B(n6644), .C(n6643), .D(n6642), 
        .Y(n6651) );
  sky130_fd_sc_hd__a22oi_1 U8167 ( .A1(n8466), .A2(\cpuregs[25][21] ), .B1(
        n8479), .B2(\cpuregs[2][21] ), .Y(n6649) );
  sky130_fd_sc_hd__a22oi_1 U8168 ( .A1(n8480), .A2(\cpuregs[21][21] ), .B1(
        n8470), .B2(\cpuregs[10][21] ), .Y(n6648) );
  sky130_fd_sc_hd__a22oi_1 U8169 ( .A1(n8477), .A2(\cpuregs[7][21] ), .B1(
        n8472), .B2(\cpuregs[18][21] ), .Y(n6647) );
  sky130_fd_sc_hd__a22oi_1 U8170 ( .A1(n8464), .A2(\cpuregs[23][21] ), .B1(
        n8036), .B2(\cpuregs[9][21] ), .Y(n6646) );
  sky130_fd_sc_hd__nand4_1 U8171 ( .A(n6649), .B(n6648), .C(n6647), .D(n6646), 
        .Y(n6650) );
  sky130_fd_sc_hd__nor4_1 U8172 ( .A(n6653), .B(n6652), .C(n6651), .D(n6650), 
        .Y(n6655) );
  sky130_fd_sc_hd__a22oi_1 U8173 ( .A1(pcpi_rs2[21]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[21]), .Y(n6654) );
  sky130_fd_sc_hd__o21ai_1 U8174 ( .A1(n6655), .A2(n8514), .B1(n6654), .Y(
        n3937) );
  sky130_fd_sc_hd__o21ai_1 U8175 ( .A1(n6658), .A2(n6657), .B1(n6656), .Y(
        n7034) );
  sky130_fd_sc_hd__a21oi_1 U8176 ( .A1(n7034), .A2(n6660), .B1(n6659), .Y(
        n7691) );
  sky130_fd_sc_hd__nand2_1 U8177 ( .A(n6661), .B(n7690), .Y(n6662) );
  sky130_fd_sc_hd__xor2_1 U8178 ( .A(n7691), .B(n6662), .X(n6663) );
  sky130_fd_sc_hd__nand2_1 U8179 ( .A(n6663), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n6668) );
  sky130_fd_sc_hd__nor2_1 U8180 ( .A(n8683), .B(n6664), .Y(n6665) );
  sky130_fd_sc_hd__a31oi_1 U8181 ( .A1(n9382), .A2(pcpi_rs1[21]), .A3(
        pcpi_rs2[21]), .B1(n6665), .Y(n6667) );
  sky130_fd_sc_hd__o21ai_1 U8182 ( .A1(pcpi_rs1[21]), .A2(pcpi_rs2[21]), .B1(
        n9872), .Y(n6666) );
  sky130_fd_sc_hd__nand3_1 U8183 ( .A(n6668), .B(n6667), .C(n6666), .Y(
        alu_out[21]) );
  sky130_fd_sc_hd__a22o_1 U8184 ( .A1(n10055), .A2(n6669), .B1(n9530), .B2(
        reg_pc[21]), .X(n3998) );
  sky130_fd_sc_hd__nand2_1 U8185 ( .A(n6672), .B(n6671), .Y(n6676) );
  sky130_fd_sc_hd__a21oi_1 U8186 ( .A1(n7221), .A2(n6674), .B1(n6673), .Y(
        n7130) );
  sky130_fd_sc_hd__o21ai_1 U8187 ( .A1(n7438), .A2(n7130), .B1(n7439), .Y(
        n6675) );
  sky130_fd_sc_hd__xnor2_1 U8188 ( .A(n6676), .B(n6675), .Y(n6677) );
  sky130_fd_sc_hd__nand2_1 U8189 ( .A(n6677), .B(n4639), .Y(n6682) );
  sky130_fd_sc_hd__a22oi_1 U8190 ( .A1(n9861), .A2(count_cycle[57]), .B1(n9860), .B2(count_cycle[25]), .Y(n6681) );
  sky130_fd_sc_hd__a22o_1 U8191 ( .A1(pcpi_rs1[25]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[25]), .X(n6678) );
  sky130_fd_sc_hd__a211oi_1 U8192 ( .A1(n9857), .A2(count_instr[25]), .B1(
        n7707), .C1(n6678), .Y(n6680) );
  sky130_fd_sc_hd__nand2_1 U8193 ( .A(n9856), .B(count_instr[57]), .Y(n6679)
         );
  sky130_fd_sc_hd__nand4_1 U8194 ( .A(n6682), .B(n6681), .C(n6680), .D(n6679), 
        .Y(N1902) );
  sky130_fd_sc_hd__nand2_1 U8195 ( .A(n7061), .B(n6686), .Y(n7448) );
  sky130_fd_sc_hd__nor2_1 U8196 ( .A(n7542), .B(n7448), .Y(n6687) );
  sky130_fd_sc_hd__xnor2_1 U8197 ( .A(n6688), .B(n6687), .Y(n6689) );
  sky130_fd_sc_hd__a222oi_1 U8198 ( .A1(alu_out_q[25]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[25]), .C1(n6689), .C2(n9813), .Y(n6703) );
  sky130_fd_sc_hd__nand2_1 U8199 ( .A(n10057), .B(\cpuregs[24][25] ), .Y(n6690) );
  sky130_fd_sc_hd__o21ai_1 U8200 ( .A1(n10057), .A2(n4182), .B1(n6690), .Y(
        n3144) );
  sky130_fd_sc_hd__nand2_1 U8201 ( .A(n4177), .B(\cpuregs[30][25] ), .Y(n6691)
         );
  sky130_fd_sc_hd__o21ai_1 U8202 ( .A1(n4177), .A2(n4182), .B1(n6691), .Y(
        n3150) );
  sky130_fd_sc_hd__nand2_1 U8203 ( .A(n7452), .B(\cpuregs[9][25] ), .Y(n6692)
         );
  sky130_fd_sc_hd__o21ai_1 U8204 ( .A1(n7452), .A2(n4182), .B1(n6692), .Y(
        n3129) );
  sky130_fd_sc_hd__nand2_1 U8205 ( .A(n4173), .B(\cpuregs[23][25] ), .Y(n6693)
         );
  sky130_fd_sc_hd__o21ai_1 U8206 ( .A1(n4173), .A2(n4182), .B1(n6693), .Y(
        n3143) );
  sky130_fd_sc_hd__nand2_1 U8207 ( .A(n7069), .B(\cpuregs[15][25] ), .Y(n6694)
         );
  sky130_fd_sc_hd__o21ai_1 U8208 ( .A1(n7069), .A2(n4182), .B1(n6694), .Y(
        n3135) );
  sky130_fd_sc_hd__nand2_1 U8209 ( .A(n4219), .B(\cpuregs[28][25] ), .Y(n6695)
         );
  sky130_fd_sc_hd__o21ai_1 U8210 ( .A1(n4219), .A2(n4182), .B1(n6695), .Y(
        n3148) );
  sky130_fd_sc_hd__nand2_1 U8211 ( .A(n4199), .B(\cpuregs[7][25] ), .Y(n6696)
         );
  sky130_fd_sc_hd__o21ai_1 U8212 ( .A1(n4199), .A2(n4182), .B1(n6696), .Y(
        n3127) );
  sky130_fd_sc_hd__nand2_1 U8213 ( .A(n4226), .B(\cpuregs[12][25] ), .Y(n6697)
         );
  sky130_fd_sc_hd__o21ai_1 U8214 ( .A1(n4226), .A2(n4182), .B1(n6697), .Y(
        n3132) );
  sky130_fd_sc_hd__nand2_1 U8215 ( .A(n4184), .B(\cpuregs[10][25] ), .Y(n6698)
         );
  sky130_fd_sc_hd__o21ai_1 U8216 ( .A1(n4184), .A2(n4182), .B1(n6698), .Y(
        n3130) );
  sky130_fd_sc_hd__nand2_1 U8217 ( .A(n9820), .B(\cpuregs[18][25] ), .Y(n6699)
         );
  sky130_fd_sc_hd__o21ai_1 U8218 ( .A1(n9820), .A2(n4182), .B1(n6699), .Y(
        n3138) );
  sky130_fd_sc_hd__nand2_1 U8219 ( .A(n6897), .B(\cpuregs[14][25] ), .Y(n6700)
         );
  sky130_fd_sc_hd__o21ai_1 U8220 ( .A1(n6897), .A2(n4182), .B1(n6700), .Y(
        n3134) );
  sky130_fd_sc_hd__nand2_1 U8221 ( .A(n4174), .B(\cpuregs[21][25] ), .Y(n6701)
         );
  sky130_fd_sc_hd__o21ai_1 U8222 ( .A1(n4174), .A2(n4182), .B1(n6701), .Y(
        n3141) );
  sky130_fd_sc_hd__nand2_1 U8223 ( .A(n4192), .B(\cpuregs[25][25] ), .Y(n6702)
         );
  sky130_fd_sc_hd__o21ai_1 U8224 ( .A1(n4192), .A2(n4182), .B1(n6702), .Y(
        n3145) );
  sky130_fd_sc_hd__nand2_1 U8225 ( .A(n4178), .B(\cpuregs[2][25] ), .Y(n6704)
         );
  sky130_fd_sc_hd__o21ai_1 U8226 ( .A1(n4178), .A2(n4182), .B1(n6704), .Y(
        n3122) );
  sky130_fd_sc_hd__nand2_1 U8227 ( .A(n7247), .B(\cpuregs[31][25] ), .Y(n6705)
         );
  sky130_fd_sc_hd__o21ai_1 U8228 ( .A1(n7247), .A2(n4182), .B1(n6705), .Y(
        n3151) );
  sky130_fd_sc_hd__nand2_1 U8229 ( .A(n4180), .B(\cpuregs[5][25] ), .Y(n6706)
         );
  sky130_fd_sc_hd__o21ai_1 U8230 ( .A1(n4180), .A2(n4182), .B1(n6706), .Y(
        n3125) );
  sky130_fd_sc_hd__nand2_1 U8231 ( .A(n4183), .B(\cpuregs[8][25] ), .Y(n6707)
         );
  sky130_fd_sc_hd__o21ai_1 U8232 ( .A1(n4183), .A2(n4182), .B1(n6707), .Y(
        n3128) );
  sky130_fd_sc_hd__nand2_1 U8233 ( .A(n7084), .B(\cpuregs[22][25] ), .Y(n6708)
         );
  sky130_fd_sc_hd__o21ai_1 U8234 ( .A1(n7084), .A2(n4182), .B1(n6708), .Y(
        n3142) );
  sky130_fd_sc_hd__nand2_1 U8235 ( .A(n4175), .B(\cpuregs[27][25] ), .Y(n6709)
         );
  sky130_fd_sc_hd__o21ai_1 U8236 ( .A1(n4175), .A2(n4182), .B1(n6709), .Y(
        n3147) );
  sky130_fd_sc_hd__nand2_1 U8237 ( .A(n4195), .B(\cpuregs[17][25] ), .Y(n6710)
         );
  sky130_fd_sc_hd__o21ai_1 U8238 ( .A1(n4195), .A2(n4182), .B1(n6710), .Y(
        n3137) );
  sky130_fd_sc_hd__nand2_1 U8239 ( .A(n4179), .B(\cpuregs[4][25] ), .Y(n6711)
         );
  sky130_fd_sc_hd__o21ai_1 U8240 ( .A1(n4179), .A2(n4182), .B1(n6711), .Y(
        n3124) );
  sky130_fd_sc_hd__nand2_1 U8241 ( .A(n4201), .B(\cpuregs[3][25] ), .Y(n6712)
         );
  sky130_fd_sc_hd__o21ai_1 U8242 ( .A1(n4201), .A2(n4182), .B1(n6712), .Y(
        n3123) );
  sky130_fd_sc_hd__nand2_1 U8243 ( .A(n4186), .B(\cpuregs[13][25] ), .Y(n6713)
         );
  sky130_fd_sc_hd__o21ai_1 U8244 ( .A1(n4186), .A2(n4182), .B1(n6713), .Y(
        n3133) );
  sky130_fd_sc_hd__nand2_1 U8245 ( .A(n4197), .B(\cpuregs[16][25] ), .Y(n6714)
         );
  sky130_fd_sc_hd__o21ai_1 U8246 ( .A1(n4197), .A2(n4182), .B1(n6714), .Y(
        n3136) );
  sky130_fd_sc_hd__nand2_1 U8247 ( .A(n6396), .B(\cpuregs[1][25] ), .Y(n6715)
         );
  sky130_fd_sc_hd__o21ai_1 U8248 ( .A1(n6396), .A2(n4182), .B1(n6715), .Y(
        n3121) );
  sky130_fd_sc_hd__nand2_1 U8249 ( .A(n4194), .B(\cpuregs[19][25] ), .Y(n6716)
         );
  sky130_fd_sc_hd__o21ai_1 U8250 ( .A1(n4194), .A2(n4182), .B1(n6716), .Y(
        n3139) );
  sky130_fd_sc_hd__nand2_1 U8251 ( .A(n4176), .B(\cpuregs[29][25] ), .Y(n6717)
         );
  sky130_fd_sc_hd__o21ai_1 U8252 ( .A1(n4176), .A2(n4182), .B1(n6717), .Y(
        n3149) );
  sky130_fd_sc_hd__nand2_1 U8253 ( .A(n4185), .B(\cpuregs[11][25] ), .Y(n6718)
         );
  sky130_fd_sc_hd__o21ai_1 U8254 ( .A1(n4185), .A2(n4182), .B1(n6718), .Y(
        n3131) );
  sky130_fd_sc_hd__nand2_1 U8255 ( .A(n10058), .B(\cpuregs[20][25] ), .Y(n6719) );
  sky130_fd_sc_hd__o21ai_1 U8256 ( .A1(n10058), .A2(n4182), .B1(n6719), .Y(
        n3140) );
  sky130_fd_sc_hd__nand2_1 U8257 ( .A(n9621), .B(\cpuregs[26][25] ), .Y(n6720)
         );
  sky130_fd_sc_hd__o21ai_1 U8258 ( .A1(n9621), .A2(n4182), .B1(n6720), .Y(
        n3146) );
  sky130_fd_sc_hd__nand2_1 U8259 ( .A(n9772), .B(\cpuregs[6][25] ), .Y(n6721)
         );
  sky130_fd_sc_hd__o21ai_1 U8260 ( .A1(n9772), .A2(n4182), .B1(n6721), .Y(
        n3126) );
  sky130_fd_sc_hd__a22oi_1 U8261 ( .A1(decoded_imm[25]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[25]), .Y(n6722) );
  sky130_fd_sc_hd__nand2_1 U8262 ( .A(n8437), .B(n6722), .Y(n2847) );
  sky130_fd_sc_hd__a22oi_1 U8263 ( .A1(\cpuregs[29][25] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][25] ), .Y(n6726) );
  sky130_fd_sc_hd__a22oi_1 U8264 ( .A1(n8478), .A2(\cpuregs[13][25] ), .B1(
        \cpuregs[31][25] ), .B2(n8487), .Y(n6725) );
  sky130_fd_sc_hd__a22oi_1 U8265 ( .A1(n8498), .A2(\cpuregs[14][25] ), .B1(
        \cpuregs[12][25] ), .B2(n8491), .Y(n6724) );
  sky130_fd_sc_hd__a22oi_1 U8266 ( .A1(n8501), .A2(\cpuregs[15][25] ), .B1(
        \cpuregs[28][25] ), .B2(n8490), .Y(n6723) );
  sky130_fd_sc_hd__nand4_1 U8267 ( .A(n6726), .B(n6725), .C(n6724), .D(n6723), 
        .Y(n6742) );
  sky130_fd_sc_hd__a22oi_1 U8268 ( .A1(n8467), .A2(\cpuregs[26][25] ), .B1(
        n8481), .B2(\cpuregs[11][25] ), .Y(n6730) );
  sky130_fd_sc_hd__a22oi_1 U8269 ( .A1(n6059), .A2(\cpuregs[20][25] ), .B1(
        n8502), .B2(\cpuregs[6][25] ), .Y(n6729) );
  sky130_fd_sc_hd__a22oi_1 U8270 ( .A1(n6412), .A2(\cpuregs[19][25] ), .B1(
        n8488), .B2(\cpuregs[1][25] ), .Y(n6728) );
  sky130_fd_sc_hd__nand2_1 U8271 ( .A(n8500), .B(\cpuregs[30][25] ), .Y(n6727)
         );
  sky130_fd_sc_hd__nand4_1 U8272 ( .A(n6730), .B(n6729), .C(n6728), .D(n6727), 
        .Y(n6741) );
  sky130_fd_sc_hd__a22oi_1 U8273 ( .A1(n8497), .A2(\cpuregs[27][25] ), .B1(
        n8499), .B2(\cpuregs[3][25] ), .Y(n6734) );
  sky130_fd_sc_hd__a22oi_1 U8274 ( .A1(\cpuregs[4][25] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][25] ), .Y(n6733) );
  sky130_fd_sc_hd__a22oi_1 U8275 ( .A1(n8489), .A2(\cpuregs[17][25] ), .B1(
        n4233), .B2(\cpuregs[8][25] ), .Y(n6732) );
  sky130_fd_sc_hd__a22oi_1 U8276 ( .A1(n8482), .A2(\cpuregs[22][25] ), .B1(
        n8471), .B2(\cpuregs[5][25] ), .Y(n6731) );
  sky130_fd_sc_hd__nand4_1 U8277 ( .A(n6734), .B(n6733), .C(n6732), .D(n6731), 
        .Y(n6740) );
  sky130_fd_sc_hd__a22oi_1 U8278 ( .A1(n8466), .A2(\cpuregs[25][25] ), .B1(
        n8479), .B2(\cpuregs[2][25] ), .Y(n6738) );
  sky130_fd_sc_hd__a22oi_1 U8279 ( .A1(\cpuregs[21][25] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][25] ), .Y(n6737) );
  sky130_fd_sc_hd__a22oi_1 U8280 ( .A1(\cpuregs[7][25] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][25] ), .Y(n6736) );
  sky130_fd_sc_hd__a22oi_1 U8281 ( .A1(\cpuregs[23][25] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][25] ), .Y(n6735) );
  sky130_fd_sc_hd__nand4_1 U8282 ( .A(n6738), .B(n6737), .C(n6736), .D(n6735), 
        .Y(n6739) );
  sky130_fd_sc_hd__nor4_1 U8283 ( .A(n6742), .B(n6741), .C(n6740), .D(n6739), 
        .Y(n6744) );
  sky130_fd_sc_hd__a22oi_1 U8284 ( .A1(pcpi_rs2[25]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[25]), .Y(n6743) );
  sky130_fd_sc_hd__o21ai_1 U8285 ( .A1(n6744), .A2(n8514), .B1(n6743), .Y(
        n3933) );
  sky130_fd_sc_hd__a21oi_1 U8286 ( .A1(n6747), .A2(n6746), .B1(n6745), .Y(
        n7607) );
  sky130_fd_sc_hd__nand2_1 U8287 ( .A(n6748), .B(n7606), .Y(n6749) );
  sky130_fd_sc_hd__xor2_1 U8288 ( .A(n7607), .B(n6749), .X(n6754) );
  sky130_fd_sc_hd__a21oi_1 U8289 ( .A1(n9873), .A2(n6752), .B1(n9872), .Y(
        n6750) );
  sky130_fd_sc_hd__o22ai_1 U8290 ( .A1(n9877), .A2(n6752), .B1(n6751), .B2(
        n6750), .Y(n6753) );
  sky130_fd_sc_hd__a22o_1 U8291 ( .A1(n10055), .A2(n6755), .B1(n9530), .B2(
        reg_pc[25]), .X(n3994) );
  sky130_fd_sc_hd__nand2_1 U8292 ( .A(n6758), .B(n6757), .Y(n6762) );
  sky130_fd_sc_hd__a21oi_1 U8293 ( .A1(n6851), .A2(n6760), .B1(n6759), .Y(
        n7180) );
  sky130_fd_sc_hd__o21ai_1 U8294 ( .A1(n7544), .A2(n7180), .B1(n7545), .Y(
        n6761) );
  sky130_fd_sc_hd__xnor2_1 U8295 ( .A(n6762), .B(n6761), .Y(n6763) );
  sky130_fd_sc_hd__nand2_1 U8296 ( .A(n6763), .B(n9511), .Y(n6789) );
  sky130_fd_sc_hd__a22oi_1 U8297 ( .A1(n9307), .A2(pcpi_rs1[21]), .B1(
        pcpi_rs1[24]), .B2(n8927), .Y(n6788) );
  sky130_fd_sc_hd__a22oi_1 U8298 ( .A1(n9280), .A2(reg_pc[25]), .B1(n9345), 
        .B2(pcpi_rs1[29]), .Y(n6787) );
  sky130_fd_sc_hd__a22oi_1 U8299 ( .A1(n9478), .A2(\cpuregs[1][25] ), .B1(
        n9496), .B2(\cpuregs[3][25] ), .Y(n6767) );
  sky130_fd_sc_hd__a22oi_1 U8300 ( .A1(n9493), .A2(\cpuregs[6][25] ), .B1(
        n9456), .B2(\cpuregs[17][25] ), .Y(n6766) );
  sky130_fd_sc_hd__nand2_1 U8301 ( .A(n9484), .B(\cpuregs[12][25] ), .Y(n6765)
         );
  sky130_fd_sc_hd__a22oi_1 U8302 ( .A1(n9462), .A2(\cpuregs[2][25] ), .B1(
        n9316), .B2(\cpuregs[4][25] ), .Y(n6764) );
  sky130_fd_sc_hd__nand4_1 U8303 ( .A(n6767), .B(n6766), .C(n6765), .D(n6764), 
        .Y(n6783) );
  sky130_fd_sc_hd__a22oi_1 U8304 ( .A1(n9480), .A2(\cpuregs[20][25] ), .B1(
        n9473), .B2(\cpuregs[23][25] ), .Y(n6771) );
  sky130_fd_sc_hd__a22oi_1 U8305 ( .A1(n9490), .A2(\cpuregs[11][25] ), .B1(
        n9491), .B2(\cpuregs[10][25] ), .Y(n6770) );
  sky130_fd_sc_hd__a22oi_1 U8306 ( .A1(n9321), .A2(\cpuregs[27][25] ), .B1(
        n9471), .B2(\cpuregs[25][25] ), .Y(n6769) );
  sky130_fd_sc_hd__a22oi_1 U8307 ( .A1(n9460), .A2(\cpuregs[24][25] ), .B1(
        n9485), .B2(\cpuregs[21][25] ), .Y(n6768) );
  sky130_fd_sc_hd__nand4_1 U8308 ( .A(n6771), .B(n6770), .C(n6769), .D(n6768), 
        .Y(n6782) );
  sky130_fd_sc_hd__a22oi_1 U8309 ( .A1(n9468), .A2(\cpuregs[16][25] ), .B1(
        n9459), .B2(\cpuregs[18][25] ), .Y(n6775) );
  sky130_fd_sc_hd__a22oi_1 U8310 ( .A1(n9467), .A2(\cpuregs[26][25] ), .B1(
        n9494), .B2(\cpuregs[8][25] ), .Y(n6774) );
  sky130_fd_sc_hd__a22oi_1 U8311 ( .A1(n9483), .A2(\cpuregs[7][25] ), .B1(
        n9461), .B2(\cpuregs[5][25] ), .Y(n6773) );
  sky130_fd_sc_hd__a22oi_1 U8312 ( .A1(n9469), .A2(\cpuregs[9][25] ), .B1(
        n9457), .B2(\cpuregs[19][25] ), .Y(n6772) );
  sky130_fd_sc_hd__nand4_1 U8313 ( .A(n6775), .B(n6774), .C(n6773), .D(n6772), 
        .Y(n6781) );
  sky130_fd_sc_hd__a22oi_1 U8314 ( .A1(n9481), .A2(\cpuregs[14][25] ), .B1(
        n8937), .B2(\cpuregs[13][25] ), .Y(n6779) );
  sky130_fd_sc_hd__a22oi_1 U8315 ( .A1(n9482), .A2(\cpuregs[31][25] ), .B1(
        n9495), .B2(\cpuregs[22][25] ), .Y(n6778) );
  sky130_fd_sc_hd__a22oi_1 U8316 ( .A1(n9458), .A2(\cpuregs[30][25] ), .B1(
        n9479), .B2(\cpuregs[29][25] ), .Y(n6777) );
  sky130_fd_sc_hd__a22oi_1 U8317 ( .A1(n9492), .A2(\cpuregs[28][25] ), .B1(
        n9497), .B2(\cpuregs[15][25] ), .Y(n6776) );
  sky130_fd_sc_hd__nand4_1 U8318 ( .A(n6779), .B(n6778), .C(n6777), .D(n6776), 
        .Y(n6780) );
  sky130_fd_sc_hd__nor4_1 U8319 ( .A(n6783), .B(n6782), .C(n6781), .D(n6780), 
        .Y(n6784) );
  sky130_fd_sc_hd__o22ai_1 U8320 ( .A1(n8918), .A2(n8848), .B1(n6784), .B2(
        n9302), .Y(n6785) );
  sky130_fd_sc_hd__mux2i_1 U8321 ( .A0(pcpi_rs1[25]), .A1(n6785), .S(n9340), 
        .Y(n6786) );
  sky130_fd_sc_hd__nand4_1 U8322 ( .A(n6789), .B(n6788), .C(n6787), .D(n6786), 
        .Y(n2770) );
  sky130_fd_sc_hd__a21oi_1 U8323 ( .A1(n7428), .A2(n7427), .B1(n6792), .Y(
        n6797) );
  sky130_fd_sc_hd__nand2_1 U8324 ( .A(n6795), .B(n6794), .Y(n6796) );
  sky130_fd_sc_hd__xor2_1 U8325 ( .A(n6797), .B(n6796), .X(n6798) );
  sky130_fd_sc_hd__nand2_1 U8326 ( .A(n6798), .B(n9511), .Y(n6825) );
  sky130_fd_sc_hd__a22oi_1 U8327 ( .A1(n9280), .A2(reg_pc[21]), .B1(n9452), 
        .B2(pcpi_rs1[21]), .Y(n6824) );
  sky130_fd_sc_hd__o22ai_1 U8328 ( .A1(n8955), .A2(n4342), .B1(n7549), .B2(
        n4340), .Y(n6821) );
  sky130_fd_sc_hd__a22oi_1 U8329 ( .A1(n9479), .A2(\cpuregs[29][21] ), .B1(
        n9480), .B2(\cpuregs[20][21] ), .Y(n6802) );
  sky130_fd_sc_hd__a22oi_1 U8330 ( .A1(n9493), .A2(\cpuregs[6][21] ), .B1(
        n9461), .B2(\cpuregs[5][21] ), .Y(n6801) );
  sky130_fd_sc_hd__a22oi_1 U8331 ( .A1(n9478), .A2(\cpuregs[1][21] ), .B1(
        n9495), .B2(\cpuregs[22][21] ), .Y(n6800) );
  sky130_fd_sc_hd__nand2_1 U8332 ( .A(n9472), .B(\cpuregs[4][21] ), .Y(n6799)
         );
  sky130_fd_sc_hd__nand4_1 U8333 ( .A(n6802), .B(n6801), .C(n6800), .D(n6799), 
        .Y(n6818) );
  sky130_fd_sc_hd__a22oi_1 U8334 ( .A1(n9471), .A2(\cpuregs[25][21] ), .B1(
        n9467), .B2(\cpuregs[26][21] ), .Y(n6806) );
  sky130_fd_sc_hd__a22oi_1 U8335 ( .A1(n9321), .A2(\cpuregs[27][21] ), .B1(
        n9485), .B2(\cpuregs[21][21] ), .Y(n6805) );
  sky130_fd_sc_hd__a22oi_1 U8336 ( .A1(n9462), .A2(\cpuregs[2][21] ), .B1(
        n9457), .B2(\cpuregs[19][21] ), .Y(n6804) );
  sky130_fd_sc_hd__a22oi_1 U8337 ( .A1(n9496), .A2(\cpuregs[3][21] ), .B1(
        n9458), .B2(\cpuregs[30][21] ), .Y(n6803) );
  sky130_fd_sc_hd__nand4_1 U8338 ( .A(n6806), .B(n6805), .C(n6804), .D(n6803), 
        .Y(n6817) );
  sky130_fd_sc_hd__a22oi_1 U8339 ( .A1(n9494), .A2(\cpuregs[8][21] ), .B1(
        n9497), .B2(\cpuregs[15][21] ), .Y(n6810) );
  sky130_fd_sc_hd__a22oi_1 U8340 ( .A1(n9481), .A2(\cpuregs[14][21] ), .B1(
        n9456), .B2(\cpuregs[17][21] ), .Y(n6809) );
  sky130_fd_sc_hd__a22oi_1 U8341 ( .A1(n9492), .A2(\cpuregs[28][21] ), .B1(
        n9468), .B2(\cpuregs[16][21] ), .Y(n6808) );
  sky130_fd_sc_hd__a22oi_1 U8342 ( .A1(n9491), .A2(\cpuregs[10][21] ), .B1(
        n9469), .B2(\cpuregs[9][21] ), .Y(n6807) );
  sky130_fd_sc_hd__nand4_1 U8343 ( .A(n6810), .B(n6809), .C(n6808), .D(n6807), 
        .Y(n6816) );
  sky130_fd_sc_hd__a22oi_1 U8344 ( .A1(n8937), .A2(\cpuregs[13][21] ), .B1(
        n9473), .B2(\cpuregs[23][21] ), .Y(n6814) );
  sky130_fd_sc_hd__a22oi_1 U8345 ( .A1(n9490), .A2(\cpuregs[11][21] ), .B1(
        n9484), .B2(\cpuregs[12][21] ), .Y(n6813) );
  sky130_fd_sc_hd__a22oi_1 U8346 ( .A1(n9460), .A2(\cpuregs[24][21] ), .B1(
        n9459), .B2(\cpuregs[18][21] ), .Y(n6812) );
  sky130_fd_sc_hd__a22oi_1 U8347 ( .A1(n9483), .A2(\cpuregs[7][21] ), .B1(
        n9482), .B2(\cpuregs[31][21] ), .Y(n6811) );
  sky130_fd_sc_hd__nand4_1 U8348 ( .A(n6814), .B(n6813), .C(n6812), .D(n6811), 
        .Y(n6815) );
  sky130_fd_sc_hd__nor4_1 U8349 ( .A(n6818), .B(n6817), .C(n6816), .D(n6815), 
        .Y(n6819) );
  sky130_fd_sc_hd__o22ai_1 U8350 ( .A1(n6819), .A2(n9506), .B1(n8888), .B2(
        n4371), .Y(n6820) );
  sky130_fd_sc_hd__nor2_1 U8351 ( .A(n6821), .B(n6820), .Y(n6823) );
  sky130_fd_sc_hd__nand2_1 U8352 ( .A(n9345), .B(pcpi_rs1[25]), .Y(n6822) );
  sky130_fd_sc_hd__nand4_1 U8353 ( .A(n6825), .B(n6824), .C(n6823), .D(n6822), 
        .Y(n2774) );
  sky130_fd_sc_hd__a22oi_1 U8354 ( .A1(n9460), .A2(\cpuregs[24][17] ), .B1(
        n9495), .B2(\cpuregs[22][17] ), .Y(n6829) );
  sky130_fd_sc_hd__a22oi_1 U8355 ( .A1(n9479), .A2(\cpuregs[29][17] ), .B1(
        n9492), .B2(\cpuregs[28][17] ), .Y(n6828) );
  sky130_fd_sc_hd__a22oi_1 U8356 ( .A1(n9478), .A2(\cpuregs[1][17] ), .B1(
        n9493), .B2(\cpuregs[6][17] ), .Y(n6827) );
  sky130_fd_sc_hd__nand2_1 U8357 ( .A(n9456), .B(\cpuregs[17][17] ), .Y(n6826)
         );
  sky130_fd_sc_hd__nand4_1 U8358 ( .A(n6829), .B(n6828), .C(n6827), .D(n6826), 
        .Y(n6845) );
  sky130_fd_sc_hd__a22oi_1 U8359 ( .A1(n9484), .A2(\cpuregs[12][17] ), .B1(
        n9497), .B2(\cpuregs[15][17] ), .Y(n6833) );
  sky130_fd_sc_hd__a22oi_1 U8360 ( .A1(n9471), .A2(\cpuregs[25][17] ), .B1(
        n9461), .B2(\cpuregs[5][17] ), .Y(n6832) );
  sky130_fd_sc_hd__a22oi_1 U8361 ( .A1(n9458), .A2(\cpuregs[30][17] ), .B1(
        n9468), .B2(\cpuregs[16][17] ), .Y(n6831) );
  sky130_fd_sc_hd__a22oi_1 U8362 ( .A1(n9483), .A2(\cpuregs[7][17] ), .B1(
        n9482), .B2(\cpuregs[31][17] ), .Y(n6830) );
  sky130_fd_sc_hd__nand4_1 U8363 ( .A(n6833), .B(n6832), .C(n6831), .D(n6830), 
        .Y(n6844) );
  sky130_fd_sc_hd__a22oi_1 U8364 ( .A1(n9473), .A2(\cpuregs[23][17] ), .B1(
        n9457), .B2(\cpuregs[19][17] ), .Y(n6837) );
  sky130_fd_sc_hd__a22oi_1 U8365 ( .A1(n9462), .A2(\cpuregs[2][17] ), .B1(
        n9480), .B2(\cpuregs[20][17] ), .Y(n6836) );
  sky130_fd_sc_hd__a22oi_1 U8366 ( .A1(n9494), .A2(\cpuregs[8][17] ), .B1(
        n9459), .B2(\cpuregs[18][17] ), .Y(n6835) );
  sky130_fd_sc_hd__a22oi_1 U8367 ( .A1(n9472), .A2(\cpuregs[4][17] ), .B1(
        n8937), .B2(\cpuregs[13][17] ), .Y(n6834) );
  sky130_fd_sc_hd__nand4_1 U8368 ( .A(n6837), .B(n6836), .C(n6835), .D(n6834), 
        .Y(n6843) );
  sky130_fd_sc_hd__a22oi_1 U8369 ( .A1(n9321), .A2(\cpuregs[27][17] ), .B1(
        n9491), .B2(\cpuregs[10][17] ), .Y(n6841) );
  sky130_fd_sc_hd__a22oi_1 U8370 ( .A1(n9490), .A2(\cpuregs[11][17] ), .B1(
        n9485), .B2(\cpuregs[21][17] ), .Y(n6840) );
  sky130_fd_sc_hd__a22oi_1 U8371 ( .A1(n9469), .A2(\cpuregs[9][17] ), .B1(
        n9481), .B2(\cpuregs[14][17] ), .Y(n6839) );
  sky130_fd_sc_hd__a22oi_1 U8372 ( .A1(n9467), .A2(\cpuregs[26][17] ), .B1(
        n9496), .B2(\cpuregs[3][17] ), .Y(n6838) );
  sky130_fd_sc_hd__nand4_1 U8373 ( .A(n6841), .B(n6840), .C(n6839), .D(n6838), 
        .Y(n6842) );
  sky130_fd_sc_hd__nor4_1 U8374 ( .A(n6845), .B(n6844), .C(n6843), .D(n6842), 
        .Y(n6862) );
  sky130_fd_sc_hd__o22ai_1 U8375 ( .A1(n4321), .A2(n6846), .B1(n8888), .B2(
        n9340), .Y(n6847) );
  sky130_fd_sc_hd__a21oi_1 U8376 ( .A1(n9345), .A2(pcpi_rs1[21]), .B1(n6847), 
        .Y(n6861) );
  sky130_fd_sc_hd__a21oi_1 U8377 ( .A1(n6851), .A2(n6850), .B1(n6849), .Y(
        n6856) );
  sky130_fd_sc_hd__nand2_1 U8378 ( .A(n6854), .B(n6853), .Y(n6855) );
  sky130_fd_sc_hd__xor2_1 U8379 ( .A(n6856), .B(n6855), .X(n6859) );
  sky130_fd_sc_hd__nor2_1 U8380 ( .A(n7431), .B(n4340), .Y(n6858) );
  sky130_fd_sc_hd__o22ai_1 U8381 ( .A1(n8785), .A2(n4371), .B1(n8880), .B2(
        n4342), .Y(n6857) );
  sky130_fd_sc_hd__a211oi_1 U8382 ( .A1(n9511), .A2(n6859), .B1(n6858), .C1(
        n6857), .Y(n6860) );
  sky130_fd_sc_hd__o211ai_1 U8383 ( .A1(n6862), .A2(n9506), .B1(n6861), .C1(
        n6860), .Y(n2778) );
  sky130_fd_sc_hd__o21ai_1 U8384 ( .A1(n6867), .A2(n7873), .B1(n6866), .Y(
        n7787) );
  sky130_fd_sc_hd__a21oi_1 U8385 ( .A1(n7787), .A2(n7786), .B1(n6869), .Y(
        n6874) );
  sky130_fd_sc_hd__nand2_1 U8386 ( .A(n6872), .B(n6871), .Y(n6873) );
  sky130_fd_sc_hd__xor2_1 U8387 ( .A(n6874), .B(n6873), .X(n6875) );
  sky130_fd_sc_hd__nand2_1 U8388 ( .A(n6875), .B(n4639), .Y(n6882) );
  sky130_fd_sc_hd__a22oi_1 U8389 ( .A1(n9861), .A2(count_cycle[47]), .B1(n9860), .B2(count_cycle[15]), .Y(n6881) );
  sky130_fd_sc_hd__o22ai_1 U8390 ( .A1(n8849), .A2(n9437), .B1(n6877), .B2(
        n6876), .Y(n6878) );
  sky130_fd_sc_hd__a211oi_1 U8391 ( .A1(n9857), .A2(count_instr[15]), .B1(
        n7707), .C1(n6878), .Y(n6880) );
  sky130_fd_sc_hd__nand2_1 U8392 ( .A(n9856), .B(count_instr[47]), .Y(n6879)
         );
  sky130_fd_sc_hd__nand4_1 U8393 ( .A(n6882), .B(n6881), .C(n6880), .D(n6879), 
        .Y(N1892) );
  sky130_fd_sc_hd__nor2_1 U8394 ( .A(n7811), .B(n6883), .Y(n6884) );
  sky130_fd_sc_hd__xnor2_1 U8395 ( .A(n6885), .B(n6884), .Y(n6886) );
  sky130_fd_sc_hd__a222oi_1 U8396 ( .A1(reg_out[15]), .A2(n9816), .B1(
        alu_out_q[15]), .B2(n9815), .C1(n6886), .C2(n9813), .Y(n6901) );
  sky130_fd_sc_hd__nand2_1 U8397 ( .A(n10057), .B(\cpuregs[24][15] ), .Y(n6887) );
  sky130_fd_sc_hd__o21ai_1 U8398 ( .A1(n10057), .A2(n4206), .B1(n6887), .Y(
        n3454) );
  sky130_fd_sc_hd__nand2_1 U8399 ( .A(n4177), .B(\cpuregs[30][15] ), .Y(n6888)
         );
  sky130_fd_sc_hd__o21ai_1 U8400 ( .A1(n4177), .A2(n4206), .B1(n6888), .Y(
        n3460) );
  sky130_fd_sc_hd__nand2_1 U8401 ( .A(n7452), .B(\cpuregs[9][15] ), .Y(n6889)
         );
  sky130_fd_sc_hd__o21ai_1 U8402 ( .A1(n7452), .A2(n4206), .B1(n6889), .Y(
        n3439) );
  sky130_fd_sc_hd__nand2_1 U8403 ( .A(n4173), .B(\cpuregs[23][15] ), .Y(n6890)
         );
  sky130_fd_sc_hd__o21ai_1 U8404 ( .A1(n4173), .A2(n4206), .B1(n6890), .Y(
        n3453) );
  sky130_fd_sc_hd__nand2_1 U8405 ( .A(n7069), .B(\cpuregs[15][15] ), .Y(n6891)
         );
  sky130_fd_sc_hd__o21ai_1 U8406 ( .A1(n7069), .A2(n4206), .B1(n6891), .Y(
        n3445) );
  sky130_fd_sc_hd__nand2_1 U8407 ( .A(n4219), .B(\cpuregs[28][15] ), .Y(n6892)
         );
  sky130_fd_sc_hd__o21ai_1 U8408 ( .A1(n4219), .A2(n4206), .B1(n6892), .Y(
        n3458) );
  sky130_fd_sc_hd__nand2_1 U8409 ( .A(n4199), .B(\cpuregs[7][15] ), .Y(n6893)
         );
  sky130_fd_sc_hd__o21ai_1 U8410 ( .A1(n4199), .A2(n4206), .B1(n6893), .Y(
        n3437) );
  sky130_fd_sc_hd__nand2_1 U8411 ( .A(n4226), .B(\cpuregs[12][15] ), .Y(n6894)
         );
  sky130_fd_sc_hd__o21ai_1 U8412 ( .A1(n4226), .A2(n4206), .B1(n6894), .Y(
        n3442) );
  sky130_fd_sc_hd__nand2_1 U8413 ( .A(n4184), .B(\cpuregs[10][15] ), .Y(n6895)
         );
  sky130_fd_sc_hd__o21ai_1 U8414 ( .A1(n4184), .A2(n4206), .B1(n6895), .Y(
        n3440) );
  sky130_fd_sc_hd__nand2_1 U8415 ( .A(n9820), .B(\cpuregs[18][15] ), .Y(n6896)
         );
  sky130_fd_sc_hd__o21ai_1 U8416 ( .A1(n9820), .A2(n4206), .B1(n6896), .Y(
        n3448) );
  sky130_fd_sc_hd__nand2_1 U8417 ( .A(n6897), .B(\cpuregs[14][15] ), .Y(n6898)
         );
  sky130_fd_sc_hd__o21ai_1 U8418 ( .A1(n6897), .A2(n4206), .B1(n6898), .Y(
        n3444) );
  sky130_fd_sc_hd__nand2_1 U8419 ( .A(n4174), .B(\cpuregs[21][15] ), .Y(n6899)
         );
  sky130_fd_sc_hd__o21ai_1 U8420 ( .A1(n4174), .A2(n4206), .B1(n6899), .Y(
        n3451) );
  sky130_fd_sc_hd__nand2_1 U8421 ( .A(n4192), .B(\cpuregs[25][15] ), .Y(n6900)
         );
  sky130_fd_sc_hd__o21ai_1 U8422 ( .A1(n4192), .A2(n4206), .B1(n6900), .Y(
        n3455) );
  sky130_fd_sc_hd__nand2_1 U8423 ( .A(n4178), .B(\cpuregs[2][15] ), .Y(n6902)
         );
  sky130_fd_sc_hd__o21ai_1 U8424 ( .A1(n4178), .A2(n4206), .B1(n6902), .Y(
        n3432) );
  sky130_fd_sc_hd__nand2_1 U8425 ( .A(n7247), .B(\cpuregs[31][15] ), .Y(n6903)
         );
  sky130_fd_sc_hd__o21ai_1 U8426 ( .A1(n7247), .A2(n4206), .B1(n6903), .Y(
        n3461) );
  sky130_fd_sc_hd__nand2_1 U8427 ( .A(n4180), .B(\cpuregs[5][15] ), .Y(n6904)
         );
  sky130_fd_sc_hd__o21ai_1 U8428 ( .A1(n4180), .A2(n4206), .B1(n6904), .Y(
        n3435) );
  sky130_fd_sc_hd__nand2_1 U8429 ( .A(n4183), .B(\cpuregs[8][15] ), .Y(n6905)
         );
  sky130_fd_sc_hd__o21ai_1 U8430 ( .A1(n4183), .A2(n4206), .B1(n6905), .Y(
        n3438) );
  sky130_fd_sc_hd__nand2_1 U8431 ( .A(n4175), .B(\cpuregs[27][15] ), .Y(n6906)
         );
  sky130_fd_sc_hd__o21ai_1 U8432 ( .A1(n4175), .A2(n4206), .B1(n6906), .Y(
        n3457) );
  sky130_fd_sc_hd__nand2_1 U8433 ( .A(n4195), .B(\cpuregs[17][15] ), .Y(n6907)
         );
  sky130_fd_sc_hd__o21ai_1 U8434 ( .A1(n4195), .A2(n4206), .B1(n6907), .Y(
        n3447) );
  sky130_fd_sc_hd__nand2_1 U8435 ( .A(n4179), .B(\cpuregs[4][15] ), .Y(n6908)
         );
  sky130_fd_sc_hd__o21ai_1 U8436 ( .A1(n4179), .A2(n4206), .B1(n6908), .Y(
        n3434) );
  sky130_fd_sc_hd__nand2_1 U8437 ( .A(n4201), .B(\cpuregs[3][15] ), .Y(n6909)
         );
  sky130_fd_sc_hd__o21ai_1 U8438 ( .A1(n4201), .A2(n4206), .B1(n6909), .Y(
        n3433) );
  sky130_fd_sc_hd__nand2_1 U8439 ( .A(n4186), .B(\cpuregs[13][15] ), .Y(n6910)
         );
  sky130_fd_sc_hd__o21ai_1 U8440 ( .A1(n4186), .A2(n4206), .B1(n6910), .Y(
        n3443) );
  sky130_fd_sc_hd__nand2_1 U8441 ( .A(n4197), .B(\cpuregs[16][15] ), .Y(n6911)
         );
  sky130_fd_sc_hd__o21ai_1 U8442 ( .A1(n4197), .A2(n4206), .B1(n6911), .Y(
        n3446) );
  sky130_fd_sc_hd__nand2_1 U8443 ( .A(n6396), .B(\cpuregs[1][15] ), .Y(n6912)
         );
  sky130_fd_sc_hd__o21ai_1 U8444 ( .A1(n6396), .A2(n4206), .B1(n6912), .Y(
        n3431) );
  sky130_fd_sc_hd__nand2_1 U8445 ( .A(n4194), .B(\cpuregs[19][15] ), .Y(n6913)
         );
  sky130_fd_sc_hd__o21ai_1 U8446 ( .A1(n4194), .A2(n4206), .B1(n6913), .Y(
        n3449) );
  sky130_fd_sc_hd__nand2_1 U8447 ( .A(n4176), .B(\cpuregs[29][15] ), .Y(n6914)
         );
  sky130_fd_sc_hd__o21ai_1 U8448 ( .A1(n4176), .A2(n4206), .B1(n6914), .Y(
        n3459) );
  sky130_fd_sc_hd__nand2_1 U8449 ( .A(n4185), .B(\cpuregs[11][15] ), .Y(n6915)
         );
  sky130_fd_sc_hd__o21ai_1 U8450 ( .A1(n4185), .A2(n4206), .B1(n6915), .Y(
        n3441) );
  sky130_fd_sc_hd__nand2_1 U8451 ( .A(n10058), .B(\cpuregs[20][15] ), .Y(n6916) );
  sky130_fd_sc_hd__o21ai_1 U8452 ( .A1(n10058), .A2(n4206), .B1(n6916), .Y(
        n3450) );
  sky130_fd_sc_hd__nand2_1 U8453 ( .A(n9621), .B(\cpuregs[26][15] ), .Y(n6917)
         );
  sky130_fd_sc_hd__o21ai_1 U8454 ( .A1(n9621), .A2(n4206), .B1(n6917), .Y(
        n3456) );
  sky130_fd_sc_hd__nand2_1 U8455 ( .A(n9772), .B(\cpuregs[6][15] ), .Y(n6918)
         );
  sky130_fd_sc_hd__o21ai_1 U8456 ( .A1(n9772), .A2(n4206), .B1(n6918), .Y(
        n3436) );
  sky130_fd_sc_hd__a22oi_1 U8457 ( .A1(decoded_imm[15]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[15]), .Y(n6920) );
  sky130_fd_sc_hd__nand2_1 U8458 ( .A(n5989), .B(mem_rdata_q[15]), .Y(n6919)
         );
  sky130_fd_sc_hd__nand3_1 U8459 ( .A(n7930), .B(n6920), .C(n6919), .Y(n2857)
         );
  sky130_fd_sc_hd__a22oi_1 U8460 ( .A1(\cpuregs[29][15] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][15] ), .Y(n6924) );
  sky130_fd_sc_hd__a22oi_1 U8461 ( .A1(n8478), .A2(\cpuregs[13][15] ), .B1(
        \cpuregs[31][15] ), .B2(n8487), .Y(n6923) );
  sky130_fd_sc_hd__a22oi_1 U8462 ( .A1(n8498), .A2(\cpuregs[14][15] ), .B1(
        \cpuregs[12][15] ), .B2(n8491), .Y(n6922) );
  sky130_fd_sc_hd__a22oi_1 U8463 ( .A1(n8501), .A2(\cpuregs[15][15] ), .B1(
        \cpuregs[28][15] ), .B2(n8490), .Y(n6921) );
  sky130_fd_sc_hd__nand4_1 U8464 ( .A(n6924), .B(n6923), .C(n6922), .D(n6921), 
        .Y(n6940) );
  sky130_fd_sc_hd__a22oi_1 U8465 ( .A1(n8467), .A2(\cpuregs[26][15] ), .B1(
        n8481), .B2(\cpuregs[11][15] ), .Y(n6928) );
  sky130_fd_sc_hd__a22oi_1 U8466 ( .A1(n6059), .A2(\cpuregs[20][15] ), .B1(
        n8502), .B2(\cpuregs[6][15] ), .Y(n6927) );
  sky130_fd_sc_hd__a22oi_1 U8467 ( .A1(n6412), .A2(\cpuregs[19][15] ), .B1(
        n8488), .B2(\cpuregs[1][15] ), .Y(n6926) );
  sky130_fd_sc_hd__nand2_1 U8468 ( .A(n8500), .B(\cpuregs[30][15] ), .Y(n6925)
         );
  sky130_fd_sc_hd__nand4_1 U8469 ( .A(n6928), .B(n6927), .C(n6926), .D(n6925), 
        .Y(n6939) );
  sky130_fd_sc_hd__a22oi_1 U8470 ( .A1(n8497), .A2(\cpuregs[27][15] ), .B1(
        n8499), .B2(\cpuregs[3][15] ), .Y(n6932) );
  sky130_fd_sc_hd__a22oi_1 U8471 ( .A1(\cpuregs[4][15] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][15] ), .Y(n6931) );
  sky130_fd_sc_hd__a22oi_1 U8472 ( .A1(n8489), .A2(\cpuregs[17][15] ), .B1(
        n4233), .B2(\cpuregs[8][15] ), .Y(n6930) );
  sky130_fd_sc_hd__a22oi_1 U8473 ( .A1(n8482), .A2(\cpuregs[22][15] ), .B1(
        n8471), .B2(\cpuregs[5][15] ), .Y(n6929) );
  sky130_fd_sc_hd__nand4_1 U8474 ( .A(n6932), .B(n6931), .C(n6930), .D(n6929), 
        .Y(n6938) );
  sky130_fd_sc_hd__a22oi_1 U8475 ( .A1(n8466), .A2(\cpuregs[25][15] ), .B1(
        n8479), .B2(\cpuregs[2][15] ), .Y(n6936) );
  sky130_fd_sc_hd__a22oi_1 U8476 ( .A1(\cpuregs[21][15] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][15] ), .Y(n6935) );
  sky130_fd_sc_hd__a22oi_1 U8477 ( .A1(\cpuregs[7][15] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][15] ), .Y(n6934) );
  sky130_fd_sc_hd__a22oi_1 U8478 ( .A1(\cpuregs[23][15] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][15] ), .Y(n6933) );
  sky130_fd_sc_hd__nand4_1 U8479 ( .A(n6936), .B(n6935), .C(n6934), .D(n6933), 
        .Y(n6937) );
  sky130_fd_sc_hd__nor4_1 U8480 ( .A(n6940), .B(n6939), .C(n6938), .D(n6937), 
        .Y(n6942) );
  sky130_fd_sc_hd__a22oi_1 U8481 ( .A1(pcpi_rs2[15]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[15]), .Y(n6941) );
  sky130_fd_sc_hd__o21ai_1 U8482 ( .A1(n6942), .A2(n8514), .B1(n6941), .Y(
        n3943) );
  sky130_fd_sc_hd__a21oi_1 U8483 ( .A1(n9873), .A2(n6944), .B1(n9872), .Y(
        n6943) );
  sky130_fd_sc_hd__o21ai_1 U8484 ( .A1(n6944), .A2(n9877), .B1(n6943), .Y(
        n6948) );
  sky130_fd_sc_hd__nand2_1 U8485 ( .A(n7293), .B(n7291), .Y(n6946) );
  sky130_fd_sc_hd__xnor2_1 U8486 ( .A(n6946), .B(n7294), .Y(n6947) );
  sky130_fd_sc_hd__a22o_1 U8487 ( .A1(n6949), .A2(n6948), .B1(n6947), .B2(
        is_lui_auipc_jal_jalr_addi_add_sub), .X(alu_out[15]) );
  sky130_fd_sc_hd__nand2_1 U8488 ( .A(n7084), .B(\cpuregs[22][15] ), .Y(n6950)
         );
  sky130_fd_sc_hd__o21ai_1 U8489 ( .A1(n7084), .A2(n4206), .B1(n6950), .Y(
        n3452) );
  sky130_fd_sc_hd__nand2_1 U8490 ( .A(n6951), .B(n7308), .Y(n6958) );
  sky130_fd_sc_hd__nand2_1 U8491 ( .A(n7799), .B(n6953), .Y(n6956) );
  sky130_fd_sc_hd__inv_1 U8492 ( .A(n6954), .Y(n7803) );
  sky130_fd_sc_hd__a21oi_1 U8493 ( .A1(n7803), .A2(n6953), .B1(n7307), .Y(
        n6955) );
  sky130_fd_sc_hd__o21ai_1 U8494 ( .A1(n6956), .A2(n8073), .B1(n6955), .Y(
        n6957) );
  sky130_fd_sc_hd__xnor2_1 U8495 ( .A(n6958), .B(n6957), .Y(n6959) );
  sky130_fd_sc_hd__a222oi_1 U8496 ( .A1(n6961), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[15]), .C1(n5794), .C2(n6959), .Y(n6960) );
  sky130_fd_sc_hd__a22o_1 U8497 ( .A1(n10055), .A2(n6961), .B1(n9530), .B2(
        reg_pc[15]), .X(n4004) );
  sky130_fd_sc_hd__nand2_1 U8498 ( .A(n6964), .B(n6963), .Y(n6968) );
  sky130_fd_sc_hd__a21oi_1 U8499 ( .A1(n7221), .A2(n6966), .B1(n6965), .Y(
        n7703) );
  sky130_fd_sc_hd__o21ai_1 U8500 ( .A1(n7699), .A2(n7703), .B1(n7700), .Y(
        n6967) );
  sky130_fd_sc_hd__xnor2_1 U8501 ( .A(n6968), .B(n6967), .Y(n6969) );
  sky130_fd_sc_hd__nand2_1 U8502 ( .A(n6969), .B(n4639), .Y(n6974) );
  sky130_fd_sc_hd__a22oi_1 U8503 ( .A1(n9861), .A2(count_cycle[51]), .B1(n9860), .B2(count_cycle[19]), .Y(n6973) );
  sky130_fd_sc_hd__a22o_1 U8504 ( .A1(pcpi_rs1[19]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[19]), .X(n6970) );
  sky130_fd_sc_hd__a211oi_1 U8505 ( .A1(n9857), .A2(count_instr[19]), .B1(
        n7707), .C1(n6970), .Y(n6972) );
  sky130_fd_sc_hd__nand2_1 U8506 ( .A(n9856), .B(count_instr[51]), .Y(n6971)
         );
  sky130_fd_sc_hd__nand4_1 U8507 ( .A(n6974), .B(n6973), .C(n6972), .D(n6971), 
        .Y(N1896) );
  sky130_fd_sc_hd__nor2_1 U8508 ( .A(n8881), .B(n9774), .Y(n6975) );
  sky130_fd_sc_hd__xnor2_1 U8509 ( .A(n6976), .B(n6975), .Y(n6977) );
  sky130_fd_sc_hd__a222oi_1 U8510 ( .A1(alu_out_q[19]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[19]), .C1(n6977), .C2(n9813), .Y(n6991) );
  sky130_fd_sc_hd__nand2_1 U8511 ( .A(n10057), .B(\cpuregs[24][19] ), .Y(n6978) );
  sky130_fd_sc_hd__o21ai_1 U8512 ( .A1(n10057), .A2(n4203), .B1(n6978), .Y(
        n3330) );
  sky130_fd_sc_hd__nand2_1 U8513 ( .A(n4177), .B(\cpuregs[30][19] ), .Y(n6979)
         );
  sky130_fd_sc_hd__o21ai_1 U8514 ( .A1(n4177), .A2(n4203), .B1(n6979), .Y(
        n3336) );
  sky130_fd_sc_hd__nand2_1 U8515 ( .A(n7452), .B(\cpuregs[9][19] ), .Y(n6980)
         );
  sky130_fd_sc_hd__o21ai_1 U8516 ( .A1(n7452), .A2(n4203), .B1(n6980), .Y(
        n3315) );
  sky130_fd_sc_hd__nand2_1 U8517 ( .A(n4173), .B(\cpuregs[23][19] ), .Y(n6981)
         );
  sky130_fd_sc_hd__o21ai_1 U8518 ( .A1(n4173), .A2(n4203), .B1(n6981), .Y(
        n3329) );
  sky130_fd_sc_hd__nand2_1 U8519 ( .A(n7069), .B(\cpuregs[15][19] ), .Y(n6982)
         );
  sky130_fd_sc_hd__o21ai_1 U8520 ( .A1(n7069), .A2(n4203), .B1(n6982), .Y(
        n3321) );
  sky130_fd_sc_hd__nand2_1 U8521 ( .A(n4219), .B(\cpuregs[28][19] ), .Y(n6983)
         );
  sky130_fd_sc_hd__o21ai_1 U8522 ( .A1(n4219), .A2(n4203), .B1(n6983), .Y(
        n3334) );
  sky130_fd_sc_hd__nand2_1 U8523 ( .A(n4199), .B(\cpuregs[7][19] ), .Y(n6984)
         );
  sky130_fd_sc_hd__o21ai_1 U8524 ( .A1(n4199), .A2(n4203), .B1(n6984), .Y(
        n3313) );
  sky130_fd_sc_hd__nand2_1 U8525 ( .A(n4226), .B(\cpuregs[12][19] ), .Y(n6985)
         );
  sky130_fd_sc_hd__o21ai_1 U8526 ( .A1(n4226), .A2(n4203), .B1(n6985), .Y(
        n3318) );
  sky130_fd_sc_hd__nand2_1 U8527 ( .A(n4184), .B(\cpuregs[10][19] ), .Y(n6986)
         );
  sky130_fd_sc_hd__o21ai_1 U8528 ( .A1(n4184), .A2(n4203), .B1(n6986), .Y(
        n3316) );
  sky130_fd_sc_hd__nand2_1 U8529 ( .A(n9820), .B(\cpuregs[18][19] ), .Y(n6987)
         );
  sky130_fd_sc_hd__o21ai_1 U8530 ( .A1(n9820), .A2(n4203), .B1(n6987), .Y(
        n3324) );
  sky130_fd_sc_hd__nand2_1 U8531 ( .A(n6897), .B(\cpuregs[14][19] ), .Y(n6988)
         );
  sky130_fd_sc_hd__o21ai_1 U8532 ( .A1(n6897), .A2(n4203), .B1(n6988), .Y(
        n3320) );
  sky130_fd_sc_hd__nand2_1 U8533 ( .A(n4174), .B(\cpuregs[21][19] ), .Y(n6989)
         );
  sky130_fd_sc_hd__o21ai_1 U8534 ( .A1(n4174), .A2(n4203), .B1(n6989), .Y(
        n3327) );
  sky130_fd_sc_hd__nand2_1 U8535 ( .A(n4192), .B(\cpuregs[25][19] ), .Y(n6990)
         );
  sky130_fd_sc_hd__o21ai_1 U8536 ( .A1(n4192), .A2(n4203), .B1(n6990), .Y(
        n3331) );
  sky130_fd_sc_hd__nand2_1 U8537 ( .A(n4178), .B(\cpuregs[2][19] ), .Y(n6992)
         );
  sky130_fd_sc_hd__o21ai_1 U8538 ( .A1(n4178), .A2(n4203), .B1(n6992), .Y(
        n3308) );
  sky130_fd_sc_hd__nand2_1 U8539 ( .A(n7247), .B(\cpuregs[31][19] ), .Y(n6993)
         );
  sky130_fd_sc_hd__o21ai_1 U8540 ( .A1(n7247), .A2(n4203), .B1(n6993), .Y(
        n3337) );
  sky130_fd_sc_hd__nand2_1 U8541 ( .A(n4180), .B(\cpuregs[5][19] ), .Y(n6994)
         );
  sky130_fd_sc_hd__o21ai_1 U8542 ( .A1(n4180), .A2(n4203), .B1(n6994), .Y(
        n3311) );
  sky130_fd_sc_hd__nand2_1 U8543 ( .A(n4183), .B(\cpuregs[8][19] ), .Y(n6995)
         );
  sky130_fd_sc_hd__o21ai_1 U8544 ( .A1(n4183), .A2(n4203), .B1(n6995), .Y(
        n3314) );
  sky130_fd_sc_hd__nand2_1 U8545 ( .A(n7084), .B(\cpuregs[22][19] ), .Y(n6996)
         );
  sky130_fd_sc_hd__o21ai_1 U8546 ( .A1(n7084), .A2(n4203), .B1(n6996), .Y(
        n3328) );
  sky130_fd_sc_hd__nand2_1 U8547 ( .A(n4175), .B(\cpuregs[27][19] ), .Y(n6997)
         );
  sky130_fd_sc_hd__o21ai_1 U8548 ( .A1(n4175), .A2(n4203), .B1(n6997), .Y(
        n3333) );
  sky130_fd_sc_hd__nand2_1 U8549 ( .A(n4195), .B(\cpuregs[17][19] ), .Y(n6998)
         );
  sky130_fd_sc_hd__o21ai_1 U8550 ( .A1(n4195), .A2(n4203), .B1(n6998), .Y(
        n3323) );
  sky130_fd_sc_hd__nand2_1 U8551 ( .A(n4179), .B(\cpuregs[4][19] ), .Y(n6999)
         );
  sky130_fd_sc_hd__o21ai_1 U8552 ( .A1(n4179), .A2(n4203), .B1(n6999), .Y(
        n3310) );
  sky130_fd_sc_hd__nand2_1 U8553 ( .A(n4201), .B(\cpuregs[3][19] ), .Y(n7000)
         );
  sky130_fd_sc_hd__o21ai_1 U8554 ( .A1(n4201), .A2(n4203), .B1(n7000), .Y(
        n3309) );
  sky130_fd_sc_hd__nand2_1 U8555 ( .A(n4186), .B(\cpuregs[13][19] ), .Y(n7001)
         );
  sky130_fd_sc_hd__o21ai_1 U8556 ( .A1(n4186), .A2(n4203), .B1(n7001), .Y(
        n3319) );
  sky130_fd_sc_hd__nand2_1 U8557 ( .A(n4197), .B(\cpuregs[16][19] ), .Y(n7002)
         );
  sky130_fd_sc_hd__o21ai_1 U8558 ( .A1(n4197), .A2(n4203), .B1(n7002), .Y(
        n3322) );
  sky130_fd_sc_hd__nand2_1 U8559 ( .A(n6396), .B(\cpuregs[1][19] ), .Y(n7003)
         );
  sky130_fd_sc_hd__o21ai_1 U8560 ( .A1(n6396), .A2(n4203), .B1(n7003), .Y(
        n3307) );
  sky130_fd_sc_hd__nand2_1 U8561 ( .A(n4194), .B(\cpuregs[19][19] ), .Y(n7004)
         );
  sky130_fd_sc_hd__o21ai_1 U8562 ( .A1(n4194), .A2(n4203), .B1(n7004), .Y(
        n3325) );
  sky130_fd_sc_hd__nand2_1 U8563 ( .A(n4176), .B(\cpuregs[29][19] ), .Y(n7005)
         );
  sky130_fd_sc_hd__o21ai_1 U8564 ( .A1(n4176), .A2(n4203), .B1(n7005), .Y(
        n3335) );
  sky130_fd_sc_hd__nand2_1 U8565 ( .A(n4185), .B(\cpuregs[11][19] ), .Y(n7006)
         );
  sky130_fd_sc_hd__o21ai_1 U8566 ( .A1(n4185), .A2(n4203), .B1(n7006), .Y(
        n3317) );
  sky130_fd_sc_hd__nand2_1 U8567 ( .A(n10058), .B(\cpuregs[20][19] ), .Y(n7007) );
  sky130_fd_sc_hd__o21ai_1 U8568 ( .A1(n10058), .A2(n4203), .B1(n7007), .Y(
        n3326) );
  sky130_fd_sc_hd__nand2_1 U8569 ( .A(n9621), .B(\cpuregs[26][19] ), .Y(n7008)
         );
  sky130_fd_sc_hd__o21ai_1 U8570 ( .A1(n9621), .A2(n4203), .B1(n7008), .Y(
        n3332) );
  sky130_fd_sc_hd__nand2_1 U8571 ( .A(n9209), .B(\cpuregs[6][19] ), .Y(n7009)
         );
  sky130_fd_sc_hd__o21ai_1 U8572 ( .A1(n9772), .A2(n4203), .B1(n7009), .Y(
        n3312) );
  sky130_fd_sc_hd__a22oi_1 U8573 ( .A1(decoded_imm[19]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[19]), .Y(n7011) );
  sky130_fd_sc_hd__nand2_1 U8574 ( .A(n5989), .B(mem_rdata_q[19]), .Y(n7010)
         );
  sky130_fd_sc_hd__nand3_1 U8575 ( .A(n7930), .B(n7011), .C(n7010), .Y(n2853)
         );
  sky130_fd_sc_hd__a22oi_1 U8576 ( .A1(n6137), .A2(\cpuregs[29][19] ), .B1(
        n8503), .B2(\cpuregs[24][19] ), .Y(n7015) );
  sky130_fd_sc_hd__a22oi_1 U8577 ( .A1(n8478), .A2(\cpuregs[13][19] ), .B1(
        n8487), .B2(\cpuregs[31][19] ), .Y(n7014) );
  sky130_fd_sc_hd__a22oi_1 U8578 ( .A1(n8498), .A2(\cpuregs[14][19] ), .B1(
        n8491), .B2(\cpuregs[12][19] ), .Y(n7013) );
  sky130_fd_sc_hd__a22oi_1 U8579 ( .A1(n8501), .A2(\cpuregs[15][19] ), .B1(
        n8490), .B2(\cpuregs[28][19] ), .Y(n7012) );
  sky130_fd_sc_hd__nand4_1 U8580 ( .A(n7015), .B(n7014), .C(n7013), .D(n7012), 
        .Y(n7031) );
  sky130_fd_sc_hd__a22oi_1 U8581 ( .A1(n8467), .A2(\cpuregs[26][19] ), .B1(
        n8481), .B2(\cpuregs[11][19] ), .Y(n7019) );
  sky130_fd_sc_hd__a22oi_1 U8582 ( .A1(n6059), .A2(\cpuregs[20][19] ), .B1(
        n8502), .B2(\cpuregs[6][19] ), .Y(n7018) );
  sky130_fd_sc_hd__a22oi_1 U8583 ( .A1(n6412), .A2(\cpuregs[19][19] ), .B1(
        n8488), .B2(\cpuregs[1][19] ), .Y(n7017) );
  sky130_fd_sc_hd__nand2_1 U8584 ( .A(n8500), .B(\cpuregs[30][19] ), .Y(n7016)
         );
  sky130_fd_sc_hd__nand4_1 U8585 ( .A(n7019), .B(n7018), .C(n7017), .D(n7016), 
        .Y(n7030) );
  sky130_fd_sc_hd__a22oi_1 U8586 ( .A1(n8497), .A2(\cpuregs[27][19] ), .B1(
        n8499), .B2(\cpuregs[3][19] ), .Y(n7023) );
  sky130_fd_sc_hd__a22oi_1 U8587 ( .A1(n8492), .A2(\cpuregs[4][19] ), .B1(
        n8465), .B2(\cpuregs[16][19] ), .Y(n7022) );
  sky130_fd_sc_hd__a22oi_1 U8588 ( .A1(n8489), .A2(\cpuregs[17][19] ), .B1(
        n4233), .B2(\cpuregs[8][19] ), .Y(n7021) );
  sky130_fd_sc_hd__a22oi_1 U8589 ( .A1(n8482), .A2(\cpuregs[22][19] ), .B1(
        n8471), .B2(\cpuregs[5][19] ), .Y(n7020) );
  sky130_fd_sc_hd__nand4_1 U8590 ( .A(n7023), .B(n7022), .C(n7021), .D(n7020), 
        .Y(n7029) );
  sky130_fd_sc_hd__a22oi_1 U8591 ( .A1(n8466), .A2(\cpuregs[25][19] ), .B1(
        n8479), .B2(\cpuregs[2][19] ), .Y(n7027) );
  sky130_fd_sc_hd__a22oi_1 U8592 ( .A1(n8480), .A2(\cpuregs[21][19] ), .B1(
        n8470), .B2(\cpuregs[10][19] ), .Y(n7026) );
  sky130_fd_sc_hd__a22oi_1 U8593 ( .A1(n8477), .A2(\cpuregs[7][19] ), .B1(
        n8472), .B2(\cpuregs[18][19] ), .Y(n7025) );
  sky130_fd_sc_hd__a22oi_1 U8594 ( .A1(n8464), .A2(\cpuregs[23][19] ), .B1(
        n8036), .B2(\cpuregs[9][19] ), .Y(n7024) );
  sky130_fd_sc_hd__nand4_1 U8595 ( .A(n7027), .B(n7026), .C(n7025), .D(n7024), 
        .Y(n7028) );
  sky130_fd_sc_hd__nor4_1 U8596 ( .A(n7031), .B(n7030), .C(n7029), .D(n7028), 
        .Y(n7033) );
  sky130_fd_sc_hd__a22oi_1 U8597 ( .A1(pcpi_rs2[19]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[19]), .Y(n7032) );
  sky130_fd_sc_hd__o21ai_1 U8598 ( .A1(n7033), .A2(n8514), .B1(n7032), .Y(
        n3939) );
  sky130_fd_sc_hd__nand2_1 U8599 ( .A(n7035), .B(n7391), .Y(n7036) );
  sky130_fd_sc_hd__xor2_1 U8600 ( .A(n7392), .B(n7036), .X(n7041) );
  sky130_fd_sc_hd__a21oi_1 U8601 ( .A1(n9873), .A2(n7039), .B1(n9872), .Y(
        n7037) );
  sky130_fd_sc_hd__o22ai_1 U8602 ( .A1(n7039), .A2(n9877), .B1(n7038), .B2(
        n7037), .Y(n7040) );
  sky130_fd_sc_hd__a21o_1 U8603 ( .A1(n7041), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n7040), .X(alu_out[19]) );
  sky130_fd_sc_hd__a22o_1 U8604 ( .A1(n9530), .A2(reg_pc[19]), .B1(n7042), 
        .B2(n10055), .X(n4000) );
  sky130_fd_sc_hd__o21ai_1 U8605 ( .A1(n7047), .A2(n7046), .B1(n7045), .Y(
        n7619) );
  sky130_fd_sc_hd__a21oi_1 U8606 ( .A1(n7619), .A2(n7618), .B1(n7049), .Y(
        n7054) );
  sky130_fd_sc_hd__nand2_1 U8607 ( .A(n7052), .B(n7051), .Y(n7053) );
  sky130_fd_sc_hd__xor2_1 U8608 ( .A(n7054), .B(n7053), .X(n7055) );
  sky130_fd_sc_hd__nand2_1 U8609 ( .A(n7055), .B(n4639), .Y(n7060) );
  sky130_fd_sc_hd__a22oi_1 U8610 ( .A1(n9861), .A2(count_cycle[55]), .B1(n9860), .B2(count_cycle[23]), .Y(n7059) );
  sky130_fd_sc_hd__a22o_1 U8611 ( .A1(pcpi_rs1[23]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[23]), .X(n7056) );
  sky130_fd_sc_hd__a211oi_1 U8612 ( .A1(n9857), .A2(count_instr[23]), .B1(
        n7707), .C1(n7056), .Y(n7058) );
  sky130_fd_sc_hd__nand2_1 U8613 ( .A(n9856), .B(count_instr[55]), .Y(n7057)
         );
  sky130_fd_sc_hd__nand4_1 U8614 ( .A(n7060), .B(n7059), .C(n7058), .D(n7057), 
        .Y(N1900) );
  sky130_fd_sc_hd__nor2_1 U8615 ( .A(n7627), .B(n7628), .Y(n7062) );
  sky130_fd_sc_hd__xnor2_1 U8616 ( .A(n7063), .B(n7062), .Y(n7064) );
  sky130_fd_sc_hd__a222oi_1 U8617 ( .A1(alu_out_q[23]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[23]), .C1(n7064), .C2(n9813), .Y(n7079) );
  sky130_fd_sc_hd__nand2_1 U8618 ( .A(n10057), .B(\cpuregs[24][23] ), .Y(n7065) );
  sky130_fd_sc_hd__o21ai_1 U8619 ( .A1(n10057), .A2(n4187), .B1(n7065), .Y(
        n3206) );
  sky130_fd_sc_hd__nand2_1 U8620 ( .A(n4177), .B(\cpuregs[30][23] ), .Y(n7066)
         );
  sky130_fd_sc_hd__o21ai_1 U8621 ( .A1(n4177), .A2(n4187), .B1(n7066), .Y(
        n3212) );
  sky130_fd_sc_hd__nand2_1 U8622 ( .A(n7452), .B(\cpuregs[9][23] ), .Y(n7067)
         );
  sky130_fd_sc_hd__o21ai_1 U8623 ( .A1(n7452), .A2(n4187), .B1(n7067), .Y(
        n3191) );
  sky130_fd_sc_hd__nand2_1 U8624 ( .A(n4173), .B(\cpuregs[23][23] ), .Y(n7068)
         );
  sky130_fd_sc_hd__o21ai_1 U8625 ( .A1(n4173), .A2(n4187), .B1(n7068), .Y(
        n3205) );
  sky130_fd_sc_hd__nand2_1 U8626 ( .A(n7069), .B(\cpuregs[15][23] ), .Y(n7070)
         );
  sky130_fd_sc_hd__o21ai_1 U8627 ( .A1(n7069), .A2(n4187), .B1(n7070), .Y(
        n3197) );
  sky130_fd_sc_hd__nand2_1 U8628 ( .A(n4219), .B(\cpuregs[28][23] ), .Y(n7071)
         );
  sky130_fd_sc_hd__o21ai_1 U8629 ( .A1(n4219), .A2(n4187), .B1(n7071), .Y(
        n3210) );
  sky130_fd_sc_hd__nand2_1 U8630 ( .A(n4199), .B(\cpuregs[7][23] ), .Y(n7072)
         );
  sky130_fd_sc_hd__o21ai_1 U8631 ( .A1(n4199), .A2(n4187), .B1(n7072), .Y(
        n3189) );
  sky130_fd_sc_hd__nand2_1 U8632 ( .A(n4226), .B(\cpuregs[12][23] ), .Y(n7073)
         );
  sky130_fd_sc_hd__o21ai_1 U8633 ( .A1(n4226), .A2(n4187), .B1(n7073), .Y(
        n3194) );
  sky130_fd_sc_hd__nand2_1 U8634 ( .A(n4184), .B(\cpuregs[10][23] ), .Y(n7074)
         );
  sky130_fd_sc_hd__o21ai_1 U8635 ( .A1(n4184), .A2(n4187), .B1(n7074), .Y(
        n3192) );
  sky130_fd_sc_hd__nand2_1 U8636 ( .A(n9820), .B(\cpuregs[18][23] ), .Y(n7075)
         );
  sky130_fd_sc_hd__o21ai_1 U8637 ( .A1(n9820), .A2(n4187), .B1(n7075), .Y(
        n3200) );
  sky130_fd_sc_hd__nand2_1 U8638 ( .A(n6897), .B(\cpuregs[14][23] ), .Y(n7076)
         );
  sky130_fd_sc_hd__o21ai_1 U8639 ( .A1(n6897), .A2(n4187), .B1(n7076), .Y(
        n3196) );
  sky130_fd_sc_hd__nand2_1 U8640 ( .A(n4174), .B(\cpuregs[21][23] ), .Y(n7077)
         );
  sky130_fd_sc_hd__o21ai_1 U8641 ( .A1(n4174), .A2(n4187), .B1(n7077), .Y(
        n3203) );
  sky130_fd_sc_hd__nand2_1 U8642 ( .A(n4192), .B(\cpuregs[25][23] ), .Y(n7078)
         );
  sky130_fd_sc_hd__o21ai_1 U8643 ( .A1(n4192), .A2(n4187), .B1(n7078), .Y(
        n3207) );
  sky130_fd_sc_hd__nand2_1 U8644 ( .A(n4178), .B(\cpuregs[2][23] ), .Y(n7080)
         );
  sky130_fd_sc_hd__o21ai_1 U8645 ( .A1(n4178), .A2(n4187), .B1(n7080), .Y(
        n3184) );
  sky130_fd_sc_hd__nand2_1 U8646 ( .A(n7247), .B(\cpuregs[31][23] ), .Y(n7081)
         );
  sky130_fd_sc_hd__o21ai_1 U8647 ( .A1(n7247), .A2(n4187), .B1(n7081), .Y(
        n3213) );
  sky130_fd_sc_hd__nand2_1 U8648 ( .A(n4180), .B(\cpuregs[5][23] ), .Y(n7082)
         );
  sky130_fd_sc_hd__o21ai_1 U8649 ( .A1(n4180), .A2(n4187), .B1(n7082), .Y(
        n3187) );
  sky130_fd_sc_hd__nand2_1 U8650 ( .A(n4183), .B(\cpuregs[8][23] ), .Y(n7083)
         );
  sky130_fd_sc_hd__o21ai_1 U8651 ( .A1(n4183), .A2(n4187), .B1(n7083), .Y(
        n3190) );
  sky130_fd_sc_hd__nand2_1 U8652 ( .A(n7084), .B(\cpuregs[22][23] ), .Y(n7085)
         );
  sky130_fd_sc_hd__o21ai_1 U8653 ( .A1(n7084), .A2(n4187), .B1(n7085), .Y(
        n3204) );
  sky130_fd_sc_hd__nand2_1 U8654 ( .A(n4175), .B(\cpuregs[27][23] ), .Y(n7086)
         );
  sky130_fd_sc_hd__o21ai_1 U8655 ( .A1(n4175), .A2(n4187), .B1(n7086), .Y(
        n3209) );
  sky130_fd_sc_hd__nand2_1 U8656 ( .A(n4195), .B(\cpuregs[17][23] ), .Y(n7087)
         );
  sky130_fd_sc_hd__o21ai_1 U8657 ( .A1(n4195), .A2(n4187), .B1(n7087), .Y(
        n3199) );
  sky130_fd_sc_hd__nand2_1 U8658 ( .A(n4179), .B(\cpuregs[4][23] ), .Y(n7088)
         );
  sky130_fd_sc_hd__o21ai_1 U8659 ( .A1(n4179), .A2(n4187), .B1(n7088), .Y(
        n3186) );
  sky130_fd_sc_hd__nand2_1 U8660 ( .A(n4201), .B(\cpuregs[3][23] ), .Y(n7089)
         );
  sky130_fd_sc_hd__o21ai_1 U8661 ( .A1(n4201), .A2(n4187), .B1(n7089), .Y(
        n3185) );
  sky130_fd_sc_hd__nand2_1 U8662 ( .A(n4186), .B(\cpuregs[13][23] ), .Y(n7090)
         );
  sky130_fd_sc_hd__o21ai_1 U8663 ( .A1(n4186), .A2(n4187), .B1(n7090), .Y(
        n3195) );
  sky130_fd_sc_hd__nand2_1 U8664 ( .A(n4197), .B(\cpuregs[16][23] ), .Y(n7091)
         );
  sky130_fd_sc_hd__o21ai_1 U8665 ( .A1(n4197), .A2(n4187), .B1(n7091), .Y(
        n3198) );
  sky130_fd_sc_hd__nand2_1 U8666 ( .A(n6396), .B(\cpuregs[1][23] ), .Y(n7092)
         );
  sky130_fd_sc_hd__o21ai_1 U8667 ( .A1(n6396), .A2(n4187), .B1(n7092), .Y(
        n3183) );
  sky130_fd_sc_hd__nand2_1 U8668 ( .A(n4194), .B(\cpuregs[19][23] ), .Y(n7093)
         );
  sky130_fd_sc_hd__o21ai_1 U8669 ( .A1(n4194), .A2(n4187), .B1(n7093), .Y(
        n3201) );
  sky130_fd_sc_hd__nand2_1 U8670 ( .A(n4176), .B(\cpuregs[29][23] ), .Y(n7094)
         );
  sky130_fd_sc_hd__o21ai_1 U8671 ( .A1(n4176), .A2(n4187), .B1(n7094), .Y(
        n3211) );
  sky130_fd_sc_hd__nand2_1 U8672 ( .A(n4185), .B(\cpuregs[11][23] ), .Y(n7095)
         );
  sky130_fd_sc_hd__o21ai_1 U8673 ( .A1(n4185), .A2(n4187), .B1(n7095), .Y(
        n3193) );
  sky130_fd_sc_hd__nand2_1 U8674 ( .A(n10058), .B(\cpuregs[20][23] ), .Y(n7096) );
  sky130_fd_sc_hd__o21ai_1 U8675 ( .A1(n10058), .A2(n4187), .B1(n7096), .Y(
        n3202) );
  sky130_fd_sc_hd__nand2_1 U8676 ( .A(n9621), .B(\cpuregs[26][23] ), .Y(n7097)
         );
  sky130_fd_sc_hd__o21ai_1 U8677 ( .A1(n9621), .A2(n4187), .B1(n7097), .Y(
        n3208) );
  sky130_fd_sc_hd__nand2_1 U8678 ( .A(n9209), .B(\cpuregs[6][23] ), .Y(n7098)
         );
  sky130_fd_sc_hd__o21ai_1 U8679 ( .A1(n9772), .A2(n4187), .B1(n7098), .Y(
        n3188) );
  sky130_fd_sc_hd__a22oi_1 U8680 ( .A1(decoded_imm[23]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[23]), .Y(n7099) );
  sky130_fd_sc_hd__nand2_1 U8681 ( .A(n8437), .B(n7099), .Y(n2849) );
  sky130_fd_sc_hd__a22oi_1 U8682 ( .A1(\cpuregs[29][23] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][23] ), .Y(n7103) );
  sky130_fd_sc_hd__a22oi_1 U8683 ( .A1(n8478), .A2(\cpuregs[13][23] ), .B1(
        \cpuregs[31][23] ), .B2(n8487), .Y(n7102) );
  sky130_fd_sc_hd__a22oi_1 U8684 ( .A1(n8498), .A2(\cpuregs[14][23] ), .B1(
        \cpuregs[12][23] ), .B2(n8491), .Y(n7101) );
  sky130_fd_sc_hd__a22oi_1 U8685 ( .A1(n8501), .A2(\cpuregs[15][23] ), .B1(
        \cpuregs[28][23] ), .B2(n8490), .Y(n7100) );
  sky130_fd_sc_hd__nand4_1 U8686 ( .A(n7103), .B(n7102), .C(n7101), .D(n7100), 
        .Y(n7119) );
  sky130_fd_sc_hd__a22oi_1 U8687 ( .A1(n8467), .A2(\cpuregs[26][23] ), .B1(
        n8481), .B2(\cpuregs[11][23] ), .Y(n7107) );
  sky130_fd_sc_hd__a22oi_1 U8688 ( .A1(n6059), .A2(\cpuregs[20][23] ), .B1(
        n8502), .B2(\cpuregs[6][23] ), .Y(n7106) );
  sky130_fd_sc_hd__a22oi_1 U8689 ( .A1(n6412), .A2(\cpuregs[19][23] ), .B1(
        n8488), .B2(\cpuregs[1][23] ), .Y(n7105) );
  sky130_fd_sc_hd__nand2_1 U8690 ( .A(n8500), .B(\cpuregs[30][23] ), .Y(n7104)
         );
  sky130_fd_sc_hd__nand4_1 U8691 ( .A(n7107), .B(n7106), .C(n7105), .D(n7104), 
        .Y(n7118) );
  sky130_fd_sc_hd__a22oi_1 U8692 ( .A1(n8497), .A2(\cpuregs[27][23] ), .B1(
        n8499), .B2(\cpuregs[3][23] ), .Y(n7111) );
  sky130_fd_sc_hd__a22oi_1 U8693 ( .A1(\cpuregs[4][23] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][23] ), .Y(n7110) );
  sky130_fd_sc_hd__a22oi_1 U8694 ( .A1(n8489), .A2(\cpuregs[17][23] ), .B1(
        n4233), .B2(\cpuregs[8][23] ), .Y(n7109) );
  sky130_fd_sc_hd__a22oi_1 U8695 ( .A1(n8482), .A2(\cpuregs[22][23] ), .B1(
        n8471), .B2(\cpuregs[5][23] ), .Y(n7108) );
  sky130_fd_sc_hd__nand4_1 U8696 ( .A(n7111), .B(n7110), .C(n7109), .D(n7108), 
        .Y(n7117) );
  sky130_fd_sc_hd__a22oi_1 U8697 ( .A1(n8466), .A2(\cpuregs[25][23] ), .B1(
        n8479), .B2(\cpuregs[2][23] ), .Y(n7115) );
  sky130_fd_sc_hd__a22oi_1 U8698 ( .A1(\cpuregs[21][23] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][23] ), .Y(n7114) );
  sky130_fd_sc_hd__a22oi_1 U8699 ( .A1(\cpuregs[7][23] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][23] ), .Y(n7113) );
  sky130_fd_sc_hd__a22oi_1 U8700 ( .A1(\cpuregs[23][23] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][23] ), .Y(n7112) );
  sky130_fd_sc_hd__nand4_1 U8701 ( .A(n7115), .B(n7114), .C(n7113), .D(n7112), 
        .Y(n7116) );
  sky130_fd_sc_hd__nor4_1 U8702 ( .A(n7119), .B(n7118), .C(n7117), .D(n7116), 
        .Y(n7121) );
  sky130_fd_sc_hd__a22oi_1 U8703 ( .A1(pcpi_rs2[23]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[23]), .Y(n7120) );
  sky130_fd_sc_hd__o21ai_1 U8704 ( .A1(n7121), .A2(n8514), .B1(n7120), .Y(
        n3935) );
  sky130_fd_sc_hd__nand2_1 U8705 ( .A(n7122), .B(n7509), .Y(n7123) );
  sky130_fd_sc_hd__xor2_1 U8706 ( .A(n7510), .B(n7123), .X(n7128) );
  sky130_fd_sc_hd__a21oi_1 U8707 ( .A1(n9873), .A2(n7126), .B1(n9872), .Y(
        n7124) );
  sky130_fd_sc_hd__o22ai_1 U8708 ( .A1(n9877), .A2(n7126), .B1(n7125), .B2(
        n7124), .Y(n7127) );
  sky130_fd_sc_hd__a21o_1 U8709 ( .A1(n7128), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n7127), .X(alu_out[23]) );
  sky130_fd_sc_hd__a22o_1 U8710 ( .A1(n9530), .A2(reg_pc[23]), .B1(n7129), 
        .B2(n10055), .X(n3996) );
  sky130_fd_sc_hd__a21oi_1 U8711 ( .A1(n7569), .A2(n7134), .B1(n7133), .Y(
        n7139) );
  sky130_fd_sc_hd__nand2_1 U8712 ( .A(n7137), .B(n7136), .Y(n7138) );
  sky130_fd_sc_hd__xor2_1 U8713 ( .A(n7139), .B(n7138), .X(n7140) );
  sky130_fd_sc_hd__nand2_1 U8714 ( .A(n7140), .B(n4639), .Y(n7145) );
  sky130_fd_sc_hd__a22oi_1 U8715 ( .A1(n9861), .A2(count_cycle[59]), .B1(n9860), .B2(count_cycle[27]), .Y(n7144) );
  sky130_fd_sc_hd__a22o_1 U8716 ( .A1(n9858), .A2(pcpi_rs1[27]), .B1(n7705), 
        .B2(mem_rdata_word[27]), .X(n7141) );
  sky130_fd_sc_hd__a211oi_1 U8717 ( .A1(n9857), .A2(count_instr[27]), .B1(
        n7707), .C1(n7141), .Y(n7143) );
  sky130_fd_sc_hd__nand2_1 U8718 ( .A(n9856), .B(count_instr[59]), .Y(n7142)
         );
  sky130_fd_sc_hd__nand4_1 U8719 ( .A(n7145), .B(n7144), .C(n7143), .D(n7142), 
        .Y(N1904) );
  sky130_fd_sc_hd__a22oi_1 U8720 ( .A1(decoded_imm[27]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[27]), .Y(n7146) );
  sky130_fd_sc_hd__nand2_1 U8721 ( .A(n8437), .B(n7146), .Y(n2845) );
  sky130_fd_sc_hd__a22oi_1 U8722 ( .A1(n8482), .A2(\cpuregs[22][27] ), .B1(
        n4233), .B2(\cpuregs[8][27] ), .Y(n7150) );
  sky130_fd_sc_hd__a22oi_1 U8723 ( .A1(n8489), .A2(\cpuregs[17][27] ), .B1(
        n8472), .B2(\cpuregs[18][27] ), .Y(n7149) );
  sky130_fd_sc_hd__a22oi_1 U8724 ( .A1(n6059), .A2(\cpuregs[20][27] ), .B1(
        n8499), .B2(\cpuregs[3][27] ), .Y(n7148) );
  sky130_fd_sc_hd__nand2_1 U8725 ( .A(n8464), .B(\cpuregs[23][27] ), .Y(n7147)
         );
  sky130_fd_sc_hd__nand4_1 U8726 ( .A(n7150), .B(n7149), .C(n7148), .D(n7147), 
        .Y(n7166) );
  sky130_fd_sc_hd__a22oi_1 U8727 ( .A1(n8487), .A2(\cpuregs[31][27] ), .B1(
        n6412), .B2(\cpuregs[19][27] ), .Y(n7154) );
  sky130_fd_sc_hd__a22oi_1 U8728 ( .A1(n8466), .A2(\cpuregs[25][27] ), .B1(
        n8479), .B2(\cpuregs[2][27] ), .Y(n7153) );
  sky130_fd_sc_hd__a22oi_1 U8729 ( .A1(n8492), .A2(\cpuregs[4][27] ), .B1(
        n8471), .B2(\cpuregs[5][27] ), .Y(n7152) );
  sky130_fd_sc_hd__a22oi_1 U8730 ( .A1(n8498), .A2(\cpuregs[14][27] ), .B1(
        n8501), .B2(\cpuregs[15][27] ), .Y(n7151) );
  sky130_fd_sc_hd__nand4_1 U8731 ( .A(n7154), .B(n7153), .C(n7152), .D(n7151), 
        .Y(n7165) );
  sky130_fd_sc_hd__a22oi_1 U8732 ( .A1(n8477), .A2(\cpuregs[7][27] ), .B1(
        n8480), .B2(\cpuregs[21][27] ), .Y(n7158) );
  sky130_fd_sc_hd__a22oi_1 U8733 ( .A1(n8470), .A2(\cpuregs[10][27] ), .B1(
        n8036), .B2(\cpuregs[9][27] ), .Y(n7157) );
  sky130_fd_sc_hd__a22oi_1 U8734 ( .A1(n8500), .A2(\cpuregs[30][27] ), .B1(
        n8491), .B2(\cpuregs[12][27] ), .Y(n7156) );
  sky130_fd_sc_hd__a22oi_1 U8735 ( .A1(n8481), .A2(\cpuregs[11][27] ), .B1(
        n8488), .B2(\cpuregs[1][27] ), .Y(n7155) );
  sky130_fd_sc_hd__nand4_1 U8736 ( .A(n7158), .B(n7157), .C(n7156), .D(n7155), 
        .Y(n7164) );
  sky130_fd_sc_hd__a22oi_1 U8737 ( .A1(n8465), .A2(\cpuregs[16][27] ), .B1(
        n8467), .B2(\cpuregs[26][27] ), .Y(n7162) );
  sky130_fd_sc_hd__a22oi_1 U8738 ( .A1(n8497), .A2(\cpuregs[27][27] ), .B1(
        n8503), .B2(\cpuregs[24][27] ), .Y(n7161) );
  sky130_fd_sc_hd__a22oi_1 U8739 ( .A1(n8502), .A2(\cpuregs[6][27] ), .B1(
        n6137), .B2(\cpuregs[29][27] ), .Y(n7160) );
  sky130_fd_sc_hd__a22oi_1 U8740 ( .A1(n8478), .A2(\cpuregs[13][27] ), .B1(
        n8490), .B2(\cpuregs[28][27] ), .Y(n7159) );
  sky130_fd_sc_hd__nand4_1 U8741 ( .A(n7162), .B(n7161), .C(n7160), .D(n7159), 
        .Y(n7163) );
  sky130_fd_sc_hd__nor4_1 U8742 ( .A(n7166), .B(n7165), .C(n7164), .D(n7163), 
        .Y(n7168) );
  sky130_fd_sc_hd__a22oi_1 U8743 ( .A1(pcpi_rs2[27]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[27]), .Y(n7167) );
  sky130_fd_sc_hd__o21ai_1 U8744 ( .A1(n8514), .A2(n7168), .B1(n7167), .Y(
        n3931) );
  sky130_fd_sc_hd__nand2_1 U8745 ( .A(n7170), .B(n7169), .Y(n7172) );
  sky130_fd_sc_hd__xnor2_1 U8746 ( .A(n7172), .B(n7171), .Y(n7173) );
  sky130_fd_sc_hd__nand2_1 U8747 ( .A(n7173), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n7178) );
  sky130_fd_sc_hd__nor2_1 U8748 ( .A(n8683), .B(n7174), .Y(n7175) );
  sky130_fd_sc_hd__a31oi_1 U8749 ( .A1(n9382), .A2(pcpi_rs1[27]), .A3(
        pcpi_rs2[27]), .B1(n7175), .Y(n7177) );
  sky130_fd_sc_hd__o21ai_1 U8750 ( .A1(pcpi_rs1[27]), .A2(pcpi_rs2[27]), .B1(
        n9872), .Y(n7176) );
  sky130_fd_sc_hd__nand3_1 U8751 ( .A(n7178), .B(n7177), .C(n7176), .Y(
        alu_out[27]) );
  sky130_fd_sc_hd__a22o_1 U8752 ( .A1(n10055), .A2(n7179), .B1(n9530), .B2(
        reg_pc[27]), .X(n3992) );
  sky130_fd_sc_hd__a21oi_1 U8753 ( .A1(n8959), .A2(n7184), .B1(n7183), .Y(
        n7189) );
  sky130_fd_sc_hd__nand2_1 U8754 ( .A(n7187), .B(n7186), .Y(n7188) );
  sky130_fd_sc_hd__xor2_1 U8755 ( .A(n7189), .B(n7188), .X(n7190) );
  sky130_fd_sc_hd__nand2_1 U8756 ( .A(n7190), .B(n9511), .Y(n7218) );
  sky130_fd_sc_hd__a22oi_1 U8757 ( .A1(n9280), .A2(reg_pc[27]), .B1(n9452), 
        .B2(pcpi_rs1[27]), .Y(n7217) );
  sky130_fd_sc_hd__o22ai_1 U8758 ( .A1(n8918), .A2(n4340), .B1(n7191), .B2(
        n4342), .Y(n7214) );
  sky130_fd_sc_hd__a22oi_1 U8759 ( .A1(n9490), .A2(\cpuregs[11][27] ), .B1(
        n9457), .B2(\cpuregs[19][27] ), .Y(n7195) );
  sky130_fd_sc_hd__a22oi_1 U8760 ( .A1(n8946), .A2(\cpuregs[24][27] ), .B1(
        n9468), .B2(\cpuregs[16][27] ), .Y(n7194) );
  sky130_fd_sc_hd__a22oi_1 U8761 ( .A1(n9483), .A2(\cpuregs[7][27] ), .B1(
        n9484), .B2(\cpuregs[12][27] ), .Y(n7193) );
  sky130_fd_sc_hd__nand2_1 U8762 ( .A(n9478), .B(\cpuregs[1][27] ), .Y(n7192)
         );
  sky130_fd_sc_hd__nand4_1 U8763 ( .A(n7195), .B(n7194), .C(n7193), .D(n7192), 
        .Y(n7211) );
  sky130_fd_sc_hd__a22oi_1 U8764 ( .A1(n9458), .A2(\cpuregs[30][27] ), .B1(
        n9470), .B2(\cpuregs[13][27] ), .Y(n7199) );
  sky130_fd_sc_hd__a22oi_1 U8765 ( .A1(n9471), .A2(\cpuregs[25][27] ), .B1(
        n9491), .B2(\cpuregs[10][27] ), .Y(n7198) );
  sky130_fd_sc_hd__a22oi_1 U8766 ( .A1(n9461), .A2(\cpuregs[5][27] ), .B1(
        n9481), .B2(\cpuregs[14][27] ), .Y(n7197) );
  sky130_fd_sc_hd__a22oi_1 U8767 ( .A1(n9459), .A2(\cpuregs[18][27] ), .B1(
        n9495), .B2(\cpuregs[22][27] ), .Y(n7196) );
  sky130_fd_sc_hd__nand4_1 U8768 ( .A(n7199), .B(n7198), .C(n7197), .D(n7196), 
        .Y(n7210) );
  sky130_fd_sc_hd__a22oi_1 U8769 ( .A1(n9467), .A2(\cpuregs[26][27] ), .B1(
        n9493), .B2(\cpuregs[6][27] ), .Y(n7203) );
  sky130_fd_sc_hd__a22oi_1 U8770 ( .A1(n9316), .A2(\cpuregs[4][27] ), .B1(
        n9482), .B2(\cpuregs[31][27] ), .Y(n7202) );
  sky130_fd_sc_hd__a22oi_1 U8771 ( .A1(n9494), .A2(\cpuregs[8][27] ), .B1(
        n9496), .B2(\cpuregs[3][27] ), .Y(n7201) );
  sky130_fd_sc_hd__a22oi_1 U8772 ( .A1(n9492), .A2(\cpuregs[28][27] ), .B1(
        n9485), .B2(\cpuregs[21][27] ), .Y(n7200) );
  sky130_fd_sc_hd__nand4_1 U8773 ( .A(n7203), .B(n7202), .C(n7201), .D(n7200), 
        .Y(n7209) );
  sky130_fd_sc_hd__a22oi_1 U8774 ( .A1(n9321), .A2(\cpuregs[27][27] ), .B1(
        n9479), .B2(\cpuregs[29][27] ), .Y(n7207) );
  sky130_fd_sc_hd__a22oi_1 U8775 ( .A1(n9469), .A2(\cpuregs[9][27] ), .B1(
        n9497), .B2(\cpuregs[15][27] ), .Y(n7206) );
  sky130_fd_sc_hd__a22oi_1 U8776 ( .A1(n9480), .A2(\cpuregs[20][27] ), .B1(
        n9473), .B2(\cpuregs[23][27] ), .Y(n7205) );
  sky130_fd_sc_hd__a22oi_1 U8777 ( .A1(n9462), .A2(\cpuregs[2][27] ), .B1(
        n9456), .B2(\cpuregs[17][27] ), .Y(n7204) );
  sky130_fd_sc_hd__nand4_1 U8778 ( .A(n7207), .B(n7206), .C(n7205), .D(n7204), 
        .Y(n7208) );
  sky130_fd_sc_hd__nor4_1 U8779 ( .A(n7211), .B(n7210), .C(n7209), .D(n7208), 
        .Y(n7212) );
  sky130_fd_sc_hd__o22ai_1 U8780 ( .A1(n7212), .A2(n9506), .B1(n7548), .B2(
        n4371), .Y(n7213) );
  sky130_fd_sc_hd__nor2_1 U8781 ( .A(n7214), .B(n7213), .Y(n7216) );
  sky130_fd_sc_hd__nand2_1 U8782 ( .A(n9345), .B(pcpi_rs1[31]), .Y(n7215) );
  sky130_fd_sc_hd__nand4_1 U8783 ( .A(n7218), .B(n7217), .C(n7216), .D(n7215), 
        .Y(n2768) );
  sky130_fd_sc_hd__nand2_1 U8784 ( .A(n7220), .B(n7219), .Y(n7222) );
  sky130_fd_sc_hd__xnor2_1 U8785 ( .A(n7222), .B(n7221), .Y(n7223) );
  sky130_fd_sc_hd__nand2_1 U8786 ( .A(n7223), .B(n4639), .Y(n7228) );
  sky130_fd_sc_hd__a22oi_1 U8787 ( .A1(n9861), .A2(count_cycle[48]), .B1(n9860), .B2(count_cycle[16]), .Y(n7227) );
  sky130_fd_sc_hd__a22o_1 U8788 ( .A1(pcpi_rs1[16]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[16]), .X(n7224) );
  sky130_fd_sc_hd__a211oi_1 U8789 ( .A1(n9857), .A2(count_instr[16]), .B1(
        n7707), .C1(n7224), .Y(n7226) );
  sky130_fd_sc_hd__nand2_1 U8790 ( .A(n9856), .B(count_instr[48]), .Y(n7225)
         );
  sky130_fd_sc_hd__nand4_1 U8791 ( .A(n7228), .B(n7227), .C(n7226), .D(n7225), 
        .Y(N1893) );
  sky130_fd_sc_hd__xor2_1 U8792 ( .A(n7230), .B(n7229), .X(n7231) );
  sky130_fd_sc_hd__a222oi_1 U8793 ( .A1(reg_out[16]), .A2(n9816), .B1(
        alu_out_q[16]), .B2(n9815), .C1(n7231), .C2(n9813), .Y(n7245) );
  sky130_fd_sc_hd__nand2_1 U8794 ( .A(n10057), .B(\cpuregs[24][16] ), .Y(n7232) );
  sky130_fd_sc_hd__o21ai_1 U8795 ( .A1(n10057), .A2(n4193), .B1(n7232), .Y(
        n3423) );
  sky130_fd_sc_hd__nand2_1 U8796 ( .A(n4177), .B(\cpuregs[30][16] ), .Y(n7233)
         );
  sky130_fd_sc_hd__o21ai_1 U8797 ( .A1(n4177), .A2(n4193), .B1(n7233), .Y(
        n3429) );
  sky130_fd_sc_hd__nand2_1 U8798 ( .A(n7452), .B(\cpuregs[9][16] ), .Y(n7234)
         );
  sky130_fd_sc_hd__o21ai_1 U8799 ( .A1(n7452), .A2(n4193), .B1(n7234), .Y(
        n3408) );
  sky130_fd_sc_hd__nand2_1 U8800 ( .A(n4173), .B(\cpuregs[23][16] ), .Y(n7235)
         );
  sky130_fd_sc_hd__o21ai_1 U8801 ( .A1(n4173), .A2(n4193), .B1(n7235), .Y(
        n3422) );
  sky130_fd_sc_hd__nand2_1 U8802 ( .A(n7069), .B(\cpuregs[15][16] ), .Y(n7236)
         );
  sky130_fd_sc_hd__o21ai_1 U8803 ( .A1(n7069), .A2(n4193), .B1(n7236), .Y(
        n3414) );
  sky130_fd_sc_hd__nand2_1 U8804 ( .A(n4219), .B(\cpuregs[28][16] ), .Y(n7237)
         );
  sky130_fd_sc_hd__o21ai_1 U8805 ( .A1(n4219), .A2(n4193), .B1(n7237), .Y(
        n3427) );
  sky130_fd_sc_hd__nand2_1 U8806 ( .A(n4199), .B(\cpuregs[7][16] ), .Y(n7238)
         );
  sky130_fd_sc_hd__o21ai_1 U8807 ( .A1(n4199), .A2(n4193), .B1(n7238), .Y(
        n3406) );
  sky130_fd_sc_hd__nand2_1 U8808 ( .A(n4226), .B(\cpuregs[12][16] ), .Y(n7239)
         );
  sky130_fd_sc_hd__o21ai_1 U8809 ( .A1(n4226), .A2(n4193), .B1(n7239), .Y(
        n3411) );
  sky130_fd_sc_hd__nand2_1 U8810 ( .A(n4184), .B(\cpuregs[10][16] ), .Y(n7240)
         );
  sky130_fd_sc_hd__o21ai_1 U8811 ( .A1(n4184), .A2(n4193), .B1(n7240), .Y(
        n3409) );
  sky130_fd_sc_hd__nand2_1 U8812 ( .A(n9820), .B(\cpuregs[18][16] ), .Y(n7241)
         );
  sky130_fd_sc_hd__o21ai_1 U8813 ( .A1(n9820), .A2(n4193), .B1(n7241), .Y(
        n3417) );
  sky130_fd_sc_hd__nand2_1 U8814 ( .A(n6897), .B(\cpuregs[14][16] ), .Y(n7242)
         );
  sky130_fd_sc_hd__o21ai_1 U8815 ( .A1(n6897), .A2(n4193), .B1(n7242), .Y(
        n3413) );
  sky130_fd_sc_hd__nand2_1 U8816 ( .A(n4174), .B(\cpuregs[21][16] ), .Y(n7243)
         );
  sky130_fd_sc_hd__o21ai_1 U8817 ( .A1(n4174), .A2(n4193), .B1(n7243), .Y(
        n3420) );
  sky130_fd_sc_hd__nand2_1 U8818 ( .A(n4192), .B(\cpuregs[25][16] ), .Y(n7244)
         );
  sky130_fd_sc_hd__o21ai_1 U8819 ( .A1(n4192), .A2(n4193), .B1(n7244), .Y(
        n3424) );
  sky130_fd_sc_hd__nand2_1 U8820 ( .A(n4178), .B(\cpuregs[2][16] ), .Y(n7246)
         );
  sky130_fd_sc_hd__o21ai_1 U8821 ( .A1(n4178), .A2(n4193), .B1(n7246), .Y(
        n3401) );
  sky130_fd_sc_hd__nand2_1 U8822 ( .A(n7247), .B(\cpuregs[31][16] ), .Y(n7248)
         );
  sky130_fd_sc_hd__o21ai_1 U8823 ( .A1(n7247), .A2(n4193), .B1(n7248), .Y(
        n3430) );
  sky130_fd_sc_hd__nand2_1 U8824 ( .A(n4180), .B(\cpuregs[5][16] ), .Y(n7249)
         );
  sky130_fd_sc_hd__o21ai_1 U8825 ( .A1(n4180), .A2(n4193), .B1(n7249), .Y(
        n3404) );
  sky130_fd_sc_hd__nand2_1 U8826 ( .A(n4183), .B(\cpuregs[8][16] ), .Y(n7250)
         );
  sky130_fd_sc_hd__o21ai_1 U8827 ( .A1(n4183), .A2(n4193), .B1(n7250), .Y(
        n3407) );
  sky130_fd_sc_hd__nand2_1 U8828 ( .A(n7084), .B(\cpuregs[22][16] ), .Y(n7251)
         );
  sky130_fd_sc_hd__o21ai_1 U8829 ( .A1(n7084), .A2(n4193), .B1(n7251), .Y(
        n3421) );
  sky130_fd_sc_hd__nand2_1 U8830 ( .A(n4175), .B(\cpuregs[27][16] ), .Y(n7252)
         );
  sky130_fd_sc_hd__o21ai_1 U8831 ( .A1(n4175), .A2(n4193), .B1(n7252), .Y(
        n3426) );
  sky130_fd_sc_hd__nand2_1 U8832 ( .A(n4195), .B(\cpuregs[17][16] ), .Y(n7253)
         );
  sky130_fd_sc_hd__o21ai_1 U8833 ( .A1(n4195), .A2(n4193), .B1(n7253), .Y(
        n3416) );
  sky130_fd_sc_hd__nand2_1 U8834 ( .A(n4179), .B(\cpuregs[4][16] ), .Y(n7254)
         );
  sky130_fd_sc_hd__o21ai_1 U8835 ( .A1(n4179), .A2(n4193), .B1(n7254), .Y(
        n3403) );
  sky130_fd_sc_hd__nand2_1 U8836 ( .A(n4201), .B(\cpuregs[3][16] ), .Y(n7255)
         );
  sky130_fd_sc_hd__o21ai_1 U8837 ( .A1(n4201), .A2(n4193), .B1(n7255), .Y(
        n3402) );
  sky130_fd_sc_hd__nand2_1 U8838 ( .A(n4186), .B(\cpuregs[13][16] ), .Y(n7256)
         );
  sky130_fd_sc_hd__o21ai_1 U8839 ( .A1(n4186), .A2(n4193), .B1(n7256), .Y(
        n3412) );
  sky130_fd_sc_hd__nand2_1 U8840 ( .A(n4197), .B(\cpuregs[16][16] ), .Y(n7257)
         );
  sky130_fd_sc_hd__o21ai_1 U8841 ( .A1(n4197), .A2(n4193), .B1(n7257), .Y(
        n3415) );
  sky130_fd_sc_hd__nand2_1 U8842 ( .A(n6396), .B(\cpuregs[1][16] ), .Y(n7258)
         );
  sky130_fd_sc_hd__o21ai_1 U8843 ( .A1(n6396), .A2(n4193), .B1(n7258), .Y(
        n3400) );
  sky130_fd_sc_hd__nand2_1 U8844 ( .A(n4194), .B(\cpuregs[19][16] ), .Y(n7259)
         );
  sky130_fd_sc_hd__o21ai_1 U8845 ( .A1(n4194), .A2(n4193), .B1(n7259), .Y(
        n3418) );
  sky130_fd_sc_hd__nand2_1 U8846 ( .A(n4176), .B(\cpuregs[29][16] ), .Y(n7260)
         );
  sky130_fd_sc_hd__o21ai_1 U8847 ( .A1(n4176), .A2(n4193), .B1(n7260), .Y(
        n3428) );
  sky130_fd_sc_hd__nand2_1 U8848 ( .A(n4185), .B(\cpuregs[11][16] ), .Y(n7261)
         );
  sky130_fd_sc_hd__o21ai_1 U8849 ( .A1(n4185), .A2(n4193), .B1(n7261), .Y(
        n3410) );
  sky130_fd_sc_hd__nand2_1 U8850 ( .A(n10058), .B(\cpuregs[20][16] ), .Y(n7262) );
  sky130_fd_sc_hd__o21ai_1 U8851 ( .A1(n10058), .A2(n4193), .B1(n7262), .Y(
        n3419) );
  sky130_fd_sc_hd__nand2_1 U8852 ( .A(n9621), .B(\cpuregs[26][16] ), .Y(n7263)
         );
  sky130_fd_sc_hd__o21ai_1 U8853 ( .A1(n9621), .A2(n4193), .B1(n7263), .Y(
        n3425) );
  sky130_fd_sc_hd__nand2_1 U8854 ( .A(n9772), .B(\cpuregs[6][16] ), .Y(n7264)
         );
  sky130_fd_sc_hd__o21ai_1 U8855 ( .A1(n9772), .A2(n4193), .B1(n7264), .Y(
        n3405) );
  sky130_fd_sc_hd__a22oi_1 U8856 ( .A1(decoded_imm[16]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[16]), .Y(n7266) );
  sky130_fd_sc_hd__nand2_1 U8857 ( .A(n5989), .B(mem_rdata_q[16]), .Y(n7265)
         );
  sky130_fd_sc_hd__nand3_1 U8858 ( .A(n7930), .B(n7266), .C(n7265), .Y(n2856)
         );
  sky130_fd_sc_hd__a22oi_1 U8859 ( .A1(\cpuregs[29][16] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][16] ), .Y(n7270) );
  sky130_fd_sc_hd__a22oi_1 U8860 ( .A1(n8478), .A2(\cpuregs[13][16] ), .B1(
        \cpuregs[31][16] ), .B2(n8487), .Y(n7269) );
  sky130_fd_sc_hd__a22oi_1 U8861 ( .A1(n8498), .A2(\cpuregs[14][16] ), .B1(
        \cpuregs[12][16] ), .B2(n8491), .Y(n7268) );
  sky130_fd_sc_hd__a22oi_1 U8862 ( .A1(n8501), .A2(\cpuregs[15][16] ), .B1(
        \cpuregs[28][16] ), .B2(n8490), .Y(n7267) );
  sky130_fd_sc_hd__nand4_1 U8863 ( .A(n7270), .B(n7269), .C(n7268), .D(n7267), 
        .Y(n7286) );
  sky130_fd_sc_hd__a22oi_1 U8864 ( .A1(n8467), .A2(\cpuregs[26][16] ), .B1(
        n8481), .B2(\cpuregs[11][16] ), .Y(n7274) );
  sky130_fd_sc_hd__a22oi_1 U8865 ( .A1(n6059), .A2(\cpuregs[20][16] ), .B1(
        n8502), .B2(\cpuregs[6][16] ), .Y(n7273) );
  sky130_fd_sc_hd__a22oi_1 U8866 ( .A1(n6412), .A2(\cpuregs[19][16] ), .B1(
        n8488), .B2(\cpuregs[1][16] ), .Y(n7272) );
  sky130_fd_sc_hd__nand2_1 U8867 ( .A(n8500), .B(\cpuregs[30][16] ), .Y(n7271)
         );
  sky130_fd_sc_hd__nand4_1 U8868 ( .A(n7274), .B(n7273), .C(n7272), .D(n7271), 
        .Y(n7285) );
  sky130_fd_sc_hd__a22oi_1 U8869 ( .A1(n8497), .A2(\cpuregs[27][16] ), .B1(
        n8499), .B2(\cpuregs[3][16] ), .Y(n7278) );
  sky130_fd_sc_hd__a22oi_1 U8870 ( .A1(\cpuregs[4][16] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][16] ), .Y(n7277) );
  sky130_fd_sc_hd__a22oi_1 U8871 ( .A1(n8489), .A2(\cpuregs[17][16] ), .B1(
        n4233), .B2(\cpuregs[8][16] ), .Y(n7276) );
  sky130_fd_sc_hd__a22oi_1 U8872 ( .A1(n8482), .A2(\cpuregs[22][16] ), .B1(
        n8471), .B2(\cpuregs[5][16] ), .Y(n7275) );
  sky130_fd_sc_hd__nand4_1 U8873 ( .A(n7278), .B(n7277), .C(n7276), .D(n7275), 
        .Y(n7284) );
  sky130_fd_sc_hd__a22oi_1 U8874 ( .A1(n8466), .A2(\cpuregs[25][16] ), .B1(
        n8479), .B2(\cpuregs[2][16] ), .Y(n7282) );
  sky130_fd_sc_hd__a22oi_1 U8875 ( .A1(\cpuregs[21][16] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][16] ), .Y(n7281) );
  sky130_fd_sc_hd__a22oi_1 U8876 ( .A1(\cpuregs[7][16] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][16] ), .Y(n7280) );
  sky130_fd_sc_hd__a22oi_1 U8877 ( .A1(\cpuregs[23][16] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][16] ), .Y(n7279) );
  sky130_fd_sc_hd__nand4_1 U8878 ( .A(n7282), .B(n7281), .C(n7280), .D(n7279), 
        .Y(n7283) );
  sky130_fd_sc_hd__nor4_1 U8879 ( .A(n7286), .B(n7285), .C(n7284), .D(n7283), 
        .Y(n7288) );
  sky130_fd_sc_hd__a22oi_1 U8880 ( .A1(pcpi_rs2[16]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[16]), .Y(n7287) );
  sky130_fd_sc_hd__o21ai_1 U8881 ( .A1(n7288), .A2(n8514), .B1(n7287), .Y(
        n3942) );
  sky130_fd_sc_hd__a21oi_1 U8882 ( .A1(n9873), .A2(n7290), .B1(n9872), .Y(
        n7289) );
  sky130_fd_sc_hd__o21ai_1 U8883 ( .A1(n7290), .A2(n9877), .B1(n7289), .Y(
        n7301) );
  sky130_fd_sc_hd__a21oi_1 U8884 ( .A1(n7294), .A2(n7293), .B1(n7292), .Y(
        n7299) );
  sky130_fd_sc_hd__nand2_1 U8885 ( .A(n7297), .B(n7296), .Y(n7298) );
  sky130_fd_sc_hd__xor2_1 U8886 ( .A(n7299), .B(n7298), .X(n7300) );
  sky130_fd_sc_hd__a22o_1 U8887 ( .A1(n7302), .A2(n7301), .B1(n7300), .B2(
        is_lui_auipc_jal_jalr_addi_add_sub), .X(alu_out[16]) );
  sky130_fd_sc_hd__nand2_1 U8888 ( .A(n7305), .B(n7304), .Y(n7316) );
  sky130_fd_sc_hd__nor2_1 U8889 ( .A(n7310), .B(n7306), .Y(n7312) );
  sky130_fd_sc_hd__nand2_1 U8890 ( .A(n7312), .B(n7799), .Y(n7314) );
  sky130_fd_sc_hd__o21ai_1 U8891 ( .A1(n7310), .A2(n7309), .B1(n7308), .Y(
        n7311) );
  sky130_fd_sc_hd__a21oi_1 U8892 ( .A1(n7803), .A2(n7312), .B1(n7311), .Y(
        n7313) );
  sky130_fd_sc_hd__o21ai_1 U8893 ( .A1(n7314), .A2(n8073), .B1(n7313), .Y(
        n7315) );
  sky130_fd_sc_hd__xnor2_1 U8894 ( .A(n7316), .B(n7315), .Y(n7317) );
  sky130_fd_sc_hd__a222oi_1 U8895 ( .A1(n7319), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[16]), .C1(n5794), .C2(n7317), .Y(n7318) );
  sky130_fd_sc_hd__a22o_1 U8896 ( .A1(n10055), .A2(n7319), .B1(n9530), .B2(
        reg_pc[16]), .X(n4003) );
  sky130_fd_sc_hd__nand2_1 U8897 ( .A(n7321), .B(n7320), .Y(n7323) );
  sky130_fd_sc_hd__xnor2_1 U8898 ( .A(n7323), .B(n7322), .Y(n7324) );
  sky130_fd_sc_hd__nand2_1 U8899 ( .A(n7324), .B(n4639), .Y(n7329) );
  sky130_fd_sc_hd__a22oi_1 U8900 ( .A1(n9861), .A2(count_cycle[52]), .B1(n9860), .B2(count_cycle[20]), .Y(n7328) );
  sky130_fd_sc_hd__a22o_1 U8901 ( .A1(n9858), .A2(pcpi_rs1[20]), .B1(n7705), 
        .B2(mem_rdata_word[20]), .X(n7325) );
  sky130_fd_sc_hd__a211oi_1 U8902 ( .A1(n9857), .A2(count_instr[20]), .B1(
        n7707), .C1(n7325), .Y(n7327) );
  sky130_fd_sc_hd__nand2_1 U8903 ( .A(n9856), .B(count_instr[52]), .Y(n7326)
         );
  sky130_fd_sc_hd__nand4_1 U8904 ( .A(n7329), .B(n7328), .C(n7327), .D(n7326), 
        .Y(N1897) );
  sky130_fd_sc_hd__xnor2_1 U8905 ( .A(n7424), .B(n7330), .Y(n7331) );
  sky130_fd_sc_hd__a222oi_1 U8906 ( .A1(alu_out_q[20]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[20]), .C1(n7331), .C2(n9813), .Y(n7345) );
  sky130_fd_sc_hd__nand2_1 U8907 ( .A(n10057), .B(\cpuregs[24][20] ), .Y(n7332) );
  sky130_fd_sc_hd__o21ai_1 U8908 ( .A1(n10057), .A2(n4205), .B1(n7332), .Y(
        n3299) );
  sky130_fd_sc_hd__nand2_1 U8909 ( .A(n4177), .B(\cpuregs[30][20] ), .Y(n7333)
         );
  sky130_fd_sc_hd__o21ai_1 U8910 ( .A1(n4177), .A2(n4205), .B1(n7333), .Y(
        n3305) );
  sky130_fd_sc_hd__nand2_1 U8911 ( .A(n7452), .B(\cpuregs[9][20] ), .Y(n7334)
         );
  sky130_fd_sc_hd__o21ai_1 U8912 ( .A1(n7452), .A2(n4205), .B1(n7334), .Y(
        n3284) );
  sky130_fd_sc_hd__nand2_1 U8913 ( .A(n4173), .B(\cpuregs[23][20] ), .Y(n7335)
         );
  sky130_fd_sc_hd__o21ai_1 U8914 ( .A1(n4173), .A2(n4205), .B1(n7335), .Y(
        n3298) );
  sky130_fd_sc_hd__nand2_1 U8915 ( .A(n7069), .B(\cpuregs[15][20] ), .Y(n7336)
         );
  sky130_fd_sc_hd__o21ai_1 U8916 ( .A1(n7069), .A2(n4205), .B1(n7336), .Y(
        n3290) );
  sky130_fd_sc_hd__nand2_1 U8917 ( .A(n4219), .B(\cpuregs[28][20] ), .Y(n7337)
         );
  sky130_fd_sc_hd__o21ai_1 U8918 ( .A1(n4219), .A2(n4205), .B1(n7337), .Y(
        n3303) );
  sky130_fd_sc_hd__nand2_1 U8919 ( .A(n4199), .B(\cpuregs[7][20] ), .Y(n7338)
         );
  sky130_fd_sc_hd__o21ai_1 U8920 ( .A1(n4199), .A2(n4205), .B1(n7338), .Y(
        n3282) );
  sky130_fd_sc_hd__nand2_1 U8921 ( .A(n4226), .B(\cpuregs[12][20] ), .Y(n7339)
         );
  sky130_fd_sc_hd__o21ai_1 U8922 ( .A1(n4226), .A2(n4205), .B1(n7339), .Y(
        n3287) );
  sky130_fd_sc_hd__nand2_1 U8923 ( .A(n4184), .B(\cpuregs[10][20] ), .Y(n7340)
         );
  sky130_fd_sc_hd__o21ai_1 U8924 ( .A1(n4184), .A2(n4205), .B1(n7340), .Y(
        n3285) );
  sky130_fd_sc_hd__nand2_1 U8925 ( .A(n9820), .B(\cpuregs[18][20] ), .Y(n7341)
         );
  sky130_fd_sc_hd__o21ai_1 U8926 ( .A1(n9820), .A2(n4205), .B1(n7341), .Y(
        n3293) );
  sky130_fd_sc_hd__nand2_1 U8927 ( .A(n6897), .B(\cpuregs[14][20] ), .Y(n7342)
         );
  sky130_fd_sc_hd__o21ai_1 U8928 ( .A1(n6897), .A2(n4205), .B1(n7342), .Y(
        n3289) );
  sky130_fd_sc_hd__nand2_1 U8929 ( .A(n4174), .B(\cpuregs[21][20] ), .Y(n7343)
         );
  sky130_fd_sc_hd__o21ai_1 U8930 ( .A1(n4174), .A2(n4205), .B1(n7343), .Y(
        n3296) );
  sky130_fd_sc_hd__nand2_1 U8931 ( .A(n4192), .B(\cpuregs[25][20] ), .Y(n7344)
         );
  sky130_fd_sc_hd__o21ai_1 U8932 ( .A1(n4192), .A2(n4205), .B1(n7344), .Y(
        n3300) );
  sky130_fd_sc_hd__nand2_1 U8933 ( .A(n4178), .B(\cpuregs[2][20] ), .Y(n7346)
         );
  sky130_fd_sc_hd__o21ai_1 U8934 ( .A1(n4178), .A2(n4205), .B1(n7346), .Y(
        n3277) );
  sky130_fd_sc_hd__nand2_1 U8935 ( .A(n7247), .B(\cpuregs[31][20] ), .Y(n7347)
         );
  sky130_fd_sc_hd__o21ai_1 U8936 ( .A1(n7247), .A2(n4205), .B1(n7347), .Y(
        n3306) );
  sky130_fd_sc_hd__nand2_1 U8937 ( .A(n4180), .B(\cpuregs[5][20] ), .Y(n7348)
         );
  sky130_fd_sc_hd__o21ai_1 U8938 ( .A1(n4180), .A2(n4205), .B1(n7348), .Y(
        n3280) );
  sky130_fd_sc_hd__nand2_1 U8939 ( .A(n4183), .B(\cpuregs[8][20] ), .Y(n7349)
         );
  sky130_fd_sc_hd__o21ai_1 U8940 ( .A1(n4183), .A2(n4205), .B1(n7349), .Y(
        n3283) );
  sky130_fd_sc_hd__nand2_1 U8941 ( .A(n7084), .B(\cpuregs[22][20] ), .Y(n7350)
         );
  sky130_fd_sc_hd__o21ai_1 U8942 ( .A1(n7084), .A2(n4205), .B1(n7350), .Y(
        n3297) );
  sky130_fd_sc_hd__nand2_1 U8943 ( .A(n4175), .B(\cpuregs[27][20] ), .Y(n7351)
         );
  sky130_fd_sc_hd__o21ai_1 U8944 ( .A1(n4175), .A2(n4205), .B1(n7351), .Y(
        n3302) );
  sky130_fd_sc_hd__nand2_1 U8945 ( .A(n4195), .B(\cpuregs[17][20] ), .Y(n7352)
         );
  sky130_fd_sc_hd__o21ai_1 U8946 ( .A1(n4195), .A2(n4205), .B1(n7352), .Y(
        n3292) );
  sky130_fd_sc_hd__nand2_1 U8947 ( .A(n4179), .B(\cpuregs[4][20] ), .Y(n7353)
         );
  sky130_fd_sc_hd__o21ai_1 U8948 ( .A1(n4179), .A2(n4205), .B1(n7353), .Y(
        n3279) );
  sky130_fd_sc_hd__nand2_1 U8949 ( .A(n4201), .B(\cpuregs[3][20] ), .Y(n7354)
         );
  sky130_fd_sc_hd__o21ai_1 U8950 ( .A1(n4201), .A2(n4205), .B1(n7354), .Y(
        n3278) );
  sky130_fd_sc_hd__nand2_1 U8951 ( .A(n4186), .B(\cpuregs[13][20] ), .Y(n7355)
         );
  sky130_fd_sc_hd__o21ai_1 U8952 ( .A1(n4186), .A2(n4205), .B1(n7355), .Y(
        n3288) );
  sky130_fd_sc_hd__nand2_1 U8953 ( .A(n4197), .B(\cpuregs[16][20] ), .Y(n7356)
         );
  sky130_fd_sc_hd__o21ai_1 U8954 ( .A1(n4197), .A2(n4205), .B1(n7356), .Y(
        n3291) );
  sky130_fd_sc_hd__nand2_1 U8955 ( .A(n6396), .B(\cpuregs[1][20] ), .Y(n7357)
         );
  sky130_fd_sc_hd__o21ai_1 U8956 ( .A1(n6396), .A2(n4205), .B1(n7357), .Y(
        n3276) );
  sky130_fd_sc_hd__nand2_1 U8957 ( .A(n4194), .B(\cpuregs[19][20] ), .Y(n7358)
         );
  sky130_fd_sc_hd__o21ai_1 U8958 ( .A1(n4194), .A2(n4205), .B1(n7358), .Y(
        n3294) );
  sky130_fd_sc_hd__nand2_1 U8959 ( .A(n4176), .B(\cpuregs[29][20] ), .Y(n7359)
         );
  sky130_fd_sc_hd__o21ai_1 U8960 ( .A1(n4176), .A2(n4205), .B1(n7359), .Y(
        n3304) );
  sky130_fd_sc_hd__nand2_1 U8961 ( .A(n4185), .B(\cpuregs[11][20] ), .Y(n7360)
         );
  sky130_fd_sc_hd__o21ai_1 U8962 ( .A1(n4185), .A2(n4205), .B1(n7360), .Y(
        n3286) );
  sky130_fd_sc_hd__nand2_1 U8963 ( .A(n10058), .B(\cpuregs[20][20] ), .Y(n7361) );
  sky130_fd_sc_hd__o21ai_1 U8964 ( .A1(n10058), .A2(n4205), .B1(n7361), .Y(
        n3295) );
  sky130_fd_sc_hd__nand2_1 U8965 ( .A(n9621), .B(\cpuregs[26][20] ), .Y(n7362)
         );
  sky130_fd_sc_hd__o21ai_1 U8966 ( .A1(n9621), .A2(n4205), .B1(n7362), .Y(
        n3301) );
  sky130_fd_sc_hd__nand2_1 U8967 ( .A(n9772), .B(\cpuregs[6][20] ), .Y(n7363)
         );
  sky130_fd_sc_hd__o21ai_1 U8968 ( .A1(n9772), .A2(n4205), .B1(n7363), .Y(
        n3281) );
  sky130_fd_sc_hd__a22oi_1 U8969 ( .A1(decoded_imm[20]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[20]), .Y(n7364) );
  sky130_fd_sc_hd__nand2_1 U8970 ( .A(n8437), .B(n7364), .Y(n2852) );
  sky130_fd_sc_hd__a22oi_1 U8971 ( .A1(n6137), .A2(\cpuregs[29][20] ), .B1(
        n8503), .B2(\cpuregs[24][20] ), .Y(n7368) );
  sky130_fd_sc_hd__a22oi_1 U8972 ( .A1(n8478), .A2(\cpuregs[13][20] ), .B1(
        n8487), .B2(\cpuregs[31][20] ), .Y(n7367) );
  sky130_fd_sc_hd__a22oi_1 U8973 ( .A1(n8498), .A2(\cpuregs[14][20] ), .B1(
        n8491), .B2(\cpuregs[12][20] ), .Y(n7366) );
  sky130_fd_sc_hd__a22oi_1 U8974 ( .A1(n8501), .A2(\cpuregs[15][20] ), .B1(
        n8490), .B2(\cpuregs[28][20] ), .Y(n7365) );
  sky130_fd_sc_hd__nand4_1 U8975 ( .A(n7368), .B(n7367), .C(n7366), .D(n7365), 
        .Y(n7384) );
  sky130_fd_sc_hd__a22oi_1 U8976 ( .A1(n8467), .A2(\cpuregs[26][20] ), .B1(
        n8481), .B2(\cpuregs[11][20] ), .Y(n7372) );
  sky130_fd_sc_hd__a22oi_1 U8977 ( .A1(n6059), .A2(\cpuregs[20][20] ), .B1(
        n8502), .B2(\cpuregs[6][20] ), .Y(n7371) );
  sky130_fd_sc_hd__a22oi_1 U8978 ( .A1(n6412), .A2(\cpuregs[19][20] ), .B1(
        n8488), .B2(\cpuregs[1][20] ), .Y(n7370) );
  sky130_fd_sc_hd__nand2_1 U8979 ( .A(n8500), .B(\cpuregs[30][20] ), .Y(n7369)
         );
  sky130_fd_sc_hd__nand4_1 U8980 ( .A(n7372), .B(n7371), .C(n7370), .D(n7369), 
        .Y(n7383) );
  sky130_fd_sc_hd__a22oi_1 U8981 ( .A1(n8497), .A2(\cpuregs[27][20] ), .B1(
        n8499), .B2(\cpuregs[3][20] ), .Y(n7376) );
  sky130_fd_sc_hd__a22oi_1 U8982 ( .A1(n8492), .A2(\cpuregs[4][20] ), .B1(
        n8465), .B2(\cpuregs[16][20] ), .Y(n7375) );
  sky130_fd_sc_hd__a22oi_1 U8983 ( .A1(n8489), .A2(\cpuregs[17][20] ), .B1(
        n4233), .B2(\cpuregs[8][20] ), .Y(n7374) );
  sky130_fd_sc_hd__a22oi_1 U8984 ( .A1(n8482), .A2(\cpuregs[22][20] ), .B1(
        n8471), .B2(\cpuregs[5][20] ), .Y(n7373) );
  sky130_fd_sc_hd__nand4_1 U8985 ( .A(n7376), .B(n7375), .C(n7374), .D(n7373), 
        .Y(n7382) );
  sky130_fd_sc_hd__a22oi_1 U8986 ( .A1(n8466), .A2(\cpuregs[25][20] ), .B1(
        n8479), .B2(\cpuregs[2][20] ), .Y(n7380) );
  sky130_fd_sc_hd__a22oi_1 U8987 ( .A1(n8480), .A2(\cpuregs[21][20] ), .B1(
        n8470), .B2(\cpuregs[10][20] ), .Y(n7379) );
  sky130_fd_sc_hd__a22oi_1 U8988 ( .A1(n8477), .A2(\cpuregs[7][20] ), .B1(
        n8472), .B2(\cpuregs[18][20] ), .Y(n7378) );
  sky130_fd_sc_hd__a22oi_1 U8989 ( .A1(n8464), .A2(\cpuregs[23][20] ), .B1(
        n8036), .B2(\cpuregs[9][20] ), .Y(n7377) );
  sky130_fd_sc_hd__nand4_1 U8990 ( .A(n7380), .B(n7379), .C(n7378), .D(n7377), 
        .Y(n7381) );
  sky130_fd_sc_hd__nor4_1 U8991 ( .A(n7384), .B(n7383), .C(n7382), .D(n7381), 
        .Y(n7387) );
  sky130_fd_sc_hd__a22oi_1 U8992 ( .A1(pcpi_rs2[20]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[20]), .Y(n7386) );
  sky130_fd_sc_hd__o21ai_1 U8993 ( .A1(n7387), .A2(n8514), .B1(n7386), .Y(
        n3938) );
  sky130_fd_sc_hd__nand2_1 U8994 ( .A(n7390), .B(n7389), .Y(n7395) );
  sky130_fd_sc_hd__o21ai_1 U8995 ( .A1(n7393), .A2(n7392), .B1(n7391), .Y(
        n7394) );
  sky130_fd_sc_hd__xnor2_1 U8996 ( .A(n7395), .B(n7394), .Y(n7396) );
  sky130_fd_sc_hd__nand2_1 U8997 ( .A(n7396), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n7401) );
  sky130_fd_sc_hd__nor2_1 U8998 ( .A(n8683), .B(n7397), .Y(n7398) );
  sky130_fd_sc_hd__a31oi_1 U8999 ( .A1(n9382), .A2(pcpi_rs1[20]), .A3(
        pcpi_rs2[20]), .B1(n7398), .Y(n7400) );
  sky130_fd_sc_hd__o21ai_1 U9000 ( .A1(pcpi_rs1[20]), .A2(pcpi_rs2[20]), .B1(
        n9872), .Y(n7399) );
  sky130_fd_sc_hd__nand3_1 U9001 ( .A(n7401), .B(n7400), .C(n7399), .Y(
        alu_out[20]) );
  sky130_fd_sc_hd__o22ai_1 U9002 ( .A1(n10029), .A2(n7424), .B1(n9387), .B2(
        n7403), .Y(n3999) );
  sky130_fd_sc_hd__a22oi_1 U9003 ( .A1(n9321), .A2(\cpuregs[27][20] ), .B1(
        n9497), .B2(\cpuregs[15][20] ), .Y(n7407) );
  sky130_fd_sc_hd__a22oi_1 U9004 ( .A1(n8937), .A2(\cpuregs[13][20] ), .B1(
        n9495), .B2(\cpuregs[22][20] ), .Y(n7406) );
  sky130_fd_sc_hd__a22oi_1 U9005 ( .A1(n9460), .A2(\cpuregs[24][20] ), .B1(
        n9485), .B2(\cpuregs[21][20] ), .Y(n7405) );
  sky130_fd_sc_hd__nand2_1 U9006 ( .A(n9456), .B(\cpuregs[17][20] ), .Y(n7404)
         );
  sky130_fd_sc_hd__nand4_1 U9007 ( .A(n7407), .B(n7406), .C(n7405), .D(n7404), 
        .Y(n7423) );
  sky130_fd_sc_hd__a22oi_1 U9008 ( .A1(n9316), .A2(\cpuregs[4][20] ), .B1(
        n9468), .B2(\cpuregs[16][20] ), .Y(n7411) );
  sky130_fd_sc_hd__a22oi_1 U9009 ( .A1(n9480), .A2(\cpuregs[20][20] ), .B1(
        n9473), .B2(\cpuregs[23][20] ), .Y(n7410) );
  sky130_fd_sc_hd__a22oi_1 U9010 ( .A1(n9461), .A2(\cpuregs[5][20] ), .B1(
        n9481), .B2(\cpuregs[14][20] ), .Y(n7409) );
  sky130_fd_sc_hd__a22oi_1 U9011 ( .A1(n9494), .A2(\cpuregs[8][20] ), .B1(
        n9469), .B2(\cpuregs[9][20] ), .Y(n7408) );
  sky130_fd_sc_hd__nand4_1 U9012 ( .A(n7411), .B(n7410), .C(n7409), .D(n7408), 
        .Y(n7422) );
  sky130_fd_sc_hd__a22oi_1 U9013 ( .A1(n9490), .A2(\cpuregs[11][20] ), .B1(
        n9478), .B2(\cpuregs[1][20] ), .Y(n7415) );
  sky130_fd_sc_hd__a22oi_1 U9014 ( .A1(n9496), .A2(\cpuregs[3][20] ), .B1(
        n9458), .B2(\cpuregs[30][20] ), .Y(n7414) );
  sky130_fd_sc_hd__a22oi_1 U9015 ( .A1(n9483), .A2(\cpuregs[7][20] ), .B1(
        n9482), .B2(\cpuregs[31][20] ), .Y(n7413) );
  sky130_fd_sc_hd__a22oi_1 U9016 ( .A1(n9491), .A2(\cpuregs[10][20] ), .B1(
        n9484), .B2(\cpuregs[12][20] ), .Y(n7412) );
  sky130_fd_sc_hd__nand4_1 U9017 ( .A(n7415), .B(n7414), .C(n7413), .D(n7412), 
        .Y(n7421) );
  sky130_fd_sc_hd__a22oi_1 U9018 ( .A1(n9467), .A2(\cpuregs[26][20] ), .B1(
        n9479), .B2(\cpuregs[29][20] ), .Y(n7419) );
  sky130_fd_sc_hd__a22oi_1 U9019 ( .A1(n9459), .A2(\cpuregs[18][20] ), .B1(
        n9457), .B2(\cpuregs[19][20] ), .Y(n7418) );
  sky130_fd_sc_hd__a22oi_1 U9020 ( .A1(n9493), .A2(\cpuregs[6][20] ), .B1(
        n9492), .B2(\cpuregs[28][20] ), .Y(n7417) );
  sky130_fd_sc_hd__a22oi_1 U9021 ( .A1(n9471), .A2(\cpuregs[25][20] ), .B1(
        n9462), .B2(\cpuregs[2][20] ), .Y(n7416) );
  sky130_fd_sc_hd__nand4_1 U9022 ( .A(n7419), .B(n7418), .C(n7417), .D(n7416), 
        .Y(n7420) );
  sky130_fd_sc_hd__nor4_1 U9023 ( .A(n7423), .B(n7422), .C(n7421), .D(n7420), 
        .Y(n7437) );
  sky130_fd_sc_hd__o22ai_1 U9024 ( .A1(n4321), .A2(n7424), .B1(n7549), .B2(
        n9340), .Y(n7425) );
  sky130_fd_sc_hd__a21oi_1 U9025 ( .A1(n9345), .A2(pcpi_rs1[24]), .B1(n7425), 
        .Y(n7436) );
  sky130_fd_sc_hd__nand2_1 U9026 ( .A(n7427), .B(n7426), .Y(n7429) );
  sky130_fd_sc_hd__xnor2_1 U9027 ( .A(n7429), .B(n7428), .Y(n7434) );
  sky130_fd_sc_hd__nor2_1 U9028 ( .A(n8890), .B(n4340), .Y(n7433) );
  sky130_fd_sc_hd__o22ai_1 U9029 ( .A1(n7431), .A2(n4371), .B1(n7430), .B2(
        n4342), .Y(n7432) );
  sky130_fd_sc_hd__a211oi_1 U9030 ( .A1(n9511), .A2(n7434), .B1(n7433), .C1(
        n7432), .Y(n7435) );
  sky130_fd_sc_hd__o211ai_1 U9031 ( .A1(n7437), .A2(n9506), .B1(n7436), .C1(
        n7435), .Y(n2775) );
  sky130_fd_sc_hd__nand2_1 U9032 ( .A(n7440), .B(n7439), .Y(n7441) );
  sky130_fd_sc_hd__xnor2_1 U9033 ( .A(n7441), .B(n7569), .Y(n7442) );
  sky130_fd_sc_hd__nand2_1 U9034 ( .A(n7442), .B(n4639), .Y(n7447) );
  sky130_fd_sc_hd__a22oi_1 U9035 ( .A1(n9861), .A2(count_cycle[56]), .B1(n9860), .B2(count_cycle[24]), .Y(n7446) );
  sky130_fd_sc_hd__a22o_1 U9036 ( .A1(pcpi_rs1[24]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[24]), .X(n7443) );
  sky130_fd_sc_hd__a211oi_1 U9037 ( .A1(n9857), .A2(count_instr[24]), .B1(
        n7707), .C1(n7443), .Y(n7445) );
  sky130_fd_sc_hd__nand2_1 U9038 ( .A(n9856), .B(count_instr[56]), .Y(n7444)
         );
  sky130_fd_sc_hd__nand4_1 U9039 ( .A(n7447), .B(n7446), .C(n7445), .D(n7444), 
        .Y(N1901) );
  sky130_fd_sc_hd__xor2_1 U9040 ( .A(n7448), .B(n7542), .X(n7449) );
  sky130_fd_sc_hd__a222oi_1 U9041 ( .A1(alu_out_q[24]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[24]), .C1(n7449), .C2(n9813), .Y(n7464) );
  sky130_fd_sc_hd__nand2_1 U9042 ( .A(n10057), .B(\cpuregs[24][24] ), .Y(n7450) );
  sky130_fd_sc_hd__o21ai_1 U9043 ( .A1(n10057), .A2(n4196), .B1(n7450), .Y(
        n3175) );
  sky130_fd_sc_hd__nand2_1 U9044 ( .A(n4177), .B(\cpuregs[30][24] ), .Y(n7451)
         );
  sky130_fd_sc_hd__o21ai_1 U9045 ( .A1(n4177), .A2(n4196), .B1(n7451), .Y(
        n3181) );
  sky130_fd_sc_hd__nand2_1 U9046 ( .A(n7452), .B(\cpuregs[9][24] ), .Y(n7453)
         );
  sky130_fd_sc_hd__o21ai_1 U9047 ( .A1(n7452), .A2(n4196), .B1(n7453), .Y(
        n3160) );
  sky130_fd_sc_hd__nand2_1 U9048 ( .A(n4173), .B(\cpuregs[23][24] ), .Y(n7454)
         );
  sky130_fd_sc_hd__o21ai_1 U9049 ( .A1(n4173), .A2(n4196), .B1(n7454), .Y(
        n3174) );
  sky130_fd_sc_hd__nand2_1 U9050 ( .A(n7069), .B(\cpuregs[15][24] ), .Y(n7455)
         );
  sky130_fd_sc_hd__o21ai_1 U9051 ( .A1(n7069), .A2(n4196), .B1(n7455), .Y(
        n3166) );
  sky130_fd_sc_hd__nand2_1 U9052 ( .A(n4219), .B(\cpuregs[28][24] ), .Y(n7456)
         );
  sky130_fd_sc_hd__o21ai_1 U9053 ( .A1(n4219), .A2(n4196), .B1(n7456), .Y(
        n3179) );
  sky130_fd_sc_hd__nand2_1 U9054 ( .A(n4199), .B(\cpuregs[7][24] ), .Y(n7457)
         );
  sky130_fd_sc_hd__o21ai_1 U9055 ( .A1(n4199), .A2(n4196), .B1(n7457), .Y(
        n3158) );
  sky130_fd_sc_hd__nand2_1 U9056 ( .A(n4226), .B(\cpuregs[12][24] ), .Y(n7458)
         );
  sky130_fd_sc_hd__o21ai_1 U9057 ( .A1(n4226), .A2(n4196), .B1(n7458), .Y(
        n3163) );
  sky130_fd_sc_hd__nand2_1 U9058 ( .A(n4184), .B(\cpuregs[10][24] ), .Y(n7459)
         );
  sky130_fd_sc_hd__o21ai_1 U9059 ( .A1(n4184), .A2(n4196), .B1(n7459), .Y(
        n3161) );
  sky130_fd_sc_hd__nand2_1 U9060 ( .A(n9820), .B(\cpuregs[18][24] ), .Y(n7460)
         );
  sky130_fd_sc_hd__o21ai_1 U9061 ( .A1(n9820), .A2(n4196), .B1(n7460), .Y(
        n3169) );
  sky130_fd_sc_hd__nand2_1 U9062 ( .A(n6897), .B(\cpuregs[14][24] ), .Y(n7461)
         );
  sky130_fd_sc_hd__o21ai_1 U9063 ( .A1(n6897), .A2(n4196), .B1(n7461), .Y(
        n3165) );
  sky130_fd_sc_hd__nand2_1 U9064 ( .A(n4174), .B(\cpuregs[21][24] ), .Y(n7462)
         );
  sky130_fd_sc_hd__o21ai_1 U9065 ( .A1(n4174), .A2(n4196), .B1(n7462), .Y(
        n3172) );
  sky130_fd_sc_hd__nand2_1 U9066 ( .A(n4192), .B(\cpuregs[25][24] ), .Y(n7463)
         );
  sky130_fd_sc_hd__o21ai_1 U9067 ( .A1(n4192), .A2(n4196), .B1(n7463), .Y(
        n3176) );
  sky130_fd_sc_hd__nand2_1 U9068 ( .A(n4178), .B(\cpuregs[2][24] ), .Y(n7465)
         );
  sky130_fd_sc_hd__o21ai_1 U9069 ( .A1(n4178), .A2(n4196), .B1(n7465), .Y(
        n3153) );
  sky130_fd_sc_hd__nand2_1 U9070 ( .A(n7247), .B(\cpuregs[31][24] ), .Y(n7466)
         );
  sky130_fd_sc_hd__o21ai_1 U9071 ( .A1(n7247), .A2(n4196), .B1(n7466), .Y(
        n3182) );
  sky130_fd_sc_hd__nand2_1 U9072 ( .A(n4180), .B(\cpuregs[5][24] ), .Y(n7467)
         );
  sky130_fd_sc_hd__o21ai_1 U9073 ( .A1(n4180), .A2(n4196), .B1(n7467), .Y(
        n3156) );
  sky130_fd_sc_hd__nand2_1 U9074 ( .A(n4183), .B(\cpuregs[8][24] ), .Y(n7468)
         );
  sky130_fd_sc_hd__o21ai_1 U9075 ( .A1(n4183), .A2(n4196), .B1(n7468), .Y(
        n3159) );
  sky130_fd_sc_hd__nand2_1 U9076 ( .A(n7084), .B(\cpuregs[22][24] ), .Y(n7469)
         );
  sky130_fd_sc_hd__o21ai_1 U9077 ( .A1(n7084), .A2(n4196), .B1(n7469), .Y(
        n3173) );
  sky130_fd_sc_hd__nand2_1 U9078 ( .A(n4175), .B(\cpuregs[27][24] ), .Y(n7470)
         );
  sky130_fd_sc_hd__o21ai_1 U9079 ( .A1(n4175), .A2(n4196), .B1(n7470), .Y(
        n3178) );
  sky130_fd_sc_hd__nand2_1 U9080 ( .A(n4195), .B(\cpuregs[17][24] ), .Y(n7471)
         );
  sky130_fd_sc_hd__o21ai_1 U9081 ( .A1(n4195), .A2(n4196), .B1(n7471), .Y(
        n3168) );
  sky130_fd_sc_hd__nand2_1 U9082 ( .A(n4179), .B(\cpuregs[4][24] ), .Y(n7472)
         );
  sky130_fd_sc_hd__o21ai_1 U9083 ( .A1(n4179), .A2(n4196), .B1(n7472), .Y(
        n3155) );
  sky130_fd_sc_hd__nand2_1 U9084 ( .A(n4201), .B(\cpuregs[3][24] ), .Y(n7473)
         );
  sky130_fd_sc_hd__o21ai_1 U9085 ( .A1(n4201), .A2(n4196), .B1(n7473), .Y(
        n3154) );
  sky130_fd_sc_hd__nand2_1 U9086 ( .A(n4186), .B(\cpuregs[13][24] ), .Y(n7474)
         );
  sky130_fd_sc_hd__o21ai_1 U9087 ( .A1(n4186), .A2(n4196), .B1(n7474), .Y(
        n3164) );
  sky130_fd_sc_hd__nand2_1 U9088 ( .A(n4197), .B(\cpuregs[16][24] ), .Y(n7475)
         );
  sky130_fd_sc_hd__o21ai_1 U9089 ( .A1(n4197), .A2(n4196), .B1(n7475), .Y(
        n3167) );
  sky130_fd_sc_hd__nand2_1 U9090 ( .A(n6396), .B(\cpuregs[1][24] ), .Y(n7476)
         );
  sky130_fd_sc_hd__o21ai_1 U9091 ( .A1(n6396), .A2(n4196), .B1(n7476), .Y(
        n3152) );
  sky130_fd_sc_hd__nand2_1 U9092 ( .A(n4194), .B(\cpuregs[19][24] ), .Y(n7477)
         );
  sky130_fd_sc_hd__o21ai_1 U9093 ( .A1(n4194), .A2(n4196), .B1(n7477), .Y(
        n3170) );
  sky130_fd_sc_hd__nand2_1 U9094 ( .A(n4176), .B(\cpuregs[29][24] ), .Y(n7478)
         );
  sky130_fd_sc_hd__o21ai_1 U9095 ( .A1(n4176), .A2(n4196), .B1(n7478), .Y(
        n3180) );
  sky130_fd_sc_hd__nand2_1 U9096 ( .A(n4185), .B(\cpuregs[11][24] ), .Y(n7479)
         );
  sky130_fd_sc_hd__o21ai_1 U9097 ( .A1(n4185), .A2(n4196), .B1(n7479), .Y(
        n3162) );
  sky130_fd_sc_hd__nand2_1 U9098 ( .A(n10058), .B(\cpuregs[20][24] ), .Y(n7480) );
  sky130_fd_sc_hd__o21ai_1 U9099 ( .A1(n10058), .A2(n4196), .B1(n7480), .Y(
        n3171) );
  sky130_fd_sc_hd__nand2_1 U9100 ( .A(n9621), .B(\cpuregs[26][24] ), .Y(n7481)
         );
  sky130_fd_sc_hd__o21ai_1 U9101 ( .A1(n9621), .A2(n4196), .B1(n7481), .Y(
        n3177) );
  sky130_fd_sc_hd__nand2_1 U9102 ( .A(n6541), .B(\cpuregs[6][24] ), .Y(n7482)
         );
  sky130_fd_sc_hd__o21ai_1 U9103 ( .A1(n9209), .A2(n4196), .B1(n7482), .Y(
        n3157) );
  sky130_fd_sc_hd__a22oi_1 U9104 ( .A1(decoded_imm[24]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[24]), .Y(n7483) );
  sky130_fd_sc_hd__nand2_1 U9105 ( .A(n8437), .B(n7483), .Y(n2848) );
  sky130_fd_sc_hd__a22oi_1 U9106 ( .A1(n6137), .A2(\cpuregs[29][24] ), .B1(
        n8503), .B2(\cpuregs[24][24] ), .Y(n7487) );
  sky130_fd_sc_hd__a22oi_1 U9107 ( .A1(n8478), .A2(\cpuregs[13][24] ), .B1(
        n8487), .B2(\cpuregs[31][24] ), .Y(n7486) );
  sky130_fd_sc_hd__a22oi_1 U9108 ( .A1(n8498), .A2(\cpuregs[14][24] ), .B1(
        n8491), .B2(\cpuregs[12][24] ), .Y(n7485) );
  sky130_fd_sc_hd__a22oi_1 U9109 ( .A1(n8501), .A2(\cpuregs[15][24] ), .B1(
        n8490), .B2(\cpuregs[28][24] ), .Y(n7484) );
  sky130_fd_sc_hd__nand4_1 U9110 ( .A(n7487), .B(n7486), .C(n7485), .D(n7484), 
        .Y(n7503) );
  sky130_fd_sc_hd__a22oi_1 U9111 ( .A1(n8467), .A2(\cpuregs[26][24] ), .B1(
        n8481), .B2(\cpuregs[11][24] ), .Y(n7491) );
  sky130_fd_sc_hd__a22oi_1 U9112 ( .A1(n6059), .A2(\cpuregs[20][24] ), .B1(
        n8502), .B2(\cpuregs[6][24] ), .Y(n7490) );
  sky130_fd_sc_hd__a22oi_1 U9113 ( .A1(n6412), .A2(\cpuregs[19][24] ), .B1(
        n8488), .B2(\cpuregs[1][24] ), .Y(n7489) );
  sky130_fd_sc_hd__nand2_1 U9114 ( .A(n8500), .B(\cpuregs[30][24] ), .Y(n7488)
         );
  sky130_fd_sc_hd__nand4_1 U9115 ( .A(n7491), .B(n7490), .C(n7489), .D(n7488), 
        .Y(n7502) );
  sky130_fd_sc_hd__a22oi_1 U9116 ( .A1(n8497), .A2(\cpuregs[27][24] ), .B1(
        n8499), .B2(\cpuregs[3][24] ), .Y(n7495) );
  sky130_fd_sc_hd__a22oi_1 U9117 ( .A1(n8492), .A2(\cpuregs[4][24] ), .B1(
        n8465), .B2(\cpuregs[16][24] ), .Y(n7494) );
  sky130_fd_sc_hd__a22oi_1 U9118 ( .A1(n8489), .A2(\cpuregs[17][24] ), .B1(
        n4233), .B2(\cpuregs[8][24] ), .Y(n7493) );
  sky130_fd_sc_hd__a22oi_1 U9119 ( .A1(n8482), .A2(\cpuregs[22][24] ), .B1(
        n8471), .B2(\cpuregs[5][24] ), .Y(n7492) );
  sky130_fd_sc_hd__nand4_1 U9120 ( .A(n7495), .B(n7494), .C(n7493), .D(n7492), 
        .Y(n7501) );
  sky130_fd_sc_hd__a22oi_1 U9121 ( .A1(n8466), .A2(\cpuregs[25][24] ), .B1(
        n8479), .B2(\cpuregs[2][24] ), .Y(n7499) );
  sky130_fd_sc_hd__a22oi_1 U9122 ( .A1(n8480), .A2(\cpuregs[21][24] ), .B1(
        n8470), .B2(\cpuregs[10][24] ), .Y(n7498) );
  sky130_fd_sc_hd__a22oi_1 U9123 ( .A1(n8477), .A2(\cpuregs[7][24] ), .B1(
        n8472), .B2(\cpuregs[18][24] ), .Y(n7497) );
  sky130_fd_sc_hd__a22oi_1 U9124 ( .A1(n8464), .A2(\cpuregs[23][24] ), .B1(
        n8036), .B2(\cpuregs[9][24] ), .Y(n7496) );
  sky130_fd_sc_hd__nand4_1 U9125 ( .A(n7499), .B(n7498), .C(n7497), .D(n7496), 
        .Y(n7500) );
  sky130_fd_sc_hd__nor4_1 U9126 ( .A(n7503), .B(n7502), .C(n7501), .D(n7500), 
        .Y(n7505) );
  sky130_fd_sc_hd__a22oi_1 U9127 ( .A1(pcpi_rs2[24]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[24]), .Y(n7504) );
  sky130_fd_sc_hd__o21ai_1 U9128 ( .A1(n7505), .A2(n8514), .B1(n7504), .Y(
        n3934) );
  sky130_fd_sc_hd__nand2_1 U9129 ( .A(n7508), .B(n7507), .Y(n7513) );
  sky130_fd_sc_hd__o21ai_1 U9130 ( .A1(n7511), .A2(n7510), .B1(n7509), .Y(
        n7512) );
  sky130_fd_sc_hd__xnor2_1 U9131 ( .A(n7513), .B(n7512), .Y(n7518) );
  sky130_fd_sc_hd__a21oi_1 U9132 ( .A1(n9873), .A2(n7516), .B1(n9872), .Y(
        n7514) );
  sky130_fd_sc_hd__o22ai_1 U9133 ( .A1(n7516), .A2(n9877), .B1(n7515), .B2(
        n7514), .Y(n7517) );
  sky130_fd_sc_hd__a21o_1 U9134 ( .A1(n7518), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n7517), .X(alu_out[24]) );
  sky130_fd_sc_hd__o22ai_1 U9135 ( .A1(n10029), .A2(n7542), .B1(n9387), .B2(
        n7520), .Y(n3995) );
  sky130_fd_sc_hd__a22oi_1 U9136 ( .A1(n9467), .A2(\cpuregs[26][24] ), .B1(
        n9494), .B2(\cpuregs[8][24] ), .Y(n7524) );
  sky130_fd_sc_hd__a22oi_1 U9137 ( .A1(n9490), .A2(\cpuregs[11][24] ), .B1(
        n9459), .B2(\cpuregs[18][24] ), .Y(n7523) );
  sky130_fd_sc_hd__a22oi_1 U9138 ( .A1(n9478), .A2(\cpuregs[1][24] ), .B1(
        n9462), .B2(\cpuregs[2][24] ), .Y(n7522) );
  sky130_fd_sc_hd__nand2_1 U9139 ( .A(n9316), .B(\cpuregs[4][24] ), .Y(n7521)
         );
  sky130_fd_sc_hd__nand4_1 U9140 ( .A(n7524), .B(n7523), .C(n7522), .D(n7521), 
        .Y(n7540) );
  sky130_fd_sc_hd__a22oi_1 U9141 ( .A1(n9492), .A2(\cpuregs[28][24] ), .B1(
        n9480), .B2(\cpuregs[20][24] ), .Y(n7528) );
  sky130_fd_sc_hd__a22oi_1 U9142 ( .A1(n9481), .A2(\cpuregs[14][24] ), .B1(
        n9497), .B2(\cpuregs[15][24] ), .Y(n7527) );
  sky130_fd_sc_hd__a22oi_1 U9143 ( .A1(n9491), .A2(\cpuregs[10][24] ), .B1(
        n9473), .B2(\cpuregs[23][24] ), .Y(n7526) );
  sky130_fd_sc_hd__a22oi_1 U9144 ( .A1(n9483), .A2(\cpuregs[7][24] ), .B1(
        n9495), .B2(\cpuregs[22][24] ), .Y(n7525) );
  sky130_fd_sc_hd__nand4_1 U9145 ( .A(n7528), .B(n7527), .C(n7526), .D(n7525), 
        .Y(n7539) );
  sky130_fd_sc_hd__a22oi_1 U9146 ( .A1(n9485), .A2(\cpuregs[21][24] ), .B1(
        n9457), .B2(\cpuregs[19][24] ), .Y(n7532) );
  sky130_fd_sc_hd__a22oi_1 U9147 ( .A1(n9496), .A2(\cpuregs[3][24] ), .B1(
        n9479), .B2(\cpuregs[29][24] ), .Y(n7531) );
  sky130_fd_sc_hd__a22oi_1 U9148 ( .A1(n9470), .A2(\cpuregs[13][24] ), .B1(
        n9456), .B2(\cpuregs[17][24] ), .Y(n7530) );
  sky130_fd_sc_hd__a22oi_1 U9149 ( .A1(n9458), .A2(\cpuregs[30][24] ), .B1(
        n9468), .B2(\cpuregs[16][24] ), .Y(n7529) );
  sky130_fd_sc_hd__nand4_1 U9150 ( .A(n7532), .B(n7531), .C(n7530), .D(n7529), 
        .Y(n7538) );
  sky130_fd_sc_hd__a22oi_1 U9151 ( .A1(n9471), .A2(\cpuregs[25][24] ), .B1(
        n9493), .B2(\cpuregs[6][24] ), .Y(n7536) );
  sky130_fd_sc_hd__a22oi_1 U9152 ( .A1(n9469), .A2(\cpuregs[9][24] ), .B1(
        n9482), .B2(\cpuregs[31][24] ), .Y(n7535) );
  sky130_fd_sc_hd__a22oi_1 U9153 ( .A1(n9321), .A2(\cpuregs[27][24] ), .B1(
        n9460), .B2(\cpuregs[24][24] ), .Y(n7534) );
  sky130_fd_sc_hd__a22oi_1 U9154 ( .A1(n9461), .A2(\cpuregs[5][24] ), .B1(
        n9484), .B2(\cpuregs[12][24] ), .Y(n7533) );
  sky130_fd_sc_hd__nand4_1 U9155 ( .A(n7536), .B(n7535), .C(n7534), .D(n7533), 
        .Y(n7537) );
  sky130_fd_sc_hd__nor4_1 U9156 ( .A(n7540), .B(n7539), .C(n7538), .D(n7537), 
        .Y(n7555) );
  sky130_fd_sc_hd__o22ai_1 U9157 ( .A1(n4321), .A2(n7542), .B1(n7541), .B2(
        n9340), .Y(n7543) );
  sky130_fd_sc_hd__a21oi_1 U9158 ( .A1(n9345), .A2(pcpi_rs1[28]), .B1(n7543), 
        .Y(n7554) );
  sky130_fd_sc_hd__nand2_1 U9159 ( .A(n7546), .B(n7545), .Y(n7547) );
  sky130_fd_sc_hd__xnor2_1 U9160 ( .A(n7547), .B(n8959), .Y(n7552) );
  sky130_fd_sc_hd__nor2_1 U9161 ( .A(n7548), .B(n4340), .Y(n7551) );
  sky130_fd_sc_hd__o22ai_1 U9162 ( .A1(n8932), .A2(n4342), .B1(n7549), .B2(
        n4371), .Y(n7550) );
  sky130_fd_sc_hd__a211oi_1 U9163 ( .A1(n9511), .A2(n7552), .B1(n7551), .C1(
        n7550), .Y(n7553) );
  sky130_fd_sc_hd__o211ai_1 U9164 ( .A1(n7555), .A2(n9506), .B1(n7554), .C1(
        n7553), .Y(n2771) );
  sky130_fd_sc_hd__nand2_1 U9165 ( .A(n7557), .B(n7556), .Y(n7559) );
  sky130_fd_sc_hd__xnor2_1 U9166 ( .A(n7559), .B(n7558), .Y(n7560) );
  sky130_fd_sc_hd__nand2_1 U9167 ( .A(n7560), .B(n4639), .Y(n7565) );
  sky130_fd_sc_hd__a22oi_1 U9168 ( .A1(n9861), .A2(count_cycle[60]), .B1(n9860), .B2(count_cycle[28]), .Y(n7564) );
  sky130_fd_sc_hd__a22o_1 U9169 ( .A1(n9858), .A2(pcpi_rs1[28]), .B1(n7705), 
        .B2(mem_rdata_word[28]), .X(n7561) );
  sky130_fd_sc_hd__a211oi_1 U9170 ( .A1(n9857), .A2(count_instr[28]), .B1(
        n7707), .C1(n7561), .Y(n7563) );
  sky130_fd_sc_hd__nand2_1 U9171 ( .A(n9856), .B(count_instr[60]), .Y(n7562)
         );
  sky130_fd_sc_hd__nand4_1 U9172 ( .A(n7565), .B(n7564), .C(n7563), .D(n7562), 
        .Y(N1905) );
  sky130_fd_sc_hd__a22o_1 U9173 ( .A1(n10055), .A2(n7566), .B1(n9530), .B2(
        reg_pc[28]), .X(n3991) );
  sky130_fd_sc_hd__a21oi_1 U9174 ( .A1(n7569), .A2(n7568), .B1(n7567), .Y(
        n7573) );
  sky130_fd_sc_hd__nand2_1 U9175 ( .A(n7571), .B(n7570), .Y(n7572) );
  sky130_fd_sc_hd__xor2_1 U9176 ( .A(n7573), .B(n7572), .X(n7574) );
  sky130_fd_sc_hd__nand2_1 U9177 ( .A(n7574), .B(n4639), .Y(n7579) );
  sky130_fd_sc_hd__a22oi_1 U9178 ( .A1(n9861), .A2(count_cycle[58]), .B1(n9860), .B2(count_cycle[26]), .Y(n7578) );
  sky130_fd_sc_hd__a22o_1 U9179 ( .A1(pcpi_rs1[26]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[26]), .X(n7575) );
  sky130_fd_sc_hd__a211oi_1 U9180 ( .A1(n9857), .A2(count_instr[26]), .B1(
        n7707), .C1(n7575), .Y(n7577) );
  sky130_fd_sc_hd__nand2_1 U9181 ( .A(n9856), .B(count_instr[58]), .Y(n7576)
         );
  sky130_fd_sc_hd__nand4_1 U9182 ( .A(n7579), .B(n7578), .C(n7577), .D(n7576), 
        .Y(N1903) );
  sky130_fd_sc_hd__a22oi_1 U9183 ( .A1(decoded_imm[26]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[26]), .Y(n7580) );
  sky130_fd_sc_hd__nand2_1 U9184 ( .A(n8437), .B(n7580), .Y(n2846) );
  sky130_fd_sc_hd__a22oi_1 U9185 ( .A1(n8478), .A2(\cpuregs[13][26] ), .B1(
        n8466), .B2(\cpuregs[25][26] ), .Y(n7584) );
  sky130_fd_sc_hd__a22oi_1 U9186 ( .A1(n8464), .A2(\cpuregs[23][26] ), .B1(
        n8503), .B2(\cpuregs[24][26] ), .Y(n7583) );
  sky130_fd_sc_hd__a22oi_1 U9187 ( .A1(n8497), .A2(\cpuregs[27][26] ), .B1(
        n8036), .B2(\cpuregs[9][26] ), .Y(n7582) );
  sky130_fd_sc_hd__nand2_1 U9188 ( .A(n8492), .B(\cpuregs[4][26] ), .Y(n7581)
         );
  sky130_fd_sc_hd__nand4_1 U9189 ( .A(n7584), .B(n7583), .C(n7582), .D(n7581), 
        .Y(n7600) );
  sky130_fd_sc_hd__a22oi_1 U9190 ( .A1(n8488), .A2(\cpuregs[1][26] ), .B1(
        n4233), .B2(\cpuregs[8][26] ), .Y(n7588) );
  sky130_fd_sc_hd__a22oi_1 U9191 ( .A1(n8482), .A2(\cpuregs[22][26] ), .B1(
        n8467), .B2(\cpuregs[26][26] ), .Y(n7587) );
  sky130_fd_sc_hd__a22oi_1 U9192 ( .A1(n8498), .A2(\cpuregs[14][26] ), .B1(
        n8489), .B2(\cpuregs[17][26] ), .Y(n7586) );
  sky130_fd_sc_hd__a22oi_1 U9193 ( .A1(n8501), .A2(\cpuregs[15][26] ), .B1(
        n8470), .B2(\cpuregs[10][26] ), .Y(n7585) );
  sky130_fd_sc_hd__nand4_1 U9194 ( .A(n7588), .B(n7587), .C(n7586), .D(n7585), 
        .Y(n7599) );
  sky130_fd_sc_hd__a22oi_1 U9195 ( .A1(n8502), .A2(\cpuregs[6][26] ), .B1(
        n8490), .B2(\cpuregs[28][26] ), .Y(n7592) );
  sky130_fd_sc_hd__a22oi_1 U9196 ( .A1(n8491), .A2(\cpuregs[12][26] ), .B1(
        n8465), .B2(\cpuregs[16][26] ), .Y(n7591) );
  sky130_fd_sc_hd__a22oi_1 U9197 ( .A1(n8477), .A2(\cpuregs[7][26] ), .B1(
        n8479), .B2(\cpuregs[2][26] ), .Y(n7590) );
  sky130_fd_sc_hd__a22oi_1 U9198 ( .A1(n8480), .A2(\cpuregs[21][26] ), .B1(
        n8499), .B2(\cpuregs[3][26] ), .Y(n7589) );
  sky130_fd_sc_hd__nand4_1 U9199 ( .A(n7592), .B(n7591), .C(n7590), .D(n7589), 
        .Y(n7598) );
  sky130_fd_sc_hd__a22oi_1 U9200 ( .A1(n8500), .A2(\cpuregs[30][26] ), .B1(
        n6412), .B2(\cpuregs[19][26] ), .Y(n7596) );
  sky130_fd_sc_hd__a22oi_1 U9201 ( .A1(n6059), .A2(\cpuregs[20][26] ), .B1(
        n8487), .B2(\cpuregs[31][26] ), .Y(n7595) );
  sky130_fd_sc_hd__a22oi_1 U9202 ( .A1(n8471), .A2(\cpuregs[5][26] ), .B1(
        n8481), .B2(\cpuregs[11][26] ), .Y(n7594) );
  sky130_fd_sc_hd__a22oi_1 U9203 ( .A1(n6137), .A2(\cpuregs[29][26] ), .B1(
        n8472), .B2(\cpuregs[18][26] ), .Y(n7593) );
  sky130_fd_sc_hd__nand4_1 U9204 ( .A(n7596), .B(n7595), .C(n7594), .D(n7593), 
        .Y(n7597) );
  sky130_fd_sc_hd__nor4_1 U9205 ( .A(n7600), .B(n7599), .C(n7598), .D(n7597), 
        .Y(n7602) );
  sky130_fd_sc_hd__a22oi_1 U9206 ( .A1(pcpi_rs2[26]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[26]), .Y(n7601) );
  sky130_fd_sc_hd__o21ai_1 U9207 ( .A1(n8514), .A2(n7602), .B1(n7601), .Y(
        n3932) );
  sky130_fd_sc_hd__nand2_1 U9208 ( .A(n7605), .B(n7604), .Y(n7610) );
  sky130_fd_sc_hd__o21ai_1 U9209 ( .A1(n7608), .A2(n7607), .B1(n7606), .Y(
        n7609) );
  sky130_fd_sc_hd__xnor2_1 U9210 ( .A(n7610), .B(n7609), .Y(n7615) );
  sky130_fd_sc_hd__a21oi_1 U9211 ( .A1(n9873), .A2(n7613), .B1(n9872), .Y(
        n7611) );
  sky130_fd_sc_hd__o22ai_1 U9212 ( .A1(n9877), .A2(n7613), .B1(n7612), .B2(
        n7611), .Y(n7614) );
  sky130_fd_sc_hd__a21o_1 U9213 ( .A1(n7615), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n7614), .X(alu_out[26]) );
  sky130_fd_sc_hd__o21ai_1 U9214 ( .A1(n10029), .A2(n9776), .B1(n7616), .Y(
        n3993) );
  sky130_fd_sc_hd__nand2_1 U9215 ( .A(n7618), .B(n7617), .Y(n7620) );
  sky130_fd_sc_hd__xnor2_1 U9216 ( .A(n7620), .B(n7619), .Y(n7621) );
  sky130_fd_sc_hd__nand2_1 U9217 ( .A(n7621), .B(n4639), .Y(n7626) );
  sky130_fd_sc_hd__a22oi_1 U9218 ( .A1(n9861), .A2(count_cycle[54]), .B1(n9860), .B2(count_cycle[22]), .Y(n7625) );
  sky130_fd_sc_hd__a22o_1 U9219 ( .A1(pcpi_rs1[22]), .A2(n9858), .B1(n7705), 
        .B2(mem_rdata_word[22]), .X(n7622) );
  sky130_fd_sc_hd__a211oi_1 U9220 ( .A1(n9857), .A2(count_instr[22]), .B1(
        n7707), .C1(n7622), .Y(n7624) );
  sky130_fd_sc_hd__nand2_1 U9221 ( .A(n9856), .B(count_instr[54]), .Y(n7623)
         );
  sky130_fd_sc_hd__nand4_1 U9222 ( .A(n7626), .B(n7625), .C(n7624), .D(n7623), 
        .Y(N1899) );
  sky130_fd_sc_hd__xor2_1 U9223 ( .A(n7628), .B(n7627), .X(n7629) );
  sky130_fd_sc_hd__a222oi_1 U9224 ( .A1(reg_out[22]), .A2(n9816), .B1(
        alu_out_q[22]), .B2(n9815), .C1(n7629), .C2(n9813), .Y(n7643) );
  sky130_fd_sc_hd__nand2_1 U9225 ( .A(n10057), .B(\cpuregs[24][22] ), .Y(n7630) );
  sky130_fd_sc_hd__o21ai_1 U9226 ( .A1(n10057), .A2(n4191), .B1(n7630), .Y(
        n3237) );
  sky130_fd_sc_hd__nand2_1 U9227 ( .A(n4177), .B(\cpuregs[30][22] ), .Y(n7631)
         );
  sky130_fd_sc_hd__o21ai_1 U9228 ( .A1(n4177), .A2(n4191), .B1(n7631), .Y(
        n3243) );
  sky130_fd_sc_hd__nand2_1 U9229 ( .A(n7452), .B(\cpuregs[9][22] ), .Y(n7632)
         );
  sky130_fd_sc_hd__o21ai_1 U9230 ( .A1(n7452), .A2(n4191), .B1(n7632), .Y(
        n3222) );
  sky130_fd_sc_hd__nand2_1 U9231 ( .A(n4173), .B(\cpuregs[23][22] ), .Y(n7633)
         );
  sky130_fd_sc_hd__o21ai_1 U9232 ( .A1(n4173), .A2(n4191), .B1(n7633), .Y(
        n3236) );
  sky130_fd_sc_hd__nand2_1 U9233 ( .A(n7069), .B(\cpuregs[15][22] ), .Y(n7634)
         );
  sky130_fd_sc_hd__o21ai_1 U9234 ( .A1(n7069), .A2(n4191), .B1(n7634), .Y(
        n3228) );
  sky130_fd_sc_hd__nand2_1 U9235 ( .A(n4219), .B(\cpuregs[28][22] ), .Y(n7635)
         );
  sky130_fd_sc_hd__o21ai_1 U9236 ( .A1(n4219), .A2(n4191), .B1(n7635), .Y(
        n3241) );
  sky130_fd_sc_hd__nand2_1 U9237 ( .A(n4199), .B(\cpuregs[7][22] ), .Y(n7636)
         );
  sky130_fd_sc_hd__o21ai_1 U9238 ( .A1(n4199), .A2(n4191), .B1(n7636), .Y(
        n3220) );
  sky130_fd_sc_hd__nand2_1 U9239 ( .A(n4226), .B(\cpuregs[12][22] ), .Y(n7637)
         );
  sky130_fd_sc_hd__o21ai_1 U9240 ( .A1(n4226), .A2(n4191), .B1(n7637), .Y(
        n3225) );
  sky130_fd_sc_hd__nand2_1 U9241 ( .A(n4184), .B(\cpuregs[10][22] ), .Y(n7638)
         );
  sky130_fd_sc_hd__o21ai_1 U9242 ( .A1(n4184), .A2(n4191), .B1(n7638), .Y(
        n3223) );
  sky130_fd_sc_hd__nand2_1 U9243 ( .A(n9820), .B(\cpuregs[18][22] ), .Y(n7639)
         );
  sky130_fd_sc_hd__o21ai_1 U9244 ( .A1(n9820), .A2(n4191), .B1(n7639), .Y(
        n3231) );
  sky130_fd_sc_hd__nand2_1 U9245 ( .A(n6897), .B(\cpuregs[14][22] ), .Y(n7640)
         );
  sky130_fd_sc_hd__o21ai_1 U9246 ( .A1(n6897), .A2(n4191), .B1(n7640), .Y(
        n3227) );
  sky130_fd_sc_hd__nand2_1 U9247 ( .A(n4174), .B(\cpuregs[21][22] ), .Y(n7641)
         );
  sky130_fd_sc_hd__o21ai_1 U9248 ( .A1(n4174), .A2(n4191), .B1(n7641), .Y(
        n3234) );
  sky130_fd_sc_hd__nand2_1 U9249 ( .A(n4192), .B(\cpuregs[25][22] ), .Y(n7642)
         );
  sky130_fd_sc_hd__o21ai_1 U9250 ( .A1(n4192), .A2(n4191), .B1(n7642), .Y(
        n3238) );
  sky130_fd_sc_hd__nand2_1 U9251 ( .A(n4178), .B(\cpuregs[2][22] ), .Y(n7644)
         );
  sky130_fd_sc_hd__o21ai_1 U9252 ( .A1(n4178), .A2(n4191), .B1(n7644), .Y(
        n3215) );
  sky130_fd_sc_hd__nand2_1 U9253 ( .A(n7247), .B(\cpuregs[31][22] ), .Y(n7645)
         );
  sky130_fd_sc_hd__o21ai_1 U9254 ( .A1(n7247), .A2(n4191), .B1(n7645), .Y(
        n3244) );
  sky130_fd_sc_hd__nand2_1 U9255 ( .A(n4180), .B(\cpuregs[5][22] ), .Y(n7646)
         );
  sky130_fd_sc_hd__o21ai_1 U9256 ( .A1(n4180), .A2(n4191), .B1(n7646), .Y(
        n3218) );
  sky130_fd_sc_hd__nand2_1 U9257 ( .A(n4183), .B(\cpuregs[8][22] ), .Y(n7647)
         );
  sky130_fd_sc_hd__o21ai_1 U9258 ( .A1(n4183), .A2(n4191), .B1(n7647), .Y(
        n3221) );
  sky130_fd_sc_hd__nand2_1 U9259 ( .A(n7084), .B(\cpuregs[22][22] ), .Y(n7648)
         );
  sky130_fd_sc_hd__o21ai_1 U9260 ( .A1(n7084), .A2(n4191), .B1(n7648), .Y(
        n3235) );
  sky130_fd_sc_hd__nand2_1 U9261 ( .A(n4175), .B(\cpuregs[27][22] ), .Y(n7649)
         );
  sky130_fd_sc_hd__o21ai_1 U9262 ( .A1(n4175), .A2(n4191), .B1(n7649), .Y(
        n3240) );
  sky130_fd_sc_hd__nand2_1 U9263 ( .A(n4195), .B(\cpuregs[17][22] ), .Y(n7650)
         );
  sky130_fd_sc_hd__o21ai_1 U9264 ( .A1(n4195), .A2(n4191), .B1(n7650), .Y(
        n3230) );
  sky130_fd_sc_hd__nand2_1 U9265 ( .A(n4179), .B(\cpuregs[4][22] ), .Y(n7651)
         );
  sky130_fd_sc_hd__o21ai_1 U9266 ( .A1(n4179), .A2(n4191), .B1(n7651), .Y(
        n3217) );
  sky130_fd_sc_hd__nand2_1 U9267 ( .A(n4201), .B(\cpuregs[3][22] ), .Y(n7652)
         );
  sky130_fd_sc_hd__o21ai_1 U9268 ( .A1(n4201), .A2(n4191), .B1(n7652), .Y(
        n3216) );
  sky130_fd_sc_hd__nand2_1 U9269 ( .A(n4186), .B(\cpuregs[13][22] ), .Y(n7653)
         );
  sky130_fd_sc_hd__o21ai_1 U9270 ( .A1(n4186), .A2(n4191), .B1(n7653), .Y(
        n3226) );
  sky130_fd_sc_hd__nand2_1 U9271 ( .A(n4197), .B(\cpuregs[16][22] ), .Y(n7654)
         );
  sky130_fd_sc_hd__o21ai_1 U9272 ( .A1(n4197), .A2(n4191), .B1(n7654), .Y(
        n3229) );
  sky130_fd_sc_hd__nand2_1 U9273 ( .A(n6396), .B(\cpuregs[1][22] ), .Y(n7655)
         );
  sky130_fd_sc_hd__o21ai_1 U9274 ( .A1(n6396), .A2(n4191), .B1(n7655), .Y(
        n3214) );
  sky130_fd_sc_hd__nand2_1 U9275 ( .A(n4194), .B(\cpuregs[19][22] ), .Y(n7656)
         );
  sky130_fd_sc_hd__o21ai_1 U9276 ( .A1(n4194), .A2(n4191), .B1(n7656), .Y(
        n3232) );
  sky130_fd_sc_hd__nand2_1 U9277 ( .A(n4176), .B(\cpuregs[29][22] ), .Y(n7657)
         );
  sky130_fd_sc_hd__o21ai_1 U9278 ( .A1(n4176), .A2(n4191), .B1(n7657), .Y(
        n3242) );
  sky130_fd_sc_hd__nand2_1 U9279 ( .A(n4185), .B(\cpuregs[11][22] ), .Y(n7658)
         );
  sky130_fd_sc_hd__o21ai_1 U9280 ( .A1(n4185), .A2(n4191), .B1(n7658), .Y(
        n3224) );
  sky130_fd_sc_hd__nand2_1 U9281 ( .A(n10058), .B(\cpuregs[20][22] ), .Y(n7659) );
  sky130_fd_sc_hd__o21ai_1 U9282 ( .A1(n10058), .A2(n4191), .B1(n7659), .Y(
        n3233) );
  sky130_fd_sc_hd__nand2_1 U9283 ( .A(n9621), .B(\cpuregs[26][22] ), .Y(n7660)
         );
  sky130_fd_sc_hd__o21ai_1 U9284 ( .A1(n9621), .A2(n4191), .B1(n7660), .Y(
        n3239) );
  sky130_fd_sc_hd__nand2_1 U9285 ( .A(n9772), .B(\cpuregs[6][22] ), .Y(n7661)
         );
  sky130_fd_sc_hd__o21ai_1 U9286 ( .A1(n9772), .A2(n4191), .B1(n7661), .Y(
        n3219) );
  sky130_fd_sc_hd__a22oi_1 U9287 ( .A1(decoded_imm[22]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[22]), .Y(n7662) );
  sky130_fd_sc_hd__nand2_1 U9288 ( .A(n8437), .B(n7662), .Y(n2850) );
  sky130_fd_sc_hd__a22oi_1 U9289 ( .A1(\cpuregs[29][22] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][22] ), .Y(n7666) );
  sky130_fd_sc_hd__a22oi_1 U9290 ( .A1(n8478), .A2(\cpuregs[13][22] ), .B1(
        \cpuregs[31][22] ), .B2(n8487), .Y(n7665) );
  sky130_fd_sc_hd__a22oi_1 U9291 ( .A1(n8498), .A2(\cpuregs[14][22] ), .B1(
        \cpuregs[12][22] ), .B2(n8491), .Y(n7664) );
  sky130_fd_sc_hd__a22oi_1 U9292 ( .A1(n8501), .A2(\cpuregs[15][22] ), .B1(
        \cpuregs[28][22] ), .B2(n8490), .Y(n7663) );
  sky130_fd_sc_hd__nand4_1 U9293 ( .A(n7666), .B(n7665), .C(n7664), .D(n7663), 
        .Y(n7682) );
  sky130_fd_sc_hd__a22oi_1 U9294 ( .A1(n8467), .A2(\cpuregs[26][22] ), .B1(
        n8481), .B2(\cpuregs[11][22] ), .Y(n7670) );
  sky130_fd_sc_hd__a22oi_1 U9295 ( .A1(n6059), .A2(\cpuregs[20][22] ), .B1(
        n8502), .B2(\cpuregs[6][22] ), .Y(n7669) );
  sky130_fd_sc_hd__a22oi_1 U9296 ( .A1(n6412), .A2(\cpuregs[19][22] ), .B1(
        n8488), .B2(\cpuregs[1][22] ), .Y(n7668) );
  sky130_fd_sc_hd__nand2_1 U9297 ( .A(n8500), .B(\cpuregs[30][22] ), .Y(n7667)
         );
  sky130_fd_sc_hd__nand4_1 U9298 ( .A(n7670), .B(n7669), .C(n7668), .D(n7667), 
        .Y(n7681) );
  sky130_fd_sc_hd__a22oi_1 U9299 ( .A1(n8497), .A2(\cpuregs[27][22] ), .B1(
        n8499), .B2(\cpuregs[3][22] ), .Y(n7674) );
  sky130_fd_sc_hd__a22oi_1 U9300 ( .A1(\cpuregs[4][22] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][22] ), .Y(n7673) );
  sky130_fd_sc_hd__a22oi_1 U9301 ( .A1(n8489), .A2(\cpuregs[17][22] ), .B1(
        n4233), .B2(\cpuregs[8][22] ), .Y(n7672) );
  sky130_fd_sc_hd__a22oi_1 U9302 ( .A1(n8482), .A2(\cpuregs[22][22] ), .B1(
        n8471), .B2(\cpuregs[5][22] ), .Y(n7671) );
  sky130_fd_sc_hd__nand4_1 U9303 ( .A(n7674), .B(n7673), .C(n7672), .D(n7671), 
        .Y(n7680) );
  sky130_fd_sc_hd__a22oi_1 U9304 ( .A1(n8466), .A2(\cpuregs[25][22] ), .B1(
        n8479), .B2(\cpuregs[2][22] ), .Y(n7678) );
  sky130_fd_sc_hd__a22oi_1 U9305 ( .A1(\cpuregs[21][22] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][22] ), .Y(n7677) );
  sky130_fd_sc_hd__a22oi_1 U9306 ( .A1(\cpuregs[7][22] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][22] ), .Y(n7676) );
  sky130_fd_sc_hd__a22oi_1 U9307 ( .A1(\cpuregs[23][22] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][22] ), .Y(n7675) );
  sky130_fd_sc_hd__nand4_1 U9308 ( .A(n7678), .B(n7677), .C(n7676), .D(n7675), 
        .Y(n7679) );
  sky130_fd_sc_hd__nor4_1 U9309 ( .A(n7682), .B(n7681), .C(n7680), .D(n7679), 
        .Y(n7684) );
  sky130_fd_sc_hd__a22oi_1 U9310 ( .A1(pcpi_rs2[22]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[22]), .Y(n7683) );
  sky130_fd_sc_hd__o21ai_1 U9311 ( .A1(n7684), .A2(n8514), .B1(n7683), .Y(
        n3936) );
  sky130_fd_sc_hd__a21oi_1 U9312 ( .A1(n9873), .A2(n7686), .B1(n9872), .Y(
        n7685) );
  sky130_fd_sc_hd__o21ai_1 U9313 ( .A1(n7686), .A2(n9877), .B1(n7685), .Y(
        n7696) );
  sky130_fd_sc_hd__nand2_1 U9314 ( .A(n7689), .B(n7688), .Y(n7694) );
  sky130_fd_sc_hd__o21ai_1 U9315 ( .A1(n7692), .A2(n7691), .B1(n7690), .Y(
        n7693) );
  sky130_fd_sc_hd__xnor2_1 U9316 ( .A(n7694), .B(n7693), .Y(n7695) );
  sky130_fd_sc_hd__a22o_1 U9317 ( .A1(n7697), .A2(n7696), .B1(n7695), .B2(
        is_lui_auipc_jal_jalr_addi_add_sub), .X(alu_out[22]) );
  sky130_fd_sc_hd__a22o_1 U9318 ( .A1(n10055), .A2(n7698), .B1(n9530), .B2(
        reg_pc[22]), .X(n3997) );
  sky130_fd_sc_hd__nand2_1 U9319 ( .A(n7701), .B(n7700), .Y(n7702) );
  sky130_fd_sc_hd__xor2_1 U9320 ( .A(n7703), .B(n7702), .X(n7704) );
  sky130_fd_sc_hd__nand2_1 U9321 ( .A(n7704), .B(n4639), .Y(n7711) );
  sky130_fd_sc_hd__a22oi_1 U9322 ( .A1(n9861), .A2(count_cycle[50]), .B1(n9860), .B2(count_cycle[18]), .Y(n7710) );
  sky130_fd_sc_hd__a22o_1 U9323 ( .A1(n9858), .A2(pcpi_rs1[18]), .B1(n7705), 
        .B2(mem_rdata_word[18]), .X(n7706) );
  sky130_fd_sc_hd__a211oi_1 U9324 ( .A1(n9857), .A2(count_instr[18]), .B1(
        n7707), .C1(n7706), .Y(n7709) );
  sky130_fd_sc_hd__nand2_1 U9325 ( .A(n9856), .B(count_instr[50]), .Y(n7708)
         );
  sky130_fd_sc_hd__nand4_1 U9326 ( .A(n7711), .B(n7710), .C(n7709), .D(n7708), 
        .Y(N1895) );
  sky130_fd_sc_hd__xor2_1 U9327 ( .A(n9774), .B(n8881), .X(n7712) );
  sky130_fd_sc_hd__a222oi_1 U9328 ( .A1(reg_out[18]), .A2(n9816), .B1(
        alu_out_q[18]), .B2(n9815), .C1(n7712), .C2(n9813), .Y(n7726) );
  sky130_fd_sc_hd__nand2_1 U9329 ( .A(n10057), .B(\cpuregs[24][18] ), .Y(n7713) );
  sky130_fd_sc_hd__o21ai_1 U9330 ( .A1(n10057), .A2(n4210), .B1(n7713), .Y(
        n3361) );
  sky130_fd_sc_hd__nand2_1 U9331 ( .A(n4177), .B(\cpuregs[30][18] ), .Y(n7714)
         );
  sky130_fd_sc_hd__o21ai_1 U9332 ( .A1(n4177), .A2(n4210), .B1(n7714), .Y(
        n3367) );
  sky130_fd_sc_hd__nand2_1 U9333 ( .A(n7452), .B(\cpuregs[9][18] ), .Y(n7715)
         );
  sky130_fd_sc_hd__o21ai_1 U9334 ( .A1(n7452), .A2(n4210), .B1(n7715), .Y(
        n3346) );
  sky130_fd_sc_hd__nand2_1 U9335 ( .A(n4173), .B(\cpuregs[23][18] ), .Y(n7716)
         );
  sky130_fd_sc_hd__o21ai_1 U9336 ( .A1(n4173), .A2(n4210), .B1(n7716), .Y(
        n3360) );
  sky130_fd_sc_hd__nand2_1 U9337 ( .A(n7069), .B(\cpuregs[15][18] ), .Y(n7717)
         );
  sky130_fd_sc_hd__o21ai_1 U9338 ( .A1(n7069), .A2(n4210), .B1(n7717), .Y(
        n3352) );
  sky130_fd_sc_hd__nand2_1 U9339 ( .A(n4219), .B(\cpuregs[28][18] ), .Y(n7718)
         );
  sky130_fd_sc_hd__o21ai_1 U9340 ( .A1(n4219), .A2(n4210), .B1(n7718), .Y(
        n3365) );
  sky130_fd_sc_hd__nand2_1 U9341 ( .A(n4199), .B(\cpuregs[7][18] ), .Y(n7719)
         );
  sky130_fd_sc_hd__o21ai_1 U9342 ( .A1(n4199), .A2(n4210), .B1(n7719), .Y(
        n3344) );
  sky130_fd_sc_hd__nand2_1 U9343 ( .A(n4226), .B(\cpuregs[12][18] ), .Y(n7720)
         );
  sky130_fd_sc_hd__o21ai_1 U9344 ( .A1(n4226), .A2(n4210), .B1(n7720), .Y(
        n3349) );
  sky130_fd_sc_hd__nand2_1 U9345 ( .A(n4184), .B(\cpuregs[10][18] ), .Y(n7721)
         );
  sky130_fd_sc_hd__o21ai_1 U9346 ( .A1(n4184), .A2(n4210), .B1(n7721), .Y(
        n3347) );
  sky130_fd_sc_hd__nand2_1 U9347 ( .A(n9820), .B(\cpuregs[18][18] ), .Y(n7722)
         );
  sky130_fd_sc_hd__o21ai_1 U9348 ( .A1(n9820), .A2(n4210), .B1(n7722), .Y(
        n3355) );
  sky130_fd_sc_hd__nand2_1 U9349 ( .A(n6897), .B(\cpuregs[14][18] ), .Y(n7723)
         );
  sky130_fd_sc_hd__o21ai_1 U9350 ( .A1(n6897), .A2(n4210), .B1(n7723), .Y(
        n3351) );
  sky130_fd_sc_hd__nand2_1 U9351 ( .A(n4174), .B(\cpuregs[21][18] ), .Y(n7724)
         );
  sky130_fd_sc_hd__o21ai_1 U9352 ( .A1(n4174), .A2(n4210), .B1(n7724), .Y(
        n3358) );
  sky130_fd_sc_hd__nand2_1 U9353 ( .A(n4192), .B(\cpuregs[25][18] ), .Y(n7725)
         );
  sky130_fd_sc_hd__o21ai_1 U9354 ( .A1(n4192), .A2(n4210), .B1(n7725), .Y(
        n3362) );
  sky130_fd_sc_hd__nand2_1 U9355 ( .A(n4178), .B(\cpuregs[2][18] ), .Y(n7727)
         );
  sky130_fd_sc_hd__o21ai_1 U9356 ( .A1(n4178), .A2(n4210), .B1(n7727), .Y(
        n3339) );
  sky130_fd_sc_hd__nand2_1 U9357 ( .A(n7247), .B(\cpuregs[31][18] ), .Y(n7728)
         );
  sky130_fd_sc_hd__o21ai_1 U9358 ( .A1(n7247), .A2(n4210), .B1(n7728), .Y(
        n3368) );
  sky130_fd_sc_hd__nand2_1 U9359 ( .A(n4180), .B(\cpuregs[5][18] ), .Y(n7729)
         );
  sky130_fd_sc_hd__o21ai_1 U9360 ( .A1(n4180), .A2(n4210), .B1(n7729), .Y(
        n3342) );
  sky130_fd_sc_hd__nand2_1 U9361 ( .A(n4183), .B(\cpuregs[8][18] ), .Y(n7730)
         );
  sky130_fd_sc_hd__o21ai_1 U9362 ( .A1(n4183), .A2(n4210), .B1(n7730), .Y(
        n3345) );
  sky130_fd_sc_hd__nand2_1 U9363 ( .A(n7084), .B(\cpuregs[22][18] ), .Y(n7731)
         );
  sky130_fd_sc_hd__o21ai_1 U9364 ( .A1(n7084), .A2(n4210), .B1(n7731), .Y(
        n3359) );
  sky130_fd_sc_hd__nand2_1 U9365 ( .A(n4175), .B(\cpuregs[27][18] ), .Y(n7732)
         );
  sky130_fd_sc_hd__o21ai_1 U9366 ( .A1(n4175), .A2(n4210), .B1(n7732), .Y(
        n3364) );
  sky130_fd_sc_hd__nand2_1 U9367 ( .A(n4195), .B(\cpuregs[17][18] ), .Y(n7733)
         );
  sky130_fd_sc_hd__o21ai_1 U9368 ( .A1(n4195), .A2(n4210), .B1(n7733), .Y(
        n3354) );
  sky130_fd_sc_hd__nand2_1 U9369 ( .A(n4179), .B(\cpuregs[4][18] ), .Y(n7734)
         );
  sky130_fd_sc_hd__o21ai_1 U9370 ( .A1(n4179), .A2(n4210), .B1(n7734), .Y(
        n3341) );
  sky130_fd_sc_hd__nand2_1 U9371 ( .A(n4201), .B(\cpuregs[3][18] ), .Y(n7735)
         );
  sky130_fd_sc_hd__o21ai_1 U9372 ( .A1(n4201), .A2(n4210), .B1(n7735), .Y(
        n3340) );
  sky130_fd_sc_hd__nand2_1 U9373 ( .A(n4186), .B(\cpuregs[13][18] ), .Y(n7736)
         );
  sky130_fd_sc_hd__o21ai_1 U9374 ( .A1(n4186), .A2(n4210), .B1(n7736), .Y(
        n3350) );
  sky130_fd_sc_hd__nand2_1 U9375 ( .A(n4197), .B(\cpuregs[16][18] ), .Y(n7737)
         );
  sky130_fd_sc_hd__o21ai_1 U9376 ( .A1(n4197), .A2(n4210), .B1(n7737), .Y(
        n3353) );
  sky130_fd_sc_hd__nand2_1 U9377 ( .A(n6396), .B(\cpuregs[1][18] ), .Y(n7738)
         );
  sky130_fd_sc_hd__o21ai_1 U9378 ( .A1(n6396), .A2(n4210), .B1(n7738), .Y(
        n3338) );
  sky130_fd_sc_hd__nand2_1 U9379 ( .A(n4194), .B(\cpuregs[19][18] ), .Y(n7739)
         );
  sky130_fd_sc_hd__o21ai_1 U9380 ( .A1(n4194), .A2(n4210), .B1(n7739), .Y(
        n3356) );
  sky130_fd_sc_hd__nand2_1 U9381 ( .A(n4176), .B(\cpuregs[29][18] ), .Y(n7740)
         );
  sky130_fd_sc_hd__o21ai_1 U9382 ( .A1(n4176), .A2(n4210), .B1(n7740), .Y(
        n3366) );
  sky130_fd_sc_hd__nand2_1 U9383 ( .A(n4185), .B(\cpuregs[11][18] ), .Y(n7741)
         );
  sky130_fd_sc_hd__o21ai_1 U9384 ( .A1(n4185), .A2(n4210), .B1(n7741), .Y(
        n3348) );
  sky130_fd_sc_hd__nand2_1 U9385 ( .A(n10058), .B(\cpuregs[20][18] ), .Y(n7742) );
  sky130_fd_sc_hd__o21ai_1 U9386 ( .A1(n10058), .A2(n4210), .B1(n7742), .Y(
        n3357) );
  sky130_fd_sc_hd__nand2_1 U9387 ( .A(n9621), .B(\cpuregs[26][18] ), .Y(n7743)
         );
  sky130_fd_sc_hd__o21ai_1 U9388 ( .A1(n9621), .A2(n4210), .B1(n7743), .Y(
        n3363) );
  sky130_fd_sc_hd__nand2_1 U9389 ( .A(n9772), .B(\cpuregs[6][18] ), .Y(n7744)
         );
  sky130_fd_sc_hd__o21ai_1 U9390 ( .A1(n9772), .A2(n4210), .B1(n7744), .Y(
        n3343) );
  sky130_fd_sc_hd__a22oi_1 U9391 ( .A1(decoded_imm[18]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[18]), .Y(n7746) );
  sky130_fd_sc_hd__nand2_1 U9392 ( .A(n5989), .B(mem_rdata_q[18]), .Y(n7745)
         );
  sky130_fd_sc_hd__nand3_1 U9393 ( .A(n7930), .B(n7746), .C(n7745), .Y(n2854)
         );
  sky130_fd_sc_hd__a22oi_1 U9394 ( .A1(n6137), .A2(\cpuregs[29][18] ), .B1(
        n8503), .B2(\cpuregs[24][18] ), .Y(n7750) );
  sky130_fd_sc_hd__a22oi_1 U9395 ( .A1(n8478), .A2(\cpuregs[13][18] ), .B1(
        n8487), .B2(\cpuregs[31][18] ), .Y(n7749) );
  sky130_fd_sc_hd__a22oi_1 U9396 ( .A1(n8498), .A2(\cpuregs[14][18] ), .B1(
        n8491), .B2(\cpuregs[12][18] ), .Y(n7748) );
  sky130_fd_sc_hd__a22oi_1 U9397 ( .A1(n8501), .A2(\cpuregs[15][18] ), .B1(
        n8490), .B2(\cpuregs[28][18] ), .Y(n7747) );
  sky130_fd_sc_hd__nand4_1 U9398 ( .A(n7750), .B(n7749), .C(n7748), .D(n7747), 
        .Y(n7766) );
  sky130_fd_sc_hd__a22oi_1 U9399 ( .A1(n8467), .A2(\cpuregs[26][18] ), .B1(
        n8481), .B2(\cpuregs[11][18] ), .Y(n7754) );
  sky130_fd_sc_hd__a22oi_1 U9400 ( .A1(n6059), .A2(\cpuregs[20][18] ), .B1(
        n8502), .B2(\cpuregs[6][18] ), .Y(n7753) );
  sky130_fd_sc_hd__a22oi_1 U9401 ( .A1(n6412), .A2(\cpuregs[19][18] ), .B1(
        n8488), .B2(\cpuregs[1][18] ), .Y(n7752) );
  sky130_fd_sc_hd__nand2_1 U9402 ( .A(n8500), .B(\cpuregs[30][18] ), .Y(n7751)
         );
  sky130_fd_sc_hd__nand4_1 U9403 ( .A(n7754), .B(n7753), .C(n7752), .D(n7751), 
        .Y(n7765) );
  sky130_fd_sc_hd__a22oi_1 U9404 ( .A1(n8497), .A2(\cpuregs[27][18] ), .B1(
        n8499), .B2(\cpuregs[3][18] ), .Y(n7758) );
  sky130_fd_sc_hd__a22oi_1 U9405 ( .A1(n8492), .A2(\cpuregs[4][18] ), .B1(
        n8465), .B2(\cpuregs[16][18] ), .Y(n7757) );
  sky130_fd_sc_hd__a22oi_1 U9406 ( .A1(n8489), .A2(\cpuregs[17][18] ), .B1(
        n4233), .B2(\cpuregs[8][18] ), .Y(n7756) );
  sky130_fd_sc_hd__a22oi_1 U9407 ( .A1(n8482), .A2(\cpuregs[22][18] ), .B1(
        n8471), .B2(\cpuregs[5][18] ), .Y(n7755) );
  sky130_fd_sc_hd__nand4_1 U9408 ( .A(n7758), .B(n7757), .C(n7756), .D(n7755), 
        .Y(n7764) );
  sky130_fd_sc_hd__a22oi_1 U9409 ( .A1(n8466), .A2(\cpuregs[25][18] ), .B1(
        n8479), .B2(\cpuregs[2][18] ), .Y(n7762) );
  sky130_fd_sc_hd__a22oi_1 U9410 ( .A1(n8480), .A2(\cpuregs[21][18] ), .B1(
        n8470), .B2(\cpuregs[10][18] ), .Y(n7761) );
  sky130_fd_sc_hd__a22oi_1 U9411 ( .A1(n8477), .A2(\cpuregs[7][18] ), .B1(
        n8472), .B2(\cpuregs[18][18] ), .Y(n7760) );
  sky130_fd_sc_hd__a22oi_1 U9412 ( .A1(n8464), .A2(\cpuregs[23][18] ), .B1(
        n8036), .B2(\cpuregs[9][18] ), .Y(n7759) );
  sky130_fd_sc_hd__nand4_1 U9413 ( .A(n7762), .B(n7761), .C(n7760), .D(n7759), 
        .Y(n7763) );
  sky130_fd_sc_hd__nor4_1 U9414 ( .A(n7766), .B(n7765), .C(n7764), .D(n7763), 
        .Y(n7768) );
  sky130_fd_sc_hd__a22oi_1 U9415 ( .A1(pcpi_rs2[18]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[18]), .Y(n7767) );
  sky130_fd_sc_hd__o21ai_1 U9416 ( .A1(n7768), .A2(n8514), .B1(n7767), .Y(
        n3940) );
  sky130_fd_sc_hd__nand2_1 U9417 ( .A(n7771), .B(n7770), .Y(n7776) );
  sky130_fd_sc_hd__o21ai_1 U9418 ( .A1(n7774), .A2(n7773), .B1(n7772), .Y(
        n7775) );
  sky130_fd_sc_hd__xnor2_1 U9419 ( .A(n7776), .B(n7775), .Y(n7777) );
  sky130_fd_sc_hd__nand2_1 U9420 ( .A(n7777), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n7782) );
  sky130_fd_sc_hd__nor2_1 U9421 ( .A(n8683), .B(n7778), .Y(n7779) );
  sky130_fd_sc_hd__a31oi_1 U9422 ( .A1(n9382), .A2(pcpi_rs1[18]), .A3(
        pcpi_rs2[18]), .B1(n7779), .Y(n7781) );
  sky130_fd_sc_hd__o21ai_1 U9423 ( .A1(pcpi_rs1[18]), .A2(pcpi_rs2[18]), .B1(
        n9872), .Y(n7780) );
  sky130_fd_sc_hd__nand3_1 U9424 ( .A(n7782), .B(n7781), .C(n7780), .Y(
        alu_out[18]) );
  sky130_fd_sc_hd__o22ai_1 U9425 ( .A1(n10029), .A2(n8881), .B1(n7784), .B2(
        n9387), .Y(n4001) );
  sky130_fd_sc_hd__clkinv_1 U9426 ( .A(mem_rdata[14]), .Y(n8187) );
  sky130_fd_sc_hd__o22ai_1 U9427 ( .A1(n8187), .A2(n8122), .B1(n10026), .B2(
        n8121), .Y(n4165) );
  sky130_fd_sc_hd__nand2_1 U9428 ( .A(n7786), .B(n7785), .Y(n7788) );
  sky130_fd_sc_hd__xnor2_1 U9429 ( .A(n7788), .B(n7787), .Y(n7789) );
  sky130_fd_sc_hd__nand2_1 U9430 ( .A(n7789), .B(n4639), .Y(n7795) );
  sky130_fd_sc_hd__a22oi_1 U9431 ( .A1(n8129), .A2(mem_rdata_word[14]), .B1(
        n9856), .B2(count_instr[46]), .Y(n7794) );
  sky130_fd_sc_hd__nand2_1 U9432 ( .A(n9861), .B(count_cycle[46]), .Y(n7790)
         );
  sky130_fd_sc_hd__o211ai_1 U9433 ( .A1(n9437), .A2(n8889), .B1(n8131), .C1(
        n7790), .Y(n7791) );
  sky130_fd_sc_hd__a21oi_1 U9434 ( .A1(n9860), .A2(count_cycle[14]), .B1(n7791), .Y(n7793) );
  sky130_fd_sc_hd__nand2_1 U9435 ( .A(n9857), .B(count_instr[14]), .Y(n7792)
         );
  sky130_fd_sc_hd__nand4_1 U9436 ( .A(n7795), .B(n7794), .C(n7793), .D(n7792), 
        .Y(N1891) );
  sky130_fd_sc_hd__nand2_1 U9437 ( .A(n7798), .B(n7797), .Y(n7807) );
  sky130_fd_sc_hd__nand2_1 U9438 ( .A(n7799), .B(n7802), .Y(n7805) );
  sky130_fd_sc_hd__a21oi_1 U9439 ( .A1(n7803), .A2(n7802), .B1(n7801), .Y(
        n7804) );
  sky130_fd_sc_hd__o21ai_1 U9440 ( .A1(n7805), .A2(n8073), .B1(n7804), .Y(
        n7806) );
  sky130_fd_sc_hd__xnor2_1 U9441 ( .A(n7807), .B(n7806), .Y(n7808) );
  sky130_fd_sc_hd__a222oi_1 U9442 ( .A1(n9530), .A2(reg_next_pc[14]), .B1(
        n9370), .B2(n7869), .C1(n7808), .C2(n5794), .Y(n7809) );
  sky130_fd_sc_hd__xnor2_1 U9443 ( .A(n7811), .B(n7810), .Y(n7812) );
  sky130_fd_sc_hd__a222oi_1 U9444 ( .A1(alu_out_q[14]), .A2(n9815), .B1(n9816), 
        .B2(reg_out[14]), .C1(n7812), .C2(n9813), .Y(n7826) );
  sky130_fd_sc_hd__nand2_1 U9445 ( .A(n10057), .B(\cpuregs[24][14] ), .Y(n7813) );
  sky130_fd_sc_hd__o21ai_1 U9446 ( .A1(n10057), .A2(n4207), .B1(n7813), .Y(
        n3485) );
  sky130_fd_sc_hd__nand2_1 U9447 ( .A(n4177), .B(\cpuregs[30][14] ), .Y(n7814)
         );
  sky130_fd_sc_hd__o21ai_1 U9448 ( .A1(n4177), .A2(n4207), .B1(n7814), .Y(
        n3491) );
  sky130_fd_sc_hd__nand2_1 U9449 ( .A(n7452), .B(\cpuregs[9][14] ), .Y(n7815)
         );
  sky130_fd_sc_hd__o21ai_1 U9450 ( .A1(n7452), .A2(n4207), .B1(n7815), .Y(
        n3470) );
  sky130_fd_sc_hd__nand2_1 U9451 ( .A(n4173), .B(\cpuregs[23][14] ), .Y(n7816)
         );
  sky130_fd_sc_hd__o21ai_1 U9452 ( .A1(n4173), .A2(n4207), .B1(n7816), .Y(
        n3484) );
  sky130_fd_sc_hd__nand2_1 U9453 ( .A(n7069), .B(\cpuregs[15][14] ), .Y(n7817)
         );
  sky130_fd_sc_hd__o21ai_1 U9454 ( .A1(n7069), .A2(n4207), .B1(n7817), .Y(
        n3476) );
  sky130_fd_sc_hd__nand2_1 U9455 ( .A(n4219), .B(\cpuregs[28][14] ), .Y(n7818)
         );
  sky130_fd_sc_hd__o21ai_1 U9456 ( .A1(n4219), .A2(n4207), .B1(n7818), .Y(
        n3489) );
  sky130_fd_sc_hd__nand2_1 U9457 ( .A(n4199), .B(\cpuregs[7][14] ), .Y(n7819)
         );
  sky130_fd_sc_hd__o21ai_1 U9458 ( .A1(n4199), .A2(n4207), .B1(n7819), .Y(
        n3468) );
  sky130_fd_sc_hd__nand2_1 U9459 ( .A(n4226), .B(\cpuregs[12][14] ), .Y(n7820)
         );
  sky130_fd_sc_hd__o21ai_1 U9460 ( .A1(n4226), .A2(n4207), .B1(n7820), .Y(
        n3473) );
  sky130_fd_sc_hd__nand2_1 U9461 ( .A(n4184), .B(\cpuregs[10][14] ), .Y(n7821)
         );
  sky130_fd_sc_hd__o21ai_1 U9462 ( .A1(n4184), .A2(n4207), .B1(n7821), .Y(
        n3471) );
  sky130_fd_sc_hd__nand2_1 U9463 ( .A(n9820), .B(\cpuregs[18][14] ), .Y(n7822)
         );
  sky130_fd_sc_hd__o21ai_1 U9464 ( .A1(n9820), .A2(n4207), .B1(n7822), .Y(
        n3479) );
  sky130_fd_sc_hd__nand2_1 U9465 ( .A(n6897), .B(\cpuregs[14][14] ), .Y(n7823)
         );
  sky130_fd_sc_hd__o21ai_1 U9466 ( .A1(n6897), .A2(n4207), .B1(n7823), .Y(
        n3475) );
  sky130_fd_sc_hd__nand2_1 U9467 ( .A(n4174), .B(\cpuregs[21][14] ), .Y(n7824)
         );
  sky130_fd_sc_hd__o21ai_1 U9468 ( .A1(n4174), .A2(n4207), .B1(n7824), .Y(
        n3482) );
  sky130_fd_sc_hd__nand2_1 U9469 ( .A(n4192), .B(\cpuregs[25][14] ), .Y(n7825)
         );
  sky130_fd_sc_hd__o21ai_1 U9470 ( .A1(n4192), .A2(n4207), .B1(n7825), .Y(
        n3486) );
  sky130_fd_sc_hd__nand2_1 U9471 ( .A(n4178), .B(\cpuregs[2][14] ), .Y(n7827)
         );
  sky130_fd_sc_hd__o21ai_1 U9472 ( .A1(n4178), .A2(n4207), .B1(n7827), .Y(
        n3463) );
  sky130_fd_sc_hd__nand2_1 U9473 ( .A(n7247), .B(\cpuregs[31][14] ), .Y(n7828)
         );
  sky130_fd_sc_hd__o21ai_1 U9474 ( .A1(n7247), .A2(n4207), .B1(n7828), .Y(
        n3492) );
  sky130_fd_sc_hd__nand2_1 U9475 ( .A(n4180), .B(\cpuregs[5][14] ), .Y(n7829)
         );
  sky130_fd_sc_hd__o21ai_1 U9476 ( .A1(n4180), .A2(n4207), .B1(n7829), .Y(
        n3466) );
  sky130_fd_sc_hd__nand2_1 U9477 ( .A(n4183), .B(\cpuregs[8][14] ), .Y(n7830)
         );
  sky130_fd_sc_hd__o21ai_1 U9478 ( .A1(n4183), .A2(n4207), .B1(n7830), .Y(
        n3469) );
  sky130_fd_sc_hd__nand2_1 U9479 ( .A(n7084), .B(\cpuregs[22][14] ), .Y(n7831)
         );
  sky130_fd_sc_hd__o21ai_1 U9480 ( .A1(n7084), .A2(n4207), .B1(n7831), .Y(
        n3483) );
  sky130_fd_sc_hd__nand2_1 U9481 ( .A(n4175), .B(\cpuregs[27][14] ), .Y(n7832)
         );
  sky130_fd_sc_hd__o21ai_1 U9482 ( .A1(n4175), .A2(n4207), .B1(n7832), .Y(
        n3488) );
  sky130_fd_sc_hd__nand2_1 U9483 ( .A(n4195), .B(\cpuregs[17][14] ), .Y(n7833)
         );
  sky130_fd_sc_hd__o21ai_1 U9484 ( .A1(n4195), .A2(n4207), .B1(n7833), .Y(
        n3478) );
  sky130_fd_sc_hd__nand2_1 U9485 ( .A(n4179), .B(\cpuregs[4][14] ), .Y(n7834)
         );
  sky130_fd_sc_hd__o21ai_1 U9486 ( .A1(n4179), .A2(n4207), .B1(n7834), .Y(
        n3465) );
  sky130_fd_sc_hd__nand2_1 U9487 ( .A(n4201), .B(\cpuregs[3][14] ), .Y(n7835)
         );
  sky130_fd_sc_hd__o21ai_1 U9488 ( .A1(n4201), .A2(n4207), .B1(n7835), .Y(
        n3464) );
  sky130_fd_sc_hd__nand2_1 U9489 ( .A(n4186), .B(\cpuregs[13][14] ), .Y(n7836)
         );
  sky130_fd_sc_hd__o21ai_1 U9490 ( .A1(n4186), .A2(n4207), .B1(n7836), .Y(
        n3474) );
  sky130_fd_sc_hd__nand2_1 U9491 ( .A(n4197), .B(\cpuregs[16][14] ), .Y(n7837)
         );
  sky130_fd_sc_hd__o21ai_1 U9492 ( .A1(n4197), .A2(n4207), .B1(n7837), .Y(
        n3477) );
  sky130_fd_sc_hd__nand2_1 U9493 ( .A(n6396), .B(\cpuregs[1][14] ), .Y(n7838)
         );
  sky130_fd_sc_hd__o21ai_1 U9494 ( .A1(n6396), .A2(n4207), .B1(n7838), .Y(
        n3462) );
  sky130_fd_sc_hd__nand2_1 U9495 ( .A(n4194), .B(\cpuregs[19][14] ), .Y(n7839)
         );
  sky130_fd_sc_hd__o21ai_1 U9496 ( .A1(n4194), .A2(n4207), .B1(n7839), .Y(
        n3480) );
  sky130_fd_sc_hd__nand2_1 U9497 ( .A(n4176), .B(\cpuregs[29][14] ), .Y(n7840)
         );
  sky130_fd_sc_hd__o21ai_1 U9498 ( .A1(n4176), .A2(n4207), .B1(n7840), .Y(
        n3490) );
  sky130_fd_sc_hd__nand2_1 U9499 ( .A(n4185), .B(\cpuregs[11][14] ), .Y(n7841)
         );
  sky130_fd_sc_hd__o21ai_1 U9500 ( .A1(n4185), .A2(n4207), .B1(n7841), .Y(
        n3472) );
  sky130_fd_sc_hd__nand2_1 U9501 ( .A(n10058), .B(\cpuregs[20][14] ), .Y(n7842) );
  sky130_fd_sc_hd__o21ai_1 U9502 ( .A1(n10058), .A2(n4207), .B1(n7842), .Y(
        n3481) );
  sky130_fd_sc_hd__nand2_1 U9503 ( .A(n9621), .B(\cpuregs[26][14] ), .Y(n7843)
         );
  sky130_fd_sc_hd__o21ai_1 U9504 ( .A1(n9621), .A2(n4207), .B1(n7843), .Y(
        n3487) );
  sky130_fd_sc_hd__nand2_1 U9505 ( .A(n9209), .B(\cpuregs[6][14] ), .Y(n7844)
         );
  sky130_fd_sc_hd__o21ai_1 U9506 ( .A1(n9772), .A2(n4207), .B1(n7844), .Y(
        n3467) );
  sky130_fd_sc_hd__a222oi_1 U9507 ( .A1(n10086), .A2(decoded_imm_j[14]), .B1(
        n10087), .B2(mem_rdata_q[14]), .C1(mem_rdata[14]), .C2(n7928), .Y(
        n7845) );
  sky130_fd_sc_hd__a22oi_1 U9508 ( .A1(decoded_imm[14]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[14]), .Y(n7846) );
  sky130_fd_sc_hd__o211ai_1 U9509 ( .A1(n10096), .A2(n7932), .B1(n7846), .C1(
        n7930), .Y(n2858) );
  sky130_fd_sc_hd__a22oi_1 U9510 ( .A1(\cpuregs[29][14] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][14] ), .Y(n7850) );
  sky130_fd_sc_hd__a22oi_1 U9511 ( .A1(n8478), .A2(\cpuregs[13][14] ), .B1(
        \cpuregs[31][14] ), .B2(n8487), .Y(n7849) );
  sky130_fd_sc_hd__a22oi_1 U9512 ( .A1(n8498), .A2(\cpuregs[14][14] ), .B1(
        \cpuregs[12][14] ), .B2(n8491), .Y(n7848) );
  sky130_fd_sc_hd__a22oi_1 U9513 ( .A1(n8501), .A2(\cpuregs[15][14] ), .B1(
        \cpuregs[28][14] ), .B2(n8490), .Y(n7847) );
  sky130_fd_sc_hd__nand4_1 U9514 ( .A(n7850), .B(n7849), .C(n7848), .D(n7847), 
        .Y(n7866) );
  sky130_fd_sc_hd__a22oi_1 U9515 ( .A1(n8467), .A2(\cpuregs[26][14] ), .B1(
        n8481), .B2(\cpuregs[11][14] ), .Y(n7854) );
  sky130_fd_sc_hd__a22oi_1 U9516 ( .A1(n6059), .A2(\cpuregs[20][14] ), .B1(
        n8502), .B2(\cpuregs[6][14] ), .Y(n7853) );
  sky130_fd_sc_hd__a22oi_1 U9517 ( .A1(n6412), .A2(\cpuregs[19][14] ), .B1(
        n8488), .B2(\cpuregs[1][14] ), .Y(n7852) );
  sky130_fd_sc_hd__nand2_1 U9518 ( .A(n8500), .B(\cpuregs[30][14] ), .Y(n7851)
         );
  sky130_fd_sc_hd__nand4_1 U9519 ( .A(n7854), .B(n7853), .C(n7852), .D(n7851), 
        .Y(n7865) );
  sky130_fd_sc_hd__a22oi_1 U9520 ( .A1(n8497), .A2(\cpuregs[27][14] ), .B1(
        n8499), .B2(\cpuregs[3][14] ), .Y(n7858) );
  sky130_fd_sc_hd__a22oi_1 U9521 ( .A1(\cpuregs[4][14] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][14] ), .Y(n7857) );
  sky130_fd_sc_hd__a22oi_1 U9522 ( .A1(n8489), .A2(\cpuregs[17][14] ), .B1(
        n4233), .B2(\cpuregs[8][14] ), .Y(n7856) );
  sky130_fd_sc_hd__a22oi_1 U9523 ( .A1(n8482), .A2(\cpuregs[22][14] ), .B1(
        n8471), .B2(\cpuregs[5][14] ), .Y(n7855) );
  sky130_fd_sc_hd__nand4_1 U9524 ( .A(n7858), .B(n7857), .C(n7856), .D(n7855), 
        .Y(n7864) );
  sky130_fd_sc_hd__a22oi_1 U9525 ( .A1(n8466), .A2(\cpuregs[25][14] ), .B1(
        n8479), .B2(\cpuregs[2][14] ), .Y(n7862) );
  sky130_fd_sc_hd__a22oi_1 U9526 ( .A1(\cpuregs[21][14] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][14] ), .Y(n7861) );
  sky130_fd_sc_hd__a22oi_1 U9527 ( .A1(\cpuregs[7][14] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][14] ), .Y(n7860) );
  sky130_fd_sc_hd__a22oi_1 U9528 ( .A1(\cpuregs[23][14] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][14] ), .Y(n7859) );
  sky130_fd_sc_hd__nand4_1 U9529 ( .A(n7862), .B(n7861), .C(n7860), .D(n7859), 
        .Y(n7863) );
  sky130_fd_sc_hd__nor4_1 U9530 ( .A(n7866), .B(n7865), .C(n7864), .D(n7863), 
        .Y(n7868) );
  sky130_fd_sc_hd__a22oi_1 U9531 ( .A1(pcpi_rs2[14]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[14]), .Y(n7867) );
  sky130_fd_sc_hd__o21ai_1 U9532 ( .A1(n7868), .A2(n8514), .B1(n7867), .Y(
        n3944) );
  sky130_fd_sc_hd__a22o_1 U9533 ( .A1(n10055), .A2(n7869), .B1(n9530), .B2(
        reg_pc[14]), .X(n4005) );
  sky130_fd_sc_hd__clkinv_1 U9534 ( .A(mem_rdata[12]), .Y(n8299) );
  sky130_fd_sc_hd__o22ai_1 U9535 ( .A1(n8299), .A2(n8122), .B1(n10024), .B2(
        n8121), .Y(n4163) );
  sky130_fd_sc_hd__nand2_1 U9536 ( .A(n7871), .B(n7870), .Y(n7872) );
  sky130_fd_sc_hd__xor2_1 U9537 ( .A(n7873), .B(n7872), .X(n7874) );
  sky130_fd_sc_hd__nand2_1 U9538 ( .A(n7874), .B(n4639), .Y(n7880) );
  sky130_fd_sc_hd__a22oi_1 U9539 ( .A1(n8129), .A2(mem_rdata_word[12]), .B1(
        n9856), .B2(count_instr[44]), .Y(n7879) );
  sky130_fd_sc_hd__nand2_1 U9540 ( .A(n9861), .B(count_cycle[44]), .Y(n7875)
         );
  sky130_fd_sc_hd__o211ai_1 U9541 ( .A1(n9437), .A2(n8778), .B1(n8131), .C1(
        n7875), .Y(n7876) );
  sky130_fd_sc_hd__a21oi_1 U9542 ( .A1(n9860), .A2(count_cycle[12]), .B1(n7876), .Y(n7878) );
  sky130_fd_sc_hd__nand2_1 U9543 ( .A(n9857), .B(count_instr[12]), .Y(n7877)
         );
  sky130_fd_sc_hd__nand4_1 U9544 ( .A(n7880), .B(n7879), .C(n7878), .D(n7877), 
        .Y(N1889) );
  sky130_fd_sc_hd__nand2_1 U9545 ( .A(n7884), .B(n7883), .Y(n7890) );
  sky130_fd_sc_hd__nand2_1 U9546 ( .A(n7977), .B(n7976), .Y(n7888) );
  sky130_fd_sc_hd__a21oi_1 U9547 ( .A1(n7978), .A2(n7976), .B1(n7886), .Y(
        n7887) );
  sky130_fd_sc_hd__o21ai_1 U9548 ( .A1(n7888), .A2(n8073), .B1(n7887), .Y(
        n7889) );
  sky130_fd_sc_hd__xnor2_1 U9549 ( .A(n7890), .B(n7889), .Y(n7891) );
  sky130_fd_sc_hd__a222oi_1 U9550 ( .A1(n7881), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[12]), .C1(n5794), .C2(n7891), .Y(n7892) );
  sky130_fd_sc_hd__xor2_1 U9551 ( .A(n7894), .B(n8779), .X(n7895) );
  sky130_fd_sc_hd__a222oi_1 U9552 ( .A1(reg_out[12]), .A2(n9816), .B1(
        alu_out_q[12]), .B2(n9815), .C1(n7895), .C2(n9813), .Y(n7909) );
  sky130_fd_sc_hd__nand2_1 U9553 ( .A(n10057), .B(\cpuregs[24][12] ), .Y(n7896) );
  sky130_fd_sc_hd__o21ai_1 U9554 ( .A1(n10057), .A2(n4212), .B1(n7896), .Y(
        n3547) );
  sky130_fd_sc_hd__nand2_1 U9555 ( .A(n4177), .B(\cpuregs[30][12] ), .Y(n7897)
         );
  sky130_fd_sc_hd__o21ai_1 U9556 ( .A1(n4177), .A2(n4212), .B1(n7897), .Y(
        n3553) );
  sky130_fd_sc_hd__nand2_1 U9557 ( .A(n7452), .B(\cpuregs[9][12] ), .Y(n7898)
         );
  sky130_fd_sc_hd__o21ai_1 U9558 ( .A1(n7452), .A2(n4212), .B1(n7898), .Y(
        n3532) );
  sky130_fd_sc_hd__nand2_1 U9559 ( .A(n4173), .B(\cpuregs[23][12] ), .Y(n7899)
         );
  sky130_fd_sc_hd__o21ai_1 U9560 ( .A1(n4173), .A2(n4212), .B1(n7899), .Y(
        n3546) );
  sky130_fd_sc_hd__nand2_1 U9561 ( .A(n7069), .B(\cpuregs[15][12] ), .Y(n7900)
         );
  sky130_fd_sc_hd__o21ai_1 U9562 ( .A1(n7069), .A2(n4212), .B1(n7900), .Y(
        n3538) );
  sky130_fd_sc_hd__nand2_1 U9563 ( .A(n4219), .B(\cpuregs[28][12] ), .Y(n7901)
         );
  sky130_fd_sc_hd__o21ai_1 U9564 ( .A1(n4219), .A2(n4212), .B1(n7901), .Y(
        n3551) );
  sky130_fd_sc_hd__nand2_1 U9565 ( .A(n4199), .B(\cpuregs[7][12] ), .Y(n7902)
         );
  sky130_fd_sc_hd__o21ai_1 U9566 ( .A1(n4199), .A2(n4212), .B1(n7902), .Y(
        n3530) );
  sky130_fd_sc_hd__nand2_1 U9567 ( .A(n4226), .B(\cpuregs[12][12] ), .Y(n7903)
         );
  sky130_fd_sc_hd__o21ai_1 U9568 ( .A1(n4226), .A2(n4212), .B1(n7903), .Y(
        n3535) );
  sky130_fd_sc_hd__nand2_1 U9569 ( .A(n4184), .B(\cpuregs[10][12] ), .Y(n7904)
         );
  sky130_fd_sc_hd__o21ai_1 U9570 ( .A1(n4184), .A2(n4212), .B1(n7904), .Y(
        n3533) );
  sky130_fd_sc_hd__nand2_1 U9571 ( .A(n9820), .B(\cpuregs[18][12] ), .Y(n7905)
         );
  sky130_fd_sc_hd__o21ai_1 U9572 ( .A1(n9820), .A2(n4212), .B1(n7905), .Y(
        n3541) );
  sky130_fd_sc_hd__nand2_1 U9573 ( .A(n6897), .B(\cpuregs[14][12] ), .Y(n7906)
         );
  sky130_fd_sc_hd__o21ai_1 U9574 ( .A1(n6897), .A2(n4212), .B1(n7906), .Y(
        n3537) );
  sky130_fd_sc_hd__nand2_1 U9575 ( .A(n4174), .B(\cpuregs[21][12] ), .Y(n7907)
         );
  sky130_fd_sc_hd__o21ai_1 U9576 ( .A1(n4174), .A2(n4212), .B1(n7907), .Y(
        n3544) );
  sky130_fd_sc_hd__nand2_1 U9577 ( .A(n4192), .B(\cpuregs[25][12] ), .Y(n7908)
         );
  sky130_fd_sc_hd__o21ai_1 U9578 ( .A1(n4192), .A2(n4212), .B1(n7908), .Y(
        n3548) );
  sky130_fd_sc_hd__nand2_1 U9579 ( .A(n4178), .B(\cpuregs[2][12] ), .Y(n7910)
         );
  sky130_fd_sc_hd__o21ai_1 U9580 ( .A1(n4178), .A2(n4212), .B1(n7910), .Y(
        n3525) );
  sky130_fd_sc_hd__nand2_1 U9581 ( .A(n7247), .B(\cpuregs[31][12] ), .Y(n7911)
         );
  sky130_fd_sc_hd__o21ai_1 U9582 ( .A1(n7247), .A2(n4212), .B1(n7911), .Y(
        n3554) );
  sky130_fd_sc_hd__nand2_1 U9583 ( .A(n4180), .B(\cpuregs[5][12] ), .Y(n7912)
         );
  sky130_fd_sc_hd__o21ai_1 U9584 ( .A1(n4180), .A2(n4212), .B1(n7912), .Y(
        n3528) );
  sky130_fd_sc_hd__nand2_1 U9585 ( .A(n4183), .B(\cpuregs[8][12] ), .Y(n7913)
         );
  sky130_fd_sc_hd__o21ai_1 U9586 ( .A1(n4183), .A2(n4212), .B1(n7913), .Y(
        n3531) );
  sky130_fd_sc_hd__nand2_1 U9587 ( .A(n7084), .B(\cpuregs[22][12] ), .Y(n7914)
         );
  sky130_fd_sc_hd__o21ai_1 U9588 ( .A1(n7084), .A2(n4212), .B1(n7914), .Y(
        n3545) );
  sky130_fd_sc_hd__nand2_1 U9589 ( .A(n4175), .B(\cpuregs[27][12] ), .Y(n7915)
         );
  sky130_fd_sc_hd__o21ai_1 U9590 ( .A1(n4175), .A2(n4212), .B1(n7915), .Y(
        n3550) );
  sky130_fd_sc_hd__nand2_1 U9591 ( .A(n4195), .B(\cpuregs[17][12] ), .Y(n7916)
         );
  sky130_fd_sc_hd__o21ai_1 U9592 ( .A1(n4195), .A2(n4212), .B1(n7916), .Y(
        n3540) );
  sky130_fd_sc_hd__nand2_1 U9593 ( .A(n4179), .B(\cpuregs[4][12] ), .Y(n7917)
         );
  sky130_fd_sc_hd__o21ai_1 U9594 ( .A1(n4179), .A2(n4212), .B1(n7917), .Y(
        n3527) );
  sky130_fd_sc_hd__nand2_1 U9595 ( .A(n4201), .B(\cpuregs[3][12] ), .Y(n7918)
         );
  sky130_fd_sc_hd__o21ai_1 U9596 ( .A1(n4201), .A2(n4212), .B1(n7918), .Y(
        n3526) );
  sky130_fd_sc_hd__nand2_1 U9597 ( .A(n4186), .B(\cpuregs[13][12] ), .Y(n7919)
         );
  sky130_fd_sc_hd__o21ai_1 U9598 ( .A1(n4186), .A2(n4212), .B1(n7919), .Y(
        n3536) );
  sky130_fd_sc_hd__nand2_1 U9599 ( .A(n4197), .B(\cpuregs[16][12] ), .Y(n7920)
         );
  sky130_fd_sc_hd__o21ai_1 U9600 ( .A1(n4197), .A2(n4212), .B1(n7920), .Y(
        n3539) );
  sky130_fd_sc_hd__nand2_1 U9601 ( .A(n6396), .B(\cpuregs[1][12] ), .Y(n7921)
         );
  sky130_fd_sc_hd__o21ai_1 U9602 ( .A1(n6396), .A2(n4212), .B1(n7921), .Y(
        n3524) );
  sky130_fd_sc_hd__nand2_1 U9603 ( .A(n4194), .B(\cpuregs[19][12] ), .Y(n7922)
         );
  sky130_fd_sc_hd__o21ai_1 U9604 ( .A1(n4194), .A2(n4212), .B1(n7922), .Y(
        n3542) );
  sky130_fd_sc_hd__nand2_1 U9605 ( .A(n4176), .B(\cpuregs[29][12] ), .Y(n7923)
         );
  sky130_fd_sc_hd__o21ai_1 U9606 ( .A1(n4176), .A2(n4212), .B1(n7923), .Y(
        n3552) );
  sky130_fd_sc_hd__nand2_1 U9607 ( .A(n4185), .B(\cpuregs[11][12] ), .Y(n7924)
         );
  sky130_fd_sc_hd__o21ai_1 U9608 ( .A1(n4185), .A2(n4212), .B1(n7924), .Y(
        n3534) );
  sky130_fd_sc_hd__nand2_1 U9609 ( .A(n10058), .B(\cpuregs[20][12] ), .Y(n7925) );
  sky130_fd_sc_hd__o21ai_1 U9610 ( .A1(n10058), .A2(n4212), .B1(n7925), .Y(
        n3543) );
  sky130_fd_sc_hd__nand2_1 U9611 ( .A(n9621), .B(\cpuregs[26][12] ), .Y(n7926)
         );
  sky130_fd_sc_hd__o21ai_1 U9612 ( .A1(n9621), .A2(n4212), .B1(n7926), .Y(
        n3549) );
  sky130_fd_sc_hd__nand2_1 U9613 ( .A(n9209), .B(\cpuregs[6][12] ), .Y(n7927)
         );
  sky130_fd_sc_hd__o21ai_1 U9614 ( .A1(n9772), .A2(n4212), .B1(n7927), .Y(
        n3529) );
  sky130_fd_sc_hd__a222oi_1 U9615 ( .A1(n10086), .A2(decoded_imm_j[12]), .B1(
        n10087), .B2(mem_rdata_q[12]), .C1(mem_rdata[12]), .C2(n7928), .Y(
        n7929) );
  sky130_fd_sc_hd__a22oi_1 U9616 ( .A1(decoded_imm[12]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[12]), .Y(n7931) );
  sky130_fd_sc_hd__o211ai_1 U9617 ( .A1(n7933), .A2(n7932), .B1(n7931), .C1(
        n7930), .Y(n2860) );
  sky130_fd_sc_hd__a22oi_1 U9618 ( .A1(n6137), .A2(\cpuregs[29][12] ), .B1(
        n8503), .B2(\cpuregs[24][12] ), .Y(n7937) );
  sky130_fd_sc_hd__a22oi_1 U9619 ( .A1(n8478), .A2(\cpuregs[13][12] ), .B1(
        n8487), .B2(\cpuregs[31][12] ), .Y(n7936) );
  sky130_fd_sc_hd__a22oi_1 U9620 ( .A1(n8498), .A2(\cpuregs[14][12] ), .B1(
        n8491), .B2(\cpuregs[12][12] ), .Y(n7935) );
  sky130_fd_sc_hd__a22oi_1 U9621 ( .A1(n8501), .A2(\cpuregs[15][12] ), .B1(
        n8490), .B2(\cpuregs[28][12] ), .Y(n7934) );
  sky130_fd_sc_hd__nand4_1 U9622 ( .A(n7937), .B(n7936), .C(n7935), .D(n7934), 
        .Y(n7953) );
  sky130_fd_sc_hd__a22oi_1 U9623 ( .A1(n8467), .A2(\cpuregs[26][12] ), .B1(
        n8481), .B2(\cpuregs[11][12] ), .Y(n7941) );
  sky130_fd_sc_hd__a22oi_1 U9624 ( .A1(n6059), .A2(\cpuregs[20][12] ), .B1(
        n8502), .B2(\cpuregs[6][12] ), .Y(n7940) );
  sky130_fd_sc_hd__a22oi_1 U9625 ( .A1(n6412), .A2(\cpuregs[19][12] ), .B1(
        n8488), .B2(\cpuregs[1][12] ), .Y(n7939) );
  sky130_fd_sc_hd__nand2_1 U9626 ( .A(n8500), .B(\cpuregs[30][12] ), .Y(n7938)
         );
  sky130_fd_sc_hd__nand4_1 U9627 ( .A(n7941), .B(n7940), .C(n7939), .D(n7938), 
        .Y(n7952) );
  sky130_fd_sc_hd__a22oi_1 U9628 ( .A1(n8497), .A2(\cpuregs[27][12] ), .B1(
        n8499), .B2(\cpuregs[3][12] ), .Y(n7945) );
  sky130_fd_sc_hd__a22oi_1 U9629 ( .A1(n8492), .A2(\cpuregs[4][12] ), .B1(
        n8465), .B2(\cpuregs[16][12] ), .Y(n7944) );
  sky130_fd_sc_hd__a22oi_1 U9630 ( .A1(n8489), .A2(\cpuregs[17][12] ), .B1(
        n4233), .B2(\cpuregs[8][12] ), .Y(n7943) );
  sky130_fd_sc_hd__a22oi_1 U9631 ( .A1(n8482), .A2(\cpuregs[22][12] ), .B1(
        n8471), .B2(\cpuregs[5][12] ), .Y(n7942) );
  sky130_fd_sc_hd__nand4_1 U9632 ( .A(n7945), .B(n7944), .C(n7943), .D(n7942), 
        .Y(n7951) );
  sky130_fd_sc_hd__a22oi_1 U9633 ( .A1(n8466), .A2(\cpuregs[25][12] ), .B1(
        n8479), .B2(\cpuregs[2][12] ), .Y(n7949) );
  sky130_fd_sc_hd__a22oi_1 U9634 ( .A1(n8480), .A2(\cpuregs[21][12] ), .B1(
        n8470), .B2(\cpuregs[10][12] ), .Y(n7948) );
  sky130_fd_sc_hd__a22oi_1 U9635 ( .A1(n8477), .A2(\cpuregs[7][12] ), .B1(
        n8472), .B2(\cpuregs[18][12] ), .Y(n7947) );
  sky130_fd_sc_hd__a22oi_1 U9636 ( .A1(n8464), .A2(\cpuregs[23][12] ), .B1(
        n8036), .B2(\cpuregs[9][12] ), .Y(n7946) );
  sky130_fd_sc_hd__nand4_1 U9637 ( .A(n7949), .B(n7948), .C(n7947), .D(n7946), 
        .Y(n7950) );
  sky130_fd_sc_hd__nor4_1 U9638 ( .A(n7953), .B(n7952), .C(n7951), .D(n7950), 
        .Y(n7955) );
  sky130_fd_sc_hd__a22oi_1 U9639 ( .A1(pcpi_rs2[12]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[12]), .Y(n7954) );
  sky130_fd_sc_hd__o21ai_1 U9640 ( .A1(n7955), .A2(n8514), .B1(n7954), .Y(
        n3946) );
  sky130_fd_sc_hd__o22ai_1 U9641 ( .A1(n10029), .A2(n8779), .B1(n7956), .B2(
        n9387), .Y(n4007) );
  sky130_fd_sc_hd__o22ai_1 U9642 ( .A1(n10023), .A2(n8121), .B1(n10079), .B2(
        n8122), .Y(n4162) );
  sky130_fd_sc_hd__o21ai_1 U9643 ( .A1(n7960), .A2(n8127), .B1(n7959), .Y(
        n8060) );
  sky130_fd_sc_hd__a21oi_1 U9644 ( .A1(n8060), .A2(n8059), .B1(n7962), .Y(
        n7967) );
  sky130_fd_sc_hd__nand2_1 U9645 ( .A(n7965), .B(n7964), .Y(n7966) );
  sky130_fd_sc_hd__xor2_1 U9646 ( .A(n7967), .B(n7966), .X(n7968) );
  sky130_fd_sc_hd__nand2_1 U9647 ( .A(n7968), .B(n4639), .Y(n7974) );
  sky130_fd_sc_hd__a22oi_1 U9648 ( .A1(n8129), .A2(mem_rdata_word[11]), .B1(
        n9856), .B2(count_instr[43]), .Y(n7973) );
  sky130_fd_sc_hd__nand2_1 U9649 ( .A(n9861), .B(count_cycle[43]), .Y(n7969)
         );
  sky130_fd_sc_hd__o211ai_1 U9650 ( .A1(n8820), .A2(n9437), .B1(n8131), .C1(
        n7969), .Y(n7970) );
  sky130_fd_sc_hd__a21oi_1 U9651 ( .A1(n9860), .A2(count_cycle[11]), .B1(n7970), .Y(n7972) );
  sky130_fd_sc_hd__nand2_1 U9652 ( .A(n9857), .B(count_instr[11]), .Y(n7971)
         );
  sky130_fd_sc_hd__nand4_1 U9653 ( .A(n7974), .B(n7973), .C(n7972), .D(n7971), 
        .Y(N1888) );
  sky130_fd_sc_hd__nand2_1 U9654 ( .A(n7976), .B(n7975), .Y(n7982) );
  sky130_fd_sc_hd__inv_1 U9655 ( .A(n7978), .Y(n7979) );
  sky130_fd_sc_hd__o21ai_1 U9656 ( .A1(n7980), .A2(n8073), .B1(n7979), .Y(
        n7981) );
  sky130_fd_sc_hd__xnor2_1 U9657 ( .A(n7982), .B(n7981), .Y(n7983) );
  sky130_fd_sc_hd__a222oi_1 U9658 ( .A1(n8057), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[11]), .C1(n5794), .C2(n7983), .Y(n7984) );
  sky130_fd_sc_hd__nand2_1 U9659 ( .A(n9736), .B(reg_pc[10]), .Y(n7986) );
  sky130_fd_sc_hd__xor2_1 U9660 ( .A(n7986), .B(n7985), .X(n7987) );
  sky130_fd_sc_hd__a222oi_1 U9661 ( .A1(reg_out[11]), .A2(n9816), .B1(
        alu_out_q[11]), .B2(n9815), .C1(n7987), .C2(n9813), .Y(n8001) );
  sky130_fd_sc_hd__nand2_1 U9662 ( .A(n10057), .B(\cpuregs[24][11] ), .Y(n7988) );
  sky130_fd_sc_hd__o21ai_1 U9663 ( .A1(n10057), .A2(n4211), .B1(n7988), .Y(
        n3578) );
  sky130_fd_sc_hd__nand2_1 U9664 ( .A(n4177), .B(\cpuregs[30][11] ), .Y(n7989)
         );
  sky130_fd_sc_hd__o21ai_1 U9665 ( .A1(n4177), .A2(n4211), .B1(n7989), .Y(
        n3584) );
  sky130_fd_sc_hd__nand2_1 U9666 ( .A(n7452), .B(\cpuregs[9][11] ), .Y(n7990)
         );
  sky130_fd_sc_hd__o21ai_1 U9667 ( .A1(n7452), .A2(n4211), .B1(n7990), .Y(
        n3563) );
  sky130_fd_sc_hd__nand2_1 U9668 ( .A(n4173), .B(\cpuregs[23][11] ), .Y(n7991)
         );
  sky130_fd_sc_hd__o21ai_1 U9669 ( .A1(n4173), .A2(n4211), .B1(n7991), .Y(
        n3577) );
  sky130_fd_sc_hd__nand2_1 U9670 ( .A(n7069), .B(\cpuregs[15][11] ), .Y(n7992)
         );
  sky130_fd_sc_hd__o21ai_1 U9671 ( .A1(n7069), .A2(n4211), .B1(n7992), .Y(
        n3569) );
  sky130_fd_sc_hd__nand2_1 U9672 ( .A(n4219), .B(\cpuregs[28][11] ), .Y(n7993)
         );
  sky130_fd_sc_hd__o21ai_1 U9673 ( .A1(n4219), .A2(n4211), .B1(n7993), .Y(
        n3582) );
  sky130_fd_sc_hd__nand2_1 U9674 ( .A(n4199), .B(\cpuregs[7][11] ), .Y(n7994)
         );
  sky130_fd_sc_hd__o21ai_1 U9675 ( .A1(n4199), .A2(n4211), .B1(n7994), .Y(
        n3561) );
  sky130_fd_sc_hd__nand2_1 U9676 ( .A(n4226), .B(\cpuregs[12][11] ), .Y(n7995)
         );
  sky130_fd_sc_hd__o21ai_1 U9677 ( .A1(n4226), .A2(n4211), .B1(n7995), .Y(
        n3566) );
  sky130_fd_sc_hd__nand2_1 U9678 ( .A(n4184), .B(\cpuregs[10][11] ), .Y(n7996)
         );
  sky130_fd_sc_hd__o21ai_1 U9679 ( .A1(n4184), .A2(n4211), .B1(n7996), .Y(
        n3564) );
  sky130_fd_sc_hd__nand2_1 U9680 ( .A(n9820), .B(\cpuregs[18][11] ), .Y(n7997)
         );
  sky130_fd_sc_hd__o21ai_1 U9681 ( .A1(n9820), .A2(n4211), .B1(n7997), .Y(
        n3572) );
  sky130_fd_sc_hd__nand2_1 U9682 ( .A(n6897), .B(\cpuregs[14][11] ), .Y(n7998)
         );
  sky130_fd_sc_hd__o21ai_1 U9683 ( .A1(n6897), .A2(n4211), .B1(n7998), .Y(
        n3568) );
  sky130_fd_sc_hd__nand2_1 U9684 ( .A(n4174), .B(\cpuregs[21][11] ), .Y(n7999)
         );
  sky130_fd_sc_hd__o21ai_1 U9685 ( .A1(n4174), .A2(n4211), .B1(n7999), .Y(
        n3575) );
  sky130_fd_sc_hd__nand2_1 U9686 ( .A(n4192), .B(\cpuregs[25][11] ), .Y(n8000)
         );
  sky130_fd_sc_hd__o21ai_1 U9687 ( .A1(n4192), .A2(n4211), .B1(n8000), .Y(
        n3579) );
  sky130_fd_sc_hd__nand2_1 U9688 ( .A(n4178), .B(\cpuregs[2][11] ), .Y(n8002)
         );
  sky130_fd_sc_hd__o21ai_1 U9689 ( .A1(n4178), .A2(n4211), .B1(n8002), .Y(
        n3556) );
  sky130_fd_sc_hd__nand2_1 U9690 ( .A(n7247), .B(\cpuregs[31][11] ), .Y(n8003)
         );
  sky130_fd_sc_hd__o21ai_1 U9691 ( .A1(n7247), .A2(n4211), .B1(n8003), .Y(
        n3585) );
  sky130_fd_sc_hd__nand2_1 U9692 ( .A(n4180), .B(\cpuregs[5][11] ), .Y(n8004)
         );
  sky130_fd_sc_hd__o21ai_1 U9693 ( .A1(n4180), .A2(n4211), .B1(n8004), .Y(
        n3559) );
  sky130_fd_sc_hd__nand2_1 U9694 ( .A(n4183), .B(\cpuregs[8][11] ), .Y(n8005)
         );
  sky130_fd_sc_hd__o21ai_1 U9695 ( .A1(n4183), .A2(n4211), .B1(n8005), .Y(
        n3562) );
  sky130_fd_sc_hd__nand2_1 U9696 ( .A(n7084), .B(\cpuregs[22][11] ), .Y(n8006)
         );
  sky130_fd_sc_hd__o21ai_1 U9697 ( .A1(n7084), .A2(n4211), .B1(n8006), .Y(
        n3576) );
  sky130_fd_sc_hd__nand2_1 U9698 ( .A(n4175), .B(\cpuregs[27][11] ), .Y(n8007)
         );
  sky130_fd_sc_hd__o21ai_1 U9699 ( .A1(n4175), .A2(n4211), .B1(n8007), .Y(
        n3581) );
  sky130_fd_sc_hd__nand2_1 U9700 ( .A(n4195), .B(\cpuregs[17][11] ), .Y(n8008)
         );
  sky130_fd_sc_hd__o21ai_1 U9701 ( .A1(n4195), .A2(n4211), .B1(n8008), .Y(
        n3571) );
  sky130_fd_sc_hd__nand2_1 U9702 ( .A(n4179), .B(\cpuregs[4][11] ), .Y(n8009)
         );
  sky130_fd_sc_hd__o21ai_1 U9703 ( .A1(n4179), .A2(n4211), .B1(n8009), .Y(
        n3558) );
  sky130_fd_sc_hd__nand2_1 U9704 ( .A(n4201), .B(\cpuregs[3][11] ), .Y(n8010)
         );
  sky130_fd_sc_hd__o21ai_1 U9705 ( .A1(n4201), .A2(n4211), .B1(n8010), .Y(
        n3557) );
  sky130_fd_sc_hd__nand2_1 U9706 ( .A(n4186), .B(\cpuregs[13][11] ), .Y(n8011)
         );
  sky130_fd_sc_hd__o21ai_1 U9707 ( .A1(n4186), .A2(n4211), .B1(n8011), .Y(
        n3567) );
  sky130_fd_sc_hd__nand2_1 U9708 ( .A(n4197), .B(\cpuregs[16][11] ), .Y(n8012)
         );
  sky130_fd_sc_hd__o21ai_1 U9709 ( .A1(n4197), .A2(n4211), .B1(n8012), .Y(
        n3570) );
  sky130_fd_sc_hd__nand2_1 U9710 ( .A(n6396), .B(\cpuregs[1][11] ), .Y(n8013)
         );
  sky130_fd_sc_hd__o21ai_1 U9711 ( .A1(n6396), .A2(n4211), .B1(n8013), .Y(
        n3555) );
  sky130_fd_sc_hd__nand2_1 U9712 ( .A(n4194), .B(\cpuregs[19][11] ), .Y(n8014)
         );
  sky130_fd_sc_hd__o21ai_1 U9713 ( .A1(n4194), .A2(n4211), .B1(n8014), .Y(
        n3573) );
  sky130_fd_sc_hd__nand2_1 U9714 ( .A(n4176), .B(\cpuregs[29][11] ), .Y(n8015)
         );
  sky130_fd_sc_hd__o21ai_1 U9715 ( .A1(n4176), .A2(n4211), .B1(n8015), .Y(
        n3583) );
  sky130_fd_sc_hd__nand2_1 U9716 ( .A(n4185), .B(\cpuregs[11][11] ), .Y(n8016)
         );
  sky130_fd_sc_hd__o21ai_1 U9717 ( .A1(n4185), .A2(n4211), .B1(n8016), .Y(
        n3565) );
  sky130_fd_sc_hd__nand2_1 U9718 ( .A(n10058), .B(\cpuregs[20][11] ), .Y(n8017) );
  sky130_fd_sc_hd__o21ai_1 U9719 ( .A1(n10058), .A2(n4211), .B1(n8017), .Y(
        n3574) );
  sky130_fd_sc_hd__nand2_1 U9720 ( .A(n9621), .B(\cpuregs[26][11] ), .Y(n8018)
         );
  sky130_fd_sc_hd__o21ai_1 U9721 ( .A1(n9621), .A2(n4211), .B1(n8018), .Y(
        n3580) );
  sky130_fd_sc_hd__nand2_1 U9722 ( .A(n9772), .B(\cpuregs[6][11] ), .Y(n8019)
         );
  sky130_fd_sc_hd__o21ai_1 U9723 ( .A1(n9772), .A2(n4211), .B1(n8019), .Y(
        n3560) );
  sky130_fd_sc_hd__and3_1 U9724 ( .A(n8020), .B(is_sb_sh_sw), .C(n10034), .X(
        n8638) );
  sky130_fd_sc_hd__o21ai_1 U9725 ( .A1(n8637), .A2(n8638), .B1(mem_rdata_q[31]), .Y(n8023) );
  sky130_fd_sc_hd__a22oi_1 U9726 ( .A1(decoded_imm[11]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[11]), .Y(n8022) );
  sky130_fd_sc_hd__nand3_1 U9727 ( .A(n8020), .B(is_beq_bne_blt_bge_bltu_bgeu), 
        .C(mem_rdata_q[7]), .Y(n8021) );
  sky130_fd_sc_hd__nand3_1 U9728 ( .A(n8023), .B(n8022), .C(n8021), .Y(n2861)
         );
  sky130_fd_sc_hd__a22oi_1 U9729 ( .A1(\cpuregs[29][11] ), .A2(n6137), .B1(
        n8503), .B2(\cpuregs[24][11] ), .Y(n8027) );
  sky130_fd_sc_hd__a22oi_1 U9730 ( .A1(n8478), .A2(\cpuregs[13][11] ), .B1(
        \cpuregs[31][11] ), .B2(n8487), .Y(n8026) );
  sky130_fd_sc_hd__a22oi_1 U9731 ( .A1(n8498), .A2(\cpuregs[14][11] ), .B1(
        \cpuregs[12][11] ), .B2(n8491), .Y(n8025) );
  sky130_fd_sc_hd__a22oi_1 U9732 ( .A1(n8501), .A2(\cpuregs[15][11] ), .B1(
        \cpuregs[28][11] ), .B2(n8490), .Y(n8024) );
  sky130_fd_sc_hd__nand4_1 U9733 ( .A(n8027), .B(n8026), .C(n8025), .D(n8024), 
        .Y(n8044) );
  sky130_fd_sc_hd__a22oi_1 U9734 ( .A1(n8467), .A2(\cpuregs[26][11] ), .B1(
        n8481), .B2(\cpuregs[11][11] ), .Y(n8031) );
  sky130_fd_sc_hd__a22oi_1 U9735 ( .A1(n6059), .A2(\cpuregs[20][11] ), .B1(
        n8502), .B2(\cpuregs[6][11] ), .Y(n8030) );
  sky130_fd_sc_hd__a22oi_1 U9736 ( .A1(n6412), .A2(\cpuregs[19][11] ), .B1(
        n8488), .B2(\cpuregs[1][11] ), .Y(n8029) );
  sky130_fd_sc_hd__nand2_1 U9737 ( .A(n8500), .B(\cpuregs[30][11] ), .Y(n8028)
         );
  sky130_fd_sc_hd__nand4_1 U9738 ( .A(n8031), .B(n8030), .C(n8029), .D(n8028), 
        .Y(n8043) );
  sky130_fd_sc_hd__a22oi_1 U9739 ( .A1(n8497), .A2(\cpuregs[27][11] ), .B1(
        n8499), .B2(\cpuregs[3][11] ), .Y(n8035) );
  sky130_fd_sc_hd__a22oi_1 U9740 ( .A1(\cpuregs[4][11] ), .A2(n8492), .B1(
        n8465), .B2(\cpuregs[16][11] ), .Y(n8034) );
  sky130_fd_sc_hd__a22oi_1 U9741 ( .A1(n8489), .A2(\cpuregs[17][11] ), .B1(
        n4233), .B2(\cpuregs[8][11] ), .Y(n8033) );
  sky130_fd_sc_hd__a22oi_1 U9742 ( .A1(n8482), .A2(\cpuregs[22][11] ), .B1(
        n8471), .B2(\cpuregs[5][11] ), .Y(n8032) );
  sky130_fd_sc_hd__nand4_1 U9743 ( .A(n8035), .B(n8034), .C(n8033), .D(n8032), 
        .Y(n8042) );
  sky130_fd_sc_hd__a22oi_1 U9744 ( .A1(n8466), .A2(\cpuregs[25][11] ), .B1(
        n8479), .B2(\cpuregs[2][11] ), .Y(n8040) );
  sky130_fd_sc_hd__a22oi_1 U9745 ( .A1(\cpuregs[21][11] ), .A2(n8480), .B1(
        n8470), .B2(\cpuregs[10][11] ), .Y(n8039) );
  sky130_fd_sc_hd__a22oi_1 U9746 ( .A1(\cpuregs[7][11] ), .A2(n8477), .B1(
        n8472), .B2(\cpuregs[18][11] ), .Y(n8038) );
  sky130_fd_sc_hd__a22oi_1 U9747 ( .A1(\cpuregs[23][11] ), .A2(n8464), .B1(
        n8036), .B2(\cpuregs[9][11] ), .Y(n8037) );
  sky130_fd_sc_hd__nand4_1 U9748 ( .A(n8040), .B(n8039), .C(n8038), .D(n8037), 
        .Y(n8041) );
  sky130_fd_sc_hd__nor4_1 U9749 ( .A(n8044), .B(n8043), .C(n8042), .D(n8041), 
        .Y(n8046) );
  sky130_fd_sc_hd__a22oi_1 U9750 ( .A1(pcpi_rs2[11]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[11]), .Y(n8045) );
  sky130_fd_sc_hd__o21ai_1 U9751 ( .A1(n8046), .A2(n8514), .B1(n8045), .Y(
        n3947) );
  sky130_fd_sc_hd__nand2_1 U9752 ( .A(n8048), .B(n8047), .Y(n8049) );
  sky130_fd_sc_hd__xor2_1 U9753 ( .A(n8050), .B(n8049), .X(n8051) );
  sky130_fd_sc_hd__nand2_1 U9754 ( .A(n8051), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n8056) );
  sky130_fd_sc_hd__nor2_1 U9755 ( .A(n8683), .B(n8052), .Y(n8053) );
  sky130_fd_sc_hd__a31oi_1 U9756 ( .A1(n9382), .A2(pcpi_rs1[11]), .A3(
        pcpi_rs2[11]), .B1(n8053), .Y(n8055) );
  sky130_fd_sc_hd__o21ai_1 U9757 ( .A1(pcpi_rs1[11]), .A2(pcpi_rs2[11]), .B1(
        n9872), .Y(n8054) );
  sky130_fd_sc_hd__nand3_1 U9758 ( .A(n8056), .B(n8055), .C(n8054), .Y(
        alu_out[11]) );
  sky130_fd_sc_hd__a22o_1 U9759 ( .A1(n10055), .A2(n8057), .B1(n9530), .B2(
        reg_pc[11]), .X(n4008) );
  sky130_fd_sc_hd__o22ai_1 U9760 ( .A1(n10022), .A2(n8121), .B1(n10081), .B2(
        n8122), .Y(n4161) );
  sky130_fd_sc_hd__nand2_1 U9761 ( .A(n8059), .B(n8058), .Y(n8061) );
  sky130_fd_sc_hd__xnor2_1 U9762 ( .A(n8061), .B(n8060), .Y(n8062) );
  sky130_fd_sc_hd__nand2_1 U9763 ( .A(n8062), .B(n4639), .Y(n8068) );
  sky130_fd_sc_hd__a22oi_1 U9764 ( .A1(n8129), .A2(mem_rdata_word[10]), .B1(
        n9856), .B2(count_instr[42]), .Y(n8067) );
  sky130_fd_sc_hd__nand2_1 U9765 ( .A(n9861), .B(count_cycle[42]), .Y(n8063)
         );
  sky130_fd_sc_hd__o211ai_1 U9766 ( .A1(n8813), .A2(n9437), .B1(n8131), .C1(
        n8063), .Y(n8064) );
  sky130_fd_sc_hd__a21oi_1 U9767 ( .A1(n9860), .A2(count_cycle[10]), .B1(n8064), .Y(n8066) );
  sky130_fd_sc_hd__nand2_1 U9768 ( .A(n9857), .B(count_instr[10]), .Y(n8065)
         );
  sky130_fd_sc_hd__nand4_1 U9769 ( .A(n8068), .B(n8067), .C(n8066), .D(n8065), 
        .Y(N1887) );
  sky130_fd_sc_hd__inv_1 U9770 ( .A(n8069), .Y(n8071) );
  sky130_fd_sc_hd__nand2_1 U9771 ( .A(n8071), .B(n8070), .Y(n8076) );
  sky130_fd_sc_hd__o21ai_1 U9772 ( .A1(n8074), .A2(n8073), .B1(n8072), .Y(
        n8075) );
  sky130_fd_sc_hd__xnor2_1 U9773 ( .A(n8076), .B(n8075), .Y(n8077) );
  sky130_fd_sc_hd__a222oi_1 U9774 ( .A1(n8119), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[10]), .C1(n5794), .C2(n8077), .Y(n8078) );
  sky130_fd_sc_hd__a22oi_1 U9775 ( .A1(decoded_imm_j[10]), .A2(n10086), .B1(
        n10087), .B2(mem_rdata_q[30]), .Y(n8079) );
  sky130_fd_sc_hd__o21ai_1 U9776 ( .A1(n10026), .A2(n10089), .B1(n8079), .Y(
        n2882) );
  sky130_fd_sc_hd__a22oi_1 U9777 ( .A1(decoded_imm[10]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[10]), .Y(n8080) );
  sky130_fd_sc_hd__o21ai_1 U9778 ( .A1(n8081), .A2(n8462), .B1(n8080), .Y(
        n2862) );
  sky130_fd_sc_hd__a22oi_1 U9779 ( .A1(\cpuregs[16][10] ), .A2(n8465), .B1(
        \cpuregs[1][10] ), .B2(n8488), .Y(n8085) );
  sky130_fd_sc_hd__a22oi_1 U9780 ( .A1(\cpuregs[19][10] ), .A2(n6412), .B1(
        \cpuregs[29][10] ), .B2(n6137), .Y(n8084) );
  sky130_fd_sc_hd__a22oi_1 U9781 ( .A1(\cpuregs[11][10] ), .A2(n8481), .B1(
        \cpuregs[20][10] ), .B2(n6059), .Y(n8083) );
  sky130_fd_sc_hd__a22oi_1 U9782 ( .A1(\cpuregs[26][10] ), .A2(n8467), .B1(
        \cpuregs[6][10] ), .B2(n8502), .Y(n8082) );
  sky130_fd_sc_hd__nand4_1 U9783 ( .A(n8085), .B(n8084), .C(n8083), .D(n8082), 
        .Y(n8101) );
  sky130_fd_sc_hd__a22oi_1 U9784 ( .A1(\cpuregs[12][10] ), .A2(n8491), .B1(
        \cpuregs[10][10] ), .B2(n8470), .Y(n8089) );
  sky130_fd_sc_hd__a22oi_1 U9785 ( .A1(\cpuregs[18][10] ), .A2(n8472), .B1(
        \cpuregs[14][10] ), .B2(n8498), .Y(n8088) );
  sky130_fd_sc_hd__a22oi_1 U9786 ( .A1(\cpuregs[21][10] ), .A2(n8480), .B1(
        \cpuregs[25][10] ), .B2(n8466), .Y(n8087) );
  sky130_fd_sc_hd__a22oi_1 U9787 ( .A1(\cpuregs[2][10] ), .A2(n8479), .B1(
        \cpuregs[31][10] ), .B2(n8487), .Y(n8086) );
  sky130_fd_sc_hd__nand4_1 U9788 ( .A(n8089), .B(n8088), .C(n8087), .D(n8086), 
        .Y(n8100) );
  sky130_fd_sc_hd__a22oi_1 U9789 ( .A1(\cpuregs[24][10] ), .A2(n8503), .B1(
        \cpuregs[30][10] ), .B2(n8500), .Y(n8093) );
  sky130_fd_sc_hd__a22oi_1 U9790 ( .A1(\cpuregs[9][10] ), .A2(n8036), .B1(
        \cpuregs[23][10] ), .B2(n8464), .Y(n8092) );
  sky130_fd_sc_hd__a22oi_1 U9791 ( .A1(\cpuregs[15][10] ), .A2(n8501), .B1(
        \cpuregs[28][10] ), .B2(n8490), .Y(n8091) );
  sky130_fd_sc_hd__nand2_1 U9792 ( .A(\cpuregs[7][10] ), .B(n8477), .Y(n8090)
         );
  sky130_fd_sc_hd__nand4_1 U9793 ( .A(n8093), .B(n8092), .C(n8091), .D(n8090), 
        .Y(n8099) );
  sky130_fd_sc_hd__a22oi_1 U9794 ( .A1(\cpuregs[5][10] ), .A2(n8471), .B1(
        \cpuregs[8][10] ), .B2(n4233), .Y(n8097) );
  sky130_fd_sc_hd__a22oi_1 U9795 ( .A1(\cpuregs[22][10] ), .A2(n8482), .B1(
        \cpuregs[27][10] ), .B2(n8497), .Y(n8096) );
  sky130_fd_sc_hd__a22oi_1 U9796 ( .A1(\cpuregs[17][10] ), .A2(n8489), .B1(
        \cpuregs[4][10] ), .B2(n8492), .Y(n8095) );
  sky130_fd_sc_hd__a22oi_1 U9797 ( .A1(\cpuregs[3][10] ), .A2(n8499), .B1(
        \cpuregs[13][10] ), .B2(n8478), .Y(n8094) );
  sky130_fd_sc_hd__nand4_1 U9798 ( .A(n8097), .B(n8096), .C(n8095), .D(n8094), 
        .Y(n8098) );
  sky130_fd_sc_hd__nor4_1 U9799 ( .A(n8101), .B(n8100), .C(n8099), .D(n8098), 
        .Y(n8103) );
  sky130_fd_sc_hd__a22oi_1 U9800 ( .A1(pcpi_rs2[10]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[10]), .Y(n8102) );
  sky130_fd_sc_hd__o21ai_1 U9801 ( .A1(n8514), .A2(n8103), .B1(n8102), .Y(
        n3948) );
  sky130_fd_sc_hd__a21oi_1 U9802 ( .A1(n8107), .A2(n8106), .B1(n8105), .Y(
        n8112) );
  sky130_fd_sc_hd__nand2_1 U9803 ( .A(n8110), .B(n8109), .Y(n8111) );
  sky130_fd_sc_hd__xor2_1 U9804 ( .A(n8112), .B(n8111), .X(n8113) );
  sky130_fd_sc_hd__nand2_1 U9805 ( .A(n8113), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n8118) );
  sky130_fd_sc_hd__nor2_1 U9806 ( .A(n8683), .B(n8114), .Y(n8115) );
  sky130_fd_sc_hd__a31oi_1 U9807 ( .A1(n9382), .A2(pcpi_rs1[10]), .A3(
        pcpi_rs2[10]), .B1(n8115), .Y(n8117) );
  sky130_fd_sc_hd__o21ai_1 U9808 ( .A1(pcpi_rs1[10]), .A2(pcpi_rs2[10]), .B1(
        n9872), .Y(n8116) );
  sky130_fd_sc_hd__nand3_1 U9809 ( .A(n8118), .B(n8117), .C(n8116), .Y(
        alu_out[10]) );
  sky130_fd_sc_hd__o22ai_1 U9810 ( .A1(n10029), .A2(n9737), .B1(n8120), .B2(
        n9387), .Y(n4009) );
  sky130_fd_sc_hd__clkinv_1 U9811 ( .A(mem_rdata[24]), .Y(n10020) );
  sky130_fd_sc_hd__o22ai_1 U9812 ( .A1(n10085), .A2(n8122), .B1(n10020), .B2(
        n8121), .Y(n4159) );
  sky130_fd_sc_hd__nand2_1 U9813 ( .A(n8125), .B(n8124), .Y(n8126) );
  sky130_fd_sc_hd__xor2_1 U9814 ( .A(n8127), .B(n8126), .X(n8128) );
  sky130_fd_sc_hd__nand2_1 U9815 ( .A(n8128), .B(n4639), .Y(n8136) );
  sky130_fd_sc_hd__a22oi_1 U9816 ( .A1(n9857), .A2(count_instr[8]), .B1(n8129), 
        .B2(mem_rdata_word[8]), .Y(n8135) );
  sky130_fd_sc_hd__nand2_1 U9817 ( .A(n9860), .B(count_cycle[8]), .Y(n8130) );
  sky130_fd_sc_hd__o211ai_1 U9818 ( .A1(n9437), .A2(n8786), .B1(n8131), .C1(
        n8130), .Y(n8132) );
  sky130_fd_sc_hd__a21oi_1 U9819 ( .A1(n9861), .A2(count_cycle[40]), .B1(n8132), .Y(n8134) );
  sky130_fd_sc_hd__nand2_1 U9820 ( .A(n9856), .B(count_instr[40]), .Y(n8133)
         );
  sky130_fd_sc_hd__nand4_1 U9821 ( .A(n8136), .B(n8135), .C(n8134), .D(n8133), 
        .Y(N1885) );
  sky130_fd_sc_hd__a22oi_1 U9822 ( .A1(decoded_imm_j[8]), .A2(n10086), .B1(
        n10087), .B2(mem_rdata_q[28]), .Y(n8137) );
  sky130_fd_sc_hd__o21ai_1 U9823 ( .A1(n10024), .A2(n10089), .B1(n8137), .Y(
        n2884) );
  sky130_fd_sc_hd__a222oi_1 U9824 ( .A1(n10122), .A2(decoded_imm[8]), .B1(
        decoded_imm_j[8]), .B2(n8608), .C1(n8262), .C2(mem_rdata_q[28]), .Y(
        n8138) );
  sky130_fd_sc_hd__a22oi_1 U9825 ( .A1(\cpuregs[26][8] ), .A2(n8467), .B1(
        \cpuregs[15][8] ), .B2(n8501), .Y(n8142) );
  sky130_fd_sc_hd__a22oi_1 U9826 ( .A1(\cpuregs[11][8] ), .A2(n8481), .B1(
        \cpuregs[19][8] ), .B2(n6412), .Y(n8141) );
  sky130_fd_sc_hd__a22oi_1 U9827 ( .A1(\cpuregs[24][8] ), .A2(n8503), .B1(
        \cpuregs[9][8] ), .B2(n8036), .Y(n8140) );
  sky130_fd_sc_hd__nand2_1 U9828 ( .A(\cpuregs[17][8] ), .B(n8489), .Y(n8139)
         );
  sky130_fd_sc_hd__nand4_1 U9829 ( .A(n8142), .B(n8141), .C(n8140), .D(n8139), 
        .Y(n8158) );
  sky130_fd_sc_hd__a22oi_1 U9830 ( .A1(\cpuregs[5][8] ), .A2(n8471), .B1(
        \cpuregs[8][8] ), .B2(n4233), .Y(n8146) );
  sky130_fd_sc_hd__a22oi_1 U9831 ( .A1(\cpuregs[4][8] ), .A2(n8492), .B1(
        \cpuregs[6][8] ), .B2(n8502), .Y(n8145) );
  sky130_fd_sc_hd__a22oi_1 U9832 ( .A1(\cpuregs[1][8] ), .A2(n8488), .B1(
        \cpuregs[27][8] ), .B2(n8497), .Y(n8144) );
  sky130_fd_sc_hd__a22oi_1 U9833 ( .A1(\cpuregs[28][8] ), .A2(n8490), .B1(
        \cpuregs[21][8] ), .B2(n8480), .Y(n8143) );
  sky130_fd_sc_hd__nand4_1 U9834 ( .A(n8146), .B(n8145), .C(n8144), .D(n8143), 
        .Y(n8157) );
  sky130_fd_sc_hd__a22oi_1 U9835 ( .A1(\cpuregs[31][8] ), .A2(n8487), .B1(
        \cpuregs[13][8] ), .B2(n8478), .Y(n8150) );
  sky130_fd_sc_hd__a22oi_1 U9836 ( .A1(\cpuregs[22][8] ), .A2(n8482), .B1(
        \cpuregs[2][8] ), .B2(n8479), .Y(n8149) );
  sky130_fd_sc_hd__a22oi_1 U9837 ( .A1(\cpuregs[12][8] ), .A2(n8491), .B1(
        \cpuregs[20][8] ), .B2(n6059), .Y(n8148) );
  sky130_fd_sc_hd__a22oi_1 U9838 ( .A1(\cpuregs[3][8] ), .A2(n8499), .B1(
        \cpuregs[18][8] ), .B2(n8472), .Y(n8147) );
  sky130_fd_sc_hd__nand4_1 U9839 ( .A(n8150), .B(n8149), .C(n8148), .D(n8147), 
        .Y(n8156) );
  sky130_fd_sc_hd__a22oi_1 U9840 ( .A1(\cpuregs[7][8] ), .A2(n8477), .B1(
        \cpuregs[16][8] ), .B2(n8465), .Y(n8154) );
  sky130_fd_sc_hd__a22oi_1 U9841 ( .A1(\cpuregs[23][8] ), .A2(n8464), .B1(
        \cpuregs[14][8] ), .B2(n8498), .Y(n8153) );
  sky130_fd_sc_hd__a22oi_1 U9842 ( .A1(\cpuregs[10][8] ), .A2(n8470), .B1(
        \cpuregs[25][8] ), .B2(n8466), .Y(n8152) );
  sky130_fd_sc_hd__a22oi_1 U9843 ( .A1(\cpuregs[30][8] ), .A2(n8500), .B1(
        \cpuregs[29][8] ), .B2(n6137), .Y(n8151) );
  sky130_fd_sc_hd__nand4_1 U9844 ( .A(n8154), .B(n8153), .C(n8152), .D(n8151), 
        .Y(n8155) );
  sky130_fd_sc_hd__nor4_1 U9845 ( .A(n8158), .B(n8157), .C(n8156), .D(n8155), 
        .Y(n8160) );
  sky130_fd_sc_hd__a22oi_1 U9846 ( .A1(pcpi_rs2[8]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[8]), .Y(n8159) );
  sky130_fd_sc_hd__o21ai_1 U9847 ( .A1(n8514), .A2(n8160), .B1(n8159), .Y(
        n3950) );
  sky130_fd_sc_hd__nand2_1 U9848 ( .A(n8163), .B(n8162), .Y(n8165) );
  sky130_fd_sc_hd__o21ai_1 U9849 ( .A1(n9041), .A2(n9045), .B1(n9042), .Y(
        n8164) );
  sky130_fd_sc_hd__xnor2_1 U9850 ( .A(n8165), .B(n8164), .Y(n8170) );
  sky130_fd_sc_hd__a21oi_1 U9851 ( .A1(n9873), .A2(n8168), .B1(n9872), .Y(
        n8166) );
  sky130_fd_sc_hd__o22ai_1 U9852 ( .A1(n9877), .A2(n8168), .B1(n8167), .B2(
        n8166), .Y(n8169) );
  sky130_fd_sc_hd__a21o_1 U9853 ( .A1(n8170), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n8169), .X(alu_out[8]) );
  sky130_fd_sc_hd__inv_1 U9854 ( .A(n8171), .Y(n9034) );
  sky130_fd_sc_hd__inv_1 U9855 ( .A(n9033), .Y(n8173) );
  sky130_fd_sc_hd__nor2_1 U9856 ( .A(n8172), .B(n8173), .Y(n8177) );
  sky130_fd_sc_hd__clkbuf_1 U9857 ( .A(n8174), .X(n9032) );
  sky130_fd_sc_hd__o21ai_1 U9858 ( .A1(n8172), .A2(n8175), .B1(n9035), .Y(
        n8176) );
  sky130_fd_sc_hd__a21oi_1 U9859 ( .A1(n9034), .A2(n8177), .B1(n8176), .Y(
        n8182) );
  sky130_fd_sc_hd__nand2_1 U9860 ( .A(n8180), .B(n8179), .Y(n8181) );
  sky130_fd_sc_hd__xor2_1 U9861 ( .A(n8182), .B(n8181), .X(n8183) );
  sky130_fd_sc_hd__a222oi_1 U9862 ( .A1(n8185), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[8]), .C1(n5794), .C2(n8183), .Y(n8184) );
  sky130_fd_sc_hd__o22ai_1 U9863 ( .A1(n10029), .A2(n9664), .B1(n8186), .B2(
        n9387), .Y(n4011) );
  sky130_fd_sc_hd__o22ai_1 U9864 ( .A1(n8187), .A2(n9850), .B1(n10026), .B2(
        n9851), .Y(n8188) );
  sky130_fd_sc_hd__a21oi_1 U9865 ( .A1(mem_rdata[22]), .A2(n9853), .B1(n8188), 
        .Y(n8189) );
  sky130_fd_sc_hd__o21ai_1 U9866 ( .A1(n10017), .A2(n8190), .B1(n8189), .Y(
        n4157) );
  sky130_fd_sc_hd__nand2_1 U9867 ( .A(n8193), .B(n8192), .Y(n8194) );
  sky130_fd_sc_hd__xor2_1 U9868 ( .A(n8195), .B(n8194), .X(n8196) );
  sky130_fd_sc_hd__nand2_1 U9869 ( .A(n8196), .B(n4639), .Y(n8201) );
  sky130_fd_sc_hd__a22o_1 U9870 ( .A1(n9859), .A2(mem_rdata_word[6]), .B1(
        n9858), .B2(pcpi_rs1[6]), .X(n8197) );
  sky130_fd_sc_hd__a21oi_1 U9871 ( .A1(n9861), .A2(count_cycle[38]), .B1(n8197), .Y(n8200) );
  sky130_fd_sc_hd__a22oi_1 U9872 ( .A1(n9857), .A2(count_instr[6]), .B1(n9856), 
        .B2(count_instr[38]), .Y(n8199) );
  sky130_fd_sc_hd__nand2_1 U9873 ( .A(n9860), .B(count_cycle[6]), .Y(n8198) );
  sky130_fd_sc_hd__nand4_1 U9874 ( .A(n8201), .B(n8200), .C(n8199), .D(n8198), 
        .Y(N1883) );
  sky130_fd_sc_hd__clkbuf_1 U9875 ( .A(n8202), .X(n8250) );
  sky130_fd_sc_hd__a21oi_1 U9876 ( .A1(n9034), .A2(n8257), .B1(n8256), .Y(
        n8209) );
  sky130_fd_sc_hd__nand2_1 U9877 ( .A(n8207), .B(n8206), .Y(n8208) );
  sky130_fd_sc_hd__xor2_1 U9878 ( .A(n8209), .B(n8208), .X(n8210) );
  sky130_fd_sc_hd__a222oi_1 U9879 ( .A1(n8250), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[6]), .C1(n5794), .C2(n8210), .Y(n8211) );
  sky130_fd_sc_hd__a22oi_1 U9880 ( .A1(decoded_imm_j[6]), .A2(n10086), .B1(
        n10087), .B2(mem_rdata_q[26]), .Y(n8212) );
  sky130_fd_sc_hd__o21ai_1 U9881 ( .A1(n10022), .A2(n10089), .B1(n8212), .Y(
        n2886) );
  sky130_fd_sc_hd__a222oi_1 U9882 ( .A1(n10122), .A2(decoded_imm[6]), .B1(
        decoded_imm_j[6]), .B2(n8608), .C1(n8262), .C2(mem_rdata_q[26]), .Y(
        n8213) );
  sky130_fd_sc_hd__a22oi_1 U9883 ( .A1(\cpuregs[18][6] ), .A2(n8472), .B1(
        \cpuregs[21][6] ), .B2(n8480), .Y(n8217) );
  sky130_fd_sc_hd__a22oi_1 U9884 ( .A1(\cpuregs[20][6] ), .A2(n6059), .B1(
        \cpuregs[24][6] ), .B2(n8503), .Y(n8216) );
  sky130_fd_sc_hd__a22oi_1 U9885 ( .A1(\cpuregs[3][6] ), .A2(n8499), .B1(
        \cpuregs[5][6] ), .B2(n8471), .Y(n8215) );
  sky130_fd_sc_hd__nand2_1 U9886 ( .A(\cpuregs[1][6] ), .B(n8488), .Y(n8214)
         );
  sky130_fd_sc_hd__nand4_1 U9887 ( .A(n8217), .B(n8216), .C(n8215), .D(n8214), 
        .Y(n8233) );
  sky130_fd_sc_hd__a22oi_1 U9888 ( .A1(\cpuregs[17][6] ), .A2(n8489), .B1(
        \cpuregs[6][6] ), .B2(n8502), .Y(n8221) );
  sky130_fd_sc_hd__a22oi_1 U9889 ( .A1(\cpuregs[7][6] ), .A2(n8477), .B1(
        \cpuregs[29][6] ), .B2(n6137), .Y(n8220) );
  sky130_fd_sc_hd__a22oi_1 U9890 ( .A1(\cpuregs[25][6] ), .A2(n8466), .B1(
        \cpuregs[9][6] ), .B2(n8036), .Y(n8219) );
  sky130_fd_sc_hd__a22oi_1 U9891 ( .A1(\cpuregs[11][6] ), .A2(n8481), .B1(
        \cpuregs[26][6] ), .B2(n8467), .Y(n8218) );
  sky130_fd_sc_hd__nand4_1 U9892 ( .A(n8221), .B(n8220), .C(n8219), .D(n8218), 
        .Y(n8232) );
  sky130_fd_sc_hd__a22oi_1 U9893 ( .A1(\cpuregs[8][6] ), .A2(n4233), .B1(
        \cpuregs[22][6] ), .B2(n8482), .Y(n8225) );
  sky130_fd_sc_hd__a22oi_1 U9894 ( .A1(\cpuregs[2][6] ), .A2(n8479), .B1(
        \cpuregs[16][6] ), .B2(n8465), .Y(n8224) );
  sky130_fd_sc_hd__a22oi_1 U9895 ( .A1(\cpuregs[15][6] ), .A2(n8501), .B1(
        \cpuregs[13][6] ), .B2(n8478), .Y(n8223) );
  sky130_fd_sc_hd__a22oi_1 U9896 ( .A1(\cpuregs[31][6] ), .A2(n8487), .B1(
        \cpuregs[28][6] ), .B2(n8490), .Y(n8222) );
  sky130_fd_sc_hd__nand4_1 U9897 ( .A(n8225), .B(n8224), .C(n8223), .D(n8222), 
        .Y(n8231) );
  sky130_fd_sc_hd__a22oi_1 U9898 ( .A1(\cpuregs[14][6] ), .A2(n8498), .B1(
        \cpuregs[27][6] ), .B2(n8497), .Y(n8229) );
  sky130_fd_sc_hd__a22oi_1 U9899 ( .A1(\cpuregs[19][6] ), .A2(n6412), .B1(
        \cpuregs[23][6] ), .B2(n8464), .Y(n8228) );
  sky130_fd_sc_hd__a22oi_1 U9900 ( .A1(\cpuregs[4][6] ), .A2(n8492), .B1(
        \cpuregs[10][6] ), .B2(n8470), .Y(n8227) );
  sky130_fd_sc_hd__a22oi_1 U9901 ( .A1(\cpuregs[12][6] ), .A2(n8491), .B1(
        \cpuregs[30][6] ), .B2(n8500), .Y(n8226) );
  sky130_fd_sc_hd__nand4_1 U9902 ( .A(n8229), .B(n8228), .C(n8227), .D(n8226), 
        .Y(n8230) );
  sky130_fd_sc_hd__nor4_1 U9903 ( .A(n8233), .B(n8232), .C(n8231), .D(n8230), 
        .Y(n8235) );
  sky130_fd_sc_hd__a22oi_1 U9904 ( .A1(pcpi_rs2[6]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[6]), .Y(n8234) );
  sky130_fd_sc_hd__o21ai_1 U9905 ( .A1(n8514), .A2(n8235), .B1(n8234), .Y(
        n3952) );
  sky130_fd_sc_hd__nand2_1 U9906 ( .A(n8238), .B(n8237), .Y(n8243) );
  sky130_fd_sc_hd__inv_1 U9907 ( .A(n8239), .Y(n8517) );
  sky130_fd_sc_hd__a21oi_1 U9908 ( .A1(n8517), .A2(n8241), .B1(n8240), .Y(
        n8291) );
  sky130_fd_sc_hd__o21ai_1 U9909 ( .A1(n8287), .A2(n8291), .B1(n8288), .Y(
        n8242) );
  sky130_fd_sc_hd__xnor2_1 U9910 ( .A(n8243), .B(n8242), .Y(n8244) );
  sky130_fd_sc_hd__nand2_1 U9911 ( .A(n8244), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n8249) );
  sky130_fd_sc_hd__o21ai_1 U9912 ( .A1(pcpi_rs1[6]), .A2(pcpi_rs2[6]), .B1(
        n9872), .Y(n8248) );
  sky130_fd_sc_hd__nand2_1 U9913 ( .A(n9873), .B(n8245), .Y(n8247) );
  sky130_fd_sc_hd__nand3_1 U9914 ( .A(n9382), .B(pcpi_rs1[6]), .C(pcpi_rs2[6]), 
        .Y(n8246) );
  sky130_fd_sc_hd__nand4_1 U9915 ( .A(n8249), .B(n8248), .C(n8247), .D(n8246), 
        .Y(alu_out[6]) );
  sky130_fd_sc_hd__o22ai_1 U9916 ( .A1(n10029), .A2(n9624), .B1(n8251), .B2(
        n9387), .Y(n4013) );
  sky130_fd_sc_hd__clkinv_1 U9917 ( .A(mem_rdata[5]), .Y(n8255) );
  sky130_fd_sc_hd__o22ai_1 U9918 ( .A1(n10025), .A2(n9851), .B1(n8252), .B2(
        n9850), .Y(n8253) );
  sky130_fd_sc_hd__a21oi_1 U9919 ( .A1(mem_rdata[21]), .A2(n9853), .B1(n8253), 
        .Y(n8254) );
  sky130_fd_sc_hd__o21ai_1 U9920 ( .A1(n10017), .A2(n8255), .B1(n8254), .Y(
        n4156) );
  sky130_fd_sc_hd__nand2_1 U9921 ( .A(n8257), .B(n8204), .Y(n8258) );
  sky130_fd_sc_hd__xnor2_1 U9922 ( .A(n8258), .B(n9034), .Y(n8259) );
  sky130_fd_sc_hd__a222oi_1 U9923 ( .A1(n8297), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[5]), .C1(n5794), .C2(n8259), .Y(n8260) );
  sky130_fd_sc_hd__a22oi_1 U9924 ( .A1(decoded_imm_j[5]), .A2(n10086), .B1(
        n10087), .B2(mem_rdata_q[25]), .Y(n8261) );
  sky130_fd_sc_hd__o21ai_1 U9925 ( .A1(n10021), .A2(n10089), .B1(n8261), .Y(
        n2887) );
  sky130_fd_sc_hd__a222oi_1 U9926 ( .A1(n10122), .A2(decoded_imm[5]), .B1(
        decoded_imm_j[5]), .B2(n8608), .C1(n8262), .C2(mem_rdata_q[25]), .Y(
        n8263) );
  sky130_fd_sc_hd__a22oi_1 U9927 ( .A1(\cpuregs[1][5] ), .A2(n8488), .B1(
        \cpuregs[24][5] ), .B2(n8503), .Y(n8267) );
  sky130_fd_sc_hd__a22oi_1 U9928 ( .A1(\cpuregs[20][5] ), .A2(n6059), .B1(
        \cpuregs[29][5] ), .B2(n6137), .Y(n8266) );
  sky130_fd_sc_hd__a22oi_1 U9929 ( .A1(\cpuregs[10][5] ), .A2(n8470), .B1(
        \cpuregs[18][5] ), .B2(n8472), .Y(n8265) );
  sky130_fd_sc_hd__nand2_1 U9930 ( .A(\cpuregs[25][5] ), .B(n8466), .Y(n8264)
         );
  sky130_fd_sc_hd__nand4_1 U9931 ( .A(n8267), .B(n8266), .C(n8265), .D(n8264), 
        .Y(n8283) );
  sky130_fd_sc_hd__a22oi_1 U9932 ( .A1(\cpuregs[2][5] ), .A2(n8479), .B1(
        \cpuregs[28][5] ), .B2(n8490), .Y(n8271) );
  sky130_fd_sc_hd__a22oi_1 U9933 ( .A1(\cpuregs[5][5] ), .A2(n8471), .B1(
        \cpuregs[26][5] ), .B2(n8467), .Y(n8270) );
  sky130_fd_sc_hd__a22oi_1 U9934 ( .A1(\cpuregs[16][5] ), .A2(n8465), .B1(
        \cpuregs[19][5] ), .B2(n6412), .Y(n8269) );
  sky130_fd_sc_hd__a22oi_1 U9935 ( .A1(\cpuregs[7][5] ), .A2(n8477), .B1(
        \cpuregs[23][5] ), .B2(n8464), .Y(n8268) );
  sky130_fd_sc_hd__nand4_1 U9936 ( .A(n8271), .B(n8270), .C(n8269), .D(n8268), 
        .Y(n8282) );
  sky130_fd_sc_hd__a22oi_1 U9937 ( .A1(\cpuregs[15][5] ), .A2(n8501), .B1(
        \cpuregs[30][5] ), .B2(n8500), .Y(n8275) );
  sky130_fd_sc_hd__a22oi_1 U9938 ( .A1(\cpuregs[14][5] ), .A2(n8498), .B1(
        \cpuregs[22][5] ), .B2(n8482), .Y(n8274) );
  sky130_fd_sc_hd__a22oi_1 U9939 ( .A1(\cpuregs[21][5] ), .A2(n8480), .B1(
        \cpuregs[9][5] ), .B2(n8036), .Y(n8273) );
  sky130_fd_sc_hd__a22oi_1 U9940 ( .A1(\cpuregs[3][5] ), .A2(n8499), .B1(
        \cpuregs[31][5] ), .B2(n8487), .Y(n8272) );
  sky130_fd_sc_hd__nand4_1 U9941 ( .A(n8275), .B(n8274), .C(n8273), .D(n8272), 
        .Y(n8281) );
  sky130_fd_sc_hd__a22oi_1 U9942 ( .A1(\cpuregs[8][5] ), .A2(n4233), .B1(
        \cpuregs[13][5] ), .B2(n8478), .Y(n8279) );
  sky130_fd_sc_hd__a22oi_1 U9943 ( .A1(\cpuregs[27][5] ), .A2(n8497), .B1(
        \cpuregs[12][5] ), .B2(n8491), .Y(n8278) );
  sky130_fd_sc_hd__a22oi_1 U9944 ( .A1(\cpuregs[17][5] ), .A2(n8489), .B1(
        \cpuregs[6][5] ), .B2(n8502), .Y(n8277) );
  sky130_fd_sc_hd__a22oi_1 U9945 ( .A1(\cpuregs[4][5] ), .A2(n8492), .B1(
        \cpuregs[11][5] ), .B2(n8481), .Y(n8276) );
  sky130_fd_sc_hd__nand4_1 U9946 ( .A(n8279), .B(n8278), .C(n8277), .D(n8276), 
        .Y(n8280) );
  sky130_fd_sc_hd__nor4_1 U9947 ( .A(n8283), .B(n8282), .C(n8281), .D(n8280), 
        .Y(n8285) );
  sky130_fd_sc_hd__a22oi_1 U9948 ( .A1(pcpi_rs2[5]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[5]), .Y(n8284) );
  sky130_fd_sc_hd__o21ai_1 U9949 ( .A1(n8514), .A2(n8285), .B1(n8284), .Y(
        n3953) );
  sky130_fd_sc_hd__o21ai_1 U9950 ( .A1(n8292), .A2(n8683), .B1(n8386), .Y(
        n8295) );
  sky130_fd_sc_hd__nand2_1 U9951 ( .A(n8289), .B(n8288), .Y(n8290) );
  sky130_fd_sc_hd__xor2_1 U9952 ( .A(n8291), .B(n8290), .X(n8293) );
  sky130_fd_sc_hd__a222oi_1 U9953 ( .A1(n8295), .A2(n8294), .B1(
        is_lui_auipc_jal_jalr_addi_add_sub), .B2(n8293), .C1(n9382), .C2(n8292), .Y(n8296) );
  sky130_fd_sc_hd__o22ai_1 U9954 ( .A1(n10029), .A2(n9550), .B1(n8298), .B2(
        n9387), .Y(n4014) );
  sky130_fd_sc_hd__clkinv_1 U9955 ( .A(mem_rdata[4]), .Y(n8302) );
  sky130_fd_sc_hd__o22ai_1 U9956 ( .A1(n8299), .A2(n9850), .B1(n10024), .B2(
        n9851), .Y(n8300) );
  sky130_fd_sc_hd__a21oi_1 U9957 ( .A1(mem_rdata[20]), .A2(n9853), .B1(n8300), 
        .Y(n8301) );
  sky130_fd_sc_hd__o21ai_1 U9958 ( .A1(n10017), .A2(n8302), .B1(n8301), .Y(
        n4155) );
  sky130_fd_sc_hd__nand2_1 U9959 ( .A(n8304), .B(n8303), .Y(n8306) );
  sky130_fd_sc_hd__xnor2_1 U9960 ( .A(n8306), .B(n8305), .Y(n8307) );
  sky130_fd_sc_hd__nand2_1 U9961 ( .A(n8307), .B(n4639), .Y(n8312) );
  sky130_fd_sc_hd__a22o_1 U9962 ( .A1(n9859), .A2(mem_rdata_word[4]), .B1(
        n9858), .B2(pcpi_rs1[4]), .X(n8308) );
  sky130_fd_sc_hd__a21oi_1 U9963 ( .A1(n9861), .A2(count_cycle[36]), .B1(n8308), .Y(n8311) );
  sky130_fd_sc_hd__a22oi_1 U9964 ( .A1(n9857), .A2(count_instr[4]), .B1(n9856), 
        .B2(count_instr[36]), .Y(n8310) );
  sky130_fd_sc_hd__nand2_1 U9965 ( .A(n9860), .B(count_cycle[4]), .Y(n8309) );
  sky130_fd_sc_hd__nand4_1 U9966 ( .A(n8312), .B(n8311), .C(n8310), .D(n8309), 
        .Y(N1881) );
  sky130_fd_sc_hd__nand2_1 U9967 ( .A(n8315), .B(n8314), .Y(n8319) );
  sky130_fd_sc_hd__inv_1 U9968 ( .A(n8317), .Y(n8691) );
  sky130_fd_sc_hd__o21ai_1 U9969 ( .A1(n8316), .A2(n8691), .B1(n8688), .Y(
        n8318) );
  sky130_fd_sc_hd__xnor2_1 U9970 ( .A(n8319), .B(n8318), .Y(n8320) );
  sky130_fd_sc_hd__a222oi_1 U9971 ( .A1(n8400), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[4]), .C1(n5794), .C2(n8320), .Y(n8321) );
  sky130_fd_sc_hd__xnor2_1 U9972 ( .A(n8323), .B(n9549), .Y(n8324) );
  sky130_fd_sc_hd__nand2_1 U9973 ( .A(n8324), .B(n9813), .Y(n8326) );
  sky130_fd_sc_hd__a22oi_1 U9974 ( .A1(n9816), .A2(reg_out[4]), .B1(n9815), 
        .B2(alu_out_q[4]), .Y(n8325) );
  sky130_fd_sc_hd__nand2_1 U9975 ( .A(n4179), .B(\cpuregs[4][4] ), .Y(n8327)
         );
  sky130_fd_sc_hd__o21ai_1 U9976 ( .A1(n8358), .A2(n4179), .B1(n8327), .Y(
        n3775) );
  sky130_fd_sc_hd__nand2_1 U9977 ( .A(n4226), .B(\cpuregs[12][4] ), .Y(n8328)
         );
  sky130_fd_sc_hd__o21ai_1 U9978 ( .A1(n8358), .A2(n4226), .B1(n8328), .Y(
        n3783) );
  sky130_fd_sc_hd__nand2_1 U9979 ( .A(n4197), .B(\cpuregs[16][4] ), .Y(n8329)
         );
  sky130_fd_sc_hd__o21ai_1 U9980 ( .A1(n8358), .A2(n4197), .B1(n8329), .Y(
        n3787) );
  sky130_fd_sc_hd__nand2_1 U9981 ( .A(n4183), .B(\cpuregs[8][4] ), .Y(n8330)
         );
  sky130_fd_sc_hd__o21ai_1 U9982 ( .A1(n8358), .A2(n4183), .B1(n8330), .Y(
        n3779) );
  sky130_fd_sc_hd__nand2_1 U9983 ( .A(n4219), .B(\cpuregs[28][4] ), .Y(n8331)
         );
  sky130_fd_sc_hd__o21ai_1 U9984 ( .A1(n8358), .A2(n4219), .B1(n8331), .Y(
        n3799) );
  sky130_fd_sc_hd__nand2_1 U9985 ( .A(n10058), .B(\cpuregs[20][4] ), .Y(n8332)
         );
  sky130_fd_sc_hd__o21ai_1 U9986 ( .A1(n8358), .A2(n10058), .B1(n8332), .Y(
        n3791) );
  sky130_fd_sc_hd__nand2_1 U9987 ( .A(n10057), .B(\cpuregs[24][4] ), .Y(n8333)
         );
  sky130_fd_sc_hd__o21ai_1 U9988 ( .A1(n8358), .A2(n10057), .B1(n8333), .Y(
        n3795) );
  sky130_fd_sc_hd__nand2_1 U9989 ( .A(n9772), .B(\cpuregs[6][4] ), .Y(n8334)
         );
  sky130_fd_sc_hd__o21ai_1 U9990 ( .A1(n8358), .A2(n9772), .B1(n8334), .Y(
        n3777) );
  sky130_fd_sc_hd__nand2_1 U9991 ( .A(n6897), .B(\cpuregs[14][4] ), .Y(n8335)
         );
  sky130_fd_sc_hd__o21ai_1 U9992 ( .A1(n8358), .A2(n6897), .B1(n8335), .Y(
        n3785) );
  sky130_fd_sc_hd__nand2_1 U9993 ( .A(n9820), .B(\cpuregs[18][4] ), .Y(n8336)
         );
  sky130_fd_sc_hd__o21ai_1 U9994 ( .A1(n8358), .A2(n9820), .B1(n8336), .Y(
        n3789) );
  sky130_fd_sc_hd__nand2_1 U9995 ( .A(n4184), .B(\cpuregs[10][4] ), .Y(n8337)
         );
  sky130_fd_sc_hd__o21ai_1 U9996 ( .A1(n8358), .A2(n4184), .B1(n8337), .Y(
        n3781) );
  sky130_fd_sc_hd__nand2_1 U9997 ( .A(n4177), .B(\cpuregs[30][4] ), .Y(n8338)
         );
  sky130_fd_sc_hd__o21ai_1 U9998 ( .A1(n8358), .A2(n4177), .B1(n8338), .Y(
        n3801) );
  sky130_fd_sc_hd__nand2_1 U9999 ( .A(n7084), .B(\cpuregs[22][4] ), .Y(n8339)
         );
  sky130_fd_sc_hd__o21ai_1 U10000 ( .A1(n8358), .A2(n7084), .B1(n8339), .Y(
        n3793) );
  sky130_fd_sc_hd__nand2_1 U10001 ( .A(n9621), .B(\cpuregs[26][4] ), .Y(n8340)
         );
  sky130_fd_sc_hd__o21ai_1 U10002 ( .A1(n8358), .A2(n9621), .B1(n8340), .Y(
        n3797) );
  sky130_fd_sc_hd__nand2_1 U10003 ( .A(n4178), .B(\cpuregs[2][4] ), .Y(n8341)
         );
  sky130_fd_sc_hd__o21ai_1 U10004 ( .A1(n8358), .A2(n4178), .B1(n8341), .Y(
        n3773) );
  sky130_fd_sc_hd__nand2_1 U10005 ( .A(n4180), .B(\cpuregs[5][4] ), .Y(n8342)
         );
  sky130_fd_sc_hd__o21ai_1 U10006 ( .A1(n8358), .A2(n4180), .B1(n8342), .Y(
        n3776) );
  sky130_fd_sc_hd__nand2_1 U10007 ( .A(n4186), .B(\cpuregs[13][4] ), .Y(n8343)
         );
  sky130_fd_sc_hd__o21ai_1 U10008 ( .A1(n8358), .A2(n4186), .B1(n8343), .Y(
        n3784) );
  sky130_fd_sc_hd__nand2_1 U10009 ( .A(n4195), .B(\cpuregs[17][4] ), .Y(n8344)
         );
  sky130_fd_sc_hd__o21ai_1 U10010 ( .A1(n8358), .A2(n4195), .B1(n8344), .Y(
        n3788) );
  sky130_fd_sc_hd__nand2_1 U10011 ( .A(n7452), .B(\cpuregs[9][4] ), .Y(n8345)
         );
  sky130_fd_sc_hd__o21ai_1 U10012 ( .A1(n8358), .A2(n7452), .B1(n8345), .Y(
        n3780) );
  sky130_fd_sc_hd__nand2_1 U10013 ( .A(n4176), .B(\cpuregs[29][4] ), .Y(n8346)
         );
  sky130_fd_sc_hd__o21ai_1 U10014 ( .A1(n8358), .A2(n4176), .B1(n8346), .Y(
        n3800) );
  sky130_fd_sc_hd__nand2_1 U10015 ( .A(n4174), .B(\cpuregs[21][4] ), .Y(n8347)
         );
  sky130_fd_sc_hd__o21ai_1 U10016 ( .A1(n8358), .A2(n4174), .B1(n8347), .Y(
        n3792) );
  sky130_fd_sc_hd__nand2_1 U10017 ( .A(n4192), .B(\cpuregs[25][4] ), .Y(n8348)
         );
  sky130_fd_sc_hd__o21ai_1 U10018 ( .A1(n8358), .A2(n4192), .B1(n8348), .Y(
        n3796) );
  sky130_fd_sc_hd__nand2_1 U10019 ( .A(n6396), .B(\cpuregs[1][4] ), .Y(n8349)
         );
  sky130_fd_sc_hd__o21ai_1 U10020 ( .A1(n8358), .A2(n6396), .B1(n8349), .Y(
        n3772) );
  sky130_fd_sc_hd__nand2_1 U10021 ( .A(n4199), .B(\cpuregs[7][4] ), .Y(n8350)
         );
  sky130_fd_sc_hd__o21ai_1 U10022 ( .A1(n8358), .A2(n4199), .B1(n8350), .Y(
        n3778) );
  sky130_fd_sc_hd__nand2_1 U10023 ( .A(n7069), .B(\cpuregs[15][4] ), .Y(n8351)
         );
  sky130_fd_sc_hd__o21ai_1 U10024 ( .A1(n8358), .A2(n7069), .B1(n8351), .Y(
        n3786) );
  sky130_fd_sc_hd__nand2_1 U10025 ( .A(n4194), .B(\cpuregs[19][4] ), .Y(n8352)
         );
  sky130_fd_sc_hd__o21ai_1 U10026 ( .A1(n8358), .A2(n4194), .B1(n8352), .Y(
        n3790) );
  sky130_fd_sc_hd__nand2_1 U10027 ( .A(n4185), .B(\cpuregs[11][4] ), .Y(n8353)
         );
  sky130_fd_sc_hd__o21ai_1 U10028 ( .A1(n8358), .A2(n4185), .B1(n8353), .Y(
        n3782) );
  sky130_fd_sc_hd__nand2_1 U10029 ( .A(n7247), .B(\cpuregs[31][4] ), .Y(n8354)
         );
  sky130_fd_sc_hd__o21ai_1 U10030 ( .A1(n8358), .A2(n7247), .B1(n8354), .Y(
        n3802) );
  sky130_fd_sc_hd__nand2_1 U10031 ( .A(n4173), .B(\cpuregs[23][4] ), .Y(n8355)
         );
  sky130_fd_sc_hd__o21ai_1 U10032 ( .A1(n8358), .A2(n4173), .B1(n8355), .Y(
        n3794) );
  sky130_fd_sc_hd__nand2_1 U10033 ( .A(n4175), .B(\cpuregs[27][4] ), .Y(n8356)
         );
  sky130_fd_sc_hd__o21ai_1 U10034 ( .A1(n8358), .A2(n4175), .B1(n8356), .Y(
        n3798) );
  sky130_fd_sc_hd__nand2_1 U10035 ( .A(n4201), .B(\cpuregs[3][4] ), .Y(n8357)
         );
  sky130_fd_sc_hd__o21ai_1 U10036 ( .A1(n8358), .A2(n4201), .B1(n8357), .Y(
        n3774) );
  sky130_fd_sc_hd__a22oi_1 U10037 ( .A1(decoded_imm[4]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[4]), .Y(n8361) );
  sky130_fd_sc_hd__nand2_1 U10038 ( .A(n8609), .B(mem_rdata_q[11]), .Y(n8360)
         );
  sky130_fd_sc_hd__o211ai_1 U10039 ( .A1(n8613), .A2(n8362), .B1(n8361), .C1(
        n8360), .Y(n2868) );
  sky130_fd_sc_hd__a22oi_1 U10040 ( .A1(n8656), .A2(\cpuregs[25][4] ), .B1(
        n6001), .B2(\cpuregs[1][4] ), .Y(n8366) );
  sky130_fd_sc_hd__a22oi_1 U10041 ( .A1(n8658), .A2(\cpuregs[21][4] ), .B1(
        n8657), .B2(\cpuregs[17][4] ), .Y(n8365) );
  sky130_fd_sc_hd__a22oi_1 U10042 ( .A1(n8660), .A2(\cpuregs[5][4] ), .B1(
        n4215), .B2(\cpuregs[9][4] ), .Y(n8364) );
  sky130_fd_sc_hd__a22oi_1 U10043 ( .A1(n8662), .A2(\cpuregs[29][4] ), .B1(
        n8661), .B2(\cpuregs[13][4] ), .Y(n8363) );
  sky130_fd_sc_hd__nand4_1 U10044 ( .A(n8366), .B(n8365), .C(n8364), .D(n8363), 
        .Y(n8372) );
  sky130_fd_sc_hd__a22oi_1 U10045 ( .A1(n8656), .A2(\cpuregs[27][4] ), .B1(
        n6001), .B2(\cpuregs[3][4] ), .Y(n8370) );
  sky130_fd_sc_hd__a22oi_1 U10046 ( .A1(n8658), .A2(\cpuregs[23][4] ), .B1(
        n8657), .B2(\cpuregs[19][4] ), .Y(n8369) );
  sky130_fd_sc_hd__a22oi_1 U10047 ( .A1(n8660), .A2(\cpuregs[7][4] ), .B1(
        n4215), .B2(\cpuregs[11][4] ), .Y(n8368) );
  sky130_fd_sc_hd__a22oi_1 U10048 ( .A1(n8662), .A2(\cpuregs[31][4] ), .B1(
        n8661), .B2(\cpuregs[15][4] ), .Y(n8367) );
  sky130_fd_sc_hd__nand4_1 U10049 ( .A(n8370), .B(n8369), .C(n8368), .D(n8367), 
        .Y(n8371) );
  sky130_fd_sc_hd__a22o_1 U10050 ( .A1(n8372), .A2(n8649), .B1(n8669), .B2(
        n8371), .X(n8384) );
  sky130_fd_sc_hd__a22oi_1 U10051 ( .A1(n8657), .A2(\cpuregs[16][4] ), .B1(
        n4215), .B2(\cpuregs[8][4] ), .Y(n8376) );
  sky130_fd_sc_hd__a22oi_1 U10052 ( .A1(n8658), .A2(\cpuregs[20][4] ), .B1(
        n8656), .B2(\cpuregs[24][4] ), .Y(n8375) );
  sky130_fd_sc_hd__a22oi_1 U10053 ( .A1(n8660), .A2(\cpuregs[4][4] ), .B1(
        n8662), .B2(\cpuregs[28][4] ), .Y(n8374) );
  sky130_fd_sc_hd__nand2_1 U10054 ( .A(n8661), .B(\cpuregs[12][4] ), .Y(n8373)
         );
  sky130_fd_sc_hd__nand4_1 U10055 ( .A(n8376), .B(n8375), .C(n8374), .D(n8373), 
        .Y(n8382) );
  sky130_fd_sc_hd__a22oi_1 U10056 ( .A1(n8656), .A2(\cpuregs[26][4] ), .B1(
        n6001), .B2(\cpuregs[2][4] ), .Y(n8380) );
  sky130_fd_sc_hd__a22oi_1 U10057 ( .A1(n8658), .A2(\cpuregs[22][4] ), .B1(
        n8657), .B2(\cpuregs[18][4] ), .Y(n8379) );
  sky130_fd_sc_hd__a22oi_1 U10058 ( .A1(n8660), .A2(\cpuregs[6][4] ), .B1(
        n4215), .B2(\cpuregs[10][4] ), .Y(n8378) );
  sky130_fd_sc_hd__a22oi_1 U10059 ( .A1(n8662), .A2(\cpuregs[30][4] ), .B1(
        n8661), .B2(\cpuregs[14][4] ), .Y(n8377) );
  sky130_fd_sc_hd__nand4_1 U10060 ( .A(n8380), .B(n8379), .C(n8378), .D(n8377), 
        .Y(n8381) );
  sky130_fd_sc_hd__a22o_1 U10061 ( .A1(n8382), .A2(n8650), .B1(n8668), .B2(
        n8381), .X(n8383) );
  sky130_fd_sc_hd__nor4_1 U10062 ( .A(is_lb_lh_lw_lbu_lhu), .B(
        is_slli_srli_srai), .C(is_jalr_addi_slti_sltiu_xori_ori_andi), .D(
        n9302), .Y(n9439) );
  sky130_fd_sc_hd__o21ai_1 U10063 ( .A1(n8384), .A2(n8383), .B1(n9439), .Y(
        n9429) );
  sky130_fd_sc_hd__a22oi_1 U10064 ( .A1(pcpi_rs2[4]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[4]), .Y(n8385) );
  sky130_fd_sc_hd__o21ai_1 U10065 ( .A1(n10060), .A2(n9429), .B1(n8385), .Y(
        n3954) );
  sky130_fd_sc_hd__o21ai_1 U10066 ( .A1(n8395), .A2(n8683), .B1(n8386), .Y(
        n8398) );
  sky130_fd_sc_hd__a21oi_1 U10067 ( .A1(n8517), .A2(n8516), .B1(n8389), .Y(
        n8394) );
  sky130_fd_sc_hd__nand2_1 U10068 ( .A(n8392), .B(n8391), .Y(n8393) );
  sky130_fd_sc_hd__xor2_1 U10069 ( .A(n8394), .B(n8393), .X(n8396) );
  sky130_fd_sc_hd__a222oi_1 U10070 ( .A1(n8398), .A2(n8397), .B1(
        is_lui_auipc_jal_jalr_addi_add_sub), .B2(n8396), .C1(n8395), .C2(n9382), .Y(n8399) );
  sky130_fd_sc_hd__a22o_1 U10071 ( .A1(n10055), .A2(n8400), .B1(n9530), .B2(
        reg_pc[4]), .X(n4015) );
  sky130_fd_sc_hd__a222oi_1 U10072 ( .A1(reg_out[29]), .A2(n9816), .B1(
        alu_out_q[29]), .B2(n9815), .C1(n8403), .C2(n9813), .Y(n8417) );
  sky130_fd_sc_hd__nand2_1 U10073 ( .A(n7084), .B(\cpuregs[22][29] ), .Y(n8404) );
  sky130_fd_sc_hd__o21ai_1 U10074 ( .A1(n7084), .A2(n4208), .B1(n8404), .Y(
        n3018) );
  sky130_fd_sc_hd__nand2_1 U10075 ( .A(n4226), .B(\cpuregs[12][29] ), .Y(n8405) );
  sky130_fd_sc_hd__o21ai_1 U10076 ( .A1(n4226), .A2(n4208), .B1(n8405), .Y(
        n3008) );
  sky130_fd_sc_hd__nand2_1 U10077 ( .A(n4178), .B(\cpuregs[2][29] ), .Y(n8406)
         );
  sky130_fd_sc_hd__o21ai_1 U10078 ( .A1(n4178), .A2(n4208), .B1(n8406), .Y(
        n2998) );
  sky130_fd_sc_hd__nand2_1 U10079 ( .A(n7452), .B(\cpuregs[9][29] ), .Y(n8407)
         );
  sky130_fd_sc_hd__o21ai_1 U10080 ( .A1(n7452), .A2(n4208), .B1(n8407), .Y(
        n3005) );
  sky130_fd_sc_hd__nand2_1 U10081 ( .A(n7069), .B(\cpuregs[15][29] ), .Y(n8408) );
  sky130_fd_sc_hd__o21ai_1 U10082 ( .A1(n7069), .A2(n4208), .B1(n8408), .Y(
        n3011) );
  sky130_fd_sc_hd__nand2_1 U10083 ( .A(n4194), .B(\cpuregs[19][29] ), .Y(n8409) );
  sky130_fd_sc_hd__o21ai_1 U10084 ( .A1(n4194), .A2(n4208), .B1(n8409), .Y(
        n3015) );
  sky130_fd_sc_hd__nand2_1 U10085 ( .A(n4199), .B(\cpuregs[7][29] ), .Y(n8410)
         );
  sky130_fd_sc_hd__o21ai_1 U10086 ( .A1(n4199), .A2(n4208), .B1(n8410), .Y(
        n3003) );
  sky130_fd_sc_hd__nand2_1 U10087 ( .A(n4180), .B(\cpuregs[5][29] ), .Y(n8411)
         );
  sky130_fd_sc_hd__o21ai_1 U10088 ( .A1(n4180), .A2(n4208), .B1(n8411), .Y(
        n3001) );
  sky130_fd_sc_hd__nand2_1 U10089 ( .A(n9820), .B(\cpuregs[18][29] ), .Y(n8412) );
  sky130_fd_sc_hd__o21ai_1 U10090 ( .A1(n9820), .A2(n4208), .B1(n8412), .Y(
        n3014) );
  sky130_fd_sc_hd__nand2_1 U10091 ( .A(n4219), .B(\cpuregs[28][29] ), .Y(n8413) );
  sky130_fd_sc_hd__o21ai_1 U10092 ( .A1(n4219), .A2(n4208), .B1(n8413), .Y(
        n3024) );
  sky130_fd_sc_hd__nand2_1 U10093 ( .A(n4201), .B(\cpuregs[3][29] ), .Y(n8414)
         );
  sky130_fd_sc_hd__o21ai_1 U10094 ( .A1(n4201), .A2(n4208), .B1(n8414), .Y(
        n2999) );
  sky130_fd_sc_hd__nand2_1 U10095 ( .A(n4197), .B(\cpuregs[16][29] ), .Y(n8415) );
  sky130_fd_sc_hd__o21ai_1 U10096 ( .A1(n4197), .A2(n4208), .B1(n8415), .Y(
        n3012) );
  sky130_fd_sc_hd__nand2_1 U10097 ( .A(n9621), .B(\cpuregs[26][29] ), .Y(n8416) );
  sky130_fd_sc_hd__o21ai_1 U10098 ( .A1(n9621), .A2(n4208), .B1(n8416), .Y(
        n3022) );
  sky130_fd_sc_hd__nand2_1 U10099 ( .A(n4183), .B(\cpuregs[8][29] ), .Y(n8418)
         );
  sky130_fd_sc_hd__o21ai_1 U10100 ( .A1(n4183), .A2(n4208), .B1(n8418), .Y(
        n3004) );
  sky130_fd_sc_hd__nand2_1 U10101 ( .A(n10057), .B(\cpuregs[24][29] ), .Y(
        n8419) );
  sky130_fd_sc_hd__o21ai_1 U10102 ( .A1(n10057), .A2(n4208), .B1(n8419), .Y(
        n3020) );
  sky130_fd_sc_hd__nand2_1 U10103 ( .A(n4174), .B(\cpuregs[21][29] ), .Y(n8420) );
  sky130_fd_sc_hd__o21ai_1 U10104 ( .A1(n4174), .A2(n4208), .B1(n8420), .Y(
        n3017) );
  sky130_fd_sc_hd__nand2_1 U10105 ( .A(n4175), .B(\cpuregs[27][29] ), .Y(n8421) );
  sky130_fd_sc_hd__o21ai_1 U10106 ( .A1(n4175), .A2(n4208), .B1(n8421), .Y(
        n3023) );
  sky130_fd_sc_hd__nand2_1 U10107 ( .A(n4192), .B(\cpuregs[25][29] ), .Y(n8422) );
  sky130_fd_sc_hd__o21ai_1 U10108 ( .A1(n4192), .A2(n4208), .B1(n8422), .Y(
        n3021) );
  sky130_fd_sc_hd__nand2_1 U10109 ( .A(n4186), .B(\cpuregs[13][29] ), .Y(n8423) );
  sky130_fd_sc_hd__o21ai_1 U10110 ( .A1(n4186), .A2(n4208), .B1(n8423), .Y(
        n3009) );
  sky130_fd_sc_hd__nand2_1 U10111 ( .A(n4184), .B(\cpuregs[10][29] ), .Y(n8424) );
  sky130_fd_sc_hd__o21ai_1 U10112 ( .A1(n4184), .A2(n4208), .B1(n8424), .Y(
        n3006) );
  sky130_fd_sc_hd__nand2_1 U10113 ( .A(n4185), .B(\cpuregs[11][29] ), .Y(n8425) );
  sky130_fd_sc_hd__o21ai_1 U10114 ( .A1(n4185), .A2(n4208), .B1(n8425), .Y(
        n3007) );
  sky130_fd_sc_hd__nand2_1 U10115 ( .A(n6897), .B(\cpuregs[14][29] ), .Y(n8426) );
  sky130_fd_sc_hd__o21ai_1 U10116 ( .A1(n6897), .A2(n4208), .B1(n8426), .Y(
        n3010) );
  sky130_fd_sc_hd__nand2_1 U10117 ( .A(n4176), .B(\cpuregs[29][29] ), .Y(n8427) );
  sky130_fd_sc_hd__o21ai_1 U10118 ( .A1(n4176), .A2(n4208), .B1(n8427), .Y(
        n3025) );
  sky130_fd_sc_hd__nand2_1 U10119 ( .A(n6396), .B(\cpuregs[1][29] ), .Y(n8428)
         );
  sky130_fd_sc_hd__o21ai_1 U10120 ( .A1(n6396), .A2(n4208), .B1(n8428), .Y(
        n2997) );
  sky130_fd_sc_hd__nand2_1 U10121 ( .A(n4177), .B(\cpuregs[30][29] ), .Y(n8429) );
  sky130_fd_sc_hd__o21ai_1 U10122 ( .A1(n4177), .A2(n4208), .B1(n8429), .Y(
        n3026) );
  sky130_fd_sc_hd__nand2_1 U10123 ( .A(n4173), .B(\cpuregs[23][29] ), .Y(n8430) );
  sky130_fd_sc_hd__o21ai_1 U10124 ( .A1(n4173), .A2(n4208), .B1(n8430), .Y(
        n3019) );
  sky130_fd_sc_hd__nand2_1 U10125 ( .A(n4195), .B(\cpuregs[17][29] ), .Y(n8431) );
  sky130_fd_sc_hd__o21ai_1 U10126 ( .A1(n4195), .A2(n4208), .B1(n8431), .Y(
        n3013) );
  sky130_fd_sc_hd__nand2_1 U10127 ( .A(n10058), .B(\cpuregs[20][29] ), .Y(
        n8432) );
  sky130_fd_sc_hd__o21ai_1 U10128 ( .A1(n10058), .A2(n4208), .B1(n8432), .Y(
        n3016) );
  sky130_fd_sc_hd__nand2_1 U10129 ( .A(n7247), .B(\cpuregs[31][29] ), .Y(n8433) );
  sky130_fd_sc_hd__o21ai_1 U10130 ( .A1(n7247), .A2(n4208), .B1(n8433), .Y(
        n3027) );
  sky130_fd_sc_hd__nand2_1 U10131 ( .A(n9209), .B(\cpuregs[6][29] ), .Y(n8434)
         );
  sky130_fd_sc_hd__o21ai_1 U10132 ( .A1(n9772), .A2(n4208), .B1(n8434), .Y(
        n3002) );
  sky130_fd_sc_hd__nand2_1 U10133 ( .A(n4179), .B(\cpuregs[4][29] ), .Y(n8435)
         );
  sky130_fd_sc_hd__o21ai_1 U10134 ( .A1(n4179), .A2(n4208), .B1(n8435), .Y(
        n3000) );
  sky130_fd_sc_hd__a22oi_1 U10135 ( .A1(decoded_imm[31]), .A2(n10122), .B1(
        n5989), .B2(mem_rdata_q[31]), .Y(n8436) );
  sky130_fd_sc_hd__nand2_1 U10136 ( .A(n8437), .B(n8436), .Y(n2841) );
  sky130_fd_sc_hd__a22oi_1 U10137 ( .A1(n8501), .A2(\cpuregs[15][31] ), .B1(
        n8465), .B2(\cpuregs[16][31] ), .Y(n8441) );
  sky130_fd_sc_hd__a22oi_1 U10138 ( .A1(\cpuregs[23][31] ), .A2(n8464), .B1(
        n6059), .B2(\cpuregs[20][31] ), .Y(n8440) );
  sky130_fd_sc_hd__a22oi_1 U10139 ( .A1(\cpuregs[28][31] ), .A2(n8490), .B1(
        n4233), .B2(\cpuregs[8][31] ), .Y(n8439) );
  sky130_fd_sc_hd__nand2_1 U10140 ( .A(n8471), .B(\cpuregs[5][31] ), .Y(n8438)
         );
  sky130_fd_sc_hd__nand4_1 U10141 ( .A(n8441), .B(n8440), .C(n8439), .D(n8438), 
        .Y(n8457) );
  sky130_fd_sc_hd__a22oi_1 U10142 ( .A1(\cpuregs[7][31] ), .A2(n8477), .B1(
        n6137), .B2(\cpuregs[29][31] ), .Y(n8445) );
  sky130_fd_sc_hd__a22oi_1 U10143 ( .A1(n6412), .A2(\cpuregs[19][31] ), .B1(
        n8036), .B2(\cpuregs[9][31] ), .Y(n8444) );
  sky130_fd_sc_hd__a22oi_1 U10144 ( .A1(\cpuregs[30][31] ), .A2(n8500), .B1(
        n8470), .B2(\cpuregs[10][31] ), .Y(n8443) );
  sky130_fd_sc_hd__a22oi_1 U10145 ( .A1(n8492), .A2(\cpuregs[4][31] ), .B1(
        n8478), .B2(\cpuregs[13][31] ), .Y(n8442) );
  sky130_fd_sc_hd__nand4_1 U10146 ( .A(n8445), .B(n8444), .C(n8443), .D(n8442), 
        .Y(n8456) );
  sky130_fd_sc_hd__a22oi_1 U10147 ( .A1(n8472), .A2(\cpuregs[18][31] ), .B1(
        n8467), .B2(\cpuregs[26][31] ), .Y(n8449) );
  sky130_fd_sc_hd__a22oi_1 U10148 ( .A1(\cpuregs[21][31] ), .A2(n8480), .B1(
        n8481), .B2(\cpuregs[11][31] ), .Y(n8448) );
  sky130_fd_sc_hd__a22oi_1 U10149 ( .A1(\cpuregs[14][31] ), .A2(n8498), .B1(
        n8488), .B2(\cpuregs[1][31] ), .Y(n8447) );
  sky130_fd_sc_hd__a22oi_1 U10150 ( .A1(n8489), .A2(\cpuregs[17][31] ), .B1(
        n8499), .B2(\cpuregs[3][31] ), .Y(n8446) );
  sky130_fd_sc_hd__nand4_1 U10151 ( .A(n8449), .B(n8448), .C(n8447), .D(n8446), 
        .Y(n8455) );
  sky130_fd_sc_hd__a22oi_1 U10152 ( .A1(\cpuregs[22][31] ), .A2(n8482), .B1(
        n8466), .B2(\cpuregs[25][31] ), .Y(n8453) );
  sky130_fd_sc_hd__a22oi_1 U10153 ( .A1(n8503), .A2(\cpuregs[24][31] ), .B1(
        n8479), .B2(\cpuregs[2][31] ), .Y(n8452) );
  sky130_fd_sc_hd__a22oi_1 U10154 ( .A1(n8502), .A2(\cpuregs[6][31] ), .B1(
        n8491), .B2(\cpuregs[12][31] ), .Y(n8451) );
  sky130_fd_sc_hd__a22oi_1 U10155 ( .A1(\cpuregs[31][31] ), .A2(n8487), .B1(
        n8497), .B2(\cpuregs[27][31] ), .Y(n8450) );
  sky130_fd_sc_hd__nand4_1 U10156 ( .A(n8453), .B(n8452), .C(n8451), .D(n8450), 
        .Y(n8454) );
  sky130_fd_sc_hd__nor4_1 U10157 ( .A(n8457), .B(n8456), .C(n8455), .D(n8454), 
        .Y(n8459) );
  sky130_fd_sc_hd__a22oi_1 U10158 ( .A1(pcpi_rs2[31]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[31]), .Y(n8458) );
  sky130_fd_sc_hd__o21ai_1 U10159 ( .A1(n8514), .A2(n8459), .B1(n8458), .Y(
        n3927) );
  sky130_fd_sc_hd__a22oi_1 U10160 ( .A1(decoded_imm_j[7]), .A2(n10086), .B1(
        n10087), .B2(mem_rdata_q[27]), .Y(n8460) );
  sky130_fd_sc_hd__o21ai_1 U10161 ( .A1(n10023), .A2(n10089), .B1(n8460), .Y(
        n2885) );
  sky130_fd_sc_hd__a22oi_1 U10162 ( .A1(decoded_imm[7]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[7]), .Y(n8461) );
  sky130_fd_sc_hd__o21ai_1 U10163 ( .A1(n8463), .A2(n8462), .B1(n8461), .Y(
        n2865) );
  sky130_fd_sc_hd__a22oi_1 U10164 ( .A1(n6059), .A2(\cpuregs[20][7] ), .B1(
        n8464), .B2(\cpuregs[23][7] ), .Y(n8476) );
  sky130_fd_sc_hd__a22oi_1 U10165 ( .A1(n8466), .A2(\cpuregs[25][7] ), .B1(
        n8465), .B2(\cpuregs[16][7] ), .Y(n8475) );
  sky130_fd_sc_hd__a2bb2oi_1 U10166 ( .B1(n8470), .B2(\cpuregs[10][7] ), 
        .A1_N(n8469), .A2_N(n8468), .Y(n8474) );
  sky130_fd_sc_hd__a22oi_1 U10167 ( .A1(n8472), .A2(\cpuregs[18][7] ), .B1(
        n8471), .B2(\cpuregs[5][7] ), .Y(n8473) );
  sky130_fd_sc_hd__nand4_1 U10168 ( .A(n8476), .B(n8475), .C(n8474), .D(n8473), 
        .Y(n8511) );
  sky130_fd_sc_hd__a22oi_1 U10169 ( .A1(n8036), .A2(\cpuregs[9][7] ), .B1(
        n8477), .B2(\cpuregs[7][7] ), .Y(n8486) );
  sky130_fd_sc_hd__a22oi_1 U10170 ( .A1(n4233), .A2(\cpuregs[8][7] ), .B1(
        n8478), .B2(\cpuregs[13][7] ), .Y(n8485) );
  sky130_fd_sc_hd__a22oi_1 U10171 ( .A1(n8480), .A2(\cpuregs[21][7] ), .B1(
        n8479), .B2(\cpuregs[2][7] ), .Y(n8484) );
  sky130_fd_sc_hd__a22oi_1 U10172 ( .A1(n8482), .A2(\cpuregs[22][7] ), .B1(
        n8481), .B2(\cpuregs[11][7] ), .Y(n8483) );
  sky130_fd_sc_hd__nand4_1 U10173 ( .A(n8486), .B(n8485), .C(n8484), .D(n8483), 
        .Y(n8510) );
  sky130_fd_sc_hd__a22oi_1 U10174 ( .A1(n8488), .A2(\cpuregs[1][7] ), .B1(
        n8487), .B2(\cpuregs[31][7] ), .Y(n8496) );
  sky130_fd_sc_hd__a22oi_1 U10175 ( .A1(n8490), .A2(\cpuregs[28][7] ), .B1(
        n8489), .B2(\cpuregs[17][7] ), .Y(n8495) );
  sky130_fd_sc_hd__a22oi_1 U10176 ( .A1(n6137), .A2(\cpuregs[29][7] ), .B1(
        n8491), .B2(\cpuregs[12][7] ), .Y(n8494) );
  sky130_fd_sc_hd__nand2_1 U10177 ( .A(n8492), .B(\cpuregs[4][7] ), .Y(n8493)
         );
  sky130_fd_sc_hd__nand4_1 U10178 ( .A(n8496), .B(n8495), .C(n8494), .D(n8493), 
        .Y(n8509) );
  sky130_fd_sc_hd__a22oi_1 U10179 ( .A1(n8498), .A2(\cpuregs[14][7] ), .B1(
        n8497), .B2(\cpuregs[27][7] ), .Y(n8507) );
  sky130_fd_sc_hd__a22oi_1 U10180 ( .A1(n8500), .A2(\cpuregs[30][7] ), .B1(
        n8499), .B2(\cpuregs[3][7] ), .Y(n8506) );
  sky130_fd_sc_hd__a22oi_1 U10181 ( .A1(n8501), .A2(\cpuregs[15][7] ), .B1(
        n6412), .B2(\cpuregs[19][7] ), .Y(n8505) );
  sky130_fd_sc_hd__a22oi_1 U10182 ( .A1(n8503), .A2(\cpuregs[24][7] ), .B1(
        n8502), .B2(\cpuregs[6][7] ), .Y(n8504) );
  sky130_fd_sc_hd__nand4_1 U10183 ( .A(n8507), .B(n8506), .C(n8505), .D(n8504), 
        .Y(n8508) );
  sky130_fd_sc_hd__nor4_1 U10184 ( .A(n8511), .B(n8510), .C(n8509), .D(n8508), 
        .Y(n8513) );
  sky130_fd_sc_hd__a22oi_1 U10185 ( .A1(pcpi_rs2[7]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[7]), .Y(n8512) );
  sky130_fd_sc_hd__o21ai_1 U10186 ( .A1(n8514), .A2(n8513), .B1(n8512), .Y(
        n3951) );
  sky130_fd_sc_hd__nand2_1 U10187 ( .A(n8516), .B(n8515), .Y(n8518) );
  sky130_fd_sc_hd__xnor2_1 U10188 ( .A(n8518), .B(n8517), .Y(n8519) );
  sky130_fd_sc_hd__nand2_1 U10189 ( .A(n8519), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n8524) );
  sky130_fd_sc_hd__o21ai_1 U10190 ( .A1(pcpi_rs1[3]), .A2(pcpi_rs2[3]), .B1(
        n9872), .Y(n8523) );
  sky130_fd_sc_hd__nand2_1 U10191 ( .A(n9873), .B(n8520), .Y(n8522) );
  sky130_fd_sc_hd__nand3_1 U10192 ( .A(n9382), .B(pcpi_rs1[3]), .C(pcpi_rs2[3]), .Y(n8521) );
  sky130_fd_sc_hd__nand4_1 U10193 ( .A(n8524), .B(n8523), .C(n8522), .D(n8521), 
        .Y(alu_out[3]) );
  sky130_fd_sc_hd__nand2_1 U10194 ( .A(n4180), .B(\cpuregs[5][3] ), .Y(n8525)
         );
  sky130_fd_sc_hd__o21ai_1 U10195 ( .A1(n8555), .A2(n4180), .B1(n8525), .Y(
        n3807) );
  sky130_fd_sc_hd__nand2_1 U10196 ( .A(n4186), .B(\cpuregs[13][3] ), .Y(n8526)
         );
  sky130_fd_sc_hd__o21ai_1 U10197 ( .A1(n8555), .A2(n4186), .B1(n8526), .Y(
        n3815) );
  sky130_fd_sc_hd__nand2_1 U10198 ( .A(n4195), .B(\cpuregs[17][3] ), .Y(n8527)
         );
  sky130_fd_sc_hd__o21ai_1 U10199 ( .A1(n8555), .A2(n4195), .B1(n8527), .Y(
        n3819) );
  sky130_fd_sc_hd__nand2_1 U10200 ( .A(n7452), .B(\cpuregs[9][3] ), .Y(n8528)
         );
  sky130_fd_sc_hd__o21ai_1 U10201 ( .A1(n8555), .A2(n7452), .B1(n8528), .Y(
        n3811) );
  sky130_fd_sc_hd__nand2_1 U10202 ( .A(n4176), .B(\cpuregs[29][3] ), .Y(n8529)
         );
  sky130_fd_sc_hd__o21ai_1 U10203 ( .A1(n8555), .A2(n4176), .B1(n8529), .Y(
        n3831) );
  sky130_fd_sc_hd__nand2_1 U10204 ( .A(n4174), .B(\cpuregs[21][3] ), .Y(n8530)
         );
  sky130_fd_sc_hd__o21ai_1 U10205 ( .A1(n8555), .A2(n4174), .B1(n8530), .Y(
        n3823) );
  sky130_fd_sc_hd__nand2_1 U10206 ( .A(n4192), .B(\cpuregs[25][3] ), .Y(n8531)
         );
  sky130_fd_sc_hd__o21ai_1 U10207 ( .A1(n8555), .A2(n4192), .B1(n8531), .Y(
        n3827) );
  sky130_fd_sc_hd__nand2_1 U10208 ( .A(n6396), .B(\cpuregs[1][3] ), .Y(n8532)
         );
  sky130_fd_sc_hd__o21ai_1 U10209 ( .A1(n8555), .A2(n6396), .B1(n8532), .Y(
        n3803) );
  sky130_fd_sc_hd__nand2_1 U10210 ( .A(n4199), .B(\cpuregs[7][3] ), .Y(n8533)
         );
  sky130_fd_sc_hd__o21ai_1 U10211 ( .A1(n8555), .A2(n4199), .B1(n8533), .Y(
        n3809) );
  sky130_fd_sc_hd__nand2_1 U10212 ( .A(n7069), .B(\cpuregs[15][3] ), .Y(n8534)
         );
  sky130_fd_sc_hd__o21ai_1 U10213 ( .A1(n8555), .A2(n7069), .B1(n8534), .Y(
        n3817) );
  sky130_fd_sc_hd__nand2_1 U10214 ( .A(n4194), .B(\cpuregs[19][3] ), .Y(n8535)
         );
  sky130_fd_sc_hd__o21ai_1 U10215 ( .A1(n8555), .A2(n4194), .B1(n8535), .Y(
        n3821) );
  sky130_fd_sc_hd__nand2_1 U10216 ( .A(n4185), .B(\cpuregs[11][3] ), .Y(n8536)
         );
  sky130_fd_sc_hd__o21ai_1 U10217 ( .A1(n8555), .A2(n4185), .B1(n8536), .Y(
        n3813) );
  sky130_fd_sc_hd__nand2_1 U10218 ( .A(n7247), .B(\cpuregs[31][3] ), .Y(n8537)
         );
  sky130_fd_sc_hd__o21ai_1 U10219 ( .A1(n8555), .A2(n7247), .B1(n8537), .Y(
        n3833) );
  sky130_fd_sc_hd__nand2_1 U10220 ( .A(n4173), .B(\cpuregs[23][3] ), .Y(n8538)
         );
  sky130_fd_sc_hd__o21ai_1 U10221 ( .A1(n8555), .A2(n4173), .B1(n8538), .Y(
        n3825) );
  sky130_fd_sc_hd__nand2_1 U10222 ( .A(n4175), .B(\cpuregs[27][3] ), .Y(n8539)
         );
  sky130_fd_sc_hd__o21ai_1 U10223 ( .A1(n8555), .A2(n4175), .B1(n8539), .Y(
        n3829) );
  sky130_fd_sc_hd__nand2_1 U10224 ( .A(n4201), .B(\cpuregs[3][3] ), .Y(n8540)
         );
  sky130_fd_sc_hd__o21ai_1 U10225 ( .A1(n8555), .A2(n4201), .B1(n8540), .Y(
        n3805) );
  sky130_fd_sc_hd__nand2_1 U10226 ( .A(n4179), .B(\cpuregs[4][3] ), .Y(n8541)
         );
  sky130_fd_sc_hd__o21ai_1 U10227 ( .A1(n8555), .A2(n4179), .B1(n8541), .Y(
        n3806) );
  sky130_fd_sc_hd__nand2_1 U10228 ( .A(n4226), .B(\cpuregs[12][3] ), .Y(n8542)
         );
  sky130_fd_sc_hd__o21ai_1 U10229 ( .A1(n8555), .A2(n4226), .B1(n8542), .Y(
        n3814) );
  sky130_fd_sc_hd__nand2_1 U10230 ( .A(n4197), .B(\cpuregs[16][3] ), .Y(n8543)
         );
  sky130_fd_sc_hd__o21ai_1 U10231 ( .A1(n8555), .A2(n4197), .B1(n8543), .Y(
        n3818) );
  sky130_fd_sc_hd__nand2_1 U10232 ( .A(n4183), .B(\cpuregs[8][3] ), .Y(n8544)
         );
  sky130_fd_sc_hd__o21ai_1 U10233 ( .A1(n8555), .A2(n4183), .B1(n8544), .Y(
        n3810) );
  sky130_fd_sc_hd__nand2_1 U10234 ( .A(n4219), .B(\cpuregs[28][3] ), .Y(n8545)
         );
  sky130_fd_sc_hd__o21ai_1 U10235 ( .A1(n8555), .A2(n4219), .B1(n8545), .Y(
        n3830) );
  sky130_fd_sc_hd__nand2_1 U10236 ( .A(n10057), .B(\cpuregs[24][3] ), .Y(n8546) );
  sky130_fd_sc_hd__o21ai_1 U10237 ( .A1(n8555), .A2(n10057), .B1(n8546), .Y(
        n3826) );
  sky130_fd_sc_hd__nand2_1 U10238 ( .A(n9772), .B(\cpuregs[6][3] ), .Y(n8547)
         );
  sky130_fd_sc_hd__o21ai_1 U10239 ( .A1(n8555), .A2(n9772), .B1(n8547), .Y(
        n3808) );
  sky130_fd_sc_hd__nand2_1 U10240 ( .A(n6897), .B(\cpuregs[14][3] ), .Y(n8548)
         );
  sky130_fd_sc_hd__o21ai_1 U10241 ( .A1(n8555), .A2(n6897), .B1(n8548), .Y(
        n3816) );
  sky130_fd_sc_hd__nand2_1 U10242 ( .A(n9820), .B(\cpuregs[18][3] ), .Y(n8549)
         );
  sky130_fd_sc_hd__o21ai_1 U10243 ( .A1(n8555), .A2(n9820), .B1(n8549), .Y(
        n3820) );
  sky130_fd_sc_hd__nand2_1 U10244 ( .A(n4184), .B(\cpuregs[10][3] ), .Y(n8550)
         );
  sky130_fd_sc_hd__o21ai_1 U10245 ( .A1(n8555), .A2(n4184), .B1(n8550), .Y(
        n3812) );
  sky130_fd_sc_hd__nand2_1 U10246 ( .A(n4177), .B(\cpuregs[30][3] ), .Y(n8551)
         );
  sky130_fd_sc_hd__o21ai_1 U10247 ( .A1(n8555), .A2(n4177), .B1(n8551), .Y(
        n3832) );
  sky130_fd_sc_hd__nand2_1 U10248 ( .A(n7084), .B(\cpuregs[22][3] ), .Y(n8552)
         );
  sky130_fd_sc_hd__o21ai_1 U10249 ( .A1(n8555), .A2(n7084), .B1(n8552), .Y(
        n3824) );
  sky130_fd_sc_hd__nand2_1 U10250 ( .A(n9621), .B(\cpuregs[26][3] ), .Y(n8553)
         );
  sky130_fd_sc_hd__o21ai_1 U10251 ( .A1(n8555), .A2(n9621), .B1(n8553), .Y(
        n3828) );
  sky130_fd_sc_hd__nand2_1 U10252 ( .A(n4178), .B(\cpuregs[2][3] ), .Y(n8554)
         );
  sky130_fd_sc_hd__o21ai_1 U10253 ( .A1(n8555), .A2(n4178), .B1(n8554), .Y(
        n3804) );
  sky130_fd_sc_hd__a22oi_1 U10254 ( .A1(decoded_imm[3]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[3]), .Y(n8557) );
  sky130_fd_sc_hd__nand2_1 U10255 ( .A(n8609), .B(mem_rdata_q[10]), .Y(n8556)
         );
  sky130_fd_sc_hd__o211ai_1 U10256 ( .A1(n8613), .A2(n8558), .B1(n8557), .C1(
        n8556), .Y(n2869) );
  sky130_fd_sc_hd__a22oi_1 U10257 ( .A1(n8657), .A2(\cpuregs[16][3] ), .B1(
        n4215), .B2(\cpuregs[8][3] ), .Y(n8562) );
  sky130_fd_sc_hd__a22oi_1 U10258 ( .A1(n8658), .A2(\cpuregs[20][3] ), .B1(
        n8656), .B2(\cpuregs[24][3] ), .Y(n8561) );
  sky130_fd_sc_hd__a22oi_1 U10259 ( .A1(n8660), .A2(\cpuregs[4][3] ), .B1(
        n8662), .B2(\cpuregs[28][3] ), .Y(n8560) );
  sky130_fd_sc_hd__nand2_1 U10260 ( .A(n8661), .B(\cpuregs[12][3] ), .Y(n8559)
         );
  sky130_fd_sc_hd__nand4_1 U10261 ( .A(n8562), .B(n8561), .C(n8560), .D(n8559), 
        .Y(n8568) );
  sky130_fd_sc_hd__a22oi_1 U10262 ( .A1(n8656), .A2(\cpuregs[26][3] ), .B1(
        n6001), .B2(\cpuregs[2][3] ), .Y(n8566) );
  sky130_fd_sc_hd__a22oi_1 U10263 ( .A1(n8658), .A2(\cpuregs[22][3] ), .B1(
        n8657), .B2(\cpuregs[18][3] ), .Y(n8565) );
  sky130_fd_sc_hd__a22oi_1 U10264 ( .A1(n8660), .A2(\cpuregs[6][3] ), .B1(
        n4215), .B2(\cpuregs[10][3] ), .Y(n8564) );
  sky130_fd_sc_hd__a22oi_1 U10265 ( .A1(n8662), .A2(\cpuregs[30][3] ), .B1(
        n8661), .B2(\cpuregs[14][3] ), .Y(n8563) );
  sky130_fd_sc_hd__nand4_1 U10266 ( .A(n8566), .B(n8565), .C(n8564), .D(n8563), 
        .Y(n8567) );
  sky130_fd_sc_hd__a22o_1 U10267 ( .A1(n8568), .A2(n8650), .B1(n8668), .B2(
        n8567), .X(n8580) );
  sky130_fd_sc_hd__a22oi_1 U10268 ( .A1(n8656), .A2(\cpuregs[25][3] ), .B1(
        n6001), .B2(\cpuregs[1][3] ), .Y(n8572) );
  sky130_fd_sc_hd__a22oi_1 U10269 ( .A1(n8658), .A2(\cpuregs[21][3] ), .B1(
        n8657), .B2(\cpuregs[17][3] ), .Y(n8571) );
  sky130_fd_sc_hd__a22oi_1 U10270 ( .A1(n8660), .A2(\cpuregs[5][3] ), .B1(
        n4215), .B2(\cpuregs[9][3] ), .Y(n8570) );
  sky130_fd_sc_hd__a22oi_1 U10271 ( .A1(n8662), .A2(\cpuregs[29][3] ), .B1(
        n8661), .B2(\cpuregs[13][3] ), .Y(n8569) );
  sky130_fd_sc_hd__nand4_1 U10272 ( .A(n8572), .B(n8571), .C(n8570), .D(n8569), 
        .Y(n8578) );
  sky130_fd_sc_hd__a22oi_1 U10273 ( .A1(n8656), .A2(\cpuregs[27][3] ), .B1(
        n6001), .B2(\cpuregs[3][3] ), .Y(n8576) );
  sky130_fd_sc_hd__a22oi_1 U10274 ( .A1(n8658), .A2(\cpuregs[23][3] ), .B1(
        n8657), .B2(\cpuregs[19][3] ), .Y(n8575) );
  sky130_fd_sc_hd__a22oi_1 U10275 ( .A1(n8660), .A2(\cpuregs[7][3] ), .B1(
        n4215), .B2(\cpuregs[11][3] ), .Y(n8574) );
  sky130_fd_sc_hd__a22oi_1 U10276 ( .A1(n8662), .A2(\cpuregs[31][3] ), .B1(
        n8661), .B2(\cpuregs[15][3] ), .Y(n8573) );
  sky130_fd_sc_hd__nand4_1 U10277 ( .A(n8576), .B(n8575), .C(n8574), .D(n8573), 
        .Y(n8577) );
  sky130_fd_sc_hd__a22o_1 U10278 ( .A1(n8578), .A2(n8649), .B1(n8669), .B2(
        n8577), .X(n8579) );
  sky130_fd_sc_hd__o21ai_1 U10279 ( .A1(n8580), .A2(n8579), .B1(n9439), .Y(
        n9435) );
  sky130_fd_sc_hd__a22oi_1 U10280 ( .A1(pcpi_rs2[3]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[3]), .Y(n8581) );
  sky130_fd_sc_hd__o21ai_1 U10281 ( .A1(n10060), .A2(n9435), .B1(n8581), .Y(
        n3955) );
  sky130_fd_sc_hd__a22oi_1 U10282 ( .A1(decoded_imm[2]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[2]), .Y(n8583) );
  sky130_fd_sc_hd__nand2_1 U10283 ( .A(n8609), .B(mem_rdata_q[9]), .Y(n8582)
         );
  sky130_fd_sc_hd__o211ai_1 U10284 ( .A1(n8613), .A2(n8584), .B1(n8583), .C1(
        n8582), .Y(n2870) );
  sky130_fd_sc_hd__a22oi_1 U10285 ( .A1(n8656), .A2(\cpuregs[25][2] ), .B1(
        n6001), .B2(\cpuregs[1][2] ), .Y(n8588) );
  sky130_fd_sc_hd__a22oi_1 U10286 ( .A1(n8658), .A2(\cpuregs[21][2] ), .B1(
        n8657), .B2(\cpuregs[17][2] ), .Y(n8587) );
  sky130_fd_sc_hd__a22oi_1 U10287 ( .A1(n8660), .A2(\cpuregs[5][2] ), .B1(
        n4215), .B2(\cpuregs[9][2] ), .Y(n8586) );
  sky130_fd_sc_hd__a22oi_1 U10288 ( .A1(n8662), .A2(\cpuregs[29][2] ), .B1(
        n8661), .B2(\cpuregs[13][2] ), .Y(n8585) );
  sky130_fd_sc_hd__nand4_1 U10289 ( .A(n8588), .B(n8587), .C(n8586), .D(n8585), 
        .Y(n8594) );
  sky130_fd_sc_hd__a22oi_1 U10290 ( .A1(n8656), .A2(\cpuregs[26][2] ), .B1(
        n6001), .B2(\cpuregs[2][2] ), .Y(n8592) );
  sky130_fd_sc_hd__a22oi_1 U10291 ( .A1(n8658), .A2(\cpuregs[22][2] ), .B1(
        n8657), .B2(\cpuregs[18][2] ), .Y(n8591) );
  sky130_fd_sc_hd__a22oi_1 U10292 ( .A1(n8660), .A2(\cpuregs[6][2] ), .B1(
        n4215), .B2(\cpuregs[10][2] ), .Y(n8590) );
  sky130_fd_sc_hd__a22oi_1 U10293 ( .A1(n8662), .A2(\cpuregs[30][2] ), .B1(
        n8661), .B2(\cpuregs[14][2] ), .Y(n8589) );
  sky130_fd_sc_hd__nand4_1 U10294 ( .A(n8592), .B(n8591), .C(n8590), .D(n8589), 
        .Y(n8593) );
  sky130_fd_sc_hd__a22o_1 U10295 ( .A1(n8594), .A2(n8649), .B1(n8668), .B2(
        n8593), .X(n8606) );
  sky130_fd_sc_hd__a22oi_1 U10296 ( .A1(n8657), .A2(\cpuregs[16][2] ), .B1(
        n4215), .B2(\cpuregs[8][2] ), .Y(n8598) );
  sky130_fd_sc_hd__a22oi_1 U10297 ( .A1(n8658), .A2(\cpuregs[20][2] ), .B1(
        n8656), .B2(\cpuregs[24][2] ), .Y(n8597) );
  sky130_fd_sc_hd__a22oi_1 U10298 ( .A1(n8660), .A2(\cpuregs[4][2] ), .B1(
        n8662), .B2(\cpuregs[28][2] ), .Y(n8596) );
  sky130_fd_sc_hd__nand2_1 U10299 ( .A(n8661), .B(\cpuregs[12][2] ), .Y(n8595)
         );
  sky130_fd_sc_hd__nand4_1 U10300 ( .A(n8598), .B(n8597), .C(n8596), .D(n8595), 
        .Y(n8604) );
  sky130_fd_sc_hd__a22oi_1 U10301 ( .A1(n8656), .A2(\cpuregs[27][2] ), .B1(
        n6001), .B2(\cpuregs[3][2] ), .Y(n8602) );
  sky130_fd_sc_hd__a22oi_1 U10302 ( .A1(n8658), .A2(\cpuregs[23][2] ), .B1(
        n8657), .B2(\cpuregs[19][2] ), .Y(n8601) );
  sky130_fd_sc_hd__a22oi_1 U10303 ( .A1(n8660), .A2(\cpuregs[7][2] ), .B1(
        n4215), .B2(\cpuregs[11][2] ), .Y(n8600) );
  sky130_fd_sc_hd__a22oi_1 U10304 ( .A1(n8662), .A2(\cpuregs[31][2] ), .B1(
        n8661), .B2(\cpuregs[15][2] ), .Y(n8599) );
  sky130_fd_sc_hd__nand4_1 U10305 ( .A(n8602), .B(n8601), .C(n8600), .D(n8599), 
        .Y(n8603) );
  sky130_fd_sc_hd__a22o_1 U10306 ( .A1(n8604), .A2(n8650), .B1(n8669), .B2(
        n8603), .X(n8605) );
  sky130_fd_sc_hd__o21ai_1 U10307 ( .A1(n8606), .A2(n8605), .B1(n9439), .Y(
        n9425) );
  sky130_fd_sc_hd__a22oi_1 U10308 ( .A1(pcpi_rs2[2]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[2]), .Y(n8607) );
  sky130_fd_sc_hd__o21ai_1 U10309 ( .A1(n10060), .A2(n9425), .B1(n8607), .Y(
        n3956) );
  sky130_fd_sc_hd__a22oi_1 U10310 ( .A1(decoded_imm[1]), .A2(n10122), .B1(
        n8608), .B2(decoded_imm_j[1]), .Y(n8611) );
  sky130_fd_sc_hd__nand2_1 U10311 ( .A(n8609), .B(mem_rdata_q[8]), .Y(n8610)
         );
  sky130_fd_sc_hd__o211ai_1 U10312 ( .A1(n8613), .A2(n8612), .B1(n8611), .C1(
        n8610), .Y(n2871) );
  sky130_fd_sc_hd__a22oi_1 U10313 ( .A1(n8657), .A2(\cpuregs[16][1] ), .B1(
        n4215), .B2(\cpuregs[8][1] ), .Y(n8617) );
  sky130_fd_sc_hd__a22oi_1 U10314 ( .A1(n8658), .A2(\cpuregs[20][1] ), .B1(
        n8656), .B2(\cpuregs[24][1] ), .Y(n8616) );
  sky130_fd_sc_hd__a22oi_1 U10315 ( .A1(n8660), .A2(\cpuregs[4][1] ), .B1(
        n8662), .B2(\cpuregs[28][1] ), .Y(n8615) );
  sky130_fd_sc_hd__nand2_1 U10316 ( .A(n8661), .B(\cpuregs[12][1] ), .Y(n8614)
         );
  sky130_fd_sc_hd__nand4_1 U10317 ( .A(n8617), .B(n8616), .C(n8615), .D(n8614), 
        .Y(n8623) );
  sky130_fd_sc_hd__a22oi_1 U10318 ( .A1(n8656), .A2(\cpuregs[26][1] ), .B1(
        n6001), .B2(\cpuregs[2][1] ), .Y(n8621) );
  sky130_fd_sc_hd__a22oi_1 U10319 ( .A1(n8658), .A2(\cpuregs[22][1] ), .B1(
        n8657), .B2(\cpuregs[18][1] ), .Y(n8620) );
  sky130_fd_sc_hd__a22oi_1 U10320 ( .A1(n8660), .A2(\cpuregs[6][1] ), .B1(
        n4215), .B2(\cpuregs[10][1] ), .Y(n8619) );
  sky130_fd_sc_hd__a22oi_1 U10321 ( .A1(n8662), .A2(\cpuregs[30][1] ), .B1(
        n8661), .B2(\cpuregs[14][1] ), .Y(n8618) );
  sky130_fd_sc_hd__nand4_1 U10322 ( .A(n8621), .B(n8620), .C(n8619), .D(n8618), 
        .Y(n8622) );
  sky130_fd_sc_hd__a22o_1 U10323 ( .A1(n8623), .A2(n8650), .B1(n8668), .B2(
        n8622), .X(n8635) );
  sky130_fd_sc_hd__a22oi_1 U10324 ( .A1(n8656), .A2(\cpuregs[25][1] ), .B1(
        n6001), .B2(\cpuregs[1][1] ), .Y(n8627) );
  sky130_fd_sc_hd__a22oi_1 U10325 ( .A1(n8658), .A2(\cpuregs[21][1] ), .B1(
        n8657), .B2(\cpuregs[17][1] ), .Y(n8626) );
  sky130_fd_sc_hd__a22oi_1 U10326 ( .A1(n8660), .A2(\cpuregs[5][1] ), .B1(
        n4215), .B2(\cpuregs[9][1] ), .Y(n8625) );
  sky130_fd_sc_hd__a22oi_1 U10327 ( .A1(n8662), .A2(\cpuregs[29][1] ), .B1(
        n8661), .B2(\cpuregs[13][1] ), .Y(n8624) );
  sky130_fd_sc_hd__nand4_1 U10328 ( .A(n8627), .B(n8626), .C(n8625), .D(n8624), 
        .Y(n8633) );
  sky130_fd_sc_hd__a22oi_1 U10329 ( .A1(n8656), .A2(\cpuregs[27][1] ), .B1(
        n6001), .B2(\cpuregs[3][1] ), .Y(n8631) );
  sky130_fd_sc_hd__a22oi_1 U10330 ( .A1(n8658), .A2(\cpuregs[23][1] ), .B1(
        n8657), .B2(\cpuregs[19][1] ), .Y(n8630) );
  sky130_fd_sc_hd__a22oi_1 U10331 ( .A1(n8660), .A2(\cpuregs[7][1] ), .B1(
        n4215), .B2(\cpuregs[11][1] ), .Y(n8629) );
  sky130_fd_sc_hd__a22oi_1 U10332 ( .A1(n8662), .A2(\cpuregs[31][1] ), .B1(
        n8661), .B2(\cpuregs[15][1] ), .Y(n8628) );
  sky130_fd_sc_hd__nand4_1 U10333 ( .A(n8631), .B(n8630), .C(n8629), .D(n8628), 
        .Y(n8632) );
  sky130_fd_sc_hd__a22o_1 U10334 ( .A1(n8633), .A2(n8649), .B1(n8669), .B2(
        n8632), .X(n8634) );
  sky130_fd_sc_hd__o21ai_1 U10335 ( .A1(n8635), .A2(n8634), .B1(n9439), .Y(
        n9220) );
  sky130_fd_sc_hd__a22oi_1 U10336 ( .A1(pcpi_rs2[1]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[1]), .Y(n8636) );
  sky130_fd_sc_hd__o21ai_1 U10337 ( .A1(n10060), .A2(n9220), .B1(n8636), .Y(
        n3957) );
  sky130_fd_sc_hd__a222oi_1 U10338 ( .A1(n10122), .A2(decoded_imm[0]), .B1(
        n8638), .B2(mem_rdata_q[7]), .C1(mem_rdata_q[20]), .C2(n8637), .Y(
        n8639) );
  sky130_fd_sc_hd__a22oi_1 U10339 ( .A1(n8657), .A2(\cpuregs[16][0] ), .B1(
        n4215), .B2(\cpuregs[8][0] ), .Y(n8643) );
  sky130_fd_sc_hd__a22oi_1 U10340 ( .A1(n8658), .A2(\cpuregs[20][0] ), .B1(
        n8656), .B2(\cpuregs[24][0] ), .Y(n8642) );
  sky130_fd_sc_hd__a22oi_1 U10341 ( .A1(n8660), .A2(\cpuregs[4][0] ), .B1(
        n8662), .B2(\cpuregs[28][0] ), .Y(n8641) );
  sky130_fd_sc_hd__nand2_1 U10342 ( .A(n8661), .B(\cpuregs[12][0] ), .Y(n8640)
         );
  sky130_fd_sc_hd__nand4_1 U10343 ( .A(n8643), .B(n8642), .C(n8641), .D(n8640), 
        .Y(n8651) );
  sky130_fd_sc_hd__a22oi_1 U10344 ( .A1(n8656), .A2(\cpuregs[25][0] ), .B1(
        n6001), .B2(\cpuregs[1][0] ), .Y(n8647) );
  sky130_fd_sc_hd__a22oi_1 U10345 ( .A1(n8658), .A2(\cpuregs[21][0] ), .B1(
        n8657), .B2(\cpuregs[17][0] ), .Y(n8646) );
  sky130_fd_sc_hd__a22oi_1 U10346 ( .A1(n8660), .A2(\cpuregs[5][0] ), .B1(
        n4215), .B2(\cpuregs[9][0] ), .Y(n8645) );
  sky130_fd_sc_hd__a22oi_1 U10347 ( .A1(n8662), .A2(\cpuregs[29][0] ), .B1(
        n8661), .B2(\cpuregs[13][0] ), .Y(n8644) );
  sky130_fd_sc_hd__nand4_1 U10348 ( .A(n8647), .B(n8646), .C(n8645), .D(n8644), 
        .Y(n8648) );
  sky130_fd_sc_hd__a22o_1 U10349 ( .A1(n8651), .A2(n8650), .B1(n8649), .B2(
        n8648), .X(n8672) );
  sky130_fd_sc_hd__a22oi_1 U10350 ( .A1(n8656), .A2(\cpuregs[27][0] ), .B1(
        n6001), .B2(\cpuregs[3][0] ), .Y(n8655) );
  sky130_fd_sc_hd__a22oi_1 U10351 ( .A1(n8658), .A2(\cpuregs[23][0] ), .B1(
        n8657), .B2(\cpuregs[19][0] ), .Y(n8654) );
  sky130_fd_sc_hd__a22oi_1 U10352 ( .A1(n8660), .A2(\cpuregs[7][0] ), .B1(
        n4215), .B2(\cpuregs[11][0] ), .Y(n8653) );
  sky130_fd_sc_hd__a22oi_1 U10353 ( .A1(n8662), .A2(\cpuregs[31][0] ), .B1(
        n8661), .B2(\cpuregs[15][0] ), .Y(n8652) );
  sky130_fd_sc_hd__nand4_1 U10354 ( .A(n8655), .B(n8654), .C(n8653), .D(n8652), 
        .Y(n8670) );
  sky130_fd_sc_hd__a22oi_1 U10355 ( .A1(n8656), .A2(\cpuregs[26][0] ), .B1(
        n6001), .B2(\cpuregs[2][0] ), .Y(n8666) );
  sky130_fd_sc_hd__a22oi_1 U10356 ( .A1(n8658), .A2(\cpuregs[22][0] ), .B1(
        n8657), .B2(\cpuregs[18][0] ), .Y(n8665) );
  sky130_fd_sc_hd__a22oi_1 U10357 ( .A1(n8660), .A2(\cpuregs[6][0] ), .B1(
        n4215), .B2(\cpuregs[10][0] ), .Y(n8664) );
  sky130_fd_sc_hd__a22oi_1 U10358 ( .A1(n8662), .A2(\cpuregs[30][0] ), .B1(
        n8661), .B2(\cpuregs[14][0] ), .Y(n8663) );
  sky130_fd_sc_hd__nand4_1 U10359 ( .A(n8666), .B(n8665), .C(n8664), .D(n8663), 
        .Y(n8667) );
  sky130_fd_sc_hd__a22o_1 U10360 ( .A1(n8670), .A2(n8669), .B1(n8668), .B2(
        n8667), .X(n8671) );
  sky130_fd_sc_hd__o21ai_1 U10361 ( .A1(n8672), .A2(n8671), .B1(n9439), .Y(
        n9225) );
  sky130_fd_sc_hd__a22oi_1 U10362 ( .A1(pcpi_rs2[0]), .A2(n9532), .B1(n4181), 
        .B2(decoded_imm[0]), .Y(n8673) );
  sky130_fd_sc_hd__o21ai_1 U10363 ( .A1(n10060), .A2(n9225), .B1(n8673), .Y(
        n3958) );
  sky130_fd_sc_hd__a21oi_1 U10364 ( .A1(n8677), .A2(n8676), .B1(n8675), .Y(
        n9022) );
  sky130_fd_sc_hd__xor2_1 U10365 ( .A(n9017), .B(pcpi_rs2[30]), .X(n8678) );
  sky130_fd_sc_hd__nor2_1 U10366 ( .A(pcpi_rs1[30]), .B(n8678), .Y(n9023) );
  sky130_fd_sc_hd__nand2_1 U10367 ( .A(n8678), .B(pcpi_rs1[30]), .Y(n9021) );
  sky130_fd_sc_hd__nand2_1 U10368 ( .A(n8679), .B(n9021), .Y(n8680) );
  sky130_fd_sc_hd__xor2_1 U10369 ( .A(n9022), .B(n8680), .X(n8681) );
  sky130_fd_sc_hd__nand2_1 U10370 ( .A(n8681), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n8687) );
  sky130_fd_sc_hd__nor2_1 U10371 ( .A(n8683), .B(n8682), .Y(n8684) );
  sky130_fd_sc_hd__a31oi_1 U10372 ( .A1(n9382), .A2(pcpi_rs1[30]), .A3(
        pcpi_rs2[30]), .B1(n8684), .Y(n8686) );
  sky130_fd_sc_hd__o21ai_1 U10373 ( .A1(pcpi_rs1[30]), .A2(pcpi_rs2[30]), .B1(
        n9872), .Y(n8685) );
  sky130_fd_sc_hd__nand3_1 U10374 ( .A(n8687), .B(n8686), .C(n8685), .Y(
        alu_out[30]) );
  sky130_fd_sc_hd__nand2_1 U10375 ( .A(n8689), .B(n8688), .Y(n8690) );
  sky130_fd_sc_hd__xor2_1 U10376 ( .A(n8691), .B(n8690), .X(n8692) );
  sky130_fd_sc_hd__a222oi_1 U10377 ( .A1(n8694), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[3]), .C1(n5794), .C2(n8692), .Y(n8693) );
  sky130_fd_sc_hd__o22ai_1 U10378 ( .A1(n10029), .A2(n8723), .B1(n8695), .B2(
        n9387), .Y(n4016) );
  sky130_fd_sc_hd__a22oi_1 U10379 ( .A1(n9494), .A2(\cpuregs[8][3] ), .B1(
        n9482), .B2(\cpuregs[31][3] ), .Y(n8699) );
  sky130_fd_sc_hd__a22oi_1 U10380 ( .A1(n9473), .A2(\cpuregs[23][3] ), .B1(
        n9316), .B2(\cpuregs[4][3] ), .Y(n8698) );
  sky130_fd_sc_hd__a22oi_1 U10381 ( .A1(n9497), .A2(\cpuregs[15][3] ), .B1(
        n9493), .B2(\cpuregs[6][3] ), .Y(n8697) );
  sky130_fd_sc_hd__nand2_1 U10382 ( .A(n9469), .B(\cpuregs[9][3] ), .Y(n8696)
         );
  sky130_fd_sc_hd__nand4_1 U10383 ( .A(n8699), .B(n8698), .C(n8697), .D(n8696), 
        .Y(n8715) );
  sky130_fd_sc_hd__a22oi_1 U10384 ( .A1(n9460), .A2(\cpuregs[24][3] ), .B1(
        n9483), .B2(\cpuregs[7][3] ), .Y(n8703) );
  sky130_fd_sc_hd__a22oi_1 U10385 ( .A1(n9462), .A2(\cpuregs[2][3] ), .B1(
        n9490), .B2(\cpuregs[11][3] ), .Y(n8702) );
  sky130_fd_sc_hd__a22oi_1 U10386 ( .A1(n9471), .A2(\cpuregs[25][3] ), .B1(
        n9458), .B2(\cpuregs[30][3] ), .Y(n8701) );
  sky130_fd_sc_hd__a22oi_1 U10387 ( .A1(n9492), .A2(\cpuregs[28][3] ), .B1(
        n9478), .B2(\cpuregs[1][3] ), .Y(n8700) );
  sky130_fd_sc_hd__nand4_1 U10388 ( .A(n8703), .B(n8702), .C(n8701), .D(n8700), 
        .Y(n8714) );
  sky130_fd_sc_hd__a22oi_1 U10389 ( .A1(n9456), .A2(\cpuregs[17][3] ), .B1(
        n9480), .B2(\cpuregs[20][3] ), .Y(n8707) );
  sky130_fd_sc_hd__a22oi_1 U10390 ( .A1(n9457), .A2(\cpuregs[19][3] ), .B1(
        n9484), .B2(\cpuregs[12][3] ), .Y(n8706) );
  sky130_fd_sc_hd__a22oi_1 U10391 ( .A1(n9481), .A2(\cpuregs[14][3] ), .B1(
        n9496), .B2(\cpuregs[3][3] ), .Y(n8705) );
  sky130_fd_sc_hd__a22oi_1 U10392 ( .A1(n9485), .A2(\cpuregs[21][3] ), .B1(
        n9461), .B2(\cpuregs[5][3] ), .Y(n8704) );
  sky130_fd_sc_hd__nand4_1 U10393 ( .A(n8707), .B(n8706), .C(n8705), .D(n8704), 
        .Y(n8713) );
  sky130_fd_sc_hd__a22oi_1 U10394 ( .A1(n9321), .A2(\cpuregs[27][3] ), .B1(
        n9470), .B2(\cpuregs[13][3] ), .Y(n8711) );
  sky130_fd_sc_hd__a22oi_1 U10395 ( .A1(n9468), .A2(\cpuregs[16][3] ), .B1(
        n9495), .B2(\cpuregs[22][3] ), .Y(n8710) );
  sky130_fd_sc_hd__a22oi_1 U10396 ( .A1(n9467), .A2(\cpuregs[26][3] ), .B1(
        n9491), .B2(\cpuregs[10][3] ), .Y(n8709) );
  sky130_fd_sc_hd__a22oi_1 U10397 ( .A1(n9459), .A2(\cpuregs[18][3] ), .B1(
        n9479), .B2(\cpuregs[29][3] ), .Y(n8708) );
  sky130_fd_sc_hd__nand4_1 U10398 ( .A(n8711), .B(n8710), .C(n8709), .D(n8708), 
        .Y(n8712) );
  sky130_fd_sc_hd__nor4_1 U10399 ( .A(n8715), .B(n8714), .C(n8713), .D(n8712), 
        .Y(n8728) );
  sky130_fd_sc_hd__nand2_1 U10400 ( .A(n8718), .B(n8717), .Y(n8721) );
  sky130_fd_sc_hd__o21ai_1 U10401 ( .A1(n9334), .A2(n9338), .B1(n9335), .Y(
        n8720) );
  sky130_fd_sc_hd__xnor2_1 U10402 ( .A(n8721), .B(n8720), .Y(n8722) );
  sky130_fd_sc_hd__nand2_1 U10403 ( .A(n9511), .B(n8722), .Y(n8727) );
  sky130_fd_sc_hd__o22ai_1 U10404 ( .A1(n4321), .A2(n8723), .B1(n9342), .B2(
        n9340), .Y(n8725) );
  sky130_fd_sc_hd__o22ai_1 U10405 ( .A1(n9455), .A2(n4342), .B1(n4340), .B2(
        n9341), .Y(n8724) );
  sky130_fd_sc_hd__a211oi_1 U10406 ( .A1(n9345), .A2(pcpi_rs1[7]), .B1(n8725), 
        .C1(n8724), .Y(n8726) );
  sky130_fd_sc_hd__o211ai_1 U10407 ( .A1(n8728), .A2(n9506), .B1(n8727), .C1(
        n8726), .Y(n2792) );
  sky130_fd_sc_hd__a22oi_1 U10408 ( .A1(n9485), .A2(\cpuregs[21][4] ), .B1(
        n9497), .B2(\cpuregs[15][4] ), .Y(n8732) );
  sky130_fd_sc_hd__a22oi_1 U10409 ( .A1(n9481), .A2(\cpuregs[14][4] ), .B1(
        n9321), .B2(\cpuregs[27][4] ), .Y(n8731) );
  sky130_fd_sc_hd__a22oi_1 U10410 ( .A1(n9457), .A2(\cpuregs[19][4] ), .B1(
        n9461), .B2(\cpuregs[5][4] ), .Y(n8730) );
  sky130_fd_sc_hd__nand2_1 U10411 ( .A(n9468), .B(\cpuregs[16][4] ), .Y(n8729)
         );
  sky130_fd_sc_hd__nand4_1 U10412 ( .A(n8732), .B(n8731), .C(n8730), .D(n8729), 
        .Y(n8748) );
  sky130_fd_sc_hd__a22oi_1 U10413 ( .A1(n9462), .A2(\cpuregs[2][4] ), .B1(
        n9493), .B2(\cpuregs[6][4] ), .Y(n8736) );
  sky130_fd_sc_hd__a22oi_1 U10414 ( .A1(n9471), .A2(\cpuregs[25][4] ), .B1(
        n9492), .B2(\cpuregs[28][4] ), .Y(n8735) );
  sky130_fd_sc_hd__a22oi_1 U10415 ( .A1(n9495), .A2(\cpuregs[22][4] ), .B1(
        n9494), .B2(\cpuregs[8][4] ), .Y(n8734) );
  sky130_fd_sc_hd__a22oi_1 U10416 ( .A1(n9289), .A2(\cpuregs[18][4] ), .B1(
        n9467), .B2(\cpuregs[26][4] ), .Y(n8733) );
  sky130_fd_sc_hd__nand4_1 U10417 ( .A(n8736), .B(n8735), .C(n8734), .D(n8733), 
        .Y(n8747) );
  sky130_fd_sc_hd__a22oi_1 U10418 ( .A1(n9491), .A2(\cpuregs[10][4] ), .B1(
        n9460), .B2(\cpuregs[24][4] ), .Y(n8740) );
  sky130_fd_sc_hd__a22oi_1 U10419 ( .A1(n9473), .A2(\cpuregs[23][4] ), .B1(
        n9484), .B2(\cpuregs[12][4] ), .Y(n8739) );
  sky130_fd_sc_hd__a22oi_1 U10420 ( .A1(n9456), .A2(\cpuregs[17][4] ), .B1(
        n9490), .B2(\cpuregs[11][4] ), .Y(n8738) );
  sky130_fd_sc_hd__a22oi_1 U10421 ( .A1(n9479), .A2(\cpuregs[29][4] ), .B1(
        n9480), .B2(\cpuregs[20][4] ), .Y(n8737) );
  sky130_fd_sc_hd__nand4_1 U10422 ( .A(n8740), .B(n8739), .C(n8738), .D(n8737), 
        .Y(n8746) );
  sky130_fd_sc_hd__a22oi_1 U10423 ( .A1(n9496), .A2(\cpuregs[3][4] ), .B1(
        n9483), .B2(\cpuregs[7][4] ), .Y(n8744) );
  sky130_fd_sc_hd__a22oi_1 U10424 ( .A1(n9482), .A2(\cpuregs[31][4] ), .B1(
        n9470), .B2(\cpuregs[13][4] ), .Y(n8743) );
  sky130_fd_sc_hd__a22oi_1 U10425 ( .A1(n9478), .A2(\cpuregs[1][4] ), .B1(
        n9458), .B2(\cpuregs[30][4] ), .Y(n8742) );
  sky130_fd_sc_hd__a22oi_1 U10426 ( .A1(n9469), .A2(\cpuregs[9][4] ), .B1(
        n9316), .B2(\cpuregs[4][4] ), .Y(n8741) );
  sky130_fd_sc_hd__nand4_1 U10427 ( .A(n8744), .B(n8743), .C(n8742), .D(n8741), 
        .Y(n8745) );
  sky130_fd_sc_hd__or4_1 U10428 ( .A(n8748), .B(n8747), .C(n8746), .D(n8745), 
        .X(n8751) );
  sky130_fd_sc_hd__a22oi_1 U10429 ( .A1(n9280), .A2(reg_pc[4]), .B1(n9452), 
        .B2(pcpi_rs1[4]), .Y(n8749) );
  sky130_fd_sc_hd__o21ai_1 U10430 ( .A1(n8786), .A2(n9454), .B1(n8749), .Y(
        n8750) );
  sky130_fd_sc_hd__a21oi_1 U10431 ( .A1(n8751), .A2(n8921), .B1(n8750), .Y(
        n8757) );
  sky130_fd_sc_hd__nand2_1 U10432 ( .A(n9110), .B(n9108), .Y(n8753) );
  sky130_fd_sc_hd__xnor2_1 U10433 ( .A(n8753), .B(n9111), .Y(n8754) );
  sky130_fd_sc_hd__a22oi_1 U10434 ( .A1(n9511), .A2(n8754), .B1(n8927), .B2(
        pcpi_rs1[3]), .Y(n8756) );
  sky130_fd_sc_hd__a22oi_1 U10435 ( .A1(n9307), .A2(pcpi_rs1[0]), .B1(
        pcpi_rs1[5]), .B2(n4456), .Y(n8755) );
  sky130_fd_sc_hd__nand3_1 U10436 ( .A(n8757), .B(n8756), .C(n8755), .Y(n2791)
         );
  sky130_fd_sc_hd__a22oi_1 U10437 ( .A1(n9493), .A2(\cpuregs[6][12] ), .B1(
        n9479), .B2(\cpuregs[29][12] ), .Y(n8761) );
  sky130_fd_sc_hd__a22oi_1 U10438 ( .A1(n9478), .A2(\cpuregs[1][12] ), .B1(
        n9457), .B2(\cpuregs[19][12] ), .Y(n8760) );
  sky130_fd_sc_hd__a22oi_1 U10439 ( .A1(n9496), .A2(\cpuregs[3][12] ), .B1(
        n9458), .B2(\cpuregs[30][12] ), .Y(n8759) );
  sky130_fd_sc_hd__nand2_1 U10440 ( .A(n9485), .B(\cpuregs[21][12] ), .Y(n8758) );
  sky130_fd_sc_hd__nand4_1 U10441 ( .A(n8761), .B(n8760), .C(n8759), .D(n8758), 
        .Y(n8777) );
  sky130_fd_sc_hd__a22oi_1 U10442 ( .A1(n9484), .A2(\cpuregs[12][12] ), .B1(
        n9473), .B2(\cpuregs[23][12] ), .Y(n8765) );
  sky130_fd_sc_hd__a22oi_1 U10443 ( .A1(n9491), .A2(\cpuregs[10][12] ), .B1(
        n9481), .B2(\cpuregs[14][12] ), .Y(n8764) );
  sky130_fd_sc_hd__a22oi_1 U10444 ( .A1(n9467), .A2(\cpuregs[26][12] ), .B1(
        n9469), .B2(\cpuregs[9][12] ), .Y(n8763) );
  sky130_fd_sc_hd__a22oi_1 U10445 ( .A1(n9462), .A2(\cpuregs[2][12] ), .B1(
        n9456), .B2(\cpuregs[17][12] ), .Y(n8762) );
  sky130_fd_sc_hd__nand4_1 U10446 ( .A(n8765), .B(n8764), .C(n8763), .D(n8762), 
        .Y(n8776) );
  sky130_fd_sc_hd__a22oi_1 U10447 ( .A1(n9471), .A2(\cpuregs[25][12] ), .B1(
        n9483), .B2(\cpuregs[7][12] ), .Y(n8769) );
  sky130_fd_sc_hd__a22oi_1 U10448 ( .A1(n9492), .A2(\cpuregs[28][12] ), .B1(
        n9480), .B2(\cpuregs[20][12] ), .Y(n8768) );
  sky130_fd_sc_hd__a22oi_1 U10449 ( .A1(n9490), .A2(\cpuregs[11][12] ), .B1(
        n9495), .B2(\cpuregs[22][12] ), .Y(n8767) );
  sky130_fd_sc_hd__a22oi_1 U10450 ( .A1(n9472), .A2(\cpuregs[4][12] ), .B1(
        n9497), .B2(\cpuregs[15][12] ), .Y(n8766) );
  sky130_fd_sc_hd__nand4_1 U10451 ( .A(n8769), .B(n8768), .C(n8767), .D(n8766), 
        .Y(n8775) );
  sky130_fd_sc_hd__a22oi_1 U10452 ( .A1(n9482), .A2(\cpuregs[31][12] ), .B1(
        n9289), .B2(\cpuregs[18][12] ), .Y(n8773) );
  sky130_fd_sc_hd__a22oi_1 U10453 ( .A1(n8937), .A2(\cpuregs[13][12] ), .B1(
        n9468), .B2(\cpuregs[16][12] ), .Y(n8772) );
  sky130_fd_sc_hd__a22oi_1 U10454 ( .A1(n9460), .A2(\cpuregs[24][12] ), .B1(
        n9461), .B2(\cpuregs[5][12] ), .Y(n8771) );
  sky130_fd_sc_hd__a22oi_1 U10455 ( .A1(n9321), .A2(\cpuregs[27][12] ), .B1(
        n9494), .B2(\cpuregs[8][12] ), .Y(n8770) );
  sky130_fd_sc_hd__nand4_1 U10456 ( .A(n8773), .B(n8772), .C(n8771), .D(n8770), 
        .Y(n8774) );
  sky130_fd_sc_hd__nor4_1 U10457 ( .A(n8777), .B(n8776), .C(n8775), .D(n8774), 
        .Y(n8792) );
  sky130_fd_sc_hd__o22ai_1 U10458 ( .A1(n4321), .A2(n8779), .B1(n8778), .B2(
        n9340), .Y(n8780) );
  sky130_fd_sc_hd__a21oi_1 U10459 ( .A1(n9345), .A2(pcpi_rs1[16]), .B1(n8780), 
        .Y(n8791) );
  sky130_fd_sc_hd__nand2_1 U10460 ( .A(n8782), .B(n8781), .Y(n8783) );
  sky130_fd_sc_hd__xor2_1 U10461 ( .A(n8784), .B(n8783), .X(n8789) );
  sky130_fd_sc_hd__nor2_1 U10462 ( .A(n8820), .B(n4340), .Y(n8788) );
  sky130_fd_sc_hd__o22ai_1 U10463 ( .A1(n8786), .A2(n4371), .B1(n8785), .B2(
        n4342), .Y(n8787) );
  sky130_fd_sc_hd__a211oi_1 U10464 ( .A1(n9511), .A2(n8789), .B1(n8788), .C1(
        n8787), .Y(n8790) );
  sky130_fd_sc_hd__o211ai_1 U10465 ( .A1(n8792), .A2(n9506), .B1(n8791), .C1(
        n8790), .Y(n2783) );
  sky130_fd_sc_hd__a22oi_1 U10466 ( .A1(n9495), .A2(\cpuregs[22][10] ), .B1(
        n9484), .B2(\cpuregs[12][10] ), .Y(n8796) );
  sky130_fd_sc_hd__a22oi_1 U10467 ( .A1(n9462), .A2(\cpuregs[2][10] ), .B1(
        n9469), .B2(\cpuregs[9][10] ), .Y(n8795) );
  sky130_fd_sc_hd__a22oi_1 U10468 ( .A1(n9497), .A2(\cpuregs[15][10] ), .B1(
        n9457), .B2(\cpuregs[19][10] ), .Y(n8794) );
  sky130_fd_sc_hd__nand2_1 U10469 ( .A(n9483), .B(\cpuregs[7][10] ), .Y(n8793)
         );
  sky130_fd_sc_hd__nand4_1 U10470 ( .A(n8796), .B(n8795), .C(n8794), .D(n8793), 
        .Y(n8812) );
  sky130_fd_sc_hd__a22oi_1 U10471 ( .A1(n9461), .A2(\cpuregs[5][10] ), .B1(
        n9459), .B2(\cpuregs[18][10] ), .Y(n8800) );
  sky130_fd_sc_hd__a22oi_1 U10472 ( .A1(n9492), .A2(\cpuregs[28][10] ), .B1(
        n9496), .B2(\cpuregs[3][10] ), .Y(n8799) );
  sky130_fd_sc_hd__a22oi_1 U10473 ( .A1(n9468), .A2(\cpuregs[16][10] ), .B1(
        n9467), .B2(\cpuregs[26][10] ), .Y(n8798) );
  sky130_fd_sc_hd__a22oi_1 U10474 ( .A1(n9494), .A2(\cpuregs[8][10] ), .B1(
        n9460), .B2(\cpuregs[24][10] ), .Y(n8797) );
  sky130_fd_sc_hd__nand4_1 U10475 ( .A(n8800), .B(n8799), .C(n8798), .D(n8797), 
        .Y(n8811) );
  sky130_fd_sc_hd__a22oi_1 U10476 ( .A1(n9485), .A2(\cpuregs[21][10] ), .B1(
        n9321), .B2(\cpuregs[27][10] ), .Y(n8804) );
  sky130_fd_sc_hd__a22oi_1 U10477 ( .A1(n9471), .A2(\cpuregs[25][10] ), .B1(
        n9470), .B2(\cpuregs[13][10] ), .Y(n8803) );
  sky130_fd_sc_hd__a22oi_1 U10478 ( .A1(n9491), .A2(\cpuregs[10][10] ), .B1(
        n9490), .B2(\cpuregs[11][10] ), .Y(n8802) );
  sky130_fd_sc_hd__a22oi_1 U10479 ( .A1(n9481), .A2(\cpuregs[14][10] ), .B1(
        n9479), .B2(\cpuregs[29][10] ), .Y(n8801) );
  sky130_fd_sc_hd__nand4_1 U10480 ( .A(n8804), .B(n8803), .C(n8802), .D(n8801), 
        .Y(n8810) );
  sky130_fd_sc_hd__a22oi_1 U10481 ( .A1(n9478), .A2(\cpuregs[1][10] ), .B1(
        n9458), .B2(\cpuregs[30][10] ), .Y(n8808) );
  sky130_fd_sc_hd__a22oi_1 U10482 ( .A1(n9473), .A2(\cpuregs[23][10] ), .B1(
        n9456), .B2(\cpuregs[17][10] ), .Y(n8807) );
  sky130_fd_sc_hd__a22oi_1 U10483 ( .A1(n9480), .A2(\cpuregs[20][10] ), .B1(
        n9482), .B2(\cpuregs[31][10] ), .Y(n8806) );
  sky130_fd_sc_hd__a22oi_1 U10484 ( .A1(n9493), .A2(\cpuregs[6][10] ), .B1(
        n9316), .B2(\cpuregs[4][10] ), .Y(n8805) );
  sky130_fd_sc_hd__nand4_1 U10485 ( .A(n8808), .B(n8807), .C(n8806), .D(n8805), 
        .Y(n8809) );
  sky130_fd_sc_hd__nor4_1 U10486 ( .A(n8812), .B(n8811), .C(n8810), .D(n8809), 
        .Y(n8826) );
  sky130_fd_sc_hd__o22ai_1 U10487 ( .A1(n4321), .A2(n9737), .B1(n8813), .B2(
        n9340), .Y(n8814) );
  sky130_fd_sc_hd__a21oi_1 U10488 ( .A1(n9345), .A2(pcpi_rs1[14]), .B1(n8814), 
        .Y(n8825) );
  sky130_fd_sc_hd__nand2_1 U10489 ( .A(n8816), .B(n8815), .Y(n8818) );
  sky130_fd_sc_hd__xnor2_1 U10490 ( .A(n8818), .B(n8817), .Y(n8823) );
  sky130_fd_sc_hd__nor2_1 U10491 ( .A(n8819), .B(n4340), .Y(n8822) );
  sky130_fd_sc_hd__o22ai_1 U10492 ( .A1(n9117), .A2(n4371), .B1(n4342), .B2(
        n8820), .Y(n8821) );
  sky130_fd_sc_hd__a211oi_1 U10493 ( .A1(n9511), .A2(n8823), .B1(n8822), .C1(
        n8821), .Y(n8824) );
  sky130_fd_sc_hd__o211ai_1 U10494 ( .A1(n8826), .A2(n9506), .B1(n8825), .C1(
        n8824), .Y(n2785) );
  sky130_fd_sc_hd__a22oi_1 U10495 ( .A1(n9307), .A2(pcpi_rs1[10]), .B1(
        pcpi_rs1[13]), .B2(n8927), .Y(n8859) );
  sky130_fd_sc_hd__a22oi_1 U10496 ( .A1(n9280), .A2(reg_pc[14]), .B1(n9345), 
        .B2(pcpi_rs1[18]), .Y(n8858) );
  sky130_fd_sc_hd__a22oi_1 U10497 ( .A1(n9478), .A2(\cpuregs[1][14] ), .B1(
        n9496), .B2(\cpuregs[3][14] ), .Y(n8830) );
  sky130_fd_sc_hd__a22oi_1 U10498 ( .A1(n9493), .A2(\cpuregs[6][14] ), .B1(
        n9456), .B2(\cpuregs[17][14] ), .Y(n8829) );
  sky130_fd_sc_hd__nand2_1 U10499 ( .A(n9484), .B(\cpuregs[12][14] ), .Y(n8828) );
  sky130_fd_sc_hd__a22oi_1 U10500 ( .A1(n9462), .A2(\cpuregs[2][14] ), .B1(
        n9316), .B2(\cpuregs[4][14] ), .Y(n8827) );
  sky130_fd_sc_hd__nand4_1 U10501 ( .A(n8830), .B(n8829), .C(n8828), .D(n8827), 
        .Y(n8846) );
  sky130_fd_sc_hd__a22oi_1 U10502 ( .A1(n9480), .A2(\cpuregs[20][14] ), .B1(
        n9473), .B2(\cpuregs[23][14] ), .Y(n8834) );
  sky130_fd_sc_hd__a22oi_1 U10503 ( .A1(n9490), .A2(\cpuregs[11][14] ), .B1(
        n9491), .B2(\cpuregs[10][14] ), .Y(n8833) );
  sky130_fd_sc_hd__a22oi_1 U10504 ( .A1(n9321), .A2(\cpuregs[27][14] ), .B1(
        n9471), .B2(\cpuregs[25][14] ), .Y(n8832) );
  sky130_fd_sc_hd__a22oi_1 U10505 ( .A1(n9460), .A2(\cpuregs[24][14] ), .B1(
        n9485), .B2(\cpuregs[21][14] ), .Y(n8831) );
  sky130_fd_sc_hd__nand4_1 U10506 ( .A(n8834), .B(n8833), .C(n8832), .D(n8831), 
        .Y(n8845) );
  sky130_fd_sc_hd__a22oi_1 U10507 ( .A1(n9468), .A2(\cpuregs[16][14] ), .B1(
        n9289), .B2(\cpuregs[18][14] ), .Y(n8838) );
  sky130_fd_sc_hd__a22oi_1 U10508 ( .A1(n9467), .A2(\cpuregs[26][14] ), .B1(
        n9494), .B2(\cpuregs[8][14] ), .Y(n8837) );
  sky130_fd_sc_hd__a22oi_1 U10509 ( .A1(n9483), .A2(\cpuregs[7][14] ), .B1(
        n9461), .B2(\cpuregs[5][14] ), .Y(n8836) );
  sky130_fd_sc_hd__a22oi_1 U10510 ( .A1(n9469), .A2(\cpuregs[9][14] ), .B1(
        n9457), .B2(\cpuregs[19][14] ), .Y(n8835) );
  sky130_fd_sc_hd__nand4_1 U10511 ( .A(n8838), .B(n8837), .C(n8836), .D(n8835), 
        .Y(n8844) );
  sky130_fd_sc_hd__a22oi_1 U10512 ( .A1(n9481), .A2(\cpuregs[14][14] ), .B1(
        n9470), .B2(\cpuregs[13][14] ), .Y(n8842) );
  sky130_fd_sc_hd__a22oi_1 U10513 ( .A1(n9482), .A2(\cpuregs[31][14] ), .B1(
        n9495), .B2(\cpuregs[22][14] ), .Y(n8841) );
  sky130_fd_sc_hd__a22oi_1 U10514 ( .A1(n9458), .A2(\cpuregs[30][14] ), .B1(
        n9479), .B2(\cpuregs[29][14] ), .Y(n8840) );
  sky130_fd_sc_hd__a22oi_1 U10515 ( .A1(n9492), .A2(\cpuregs[28][14] ), .B1(
        n9497), .B2(\cpuregs[15][14] ), .Y(n8839) );
  sky130_fd_sc_hd__nand4_1 U10516 ( .A(n8842), .B(n8841), .C(n8840), .D(n8839), 
        .Y(n8843) );
  sky130_fd_sc_hd__nor4_1 U10517 ( .A(n8846), .B(n8845), .C(n8844), .D(n8843), 
        .Y(n8847) );
  sky130_fd_sc_hd__o22ai_1 U10518 ( .A1(n8849), .A2(n8848), .B1(n8847), .B2(
        n9302), .Y(n8850) );
  sky130_fd_sc_hd__mux2i_1 U10519 ( .A0(pcpi_rs1[14]), .A1(n8850), .S(n9340), 
        .Y(n8857) );
  sky130_fd_sc_hd__nand2_1 U10520 ( .A(n8852), .B(n8851), .Y(n8854) );
  sky130_fd_sc_hd__xnor2_1 U10521 ( .A(n8854), .B(n8853), .Y(n8855) );
  sky130_fd_sc_hd__nand2_1 U10522 ( .A(n9511), .B(n8855), .Y(n8856) );
  sky130_fd_sc_hd__nand4_1 U10523 ( .A(n8859), .B(n8858), .C(n8857), .D(n8856), 
        .Y(n2781) );
  sky130_fd_sc_hd__a22oi_1 U10524 ( .A1(n9460), .A2(\cpuregs[24][18] ), .B1(
        n9468), .B2(\cpuregs[16][18] ), .Y(n8863) );
  sky130_fd_sc_hd__a22oi_1 U10525 ( .A1(n9491), .A2(\cpuregs[10][18] ), .B1(
        n9492), .B2(\cpuregs[28][18] ), .Y(n8862) );
  sky130_fd_sc_hd__a22oi_1 U10526 ( .A1(n9321), .A2(\cpuregs[27][18] ), .B1(
        n9495), .B2(\cpuregs[22][18] ), .Y(n8861) );
  sky130_fd_sc_hd__nand2_1 U10527 ( .A(n9497), .B(\cpuregs[15][18] ), .Y(n8860) );
  sky130_fd_sc_hd__nand4_1 U10528 ( .A(n8863), .B(n8862), .C(n8861), .D(n8860), 
        .Y(n8879) );
  sky130_fd_sc_hd__a22oi_1 U10529 ( .A1(n9480), .A2(\cpuregs[20][18] ), .B1(
        n9485), .B2(\cpuregs[21][18] ), .Y(n8867) );
  sky130_fd_sc_hd__a22oi_1 U10530 ( .A1(n9481), .A2(\cpuregs[14][18] ), .B1(
        n9459), .B2(\cpuregs[18][18] ), .Y(n8866) );
  sky130_fd_sc_hd__a22oi_1 U10531 ( .A1(n9483), .A2(\cpuregs[7][18] ), .B1(
        n9482), .B2(\cpuregs[31][18] ), .Y(n8865) );
  sky130_fd_sc_hd__a22oi_1 U10532 ( .A1(n9471), .A2(\cpuregs[25][18] ), .B1(
        n9462), .B2(\cpuregs[2][18] ), .Y(n8864) );
  sky130_fd_sc_hd__nand4_1 U10533 ( .A(n8867), .B(n8866), .C(n8865), .D(n8864), 
        .Y(n8878) );
  sky130_fd_sc_hd__a22oi_1 U10534 ( .A1(n9467), .A2(\cpuregs[26][18] ), .B1(
        n8937), .B2(\cpuregs[13][18] ), .Y(n8871) );
  sky130_fd_sc_hd__a22oi_1 U10535 ( .A1(n9316), .A2(\cpuregs[4][18] ), .B1(
        n9473), .B2(\cpuregs[23][18] ), .Y(n8870) );
  sky130_fd_sc_hd__a22oi_1 U10536 ( .A1(n9494), .A2(\cpuregs[8][18] ), .B1(
        n9496), .B2(\cpuregs[3][18] ), .Y(n8869) );
  sky130_fd_sc_hd__a22oi_1 U10537 ( .A1(n9490), .A2(\cpuregs[11][18] ), .B1(
        n9469), .B2(\cpuregs[9][18] ), .Y(n8868) );
  sky130_fd_sc_hd__nand4_1 U10538 ( .A(n8871), .B(n8870), .C(n8869), .D(n8868), 
        .Y(n8877) );
  sky130_fd_sc_hd__a22oi_1 U10539 ( .A1(n9478), .A2(\cpuregs[1][18] ), .B1(
        n9493), .B2(\cpuregs[6][18] ), .Y(n8875) );
  sky130_fd_sc_hd__a22oi_1 U10540 ( .A1(n9479), .A2(\cpuregs[29][18] ), .B1(
        n9456), .B2(\cpuregs[17][18] ), .Y(n8874) );
  sky130_fd_sc_hd__a22oi_1 U10541 ( .A1(n9458), .A2(\cpuregs[30][18] ), .B1(
        n9457), .B2(\cpuregs[19][18] ), .Y(n8873) );
  sky130_fd_sc_hd__a22oi_1 U10542 ( .A1(n9461), .A2(\cpuregs[5][18] ), .B1(
        n9484), .B2(\cpuregs[12][18] ), .Y(n8872) );
  sky130_fd_sc_hd__nand4_1 U10543 ( .A(n8875), .B(n8874), .C(n8873), .D(n8872), 
        .Y(n8876) );
  sky130_fd_sc_hd__nor4_1 U10544 ( .A(n8879), .B(n8878), .C(n8877), .D(n8876), 
        .Y(n8896) );
  sky130_fd_sc_hd__o22ai_1 U10545 ( .A1(n4321), .A2(n8881), .B1(n8880), .B2(
        n9340), .Y(n8882) );
  sky130_fd_sc_hd__a21oi_1 U10546 ( .A1(n9345), .A2(pcpi_rs1[22]), .B1(n8882), 
        .Y(n8895) );
  sky130_fd_sc_hd__nand2_1 U10547 ( .A(n8885), .B(n8884), .Y(n8886) );
  sky130_fd_sc_hd__xor2_1 U10548 ( .A(n8887), .B(n8886), .X(n8893) );
  sky130_fd_sc_hd__nor2_1 U10549 ( .A(n8888), .B(n4340), .Y(n8892) );
  sky130_fd_sc_hd__o22ai_1 U10550 ( .A1(n8890), .A2(n4342), .B1(n8889), .B2(
        n4371), .Y(n8891) );
  sky130_fd_sc_hd__a211oi_1 U10551 ( .A1(n9511), .A2(n8893), .B1(n8892), .C1(
        n8891), .Y(n8894) );
  sky130_fd_sc_hd__o211ai_1 U10552 ( .A1(n8896), .A2(n9506), .B1(n8895), .C1(
        n8894), .Y(n2777) );
  sky130_fd_sc_hd__a22oi_1 U10553 ( .A1(n9468), .A2(\cpuregs[16][22] ), .B1(
        n9289), .B2(\cpuregs[18][22] ), .Y(n8900) );
  sky130_fd_sc_hd__a22oi_1 U10554 ( .A1(n9467), .A2(\cpuregs[26][22] ), .B1(
        n9494), .B2(\cpuregs[8][22] ), .Y(n8899) );
  sky130_fd_sc_hd__a22oi_1 U10555 ( .A1(n9483), .A2(\cpuregs[7][22] ), .B1(
        n9461), .B2(\cpuregs[5][22] ), .Y(n8898) );
  sky130_fd_sc_hd__a22oi_1 U10556 ( .A1(n9469), .A2(\cpuregs[9][22] ), .B1(
        n9457), .B2(\cpuregs[19][22] ), .Y(n8897) );
  sky130_fd_sc_hd__nand4_1 U10557 ( .A(n8900), .B(n8899), .C(n8898), .D(n8897), 
        .Y(n8916) );
  sky130_fd_sc_hd__a22oi_1 U10558 ( .A1(n9480), .A2(\cpuregs[20][22] ), .B1(
        n9473), .B2(\cpuregs[23][22] ), .Y(n8904) );
  sky130_fd_sc_hd__a22oi_1 U10559 ( .A1(n9490), .A2(\cpuregs[11][22] ), .B1(
        n9491), .B2(\cpuregs[10][22] ), .Y(n8903) );
  sky130_fd_sc_hd__a22oi_1 U10560 ( .A1(n9321), .A2(\cpuregs[27][22] ), .B1(
        n9471), .B2(\cpuregs[25][22] ), .Y(n8902) );
  sky130_fd_sc_hd__a22oi_1 U10561 ( .A1(n8946), .A2(\cpuregs[24][22] ), .B1(
        n9485), .B2(\cpuregs[21][22] ), .Y(n8901) );
  sky130_fd_sc_hd__nand4_1 U10562 ( .A(n8904), .B(n8903), .C(n8902), .D(n8901), 
        .Y(n8915) );
  sky130_fd_sc_hd__a22oi_1 U10563 ( .A1(n9478), .A2(\cpuregs[1][22] ), .B1(
        n9496), .B2(\cpuregs[3][22] ), .Y(n8908) );
  sky130_fd_sc_hd__a22oi_1 U10564 ( .A1(n9493), .A2(\cpuregs[6][22] ), .B1(
        n9456), .B2(\cpuregs[17][22] ), .Y(n8907) );
  sky130_fd_sc_hd__nand2_1 U10565 ( .A(n9484), .B(\cpuregs[12][22] ), .Y(n8906) );
  sky130_fd_sc_hd__a22oi_1 U10566 ( .A1(n9462), .A2(\cpuregs[2][22] ), .B1(
        n9472), .B2(\cpuregs[4][22] ), .Y(n8905) );
  sky130_fd_sc_hd__nand4_1 U10567 ( .A(n8908), .B(n8907), .C(n8906), .D(n8905), 
        .Y(n8914) );
  sky130_fd_sc_hd__a22oi_1 U10568 ( .A1(n9481), .A2(\cpuregs[14][22] ), .B1(
        n9470), .B2(\cpuregs[13][22] ), .Y(n8912) );
  sky130_fd_sc_hd__a22oi_1 U10569 ( .A1(n9482), .A2(\cpuregs[31][22] ), .B1(
        n9495), .B2(\cpuregs[22][22] ), .Y(n8911) );
  sky130_fd_sc_hd__a22oi_1 U10570 ( .A1(n9458), .A2(\cpuregs[30][22] ), .B1(
        n9479), .B2(\cpuregs[29][22] ), .Y(n8910) );
  sky130_fd_sc_hd__a22oi_1 U10571 ( .A1(n9492), .A2(\cpuregs[28][22] ), .B1(
        n9497), .B2(\cpuregs[15][22] ), .Y(n8909) );
  sky130_fd_sc_hd__nand4_1 U10572 ( .A(n8912), .B(n8911), .C(n8910), .D(n8909), 
        .Y(n8913) );
  sky130_fd_sc_hd__or4_1 U10573 ( .A(n8916), .B(n8915), .C(n8914), .D(n8913), 
        .X(n8920) );
  sky130_fd_sc_hd__a22oi_1 U10574 ( .A1(n9280), .A2(reg_pc[22]), .B1(n9452), 
        .B2(pcpi_rs1[22]), .Y(n8917) );
  sky130_fd_sc_hd__o21ai_1 U10575 ( .A1(n8918), .A2(n9454), .B1(n8917), .Y(
        n8919) );
  sky130_fd_sc_hd__a21oi_1 U10576 ( .A1(n8921), .A2(n8920), .B1(n8919), .Y(
        n8930) );
  sky130_fd_sc_hd__nand2_1 U10577 ( .A(n8923), .B(n8922), .Y(n8925) );
  sky130_fd_sc_hd__xnor2_1 U10578 ( .A(n8925), .B(n8924), .Y(n8926) );
  sky130_fd_sc_hd__a22oi_1 U10579 ( .A1(pcpi_rs1[21]), .A2(n8927), .B1(n8926), 
        .B2(n9511), .Y(n8929) );
  sky130_fd_sc_hd__a22oi_1 U10580 ( .A1(n9307), .A2(pcpi_rs1[18]), .B1(
        pcpi_rs1[23]), .B2(n4456), .Y(n8928) );
  sky130_fd_sc_hd__nand3_1 U10581 ( .A(n8930), .B(n8929), .C(n8928), .Y(n2773)
         );
  sky130_fd_sc_hd__o22ai_1 U10582 ( .A1(n8932), .A2(n4340), .B1(n8931), .B2(
        n4342), .Y(n8969) );
  sky130_fd_sc_hd__a22oi_1 U10583 ( .A1(n9494), .A2(\cpuregs[8][26] ), .B1(
        n9458), .B2(\cpuregs[30][26] ), .Y(n8936) );
  sky130_fd_sc_hd__a22oi_1 U10584 ( .A1(n9462), .A2(\cpuregs[2][26] ), .B1(
        n9481), .B2(\cpuregs[14][26] ), .Y(n8935) );
  sky130_fd_sc_hd__a22oi_1 U10585 ( .A1(n9497), .A2(\cpuregs[15][26] ), .B1(
        n9456), .B2(\cpuregs[17][26] ), .Y(n8934) );
  sky130_fd_sc_hd__nand2_1 U10586 ( .A(n9478), .B(\cpuregs[1][26] ), .Y(n8933)
         );
  sky130_fd_sc_hd__nand4_1 U10587 ( .A(n8936), .B(n8935), .C(n8934), .D(n8933), 
        .Y(n8954) );
  sky130_fd_sc_hd__a22oi_1 U10588 ( .A1(n9461), .A2(\cpuregs[5][26] ), .B1(
        n9495), .B2(\cpuregs[22][26] ), .Y(n8941) );
  sky130_fd_sc_hd__a22oi_1 U10589 ( .A1(n9496), .A2(\cpuregs[3][26] ), .B1(
        n8937), .B2(\cpuregs[13][26] ), .Y(n8940) );
  sky130_fd_sc_hd__a22oi_1 U10590 ( .A1(n9480), .A2(\cpuregs[20][26] ), .B1(
        n9289), .B2(\cpuregs[18][26] ), .Y(n8939) );
  sky130_fd_sc_hd__a22oi_1 U10591 ( .A1(n9491), .A2(\cpuregs[10][26] ), .B1(
        n9469), .B2(\cpuregs[9][26] ), .Y(n8938) );
  sky130_fd_sc_hd__nand4_1 U10592 ( .A(n8941), .B(n8940), .C(n8939), .D(n8938), 
        .Y(n8953) );
  sky130_fd_sc_hd__a22oi_1 U10593 ( .A1(n9490), .A2(\cpuregs[11][26] ), .B1(
        n9484), .B2(\cpuregs[12][26] ), .Y(n8945) );
  sky130_fd_sc_hd__a22oi_1 U10594 ( .A1(n9467), .A2(\cpuregs[26][26] ), .B1(
        n9479), .B2(\cpuregs[29][26] ), .Y(n8944) );
  sky130_fd_sc_hd__a22oi_1 U10595 ( .A1(n9493), .A2(\cpuregs[6][26] ), .B1(
        n9485), .B2(\cpuregs[21][26] ), .Y(n8943) );
  sky130_fd_sc_hd__a22oi_1 U10596 ( .A1(n9321), .A2(\cpuregs[27][26] ), .B1(
        n9468), .B2(\cpuregs[16][26] ), .Y(n8942) );
  sky130_fd_sc_hd__nand4_1 U10597 ( .A(n8945), .B(n8944), .C(n8943), .D(n8942), 
        .Y(n8952) );
  sky130_fd_sc_hd__a22oi_1 U10598 ( .A1(n8946), .A2(\cpuregs[24][26] ), .B1(
        n9482), .B2(\cpuregs[31][26] ), .Y(n8950) );
  sky130_fd_sc_hd__a22oi_1 U10599 ( .A1(n9492), .A2(\cpuregs[28][26] ), .B1(
        n9457), .B2(\cpuregs[19][26] ), .Y(n8949) );
  sky130_fd_sc_hd__a22oi_1 U10600 ( .A1(n9471), .A2(\cpuregs[25][26] ), .B1(
        n9473), .B2(\cpuregs[23][26] ), .Y(n8948) );
  sky130_fd_sc_hd__a22oi_1 U10601 ( .A1(n9316), .A2(\cpuregs[4][26] ), .B1(
        n9483), .B2(\cpuregs[7][26] ), .Y(n8947) );
  sky130_fd_sc_hd__nand4_1 U10602 ( .A(n8950), .B(n8949), .C(n8948), .D(n8947), 
        .Y(n8951) );
  sky130_fd_sc_hd__nor4_1 U10603 ( .A(n8954), .B(n8953), .C(n8952), .D(n8951), 
        .Y(n8956) );
  sky130_fd_sc_hd__o22ai_1 U10604 ( .A1(n8956), .A2(n9506), .B1(n8955), .B2(
        n4371), .Y(n8968) );
  sky130_fd_sc_hd__a22oi_1 U10605 ( .A1(n9280), .A2(reg_pc[26]), .B1(n9452), 
        .B2(pcpi_rs1[26]), .Y(n8966) );
  sky130_fd_sc_hd__a21oi_1 U10606 ( .A1(n8959), .A2(n8958), .B1(n8957), .Y(
        n8963) );
  sky130_fd_sc_hd__nand2_1 U10607 ( .A(n8961), .B(n8960), .Y(n8962) );
  sky130_fd_sc_hd__xor2_1 U10608 ( .A(n8963), .B(n8962), .X(n8964) );
  sky130_fd_sc_hd__nand2_1 U10609 ( .A(n8964), .B(n9511), .Y(n8965) );
  sky130_fd_sc_hd__o211ai_1 U10610 ( .A1(n9454), .A2(n9305), .B1(n8966), .C1(
        n8965), .Y(n8967) );
  sky130_fd_sc_hd__or3_1 U10611 ( .A(n8969), .B(n8968), .C(n8967), .X(n2769)
         );
  sky130_fd_sc_hd__a222oi_1 U10612 ( .A1(reg_out[30]), .A2(n9816), .B1(
        alu_out_q[30]), .B2(n9815), .C1(n8971), .C2(n9813), .Y(n8985) );
  sky130_fd_sc_hd__nand2_1 U10613 ( .A(n7084), .B(\cpuregs[22][30] ), .Y(n8972) );
  sky130_fd_sc_hd__o21ai_1 U10614 ( .A1(n7084), .A2(n4190), .B1(n8972), .Y(
        n2987) );
  sky130_fd_sc_hd__nand2_1 U10615 ( .A(n4226), .B(\cpuregs[12][30] ), .Y(n8973) );
  sky130_fd_sc_hd__o21ai_1 U10616 ( .A1(n4226), .A2(n4190), .B1(n8973), .Y(
        n2977) );
  sky130_fd_sc_hd__nand2_1 U10617 ( .A(n4178), .B(\cpuregs[2][30] ), .Y(n8974)
         );
  sky130_fd_sc_hd__o21ai_1 U10618 ( .A1(n4178), .A2(n4190), .B1(n8974), .Y(
        n2967) );
  sky130_fd_sc_hd__nand2_1 U10619 ( .A(n7452), .B(\cpuregs[9][30] ), .Y(n8975)
         );
  sky130_fd_sc_hd__o21ai_1 U10620 ( .A1(n7452), .A2(n4190), .B1(n8975), .Y(
        n2974) );
  sky130_fd_sc_hd__nand2_1 U10621 ( .A(n7069), .B(\cpuregs[15][30] ), .Y(n8976) );
  sky130_fd_sc_hd__o21ai_1 U10622 ( .A1(n7069), .A2(n4190), .B1(n8976), .Y(
        n2980) );
  sky130_fd_sc_hd__nand2_1 U10623 ( .A(n4194), .B(\cpuregs[19][30] ), .Y(n8977) );
  sky130_fd_sc_hd__o21ai_1 U10624 ( .A1(n4194), .A2(n4190), .B1(n8977), .Y(
        n2984) );
  sky130_fd_sc_hd__nand2_1 U10625 ( .A(n4199), .B(\cpuregs[7][30] ), .Y(n8978)
         );
  sky130_fd_sc_hd__o21ai_1 U10626 ( .A1(n4199), .A2(n4190), .B1(n8978), .Y(
        n2972) );
  sky130_fd_sc_hd__nand2_1 U10627 ( .A(n4180), .B(\cpuregs[5][30] ), .Y(n8979)
         );
  sky130_fd_sc_hd__o21ai_1 U10628 ( .A1(n4180), .A2(n4190), .B1(n8979), .Y(
        n2970) );
  sky130_fd_sc_hd__nand2_1 U10629 ( .A(n9820), .B(\cpuregs[18][30] ), .Y(n8980) );
  sky130_fd_sc_hd__o21ai_1 U10630 ( .A1(n9820), .A2(n4190), .B1(n8980), .Y(
        n2983) );
  sky130_fd_sc_hd__nand2_1 U10631 ( .A(n4219), .B(\cpuregs[28][30] ), .Y(n8981) );
  sky130_fd_sc_hd__o21ai_1 U10632 ( .A1(n4219), .A2(n4190), .B1(n8981), .Y(
        n2993) );
  sky130_fd_sc_hd__nand2_1 U10633 ( .A(n4201), .B(\cpuregs[3][30] ), .Y(n8982)
         );
  sky130_fd_sc_hd__o21ai_1 U10634 ( .A1(n4201), .A2(n4190), .B1(n8982), .Y(
        n2968) );
  sky130_fd_sc_hd__nand2_1 U10635 ( .A(n4197), .B(\cpuregs[16][30] ), .Y(n8983) );
  sky130_fd_sc_hd__o21ai_1 U10636 ( .A1(n4197), .A2(n4190), .B1(n8983), .Y(
        n2981) );
  sky130_fd_sc_hd__nand2_1 U10637 ( .A(n9621), .B(\cpuregs[26][30] ), .Y(n8984) );
  sky130_fd_sc_hd__o21ai_1 U10638 ( .A1(n9621), .A2(n4190), .B1(n8984), .Y(
        n2991) );
  sky130_fd_sc_hd__nand2_1 U10639 ( .A(n4183), .B(\cpuregs[8][30] ), .Y(n8986)
         );
  sky130_fd_sc_hd__o21ai_1 U10640 ( .A1(n4183), .A2(n4190), .B1(n8986), .Y(
        n2973) );
  sky130_fd_sc_hd__nand2_1 U10641 ( .A(n10057), .B(\cpuregs[24][30] ), .Y(
        n8987) );
  sky130_fd_sc_hd__o21ai_1 U10642 ( .A1(n10057), .A2(n4190), .B1(n8987), .Y(
        n2989) );
  sky130_fd_sc_hd__nand2_1 U10643 ( .A(n4174), .B(\cpuregs[21][30] ), .Y(n8988) );
  sky130_fd_sc_hd__o21ai_1 U10644 ( .A1(n4174), .A2(n4190), .B1(n8988), .Y(
        n2986) );
  sky130_fd_sc_hd__nand2_1 U10645 ( .A(n4175), .B(\cpuregs[27][30] ), .Y(n8989) );
  sky130_fd_sc_hd__o21ai_1 U10646 ( .A1(n4175), .A2(n4190), .B1(n8989), .Y(
        n2992) );
  sky130_fd_sc_hd__nand2_1 U10647 ( .A(n4192), .B(\cpuregs[25][30] ), .Y(n8990) );
  sky130_fd_sc_hd__o21ai_1 U10648 ( .A1(n4192), .A2(n4190), .B1(n8990), .Y(
        n2990) );
  sky130_fd_sc_hd__nand2_1 U10649 ( .A(n4186), .B(\cpuregs[13][30] ), .Y(n8991) );
  sky130_fd_sc_hd__o21ai_1 U10650 ( .A1(n4186), .A2(n4190), .B1(n8991), .Y(
        n2978) );
  sky130_fd_sc_hd__nand2_1 U10651 ( .A(n4184), .B(\cpuregs[10][30] ), .Y(n8992) );
  sky130_fd_sc_hd__o21ai_1 U10652 ( .A1(n4184), .A2(n4190), .B1(n8992), .Y(
        n2975) );
  sky130_fd_sc_hd__nand2_1 U10653 ( .A(n4185), .B(\cpuregs[11][30] ), .Y(n8993) );
  sky130_fd_sc_hd__o21ai_1 U10654 ( .A1(n4185), .A2(n4190), .B1(n8993), .Y(
        n2976) );
  sky130_fd_sc_hd__nand2_1 U10655 ( .A(n6897), .B(\cpuregs[14][30] ), .Y(n8994) );
  sky130_fd_sc_hd__o21ai_1 U10656 ( .A1(n6897), .A2(n4190), .B1(n8994), .Y(
        n2979) );
  sky130_fd_sc_hd__nand2_1 U10657 ( .A(n4176), .B(\cpuregs[29][30] ), .Y(n8995) );
  sky130_fd_sc_hd__o21ai_1 U10658 ( .A1(n4176), .A2(n4190), .B1(n8995), .Y(
        n2994) );
  sky130_fd_sc_hd__nand2_1 U10659 ( .A(n6396), .B(\cpuregs[1][30] ), .Y(n8996)
         );
  sky130_fd_sc_hd__o21ai_1 U10660 ( .A1(n6396), .A2(n4190), .B1(n8996), .Y(
        n2966) );
  sky130_fd_sc_hd__nand2_1 U10661 ( .A(n4177), .B(\cpuregs[30][30] ), .Y(n8997) );
  sky130_fd_sc_hd__o21ai_1 U10662 ( .A1(n4177), .A2(n4190), .B1(n8997), .Y(
        n2995) );
  sky130_fd_sc_hd__nand2_1 U10663 ( .A(n4173), .B(\cpuregs[23][30] ), .Y(n8998) );
  sky130_fd_sc_hd__o21ai_1 U10664 ( .A1(n4173), .A2(n4190), .B1(n8998), .Y(
        n2988) );
  sky130_fd_sc_hd__nand2_1 U10665 ( .A(n4195), .B(\cpuregs[17][30] ), .Y(n8999) );
  sky130_fd_sc_hd__o21ai_1 U10666 ( .A1(n4195), .A2(n4190), .B1(n8999), .Y(
        n2982) );
  sky130_fd_sc_hd__nand2_1 U10667 ( .A(n10058), .B(\cpuregs[20][30] ), .Y(
        n9000) );
  sky130_fd_sc_hd__o21ai_1 U10668 ( .A1(n10058), .A2(n4190), .B1(n9000), .Y(
        n2985) );
  sky130_fd_sc_hd__nand2_1 U10669 ( .A(n7247), .B(\cpuregs[31][30] ), .Y(n9001) );
  sky130_fd_sc_hd__o21ai_1 U10670 ( .A1(n7247), .A2(n4190), .B1(n9001), .Y(
        n2996) );
  sky130_fd_sc_hd__nand2_1 U10671 ( .A(n9772), .B(\cpuregs[6][30] ), .Y(n9002)
         );
  sky130_fd_sc_hd__o21ai_1 U10672 ( .A1(n9772), .A2(n4190), .B1(n9002), .Y(
        n2971) );
  sky130_fd_sc_hd__nand2_1 U10673 ( .A(n4179), .B(\cpuregs[4][30] ), .Y(n9003)
         );
  sky130_fd_sc_hd__o21ai_1 U10674 ( .A1(n4179), .A2(n4190), .B1(n9003), .Y(
        n2969) );
  sky130_fd_sc_hd__nand2_1 U10675 ( .A(mem_rdata_q[14]), .B(
        is_beq_bne_blt_bge_bltu_bgeu), .Y(n10036) );
  sky130_fd_sc_hd__o22ai_1 U10676 ( .A1(n10036), .A2(n10040), .B1(n9004), .B2(
        n10052), .Y(n3982) );
  sky130_fd_sc_hd__nand2_1 U10677 ( .A(n10050), .B(instr_bge), .Y(n9005) );
  sky130_fd_sc_hd__o31ai_1 U10678 ( .A1(n10060), .A2(n10036), .A3(n10106), 
        .B1(n9005), .Y(n3984) );
  sky130_fd_sc_hd__o22ai_1 U10679 ( .A1(n9008), .A2(n10052), .B1(n9007), .B2(
        n9006), .Y(n3986) );
  sky130_fd_sc_hd__nand2_1 U10680 ( .A(n9524), .B(n9009), .Y(n9011) );
  sky130_fd_sc_hd__nand3_1 U10681 ( .A(n9437), .B(n9011), .C(n9010), .Y(n9441)
         );
  sky130_fd_sc_hd__nor3_1 U10682 ( .A(n9859), .B(n10029), .C(n9441), .Y(n9016)
         );
  sky130_fd_sc_hd__nor2_1 U10683 ( .A(n9524), .B(n9858), .Y(n9520) );
  sky130_fd_sc_hd__nand3_1 U10684 ( .A(n9520), .B(n9012), .C(n10124), .Y(n9013) );
  sky130_fd_sc_hd__a21oi_1 U10685 ( .A1(n9543), .A2(n4639), .B1(n9013), .Y(
        n9015) );
  sky130_fd_sc_hd__nand2_1 U10686 ( .A(n9016), .B(latched_store), .Y(n9014) );
  sky130_fd_sc_hd__o31ai_1 U10687 ( .A1(n9016), .A2(n10060), .A3(n9015), .B1(
        n9014), .Y(n4116) );
  sky130_fd_sc_hd__xor2_1 U10688 ( .A(n9017), .B(pcpi_rs2[31]), .X(n9018) );
  sky130_fd_sc_hd__nand2_1 U10689 ( .A(n9018), .B(pcpi_rs1[31]), .Y(n9019) );
  sky130_fd_sc_hd__nand2_1 U10690 ( .A(n9020), .B(n9019), .Y(n9025) );
  sky130_fd_sc_hd__o21ai_1 U10691 ( .A1(n9023), .A2(n9022), .B1(n9021), .Y(
        n9024) );
  sky130_fd_sc_hd__xnor2_1 U10692 ( .A(n9025), .B(n9024), .Y(n9030) );
  sky130_fd_sc_hd__a21oi_1 U10693 ( .A1(n9873), .A2(n9028), .B1(n9872), .Y(
        n9026) );
  sky130_fd_sc_hd__o22ai_1 U10694 ( .A1(n9877), .A2(n9028), .B1(n9027), .B2(
        n9026), .Y(n9029) );
  sky130_fd_sc_hd__a22o_1 U10695 ( .A1(n10055), .A2(n9031), .B1(n9530), .B2(
        reg_pc[31]), .X(n3988) );
  sky130_fd_sc_hd__a21oi_1 U10696 ( .A1(n9034), .A2(n9033), .B1(n9032), .Y(
        n9038) );
  sky130_fd_sc_hd__nand2_1 U10697 ( .A(n9036), .B(n9035), .Y(n9037) );
  sky130_fd_sc_hd__xor2_1 U10698 ( .A(n9038), .B(n9037), .X(n9039) );
  sky130_fd_sc_hd__a222oi_1 U10699 ( .A1(n9052), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[7]), .C1(n5794), .C2(n9039), .Y(n9040) );
  sky130_fd_sc_hd__nand2_1 U10700 ( .A(n9043), .B(n9042), .Y(n9044) );
  sky130_fd_sc_hd__xor2_1 U10701 ( .A(n9045), .B(n9044), .X(n9046) );
  sky130_fd_sc_hd__nand2_1 U10702 ( .A(n9046), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n9051) );
  sky130_fd_sc_hd__o21ai_1 U10703 ( .A1(pcpi_rs1[7]), .A2(pcpi_rs2[7]), .B1(
        n9872), .Y(n9050) );
  sky130_fd_sc_hd__nand2_1 U10704 ( .A(n9873), .B(n9047), .Y(n9049) );
  sky130_fd_sc_hd__nand3_1 U10705 ( .A(n9382), .B(pcpi_rs1[7]), .C(pcpi_rs2[7]), .Y(n9048) );
  sky130_fd_sc_hd__nand4_1 U10706 ( .A(n9051), .B(n9050), .C(n9049), .D(n9048), 
        .Y(alu_out[7]) );
  sky130_fd_sc_hd__a22o_1 U10707 ( .A1(n10055), .A2(n9052), .B1(n9530), .B2(
        reg_pc[7]), .X(n4012) );
  sky130_fd_sc_hd__a22oi_1 U10708 ( .A1(n9462), .A2(\cpuregs[2][6] ), .B1(
        n9496), .B2(\cpuregs[3][6] ), .Y(n9056) );
  sky130_fd_sc_hd__a22oi_1 U10709 ( .A1(n9497), .A2(\cpuregs[15][6] ), .B1(
        n9478), .B2(\cpuregs[1][6] ), .Y(n9055) );
  sky130_fd_sc_hd__a22oi_1 U10710 ( .A1(n9456), .A2(\cpuregs[17][6] ), .B1(
        n9482), .B2(\cpuregs[31][6] ), .Y(n9054) );
  sky130_fd_sc_hd__nand2_1 U10711 ( .A(n9316), .B(\cpuregs[4][6] ), .Y(n9053)
         );
  sky130_fd_sc_hd__nand4_1 U10712 ( .A(n9056), .B(n9055), .C(n9054), .D(n9053), 
        .Y(n9072) );
  sky130_fd_sc_hd__a22oi_1 U10713 ( .A1(n9459), .A2(\cpuregs[18][6] ), .B1(
        n9490), .B2(\cpuregs[11][6] ), .Y(n9060) );
  sky130_fd_sc_hd__a22oi_1 U10714 ( .A1(n9484), .A2(\cpuregs[12][6] ), .B1(
        n9480), .B2(\cpuregs[20][6] ), .Y(n9059) );
  sky130_fd_sc_hd__a22oi_1 U10715 ( .A1(n9468), .A2(\cpuregs[16][6] ), .B1(
        n9481), .B2(\cpuregs[14][6] ), .Y(n9058) );
  sky130_fd_sc_hd__a22oi_1 U10716 ( .A1(n9485), .A2(\cpuregs[21][6] ), .B1(
        n9471), .B2(\cpuregs[25][6] ), .Y(n9057) );
  sky130_fd_sc_hd__nand4_1 U10717 ( .A(n9060), .B(n9059), .C(n9058), .D(n9057), 
        .Y(n9071) );
  sky130_fd_sc_hd__a22oi_1 U10718 ( .A1(n9457), .A2(\cpuregs[19][6] ), .B1(
        n9461), .B2(\cpuregs[5][6] ), .Y(n9064) );
  sky130_fd_sc_hd__a22oi_1 U10719 ( .A1(n9494), .A2(\cpuregs[8][6] ), .B1(
        n9460), .B2(\cpuregs[24][6] ), .Y(n9063) );
  sky130_fd_sc_hd__a22oi_1 U10720 ( .A1(n9493), .A2(\cpuregs[6][6] ), .B1(
        n9495), .B2(\cpuregs[22][6] ), .Y(n9062) );
  sky130_fd_sc_hd__a22oi_1 U10721 ( .A1(n9492), .A2(\cpuregs[28][6] ), .B1(
        n9473), .B2(\cpuregs[23][6] ), .Y(n9061) );
  sky130_fd_sc_hd__nand4_1 U10722 ( .A(n9064), .B(n9063), .C(n9062), .D(n9061), 
        .Y(n9070) );
  sky130_fd_sc_hd__a22oi_1 U10723 ( .A1(n9483), .A2(\cpuregs[7][6] ), .B1(
        n9469), .B2(\cpuregs[9][6] ), .Y(n9068) );
  sky130_fd_sc_hd__a22oi_1 U10724 ( .A1(n9321), .A2(\cpuregs[27][6] ), .B1(
        n9458), .B2(\cpuregs[30][6] ), .Y(n9067) );
  sky130_fd_sc_hd__a22oi_1 U10725 ( .A1(n9479), .A2(\cpuregs[29][6] ), .B1(
        n9470), .B2(\cpuregs[13][6] ), .Y(n9066) );
  sky130_fd_sc_hd__a22oi_1 U10726 ( .A1(n9467), .A2(\cpuregs[26][6] ), .B1(
        n9491), .B2(\cpuregs[10][6] ), .Y(n9065) );
  sky130_fd_sc_hd__nand4_1 U10727 ( .A(n9068), .B(n9067), .C(n9066), .D(n9065), 
        .Y(n9069) );
  sky130_fd_sc_hd__nor4_1 U10728 ( .A(n9072), .B(n9071), .C(n9070), .D(n9069), 
        .Y(n9085) );
  sky130_fd_sc_hd__o22ai_1 U10729 ( .A1(n4321), .A2(n9624), .B1(n9117), .B2(
        n9340), .Y(n9073) );
  sky130_fd_sc_hd__a21oi_1 U10730 ( .A1(n9345), .A2(pcpi_rs1[10]), .B1(n9073), 
        .Y(n9084) );
  sky130_fd_sc_hd__nand2_1 U10731 ( .A(n9076), .B(n9075), .Y(n9077) );
  sky130_fd_sc_hd__xor2_1 U10732 ( .A(n9078), .B(n9077), .X(n9082) );
  sky130_fd_sc_hd__nor2_1 U10733 ( .A(n9106), .B(n4340), .Y(n9081) );
  sky130_fd_sc_hd__o22ai_1 U10734 ( .A1(n9079), .A2(n4342), .B1(n4371), .B2(
        n9341), .Y(n9080) );
  sky130_fd_sc_hd__a211oi_1 U10735 ( .A1(n9511), .A2(n9082), .B1(n9081), .C1(
        n9080), .Y(n9083) );
  sky130_fd_sc_hd__o211ai_1 U10736 ( .A1(n9085), .A2(n9506), .B1(n9084), .C1(
        n9083), .Y(n2789) );
  sky130_fd_sc_hd__a22oi_1 U10737 ( .A1(n9485), .A2(\cpuregs[21][5] ), .B1(
        n9316), .B2(\cpuregs[4][5] ), .Y(n9089) );
  sky130_fd_sc_hd__a22oi_1 U10738 ( .A1(n9483), .A2(\cpuregs[7][5] ), .B1(
        n9478), .B2(\cpuregs[1][5] ), .Y(n9088) );
  sky130_fd_sc_hd__a22oi_1 U10739 ( .A1(n9461), .A2(\cpuregs[5][5] ), .B1(
        n9491), .B2(\cpuregs[10][5] ), .Y(n9087) );
  sky130_fd_sc_hd__nand2_1 U10740 ( .A(n9494), .B(\cpuregs[8][5] ), .Y(n9086)
         );
  sky130_fd_sc_hd__nand4_1 U10741 ( .A(n9089), .B(n9088), .C(n9087), .D(n9086), 
        .Y(n9105) );
  sky130_fd_sc_hd__a22oi_1 U10742 ( .A1(n9462), .A2(\cpuregs[2][5] ), .B1(
        n9496), .B2(\cpuregs[3][5] ), .Y(n9093) );
  sky130_fd_sc_hd__a22oi_1 U10743 ( .A1(n9471), .A2(\cpuregs[25][5] ), .B1(
        n9469), .B2(\cpuregs[9][5] ), .Y(n9092) );
  sky130_fd_sc_hd__a22oi_1 U10744 ( .A1(n9480), .A2(\cpuregs[20][5] ), .B1(
        n9482), .B2(\cpuregs[31][5] ), .Y(n9091) );
  sky130_fd_sc_hd__a22oi_1 U10745 ( .A1(n9321), .A2(\cpuregs[27][5] ), .B1(
        n9473), .B2(\cpuregs[23][5] ), .Y(n9090) );
  sky130_fd_sc_hd__nand4_1 U10746 ( .A(n9093), .B(n9092), .C(n9091), .D(n9090), 
        .Y(n9104) );
  sky130_fd_sc_hd__a22oi_1 U10747 ( .A1(n9460), .A2(\cpuregs[24][5] ), .B1(
        n9456), .B2(\cpuregs[17][5] ), .Y(n9097) );
  sky130_fd_sc_hd__a22oi_1 U10748 ( .A1(n9467), .A2(\cpuregs[26][5] ), .B1(
        n9484), .B2(\cpuregs[12][5] ), .Y(n9096) );
  sky130_fd_sc_hd__a22oi_1 U10749 ( .A1(n9490), .A2(\cpuregs[11][5] ), .B1(
        n9470), .B2(\cpuregs[13][5] ), .Y(n9095) );
  sky130_fd_sc_hd__a22oi_1 U10750 ( .A1(n9481), .A2(\cpuregs[14][5] ), .B1(
        n9459), .B2(\cpuregs[18][5] ), .Y(n9094) );
  sky130_fd_sc_hd__nand4_1 U10751 ( .A(n9097), .B(n9096), .C(n9095), .D(n9094), 
        .Y(n9103) );
  sky130_fd_sc_hd__a22oi_1 U10752 ( .A1(n9495), .A2(\cpuregs[22][5] ), .B1(
        n9479), .B2(\cpuregs[29][5] ), .Y(n9101) );
  sky130_fd_sc_hd__a22oi_1 U10753 ( .A1(n9468), .A2(\cpuregs[16][5] ), .B1(
        n9493), .B2(\cpuregs[6][5] ), .Y(n9100) );
  sky130_fd_sc_hd__a22oi_1 U10754 ( .A1(n9497), .A2(\cpuregs[15][5] ), .B1(
        n9457), .B2(\cpuregs[19][5] ), .Y(n9099) );
  sky130_fd_sc_hd__a22oi_1 U10755 ( .A1(n9492), .A2(\cpuregs[28][5] ), .B1(
        n9458), .B2(\cpuregs[30][5] ), .Y(n9098) );
  sky130_fd_sc_hd__nand4_1 U10756 ( .A(n9101), .B(n9100), .C(n9099), .D(n9098), 
        .Y(n9102) );
  sky130_fd_sc_hd__nor4_1 U10757 ( .A(n9105), .B(n9104), .C(n9103), .D(n9102), 
        .Y(n9123) );
  sky130_fd_sc_hd__o22ai_1 U10758 ( .A1(n4321), .A2(n9550), .B1(n9106), .B2(
        n9340), .Y(n9107) );
  sky130_fd_sc_hd__a21oi_1 U10759 ( .A1(n9345), .A2(pcpi_rs1[9]), .B1(n9107), 
        .Y(n9122) );
  sky130_fd_sc_hd__a21oi_1 U10760 ( .A1(n9111), .A2(n9110), .B1(n9109), .Y(
        n9116) );
  sky130_fd_sc_hd__nand2_1 U10761 ( .A(n9114), .B(n9113), .Y(n9115) );
  sky130_fd_sc_hd__xor2_1 U10762 ( .A(n9116), .B(n9115), .X(n9120) );
  sky130_fd_sc_hd__nor2_1 U10763 ( .A(n9455), .B(n4340), .Y(n9119) );
  sky130_fd_sc_hd__o22ai_1 U10764 ( .A1(n9117), .A2(n4342), .B1(n4371), .B2(
        n9907), .Y(n9118) );
  sky130_fd_sc_hd__a211oi_1 U10765 ( .A1(n9511), .A2(n9120), .B1(n9119), .C1(
        n9118), .Y(n9121) );
  sky130_fd_sc_hd__o211ai_1 U10766 ( .A1(n9123), .A2(n9506), .B1(n9122), .C1(
        n9121), .Y(n2790) );
  sky130_fd_sc_hd__a22oi_1 U10767 ( .A1(n9468), .A2(\cpuregs[16][1] ), .B1(
        n9495), .B2(\cpuregs[22][1] ), .Y(n9127) );
  sky130_fd_sc_hd__a22oi_1 U10768 ( .A1(n9457), .A2(\cpuregs[19][1] ), .B1(
        n9458), .B2(\cpuregs[30][1] ), .Y(n9126) );
  sky130_fd_sc_hd__a22oi_1 U10769 ( .A1(n9462), .A2(\cpuregs[2][1] ), .B1(
        n9490), .B2(\cpuregs[11][1] ), .Y(n9125) );
  sky130_fd_sc_hd__nand2_1 U10770 ( .A(n9484), .B(\cpuregs[12][1] ), .Y(n9124)
         );
  sky130_fd_sc_hd__nand4_1 U10771 ( .A(n9127), .B(n9126), .C(n9125), .D(n9124), 
        .Y(n9143) );
  sky130_fd_sc_hd__a22oi_1 U10772 ( .A1(n9473), .A2(\cpuregs[23][1] ), .B1(
        n9496), .B2(\cpuregs[3][1] ), .Y(n9131) );
  sky130_fd_sc_hd__a22oi_1 U10773 ( .A1(n9485), .A2(\cpuregs[21][1] ), .B1(
        n9456), .B2(\cpuregs[17][1] ), .Y(n9130) );
  sky130_fd_sc_hd__a22oi_1 U10774 ( .A1(n9493), .A2(\cpuregs[6][1] ), .B1(
        n9482), .B2(\cpuregs[31][1] ), .Y(n9129) );
  sky130_fd_sc_hd__a22oi_1 U10775 ( .A1(n9471), .A2(\cpuregs[25][1] ), .B1(
        n9492), .B2(\cpuregs[28][1] ), .Y(n9128) );
  sky130_fd_sc_hd__nand4_1 U10776 ( .A(n9131), .B(n9130), .C(n9129), .D(n9128), 
        .Y(n9142) );
  sky130_fd_sc_hd__a22oi_1 U10777 ( .A1(n9494), .A2(\cpuregs[8][1] ), .B1(
        n9480), .B2(\cpuregs[20][1] ), .Y(n9135) );
  sky130_fd_sc_hd__a22oi_1 U10778 ( .A1(n9467), .A2(\cpuregs[26][1] ), .B1(
        n9470), .B2(\cpuregs[13][1] ), .Y(n9134) );
  sky130_fd_sc_hd__a22oi_1 U10779 ( .A1(n9483), .A2(\cpuregs[7][1] ), .B1(
        n9469), .B2(\cpuregs[9][1] ), .Y(n9133) );
  sky130_fd_sc_hd__a22oi_1 U10780 ( .A1(n9481), .A2(\cpuregs[14][1] ), .B1(
        n9461), .B2(\cpuregs[5][1] ), .Y(n9132) );
  sky130_fd_sc_hd__nand4_1 U10781 ( .A(n9135), .B(n9134), .C(n9133), .D(n9132), 
        .Y(n9141) );
  sky130_fd_sc_hd__a22oi_1 U10782 ( .A1(n9497), .A2(\cpuregs[15][1] ), .B1(
        n9316), .B2(\cpuregs[4][1] ), .Y(n9139) );
  sky130_fd_sc_hd__a22oi_1 U10783 ( .A1(n9491), .A2(\cpuregs[10][1] ), .B1(
        n9479), .B2(\cpuregs[29][1] ), .Y(n9138) );
  sky130_fd_sc_hd__a22oi_1 U10784 ( .A1(n9460), .A2(\cpuregs[24][1] ), .B1(
        n9478), .B2(\cpuregs[1][1] ), .Y(n9137) );
  sky130_fd_sc_hd__a22oi_1 U10785 ( .A1(n9321), .A2(\cpuregs[27][1] ), .B1(
        n9459), .B2(\cpuregs[18][1] ), .Y(n9136) );
  sky130_fd_sc_hd__nand4_1 U10786 ( .A(n9139), .B(n9138), .C(n9137), .D(n9136), 
        .Y(n9140) );
  sky130_fd_sc_hd__nor4_1 U10787 ( .A(n9143), .B(n9142), .C(n9141), .D(n9140), 
        .Y(n9154) );
  sky130_fd_sc_hd__nand2_1 U10788 ( .A(n9146), .B(n9145), .Y(n9147) );
  sky130_fd_sc_hd__xor2_1 U10789 ( .A(n9147), .B(n9450), .X(n9148) );
  sky130_fd_sc_hd__nand2_1 U10790 ( .A(n9511), .B(n9148), .Y(n9153) );
  sky130_fd_sc_hd__o22ai_1 U10791 ( .A1(n4321), .A2(n9181), .B1(n9907), .B2(
        n9340), .Y(n9151) );
  sky130_fd_sc_hd__o22ai_1 U10792 ( .A1(n9149), .A2(n4340), .B1(n4342), .B2(
        n9341), .Y(n9150) );
  sky130_fd_sc_hd__a211oi_1 U10793 ( .A1(pcpi_rs1[5]), .A2(n9345), .B1(n9151), 
        .C1(n9150), .Y(n9152) );
  sky130_fd_sc_hd__o211ai_1 U10794 ( .A1(n9154), .A2(n9506), .B1(n9153), .C1(
        n9152), .Y(n2933) );
  sky130_fd_sc_hd__clkinv_1 U10795 ( .A(mem_rdata[1]), .Y(n9157) );
  sky130_fd_sc_hd__o22ai_1 U10796 ( .A1(n10021), .A2(n9851), .B1(n9850), .B2(
        n10083), .Y(n9155) );
  sky130_fd_sc_hd__a21oi_1 U10797 ( .A1(mem_rdata[17]), .A2(n9853), .B1(n9155), 
        .Y(n9156) );
  sky130_fd_sc_hd__o21ai_1 U10798 ( .A1(n10017), .A2(n9157), .B1(n9156), .Y(
        n4152) );
  sky130_fd_sc_hd__nand2_1 U10799 ( .A(n9159), .B(n4639), .Y(n9164) );
  sky130_fd_sc_hd__a22oi_1 U10800 ( .A1(n9857), .A2(count_instr[1]), .B1(n9856), .B2(count_instr[33]), .Y(n9163) );
  sky130_fd_sc_hd__o2bb2ai_1 U10801 ( .B1(n9907), .B2(n9437), .A1_N(n9859), 
        .A2_N(mem_rdata_word[1]), .Y(n9160) );
  sky130_fd_sc_hd__a21oi_1 U10802 ( .A1(n9861), .A2(count_cycle[33]), .B1(
        n9160), .Y(n9162) );
  sky130_fd_sc_hd__nand2_1 U10803 ( .A(n9860), .B(count_cycle[1]), .Y(n9161)
         );
  sky130_fd_sc_hd__nand4_1 U10804 ( .A(n9164), .B(n9163), .C(n9162), .D(n9161), 
        .Y(N1878) );
  sky130_fd_sc_hd__nand2_1 U10805 ( .A(n9165), .B(n9375), .Y(n9167) );
  sky130_fd_sc_hd__xor2_1 U10806 ( .A(n9167), .B(n9376), .X(n9168) );
  sky130_fd_sc_hd__nand2_1 U10807 ( .A(n9168), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n9173) );
  sky130_fd_sc_hd__o21ai_1 U10808 ( .A1(pcpi_rs1[1]), .A2(pcpi_rs2[1]), .B1(
        n9872), .Y(n9172) );
  sky130_fd_sc_hd__nand2_1 U10809 ( .A(n9873), .B(n9169), .Y(n9171) );
  sky130_fd_sc_hd__nand3_1 U10810 ( .A(n9382), .B(pcpi_rs1[1]), .C(pcpi_rs2[1]), .Y(n9170) );
  sky130_fd_sc_hd__nand4_1 U10811 ( .A(n9173), .B(n9172), .C(n9171), .D(n9170), 
        .Y(alu_out[1]) );
  sky130_fd_sc_hd__nand2_1 U10812 ( .A(n9174), .B(n10055), .Y(n9180) );
  sky130_fd_sc_hd__nand2_1 U10813 ( .A(n9530), .B(reg_next_pc[1]), .Y(n9179)
         );
  sky130_fd_sc_hd__or2_2 U10814 ( .A(n9175), .B(n9174), .X(n9176) );
  sky130_fd_sc_hd__nand2_1 U10815 ( .A(n9177), .B(n5794), .Y(n9178) );
  sky130_fd_sc_hd__o211ai_1 U10816 ( .A1(decoder_trigger), .A2(n9180), .B1(
        n9179), .C1(n9178), .Y(n4050) );
  sky130_fd_sc_hd__o21ai_1 U10817 ( .A1(n9181), .A2(n10029), .B1(n9180), .Y(
        n4018) );
  sky130_fd_sc_hd__nand2_1 U10818 ( .A(n9815), .B(alu_out_q[1]), .Y(n9184) );
  sky130_fd_sc_hd__nand2_1 U10819 ( .A(n9816), .B(reg_out[1]), .Y(n9183) );
  sky130_fd_sc_hd__nand2_1 U10820 ( .A(reg_pc[1]), .B(n9813), .Y(n9182) );
  sky130_fd_sc_hd__nand2_1 U10821 ( .A(n4180), .B(\cpuregs[5][1] ), .Y(n9185)
         );
  sky130_fd_sc_hd__o21ai_1 U10822 ( .A1(n9217), .A2(n4180), .B1(n9185), .Y(
        n3869) );
  sky130_fd_sc_hd__nand2_1 U10823 ( .A(n4186), .B(\cpuregs[13][1] ), .Y(n9186)
         );
  sky130_fd_sc_hd__o21ai_1 U10824 ( .A1(n9217), .A2(n4186), .B1(n9186), .Y(
        n3877) );
  sky130_fd_sc_hd__nand2_1 U10825 ( .A(n4195), .B(\cpuregs[17][1] ), .Y(n9187)
         );
  sky130_fd_sc_hd__o21ai_1 U10826 ( .A1(n9217), .A2(n4195), .B1(n9187), .Y(
        n3881) );
  sky130_fd_sc_hd__nand2_1 U10827 ( .A(n7452), .B(\cpuregs[9][1] ), .Y(n9188)
         );
  sky130_fd_sc_hd__o21ai_1 U10828 ( .A1(n9217), .A2(n7452), .B1(n9188), .Y(
        n3873) );
  sky130_fd_sc_hd__nand2_1 U10829 ( .A(n4176), .B(\cpuregs[29][1] ), .Y(n9189)
         );
  sky130_fd_sc_hd__o21ai_1 U10830 ( .A1(n9217), .A2(n4176), .B1(n9189), .Y(
        n3893) );
  sky130_fd_sc_hd__nand2_1 U10831 ( .A(n4174), .B(\cpuregs[21][1] ), .Y(n9190)
         );
  sky130_fd_sc_hd__o21ai_1 U10832 ( .A1(n9217), .A2(n4174), .B1(n9190), .Y(
        n3885) );
  sky130_fd_sc_hd__nand2_1 U10833 ( .A(n4192), .B(\cpuregs[25][1] ), .Y(n9191)
         );
  sky130_fd_sc_hd__o21ai_1 U10834 ( .A1(n9217), .A2(n4192), .B1(n9191), .Y(
        n3889) );
  sky130_fd_sc_hd__nand2_1 U10835 ( .A(n6396), .B(\cpuregs[1][1] ), .Y(n9192)
         );
  sky130_fd_sc_hd__o21ai_1 U10836 ( .A1(n9217), .A2(n6396), .B1(n9192), .Y(
        n3865) );
  sky130_fd_sc_hd__nand2_1 U10837 ( .A(n4199), .B(\cpuregs[7][1] ), .Y(n9193)
         );
  sky130_fd_sc_hd__o21ai_1 U10838 ( .A1(n9217), .A2(n4199), .B1(n9193), .Y(
        n3871) );
  sky130_fd_sc_hd__nand2_1 U10839 ( .A(n7069), .B(\cpuregs[15][1] ), .Y(n9194)
         );
  sky130_fd_sc_hd__o21ai_1 U10840 ( .A1(n9217), .A2(n7069), .B1(n9194), .Y(
        n3879) );
  sky130_fd_sc_hd__nand2_1 U10841 ( .A(n4194), .B(\cpuregs[19][1] ), .Y(n9195)
         );
  sky130_fd_sc_hd__o21ai_1 U10842 ( .A1(n9217), .A2(n4194), .B1(n9195), .Y(
        n3883) );
  sky130_fd_sc_hd__nand2_1 U10843 ( .A(n4185), .B(\cpuregs[11][1] ), .Y(n9196)
         );
  sky130_fd_sc_hd__o21ai_1 U10844 ( .A1(n9217), .A2(n4185), .B1(n9196), .Y(
        n3875) );
  sky130_fd_sc_hd__nand2_1 U10845 ( .A(n7247), .B(\cpuregs[31][1] ), .Y(n9197)
         );
  sky130_fd_sc_hd__o21ai_1 U10846 ( .A1(n9217), .A2(n7247), .B1(n9197), .Y(
        n3895) );
  sky130_fd_sc_hd__nand2_1 U10847 ( .A(n4173), .B(\cpuregs[23][1] ), .Y(n9198)
         );
  sky130_fd_sc_hd__o21ai_1 U10848 ( .A1(n9217), .A2(n4173), .B1(n9198), .Y(
        n3887) );
  sky130_fd_sc_hd__nand2_1 U10849 ( .A(n4175), .B(\cpuregs[27][1] ), .Y(n9199)
         );
  sky130_fd_sc_hd__o21ai_1 U10850 ( .A1(n9217), .A2(n4175), .B1(n9199), .Y(
        n3891) );
  sky130_fd_sc_hd__nand2_1 U10851 ( .A(n4201), .B(\cpuregs[3][1] ), .Y(n9200)
         );
  sky130_fd_sc_hd__o21ai_1 U10852 ( .A1(n9217), .A2(n4201), .B1(n9200), .Y(
        n3867) );
  sky130_fd_sc_hd__nand2_1 U10853 ( .A(n4179), .B(\cpuregs[4][1] ), .Y(n9201)
         );
  sky130_fd_sc_hd__o21ai_1 U10854 ( .A1(n9217), .A2(n4179), .B1(n9201), .Y(
        n3868) );
  sky130_fd_sc_hd__nand2_1 U10855 ( .A(n4226), .B(\cpuregs[12][1] ), .Y(n9202)
         );
  sky130_fd_sc_hd__o21ai_1 U10856 ( .A1(n9217), .A2(n4226), .B1(n9202), .Y(
        n3876) );
  sky130_fd_sc_hd__nand2_1 U10857 ( .A(n4197), .B(\cpuregs[16][1] ), .Y(n9203)
         );
  sky130_fd_sc_hd__o21ai_1 U10858 ( .A1(n9217), .A2(n4197), .B1(n9203), .Y(
        n3880) );
  sky130_fd_sc_hd__nand2_1 U10859 ( .A(n4183), .B(\cpuregs[8][1] ), .Y(n9204)
         );
  sky130_fd_sc_hd__o21ai_1 U10860 ( .A1(n9217), .A2(n4183), .B1(n9204), .Y(
        n3872) );
  sky130_fd_sc_hd__nand2_1 U10861 ( .A(n4219), .B(\cpuregs[28][1] ), .Y(n9205)
         );
  sky130_fd_sc_hd__o21ai_1 U10862 ( .A1(n9217), .A2(n4219), .B1(n9205), .Y(
        n3892) );
  sky130_fd_sc_hd__nand2_1 U10863 ( .A(n10058), .B(\cpuregs[20][1] ), .Y(n9206) );
  sky130_fd_sc_hd__o21ai_1 U10864 ( .A1(n9217), .A2(n10058), .B1(n9206), .Y(
        n3884) );
  sky130_fd_sc_hd__nand2_1 U10865 ( .A(n10057), .B(\cpuregs[24][1] ), .Y(n9207) );
  sky130_fd_sc_hd__o21ai_1 U10866 ( .A1(n9217), .A2(n10057), .B1(n9207), .Y(
        n3888) );
  sky130_fd_sc_hd__nand2_1 U10867 ( .A(n9772), .B(\cpuregs[6][1] ), .Y(n9208)
         );
  sky130_fd_sc_hd__o21ai_1 U10868 ( .A1(n9217), .A2(n9209), .B1(n9208), .Y(
        n3870) );
  sky130_fd_sc_hd__nand2_1 U10869 ( .A(n6897), .B(\cpuregs[14][1] ), .Y(n9210)
         );
  sky130_fd_sc_hd__o21ai_1 U10870 ( .A1(n9217), .A2(n6897), .B1(n9210), .Y(
        n3878) );
  sky130_fd_sc_hd__nand2_1 U10871 ( .A(n9820), .B(\cpuregs[18][1] ), .Y(n9211)
         );
  sky130_fd_sc_hd__o21ai_1 U10872 ( .A1(n9217), .A2(n9820), .B1(n9211), .Y(
        n3882) );
  sky130_fd_sc_hd__nand2_1 U10873 ( .A(n4184), .B(\cpuregs[10][1] ), .Y(n9212)
         );
  sky130_fd_sc_hd__o21ai_1 U10874 ( .A1(n9217), .A2(n4184), .B1(n9212), .Y(
        n3874) );
  sky130_fd_sc_hd__nand2_1 U10875 ( .A(n4177), .B(\cpuregs[30][1] ), .Y(n9213)
         );
  sky130_fd_sc_hd__o21ai_1 U10876 ( .A1(n9217), .A2(n4177), .B1(n9213), .Y(
        n3894) );
  sky130_fd_sc_hd__nand2_1 U10877 ( .A(n7084), .B(\cpuregs[22][1] ), .Y(n9214)
         );
  sky130_fd_sc_hd__o21ai_1 U10878 ( .A1(n9217), .A2(n7084), .B1(n9214), .Y(
        n3886) );
  sky130_fd_sc_hd__nand2_1 U10879 ( .A(n9621), .B(\cpuregs[26][1] ), .Y(n9215)
         );
  sky130_fd_sc_hd__o21ai_1 U10880 ( .A1(n9217), .A2(n9621), .B1(n9215), .Y(
        n3890) );
  sky130_fd_sc_hd__nand2_1 U10881 ( .A(n4178), .B(\cpuregs[2][1] ), .Y(n9216)
         );
  sky130_fd_sc_hd__o21ai_1 U10882 ( .A1(n9217), .A2(n4178), .B1(n9216), .Y(
        n3866) );
  sky130_fd_sc_hd__nor3_1 U10883 ( .A(is_lb_lh_lw_lbu_lhu), .B(n10118), .C(
        n9302), .Y(n9434) );
  sky130_fd_sc_hd__a22oi_1 U10884 ( .A1(N1571), .A2(n9218), .B1(n9434), .B2(
        decoded_imm_j[1]), .Y(n9219) );
  sky130_fd_sc_hd__nand2_1 U10885 ( .A(n9220), .B(n9219), .Y(N1910) );
  sky130_fd_sc_hd__nor2_1 U10886 ( .A(n9222), .B(n9427), .Y(n9221) );
  sky130_fd_sc_hd__a31oi_1 U10887 ( .A1(n9224), .A2(n9223), .A3(n9222), .B1(
        n9221), .Y(n9226) );
  sky130_fd_sc_hd__o211ai_1 U10888 ( .A1(n9227), .A2(n9431), .B1(n9226), .C1(
        n9225), .Y(N1909) );
  sky130_fd_sc_hd__ha_1 U10889 ( .A(n9228), .B(reg_pc[30]), .COUT(n9229), 
        .SUM(n8971) );
  sky130_fd_sc_hd__xor2_1 U10890 ( .A(reg_pc[31]), .B(n9229), .X(n9231) );
  sky130_fd_sc_hd__a22o_1 U10891 ( .A1(reg_out[31]), .A2(n9816), .B1(n9815), 
        .B2(alu_out_q[31]), .X(n9230) );
  sky130_fd_sc_hd__a21oi_2 U10892 ( .A1(n9231), .A2(n9813), .B1(n9230), .Y(
        n9260) );
  sky130_fd_sc_hd__inv_2 U10893 ( .A(n9260), .Y(n9234) );
  sky130_fd_sc_hd__nand2_1 U10894 ( .A(n7084), .B(\cpuregs[22][31] ), .Y(n9232) );
  sky130_fd_sc_hd__o21ai_1 U10895 ( .A1(n7084), .A2(n9266), .B1(n9232), .Y(
        n2956) );
  sky130_fd_sc_hd__nand2_1 U10896 ( .A(n4226), .B(\cpuregs[12][31] ), .Y(n9233) );
  sky130_fd_sc_hd__o21ai_1 U10897 ( .A1(n4226), .A2(n9266), .B1(n9233), .Y(
        n2946) );
  sky130_fd_sc_hd__nand2_1 U10898 ( .A(n4178), .B(\cpuregs[2][31] ), .Y(n9235)
         );
  sky130_fd_sc_hd__o21ai_1 U10899 ( .A1(n4178), .A2(n9264), .B1(n9235), .Y(
        n2936) );
  sky130_fd_sc_hd__nand2_1 U10900 ( .A(n7452), .B(\cpuregs[9][31] ), .Y(n9236)
         );
  sky130_fd_sc_hd__o21ai_1 U10901 ( .A1(n7452), .A2(n9266), .B1(n9236), .Y(
        n2943) );
  sky130_fd_sc_hd__nand2_1 U10902 ( .A(n7069), .B(\cpuregs[15][31] ), .Y(n9237) );
  sky130_fd_sc_hd__o21ai_1 U10903 ( .A1(n7069), .A2(n9260), .B1(n9237), .Y(
        n2949) );
  sky130_fd_sc_hd__nand2_1 U10904 ( .A(n4194), .B(\cpuregs[19][31] ), .Y(n9238) );
  sky130_fd_sc_hd__o21ai_1 U10905 ( .A1(n4194), .A2(n9260), .B1(n9238), .Y(
        n2953) );
  sky130_fd_sc_hd__nand2_1 U10906 ( .A(n4199), .B(\cpuregs[7][31] ), .Y(n9239)
         );
  sky130_fd_sc_hd__o21ai_1 U10907 ( .A1(n4199), .A2(n9260), .B1(n9239), .Y(
        n2941) );
  sky130_fd_sc_hd__nand2_1 U10908 ( .A(n4180), .B(\cpuregs[5][31] ), .Y(n9240)
         );
  sky130_fd_sc_hd__o21ai_1 U10909 ( .A1(n4180), .A2(n9260), .B1(n9240), .Y(
        n2939) );
  sky130_fd_sc_hd__nand2_1 U10910 ( .A(n9820), .B(\cpuregs[18][31] ), .Y(n9241) );
  sky130_fd_sc_hd__o21ai_1 U10911 ( .A1(n9820), .A2(n9260), .B1(n9241), .Y(
        n2952) );
  sky130_fd_sc_hd__nand2_1 U10912 ( .A(n4219), .B(\cpuregs[28][31] ), .Y(n9242) );
  sky130_fd_sc_hd__o21ai_1 U10913 ( .A1(n4219), .A2(n9264), .B1(n9242), .Y(
        n2962) );
  sky130_fd_sc_hd__nand2_1 U10914 ( .A(n4201), .B(\cpuregs[3][31] ), .Y(n9243)
         );
  sky130_fd_sc_hd__o21ai_1 U10915 ( .A1(n4201), .A2(n9266), .B1(n9243), .Y(
        n2937) );
  sky130_fd_sc_hd__nand2_1 U10916 ( .A(n4197), .B(\cpuregs[16][31] ), .Y(n9244) );
  sky130_fd_sc_hd__o21ai_1 U10917 ( .A1(n4197), .A2(n9264), .B1(n9244), .Y(
        n2950) );
  sky130_fd_sc_hd__nand2_1 U10918 ( .A(n9621), .B(\cpuregs[26][31] ), .Y(n9245) );
  sky130_fd_sc_hd__o21ai_1 U10919 ( .A1(n9621), .A2(n9266), .B1(n9245), .Y(
        n2960) );
  sky130_fd_sc_hd__nand2_1 U10920 ( .A(n4183), .B(\cpuregs[8][31] ), .Y(n9246)
         );
  sky130_fd_sc_hd__o21ai_1 U10921 ( .A1(n4183), .A2(n9260), .B1(n9246), .Y(
        n2942) );
  sky130_fd_sc_hd__nand2_1 U10922 ( .A(n10057), .B(\cpuregs[24][31] ), .Y(
        n9247) );
  sky130_fd_sc_hd__o21ai_1 U10923 ( .A1(n10057), .A2(n9260), .B1(n9247), .Y(
        n2958) );
  sky130_fd_sc_hd__nand2_1 U10924 ( .A(n4174), .B(\cpuregs[21][31] ), .Y(n9248) );
  sky130_fd_sc_hd__o21ai_1 U10925 ( .A1(n4174), .A2(n9260), .B1(n9248), .Y(
        n2955) );
  sky130_fd_sc_hd__nand2_1 U10926 ( .A(n4175), .B(\cpuregs[27][31] ), .Y(n9249) );
  sky130_fd_sc_hd__o21ai_1 U10927 ( .A1(n4175), .A2(n9260), .B1(n9249), .Y(
        n2961) );
  sky130_fd_sc_hd__nand2_1 U10928 ( .A(n4192), .B(\cpuregs[25][31] ), .Y(n9250) );
  sky130_fd_sc_hd__o21ai_1 U10929 ( .A1(n4192), .A2(n9260), .B1(n9250), .Y(
        n2959) );
  sky130_fd_sc_hd__nand2_1 U10930 ( .A(n4186), .B(\cpuregs[13][31] ), .Y(n9251) );
  sky130_fd_sc_hd__o21ai_1 U10931 ( .A1(n4186), .A2(n9266), .B1(n9251), .Y(
        n2947) );
  sky130_fd_sc_hd__nand2_1 U10932 ( .A(n4184), .B(\cpuregs[10][31] ), .Y(n9252) );
  sky130_fd_sc_hd__o21ai_1 U10933 ( .A1(n4184), .A2(n9264), .B1(n9252), .Y(
        n2944) );
  sky130_fd_sc_hd__nand2_1 U10934 ( .A(n4185), .B(\cpuregs[11][31] ), .Y(n9253) );
  sky130_fd_sc_hd__o21ai_1 U10935 ( .A1(n4185), .A2(n9264), .B1(n9253), .Y(
        n2945) );
  sky130_fd_sc_hd__nand2_1 U10936 ( .A(n6897), .B(\cpuregs[14][31] ), .Y(n9254) );
  sky130_fd_sc_hd__o21ai_1 U10937 ( .A1(n6897), .A2(n9266), .B1(n9254), .Y(
        n2948) );
  sky130_fd_sc_hd__nand2_1 U10938 ( .A(n4176), .B(\cpuregs[29][31] ), .Y(n9255) );
  sky130_fd_sc_hd__o21ai_1 U10939 ( .A1(n4176), .A2(n9260), .B1(n9255), .Y(
        n2963) );
  sky130_fd_sc_hd__nand2_1 U10940 ( .A(n6396), .B(\cpuregs[1][31] ), .Y(n9256)
         );
  sky130_fd_sc_hd__o21ai_1 U10941 ( .A1(n6396), .A2(n9260), .B1(n9256), .Y(
        n2935) );
  sky130_fd_sc_hd__nand2_1 U10942 ( .A(n4177), .B(\cpuregs[30][31] ), .Y(n9257) );
  sky130_fd_sc_hd__o21ai_1 U10943 ( .A1(n4177), .A2(n9260), .B1(n9257), .Y(
        n2964) );
  sky130_fd_sc_hd__nand2_1 U10944 ( .A(n4173), .B(\cpuregs[23][31] ), .Y(n9258) );
  sky130_fd_sc_hd__o21ai_1 U10945 ( .A1(n4173), .A2(n9260), .B1(n9258), .Y(
        n2957) );
  sky130_fd_sc_hd__nand2_1 U10946 ( .A(n4195), .B(\cpuregs[17][31] ), .Y(n9259) );
  sky130_fd_sc_hd__o21ai_1 U10947 ( .A1(n4195), .A2(n9260), .B1(n9259), .Y(
        n2951) );
  sky130_fd_sc_hd__nand2_1 U10948 ( .A(n10058), .B(\cpuregs[20][31] ), .Y(
        n9261) );
  sky130_fd_sc_hd__o21ai_1 U10949 ( .A1(n10058), .A2(n9264), .B1(n9261), .Y(
        n2954) );
  sky130_fd_sc_hd__nand2_1 U10950 ( .A(n7247), .B(\cpuregs[31][31] ), .Y(n9262) );
  sky130_fd_sc_hd__o21ai_1 U10951 ( .A1(n7247), .A2(n9264), .B1(n9262), .Y(
        n2965) );
  sky130_fd_sc_hd__nand2_1 U10952 ( .A(n9772), .B(\cpuregs[6][31] ), .Y(n9263)
         );
  sky130_fd_sc_hd__o21ai_1 U10953 ( .A1(n9772), .A2(n9264), .B1(n9263), .Y(
        n2940) );
  sky130_fd_sc_hd__nand2_1 U10954 ( .A(n4179), .B(\cpuregs[4][31] ), .Y(n9265)
         );
  sky130_fd_sc_hd__o21ai_1 U10955 ( .A1(n4179), .A2(n9266), .B1(n9265), .Y(
        n2938) );
  sky130_fd_sc_hd__a21oi_1 U10956 ( .A1(n9270), .A2(n9269), .B1(n9268), .Y(
        n9274) );
  sky130_fd_sc_hd__nand2_1 U10957 ( .A(pcpi_rs1[31]), .B(decoded_imm[31]), .Y(
        n9271) );
  sky130_fd_sc_hd__nand2_1 U10958 ( .A(n9272), .B(n9271), .Y(n9273) );
  sky130_fd_sc_hd__xor2_1 U10959 ( .A(n9274), .B(n9273), .X(n9275) );
  sky130_fd_sc_hd__nand2_1 U10960 ( .A(n9275), .B(n9511), .Y(n9311) );
  sky130_fd_sc_hd__nor3_1 U10961 ( .A(n9278), .B(n9277), .C(n9276), .Y(n9279)
         );
  sky130_fd_sc_hd__a21oi_1 U10962 ( .A1(n9280), .A2(reg_pc[31]), .B1(n9279), 
        .Y(n9310) );
  sky130_fd_sc_hd__a22oi_1 U10963 ( .A1(n9493), .A2(\cpuregs[6][31] ), .B1(
        n9456), .B2(\cpuregs[17][31] ), .Y(n9284) );
  sky130_fd_sc_hd__a22oi_1 U10964 ( .A1(n9462), .A2(\cpuregs[2][31] ), .B1(
        n9316), .B2(\cpuregs[4][31] ), .Y(n9283) );
  sky130_fd_sc_hd__nand2_1 U10965 ( .A(n9484), .B(\cpuregs[12][31] ), .Y(n9282) );
  sky130_fd_sc_hd__a22oi_1 U10966 ( .A1(n9478), .A2(\cpuregs[1][31] ), .B1(
        n9496), .B2(\cpuregs[3][31] ), .Y(n9281) );
  sky130_fd_sc_hd__nand4_1 U10967 ( .A(n9284), .B(n9283), .C(n9282), .D(n9281), 
        .Y(n9301) );
  sky130_fd_sc_hd__a22oi_1 U10968 ( .A1(n9480), .A2(\cpuregs[20][31] ), .B1(
        n9473), .B2(\cpuregs[23][31] ), .Y(n9288) );
  sky130_fd_sc_hd__a22oi_1 U10969 ( .A1(n9490), .A2(\cpuregs[11][31] ), .B1(
        n9491), .B2(\cpuregs[10][31] ), .Y(n9287) );
  sky130_fd_sc_hd__a22oi_1 U10970 ( .A1(n9321), .A2(\cpuregs[27][31] ), .B1(
        n9471), .B2(\cpuregs[25][31] ), .Y(n9286) );
  sky130_fd_sc_hd__a22oi_1 U10971 ( .A1(n9460), .A2(\cpuregs[24][31] ), .B1(
        n9485), .B2(\cpuregs[21][31] ), .Y(n9285) );
  sky130_fd_sc_hd__nand4_1 U10972 ( .A(n9288), .B(n9287), .C(n9286), .D(n9285), 
        .Y(n9300) );
  sky130_fd_sc_hd__a22oi_1 U10973 ( .A1(n9468), .A2(\cpuregs[16][31] ), .B1(
        n9289), .B2(\cpuregs[18][31] ), .Y(n9293) );
  sky130_fd_sc_hd__a22oi_1 U10974 ( .A1(n9467), .A2(\cpuregs[26][31] ), .B1(
        n9494), .B2(\cpuregs[8][31] ), .Y(n9292) );
  sky130_fd_sc_hd__a22oi_1 U10975 ( .A1(n9469), .A2(\cpuregs[9][31] ), .B1(
        n9457), .B2(\cpuregs[19][31] ), .Y(n9291) );
  sky130_fd_sc_hd__a22oi_1 U10976 ( .A1(n9483), .A2(\cpuregs[7][31] ), .B1(
        n9461), .B2(\cpuregs[5][31] ), .Y(n9290) );
  sky130_fd_sc_hd__nand4_1 U10977 ( .A(n9293), .B(n9292), .C(n9291), .D(n9290), 
        .Y(n9299) );
  sky130_fd_sc_hd__a22oi_1 U10978 ( .A1(n9481), .A2(\cpuregs[14][31] ), .B1(
        n9470), .B2(\cpuregs[13][31] ), .Y(n9297) );
  sky130_fd_sc_hd__a22oi_1 U10979 ( .A1(n9482), .A2(\cpuregs[31][31] ), .B1(
        n9495), .B2(\cpuregs[22][31] ), .Y(n9296) );
  sky130_fd_sc_hd__a22oi_1 U10980 ( .A1(n9458), .A2(\cpuregs[30][31] ), .B1(
        n9479), .B2(\cpuregs[29][31] ), .Y(n9295) );
  sky130_fd_sc_hd__a22oi_1 U10981 ( .A1(n9492), .A2(\cpuregs[28][31] ), .B1(
        n9497), .B2(\cpuregs[15][31] ), .Y(n9294) );
  sky130_fd_sc_hd__nand4_1 U10982 ( .A(n9297), .B(n9296), .C(n9295), .D(n9294), 
        .Y(n9298) );
  sky130_fd_sc_hd__nor4_1 U10983 ( .A(n9301), .B(n9300), .C(n9299), .D(n9298), 
        .Y(n9303) );
  sky130_fd_sc_hd__o22ai_1 U10984 ( .A1(n9305), .A2(n9304), .B1(n9303), .B2(
        n9302), .Y(n9306) );
  sky130_fd_sc_hd__nand2_1 U10985 ( .A(n9307), .B(pcpi_rs1[27]), .Y(n9308) );
  sky130_fd_sc_hd__nand4_1 U10986 ( .A(n9311), .B(n9310), .C(n9309), .D(n9308), 
        .Y(n2764) );
  sky130_fd_sc_hd__a22oi_1 U10987 ( .A1(n9493), .A2(\cpuregs[6][2] ), .B1(
        n9478), .B2(\cpuregs[1][2] ), .Y(n9315) );
  sky130_fd_sc_hd__a22oi_1 U10988 ( .A1(n9457), .A2(\cpuregs[19][2] ), .B1(
        n9480), .B2(\cpuregs[20][2] ), .Y(n9314) );
  sky130_fd_sc_hd__a22oi_1 U10989 ( .A1(n9481), .A2(\cpuregs[14][2] ), .B1(
        n9459), .B2(\cpuregs[18][2] ), .Y(n9313) );
  sky130_fd_sc_hd__nand2_1 U10990 ( .A(n9483), .B(\cpuregs[7][2] ), .Y(n9312)
         );
  sky130_fd_sc_hd__nand4_1 U10991 ( .A(n9315), .B(n9314), .C(n9313), .D(n9312), 
        .Y(n9333) );
  sky130_fd_sc_hd__a22oi_1 U10992 ( .A1(n9467), .A2(\cpuregs[26][2] ), .B1(
        n9491), .B2(\cpuregs[10][2] ), .Y(n9320) );
  sky130_fd_sc_hd__a22oi_1 U10993 ( .A1(n9460), .A2(\cpuregs[24][2] ), .B1(
        n9469), .B2(\cpuregs[9][2] ), .Y(n9319) );
  sky130_fd_sc_hd__a22oi_1 U10994 ( .A1(n9494), .A2(\cpuregs[8][2] ), .B1(
        n9482), .B2(\cpuregs[31][2] ), .Y(n9318) );
  sky130_fd_sc_hd__a22oi_1 U10995 ( .A1(n9458), .A2(\cpuregs[30][2] ), .B1(
        n9316), .B2(\cpuregs[4][2] ), .Y(n9317) );
  sky130_fd_sc_hd__nand4_1 U10996 ( .A(n9320), .B(n9319), .C(n9318), .D(n9317), 
        .Y(n9332) );
  sky130_fd_sc_hd__a22oi_1 U10997 ( .A1(n9321), .A2(\cpuregs[27][2] ), .B1(
        n9456), .B2(\cpuregs[17][2] ), .Y(n9325) );
  sky130_fd_sc_hd__a22oi_1 U10998 ( .A1(n9461), .A2(\cpuregs[5][2] ), .B1(
        n9471), .B2(\cpuregs[25][2] ), .Y(n9324) );
  sky130_fd_sc_hd__a22oi_1 U10999 ( .A1(n9468), .A2(\cpuregs[16][2] ), .B1(
        n9496), .B2(\cpuregs[3][2] ), .Y(n9323) );
  sky130_fd_sc_hd__a22oi_1 U11000 ( .A1(n9462), .A2(\cpuregs[2][2] ), .B1(
        n9484), .B2(\cpuregs[12][2] ), .Y(n9322) );
  sky130_fd_sc_hd__nand4_1 U11001 ( .A(n9325), .B(n9324), .C(n9323), .D(n9322), 
        .Y(n9331) );
  sky130_fd_sc_hd__a22oi_1 U11002 ( .A1(n9485), .A2(\cpuregs[21][2] ), .B1(
        n9479), .B2(\cpuregs[29][2] ), .Y(n9329) );
  sky130_fd_sc_hd__a22oi_1 U11003 ( .A1(n9497), .A2(\cpuregs[15][2] ), .B1(
        n9490), .B2(\cpuregs[11][2] ), .Y(n9328) );
  sky130_fd_sc_hd__a22oi_1 U11004 ( .A1(n9492), .A2(\cpuregs[28][2] ), .B1(
        n9495), .B2(\cpuregs[22][2] ), .Y(n9327) );
  sky130_fd_sc_hd__a22oi_1 U11005 ( .A1(n9473), .A2(\cpuregs[23][2] ), .B1(
        n9470), .B2(\cpuregs[13][2] ), .Y(n9326) );
  sky130_fd_sc_hd__nand4_1 U11006 ( .A(n9329), .B(n9328), .C(n9327), .D(n9326), 
        .Y(n9330) );
  sky130_fd_sc_hd__nor4_1 U11007 ( .A(n9333), .B(n9332), .C(n9331), .D(n9330), 
        .Y(n9348) );
  sky130_fd_sc_hd__nand2_1 U11008 ( .A(n9336), .B(n9335), .Y(n9337) );
  sky130_fd_sc_hd__xor2_1 U11009 ( .A(n9338), .B(n9337), .X(n9339) );
  sky130_fd_sc_hd__nand2_1 U11010 ( .A(n9511), .B(n9339), .Y(n9347) );
  sky130_fd_sc_hd__o22ai_1 U11011 ( .A1(n4321), .A2(n9389), .B1(n9341), .B2(
        n9340), .Y(n9344) );
  sky130_fd_sc_hd__o22ai_1 U11012 ( .A1(n9342), .A2(n4342), .B1(n4340), .B2(
        n9907), .Y(n9343) );
  sky130_fd_sc_hd__a211oi_1 U11013 ( .A1(n9345), .A2(pcpi_rs1[6]), .B1(n9344), 
        .C1(n9343), .Y(n9346) );
  sky130_fd_sc_hd__o211ai_1 U11014 ( .A1(n9348), .A2(n9506), .B1(n9347), .C1(
        n9346), .Y(n2793) );
  sky130_fd_sc_hd__clkinv_1 U11015 ( .A(mem_rdata[2]), .Y(n9351) );
  sky130_fd_sc_hd__o22ai_1 U11016 ( .A1(n10022), .A2(n9851), .B1(n9850), .B2(
        n10081), .Y(n9349) );
  sky130_fd_sc_hd__a21oi_1 U11017 ( .A1(mem_rdata[18]), .A2(n9853), .B1(n9349), 
        .Y(n9350) );
  sky130_fd_sc_hd__o21ai_1 U11018 ( .A1(n10017), .A2(n9351), .B1(n9350), .Y(
        n4153) );
  sky130_fd_sc_hd__nand2_1 U11019 ( .A(n9354), .B(n9353), .Y(n9355) );
  sky130_fd_sc_hd__xor2_1 U11020 ( .A(n9356), .B(n9355), .X(n9357) );
  sky130_fd_sc_hd__nand2_1 U11021 ( .A(n9357), .B(n4639), .Y(n9362) );
  sky130_fd_sc_hd__a22o_1 U11022 ( .A1(n9859), .A2(mem_rdata_word[2]), .B1(
        n9858), .B2(pcpi_rs1[2]), .X(n9358) );
  sky130_fd_sc_hd__a21oi_1 U11023 ( .A1(n9861), .A2(count_cycle[34]), .B1(
        n9358), .Y(n9361) );
  sky130_fd_sc_hd__nand2_1 U11024 ( .A(n9860), .B(count_cycle[2]), .Y(n9360)
         );
  sky130_fd_sc_hd__a22oi_1 U11025 ( .A1(n9857), .A2(count_instr[2]), .B1(n9856), .B2(count_instr[34]), .Y(n9359) );
  sky130_fd_sc_hd__nand4_1 U11026 ( .A(n9362), .B(n9361), .C(n9360), .D(n9359), 
        .Y(N1879) );
  sky130_fd_sc_hd__nand2_1 U11027 ( .A(n9366), .B(n9365), .Y(n9368) );
  sky130_fd_sc_hd__xor2_1 U11028 ( .A(n9368), .B(n9367), .X(n9369) );
  sky130_fd_sc_hd__a222oi_1 U11029 ( .A1(n9363), .A2(n9370), .B1(n9530), .B2(
        reg_next_pc[2]), .C1(n5794), .C2(n9369), .Y(n9371) );
  sky130_fd_sc_hd__nand2_1 U11030 ( .A(n9374), .B(n9373), .Y(n9379) );
  sky130_fd_sc_hd__o21ai_1 U11031 ( .A1(n9377), .A2(n9376), .B1(n9375), .Y(
        n9378) );
  sky130_fd_sc_hd__xnor2_1 U11032 ( .A(n9379), .B(n9378), .Y(n9380) );
  sky130_fd_sc_hd__nand2_1 U11033 ( .A(n9380), .B(
        is_lui_auipc_jal_jalr_addi_add_sub), .Y(n9386) );
  sky130_fd_sc_hd__o21ai_1 U11034 ( .A1(pcpi_rs1[2]), .A2(pcpi_rs2[2]), .B1(
        n9872), .Y(n9385) );
  sky130_fd_sc_hd__nand2_1 U11035 ( .A(n9873), .B(n9381), .Y(n9384) );
  sky130_fd_sc_hd__nand3_1 U11036 ( .A(n9382), .B(pcpi_rs1[2]), .C(pcpi_rs2[2]), .Y(n9383) );
  sky130_fd_sc_hd__nand4_1 U11037 ( .A(n9386), .B(n9385), .C(n9384), .D(n9383), 
        .Y(alu_out[2]) );
  sky130_fd_sc_hd__inv_1 U11038 ( .A(n9363), .Y(n9388) );
  sky130_fd_sc_hd__o22ai_1 U11039 ( .A1(n10029), .A2(n9389), .B1(n9388), .B2(
        n9387), .Y(n4017) );
  sky130_fd_sc_hd__nand2_1 U11040 ( .A(n9815), .B(alu_out_q[2]), .Y(n9392) );
  sky130_fd_sc_hd__nand2_1 U11041 ( .A(n9816), .B(reg_out[2]), .Y(n9391) );
  sky130_fd_sc_hd__nand2_1 U11042 ( .A(n9389), .B(n9813), .Y(n9390) );
  sky130_fd_sc_hd__nand2_1 U11043 ( .A(n4179), .B(\cpuregs[4][2] ), .Y(n9393)
         );
  sky130_fd_sc_hd__o21ai_1 U11044 ( .A1(n9424), .A2(n4179), .B1(n9393), .Y(
        n3837) );
  sky130_fd_sc_hd__nand2_1 U11045 ( .A(n4226), .B(\cpuregs[12][2] ), .Y(n9394)
         );
  sky130_fd_sc_hd__o21ai_1 U11046 ( .A1(n9424), .A2(n4226), .B1(n9394), .Y(
        n3845) );
  sky130_fd_sc_hd__nand2_1 U11047 ( .A(n4197), .B(\cpuregs[16][2] ), .Y(n9395)
         );
  sky130_fd_sc_hd__o21ai_1 U11048 ( .A1(n9424), .A2(n4197), .B1(n9395), .Y(
        n3849) );
  sky130_fd_sc_hd__nand2_1 U11049 ( .A(n4183), .B(\cpuregs[8][2] ), .Y(n9396)
         );
  sky130_fd_sc_hd__o21ai_1 U11050 ( .A1(n9424), .A2(n4183), .B1(n9396), .Y(
        n3841) );
  sky130_fd_sc_hd__nand2_1 U11051 ( .A(n4219), .B(\cpuregs[28][2] ), .Y(n9397)
         );
  sky130_fd_sc_hd__o21ai_1 U11052 ( .A1(n9424), .A2(n4219), .B1(n9397), .Y(
        n3861) );
  sky130_fd_sc_hd__nand2_1 U11053 ( .A(n10058), .B(\cpuregs[20][2] ), .Y(n9398) );
  sky130_fd_sc_hd__o21ai_1 U11054 ( .A1(n9424), .A2(n10058), .B1(n9398), .Y(
        n3853) );
  sky130_fd_sc_hd__nand2_1 U11055 ( .A(n10057), .B(\cpuregs[24][2] ), .Y(n9399) );
  sky130_fd_sc_hd__o21ai_1 U11056 ( .A1(n9424), .A2(n10057), .B1(n9399), .Y(
        n3857) );
  sky130_fd_sc_hd__nand2_1 U11057 ( .A(n4199), .B(\cpuregs[7][2] ), .Y(n9400)
         );
  sky130_fd_sc_hd__o21ai_1 U11058 ( .A1(n9424), .A2(n4199), .B1(n9400), .Y(
        n3840) );
  sky130_fd_sc_hd__nand2_1 U11059 ( .A(n7069), .B(\cpuregs[15][2] ), .Y(n9401)
         );
  sky130_fd_sc_hd__o21ai_1 U11060 ( .A1(n9424), .A2(n7069), .B1(n9401), .Y(
        n3848) );
  sky130_fd_sc_hd__nand2_1 U11061 ( .A(n4194), .B(\cpuregs[19][2] ), .Y(n9402)
         );
  sky130_fd_sc_hd__o21ai_1 U11062 ( .A1(n9424), .A2(n4194), .B1(n9402), .Y(
        n3852) );
  sky130_fd_sc_hd__nand2_1 U11063 ( .A(n4185), .B(\cpuregs[11][2] ), .Y(n9403)
         );
  sky130_fd_sc_hd__o21ai_1 U11064 ( .A1(n9424), .A2(n4185), .B1(n9403), .Y(
        n3844) );
  sky130_fd_sc_hd__nand2_1 U11065 ( .A(n7247), .B(\cpuregs[31][2] ), .Y(n9404)
         );
  sky130_fd_sc_hd__o21ai_1 U11066 ( .A1(n9424), .A2(n7247), .B1(n9404), .Y(
        n3864) );
  sky130_fd_sc_hd__nand2_1 U11067 ( .A(n4173), .B(\cpuregs[23][2] ), .Y(n9405)
         );
  sky130_fd_sc_hd__o21ai_1 U11068 ( .A1(n9424), .A2(n4173), .B1(n9405), .Y(
        n3856) );
  sky130_fd_sc_hd__nand2_1 U11069 ( .A(n4175), .B(\cpuregs[27][2] ), .Y(n9406)
         );
  sky130_fd_sc_hd__o21ai_1 U11070 ( .A1(n9424), .A2(n4175), .B1(n9406), .Y(
        n3860) );
  sky130_fd_sc_hd__nand2_1 U11071 ( .A(n4201), .B(\cpuregs[3][2] ), .Y(n9407)
         );
  sky130_fd_sc_hd__o21ai_1 U11072 ( .A1(n9424), .A2(n4201), .B1(n9407), .Y(
        n3836) );
  sky130_fd_sc_hd__nand2_1 U11073 ( .A(n4180), .B(\cpuregs[5][2] ), .Y(n9408)
         );
  sky130_fd_sc_hd__o21ai_1 U11074 ( .A1(n9424), .A2(n4180), .B1(n9408), .Y(
        n3838) );
  sky130_fd_sc_hd__nand2_1 U11075 ( .A(n4186), .B(\cpuregs[13][2] ), .Y(n9409)
         );
  sky130_fd_sc_hd__o21ai_1 U11076 ( .A1(n9424), .A2(n4186), .B1(n9409), .Y(
        n3846) );
  sky130_fd_sc_hd__nand2_1 U11077 ( .A(n4195), .B(\cpuregs[17][2] ), .Y(n9410)
         );
  sky130_fd_sc_hd__o21ai_1 U11078 ( .A1(n9424), .A2(n4195), .B1(n9410), .Y(
        n3850) );
  sky130_fd_sc_hd__nand2_1 U11079 ( .A(n7452), .B(\cpuregs[9][2] ), .Y(n9411)
         );
  sky130_fd_sc_hd__o21ai_1 U11080 ( .A1(n9424), .A2(n7452), .B1(n9411), .Y(
        n3842) );
  sky130_fd_sc_hd__nand2_1 U11081 ( .A(n4176), .B(\cpuregs[29][2] ), .Y(n9412)
         );
  sky130_fd_sc_hd__o21ai_1 U11082 ( .A1(n9424), .A2(n4176), .B1(n9412), .Y(
        n3862) );
  sky130_fd_sc_hd__nand2_1 U11083 ( .A(n4174), .B(\cpuregs[21][2] ), .Y(n9413)
         );
  sky130_fd_sc_hd__o21ai_1 U11084 ( .A1(n9424), .A2(n4174), .B1(n9413), .Y(
        n3854) );
  sky130_fd_sc_hd__nand2_1 U11085 ( .A(n4192), .B(\cpuregs[25][2] ), .Y(n9414)
         );
  sky130_fd_sc_hd__o21ai_1 U11086 ( .A1(n9424), .A2(n4192), .B1(n9414), .Y(
        n3858) );
  sky130_fd_sc_hd__nand2_1 U11087 ( .A(n6396), .B(\cpuregs[1][2] ), .Y(n9415)
         );
  sky130_fd_sc_hd__o21ai_1 U11088 ( .A1(n9424), .A2(n6396), .B1(n9415), .Y(
        n3834) );
  sky130_fd_sc_hd__nand2_1 U11089 ( .A(n9772), .B(\cpuregs[6][2] ), .Y(n9416)
         );
  sky130_fd_sc_hd__o21ai_1 U11090 ( .A1(n9424), .A2(n9772), .B1(n9416), .Y(
        n3839) );
  sky130_fd_sc_hd__nand2_1 U11091 ( .A(n6897), .B(\cpuregs[14][2] ), .Y(n9417)
         );
  sky130_fd_sc_hd__o21ai_1 U11092 ( .A1(n9424), .A2(n6897), .B1(n9417), .Y(
        n3847) );
  sky130_fd_sc_hd__nand2_1 U11093 ( .A(n9820), .B(\cpuregs[18][2] ), .Y(n9418)
         );
  sky130_fd_sc_hd__o21ai_1 U11094 ( .A1(n9424), .A2(n9820), .B1(n9418), .Y(
        n3851) );
  sky130_fd_sc_hd__nand2_1 U11095 ( .A(n4184), .B(\cpuregs[10][2] ), .Y(n9419)
         );
  sky130_fd_sc_hd__o21ai_1 U11096 ( .A1(n9424), .A2(n4184), .B1(n9419), .Y(
        n3843) );
  sky130_fd_sc_hd__nand2_1 U11097 ( .A(n4177), .B(\cpuregs[30][2] ), .Y(n9420)
         );
  sky130_fd_sc_hd__o21ai_1 U11098 ( .A1(n9424), .A2(n4177), .B1(n9420), .Y(
        n3863) );
  sky130_fd_sc_hd__nand2_1 U11099 ( .A(n7084), .B(\cpuregs[22][2] ), .Y(n9421)
         );
  sky130_fd_sc_hd__o21ai_1 U11100 ( .A1(n9424), .A2(n7084), .B1(n9421), .Y(
        n3855) );
  sky130_fd_sc_hd__nand2_1 U11101 ( .A(n9621), .B(\cpuregs[26][2] ), .Y(n9422)
         );
  sky130_fd_sc_hd__o21ai_1 U11102 ( .A1(n9424), .A2(n9621), .B1(n9422), .Y(
        n3859) );
  sky130_fd_sc_hd__nand2_1 U11103 ( .A(n4178), .B(\cpuregs[2][2] ), .Y(n9423)
         );
  sky130_fd_sc_hd__o21ai_1 U11104 ( .A1(n9424), .A2(n4178), .B1(n9423), .Y(
        n3835) );
  sky130_fd_sc_hd__nand2_1 U11105 ( .A(n9434), .B(decoded_imm_j[2]), .Y(n9426)
         );
  sky130_fd_sc_hd__o211ai_1 U11106 ( .A1(reg_sh[2]), .A2(n9427), .B1(n9426), 
        .C1(n9425), .Y(N1911) );
  sky130_fd_sc_hd__nand3_1 U11107 ( .A(n9858), .B(reg_sh[4]), .C(n9428), .Y(
        n9430) );
  sky130_fd_sc_hd__o211ai_1 U11108 ( .A1(n9432), .A2(n9431), .B1(n9430), .C1(
        n9429), .Y(N1913) );
  sky130_fd_sc_hd__a22oi_1 U11109 ( .A1(reg_sh[3]), .A2(reg_sh[2]), .B1(n9433), 
        .B2(reg_sh[4]), .Y(n9438) );
  sky130_fd_sc_hd__nand2_1 U11110 ( .A(n9434), .B(decoded_imm_j[3]), .Y(n9436)
         );
  sky130_fd_sc_hd__o211ai_1 U11111 ( .A1(n9438), .A2(n9437), .B1(n9436), .C1(
        n9435), .Y(N1912) );
  sky130_fd_sc_hd__nand2_1 U11112 ( .A(n9439), .B(is_sb_sh_sw), .Y(n9528) );
  sky130_fd_sc_hd__o22ai_1 U11113 ( .A1(n9884), .A2(n9519), .B1(n9440), .B2(
        n9528), .Y(n2838) );
  sky130_fd_sc_hd__a21oi_1 U11114 ( .A1(n9444), .A2(n9443), .B1(n9442), .Y(
        n9445) );
  sky130_fd_sc_hd__o21ai_1 U11115 ( .A1(n9445), .A2(n10060), .B1(n9519), .Y(
        n9446) );
  sky130_fd_sc_hd__o21ai_1 U11116 ( .A1(n9883), .A2(n9519), .B1(n9446), .Y(
        n2834) );
  sky130_fd_sc_hd__nand3_1 U11117 ( .A(n9519), .B(n9447), .C(n10055), .Y(n9448) );
  sky130_fd_sc_hd__o21ai_1 U11118 ( .A1(n9449), .A2(n9519), .B1(n9448), .Y(
        n2835) );
  sky130_fd_sc_hd__nand2_1 U11119 ( .A(n9452), .B(pcpi_rs1[0]), .Y(n9453) );
  sky130_fd_sc_hd__o21ai_1 U11120 ( .A1(n9455), .A2(n9454), .B1(n9453), .Y(
        n9509) );
  sky130_fd_sc_hd__a22oi_1 U11121 ( .A1(n9457), .A2(\cpuregs[19][0] ), .B1(
        n9456), .B2(\cpuregs[17][0] ), .Y(n9466) );
  sky130_fd_sc_hd__a22oi_1 U11122 ( .A1(n9459), .A2(\cpuregs[18][0] ), .B1(
        n9458), .B2(\cpuregs[30][0] ), .Y(n9465) );
  sky130_fd_sc_hd__a22oi_1 U11123 ( .A1(n9461), .A2(\cpuregs[5][0] ), .B1(
        n9460), .B2(\cpuregs[24][0] ), .Y(n9464) );
  sky130_fd_sc_hd__nand2_1 U11124 ( .A(n9462), .B(\cpuregs[2][0] ), .Y(n9463)
         );
  sky130_fd_sc_hd__nand4_1 U11125 ( .A(n9466), .B(n9465), .C(n9464), .D(n9463), 
        .Y(n9505) );
  sky130_fd_sc_hd__a22oi_1 U11126 ( .A1(n9468), .A2(\cpuregs[16][0] ), .B1(
        n9467), .B2(\cpuregs[26][0] ), .Y(n9477) );
  sky130_fd_sc_hd__a22oi_1 U11127 ( .A1(n9321), .A2(\cpuregs[27][0] ), .B1(
        n9469), .B2(\cpuregs[9][0] ), .Y(n9476) );
  sky130_fd_sc_hd__a22oi_1 U11128 ( .A1(n9471), .A2(\cpuregs[25][0] ), .B1(
        n9470), .B2(\cpuregs[13][0] ), .Y(n9475) );
  sky130_fd_sc_hd__a22oi_1 U11129 ( .A1(n9473), .A2(\cpuregs[23][0] ), .B1(
        n9472), .B2(\cpuregs[4][0] ), .Y(n9474) );
  sky130_fd_sc_hd__nand4_1 U11130 ( .A(n9477), .B(n9476), .C(n9475), .D(n9474), 
        .Y(n9504) );
  sky130_fd_sc_hd__a22oi_1 U11131 ( .A1(n9479), .A2(\cpuregs[29][0] ), .B1(
        n9478), .B2(\cpuregs[1][0] ), .Y(n9489) );
  sky130_fd_sc_hd__a22oi_1 U11132 ( .A1(n9481), .A2(\cpuregs[14][0] ), .B1(
        n9480), .B2(\cpuregs[20][0] ), .Y(n9488) );
  sky130_fd_sc_hd__a22oi_1 U11133 ( .A1(n9483), .A2(\cpuregs[7][0] ), .B1(
        n9482), .B2(\cpuregs[31][0] ), .Y(n9487) );
  sky130_fd_sc_hd__a22oi_1 U11134 ( .A1(n9485), .A2(\cpuregs[21][0] ), .B1(
        n9484), .B2(\cpuregs[12][0] ), .Y(n9486) );
  sky130_fd_sc_hd__nand4_1 U11135 ( .A(n9489), .B(n9488), .C(n9487), .D(n9486), 
        .Y(n9503) );
  sky130_fd_sc_hd__a22oi_1 U11136 ( .A1(n9491), .A2(\cpuregs[10][0] ), .B1(
        n9490), .B2(\cpuregs[11][0] ), .Y(n9501) );
  sky130_fd_sc_hd__a22oi_1 U11137 ( .A1(n9493), .A2(\cpuregs[6][0] ), .B1(
        n9492), .B2(\cpuregs[28][0] ), .Y(n9500) );
  sky130_fd_sc_hd__a22oi_1 U11138 ( .A1(n9495), .A2(\cpuregs[22][0] ), .B1(
        n9494), .B2(\cpuregs[8][0] ), .Y(n9499) );
  sky130_fd_sc_hd__a22oi_1 U11139 ( .A1(n9497), .A2(\cpuregs[15][0] ), .B1(
        n9496), .B2(\cpuregs[3][0] ), .Y(n9498) );
  sky130_fd_sc_hd__nand4_1 U11140 ( .A(n9501), .B(n9500), .C(n9499), .D(n9498), 
        .Y(n9502) );
  sky130_fd_sc_hd__nor4_1 U11141 ( .A(n9505), .B(n9504), .C(n9503), .D(n9502), 
        .Y(n9507) );
  sky130_fd_sc_hd__o22ai_1 U11142 ( .A1(n9507), .A2(n9506), .B1(n4342), .B2(
        n9907), .Y(n9508) );
  sky130_fd_sc_hd__a211o_1 U11143 ( .A1(n9511), .A2(n9510), .B1(n9509), .C1(
        n9508), .X(n2934) );
  sky130_fd_sc_hd__nor2_1 U11144 ( .A(n9512), .B(n9533), .Y(n9516) );
  sky130_fd_sc_hd__nor3_1 U11145 ( .A(is_sll_srl_sra), .B(n9513), .C(
        is_sb_sh_sw), .Y(n9515) );
  sky130_fd_sc_hd__o21ai_1 U11146 ( .A1(n9516), .A2(n9515), .B1(n9514), .Y(
        n9517) );
  sky130_fd_sc_hd__o21ai_1 U11147 ( .A1(n9519), .A2(n9518), .B1(n9517), .Y(
        n2836) );
  sky130_fd_sc_hd__o22ai_1 U11148 ( .A1(n9522), .A2(n9521), .B1(n9909), .B2(
        n9520), .Y(n9523) );
  sky130_fd_sc_hd__a21oi_1 U11149 ( .A1(n9525), .A2(n9524), .B1(n9523), .Y(
        n9527) );
  sky130_fd_sc_hd__a21oi_1 U11150 ( .A1(n9528), .A2(n9527), .B1(n9526), .Y(
        n9540) );
  sky130_fd_sc_hd__nand3_1 U11151 ( .A(n9531), .B(n9530), .C(n9529), .Y(n9536)
         );
  sky130_fd_sc_hd__a21oi_1 U11152 ( .A1(n9534), .A2(n9533), .B1(n9532), .Y(
        n9535) );
  sky130_fd_sc_hd__a211oi_1 U11153 ( .A1(n9538), .A2(n9537), .B1(n9536), .C1(
        n9535), .Y(n9539) );
  sky130_fd_sc_hd__mux2i_1 U11154 ( .A0(n9540), .A1(mem_do_rinst), .S(n9539), 
        .Y(n9541) );
  sky130_fd_sc_hd__nand2_1 U11155 ( .A(n9542), .B(n9541), .Y(n2840) );
  sky130_fd_sc_hd__o21ai_1 U11156 ( .A1(n9544), .A2(n9881), .B1(n10114), .Y(
        n9546) );
  sky130_fd_sc_hd__nand2_1 U11157 ( .A(n9546), .B(n9545), .Y(N2077) );
  sky130_fd_sc_hd__o22ai_1 U11158 ( .A1(n9548), .A2(n10052), .B1(n10034), .B2(
        n9547), .Y(n3987) );
  sky130_fd_sc_hd__nand2_1 U11159 ( .A(n9549), .B(reg_pc[4]), .Y(n9551) );
  sky130_fd_sc_hd__xor2_1 U11160 ( .A(n9551), .B(n9550), .X(n9552) );
  sky130_fd_sc_hd__nand2_1 U11161 ( .A(n9552), .B(n9813), .Y(n9554) );
  sky130_fd_sc_hd__a22oi_1 U11162 ( .A1(n9816), .A2(reg_out[5]), .B1(n9815), 
        .B2(alu_out_q[5]), .Y(n9553) );
  sky130_fd_sc_hd__nand2_1 U11163 ( .A(n6396), .B(\cpuregs[1][5] ), .Y(n9555)
         );
  sky130_fd_sc_hd__o21ai_1 U11164 ( .A1(n9586), .A2(n6396), .B1(n9555), .Y(
        n3741) );
  sky130_fd_sc_hd__nand2_1 U11165 ( .A(n10057), .B(\cpuregs[24][5] ), .Y(n9556) );
  sky130_fd_sc_hd__o21ai_1 U11166 ( .A1(n9586), .A2(n10057), .B1(n9556), .Y(
        n3764) );
  sky130_fd_sc_hd__nand2_1 U11167 ( .A(n10058), .B(\cpuregs[20][5] ), .Y(n9557) );
  sky130_fd_sc_hd__o21ai_1 U11168 ( .A1(n9586), .A2(n10058), .B1(n9557), .Y(
        n3760) );
  sky130_fd_sc_hd__nand2_1 U11169 ( .A(n4176), .B(\cpuregs[29][5] ), .Y(n9558)
         );
  sky130_fd_sc_hd__o21ai_1 U11170 ( .A1(n9586), .A2(n4176), .B1(n9558), .Y(
        n3769) );
  sky130_fd_sc_hd__nand2_1 U11171 ( .A(n4184), .B(\cpuregs[10][5] ), .Y(n9559)
         );
  sky130_fd_sc_hd__o21ai_1 U11172 ( .A1(n9586), .A2(n4184), .B1(n9559), .Y(
        n3750) );
  sky130_fd_sc_hd__nand2_1 U11173 ( .A(n9820), .B(\cpuregs[18][5] ), .Y(n9560)
         );
  sky130_fd_sc_hd__o21ai_1 U11174 ( .A1(n9586), .A2(n9820), .B1(n9560), .Y(
        n3758) );
  sky130_fd_sc_hd__nand2_1 U11175 ( .A(n4192), .B(\cpuregs[25][5] ), .Y(n9561)
         );
  sky130_fd_sc_hd__o21ai_1 U11176 ( .A1(n9586), .A2(n4192), .B1(n9561), .Y(
        n3765) );
  sky130_fd_sc_hd__nand2_1 U11177 ( .A(n7069), .B(\cpuregs[15][5] ), .Y(n9562)
         );
  sky130_fd_sc_hd__o21ai_1 U11178 ( .A1(n9586), .A2(n7069), .B1(n9562), .Y(
        n3755) );
  sky130_fd_sc_hd__nand2_1 U11179 ( .A(n4177), .B(\cpuregs[30][5] ), .Y(n9563)
         );
  sky130_fd_sc_hd__o21ai_1 U11180 ( .A1(n9586), .A2(n4177), .B1(n9563), .Y(
        n3770) );
  sky130_fd_sc_hd__nand2_1 U11181 ( .A(n6897), .B(\cpuregs[14][5] ), .Y(n9564)
         );
  sky130_fd_sc_hd__o21ai_1 U11182 ( .A1(n9586), .A2(n6897), .B1(n9564), .Y(
        n3754) );
  sky130_fd_sc_hd__nand2_1 U11183 ( .A(n7084), .B(\cpuregs[22][5] ), .Y(n9565)
         );
  sky130_fd_sc_hd__o21ai_1 U11184 ( .A1(n9586), .A2(n7084), .B1(n9565), .Y(
        n3762) );
  sky130_fd_sc_hd__nand2_1 U11185 ( .A(n4174), .B(\cpuregs[21][5] ), .Y(n9566)
         );
  sky130_fd_sc_hd__o21ai_1 U11186 ( .A1(n9586), .A2(n4174), .B1(n9566), .Y(
        n3761) );
  sky130_fd_sc_hd__nand2_1 U11187 ( .A(n7452), .B(\cpuregs[9][5] ), .Y(n9567)
         );
  sky130_fd_sc_hd__o21ai_1 U11188 ( .A1(n9586), .A2(n7452), .B1(n9567), .Y(
        n3749) );
  sky130_fd_sc_hd__nand2_1 U11189 ( .A(n4201), .B(\cpuregs[3][5] ), .Y(n9568)
         );
  sky130_fd_sc_hd__o21ai_1 U11190 ( .A1(n9586), .A2(n4201), .B1(n9568), .Y(
        n3743) );
  sky130_fd_sc_hd__nand2_1 U11191 ( .A(n7247), .B(\cpuregs[31][5] ), .Y(n9569)
         );
  sky130_fd_sc_hd__o21ai_1 U11192 ( .A1(n9586), .A2(n7247), .B1(n9569), .Y(
        n3771) );
  sky130_fd_sc_hd__nand2_1 U11193 ( .A(n4178), .B(\cpuregs[2][5] ), .Y(n9570)
         );
  sky130_fd_sc_hd__o21ai_1 U11194 ( .A1(n9586), .A2(n4178), .B1(n9570), .Y(
        n3742) );
  sky130_fd_sc_hd__nand2_1 U11195 ( .A(n4219), .B(\cpuregs[28][5] ), .Y(n9571)
         );
  sky130_fd_sc_hd__o21ai_1 U11196 ( .A1(n9586), .A2(n4219), .B1(n9571), .Y(
        n3768) );
  sky130_fd_sc_hd__nand2_1 U11197 ( .A(n4180), .B(\cpuregs[5][5] ), .Y(n9572)
         );
  sky130_fd_sc_hd__o21ai_1 U11198 ( .A1(n9586), .A2(n4180), .B1(n9572), .Y(
        n3745) );
  sky130_fd_sc_hd__nand2_1 U11199 ( .A(n9621), .B(\cpuregs[26][5] ), .Y(n9573)
         );
  sky130_fd_sc_hd__o21ai_1 U11200 ( .A1(n9586), .A2(n9621), .B1(n9573), .Y(
        n3766) );
  sky130_fd_sc_hd__nand2_1 U11201 ( .A(n4197), .B(\cpuregs[16][5] ), .Y(n9574)
         );
  sky130_fd_sc_hd__o21ai_1 U11202 ( .A1(n9586), .A2(n4197), .B1(n9574), .Y(
        n3756) );
  sky130_fd_sc_hd__nand2_1 U11203 ( .A(n4194), .B(\cpuregs[19][5] ), .Y(n9575)
         );
  sky130_fd_sc_hd__o21ai_1 U11204 ( .A1(n9586), .A2(n4194), .B1(n9575), .Y(
        n3759) );
  sky130_fd_sc_hd__nand2_1 U11205 ( .A(n4199), .B(\cpuregs[7][5] ), .Y(n9576)
         );
  sky130_fd_sc_hd__o21ai_1 U11206 ( .A1(n9586), .A2(n4199), .B1(n9576), .Y(
        n3747) );
  sky130_fd_sc_hd__nand2_1 U11207 ( .A(n4173), .B(\cpuregs[23][5] ), .Y(n9577)
         );
  sky130_fd_sc_hd__o21ai_1 U11208 ( .A1(n9586), .A2(n4173), .B1(n9577), .Y(
        n3763) );
  sky130_fd_sc_hd__nand2_1 U11209 ( .A(n4183), .B(\cpuregs[8][5] ), .Y(n9578)
         );
  sky130_fd_sc_hd__o21ai_1 U11210 ( .A1(n9586), .A2(n4183), .B1(n9578), .Y(
        n3748) );
  sky130_fd_sc_hd__nand2_1 U11211 ( .A(n4186), .B(\cpuregs[13][5] ), .Y(n9579)
         );
  sky130_fd_sc_hd__o21ai_1 U11212 ( .A1(n9586), .A2(n4186), .B1(n9579), .Y(
        n3753) );
  sky130_fd_sc_hd__nand2_1 U11213 ( .A(n4175), .B(\cpuregs[27][5] ), .Y(n9580)
         );
  sky130_fd_sc_hd__o21ai_1 U11214 ( .A1(n9586), .A2(n4175), .B1(n9580), .Y(
        n3767) );
  sky130_fd_sc_hd__nand2_1 U11215 ( .A(n4226), .B(\cpuregs[12][5] ), .Y(n9581)
         );
  sky130_fd_sc_hd__o21ai_1 U11216 ( .A1(n9586), .A2(n4226), .B1(n9581), .Y(
        n3752) );
  sky130_fd_sc_hd__nand2_1 U11217 ( .A(n4195), .B(\cpuregs[17][5] ), .Y(n9582)
         );
  sky130_fd_sc_hd__o21ai_1 U11218 ( .A1(n9586), .A2(n4195), .B1(n9582), .Y(
        n3757) );
  sky130_fd_sc_hd__nand2_1 U11219 ( .A(n9772), .B(\cpuregs[6][5] ), .Y(n9583)
         );
  sky130_fd_sc_hd__o21ai_1 U11220 ( .A1(n9586), .A2(n9772), .B1(n9583), .Y(
        n3746) );
  sky130_fd_sc_hd__nand2_1 U11221 ( .A(n4179), .B(\cpuregs[4][5] ), .Y(n9584)
         );
  sky130_fd_sc_hd__o21ai_1 U11222 ( .A1(n9586), .A2(n4179), .B1(n9584), .Y(
        n3744) );
  sky130_fd_sc_hd__nand2_1 U11223 ( .A(n4185), .B(\cpuregs[11][5] ), .Y(n9585)
         );
  sky130_fd_sc_hd__o21ai_1 U11224 ( .A1(n9586), .A2(n4185), .B1(n9585), .Y(
        n3751) );
  sky130_fd_sc_hd__xor2_1 U11225 ( .A(n9662), .B(n9624), .X(n9588) );
  sky130_fd_sc_hd__nand2_1 U11226 ( .A(n9588), .B(n9813), .Y(n9590) );
  sky130_fd_sc_hd__a22oi_1 U11227 ( .A1(n9816), .A2(reg_out[6]), .B1(n9815), 
        .B2(alu_out_q[6]), .Y(n9589) );
  sky130_fd_sc_hd__nand2_1 U11228 ( .A(n9820), .B(\cpuregs[18][6] ), .Y(n9591)
         );
  sky130_fd_sc_hd__o21ai_1 U11229 ( .A1(n9623), .A2(n9820), .B1(n9591), .Y(
        n3727) );
  sky130_fd_sc_hd__nand2_1 U11230 ( .A(n4174), .B(\cpuregs[21][6] ), .Y(n9592)
         );
  sky130_fd_sc_hd__o21ai_1 U11231 ( .A1(n9623), .A2(n4174), .B1(n9592), .Y(
        n3730) );
  sky130_fd_sc_hd__nand2_1 U11232 ( .A(n10058), .B(\cpuregs[20][6] ), .Y(n9593) );
  sky130_fd_sc_hd__o21ai_1 U11233 ( .A1(n9623), .A2(n10058), .B1(n9593), .Y(
        n3729) );
  sky130_fd_sc_hd__nand2_1 U11234 ( .A(n10057), .B(\cpuregs[24][6] ), .Y(n9594) );
  sky130_fd_sc_hd__o21ai_1 U11235 ( .A1(n9623), .A2(n10057), .B1(n9594), .Y(
        n3733) );
  sky130_fd_sc_hd__nand2_1 U11236 ( .A(n4201), .B(\cpuregs[3][6] ), .Y(n9595)
         );
  sky130_fd_sc_hd__o21ai_1 U11237 ( .A1(n9623), .A2(n4201), .B1(n9595), .Y(
        n3712) );
  sky130_fd_sc_hd__nand2_1 U11238 ( .A(n4180), .B(\cpuregs[5][6] ), .Y(n9596)
         );
  sky130_fd_sc_hd__o21ai_1 U11239 ( .A1(n9623), .A2(n4180), .B1(n9596), .Y(
        n3714) );
  sky130_fd_sc_hd__nand2_1 U11240 ( .A(n6396), .B(\cpuregs[1][6] ), .Y(n9597)
         );
  sky130_fd_sc_hd__o21ai_1 U11241 ( .A1(n9623), .A2(n6396), .B1(n9597), .Y(
        n3710) );
  sky130_fd_sc_hd__nand2_1 U11242 ( .A(n4183), .B(\cpuregs[8][6] ), .Y(n9598)
         );
  sky130_fd_sc_hd__o21ai_1 U11243 ( .A1(n9623), .A2(n4183), .B1(n9598), .Y(
        n3717) );
  sky130_fd_sc_hd__nand2_1 U11244 ( .A(n7084), .B(\cpuregs[22][6] ), .Y(n9599)
         );
  sky130_fd_sc_hd__o21ai_1 U11245 ( .A1(n9623), .A2(n7084), .B1(n9599), .Y(
        n3731) );
  sky130_fd_sc_hd__nand2_1 U11246 ( .A(n4178), .B(\cpuregs[2][6] ), .Y(n9600)
         );
  sky130_fd_sc_hd__o21ai_1 U11247 ( .A1(n9623), .A2(n4178), .B1(n9600), .Y(
        n3711) );
  sky130_fd_sc_hd__nand2_1 U11248 ( .A(n4197), .B(\cpuregs[16][6] ), .Y(n9601)
         );
  sky130_fd_sc_hd__o21ai_1 U11249 ( .A1(n9623), .A2(n4197), .B1(n9601), .Y(
        n3725) );
  sky130_fd_sc_hd__nand2_1 U11250 ( .A(n7069), .B(\cpuregs[15][6] ), .Y(n9602)
         );
  sky130_fd_sc_hd__o21ai_1 U11251 ( .A1(n9623), .A2(n7069), .B1(n9602), .Y(
        n3724) );
  sky130_fd_sc_hd__nand2_1 U11252 ( .A(n4186), .B(\cpuregs[13][6] ), .Y(n9603)
         );
  sky130_fd_sc_hd__o21ai_1 U11253 ( .A1(n9623), .A2(n4186), .B1(n9603), .Y(
        n3722) );
  sky130_fd_sc_hd__nand2_1 U11254 ( .A(n7247), .B(\cpuregs[31][6] ), .Y(n9604)
         );
  sky130_fd_sc_hd__o21ai_1 U11255 ( .A1(n9623), .A2(n7247), .B1(n9604), .Y(
        n3740) );
  sky130_fd_sc_hd__nand2_1 U11256 ( .A(n4219), .B(\cpuregs[28][6] ), .Y(n9605)
         );
  sky130_fd_sc_hd__o21ai_1 U11257 ( .A1(n9623), .A2(n4219), .B1(n9605), .Y(
        n3737) );
  sky130_fd_sc_hd__nand2_1 U11258 ( .A(n6897), .B(\cpuregs[14][6] ), .Y(n9606)
         );
  sky130_fd_sc_hd__o21ai_1 U11259 ( .A1(n9623), .A2(n6897), .B1(n9606), .Y(
        n3723) );
  sky130_fd_sc_hd__nand2_1 U11260 ( .A(n4175), .B(\cpuregs[27][6] ), .Y(n9607)
         );
  sky130_fd_sc_hd__o21ai_1 U11261 ( .A1(n9623), .A2(n4175), .B1(n9607), .Y(
        n3736) );
  sky130_fd_sc_hd__nand2_1 U11262 ( .A(n4194), .B(\cpuregs[19][6] ), .Y(n9608)
         );
  sky130_fd_sc_hd__o21ai_1 U11263 ( .A1(n9623), .A2(n4194), .B1(n9608), .Y(
        n3728) );
  sky130_fd_sc_hd__nand2_1 U11264 ( .A(n4173), .B(\cpuregs[23][6] ), .Y(n9609)
         );
  sky130_fd_sc_hd__o21ai_1 U11265 ( .A1(n9623), .A2(n4173), .B1(n9609), .Y(
        n3732) );
  sky130_fd_sc_hd__nand2_1 U11266 ( .A(n4179), .B(\cpuregs[4][6] ), .Y(n9610)
         );
  sky130_fd_sc_hd__o21ai_1 U11267 ( .A1(n9623), .A2(n4179), .B1(n9610), .Y(
        n3713) );
  sky130_fd_sc_hd__nand2_1 U11268 ( .A(n4184), .B(\cpuregs[10][6] ), .Y(n9611)
         );
  sky130_fd_sc_hd__o21ai_1 U11269 ( .A1(n9623), .A2(n4184), .B1(n9611), .Y(
        n3719) );
  sky130_fd_sc_hd__nand2_1 U11270 ( .A(n4226), .B(\cpuregs[12][6] ), .Y(n9612)
         );
  sky130_fd_sc_hd__o21ai_1 U11271 ( .A1(n9623), .A2(n4226), .B1(n9612), .Y(
        n3721) );
  sky130_fd_sc_hd__nand2_1 U11272 ( .A(n4177), .B(\cpuregs[30][6] ), .Y(n9613)
         );
  sky130_fd_sc_hd__o21ai_1 U11273 ( .A1(n9623), .A2(n4177), .B1(n9613), .Y(
        n3739) );
  sky130_fd_sc_hd__nand2_1 U11274 ( .A(n4195), .B(\cpuregs[17][6] ), .Y(n9614)
         );
  sky130_fd_sc_hd__o21ai_1 U11275 ( .A1(n9623), .A2(n4195), .B1(n9614), .Y(
        n3726) );
  sky130_fd_sc_hd__nand2_1 U11276 ( .A(n9772), .B(\cpuregs[6][6] ), .Y(n9615)
         );
  sky130_fd_sc_hd__o21ai_1 U11277 ( .A1(n9623), .A2(n9772), .B1(n9615), .Y(
        n3715) );
  sky130_fd_sc_hd__nand2_1 U11278 ( .A(n4199), .B(\cpuregs[7][6] ), .Y(n9616)
         );
  sky130_fd_sc_hd__o21ai_1 U11279 ( .A1(n9623), .A2(n4199), .B1(n9616), .Y(
        n3716) );
  sky130_fd_sc_hd__nand2_1 U11280 ( .A(n4176), .B(\cpuregs[29][6] ), .Y(n9617)
         );
  sky130_fd_sc_hd__o21ai_1 U11281 ( .A1(n9623), .A2(n4176), .B1(n9617), .Y(
        n3738) );
  sky130_fd_sc_hd__nand2_1 U11282 ( .A(n4192), .B(\cpuregs[25][6] ), .Y(n9618)
         );
  sky130_fd_sc_hd__o21ai_1 U11283 ( .A1(n9623), .A2(n4192), .B1(n9618), .Y(
        n3734) );
  sky130_fd_sc_hd__nand2_1 U11284 ( .A(n7452), .B(\cpuregs[9][6] ), .Y(n9619)
         );
  sky130_fd_sc_hd__o21ai_1 U11285 ( .A1(n9623), .A2(n7452), .B1(n9619), .Y(
        n3718) );
  sky130_fd_sc_hd__nand2_1 U11286 ( .A(n4185), .B(\cpuregs[11][6] ), .Y(n9620)
         );
  sky130_fd_sc_hd__o21ai_1 U11287 ( .A1(n9623), .A2(n4185), .B1(n9620), .Y(
        n3720) );
  sky130_fd_sc_hd__nand2_1 U11288 ( .A(n9621), .B(\cpuregs[26][6] ), .Y(n9622)
         );
  sky130_fd_sc_hd__o21ai_1 U11289 ( .A1(n9623), .A2(n9621), .B1(n9622), .Y(
        n3735) );
  sky130_fd_sc_hd__nor2_1 U11290 ( .A(n9624), .B(n9662), .Y(n9625) );
  sky130_fd_sc_hd__xnor2_1 U11291 ( .A(n9626), .B(n9625), .Y(n9627) );
  sky130_fd_sc_hd__nand2_1 U11292 ( .A(n9627), .B(n9813), .Y(n9629) );
  sky130_fd_sc_hd__a22oi_1 U11293 ( .A1(n9816), .A2(reg_out[7]), .B1(n9815), 
        .B2(alu_out_q[7]), .Y(n9628) );
  sky130_fd_sc_hd__nand2_1 U11294 ( .A(n6396), .B(\cpuregs[1][7] ), .Y(n9630)
         );
  sky130_fd_sc_hd__o21ai_1 U11295 ( .A1(n9661), .A2(n6396), .B1(n9630), .Y(
        n3679) );
  sky130_fd_sc_hd__nand2_1 U11296 ( .A(n7247), .B(\cpuregs[31][7] ), .Y(n9631)
         );
  sky130_fd_sc_hd__o21ai_1 U11297 ( .A1(n9661), .A2(n7247), .B1(n9631), .Y(
        n3709) );
  sky130_fd_sc_hd__nand2_1 U11298 ( .A(n4219), .B(\cpuregs[28][7] ), .Y(n9632)
         );
  sky130_fd_sc_hd__o21ai_1 U11299 ( .A1(n9661), .A2(n4219), .B1(n9632), .Y(
        n3706) );
  sky130_fd_sc_hd__nand2_1 U11300 ( .A(n4195), .B(\cpuregs[17][7] ), .Y(n9633)
         );
  sky130_fd_sc_hd__o21ai_1 U11301 ( .A1(n9661), .A2(n4195), .B1(n9633), .Y(
        n3695) );
  sky130_fd_sc_hd__nand2_1 U11302 ( .A(n4176), .B(\cpuregs[29][7] ), .Y(n9634)
         );
  sky130_fd_sc_hd__o21ai_1 U11303 ( .A1(n9661), .A2(n4176), .B1(n9634), .Y(
        n3707) );
  sky130_fd_sc_hd__nand2_1 U11304 ( .A(n4226), .B(\cpuregs[12][7] ), .Y(n9635)
         );
  sky130_fd_sc_hd__o21ai_1 U11305 ( .A1(n9661), .A2(n4226), .B1(n9635), .Y(
        n3690) );
  sky130_fd_sc_hd__nand2_1 U11306 ( .A(n4179), .B(\cpuregs[4][7] ), .Y(n9636)
         );
  sky130_fd_sc_hd__o21ai_1 U11307 ( .A1(n9661), .A2(n4179), .B1(n9636), .Y(
        n3682) );
  sky130_fd_sc_hd__nand2_1 U11308 ( .A(n10058), .B(\cpuregs[20][7] ), .Y(n9637) );
  sky130_fd_sc_hd__o21ai_1 U11309 ( .A1(n9661), .A2(n10058), .B1(n9637), .Y(
        n3698) );
  sky130_fd_sc_hd__nand2_1 U11310 ( .A(n4173), .B(\cpuregs[23][7] ), .Y(n9638)
         );
  sky130_fd_sc_hd__o21ai_1 U11311 ( .A1(n9661), .A2(n4173), .B1(n9638), .Y(
        n3701) );
  sky130_fd_sc_hd__nand2_1 U11312 ( .A(n4192), .B(\cpuregs[25][7] ), .Y(n9639)
         );
  sky130_fd_sc_hd__o21ai_1 U11313 ( .A1(n9661), .A2(n4192), .B1(n9639), .Y(
        n3703) );
  sky130_fd_sc_hd__nand2_1 U11314 ( .A(n4197), .B(\cpuregs[16][7] ), .Y(n9640)
         );
  sky130_fd_sc_hd__o21ai_1 U11315 ( .A1(n9661), .A2(n4197), .B1(n9640), .Y(
        n3694) );
  sky130_fd_sc_hd__nand2_1 U11316 ( .A(n4184), .B(\cpuregs[10][7] ), .Y(n9641)
         );
  sky130_fd_sc_hd__o21ai_1 U11317 ( .A1(n9661), .A2(n4184), .B1(n9641), .Y(
        n3688) );
  sky130_fd_sc_hd__nand2_1 U11318 ( .A(n9621), .B(\cpuregs[26][7] ), .Y(n9642)
         );
  sky130_fd_sc_hd__o21ai_1 U11319 ( .A1(n9661), .A2(n9621), .B1(n9642), .Y(
        n3704) );
  sky130_fd_sc_hd__nand2_1 U11320 ( .A(n9820), .B(\cpuregs[18][7] ), .Y(n9643)
         );
  sky130_fd_sc_hd__o21ai_1 U11321 ( .A1(n9661), .A2(n9820), .B1(n9643), .Y(
        n3696) );
  sky130_fd_sc_hd__nand2_1 U11322 ( .A(n4180), .B(\cpuregs[5][7] ), .Y(n9644)
         );
  sky130_fd_sc_hd__o21ai_1 U11323 ( .A1(n9661), .A2(n4180), .B1(n9644), .Y(
        n3683) );
  sky130_fd_sc_hd__nand2_1 U11324 ( .A(n10057), .B(\cpuregs[24][7] ), .Y(n9645) );
  sky130_fd_sc_hd__o21ai_1 U11325 ( .A1(n9661), .A2(n10057), .B1(n9645), .Y(
        n3702) );
  sky130_fd_sc_hd__nand2_1 U11326 ( .A(n9772), .B(\cpuregs[6][7] ), .Y(n9646)
         );
  sky130_fd_sc_hd__o21ai_1 U11327 ( .A1(n9661), .A2(n9772), .B1(n9646), .Y(
        n3684) );
  sky130_fd_sc_hd__nand2_1 U11328 ( .A(n4177), .B(\cpuregs[30][7] ), .Y(n9647)
         );
  sky130_fd_sc_hd__o21ai_1 U11329 ( .A1(n9661), .A2(n4177), .B1(n9647), .Y(
        n3708) );
  sky130_fd_sc_hd__nand2_1 U11330 ( .A(n4201), .B(\cpuregs[3][7] ), .Y(n9648)
         );
  sky130_fd_sc_hd__o21ai_1 U11331 ( .A1(n9661), .A2(n4201), .B1(n9648), .Y(
        n3681) );
  sky130_fd_sc_hd__nand2_1 U11332 ( .A(n6897), .B(\cpuregs[14][7] ), .Y(n9649)
         );
  sky130_fd_sc_hd__o21ai_1 U11333 ( .A1(n9661), .A2(n6897), .B1(n9649), .Y(
        n3692) );
  sky130_fd_sc_hd__nand2_1 U11334 ( .A(n4175), .B(\cpuregs[27][7] ), .Y(n9650)
         );
  sky130_fd_sc_hd__o21ai_1 U11335 ( .A1(n9661), .A2(n4175), .B1(n9650), .Y(
        n3705) );
  sky130_fd_sc_hd__nand2_1 U11336 ( .A(n7069), .B(\cpuregs[15][7] ), .Y(n9651)
         );
  sky130_fd_sc_hd__o21ai_1 U11337 ( .A1(n9661), .A2(n7069), .B1(n9651), .Y(
        n3693) );
  sky130_fd_sc_hd__nand2_1 U11338 ( .A(n4194), .B(\cpuregs[19][7] ), .Y(n9652)
         );
  sky130_fd_sc_hd__o21ai_1 U11339 ( .A1(n9661), .A2(n4194), .B1(n9652), .Y(
        n3697) );
  sky130_fd_sc_hd__nand2_1 U11340 ( .A(n7452), .B(\cpuregs[9][7] ), .Y(n9653)
         );
  sky130_fd_sc_hd__o21ai_1 U11341 ( .A1(n9661), .A2(n7452), .B1(n9653), .Y(
        n3687) );
  sky130_fd_sc_hd__nand2_1 U11342 ( .A(n4199), .B(\cpuregs[7][7] ), .Y(n9654)
         );
  sky130_fd_sc_hd__o21ai_1 U11343 ( .A1(n9661), .A2(n4199), .B1(n9654), .Y(
        n3685) );
  sky130_fd_sc_hd__nand2_1 U11344 ( .A(n4183), .B(\cpuregs[8][7] ), .Y(n9655)
         );
  sky130_fd_sc_hd__o21ai_1 U11345 ( .A1(n9661), .A2(n4183), .B1(n9655), .Y(
        n3686) );
  sky130_fd_sc_hd__nand2_1 U11346 ( .A(n4186), .B(\cpuregs[13][7] ), .Y(n9656)
         );
  sky130_fd_sc_hd__o21ai_1 U11347 ( .A1(n9661), .A2(n4186), .B1(n9656), .Y(
        n3691) );
  sky130_fd_sc_hd__nand2_1 U11348 ( .A(n4174), .B(\cpuregs[21][7] ), .Y(n9657)
         );
  sky130_fd_sc_hd__o21ai_1 U11349 ( .A1(n9661), .A2(n4174), .B1(n9657), .Y(
        n3699) );
  sky130_fd_sc_hd__nand2_1 U11350 ( .A(n4178), .B(\cpuregs[2][7] ), .Y(n9658)
         );
  sky130_fd_sc_hd__o21ai_1 U11351 ( .A1(n9661), .A2(n4178), .B1(n9658), .Y(
        n3680) );
  sky130_fd_sc_hd__nand2_1 U11352 ( .A(n7084), .B(\cpuregs[22][7] ), .Y(n9659)
         );
  sky130_fd_sc_hd__o21ai_1 U11353 ( .A1(n9661), .A2(n7084), .B1(n9659), .Y(
        n3700) );
  sky130_fd_sc_hd__nand2_1 U11354 ( .A(n4185), .B(\cpuregs[11][7] ), .Y(n9660)
         );
  sky130_fd_sc_hd__o21ai_1 U11355 ( .A1(n9661), .A2(n4185), .B1(n9660), .Y(
        n3689) );
  sky130_fd_sc_hd__nor2_1 U11356 ( .A(n9663), .B(n9662), .Y(n9700) );
  sky130_fd_sc_hd__xnor2_1 U11357 ( .A(n9664), .B(n9700), .Y(n9665) );
  sky130_fd_sc_hd__nand2_1 U11358 ( .A(n9665), .B(n9813), .Y(n9667) );
  sky130_fd_sc_hd__a22oi_1 U11359 ( .A1(n9816), .A2(reg_out[8]), .B1(n9815), 
        .B2(alu_out_q[8]), .Y(n9666) );
  sky130_fd_sc_hd__nand2_1 U11360 ( .A(n9621), .B(\cpuregs[26][8] ), .Y(n9668)
         );
  sky130_fd_sc_hd__o21ai_1 U11361 ( .A1(n9621), .A2(n9699), .B1(n9668), .Y(
        n3673) );
  sky130_fd_sc_hd__nand2_1 U11362 ( .A(n7069), .B(\cpuregs[15][8] ), .Y(n9669)
         );
  sky130_fd_sc_hd__o21ai_1 U11363 ( .A1(n7069), .A2(n9699), .B1(n9669), .Y(
        n3662) );
  sky130_fd_sc_hd__nand2_1 U11364 ( .A(n4185), .B(\cpuregs[11][8] ), .Y(n9670)
         );
  sky130_fd_sc_hd__o21ai_1 U11365 ( .A1(n4185), .A2(n9699), .B1(n9670), .Y(
        n3658) );
  sky130_fd_sc_hd__nand2_1 U11366 ( .A(n4194), .B(\cpuregs[19][8] ), .Y(n9671)
         );
  sky130_fd_sc_hd__o21ai_1 U11367 ( .A1(n4194), .A2(n9699), .B1(n9671), .Y(
        n3666) );
  sky130_fd_sc_hd__nand2_1 U11368 ( .A(n10057), .B(\cpuregs[24][8] ), .Y(n9672) );
  sky130_fd_sc_hd__o21ai_1 U11369 ( .A1(n10057), .A2(n9699), .B1(n9672), .Y(
        n3671) );
  sky130_fd_sc_hd__nand2_1 U11370 ( .A(n7452), .B(\cpuregs[9][8] ), .Y(n9673)
         );
  sky130_fd_sc_hd__o21ai_1 U11371 ( .A1(n7452), .A2(n9699), .B1(n9673), .Y(
        n3656) );
  sky130_fd_sc_hd__nand2_1 U11372 ( .A(n4195), .B(\cpuregs[17][8] ), .Y(n9674)
         );
  sky130_fd_sc_hd__o21ai_1 U11373 ( .A1(n4195), .A2(n9699), .B1(n9674), .Y(
        n3664) );
  sky130_fd_sc_hd__nand2_1 U11374 ( .A(n4180), .B(\cpuregs[5][8] ), .Y(n9675)
         );
  sky130_fd_sc_hd__o21ai_1 U11375 ( .A1(n4180), .A2(n9699), .B1(n9675), .Y(
        n3652) );
  sky130_fd_sc_hd__nand2_1 U11376 ( .A(n4183), .B(\cpuregs[8][8] ), .Y(n9676)
         );
  sky130_fd_sc_hd__o21ai_1 U11377 ( .A1(n4183), .A2(n9699), .B1(n9676), .Y(
        n3655) );
  sky130_fd_sc_hd__nand2_1 U11378 ( .A(n4179), .B(\cpuregs[4][8] ), .Y(n9677)
         );
  sky130_fd_sc_hd__o21ai_1 U11379 ( .A1(n4179), .A2(n9699), .B1(n9677), .Y(
        n3651) );
  sky130_fd_sc_hd__nand2_1 U11380 ( .A(n9772), .B(\cpuregs[6][8] ), .Y(n9678)
         );
  sky130_fd_sc_hd__o21ai_1 U11381 ( .A1(n9772), .A2(n9699), .B1(n9678), .Y(
        n3653) );
  sky130_fd_sc_hd__nand2_1 U11382 ( .A(n6396), .B(\cpuregs[1][8] ), .Y(n9679)
         );
  sky130_fd_sc_hd__o21ai_1 U11383 ( .A1(n6396), .A2(n9699), .B1(n9679), .Y(
        n3648) );
  sky130_fd_sc_hd__nand2_1 U11384 ( .A(n4175), .B(\cpuregs[27][8] ), .Y(n9680)
         );
  sky130_fd_sc_hd__o21ai_1 U11385 ( .A1(n4175), .A2(n9699), .B1(n9680), .Y(
        n3674) );
  sky130_fd_sc_hd__nand2_1 U11386 ( .A(n4219), .B(\cpuregs[28][8] ), .Y(n9681)
         );
  sky130_fd_sc_hd__o21ai_1 U11387 ( .A1(n4219), .A2(n9699), .B1(n9681), .Y(
        n3675) );
  sky130_fd_sc_hd__nand2_1 U11388 ( .A(n4174), .B(\cpuregs[21][8] ), .Y(n9682)
         );
  sky130_fd_sc_hd__o21ai_1 U11389 ( .A1(n4174), .A2(n9699), .B1(n9682), .Y(
        n3668) );
  sky130_fd_sc_hd__nand2_1 U11390 ( .A(n4199), .B(\cpuregs[7][8] ), .Y(n9683)
         );
  sky130_fd_sc_hd__o21ai_1 U11391 ( .A1(n4199), .A2(n9699), .B1(n9683), .Y(
        n3654) );
  sky130_fd_sc_hd__nand2_1 U11392 ( .A(n4197), .B(\cpuregs[16][8] ), .Y(n9684)
         );
  sky130_fd_sc_hd__o21ai_1 U11393 ( .A1(n4197), .A2(n9699), .B1(n9684), .Y(
        n3663) );
  sky130_fd_sc_hd__nand2_1 U11394 ( .A(n4173), .B(\cpuregs[23][8] ), .Y(n9685)
         );
  sky130_fd_sc_hd__o21ai_1 U11395 ( .A1(n4173), .A2(n9699), .B1(n9685), .Y(
        n3670) );
  sky130_fd_sc_hd__nand2_1 U11396 ( .A(n6897), .B(\cpuregs[14][8] ), .Y(n9686)
         );
  sky130_fd_sc_hd__o21ai_1 U11397 ( .A1(n6897), .A2(n9699), .B1(n9686), .Y(
        n3661) );
  sky130_fd_sc_hd__nand2_1 U11398 ( .A(n4184), .B(\cpuregs[10][8] ), .Y(n9687)
         );
  sky130_fd_sc_hd__o21ai_1 U11399 ( .A1(n4184), .A2(n9699), .B1(n9687), .Y(
        n3657) );
  sky130_fd_sc_hd__nand2_1 U11400 ( .A(n4192), .B(\cpuregs[25][8] ), .Y(n9688)
         );
  sky130_fd_sc_hd__o21ai_1 U11401 ( .A1(n4192), .A2(n9699), .B1(n9688), .Y(
        n3672) );
  sky130_fd_sc_hd__nand2_1 U11402 ( .A(n4177), .B(\cpuregs[30][8] ), .Y(n9689)
         );
  sky130_fd_sc_hd__o21ai_1 U11403 ( .A1(n4177), .A2(n9699), .B1(n9689), .Y(
        n3677) );
  sky130_fd_sc_hd__nand2_1 U11404 ( .A(n4176), .B(\cpuregs[29][8] ), .Y(n9690)
         );
  sky130_fd_sc_hd__o21ai_1 U11405 ( .A1(n4176), .A2(n9699), .B1(n9690), .Y(
        n3676) );
  sky130_fd_sc_hd__nand2_1 U11406 ( .A(n7247), .B(\cpuregs[31][8] ), .Y(n9691)
         );
  sky130_fd_sc_hd__o21ai_1 U11407 ( .A1(n7247), .A2(n9699), .B1(n9691), .Y(
        n3678) );
  sky130_fd_sc_hd__nand2_1 U11408 ( .A(n4186), .B(\cpuregs[13][8] ), .Y(n9692)
         );
  sky130_fd_sc_hd__o21ai_1 U11409 ( .A1(n4186), .A2(n9699), .B1(n9692), .Y(
        n3660) );
  sky130_fd_sc_hd__nand2_1 U11410 ( .A(n7084), .B(\cpuregs[22][8] ), .Y(n9693)
         );
  sky130_fd_sc_hd__o21ai_1 U11411 ( .A1(n7084), .A2(n9699), .B1(n9693), .Y(
        n3669) );
  sky130_fd_sc_hd__nand2_1 U11412 ( .A(n4178), .B(\cpuregs[2][8] ), .Y(n9694)
         );
  sky130_fd_sc_hd__o21ai_1 U11413 ( .A1(n4178), .A2(n9699), .B1(n9694), .Y(
        n3649) );
  sky130_fd_sc_hd__nand2_1 U11414 ( .A(n4226), .B(\cpuregs[12][8] ), .Y(n9695)
         );
  sky130_fd_sc_hd__o21ai_1 U11415 ( .A1(n4226), .A2(n9699), .B1(n9695), .Y(
        n3659) );
  sky130_fd_sc_hd__nand2_1 U11416 ( .A(n10058), .B(\cpuregs[20][8] ), .Y(n9696) );
  sky130_fd_sc_hd__o21ai_1 U11417 ( .A1(n10058), .A2(n9699), .B1(n9696), .Y(
        n3667) );
  sky130_fd_sc_hd__nand2_1 U11418 ( .A(n4201), .B(\cpuregs[3][8] ), .Y(n9697)
         );
  sky130_fd_sc_hd__o21ai_1 U11419 ( .A1(n4201), .A2(n9699), .B1(n9697), .Y(
        n3650) );
  sky130_fd_sc_hd__nand2_1 U11420 ( .A(n9820), .B(\cpuregs[18][8] ), .Y(n9698)
         );
  sky130_fd_sc_hd__o21ai_1 U11421 ( .A1(n9820), .A2(n9699), .B1(n9698), .Y(
        n3665) );
  sky130_fd_sc_hd__nand2_1 U11422 ( .A(n9700), .B(reg_pc[8]), .Y(n9702) );
  sky130_fd_sc_hd__xor2_1 U11423 ( .A(n9702), .B(n9701), .X(n9703) );
  sky130_fd_sc_hd__a222oi_1 U11424 ( .A1(reg_out[9]), .A2(n9816), .B1(
        alu_out_q[9]), .B2(n9815), .C1(n9703), .C2(n9813), .Y(n9717) );
  sky130_fd_sc_hd__nand2_1 U11425 ( .A(n4175), .B(\cpuregs[27][9] ), .Y(n9704)
         );
  sky130_fd_sc_hd__o21ai_1 U11426 ( .A1(n4175), .A2(n4209), .B1(n9704), .Y(
        n3643) );
  sky130_fd_sc_hd__nand2_1 U11427 ( .A(n10058), .B(\cpuregs[20][9] ), .Y(n9705) );
  sky130_fd_sc_hd__o21ai_1 U11428 ( .A1(n10058), .A2(n4209), .B1(n9705), .Y(
        n3636) );
  sky130_fd_sc_hd__nand2_1 U11429 ( .A(n4174), .B(\cpuregs[21][9] ), .Y(n9706)
         );
  sky130_fd_sc_hd__o21ai_1 U11430 ( .A1(n4174), .A2(n4209), .B1(n9706), .Y(
        n3637) );
  sky130_fd_sc_hd__nand2_1 U11431 ( .A(n4185), .B(\cpuregs[11][9] ), .Y(n9707)
         );
  sky130_fd_sc_hd__o21ai_1 U11432 ( .A1(n4185), .A2(n4209), .B1(n9707), .Y(
        n3627) );
  sky130_fd_sc_hd__nand2_1 U11433 ( .A(n4186), .B(\cpuregs[13][9] ), .Y(n9708)
         );
  sky130_fd_sc_hd__o21ai_1 U11434 ( .A1(n4186), .A2(n4209), .B1(n9708), .Y(
        n3629) );
  sky130_fd_sc_hd__nand2_1 U11435 ( .A(n7069), .B(\cpuregs[15][9] ), .Y(n9709)
         );
  sky130_fd_sc_hd__o21ai_1 U11436 ( .A1(n7069), .A2(n4209), .B1(n9709), .Y(
        n3631) );
  sky130_fd_sc_hd__nand2_1 U11437 ( .A(n4184), .B(\cpuregs[10][9] ), .Y(n9710)
         );
  sky130_fd_sc_hd__o21ai_1 U11438 ( .A1(n4184), .A2(n4209), .B1(n9710), .Y(
        n3626) );
  sky130_fd_sc_hd__nand2_1 U11439 ( .A(n6897), .B(\cpuregs[14][9] ), .Y(n9711)
         );
  sky130_fd_sc_hd__o21ai_1 U11440 ( .A1(n6897), .A2(n4209), .B1(n9711), .Y(
        n3630) );
  sky130_fd_sc_hd__nand2_1 U11441 ( .A(n4180), .B(\cpuregs[5][9] ), .Y(n9712)
         );
  sky130_fd_sc_hd__o21ai_1 U11442 ( .A1(n4180), .A2(n4209), .B1(n9712), .Y(
        n3621) );
  sky130_fd_sc_hd__nand2_1 U11443 ( .A(n4194), .B(\cpuregs[19][9] ), .Y(n9713)
         );
  sky130_fd_sc_hd__o21ai_1 U11444 ( .A1(n4194), .A2(n4209), .B1(n9713), .Y(
        n3635) );
  sky130_fd_sc_hd__nand2_1 U11445 ( .A(n7084), .B(\cpuregs[22][9] ), .Y(n9714)
         );
  sky130_fd_sc_hd__o21ai_1 U11446 ( .A1(n7084), .A2(n4209), .B1(n9714), .Y(
        n3638) );
  sky130_fd_sc_hd__nand2_1 U11447 ( .A(n9621), .B(\cpuregs[26][9] ), .Y(n9715)
         );
  sky130_fd_sc_hd__o21ai_1 U11448 ( .A1(n9621), .A2(n4209), .B1(n9715), .Y(
        n3642) );
  sky130_fd_sc_hd__nand2_1 U11449 ( .A(n4177), .B(\cpuregs[30][9] ), .Y(n9716)
         );
  sky130_fd_sc_hd__o21ai_1 U11450 ( .A1(n4177), .A2(n4209), .B1(n9716), .Y(
        n3646) );
  sky130_fd_sc_hd__nand2_1 U11451 ( .A(n4195), .B(\cpuregs[17][9] ), .Y(n9718)
         );
  sky130_fd_sc_hd__o21ai_1 U11452 ( .A1(n4195), .A2(n4209), .B1(n9718), .Y(
        n3633) );
  sky130_fd_sc_hd__nand2_1 U11453 ( .A(n9820), .B(\cpuregs[18][9] ), .Y(n9719)
         );
  sky130_fd_sc_hd__o21ai_1 U11454 ( .A1(n9820), .A2(n4209), .B1(n9719), .Y(
        n3634) );
  sky130_fd_sc_hd__nand2_1 U11455 ( .A(n4197), .B(\cpuregs[16][9] ), .Y(n9720)
         );
  sky130_fd_sc_hd__o21ai_1 U11456 ( .A1(n4197), .A2(n4209), .B1(n9720), .Y(
        n3632) );
  sky130_fd_sc_hd__nand2_1 U11457 ( .A(n4192), .B(\cpuregs[25][9] ), .Y(n9721)
         );
  sky130_fd_sc_hd__o21ai_1 U11458 ( .A1(n4192), .A2(n4209), .B1(n9721), .Y(
        n3641) );
  sky130_fd_sc_hd__nand2_1 U11459 ( .A(n4201), .B(\cpuregs[3][9] ), .Y(n9722)
         );
  sky130_fd_sc_hd__o21ai_1 U11460 ( .A1(n4201), .A2(n4209), .B1(n9722), .Y(
        n3619) );
  sky130_fd_sc_hd__nand2_1 U11461 ( .A(n10057), .B(\cpuregs[24][9] ), .Y(n9723) );
  sky130_fd_sc_hd__o21ai_1 U11462 ( .A1(n10057), .A2(n4209), .B1(n9723), .Y(
        n3640) );
  sky130_fd_sc_hd__nand2_1 U11463 ( .A(n4226), .B(\cpuregs[12][9] ), .Y(n9724)
         );
  sky130_fd_sc_hd__o21ai_1 U11464 ( .A1(n4226), .A2(n4209), .B1(n9724), .Y(
        n3628) );
  sky130_fd_sc_hd__nand2_1 U11465 ( .A(n9209), .B(\cpuregs[6][9] ), .Y(n9725)
         );
  sky130_fd_sc_hd__o21ai_1 U11466 ( .A1(n9772), .A2(n4209), .B1(n9725), .Y(
        n3622) );
  sky130_fd_sc_hd__nand2_1 U11467 ( .A(n4176), .B(\cpuregs[29][9] ), .Y(n9726)
         );
  sky130_fd_sc_hd__o21ai_1 U11468 ( .A1(n4176), .A2(n4209), .B1(n9726), .Y(
        n3645) );
  sky130_fd_sc_hd__nand2_1 U11469 ( .A(n7247), .B(\cpuregs[31][9] ), .Y(n9727)
         );
  sky130_fd_sc_hd__o21ai_1 U11470 ( .A1(n7247), .A2(n4209), .B1(n9727), .Y(
        n3647) );
  sky130_fd_sc_hd__nand2_1 U11471 ( .A(n6396), .B(\cpuregs[1][9] ), .Y(n9728)
         );
  sky130_fd_sc_hd__o21ai_1 U11472 ( .A1(n6396), .A2(n4209), .B1(n9728), .Y(
        n3617) );
  sky130_fd_sc_hd__nand2_1 U11473 ( .A(n4199), .B(\cpuregs[7][9] ), .Y(n9729)
         );
  sky130_fd_sc_hd__o21ai_1 U11474 ( .A1(n4199), .A2(n4209), .B1(n9729), .Y(
        n3623) );
  sky130_fd_sc_hd__nand2_1 U11475 ( .A(n4219), .B(\cpuregs[28][9] ), .Y(n9730)
         );
  sky130_fd_sc_hd__o21ai_1 U11476 ( .A1(n4219), .A2(n4209), .B1(n9730), .Y(
        n3644) );
  sky130_fd_sc_hd__nand2_1 U11477 ( .A(n4179), .B(\cpuregs[4][9] ), .Y(n9731)
         );
  sky130_fd_sc_hd__o21ai_1 U11478 ( .A1(n4179), .A2(n4209), .B1(n9731), .Y(
        n3620) );
  sky130_fd_sc_hd__nand2_1 U11479 ( .A(n4178), .B(\cpuregs[2][9] ), .Y(n9732)
         );
  sky130_fd_sc_hd__o21ai_1 U11480 ( .A1(n4178), .A2(n4209), .B1(n9732), .Y(
        n3618) );
  sky130_fd_sc_hd__nand2_1 U11481 ( .A(n4173), .B(\cpuregs[23][9] ), .Y(n9733)
         );
  sky130_fd_sc_hd__o21ai_1 U11482 ( .A1(n4173), .A2(n4209), .B1(n9733), .Y(
        n3639) );
  sky130_fd_sc_hd__nand2_1 U11483 ( .A(n4183), .B(\cpuregs[8][9] ), .Y(n9734)
         );
  sky130_fd_sc_hd__o21ai_1 U11484 ( .A1(n4183), .A2(n4209), .B1(n9734), .Y(
        n3624) );
  sky130_fd_sc_hd__nand2_1 U11485 ( .A(n7452), .B(\cpuregs[9][9] ), .Y(n9735)
         );
  sky130_fd_sc_hd__o21ai_1 U11486 ( .A1(n7452), .A2(n4209), .B1(n9735), .Y(
        n3625) );
  sky130_fd_sc_hd__xnor2_1 U11487 ( .A(n9737), .B(n9736), .Y(n9738) );
  sky130_fd_sc_hd__nand2_1 U11488 ( .A(n9738), .B(n9813), .Y(n9740) );
  sky130_fd_sc_hd__a22oi_1 U11489 ( .A1(n9816), .A2(reg_out[10]), .B1(n9815), 
        .B2(alu_out_q[10]), .Y(n9739) );
  sky130_fd_sc_hd__nand2_1 U11490 ( .A(n10057), .B(\cpuregs[24][10] ), .Y(
        n9741) );
  sky130_fd_sc_hd__o21ai_1 U11491 ( .A1(n9773), .A2(n10057), .B1(n9741), .Y(
        n3609) );
  sky130_fd_sc_hd__nand2_1 U11492 ( .A(n4177), .B(\cpuregs[30][10] ), .Y(n9742) );
  sky130_fd_sc_hd__o21ai_1 U11493 ( .A1(n9773), .A2(n4177), .B1(n9742), .Y(
        n3615) );
  sky130_fd_sc_hd__nand2_1 U11494 ( .A(n7452), .B(\cpuregs[9][10] ), .Y(n9743)
         );
  sky130_fd_sc_hd__o21ai_1 U11495 ( .A1(n9773), .A2(n7452), .B1(n9743), .Y(
        n3594) );
  sky130_fd_sc_hd__nand2_1 U11496 ( .A(n4173), .B(\cpuregs[23][10] ), .Y(n9744) );
  sky130_fd_sc_hd__o21ai_1 U11497 ( .A1(n9773), .A2(n4173), .B1(n9744), .Y(
        n3608) );
  sky130_fd_sc_hd__nand2_1 U11498 ( .A(n7069), .B(\cpuregs[15][10] ), .Y(n9745) );
  sky130_fd_sc_hd__o21ai_1 U11499 ( .A1(n9773), .A2(n7069), .B1(n9745), .Y(
        n3600) );
  sky130_fd_sc_hd__nand2_1 U11500 ( .A(n4219), .B(\cpuregs[28][10] ), .Y(n9746) );
  sky130_fd_sc_hd__o21ai_1 U11501 ( .A1(n9773), .A2(n4219), .B1(n9746), .Y(
        n3613) );
  sky130_fd_sc_hd__nand2_1 U11502 ( .A(n4199), .B(\cpuregs[7][10] ), .Y(n9747)
         );
  sky130_fd_sc_hd__o21ai_1 U11503 ( .A1(n9773), .A2(n4199), .B1(n9747), .Y(
        n3592) );
  sky130_fd_sc_hd__nand2_1 U11504 ( .A(n4226), .B(\cpuregs[12][10] ), .Y(n9748) );
  sky130_fd_sc_hd__o21ai_1 U11505 ( .A1(n9773), .A2(n4226), .B1(n9748), .Y(
        n3597) );
  sky130_fd_sc_hd__nand2_1 U11506 ( .A(n4184), .B(\cpuregs[10][10] ), .Y(n9749) );
  sky130_fd_sc_hd__o21ai_1 U11507 ( .A1(n9773), .A2(n4184), .B1(n9749), .Y(
        n3595) );
  sky130_fd_sc_hd__nand2_1 U11508 ( .A(n9820), .B(\cpuregs[18][10] ), .Y(n9750) );
  sky130_fd_sc_hd__o21ai_1 U11509 ( .A1(n9773), .A2(n9820), .B1(n9750), .Y(
        n3603) );
  sky130_fd_sc_hd__nand2_1 U11510 ( .A(n6897), .B(\cpuregs[14][10] ), .Y(n9751) );
  sky130_fd_sc_hd__o21ai_1 U11511 ( .A1(n9773), .A2(n6897), .B1(n9751), .Y(
        n3599) );
  sky130_fd_sc_hd__nand2_1 U11512 ( .A(n4174), .B(\cpuregs[21][10] ), .Y(n9752) );
  sky130_fd_sc_hd__o21ai_1 U11513 ( .A1(n9773), .A2(n4174), .B1(n9752), .Y(
        n3606) );
  sky130_fd_sc_hd__nand2_1 U11514 ( .A(n4192), .B(\cpuregs[25][10] ), .Y(n9753) );
  sky130_fd_sc_hd__o21ai_1 U11515 ( .A1(n9773), .A2(n4192), .B1(n9753), .Y(
        n3610) );
  sky130_fd_sc_hd__nand2_1 U11516 ( .A(n4178), .B(\cpuregs[2][10] ), .Y(n9754)
         );
  sky130_fd_sc_hd__o21ai_1 U11517 ( .A1(n9773), .A2(n4178), .B1(n9754), .Y(
        n3587) );
  sky130_fd_sc_hd__nand2_1 U11518 ( .A(n7247), .B(\cpuregs[31][10] ), .Y(n9755) );
  sky130_fd_sc_hd__o21ai_1 U11519 ( .A1(n9773), .A2(n7247), .B1(n9755), .Y(
        n3616) );
  sky130_fd_sc_hd__nand2_1 U11520 ( .A(n4180), .B(\cpuregs[5][10] ), .Y(n9756)
         );
  sky130_fd_sc_hd__o21ai_1 U11521 ( .A1(n9773), .A2(n4180), .B1(n9756), .Y(
        n3590) );
  sky130_fd_sc_hd__nand2_1 U11522 ( .A(n4183), .B(\cpuregs[8][10] ), .Y(n9757)
         );
  sky130_fd_sc_hd__o21ai_1 U11523 ( .A1(n9773), .A2(n4183), .B1(n9757), .Y(
        n3593) );
  sky130_fd_sc_hd__nand2_1 U11524 ( .A(n7084), .B(\cpuregs[22][10] ), .Y(n9758) );
  sky130_fd_sc_hd__o21ai_1 U11525 ( .A1(n9773), .A2(n7084), .B1(n9758), .Y(
        n3607) );
  sky130_fd_sc_hd__nand2_1 U11526 ( .A(n4175), .B(\cpuregs[27][10] ), .Y(n9759) );
  sky130_fd_sc_hd__o21ai_1 U11527 ( .A1(n9773), .A2(n4175), .B1(n9759), .Y(
        n3612) );
  sky130_fd_sc_hd__nand2_1 U11528 ( .A(n4195), .B(\cpuregs[17][10] ), .Y(n9760) );
  sky130_fd_sc_hd__o21ai_1 U11529 ( .A1(n9773), .A2(n4195), .B1(n9760), .Y(
        n3602) );
  sky130_fd_sc_hd__nand2_1 U11530 ( .A(n4179), .B(\cpuregs[4][10] ), .Y(n9761)
         );
  sky130_fd_sc_hd__o21ai_1 U11531 ( .A1(n9773), .A2(n4179), .B1(n9761), .Y(
        n3589) );
  sky130_fd_sc_hd__nand2_1 U11532 ( .A(n4201), .B(\cpuregs[3][10] ), .Y(n9762)
         );
  sky130_fd_sc_hd__o21ai_1 U11533 ( .A1(n9773), .A2(n4201), .B1(n9762), .Y(
        n3588) );
  sky130_fd_sc_hd__nand2_1 U11534 ( .A(n4186), .B(\cpuregs[13][10] ), .Y(n9763) );
  sky130_fd_sc_hd__o21ai_1 U11535 ( .A1(n9773), .A2(n4186), .B1(n9763), .Y(
        n3598) );
  sky130_fd_sc_hd__nand2_1 U11536 ( .A(n4197), .B(\cpuregs[16][10] ), .Y(n9764) );
  sky130_fd_sc_hd__o21ai_1 U11537 ( .A1(n9773), .A2(n4197), .B1(n9764), .Y(
        n3601) );
  sky130_fd_sc_hd__nand2_1 U11538 ( .A(n6396), .B(\cpuregs[1][10] ), .Y(n9765)
         );
  sky130_fd_sc_hd__o21ai_1 U11539 ( .A1(n9773), .A2(n6396), .B1(n9765), .Y(
        n3586) );
  sky130_fd_sc_hd__nand2_1 U11540 ( .A(n4194), .B(\cpuregs[19][10] ), .Y(n9766) );
  sky130_fd_sc_hd__o21ai_1 U11541 ( .A1(n9773), .A2(n4194), .B1(n9766), .Y(
        n3604) );
  sky130_fd_sc_hd__nand2_1 U11542 ( .A(n4176), .B(\cpuregs[29][10] ), .Y(n9767) );
  sky130_fd_sc_hd__o21ai_1 U11543 ( .A1(n9773), .A2(n4176), .B1(n9767), .Y(
        n3614) );
  sky130_fd_sc_hd__nand2_1 U11544 ( .A(n4185), .B(\cpuregs[11][10] ), .Y(n9768) );
  sky130_fd_sc_hd__o21ai_1 U11545 ( .A1(n9773), .A2(n4185), .B1(n9768), .Y(
        n3596) );
  sky130_fd_sc_hd__nand2_1 U11546 ( .A(n10058), .B(\cpuregs[20][10] ), .Y(
        n9769) );
  sky130_fd_sc_hd__o21ai_1 U11547 ( .A1(n9773), .A2(n10058), .B1(n9769), .Y(
        n3605) );
  sky130_fd_sc_hd__nand2_1 U11548 ( .A(n9621), .B(\cpuregs[26][10] ), .Y(n9770) );
  sky130_fd_sc_hd__o21ai_1 U11549 ( .A1(n9773), .A2(n9621), .B1(n9770), .Y(
        n3611) );
  sky130_fd_sc_hd__nand2_1 U11550 ( .A(n9209), .B(\cpuregs[6][10] ), .Y(n9771)
         );
  sky130_fd_sc_hd__o21ai_1 U11551 ( .A1(n9773), .A2(n9772), .B1(n9771), .Y(
        n3591) );
  sky130_fd_sc_hd__nor2_1 U11552 ( .A(n9775), .B(n9774), .Y(n9810) );
  sky130_fd_sc_hd__xnor2_1 U11553 ( .A(n9776), .B(n9810), .Y(n9777) );
  sky130_fd_sc_hd__a222oi_1 U11554 ( .A1(reg_out[26]), .A2(n9816), .B1(
        alu_out_q[26]), .B2(n9815), .C1(n9777), .C2(n9813), .Y(n9791) );
  sky130_fd_sc_hd__nand2_1 U11555 ( .A(n4186), .B(\cpuregs[13][26] ), .Y(n9778) );
  sky130_fd_sc_hd__o21ai_1 U11556 ( .A1(n4186), .A2(n4204), .B1(n9778), .Y(
        n3102) );
  sky130_fd_sc_hd__nand2_1 U11557 ( .A(n4192), .B(\cpuregs[25][26] ), .Y(n9779) );
  sky130_fd_sc_hd__o21ai_1 U11558 ( .A1(n4192), .A2(n4204), .B1(n9779), .Y(
        n3114) );
  sky130_fd_sc_hd__nand2_1 U11559 ( .A(n4173), .B(\cpuregs[23][26] ), .Y(n9780) );
  sky130_fd_sc_hd__o21ai_1 U11560 ( .A1(n4173), .A2(n4204), .B1(n9780), .Y(
        n3112) );
  sky130_fd_sc_hd__nand2_1 U11561 ( .A(n10057), .B(\cpuregs[24][26] ), .Y(
        n9781) );
  sky130_fd_sc_hd__o21ai_1 U11562 ( .A1(n10057), .A2(n4204), .B1(n9781), .Y(
        n3113) );
  sky130_fd_sc_hd__nand2_1 U11563 ( .A(n7452), .B(\cpuregs[9][26] ), .Y(n9782)
         );
  sky130_fd_sc_hd__o21ai_1 U11564 ( .A1(n7452), .A2(n4204), .B1(n9782), .Y(
        n3098) );
  sky130_fd_sc_hd__nand2_1 U11565 ( .A(n4175), .B(\cpuregs[27][26] ), .Y(n9783) );
  sky130_fd_sc_hd__o21ai_1 U11566 ( .A1(n4175), .A2(n4204), .B1(n9783), .Y(
        n3116) );
  sky130_fd_sc_hd__nand2_1 U11567 ( .A(n4179), .B(\cpuregs[4][26] ), .Y(n9784)
         );
  sky130_fd_sc_hd__o21ai_1 U11568 ( .A1(n4179), .A2(n4204), .B1(n9784), .Y(
        n3093) );
  sky130_fd_sc_hd__nand2_1 U11569 ( .A(n6396), .B(\cpuregs[1][26] ), .Y(n9785)
         );
  sky130_fd_sc_hd__o21ai_1 U11570 ( .A1(n6396), .A2(n4204), .B1(n9785), .Y(
        n3090) );
  sky130_fd_sc_hd__nand2_1 U11571 ( .A(n4183), .B(\cpuregs[8][26] ), .Y(n9786)
         );
  sky130_fd_sc_hd__o21ai_1 U11572 ( .A1(n4183), .A2(n4204), .B1(n9786), .Y(
        n3097) );
  sky130_fd_sc_hd__nand2_1 U11573 ( .A(n7084), .B(\cpuregs[22][26] ), .Y(n9787) );
  sky130_fd_sc_hd__o21ai_1 U11574 ( .A1(n7084), .A2(n4204), .B1(n9787), .Y(
        n3111) );
  sky130_fd_sc_hd__nand2_1 U11575 ( .A(n9621), .B(\cpuregs[26][26] ), .Y(n9788) );
  sky130_fd_sc_hd__o21ai_1 U11576 ( .A1(n9621), .A2(n4204), .B1(n9788), .Y(
        n3115) );
  sky130_fd_sc_hd__nand2_1 U11577 ( .A(n6897), .B(\cpuregs[14][26] ), .Y(n9789) );
  sky130_fd_sc_hd__o21ai_1 U11578 ( .A1(n6897), .A2(n4204), .B1(n9789), .Y(
        n3103) );
  sky130_fd_sc_hd__nand2_1 U11579 ( .A(n4195), .B(\cpuregs[17][26] ), .Y(n9790) );
  sky130_fd_sc_hd__o21ai_1 U11580 ( .A1(n4195), .A2(n4204), .B1(n9790), .Y(
        n3106) );
  sky130_fd_sc_hd__nand2_1 U11581 ( .A(n4184), .B(\cpuregs[10][26] ), .Y(n9792) );
  sky130_fd_sc_hd__o21ai_1 U11582 ( .A1(n4184), .A2(n4204), .B1(n9792), .Y(
        n3099) );
  sky130_fd_sc_hd__nand2_1 U11583 ( .A(n7069), .B(\cpuregs[15][26] ), .Y(n9793) );
  sky130_fd_sc_hd__o21ai_1 U11584 ( .A1(n7069), .A2(n4204), .B1(n9793), .Y(
        n3104) );
  sky130_fd_sc_hd__nand2_1 U11585 ( .A(n9772), .B(\cpuregs[6][26] ), .Y(n9794)
         );
  sky130_fd_sc_hd__o21ai_1 U11586 ( .A1(n9772), .A2(n4204), .B1(n9794), .Y(
        n3095) );
  sky130_fd_sc_hd__nand2_1 U11587 ( .A(n4219), .B(\cpuregs[28][26] ), .Y(n9795) );
  sky130_fd_sc_hd__o21ai_1 U11588 ( .A1(n4219), .A2(n4204), .B1(n9795), .Y(
        n3117) );
  sky130_fd_sc_hd__nand2_1 U11589 ( .A(n4226), .B(\cpuregs[12][26] ), .Y(n9796) );
  sky130_fd_sc_hd__o21ai_1 U11590 ( .A1(n4226), .A2(n4204), .B1(n9796), .Y(
        n3101) );
  sky130_fd_sc_hd__nand2_1 U11591 ( .A(n4197), .B(\cpuregs[16][26] ), .Y(n9797) );
  sky130_fd_sc_hd__o21ai_1 U11592 ( .A1(n4197), .A2(n4204), .B1(n9797), .Y(
        n3105) );
  sky130_fd_sc_hd__nand2_1 U11593 ( .A(n4178), .B(\cpuregs[2][26] ), .Y(n9798)
         );
  sky130_fd_sc_hd__o21ai_1 U11594 ( .A1(n4178), .A2(n4204), .B1(n9798), .Y(
        n3091) );
  sky130_fd_sc_hd__nand2_1 U11595 ( .A(n4199), .B(\cpuregs[7][26] ), .Y(n9799)
         );
  sky130_fd_sc_hd__o21ai_1 U11596 ( .A1(n4199), .A2(n4204), .B1(n9799), .Y(
        n3096) );
  sky130_fd_sc_hd__nand2_1 U11597 ( .A(n4201), .B(\cpuregs[3][26] ), .Y(n9800)
         );
  sky130_fd_sc_hd__o21ai_1 U11598 ( .A1(n4201), .A2(n4204), .B1(n9800), .Y(
        n3092) );
  sky130_fd_sc_hd__nand2_1 U11599 ( .A(n4174), .B(\cpuregs[21][26] ), .Y(n9801) );
  sky130_fd_sc_hd__o21ai_1 U11600 ( .A1(n4174), .A2(n4204), .B1(n9801), .Y(
        n3110) );
  sky130_fd_sc_hd__nand2_1 U11601 ( .A(n4194), .B(\cpuregs[19][26] ), .Y(n9802) );
  sky130_fd_sc_hd__o21ai_1 U11602 ( .A1(n4194), .A2(n4204), .B1(n9802), .Y(
        n3108) );
  sky130_fd_sc_hd__nand2_1 U11603 ( .A(n4177), .B(\cpuregs[30][26] ), .Y(n9803) );
  sky130_fd_sc_hd__o21ai_1 U11604 ( .A1(n4177), .A2(n4204), .B1(n9803), .Y(
        n3119) );
  sky130_fd_sc_hd__nand2_1 U11605 ( .A(n10058), .B(\cpuregs[20][26] ), .Y(
        n9804) );
  sky130_fd_sc_hd__o21ai_1 U11606 ( .A1(n10058), .A2(n4204), .B1(n9804), .Y(
        n3109) );
  sky130_fd_sc_hd__nand2_1 U11607 ( .A(n7247), .B(\cpuregs[31][26] ), .Y(n9805) );
  sky130_fd_sc_hd__o21ai_1 U11608 ( .A1(n7247), .A2(n4204), .B1(n9805), .Y(
        n3120) );
  sky130_fd_sc_hd__nand2_1 U11609 ( .A(n4180), .B(\cpuregs[5][26] ), .Y(n9806)
         );
  sky130_fd_sc_hd__o21ai_1 U11610 ( .A1(n4180), .A2(n4204), .B1(n9806), .Y(
        n3094) );
  sky130_fd_sc_hd__nand2_1 U11611 ( .A(n4185), .B(\cpuregs[11][26] ), .Y(n9807) );
  sky130_fd_sc_hd__o21ai_1 U11612 ( .A1(n4185), .A2(n4204), .B1(n9807), .Y(
        n3100) );
  sky130_fd_sc_hd__nand2_1 U11613 ( .A(n9820), .B(\cpuregs[18][26] ), .Y(n9808) );
  sky130_fd_sc_hd__o21ai_1 U11614 ( .A1(n9820), .A2(n4204), .B1(n9808), .Y(
        n3107) );
  sky130_fd_sc_hd__nand2_1 U11615 ( .A(n4176), .B(\cpuregs[29][26] ), .Y(n9809) );
  sky130_fd_sc_hd__o21ai_1 U11616 ( .A1(n4176), .A2(n4204), .B1(n9809), .Y(
        n3118) );
  sky130_fd_sc_hd__nand2_1 U11617 ( .A(n9810), .B(reg_pc[26]), .Y(n9812) );
  sky130_fd_sc_hd__xor2_1 U11618 ( .A(n9812), .B(n9811), .X(n9814) );
  sky130_fd_sc_hd__a222oi_1 U11619 ( .A1(reg_out[27]), .A2(n9816), .B1(
        alu_out_q[27]), .B2(n9815), .C1(n9814), .C2(n9813), .Y(n9831) );
  sky130_fd_sc_hd__nand2_1 U11620 ( .A(n4183), .B(\cpuregs[8][27] ), .Y(n9817)
         );
  sky130_fd_sc_hd__o21ai_1 U11621 ( .A1(n4183), .A2(n4198), .B1(n9817), .Y(
        n3066) );
  sky130_fd_sc_hd__nand2_1 U11622 ( .A(n7084), .B(\cpuregs[22][27] ), .Y(n9818) );
  sky130_fd_sc_hd__o21ai_1 U11623 ( .A1(n7084), .A2(n4198), .B1(n9818), .Y(
        n3080) );
  sky130_fd_sc_hd__nand2_1 U11624 ( .A(n4195), .B(\cpuregs[17][27] ), .Y(n9819) );
  sky130_fd_sc_hd__o21ai_1 U11625 ( .A1(n4195), .A2(n4198), .B1(n9819), .Y(
        n3075) );
  sky130_fd_sc_hd__nand2_1 U11626 ( .A(n9820), .B(\cpuregs[18][27] ), .Y(n9821) );
  sky130_fd_sc_hd__o21ai_1 U11627 ( .A1(n9820), .A2(n4198), .B1(n9821), .Y(
        n3076) );
  sky130_fd_sc_hd__nand2_1 U11628 ( .A(n4201), .B(\cpuregs[3][27] ), .Y(n9822)
         );
  sky130_fd_sc_hd__o21ai_1 U11629 ( .A1(n4201), .A2(n4198), .B1(n9822), .Y(
        n3061) );
  sky130_fd_sc_hd__nand2_1 U11630 ( .A(n10058), .B(\cpuregs[20][27] ), .Y(
        n9823) );
  sky130_fd_sc_hd__o21ai_1 U11631 ( .A1(n10058), .A2(n4198), .B1(n9823), .Y(
        n3078) );
  sky130_fd_sc_hd__nand2_1 U11632 ( .A(n4173), .B(\cpuregs[23][27] ), .Y(n9824) );
  sky130_fd_sc_hd__o21ai_1 U11633 ( .A1(n4173), .A2(n4198), .B1(n9824), .Y(
        n3081) );
  sky130_fd_sc_hd__nand2_1 U11634 ( .A(n4194), .B(\cpuregs[19][27] ), .Y(n9825) );
  sky130_fd_sc_hd__o21ai_1 U11635 ( .A1(n4194), .A2(n4198), .B1(n9825), .Y(
        n3077) );
  sky130_fd_sc_hd__nand2_1 U11636 ( .A(n7247), .B(\cpuregs[31][27] ), .Y(n9826) );
  sky130_fd_sc_hd__o21ai_1 U11637 ( .A1(n7247), .A2(n4198), .B1(n9826), .Y(
        n3089) );
  sky130_fd_sc_hd__nand2_1 U11638 ( .A(n4178), .B(\cpuregs[2][27] ), .Y(n9827)
         );
  sky130_fd_sc_hd__o21ai_1 U11639 ( .A1(n4178), .A2(n4198), .B1(n9827), .Y(
        n3060) );
  sky130_fd_sc_hd__nand2_1 U11640 ( .A(n4192), .B(\cpuregs[25][27] ), .Y(n9828) );
  sky130_fd_sc_hd__o21ai_1 U11641 ( .A1(n4192), .A2(n4198), .B1(n9828), .Y(
        n3083) );
  sky130_fd_sc_hd__nand2_1 U11642 ( .A(n4179), .B(\cpuregs[4][27] ), .Y(n9829)
         );
  sky130_fd_sc_hd__o21ai_1 U11643 ( .A1(n4179), .A2(n4198), .B1(n9829), .Y(
        n3062) );
  sky130_fd_sc_hd__nand2_1 U11644 ( .A(n4180), .B(\cpuregs[5][27] ), .Y(n9830)
         );
  sky130_fd_sc_hd__o21ai_1 U11645 ( .A1(n4180), .A2(n4198), .B1(n9830), .Y(
        n3063) );
  sky130_fd_sc_hd__nand2_1 U11646 ( .A(n6897), .B(\cpuregs[14][27] ), .Y(n9832) );
  sky130_fd_sc_hd__o21ai_1 U11647 ( .A1(n6897), .A2(n4198), .B1(n9832), .Y(
        n3072) );
  sky130_fd_sc_hd__nand2_1 U11648 ( .A(n7069), .B(\cpuregs[15][27] ), .Y(n9833) );
  sky130_fd_sc_hd__o21ai_1 U11649 ( .A1(n7069), .A2(n4198), .B1(n9833), .Y(
        n3073) );
  sky130_fd_sc_hd__nand2_1 U11650 ( .A(n4199), .B(\cpuregs[7][27] ), .Y(n9834)
         );
  sky130_fd_sc_hd__o21ai_1 U11651 ( .A1(n4199), .A2(n4198), .B1(n9834), .Y(
        n3065) );
  sky130_fd_sc_hd__nand2_1 U11652 ( .A(n4174), .B(\cpuregs[21][27] ), .Y(n9835) );
  sky130_fd_sc_hd__o21ai_1 U11653 ( .A1(n4174), .A2(n4198), .B1(n9835), .Y(
        n3079) );
  sky130_fd_sc_hd__nand2_1 U11654 ( .A(n7452), .B(\cpuregs[9][27] ), .Y(n9836)
         );
  sky130_fd_sc_hd__o21ai_1 U11655 ( .A1(n7452), .A2(n4198), .B1(n9836), .Y(
        n3067) );
  sky130_fd_sc_hd__nand2_1 U11656 ( .A(n4184), .B(\cpuregs[10][27] ), .Y(n9837) );
  sky130_fd_sc_hd__o21ai_1 U11657 ( .A1(n4184), .A2(n4198), .B1(n9837), .Y(
        n3068) );
  sky130_fd_sc_hd__nand2_1 U11658 ( .A(n4226), .B(\cpuregs[12][27] ), .Y(n9838) );
  sky130_fd_sc_hd__o21ai_1 U11659 ( .A1(n4226), .A2(n4198), .B1(n9838), .Y(
        n3070) );
  sky130_fd_sc_hd__nand2_1 U11660 ( .A(n4177), .B(\cpuregs[30][27] ), .Y(n9839) );
  sky130_fd_sc_hd__o21ai_1 U11661 ( .A1(n4177), .A2(n4198), .B1(n9839), .Y(
        n3088) );
  sky130_fd_sc_hd__nand2_1 U11662 ( .A(n6396), .B(\cpuregs[1][27] ), .Y(n9840)
         );
  sky130_fd_sc_hd__o21ai_1 U11663 ( .A1(n6396), .A2(n4198), .B1(n9840), .Y(
        n3059) );
  sky130_fd_sc_hd__nand2_1 U11664 ( .A(n4185), .B(\cpuregs[11][27] ), .Y(n9841) );
  sky130_fd_sc_hd__o21ai_1 U11665 ( .A1(n4185), .A2(n4198), .B1(n9841), .Y(
        n3069) );
  sky130_fd_sc_hd__nand2_1 U11666 ( .A(n4197), .B(\cpuregs[16][27] ), .Y(n9842) );
  sky130_fd_sc_hd__o21ai_1 U11667 ( .A1(n4197), .A2(n4198), .B1(n9842), .Y(
        n3074) );
  sky130_fd_sc_hd__nand2_1 U11668 ( .A(n9621), .B(\cpuregs[26][27] ), .Y(n9843) );
  sky130_fd_sc_hd__o21ai_1 U11669 ( .A1(n9621), .A2(n4198), .B1(n9843), .Y(
        n3084) );
  sky130_fd_sc_hd__nand2_1 U11670 ( .A(n10057), .B(\cpuregs[24][27] ), .Y(
        n9844) );
  sky130_fd_sc_hd__o21ai_1 U11671 ( .A1(n10057), .A2(n4198), .B1(n9844), .Y(
        n3082) );
  sky130_fd_sc_hd__nand2_1 U11672 ( .A(n4175), .B(\cpuregs[27][27] ), .Y(n9845) );
  sky130_fd_sc_hd__o21ai_1 U11673 ( .A1(n4175), .A2(n4198), .B1(n9845), .Y(
        n3085) );
  sky130_fd_sc_hd__nand2_1 U11674 ( .A(n6541), .B(\cpuregs[6][27] ), .Y(n9846)
         );
  sky130_fd_sc_hd__o21ai_1 U11675 ( .A1(n6541), .A2(n4198), .B1(n9846), .Y(
        n3064) );
  sky130_fd_sc_hd__nand2_1 U11676 ( .A(n4176), .B(\cpuregs[29][27] ), .Y(n9847) );
  sky130_fd_sc_hd__o21ai_1 U11677 ( .A1(n4176), .A2(n4198), .B1(n9847), .Y(
        n3087) );
  sky130_fd_sc_hd__nand2_1 U11678 ( .A(n4186), .B(\cpuregs[13][27] ), .Y(n9848) );
  sky130_fd_sc_hd__o21ai_1 U11679 ( .A1(n4186), .A2(n4198), .B1(n9848), .Y(
        n3071) );
  sky130_fd_sc_hd__nand2_1 U11680 ( .A(n4219), .B(\cpuregs[28][27] ), .Y(n9849) );
  sky130_fd_sc_hd__o21ai_1 U11681 ( .A1(n4219), .A2(n4198), .B1(n9849), .Y(
        n3086) );
  sky130_fd_sc_hd__clkinv_1 U11682 ( .A(mem_rdata[0]), .Y(n9855) );
  sky130_fd_sc_hd__o22ai_1 U11683 ( .A1(n10020), .A2(n9851), .B1(n10085), .B2(
        n9850), .Y(n9852) );
  sky130_fd_sc_hd__a21oi_1 U11684 ( .A1(mem_rdata[16]), .A2(n9853), .B1(n9852), 
        .Y(n9854) );
  sky130_fd_sc_hd__o21ai_1 U11685 ( .A1(n10017), .A2(n9855), .B1(n9854), .Y(
        n4151) );
  sky130_fd_sc_hd__a22oi_1 U11686 ( .A1(n9857), .A2(count_instr[0]), .B1(n9856), .B2(count_instr[32]), .Y(n9865) );
  sky130_fd_sc_hd__a22oi_1 U11687 ( .A1(n9859), .A2(mem_rdata_word[0]), .B1(
        n9858), .B2(pcpi_rs1[0]), .Y(n9864) );
  sky130_fd_sc_hd__a22oi_1 U11688 ( .A1(n9861), .A2(count_cycle[32]), .B1(
        n9860), .B2(count_cycle[0]), .Y(n9863) );
  sky130_fd_sc_hd__nand2_1 U11689 ( .A(decoded_imm[0]), .B(n4639), .Y(n9862)
         );
  sky130_fd_sc_hd__nand4_1 U11690 ( .A(n9865), .B(n9864), .C(n9863), .D(n9862), 
        .Y(N1877) );
  sky130_fd_sc_hd__nand2_1 U11691 ( .A(n9868), .B(n9867), .Y(n9869) );
  sky130_fd_sc_hd__xnor2_1 U11692 ( .A(n9870), .B(n9869), .Y(n9879) );
  sky130_fd_sc_hd__a21oi_1 U11693 ( .A1(n9873), .A2(n9876), .B1(n9872), .Y(
        n9874) );
  sky130_fd_sc_hd__o22ai_1 U11694 ( .A1(n9877), .A2(n9876), .B1(n9875), .B2(
        n9874), .Y(n9878) );
  sky130_fd_sc_hd__a21oi_1 U11695 ( .A1(n9879), .A2(
        is_lui_auipc_jal_jalr_addi_add_sub), .B1(n9878), .Y(n9880) );
  sky130_fd_sc_hd__o31ai_1 U11696 ( .A1(is_lui_auipc_jal_jalr_addi_add_sub), 
        .A2(n9882), .A3(n9881), .B1(n9880), .Y(alu_out[0]) );
  sky130_fd_sc_hd__nand4_1 U11697 ( .A(n9884), .B(n9883), .C(resetn), .D(
        cpu_state[7]), .Y(n9886) );
  sky130_fd_sc_hd__nor2_1 U11698 ( .A(n9886), .B(n9885), .Y(N2068) );
  sky130_fd_sc_hd__o21a_1 U11699 ( .A1(n9906), .A2(mem_wordsize[1]), .B1(n9887), .X(n9902) );
  sky130_fd_sc_hd__o22ai_1 U11700 ( .A1(n9889), .A2(n10027), .B1(n9888), .B2(
        n9902), .Y(n4141) );
  sky130_fd_sc_hd__o22ai_1 U11701 ( .A1(n9891), .A2(n10027), .B1(n9890), .B2(
        n9902), .Y(n4140) );
  sky130_fd_sc_hd__o22ai_1 U11702 ( .A1(n9893), .A2(n10027), .B1(n9892), .B2(
        n9902), .Y(n4139) );
  sky130_fd_sc_hd__o22ai_1 U11703 ( .A1(n9895), .A2(n10027), .B1(n9894), .B2(
        n9902), .Y(n4138) );
  sky130_fd_sc_hd__o22ai_1 U11704 ( .A1(n9897), .A2(n9902), .B1(n9896), .B2(
        n10027), .Y(n4137) );
  sky130_fd_sc_hd__o22ai_1 U11705 ( .A1(n9899), .A2(n9902), .B1(n9898), .B2(
        n10027), .Y(n4136) );
  sky130_fd_sc_hd__o22ai_1 U11706 ( .A1(n9901), .A2(n10027), .B1(n9900), .B2(
        n9902), .Y(n4135) );
  sky130_fd_sc_hd__o22ai_1 U11707 ( .A1(n9904), .A2(n10027), .B1(n9903), .B2(
        n9902), .Y(n4134) );
  sky130_fd_sc_hd__a21oi_1 U11708 ( .A1(pcpi_rs1[0]), .A2(n9906), .B1(n9905), 
        .Y(n9908) );
  sky130_fd_sc_hd__o21ai_1 U11709 ( .A1(pcpi_rs1[1]), .A2(n9908), .B1(n10027), 
        .Y(n4170) );
  sky130_fd_sc_hd__o21ai_1 U11710 ( .A1(n9908), .A2(n9907), .B1(n10027), .Y(
        n4168) );
  sky130_fd_sc_hd__nand2_1 U11711 ( .A(n9910), .B(n9909), .Y(n10133) );
  sky130_fd_sc_hd__nand2_1 U11712 ( .A(n10133), .B(n4841), .Y(n9939) );
  sky130_fd_sc_hd__and2_1 U11713 ( .A(n10133), .B(n4845), .X(n9941) );
  sky130_fd_sc_hd__a222oi_1 U11714 ( .A1(pcpi_rs1[28]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[28]), .C1(reg_out[28]), .C2(n9941), .Y(n9912) );
  sky130_fd_sc_hd__a222oi_1 U11715 ( .A1(pcpi_rs1[29]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[29]), .C1(reg_out[29]), .C2(n9941), .Y(n9913) );
  sky130_fd_sc_hd__a222oi_1 U11716 ( .A1(pcpi_rs1[30]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[30]), .C1(reg_out[30]), .C2(n9941), .Y(n9914) );
  sky130_fd_sc_hd__a222oi_1 U11717 ( .A1(pcpi_rs1[31]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[31]), .C1(reg_out[31]), .C2(n9941), .Y(n9915) );
  sky130_fd_sc_hd__a22oi_1 U11718 ( .A1(pcpi_rs1[2]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[2]), .Y(n9916) );
  sky130_fd_sc_hd__o21ai_1 U11719 ( .A1(n9917), .A2(n9939), .B1(n9916), .Y(
        mem_la_addr[2]) );
  sky130_fd_sc_hd__a22oi_1 U11720 ( .A1(pcpi_rs1[3]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[3]), .Y(n9918) );
  sky130_fd_sc_hd__o21ai_1 U11721 ( .A1(n9919), .A2(n9939), .B1(n9918), .Y(
        mem_la_addr[3]) );
  sky130_fd_sc_hd__a22oi_1 U11722 ( .A1(pcpi_rs1[4]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[4]), .Y(n9920) );
  sky130_fd_sc_hd__o21ai_1 U11723 ( .A1(n9921), .A2(n9939), .B1(n9920), .Y(
        mem_la_addr[4]) );
  sky130_fd_sc_hd__a22oi_1 U11724 ( .A1(pcpi_rs1[5]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[5]), .Y(n9922) );
  sky130_fd_sc_hd__o21ai_1 U11725 ( .A1(n9923), .A2(n9939), .B1(n9922), .Y(
        mem_la_addr[5]) );
  sky130_fd_sc_hd__a22oi_1 U11726 ( .A1(pcpi_rs1[6]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[6]), .Y(n9924) );
  sky130_fd_sc_hd__o21ai_1 U11727 ( .A1(n9925), .A2(n9939), .B1(n9924), .Y(
        mem_la_addr[6]) );
  sky130_fd_sc_hd__a22oi_1 U11728 ( .A1(pcpi_rs1[7]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[7]), .Y(n9926) );
  sky130_fd_sc_hd__o21ai_1 U11729 ( .A1(n9927), .A2(n9939), .B1(n9926), .Y(
        mem_la_addr[7]) );
  sky130_fd_sc_hd__a22oi_1 U11730 ( .A1(pcpi_rs1[8]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[8]), .Y(n9928) );
  sky130_fd_sc_hd__o21ai_1 U11731 ( .A1(n9929), .A2(n9939), .B1(n9928), .Y(
        mem_la_addr[8]) );
  sky130_fd_sc_hd__a22oi_1 U11732 ( .A1(pcpi_rs1[9]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[9]), .Y(n9930) );
  sky130_fd_sc_hd__o21ai_1 U11733 ( .A1(n9931), .A2(n9939), .B1(n9930), .Y(
        mem_la_addr[9]) );
  sky130_fd_sc_hd__a22oi_1 U11734 ( .A1(pcpi_rs1[10]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[10]), .Y(n9932) );
  sky130_fd_sc_hd__o21ai_1 U11735 ( .A1(n9933), .A2(n9939), .B1(n9932), .Y(
        mem_la_addr[10]) );
  sky130_fd_sc_hd__a22oi_1 U11736 ( .A1(pcpi_rs1[11]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[11]), .Y(n9934) );
  sky130_fd_sc_hd__o21ai_1 U11737 ( .A1(n9935), .A2(n9939), .B1(n9934), .Y(
        mem_la_addr[11]) );
  sky130_fd_sc_hd__a22oi_1 U11738 ( .A1(pcpi_rs1[12]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[12]), .Y(n9936) );
  sky130_fd_sc_hd__o21ai_1 U11739 ( .A1(n9937), .A2(n9939), .B1(n9936), .Y(
        mem_la_addr[12]) );
  sky130_fd_sc_hd__a222oi_1 U11740 ( .A1(pcpi_rs1[13]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[13]), .C1(reg_out[13]), .C2(n9941), .Y(n9988) );
  sky130_fd_sc_hd__a222oi_1 U11741 ( .A1(pcpi_rs1[14]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[14]), .C1(reg_out[14]), .C2(n9941), .Y(n9990) );
  sky130_fd_sc_hd__a222oi_1 U11742 ( .A1(pcpi_rs1[15]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[15]), .C1(reg_out[15]), .C2(n9941), .Y(n9992) );
  sky130_fd_sc_hd__a222oi_1 U11743 ( .A1(pcpi_rs1[16]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[16]), .C1(reg_out[16]), .C2(n9941), .Y(n9994) );
  sky130_fd_sc_hd__a222oi_1 U11744 ( .A1(pcpi_rs1[17]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[17]), .C1(reg_out[17]), .C2(n9941), .Y(n9996) );
  sky130_fd_sc_hd__a222oi_1 U11745 ( .A1(pcpi_rs1[18]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[18]), .C1(reg_out[18]), .C2(n9941), .Y(n9998) );
  sky130_fd_sc_hd__a222oi_1 U11746 ( .A1(pcpi_rs1[19]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[19]), .C1(reg_out[19]), .C2(n9941), .Y(n10000) );
  sky130_fd_sc_hd__a222oi_1 U11747 ( .A1(pcpi_rs1[20]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[20]), .C1(reg_out[20]), .C2(n9941), .Y(n10002) );
  sky130_fd_sc_hd__a222oi_1 U11748 ( .A1(pcpi_rs1[21]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[21]), .C1(reg_out[21]), .C2(n9941), .Y(n10004) );
  sky130_fd_sc_hd__a222oi_1 U11749 ( .A1(pcpi_rs1[22]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[22]), .C1(reg_out[22]), .C2(n9941), .Y(n10006) );
  sky130_fd_sc_hd__a222oi_1 U11750 ( .A1(pcpi_rs1[23]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[23]), .C1(reg_out[23]), .C2(n9941), .Y(n10008) );
  sky130_fd_sc_hd__a222oi_1 U11751 ( .A1(pcpi_rs1[24]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[24]), .C1(reg_out[24]), .C2(n9941), .Y(n10010) );
  sky130_fd_sc_hd__a222oi_1 U11752 ( .A1(pcpi_rs1[25]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[25]), .C1(reg_out[25]), .C2(n9941), .Y(n10012) );
  sky130_fd_sc_hd__a22oi_1 U11753 ( .A1(pcpi_rs1[26]), .A2(n9943), .B1(n9941), 
        .B2(reg_out[26]), .Y(n9938) );
  sky130_fd_sc_hd__o21ai_1 U11754 ( .A1(n9940), .A2(n9939), .B1(n9938), .Y(
        mem_la_addr[26]) );
  sky130_fd_sc_hd__a222oi_1 U11755 ( .A1(pcpi_rs1[27]), .A2(n9943), .B1(n9942), 
        .B2(reg_next_pc[27]), .C1(reg_out[27]), .C2(n9941), .Y(n10016) );
  sky130_fd_sc_hd__nor2_1 U11756 ( .A(mem_state[1]), .B(mem_state[0]), .Y(
        n9963) );
  sky130_fd_sc_hd__nand2_1 U11757 ( .A(resetn), .B(n9963), .Y(n10138) );
  sky130_fd_sc_hd__nand3_1 U11758 ( .A(n9944), .B(mem_do_wdata), .C(n10061), 
        .Y(n9945) );
  sky130_fd_sc_hd__nand2_1 U11759 ( .A(n9945), .B(mem_wdata[0]), .Y(n9946) );
  sky130_fd_sc_hd__o21ai_1 U11760 ( .A1(n9947), .A2(n9945), .B1(n9946), .Y(
        n2830) );
  sky130_fd_sc_hd__nand2_1 U11761 ( .A(n9945), .B(mem_wdata[1]), .Y(n9948) );
  sky130_fd_sc_hd__o21ai_1 U11762 ( .A1(n9949), .A2(n9945), .B1(n9948), .Y(
        n2823) );
  sky130_fd_sc_hd__nand2_1 U11763 ( .A(n9945), .B(mem_wdata[2]), .Y(n9950) );
  sky130_fd_sc_hd__o21ai_1 U11764 ( .A1(n9951), .A2(n9945), .B1(n9950), .Y(
        n2824) );
  sky130_fd_sc_hd__nand2_1 U11765 ( .A(n9945), .B(mem_wdata[3]), .Y(n9952) );
  sky130_fd_sc_hd__o21ai_1 U11766 ( .A1(n9953), .A2(n9945), .B1(n9952), .Y(
        n2825) );
  sky130_fd_sc_hd__nand2_1 U11767 ( .A(n9945), .B(mem_wdata[4]), .Y(n9954) );
  sky130_fd_sc_hd__o21ai_1 U11768 ( .A1(n9955), .A2(n9945), .B1(n9954), .Y(
        n2826) );
  sky130_fd_sc_hd__nand2_1 U11769 ( .A(n9945), .B(mem_wdata[5]), .Y(n9956) );
  sky130_fd_sc_hd__o21ai_1 U11770 ( .A1(n9957), .A2(n9945), .B1(n9956), .Y(
        n2827) );
  sky130_fd_sc_hd__nand2_1 U11771 ( .A(n9945), .B(mem_wdata[6]), .Y(n9958) );
  sky130_fd_sc_hd__o21ai_1 U11772 ( .A1(n9959), .A2(n9945), .B1(n9958), .Y(
        n2828) );
  sky130_fd_sc_hd__nand2_1 U11773 ( .A(n9945), .B(mem_wdata[7]), .Y(n9960) );
  sky130_fd_sc_hd__o21ai_1 U11774 ( .A1(n9961), .A2(n9945), .B1(n9960), .Y(
        n2829) );
  sky130_fd_sc_hd__nor2_1 U11775 ( .A(n10133), .B(mem_do_rdata), .Y(n10137) );
  sky130_fd_sc_hd__nor2_1 U11776 ( .A(n9962), .B(mem_do_wdata), .Y(n9964) );
  sky130_fd_sc_hd__nand3_1 U11777 ( .A(n9963), .B(resetn), .C(n10061), .Y(
        n10069) );
  sky130_fd_sc_hd__nand2_1 U11778 ( .A(mem_la_addr[2]), .B(n10136), .Y(n9965)
         );
  sky130_fd_sc_hd__o21ai_1 U11779 ( .A1(n10136), .A2(n9966), .B1(n9965), .Y(
        n2763) );
  sky130_fd_sc_hd__nand2_1 U11780 ( .A(mem_la_addr[3]), .B(n10136), .Y(n9967)
         );
  sky130_fd_sc_hd__o21ai_1 U11781 ( .A1(n10136), .A2(n9968), .B1(n9967), .Y(
        n2762) );
  sky130_fd_sc_hd__nand2_1 U11782 ( .A(mem_la_addr[4]), .B(n10136), .Y(n9969)
         );
  sky130_fd_sc_hd__o21ai_1 U11783 ( .A1(n10136), .A2(n9970), .B1(n9969), .Y(
        n2761) );
  sky130_fd_sc_hd__nand2_1 U11784 ( .A(mem_la_addr[5]), .B(n10136), .Y(n9971)
         );
  sky130_fd_sc_hd__o21ai_1 U11785 ( .A1(n10136), .A2(n9972), .B1(n9971), .Y(
        n2760) );
  sky130_fd_sc_hd__nand2_1 U11786 ( .A(mem_la_addr[6]), .B(n10136), .Y(n9973)
         );
  sky130_fd_sc_hd__o21ai_1 U11787 ( .A1(n10136), .A2(n9974), .B1(n9973), .Y(
        n2759) );
  sky130_fd_sc_hd__nand2_1 U11788 ( .A(mem_la_addr[7]), .B(n10136), .Y(n9975)
         );
  sky130_fd_sc_hd__o21ai_1 U11789 ( .A1(n10136), .A2(n9976), .B1(n9975), .Y(
        n2758) );
  sky130_fd_sc_hd__nand2_1 U11790 ( .A(mem_la_addr[8]), .B(n10136), .Y(n9977)
         );
  sky130_fd_sc_hd__o21ai_1 U11791 ( .A1(n10136), .A2(n9978), .B1(n9977), .Y(
        n2757) );
  sky130_fd_sc_hd__nand2_1 U11792 ( .A(mem_la_addr[9]), .B(n10136), .Y(n9979)
         );
  sky130_fd_sc_hd__o21ai_1 U11793 ( .A1(n10136), .A2(n9980), .B1(n9979), .Y(
        n2756) );
  sky130_fd_sc_hd__nand2_1 U11794 ( .A(mem_la_addr[10]), .B(n10136), .Y(n9981)
         );
  sky130_fd_sc_hd__o21ai_1 U11795 ( .A1(n10136), .A2(n9982), .B1(n9981), .Y(
        n2755) );
  sky130_fd_sc_hd__nand2_1 U11796 ( .A(mem_la_addr[11]), .B(n10136), .Y(n9983)
         );
  sky130_fd_sc_hd__o21ai_1 U11797 ( .A1(n10136), .A2(n9984), .B1(n9983), .Y(
        n2754) );
  sky130_fd_sc_hd__nand2_1 U11798 ( .A(mem_la_addr[12]), .B(n10136), .Y(n9985)
         );
  sky130_fd_sc_hd__o21ai_1 U11799 ( .A1(n10136), .A2(n9986), .B1(n9985), .Y(
        n2753) );
  sky130_fd_sc_hd__nand2_1 U11800 ( .A(n10066), .B(mem_addr[13]), .Y(n9987) );
  sky130_fd_sc_hd__o21ai_1 U11801 ( .A1(n10066), .A2(n9988), .B1(n9987), .Y(
        n2752) );
  sky130_fd_sc_hd__nand2_1 U11802 ( .A(n10066), .B(mem_addr[14]), .Y(n9989) );
  sky130_fd_sc_hd__o21ai_1 U11803 ( .A1(n10066), .A2(n9990), .B1(n9989), .Y(
        n2751) );
  sky130_fd_sc_hd__nand2_1 U11804 ( .A(n10066), .B(mem_addr[15]), .Y(n9991) );
  sky130_fd_sc_hd__o21ai_1 U11805 ( .A1(n10066), .A2(n9992), .B1(n9991), .Y(
        n2750) );
  sky130_fd_sc_hd__nand2_1 U11806 ( .A(n10066), .B(mem_addr[16]), .Y(n9993) );
  sky130_fd_sc_hd__o21ai_1 U11807 ( .A1(n10066), .A2(n9994), .B1(n9993), .Y(
        n2749) );
  sky130_fd_sc_hd__nand2_1 U11808 ( .A(n10066), .B(mem_addr[17]), .Y(n9995) );
  sky130_fd_sc_hd__o21ai_1 U11809 ( .A1(n10066), .A2(n9996), .B1(n9995), .Y(
        n2748) );
  sky130_fd_sc_hd__nand2_1 U11810 ( .A(n10066), .B(mem_addr[18]), .Y(n9997) );
  sky130_fd_sc_hd__o21ai_1 U11811 ( .A1(n10066), .A2(n9998), .B1(n9997), .Y(
        n2747) );
  sky130_fd_sc_hd__nand2_1 U11812 ( .A(n10066), .B(mem_addr[19]), .Y(n9999) );
  sky130_fd_sc_hd__o21ai_1 U11813 ( .A1(n10066), .A2(n10000), .B1(n9999), .Y(
        n2746) );
  sky130_fd_sc_hd__nand2_1 U11814 ( .A(n10066), .B(mem_addr[20]), .Y(n10001)
         );
  sky130_fd_sc_hd__o21ai_1 U11815 ( .A1(n10066), .A2(n10002), .B1(n10001), .Y(
        n2745) );
  sky130_fd_sc_hd__nand2_1 U11816 ( .A(n10066), .B(mem_addr[21]), .Y(n10003)
         );
  sky130_fd_sc_hd__o21ai_1 U11817 ( .A1(n10066), .A2(n10004), .B1(n10003), .Y(
        n2744) );
  sky130_fd_sc_hd__nand2_1 U11818 ( .A(n10066), .B(mem_addr[22]), .Y(n10005)
         );
  sky130_fd_sc_hd__o21ai_1 U11819 ( .A1(n10066), .A2(n10006), .B1(n10005), .Y(
        n2743) );
  sky130_fd_sc_hd__nand2_1 U11820 ( .A(n10066), .B(mem_addr[23]), .Y(n10007)
         );
  sky130_fd_sc_hd__o21ai_1 U11821 ( .A1(n10066), .A2(n10008), .B1(n10007), .Y(
        n2742) );
  sky130_fd_sc_hd__nand2_1 U11822 ( .A(n10066), .B(mem_addr[24]), .Y(n10009)
         );
  sky130_fd_sc_hd__o21ai_1 U11823 ( .A1(n10066), .A2(n10010), .B1(n10009), .Y(
        n2741) );
  sky130_fd_sc_hd__nand2_1 U11824 ( .A(n10066), .B(mem_addr[25]), .Y(n10011)
         );
  sky130_fd_sc_hd__o21ai_1 U11825 ( .A1(n10066), .A2(n10012), .B1(n10011), .Y(
        n2740) );
  sky130_fd_sc_hd__nand2_1 U11826 ( .A(mem_la_addr[26]), .B(n10136), .Y(n10013) );
  sky130_fd_sc_hd__o21ai_1 U11827 ( .A1(n10136), .A2(n10014), .B1(n10013), .Y(
        n2739) );
  sky130_fd_sc_hd__nand2_1 U11828 ( .A(n10066), .B(mem_addr[27]), .Y(n10015)
         );
  sky130_fd_sc_hd__o21ai_1 U11829 ( .A1(n10066), .A2(n10016), .B1(n10015), .Y(
        n2738) );
  sky130_fd_sc_hd__clkinv_1 U11830 ( .A(n10018), .Y(n10019) );
  sky130_fd_sc_hd__nand2_1 U11831 ( .A(n10027), .B(n10019), .Y(n4167) );
  sky130_fd_sc_hd__nand3_1 U11832 ( .A(n10104), .B(n10100), .C(n10107), .Y(
        N258) );
  sky130_fd_sc_hd__nor2_1 U11833 ( .A(n10020), .B(n10027), .Y(N196) );
  sky130_fd_sc_hd__nor2_1 U11834 ( .A(n10021), .B(n10027), .Y(N197) );
  sky130_fd_sc_hd__nor2_1 U11835 ( .A(n10022), .B(n10027), .Y(N198) );
  sky130_fd_sc_hd__nor2_1 U11836 ( .A(n10023), .B(n10027), .Y(N199) );
  sky130_fd_sc_hd__nor2_1 U11837 ( .A(n10024), .B(n10027), .Y(N200) );
  sky130_fd_sc_hd__nor2_1 U11838 ( .A(n10025), .B(n10027), .Y(N201) );
  sky130_fd_sc_hd__nor2_1 U11839 ( .A(n10026), .B(n10027), .Y(N202) );
  sky130_fd_sc_hd__nor2_1 U11840 ( .A(n10028), .B(n10027), .Y(N203) );
  sky130_fd_sc_hd__nor2_1 U11841 ( .A(n10030), .B(n10029), .Y(n10032) );
  sky130_fd_sc_hd__nor3_1 U11842 ( .A(n10032), .B(n10124), .C(n10060), .Y(
        n10031) );
  sky130_fd_sc_hd__a22o_1 U11843 ( .A1(instr_lb), .A2(n10031), .B1(n10032), 
        .B2(latched_is_lb), .X(n4121) );
  sky130_fd_sc_hd__a22o_1 U11844 ( .A1(instr_lh), .A2(n10031), .B1(n10032), 
        .B2(latched_is_lh), .X(n4120) );
  sky130_fd_sc_hd__a22o_1 U11845 ( .A1(n10032), .A2(latched_is_lu), .B1(n10031), .B2(is_lbu_lhu_lw), .X(n4119) );
  sky130_fd_sc_hd__o22ai_1 U11846 ( .A1(n10035), .A2(n10052), .B1(n10034), 
        .B2(n10033), .Y(n3985) );
  sky130_fd_sc_hd__o22ai_1 U11847 ( .A1(n10037), .A2(n10052), .B1(n10038), 
        .B2(n10036), .Y(n3983) );
  sky130_fd_sc_hd__nand2_1 U11848 ( .A(is_alu_reg_imm), .B(n10096), .Y(n10041)
         );
  sky130_fd_sc_hd__o22ai_1 U11849 ( .A1(n10039), .A2(n10052), .B1(n10038), 
        .B2(n10041), .Y(n3980) );
  sky130_fd_sc_hd__o22ai_1 U11850 ( .A1(n10042), .A2(n10052), .B1(n10041), 
        .B2(n10040), .Y(n3979) );
  sky130_fd_sc_hd__a22o_1 U11851 ( .A1(n10044), .A2(n10043), .B1(instr_add), 
        .B2(n10050), .X(n3975) );
  sky130_fd_sc_hd__o22ai_1 U11852 ( .A1(mem_rdata_q[14]), .A2(n10046), .B1(
        n10045), .B2(n10052), .Y(n3972) );
  sky130_fd_sc_hd__o22ai_1 U11853 ( .A1(mem_rdata_q[14]), .A2(n10048), .B1(
        n10047), .B2(n10052), .Y(n3971) );
  sky130_fd_sc_hd__a22o_1 U11854 ( .A1(instr_xor), .A2(n10050), .B1(n10049), 
        .B2(n10102), .X(n3970) );
  sky130_fd_sc_hd__o22ai_1 U11855 ( .A1(n10053), .A2(n10052), .B1(n10096), 
        .B2(n10051), .Y(n3969) );
  sky130_fd_sc_hd__a22o_1 U11856 ( .A1(latched_rd[0]), .A2(n10056), .B1(n10055), .B2(decoded_rd[0]), .X(n3963) );
  sky130_fd_sc_hd__a22o_1 U11857 ( .A1(latched_rd[1]), .A2(n10056), .B1(n10055), .B2(decoded_rd[1]), .X(n3962) );
  sky130_fd_sc_hd__a22o_1 U11858 ( .A1(latched_rd[2]), .A2(n10056), .B1(n10055), .B2(decoded_rd[2]), .X(n3961) );
  sky130_fd_sc_hd__a22o_1 U11859 ( .A1(latched_rd[3]), .A2(n10056), .B1(n10055), .B2(decoded_rd[3]), .X(n3960) );
  sky130_fd_sc_hd__o2bb2ai_1 U11860 ( .B1(n7247), .B2(n10059), .A1_N(n7247), 
        .A2_N(\cpuregs[31][0] ), .Y(n3926) );
  sky130_fd_sc_hd__o2bb2ai_1 U11861 ( .B1(n4177), .B2(n10059), .A1_N(n4177), 
        .A2_N(\cpuregs[30][0] ), .Y(n3925) );
  sky130_fd_sc_hd__o2bb2ai_1 U11862 ( .B1(n4176), .B2(n10059), .A1_N(n4176), 
        .A2_N(\cpuregs[29][0] ), .Y(n3924) );
  sky130_fd_sc_hd__o2bb2ai_1 U11863 ( .B1(n4219), .B2(n10059), .A1_N(n4219), 
        .A2_N(\cpuregs[28][0] ), .Y(n3923) );
  sky130_fd_sc_hd__o2bb2ai_1 U11864 ( .B1(n4175), .B2(n10059), .A1_N(n4175), 
        .A2_N(\cpuregs[27][0] ), .Y(n3922) );
  sky130_fd_sc_hd__o2bb2ai_1 U11865 ( .B1(n9621), .B2(n10059), .A1_N(n9621), 
        .A2_N(\cpuregs[26][0] ), .Y(n3921) );
  sky130_fd_sc_hd__o2bb2ai_1 U11866 ( .B1(n4192), .B2(n10059), .A1_N(n4192), 
        .A2_N(\cpuregs[25][0] ), .Y(n3920) );
  sky130_fd_sc_hd__o2bb2ai_1 U11867 ( .B1(n10057), .B2(n10059), .A1_N(n10057), 
        .A2_N(\cpuregs[24][0] ), .Y(n3919) );
  sky130_fd_sc_hd__o2bb2ai_1 U11868 ( .B1(n4173), .B2(n10059), .A1_N(n4173), 
        .A2_N(\cpuregs[23][0] ), .Y(n3918) );
  sky130_fd_sc_hd__o2bb2ai_1 U11869 ( .B1(n7084), .B2(n10059), .A1_N(n7084), 
        .A2_N(\cpuregs[22][0] ), .Y(n3917) );
  sky130_fd_sc_hd__o2bb2ai_1 U11870 ( .B1(n4174), .B2(n10059), .A1_N(n4174), 
        .A2_N(\cpuregs[21][0] ), .Y(n3916) );
  sky130_fd_sc_hd__o2bb2ai_1 U11871 ( .B1(n10058), .B2(n10059), .A1_N(n10058), 
        .A2_N(\cpuregs[20][0] ), .Y(n3915) );
  sky130_fd_sc_hd__o2bb2ai_1 U11872 ( .B1(n4194), .B2(n10059), .A1_N(n4194), 
        .A2_N(\cpuregs[19][0] ), .Y(n3914) );
  sky130_fd_sc_hd__o2bb2ai_1 U11873 ( .B1(n9820), .B2(n10059), .A1_N(n9820), 
        .A2_N(\cpuregs[18][0] ), .Y(n3913) );
  sky130_fd_sc_hd__o2bb2ai_1 U11874 ( .B1(n4195), .B2(n10059), .A1_N(n4195), 
        .A2_N(\cpuregs[17][0] ), .Y(n3912) );
  sky130_fd_sc_hd__o2bb2ai_1 U11875 ( .B1(n4197), .B2(n10059), .A1_N(n4197), 
        .A2_N(\cpuregs[16][0] ), .Y(n3911) );
  sky130_fd_sc_hd__o2bb2ai_1 U11876 ( .B1(n7069), .B2(n10059), .A1_N(n7069), 
        .A2_N(\cpuregs[15][0] ), .Y(n3910) );
  sky130_fd_sc_hd__o2bb2ai_1 U11877 ( .B1(n6897), .B2(n10059), .A1_N(n6897), 
        .A2_N(\cpuregs[14][0] ), .Y(n3909) );
  sky130_fd_sc_hd__o2bb2ai_1 U11878 ( .B1(n4186), .B2(n10059), .A1_N(n4186), 
        .A2_N(\cpuregs[13][0] ), .Y(n3908) );
  sky130_fd_sc_hd__o2bb2ai_1 U11879 ( .B1(n4226), .B2(n10059), .A1_N(n4226), 
        .A2_N(\cpuregs[12][0] ), .Y(n3907) );
  sky130_fd_sc_hd__o2bb2ai_1 U11880 ( .B1(n4185), .B2(n10059), .A1_N(n4185), 
        .A2_N(\cpuregs[11][0] ), .Y(n3906) );
  sky130_fd_sc_hd__o2bb2ai_1 U11881 ( .B1(n4184), .B2(n10059), .A1_N(n4184), 
        .A2_N(\cpuregs[10][0] ), .Y(n3905) );
  sky130_fd_sc_hd__o2bb2ai_1 U11882 ( .B1(n7452), .B2(n10059), .A1_N(n7452), 
        .A2_N(\cpuregs[9][0] ), .Y(n3904) );
  sky130_fd_sc_hd__o2bb2ai_1 U11883 ( .B1(n4183), .B2(n10059), .A1_N(n4183), 
        .A2_N(\cpuregs[8][0] ), .Y(n3903) );
  sky130_fd_sc_hd__o2bb2ai_1 U11884 ( .B1(n4199), .B2(n10059), .A1_N(n4199), 
        .A2_N(\cpuregs[7][0] ), .Y(n3902) );
  sky130_fd_sc_hd__o2bb2ai_1 U11885 ( .B1(n4180), .B2(n10059), .A1_N(n4180), 
        .A2_N(\cpuregs[5][0] ), .Y(n3900) );
  sky130_fd_sc_hd__o2bb2ai_1 U11886 ( .B1(n4179), .B2(n10059), .A1_N(n4179), 
        .A2_N(\cpuregs[4][0] ), .Y(n3899) );
  sky130_fd_sc_hd__o2bb2ai_1 U11887 ( .B1(n4201), .B2(n10059), .A1_N(n4201), 
        .A2_N(\cpuregs[3][0] ), .Y(n3898) );
  sky130_fd_sc_hd__o2bb2ai_1 U11888 ( .B1(n4178), .B2(n10059), .A1_N(n4178), 
        .A2_N(\cpuregs[2][0] ), .Y(n3897) );
  sky130_fd_sc_hd__o2bb2ai_1 U11889 ( .B1(n6396), .B2(n10059), .A1_N(n6396), 
        .A2_N(\cpuregs[1][0] ), .Y(n3896) );
  sky130_fd_sc_hd__nand2_1 U11890 ( .A(trap), .B(mem_ready), .Y(n10064) );
  sky130_fd_sc_hd__nand2_1 U11891 ( .A(mem_state[1]), .B(mem_state[0]), .Y(
        n10062) );
  sky130_fd_sc_hd__a31oi_1 U11892 ( .A1(n10063), .A2(n10062), .A3(n10061), 
        .B1(n10060), .Y(n10067) );
  sky130_fd_sc_hd__nand3_1 U11893 ( .A(n10064), .B(mem_valid), .C(n10067), .Y(
        n10065) );
  sky130_fd_sc_hd__nand2_1 U11894 ( .A(n10066), .B(n10065), .Y(n2931) );
  sky130_fd_sc_hd__o211ai_1 U11895 ( .A1(trap), .A2(n10068), .B1(n10067), .C1(
        n10066), .Y(n10077) );
  sky130_fd_sc_hd__nor2_1 U11896 ( .A(mem_do_wdata), .B(n10069), .Y(n10134) );
  sky130_fd_sc_hd__nor2_1 U11897 ( .A(n10060), .B(mem_do_rinst), .Y(n10070) );
  sky130_fd_sc_hd__and3_1 U11898 ( .A(n10071), .B(n10070), .C(mem_state[0]), 
        .X(n10074) );
  sky130_fd_sc_hd__o21ai_1 U11899 ( .A1(n10134), .A2(n10074), .B1(n10077), .Y(
        n10072) );
  sky130_fd_sc_hd__o21ai_1 U11900 ( .A1(n10077), .A2(n10073), .B1(n10072), .Y(
        n2930) );
  sky130_fd_sc_hd__o21ai_1 U11901 ( .A1(n10074), .A2(n10140), .B1(n10077), .Y(
        n10075) );
  sky130_fd_sc_hd__o21ai_1 U11902 ( .A1(n10077), .A2(n10076), .B1(n10075), .Y(
        n2929) );
  sky130_fd_sc_hd__a22oi_1 U11903 ( .A1(mem_rdata_q[11]), .A2(n10087), .B1(
        decoded_rd[4]), .B2(n10086), .Y(n10078) );
  sky130_fd_sc_hd__o21ai_1 U11904 ( .A1(n10089), .A2(n10079), .B1(n10078), .Y(
        n2927) );
  sky130_fd_sc_hd__a22oi_1 U11905 ( .A1(mem_rdata_q[10]), .A2(n10087), .B1(
        decoded_rd[3]), .B2(n10086), .Y(n10080) );
  sky130_fd_sc_hd__o21ai_1 U11906 ( .A1(n10089), .A2(n10081), .B1(n10080), .Y(
        n2926) );
  sky130_fd_sc_hd__a22oi_1 U11907 ( .A1(mem_rdata_q[9]), .A2(n10087), .B1(
        decoded_rd[2]), .B2(n10086), .Y(n10082) );
  sky130_fd_sc_hd__o21ai_1 U11908 ( .A1(n10089), .A2(n10083), .B1(n10082), .Y(
        n2925) );
  sky130_fd_sc_hd__a22oi_1 U11909 ( .A1(mem_rdata_q[8]), .A2(n10087), .B1(
        decoded_rd[1]), .B2(n10086), .Y(n10084) );
  sky130_fd_sc_hd__o21ai_1 U11910 ( .A1(n10089), .A2(n10085), .B1(n10084), .Y(
        n2924) );
  sky130_fd_sc_hd__a22oi_1 U11911 ( .A1(mem_rdata_q[7]), .A2(n10087), .B1(
        decoded_rd[0]), .B2(n10086), .Y(n10088) );
  sky130_fd_sc_hd__o21ai_1 U11912 ( .A1(n10089), .A2(n5907), .B1(n10088), .Y(
        n2923) );
  sky130_fd_sc_hd__nand2_1 U11913 ( .A(n10094), .B(n10090), .Y(n10112) );
  sky130_fd_sc_hd__o22ai_1 U11914 ( .A1(n10114), .A2(n10091), .B1(n10109), 
        .B2(n10112), .Y(n2922) );
  sky130_fd_sc_hd__a22o_1 U11915 ( .A1(is_sll_srl_sra), .A2(n10122), .B1(
        is_alu_reg_reg), .B2(n10092), .X(n2917) );
  sky130_fd_sc_hd__nand2_1 U11916 ( .A(n10094), .B(n10093), .Y(n10108) );
  sky130_fd_sc_hd__o22ai_1 U11917 ( .A1(n10114), .A2(n10099), .B1(n10113), 
        .B2(n10108), .Y(n2910) );
  sky130_fd_sc_hd__nand3_1 U11918 ( .A(n10101), .B(n10096), .C(n10095), .Y(
        n10110) );
  sky130_fd_sc_hd__o22ai_1 U11919 ( .A1(n5983), .A2(n10097), .B1(n10099), .B2(
        n10110), .Y(n2909) );
  sky130_fd_sc_hd__o22ai_1 U11920 ( .A1(n5983), .A2(n10100), .B1(n10099), .B2(
        n10098), .Y(n2907) );
  sky130_fd_sc_hd__nand2_1 U11921 ( .A(is_lb_lh_lw_lbu_lhu), .B(n10102), .Y(
        n10105) );
  sky130_fd_sc_hd__o22ai_1 U11922 ( .A1(n5983), .A2(n10104), .B1(n10103), .B2(
        n10105), .Y(n2906) );
  sky130_fd_sc_hd__o22ai_1 U11923 ( .A1(n5983), .A2(n10107), .B1(n10106), .B2(
        n10105), .Y(n2905) );
  sky130_fd_sc_hd__o22ai_1 U11924 ( .A1(n10114), .A2(n10111), .B1(n10109), 
        .B2(n10108), .Y(n2904) );
  sky130_fd_sc_hd__o22ai_1 U11925 ( .A1(n5983), .A2(n10128), .B1(n10111), .B2(
        n10110), .Y(n2903) );
  sky130_fd_sc_hd__o22ai_1 U11926 ( .A1(n10114), .A2(n10120), .B1(n10113), 
        .B2(n10112), .Y(n2900) );
  sky130_fd_sc_hd__o22ai_1 U11927 ( .A1(mem_rdata_q[30]), .A2(n10116), .B1(
        n5983), .B2(n10115), .Y(n2898) );
  sky130_fd_sc_hd__o21ai_1 U11928 ( .A1(n5983), .A2(n10118), .B1(n10117), .Y(
        n2896) );
  sky130_fd_sc_hd__o21ai_1 U11929 ( .A1(n10121), .A2(n10120), .B1(n10119), .Y(
        n10123) );
  sky130_fd_sc_hd__a22o_1 U11930 ( .A1(n5983), .A2(n10123), .B1(n10122), .B2(
        is_jalr_addi_slti_sltiu_xori_ori_andi), .X(n2895) );
  sky130_fd_sc_hd__nor3_1 U11931 ( .A(n10126), .B(n10125), .C(n10124), .Y(
        n10127) );
  sky130_fd_sc_hd__a31oi_1 U11932 ( .A1(n10129), .A2(instr_sh), .A3(n10128), 
        .B1(n10127), .Y(n10132) );
  sky130_fd_sc_hd__nand2_1 U11933 ( .A(mem_wordsize[0]), .B(n10131), .Y(n10130) );
  sky130_fd_sc_hd__o21ai_1 U11934 ( .A1(n10132), .A2(n10131), .B1(n10130), .Y(
        n2832) );
  sky130_fd_sc_hd__a22o_1 U11935 ( .A1(n10140), .A2(mem_la_wdata[16]), .B1(
        n9945), .B2(mem_wdata[16]), .X(n2822) );
  sky130_fd_sc_hd__a22o_1 U11936 ( .A1(n10140), .A2(mem_la_wdata[17]), .B1(
        n9945), .B2(mem_wdata[17]), .X(n2821) );
  sky130_fd_sc_hd__a22o_1 U11937 ( .A1(n10140), .A2(mem_la_wdata[18]), .B1(
        n9945), .B2(mem_wdata[18]), .X(n2820) );
  sky130_fd_sc_hd__a22o_1 U11938 ( .A1(n10140), .A2(mem_la_wdata[19]), .B1(
        n9945), .B2(mem_wdata[19]), .X(n2819) );
  sky130_fd_sc_hd__a22o_1 U11939 ( .A1(n10140), .A2(mem_la_wdata[20]), .B1(
        n9945), .B2(mem_wdata[20]), .X(n2818) );
  sky130_fd_sc_hd__a22o_1 U11940 ( .A1(n10140), .A2(mem_la_wdata[21]), .B1(
        n9945), .B2(mem_wdata[21]), .X(n2817) );
  sky130_fd_sc_hd__a22o_1 U11941 ( .A1(n10140), .A2(mem_la_wdata[22]), .B1(
        n9945), .B2(mem_wdata[22]), .X(n2816) );
  sky130_fd_sc_hd__a22o_1 U11942 ( .A1(n10140), .A2(mem_la_wdata[23]), .B1(
        n9945), .B2(mem_wdata[23]), .X(n2815) );
  sky130_fd_sc_hd__a22o_1 U11943 ( .A1(n10140), .A2(mem_la_wdata[8]), .B1(
        n9945), .B2(mem_wdata[8]), .X(n2814) );
  sky130_fd_sc_hd__a22o_1 U11944 ( .A1(n10140), .A2(mem_la_wdata[24]), .B1(
        n9945), .B2(mem_wdata[24]), .X(n2813) );
  sky130_fd_sc_hd__a22o_1 U11945 ( .A1(n10140), .A2(mem_la_wdata[9]), .B1(
        n9945), .B2(mem_wdata[9]), .X(n2812) );
  sky130_fd_sc_hd__a22o_1 U11946 ( .A1(n10140), .A2(mem_la_wdata[25]), .B1(
        n9945), .B2(mem_wdata[25]), .X(n2811) );
  sky130_fd_sc_hd__a22o_1 U11947 ( .A1(n10140), .A2(mem_la_wdata[10]), .B1(
        n9945), .B2(mem_wdata[10]), .X(n2810) );
  sky130_fd_sc_hd__a22o_1 U11948 ( .A1(n10140), .A2(mem_la_wdata[26]), .B1(
        n9945), .B2(mem_wdata[26]), .X(n2809) );
  sky130_fd_sc_hd__a22o_1 U11949 ( .A1(n10140), .A2(mem_la_wdata[11]), .B1(
        n9945), .B2(mem_wdata[11]), .X(n2808) );
  sky130_fd_sc_hd__a22o_1 U11950 ( .A1(n10140), .A2(mem_la_wdata[27]), .B1(
        n9945), .B2(mem_wdata[27]), .X(n2807) );
  sky130_fd_sc_hd__a22o_1 U11951 ( .A1(n10140), .A2(mem_la_wdata[12]), .B1(
        n9945), .B2(mem_wdata[12]), .X(n2806) );
  sky130_fd_sc_hd__a22o_1 U11952 ( .A1(n10140), .A2(mem_la_wdata[28]), .B1(
        n9945), .B2(mem_wdata[28]), .X(n2805) );
  sky130_fd_sc_hd__a22o_1 U11953 ( .A1(n10140), .A2(mem_la_wdata[13]), .B1(
        n9945), .B2(mem_wdata[13]), .X(n2804) );
  sky130_fd_sc_hd__a22o_1 U11954 ( .A1(n10140), .A2(mem_la_wdata[29]), .B1(
        n9945), .B2(mem_wdata[29]), .X(n2803) );
  sky130_fd_sc_hd__a22o_1 U11955 ( .A1(n10140), .A2(mem_la_wdata[14]), .B1(
        n9945), .B2(mem_wdata[14]), .X(n2802) );
  sky130_fd_sc_hd__a22o_1 U11956 ( .A1(n10140), .A2(mem_la_wdata[30]), .B1(
        n9945), .B2(mem_wdata[30]), .X(n2801) );
  sky130_fd_sc_hd__a22o_1 U11957 ( .A1(n10140), .A2(mem_la_wdata[15]), .B1(
        n9945), .B2(mem_wdata[15]), .X(n2800) );
  sky130_fd_sc_hd__a22o_1 U11958 ( .A1(mem_instr), .A2(n10066), .B1(n10134), 
        .B2(n10133), .X(n2798) );
  sky130_fd_sc_hd__nor2b_1 U11959 ( .B_N(n10137), .A(n9945), .Y(n10135) );
  sky130_fd_sc_hd__a22o_1 U11960 ( .A1(mem_la_wstrb[0]), .A2(n10135), .B1(
        mem_wstrb[0]), .B2(n10066), .X(n2797) );
  sky130_fd_sc_hd__a22o_1 U11961 ( .A1(mem_la_wstrb[1]), .A2(n10135), .B1(
        mem_wstrb[1]), .B2(n10066), .X(n2796) );
  sky130_fd_sc_hd__a22o_1 U11962 ( .A1(mem_la_wstrb[2]), .A2(n10135), .B1(
        mem_wstrb[2]), .B2(n10066), .X(n2795) );
  sky130_fd_sc_hd__a22o_1 U11963 ( .A1(mem_la_wstrb[3]), .A2(n10135), .B1(
        mem_wstrb[3]), .B2(n10066), .X(n2794) );
  sky130_fd_sc_hd__a22o_1 U11964 ( .A1(n10136), .A2(mem_la_addr[28]), .B1(
        n10066), .B2(mem_addr[28]), .X(n2737) );
  sky130_fd_sc_hd__a22o_1 U11965 ( .A1(n10136), .A2(mem_la_addr[29]), .B1(
        n10066), .B2(mem_addr[29]), .X(n2736) );
  sky130_fd_sc_hd__a22o_1 U11966 ( .A1(n10136), .A2(mem_la_addr[30]), .B1(
        n10066), .B2(mem_addr[30]), .X(n2735) );
  sky130_fd_sc_hd__a22o_1 U11967 ( .A1(n10136), .A2(mem_la_addr[31]), .B1(
        n10066), .B2(mem_addr[31]), .X(n2734) );
  sky130_fd_sc_hd__nor2_1 U11968 ( .A(n10137), .B(n10138), .Y(mem_la_read) );
  sky130_fd_sc_hd__nor2_1 U11969 ( .A(n10139), .B(n10138), .Y(mem_la_write) );
  sky130_fd_sc_hd__a22o_1 U11970 ( .A1(n10140), .A2(mem_la_wdata[31]), .B1(
        n9945), .B2(mem_wdata[31]), .X(n2732) );
endmodule

