/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 29 20:02:39 2025
/////////////////////////////////////////////////////////////


module dffrc_16_0002 ( clk_i, rst_n_i, dat_i, dat_o );
  input [15:0] dat_i;
  output [15:0] dat_o;
  input clk_i, rst_n_i;


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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[1]) );
endmodule


module dffr_DATA_WIDTH8_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i;


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


module dffr_DATA_WIDTH8_2 ( clk_i, rst_n_i, dat_i, dat_o );
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i;


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


module dffr_DATA_WIDTH8_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i;


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


module dffr_DATA_WIDTH1_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


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


module i2c_master_bit_ctrl_DW01_dec_2 ( A, SUM );
  input [15:0] A;
  output [15:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n16, n17, n18, n19, n20, n21, n22,
         n23, n26, n27, n30, n31, n32, n33, n36, n37, n40, n41, n42, n46, n47,
         n51, n52, n55, n56, n57, n59, n60, n61, n63, n65, n66, n67, n69, n70,
         n71, n72, n74, n75, n77, n78, n79, n81;
  assign n2 = A[14];
  assign n3 = A[13];
  assign n4 = A[12];
  assign n5 = A[11];
  assign n6 = A[10];
  assign n7 = A[9];
  assign n8 = A[8];
  assign n9 = A[7];
  assign n57 = A[6];
  assign n63 = A[5];
  assign n67 = A[4];
  assign n72 = A[3];
  assign n75 = A[2];
  assign n79 = A[1];
  assign n81 = A[0];

  sky130_fd_sc_hd__xnor2_1 U2 ( .A(A[15]), .B(n16), .Y(SUM[15]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n2), .B(n20), .Y(SUM[14]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n1), .B(n17), .Y(n16) );
  sky130_fd_sc_hd__nor2_1 U5 ( .A(n18), .B(n32), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U6 ( .A(n23), .B(n19), .Y(n18) );
  sky130_fd_sc_hd__xnor2_1 U9 ( .A(n3), .B(n26), .Y(SUM[13]) );
  sky130_fd_sc_hd__nand2_1 U10 ( .A(n1), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U11 ( .A(n22), .B(n32), .Y(n21) );
  sky130_fd_sc_hd__nor2_1 U13 ( .A(n3), .B(n4), .Y(n23) );
  sky130_fd_sc_hd__xnor2_1 U17 ( .A(n4), .B(n30), .Y(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n1), .B(n27), .Y(n26) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n4), .B(n32), .Y(n27) );
  sky130_fd_sc_hd__xnor2_1 U23 ( .A(n5), .B(n36), .Y(SUM[11]) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n1), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(n41), .B(n33), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U27 ( .A(n6), .B(n5), .Y(n33) );
  sky130_fd_sc_hd__xnor2_1 U31 ( .A(n6), .B(n40), .Y(SUM[10]) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(n1), .B(n37), .Y(n36) );
  sky130_fd_sc_hd__nor2_1 U33 ( .A(n6), .B(n42), .Y(n37) );
  sky130_fd_sc_hd__xnor2_1 U37 ( .A(n7), .B(n46), .Y(SUM[9]) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n1), .B(n41), .Y(n40) );
  sky130_fd_sc_hd__nor2_1 U41 ( .A(n8), .B(n7), .Y(n41) );
  sky130_fd_sc_hd__xor2_1 U45 ( .A(n1), .B(n8), .X(SUM[8]) );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(n1), .B(n47), .Y(n46) );
  sky130_fd_sc_hd__xnor2_1 U51 ( .A(n9), .B(n55), .Y(SUM[7]) );
  sky130_fd_sc_hd__nor2_1 U54 ( .A(n57), .B(n9), .Y(n52) );
  sky130_fd_sc_hd__xnor2_1 U58 ( .A(n57), .B(n59), .Y(SUM[6]) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n56), .B(n69), .Y(n55) );
  sky130_fd_sc_hd__nor2_1 U60 ( .A(n57), .B(n61), .Y(n56) );
  sky130_fd_sc_hd__xnor2_1 U64 ( .A(n63), .B(n65), .Y(SUM[5]) );
  sky130_fd_sc_hd__nand2_1 U65 ( .A(n69), .B(n60), .Y(n59) );
  sky130_fd_sc_hd__xor2_1 U72 ( .A(n69), .B(n67), .X(SUM[4]) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(n69), .B(n66), .Y(n65) );
  sky130_fd_sc_hd__xor2_1 U78 ( .A(n74), .B(n72), .X(SUM[3]) );
  sky130_fd_sc_hd__nor2_1 U81 ( .A(n75), .B(n72), .Y(n71) );
  sky130_fd_sc_hd__xnor2_1 U85 ( .A(n75), .B(n77), .Y(SUM[2]) );
  sky130_fd_sc_hd__nor2_1 U86 ( .A(n75), .B(n77), .Y(n74) );
  sky130_fd_sc_hd__xnor2_1 U90 ( .A(n81), .B(n79), .Y(SUM[1]) );
  sky130_fd_sc_hd__nor2_1 U92 ( .A(n79), .B(n81), .Y(n78) );
  sky130_fd_sc_hd__nor2_1 U100 ( .A(n67), .B(n63), .Y(n60) );
  sky130_fd_sc_hd__inv_2 U101 ( .A(n2), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U102 ( .A(n23), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U103 ( .A(n32), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U104 ( .A(n41), .Y(n42) );
  sky130_fd_sc_hd__inv_2 U105 ( .A(n8), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U106 ( .A(n52), .B(n60), .Y(n51) );
  sky130_fd_sc_hd__inv_2 U107 ( .A(n60), .Y(n61) );
  sky130_fd_sc_hd__inv_2 U108 ( .A(n67), .Y(n66) );
  sky130_fd_sc_hd__inv_2 U109 ( .A(n70), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(n81), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_2 U111 ( .A(n78), .Y(n77) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(n71), .B(n78), .Y(n70) );
  sky130_fd_sc_hd__nor2_4 U113 ( .A(n70), .B(n51), .Y(n1) );
endmodule


module i2c_master_bit_ctrl_DW01_dec_3 ( A, SUM );
  input [13:0] A;
  output [13:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n14, n15, n18, n19, n20, n21, n24,
         n25, n28, n29, n30, n34, n35, n39, n40, n43, n44, n47, n48, n49, n53,
         n54, n55, n57, n58, n59, n60, n62, n63, n65, n66, n67, n69;
  assign n2 = A[12];
  assign n3 = A[11];
  assign n4 = A[10];
  assign n5 = A[9];
  assign n6 = A[8];
  assign n7 = A[7];
  assign n8 = A[6];
  assign n9 = A[5];
  assign n55 = A[4];
  assign n60 = A[3];
  assign n63 = A[2];
  assign n67 = A[1];
  assign n69 = A[0];

  sky130_fd_sc_hd__xnor2_1 U2 ( .A(A[13]), .B(n14), .Y(SUM[13]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n2), .B(n18), .Y(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n1), .B(n15), .Y(n14) );
  sky130_fd_sc_hd__nor2_1 U5 ( .A(n2), .B(n20), .Y(n15) );
  sky130_fd_sc_hd__xnor2_1 U9 ( .A(n3), .B(n24), .Y(SUM[11]) );
  sky130_fd_sc_hd__nand2_1 U10 ( .A(n1), .B(n19), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n29), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U13 ( .A(n4), .B(n3), .Y(n21) );
  sky130_fd_sc_hd__xnor2_1 U17 ( .A(n4), .B(n28), .Y(SUM[10]) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n1), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n4), .B(n30), .Y(n25) );
  sky130_fd_sc_hd__xnor2_1 U23 ( .A(n5), .B(n34), .Y(SUM[9]) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n1), .B(n29), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U27 ( .A(n6), .B(n5), .Y(n29) );
  sky130_fd_sc_hd__xor2_1 U31 ( .A(n1), .B(n6), .X(SUM[8]) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(n1), .B(n35), .Y(n34) );
  sky130_fd_sc_hd__xnor2_1 U37 ( .A(n7), .B(n43), .Y(SUM[7]) );
  sky130_fd_sc_hd__nor2_1 U38 ( .A(n58), .B(n39), .Y(n1) );
  sky130_fd_sc_hd__nand2_1 U39 ( .A(n40), .B(n48), .Y(n39) );
  sky130_fd_sc_hd__nor2_1 U40 ( .A(n8), .B(n7), .Y(n40) );
  sky130_fd_sc_hd__xnor2_1 U44 ( .A(n8), .B(n47), .Y(SUM[6]) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n44), .B(n57), .Y(n43) );
  sky130_fd_sc_hd__nor2_1 U46 ( .A(n8), .B(n49), .Y(n44) );
  sky130_fd_sc_hd__xnor2_1 U50 ( .A(n9), .B(n53), .Y(SUM[5]) );
  sky130_fd_sc_hd__nand2_1 U51 ( .A(n57), .B(n48), .Y(n47) );
  sky130_fd_sc_hd__nor2_1 U54 ( .A(n55), .B(n9), .Y(n48) );
  sky130_fd_sc_hd__xor2_1 U58 ( .A(n57), .B(n55), .X(SUM[4]) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n57), .B(n54), .Y(n53) );
  sky130_fd_sc_hd__xor2_1 U64 ( .A(n62), .B(n60), .X(SUM[3]) );
  sky130_fd_sc_hd__nand2_1 U66 ( .A(n59), .B(n66), .Y(n58) );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(n63), .B(n60), .Y(n59) );
  sky130_fd_sc_hd__xnor2_1 U71 ( .A(n63), .B(n65), .Y(SUM[2]) );
  sky130_fd_sc_hd__nor2_1 U72 ( .A(n63), .B(n65), .Y(n62) );
  sky130_fd_sc_hd__xnor2_1 U76 ( .A(n69), .B(n67), .Y(SUM[1]) );
  sky130_fd_sc_hd__nor2_1 U78 ( .A(n67), .B(n69), .Y(n66) );
  sky130_fd_sc_hd__inv_2 U86 ( .A(n58), .Y(n57) );
  sky130_fd_sc_hd__inv_2 U87 ( .A(n29), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(n48), .Y(n49) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(n66), .Y(n65) );
  sky130_fd_sc_hd__inv_2 U90 ( .A(n20), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(n6), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U92 ( .A(n55), .Y(n54) );
  sky130_fd_sc_hd__inv_2 U93 ( .A(n69), .Y(SUM[0]) );
endmodule


module i2c_master_bit_ctrl ( clk_i, rst_n_i, ena_i, clk_cnt_i, cmd_i, 
        cmd_ack_o, busy_o, al_o, dat_i, dat_o, scl_i, scl_o, scl_dir_o, sda_i, 
        sda_o, sda_dir_o );
  input [15:0] clk_cnt_i;
  input [3:0] cmd_i;
  input clk_i, rst_n_i, ena_i, dat_i, scl_i, sda_i;
  output cmd_ack_o, busy_o, al_o, dat_o, scl_o, scl_dir_o, sda_o, sda_dir_o;
  wire   scl_o, r_dscl_dir, r_slave_wait, r_sSCL, N28, r_dSCL, r_clk_en, N33,
         N34, N35, N36, N37, N38, N39, N40, N41, N42, N43, N44, N45, N46, N47,
         N48, N71, N72, N73, N74, N75, N76, N77, N78, N79, N80, N81, N82, N83,
         N84, N85, N86, N87, N88, N89, N90, N91, N92, N93, N94, N95, N96, N97,
         N98, r_sSDA, N101, N102, r_sta_cond, r_sto_cond, N103, N104, N105,
         r_cmd_stop, r_sda_chk, N106, N107, N193, n2, n5, n67, n68, n73, n74,
         n75, n78, n79, n86, n88, n89, n98, n99, n101, n103, n105, n106, n107,
         n118, n119, n120, n121, n122, n123, n124, n125, n126, n127, n128,
         n129, n130, n131, n132, n133, n134, n135, n136, n137, n138, n139,
         n140, n141, n142, n143, n144, n145, n146, n147, n148, n149, n150,
         n151, n152, n153, n154, n155, n156, n157, n158, n159, n160, n161,
         n162, n163, n164, n165, n1, n3, n4, n6, n7, n8, n9, n10, n11, n12,
         n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26,
         n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40,
         n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54,
         n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n69, n70,
         n71, n72, n76, n77, n80, n81, n82, n83, n84, n85, n87, n90, n91, n92,
         n93, n94, n95, n96, n97, n100, n102, n104, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n166, n167, n168, n169, n170,
         n171, n172, n173, n174, n175, n176, n177, n178, n179, n180, n181,
         n182, n183, n184, n185, n186, n187, n188, n189, n190, n191, n192,
         n193, n194, n195, n196, n197, n198, n199, n200, n201, n202, n203,
         n204, n205, n206, n207;
  wire   [15:0] r_cnt;
  wire   [1:0] r_cSCL;
  wire   [1:0] r_cSDA;
  wire   [13:0] r_filter_cnt;
  wire   [2:0] r_fSCL;
  wire   [2:0] r_fSDA;
  wire   [17:0] r_c_state;
  assign sda_o = scl_o;

  sky130_fd_sc_hd__dfrtp_1 r_cSDA_reg_0_ ( .D(sda_i), .CLK(clk_i), .RESET_B(n6), .Q(r_cSDA[0]) );
  sky130_fd_sc_hd__dfrtp_1 r_cSDA_reg_1_ ( .D(r_cSDA[0]), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_cSDA[1]) );
  sky130_fd_sc_hd__dfrtp_1 r_cSCL_reg_0_ ( .D(scl_i), .CLK(clk_i), .RESET_B(n6), .Q(r_cSCL[0]) );
  sky130_fd_sc_hd__dfrtp_1 r_cSCL_reg_1_ ( .D(r_cSCL[0]), .CLK(clk_i), 
        .RESET_B(n7), .Q(r_cSCL[1]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_0_ ( .D(N85), .CLK(clk_i), 
        .RESET_B(n8), .Q(r_filter_cnt[0]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_1_ ( .D(N86), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_filter_cnt[1]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_2_ ( .D(N87), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_filter_cnt[2]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_3_ ( .D(N88), .CLK(clk_i), 
        .RESET_B(n7), .Q(r_filter_cnt[3]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_4_ ( .D(N89), .CLK(clk_i), 
        .RESET_B(n8), .Q(r_filter_cnt[4]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_5_ ( .D(N90), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_filter_cnt[5]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_6_ ( .D(N91), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_filter_cnt[6]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_7_ ( .D(N92), .CLK(clk_i), 
        .RESET_B(n7), .Q(r_filter_cnt[7]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_8_ ( .D(N93), .CLK(clk_i), 
        .RESET_B(n8), .Q(r_filter_cnt[8]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_9_ ( .D(N94), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_filter_cnt[9]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_10_ ( .D(N95), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_filter_cnt[10]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_11_ ( .D(N96), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_filter_cnt[11]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_12_ ( .D(N97), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_filter_cnt[12]) );
  sky130_fd_sc_hd__dfrtp_1 r_filter_cnt_reg_13_ ( .D(N98), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_filter_cnt[13]) );
  sky130_fd_sc_hd__dfsbp_1 r_dSDA_reg ( .D(r_sSDA), .CLK(clk_i), .SET_B(n8), 
        .Q(n40), .Q_N(n129) );
  sky130_fd_sc_hd__dfrtp_1 r_sto_cond_reg ( .D(N104), .CLK(clk_i), .RESET_B(n4), .Q(r_sto_cond) );
  sky130_fd_sc_hd__dfrtp_1 r_sta_cond_reg ( .D(N103), .CLK(clk_i), .RESET_B(n4), .Q(r_sta_cond) );
  sky130_fd_sc_hd__dfrtp_1 busy_o_reg ( .D(N105), .CLK(clk_i), .RESET_B(n4), 
        .Q(busy_o) );
  sky130_fd_sc_hd__edfxtp_1 dat_o_reg ( .D(r_sSDA), .DE(N107), .CLK(clk_i), 
        .Q(dat_o) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_16_ ( .D(n164), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_c_state[16]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_5_ ( .D(n158), .CLK(clk_i), .RESET_B(
        n4), .Q(r_c_state[5]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_6_ ( .D(n157), .CLK(clk_i), .RESET_B(
        n4), .Q(r_c_state[6]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_7_ ( .D(n156), .CLK(clk_i), .RESET_B(
        n4), .Q(r_c_state[7]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_8_ ( .D(n155), .CLK(clk_i), .RESET_B(
        n4), .Q(r_c_state[8]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_13_ ( .D(n150), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_c_state[13]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_14_ ( .D(n149), .CLK(clk_i), 
        .RESET_B(n4), .Q(r_c_state[14]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_15_ ( .D(n148), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_c_state[15]) );
  sky130_fd_sc_hd__dfrtp_1 r_sda_chk_reg ( .D(n130), .CLK(clk_i), .RESET_B(n6), 
        .Q(r_sda_chk) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_9_ ( .D(n154), .CLK(clk_i), .RESET_B(
        n6), .Q(r_c_state[9]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_10_ ( .D(n153), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_c_state[10]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_11_ ( .D(n152), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_c_state[11]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_12_ ( .D(n151), .CLK(clk_i), 
        .RESET_B(n6), .Q(r_c_state[12]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_0_ ( .D(n163), .CLK(clk_i), .RESET_B(
        n6), .Q(r_c_state[0]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_1_ ( .D(n162), .CLK(clk_i), .RESET_B(
        n6), .Q(r_c_state[1]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_2_ ( .D(n161), .CLK(clk_i), .RESET_B(
        n6), .Q(r_c_state[2]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_3_ ( .D(n160), .CLK(clk_i), .RESET_B(
        n6), .Q(r_c_state[3]) );
  sky130_fd_sc_hd__dfrtp_1 r_c_state_reg_4_ ( .D(n159), .CLK(clk_i), .RESET_B(
        n6), .Q(r_c_state[4]) );
  sky130_fd_sc_hd__dfrtp_1 r_slave_wait_reg ( .D(N28), .CLK(clk_i), .RESET_B(
        n7), .Q(r_slave_wait) );
  sky130_fd_sc_hd__dfrtp_1 r_cmd_stop_reg ( .D(n121), .CLK(clk_i), .RESET_B(n7), .Q(r_cmd_stop) );
  sky130_fd_sc_hd__dfrtp_1 cmd_ack_o_reg ( .D(N193), .CLK(clk_i), .RESET_B(n7), 
        .Q(cmd_ack_o) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_2_ ( .D(n144), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[2]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_1_ ( .D(n145), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[1]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_3_ ( .D(n143), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[3]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_4_ ( .D(n142), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[4]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_5_ ( .D(n141), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[5]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_6_ ( .D(n140), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[6]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_7_ ( .D(n139), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[7]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_8_ ( .D(n138), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[8]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_9_ ( .D(n137), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[9]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_10_ ( .D(n136), .CLK(clk_i), .RESET_B(n8), 
        .Q(r_cnt[10]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_11_ ( .D(n135), .CLK(clk_i), .RESET_B(n8), 
        .Q(r_cnt[11]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_12_ ( .D(n134), .CLK(clk_i), .RESET_B(n8), 
        .Q(r_cnt[12]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_13_ ( .D(n133), .CLK(clk_i), .RESET_B(n8), 
        .Q(r_cnt[13]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_14_ ( .D(n132), .CLK(clk_i), .RESET_B(n8), 
        .Q(r_cnt[14]) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_15_ ( .D(n131), .CLK(clk_i), .RESET_B(n8), 
        .Q(r_cnt[15]) );
  sky130_fd_sc_hd__a22o_1 U7 ( .A1(n180), .A2(r_fSDA[1]), .B1(n9), .B2(
        r_fSDA[2]), .X(n125) );
  sky130_fd_sc_hd__a22o_1 U8 ( .A1(n180), .A2(r_fSDA[0]), .B1(n9), .B2(
        r_fSDA[1]), .X(n126) );
  sky130_fd_sc_hd__a22o_1 U9 ( .A1(n5), .A2(r_fSDA[0]), .B1(r_cSDA[1]), .B2(
        n180), .X(n127) );
  sky130_fd_sc_hd__nand4_1 U77 ( .A(cmd_i[2]), .B(n79), .C(n207), .D(n206), 
        .Y(n78) );
  sky130_fd_sc_hd__nand4_1 U82 ( .A(n187), .B(n88), .C(cmd_i[3]), .D(n89), .Y(
        n86) );
  sky130_fd_sc_hd__nand4_1 U98 ( .A(cmd_i[0]), .B(n79), .C(n206), .D(n205), 
        .Y(n98) );
  sky130_fd_sc_hd__nand4b_1 U109 ( .A_N(al_o), .B(n197), .C(n107), .D(n198), 
        .Y(n68) );
  sky130_fd_sc_hd__o41a_1 U155 ( .A1(r_c_state[12]), .A2(r_c_state[16]), .A3(
        r_c_state[4]), .A4(r_c_state[8]), .B1(n3), .X(N193) );
  sky130_fd_sc_hd__nand2_1 U160 ( .A(n99), .B(n204), .Y(n118) );
  sky130_fd_sc_hd__nand4_1 U166 ( .A(n202), .B(n203), .C(n190), .D(n191), .Y(
        n67) );
  sky130_fd_sc_hd__nand4_1 U171 ( .A(n199), .B(n196), .C(n198), .D(n120), .Y(
        n73) );
  sky130_fd_sc_hd__nand4_1 U173 ( .A(n192), .B(n193), .C(n194), .D(n188), .Y(
        n105) );
  sky130_fd_sc_hd__o21a_1 U183 ( .A1(busy_o), .A2(r_sta_cond), .B1(n181), .X(
        N105) );
  sky130_fd_sc_hd__dfstp_2 r_fSDA_reg_0_ ( .D(n127), .CLK(clk_i), .SET_B(n6), 
        .Q(r_fSDA[0]) );
  sky130_fd_sc_hd__dfstp_2 r_fSDA_reg_1_ ( .D(n126), .CLK(clk_i), .SET_B(n7), 
        .Q(r_fSDA[1]) );
  sky130_fd_sc_hd__dfstp_2 r_fSDA_reg_2_ ( .D(n125), .CLK(clk_i), .SET_B(n8), 
        .Q(r_fSDA[2]) );
  sky130_fd_sc_hd__dfstp_2 r_fSCL_reg_0_ ( .D(n124), .CLK(clk_i), .SET_B(n7), 
        .Q(r_fSCL[0]) );
  sky130_fd_sc_hd__dfstp_2 r_fSCL_reg_1_ ( .D(n123), .CLK(clk_i), .SET_B(n8), 
        .Q(r_fSCL[1]) );
  sky130_fd_sc_hd__dfstp_2 r_fSCL_reg_2_ ( .D(n122), .CLK(clk_i), .SET_B(n4), 
        .Q(r_fSCL[2]) );
  sky130_fd_sc_hd__dfstp_2 r_sSCL_reg ( .D(N101), .CLK(clk_i), .SET_B(n4), .Q(
        r_sSCL) );
  sky130_fd_sc_hd__dfstp_2 r_sSDA_reg ( .D(N102), .CLK(clk_i), .SET_B(n8), .Q(
        r_sSDA) );
  sky130_fd_sc_hd__dfstp_2 r_dSCL_reg ( .D(r_sSCL), .CLK(clk_i), .SET_B(n8), 
        .Q(r_dSCL) );
  sky130_fd_sc_hd__dfstp_2 sda_dir_o_reg ( .D(n165), .CLK(clk_i), .SET_B(n8), 
        .Q(sda_dir_o) );
  sky130_fd_sc_hd__dfstp_2 scl_dir_o_reg ( .D(n147), .CLK(clk_i), .SET_B(n8), 
        .Q(scl_dir_o) );
  sky130_fd_sc_hd__dfstp_2 r_clk_en_reg ( .D(n128), .CLK(clk_i), .SET_B(n8), 
        .Q(r_clk_en) );
  sky130_fd_sc_hd__nor3_2 U101 ( .A(n184), .B(cmd_i[3]), .C(n99), .Y(n79) );
  i2c_master_bit_ctrl_DW01_dec_2 sub_149 ( .A({r_cnt[15:9], n13, r_cnt[7:5], 
        n15, r_cnt[3], n1, r_cnt[1], n17}), .SUM({N48, N47, N46, N45, N44, N43, 
        N42, N41, N40, N39, N38, N37, N36, N35, N34, N33}) );
  i2c_master_bit_ctrl_DW01_dec_3 sub_172 ( .A(r_filter_cnt), .SUM({N84, N83, 
        N82, N81, N80, N79, N78, N77, N76, N75, N74, N73, N72, N71}) );
  sky130_fd_sc_hd__dfrtp_1 r_cnt_reg_0_ ( .D(n146), .CLK(clk_i), .RESET_B(n7), 
        .Q(r_cnt[0]) );
  sky130_fd_sc_hd__dfxtp_1 r_dscl_dir_reg ( .D(scl_dir_o), .CLK(clk_i), .Q(
        r_dscl_dir) );
  sky130_fd_sc_hd__dfrtp_2 al_o_reg ( .D(N106), .CLK(clk_i), .RESET_B(n8), .Q(
        al_o) );
  sky130_fd_sc_hd__a2bb2o_1 U3 ( .A1_N(n184), .A2_N(n203), .B1(n179), .B2(
        r_c_state[4]), .X(n159) );
  sky130_fd_sc_hd__a2bb2o_1 U4 ( .A1_N(n184), .A2_N(n191), .B1(n179), .B2(
        r_c_state[8]), .X(n155) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n88), .Y(n184) );
  sky130_fd_sc_hd__nor4b_4 U6 ( .D_N(n119), .A(r_c_state[5]), .B(r_c_state[8]), 
        .C(r_c_state[4]), .Y(n75) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(r_c_state[10]), .B(n105), .Y(n120) );
  sky130_fd_sc_hd__nor2_1 U11 ( .A(r_c_state[1]), .B(n67), .Y(n119) );
  sky130_fd_sc_hd__nand3b_1 U12 ( .A_N(n73), .B(n75), .C(n200), .Y(n99) );
  sky130_fd_sc_hd__nor2_1 U13 ( .A(r_cnt[12]), .B(r_cnt[13]), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(cmd_i[2]), .Y(n205) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(n99), .Y(n187) );
  sky130_fd_sc_hd__nor2_2 U16 ( .A(al_o), .B(n179), .Y(n88) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(r_c_state[9]), .Y(n196) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(cmd_i[0]), .Y(n207) );
  sky130_fd_sc_hd__nand3_1 U19 ( .A(n207), .B(n205), .C(cmd_i[1]), .Y(n2) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(r_c_state[5]), .Y(n189) );
  sky130_fd_sc_hd__nand2_2 U21 ( .A(ena_i), .B(n180), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(n33), .Y(n34) );
  sky130_fd_sc_hd__o32ai_1 U23 ( .A1(n182), .A2(r_sSDA), .A3(n195), .B1(n181), 
        .B2(n118), .Y(N106) );
  sky130_fd_sc_hd__nor2_1 U24 ( .A(r_cnt[4]), .B(r_cnt[5]), .Y(n44) );
  sky130_fd_sc_hd__nor2_1 U25 ( .A(r_cnt[8]), .B(r_cnt[9]), .Y(n46) );
  sky130_fd_sc_hd__nor2_1 U26 ( .A(r_cnt[14]), .B(r_cnt[15]), .Y(n49) );
  sky130_fd_sc_hd__nor2_1 U27 ( .A(r_c_state[8]), .B(r_c_state[1]), .Y(n107)
         );
  sky130_fd_sc_hd__nand3_1 U28 ( .A(n199), .B(n196), .C(n200), .Y(n106) );
  sky130_fd_sc_hd__inv_2 U29 ( .A(sda_dir_o), .Y(n182) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(r_c_state[3]), .Y(n203) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(r_c_state[2]), .Y(n202) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(r_c_state[1]), .Y(n201) );
  sky130_fd_sc_hd__inv_2 U33 ( .A(r_c_state[12]), .Y(n199) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(r_c_state[11]), .Y(n198) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(r_c_state[10]), .Y(n197) );
  sky130_fd_sc_hd__inv_2 U36 ( .A(r_sda_chk), .Y(n195) );
  sky130_fd_sc_hd__inv_2 U37 ( .A(r_c_state[14]), .Y(n193) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(cmd_i[1]), .Y(n206) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(r_c_state[13]), .Y(n192) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(r_c_state[7]), .Y(n191) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(r_c_state[6]), .Y(n190) );
  sky130_fd_sc_hd__inv_2 U42 ( .A(r_c_state[16]), .Y(n188) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(n55), .B(n54), .Y(n185) );
  sky130_fd_sc_hd__inv_2 U44 ( .A(r_c_state[15]), .Y(n194) );
  sky130_fd_sc_hd__o22ai_1 U45 ( .A1(n101), .A2(n182), .B1(n103), .B2(n186), 
        .Y(n165) );
  sky130_fd_sc_hd__a211oi_1 U46 ( .A1(dat_i), .A2(n105), .B1(n106), .C1(n68), 
        .Y(n103) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(n101), .Y(n186) );
  sky130_fd_sc_hd__a21oi_1 U48 ( .A1(n187), .A2(n3), .B1(n179), .Y(n101) );
  sky130_fd_sc_hd__maj3_1 U49 ( .A(r_fSDA[0]), .B(r_fSDA[2]), .C(r_fSDA[1]), 
        .X(N102) );
  sky130_fd_sc_hd__nor3_1 U50 ( .A(cmd_i[0]), .B(cmd_i[2]), .C(cmd_i[1]), .Y(
        n89) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n22), .Y(n183) );
  sky130_fd_sc_hd__nor3_1 U52 ( .A(n184), .B(cmd_i[3]), .C(n99), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n166), .Y(n1) );
  sky130_fd_sc_hd__buf_1 U54 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__and2_1 U55 ( .A(r_clk_en), .B(n55), .X(n3) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(r_c_state[0]), .Y(n200) );
  sky130_fd_sc_hd__buf_1 U57 ( .A(rst_n_i), .X(n8) );
  sky130_fd_sc_hd__buf_1 U58 ( .A(rst_n_i), .X(n7) );
  sky130_fd_sc_hd__buf_1 U59 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__conb_1 U60 ( .LO(scl_o) );
  sky130_fd_sc_hd__nor2_1 U61 ( .A(r_cnt[10]), .B(r_cnt[11]), .Y(n47) );
  sky130_fd_sc_hd__nor2_1 U62 ( .A(r_cnt[6]), .B(r_cnt[7]), .Y(n45) );
  sky130_fd_sc_hd__nor2_1 U63 ( .A(r_cnt[0]), .B(r_cnt[2]), .Y(n42) );
  sky130_fd_sc_hd__inv_2 U64 ( .A(r_clk_en), .Y(n54) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(al_o), .Y(n55) );
  sky130_fd_sc_hd__nand4_1 U66 ( .A(n45), .B(n44), .C(n43), .D(n42), .Y(n53)
         );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(r_cnt[1]), .B(r_cnt[3]), .Y(n43) );
  sky130_fd_sc_hd__inv_2 U68 ( .A(r_sSCL), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(n180), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U70 ( .A(n174), .Y(n169) );
  sky130_fd_sc_hd__inv_2 U71 ( .A(n179), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U72 ( .A(n185), .Y(n179) );
  sky130_fd_sc_hd__nor4b_2 U73 ( .D_N(n11), .A(r_filter_cnt[6]), .B(
        r_filter_cnt[5]), .C(r_filter_cnt[4]), .Y(n32) );
  sky130_fd_sc_hd__and4_1 U74 ( .A(n26), .B(n25), .C(n24), .D(n23), .X(n11) );
  sky130_fd_sc_hd__and2_2 U75 ( .A(n21), .B(n174), .X(n12) );
  sky130_fd_sc_hd__inv_2 U76 ( .A(n93), .Y(n13) );
  sky130_fd_sc_hd__nor4b_2 U78 ( .D_N(n14), .A(r_filter_cnt[13]), .B(
        r_filter_cnt[12]), .C(r_filter_cnt[11]), .Y(n31) );
  sky130_fd_sc_hd__and4_1 U79 ( .A(n30), .B(n29), .C(n28), .D(n27), .X(n14) );
  sky130_fd_sc_hd__nor3_1 U80 ( .A(n75), .B(r_c_state[0]), .C(n179), .Y(n74)
         );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n112), .Y(n15) );
  sky130_fd_sc_hd__clkinv_1 U83 ( .A(r_cnt[4]), .Y(n112) );
  sky130_fd_sc_hd__clkinv_1 U84 ( .A(r_cnt[0]), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U85 ( .A(n16), .Y(n17) );
  sky130_fd_sc_hd__o211a_1 U86 ( .A1(n52), .A2(n53), .B1(n51), .C1(ena_i), .X(
        n18) );
  sky130_fd_sc_hd__nand2_1 U87 ( .A(r_slave_wait), .B(n18), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(r_slave_wait), .B(n18), .Y(n174) );
  sky130_fd_sc_hd__o211a_1 U89 ( .A1(n53), .A2(n52), .B1(n51), .C1(ena_i), .X(
        n21) );
  sky130_fd_sc_hd__o21ai_0 U90 ( .A1(n10), .A2(n200), .B1(n98), .Y(n163) );
  sky130_fd_sc_hd__o21ai_0 U91 ( .A1(n10), .A2(n196), .B1(n86), .Y(n154) );
  sky130_fd_sc_hd__o21ai_0 U92 ( .A1(n10), .A2(n192), .B1(n78), .Y(n150) );
  sky130_fd_sc_hd__o22ai_1 U93 ( .A1(n194), .A2(n10), .B1(n184), .B2(n193), 
        .Y(n148) );
  sky130_fd_sc_hd__o22ai_1 U94 ( .A1(n185), .A2(n188), .B1(n184), .B2(n194), 
        .Y(n164) );
  sky130_fd_sc_hd__o22ai_1 U95 ( .A1(n10), .A2(n201), .B1(n184), .B2(n200), 
        .Y(n162) );
  sky130_fd_sc_hd__o22ai_1 U96 ( .A1(n10), .A2(n202), .B1(n184), .B2(n201), 
        .Y(n161) );
  sky130_fd_sc_hd__o22ai_1 U97 ( .A1(n10), .A2(n203), .B1(n184), .B2(n202), 
        .Y(n160) );
  sky130_fd_sc_hd__o22ai_1 U99 ( .A1(n10), .A2(n189), .B1(n2), .B2(n183), .Y(
        n158) );
  sky130_fd_sc_hd__o22ai_1 U100 ( .A1(n10), .A2(n190), .B1(n184), .B2(n189), 
        .Y(n157) );
  sky130_fd_sc_hd__o22ai_1 U102 ( .A1(n10), .A2(n191), .B1(n184), .B2(n190), 
        .Y(n156) );
  sky130_fd_sc_hd__o22ai_1 U103 ( .A1(n10), .A2(n197), .B1(n184), .B2(n196), 
        .Y(n153) );
  sky130_fd_sc_hd__o22ai_1 U104 ( .A1(n10), .A2(n198), .B1(n184), .B2(n197), 
        .Y(n152) );
  sky130_fd_sc_hd__o22ai_1 U105 ( .A1(n10), .A2(n199), .B1(n184), .B2(n198), 
        .Y(n151) );
  sky130_fd_sc_hd__o22ai_1 U106 ( .A1(n185), .A2(n193), .B1(n184), .B2(n192), 
        .Y(n149) );
  sky130_fd_sc_hd__o22ai_1 U107 ( .A1(n185), .A2(n195), .B1(n184), .B2(n194), 
        .Y(n130) );
  sky130_fd_sc_hd__inv_2 U108 ( .A(n128), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(n21), .Y(n128) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(n63), .Y(n171) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(r_filter_cnt[0]), .Y(n26) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(r_filter_cnt[1]), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(r_filter_cnt[2]), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(r_filter_cnt[3]), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(r_filter_cnt[7]), .Y(n30) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(r_filter_cnt[8]), .Y(n29) );
  sky130_fd_sc_hd__inv_1 U118 ( .A(r_filter_cnt[9]), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U119 ( .A(r_filter_cnt[10]), .Y(n27) );
  sky130_fd_sc_hd__nand2_1 U120 ( .A(n32), .B(n31), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U121 ( .A(clk_cnt_i[15]), .Y(n175) );
  sky130_fd_sc_hd__clkinv_2 U122 ( .A(n5), .Y(n180) );
  sky130_fd_sc_hd__nand2_1 U123 ( .A(ena_i), .B(n5), .Y(n33) );
  sky130_fd_sc_hd__o2bb2ai_1 U124 ( .B1(n175), .B2(n35), .A1_N(N84), .A2_N(n34), .Y(N98) );
  sky130_fd_sc_hd__inv_1 U125 ( .A(clk_cnt_i[14]), .Y(n66) );
  sky130_fd_sc_hd__o2bb2ai_1 U126 ( .B1(n66), .B2(n35), .A1_N(N83), .A2_N(n34), 
        .Y(N97) );
  sky130_fd_sc_hd__inv_1 U127 ( .A(clk_cnt_i[13]), .Y(n71) );
  sky130_fd_sc_hd__o2bb2ai_1 U128 ( .B1(n71), .B2(n35), .A1_N(N82), .A2_N(n34), 
        .Y(N96) );
  sky130_fd_sc_hd__inv_1 U129 ( .A(clk_cnt_i[12]), .Y(n77) );
  sky130_fd_sc_hd__o2bb2ai_1 U130 ( .B1(n77), .B2(n35), .A1_N(N81), .A2_N(n34), 
        .Y(N95) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(clk_cnt_i[11]), .Y(n82) );
  sky130_fd_sc_hd__o2bb2ai_1 U132 ( .B1(n82), .B2(n35), .A1_N(N80), .A2_N(n34), 
        .Y(N94) );
  sky130_fd_sc_hd__inv_1 U133 ( .A(clk_cnt_i[10]), .Y(n85) );
  sky130_fd_sc_hd__o2bb2ai_1 U134 ( .B1(n85), .B2(n35), .A1_N(N79), .A2_N(n34), 
        .Y(N93) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(clk_cnt_i[9]), .Y(n91) );
  sky130_fd_sc_hd__o2bb2ai_1 U136 ( .B1(n91), .B2(n35), .A1_N(N78), .A2_N(n34), 
        .Y(N92) );
  sky130_fd_sc_hd__inv_1 U137 ( .A(clk_cnt_i[8]), .Y(n94) );
  sky130_fd_sc_hd__o2bb2ai_1 U138 ( .B1(n94), .B2(n35), .A1_N(N77), .A2_N(n34), 
        .Y(N91) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(clk_cnt_i[7]), .Y(n97) );
  sky130_fd_sc_hd__o2bb2ai_1 U140 ( .B1(n97), .B2(n35), .A1_N(N76), .A2_N(n34), 
        .Y(N90) );
  sky130_fd_sc_hd__inv_1 U141 ( .A(clk_cnt_i[6]), .Y(n104) );
  sky130_fd_sc_hd__o2bb2ai_1 U142 ( .B1(n104), .B2(n35), .A1_N(N75), .A2_N(n34), .Y(N89) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(clk_cnt_i[5]), .Y(n110) );
  sky130_fd_sc_hd__o2bb2ai_1 U144 ( .B1(n110), .B2(n35), .A1_N(N74), .A2_N(n34), .Y(N88) );
  sky130_fd_sc_hd__inv_1 U145 ( .A(clk_cnt_i[4]), .Y(n113) );
  sky130_fd_sc_hd__o2bb2ai_1 U146 ( .B1(n113), .B2(n35), .A1_N(N73), .A2_N(n34), .Y(N87) );
  sky130_fd_sc_hd__inv_1 U147 ( .A(clk_cnt_i[3]), .Y(n116) );
  sky130_fd_sc_hd__o2bb2ai_1 U148 ( .B1(n116), .B2(n35), .A1_N(N72), .A2_N(n34), .Y(N86) );
  sky130_fd_sc_hd__inv_1 U149 ( .A(clk_cnt_i[2]), .Y(n167) );
  sky130_fd_sc_hd__o2bb2ai_1 U150 ( .B1(n167), .B2(n35), .A1_N(N71), .A2_N(n34), .Y(N85) );
  sky130_fd_sc_hd__mux2_1 U151 ( .A0(r_fSCL[0]), .A1(r_cSCL[1]), .S(n180), .X(
        n124) );
  sky130_fd_sc_hd__inv_1 U152 ( .A(r_fSCL[1]), .Y(n38) );
  sky130_fd_sc_hd__inv_1 U153 ( .A(r_fSCL[0]), .Y(n39) );
  sky130_fd_sc_hd__mux2i_1 U154 ( .A0(n38), .A1(n39), .S(n180), .Y(n123) );
  sky130_fd_sc_hd__inv_1 U156 ( .A(r_fSCL[2]), .Y(n36) );
  sky130_fd_sc_hd__mux2i_1 U157 ( .A0(n36), .A1(n38), .S(n180), .Y(n122) );
  sky130_fd_sc_hd__o21ai_1 U158 ( .A1(r_fSCL[1]), .A2(r_fSCL[0]), .B1(
        r_fSCL[2]), .Y(n37) );
  sky130_fd_sc_hd__o21ai_1 U159 ( .A1(n39), .A2(n38), .B1(n37), .Y(N101) );
  sky130_fd_sc_hd__inv_1 U161 ( .A(r_sSDA), .Y(n41) );
  sky130_fd_sc_hd__nor3_1 U162 ( .A(n41), .B(n50), .C(n40), .Y(N104) );
  sky130_fd_sc_hd__inv_1 U163 ( .A(r_sto_cond), .Y(n181) );
  sky130_fd_sc_hd__nand4_1 U164 ( .A(n49), .B(n48), .C(n47), .D(n46), .Y(n52)
         );
  sky130_fd_sc_hd__nand3_2 U165 ( .A(scl_dir_o), .B(n50), .C(r_dSCL), .Y(n51)
         );
  sky130_fd_sc_hd__nor4_1 U167 ( .A(n67), .B(n68), .C(r_c_state[15]), .D(
        r_c_state[14]), .Y(n59) );
  sky130_fd_sc_hd__inv_1 U168 ( .A(scl_dir_o), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U169 ( .A(n73), .Y(n56) );
  sky130_fd_sc_hd__o21ai_1 U170 ( .A1(n56), .A2(r_c_state[0]), .B1(n3), .Y(n57) );
  sky130_fd_sc_hd__a21oi_1 U172 ( .A1(n57), .A2(n185), .B1(n74), .Y(n58) );
  sky130_fd_sc_hd__mux2i_1 U174 ( .A0(n59), .A1(n61), .S(n58), .Y(n147) );
  sky130_fd_sc_hd__inv_1 U175 ( .A(r_slave_wait), .Y(n60) );
  sky130_fd_sc_hd__o21ai_1 U176 ( .A1(r_dscl_dir), .A2(n61), .B1(n60), .Y(n62)
         );
  sky130_fd_sc_hd__and2_0 U177 ( .A(n62), .B(n50), .X(N28) );
  sky130_fd_sc_hd__inv_1 U178 ( .A(r_cnt[14]), .Y(n65) );
  sky130_fd_sc_hd__nand2_1 U179 ( .A(n174), .B(n21), .Y(n63) );
  sky130_fd_sc_hd__nand2_1 U180 ( .A(N47), .B(n12), .Y(n64) );
  sky130_fd_sc_hd__o221ai_1 U181 ( .A1(n20), .A2(n66), .B1(n19), .B2(n65), 
        .C1(n64), .Y(n132) );
  sky130_fd_sc_hd__inv_1 U182 ( .A(r_cnt[13]), .Y(n70) );
  sky130_fd_sc_hd__nand2_1 U184 ( .A(N46), .B(n12), .Y(n69) );
  sky130_fd_sc_hd__o221ai_1 U185 ( .A1(n20), .A2(n71), .B1(n19), .B2(n70), 
        .C1(n69), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U186 ( .A(r_cnt[12]), .Y(n76) );
  sky130_fd_sc_hd__nand2_1 U187 ( .A(N45), .B(n12), .Y(n72) );
  sky130_fd_sc_hd__o221ai_1 U188 ( .A1(n20), .A2(n77), .B1(n19), .B2(n76), 
        .C1(n72), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U189 ( .A(r_cnt[11]), .Y(n81) );
  sky130_fd_sc_hd__nand2_1 U190 ( .A(N44), .B(n12), .Y(n80) );
  sky130_fd_sc_hd__o221ai_1 U191 ( .A1(n20), .A2(n82), .B1(n19), .B2(n81), 
        .C1(n80), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U192 ( .A(r_cnt[10]), .Y(n84) );
  sky130_fd_sc_hd__nand2_1 U193 ( .A(N43), .B(n12), .Y(n83) );
  sky130_fd_sc_hd__o221ai_1 U194 ( .A1(n20), .A2(n85), .B1(n19), .B2(n84), 
        .C1(n83), .Y(n136) );
  sky130_fd_sc_hd__inv_1 U195 ( .A(r_cnt[9]), .Y(n90) );
  sky130_fd_sc_hd__nand2_1 U196 ( .A(N42), .B(n12), .Y(n87) );
  sky130_fd_sc_hd__o221ai_1 U197 ( .A1(n20), .A2(n91), .B1(n19), .B2(n90), 
        .C1(n87), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U198 ( .A(r_cnt[8]), .Y(n93) );
  sky130_fd_sc_hd__nand2_1 U199 ( .A(N41), .B(n12), .Y(n92) );
  sky130_fd_sc_hd__o221ai_1 U200 ( .A1(n20), .A2(n94), .B1(n19), .B2(n93), 
        .C1(n92), .Y(n138) );
  sky130_fd_sc_hd__inv_1 U201 ( .A(r_cnt[7]), .Y(n96) );
  sky130_fd_sc_hd__nand2_1 U202 ( .A(N40), .B(n12), .Y(n95) );
  sky130_fd_sc_hd__o221ai_1 U203 ( .A1(n20), .A2(n97), .B1(n19), .B2(n96), 
        .C1(n95), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U204 ( .A(r_cnt[6]), .Y(n102) );
  sky130_fd_sc_hd__nand2_1 U205 ( .A(N39), .B(n12), .Y(n100) );
  sky130_fd_sc_hd__o221ai_1 U206 ( .A1(n20), .A2(n104), .B1(n19), .B2(n102), 
        .C1(n100), .Y(n140) );
  sky130_fd_sc_hd__inv_1 U207 ( .A(r_cnt[5]), .Y(n109) );
  sky130_fd_sc_hd__nand2_1 U208 ( .A(N38), .B(n12), .Y(n108) );
  sky130_fd_sc_hd__o221ai_1 U209 ( .A1(n20), .A2(n110), .B1(n19), .B2(n109), 
        .C1(n108), .Y(n141) );
  sky130_fd_sc_hd__nand2_1 U210 ( .A(N37), .B(n12), .Y(n111) );
  sky130_fd_sc_hd__o221ai_1 U211 ( .A1(n20), .A2(n113), .B1(n19), .B2(n112), 
        .C1(n111), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U212 ( .A(r_cnt[3]), .Y(n115) );
  sky130_fd_sc_hd__nand2_1 U213 ( .A(N36), .B(n12), .Y(n114) );
  sky130_fd_sc_hd__o221ai_1 U214 ( .A1(n20), .A2(n116), .B1(n19), .B2(n115), 
        .C1(n114), .Y(n143) );
  sky130_fd_sc_hd__inv_1 U215 ( .A(r_cnt[2]), .Y(n166) );
  sky130_fd_sc_hd__nand2_1 U216 ( .A(N35), .B(n12), .Y(n117) );
  sky130_fd_sc_hd__o221ai_1 U217 ( .A1(n20), .A2(n167), .B1(n19), .B2(n166), 
        .C1(n117), .Y(n144) );
  sky130_fd_sc_hd__a222oi_1 U218 ( .A1(N34), .A2(n171), .B1(clk_cnt_i[1]), 
        .B2(n128), .C1(r_cnt[1]), .C2(n169), .Y(n168) );
  sky130_fd_sc_hd__inv_1 U219 ( .A(n168), .Y(n145) );
  sky130_fd_sc_hd__a222oi_1 U220 ( .A1(N33), .A2(n171), .B1(clk_cnt_i[0]), 
        .B2(n128), .C1(n17), .C2(n169), .Y(n170) );
  sky130_fd_sc_hd__inv_1 U221 ( .A(n170), .Y(n146) );
  sky130_fd_sc_hd__inv_1 U222 ( .A(r_cnt[15]), .Y(n173) );
  sky130_fd_sc_hd__nand2_1 U223 ( .A(N48), .B(n12), .Y(n172) );
  sky130_fd_sc_hd__o221ai_1 U224 ( .A1(n20), .A2(n175), .B1(n19), .B2(n173), 
        .C1(n172), .Y(n131) );
  sky130_fd_sc_hd__nor2_1 U225 ( .A(r_dSCL), .B(n50), .Y(N107) );
  sky130_fd_sc_hd__nor3_1 U226 ( .A(n129), .B(r_sSDA), .C(n50), .Y(N103) );
  sky130_fd_sc_hd__inv_1 U227 ( .A(r_cmd_stop), .Y(n204) );
  sky130_fd_sc_hd__inv_1 U228 ( .A(n2), .Y(n177) );
  sky130_fd_sc_hd__inv_1 U229 ( .A(cmd_i[3]), .Y(n176) );
  sky130_fd_sc_hd__nand2_1 U230 ( .A(n177), .B(n176), .Y(n178) );
  sky130_fd_sc_hd__mux2i_1 U231 ( .A0(n204), .A1(n178), .S(r_clk_en), .Y(n121)
         );
endmodule


module i2c_master_byte_ctrl ( clk_i, rst_n_i, ena_i, clk_cnt_i, start_i, 
        stop_i, read_i, write_i, ack_i, dat_i, cmd_ack_o, ack_o, dat_o, 
        i2c_busy_o, i2c_al_o, scl_i, scl_o, scl_dir_o, sda_i, sda_o, sda_dir_o
 );
  input [15:0] clk_cnt_i;
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i, ena_i, start_i, stop_i, read_i, write_i, ack_i, scl_i,
         sda_i;
  output cmd_ack_o, ack_o, i2c_busy_o, i2c_al_o, scl_o, scl_dir_o, sda_o,
         sda_dir_o;
  wire   scl_o, core_ack, core_txd, core_rxd, ld, shift, N93, N94, N95, N96,
         n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40,
         n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54,
         n55, n56, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69,
         n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n84, n85, n86, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
         n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n57,
         n87, n88, n89;
  wire   [3:0] core_cmd;
  wire   [2:0] dcnt;
  wire   [4:0] c_state;
  assign sda_o = scl_o;

  sky130_fd_sc_hd__dfrtp_1 c_state_reg_0_ ( .D(n86), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(c_state[0]) );
  sky130_fd_sc_hd__dfrtp_1 core_txd_reg ( .D(N93), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(core_txd) );
  sky130_fd_sc_hd__dfrtp_1 c_state_reg_1_ ( .D(n81), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(c_state[1]) );
  sky130_fd_sc_hd__dfrtp_1 shift_reg ( .D(N94), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(shift) );
  sky130_fd_sc_hd__dfrtp_1 dcnt_reg_0_ ( .D(n83), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dcnt[0]) );
  sky130_fd_sc_hd__dfrtp_1 c_state_reg_3_ ( .D(n79), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(c_state[3]) );
  sky130_fd_sc_hd__dfrtp_1 ack_o_reg ( .D(n66), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(ack_o) );
  sky130_fd_sc_hd__dfrtp_1 c_state_reg_2_ ( .D(n80), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(c_state[2]) );
  sky130_fd_sc_hd__dfrtp_1 core_cmd_reg_2_ ( .D(n76), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(core_cmd[2]) );
  sky130_fd_sc_hd__dfrtp_1 core_cmd_reg_3_ ( .D(n75), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(core_cmd[3]) );
  sky130_fd_sc_hd__dfrtp_1 core_cmd_reg_1_ ( .D(n77), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(core_cmd[1]) );
  sky130_fd_sc_hd__dfrtp_1 c_state_reg_4_ ( .D(n85), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(c_state[4]) );
  sky130_fd_sc_hd__dfrtp_1 cmd_ack_o_reg ( .D(N96), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(cmd_ack_o) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_0_ ( .D(n73), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_1_ ( .D(n74), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_2_ ( .D(n72), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_3_ ( .D(n71), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_4_ ( .D(n70), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_5_ ( .D(n69), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_6_ ( .D(n68), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 sr_reg_7_ ( .D(n67), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dcnt_reg_1_ ( .D(n84), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dcnt[1]) );
  sky130_fd_sc_hd__dfrtp_1 dcnt_reg_2_ ( .D(n82), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dcnt[2]) );
  sky130_fd_sc_hd__dfrtp_1 core_cmd_reg_0_ ( .D(n78), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(core_cmd[0]) );
  sky130_fd_sc_hd__o21ai_1 U16 ( .A1(n89), .A2(n7), .B1(n48), .Y(n78) );
  sky130_fd_sc_hd__o21ai_1 U20 ( .A1(n50), .A2(n19), .B1(n44), .Y(n80) );
  sky130_fd_sc_hd__o21ai_1 U22 ( .A1(n50), .A2(n15), .B1(n39), .Y(n81) );
  sky130_fd_sc_hd__o21ai_1 U26 ( .A1(dcnt[1]), .A2(n54), .B1(dcnt[2]), .Y(n53)
         );
  sky130_fd_sc_hd__o21ai_1 U30 ( .A1(n7), .A2(n14), .B1(n48), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(core_ack), .B(c_state[3]), .Y(n28) );
  sky130_fd_sc_hd__nand2_1 U70 ( .A(ld), .B(dat_i[7]), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U71 ( .A(dat_i[6]), .B(ld), .Y(n32) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(dat_i[5]), .B(ld), .Y(n33) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(dat_i[4]), .B(ld), .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U74 ( .A(dat_i[3]), .B(ld), .Y(n35) );
  sky130_fd_sc_hd__nand2_1 U75 ( .A(dat_i[2]), .B(ld), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(dat_i[0]), .B(ld), .Y(n37) );
  sky130_fd_sc_hd__nand2_1 U77 ( .A(dat_i[1]), .B(ld), .Y(n38) );
  sky130_fd_sc_hd__a32oi_1 U78 ( .A1(n42), .A2(n17), .A3(n4), .B1(core_cmd[3]), 
        .B2(n2), .Y(n41) );
  sky130_fd_sc_hd__a32oi_1 U79 ( .A1(n42), .A2(n17), .A3(c_state[2]), .B1(
        core_cmd[2]), .B2(n2), .Y(n46) );
  sky130_fd_sc_hd__a21o_1 U80 ( .A1(n52), .A2(write_i), .B1(c_state[0]), .X(
        n51) );
  sky130_fd_sc_hd__a21bo_1 U81 ( .A1(n54), .A2(dcnt[1]), .B1_N(n55), .X(n84)
         );
  sky130_fd_sc_hd__o31a_1 U82 ( .A1(dcnt[0]), .A2(dcnt[1]), .A3(n29), .B1(n21), 
        .X(n55) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n30), .B(n16), .Y(n54) );
  sky130_fd_sc_hd__nand2_1 U84 ( .A(n21), .B(n29), .Y(n30) );
  sky130_fd_sc_hd__a32oi_1 U86 ( .A1(n52), .A2(n11), .A3(n10), .B1(c_state[3]), 
        .B2(stop_i), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U87 ( .A(c_state[3]), .B(n9), .Y(n58) );
  sky130_fd_sc_hd__nand2_1 U90 ( .A(core_ack), .B(n13), .Y(n59) );
  sky130_fd_sc_hd__a222oi_1 U91 ( .A1(ack_i), .A2(c_state[3]), .B1(core_ack), 
        .B2(n63), .C1(dat_o[7]), .C2(n64), .Y(n62) );
  i2c_master_bit_ctrl u_i2c_master_bit_ctrl ( .clk_i(clk_i), .rst_n_i(rst_n_i), 
        .ena_i(ena_i), .clk_cnt_i(clk_cnt_i), .cmd_i(core_cmd), .cmd_ack_o(
        core_ack), .busy_o(i2c_busy_o), .al_o(i2c_al_o), .dat_i(core_txd), 
        .dat_o(core_rxd), .scl_i(scl_i), .scl_dir_o(scl_dir_o), .sda_i(sda_i), 
        .sda_dir_o(sda_dir_o) );
  sky130_fd_sc_hd__dfrtp_1 ld_reg ( .D(N95), .CLK(clk_i), .RESET_B(rst_n_i), 
        .Q(ld) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(read_i), .Y(n10) );
  sky130_fd_sc_hd__and4_1 U4 ( .A(n18), .B(n20), .C(n19), .D(n60), .X(n5) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(dat_o[6]), .Y(n87) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(ld), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U7 ( .A(shift), .B(n21), .Y(n29) );
  sky130_fd_sc_hd__o32ai_1 U8 ( .A1(n1), .A2(i2c_al_o), .A3(n56), .B1(n14), 
        .B2(n59), .Y(N95) );
  sky130_fd_sc_hd__nor3_1 U9 ( .A(dcnt[1]), .B(dcnt[2]), .C(dcnt[0]), .Y(n49)
         );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n56), .B(start_i), .Y(n52) );
  sky130_fd_sc_hd__nor2_1 U11 ( .A(n43), .B(i2c_al_o), .Y(n3) );
  sky130_fd_sc_hd__nand4_1 U12 ( .A(n18), .B(n20), .C(n19), .D(n60), .Y(n56)
         );
  sky130_fd_sc_hd__inv_2 U13 ( .A(dat_o[5]), .Y(n57) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(dat_o[4]), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(dat_o[3]), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(dat_o[2]), .Y(n24) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(dat_o[1]), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(dat_o[0]), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(stop_i), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(c_state[4]), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(core_rxd), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(dcnt[0]), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(n49), .Y(n17) );
  sky130_fd_sc_hd__nand3_1 U28 ( .A(n3), .B(n5), .C(start_i), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U29 ( .A(n2), .Y(n7) );
  sky130_fd_sc_hd__o221ai_1 U31 ( .A1(n29), .A2(n87), .B1(n30), .B2(n88), .C1(
        n31), .Y(n67) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(dat_o[7]), .Y(n88) );
  sky130_fd_sc_hd__o211ai_1 U33 ( .A1(n18), .A2(n7), .B1(n45), .C1(n40), .Y(
        n79) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(write_i), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(core_ack), .Y(n6) );
  sky130_fd_sc_hd__inv_2 U36 ( .A(c_state[2]), .Y(n19) );
  sky130_fd_sc_hd__nand3_1 U37 ( .A(n51), .B(n10), .C(n3), .Y(n44) );
  sky130_fd_sc_hd__a21oi_1 U38 ( .A1(n13), .A2(n17), .B1(n2), .Y(n50) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(core_cmd[0]), .Y(n89) );
  sky130_fd_sc_hd__o211ai_1 U40 ( .A1(n29), .A2(n17), .B1(n53), .C1(n21), .Y(
        n82) );
  sky130_fd_sc_hd__o221ai_1 U41 ( .A1(n29), .A2(n57), .B1(n87), .B2(n30), .C1(
        n32), .Y(n68) );
  sky130_fd_sc_hd__o221ai_1 U42 ( .A1(n29), .A2(n26), .B1(n30), .B2(n57), .C1(
        n33), .Y(n69) );
  sky130_fd_sc_hd__o221ai_1 U43 ( .A1(n29), .A2(n25), .B1(n30), .B2(n26), .C1(
        n34), .Y(n70) );
  sky130_fd_sc_hd__o221ai_1 U44 ( .A1(n29), .A2(n24), .B1(n30), .B2(n25), .C1(
        n35), .Y(n71) );
  sky130_fd_sc_hd__o221ai_1 U45 ( .A1(n29), .A2(n23), .B1(n30), .B2(n24), .C1(
        n36), .Y(n72) );
  sky130_fd_sc_hd__o221ai_1 U46 ( .A1(n29), .A2(n22), .B1(n30), .B2(n23), .C1(
        n38), .Y(n74) );
  sky130_fd_sc_hd__o221ai_1 U47 ( .A1(n12), .A2(n29), .B1(n30), .B2(n22), .C1(
        n37), .Y(n73) );
  sky130_fd_sc_hd__a21oi_1 U48 ( .A1(n20), .A2(n58), .B1(n59), .Y(N96) );
  sky130_fd_sc_hd__o22ai_1 U49 ( .A1(n7), .A2(n20), .B1(n47), .B2(n8), .Y(n85)
         );
  sky130_fd_sc_hd__o2bb2ai_1 U50 ( .B1(n47), .B2(n8), .A1_N(core_cmd[1]), 
        .A2_N(n2), .Y(n77) );
  sky130_fd_sc_hd__nor2_1 U51 ( .A(i2c_al_o), .B(n27), .Y(n66) );
  sky130_fd_sc_hd__a2bb2oi_1 U52 ( .B1(ack_o), .B2(n28), .A1_N(n12), .A2_N(n28), .Y(n27) );
  sky130_fd_sc_hd__o221ai_1 U53 ( .A1(dcnt[0]), .A2(n29), .B1(n30), .B2(n16), 
        .C1(n21), .Y(n83) );
  sky130_fd_sc_hd__nor2_1 U54 ( .A(n61), .B(n59), .Y(N94) );
  sky130_fd_sc_hd__nor2_1 U55 ( .A(i2c_al_o), .B(n62), .Y(N93) );
  sky130_fd_sc_hd__a21o_1 U56 ( .A1(c_state[1]), .A2(ack_i), .B1(c_state[3]), 
        .X(n63) );
  sky130_fd_sc_hd__a31o_2 U57 ( .A1(n9), .A2(n11), .A3(n10), .B1(cmd_ack_o), 
        .X(n1) );
  sky130_fd_sc_hd__conb_1 U58 ( .LO(scl_o) );
  sky130_fd_sc_hd__o221a_4 U59 ( .A1(n5), .A2(n6), .B1(n56), .B2(n1), .C1(n13), 
        .X(n2) );
  sky130_fd_sc_hd__o221a_1 U60 ( .A1(n5), .A2(n6), .B1(n56), .B2(n1), .C1(n13), 
        .X(n43) );
  sky130_fd_sc_hd__nand3_1 U61 ( .A(n46), .B(n45), .C(n44), .Y(n76) );
  sky130_fd_sc_hd__nand3_1 U62 ( .A(n41), .B(n40), .C(n39), .Y(n75) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(c_state[0]), .Y(n14) );
  sky130_fd_sc_hd__nor3_1 U64 ( .A(c_state[0]), .B(c_state[4]), .C(c_state[2]), 
        .Y(n65) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(n15), .Y(n4) );
  sky130_fd_sc_hd__nor2_2 U66 ( .A(c_state[1]), .B(c_state[0]), .Y(n60) );
  sky130_fd_sc_hd__clkinv_1 U67 ( .A(c_state[3]), .Y(n18) );
  sky130_fd_sc_hd__a21oi_1 U68 ( .A1(c_state[2]), .A2(n17), .B1(n4), .Y(n61)
         );
  sky130_fd_sc_hd__o221ai_1 U85 ( .A1(c_state[3]), .A2(n4), .B1(core_ack), 
        .B2(n15), .C1(n65), .Y(n64) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(c_state[1]), .Y(n15) );
  sky130_fd_sc_hd__inv_1 U89 ( .A(i2c_al_o), .Y(n13) );
  sky130_fd_sc_hd__nor2_4 U92 ( .A(n2), .B(i2c_al_o), .Y(n42) );
  sky130_fd_sc_hd__o211ai_1 U93 ( .A1(n52), .A2(c_state[0]), .B1(n42), .C1(
        read_i), .Y(n39) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(n3), .Y(n8) );
  sky130_fd_sc_hd__nand3_1 U95 ( .A(n42), .B(n49), .C(n4), .Y(n45) );
  sky130_fd_sc_hd__nand3_1 U96 ( .A(n3), .B(n49), .C(c_state[2]), .Y(n40) );
endmodule


module apb4_i2c ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr, i2c_scl_i, i2c_scl_o, i2c_scl_dir_o, 
        i2c_sda_i, i2c_sda_o, i2c_sda_dir_o, i2c_irq_o );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite,
         i2c_scl_i, i2c_sda_i;
  output apb4_pready, apb4_pslverr, i2c_scl_o, i2c_scl_dir_o, i2c_sda_o,
         i2c_sda_dir_o, i2c_irq_o;
  wire   s_i2c_sr_1, s_i2c_sr_0, s_i2c_done, s_i2c_al, s_i2c_al_d,
         s_i2c_rxack_d, s_i2c_tip_d, s_i2c_irq_d, s_irq_d, n46, n47, n48, n49,
         n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63,
         n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77,
         n78, apb4_pslverr, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102,
         n103, n104, n105, n106, n107, n108, n109, n110, n111, n112, n113,
         n114, n115, n116, n117, n118, n119, n120, n121, n122, n123, n124;
  wire   [7:0] s_i2c_cmd_q;
  wire   [7:0] s_i2c_ctrl_q;
  wire   [7:5] s_i2c_sr;
  wire   [15:0] s_i2c_pscr_d;
  wire   [15:0] s_i2c_pscr_q;
  wire   [7:0] s_i2c_ctrl_d;
  wire   [7:0] s_i2c_txr_d;
  wire   [7:0] s_i2c_txr_q;
  wire   [7:0] s_i2c_cmd_d;
  wire   [7:0] s_i2c_rxr;
  assign i2c_sda_o = apb4_pslverr;
  assign i2c_scl_o = apb4_pslverr;
  assign apb4_prdata[31] = apb4_pslverr;
  assign apb4_prdata[30] = apb4_pslverr;
  assign apb4_prdata[29] = apb4_pslverr;
  assign apb4_prdata[28] = apb4_pslverr;
  assign apb4_prdata[27] = apb4_pslverr;
  assign apb4_prdata[26] = apb4_pslverr;
  assign apb4_prdata[25] = apb4_pslverr;
  assign apb4_prdata[24] = apb4_pslverr;
  assign apb4_prdata[23] = apb4_pslverr;
  assign apb4_prdata[22] = apb4_pslverr;
  assign apb4_prdata[21] = apb4_pslverr;
  assign apb4_prdata[20] = apb4_pslverr;
  assign apb4_prdata[19] = apb4_pslverr;
  assign apb4_prdata[18] = apb4_pslverr;
  assign apb4_prdata[17] = apb4_pslverr;
  assign apb4_prdata[16] = apb4_pslverr;

  sky130_fd_sc_hd__nand2_1 U104 ( .A(n91), .B(n92), .Y(s_i2c_tip_d) );
  sky130_fd_sc_hd__a22o_1 U105 ( .A1(n49), .A2(s_i2c_pscr_q[9]), .B1(
        apb4_pwdata[9]), .B2(n112), .X(s_i2c_pscr_d[9]) );
  sky130_fd_sc_hd__a22o_1 U106 ( .A1(n49), .A2(s_i2c_pscr_q[8]), .B1(
        apb4_pwdata[8]), .B2(n112), .X(s_i2c_pscr_d[8]) );
  sky130_fd_sc_hd__a22o_1 U107 ( .A1(apb4_pwdata[7]), .A2(n112), .B1(n49), 
        .B2(s_i2c_pscr_q[7]), .X(s_i2c_pscr_d[7]) );
  sky130_fd_sc_hd__a22o_1 U108 ( .A1(apb4_pwdata[6]), .A2(n112), .B1(n49), 
        .B2(s_i2c_pscr_q[6]), .X(s_i2c_pscr_d[6]) );
  sky130_fd_sc_hd__a22o_1 U109 ( .A1(apb4_pwdata[1]), .A2(n112), .B1(n49), 
        .B2(s_i2c_pscr_q[1]), .X(s_i2c_pscr_d[1]) );
  sky130_fd_sc_hd__a22o_1 U110 ( .A1(n49), .A2(s_i2c_pscr_q[15]), .B1(
        apb4_pwdata[15]), .B2(n112), .X(s_i2c_pscr_d[15]) );
  sky130_fd_sc_hd__a22o_1 U111 ( .A1(n49), .A2(s_i2c_pscr_q[14]), .B1(
        apb4_pwdata[14]), .B2(n112), .X(s_i2c_pscr_d[14]) );
  sky130_fd_sc_hd__a22o_1 U112 ( .A1(n49), .A2(s_i2c_pscr_q[13]), .B1(
        apb4_pwdata[13]), .B2(n112), .X(s_i2c_pscr_d[13]) );
  sky130_fd_sc_hd__a22o_1 U113 ( .A1(n49), .A2(s_i2c_pscr_q[12]), .B1(
        apb4_pwdata[12]), .B2(n112), .X(s_i2c_pscr_d[12]) );
  sky130_fd_sc_hd__a22o_1 U114 ( .A1(n49), .A2(s_i2c_pscr_q[11]), .B1(
        apb4_pwdata[11]), .B2(n112), .X(s_i2c_pscr_d[11]) );
  sky130_fd_sc_hd__a22o_1 U115 ( .A1(n49), .A2(s_i2c_pscr_q[10]), .B1(
        apb4_pwdata[10]), .B2(n112), .X(s_i2c_pscr_d[10]) );
  sky130_fd_sc_hd__a31oi_1 U117 ( .A1(n94), .A2(n80), .A3(n93), .B1(
        s_i2c_cmd_q[0]), .Y(s_i2c_irq_d) );
  sky130_fd_sc_hd__nor2b_1 U119 ( .B_N(n53), .A(apb4_paddr[5]), .Y(n47) );
  sky130_fd_sc_hd__and3_1 U121 ( .A(apb4_psel), .B(apb4_penable), .C(
        apb4_pwrite), .X(n53) );
  sky130_fd_sc_hd__a21o_1 U122 ( .A1(n89), .A2(s_i2c_sr[5]), .B1(s_i2c_al), 
        .X(s_i2c_al_d) );
  sky130_fd_sc_hd__nor2b_1 U123 ( .B_N(s_i2c_pscr_q[9]), .A(n57), .Y(
        apb4_prdata[9]) );
  sky130_fd_sc_hd__nor2b_1 U124 ( .B_N(s_i2c_pscr_q[8]), .A(n57), .Y(
        apb4_prdata[8]) );
  sky130_fd_sc_hd__a22o_1 U125 ( .A1(n108), .A2(s_i2c_pscr_q[7]), .B1(n109), 
        .B2(n58), .X(apb4_prdata[7]) );
  sky130_fd_sc_hd__a222oi_1 U126 ( .A1(s_i2c_rxr[7]), .A2(n60), .B1(
        s_i2c_sr[7]), .B2(n61), .C1(s_i2c_cmd_q[7]), .C2(n56), .Y(n59) );
  sky130_fd_sc_hd__a22o_1 U127 ( .A1(n108), .A2(s_i2c_pscr_q[6]), .B1(n109), 
        .B2(n62), .X(apb4_prdata[6]) );
  sky130_fd_sc_hd__a222oi_1 U128 ( .A1(s_i2c_rxr[6]), .A2(n60), .B1(
        s_i2c_sr[6]), .B2(n61), .C1(s_i2c_cmd_q[6]), .C2(n56), .Y(n63) );
  sky130_fd_sc_hd__a22o_1 U129 ( .A1(n56), .A2(s_i2c_cmd_q[5]), .B1(
        s_i2c_sr[5]), .B2(n61), .X(n67) );
  sky130_fd_sc_hd__a22o_1 U130 ( .A1(n108), .A2(s_i2c_pscr_q[1]), .B1(n109), 
        .B2(n74), .X(apb4_prdata[1]) );
  sky130_fd_sc_hd__a222oi_1 U131 ( .A1(s_i2c_rxr[1]), .A2(n60), .B1(s_i2c_sr_1), .B2(n61), .C1(s_i2c_cmd_q[1]), .C2(n56), .Y(n75) );
  sky130_fd_sc_hd__nor2b_1 U132 ( .B_N(s_i2c_pscr_q[15]), .A(n57), .Y(
        apb4_prdata[15]) );
  sky130_fd_sc_hd__nor2b_1 U133 ( .B_N(s_i2c_pscr_q[14]), .A(n57), .Y(
        apb4_prdata[14]) );
  sky130_fd_sc_hd__nor2b_1 U134 ( .B_N(s_i2c_pscr_q[13]), .A(n57), .Y(
        apb4_prdata[13]) );
  sky130_fd_sc_hd__nor2b_1 U135 ( .B_N(s_i2c_pscr_q[12]), .A(n57), .Y(
        apb4_prdata[12]) );
  sky130_fd_sc_hd__nor2b_1 U136 ( .B_N(s_i2c_pscr_q[11]), .A(n57), .Y(
        apb4_prdata[11]) );
  sky130_fd_sc_hd__nor2b_1 U137 ( .B_N(s_i2c_pscr_q[10]), .A(n57), .Y(
        apb4_prdata[10]) );
  sky130_fd_sc_hd__a22o_1 U138 ( .A1(s_i2c_sr_0), .A2(n61), .B1(n56), .B2(
        s_i2c_cmd_q[0]), .X(n78) );
  sky130_fd_sc_hd__nand4b_1 U140 ( .A_N(apb4_pwrite), .B(apb4_psel), .C(
        apb4_penable), .D(n110), .Y(n65) );
  dffrc_16_0002 u_i2c_pscr_dffrc ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_i2c_pscr_d), .dat_o(s_i2c_pscr_q) );
  dffr_DATA_WIDTH8_0 u_i2c_ctrl_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_i2c_ctrl_d), .dat_o(s_i2c_ctrl_q) );
  dffr_DATA_WIDTH8_2 u_i2c_txr_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .dat_i(s_i2c_txr_d), .dat_o(s_i2c_txr_q) );
  dffr_DATA_WIDTH8_1 u_i2c_cmd_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .dat_i(s_i2c_cmd_d), .dat_o(s_i2c_cmd_q) );
  dffr_DATA_WIDTH1_0 u_i2c_al_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_i2c_al_d), .dat_o(s_i2c_sr[5]) );
  dffr_DATA_WIDTH1_4 u_i2c_rxack_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_i2c_rxack_d), .dat_o(s_i2c_sr[7]) );
  dffr_DATA_WIDTH1_3 u_i2c_tip_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .dat_i(s_i2c_tip_d), .dat_o(s_i2c_sr_1) );
  dffr_DATA_WIDTH1_2 u_i2c_irq_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .dat_i(s_i2c_irq_d), .dat_o(s_i2c_sr_0) );
  dffr_DATA_WIDTH1_1 u_irq_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_irq_d), .dat_o(i2c_irq_o) );
  i2c_master_byte_ctrl u_i2c_master_byte_ctrl ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .ena_i(s_i2c_ctrl_q[7]), .clk_cnt_i(s_i2c_pscr_q), 
        .start_i(s_i2c_cmd_q[7]), .stop_i(s_i2c_cmd_q[6]), .read_i(
        s_i2c_cmd_q[5]), .write_i(s_i2c_cmd_q[4]), .ack_i(s_i2c_cmd_q[3]), 
        .dat_i(s_i2c_txr_q), .cmd_ack_o(s_i2c_done), .ack_o(s_i2c_rxack_d), 
        .dat_o(s_i2c_rxr), .i2c_busy_o(s_i2c_sr[6]), .i2c_al_o(s_i2c_al), 
        .scl_i(i2c_scl_i), .scl_dir_o(i2c_scl_dir_o), .sda_i(i2c_sda_i), 
        .sda_dir_o(i2c_sda_dir_o) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(s_i2c_txr_q[0]), .Y(n88) );
  sky130_fd_sc_hd__inv_2 U142 ( .A(s_i2c_txr_q[1]), .Y(n87) );
  sky130_fd_sc_hd__inv_2 U143 ( .A(s_i2c_txr_q[5]), .Y(n83) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(s_i2c_txr_q[6]), .Y(n82) );
  sky130_fd_sc_hd__inv_2 U145 ( .A(s_i2c_txr_q[7]), .Y(n81) );
  sky130_fd_sc_hd__inv_2 U146 ( .A(s_i2c_ctrl_q[0]), .Y(n102) );
  sky130_fd_sc_hd__inv_2 U147 ( .A(s_i2c_ctrl_q[1]), .Y(n101) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(s_i2c_ctrl_q[5]), .Y(n97) );
  sky130_fd_sc_hd__inv_2 U149 ( .A(s_i2c_ctrl_q[6]), .Y(n96) );
  sky130_fd_sc_hd__inv_2 U150 ( .A(s_i2c_ctrl_q[7]), .Y(n95) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(s_i2c_pscr_q[0]), .Y(n107) );
  sky130_fd_sc_hd__inv_2 U152 ( .A(s_i2c_pscr_q[5]), .Y(n103) );
  sky130_fd_sc_hd__o22ai_1 U153 ( .A1(n113), .A2(n124), .B1(n46), .B2(n88), 
        .Y(s_i2c_txr_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U154 ( .A1(n113), .A2(n123), .B1(n46), .B2(n87), 
        .Y(s_i2c_txr_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U155 ( .A1(n113), .A2(n122), .B1(n46), .B2(n86), 
        .Y(s_i2c_txr_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U156 ( .A1(n113), .A2(n121), .B1(n46), .B2(n85), 
        .Y(s_i2c_txr_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U157 ( .A1(n113), .A2(n120), .B1(n46), .B2(n84), 
        .Y(s_i2c_txr_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U158 ( .A1(n113), .A2(n119), .B1(n46), .B2(n83), 
        .Y(s_i2c_txr_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U159 ( .A1(n113), .A2(n118), .B1(n46), .B2(n82), 
        .Y(s_i2c_txr_d[6]) );
  sky130_fd_sc_hd__o2bb2ai_1 U160 ( .B1(n121), .B2(n54), .A1_N(n54), .A2_N(
        s_i2c_cmd_q[3]), .Y(s_i2c_cmd_d[3]) );
  sky130_fd_sc_hd__inv_2 U161 ( .A(apb4_paddr[3]), .Y(n115) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(apb4_paddr[2]), .Y(n116) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(apb4_paddr[4]), .Y(n114) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(apb4_paddr[5]), .Y(n110) );
  sky130_fd_sc_hd__nor3_1 U165 ( .A(apb4_paddr[3]), .B(apb4_paddr[4]), .C(n116), .Y(n50) );
  sky130_fd_sc_hd__nor3_1 U166 ( .A(n116), .B(apb4_paddr[3]), .C(n114), .Y(n61) );
  sky130_fd_sc_hd__inv_2 U167 ( .A(n65), .Y(n109) );
  sky130_fd_sc_hd__nand3_1 U168 ( .A(n116), .B(n114), .C(apb4_paddr[3]), .Y(
        n48) );
  sky130_fd_sc_hd__nand3_1 U169 ( .A(n115), .B(n114), .C(n116), .Y(n52) );
  sky130_fd_sc_hd__nor3_1 U170 ( .A(n115), .B(apb4_paddr[4]), .C(n116), .Y(n60) );
  sky130_fd_sc_hd__nor3_1 U171 ( .A(apb4_paddr[2]), .B(apb4_paddr[3]), .C(n114), .Y(n56) );
  sky130_fd_sc_hd__inv_2 U172 ( .A(n57), .Y(n108) );
  sky130_fd_sc_hd__nand2_1 U173 ( .A(n109), .B(n50), .Y(n57) );
  sky130_fd_sc_hd__inv_2 U174 ( .A(s_i2c_done), .Y(n94) );
  sky130_fd_sc_hd__inv_2 U175 ( .A(s_i2c_sr_0), .Y(n80) );
  sky130_fd_sc_hd__inv_2 U176 ( .A(s_i2c_txr_q[2]), .Y(n86) );
  sky130_fd_sc_hd__inv_2 U177 ( .A(s_i2c_txr_q[3]), .Y(n85) );
  sky130_fd_sc_hd__inv_2 U178 ( .A(s_i2c_txr_q[4]), .Y(n84) );
  sky130_fd_sc_hd__nor2b_1 U179 ( .B_N(n47), .A(n48), .Y(n46) );
  sky130_fd_sc_hd__inv_2 U180 ( .A(n46), .Y(n113) );
  sky130_fd_sc_hd__inv_2 U181 ( .A(s_i2c_cmd_q[4]), .Y(n92) );
  sky130_fd_sc_hd__inv_2 U182 ( .A(s_i2c_cmd_q[5]), .Y(n91) );
  sky130_fd_sc_hd__nand4_1 U183 ( .A(n56), .B(s_i2c_ctrl_q[7]), .C(n53), .D(
        n110), .Y(n54) );
  sky130_fd_sc_hd__nand3_1 U184 ( .A(n93), .B(n94), .C(n54), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U185 ( .A(s_i2c_cmd_q[7]), .Y(n89) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(apb4_pwdata[1]), .Y(n123) );
  sky130_fd_sc_hd__inv_2 U187 ( .A(s_i2c_ctrl_q[2]), .Y(n100) );
  sky130_fd_sc_hd__inv_2 U188 ( .A(s_i2c_ctrl_q[3]), .Y(n99) );
  sky130_fd_sc_hd__inv_2 U189 ( .A(s_i2c_ctrl_q[4]), .Y(n98) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(apb4_pwdata[6]), .Y(n118) );
  sky130_fd_sc_hd__nor2b_1 U191 ( .B_N(n47), .A(n52), .Y(n51) );
  sky130_fd_sc_hd__inv_2 U192 ( .A(n51), .Y(n111) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(apb4_pwdata[7]), .Y(n117) );
  sky130_fd_sc_hd__inv_2 U194 ( .A(apb4_pwdata[0]), .Y(n124) );
  sky130_fd_sc_hd__inv_2 U195 ( .A(s_i2c_pscr_q[2]), .Y(n106) );
  sky130_fd_sc_hd__inv_2 U196 ( .A(apb4_pwdata[2]), .Y(n122) );
  sky130_fd_sc_hd__inv_2 U197 ( .A(s_i2c_pscr_q[3]), .Y(n105) );
  sky130_fd_sc_hd__inv_2 U198 ( .A(apb4_pwdata[3]), .Y(n121) );
  sky130_fd_sc_hd__inv_2 U199 ( .A(s_i2c_pscr_q[4]), .Y(n104) );
  sky130_fd_sc_hd__inv_2 U200 ( .A(apb4_pwdata[4]), .Y(n120) );
  sky130_fd_sc_hd__inv_2 U201 ( .A(apb4_pwdata[5]), .Y(n119) );
  sky130_fd_sc_hd__nand2_1 U202 ( .A(n50), .B(n47), .Y(n49) );
  sky130_fd_sc_hd__inv_2 U203 ( .A(n49), .Y(n112) );
  sky130_fd_sc_hd__o22ai_1 U204 ( .A1(n107), .A2(n57), .B1(n76), .B2(n65), .Y(
        apb4_prdata[0]) );
  sky130_fd_sc_hd__a211oi_1 U205 ( .A1(s_i2c_rxr[0]), .A2(n60), .B1(n77), .C1(
        n78), .Y(n76) );
  sky130_fd_sc_hd__o22ai_1 U206 ( .A1(n52), .A2(n102), .B1(n48), .B2(n88), .Y(
        n77) );
  sky130_fd_sc_hd__o221ai_1 U207 ( .A1(n48), .A2(n87), .B1(n52), .B2(n101), 
        .C1(n75), .Y(n74) );
  sky130_fd_sc_hd__o22ai_1 U208 ( .A1(n106), .A2(n57), .B1(n72), .B2(n65), .Y(
        apb4_prdata[2]) );
  sky130_fd_sc_hd__a221oi_1 U209 ( .A1(s_i2c_cmd_q[2]), .A2(n56), .B1(
        s_i2c_rxr[2]), .B2(n60), .C1(n73), .Y(n72) );
  sky130_fd_sc_hd__o22ai_1 U210 ( .A1(n52), .A2(n100), .B1(n48), .B2(n86), .Y(
        n73) );
  sky130_fd_sc_hd__o22ai_1 U211 ( .A1(n105), .A2(n57), .B1(n70), .B2(n65), .Y(
        apb4_prdata[3]) );
  sky130_fd_sc_hd__a221oi_1 U212 ( .A1(s_i2c_cmd_q[3]), .A2(n56), .B1(
        s_i2c_rxr[3]), .B2(n60), .C1(n71), .Y(n70) );
  sky130_fd_sc_hd__o22ai_1 U213 ( .A1(n52), .A2(n99), .B1(n48), .B2(n85), .Y(
        n71) );
  sky130_fd_sc_hd__o22ai_1 U214 ( .A1(n104), .A2(n57), .B1(n68), .B2(n65), .Y(
        apb4_prdata[4]) );
  sky130_fd_sc_hd__a221oi_1 U215 ( .A1(s_i2c_cmd_q[4]), .A2(n56), .B1(
        s_i2c_rxr[4]), .B2(n60), .C1(n69), .Y(n68) );
  sky130_fd_sc_hd__o22ai_1 U216 ( .A1(n52), .A2(n98), .B1(n48), .B2(n84), .Y(
        n69) );
  sky130_fd_sc_hd__o22ai_1 U217 ( .A1(n103), .A2(n57), .B1(n64), .B2(n65), .Y(
        apb4_prdata[5]) );
  sky130_fd_sc_hd__a211oi_1 U218 ( .A1(s_i2c_rxr[5]), .A2(n60), .B1(n66), .C1(
        n67), .Y(n64) );
  sky130_fd_sc_hd__o22ai_1 U219 ( .A1(n52), .A2(n97), .B1(n48), .B2(n83), .Y(
        n66) );
  sky130_fd_sc_hd__o221ai_1 U220 ( .A1(n48), .A2(n82), .B1(n96), .B2(n52), 
        .C1(n63), .Y(n62) );
  sky130_fd_sc_hd__o221ai_1 U221 ( .A1(n48), .A2(n81), .B1(n52), .B2(n95), 
        .C1(n59), .Y(n58) );
  sky130_fd_sc_hd__nor2_1 U222 ( .A(n96), .B(n80), .Y(s_irq_d) );
  sky130_fd_sc_hd__o22ai_1 U223 ( .A1(n113), .A2(n117), .B1(n46), .B2(n81), 
        .Y(s_i2c_txr_d[7]) );
  sky130_fd_sc_hd__nor2_1 U224 ( .A(n124), .B(n54), .Y(s_i2c_cmd_d[0]) );
  sky130_fd_sc_hd__nor2_1 U225 ( .A(n123), .B(n54), .Y(s_i2c_cmd_d[1]) );
  sky130_fd_sc_hd__nor2_1 U226 ( .A(n122), .B(n54), .Y(s_i2c_cmd_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U227 ( .A1(n120), .A2(n54), .B1(n55), .B2(n92), .Y(
        s_i2c_cmd_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U228 ( .A1(n119), .A2(n54), .B1(n55), .B2(n91), .Y(
        s_i2c_cmd_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U229 ( .A1(n118), .A2(n54), .B1(n55), .B2(n90), .Y(
        s_i2c_cmd_d[6]) );
  sky130_fd_sc_hd__inv_2 U230 ( .A(s_i2c_cmd_q[6]), .Y(n90) );
  sky130_fd_sc_hd__o22ai_1 U231 ( .A1(n117), .A2(n54), .B1(n55), .B2(n89), .Y(
        s_i2c_cmd_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U232 ( .A1(n124), .A2(n111), .B1(n51), .B2(n102), 
        .Y(s_i2c_ctrl_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U233 ( .A1(n123), .A2(n111), .B1(n51), .B2(n101), 
        .Y(s_i2c_ctrl_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U234 ( .A1(n122), .A2(n111), .B1(n51), .B2(n100), 
        .Y(s_i2c_ctrl_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U235 ( .A1(n121), .A2(n111), .B1(n51), .B2(n99), 
        .Y(s_i2c_ctrl_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U236 ( .A1(n120), .A2(n111), .B1(n51), .B2(n98), 
        .Y(s_i2c_ctrl_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U237 ( .A1(n119), .A2(n111), .B1(n51), .B2(n97), 
        .Y(s_i2c_ctrl_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U238 ( .A1(n118), .A2(n111), .B1(n51), .B2(n96), 
        .Y(s_i2c_ctrl_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U239 ( .A1(n117), .A2(n111), .B1(n51), .B2(n95), 
        .Y(s_i2c_ctrl_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U240 ( .A1(n124), .A2(n49), .B1(n112), .B2(n107), 
        .Y(s_i2c_pscr_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U241 ( .A1(n122), .A2(n49), .B1(n112), .B2(n106), 
        .Y(s_i2c_pscr_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U242 ( .A1(n121), .A2(n49), .B1(n112), .B2(n105), 
        .Y(s_i2c_pscr_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U243 ( .A1(n120), .A2(n49), .B1(n112), .B2(n104), 
        .Y(s_i2c_pscr_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U244 ( .A1(n119), .A2(n49), .B1(n112), .B2(n103), 
        .Y(s_i2c_pscr_d[5]) );
  sky130_fd_sc_hd__conb_1 U245 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__inv_1 U246 ( .A(s_i2c_al), .Y(n93) );
endmodule

