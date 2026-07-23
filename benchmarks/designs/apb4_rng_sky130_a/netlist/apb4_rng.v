/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 13:27:24 2025
/////////////////////////////////////////////////////////////


module dffr_DATA_WIDTH1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH32 ( clk_i, rst_n_i, dat_i, dat_o );
  input [31:0] dat_i;
  output [31:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module lfsr_galois_32_e0000200 ( clk_i, rst_n_i, wr_i, dat_i, dat_o );
  input [31:0] dat_i;
  output [31:0] dat_o;
  input clk_i, rst_n_i, wr_i;
  wire   n2, n3, n4, n1, n5, n6, n7, n8;
  wire   [31:0] s_shift_d;

  dffr_DATA_WIDTH32 u_shift_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_shift_d), .dat_o(dat_o) );
  sky130_fd_sc_hd__xnor2_1 U5 ( .A(dat_o[0]), .B(dat_o[10]), .Y(n2) );
  sky130_fd_sc_hd__a22o_1 U6 ( .A1(dat_o[9]), .A2(n6), .B1(dat_i[8]), .B2(n1), 
        .X(s_shift_d[8]) );
  sky130_fd_sc_hd__a22o_1 U7 ( .A1(dat_o[8]), .A2(n7), .B1(dat_i[7]), .B2(n5), 
        .X(s_shift_d[7]) );
  sky130_fd_sc_hd__a22o_1 U8 ( .A1(dat_o[7]), .A2(n7), .B1(dat_i[6]), .B2(n5), 
        .X(s_shift_d[6]) );
  sky130_fd_sc_hd__a22o_1 U9 ( .A1(dat_o[6]), .A2(n7), .B1(dat_i[5]), .B2(n5), 
        .X(s_shift_d[5]) );
  sky130_fd_sc_hd__a22o_1 U10 ( .A1(dat_o[5]), .A2(n7), .B1(dat_i[4]), .B2(n5), 
        .X(s_shift_d[4]) );
  sky130_fd_sc_hd__a22o_1 U11 ( .A1(dat_o[4]), .A2(n7), .B1(dat_i[3]), .B2(n5), 
        .X(s_shift_d[3]) );
  sky130_fd_sc_hd__a22o_1 U12 ( .A1(n7), .A2(dat_o[0]), .B1(dat_i[31]), .B2(n5), .X(s_shift_d[31]) );
  sky130_fd_sc_hd__xnor2_1 U13 ( .A(dat_o[0]), .B(dat_o[31]), .Y(n3) );
  sky130_fd_sc_hd__a22o_1 U14 ( .A1(dat_o[3]), .A2(n7), .B1(dat_i[2]), .B2(n5), 
        .X(s_shift_d[2]) );
  sky130_fd_sc_hd__xnor2_1 U15 ( .A(dat_o[0]), .B(dat_o[30]), .Y(n4) );
  sky130_fd_sc_hd__a22o_1 U16 ( .A1(dat_o[29]), .A2(n7), .B1(dat_i[28]), .B2(
        n5), .X(s_shift_d[28]) );
  sky130_fd_sc_hd__a22o_1 U17 ( .A1(dat_o[28]), .A2(n7), .B1(dat_i[27]), .B2(
        n5), .X(s_shift_d[27]) );
  sky130_fd_sc_hd__a22o_1 U18 ( .A1(dat_o[27]), .A2(n7), .B1(dat_i[26]), .B2(
        n5), .X(s_shift_d[26]) );
  sky130_fd_sc_hd__a22o_1 U19 ( .A1(dat_o[26]), .A2(n7), .B1(dat_i[25]), .B2(
        n5), .X(s_shift_d[25]) );
  sky130_fd_sc_hd__a22o_1 U20 ( .A1(dat_o[25]), .A2(n7), .B1(dat_i[24]), .B2(
        n5), .X(s_shift_d[24]) );
  sky130_fd_sc_hd__a22o_1 U21 ( .A1(dat_o[24]), .A2(n7), .B1(dat_i[23]), .B2(
        n5), .X(s_shift_d[23]) );
  sky130_fd_sc_hd__a22o_1 U22 ( .A1(dat_o[23]), .A2(n7), .B1(dat_i[22]), .B2(
        n5), .X(s_shift_d[22]) );
  sky130_fd_sc_hd__a22o_1 U23 ( .A1(dat_o[22]), .A2(n7), .B1(dat_i[21]), .B2(
        n1), .X(s_shift_d[21]) );
  sky130_fd_sc_hd__a22o_1 U24 ( .A1(dat_o[21]), .A2(n7), .B1(dat_i[20]), .B2(
        n1), .X(s_shift_d[20]) );
  sky130_fd_sc_hd__a22o_1 U25 ( .A1(dat_o[2]), .A2(n7), .B1(dat_i[1]), .B2(n1), 
        .X(s_shift_d[1]) );
  sky130_fd_sc_hd__a22o_1 U26 ( .A1(dat_o[20]), .A2(n7), .B1(dat_i[19]), .B2(
        n1), .X(s_shift_d[19]) );
  sky130_fd_sc_hd__a22o_1 U27 ( .A1(dat_o[19]), .A2(n7), .B1(dat_i[18]), .B2(
        n1), .X(s_shift_d[18]) );
  sky130_fd_sc_hd__a22o_1 U28 ( .A1(dat_o[18]), .A2(n7), .B1(dat_i[17]), .B2(
        n1), .X(s_shift_d[17]) );
  sky130_fd_sc_hd__a22o_1 U29 ( .A1(dat_o[17]), .A2(n7), .B1(dat_i[16]), .B2(
        n1), .X(s_shift_d[16]) );
  sky130_fd_sc_hd__a22o_1 U30 ( .A1(dat_o[16]), .A2(n7), .B1(dat_i[15]), .B2(
        n1), .X(s_shift_d[15]) );
  sky130_fd_sc_hd__a22o_1 U31 ( .A1(dat_o[15]), .A2(n7), .B1(dat_i[14]), .B2(
        n1), .X(s_shift_d[14]) );
  sky130_fd_sc_hd__a22o_1 U32 ( .A1(dat_o[14]), .A2(n7), .B1(dat_i[13]), .B2(
        n1), .X(s_shift_d[13]) );
  sky130_fd_sc_hd__a22o_1 U33 ( .A1(dat_o[13]), .A2(n7), .B1(dat_i[12]), .B2(
        n1), .X(s_shift_d[12]) );
  sky130_fd_sc_hd__a22o_1 U34 ( .A1(dat_o[12]), .A2(n7), .B1(dat_i[11]), .B2(
        n1), .X(s_shift_d[11]) );
  sky130_fd_sc_hd__a22o_1 U35 ( .A1(dat_o[11]), .A2(n7), .B1(dat_i[10]), .B2(
        n1), .X(s_shift_d[10]) );
  sky130_fd_sc_hd__a22o_1 U36 ( .A1(dat_o[1]), .A2(n7), .B1(dat_i[0]), .B2(n5), 
        .X(s_shift_d[0]) );
  sky130_fd_sc_hd__buf_1 U1 ( .A(n8), .X(n6) );
  sky130_fd_sc_hd__inv_2 U2 ( .A(n6), .Y(n1) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(n6), .Y(n5) );
  sky130_fd_sc_hd__o2bb2ai_1 U4 ( .B1(n1), .B2(n2), .A1_N(n1), .A2_N(dat_i[9]), 
        .Y(s_shift_d[9]) );
  sky130_fd_sc_hd__o2bb2ai_1 U37 ( .B1(n1), .B2(n4), .A1_N(dat_i[29]), .A2_N(
        n1), .Y(s_shift_d[29]) );
  sky130_fd_sc_hd__o2bb2ai_1 U38 ( .B1(n1), .B2(n3), .A1_N(dat_i[30]), .A2_N(
        n1), .Y(s_shift_d[30]) );
  sky130_fd_sc_hd__buf_2 U39 ( .A(n8), .X(n7) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(wr_i), .Y(n8) );
