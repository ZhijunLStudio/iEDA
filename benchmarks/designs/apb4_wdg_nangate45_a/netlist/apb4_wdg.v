/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 13:37:49 2025
/////////////////////////////////////////////////////////////


module dffr_DATA_WIDTH3_0 ( clk_i, rst_n_i, dat_i, dat_o );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
endmodule


module dffr_DATA_WIDTH20 ( clk_i, rst_n_i, dat_i, dat_o );
  input [19:0] dat_i;
  output [19:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
endmodule


module dffr_DATA_WIDTH3_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [2:0] dat_i;
  output [2:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
endmodule


module dffr_DATA_WIDTH1_3 ( clk_i, rst_n_i, dat_i, dat_o );
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
         n30, n31, n32, n33, n36, n37, n38, n41, n42, n43, n44, n48, n49, n50,
         n53, n54, n55, n57, n60, n61, n62, n65, n66, n67, n70, n72, n73, n75,
         n76, n77, n78, n79, n81, n82, n83, n85, n86, n87, n89, n91, n92, n93,
         n96, n97, n98, n100, n107, n153, n154, n155, n156, n157, n158, n159,
         n160, n161, n162, n163, n164, n165, n166, n167, n168, n169, n170,
         n171, n172, n173, n174, n175, n176, n177, n178, n179, n180, n181,
         n182, n183;
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

  sky130_fd_sc_hd__xor2_1 U2 ( .A(n22), .B(n1), .X(SUM[18]) );
  sky130_fd_sc_hd__nor2_1 U3 ( .A(n20), .B(n179), .Y(SUM[19]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n24), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n3), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__xor2_1 U19 ( .A(n36), .B(n4), .X(SUM[15]) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(n43), .B(n33), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U23 ( .A(n4), .B(n5), .Y(n33) );
  sky130_fd_sc_hd__xor2_1 U27 ( .A(n41), .B(n5), .X(SUM[14]) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n37), .B(n75), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n38), .B(n55), .Y(n37) );
  sky130_fd_sc_hd__nor2_1 U30 ( .A(n5), .B(n44), .Y(n38) );
  sky130_fd_sc_hd__xor2_1 U34 ( .A(n6), .B(n48), .X(SUM[13]) );
  sky130_fd_sc_hd__nor2_1 U35 ( .A(n42), .B(n75), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n55), .B(n168), .Y(n42) );
  sky130_fd_sc_hd__xor2_1 U43 ( .A(n53), .B(n7), .X(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n55), .B(n50), .Y(n49) );
  sky130_fd_sc_hd__xor2_1 U50 ( .A(n60), .B(n8), .X(SUM[11]) );
  sky130_fd_sc_hd__nor2_1 U51 ( .A(n182), .B(n75), .Y(n53) );
  sky130_fd_sc_hd__xor2_1 U59 ( .A(n65), .B(n164), .X(SUM[10]) );
  sky130_fd_sc_hd__nor2_1 U60 ( .A(n61), .B(n75), .Y(n60) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n183), .B(n62), .Y(n61) );
  sky130_fd_sc_hd__xor2_1 U66 ( .A(n72), .B(n156), .X(SUM[9]) );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(n66), .B(n75), .Y(n65) );
  sky130_fd_sc_hd__xnor2_1 U75 ( .A(n75), .B(n160), .Y(SUM[8]) );
  sky130_fd_sc_hd__nor2_1 U76 ( .A(n160), .B(n75), .Y(n72) );
  sky130_fd_sc_hd__xnor2_1 U80 ( .A(n79), .B(n81), .Y(SUM[7]) );
  sky130_fd_sc_hd__nor2_1 U84 ( .A(n79), .B(n83), .Y(n78) );
  sky130_fd_sc_hd__xnor2_1 U88 ( .A(n83), .B(n85), .Y(SUM[6]) );
  sky130_fd_sc_hd__nand2_1 U89 ( .A(n162), .B(n82), .Y(n81) );
  sky130_fd_sc_hd__nor2_1 U90 ( .A(n83), .B(n87), .Y(n82) );
  sky130_fd_sc_hd__xnor2_1 U94 ( .A(n158), .B(n91), .Y(SUM[5]) );
  sky130_fd_sc_hd__nand2_1 U95 ( .A(n162), .B(n181), .Y(n85) );
  sky130_fd_sc_hd__xor2_1 U102 ( .A(n162), .B(n165), .X(SUM[4]) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n171), .B(n92), .Y(n91) );
  sky130_fd_sc_hd__xnor2_1 U115 ( .A(n169), .B(n161), .Y(SUM[2]) );
  sky130_fd_sc_hd__dlygate4sd1_1 U131 ( .A(n98), .X(n153) );
  sky130_fd_sc_hd__nand2_1 U132 ( .A(n178), .B(n154), .Y(n170) );
  sky130_fd_sc_hd__clkinv_16 U133 ( .A(n3), .Y(n154) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(n96), .Y(n171) );
  sky130_fd_sc_hd__nor2_1 U135 ( .A(n49), .B(n75), .Y(n48) );
  sky130_fd_sc_hd__nor2_2 U136 ( .A(n6), .B(n7), .Y(n43) );
  sky130_fd_sc_hd__inv_1 U137 ( .A(n70), .Y(n155) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(n155), .Y(n156) );
  sky130_fd_sc_hd__xnor2_1 U139 ( .A(n177), .B(SUM[0]), .Y(SUM[1]) );
  sky130_fd_sc_hd__nor2_2 U140 ( .A(n98), .B(n17), .Y(n97) );
  sky130_fd_sc_hd__inv_1 U141 ( .A(n89), .Y(n157) );
  sky130_fd_sc_hd__inv_1 U142 ( .A(n157), .Y(n158) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(n73), .Y(n159) );
  sky130_fd_sc_hd__inv_1 U144 ( .A(n159), .Y(n160) );
  sky130_fd_sc_hd__inv_1 U145 ( .A(n163), .Y(n161) );
  sky130_fd_sc_hd__inv_1 U146 ( .A(n163), .Y(n176) );
  sky130_fd_sc_hd__inv_1 U147 ( .A(n96), .Y(n162) );
  sky130_fd_sc_hd__nor2_1 U148 ( .A(n107), .B(n18), .Y(n163) );
  sky130_fd_sc_hd__nor2_1 U149 ( .A(n107), .B(n18), .Y(n180) );
  sky130_fd_sc_hd__clkbuf_1 U150 ( .A(n17), .X(n169) );
  sky130_fd_sc_hd__nor2b_2 U151 ( .B_N(n24), .A(n179), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U152 ( .A(n178), .Y(n179) );
  sky130_fd_sc_hd__inv_1 U153 ( .A(n62), .Y(n164) );
  sky130_fd_sc_hd__dlygate4sd1_1 U154 ( .A(n93), .X(n165) );
  sky130_fd_sc_hd__inv_1 U155 ( .A(n172), .Y(n166) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U156 ( .A(n18), .X(n167) );
  sky130_fd_sc_hd__inv_1 U157 ( .A(n44), .Y(n168) );
  sky130_fd_sc_hd__nor2_1 U158 ( .A(n77), .B(n96), .Y(n76) );
  sky130_fd_sc_hd__xnor2_1 U159 ( .A(n25), .B(n170), .Y(SUM[17]) );
  sky130_fd_sc_hd__xnor2_1 U160 ( .A(n3), .B(n30), .Y(SUM[16]) );
  sky130_fd_sc_hd__nand2b_4 U161 ( .A_N(n77), .B(n171), .Y(n75) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(n100), .Y(n173) );
  sky130_fd_sc_hd__nor2_2 U163 ( .A(n169), .B(n176), .Y(n100) );
  sky130_fd_sc_hd__nand2_1 U164 ( .A(n173), .B(n166), .Y(n174) );
  sky130_fd_sc_hd__nand2_1 U165 ( .A(n172), .B(n100), .Y(n175) );
  sky130_fd_sc_hd__nand2_1 U166 ( .A(n174), .B(n175), .Y(SUM[3]) );
  sky130_fd_sc_hd__inv_1 U167 ( .A(n153), .Y(n172) );
  sky130_fd_sc_hd__nand2_1 U168 ( .A(n86), .B(n78), .Y(n77) );
  sky130_fd_sc_hd__nor2_1 U169 ( .A(n89), .B(n93), .Y(n86) );
  sky130_fd_sc_hd__clkinv_1 U170 ( .A(n1), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U171 ( .A(n76), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__nor2_1 U172 ( .A(n54), .B(n32), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U173 ( .A(n7), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U174 ( .A(n167), .Y(n177) );
  sky130_fd_sc_hd__inv_1 U175 ( .A(n30), .Y(n178) );
  sky130_fd_sc_hd__nor2_1 U176 ( .A(n89), .B(n93), .Y(n181) );
  sky130_fd_sc_hd__inv_1 U177 ( .A(n55), .Y(n182) );
  sky130_fd_sc_hd__inv_1 U178 ( .A(n54), .Y(n55) );
  sky130_fd_sc_hd__inv_1 U179 ( .A(n43), .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U180 ( .A(n67), .B(n57), .Y(n54) );
  sky130_fd_sc_hd__inv_1 U181 ( .A(n9), .Y(n62) );
  sky130_fd_sc_hd__nor2_1 U182 ( .A(n9), .B(n8), .Y(n57) );
  sky130_fd_sc_hd__nor2_1 U183 ( .A(n156), .B(n160), .Y(n183) );
  sky130_fd_sc_hd__nor2_1 U184 ( .A(n70), .B(n73), .Y(n67) );
  sky130_fd_sc_hd__nand2_2 U185 ( .A(n180), .B(n97), .Y(n96) );
  sky130_fd_sc_hd__inv_1 U186 ( .A(n107), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U187 ( .A(n181), .Y(n87) );
  sky130_fd_sc_hd__clkinv_1 U188 ( .A(n93), .Y(n92) );
  sky130_fd_sc_hd__inv_1 U189 ( .A(n183), .Y(n66) );
endmodule


module clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_inc_1 ( A, SUM );
  input [19:0] A;
  output [19:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n9, n10, n12, n13, n14, n15, n16, n18,
         n19, n20, n21, n23, n24, n25, n28, n30, n31, n33, n34, n35, n36, n37,
         n39, n40, n42, n43, n45, n46, n47, n48, n49, n52, n54, n55, n57, n58,
         n59, n60, n61, n63, n64, n66, n67, n68, n70, n72, n73, n74, n75, n76,
         n77, n79, n80, n82, n83, n84, n86;
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
  sky130_fd_sc_hd__nand2_1 U98 ( .A(n82), .B(n80), .Y(n79) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n84), .B(n86), .Y(n83) );
  sky130_fd_sc_hd__xnor2_1 U110 ( .A(n18), .B(n16), .Y(SUM[15]) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(n49), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U112 ( .A(n6), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(n75), .Y(n74) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(n58), .Y(n57) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(n36), .Y(n37) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(n83), .Y(n82) );
  sky130_fd_sc_hd__xor2_1 U117 ( .A(n86), .B(n84), .X(SUM[1]) );
  sky130_fd_sc_hd__xor2_1 U118 ( .A(n80), .B(n82), .X(SUM[2]) );
  sky130_fd_sc_hd__xor2_1 U119 ( .A(n68), .B(n70), .X(SUM[5]) );
  sky130_fd_sc_hd__xor2_1 U120 ( .A(n64), .B(n66), .X(SUM[6]) );
  sky130_fd_sc_hd__xor2_1 U121 ( .A(n55), .B(n57), .X(SUM[8]) );
  sky130_fd_sc_hd__xor2_1 U122 ( .A(n10), .B(n12), .X(SUM[16]) );
  sky130_fd_sc_hd__xnor2_1 U123 ( .A(n79), .B(n77), .Y(SUM[3]) );
  sky130_fd_sc_hd__xnor2_1 U124 ( .A(n63), .B(n61), .Y(SUM[7]) );
  sky130_fd_sc_hd__xnor2_1 U125 ( .A(n54), .B(n52), .Y(SUM[9]) );
  sky130_fd_sc_hd__xnor2_1 U126 ( .A(n42), .B(n40), .Y(SUM[11]) );
  sky130_fd_sc_hd__xnor2_1 U127 ( .A(n30), .B(n28), .Y(SUM[13]) );
  sky130_fd_sc_hd__xnor2_1 U128 ( .A(n23), .B(n21), .Y(SUM[14]) );
  sky130_fd_sc_hd__xnor2_1 U129 ( .A(n9), .B(n7), .Y(SUM[17]) );
  sky130_fd_sc_hd__xnor2_1 U130 ( .A(A[19]), .B(n1), .Y(SUM[19]) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(n86), .Y(SUM[0]) );
  sky130_fd_sc_hd__nand2b_1 U132 ( .A_N(n25), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U133 ( .A(n45), .Y(n46) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(n33), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U135 ( .A(A[18]), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U136 ( .A(n72), .Y(n73) );
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
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n31,
         n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
         n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73;
  wire   [19:0] s_cnt_q;
  wire   [19:0] s_cnt_d;
  wire   [2:0] s_div_done_q;
  wire   [2:0] s_div_done_d;

  dffr_DATA_WIDTH20 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_cnt_d), .dat_o(s_cnt_q) );
  dffr_DATA_WIDTH3_1 u_ready_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i({
        n73, s_div_done_d[1:0]}), .dat_o(s_div_done_q) );
  dffr_DATA_WIDTH1_3 u_clk_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_clk_d), .dat_o(clk_o) );
  clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_dec_1 r378 ( .A({n1, 
        div_i[19:1]}), .SUM({N41, N40, N39, N38, N37, N36, N35, N34, N33, N32, 
        N31, N30, N29, N28, N27, N26, N25, N24, N23, N22}) );
  clk_int_even_div_simple_DIV_VALUE_WIDTH20_DW01_inc_1 add_160 ( .A(s_cnt_q), 
        .SUM({N21, N20, N19, N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, 
        N8, N7, N6, N5, N4, N3, N2}) );
  sky130_fd_sc_hd__and2_1 U3 ( .A(n67), .B(N3), .X(s_cnt_d[1]) );
  sky130_fd_sc_hd__nor2b_1 U4 ( .B_N(n67), .A(n2), .Y(s_cnt_d[5]) );
  sky130_fd_sc_hd__clkinv_16 U5 ( .A(N7), .Y(n2) );
  sky130_fd_sc_hd__nor2b_1 U6 ( .B_N(n71), .A(n3), .Y(s_cnt_d[0]) );
  sky130_fd_sc_hd__clkinv_16 U7 ( .A(N2), .Y(n3) );
  sky130_fd_sc_hd__nor2b_1 U8 ( .B_N(n67), .A(n4), .Y(s_cnt_d[4]) );
  sky130_fd_sc_hd__clkinv_16 U9 ( .A(N6), .Y(n4) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(N35), .Y(n15) );
  sky130_fd_sc_hd__nor3_2 U11 ( .A(n47), .B(n46), .C(n13), .Y(n29) );
  sky130_fd_sc_hd__nand2b_1 U12 ( .A_N(n6), .B(N25), .Y(n8) );
  sky130_fd_sc_hd__clkinv_1 U13 ( .A(N25), .Y(n7) );
  sky130_fd_sc_hd__xnor2_1 U14 ( .A(s_cnt_q[4]), .B(N26), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(N41), .B(s_cnt_q[19]), .Y(n32) );
  sky130_fd_sc_hd__nor2_2 U16 ( .A(n54), .B(n55), .Y(n64) );
  sky130_fd_sc_hd__nand2_1 U17 ( .A(n6), .B(n7), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n9), .B(n8), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(s_cnt_q[3]), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U20 ( .A(s_cnt_q[13]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(s_cnt_q[18]), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(clk_o), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(N10), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(N5), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(N18), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U26 ( .A(N17), .Y(n21) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(n66), .Y(n67) );
  sky130_fd_sc_hd__xnor2_1 U28 ( .A(n10), .B(n72), .Y(s_clk_d) );
  sky130_fd_sc_hd__o21ai_0 U29 ( .A1(div_valid_i), .A2(n63), .B1(n62), .Y(n73)
         );
  sky130_fd_sc_hd__nor2b_1 U30 ( .B_N(n71), .A(n11), .Y(s_cnt_d[3]) );
  sky130_fd_sc_hd__nor2b_1 U31 ( .B_N(n67), .A(n12), .Y(s_cnt_d[16]) );
  sky130_fd_sc_hd__nand4_1 U32 ( .A(n44), .B(n43), .C(n42), .D(n41), .Y(n13)
         );
  sky130_fd_sc_hd__nand4_1 U33 ( .A(n44), .B(n43), .C(n42), .D(n41), .Y(n45)
         );
  sky130_fd_sc_hd__clkinv_1 U34 ( .A(n19), .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U35 ( .A(N35), .B(s_cnt_q[13]), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n14), .B(n15), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U37 ( .A(n16), .B(n17), .Y(n33) );
  sky130_fd_sc_hd__xnor2_1 U38 ( .A(N38), .B(s_cnt_q[16]), .Y(n31) );
  sky130_fd_sc_hd__nand4_1 U39 ( .A(n18), .B(n5), .C(n31), .D(n32), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U40 ( .A(n23), .Y(n18) );
  sky130_fd_sc_hd__nor2b_1 U41 ( .B_N(n67), .A(n20), .Y(s_cnt_d[8]) );
  sky130_fd_sc_hd__nor2b_1 U42 ( .B_N(n71), .A(n21), .Y(s_cnt_d[15]) );
  sky130_fd_sc_hd__inv_1 U43 ( .A(n72), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U44 ( .A(n59), .Y(n72) );
  sky130_fd_sc_hd__and2_1 U45 ( .A(n67), .B(N12), .X(s_cnt_d[10]) );
  sky130_fd_sc_hd__and2_1 U46 ( .A(n71), .B(N14), .X(s_cnt_d[12]) );
  sky130_fd_sc_hd__and2_1 U47 ( .A(n71), .B(N20), .X(s_cnt_d[18]) );
  sky130_fd_sc_hd__and2_1 U48 ( .A(n71), .B(N15), .X(s_cnt_d[13]) );
  sky130_fd_sc_hd__and2_1 U49 ( .A(n71), .B(N19), .X(s_cnt_d[17]) );
  sky130_fd_sc_hd__and2_1 U50 ( .A(n67), .B(N13), .X(s_cnt_d[11]) );
  sky130_fd_sc_hd__and2_1 U51 ( .A(n67), .B(N16), .X(s_cnt_d[14]) );
  sky130_fd_sc_hd__and2_1 U52 ( .A(n71), .B(N21), .X(s_cnt_d[19]) );
  sky130_fd_sc_hd__and2_1 U53 ( .A(n71), .B(N8), .X(s_cnt_d[6]) );
  sky130_fd_sc_hd__and2_1 U54 ( .A(n67), .B(N9), .X(s_cnt_d[7]) );
  sky130_fd_sc_hd__and2_1 U55 ( .A(n67), .B(N11), .X(s_cnt_d[9]) );
  sky130_fd_sc_hd__nand4_1 U56 ( .A(n35), .B(n37), .C(n36), .D(n38), .Y(n23)
         );
  sky130_fd_sc_hd__nand2_1 U57 ( .A(N39), .B(s_cnt_q[17]), .Y(n26) );
  sky130_fd_sc_hd__nand2_1 U58 ( .A(n24), .B(n25), .Y(n27) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n26), .B(n27), .Y(n34) );
  sky130_fd_sc_hd__inv_1 U60 ( .A(N39), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(s_cnt_q[17]), .Y(n25) );
  sky130_fd_sc_hd__xnor2_1 U62 ( .A(n28), .B(N40), .Y(n46) );
  sky130_fd_sc_hd__nor3_1 U63 ( .A(n47), .B(n46), .C(n45), .Y(n65) );
  sky130_fd_sc_hd__nand2b_1 U64 ( .A_N(s_div_done_q[0]), .B(n68), .Y(n56) );
  sky130_fd_sc_hd__nor2_1 U65 ( .A(n40), .B(n39), .Y(n41) );
  sky130_fd_sc_hd__and3_1 U66 ( .A(s_div_done_q[1]), .B(s_div_done_q[2]), .C(
        s_div_done_q[0]), .X(div_done_o) );
  sky130_fd_sc_hd__conb_1 U67 ( .LO(n1), .HI(div_ready_o) );
  sky130_fd_sc_hd__inv_2 U68 ( .A(n70), .Y(n71) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n34), .B(n33), .Y(n47) );
  sky130_fd_sc_hd__xnor2_1 U70 ( .A(s_cnt_q[2]), .B(N24), .Y(n38) );
  sky130_fd_sc_hd__xnor2_1 U71 ( .A(s_cnt_q[0]), .B(N22), .Y(n37) );
  sky130_fd_sc_hd__xnor2_1 U72 ( .A(N23), .B(s_cnt_q[1]), .Y(n36) );
  sky130_fd_sc_hd__xnor2_1 U73 ( .A(s_cnt_q[8]), .B(N30), .Y(n43) );
  sky130_fd_sc_hd__xnor2_1 U74 ( .A(s_cnt_q[7]), .B(N29), .Y(n42) );
  sky130_fd_sc_hd__xor2_1 U75 ( .A(s_cnt_q[5]), .B(N27), .X(n40) );
  sky130_fd_sc_hd__xor2_1 U76 ( .A(s_cnt_q[6]), .B(N28), .X(n39) );
  sky130_fd_sc_hd__xnor2_1 U77 ( .A(s_cnt_q[15]), .B(N37), .Y(n51) );
  sky130_fd_sc_hd__xnor2_1 U78 ( .A(s_cnt_q[14]), .B(N36), .Y(n50) );
  sky130_fd_sc_hd__xnor2_1 U79 ( .A(s_cnt_q[12]), .B(N34), .Y(n49) );
  sky130_fd_sc_hd__xnor2_1 U80 ( .A(N31), .B(s_cnt_q[9]), .Y(n48) );
  sky130_fd_sc_hd__nand4_1 U81 ( .A(n51), .B(n50), .C(n49), .D(n48), .Y(n55)
         );
  sky130_fd_sc_hd__xnor2_1 U82 ( .A(s_cnt_q[10]), .B(N32), .Y(n53) );
  sky130_fd_sc_hd__xnor2_1 U83 ( .A(s_cnt_q[11]), .B(N33), .Y(n52) );
  sky130_fd_sc_hd__nand2_1 U84 ( .A(n53), .B(n52), .Y(n54) );
  sky130_fd_sc_hd__nand2_1 U85 ( .A(n65), .B(n64), .Y(n59) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(div_valid_i), .Y(n68) );
  sky130_fd_sc_hd__nand2_1 U87 ( .A(s_div_done_q[0]), .B(n68), .Y(n57) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(div_done_o), .B(n68), .Y(n60) );
  sky130_fd_sc_hd__o221ai_1 U89 ( .A1(n57), .A2(n72), .B1(n56), .B2(n22), .C1(
        n60), .Y(s_div_done_d[0]) );
  sky130_fd_sc_hd__mux2i_1 U90 ( .A0(n57), .A1(n56), .S(s_div_done_q[1]), .Y(
        n58) );
  sky130_fd_sc_hd__a32oi_1 U91 ( .A1(n59), .A2(n68), .A3(s_div_done_q[1]), 
        .B1(n72), .B2(n58), .Y(n61) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(n61), .B(n60), .Y(s_div_done_d[1]) );
  sky130_fd_sc_hd__inv_1 U93 ( .A(s_div_done_q[2]), .Y(n63) );
  sky130_fd_sc_hd__nand4_1 U94 ( .A(n72), .B(s_div_done_q[1]), .C(n68), .D(
        s_div_done_q[0]), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U95 ( .A(n29), .B(n64), .Y(n69) );
  sky130_fd_sc_hd__nand2_1 U96 ( .A(n69), .B(n68), .Y(n66) );
  sky130_fd_sc_hd__and2_0 U97 ( .A(n71), .B(N4), .X(s_cnt_d[2]) );
  sky130_fd_sc_hd__nand2_1 U98 ( .A(n69), .B(n68), .Y(n70) );
endmodule


module dffr_DATA_WIDTH32_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [31:0] dat_i;
  output [31:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3;

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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(n1), .RESET_B(
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(n2), .RESET_B(
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


module dffr_DATA_WIDTH32_2 ( clk_i, rst_n_i, dat_i, dat_o );
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


module cdc_sync_STAGE2_DATA_WIDTH1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;
  wire   s_sync_dat_0__0_;

  dffr_DATA_WIDTH1_2 genblk1_0__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(dat_i[0]), .dat_o(s_sync_dat_0__0_) );
  dffr_DATA_WIDTH1_1 genblk1_1__genblk1_u_sync_dffr ( .clk_i(clk_i), .rst_n_i(
        rst_n_i), .dat_i(s_sync_dat_0__0_), .dat_o(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH1_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH32_1 ( clk_i, rst_n_i, dat_i, dat_o );
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


module apb4_wdg_DW01_inc_0_DW01_inc_1 ( A, SUM );
  input [31:0] A;
  output [31:0] SUM;

  wire   [31:2] carry;

  sky130_fd_sc_hd__ha_1 U1_1_30 ( .A(A[30]), .B(carry[30]), .COUT(carry[31]), 
        .SUM(SUM[30]) );
  sky130_fd_sc_hd__ha_1 U1_1_29 ( .A(A[29]), .B(carry[29]), .COUT(carry[30]), 
        .SUM(SUM[29]) );
  sky130_fd_sc_hd__ha_1 U1_1_28 ( .A(A[28]), .B(carry[28]), .COUT(carry[29]), 
        .SUM(SUM[28]) );
  sky130_fd_sc_hd__ha_1 U1_1_27 ( .A(A[27]), .B(carry[27]), .COUT(carry[28]), 
        .SUM(SUM[27]) );
  sky130_fd_sc_hd__ha_1 U1_1_26 ( .A(A[26]), .B(carry[26]), .COUT(carry[27]), 
        .SUM(SUM[26]) );
  sky130_fd_sc_hd__ha_1 U1_1_25 ( .A(A[25]), .B(carry[25]), .COUT(carry[26]), 
        .SUM(SUM[25]) );
  sky130_fd_sc_hd__ha_1 U1_1_24 ( .A(A[24]), .B(carry[24]), .COUT(carry[25]), 
        .SUM(SUM[24]) );
  sky130_fd_sc_hd__ha_1 U1_1_23 ( .A(A[23]), .B(carry[23]), .COUT(carry[24]), 
        .SUM(SUM[23]) );
  sky130_fd_sc_hd__ha_1 U1_1_22 ( .A(A[22]), .B(carry[22]), .COUT(carry[23]), 
        .SUM(SUM[22]) );
  sky130_fd_sc_hd__ha_1 U1_1_21 ( .A(A[21]), .B(carry[21]), .COUT(carry[22]), 
        .SUM(SUM[21]) );
  sky130_fd_sc_hd__ha_1 U1_1_20 ( .A(A[20]), .B(carry[20]), .COUT(carry[21]), 
        .SUM(SUM[20]) );
  sky130_fd_sc_hd__ha_1 U1_1_19 ( .A(A[19]), .B(carry[19]), .COUT(carry[20]), 
        .SUM(SUM[19]) );
  sky130_fd_sc_hd__ha_1 U1_1_18 ( .A(A[18]), .B(carry[18]), .COUT(carry[19]), 
        .SUM(SUM[18]) );
  sky130_fd_sc_hd__ha_1 U1_1_17 ( .A(A[17]), .B(carry[17]), .COUT(carry[18]), 
        .SUM(SUM[17]) );
  sky130_fd_sc_hd__ha_1 U1_1_16 ( .A(A[16]), .B(carry[16]), .COUT(carry[17]), 
        .SUM(SUM[16]) );
  sky130_fd_sc_hd__ha_1 U1_1_15 ( .A(A[15]), .B(carry[15]), .COUT(carry[16]), 
        .SUM(SUM[15]) );
  sky130_fd_sc_hd__ha_1 U1_1_14 ( .A(A[14]), .B(carry[14]), .COUT(carry[15]), 
        .SUM(SUM[14]) );
  sky130_fd_sc_hd__ha_1 U1_1_13 ( .A(A[13]), .B(carry[13]), .COUT(carry[14]), 
        .SUM(SUM[13]) );
  sky130_fd_sc_hd__ha_1 U1_1_12 ( .A(A[12]), .B(carry[12]), .COUT(carry[13]), 
        .SUM(SUM[12]) );
  sky130_fd_sc_hd__ha_1 U1_1_11 ( .A(A[11]), .B(carry[11]), .COUT(carry[12]), 
        .SUM(SUM[11]) );
  sky130_fd_sc_hd__ha_1 U1_1_10 ( .A(A[10]), .B(carry[10]), .COUT(carry[11]), 
        .SUM(SUM[10]) );
  sky130_fd_sc_hd__ha_1 U1_1_9 ( .A(A[9]), .B(carry[9]), .COUT(carry[10]), 
        .SUM(SUM[9]) );
  sky130_fd_sc_hd__ha_1 U1_1_8 ( .A(A[8]), .B(carry[8]), .COUT(carry[9]), 
        .SUM(SUM[8]) );
  sky130_fd_sc_hd__ha_1 U1_1_7 ( .A(A[7]), .B(carry[7]), .COUT(carry[8]), 
        .SUM(SUM[7]) );
  sky130_fd_sc_hd__ha_1 U1_1_6 ( .A(A[6]), .B(carry[6]), .COUT(carry[7]), 
        .SUM(SUM[6]) );
  sky130_fd_sc_hd__ha_1 U1_1_5 ( .A(A[5]), .B(carry[5]), .COUT(carry[6]), 
        .SUM(SUM[5]) );
  sky130_fd_sc_hd__ha_1 U1_1_4 ( .A(A[4]), .B(carry[4]), .COUT(carry[5]), 
        .SUM(SUM[4]) );
  sky130_fd_sc_hd__ha_1 U1_1_3 ( .A(A[3]), .B(carry[3]), .COUT(carry[4]), 
        .SUM(SUM[3]) );
  sky130_fd_sc_hd__ha_1 U1_1_2 ( .A(A[2]), .B(carry[2]), .COUT(carry[3]), 
        .SUM(SUM[2]) );
  sky130_fd_sc_hd__ha_1 U1_1_1 ( .A(A[1]), .B(A[0]), .COUT(carry[2]), .SUM(
        SUM[1]) );
  sky130_fd_sc_hd__inv_2 U1 ( .A(A[0]), .Y(SUM[0]) );
  sky130_fd_sc_hd__xor2_1 U2 ( .A(carry[31]), .B(A[31]), .X(SUM[31]) );
endmodule


module apb4_wdg_DW_cmp_1 ( A, B, TC, GE_LT, GE_GT_EQ, GE_LT_GT_LE, EQ_NE );
  input [31:0] A;
  input [31:0] B;
  input TC, GE_LT, GE_GT_EQ;
  output GE_LT_GT_LE, EQ_NE;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n124, n125, n126,
         n127, n128, n129, n130, n131, n132, n133, n134, n135, n136, n137,
         n138, n139, n140, n141, n142, n143, n144, n145, n146, n147, n148,
         n149, n150, n151, n152, n153, n154, n155, n231, n232;

  sky130_fd_sc_hd__o21ai_1 U1 ( .A1(n1), .A2(n63), .B1(n2), .Y(GE_LT_GT_LE) );
  sky130_fd_sc_hd__nand2_1 U2 ( .A(n3), .B(n33), .Y(n1) );
  sky130_fd_sc_hd__a21oi_1 U3 ( .A1(n34), .A2(n3), .B1(n4), .Y(n2) );
  sky130_fd_sc_hd__nor2_1 U4 ( .A(n5), .B(n19), .Y(n3) );
  sky130_fd_sc_hd__o21ai_1 U5 ( .A1(n5), .A2(n20), .B1(n6), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U6 ( .A(n13), .B(n7), .Y(n5) );
  sky130_fd_sc_hd__a21oi_1 U7 ( .A1(n7), .A2(n14), .B1(n8), .Y(n6) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n9), .B(n11), .Y(n7) );
  sky130_fd_sc_hd__o21ai_1 U9 ( .A1(n12), .A2(n9), .B1(n10), .Y(n8) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(A[31]), .B(n155), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n155), .B(A[31]), .Y(n10) );
  sky130_fd_sc_hd__nor2_1 U12 ( .A(A[30]), .B(n154), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n154), .B(A[30]), .Y(n12) );
  sky130_fd_sc_hd__nor2_1 U14 ( .A(n15), .B(n17), .Y(n13) );
  sky130_fd_sc_hd__o21ai_1 U15 ( .A1(n18), .A2(n15), .B1(n16), .Y(n14) );
  sky130_fd_sc_hd__nor2_1 U16 ( .A(A[29]), .B(n153), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U17 ( .A(n153), .B(A[29]), .Y(n16) );
  sky130_fd_sc_hd__nor2_1 U18 ( .A(A[28]), .B(n152), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(n152), .B(A[28]), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n27), .B(n21), .Y(n19) );
  sky130_fd_sc_hd__a21oi_1 U21 ( .A1(n21), .A2(n28), .B1(n22), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U22 ( .A(n23), .B(n25), .Y(n21) );
  sky130_fd_sc_hd__o21ai_1 U23 ( .A1(n26), .A2(n23), .B1(n24), .Y(n22) );
  sky130_fd_sc_hd__nor2_1 U24 ( .A(A[27]), .B(n151), .Y(n23) );
  sky130_fd_sc_hd__nand2_1 U25 ( .A(n151), .B(A[27]), .Y(n24) );
  sky130_fd_sc_hd__nor2_1 U26 ( .A(A[26]), .B(n150), .Y(n25) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(n150), .B(A[26]), .Y(n26) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n29), .B(n31), .Y(n27) );
  sky130_fd_sc_hd__o21ai_1 U29 ( .A1(n32), .A2(n29), .B1(n30), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U30 ( .A(A[25]), .B(n149), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U31 ( .A(n149), .B(A[25]), .Y(n30) );
  sky130_fd_sc_hd__nor2_1 U32 ( .A(A[24]), .B(n148), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n148), .B(A[24]), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U34 ( .A(n35), .B(n49), .Y(n33) );
  sky130_fd_sc_hd__o21ai_1 U35 ( .A1(n35), .A2(n50), .B1(n36), .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n37), .B(n43), .Y(n35) );
  sky130_fd_sc_hd__a21oi_1 U37 ( .A1(n37), .A2(n44), .B1(n38), .Y(n36) );
  sky130_fd_sc_hd__nor2_1 U38 ( .A(n39), .B(n41), .Y(n37) );
  sky130_fd_sc_hd__o21ai_1 U39 ( .A1(n42), .A2(n39), .B1(n40), .Y(n38) );
  sky130_fd_sc_hd__nor2_1 U40 ( .A(A[23]), .B(n147), .Y(n39) );
  sky130_fd_sc_hd__nand2_1 U41 ( .A(n147), .B(A[23]), .Y(n40) );
  sky130_fd_sc_hd__nor2_1 U42 ( .A(A[22]), .B(n146), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(n146), .B(A[22]), .Y(n42) );
  sky130_fd_sc_hd__nor2_1 U44 ( .A(n45), .B(n47), .Y(n43) );
  sky130_fd_sc_hd__o21ai_1 U45 ( .A1(n48), .A2(n45), .B1(n46), .Y(n44) );
  sky130_fd_sc_hd__nor2_1 U46 ( .A(A[21]), .B(n145), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(n145), .B(A[21]), .Y(n46) );
  sky130_fd_sc_hd__nor2_1 U48 ( .A(A[20]), .B(n144), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n144), .B(A[20]), .Y(n48) );
  sky130_fd_sc_hd__nand2_1 U50 ( .A(n51), .B(n57), .Y(n49) );
  sky130_fd_sc_hd__a21oi_1 U51 ( .A1(n51), .A2(n58), .B1(n52), .Y(n50) );
  sky130_fd_sc_hd__nor2_1 U52 ( .A(n53), .B(n55), .Y(n51) );
  sky130_fd_sc_hd__o21ai_1 U53 ( .A1(n56), .A2(n53), .B1(n54), .Y(n52) );
  sky130_fd_sc_hd__nor2_1 U54 ( .A(A[19]), .B(n143), .Y(n53) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(n143), .B(A[19]), .Y(n54) );
  sky130_fd_sc_hd__nor2_1 U56 ( .A(A[18]), .B(n142), .Y(n55) );
  sky130_fd_sc_hd__nand2_1 U57 ( .A(n142), .B(A[18]), .Y(n56) );
  sky130_fd_sc_hd__nor2_1 U58 ( .A(n59), .B(n61), .Y(n57) );
  sky130_fd_sc_hd__o21ai_1 U59 ( .A1(n62), .A2(n59), .B1(n60), .Y(n58) );
  sky130_fd_sc_hd__nor2_1 U60 ( .A(A[17]), .B(n141), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n141), .B(A[17]), .Y(n60) );
  sky130_fd_sc_hd__nor2_1 U62 ( .A(A[16]), .B(n140), .Y(n61) );
  sky130_fd_sc_hd__nand2_1 U63 ( .A(n140), .B(A[16]), .Y(n62) );
  sky130_fd_sc_hd__a21oi_1 U64 ( .A1(n94), .A2(n64), .B1(n65), .Y(n63) );
  sky130_fd_sc_hd__nor2_1 U65 ( .A(n80), .B(n66), .Y(n64) );
  sky130_fd_sc_hd__o21ai_1 U66 ( .A1(n66), .A2(n81), .B1(n67), .Y(n65) );
  sky130_fd_sc_hd__nand2_1 U67 ( .A(n74), .B(n68), .Y(n66) );
  sky130_fd_sc_hd__a21oi_1 U68 ( .A1(n68), .A2(n75), .B1(n69), .Y(n67) );
  sky130_fd_sc_hd__nor2_1 U69 ( .A(n70), .B(n72), .Y(n68) );
  sky130_fd_sc_hd__o21ai_1 U70 ( .A1(n73), .A2(n70), .B1(n71), .Y(n69) );
  sky130_fd_sc_hd__nor2_1 U71 ( .A(A[15]), .B(n139), .Y(n70) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(n139), .B(A[15]), .Y(n71) );
  sky130_fd_sc_hd__nor2_1 U73 ( .A(A[14]), .B(n138), .Y(n72) );
  sky130_fd_sc_hd__nand2_1 U74 ( .A(n138), .B(A[14]), .Y(n73) );
  sky130_fd_sc_hd__nor2_1 U75 ( .A(n76), .B(n78), .Y(n74) );
  sky130_fd_sc_hd__o21ai_1 U76 ( .A1(n79), .A2(n76), .B1(n77), .Y(n75) );
  sky130_fd_sc_hd__nor2_1 U77 ( .A(A[13]), .B(n137), .Y(n76) );
  sky130_fd_sc_hd__nand2_1 U78 ( .A(n137), .B(A[13]), .Y(n77) );
  sky130_fd_sc_hd__nor2_1 U79 ( .A(A[12]), .B(n136), .Y(n78) );
  sky130_fd_sc_hd__nand2_1 U80 ( .A(n136), .B(A[12]), .Y(n79) );
  sky130_fd_sc_hd__nand2_1 U81 ( .A(n82), .B(n88), .Y(n80) );
  sky130_fd_sc_hd__a21oi_1 U82 ( .A1(n82), .A2(n89), .B1(n83), .Y(n81) );
  sky130_fd_sc_hd__nor2_1 U83 ( .A(n84), .B(n86), .Y(n82) );
  sky130_fd_sc_hd__o21ai_1 U84 ( .A1(n87), .A2(n84), .B1(n85), .Y(n83) );
  sky130_fd_sc_hd__nor2_1 U85 ( .A(A[11]), .B(n135), .Y(n84) );
  sky130_fd_sc_hd__nand2_1 U86 ( .A(n135), .B(A[11]), .Y(n85) );
  sky130_fd_sc_hd__nor2_1 U87 ( .A(A[10]), .B(n134), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(n134), .B(A[10]), .Y(n87) );
  sky130_fd_sc_hd__nor2_1 U89 ( .A(n90), .B(n92), .Y(n88) );
  sky130_fd_sc_hd__o21ai_1 U90 ( .A1(n93), .A2(n90), .B1(n91), .Y(n89) );
  sky130_fd_sc_hd__nor2_1 U91 ( .A(A[9]), .B(n133), .Y(n90) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(n133), .B(A[9]), .Y(n91) );
  sky130_fd_sc_hd__nor2_1 U93 ( .A(A[8]), .B(n132), .Y(n92) );
  sky130_fd_sc_hd__nand2_1 U94 ( .A(n132), .B(A[8]), .Y(n93) );
  sky130_fd_sc_hd__o21ai_1 U95 ( .A1(n95), .A2(n109), .B1(n96), .Y(n94) );
  sky130_fd_sc_hd__nand2_1 U96 ( .A(n103), .B(n97), .Y(n95) );
  sky130_fd_sc_hd__a21oi_1 U97 ( .A1(n97), .A2(n104), .B1(n98), .Y(n96) );
  sky130_fd_sc_hd__nor2_1 U98 ( .A(n99), .B(n101), .Y(n97) );
  sky130_fd_sc_hd__o21ai_1 U99 ( .A1(n102), .A2(n99), .B1(n100), .Y(n98) );
  sky130_fd_sc_hd__nor2_1 U100 ( .A(A[7]), .B(n131), .Y(n99) );
  sky130_fd_sc_hd__nand2_1 U101 ( .A(n131), .B(A[7]), .Y(n100) );
  sky130_fd_sc_hd__nor2_1 U102 ( .A(A[6]), .B(n130), .Y(n101) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n130), .B(A[6]), .Y(n102) );
  sky130_fd_sc_hd__nor2_1 U104 ( .A(n105), .B(n107), .Y(n103) );
  sky130_fd_sc_hd__o21ai_1 U105 ( .A1(n108), .A2(n105), .B1(n106), .Y(n104) );
  sky130_fd_sc_hd__nor2_1 U106 ( .A(A[5]), .B(n129), .Y(n105) );
  sky130_fd_sc_hd__nand2_1 U107 ( .A(n129), .B(A[5]), .Y(n106) );
  sky130_fd_sc_hd__nor2_1 U108 ( .A(A[4]), .B(n128), .Y(n107) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(n128), .B(A[4]), .Y(n108) );
  sky130_fd_sc_hd__a21oi_1 U110 ( .A1(n116), .A2(n110), .B1(n111), .Y(n109) );
  sky130_fd_sc_hd__nor2_1 U111 ( .A(n112), .B(n114), .Y(n110) );
  sky130_fd_sc_hd__o21ai_1 U112 ( .A1(n115), .A2(n112), .B1(n113), .Y(n111) );
  sky130_fd_sc_hd__nor2_1 U113 ( .A(A[3]), .B(n127), .Y(n112) );
  sky130_fd_sc_hd__nand2_1 U114 ( .A(n127), .B(A[3]), .Y(n113) );
  sky130_fd_sc_hd__nor2_1 U115 ( .A(A[2]), .B(n126), .Y(n114) );
  sky130_fd_sc_hd__nand2_1 U116 ( .A(n126), .B(A[2]), .Y(n115) );
  sky130_fd_sc_hd__o21ai_1 U117 ( .A1(n117), .A2(n119), .B1(n118), .Y(n116) );
  sky130_fd_sc_hd__nor2_1 U118 ( .A(A[1]), .B(n125), .Y(n117) );
  sky130_fd_sc_hd__nand2_1 U119 ( .A(n125), .B(A[1]), .Y(n118) );
  sky130_fd_sc_hd__nor2_1 U120 ( .A(n232), .B(n231), .Y(n119) );
  sky130_fd_sc_hd__inv_2 U161 ( .A(B[0]), .Y(n124) );
  sky130_fd_sc_hd__or2_0 U162 ( .A(A[0]), .B(n124), .X(n231) );
  sky130_fd_sc_hd__and2_0 U163 ( .A(n124), .B(A[0]), .X(n232) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(B[17]), .Y(n141) );
  sky130_fd_sc_hd__inv_2 U165 ( .A(B[5]), .Y(n129) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(B[3]), .Y(n127) );
  sky130_fd_sc_hd__inv_2 U167 ( .A(B[9]), .Y(n133) );
  sky130_fd_sc_hd__inv_2 U168 ( .A(B[21]), .Y(n145) );
  sky130_fd_sc_hd__inv_2 U169 ( .A(B[25]), .Y(n149) );
  sky130_fd_sc_hd__inv_2 U170 ( .A(B[13]), .Y(n137) );
  sky130_fd_sc_hd__inv_2 U171 ( .A(B[19]), .Y(n143) );
  sky130_fd_sc_hd__inv_2 U172 ( .A(B[7]), .Y(n131) );
  sky130_fd_sc_hd__inv_2 U173 ( .A(B[29]), .Y(n153) );
  sky130_fd_sc_hd__inv_2 U174 ( .A(B[11]), .Y(n135) );
  sky130_fd_sc_hd__inv_2 U175 ( .A(B[23]), .Y(n147) );
  sky130_fd_sc_hd__inv_2 U176 ( .A(B[31]), .Y(n155) );
  sky130_fd_sc_hd__inv_2 U177 ( .A(B[27]), .Y(n151) );
  sky130_fd_sc_hd__inv_2 U178 ( .A(B[15]), .Y(n139) );
  sky130_fd_sc_hd__inv_2 U179 ( .A(B[30]), .Y(n154) );
  sky130_fd_sc_hd__inv_2 U180 ( .A(B[1]), .Y(n125) );
  sky130_fd_sc_hd__inv_2 U181 ( .A(B[2]), .Y(n126) );
  sky130_fd_sc_hd__inv_2 U182 ( .A(B[18]), .Y(n142) );
  sky130_fd_sc_hd__inv_2 U183 ( .A(B[6]), .Y(n130) );
  sky130_fd_sc_hd__inv_2 U184 ( .A(B[8]), .Y(n132) );
  sky130_fd_sc_hd__inv_2 U185 ( .A(B[16]), .Y(n140) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(B[4]), .Y(n128) );
  sky130_fd_sc_hd__inv_2 U187 ( .A(B[10]), .Y(n134) );
  sky130_fd_sc_hd__inv_2 U188 ( .A(B[14]), .Y(n138) );
  sky130_fd_sc_hd__inv_2 U189 ( .A(B[22]), .Y(n146) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(B[20]), .Y(n144) );
  sky130_fd_sc_hd__inv_2 U191 ( .A(B[26]), .Y(n150) );
  sky130_fd_sc_hd__inv_2 U192 ( .A(B[24]), .Y(n148) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(B[12]), .Y(n136) );
  sky130_fd_sc_hd__inv_2 U194 ( .A(B[28]), .Y(n152) );
endmodule


module apb4_wdg ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr, wdg_rtc_clk_i, wdg_rst_o );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite,
         wdg_rtc_clk_i;
  output apb4_pready, apb4_pslverr, wdg_rst_o;
  wire   N0, n8, n7, s_tc_clk, s_inclk, s_done, s_valid, s_wdg_feed_q, N55,
         N58, N59, N60, N61, N62, N63, N64, N65, N66, N67, N68, N69, N70, N71,
         N72, N73, N74, N75, N76, N77, N78, N79, N80, N81, N82, N83, N84, N85,
         N86, N87, N88, N89, s_ov_irq_trg, \s_wdg_stat_d[0] , s_wdg_feed_d,
         n133, n134, n143, n144, n145, n147, n148, n153, n169, n171, n172,
         n173, n174, n175, n176, n177, n178, n179, n180, n181, n182, n183,
         n184, n185, n186, n187, n188, n189, n190, n191, n192, n193, n194,
         n195, n196, n197, n198, n199, n200, n201, n202, n203, n204, n205,
         n206, n207, n208, n209, n210, n211, n212, n213, n214, n215, n216,
         n217, n218, n219, n220, n221, n222, n223, n224, n225, n226, n227,
         n228, n229, n230, n231, n232, n233, n234, n235, n236, n237, n238,
         n239, n240, n241, n242, n243, n244, n245, n246, n247, n248, n249,
         n250, n251, n252, n253, n254, n255, n256, n257, n258, n259, n260,
         n261, n262, n263, n264, n265, n266, n267, n268, n269, n270, n271,
         n272, n273, n274, n275, n276, n277, n278, n279, n280, n281, n282,
         n283, n284, n285, n286, n287, n288, n289, n290, n291, n292, n293,
         n294, n295, n296, n297, n298, n299, n300, n301, n302, n303, n304,
         n305, n306, n307, n308, n309, n310, n311, n312, n313, n314, n315,
         n316, n317, n318, n319, n320, n321, n322, n323, n324, n325, n326,
         n327, n328, n329, n330, n331, n332, n333, n334, n335, n336, n337,
         n338, n339, n340, n341, n342, n343, n344, n345, n346, n347, n348,
         n349, n350, n351, n352, n353, n354, n355, n356, n357, n358, n359,
         n360, n361, n362, n363, n364, n365, n366, n367, n368, n369, n370,
         n371, n372, n373, n374, n375, n376, n377, n378, n379, n380, n381,
         n382, n383, n384, n385, n386, n387, n388, n389, n390, n391, n392,
         n393, n394, n395, n396, n397, n398, n399, n400, n401, n402, n403,
         n404, n405, n406, n407, n408, n409, n410, n411, n412, n413, n414;
  wire   [2:0] s_wdg_ctrl_q;
  wire   [31:0] s_wdg_key_q;
  wire   [2:0] s_wdg_ctrl_d;
  wire   [19:0] s_wdg_pscr_d;
  wire   [19:0] s_wdg_pscr_q;
  wire   [31:0] s_wdg_cnt_d;
  wire   [31:0] s_wdg_cnt_q;
  wire   [31:0] s_wdg_cmp_q;
  wire   [31:0] s_wdg_cmp_d;
  wire   [31:0] s_wdg_key_d;
  assign apb4_pready = n8;
  assign apb4_pslverr = n7;

  sky130_fd_sc_hd__a32o_1 U267 ( .A1(s_ov_irq_trg), .A2(n374), .A3(
        s_wdg_ctrl_q[0]), .B1(wdg_rst_o), .B2(n133), .X(\s_wdg_stat_d[0] ) );
  sky130_fd_sc_hd__nand4_1 U268 ( .A(apb4_paddr[4]), .B(n134), .C(n318), .D(
        n317), .Y(n133) );
  sky130_fd_sc_hd__nand2_1 U321 ( .A(n395), .B(s_wdg_key_q[9]), .Y(n171) );
  sky130_fd_sc_hd__nand2_1 U322 ( .A(n395), .B(s_wdg_key_q[8]), .Y(n172) );
  sky130_fd_sc_hd__nand2_1 U323 ( .A(n395), .B(s_wdg_key_q[7]), .Y(n173) );
  sky130_fd_sc_hd__nand2_1 U324 ( .A(n395), .B(s_wdg_key_q[6]), .Y(n174) );
  sky130_fd_sc_hd__nand2_1 U325 ( .A(n395), .B(s_wdg_key_q[5]), .Y(n175) );
  sky130_fd_sc_hd__nand2_1 U326 ( .A(n395), .B(s_wdg_key_q[4]), .Y(n176) );
  sky130_fd_sc_hd__nand2_1 U327 ( .A(n395), .B(s_wdg_key_q[3]), .Y(n177) );
  sky130_fd_sc_hd__a32oi_1 U328 ( .A1(n153), .A2(n180), .A3(s_wdg_ctrl_q[2]), 
        .B1(n395), .B2(s_wdg_key_q[2]), .Y(n179) );
  sky130_fd_sc_hd__a32oi_1 U329 ( .A1(n153), .A2(n180), .A3(N0), .B1(n395), 
        .B2(s_wdg_key_q[1]), .Y(n181) );
  sky130_fd_sc_hd__nand2_1 U330 ( .A(n395), .B(s_wdg_key_q[19]), .Y(n182) );
  sky130_fd_sc_hd__nand2_1 U331 ( .A(n395), .B(s_wdg_key_q[18]), .Y(n183) );
  sky130_fd_sc_hd__nand2_1 U332 ( .A(n395), .B(s_wdg_key_q[17]), .Y(n184) );
  sky130_fd_sc_hd__nand2_1 U333 ( .A(n395), .B(s_wdg_key_q[16]), .Y(n185) );
  sky130_fd_sc_hd__nand2_1 U334 ( .A(n395), .B(s_wdg_key_q[15]), .Y(n186) );
  sky130_fd_sc_hd__nand2_1 U335 ( .A(n395), .B(s_wdg_key_q[14]), .Y(n187) );
  sky130_fd_sc_hd__nand2_1 U336 ( .A(n395), .B(s_wdg_key_q[13]), .Y(n188) );
  sky130_fd_sc_hd__nand2_1 U337 ( .A(n395), .B(s_wdg_key_q[12]), .Y(n189) );
  sky130_fd_sc_hd__nand2_1 U338 ( .A(n395), .B(s_wdg_key_q[11]), .Y(n190) );
  sky130_fd_sc_hd__nand2_1 U339 ( .A(n395), .B(s_wdg_key_q[10]), .Y(n191) );
  sky130_fd_sc_hd__a32oi_1 U340 ( .A1(n193), .A2(n318), .A3(n134), .B1(n395), 
        .B2(s_wdg_key_q[0]), .Y(n192) );
  sky130_fd_sc_hd__nand2_1 U343 ( .A(n207), .B(n134), .Y(n169) );
  sky130_fd_sc_hd__nor2b_1 U344 ( .B_N(n180), .A(apb4_paddr[5]), .Y(n134) );
  sky130_fd_sc_hd__and3b_1 U345 ( .B(apb4_penable), .C(apb4_psel), .A_N(
        apb4_pwrite), .X(n180) );
  dffr_DATA_WIDTH3_0 u_wdg_ctrl_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_wdg_ctrl_d), .dat_o({s_wdg_ctrl_q[2], N0, 
        s_wdg_ctrl_q[0]}) );
  dffrc_20_00002 u_wdg_pscr_dffrc ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_wdg_pscr_d), .dat_o(s_wdg_pscr_q) );
  clk_int_even_div_simple_DIV_VALUE_WIDTH20 u_clk_int_even_div_simple ( 
        .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .div_i(s_wdg_pscr_q), 
        .div_valid_i(s_valid), .div_done_o(s_done), .clk_o(s_inclk) );
  dffr_DATA_WIDTH32_0 u_wdg_cnt_dffr ( .clk_i(s_tc_clk), .rst_n_i(apb4_presetn), .dat_i(s_wdg_cnt_d), .dat_o(s_wdg_cnt_q) );
  dffr_DATA_WIDTH32_2 u_wdg_cmp_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_wdg_cmp_d), .dat_o(s_wdg_cmp_q) );
  cdc_sync_STAGE2_DATA_WIDTH1 u_irq_cdc_sync ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(N55), .dat_o(s_ov_irq_trg) );
  dffr_DATA_WIDTH1_0 u_wdg_stat_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(\s_wdg_stat_d[0] ), .dat_o(wdg_rst_o) );
  dffr_DATA_WIDTH32_1 u_wdg_key_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_wdg_key_d), .dat_o(s_wdg_key_q) );
  dffr_DATA_WIDTH1_4 u_wdg_feed_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_wdg_feed_d), .dat_o(s_wdg_feed_q) );
  apb4_wdg_DW01_inc_0_DW01_inc_1 add_90 ( .A(s_wdg_cnt_q), .SUM({N89, N88, N87, 
        N86, N85, N84, N83, N82, N81, N80, N79, N78, N77, N76, N75, N74, N73, 
        N72, N71, N70, N69, N68, N67, N66, N65, N64, N63, N62, N61, N60, N59, 
        N58}) );
  apb4_wdg_DW_cmp_1 r375 ( .A(s_wdg_cnt_q), .B(s_wdg_cmp_q), .TC(n7), .GE_LT(
        n8), .GE_GT_EQ(n8), .GE_LT_GT_LE(N55) );
  sky130_fd_sc_hd__dlygate4sd3_1 U346 ( .A(s_wdg_pscr_q[1]), .X(n209) );
  sky130_fd_sc_hd__nand2_1 U347 ( .A(n134), .B(n208), .Y(n195) );
  sky130_fd_sc_hd__nand3_1 U348 ( .A(apb4_penable), .B(apb4_psel), .C(
        apb4_pwrite), .Y(n196) );
  sky130_fd_sc_hd__bufinv_8 U349 ( .A(n256), .Y(n268) );
  sky130_fd_sc_hd__nand2_8 U350 ( .A(n268), .B(n261), .Y(n270) );
  sky130_fd_sc_hd__dlygate4sd3_1 U351 ( .A(s_wdg_pscr_q[10]), .X(n197) );
  sky130_fd_sc_hd__dlygate4sd3_1 U352 ( .A(s_wdg_pscr_q[9]), .X(n198) );
  sky130_fd_sc_hd__dlygate4sd3_1 U353 ( .A(s_wdg_pscr_q[11]), .X(n199) );
  sky130_fd_sc_hd__dlygate4sd3_1 U354 ( .A(s_wdg_pscr_q[4]), .X(n200) );
  sky130_fd_sc_hd__dlygate4sd3_1 U355 ( .A(s_wdg_pscr_q[2]), .X(n201) );
  sky130_fd_sc_hd__clkinv_2 U356 ( .A(n223), .Y(n222) );
  sky130_fd_sc_hd__clkinv_4 U357 ( .A(n223), .Y(n221) );
  sky130_fd_sc_hd__and2_1 U358 ( .A(n248), .B(n247), .X(n202) );
  sky130_fd_sc_hd__and2_1 U359 ( .A(n254), .B(n208), .X(n203) );
  sky130_fd_sc_hd__inv_2 U360 ( .A(n232), .Y(n231) );
  sky130_fd_sc_hd__inv_2 U361 ( .A(n223), .Y(n220) );
  sky130_fd_sc_hd__inv_2 U362 ( .A(n203), .Y(n223) );
  sky130_fd_sc_hd__inv_2 U363 ( .A(n178), .Y(n395) );
  sky130_fd_sc_hd__buf_1 U364 ( .A(n205), .X(n224) );
  sky130_fd_sc_hd__buf_1 U365 ( .A(n205), .X(n225) );
  sky130_fd_sc_hd__inv_2 U366 ( .A(n196), .Y(n230) );
  sky130_fd_sc_hd__inv_2 U367 ( .A(n147), .Y(n232) );
  sky130_fd_sc_hd__buf_1 U368 ( .A(n205), .X(n226) );
  sky130_fd_sc_hd__clkinv_1 U369 ( .A(n271), .Y(n254) );
  sky130_fd_sc_hd__and3_1 U370 ( .A(n153), .B(n230), .C(n202), .X(n204) );
  sky130_fd_sc_hd__o22ai_1 U371 ( .A1(n230), .A2(n356), .B1(n231), .B2(n401), 
        .Y(s_wdg_key_d[25]) );
  sky130_fd_sc_hd__o22ai_1 U372 ( .A1(n230), .A2(n352), .B1(n231), .B2(n397), 
        .Y(s_wdg_key_d[30]) );
  sky130_fd_sc_hd__o22ai_1 U373 ( .A1(n230), .A2(n359), .B1(n231), .B2(n404), 
        .Y(s_wdg_key_d[20]) );
  sky130_fd_sc_hd__o22ai_1 U374 ( .A1(n230), .A2(n355), .B1(n231), .B2(n400), 
        .Y(s_wdg_key_d[26]) );
  sky130_fd_sc_hd__o22ai_1 U375 ( .A1(n230), .A2(n358), .B1(n231), .B2(n403), 
        .Y(s_wdg_key_d[21]) );
  sky130_fd_sc_hd__o22ai_1 U376 ( .A1(n230), .A2(n354), .B1(n231), .B2(n399), 
        .Y(s_wdg_key_d[27]) );
  sky130_fd_sc_hd__o22ai_1 U377 ( .A1(n230), .A2(n357), .B1(n231), .B2(n402), 
        .Y(s_wdg_key_d[24]) );
  sky130_fd_sc_hd__o22ai_1 U378 ( .A1(n230), .A2(n353), .B1(n231), .B2(n398), 
        .Y(s_wdg_key_d[28]) );
  sky130_fd_sc_hd__nand2_1 U379 ( .A(n148), .B(n180), .Y(n178) );
  sky130_fd_sc_hd__o22ai_1 U380 ( .A1(n331), .A2(n195), .B1(n359), .B2(n178), 
        .Y(apb4_prdata[20]) );
  sky130_fd_sc_hd__o22ai_1 U381 ( .A1(n330), .A2(n195), .B1(n358), .B2(n178), 
        .Y(apb4_prdata[21]) );
  sky130_fd_sc_hd__o22ai_1 U382 ( .A1(n329), .A2(n195), .B1(n357), .B2(n178), 
        .Y(apb4_prdata[24]) );
  sky130_fd_sc_hd__o22ai_1 U383 ( .A1(n328), .A2(n195), .B1(n356), .B2(n178), 
        .Y(apb4_prdata[25]) );
  sky130_fd_sc_hd__o22ai_1 U384 ( .A1(n327), .A2(n195), .B1(n355), .B2(n178), 
        .Y(apb4_prdata[26]) );
  sky130_fd_sc_hd__o22ai_1 U385 ( .A1(n326), .A2(n195), .B1(n354), .B2(n178), 
        .Y(apb4_prdata[27]) );
  sky130_fd_sc_hd__o22ai_1 U386 ( .A1(n325), .A2(n195), .B1(n353), .B2(n178), 
        .Y(apb4_prdata[28]) );
  sky130_fd_sc_hd__o22ai_1 U387 ( .A1(n324), .A2(n195), .B1(n352), .B2(n178), 
        .Y(apb4_prdata[30]) );
  sky130_fd_sc_hd__buf_1 U388 ( .A(n206), .X(n227) );
  sky130_fd_sc_hd__buf_1 U389 ( .A(n206), .X(n228) );
  sky130_fd_sc_hd__nand3_1 U390 ( .A(n412), .B(n411), .C(n413), .Y(n144) );
  sky130_fd_sc_hd__nand3_1 U391 ( .A(n406), .B(n405), .C(n407), .Y(n145) );
  sky130_fd_sc_hd__nand3_1 U392 ( .A(n409), .B(n408), .C(n410), .Y(n143) );
  sky130_fd_sc_hd__and3b_1 U393 ( .B(n273), .C(n227), .A_N(N55), .X(n205) );
  sky130_fd_sc_hd__buf_1 U394 ( .A(n206), .X(n229) );
  sky130_fd_sc_hd__inv_2 U395 ( .A(n261), .Y(n262) );
  sky130_fd_sc_hd__inv_2 U396 ( .A(wdg_rst_o), .Y(n374) );
  sky130_fd_sc_hd__o22ai_1 U397 ( .A1(n230), .A2(n372), .B1(n231), .B2(n323), 
        .Y(s_wdg_key_d[1]) );
  sky130_fd_sc_hd__inv_1 U398 ( .A(s_wdg_key_q[1]), .Y(n372) );
  sky130_fd_sc_hd__o22ai_1 U399 ( .A1(n230), .A2(n371), .B1(n413), .B2(n147), 
        .Y(s_wdg_key_d[2]) );
  sky130_fd_sc_hd__inv_1 U400 ( .A(s_wdg_key_q[2]), .Y(n371) );
  sky130_fd_sc_hd__o22ai_1 U401 ( .A1(n230), .A2(n368), .B1(n322), .B2(n147), 
        .Y(s_wdg_key_d[6]) );
  sky130_fd_sc_hd__inv_1 U402 ( .A(s_wdg_key_q[6]), .Y(n368) );
  sky130_fd_sc_hd__o22ai_1 U403 ( .A1(n230), .A2(n364), .B1(n320), .B2(n147), 
        .Y(s_wdg_key_d[12]) );
  sky130_fd_sc_hd__inv_1 U404 ( .A(s_wdg_key_q[12]), .Y(n364) );
  sky130_fd_sc_hd__o22ai_1 U405 ( .A1(n230), .A2(n360), .B1(n405), .B2(n147), 
        .Y(s_wdg_key_d[18]) );
  sky130_fd_sc_hd__inv_1 U406 ( .A(s_wdg_key_q[18]), .Y(n360) );
  sky130_fd_sc_hd__o22ai_1 U407 ( .A1(n230), .A2(n363), .B1(n319), .B2(n147), 
        .Y(s_wdg_key_d[14]) );
  sky130_fd_sc_hd__inv_1 U408 ( .A(s_wdg_key_q[14]), .Y(n363) );
  sky130_fd_sc_hd__o22ai_1 U409 ( .A1(n230), .A2(n367), .B1(n410), .B2(n147), 
        .Y(s_wdg_key_d[7]) );
  sky130_fd_sc_hd__inv_1 U410 ( .A(s_wdg_key_q[7]), .Y(n367) );
  sky130_fd_sc_hd__o22ai_1 U411 ( .A1(n230), .A2(n362), .B1(n407), .B2(n147), 
        .Y(s_wdg_key_d[16]) );
  sky130_fd_sc_hd__inv_1 U412 ( .A(s_wdg_key_q[16]), .Y(n362) );
  sky130_fd_sc_hd__o22ai_1 U413 ( .A1(n230), .A2(n370), .B1(n412), .B2(n147), 
        .Y(s_wdg_key_d[3]) );
  sky130_fd_sc_hd__inv_1 U414 ( .A(s_wdg_key_q[3]), .Y(n370) );
  sky130_fd_sc_hd__o22ai_1 U415 ( .A1(n230), .A2(n366), .B1(n409), .B2(n147), 
        .Y(s_wdg_key_d[8]) );
  sky130_fd_sc_hd__inv_1 U416 ( .A(s_wdg_key_q[8]), .Y(n366) );
  sky130_fd_sc_hd__o22ai_1 U417 ( .A1(n230), .A2(n373), .B1(n414), .B2(n147), 
        .Y(s_wdg_key_d[0]) );
  sky130_fd_sc_hd__inv_1 U418 ( .A(s_wdg_key_q[0]), .Y(n373) );
  sky130_fd_sc_hd__o22ai_1 U419 ( .A1(n230), .A2(n365), .B1(n321), .B2(n147), 
        .Y(s_wdg_key_d[11]) );
  sky130_fd_sc_hd__inv_1 U420 ( .A(s_wdg_key_q[11]), .Y(n365) );
  sky130_fd_sc_hd__o22ai_1 U421 ( .A1(n230), .A2(n361), .B1(n406), .B2(n147), 
        .Y(s_wdg_key_d[17]) );
  sky130_fd_sc_hd__inv_1 U422 ( .A(s_wdg_key_q[17]), .Y(n361) );
  sky130_fd_sc_hd__o22ai_1 U423 ( .A1(n230), .A2(n369), .B1(n411), .B2(n231), 
        .Y(s_wdg_key_d[4]) );
  sky130_fd_sc_hd__inv_1 U424 ( .A(s_wdg_key_q[4]), .Y(n369) );
  sky130_fd_sc_hd__inv_1 U425 ( .A(s_wdg_key_q[25]), .Y(n356) );
  sky130_fd_sc_hd__inv_1 U426 ( .A(s_wdg_key_q[30]), .Y(n352) );
  sky130_fd_sc_hd__inv_1 U427 ( .A(s_wdg_key_q[20]), .Y(n359) );
  sky130_fd_sc_hd__inv_1 U428 ( .A(s_wdg_key_q[26]), .Y(n355) );
  sky130_fd_sc_hd__inv_1 U429 ( .A(s_wdg_key_q[21]), .Y(n358) );
  sky130_fd_sc_hd__inv_1 U430 ( .A(s_wdg_key_q[27]), .Y(n354) );
  sky130_fd_sc_hd__inv_1 U431 ( .A(s_wdg_key_q[24]), .Y(n357) );
  sky130_fd_sc_hd__inv_1 U432 ( .A(s_wdg_key_q[28]), .Y(n353) );
  sky130_fd_sc_hd__nor4_1 U433 ( .A(apb4_paddr[2]), .B(apb4_paddr[3]), .C(
        apb4_paddr[4]), .D(apb4_paddr[5]), .Y(n153) );
  sky130_fd_sc_hd__nor4_1 U434 ( .A(n318), .B(n396), .C(apb4_paddr[3]), .D(
        apb4_paddr[5]), .Y(n148) );
  sky130_fd_sc_hd__a22oi_1 U435 ( .A1(wdg_rst_o), .A2(n317), .B1(s_wdg_feed_q), 
        .B2(apb4_paddr[3]), .Y(n194) );
  sky130_fd_sc_hd__o221ai_1 U436 ( .A1(n394), .A2(n212), .B1(n351), .B2(n195), 
        .C1(n192), .Y(apb4_prdata[0]) );
  sky130_fd_sc_hd__o32ai_1 U437 ( .A1(n308), .A2(apb4_paddr[4]), .A3(
        apb4_paddr[3]), .B1(n194), .B2(n396), .Y(n193) );
  sky130_fd_sc_hd__o221ai_1 U438 ( .A1(n393), .A2(n218), .B1(n350), .B2(n195), 
        .C1(n181), .Y(apb4_prdata[1]) );
  sky130_fd_sc_hd__o221ai_1 U439 ( .A1(n392), .A2(n219), .B1(n349), .B2(n195), 
        .C1(n179), .Y(apb4_prdata[2]) );
  sky130_fd_sc_hd__o221ai_1 U440 ( .A1(n391), .A2(n219), .B1(n348), .B2(n195), 
        .C1(n177), .Y(apb4_prdata[3]) );
  sky130_fd_sc_hd__o221ai_1 U441 ( .A1(n390), .A2(n217), .B1(n347), .B2(n195), 
        .C1(n176), .Y(apb4_prdata[4]) );
  sky130_fd_sc_hd__o221ai_1 U442 ( .A1(n389), .A2(n218), .B1(n346), .B2(n195), 
        .C1(n175), .Y(apb4_prdata[5]) );
  sky130_fd_sc_hd__o221ai_1 U443 ( .A1(n388), .A2(n212), .B1(n345), .B2(n195), 
        .C1(n174), .Y(apb4_prdata[6]) );
  sky130_fd_sc_hd__o221ai_1 U444 ( .A1(n387), .A2(n213), .B1(n344), .B2(n195), 
        .C1(n173), .Y(apb4_prdata[7]) );
  sky130_fd_sc_hd__o221ai_1 U445 ( .A1(n386), .A2(n214), .B1(n343), .B2(n195), 
        .C1(n172), .Y(apb4_prdata[8]) );
  sky130_fd_sc_hd__o221ai_1 U446 ( .A1(n385), .A2(n169), .B1(n342), .B2(n195), 
        .C1(n171), .Y(apb4_prdata[9]) );
  sky130_fd_sc_hd__o221ai_1 U447 ( .A1(n384), .A2(n213), .B1(n341), .B2(n195), 
        .C1(n191), .Y(apb4_prdata[10]) );
  sky130_fd_sc_hd__o221ai_1 U448 ( .A1(n383), .A2(n214), .B1(n340), .B2(n195), 
        .C1(n190), .Y(apb4_prdata[11]) );
  sky130_fd_sc_hd__o221ai_1 U449 ( .A1(n382), .A2(n219), .B1(n339), .B2(n195), 
        .C1(n189), .Y(apb4_prdata[12]) );
  sky130_fd_sc_hd__o221ai_1 U450 ( .A1(n381), .A2(n215), .B1(n338), .B2(n195), 
        .C1(n188), .Y(apb4_prdata[13]) );
  sky130_fd_sc_hd__o221ai_1 U451 ( .A1(n380), .A2(n216), .B1(n337), .B2(n195), 
        .C1(n187), .Y(apb4_prdata[14]) );
  sky130_fd_sc_hd__o221ai_1 U452 ( .A1(n379), .A2(n217), .B1(n336), .B2(n195), 
        .C1(n186), .Y(apb4_prdata[15]) );
  sky130_fd_sc_hd__o221ai_1 U453 ( .A1(n378), .A2(n218), .B1(n335), .B2(n195), 
        .C1(n185), .Y(apb4_prdata[16]) );
  sky130_fd_sc_hd__o221ai_1 U454 ( .A1(n377), .A2(n215), .B1(n334), .B2(n195), 
        .C1(n184), .Y(apb4_prdata[17]) );
  sky130_fd_sc_hd__o221ai_1 U455 ( .A1(n376), .A2(n216), .B1(n333), .B2(n195), 
        .C1(n183), .Y(apb4_prdata[18]) );
  sky130_fd_sc_hd__o221ai_1 U456 ( .A1(n375), .A2(n217), .B1(n332), .B2(n195), 
        .C1(n182), .Y(apb4_prdata[19]) );
  sky130_fd_sc_hd__and2_0 U457 ( .A(s_done), .B(s_wdg_ctrl_q[2]), .X(n206) );
  sky130_fd_sc_hd__inv_2 U458 ( .A(apb4_paddr[4]), .Y(n396) );
  sky130_fd_sc_hd__and3_1 U459 ( .A(apb4_paddr[2]), .B(n317), .C(n396), .X(
        n207) );
  sky130_fd_sc_hd__and3_1 U460 ( .A(apb4_paddr[3]), .B(apb4_paddr[2]), .C(n396), .X(n208) );
  sky130_fd_sc_hd__mux2_2 U461 ( .A0(s_inclk), .A1(wdg_rtc_clk_i), .S(N0), .X(
        s_tc_clk) );
  sky130_fd_sc_hd__conb_1 U462 ( .LO(n7), .HI(n8) );
  sky130_fd_sc_hd__inv_1 U463 ( .A(n209), .Y(n393) );
  sky130_fd_sc_hd__inv_1 U464 ( .A(n169), .Y(n210) );
  sky130_fd_sc_hd__inv_1 U465 ( .A(n169), .Y(n211) );
  sky130_fd_sc_hd__inv_1 U466 ( .A(n210), .Y(n212) );
  sky130_fd_sc_hd__inv_1 U467 ( .A(n210), .Y(n213) );
  sky130_fd_sc_hd__inv_1 U468 ( .A(n210), .Y(n214) );
  sky130_fd_sc_hd__inv_1 U469 ( .A(n211), .Y(n215) );
  sky130_fd_sc_hd__inv_1 U470 ( .A(n211), .Y(n216) );
  sky130_fd_sc_hd__inv_1 U471 ( .A(n211), .Y(n217) );
  sky130_fd_sc_hd__inv_1 U472 ( .A(n211), .Y(n218) );
  sky130_fd_sc_hd__inv_1 U473 ( .A(n211), .Y(n219) );
  sky130_fd_sc_hd__nand2_1 U474 ( .A(n148), .B(n230), .Y(n147) );
  sky130_fd_sc_hd__inv_1 U475 ( .A(s_wdg_key_q[5]), .Y(n242) );
  sky130_fd_sc_hd__inv_1 U476 ( .A(apb4_pwdata[5]), .Y(n264) );
  sky130_fd_sc_hd__o22ai_1 U477 ( .A1(n230), .A2(n242), .B1(n231), .B2(n264), 
        .Y(s_wdg_key_d[5]) );
  sky130_fd_sc_hd__inv_1 U478 ( .A(s_wdg_key_q[9]), .Y(n241) );
  sky130_fd_sc_hd__inv_1 U479 ( .A(apb4_pwdata[9]), .Y(n408) );
  sky130_fd_sc_hd__o22ai_1 U480 ( .A1(n230), .A2(n241), .B1(n408), .B2(n147), 
        .Y(s_wdg_key_d[9]) );
  sky130_fd_sc_hd__inv_1 U481 ( .A(s_wdg_key_q[10]), .Y(n240) );
  sky130_fd_sc_hd__inv_1 U482 ( .A(apb4_pwdata[10]), .Y(n265) );
  sky130_fd_sc_hd__o22ai_1 U483 ( .A1(n230), .A2(n240), .B1(n147), .B2(n265), 
        .Y(s_wdg_key_d[10]) );
  sky130_fd_sc_hd__inv_1 U484 ( .A(s_wdg_key_q[13]), .Y(n239) );
  sky130_fd_sc_hd__inv_1 U485 ( .A(apb4_pwdata[13]), .Y(n266) );
  sky130_fd_sc_hd__o22ai_1 U486 ( .A1(n230), .A2(n239), .B1(n231), .B2(n266), 
        .Y(s_wdg_key_d[13]) );
  sky130_fd_sc_hd__inv_1 U487 ( .A(s_wdg_key_q[15]), .Y(n238) );
  sky130_fd_sc_hd__inv_1 U488 ( .A(apb4_pwdata[15]), .Y(n267) );
  sky130_fd_sc_hd__o22ai_1 U489 ( .A1(n230), .A2(n238), .B1(n147), .B2(n267), 
        .Y(s_wdg_key_d[15]) );
  sky130_fd_sc_hd__inv_1 U490 ( .A(s_wdg_key_q[19]), .Y(n237) );
  sky130_fd_sc_hd__inv_1 U491 ( .A(apb4_pwdata[19]), .Y(n269) );
  sky130_fd_sc_hd__o22ai_1 U492 ( .A1(n230), .A2(n237), .B1(n231), .B2(n269), 
        .Y(s_wdg_key_d[19]) );
  sky130_fd_sc_hd__inv_1 U493 ( .A(s_wdg_key_q[22]), .Y(n309) );
  sky130_fd_sc_hd__inv_1 U494 ( .A(apb4_pwdata[22]), .Y(n250) );
  sky130_fd_sc_hd__o22ai_1 U495 ( .A1(n230), .A2(n309), .B1(n231), .B2(n250), 
        .Y(s_wdg_key_d[22]) );
  sky130_fd_sc_hd__inv_1 U496 ( .A(s_wdg_key_q[23]), .Y(n311) );
  sky130_fd_sc_hd__inv_1 U497 ( .A(apb4_pwdata[23]), .Y(n251) );
  sky130_fd_sc_hd__o22ai_1 U498 ( .A1(n230), .A2(n311), .B1(n231), .B2(n251), 
        .Y(s_wdg_key_d[23]) );
  sky130_fd_sc_hd__inv_1 U499 ( .A(s_wdg_key_q[29]), .Y(n313) );
  sky130_fd_sc_hd__inv_1 U500 ( .A(apb4_pwdata[29]), .Y(n252) );
  sky130_fd_sc_hd__o22ai_1 U501 ( .A1(n230), .A2(n313), .B1(n231), .B2(n252), 
        .Y(s_wdg_key_d[29]) );
  sky130_fd_sc_hd__inv_1 U502 ( .A(s_wdg_key_q[31]), .Y(n315) );
  sky130_fd_sc_hd__inv_1 U503 ( .A(apb4_pwdata[31]), .Y(n253) );
  sky130_fd_sc_hd__o22ai_1 U504 ( .A1(n230), .A2(n315), .B1(n231), .B2(n253), 
        .Y(s_wdg_key_d[31]) );
  sky130_fd_sc_hd__inv_1 U505 ( .A(s_wdg_cmp_q[0]), .Y(n351) );
  sky130_fd_sc_hd__inv_1 U506 ( .A(apb4_pwdata[0]), .Y(n414) );
  sky130_fd_sc_hd__nand4_1 U507 ( .A(s_wdg_key_q[11]), .B(s_wdg_key_q[12]), 
        .C(s_wdg_key_q[7]), .D(s_wdg_key_q[8]), .Y(n236) );
  sky130_fd_sc_hd__nand4_1 U508 ( .A(s_wdg_key_q[17]), .B(s_wdg_key_q[18]), 
        .C(s_wdg_key_q[14]), .D(s_wdg_key_q[16]), .Y(n235) );
  sky130_fd_sc_hd__nand4_1 U509 ( .A(s_wdg_key_q[24]), .B(s_wdg_key_q[25]), 
        .C(s_wdg_key_q[20]), .D(s_wdg_key_q[21]), .Y(n234) );
  sky130_fd_sc_hd__nand4_1 U510 ( .A(s_wdg_key_q[28]), .B(s_wdg_key_q[30]), 
        .C(s_wdg_key_q[26]), .D(s_wdg_key_q[27]), .Y(n233) );
  sky130_fd_sc_hd__nor4_1 U511 ( .A(n236), .B(n235), .C(n234), .D(n233), .Y(
        n248) );
  sky130_fd_sc_hd__nand4_1 U512 ( .A(n309), .B(n311), .C(n313), .D(n315), .Y(
        n246) );
  sky130_fd_sc_hd__nand4_1 U513 ( .A(n240), .B(n239), .C(n238), .D(n237), .Y(
        n245) );
  sky130_fd_sc_hd__nand4_1 U514 ( .A(s_wdg_key_q[0]), .B(s_wdg_key_q[1]), .C(
        n242), .D(n241), .Y(n244) );
  sky130_fd_sc_hd__nand4_1 U515 ( .A(s_wdg_key_q[4]), .B(s_wdg_key_q[6]), .C(
        s_wdg_key_q[2]), .D(s_wdg_key_q[3]), .Y(n243) );
  sky130_fd_sc_hd__nor4_1 U516 ( .A(n246), .B(n245), .C(n244), .D(n243), .Y(
        n247) );
  sky130_fd_sc_hd__inv_1 U517 ( .A(apb4_paddr[5]), .Y(n249) );
  sky130_fd_sc_hd__nand3_1 U518 ( .A(n202), .B(n230), .C(n249), .Y(n271) );
  sky130_fd_sc_hd__mux2i_1 U519 ( .A0(n351), .A1(n414), .S(n222), .Y(
        s_wdg_cmp_d[0]) );
  sky130_fd_sc_hd__inv_1 U520 ( .A(s_wdg_cmp_q[1]), .Y(n350) );
  sky130_fd_sc_hd__inv_1 U521 ( .A(apb4_pwdata[1]), .Y(n323) );
  sky130_fd_sc_hd__mux2i_1 U522 ( .A0(n350), .A1(n323), .S(n222), .Y(
        s_wdg_cmp_d[1]) );
  sky130_fd_sc_hd__inv_1 U523 ( .A(s_wdg_cmp_q[2]), .Y(n349) );
  sky130_fd_sc_hd__inv_1 U524 ( .A(apb4_pwdata[2]), .Y(n413) );
  sky130_fd_sc_hd__mux2i_1 U525 ( .A0(n349), .A1(n413), .S(n222), .Y(
        s_wdg_cmp_d[2]) );
  sky130_fd_sc_hd__inv_1 U526 ( .A(s_wdg_cmp_q[3]), .Y(n348) );
  sky130_fd_sc_hd__inv_1 U527 ( .A(apb4_pwdata[3]), .Y(n412) );
  sky130_fd_sc_hd__mux2i_1 U528 ( .A0(n348), .A1(n412), .S(n222), .Y(
        s_wdg_cmp_d[3]) );
  sky130_fd_sc_hd__inv_1 U529 ( .A(s_wdg_cmp_q[4]), .Y(n347) );
  sky130_fd_sc_hd__inv_1 U530 ( .A(apb4_pwdata[4]), .Y(n411) );
  sky130_fd_sc_hd__mux2i_1 U531 ( .A0(n347), .A1(n411), .S(n222), .Y(
        s_wdg_cmp_d[4]) );
  sky130_fd_sc_hd__inv_1 U532 ( .A(s_wdg_cmp_q[5]), .Y(n346) );
  sky130_fd_sc_hd__mux2i_1 U533 ( .A0(n346), .A1(n264), .S(n222), .Y(
        s_wdg_cmp_d[5]) );
  sky130_fd_sc_hd__inv_1 U534 ( .A(s_wdg_cmp_q[6]), .Y(n345) );
  sky130_fd_sc_hd__inv_1 U535 ( .A(apb4_pwdata[6]), .Y(n322) );
  sky130_fd_sc_hd__mux2i_1 U536 ( .A0(n345), .A1(n322), .S(n221), .Y(
        s_wdg_cmp_d[6]) );
  sky130_fd_sc_hd__inv_1 U537 ( .A(s_wdg_cmp_q[7]), .Y(n344) );
  sky130_fd_sc_hd__inv_1 U538 ( .A(apb4_pwdata[7]), .Y(n410) );
  sky130_fd_sc_hd__mux2i_1 U539 ( .A0(n344), .A1(n410), .S(n221), .Y(
        s_wdg_cmp_d[7]) );
  sky130_fd_sc_hd__inv_1 U540 ( .A(s_wdg_cmp_q[8]), .Y(n343) );
  sky130_fd_sc_hd__inv_1 U541 ( .A(apb4_pwdata[8]), .Y(n409) );
  sky130_fd_sc_hd__mux2i_1 U542 ( .A0(n343), .A1(n409), .S(n221), .Y(
        s_wdg_cmp_d[8]) );
  sky130_fd_sc_hd__inv_1 U543 ( .A(s_wdg_cmp_q[9]), .Y(n342) );
  sky130_fd_sc_hd__mux2i_1 U544 ( .A0(n342), .A1(n408), .S(n221), .Y(
        s_wdg_cmp_d[9]) );
  sky130_fd_sc_hd__inv_1 U545 ( .A(s_wdg_cmp_q[10]), .Y(n341) );
  sky130_fd_sc_hd__mux2i_1 U546 ( .A0(n341), .A1(n265), .S(n221), .Y(
        s_wdg_cmp_d[10]) );
  sky130_fd_sc_hd__inv_1 U547 ( .A(s_wdg_cmp_q[11]), .Y(n340) );
  sky130_fd_sc_hd__inv_1 U548 ( .A(apb4_pwdata[11]), .Y(n321) );
  sky130_fd_sc_hd__mux2i_1 U549 ( .A0(n340), .A1(n321), .S(n221), .Y(
        s_wdg_cmp_d[11]) );
  sky130_fd_sc_hd__inv_1 U550 ( .A(s_wdg_cmp_q[12]), .Y(n339) );
  sky130_fd_sc_hd__inv_1 U551 ( .A(apb4_pwdata[12]), .Y(n320) );
  sky130_fd_sc_hd__mux2i_1 U552 ( .A0(n339), .A1(n320), .S(n221), .Y(
        s_wdg_cmp_d[12]) );
  sky130_fd_sc_hd__inv_1 U553 ( .A(s_wdg_cmp_q[13]), .Y(n338) );
  sky130_fd_sc_hd__mux2i_1 U554 ( .A0(n338), .A1(n266), .S(n221), .Y(
        s_wdg_cmp_d[13]) );
  sky130_fd_sc_hd__inv_1 U555 ( .A(s_wdg_cmp_q[14]), .Y(n337) );
  sky130_fd_sc_hd__inv_1 U556 ( .A(apb4_pwdata[14]), .Y(n319) );
  sky130_fd_sc_hd__mux2i_1 U557 ( .A0(n337), .A1(n319), .S(n221), .Y(
        s_wdg_cmp_d[14]) );
  sky130_fd_sc_hd__inv_1 U558 ( .A(s_wdg_cmp_q[15]), .Y(n336) );
  sky130_fd_sc_hd__mux2i_1 U559 ( .A0(n336), .A1(n267), .S(n221), .Y(
        s_wdg_cmp_d[15]) );
  sky130_fd_sc_hd__inv_1 U560 ( .A(s_wdg_cmp_q[16]), .Y(n335) );
  sky130_fd_sc_hd__inv_1 U561 ( .A(apb4_pwdata[16]), .Y(n407) );
  sky130_fd_sc_hd__mux2i_1 U562 ( .A0(n335), .A1(n407), .S(n221), .Y(
        s_wdg_cmp_d[16]) );
  sky130_fd_sc_hd__inv_1 U563 ( .A(s_wdg_cmp_q[17]), .Y(n334) );
  sky130_fd_sc_hd__inv_1 U564 ( .A(apb4_pwdata[17]), .Y(n406) );
  sky130_fd_sc_hd__mux2i_1 U565 ( .A0(n334), .A1(n406), .S(n221), .Y(
        s_wdg_cmp_d[17]) );
  sky130_fd_sc_hd__inv_1 U566 ( .A(s_wdg_cmp_q[18]), .Y(n333) );
  sky130_fd_sc_hd__inv_1 U567 ( .A(apb4_pwdata[18]), .Y(n405) );
  sky130_fd_sc_hd__mux2i_1 U568 ( .A0(n333), .A1(n405), .S(n221), .Y(
        s_wdg_cmp_d[18]) );
  sky130_fd_sc_hd__inv_1 U569 ( .A(s_wdg_cmp_q[19]), .Y(n332) );
  sky130_fd_sc_hd__mux2i_1 U570 ( .A0(n332), .A1(n269), .S(n220), .Y(
        s_wdg_cmp_d[19]) );
  sky130_fd_sc_hd__inv_1 U571 ( .A(s_wdg_cmp_q[20]), .Y(n331) );
  sky130_fd_sc_hd__inv_1 U572 ( .A(apb4_pwdata[20]), .Y(n404) );
  sky130_fd_sc_hd__mux2i_1 U573 ( .A0(n331), .A1(n404), .S(n220), .Y(
        s_wdg_cmp_d[20]) );
  sky130_fd_sc_hd__inv_1 U574 ( .A(s_wdg_cmp_q[21]), .Y(n330) );
  sky130_fd_sc_hd__inv_1 U575 ( .A(apb4_pwdata[21]), .Y(n403) );
  sky130_fd_sc_hd__mux2i_1 U576 ( .A0(n330), .A1(n403), .S(n220), .Y(
        s_wdg_cmp_d[21]) );
  sky130_fd_sc_hd__inv_1 U577 ( .A(s_wdg_cmp_q[22]), .Y(n310) );
  sky130_fd_sc_hd__mux2i_1 U578 ( .A0(n310), .A1(n250), .S(n220), .Y(
        s_wdg_cmp_d[22]) );
  sky130_fd_sc_hd__inv_1 U579 ( .A(s_wdg_cmp_q[23]), .Y(n312) );
  sky130_fd_sc_hd__mux2i_1 U580 ( .A0(n312), .A1(n251), .S(n220), .Y(
        s_wdg_cmp_d[23]) );
  sky130_fd_sc_hd__inv_1 U581 ( .A(s_wdg_cmp_q[24]), .Y(n329) );
  sky130_fd_sc_hd__inv_1 U582 ( .A(apb4_pwdata[24]), .Y(n402) );
  sky130_fd_sc_hd__mux2i_1 U583 ( .A0(n329), .A1(n402), .S(n220), .Y(
        s_wdg_cmp_d[24]) );
  sky130_fd_sc_hd__inv_1 U584 ( .A(s_wdg_cmp_q[25]), .Y(n328) );
  sky130_fd_sc_hd__inv_1 U585 ( .A(apb4_pwdata[25]), .Y(n401) );
  sky130_fd_sc_hd__mux2i_1 U586 ( .A0(n328), .A1(n401), .S(n220), .Y(
        s_wdg_cmp_d[25]) );
  sky130_fd_sc_hd__inv_1 U587 ( .A(s_wdg_cmp_q[26]), .Y(n327) );
  sky130_fd_sc_hd__inv_1 U588 ( .A(apb4_pwdata[26]), .Y(n400) );
  sky130_fd_sc_hd__mux2i_1 U589 ( .A0(n327), .A1(n400), .S(n220), .Y(
        s_wdg_cmp_d[26]) );
  sky130_fd_sc_hd__inv_1 U590 ( .A(s_wdg_cmp_q[27]), .Y(n326) );
  sky130_fd_sc_hd__inv_1 U591 ( .A(apb4_pwdata[27]), .Y(n399) );
  sky130_fd_sc_hd__mux2i_1 U592 ( .A0(n326), .A1(n399), .S(n220), .Y(
        s_wdg_cmp_d[27]) );
  sky130_fd_sc_hd__inv_1 U593 ( .A(s_wdg_cmp_q[28]), .Y(n325) );
  sky130_fd_sc_hd__inv_1 U594 ( .A(apb4_pwdata[28]), .Y(n398) );
  sky130_fd_sc_hd__mux2i_1 U595 ( .A0(n325), .A1(n398), .S(n220), .Y(
        s_wdg_cmp_d[28]) );
  sky130_fd_sc_hd__inv_1 U596 ( .A(s_wdg_cmp_q[29]), .Y(n314) );
  sky130_fd_sc_hd__mux2i_1 U597 ( .A0(n314), .A1(n252), .S(n220), .Y(
        s_wdg_cmp_d[29]) );
  sky130_fd_sc_hd__inv_1 U598 ( .A(s_wdg_cmp_q[30]), .Y(n324) );
  sky130_fd_sc_hd__inv_1 U599 ( .A(apb4_pwdata[30]), .Y(n397) );
  sky130_fd_sc_hd__mux2i_1 U600 ( .A0(n324), .A1(n397), .S(n220), .Y(
        s_wdg_cmp_d[30]) );
  sky130_fd_sc_hd__inv_1 U601 ( .A(s_wdg_cmp_q[31]), .Y(n316) );
  sky130_fd_sc_hd__mux2i_1 U602 ( .A0(n316), .A1(n253), .S(n220), .Y(
        s_wdg_cmp_d[31]) );
  sky130_fd_sc_hd__inv_1 U603 ( .A(apb4_paddr[3]), .Y(n317) );
  sky130_fd_sc_hd__nand2_1 U604 ( .A(n207), .B(n254), .Y(n256) );
  sky130_fd_sc_hd__inv_1 U605 ( .A(s_done), .Y(n255) );
  sky130_fd_sc_hd__nor2_1 U606 ( .A(n256), .B(n255), .Y(s_valid) );
  sky130_fd_sc_hd__nand4_1 U607 ( .A(n323), .B(n322), .C(n320), .D(n319), .Y(
        n257) );
  sky130_fd_sc_hd__nor4_1 U608 ( .A(n257), .B(apb4_pwdata[15]), .C(
        apb4_pwdata[11]), .D(apb4_pwdata[19]), .Y(n260) );
  sky130_fd_sc_hd__nand3_1 U609 ( .A(n265), .B(n266), .C(n264), .Y(n258) );
  sky130_fd_sc_hd__nor4_1 U610 ( .A(n258), .B(n145), .C(n144), .D(n143), .Y(
        n259) );
  sky130_fd_sc_hd__nand2_1 U611 ( .A(n260), .B(n259), .Y(n261) );
  sky130_fd_sc_hd__inv_1 U612 ( .A(s_wdg_pscr_q[0]), .Y(n394) );
  sky130_fd_sc_hd__o22ai_1 U613 ( .A1(n414), .A2(n270), .B1(n394), .B2(n268), 
        .Y(s_wdg_pscr_d[0]) );
  sky130_fd_sc_hd__nor2_1 U614 ( .A(apb4_pwdata[1]), .B(n262), .Y(n263) );
  sky130_fd_sc_hd__mux2i_1 U615 ( .A0(n393), .A1(n263), .S(n268), .Y(
        s_wdg_pscr_d[1]) );
  sky130_fd_sc_hd__inv_1 U616 ( .A(n201), .Y(n392) );
  sky130_fd_sc_hd__o22ai_1 U617 ( .A1(n413), .A2(n270), .B1(n392), .B2(n268), 
        .Y(s_wdg_pscr_d[2]) );
  sky130_fd_sc_hd__inv_1 U618 ( .A(s_wdg_pscr_q[3]), .Y(n391) );
  sky130_fd_sc_hd__o22ai_1 U619 ( .A1(n412), .A2(n270), .B1(n391), .B2(n268), 
        .Y(s_wdg_pscr_d[3]) );
  sky130_fd_sc_hd__inv_1 U620 ( .A(n200), .Y(n390) );
  sky130_fd_sc_hd__o22ai_1 U621 ( .A1(n411), .A2(n270), .B1(n390), .B2(n268), 
        .Y(s_wdg_pscr_d[4]) );
  sky130_fd_sc_hd__inv_1 U622 ( .A(s_wdg_pscr_q[5]), .Y(n389) );
  sky130_fd_sc_hd__o22ai_1 U623 ( .A1(n270), .A2(n264), .B1(n389), .B2(n268), 
        .Y(s_wdg_pscr_d[5]) );
  sky130_fd_sc_hd__inv_1 U624 ( .A(s_wdg_pscr_q[6]), .Y(n388) );
  sky130_fd_sc_hd__o22ai_1 U625 ( .A1(n322), .A2(n270), .B1(n388), .B2(n268), 
        .Y(s_wdg_pscr_d[6]) );
  sky130_fd_sc_hd__inv_1 U626 ( .A(s_wdg_pscr_q[7]), .Y(n387) );
  sky130_fd_sc_hd__o22ai_1 U627 ( .A1(n410), .A2(n270), .B1(n387), .B2(n268), 
        .Y(s_wdg_pscr_d[7]) );
  sky130_fd_sc_hd__inv_1 U628 ( .A(s_wdg_pscr_q[8]), .Y(n386) );
  sky130_fd_sc_hd__o22ai_1 U629 ( .A1(n409), .A2(n270), .B1(n386), .B2(n268), 
        .Y(s_wdg_pscr_d[8]) );
  sky130_fd_sc_hd__inv_1 U630 ( .A(n198), .Y(n385) );
  sky130_fd_sc_hd__o22ai_1 U631 ( .A1(n408), .A2(n270), .B1(n385), .B2(n268), 
        .Y(s_wdg_pscr_d[9]) );
  sky130_fd_sc_hd__inv_1 U632 ( .A(n197), .Y(n384) );
  sky130_fd_sc_hd__o22ai_1 U633 ( .A1(n270), .A2(n265), .B1(n384), .B2(n268), 
        .Y(s_wdg_pscr_d[10]) );
  sky130_fd_sc_hd__inv_1 U634 ( .A(n199), .Y(n383) );
  sky130_fd_sc_hd__o22ai_1 U635 ( .A1(n321), .A2(n270), .B1(n383), .B2(n268), 
        .Y(s_wdg_pscr_d[11]) );
  sky130_fd_sc_hd__inv_1 U636 ( .A(s_wdg_pscr_q[12]), .Y(n382) );
  sky130_fd_sc_hd__o22ai_1 U637 ( .A1(n320), .A2(n270), .B1(n382), .B2(n268), 
        .Y(s_wdg_pscr_d[12]) );
  sky130_fd_sc_hd__inv_1 U638 ( .A(s_wdg_pscr_q[13]), .Y(n381) );
  sky130_fd_sc_hd__o22ai_1 U639 ( .A1(n270), .A2(n266), .B1(n381), .B2(n268), 
        .Y(s_wdg_pscr_d[13]) );
  sky130_fd_sc_hd__inv_1 U640 ( .A(s_wdg_pscr_q[14]), .Y(n380) );
  sky130_fd_sc_hd__o22ai_1 U641 ( .A1(n319), .A2(n270), .B1(n380), .B2(n268), 
        .Y(s_wdg_pscr_d[14]) );
  sky130_fd_sc_hd__inv_1 U642 ( .A(s_wdg_pscr_q[15]), .Y(n379) );
  sky130_fd_sc_hd__o22ai_1 U643 ( .A1(n270), .A2(n267), .B1(n379), .B2(n268), 
        .Y(s_wdg_pscr_d[15]) );
  sky130_fd_sc_hd__inv_1 U644 ( .A(s_wdg_pscr_q[16]), .Y(n378) );
  sky130_fd_sc_hd__o22ai_1 U645 ( .A1(n407), .A2(n270), .B1(n378), .B2(n268), 
        .Y(s_wdg_pscr_d[16]) );
  sky130_fd_sc_hd__inv_1 U646 ( .A(s_wdg_pscr_q[17]), .Y(n377) );
  sky130_fd_sc_hd__o22ai_1 U647 ( .A1(n406), .A2(n270), .B1(n377), .B2(n268), 
        .Y(s_wdg_pscr_d[17]) );
  sky130_fd_sc_hd__inv_1 U648 ( .A(s_wdg_pscr_q[18]), .Y(n376) );
  sky130_fd_sc_hd__o22ai_1 U649 ( .A1(n405), .A2(n270), .B1(n376), .B2(n268), 
        .Y(s_wdg_pscr_d[18]) );
  sky130_fd_sc_hd__inv_1 U650 ( .A(s_wdg_pscr_q[19]), .Y(n375) );
  sky130_fd_sc_hd__o22ai_1 U651 ( .A1(n270), .A2(n269), .B1(n375), .B2(n268), 
        .Y(s_wdg_pscr_d[19]) );
  sky130_fd_sc_hd__inv_1 U652 ( .A(s_wdg_feed_q), .Y(n273) );
  sky130_fd_sc_hd__nor4_1 U653 ( .A(apb4_paddr[2]), .B(n271), .C(n317), .D(
        n396), .Y(n272) );
  sky130_fd_sc_hd__mux2i_1 U654 ( .A0(n273), .A1(n414), .S(n272), .Y(
        s_wdg_feed_d) );
  sky130_fd_sc_hd__inv_1 U655 ( .A(s_wdg_cnt_q[31]), .Y(n274) );
  sky130_fd_sc_hd__o2bb2ai_1 U656 ( .B1(n227), .B2(n274), .A1_N(N89), .A2_N(
        n226), .Y(s_wdg_cnt_d[31]) );
  sky130_fd_sc_hd__inv_1 U657 ( .A(s_wdg_cnt_q[30]), .Y(n275) );
  sky130_fd_sc_hd__o2bb2ai_1 U658 ( .B1(n227), .B2(n275), .A1_N(N88), .A2_N(
        n226), .Y(s_wdg_cnt_d[30]) );
  sky130_fd_sc_hd__inv_1 U659 ( .A(s_wdg_cnt_q[29]), .Y(n276) );
  sky130_fd_sc_hd__o2bb2ai_1 U660 ( .B1(n227), .B2(n276), .A1_N(N87), .A2_N(
        n226), .Y(s_wdg_cnt_d[29]) );
  sky130_fd_sc_hd__inv_1 U661 ( .A(s_wdg_cnt_q[28]), .Y(n277) );
  sky130_fd_sc_hd__o2bb2ai_1 U662 ( .B1(n227), .B2(n277), .A1_N(N86), .A2_N(
        n226), .Y(s_wdg_cnt_d[28]) );
  sky130_fd_sc_hd__inv_1 U663 ( .A(s_wdg_cnt_q[27]), .Y(n278) );
  sky130_fd_sc_hd__o2bb2ai_1 U664 ( .B1(n227), .B2(n278), .A1_N(N85), .A2_N(
        n226), .Y(s_wdg_cnt_d[27]) );
  sky130_fd_sc_hd__inv_1 U665 ( .A(s_wdg_cnt_q[26]), .Y(n279) );
  sky130_fd_sc_hd__o2bb2ai_1 U666 ( .B1(n227), .B2(n279), .A1_N(N84), .A2_N(
        n226), .Y(s_wdg_cnt_d[26]) );
  sky130_fd_sc_hd__inv_1 U667 ( .A(s_wdg_cnt_q[25]), .Y(n280) );
  sky130_fd_sc_hd__o2bb2ai_1 U668 ( .B1(n227), .B2(n280), .A1_N(N83), .A2_N(
        n225), .Y(s_wdg_cnt_d[25]) );
  sky130_fd_sc_hd__inv_1 U669 ( .A(s_wdg_cnt_q[24]), .Y(n281) );
  sky130_fd_sc_hd__o2bb2ai_1 U670 ( .B1(n227), .B2(n281), .A1_N(N82), .A2_N(
        n225), .Y(s_wdg_cnt_d[24]) );
  sky130_fd_sc_hd__inv_1 U671 ( .A(s_wdg_cnt_q[23]), .Y(n282) );
  sky130_fd_sc_hd__o2bb2ai_1 U672 ( .B1(n227), .B2(n282), .A1_N(N81), .A2_N(
        n225), .Y(s_wdg_cnt_d[23]) );
  sky130_fd_sc_hd__inv_1 U673 ( .A(s_wdg_cnt_q[22]), .Y(n283) );
  sky130_fd_sc_hd__o2bb2ai_1 U674 ( .B1(n227), .B2(n283), .A1_N(N80), .A2_N(
        n225), .Y(s_wdg_cnt_d[22]) );
  sky130_fd_sc_hd__inv_1 U675 ( .A(s_wdg_cnt_q[21]), .Y(n284) );
  sky130_fd_sc_hd__o2bb2ai_1 U676 ( .B1(n227), .B2(n284), .A1_N(N79), .A2_N(
        n225), .Y(s_wdg_cnt_d[21]) );
  sky130_fd_sc_hd__inv_1 U677 ( .A(s_wdg_cnt_q[20]), .Y(n285) );
  sky130_fd_sc_hd__o2bb2ai_1 U678 ( .B1(n227), .B2(n285), .A1_N(N78), .A2_N(
        n225), .Y(s_wdg_cnt_d[20]) );
  sky130_fd_sc_hd__inv_1 U679 ( .A(s_wdg_cnt_q[19]), .Y(n286) );
  sky130_fd_sc_hd__o2bb2ai_1 U680 ( .B1(n227), .B2(n286), .A1_N(N77), .A2_N(
        n225), .Y(s_wdg_cnt_d[19]) );
  sky130_fd_sc_hd__inv_1 U681 ( .A(s_wdg_cnt_q[18]), .Y(n287) );
  sky130_fd_sc_hd__o2bb2ai_1 U682 ( .B1(n228), .B2(n287), .A1_N(N76), .A2_N(
        n225), .Y(s_wdg_cnt_d[18]) );
  sky130_fd_sc_hd__inv_1 U683 ( .A(s_wdg_cnt_q[17]), .Y(n288) );
  sky130_fd_sc_hd__o2bb2ai_1 U684 ( .B1(n228), .B2(n288), .A1_N(N75), .A2_N(
        n225), .Y(s_wdg_cnt_d[17]) );
  sky130_fd_sc_hd__inv_1 U685 ( .A(s_wdg_cnt_q[16]), .Y(n289) );
  sky130_fd_sc_hd__o2bb2ai_1 U686 ( .B1(n228), .B2(n289), .A1_N(N74), .A2_N(
        n225), .Y(s_wdg_cnt_d[16]) );
  sky130_fd_sc_hd__inv_1 U687 ( .A(s_wdg_cnt_q[15]), .Y(n290) );
  sky130_fd_sc_hd__o2bb2ai_1 U688 ( .B1(n228), .B2(n290), .A1_N(N73), .A2_N(
        n225), .Y(s_wdg_cnt_d[15]) );
  sky130_fd_sc_hd__inv_1 U689 ( .A(s_wdg_cnt_q[14]), .Y(n291) );
  sky130_fd_sc_hd__o2bb2ai_1 U690 ( .B1(n228), .B2(n291), .A1_N(N72), .A2_N(
        n225), .Y(s_wdg_cnt_d[14]) );
  sky130_fd_sc_hd__inv_1 U691 ( .A(s_wdg_cnt_q[13]), .Y(n292) );
  sky130_fd_sc_hd__o2bb2ai_1 U692 ( .B1(n228), .B2(n292), .A1_N(N71), .A2_N(
        n225), .Y(s_wdg_cnt_d[13]) );
  sky130_fd_sc_hd__inv_1 U693 ( .A(s_wdg_cnt_q[12]), .Y(n293) );
  sky130_fd_sc_hd__o2bb2ai_1 U694 ( .B1(n228), .B2(n293), .A1_N(N70), .A2_N(
        n224), .Y(s_wdg_cnt_d[12]) );
  sky130_fd_sc_hd__inv_1 U695 ( .A(s_wdg_cnt_q[11]), .Y(n294) );
  sky130_fd_sc_hd__o2bb2ai_1 U696 ( .B1(n228), .B2(n294), .A1_N(N69), .A2_N(
        n224), .Y(s_wdg_cnt_d[11]) );
  sky130_fd_sc_hd__inv_1 U697 ( .A(s_wdg_cnt_q[10]), .Y(n295) );
  sky130_fd_sc_hd__o2bb2ai_1 U698 ( .B1(n228), .B2(n295), .A1_N(N68), .A2_N(
        n224), .Y(s_wdg_cnt_d[10]) );
  sky130_fd_sc_hd__inv_1 U699 ( .A(s_wdg_cnt_q[9]), .Y(n296) );
  sky130_fd_sc_hd__o2bb2ai_1 U700 ( .B1(n228), .B2(n296), .A1_N(N67), .A2_N(
        n224), .Y(s_wdg_cnt_d[9]) );
  sky130_fd_sc_hd__inv_1 U701 ( .A(s_wdg_cnt_q[8]), .Y(n297) );
  sky130_fd_sc_hd__o2bb2ai_1 U702 ( .B1(n228), .B2(n297), .A1_N(N66), .A2_N(
        n224), .Y(s_wdg_cnt_d[8]) );
  sky130_fd_sc_hd__inv_1 U703 ( .A(s_wdg_cnt_q[7]), .Y(n298) );
  sky130_fd_sc_hd__o2bb2ai_1 U704 ( .B1(n228), .B2(n298), .A1_N(N65), .A2_N(
        n224), .Y(s_wdg_cnt_d[7]) );
  sky130_fd_sc_hd__inv_1 U705 ( .A(s_wdg_cnt_q[6]), .Y(n299) );
  sky130_fd_sc_hd__o2bb2ai_1 U706 ( .B1(n228), .B2(n299), .A1_N(N64), .A2_N(
        n224), .Y(s_wdg_cnt_d[6]) );
  sky130_fd_sc_hd__inv_1 U707 ( .A(s_wdg_cnt_q[5]), .Y(n300) );
  sky130_fd_sc_hd__o2bb2ai_1 U708 ( .B1(n228), .B2(n300), .A1_N(N63), .A2_N(
        n224), .Y(s_wdg_cnt_d[5]) );
  sky130_fd_sc_hd__inv_1 U709 ( .A(s_wdg_cnt_q[4]), .Y(n301) );
  sky130_fd_sc_hd__o2bb2ai_1 U710 ( .B1(n229), .B2(n301), .A1_N(N62), .A2_N(
        n224), .Y(s_wdg_cnt_d[4]) );
  sky130_fd_sc_hd__inv_1 U711 ( .A(s_wdg_cnt_q[3]), .Y(n302) );
  sky130_fd_sc_hd__o2bb2ai_1 U712 ( .B1(n229), .B2(n302), .A1_N(N61), .A2_N(
        n224), .Y(s_wdg_cnt_d[3]) );
  sky130_fd_sc_hd__inv_1 U713 ( .A(s_wdg_cnt_q[2]), .Y(n303) );
  sky130_fd_sc_hd__o2bb2ai_1 U714 ( .B1(n229), .B2(n303), .A1_N(N60), .A2_N(
        n224), .Y(s_wdg_cnt_d[2]) );
  sky130_fd_sc_hd__inv_1 U715 ( .A(s_wdg_cnt_q[1]), .Y(n304) );
  sky130_fd_sc_hd__o2bb2ai_1 U716 ( .B1(n229), .B2(n304), .A1_N(N59), .A2_N(
        n224), .Y(s_wdg_cnt_d[1]) );
  sky130_fd_sc_hd__inv_1 U717 ( .A(s_wdg_cnt_q[0]), .Y(n305) );
  sky130_fd_sc_hd__o2bb2ai_1 U718 ( .B1(n229), .B2(n305), .A1_N(N58), .A2_N(
        n224), .Y(s_wdg_cnt_d[0]) );
  sky130_fd_sc_hd__inv_1 U719 ( .A(s_wdg_ctrl_q[2]), .Y(n306) );
  sky130_fd_sc_hd__mux2i_1 U720 ( .A0(n306), .A1(n413), .S(n204), .Y(
        s_wdg_ctrl_d[2]) );
  sky130_fd_sc_hd__inv_1 U721 ( .A(N0), .Y(n307) );
  sky130_fd_sc_hd__mux2i_1 U722 ( .A0(n307), .A1(n323), .S(n204), .Y(
        s_wdg_ctrl_d[1]) );
  sky130_fd_sc_hd__inv_1 U723 ( .A(s_wdg_ctrl_q[0]), .Y(n308) );
  sky130_fd_sc_hd__mux2i_1 U724 ( .A0(n308), .A1(n414), .S(n204), .Y(
        s_wdg_ctrl_d[0]) );
  sky130_fd_sc_hd__inv_1 U725 ( .A(apb4_paddr[2]), .Y(n318) );
  sky130_fd_sc_hd__o22ai_1 U726 ( .A1(n195), .A2(n310), .B1(n178), .B2(n309), 
        .Y(apb4_prdata[22]) );
  sky130_fd_sc_hd__o22ai_1 U727 ( .A1(n195), .A2(n312), .B1(n178), .B2(n311), 
        .Y(apb4_prdata[23]) );
  sky130_fd_sc_hd__o22ai_1 U728 ( .A1(n195), .A2(n314), .B1(n178), .B2(n313), 
        .Y(apb4_prdata[29]) );
  sky130_fd_sc_hd__o22ai_1 U729 ( .A1(n195), .A2(n316), .B1(n178), .B2(n315), 
        .Y(apb4_prdata[31]) );
endmodule

