/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 13:30:48 2025
/////////////////////////////////////////////////////////////


module dffr_DATA_WIDTH1_2 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module cdc_sync_STAGE2_DATA_WIDTH1_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;
  wire   s_sync_dat_0__0_;

  dffr_DATA_WIDTH1_2 genblk1_0__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(dat_i[0]), .dat_o(s_sync_dat_0__0_) );
  dffr_DATA_WIDTH1_1 genblk1_1__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(s_sync_dat_0__0_), .dat_o(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_8 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module edge_det_STAGE2_DATA_WIDTH1 ( clk_i, rst_n_i, dat_i, dat_o, re_o, fe_o
 );
  input [0:0] dat_i;
  output [0:0] dat_o;
  output [0:0] re_o;
  output [0:0] fe_o;
  input clk_i, rst_n_i;
  wire   \s_dat_d[0] ;

  sky130_fd_sc_hd__nor2b_1 U1 ( .B_N(\s_dat_d[0] ), .A(dat_o[0]), .Y(re_o[0])
         );
  sky130_fd_sc_hd__nor2b_1 U2 ( .B_N(dat_o[0]), .A(\s_dat_d[0] ), .Y(fe_o[0])
         );
  cdc_sync_STAGE2_DATA_WIDTH1_1 u_cdc_sync ( .clk_i(clk_i), .rst_n_i(rst_n_i), 
        .dat_i(dat_i[0]), .dat_o(\s_dat_d[0] ) );
  dffr_DATA_WIDTH1_8 u_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        \s_dat_d[0] ), .dat_o(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH4 ( clk_i, rst_n_i, dat_i, dat_o );
  input [3:0] dat_i;
  output [3:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffrc_20_00002 ( clk_i, rst_n_i, dat_i, dat_o );
  input [19:0] dat_i;
  output [19:0] dat_o;
  input clk_i, rst_n_i;


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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
endmodule


module dffr_DATA_WIDTH20 ( clk_i, rst_n_i, dat_i, dat_o );
  input [19:0] dat_i;
  output [19:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_4 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_4 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
endmodule


module dffr_DATA_WIDTH3 ( clk_i, rst_n_i, dat_i, dat_o );
  input [2:0] dat_i;
  output [2:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_7 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_dec_1 ( A, SUM );
  input [19:0] A;
  output [19:0] SUM;
  wire   n1, n3, n4, n5, n6, n7, n8, n9, n17, n18, n20, n21, n22, n24, n25,
         n27, n30, n31, n32, n33, n36, n37, n38, n41, n42, n43, n44, n48, n49,
         n50, n53, n54, n55, n57, n60, n61, n62, n65, n66, n67, n70, n72, n73,
         n75, n76, n77, n78, n79, n81, n82, n83, n85, n86, n87, n89, n91, n92,
         n93, n95, n96, n97, n98, n100, n104, n107, n153, n154, n155, n156,
         n157, n158, n159, n160, n161, n162, n163, n164, n165, n166, n167,
         n168, n169, n170, n171, n172, n173, n174, n175, n176, n177, n178,
         n179, n180, n181, n182, n183, n184, n185, n186, n187, n188;
  assign n1 = A[18];
  assign n3 = A[16];
  assign n4 = A[15];
  assign n5 = A[14];
  assign n6 = A[13];
  assign n7 = A[12];
  assign n8 = A[11];
  assign n9 = A[10];
  assign n17 = A[2];
  assign n18 = A[1];
  assign n25 = A[17];
  assign n70 = A[9];
  assign n73 = A[8];
  assign n79 = A[7];
  assign n83 = A[6];
  assign n89 = A[5];
  assign n93 = A[4];
  assign n98 = A[3];
  assign n107 = A[0];

  sky130_fd_sc_hd__nor2_1 U3 ( .A(n20), .B(n188), .Y(SUM[19]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n24), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n3), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__xnor2_1 U14 ( .A(n3), .B(n30), .Y(SUM[16]) );
  sky130_fd_sc_hd__xor2_1 U19 ( .A(n36), .B(n4), .X(SUM[15]) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(n43), .B(n33), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U23 ( .A(n4), .B(n5), .Y(n33) );
  sky130_fd_sc_hd__xor2_1 U27 ( .A(n41), .B(n5), .X(SUM[14]) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n37), .B(n75), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n38), .B(n55), .Y(n37) );
  sky130_fd_sc_hd__nor2_1 U30 ( .A(n5), .B(n44), .Y(n38) );
  sky130_fd_sc_hd__nor2_1 U35 ( .A(n42), .B(n75), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n55), .B(n43), .Y(n42) );
  sky130_fd_sc_hd__xor2_1 U43 ( .A(n53), .B(n7), .X(SUM[12]) );
  sky130_fd_sc_hd__nor2_1 U44 ( .A(n49), .B(n161), .Y(n48) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n55), .B(n50), .Y(n49) );
  sky130_fd_sc_hd__xor2_1 U50 ( .A(n60), .B(n8), .X(SUM[11]) );
  sky130_fd_sc_hd__nor2_1 U51 ( .A(n185), .B(n75), .Y(n53) );
  sky130_fd_sc_hd__xor2_1 U59 ( .A(n65), .B(n164), .X(SUM[10]) );
  sky130_fd_sc_hd__nor2_1 U60 ( .A(n61), .B(n161), .Y(n60) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n181), .B(n62), .Y(n61) );
  sky130_fd_sc_hd__xor2_1 U66 ( .A(n72), .B(n70), .X(SUM[9]) );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(n66), .B(n161), .Y(n65) );
  sky130_fd_sc_hd__xnor2_1 U75 ( .A(n161), .B(n73), .Y(SUM[8]) );
  sky130_fd_sc_hd__nor2_1 U76 ( .A(n73), .B(n75), .Y(n72) );
  sky130_fd_sc_hd__xnor2_1 U80 ( .A(n160), .B(n81), .Y(SUM[7]) );
  sky130_fd_sc_hd__nor2_1 U84 ( .A(n79), .B(n83), .Y(n78) );
  sky130_fd_sc_hd__xnor2_1 U88 ( .A(n158), .B(n85), .Y(SUM[6]) );
  sky130_fd_sc_hd__nand2_1 U89 ( .A(n95), .B(n82), .Y(n81) );
  sky130_fd_sc_hd__nor2_1 U90 ( .A(n158), .B(n87), .Y(n82) );
  sky130_fd_sc_hd__xnor2_1 U94 ( .A(n178), .B(n91), .Y(SUM[5]) );
  sky130_fd_sc_hd__nand2_1 U95 ( .A(n95), .B(n176), .Y(n85) );
  sky130_fd_sc_hd__xor2_1 U102 ( .A(n166), .B(n95), .X(SUM[4]) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n95), .B(n92), .Y(n91) );
  sky130_fd_sc_hd__xnor2_1 U115 ( .A(n17), .B(n179), .Y(SUM[2]) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(n25), .Y(n165) );
  sky130_fd_sc_hd__dlygate4sd1_1 U132 ( .A(n107), .X(n153) );
  sky130_fd_sc_hd__nor2_1 U133 ( .A(n77), .B(n96), .Y(n154) );
  sky130_fd_sc_hd__nor2_1 U134 ( .A(n77), .B(n156), .Y(n187) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(n177), .Y(n155) );
  sky130_fd_sc_hd__clkinv_1 U136 ( .A(n89), .Y(n177) );
  sky130_fd_sc_hd__nand2_1 U137 ( .A(n104), .B(n97), .Y(n156) );
  sky130_fd_sc_hd__nand2_1 U138 ( .A(n104), .B(n97), .Y(n96) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(n83), .Y(n157) );
  sky130_fd_sc_hd__inv_1 U140 ( .A(n157), .Y(n158) );
  sky130_fd_sc_hd__inv_1 U141 ( .A(n79), .Y(n159) );
  sky130_fd_sc_hd__inv_1 U142 ( .A(n159), .Y(n160) );
  sky130_fd_sc_hd__nor2_1 U143 ( .A(n89), .B(n93), .Y(n86) );
  sky130_fd_sc_hd__xnor2_1 U144 ( .A(n22), .B(n21), .Y(SUM[18]) );
  sky130_fd_sc_hd__inv_1 U145 ( .A(n154), .Y(n161) );
  sky130_fd_sc_hd__inv_1 U146 ( .A(n187), .Y(n75) );
  sky130_fd_sc_hd__nor2_1 U147 ( .A(n162), .B(n188), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U148 ( .A(n24), .Y(n162) );
  sky130_fd_sc_hd__inv_1 U149 ( .A(n172), .Y(n163) );
  sky130_fd_sc_hd__dlygate4sd1_1 U150 ( .A(n9), .X(n164) );
  sky130_fd_sc_hd__nor2_1 U151 ( .A(n77), .B(n96), .Y(n76) );
  sky130_fd_sc_hd__nor2_2 U152 ( .A(n18), .B(n107), .Y(n104) );
  sky130_fd_sc_hd__clkinv_1 U153 ( .A(n185), .Y(n55) );
  sky130_fd_sc_hd__nor2_1 U154 ( .A(n3), .B(n188), .Y(n27) );
  sky130_fd_sc_hd__xnor2_1 U155 ( .A(n27), .B(n165), .Y(SUM[17]) );
  sky130_fd_sc_hd__dlygate4sd1_1 U156 ( .A(n93), .X(n166) );
  sky130_fd_sc_hd__nand2_1 U157 ( .A(n48), .B(n168), .Y(n169) );
  sky130_fd_sc_hd__nand2_1 U158 ( .A(n167), .B(n6), .Y(n170) );
  sky130_fd_sc_hd__nand2_1 U159 ( .A(n169), .B(n170), .Y(SUM[13]) );
  sky130_fd_sc_hd__inv_1 U160 ( .A(n48), .Y(n167) );
  sky130_fd_sc_hd__inv_1 U161 ( .A(n6), .Y(n168) );
  sky130_fd_sc_hd__nor2_2 U162 ( .A(n98), .B(n17), .Y(n97) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U163 ( .A(n18), .X(n171) );
  sky130_fd_sc_hd__nand2_1 U164 ( .A(n173), .B(n163), .Y(n174) );
  sky130_fd_sc_hd__nand2_1 U165 ( .A(n100), .B(n172), .Y(n175) );
  sky130_fd_sc_hd__nand2_1 U166 ( .A(n174), .B(n175), .Y(SUM[3]) );
  sky130_fd_sc_hd__inv_1 U167 ( .A(n98), .Y(n172) );
  sky130_fd_sc_hd__inv_1 U168 ( .A(n100), .Y(n173) );
  sky130_fd_sc_hd__nand2_1 U169 ( .A(n86), .B(n78), .Y(n77) );
  sky130_fd_sc_hd__nor2_1 U170 ( .A(n155), .B(n93), .Y(n176) );
  sky130_fd_sc_hd__inv_1 U171 ( .A(n177), .Y(n178) );
  sky130_fd_sc_hd__nor2_2 U172 ( .A(n9), .B(n8), .Y(n57) );
  sky130_fd_sc_hd__or2_1 U173 ( .A(n107), .B(n18), .X(n179) );
  sky130_fd_sc_hd__inv_1 U174 ( .A(n156), .Y(n95) );
  sky130_fd_sc_hd__nor2_1 U175 ( .A(n70), .B(n73), .Y(n180) );
  sky130_fd_sc_hd__nor2_1 U176 ( .A(n70), .B(n73), .Y(n181) );
  sky130_fd_sc_hd__nor2_1 U177 ( .A(n70), .B(n73), .Y(n67) );
  sky130_fd_sc_hd__nor2_1 U178 ( .A(n107), .B(n18), .Y(n184) );
  sky130_fd_sc_hd__clkinv_1 U179 ( .A(n1), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U180 ( .A(n93), .Y(n92) );
  sky130_fd_sc_hd__xor2_1 U181 ( .A(n182), .B(n107), .X(SUM[1]) );
  sky130_fd_sc_hd__inv_1 U182 ( .A(n7), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U183 ( .A(n171), .Y(n182) );
  sky130_fd_sc_hd__inv_1 U184 ( .A(n184), .Y(n183) );
  sky130_fd_sc_hd__nor2_1 U185 ( .A(n17), .B(n183), .Y(n100) );
  sky130_fd_sc_hd__nand2_1 U186 ( .A(n67), .B(n57), .Y(n185) );
  sky130_fd_sc_hd__nand2_1 U187 ( .A(n180), .B(n57), .Y(n54) );
  sky130_fd_sc_hd__nor2_1 U188 ( .A(n185), .B(n32), .Y(n186) );
  sky130_fd_sc_hd__nor2_1 U189 ( .A(n54), .B(n32), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U190 ( .A(n164), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U191 ( .A(n76), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__inv_1 U192 ( .A(n153), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U193 ( .A(n180), .Y(n66) );
  sky130_fd_sc_hd__nand2_1 U194 ( .A(n76), .B(n186), .Y(n188) );
  sky130_fd_sc_hd__inv_1 U195 ( .A(n176), .Y(n87) );
  sky130_fd_sc_hd__inv_1 U196 ( .A(n43), .Y(n44) );
  sky130_fd_sc_hd__nor2_2 U197 ( .A(n6), .B(n7), .Y(n43) );
endmodule


module clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_inc_1 ( A, SUM );
  input [19:0] A;
  output [19:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n9, n10, n12, n13, n14, n15, n16, n18,
         n19, n20, n21, n23, n24, n25, n28, n30, n31, n33, n34, n35, n36, n37,
         n39, n40, n42, n43, n45, n46, n47, n48, n49, n52, n54, n55, n57, n58,
         n59, n60, n61, n63, n64, n66, n67, n68, n70, n72, n73, n74, n75, n76,
         n77, n80, n82, n83, n84, n86, n132;
  assign n7 = A[17];
  assign n10 = A[16];
  assign n16 = A[15];
  assign n21 = A[14];
  assign n28 = A[13];
  assign n33 = A[12];
  assign n40 = A[11];
  assign n45 = A[10];
  assign n52 = A[9];
  assign n55 = A[8];
  assign n61 = A[7];
  assign n64 = A[6];
  assign n68 = A[5];
  assign n72 = A[4];
  assign n77 = A[3];
  assign n80 = A[2];
  assign n84 = A[1];
  assign n86 = A[0];

  sky130_fd_sc_hd__xor2_1 U3 ( .A(n4), .B(n3), .X(SUM[18]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n12), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__nor2_1 U5 ( .A(n3), .B(n6), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U8 ( .A(n12), .B(n5), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U10 ( .A(n10), .B(n7), .Y(n6) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(n12), .B(n10), .Y(n9) );
  sky130_fd_sc_hd__nor2_1 U18 ( .A(n58), .B(n13), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(n36), .B(n14), .Y(n13) );
  sky130_fd_sc_hd__nor2_1 U20 ( .A(n15), .B(n25), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U21 ( .A(n21), .B(n16), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U25 ( .A(n19), .B(n57), .Y(n18) );
  sky130_fd_sc_hd__nor2_1 U26 ( .A(n20), .B(n37), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U31 ( .A(n24), .B(n57), .Y(n23) );
  sky130_fd_sc_hd__nor2_1 U32 ( .A(n25), .B(n37), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U35 ( .A(n33), .B(n28), .Y(n25) );
  sky130_fd_sc_hd__xor2_1 U38 ( .A(n35), .B(n34), .X(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U39 ( .A(n31), .B(n57), .Y(n30) );
  sky130_fd_sc_hd__nor2_1 U40 ( .A(n34), .B(n37), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n57), .B(n36), .Y(n35) );
  sky130_fd_sc_hd__nor2_1 U48 ( .A(n39), .B(n49), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n45), .B(n40), .Y(n39) );
  sky130_fd_sc_hd__xor2_1 U52 ( .A(n47), .B(n46), .X(SUM[10]) );
  sky130_fd_sc_hd__nand2_1 U53 ( .A(n57), .B(n43), .Y(n42) );
  sky130_fd_sc_hd__nor2_1 U54 ( .A(n46), .B(n49), .Y(n43) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n57), .B(n48), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U63 ( .A(n55), .B(n52), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U67 ( .A(n57), .B(n55), .Y(n54) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(n59), .B(n75), .Y(n58) );
  sky130_fd_sc_hd__nor2_1 U73 ( .A(n60), .B(n67), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U74 ( .A(n64), .B(n61), .Y(n60) );
  sky130_fd_sc_hd__nand2_1 U78 ( .A(n66), .B(n64), .Y(n63) );
  sky130_fd_sc_hd__nor2_1 U82 ( .A(n67), .B(n74), .Y(n66) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n72), .B(n68), .Y(n67) );
  sky130_fd_sc_hd__xor2_1 U86 ( .A(n74), .B(n73), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U87 ( .A(n73), .B(n74), .Y(n70) );
  sky130_fd_sc_hd__nor2_1 U93 ( .A(n83), .B(n76), .Y(n75) );
  sky130_fd_sc_hd__nand2_1 U94 ( .A(n80), .B(n77), .Y(n76) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n84), .B(n86), .Y(n83) );
  sky130_fd_sc_hd__xor2_1 U110 ( .A(n132), .B(n77), .X(SUM[3]) );
  sky130_fd_sc_hd__and2_1 U111 ( .A(n82), .B(n80), .X(n132) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(n49), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U113 ( .A(n6), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(n75), .Y(n74) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(n58), .Y(n57) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(n36), .Y(n37) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(n83), .Y(n82) );
  sky130_fd_sc_hd__xor2_1 U118 ( .A(n86), .B(n84), .X(SUM[1]) );
  sky130_fd_sc_hd__xor2_1 U119 ( .A(n80), .B(n82), .X(SUM[2]) );
  sky130_fd_sc_hd__xor2_1 U120 ( .A(n55), .B(n57), .X(SUM[8]) );
  sky130_fd_sc_hd__xnor2_1 U121 ( .A(n63), .B(n61), .Y(SUM[7]) );
  sky130_fd_sc_hd__xnor2_1 U122 ( .A(n54), .B(n52), .Y(SUM[9]) );
  sky130_fd_sc_hd__inv_1 U123 ( .A(n86), .Y(SUM[0]) );
  sky130_fd_sc_hd__xor2_1 U124 ( .A(n10), .B(n12), .X(SUM[16]) );
  sky130_fd_sc_hd__xnor2_1 U125 ( .A(A[19]), .B(n1), .Y(SUM[19]) );
  sky130_fd_sc_hd__xnor2_1 U126 ( .A(n9), .B(n7), .Y(SUM[17]) );
  sky130_fd_sc_hd__xnor2_1 U127 ( .A(n30), .B(n28), .Y(SUM[13]) );
  sky130_fd_sc_hd__xnor2_1 U128 ( .A(n23), .B(n21), .Y(SUM[14]) );
  sky130_fd_sc_hd__xnor2_1 U129 ( .A(n18), .B(n16), .Y(SUM[15]) );
  sky130_fd_sc_hd__xnor2_1 U130 ( .A(n42), .B(n40), .Y(SUM[11]) );
  sky130_fd_sc_hd__xor2_1 U131 ( .A(n64), .B(n66), .X(SUM[6]) );
  sky130_fd_sc_hd__xor2_1 U132 ( .A(n68), .B(n70), .X(SUM[5]) );
  sky130_fd_sc_hd__nand2b_1 U133 ( .A_N(n25), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(n45), .Y(n46) );
  sky130_fd_sc_hd__inv_2 U135 ( .A(n33), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U136 ( .A(A[18]), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U137 ( .A(n72), .Y(n73) );
endmodule


module clk_int_even_div_simple_DIV_VALUE_WIDTH20 ( clk_i, rst_n_i, div_i, 
        div_valid_i, div_ready_o, div_done_o, clk_o );
  input [19:0] div_i;
  input clk_i, rst_n_i, div_valid_i;
  output div_ready_o, div_done_o, clk_o;
  wire   N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16,
         N17, N18, N19, N20, N21, N22, N23, N24, N25, N26, N27, N28, N29, N30,
         N31, N32, N33, N34, N35, N36, N37, N38, N39, N40, N41, s_clk_d, n1,
         n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73,
         n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87,
         n88;
  wire   [19:0] s_cnt_q;
  wire   [19:0] s_cnt_d;
  wire   [2:0] s_div_done_q;
  wire   [2:0] s_div_done_d;

  dffr_DATA_WIDTH20 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_cnt_d), .dat_o(s_cnt_q) );
  dffr_DATA_WIDTH3 u_ready_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i({
        n88, s_div_done_d[1:0]}), .dat_o(s_div_done_q) );
  dffr_DATA_WIDTH1_7 u_clk_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_clk_d), .dat_o(clk_o) );
  clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_dec_1 r378 ( .A({n1, 
        div_i[19:1]}), .SUM({N41, N40, N39, N38, N37, N36, N35, N34, N33, N32, 
        N31, N30, N29, N28, N27, N26, N25, N24, N23, N22}) );
  clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_inc_1 add_160 ( .A(s_cnt_q), 
        .SUM({N21, N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, 
        N8, N7, N6, N5, N4, N3, N2}) );
  sky130_fd_sc_hd__o21ai_0 U3 ( .A1(div_valid_i), .A2(n80), .B1(n79), .Y(n88)
         );
  sky130_fd_sc_hd__inv_1 U4 ( .A(n76), .Y(n2) );
  sky130_fd_sc_hd__inv_1 U5 ( .A(n76), .Y(n87) );
  sky130_fd_sc_hd__nand3b_1 U6 ( .A_N(n64), .B(n52), .C(n53), .Y(n3) );
  sky130_fd_sc_hd__nor2b_1 U7 ( .B_N(n86), .A(n4), .Y(s_cnt_d[1]) );
  sky130_fd_sc_hd__clkinv_16 U8 ( .A(N3), .Y(n4) );
  sky130_fd_sc_hd__nor2b_1 U9 ( .B_N(n86), .A(n5), .Y(s_cnt_d[8]) );
  sky130_fd_sc_hd__clkinv_16 U10 ( .A(N10), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U11 ( .A(n71), .B(n72), .Y(n6) );
  sky130_fd_sc_hd__nor2_1 U12 ( .A(n71), .B(n72), .Y(n81) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(N24), .B(s_cnt_q[2]), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(n7), .B(n8), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(n9), .B(n10), .Y(n59) );
  sky130_fd_sc_hd__inv_1 U16 ( .A(N24), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(s_cnt_q[2]), .Y(n8) );
  sky130_fd_sc_hd__and2_1 U18 ( .A(n86), .B(N11), .X(s_cnt_d[9]) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(s_cnt_q[15]), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(s_cnt_q[14]), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(s_cnt_q[3]), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(s_cnt_q[18]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(s_cnt_q[5]), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(div_valid_i), .Y(n84) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(clk_o), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U26 ( .A(n83), .Y(n35) );
  sky130_fd_sc_hd__xnor2_1 U27 ( .A(n11), .B(n2), .Y(s_clk_d) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(N8), .Y(n12) );
  sky130_fd_sc_hd__nor2b_1 U29 ( .B_N(n35), .A(n12), .Y(s_cnt_d[6]) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(N37), .Y(n27) );
  sky130_fd_sc_hd__nand3_1 U31 ( .A(n31), .B(n25), .C(n62), .Y(n13) );
  sky130_fd_sc_hd__nand3_1 U32 ( .A(n31), .B(n25), .C(n62), .Y(n63) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(N36), .Y(n16) );
  sky130_fd_sc_hd__xnor2_1 U34 ( .A(n14), .B(N40), .Y(n64) );
  sky130_fd_sc_hd__nand2_1 U35 ( .A(N36), .B(s_cnt_q[14]), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n16), .B(n15), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U37 ( .A(n17), .B(n18), .Y(n67) );
  sky130_fd_sc_hd__nor2_1 U38 ( .A(n19), .B(n20), .Y(n25) );
  sky130_fd_sc_hd__xor2_1 U39 ( .A(s_cnt_q[8]), .B(N30), .X(n19) );
  sky130_fd_sc_hd__xor2_1 U40 ( .A(s_cnt_q[7]), .B(N29), .X(n20) );
  sky130_fd_sc_hd__nand2_1 U41 ( .A(N38), .B(s_cnt_q[16]), .Y(n23) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(n21), .B(n22), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(n23), .B(n24), .Y(n47) );
  sky130_fd_sc_hd__inv_2 U44 ( .A(s_cnt_q[16]), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(N38), .Y(n22) );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(N37), .B(s_cnt_q[15]), .Y(n28) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(n27), .B(n26), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(n28), .B(n29), .Y(n68) );
  sky130_fd_sc_hd__nand4_1 U49 ( .A(n56), .B(n59), .C(n58), .D(n57), .Y(n30)
         );
  sky130_fd_sc_hd__inv_1 U50 ( .A(n30), .Y(n49) );
  sky130_fd_sc_hd__inv_1 U51 ( .A(n33), .Y(n31) );
  sky130_fd_sc_hd__nand3b_1 U52 ( .A_N(n64), .B(n52), .C(n53), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U53 ( .A(n85), .B(n84), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U54 ( .A(n32), .Y(n86) );
  sky130_fd_sc_hd__nand4_1 U55 ( .A(n49), .B(n47), .C(n50), .D(n48), .Y(n33)
         );
  sky130_fd_sc_hd__nor2_1 U56 ( .A(n61), .B(n60), .Y(n62) );
  sky130_fd_sc_hd__xnor2_1 U57 ( .A(n34), .B(N27), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U58 ( .A(N25), .Y(n37) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(N25), .B(s_cnt_q[3]), .Y(n38) );
  sky130_fd_sc_hd__nand2_1 U60 ( .A(n37), .B(n36), .Y(n39) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n38), .B(n39), .Y(n56) );
  sky130_fd_sc_hd__nand2_1 U62 ( .A(N39), .B(s_cnt_q[17]), .Y(n42) );
  sky130_fd_sc_hd__nand2_1 U63 ( .A(n40), .B(n41), .Y(n43) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n43), .B(n42), .Y(n53) );
  sky130_fd_sc_hd__inv_1 U65 ( .A(s_cnt_q[17]), .Y(n40) );
  sky130_fd_sc_hd__inv_1 U66 ( .A(N39), .Y(n41) );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(n63), .B(n45), .Y(n44) );
  sky130_fd_sc_hd__nor2_1 U68 ( .A(n13), .B(n3), .Y(n82) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(N41), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U70 ( .A(s_cnt_q[19]), .Y(n54) );
  sky130_fd_sc_hd__nand2b_1 U71 ( .A_N(s_div_done_q[0]), .B(n84), .Y(n73) );
  sky130_fd_sc_hd__and3_1 U72 ( .A(s_div_done_q[1]), .B(s_div_done_q[2]), .C(
        s_div_done_q[0]), .X(div_done_o) );
  sky130_fd_sc_hd__conb_1 U73 ( .LO(n1), .HI(div_ready_o) );
  sky130_fd_sc_hd__and2_0 U74 ( .A(n55), .B(n54), .X(n48) );
  sky130_fd_sc_hd__xnor2_1 U75 ( .A(s_cnt_q[4]), .B(N26), .Y(n50) );
  sky130_fd_sc_hd__and2_1 U76 ( .A(n86), .B(N20), .X(s_cnt_d[18]) );
  sky130_fd_sc_hd__and2_1 U77 ( .A(n35), .B(N12), .X(s_cnt_d[10]) );
  sky130_fd_sc_hd__and2_1 U78 ( .A(n86), .B(N13), .X(s_cnt_d[11]) );
  sky130_fd_sc_hd__and2_1 U79 ( .A(n86), .B(N14), .X(s_cnt_d[12]) );
  sky130_fd_sc_hd__and2_1 U80 ( .A(n86), .B(N17), .X(s_cnt_d[15]) );
  sky130_fd_sc_hd__and2_1 U81 ( .A(n35), .B(N15), .X(s_cnt_d[13]) );
  sky130_fd_sc_hd__and2_1 U82 ( .A(n35), .B(N16), .X(s_cnt_d[14]) );
  sky130_fd_sc_hd__and2_1 U83 ( .A(n35), .B(N19), .X(s_cnt_d[17]) );
  sky130_fd_sc_hd__and2_1 U84 ( .A(n86), .B(N21), .X(s_cnt_d[19]) );
  sky130_fd_sc_hd__and2_1 U85 ( .A(n35), .B(N18), .X(s_cnt_d[16]) );
  sky130_fd_sc_hd__and2_1 U86 ( .A(n86), .B(N4), .X(s_cnt_d[2]) );
  sky130_fd_sc_hd__and2_1 U87 ( .A(n35), .B(N2), .X(s_cnt_d[0]) );
  sky130_fd_sc_hd__and2_1 U88 ( .A(n86), .B(N9), .X(s_cnt_d[7]) );
  sky130_fd_sc_hd__and2_1 U89 ( .A(n35), .B(N7), .X(s_cnt_d[5]) );
  sky130_fd_sc_hd__and2_1 U90 ( .A(n35), .B(N5), .X(s_cnt_d[3]) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(n87), .Y(n51) );
  sky130_fd_sc_hd__and2_1 U92 ( .A(n35), .B(N6), .X(s_cnt_d[4]) );
  sky130_fd_sc_hd__xnor2_1 U93 ( .A(s_cnt_q[13]), .B(N35), .Y(n52) );
  sky130_fd_sc_hd__xnor2_1 U94 ( .A(s_cnt_q[0]), .B(N22), .Y(n58) );
  sky130_fd_sc_hd__xnor2_1 U95 ( .A(s_cnt_q[1]), .B(N23), .Y(n57) );
  sky130_fd_sc_hd__xor2_1 U96 ( .A(s_cnt_q[6]), .B(N28), .X(n60) );
  sky130_fd_sc_hd__xnor2_1 U97 ( .A(s_cnt_q[12]), .B(N34), .Y(n66) );
  sky130_fd_sc_hd__xnor2_1 U98 ( .A(s_cnt_q[9]), .B(N31), .Y(n65) );
  sky130_fd_sc_hd__nand4_1 U99 ( .A(n65), .B(n66), .C(n67), .D(n68), .Y(n72)
         );
  sky130_fd_sc_hd__xnor2_1 U100 ( .A(s_cnt_q[10]), .B(N32), .Y(n70) );
  sky130_fd_sc_hd__xnor2_1 U101 ( .A(s_cnt_q[11]), .B(N33), .Y(n69) );
  sky130_fd_sc_hd__nand2_1 U102 ( .A(n70), .B(n69), .Y(n71) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n82), .B(n81), .Y(n76) );
  sky130_fd_sc_hd__nand2_1 U104 ( .A(s_div_done_q[0]), .B(n84), .Y(n74) );
  sky130_fd_sc_hd__nand2_1 U105 ( .A(div_done_o), .B(n84), .Y(n77) );
  sky130_fd_sc_hd__o221ai_1 U106 ( .A1(n87), .A2(n74), .B1(n73), .B2(n51), 
        .C1(n77), .Y(s_div_done_d[0]) );
  sky130_fd_sc_hd__mux2i_1 U107 ( .A0(n74), .A1(n73), .S(s_div_done_q[1]), .Y(
        n75) );
  sky130_fd_sc_hd__a32oi_1 U108 ( .A1(n76), .A2(n84), .A3(s_div_done_q[1]), 
        .B1(n87), .B2(n75), .Y(n78) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(n78), .B(n77), .Y(s_div_done_d[1]) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(s_div_done_q[2]), .Y(n80) );
  sky130_fd_sc_hd__nand4_1 U111 ( .A(n2), .B(s_div_done_q[1]), .C(n84), .D(
        s_div_done_q[0]), .Y(n79) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(n44), .B(n6), .Y(n85) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(n85), .B(n84), .Y(n83) );
endmodule


module dffr_DATA_WIDTH1_6 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_5 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module cdc_sync_det_STAGE2_DATA_WIDTH1 ( clk_i, rst_n_i, dat_i, dat_pre_o, 
        dat_o );
  input [0:0] dat_i;
  output [0:0] dat_pre_o;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  dffr_DATA_WIDTH1_6 genblk1_0__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(dat_i[0]), .dat_o(dat_pre_o[0]) );
  dffr_DATA_WIDTH1_5 genblk1_1__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(dat_pre_o[0]), .dat_o(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH33 ( clk_i, rst_n_i, dat_i, dat_o );
  input [32:0] dat_i;
  output [32:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(n1), .RESET_B(
        rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(n2), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(n3), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(n3), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(n3), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(n3), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(n3), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(clk_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(clk_i), .X(n1) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(clk_i), .X(n3) );
endmodule


module delta_counter_DATA_WIDTH32_DW01_add_0 ( A, B, CI, SUM, CO );
  input [32:0] A;
  input [32:0] B;
  output [32:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [32:1] carry;

  sky130_fd_sc_hd__fa_1 U1_1 ( .A(A[1]), .B(B[1]), .CIN(n1), .COUT(carry[2]), 
        .SUM(SUM[1]) );
  sky130_fd_sc_hd__fa_1 U1_30 ( .A(A[30]), .B(B[30]), .CIN(carry[30]), .COUT(
        carry[31]), .SUM(SUM[30]) );
  sky130_fd_sc_hd__fa_1 U1_29 ( .A(A[29]), .B(B[29]), .CIN(carry[29]), .COUT(
        carry[30]), .SUM(SUM[29]) );
  sky130_fd_sc_hd__fa_1 U1_28 ( .A(A[28]), .B(B[28]), .CIN(carry[28]), .COUT(
        carry[29]), .SUM(SUM[28]) );
  sky130_fd_sc_hd__fa_1 U1_27 ( .A(A[27]), .B(B[27]), .CIN(carry[27]), .COUT(
        carry[28]), .SUM(SUM[27]) );
  sky130_fd_sc_hd__fa_1 U1_26 ( .A(A[26]), .B(B[26]), .CIN(carry[26]), .COUT(
        carry[27]), .SUM(SUM[26]) );
  sky130_fd_sc_hd__fa_1 U1_25 ( .A(A[25]), .B(B[25]), .CIN(carry[25]), .COUT(
        carry[26]), .SUM(SUM[25]) );
  sky130_fd_sc_hd__fa_1 U1_24 ( .A(A[24]), .B(B[24]), .CIN(carry[24]), .COUT(
        carry[25]), .SUM(SUM[24]) );
  sky130_fd_sc_hd__fa_1 U1_23 ( .A(A[23]), .B(B[23]), .CIN(carry[23]), .COUT(
        carry[24]), .SUM(SUM[23]) );
  sky130_fd_sc_hd__fa_1 U1_22 ( .A(A[22]), .B(B[22]), .CIN(carry[22]), .COUT(
        carry[23]), .SUM(SUM[22]) );
  sky130_fd_sc_hd__fa_1 U1_21 ( .A(A[21]), .B(B[21]), .CIN(carry[21]), .COUT(
        carry[22]), .SUM(SUM[21]) );
  sky130_fd_sc_hd__fa_1 U1_20 ( .A(A[20]), .B(B[20]), .CIN(carry[20]), .COUT(
        carry[21]), .SUM(SUM[20]) );
  sky130_fd_sc_hd__fa_1 U1_19 ( .A(A[19]), .B(B[19]), .CIN(carry[19]), .COUT(
        carry[20]), .SUM(SUM[19]) );
  sky130_fd_sc_hd__fa_1 U1_18 ( .A(A[18]), .B(B[18]), .CIN(carry[18]), .COUT(
        carry[19]), .SUM(SUM[18]) );
  sky130_fd_sc_hd__fa_1 U1_17 ( .A(A[17]), .B(B[17]), .CIN(carry[17]), .COUT(
        carry[18]), .SUM(SUM[17]) );
  sky130_fd_sc_hd__fa_1 U1_16 ( .A(A[16]), .B(B[16]), .CIN(carry[16]), .COUT(
        carry[17]), .SUM(SUM[16]) );
  sky130_fd_sc_hd__fa_1 U1_15 ( .A(A[15]), .B(B[15]), .CIN(carry[15]), .COUT(
        carry[16]), .SUM(SUM[15]) );
  sky130_fd_sc_hd__fa_1 U1_14 ( .A(A[14]), .B(B[14]), .CIN(carry[14]), .COUT(
        carry[15]), .SUM(SUM[14]) );
  sky130_fd_sc_hd__fa_1 U1_13 ( .A(A[13]), .B(B[13]), .CIN(carry[13]), .COUT(
        carry[14]), .SUM(SUM[13]) );
  sky130_fd_sc_hd__fa_1 U1_12 ( .A(A[12]), .B(B[12]), .CIN(carry[12]), .COUT(
        carry[13]), .SUM(SUM[12]) );
  sky130_fd_sc_hd__fa_1 U1_11 ( .A(A[11]), .B(B[11]), .CIN(carry[11]), .COUT(
        carry[12]), .SUM(SUM[11]) );
  sky130_fd_sc_hd__fa_1 U1_10 ( .A(A[10]), .B(B[10]), .CIN(carry[10]), .COUT(
        carry[11]), .SUM(SUM[10]) );
  sky130_fd_sc_hd__fa_1 U1_9 ( .A(A[9]), .B(B[9]), .CIN(carry[9]), .COUT(
        carry[10]), .SUM(SUM[9]) );
  sky130_fd_sc_hd__fa_1 U1_8 ( .A(A[8]), .B(B[8]), .CIN(carry[8]), .COUT(
        carry[9]), .SUM(SUM[8]) );
  sky130_fd_sc_hd__fa_1 U1_7 ( .A(A[7]), .B(B[7]), .CIN(carry[7]), .COUT(
        carry[8]), .SUM(SUM[7]) );
  sky130_fd_sc_hd__fa_1 U1_6 ( .A(A[6]), .B(B[6]), .CIN(carry[6]), .COUT(
        carry[7]), .SUM(SUM[6]) );
  sky130_fd_sc_hd__fa_1 U1_5 ( .A(A[5]), .B(B[5]), .CIN(carry[5]), .COUT(
        carry[6]), .SUM(SUM[5]) );
  sky130_fd_sc_hd__fa_1 U1_4 ( .A(A[4]), .B(B[4]), .CIN(carry[4]), .COUT(
        carry[5]), .SUM(SUM[4]) );
  sky130_fd_sc_hd__fa_1 U1_3 ( .A(A[3]), .B(B[3]), .CIN(carry[3]), .COUT(
        carry[4]), .SUM(SUM[3]) );
  sky130_fd_sc_hd__fa_1 U1_2 ( .A(A[2]), .B(B[2]), .CIN(carry[2]), .COUT(
        carry[3]), .SUM(SUM[2]) );
  sky130_fd_sc_hd__fa_1 U1_31 ( .A(A[31]), .B(B[31]), .CIN(carry[31]), .COUT(
        carry[32]), .SUM(SUM[31]) );
  sky130_fd_sc_hd__and2_1 U1 ( .A(B[0]), .B(A[0]), .X(n1) );
  sky130_fd_sc_hd__xor2_1 U2 ( .A(A[32]), .B(carry[32]), .X(SUM[32]) );
  sky130_fd_sc_hd__xor2_1 U3 ( .A(B[0]), .B(A[0]), .X(SUM[0]) );
endmodule


module delta_counter_DATA_WIDTH32_DW01_sub_0 ( A, B, CI, DIFF, CO );
  input [32:0] A;
  input [32:0] B;
  output [32:0] DIFF;
  input CI;
  output CO;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33;
  wire   [33:0] carry;

  sky130_fd_sc_hd__fa_1 U2_1 ( .A(A[1]), .B(n3), .CIN(carry[1]), .COUT(
        carry[2]), .SUM(DIFF[1]) );
  sky130_fd_sc_hd__fa_1 U2_30 ( .A(A[30]), .B(n32), .CIN(carry[30]), .COUT(
        carry[31]), .SUM(DIFF[30]) );
  sky130_fd_sc_hd__fa_1 U2_29 ( .A(A[29]), .B(n31), .CIN(carry[29]), .COUT(
        carry[30]), .SUM(DIFF[29]) );
  sky130_fd_sc_hd__fa_1 U2_28 ( .A(A[28]), .B(n30), .CIN(carry[28]), .COUT(
        carry[29]), .SUM(DIFF[28]) );
  sky130_fd_sc_hd__fa_1 U2_27 ( .A(A[27]), .B(n29), .CIN(carry[27]), .COUT(
        carry[28]), .SUM(DIFF[27]) );
  sky130_fd_sc_hd__fa_1 U2_26 ( .A(A[26]), .B(n28), .CIN(carry[26]), .COUT(
        carry[27]), .SUM(DIFF[26]) );
  sky130_fd_sc_hd__fa_1 U2_25 ( .A(A[25]), .B(n27), .CIN(carry[25]), .COUT(
        carry[26]), .SUM(DIFF[25]) );
  sky130_fd_sc_hd__fa_1 U2_24 ( .A(A[24]), .B(n26), .CIN(carry[24]), .COUT(
        carry[25]), .SUM(DIFF[24]) );
  sky130_fd_sc_hd__fa_1 U2_23 ( .A(A[23]), .B(n25), .CIN(carry[23]), .COUT(
        carry[24]), .SUM(DIFF[23]) );
  sky130_fd_sc_hd__fa_1 U2_22 ( .A(A[22]), .B(n24), .CIN(carry[22]), .COUT(
        carry[23]), .SUM(DIFF[22]) );
  sky130_fd_sc_hd__fa_1 U2_21 ( .A(A[21]), .B(n23), .CIN(carry[21]), .COUT(
        carry[22]), .SUM(DIFF[21]) );
  sky130_fd_sc_hd__fa_1 U2_20 ( .A(A[20]), .B(n22), .CIN(carry[20]), .COUT(
        carry[21]), .SUM(DIFF[20]) );
  sky130_fd_sc_hd__fa_1 U2_19 ( .A(A[19]), .B(n21), .CIN(carry[19]), .COUT(
        carry[20]), .SUM(DIFF[19]) );
  sky130_fd_sc_hd__fa_1 U2_18 ( .A(A[18]), .B(n20), .CIN(carry[18]), .COUT(
        carry[19]), .SUM(DIFF[18]) );
  sky130_fd_sc_hd__fa_1 U2_17 ( .A(A[17]), .B(n19), .CIN(carry[17]), .COUT(
        carry[18]), .SUM(DIFF[17]) );
  sky130_fd_sc_hd__fa_1 U2_16 ( .A(A[16]), .B(n18), .CIN(carry[16]), .COUT(
        carry[17]), .SUM(DIFF[16]) );
  sky130_fd_sc_hd__fa_1 U2_15 ( .A(A[15]), .B(n17), .CIN(carry[15]), .COUT(
        carry[16]), .SUM(DIFF[15]) );
  sky130_fd_sc_hd__fa_1 U2_14 ( .A(A[14]), .B(n16), .CIN(carry[14]), .COUT(
        carry[15]), .SUM(DIFF[14]) );
  sky130_fd_sc_hd__fa_1 U2_13 ( .A(A[13]), .B(n15), .CIN(carry[13]), .COUT(
        carry[14]), .SUM(DIFF[13]) );
  sky130_fd_sc_hd__fa_1 U2_12 ( .A(A[12]), .B(n14), .CIN(carry[12]), .COUT(
        carry[13]), .SUM(DIFF[12]) );
  sky130_fd_sc_hd__fa_1 U2_11 ( .A(A[11]), .B(n13), .CIN(carry[11]), .COUT(
        carry[12]), .SUM(DIFF[11]) );
  sky130_fd_sc_hd__fa_1 U2_10 ( .A(A[10]), .B(n12), .CIN(carry[10]), .COUT(
        carry[11]), .SUM(DIFF[10]) );
  sky130_fd_sc_hd__fa_1 U2_9 ( .A(A[9]), .B(n11), .CIN(carry[9]), .COUT(
        carry[10]), .SUM(DIFF[9]) );
  sky130_fd_sc_hd__fa_1 U2_8 ( .A(A[8]), .B(n10), .CIN(carry[8]), .COUT(
        carry[9]), .SUM(DIFF[8]) );
  sky130_fd_sc_hd__fa_1 U2_7 ( .A(A[7]), .B(n9), .CIN(carry[7]), .COUT(
        carry[8]), .SUM(DIFF[7]) );
  sky130_fd_sc_hd__fa_1 U2_6 ( .A(A[6]), .B(n8), .CIN(carry[6]), .COUT(
        carry[7]), .SUM(DIFF[6]) );
  sky130_fd_sc_hd__fa_1 U2_5 ( .A(A[5]), .B(n7), .CIN(carry[5]), .COUT(
        carry[6]), .SUM(DIFF[5]) );
  sky130_fd_sc_hd__fa_1 U2_4 ( .A(A[4]), .B(n6), .CIN(carry[4]), .COUT(
        carry[5]), .SUM(DIFF[4]) );
  sky130_fd_sc_hd__fa_1 U2_3 ( .A(A[3]), .B(n5), .CIN(carry[3]), .COUT(
        carry[4]), .SUM(DIFF[3]) );
  sky130_fd_sc_hd__fa_1 U2_2 ( .A(A[2]), .B(n4), .CIN(carry[2]), .COUT(
        carry[3]), .SUM(DIFF[2]) );
  sky130_fd_sc_hd__fa_1 U2_31 ( .A(A[31]), .B(n33), .CIN(carry[31]), .COUT(
        carry[32]), .SUM(DIFF[31]) );
  sky130_fd_sc_hd__inv_2 U1 ( .A(B[31]), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U2 ( .A(B[2]), .Y(n4) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(B[3]), .Y(n5) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(B[4]), .Y(n6) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(B[5]), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(B[6]), .Y(n8) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(B[7]), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(B[8]), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(B[9]), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(B[10]), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(B[11]), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(B[12]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(B[13]), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(B[14]), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(B[15]), .Y(n17) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(B[16]), .Y(n18) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(B[17]), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(B[18]), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(B[19]), .Y(n21) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(B[20]), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(B[21]), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(B[22]), .Y(n24) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(B[23]), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(B[24]), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(B[25]), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U26 ( .A(B[26]), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(B[27]), .Y(n29) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(B[28]), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U29 ( .A(B[29]), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(B[30]), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(B[1]), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(A[0]), .Y(n1) );
  sky130_fd_sc_hd__inv_2 U33 ( .A(B[0]), .Y(n2) );
  sky130_fd_sc_hd__xnor2_1 U34 ( .A(A[32]), .B(carry[32]), .Y(DIFF[32]) );
  sky130_fd_sc_hd__nand2_1 U35 ( .A(B[0]), .B(n1), .Y(carry[1]) );
  sky130_fd_sc_hd__xnor2_1 U36 ( .A(n2), .B(A[0]), .Y(DIFF[0]) );
endmodule


module delta_counter_DATA_WIDTH32 ( clk_i, rst_n_i, clr_i, en_i, load_i, 
        down_i, delta_i, dat_i, dat_o, ovf_o );
  input [31:0] delta_i;
  input [31:0] dat_i;
  output [31:0] dat_o;
  input clk_i, rst_n_i, clr_i, en_i, load_i, down_i;
  output ovf_o;
  wire   N8, N9, N10, N11, N12, N13, N14, N15, N16, N17, N18, N19, N20, N21,
         N22, N23, N24, N25, N26, N27, N28, N29, N30, N31, N32, N33, N34, N35,
         N36, N37, N38, N39, N40, N41, N42, N43, N44, N45, N46, N47, N48, N49,
         N50, N51, N52, N53, N54, N55, N56, N57, N58, N59, N60, N61, N62, N63,
         N64, N65, N66, N67, N68, N69, N70, N71, N72, N73, n6, n8, n9, n10,
         n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n43, n44, n45, n1, n2, n3, n4, n5, n7, n46, n47,
         n48, n49, n50, n51, n52;
  wire   [32:0] s_cnt_d;

  sky130_fd_sc_hd__a221o_1 U9 ( .A1(dat_o[9]), .A2(n49), .B1(dat_i[9]), .B2(
        n48), .C1(n10), .X(s_cnt_d[9]) );
  sky130_fd_sc_hd__a22o_1 U10 ( .A1(N17), .A2(n4), .B1(N50), .B2(n2), .X(n10)
         );
  sky130_fd_sc_hd__a221o_1 U11 ( .A1(dat_o[8]), .A2(n51), .B1(dat_i[8]), .B2(
        n48), .C1(n13), .X(s_cnt_d[8]) );
  sky130_fd_sc_hd__a22o_1 U12 ( .A1(N16), .A2(n7), .B1(N49), .B2(n1), .X(n13)
         );
  sky130_fd_sc_hd__a221o_1 U13 ( .A1(dat_o[7]), .A2(n51), .B1(dat_i[7]), .B2(
        n48), .C1(n14), .X(s_cnt_d[7]) );
  sky130_fd_sc_hd__a22o_1 U14 ( .A1(N15), .A2(n7), .B1(N48), .B2(n1), .X(n14)
         );
  sky130_fd_sc_hd__a221o_1 U15 ( .A1(dat_o[6]), .A2(n51), .B1(dat_i[6]), .B2(
        n48), .C1(n15), .X(s_cnt_d[6]) );
  sky130_fd_sc_hd__a22o_1 U16 ( .A1(N14), .A2(n7), .B1(N47), .B2(n1), .X(n15)
         );
  sky130_fd_sc_hd__a221o_1 U17 ( .A1(dat_o[5]), .A2(n51), .B1(dat_i[5]), .B2(
        n48), .C1(n16), .X(s_cnt_d[5]) );
  sky130_fd_sc_hd__a22o_1 U18 ( .A1(N13), .A2(n7), .B1(N46), .B2(n1), .X(n16)
         );
  sky130_fd_sc_hd__a221o_1 U19 ( .A1(dat_o[4]), .A2(n51), .B1(dat_i[4]), .B2(
        n48), .C1(n17), .X(s_cnt_d[4]) );
  sky130_fd_sc_hd__a22o_1 U20 ( .A1(N12), .A2(n7), .B1(N45), .B2(n1), .X(n17)
         );
  sky130_fd_sc_hd__a221o_1 U21 ( .A1(dat_o[3]), .A2(n51), .B1(dat_i[3]), .B2(
        n47), .C1(n18), .X(s_cnt_d[3]) );
  sky130_fd_sc_hd__a22o_1 U22 ( .A1(N11), .A2(n7), .B1(N44), .B2(n1), .X(n18)
         );
  sky130_fd_sc_hd__a222oi_1 U23 ( .A1(ovf_o), .A2(n51), .B1(N73), .B2(n3), 
        .C1(N40), .C2(n7), .Y(n19) );
  sky130_fd_sc_hd__a221o_1 U24 ( .A1(dat_o[31]), .A2(n50), .B1(dat_i[31]), 
        .B2(n47), .C1(n20), .X(s_cnt_d[31]) );
  sky130_fd_sc_hd__a22o_1 U25 ( .A1(N39), .A2(n5), .B1(N72), .B2(n1), .X(n20)
         );
  sky130_fd_sc_hd__a221o_1 U26 ( .A1(dat_o[30]), .A2(n50), .B1(dat_i[30]), 
        .B2(n47), .C1(n21), .X(s_cnt_d[30]) );
  sky130_fd_sc_hd__a22o_1 U27 ( .A1(N38), .A2(n5), .B1(N71), .B2(n1), .X(n21)
         );
  sky130_fd_sc_hd__a221o_1 U28 ( .A1(dat_o[2]), .A2(n50), .B1(dat_i[2]), .B2(
        n47), .C1(n22), .X(s_cnt_d[2]) );
  sky130_fd_sc_hd__a22o_1 U29 ( .A1(N10), .A2(n5), .B1(N43), .B2(n1), .X(n22)
         );
  sky130_fd_sc_hd__a221o_1 U30 ( .A1(dat_o[29]), .A2(n50), .B1(dat_i[29]), 
        .B2(n47), .C1(n23), .X(s_cnt_d[29]) );
  sky130_fd_sc_hd__a22o_1 U31 ( .A1(N37), .A2(n5), .B1(N70), .B2(n1), .X(n23)
         );
  sky130_fd_sc_hd__a221o_1 U32 ( .A1(dat_o[28]), .A2(n50), .B1(dat_i[28]), 
        .B2(n47), .C1(n24), .X(s_cnt_d[28]) );
  sky130_fd_sc_hd__a22o_1 U33 ( .A1(N36), .A2(n5), .B1(N69), .B2(n1), .X(n24)
         );
  sky130_fd_sc_hd__a221o_1 U34 ( .A1(dat_o[27]), .A2(n50), .B1(dat_i[27]), 
        .B2(n47), .C1(n25), .X(s_cnt_d[27]) );
  sky130_fd_sc_hd__a22o_1 U35 ( .A1(N35), .A2(n5), .B1(N68), .B2(n1), .X(n25)
         );
  sky130_fd_sc_hd__a221o_1 U36 ( .A1(dat_o[26]), .A2(n50), .B1(dat_i[26]), 
        .B2(n47), .C1(n26), .X(s_cnt_d[26]) );
  sky130_fd_sc_hd__a22o_1 U37 ( .A1(N34), .A2(n5), .B1(N67), .B2(n2), .X(n26)
         );
  sky130_fd_sc_hd__a221o_1 U38 ( .A1(dat_o[25]), .A2(n50), .B1(dat_i[25]), 
        .B2(n47), .C1(n27), .X(s_cnt_d[25]) );
  sky130_fd_sc_hd__a22o_1 U39 ( .A1(N33), .A2(n5), .B1(N66), .B2(n2), .X(n27)
         );
  sky130_fd_sc_hd__a221o_1 U40 ( .A1(dat_o[24]), .A2(n50), .B1(dat_i[24]), 
        .B2(n47), .C1(n28), .X(s_cnt_d[24]) );
  sky130_fd_sc_hd__a22o_1 U41 ( .A1(N32), .A2(n5), .B1(N65), .B2(n2), .X(n28)
         );
  sky130_fd_sc_hd__a221o_1 U42 ( .A1(dat_o[23]), .A2(n50), .B1(dat_i[23]), 
        .B2(n47), .C1(n29), .X(s_cnt_d[23]) );
  sky130_fd_sc_hd__a22o_1 U43 ( .A1(N31), .A2(n5), .B1(N64), .B2(n2), .X(n29)
         );
  sky130_fd_sc_hd__a221o_1 U44 ( .A1(dat_o[22]), .A2(n50), .B1(dat_i[22]), 
        .B2(n47), .C1(n30), .X(s_cnt_d[22]) );
  sky130_fd_sc_hd__a22o_1 U45 ( .A1(N30), .A2(n5), .B1(N63), .B2(n2), .X(n30)
         );
  sky130_fd_sc_hd__a221o_1 U46 ( .A1(dat_o[21]), .A2(n50), .B1(dat_i[21]), 
        .B2(n47), .C1(n31), .X(s_cnt_d[21]) );
  sky130_fd_sc_hd__a22o_1 U47 ( .A1(N29), .A2(n5), .B1(N62), .B2(n2), .X(n31)
         );
  sky130_fd_sc_hd__a221o_1 U48 ( .A1(dat_o[20]), .A2(n49), .B1(dat_i[20]), 
        .B2(n46), .C1(n32), .X(s_cnt_d[20]) );
  sky130_fd_sc_hd__a22o_1 U49 ( .A1(N28), .A2(n4), .B1(N61), .B2(n2), .X(n32)
         );
  sky130_fd_sc_hd__a221o_1 U50 ( .A1(dat_o[1]), .A2(n49), .B1(dat_i[1]), .B2(
        n46), .C1(n33), .X(s_cnt_d[1]) );
  sky130_fd_sc_hd__a22o_1 U51 ( .A1(N9), .A2(n4), .B1(N42), .B2(n2), .X(n33)
         );
  sky130_fd_sc_hd__a221o_1 U52 ( .A1(dat_o[19]), .A2(n49), .B1(dat_i[19]), 
        .B2(n46), .C1(n34), .X(s_cnt_d[19]) );
  sky130_fd_sc_hd__a22o_1 U53 ( .A1(N27), .A2(n4), .B1(N60), .B2(n2), .X(n34)
         );
  sky130_fd_sc_hd__a221o_1 U54 ( .A1(dat_o[18]), .A2(n49), .B1(dat_i[18]), 
        .B2(n46), .C1(n35), .X(s_cnt_d[18]) );
  sky130_fd_sc_hd__a22o_1 U55 ( .A1(N26), .A2(n4), .B1(N59), .B2(n2), .X(n35)
         );
  sky130_fd_sc_hd__a221o_1 U56 ( .A1(dat_o[17]), .A2(n49), .B1(dat_i[17]), 
        .B2(n46), .C1(n36), .X(s_cnt_d[17]) );
  sky130_fd_sc_hd__a22o_1 U57 ( .A1(N25), .A2(n4), .B1(N58), .B2(n2), .X(n36)
         );
  sky130_fd_sc_hd__a221o_1 U58 ( .A1(dat_o[16]), .A2(n49), .B1(dat_i[16]), 
        .B2(n46), .C1(n37), .X(s_cnt_d[16]) );
  sky130_fd_sc_hd__a22o_1 U59 ( .A1(N24), .A2(n4), .B1(N57), .B2(n3), .X(n37)
         );
  sky130_fd_sc_hd__a221o_1 U60 ( .A1(dat_o[15]), .A2(n49), .B1(dat_i[15]), 
        .B2(n46), .C1(n38), .X(s_cnt_d[15]) );
  sky130_fd_sc_hd__a22o_1 U61 ( .A1(N23), .A2(n4), .B1(N56), .B2(n3), .X(n38)
         );
  sky130_fd_sc_hd__a221o_1 U62 ( .A1(dat_o[14]), .A2(n49), .B1(dat_i[14]), 
        .B2(n46), .C1(n39), .X(s_cnt_d[14]) );
  sky130_fd_sc_hd__a22o_1 U63 ( .A1(N22), .A2(n4), .B1(N55), .B2(n3), .X(n39)
         );
  sky130_fd_sc_hd__a221o_1 U64 ( .A1(dat_o[13]), .A2(n49), .B1(dat_i[13]), 
        .B2(n46), .C1(n40), .X(s_cnt_d[13]) );
  sky130_fd_sc_hd__a22o_1 U65 ( .A1(N21), .A2(n4), .B1(N54), .B2(n3), .X(n40)
         );
  sky130_fd_sc_hd__a221o_1 U66 ( .A1(dat_o[12]), .A2(n49), .B1(dat_i[12]), 
        .B2(n46), .C1(n41), .X(s_cnt_d[12]) );
  sky130_fd_sc_hd__a22o_1 U67 ( .A1(N20), .A2(n4), .B1(N53), .B2(n3), .X(n41)
         );
  sky130_fd_sc_hd__a221o_1 U68 ( .A1(dat_o[11]), .A2(n49), .B1(dat_i[11]), 
        .B2(n46), .C1(n42), .X(s_cnt_d[11]) );
  sky130_fd_sc_hd__a22o_1 U69 ( .A1(N19), .A2(n4), .B1(N52), .B2(n3), .X(n42)
         );
  sky130_fd_sc_hd__a221o_1 U70 ( .A1(dat_o[10]), .A2(n49), .B1(dat_i[10]), 
        .B2(n46), .C1(n43), .X(s_cnt_d[10]) );
  sky130_fd_sc_hd__a22o_1 U71 ( .A1(N18), .A2(n4), .B1(N51), .B2(n2), .X(n43)
         );
  sky130_fd_sc_hd__a221o_1 U72 ( .A1(dat_o[0]), .A2(n50), .B1(dat_i[0]), .B2(
        n46), .C1(n44), .X(s_cnt_d[0]) );
  sky130_fd_sc_hd__a22o_1 U73 ( .A1(N8), .A2(n5), .B1(N41), .B2(n1), .X(n44)
         );
  sky130_fd_sc_hd__nor2b_1 U74 ( .B_N(n45), .A(down_i), .Y(n12) );
  sky130_fd_sc_hd__and2_0 U75 ( .A(down_i), .B(n45), .X(n11) );
  sky130_fd_sc_hd__nor2b_1 U76 ( .B_N(load_i), .A(clr_i), .Y(n9) );
  dffr_DATA_WIDTH33 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i({n52, 
        s_cnt_d[31:0]}), .dat_o({ovf_o, dat_o}) );
  delta_counter_DATA_WIDTH32_DW01_add_0 add_86 ( .A({ovf_o, dat_o}), .B({n6, 
        delta_i}), .CI(n6), .SUM({N73, N72, N71, N70, N69, N68, N67, N66, N65, 
        N64, N63, N62, N61, N60, N59, N58, N57, N56, N55, N54, N53, N52, N51, 
        N50, N49, N48, N47, N46, N45, N44, N43, N42, N41}) );
  delta_counter_DATA_WIDTH32_DW01_sub_0 sub_84 ( .A({ovf_o, dat_o}), .B({n6, 
        delta_i}), .CI(n6), .DIFF({N40, N39, N38, N37, N36, N35, N34, N33, N32, 
        N31, N30, N29, N28, N27, N26, N25, N24, N23, N22, N21, N20, N19, N18, 
        N17, N16, N15, N14, N13, N12, N11, N10, N9, N8}) );
  sky130_fd_sc_hd__buf_1 U2 ( .A(n9), .X(n46) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(n9), .X(n47) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(n8), .X(n49) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(n8), .X(n50) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(n8), .X(n51) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(n9), .X(n48) );
  sky130_fd_sc_hd__nor3_1 U8 ( .A(en_i), .B(load_i), .C(clr_i), .Y(n8) );
  sky130_fd_sc_hd__nor3b_1 U77 ( .C_N(en_i), .A(clr_i), .B(load_i), .Y(n45) );
  sky130_fd_sc_hd__buf_1 U78 ( .A(n11), .X(n4) );
  sky130_fd_sc_hd__buf_1 U79 ( .A(n11), .X(n5) );
  sky130_fd_sc_hd__buf_1 U80 ( .A(n12), .X(n2) );
  sky130_fd_sc_hd__buf_1 U81 ( .A(n12), .X(n1) );
  sky130_fd_sc_hd__buf_1 U82 ( .A(n11), .X(n7) );
  sky130_fd_sc_hd__buf_1 U83 ( .A(n12), .X(n3) );
  sky130_fd_sc_hd__inv_2 U84 ( .A(n19), .Y(n52) );
  sky130_fd_sc_hd__conb_1 U85 ( .LO(n6) );
endmodule


module counter_DATA_WIDTH32 ( clk_i, rst_n_i, clr_i, en_i, load_i, down_i, 
        dat_i, dat_o, ovf_o );
  input [31:0] dat_i;
  output [31:0] dat_o;
  input clk_i, rst_n_i, clr_i, en_i, load_i, down_i;
  output ovf_o;
  wire   n_Logic1_, n_Logic0_;

  delta_counter_DATA_WIDTH32 u_delta_counter ( .clk_i(clk_i), .rst_n_i(rst_n_i), .clr_i(clr_i), .en_i(en_i), .load_i(load_i), .down_i(down_i), .delta_i({
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, n_Logic0_, 
        n_Logic0_, n_Logic1_}), .dat_i(dat_i), .dat_o(dat_o), .ovf_o(ovf_o) );
  sky130_fd_sc_hd__conb_1 U3 ( .LO(n_Logic0_), .HI(n_Logic1_) );
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


module dffr_DATA_WIDTH1_4 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_3 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module cdc_sync_STAGE2_DATA_WIDTH1_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;
  wire   s_sync_dat_0__0_;

  dffr_DATA_WIDTH1_4 genblk1_0__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(dat_i[0]), .dat_o(s_sync_dat_0__0_) );
  dffr_DATA_WIDTH1_3 genblk1_1__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(s_sync_dat_0__0_), .dat_o(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_9 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module apb4_timer ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr, timer_exclk_i, timer_capch_i, timer_irq_o
 );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite,
         timer_exclk_i, timer_capch_i;
  output apb4_pready, apb4_pslverr, timer_irq_o;
  wire   N0, s_tr_clk, s_inclk, s_done, \s_tim_stat_q[0] , s_valid,
         s_norm_trg1, s_norm_trg2, n_1_net_, s_cnt_ov, \s_tim_stat_d[0] ,
         s_irq_d, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n85,
         n86, n88, n89, n90, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153, n154, n155,
         n156, n157, n158, n159, n160, n161, n162, n163, n164, n165, n166,
         n167, n168, n169, n170, n171, n172, n173, n174, n175, n176, n177,
         n178, n179, n180, n181, n182, n183, n184, n185, n186;
  wire   [3:0] s_tim_ctrl_q;
  wire   [3:0] s_tim_ctrl_d;
  wire   [19:0] s_tim_pscr_d;
  wire   [19:0] s_tim_pscr_q;
  wire   [31:0] s_tim_cmp_q;
  wire   [31:0] s_tim_cmp_d;

  sky130_fd_sc_hd__nor2b_1 U149 ( .B_N(n75), .A(apb4_pwdata[1]), .Y(n74) );
  sky130_fd_sc_hd__nand4_1 U151 ( .A(n76), .B(n77), .C(n78), .D(n79), .Y(n75)
         );
  sky130_fd_sc_hd__nand2_1 U153 ( .A(n86), .B(n108), .Y(n85) );
  sky130_fd_sc_hd__a22o_1 U154 ( .A1(apb4_pwdata[3]), .A2(n115), .B1(n113), 
        .B2(s_tim_cmp_q[3]), .X(s_tim_cmp_d[3]) );
  sky130_fd_sc_hd__a22o_1 U155 ( .A1(n113), .A2(s_tim_cmp_q[31]), .B1(
        apb4_pwdata[31]), .B2(n116), .X(s_tim_cmp_d[31]) );
  sky130_fd_sc_hd__a22o_1 U156 ( .A1(n113), .A2(s_tim_cmp_q[30]), .B1(
        apb4_pwdata[30]), .B2(n116), .X(s_tim_cmp_d[30]) );
  sky130_fd_sc_hd__a22o_1 U157 ( .A1(apb4_pwdata[2]), .A2(n115), .B1(n113), 
        .B2(s_tim_cmp_q[2]), .X(s_tim_cmp_d[2]) );
  sky130_fd_sc_hd__a22o_1 U158 ( .A1(n113), .A2(s_tim_cmp_q[29]), .B1(
        apb4_pwdata[29]), .B2(n116), .X(s_tim_cmp_d[29]) );
  sky130_fd_sc_hd__a22o_1 U159 ( .A1(n113), .A2(s_tim_cmp_q[28]), .B1(
        apb4_pwdata[28]), .B2(n116), .X(s_tim_cmp_d[28]) );
  sky130_fd_sc_hd__a22o_1 U160 ( .A1(n113), .A2(s_tim_cmp_q[27]), .B1(
        apb4_pwdata[27]), .B2(n116), .X(s_tim_cmp_d[27]) );
  sky130_fd_sc_hd__a22o_1 U161 ( .A1(n113), .A2(s_tim_cmp_q[26]), .B1(
        apb4_pwdata[26]), .B2(n116), .X(s_tim_cmp_d[26]) );
  sky130_fd_sc_hd__a22o_1 U162 ( .A1(n113), .A2(s_tim_cmp_q[25]), .B1(
        apb4_pwdata[25]), .B2(n116), .X(s_tim_cmp_d[25]) );
  sky130_fd_sc_hd__a22o_1 U163 ( .A1(n113), .A2(s_tim_cmp_q[24]), .B1(
        apb4_pwdata[24]), .B2(n116), .X(s_tim_cmp_d[24]) );
  sky130_fd_sc_hd__a22o_1 U164 ( .A1(n113), .A2(s_tim_cmp_q[23]), .B1(
        apb4_pwdata[23]), .B2(n116), .X(s_tim_cmp_d[23]) );
  sky130_fd_sc_hd__a22o_1 U165 ( .A1(n113), .A2(s_tim_cmp_q[22]), .B1(
        apb4_pwdata[22]), .B2(n116), .X(s_tim_cmp_d[22]) );
  sky130_fd_sc_hd__a22o_1 U166 ( .A1(n113), .A2(s_tim_cmp_q[21]), .B1(
        apb4_pwdata[21]), .B2(n116), .X(s_tim_cmp_d[21]) );
  sky130_fd_sc_hd__a22o_1 U167 ( .A1(n113), .A2(s_tim_cmp_q[20]), .B1(
        apb4_pwdata[20]), .B2(n116), .X(s_tim_cmp_d[20]) );
  sky130_fd_sc_hd__a22o_1 U168 ( .A1(apb4_pwdata[1]), .A2(n115), .B1(n113), 
        .B2(s_tim_cmp_q[1]), .X(s_tim_cmp_d[1]) );
  sky130_fd_sc_hd__a22o_1 U169 ( .A1(apb4_pwdata[0]), .A2(n115), .B1(n113), 
        .B2(s_tim_cmp_q[0]), .X(s_tim_cmp_d[0]) );
  sky130_fd_sc_hd__nand2_1 U172 ( .A(s_tim_ctrl_q[2]), .B(s_done), .Y(n100) );
  sky130_fd_sc_hd__o21bai_1 U173 ( .A1(s_norm_trg2), .A2(n120), .B1_N(s_cnt_ov), .Y(n_1_net_) );
  sky130_fd_sc_hd__nand2_1 U174 ( .A(n105), .B(s_tim_cmp_q[3]), .Y(n94) );
  sky130_fd_sc_hd__nor2b_1 U175 ( .B_N(s_tim_cmp_q[31]), .A(n112), .Y(
        apb4_prdata[31]) );
  sky130_fd_sc_hd__nor2b_1 U176 ( .B_N(s_tim_cmp_q[30]), .A(n112), .Y(
        apb4_prdata[30]) );
  sky130_fd_sc_hd__nand2_1 U177 ( .A(n105), .B(s_tim_cmp_q[2]), .Y(n95) );
  sky130_fd_sc_hd__nor2b_1 U178 ( .B_N(s_tim_cmp_q[29]), .A(n112), .Y(
        apb4_prdata[29]) );
  sky130_fd_sc_hd__nor2b_1 U179 ( .B_N(s_tim_cmp_q[28]), .A(n112), .Y(
        apb4_prdata[28]) );
  sky130_fd_sc_hd__nor2b_1 U180 ( .B_N(s_tim_cmp_q[27]), .A(n112), .Y(
        apb4_prdata[27]) );
  sky130_fd_sc_hd__nor2b_1 U181 ( .B_N(s_tim_cmp_q[26]), .A(n112), .Y(
        apb4_prdata[26]) );
  sky130_fd_sc_hd__nor2b_1 U182 ( .B_N(s_tim_cmp_q[25]), .A(n112), .Y(
        apb4_prdata[25]) );
  sky130_fd_sc_hd__nor2b_1 U183 ( .B_N(s_tim_cmp_q[24]), .A(n112), .Y(
        apb4_prdata[24]) );
  sky130_fd_sc_hd__nor2b_1 U184 ( .B_N(s_tim_cmp_q[23]), .A(n112), .Y(
        apb4_prdata[23]) );
  sky130_fd_sc_hd__nor2b_1 U185 ( .B_N(s_tim_cmp_q[22]), .A(n112), .Y(
        apb4_prdata[22]) );
  sky130_fd_sc_hd__nor2b_1 U186 ( .B_N(s_tim_cmp_q[21]), .A(n112), .Y(
        apb4_prdata[21]) );
  sky130_fd_sc_hd__nor2b_1 U187 ( .B_N(s_tim_cmp_q[20]), .A(n112), .Y(
        apb4_prdata[20]) );
  sky130_fd_sc_hd__nand2_1 U188 ( .A(n105), .B(s_tim_cmp_q[1]), .Y(n96) );
  sky130_fd_sc_hd__nand2_1 U189 ( .A(n163), .B(n86), .Y(n93) );
  sky130_fd_sc_hd__nand2_1 U190 ( .A(n105), .B(s_tim_cmp_q[0]), .Y(n98) );
  sky130_fd_sc_hd__and3_1 U192 ( .A(apb4_paddr[2]), .B(n166), .C(apb4_paddr[3]), .X(n88) );
  sky130_fd_sc_hd__nand4b_1 U194 ( .A_N(apb4_pwrite), .B(apb4_psel), .C(
        apb4_penable), .D(n118), .Y(n90) );
  edge_det_STAGE2_DATA_WIDTH1 u_edge_det ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(timer_capch_i) );
  dffr_DATA_WIDTH4 u_tim_ctrl_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_tim_ctrl_d), .dat_o({s_tim_ctrl_q[3:2], N0, s_tim_ctrl_q[0]})
         );
  dffrc_20_00002 u_tim_pscr_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_tim_pscr_d), .dat_o(s_tim_pscr_q) );
  clk_int_even_div_simple_DIV_VALUE_WIDTH20 u_clk_int_even_div_simple ( 
        .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .div_i(s_tim_pscr_q), 
        .div_valid_i(s_valid), .div_done_o(s_done), .clk_o(s_inclk) );
  cdc_sync_det_STAGE2_DATA_WIDTH1 u_cnt_cdc_sync ( .clk_i(s_tr_clk), .rst_n_i(
        apb4_presetn), .dat_i(n121), .dat_pre_o(s_norm_trg1), .dat_o(
        s_norm_trg2) );
  counter_DATA_WIDTH32 u_tim_cnt_counter ( .clk_i(s_tr_clk), .rst_n_i(
        apb4_presetn), .clr_i(n100), .en_i(n121), .load_i(n_1_net_), .down_i(
        s_tim_ctrl_q[3]), .dat_i(s_tim_cmp_q), .ovf_o(s_cnt_ov) );
  dffr_DATA_WIDTH32 u_tim_cmp_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_tim_cmp_d), .dat_o(s_tim_cmp_q) );
  cdc_sync_STAGE2_DATA_WIDTH1_0 u_irq_cdc_sync ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_cnt_ov), .dat_o(\s_tim_stat_d[0] ) );
  dffr_DATA_WIDTH1_0 u_tim_stat_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(\s_tim_stat_d[0] ), .dat_o(\s_tim_stat_q[0] ) );
  dffr_DATA_WIDTH1_9 u_irq_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_irq_d), .dat_o(timer_irq_o) );
  sky130_fd_sc_hd__dlygate4sd3_1 U195 ( .A(s_tim_pscr_q[7]), .X(n101) );
  sky130_fd_sc_hd__dlygate4sd3_1 U196 ( .A(s_tim_pscr_q[8]), .X(n102) );
  sky130_fd_sc_hd__clkinv_1 U197 ( .A(s_tim_pscr_q[10]), .Y(n148) );
  sky130_fd_sc_hd__dlygate4sd3_1 U198 ( .A(s_tim_pscr_q[6]), .X(n103) );
  sky130_fd_sc_hd__dlygate4sd3_1 U199 ( .A(s_tim_pscr_q[5]), .X(n104) );
  sky130_fd_sc_hd__dlygate4sd1_1 U200 ( .A(s_tim_pscr_q[1]), .X(n109) );
  sky130_fd_sc_hd__dlygate4sd3_1 U201 ( .A(s_tim_pscr_q[2]), .X(n110) );
  sky130_fd_sc_hd__inv_1 U202 ( .A(n103), .Y(n152) );
  sky130_fd_sc_hd__inv_2 U203 ( .A(n114), .Y(n113) );
  sky130_fd_sc_hd__inv_2 U204 ( .A(n72), .Y(n165) );
  sky130_fd_sc_hd__buf_1 U205 ( .A(n106), .X(n114) );
  sky130_fd_sc_hd__inv_2 U206 ( .A(n85), .Y(n164) );
  sky130_fd_sc_hd__buf_1 U207 ( .A(n106), .X(n115) );
  sky130_fd_sc_hd__buf_1 U208 ( .A(n106), .X(n116) );
  sky130_fd_sc_hd__inv_2 U209 ( .A(n105), .Y(n112) );
  sky130_fd_sc_hd__o22ai_1 U210 ( .A1(n165), .A2(n145), .B1(n73), .B2(n173), 
        .Y(s_tim_pscr_d[13]) );
  sky130_fd_sc_hd__o22ai_1 U211 ( .A1(n165), .A2(n152), .B1(n73), .B2(n180), 
        .Y(s_tim_pscr_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U212 ( .A1(n165), .A2(n149), .B1(n73), .B2(n177), 
        .Y(s_tim_pscr_d[9]) );
  sky130_fd_sc_hd__o22ai_1 U213 ( .A1(n165), .A2(n155), .B1(n73), .B2(n183), 
        .Y(s_tim_pscr_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U214 ( .A1(n165), .A2(n153), .B1(n73), .B2(n181), 
        .Y(s_tim_pscr_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U215 ( .A1(n165), .A2(n147), .B1(n73), .B2(n175), 
        .Y(s_tim_pscr_d[11]) );
  sky130_fd_sc_hd__o22ai_1 U216 ( .A1(n165), .A2(n139), .B1(n73), .B2(n167), 
        .Y(s_tim_pscr_d[19]) );
  sky130_fd_sc_hd__o22ai_1 U217 ( .A1(n165), .A2(n151), .B1(n73), .B2(n179), 
        .Y(s_tim_pscr_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U218 ( .A1(n165), .A2(n141), .B1(n73), .B2(n169), 
        .Y(s_tim_pscr_d[17]) );
  sky130_fd_sc_hd__o22ai_1 U219 ( .A1(n165), .A2(n143), .B1(n73), .B2(n171), 
        .Y(s_tim_pscr_d[15]) );
  sky130_fd_sc_hd__o22ai_1 U220 ( .A1(n165), .A2(n154), .B1(n73), .B2(n182), 
        .Y(s_tim_pscr_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U221 ( .A1(n165), .A2(n144), .B1(n73), .B2(n172), 
        .Y(s_tim_pscr_d[14]) );
  sky130_fd_sc_hd__o22ai_1 U222 ( .A1(n165), .A2(n150), .B1(n73), .B2(n178), 
        .Y(s_tim_pscr_d[8]) );
  sky130_fd_sc_hd__o22ai_1 U223 ( .A1(n165), .A2(n146), .B1(n73), .B2(n174), 
        .Y(s_tim_pscr_d[12]) );
  sky130_fd_sc_hd__o22ai_1 U224 ( .A1(n165), .A2(n140), .B1(n73), .B2(n168), 
        .Y(s_tim_pscr_d[18]) );
  sky130_fd_sc_hd__o22ai_1 U225 ( .A1(n165), .A2(n142), .B1(n73), .B2(n170), 
        .Y(s_tim_pscr_d[16]) );
  sky130_fd_sc_hd__o22ai_1 U226 ( .A1(n186), .A2(n85), .B1(n164), .B2(n162), 
        .Y(s_tim_ctrl_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U227 ( .A1(n183), .A2(n85), .B1(n164), .B2(n159), 
        .Y(s_tim_ctrl_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U228 ( .A1(n165), .A2(n158), .B1(n73), .B2(n186), 
        .Y(s_tim_pscr_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U229 ( .A1(n176), .A2(n113), .B1(n114), .B2(n132), 
        .Y(s_tim_cmp_d[10]) );
  sky130_fd_sc_hd__o22ai_1 U230 ( .A1(n181), .A2(n113), .B1(n115), .B2(n137), 
        .Y(s_tim_cmp_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U231 ( .A1(n180), .A2(n113), .B1(n115), .B2(n136), 
        .Y(s_tim_cmp_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U232 ( .A1(n175), .A2(n113), .B1(n115), .B2(n131), 
        .Y(s_tim_cmp_d[11]) );
  sky130_fd_sc_hd__o22ai_1 U233 ( .A1(n174), .A2(n113), .B1(n115), .B2(n130), 
        .Y(s_tim_cmp_d[12]) );
  sky130_fd_sc_hd__o22ai_1 U234 ( .A1(n173), .A2(n113), .B1(n115), .B2(n129), 
        .Y(s_tim_cmp_d[13]) );
  sky130_fd_sc_hd__o22ai_1 U235 ( .A1(n172), .A2(n113), .B1(n115), .B2(n128), 
        .Y(s_tim_cmp_d[14]) );
  sky130_fd_sc_hd__o22ai_1 U236 ( .A1(n171), .A2(n113), .B1(n115), .B2(n127), 
        .Y(s_tim_cmp_d[15]) );
  sky130_fd_sc_hd__o22ai_1 U237 ( .A1(n167), .A2(n113), .B1(n115), .B2(n123), 
        .Y(s_tim_cmp_d[19]) );
  sky130_fd_sc_hd__o22ai_1 U238 ( .A1(n182), .A2(n113), .B1(n115), .B2(n138), 
        .Y(s_tim_cmp_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U239 ( .A1(n179), .A2(n113), .B1(n115), .B2(n135), 
        .Y(s_tim_cmp_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U240 ( .A1(n178), .A2(n113), .B1(n115), .B2(n134), 
        .Y(s_tim_cmp_d[8]) );
  sky130_fd_sc_hd__o22ai_1 U241 ( .A1(n177), .A2(n113), .B1(n115), .B2(n133), 
        .Y(s_tim_cmp_d[9]) );
  sky130_fd_sc_hd__o22ai_1 U242 ( .A1(n170), .A2(n113), .B1(n115), .B2(n126), 
        .Y(s_tim_cmp_d[16]) );
  sky130_fd_sc_hd__o22ai_1 U243 ( .A1(n169), .A2(n113), .B1(n115), .B2(n125), 
        .Y(s_tim_cmp_d[17]) );
  sky130_fd_sc_hd__o22ai_1 U244 ( .A1(n168), .A2(n113), .B1(n115), .B2(n124), 
        .Y(s_tim_cmp_d[18]) );
  sky130_fd_sc_hd__o22ai_1 U245 ( .A1(n184), .A2(n85), .B1(n164), .B2(n160), 
        .Y(s_tim_ctrl_d[2]) );
  sky130_fd_sc_hd__nand2_1 U246 ( .A(n165), .B(n75), .Y(n73) );
  sky130_fd_sc_hd__nand2_1 U247 ( .A(n163), .B(n107), .Y(n111) );
  sky130_fd_sc_hd__nand2_1 U248 ( .A(n163), .B(n107), .Y(n92) );
  sky130_fd_sc_hd__and2_0 U249 ( .A(n163), .B(n88), .X(n105) );
  sky130_fd_sc_hd__inv_2 U250 ( .A(n90), .Y(n163) );
  sky130_fd_sc_hd__o22ai_1 U251 ( .A1(n138), .A2(n112), .B1(n154), .B2(n111), 
        .Y(apb4_prdata[4]) );
  sky130_fd_sc_hd__o22ai_1 U252 ( .A1(n137), .A2(n112), .B1(n153), .B2(n92), 
        .Y(apb4_prdata[5]) );
  sky130_fd_sc_hd__o22ai_1 U253 ( .A1(n136), .A2(n112), .B1(n152), .B2(n111), 
        .Y(apb4_prdata[6]) );
  sky130_fd_sc_hd__o22ai_1 U254 ( .A1(n135), .A2(n112), .B1(n151), .B2(n92), 
        .Y(apb4_prdata[7]) );
  sky130_fd_sc_hd__o22ai_1 U255 ( .A1(n134), .A2(n112), .B1(n150), .B2(n111), 
        .Y(apb4_prdata[8]) );
  sky130_fd_sc_hd__o22ai_1 U256 ( .A1(n133), .A2(n112), .B1(n149), .B2(n92), 
        .Y(apb4_prdata[9]) );
  sky130_fd_sc_hd__o22ai_1 U257 ( .A1(n132), .A2(n112), .B1(n148), .B2(n111), 
        .Y(apb4_prdata[10]) );
  sky130_fd_sc_hd__o22ai_1 U258 ( .A1(n131), .A2(n112), .B1(n147), .B2(n92), 
        .Y(apb4_prdata[11]) );
  sky130_fd_sc_hd__o22ai_1 U259 ( .A1(n130), .A2(n112), .B1(n146), .B2(n111), 
        .Y(apb4_prdata[12]) );
  sky130_fd_sc_hd__o22ai_1 U260 ( .A1(n129), .A2(n112), .B1(n145), .B2(n92), 
        .Y(apb4_prdata[13]) );
  sky130_fd_sc_hd__o22ai_1 U261 ( .A1(n128), .A2(n112), .B1(n144), .B2(n111), 
        .Y(apb4_prdata[14]) );
  sky130_fd_sc_hd__o22ai_1 U262 ( .A1(n127), .A2(n112), .B1(n143), .B2(n92), 
        .Y(apb4_prdata[15]) );
  sky130_fd_sc_hd__o22ai_1 U263 ( .A1(n126), .A2(n112), .B1(n142), .B2(n111), 
        .Y(apb4_prdata[16]) );
  sky130_fd_sc_hd__o22ai_1 U264 ( .A1(n125), .A2(n112), .B1(n141), .B2(n92), 
        .Y(apb4_prdata[17]) );
  sky130_fd_sc_hd__o22ai_1 U265 ( .A1(n124), .A2(n112), .B1(n140), .B2(n111), 
        .Y(apb4_prdata[18]) );
  sky130_fd_sc_hd__o22ai_1 U266 ( .A1(n123), .A2(n112), .B1(n139), .B2(n92), 
        .Y(apb4_prdata[19]) );
  sky130_fd_sc_hd__inv_2 U267 ( .A(n100), .Y(n121) );
  sky130_fd_sc_hd__and2_0 U268 ( .A(n88), .B(n108), .X(n106) );
  sky130_fd_sc_hd__nand3_1 U269 ( .A(n169), .B(n168), .C(n170), .Y(n82) );
  sky130_fd_sc_hd__nand3_1 U270 ( .A(n178), .B(n177), .C(n179), .Y(n80) );
  sky130_fd_sc_hd__nand3_1 U271 ( .A(n183), .B(n182), .C(n184), .Y(n81) );
  sky130_fd_sc_hd__o32ai_1 U272 ( .A1(n122), .A2(timer_irq_o), .A3(n162), .B1(
        n89), .B2(n119), .Y(s_irq_d) );
  sky130_fd_sc_hd__nor4_1 U273 ( .A(apb4_paddr[3]), .B(apb4_paddr[2]), .C(n90), 
        .D(n166), .Y(n89) );
  sky130_fd_sc_hd__inv_2 U274 ( .A(timer_irq_o), .Y(n119) );
  sky130_fd_sc_hd__inv_2 U275 ( .A(\s_tim_stat_q[0] ), .Y(n122) );
  sky130_fd_sc_hd__inv_1 U276 ( .A(s_tim_pscr_q[13]), .Y(n145) );
  sky130_fd_sc_hd__inv_2 U277 ( .A(s_tim_ctrl_q[0]), .Y(n162) );
  sky130_fd_sc_hd__inv_1 U278 ( .A(s_tim_pscr_q[3]), .Y(n155) );
  sky130_fd_sc_hd__inv_1 U279 ( .A(n104), .Y(n153) );
  sky130_fd_sc_hd__inv_1 U280 ( .A(s_tim_pscr_q[19]), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U281 ( .A(n101), .Y(n151) );
  sky130_fd_sc_hd__inv_1 U282 ( .A(s_tim_pscr_q[17]), .Y(n141) );
  sky130_fd_sc_hd__inv_1 U283 ( .A(s_tim_pscr_q[15]), .Y(n143) );
  sky130_fd_sc_hd__inv_1 U284 ( .A(s_tim_pscr_q[4]), .Y(n154) );
  sky130_fd_sc_hd__inv_1 U285 ( .A(s_tim_pscr_q[14]), .Y(n144) );
  sky130_fd_sc_hd__inv_1 U286 ( .A(n102), .Y(n150) );
  sky130_fd_sc_hd__inv_1 U287 ( .A(s_tim_pscr_q[12]), .Y(n146) );
  sky130_fd_sc_hd__inv_1 U288 ( .A(s_tim_pscr_q[18]), .Y(n140) );
  sky130_fd_sc_hd__inv_1 U289 ( .A(s_tim_pscr_q[16]), .Y(n142) );
  sky130_fd_sc_hd__inv_2 U290 ( .A(s_tim_ctrl_q[3]), .Y(n159) );
  sky130_fd_sc_hd__o22ai_1 U291 ( .A1(n85), .A2(n185), .B1(n164), .B2(n161), 
        .Y(s_tim_ctrl_d[1]) );
  sky130_fd_sc_hd__inv_2 U292 ( .A(apb4_pwdata[1]), .Y(n185) );
  sky130_fd_sc_hd__inv_2 U293 ( .A(N0), .Y(n161) );
  sky130_fd_sc_hd__inv_2 U294 ( .A(s_tim_pscr_q[0]), .Y(n158) );
  sky130_fd_sc_hd__inv_2 U295 ( .A(s_tim_cmp_q[10]), .Y(n132) );
  sky130_fd_sc_hd__inv_2 U296 ( .A(s_tim_cmp_q[4]), .Y(n138) );
  sky130_fd_sc_hd__inv_2 U297 ( .A(s_tim_cmp_q[5]), .Y(n137) );
  sky130_fd_sc_hd__inv_2 U298 ( .A(s_tim_cmp_q[6]), .Y(n136) );
  sky130_fd_sc_hd__inv_2 U299 ( .A(s_tim_cmp_q[7]), .Y(n135) );
  sky130_fd_sc_hd__inv_2 U300 ( .A(s_tim_cmp_q[8]), .Y(n134) );
  sky130_fd_sc_hd__inv_2 U301 ( .A(s_tim_cmp_q[9]), .Y(n133) );
  sky130_fd_sc_hd__inv_2 U302 ( .A(s_tim_cmp_q[11]), .Y(n131) );
  sky130_fd_sc_hd__inv_2 U303 ( .A(s_tim_cmp_q[12]), .Y(n130) );
  sky130_fd_sc_hd__inv_2 U304 ( .A(s_tim_cmp_q[13]), .Y(n129) );
  sky130_fd_sc_hd__inv_2 U305 ( .A(s_tim_cmp_q[14]), .Y(n128) );
  sky130_fd_sc_hd__inv_2 U306 ( .A(s_tim_cmp_q[15]), .Y(n127) );
  sky130_fd_sc_hd__inv_2 U307 ( .A(s_tim_cmp_q[16]), .Y(n126) );
  sky130_fd_sc_hd__inv_2 U308 ( .A(s_tim_cmp_q[17]), .Y(n125) );
  sky130_fd_sc_hd__inv_2 U309 ( .A(s_tim_cmp_q[18]), .Y(n124) );
  sky130_fd_sc_hd__inv_2 U310 ( .A(s_tim_cmp_q[19]), .Y(n123) );
  sky130_fd_sc_hd__inv_2 U311 ( .A(s_tim_ctrl_q[2]), .Y(n160) );
  sky130_fd_sc_hd__inv_2 U312 ( .A(s_norm_trg1), .Y(n120) );
  sky130_fd_sc_hd__nor3_1 U313 ( .A(n80), .B(apb4_pwdata[6]), .C(
        apb4_pwdata[5]), .Y(n79) );
  sky130_fd_sc_hd__nor3_1 U314 ( .A(n81), .B(apb4_pwdata[1]), .C(
        apb4_pwdata[19]), .Y(n78) );
  sky130_fd_sc_hd__nor3_1 U315 ( .A(n82), .B(apb4_pwdata[15]), .C(
        apb4_pwdata[14]), .Y(n77) );
  sky130_fd_sc_hd__nor3_1 U316 ( .A(apb4_paddr[3]), .B(apb4_paddr[4]), .C(
        apb4_paddr[2]), .Y(n86) );
  sky130_fd_sc_hd__nor4_1 U317 ( .A(apb4_pwdata[13]), .B(apb4_pwdata[12]), .C(
        apb4_pwdata[11]), .D(apb4_pwdata[10]), .Y(n76) );
  sky130_fd_sc_hd__o221ai_1 U318 ( .A1(n97), .A2(n90), .B1(n158), .B2(n111), 
        .C1(n98), .Y(apb4_prdata[0]) );
  sky130_fd_sc_hd__a21oi_1 U319 ( .A1(s_tim_ctrl_q[0]), .A2(n86), .B1(n99), 
        .Y(n97) );
  sky130_fd_sc_hd__nor4_1 U320 ( .A(apb4_paddr[3]), .B(apb4_paddr[2]), .C(n122), .D(n166), .Y(n99) );
  sky130_fd_sc_hd__o221ai_1 U321 ( .A1(n159), .A2(n93), .B1(n155), .B2(n92), 
        .C1(n94), .Y(apb4_prdata[3]) );
  sky130_fd_sc_hd__nor3b_1 U322 ( .C_N(apb4_paddr[2]), .A(apb4_paddr[3]), .B(
        apb4_paddr[4]), .Y(n107) );
  sky130_fd_sc_hd__inv_2 U323 ( .A(apb4_pwdata[9]), .Y(n177) );
  sky130_fd_sc_hd__inv_2 U324 ( .A(apb4_pwdata[4]), .Y(n182) );
  sky130_fd_sc_hd__inv_2 U325 ( .A(apb4_pwdata[18]), .Y(n168) );
  sky130_fd_sc_hd__inv_2 U326 ( .A(apb4_pwdata[7]), .Y(n179) );
  sky130_fd_sc_hd__inv_2 U327 ( .A(apb4_pwdata[16]), .Y(n170) );
  sky130_fd_sc_hd__inv_2 U328 ( .A(apb4_pwdata[3]), .Y(n183) );
  sky130_fd_sc_hd__inv_2 U329 ( .A(apb4_pwdata[8]), .Y(n178) );
  sky130_fd_sc_hd__inv_2 U330 ( .A(apb4_pwdata[17]), .Y(n169) );
  sky130_fd_sc_hd__mux2_2 U331 ( .A0(s_inclk), .A1(timer_exclk_i), .S(N0), .X(
        s_tr_clk) );
  sky130_fd_sc_hd__inv_2 U332 ( .A(apb4_pwdata[2]), .Y(n184) );
  sky130_fd_sc_hd__inv_2 U333 ( .A(apb4_paddr[4]), .Y(n166) );
  sky130_fd_sc_hd__and4_1 U334 ( .A(apb4_penable), .B(apb4_psel), .C(
        apb4_pwrite), .D(n118), .X(n108) );
  sky130_fd_sc_hd__inv_2 U335 ( .A(apb4_pwdata[12]), .Y(n174) );
  sky130_fd_sc_hd__inv_2 U336 ( .A(apb4_pwdata[13]), .Y(n173) );
  sky130_fd_sc_hd__inv_2 U337 ( .A(apb4_pwdata[14]), .Y(n172) );
  sky130_fd_sc_hd__inv_2 U338 ( .A(apb4_pwdata[6]), .Y(n180) );
  sky130_fd_sc_hd__inv_2 U339 ( .A(apb4_pwdata[5]), .Y(n181) );
  sky130_fd_sc_hd__inv_2 U340 ( .A(apb4_pwdata[11]), .Y(n175) );
  sky130_fd_sc_hd__inv_2 U341 ( .A(apb4_pwdata[15]), .Y(n171) );
  sky130_fd_sc_hd__inv_2 U342 ( .A(apb4_pwdata[19]), .Y(n167) );
  sky130_fd_sc_hd__inv_2 U343 ( .A(apb4_pwdata[0]), .Y(n186) );
  sky130_fd_sc_hd__inv_2 U344 ( .A(apb4_pwdata[10]), .Y(n176) );
  sky130_fd_sc_hd__inv_2 U345 ( .A(s_tim_pscr_q[9]), .Y(n149) );
  sky130_fd_sc_hd__conb_1 U346 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__o221ai_1 U347 ( .A1(n161), .A2(n93), .B1(n157), .B2(n92), 
        .C1(n96), .Y(apb4_prdata[1]) );
  sky130_fd_sc_hd__o22ai_1 U348 ( .A1(n165), .A2(n157), .B1(n74), .B2(n72), 
        .Y(s_tim_pscr_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U349 ( .A1(n165), .A2(n148), .B1(n73), .B2(n176), 
        .Y(s_tim_pscr_d[10]) );
  sky130_fd_sc_hd__o221ai_1 U350 ( .A1(n160), .A2(n93), .B1(n156), .B2(n111), 
        .C1(n95), .Y(apb4_prdata[2]) );
  sky130_fd_sc_hd__o22ai_1 U351 ( .A1(n165), .A2(n156), .B1(n73), .B2(n184), 
        .Y(s_tim_pscr_d[2]) );
  sky130_fd_sc_hd__inv_1 U352 ( .A(s_tim_pscr_q[11]), .Y(n147) );
  sky130_fd_sc_hd__inv_2 U353 ( .A(n110), .Y(n156) );
  sky130_fd_sc_hd__inv_1 U354 ( .A(n109), .Y(n157) );
  sky130_fd_sc_hd__inv_1 U355 ( .A(apb4_paddr[5]), .Y(n118) );
  sky130_fd_sc_hd__nand2_1 U356 ( .A(n108), .B(n107), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U357 ( .A(s_done), .Y(n117) );
  sky130_fd_sc_hd__nor2_1 U358 ( .A(n72), .B(n117), .Y(s_valid) );
endmodule