endmodule


module apb4_rng ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite;
  output apb4_pready, apb4_pslverr;
  wire   \s_rng_ctrl_d[0] , \s_rng_ctrl_q[0] , n_0_net_, n1, n2, n3, n4, n5,
         n6, n7, n8, n9, n10;
  wire   [31:0] s_rng_val;

  dffr_DATA_WIDTH1 u_rng_ctrl_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(\s_rng_ctrl_d[0] ), .dat_o(\s_rng_ctrl_q[0] ) );
  lfsr_galois_32_e0000200 u_lfsr_galois ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .wr_i(n_0_net_), .dat_i(apb4_pwdata), .dat_o(s_rng_val)
         );
  sky130_fd_sc_hd__nand4b_1 U9 ( .A_N(apb4_paddr[3]), .B(apb4_pwrite), .C(
        apb4_psel), .D(apb4_penable), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U10 ( .A(apb4_paddr[2]), .B(\s_rng_ctrl_q[0] ), .Y(
        n5) );
  sky130_fd_sc_hd__and2_0 U11 ( .A(s_rng_val[9]), .B(n6), .X(apb4_prdata[9])
         );
  sky130_fd_sc_hd__and2_0 U12 ( .A(s_rng_val[8]), .B(n6), .X(apb4_prdata[8])
         );
  sky130_fd_sc_hd__and2_0 U13 ( .A(s_rng_val[7]), .B(n10), .X(apb4_prdata[7])
         );
  sky130_fd_sc_hd__and2_0 U14 ( .A(s_rng_val[6]), .B(n6), .X(apb4_prdata[6])
         );
  sky130_fd_sc_hd__and2_0 U15 ( .A(s_rng_val[5]), .B(n10), .X(apb4_prdata[5])
         );
  sky130_fd_sc_hd__and2_0 U16 ( .A(s_rng_val[4]), .B(n10), .X(apb4_prdata[4])
         );
  sky130_fd_sc_hd__and2_0 U17 ( .A(s_rng_val[3]), .B(n6), .X(apb4_prdata[3])
         );
  sky130_fd_sc_hd__and2_0 U18 ( .A(s_rng_val[31]), .B(n10), .X(apb4_prdata[31]) );
  sky130_fd_sc_hd__and2_0 U19 ( .A(s_rng_val[30]), .B(n10), .X(apb4_prdata[30]) );
  sky130_fd_sc_hd__and2_0 U20 ( .A(s_rng_val[2]), .B(n10), .X(apb4_prdata[2])
         );
  sky130_fd_sc_hd__and2_0 U21 ( .A(s_rng_val[29]), .B(n6), .X(apb4_prdata[29])
         );
  sky130_fd_sc_hd__and2_0 U22 ( .A(s_rng_val[28]), .B(n10), .X(apb4_prdata[28]) );
  sky130_fd_sc_hd__and2_0 U23 ( .A(s_rng_val[27]), .B(n10), .X(apb4_prdata[27]) );
  sky130_fd_sc_hd__and2_0 U24 ( .A(s_rng_val[26]), .B(n6), .X(apb4_prdata[26])
         );
  sky130_fd_sc_hd__and2_0 U25 ( .A(s_rng_val[25]), .B(n6), .X(apb4_prdata[25])
         );
  sky130_fd_sc_hd__and2_0 U26 ( .A(s_rng_val[24]), .B(n6), .X(apb4_prdata[24])
         );
  sky130_fd_sc_hd__and2_0 U27 ( .A(s_rng_val[23]), .B(n10), .X(apb4_prdata[23]) );
  sky130_fd_sc_hd__and2_0 U28 ( .A(s_rng_val[22]), .B(n6), .X(apb4_prdata[22])
         );
  sky130_fd_sc_hd__and2_0 U29 ( .A(s_rng_val[21]), .B(n6), .X(apb4_prdata[21])
         );
  sky130_fd_sc_hd__and2_0 U30 ( .A(s_rng_val[20]), .B(n6), .X(apb4_prdata[20])
         );
  sky130_fd_sc_hd__and2_0 U31 ( .A(s_rng_val[1]), .B(n10), .X(apb4_prdata[1])
         );
  sky130_fd_sc_hd__and2_0 U32 ( .A(s_rng_val[19]), .B(n6), .X(apb4_prdata[19])
         );
  sky130_fd_sc_hd__and2_0 U33 ( .A(s_rng_val[18]), .B(n10), .X(apb4_prdata[18]) );
  sky130_fd_sc_hd__and2_0 U34 ( .A(s_rng_val[17]), .B(n10), .X(apb4_prdata[17]) );
  sky130_fd_sc_hd__and2_0 U35 ( .A(s_rng_val[16]), .B(n10), .X(apb4_prdata[16]) );
  sky130_fd_sc_hd__and2_0 U36 ( .A(s_rng_val[15]), .B(n10), .X(apb4_prdata[15]) );
  sky130_fd_sc_hd__and2_0 U37 ( .A(s_rng_val[14]), .B(n6), .X(apb4_prdata[14])
         );
  sky130_fd_sc_hd__and2_0 U38 ( .A(s_rng_val[13]), .B(n10), .X(apb4_prdata[13]) );
  sky130_fd_sc_hd__and2_0 U39 ( .A(s_rng_val[12]), .B(n10), .X(apb4_prdata[12]) );
  sky130_fd_sc_hd__and2_0 U40 ( .A(s_rng_val[11]), .B(n10), .X(apb4_prdata[11]) );
  sky130_fd_sc_hd__and2_0 U41 ( .A(s_rng_val[10]), .B(n10), .X(apb4_prdata[10]) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(s_rng_val[0]), .B(n6), .Y(n8) );
  sky130_fd_sc_hd__nand3b_1 U43 ( .A_N(apb4_pwrite), .B(apb4_penable), .C(
        apb4_psel), .Y(n7) );
  sky130_fd_sc_hd__or3_1 U44 ( .A(apb4_paddr[4]), .B(apb4_paddr[5]), .C(
        apb4_paddr[2]), .X(n3) );
  sky130_fd_sc_hd__o2bb2ai_1 U45 ( .B1(n2), .B2(n1), .A1_N(apb4_pwdata[0]), 
        .A2_N(n2), .Y(\s_rng_ctrl_d[0] ) );
  sky130_fd_sc_hd__nor2_1 U46 ( .A(n3), .B(n4), .Y(n2) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(\s_rng_ctrl_q[0] ), .Y(n1) );
  sky130_fd_sc_hd__o41ai_1 U48 ( .A1(apb4_paddr[3]), .A2(n3), .A3(n1), .A4(n7), 
        .B1(n8), .Y(apb4_prdata[0]) );
  sky130_fd_sc_hd__nor3b_1 U49 ( .C_N(apb4_paddr[3]), .A(n7), .B(n3), .Y(n6)
         );
  sky130_fd_sc_hd__conb_1 U50 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__nor4_1 U51 ( .A(n5), .B(n4), .C(apb4_paddr[5]), .D(
        apb4_paddr[4]), .Y(n_0_net_) );
  sky130_fd_sc_hd__inv_2 U52 ( .A(n6), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n9), .Y(n10) );
endmodule

