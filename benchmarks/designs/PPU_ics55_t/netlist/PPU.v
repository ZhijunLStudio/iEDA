/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 29 19:38:25 2025
/////////////////////////////////////////////////////////////


module ClockGen_DW01_inc_0_DW01_inc_4 ( A, SUM );
  input [8:0] A;
  output [8:0] SUM;

  wire   [8:2] carry;

  sky130_fd_sc_hd__ha_1 U1_1_1 ( .A(A[1]), .B(A[0]), .COUT(carry[2]), .SUM(
        SUM[1]) );
  sky130_fd_sc_hd__ha_1 U1_1_5 ( .A(A[5]), .B(carry[5]), .COUT(carry[6]), 
        .SUM(SUM[5]) );
  sky130_fd_sc_hd__ha_1 U1_1_3 ( .A(A[3]), .B(carry[3]), .COUT(carry[4]), 
        .SUM(SUM[3]) );
  sky130_fd_sc_hd__ha_1 U1_1_2 ( .A(A[2]), .B(carry[2]), .COUT(carry[3]), 
        .SUM(SUM[2]) );
  sky130_fd_sc_hd__ha_1 U1_1_4 ( .A(A[4]), .B(carry[4]), .COUT(carry[5]), 
        .SUM(SUM[4]) );
  sky130_fd_sc_hd__ha_1 U1_1_7 ( .A(A[7]), .B(carry[7]), .COUT(carry[8]), 
        .SUM(SUM[7]) );
  sky130_fd_sc_hd__ha_1 U1_1_6 ( .A(A[6]), .B(carry[6]), .COUT(carry[7]), 
        .SUM(SUM[6]) );
  sky130_fd_sc_hd__inv_1 U1 ( .A(A[0]), .Y(SUM[0]) );
  sky130_fd_sc_hd__xor2_1 U2 ( .A(carry[8]), .B(A[8]), .X(SUM[8]) );
endmodule


module ClockGen_DW01_inc_1_DW01_inc_5 ( A, SUM );
  input [8:0] A;
  output [8:0] SUM;

  wire   [8:2] carry;

  sky130_fd_sc_hd__ha_1 U1_1_1 ( .A(A[1]), .B(A[0]), .COUT(carry[2]), .SUM(
        SUM[1]) );
  sky130_fd_sc_hd__ha_1 U1_1_2 ( .A(A[2]), .B(carry[2]), .COUT(carry[3]), 
        .SUM(SUM[2]) );
  sky130_fd_sc_hd__ha_1 U1_1_3 ( .A(A[3]), .B(carry[3]), .COUT(carry[4]), 
        .SUM(SUM[3]) );
  sky130_fd_sc_hd__ha_1 U1_1_4 ( .A(A[4]), .B(carry[4]), .COUT(carry[5]), 
        .SUM(SUM[4]) );
  sky130_fd_sc_hd__ha_1 U1_1_5 ( .A(A[5]), .B(carry[5]), .COUT(carry[6]), 
        .SUM(SUM[5]) );
  sky130_fd_sc_hd__ha_1 U1_1_6 ( .A(A[6]), .B(carry[6]), .COUT(carry[7]), 
        .SUM(SUM[6]) );
  sky130_fd_sc_hd__ha_1 U1_1_7 ( .A(A[7]), .B(carry[7]), .COUT(carry[8]), 
        .SUM(SUM[7]) );
  sky130_fd_sc_hd__inv_2 U1 ( .A(A[0]), .Y(SUM[0]) );
  sky130_fd_sc_hd__xor2_1 U2 ( .A(carry[8]), .B(A[8]), .X(SUM[8]) );
endmodule


module ClockGen ( clk, ce, reset, is_rendering, scanline, cycle, is_in_vblank, 
        end_of_line, at_last_cycle_group, exiting_vblank, entering_vblank, 
        is_pre_render );
  output [8:0] scanline;
  output [8:0] cycle;
  input clk, ce, reset, is_rendering;
  output is_in_vblank, end_of_line, at_last_cycle_group, exiting_vblank,
         entering_vblank, is_pre_render;
  wire   second_frame, N19, N20, N21, N22, N23, N24, N25, N26, N27, N55, N56,
         N57, N58, N59, N60, N61, N62, N63, n31, n32, n33, n34, n35, n36, n37,
         n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51,
         n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65,
         n66, n67, n68;

  sky130_fd_sc_hd__dfxtp_2 cycle_reg_0_ ( .D(n39), .CLK(clk), .Q(cycle[0]) );
  sky130_fd_sc_hd__dfxtp_2 cycle_reg_1_ ( .D(n38), .CLK(clk), .Q(cycle[1]) );
  sky130_fd_sc_hd__dfxtp_2 cycle_reg_5_ ( .D(n34), .CLK(clk), .Q(cycle[5]) );
  sky130_fd_sc_hd__dfxtp_2 cycle_reg_6_ ( .D(n33), .CLK(clk), .Q(cycle[6]) );
  sky130_fd_sc_hd__dfxtp_2 cycle_reg_7_ ( .D(n32), .CLK(clk), .Q(cycle[7]) );
  sky130_fd_sc_hd__dfxtp_2 cycle_reg_8_ ( .D(n31), .CLK(clk), .Q(cycle[8]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_1_ ( .D(n50), .CLK(clk), .Q(
        scanline[1]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_0_ ( .D(n49), .CLK(clk), .Q(
        scanline[0]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_2_ ( .D(n48), .CLK(clk), .Q(
        scanline[2]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_3_ ( .D(n47), .CLK(clk), .Q(
        scanline[3]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_4_ ( .D(n46), .CLK(clk), .Q(
        scanline[4]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_5_ ( .D(n45), .CLK(clk), .Q(
        scanline[5]) );
  sky130_fd_sc_hd__dfxtp_2 scanline_reg_8_ ( .D(n42), .CLK(clk), .Q(
        scanline[8]) );
  ClockGen_DW01_inc_0_DW01_inc_4 add_142 ( .A(scanline), .SUM({N63, N62, N61, 
        N60, N59, N58, N57, N56, N55}) );
  ClockGen_DW01_inc_1_DW01_inc_5 add_129 ( .A(cycle), .SUM({N27, N26, N25, N24, 
        N23, N22, N21, N20, N19}) );
  sky130_fd_sc_hd__dfxtp_4 scanline_reg_7_ ( .D(n43), .CLK(clk), .Q(
        scanline[7]) );
  sky130_fd_sc_hd__dfxtp_4 scanline_reg_6_ ( .D(n44), .CLK(clk), .Q(
        scanline[6]) );
  sky130_fd_sc_hd__dfxtp_1 is_pre_render_reg ( .D(n51), .CLK(clk), .Q(
        is_pre_render) );
  sky130_fd_sc_hd__dfxtp_1 cycle_reg_2_ ( .D(n37), .CLK(clk), .Q(cycle[2]) );
  sky130_fd_sc_hd__dfxtp_1 cycle_reg_3_ ( .D(n36), .CLK(clk), .Q(cycle[3]) );
  sky130_fd_sc_hd__dfxtp_1 cycle_reg_4_ ( .D(n35), .CLK(clk), .Q(cycle[4]) );
  sky130_fd_sc_hd__dfxtp_1 second_frame_reg ( .D(n40), .CLK(clk), .Q(
        second_frame) );
  sky130_fd_sc_hd__dfxtp_1 is_in_vblank_reg ( .D(n41), .CLK(clk), .Q(
        is_in_vblank) );
  sky130_fd_sc_hd__nand3_1 U3 ( .A(is_pre_render), .B(second_frame), .C(
        is_rendering), .Y(n5) );
  sky130_fd_sc_hd__clkinv_1 U4 ( .A(n18), .Y(end_of_line) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n19), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(n30), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n52), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(ce), .Y(n3) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n66), .B(n3), .Y(n63) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n68), .Y(entering_vblank) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(n63), .Y(n65) );
  sky130_fd_sc_hd__and4_1 U12 ( .A(cycle[4]), .B(cycle[6]), .C(cycle[8]), .D(
        n4), .X(at_last_cycle_group) );
  sky130_fd_sc_hd__and3_1 U13 ( .A(ce), .B(n18), .C(n66), .X(n2) );
  sky130_fd_sc_hd__inv_1 U14 ( .A(cycle[8]), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(reset), .Y(n66) );
  sky130_fd_sc_hd__nor3_1 U16 ( .A(cycle[3]), .B(cycle[5]), .C(cycle[7]), .Y(
        n4) );
  sky130_fd_sc_hd__xnor2_1 U17 ( .A(cycle[2]), .B(n5), .Y(n8) );
  sky130_fd_sc_hd__xor2_1 U18 ( .A(n5), .B(cycle[1]), .X(n7) );
  sky130_fd_sc_hd__xor2_1 U19 ( .A(n5), .B(cycle[0]), .X(n6) );
  sky130_fd_sc_hd__nand4_1 U20 ( .A(at_last_cycle_group), .B(n8), .C(n7), .D(
        n6), .Y(n18) );
  sky130_fd_sc_hd__o2bb2ai_1 U21 ( .B1(n9), .B2(n63), .A1_N(N27), .A2_N(n2), 
        .Y(n31) );
  sky130_fd_sc_hd__inv_1 U22 ( .A(cycle[7]), .Y(n10) );
  sky130_fd_sc_hd__o2bb2ai_1 U23 ( .B1(n63), .B2(n10), .A1_N(N26), .A2_N(n2), 
        .Y(n32) );
  sky130_fd_sc_hd__inv_1 U24 ( .A(cycle[6]), .Y(n11) );
  sky130_fd_sc_hd__o2bb2ai_1 U25 ( .B1(n11), .B2(n63), .A1_N(N25), .A2_N(n2), 
        .Y(n33) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(cycle[5]), .Y(n12) );
  sky130_fd_sc_hd__o2bb2ai_1 U27 ( .B1(n63), .B2(n12), .A1_N(N24), .A2_N(n2), 
        .Y(n34) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(cycle[3]), .Y(n13) );
  sky130_fd_sc_hd__o2bb2ai_1 U29 ( .B1(n63), .B2(n13), .A1_N(N22), .A2_N(n2), 
        .Y(n36) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(cycle[2]), .Y(n14) );
  sky130_fd_sc_hd__o2bb2ai_1 U31 ( .B1(n63), .B2(n14), .A1_N(N21), .A2_N(n2), 
        .Y(n37) );
  sky130_fd_sc_hd__inv_1 U32 ( .A(cycle[1]), .Y(n15) );
  sky130_fd_sc_hd__o2bb2ai_1 U33 ( .B1(n63), .B2(n15), .A1_N(N20), .A2_N(n2), 
        .Y(n38) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(cycle[0]), .Y(n16) );
  sky130_fd_sc_hd__o2bb2ai_1 U35 ( .B1(n63), .B2(n16), .A1_N(N19), .A2_N(n2), 
        .Y(n39) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(cycle[4]), .Y(n17) );
  sky130_fd_sc_hd__o2bb2ai_1 U37 ( .B1(n17), .B2(n63), .A1_N(N23), .A2_N(n2), 
        .Y(n35) );
  sky130_fd_sc_hd__nand3_1 U38 ( .A(ce), .B(end_of_line), .C(n66), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U39 ( .A(n19), .B(n66), .Y(n52) );
  sky130_fd_sc_hd__inv_1 U40 ( .A(scanline[1]), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U41 ( .A(scanline[3]), .Y(n57) );
  sky130_fd_sc_hd__inv_1 U42 ( .A(scanline[0]), .Y(n20) );
  sky130_fd_sc_hd__nand4_1 U43 ( .A(scanline[2]), .B(n21), .C(n57), .D(n20), 
        .Y(n24) );
  sky130_fd_sc_hd__inv_1 U44 ( .A(scanline[4]), .Y(n54) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(scanline[7]), .Y(n22) );
  sky130_fd_sc_hd__nand3_1 U46 ( .A(scanline[8]), .B(n54), .C(n22), .Y(n23) );
  sky130_fd_sc_hd__nor4_1 U47 ( .A(n24), .B(n23), .C(scanline[5]), .D(
        scanline[6]), .Y(n25) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(n25), .B(end_of_line), .Y(n64) );
  sky130_fd_sc_hd__clkinv_2 U49 ( .A(n64), .Y(exiting_vblank) );
  sky130_fd_sc_hd__nand2_1 U50 ( .A(n27), .B(exiting_vblank), .Y(n30) );
  sky130_fd_sc_hd__a221o_1 U51 ( .A1(n28), .A2(scanline[8]), .B1(N63), .B2(n27), .C1(n26), .X(n42) );
  sky130_fd_sc_hd__a221o_1 U52 ( .A1(n28), .A2(scanline[7]), .B1(N62), .B2(n27), .C1(n26), .X(n43) );
  sky130_fd_sc_hd__a221o_1 U53 ( .A1(n28), .A2(scanline[6]), .B1(N61), .B2(n27), .C1(n26), .X(n44) );
  sky130_fd_sc_hd__a221o_1 U54 ( .A1(n28), .A2(scanline[5]), .B1(N60), .B2(n27), .C1(n26), .X(n45) );
  sky130_fd_sc_hd__a221o_1 U55 ( .A1(n28), .A2(scanline[4]), .B1(N59), .B2(n27), .C1(n26), .X(n46) );
  sky130_fd_sc_hd__a221o_1 U56 ( .A1(scanline[3]), .A2(n28), .B1(N58), .B2(n27), .C1(n26), .X(n47) );
  sky130_fd_sc_hd__a221o_1 U57 ( .A1(scanline[1]), .A2(n28), .B1(N56), .B2(n27), .C1(n26), .X(n50) );
  sky130_fd_sc_hd__a221o_1 U58 ( .A1(scanline[0]), .A2(n28), .B1(N55), .B2(n27), .C1(n26), .X(n49) );
  sky130_fd_sc_hd__a221o_1 U59 ( .A1(n28), .A2(scanline[2]), .B1(N57), .B2(n27), .C1(n26), .X(n48) );
  sky130_fd_sc_hd__a21oi_1 U60 ( .A1(n64), .A2(n66), .B1(n28), .Y(n29) );
  sky130_fd_sc_hd__mux2i_1 U61 ( .A0(n30), .A1(n29), .S(second_frame), .Y(n40)
         );
  sky130_fd_sc_hd__inv_1 U62 ( .A(is_pre_render), .Y(n53) );
  sky130_fd_sc_hd__o21ai_1 U63 ( .A1(n53), .A2(n52), .B1(n30), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U64 ( .A(scanline[8]), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U65 ( .A(scanline[6]), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U66 ( .A(scanline[5]), .Y(n55) );
  sky130_fd_sc_hd__nor3_1 U67 ( .A(n56), .B(n55), .C(n54), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U68 ( .A(scanline[2]), .Y(n58) );
  sky130_fd_sc_hd__nand3_1 U69 ( .A(end_of_line), .B(n58), .C(n57), .Y(n59) );
  sky130_fd_sc_hd__nor3_1 U70 ( .A(n59), .B(scanline[0]), .C(scanline[1]), .Y(
        n60) );
  sky130_fd_sc_hd__nand4_1 U71 ( .A(scanline[7]), .B(n62), .C(n61), .D(n60), 
        .Y(n68) );
  sky130_fd_sc_hd__o21ai_1 U72 ( .A1(n65), .A2(n64), .B1(is_in_vblank), .Y(n67) );
  sky130_fd_sc_hd__o211ai_1 U73 ( .A1(n68), .A2(n3), .B1(n67), .C1(n66), .Y(
        n41) );
endmodule


module LoopyGen ( clk, ce, is_rendering, ain, din, read, write, is_pre_render, 
        cycle, loopy, fine_x_scroll );
  input [2:0] ain;
  input [7:0] din;
  input [8:0] cycle;
  output [14:0] loopy;
  output [2:0] fine_x_scroll;
  input clk, ce, is_rendering, read, write, is_pre_render;
  wire   ppu_incr, ppu_address_latch, n158, n159, n160, n161, n162, n163, n164,
         n165, n166, n167, n168, n169, n170, n171, n172, n173, n174, n175,
         n176, n177, n178, n179, n180, n181, n182, n183, n184, n185, n186,
         n187, n188, n189, n190, n191, n192, n1, n2, n3, n4, n5, n6, n7, n8,
         n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22,
         n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50,
         n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
         n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136, n137, n138,
         n139, n140, n141, n142, n143, n144, n145, n146, n147, n148, n149,
         n150, n151, n152, n153, n154, n155, n156, n157, n193, n194, n195,
         n196, n197, n198, n199, n200, n201, n202, n203, n204, n205, n206,
         n207, n208, n209, n210, n211, n212, n213, n214, n215, n216, n217,
         n218, n219, n220, n221, n222, n223, n224, n225, n226, n227, n228,
         n229, n230, n231, n232, n233, n234, n235, n236, n237, n238, n239,
         n240, n241, n242, n243, n244, n245, n246, n247, n248, n249, n250,
         n251, n252, n253, n254, n255, n256, n257, n258, n259, n260, n261,
         n262, n263, n264, n265, n266, n267, n268, n269, n270, n271, n272,
         n273, n274;
  wire   [14:0] loopy_t;

  sky130_fd_sc_hd__dfxtp_2 loopy_v_reg_0_ ( .D(n171), .CLK(clk), .Q(loopy[0])
         );
  sky130_fd_sc_hd__dfxtp_2 loopy_v_reg_1_ ( .D(n166), .CLK(clk), .Q(loopy[1])
         );
  sky130_fd_sc_hd__dfxtp_4 loopy_x_reg_0_ ( .D(n191), .CLK(clk), .Q(
        fine_x_scroll[0]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_7_ ( .D(n162), .CLK(clk), .Q(loopy[7])
         );
  sky130_fd_sc_hd__dfxtp_4 loopy_x_reg_1_ ( .D(n189), .CLK(clk), .Q(
        fine_x_scroll[1]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_10_ ( .D(n184), .CLK(clk), .Q(
        loopy_t[10]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_8_ ( .D(n182), .CLK(clk), .Q(loopy_t[8]) );
  sky130_fd_sc_hd__dfxtp_1 ppu_address_latch_reg ( .D(n192), .CLK(clk), .Q(
        ppu_address_latch) );
  sky130_fd_sc_hd__dfxtp_1 loopy_x_reg_2_ ( .D(n190), .CLK(clk), .Q(
        fine_x_scroll[2]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_14_ ( .D(n188), .CLK(clk), .Q(
        loopy_t[14]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_13_ ( .D(n187), .CLK(clk), .Q(
        loopy_t[13]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_12_ ( .D(n186), .CLK(clk), .Q(
        loopy_t[12]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_11_ ( .D(n185), .CLK(clk), .Q(
        loopy_t[11]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_9_ ( .D(n183), .CLK(clk), .Q(loopy_t[9]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_7_ ( .D(n181), .CLK(clk), .Q(loopy_t[7]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_6_ ( .D(n180), .CLK(clk), .Q(loopy_t[6]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_5_ ( .D(n179), .CLK(clk), .Q(loopy_t[5]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_4_ ( .D(n178), .CLK(clk), .Q(loopy_t[4]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_3_ ( .D(n177), .CLK(clk), .Q(loopy_t[3]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_2_ ( .D(n176), .CLK(clk), .Q(loopy_t[2]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_1_ ( .D(n175), .CLK(clk), .Q(loopy_t[1]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_t_reg_0_ ( .D(n174), .CLK(clk), .Q(loopy_t[0]) );
  sky130_fd_sc_hd__dfxtp_1 ppu_incr_reg ( .D(n173), .CLK(clk), .Q(ppu_incr) );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_4_ ( .D(n169), .CLK(clk), .Q(loopy[4])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_2_ ( .D(n167), .CLK(clk), .Q(loopy[2])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_3_ ( .D(n168), .CLK(clk), .Q(loopy[3])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_10_ ( .D(n170), .CLK(clk), .Q(loopy[10]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_5_ ( .D(n165), .CLK(clk), .Q(loopy[5])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_11_ ( .D(n160), .CLK(clk), .Q(loopy[11]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_9_ ( .D(n164), .CLK(clk), .Q(loopy[9])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_6_ ( .D(n161), .CLK(clk), .Q(loopy[6])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_8_ ( .D(n163), .CLK(clk), .Q(loopy[8])
         );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_13_ ( .D(n158), .CLK(clk), .Q(loopy[13]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_12_ ( .D(n159), .CLK(clk), .Q(loopy[12]) );
  sky130_fd_sc_hd__dfxtp_1 loopy_v_reg_14_ ( .D(n172), .CLK(clk), .Q(loopy[14]) );
  sky130_fd_sc_hd__inv_4 U3 ( .A(n148), .Y(n203) );
  sky130_fd_sc_hd__nand4_4 U4 ( .A(ain[1]), .B(ain[2]), .C(ain[0]), .D(n24), 
        .Y(n148) );
  sky130_fd_sc_hd__a21oi_2 U5 ( .A1(n212), .A2(n213), .B1(is_rendering), .Y(
        n24) );
  sky130_fd_sc_hd__nand3_1 U6 ( .A(n7), .B(n25), .C(n204), .Y(n116) );
  sky130_fd_sc_hd__nand4_1 U7 ( .A(n68), .B(n274), .C(n273), .D(n69), .Y(n135)
         );
  sky130_fd_sc_hd__inv_2 U8 ( .A(n70), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U9 ( .A(n141), .Y(n142) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n97), .Y(n99) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(n94), .Y(n72) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(n95), .Y(n78) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(n103), .Y(n104) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(n61), .Y(n114) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(n62), .Y(n73) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(n258), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(n146), .Y(n139) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(n150), .Y(n151) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(n135), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(n109), .Y(n138) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(n207), .Y(n87) );
  sky130_fd_sc_hd__nor2_1 U22 ( .A(n80), .B(n76), .Y(n77) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(loopy[9]), .Y(n76) );
  sky130_fd_sc_hd__inv_1 U24 ( .A(n96), .Y(n108) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(n43), .Y(n48) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(n42), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(n52), .Y(n57) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(n221), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(n157), .Y(n193) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(n126), .Y(n130) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(n127), .Y(n129) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(n137), .Y(n124) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(n128), .Y(n208) );
  sky130_fd_sc_hd__nand2_1 U34 ( .A(n81), .B(n80), .Y(n211) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(n98), .Y(n81) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(n199), .Y(n201) );
  sky130_fd_sc_hd__inv_2 U37 ( .A(n75), .Y(n205) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(n115), .Y(n117) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(n116), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(n31), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(n29), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U42 ( .A(n111), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U43 ( .A(din[3]), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U44 ( .A(din[4]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U45 ( .A(din[6]), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U46 ( .A(din[5]), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(din[7]), .Y(n17) );
  sky130_fd_sc_hd__inv_2 U48 ( .A(din[0]), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U49 ( .A(din[1]), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U50 ( .A(din[2]), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n85), .Y(n86) );
  sky130_fd_sc_hd__inv_1 U52 ( .A(n147), .Y(n140) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n155), .Y(n152) );
  sky130_fd_sc_hd__nand3_1 U54 ( .A(n137), .B(n128), .C(loopy_t[9]), .Y(n106)
         );
  sky130_fd_sc_hd__o211a_1 U55 ( .A1(n148), .A2(n95), .B1(n128), .C1(n211), 
        .X(n1) );
  sky130_fd_sc_hd__and2_1 U56 ( .A(n102), .B(loopy[8]), .X(n2) );
  sky130_fd_sc_hd__o21a_2 U57 ( .A1(n259), .A2(n70), .B1(n126), .X(n3) );
  sky130_fd_sc_hd__and2_1 U58 ( .A(n98), .B(n148), .X(n4) );
  sky130_fd_sc_hd__o21a_1 U59 ( .A1(n114), .A2(n116), .B1(n8), .X(n5) );
  sky130_fd_sc_hd__and2_1 U60 ( .A(n149), .B(n148), .X(n6) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(cycle[5]), .Y(n266) );
  sky130_fd_sc_hd__inv_2 U62 ( .A(ce), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(n79), .Y(n89) );
  sky130_fd_sc_hd__nand3_2 U64 ( .A(n122), .B(n128), .C(n127), .Y(n98) );
  sky130_fd_sc_hd__inv_1 U65 ( .A(n149), .Y(n122) );
  sky130_fd_sc_hd__o21ai_4 U66 ( .A1(n87), .A2(n203), .B1(ce), .Y(n126) );
  sky130_fd_sc_hd__o21ai_2 U67 ( .A1(n259), .A2(n70), .B1(n126), .Y(n7) );
  sky130_fd_sc_hd__o21ai_0 U68 ( .A1(n259), .A2(n70), .B1(n126), .Y(n8) );
  sky130_fd_sc_hd__a41o_4 U69 ( .A1(n9), .A2(loopy[14]), .A3(loopy[12]), .A4(
        loopy[13]), .B1(n71), .X(n128) );
  sky130_fd_sc_hd__inv_2 U70 ( .A(n71), .Y(n136) );
  sky130_fd_sc_hd__o21ai_2 U71 ( .A1(n75), .A2(n70), .B1(n126), .Y(n71) );
  sky130_fd_sc_hd__inv_1 U72 ( .A(read), .Y(n212) );
  sky130_fd_sc_hd__inv_1 U73 ( .A(ppu_address_latch), .Y(n214) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(n257), .Y(n215) );
  sky130_fd_sc_hd__nand3_1 U75 ( .A(ce), .B(n214), .C(n215), .Y(n221) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(ppu_address_latch), .B(n231), .Y(n207) );
  sky130_fd_sc_hd__nand2_1 U77 ( .A(ce), .B(n87), .Y(n247) );
  sky130_fd_sc_hd__nand4_1 U78 ( .A(cycle[8]), .B(is_pre_render), .C(n269), 
        .D(n268), .Y(n75) );
  sky130_fd_sc_hd__o41ai_1 U79 ( .A1(cycle[4]), .A2(cycle[3]), .A3(n263), .A4(
        n264), .B1(n75), .Y(n258) );
  sky130_fd_sc_hd__inv_1 U80 ( .A(write), .Y(n213) );
  sky130_fd_sc_hd__inv_1 U81 ( .A(fine_x_scroll[0]), .Y(n19) );
  sky130_fd_sc_hd__mux2i_1 U82 ( .A0(n19), .A1(n10), .S(n20), .Y(n191) );
  sky130_fd_sc_hd__inv_1 U83 ( .A(fine_x_scroll[1]), .Y(n21) );
  sky130_fd_sc_hd__mux2i_1 U84 ( .A0(n21), .A1(n11), .S(n20), .Y(n189) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(ppu_incr), .Y(n74) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(n230), .Y(n22) );
  sky130_fd_sc_hd__nor2_1 U87 ( .A(n18), .B(n22), .Y(n23) );
  sky130_fd_sc_hd__mux2i_1 U88 ( .A0(n74), .A1(n12), .S(n23), .Y(n173) );
  sky130_fd_sc_hd__nand2_1 U89 ( .A(is_rendering), .B(ce), .Y(n70) );
  sky130_fd_sc_hd__o211ai_1 U90 ( .A1(n218), .A2(n203), .B1(n233), .C1(n257), 
        .Y(n204) );
  sky130_fd_sc_hd__nand2_1 U91 ( .A(n258), .B(n204), .Y(n111) );
  sky130_fd_sc_hd__a22oi_1 U92 ( .A1(loopy_t[0]), .A2(n28), .B1(n87), .B2(
        din[0]), .Y(n27) );
  sky130_fd_sc_hd__o31ai_1 U93 ( .A1(ppu_incr), .A2(n3), .A3(n148), .B1(n116), 
        .Y(n29) );
  sky130_fd_sc_hd__o21ai_1 U94 ( .A1(n148), .A2(n74), .B1(n7), .Y(n31) );
  sky130_fd_sc_hd__mux2i_1 U95 ( .A0(n29), .A1(n31), .S(loopy[0]), .Y(n26) );
  sky130_fd_sc_hd__o21ai_1 U96 ( .A1(n3), .A2(n27), .B1(n26), .Y(n171) );
  sky130_fd_sc_hd__a22oi_1 U97 ( .A1(loopy_t[1]), .A2(n28), .B1(din[1]), .B2(
        n87), .Y(n39) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(loopy[0]), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U99 ( .A(n30), .B(n32), .Y(n37) );
  sky130_fd_sc_hd__o21ai_1 U100 ( .A1(n203), .A2(n33), .B1(n32), .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U101 ( .A(n35), .B(n34), .Y(n36) );
  sky130_fd_sc_hd__mux2i_1 U102 ( .A0(n37), .A1(n36), .S(loopy[1]), .Y(n38) );
  sky130_fd_sc_hd__o21ai_1 U103 ( .A1(n3), .A2(n39), .B1(n38), .Y(n166) );
  sky130_fd_sc_hd__nand2_1 U104 ( .A(loopy[1]), .B(loopy[0]), .Y(n42) );
  sky130_fd_sc_hd__nand2_1 U105 ( .A(n51), .B(n74), .Y(n43) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(loopy_t[2]), .Y(n40) );
  sky130_fd_sc_hd__o32ai_1 U107 ( .A1(loopy[2]), .A2(n43), .A3(n148), .B1(n111), .B2(n40), .Y(n41) );
  sky130_fd_sc_hd__a21oi_1 U108 ( .A1(n87), .A2(din[2]), .B1(n41), .Y(n47) );
  sky130_fd_sc_hd__nor2_1 U109 ( .A(n42), .B(n116), .Y(n45) );
  sky130_fd_sc_hd__o221ai_1 U110 ( .A1(n51), .A2(n116), .B1(n48), .B2(n148), 
        .C1(n8), .Y(n44) );
  sky130_fd_sc_hd__mux2i_1 U111 ( .A0(n45), .A1(n44), .S(loopy[2]), .Y(n46) );
  sky130_fd_sc_hd__o21ai_1 U112 ( .A1(n3), .A2(n47), .B1(n46), .Y(n167) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(loopy[2]), .B(n48), .Y(n52) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(loopy_t[3]), .Y(n49) );
  sky130_fd_sc_hd__o32ai_1 U115 ( .A1(loopy[3]), .A2(n52), .A3(n148), .B1(n111), .B2(n49), .Y(n50) );
  sky130_fd_sc_hd__a21oi_1 U116 ( .A1(din[3]), .A2(n87), .B1(n50), .Y(n56) );
  sky130_fd_sc_hd__nand2_1 U117 ( .A(loopy[2]), .B(n51), .Y(n61) );
  sky130_fd_sc_hd__nor2_1 U118 ( .A(n61), .B(n116), .Y(n54) );
  sky130_fd_sc_hd__o21ai_1 U119 ( .A1(n57), .A2(n148), .B1(n5), .Y(n53) );
  sky130_fd_sc_hd__mux2i_1 U120 ( .A0(n54), .A1(n53), .S(loopy[3]), .Y(n55) );
  sky130_fd_sc_hd__o21ai_1 U121 ( .A1(n3), .A2(n56), .B1(n55), .Y(n168) );
  sky130_fd_sc_hd__nand2_1 U122 ( .A(loopy[3]), .B(n57), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U123 ( .A(loopy_t[4]), .Y(n58) );
  sky130_fd_sc_hd__o32ai_1 U124 ( .A1(loopy[4]), .A2(n62), .A3(n148), .B1(n111), .B2(n58), .Y(n59) );
  sky130_fd_sc_hd__a21oi_1 U125 ( .A1(din[4]), .A2(n87), .B1(n59), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U126 ( .A(loopy[3]), .Y(n60) );
  sky130_fd_sc_hd__nor3_1 U127 ( .A(n61), .B(n60), .C(n116), .Y(n64) );
  sky130_fd_sc_hd__o221ai_1 U128 ( .A1(loopy[3]), .A2(n116), .B1(n73), .B2(
        n148), .C1(n5), .Y(n63) );
  sky130_fd_sc_hd__mux2i_1 U129 ( .A0(n64), .A1(n63), .S(loopy[4]), .Y(n65) );
  sky130_fd_sc_hd__o21ai_1 U130 ( .A1(n3), .A2(n66), .B1(n65), .Y(n169) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(loopy_t[12]), .Y(n145) );
  sky130_fd_sc_hd__o221ai_1 U132 ( .A1(n223), .A2(n10), .B1(n222), .B2(n145), 
        .C1(n226), .Y(n186) );
  sky130_fd_sc_hd__nand2_1 U133 ( .A(n205), .B(n204), .Y(n94) );
  sky130_fd_sc_hd__inv_1 U134 ( .A(cycle[0]), .Y(n67) );
  sky130_fd_sc_hd__nor2_1 U135 ( .A(n266), .B(n67), .Y(n69) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(loopy[13]), .Y(n156) );
  sky130_fd_sc_hd__nand2_1 U137 ( .A(n72), .B(n128), .Y(n85) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(loopy_t[6]), .Y(n84) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(loopy[5]), .Y(n80) );
  sky130_fd_sc_hd__nand2_1 U140 ( .A(loopy[4]), .B(n73), .Y(n199) );
  sky130_fd_sc_hd__o22ai_1 U141 ( .A1(n80), .A2(n74), .B1(n80), .B2(n199), .Y(
        n95) );
  sky130_fd_sc_hd__nand2_1 U142 ( .A(n204), .B(n75), .Y(n149) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(loopy[6]), .Y(n88) );
  sky130_fd_sc_hd__nand4_1 U144 ( .A(n77), .B(loopy[7]), .C(n88), .D(loopy[8]), 
        .Y(n127) );
  sky130_fd_sc_hd__o32ai_1 U145 ( .A1(n208), .A2(n78), .A3(n148), .B1(n80), 
        .B2(n98), .Y(n79) );
  sky130_fd_sc_hd__mux2i_1 U146 ( .A0(n89), .A1(n1), .S(loopy[6]), .Y(n82) );
  sky130_fd_sc_hd__a31oi_1 U147 ( .A1(din[6]), .A2(n87), .A3(n128), .B1(n82), 
        .Y(n83) );
  sky130_fd_sc_hd__o21ai_1 U148 ( .A1(n85), .A2(n84), .B1(n83), .Y(n161) );
  sky130_fd_sc_hd__a32oi_1 U149 ( .A1(din[7]), .A2(n87), .A3(n128), .B1(
        loopy_t[7]), .B2(n86), .Y(n93) );
  sky130_fd_sc_hd__nor2_1 U150 ( .A(n89), .B(n88), .Y(n91) );
  sky130_fd_sc_hd__o21ai_1 U151 ( .A1(loopy[6]), .A2(n4), .B1(n1), .Y(n90) );
  sky130_fd_sc_hd__mux2i_1 U152 ( .A0(n91), .A1(n90), .S(loopy[7]), .Y(n92) );
  sky130_fd_sc_hd__nand2_1 U153 ( .A(n93), .B(n92), .Y(n162) );
  sky130_fd_sc_hd__nand2_1 U154 ( .A(n94), .B(n207), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U155 ( .A(loopy_t[8]), .Y(n101) );
  sky130_fd_sc_hd__nand3_1 U156 ( .A(loopy[6]), .B(loopy[7]), .C(n95), .Y(n96)
         );
  sky130_fd_sc_hd__nand3_1 U157 ( .A(loopy[6]), .B(loopy[5]), .C(loopy[7]), 
        .Y(n97) );
  sky130_fd_sc_hd__o32ai_1 U158 ( .A1(n208), .A2(n148), .A3(n96), .B1(n98), 
        .B2(n97), .Y(n102) );
  sky130_fd_sc_hd__o221ai_1 U159 ( .A1(n108), .A2(n148), .B1(n99), .B2(n98), 
        .C1(n128), .Y(n103) );
  sky130_fd_sc_hd__mux2i_1 U160 ( .A0(n102), .A1(n103), .S(loopy[8]), .Y(n100)
         );
  sky130_fd_sc_hd__o31ai_1 U161 ( .A1(n208), .A2(n124), .A3(n101), .B1(n100), 
        .Y(n163) );
  sky130_fd_sc_hd__o21ai_1 U162 ( .A1(loopy[8]), .A2(n4), .B1(n104), .Y(n105)
         );
  sky130_fd_sc_hd__mux2i_1 U163 ( .A0(n2), .A1(n105), .S(loopy[9]), .Y(n107)
         );
  sky130_fd_sc_hd__nand2_1 U164 ( .A(n107), .B(n106), .Y(n164) );
  sky130_fd_sc_hd__nand3_1 U165 ( .A(loopy[8]), .B(loopy[9]), .C(n108), .Y(
        n109) );
  sky130_fd_sc_hd__inv_1 U166 ( .A(loopy[10]), .Y(n113) );
  sky130_fd_sc_hd__inv_1 U167 ( .A(loopy_t[10]), .Y(n110) );
  sky130_fd_sc_hd__a21oi_1 U168 ( .A1(n111), .A2(n207), .B1(n110), .Y(n112) );
  sky130_fd_sc_hd__a31oi_1 U169 ( .A1(n138), .A2(n203), .A3(n113), .B1(n112), 
        .Y(n121) );
  sky130_fd_sc_hd__nand3_1 U170 ( .A(loopy[4]), .B(loopy[3]), .C(n114), .Y(
        n115) );
  sky130_fd_sc_hd__nor2_1 U171 ( .A(n115), .B(n116), .Y(n119) );
  sky130_fd_sc_hd__o221ai_1 U172 ( .A1(n117), .A2(n116), .B1(n138), .B2(n148), 
        .C1(n7), .Y(n118) );
  sky130_fd_sc_hd__mux2i_1 U173 ( .A0(n119), .A1(n118), .S(loopy[10]), .Y(n120) );
  sky130_fd_sc_hd__o21ai_1 U174 ( .A1(n3), .A2(n121), .B1(n120), .Y(n170) );
  sky130_fd_sc_hd__inv_1 U175 ( .A(loopy_t[11]), .Y(n123) );
  sky130_fd_sc_hd__mux2i_1 U176 ( .A0(n123), .A1(n228), .S(n229), .Y(n185) );
  sky130_fd_sc_hd__a31oi_1 U177 ( .A1(loopy[10]), .A2(n203), .A3(n138), .B1(
        n122), .Y(n125) );
  sky130_fd_sc_hd__o22a_1 U178 ( .A1(loopy[11]), .A2(n125), .B1(n124), .B2(
        n123), .X(n134) );
  sky130_fd_sc_hd__o31ai_1 U179 ( .A1(n205), .A2(n130), .A3(n129), .B1(n128), 
        .Y(n133) );
  sky130_fd_sc_hd__a21oi_1 U180 ( .A1(n138), .A2(loopy[10]), .B1(n148), .Y(
        n131) );
  sky130_fd_sc_hd__o21ai_1 U181 ( .A1(n131), .A2(n133), .B1(loopy[11]), .Y(
        n132) );
  sky130_fd_sc_hd__o21ai_1 U182 ( .A1(n134), .A2(n133), .B1(n132), .Y(n160) );
  sky130_fd_sc_hd__nand2_1 U183 ( .A(n136), .B(n135), .Y(n147) );
  sky130_fd_sc_hd__nand2_1 U184 ( .A(n147), .B(n137), .Y(n198) );
  sky130_fd_sc_hd__nand3_1 U185 ( .A(loopy[11]), .B(loopy[10]), .C(n138), .Y(
        n141) );
  sky130_fd_sc_hd__o21ai_1 U186 ( .A1(n148), .A2(n141), .B1(n149), .Y(n146) );
  sky130_fd_sc_hd__nor2_1 U187 ( .A(n140), .B(n139), .Y(n143) );
  sky130_fd_sc_hd__o21ai_1 U188 ( .A1(n142), .A2(n148), .B1(n147), .Y(n150) );
  sky130_fd_sc_hd__mux2i_1 U189 ( .A0(n143), .A1(n150), .S(loopy[12]), .Y(n144) );
  sky130_fd_sc_hd__o21ai_1 U190 ( .A1(n198), .A2(n145), .B1(n144), .Y(n159) );
  sky130_fd_sc_hd__inv_1 U191 ( .A(loopy_t[13]), .Y(n154) );
  sky130_fd_sc_hd__o221ai_1 U192 ( .A1(n11), .A2(n223), .B1(n222), .B2(n154), 
        .C1(n224), .Y(n187) );
  sky130_fd_sc_hd__nand3_1 U193 ( .A(loopy[12]), .B(n147), .C(n146), .Y(n155)
         );
  sky130_fd_sc_hd__o21ai_1 U194 ( .A1(loopy[12]), .A2(n6), .B1(n151), .Y(n157)
         );
  sky130_fd_sc_hd__mux2i_1 U195 ( .A0(n152), .A1(n157), .S(loopy[13]), .Y(n153) );
  sky130_fd_sc_hd__o21ai_1 U196 ( .A1(n198), .A2(n154), .B1(n153), .Y(n158) );
  sky130_fd_sc_hd__inv_1 U197 ( .A(loopy_t[14]), .Y(n197) );
  sky130_fd_sc_hd__o22ai_1 U198 ( .A1(n223), .A2(n12), .B1(n222), .B2(n197), 
        .Y(n188) );
  sky130_fd_sc_hd__nor2_1 U199 ( .A(n156), .B(n155), .Y(n195) );
  sky130_fd_sc_hd__o21ai_1 U200 ( .A1(loopy[13]), .A2(n6), .B1(n193), .Y(n194)
         );
  sky130_fd_sc_hd__mux2i_1 U201 ( .A0(n195), .A1(n194), .S(loopy[14]), .Y(n196) );
  sky130_fd_sc_hd__o21ai_1 U202 ( .A1(n198), .A2(n197), .B1(n196), .Y(n172) );
  sky130_fd_sc_hd__xor2_1 U203 ( .A(loopy[5]), .B(ppu_incr), .X(n200) );
  sky130_fd_sc_hd__xor2_1 U204 ( .A(n201), .B(n200), .X(n202) );
  sky130_fd_sc_hd__a32oi_1 U205 ( .A1(loopy_t[5]), .A2(n205), .A3(n204), .B1(
        n203), .B2(n202), .Y(n206) );
  sky130_fd_sc_hd__o21ai_1 U206 ( .A1(n207), .A2(n15), .B1(n206), .Y(n209) );
  sky130_fd_sc_hd__mux2i_1 U207 ( .A0(n209), .A1(loopy[5]), .S(n208), .Y(n210)
         );
  sky130_fd_sc_hd__nand2_1 U208 ( .A(n211), .B(n210), .Y(n165) );
  sky130_fd_sc_hd__mux2i_1 U209 ( .A0(n216), .A1(n217), .S(ppu_address_latch), 
        .Y(n192) );
  sky130_fd_sc_hd__nand2_1 U210 ( .A(n217), .B(n218), .Y(n216) );
  sky130_fd_sc_hd__o21a_1 U211 ( .A1(n219), .A2(n218), .B1(ce), .X(n217) );
  sky130_fd_sc_hd__nor4_1 U212 ( .A(ain[2]), .B(ain[0]), .C(n220), .D(n212), 
        .Y(n219) );
  sky130_fd_sc_hd__mux2_1 U213 ( .A0(din[2]), .A1(fine_x_scroll[2]), .S(n221), 
        .X(n190) );
  sky130_fd_sc_hd__nand2_1 U214 ( .A(din[5]), .B(n225), .Y(n224) );
  sky130_fd_sc_hd__nand2_1 U215 ( .A(din[4]), .B(n225), .Y(n226) );
  sky130_fd_sc_hd__clkinv_1 U216 ( .A(n227), .Y(n225) );
  sky130_fd_sc_hd__a22oi_1 U217 ( .A1(n230), .A2(din[1]), .B1(din[3]), .B2(
        n231), .Y(n228) );
  sky130_fd_sc_hd__mux2i_1 U218 ( .A0(n110), .A1(n232), .S(n229), .Y(n184) );
  sky130_fd_sc_hd__nor2_1 U219 ( .A(n18), .B(n233), .Y(n229) );
  sky130_fd_sc_hd__a22oi_1 U220 ( .A1(n230), .A2(din[0]), .B1(n231), .B2(
        din[2]), .Y(n232) );
  sky130_fd_sc_hd__o221ai_1 U221 ( .A1(n11), .A2(n227), .B1(n222), .B2(n234), 
        .C1(n235), .Y(n183) );
  sky130_fd_sc_hd__nand2_1 U222 ( .A(din[7]), .B(n236), .Y(n235) );
  sky130_fd_sc_hd__clkinv_1 U223 ( .A(loopy_t[9]), .Y(n234) );
  sky130_fd_sc_hd__o221ai_1 U224 ( .A1(n10), .A2(n227), .B1(n222), .B2(n101), 
        .C1(n237), .Y(n182) );
  sky130_fd_sc_hd__nand2_1 U225 ( .A(din[6]), .B(n236), .Y(n237) );
  sky130_fd_sc_hd__clkinv_1 U226 ( .A(n223), .Y(n236) );
  sky130_fd_sc_hd__nand2_1 U227 ( .A(n215), .B(n222), .Y(n223) );
  sky130_fd_sc_hd__nand2_1 U228 ( .A(n231), .B(n222), .Y(n227) );
  sky130_fd_sc_hd__o31ai_1 U229 ( .A1(n238), .A2(ppu_address_latch), .A3(n18), 
        .B1(n239), .Y(n222) );
  sky130_fd_sc_hd__o221ai_1 U230 ( .A1(n15), .A2(n240), .B1(n17), .B2(n241), 
        .C1(n242), .Y(n181) );
  sky130_fd_sc_hd__nand2_1 U231 ( .A(loopy_t[7]), .B(n243), .Y(n242) );
  sky130_fd_sc_hd__o221ai_1 U232 ( .A1(n14), .A2(n240), .B1(n16), .B2(n241), 
        .C1(n244), .Y(n180) );
  sky130_fd_sc_hd__nand2_1 U233 ( .A(loopy_t[6]), .B(n243), .Y(n244) );
  sky130_fd_sc_hd__o221ai_1 U234 ( .A1(n13), .A2(n240), .B1(n15), .B2(n241), 
        .C1(n245), .Y(n179) );
  sky130_fd_sc_hd__nand2_1 U235 ( .A(loopy_t[5]), .B(n243), .Y(n245) );
  sky130_fd_sc_hd__clkinv_1 U236 ( .A(n246), .Y(n243) );
  sky130_fd_sc_hd__nand2_1 U237 ( .A(n231), .B(n246), .Y(n241) );
  sky130_fd_sc_hd__nand2_1 U238 ( .A(n215), .B(n246), .Y(n240) );
  sky130_fd_sc_hd__nand2_1 U239 ( .A(n247), .B(n239), .Y(n246) );
  sky130_fd_sc_hd__nand3_1 U240 ( .A(ppu_address_latch), .B(ce), .C(n215), .Y(
        n239) );
  sky130_fd_sc_hd__o221ai_1 U241 ( .A1(n17), .A2(n248), .B1(n14), .B2(n249), 
        .C1(n250), .Y(n178) );
  sky130_fd_sc_hd__nand2_1 U242 ( .A(loopy_t[4]), .B(n251), .Y(n250) );
  sky130_fd_sc_hd__o221ai_1 U243 ( .A1(n16), .A2(n248), .B1(n13), .B2(n249), 
        .C1(n252), .Y(n177) );
  sky130_fd_sc_hd__nand2_1 U244 ( .A(loopy_t[3]), .B(n251), .Y(n252) );
  sky130_fd_sc_hd__o221ai_1 U245 ( .A1(n15), .A2(n248), .B1(n12), .B2(n249), 
        .C1(n253), .Y(n176) );
  sky130_fd_sc_hd__nand2_1 U246 ( .A(loopy_t[2]), .B(n251), .Y(n253) );
  sky130_fd_sc_hd__o221ai_1 U247 ( .A1(n14), .A2(n248), .B1(n11), .B2(n249), 
        .C1(n254), .Y(n175) );
  sky130_fd_sc_hd__nand2_1 U248 ( .A(loopy_t[1]), .B(n251), .Y(n254) );
  sky130_fd_sc_hd__o221ai_1 U249 ( .A1(n13), .A2(n248), .B1(n10), .B2(n249), 
        .C1(n255), .Y(n174) );
  sky130_fd_sc_hd__nand2_1 U250 ( .A(loopy_t[0]), .B(n251), .Y(n255) );
  sky130_fd_sc_hd__clkinv_1 U251 ( .A(n256), .Y(n251) );
  sky130_fd_sc_hd__nand2_1 U252 ( .A(n231), .B(n256), .Y(n249) );
  sky130_fd_sc_hd__nand2_1 U253 ( .A(n215), .B(n256), .Y(n248) );
  sky130_fd_sc_hd__nand2_1 U254 ( .A(n247), .B(n221), .Y(n256) );
  sky130_fd_sc_hd__a41oi_1 U255 ( .A1(cycle[1]), .A2(cycle[0]), .A3(n260), 
        .A4(n261), .B1(n258), .Y(n259) );
  sky130_fd_sc_hd__o41ai_1 U256 ( .A1(cycle[7]), .A2(cycle[5]), .A3(cycle[4]), 
        .A4(n262), .B1(cycle[8]), .Y(n260) );
  sky130_fd_sc_hd__nand3_1 U257 ( .A(n262), .B(n265), .C(n266), .Y(n264) );
  sky130_fd_sc_hd__nand4b_1 U258 ( .A_N(cycle[0]), .B(cycle[8]), .C(n267), .D(
        n261), .Y(n263) );
  sky130_fd_sc_hd__clkinv_1 U259 ( .A(cycle[2]), .Y(n261) );
  sky130_fd_sc_hd__a21oi_1 U260 ( .A1(n214), .A2(n231), .B1(n230), .Y(n233) );
  sky130_fd_sc_hd__nor4_1 U261 ( .A(n213), .B(ain[0]), .C(ain[1]), .D(ain[2]), 
        .Y(n230) );
  sky130_fd_sc_hd__clkinv_1 U262 ( .A(n238), .Y(n231) );
  sky130_fd_sc_hd__nand2_1 U263 ( .A(n238), .B(n257), .Y(n218) );
  sky130_fd_sc_hd__nand4_1 U264 ( .A(write), .B(ain[2]), .C(ain[0]), .D(n220), 
        .Y(n257) );
  sky130_fd_sc_hd__clkinv_1 U265 ( .A(ain[1]), .Y(n220) );
  sky130_fd_sc_hd__nand4b_1 U266 ( .A_N(ain[0]), .B(ain[2]), .C(ain[1]), .D(
        write), .Y(n238) );
  sky130_fd_sc_hd__nor3_1 U267 ( .A(n270), .B(cycle[2]), .C(cycle[1]), .Y(n269) );
  sky130_fd_sc_hd__nand3_1 U268 ( .A(n262), .B(n265), .C(n271), .Y(n270) );
  sky130_fd_sc_hd__nor3_1 U269 ( .A(n266), .B(cycle[0]), .C(n272), .Y(n268) );
  sky130_fd_sc_hd__nor4_1 U270 ( .A(n267), .B(n271), .C(n262), .D(n265), .Y(
        n274) );
  sky130_fd_sc_hd__clkinv_1 U271 ( .A(cycle[7]), .Y(n265) );
  sky130_fd_sc_hd__clkinv_1 U272 ( .A(cycle[6]), .Y(n262) );
  sky130_fd_sc_hd__clkinv_1 U273 ( .A(cycle[3]), .Y(n271) );
  sky130_fd_sc_hd__clkinv_1 U274 ( .A(cycle[1]), .Y(n267) );
  sky130_fd_sc_hd__nor3_1 U275 ( .A(n272), .B(cycle[8]), .C(cycle[2]), .Y(n273) );
  sky130_fd_sc_hd__clkinv_1 U276 ( .A(cycle[4]), .Y(n272) );
endmodule


module BgPainter ( clk, ce, enable, cycle, fine_x_scroll, loopy, name_table, 
        vram_data, pixel );
  input [2:0] cycle;
  input [2:0] fine_x_scroll;
  input [14:0] loopy;
  output [7:0] name_table;
  input [7:0] vram_data;
  output [3:0] pixel;
  input clk, ce, enable;
  wire   N33, N34, N35, n27, n28, n34, n35, n36, n44, n65, n66, n67, n70, n73,
         n74, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102,
         n103, n104, n105, n106, n107, n108, n109, n110, n111, n112, n113,
         n114, n115, n116, n117, n118, n119, n120, n121, n122, n123, n124,
         n125, n126, n127, n128, n129, n130, n131, n132, n133, n134, n135,
         n136, n137, n138, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12,
         n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26,
         n29, n30, n31, n32, n33, n37, n38, n39, n40, n41, n42, n43, n45, n46,
         n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60,
         n61, n62, n63, n64, n68, n69, n71, n72, n75, n76, n139, n140, n141,
         n142, n143, n144, n145, n146, n147, n148, n149;
  wire   [1:0] current_attribute_table;
  wire   [7:0] bg0;
  wire   [15:0] playfield_pipe_1;
  wire   [15:0] playfield_pipe_2;
  wire   [8:0] playfield_pipe_3;
  wire   [8:0] playfield_pipe_4;
  assign N33 = fine_x_scroll[0];
  assign N34 = fine_x_scroll[1];
  assign N35 = fine_x_scroll[2];

  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_3_reg_8_ ( .D(
        current_attribute_table[0]), .DE(n80), .CLK(clk), .Q(n57) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_3_reg_6_ ( .D(n53), .DE(n54), .CLK(
        clk), .Q(n2) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_3_reg_5_ ( .D(n2), .DE(n54), .CLK(
        clk), .Q(playfield_pipe_3[5]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_3_reg_4_ ( .D(playfield_pipe_3[5]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_3[4]) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_3_reg_3_ ( .D(playfield_pipe_3[4]), 
        .DE(n54), .CLK(clk), .Q(n4), .Q_N(n27) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_3_reg_2_ ( .D(n4), .DE(n54), .CLK(
        clk), .Q(playfield_pipe_3[2]), .Q_N(n28) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_3_reg_1_ ( .D(playfield_pipe_3[2]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_3[1]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_3_reg_0_ ( .D(playfield_pipe_3[1]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_3[0]) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_4_reg_7_ ( .D(n58), .DE(n54), .CLK(
        clk), .Q(n52) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_4_reg_6_ ( .D(n52), .DE(n54), .CLK(
        clk), .Q(n1) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_4_reg_5_ ( .D(n1), .DE(n54), .CLK(
        clk), .Q(playfield_pipe_4[5]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_4_reg_4_ ( .D(playfield_pipe_4[5]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_4[4]) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_4_reg_3_ ( .D(playfield_pipe_4[4]), 
        .DE(n54), .CLK(clk), .Q(n3), .Q_N(n34) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_4_reg_2_ ( .D(n3), .DE(n54), .CLK(
        clk), .Q(playfield_pipe_4[2]), .Q_N(n35) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_4_reg_1_ ( .D(playfield_pipe_4[2]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_4[1]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_4_reg_0_ ( .D(playfield_pipe_4[1]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_4[0]) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_1_reg_15_ ( .D(bg0[0]), .DE(n80), 
        .CLK(clk), .Q_N(n36) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_7_ ( .D(playfield_pipe_1[8]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[7]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_6_ ( .D(playfield_pipe_1[7]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[6]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_5_ ( .D(playfield_pipe_1[6]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[5]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_4_ ( .D(playfield_pipe_1[5]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[4]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_3_ ( .D(playfield_pipe_1[4]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[3]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_2_ ( .D(playfield_pipe_1[3]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[2]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_1_ ( .D(playfield_pipe_1[2]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[1]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_1_reg_0_ ( .D(playfield_pipe_1[1]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_1[0]) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_2_reg_15_ ( .D(vram_data[0]), .DE(
        n80), .CLK(clk), .Q_N(n44) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_2_reg_7_ ( .D(playfield_pipe_2[8]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[7]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_2_reg_6_ ( .D(playfield_pipe_2[7]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[6]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_2_reg_4_ ( .D(playfield_pipe_2[5]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[4]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_2_reg_2_ ( .D(playfield_pipe_2[3]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[2]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_2_reg_1_ ( .D(playfield_pipe_2[2]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[1]) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_2_reg_0_ ( .D(playfield_pipe_2[1]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[0]) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(N34), .B(N33), .Y(n70) );
  sky130_fd_sc_hd__nand2_1 U110 ( .A(vram_data[7]), .B(n80), .Y(n79) );
  sky130_fd_sc_hd__nand2_1 U111 ( .A(vram_data[1]), .B(n80), .Y(n81) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(vram_data[2]), .B(n80), .Y(n82) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(vram_data[3]), .B(n80), .Y(n83) );
  sky130_fd_sc_hd__nand2_1 U114 ( .A(vram_data[4]), .B(n80), .Y(n84) );
  sky130_fd_sc_hd__nand2_1 U115 ( .A(vram_data[5]), .B(n80), .Y(n85) );
  sky130_fd_sc_hd__nand2_1 U116 ( .A(vram_data[6]), .B(n80), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U117 ( .A(bg0[7]), .B(n80), .Y(n87) );
  sky130_fd_sc_hd__nand2_1 U118 ( .A(bg0[1]), .B(n80), .Y(n88) );
  sky130_fd_sc_hd__nand2_1 U119 ( .A(bg0[2]), .B(n80), .Y(n89) );
  sky130_fd_sc_hd__nand2_1 U120 ( .A(bg0[3]), .B(n80), .Y(n90) );
  sky130_fd_sc_hd__nand2_1 U121 ( .A(bg0[4]), .B(n80), .Y(n91) );
  sky130_fd_sc_hd__nand2_1 U122 ( .A(bg0[5]), .B(n80), .Y(n92) );
  sky130_fd_sc_hd__nand2_1 U123 ( .A(bg0[6]), .B(n80), .Y(n93) );
  sky130_fd_sc_hd__and3b_1 U126 ( .B(n101), .C(n100), .A_N(n97), .X(n98) );
  sky130_fd_sc_hd__nand2b_1 U127 ( .A_N(loopy[6]), .B(loopy[1]), .Y(n100) );
  sky130_fd_sc_hd__nand2b_1 U128 ( .A_N(loopy[1]), .B(loopy[6]), .Y(n101) );
  sky130_fd_sc_hd__nand2_1 U129 ( .A(n104), .B(cycle[1]), .Y(n96) );
  sky130_fd_sc_hd__and3b_1 U131 ( .B(ce), .C(cycle[0]), .A_N(cycle[2]), .X(
        n104) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_4_reg_8_ ( .D(
        current_attribute_table[1]), .DE(n80), .CLK(clk), .Q(n58) );
  sky130_fd_sc_hd__edfxtp_1 playfield_pipe_3_reg_7_ ( .D(n57), .DE(n54), .CLK(
        clk), .Q(n53) );
  sky130_fd_sc_hd__edfxbp_1 playfield_pipe_2_reg_5_ ( .D(playfield_pipe_2[6]), 
        .DE(n54), .CLK(clk), .Q(playfield_pipe_2[5]), .Q_N(n26) );
  sky130_fd_sc_hd__mux2_1 \playfield_pipe_2_reg_3_/U3  ( .A0(
        playfield_pipe_2[3]), .A1(playfield_pipe_2[4]), .S(n54), .X(n5) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_3_ ( .D(n5), .CLK(clk), .Q(
        playfield_pipe_2[3]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_7_ ( .D(n138), .CLK(clk), .Q(bg0[7]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_6_ ( .D(n137), .CLK(clk), .Q(bg0[6]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_5_ ( .D(n136), .CLK(clk), .Q(bg0[5]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_4_ ( .D(n135), .CLK(clk), .Q(bg0[4]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_3_ ( .D(n134), .CLK(clk), .Q(bg0[3]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_2_ ( .D(n133), .CLK(clk), .Q(bg0[2]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_1_ ( .D(n132), .CLK(clk), .Q(bg0[1]) );
  sky130_fd_sc_hd__dfxtp_1 bg0_reg_0_ ( .D(n131), .CLK(clk), .Q(bg0[0]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_7_ ( .D(n130), .CLK(clk), 
        .Q(name_table[7]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_6_ ( .D(n129), .CLK(clk), 
        .Q(name_table[6]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_5_ ( .D(n128), .CLK(clk), 
        .Q(name_table[5]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_4_ ( .D(n127), .CLK(clk), 
        .Q(name_table[4]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_3_ ( .D(n126), .CLK(clk), 
        .Q(name_table[3]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_2_ ( .D(n125), .CLK(clk), 
        .Q(name_table[2]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_1_ ( .D(n124), .CLK(clk), 
        .Q(name_table[1]) );
  sky130_fd_sc_hd__dfxtp_1 current_name_table_reg_0_ ( .D(n123), .CLK(clk), 
        .Q(name_table[0]) );
  sky130_fd_sc_hd__dfxtp_1 current_attribute_table_reg_1_ ( .D(n122), .CLK(clk), .Q(current_attribute_table[1]) );
  sky130_fd_sc_hd__dfxtp_1 current_attribute_table_reg_0_ ( .D(n121), .CLK(clk), .Q(current_attribute_table[0]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_14_ ( .D(n115), .CLK(clk), .Q(
        playfield_pipe_1[14]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_13_ ( .D(n116), .CLK(clk), .Q(
        playfield_pipe_1[13]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_12_ ( .D(n117), .CLK(clk), .Q(
        playfield_pipe_1[12]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_11_ ( .D(n118), .CLK(clk), .Q(
        playfield_pipe_1[11]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_10_ ( .D(n119), .CLK(clk), .Q(
        playfield_pipe_1[10]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_9_ ( .D(n120), .CLK(clk), .Q(
        playfield_pipe_1[9]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_1_reg_8_ ( .D(n114), .CLK(clk), .Q(
        playfield_pipe_1[8]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_14_ ( .D(n108), .CLK(clk), .Q(
        playfield_pipe_2[14]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_13_ ( .D(n109), .CLK(clk), .Q(
        playfield_pipe_2[13]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_12_ ( .D(n110), .CLK(clk), .Q(
        playfield_pipe_2[12]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_11_ ( .D(n111), .CLK(clk), .Q(
        playfield_pipe_2[11]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_10_ ( .D(n112), .CLK(clk), .Q(
        playfield_pipe_2[10]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_9_ ( .D(n113), .CLK(clk), .Q(
        playfield_pipe_2[9]) );
  sky130_fd_sc_hd__dfxtp_1 playfield_pipe_2_reg_8_ ( .D(n107), .CLK(clk), .Q(
        playfield_pipe_2[8]) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(n49), .Y(n48) );
  sky130_fd_sc_hd__nor2_1 U4 ( .A(N33), .B(N34), .Y(n67) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(playfield_pipe_2[10]), .Y(n75) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(playfield_pipe_2[11]), .Y(n72) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(playfield_pipe_2[12]), .Y(n71) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(playfield_pipe_2[13]), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(playfield_pipe_2[14]), .Y(n68) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(playfield_pipe_1[10]), .Y(n63) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(playfield_pipe_1[11]), .Y(n62) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(playfield_pipe_1[12]), .Y(n61) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(playfield_pipe_1[13]), .Y(n60) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(n94), .B(n54), .Y(n78) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(playfield_pipe_1[14]), .Y(n59) );
  sky130_fd_sc_hd__nand3_1 U16 ( .A(cycle[1]), .B(cycle[0]), .C(cycle[2]), .Y(
        n94) );
  sky130_fd_sc_hd__o22ai_1 U17 ( .A1(n65), .A2(n139), .B1(N35), .B2(n66), .Y(
        pixel[3]) );
  sky130_fd_sc_hd__o22ai_1 U18 ( .A1(n73), .A2(n139), .B1(N35), .B2(n74), .Y(
        pixel[2]) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(playfield_pipe_2[7]), .B(n30), .X(n8) );
  sky130_fd_sc_hd__o22a_1 U20 ( .A1(n42), .A2(n21), .B1(n49), .B2(n20), .X(n11) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(playfield_pipe_1[4]), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(playfield_pipe_1[7]), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(cycle[1]), .Y(n141) );
  sky130_fd_sc_hd__nor2_1 U24 ( .A(loopy[6]), .B(loopy[1]), .Y(n97) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(n96), .Y(n140) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(n104), .B(n141), .Y(n105) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(vram_data[0]), .Y(n149) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(vram_data[1]), .Y(n148) );
  sky130_fd_sc_hd__inv_2 U29 ( .A(vram_data[2]), .Y(n147) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(vram_data[3]), .Y(n146) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(vram_data[4]), .Y(n145) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(vram_data[5]), .Y(n144) );
  sky130_fd_sc_hd__inv_2 U33 ( .A(vram_data[6]), .Y(n143) );
  sky130_fd_sc_hd__nand4_1 U34 ( .A(cycle[2]), .B(cycle[0]), .C(ce), .D(n141), 
        .Y(n106) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(vram_data[7]), .Y(n142) );
  sky130_fd_sc_hd__o221ai_1 U36 ( .A1(n78), .A2(n75), .B1(n54), .B2(n76), .C1(
        n86), .Y(n113) );
  sky130_fd_sc_hd__o221ai_1 U37 ( .A1(n78), .A2(n72), .B1(n54), .B2(n75), .C1(
        n85), .Y(n112) );
  sky130_fd_sc_hd__o221ai_1 U38 ( .A1(n78), .A2(n71), .B1(n54), .B2(n72), .C1(
        n84), .Y(n111) );
  sky130_fd_sc_hd__o221ai_1 U39 ( .A1(n78), .A2(n69), .B1(n54), .B2(n71), .C1(
        n83), .Y(n110) );
  sky130_fd_sc_hd__o221ai_1 U40 ( .A1(n78), .A2(n68), .B1(n54), .B2(n69), .C1(
        n82), .Y(n109) );
  sky130_fd_sc_hd__o221ai_1 U41 ( .A1(n78), .A2(n44), .B1(n54), .B2(n68), .C1(
        n81), .Y(n108) );
  sky130_fd_sc_hd__o221ai_1 U42 ( .A1(n78), .A2(n63), .B1(n54), .B2(n64), .C1(
        n93), .Y(n120) );
  sky130_fd_sc_hd__o221ai_1 U43 ( .A1(n78), .A2(n62), .B1(n54), .B2(n63), .C1(
        n92), .Y(n119) );
  sky130_fd_sc_hd__o221ai_1 U44 ( .A1(n78), .A2(n61), .B1(n54), .B2(n62), .C1(
        n91), .Y(n118) );
  sky130_fd_sc_hd__o221ai_1 U45 ( .A1(n78), .A2(n60), .B1(n54), .B2(n61), .C1(
        n90), .Y(n117) );
  sky130_fd_sc_hd__o221ai_1 U46 ( .A1(n78), .A2(n59), .B1(n54), .B2(n60), .C1(
        n89), .Y(n116) );
  sky130_fd_sc_hd__o221ai_1 U47 ( .A1(n78), .A2(n36), .B1(n54), .B2(n59), .C1(
        n88), .Y(n115) );
  sky130_fd_sc_hd__o22ai_1 U48 ( .A1(n140), .A2(n56), .B1(n95), .B2(n96), .Y(
        n121) );
  sky130_fd_sc_hd__inv_2 U49 ( .A(current_attribute_table[0]), .Y(n56) );
  sky130_fd_sc_hd__a221oi_1 U50 ( .A1(n97), .A2(vram_data[0]), .B1(n98), .B2(
        vram_data[6]), .C1(n99), .Y(n95) );
  sky130_fd_sc_hd__o22ai_1 U51 ( .A1(n147), .A2(n100), .B1(n145), .B2(n101), 
        .Y(n99) );
  sky130_fd_sc_hd__o22ai_1 U52 ( .A1(n140), .A2(n55), .B1(n102), .B2(n96), .Y(
        n122) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(current_attribute_table[1]), .Y(n55) );
  sky130_fd_sc_hd__a221oi_1 U54 ( .A1(n97), .A2(vram_data[1]), .B1(n98), .B2(
        vram_data[7]), .C1(n103), .Y(n102) );
  sky130_fd_sc_hd__o22ai_1 U55 ( .A1(n146), .A2(n100), .B1(n144), .B2(n101), 
        .Y(n103) );
  sky130_fd_sc_hd__o2bb2ai_1 U56 ( .B1(n149), .B2(n105), .A1_N(name_table[0]), 
        .A2_N(n105), .Y(n123) );
  sky130_fd_sc_hd__o2bb2ai_1 U57 ( .B1(n148), .B2(n105), .A1_N(name_table[1]), 
        .A2_N(n105), .Y(n124) );
  sky130_fd_sc_hd__o2bb2ai_1 U58 ( .B1(n147), .B2(n105), .A1_N(name_table[2]), 
        .A2_N(n105), .Y(n125) );
  sky130_fd_sc_hd__o2bb2ai_1 U59 ( .B1(n146), .B2(n105), .A1_N(name_table[3]), 
        .A2_N(n105), .Y(n126) );
  sky130_fd_sc_hd__o2bb2ai_1 U60 ( .B1(n145), .B2(n105), .A1_N(name_table[4]), 
        .A2_N(n105), .Y(n127) );
  sky130_fd_sc_hd__o2bb2ai_1 U61 ( .B1(n144), .B2(n105), .A1_N(name_table[5]), 
        .A2_N(n105), .Y(n128) );
  sky130_fd_sc_hd__o2bb2ai_1 U62 ( .B1(n143), .B2(n105), .A1_N(name_table[6]), 
        .A2_N(n105), .Y(n129) );
  sky130_fd_sc_hd__o2bb2ai_1 U63 ( .B1(n142), .B2(n105), .A1_N(name_table[7]), 
        .A2_N(n105), .Y(n130) );
  sky130_fd_sc_hd__o2bb2ai_1 U64 ( .B1(n149), .B2(n106), .A1_N(n106), .A2_N(
        bg0[0]), .Y(n131) );
  sky130_fd_sc_hd__o2bb2ai_1 U65 ( .B1(n148), .B2(n106), .A1_N(n106), .A2_N(
        bg0[1]), .Y(n132) );
  sky130_fd_sc_hd__o2bb2ai_1 U66 ( .B1(n147), .B2(n106), .A1_N(n106), .A2_N(
        bg0[2]), .Y(n133) );
  sky130_fd_sc_hd__o2bb2ai_1 U67 ( .B1(n146), .B2(n106), .A1_N(n106), .A2_N(
        bg0[3]), .Y(n134) );
  sky130_fd_sc_hd__o2bb2ai_1 U68 ( .B1(n145), .B2(n106), .A1_N(n106), .A2_N(
        bg0[4]), .Y(n135) );
  sky130_fd_sc_hd__o2bb2ai_1 U69 ( .B1(n144), .B2(n106), .A1_N(n106), .A2_N(
        bg0[5]), .Y(n136) );
  sky130_fd_sc_hd__o2bb2ai_1 U70 ( .B1(n143), .B2(n106), .A1_N(n106), .A2_N(
        bg0[6]), .Y(n137) );
  sky130_fd_sc_hd__o2bb2ai_1 U71 ( .B1(n142), .B2(n106), .A1_N(n106), .A2_N(
        bg0[7]), .Y(n138) );
  sky130_fd_sc_hd__nor2_1 U72 ( .A(n94), .B(n77), .Y(n80) );
  sky130_fd_sc_hd__inv_2 U73 ( .A(n77), .Y(n54) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(n42), .Y(n51) );
  sky130_fd_sc_hd__nor3_2 U75 ( .A(n7), .B(n8), .C(n29), .Y(n32) );
  sky130_fd_sc_hd__clkinv_1 U76 ( .A(n6), .Y(n33) );
  sky130_fd_sc_hd__nand2_2 U77 ( .A(N33), .B(n15), .Y(n42) );
  sky130_fd_sc_hd__nand2b_2 U78 ( .A_N(n15), .B(n16), .Y(n49) );
  sky130_fd_sc_hd__inv_2 U79 ( .A(N34), .Y(n15) );
  sky130_fd_sc_hd__and2_0 U80 ( .A(playfield_pipe_2[4]), .B(n31), .X(n7) );
  sky130_fd_sc_hd__mux4_2 U81 ( .A0(playfield_pipe_2[0]), .A1(
        playfield_pipe_2[1]), .A2(playfield_pipe_2[2]), .A3(
        playfield_pipe_2[3]), .S0(N33), .S1(N34), .X(n6) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(n13), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U83 ( .A(n14), .Y(n30) );
  sky130_fd_sc_hd__a221oi_2 U84 ( .A1(playfield_pipe_1[0]), .A2(n31), .B1(
        playfield_pipe_1[3]), .B2(n30), .C1(n19), .Y(n23) );
  sky130_fd_sc_hd__o221a_1 U85 ( .A1(n9), .A2(n13), .B1(n10), .B2(n14), .C1(
        n11), .X(n22) );
  sky130_fd_sc_hd__nand2_1 U86 ( .A(enable), .B(ce), .Y(n77) );
  sky130_fd_sc_hd__inv_1 U87 ( .A(playfield_pipe_1[8]), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(playfield_pipe_1[9]), .Y(n64) );
  sky130_fd_sc_hd__o221ai_1 U89 ( .A1(n54), .A2(n12), .B1(n64), .B2(n78), .C1(
        n87), .Y(n114) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(N33), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U91 ( .A(n16), .B(n15), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(N33), .B(N34), .Y(n14) );
  sky130_fd_sc_hd__inv_1 U93 ( .A(playfield_pipe_1[1]), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(playfield_pipe_1[2]), .Y(n17) );
  sky130_fd_sc_hd__o22ai_1 U95 ( .A1(n42), .A2(n18), .B1(n49), .B2(n17), .Y(
        n19) );
  sky130_fd_sc_hd__inv_1 U96 ( .A(playfield_pipe_1[5]), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U97 ( .A(playfield_pipe_1[6]), .Y(n20) );
  sky130_fd_sc_hd__mux2i_1 U98 ( .A0(n23), .A1(n22), .S(N35), .Y(pixel[0]) );
  sky130_fd_sc_hd__inv_1 U99 ( .A(playfield_pipe_2[8]), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(playfield_pipe_2[9]), .Y(n76) );
  sky130_fd_sc_hd__o221ai_1 U101 ( .A1(n54), .A2(n24), .B1(n76), .B2(n78), 
        .C1(n79), .Y(n107) );
  sky130_fd_sc_hd__inv_1 U102 ( .A(playfield_pipe_2[6]), .Y(n25) );
  sky130_fd_sc_hd__o22ai_1 U103 ( .A1(n42), .A2(n26), .B1(n49), .B2(n25), .Y(
        n29) );
  sky130_fd_sc_hd__mux2i_1 U104 ( .A0(n33), .A1(n32), .S(N35), .Y(pixel[1]) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(n70), .Y(n47) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(n67), .Y(n45) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(playfield_pipe_3[4]), .Y(n38) );
  sky130_fd_sc_hd__inv_1 U108 ( .A(playfield_pipe_3[5]), .Y(n37) );
  sky130_fd_sc_hd__o22ai_1 U124 ( .A1(n45), .A2(n38), .B1(n42), .B2(n37), .Y(
        n39) );
  sky130_fd_sc_hd__a221oi_1 U125 ( .A1(n48), .A2(n2), .B1(n53), .B2(n47), .C1(
        n39), .Y(n73) );
  sky130_fd_sc_hd__inv_1 U130 ( .A(N35), .Y(n139) );
  sky130_fd_sc_hd__o22ai_1 U132 ( .A1(n27), .A2(n70), .B1(n28), .B2(n49), .Y(
        n40) );
  sky130_fd_sc_hd__a221oi_1 U133 ( .A1(playfield_pipe_3[1]), .A2(n51), .B1(
        playfield_pipe_3[0]), .B2(n67), .C1(n40), .Y(n74) );
  sky130_fd_sc_hd__inv_1 U134 ( .A(playfield_pipe_4[4]), .Y(n43) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(playfield_pipe_4[5]), .Y(n41) );
  sky130_fd_sc_hd__o22ai_1 U136 ( .A1(n45), .A2(n43), .B1(n42), .B2(n41), .Y(
        n46) );
  sky130_fd_sc_hd__a221oi_1 U137 ( .A1(n48), .A2(n1), .B1(n47), .B2(n52), .C1(
        n46), .Y(n65) );
  sky130_fd_sc_hd__o22ai_1 U138 ( .A1(n34), .A2(n70), .B1(n35), .B2(n49), .Y(
        n50) );
  sky130_fd_sc_hd__a221oi_1 U139 ( .A1(playfield_pipe_4[1]), .A2(n51), .B1(
        playfield_pipe_4[0]), .B2(n67), .C1(n50), .Y(n66) );
endmodule


module SpriteRAM_DW01_sub_1 ( A, B, CI, DIFF, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] DIFF;
  input CI;
  output CO;
  wire   n1, n2, n3, n4, n5, n6, n9, n10, n11, n12, n13, n14, n15, n16, n17,
         n18, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32,
         n34, n35, n36, n37, n38, n39, n40, n42, n44, n45, n48, n49, n50, n53,
         n54, n55, n56, n57, n58, n59, n60, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124;

  sky130_fd_sc_hd__nand2_1 U5 ( .A(n114), .B(n113), .Y(n10) );
  sky130_fd_sc_hd__a21oi_1 U6 ( .A1(n12), .A2(n118), .B1(n13), .Y(n11) );
  sky130_fd_sc_hd__o21ai_1 U8 ( .A1(n14), .A2(n22), .B1(n15), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n123), .B(n15), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n53), .B(A[7]), .Y(n15) );
  sky130_fd_sc_hd__xnor2_1 U13 ( .A(n3), .B(n23), .Y(DIFF[6]) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(n26), .B(n108), .Y(n17) );
  sky130_fd_sc_hd__a21oi_1 U16 ( .A1(n27), .A2(n108), .B1(n20), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(n108), .B(n22), .Y(n3) );
  sky130_fd_sc_hd__nor2_1 U21 ( .A(A[6]), .B(n54), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(n54), .B(A[6]), .Y(n22) );
  sky130_fd_sc_hd__xnor2_1 U23 ( .A(n4), .B(n30), .Y(DIFF[5]) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(n55), .B(A[5]), .Y(n29) );
  sky130_fd_sc_hd__xor2_1 U33 ( .A(n5), .B(n115), .X(DIFF[4]) );
  sky130_fd_sc_hd__nand2_1 U35 ( .A(n49), .B(n32), .Y(n5) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(n50), .B(n37), .Y(n6) );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(n57), .B(A[3]), .Y(n37) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n59), .B(A[1]), .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(n58), .B(A[2]), .Y(n40) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(B[2]), .Y(n58) );
  sky130_fd_sc_hd__nor2_4 U75 ( .A(A[1]), .B(n59), .Y(n116) );
  sky130_fd_sc_hd__inv_2 U76 ( .A(B[1]), .Y(n59) );
  sky130_fd_sc_hd__o21ai_2 U77 ( .A1(n45), .A2(n116), .B1(n44), .Y(n42) );
  sky130_fd_sc_hd__o21ai_1 U78 ( .A1(n45), .A2(n116), .B1(n44), .Y(n120) );
  sky130_fd_sc_hd__nor2_2 U79 ( .A(n60), .B(A[0]), .Y(n45) );
  sky130_fd_sc_hd__inv_1 U80 ( .A(B[3]), .Y(n95) );
  sky130_fd_sc_hd__inv_1 U81 ( .A(n95), .Y(n96) );
  sky130_fd_sc_hd__nand2_1 U82 ( .A(n38), .B(n6), .Y(n99) );
  sky130_fd_sc_hd__nand2_2 U83 ( .A(n97), .B(n98), .Y(n100) );
  sky130_fd_sc_hd__nand2_1 U84 ( .A(n99), .B(n100), .Y(DIFF[3]) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(n38), .Y(n97) );
  sky130_fd_sc_hd__inv_2 U86 ( .A(n6), .Y(n98) );
  sky130_fd_sc_hd__dlygate4sd1_1 U87 ( .A(n32), .X(n101) );
  sky130_fd_sc_hd__o21ai_2 U88 ( .A1(n24), .A2(n115), .B1(n25), .Y(n23) );
  sky130_fd_sc_hd__clkinv_1 U89 ( .A(B[6]), .Y(n54) );
  sky130_fd_sc_hd__nor2_1 U90 ( .A(A[5]), .B(n55), .Y(n117) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(B[5]), .Y(n55) );
  sky130_fd_sc_hd__inv_1 U92 ( .A(A[6]), .Y(n103) );
  sky130_fd_sc_hd__nor2_1 U93 ( .A(n14), .B(n21), .Y(n114) );
  sky130_fd_sc_hd__nand2_1 U94 ( .A(n48), .B(n29), .Y(n4) );
  sky130_fd_sc_hd__clkinv_1 U95 ( .A(n122), .Y(n48) );
  sky130_fd_sc_hd__clkinv_2 U96 ( .A(B[4]), .Y(n56) );
  sky130_fd_sc_hd__nor2_2 U97 ( .A(A[4]), .B(n56), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U98 ( .A(B[7]), .Y(n53) );
  sky130_fd_sc_hd__a21oi_2 U99 ( .A1(n42), .A2(n34), .B1(n35), .Y(n115) );
  sky130_fd_sc_hd__o21ai_2 U100 ( .A1(n119), .A2(n1), .B1(n101), .Y(n30) );
  sky130_fd_sc_hd__o21ai_1 U101 ( .A1(n39), .A2(n124), .B1(n40), .Y(n38) );
  sky130_fd_sc_hd__nor2_2 U102 ( .A(A[2]), .B(n58), .Y(n39) );
  sky130_fd_sc_hd__nand2_2 U103 ( .A(n111), .B(n18), .Y(n16) );
  sky130_fd_sc_hd__nor2_2 U104 ( .A(A[3]), .B(n57), .Y(n121) );
  sky130_fd_sc_hd__o21ai_1 U105 ( .A1(n1), .A2(n10), .B1(n11), .Y(n9) );
  sky130_fd_sc_hd__o22ai_2 U106 ( .A1(n102), .A2(n96), .B1(n40), .B2(n36), .Y(
        n35) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(A[3]), .Y(n102) );
  sky130_fd_sc_hd__xnor2_2 U108 ( .A(n2), .B(n16), .Y(DIFF[7]) );
  sky130_fd_sc_hd__inv_2 U109 ( .A(B[0]), .Y(n60) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(B[3]), .Y(n57) );
  sky130_fd_sc_hd__nand2_1 U111 ( .A(n103), .B(B[6]), .Y(n108) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(n9), .B(A[8]), .Y(n106) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(n104), .B(n105), .Y(n107) );
  sky130_fd_sc_hd__nand2_1 U114 ( .A(n107), .B(n106), .Y(DIFF[8]) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(n9), .Y(n104) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(A[8]), .Y(n105) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(n17), .Y(n109) );
  sky130_fd_sc_hd__nand2_1 U118 ( .A(n109), .B(n110), .Y(n111) );
  sky130_fd_sc_hd__inv_1 U119 ( .A(n115), .Y(n110) );
  sky130_fd_sc_hd__nor2_1 U120 ( .A(n31), .B(n28), .Y(n112) );
  sky130_fd_sc_hd__nor2_1 U121 ( .A(n31), .B(n28), .Y(n113) );
  sky130_fd_sc_hd__nor2_1 U122 ( .A(n31), .B(n28), .Y(n26) );
  sky130_fd_sc_hd__nor2_1 U123 ( .A(n14), .B(n21), .Y(n12) );
  sky130_fd_sc_hd__nor2_1 U124 ( .A(A[5]), .B(n55), .Y(n28) );
  sky130_fd_sc_hd__nor2_2 U125 ( .A(A[7]), .B(n53), .Y(n14) );
  sky130_fd_sc_hd__inv_1 U126 ( .A(n22), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U127 ( .A(n112), .Y(n24) );
  sky130_fd_sc_hd__o21ai_1 U128 ( .A1(n32), .A2(n117), .B1(n29), .Y(n118) );
  sky130_fd_sc_hd__o21ai_0 U129 ( .A1(n32), .A2(n117), .B1(n29), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U130 ( .A(n49), .Y(n119) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(n31), .Y(n49) );
  sky130_fd_sc_hd__nand2_2 U132 ( .A(n56), .B(A[4]), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U133 ( .A(A[3]), .B(n57), .Y(n36) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U134 ( .A(n117), .X(n122) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(n121), .Y(n50) );
  sky130_fd_sc_hd__or2_2 U136 ( .A(A[7]), .B(n53), .X(n123) );
  sky130_fd_sc_hd__o21a_1 U137 ( .A1(n116), .A2(n45), .B1(n44), .X(n124) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(n118), .Y(n25) );
  sky130_fd_sc_hd__a21oi_1 U139 ( .A1(n120), .A2(n34), .B1(n35), .Y(n1) );
  sky130_fd_sc_hd__nor2_2 U140 ( .A(n39), .B(n121), .Y(n34) );
endmodule


module SpriteRAM ( clk, ce, reset_line, sprites_enabled, exiting_vblank, 
        obj_size, scanline, cycle, oam_bus, oam_ptr_load, oam_load, data_in, 
        spr_overflow, sprite0 );
  input [8:0] scanline;
  input [8:0] cycle;
  output [7:0] oam_bus;
  input [7:0] data_in;
  input clk, ce, reset_line, sprites_enabled, exiting_vblank, obj_size,
         oam_ptr_load, oam_load;
  output spr_overflow, sprite0;
  wire   N31, N32, N33, N34, N35, N36, N37, N38, n2769, n2770, n2771,
         sprite0_curr, n5, n278, n283, n421, n625, n626, n627, n628, n629,
         n630, n631, n632, n633, n634, n635, n636, n637, n638, n639, n640,
         n641, n642, n643, n644, n645, n646, n647, n648, n649, n650, n651,
         n652, n653, n654, n655, n656, n657, n658, n659, n660, n661, n662,
         n663, n664, n665, n666, n667, n668, n669, n670, n671, n672, n673,
         n674, n675, n676, n677, n678, n679, n680, n681, n682, n683, n684,
         n685, n686, n687, n688, n689, n690, n691, n692, n693, n694, n695,
         n696, n697, n698, n699, n700, n701, n702, n703, n704, n705, n706,
         n707, n708, n709, n710, n711, n712, n713, n714, n715, n716, n717,
         n718, n719, n720, n721, n722, n723, n724, n725, n726, n727, n728,
         n729, n730, n731, n732, n733, n734, n735, n736, n737, n738, n739,
         n740, n741, n742, n743, n744, n745, n746, n747, n748, n749, n750,
         n751, n752, n753, n754, n755, n756, n757, n758, n759, n760, n761,
         n762, n763, n764, n765, n766, n767, n768, n769, n770, n771, n772,
         n773, n774, n775, n776, n777, n778, n779, n780, n781, n782, n783,
         n784, n785, n786, n787, n788, n789, n790, n791, n792, n793, n794,
         n795, n796, n797, n798, n799, n800, n801, n802, n803, n804, n805,
         n806, n807, n808, n809, n810, n811, n812, n813, n814, n815, n816,
         n817, n818, n819, n820, n821, n822, n823, n824, n825, n826, n827,
         n828, n1, n2, n3, n4, n6, n7, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153, n154, n155,
         n156, n157, n158, n159, n160, n161, n162, n163, n164, n165, n166,
         n167, n168, n169, n170, n171, n172, n173, n174, n175, n176, n177,
         n178, n179, n180, n181, n182, n183, n184, n185, n186, n187, n188,
         n189, n190, n191, n192, n193, n194, n195, n196, n197, n198, n199,
         n200, n201, n202, n203, n204, n205, n206, n207, n208, n209, n210,
         n211, n212, n213, n214, n215, n216, n217, n218, n219, n220, n221,
         n222, n223, n224, n225, n226, n227, n228, n229, n230, n231, n232,
         n233, n234, n235, n236, n237, n238, n239, n240, n241, n242, n243,
         n244, n245, n246, n247, n248, n249, n250, n251, n252, n253, n254,
         n255, n256, n257, n258, n259, n260, n261, n262, n263, n264, n265,
         n266, n267, n268, n269, n270, n271, n272, n273, n274, n275, n276,
         n277, n279, n280, n281, n282, n284, n285, n286, n287, n288, n289,
         n290, n291, n292, n293, n294, n295, n296, n297, n298, n299, n300,
         n301, n302, n303, n304, n305, n306, n307, n308, n309, n310, n311,
         n312, n313, n314, n315, n316, n317, n318, n319, n320, n321, n322,
         n323, n324, n325, n326, n327, n328, n329, n330, n331, n332, n333,
         n334, n335, n336, n337, n338, n339, n340, n341, n342, n343, n344,
         n345, n346, n347, n348, n349, n350, n351, n352, n353, n354, n355,
         n356, n357, n358, n359, n360, n361, n362, n363, n364, n365, n366,
         n367, n368, n369, n370, n371, n372, n373, n374, n375, n376, n377,
         n378, n379, n380, n381, n382, n383, n384, n385, n386, n387, n388,
         n389, n390, n391, n392, n393, n394, n395, n396, n397, n398, n399,
         n400, n401, n402, n403, n404, n405, n406, n407, n408, n409, n410,
         n411, n412, n413, n414, n415, n416, n417, n418, n419, n420, n422,
         n423, n424, n425, n426, n427, n430, n431, n432, n433, n434, n435,
         n436, n437, n438, n439, n440, n441, n442, n443, n444, n445, n446,
         n447, n448, n449, n450, n451, n452, n453, n454, n455, n456, n457,
         n458, n459, n460, n461, n462, n463, n464, n465, n466, n467, n468,
         n469, n470, n471, n472, n473, n474, n475, n476, n477, n478, n479,
         n480, n481, n482, n483, n484, n485, n486, n487, n488, n489, n490,
         n491, n492, n493, n494, n495, n496, n497, n498, n499, n500, n501,
         n502, n503, n504, n505, n506, n507, n508, n509, n510, n511, n512,
         n513, n514, n515, n516, n517, n518, n519, n520, n521, n522, n523,
         n524, n525, n526, n527, n528, n529, n530, n531, n532, n533, n534,
         n535, n536, n537, n538, n539, n540, n541, n542, n543, n544, n545,
         n546, n547, n548, n549, n550, n551, n552, n553, n554, n555, n556,
         n557, n558, n559, n560, n561, n562, n563, n564, n565, n566, n567,
         n568, n569, n570, n571, n572, n573, n574, n575, n576, n577, n578,
         n579, n580, n581, n582, n583, n584, n585, n586, n587, n588, n589,
         n590, n591, n592, n593, n594, n595, n596, n597, n598, n599, n600,
         n601, n602, n603, n604, n605, n606, n607, n608, n609, n610, n611,
         n612, n613, n614, n615, n616, n617, n618, n619, n620, n621, n622,
         n623, n624, n829, n830, n831, n832, n833, n834, n835, n836, n837,
         n838, n839, n840, n841, n842, n843, n844, n845, n846, n847, n848,
         n849, n850, n851, n852, n853, n854, n855, n856, n857, n858, n859,
         n860, n861, n862, n863, n864, n865, n866, n867, n868, n869, n870,
         n871, n872, n873, n874, n875, n876, n877, n878, n879, n880, n881,
         n882, n883, n884, n885, n886, n887, n888, n889, n890, n891, n892,
         n893, n894, n895, n896, n897, n898, n899, n900, n901, n902, n903,
         n904, n905, n906, n907, n908, n909, n910, n911, n912, n913, n914,
         n915, n916, n917, n918, n919, n920, n921, n922, n923, n924, n925,
         n926, n927, n928, n929, n930, n931, n932, n933, n934, n935, n936,
         n937, n938, n939, n940, n941, n942, n943, n944, n945, n946, n947,
         n948, n949, n950, n951, n952, n953, n954, n955, n956, n957, n958,
         n959, n960, n961, n962, n963, n964, n965, n966, n967, n968, n969,
         n970, n971, n972, n973, n974, n975, n976, n977, n978, n979, n980,
         n981, n982, n983, n984, n985, n986, n987, n988, n989, n990, n991,
         n992, n993, n994, n995, n996, n997, n998, n999, n1000, n1001, n1002,
         n1003, n1004, n1005, n1006, n1007, n1008, n1009, n1010, n1011, n1012,
         n1013, n1014, n1015, n1016, n1017, n1018, n1019, n1020, n1021, n1022,
         n1023, n1024, n1025, n1026, n1027, n1028, n1029, n1030, n1031, n1032,
         n1033, n1034, n1035, n1036, n1037, n1038, n1039, n1040, n1041, n1042,
         n1043, n1044, n1045, n1046, n1047, n1048, n1049, n1050, n1051, n1052,
         n1053, n1054, n1055, n1056, n1057, n1058, n1059, n1060, n1061, n1062,
         n1063, n1064, n1065, n1066, n1067, n1068, n1069, n1070, n1071, n1072,
         n1073, n1074, n1075, n1076, n1077, n1078, n1079, n1080, n1081, n1082,
         n1083, n1084, n1085, n1086, n1087, n1088, n1089, n1090, n1091, n1092,
         n1093, n1094, n1095, n1096, n1097, n1098, n1099, n1100, n1101, n1102,
         n1103, n1104, n1105, n1106, n1107, n1108, n1109, n1110, n1111, n1112,
         n1113, n1114, n1115, n1116, n1117, n1118, n1119, n1120, n1121, n1122,
         n1123, n1124, n1125, n1126, n1127, n1128, n1129, n1130, n1131, n1132,
         n1133, n1134, n1135, n1136, n1137, n1138, n1139, n1140, n1141, n1142,
         n1143, n1144, n1145, n1146, n1147, n1148, n1149, n1150, n1151, n1152,
         n1153, n1154, n1155, n1156, n1157, n1158, n1159, n1160, n1161, n1162,
         n1163, n1164, n1165, n1166, n1167, n1168, n1169, n1170, n1171, n1172,
         n1173, n1174, n1175, n1176, n1177, n1178, n1179, n1180, n1181, n1182,
         n1183, n1184, n1185, n1186, n1187, n1188, n1189, n1190, n1191, n1192,
         n1193, n1194, n1195, n1196, n1197, n1198, n1199, n1200, n1201, n1202,
         n1203, n1204, n1205, n1206, n1207, n1208, n1209, n1210, n1211, n1212,
         n1213, n1214, n1215, n1216, n1217, n1218, n1219, n1220, n1221, n1222,
         n1223, n1224, n1225, n1226, n1227, n1228, n1229, n1230, n1231, n1232,
         n1233, n1234, n1235, n1236, n1237, n1238, n1239, n1240, n1241, n1242,
         n1243, n1244, n1245, n1246, n1247, n1248, n1249, n1250, n1251, n1252,
         n1253, n1254, n1255, n1256, n1257, n1258, n1259, n1260, n1261, n1262,
         n1263, n1264, n1265, n1266, n1267, n1268, n1269, n1270, n1271, n1272,
         n1273, n1274, n1275, n1276, n1277, n1278, n1279, n1280, n1281, n1282,
         n1283, n1284, n1285, n1286, n1287, n1288, n1289, n1290, n1291, n1292,
         n1293, n1294, n1295, n1296, n1297, n1298, n1299, n1300, n1301, n1302,
         n1303, n1304, n1305, n1306, n1307, n1308, n1309, n1310, n1311, n1312,
         n1313, n1314, n1315, n1316, n1317, n1318, n1319, n1320, n1321, n1322,
         n1323, n1324, n1325, n1326, n1327, n1328, n1329, n1330, n1331, n1332,
         n1333, n1334, n1335, n1336, n1337, n1338, n1339, n1340, n1341, n1342,
         n1343, n1344, n1345, n1346, n1347, n1348, n1349, n1350, n1351, n1352,
         n1353, n1354, n1355, n1356, n1357, n1358, n1359, n1360, n1361, n1362,
         n1363, n1364, n1365, n1366, n1367, n1368, n1369, n1370, n1371, n1372,
         n1373, n1374, n1375, n1376, n1377, n1378, n1379, n1380, n1381, n1382,
         n1383, n1384, n1385, n1386, n1387, n1388, n1389, n1390, n1391, n1392,
         n1393, n1394, n1395, n1396, n1397, n1398, n1399, n1400, n1401, n1402,
         n1403, n1404, n1405, n1406, n1407, n1408, n1409, n1410, n1411, n1412,
         n1413, n1414, n1415, n1416, n1417, n1418, n1419, n1420, n1421, n1422,
         n1423, n1424, n1425, n1426, n1427, n1428, n1429, n1430, n1431, n1432,
         n1433, n1434, n1435, n1436, n1437, n1438, n1439, n1440, n1441, n1442,
         n1443, n1444, n1445, n1446, n1447, n1448, n1449, n1450, n1451, n1452,
         n1453, n1454, n1455, n1456, n1457, n1458, n1459, n1460, n1461, n1462,
         n1463, n1464, n1465, n1466, n1467, n1468, n1469, n1470, n1471, n1472,
         n1473, n1474, n1475, n1476, n1477, n1478, n1479, n1480, n1481, n1482,
         n1483, n1484, n1485, n1486, n1487, n1488, n1489, n1490, n1491, n1492,
         n1493, n1494, n1495, n1496, n1497, n1498, n1499, n1500, n1501, n1502,
         n1503, n1504, n1505, n1506, n1507, n1508, n1509, n1510, n1511, n1512,
         n1513, n1514, n1515, n1516, n1517, n1518, n1519, n1520, n1521, n1522,
         n1523, n1524, n1525, n1526, n1527, n1528, n1529, n1530, n1531, n1532,
         n1533, n1534, n1535, n1536, n1537, n1538, n1539, n1540, n1541, n1542,
         n1543, n1544, n1545, n1546, n1547, n1548, n1549, n1550, n1551, n1552,
         n1553, n1554, n1555, n1556, n1557, n1558, n1559, n1560, n1561, n1562,
         n1563, n1564, n1565, n1566, n1567, n1568, n1569, n1570, n1571, n1572,
         n1573, n1574, n1575, n1576, n1577, n1578, n1579, n1580, n1581, n1582,
         n1583, n1584, n1585, n1586, n1587, n1588, n1589, n1590, n1591, n1592,
         n1593, n1594, n1595, n1596, n1597, n1598, n1599, n1600, n1601, n1602,
         n1603, n1604, n1605, n1606, n1607, n1608, n1609, n1610, n1611, n1612,
         n1613, n1614, n1615, n1616, n1617, n1618, n1619, n1620, n1621, n1622,
         n1623, n1624, n1625, n1626, n1627, n1628, n1629, n1630, n1631, n1632,
         n1633, n1634, n1635, n1636, n1637, n1638, n1639, n1640, n1641, n1642,
         n1643, n1644, n1645, n1646, n1647, n1648, n1649, n1650, n1651, n1652,
         n1653, n1654, n1655, n1656, n1657, n1658, n1659, n1660, n1661, n1662,
         n1663, n1664, n1665, n1666, n1667, n1668, n1669, n1670, n1671, n1672,
         n1673, n1674, n1675, n1676, n1677, n1678, n1679, n1680, n1681, n1682,
         n1683, n1684, n1685, n1686, n1687, n1688, n1689, n1690, n1691, n1692,
         n1693, n1694, n1695, n1696, n1697, n1698, n1699, n1700, n1701, n1702,
         n1703, n1704, n1705, n1706, n1707, n1708, n1709, n1710, n1711, n1712,
         n1713, n1714, n1715, n1716, n1717, n1718, n1719, n1720, n1721, n1722,
         n1723, n1724, n1725, n1726, n1727, n1728, n1729, n1730, n1731, n1732,
         n1733, n1734, n1735, n1736, n1737, n1738, n1739, n1740, n1741, n1742,
         n1743, n1744, n1745, n1746, n1747, n1748, n1749, n1750, n1751, n1752,
         n1753, n1754, n1755, n1756, n1757, n1758, n1759, n1760, n1761, n1762,
         n1763, n1764, n1765, n1766, n1767, n1768, n1769, n1770, n1771, n1772,
         n1773, n1774, n1775, n1776, n1777, n1778, n1779, n1780, n1781, n1782,
         n1783, n1784, n1785, n1786, n1787, n1788, n1789, n1790, n1791, n1792,
         n1793, n1794, n1795, n1796, n1797, n1798, n1799, n1800, n1801, n1802,
         n1803, n1804, n1805, n1806, n1807, n1808, n1809, n1810, n1811, n1812,
         n1813, n1814, n1815, n1816, n1817, n1818, n1819, n1820, n1821, n1822,
         n1823, n1824, n1825, n1826, n1827, n1828, n1829, n1830, n1831, n1832,
         n1833, n1834, n1835, n1836, n1837, n1838, n1839, n1840, n1841, n1842,
         n1843, n1844, n1845, n1846, n1847, n1848, n1849, n1850, n1851, n1852,
         n1853, n1854, n1855, n1856, n1857, n1858, n1859, n1860, n1861, n1862,
         n1863, n1864, n1865, n1866, n1867, n1868, n1869, n1870, n1871, n1872,
         n1873, n1874, n1875, n1876, n1877, n1878, n1879, n1880, n1881, n1882,
         n1883, n1884, n1885, n1886, n1887, n1888, n1889, n1890, n1891, n1892,
         n1893, n1894, n1895, n1896, n1897, n1898, n1899, n1900, n1901, n1902,
         n1903, n1904, n1905, n1906, n1907, n1908, n1909, n1910, n1911, n1912,
         n1913, n1914, n1915, n1916, n1917, n1918, n1919, n1920, n1921, n1922,
         n1923, n1924, n1925, n1926, n1927, n1928, n1929, n1930, n1931, n1932,
         n1933, n1934, n1935, n1936, n1937, n1938, n1939, n1940, n1941, n1942,
         n1943, n1944, n1945, n1946, n1947, n1948, n1949, n1950, n1951, n1952,
         n1953, n1954, n1955, n1956, n1957, n1958, n1959, n1960, n1961, n1962,
         n1963, n1964, n1965, n1966, n1967, n1968, n1969, n1970, n1971, n1972,
         n1973, n1974, n1975, n1976, n1977, n1978, n1979, n1980, n1981, n1982,
         n1983, n1984, n1985, n1986, n1987, n1988, n1989, n1990, n1991, n1992,
         n1993, n1994, n1995, n1996, n1997, n1998, n1999, n2000, n2001, n2002,
         n2003, n2004, n2005, n2006, n2007, n2008, n2009, n2010, n2011, n2012,
         n2013, n2014, n2015, n2016, n2017, n2018, n2019, n2020, n2021, n2022,
         n2023, n2024, n2025, n2026, n2027, n2028, n2029, n2030, n2031, n2032,
         n2033, n2034, n2035, n2036, n2037, n2038, n2039, n2040, n2041, n2042,
         n2043, n2044, n2045, n2046, n2047, n2048, n2049, n2050, n2051, n2052,
         n2053, n2054, n2055, n2056, n2057, n2058, n2059, n2060, n2061, n2062,
         n2063, n2064, n2065, n2066, n2067, n2068, n2069, n2070, n2071, n2072,
         n2073, n2074, n2075, n2076, n2077, n2078, n2079, n2080, n2081, n2082,
         n2083, n2084, n2085, n2086, n2087, n2088, n2089, n2090, n2091, n2092,
         n2093, n2094, n2095, n2096, n2097, n2098, n2099, n2100, n2101, n2102,
         n2103, n2104, n2105, n2106, n2107, n2108, n2109, n2110, n2111, n2112,
         n2113, n2114, n2115, n2116, n2117, n2118, n2119, n2120, n2121, n2122,
         n2123, n2124, n2125, n2126, n2127, n2128, n2129, n2130, n2131, n2132,
         n2133, n2134, n2135, n2136, n2137, n2138, n2139, n2140, n2141, n2142,
         n2143, n2144, n2145, n2146, n2147, n2148, n2149, n2150, n2151, n2152,
         n2153, n2154, n2155, n2156, n2157, n2158, n2159, n2160, n2161, n2162,
         n2163, n2164, n2165, n2166, n2167, n2168, n2169, n2170, n2171, n2172,
         n2173, n2174, n2175, n2176, n2177, n2178, n2179, n2180, n2181, n2182,
         n2183, n2184, n2185, n2186, n2187, n2188, n2189, n2190, n2191, n2192,
         n2193, n2194, n2195, n2196, n2197, n2198, n2199, n2200, n2201, n2202,
         n2203, n2204, n2205, n2206, n2207, n2208, n2209, n2210, n2211, n2212,
         n2213, n2214, n2215, n2216, n2217, n2218, n2219, n2220, n2221, n2222,
         n2223, n2224, n2225, n2226, n2227, n2228, n2229, n2230, n2231, n2232,
         n2233, n2234, n2235, n2236, n2237, n2238, n2239, n2240, n2241, n2242,
         n2243, n2244, n2245, n2246, n2247, n2248, n2249, n2250, n2251, n2252,
         n2253, n2254, n2255, n2256, n2257, n2258, n2259, n2260, n2261, n2262,
         n2263, n2264, n2265, n2266, n2267, n2268, n2269, n2270, n2271, n2272,
         n2273, n2274, n2275, n2276, n2277, n2278, n2279, n2280, n2281, n2282,
         n2283, n2284, n2285, n2286, n2287, n2288, n2289, n2290, n2291, n2292,
         n2293, n2294, n2295, n2296, n2297, n2298, n2299, n2300, n2301, n2302,
         n2303, n2304, n2305, n2306, n2307, n2308, n2309, n2310, n2311, n2312,
         n2313, n2314, n2315, n2316, n2317, n2318, n2319, n2320, n2321, n2322,
         n2323, n2324, n2325, n2326, n2327, n2328, n2329, n2330, n2331, n2332,
         n2333, n2334, n2335, n2336, n2337, n2338, n2339, n2340, n2341, n2342,
         n2343, n2344, n2345, n2346, n2347, n2348, n2349, n2350, n2351, n2352,
         n2353, n2354, n2355, n2356, n2357, n2358, n2359, n2360, n2361, n2362,
         n2363, n2364, n2365, n2366, n2367, n2368, n2369, n2370, n2371, n2372,
         n2373, n2374, n2375, n2376, n2377, n2378, n2379, n2380, n2381, n2382,
         n2383, n2384, n2385, n2386, n2387, n2388, n2389, n2390, n2391, n2392,
         n2393, n2394, n2395, n2396, n2397, n2398, n2399, n2400, n2401, n2402,
         n2403, n2404, n2405, n2406, n2407, n2408, n2409, n2410, n2411, n2412,
         n2413, n2414, n2415, n2416, n2417, n2418, n2419, n2420, n2421, n2422,
         n2423, n2424, n2425, n2426, n2427, n2428, n2429, n2430, n2431, n2432,
         n2433, n2434, n2435, n2436, n2437, n2438, n2439, n2440, n2441, n2442,
         n2443, n2444, n2445, n2446, n2447, n2448, n2449, n2450, n2451, n2452,
         n2453, n2454, n2455, n2456, n2457, n2458, n2459, n2460, n2461, n2462,
         n2463, n2464, n2465, n2466, n2467, n2468, n2469, n2470, n2471, n2472,
         n2473, n2474, n2475, n2476, n2477, n2478, n2479, n2480, n2481, n2482,
         n2483, n2484, n2485, n2486, n2487, n2488, n2489, n2490, n2491, n2492,
         n2493, n2494, n2495, n2496, n2497, n2498, n2499, n2500, n2501, n2502,
         n2503, n2504, n2505, n2506, n2507, n2508, n2509, n2510, n2511, n2512,
         n2513, n2514, n2515, n2516, n2517, n2518, n2519, n2520, n2521, n2522,
         n2523, n2524, n2525, n2526, n2527, n2528, n2529, n2530, n2531, n2532,
         n2533, n2534, n2535, n2536, n2537, n2538, n2539, n2540, n2541, n2542,
         n2543, n2544, n2545, n2546, n2547, n2548, n2549, n2550, n2551, n2552,
         n2553, n2554, n2555, n2556, n2557, n2558, n2559, n2560, n2561, n2562,
         n2563, n2564, n2565, n2566, n2567, n2568, n2569, n2570, n2571, n2572,
         n2573, n2574, n2575, n2576, n2577, n2578, n2579, n2580, n2581, n2582,
         n2583, n2584, n2585, n2586, n2587, n2588, n2589, n2590, n2591, n2592,
         n2593, n2594, n2595, n2596, n2597, n2598, n2599, n2600, n2601, n2602,
         n2603, n2604, n2605, n2606, n2607, n2608, n2609, n2610, n2611, n2612,
         n2613, n2614, n2615, n2616, n2617, n2618, n2619, n2620, n2621, n2622,
         n2623, n2624, n2625, n2626, n2627, n2628, n2629, n2630, n2631, n2632,
         n2633, n2634, n2635, n2636, n2637, n2638, n2639, n2640, n2641, n2642,
         n2643, n2644, n2645, n2646, n2647, n2648, n2649, n2650, n2651, n2652,
         n2653, n2654, n2655, n2656, n2657, n2658, n2659, n2660, n2661, n2662,
         n2663, n2664, n2665, n2666, n2667, n2668, n2669, n2670, n2671, n2672,
         n2673, n2674, n2675, n2676, n2677, n2678, n2679, n2680, n2681, n2682,
         n2683, n2684, n2685, n2686, n2687, n2688, n2689, n2690, n2691, n2692,
         n2693, n2694, n2695, n2696, n2697, n2698, n2699, n2700, n2701, n2702,
         n2703, n2704, n2705, n2706, n2707, n2708, n2709, n2710, n2711, n2712,
         n2713, n2714, n2715, n2716, n2717, n2718, n2719, n2720, n2721, n2722,
         n2723, n2724, n2725, n2726, n2727, n2728, n2729, n2730, n2731, n2732,
         n2733, n2734, n2735, n2736, n2737, n2738, n2739, n2740, n2741, n2742,
         n2743, n2744, n2745, n2746, n2747, n2748, n2749, n2750, n2751, n2752,
         n2753, n2754, n2755, n2756, n2757, n2758, n2759, n2760, n2761, n2762,
         n2763, n2764, n2765, n2766, n2767, n2768;
  wire   [2047:0] oam;
  wire   [8:3] spr_y_coord;
  wire   [1:0] state;
  wire   [1:0] oam_inc;
  wire   [2:0] p;
  wire   SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2;

  sky130_fd_sc_hd__edfxbp_1 state_reg_0_ ( .D(n2766), .DE(n421), .CLK(clk), 
        .Q(state[0]), .Q_N(n283) );
  sky130_fd_sc_hd__dlxtp_1 oam_inc_reg_1_ ( .GATE(n425), .D(n427), .Q(
        oam_inc[1]) );
  sky130_fd_sc_hd__dlxtp_1 oam_inc_reg_0_ ( .GATE(n425), .D(n2765), .Q(
        oam_inc[0]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__1_ ( .D(n2402), .DE(n210), .CLK(clk), 
        .Q(oam[737]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__2_ ( .D(n2418), .DE(n210), .CLK(clk), 
        .Q(oam[738]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__3_ ( .D(n2424), .DE(n210), .CLK(clk), 
        .Q(oam[739]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__4_ ( .D(n2430), .DE(n210), .CLK(clk), 
        .Q(oam[740]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__5_ ( .D(n2436), .DE(n210), .CLK(clk), 
        .Q(oam[741]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__6_ ( .D(n2452), .DE(n210), .CLK(clk), 
        .Q(oam[742]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__7_ ( .D(n2468), .DE(n210), .CLK(clk), 
        .Q(oam[743]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_163__0_ ( .D(n2386), .DE(n210), .CLK(clk), 
        .Q(oam[736]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__1_ ( .D(n2403), .DE(n209), .CLK(clk), 
        .Q(oam[609]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__2_ ( .D(n2420), .DE(n209), .CLK(clk), 
        .Q(oam[610]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__3_ ( .D(n2425), .DE(n209), .CLK(clk), 
        .Q(oam[611]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__4_ ( .D(n2431), .DE(n209), .CLK(clk), 
        .Q(oam[612]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__5_ ( .D(n2437), .DE(n209), .CLK(clk), 
        .Q(oam[613]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__6_ ( .D(n2453), .DE(n209), .CLK(clk), 
        .Q(oam[614]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__7_ ( .D(n2469), .DE(n209), .CLK(clk), 
        .Q(oam[615]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_179__0_ ( .D(n2387), .DE(n209), .CLK(clk), 
        .Q(oam[608]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__1_ ( .D(n2404), .DE(n98), .CLK(clk), 
        .Q(oam[481]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__2_ ( .D(n2420), .DE(n98), .CLK(clk), 
        .Q(oam[482]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__3_ ( .D(n2426), .DE(n98), .CLK(clk), 
        .Q(oam[483]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__4_ ( .D(n2432), .DE(n98), .CLK(clk), 
        .Q(oam[484]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__5_ ( .D(n2438), .DE(n98), .CLK(clk), 
        .Q(oam[485]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__6_ ( .D(n2454), .DE(n98), .CLK(clk), 
        .Q(oam[486]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__7_ ( .D(n2470), .DE(n98), .CLK(clk), 
        .Q(oam[487]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_195__0_ ( .D(n2388), .DE(n98), .CLK(clk), 
        .Q(oam[480]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__1_ ( .D(n2400), .DE(n100), .CLK(clk), 
        .Q(oam[353]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__2_ ( .D(n2416), .DE(n100), .CLK(clk), 
        .Q(oam[354]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__3_ ( .D(n2425), .DE(n100), .CLK(clk), 
        .Q(oam[355]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__4_ ( .D(n2431), .DE(n100), .CLK(clk), 
        .Q(oam[356]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__5_ ( .D(n2434), .DE(n100), .CLK(clk), 
        .Q(oam[357]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__6_ ( .D(n2450), .DE(n100), .CLK(clk), 
        .Q(oam[358]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__7_ ( .D(n2466), .DE(n100), .CLK(clk), 
        .Q(oam[359]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_211__0_ ( .D(n2384), .DE(n100), .CLK(clk), 
        .Q(oam[352]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__1_ ( .D(n2410), .DE(n207), .CLK(clk), 
        .Q(oam[225]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__2_ ( .D(n2419), .DE(n207), .CLK(clk), 
        .Q(oam[226]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__3_ ( .D(n2426), .DE(n207), .CLK(clk), 
        .Q(oam[227]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__4_ ( .D(n2432), .DE(n207), .CLK(clk), 
        .Q(oam[228]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__5_ ( .D(n2437), .DE(n207), .CLK(clk), 
        .Q(oam[229]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__6_ ( .D(n2453), .DE(n207), .CLK(clk), 
        .Q(oam[230]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__7_ ( .D(n2469), .DE(n207), .CLK(clk), 
        .Q(oam[231]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_227__0_ ( .D(n2387), .DE(n207), .CLK(clk), 
        .Q(oam[224]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__1_ ( .D(n2410), .DE(n208), .CLK(clk), 
        .Q(oam[97]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__2_ ( .D(n2416), .DE(n208), .CLK(clk), 
        .Q(oam[98]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__3_ ( .D(n2422), .DE(n208), .CLK(clk), 
        .Q(oam[99]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__4_ ( .D(n2428), .DE(n208), .CLK(clk), 
        .Q(oam[100]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__5_ ( .D(n2443), .DE(n208), .CLK(clk), 
        .Q(oam[101]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__6_ ( .D(n2459), .DE(n208), .CLK(clk), 
        .Q(oam[102]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__7_ ( .D(n2475), .DE(n208), .CLK(clk), 
        .Q(oam[103]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_243__0_ ( .D(n2393), .DE(n208), .CLK(clk), 
        .Q(oam[96]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__1_ ( .D(n2410), .DE(n143), .CLK(clk), 
        .Q(oam[2017]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__2_ ( .D(n2420), .DE(n143), .CLK(clk), 
        .Q(oam[2018]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__3_ ( .D(n2426), .DE(n143), .CLK(clk), 
        .Q(oam[2019]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__4_ ( .D(n2432), .DE(n143), .CLK(clk), 
        .Q(oam[2020]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__5_ ( .D(n2435), .DE(n143), .CLK(clk), 
        .Q(oam[2021]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__6_ ( .D(n2450), .DE(n143), .CLK(clk), 
        .Q(oam[2022]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__7_ ( .D(n2467), .DE(n143), .CLK(clk), 
        .Q(oam[2023]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_3__0_ ( .D(n2385), .DE(n143), .CLK(clk), 
        .Q(oam[2016]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__1_ ( .D(n2410), .DE(n171), .CLK(clk), 
        .Q(oam[1889]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__2_ ( .D(n2417), .DE(n171), .CLK(clk), 
        .Q(oam[1890]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__3_ ( .D(n2423), .DE(n171), .CLK(clk), 
        .Q(oam[1891]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__4_ ( .D(n2429), .DE(n171), .CLK(clk), 
        .Q(oam[1892]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__5_ ( .D(n2442), .DE(n171), .CLK(clk), 
        .Q(oam[1893]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__6_ ( .D(n2455), .DE(n171), .CLK(clk), 
        .Q(oam[1894]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__7_ ( .D(n2474), .DE(n171), .CLK(clk), 
        .Q(oam[1895]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_19__0_ ( .D(n2392), .DE(n171), .CLK(clk), 
        .Q(oam[1888]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__1_ ( .D(n2410), .DE(n123), .CLK(clk), 
        .Q(oam[1761]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__2_ ( .D(n2416), .DE(n123), .CLK(clk), 
        .Q(oam[1762]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__3_ ( .D(n2422), .DE(n123), .CLK(clk), 
        .Q(oam[1763]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__4_ ( .D(n2428), .DE(n123), .CLK(clk), 
        .Q(oam[1764]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__5_ ( .D(n2434), .DE(n123), .CLK(clk), 
        .Q(oam[1765]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__6_ ( .D(n2450), .DE(n123), .CLK(clk), 
        .Q(oam[1766]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__7_ ( .D(n2466), .DE(n123), .CLK(clk), 
        .Q(oam[1767]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_35__0_ ( .D(n2384), .DE(n123), .CLK(clk), 
        .Q(oam[1760]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__1_ ( .D(n2410), .DE(n206), .CLK(clk), 
        .Q(oam[1633]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__2_ ( .D(n2417), .DE(n206), .CLK(clk), 
        .Q(oam[1634]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__3_ ( .D(n2423), .DE(n206), .CLK(clk), 
        .Q(oam[1635]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__4_ ( .D(n2429), .DE(n206), .CLK(clk), 
        .Q(oam[1636]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__5_ ( .D(n2435), .DE(n206), .CLK(clk), 
        .Q(oam[1637]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__6_ ( .D(n2451), .DE(n206), .CLK(clk), 
        .Q(oam[1638]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__7_ ( .D(n2467), .DE(n206), .CLK(clk), 
        .Q(oam[1639]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_51__0_ ( .D(n2385), .DE(n206), .CLK(clk), 
        .Q(oam[1632]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__1_ ( .D(n2410), .DE(n257), .CLK(clk), 
        .Q(oam[1505]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__2_ ( .D(n2418), .DE(n257), .CLK(clk), 
        .Q(oam[1506]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__3_ ( .D(n2424), .DE(n257), .CLK(clk), 
        .Q(oam[1507]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__4_ ( .D(n2430), .DE(n257), .CLK(clk), 
        .Q(oam[1508]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__5_ ( .D(n2440), .DE(n257), .CLK(clk), 
        .Q(oam[1509]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__6_ ( .D(data_in[6]), .DE(n257), .CLK(
        clk), .Q(oam[1510]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__7_ ( .D(n2472), .DE(n257), .CLK(clk), 
        .Q(oam[1511]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_67__0_ ( .D(n2390), .DE(n257), .CLK(clk), 
        .Q(oam[1504]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__1_ ( .D(n2410), .DE(n256), .CLK(clk), 
        .Q(oam[1377]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__2_ ( .D(n2417), .DE(n256), .CLK(clk), 
        .Q(oam[1378]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__3_ ( .D(n2423), .DE(n256), .CLK(clk), 
        .Q(oam[1379]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__4_ ( .D(n2429), .DE(n256), .CLK(clk), 
        .Q(oam[1380]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__5_ ( .D(n2439), .DE(n256), .CLK(clk), 
        .Q(oam[1381]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__6_ ( .D(n2456), .DE(n256), .CLK(clk), 
        .Q(oam[1382]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__7_ ( .D(n2471), .DE(n256), .CLK(clk), 
        .Q(oam[1383]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_83__0_ ( .D(n2389), .DE(n256), .CLK(clk), 
        .Q(oam[1376]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__1_ ( .D(n2410), .DE(n267), .CLK(clk), 
        .Q(oam[1249]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__2_ ( .D(n2419), .DE(n267), .CLK(clk), 
        .Q(oam[1250]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__3_ ( .D(n2423), .DE(n267), .CLK(clk), 
        .Q(oam[1251]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__4_ ( .D(n2429), .DE(n267), .CLK(clk), 
        .Q(oam[1252]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__5_ ( .D(n2438), .DE(n267), .CLK(clk), 
        .Q(oam[1253]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__6_ ( .D(n2454), .DE(n267), .CLK(clk), 
        .Q(oam[1254]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__7_ ( .D(n2470), .DE(n267), .CLK(clk), 
        .Q(oam[1255]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_99__0_ ( .D(n2388), .DE(n267), .CLK(clk), 
        .Q(oam[1248]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__1_ ( .D(n2410), .DE(n144), .CLK(clk), 
        .Q(oam[1121]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__2_ ( .D(n2420), .DE(n144), .CLK(clk), 
        .Q(oam[1122]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__3_ ( .D(n2426), .DE(n144), .CLK(clk), 
        .Q(oam[1123]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__4_ ( .D(n2432), .DE(n144), .CLK(clk), 
        .Q(oam[1124]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__5_ ( .D(n2436), .DE(n144), .CLK(clk), 
        .Q(oam[1125]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__6_ ( .D(n2452), .DE(n144), .CLK(clk), 
        .Q(oam[1126]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__7_ ( .D(n2468), .DE(n144), .CLK(clk), 
        .Q(oam[1127]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_115__0_ ( .D(n2386), .DE(n144), .CLK(clk), 
        .Q(oam[1120]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__1_ ( .D(n2410), .DE(n169), .CLK(clk), 
        .Q(oam[993]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__2_ ( .D(n2416), .DE(n169), .CLK(clk), 
        .Q(oam[994]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__3_ ( .D(n2422), .DE(n169), .CLK(clk), 
        .Q(oam[995]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__4_ ( .D(n2428), .DE(n169), .CLK(clk), 
        .Q(oam[996]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__5_ ( .D(n2441), .DE(n169), .CLK(clk), 
        .Q(oam[997]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__6_ ( .D(n2458), .DE(n169), .CLK(clk), 
        .Q(oam[998]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__7_ ( .D(n2473), .DE(n169), .CLK(clk), 
        .Q(oam[999]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_131__0_ ( .D(n2391), .DE(n169), .CLK(clk), 
        .Q(oam[992]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__1_ ( .D(n2410), .DE(n168), .CLK(clk), 
        .Q(oam[865]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__2_ ( .D(n2419), .DE(n168), .CLK(clk), 
        .Q(oam[866]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__3_ ( .D(n2422), .DE(n168), .CLK(clk), 
        .Q(oam[867]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__4_ ( .D(n2428), .DE(n168), .CLK(clk), 
        .Q(oam[868]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__5_ ( .D(n2434), .DE(n168), .CLK(clk), 
        .Q(oam[869]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__6_ ( .D(n2457), .DE(n168), .CLK(clk), 
        .Q(oam[870]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__7_ ( .D(n2466), .DE(n168), .CLK(clk), 
        .Q(oam[871]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_147__0_ ( .D(n2384), .DE(n168), .CLK(clk), 
        .Q(oam[864]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__1_ ( .D(n2410), .DE(n266), .CLK(clk), 
        .Q(oam[705]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__2_ ( .D(n2418), .DE(n266), .CLK(clk), 
        .Q(oam[706]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__3_ ( .D(n2424), .DE(n266), .CLK(clk), 
        .Q(oam[707]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__4_ ( .D(n2430), .DE(n266), .CLK(clk), 
        .Q(oam[708]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__5_ ( .D(n2442), .DE(n266), .CLK(clk), 
        .Q(oam[709]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__6_ ( .D(n2458), .DE(n266), .CLK(clk), 
        .Q(oam[710]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__7_ ( .D(n2474), .DE(n266), .CLK(clk), 
        .Q(oam[711]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_167__0_ ( .D(n2392), .DE(n266), .CLK(clk), 
        .Q(oam[704]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__1_ ( .D(n2410), .DE(n265), .CLK(clk), 
        .Q(oam[577]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__2_ ( .D(n2417), .DE(n265), .CLK(clk), 
        .Q(oam[578]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__3_ ( .D(n2423), .DE(n265), .CLK(clk), 
        .Q(oam[579]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__4_ ( .D(n2429), .DE(n265), .CLK(clk), 
        .Q(oam[580]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__5_ ( .D(n2441), .DE(n265), .CLK(clk), 
        .Q(oam[581]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__6_ ( .D(n2457), .DE(n265), .CLK(clk), 
        .Q(oam[582]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__7_ ( .D(n2473), .DE(n265), .CLK(clk), 
        .Q(oam[583]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_183__0_ ( .D(n2391), .DE(n265), .CLK(clk), 
        .Q(oam[576]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__1_ ( .D(n2409), .DE(n233), .CLK(clk), 
        .Q(oam[449]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__2_ ( .D(n2416), .DE(n233), .CLK(clk), 
        .Q(oam[450]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__3_ ( .D(n2422), .DE(n233), .CLK(clk), 
        .Q(oam[451]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__4_ ( .D(n2428), .DE(n233), .CLK(clk), 
        .Q(oam[452]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__5_ ( .D(n2443), .DE(n233), .CLK(clk), 
        .Q(oam[453]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__6_ ( .D(n2459), .DE(n233), .CLK(clk), 
        .Q(oam[454]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__7_ ( .D(n2475), .DE(n233), .CLK(clk), 
        .Q(oam[455]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_199__0_ ( .D(n2393), .DE(n233), .CLK(clk), 
        .Q(oam[448]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__1_ ( .D(n2409), .DE(n232), .CLK(clk), 
        .Q(oam[321]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__2_ ( .D(n2417), .DE(n232), .CLK(clk), 
        .Q(oam[322]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__3_ ( .D(n2425), .DE(n232), .CLK(clk), 
        .Q(oam[323]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__4_ ( .D(n2431), .DE(n232), .CLK(clk), 
        .Q(oam[324]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__5_ ( .D(n2443), .DE(n232), .CLK(clk), 
        .Q(oam[325]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__6_ ( .D(n2459), .DE(n232), .CLK(clk), 
        .Q(oam[326]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__7_ ( .D(n2475), .DE(n232), .CLK(clk), 
        .Q(oam[327]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_215__0_ ( .D(n2393), .DE(n232), .CLK(clk), 
        .Q(oam[320]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__1_ ( .D(n2409), .DE(n264), .CLK(clk), 
        .Q(oam[193]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__2_ ( .D(n2420), .DE(n264), .CLK(clk), 
        .Q(oam[194]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__3_ ( .D(n2426), .DE(n264), .CLK(clk), 
        .Q(oam[195]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__4_ ( .D(n2432), .DE(n264), .CLK(clk), 
        .Q(oam[196]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__5_ ( .D(n2443), .DE(n264), .CLK(clk), 
        .Q(oam[197]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__6_ ( .D(n2459), .DE(n264), .CLK(clk), 
        .Q(oam[198]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__7_ ( .D(n2475), .DE(n264), .CLK(clk), 
        .Q(oam[199]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_231__0_ ( .D(n2393), .DE(n264), .CLK(clk), 
        .Q(oam[192]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__1_ ( .D(n2409), .DE(n263), .CLK(clk), 
        .Q(oam[65]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__2_ ( .D(data_in[2]), .DE(n263), .CLK(
        clk), .Q(oam[66]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__3_ ( .D(n2425), .DE(n263), .CLK(clk), 
        .Q(oam[67]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__4_ ( .D(n2431), .DE(n263), .CLK(clk), 
        .Q(oam[68]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__5_ ( .D(n2443), .DE(n263), .CLK(clk), 
        .Q(oam[69]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__6_ ( .D(n2459), .DE(n263), .CLK(clk), 
        .Q(oam[70]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__7_ ( .D(n2475), .DE(n263), .CLK(clk), 
        .Q(oam[71]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_247__0_ ( .D(n2393), .DE(n263), .CLK(clk), 
        .Q(oam[64]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__1_ ( .D(n2409), .DE(n150), .CLK(clk), 
        .Q(oam[1985]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__2_ ( .D(n2419), .DE(n150), .CLK(clk), 
        .Q(oam[1986]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__3_ ( .D(data_in[3]), .DE(n150), .CLK(
        clk), .Q(oam[1987]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__4_ ( .D(data_in[4]), .DE(n150), .CLK(
        clk), .Q(oam[1988]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__5_ ( .D(n2443), .DE(n150), .CLK(clk), 
        .Q(oam[1989]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__6_ ( .D(n2459), .DE(n150), .CLK(clk), 
        .Q(oam[1990]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__7_ ( .D(n2475), .DE(n150), .CLK(clk), 
        .Q(oam[1991]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_7__0_ ( .D(n2393), .DE(n150), .CLK(clk), 
        .Q(oam[1984]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__1_ ( .D(n2409), .DE(n186), .CLK(clk), 
        .Q(oam[1857]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__2_ ( .D(n2416), .DE(n186), .CLK(clk), 
        .Q(oam[1858]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__3_ ( .D(n2422), .DE(n186), .CLK(clk), 
        .Q(oam[1859]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__4_ ( .D(n2428), .DE(n186), .CLK(clk), 
        .Q(oam[1860]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__5_ ( .D(n2443), .DE(n186), .CLK(clk), 
        .Q(oam[1861]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__6_ ( .D(n2459), .DE(n186), .CLK(clk), 
        .Q(oam[1862]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__7_ ( .D(n2475), .DE(n186), .CLK(clk), 
        .Q(oam[1863]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_23__0_ ( .D(n2393), .DE(n186), .CLK(clk), 
        .Q(oam[1856]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__1_ ( .D(n2409), .DE(n261), .CLK(clk), 
        .Q(oam[1729]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__2_ ( .D(n2419), .DE(n261), .CLK(clk), 
        .Q(oam[1730]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__3_ ( .D(n2425), .DE(n261), .CLK(clk), 
        .Q(oam[1731]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__4_ ( .D(n2431), .DE(n261), .CLK(clk), 
        .Q(oam[1732]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__5_ ( .D(n2443), .DE(n261), .CLK(clk), 
        .Q(oam[1733]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__6_ ( .D(n2459), .DE(n261), .CLK(clk), 
        .Q(oam[1734]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__7_ ( .D(n2475), .DE(n261), .CLK(clk), 
        .Q(oam[1735]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_39__0_ ( .D(n2393), .DE(n261), .CLK(clk), 
        .Q(oam[1728]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__1_ ( .D(n2409), .DE(n260), .CLK(clk), 
        .Q(oam[1601]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__2_ ( .D(n2418), .DE(n260), .CLK(clk), 
        .Q(oam[1602]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__3_ ( .D(n2424), .DE(n260), .CLK(clk), 
        .Q(oam[1603]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__4_ ( .D(n2430), .DE(n260), .CLK(clk), 
        .Q(oam[1604]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__5_ ( .D(n2443), .DE(n260), .CLK(clk), 
        .Q(oam[1605]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__6_ ( .D(n2459), .DE(n260), .CLK(clk), 
        .Q(oam[1606]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__7_ ( .D(n2475), .DE(n260), .CLK(clk), 
        .Q(oam[1607]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_55__0_ ( .D(n2393), .DE(n260), .CLK(clk), 
        .Q(oam[1600]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__1_ ( .D(n2409), .DE(n259), .CLK(clk), 
        .Q(oam[1473]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__2_ ( .D(n2418), .DE(n259), .CLK(clk), 
        .Q(oam[1474]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__3_ ( .D(n2424), .DE(n259), .CLK(clk), 
        .Q(oam[1475]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__4_ ( .D(n2430), .DE(n259), .CLK(clk), 
        .Q(oam[1476]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__5_ ( .D(n2443), .DE(n259), .CLK(clk), 
        .Q(oam[1477]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__6_ ( .D(n2459), .DE(n259), .CLK(clk), 
        .Q(oam[1478]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__7_ ( .D(n2475), .DE(n259), .CLK(clk), 
        .Q(oam[1479]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_71__0_ ( .D(n2393), .DE(n259), .CLK(clk), 
        .Q(oam[1472]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__1_ ( .D(n2409), .DE(n258), .CLK(clk), 
        .Q(oam[1345]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__2_ ( .D(n2417), .DE(n258), .CLK(clk), 
        .Q(oam[1346]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__3_ ( .D(n2423), .DE(n258), .CLK(clk), 
        .Q(oam[1347]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__4_ ( .D(n2429), .DE(n258), .CLK(clk), 
        .Q(oam[1348]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__5_ ( .D(n2443), .DE(n258), .CLK(clk), 
        .Q(oam[1349]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__6_ ( .D(n2459), .DE(n258), .CLK(clk), 
        .Q(oam[1350]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__7_ ( .D(n2475), .DE(n258), .CLK(clk), 
        .Q(oam[1351]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_87__0_ ( .D(n2393), .DE(n258), .CLK(clk), 
        .Q(oam[1344]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__1_ ( .D(n2409), .DE(n262), .CLK(clk), 
        .Q(oam[1217]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__2_ ( .D(n2416), .DE(n262), .CLK(clk), 
        .Q(oam[1218]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__3_ ( .D(n2422), .DE(n262), .CLK(clk), 
        .Q(oam[1219]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__4_ ( .D(n2428), .DE(n262), .CLK(clk), 
        .Q(oam[1220]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__5_ ( .D(n2443), .DE(n262), .CLK(clk), 
        .Q(oam[1221]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__6_ ( .D(n2459), .DE(n262), .CLK(clk), 
        .Q(oam[1222]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__7_ ( .D(n2475), .DE(n262), .CLK(clk), 
        .Q(oam[1223]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_103__0_ ( .D(n2393), .DE(n262), .CLK(clk), 
        .Q(oam[1216]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__1_ ( .D(n2409), .DE(n161), .CLK(clk), 
        .Q(oam[1089]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__2_ ( .D(n2420), .DE(n161), .CLK(clk), 
        .Q(oam[1090]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__3_ ( .D(n2426), .DE(n161), .CLK(clk), 
        .Q(oam[1091]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__4_ ( .D(n2432), .DE(n161), .CLK(clk), 
        .Q(oam[1092]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__5_ ( .D(n2443), .DE(n161), .CLK(clk), 
        .Q(oam[1093]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__6_ ( .D(n2459), .DE(n161), .CLK(clk), 
        .Q(oam[1094]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__7_ ( .D(n2475), .DE(n161), .CLK(clk), 
        .Q(oam[1095]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_119__0_ ( .D(n2393), .DE(n161), .CLK(clk), 
        .Q(oam[1088]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__1_ ( .D(n2409), .DE(n167), .CLK(clk), 
        .Q(oam[961]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__2_ ( .D(n2419), .DE(n167), .CLK(clk), 
        .Q(oam[962]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__3_ ( .D(n2425), .DE(n167), .CLK(clk), 
        .Q(oam[963]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__4_ ( .D(n2431), .DE(n167), .CLK(clk), 
        .Q(oam[964]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__5_ ( .D(n2443), .DE(n167), .CLK(clk), 
        .Q(oam[965]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__6_ ( .D(n2459), .DE(n167), .CLK(clk), 
        .Q(oam[966]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__7_ ( .D(n2475), .DE(n167), .CLK(clk), 
        .Q(oam[967]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_135__0_ ( .D(n2393), .DE(n167), .CLK(clk), 
        .Q(oam[960]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__1_ ( .D(n2409), .DE(n166), .CLK(clk), 
        .Q(oam[833]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__2_ ( .D(n2419), .DE(n166), .CLK(clk), 
        .Q(oam[834]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__3_ ( .D(n2424), .DE(n166), .CLK(clk), 
        .Q(oam[835]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__4_ ( .D(n2430), .DE(n166), .CLK(clk), 
        .Q(oam[836]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__5_ ( .D(n2443), .DE(n166), .CLK(clk), 
        .Q(oam[837]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__6_ ( .D(n2459), .DE(n166), .CLK(clk), 
        .Q(oam[838]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__7_ ( .D(n2475), .DE(n166), .CLK(clk), 
        .Q(oam[839]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_151__0_ ( .D(n2393), .DE(n166), .CLK(clk), 
        .Q(oam[832]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__1_ ( .D(n2402), .DE(n363), .CLK(clk), 
        .Q(oam[673]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__2_ ( .D(n2416), .DE(n363), .CLK(clk), 
        .Q(oam[674]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__3_ ( .D(n2422), .DE(n363), .CLK(clk), 
        .Q(oam[675]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__4_ ( .D(n2428), .DE(n363), .CLK(clk), 
        .Q(oam[676]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__5_ ( .D(n2436), .DE(n363), .CLK(clk), 
        .Q(oam[677]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__6_ ( .D(n2452), .DE(n363), .CLK(clk), 
        .Q(oam[678]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__7_ ( .D(n2468), .DE(n363), .CLK(clk), 
        .Q(oam[679]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_171__0_ ( .D(n2386), .DE(n363), .CLK(clk), 
        .Q(oam[672]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__1_ ( .D(n2400), .DE(n362), .CLK(clk), 
        .Q(oam[545]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__2_ ( .D(n2418), .DE(n362), .CLK(clk), 
        .Q(oam[546]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__3_ ( .D(n2424), .DE(n362), .CLK(clk), 
        .Q(oam[547]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__4_ ( .D(n2430), .DE(n362), .CLK(clk), 
        .Q(oam[548]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__5_ ( .D(n2434), .DE(n362), .CLK(clk), 
        .Q(oam[549]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__6_ ( .D(n2450), .DE(n362), .CLK(clk), 
        .Q(oam[550]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__7_ ( .D(n2466), .DE(n362), .CLK(clk), 
        .Q(oam[551]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_187__0_ ( .D(n2384), .DE(n362), .CLK(clk), 
        .Q(oam[544]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__1_ ( .D(n2406), .DE(n358), .CLK(clk), 
        .Q(oam[417]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__2_ ( .D(n2417), .DE(n358), .CLK(clk), 
        .Q(oam[418]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__3_ ( .D(n2423), .DE(n358), .CLK(clk), 
        .Q(oam[419]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__4_ ( .D(n2429), .DE(n358), .CLK(clk), 
        .Q(oam[420]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__5_ ( .D(n2440), .DE(n358), .CLK(clk), 
        .Q(oam[421]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__6_ ( .D(n2456), .DE(n358), .CLK(clk), 
        .Q(oam[422]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__7_ ( .D(n2472), .DE(n358), .CLK(clk), 
        .Q(oam[423]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_203__0_ ( .D(n2390), .DE(n358), .CLK(clk), 
        .Q(oam[416]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__1_ ( .D(n2407), .DE(n357), .CLK(clk), 
        .Q(oam[289]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__2_ ( .D(n2416), .DE(n357), .CLK(clk), 
        .Q(oam[290]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__3_ ( .D(n2422), .DE(n357), .CLK(clk), 
        .Q(oam[291]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__4_ ( .D(n2428), .DE(n357), .CLK(clk), 
        .Q(oam[292]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__5_ ( .D(n2441), .DE(n357), .CLK(clk), 
        .Q(oam[293]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__6_ ( .D(n2457), .DE(n357), .CLK(clk), 
        .Q(oam[294]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__7_ ( .D(n2473), .DE(n357), .CLK(clk), 
        .Q(oam[295]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_219__0_ ( .D(n2391), .DE(n357), .CLK(clk), 
        .Q(oam[288]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__1_ ( .D(n2408), .DE(n361), .CLK(clk), 
        .Q(oam[161]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__2_ ( .D(n2420), .DE(n361), .CLK(clk), 
        .Q(oam[162]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__3_ ( .D(n2426), .DE(n361), .CLK(clk), 
        .Q(oam[163]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__4_ ( .D(n2432), .DE(n361), .CLK(clk), 
        .Q(oam[164]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__5_ ( .D(n2442), .DE(n361), .CLK(clk), 
        .Q(oam[165]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__6_ ( .D(n2458), .DE(n361), .CLK(clk), 
        .Q(oam[166]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__7_ ( .D(n2474), .DE(n361), .CLK(clk), 
        .Q(oam[167]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_235__0_ ( .D(n2392), .DE(n361), .CLK(clk), 
        .Q(oam[160]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__1_ ( .D(n2401), .DE(n360), .CLK(clk), 
        .Q(oam[33]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__2_ ( .D(n2420), .DE(n360), .CLK(clk), 
        .Q(oam[34]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__3_ ( .D(n2425), .DE(n360), .CLK(clk), 
        .Q(oam[35]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__4_ ( .D(n2431), .DE(n360), .CLK(clk), 
        .Q(oam[36]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__5_ ( .D(n2435), .DE(n360), .CLK(clk), 
        .Q(oam[37]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__6_ ( .D(n2451), .DE(n360), .CLK(clk), 
        .Q(oam[38]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__7_ ( .D(n2467), .DE(n360), .CLK(clk), 
        .Q(oam[39]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_251__0_ ( .D(n2385), .DE(n360), .CLK(clk), 
        .Q(oam[32]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__1_ ( .D(n2403), .DE(n327), .CLK(clk), 
        .Q(oam[1953]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__2_ ( .D(n2416), .DE(n327), .CLK(clk), 
        .Q(oam[1954]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__3_ ( .D(n2425), .DE(n327), .CLK(clk), 
        .Q(oam[1955]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__4_ ( .D(n2431), .DE(n327), .CLK(clk), 
        .Q(oam[1956]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__5_ ( .D(n2438), .DE(n327), .CLK(clk), 
        .Q(oam[1957]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__6_ ( .D(n2454), .DE(n327), .CLK(clk), 
        .Q(oam[1958]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__7_ ( .D(n2470), .DE(n327), .CLK(clk), 
        .Q(oam[1959]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_11__0_ ( .D(n2388), .DE(n327), .CLK(clk), 
        .Q(oam[1952]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__1_ ( .D(n2404), .DE(n326), .CLK(clk), 
        .Q(oam[1825]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__2_ ( .D(n2420), .DE(n326), .CLK(clk), 
        .Q(oam[1826]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__3_ ( .D(n2426), .DE(n326), .CLK(clk), 
        .Q(oam[1827]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__4_ ( .D(n2432), .DE(n326), .CLK(clk), 
        .Q(oam[1828]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__5_ ( .D(n2437), .DE(n326), .CLK(clk), 
        .Q(oam[1829]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__6_ ( .D(n2453), .DE(n326), .CLK(clk), 
        .Q(oam[1830]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__7_ ( .D(n2469), .DE(n326), .CLK(clk), 
        .Q(oam[1831]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_27__0_ ( .D(n2387), .DE(n326), .CLK(clk), 
        .Q(oam[1824]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__1_ ( .D(n2402), .DE(n356), .CLK(clk), 
        .Q(oam[1697]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__2_ ( .D(n2418), .DE(n356), .CLK(clk), 
        .Q(oam[1698]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__3_ ( .D(n2424), .DE(n356), .CLK(clk), 
        .Q(oam[1699]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__4_ ( .D(n2430), .DE(n356), .CLK(clk), 
        .Q(oam[1700]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__5_ ( .D(n2436), .DE(n356), .CLK(clk), 
        .Q(oam[1701]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__6_ ( .D(n2452), .DE(n356), .CLK(clk), 
        .Q(oam[1702]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__7_ ( .D(n2468), .DE(n356), .CLK(clk), 
        .Q(oam[1703]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_43__0_ ( .D(n2386), .DE(n356), .CLK(clk), 
        .Q(oam[1696]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__1_ ( .D(n2410), .DE(n355), .CLK(clk), 
        .Q(oam[1569]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__2_ ( .D(n2416), .DE(n355), .CLK(clk), 
        .Q(oam[1570]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__3_ ( .D(n2426), .DE(n355), .CLK(clk), 
        .Q(oam[1571]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__4_ ( .D(n2432), .DE(n355), .CLK(clk), 
        .Q(oam[1572]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__5_ ( .D(n2443), .DE(n355), .CLK(clk), 
        .Q(oam[1573]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__6_ ( .D(n2459), .DE(n355), .CLK(clk), 
        .Q(oam[1574]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__7_ ( .D(n2475), .DE(n355), .CLK(clk), 
        .Q(oam[1575]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_59__0_ ( .D(n2393), .DE(n355), .CLK(clk), 
        .Q(oam[1568]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__1_ ( .D(n2409), .DE(n354), .CLK(clk), 
        .Q(oam[1441]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__2_ ( .D(n2419), .DE(n354), .CLK(clk), 
        .Q(oam[1442]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__3_ ( .D(n2422), .DE(n354), .CLK(clk), 
        .Q(oam[1443]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__4_ ( .D(n2428), .DE(n354), .CLK(clk), 
        .Q(oam[1444]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__5_ ( .D(n2443), .DE(n354), .CLK(clk), 
        .Q(oam[1445]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__6_ ( .D(n2459), .DE(n354), .CLK(clk), 
        .Q(oam[1446]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__7_ ( .D(n2475), .DE(n354), .CLK(clk), 
        .Q(oam[1447]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_75__0_ ( .D(n2393), .DE(n354), .CLK(clk), 
        .Q(oam[1440]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__1_ ( .D(n2405), .DE(n353), .CLK(clk), 
        .Q(oam[1313]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__2_ ( .D(n2417), .DE(n353), .CLK(clk), 
        .Q(oam[1314]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__3_ ( .D(n2423), .DE(n353), .CLK(clk), 
        .Q(oam[1315]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__4_ ( .D(n2429), .DE(n353), .CLK(clk), 
        .Q(oam[1316]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__5_ ( .D(n2439), .DE(n353), .CLK(clk), 
        .Q(oam[1317]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__6_ ( .D(n2455), .DE(n353), .CLK(clk), 
        .Q(oam[1318]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__7_ ( .D(n2471), .DE(n353), .CLK(clk), 
        .Q(oam[1319]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_91__0_ ( .D(n2389), .DE(n353), .CLK(clk), 
        .Q(oam[1312]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__1_ ( .D(n2406), .DE(n359), .CLK(clk), 
        .Q(oam[1185]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__2_ ( .D(n2416), .DE(n359), .CLK(clk), 
        .Q(oam[1186]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__3_ ( .D(n2422), .DE(n359), .CLK(clk), 
        .Q(oam[1187]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__4_ ( .D(n2428), .DE(n359), .CLK(clk), 
        .Q(oam[1188]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__5_ ( .D(n2440), .DE(n359), .CLK(clk), 
        .Q(oam[1189]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__6_ ( .D(n2456), .DE(n359), .CLK(clk), 
        .Q(oam[1190]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__7_ ( .D(n2472), .DE(n359), .CLK(clk), 
        .Q(oam[1191]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_107__0_ ( .D(n2390), .DE(n359), .CLK(clk), 
        .Q(oam[1184]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__1_ ( .D(n2407), .DE(n160), .CLK(clk), 
        .Q(oam[1057]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__2_ ( .D(n2419), .DE(n160), .CLK(clk), 
        .Q(oam[1058]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__3_ ( .D(n2426), .DE(n160), .CLK(clk), 
        .Q(oam[1059]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__4_ ( .D(n2432), .DE(n160), .CLK(clk), 
        .Q(oam[1060]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__5_ ( .D(n2441), .DE(n160), .CLK(clk), 
        .Q(oam[1061]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__6_ ( .D(n2457), .DE(n160), .CLK(clk), 
        .Q(oam[1062]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__7_ ( .D(n2473), .DE(n160), .CLK(clk), 
        .Q(oam[1063]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_123__0_ ( .D(n2391), .DE(n160), .CLK(clk), 
        .Q(oam[1056]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__1_ ( .D(n2408), .DE(n141), .CLK(clk), 
        .Q(oam[929]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__2_ ( .D(n2418), .DE(n141), .CLK(clk), 
        .Q(oam[930]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__3_ ( .D(n2425), .DE(n141), .CLK(clk), 
        .Q(oam[931]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__4_ ( .D(n2431), .DE(n141), .CLK(clk), 
        .Q(oam[932]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__5_ ( .D(n2442), .DE(n141), .CLK(clk), 
        .Q(oam[933]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__6_ ( .D(n2458), .DE(n141), .CLK(clk), 
        .Q(oam[934]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__7_ ( .D(n2474), .DE(n141), .CLK(clk), 
        .Q(oam[935]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_139__0_ ( .D(n2392), .DE(n141), .CLK(clk), 
        .Q(oam[928]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__1_ ( .D(n2408), .DE(n181), .CLK(clk), 
        .Q(oam[801]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__2_ ( .D(n2417), .DE(n181), .CLK(clk), 
        .Q(oam[802]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__3_ ( .D(n2423), .DE(n181), .CLK(clk), 
        .Q(oam[803]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__4_ ( .D(n2429), .DE(n181), .CLK(clk), 
        .Q(oam[804]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__5_ ( .D(n2442), .DE(n181), .CLK(clk), 
        .Q(oam[805]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__6_ ( .D(n2458), .DE(n181), .CLK(clk), 
        .Q(oam[806]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__7_ ( .D(n2474), .DE(n181), .CLK(clk), 
        .Q(oam[807]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_155__0_ ( .D(n2392), .DE(n181), .CLK(clk), 
        .Q(oam[800]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__1_ ( .D(n2408), .DE(n396), .CLK(clk), 
        .Q(oam[641]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__2_ ( .D(n2416), .DE(n396), .CLK(clk), 
        .Q(oam[642]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__3_ ( .D(n2422), .DE(n396), .CLK(clk), 
        .Q(oam[643]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__4_ ( .D(n2428), .DE(n396), .CLK(clk), 
        .Q(oam[644]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__5_ ( .D(n2442), .DE(n396), .CLK(clk), 
        .Q(oam[645]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__6_ ( .D(n2458), .DE(n396), .CLK(clk), 
        .Q(oam[646]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__7_ ( .D(n2474), .DE(n396), .CLK(clk), 
        .Q(oam[647]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_175__0_ ( .D(n2392), .DE(n396), .CLK(clk), 
        .Q(oam[640]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__1_ ( .D(n2408), .DE(n395), .CLK(clk), 
        .Q(oam[513]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__2_ ( .D(n2418), .DE(n395), .CLK(clk), 
        .Q(oam[514]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__3_ ( .D(n2425), .DE(n395), .CLK(clk), 
        .Q(oam[515]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__4_ ( .D(n2431), .DE(n395), .CLK(clk), 
        .Q(oam[516]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__5_ ( .D(n2442), .DE(n395), .CLK(clk), 
        .Q(oam[517]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__6_ ( .D(n2458), .DE(n395), .CLK(clk), 
        .Q(oam[518]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__7_ ( .D(n2474), .DE(n395), .CLK(clk), 
        .Q(oam[519]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_191__0_ ( .D(n2392), .DE(n395), .CLK(clk), 
        .Q(oam[512]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__1_ ( .D(n2408), .DE(n391), .CLK(clk), 
        .Q(oam[385]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__2_ ( .D(n2417), .DE(n391), .CLK(clk), 
        .Q(oam[386]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__3_ ( .D(n2425), .DE(n391), .CLK(clk), 
        .Q(oam[387]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__4_ ( .D(n2431), .DE(n391), .CLK(clk), 
        .Q(oam[388]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__5_ ( .D(n2442), .DE(n391), .CLK(clk), 
        .Q(oam[389]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__6_ ( .D(n2458), .DE(n391), .CLK(clk), 
        .Q(oam[390]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__7_ ( .D(n2474), .DE(n391), .CLK(clk), 
        .Q(oam[391]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_207__0_ ( .D(n2392), .DE(n391), .CLK(clk), 
        .Q(oam[384]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__1_ ( .D(n2408), .DE(n390), .CLK(clk), 
        .Q(oam[257]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__2_ ( .D(n2420), .DE(n390), .CLK(clk), 
        .Q(oam[258]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__3_ ( .D(n2426), .DE(n390), .CLK(clk), 
        .Q(oam[259]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__4_ ( .D(n2432), .DE(n390), .CLK(clk), 
        .Q(oam[260]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__5_ ( .D(n2442), .DE(n390), .CLK(clk), 
        .Q(oam[261]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__6_ ( .D(n2458), .DE(n390), .CLK(clk), 
        .Q(oam[262]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__7_ ( .D(n2474), .DE(n390), .CLK(clk), 
        .Q(oam[263]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_223__0_ ( .D(n2392), .DE(n390), .CLK(clk), 
        .Q(oam[256]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__1_ ( .D(n2408), .DE(n394), .CLK(clk), 
        .Q(oam[129]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__2_ ( .D(n2420), .DE(n394), .CLK(clk), 
        .Q(oam[130]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__3_ ( .D(n2426), .DE(n394), .CLK(clk), 
        .Q(oam[131]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__4_ ( .D(n2432), .DE(n394), .CLK(clk), 
        .Q(oam[132]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__5_ ( .D(n2442), .DE(n394), .CLK(clk), 
        .Q(oam[133]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__6_ ( .D(n2458), .DE(n394), .CLK(clk), 
        .Q(oam[134]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__7_ ( .D(n2474), .DE(n394), .CLK(clk), 
        .Q(oam[135]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_239__0_ ( .D(n2392), .DE(n394), .CLK(clk), 
        .Q(oam[128]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__1_ ( .D(n2408), .DE(n393), .CLK(clk), 
        .Q(oam[1]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__2_ ( .D(n2420), .DE(n393), .CLK(clk), 
        .Q(oam[2]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__3_ ( .D(n2426), .DE(n393), .CLK(clk), 
        .Q(oam[3]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__4_ ( .D(n2432), .DE(n393), .CLK(clk), 
        .Q(oam[4]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__5_ ( .D(n2442), .DE(n393), .CLK(clk), 
        .Q(oam[5]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__6_ ( .D(n2458), .DE(n393), .CLK(clk), 
        .Q(oam[6]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__7_ ( .D(n2474), .DE(n393), .CLK(clk), 
        .Q(oam[7]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_255__0_ ( .D(n2392), .DE(n393), .CLK(clk), 
        .Q(oam[0]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__1_ ( .D(n2408), .DE(n325), .CLK(clk), 
        .Q(oam[1921]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__2_ ( .D(n2420), .DE(n325), .CLK(clk), 
        .Q(oam[1922]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__3_ ( .D(n2426), .DE(n325), .CLK(clk), 
        .Q(oam[1923]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__4_ ( .D(n2432), .DE(n325), .CLK(clk), 
        .Q(oam[1924]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__5_ ( .D(n2442), .DE(n325), .CLK(clk), 
        .Q(oam[1925]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__6_ ( .D(n2458), .DE(n325), .CLK(clk), 
        .Q(oam[1926]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__7_ ( .D(n2474), .DE(n325), .CLK(clk), 
        .Q(oam[1927]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_15__0_ ( .D(n2392), .DE(n325), .CLK(clk), 
        .Q(oam[1920]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__1_ ( .D(n2408), .DE(n324), .CLK(clk), 
        .Q(oam[1793]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__2_ ( .D(n2420), .DE(n324), .CLK(clk), 
        .Q(oam[1794]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__3_ ( .D(n2426), .DE(n324), .CLK(clk), 
        .Q(oam[1795]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__4_ ( .D(n2432), .DE(n324), .CLK(clk), 
        .Q(oam[1796]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__5_ ( .D(n2442), .DE(n324), .CLK(clk), 
        .Q(oam[1797]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__6_ ( .D(n2458), .DE(n324), .CLK(clk), 
        .Q(oam[1798]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__7_ ( .D(n2474), .DE(n324), .CLK(clk), 
        .Q(oam[1799]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_31__0_ ( .D(n2392), .DE(n324), .CLK(clk), 
        .Q(oam[1792]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__1_ ( .D(n2408), .DE(n389), .CLK(clk), 
        .Q(oam[1665]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__2_ ( .D(n2420), .DE(n389), .CLK(clk), 
        .Q(oam[1666]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__3_ ( .D(n2426), .DE(n389), .CLK(clk), 
        .Q(oam[1667]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__4_ ( .D(n2432), .DE(n389), .CLK(clk), 
        .Q(oam[1668]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__5_ ( .D(n2442), .DE(n389), .CLK(clk), 
        .Q(oam[1669]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__6_ ( .D(n2458), .DE(n389), .CLK(clk), 
        .Q(oam[1670]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__7_ ( .D(n2474), .DE(n389), .CLK(clk), 
        .Q(oam[1671]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_47__0_ ( .D(n2392), .DE(n389), .CLK(clk), 
        .Q(oam[1664]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__1_ ( .D(n2408), .DE(n388), .CLK(clk), 
        .Q(oam[1537]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__2_ ( .D(n2420), .DE(n388), .CLK(clk), 
        .Q(oam[1538]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__3_ ( .D(n2426), .DE(n388), .CLK(clk), 
        .Q(oam[1539]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__4_ ( .D(n2432), .DE(n388), .CLK(clk), 
        .Q(oam[1540]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__5_ ( .D(n2442), .DE(n388), .CLK(clk), 
        .Q(oam[1541]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__6_ ( .D(n2458), .DE(n388), .CLK(clk), 
        .Q(oam[1542]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__7_ ( .D(n2474), .DE(n388), .CLK(clk), 
        .Q(oam[1543]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_63__0_ ( .D(n2392), .DE(n388), .CLK(clk), 
        .Q(oam[1536]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__1_ ( .D(n2408), .DE(n387), .CLK(clk), 
        .Q(oam[1409]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__2_ ( .D(n2420), .DE(n387), .CLK(clk), 
        .Q(oam[1410]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__3_ ( .D(n2426), .DE(n387), .CLK(clk), 
        .Q(oam[1411]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__4_ ( .D(n2432), .DE(n387), .CLK(clk), 
        .Q(oam[1412]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__5_ ( .D(n2442), .DE(n387), .CLK(clk), 
        .Q(oam[1413]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__6_ ( .D(n2458), .DE(n387), .CLK(clk), 
        .Q(oam[1414]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__7_ ( .D(n2474), .DE(n387), .CLK(clk), 
        .Q(oam[1415]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_79__0_ ( .D(n2392), .DE(n387), .CLK(clk), 
        .Q(oam[1408]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__1_ ( .D(n2408), .DE(n386), .CLK(clk), 
        .Q(oam[1281]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__2_ ( .D(n2420), .DE(n386), .CLK(clk), 
        .Q(oam[1282]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__3_ ( .D(n2426), .DE(n386), .CLK(clk), 
        .Q(oam[1283]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__4_ ( .D(n2432), .DE(n386), .CLK(clk), 
        .Q(oam[1284]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__5_ ( .D(n2442), .DE(n386), .CLK(clk), 
        .Q(oam[1285]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__6_ ( .D(n2458), .DE(n386), .CLK(clk), 
        .Q(oam[1286]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__7_ ( .D(n2474), .DE(n386), .CLK(clk), 
        .Q(oam[1287]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_95__0_ ( .D(n2392), .DE(n386), .CLK(clk), 
        .Q(oam[1280]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__1_ ( .D(n2407), .DE(n392), .CLK(clk), 
        .Q(oam[1153]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__2_ ( .D(n2420), .DE(n392), .CLK(clk), 
        .Q(oam[1154]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__3_ ( .D(n2426), .DE(n392), .CLK(clk), 
        .Q(oam[1155]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__4_ ( .D(n2432), .DE(n392), .CLK(clk), 
        .Q(oam[1156]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__5_ ( .D(n2441), .DE(n392), .CLK(clk), 
        .Q(oam[1157]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__6_ ( .D(n2457), .DE(n392), .CLK(clk), 
        .Q(oam[1158]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__7_ ( .D(n2473), .DE(n392), .CLK(clk), 
        .Q(oam[1159]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_111__0_ ( .D(n2391), .DE(n392), .CLK(clk), 
        .Q(oam[1152]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__1_ ( .D(n2407), .DE(n159), .CLK(clk), 
        .Q(oam[1025]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__2_ ( .D(n2420), .DE(n159), .CLK(clk), 
        .Q(oam[1026]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__3_ ( .D(n2426), .DE(n159), .CLK(clk), 
        .Q(oam[1027]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__4_ ( .D(n2432), .DE(n159), .CLK(clk), 
        .Q(oam[1028]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__5_ ( .D(n2441), .DE(n159), .CLK(clk), 
        .Q(oam[1029]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__6_ ( .D(n2457), .DE(n159), .CLK(clk), 
        .Q(oam[1030]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__7_ ( .D(n2473), .DE(n159), .CLK(clk), 
        .Q(oam[1031]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_127__0_ ( .D(n2391), .DE(n159), .CLK(clk), 
        .Q(oam[1024]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__1_ ( .D(n2407), .DE(n140), .CLK(clk), 
        .Q(oam[897]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__2_ ( .D(n2420), .DE(n140), .CLK(clk), 
        .Q(oam[898]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__3_ ( .D(n2426), .DE(n140), .CLK(clk), 
        .Q(oam[899]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__4_ ( .D(n2432), .DE(n140), .CLK(clk), 
        .Q(oam[900]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__5_ ( .D(n2441), .DE(n140), .CLK(clk), 
        .Q(oam[901]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__6_ ( .D(n2457), .DE(n140), .CLK(clk), 
        .Q(oam[902]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__7_ ( .D(n2473), .DE(n140), .CLK(clk), 
        .Q(oam[903]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_143__0_ ( .D(n2391), .DE(n140), .CLK(clk), 
        .Q(oam[896]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__1_ ( .D(n2407), .DE(n180), .CLK(clk), 
        .Q(oam[769]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__2_ ( .D(n2420), .DE(n180), .CLK(clk), 
        .Q(oam[770]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__3_ ( .D(n2426), .DE(n180), .CLK(clk), 
        .Q(oam[771]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__4_ ( .D(n2432), .DE(n180), .CLK(clk), 
        .Q(oam[772]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__5_ ( .D(n2441), .DE(n180), .CLK(clk), 
        .Q(oam[773]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__6_ ( .D(n2457), .DE(n180), .CLK(clk), 
        .Q(oam[774]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__7_ ( .D(n2473), .DE(n180), .CLK(clk), 
        .Q(oam[775]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_159__0_ ( .D(n2391), .DE(n180), .CLK(clk), 
        .Q(oam[768]) );
  sky130_fd_sc_hd__edfxtp_1 state_reg_1_ ( .D(n2766), .DE(n421), .CLK(clk), 
        .Q(state[1]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_166__1_ ( .D(n2407), .DE(n302), .CLK(clk), 
        .Q(oam[713]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_166__5_ ( .D(n2441), .DE(n302), .CLK(clk), 
        .Q(oam[717]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_166__6_ ( .D(n2457), .DE(n302), .CLK(clk), 
        .Q(oam[718]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_166__7_ ( .D(n2473), .DE(n302), .CLK(clk), 
        .Q(oam[719]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_166__0_ ( .D(n2391), .DE(n302), .CLK(clk), 
        .Q(oam[712]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_182__1_ ( .D(n2407), .DE(n301), .CLK(clk), 
        .Q(oam[585]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_182__5_ ( .D(n2441), .DE(n301), .CLK(clk), 
        .Q(oam[589]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_182__6_ ( .D(n2457), .DE(n301), .CLK(clk), 
        .Q(oam[590]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_182__7_ ( .D(n2473), .DE(n301), .CLK(clk), 
        .Q(oam[591]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_182__0_ ( .D(n2391), .DE(n301), .CLK(clk), 
        .Q(oam[584]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_198__1_ ( .D(n2407), .DE(n297), .CLK(clk), 
        .Q(oam[457]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_198__5_ ( .D(n2441), .DE(n297), .CLK(clk), 
        .Q(oam[461]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_198__6_ ( .D(n2457), .DE(n297), .CLK(clk), 
        .Q(oam[462]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_198__7_ ( .D(n2473), .DE(n297), .CLK(clk), 
        .Q(oam[463]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_198__0_ ( .D(n2391), .DE(n297), .CLK(clk), 
        .Q(oam[456]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_214__1_ ( .D(n2407), .DE(n296), .CLK(clk), 
        .Q(oam[329]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_214__5_ ( .D(n2441), .DE(n296), .CLK(clk), 
        .Q(oam[333]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_214__6_ ( .D(n2457), .DE(n296), .CLK(clk), 
        .Q(oam[334]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_214__7_ ( .D(n2473), .DE(n296), .CLK(clk), 
        .Q(oam[335]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_214__0_ ( .D(n2391), .DE(n296), .CLK(clk), 
        .Q(oam[328]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_230__1_ ( .D(n2407), .DE(n300), .CLK(clk), 
        .Q(oam[201]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_230__5_ ( .D(n2441), .DE(n300), .CLK(clk), 
        .Q(oam[205]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_230__6_ ( .D(n2457), .DE(n300), .CLK(clk), 
        .Q(oam[206]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_230__7_ ( .D(n2473), .DE(n300), .CLK(clk), 
        .Q(oam[207]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_230__0_ ( .D(n2391), .DE(n300), .CLK(clk), 
        .Q(oam[200]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_246__1_ ( .D(n2407), .DE(n299), .CLK(clk), 
        .Q(oam[73]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_246__5_ ( .D(n2441), .DE(n299), .CLK(clk), 
        .Q(oam[77]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_246__6_ ( .D(n2457), .DE(n299), .CLK(clk), 
        .Q(oam[78]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_246__7_ ( .D(n2473), .DE(n299), .CLK(clk), 
        .Q(oam[79]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_246__0_ ( .D(n2391), .DE(n299), .CLK(clk), 
        .Q(oam[72]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_6__1_ ( .D(n2407), .DE(n189), .CLK(clk), 
        .Q(oam[1993]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_6__5_ ( .D(n2441), .DE(n189), .CLK(clk), 
        .Q(oam[1997]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_6__6_ ( .D(n2457), .DE(n189), .CLK(clk), 
        .Q(oam[1998]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_6__7_ ( .D(n2473), .DE(n189), .CLK(clk), 
        .Q(oam[1999]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_6__0_ ( .D(n2391), .DE(n189), .CLK(clk), 
        .Q(oam[1992]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_22__1_ ( .D(n2407), .DE(n199), .CLK(clk), 
        .Q(oam[1865]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_22__5_ ( .D(n2441), .DE(n199), .CLK(clk), 
        .Q(oam[1869]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_22__6_ ( .D(n2457), .DE(n199), .CLK(clk), 
        .Q(oam[1870]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_22__7_ ( .D(n2473), .DE(n199), .CLK(clk), 
        .Q(oam[1871]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_22__0_ ( .D(n2391), .DE(n199), .CLK(clk), 
        .Q(oam[1864]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_38__1_ ( .D(n2407), .DE(n295), .CLK(clk), 
        .Q(oam[1737]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_38__5_ ( .D(n2441), .DE(n295), .CLK(clk), 
        .Q(oam[1741]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_38__6_ ( .D(n2457), .DE(n295), .CLK(clk), 
        .Q(oam[1742]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_38__7_ ( .D(n2473), .DE(n295), .CLK(clk), 
        .Q(oam[1743]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_38__0_ ( .D(n2391), .DE(n295), .CLK(clk), 
        .Q(oam[1736]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_54__1_ ( .D(n2407), .DE(n294), .CLK(clk), 
        .Q(oam[1609]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_54__5_ ( .D(n2441), .DE(n294), .CLK(clk), 
        .Q(oam[1613]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_54__6_ ( .D(n2457), .DE(n294), .CLK(clk), 
        .Q(oam[1614]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_54__7_ ( .D(n2473), .DE(n294), .CLK(clk), 
        .Q(oam[1615]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_54__0_ ( .D(n2391), .DE(n294), .CLK(clk), 
        .Q(oam[1608]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_70__1_ ( .D(n2405), .DE(n293), .CLK(clk), 
        .Q(oam[1481]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_70__5_ ( .D(n2439), .DE(n293), .CLK(clk), 
        .Q(oam[1485]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_70__6_ ( .D(n2455), .DE(n293), .CLK(clk), 
        .Q(oam[1486]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_70__7_ ( .D(n2471), .DE(n293), .CLK(clk), 
        .Q(oam[1487]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_70__0_ ( .D(n2389), .DE(n293), .CLK(clk), 
        .Q(oam[1480]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_86__1_ ( .D(n2406), .DE(n292), .CLK(clk), 
        .Q(oam[1353]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_86__5_ ( .D(n2440), .DE(n292), .CLK(clk), 
        .Q(oam[1357]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_86__6_ ( .D(n2456), .DE(n292), .CLK(clk), 
        .Q(oam[1358]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_86__7_ ( .D(n2472), .DE(n292), .CLK(clk), 
        .Q(oam[1359]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_86__0_ ( .D(n2390), .DE(n292), .CLK(clk), 
        .Q(oam[1352]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_102__1_ ( .D(n2407), .DE(n298), .CLK(clk), 
        .Q(oam[1225]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_102__5_ ( .D(n2441), .DE(n298), .CLK(clk), 
        .Q(oam[1229]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_102__6_ ( .D(n2457), .DE(n298), .CLK(clk), 
        .Q(oam[1230]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_102__7_ ( .D(n2473), .DE(n298), .CLK(clk), 
        .Q(oam[1231]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_102__0_ ( .D(n2391), .DE(n298), .CLK(clk), 
        .Q(oam[1224]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_118__1_ ( .D(n2408), .DE(n193), .CLK(clk), 
        .Q(oam[1097]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_118__5_ ( .D(n2442), .DE(n193), .CLK(clk), 
        .Q(oam[1101]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_118__6_ ( .D(n2458), .DE(n193), .CLK(clk), 
        .Q(oam[1102]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_118__7_ ( .D(n2474), .DE(n193), .CLK(clk), 
        .Q(oam[1103]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_118__0_ ( .D(n2392), .DE(n193), .CLK(clk), 
        .Q(oam[1096]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_134__1_ ( .D(n2400), .DE(n165), .CLK(clk), 
        .Q(oam[969]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_134__5_ ( .D(n2434), .DE(n165), .CLK(clk), 
        .Q(oam[973]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_134__6_ ( .D(n2450), .DE(n165), .CLK(clk), 
        .Q(oam[974]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_134__7_ ( .D(n2466), .DE(n165), .CLK(clk), 
        .Q(oam[975]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_134__0_ ( .D(n2384), .DE(n165), .CLK(clk), 
        .Q(oam[968]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_150__1_ ( .D(n2401), .DE(n197), .CLK(clk), 
        .Q(oam[841]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_150__5_ ( .D(n2435), .DE(n197), .CLK(clk), 
        .Q(oam[845]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_150__6_ ( .D(n2451), .DE(n197), .CLK(clk), 
        .Q(oam[846]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_150__7_ ( .D(n2467), .DE(n197), .CLK(clk), 
        .Q(oam[847]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_150__0_ ( .D(n2385), .DE(n197), .CLK(clk), 
        .Q(oam[840]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_170__1_ ( .D(n2402), .DE(n407), .CLK(clk), 
        .Q(oam[681]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_170__5_ ( .D(n2436), .DE(n407), .CLK(clk), 
        .Q(oam[685]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_170__6_ ( .D(n2452), .DE(n407), .CLK(clk), 
        .Q(oam[686]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_170__7_ ( .D(n2468), .DE(n407), .CLK(clk), 
        .Q(oam[687]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_170__0_ ( .D(n2386), .DE(n407), .CLK(clk), 
        .Q(oam[680]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_186__1_ ( .D(n2410), .DE(n406), .CLK(clk), 
        .Q(oam[553]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_186__5_ ( .D(n2436), .DE(n406), .CLK(clk), 
        .Q(oam[557]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_186__6_ ( .D(n2452), .DE(n406), .CLK(clk), 
        .Q(oam[558]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_186__7_ ( .D(n2468), .DE(n406), .CLK(clk), 
        .Q(oam[559]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_186__0_ ( .D(n2386), .DE(n406), .CLK(clk), 
        .Q(oam[552]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_202__1_ ( .D(n2409), .DE(n402), .CLK(clk), 
        .Q(oam[425]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_202__5_ ( .D(n2443), .DE(n402), .CLK(clk), 
        .Q(oam[429]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_202__6_ ( .D(n2459), .DE(n402), .CLK(clk), 
        .Q(oam[430]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_202__7_ ( .D(n2475), .DE(n402), .CLK(clk), 
        .Q(oam[431]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_202__0_ ( .D(n2393), .DE(n402), .CLK(clk), 
        .Q(oam[424]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_218__1_ ( .D(n2404), .DE(n401), .CLK(clk), 
        .Q(oam[297]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_218__5_ ( .D(n2437), .DE(n401), .CLK(clk), 
        .Q(oam[301]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_218__6_ ( .D(n2453), .DE(n401), .CLK(clk), 
        .Q(oam[302]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_218__7_ ( .D(n2469), .DE(n401), .CLK(clk), 
        .Q(oam[303]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_218__0_ ( .D(n2387), .DE(n401), .CLK(clk), 
        .Q(oam[296]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_234__1_ ( .D(n2409), .DE(n405), .CLK(clk), 
        .Q(oam[169]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_234__5_ ( .D(n2443), .DE(n405), .CLK(clk), 
        .Q(oam[173]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_234__6_ ( .D(n2459), .DE(n405), .CLK(clk), 
        .Q(oam[174]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_234__7_ ( .D(n2475), .DE(n405), .CLK(clk), 
        .Q(oam[175]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_234__0_ ( .D(n2393), .DE(n405), .CLK(clk), 
        .Q(oam[168]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_250__1_ ( .D(n2405), .DE(n404), .CLK(clk), 
        .Q(oam[41]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_250__5_ ( .D(n2439), .DE(n404), .CLK(clk), 
        .Q(oam[45]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_250__6_ ( .D(n2455), .DE(n404), .CLK(clk), 
        .Q(oam[46]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_250__7_ ( .D(n2471), .DE(n404), .CLK(clk), 
        .Q(oam[47]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_250__0_ ( .D(n2389), .DE(n404), .CLK(clk), 
        .Q(oam[40]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_10__1_ ( .D(n2403), .DE(n188), .CLK(clk), 
        .Q(oam[1961]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_10__5_ ( .D(n2438), .DE(n188), .CLK(clk), 
        .Q(oam[1965]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_10__6_ ( .D(n2454), .DE(n188), .CLK(clk), 
        .Q(oam[1966]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_10__7_ ( .D(n2470), .DE(n188), .CLK(clk), 
        .Q(oam[1967]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_10__0_ ( .D(n2388), .DE(n188), .CLK(clk), 
        .Q(oam[1960]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_26__1_ ( .D(n2404), .DE(n330), .CLK(clk), 
        .Q(oam[1833]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_26__5_ ( .D(n2437), .DE(n330), .CLK(clk), 
        .Q(oam[1837]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_26__6_ ( .D(n2453), .DE(n330), .CLK(clk), 
        .Q(oam[1838]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_26__7_ ( .D(n2469), .DE(n330), .CLK(clk), 
        .Q(oam[1839]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_26__0_ ( .D(n2387), .DE(n330), .CLK(clk), 
        .Q(oam[1832]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_42__1_ ( .D(n2406), .DE(n400), .CLK(clk), 
        .Q(oam[1705]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_42__5_ ( .D(n2440), .DE(n400), .CLK(clk), 
        .Q(oam[1709]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_42__6_ ( .D(n2456), .DE(n400), .CLK(clk), 
        .Q(oam[1710]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_42__7_ ( .D(n2472), .DE(n400), .CLK(clk), 
        .Q(oam[1711]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_42__0_ ( .D(n2390), .DE(n400), .CLK(clk), 
        .Q(oam[1704]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_58__1_ ( .D(n2406), .DE(n399), .CLK(clk), 
        .Q(oam[1577]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_58__5_ ( .D(n2440), .DE(n399), .CLK(clk), 
        .Q(oam[1581]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_58__6_ ( .D(n2456), .DE(n399), .CLK(clk), 
        .Q(oam[1582]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_58__7_ ( .D(n2472), .DE(n399), .CLK(clk), 
        .Q(oam[1583]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_58__0_ ( .D(n2390), .DE(n399), .CLK(clk), 
        .Q(oam[1576]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_74__1_ ( .D(n2406), .DE(n398), .CLK(clk), 
        .Q(oam[1449]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_74__5_ ( .D(n2440), .DE(n398), .CLK(clk), 
        .Q(oam[1453]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_74__6_ ( .D(n2456), .DE(n398), .CLK(clk), 
        .Q(oam[1454]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_74__7_ ( .D(n2472), .DE(n398), .CLK(clk), 
        .Q(oam[1455]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_74__0_ ( .D(n2390), .DE(n398), .CLK(clk), 
        .Q(oam[1448]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_90__1_ ( .D(n2406), .DE(n397), .CLK(clk), 
        .Q(oam[1321]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_90__5_ ( .D(n2440), .DE(n397), .CLK(clk), 
        .Q(oam[1325]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_90__6_ ( .D(n2456), .DE(n397), .CLK(clk), 
        .Q(oam[1326]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_90__7_ ( .D(n2472), .DE(n397), .CLK(clk), 
        .Q(oam[1327]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_90__0_ ( .D(n2390), .DE(n397), .CLK(clk), 
        .Q(oam[1320]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_106__1_ ( .D(n2406), .DE(n403), .CLK(clk), 
        .Q(oam[1193]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_106__5_ ( .D(n2440), .DE(n403), .CLK(clk), 
        .Q(oam[1197]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_106__6_ ( .D(n2456), .DE(n403), .CLK(clk), 
        .Q(oam[1198]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_106__7_ ( .D(n2472), .DE(n403), .CLK(clk), 
        .Q(oam[1199]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_106__0_ ( .D(n2390), .DE(n403), .CLK(clk), 
        .Q(oam[1192]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_122__1_ ( .D(n2406), .DE(n192), .CLK(clk), 
        .Q(oam[1065]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_122__5_ ( .D(n2440), .DE(n192), .CLK(clk), 
        .Q(oam[1069]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_122__6_ ( .D(n2456), .DE(n192), .CLK(clk), 
        .Q(oam[1070]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_122__7_ ( .D(n2472), .DE(n192), .CLK(clk), 
        .Q(oam[1071]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_122__0_ ( .D(n2390), .DE(n192), .CLK(clk), 
        .Q(oam[1064]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_138__1_ ( .D(n2406), .DE(n164), .CLK(clk), 
        .Q(oam[937]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_138__5_ ( .D(n2440), .DE(n164), .CLK(clk), 
        .Q(oam[941]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_138__6_ ( .D(n2456), .DE(n164), .CLK(clk), 
        .Q(oam[942]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_138__7_ ( .D(n2472), .DE(n164), .CLK(clk), 
        .Q(oam[943]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_138__0_ ( .D(n2390), .DE(n164), .CLK(clk), 
        .Q(oam[936]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_154__1_ ( .D(n2406), .DE(n196), .CLK(clk), 
        .Q(oam[809]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_154__5_ ( .D(n2440), .DE(n196), .CLK(clk), 
        .Q(oam[813]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_154__6_ ( .D(n2456), .DE(n196), .CLK(clk), 
        .Q(oam[814]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_154__7_ ( .D(n2472), .DE(n196), .CLK(clk), 
        .Q(oam[815]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_154__0_ ( .D(n2390), .DE(n196), .CLK(clk), 
        .Q(oam[808]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_174__1_ ( .D(n2406), .DE(n418), .CLK(clk), 
        .Q(oam[649]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_174__5_ ( .D(n2440), .DE(n418), .CLK(clk), 
        .Q(oam[653]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_174__6_ ( .D(n2456), .DE(n418), .CLK(clk), 
        .Q(oam[654]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_174__7_ ( .D(n2472), .DE(n418), .CLK(clk), 
        .Q(oam[655]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_174__0_ ( .D(n2390), .DE(n418), .CLK(clk), 
        .Q(oam[648]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_190__1_ ( .D(n2406), .DE(n417), .CLK(clk), 
        .Q(oam[521]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_190__5_ ( .D(n2440), .DE(n417), .CLK(clk), 
        .Q(oam[525]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_190__6_ ( .D(n2456), .DE(n417), .CLK(clk), 
        .Q(oam[526]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_190__7_ ( .D(n2472), .DE(n417), .CLK(clk), 
        .Q(oam[527]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_190__0_ ( .D(n2390), .DE(n417), .CLK(clk), 
        .Q(oam[520]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_206__1_ ( .D(n2406), .DE(n413), .CLK(clk), 
        .Q(oam[393]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_206__5_ ( .D(n2440), .DE(n413), .CLK(clk), 
        .Q(oam[397]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_206__6_ ( .D(n2456), .DE(n413), .CLK(clk), 
        .Q(oam[398]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_206__7_ ( .D(n2472), .DE(n413), .CLK(clk), 
        .Q(oam[399]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_206__0_ ( .D(n2390), .DE(n413), .CLK(clk), 
        .Q(oam[392]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_222__1_ ( .D(n2406), .DE(n412), .CLK(clk), 
        .Q(oam[265]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_222__5_ ( .D(n2440), .DE(n412), .CLK(clk), 
        .Q(oam[269]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_222__6_ ( .D(n2456), .DE(n412), .CLK(clk), 
        .Q(oam[270]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_222__7_ ( .D(n2472), .DE(n412), .CLK(clk), 
        .Q(oam[271]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_222__0_ ( .D(n2390), .DE(n412), .CLK(clk), 
        .Q(oam[264]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_238__1_ ( .D(n2406), .DE(n416), .CLK(clk), 
        .Q(oam[137]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_238__5_ ( .D(n2440), .DE(n416), .CLK(clk), 
        .Q(oam[141]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_238__6_ ( .D(n2456), .DE(n416), .CLK(clk), 
        .Q(oam[142]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_238__7_ ( .D(n2472), .DE(n416), .CLK(clk), 
        .Q(oam[143]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_238__0_ ( .D(n2390), .DE(n416), .CLK(clk), 
        .Q(oam[136]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_254__1_ ( .D(n2406), .DE(n415), .CLK(clk), 
        .Q(oam[9]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_254__5_ ( .D(n2440), .DE(n415), .CLK(clk), 
        .Q(oam[13]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_254__6_ ( .D(n2456), .DE(n415), .CLK(clk), 
        .Q(oam[14]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_254__7_ ( .D(n2472), .DE(n415), .CLK(clk), 
        .Q(oam[15]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_254__0_ ( .D(n2390), .DE(n415), .CLK(clk), 
        .Q(oam[8]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_14__1_ ( .D(n2405), .DE(n329), .CLK(clk), 
        .Q(oam[1929]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_14__5_ ( .D(n2439), .DE(n329), .CLK(clk), 
        .Q(oam[1933]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_14__6_ ( .D(n2455), .DE(n329), .CLK(clk), 
        .Q(oam[1934]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_14__7_ ( .D(n2471), .DE(n329), .CLK(clk), 
        .Q(oam[1935]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_14__0_ ( .D(n2389), .DE(n329), .CLK(clk), 
        .Q(oam[1928]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_30__1_ ( .D(n2405), .DE(n328), .CLK(clk), 
        .Q(oam[1801]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_30__5_ ( .D(n2439), .DE(n328), .CLK(clk), 
        .Q(oam[1805]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_30__6_ ( .D(n2455), .DE(n328), .CLK(clk), 
        .Q(oam[1806]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_30__7_ ( .D(n2471), .DE(n328), .CLK(clk), 
        .Q(oam[1807]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_30__0_ ( .D(n2389), .DE(n328), .CLK(clk), 
        .Q(oam[1800]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_46__1_ ( .D(n2405), .DE(n411), .CLK(clk), 
        .Q(oam[1673]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_46__5_ ( .D(n2439), .DE(n411), .CLK(clk), 
        .Q(oam[1677]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_46__6_ ( .D(n2455), .DE(n411), .CLK(clk), 
        .Q(oam[1678]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_46__7_ ( .D(n2471), .DE(n411), .CLK(clk), 
        .Q(oam[1679]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_46__0_ ( .D(n2389), .DE(n411), .CLK(clk), 
        .Q(oam[1672]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_62__1_ ( .D(n2405), .DE(n410), .CLK(clk), 
        .Q(oam[1545]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_62__5_ ( .D(n2439), .DE(n410), .CLK(clk), 
        .Q(oam[1549]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_62__6_ ( .D(n2455), .DE(n410), .CLK(clk), 
        .Q(oam[1550]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_62__7_ ( .D(n2471), .DE(n410), .CLK(clk), 
        .Q(oam[1551]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_62__0_ ( .D(n2389), .DE(n410), .CLK(clk), 
        .Q(oam[1544]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_78__1_ ( .D(n2405), .DE(n409), .CLK(clk), 
        .Q(oam[1417]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_78__5_ ( .D(n2439), .DE(n409), .CLK(clk), 
        .Q(oam[1421]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_78__6_ ( .D(n2455), .DE(n409), .CLK(clk), 
        .Q(oam[1422]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_78__7_ ( .D(n2471), .DE(n409), .CLK(clk), 
        .Q(oam[1423]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_78__0_ ( .D(n2389), .DE(n409), .CLK(clk), 
        .Q(oam[1416]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_94__1_ ( .D(n2405), .DE(n408), .CLK(clk), 
        .Q(oam[1289]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_94__5_ ( .D(n2439), .DE(n408), .CLK(clk), 
        .Q(oam[1293]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_94__6_ ( .D(n2455), .DE(n408), .CLK(clk), 
        .Q(oam[1294]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_94__7_ ( .D(n2471), .DE(n408), .CLK(clk), 
        .Q(oam[1295]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_94__0_ ( .D(n2389), .DE(n408), .CLK(clk), 
        .Q(oam[1288]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_110__1_ ( .D(n2405), .DE(n414), .CLK(clk), 
        .Q(oam[1161]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_110__5_ ( .D(n2439), .DE(n414), .CLK(clk), 
        .Q(oam[1165]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_110__6_ ( .D(n2455), .DE(n414), .CLK(clk), 
        .Q(oam[1166]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_110__7_ ( .D(n2471), .DE(n414), .CLK(clk), 
        .Q(oam[1167]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_110__0_ ( .D(n2389), .DE(n414), .CLK(clk), 
        .Q(oam[1160]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_126__1_ ( .D(n2405), .DE(n191), .CLK(clk), 
        .Q(oam[1033]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_126__5_ ( .D(n2439), .DE(n191), .CLK(clk), 
        .Q(oam[1037]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_126__6_ ( .D(n2455), .DE(n191), .CLK(clk), 
        .Q(oam[1038]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_126__7_ ( .D(n2471), .DE(n191), .CLK(clk), 
        .Q(oam[1039]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_126__0_ ( .D(n2389), .DE(n191), .CLK(clk), 
        .Q(oam[1032]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_142__1_ ( .D(n2405), .DE(n163), .CLK(clk), 
        .Q(oam[905]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_142__5_ ( .D(n2439), .DE(n163), .CLK(clk), 
        .Q(oam[909]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_142__6_ ( .D(n2455), .DE(n163), .CLK(clk), 
        .Q(oam[910]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_142__7_ ( .D(n2471), .DE(n163), .CLK(clk), 
        .Q(oam[911]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_142__0_ ( .D(n2389), .DE(n163), .CLK(clk), 
        .Q(oam[904]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_158__1_ ( .D(n2405), .DE(n195), .CLK(clk), 
        .Q(oam[777]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_158__5_ ( .D(n2439), .DE(n195), .CLK(clk), 
        .Q(oam[781]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_158__6_ ( .D(n2455), .DE(n195), .CLK(clk), 
        .Q(oam[782]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_158__7_ ( .D(n2471), .DE(n195), .CLK(clk), 
        .Q(oam[783]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_158__0_ ( .D(n2389), .DE(n195), .CLK(clk), 
        .Q(oam[776]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_178__1_ ( .D(n2405), .DE(n313), .CLK(clk), 
        .Q(oam[617]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_178__5_ ( .D(n2439), .DE(n313), .CLK(clk), 
        .Q(oam[621]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_178__6_ ( .D(n2455), .DE(n313), .CLK(clk), 
        .Q(oam[622]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_178__7_ ( .D(n2471), .DE(n313), .CLK(clk), 
        .Q(oam[623]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_178__0_ ( .D(n2389), .DE(n313), .CLK(clk), 
        .Q(oam[616]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_194__1_ ( .D(n2405), .DE(n308), .CLK(clk), 
        .Q(oam[489]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_194__5_ ( .D(n2439), .DE(n308), .CLK(clk), 
        .Q(oam[493]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_194__6_ ( .D(n2455), .DE(n308), .CLK(clk), 
        .Q(oam[494]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_194__7_ ( .D(n2471), .DE(n308), .CLK(clk), 
        .Q(oam[495]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_194__0_ ( .D(n2389), .DE(n308), .CLK(clk), 
        .Q(oam[488]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_210__1_ ( .D(n2405), .DE(n307), .CLK(clk), 
        .Q(oam[361]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_210__5_ ( .D(n2439), .DE(n307), .CLK(clk), 
        .Q(oam[365]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_210__6_ ( .D(n2455), .DE(n307), .CLK(clk), 
        .Q(oam[366]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_210__7_ ( .D(n2471), .DE(n307), .CLK(clk), 
        .Q(oam[367]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_210__0_ ( .D(n2389), .DE(n307), .CLK(clk), 
        .Q(oam[360]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_226__1_ ( .D(n2405), .DE(n312), .CLK(clk), 
        .Q(oam[233]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_226__5_ ( .D(n2439), .DE(n312), .CLK(clk), 
        .Q(oam[237]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_226__6_ ( .D(n2455), .DE(n312), .CLK(clk), 
        .Q(oam[238]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_226__7_ ( .D(n2471), .DE(n312), .CLK(clk), 
        .Q(oam[239]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_226__0_ ( .D(n2389), .DE(n312), .CLK(clk), 
        .Q(oam[232]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_242__1_ ( .D(n2403), .DE(n311), .CLK(clk), 
        .Q(oam[105]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_242__5_ ( .D(n2438), .DE(n311), .CLK(clk), 
        .Q(oam[109]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_242__6_ ( .D(n2454), .DE(n311), .CLK(clk), 
        .Q(oam[110]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_242__7_ ( .D(n2470), .DE(n311), .CLK(clk), 
        .Q(oam[111]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_242__0_ ( .D(n2388), .DE(n311), .CLK(clk), 
        .Q(oam[104]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_2__1_ ( .D(n2402), .DE(n187), .CLK(clk), 
        .Q(oam[2025]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_2__5_ ( .D(n2436), .DE(n187), .CLK(clk), 
        .Q(oam[2029]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_2__6_ ( .D(n2452), .DE(n187), .CLK(clk), 
        .Q(oam[2030]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_2__7_ ( .D(n2468), .DE(n187), .CLK(clk), 
        .Q(oam[2031]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_2__0_ ( .D(n2386), .DE(n187), .CLK(clk), 
        .Q(oam[2024]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_18__1_ ( .D(n2410), .DE(n198), .CLK(clk), 
        .Q(oam[1897]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_18__5_ ( .D(n2437), .DE(n198), .CLK(clk), 
        .Q(oam[1901]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_18__6_ ( .D(n2453), .DE(n198), .CLK(clk), 
        .Q(oam[1902]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_18__7_ ( .D(n2469), .DE(n198), .CLK(clk), 
        .Q(oam[1903]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_18__0_ ( .D(n2387), .DE(n198), .CLK(clk), 
        .Q(oam[1896]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_34__1_ ( .D(n2409), .DE(n306), .CLK(clk), 
        .Q(oam[1769]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_34__5_ ( .D(n2443), .DE(n306), .CLK(clk), 
        .Q(oam[1773]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_34__6_ ( .D(n2459), .DE(n306), .CLK(clk), 
        .Q(oam[1774]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_34__7_ ( .D(n2475), .DE(n306), .CLK(clk), 
        .Q(oam[1775]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_34__0_ ( .D(n2393), .DE(n306), .CLK(clk), 
        .Q(oam[1768]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_50__1_ ( .D(n2403), .DE(n305), .CLK(clk), 
        .Q(oam[1641]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_50__5_ ( .D(n2438), .DE(n305), .CLK(clk), 
        .Q(oam[1645]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_50__6_ ( .D(n2454), .DE(n305), .CLK(clk), 
        .Q(oam[1646]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_50__7_ ( .D(n2470), .DE(n305), .CLK(clk), 
        .Q(oam[1647]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_50__0_ ( .D(n2388), .DE(n305), .CLK(clk), 
        .Q(oam[1640]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_66__1_ ( .D(n2410), .DE(n304), .CLK(clk), 
        .Q(oam[1513]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_66__5_ ( .D(n2435), .DE(n304), .CLK(clk), 
        .Q(oam[1517]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_66__6_ ( .D(n2451), .DE(n304), .CLK(clk), 
        .Q(oam[1518]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_66__7_ ( .D(n2467), .DE(n304), .CLK(clk), 
        .Q(oam[1519]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_66__0_ ( .D(n2385), .DE(n304), .CLK(clk), 
        .Q(oam[1512]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_82__1_ ( .D(n2405), .DE(n303), .CLK(clk), 
        .Q(oam[1385]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_82__5_ ( .D(n2439), .DE(n303), .CLK(clk), 
        .Q(oam[1389]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_82__6_ ( .D(n2455), .DE(n303), .CLK(clk), 
        .Q(oam[1390]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_82__7_ ( .D(n2471), .DE(n303), .CLK(clk), 
        .Q(oam[1391]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_82__0_ ( .D(n2389), .DE(n303), .CLK(clk), 
        .Q(oam[1384]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_98__1_ ( .D(n2406), .DE(n310), .CLK(clk), 
        .Q(oam[1257]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_98__5_ ( .D(n2440), .DE(n310), .CLK(clk), 
        .Q(oam[1261]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_98__6_ ( .D(n2456), .DE(n310), .CLK(clk), 
        .Q(oam[1262]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_98__7_ ( .D(n2472), .DE(n310), .CLK(clk), 
        .Q(oam[1263]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_98__0_ ( .D(n2390), .DE(n310), .CLK(clk), 
        .Q(oam[1256]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_114__1_ ( .D(n2408), .DE(n190), .CLK(clk), 
        .Q(oam[1129]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_114__5_ ( .D(n2442), .DE(n190), .CLK(clk), 
        .Q(oam[1133]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_114__6_ ( .D(n2458), .DE(n190), .CLK(clk), 
        .Q(oam[1134]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_114__7_ ( .D(n2474), .DE(n190), .CLK(clk), 
        .Q(oam[1135]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_114__0_ ( .D(n2392), .DE(n190), .CLK(clk), 
        .Q(oam[1128]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_130__1_ ( .D(n2407), .DE(n162), .CLK(clk), 
        .Q(oam[1001]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_130__5_ ( .D(n2441), .DE(n162), .CLK(clk), 
        .Q(oam[1005]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_130__6_ ( .D(n2457), .DE(n162), .CLK(clk), 
        .Q(oam[1006]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_130__7_ ( .D(n2473), .DE(n162), .CLK(clk), 
        .Q(oam[1007]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_130__0_ ( .D(n2391), .DE(n162), .CLK(clk), 
        .Q(oam[1000]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_146__1_ ( .D(n2400), .DE(n194), .CLK(clk), 
        .Q(oam[873]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_146__5_ ( .D(n2434), .DE(n194), .CLK(clk), 
        .Q(oam[877]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_146__6_ ( .D(n2450), .DE(n194), .CLK(clk), 
        .Q(oam[878]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_146__7_ ( .D(n2466), .DE(n194), .CLK(clk), 
        .Q(oam[879]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_146__0_ ( .D(n2384), .DE(n194), .CLK(clk), 
        .Q(oam[872]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_162__5_ ( .D(n2435), .DE(n309), .CLK(clk), 
        .Q(oam[749]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_162__6_ ( .D(n2451), .DE(n309), .CLK(clk), 
        .Q(oam[750]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_162__7_ ( .D(n2467), .DE(n309), .CLK(clk), 
        .Q(oam[751]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_162__1_ ( .D(n2401), .DE(n309), .CLK(clk), 
        .Q(oam[745]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_162__0_ ( .D(n2385), .DE(n309), .CLK(clk), 
        .Q(oam[744]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__1_ ( .D(n2404), .DE(n255), .CLK(clk), 
        .Q(oam[729]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__2_ ( .D(n2420), .DE(n255), .CLK(clk), 
        .Q(oam[730]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__3_ ( .D(n2426), .DE(n255), .CLK(clk), 
        .Q(oam[731]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__4_ ( .D(n2432), .DE(n255), .CLK(clk), 
        .Q(oam[732]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__5_ ( .D(n2437), .DE(n255), .CLK(clk), 
        .Q(oam[733]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__6_ ( .D(n2453), .DE(n255), .CLK(clk), 
        .Q(oam[734]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__7_ ( .D(n2469), .DE(n255), .CLK(clk), 
        .Q(oam[735]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_164__0_ ( .D(n2387), .DE(n255), .CLK(clk), 
        .Q(oam[728]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__1_ ( .D(n2402), .DE(n254), .CLK(clk), 
        .Q(oam[601]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__2_ ( .D(n2420), .DE(n254), .CLK(clk), 
        .Q(oam[602]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__3_ ( .D(n2426), .DE(n254), .CLK(clk), 
        .Q(oam[603]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__4_ ( .D(n2432), .DE(n254), .CLK(clk), 
        .Q(oam[604]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__5_ ( .D(n2436), .DE(n254), .CLK(clk), 
        .Q(oam[605]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__6_ ( .D(n2452), .DE(n254), .CLK(clk), 
        .Q(oam[606]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__7_ ( .D(n2468), .DE(n254), .CLK(clk), 
        .Q(oam[607]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_180__0_ ( .D(n2386), .DE(n254), .CLK(clk), 
        .Q(oam[600]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__1_ ( .D(n2406), .DE(n245), .CLK(clk), 
        .Q(oam[473]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__2_ ( .D(n2417), .DE(n245), .CLK(clk), 
        .Q(oam[474]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__3_ ( .D(n2425), .DE(n245), .CLK(clk), 
        .Q(oam[475]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__4_ ( .D(n2431), .DE(n245), .CLK(clk), 
        .Q(oam[476]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__5_ ( .D(n2440), .DE(n245), .CLK(clk), 
        .Q(oam[477]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__6_ ( .D(n2456), .DE(n245), .CLK(clk), 
        .Q(oam[478]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__7_ ( .D(n2472), .DE(n245), .CLK(clk), 
        .Q(oam[479]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_196__0_ ( .D(n2390), .DE(n245), .CLK(clk), 
        .Q(oam[472]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__1_ ( .D(n2405), .DE(n244), .CLK(clk), 
        .Q(oam[345]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__2_ ( .D(n2416), .DE(n244), .CLK(clk), 
        .Q(oam[346]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__3_ ( .D(n2425), .DE(n244), .CLK(clk), 
        .Q(oam[347]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__4_ ( .D(n2431), .DE(n244), .CLK(clk), 
        .Q(oam[348]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__5_ ( .D(n2439), .DE(n244), .CLK(clk), 
        .Q(oam[349]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__6_ ( .D(n2455), .DE(n244), .CLK(clk), 
        .Q(oam[350]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__7_ ( .D(n2471), .DE(n244), .CLK(clk), 
        .Q(oam[351]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_212__0_ ( .D(n2389), .DE(n244), .CLK(clk), 
        .Q(oam[344]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__1_ ( .D(n2408), .DE(n253), .CLK(clk), 
        .Q(oam[217]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__2_ ( .D(n2420), .DE(n253), .CLK(clk), 
        .Q(oam[218]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__3_ ( .D(n2425), .DE(n253), .CLK(clk), 
        .Q(oam[219]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__4_ ( .D(n2431), .DE(n253), .CLK(clk), 
        .Q(oam[220]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__5_ ( .D(n2442), .DE(n253), .CLK(clk), 
        .Q(oam[221]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__6_ ( .D(n2458), .DE(n253), .CLK(clk), 
        .Q(oam[222]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__7_ ( .D(n2474), .DE(n253), .CLK(clk), 
        .Q(oam[223]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_228__0_ ( .D(n2392), .DE(n253), .CLK(clk), 
        .Q(oam[216]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__1_ ( .D(n2407), .DE(n252), .CLK(clk), 
        .Q(oam[89]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__2_ ( .D(n2419), .DE(n252), .CLK(clk), 
        .Q(oam[90]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__3_ ( .D(n2425), .DE(n252), .CLK(clk), 
        .Q(oam[91]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__4_ ( .D(n2431), .DE(n252), .CLK(clk), 
        .Q(oam[92]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__5_ ( .D(n2441), .DE(n252), .CLK(clk), 
        .Q(oam[93]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__6_ ( .D(n2457), .DE(n252), .CLK(clk), 
        .Q(oam[94]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__7_ ( .D(n2473), .DE(n252), .CLK(clk), 
        .Q(oam[95]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_244__0_ ( .D(n2391), .DE(n252), .CLK(clk), 
        .Q(oam[88]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__1_ ( .D(n2408), .DE(n149), .CLK(clk), 
        .Q(oam[2009]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__2_ ( .D(n2420), .DE(n149), .CLK(clk), 
        .Q(oam[2010]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__3_ ( .D(n2425), .DE(n149), .CLK(clk), 
        .Q(oam[2011]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__4_ ( .D(n2431), .DE(n149), .CLK(clk), 
        .Q(oam[2012]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__5_ ( .D(n2442), .DE(n149), .CLK(clk), 
        .Q(oam[2013]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__6_ ( .D(n2458), .DE(n149), .CLK(clk), 
        .Q(oam[2014]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__7_ ( .D(n2474), .DE(n149), .CLK(clk), 
        .Q(oam[2015]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_4__0_ ( .D(n2392), .DE(n149), .CLK(clk), 
        .Q(oam[2008]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__1_ ( .D(n2407), .DE(n185), .CLK(clk), 
        .Q(oam[1881]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__2_ ( .D(n2419), .DE(n185), .CLK(clk), 
        .Q(oam[1882]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__3_ ( .D(n2425), .DE(n185), .CLK(clk), 
        .Q(oam[1883]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__4_ ( .D(n2431), .DE(n185), .CLK(clk), 
        .Q(oam[1884]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__5_ ( .D(n2441), .DE(n185), .CLK(clk), 
        .Q(oam[1885]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__6_ ( .D(n2457), .DE(n185), .CLK(clk), 
        .Q(oam[1886]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__7_ ( .D(n2473), .DE(n185), .CLK(clk), 
        .Q(oam[1887]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_20__0_ ( .D(n2391), .DE(n185), .CLK(clk), 
        .Q(oam[1880]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__1_ ( .D(n2400), .DE(n243), .CLK(clk), 
        .Q(oam[1753]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__2_ ( .D(n2418), .DE(n243), .CLK(clk), 
        .Q(oam[1754]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__3_ ( .D(n2425), .DE(n243), .CLK(clk), 
        .Q(oam[1755]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__4_ ( .D(n2431), .DE(n243), .CLK(clk), 
        .Q(oam[1756]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__5_ ( .D(n2434), .DE(n243), .CLK(clk), 
        .Q(oam[1757]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__6_ ( .D(n2450), .DE(n243), .CLK(clk), 
        .Q(oam[1758]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__7_ ( .D(n2466), .DE(n243), .CLK(clk), 
        .Q(oam[1759]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_36__0_ ( .D(n2384), .DE(n243), .CLK(clk), 
        .Q(oam[1752]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__1_ ( .D(n2401), .DE(n242), .CLK(clk), 
        .Q(oam[1625]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__2_ ( .D(data_in[2]), .DE(n242), .CLK(
        clk), .Q(oam[1626]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__3_ ( .D(n2425), .DE(n242), .CLK(clk), 
        .Q(oam[1627]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__4_ ( .D(n2431), .DE(n242), .CLK(clk), 
        .Q(oam[1628]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__5_ ( .D(n2435), .DE(n242), .CLK(clk), 
        .Q(oam[1629]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__6_ ( .D(n2451), .DE(n242), .CLK(clk), 
        .Q(oam[1630]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__7_ ( .D(n2467), .DE(n242), .CLK(clk), 
        .Q(oam[1631]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_52__0_ ( .D(n2385), .DE(n242), .CLK(clk), 
        .Q(oam[1624]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__1_ ( .D(n2403), .DE(n241), .CLK(clk), 
        .Q(oam[1497]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__2_ ( .D(n2417), .DE(n241), .CLK(clk), 
        .Q(oam[1498]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__3_ ( .D(n2425), .DE(n241), .CLK(clk), 
        .Q(oam[1499]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__4_ ( .D(n2431), .DE(n241), .CLK(clk), 
        .Q(oam[1500]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__5_ ( .D(n2438), .DE(n241), .CLK(clk), 
        .Q(oam[1501]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__6_ ( .D(n2454), .DE(n241), .CLK(clk), 
        .Q(oam[1502]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__7_ ( .D(n2470), .DE(n241), .CLK(clk), 
        .Q(oam[1503]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_68__0_ ( .D(n2388), .DE(n241), .CLK(clk), 
        .Q(oam[1496]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__1_ ( .D(n2404), .DE(n240), .CLK(clk), 
        .Q(oam[1369]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__2_ ( .D(n2416), .DE(n240), .CLK(clk), 
        .Q(oam[1370]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__3_ ( .D(n2425), .DE(n240), .CLK(clk), 
        .Q(oam[1371]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__4_ ( .D(n2431), .DE(n240), .CLK(clk), 
        .Q(oam[1372]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__5_ ( .D(n2437), .DE(n240), .CLK(clk), 
        .Q(oam[1373]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__6_ ( .D(n2453), .DE(n240), .CLK(clk), 
        .Q(oam[1374]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__7_ ( .D(n2469), .DE(n240), .CLK(clk), 
        .Q(oam[1375]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_84__0_ ( .D(n2387), .DE(n240), .CLK(clk), 
        .Q(oam[1368]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__1_ ( .D(n2402), .DE(n251), .CLK(clk), 
        .Q(oam[1241]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__2_ ( .D(n2420), .DE(n251), .CLK(clk), 
        .Q(oam[1242]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__3_ ( .D(n2425), .DE(n251), .CLK(clk), 
        .Q(oam[1243]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__4_ ( .D(n2431), .DE(n251), .CLK(clk), 
        .Q(oam[1244]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__5_ ( .D(n2436), .DE(n251), .CLK(clk), 
        .Q(oam[1245]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__6_ ( .D(n2452), .DE(n251), .CLK(clk), 
        .Q(oam[1246]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__7_ ( .D(n2468), .DE(n251), .CLK(clk), 
        .Q(oam[1247]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_100__0_ ( .D(n2386), .DE(n251), .CLK(clk), 
        .Q(oam[1240]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__1_ ( .D(n2410), .DE(n158), .CLK(clk), 
        .Q(oam[1113]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__2_ ( .D(n2419), .DE(n158), .CLK(clk), 
        .Q(oam[1114]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__3_ ( .D(n2425), .DE(n158), .CLK(clk), 
        .Q(oam[1115]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__4_ ( .D(n2431), .DE(n158), .CLK(clk), 
        .Q(oam[1116]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__5_ ( .D(n2438), .DE(n158), .CLK(clk), 
        .Q(oam[1117]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__6_ ( .D(n2454), .DE(n158), .CLK(clk), 
        .Q(oam[1118]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__7_ ( .D(n2470), .DE(n158), .CLK(clk), 
        .Q(oam[1119]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_116__0_ ( .D(n2388), .DE(n158), .CLK(clk), 
        .Q(oam[1112]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__1_ ( .D(n2409), .DE(n139), .CLK(clk), 
        .Q(oam[985]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__2_ ( .D(n2418), .DE(n139), .CLK(clk), 
        .Q(oam[986]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__3_ ( .D(n2425), .DE(n139), .CLK(clk), 
        .Q(oam[987]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__4_ ( .D(n2431), .DE(n139), .CLK(clk), 
        .Q(oam[988]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__5_ ( .D(n2443), .DE(n139), .CLK(clk), 
        .Q(oam[989]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__6_ ( .D(n2459), .DE(n139), .CLK(clk), 
        .Q(oam[990]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__7_ ( .D(n2475), .DE(n139), .CLK(clk), 
        .Q(oam[991]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_132__0_ ( .D(n2393), .DE(n139), .CLK(clk), 
        .Q(oam[984]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__1_ ( .D(n2401), .DE(n179), .CLK(clk), 
        .Q(oam[857]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__2_ ( .D(data_in[2]), .DE(n179), .CLK(
        clk), .Q(oam[858]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__3_ ( .D(n2425), .DE(n179), .CLK(clk), 
        .Q(oam[859]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__4_ ( .D(n2431), .DE(n179), .CLK(clk), 
        .Q(oam[860]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__5_ ( .D(n2435), .DE(n179), .CLK(clk), 
        .Q(oam[861]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__6_ ( .D(n2451), .DE(n179), .CLK(clk), 
        .Q(oam[862]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__7_ ( .D(n2467), .DE(n179), .CLK(clk), 
        .Q(oam[863]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_148__0_ ( .D(n2385), .DE(n179), .CLK(clk), 
        .Q(oam[856]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__1_ ( .D(n2402), .DE(n352), .CLK(clk), 
        .Q(oam[697]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__2_ ( .D(n2417), .DE(n352), .CLK(clk), 
        .Q(oam[698]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__3_ ( .D(n2423), .DE(n352), .CLK(clk), 
        .Q(oam[699]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__4_ ( .D(n2429), .DE(n352), .CLK(clk), 
        .Q(oam[700]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__5_ ( .D(n2436), .DE(n352), .CLK(clk), 
        .Q(oam[701]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__6_ ( .D(n2452), .DE(n352), .CLK(clk), 
        .Q(oam[702]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__7_ ( .D(n2468), .DE(n352), .CLK(clk), 
        .Q(oam[703]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_168__0_ ( .D(n2386), .DE(n352), .CLK(clk), 
        .Q(oam[696]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__1_ ( .D(n2410), .DE(n351), .CLK(clk), 
        .Q(oam[569]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__2_ ( .D(data_in[2]), .DE(n351), .CLK(
        clk), .Q(oam[570]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__3_ ( .D(n2425), .DE(n351), .CLK(clk), 
        .Q(oam[571]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__4_ ( .D(n2431), .DE(n351), .CLK(clk), 
        .Q(oam[572]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__5_ ( .D(n2434), .DE(n351), .CLK(clk), 
        .Q(oam[573]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__6_ ( .D(n2450), .DE(n351), .CLK(clk), 
        .Q(oam[574]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__7_ ( .D(n2466), .DE(n351), .CLK(clk), 
        .Q(oam[575]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_184__0_ ( .D(n2384), .DE(n351), .CLK(clk), 
        .Q(oam[568]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__1_ ( .D(n2409), .DE(n342), .CLK(clk), 
        .Q(oam[441]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__2_ ( .D(n2420), .DE(n342), .CLK(clk), 
        .Q(oam[442]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__3_ ( .D(n2426), .DE(n342), .CLK(clk), 
        .Q(oam[443]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__4_ ( .D(n2432), .DE(n342), .CLK(clk), 
        .Q(oam[444]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__5_ ( .D(n2443), .DE(n342), .CLK(clk), 
        .Q(oam[445]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__6_ ( .D(n2459), .DE(n342), .CLK(clk), 
        .Q(oam[446]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__7_ ( .D(n2475), .DE(n342), .CLK(clk), 
        .Q(oam[447]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_200__0_ ( .D(n2393), .DE(n342), .CLK(clk), 
        .Q(oam[440]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__1_ ( .D(n2406), .DE(n341), .CLK(clk), 
        .Q(oam[313]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__2_ ( .D(n2419), .DE(n341), .CLK(clk), 
        .Q(oam[314]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__3_ ( .D(n2423), .DE(n341), .CLK(clk), 
        .Q(oam[315]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__4_ ( .D(n2429), .DE(n341), .CLK(clk), 
        .Q(oam[316]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__5_ ( .D(n2440), .DE(n341), .CLK(clk), 
        .Q(oam[317]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__6_ ( .D(n2456), .DE(n341), .CLK(clk), 
        .Q(oam[318]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__7_ ( .D(n2472), .DE(n341), .CLK(clk), 
        .Q(oam[319]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_216__0_ ( .D(n2390), .DE(n341), .CLK(clk), 
        .Q(oam[312]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__1_ ( .D(n2405), .DE(n350), .CLK(clk), 
        .Q(oam[185]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__2_ ( .D(n2417), .DE(n350), .CLK(clk), 
        .Q(oam[186]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__3_ ( .D(n2422), .DE(n350), .CLK(clk), 
        .Q(oam[187]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__4_ ( .D(n2428), .DE(n350), .CLK(clk), 
        .Q(oam[188]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__5_ ( .D(n2439), .DE(n350), .CLK(clk), 
        .Q(oam[189]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__6_ ( .D(n2455), .DE(n350), .CLK(clk), 
        .Q(oam[190]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__7_ ( .D(n2471), .DE(n350), .CLK(clk), 
        .Q(oam[191]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_232__0_ ( .D(n2389), .DE(n350), .CLK(clk), 
        .Q(oam[184]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__1_ ( .D(n2408), .DE(n349), .CLK(clk), 
        .Q(oam[57]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__2_ ( .D(n2418), .DE(n349), .CLK(clk), 
        .Q(oam[58]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__3_ ( .D(n2424), .DE(n349), .CLK(clk), 
        .Q(oam[59]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__4_ ( .D(n2430), .DE(n349), .CLK(clk), 
        .Q(oam[60]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__5_ ( .D(n2442), .DE(n349), .CLK(clk), 
        .Q(oam[61]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__6_ ( .D(n2458), .DE(n349), .CLK(clk), 
        .Q(oam[62]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__7_ ( .D(n2474), .DE(n349), .CLK(clk), 
        .Q(oam[63]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_248__0_ ( .D(n2392), .DE(n349), .CLK(clk), 
        .Q(oam[56]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__1_ ( .D(n2406), .DE(n323), .CLK(clk), 
        .Q(oam[1977]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__2_ ( .D(n2419), .DE(n323), .CLK(clk), 
        .Q(oam[1978]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__3_ ( .D(data_in[3]), .DE(n323), .CLK(
        clk), .Q(oam[1979]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__4_ ( .D(data_in[4]), .DE(n323), .CLK(
        clk), .Q(oam[1980]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__5_ ( .D(n2440), .DE(n323), .CLK(clk), 
        .Q(oam[1981]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__6_ ( .D(n2456), .DE(n323), .CLK(clk), 
        .Q(oam[1982]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__7_ ( .D(n2472), .DE(n323), .CLK(clk), 
        .Q(oam[1983]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_8__0_ ( .D(n2390), .DE(n323), .CLK(clk), 
        .Q(oam[1976]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__1_ ( .D(n2405), .DE(n322), .CLK(clk), 
        .Q(oam[1849]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__2_ ( .D(data_in[2]), .DE(n322), .CLK(
        clk), .Q(oam[1850]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__3_ ( .D(n2423), .DE(n322), .CLK(clk), 
        .Q(oam[1851]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__4_ ( .D(n2429), .DE(n322), .CLK(clk), 
        .Q(oam[1852]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__5_ ( .D(n2439), .DE(n322), .CLK(clk), 
        .Q(oam[1853]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__6_ ( .D(n2455), .DE(n322), .CLK(clk), 
        .Q(oam[1854]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__7_ ( .D(n2471), .DE(n322), .CLK(clk), 
        .Q(oam[1855]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_24__0_ ( .D(n2389), .DE(n322), .CLK(clk), 
        .Q(oam[1848]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__1_ ( .D(n2408), .DE(n340), .CLK(clk), 
        .Q(oam[1721]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__2_ ( .D(n2418), .DE(n340), .CLK(clk), 
        .Q(oam[1722]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__3_ ( .D(n2424), .DE(n340), .CLK(clk), 
        .Q(oam[1723]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__4_ ( .D(n2430), .DE(n340), .CLK(clk), 
        .Q(oam[1724]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__5_ ( .D(n2442), .DE(n340), .CLK(clk), 
        .Q(oam[1725]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__6_ ( .D(n2458), .DE(n340), .CLK(clk), 
        .Q(oam[1726]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__7_ ( .D(n2474), .DE(n340), .CLK(clk), 
        .Q(oam[1727]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_40__0_ ( .D(n2392), .DE(n340), .CLK(clk), 
        .Q(oam[1720]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__1_ ( .D(n2407), .DE(n339), .CLK(clk), 
        .Q(oam[1593]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__2_ ( .D(n2417), .DE(n339), .CLK(clk), 
        .Q(oam[1594]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__3_ ( .D(n2423), .DE(n339), .CLK(clk), 
        .Q(oam[1595]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__4_ ( .D(n2429), .DE(n339), .CLK(clk), 
        .Q(oam[1596]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__5_ ( .D(n2441), .DE(n339), .CLK(clk), 
        .Q(oam[1597]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__6_ ( .D(n2457), .DE(n339), .CLK(clk), 
        .Q(oam[1598]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__7_ ( .D(n2473), .DE(n339), .CLK(clk), 
        .Q(oam[1599]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_56__0_ ( .D(n2391), .DE(n339), .CLK(clk), 
        .Q(oam[1592]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__1_ ( .D(n2400), .DE(n338), .CLK(clk), 
        .Q(oam[1465]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__2_ ( .D(n2416), .DE(n338), .CLK(clk), 
        .Q(oam[1466]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__3_ ( .D(n2422), .DE(n338), .CLK(clk), 
        .Q(oam[1467]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__4_ ( .D(n2428), .DE(n338), .CLK(clk), 
        .Q(oam[1468]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__5_ ( .D(n2434), .DE(n338), .CLK(clk), 
        .Q(oam[1469]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__6_ ( .D(n2450), .DE(n338), .CLK(clk), 
        .Q(oam[1470]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__7_ ( .D(n2466), .DE(n338), .CLK(clk), 
        .Q(oam[1471]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_72__0_ ( .D(n2384), .DE(n338), .CLK(clk), 
        .Q(oam[1464]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__1_ ( .D(n2401), .DE(n337), .CLK(clk), 
        .Q(oam[1337]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__2_ ( .D(n2420), .DE(n337), .CLK(clk), 
        .Q(oam[1338]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__3_ ( .D(n2426), .DE(n337), .CLK(clk), 
        .Q(oam[1339]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__4_ ( .D(n2432), .DE(n337), .CLK(clk), 
        .Q(oam[1340]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__5_ ( .D(n2435), .DE(n337), .CLK(clk), 
        .Q(oam[1341]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__6_ ( .D(n2451), .DE(n337), .CLK(clk), 
        .Q(oam[1342]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__7_ ( .D(n2467), .DE(n337), .CLK(clk), 
        .Q(oam[1343]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_88__0_ ( .D(n2385), .DE(n337), .CLK(clk), 
        .Q(oam[1336]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__1_ ( .D(n2403), .DE(n348), .CLK(clk), 
        .Q(oam[1209]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__2_ ( .D(n2420), .DE(n348), .CLK(clk), 
        .Q(oam[1210]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__3_ ( .D(n2426), .DE(n348), .CLK(clk), 
        .Q(oam[1211]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__4_ ( .D(n2432), .DE(n348), .CLK(clk), 
        .Q(oam[1212]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__5_ ( .D(n2438), .DE(n348), .CLK(clk), 
        .Q(oam[1213]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__6_ ( .D(n2454), .DE(n348), .CLK(clk), 
        .Q(oam[1214]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__7_ ( .D(n2470), .DE(n348), .CLK(clk), 
        .Q(oam[1215]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_104__0_ ( .D(n2388), .DE(n348), .CLK(clk), 
        .Q(oam[1208]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__1_ ( .D(n2404), .DE(n157), .CLK(clk), 
        .Q(oam[1081]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__2_ ( .D(n2418), .DE(n157), .CLK(clk), 
        .Q(oam[1082]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__3_ ( .D(n2424), .DE(n157), .CLK(clk), 
        .Q(oam[1083]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__4_ ( .D(n2430), .DE(n157), .CLK(clk), 
        .Q(oam[1084]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__5_ ( .D(n2437), .DE(n157), .CLK(clk), 
        .Q(oam[1085]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__6_ ( .D(n2453), .DE(n157), .CLK(clk), 
        .Q(oam[1086]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__7_ ( .D(n2469), .DE(n157), .CLK(clk), 
        .Q(oam[1087]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_120__0_ ( .D(n2387), .DE(n157), .CLK(clk), 
        .Q(oam[1080]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__1_ ( .D(n2404), .DE(n138), .CLK(clk), 
        .Q(oam[953]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__2_ ( .D(n2417), .DE(n138), .CLK(clk), 
        .Q(oam[954]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__3_ ( .D(n2423), .DE(n138), .CLK(clk), 
        .Q(oam[955]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__4_ ( .D(n2429), .DE(n138), .CLK(clk), 
        .Q(oam[956]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__5_ ( .D(n2438), .DE(n138), .CLK(clk), 
        .Q(oam[957]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__6_ ( .D(n2454), .DE(n138), .CLK(clk), 
        .Q(oam[958]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__7_ ( .D(n2470), .DE(n138), .CLK(clk), 
        .Q(oam[959]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_136__0_ ( .D(n2388), .DE(n138), .CLK(clk), 
        .Q(oam[952]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__1_ ( .D(n2404), .DE(n178), .CLK(clk), 
        .Q(oam[825]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__2_ ( .D(n2419), .DE(n178), .CLK(clk), 
        .Q(oam[826]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__3_ ( .D(n2422), .DE(n178), .CLK(clk), 
        .Q(oam[827]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__4_ ( .D(n2428), .DE(n178), .CLK(clk), 
        .Q(oam[828]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__5_ ( .D(n2438), .DE(n178), .CLK(clk), 
        .Q(oam[829]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__6_ ( .D(n2454), .DE(n178), .CLK(clk), 
        .Q(oam[830]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__7_ ( .D(n2470), .DE(n178), .CLK(clk), 
        .Q(oam[831]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_152__0_ ( .D(n2388), .DE(n178), .CLK(clk), 
        .Q(oam[824]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__1_ ( .D(n2404), .DE(n385), .CLK(clk), 
        .Q(oam[665]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__2_ ( .D(n2416), .DE(n385), .CLK(clk), 
        .Q(oam[666]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__3_ ( .D(n2422), .DE(n385), .CLK(clk), 
        .Q(oam[667]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__4_ ( .D(n2428), .DE(n385), .CLK(clk), 
        .Q(oam[668]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__5_ ( .D(n2438), .DE(n385), .CLK(clk), 
        .Q(oam[669]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__6_ ( .D(n2454), .DE(n385), .CLK(clk), 
        .Q(oam[670]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__7_ ( .D(n2470), .DE(n385), .CLK(clk), 
        .Q(oam[671]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_172__0_ ( .D(n2388), .DE(n385), .CLK(clk), 
        .Q(oam[664]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__1_ ( .D(n2404), .DE(n384), .CLK(clk), 
        .Q(oam[537]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__2_ ( .D(n2416), .DE(n384), .CLK(clk), 
        .Q(oam[538]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__3_ ( .D(n2422), .DE(n384), .CLK(clk), 
        .Q(oam[539]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__4_ ( .D(n2428), .DE(n384), .CLK(clk), 
        .Q(oam[540]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__5_ ( .D(n2438), .DE(n384), .CLK(clk), 
        .Q(oam[541]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__6_ ( .D(n2454), .DE(n384), .CLK(clk), 
        .Q(oam[542]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__7_ ( .D(n2470), .DE(n384), .CLK(clk), 
        .Q(oam[543]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_188__0_ ( .D(n2388), .DE(n384), .CLK(clk), 
        .Q(oam[536]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__1_ ( .D(n2404), .DE(n375), .CLK(clk), 
        .Q(oam[409]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__2_ ( .D(n2416), .DE(n375), .CLK(clk), 
        .Q(oam[410]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__3_ ( .D(n2422), .DE(n375), .CLK(clk), 
        .Q(oam[411]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__4_ ( .D(n2428), .DE(n375), .CLK(clk), 
        .Q(oam[412]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__5_ ( .D(n2438), .DE(n375), .CLK(clk), 
        .Q(oam[413]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__6_ ( .D(n2454), .DE(n375), .CLK(clk), 
        .Q(oam[414]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__7_ ( .D(n2470), .DE(n375), .CLK(clk), 
        .Q(oam[415]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_204__0_ ( .D(n2388), .DE(n375), .CLK(clk), 
        .Q(oam[408]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__1_ ( .D(n2404), .DE(n374), .CLK(clk), 
        .Q(oam[281]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__2_ ( .D(n2419), .DE(n374), .CLK(clk), 
        .Q(oam[282]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__3_ ( .D(n2425), .DE(n374), .CLK(clk), 
        .Q(oam[283]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__4_ ( .D(n2431), .DE(n374), .CLK(clk), 
        .Q(oam[284]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__5_ ( .D(n2438), .DE(n374), .CLK(clk), 
        .Q(oam[285]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__6_ ( .D(n2454), .DE(n374), .CLK(clk), 
        .Q(oam[286]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__7_ ( .D(n2470), .DE(n374), .CLK(clk), 
        .Q(oam[287]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_220__0_ ( .D(n2388), .DE(n374), .CLK(clk), 
        .Q(oam[280]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__1_ ( .D(n2404), .DE(n383), .CLK(clk), 
        .Q(oam[153]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__2_ ( .D(n2420), .DE(n383), .CLK(clk), 
        .Q(oam[154]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__3_ ( .D(n2426), .DE(n383), .CLK(clk), 
        .Q(oam[155]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__4_ ( .D(n2432), .DE(n383), .CLK(clk), 
        .Q(oam[156]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__5_ ( .D(n2438), .DE(n383), .CLK(clk), 
        .Q(oam[157]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__6_ ( .D(n2454), .DE(n383), .CLK(clk), 
        .Q(oam[158]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__7_ ( .D(n2470), .DE(n383), .CLK(clk), 
        .Q(oam[159]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_236__0_ ( .D(n2388), .DE(n383), .CLK(clk), 
        .Q(oam[152]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__1_ ( .D(n2404), .DE(n382), .CLK(clk), 
        .Q(oam[25]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__2_ ( .D(n2419), .DE(n382), .CLK(clk), 
        .Q(oam[26]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__3_ ( .D(n2425), .DE(n382), .CLK(clk), 
        .Q(oam[27]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__4_ ( .D(n2431), .DE(n382), .CLK(clk), 
        .Q(oam[28]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__5_ ( .D(n2438), .DE(n382), .CLK(clk), 
        .Q(oam[29]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__6_ ( .D(n2454), .DE(n382), .CLK(clk), 
        .Q(oam[30]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__7_ ( .D(n2470), .DE(n382), .CLK(clk), 
        .Q(oam[31]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_252__0_ ( .D(n2388), .DE(n382), .CLK(clk), 
        .Q(oam[24]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__1_ ( .D(n2404), .DE(n321), .CLK(clk), 
        .Q(oam[1945]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__2_ ( .D(n2420), .DE(n321), .CLK(clk), 
        .Q(oam[1946]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__3_ ( .D(n2426), .DE(n321), .CLK(clk), 
        .Q(oam[1947]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__4_ ( .D(n2432), .DE(n321), .CLK(clk), 
        .Q(oam[1948]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__5_ ( .D(n2438), .DE(n321), .CLK(clk), 
        .Q(oam[1949]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__6_ ( .D(n2454), .DE(n321), .CLK(clk), 
        .Q(oam[1950]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__7_ ( .D(n2470), .DE(n321), .CLK(clk), 
        .Q(oam[1951]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_12__0_ ( .D(n2388), .DE(n321), .CLK(clk), 
        .Q(oam[1944]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__1_ ( .D(n2404), .DE(n320), .CLK(clk), 
        .Q(oam[1817]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__2_ ( .D(n2420), .DE(n320), .CLK(clk), 
        .Q(oam[1818]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__3_ ( .D(n2425), .DE(n320), .CLK(clk), 
        .Q(oam[1819]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__4_ ( .D(n2431), .DE(n320), .CLK(clk), 
        .Q(oam[1820]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__5_ ( .D(n2438), .DE(n320), .CLK(clk), 
        .Q(oam[1821]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__6_ ( .D(n2454), .DE(n320), .CLK(clk), 
        .Q(oam[1822]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__7_ ( .D(n2470), .DE(n320), .CLK(clk), 
        .Q(oam[1823]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_28__0_ ( .D(n2388), .DE(n320), .CLK(clk), 
        .Q(oam[1816]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__1_ ( .D(n2404), .DE(n373), .CLK(clk), 
        .Q(oam[1689]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__2_ ( .D(n2419), .DE(n373), .CLK(clk), 
        .Q(oam[1690]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__3_ ( .D(n2424), .DE(n373), .CLK(clk), 
        .Q(oam[1691]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__4_ ( .D(n2430), .DE(n373), .CLK(clk), 
        .Q(oam[1692]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__5_ ( .D(n2438), .DE(n373), .CLK(clk), 
        .Q(oam[1693]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__6_ ( .D(n2454), .DE(n373), .CLK(clk), 
        .Q(oam[1694]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__7_ ( .D(n2470), .DE(n373), .CLK(clk), 
        .Q(oam[1695]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_44__0_ ( .D(n2388), .DE(n373), .CLK(clk), 
        .Q(oam[1688]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__1_ ( .D(n2404), .DE(n372), .CLK(clk), 
        .Q(oam[1561]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__2_ ( .D(n2418), .DE(n372), .CLK(clk), 
        .Q(oam[1562]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__3_ ( .D(n2424), .DE(n372), .CLK(clk), 
        .Q(oam[1563]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__4_ ( .D(n2430), .DE(n372), .CLK(clk), 
        .Q(oam[1564]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__5_ ( .D(n2438), .DE(n372), .CLK(clk), 
        .Q(oam[1565]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__6_ ( .D(n2454), .DE(n372), .CLK(clk), 
        .Q(oam[1566]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__7_ ( .D(n2470), .DE(n372), .CLK(clk), 
        .Q(oam[1567]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_60__0_ ( .D(n2388), .DE(n372), .CLK(clk), 
        .Q(oam[1560]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__1_ ( .D(n2404), .DE(n371), .CLK(clk), 
        .Q(oam[1433]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__2_ ( .D(n2418), .DE(n371), .CLK(clk), 
        .Q(oam[1434]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__3_ ( .D(n2424), .DE(n371), .CLK(clk), 
        .Q(oam[1435]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__4_ ( .D(n2430), .DE(n371), .CLK(clk), 
        .Q(oam[1436]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__5_ ( .D(n2438), .DE(n371), .CLK(clk), 
        .Q(oam[1437]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__6_ ( .D(n2454), .DE(n371), .CLK(clk), 
        .Q(oam[1438]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__7_ ( .D(n2470), .DE(n371), .CLK(clk), 
        .Q(oam[1439]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_76__0_ ( .D(n2388), .DE(n371), .CLK(clk), 
        .Q(oam[1432]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__1_ ( .D(n2404), .DE(n370), .CLK(clk), 
        .Q(oam[1305]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__2_ ( .D(n2417), .DE(n370), .CLK(clk), 
        .Q(oam[1306]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__3_ ( .D(n2423), .DE(n370), .CLK(clk), 
        .Q(oam[1307]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__4_ ( .D(n2429), .DE(n370), .CLK(clk), 
        .Q(oam[1308]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__5_ ( .D(n2438), .DE(n370), .CLK(clk), 
        .Q(oam[1309]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__6_ ( .D(n2454), .DE(n370), .CLK(clk), 
        .Q(oam[1310]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__7_ ( .D(n2470), .DE(n370), .CLK(clk), 
        .Q(oam[1311]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_92__0_ ( .D(n2388), .DE(n370), .CLK(clk), 
        .Q(oam[1304]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__1_ ( .D(n2403), .DE(n381), .CLK(clk), 
        .Q(oam[1177]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__2_ ( .D(n2418), .DE(n381), .CLK(clk), 
        .Q(oam[1178]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__3_ ( .D(n2424), .DE(n381), .CLK(clk), 
        .Q(oam[1179]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__4_ ( .D(n2430), .DE(n381), .CLK(clk), 
        .Q(oam[1180]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__5_ ( .D(n2437), .DE(n381), .CLK(clk), 
        .Q(oam[1181]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__6_ ( .D(n2453), .DE(n381), .CLK(clk), 
        .Q(oam[1182]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__7_ ( .D(n2469), .DE(n381), .CLK(clk), 
        .Q(oam[1183]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_108__0_ ( .D(n2387), .DE(n381), .CLK(clk), 
        .Q(oam[1176]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__1_ ( .D(n2403), .DE(n156), .CLK(clk), 
        .Q(oam[1049]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__2_ ( .D(n2420), .DE(n156), .CLK(clk), 
        .Q(oam[1050]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__3_ ( .D(n2426), .DE(n156), .CLK(clk), 
        .Q(oam[1051]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__4_ ( .D(n2432), .DE(n156), .CLK(clk), 
        .Q(oam[1052]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__5_ ( .D(n2437), .DE(n156), .CLK(clk), 
        .Q(oam[1053]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__6_ ( .D(n2453), .DE(n156), .CLK(clk), 
        .Q(oam[1054]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__7_ ( .D(n2469), .DE(n156), .CLK(clk), 
        .Q(oam[1055]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_124__0_ ( .D(n2387), .DE(n156), .CLK(clk), 
        .Q(oam[1048]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__1_ ( .D(n2403), .DE(n137), .CLK(clk), 
        .Q(oam[921]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__2_ ( .D(n2416), .DE(n137), .CLK(clk), 
        .Q(oam[922]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__3_ ( .D(n2425), .DE(n137), .CLK(clk), 
        .Q(oam[923]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__4_ ( .D(n2431), .DE(n137), .CLK(clk), 
        .Q(oam[924]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__5_ ( .D(n2437), .DE(n137), .CLK(clk), 
        .Q(oam[925]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__6_ ( .D(n2453), .DE(n137), .CLK(clk), 
        .Q(oam[926]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__7_ ( .D(n2469), .DE(n137), .CLK(clk), 
        .Q(oam[927]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_140__0_ ( .D(n2387), .DE(n137), .CLK(clk), 
        .Q(oam[920]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__1_ ( .D(n2403), .DE(n177), .CLK(clk), 
        .Q(oam[793]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__2_ ( .D(n2419), .DE(n177), .CLK(clk), 
        .Q(oam[794]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__3_ ( .D(n2425), .DE(n177), .CLK(clk), 
        .Q(oam[795]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__4_ ( .D(n2431), .DE(n177), .CLK(clk), 
        .Q(oam[796]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__5_ ( .D(n2437), .DE(n177), .CLK(clk), 
        .Q(oam[797]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__6_ ( .D(n2453), .DE(n177), .CLK(clk), 
        .Q(oam[798]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__7_ ( .D(n2469), .DE(n177), .CLK(clk), 
        .Q(oam[799]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_156__0_ ( .D(n2387), .DE(n177), .CLK(clk), 
        .Q(oam[792]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__1_ ( .D(n2403), .DE(n291), .CLK(clk), 
        .Q(oam[633]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__2_ ( .D(n2419), .DE(n291), .CLK(clk), 
        .Q(oam[634]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__3_ ( .D(n2424), .DE(n291), .CLK(clk), 
        .Q(oam[635]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__4_ ( .D(n2430), .DE(n291), .CLK(clk), 
        .Q(oam[636]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__5_ ( .D(n2437), .DE(n291), .CLK(clk), 
        .Q(oam[637]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__6_ ( .D(n2453), .DE(n291), .CLK(clk), 
        .Q(oam[638]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__7_ ( .D(n2469), .DE(n291), .CLK(clk), 
        .Q(oam[639]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_176__0_ ( .D(n2387), .DE(n291), .CLK(clk), 
        .Q(oam[632]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__1_ ( .D(n2403), .DE(n280), .CLK(clk), 
        .Q(oam[505]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__2_ ( .D(n2418), .DE(n280), .CLK(clk), 
        .Q(oam[506]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__3_ ( .D(n2424), .DE(n280), .CLK(clk), 
        .Q(oam[507]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__4_ ( .D(n2430), .DE(n280), .CLK(clk), 
        .Q(oam[508]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__5_ ( .D(n2437), .DE(n280), .CLK(clk), 
        .Q(oam[509]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__6_ ( .D(n2453), .DE(n280), .CLK(clk), 
        .Q(oam[510]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__7_ ( .D(n2469), .DE(n280), .CLK(clk), 
        .Q(oam[511]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_192__0_ ( .D(n2387), .DE(n280), .CLK(clk), 
        .Q(oam[504]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__1_ ( .D(n2403), .DE(n279), .CLK(clk), 
        .Q(oam[377]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__2_ ( .D(n2417), .DE(n279), .CLK(clk), 
        .Q(oam[378]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__3_ ( .D(n2423), .DE(n279), .CLK(clk), 
        .Q(oam[379]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__4_ ( .D(n2429), .DE(n279), .CLK(clk), 
        .Q(oam[380]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__5_ ( .D(n2437), .DE(n279), .CLK(clk), 
        .Q(oam[381]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__6_ ( .D(n2453), .DE(n279), .CLK(clk), 
        .Q(oam[382]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__7_ ( .D(n2469), .DE(n279), .CLK(clk), 
        .Q(oam[383]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_208__0_ ( .D(n2387), .DE(n279), .CLK(clk), 
        .Q(oam[376]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__1_ ( .D(n2403), .DE(n290), .CLK(clk), 
        .Q(oam[249]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__2_ ( .D(n2416), .DE(n290), .CLK(clk), 
        .Q(oam[250]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__3_ ( .D(n2422), .DE(n290), .CLK(clk), 
        .Q(oam[251]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__4_ ( .D(n2428), .DE(n290), .CLK(clk), 
        .Q(oam[252]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__5_ ( .D(n2437), .DE(n290), .CLK(clk), 
        .Q(oam[253]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__6_ ( .D(n2453), .DE(n290), .CLK(clk), 
        .Q(oam[254]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__7_ ( .D(n2469), .DE(n290), .CLK(clk), 
        .Q(oam[255]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_224__0_ ( .D(n2387), .DE(n290), .CLK(clk), 
        .Q(oam[248]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__1_ ( .D(n2403), .DE(n289), .CLK(clk), 
        .Q(oam[121]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__2_ ( .D(n2418), .DE(n289), .CLK(clk), 
        .Q(oam[122]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__3_ ( .D(n2424), .DE(n289), .CLK(clk), 
        .Q(oam[123]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__4_ ( .D(n2430), .DE(n289), .CLK(clk), 
        .Q(oam[124]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__5_ ( .D(n2437), .DE(n289), .CLK(clk), 
        .Q(oam[125]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__6_ ( .D(n2453), .DE(n289), .CLK(clk), 
        .Q(oam[126]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__7_ ( .D(n2469), .DE(n289), .CLK(clk), 
        .Q(oam[127]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_240__0_ ( .D(n2387), .DE(n289), .CLK(clk), 
        .Q(oam[120]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__1_ ( .D(n2403), .DE(n148), .CLK(clk), 
        .Q(oam[2041]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__2_ ( .D(n2417), .DE(n148), .CLK(clk), 
        .Q(oam[2042]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__3_ ( .D(n2423), .DE(n148), .CLK(clk), 
        .Q(oam[2043]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__4_ ( .D(n2429), .DE(n148), .CLK(clk), 
        .Q(oam[2044]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__5_ ( .D(n2437), .DE(n148), .CLK(clk), 
        .Q(oam[2045]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__6_ ( .D(n2453), .DE(n148), .CLK(clk), 
        .Q(oam[2046]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__7_ ( .D(n2469), .DE(n148), .CLK(clk), 
        .Q(oam[2047]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_0__0_ ( .D(n2387), .DE(n148), .CLK(clk), 
        .Q(oam[2040]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__1_ ( .D(n2403), .DE(n184), .CLK(clk), 
        .Q(oam[1913]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__2_ ( .D(n2417), .DE(n184), .CLK(clk), 
        .Q(oam[1914]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__3_ ( .D(n2423), .DE(n184), .CLK(clk), 
        .Q(oam[1915]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__4_ ( .D(n2429), .DE(n184), .CLK(clk), 
        .Q(oam[1916]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__5_ ( .D(n2437), .DE(n184), .CLK(clk), 
        .Q(oam[1917]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__6_ ( .D(n2453), .DE(n184), .CLK(clk), 
        .Q(oam[1918]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__7_ ( .D(n2469), .DE(n184), .CLK(clk), 
        .Q(oam[1919]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_16__0_ ( .D(n2387), .DE(n184), .CLK(clk), 
        .Q(oam[1912]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__1_ ( .D(n2403), .DE(n277), .CLK(clk), 
        .Q(oam[1785]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__2_ ( .D(n2420), .DE(n277), .CLK(clk), 
        .Q(oam[1786]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__3_ ( .D(n2426), .DE(n277), .CLK(clk), 
        .Q(oam[1787]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__4_ ( .D(n2432), .DE(n277), .CLK(clk), 
        .Q(oam[1788]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__5_ ( .D(n2437), .DE(n277), .CLK(clk), 
        .Q(oam[1789]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__6_ ( .D(n2453), .DE(n277), .CLK(clk), 
        .Q(oam[1790]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__7_ ( .D(n2469), .DE(n277), .CLK(clk), 
        .Q(oam[1791]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_32__0_ ( .D(n2387), .DE(n277), .CLK(clk), 
        .Q(oam[1784]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__1_ ( .D(n2403), .DE(n276), .CLK(clk), 
        .Q(oam[1657]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__2_ ( .D(n2417), .DE(n276), .CLK(clk), 
        .Q(oam[1658]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__3_ ( .D(n2425), .DE(n276), .CLK(clk), 
        .Q(oam[1659]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__4_ ( .D(n2431), .DE(n276), .CLK(clk), 
        .Q(oam[1660]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__5_ ( .D(n2437), .DE(n276), .CLK(clk), 
        .Q(oam[1661]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__6_ ( .D(n2453), .DE(n276), .CLK(clk), 
        .Q(oam[1662]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__7_ ( .D(n2469), .DE(n276), .CLK(clk), 
        .Q(oam[1663]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_48__0_ ( .D(n2387), .DE(n276), .CLK(clk), 
        .Q(oam[1656]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__1_ ( .D(n2403), .DE(n275), .CLK(clk), 
        .Q(oam[1529]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__2_ ( .D(n2419), .DE(n275), .CLK(clk), 
        .Q(oam[1530]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__3_ ( .D(n2426), .DE(n275), .CLK(clk), 
        .Q(oam[1531]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__4_ ( .D(n2432), .DE(n275), .CLK(clk), 
        .Q(oam[1532]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__5_ ( .D(n2437), .DE(n275), .CLK(clk), 
        .Q(oam[1533]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__6_ ( .D(n2453), .DE(n275), .CLK(clk), 
        .Q(oam[1534]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__7_ ( .D(n2469), .DE(n275), .CLK(clk), 
        .Q(oam[1535]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_64__0_ ( .D(n2387), .DE(n275), .CLK(clk), 
        .Q(oam[1528]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__1_ ( .D(n2402), .DE(n274), .CLK(clk), 
        .Q(oam[1401]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__2_ ( .D(n2419), .DE(n274), .CLK(clk), 
        .Q(oam[1402]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__3_ ( .D(n2425), .DE(n274), .CLK(clk), 
        .Q(oam[1403]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__4_ ( .D(n2431), .DE(n274), .CLK(clk), 
        .Q(oam[1404]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__5_ ( .D(n2436), .DE(n274), .CLK(clk), 
        .Q(oam[1405]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__6_ ( .D(n2452), .DE(n274), .CLK(clk), 
        .Q(oam[1406]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__7_ ( .D(n2468), .DE(n274), .CLK(clk), 
        .Q(oam[1407]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_80__0_ ( .D(n2386), .DE(n274), .CLK(clk), 
        .Q(oam[1400]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__1_ ( .D(n2402), .DE(n288), .CLK(clk), 
        .Q(oam[1273]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__2_ ( .D(n2419), .DE(n288), .CLK(clk), 
        .Q(oam[1274]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__3_ ( .D(n2424), .DE(n288), .CLK(clk), 
        .Q(oam[1275]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__4_ ( .D(n2430), .DE(n288), .CLK(clk), 
        .Q(oam[1276]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__5_ ( .D(n2436), .DE(n288), .CLK(clk), 
        .Q(oam[1277]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__6_ ( .D(n2452), .DE(n288), .CLK(clk), 
        .Q(oam[1278]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__7_ ( .D(n2468), .DE(n288), .CLK(clk), 
        .Q(oam[1279]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_96__0_ ( .D(n2386), .DE(n288), .CLK(clk), 
        .Q(oam[1272]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__1_ ( .D(n2402), .DE(n155), .CLK(clk), 
        .Q(oam[1145]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__2_ ( .D(n2419), .DE(n155), .CLK(clk), 
        .Q(oam[1146]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__3_ ( .D(data_in[3]), .DE(n155), .CLK(
        clk), .Q(oam[1147]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__4_ ( .D(data_in[4]), .DE(n155), .CLK(
        clk), .Q(oam[1148]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__5_ ( .D(n2436), .DE(n155), .CLK(clk), 
        .Q(oam[1149]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__6_ ( .D(n2452), .DE(n155), .CLK(clk), 
        .Q(oam[1150]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__7_ ( .D(n2468), .DE(n155), .CLK(clk), 
        .Q(oam[1151]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_112__0_ ( .D(n2386), .DE(n155), .CLK(clk), 
        .Q(oam[1144]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__1_ ( .D(n2402), .DE(n136), .CLK(clk), 
        .Q(oam[1017]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__2_ ( .D(n2419), .DE(n136), .CLK(clk), 
        .Q(oam[1018]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__3_ ( .D(n2423), .DE(n136), .CLK(clk), 
        .Q(oam[1019]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__4_ ( .D(n2429), .DE(n136), .CLK(clk), 
        .Q(oam[1020]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__5_ ( .D(n2436), .DE(n136), .CLK(clk), 
        .Q(oam[1021]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__6_ ( .D(n2452), .DE(n136), .CLK(clk), 
        .Q(oam[1022]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__7_ ( .D(n2468), .DE(n136), .CLK(clk), 
        .Q(oam[1023]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_128__0_ ( .D(n2386), .DE(n136), .CLK(clk), 
        .Q(oam[1016]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__1_ ( .D(n2402), .DE(n176), .CLK(clk), 
        .Q(oam[889]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__2_ ( .D(n2419), .DE(n176), .CLK(clk), 
        .Q(oam[890]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__3_ ( .D(n2422), .DE(n176), .CLK(clk), 
        .Q(oam[891]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__4_ ( .D(n2428), .DE(n176), .CLK(clk), 
        .Q(oam[892]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__5_ ( .D(n2436), .DE(n176), .CLK(clk), 
        .Q(oam[893]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__6_ ( .D(n2452), .DE(n176), .CLK(clk), 
        .Q(oam[894]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__7_ ( .D(n2468), .DE(n176), .CLK(clk), 
        .Q(oam[895]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_144__0_ ( .D(n2386), .DE(n176), .CLK(clk), 
        .Q(oam[888]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__1_ ( .D(n2402), .DE(n287), .CLK(clk), 
        .Q(oam[761]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__2_ ( .D(n2419), .DE(n287), .CLK(clk), 
        .Q(oam[762]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__3_ ( .D(n2426), .DE(n287), .CLK(clk), 
        .Q(oam[763]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__4_ ( .D(n2432), .DE(n287), .CLK(clk), 
        .Q(oam[764]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__5_ ( .D(n2436), .DE(n287), .CLK(clk), 
        .Q(oam[765]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__6_ ( .D(n2452), .DE(n287), .CLK(clk), 
        .Q(oam[766]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__7_ ( .D(n2468), .DE(n287), .CLK(clk), 
        .Q(oam[767]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_160__0_ ( .D(n2386), .DE(n287), .CLK(clk), 
        .Q(oam[760]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__1_ ( .D(n2402), .DE(n250), .CLK(clk), 
        .Q(oam[721]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__2_ ( .D(n2419), .DE(n250), .CLK(clk), 
        .Q(oam[722]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__3_ ( .D(data_in[3]), .DE(n250), .CLK(
        clk), .Q(oam[723]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__4_ ( .D(data_in[4]), .DE(n250), .CLK(
        clk), .Q(oam[724]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__5_ ( .D(n2436), .DE(n250), .CLK(clk), 
        .Q(oam[725]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__6_ ( .D(n2452), .DE(n250), .CLK(clk), 
        .Q(oam[726]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__7_ ( .D(n2468), .DE(n250), .CLK(clk), 
        .Q(oam[727]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_165__0_ ( .D(n2386), .DE(n250), .CLK(clk), 
        .Q(oam[720]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__1_ ( .D(n2402), .DE(n249), .CLK(clk), 
        .Q(oam[593]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__2_ ( .D(n2419), .DE(n249), .CLK(clk), 
        .Q(oam[594]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__3_ ( .D(n2423), .DE(n249), .CLK(clk), 
        .Q(oam[595]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__4_ ( .D(n2429), .DE(n249), .CLK(clk), 
        .Q(oam[596]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__5_ ( .D(n2436), .DE(n249), .CLK(clk), 
        .Q(oam[597]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__6_ ( .D(n2452), .DE(n249), .CLK(clk), 
        .Q(oam[598]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__7_ ( .D(n2468), .DE(n249), .CLK(clk), 
        .Q(oam[599]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_181__0_ ( .D(n2386), .DE(n249), .CLK(clk), 
        .Q(oam[592]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__1_ ( .D(n2402), .DE(n239), .CLK(clk), 
        .Q(oam[465]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__2_ ( .D(n2419), .DE(n239), .CLK(clk), 
        .Q(oam[466]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__3_ ( .D(n2422), .DE(n239), .CLK(clk), 
        .Q(oam[467]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__4_ ( .D(n2428), .DE(n239), .CLK(clk), 
        .Q(oam[468]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__5_ ( .D(n2436), .DE(n239), .CLK(clk), 
        .Q(oam[469]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__6_ ( .D(n2452), .DE(n239), .CLK(clk), 
        .Q(oam[470]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__7_ ( .D(n2468), .DE(n239), .CLK(clk), 
        .Q(oam[471]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_197__0_ ( .D(n2386), .DE(n239), .CLK(clk), 
        .Q(oam[464]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__1_ ( .D(n2402), .DE(n238), .CLK(clk), 
        .Q(oam[337]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__2_ ( .D(n2419), .DE(n238), .CLK(clk), 
        .Q(oam[338]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__3_ ( .D(n2426), .DE(n238), .CLK(clk), 
        .Q(oam[339]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__4_ ( .D(n2432), .DE(n238), .CLK(clk), 
        .Q(oam[340]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__5_ ( .D(n2436), .DE(n238), .CLK(clk), 
        .Q(oam[341]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__6_ ( .D(n2452), .DE(n238), .CLK(clk), 
        .Q(oam[342]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__7_ ( .D(n2468), .DE(n238), .CLK(clk), 
        .Q(oam[343]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_213__0_ ( .D(n2386), .DE(n238), .CLK(clk), 
        .Q(oam[336]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__1_ ( .D(n2402), .DE(n248), .CLK(clk), 
        .Q(oam[209]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__2_ ( .D(n2419), .DE(n248), .CLK(clk), 
        .Q(oam[210]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__3_ ( .D(n2425), .DE(n248), .CLK(clk), 
        .Q(oam[211]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__4_ ( .D(n2431), .DE(n248), .CLK(clk), 
        .Q(oam[212]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__5_ ( .D(n2436), .DE(n248), .CLK(clk), 
        .Q(oam[213]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__6_ ( .D(n2452), .DE(n248), .CLK(clk), 
        .Q(oam[214]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__7_ ( .D(n2468), .DE(n248), .CLK(clk), 
        .Q(oam[215]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_229__0_ ( .D(n2386), .DE(n248), .CLK(clk), 
        .Q(oam[208]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__1_ ( .D(n2402), .DE(n247), .CLK(clk), 
        .Q(oam[81]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__2_ ( .D(n2419), .DE(n247), .CLK(clk), 
        .Q(oam[82]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__3_ ( .D(n2424), .DE(n247), .CLK(clk), 
        .Q(oam[83]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__4_ ( .D(n2430), .DE(n247), .CLK(clk), 
        .Q(oam[84]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__5_ ( .D(n2436), .DE(n247), .CLK(clk), 
        .Q(oam[85]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__6_ ( .D(n2452), .DE(n247), .CLK(clk), 
        .Q(oam[86]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__7_ ( .D(n2468), .DE(n247), .CLK(clk), 
        .Q(oam[87]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_245__0_ ( .D(n2386), .DE(n247), .CLK(clk), 
        .Q(oam[80]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__1_ ( .D(n2402), .DE(n147), .CLK(clk), 
        .Q(oam[2001]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__2_ ( .D(n2419), .DE(n147), .CLK(clk), 
        .Q(oam[2002]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__3_ ( .D(n2425), .DE(n147), .CLK(clk), 
        .Q(oam[2003]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__4_ ( .D(n2431), .DE(n147), .CLK(clk), 
        .Q(oam[2004]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__5_ ( .D(n2436), .DE(n147), .CLK(clk), 
        .Q(oam[2005]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__6_ ( .D(n2452), .DE(n147), .CLK(clk), 
        .Q(oam[2006]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__7_ ( .D(n2468), .DE(n147), .CLK(clk), 
        .Q(oam[2007]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_5__0_ ( .D(n2386), .DE(n147), .CLK(clk), 
        .Q(oam[2000]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__1_ ( .D(n2402), .DE(n183), .CLK(clk), 
        .Q(oam[1873]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__2_ ( .D(n2419), .DE(n183), .CLK(clk), 
        .Q(oam[1874]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__3_ ( .D(n2424), .DE(n183), .CLK(clk), 
        .Q(oam[1875]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__4_ ( .D(n2430), .DE(n183), .CLK(clk), 
        .Q(oam[1876]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__5_ ( .D(n2436), .DE(n183), .CLK(clk), 
        .Q(oam[1877]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__6_ ( .D(n2452), .DE(n183), .CLK(clk), 
        .Q(oam[1878]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__7_ ( .D(n2468), .DE(n183), .CLK(clk), 
        .Q(oam[1879]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_21__0_ ( .D(n2386), .DE(n183), .CLK(clk), 
        .Q(oam[1872]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__1_ ( .D(n2405), .DE(n237), .CLK(clk), 
        .Q(oam[1745]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__2_ ( .D(n2420), .DE(n237), .CLK(clk), 
        .Q(oam[1746]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__3_ ( .D(n2425), .DE(n237), .CLK(clk), 
        .Q(oam[1747]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__4_ ( .D(n2431), .DE(n237), .CLK(clk), 
        .Q(oam[1748]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__5_ ( .D(n2439), .DE(n237), .CLK(clk), 
        .Q(oam[1749]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__6_ ( .D(n2455), .DE(n237), .CLK(clk), 
        .Q(oam[1750]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__7_ ( .D(n2471), .DE(n237), .CLK(clk), 
        .Q(oam[1751]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_37__0_ ( .D(n2389), .DE(n237), .CLK(clk), 
        .Q(oam[1744]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__1_ ( .D(n2406), .DE(n236), .CLK(clk), 
        .Q(oam[1617]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__2_ ( .D(data_in[2]), .DE(n236), .CLK(
        clk), .Q(oam[1618]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__3_ ( .D(n2423), .DE(n236), .CLK(clk), 
        .Q(oam[1619]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__4_ ( .D(n2429), .DE(n236), .CLK(clk), 
        .Q(oam[1620]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__5_ ( .D(n2440), .DE(n236), .CLK(clk), 
        .Q(oam[1621]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__6_ ( .D(n2456), .DE(n236), .CLK(clk), 
        .Q(oam[1622]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__7_ ( .D(n2472), .DE(n236), .CLK(clk), 
        .Q(oam[1623]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_53__0_ ( .D(n2390), .DE(n236), .CLK(clk), 
        .Q(oam[1616]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__1_ ( .D(n2408), .DE(n235), .CLK(clk), 
        .Q(oam[1489]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__2_ ( .D(n2419), .DE(n235), .CLK(clk), 
        .Q(oam[1490]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__3_ ( .D(n2424), .DE(n235), .CLK(clk), 
        .Q(oam[1491]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__4_ ( .D(n2430), .DE(n235), .CLK(clk), 
        .Q(oam[1492]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__5_ ( .D(n2442), .DE(n235), .CLK(clk), 
        .Q(oam[1493]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__6_ ( .D(n2458), .DE(n235), .CLK(clk), 
        .Q(oam[1494]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__7_ ( .D(n2474), .DE(n235), .CLK(clk), 
        .Q(oam[1495]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_69__0_ ( .D(n2392), .DE(n235), .CLK(clk), 
        .Q(oam[1488]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__1_ ( .D(n2410), .DE(n234), .CLK(clk), 
        .Q(oam[1361]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__2_ ( .D(n2418), .DE(n234), .CLK(clk), 
        .Q(oam[1362]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__3_ ( .D(data_in[3]), .DE(n234), .CLK(
        clk), .Q(oam[1363]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__4_ ( .D(data_in[4]), .DE(n234), .CLK(
        clk), .Q(oam[1364]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__5_ ( .D(n2441), .DE(n234), .CLK(clk), 
        .Q(oam[1365]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__6_ ( .D(n2457), .DE(n234), .CLK(clk), 
        .Q(oam[1366]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__7_ ( .D(n2473), .DE(n234), .CLK(clk), 
        .Q(oam[1367]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_85__0_ ( .D(n2391), .DE(n234), .CLK(clk), 
        .Q(oam[1360]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__1_ ( .D(n2406), .DE(n246), .CLK(clk), 
        .Q(oam[1233]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__2_ ( .D(data_in[2]), .DE(n246), .CLK(
        clk), .Q(oam[1234]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__3_ ( .D(n2423), .DE(n246), .CLK(clk), 
        .Q(oam[1235]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__4_ ( .D(n2429), .DE(n246), .CLK(clk), 
        .Q(oam[1236]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__5_ ( .D(n2440), .DE(n246), .CLK(clk), 
        .Q(oam[1237]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__6_ ( .D(n2456), .DE(n246), .CLK(clk), 
        .Q(oam[1238]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__7_ ( .D(n2472), .DE(n246), .CLK(clk), 
        .Q(oam[1239]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_101__0_ ( .D(n2390), .DE(n246), .CLK(clk), 
        .Q(oam[1232]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__1_ ( .D(n2403), .DE(n154), .CLK(clk), 
        .Q(oam[1105]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__2_ ( .D(n2417), .DE(n154), .CLK(clk), 
        .Q(oam[1106]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__3_ ( .D(n2422), .DE(n154), .CLK(clk), 
        .Q(oam[1107]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__4_ ( .D(n2428), .DE(n154), .CLK(clk), 
        .Q(oam[1108]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__5_ ( .D(n2438), .DE(n154), .CLK(clk), 
        .Q(oam[1109]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__6_ ( .D(n2454), .DE(n154), .CLK(clk), 
        .Q(oam[1110]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__7_ ( .D(n2470), .DE(n154), .CLK(clk), 
        .Q(oam[1111]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_117__0_ ( .D(n2388), .DE(n154), .CLK(clk), 
        .Q(oam[1104]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__1_ ( .D(n2401), .DE(n135), .CLK(clk), 
        .Q(oam[977]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__2_ ( .D(n2416), .DE(n135), .CLK(clk), 
        .Q(oam[978]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__3_ ( .D(n2426), .DE(n135), .CLK(clk), 
        .Q(oam[979]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__4_ ( .D(n2432), .DE(n135), .CLK(clk), 
        .Q(oam[980]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__5_ ( .D(n2435), .DE(n135), .CLK(clk), 
        .Q(oam[981]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__6_ ( .D(n2451), .DE(n135), .CLK(clk), 
        .Q(oam[982]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__7_ ( .D(n2467), .DE(n135), .CLK(clk), 
        .Q(oam[983]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_133__0_ ( .D(n2385), .DE(n135), .CLK(clk), 
        .Q(oam[976]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__1_ ( .D(n2400), .DE(n175), .CLK(clk), 
        .Q(oam[849]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__2_ ( .D(n2420), .DE(n175), .CLK(clk), 
        .Q(oam[850]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__3_ ( .D(n2425), .DE(n175), .CLK(clk), 
        .Q(oam[851]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__4_ ( .D(n2431), .DE(n175), .CLK(clk), 
        .Q(oam[852]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__5_ ( .D(n2434), .DE(n175), .CLK(clk), 
        .Q(oam[853]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__6_ ( .D(n2450), .DE(n175), .CLK(clk), 
        .Q(oam[854]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__7_ ( .D(n2466), .DE(n175), .CLK(clk), 
        .Q(oam[855]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_149__0_ ( .D(n2384), .DE(n175), .CLK(clk), 
        .Q(oam[848]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__1_ ( .D(n2404), .DE(n347), .CLK(clk), 
        .Q(oam[689]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__2_ ( .D(n2418), .DE(n347), .CLK(clk), 
        .Q(oam[690]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__3_ ( .D(data_in[3]), .DE(n347), .CLK(
        clk), .Q(oam[691]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__4_ ( .D(data_in[4]), .DE(n347), .CLK(
        clk), .Q(oam[692]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__5_ ( .D(n2437), .DE(n347), .CLK(clk), 
        .Q(oam[693]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__6_ ( .D(n2453), .DE(n347), .CLK(clk), 
        .Q(oam[694]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__7_ ( .D(n2469), .DE(n347), .CLK(clk), 
        .Q(oam[695]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_169__0_ ( .D(n2387), .DE(n347), .CLK(clk), 
        .Q(oam[688]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__1_ ( .D(n2402), .DE(n346), .CLK(clk), 
        .Q(oam[561]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__2_ ( .D(n2419), .DE(n346), .CLK(clk), 
        .Q(oam[562]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__3_ ( .D(n2424), .DE(n346), .CLK(clk), 
        .Q(oam[563]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__4_ ( .D(n2430), .DE(n346), .CLK(clk), 
        .Q(oam[564]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__5_ ( .D(n2436), .DE(n346), .CLK(clk), 
        .Q(oam[565]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__6_ ( .D(n2452), .DE(n346), .CLK(clk), 
        .Q(oam[566]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__7_ ( .D(n2468), .DE(n346), .CLK(clk), 
        .Q(oam[567]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_185__0_ ( .D(n2386), .DE(n346), .CLK(clk), 
        .Q(oam[560]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__1_ ( .D(n2410), .DE(n336), .CLK(clk), 
        .Q(oam[433]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__2_ ( .D(n2418), .DE(n336), .CLK(clk), 
        .Q(oam[434]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__3_ ( .D(data_in[3]), .DE(n336), .CLK(
        clk), .Q(oam[435]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__4_ ( .D(data_in[4]), .DE(n336), .CLK(
        clk), .Q(oam[436]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__5_ ( .D(n2440), .DE(n336), .CLK(clk), 
        .Q(oam[437]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__6_ ( .D(n2456), .DE(n336), .CLK(clk), 
        .Q(oam[438]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__7_ ( .D(n2472), .DE(n336), .CLK(clk), 
        .Q(oam[439]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_201__0_ ( .D(n2390), .DE(n336), .CLK(clk), 
        .Q(oam[432]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__1_ ( .D(n2407), .DE(n335), .CLK(clk), 
        .Q(oam[305]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__2_ ( .D(data_in[2]), .DE(n335), .CLK(
        clk), .Q(oam[306]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__3_ ( .D(n2423), .DE(n335), .CLK(clk), 
        .Q(oam[307]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__4_ ( .D(n2429), .DE(n335), .CLK(clk), 
        .Q(oam[308]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__5_ ( .D(n2441), .DE(n335), .CLK(clk), 
        .Q(oam[309]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__6_ ( .D(n2457), .DE(n335), .CLK(clk), 
        .Q(oam[310]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__7_ ( .D(n2473), .DE(n335), .CLK(clk), 
        .Q(oam[311]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_217__0_ ( .D(n2391), .DE(n335), .CLK(clk), 
        .Q(oam[304]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__1_ ( .D(n2408), .DE(n345), .CLK(clk), 
        .Q(oam[177]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__2_ ( .D(n2417), .DE(n345), .CLK(clk), 
        .Q(oam[178]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__3_ ( .D(n2422), .DE(n345), .CLK(clk), 
        .Q(oam[179]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__4_ ( .D(n2428), .DE(n345), .CLK(clk), 
        .Q(oam[180]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__5_ ( .D(n2442), .DE(n345), .CLK(clk), 
        .Q(oam[181]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__6_ ( .D(n2458), .DE(n345), .CLK(clk), 
        .Q(oam[182]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__7_ ( .D(n2474), .DE(n345), .CLK(clk), 
        .Q(oam[183]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_233__0_ ( .D(n2392), .DE(n345), .CLK(clk), 
        .Q(oam[176]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__1_ ( .D(n2401), .DE(n344), .CLK(clk), 
        .Q(oam[49]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__2_ ( .D(n2416), .DE(n344), .CLK(clk), 
        .Q(oam[50]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__3_ ( .D(n2426), .DE(n344), .CLK(clk), 
        .Q(oam[51]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__4_ ( .D(n2432), .DE(n344), .CLK(clk), 
        .Q(oam[52]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__5_ ( .D(n2435), .DE(n344), .CLK(clk), 
        .Q(oam[53]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__6_ ( .D(n2451), .DE(n344), .CLK(clk), 
        .Q(oam[54]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__7_ ( .D(n2467), .DE(n344), .CLK(clk), 
        .Q(oam[55]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_249__0_ ( .D(n2385), .DE(n344), .CLK(clk), 
        .Q(oam[48]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__1_ ( .D(n2401), .DE(n319), .CLK(clk), 
        .Q(oam[1969]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__2_ ( .D(n2418), .DE(n319), .CLK(clk), 
        .Q(oam[1970]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__3_ ( .D(n2424), .DE(n319), .CLK(clk), 
        .Q(oam[1971]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__4_ ( .D(n2430), .DE(n319), .CLK(clk), 
        .Q(oam[1972]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__5_ ( .D(n2435), .DE(n319), .CLK(clk), 
        .Q(oam[1973]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__6_ ( .D(n2451), .DE(n319), .CLK(clk), 
        .Q(oam[1974]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__7_ ( .D(n2467), .DE(n319), .CLK(clk), 
        .Q(oam[1975]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_9__0_ ( .D(n2385), .DE(n319), .CLK(clk), 
        .Q(oam[1968]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__1_ ( .D(n2401), .DE(n318), .CLK(clk), 
        .Q(oam[1841]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__2_ ( .D(n2418), .DE(n318), .CLK(clk), 
        .Q(oam[1842]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__3_ ( .D(n2424), .DE(n318), .CLK(clk), 
        .Q(oam[1843]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__4_ ( .D(n2430), .DE(n318), .CLK(clk), 
        .Q(oam[1844]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__5_ ( .D(n2435), .DE(n318), .CLK(clk), 
        .Q(oam[1845]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__6_ ( .D(n2451), .DE(n318), .CLK(clk), 
        .Q(oam[1846]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__7_ ( .D(n2467), .DE(n318), .CLK(clk), 
        .Q(oam[1847]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_25__0_ ( .D(n2385), .DE(n318), .CLK(clk), 
        .Q(oam[1840]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__1_ ( .D(n2401), .DE(n334), .CLK(clk), 
        .Q(oam[1713]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__2_ ( .D(n2418), .DE(n334), .CLK(clk), 
        .Q(oam[1714]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__3_ ( .D(n2424), .DE(n334), .CLK(clk), 
        .Q(oam[1715]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__4_ ( .D(n2430), .DE(n334), .CLK(clk), 
        .Q(oam[1716]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__5_ ( .D(n2435), .DE(n334), .CLK(clk), 
        .Q(oam[1717]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__6_ ( .D(n2451), .DE(n334), .CLK(clk), 
        .Q(oam[1718]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__7_ ( .D(n2467), .DE(n334), .CLK(clk), 
        .Q(oam[1719]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_41__0_ ( .D(n2385), .DE(n334), .CLK(clk), 
        .Q(oam[1712]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__1_ ( .D(n2401), .DE(n333), .CLK(clk), 
        .Q(oam[1585]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__2_ ( .D(n2418), .DE(n333), .CLK(clk), 
        .Q(oam[1586]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__3_ ( .D(n2424), .DE(n333), .CLK(clk), 
        .Q(oam[1587]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__4_ ( .D(n2430), .DE(n333), .CLK(clk), 
        .Q(oam[1588]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__5_ ( .D(n2435), .DE(n333), .CLK(clk), 
        .Q(oam[1589]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__6_ ( .D(n2451), .DE(n333), .CLK(clk), 
        .Q(oam[1590]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__7_ ( .D(n2467), .DE(n333), .CLK(clk), 
        .Q(oam[1591]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_57__0_ ( .D(n2385), .DE(n333), .CLK(clk), 
        .Q(oam[1584]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__1_ ( .D(n2401), .DE(n332), .CLK(clk), 
        .Q(oam[1457]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__2_ ( .D(n2418), .DE(n332), .CLK(clk), 
        .Q(oam[1458]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__3_ ( .D(n2424), .DE(n332), .CLK(clk), 
        .Q(oam[1459]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__4_ ( .D(n2430), .DE(n332), .CLK(clk), 
        .Q(oam[1460]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__5_ ( .D(n2435), .DE(n332), .CLK(clk), 
        .Q(oam[1461]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__6_ ( .D(n2451), .DE(n332), .CLK(clk), 
        .Q(oam[1462]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__7_ ( .D(n2467), .DE(n332), .CLK(clk), 
        .Q(oam[1463]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_73__0_ ( .D(n2385), .DE(n332), .CLK(clk), 
        .Q(oam[1456]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__1_ ( .D(n2401), .DE(n331), .CLK(clk), 
        .Q(oam[1329]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__2_ ( .D(n2418), .DE(n331), .CLK(clk), 
        .Q(oam[1330]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__3_ ( .D(n2424), .DE(n331), .CLK(clk), 
        .Q(oam[1331]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__4_ ( .D(n2430), .DE(n331), .CLK(clk), 
        .Q(oam[1332]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__5_ ( .D(n2435), .DE(n331), .CLK(clk), 
        .Q(oam[1333]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__6_ ( .D(n2451), .DE(n331), .CLK(clk), 
        .Q(oam[1334]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__7_ ( .D(n2467), .DE(n331), .CLK(clk), 
        .Q(oam[1335]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_89__0_ ( .D(n2385), .DE(n331), .CLK(clk), 
        .Q(oam[1328]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__1_ ( .D(n2401), .DE(n343), .CLK(clk), 
        .Q(oam[1201]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__2_ ( .D(n2418), .DE(n343), .CLK(clk), 
        .Q(oam[1202]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__3_ ( .D(n2424), .DE(n343), .CLK(clk), 
        .Q(oam[1203]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__4_ ( .D(n2430), .DE(n343), .CLK(clk), 
        .Q(oam[1204]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__5_ ( .D(n2435), .DE(n343), .CLK(clk), 
        .Q(oam[1205]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__6_ ( .D(n2451), .DE(n343), .CLK(clk), 
        .Q(oam[1206]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__7_ ( .D(n2467), .DE(n343), .CLK(clk), 
        .Q(oam[1207]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_105__0_ ( .D(n2385), .DE(n343), .CLK(clk), 
        .Q(oam[1200]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__1_ ( .D(n2401), .DE(n153), .CLK(clk), 
        .Q(oam[1073]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__2_ ( .D(n2418), .DE(n153), .CLK(clk), 
        .Q(oam[1074]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__3_ ( .D(n2424), .DE(n153), .CLK(clk), 
        .Q(oam[1075]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__4_ ( .D(n2430), .DE(n153), .CLK(clk), 
        .Q(oam[1076]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__5_ ( .D(n2435), .DE(n153), .CLK(clk), 
        .Q(oam[1077]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__6_ ( .D(n2451), .DE(n153), .CLK(clk), 
        .Q(oam[1078]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__7_ ( .D(n2467), .DE(n153), .CLK(clk), 
        .Q(oam[1079]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_121__0_ ( .D(n2385), .DE(n153), .CLK(clk), 
        .Q(oam[1072]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__1_ ( .D(n2401), .DE(n134), .CLK(clk), 
        .Q(oam[945]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__2_ ( .D(n2418), .DE(n134), .CLK(clk), 
        .Q(oam[946]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__3_ ( .D(n2424), .DE(n134), .CLK(clk), 
        .Q(oam[947]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__4_ ( .D(n2430), .DE(n134), .CLK(clk), 
        .Q(oam[948]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__5_ ( .D(n2435), .DE(n134), .CLK(clk), 
        .Q(oam[949]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__6_ ( .D(n2451), .DE(n134), .CLK(clk), 
        .Q(oam[950]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__7_ ( .D(n2467), .DE(n134), .CLK(clk), 
        .Q(oam[951]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_137__0_ ( .D(n2385), .DE(n134), .CLK(clk), 
        .Q(oam[944]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__1_ ( .D(n2401), .DE(n174), .CLK(clk), 
        .Q(oam[817]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__2_ ( .D(n2418), .DE(n174), .CLK(clk), 
        .Q(oam[818]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__3_ ( .D(n2424), .DE(n174), .CLK(clk), 
        .Q(oam[819]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__4_ ( .D(n2430), .DE(n174), .CLK(clk), 
        .Q(oam[820]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__5_ ( .D(n2435), .DE(n174), .CLK(clk), 
        .Q(oam[821]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__6_ ( .D(n2451), .DE(n174), .CLK(clk), 
        .Q(oam[822]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__7_ ( .D(n2467), .DE(n174), .CLK(clk), 
        .Q(oam[823]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_153__0_ ( .D(n2385), .DE(n174), .CLK(clk), 
        .Q(oam[816]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__1_ ( .D(n2401), .DE(n380), .CLK(clk), 
        .Q(oam[657]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__2_ ( .D(n2418), .DE(n380), .CLK(clk), 
        .Q(oam[658]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__3_ ( .D(n2424), .DE(n380), .CLK(clk), 
        .Q(oam[659]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__4_ ( .D(n2430), .DE(n380), .CLK(clk), 
        .Q(oam[660]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__5_ ( .D(n2435), .DE(n380), .CLK(clk), 
        .Q(oam[661]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__6_ ( .D(n2451), .DE(n380), .CLK(clk), 
        .Q(oam[662]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__7_ ( .D(n2467), .DE(n380), .CLK(clk), 
        .Q(oam[663]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_173__0_ ( .D(n2385), .DE(n380), .CLK(clk), 
        .Q(oam[656]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__1_ ( .D(n2401), .DE(n379), .CLK(clk), 
        .Q(oam[529]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__2_ ( .D(n2418), .DE(n379), .CLK(clk), 
        .Q(oam[530]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__3_ ( .D(n2424), .DE(n379), .CLK(clk), 
        .Q(oam[531]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__4_ ( .D(n2430), .DE(n379), .CLK(clk), 
        .Q(oam[532]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__5_ ( .D(n2435), .DE(n379), .CLK(clk), 
        .Q(oam[533]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__6_ ( .D(n2451), .DE(n379), .CLK(clk), 
        .Q(oam[534]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__7_ ( .D(n2467), .DE(n379), .CLK(clk), 
        .Q(oam[535]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_189__0_ ( .D(n2385), .DE(n379), .CLK(clk), 
        .Q(oam[528]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__1_ ( .D(n2401), .DE(n369), .CLK(clk), 
        .Q(oam[401]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__2_ ( .D(n2418), .DE(n369), .CLK(clk), 
        .Q(oam[402]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__3_ ( .D(n2424), .DE(n369), .CLK(clk), 
        .Q(oam[403]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__4_ ( .D(n2430), .DE(n369), .CLK(clk), 
        .Q(oam[404]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__5_ ( .D(n2435), .DE(n369), .CLK(clk), 
        .Q(oam[405]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__6_ ( .D(n2451), .DE(n369), .CLK(clk), 
        .Q(oam[406]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__7_ ( .D(n2467), .DE(n369), .CLK(clk), 
        .Q(oam[407]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_205__0_ ( .D(n2385), .DE(n369), .CLK(clk), 
        .Q(oam[400]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__1_ ( .D(n2401), .DE(n368), .CLK(clk), 
        .Q(oam[273]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__2_ ( .D(n2418), .DE(n368), .CLK(clk), 
        .Q(oam[274]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__3_ ( .D(n2424), .DE(n368), .CLK(clk), 
        .Q(oam[275]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__4_ ( .D(n2430), .DE(n368), .CLK(clk), 
        .Q(oam[276]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__5_ ( .D(n2435), .DE(n368), .CLK(clk), 
        .Q(oam[277]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__6_ ( .D(n2451), .DE(n368), .CLK(clk), 
        .Q(oam[278]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__7_ ( .D(n2467), .DE(n368), .CLK(clk), 
        .Q(oam[279]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_221__0_ ( .D(n2385), .DE(n368), .CLK(clk), 
        .Q(oam[272]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__1_ ( .D(n2400), .DE(n378), .CLK(clk), 
        .Q(oam[145]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__2_ ( .D(n2417), .DE(n378), .CLK(clk), 
        .Q(oam[146]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__3_ ( .D(n2423), .DE(n378), .CLK(clk), 
        .Q(oam[147]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__4_ ( .D(n2429), .DE(n378), .CLK(clk), 
        .Q(oam[148]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__5_ ( .D(n2434), .DE(n378), .CLK(clk), 
        .Q(oam[149]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__6_ ( .D(n2450), .DE(n378), .CLK(clk), 
        .Q(oam[150]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__7_ ( .D(n2466), .DE(n378), .CLK(clk), 
        .Q(oam[151]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_237__0_ ( .D(n2384), .DE(n378), .CLK(clk), 
        .Q(oam[144]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__1_ ( .D(n2400), .DE(n377), .CLK(clk), 
        .Q(oam[17]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__2_ ( .D(n2417), .DE(n377), .CLK(clk), 
        .Q(oam[18]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__3_ ( .D(n2423), .DE(n377), .CLK(clk), 
        .Q(oam[19]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__4_ ( .D(n2429), .DE(n377), .CLK(clk), 
        .Q(oam[20]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__5_ ( .D(n2434), .DE(n377), .CLK(clk), 
        .Q(oam[21]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__6_ ( .D(n2450), .DE(n377), .CLK(clk), 
        .Q(oam[22]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__7_ ( .D(n2466), .DE(n377), .CLK(clk), 
        .Q(oam[23]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_253__0_ ( .D(n2384), .DE(n377), .CLK(clk), 
        .Q(oam[16]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__1_ ( .D(n2400), .DE(n317), .CLK(clk), 
        .Q(oam[1937]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__2_ ( .D(n2417), .DE(n317), .CLK(clk), 
        .Q(oam[1938]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__3_ ( .D(n2423), .DE(n317), .CLK(clk), 
        .Q(oam[1939]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__4_ ( .D(n2429), .DE(n317), .CLK(clk), 
        .Q(oam[1940]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__5_ ( .D(n2434), .DE(n317), .CLK(clk), 
        .Q(oam[1941]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__6_ ( .D(n2450), .DE(n317), .CLK(clk), 
        .Q(oam[1942]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__7_ ( .D(n2466), .DE(n317), .CLK(clk), 
        .Q(oam[1943]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_13__0_ ( .D(n2384), .DE(n317), .CLK(clk), 
        .Q(oam[1936]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__1_ ( .D(n2400), .DE(n316), .CLK(clk), 
        .Q(oam[1809]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__2_ ( .D(n2417), .DE(n316), .CLK(clk), 
        .Q(oam[1810]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__3_ ( .D(n2423), .DE(n316), .CLK(clk), 
        .Q(oam[1811]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__4_ ( .D(n2429), .DE(n316), .CLK(clk), 
        .Q(oam[1812]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__5_ ( .D(n2434), .DE(n316), .CLK(clk), 
        .Q(oam[1813]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__6_ ( .D(n2450), .DE(n316), .CLK(clk), 
        .Q(oam[1814]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__7_ ( .D(n2466), .DE(n316), .CLK(clk), 
        .Q(oam[1815]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_29__0_ ( .D(n2384), .DE(n316), .CLK(clk), 
        .Q(oam[1808]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__1_ ( .D(n2400), .DE(n367), .CLK(clk), 
        .Q(oam[1681]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__2_ ( .D(n2417), .DE(n367), .CLK(clk), 
        .Q(oam[1682]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__3_ ( .D(n2423), .DE(n367), .CLK(clk), 
        .Q(oam[1683]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__4_ ( .D(n2429), .DE(n367), .CLK(clk), 
        .Q(oam[1684]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__5_ ( .D(n2434), .DE(n367), .CLK(clk), 
        .Q(oam[1685]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__6_ ( .D(n2450), .DE(n367), .CLK(clk), 
        .Q(oam[1686]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__7_ ( .D(n2466), .DE(n367), .CLK(clk), 
        .Q(oam[1687]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_45__0_ ( .D(n2384), .DE(n367), .CLK(clk), 
        .Q(oam[1680]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__1_ ( .D(n2400), .DE(n366), .CLK(clk), 
        .Q(oam[1553]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__2_ ( .D(n2417), .DE(n366), .CLK(clk), 
        .Q(oam[1554]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__3_ ( .D(n2423), .DE(n366), .CLK(clk), 
        .Q(oam[1555]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__4_ ( .D(n2429), .DE(n366), .CLK(clk), 
        .Q(oam[1556]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__5_ ( .D(n2434), .DE(n366), .CLK(clk), 
        .Q(oam[1557]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__6_ ( .D(n2450), .DE(n366), .CLK(clk), 
        .Q(oam[1558]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__7_ ( .D(n2466), .DE(n366), .CLK(clk), 
        .Q(oam[1559]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_61__0_ ( .D(n2384), .DE(n366), .CLK(clk), 
        .Q(oam[1552]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__1_ ( .D(n2400), .DE(n365), .CLK(clk), 
        .Q(oam[1425]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__2_ ( .D(n2417), .DE(n365), .CLK(clk), 
        .Q(oam[1426]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__3_ ( .D(n2423), .DE(n365), .CLK(clk), 
        .Q(oam[1427]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__4_ ( .D(n2429), .DE(n365), .CLK(clk), 
        .Q(oam[1428]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__5_ ( .D(n2434), .DE(n365), .CLK(clk), 
        .Q(oam[1429]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__6_ ( .D(n2450), .DE(n365), .CLK(clk), 
        .Q(oam[1430]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__7_ ( .D(n2466), .DE(n365), .CLK(clk), 
        .Q(oam[1431]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_77__0_ ( .D(n2384), .DE(n365), .CLK(clk), 
        .Q(oam[1424]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__1_ ( .D(n2400), .DE(n364), .CLK(clk), 
        .Q(oam[1297]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__2_ ( .D(n2417), .DE(n364), .CLK(clk), 
        .Q(oam[1298]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__3_ ( .D(n2423), .DE(n364), .CLK(clk), 
        .Q(oam[1299]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__4_ ( .D(n2429), .DE(n364), .CLK(clk), 
        .Q(oam[1300]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__5_ ( .D(n2434), .DE(n364), .CLK(clk), 
        .Q(oam[1301]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__6_ ( .D(n2450), .DE(n364), .CLK(clk), 
        .Q(oam[1302]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__7_ ( .D(n2466), .DE(n364), .CLK(clk), 
        .Q(oam[1303]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_93__0_ ( .D(n2384), .DE(n364), .CLK(clk), 
        .Q(oam[1296]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__1_ ( .D(n2400), .DE(n376), .CLK(clk), 
        .Q(oam[1169]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__2_ ( .D(n2417), .DE(n376), .CLK(clk), 
        .Q(oam[1170]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__3_ ( .D(n2423), .DE(n376), .CLK(clk), 
        .Q(oam[1171]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__4_ ( .D(n2429), .DE(n376), .CLK(clk), 
        .Q(oam[1172]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__5_ ( .D(n2434), .DE(n376), .CLK(clk), 
        .Q(oam[1173]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__6_ ( .D(n2450), .DE(n376), .CLK(clk), 
        .Q(oam[1174]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__7_ ( .D(n2466), .DE(n376), .CLK(clk), 
        .Q(oam[1175]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_109__0_ ( .D(n2384), .DE(n376), .CLK(clk), 
        .Q(oam[1168]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__1_ ( .D(n2400), .DE(n152), .CLK(clk), 
        .Q(oam[1041]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__2_ ( .D(n2417), .DE(n152), .CLK(clk), 
        .Q(oam[1042]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__3_ ( .D(n2423), .DE(n152), .CLK(clk), 
        .Q(oam[1043]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__4_ ( .D(n2429), .DE(n152), .CLK(clk), 
        .Q(oam[1044]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__5_ ( .D(n2434), .DE(n152), .CLK(clk), 
        .Q(oam[1045]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__6_ ( .D(n2450), .DE(n152), .CLK(clk), 
        .Q(oam[1046]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__7_ ( .D(n2466), .DE(n152), .CLK(clk), 
        .Q(oam[1047]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_125__0_ ( .D(n2384), .DE(n152), .CLK(clk), 
        .Q(oam[1040]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__1_ ( .D(n2400), .DE(n133), .CLK(clk), 
        .Q(oam[913]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__2_ ( .D(n2417), .DE(n133), .CLK(clk), 
        .Q(oam[914]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__3_ ( .D(n2423), .DE(n133), .CLK(clk), 
        .Q(oam[915]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__4_ ( .D(n2429), .DE(n133), .CLK(clk), 
        .Q(oam[916]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__5_ ( .D(n2434), .DE(n133), .CLK(clk), 
        .Q(oam[917]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__6_ ( .D(n2450), .DE(n133), .CLK(clk), 
        .Q(oam[918]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__7_ ( .D(n2466), .DE(n133), .CLK(clk), 
        .Q(oam[919]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_141__0_ ( .D(n2384), .DE(n133), .CLK(clk), 
        .Q(oam[912]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__1_ ( .D(n2400), .DE(n173), .CLK(clk), 
        .Q(oam[785]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__2_ ( .D(n2417), .DE(n173), .CLK(clk), 
        .Q(oam[786]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__3_ ( .D(n2423), .DE(n173), .CLK(clk), 
        .Q(oam[787]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__4_ ( .D(n2429), .DE(n173), .CLK(clk), 
        .Q(oam[788]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__5_ ( .D(n2434), .DE(n173), .CLK(clk), 
        .Q(oam[789]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__6_ ( .D(n2450), .DE(n173), .CLK(clk), 
        .Q(oam[790]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__7_ ( .D(n2466), .DE(n173), .CLK(clk), 
        .Q(oam[791]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_157__0_ ( .D(n2384), .DE(n173), .CLK(clk), 
        .Q(oam[784]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__1_ ( .D(n2400), .DE(n286), .CLK(clk), 
        .Q(oam[625]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__2_ ( .D(n2417), .DE(n286), .CLK(clk), 
        .Q(oam[626]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__3_ ( .D(n2423), .DE(n286), .CLK(clk), 
        .Q(oam[627]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__4_ ( .D(n2429), .DE(n286), .CLK(clk), 
        .Q(oam[628]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__5_ ( .D(n2434), .DE(n286), .CLK(clk), 
        .Q(oam[629]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__6_ ( .D(n2450), .DE(n286), .CLK(clk), 
        .Q(oam[630]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__7_ ( .D(n2466), .DE(n286), .CLK(clk), 
        .Q(oam[631]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_177__0_ ( .D(n2384), .DE(n286), .CLK(clk), 
        .Q(oam[624]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__1_ ( .D(n2400), .DE(n273), .CLK(clk), 
        .Q(oam[497]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__2_ ( .D(n2417), .DE(n273), .CLK(clk), 
        .Q(oam[498]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__3_ ( .D(n2423), .DE(n273), .CLK(clk), 
        .Q(oam[499]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__4_ ( .D(n2429), .DE(n273), .CLK(clk), 
        .Q(oam[500]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__5_ ( .D(n2434), .DE(n273), .CLK(clk), 
        .Q(oam[501]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__6_ ( .D(n2450), .DE(n273), .CLK(clk), 
        .Q(oam[502]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__7_ ( .D(n2466), .DE(n273), .CLK(clk), 
        .Q(oam[503]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_193__0_ ( .D(n2384), .DE(n273), .CLK(clk), 
        .Q(oam[496]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__1_ ( .D(n2405), .DE(n272), .CLK(clk), 
        .Q(oam[369]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__2_ ( .D(n2416), .DE(n272), .CLK(clk), 
        .Q(oam[370]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__3_ ( .D(n2422), .DE(n272), .CLK(clk), 
        .Q(oam[371]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__4_ ( .D(n2428), .DE(n272), .CLK(clk), 
        .Q(oam[372]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__5_ ( .D(n2439), .DE(n272), .CLK(clk), 
        .Q(oam[373]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__6_ ( .D(n2455), .DE(n272), .CLK(clk), 
        .Q(oam[374]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__7_ ( .D(n2471), .DE(n272), .CLK(clk), 
        .Q(oam[375]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_209__0_ ( .D(n2389), .DE(n272), .CLK(clk), 
        .Q(oam[368]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__1_ ( .D(n2404), .DE(n285), .CLK(clk), 
        .Q(oam[241]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__2_ ( .D(n2416), .DE(n285), .CLK(clk), 
        .Q(oam[242]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__3_ ( .D(n2422), .DE(n285), .CLK(clk), 
        .Q(oam[243]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__4_ ( .D(n2428), .DE(n285), .CLK(clk), 
        .Q(oam[244]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__5_ ( .D(n2437), .DE(n285), .CLK(clk), 
        .Q(oam[245]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__6_ ( .D(n2453), .DE(n285), .CLK(clk), 
        .Q(oam[246]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__7_ ( .D(n2469), .DE(n285), .CLK(clk), 
        .Q(oam[247]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_225__0_ ( .D(n2387), .DE(n285), .CLK(clk), 
        .Q(oam[240]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__1_ ( .D(n2409), .DE(n284), .CLK(clk), 
        .Q(oam[113]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__2_ ( .D(n2416), .DE(n284), .CLK(clk), 
        .Q(oam[114]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__3_ ( .D(n2422), .DE(n284), .CLK(clk), 
        .Q(oam[115]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__4_ ( .D(n2428), .DE(n284), .CLK(clk), 
        .Q(oam[116]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__5_ ( .D(n2443), .DE(n284), .CLK(clk), 
        .Q(oam[117]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__6_ ( .D(n2459), .DE(n284), .CLK(clk), 
        .Q(oam[118]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__7_ ( .D(n2475), .DE(n284), .CLK(clk), 
        .Q(oam[119]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_241__0_ ( .D(n2393), .DE(n284), .CLK(clk), 
        .Q(oam[112]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__1_ ( .D(n2409), .DE(n146), .CLK(clk), 
        .Q(oam[2033]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__2_ ( .D(n2416), .DE(n146), .CLK(clk), 
        .Q(oam[2034]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__3_ ( .D(n2422), .DE(n146), .CLK(clk), 
        .Q(oam[2035]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__4_ ( .D(n2428), .DE(n146), .CLK(clk), 
        .Q(oam[2036]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__5_ ( .D(n2443), .DE(n146), .CLK(clk), 
        .Q(oam[2037]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__6_ ( .D(n2459), .DE(n146), .CLK(clk), 
        .Q(oam[2038]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__7_ ( .D(n2475), .DE(n146), .CLK(clk), 
        .Q(oam[2039]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_1__0_ ( .D(n2393), .DE(n146), .CLK(clk), 
        .Q(oam[2032]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__1_ ( .D(n2410), .DE(n182), .CLK(clk), 
        .Q(oam[1905]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__2_ ( .D(n2416), .DE(n182), .CLK(clk), 
        .Q(oam[1906]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__3_ ( .D(n2422), .DE(n182), .CLK(clk), 
        .Q(oam[1907]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__4_ ( .D(n2428), .DE(n182), .CLK(clk), 
        .Q(oam[1908]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__5_ ( .D(n2439), .DE(n182), .CLK(clk), 
        .Q(oam[1909]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__6_ ( .D(n2455), .DE(n182), .CLK(clk), 
        .Q(oam[1910]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__7_ ( .D(n2471), .DE(n182), .CLK(clk), 
        .Q(oam[1911]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_17__0_ ( .D(n2389), .DE(n182), .CLK(clk), 
        .Q(oam[1904]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__1_ ( .D(n2401), .DE(n271), .CLK(clk), 
        .Q(oam[1777]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__2_ ( .D(n2416), .DE(n271), .CLK(clk), 
        .Q(oam[1778]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__3_ ( .D(n2422), .DE(n271), .CLK(clk), 
        .Q(oam[1779]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__4_ ( .D(n2428), .DE(n271), .CLK(clk), 
        .Q(oam[1780]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__5_ ( .D(n2435), .DE(n271), .CLK(clk), 
        .Q(oam[1781]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__6_ ( .D(n2451), .DE(n271), .CLK(clk), 
        .Q(oam[1782]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__7_ ( .D(n2467), .DE(n271), .CLK(clk), 
        .Q(oam[1783]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_33__0_ ( .D(n2385), .DE(n271), .CLK(clk), 
        .Q(oam[1776]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__1_ ( .D(n2403), .DE(n270), .CLK(clk), 
        .Q(oam[1649]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__2_ ( .D(n2416), .DE(n270), .CLK(clk), 
        .Q(oam[1650]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__3_ ( .D(n2422), .DE(n270), .CLK(clk), 
        .Q(oam[1651]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__4_ ( .D(n2428), .DE(n270), .CLK(clk), 
        .Q(oam[1652]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__5_ ( .D(n2438), .DE(n270), .CLK(clk), 
        .Q(oam[1653]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__6_ ( .D(n2454), .DE(n270), .CLK(clk), 
        .Q(oam[1654]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__7_ ( .D(n2470), .DE(n270), .CLK(clk), 
        .Q(oam[1655]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_49__0_ ( .D(n2388), .DE(n270), .CLK(clk), 
        .Q(oam[1648]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__1_ ( .D(n2407), .DE(n269), .CLK(clk), 
        .Q(oam[1521]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__2_ ( .D(n2416), .DE(n269), .CLK(clk), 
        .Q(oam[1522]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__3_ ( .D(n2422), .DE(n269), .CLK(clk), 
        .Q(oam[1523]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__4_ ( .D(n2428), .DE(n269), .CLK(clk), 
        .Q(oam[1524]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__5_ ( .D(n2441), .DE(n269), .CLK(clk), 
        .Q(oam[1525]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__6_ ( .D(n2457), .DE(n269), .CLK(clk), 
        .Q(oam[1526]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__7_ ( .D(n2473), .DE(n269), .CLK(clk), 
        .Q(oam[1527]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_65__0_ ( .D(n2391), .DE(n269), .CLK(clk), 
        .Q(oam[1520]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__1_ ( .D(n2408), .DE(n268), .CLK(clk), 
        .Q(oam[1393]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__2_ ( .D(n2416), .DE(n268), .CLK(clk), 
        .Q(oam[1394]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__3_ ( .D(n2422), .DE(n268), .CLK(clk), 
        .Q(oam[1395]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__4_ ( .D(n2428), .DE(n268), .CLK(clk), 
        .Q(oam[1396]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__5_ ( .D(n2442), .DE(n268), .CLK(clk), 
        .Q(oam[1397]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__6_ ( .D(n2458), .DE(n268), .CLK(clk), 
        .Q(oam[1398]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__7_ ( .D(n2474), .DE(n268), .CLK(clk), 
        .Q(oam[1399]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_81__0_ ( .D(n2392), .DE(n268), .CLK(clk), 
        .Q(oam[1392]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__1_ ( .D(n2400), .DE(n282), .CLK(clk), 
        .Q(oam[1265]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__2_ ( .D(n2416), .DE(n282), .CLK(clk), 
        .Q(oam[1266]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__3_ ( .D(n2422), .DE(n282), .CLK(clk), 
        .Q(oam[1267]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__4_ ( .D(n2428), .DE(n282), .CLK(clk), 
        .Q(oam[1268]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__5_ ( .D(n2434), .DE(n282), .CLK(clk), 
        .Q(oam[1269]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__6_ ( .D(n2450), .DE(n282), .CLK(clk), 
        .Q(oam[1270]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__7_ ( .D(n2466), .DE(n282), .CLK(clk), 
        .Q(oam[1271]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_97__0_ ( .D(n2384), .DE(n282), .CLK(clk), 
        .Q(oam[1264]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__1_ ( .D(n2405), .DE(n151), .CLK(clk), 
        .Q(oam[1137]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__2_ ( .D(n2416), .DE(n151), .CLK(clk), 
        .Q(oam[1138]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__3_ ( .D(n2422), .DE(n151), .CLK(clk), 
        .Q(oam[1139]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__4_ ( .D(n2428), .DE(n151), .CLK(clk), 
        .Q(oam[1140]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__5_ ( .D(n2439), .DE(n151), .CLK(clk), 
        .Q(oam[1141]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__6_ ( .D(n2455), .DE(n151), .CLK(clk), 
        .Q(oam[1142]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__7_ ( .D(n2471), .DE(n151), .CLK(clk), 
        .Q(oam[1143]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_113__0_ ( .D(n2389), .DE(n151), .CLK(clk), 
        .Q(oam[1136]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__1_ ( .D(n2406), .DE(n132), .CLK(clk), 
        .Q(oam[1009]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__2_ ( .D(n2416), .DE(n132), .CLK(clk), 
        .Q(oam[1010]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__3_ ( .D(n2422), .DE(n132), .CLK(clk), 
        .Q(oam[1011]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__4_ ( .D(n2428), .DE(n132), .CLK(clk), 
        .Q(oam[1012]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__5_ ( .D(n2440), .DE(n132), .CLK(clk), 
        .Q(oam[1013]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__6_ ( .D(n2456), .DE(n132), .CLK(clk), 
        .Q(oam[1014]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__7_ ( .D(n2472), .DE(n132), .CLK(clk), 
        .Q(oam[1015]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_129__0_ ( .D(n2390), .DE(n132), .CLK(clk), 
        .Q(oam[1008]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__1_ ( .D(n2400), .DE(n172), .CLK(clk), 
        .Q(oam[881]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__2_ ( .D(n2416), .DE(n172), .CLK(clk), 
        .Q(oam[882]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__3_ ( .D(n2422), .DE(n172), .CLK(clk), 
        .Q(oam[883]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__4_ ( .D(n2428), .DE(n172), .CLK(clk), 
        .Q(oam[884]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__5_ ( .D(n2434), .DE(n172), .CLK(clk), 
        .Q(oam[885]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__6_ ( .D(n2450), .DE(n172), .CLK(clk), 
        .Q(oam[886]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__7_ ( .D(n2466), .DE(n172), .CLK(clk), 
        .Q(oam[887]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_145__0_ ( .D(n2384), .DE(n172), .CLK(clk), 
        .Q(oam[880]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__1_ ( .D(n2409), .DE(n281), .CLK(clk), 
        .Q(oam[753]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__2_ ( .D(n2416), .DE(n281), .CLK(clk), 
        .Q(oam[754]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__3_ ( .D(n2422), .DE(n281), .CLK(clk), 
        .Q(oam[755]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__4_ ( .D(n2428), .DE(n281), .CLK(clk), 
        .Q(oam[756]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__5_ ( .D(n2443), .DE(n281), .CLK(clk), 
        .Q(oam[757]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__6_ ( .D(n2459), .DE(n281), .CLK(clk), 
        .Q(oam[758]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__7_ ( .D(n2475), .DE(n281), .CLK(clk), 
        .Q(oam[759]) );
  sky130_fd_sc_hd__edfxtp_1 oam_reg_161__0_ ( .D(n2393), .DE(n281), .CLK(clk), 
        .Q(oam[752]) );
  sky130_fd_sc_hd__edfxbp_1 sprite0_curr_reg ( .D(n2764), .DE(ce), .CLK(clk), 
        .Q(sprite0_curr), .Q_N(n278) );
  sky130_fd_sc_hd__edfxtp_1 sprite0_reg ( .D(sprite0_curr), .DE(n2768), .CLK(
        clk), .Q(sprite0) );
  SpriteRAM_DW01_sub_1 sub_238 ( .A(scanline), .B({n5, oam_bus[7:4], n2769, 
        n2770, n450, n2771}), .CI(n5), .DIFF({spr_y_coord, 
        SYNOPSYS_UNCONNECTED__0, SYNOPSYS_UNCONNECTED__1, 
        SYNOPSYS_UNCONNECTED__2}) );
  sky130_fd_sc_hd__dfxbp_2 oam_ptr_reg_2_ ( .D(n826), .CLK(clk), .Q(N33), 
        .Q_N(n2264) );
  sky130_fd_sc_hd__dfxbp_1 oam_ptr_reg_1_ ( .D(n827), .CLK(clk), .Q(N32), 
        .Q_N(n2283) );
  sky130_fd_sc_hd__dfxbp_2 oam_ptr_reg_0_ ( .D(n828), .CLK(clk), .Q(N31), 
        .Q_N(n2278) );
  sky130_fd_sc_hd__dfxtp_2 oam_ptr_reg_3_ ( .D(n825), .CLK(clk), .Q(N34) );
  sky130_fd_sc_hd__dfxtp_1 spr_overflow_reg ( .D(n820), .CLK(clk), .Q(
        spr_overflow) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_10__3_ ( .D(n632), .CLK(clk), .Q(oam[1963])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_ptr_reg_4_ ( .D(n824), .CLK(clk), .Q(N35) );
  sky130_fd_sc_hd__dfxtp_1 oam_ptr_reg_6_ ( .D(n822), .CLK(clk), .Q(N37) );
  sky130_fd_sc_hd__dfxtp_1 oam_ptr_reg_5_ ( .D(n823), .CLK(clk), .Q(N36) );
  sky130_fd_sc_hd__dfxtp_1 oam_ptr_reg_7_ ( .D(n821), .CLK(clk), .Q(N38) );
  sky130_fd_sc_hd__dfxtp_1 p_reg_0_ ( .D(n818), .CLK(clk), .Q(p[0]) );
  sky130_fd_sc_hd__dfxtp_1 p_reg_1_ ( .D(n817), .CLK(clk), .Q(p[1]) );
  sky130_fd_sc_hd__dfxtp_1 p_reg_2_ ( .D(n819), .CLK(clk), .Q(p[2]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_166__4_ ( .D(n748), .CLK(clk), .Q(oam[716])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_166__3_ ( .D(n749), .CLK(clk), .Q(oam[715])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_166__2_ ( .D(n750), .CLK(clk), .Q(oam[714])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_182__4_ ( .D(n760), .CLK(clk), .Q(oam[588])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_182__3_ ( .D(n761), .CLK(clk), .Q(oam[587])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_182__2_ ( .D(n762), .CLK(clk), .Q(oam[586])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_198__4_ ( .D(n772), .CLK(clk), .Q(oam[460])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_198__3_ ( .D(n773), .CLK(clk), .Q(oam[459])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_198__2_ ( .D(n774), .CLK(clk), .Q(oam[458])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_214__4_ ( .D(n784), .CLK(clk), .Q(oam[332])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_214__3_ ( .D(n785), .CLK(clk), .Q(oam[331])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_214__2_ ( .D(n786), .CLK(clk), .Q(oam[330])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_230__4_ ( .D(n796), .CLK(clk), .Q(oam[204])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_230__3_ ( .D(n797), .CLK(clk), .Q(oam[203])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_230__2_ ( .D(n798), .CLK(clk), .Q(oam[202])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_246__4_ ( .D(n808), .CLK(clk), .Q(oam[76])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_246__3_ ( .D(n809), .CLK(clk), .Q(oam[75])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_246__2_ ( .D(n810), .CLK(clk), .Q(oam[74])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_6__2_ ( .D(n630), .CLK(clk), .Q(oam[1994])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_6__3_ ( .D(n629), .CLK(clk), .Q(oam[1995])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_6__4_ ( .D(n628), .CLK(clk), .Q(oam[1996])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_22__4_ ( .D(n640), .CLK(clk), .Q(oam[1868])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_22__3_ ( .D(n641), .CLK(clk), .Q(oam[1867])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_22__2_ ( .D(n642), .CLK(clk), .Q(oam[1866])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_38__4_ ( .D(n652), .CLK(clk), .Q(oam[1740])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_38__3_ ( .D(n653), .CLK(clk), .Q(oam[1739])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_38__2_ ( .D(n654), .CLK(clk), .Q(oam[1738])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_54__4_ ( .D(n664), .CLK(clk), .Q(oam[1612])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_54__3_ ( .D(n665), .CLK(clk), .Q(oam[1611])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_54__2_ ( .D(n666), .CLK(clk), .Q(oam[1610])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_70__4_ ( .D(n676), .CLK(clk), .Q(oam[1484])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_70__3_ ( .D(n677), .CLK(clk), .Q(oam[1483])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_70__2_ ( .D(n678), .CLK(clk), .Q(oam[1482])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_86__4_ ( .D(n688), .CLK(clk), .Q(oam[1356])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_86__3_ ( .D(n689), .CLK(clk), .Q(oam[1355])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_86__2_ ( .D(n690), .CLK(clk), .Q(oam[1354])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_102__4_ ( .D(n700), .CLK(clk), .Q(oam[1228]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_102__3_ ( .D(n701), .CLK(clk), .Q(oam[1227]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_102__2_ ( .D(n702), .CLK(clk), .Q(oam[1226]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_118__4_ ( .D(n712), .CLK(clk), .Q(oam[1100]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_118__3_ ( .D(n713), .CLK(clk), .Q(oam[1099]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_118__2_ ( .D(n714), .CLK(clk), .Q(oam[1098]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_134__4_ ( .D(n724), .CLK(clk), .Q(oam[972])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_134__3_ ( .D(n725), .CLK(clk), .Q(oam[971])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_134__2_ ( .D(n726), .CLK(clk), .Q(oam[970])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_150__4_ ( .D(n736), .CLK(clk), .Q(oam[844])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_150__3_ ( .D(n737), .CLK(clk), .Q(oam[843])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_150__2_ ( .D(n738), .CLK(clk), .Q(oam[842])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_170__4_ ( .D(n751), .CLK(clk), .Q(oam[684])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_170__3_ ( .D(n752), .CLK(clk), .Q(oam[683])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_170__2_ ( .D(n753), .CLK(clk), .Q(oam[682])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_186__4_ ( .D(n763), .CLK(clk), .Q(oam[556])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_186__3_ ( .D(n764), .CLK(clk), .Q(oam[555])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_186__2_ ( .D(n765), .CLK(clk), .Q(oam[554])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_202__4_ ( .D(n775), .CLK(clk), .Q(oam[428])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_202__3_ ( .D(n776), .CLK(clk), .Q(oam[427])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_202__2_ ( .D(n777), .CLK(clk), .Q(oam[426])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_218__4_ ( .D(n787), .CLK(clk), .Q(oam[300])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_218__3_ ( .D(n788), .CLK(clk), .Q(oam[299])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_218__2_ ( .D(n789), .CLK(clk), .Q(oam[298])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_234__4_ ( .D(n799), .CLK(clk), .Q(oam[172])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_234__3_ ( .D(n800), .CLK(clk), .Q(oam[171])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_234__2_ ( .D(n801), .CLK(clk), .Q(oam[170])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_250__4_ ( .D(n811), .CLK(clk), .Q(oam[44])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_250__3_ ( .D(n812), .CLK(clk), .Q(oam[43])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_250__2_ ( .D(n813), .CLK(clk), .Q(oam[42])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_10__2_ ( .D(n633), .CLK(clk), .Q(oam[1962])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_10__4_ ( .D(n631), .CLK(clk), .Q(oam[1964])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_26__4_ ( .D(n643), .CLK(clk), .Q(oam[1836])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_26__3_ ( .D(n644), .CLK(clk), .Q(oam[1835])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_26__2_ ( .D(n645), .CLK(clk), .Q(oam[1834])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_42__4_ ( .D(n655), .CLK(clk), .Q(oam[1708])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_42__3_ ( .D(n656), .CLK(clk), .Q(oam[1707])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_42__2_ ( .D(n657), .CLK(clk), .Q(oam[1706])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_58__4_ ( .D(n667), .CLK(clk), .Q(oam[1580])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_58__3_ ( .D(n668), .CLK(clk), .Q(oam[1579])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_58__2_ ( .D(n669), .CLK(clk), .Q(oam[1578])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_74__4_ ( .D(n679), .CLK(clk), .Q(oam[1452])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_74__3_ ( .D(n680), .CLK(clk), .Q(oam[1451])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_74__2_ ( .D(n681), .CLK(clk), .Q(oam[1450])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_90__4_ ( .D(n691), .CLK(clk), .Q(oam[1324])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_90__3_ ( .D(n692), .CLK(clk), .Q(oam[1323])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_90__2_ ( .D(n693), .CLK(clk), .Q(oam[1322])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_106__4_ ( .D(n703), .CLK(clk), .Q(oam[1196]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_106__3_ ( .D(n704), .CLK(clk), .Q(oam[1195]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_106__2_ ( .D(n705), .CLK(clk), .Q(oam[1194]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_122__4_ ( .D(n715), .CLK(clk), .Q(oam[1068]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_122__3_ ( .D(n716), .CLK(clk), .Q(oam[1067]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_122__2_ ( .D(n717), .CLK(clk), .Q(oam[1066]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_138__4_ ( .D(n727), .CLK(clk), .Q(oam[940])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_138__3_ ( .D(n728), .CLK(clk), .Q(oam[939])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_138__2_ ( .D(n729), .CLK(clk), .Q(oam[938])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_154__4_ ( .D(n739), .CLK(clk), .Q(oam[812])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_154__3_ ( .D(n740), .CLK(clk), .Q(oam[811])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_154__2_ ( .D(n741), .CLK(clk), .Q(oam[810])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_174__4_ ( .D(n754), .CLK(clk), .Q(oam[652])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_174__3_ ( .D(n755), .CLK(clk), .Q(oam[651])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_174__2_ ( .D(n756), .CLK(clk), .Q(oam[650])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_190__4_ ( .D(n766), .CLK(clk), .Q(oam[524])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_190__3_ ( .D(n767), .CLK(clk), .Q(oam[523])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_190__2_ ( .D(n768), .CLK(clk), .Q(oam[522])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_206__4_ ( .D(n778), .CLK(clk), .Q(oam[396])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_206__3_ ( .D(n779), .CLK(clk), .Q(oam[395])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_206__2_ ( .D(n780), .CLK(clk), .Q(oam[394])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_222__4_ ( .D(n790), .CLK(clk), .Q(oam[268])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_222__3_ ( .D(n791), .CLK(clk), .Q(oam[267])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_222__2_ ( .D(n792), .CLK(clk), .Q(oam[266])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_238__4_ ( .D(n802), .CLK(clk), .Q(oam[140])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_238__3_ ( .D(n803), .CLK(clk), .Q(oam[139])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_238__2_ ( .D(n804), .CLK(clk), .Q(oam[138])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_254__4_ ( .D(n814), .CLK(clk), .Q(oam[12])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_254__3_ ( .D(n815), .CLK(clk), .Q(oam[11])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_254__2_ ( .D(n816), .CLK(clk), .Q(oam[10])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_14__2_ ( .D(n636), .CLK(clk), .Q(oam[1930])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_14__3_ ( .D(n635), .CLK(clk), .Q(oam[1931])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_14__4_ ( .D(n634), .CLK(clk), .Q(oam[1932])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_30__4_ ( .D(n646), .CLK(clk), .Q(oam[1804])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_30__3_ ( .D(n647), .CLK(clk), .Q(oam[1803])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_30__2_ ( .D(n648), .CLK(clk), .Q(oam[1802])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_46__4_ ( .D(n658), .CLK(clk), .Q(oam[1676])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_46__3_ ( .D(n659), .CLK(clk), .Q(oam[1675])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_46__2_ ( .D(n660), .CLK(clk), .Q(oam[1674])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_62__4_ ( .D(n670), .CLK(clk), .Q(oam[1548])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_62__3_ ( .D(n671), .CLK(clk), .Q(oam[1547])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_62__2_ ( .D(n672), .CLK(clk), .Q(oam[1546])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_78__4_ ( .D(n682), .CLK(clk), .Q(oam[1420])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_78__3_ ( .D(n683), .CLK(clk), .Q(oam[1419])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_78__2_ ( .D(n684), .CLK(clk), .Q(oam[1418])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_94__4_ ( .D(n694), .CLK(clk), .Q(oam[1292])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_94__3_ ( .D(n695), .CLK(clk), .Q(oam[1291])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_94__2_ ( .D(n696), .CLK(clk), .Q(oam[1290])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_110__4_ ( .D(n706), .CLK(clk), .Q(oam[1164]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_110__3_ ( .D(n707), .CLK(clk), .Q(oam[1163]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_110__2_ ( .D(n708), .CLK(clk), .Q(oam[1162]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_126__4_ ( .D(n718), .CLK(clk), .Q(oam[1036]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_126__3_ ( .D(n719), .CLK(clk), .Q(oam[1035]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_126__2_ ( .D(n720), .CLK(clk), .Q(oam[1034]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_142__4_ ( .D(n730), .CLK(clk), .Q(oam[908])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_142__3_ ( .D(n731), .CLK(clk), .Q(oam[907])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_142__2_ ( .D(n732), .CLK(clk), .Q(oam[906])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_158__4_ ( .D(n742), .CLK(clk), .Q(oam[780])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_158__3_ ( .D(n743), .CLK(clk), .Q(oam[779])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_158__2_ ( .D(n744), .CLK(clk), .Q(oam[778])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_178__4_ ( .D(n757), .CLK(clk), .Q(oam[620])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_178__3_ ( .D(n758), .CLK(clk), .Q(oam[619])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_178__2_ ( .D(n759), .CLK(clk), .Q(oam[618])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_194__4_ ( .D(n769), .CLK(clk), .Q(oam[492])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_194__3_ ( .D(n770), .CLK(clk), .Q(oam[491])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_194__2_ ( .D(n771), .CLK(clk), .Q(oam[490])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_210__4_ ( .D(n781), .CLK(clk), .Q(oam[364])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_210__3_ ( .D(n782), .CLK(clk), .Q(oam[363])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_210__2_ ( .D(n783), .CLK(clk), .Q(oam[362])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_226__4_ ( .D(n793), .CLK(clk), .Q(oam[236])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_226__3_ ( .D(n794), .CLK(clk), .Q(oam[235])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_226__2_ ( .D(n795), .CLK(clk), .Q(oam[234])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_242__4_ ( .D(n805), .CLK(clk), .Q(oam[108])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_242__3_ ( .D(n806), .CLK(clk), .Q(oam[107])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_242__2_ ( .D(n807), .CLK(clk), .Q(oam[106])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_2__2_ ( .D(n627), .CLK(clk), .Q(oam[2026])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_2__3_ ( .D(n626), .CLK(clk), .Q(oam[2027])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_2__4_ ( .D(n625), .CLK(clk), .Q(oam[2028])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_18__4_ ( .D(n637), .CLK(clk), .Q(oam[1900])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_18__3_ ( .D(n638), .CLK(clk), .Q(oam[1899])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_18__2_ ( .D(n639), .CLK(clk), .Q(oam[1898])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_34__4_ ( .D(n649), .CLK(clk), .Q(oam[1772])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_34__3_ ( .D(n650), .CLK(clk), .Q(oam[1771])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_34__2_ ( .D(n651), .CLK(clk), .Q(oam[1770])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_50__4_ ( .D(n661), .CLK(clk), .Q(oam[1644])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_50__3_ ( .D(n662), .CLK(clk), .Q(oam[1643])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_50__2_ ( .D(n663), .CLK(clk), .Q(oam[1642])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_66__4_ ( .D(n673), .CLK(clk), .Q(oam[1516])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_66__3_ ( .D(n674), .CLK(clk), .Q(oam[1515])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_66__2_ ( .D(n675), .CLK(clk), .Q(oam[1514])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_82__4_ ( .D(n685), .CLK(clk), .Q(oam[1388])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_82__3_ ( .D(n686), .CLK(clk), .Q(oam[1387])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_82__2_ ( .D(n687), .CLK(clk), .Q(oam[1386])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_98__4_ ( .D(n697), .CLK(clk), .Q(oam[1260])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_98__3_ ( .D(n698), .CLK(clk), .Q(oam[1259])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_98__2_ ( .D(n699), .CLK(clk), .Q(oam[1258])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_114__4_ ( .D(n709), .CLK(clk), .Q(oam[1132]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_114__3_ ( .D(n710), .CLK(clk), .Q(oam[1131]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_114__2_ ( .D(n711), .CLK(clk), .Q(oam[1130]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_130__4_ ( .D(n721), .CLK(clk), .Q(oam[1004]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_130__3_ ( .D(n722), .CLK(clk), .Q(oam[1003]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_130__2_ ( .D(n723), .CLK(clk), .Q(oam[1002]) );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_146__4_ ( .D(n733), .CLK(clk), .Q(oam[876])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_146__3_ ( .D(n734), .CLK(clk), .Q(oam[875])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_146__2_ ( .D(n735), .CLK(clk), .Q(oam[874])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_162__2_ ( .D(n747), .CLK(clk), .Q(oam[746])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_162__4_ ( .D(n745), .CLK(clk), .Q(oam[748])
         );
  sky130_fd_sc_hd__dfxtp_1 oam_reg_162__3_ ( .D(n746), .CLK(clk), .Q(oam[747])
         );
  sky130_fd_sc_hd__a2bb2oi_1 U3 ( .B1(oam[1740]), .B2(n58), .A1_N(n1), .A2_N(
        n592), .Y(n1682) );
  sky130_fd_sc_hd__clkinv_16 U4 ( .A(oam[1732]), .Y(n1) );
  sky130_fd_sc_hd__dlygate4sd3_1 U5 ( .A(n509), .X(n2) );
  sky130_fd_sc_hd__dlygate4sd3_1 U6 ( .A(n507), .X(n3) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n452), .Y(n4) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(n452), .Y(n840) );
  sky130_fd_sc_hd__buf_4 U9 ( .A(n842), .X(n2331) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(n2271), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(n2271), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(n2271), .Y(n847) );
  sky130_fd_sc_hd__a22oi_2 U13 ( .A1(oam[1475]), .A2(n610), .B1(oam[1483]), 
        .B2(n89), .Y(n1428) );
  sky130_fd_sc_hd__a22oi_2 U14 ( .A1(oam[836]), .A2(n606), .B1(oam[844]), .B2(
        n57), .Y(n1570) );
  sky130_fd_sc_hd__dlygate4sd3_1 U15 ( .A(n2771), .X(oam_bus[0]) );
  sky130_fd_sc_hd__nand2_1 U16 ( .A(n437), .B(n434), .Y(n2771) );
  sky130_fd_sc_hd__buf_2 U17 ( .A(n7), .X(n2339) );
  sky130_fd_sc_hd__buf_4 U18 ( .A(n7), .X(n2342) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(n13), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U20 ( .A(n838), .Y(n13) );
  sky130_fd_sc_hd__and4_2 U21 ( .A(n579), .B(n580), .C(n581), .D(n582), .X(n10) );
  sky130_fd_sc_hd__a22oi_2 U22 ( .A1(oam[1985]), .A2(n586), .B1(oam[1993]), 
        .B2(n93), .Y(n1067) );
  sky130_fd_sc_hd__a22oi_2 U23 ( .A1(oam[1984]), .A2(n610), .B1(oam[1992]), 
        .B2(n31), .Y(n891) );
  sky130_fd_sc_hd__a22oi_2 U24 ( .A1(oam[1857]), .A2(n586), .B1(oam[1865]), 
        .B2(n92), .Y(n1023) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(n531), .Y(n537) );
  sky130_fd_sc_hd__buf_4 U26 ( .A(n532), .X(n533) );
  sky130_fd_sc_hd__buf_4 U27 ( .A(n532), .X(n535) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(n74), .Y(n77) );
  sky130_fd_sc_hd__a22oi_2 U29 ( .A1(oam[579]), .A2(n599), .B1(oam[587]), .B2(
        n72), .Y(n1482) );
  sky130_fd_sc_hd__a22oi_2 U30 ( .A1(oam[195]), .A2(n618), .B1(oam[203]), .B2(
        n71), .Y(n1536) );
  sky130_fd_sc_hd__inv_4 U31 ( .A(n569), .Y(n572) );
  sky130_fd_sc_hd__a22oi_2 U32 ( .A1(oam[1347]), .A2(n608), .B1(oam[1355]), 
        .B2(n59), .Y(n1384) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n2270), .B(n2252), .Y(n2271) );
  sky130_fd_sc_hd__nand2_1 U34 ( .A(n2252), .B(n2260), .Y(n452) );
  sky130_fd_sc_hd__a22oi_2 U35 ( .A1(oam[1217]), .A2(n609), .B1(oam[1225]), 
        .B2(n77), .Y(n1165) );
  sky130_fd_sc_hd__and4_4 U36 ( .A(n1410), .B(n1409), .C(n1411), .D(n1412), 
        .X(n508) );
  sky130_fd_sc_hd__inv_1 U37 ( .A(n2292), .Y(n54) );
  sky130_fd_sc_hd__clkinv_1 U38 ( .A(n596), .Y(n614) );
  sky130_fd_sc_hd__inv_1 U39 ( .A(n2291), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(n14), .Y(n20) );
  sky130_fd_sc_hd__a22oi_2 U41 ( .A1(oam[65]), .A2(n617), .B1(oam[73]), .B2(
        n20), .Y(n1141) );
  sky130_fd_sc_hd__clkinv_1 U42 ( .A(n596), .Y(n615) );
  sky130_fd_sc_hd__buf_2 U43 ( .A(n838), .X(n2294) );
  sky130_fd_sc_hd__buf_2 U44 ( .A(n838), .X(n2289) );
  sky130_fd_sc_hd__buf_2 U45 ( .A(n838), .X(n2295) );
  sky130_fd_sc_hd__buf_2 U46 ( .A(n838), .X(n2287) );
  sky130_fd_sc_hd__inv_1 U47 ( .A(n515), .Y(n521) );
  sky130_fd_sc_hd__nand2_2 U48 ( .A(N32), .B(n2278), .Y(n2277) );
  sky130_fd_sc_hd__nand2_4 U49 ( .A(n2249), .B(n2250), .Y(n2248) );
  sky130_fd_sc_hd__inv_2 U50 ( .A(n90), .Y(n92) );
  sky130_fd_sc_hd__buf_2 U51 ( .A(n838), .X(n2290) );
  sky130_fd_sc_hd__inv_4 U52 ( .A(n2248), .Y(n838) );
  sky130_fd_sc_hd__a22oi_2 U53 ( .A1(oam[1987]), .A2(n608), .B1(oam[1995]), 
        .B2(n76), .Y(n1418) );
  sky130_fd_sc_hd__a22oi_2 U54 ( .A1(oam[1219]), .A2(n607), .B1(oam[1227]), 
        .B2(n20), .Y(n1516) );
  sky130_fd_sc_hd__a22oi_2 U55 ( .A1(oam[1731]), .A2(n604), .B1(oam[1739]), 
        .B2(n64), .Y(n1506) );
  sky130_fd_sc_hd__inv_1 U56 ( .A(n2248), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U57 ( .A(n11), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U58 ( .A(n838), .Y(n14) );
  sky130_fd_sc_hd__inv_1 U59 ( .A(n13), .Y(n15) );
  sky130_fd_sc_hd__inv_1 U60 ( .A(n13), .Y(n16) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(n13), .Y(n17) );
  sky130_fd_sc_hd__inv_1 U62 ( .A(n14), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(n14), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U64 ( .A(n2288), .Y(n21) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(n2288), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U66 ( .A(n21), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U67 ( .A(n21), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U68 ( .A(n21), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(n22), .Y(n26) );
  sky130_fd_sc_hd__inv_1 U70 ( .A(n22), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U71 ( .A(n22), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U72 ( .A(n2289), .Y(n29) );
  sky130_fd_sc_hd__inv_2 U73 ( .A(n2289), .Y(n30) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(n29), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U75 ( .A(n29), .Y(n32) );
  sky130_fd_sc_hd__inv_1 U76 ( .A(n29), .Y(n33) );
  sky130_fd_sc_hd__inv_1 U77 ( .A(n30), .Y(n34) );
  sky130_fd_sc_hd__inv_1 U78 ( .A(n30), .Y(n35) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(n30), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U80 ( .A(n2287), .Y(n37) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n2287), .Y(n38) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(n37), .Y(n39) );
  sky130_fd_sc_hd__inv_1 U83 ( .A(n37), .Y(n40) );
  sky130_fd_sc_hd__inv_1 U84 ( .A(n37), .Y(n41) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(n38), .Y(n42) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(n38), .Y(n43) );
  sky130_fd_sc_hd__inv_1 U87 ( .A(n38), .Y(n44) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(n2293), .Y(n45) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(n2293), .Y(n46) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(n45), .Y(n47) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(n45), .Y(n48) );
  sky130_fd_sc_hd__inv_1 U92 ( .A(n45), .Y(n49) );
  sky130_fd_sc_hd__inv_1 U93 ( .A(n46), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(n46), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U95 ( .A(n46), .Y(n52) );
  sky130_fd_sc_hd__inv_2 U96 ( .A(n2292), .Y(n53) );
  sky130_fd_sc_hd__inv_1 U97 ( .A(n53), .Y(n55) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(n53), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U99 ( .A(n53), .Y(n57) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(n54), .Y(n58) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(n54), .Y(n59) );
  sky130_fd_sc_hd__inv_2 U102 ( .A(n2290), .Y(n60) );
  sky130_fd_sc_hd__inv_2 U103 ( .A(n2290), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(n60), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(n60), .Y(n63) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(n60), .Y(n64) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(n61), .Y(n65) );
  sky130_fd_sc_hd__inv_1 U108 ( .A(n61), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(n61), .Y(n67) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(n2291), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(n68), .Y(n70) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(n68), .Y(n71) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(n68), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(n69), .Y(n73) );
  sky130_fd_sc_hd__inv_2 U115 ( .A(n11), .Y(n74) );
  sky130_fd_sc_hd__inv_2 U116 ( .A(n11), .Y(n75) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(n74), .Y(n76) );
  sky130_fd_sc_hd__inv_1 U118 ( .A(n74), .Y(n78) );
  sky130_fd_sc_hd__inv_1 U119 ( .A(n75), .Y(n79) );
  sky130_fd_sc_hd__inv_1 U120 ( .A(n75), .Y(n80) );
  sky130_fd_sc_hd__inv_1 U121 ( .A(n75), .Y(n81) );
  sky130_fd_sc_hd__inv_2 U122 ( .A(n2294), .Y(n82) );
  sky130_fd_sc_hd__inv_2 U123 ( .A(n2294), .Y(n83) );
  sky130_fd_sc_hd__inv_1 U124 ( .A(n82), .Y(n84) );
  sky130_fd_sc_hd__inv_1 U125 ( .A(n82), .Y(n85) );
  sky130_fd_sc_hd__inv_1 U126 ( .A(n82), .Y(n86) );
  sky130_fd_sc_hd__inv_1 U127 ( .A(n83), .Y(n87) );
  sky130_fd_sc_hd__inv_1 U128 ( .A(n83), .Y(n88) );
  sky130_fd_sc_hd__inv_1 U129 ( .A(n83), .Y(n89) );
  sky130_fd_sc_hd__inv_2 U130 ( .A(n2295), .Y(n90) );
  sky130_fd_sc_hd__inv_2 U131 ( .A(n2295), .Y(n91) );
  sky130_fd_sc_hd__inv_1 U132 ( .A(n90), .Y(n93) );
  sky130_fd_sc_hd__inv_1 U133 ( .A(n90), .Y(n94) );
  sky130_fd_sc_hd__inv_1 U134 ( .A(n91), .Y(n95) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(n91), .Y(n96) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(n91), .Y(n97) );
  sky130_fd_sc_hd__buf_2 U137 ( .A(n838), .X(n2288) );
  sky130_fd_sc_hd__buf_2 U138 ( .A(n838), .X(n2293) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U139 ( .A(n838), .X(n2292) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U140 ( .A(n838), .X(n2291) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(n564), .Y(n571) );
  sky130_fd_sc_hd__inv_2 U142 ( .A(n2491), .Y(n2493) );
  sky130_fd_sc_hd__nand2_1 U143 ( .A(N33), .B(n2258), .Y(n2257) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(n2281), .Y(n851) );
  sky130_fd_sc_hd__buf_6 U145 ( .A(n851), .X(n2380) );
  sky130_fd_sc_hd__a22oi_1 U146 ( .A1(oam[1270]), .A2(n479), .B1(oam[1278]), 
        .B2(n2326), .Y(n2043) );
  sky130_fd_sc_hd__and4_1 U147 ( .A(n1277), .B(n1278), .C(n1279), .D(n1280), 
        .X(n512) );
  sky130_fd_sc_hd__and4_1 U148 ( .A(n1190), .B(n1191), .C(n1192), .D(n1193), 
        .X(n514) );
  sky130_fd_sc_hd__and4_1 U149 ( .A(n1321), .B(n1322), .C(n1323), .D(n1324), 
        .X(n511) );
  sky130_fd_sc_hd__and4_1 U150 ( .A(n1453), .B(n1454), .C(n1455), .D(n1456), 
        .X(n507) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(n2511), .Y(n2533) );
  sky130_fd_sc_hd__inv_1 U152 ( .A(n2758), .Y(n2768) );
  sky130_fd_sc_hd__nand2_1 U153 ( .A(n2276), .B(n2252), .Y(n2279) );
  sky130_fd_sc_hd__nand2_1 U154 ( .A(n2270), .B(n2256), .Y(n2273) );
  sky130_fd_sc_hd__nand4_1 U155 ( .A(n511), .B(n512), .C(n513), .D(n514), .Y(
        n2770) );
  sky130_fd_sc_hd__buf_2 U156 ( .A(n849), .X(n2358) );
  sky130_fd_sc_hd__a22oi_1 U157 ( .A1(oam[1142]), .A2(n482), .B1(oam[1150]), 
        .B2(n2326), .Y(n1999) );
  sky130_fd_sc_hd__inv_2 U158 ( .A(n474), .Y(n476) );
  sky130_fd_sc_hd__inv_2 U159 ( .A(n473), .Y(n484) );
  sky130_fd_sc_hd__inv_2 U160 ( .A(oam[1832]), .Y(n447) );
  sky130_fd_sc_hd__inv_2 U161 ( .A(oam[1368]), .Y(n448) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(oam[1065]), .Y(n444) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(oam[1057]), .Y(n443) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(oam[1905]), .Y(n449) );
  sky130_fd_sc_hd__inv_2 U165 ( .A(oam[1825]), .Y(n446) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(oam[1393]), .Y(n442) );
  sky130_fd_sc_hd__a22oi_1 U167 ( .A1(oam[2017]), .A2(n2309), .B1(oam[2025]), 
        .B2(n2323), .Y(n1065) );
  sky130_fd_sc_hd__inv_2 U168 ( .A(oam[1882]), .Y(n440) );
  sky130_fd_sc_hd__a22oi_1 U169 ( .A1(oam[1717]), .A2(n2366), .B1(oam[1725]), 
        .B2(n2377), .Y(n1859) );
  sky130_fd_sc_hd__a22oi_1 U170 ( .A1(oam[1189]), .A2(n529), .B1(oam[1197]), 
        .B2(n566), .Y(n1870) );
  sky130_fd_sc_hd__a22oi_1 U171 ( .A1(oam[38]), .A2(n519), .B1(oam[46]), .B2(
        n566), .Y(n2024) );
  sky130_fd_sc_hd__inv_2 U172 ( .A(oam[1726]), .Y(n501) );
  sky130_fd_sc_hd__inv_2 U173 ( .A(oam[1718]), .Y(n500) );
  sky130_fd_sc_hd__a22oi_1 U174 ( .A1(oam[1686]), .A2(n562), .B1(oam[1694]), 
        .B2(n2356), .Y(n2039) );
  sky130_fd_sc_hd__inv_2 U175 ( .A(oam[1198]), .Y(n461) );
  sky130_fd_sc_hd__a22oi_1 U176 ( .A1(oam[678]), .A2(n519), .B1(oam[686]), 
        .B2(n567), .Y(n2058) );
  sky130_fd_sc_hd__a22oi_1 U177 ( .A1(oam[694]), .A2(n2373), .B1(oam[702]), 
        .B2(n2378), .Y(n2057) );
  sky130_fd_sc_hd__inv_2 U178 ( .A(oam[174]), .Y(n455) );
  sky130_fd_sc_hd__a22oi_1 U179 ( .A1(oam[230]), .A2(n2307), .B1(oam[238]), 
        .B2(n2324), .Y(n2064) );
  sky130_fd_sc_hd__a22oi_1 U180 ( .A1(oam[1888]), .A2(n471), .B1(oam[1896]), 
        .B2(n2323), .Y(n835) );
  sky130_fd_sc_hd__inv_2 U181 ( .A(oam[1783]), .Y(n498) );
  sky130_fd_sc_hd__inv_2 U182 ( .A(oam[1751]), .Y(n499) );
  sky130_fd_sc_hd__inv_2 U183 ( .A(oam[1743]), .Y(n470) );
  sky130_fd_sc_hd__inv_2 U184 ( .A(oam[1735]), .Y(n469) );
  sky130_fd_sc_hd__inv_2 U185 ( .A(oam[1271]), .Y(n497) );
  sky130_fd_sc_hd__a22oi_1 U186 ( .A1(oam[1191]), .A2(n529), .B1(oam[1199]), 
        .B2(n577), .Y(n2229) );
  sky130_fd_sc_hd__a22oi_1 U187 ( .A1(oam[1207]), .A2(n2368), .B1(oam[1215]), 
        .B2(n2376), .Y(n2228) );
  sky130_fd_sc_hd__a22oi_1 U188 ( .A1(oam[1175]), .A2(n557), .B1(oam[1183]), 
        .B2(n2355), .Y(n2230) );
  sky130_fd_sc_hd__a22oi_1 U189 ( .A1(oam[759]), .A2(n479), .B1(oam[767]), 
        .B2(n2325), .Y(n2234) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(n2490), .Y(n2565) );
  sky130_fd_sc_hd__inv_2 U191 ( .A(n2545), .Y(n2563) );
  sky130_fd_sc_hd__inv_2 U192 ( .A(n2541), .Y(n2559) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(n2546), .Y(n2550) );
  sky130_fd_sc_hd__inv_2 U194 ( .A(n2551), .Y(n2555) );
  sky130_fd_sc_hd__inv_2 U195 ( .A(n2748), .Y(n2736) );
  sky130_fd_sc_hd__inv_2 U196 ( .A(n2749), .Y(n2564) );
  sky130_fd_sc_hd__inv_2 U197 ( .A(obj_size), .Y(n622) );
  sky130_fd_sc_hd__inv_2 U198 ( .A(n2759), .Y(n2760) );
  sky130_fd_sc_hd__inv_2 U199 ( .A(n2521), .Y(n2514) );
  sky130_fd_sc_hd__inv_2 U200 ( .A(n2520), .Y(n2558) );
  sky130_fd_sc_hd__nand4b_2 U201 ( .A_N(n1893), .B(n451), .C(n217), .D(n124), 
        .Y(oam_bus[6]) );
  sky130_fd_sc_hd__inv_2 U202 ( .A(n2505), .Y(n2506) );
  sky130_fd_sc_hd__inv_2 U203 ( .A(n2750), .Y(n2484) );
  sky130_fd_sc_hd__inv_2 U204 ( .A(n594), .Y(n605) );
  sky130_fd_sc_hd__inv_2 U205 ( .A(n441), .Y(n594) );
  sky130_fd_sc_hd__inv_1 U206 ( .A(n597), .Y(n616) );
  sky130_fd_sc_hd__inv_1 U207 ( .A(n441), .Y(n598) );
  sky130_fd_sc_hd__inv_2 U208 ( .A(n2413), .Y(n2405) );
  sky130_fd_sc_hd__inv_2 U209 ( .A(n2413), .Y(n2406) );
  sky130_fd_sc_hd__inv_2 U210 ( .A(n2396), .Y(n2389) );
  sky130_fd_sc_hd__inv_2 U211 ( .A(n2396), .Y(n2390) );
  sky130_fd_sc_hd__inv_2 U212 ( .A(n2478), .Y(n2471) );
  sky130_fd_sc_hd__inv_2 U213 ( .A(n2478), .Y(n2472) );
  sky130_fd_sc_hd__inv_2 U214 ( .A(n2462), .Y(n2455) );
  sky130_fd_sc_hd__inv_2 U215 ( .A(n2462), .Y(n2456) );
  sky130_fd_sc_hd__inv_2 U216 ( .A(n2446), .Y(n2439) );
  sky130_fd_sc_hd__inv_2 U217 ( .A(n2446), .Y(n2440) );
  sky130_fd_sc_hd__buf_1 U218 ( .A(n2415), .X(n2413) );
  sky130_fd_sc_hd__inv_2 U219 ( .A(n2412), .Y(n2407) );
  sky130_fd_sc_hd__inv_2 U220 ( .A(n2412), .Y(n2408) );
  sky130_fd_sc_hd__buf_1 U221 ( .A(n2399), .X(n2396) );
  sky130_fd_sc_hd__inv_2 U222 ( .A(n2395), .Y(n2391) );
  sky130_fd_sc_hd__inv_2 U223 ( .A(n2395), .Y(n2392) );
  sky130_fd_sc_hd__buf_1 U224 ( .A(n2481), .X(n2478) );
  sky130_fd_sc_hd__inv_2 U225 ( .A(n2477), .Y(n2473) );
  sky130_fd_sc_hd__inv_2 U226 ( .A(n2477), .Y(n2474) );
  sky130_fd_sc_hd__buf_1 U227 ( .A(n2465), .X(n2462) );
  sky130_fd_sc_hd__inv_2 U228 ( .A(n2461), .Y(n2457) );
  sky130_fd_sc_hd__inv_2 U229 ( .A(n2461), .Y(n2458) );
  sky130_fd_sc_hd__buf_1 U230 ( .A(n2449), .X(n2446) );
  sky130_fd_sc_hd__inv_2 U231 ( .A(n2445), .Y(n2441) );
  sky130_fd_sc_hd__inv_2 U232 ( .A(n2445), .Y(n2442) );
  sky130_fd_sc_hd__buf_1 U233 ( .A(n2415), .X(n2412) );
  sky130_fd_sc_hd__inv_2 U234 ( .A(n2414), .Y(n2400) );
  sky130_fd_sc_hd__buf_2 U235 ( .A(n565), .X(n568) );
  sky130_fd_sc_hd__inv_2 U236 ( .A(n592), .Y(n599) );
  sky130_fd_sc_hd__inv_2 U237 ( .A(n595), .Y(n609) );
  sky130_fd_sc_hd__buf_1 U238 ( .A(n2399), .X(n2395) );
  sky130_fd_sc_hd__inv_2 U239 ( .A(n2397), .Y(n2384) );
  sky130_fd_sc_hd__buf_1 U240 ( .A(n2481), .X(n2477) );
  sky130_fd_sc_hd__inv_2 U241 ( .A(n2479), .Y(n2466) );
  sky130_fd_sc_hd__buf_1 U242 ( .A(n2465), .X(n2461) );
  sky130_fd_sc_hd__inv_2 U243 ( .A(n2463), .Y(n2450) );
  sky130_fd_sc_hd__buf_1 U244 ( .A(n2449), .X(n2445) );
  sky130_fd_sc_hd__inv_2 U245 ( .A(n2447), .Y(n2434) );
  sky130_fd_sc_hd__buf_1 U246 ( .A(n2415), .X(n2414) );
  sky130_fd_sc_hd__buf_1 U247 ( .A(n2399), .X(n2397) );
  sky130_fd_sc_hd__buf_1 U248 ( .A(n2481), .X(n2479) );
  sky130_fd_sc_hd__buf_1 U249 ( .A(n2465), .X(n2463) );
  sky130_fd_sc_hd__buf_1 U250 ( .A(n2449), .X(n2447) );
  sky130_fd_sc_hd__inv_2 U251 ( .A(n531), .Y(n538) );
  sky130_fd_sc_hd__inv_2 U252 ( .A(n515), .Y(n522) );
  sky130_fd_sc_hd__inv_2 U253 ( .A(n598), .Y(n621) );
  sky130_fd_sc_hd__and2_1 U254 ( .A(n212), .B(n110), .X(n98) );
  sky130_fd_sc_hd__and2_1 U255 ( .A(N37), .B(N38), .X(n99) );
  sky130_fd_sc_hd__and2_1 U256 ( .A(n214), .B(n110), .X(n100) );
  sky130_fd_sc_hd__and2_1 U257 ( .A(n2087), .B(n200), .X(n101) );
  sky130_fd_sc_hd__inv_2 U258 ( .A(n2433), .Y(n2431) );
  sky130_fd_sc_hd__inv_2 U259 ( .A(n2433), .Y(n2432) );
  sky130_fd_sc_hd__inv_2 U260 ( .A(n2427), .Y(n2425) );
  sky130_fd_sc_hd__inv_2 U261 ( .A(n2427), .Y(n2426) );
  sky130_fd_sc_hd__inv_2 U262 ( .A(n2421), .Y(n2420) );
  sky130_fd_sc_hd__buf_1 U263 ( .A(n2399), .X(n2398) );
  sky130_fd_sc_hd__inv_2 U264 ( .A(n2394), .Y(n2393) );
  sky130_fd_sc_hd__inv_2 U265 ( .A(n2397), .Y(n2385) );
  sky130_fd_sc_hd__buf_1 U266 ( .A(n2481), .X(n2480) );
  sky130_fd_sc_hd__inv_2 U267 ( .A(n2476), .Y(n2475) );
  sky130_fd_sc_hd__inv_2 U268 ( .A(n2479), .Y(n2467) );
  sky130_fd_sc_hd__buf_1 U269 ( .A(n2465), .X(n2464) );
  sky130_fd_sc_hd__inv_2 U270 ( .A(n2460), .Y(n2459) );
  sky130_fd_sc_hd__inv_2 U271 ( .A(n2463), .Y(n2451) );
  sky130_fd_sc_hd__buf_1 U272 ( .A(n2449), .X(n2448) );
  sky130_fd_sc_hd__inv_2 U273 ( .A(n2444), .Y(n2443) );
  sky130_fd_sc_hd__inv_2 U274 ( .A(n2447), .Y(n2435) );
  sky130_fd_sc_hd__inv_2 U275 ( .A(n2411), .Y(n2409) );
  sky130_fd_sc_hd__inv_2 U276 ( .A(n2411), .Y(n2410) );
  sky130_fd_sc_hd__inv_2 U277 ( .A(n2414), .Y(n2401) );
  sky130_fd_sc_hd__inv_2 U278 ( .A(n570), .Y(n573) );
  sky130_fd_sc_hd__and2_1 U279 ( .A(n2152), .B(n2687), .X(n102) );
  sky130_fd_sc_hd__and2_1 U280 ( .A(n225), .B(n125), .X(n103) );
  sky130_fd_sc_hd__and2_1 U281 ( .A(n2687), .B(n2211), .X(n104) );
  sky130_fd_sc_hd__and2_1 U282 ( .A(N35), .B(n2565), .X(n105) );
  sky130_fd_sc_hd__and2_1 U283 ( .A(n2565), .B(n2152), .X(n106) );
  sky130_fd_sc_hd__and2_1 U284 ( .A(n131), .B(n2558), .X(n107) );
  sky130_fd_sc_hd__and2_1 U285 ( .A(n424), .B(n131), .X(n108) );
  sky130_fd_sc_hd__and2_1 U286 ( .A(n2563), .B(n131), .X(n109) );
  sky130_fd_sc_hd__and2_1 U287 ( .A(n2564), .B(n2558), .X(n110) );
  sky130_fd_sc_hd__and2_1 U288 ( .A(n424), .B(n2555), .X(n111) );
  sky130_fd_sc_hd__and2_1 U289 ( .A(n424), .B(n2564), .X(n112) );
  sky130_fd_sc_hd__and2_1 U290 ( .A(n2563), .B(n2555), .X(n113) );
  sky130_fd_sc_hd__and2_1 U291 ( .A(n2555), .B(n2558), .X(n114) );
  sky130_fd_sc_hd__and2_1 U292 ( .A(n2563), .B(n2564), .X(n115) );
  sky130_fd_sc_hd__and2_1 U293 ( .A(n2559), .B(n131), .X(n116) );
  sky130_fd_sc_hd__and2_1 U294 ( .A(n2559), .B(n2555), .X(n117) );
  sky130_fd_sc_hd__and2_1 U295 ( .A(n2559), .B(n2564), .X(n118) );
  sky130_fd_sc_hd__and2_1 U296 ( .A(n424), .B(n2550), .X(n119) );
  sky130_fd_sc_hd__and2_1 U297 ( .A(n2563), .B(n2550), .X(n120) );
  sky130_fd_sc_hd__and2_1 U298 ( .A(n2550), .B(n2558), .X(n121) );
  sky130_fd_sc_hd__and2_1 U299 ( .A(n2559), .B(n2550), .X(n122) );
  sky130_fd_sc_hd__and2_1 U300 ( .A(n211), .B(n110), .X(n123) );
  sky130_fd_sc_hd__inv_2 U301 ( .A(n2421), .Y(n2419) );
  sky130_fd_sc_hd__buf_1 U302 ( .A(n2399), .X(n2394) );
  sky130_fd_sc_hd__inv_2 U303 ( .A(n2394), .Y(n2386) );
  sky130_fd_sc_hd__inv_2 U304 ( .A(n2398), .Y(n2387) );
  sky130_fd_sc_hd__inv_2 U305 ( .A(n2398), .Y(n2388) );
  sky130_fd_sc_hd__buf_1 U306 ( .A(n2481), .X(n2476) );
  sky130_fd_sc_hd__inv_2 U307 ( .A(n2476), .Y(n2468) );
  sky130_fd_sc_hd__inv_2 U308 ( .A(n2480), .Y(n2469) );
  sky130_fd_sc_hd__inv_2 U309 ( .A(n2480), .Y(n2470) );
  sky130_fd_sc_hd__buf_1 U310 ( .A(n2465), .X(n2460) );
  sky130_fd_sc_hd__inv_2 U311 ( .A(n2460), .Y(n2452) );
  sky130_fd_sc_hd__inv_2 U312 ( .A(n2464), .Y(n2453) );
  sky130_fd_sc_hd__inv_2 U313 ( .A(n2464), .Y(n2454) );
  sky130_fd_sc_hd__buf_1 U314 ( .A(n2449), .X(n2444) );
  sky130_fd_sc_hd__inv_2 U315 ( .A(n2444), .Y(n2436) );
  sky130_fd_sc_hd__inv_2 U316 ( .A(n2448), .Y(n2437) );
  sky130_fd_sc_hd__inv_2 U317 ( .A(n2448), .Y(n2438) );
  sky130_fd_sc_hd__buf_1 U318 ( .A(n2415), .X(n2411) );
  sky130_fd_sc_hd__inv_2 U319 ( .A(n2411), .Y(n2402) );
  sky130_fd_sc_hd__inv_2 U320 ( .A(n2415), .Y(n2403) );
  sky130_fd_sc_hd__inv_2 U321 ( .A(n2411), .Y(n2404) );
  sky130_fd_sc_hd__inv_2 U322 ( .A(n592), .Y(n600) );
  sky130_fd_sc_hd__and4_1 U323 ( .A(n1895), .B(n1896), .C(n1897), .D(n1898), 
        .X(n124) );
  sky130_fd_sc_hd__and2_1 U324 ( .A(n2211), .B(n2212), .X(n125) );
  sky130_fd_sc_hd__and2_1 U325 ( .A(N38), .B(n2211), .X(n126) );
  sky130_fd_sc_hd__and2_1 U326 ( .A(n218), .B(n125), .X(n127) );
  sky130_fd_sc_hd__and2_1 U327 ( .A(n125), .B(n230), .X(n128) );
  sky130_fd_sc_hd__and2_1 U328 ( .A(n230), .B(n126), .X(n129) );
  sky130_fd_sc_hd__and2_1 U329 ( .A(n2087), .B(n230), .X(n130) );
  sky130_fd_sc_hd__and2_1 U330 ( .A(n462), .B(N33), .X(n131) );
  sky130_fd_sc_hd__and2_1 U331 ( .A(n115), .B(n419), .X(n132) );
  sky130_fd_sc_hd__and2_1 U332 ( .A(n109), .B(n419), .X(n133) );
  sky130_fd_sc_hd__and2_1 U333 ( .A(n120), .B(n419), .X(n134) );
  sky130_fd_sc_hd__and2_1 U334 ( .A(n113), .B(n419), .X(n135) );
  sky130_fd_sc_hd__and2_1 U335 ( .A(n112), .B(n419), .X(n136) );
  sky130_fd_sc_hd__and2_1 U336 ( .A(n108), .B(n419), .X(n137) );
  sky130_fd_sc_hd__and2_1 U337 ( .A(n119), .B(n419), .X(n138) );
  sky130_fd_sc_hd__and2_1 U338 ( .A(n111), .B(n419), .X(n139) );
  sky130_fd_sc_hd__and2_1 U339 ( .A(n107), .B(n419), .X(n140) );
  sky130_fd_sc_hd__and2_1 U340 ( .A(n121), .B(n419), .X(n141) );
  sky130_fd_sc_hd__and2_1 U341 ( .A(N38), .B(n106), .X(n142) );
  sky130_fd_sc_hd__and2_1 U342 ( .A(n315), .B(n110), .X(n143) );
  sky130_fd_sc_hd__and2_1 U343 ( .A(n420), .B(n110), .X(n144) );
  sky130_fd_sc_hd__and2_1 U344 ( .A(n105), .B(N36), .X(n145) );
  sky130_fd_sc_hd__and2_1 U345 ( .A(n115), .B(n315), .X(n146) );
  sky130_fd_sc_hd__and2_1 U346 ( .A(n113), .B(n315), .X(n147) );
  sky130_fd_sc_hd__and2_1 U347 ( .A(n112), .B(n315), .X(n148) );
  sky130_fd_sc_hd__and2_1 U348 ( .A(n111), .B(n315), .X(n149) );
  sky130_fd_sc_hd__and2_1 U349 ( .A(n114), .B(n315), .X(n150) );
  sky130_fd_sc_hd__and2_1 U350 ( .A(n115), .B(n420), .X(n151) );
  sky130_fd_sc_hd__and2_1 U351 ( .A(n109), .B(n420), .X(n152) );
  sky130_fd_sc_hd__and2_1 U352 ( .A(n120), .B(n420), .X(n153) );
  sky130_fd_sc_hd__and2_1 U353 ( .A(n113), .B(n420), .X(n154) );
  sky130_fd_sc_hd__and2_1 U354 ( .A(n112), .B(n420), .X(n155) );
  sky130_fd_sc_hd__and2_1 U355 ( .A(n108), .B(n420), .X(n156) );
  sky130_fd_sc_hd__and2_1 U356 ( .A(n119), .B(n420), .X(n157) );
  sky130_fd_sc_hd__and2_1 U357 ( .A(n111), .B(n420), .X(n158) );
  sky130_fd_sc_hd__and2_1 U358 ( .A(n107), .B(n420), .X(n159) );
  sky130_fd_sc_hd__and2_1 U359 ( .A(n121), .B(n420), .X(n160) );
  sky130_fd_sc_hd__and2_1 U360 ( .A(n114), .B(n420), .X(n161) );
  sky130_fd_sc_hd__and2_1 U361 ( .A(n118), .B(n419), .X(n162) );
  sky130_fd_sc_hd__and2_1 U362 ( .A(n116), .B(n419), .X(n163) );
  sky130_fd_sc_hd__and2_1 U363 ( .A(n122), .B(n419), .X(n164) );
  sky130_fd_sc_hd__and2_1 U364 ( .A(n117), .B(n419), .X(n165) );
  sky130_fd_sc_hd__and2_1 U365 ( .A(n422), .B(n114), .X(n166) );
  sky130_fd_sc_hd__and2_1 U366 ( .A(n419), .B(n114), .X(n167) );
  sky130_fd_sc_hd__and2_1 U367 ( .A(n422), .B(n110), .X(n168) );
  sky130_fd_sc_hd__and2_1 U368 ( .A(n419), .B(n110), .X(n169) );
  sky130_fd_sc_hd__and2_1 U369 ( .A(n105), .B(N38), .X(n170) );
  sky130_fd_sc_hd__and2_1 U370 ( .A(n314), .B(n110), .X(n171) );
  sky130_fd_sc_hd__and2_1 U371 ( .A(n115), .B(n422), .X(n172) );
  sky130_fd_sc_hd__and2_1 U372 ( .A(n109), .B(n422), .X(n173) );
  sky130_fd_sc_hd__and2_1 U373 ( .A(n120), .B(n422), .X(n174) );
  sky130_fd_sc_hd__and2_1 U374 ( .A(n113), .B(n422), .X(n175) );
  sky130_fd_sc_hd__and2_1 U375 ( .A(n112), .B(n422), .X(n176) );
  sky130_fd_sc_hd__and2_1 U376 ( .A(n108), .B(n422), .X(n177) );
  sky130_fd_sc_hd__and2_1 U377 ( .A(n119), .B(n422), .X(n178) );
  sky130_fd_sc_hd__and2_1 U378 ( .A(n111), .B(n422), .X(n179) );
  sky130_fd_sc_hd__and2_1 U379 ( .A(n107), .B(n422), .X(n180) );
  sky130_fd_sc_hd__and2_1 U380 ( .A(n121), .B(n422), .X(n181) );
  sky130_fd_sc_hd__and2_1 U381 ( .A(n115), .B(n314), .X(n182) );
  sky130_fd_sc_hd__and2_1 U382 ( .A(n113), .B(n314), .X(n183) );
  sky130_fd_sc_hd__and2_1 U383 ( .A(n112), .B(n314), .X(n184) );
  sky130_fd_sc_hd__and2_1 U384 ( .A(n111), .B(n314), .X(n185) );
  sky130_fd_sc_hd__and2_1 U385 ( .A(n114), .B(n314), .X(n186) );
  sky130_fd_sc_hd__and2_1 U386 ( .A(n118), .B(n315), .X(n187) );
  sky130_fd_sc_hd__and2_1 U387 ( .A(n122), .B(n315), .X(n188) );
  sky130_fd_sc_hd__and2_1 U388 ( .A(n117), .B(n315), .X(n189) );
  sky130_fd_sc_hd__and2_1 U389 ( .A(n118), .B(n420), .X(n190) );
  sky130_fd_sc_hd__and2_1 U390 ( .A(n116), .B(n420), .X(n191) );
  sky130_fd_sc_hd__and2_1 U391 ( .A(n122), .B(n420), .X(n192) );
  sky130_fd_sc_hd__and2_1 U392 ( .A(n117), .B(n420), .X(n193) );
  sky130_fd_sc_hd__and2_1 U393 ( .A(n118), .B(n422), .X(n194) );
  sky130_fd_sc_hd__and2_1 U394 ( .A(n116), .B(n422), .X(n195) );
  sky130_fd_sc_hd__and2_1 U395 ( .A(n122), .B(n422), .X(n196) );
  sky130_fd_sc_hd__and2_1 U396 ( .A(n117), .B(n422), .X(n197) );
  sky130_fd_sc_hd__and2_1 U397 ( .A(n118), .B(n314), .X(n198) );
  sky130_fd_sc_hd__and2_1 U398 ( .A(n117), .B(n314), .X(n199) );
  sky130_fd_sc_hd__and2_1 U399 ( .A(N36), .B(n106), .X(n200) );
  sky130_fd_sc_hd__and2_1 U400 ( .A(n145), .B(n99), .X(n201) );
  sky130_fd_sc_hd__and2_1 U401 ( .A(n170), .B(n423), .X(n202) );
  sky130_fd_sc_hd__and2_1 U402 ( .A(n200), .B(n99), .X(n203) );
  sky130_fd_sc_hd__and2_1 U403 ( .A(n142), .B(n423), .X(n204) );
  sky130_fd_sc_hd__and3_1 U404 ( .A(n105), .B(n423), .C(n2212), .X(n205) );
  sky130_fd_sc_hd__and2_1 U405 ( .A(n205), .B(n110), .X(n206) );
  sky130_fd_sc_hd__and2_1 U406 ( .A(n203), .B(n110), .X(n207) );
  sky130_fd_sc_hd__and2_1 U407 ( .A(n201), .B(n110), .X(n208) );
  sky130_fd_sc_hd__and2_1 U408 ( .A(n202), .B(n110), .X(n209) );
  sky130_fd_sc_hd__and2_1 U409 ( .A(n204), .B(n110), .X(n210) );
  sky130_fd_sc_hd__and3_1 U410 ( .A(n423), .B(n106), .C(n2212), .X(n211) );
  sky130_fd_sc_hd__and3_1 U411 ( .A(n99), .B(n106), .C(n2687), .X(n212) );
  sky130_fd_sc_hd__and3_1 U412 ( .A(n2087), .B(n106), .C(n2687), .X(n213) );
  sky130_fd_sc_hd__and3_1 U413 ( .A(n99), .B(n105), .C(n2687), .X(n214) );
  sky130_fd_sc_hd__and3_1 U414 ( .A(n2087), .B(n105), .C(n2687), .X(n215) );
  sky130_fd_sc_hd__inv_2 U415 ( .A(data_in[4]), .Y(n2433) );
  sky130_fd_sc_hd__inv_2 U416 ( .A(data_in[2]), .Y(n2421) );
  sky130_fd_sc_hd__inv_2 U417 ( .A(data_in[3]), .Y(n2427) );
  sky130_fd_sc_hd__a22oi_1 U418 ( .A1(n2373), .A2(oam[1458]), .B1(n2381), .B2(
        oam[1466]), .Y(n216) );
  sky130_fd_sc_hd__nand4_1 U419 ( .A(n579), .B(n580), .C(n581), .D(n582), .Y(
        n450) );
  sky130_fd_sc_hd__inv_2 U420 ( .A(n2273), .Y(n547) );
  sky130_fd_sc_hd__clkinv_1 U421 ( .A(n585), .Y(n596) );
  sky130_fd_sc_hd__and4_1 U422 ( .A(n1939), .B(n1940), .C(n1941), .D(n1942), 
        .X(n217) );
  sky130_fd_sc_hd__and2_1 U423 ( .A(N36), .B(n2152), .X(n218) );
  sky130_fd_sc_hd__and2_1 U424 ( .A(n102), .B(n125), .X(n219) );
  sky130_fd_sc_hd__and2_1 U425 ( .A(n218), .B(n2087), .X(n220) );
  sky130_fd_sc_hd__and2_1 U426 ( .A(n102), .B(n2087), .X(n221) );
  sky130_fd_sc_hd__and2_1 U427 ( .A(n218), .B(n126), .X(n222) );
  sky130_fd_sc_hd__and2_1 U428 ( .A(n102), .B(n126), .X(n223) );
  sky130_fd_sc_hd__and2_1 U429 ( .A(n102), .B(n99), .X(n224) );
  sky130_fd_sc_hd__and2_1 U430 ( .A(N35), .B(n2687), .X(n225) );
  sky130_fd_sc_hd__and2_1 U431 ( .A(n218), .B(n99), .X(n226) );
  sky130_fd_sc_hd__and2_1 U432 ( .A(n225), .B(n126), .X(n227) );
  sky130_fd_sc_hd__and2_1 U433 ( .A(n225), .B(n2087), .X(n228) );
  sky130_fd_sc_hd__and2_1 U434 ( .A(n225), .B(n99), .X(n229) );
  sky130_fd_sc_hd__and2_1 U435 ( .A(N36), .B(N35), .X(n230) );
  sky130_fd_sc_hd__and2_1 U436 ( .A(n99), .B(n230), .X(n231) );
  sky130_fd_sc_hd__and2_1 U437 ( .A(n214), .B(n114), .X(n232) );
  sky130_fd_sc_hd__and2_1 U438 ( .A(n212), .B(n114), .X(n233) );
  sky130_fd_sc_hd__and2_1 U439 ( .A(n113), .B(n215), .X(n234) );
  sky130_fd_sc_hd__and2_1 U440 ( .A(n113), .B(n213), .X(n235) );
  sky130_fd_sc_hd__and2_1 U441 ( .A(n113), .B(n205), .X(n236) );
  sky130_fd_sc_hd__and2_1 U442 ( .A(n113), .B(n211), .X(n237) );
  sky130_fd_sc_hd__and2_1 U443 ( .A(n113), .B(n214), .X(n238) );
  sky130_fd_sc_hd__and2_1 U444 ( .A(n113), .B(n212), .X(n239) );
  sky130_fd_sc_hd__and2_1 U445 ( .A(n111), .B(n215), .X(n240) );
  sky130_fd_sc_hd__and2_1 U446 ( .A(n111), .B(n213), .X(n241) );
  sky130_fd_sc_hd__and2_1 U447 ( .A(n111), .B(n205), .X(n242) );
  sky130_fd_sc_hd__and2_1 U448 ( .A(n111), .B(n211), .X(n243) );
  sky130_fd_sc_hd__and2_1 U449 ( .A(n111), .B(n214), .X(n244) );
  sky130_fd_sc_hd__and2_1 U450 ( .A(n111), .B(n212), .X(n245) );
  sky130_fd_sc_hd__and2_1 U451 ( .A(n113), .B(n101), .X(n246) );
  sky130_fd_sc_hd__and2_1 U452 ( .A(n113), .B(n201), .X(n247) );
  sky130_fd_sc_hd__and2_1 U453 ( .A(n113), .B(n203), .X(n248) );
  sky130_fd_sc_hd__and2_1 U454 ( .A(n113), .B(n202), .X(n249) );
  sky130_fd_sc_hd__and2_1 U455 ( .A(n113), .B(n204), .X(n250) );
  sky130_fd_sc_hd__and2_1 U456 ( .A(n111), .B(n101), .X(n251) );
  sky130_fd_sc_hd__and2_1 U457 ( .A(n111), .B(n201), .X(n252) );
  sky130_fd_sc_hd__and2_1 U458 ( .A(n111), .B(n203), .X(n253) );
  sky130_fd_sc_hd__and2_1 U459 ( .A(n111), .B(n202), .X(n254) );
  sky130_fd_sc_hd__and2_1 U460 ( .A(n111), .B(n204), .X(n255) );
  sky130_fd_sc_hd__and2_1 U461 ( .A(n215), .B(n110), .X(n256) );
  sky130_fd_sc_hd__and2_1 U462 ( .A(n213), .B(n110), .X(n257) );
  sky130_fd_sc_hd__and2_1 U463 ( .A(n114), .B(n215), .X(n258) );
  sky130_fd_sc_hd__and2_1 U464 ( .A(n114), .B(n213), .X(n259) );
  sky130_fd_sc_hd__and2_1 U465 ( .A(n114), .B(n205), .X(n260) );
  sky130_fd_sc_hd__and2_1 U466 ( .A(n114), .B(n211), .X(n261) );
  sky130_fd_sc_hd__and2_1 U467 ( .A(n114), .B(n101), .X(n262) );
  sky130_fd_sc_hd__and2_1 U468 ( .A(n114), .B(n201), .X(n263) );
  sky130_fd_sc_hd__and2_1 U469 ( .A(n114), .B(n203), .X(n264) );
  sky130_fd_sc_hd__and2_1 U470 ( .A(n114), .B(n202), .X(n265) );
  sky130_fd_sc_hd__and2_1 U471 ( .A(n114), .B(n204), .X(n266) );
  sky130_fd_sc_hd__and2_1 U472 ( .A(n101), .B(n110), .X(n267) );
  sky130_fd_sc_hd__and2_1 U473 ( .A(n115), .B(n215), .X(n268) );
  sky130_fd_sc_hd__and2_1 U474 ( .A(n115), .B(n213), .X(n269) );
  sky130_fd_sc_hd__and2_1 U475 ( .A(n115), .B(n205), .X(n270) );
  sky130_fd_sc_hd__and2_1 U476 ( .A(n115), .B(n211), .X(n271) );
  sky130_fd_sc_hd__and2_1 U477 ( .A(n115), .B(n214), .X(n272) );
  sky130_fd_sc_hd__and2_1 U478 ( .A(n115), .B(n212), .X(n273) );
  sky130_fd_sc_hd__and2_1 U479 ( .A(n112), .B(n215), .X(n274) );
  sky130_fd_sc_hd__and2_1 U480 ( .A(n112), .B(n213), .X(n275) );
  sky130_fd_sc_hd__and2_1 U481 ( .A(n112), .B(n205), .X(n276) );
  sky130_fd_sc_hd__and2_1 U482 ( .A(n112), .B(n211), .X(n277) );
  sky130_fd_sc_hd__and2_1 U483 ( .A(n112), .B(n214), .X(n279) );
  sky130_fd_sc_hd__and2_1 U484 ( .A(n112), .B(n212), .X(n280) );
  sky130_fd_sc_hd__and2_1 U485 ( .A(n115), .B(n204), .X(n281) );
  sky130_fd_sc_hd__and2_1 U486 ( .A(n115), .B(n101), .X(n282) );
  sky130_fd_sc_hd__and2_1 U487 ( .A(n115), .B(n201), .X(n284) );
  sky130_fd_sc_hd__and2_1 U488 ( .A(n115), .B(n203), .X(n285) );
  sky130_fd_sc_hd__and2_1 U489 ( .A(n115), .B(n202), .X(n286) );
  sky130_fd_sc_hd__and2_1 U490 ( .A(n112), .B(n204), .X(n287) );
  sky130_fd_sc_hd__and2_1 U491 ( .A(n112), .B(n101), .X(n288) );
  sky130_fd_sc_hd__and2_1 U492 ( .A(n112), .B(n201), .X(n289) );
  sky130_fd_sc_hd__and2_1 U493 ( .A(n112), .B(n203), .X(n290) );
  sky130_fd_sc_hd__and2_1 U494 ( .A(n112), .B(n202), .X(n291) );
  sky130_fd_sc_hd__and2_1 U495 ( .A(n117), .B(n215), .X(n292) );
  sky130_fd_sc_hd__and2_1 U496 ( .A(n117), .B(n213), .X(n293) );
  sky130_fd_sc_hd__and2_1 U497 ( .A(n117), .B(n205), .X(n294) );
  sky130_fd_sc_hd__and2_1 U498 ( .A(n117), .B(n211), .X(n295) );
  sky130_fd_sc_hd__and2_1 U499 ( .A(n117), .B(n214), .X(n296) );
  sky130_fd_sc_hd__and2_1 U500 ( .A(n117), .B(n212), .X(n297) );
  sky130_fd_sc_hd__and2_1 U501 ( .A(n117), .B(n101), .X(n298) );
  sky130_fd_sc_hd__and2_1 U502 ( .A(n117), .B(n201), .X(n299) );
  sky130_fd_sc_hd__and2_1 U503 ( .A(n117), .B(n203), .X(n300) );
  sky130_fd_sc_hd__and2_1 U504 ( .A(n117), .B(n202), .X(n301) );
  sky130_fd_sc_hd__and2_1 U505 ( .A(n117), .B(n204), .X(n302) );
  sky130_fd_sc_hd__and2_1 U506 ( .A(n118), .B(n215), .X(n303) );
  sky130_fd_sc_hd__and2_1 U507 ( .A(n118), .B(n213), .X(n304) );
  sky130_fd_sc_hd__and2_1 U508 ( .A(n118), .B(n205), .X(n305) );
  sky130_fd_sc_hd__and2_1 U509 ( .A(n118), .B(n211), .X(n306) );
  sky130_fd_sc_hd__and2_1 U510 ( .A(n118), .B(n214), .X(n307) );
  sky130_fd_sc_hd__and2_1 U511 ( .A(n118), .B(n212), .X(n308) );
  sky130_fd_sc_hd__and2_1 U512 ( .A(n118), .B(n204), .X(n309) );
  sky130_fd_sc_hd__and2_1 U513 ( .A(n118), .B(n101), .X(n310) );
  sky130_fd_sc_hd__and2_1 U514 ( .A(n118), .B(n201), .X(n311) );
  sky130_fd_sc_hd__and2_1 U515 ( .A(n118), .B(n203), .X(n312) );
  sky130_fd_sc_hd__and2_1 U516 ( .A(n118), .B(n202), .X(n313) );
  sky130_fd_sc_hd__and2_1 U517 ( .A(n2736), .B(n105), .X(n314) );
  sky130_fd_sc_hd__and2_1 U518 ( .A(n2736), .B(n106), .X(n315) );
  sky130_fd_sc_hd__and2_1 U519 ( .A(n109), .B(n314), .X(n316) );
  sky130_fd_sc_hd__and2_1 U520 ( .A(n109), .B(n315), .X(n317) );
  sky130_fd_sc_hd__and2_1 U521 ( .A(n120), .B(n314), .X(n318) );
  sky130_fd_sc_hd__and2_1 U522 ( .A(n120), .B(n315), .X(n319) );
  sky130_fd_sc_hd__and2_1 U523 ( .A(n108), .B(n314), .X(n320) );
  sky130_fd_sc_hd__and2_1 U524 ( .A(n108), .B(n315), .X(n321) );
  sky130_fd_sc_hd__and2_1 U525 ( .A(n119), .B(n314), .X(n322) );
  sky130_fd_sc_hd__and2_1 U526 ( .A(n119), .B(n315), .X(n323) );
  sky130_fd_sc_hd__and2_1 U527 ( .A(n107), .B(n314), .X(n324) );
  sky130_fd_sc_hd__and2_1 U528 ( .A(n107), .B(n315), .X(n325) );
  sky130_fd_sc_hd__and2_1 U529 ( .A(n121), .B(n314), .X(n326) );
  sky130_fd_sc_hd__and2_1 U530 ( .A(n121), .B(n315), .X(n327) );
  sky130_fd_sc_hd__and2_1 U531 ( .A(n116), .B(n314), .X(n328) );
  sky130_fd_sc_hd__and2_1 U532 ( .A(n116), .B(n315), .X(n329) );
  sky130_fd_sc_hd__and2_1 U533 ( .A(n122), .B(n314), .X(n330) );
  sky130_fd_sc_hd__and2_1 U534 ( .A(n120), .B(n215), .X(n331) );
  sky130_fd_sc_hd__and2_1 U535 ( .A(n120), .B(n213), .X(n332) );
  sky130_fd_sc_hd__and2_1 U536 ( .A(n120), .B(n205), .X(n333) );
  sky130_fd_sc_hd__and2_1 U537 ( .A(n120), .B(n211), .X(n334) );
  sky130_fd_sc_hd__and2_1 U538 ( .A(n120), .B(n214), .X(n335) );
  sky130_fd_sc_hd__and2_1 U539 ( .A(n120), .B(n212), .X(n336) );
  sky130_fd_sc_hd__and2_1 U540 ( .A(n119), .B(n215), .X(n337) );
  sky130_fd_sc_hd__and2_1 U541 ( .A(n119), .B(n213), .X(n338) );
  sky130_fd_sc_hd__and2_1 U542 ( .A(n119), .B(n205), .X(n339) );
  sky130_fd_sc_hd__and2_1 U543 ( .A(n119), .B(n211), .X(n340) );
  sky130_fd_sc_hd__and2_1 U544 ( .A(n119), .B(n214), .X(n341) );
  sky130_fd_sc_hd__and2_1 U545 ( .A(n119), .B(n212), .X(n342) );
  sky130_fd_sc_hd__and2_1 U546 ( .A(n120), .B(n101), .X(n343) );
  sky130_fd_sc_hd__and2_1 U547 ( .A(n120), .B(n201), .X(n344) );
  sky130_fd_sc_hd__and2_1 U548 ( .A(n120), .B(n203), .X(n345) );
  sky130_fd_sc_hd__and2_1 U549 ( .A(n120), .B(n202), .X(n346) );
  sky130_fd_sc_hd__and2_1 U550 ( .A(n120), .B(n204), .X(n347) );
  sky130_fd_sc_hd__and2_1 U551 ( .A(n119), .B(n101), .X(n348) );
  sky130_fd_sc_hd__and2_1 U552 ( .A(n119), .B(n201), .X(n349) );
  sky130_fd_sc_hd__and2_1 U553 ( .A(n119), .B(n203), .X(n350) );
  sky130_fd_sc_hd__and2_1 U554 ( .A(n119), .B(n202), .X(n351) );
  sky130_fd_sc_hd__and2_1 U555 ( .A(n119), .B(n204), .X(n352) );
  sky130_fd_sc_hd__and2_1 U556 ( .A(n121), .B(n215), .X(n353) );
  sky130_fd_sc_hd__and2_1 U557 ( .A(n121), .B(n213), .X(n354) );
  sky130_fd_sc_hd__and2_1 U558 ( .A(n121), .B(n205), .X(n355) );
  sky130_fd_sc_hd__and2_1 U559 ( .A(n121), .B(n211), .X(n356) );
  sky130_fd_sc_hd__and2_1 U560 ( .A(n121), .B(n214), .X(n357) );
  sky130_fd_sc_hd__and2_1 U561 ( .A(n121), .B(n212), .X(n358) );
  sky130_fd_sc_hd__and2_1 U562 ( .A(n121), .B(n101), .X(n359) );
  sky130_fd_sc_hd__and2_1 U563 ( .A(n121), .B(n201), .X(n360) );
  sky130_fd_sc_hd__and2_1 U564 ( .A(n121), .B(n203), .X(n361) );
  sky130_fd_sc_hd__and2_1 U565 ( .A(n121), .B(n202), .X(n362) );
  sky130_fd_sc_hd__and2_1 U566 ( .A(n121), .B(n204), .X(n363) );
  sky130_fd_sc_hd__and2_1 U567 ( .A(n109), .B(n215), .X(n364) );
  sky130_fd_sc_hd__and2_1 U568 ( .A(n109), .B(n213), .X(n365) );
  sky130_fd_sc_hd__and2_1 U569 ( .A(n109), .B(n205), .X(n366) );
  sky130_fd_sc_hd__and2_1 U570 ( .A(n109), .B(n211), .X(n367) );
  sky130_fd_sc_hd__and2_1 U571 ( .A(n109), .B(n214), .X(n368) );
  sky130_fd_sc_hd__and2_1 U572 ( .A(n109), .B(n212), .X(n369) );
  sky130_fd_sc_hd__and2_1 U573 ( .A(n108), .B(n215), .X(n370) );
  sky130_fd_sc_hd__and2_1 U574 ( .A(n108), .B(n213), .X(n371) );
  sky130_fd_sc_hd__and2_1 U575 ( .A(n108), .B(n205), .X(n372) );
  sky130_fd_sc_hd__and2_1 U576 ( .A(n108), .B(n211), .X(n373) );
  sky130_fd_sc_hd__and2_1 U577 ( .A(n108), .B(n214), .X(n374) );
  sky130_fd_sc_hd__and2_1 U578 ( .A(n108), .B(n212), .X(n375) );
  sky130_fd_sc_hd__and2_1 U579 ( .A(n109), .B(n101), .X(n376) );
  sky130_fd_sc_hd__and2_1 U580 ( .A(n109), .B(n201), .X(n377) );
  sky130_fd_sc_hd__and2_1 U581 ( .A(n109), .B(n203), .X(n378) );
  sky130_fd_sc_hd__and2_1 U582 ( .A(n109), .B(n202), .X(n379) );
  sky130_fd_sc_hd__and2_1 U583 ( .A(n109), .B(n204), .X(n380) );
  sky130_fd_sc_hd__and2_1 U584 ( .A(n108), .B(n101), .X(n381) );
  sky130_fd_sc_hd__and2_1 U585 ( .A(n108), .B(n201), .X(n382) );
  sky130_fd_sc_hd__and2_1 U586 ( .A(n108), .B(n203), .X(n383) );
  sky130_fd_sc_hd__and2_1 U587 ( .A(n108), .B(n202), .X(n384) );
  sky130_fd_sc_hd__and2_1 U588 ( .A(n108), .B(n204), .X(n385) );
  sky130_fd_sc_hd__and2_1 U589 ( .A(n107), .B(n215), .X(n386) );
  sky130_fd_sc_hd__and2_1 U590 ( .A(n107), .B(n213), .X(n387) );
  sky130_fd_sc_hd__and2_1 U591 ( .A(n107), .B(n205), .X(n388) );
  sky130_fd_sc_hd__and2_1 U592 ( .A(n107), .B(n211), .X(n389) );
  sky130_fd_sc_hd__and2_1 U593 ( .A(n107), .B(n214), .X(n390) );
  sky130_fd_sc_hd__and2_1 U594 ( .A(n107), .B(n212), .X(n391) );
  sky130_fd_sc_hd__and2_1 U595 ( .A(n107), .B(n101), .X(n392) );
  sky130_fd_sc_hd__and2_1 U596 ( .A(n107), .B(n201), .X(n393) );
  sky130_fd_sc_hd__and2_1 U597 ( .A(n107), .B(n203), .X(n394) );
  sky130_fd_sc_hd__and2_1 U598 ( .A(n107), .B(n202), .X(n395) );
  sky130_fd_sc_hd__and2_1 U599 ( .A(n107), .B(n204), .X(n396) );
  sky130_fd_sc_hd__and2_1 U600 ( .A(n122), .B(n215), .X(n397) );
  sky130_fd_sc_hd__and2_1 U601 ( .A(n122), .B(n213), .X(n398) );
  sky130_fd_sc_hd__and2_1 U602 ( .A(n122), .B(n205), .X(n399) );
  sky130_fd_sc_hd__and2_1 U603 ( .A(n122), .B(n211), .X(n400) );
  sky130_fd_sc_hd__and2_1 U604 ( .A(n122), .B(n214), .X(n401) );
  sky130_fd_sc_hd__and2_1 U605 ( .A(n122), .B(n212), .X(n402) );
  sky130_fd_sc_hd__and2_1 U606 ( .A(n122), .B(n101), .X(n403) );
  sky130_fd_sc_hd__and2_1 U607 ( .A(n122), .B(n201), .X(n404) );
  sky130_fd_sc_hd__and2_1 U608 ( .A(n122), .B(n203), .X(n405) );
  sky130_fd_sc_hd__and2_1 U609 ( .A(n122), .B(n202), .X(n406) );
  sky130_fd_sc_hd__and2_1 U610 ( .A(n122), .B(n204), .X(n407) );
  sky130_fd_sc_hd__and2_1 U611 ( .A(n116), .B(n215), .X(n408) );
  sky130_fd_sc_hd__and2_1 U612 ( .A(n116), .B(n213), .X(n409) );
  sky130_fd_sc_hd__and2_1 U613 ( .A(n116), .B(n205), .X(n410) );
  sky130_fd_sc_hd__and2_1 U614 ( .A(n116), .B(n211), .X(n411) );
  sky130_fd_sc_hd__and2_1 U615 ( .A(n116), .B(n214), .X(n412) );
  sky130_fd_sc_hd__and2_1 U616 ( .A(n116), .B(n212), .X(n413) );
  sky130_fd_sc_hd__and2_1 U617 ( .A(n116), .B(n101), .X(n414) );
  sky130_fd_sc_hd__and2_1 U618 ( .A(n116), .B(n201), .X(n415) );
  sky130_fd_sc_hd__and2_1 U619 ( .A(n116), .B(n203), .X(n416) );
  sky130_fd_sc_hd__and2_1 U620 ( .A(n116), .B(n202), .X(n417) );
  sky130_fd_sc_hd__and2_1 U621 ( .A(n116), .B(n204), .X(n418) );
  sky130_fd_sc_hd__and2_1 U622 ( .A(n104), .B(n142), .X(n419) );
  sky130_fd_sc_hd__inv_2 U623 ( .A(n2223), .Y(n2087) );
  sky130_fd_sc_hd__and2_1 U624 ( .A(n2087), .B(n145), .X(n420) );
  sky130_fd_sc_hd__and2_1 U625 ( .A(n104), .B(n170), .X(n422) );
  sky130_fd_sc_hd__and2_1 U626 ( .A(N36), .B(n2211), .X(n423) );
  sky130_fd_sc_hd__and2_1 U627 ( .A(n2497), .B(n2496), .X(n424) );
  sky130_fd_sc_hd__inv_2 U628 ( .A(oam[1963]), .Y(n426) );
  sky130_fd_sc_hd__inv_2 U629 ( .A(n2433), .Y(n2428) );
  sky130_fd_sc_hd__inv_2 U630 ( .A(n2433), .Y(n2429) );
  sky130_fd_sc_hd__inv_2 U631 ( .A(n2433), .Y(n2430) );
  sky130_fd_sc_hd__inv_2 U632 ( .A(n2427), .Y(n2422) );
  sky130_fd_sc_hd__inv_2 U633 ( .A(n2427), .Y(n2423) );
  sky130_fd_sc_hd__inv_2 U634 ( .A(n2427), .Y(n2424) );
  sky130_fd_sc_hd__inv_2 U635 ( .A(n2421), .Y(n2416) );
  sky130_fd_sc_hd__inv_2 U636 ( .A(n2421), .Y(n2417) );
  sky130_fd_sc_hd__inv_2 U637 ( .A(n2421), .Y(n2418) );
  sky130_fd_sc_hd__and3_1 U638 ( .A(n424), .B(n2485), .C(n2484), .X(n425) );
  sky130_fd_sc_hd__inv_2 U639 ( .A(data_in[0]), .Y(n2399) );
  sky130_fd_sc_hd__inv_2 U640 ( .A(data_in[7]), .Y(n2481) );
  sky130_fd_sc_hd__inv_2 U641 ( .A(data_in[6]), .Y(n2465) );
  sky130_fd_sc_hd__inv_2 U642 ( .A(data_in[5]), .Y(n2449) );
  sky130_fd_sc_hd__inv_2 U643 ( .A(data_in[1]), .Y(n2415) );
  sky130_fd_sc_hd__inv_2 U644 ( .A(ce), .Y(n2482) );
  sky130_fd_sc_hd__clkinv_1 U645 ( .A(n2507), .Y(n2504) );
  sky130_fd_sc_hd__buf_4 U646 ( .A(n839), .X(n2304) );
  sky130_fd_sc_hd__buf_4 U647 ( .A(n839), .X(n2305) );
  sky130_fd_sc_hd__buf_4 U648 ( .A(n839), .X(n2297) );
  sky130_fd_sc_hd__a2bb2oi_1 U649 ( .B1(oam[1955]), .B2(n524), .A1_N(n426), 
        .A2_N(n570), .Y(n1420) );
  sky130_fd_sc_hd__clkinv_2 U650 ( .A(n564), .Y(n570) );
  sky130_fd_sc_hd__dlygate4sd3_1 U651 ( .A(n2767), .X(n427) );
  sky130_fd_sc_hd__buf_6 U652 ( .A(n516), .X(n518) );
  sky130_fd_sc_hd__nand4_1 U653 ( .A(n506), .B(n3), .C(n508), .D(n2), .Y(
        oam_bus[3]) );
  sky130_fd_sc_hd__nand4_2 U654 ( .A(n506), .B(n507), .C(n508), .D(n509), .Y(
        n2769) );
  sky130_fd_sc_hd__and4_1 U655 ( .A(n1497), .B(n1498), .C(n1499), .D(n1500), 
        .X(n509) );
  sky130_fd_sc_hd__a22oi_1 U656 ( .A1(oam[1840]), .A2(n2368), .B1(oam[1848]), 
        .B2(n2375), .Y(n843) );
  sky130_fd_sc_hd__buf_4 U657 ( .A(n851), .X(n2377) );
  sky130_fd_sc_hd__buf_4 U658 ( .A(n851), .X(n2381) );
  sky130_fd_sc_hd__buf_4 U659 ( .A(n851), .X(n2376) );
  sky130_fd_sc_hd__clkbuf_8 U660 ( .A(n851), .X(n2374) );
  sky130_fd_sc_hd__buf_2 U661 ( .A(n6), .X(n2335) );
  sky130_fd_sc_hd__inv_4 U662 ( .A(n2261), .Y(n842) );
  sky130_fd_sc_hd__nand2_2 U663 ( .A(n2254), .B(n2260), .Y(n2261) );
  sky130_fd_sc_hd__buf_6 U664 ( .A(n842), .X(n2330) );
  sky130_fd_sc_hd__buf_6 U665 ( .A(n850), .X(n2371) );
  sky130_fd_sc_hd__clkbuf_8 U666 ( .A(n849), .X(n2360) );
  sky130_fd_sc_hd__nand4_1 U667 ( .A(n511), .B(n512), .C(n513), .D(n514), .Y(
        oam_bus[2]) );
  sky130_fd_sc_hd__o21ai_0 U668 ( .A1(n2514), .A2(n2526), .B1(n2525), .Y(n2517) );
  sky130_fd_sc_hd__o21ai_0 U669 ( .A1(n2533), .A2(n2526), .B1(n2525), .Y(n2535) );
  sky130_fd_sc_hd__inv_2 U670 ( .A(n2526), .Y(n2537) );
  sky130_fd_sc_hd__buf_2 U671 ( .A(n842), .X(n2329) );
  sky130_fd_sc_hd__a22oi_1 U672 ( .A1(oam[1702]), .A2(n517), .B1(oam[1710]), 
        .B2(n574), .Y(n2038) );
  sky130_fd_sc_hd__a22oi_2 U673 ( .A1(oam[1187]), .A2(n519), .B1(oam[1195]), 
        .B2(n574), .Y(n1518) );
  sky130_fd_sc_hd__o21ai_0 U674 ( .A1(n2539), .A2(n2411), .B1(n2501), .Y(n827)
         );
  sky130_fd_sc_hd__inv_2 U675 ( .A(n2269), .Y(n430) );
  sky130_fd_sc_hd__inv_1 U676 ( .A(n2269), .Y(n848) );
  sky130_fd_sc_hd__nand2_1 U677 ( .A(n2250), .B(n2270), .Y(n2269) );
  sky130_fd_sc_hd__nor2_1 U678 ( .A(n431), .B(spr_y_coord[7]), .Y(n2753) );
  sky130_fd_sc_hd__nand2_1 U679 ( .A(n432), .B(n2751), .Y(n431) );
  sky130_fd_sc_hd__nor2_1 U680 ( .A(spr_y_coord[4]), .B(n623), .Y(n432) );
  sky130_fd_sc_hd__nand4_1 U681 ( .A(n882), .B(n883), .C(n884), .D(n885), .Y(
        n433) );
  sky130_fd_sc_hd__nor2_1 U682 ( .A(n435), .B(n436), .Y(n434) );
  sky130_fd_sc_hd__nand4_1 U683 ( .A(n970), .B(n971), .C(n972), .D(n973), .Y(
        n435) );
  sky130_fd_sc_hd__nand4_1 U684 ( .A(n926), .B(n927), .C(n928), .D(n929), .Y(
        n436) );
  sky130_fd_sc_hd__nor2_1 U685 ( .A(n433), .B(n438), .Y(n437) );
  sky130_fd_sc_hd__nand4_1 U686 ( .A(n624), .B(n829), .C(n830), .D(n831), .Y(
        n438) );
  sky130_fd_sc_hd__buf_6 U687 ( .A(n850), .X(n439) );
  sky130_fd_sc_hd__buf_6 U688 ( .A(n430), .X(n2346) );
  sky130_fd_sc_hd__a2bb2oi_1 U689 ( .B1(oam[1874]), .B2(n2305), .A1_N(n440), 
        .A2_N(n538), .Y(n1198) );
  sky130_fd_sc_hd__inv_2 U690 ( .A(n2251), .Y(n441) );
  sky130_fd_sc_hd__inv_1 U691 ( .A(n2251), .Y(n583) );
  sky130_fd_sc_hd__a2bb2oi_1 U692 ( .B1(oam[1401]), .B2(n2333), .A1_N(n442), 
        .A2_N(n475), .Y(n1030) );
  sky130_fd_sc_hd__buf_2 U693 ( .A(n6), .X(n2338) );
  sky130_fd_sc_hd__buf_6 U694 ( .A(n849), .X(n2364) );
  sky130_fd_sc_hd__o22a_2 U695 ( .A1(n443), .A2(n520), .B1(n444), .B2(n570), 
        .X(n1123) );
  sky130_fd_sc_hd__and4_1 U696 ( .A(n1234), .B(n1236), .C(n1235), .D(n1237), 
        .X(n513) );
  sky130_fd_sc_hd__clkbuf_8 U697 ( .A(n851), .X(n2379) );
  sky130_fd_sc_hd__buf_2 U698 ( .A(n841), .X(n445) );
  sky130_fd_sc_hd__buf_4 U699 ( .A(n841), .X(n2324) );
  sky130_fd_sc_hd__buf_4 U700 ( .A(n850), .X(n2365) );
  sky130_fd_sc_hd__a2bb2oi_1 U701 ( .B1(oam[1833]), .B2(n572), .A1_N(n446), 
        .A2_N(n522), .Y(n1025) );
  sky130_fd_sc_hd__buf_6 U702 ( .A(n516), .X(n519) );
  sky130_fd_sc_hd__a2bb2oi_1 U703 ( .B1(oam[1824]), .B2(n518), .A1_N(n447), 
        .A2_N(n570), .Y(n844) );
  sky130_fd_sc_hd__a2bb2oi_1 U704 ( .B1(oam[1360]), .B2(n2305), .A1_N(n448), 
        .A2_N(n538), .Y(n856) );
  sky130_fd_sc_hd__buf_6 U705 ( .A(n4), .X(n2313) );
  sky130_fd_sc_hd__buf_6 U706 ( .A(n4), .X(n2307) );
  sky130_fd_sc_hd__a2bb2oi_1 U707 ( .B1(oam[1913]), .B2(n2333), .A1_N(n449), 
        .A2_N(n475), .Y(n1020) );
  sky130_fd_sc_hd__inv_1 U708 ( .A(n474), .Y(n475) );
  sky130_fd_sc_hd__buf_6 U709 ( .A(n840), .X(n2308) );
  sky130_fd_sc_hd__nand2_2 U710 ( .A(n2270), .B(n2254), .Y(n2272) );
  sky130_fd_sc_hd__buf_6 U711 ( .A(n6), .X(n2344) );
  sky130_fd_sc_hd__buf_6 U712 ( .A(n847), .X(n2343) );
  sky130_fd_sc_hd__inv_4 U713 ( .A(n2284), .Y(n850) );
  sky130_fd_sc_hd__buf_6 U714 ( .A(n851), .X(n2375) );
  sky130_fd_sc_hd__buf_6 U715 ( .A(n4), .X(n2312) );
  sky130_fd_sc_hd__buf_6 U716 ( .A(n840), .X(n472) );
  sky130_fd_sc_hd__nand2_1 U717 ( .A(n2258), .B(n2264), .Y(n2263) );
  sky130_fd_sc_hd__nand2_1 U718 ( .A(N34), .B(n2264), .Y(n2286) );
  sky130_fd_sc_hd__inv_2 U719 ( .A(n10), .Y(oam_bus[1]) );
  sky130_fd_sc_hd__buf_6 U720 ( .A(n847), .X(n2340) );
  sky130_fd_sc_hd__inv_2 U721 ( .A(n476), .Y(n480) );
  sky130_fd_sc_hd__buf_4 U722 ( .A(n849), .X(n2362) );
  sky130_fd_sc_hd__buf_4 U723 ( .A(n849), .X(n2361) );
  sky130_fd_sc_hd__buf_4 U724 ( .A(n847), .X(n2341) );
  sky130_fd_sc_hd__a22oi_1 U725 ( .A1(n2299), .A2(oam[2002]), .B1(n541), .B2(
        oam[2010]), .Y(n1242) );
  sky130_fd_sc_hd__buf_6 U726 ( .A(n839), .X(n2299) );
  sky130_fd_sc_hd__a22oi_1 U727 ( .A1(n2296), .A2(oam[978]), .B1(n534), .B2(
        oam[986]), .Y(n1261) );
  sky130_fd_sc_hd__buf_12 U728 ( .A(n839), .X(n2296) );
  sky130_fd_sc_hd__a22oi_1 U729 ( .A1(n483), .A2(oam[1779]), .B1(n2330), .B2(
        oam[1787]), .Y(n1503) );
  sky130_fd_sc_hd__buf_6 U730 ( .A(n850), .X(n2373) );
  sky130_fd_sc_hd__inv_2 U731 ( .A(n1894), .Y(n451) );
  sky130_fd_sc_hd__a22oi_1 U732 ( .A1(n2298), .A2(oam[1110]), .B1(n545), .B2(
        oam[1118]), .Y(n2001) );
  sky130_fd_sc_hd__a22oi_1 U733 ( .A1(n487), .A2(oam[1654]), .B1(n2326), .B2(
        oam[1662]), .Y(n1989) );
  sky130_fd_sc_hd__a22oi_1 U734 ( .A1(n2341), .A2(oam[1158]), .B1(n2345), .B2(
        oam[1166]), .Y(n2050) );
  sky130_fd_sc_hd__a22oi_1 U735 ( .A1(n2366), .A2(oam[1590]), .B1(n2380), .B2(
        oam[1598]), .Y(n1993) );
  sky130_fd_sc_hd__a22oi_1 U736 ( .A1(n2368), .A2(oam[1206]), .B1(n2382), .B2(
        oam[1214]), .Y(n2047) );
  sky130_fd_sc_hd__buf_2 U737 ( .A(n851), .X(n2382) );
  sky130_fd_sc_hd__nand2_1 U738 ( .A(oam[1062]), .B(n525), .Y(n453) );
  sky130_fd_sc_hd__nand2_1 U739 ( .A(oam[1070]), .B(n572), .Y(n454) );
  sky130_fd_sc_hd__and2_1 U740 ( .A(n453), .B(n454), .X(n2004) );
  sky130_fd_sc_hd__a2bb2oi_1 U741 ( .B1(oam[166]), .B2(n524), .A1_N(n455), 
        .A2_N(n570), .Y(n2068) );
  sky130_fd_sc_hd__buf_4 U742 ( .A(n841), .X(n2320) );
  sky130_fd_sc_hd__nand2_1 U743 ( .A(N32), .B(N31), .Y(n2280) );
  sky130_fd_sc_hd__buf_6 U744 ( .A(n7), .X(n2336) );
  sky130_fd_sc_hd__a22oi_1 U745 ( .A1(oam[1173]), .A2(n559), .B1(oam[1181]), 
        .B2(n2357), .Y(n1871) );
  sky130_fd_sc_hd__inv_2 U746 ( .A(n2262), .Y(n474) );
  sky130_fd_sc_hd__nand2_1 U747 ( .A(oam[1174]), .B(n560), .Y(n456) );
  sky130_fd_sc_hd__nand2_1 U748 ( .A(oam[1182]), .B(n2356), .Y(n457) );
  sky130_fd_sc_hd__and2_0 U749 ( .A(n456), .B(n457), .X(n2049) );
  sky130_fd_sc_hd__buf_4 U750 ( .A(n842), .X(n2334) );
  sky130_fd_sc_hd__nand2_1 U751 ( .A(oam[550]), .B(n526), .Y(n458) );
  sky130_fd_sc_hd__nand2_1 U752 ( .A(oam[558]), .B(n572), .Y(n459) );
  sky130_fd_sc_hd__and2_1 U753 ( .A(n458), .B(n459), .X(n2014) );
  sky130_fd_sc_hd__a22oi_1 U754 ( .A1(oam[1670]), .A2(n2340), .B1(oam[1678]), 
        .B2(n2354), .Y(n2040) );
  sky130_fd_sc_hd__inv_1 U755 ( .A(n2367), .Y(n460) );
  sky130_fd_sc_hd__a22oi_1 U756 ( .A1(oam[1703]), .A2(n517), .B1(oam[1711]), 
        .B2(n577), .Y(n2218) );
  sky130_fd_sc_hd__buf_6 U757 ( .A(n842), .X(n2332) );
  sky130_fd_sc_hd__buf_4 U758 ( .A(n849), .X(n2355) );
  sky130_fd_sc_hd__buf_4 U759 ( .A(n849), .X(n2363) );
  sky130_fd_sc_hd__buf_4 U760 ( .A(n849), .X(n2357) );
  sky130_fd_sc_hd__a2bb2oi_1 U761 ( .B1(oam[1190]), .B2(n524), .A1_N(n461), 
        .A2_N(n571), .Y(n2048) );
  sky130_fd_sc_hd__o21ai_0 U762 ( .A1(p[0]), .A2(reset_line), .B1(n2503), .Y(
        n2507) );
  sky130_fd_sc_hd__o41ai_2 U763 ( .A1(state[1]), .A2(n2520), .A3(n2482), .A4(
        n2523), .B1(n2758), .Y(n2503) );
  sky130_fd_sc_hd__nand2_2 U764 ( .A(ce), .B(reset_line), .Y(n2758) );
  sky130_fd_sc_hd__buf_2 U765 ( .A(n850), .X(n2372) );
  sky130_fd_sc_hd__dlygate4sd1_1 U766 ( .A(N34), .X(n462) );
  sky130_fd_sc_hd__o21ai_0 U767 ( .A1(n2539), .A2(n2427), .B1(n2532), .Y(n825)
         );
  sky130_fd_sc_hd__buf_4 U768 ( .A(n430), .X(n2347) );
  sky130_fd_sc_hd__buf_4 U769 ( .A(n430), .X(n2351) );
  sky130_fd_sc_hd__buf_4 U770 ( .A(n848), .X(n2349) );
  sky130_fd_sc_hd__buf_6 U771 ( .A(n430), .X(n2348) );
  sky130_fd_sc_hd__a22oi_1 U772 ( .A1(oam[695]), .A2(n2371), .B1(oam[703]), 
        .B2(n2374), .Y(n2238) );
  sky130_fd_sc_hd__nand2_1 U773 ( .A(oam[758]), .B(n482), .Y(n463) );
  sky130_fd_sc_hd__nand2_1 U774 ( .A(oam[766]), .B(n2326), .Y(n464) );
  sky130_fd_sc_hd__and2_0 U775 ( .A(n463), .B(n464), .X(n2053) );
  sky130_fd_sc_hd__buf_6 U776 ( .A(n842), .X(n2326) );
  sky130_fd_sc_hd__buf_2 U777 ( .A(n839), .X(n2298) );
  sky130_fd_sc_hd__buf_4 U778 ( .A(n850), .X(n2370) );
  sky130_fd_sc_hd__nand2_2 U779 ( .A(n2276), .B(n2254), .Y(n2281) );
  sky130_fd_sc_hd__a22oi_1 U780 ( .A1(oam[1603]), .A2(n599), .B1(oam[1611]), 
        .B2(n86), .Y(n1462) );
  sky130_fd_sc_hd__nand2_2 U781 ( .A(n2249), .B(n2256), .Y(n2255) );
  sky130_fd_sc_hd__nand4_2 U782 ( .A(n465), .B(n466), .C(n467), .D(n468), .Y(
        oam_bus[7]) );
  sky130_fd_sc_hd__and4_1 U783 ( .A(n2205), .B(n2206), .C(n2207), .D(n2208), 
        .X(n465) );
  sky130_fd_sc_hd__and4_1 U784 ( .A(n2161), .B(n2162), .C(n2163), .D(n2164), 
        .X(n466) );
  sky130_fd_sc_hd__and4_1 U785 ( .A(n2116), .B(n2117), .C(n2118), .D(n2119), 
        .X(n467) );
  sky130_fd_sc_hd__and4_1 U786 ( .A(n2071), .B(n2072), .C(n2073), .D(n2074), 
        .X(n468) );
  sky130_fd_sc_hd__o22a_2 U787 ( .A1(n469), .A2(n597), .B1(n470), .B2(n12), 
        .X(n2216) );
  sky130_fd_sc_hd__buf_2 U788 ( .A(n839), .X(n2303) );
  sky130_fd_sc_hd__buf_6 U789 ( .A(n850), .X(n2366) );
  sky130_fd_sc_hd__buf_2 U790 ( .A(n4), .X(n471) );
  sky130_fd_sc_hd__inv_1 U791 ( .A(n2262), .Y(n473) );
  sky130_fd_sc_hd__inv_2 U792 ( .A(n474), .Y(n477) );
  sky130_fd_sc_hd__inv_2 U793 ( .A(n476), .Y(n478) );
  sky130_fd_sc_hd__inv_2 U794 ( .A(n476), .Y(n479) );
  sky130_fd_sc_hd__inv_2 U795 ( .A(n477), .Y(n481) );
  sky130_fd_sc_hd__inv_2 U796 ( .A(n477), .Y(n482) );
  sky130_fd_sc_hd__inv_2 U797 ( .A(n477), .Y(n483) );
  sky130_fd_sc_hd__inv_2 U798 ( .A(n473), .Y(n485) );
  sky130_fd_sc_hd__inv_2 U799 ( .A(n484), .Y(n486) );
  sky130_fd_sc_hd__inv_2 U800 ( .A(n484), .Y(n487) );
  sky130_fd_sc_hd__inv_2 U801 ( .A(n484), .Y(n488) );
  sky130_fd_sc_hd__inv_2 U802 ( .A(n485), .Y(n489) );
  sky130_fd_sc_hd__inv_2 U803 ( .A(n485), .Y(n490) );
  sky130_fd_sc_hd__buf_6 U804 ( .A(n850), .X(n2368) );
  sky130_fd_sc_hd__o21ai_1 U805 ( .A1(n2031), .A2(n2032), .B1(n127), .Y(n2030)
         );
  sky130_fd_sc_hd__buf_6 U806 ( .A(n841), .X(n2316) );
  sky130_fd_sc_hd__a2bb2oi_1 U807 ( .B1(oam[1759]), .B2(n545), .A1_N(n499), 
        .A2_N(n2255), .Y(n2215) );
  sky130_fd_sc_hd__nand4_2 U808 ( .A(n491), .B(n492), .C(n493), .D(n494), .Y(
        oam_bus[5]) );
  sky130_fd_sc_hd__and4_1 U809 ( .A(n1849), .B(n1850), .C(n1851), .D(n1852), 
        .X(n491) );
  sky130_fd_sc_hd__and4_4 U810 ( .A(n1805), .B(n1806), .C(n1807), .D(n1808), 
        .X(n492) );
  sky130_fd_sc_hd__and4_1 U811 ( .A(n1761), .B(n1762), .C(n1763), .D(n1764), 
        .X(n493) );
  sky130_fd_sc_hd__and4_1 U812 ( .A(n1717), .B(n1718), .C(n1719), .D(n1720), 
        .X(n494) );
  sky130_fd_sc_hd__inv_2 U813 ( .A(n570), .Y(n574) );
  sky130_fd_sc_hd__buf_2 U814 ( .A(n840), .X(n2306) );
  sky130_fd_sc_hd__buf_4 U815 ( .A(n6), .X(n2337) );
  sky130_fd_sc_hd__nand2_1 U816 ( .A(oam[677]), .B(n526), .Y(n495) );
  sky130_fd_sc_hd__nand2_1 U817 ( .A(oam[685]), .B(n572), .Y(n496) );
  sky130_fd_sc_hd__and2_1 U818 ( .A(n495), .B(n496), .X(n1880) );
  sky130_fd_sc_hd__buf_6 U819 ( .A(n516), .X(n517) );
  sky130_fd_sc_hd__nand2_2 U820 ( .A(n2249), .B(n2252), .Y(n2251) );
  sky130_fd_sc_hd__buf_6 U821 ( .A(n842), .X(n2325) );
  sky130_fd_sc_hd__buf_2 U822 ( .A(n841), .X(n2322) );
  sky130_fd_sc_hd__buf_2 U823 ( .A(n841), .X(n2315) );
  sky130_fd_sc_hd__a2bb2oi_1 U824 ( .B1(oam[1279]), .B2(n2325), .A1_N(n497), 
        .A2_N(n475), .Y(n2224) );
  sky130_fd_sc_hd__a2bb2oi_1 U825 ( .B1(oam[1791]), .B2(n2325), .A1_N(n498), 
        .A2_N(n475), .Y(n2213) );
  sky130_fd_sc_hd__buf_2 U826 ( .A(n842), .X(n2328) );
  sky130_fd_sc_hd__o22a_2 U827 ( .A1(n500), .A2(n460), .B1(n501), .B2(n2281), 
        .X(n2037) );
  sky130_fd_sc_hd__buf_2 U828 ( .A(n841), .X(n2318) );
  sky130_fd_sc_hd__buf_4 U829 ( .A(n839), .X(n2300) );
  sky130_fd_sc_hd__buf_6 U830 ( .A(n842), .X(n2333) );
  sky130_fd_sc_hd__buf_2 U831 ( .A(n842), .X(n2327) );
  sky130_fd_sc_hd__buf_6 U832 ( .A(n849), .X(n2356) );
  sky130_fd_sc_hd__buf_6 U833 ( .A(n850), .X(n2367) );
  sky130_fd_sc_hd__buf_2 U834 ( .A(n841), .X(n2317) );
  sky130_fd_sc_hd__nand4_2 U835 ( .A(n502), .B(n503), .C(n504), .D(n505), .Y(
        oam_bus[4]) );
  sky130_fd_sc_hd__and4_1 U836 ( .A(n1629), .B(n1630), .C(n1631), .D(n1632), 
        .X(n502) );
  sky130_fd_sc_hd__and4_1 U837 ( .A(n1673), .B(n1674), .C(n1675), .D(n1676), 
        .X(n503) );
  sky130_fd_sc_hd__and4_1 U838 ( .A(n1586), .B(n1585), .C(n1587), .D(n1588), 
        .X(n504) );
  sky130_fd_sc_hd__and4_1 U839 ( .A(n1541), .B(n1542), .C(n1543), .D(n1544), 
        .X(n505) );
  sky130_fd_sc_hd__and4_4 U840 ( .A(n1365), .B(n1366), .C(n1367), .D(n1368), 
        .X(n506) );
  sky130_fd_sc_hd__nand2_2 U841 ( .A(n2276), .B(n2256), .Y(n2284) );
  sky130_fd_sc_hd__inv_2 U842 ( .A(n2496), .Y(n510) );
  sky130_fd_sc_hd__buf_2 U843 ( .A(n839), .X(n2301) );
  sky130_fd_sc_hd__buf_4 U844 ( .A(n848), .X(n2350) );
  sky130_fd_sc_hd__buf_4 U845 ( .A(n848), .X(n2352) );
  sky130_fd_sc_hd__buf_2 U846 ( .A(n848), .X(n2345) );
  sky130_fd_sc_hd__buf_2 U847 ( .A(n841), .X(n2319) );
  sky130_fd_sc_hd__buf_2 U848 ( .A(n851), .X(n2378) );
  sky130_fd_sc_hd__buf_2 U849 ( .A(n840), .X(n2310) );
  sky130_fd_sc_hd__buf_2 U850 ( .A(n850), .X(n2369) );
  sky130_fd_sc_hd__inv_2 U851 ( .A(n2274), .Y(n2270) );
  sky130_fd_sc_hd__inv_2 U852 ( .A(n2257), .Y(n2249) );
  sky130_fd_sc_hd__inv_2 U853 ( .A(n2279), .Y(n515) );
  sky130_fd_sc_hd__inv_1 U854 ( .A(n2279), .Y(n516) );
  sky130_fd_sc_hd__inv_2 U855 ( .A(n515), .Y(n520) );
  sky130_fd_sc_hd__inv_2 U856 ( .A(n515), .Y(n523) );
  sky130_fd_sc_hd__inv_2 U857 ( .A(n520), .Y(n524) );
  sky130_fd_sc_hd__inv_2 U858 ( .A(n520), .Y(n525) );
  sky130_fd_sc_hd__inv_2 U859 ( .A(n521), .Y(n526) );
  sky130_fd_sc_hd__inv_2 U860 ( .A(n522), .Y(n527) );
  sky130_fd_sc_hd__inv_2 U861 ( .A(n522), .Y(n528) );
  sky130_fd_sc_hd__inv_2 U862 ( .A(n523), .Y(n529) );
  sky130_fd_sc_hd__inv_2 U863 ( .A(n523), .Y(n530) );
  sky130_fd_sc_hd__buf_2 U864 ( .A(n851), .X(n2383) );
  sky130_fd_sc_hd__a22oi_1 U865 ( .A1(oam[1728]), .A2(n619), .B1(oam[1736]), 
        .B2(n43), .Y(n979) );
  sky130_fd_sc_hd__inv_2 U866 ( .A(n2253), .Y(n531) );
  sky130_fd_sc_hd__inv_1 U867 ( .A(n2253), .Y(n532) );
  sky130_fd_sc_hd__buf_6 U868 ( .A(n532), .X(n534) );
  sky130_fd_sc_hd__inv_2 U869 ( .A(n531), .Y(n536) );
  sky130_fd_sc_hd__inv_2 U870 ( .A(n531), .Y(n539) );
  sky130_fd_sc_hd__inv_2 U871 ( .A(n536), .Y(n540) );
  sky130_fd_sc_hd__inv_2 U872 ( .A(n536), .Y(n541) );
  sky130_fd_sc_hd__inv_2 U873 ( .A(n537), .Y(n542) );
  sky130_fd_sc_hd__inv_2 U874 ( .A(n538), .Y(n543) );
  sky130_fd_sc_hd__inv_2 U875 ( .A(n539), .Y(n544) );
  sky130_fd_sc_hd__inv_2 U876 ( .A(n539), .Y(n545) );
  sky130_fd_sc_hd__buf_2 U877 ( .A(n849), .X(n2359) );
  sky130_fd_sc_hd__buf_2 U878 ( .A(n840), .X(n2309) );
  sky130_fd_sc_hd__buf_2 U879 ( .A(n841), .X(n2321) );
  sky130_fd_sc_hd__inv_2 U880 ( .A(n2273), .Y(n546) );
  sky130_fd_sc_hd__buf_2 U881 ( .A(n547), .X(n548) );
  sky130_fd_sc_hd__buf_2 U882 ( .A(n547), .X(n549) );
  sky130_fd_sc_hd__buf_2 U883 ( .A(n547), .X(n550) );
  sky130_fd_sc_hd__buf_2 U884 ( .A(n547), .X(n551) );
  sky130_fd_sc_hd__inv_2 U885 ( .A(n546), .Y(n552) );
  sky130_fd_sc_hd__inv_2 U886 ( .A(n546), .Y(n553) );
  sky130_fd_sc_hd__inv_2 U887 ( .A(n546), .Y(n554) );
  sky130_fd_sc_hd__inv_2 U888 ( .A(n546), .Y(n555) );
  sky130_fd_sc_hd__inv_2 U889 ( .A(n552), .Y(n556) );
  sky130_fd_sc_hd__inv_2 U890 ( .A(n552), .Y(n557) );
  sky130_fd_sc_hd__inv_2 U891 ( .A(n553), .Y(n558) );
  sky130_fd_sc_hd__inv_2 U892 ( .A(n553), .Y(n559) );
  sky130_fd_sc_hd__inv_2 U893 ( .A(n554), .Y(n560) );
  sky130_fd_sc_hd__inv_2 U894 ( .A(n554), .Y(n561) );
  sky130_fd_sc_hd__inv_2 U895 ( .A(n555), .Y(n562) );
  sky130_fd_sc_hd__inv_2 U896 ( .A(n555), .Y(n563) );
  sky130_fd_sc_hd__inv_2 U897 ( .A(n2275), .Y(n564) );
  sky130_fd_sc_hd__inv_1 U898 ( .A(n2275), .Y(n565) );
  sky130_fd_sc_hd__buf_6 U899 ( .A(n565), .X(n566) );
  sky130_fd_sc_hd__buf_6 U900 ( .A(n565), .X(n567) );
  sky130_fd_sc_hd__inv_2 U901 ( .A(n564), .Y(n569) );
  sky130_fd_sc_hd__inv_2 U902 ( .A(n571), .Y(n575) );
  sky130_fd_sc_hd__inv_2 U903 ( .A(n571), .Y(n576) );
  sky130_fd_sc_hd__inv_2 U904 ( .A(n571), .Y(n577) );
  sky130_fd_sc_hd__buf_2 U905 ( .A(n839), .X(n2302) );
  sky130_fd_sc_hd__buf_2 U906 ( .A(n4), .X(n2311) );
  sky130_fd_sc_hd__buf_2 U907 ( .A(n430), .X(n2353) );
  sky130_fd_sc_hd__or2_2 U908 ( .A(n278), .B(reset_line), .X(n578) );
  sky130_fd_sc_hd__nand2_1 U909 ( .A(n2757), .B(n578), .Y(n2764) );
  sky130_fd_sc_hd__nor3_1 U910 ( .A(spr_y_coord[4]), .B(spr_y_coord[6]), .C(
        spr_y_coord[5]), .Y(n2486) );
  sky130_fd_sc_hd__buf_2 U911 ( .A(n430), .X(n2354) );
  sky130_fd_sc_hd__a22oi_2 U912 ( .A1(oam[1264]), .A2(n481), .B1(oam[1272]), 
        .B2(n2333), .Y(n986) );
  sky130_fd_sc_hd__inv_2 U913 ( .A(n2259), .Y(n841) );
  sky130_fd_sc_hd__inv_1 U914 ( .A(n427), .Y(n2765) );
  sky130_fd_sc_hd__and4_1 U915 ( .A(n1146), .B(n1147), .C(n1148), .D(n1149), 
        .X(n579) );
  sky130_fd_sc_hd__and4_1 U916 ( .A(n1103), .B(n1102), .C(n1104), .D(n1105), 
        .X(n580) );
  sky130_fd_sc_hd__and4_1 U917 ( .A(n1058), .B(n1059), .C(n1060), .D(n1061), 
        .X(n581) );
  sky130_fd_sc_hd__and4_1 U918 ( .A(n1014), .B(n1015), .C(n1016), .D(n1017), 
        .X(n582) );
  sky130_fd_sc_hd__inv_2 U919 ( .A(N34), .Y(n2258) );
  sky130_fd_sc_hd__inv_1 U920 ( .A(n2251), .Y(n584) );
  sky130_fd_sc_hd__inv_1 U921 ( .A(n2251), .Y(n585) );
  sky130_fd_sc_hd__clkbuf_1 U922 ( .A(n441), .X(n586) );
  sky130_fd_sc_hd__clkbuf_1 U923 ( .A(n584), .X(n587) );
  sky130_fd_sc_hd__clkbuf_1 U924 ( .A(n585), .X(n588) );
  sky130_fd_sc_hd__clkbuf_1 U925 ( .A(n585), .X(n589) );
  sky130_fd_sc_hd__clkbuf_1 U926 ( .A(n585), .X(n590) );
  sky130_fd_sc_hd__clkbuf_1 U927 ( .A(n441), .X(n591) );
  sky130_fd_sc_hd__inv_2 U928 ( .A(n584), .Y(n592) );
  sky130_fd_sc_hd__inv_2 U929 ( .A(n441), .Y(n593) );
  sky130_fd_sc_hd__inv_2 U930 ( .A(n583), .Y(n595) );
  sky130_fd_sc_hd__inv_2 U931 ( .A(n583), .Y(n597) );
  sky130_fd_sc_hd__inv_1 U932 ( .A(n593), .Y(n601) );
  sky130_fd_sc_hd__inv_1 U933 ( .A(n593), .Y(n602) );
  sky130_fd_sc_hd__inv_1 U934 ( .A(n593), .Y(n603) );
  sky130_fd_sc_hd__inv_1 U935 ( .A(n593), .Y(n604) );
  sky130_fd_sc_hd__inv_1 U936 ( .A(n594), .Y(n606) );
  sky130_fd_sc_hd__inv_1 U937 ( .A(n594), .Y(n607) );
  sky130_fd_sc_hd__inv_1 U938 ( .A(n595), .Y(n608) );
  sky130_fd_sc_hd__inv_1 U939 ( .A(n595), .Y(n610) );
  sky130_fd_sc_hd__inv_1 U940 ( .A(n595), .Y(n611) );
  sky130_fd_sc_hd__inv_1 U941 ( .A(n596), .Y(n612) );
  sky130_fd_sc_hd__inv_1 U942 ( .A(n596), .Y(n613) );
  sky130_fd_sc_hd__inv_1 U943 ( .A(n597), .Y(n617) );
  sky130_fd_sc_hd__inv_1 U944 ( .A(n597), .Y(n618) );
  sky130_fd_sc_hd__inv_1 U945 ( .A(n597), .Y(n619) );
  sky130_fd_sc_hd__inv_1 U946 ( .A(n597), .Y(n620) );
  sky130_fd_sc_hd__nand2_1 U947 ( .A(n2250), .B(n2276), .Y(n2275) );
  sky130_fd_sc_hd__inv_2 U948 ( .A(n2277), .Y(n2250) );
  sky130_fd_sc_hd__inv_2 U949 ( .A(n2280), .Y(n2252) );
  sky130_fd_sc_hd__inv_2 U950 ( .A(n2282), .Y(n2254) );
  sky130_fd_sc_hd__inv_2 U951 ( .A(n2272), .Y(n849) );
  sky130_fd_sc_hd__inv_2 U952 ( .A(n2263), .Y(n2260) );
  sky130_fd_sc_hd__buf_6 U953 ( .A(n841), .X(n2323) );
  sky130_fd_sc_hd__buf_2 U954 ( .A(n4), .X(n2314) );
  sky130_fd_sc_hd__nand2_1 U955 ( .A(spr_y_coord[3]), .B(n622), .Y(n2751) );
  sky130_fd_sc_hd__nand2_1 U956 ( .A(n2766), .B(n2752), .Y(n623) );
  sky130_fd_sc_hd__inv_2 U957 ( .A(reset_line), .Y(n2766) );
  sky130_fd_sc_hd__inv_2 U958 ( .A(n2286), .Y(n2276) );
  sky130_fd_sc_hd__inv_2 U959 ( .A(n2285), .Y(n2256) );
  sky130_fd_sc_hd__conb_1 U960 ( .LO(n5) );
  sky130_fd_sc_hd__o21ai_1 U961 ( .A1(n832), .A2(n833), .B1(n103), .Y(n831) );
  sky130_fd_sc_hd__nand4_1 U962 ( .A(n834), .B(n835), .C(n836), .D(n837), .Y(
        n833) );
  sky130_fd_sc_hd__a22oi_1 U963 ( .A1(oam[1856]), .A2(n618), .B1(oam[1864]), 
        .B2(n49), .Y(n837) );
  sky130_fd_sc_hd__a22oi_1 U964 ( .A1(oam[1872]), .A2(n2299), .B1(oam[1880]), 
        .B2(n534), .Y(n836) );
  sky130_fd_sc_hd__a22oi_1 U965 ( .A1(oam[1904]), .A2(n490), .B1(oam[1912]), 
        .B2(n2334), .Y(n834) );
  sky130_fd_sc_hd__nand4_1 U966 ( .A(n843), .B(n844), .C(n845), .D(n846), .Y(
        n832) );
  sky130_fd_sc_hd__a22oi_1 U967 ( .A1(oam[1792]), .A2(n2336), .B1(oam[1800]), 
        .B2(n2352), .Y(n846) );
  sky130_fd_sc_hd__a22oi_1 U968 ( .A1(oam[1808]), .A2(n551), .B1(oam[1816]), 
        .B2(n2364), .Y(n845) );
  sky130_fd_sc_hd__o21ai_1 U969 ( .A1(n852), .A2(n853), .B1(n228), .Y(n830) );
  sky130_fd_sc_hd__nand4_1 U970 ( .A(n854), .B(n855), .C(n856), .D(n857), .Y(
        n853) );
  sky130_fd_sc_hd__a22oi_1 U971 ( .A1(oam[1344]), .A2(n599), .B1(oam[1352]), 
        .B2(n19), .Y(n857) );
  sky130_fd_sc_hd__a22oi_1 U972 ( .A1(oam[1376]), .A2(n2313), .B1(oam[1384]), 
        .B2(n2316), .Y(n855) );
  sky130_fd_sc_hd__a22oi_1 U973 ( .A1(oam[1392]), .A2(n480), .B1(oam[1400]), 
        .B2(n2334), .Y(n854) );
  sky130_fd_sc_hd__nand4_1 U974 ( .A(n858), .B(n859), .C(n860), .D(n861), .Y(
        n852) );
  sky130_fd_sc_hd__a22oi_1 U975 ( .A1(oam[1280]), .A2(n2340), .B1(oam[1288]), 
        .B2(n2349), .Y(n861) );
  sky130_fd_sc_hd__a22oi_1 U976 ( .A1(oam[1296]), .A2(n556), .B1(oam[1304]), 
        .B2(n2364), .Y(n860) );
  sky130_fd_sc_hd__a22oi_1 U977 ( .A1(oam[1312]), .A2(n519), .B1(oam[1320]), 
        .B2(n575), .Y(n859) );
  sky130_fd_sc_hd__a22oi_1 U978 ( .A1(oam[1328]), .A2(n2372), .B1(oam[1336]), 
        .B2(n2376), .Y(n858) );
  sky130_fd_sc_hd__o21ai_1 U979 ( .A1(n862), .A2(n863), .B1(n227), .Y(n829) );
  sky130_fd_sc_hd__nand4_1 U980 ( .A(n864), .B(n865), .C(n866), .D(n867), .Y(
        n863) );
  sky130_fd_sc_hd__a22oi_1 U981 ( .A1(oam[832]), .A2(n591), .B1(oam[840]), 
        .B2(n26), .Y(n867) );
  sky130_fd_sc_hd__a22oi_1 U982 ( .A1(oam[848]), .A2(n2301), .B1(oam[856]), 
        .B2(n540), .Y(n866) );
  sky130_fd_sc_hd__a22oi_1 U983 ( .A1(oam[864]), .A2(n2306), .B1(oam[872]), 
        .B2(n2321), .Y(n865) );
  sky130_fd_sc_hd__a22oi_1 U984 ( .A1(oam[880]), .A2(n481), .B1(oam[888]), 
        .B2(n2334), .Y(n864) );
  sky130_fd_sc_hd__nand4_1 U985 ( .A(n868), .B(n869), .C(n870), .D(n871), .Y(
        n862) );
  sky130_fd_sc_hd__a22oi_1 U986 ( .A1(oam[768]), .A2(n2339), .B1(oam[776]), 
        .B2(n2345), .Y(n871) );
  sky130_fd_sc_hd__a22oi_1 U987 ( .A1(oam[784]), .A2(n557), .B1(oam[792]), 
        .B2(n2364), .Y(n870) );
  sky130_fd_sc_hd__a22oi_1 U988 ( .A1(oam[800]), .A2(n517), .B1(oam[808]), 
        .B2(n572), .Y(n869) );
  sky130_fd_sc_hd__a22oi_1 U989 ( .A1(oam[816]), .A2(n2369), .B1(oam[824]), 
        .B2(n2374), .Y(n868) );
  sky130_fd_sc_hd__o21ai_1 U990 ( .A1(n872), .A2(n873), .B1(n229), .Y(n624) );
  sky130_fd_sc_hd__nand4_1 U991 ( .A(n874), .B(n875), .C(n876), .D(n877), .Y(
        n873) );
  sky130_fd_sc_hd__a22oi_1 U992 ( .A1(oam[320]), .A2(n600), .B1(oam[328]), 
        .B2(n47), .Y(n877) );
  sky130_fd_sc_hd__a22oi_1 U993 ( .A1(oam[336]), .A2(n2300), .B1(oam[344]), 
        .B2(n544), .Y(n876) );
  sky130_fd_sc_hd__a22oi_1 U994 ( .A1(oam[352]), .A2(n2312), .B1(oam[360]), 
        .B2(n2321), .Y(n875) );
  sky130_fd_sc_hd__a22oi_1 U995 ( .A1(oam[368]), .A2(n482), .B1(oam[376]), 
        .B2(n2334), .Y(n874) );
  sky130_fd_sc_hd__nand4_1 U996 ( .A(n878), .B(n879), .C(n880), .D(n881), .Y(
        n872) );
  sky130_fd_sc_hd__a22oi_1 U997 ( .A1(oam[256]), .A2(n2337), .B1(oam[264]), 
        .B2(n2351), .Y(n881) );
  sky130_fd_sc_hd__a22oi_1 U998 ( .A1(oam[272]), .A2(n562), .B1(oam[280]), 
        .B2(n2364), .Y(n880) );
  sky130_fd_sc_hd__a22oi_1 U999 ( .A1(oam[288]), .A2(n527), .B1(oam[296]), 
        .B2(n567), .Y(n879) );
  sky130_fd_sc_hd__a22oi_1 U1000 ( .A1(oam[304]), .A2(n439), .B1(oam[312]), 
        .B2(n2375), .Y(n878) );
  sky130_fd_sc_hd__o21ai_1 U1001 ( .A1(n886), .A2(n887), .B1(n219), .Y(n885)
         );
  sky130_fd_sc_hd__nand4_1 U1002 ( .A(n888), .B(n889), .C(n890), .D(n891), .Y(
        n887) );
  sky130_fd_sc_hd__a22oi_1 U1003 ( .A1(oam[2000]), .A2(n2296), .B1(oam[2008]), 
        .B2(n543), .Y(n890) );
  sky130_fd_sc_hd__a22oi_1 U1004 ( .A1(oam[2016]), .A2(n2313), .B1(oam[2024]), 
        .B2(n2322), .Y(n889) );
  sky130_fd_sc_hd__a22oi_1 U1005 ( .A1(oam[2032]), .A2(n479), .B1(oam[2040]), 
        .B2(n2334), .Y(n888) );
  sky130_fd_sc_hd__nand4_1 U1006 ( .A(n892), .B(n893), .C(n894), .D(n895), .Y(
        n886) );
  sky130_fd_sc_hd__a22oi_1 U1007 ( .A1(oam[1920]), .A2(n2335), .B1(oam[1928]), 
        .B2(n2353), .Y(n895) );
  sky130_fd_sc_hd__a22oi_1 U1008 ( .A1(oam[1936]), .A2(n562), .B1(oam[1944]), 
        .B2(n2364), .Y(n894) );
  sky130_fd_sc_hd__a22oi_1 U1009 ( .A1(oam[1952]), .A2(n530), .B1(oam[1960]), 
        .B2(n572), .Y(n893) );
  sky130_fd_sc_hd__a22oi_1 U1010 ( .A1(oam[1968]), .A2(n2367), .B1(oam[1976]), 
        .B2(n2377), .Y(n892) );
  sky130_fd_sc_hd__o21ai_1 U1011 ( .A1(n896), .A2(n897), .B1(n221), .Y(n884)
         );
  sky130_fd_sc_hd__nand4_1 U1012 ( .A(n898), .B(n899), .C(n900), .D(n901), .Y(
        n897) );
  sky130_fd_sc_hd__a22oi_1 U1013 ( .A1(oam[1472]), .A2(n615), .B1(oam[1480]), 
        .B2(n39), .Y(n901) );
  sky130_fd_sc_hd__a22oi_1 U1014 ( .A1(oam[1488]), .A2(n2296), .B1(oam[1496]), 
        .B2(n533), .Y(n900) );
  sky130_fd_sc_hd__a22oi_1 U1015 ( .A1(oam[1504]), .A2(n2307), .B1(oam[1512]), 
        .B2(n2317), .Y(n899) );
  sky130_fd_sc_hd__a22oi_1 U1016 ( .A1(oam[1520]), .A2(n481), .B1(oam[1528]), 
        .B2(n2334), .Y(n898) );
  sky130_fd_sc_hd__nand4_1 U1017 ( .A(n902), .B(n903), .C(n904), .D(n905), .Y(
        n896) );
  sky130_fd_sc_hd__a22oi_1 U1018 ( .A1(oam[1408]), .A2(n2344), .B1(oam[1416]), 
        .B2(n2351), .Y(n905) );
  sky130_fd_sc_hd__a22oi_1 U1019 ( .A1(oam[1424]), .A2(n557), .B1(oam[1432]), 
        .B2(n2364), .Y(n904) );
  sky130_fd_sc_hd__a22oi_1 U1020 ( .A1(oam[1440]), .A2(n527), .B1(oam[1448]), 
        .B2(n576), .Y(n903) );
  sky130_fd_sc_hd__a22oi_1 U1021 ( .A1(oam[1456]), .A2(n2367), .B1(oam[1464]), 
        .B2(n2381), .Y(n902) );
  sky130_fd_sc_hd__o21ai_1 U1022 ( .A1(n906), .A2(n907), .B1(n223), .Y(n883)
         );
  sky130_fd_sc_hd__nand4_1 U1023 ( .A(n908), .B(n909), .C(n910), .D(n911), .Y(
        n907) );
  sky130_fd_sc_hd__a22oi_1 U1024 ( .A1(oam[960]), .A2(n599), .B1(oam[968]), 
        .B2(n44), .Y(n911) );
  sky130_fd_sc_hd__a22oi_1 U1025 ( .A1(oam[976]), .A2(n2302), .B1(oam[984]), 
        .B2(n542), .Y(n910) );
  sky130_fd_sc_hd__a22oi_1 U1026 ( .A1(oam[992]), .A2(n2312), .B1(oam[1000]), 
        .B2(n445), .Y(n909) );
  sky130_fd_sc_hd__a22oi_1 U1027 ( .A1(oam[1008]), .A2(n488), .B1(oam[1016]), 
        .B2(n2334), .Y(n908) );
  sky130_fd_sc_hd__nand4_1 U1028 ( .A(n912), .B(n913), .C(n914), .D(n915), .Y(
        n906) );
  sky130_fd_sc_hd__a22oi_1 U1029 ( .A1(oam[896]), .A2(n2341), .B1(oam[904]), 
        .B2(n2348), .Y(n915) );
  sky130_fd_sc_hd__a22oi_1 U1030 ( .A1(oam[912]), .A2(n548), .B1(oam[920]), 
        .B2(n2364), .Y(n914) );
  sky130_fd_sc_hd__a22oi_1 U1031 ( .A1(oam[928]), .A2(n525), .B1(oam[936]), 
        .B2(n577), .Y(n913) );
  sky130_fd_sc_hd__a22oi_1 U1032 ( .A1(oam[944]), .A2(n439), .B1(oam[952]), 
        .B2(n2375), .Y(n912) );
  sky130_fd_sc_hd__o21ai_1 U1033 ( .A1(n916), .A2(n917), .B1(n224), .Y(n882)
         );
  sky130_fd_sc_hd__nand4_1 U1034 ( .A(n918), .B(n919), .C(n920), .D(n921), .Y(
        n917) );
  sky130_fd_sc_hd__a22oi_1 U1035 ( .A1(oam[448]), .A2(n599), .B1(oam[456]), 
        .B2(n18), .Y(n921) );
  sky130_fd_sc_hd__a22oi_1 U1036 ( .A1(oam[464]), .A2(n2299), .B1(oam[472]), 
        .B2(n533), .Y(n920) );
  sky130_fd_sc_hd__a22oi_1 U1037 ( .A1(oam[480]), .A2(n2307), .B1(oam[488]), 
        .B2(n2320), .Y(n919) );
  sky130_fd_sc_hd__a22oi_1 U1038 ( .A1(oam[496]), .A2(n482), .B1(oam[504]), 
        .B2(n2334), .Y(n918) );
  sky130_fd_sc_hd__nand4_1 U1039 ( .A(n922), .B(n923), .C(n924), .D(n925), .Y(
        n916) );
  sky130_fd_sc_hd__a22oi_1 U1040 ( .A1(oam[384]), .A2(n2344), .B1(oam[392]), 
        .B2(n2346), .Y(n925) );
  sky130_fd_sc_hd__a22oi_1 U1041 ( .A1(oam[400]), .A2(n558), .B1(oam[408]), 
        .B2(n2364), .Y(n924) );
  sky130_fd_sc_hd__a22oi_1 U1042 ( .A1(oam[416]), .A2(n528), .B1(oam[424]), 
        .B2(n576), .Y(n923) );
  sky130_fd_sc_hd__a22oi_1 U1043 ( .A1(oam[432]), .A2(n2367), .B1(oam[440]), 
        .B2(n2383), .Y(n922) );
  sky130_fd_sc_hd__o21ai_1 U1044 ( .A1(n930), .A2(n931), .B1(n128), .Y(n929)
         );
  sky130_fd_sc_hd__nand4_1 U1045 ( .A(n932), .B(n933), .C(n934), .D(n935), .Y(
        n931) );
  sky130_fd_sc_hd__a22oi_1 U1046 ( .A1(oam[1600]), .A2(n589), .B1(oam[1608]), 
        .B2(n24), .Y(n935) );
  sky130_fd_sc_hd__a22oi_1 U1047 ( .A1(oam[1616]), .A2(n2299), .B1(oam[1624]), 
        .B2(n542), .Y(n934) );
  sky130_fd_sc_hd__a22oi_1 U1048 ( .A1(oam[1632]), .A2(n472), .B1(oam[1640]), 
        .B2(n2317), .Y(n933) );
  sky130_fd_sc_hd__a22oi_1 U1049 ( .A1(oam[1648]), .A2(n480), .B1(oam[1656]), 
        .B2(n2334), .Y(n932) );
  sky130_fd_sc_hd__nand4_1 U1050 ( .A(n936), .B(n937), .C(n938), .D(n939), .Y(
        n930) );
  sky130_fd_sc_hd__a22oi_1 U1051 ( .A1(oam[1536]), .A2(n2342), .B1(oam[1544]), 
        .B2(n2350), .Y(n939) );
  sky130_fd_sc_hd__a22oi_1 U1052 ( .A1(oam[1552]), .A2(n563), .B1(oam[1560]), 
        .B2(n2364), .Y(n938) );
  sky130_fd_sc_hd__a22oi_1 U1053 ( .A1(oam[1568]), .A2(n529), .B1(oam[1576]), 
        .B2(n577), .Y(n937) );
  sky130_fd_sc_hd__a22oi_1 U1054 ( .A1(oam[1584]), .A2(n2372), .B1(oam[1592]), 
        .B2(n2379), .Y(n936) );
  sky130_fd_sc_hd__o21ai_1 U1055 ( .A1(n940), .A2(n941), .B1(n130), .Y(n928)
         );
  sky130_fd_sc_hd__nand4_1 U1056 ( .A(n942), .B(n943), .C(n944), .D(n945), .Y(
        n941) );
  sky130_fd_sc_hd__a22oi_1 U1057 ( .A1(oam[1088]), .A2(n591), .B1(oam[1096]), 
        .B2(n27), .Y(n945) );
  sky130_fd_sc_hd__a22oi_1 U1058 ( .A1(oam[1104]), .A2(n2296), .B1(oam[1112]), 
        .B2(n534), .Y(n944) );
  sky130_fd_sc_hd__a22oi_1 U1059 ( .A1(oam[1120]), .A2(n2310), .B1(oam[1128]), 
        .B2(n2320), .Y(n943) );
  sky130_fd_sc_hd__a22oi_1 U1060 ( .A1(oam[1136]), .A2(n488), .B1(oam[1144]), 
        .B2(n2334), .Y(n942) );
  sky130_fd_sc_hd__nand4_1 U1061 ( .A(n946), .B(n947), .C(n948), .D(n949), .Y(
        n940) );
  sky130_fd_sc_hd__a22oi_1 U1062 ( .A1(oam[1024]), .A2(n2338), .B1(oam[1032]), 
        .B2(n2349), .Y(n949) );
  sky130_fd_sc_hd__a22oi_1 U1063 ( .A1(oam[1040]), .A2(n550), .B1(oam[1048]), 
        .B2(n2364), .Y(n948) );
  sky130_fd_sc_hd__a22oi_1 U1064 ( .A1(oam[1056]), .A2(n519), .B1(oam[1064]), 
        .B2(n567), .Y(n947) );
  sky130_fd_sc_hd__a22oi_1 U1065 ( .A1(oam[1072]), .A2(n2365), .B1(oam[1080]), 
        .B2(n2376), .Y(n946) );
  sky130_fd_sc_hd__o21ai_1 U1066 ( .A1(n950), .A2(n951), .B1(n129), .Y(n927)
         );
  sky130_fd_sc_hd__nand4_1 U1067 ( .A(n952), .B(n953), .C(n954), .D(n955), .Y(
        n951) );
  sky130_fd_sc_hd__a22oi_1 U1068 ( .A1(oam[576]), .A2(n600), .B1(oam[584]), 
        .B2(n35), .Y(n955) );
  sky130_fd_sc_hd__a22oi_1 U1069 ( .A1(oam[592]), .A2(n2305), .B1(oam[600]), 
        .B2(n535), .Y(n954) );
  sky130_fd_sc_hd__a22oi_1 U1070 ( .A1(oam[608]), .A2(n2313), .B1(oam[616]), 
        .B2(n2315), .Y(n953) );
  sky130_fd_sc_hd__a22oi_1 U1071 ( .A1(oam[624]), .A2(n478), .B1(oam[632]), 
        .B2(n2334), .Y(n952) );
  sky130_fd_sc_hd__nand4_1 U1072 ( .A(n956), .B(n957), .C(n958), .D(n959), .Y(
        n950) );
  sky130_fd_sc_hd__a22oi_1 U1073 ( .A1(oam[512]), .A2(n2340), .B1(oam[520]), 
        .B2(n2347), .Y(n959) );
  sky130_fd_sc_hd__a22oi_1 U1074 ( .A1(oam[528]), .A2(n563), .B1(oam[536]), 
        .B2(n2364), .Y(n958) );
  sky130_fd_sc_hd__a22oi_1 U1075 ( .A1(oam[544]), .A2(n528), .B1(oam[552]), 
        .B2(n572), .Y(n957) );
  sky130_fd_sc_hd__a22oi_1 U1076 ( .A1(oam[560]), .A2(n2369), .B1(oam[568]), 
        .B2(n2382), .Y(n956) );
  sky130_fd_sc_hd__o21ai_1 U1077 ( .A1(n960), .A2(n961), .B1(n231), .Y(n926)
         );
  sky130_fd_sc_hd__nand4_1 U1078 ( .A(n962), .B(n963), .C(n964), .D(n965), .Y(
        n961) );
  sky130_fd_sc_hd__a22oi_1 U1079 ( .A1(oam[64]), .A2(n610), .B1(oam[72]), .B2(
        n48), .Y(n965) );
  sky130_fd_sc_hd__a22oi_1 U1080 ( .A1(oam[80]), .A2(n2303), .B1(oam[88]), 
        .B2(n543), .Y(n964) );
  sky130_fd_sc_hd__a22oi_1 U1081 ( .A1(oam[96]), .A2(n2313), .B1(oam[104]), 
        .B2(n2324), .Y(n963) );
  sky130_fd_sc_hd__a22oi_1 U1082 ( .A1(oam[112]), .A2(n488), .B1(oam[120]), 
        .B2(n2334), .Y(n962) );
  sky130_fd_sc_hd__nand4_1 U1083 ( .A(n966), .B(n967), .C(n968), .D(n969), .Y(
        n960) );
  sky130_fd_sc_hd__a22oi_1 U1084 ( .A1(oam[0]), .A2(n2338), .B1(oam[8]), .B2(
        n2348), .Y(n969) );
  sky130_fd_sc_hd__a22oi_1 U1085 ( .A1(oam[16]), .A2(n561), .B1(oam[24]), .B2(
        n2364), .Y(n968) );
  sky130_fd_sc_hd__a22oi_1 U1086 ( .A1(oam[32]), .A2(n517), .B1(oam[40]), .B2(
        n566), .Y(n967) );
  sky130_fd_sc_hd__a22oi_1 U1087 ( .A1(oam[48]), .A2(n2367), .B1(oam[56]), 
        .B2(n2376), .Y(n966) );
  sky130_fd_sc_hd__o21ai_1 U1088 ( .A1(n974), .A2(n975), .B1(n127), .Y(n973)
         );
  sky130_fd_sc_hd__nand4_1 U1089 ( .A(n976), .B(n977), .C(n978), .D(n979), .Y(
        n975) );
  sky130_fd_sc_hd__a22oi_1 U1090 ( .A1(oam[1744]), .A2(n2304), .B1(oam[1752]), 
        .B2(n533), .Y(n978) );
  sky130_fd_sc_hd__a22oi_1 U1091 ( .A1(oam[1760]), .A2(n2307), .B1(oam[1768]), 
        .B2(n2320), .Y(n977) );
  sky130_fd_sc_hd__a22oi_1 U1092 ( .A1(oam[1776]), .A2(n487), .B1(oam[1784]), 
        .B2(n2334), .Y(n976) );
  sky130_fd_sc_hd__nand4_1 U1093 ( .A(n981), .B(n980), .C(n982), .D(n983), .Y(
        n974) );
  sky130_fd_sc_hd__a22oi_1 U1094 ( .A1(oam[1664]), .A2(n2341), .B1(oam[1672]), 
        .B2(n2349), .Y(n983) );
  sky130_fd_sc_hd__a22oi_1 U1095 ( .A1(oam[1680]), .A2(n549), .B1(oam[1688]), 
        .B2(n2364), .Y(n982) );
  sky130_fd_sc_hd__a22oi_1 U1096 ( .A1(oam[1696]), .A2(n524), .B1(oam[1704]), 
        .B2(n574), .Y(n981) );
  sky130_fd_sc_hd__a22oi_1 U1097 ( .A1(oam[1712]), .A2(n2366), .B1(oam[1720]), 
        .B2(n2380), .Y(n980) );
  sky130_fd_sc_hd__o21ai_1 U1098 ( .A1(n984), .A2(n985), .B1(n220), .Y(n972)
         );
  sky130_fd_sc_hd__nand4_1 U1099 ( .A(n989), .B(n987), .C(n988), .D(n986), .Y(
        n985) );
  sky130_fd_sc_hd__a22oi_1 U1100 ( .A1(oam[1216]), .A2(n588), .B1(oam[1224]), 
        .B2(n20), .Y(n989) );
  sky130_fd_sc_hd__a22oi_1 U1101 ( .A1(oam[1232]), .A2(n2297), .B1(oam[1240]), 
        .B2(n540), .Y(n988) );
  sky130_fd_sc_hd__a22oi_1 U1102 ( .A1(oam[1248]), .A2(n2314), .B1(oam[1256]), 
        .B2(n2316), .Y(n987) );
  sky130_fd_sc_hd__nand4_1 U1103 ( .A(n990), .B(n991), .C(n992), .D(n993), .Y(
        n984) );
  sky130_fd_sc_hd__a22oi_1 U1104 ( .A1(oam[1152]), .A2(n2336), .B1(oam[1160]), 
        .B2(n2354), .Y(n993) );
  sky130_fd_sc_hd__a22oi_1 U1105 ( .A1(oam[1168]), .A2(n550), .B1(oam[1176]), 
        .B2(n2363), .Y(n992) );
  sky130_fd_sc_hd__a22oi_1 U1106 ( .A1(oam[1184]), .A2(n526), .B1(oam[1192]), 
        .B2(n575), .Y(n991) );
  sky130_fd_sc_hd__a22oi_1 U1107 ( .A1(oam[1200]), .A2(n439), .B1(oam[1208]), 
        .B2(n2374), .Y(n990) );
  sky130_fd_sc_hd__o21ai_1 U1108 ( .A1(n994), .A2(n995), .B1(n222), .Y(n971)
         );
  sky130_fd_sc_hd__nand4_1 U1109 ( .A(n996), .B(n997), .C(n998), .D(n999), .Y(
        n995) );
  sky130_fd_sc_hd__a22oi_1 U1110 ( .A1(oam[704]), .A2(n617), .B1(oam[712]), 
        .B2(n97), .Y(n999) );
  sky130_fd_sc_hd__a22oi_1 U1111 ( .A1(oam[720]), .A2(n2300), .B1(oam[728]), 
        .B2(n541), .Y(n998) );
  sky130_fd_sc_hd__a22oi_1 U1112 ( .A1(oam[736]), .A2(n2311), .B1(oam[744]), 
        .B2(n2315), .Y(n997) );
  sky130_fd_sc_hd__a22oi_1 U1113 ( .A1(oam[752]), .A2(n486), .B1(oam[760]), 
        .B2(n2333), .Y(n996) );
  sky130_fd_sc_hd__nand4_1 U1114 ( .A(n1000), .B(n1001), .C(n1002), .D(n1003), 
        .Y(n994) );
  sky130_fd_sc_hd__a22oi_1 U1115 ( .A1(oam[640]), .A2(n2341), .B1(oam[648]), 
        .B2(n2352), .Y(n1003) );
  sky130_fd_sc_hd__a22oi_1 U1116 ( .A1(oam[656]), .A2(n557), .B1(oam[664]), 
        .B2(n2363), .Y(n1002) );
  sky130_fd_sc_hd__a22oi_1 U1117 ( .A1(oam[672]), .A2(n519), .B1(oam[680]), 
        .B2(n566), .Y(n1001) );
  sky130_fd_sc_hd__a22oi_1 U1118 ( .A1(oam[688]), .A2(n439), .B1(oam[696]), 
        .B2(n2381), .Y(n1000) );
  sky130_fd_sc_hd__o21ai_1 U1119 ( .A1(n1004), .A2(n1005), .B1(n226), .Y(n970)
         );
  sky130_fd_sc_hd__nand4_1 U1120 ( .A(n1006), .B(n1007), .C(n1008), .D(n1009), 
        .Y(n1005) );
  sky130_fd_sc_hd__a22oi_1 U1121 ( .A1(oam[192]), .A2(n587), .B1(oam[200]), 
        .B2(n25), .Y(n1009) );
  sky130_fd_sc_hd__a22oi_1 U1122 ( .A1(oam[208]), .A2(n2296), .B1(oam[216]), 
        .B2(n533), .Y(n1008) );
  sky130_fd_sc_hd__a22oi_1 U1123 ( .A1(oam[224]), .A2(n2311), .B1(oam[232]), 
        .B2(n2324), .Y(n1007) );
  sky130_fd_sc_hd__a22oi_1 U1124 ( .A1(oam[240]), .A2(n490), .B1(oam[248]), 
        .B2(n2333), .Y(n1006) );
  sky130_fd_sc_hd__nand4_1 U1125 ( .A(n1010), .B(n1011), .C(n1012), .D(n1013), 
        .Y(n1004) );
  sky130_fd_sc_hd__a22oi_1 U1126 ( .A1(oam[128]), .A2(n2336), .B1(oam[136]), 
        .B2(n2349), .Y(n1013) );
  sky130_fd_sc_hd__a22oi_1 U1127 ( .A1(oam[144]), .A2(n550), .B1(oam[152]), 
        .B2(n2363), .Y(n1012) );
  sky130_fd_sc_hd__a22oi_1 U1128 ( .A1(oam[160]), .A2(n527), .B1(oam[168]), 
        .B2(n567), .Y(n1011) );
  sky130_fd_sc_hd__a22oi_1 U1129 ( .A1(oam[176]), .A2(n2373), .B1(oam[184]), 
        .B2(n2378), .Y(n1010) );
  sky130_fd_sc_hd__o21ai_1 U1130 ( .A1(n1018), .A2(n1019), .B1(n103), .Y(n1017) );
  sky130_fd_sc_hd__nand4_1 U1131 ( .A(n1021), .B(n1020), .C(n1022), .D(n1023), 
        .Y(n1019) );
  sky130_fd_sc_hd__a22oi_1 U1132 ( .A1(oam[1873]), .A2(n2299), .B1(oam[1881]), 
        .B2(n544), .Y(n1022) );
  sky130_fd_sc_hd__a22oi_1 U1133 ( .A1(oam[1889]), .A2(n2306), .B1(oam[1897]), 
        .B2(n2323), .Y(n1021) );
  sky130_fd_sc_hd__nand4_1 U1134 ( .A(n1024), .B(n1025), .C(n1026), .D(n1027), 
        .Y(n1018) );
  sky130_fd_sc_hd__a22oi_1 U1135 ( .A1(oam[1793]), .A2(n2340), .B1(oam[1801]), 
        .B2(n2346), .Y(n1027) );
  sky130_fd_sc_hd__a22oi_1 U1136 ( .A1(oam[1809]), .A2(n556), .B1(oam[1817]), 
        .B2(n2363), .Y(n1026) );
  sky130_fd_sc_hd__a22oi_1 U1137 ( .A1(oam[1841]), .A2(n2366), .B1(oam[1849]), 
        .B2(n2382), .Y(n1024) );
  sky130_fd_sc_hd__o21ai_1 U1138 ( .A1(n1028), .A2(n1029), .B1(n228), .Y(n1016) );
  sky130_fd_sc_hd__nand4_1 U1139 ( .A(n1031), .B(n1030), .C(n1032), .D(n1033), 
        .Y(n1029) );
  sky130_fd_sc_hd__a22oi_1 U1140 ( .A1(oam[1345]), .A2(n589), .B1(oam[1353]), 
        .B2(n94), .Y(n1033) );
  sky130_fd_sc_hd__a22oi_1 U1141 ( .A1(oam[1361]), .A2(n2296), .B1(oam[1369]), 
        .B2(n535), .Y(n1032) );
  sky130_fd_sc_hd__a22oi_1 U1142 ( .A1(oam[1377]), .A2(n2308), .B1(oam[1385]), 
        .B2(n2318), .Y(n1031) );
  sky130_fd_sc_hd__nand4_1 U1143 ( .A(n1034), .B(n1035), .C(n1036), .D(n1037), 
        .Y(n1028) );
  sky130_fd_sc_hd__a22oi_1 U1144 ( .A1(oam[1281]), .A2(n2343), .B1(oam[1289]), 
        .B2(n2348), .Y(n1037) );
  sky130_fd_sc_hd__a22oi_1 U1145 ( .A1(oam[1297]), .A2(n558), .B1(oam[1305]), 
        .B2(n2363), .Y(n1036) );
  sky130_fd_sc_hd__a22oi_1 U1146 ( .A1(oam[1313]), .A2(n530), .B1(oam[1321]), 
        .B2(n566), .Y(n1035) );
  sky130_fd_sc_hd__a22oi_1 U1147 ( .A1(oam[1329]), .A2(n439), .B1(oam[1337]), 
        .B2(n2378), .Y(n1034) );
  sky130_fd_sc_hd__o21ai_1 U1148 ( .A1(n1038), .A2(n1039), .B1(n227), .Y(n1015) );
  sky130_fd_sc_hd__nand4_1 U1149 ( .A(n1040), .B(n1041), .C(n1042), .D(n1043), 
        .Y(n1039) );
  sky130_fd_sc_hd__a22oi_1 U1150 ( .A1(oam[833]), .A2(n599), .B1(oam[841]), 
        .B2(n15), .Y(n1043) );
  sky130_fd_sc_hd__a22oi_1 U1151 ( .A1(oam[849]), .A2(n2296), .B1(oam[857]), 
        .B2(n540), .Y(n1042) );
  sky130_fd_sc_hd__a22oi_1 U1152 ( .A1(oam[865]), .A2(n2308), .B1(oam[873]), 
        .B2(n2319), .Y(n1041) );
  sky130_fd_sc_hd__a22oi_1 U1153 ( .A1(oam[881]), .A2(n486), .B1(oam[889]), 
        .B2(n2333), .Y(n1040) );
  sky130_fd_sc_hd__nand4_1 U1154 ( .A(n1044), .B(n1045), .C(n1046), .D(n1047), 
        .Y(n1038) );
  sky130_fd_sc_hd__a22oi_1 U1155 ( .A1(oam[769]), .A2(n2340), .B1(oam[777]), 
        .B2(n2354), .Y(n1047) );
  sky130_fd_sc_hd__a22oi_1 U1156 ( .A1(oam[785]), .A2(n548), .B1(oam[793]), 
        .B2(n2363), .Y(n1046) );
  sky130_fd_sc_hd__a22oi_1 U1157 ( .A1(oam[801]), .A2(n525), .B1(oam[809]), 
        .B2(n567), .Y(n1045) );
  sky130_fd_sc_hd__a22oi_1 U1158 ( .A1(oam[817]), .A2(n2366), .B1(oam[825]), 
        .B2(n2376), .Y(n1044) );
  sky130_fd_sc_hd__o21ai_1 U1159 ( .A1(n1048), .A2(n1049), .B1(n229), .Y(n1014) );
  sky130_fd_sc_hd__nand4_1 U1160 ( .A(n1050), .B(n1051), .C(n1052), .D(n1053), 
        .Y(n1049) );
  sky130_fd_sc_hd__a22oi_1 U1161 ( .A1(oam[321]), .A2(n603), .B1(oam[329]), 
        .B2(n23), .Y(n1053) );
  sky130_fd_sc_hd__a22oi_1 U1162 ( .A1(oam[337]), .A2(n2299), .B1(oam[345]), 
        .B2(n535), .Y(n1052) );
  sky130_fd_sc_hd__a22oi_1 U1163 ( .A1(oam[353]), .A2(n472), .B1(oam[361]), 
        .B2(n2316), .Y(n1051) );
  sky130_fd_sc_hd__a22oi_1 U1164 ( .A1(oam[369]), .A2(n478), .B1(oam[377]), 
        .B2(n2333), .Y(n1050) );
  sky130_fd_sc_hd__nand4_1 U1165 ( .A(n1054), .B(n1055), .C(n1056), .D(n1057), 
        .Y(n1048) );
  sky130_fd_sc_hd__a22oi_1 U1166 ( .A1(oam[257]), .A2(n2340), .B1(oam[265]), 
        .B2(n2350), .Y(n1057) );
  sky130_fd_sc_hd__a22oi_1 U1167 ( .A1(oam[273]), .A2(n563), .B1(oam[281]), 
        .B2(n2363), .Y(n1056) );
  sky130_fd_sc_hd__a22oi_1 U1168 ( .A1(oam[289]), .A2(n529), .B1(oam[297]), 
        .B2(n567), .Y(n1055) );
  sky130_fd_sc_hd__a22oi_1 U1169 ( .A1(oam[305]), .A2(n2365), .B1(oam[313]), 
        .B2(n2376), .Y(n1054) );
  sky130_fd_sc_hd__o21ai_1 U1170 ( .A1(n1062), .A2(n1063), .B1(n219), .Y(n1061) );
  sky130_fd_sc_hd__nand4_1 U1171 ( .A(n1064), .B(n1065), .C(n1066), .D(n1067), 
        .Y(n1063) );
  sky130_fd_sc_hd__a22oi_1 U1172 ( .A1(oam[2001]), .A2(n2296), .B1(oam[2009]), 
        .B2(n540), .Y(n1066) );
  sky130_fd_sc_hd__a22oi_1 U1173 ( .A1(oam[2033]), .A2(n483), .B1(oam[2041]), 
        .B2(n2333), .Y(n1064) );
  sky130_fd_sc_hd__nand4_1 U1174 ( .A(n1068), .B(n1069), .C(n1070), .D(n1071), 
        .Y(n1062) );
  sky130_fd_sc_hd__a22oi_1 U1175 ( .A1(oam[1921]), .A2(n2341), .B1(oam[1929]), 
        .B2(n2345), .Y(n1071) );
  sky130_fd_sc_hd__a22oi_1 U1176 ( .A1(oam[1937]), .A2(n559), .B1(oam[1945]), 
        .B2(n2363), .Y(n1070) );
  sky130_fd_sc_hd__a22oi_1 U1177 ( .A1(oam[1953]), .A2(n529), .B1(oam[1961]), 
        .B2(n567), .Y(n1069) );
  sky130_fd_sc_hd__a22oi_1 U1178 ( .A1(oam[1969]), .A2(n2368), .B1(oam[1977]), 
        .B2(n2381), .Y(n1068) );
  sky130_fd_sc_hd__o21ai_1 U1179 ( .A1(n1072), .A2(n1073), .B1(n221), .Y(n1060) );
  sky130_fd_sc_hd__nand4_1 U1180 ( .A(n1074), .B(n1075), .C(n1076), .D(n1077), 
        .Y(n1073) );
  sky130_fd_sc_hd__a22oi_1 U1181 ( .A1(oam[1473]), .A2(n587), .B1(oam[1481]), 
        .B2(n96), .Y(n1077) );
  sky130_fd_sc_hd__a22oi_1 U1182 ( .A1(oam[1489]), .A2(n2296), .B1(oam[1497]), 
        .B2(n545), .Y(n1076) );
  sky130_fd_sc_hd__a22oi_1 U1183 ( .A1(oam[1505]), .A2(n2313), .B1(oam[1513]), 
        .B2(n2320), .Y(n1075) );
  sky130_fd_sc_hd__a22oi_1 U1184 ( .A1(oam[1521]), .A2(n488), .B1(oam[1529]), 
        .B2(n2333), .Y(n1074) );
  sky130_fd_sc_hd__nand4_1 U1185 ( .A(n1078), .B(n1079), .C(n1080), .D(n1081), 
        .Y(n1072) );
  sky130_fd_sc_hd__a22oi_1 U1186 ( .A1(oam[1409]), .A2(n2343), .B1(oam[1417]), 
        .B2(n2352), .Y(n1081) );
  sky130_fd_sc_hd__a22oi_1 U1187 ( .A1(oam[1425]), .A2(n549), .B1(oam[1433]), 
        .B2(n2363), .Y(n1080) );
  sky130_fd_sc_hd__a22oi_1 U1188 ( .A1(oam[1441]), .A2(n518), .B1(oam[1449]), 
        .B2(n566), .Y(n1079) );
  sky130_fd_sc_hd__a22oi_1 U1189 ( .A1(oam[1457]), .A2(n439), .B1(oam[1465]), 
        .B2(n2375), .Y(n1078) );
  sky130_fd_sc_hd__o21ai_1 U1190 ( .A1(n1082), .A2(n1083), .B1(n223), .Y(n1059) );
  sky130_fd_sc_hd__nand4_1 U1191 ( .A(n1084), .B(n1085), .C(n1086), .D(n1087), 
        .Y(n1083) );
  sky130_fd_sc_hd__a22oi_1 U1192 ( .A1(oam[961]), .A2(n600), .B1(oam[969]), 
        .B2(n16), .Y(n1087) );
  sky130_fd_sc_hd__a22oi_1 U1193 ( .A1(oam[977]), .A2(n2305), .B1(oam[985]), 
        .B2(n543), .Y(n1086) );
  sky130_fd_sc_hd__a22oi_1 U1194 ( .A1(oam[993]), .A2(n2311), .B1(oam[1001]), 
        .B2(n2323), .Y(n1085) );
  sky130_fd_sc_hd__a22oi_1 U1195 ( .A1(oam[1009]), .A2(n490), .B1(oam[1017]), 
        .B2(n2333), .Y(n1084) );
  sky130_fd_sc_hd__nand4_1 U1196 ( .A(n1088), .B(n1089), .C(n1090), .D(n1091), 
        .Y(n1082) );
  sky130_fd_sc_hd__a22oi_1 U1197 ( .A1(oam[897]), .A2(n2341), .B1(oam[905]), 
        .B2(n2346), .Y(n1091) );
  sky130_fd_sc_hd__a22oi_1 U1198 ( .A1(oam[913]), .A2(n558), .B1(oam[921]), 
        .B2(n2363), .Y(n1090) );
  sky130_fd_sc_hd__a22oi_1 U1199 ( .A1(oam[929]), .A2(n526), .B1(oam[937]), 
        .B2(n566), .Y(n1089) );
  sky130_fd_sc_hd__a22oi_1 U1200 ( .A1(oam[945]), .A2(n2371), .B1(oam[953]), 
        .B2(n2374), .Y(n1088) );
  sky130_fd_sc_hd__o21ai_1 U1201 ( .A1(n1092), .A2(n1093), .B1(n224), .Y(n1058) );
  sky130_fd_sc_hd__nand4_1 U1202 ( .A(n1094), .B(n1095), .C(n1096), .D(n1097), 
        .Y(n1093) );
  sky130_fd_sc_hd__a22oi_1 U1203 ( .A1(oam[449]), .A2(n606), .B1(oam[457]), 
        .B2(n28), .Y(n1097) );
  sky130_fd_sc_hd__a22oi_1 U1204 ( .A1(oam[465]), .A2(n2302), .B1(oam[473]), 
        .B2(n545), .Y(n1096) );
  sky130_fd_sc_hd__a22oi_1 U1205 ( .A1(oam[481]), .A2(n472), .B1(oam[489]), 
        .B2(n2315), .Y(n1095) );
  sky130_fd_sc_hd__a22oi_1 U1206 ( .A1(oam[497]), .A2(n478), .B1(oam[505]), 
        .B2(n2333), .Y(n1094) );
  sky130_fd_sc_hd__nand4_1 U1207 ( .A(n1098), .B(n1099), .C(n1100), .D(n1101), 
        .Y(n1092) );
  sky130_fd_sc_hd__a22oi_1 U1208 ( .A1(oam[385]), .A2(n2343), .B1(oam[393]), 
        .B2(n2346), .Y(n1101) );
  sky130_fd_sc_hd__a22oi_1 U1209 ( .A1(oam[401]), .A2(n549), .B1(oam[409]), 
        .B2(n2363), .Y(n1100) );
  sky130_fd_sc_hd__a22oi_1 U1210 ( .A1(oam[417]), .A2(n530), .B1(oam[425]), 
        .B2(n566), .Y(n1099) );
  sky130_fd_sc_hd__a22oi_1 U1211 ( .A1(oam[433]), .A2(n2371), .B1(oam[441]), 
        .B2(n2381), .Y(n1098) );
  sky130_fd_sc_hd__o21ai_1 U1212 ( .A1(n1106), .A2(n1107), .B1(n128), .Y(n1105) );
  sky130_fd_sc_hd__nand4_1 U1213 ( .A(n1108), .B(n1109), .C(n1110), .D(n1111), 
        .Y(n1107) );
  sky130_fd_sc_hd__a22oi_1 U1214 ( .A1(oam[1601]), .A2(n602), .B1(oam[1609]), 
        .B2(n95), .Y(n1111) );
  sky130_fd_sc_hd__a22oi_1 U1215 ( .A1(oam[1617]), .A2(n2299), .B1(oam[1625]), 
        .B2(n541), .Y(n1110) );
  sky130_fd_sc_hd__a22oi_1 U1216 ( .A1(oam[1633]), .A2(n472), .B1(oam[1641]), 
        .B2(n2324), .Y(n1109) );
  sky130_fd_sc_hd__a22oi_1 U1217 ( .A1(oam[1649]), .A2(n487), .B1(oam[1657]), 
        .B2(n2333), .Y(n1108) );
  sky130_fd_sc_hd__nand4_1 U1218 ( .A(n1112), .B(n1113), .C(n1114), .D(n1115), 
        .Y(n1106) );
  sky130_fd_sc_hd__a22oi_1 U1219 ( .A1(oam[1537]), .A2(n2340), .B1(oam[1545]), 
        .B2(n2346), .Y(n1115) );
  sky130_fd_sc_hd__a22oi_1 U1220 ( .A1(oam[1553]), .A2(n549), .B1(oam[1561]), 
        .B2(n2363), .Y(n1114) );
  sky130_fd_sc_hd__a22oi_1 U1221 ( .A1(oam[1569]), .A2(n518), .B1(oam[1577]), 
        .B2(n572), .Y(n1113) );
  sky130_fd_sc_hd__a22oi_1 U1222 ( .A1(oam[1585]), .A2(n439), .B1(oam[1593]), 
        .B2(n2383), .Y(n1112) );
  sky130_fd_sc_hd__o21ai_1 U1223 ( .A1(n1116), .A2(n1117), .B1(n130), .Y(n1104) );
  sky130_fd_sc_hd__nand4_1 U1224 ( .A(n1118), .B(n1119), .C(n1120), .D(n1121), 
        .Y(n1117) );
  sky130_fd_sc_hd__a22oi_1 U1225 ( .A1(oam[1089]), .A2(n606), .B1(oam[1097]), 
        .B2(n17), .Y(n1121) );
  sky130_fd_sc_hd__a22oi_1 U1226 ( .A1(oam[1105]), .A2(n2299), .B1(oam[1113]), 
        .B2(n544), .Y(n1120) );
  sky130_fd_sc_hd__a22oi_1 U1227 ( .A1(oam[1121]), .A2(n2312), .B1(oam[1129]), 
        .B2(n2322), .Y(n1119) );
  sky130_fd_sc_hd__a22oi_1 U1228 ( .A1(oam[1137]), .A2(n489), .B1(oam[1145]), 
        .B2(n2333), .Y(n1118) );
  sky130_fd_sc_hd__nand4_1 U1229 ( .A(n1122), .B(n1123), .C(n1124), .D(n1125), 
        .Y(n1116) );
  sky130_fd_sc_hd__a22oi_1 U1230 ( .A1(oam[1025]), .A2(n2343), .B1(oam[1033]), 
        .B2(n2353), .Y(n1125) );
  sky130_fd_sc_hd__a22oi_1 U1231 ( .A1(oam[1041]), .A2(n559), .B1(oam[1049]), 
        .B2(n2363), .Y(n1124) );
  sky130_fd_sc_hd__a22oi_1 U1232 ( .A1(oam[1073]), .A2(n2366), .B1(oam[1081]), 
        .B2(n2377), .Y(n1122) );
  sky130_fd_sc_hd__o21ai_1 U1233 ( .A1(n1126), .A2(n1127), .B1(n129), .Y(n1103) );
  sky130_fd_sc_hd__nand4_1 U1234 ( .A(n1128), .B(n1129), .C(n1130), .D(n1131), 
        .Y(n1127) );
  sky130_fd_sc_hd__a22oi_1 U1235 ( .A1(oam[577]), .A2(n608), .B1(oam[585]), 
        .B2(n81), .Y(n1131) );
  sky130_fd_sc_hd__a22oi_1 U1236 ( .A1(oam[593]), .A2(n2296), .B1(oam[601]), 
        .B2(n542), .Y(n1130) );
  sky130_fd_sc_hd__a22oi_1 U1237 ( .A1(oam[609]), .A2(n2310), .B1(oam[617]), 
        .B2(n2317), .Y(n1129) );
  sky130_fd_sc_hd__a22oi_1 U1238 ( .A1(oam[625]), .A2(n480), .B1(oam[633]), 
        .B2(n2332), .Y(n1128) );
  sky130_fd_sc_hd__nand4_1 U1239 ( .A(n1132), .B(n1133), .C(n1134), .D(n1135), 
        .Y(n1126) );
  sky130_fd_sc_hd__a22oi_1 U1240 ( .A1(oam[513]), .A2(n2337), .B1(oam[521]), 
        .B2(n2349), .Y(n1135) );
  sky130_fd_sc_hd__a22oi_1 U1241 ( .A1(oam[529]), .A2(n559), .B1(oam[537]), 
        .B2(n2362), .Y(n1134) );
  sky130_fd_sc_hd__a22oi_1 U1242 ( .A1(oam[545]), .A2(n529), .B1(oam[553]), 
        .B2(n567), .Y(n1133) );
  sky130_fd_sc_hd__a22oi_1 U1243 ( .A1(oam[561]), .A2(n2372), .B1(oam[569]), 
        .B2(n2380), .Y(n1132) );
  sky130_fd_sc_hd__o21ai_1 U1244 ( .A1(n1136), .A2(n1137), .B1(n231), .Y(n1102) );
  sky130_fd_sc_hd__nand4_1 U1245 ( .A(n1138), .B(n1139), .C(n1140), .D(n1141), 
        .Y(n1137) );
  sky130_fd_sc_hd__a22oi_1 U1246 ( .A1(oam[81]), .A2(n2296), .B1(oam[89]), 
        .B2(n545), .Y(n1140) );
  sky130_fd_sc_hd__a22oi_1 U1247 ( .A1(oam[97]), .A2(n2307), .B1(oam[105]), 
        .B2(n445), .Y(n1139) );
  sky130_fd_sc_hd__a22oi_1 U1248 ( .A1(oam[113]), .A2(n482), .B1(oam[121]), 
        .B2(n2332), .Y(n1138) );
  sky130_fd_sc_hd__nand4_1 U1249 ( .A(n1142), .B(n1143), .C(n1144), .D(n1145), 
        .Y(n1136) );
  sky130_fd_sc_hd__a22oi_1 U1250 ( .A1(oam[1]), .A2(n2339), .B1(oam[9]), .B2(
        n2350), .Y(n1145) );
  sky130_fd_sc_hd__a22oi_1 U1251 ( .A1(oam[17]), .A2(n548), .B1(oam[25]), .B2(
        n2362), .Y(n1144) );
  sky130_fd_sc_hd__a22oi_1 U1252 ( .A1(oam[33]), .A2(n524), .B1(oam[41]), .B2(
        n566), .Y(n1143) );
  sky130_fd_sc_hd__a22oi_1 U1253 ( .A1(oam[49]), .A2(n439), .B1(oam[57]), .B2(
        n2378), .Y(n1142) );
  sky130_fd_sc_hd__o21ai_1 U1254 ( .A1(n1150), .A2(n1151), .B1(n127), .Y(n1149) );
  sky130_fd_sc_hd__nand4_1 U1255 ( .A(n1152), .B(n1153), .C(n1154), .D(n1155), 
        .Y(n1151) );
  sky130_fd_sc_hd__a22oi_1 U1256 ( .A1(oam[1729]), .A2(n620), .B1(oam[1737]), 
        .B2(n65), .Y(n1155) );
  sky130_fd_sc_hd__a22oi_1 U1257 ( .A1(oam[1745]), .A2(n2300), .B1(oam[1753]), 
        .B2(n542), .Y(n1154) );
  sky130_fd_sc_hd__a22oi_1 U1258 ( .A1(oam[1761]), .A2(n2308), .B1(oam[1769]), 
        .B2(n2316), .Y(n1153) );
  sky130_fd_sc_hd__a22oi_1 U1259 ( .A1(oam[1777]), .A2(n481), .B1(oam[1785]), 
        .B2(n2332), .Y(n1152) );
  sky130_fd_sc_hd__nand4_1 U1260 ( .A(n1156), .B(n1157), .C(n1158), .D(n1159), 
        .Y(n1150) );
  sky130_fd_sc_hd__a22oi_1 U1261 ( .A1(oam[1665]), .A2(n2342), .B1(oam[1673]), 
        .B2(n2345), .Y(n1159) );
  sky130_fd_sc_hd__a22oi_1 U1262 ( .A1(oam[1681]), .A2(n560), .B1(oam[1689]), 
        .B2(n2362), .Y(n1158) );
  sky130_fd_sc_hd__a22oi_1 U1263 ( .A1(oam[1697]), .A2(n517), .B1(oam[1705]), 
        .B2(n566), .Y(n1157) );
  sky130_fd_sc_hd__a22oi_1 U1264 ( .A1(oam[1713]), .A2(n2366), .B1(oam[1721]), 
        .B2(n2375), .Y(n1156) );
  sky130_fd_sc_hd__o21ai_1 U1265 ( .A1(n1160), .A2(n1161), .B1(n220), .Y(n1148) );
  sky130_fd_sc_hd__nand4_1 U1266 ( .A(n1162), .B(n1163), .C(n1164), .D(n1165), 
        .Y(n1161) );
  sky130_fd_sc_hd__a22oi_1 U1267 ( .A1(oam[1233]), .A2(n2296), .B1(oam[1241]), 
        .B2(n534), .Y(n1164) );
  sky130_fd_sc_hd__a22oi_1 U1268 ( .A1(oam[1249]), .A2(n2308), .B1(oam[1257]), 
        .B2(n445), .Y(n1163) );
  sky130_fd_sc_hd__a22oi_1 U1269 ( .A1(oam[1265]), .A2(n479), .B1(oam[1273]), 
        .B2(n2332), .Y(n1162) );
  sky130_fd_sc_hd__nand4_1 U1270 ( .A(n1167), .B(n1166), .C(n1168), .D(n1169), 
        .Y(n1160) );
  sky130_fd_sc_hd__a22oi_1 U1271 ( .A1(oam[1153]), .A2(n2342), .B1(oam[1161]), 
        .B2(n2348), .Y(n1169) );
  sky130_fd_sc_hd__a22oi_1 U1272 ( .A1(oam[1169]), .A2(n557), .B1(oam[1177]), 
        .B2(n2362), .Y(n1168) );
  sky130_fd_sc_hd__a22oi_1 U1273 ( .A1(oam[1185]), .A2(n527), .B1(oam[1193]), 
        .B2(n577), .Y(n1167) );
  sky130_fd_sc_hd__a22oi_1 U1274 ( .A1(oam[1201]), .A2(n2367), .B1(oam[1209]), 
        .B2(n2374), .Y(n1166) );
  sky130_fd_sc_hd__o21ai_1 U1275 ( .A1(n1170), .A2(n1171), .B1(n222), .Y(n1147) );
  sky130_fd_sc_hd__nand4_1 U1276 ( .A(n1172), .B(n1173), .C(n1174), .D(n1175), 
        .Y(n1171) );
  sky130_fd_sc_hd__a22oi_1 U1277 ( .A1(oam[705]), .A2(n586), .B1(oam[713]), 
        .B2(n34), .Y(n1175) );
  sky130_fd_sc_hd__a22oi_1 U1278 ( .A1(oam[721]), .A2(n2300), .B1(oam[729]), 
        .B2(n534), .Y(n1174) );
  sky130_fd_sc_hd__a22oi_1 U1279 ( .A1(oam[737]), .A2(n2307), .B1(oam[745]), 
        .B2(n2324), .Y(n1173) );
  sky130_fd_sc_hd__a22oi_1 U1280 ( .A1(oam[753]), .A2(n483), .B1(oam[761]), 
        .B2(n2332), .Y(n1172) );
  sky130_fd_sc_hd__nand4_1 U1281 ( .A(n1176), .B(n1177), .C(n1178), .D(n1179), 
        .Y(n1170) );
  sky130_fd_sc_hd__a22oi_1 U1282 ( .A1(oam[641]), .A2(n2342), .B1(oam[649]), 
        .B2(n2352), .Y(n1179) );
  sky130_fd_sc_hd__a22oi_1 U1283 ( .A1(oam[657]), .A2(n549), .B1(oam[665]), 
        .B2(n2362), .Y(n1178) );
  sky130_fd_sc_hd__a22oi_1 U1284 ( .A1(oam[673]), .A2(n525), .B1(oam[681]), 
        .B2(n568), .Y(n1177) );
  sky130_fd_sc_hd__a22oi_1 U1285 ( .A1(oam[689]), .A2(n2368), .B1(oam[697]), 
        .B2(n2376), .Y(n1176) );
  sky130_fd_sc_hd__o21ai_1 U1286 ( .A1(n1180), .A2(n1181), .B1(n226), .Y(n1146) );
  sky130_fd_sc_hd__nand4_1 U1287 ( .A(n1182), .B(n1183), .C(n1184), .D(n1185), 
        .Y(n1181) );
  sky130_fd_sc_hd__a22oi_1 U1288 ( .A1(oam[193]), .A2(n601), .B1(oam[201]), 
        .B2(n25), .Y(n1185) );
  sky130_fd_sc_hd__a22oi_1 U1289 ( .A1(oam[209]), .A2(n2296), .B1(oam[217]), 
        .B2(n541), .Y(n1184) );
  sky130_fd_sc_hd__a22oi_1 U1290 ( .A1(oam[225]), .A2(n2313), .B1(oam[233]), 
        .B2(n2318), .Y(n1183) );
  sky130_fd_sc_hd__a22oi_1 U1291 ( .A1(oam[241]), .A2(n488), .B1(oam[249]), 
        .B2(n2332), .Y(n1182) );
  sky130_fd_sc_hd__nand4_1 U1292 ( .A(n1186), .B(n1187), .C(n1188), .D(n1189), 
        .Y(n1180) );
  sky130_fd_sc_hd__a22oi_1 U1293 ( .A1(oam[129]), .A2(n2344), .B1(oam[137]), 
        .B2(n2349), .Y(n1189) );
  sky130_fd_sc_hd__a22oi_1 U1294 ( .A1(oam[145]), .A2(n559), .B1(oam[153]), 
        .B2(n2362), .Y(n1188) );
  sky130_fd_sc_hd__a22oi_1 U1295 ( .A1(oam[161]), .A2(n524), .B1(oam[169]), 
        .B2(n568), .Y(n1187) );
  sky130_fd_sc_hd__a22oi_1 U1296 ( .A1(oam[177]), .A2(n2372), .B1(oam[185]), 
        .B2(n2375), .Y(n1186) );
  sky130_fd_sc_hd__o21ai_1 U1297 ( .A1(n1194), .A2(n1195), .B1(n103), .Y(n1193) );
  sky130_fd_sc_hd__nand4_1 U1298 ( .A(n1196), .B(n1197), .C(n1198), .D(n1199), 
        .Y(n1195) );
  sky130_fd_sc_hd__a22oi_1 U1299 ( .A1(oam[1858]), .A2(n590), .B1(oam[1866]), 
        .B2(n32), .Y(n1199) );
  sky130_fd_sc_hd__a22oi_1 U1300 ( .A1(oam[1890]), .A2(n2312), .B1(oam[1898]), 
        .B2(n2316), .Y(n1197) );
  sky130_fd_sc_hd__a22oi_1 U1301 ( .A1(oam[1906]), .A2(n483), .B1(oam[1914]), 
        .B2(n2332), .Y(n1196) );
  sky130_fd_sc_hd__nand4_1 U1302 ( .A(n1200), .B(n1201), .C(n1202), .D(n1203), 
        .Y(n1194) );
  sky130_fd_sc_hd__a22oi_1 U1303 ( .A1(oam[1794]), .A2(n2343), .B1(oam[1802]), 
        .B2(n2346), .Y(n1203) );
  sky130_fd_sc_hd__a22oi_1 U1304 ( .A1(oam[1810]), .A2(n561), .B1(oam[1818]), 
        .B2(n2362), .Y(n1202) );
  sky130_fd_sc_hd__a22oi_1 U1305 ( .A1(oam[1826]), .A2(n518), .B1(oam[1834]), 
        .B2(n572), .Y(n1201) );
  sky130_fd_sc_hd__a22oi_1 U1306 ( .A1(oam[1842]), .A2(n2370), .B1(oam[1850]), 
        .B2(n2383), .Y(n1200) );
  sky130_fd_sc_hd__o21ai_1 U1307 ( .A1(n1204), .A2(n1205), .B1(n228), .Y(n1192) );
  sky130_fd_sc_hd__nand4_1 U1308 ( .A(n1206), .B(n1207), .C(n1208), .D(n1209), 
        .Y(n1205) );
  sky130_fd_sc_hd__a22oi_1 U1309 ( .A1(oam[1346]), .A2(n600), .B1(oam[1354]), 
        .B2(n52), .Y(n1209) );
  sky130_fd_sc_hd__a22oi_1 U1310 ( .A1(oam[1362]), .A2(n2298), .B1(oam[1370]), 
        .B2(n540), .Y(n1208) );
  sky130_fd_sc_hd__a22oi_1 U1311 ( .A1(oam[1378]), .A2(n472), .B1(oam[1386]), 
        .B2(n2319), .Y(n1207) );
  sky130_fd_sc_hd__a22oi_1 U1312 ( .A1(oam[1394]), .A2(n480), .B1(oam[1402]), 
        .B2(n2332), .Y(n1206) );
  sky130_fd_sc_hd__nand4_1 U1313 ( .A(n1210), .B(n1211), .C(n1212), .D(n1213), 
        .Y(n1204) );
  sky130_fd_sc_hd__a22oi_1 U1314 ( .A1(oam[1282]), .A2(n2339), .B1(oam[1290]), 
        .B2(n2347), .Y(n1213) );
  sky130_fd_sc_hd__a22oi_1 U1315 ( .A1(oam[1298]), .A2(n562), .B1(oam[1306]), 
        .B2(n2362), .Y(n1212) );
  sky130_fd_sc_hd__a22oi_1 U1316 ( .A1(oam[1314]), .A2(n517), .B1(oam[1322]), 
        .B2(n566), .Y(n1211) );
  sky130_fd_sc_hd__a22oi_1 U1317 ( .A1(oam[1330]), .A2(n2370), .B1(oam[1338]), 
        .B2(n2381), .Y(n1210) );
  sky130_fd_sc_hd__o21ai_1 U1318 ( .A1(n1214), .A2(n1215), .B1(n227), .Y(n1191) );
  sky130_fd_sc_hd__nand4_1 U1319 ( .A(n1216), .B(n1217), .C(n1218), .D(n1219), 
        .Y(n1215) );
  sky130_fd_sc_hd__a22oi_1 U1320 ( .A1(oam[834]), .A2(n601), .B1(oam[842]), 
        .B2(n89), .Y(n1219) );
  sky130_fd_sc_hd__a22oi_1 U1321 ( .A1(oam[850]), .A2(n2305), .B1(oam[858]), 
        .B2(n542), .Y(n1218) );
  sky130_fd_sc_hd__a22oi_1 U1322 ( .A1(oam[866]), .A2(n2308), .B1(oam[874]), 
        .B2(n2315), .Y(n1217) );
  sky130_fd_sc_hd__a22oi_1 U1323 ( .A1(oam[882]), .A2(n482), .B1(oam[890]), 
        .B2(n2332), .Y(n1216) );
  sky130_fd_sc_hd__nand4_1 U1324 ( .A(n1220), .B(n1221), .C(n1222), .D(n1223), 
        .Y(n1214) );
  sky130_fd_sc_hd__a22oi_1 U1325 ( .A1(oam[770]), .A2(n2337), .B1(oam[778]), 
        .B2(n2352), .Y(n1223) );
  sky130_fd_sc_hd__a22oi_1 U1326 ( .A1(oam[786]), .A2(n563), .B1(oam[794]), 
        .B2(n2362), .Y(n1222) );
  sky130_fd_sc_hd__a22oi_1 U1327 ( .A1(oam[802]), .A2(n527), .B1(oam[810]), 
        .B2(n567), .Y(n1221) );
  sky130_fd_sc_hd__a22oi_1 U1328 ( .A1(oam[818]), .A2(n2367), .B1(oam[826]), 
        .B2(n2380), .Y(n1220) );
  sky130_fd_sc_hd__o21ai_1 U1329 ( .A1(n1224), .A2(n1225), .B1(n229), .Y(n1190) );
  sky130_fd_sc_hd__nand4_1 U1330 ( .A(n1226), .B(n1227), .C(n1228), .D(n1229), 
        .Y(n1225) );
  sky130_fd_sc_hd__a22oi_1 U1331 ( .A1(oam[322]), .A2(n607), .B1(oam[330]), 
        .B2(n15), .Y(n1229) );
  sky130_fd_sc_hd__a22oi_1 U1332 ( .A1(oam[338]), .A2(n2297), .B1(oam[346]), 
        .B2(n535), .Y(n1228) );
  sky130_fd_sc_hd__a22oi_1 U1333 ( .A1(oam[354]), .A2(n2307), .B1(oam[362]), 
        .B2(n2316), .Y(n1227) );
  sky130_fd_sc_hd__a22oi_1 U1334 ( .A1(oam[370]), .A2(n488), .B1(oam[378]), 
        .B2(n2332), .Y(n1226) );
  sky130_fd_sc_hd__nand4_1 U1335 ( .A(n1230), .B(n1231), .C(n1232), .D(n1233), 
        .Y(n1224) );
  sky130_fd_sc_hd__a22oi_1 U1336 ( .A1(oam[258]), .A2(n2336), .B1(oam[266]), 
        .B2(n2348), .Y(n1233) );
  sky130_fd_sc_hd__a22oi_1 U1337 ( .A1(oam[274]), .A2(n557), .B1(oam[282]), 
        .B2(n2362), .Y(n1232) );
  sky130_fd_sc_hd__a22oi_1 U1338 ( .A1(oam[290]), .A2(n517), .B1(oam[298]), 
        .B2(n572), .Y(n1231) );
  sky130_fd_sc_hd__a22oi_1 U1339 ( .A1(oam[306]), .A2(n2373), .B1(oam[314]), 
        .B2(n2378), .Y(n1230) );
  sky130_fd_sc_hd__o21ai_1 U1340 ( .A1(n1238), .A2(n1239), .B1(n219), .Y(n1237) );
  sky130_fd_sc_hd__nand4_1 U1341 ( .A(n1240), .B(n1241), .C(n1242), .D(n1243), 
        .Y(n1239) );
  sky130_fd_sc_hd__a22oi_1 U1342 ( .A1(oam[1986]), .A2(n588), .B1(oam[1994]), 
        .B2(n40), .Y(n1243) );
  sky130_fd_sc_hd__a22oi_1 U1343 ( .A1(oam[2018]), .A2(n2309), .B1(oam[2026]), 
        .B2(n2318), .Y(n1241) );
  sky130_fd_sc_hd__a22oi_1 U1344 ( .A1(oam[2034]), .A2(n490), .B1(oam[2042]), 
        .B2(n2332), .Y(n1240) );
  sky130_fd_sc_hd__nand4_1 U1345 ( .A(n1245), .B(n1244), .C(n1246), .D(n1247), 
        .Y(n1238) );
  sky130_fd_sc_hd__a22oi_1 U1346 ( .A1(oam[1922]), .A2(n2336), .B1(oam[1930]), 
        .B2(n2350), .Y(n1247) );
  sky130_fd_sc_hd__a22oi_1 U1347 ( .A1(oam[1938]), .A2(n550), .B1(oam[1946]), 
        .B2(n2362), .Y(n1246) );
  sky130_fd_sc_hd__a22oi_1 U1348 ( .A1(oam[1954]), .A2(n530), .B1(oam[1962]), 
        .B2(n566), .Y(n1245) );
  sky130_fd_sc_hd__a22oi_1 U1349 ( .A1(oam[1970]), .A2(n2366), .B1(oam[1978]), 
        .B2(n2382), .Y(n1244) );
  sky130_fd_sc_hd__o21ai_1 U1350 ( .A1(n1248), .A2(n1249), .B1(n221), .Y(n1236) );
  sky130_fd_sc_hd__nand4_1 U1351 ( .A(n1250), .B(n1251), .C(n1252), .D(n1253), 
        .Y(n1249) );
  sky130_fd_sc_hd__a22oi_1 U1352 ( .A1(oam[1474]), .A2(n590), .B1(oam[1482]), 
        .B2(n26), .Y(n1253) );
  sky130_fd_sc_hd__a22oi_1 U1353 ( .A1(oam[1490]), .A2(n2299), .B1(oam[1498]), 
        .B2(n534), .Y(n1252) );
  sky130_fd_sc_hd__a22oi_1 U1354 ( .A1(oam[1506]), .A2(n2314), .B1(oam[1514]), 
        .B2(n2315), .Y(n1251) );
  sky130_fd_sc_hd__a22oi_1 U1355 ( .A1(oam[1522]), .A2(n479), .B1(oam[1530]), 
        .B2(n2332), .Y(n1250) );
  sky130_fd_sc_hd__nand4_1 U1356 ( .A(n216), .B(n1254), .C(n1255), .D(n1256), 
        .Y(n1248) );
  sky130_fd_sc_hd__a22oi_1 U1357 ( .A1(oam[1410]), .A2(n2335), .B1(oam[1418]), 
        .B2(n2348), .Y(n1256) );
  sky130_fd_sc_hd__a22oi_1 U1358 ( .A1(oam[1426]), .A2(n556), .B1(oam[1434]), 
        .B2(n2362), .Y(n1255) );
  sky130_fd_sc_hd__a22oi_1 U1359 ( .A1(oam[1442]), .A2(n525), .B1(oam[1450]), 
        .B2(n566), .Y(n1254) );
  sky130_fd_sc_hd__o21ai_1 U1360 ( .A1(n1257), .A2(n1258), .B1(n223), .Y(n1235) );
  sky130_fd_sc_hd__nand4_1 U1361 ( .A(n1259), .B(n1260), .C(n1261), .D(n1262), 
        .Y(n1258) );
  sky130_fd_sc_hd__a22oi_1 U1362 ( .A1(oam[962]), .A2(n600), .B1(oam[970]), 
        .B2(n86), .Y(n1262) );
  sky130_fd_sc_hd__a22oi_1 U1363 ( .A1(oam[994]), .A2(n2307), .B1(oam[1002]), 
        .B2(n2318), .Y(n1260) );
  sky130_fd_sc_hd__a22oi_1 U1364 ( .A1(oam[1010]), .A2(n486), .B1(oam[1018]), 
        .B2(n2332), .Y(n1259) );
  sky130_fd_sc_hd__nand4_1 U1365 ( .A(n1263), .B(n1264), .C(n1265), .D(n1266), 
        .Y(n1257) );
  sky130_fd_sc_hd__a22oi_1 U1366 ( .A1(oam[898]), .A2(n2342), .B1(oam[906]), 
        .B2(n2347), .Y(n1266) );
  sky130_fd_sc_hd__a22oi_1 U1367 ( .A1(oam[914]), .A2(n548), .B1(oam[922]), 
        .B2(n2362), .Y(n1265) );
  sky130_fd_sc_hd__a22oi_1 U1368 ( .A1(oam[930]), .A2(n519), .B1(oam[938]), 
        .B2(n568), .Y(n1264) );
  sky130_fd_sc_hd__a22oi_1 U1369 ( .A1(oam[946]), .A2(n2370), .B1(oam[954]), 
        .B2(n2375), .Y(n1263) );
  sky130_fd_sc_hd__o21ai_1 U1370 ( .A1(n1267), .A2(n1268), .B1(n224), .Y(n1234) );
  sky130_fd_sc_hd__nand4_1 U1371 ( .A(n1269), .B(n1270), .C(n1271), .D(n1272), 
        .Y(n1268) );
  sky130_fd_sc_hd__a22oi_1 U1372 ( .A1(oam[450]), .A2(n609), .B1(oam[458]), 
        .B2(n28), .Y(n1272) );
  sky130_fd_sc_hd__a22oi_1 U1373 ( .A1(oam[466]), .A2(n2302), .B1(oam[474]), 
        .B2(n535), .Y(n1271) );
  sky130_fd_sc_hd__a22oi_1 U1374 ( .A1(oam[482]), .A2(n2314), .B1(oam[490]), 
        .B2(n445), .Y(n1270) );
  sky130_fd_sc_hd__a22oi_1 U1375 ( .A1(oam[498]), .A2(n490), .B1(oam[506]), 
        .B2(n2331), .Y(n1269) );
  sky130_fd_sc_hd__nand4_1 U1376 ( .A(n1273), .B(n1274), .C(n1275), .D(n1276), 
        .Y(n1267) );
  sky130_fd_sc_hd__a22oi_1 U1377 ( .A1(oam[386]), .A2(n2344), .B1(oam[394]), 
        .B2(n2347), .Y(n1276) );
  sky130_fd_sc_hd__a22oi_1 U1378 ( .A1(oam[402]), .A2(n550), .B1(oam[410]), 
        .B2(n2361), .Y(n1275) );
  sky130_fd_sc_hd__a22oi_1 U1379 ( .A1(oam[418]), .A2(n518), .B1(oam[426]), 
        .B2(n573), .Y(n1274) );
  sky130_fd_sc_hd__a22oi_1 U1380 ( .A1(oam[434]), .A2(n2369), .B1(oam[442]), 
        .B2(n2379), .Y(n1273) );
  sky130_fd_sc_hd__o21ai_1 U1381 ( .A1(n1281), .A2(n1282), .B1(n128), .Y(n1280) );
  sky130_fd_sc_hd__nand4_1 U1382 ( .A(n1283), .B(n1284), .C(n1285), .D(n1286), 
        .Y(n1282) );
  sky130_fd_sc_hd__a22oi_1 U1383 ( .A1(oam[1602]), .A2(n606), .B1(oam[1610]), 
        .B2(n77), .Y(n1286) );
  sky130_fd_sc_hd__a22oi_1 U1384 ( .A1(oam[1618]), .A2(n2300), .B1(oam[1626]), 
        .B2(n535), .Y(n1285) );
  sky130_fd_sc_hd__a22oi_1 U1385 ( .A1(oam[1634]), .A2(n2307), .B1(oam[1642]), 
        .B2(n2316), .Y(n1284) );
  sky130_fd_sc_hd__a22oi_1 U1386 ( .A1(oam[1650]), .A2(n480), .B1(oam[1658]), 
        .B2(n2331), .Y(n1283) );
  sky130_fd_sc_hd__nand4_1 U1387 ( .A(n1287), .B(n1288), .C(n1289), .D(n1290), 
        .Y(n1281) );
  sky130_fd_sc_hd__a22oi_1 U1388 ( .A1(oam[1538]), .A2(n2343), .B1(oam[1546]), 
        .B2(n2351), .Y(n1290) );
  sky130_fd_sc_hd__a22oi_1 U1389 ( .A1(oam[1554]), .A2(n556), .B1(oam[1562]), 
        .B2(n2361), .Y(n1289) );
  sky130_fd_sc_hd__a22oi_1 U1390 ( .A1(oam[1570]), .A2(n518), .B1(oam[1578]), 
        .B2(n576), .Y(n1288) );
  sky130_fd_sc_hd__a22oi_1 U1391 ( .A1(oam[1586]), .A2(n2365), .B1(oam[1594]), 
        .B2(n2375), .Y(n1287) );
  sky130_fd_sc_hd__o21ai_1 U1392 ( .A1(n1291), .A2(n1292), .B1(n130), .Y(n1279) );
  sky130_fd_sc_hd__nand4_1 U1393 ( .A(n1293), .B(n1294), .C(n1295), .D(n1296), 
        .Y(n1292) );
  sky130_fd_sc_hd__a22oi_1 U1394 ( .A1(oam[1090]), .A2(n603), .B1(oam[1098]), 
        .B2(n42), .Y(n1296) );
  sky130_fd_sc_hd__a22oi_1 U1395 ( .A1(oam[1106]), .A2(n2296), .B1(oam[1114]), 
        .B2(n541), .Y(n1295) );
  sky130_fd_sc_hd__a22oi_1 U1396 ( .A1(oam[1122]), .A2(n472), .B1(oam[1130]), 
        .B2(n2323), .Y(n1294) );
  sky130_fd_sc_hd__a22oi_1 U1397 ( .A1(oam[1138]), .A2(n489), .B1(oam[1146]), 
        .B2(n2331), .Y(n1293) );
  sky130_fd_sc_hd__nand4_1 U1398 ( .A(n1297), .B(n1298), .C(n1299), .D(n1300), 
        .Y(n1291) );
  sky130_fd_sc_hd__a22oi_1 U1399 ( .A1(oam[1026]), .A2(n2341), .B1(oam[1034]), 
        .B2(n2354), .Y(n1300) );
  sky130_fd_sc_hd__a22oi_1 U1400 ( .A1(oam[1042]), .A2(n557), .B1(oam[1050]), 
        .B2(n2361), .Y(n1299) );
  sky130_fd_sc_hd__a22oi_1 U1401 ( .A1(oam[1058]), .A2(n517), .B1(oam[1066]), 
        .B2(n576), .Y(n1298) );
  sky130_fd_sc_hd__a22oi_1 U1402 ( .A1(oam[1074]), .A2(n439), .B1(oam[1082]), 
        .B2(n2377), .Y(n1297) );
  sky130_fd_sc_hd__o21ai_1 U1403 ( .A1(n1301), .A2(n1302), .B1(n129), .Y(n1278) );
  sky130_fd_sc_hd__nand4_1 U1404 ( .A(n1303), .B(n1304), .C(n1305), .D(n1306), 
        .Y(n1302) );
  sky130_fd_sc_hd__a22oi_1 U1405 ( .A1(oam[578]), .A2(n611), .B1(oam[586]), 
        .B2(n85), .Y(n1306) );
  sky130_fd_sc_hd__a22oi_1 U1406 ( .A1(oam[594]), .A2(n2301), .B1(oam[602]), 
        .B2(n533), .Y(n1305) );
  sky130_fd_sc_hd__a22oi_1 U1407 ( .A1(oam[610]), .A2(n2313), .B1(oam[618]), 
        .B2(n2321), .Y(n1304) );
  sky130_fd_sc_hd__a22oi_1 U1408 ( .A1(oam[626]), .A2(n487), .B1(oam[634]), 
        .B2(n2331), .Y(n1303) );
  sky130_fd_sc_hd__nand4_1 U1409 ( .A(n1307), .B(n1308), .C(n1309), .D(n1310), 
        .Y(n1301) );
  sky130_fd_sc_hd__a22oi_1 U1410 ( .A1(oam[514]), .A2(n2343), .B1(oam[522]), 
        .B2(n2348), .Y(n1310) );
  sky130_fd_sc_hd__a22oi_1 U1411 ( .A1(oam[530]), .A2(n558), .B1(oam[538]), 
        .B2(n2361), .Y(n1309) );
  sky130_fd_sc_hd__a22oi_1 U1412 ( .A1(oam[546]), .A2(n525), .B1(oam[554]), 
        .B2(n575), .Y(n1308) );
  sky130_fd_sc_hd__a22oi_1 U1413 ( .A1(oam[562]), .A2(n2366), .B1(oam[570]), 
        .B2(n2380), .Y(n1307) );
  sky130_fd_sc_hd__o21ai_1 U1414 ( .A1(n1311), .A2(n1312), .B1(n231), .Y(n1277) );
  sky130_fd_sc_hd__nand4_1 U1415 ( .A(n1313), .B(n1314), .C(n1315), .D(n1316), 
        .Y(n1312) );
  sky130_fd_sc_hd__a22oi_1 U1416 ( .A1(oam[66]), .A2(n611), .B1(oam[74]), .B2(
        n35), .Y(n1316) );
  sky130_fd_sc_hd__a22oi_1 U1417 ( .A1(oam[82]), .A2(n2296), .B1(oam[90]), 
        .B2(n545), .Y(n1315) );
  sky130_fd_sc_hd__a22oi_1 U1418 ( .A1(oam[98]), .A2(n2312), .B1(oam[106]), 
        .B2(n2316), .Y(n1314) );
  sky130_fd_sc_hd__a22oi_1 U1419 ( .A1(oam[114]), .A2(n481), .B1(oam[122]), 
        .B2(n2331), .Y(n1313) );
  sky130_fd_sc_hd__nand4_1 U1420 ( .A(n1317), .B(n1318), .C(n1319), .D(n1320), 
        .Y(n1311) );
  sky130_fd_sc_hd__a22oi_1 U1421 ( .A1(oam[2]), .A2(n2344), .B1(oam[10]), .B2(
        n2346), .Y(n1320) );
  sky130_fd_sc_hd__a22oi_1 U1422 ( .A1(oam[18]), .A2(n548), .B1(oam[26]), .B2(
        n2361), .Y(n1319) );
  sky130_fd_sc_hd__a22oi_1 U1423 ( .A1(oam[34]), .A2(n517), .B1(oam[42]), .B2(
        n573), .Y(n1318) );
  sky130_fd_sc_hd__a22oi_1 U1424 ( .A1(oam[50]), .A2(n2366), .B1(oam[58]), 
        .B2(n2377), .Y(n1317) );
  sky130_fd_sc_hd__o21ai_1 U1425 ( .A1(n1325), .A2(n1326), .B1(n127), .Y(n1324) );
  sky130_fd_sc_hd__nand4_1 U1426 ( .A(n1327), .B(n1328), .C(n1329), .D(n1330), 
        .Y(n1326) );
  sky130_fd_sc_hd__a22oi_1 U1427 ( .A1(oam[1730]), .A2(n621), .B1(oam[1738]), 
        .B2(n88), .Y(n1330) );
  sky130_fd_sc_hd__a22oi_1 U1428 ( .A1(oam[1746]), .A2(n2300), .B1(oam[1754]), 
        .B2(n544), .Y(n1329) );
  sky130_fd_sc_hd__a22oi_1 U1429 ( .A1(oam[1762]), .A2(n2312), .B1(oam[1770]), 
        .B2(n2319), .Y(n1328) );
  sky130_fd_sc_hd__a22oi_1 U1430 ( .A1(oam[1778]), .A2(n487), .B1(oam[1786]), 
        .B2(n2331), .Y(n1327) );
  sky130_fd_sc_hd__nand4_1 U1431 ( .A(n1331), .B(n1332), .C(n1333), .D(n1334), 
        .Y(n1325) );
  sky130_fd_sc_hd__a22oi_1 U1432 ( .A1(oam[1666]), .A2(n2342), .B1(oam[1674]), 
        .B2(n2349), .Y(n1334) );
  sky130_fd_sc_hd__a22oi_1 U1433 ( .A1(oam[1682]), .A2(n556), .B1(oam[1690]), 
        .B2(n2361), .Y(n1333) );
  sky130_fd_sc_hd__a22oi_1 U1434 ( .A1(oam[1698]), .A2(n519), .B1(oam[1706]), 
        .B2(n568), .Y(n1332) );
  sky130_fd_sc_hd__a22oi_1 U1435 ( .A1(oam[1714]), .A2(n2368), .B1(oam[1722]), 
        .B2(n2376), .Y(n1331) );
  sky130_fd_sc_hd__o21ai_1 U1436 ( .A1(n1335), .A2(n1336), .B1(n220), .Y(n1323) );
  sky130_fd_sc_hd__nand4_1 U1437 ( .A(n1337), .B(n1338), .C(n1339), .D(n1340), 
        .Y(n1336) );
  sky130_fd_sc_hd__a22oi_1 U1438 ( .A1(oam[1218]), .A2(n588), .B1(oam[1226]), 
        .B2(n32), .Y(n1340) );
  sky130_fd_sc_hd__a22oi_1 U1439 ( .A1(oam[1234]), .A2(n2296), .B1(oam[1242]), 
        .B2(n540), .Y(n1339) );
  sky130_fd_sc_hd__a22oi_1 U1440 ( .A1(oam[1250]), .A2(n2307), .B1(oam[1258]), 
        .B2(n2323), .Y(n1338) );
  sky130_fd_sc_hd__a22oi_1 U1441 ( .A1(oam[1266]), .A2(n489), .B1(oam[1274]), 
        .B2(n2331), .Y(n1337) );
  sky130_fd_sc_hd__nand4_1 U1442 ( .A(n1341), .B(n1342), .C(n1343), .D(n1344), 
        .Y(n1335) );
  sky130_fd_sc_hd__a22oi_1 U1443 ( .A1(oam[1154]), .A2(n2340), .B1(oam[1162]), 
        .B2(n2350), .Y(n1344) );
  sky130_fd_sc_hd__a22oi_1 U1444 ( .A1(oam[1170]), .A2(n559), .B1(oam[1178]), 
        .B2(n2361), .Y(n1343) );
  sky130_fd_sc_hd__a22oi_1 U1445 ( .A1(oam[1186]), .A2(n524), .B1(oam[1194]), 
        .B2(n566), .Y(n1342) );
  sky130_fd_sc_hd__a22oi_1 U1446 ( .A1(oam[1202]), .A2(n2370), .B1(oam[1210]), 
        .B2(n2375), .Y(n1341) );
  sky130_fd_sc_hd__o21ai_1 U1447 ( .A1(n1345), .A2(n1346), .B1(n222), .Y(n1322) );
  sky130_fd_sc_hd__nand4_1 U1448 ( .A(n1347), .B(n1348), .C(n1349), .D(n1350), 
        .Y(n1346) );
  sky130_fd_sc_hd__a22oi_1 U1449 ( .A1(oam[706]), .A2(n590), .B1(oam[714]), 
        .B2(n40), .Y(n1350) );
  sky130_fd_sc_hd__a22oi_1 U1450 ( .A1(oam[722]), .A2(n2301), .B1(oam[730]), 
        .B2(n545), .Y(n1349) );
  sky130_fd_sc_hd__a22oi_1 U1451 ( .A1(oam[738]), .A2(n2306), .B1(oam[746]), 
        .B2(n2316), .Y(n1348) );
  sky130_fd_sc_hd__a22oi_1 U1452 ( .A1(oam[754]), .A2(n479), .B1(oam[762]), 
        .B2(n2331), .Y(n1347) );
  sky130_fd_sc_hd__nand4_1 U1453 ( .A(n1351), .B(n1352), .C(n1353), .D(n1354), 
        .Y(n1345) );
  sky130_fd_sc_hd__a22oi_1 U1454 ( .A1(oam[642]), .A2(n2339), .B1(oam[650]), 
        .B2(n2346), .Y(n1354) );
  sky130_fd_sc_hd__a22oi_1 U1455 ( .A1(oam[658]), .A2(n548), .B1(oam[666]), 
        .B2(n2361), .Y(n1353) );
  sky130_fd_sc_hd__a22oi_1 U1456 ( .A1(oam[674]), .A2(n530), .B1(oam[682]), 
        .B2(n567), .Y(n1352) );
  sky130_fd_sc_hd__a22oi_1 U1457 ( .A1(oam[690]), .A2(n2368), .B1(oam[698]), 
        .B2(n2379), .Y(n1351) );
  sky130_fd_sc_hd__o21ai_1 U1458 ( .A1(n1355), .A2(n1356), .B1(n226), .Y(n1321) );
  sky130_fd_sc_hd__nand4_1 U1459 ( .A(n1357), .B(n1358), .C(n1359), .D(n1360), 
        .Y(n1356) );
  sky130_fd_sc_hd__a22oi_1 U1460 ( .A1(oam[194]), .A2(n605), .B1(oam[202]), 
        .B2(n20), .Y(n1360) );
  sky130_fd_sc_hd__a22oi_1 U1461 ( .A1(oam[210]), .A2(n2300), .B1(oam[218]), 
        .B2(n534), .Y(n1359) );
  sky130_fd_sc_hd__a22oi_1 U1462 ( .A1(oam[226]), .A2(n2308), .B1(oam[234]), 
        .B2(n2316), .Y(n1358) );
  sky130_fd_sc_hd__a22oi_1 U1463 ( .A1(oam[242]), .A2(n489), .B1(oam[250]), 
        .B2(n2331), .Y(n1357) );
  sky130_fd_sc_hd__nand4_1 U1464 ( .A(n1361), .B(n1362), .C(n1363), .D(n1364), 
        .Y(n1355) );
  sky130_fd_sc_hd__a22oi_1 U1465 ( .A1(oam[130]), .A2(n2340), .B1(oam[138]), 
        .B2(n2346), .Y(n1364) );
  sky130_fd_sc_hd__a22oi_1 U1466 ( .A1(oam[146]), .A2(n551), .B1(oam[154]), 
        .B2(n2361), .Y(n1363) );
  sky130_fd_sc_hd__a22oi_1 U1467 ( .A1(oam[162]), .A2(n517), .B1(oam[170]), 
        .B2(n566), .Y(n1362) );
  sky130_fd_sc_hd__a22oi_1 U1468 ( .A1(oam[178]), .A2(n439), .B1(oam[186]), 
        .B2(n2380), .Y(n1361) );
  sky130_fd_sc_hd__o21ai_1 U1469 ( .A1(n1369), .A2(n1370), .B1(n103), .Y(n1368) );
  sky130_fd_sc_hd__nand4_1 U1470 ( .A(n1371), .B(n1372), .C(n1373), .D(n1374), 
        .Y(n1370) );
  sky130_fd_sc_hd__a22oi_1 U1471 ( .A1(oam[1859]), .A2(n601), .B1(oam[1867]), 
        .B2(n87), .Y(n1374) );
  sky130_fd_sc_hd__a22oi_1 U1472 ( .A1(oam[1875]), .A2(n2296), .B1(oam[1883]), 
        .B2(n533), .Y(n1373) );
  sky130_fd_sc_hd__a22oi_1 U1473 ( .A1(oam[1891]), .A2(n471), .B1(oam[1899]), 
        .B2(n445), .Y(n1372) );
  sky130_fd_sc_hd__a22oi_1 U1474 ( .A1(oam[1907]), .A2(n486), .B1(oam[1915]), 
        .B2(n2331), .Y(n1371) );
  sky130_fd_sc_hd__nand4_1 U1475 ( .A(n1375), .B(n1376), .C(n1377), .D(n1378), 
        .Y(n1369) );
  sky130_fd_sc_hd__a22oi_1 U1476 ( .A1(oam[1795]), .A2(n2340), .B1(oam[1803]), 
        .B2(n2348), .Y(n1378) );
  sky130_fd_sc_hd__a22oi_1 U1477 ( .A1(oam[1811]), .A2(n563), .B1(oam[1819]), 
        .B2(n2361), .Y(n1377) );
  sky130_fd_sc_hd__a22oi_1 U1478 ( .A1(oam[1827]), .A2(n526), .B1(oam[1835]), 
        .B2(n572), .Y(n1376) );
  sky130_fd_sc_hd__a22oi_1 U1479 ( .A1(oam[1843]), .A2(n2366), .B1(oam[1851]), 
        .B2(n2374), .Y(n1375) );
  sky130_fd_sc_hd__o21ai_1 U1480 ( .A1(n1379), .A2(n1380), .B1(n228), .Y(n1367) );
  sky130_fd_sc_hd__nand4_1 U1481 ( .A(n1381), .B(n1382), .C(n1383), .D(n1384), 
        .Y(n1380) );
  sky130_fd_sc_hd__a22oi_1 U1482 ( .A1(oam[1363]), .A2(n2300), .B1(oam[1371]), 
        .B2(n535), .Y(n1383) );
  sky130_fd_sc_hd__a22oi_1 U1483 ( .A1(oam[1379]), .A2(n2307), .B1(oam[1387]), 
        .B2(n2323), .Y(n1382) );
  sky130_fd_sc_hd__a22oi_1 U1484 ( .A1(oam[1395]), .A2(n487), .B1(oam[1403]), 
        .B2(n2331), .Y(n1381) );
  sky130_fd_sc_hd__nand4_1 U1485 ( .A(n1385), .B(n1386), .C(n1387), .D(n1388), 
        .Y(n1379) );
  sky130_fd_sc_hd__a22oi_1 U1486 ( .A1(oam[1283]), .A2(n2335), .B1(oam[1291]), 
        .B2(n2350), .Y(n1388) );
  sky130_fd_sc_hd__a22oi_1 U1487 ( .A1(oam[1299]), .A2(n561), .B1(oam[1307]), 
        .B2(n2361), .Y(n1387) );
  sky130_fd_sc_hd__a22oi_1 U1488 ( .A1(oam[1315]), .A2(n527), .B1(oam[1323]), 
        .B2(n576), .Y(n1386) );
  sky130_fd_sc_hd__a22oi_1 U1489 ( .A1(oam[1331]), .A2(n2367), .B1(oam[1339]), 
        .B2(n2377), .Y(n1385) );
  sky130_fd_sc_hd__o21ai_1 U1490 ( .A1(n1389), .A2(n1390), .B1(n227), .Y(n1366) );
  sky130_fd_sc_hd__nand4_1 U1491 ( .A(n1391), .B(n1392), .C(n1393), .D(n1394), 
        .Y(n1390) );
  sky130_fd_sc_hd__a22oi_1 U1492 ( .A1(oam[835]), .A2(n612), .B1(oam[843]), 
        .B2(n67), .Y(n1394) );
  sky130_fd_sc_hd__a22oi_1 U1493 ( .A1(oam[851]), .A2(n2299), .B1(oam[859]), 
        .B2(n542), .Y(n1393) );
  sky130_fd_sc_hd__a22oi_1 U1494 ( .A1(oam[867]), .A2(n2308), .B1(oam[875]), 
        .B2(n2320), .Y(n1392) );
  sky130_fd_sc_hd__a22oi_1 U1495 ( .A1(oam[883]), .A2(n483), .B1(oam[891]), 
        .B2(n2331), .Y(n1391) );
  sky130_fd_sc_hd__nand4_1 U1496 ( .A(n1395), .B(n1396), .C(n1397), .D(n1398), 
        .Y(n1389) );
  sky130_fd_sc_hd__a22oi_1 U1497 ( .A1(oam[771]), .A2(n2340), .B1(oam[779]), 
        .B2(n2351), .Y(n1398) );
  sky130_fd_sc_hd__a22oi_1 U1498 ( .A1(oam[787]), .A2(n563), .B1(oam[795]), 
        .B2(n2361), .Y(n1397) );
  sky130_fd_sc_hd__a22oi_1 U1499 ( .A1(oam[803]), .A2(n528), .B1(oam[811]), 
        .B2(n573), .Y(n1396) );
  sky130_fd_sc_hd__a22oi_1 U1500 ( .A1(oam[819]), .A2(n2373), .B1(oam[827]), 
        .B2(n2381), .Y(n1395) );
  sky130_fd_sc_hd__o21ai_1 U1501 ( .A1(n1399), .A2(n1400), .B1(n229), .Y(n1365) );
  sky130_fd_sc_hd__nand4_1 U1502 ( .A(n1401), .B(n1402), .C(n1403), .D(n1404), 
        .Y(n1400) );
  sky130_fd_sc_hd__a22oi_1 U1503 ( .A1(oam[323]), .A2(n617), .B1(oam[331]), 
        .B2(n50), .Y(n1404) );
  sky130_fd_sc_hd__a22oi_1 U1504 ( .A1(oam[339]), .A2(n2298), .B1(oam[347]), 
        .B2(n544), .Y(n1403) );
  sky130_fd_sc_hd__a22oi_1 U1505 ( .A1(oam[355]), .A2(n2312), .B1(oam[363]), 
        .B2(n2318), .Y(n1402) );
  sky130_fd_sc_hd__a22oi_1 U1506 ( .A1(oam[371]), .A2(n480), .B1(oam[379]), 
        .B2(n2331), .Y(n1401) );
  sky130_fd_sc_hd__nand4_1 U1507 ( .A(n1405), .B(n1406), .C(n1407), .D(n1408), 
        .Y(n1399) );
  sky130_fd_sc_hd__a22oi_1 U1508 ( .A1(oam[259]), .A2(n2344), .B1(oam[267]), 
        .B2(n2351), .Y(n1408) );
  sky130_fd_sc_hd__a22oi_1 U1509 ( .A1(oam[275]), .A2(n562), .B1(oam[283]), 
        .B2(n2361), .Y(n1407) );
  sky130_fd_sc_hd__a22oi_1 U1510 ( .A1(oam[291]), .A2(n524), .B1(oam[299]), 
        .B2(n574), .Y(n1406) );
  sky130_fd_sc_hd__a22oi_1 U1511 ( .A1(oam[307]), .A2(n2371), .B1(oam[315]), 
        .B2(n2379), .Y(n1405) );
  sky130_fd_sc_hd__o21ai_1 U1512 ( .A1(n1413), .A2(n1414), .B1(n219), .Y(n1412) );
  sky130_fd_sc_hd__nand4_1 U1513 ( .A(n1415), .B(n1416), .C(n1417), .D(n1418), 
        .Y(n1414) );
  sky130_fd_sc_hd__a22oi_1 U1514 ( .A1(oam[2003]), .A2(n2297), .B1(oam[2011]), 
        .B2(n544), .Y(n1417) );
  sky130_fd_sc_hd__a22oi_1 U1515 ( .A1(oam[2019]), .A2(n472), .B1(oam[2027]), 
        .B2(n2316), .Y(n1416) );
  sky130_fd_sc_hd__a22oi_1 U1516 ( .A1(oam[2035]), .A2(n482), .B1(oam[2043]), 
        .B2(n2330), .Y(n1415) );
  sky130_fd_sc_hd__nand4_1 U1517 ( .A(n1419), .B(n1420), .C(n1421), .D(n1422), 
        .Y(n1413) );
  sky130_fd_sc_hd__a22oi_1 U1518 ( .A1(oam[1923]), .A2(n2340), .B1(oam[1931]), 
        .B2(n2352), .Y(n1422) );
  sky130_fd_sc_hd__a22oi_1 U1519 ( .A1(oam[1939]), .A2(n550), .B1(oam[1947]), 
        .B2(n2360), .Y(n1421) );
  sky130_fd_sc_hd__a22oi_1 U1520 ( .A1(oam[1971]), .A2(n2368), .B1(oam[1979]), 
        .B2(n2379), .Y(n1419) );
  sky130_fd_sc_hd__o21ai_1 U1521 ( .A1(n1423), .A2(n1424), .B1(n221), .Y(n1411) );
  sky130_fd_sc_hd__nand4_1 U1522 ( .A(n1425), .B(n1426), .C(n1427), .D(n1428), 
        .Y(n1424) );
  sky130_fd_sc_hd__a22oi_1 U1523 ( .A1(oam[1491]), .A2(n2304), .B1(oam[1499]), 
        .B2(n535), .Y(n1427) );
  sky130_fd_sc_hd__a22oi_1 U1524 ( .A1(oam[1507]), .A2(n2308), .B1(oam[1515]), 
        .B2(n2322), .Y(n1426) );
  sky130_fd_sc_hd__a22oi_1 U1525 ( .A1(oam[1523]), .A2(n490), .B1(oam[1531]), 
        .B2(n2330), .Y(n1425) );
  sky130_fd_sc_hd__nand4_1 U1526 ( .A(n1429), .B(n1430), .C(n1431), .D(n1432), 
        .Y(n1423) );
  sky130_fd_sc_hd__a22oi_1 U1527 ( .A1(oam[1411]), .A2(n2343), .B1(oam[1419]), 
        .B2(n2349), .Y(n1432) );
  sky130_fd_sc_hd__a22oi_1 U1528 ( .A1(oam[1427]), .A2(n556), .B1(oam[1435]), 
        .B2(n2360), .Y(n1431) );
  sky130_fd_sc_hd__a22oi_1 U1529 ( .A1(oam[1443]), .A2(n526), .B1(oam[1451]), 
        .B2(n567), .Y(n1430) );
  sky130_fd_sc_hd__a22oi_1 U1530 ( .A1(oam[1459]), .A2(n439), .B1(oam[1467]), 
        .B2(n2374), .Y(n1429) );
  sky130_fd_sc_hd__o21ai_1 U1531 ( .A1(n1433), .A2(n1434), .B1(n223), .Y(n1410) );
  sky130_fd_sc_hd__nand4_1 U1532 ( .A(n1435), .B(n1436), .C(n1437), .D(n1438), 
        .Y(n1434) );
  sky130_fd_sc_hd__a22oi_1 U1533 ( .A1(oam[963]), .A2(n612), .B1(oam[971]), 
        .B2(n36), .Y(n1438) );
  sky130_fd_sc_hd__a22oi_1 U1534 ( .A1(oam[979]), .A2(n2300), .B1(oam[987]), 
        .B2(n535), .Y(n1437) );
  sky130_fd_sc_hd__a22oi_1 U1535 ( .A1(oam[995]), .A2(n2306), .B1(oam[1003]), 
        .B2(n2317), .Y(n1436) );
  sky130_fd_sc_hd__a22oi_1 U1536 ( .A1(oam[1011]), .A2(n478), .B1(oam[1019]), 
        .B2(n2330), .Y(n1435) );
  sky130_fd_sc_hd__nand4_1 U1537 ( .A(n1439), .B(n1440), .C(n1441), .D(n1442), 
        .Y(n1433) );
  sky130_fd_sc_hd__a22oi_1 U1538 ( .A1(oam[899]), .A2(n2339), .B1(oam[907]), 
        .B2(n2345), .Y(n1442) );
  sky130_fd_sc_hd__a22oi_1 U1539 ( .A1(oam[915]), .A2(n562), .B1(oam[923]), 
        .B2(n2360), .Y(n1441) );
  sky130_fd_sc_hd__a22oi_1 U1540 ( .A1(oam[931]), .A2(n517), .B1(oam[939]), 
        .B2(n573), .Y(n1440) );
  sky130_fd_sc_hd__a22oi_1 U1541 ( .A1(oam[947]), .A2(n2366), .B1(oam[955]), 
        .B2(n2377), .Y(n1439) );
  sky130_fd_sc_hd__o21ai_1 U1542 ( .A1(n1443), .A2(n1444), .B1(n224), .Y(n1409) );
  sky130_fd_sc_hd__nand4_1 U1543 ( .A(n1445), .B(n1446), .C(n1447), .D(n1448), 
        .Y(n1444) );
  sky130_fd_sc_hd__a22oi_1 U1544 ( .A1(oam[451]), .A2(n599), .B1(oam[459]), 
        .B2(n66), .Y(n1448) );
  sky130_fd_sc_hd__a22oi_1 U1545 ( .A1(oam[467]), .A2(n2297), .B1(oam[475]), 
        .B2(n533), .Y(n1447) );
  sky130_fd_sc_hd__a22oi_1 U1546 ( .A1(oam[483]), .A2(n2309), .B1(oam[491]), 
        .B2(n2322), .Y(n1446) );
  sky130_fd_sc_hd__a22oi_1 U1547 ( .A1(oam[499]), .A2(n486), .B1(oam[507]), 
        .B2(n2330), .Y(n1445) );
  sky130_fd_sc_hd__nand4_1 U1548 ( .A(n1449), .B(n1450), .C(n1451), .D(n1452), 
        .Y(n1443) );
  sky130_fd_sc_hd__a22oi_1 U1549 ( .A1(oam[387]), .A2(n2336), .B1(oam[395]), 
        .B2(n2350), .Y(n1452) );
  sky130_fd_sc_hd__a22oi_1 U1550 ( .A1(oam[403]), .A2(n560), .B1(oam[411]), 
        .B2(n2360), .Y(n1451) );
  sky130_fd_sc_hd__a22oi_1 U1551 ( .A1(oam[419]), .A2(n527), .B1(oam[427]), 
        .B2(n577), .Y(n1450) );
  sky130_fd_sc_hd__a22oi_1 U1552 ( .A1(oam[435]), .A2(n2367), .B1(oam[443]), 
        .B2(n2380), .Y(n1449) );
  sky130_fd_sc_hd__o21ai_1 U1553 ( .A1(n1457), .A2(n1458), .B1(n128), .Y(n1456) );
  sky130_fd_sc_hd__nand4_1 U1554 ( .A(n1459), .B(n1460), .C(n1461), .D(n1462), 
        .Y(n1458) );
  sky130_fd_sc_hd__a22oi_1 U1555 ( .A1(oam[1619]), .A2(n2303), .B1(oam[1627]), 
        .B2(n544), .Y(n1461) );
  sky130_fd_sc_hd__a22oi_1 U1556 ( .A1(oam[1635]), .A2(n471), .B1(oam[1643]), 
        .B2(n2316), .Y(n1460) );
  sky130_fd_sc_hd__a22oi_1 U1557 ( .A1(oam[1651]), .A2(n489), .B1(oam[1659]), 
        .B2(n2330), .Y(n1459) );
  sky130_fd_sc_hd__nand4_1 U1558 ( .A(n1463), .B(n1464), .C(n1465), .D(n1466), 
        .Y(n1457) );
  sky130_fd_sc_hd__a22oi_1 U1559 ( .A1(oam[1539]), .A2(n2336), .B1(oam[1547]), 
        .B2(n2353), .Y(n1466) );
  sky130_fd_sc_hd__a22oi_1 U1560 ( .A1(oam[1555]), .A2(n561), .B1(oam[1563]), 
        .B2(n2360), .Y(n1465) );
  sky130_fd_sc_hd__a22oi_1 U1561 ( .A1(oam[1571]), .A2(n528), .B1(oam[1579]), 
        .B2(n567), .Y(n1464) );
  sky130_fd_sc_hd__a22oi_1 U1562 ( .A1(oam[1587]), .A2(n2369), .B1(oam[1595]), 
        .B2(n2379), .Y(n1463) );
  sky130_fd_sc_hd__o21ai_1 U1563 ( .A1(n1467), .A2(n1468), .B1(n130), .Y(n1455) );
  sky130_fd_sc_hd__nand4_1 U1564 ( .A(n1469), .B(n1470), .C(n1471), .D(n1472), 
        .Y(n1468) );
  sky130_fd_sc_hd__a22oi_1 U1565 ( .A1(oam[1091]), .A2(n614), .B1(oam[1099]), 
        .B2(n63), .Y(n1472) );
  sky130_fd_sc_hd__a22oi_1 U1566 ( .A1(oam[1107]), .A2(n2305), .B1(oam[1115]), 
        .B2(n533), .Y(n1471) );
  sky130_fd_sc_hd__a22oi_1 U1567 ( .A1(oam[1123]), .A2(n2308), .B1(oam[1131]), 
        .B2(n2320), .Y(n1470) );
  sky130_fd_sc_hd__a22oi_1 U1568 ( .A1(oam[1139]), .A2(n489), .B1(oam[1147]), 
        .B2(n2330), .Y(n1469) );
  sky130_fd_sc_hd__nand4_1 U1569 ( .A(n1473), .B(n1474), .C(n1475), .D(n1476), 
        .Y(n1467) );
  sky130_fd_sc_hd__a22oi_1 U1570 ( .A1(oam[1027]), .A2(n2337), .B1(oam[1035]), 
        .B2(n2352), .Y(n1476) );
  sky130_fd_sc_hd__a22oi_1 U1571 ( .A1(oam[1043]), .A2(n563), .B1(oam[1051]), 
        .B2(n2360), .Y(n1475) );
  sky130_fd_sc_hd__a22oi_1 U1572 ( .A1(oam[1059]), .A2(n518), .B1(oam[1067]), 
        .B2(n566), .Y(n1474) );
  sky130_fd_sc_hd__a22oi_1 U1573 ( .A1(oam[1075]), .A2(n2365), .B1(oam[1083]), 
        .B2(n2375), .Y(n1473) );
  sky130_fd_sc_hd__o21ai_1 U1574 ( .A1(n1477), .A2(n1478), .B1(n129), .Y(n1454) );
  sky130_fd_sc_hd__nand4_1 U1575 ( .A(n1479), .B(n1480), .C(n1481), .D(n1482), 
        .Y(n1478) );
  sky130_fd_sc_hd__a22oi_1 U1576 ( .A1(oam[595]), .A2(n2304), .B1(oam[603]), 
        .B2(n534), .Y(n1481) );
  sky130_fd_sc_hd__a22oi_1 U1577 ( .A1(oam[611]), .A2(n2312), .B1(oam[619]), 
        .B2(n2324), .Y(n1480) );
  sky130_fd_sc_hd__a22oi_1 U1578 ( .A1(oam[627]), .A2(n479), .B1(oam[635]), 
        .B2(n2330), .Y(n1479) );
  sky130_fd_sc_hd__nand4_1 U1579 ( .A(n1483), .B(n1484), .C(n1485), .D(n1486), 
        .Y(n1477) );
  sky130_fd_sc_hd__a22oi_1 U1580 ( .A1(oam[515]), .A2(n2337), .B1(oam[523]), 
        .B2(n2346), .Y(n1486) );
  sky130_fd_sc_hd__a22oi_1 U1581 ( .A1(oam[531]), .A2(n551), .B1(oam[539]), 
        .B2(n2360), .Y(n1485) );
  sky130_fd_sc_hd__a22oi_1 U1582 ( .A1(oam[547]), .A2(n518), .B1(oam[555]), 
        .B2(n575), .Y(n1484) );
  sky130_fd_sc_hd__a22oi_1 U1583 ( .A1(oam[563]), .A2(n2371), .B1(oam[571]), 
        .B2(n2382), .Y(n1483) );
  sky130_fd_sc_hd__o21ai_1 U1584 ( .A1(n1487), .A2(n1488), .B1(n231), .Y(n1453) );
  sky130_fd_sc_hd__nand4_1 U1585 ( .A(n1489), .B(n1490), .C(n1491), .D(n1492), 
        .Y(n1488) );
  sky130_fd_sc_hd__a22oi_1 U1586 ( .A1(oam[67]), .A2(n591), .B1(oam[75]), .B2(
        n55), .Y(n1492) );
  sky130_fd_sc_hd__a22oi_1 U1587 ( .A1(oam[83]), .A2(n2296), .B1(oam[91]), 
        .B2(n543), .Y(n1491) );
  sky130_fd_sc_hd__a22oi_1 U1588 ( .A1(oam[99]), .A2(n472), .B1(oam[107]), 
        .B2(n2317), .Y(n1490) );
  sky130_fd_sc_hd__a22oi_1 U1589 ( .A1(oam[115]), .A2(n489), .B1(oam[123]), 
        .B2(n2330), .Y(n1489) );
  sky130_fd_sc_hd__nand4_1 U1590 ( .A(n1493), .B(n1494), .C(n1495), .D(n1496), 
        .Y(n1487) );
  sky130_fd_sc_hd__a22oi_1 U1591 ( .A1(oam[3]), .A2(n2336), .B1(oam[11]), .B2(
        n2347), .Y(n1496) );
  sky130_fd_sc_hd__a22oi_1 U1592 ( .A1(oam[19]), .A2(n551), .B1(oam[27]), .B2(
        n2360), .Y(n1495) );
  sky130_fd_sc_hd__a22oi_1 U1593 ( .A1(oam[35]), .A2(n530), .B1(oam[43]), .B2(
        n567), .Y(n1494) );
  sky130_fd_sc_hd__a22oi_1 U1594 ( .A1(oam[51]), .A2(n439), .B1(oam[59]), .B2(
        n2375), .Y(n1493) );
  sky130_fd_sc_hd__o21ai_1 U1595 ( .A1(n1501), .A2(n1502), .B1(n127), .Y(n1500) );
  sky130_fd_sc_hd__nand4_1 U1596 ( .A(n1503), .B(n1504), .C(n1505), .D(n1506), 
        .Y(n1502) );
  sky130_fd_sc_hd__a22oi_1 U1597 ( .A1(oam[1747]), .A2(n2305), .B1(oam[1755]), 
        .B2(n542), .Y(n1505) );
  sky130_fd_sc_hd__a22oi_1 U1598 ( .A1(oam[1763]), .A2(n2312), .B1(oam[1771]), 
        .B2(n2324), .Y(n1504) );
  sky130_fd_sc_hd__nand4_1 U1599 ( .A(n1508), .B(n1507), .C(n1509), .D(n1510), 
        .Y(n1501) );
  sky130_fd_sc_hd__a22oi_1 U1600 ( .A1(oam[1667]), .A2(n2344), .B1(oam[1675]), 
        .B2(n2346), .Y(n1510) );
  sky130_fd_sc_hd__a22oi_1 U1601 ( .A1(oam[1683]), .A2(n560), .B1(oam[1691]), 
        .B2(n2360), .Y(n1509) );
  sky130_fd_sc_hd__a22oi_1 U1602 ( .A1(oam[1699]), .A2(n517), .B1(oam[1707]), 
        .B2(n567), .Y(n1508) );
  sky130_fd_sc_hd__a22oi_1 U1603 ( .A1(oam[1715]), .A2(n2371), .B1(oam[1723]), 
        .B2(n2380), .Y(n1507) );
  sky130_fd_sc_hd__o21ai_1 U1604 ( .A1(n1511), .A2(n1512), .B1(n220), .Y(n1499) );
  sky130_fd_sc_hd__nand4_1 U1605 ( .A(n1513), .B(n1514), .C(n1515), .D(n1516), 
        .Y(n1512) );
  sky130_fd_sc_hd__a22oi_1 U1606 ( .A1(oam[1235]), .A2(n2298), .B1(oam[1243]), 
        .B2(n544), .Y(n1515) );
  sky130_fd_sc_hd__a22oi_1 U1607 ( .A1(oam[1251]), .A2(n2310), .B1(oam[1259]), 
        .B2(n2319), .Y(n1514) );
  sky130_fd_sc_hd__a22oi_1 U1608 ( .A1(oam[1267]), .A2(n478), .B1(oam[1275]), 
        .B2(n2330), .Y(n1513) );
  sky130_fd_sc_hd__nand4_1 U1609 ( .A(n1517), .B(n1518), .C(n1519), .D(n1520), 
        .Y(n1511) );
  sky130_fd_sc_hd__a22oi_1 U1610 ( .A1(oam[1155]), .A2(n2338), .B1(oam[1163]), 
        .B2(n2354), .Y(n1520) );
  sky130_fd_sc_hd__a22oi_1 U1611 ( .A1(oam[1171]), .A2(n549), .B1(oam[1179]), 
        .B2(n2360), .Y(n1519) );
  sky130_fd_sc_hd__a22oi_1 U1612 ( .A1(oam[1203]), .A2(n2370), .B1(oam[1211]), 
        .B2(n2378), .Y(n1517) );
  sky130_fd_sc_hd__o21ai_1 U1613 ( .A1(n1521), .A2(n1522), .B1(n222), .Y(n1498) );
  sky130_fd_sc_hd__nand4_1 U1614 ( .A(n1523), .B(n1524), .C(n1525), .D(n1526), 
        .Y(n1522) );
  sky130_fd_sc_hd__a22oi_1 U1615 ( .A1(oam[707]), .A2(n609), .B1(oam[715]), 
        .B2(n85), .Y(n1526) );
  sky130_fd_sc_hd__a22oi_1 U1616 ( .A1(oam[723]), .A2(n2296), .B1(oam[731]), 
        .B2(n534), .Y(n1525) );
  sky130_fd_sc_hd__a22oi_1 U1617 ( .A1(oam[739]), .A2(n2306), .B1(oam[747]), 
        .B2(n2323), .Y(n1524) );
  sky130_fd_sc_hd__a22oi_1 U1618 ( .A1(oam[755]), .A2(n478), .B1(oam[763]), 
        .B2(n2330), .Y(n1523) );
  sky130_fd_sc_hd__nand4_1 U1619 ( .A(n1528), .B(n1527), .C(n1529), .D(n1530), 
        .Y(n1521) );
  sky130_fd_sc_hd__a22oi_1 U1620 ( .A1(oam[643]), .A2(n2343), .B1(oam[651]), 
        .B2(n2346), .Y(n1530) );
  sky130_fd_sc_hd__a22oi_1 U1621 ( .A1(oam[659]), .A2(n562), .B1(oam[667]), 
        .B2(n2360), .Y(n1529) );
  sky130_fd_sc_hd__a22oi_1 U1622 ( .A1(oam[675]), .A2(n528), .B1(oam[683]), 
        .B2(n568), .Y(n1528) );
  sky130_fd_sc_hd__a22oi_1 U1623 ( .A1(oam[691]), .A2(n2368), .B1(oam[699]), 
        .B2(n2375), .Y(n1527) );
  sky130_fd_sc_hd__o21ai_1 U1624 ( .A1(n1531), .A2(n1532), .B1(n226), .Y(n1497) );
  sky130_fd_sc_hd__nand4_1 U1625 ( .A(n1533), .B(n1534), .C(n1535), .D(n1536), 
        .Y(n1532) );
  sky130_fd_sc_hd__a22oi_1 U1626 ( .A1(oam[211]), .A2(n2296), .B1(oam[219]), 
        .B2(n533), .Y(n1535) );
  sky130_fd_sc_hd__a22oi_1 U1627 ( .A1(oam[227]), .A2(n2308), .B1(oam[235]), 
        .B2(n2321), .Y(n1534) );
  sky130_fd_sc_hd__a22oi_1 U1628 ( .A1(oam[243]), .A2(n480), .B1(oam[251]), 
        .B2(n2330), .Y(n1533) );
  sky130_fd_sc_hd__nand4_1 U1629 ( .A(n1537), .B(n1538), .C(n1539), .D(n1540), 
        .Y(n1531) );
  sky130_fd_sc_hd__a22oi_1 U1630 ( .A1(oam[131]), .A2(n2338), .B1(oam[139]), 
        .B2(n2347), .Y(n1540) );
  sky130_fd_sc_hd__a22oi_1 U1631 ( .A1(oam[147]), .A2(n559), .B1(oam[155]), 
        .B2(n2360), .Y(n1539) );
  sky130_fd_sc_hd__a22oi_1 U1632 ( .A1(oam[163]), .A2(n519), .B1(oam[171]), 
        .B2(n572), .Y(n1538) );
  sky130_fd_sc_hd__a22oi_1 U1633 ( .A1(oam[179]), .A2(n2368), .B1(oam[187]), 
        .B2(n2376), .Y(n1537) );
  sky130_fd_sc_hd__o21ai_1 U1634 ( .A1(n1545), .A2(n1546), .B1(n103), .Y(n1544) );
  sky130_fd_sc_hd__nand4_1 U1635 ( .A(n1547), .B(n1548), .C(n1549), .D(n1550), 
        .Y(n1546) );
  sky130_fd_sc_hd__a22oi_1 U1636 ( .A1(oam[1860]), .A2(n600), .B1(oam[1868]), 
        .B2(n88), .Y(n1550) );
  sky130_fd_sc_hd__a22oi_1 U1637 ( .A1(oam[1876]), .A2(n2299), .B1(oam[1884]), 
        .B2(n541), .Y(n1549) );
  sky130_fd_sc_hd__a22oi_1 U1638 ( .A1(oam[1892]), .A2(n2314), .B1(oam[1900]), 
        .B2(n445), .Y(n1548) );
  sky130_fd_sc_hd__a22oi_1 U1639 ( .A1(oam[1908]), .A2(n479), .B1(oam[1916]), 
        .B2(n2330), .Y(n1547) );
  sky130_fd_sc_hd__nand4_1 U1640 ( .A(n1551), .B(n1552), .C(n1553), .D(n1554), 
        .Y(n1545) );
  sky130_fd_sc_hd__a22oi_1 U1641 ( .A1(oam[1796]), .A2(n2344), .B1(oam[1804]), 
        .B2(n2346), .Y(n1554) );
  sky130_fd_sc_hd__a22oi_1 U1642 ( .A1(oam[1812]), .A2(n563), .B1(oam[1820]), 
        .B2(n2360), .Y(n1553) );
  sky130_fd_sc_hd__a22oi_1 U1643 ( .A1(oam[1828]), .A2(n517), .B1(oam[1836]), 
        .B2(n567), .Y(n1552) );
  sky130_fd_sc_hd__a22oi_1 U1644 ( .A1(oam[1844]), .A2(n2365), .B1(oam[1852]), 
        .B2(n2375), .Y(n1551) );
  sky130_fd_sc_hd__o21ai_1 U1645 ( .A1(n1555), .A2(n1556), .B1(n228), .Y(n1543) );
  sky130_fd_sc_hd__nand4_1 U1646 ( .A(n1557), .B(n1558), .C(n1559), .D(n1560), 
        .Y(n1556) );
  sky130_fd_sc_hd__a22oi_1 U1647 ( .A1(oam[1348]), .A2(n599), .B1(oam[1356]), 
        .B2(n80), .Y(n1560) );
  sky130_fd_sc_hd__a22oi_1 U1648 ( .A1(oam[1364]), .A2(n2305), .B1(oam[1372]), 
        .B2(n544), .Y(n1559) );
  sky130_fd_sc_hd__a22oi_1 U1649 ( .A1(oam[1380]), .A2(n2313), .B1(oam[1388]), 
        .B2(n2323), .Y(n1558) );
  sky130_fd_sc_hd__a22oi_1 U1650 ( .A1(oam[1396]), .A2(n482), .B1(oam[1404]), 
        .B2(n2329), .Y(n1557) );
  sky130_fd_sc_hd__nand4_1 U1651 ( .A(n1561), .B(n1562), .C(n1563), .D(n1564), 
        .Y(n1555) );
  sky130_fd_sc_hd__a22oi_1 U1652 ( .A1(oam[1284]), .A2(n2339), .B1(oam[1292]), 
        .B2(n2348), .Y(n1564) );
  sky130_fd_sc_hd__a22oi_1 U1653 ( .A1(oam[1300]), .A2(n562), .B1(oam[1308]), 
        .B2(n2359), .Y(n1563) );
  sky130_fd_sc_hd__a22oi_1 U1654 ( .A1(oam[1316]), .A2(n518), .B1(oam[1324]), 
        .B2(n567), .Y(n1562) );
  sky130_fd_sc_hd__a22oi_1 U1655 ( .A1(oam[1332]), .A2(n2367), .B1(oam[1340]), 
        .B2(n2377), .Y(n1561) );
  sky130_fd_sc_hd__o21ai_1 U1656 ( .A1(n1565), .A2(n1566), .B1(n227), .Y(n1542) );
  sky130_fd_sc_hd__nand4_1 U1657 ( .A(n1567), .B(n1568), .C(n1569), .D(n1570), 
        .Y(n1566) );
  sky130_fd_sc_hd__a22oi_1 U1658 ( .A1(oam[852]), .A2(n2304), .B1(oam[860]), 
        .B2(n534), .Y(n1569) );
  sky130_fd_sc_hd__a22oi_1 U1659 ( .A1(oam[868]), .A2(n2311), .B1(oam[876]), 
        .B2(n2315), .Y(n1568) );
  sky130_fd_sc_hd__a22oi_1 U1660 ( .A1(oam[884]), .A2(n481), .B1(oam[892]), 
        .B2(n2329), .Y(n1567) );
  sky130_fd_sc_hd__nand4_1 U1661 ( .A(n1571), .B(n1572), .C(n1573), .D(n1574), 
        .Y(n1565) );
  sky130_fd_sc_hd__a22oi_1 U1662 ( .A1(oam[772]), .A2(n2342), .B1(oam[780]), 
        .B2(n2349), .Y(n1574) );
  sky130_fd_sc_hd__a22oi_1 U1663 ( .A1(oam[788]), .A2(n556), .B1(oam[796]), 
        .B2(n2359), .Y(n1573) );
  sky130_fd_sc_hd__a22oi_1 U1664 ( .A1(oam[804]), .A2(n525), .B1(oam[812]), 
        .B2(n573), .Y(n1572) );
  sky130_fd_sc_hd__a22oi_1 U1665 ( .A1(oam[820]), .A2(n2367), .B1(oam[828]), 
        .B2(n2374), .Y(n1571) );
  sky130_fd_sc_hd__o21ai_1 U1666 ( .A1(n1575), .A2(n1576), .B1(n229), .Y(n1541) );
  sky130_fd_sc_hd__nand4_1 U1667 ( .A(n1577), .B(n1578), .C(n1579), .D(n1580), 
        .Y(n1576) );
  sky130_fd_sc_hd__a22oi_1 U1668 ( .A1(oam[324]), .A2(n609), .B1(oam[332]), 
        .B2(n78), .Y(n1580) );
  sky130_fd_sc_hd__a22oi_1 U1669 ( .A1(oam[340]), .A2(n2296), .B1(oam[348]), 
        .B2(n545), .Y(n1579) );
  sky130_fd_sc_hd__a22oi_1 U1670 ( .A1(oam[356]), .A2(n2310), .B1(oam[364]), 
        .B2(n2316), .Y(n1578) );
  sky130_fd_sc_hd__a22oi_1 U1671 ( .A1(oam[372]), .A2(n480), .B1(oam[380]), 
        .B2(n2329), .Y(n1577) );
  sky130_fd_sc_hd__nand4_1 U1672 ( .A(n1581), .B(n1582), .C(n1583), .D(n1584), 
        .Y(n1575) );
  sky130_fd_sc_hd__a22oi_1 U1673 ( .A1(oam[260]), .A2(n2344), .B1(oam[268]), 
        .B2(n2348), .Y(n1584) );
  sky130_fd_sc_hd__a22oi_1 U1674 ( .A1(oam[276]), .A2(n563), .B1(oam[284]), 
        .B2(n2359), .Y(n1583) );
  sky130_fd_sc_hd__a22oi_1 U1675 ( .A1(oam[292]), .A2(n526), .B1(oam[300]), 
        .B2(n576), .Y(n1582) );
  sky130_fd_sc_hd__a22oi_1 U1676 ( .A1(oam[308]), .A2(n439), .B1(oam[316]), 
        .B2(n2379), .Y(n1581) );
  sky130_fd_sc_hd__o21ai_1 U1677 ( .A1(n1589), .A2(n1590), .B1(n219), .Y(n1588) );
  sky130_fd_sc_hd__nand4_1 U1678 ( .A(n1591), .B(n1592), .C(n1593), .D(n1594), 
        .Y(n1590) );
  sky130_fd_sc_hd__a22oi_1 U1679 ( .A1(oam[1988]), .A2(n600), .B1(oam[1996]), 
        .B2(n84), .Y(n1594) );
  sky130_fd_sc_hd__a22oi_1 U1680 ( .A1(oam[2004]), .A2(n2301), .B1(oam[2012]), 
        .B2(n534), .Y(n1593) );
  sky130_fd_sc_hd__a22oi_1 U1681 ( .A1(oam[2020]), .A2(n2306), .B1(oam[2028]), 
        .B2(n2319), .Y(n1592) );
  sky130_fd_sc_hd__a22oi_1 U1682 ( .A1(oam[2036]), .A2(n479), .B1(oam[2044]), 
        .B2(n2329), .Y(n1591) );
  sky130_fd_sc_hd__nand4_1 U1683 ( .A(n1595), .B(n1596), .C(n1597), .D(n1598), 
        .Y(n1589) );
  sky130_fd_sc_hd__a22oi_1 U1684 ( .A1(oam[1924]), .A2(n2336), .B1(oam[1932]), 
        .B2(n2351), .Y(n1598) );
  sky130_fd_sc_hd__a22oi_1 U1685 ( .A1(oam[1940]), .A2(n551), .B1(oam[1948]), 
        .B2(n2359), .Y(n1597) );
  sky130_fd_sc_hd__a22oi_1 U1686 ( .A1(oam[1956]), .A2(n528), .B1(oam[1964]), 
        .B2(n572), .Y(n1596) );
  sky130_fd_sc_hd__a22oi_1 U1687 ( .A1(oam[1972]), .A2(n2368), .B1(oam[1980]), 
        .B2(n2379), .Y(n1595) );
  sky130_fd_sc_hd__o21ai_1 U1688 ( .A1(n1599), .A2(n1600), .B1(n221), .Y(n1587) );
  sky130_fd_sc_hd__nand4_1 U1689 ( .A(n1601), .B(n1602), .C(n1603), .D(n1604), 
        .Y(n1600) );
  sky130_fd_sc_hd__a22oi_1 U1690 ( .A1(oam[1476]), .A2(n604), .B1(oam[1484]), 
        .B2(n62), .Y(n1604) );
  sky130_fd_sc_hd__a22oi_1 U1691 ( .A1(oam[1492]), .A2(n2300), .B1(oam[1500]), 
        .B2(n543), .Y(n1603) );
  sky130_fd_sc_hd__a22oi_1 U1692 ( .A1(oam[1508]), .A2(n471), .B1(oam[1516]), 
        .B2(n2321), .Y(n1602) );
  sky130_fd_sc_hd__a22oi_1 U1693 ( .A1(oam[1524]), .A2(n479), .B1(oam[1532]), 
        .B2(n2329), .Y(n1601) );
  sky130_fd_sc_hd__nand4_1 U1694 ( .A(n1605), .B(n1606), .C(n1607), .D(n1608), 
        .Y(n1599) );
  sky130_fd_sc_hd__a22oi_1 U1695 ( .A1(n2338), .A2(oam[1412]), .B1(oam[1420]), 
        .B2(n2346), .Y(n1608) );
  sky130_fd_sc_hd__a22oi_1 U1696 ( .A1(oam[1428]), .A2(n556), .B1(oam[1436]), 
        .B2(n2359), .Y(n1607) );
  sky130_fd_sc_hd__a22oi_1 U1697 ( .A1(oam[1444]), .A2(n530), .B1(oam[1452]), 
        .B2(n577), .Y(n1606) );
  sky130_fd_sc_hd__a22oi_1 U1698 ( .A1(oam[1460]), .A2(n2366), .B1(oam[1468]), 
        .B2(n2383), .Y(n1605) );
  sky130_fd_sc_hd__o21ai_1 U1699 ( .A1(n1609), .A2(n1610), .B1(n223), .Y(n1586) );
  sky130_fd_sc_hd__nand4_1 U1700 ( .A(n1614), .B(n1612), .C(n1613), .D(n1611), 
        .Y(n1610) );
  sky130_fd_sc_hd__a22oi_1 U1701 ( .A1(oam[964]), .A2(n607), .B1(oam[972]), 
        .B2(n70), .Y(n1614) );
  sky130_fd_sc_hd__a22oi_1 U1702 ( .A1(oam[980]), .A2(n2305), .B1(oam[988]), 
        .B2(n540), .Y(n1613) );
  sky130_fd_sc_hd__a22oi_1 U1703 ( .A1(oam[996]), .A2(n2307), .B1(oam[1004]), 
        .B2(n2320), .Y(n1612) );
  sky130_fd_sc_hd__a22oi_1 U1704 ( .A1(oam[1012]), .A2(n486), .B1(oam[1020]), 
        .B2(n2329), .Y(n1611) );
  sky130_fd_sc_hd__nand4_1 U1705 ( .A(n1615), .B(n1616), .C(n1617), .D(n1618), 
        .Y(n1609) );
  sky130_fd_sc_hd__a22oi_1 U1706 ( .A1(oam[900]), .A2(n2342), .B1(oam[908]), 
        .B2(n2351), .Y(n1618) );
  sky130_fd_sc_hd__a22oi_1 U1707 ( .A1(oam[916]), .A2(n561), .B1(oam[924]), 
        .B2(n2359), .Y(n1617) );
  sky130_fd_sc_hd__a22oi_1 U1708 ( .A1(oam[932]), .A2(n526), .B1(oam[940]), 
        .B2(n566), .Y(n1616) );
  sky130_fd_sc_hd__a22oi_1 U1709 ( .A1(oam[948]), .A2(n2373), .B1(oam[956]), 
        .B2(n2381), .Y(n1615) );
  sky130_fd_sc_hd__o21ai_1 U1710 ( .A1(n1619), .A2(n1620), .B1(n224), .Y(n1585) );
  sky130_fd_sc_hd__nand4_1 U1711 ( .A(n1621), .B(n1622), .C(n1623), .D(n1624), 
        .Y(n1620) );
  sky130_fd_sc_hd__a22oi_1 U1712 ( .A1(oam[452]), .A2(n620), .B1(oam[460]), 
        .B2(n51), .Y(n1624) );
  sky130_fd_sc_hd__a22oi_1 U1713 ( .A1(oam[468]), .A2(n2300), .B1(oam[476]), 
        .B2(n545), .Y(n1623) );
  sky130_fd_sc_hd__a22oi_1 U1714 ( .A1(oam[484]), .A2(n472), .B1(oam[492]), 
        .B2(n2319), .Y(n1622) );
  sky130_fd_sc_hd__a22oi_1 U1715 ( .A1(oam[500]), .A2(n481), .B1(oam[508]), 
        .B2(n2329), .Y(n1621) );
  sky130_fd_sc_hd__nand4_1 U1716 ( .A(n1625), .B(n1626), .C(n1627), .D(n1628), 
        .Y(n1619) );
  sky130_fd_sc_hd__a22oi_1 U1717 ( .A1(oam[388]), .A2(n2344), .B1(oam[396]), 
        .B2(n2351), .Y(n1628) );
  sky130_fd_sc_hd__a22oi_1 U1718 ( .A1(oam[404]), .A2(n549), .B1(oam[412]), 
        .B2(n2359), .Y(n1627) );
  sky130_fd_sc_hd__a22oi_1 U1719 ( .A1(oam[420]), .A2(n527), .B1(oam[428]), 
        .B2(n574), .Y(n1626) );
  sky130_fd_sc_hd__a22oi_1 U1720 ( .A1(oam[436]), .A2(n2366), .B1(oam[444]), 
        .B2(n2376), .Y(n1625) );
  sky130_fd_sc_hd__o21ai_1 U1721 ( .A1(n1633), .A2(n1634), .B1(n128), .Y(n1632) );
  sky130_fd_sc_hd__nand4_1 U1722 ( .A(n1635), .B(n1636), .C(n1637), .D(n1638), 
        .Y(n1634) );
  sky130_fd_sc_hd__a22oi_1 U1723 ( .A1(oam[1604]), .A2(n605), .B1(oam[1612]), 
        .B2(n87), .Y(n1638) );
  sky130_fd_sc_hd__a22oi_1 U1724 ( .A1(oam[1620]), .A2(n2305), .B1(oam[1628]), 
        .B2(n535), .Y(n1637) );
  sky130_fd_sc_hd__a22oi_1 U1725 ( .A1(oam[1636]), .A2(n2312), .B1(oam[1644]), 
        .B2(n2316), .Y(n1636) );
  sky130_fd_sc_hd__a22oi_1 U1726 ( .A1(oam[1652]), .A2(n480), .B1(oam[1660]), 
        .B2(n2329), .Y(n1635) );
  sky130_fd_sc_hd__nand4_1 U1727 ( .A(n1639), .B(n1640), .C(n1641), .D(n1642), 
        .Y(n1633) );
  sky130_fd_sc_hd__a22oi_1 U1728 ( .A1(oam[1540]), .A2(n2335), .B1(oam[1548]), 
        .B2(n2345), .Y(n1642) );
  sky130_fd_sc_hd__a22oi_1 U1729 ( .A1(oam[1556]), .A2(n551), .B1(oam[1564]), 
        .B2(n2359), .Y(n1641) );
  sky130_fd_sc_hd__a22oi_1 U1730 ( .A1(oam[1572]), .A2(n519), .B1(oam[1580]), 
        .B2(n577), .Y(n1640) );
  sky130_fd_sc_hd__a22oi_1 U1731 ( .A1(oam[1588]), .A2(n2366), .B1(oam[1596]), 
        .B2(n2379), .Y(n1639) );
  sky130_fd_sc_hd__o21ai_1 U1732 ( .A1(n1643), .A2(n1644), .B1(n130), .Y(n1631) );
  sky130_fd_sc_hd__nand4_1 U1733 ( .A(n1645), .B(n1646), .C(n1647), .D(n1648), 
        .Y(n1644) );
  sky130_fd_sc_hd__a22oi_1 U1734 ( .A1(oam[1092]), .A2(n616), .B1(oam[1100]), 
        .B2(n31), .Y(n1648) );
  sky130_fd_sc_hd__a22oi_1 U1735 ( .A1(oam[1108]), .A2(n2299), .B1(oam[1116]), 
        .B2(n542), .Y(n1647) );
  sky130_fd_sc_hd__a22oi_1 U1736 ( .A1(oam[1124]), .A2(n2313), .B1(oam[1132]), 
        .B2(n2315), .Y(n1646) );
  sky130_fd_sc_hd__a22oi_1 U1737 ( .A1(oam[1140]), .A2(n482), .B1(oam[1148]), 
        .B2(n2329), .Y(n1645) );
  sky130_fd_sc_hd__nand4_1 U1738 ( .A(n1649), .B(n1650), .C(n1651), .D(n1652), 
        .Y(n1643) );
  sky130_fd_sc_hd__a22oi_1 U1739 ( .A1(oam[1028]), .A2(n2343), .B1(oam[1036]), 
        .B2(n2348), .Y(n1652) );
  sky130_fd_sc_hd__a22oi_1 U1740 ( .A1(oam[1044]), .A2(n562), .B1(oam[1052]), 
        .B2(n2359), .Y(n1651) );
  sky130_fd_sc_hd__a22oi_1 U1741 ( .A1(oam[1060]), .A2(n526), .B1(oam[1068]), 
        .B2(n567), .Y(n1650) );
  sky130_fd_sc_hd__a22oi_1 U1742 ( .A1(oam[1076]), .A2(n439), .B1(oam[1084]), 
        .B2(n2381), .Y(n1649) );
  sky130_fd_sc_hd__o21ai_1 U1743 ( .A1(n1653), .A2(n1654), .B1(n129), .Y(n1630) );
  sky130_fd_sc_hd__nand4_1 U1744 ( .A(n1655), .B(n1656), .C(n1657), .D(n1658), 
        .Y(n1654) );
  sky130_fd_sc_hd__a22oi_1 U1745 ( .A1(oam[580]), .A2(n619), .B1(oam[588]), 
        .B2(n39), .Y(n1658) );
  sky130_fd_sc_hd__a22oi_1 U1746 ( .A1(oam[596]), .A2(n2300), .B1(oam[604]), 
        .B2(n534), .Y(n1657) );
  sky130_fd_sc_hd__a22oi_1 U1747 ( .A1(oam[612]), .A2(n471), .B1(oam[620]), 
        .B2(n2323), .Y(n1656) );
  sky130_fd_sc_hd__a22oi_1 U1748 ( .A1(oam[628]), .A2(n481), .B1(oam[636]), 
        .B2(n2329), .Y(n1655) );
  sky130_fd_sc_hd__nand4_1 U1749 ( .A(n1659), .B(n1660), .C(n1661), .D(n1662), 
        .Y(n1653) );
  sky130_fd_sc_hd__a22oi_1 U1750 ( .A1(oam[516]), .A2(n2340), .B1(oam[524]), 
        .B2(n2351), .Y(n1662) );
  sky130_fd_sc_hd__a22oi_1 U1751 ( .A1(oam[532]), .A2(n550), .B1(oam[540]), 
        .B2(n2359), .Y(n1661) );
  sky130_fd_sc_hd__a22oi_1 U1752 ( .A1(oam[548]), .A2(n528), .B1(oam[556]), 
        .B2(n576), .Y(n1660) );
  sky130_fd_sc_hd__a22oi_1 U1753 ( .A1(oam[564]), .A2(n2371), .B1(oam[572]), 
        .B2(n2375), .Y(n1659) );
  sky130_fd_sc_hd__o21ai_1 U1754 ( .A1(n1663), .A2(n1664), .B1(n231), .Y(n1629) );
  sky130_fd_sc_hd__nand4_1 U1755 ( .A(n1665), .B(n1666), .C(n1667), .D(n1668), 
        .Y(n1664) );
  sky130_fd_sc_hd__a22oi_1 U1756 ( .A1(oam[68]), .A2(n621), .B1(oam[76]), .B2(
        n19), .Y(n1668) );
  sky130_fd_sc_hd__a22oi_1 U1757 ( .A1(oam[84]), .A2(n2297), .B1(oam[92]), 
        .B2(n533), .Y(n1667) );
  sky130_fd_sc_hd__a22oi_1 U1758 ( .A1(oam[100]), .A2(n2312), .B1(oam[108]), 
        .B2(n2322), .Y(n1666) );
  sky130_fd_sc_hd__a22oi_1 U1759 ( .A1(oam[116]), .A2(n487), .B1(oam[124]), 
        .B2(n2329), .Y(n1665) );
  sky130_fd_sc_hd__nand4_1 U1760 ( .A(n1669), .B(n1670), .C(n1671), .D(n1672), 
        .Y(n1663) );
  sky130_fd_sc_hd__a22oi_1 U1761 ( .A1(oam[4]), .A2(n2341), .B1(oam[12]), .B2(
        n2350), .Y(n1672) );
  sky130_fd_sc_hd__a22oi_1 U1762 ( .A1(oam[20]), .A2(n558), .B1(oam[28]), .B2(
        n2359), .Y(n1671) );
  sky130_fd_sc_hd__a22oi_1 U1763 ( .A1(oam[36]), .A2(n524), .B1(oam[44]), .B2(
        n566), .Y(n1670) );
  sky130_fd_sc_hd__a22oi_1 U1764 ( .A1(oam[52]), .A2(n2369), .B1(oam[60]), 
        .B2(n2375), .Y(n1669) );
  sky130_fd_sc_hd__o21ai_1 U1765 ( .A1(n1677), .A2(n1678), .B1(n127), .Y(n1676) );
  sky130_fd_sc_hd__nand4_1 U1766 ( .A(n1679), .B(n1680), .C(n1681), .D(n1682), 
        .Y(n1678) );
  sky130_fd_sc_hd__a22oi_1 U1767 ( .A1(oam[1748]), .A2(n2299), .B1(oam[1756]), 
        .B2(n535), .Y(n1681) );
  sky130_fd_sc_hd__a22oi_1 U1768 ( .A1(oam[1764]), .A2(n2310), .B1(oam[1772]), 
        .B2(n2316), .Y(n1680) );
  sky130_fd_sc_hd__a22oi_1 U1769 ( .A1(oam[1780]), .A2(n490), .B1(oam[1788]), 
        .B2(n2329), .Y(n1679) );
  sky130_fd_sc_hd__nand4_1 U1770 ( .A(n1683), .B(n1684), .C(n1685), .D(n1686), 
        .Y(n1677) );
  sky130_fd_sc_hd__a22oi_1 U1771 ( .A1(oam[1668]), .A2(n2344), .B1(oam[1676]), 
        .B2(n2352), .Y(n1686) );
  sky130_fd_sc_hd__a22oi_1 U1772 ( .A1(oam[1684]), .A2(n559), .B1(oam[1692]), 
        .B2(n2359), .Y(n1685) );
  sky130_fd_sc_hd__a22oi_1 U1773 ( .A1(oam[1700]), .A2(n526), .B1(oam[1708]), 
        .B2(n566), .Y(n1684) );
  sky130_fd_sc_hd__a22oi_1 U1774 ( .A1(oam[1716]), .A2(n439), .B1(oam[1724]), 
        .B2(n2376), .Y(n1683) );
  sky130_fd_sc_hd__o21ai_1 U1775 ( .A1(n1687), .A2(n1688), .B1(n220), .Y(n1675) );
  sky130_fd_sc_hd__nand4_1 U1776 ( .A(n1689), .B(n1690), .C(n1691), .D(n1692), 
        .Y(n1688) );
  sky130_fd_sc_hd__a22oi_1 U1777 ( .A1(oam[1220]), .A2(n605), .B1(oam[1228]), 
        .B2(n73), .Y(n1692) );
  sky130_fd_sc_hd__a22oi_1 U1778 ( .A1(oam[1236]), .A2(n2304), .B1(oam[1244]), 
        .B2(n544), .Y(n1691) );
  sky130_fd_sc_hd__a22oi_1 U1779 ( .A1(oam[1252]), .A2(n2312), .B1(oam[1260]), 
        .B2(n2317), .Y(n1690) );
  sky130_fd_sc_hd__a22oi_1 U1780 ( .A1(oam[1268]), .A2(n487), .B1(oam[1276]), 
        .B2(n2329), .Y(n1689) );
  sky130_fd_sc_hd__nand4_1 U1781 ( .A(n1693), .B(n1694), .C(n1695), .D(n1696), 
        .Y(n1687) );
  sky130_fd_sc_hd__a22oi_1 U1782 ( .A1(oam[1156]), .A2(n2344), .B1(oam[1164]), 
        .B2(n2354), .Y(n1696) );
  sky130_fd_sc_hd__a22oi_1 U1783 ( .A1(oam[1172]), .A2(n548), .B1(oam[1180]), 
        .B2(n2359), .Y(n1695) );
  sky130_fd_sc_hd__a22oi_1 U1784 ( .A1(oam[1188]), .A2(n530), .B1(oam[1196]), 
        .B2(n573), .Y(n1694) );
  sky130_fd_sc_hd__a22oi_1 U1785 ( .A1(oam[1204]), .A2(n2366), .B1(oam[1212]), 
        .B2(n2377), .Y(n1693) );
  sky130_fd_sc_hd__o21ai_1 U1786 ( .A1(n1697), .A2(n1698), .B1(n222), .Y(n1674) );
  sky130_fd_sc_hd__nand4_1 U1787 ( .A(n1699), .B(n1700), .C(n1701), .D(n1702), 
        .Y(n1698) );
  sky130_fd_sc_hd__a22oi_1 U1788 ( .A1(oam[708]), .A2(n621), .B1(oam[716]), 
        .B2(n33), .Y(n1702) );
  sky130_fd_sc_hd__a22oi_1 U1789 ( .A1(oam[724]), .A2(n2297), .B1(oam[732]), 
        .B2(n534), .Y(n1701) );
  sky130_fd_sc_hd__a22oi_1 U1790 ( .A1(oam[740]), .A2(n472), .B1(oam[748]), 
        .B2(n2323), .Y(n1700) );
  sky130_fd_sc_hd__a22oi_1 U1791 ( .A1(oam[756]), .A2(n489), .B1(oam[764]), 
        .B2(n2328), .Y(n1699) );
  sky130_fd_sc_hd__nand4_1 U1792 ( .A(n1703), .B(n1704), .C(n1705), .D(n1706), 
        .Y(n1697) );
  sky130_fd_sc_hd__a22oi_1 U1793 ( .A1(oam[644]), .A2(n2336), .B1(oam[652]), 
        .B2(n2349), .Y(n1706) );
  sky130_fd_sc_hd__a22oi_1 U1794 ( .A1(oam[660]), .A2(n561), .B1(oam[668]), 
        .B2(n2358), .Y(n1705) );
  sky130_fd_sc_hd__a22oi_1 U1795 ( .A1(oam[676]), .A2(n519), .B1(oam[684]), 
        .B2(n576), .Y(n1704) );
  sky130_fd_sc_hd__a22oi_1 U1796 ( .A1(oam[692]), .A2(n2368), .B1(oam[700]), 
        .B2(n2377), .Y(n1703) );
  sky130_fd_sc_hd__o21ai_1 U1797 ( .A1(n1707), .A2(n1708), .B1(n226), .Y(n1673) );
  sky130_fd_sc_hd__nand4_1 U1798 ( .A(n1709), .B(n1710), .C(n1711), .D(n1712), 
        .Y(n1708) );
  sky130_fd_sc_hd__a22oi_1 U1799 ( .A1(oam[196]), .A2(n613), .B1(oam[204]), 
        .B2(n24), .Y(n1712) );
  sky130_fd_sc_hd__a22oi_1 U1800 ( .A1(oam[212]), .A2(n2303), .B1(oam[220]), 
        .B2(n544), .Y(n1711) );
  sky130_fd_sc_hd__a22oi_1 U1801 ( .A1(oam[228]), .A2(n2307), .B1(oam[236]), 
        .B2(n2323), .Y(n1710) );
  sky130_fd_sc_hd__a22oi_1 U1802 ( .A1(oam[244]), .A2(n479), .B1(oam[252]), 
        .B2(n2328), .Y(n1709) );
  sky130_fd_sc_hd__nand4_1 U1803 ( .A(n1713), .B(n1714), .C(n1715), .D(n1716), 
        .Y(n1707) );
  sky130_fd_sc_hd__a22oi_1 U1804 ( .A1(oam[132]), .A2(n2337), .B1(oam[140]), 
        .B2(n2349), .Y(n1716) );
  sky130_fd_sc_hd__a22oi_1 U1805 ( .A1(oam[148]), .A2(n559), .B1(oam[156]), 
        .B2(n2358), .Y(n1715) );
  sky130_fd_sc_hd__a22oi_1 U1806 ( .A1(oam[164]), .A2(n530), .B1(oam[172]), 
        .B2(n575), .Y(n1714) );
  sky130_fd_sc_hd__a22oi_1 U1807 ( .A1(oam[180]), .A2(n2369), .B1(oam[188]), 
        .B2(n2383), .Y(n1713) );
  sky130_fd_sc_hd__o21ai_1 U1808 ( .A1(n1721), .A2(n1722), .B1(n103), .Y(n1720) );
  sky130_fd_sc_hd__nand4_1 U1809 ( .A(n1723), .B(n1724), .C(n1725), .D(n1726), 
        .Y(n1722) );
  sky130_fd_sc_hd__a22oi_1 U1810 ( .A1(oam[1861]), .A2(n602), .B1(oam[1869]), 
        .B2(n92), .Y(n1726) );
  sky130_fd_sc_hd__a22oi_1 U1811 ( .A1(oam[1877]), .A2(n2296), .B1(oam[1885]), 
        .B2(n545), .Y(n1725) );
  sky130_fd_sc_hd__a22oi_1 U1812 ( .A1(oam[1893]), .A2(n471), .B1(oam[1901]), 
        .B2(n2322), .Y(n1724) );
  sky130_fd_sc_hd__a22oi_1 U1813 ( .A1(oam[1909]), .A2(n488), .B1(oam[1917]), 
        .B2(n2328), .Y(n1723) );
  sky130_fd_sc_hd__nand4_1 U1814 ( .A(n1727), .B(n1728), .C(n1729), .D(n1730), 
        .Y(n1721) );
  sky130_fd_sc_hd__a22oi_1 U1815 ( .A1(oam[1797]), .A2(n2343), .B1(oam[1805]), 
        .B2(n2347), .Y(n1730) );
  sky130_fd_sc_hd__a22oi_1 U1816 ( .A1(oam[1813]), .A2(n560), .B1(oam[1821]), 
        .B2(n2358), .Y(n1729) );
  sky130_fd_sc_hd__a22oi_1 U1817 ( .A1(oam[1829]), .A2(n526), .B1(oam[1837]), 
        .B2(n575), .Y(n1728) );
  sky130_fd_sc_hd__a22oi_1 U1818 ( .A1(oam[1845]), .A2(n2367), .B1(oam[1853]), 
        .B2(n2382), .Y(n1727) );
  sky130_fd_sc_hd__o21ai_1 U1819 ( .A1(n1731), .A2(n1732), .B1(n228), .Y(n1719) );
  sky130_fd_sc_hd__nand4_1 U1820 ( .A(n1733), .B(n1734), .C(n1735), .D(n1736), 
        .Y(n1732) );
  sky130_fd_sc_hd__a22oi_1 U1821 ( .A1(oam[1349]), .A2(n604), .B1(oam[1357]), 
        .B2(n33), .Y(n1736) );
  sky130_fd_sc_hd__a22oi_1 U1822 ( .A1(oam[1365]), .A2(n2299), .B1(oam[1373]), 
        .B2(n540), .Y(n1735) );
  sky130_fd_sc_hd__a22oi_1 U1823 ( .A1(oam[1381]), .A2(n2313), .B1(oam[1389]), 
        .B2(n2320), .Y(n1734) );
  sky130_fd_sc_hd__a22oi_1 U1824 ( .A1(oam[1397]), .A2(n490), .B1(oam[1405]), 
        .B2(n2328), .Y(n1733) );
  sky130_fd_sc_hd__nand4_1 U1825 ( .A(n1737), .B(n1738), .C(n1739), .D(n1740), 
        .Y(n1731) );
  sky130_fd_sc_hd__a22oi_1 U1826 ( .A1(oam[1285]), .A2(n2343), .B1(oam[1293]), 
        .B2(n2346), .Y(n1740) );
  sky130_fd_sc_hd__a22oi_1 U1827 ( .A1(oam[1301]), .A2(n561), .B1(oam[1309]), 
        .B2(n2358), .Y(n1739) );
  sky130_fd_sc_hd__a22oi_1 U1828 ( .A1(oam[1317]), .A2(n527), .B1(oam[1325]), 
        .B2(n568), .Y(n1738) );
  sky130_fd_sc_hd__a22oi_1 U1829 ( .A1(oam[1333]), .A2(n2372), .B1(oam[1341]), 
        .B2(n2374), .Y(n1737) );
  sky130_fd_sc_hd__o21ai_1 U1830 ( .A1(n1741), .A2(n1742), .B1(n227), .Y(n1718) );
  sky130_fd_sc_hd__nand4_1 U1831 ( .A(n1743), .B(n1744), .C(n1745), .D(n1746), 
        .Y(n1742) );
  sky130_fd_sc_hd__a22oi_1 U1832 ( .A1(oam[837]), .A2(n607), .B1(oam[845]), 
        .B2(n41), .Y(n1746) );
  sky130_fd_sc_hd__a22oi_1 U1833 ( .A1(oam[853]), .A2(n2298), .B1(oam[861]), 
        .B2(n535), .Y(n1745) );
  sky130_fd_sc_hd__a22oi_1 U1834 ( .A1(oam[869]), .A2(n2313), .B1(oam[877]), 
        .B2(n2324), .Y(n1744) );
  sky130_fd_sc_hd__a22oi_1 U1835 ( .A1(oam[885]), .A2(n480), .B1(oam[893]), 
        .B2(n2328), .Y(n1743) );
  sky130_fd_sc_hd__nand4_1 U1836 ( .A(n1747), .B(n1748), .C(n1749), .D(n1750), 
        .Y(n1741) );
  sky130_fd_sc_hd__a22oi_1 U1837 ( .A1(oam[773]), .A2(n2340), .B1(oam[781]), 
        .B2(n2350), .Y(n1750) );
  sky130_fd_sc_hd__a22oi_1 U1838 ( .A1(oam[789]), .A2(n563), .B1(oam[797]), 
        .B2(n2358), .Y(n1749) );
  sky130_fd_sc_hd__a22oi_1 U1839 ( .A1(oam[805]), .A2(n518), .B1(oam[813]), 
        .B2(n573), .Y(n1748) );
  sky130_fd_sc_hd__a22oi_1 U1840 ( .A1(oam[821]), .A2(n2368), .B1(oam[829]), 
        .B2(n2380), .Y(n1747) );
  sky130_fd_sc_hd__o21ai_1 U1841 ( .A1(n1751), .A2(n1752), .B1(n229), .Y(n1717) );
  sky130_fd_sc_hd__nand4_1 U1842 ( .A(n1753), .B(n1754), .C(n1755), .D(n1756), 
        .Y(n1752) );
  sky130_fd_sc_hd__a22oi_1 U1843 ( .A1(oam[325]), .A2(n613), .B1(oam[333]), 
        .B2(n23), .Y(n1756) );
  sky130_fd_sc_hd__a22oi_1 U1844 ( .A1(oam[341]), .A2(n2297), .B1(oam[349]), 
        .B2(n534), .Y(n1755) );
  sky130_fd_sc_hd__a22oi_1 U1845 ( .A1(oam[357]), .A2(n2306), .B1(oam[365]), 
        .B2(n2320), .Y(n1754) );
  sky130_fd_sc_hd__a22oi_1 U1846 ( .A1(oam[373]), .A2(n478), .B1(oam[381]), 
        .B2(n2328), .Y(n1753) );
  sky130_fd_sc_hd__nand4_1 U1847 ( .A(n1757), .B(n1758), .C(n1759), .D(n1760), 
        .Y(n1751) );
  sky130_fd_sc_hd__a22oi_1 U1848 ( .A1(oam[261]), .A2(n2335), .B1(oam[269]), 
        .B2(n2347), .Y(n1760) );
  sky130_fd_sc_hd__a22oi_1 U1849 ( .A1(oam[277]), .A2(n559), .B1(oam[285]), 
        .B2(n2358), .Y(n1759) );
  sky130_fd_sc_hd__a22oi_1 U1850 ( .A1(oam[293]), .A2(n518), .B1(oam[301]), 
        .B2(n573), .Y(n1758) );
  sky130_fd_sc_hd__a22oi_1 U1851 ( .A1(oam[309]), .A2(n2365), .B1(oam[317]), 
        .B2(n2374), .Y(n1757) );
  sky130_fd_sc_hd__o21ai_1 U1852 ( .A1(n1765), .A2(n1766), .B1(n219), .Y(n1764) );
  sky130_fd_sc_hd__nand4_1 U1853 ( .A(n1767), .B(n1768), .C(n1769), .D(n1770), 
        .Y(n1766) );
  sky130_fd_sc_hd__a22oi_1 U1854 ( .A1(oam[1989]), .A2(n601), .B1(oam[1997]), 
        .B2(n34), .Y(n1770) );
  sky130_fd_sc_hd__a22oi_1 U1855 ( .A1(oam[2005]), .A2(n2301), .B1(oam[2013]), 
        .B2(n534), .Y(n1769) );
  sky130_fd_sc_hd__a22oi_1 U1856 ( .A1(oam[2021]), .A2(n2309), .B1(oam[2029]), 
        .B2(n2321), .Y(n1768) );
  sky130_fd_sc_hd__a22oi_1 U1857 ( .A1(oam[2037]), .A2(n480), .B1(oam[2045]), 
        .B2(n2328), .Y(n1767) );
  sky130_fd_sc_hd__nand4_1 U1858 ( .A(n1771), .B(n1772), .C(n1773), .D(n1774), 
        .Y(n1765) );
  sky130_fd_sc_hd__a22oi_1 U1859 ( .A1(oam[1925]), .A2(n2337), .B1(oam[1933]), 
        .B2(n2347), .Y(n1774) );
  sky130_fd_sc_hd__a22oi_1 U1860 ( .A1(oam[1941]), .A2(n556), .B1(oam[1949]), 
        .B2(n2358), .Y(n1773) );
  sky130_fd_sc_hd__a22oi_1 U1861 ( .A1(oam[1957]), .A2(n519), .B1(oam[1965]), 
        .B2(n573), .Y(n1772) );
  sky130_fd_sc_hd__a22oi_1 U1862 ( .A1(oam[1973]), .A2(n2373), .B1(oam[1981]), 
        .B2(n2376), .Y(n1771) );
  sky130_fd_sc_hd__o21ai_1 U1863 ( .A1(n1775), .A2(n1776), .B1(n221), .Y(n1763) );
  sky130_fd_sc_hd__nand4_1 U1864 ( .A(n1777), .B(n1778), .C(n1779), .D(n1780), 
        .Y(n1776) );
  sky130_fd_sc_hd__a22oi_1 U1865 ( .A1(oam[1477]), .A2(n603), .B1(oam[1485]), 
        .B2(n16), .Y(n1780) );
  sky130_fd_sc_hd__a22oi_1 U1866 ( .A1(oam[1493]), .A2(n2296), .B1(oam[1501]), 
        .B2(n543), .Y(n1779) );
  sky130_fd_sc_hd__a22oi_1 U1867 ( .A1(oam[1509]), .A2(n2312), .B1(oam[1517]), 
        .B2(n2316), .Y(n1778) );
  sky130_fd_sc_hd__a22oi_1 U1868 ( .A1(oam[1525]), .A2(n490), .B1(oam[1533]), 
        .B2(n2328), .Y(n1777) );
  sky130_fd_sc_hd__nand4_1 U1869 ( .A(n1781), .B(n1782), .C(n1783), .D(n1784), 
        .Y(n1775) );
  sky130_fd_sc_hd__a22oi_1 U1870 ( .A1(oam[1413]), .A2(n2343), .B1(oam[1421]), 
        .B2(n2353), .Y(n1784) );
  sky130_fd_sc_hd__a22oi_1 U1871 ( .A1(oam[1429]), .A2(n548), .B1(oam[1437]), 
        .B2(n2358), .Y(n1783) );
  sky130_fd_sc_hd__a22oi_1 U1872 ( .A1(oam[1445]), .A2(n519), .B1(oam[1453]), 
        .B2(n568), .Y(n1782) );
  sky130_fd_sc_hd__a22oi_1 U1873 ( .A1(oam[1461]), .A2(n2367), .B1(oam[1469]), 
        .B2(n2379), .Y(n1781) );
  sky130_fd_sc_hd__o21ai_1 U1874 ( .A1(n1785), .A2(n1786), .B1(n223), .Y(n1762) );
  sky130_fd_sc_hd__nand4_1 U1875 ( .A(n1787), .B(n1788), .C(n1789), .D(n1790), 
        .Y(n1786) );
  sky130_fd_sc_hd__a22oi_1 U1876 ( .A1(oam[965]), .A2(n605), .B1(oam[973]), 
        .B2(n17), .Y(n1790) );
  sky130_fd_sc_hd__a22oi_1 U1877 ( .A1(oam[981]), .A2(n2302), .B1(oam[989]), 
        .B2(n541), .Y(n1789) );
  sky130_fd_sc_hd__a22oi_1 U1878 ( .A1(oam[997]), .A2(n2311), .B1(oam[1005]), 
        .B2(n2317), .Y(n1788) );
  sky130_fd_sc_hd__a22oi_1 U1879 ( .A1(oam[1013]), .A2(n483), .B1(oam[1021]), 
        .B2(n2328), .Y(n1787) );
  sky130_fd_sc_hd__nand4_1 U1880 ( .A(n1791), .B(n1792), .C(n1793), .D(n1794), 
        .Y(n1785) );
  sky130_fd_sc_hd__a22oi_1 U1881 ( .A1(oam[901]), .A2(n2336), .B1(oam[909]), 
        .B2(n2346), .Y(n1794) );
  sky130_fd_sc_hd__a22oi_1 U1882 ( .A1(oam[917]), .A2(n558), .B1(oam[925]), 
        .B2(n2358), .Y(n1793) );
  sky130_fd_sc_hd__a22oi_1 U1883 ( .A1(oam[933]), .A2(n518), .B1(oam[941]), 
        .B2(n568), .Y(n1792) );
  sky130_fd_sc_hd__a22oi_1 U1884 ( .A1(oam[949]), .A2(n439), .B1(oam[957]), 
        .B2(n2377), .Y(n1791) );
  sky130_fd_sc_hd__o21ai_1 U1885 ( .A1(n1795), .A2(n1796), .B1(n224), .Y(n1761) );
  sky130_fd_sc_hd__nand4_1 U1886 ( .A(n1797), .B(n1798), .C(n1799), .D(n1800), 
        .Y(n1796) );
  sky130_fd_sc_hd__a22oi_1 U1887 ( .A1(oam[453]), .A2(n613), .B1(oam[461]), 
        .B2(n27), .Y(n1800) );
  sky130_fd_sc_hd__a22oi_1 U1888 ( .A1(oam[469]), .A2(n2304), .B1(oam[477]), 
        .B2(n533), .Y(n1799) );
  sky130_fd_sc_hd__a22oi_1 U1889 ( .A1(oam[485]), .A2(n472), .B1(oam[493]), 
        .B2(n2318), .Y(n1798) );
  sky130_fd_sc_hd__a22oi_1 U1890 ( .A1(oam[501]), .A2(n488), .B1(oam[509]), 
        .B2(n2328), .Y(n1797) );
  sky130_fd_sc_hd__nand4_1 U1891 ( .A(n1801), .B(n1802), .C(n1803), .D(n1804), 
        .Y(n1795) );
  sky130_fd_sc_hd__a22oi_1 U1892 ( .A1(oam[389]), .A2(n2336), .B1(oam[397]), 
        .B2(n2349), .Y(n1804) );
  sky130_fd_sc_hd__a22oi_1 U1893 ( .A1(oam[405]), .A2(n550), .B1(oam[413]), 
        .B2(n2358), .Y(n1803) );
  sky130_fd_sc_hd__a22oi_1 U1894 ( .A1(oam[421]), .A2(n524), .B1(oam[429]), 
        .B2(n574), .Y(n1802) );
  sky130_fd_sc_hd__a22oi_1 U1895 ( .A1(oam[437]), .A2(n2370), .B1(oam[445]), 
        .B2(n2376), .Y(n1801) );
  sky130_fd_sc_hd__o21ai_1 U1896 ( .A1(n1809), .A2(n1810), .B1(n128), .Y(n1808) );
  sky130_fd_sc_hd__nand4_1 U1897 ( .A(n1811), .B(n1812), .C(n1813), .D(n1814), 
        .Y(n1810) );
  sky130_fd_sc_hd__a22oi_1 U1898 ( .A1(oam[1605]), .A2(n609), .B1(oam[1613]), 
        .B2(n79), .Y(n1814) );
  sky130_fd_sc_hd__a22oi_1 U1899 ( .A1(oam[1621]), .A2(n2298), .B1(oam[1629]), 
        .B2(n542), .Y(n1813) );
  sky130_fd_sc_hd__a22oi_1 U1900 ( .A1(oam[1637]), .A2(n2308), .B1(oam[1645]), 
        .B2(n2323), .Y(n1812) );
  sky130_fd_sc_hd__a22oi_1 U1901 ( .A1(oam[1653]), .A2(n478), .B1(oam[1661]), 
        .B2(n2328), .Y(n1811) );
  sky130_fd_sc_hd__nand4_1 U1902 ( .A(n1815), .B(n1816), .C(n1817), .D(n1818), 
        .Y(n1809) );
  sky130_fd_sc_hd__a22oi_1 U1903 ( .A1(oam[1541]), .A2(n2337), .B1(oam[1549]), 
        .B2(n2353), .Y(n1818) );
  sky130_fd_sc_hd__a22oi_1 U1904 ( .A1(oam[1557]), .A2(n561), .B1(oam[1565]), 
        .B2(n2358), .Y(n1817) );
  sky130_fd_sc_hd__a22oi_1 U1905 ( .A1(oam[1573]), .A2(n529), .B1(oam[1581]), 
        .B2(n575), .Y(n1816) );
  sky130_fd_sc_hd__a22oi_1 U1906 ( .A1(oam[1589]), .A2(n2370), .B1(oam[1597]), 
        .B2(n2380), .Y(n1815) );
  sky130_fd_sc_hd__o21ai_1 U1907 ( .A1(n1819), .A2(n1820), .B1(n130), .Y(n1807) );
  sky130_fd_sc_hd__nand4_1 U1908 ( .A(n1821), .B(n1822), .C(n1823), .D(n1824), 
        .Y(n1820) );
  sky130_fd_sc_hd__a22oi_1 U1909 ( .A1(oam[1093]), .A2(n612), .B1(oam[1101]), 
        .B2(n41), .Y(n1824) );
  sky130_fd_sc_hd__a22oi_1 U1910 ( .A1(oam[1109]), .A2(n2296), .B1(oam[1117]), 
        .B2(n542), .Y(n1823) );
  sky130_fd_sc_hd__a22oi_1 U1911 ( .A1(oam[1125]), .A2(n2307), .B1(oam[1133]), 
        .B2(n2324), .Y(n1822) );
  sky130_fd_sc_hd__a22oi_1 U1912 ( .A1(oam[1141]), .A2(n483), .B1(oam[1149]), 
        .B2(n2328), .Y(n1821) );
  sky130_fd_sc_hd__nand4_1 U1913 ( .A(n1825), .B(n1826), .C(n1827), .D(n1828), 
        .Y(n1819) );
  sky130_fd_sc_hd__a22oi_1 U1914 ( .A1(oam[1029]), .A2(n2343), .B1(oam[1037]), 
        .B2(n2345), .Y(n1828) );
  sky130_fd_sc_hd__a22oi_1 U1915 ( .A1(oam[1045]), .A2(n549), .B1(oam[1053]), 
        .B2(n2358), .Y(n1827) );
  sky130_fd_sc_hd__a22oi_1 U1916 ( .A1(oam[1061]), .A2(n525), .B1(oam[1069]), 
        .B2(n574), .Y(n1826) );
  sky130_fd_sc_hd__a22oi_1 U1917 ( .A1(oam[1077]), .A2(n2371), .B1(oam[1085]), 
        .B2(n2374), .Y(n1825) );
  sky130_fd_sc_hd__o21ai_1 U1918 ( .A1(n1829), .A2(n1830), .B1(n129), .Y(n1806) );
  sky130_fd_sc_hd__nand4_1 U1919 ( .A(n1834), .B(n1832), .C(n1833), .D(n1831), 
        .Y(n1830) );
  sky130_fd_sc_hd__a22oi_1 U1920 ( .A1(oam[581]), .A2(n615), .B1(oam[589]), 
        .B2(n56), .Y(n1834) );
  sky130_fd_sc_hd__a22oi_1 U1921 ( .A1(oam[597]), .A2(n2302), .B1(oam[605]), 
        .B2(n541), .Y(n1833) );
  sky130_fd_sc_hd__a22oi_1 U1922 ( .A1(oam[613]), .A2(n2308), .B1(oam[621]), 
        .B2(n2318), .Y(n1832) );
  sky130_fd_sc_hd__a22oi_1 U1923 ( .A1(oam[629]), .A2(n483), .B1(oam[637]), 
        .B2(n2328), .Y(n1831) );
  sky130_fd_sc_hd__nand4_1 U1924 ( .A(n1835), .B(n1836), .C(n1837), .D(n1838), 
        .Y(n1829) );
  sky130_fd_sc_hd__a22oi_1 U1925 ( .A1(oam[517]), .A2(n2336), .B1(oam[525]), 
        .B2(n2350), .Y(n1838) );
  sky130_fd_sc_hd__a22oi_1 U1926 ( .A1(oam[533]), .A2(n563), .B1(oam[541]), 
        .B2(n2358), .Y(n1837) );
  sky130_fd_sc_hd__a22oi_1 U1927 ( .A1(oam[549]), .A2(n517), .B1(oam[557]), 
        .B2(n568), .Y(n1836) );
  sky130_fd_sc_hd__a22oi_1 U1928 ( .A1(oam[565]), .A2(n2365), .B1(oam[573]), 
        .B2(n2375), .Y(n1835) );
  sky130_fd_sc_hd__o21ai_1 U1929 ( .A1(n1839), .A2(n1840), .B1(n231), .Y(n1805) );
  sky130_fd_sc_hd__nand4_1 U1930 ( .A(n1841), .B(n1842), .C(n1843), .D(n1844), 
        .Y(n1840) );
  sky130_fd_sc_hd__a22oi_1 U1931 ( .A1(oam[69]), .A2(n620), .B1(oam[77]), .B2(
        n18), .Y(n1844) );
  sky130_fd_sc_hd__a22oi_1 U1932 ( .A1(oam[85]), .A2(n2297), .B1(oam[93]), 
        .B2(n542), .Y(n1843) );
  sky130_fd_sc_hd__a22oi_1 U1933 ( .A1(oam[101]), .A2(n2313), .B1(oam[109]), 
        .B2(n445), .Y(n1842) );
  sky130_fd_sc_hd__a22oi_1 U1934 ( .A1(oam[117]), .A2(n486), .B1(oam[125]), 
        .B2(n2327), .Y(n1841) );
  sky130_fd_sc_hd__nand4_1 U1935 ( .A(n1845), .B(n1846), .C(n1847), .D(n1848), 
        .Y(n1839) );
  sky130_fd_sc_hd__a22oi_1 U1936 ( .A1(oam[5]), .A2(n2341), .B1(oam[13]), .B2(
        n2352), .Y(n1848) );
  sky130_fd_sc_hd__a22oi_1 U1937 ( .A1(oam[21]), .A2(n548), .B1(oam[29]), .B2(
        n2357), .Y(n1847) );
  sky130_fd_sc_hd__a22oi_1 U1938 ( .A1(oam[37]), .A2(n526), .B1(oam[45]), .B2(
        n566), .Y(n1846) );
  sky130_fd_sc_hd__a22oi_1 U1939 ( .A1(oam[53]), .A2(n2370), .B1(oam[61]), 
        .B2(n2378), .Y(n1845) );
  sky130_fd_sc_hd__o21ai_1 U1940 ( .A1(n1853), .A2(n1854), .B1(n127), .Y(n1852) );
  sky130_fd_sc_hd__nand4_1 U1941 ( .A(n1855), .B(n1856), .C(n1857), .D(n1858), 
        .Y(n1854) );
  sky130_fd_sc_hd__a22oi_1 U1942 ( .A1(oam[1733]), .A2(n599), .B1(oam[1741]), 
        .B2(n48), .Y(n1858) );
  sky130_fd_sc_hd__a22oi_1 U1943 ( .A1(oam[1749]), .A2(n2304), .B1(oam[1757]), 
        .B2(n543), .Y(n1857) );
  sky130_fd_sc_hd__a22oi_1 U1944 ( .A1(oam[1765]), .A2(n2314), .B1(oam[1773]), 
        .B2(n2323), .Y(n1856) );
  sky130_fd_sc_hd__a22oi_1 U1945 ( .A1(oam[1781]), .A2(n486), .B1(oam[1789]), 
        .B2(n2327), .Y(n1855) );
  sky130_fd_sc_hd__nand4_1 U1946 ( .A(n1861), .B(n1860), .C(n1859), .D(n1862), 
        .Y(n1853) );
  sky130_fd_sc_hd__a22oi_1 U1947 ( .A1(oam[1669]), .A2(n2337), .B1(oam[1677]), 
        .B2(n2352), .Y(n1862) );
  sky130_fd_sc_hd__a22oi_1 U1948 ( .A1(oam[1685]), .A2(n550), .B1(oam[1693]), 
        .B2(n2357), .Y(n1861) );
  sky130_fd_sc_hd__a22oi_1 U1949 ( .A1(oam[1701]), .A2(n517), .B1(oam[1709]), 
        .B2(n575), .Y(n1860) );
  sky130_fd_sc_hd__o21ai_1 U1950 ( .A1(n1863), .A2(n1864), .B1(n220), .Y(n1851) );
  sky130_fd_sc_hd__nand4_1 U1951 ( .A(n1865), .B(n1866), .C(n1867), .D(n1868), 
        .Y(n1864) );
  sky130_fd_sc_hd__a22oi_1 U1952 ( .A1(oam[1221]), .A2(n600), .B1(oam[1229]), 
        .B2(n58), .Y(n1868) );
  sky130_fd_sc_hd__a22oi_1 U1953 ( .A1(oam[1237]), .A2(n2296), .B1(oam[1245]), 
        .B2(n534), .Y(n1867) );
  sky130_fd_sc_hd__a22oi_1 U1954 ( .A1(oam[1253]), .A2(n2307), .B1(oam[1261]), 
        .B2(n2316), .Y(n1866) );
  sky130_fd_sc_hd__a22oi_1 U1955 ( .A1(oam[1269]), .A2(n488), .B1(oam[1277]), 
        .B2(n2327), .Y(n1865) );
  sky130_fd_sc_hd__nand4_1 U1956 ( .A(n1870), .B(n1869), .C(n1871), .D(n1872), 
        .Y(n1863) );
  sky130_fd_sc_hd__a22oi_1 U1957 ( .A1(oam[1157]), .A2(n2340), .B1(oam[1165]), 
        .B2(n2354), .Y(n1872) );
  sky130_fd_sc_hd__a22oi_1 U1958 ( .A1(oam[1205]), .A2(n2366), .B1(oam[1213]), 
        .B2(n2379), .Y(n1869) );
  sky130_fd_sc_hd__o21ai_1 U1959 ( .A1(n1873), .A2(n1874), .B1(n222), .Y(n1850) );
  sky130_fd_sc_hd__nand4_1 U1960 ( .A(n1875), .B(n1876), .C(n1877), .D(n1878), 
        .Y(n1874) );
  sky130_fd_sc_hd__a22oi_1 U1961 ( .A1(oam[709]), .A2(n603), .B1(oam[717]), 
        .B2(n65), .Y(n1878) );
  sky130_fd_sc_hd__a22oi_1 U1962 ( .A1(oam[725]), .A2(n2296), .B1(oam[733]), 
        .B2(n534), .Y(n1877) );
  sky130_fd_sc_hd__a22oi_1 U1963 ( .A1(oam[741]), .A2(n2311), .B1(oam[749]), 
        .B2(n2317), .Y(n1876) );
  sky130_fd_sc_hd__a22oi_1 U1964 ( .A1(oam[757]), .A2(n489), .B1(oam[765]), 
        .B2(n2327), .Y(n1875) );
  sky130_fd_sc_hd__nand4_1 U1965 ( .A(n1879), .B(n1880), .C(n1881), .D(n1882), 
        .Y(n1873) );
  sky130_fd_sc_hd__a22oi_1 U1966 ( .A1(oam[645]), .A2(n2341), .B1(oam[653]), 
        .B2(n2346), .Y(n1882) );
  sky130_fd_sc_hd__a22oi_1 U1967 ( .A1(oam[661]), .A2(n560), .B1(oam[669]), 
        .B2(n2357), .Y(n1881) );
  sky130_fd_sc_hd__a22oi_1 U1968 ( .A1(oam[693]), .A2(n2368), .B1(oam[701]), 
        .B2(n2381), .Y(n1879) );
  sky130_fd_sc_hd__o21ai_1 U1969 ( .A1(n1883), .A2(n1884), .B1(n226), .Y(n1849) );
  sky130_fd_sc_hd__nand4_1 U1970 ( .A(n1885), .B(n1886), .C(n1887), .D(n1888), 
        .Y(n1884) );
  sky130_fd_sc_hd__a22oi_1 U1971 ( .A1(oam[197]), .A2(n614), .B1(oam[205]), 
        .B2(n56), .Y(n1888) );
  sky130_fd_sc_hd__a22oi_1 U1972 ( .A1(oam[213]), .A2(n2305), .B1(oam[221]), 
        .B2(n540), .Y(n1887) );
  sky130_fd_sc_hd__a22oi_1 U1973 ( .A1(oam[229]), .A2(n2312), .B1(oam[237]), 
        .B2(n2320), .Y(n1886) );
  sky130_fd_sc_hd__a22oi_1 U1974 ( .A1(oam[245]), .A2(n490), .B1(oam[253]), 
        .B2(n2327), .Y(n1885) );
  sky130_fd_sc_hd__nand4_1 U1975 ( .A(n1889), .B(n1890), .C(n1891), .D(n1892), 
        .Y(n1883) );
  sky130_fd_sc_hd__a22oi_1 U1976 ( .A1(oam[133]), .A2(n2340), .B1(oam[141]), 
        .B2(n2347), .Y(n1892) );
  sky130_fd_sc_hd__a22oi_1 U1977 ( .A1(oam[149]), .A2(n551), .B1(oam[157]), 
        .B2(n2357), .Y(n1891) );
  sky130_fd_sc_hd__a22oi_1 U1978 ( .A1(oam[165]), .A2(n528), .B1(oam[173]), 
        .B2(n566), .Y(n1890) );
  sky130_fd_sc_hd__a22oi_1 U1979 ( .A1(oam[181]), .A2(n2367), .B1(oam[189]), 
        .B2(n2379), .Y(n1889) );
  sky130_fd_sc_hd__o21ai_1 U1980 ( .A1(n1899), .A2(n1900), .B1(n103), .Y(n1898) );
  sky130_fd_sc_hd__nand4_1 U1981 ( .A(n1901), .B(n1902), .C(n1903), .D(n1904), 
        .Y(n1900) );
  sky130_fd_sc_hd__a22oi_1 U1982 ( .A1(oam[1862]), .A2(n587), .B1(oam[1870]), 
        .B2(n63), .Y(n1904) );
  sky130_fd_sc_hd__a22oi_1 U1983 ( .A1(oam[1878]), .A2(n2296), .B1(oam[1886]), 
        .B2(n534), .Y(n1903) );
  sky130_fd_sc_hd__a22oi_1 U1984 ( .A1(oam[1894]), .A2(n2308), .B1(oam[1902]), 
        .B2(n2321), .Y(n1902) );
  sky130_fd_sc_hd__a22oi_1 U1985 ( .A1(oam[1910]), .A2(n481), .B1(oam[1918]), 
        .B2(n2327), .Y(n1901) );
  sky130_fd_sc_hd__nand4_1 U1986 ( .A(n1905), .B(n1906), .C(n1907), .D(n1908), 
        .Y(n1899) );
  sky130_fd_sc_hd__a22oi_1 U1987 ( .A1(oam[1798]), .A2(n2342), .B1(oam[1806]), 
        .B2(n2345), .Y(n1908) );
  sky130_fd_sc_hd__a22oi_1 U1988 ( .A1(oam[1814]), .A2(n561), .B1(oam[1822]), 
        .B2(n2357), .Y(n1907) );
  sky130_fd_sc_hd__a22oi_1 U1989 ( .A1(oam[1830]), .A2(n519), .B1(oam[1838]), 
        .B2(n577), .Y(n1906) );
  sky130_fd_sc_hd__a22oi_1 U1990 ( .A1(oam[1846]), .A2(n2365), .B1(oam[1854]), 
        .B2(n2379), .Y(n1905) );
  sky130_fd_sc_hd__o21ai_1 U1991 ( .A1(n1909), .A2(n1910), .B1(n228), .Y(n1897) );
  sky130_fd_sc_hd__nand4_1 U1992 ( .A(n1911), .B(n1912), .C(n1913), .D(n1914), 
        .Y(n1910) );
  sky130_fd_sc_hd__a22oi_1 U1993 ( .A1(oam[1350]), .A2(n588), .B1(oam[1358]), 
        .B2(n73), .Y(n1914) );
  sky130_fd_sc_hd__a22oi_1 U1994 ( .A1(oam[1366]), .A2(n2299), .B1(oam[1374]), 
        .B2(n535), .Y(n1913) );
  sky130_fd_sc_hd__a22oi_1 U1995 ( .A1(oam[1382]), .A2(n2313), .B1(oam[1390]), 
        .B2(n2316), .Y(n1912) );
  sky130_fd_sc_hd__a22oi_1 U1996 ( .A1(oam[1398]), .A2(n490), .B1(oam[1406]), 
        .B2(n2327), .Y(n1911) );
  sky130_fd_sc_hd__nand4_1 U1997 ( .A(n1915), .B(n1916), .C(n1917), .D(n1918), 
        .Y(n1909) );
  sky130_fd_sc_hd__a22oi_1 U1998 ( .A1(oam[1286]), .A2(n2336), .B1(oam[1294]), 
        .B2(n2351), .Y(n1918) );
  sky130_fd_sc_hd__a22oi_1 U1999 ( .A1(oam[1302]), .A2(n548), .B1(oam[1310]), 
        .B2(n2357), .Y(n1917) );
  sky130_fd_sc_hd__a22oi_1 U2000 ( .A1(oam[1318]), .A2(n528), .B1(oam[1326]), 
        .B2(n576), .Y(n1916) );
  sky130_fd_sc_hd__a22oi_1 U2001 ( .A1(oam[1334]), .A2(n439), .B1(oam[1342]), 
        .B2(n2376), .Y(n1915) );
  sky130_fd_sc_hd__o21ai_1 U2002 ( .A1(n1919), .A2(n1920), .B1(n227), .Y(n1896) );
  sky130_fd_sc_hd__nand4_1 U2003 ( .A(n1921), .B(n1922), .C(n1923), .D(n1924), 
        .Y(n1920) );
  sky130_fd_sc_hd__a22oi_1 U2004 ( .A1(oam[838]), .A2(n589), .B1(oam[846]), 
        .B2(n51), .Y(n1924) );
  sky130_fd_sc_hd__a22oi_1 U2005 ( .A1(oam[854]), .A2(n2304), .B1(oam[862]), 
        .B2(n544), .Y(n1923) );
  sky130_fd_sc_hd__a22oi_1 U2006 ( .A1(oam[870]), .A2(n2307), .B1(oam[878]), 
        .B2(n2315), .Y(n1922) );
  sky130_fd_sc_hd__a22oi_1 U2007 ( .A1(oam[886]), .A2(n480), .B1(oam[894]), 
        .B2(n2327), .Y(n1921) );
  sky130_fd_sc_hd__nand4_1 U2008 ( .A(n1925), .B(n1926), .C(n1927), .D(n1928), 
        .Y(n1919) );
  sky130_fd_sc_hd__a22oi_1 U2009 ( .A1(oam[774]), .A2(n2343), .B1(oam[782]), 
        .B2(n2354), .Y(n1928) );
  sky130_fd_sc_hd__a22oi_1 U2010 ( .A1(oam[790]), .A2(n549), .B1(oam[798]), 
        .B2(n2357), .Y(n1927) );
  sky130_fd_sc_hd__a22oi_1 U2011 ( .A1(oam[806]), .A2(n525), .B1(oam[814]), 
        .B2(n566), .Y(n1926) );
  sky130_fd_sc_hd__a22oi_1 U2012 ( .A1(oam[822]), .A2(n2373), .B1(oam[830]), 
        .B2(n2377), .Y(n1925) );
  sky130_fd_sc_hd__o21ai_1 U2013 ( .A1(n1929), .A2(n1930), .B1(n229), .Y(n1895) );
  sky130_fd_sc_hd__nand4_1 U2014 ( .A(n1931), .B(n1932), .C(n1933), .D(n1934), 
        .Y(n1930) );
  sky130_fd_sc_hd__a22oi_1 U2015 ( .A1(oam[326]), .A2(n590), .B1(oam[334]), 
        .B2(n71), .Y(n1934) );
  sky130_fd_sc_hd__a22oi_1 U2016 ( .A1(oam[342]), .A2(n2297), .B1(oam[350]), 
        .B2(n534), .Y(n1933) );
  sky130_fd_sc_hd__a22oi_1 U2017 ( .A1(oam[358]), .A2(n472), .B1(oam[366]), 
        .B2(n2316), .Y(n1932) );
  sky130_fd_sc_hd__a22oi_1 U2018 ( .A1(oam[374]), .A2(n487), .B1(oam[382]), 
        .B2(n2327), .Y(n1931) );
  sky130_fd_sc_hd__nand4_1 U2019 ( .A(n1935), .B(n1936), .C(n1937), .D(n1938), 
        .Y(n1929) );
  sky130_fd_sc_hd__a22oi_1 U2020 ( .A1(oam[262]), .A2(n2337), .B1(oam[270]), 
        .B2(n2350), .Y(n1938) );
  sky130_fd_sc_hd__a22oi_1 U2021 ( .A1(oam[278]), .A2(n561), .B1(oam[286]), 
        .B2(n2357), .Y(n1937) );
  sky130_fd_sc_hd__a22oi_1 U2022 ( .A1(oam[294]), .A2(n529), .B1(oam[302]), 
        .B2(n567), .Y(n1936) );
  sky130_fd_sc_hd__a22oi_1 U2023 ( .A1(oam[310]), .A2(n2371), .B1(oam[318]), 
        .B2(n2383), .Y(n1935) );
  sky130_fd_sc_hd__o21ai_1 U2024 ( .A1(n1943), .A2(n1944), .B1(n219), .Y(n1942) );
  sky130_fd_sc_hd__nand4_1 U2025 ( .A(n1945), .B(n1946), .C(n1947), .D(n1948), 
        .Y(n1944) );
  sky130_fd_sc_hd__a22oi_1 U2026 ( .A1(oam[1990]), .A2(n587), .B1(oam[1998]), 
        .B2(n76), .Y(n1948) );
  sky130_fd_sc_hd__a22oi_1 U2027 ( .A1(oam[2006]), .A2(n2305), .B1(oam[2014]), 
        .B2(n533), .Y(n1947) );
  sky130_fd_sc_hd__a22oi_1 U2028 ( .A1(oam[2022]), .A2(n2310), .B1(oam[2030]), 
        .B2(n2323), .Y(n1946) );
  sky130_fd_sc_hd__a22oi_1 U2029 ( .A1(oam[2038]), .A2(n479), .B1(oam[2046]), 
        .B2(n2327), .Y(n1945) );
  sky130_fd_sc_hd__nand4_1 U2030 ( .A(n1949), .B(n1950), .C(n1951), .D(n1952), 
        .Y(n1943) );
  sky130_fd_sc_hd__a22oi_1 U2031 ( .A1(oam[1926]), .A2(n2337), .B1(oam[1934]), 
        .B2(n2352), .Y(n1952) );
  sky130_fd_sc_hd__a22oi_1 U2032 ( .A1(oam[1942]), .A2(n556), .B1(oam[1950]), 
        .B2(n2357), .Y(n1951) );
  sky130_fd_sc_hd__a22oi_1 U2033 ( .A1(oam[1958]), .A2(n518), .B1(oam[1966]), 
        .B2(n568), .Y(n1950) );
  sky130_fd_sc_hd__a22oi_1 U2034 ( .A1(oam[1974]), .A2(n2367), .B1(oam[1982]), 
        .B2(n2375), .Y(n1949) );
  sky130_fd_sc_hd__o21ai_1 U2035 ( .A1(n1953), .A2(n1954), .B1(n221), .Y(n1941) );
  sky130_fd_sc_hd__nand4_1 U2036 ( .A(n1955), .B(n1956), .C(n1957), .D(n1958), 
        .Y(n1954) );
  sky130_fd_sc_hd__a22oi_1 U2037 ( .A1(oam[1478]), .A2(n591), .B1(oam[1486]), 
        .B2(n55), .Y(n1958) );
  sky130_fd_sc_hd__a22oi_1 U2038 ( .A1(oam[1494]), .A2(n2299), .B1(oam[1502]), 
        .B2(n541), .Y(n1957) );
  sky130_fd_sc_hd__a22oi_1 U2039 ( .A1(oam[1510]), .A2(n2313), .B1(oam[1518]), 
        .B2(n2320), .Y(n1956) );
  sky130_fd_sc_hd__a22oi_1 U2040 ( .A1(oam[1526]), .A2(n480), .B1(oam[1534]), 
        .B2(n2327), .Y(n1955) );
  sky130_fd_sc_hd__nand4_1 U2041 ( .A(n1959), .B(n1960), .C(n1961), .D(n1962), 
        .Y(n1953) );
  sky130_fd_sc_hd__a22oi_1 U2042 ( .A1(oam[1414]), .A2(n2336), .B1(oam[1422]), 
        .B2(n2350), .Y(n1962) );
  sky130_fd_sc_hd__a22oi_1 U2043 ( .A1(oam[1430]), .A2(n558), .B1(oam[1438]), 
        .B2(n2357), .Y(n1961) );
  sky130_fd_sc_hd__a22oi_1 U2044 ( .A1(oam[1446]), .A2(n530), .B1(oam[1454]), 
        .B2(n573), .Y(n1960) );
  sky130_fd_sc_hd__a22oi_1 U2045 ( .A1(oam[1462]), .A2(n2369), .B1(oam[1470]), 
        .B2(n2380), .Y(n1959) );
  sky130_fd_sc_hd__o21ai_1 U2046 ( .A1(n1963), .A2(n1964), .B1(n223), .Y(n1940) );
  sky130_fd_sc_hd__nand4_1 U2047 ( .A(n1965), .B(n1966), .C(n1967), .D(n1968), 
        .Y(n1964) );
  sky130_fd_sc_hd__a22oi_1 U2048 ( .A1(oam[966]), .A2(n600), .B1(oam[974]), 
        .B2(n64), .Y(n1968) );
  sky130_fd_sc_hd__a22oi_1 U2049 ( .A1(oam[982]), .A2(n2299), .B1(oam[990]), 
        .B2(n541), .Y(n1967) );
  sky130_fd_sc_hd__a22oi_1 U2050 ( .A1(oam[998]), .A2(n2309), .B1(oam[1006]), 
        .B2(n2324), .Y(n1966) );
  sky130_fd_sc_hd__a22oi_1 U2051 ( .A1(oam[1014]), .A2(n482), .B1(oam[1022]), 
        .B2(n2327), .Y(n1965) );
  sky130_fd_sc_hd__nand4_1 U2052 ( .A(n1969), .B(n1970), .C(n1971), .D(n1972), 
        .Y(n1963) );
  sky130_fd_sc_hd__a22oi_1 U2053 ( .A1(oam[902]), .A2(n2343), .B1(oam[910]), 
        .B2(n2346), .Y(n1972) );
  sky130_fd_sc_hd__a22oi_1 U2054 ( .A1(oam[918]), .A2(n558), .B1(oam[926]), 
        .B2(n2357), .Y(n1971) );
  sky130_fd_sc_hd__a22oi_1 U2055 ( .A1(oam[934]), .A2(n524), .B1(oam[942]), 
        .B2(n575), .Y(n1970) );
  sky130_fd_sc_hd__a22oi_1 U2056 ( .A1(oam[950]), .A2(n2366), .B1(oam[958]), 
        .B2(n2374), .Y(n1969) );
  sky130_fd_sc_hd__o21ai_1 U2057 ( .A1(n1973), .A2(n1974), .B1(n224), .Y(n1939) );
  sky130_fd_sc_hd__nand4_1 U2058 ( .A(n1975), .B(n1976), .C(n1977), .D(n1978), 
        .Y(n1974) );
  sky130_fd_sc_hd__a22oi_1 U2059 ( .A1(oam[454]), .A2(n605), .B1(oam[462]), 
        .B2(n80), .Y(n1978) );
  sky130_fd_sc_hd__a22oi_1 U2060 ( .A1(oam[470]), .A2(n2305), .B1(oam[478]), 
        .B2(n533), .Y(n1977) );
  sky130_fd_sc_hd__a22oi_1 U2061 ( .A1(oam[486]), .A2(n2307), .B1(oam[494]), 
        .B2(n2317), .Y(n1976) );
  sky130_fd_sc_hd__a22oi_1 U2062 ( .A1(oam[502]), .A2(n487), .B1(oam[510]), 
        .B2(n2327), .Y(n1975) );
  sky130_fd_sc_hd__nand4_1 U2063 ( .A(n1979), .B(n1980), .C(n1981), .D(n1982), 
        .Y(n1973) );
  sky130_fd_sc_hd__a22oi_1 U2064 ( .A1(oam[390]), .A2(n2343), .B1(oam[398]), 
        .B2(n2348), .Y(n1982) );
  sky130_fd_sc_hd__a22oi_1 U2065 ( .A1(oam[406]), .A2(n560), .B1(oam[414]), 
        .B2(n2357), .Y(n1981) );
  sky130_fd_sc_hd__a22oi_1 U2066 ( .A1(oam[422]), .A2(n528), .B1(oam[430]), 
        .B2(n567), .Y(n1980) );
  sky130_fd_sc_hd__a22oi_1 U2067 ( .A1(oam[438]), .A2(n2373), .B1(oam[446]), 
        .B2(n2382), .Y(n1979) );
  sky130_fd_sc_hd__nand4_1 U2068 ( .A(n1984), .B(n1983), .C(n1986), .D(n1985), 
        .Y(n1894) );
  sky130_fd_sc_hd__o21ai_1 U2069 ( .A1(n1987), .A2(n1988), .B1(n128), .Y(n1986) );
  sky130_fd_sc_hd__nand4_1 U2070 ( .A(n1990), .B(n1989), .C(n1991), .D(n1992), 
        .Y(n1988) );
  sky130_fd_sc_hd__a22oi_1 U2071 ( .A1(oam[1606]), .A2(n614), .B1(oam[1614]), 
        .B2(n36), .Y(n1992) );
  sky130_fd_sc_hd__a22oi_1 U2072 ( .A1(oam[1622]), .A2(n2301), .B1(oam[1630]), 
        .B2(n534), .Y(n1991) );
  sky130_fd_sc_hd__a22oi_1 U2073 ( .A1(oam[1638]), .A2(n2314), .B1(oam[1646]), 
        .B2(n2318), .Y(n1990) );
  sky130_fd_sc_hd__nand4_1 U2074 ( .A(n1993), .B(n1994), .C(n1995), .D(n1996), 
        .Y(n1987) );
  sky130_fd_sc_hd__a22oi_1 U2075 ( .A1(oam[1542]), .A2(n2335), .B1(oam[1550]), 
        .B2(n2348), .Y(n1996) );
  sky130_fd_sc_hd__a22oi_1 U2076 ( .A1(oam[1558]), .A2(n558), .B1(oam[1566]), 
        .B2(n2356), .Y(n1995) );
  sky130_fd_sc_hd__a22oi_1 U2077 ( .A1(oam[1574]), .A2(n527), .B1(oam[1582]), 
        .B2(n567), .Y(n1994) );
  sky130_fd_sc_hd__o21ai_1 U2078 ( .A1(n1997), .A2(n1998), .B1(n130), .Y(n1985) );
  sky130_fd_sc_hd__nand4_1 U2079 ( .A(n1999), .B(n2000), .C(n2001), .D(n2002), 
        .Y(n1998) );
  sky130_fd_sc_hd__a22oi_1 U2080 ( .A1(oam[1094]), .A2(n621), .B1(oam[1102]), 
        .B2(n81), .Y(n2002) );
  sky130_fd_sc_hd__a22oi_1 U2081 ( .A1(oam[1126]), .A2(n2310), .B1(oam[1134]), 
        .B2(n2323), .Y(n2000) );
  sky130_fd_sc_hd__nand4_1 U2082 ( .A(n2003), .B(n2004), .C(n2005), .D(n2006), 
        .Y(n1997) );
  sky130_fd_sc_hd__a22oi_1 U2083 ( .A1(oam[1030]), .A2(n2344), .B1(oam[1038]), 
        .B2(n2350), .Y(n2006) );
  sky130_fd_sc_hd__a22oi_1 U2084 ( .A1(oam[1046]), .A2(n561), .B1(oam[1054]), 
        .B2(n2356), .Y(n2005) );
  sky130_fd_sc_hd__a22oi_1 U2085 ( .A1(oam[1078]), .A2(n2370), .B1(oam[1086]), 
        .B2(n2378), .Y(n2003) );
  sky130_fd_sc_hd__o21ai_1 U2086 ( .A1(n2007), .A2(n2008), .B1(n129), .Y(n1984) );
  sky130_fd_sc_hd__nand4_1 U2087 ( .A(n2009), .B(n2010), .C(n2011), .D(n2012), 
        .Y(n2008) );
  sky130_fd_sc_hd__a22oi_1 U2088 ( .A1(oam[582]), .A2(n616), .B1(oam[590]), 
        .B2(n52), .Y(n2012) );
  sky130_fd_sc_hd__a22oi_1 U2089 ( .A1(oam[598]), .A2(n2300), .B1(oam[606]), 
        .B2(n534), .Y(n2011) );
  sky130_fd_sc_hd__a22oi_1 U2090 ( .A1(oam[614]), .A2(n2309), .B1(oam[622]), 
        .B2(n2319), .Y(n2010) );
  sky130_fd_sc_hd__a22oi_1 U2091 ( .A1(oam[630]), .A2(n489), .B1(oam[638]), 
        .B2(n2326), .Y(n2009) );
  sky130_fd_sc_hd__nand4_1 U2092 ( .A(n2013), .B(n2014), .C(n2015), .D(n2016), 
        .Y(n2007) );
  sky130_fd_sc_hd__a22oi_1 U2093 ( .A1(oam[518]), .A2(n2340), .B1(oam[526]), 
        .B2(n2348), .Y(n2016) );
  sky130_fd_sc_hd__a22oi_1 U2094 ( .A1(oam[534]), .A2(n551), .B1(oam[542]), 
        .B2(n2356), .Y(n2015) );
  sky130_fd_sc_hd__a22oi_1 U2095 ( .A1(oam[566]), .A2(n2365), .B1(oam[574]), 
        .B2(n2383), .Y(n2013) );
  sky130_fd_sc_hd__o21ai_1 U2096 ( .A1(n2017), .A2(n2018), .B1(n231), .Y(n1983) );
  sky130_fd_sc_hd__nand4_1 U2097 ( .A(n2019), .B(n2020), .C(n2021), .D(n2022), 
        .Y(n2018) );
  sky130_fd_sc_hd__a22oi_1 U2098 ( .A1(oam[70]), .A2(n615), .B1(oam[78]), .B2(
        n42), .Y(n2022) );
  sky130_fd_sc_hd__a22oi_1 U2099 ( .A1(oam[86]), .A2(n2298), .B1(oam[94]), 
        .B2(n545), .Y(n2021) );
  sky130_fd_sc_hd__a22oi_1 U2100 ( .A1(oam[102]), .A2(n2312), .B1(oam[110]), 
        .B2(n2322), .Y(n2020) );
  sky130_fd_sc_hd__a22oi_1 U2101 ( .A1(oam[118]), .A2(n490), .B1(oam[126]), 
        .B2(n2326), .Y(n2019) );
  sky130_fd_sc_hd__nand4_1 U2102 ( .A(n2023), .B(n2024), .C(n2025), .D(n2026), 
        .Y(n2017) );
  sky130_fd_sc_hd__a22oi_1 U2103 ( .A1(oam[6]), .A2(n2335), .B1(oam[14]), .B2(
        n2346), .Y(n2026) );
  sky130_fd_sc_hd__a22oi_1 U2104 ( .A1(oam[22]), .A2(n557), .B1(oam[30]), .B2(
        n2356), .Y(n2025) );
  sky130_fd_sc_hd__a22oi_1 U2105 ( .A1(oam[54]), .A2(n439), .B1(oam[62]), .B2(
        n2380), .Y(n2023) );
  sky130_fd_sc_hd__nand4_1 U2106 ( .A(n2027), .B(n2028), .C(n2030), .D(n2029), 
        .Y(n1893) );
  sky130_fd_sc_hd__nand4_1 U2107 ( .A(n2033), .B(n2034), .C(n2035), .D(n2036), 
        .Y(n2032) );
  sky130_fd_sc_hd__a22oi_1 U2108 ( .A1(oam[1734]), .A2(n605), .B1(oam[1742]), 
        .B2(n17), .Y(n2036) );
  sky130_fd_sc_hd__a22oi_1 U2109 ( .A1(oam[1750]), .A2(n2297), .B1(oam[1758]), 
        .B2(n543), .Y(n2035) );
  sky130_fd_sc_hd__a22oi_1 U2110 ( .A1(oam[1766]), .A2(n2308), .B1(oam[1774]), 
        .B2(n2320), .Y(n2034) );
  sky130_fd_sc_hd__a22oi_1 U2111 ( .A1(oam[1782]), .A2(n478), .B1(oam[1790]), 
        .B2(n2326), .Y(n2033) );
  sky130_fd_sc_hd__nand4_1 U2112 ( .A(n2037), .B(n2038), .C(n2039), .D(n2040), 
        .Y(n2031) );
  sky130_fd_sc_hd__o21ai_1 U2113 ( .A1(n2041), .A2(n2042), .B1(n220), .Y(n2029) );
  sky130_fd_sc_hd__nand4_1 U2114 ( .A(n2043), .B(n2044), .C(n2045), .D(n2046), 
        .Y(n2042) );
  sky130_fd_sc_hd__a22oi_1 U2115 ( .A1(oam[1222]), .A2(n616), .B1(oam[1230]), 
        .B2(n67), .Y(n2046) );
  sky130_fd_sc_hd__a22oi_1 U2116 ( .A1(oam[1238]), .A2(n2304), .B1(oam[1246]), 
        .B2(n534), .Y(n2045) );
  sky130_fd_sc_hd__a22oi_1 U2117 ( .A1(oam[1254]), .A2(n2306), .B1(oam[1262]), 
        .B2(n2316), .Y(n2044) );
  sky130_fd_sc_hd__nand4_1 U2118 ( .A(n2047), .B(n2048), .C(n2049), .D(n2050), 
        .Y(n2041) );
  sky130_fd_sc_hd__o21ai_1 U2119 ( .A1(n2051), .A2(n2052), .B1(n222), .Y(n2028) );
  sky130_fd_sc_hd__nand4_1 U2120 ( .A(n2053), .B(n2054), .C(n2055), .D(n2056), 
        .Y(n2052) );
  sky130_fd_sc_hd__a22oi_1 U2121 ( .A1(oam[710]), .A2(n613), .B1(oam[718]), 
        .B2(n79), .Y(n2056) );
  sky130_fd_sc_hd__a22oi_1 U2122 ( .A1(oam[726]), .A2(n2303), .B1(oam[734]), 
        .B2(n535), .Y(n2055) );
  sky130_fd_sc_hd__a22oi_1 U2123 ( .A1(oam[742]), .A2(n472), .B1(oam[750]), 
        .B2(n2323), .Y(n2054) );
  sky130_fd_sc_hd__nand4_1 U2124 ( .A(n2057), .B(n2058), .C(n2059), .D(n2060), 
        .Y(n2051) );
  sky130_fd_sc_hd__a22oi_1 U2125 ( .A1(oam[646]), .A2(n2339), .B1(oam[654]), 
        .B2(n2352), .Y(n2060) );
  sky130_fd_sc_hd__a22oi_1 U2126 ( .A1(oam[662]), .A2(n562), .B1(oam[670]), 
        .B2(n2356), .Y(n2059) );
  sky130_fd_sc_hd__o21ai_1 U2127 ( .A1(n2061), .A2(n2062), .B1(n226), .Y(n2027) );
  sky130_fd_sc_hd__nand4_1 U2128 ( .A(n2063), .B(n2064), .C(n2065), .D(n2066), 
        .Y(n2062) );
  sky130_fd_sc_hd__a22oi_1 U2129 ( .A1(oam[198]), .A2(n621), .B1(oam[206]), 
        .B2(n44), .Y(n2066) );
  sky130_fd_sc_hd__a22oi_1 U2130 ( .A1(oam[214]), .A2(n2302), .B1(oam[222]), 
        .B2(n541), .Y(n2065) );
  sky130_fd_sc_hd__a22oi_1 U2131 ( .A1(oam[246]), .A2(n486), .B1(oam[254]), 
        .B2(n2326), .Y(n2063) );
  sky130_fd_sc_hd__nand4_1 U2132 ( .A(n2067), .B(n2068), .C(n2069), .D(n2070), 
        .Y(n2061) );
  sky130_fd_sc_hd__a22oi_1 U2133 ( .A1(oam[134]), .A2(n2342), .B1(oam[142]), 
        .B2(n2348), .Y(n2070) );
  sky130_fd_sc_hd__a22oi_1 U2134 ( .A1(oam[150]), .A2(n549), .B1(oam[158]), 
        .B2(n2356), .Y(n2069) );
  sky130_fd_sc_hd__a22oi_1 U2135 ( .A1(oam[182]), .A2(n439), .B1(oam[190]), 
        .B2(n2380), .Y(n2067) );
  sky130_fd_sc_hd__o21ai_1 U2136 ( .A1(n2075), .A2(n2076), .B1(n103), .Y(n2074) );
  sky130_fd_sc_hd__nand4_1 U2137 ( .A(n2077), .B(n2078), .C(n2079), .D(n2080), 
        .Y(n2076) );
  sky130_fd_sc_hd__a22oi_1 U2138 ( .A1(oam[1863]), .A2(n616), .B1(oam[1871]), 
        .B2(n62), .Y(n2080) );
  sky130_fd_sc_hd__a22oi_1 U2139 ( .A1(oam[1879]), .A2(n2299), .B1(oam[1887]), 
        .B2(n533), .Y(n2079) );
  sky130_fd_sc_hd__a22oi_1 U2140 ( .A1(oam[1895]), .A2(n2309), .B1(oam[1903]), 
        .B2(n2324), .Y(n2078) );
  sky130_fd_sc_hd__a22oi_1 U2141 ( .A1(oam[1911]), .A2(n486), .B1(oam[1919]), 
        .B2(n2326), .Y(n2077) );
  sky130_fd_sc_hd__nand4_1 U2142 ( .A(n2081), .B(n2082), .C(n2083), .D(n2084), 
        .Y(n2075) );
  sky130_fd_sc_hd__a22oi_1 U2143 ( .A1(oam[1799]), .A2(n2343), .B1(oam[1807]), 
        .B2(n2353), .Y(n2084) );
  sky130_fd_sc_hd__a22oi_1 U2144 ( .A1(oam[1815]), .A2(n557), .B1(oam[1823]), 
        .B2(n2356), .Y(n2083) );
  sky130_fd_sc_hd__a22oi_1 U2145 ( .A1(oam[1831]), .A2(n530), .B1(oam[1839]), 
        .B2(n575), .Y(n2082) );
  sky130_fd_sc_hd__a22oi_1 U2146 ( .A1(oam[1847]), .A2(n2368), .B1(oam[1855]), 
        .B2(n2374), .Y(n2081) );
  sky130_fd_sc_hd__o21ai_1 U2147 ( .A1(n2085), .A2(n2086), .B1(n228), .Y(n2073) );
  sky130_fd_sc_hd__nand4_1 U2148 ( .A(n2088), .B(n2089), .C(n2090), .D(n2091), 
        .Y(n2086) );
  sky130_fd_sc_hd__a22oi_1 U2149 ( .A1(oam[1351]), .A2(n618), .B1(oam[1359]), 
        .B2(n72), .Y(n2091) );
  sky130_fd_sc_hd__a22oi_1 U2150 ( .A1(oam[1367]), .A2(n2301), .B1(oam[1375]), 
        .B2(n543), .Y(n2090) );
  sky130_fd_sc_hd__a22oi_1 U2151 ( .A1(oam[1383]), .A2(n2312), .B1(oam[1391]), 
        .B2(n445), .Y(n2089) );
  sky130_fd_sc_hd__a22oi_1 U2152 ( .A1(oam[1399]), .A2(n489), .B1(oam[1407]), 
        .B2(n2326), .Y(n2088) );
  sky130_fd_sc_hd__nand4_1 U2153 ( .A(n2092), .B(n2093), .C(n2094), .D(n2095), 
        .Y(n2085) );
  sky130_fd_sc_hd__a22oi_1 U2154 ( .A1(oam[1287]), .A2(n2339), .B1(oam[1295]), 
        .B2(n2346), .Y(n2095) );
  sky130_fd_sc_hd__a22oi_1 U2155 ( .A1(oam[1303]), .A2(n560), .B1(oam[1311]), 
        .B2(n2356), .Y(n2094) );
  sky130_fd_sc_hd__a22oi_1 U2156 ( .A1(oam[1319]), .A2(n518), .B1(oam[1327]), 
        .B2(n577), .Y(n2093) );
  sky130_fd_sc_hd__a22oi_1 U2157 ( .A1(oam[1335]), .A2(n2373), .B1(oam[1343]), 
        .B2(n2375), .Y(n2092) );
  sky130_fd_sc_hd__o21ai_1 U2158 ( .A1(n2096), .A2(n2097), .B1(n227), .Y(n2072) );
  sky130_fd_sc_hd__nand4_1 U2159 ( .A(n2098), .B(n2099), .C(n2100), .D(n2101), 
        .Y(n2097) );
  sky130_fd_sc_hd__a22oi_1 U2160 ( .A1(oam[839]), .A2(n619), .B1(oam[847]), 
        .B2(n78), .Y(n2101) );
  sky130_fd_sc_hd__a22oi_1 U2161 ( .A1(oam[855]), .A2(n2298), .B1(oam[863]), 
        .B2(n542), .Y(n2100) );
  sky130_fd_sc_hd__a22oi_1 U2162 ( .A1(oam[871]), .A2(n2308), .B1(oam[879]), 
        .B2(n2324), .Y(n2099) );
  sky130_fd_sc_hd__a22oi_1 U2163 ( .A1(oam[887]), .A2(n483), .B1(oam[895]), 
        .B2(n2326), .Y(n2098) );
  sky130_fd_sc_hd__nand4_1 U2164 ( .A(n2102), .B(n2103), .C(n2104), .D(n2105), 
        .Y(n2096) );
  sky130_fd_sc_hd__a22oi_1 U2165 ( .A1(oam[775]), .A2(n2335), .B1(oam[783]), 
        .B2(n2351), .Y(n2105) );
  sky130_fd_sc_hd__a22oi_1 U2166 ( .A1(oam[791]), .A2(n560), .B1(oam[799]), 
        .B2(n2356), .Y(n2104) );
  sky130_fd_sc_hd__a22oi_1 U2167 ( .A1(oam[807]), .A2(n517), .B1(oam[815]), 
        .B2(n572), .Y(n2103) );
  sky130_fd_sc_hd__a22oi_1 U2168 ( .A1(oam[823]), .A2(n2367), .B1(oam[831]), 
        .B2(n2374), .Y(n2102) );
  sky130_fd_sc_hd__o21ai_1 U2169 ( .A1(n2106), .A2(n2107), .B1(n229), .Y(n2071) );
  sky130_fd_sc_hd__nand4_1 U2170 ( .A(n2108), .B(n2109), .C(n2110), .D(n2111), 
        .Y(n2107) );
  sky130_fd_sc_hd__a22oi_1 U2171 ( .A1(oam[327]), .A2(n586), .B1(oam[335]), 
        .B2(n66), .Y(n2111) );
  sky130_fd_sc_hd__a22oi_1 U2172 ( .A1(oam[343]), .A2(n2296), .B1(oam[351]), 
        .B2(n533), .Y(n2110) );
  sky130_fd_sc_hd__a22oi_1 U2173 ( .A1(oam[359]), .A2(n2307), .B1(oam[367]), 
        .B2(n2318), .Y(n2109) );
  sky130_fd_sc_hd__a22oi_1 U2174 ( .A1(oam[375]), .A2(n478), .B1(oam[383]), 
        .B2(n2326), .Y(n2108) );
  sky130_fd_sc_hd__nand4_1 U2175 ( .A(n2112), .B(n2113), .C(n2114), .D(n2115), 
        .Y(n2106) );
  sky130_fd_sc_hd__a22oi_1 U2176 ( .A1(oam[263]), .A2(n2344), .B1(oam[271]), 
        .B2(n2349), .Y(n2115) );
  sky130_fd_sc_hd__a22oi_1 U2177 ( .A1(oam[279]), .A2(n551), .B1(oam[287]), 
        .B2(n2356), .Y(n2114) );
  sky130_fd_sc_hd__a22oi_1 U2178 ( .A1(oam[295]), .A2(n524), .B1(oam[303]), 
        .B2(n572), .Y(n2113) );
  sky130_fd_sc_hd__a22oi_1 U2179 ( .A1(oam[311]), .A2(n2367), .B1(oam[319]), 
        .B2(n2374), .Y(n2112) );
  sky130_fd_sc_hd__o21ai_1 U2180 ( .A1(n2120), .A2(n2121), .B1(n219), .Y(n2119) );
  sky130_fd_sc_hd__nand4_1 U2181 ( .A(n2122), .B(n2123), .C(n2124), .D(n2125), 
        .Y(n2121) );
  sky130_fd_sc_hd__a22oi_1 U2182 ( .A1(oam[1991]), .A2(n621), .B1(oam[1999]), 
        .B2(n79), .Y(n2125) );
  sky130_fd_sc_hd__a22oi_1 U2183 ( .A1(oam[2007]), .A2(n2296), .B1(oam[2015]), 
        .B2(n543), .Y(n2124) );
  sky130_fd_sc_hd__a22oi_1 U2184 ( .A1(oam[2023]), .A2(n472), .B1(oam[2031]), 
        .B2(n2321), .Y(n2123) );
  sky130_fd_sc_hd__a22oi_1 U2185 ( .A1(oam[2039]), .A2(n478), .B1(oam[2047]), 
        .B2(n2326), .Y(n2122) );
  sky130_fd_sc_hd__nand4_1 U2186 ( .A(n2126), .B(n2127), .C(n2128), .D(n2129), 
        .Y(n2120) );
  sky130_fd_sc_hd__a22oi_1 U2187 ( .A1(oam[1927]), .A2(n2338), .B1(oam[1935]), 
        .B2(n2348), .Y(n2129) );
  sky130_fd_sc_hd__a22oi_1 U2188 ( .A1(oam[1943]), .A2(n563), .B1(oam[1951]), 
        .B2(n2356), .Y(n2128) );
  sky130_fd_sc_hd__a22oi_1 U2189 ( .A1(oam[1959]), .A2(n517), .B1(oam[1967]), 
        .B2(n574), .Y(n2127) );
  sky130_fd_sc_hd__a22oi_1 U2190 ( .A1(oam[1975]), .A2(n2372), .B1(oam[1983]), 
        .B2(n2381), .Y(n2126) );
  sky130_fd_sc_hd__o21ai_1 U2191 ( .A1(n2130), .A2(n2131), .B1(n221), .Y(n2118) );
  sky130_fd_sc_hd__nand4_1 U2192 ( .A(n2132), .B(n2133), .C(n2134), .D(n2135), 
        .Y(n2131) );
  sky130_fd_sc_hd__a22oi_1 U2193 ( .A1(oam[1479]), .A2(n621), .B1(oam[1487]), 
        .B2(n50), .Y(n2135) );
  sky130_fd_sc_hd__a22oi_1 U2194 ( .A1(oam[1495]), .A2(n2297), .B1(oam[1503]), 
        .B2(n540), .Y(n2134) );
  sky130_fd_sc_hd__a22oi_1 U2195 ( .A1(oam[1511]), .A2(n2312), .B1(oam[1519]), 
        .B2(n2316), .Y(n2133) );
  sky130_fd_sc_hd__a22oi_1 U2196 ( .A1(oam[1527]), .A2(n479), .B1(oam[1535]), 
        .B2(n2325), .Y(n2132) );
  sky130_fd_sc_hd__nand4_1 U2197 ( .A(n2136), .B(n2137), .C(n2138), .D(n2139), 
        .Y(n2130) );
  sky130_fd_sc_hd__a22oi_1 U2198 ( .A1(oam[1415]), .A2(n2344), .B1(oam[1423]), 
        .B2(n2354), .Y(n2139) );
  sky130_fd_sc_hd__a22oi_1 U2199 ( .A1(oam[1431]), .A2(n551), .B1(oam[1439]), 
        .B2(n2355), .Y(n2138) );
  sky130_fd_sc_hd__a22oi_1 U2200 ( .A1(oam[1447]), .A2(n525), .B1(oam[1455]), 
        .B2(n574), .Y(n2137) );
  sky130_fd_sc_hd__a22oi_1 U2201 ( .A1(oam[1463]), .A2(n439), .B1(oam[1471]), 
        .B2(n2375), .Y(n2136) );
  sky130_fd_sc_hd__o21ai_1 U2202 ( .A1(n2140), .A2(n2141), .B1(n223), .Y(n2117) );
  sky130_fd_sc_hd__nand4_1 U2203 ( .A(n2142), .B(n2143), .C(n2144), .D(n2145), 
        .Y(n2141) );
  sky130_fd_sc_hd__a22oi_1 U2204 ( .A1(oam[967]), .A2(n616), .B1(oam[975]), 
        .B2(n78), .Y(n2145) );
  sky130_fd_sc_hd__a22oi_1 U2205 ( .A1(oam[983]), .A2(n2302), .B1(oam[991]), 
        .B2(n540), .Y(n2144) );
  sky130_fd_sc_hd__a22oi_1 U2206 ( .A1(oam[999]), .A2(n2314), .B1(oam[1007]), 
        .B2(n2315), .Y(n2143) );
  sky130_fd_sc_hd__a22oi_1 U2207 ( .A1(oam[1015]), .A2(n489), .B1(oam[1023]), 
        .B2(n2325), .Y(n2142) );
  sky130_fd_sc_hd__nand4_1 U2208 ( .A(n2146), .B(n2147), .C(n2148), .D(n2149), 
        .Y(n2140) );
  sky130_fd_sc_hd__a22oi_1 U2209 ( .A1(oam[903]), .A2(n2340), .B1(oam[911]), 
        .B2(n2350), .Y(n2149) );
  sky130_fd_sc_hd__a22oi_1 U2210 ( .A1(oam[919]), .A2(n558), .B1(oam[927]), 
        .B2(n2355), .Y(n2148) );
  sky130_fd_sc_hd__a22oi_1 U2211 ( .A1(oam[935]), .A2(n529), .B1(oam[943]), 
        .B2(n567), .Y(n2147) );
  sky130_fd_sc_hd__a22oi_1 U2212 ( .A1(oam[951]), .A2(n2373), .B1(oam[959]), 
        .B2(n2374), .Y(n2146) );
  sky130_fd_sc_hd__o21ai_1 U2213 ( .A1(n2150), .A2(n2151), .B1(n224), .Y(n2116) );
  sky130_fd_sc_hd__nand4_1 U2214 ( .A(n2153), .B(n2154), .C(n2155), .D(n2156), 
        .Y(n2151) );
  sky130_fd_sc_hd__a22oi_1 U2215 ( .A1(oam[455]), .A2(n621), .B1(oam[463]), 
        .B2(n77), .Y(n2156) );
  sky130_fd_sc_hd__a22oi_1 U2216 ( .A1(oam[471]), .A2(n2305), .B1(oam[479]), 
        .B2(n543), .Y(n2155) );
  sky130_fd_sc_hd__a22oi_1 U2217 ( .A1(oam[487]), .A2(n2311), .B1(oam[495]), 
        .B2(n2322), .Y(n2154) );
  sky130_fd_sc_hd__a22oi_1 U2218 ( .A1(oam[503]), .A2(n478), .B1(oam[511]), 
        .B2(n2325), .Y(n2153) );
  sky130_fd_sc_hd__nand4_1 U2219 ( .A(n2157), .B(n2158), .C(n2159), .D(n2160), 
        .Y(n2150) );
  sky130_fd_sc_hd__a22oi_1 U2220 ( .A1(oam[391]), .A2(n2341), .B1(oam[399]), 
        .B2(n2353), .Y(n2160) );
  sky130_fd_sc_hd__a22oi_1 U2221 ( .A1(oam[407]), .A2(n548), .B1(oam[415]), 
        .B2(n2355), .Y(n2159) );
  sky130_fd_sc_hd__a22oi_1 U2222 ( .A1(oam[423]), .A2(n530), .B1(oam[431]), 
        .B2(n573), .Y(n2158) );
  sky130_fd_sc_hd__a22oi_1 U2223 ( .A1(oam[439]), .A2(n439), .B1(oam[447]), 
        .B2(n2375), .Y(n2157) );
  sky130_fd_sc_hd__o21ai_1 U2224 ( .A1(n2165), .A2(n2166), .B1(n128), .Y(n2164) );
  sky130_fd_sc_hd__nand4_1 U2225 ( .A(n2167), .B(n2168), .C(n2169), .D(n2170), 
        .Y(n2166) );
  sky130_fd_sc_hd__a22oi_1 U2226 ( .A1(oam[1607]), .A2(n589), .B1(oam[1615]), 
        .B2(n49), .Y(n2170) );
  sky130_fd_sc_hd__a22oi_1 U2227 ( .A1(oam[1623]), .A2(n2304), .B1(oam[1631]), 
        .B2(n540), .Y(n2169) );
  sky130_fd_sc_hd__a22oi_1 U2228 ( .A1(oam[1639]), .A2(n472), .B1(oam[1647]), 
        .B2(n2319), .Y(n2168) );
  sky130_fd_sc_hd__a22oi_1 U2229 ( .A1(oam[1655]), .A2(n483), .B1(oam[1663]), 
        .B2(n2325), .Y(n2167) );
  sky130_fd_sc_hd__nand4_1 U2230 ( .A(n2171), .B(n2172), .C(n2173), .D(n2174), 
        .Y(n2165) );
  sky130_fd_sc_hd__a22oi_1 U2231 ( .A1(oam[1543]), .A2(n2340), .B1(oam[1551]), 
        .B2(n2346), .Y(n2174) );
  sky130_fd_sc_hd__a22oi_1 U2232 ( .A1(oam[1559]), .A2(n551), .B1(oam[1567]), 
        .B2(n2355), .Y(n2173) );
  sky130_fd_sc_hd__a22oi_1 U2233 ( .A1(oam[1575]), .A2(n517), .B1(oam[1583]), 
        .B2(n577), .Y(n2172) );
  sky130_fd_sc_hd__a22oi_1 U2234 ( .A1(oam[1591]), .A2(n2371), .B1(oam[1599]), 
        .B2(n2375), .Y(n2171) );
  sky130_fd_sc_hd__o21ai_1 U2235 ( .A1(n2175), .A2(n2176), .B1(n130), .Y(n2163) );
  sky130_fd_sc_hd__nand4_1 U2236 ( .A(n2177), .B(n2178), .C(n2179), .D(n2180), 
        .Y(n2176) );
  sky130_fd_sc_hd__a22oi_1 U2237 ( .A1(oam[1095]), .A2(n621), .B1(oam[1103]), 
        .B2(n9), .Y(n2180) );
  sky130_fd_sc_hd__a22oi_1 U2238 ( .A1(oam[1111]), .A2(n2300), .B1(oam[1119]), 
        .B2(n543), .Y(n2179) );
  sky130_fd_sc_hd__a22oi_1 U2239 ( .A1(oam[1127]), .A2(n2308), .B1(oam[1135]), 
        .B2(n2320), .Y(n2178) );
  sky130_fd_sc_hd__a22oi_1 U2240 ( .A1(oam[1143]), .A2(n478), .B1(oam[1151]), 
        .B2(n2325), .Y(n2177) );
  sky130_fd_sc_hd__nand4_1 U2241 ( .A(n2181), .B(n2182), .C(n2183), .D(n2184), 
        .Y(n2175) );
  sky130_fd_sc_hd__a22oi_1 U2242 ( .A1(oam[1031]), .A2(n2342), .B1(oam[1039]), 
        .B2(n2353), .Y(n2184) );
  sky130_fd_sc_hd__a22oi_1 U2243 ( .A1(oam[1047]), .A2(n549), .B1(oam[1055]), 
        .B2(n2355), .Y(n2183) );
  sky130_fd_sc_hd__a22oi_1 U2244 ( .A1(oam[1063]), .A2(n518), .B1(oam[1071]), 
        .B2(n576), .Y(n2182) );
  sky130_fd_sc_hd__a22oi_1 U2245 ( .A1(oam[1079]), .A2(n2368), .B1(oam[1087]), 
        .B2(n2375), .Y(n2181) );
  sky130_fd_sc_hd__o21ai_1 U2246 ( .A1(n2185), .A2(n2186), .B1(n129), .Y(n2162) );
  sky130_fd_sc_hd__nand4_1 U2247 ( .A(n2187), .B(n2188), .C(n2189), .D(n2190), 
        .Y(n2186) );
  sky130_fd_sc_hd__a22oi_1 U2248 ( .A1(oam[583]), .A2(n602), .B1(oam[591]), 
        .B2(n70), .Y(n2190) );
  sky130_fd_sc_hd__a22oi_1 U2249 ( .A1(oam[599]), .A2(n2299), .B1(oam[607]), 
        .B2(n535), .Y(n2189) );
  sky130_fd_sc_hd__a22oi_1 U2250 ( .A1(oam[615]), .A2(n2313), .B1(oam[623]), 
        .B2(n2323), .Y(n2188) );
  sky130_fd_sc_hd__a22oi_1 U2251 ( .A1(oam[631]), .A2(n480), .B1(oam[639]), 
        .B2(n2325), .Y(n2187) );
  sky130_fd_sc_hd__nand4_1 U2252 ( .A(n2191), .B(n2192), .C(n2193), .D(n2194), 
        .Y(n2185) );
  sky130_fd_sc_hd__a22oi_1 U2253 ( .A1(oam[519]), .A2(n2344), .B1(oam[527]), 
        .B2(n2345), .Y(n2194) );
  sky130_fd_sc_hd__a22oi_1 U2254 ( .A1(oam[535]), .A2(n560), .B1(oam[543]), 
        .B2(n2355), .Y(n2193) );
  sky130_fd_sc_hd__a22oi_1 U2255 ( .A1(oam[551]), .A2(n519), .B1(oam[559]), 
        .B2(n575), .Y(n2192) );
  sky130_fd_sc_hd__a22oi_1 U2256 ( .A1(oam[567]), .A2(n2365), .B1(oam[575]), 
        .B2(n2381), .Y(n2191) );
  sky130_fd_sc_hd__o21ai_1 U2257 ( .A1(n2195), .A2(n2196), .B1(n231), .Y(n2161) );
  sky130_fd_sc_hd__nand4_1 U2258 ( .A(n2197), .B(n2198), .C(n2199), .D(n2200), 
        .Y(n2196) );
  sky130_fd_sc_hd__a22oi_1 U2259 ( .A1(oam[71]), .A2(n611), .B1(oam[79]), .B2(
        n84), .Y(n2200) );
  sky130_fd_sc_hd__a22oi_1 U2260 ( .A1(oam[87]), .A2(n2304), .B1(oam[95]), 
        .B2(n535), .Y(n2199) );
  sky130_fd_sc_hd__a22oi_1 U2261 ( .A1(oam[103]), .A2(n2313), .B1(oam[111]), 
        .B2(n2323), .Y(n2198) );
  sky130_fd_sc_hd__a22oi_1 U2262 ( .A1(oam[119]), .A2(n488), .B1(oam[127]), 
        .B2(n2325), .Y(n2197) );
  sky130_fd_sc_hd__nand4_1 U2263 ( .A(n2201), .B(n2202), .C(n2203), .D(n2204), 
        .Y(n2195) );
  sky130_fd_sc_hd__a22oi_1 U2264 ( .A1(oam[7]), .A2(n2342), .B1(oam[15]), .B2(
        n2350), .Y(n2204) );
  sky130_fd_sc_hd__a22oi_1 U2265 ( .A1(oam[23]), .A2(n551), .B1(oam[31]), .B2(
        n2355), .Y(n2203) );
  sky130_fd_sc_hd__a22oi_1 U2266 ( .A1(oam[39]), .A2(n519), .B1(oam[47]), .B2(
        n568), .Y(n2202) );
  sky130_fd_sc_hd__a22oi_1 U2267 ( .A1(oam[55]), .A2(n2373), .B1(oam[63]), 
        .B2(n2375), .Y(n2201) );
  sky130_fd_sc_hd__o21ai_1 U2268 ( .A1(n2209), .A2(n2210), .B1(n127), .Y(n2208) );
  sky130_fd_sc_hd__nand4_1 U2269 ( .A(n2213), .B(n2214), .C(n2215), .D(n2216), 
        .Y(n2210) );
  sky130_fd_sc_hd__a22oi_1 U2270 ( .A1(oam[1767]), .A2(n471), .B1(oam[1775]), 
        .B2(n2316), .Y(n2214) );
  sky130_fd_sc_hd__nand4_1 U2271 ( .A(n2217), .B(n2218), .C(n2219), .D(n2220), 
        .Y(n2209) );
  sky130_fd_sc_hd__a22oi_1 U2272 ( .A1(oam[1671]), .A2(n2336), .B1(oam[1679]), 
        .B2(n2347), .Y(n2220) );
  sky130_fd_sc_hd__a22oi_1 U2273 ( .A1(oam[1687]), .A2(n550), .B1(oam[1695]), 
        .B2(n2355), .Y(n2219) );
  sky130_fd_sc_hd__a22oi_1 U2274 ( .A1(oam[1719]), .A2(n2370), .B1(oam[1727]), 
        .B2(n2377), .Y(n2217) );
  sky130_fd_sc_hd__o21ai_1 U2275 ( .A1(n2221), .A2(n2222), .B1(n220), .Y(n2207) );
  sky130_fd_sc_hd__nand2_1 U2276 ( .A(N37), .B(n2212), .Y(n2223) );
  sky130_fd_sc_hd__inv_1 U2277 ( .A(N38), .Y(n2212) );
  sky130_fd_sc_hd__nand4_1 U2278 ( .A(n2224), .B(n2225), .C(n2226), .D(n2227), 
        .Y(n2222) );
  sky130_fd_sc_hd__a22oi_1 U2279 ( .A1(oam[1223]), .A2(n621), .B1(oam[1231]), 
        .B2(n43), .Y(n2227) );
  sky130_fd_sc_hd__a22oi_1 U2280 ( .A1(oam[1239]), .A2(n2297), .B1(oam[1247]), 
        .B2(n541), .Y(n2226) );
  sky130_fd_sc_hd__a22oi_1 U2281 ( .A1(oam[1255]), .A2(n2308), .B1(oam[1263]), 
        .B2(n2319), .Y(n2225) );
  sky130_fd_sc_hd__nand4_1 U2282 ( .A(n2228), .B(n2229), .C(n2230), .D(n2231), 
        .Y(n2221) );
  sky130_fd_sc_hd__a22oi_1 U2283 ( .A1(oam[1159]), .A2(n2336), .B1(oam[1167]), 
        .B2(n2351), .Y(n2231) );
  sky130_fd_sc_hd__o21ai_1 U2284 ( .A1(n2232), .A2(n2233), .B1(n222), .Y(n2206) );
  sky130_fd_sc_hd__inv_1 U2285 ( .A(N37), .Y(n2211) );
  sky130_fd_sc_hd__nand4_1 U2286 ( .A(n2234), .B(n2235), .C(n2236), .D(n2237), 
        .Y(n2233) );
  sky130_fd_sc_hd__a22oi_1 U2287 ( .A1(oam[711]), .A2(n621), .B1(oam[719]), 
        .B2(n47), .Y(n2237) );
  sky130_fd_sc_hd__a22oi_1 U2288 ( .A1(oam[727]), .A2(n2296), .B1(oam[735]), 
        .B2(n545), .Y(n2236) );
  sky130_fd_sc_hd__a22oi_1 U2289 ( .A1(oam[743]), .A2(n472), .B1(oam[751]), 
        .B2(n2324), .Y(n2235) );
  sky130_fd_sc_hd__nand4_1 U2290 ( .A(n2238), .B(n2239), .C(n2240), .D(n2241), 
        .Y(n2232) );
  sky130_fd_sc_hd__a22oi_1 U2291 ( .A1(oam[647]), .A2(n2338), .B1(oam[655]), 
        .B2(n2349), .Y(n2241) );
  sky130_fd_sc_hd__a22oi_1 U2292 ( .A1(oam[663]), .A2(n558), .B1(oam[671]), 
        .B2(n2355), .Y(n2240) );
  sky130_fd_sc_hd__a22oi_1 U2293 ( .A1(oam[679]), .A2(n518), .B1(oam[687]), 
        .B2(n576), .Y(n2239) );
  sky130_fd_sc_hd__o21ai_1 U2294 ( .A1(n2242), .A2(n2243), .B1(n226), .Y(n2205) );
  sky130_fd_sc_hd__inv_1 U2295 ( .A(N35), .Y(n2152) );
  sky130_fd_sc_hd__nand4_1 U2296 ( .A(n2244), .B(n2245), .C(n2246), .D(n2247), 
        .Y(n2243) );
  sky130_fd_sc_hd__a22oi_1 U2297 ( .A1(oam[199]), .A2(n600), .B1(oam[207]), 
        .B2(n57), .Y(n2247) );
  sky130_fd_sc_hd__a22oi_1 U2298 ( .A1(oam[215]), .A2(n2303), .B1(oam[223]), 
        .B2(n545), .Y(n2246) );
  sky130_fd_sc_hd__nand2_1 U2299 ( .A(n2249), .B(n2254), .Y(n2253) );
  sky130_fd_sc_hd__a22oi_1 U2300 ( .A1(oam[231]), .A2(n2313), .B1(oam[239]), 
        .B2(n445), .Y(n2245) );
  sky130_fd_sc_hd__nand2_1 U2301 ( .A(n2250), .B(n2260), .Y(n2259) );
  sky130_fd_sc_hd__a22oi_1 U2302 ( .A1(oam[247]), .A2(n481), .B1(oam[255]), 
        .B2(n2325), .Y(n2244) );
  sky130_fd_sc_hd__nand2_1 U2303 ( .A(n2260), .B(n2256), .Y(n2262) );
  sky130_fd_sc_hd__nand4_1 U2304 ( .A(n2265), .B(n2266), .C(n2267), .D(n2268), 
        .Y(n2242) );
  sky130_fd_sc_hd__a22oi_1 U2305 ( .A1(oam[135]), .A2(n2343), .B1(oam[143]), 
        .B2(n2346), .Y(n2268) );
  sky130_fd_sc_hd__a22oi_1 U2306 ( .A1(oam[151]), .A2(n557), .B1(oam[159]), 
        .B2(n2355), .Y(n2267) );
  sky130_fd_sc_hd__nand2_1 U2307 ( .A(N34), .B(N33), .Y(n2274) );
  sky130_fd_sc_hd__a22oi_1 U2308 ( .A1(oam[167]), .A2(n525), .B1(oam[175]), 
        .B2(n575), .Y(n2266) );
  sky130_fd_sc_hd__a22oi_1 U2309 ( .A1(oam[183]), .A2(n2372), .B1(oam[191]), 
        .B2(n2383), .Y(n2265) );
  sky130_fd_sc_hd__nand2_1 U2310 ( .A(n2283), .B(n2278), .Y(n2282) );
  sky130_fd_sc_hd__nand2_1 U2311 ( .A(N31), .B(n2283), .Y(n2285) );
  sky130_fd_sc_hd__inv_4 U2312 ( .A(n2255), .Y(n839) );
  sky130_fd_sc_hd__o211ai_4 U2313 ( .A1(n2565), .A2(n2493), .B1(n2766), .C1(
        n2492), .Y(n2526) );
  sky130_fd_sc_hd__inv_1 U2314 ( .A(N31), .Y(n2497) );
  sky130_fd_sc_hd__inv_1 U2315 ( .A(N32), .Y(n2496) );
  sky130_fd_sc_hd__inv_1 U2316 ( .A(oam_load), .Y(n2485) );
  sky130_fd_sc_hd__inv_1 U2317 ( .A(state[1]), .Y(n2483) );
  sky130_fd_sc_hd__nand2b_1 U2318 ( .A_N(n283), .B(n2483), .Y(n2750) );
  sky130_fd_sc_hd__inv_1 U2319 ( .A(spr_y_coord[8]), .Y(n2754) );
  sky130_fd_sc_hd__inv_1 U2320 ( .A(spr_y_coord[7]), .Y(n2487) );
  sky130_fd_sc_hd__nand4_1 U2321 ( .A(n2486), .B(n2754), .C(n2487), .D(n2751), 
        .Y(n2767) );
  sky130_fd_sc_hd__nand2_1 U2322 ( .A(oam_load), .B(ce), .Y(n2490) );
  sky130_fd_sc_hd__inv_1 U2323 ( .A(oam_ptr_load), .Y(n2492) );
  sky130_fd_sc_hd__nand2_1 U2324 ( .A(sprites_enabled), .B(cycle[0]), .Y(n2488) );
  sky130_fd_sc_hd__nand2_1 U2325 ( .A(n2492), .B(n2488), .Y(n2489) );
  sky130_fd_sc_hd__nand2_1 U2326 ( .A(ce), .B(n2489), .Y(n2491) );
  sky130_fd_sc_hd__nand3_1 U2327 ( .A(n2758), .B(n2490), .C(n2491), .Y(n2525)
         );
  sky130_fd_sc_hd__nand3_1 U2328 ( .A(oam_ptr_load), .B(n2766), .C(n2525), .Y(
        n2539) );
  sky130_fd_sc_hd__inv_1 U2329 ( .A(oam_inc[0]), .Y(n2498) );
  sky130_fd_sc_hd__nor2_1 U2330 ( .A(n2526), .B(n2498), .Y(n2494) );
  sky130_fd_sc_hd__o21ai_1 U2331 ( .A1(oam_inc[0]), .A2(n2526), .B1(n2525), 
        .Y(n2499) );
  sky130_fd_sc_hd__mux2i_1 U2332 ( .A0(n2494), .A1(n2499), .S(N31), .Y(n2495)
         );
  sky130_fd_sc_hd__o21ai_1 U2333 ( .A1(n2539), .A2(n2398), .B1(n2495), .Y(n828) );
  sky130_fd_sc_hd__nand2_1 U2334 ( .A(N31), .B(n2496), .Y(n2545) );
  sky130_fd_sc_hd__nand2_1 U2335 ( .A(N32), .B(n2497), .Y(n2541) );
  sky130_fd_sc_hd__o21ai_1 U2336 ( .A1(n2545), .A2(n2498), .B1(n2541), .Y(
        n2500) );
  sky130_fd_sc_hd__a22oi_1 U2337 ( .A1(n2537), .A2(n2500), .B1(n510), .B2(
        n2499), .Y(n2501) );
  sky130_fd_sc_hd__nand2_1 U2338 ( .A(N32), .B(N31), .Y(n2520) );
  sky130_fd_sc_hd__inv_1 U2339 ( .A(cycle[0]), .Y(n2523) );
  sky130_fd_sc_hd__nand2_1 U2340 ( .A(n2503), .B(n2766), .Y(n2502) );
  sky130_fd_sc_hd__mux2i_1 U2341 ( .A0(n2502), .A1(n2503), .S(p[0]), .Y(n818)
         );
  sky130_fd_sc_hd__nand3_1 U2342 ( .A(p[0]), .B(n2766), .C(n2503), .Y(n2505)
         );
  sky130_fd_sc_hd__mux2i_1 U2343 ( .A0(n2505), .A1(n2504), .S(p[1]), .Y(n817)
         );
  sky130_fd_sc_hd__nand2_1 U2344 ( .A(n2506), .B(p[1]), .Y(n2510) );
  sky130_fd_sc_hd__inv_1 U2345 ( .A(p[1]), .Y(n2508) );
  sky130_fd_sc_hd__a21oi_1 U2346 ( .A1(n2766), .A2(n2508), .B1(n2507), .Y(
        n2509) );
  sky130_fd_sc_hd__mux2i_1 U2347 ( .A0(n2510), .A1(n2509), .S(p[2]), .Y(n819)
         );
  sky130_fd_sc_hd__nand2_1 U2348 ( .A(oam_inc[1]), .B(n131), .Y(n2511) );
  sky130_fd_sc_hd__nor2_1 U2349 ( .A(n2511), .B(n2526), .Y(n2512) );
  sky130_fd_sc_hd__mux2i_1 U2350 ( .A0(n2512), .A1(n2535), .S(N35), .Y(n2513)
         );
  sky130_fd_sc_hd__o21ai_1 U2351 ( .A1(n2539), .A2(n2433), .B1(n2513), .Y(n824) );
  sky130_fd_sc_hd__nand3_1 U2352 ( .A(N35), .B(N36), .C(n2533), .Y(n2521) );
  sky130_fd_sc_hd__nor2_1 U2353 ( .A(n2526), .B(n2521), .Y(n2515) );
  sky130_fd_sc_hd__mux2i_1 U2354 ( .A0(n2515), .A1(n2517), .S(N37), .Y(n2516)
         );
  sky130_fd_sc_hd__o21ai_1 U2355 ( .A1(n2539), .A2(n2464), .B1(n2516), .Y(n822) );
  sky130_fd_sc_hd__nand2_1 U2356 ( .A(N37), .B(n2212), .Y(n2650) );
  sky130_fd_sc_hd__o22ai_1 U2357 ( .A1(N37), .A2(n2212), .B1(n2650), .B2(n2521), .Y(n2518) );
  sky130_fd_sc_hd__a22oi_1 U2358 ( .A1(n2537), .A2(n2518), .B1(N38), .B2(n2517), .Y(n2519) );
  sky130_fd_sc_hd__o21ai_1 U2359 ( .A1(n2539), .A2(n2480), .B1(n2519), .Y(n821) );
  sky130_fd_sc_hd__nand2_1 U2360 ( .A(N37), .B(N38), .Y(n2540) );
  sky130_fd_sc_hd__o2111ai_1 U2361 ( .A1(n2540), .A2(n2521), .B1(p[2]), .C1(
        p[1]), .D1(n2558), .Y(n2524) );
  sky130_fd_sc_hd__nand2_1 U2362 ( .A(state[0]), .B(ce), .Y(n2759) );
  sky130_fd_sc_hd__inv_1 U2363 ( .A(p[0]), .Y(n2522) );
  sky130_fd_sc_hd__o41ai_1 U2364 ( .A1(n2524), .A2(n2759), .A3(n2523), .A4(
        n2522), .B1(n2758), .Y(n421) );
  sky130_fd_sc_hd__inv_1 U2365 ( .A(oam_inc[1]), .Y(n2529) );
  sky130_fd_sc_hd__nor2_1 U2366 ( .A(n2529), .B(n2526), .Y(n2527) );
  sky130_fd_sc_hd__o21ai_1 U2367 ( .A1(oam_inc[1]), .A2(n2526), .B1(n2525), 
        .Y(n2530) );
  sky130_fd_sc_hd__mux2i_1 U2368 ( .A0(n2527), .A1(n2530), .S(N33), .Y(n2528)
         );
  sky130_fd_sc_hd__o21ai_1 U2369 ( .A1(n2539), .A2(n2421), .B1(n2528), .Y(n826) );
  sky130_fd_sc_hd__inv_1 U2370 ( .A(n462), .Y(n2556) );
  sky130_fd_sc_hd__nand2_1 U2371 ( .A(N33), .B(n2556), .Y(n2551) );
  sky130_fd_sc_hd__inv_1 U2372 ( .A(N33), .Y(n2557) );
  sky130_fd_sc_hd__nand2_1 U2373 ( .A(n462), .B(n2557), .Y(n2546) );
  sky130_fd_sc_hd__o21ai_1 U2374 ( .A1(n2551), .A2(n2529), .B1(n2546), .Y(
        n2531) );
  sky130_fd_sc_hd__a22oi_1 U2375 ( .A1(n2537), .A2(n2531), .B1(n462), .B2(
        n2530), .Y(n2532) );
  sky130_fd_sc_hd__inv_1 U2376 ( .A(N36), .Y(n2687) );
  sky130_fd_sc_hd__nand2_1 U2377 ( .A(n2533), .B(n2687), .Y(n2534) );
  sky130_fd_sc_hd__mux2i_1 U2378 ( .A0(n2687), .A1(n2534), .S(N35), .Y(n2536)
         );
  sky130_fd_sc_hd__a22oi_1 U2379 ( .A1(n2537), .A2(n2536), .B1(N36), .B2(n2535), .Y(n2538) );
  sky130_fd_sc_hd__o21ai_1 U2380 ( .A1(n2539), .A2(n2448), .B1(n2538), .Y(n823) );
  sky130_fd_sc_hd__inv_1 U2381 ( .A(oam[12]), .Y(n2542) );
  sky130_fd_sc_hd__nor2_1 U2382 ( .A(n415), .B(n2542), .Y(n814) );
  sky130_fd_sc_hd__inv_1 U2383 ( .A(oam[11]), .Y(n2543) );
  sky130_fd_sc_hd__nor2_1 U2384 ( .A(n415), .B(n2543), .Y(n815) );
  sky130_fd_sc_hd__inv_1 U2385 ( .A(oam[10]), .Y(n2544) );
  sky130_fd_sc_hd__nor2_1 U2386 ( .A(n415), .B(n2544), .Y(n816) );
  sky130_fd_sc_hd__inv_1 U2387 ( .A(oam[44]), .Y(n2547) );
  sky130_fd_sc_hd__nor2_1 U2388 ( .A(n404), .B(n2547), .Y(n811) );
  sky130_fd_sc_hd__inv_1 U2389 ( .A(oam[43]), .Y(n2548) );
  sky130_fd_sc_hd__nor2_1 U2390 ( .A(n404), .B(n2548), .Y(n812) );
  sky130_fd_sc_hd__inv_1 U2391 ( .A(oam[42]), .Y(n2549) );
  sky130_fd_sc_hd__nor2_1 U2392 ( .A(n404), .B(n2549), .Y(n813) );
  sky130_fd_sc_hd__inv_1 U2393 ( .A(oam[76]), .Y(n2552) );
  sky130_fd_sc_hd__nor2_1 U2394 ( .A(n299), .B(n2552), .Y(n808) );
  sky130_fd_sc_hd__inv_1 U2395 ( .A(oam[75]), .Y(n2553) );
  sky130_fd_sc_hd__nor2_1 U2396 ( .A(n299), .B(n2553), .Y(n809) );
  sky130_fd_sc_hd__inv_1 U2397 ( .A(oam[74]), .Y(n2554) );
  sky130_fd_sc_hd__nor2_1 U2398 ( .A(n299), .B(n2554), .Y(n810) );
  sky130_fd_sc_hd__nand2_1 U2399 ( .A(n2557), .B(n2556), .Y(n2749) );
  sky130_fd_sc_hd__inv_1 U2400 ( .A(oam[108]), .Y(n2560) );
  sky130_fd_sc_hd__nor2_1 U2401 ( .A(n311), .B(n2560), .Y(n805) );
  sky130_fd_sc_hd__inv_1 U2402 ( .A(oam[107]), .Y(n2561) );
  sky130_fd_sc_hd__nor2_1 U2403 ( .A(n311), .B(n2561), .Y(n806) );
  sky130_fd_sc_hd__inv_1 U2404 ( .A(oam[106]), .Y(n2562) );
  sky130_fd_sc_hd__nor2_1 U2405 ( .A(n311), .B(n2562), .Y(n807) );
  sky130_fd_sc_hd__inv_1 U2406 ( .A(oam[140]), .Y(n2566) );
  sky130_fd_sc_hd__nor2_1 U2407 ( .A(n416), .B(n2566), .Y(n802) );
  sky130_fd_sc_hd__inv_1 U2408 ( .A(oam[139]), .Y(n2567) );
  sky130_fd_sc_hd__nor2_1 U2409 ( .A(n416), .B(n2567), .Y(n803) );
  sky130_fd_sc_hd__inv_1 U2410 ( .A(oam[138]), .Y(n2568) );
  sky130_fd_sc_hd__nor2_1 U2411 ( .A(n416), .B(n2568), .Y(n804) );
  sky130_fd_sc_hd__inv_1 U2412 ( .A(oam[172]), .Y(n2569) );
  sky130_fd_sc_hd__nor2_1 U2413 ( .A(n405), .B(n2569), .Y(n799) );
  sky130_fd_sc_hd__inv_1 U2414 ( .A(oam[171]), .Y(n2570) );
  sky130_fd_sc_hd__nor2_1 U2415 ( .A(n405), .B(n2570), .Y(n800) );
  sky130_fd_sc_hd__inv_1 U2416 ( .A(oam[170]), .Y(n2571) );
  sky130_fd_sc_hd__nor2_1 U2417 ( .A(n405), .B(n2571), .Y(n801) );
  sky130_fd_sc_hd__inv_1 U2418 ( .A(oam[204]), .Y(n2572) );
  sky130_fd_sc_hd__nor2_1 U2419 ( .A(n300), .B(n2572), .Y(n796) );
  sky130_fd_sc_hd__inv_1 U2420 ( .A(oam[203]), .Y(n2573) );
  sky130_fd_sc_hd__nor2_1 U2421 ( .A(n300), .B(n2573), .Y(n797) );
  sky130_fd_sc_hd__inv_1 U2422 ( .A(oam[202]), .Y(n2574) );
  sky130_fd_sc_hd__nor2_1 U2423 ( .A(n300), .B(n2574), .Y(n798) );
  sky130_fd_sc_hd__inv_1 U2424 ( .A(oam[236]), .Y(n2575) );
  sky130_fd_sc_hd__nor2_1 U2425 ( .A(n312), .B(n2575), .Y(n793) );
  sky130_fd_sc_hd__inv_1 U2426 ( .A(oam[235]), .Y(n2576) );
  sky130_fd_sc_hd__nor2_1 U2427 ( .A(n312), .B(n2576), .Y(n794) );
  sky130_fd_sc_hd__inv_1 U2428 ( .A(oam[234]), .Y(n2577) );
  sky130_fd_sc_hd__nor2_1 U2429 ( .A(n312), .B(n2577), .Y(n795) );
  sky130_fd_sc_hd__inv_1 U2430 ( .A(oam[268]), .Y(n2578) );
  sky130_fd_sc_hd__nor2_1 U2431 ( .A(n412), .B(n2578), .Y(n790) );
  sky130_fd_sc_hd__inv_1 U2432 ( .A(oam[267]), .Y(n2579) );
  sky130_fd_sc_hd__nor2_1 U2433 ( .A(n412), .B(n2579), .Y(n791) );
  sky130_fd_sc_hd__inv_1 U2434 ( .A(oam[266]), .Y(n2580) );
  sky130_fd_sc_hd__nor2_1 U2435 ( .A(n412), .B(n2580), .Y(n792) );
  sky130_fd_sc_hd__inv_1 U2436 ( .A(oam[300]), .Y(n2581) );
  sky130_fd_sc_hd__nor2_1 U2437 ( .A(n401), .B(n2581), .Y(n787) );
  sky130_fd_sc_hd__inv_1 U2438 ( .A(oam[299]), .Y(n2582) );
  sky130_fd_sc_hd__nor2_1 U2439 ( .A(n401), .B(n2582), .Y(n788) );
  sky130_fd_sc_hd__inv_1 U2440 ( .A(oam[298]), .Y(n2583) );
  sky130_fd_sc_hd__nor2_1 U2441 ( .A(n401), .B(n2583), .Y(n789) );
  sky130_fd_sc_hd__inv_1 U2442 ( .A(oam[332]), .Y(n2584) );
  sky130_fd_sc_hd__nor2_1 U2443 ( .A(n296), .B(n2584), .Y(n784) );
  sky130_fd_sc_hd__inv_1 U2444 ( .A(oam[331]), .Y(n2585) );
  sky130_fd_sc_hd__nor2_1 U2445 ( .A(n296), .B(n2585), .Y(n785) );
  sky130_fd_sc_hd__inv_1 U2446 ( .A(oam[330]), .Y(n2586) );
  sky130_fd_sc_hd__nor2_1 U2447 ( .A(n296), .B(n2586), .Y(n786) );
  sky130_fd_sc_hd__inv_1 U2448 ( .A(oam[364]), .Y(n2587) );
  sky130_fd_sc_hd__nor2_1 U2449 ( .A(n307), .B(n2587), .Y(n781) );
  sky130_fd_sc_hd__inv_1 U2450 ( .A(oam[363]), .Y(n2588) );
  sky130_fd_sc_hd__nor2_1 U2451 ( .A(n307), .B(n2588), .Y(n782) );
  sky130_fd_sc_hd__inv_1 U2452 ( .A(oam[362]), .Y(n2589) );
  sky130_fd_sc_hd__nor2_1 U2453 ( .A(n307), .B(n2589), .Y(n783) );
  sky130_fd_sc_hd__inv_1 U2454 ( .A(oam[396]), .Y(n2590) );
  sky130_fd_sc_hd__nor2_1 U2455 ( .A(n413), .B(n2590), .Y(n778) );
  sky130_fd_sc_hd__inv_1 U2456 ( .A(oam[395]), .Y(n2591) );
  sky130_fd_sc_hd__nor2_1 U2457 ( .A(n413), .B(n2591), .Y(n779) );
  sky130_fd_sc_hd__inv_1 U2458 ( .A(oam[394]), .Y(n2592) );
  sky130_fd_sc_hd__nor2_1 U2459 ( .A(n413), .B(n2592), .Y(n780) );
  sky130_fd_sc_hd__inv_1 U2460 ( .A(oam[428]), .Y(n2593) );
  sky130_fd_sc_hd__nor2_1 U2461 ( .A(n402), .B(n2593), .Y(n775) );
  sky130_fd_sc_hd__inv_1 U2462 ( .A(oam[427]), .Y(n2594) );
  sky130_fd_sc_hd__nor2_1 U2463 ( .A(n402), .B(n2594), .Y(n776) );
  sky130_fd_sc_hd__inv_1 U2464 ( .A(oam[426]), .Y(n2595) );
  sky130_fd_sc_hd__nor2_1 U2465 ( .A(n402), .B(n2595), .Y(n777) );
  sky130_fd_sc_hd__inv_1 U2466 ( .A(oam[460]), .Y(n2596) );
  sky130_fd_sc_hd__nor2_1 U2467 ( .A(n297), .B(n2596), .Y(n772) );
  sky130_fd_sc_hd__inv_1 U2468 ( .A(oam[459]), .Y(n2597) );
  sky130_fd_sc_hd__nor2_1 U2469 ( .A(n297), .B(n2597), .Y(n773) );
  sky130_fd_sc_hd__inv_1 U2470 ( .A(oam[458]), .Y(n2598) );
  sky130_fd_sc_hd__nor2_1 U2471 ( .A(n297), .B(n2598), .Y(n774) );
  sky130_fd_sc_hd__inv_1 U2472 ( .A(oam[492]), .Y(n2599) );
  sky130_fd_sc_hd__nor2_1 U2473 ( .A(n308), .B(n2599), .Y(n769) );
  sky130_fd_sc_hd__inv_1 U2474 ( .A(oam[491]), .Y(n2600) );
  sky130_fd_sc_hd__nor2_1 U2475 ( .A(n308), .B(n2600), .Y(n770) );
  sky130_fd_sc_hd__inv_1 U2476 ( .A(oam[490]), .Y(n2601) );
  sky130_fd_sc_hd__nor2_1 U2477 ( .A(n308), .B(n2601), .Y(n771) );
  sky130_fd_sc_hd__inv_1 U2478 ( .A(oam[524]), .Y(n2602) );
  sky130_fd_sc_hd__nor2_1 U2479 ( .A(n417), .B(n2602), .Y(n766) );
  sky130_fd_sc_hd__inv_1 U2480 ( .A(oam[523]), .Y(n2603) );
  sky130_fd_sc_hd__nor2_1 U2481 ( .A(n417), .B(n2603), .Y(n767) );
  sky130_fd_sc_hd__inv_1 U2482 ( .A(oam[522]), .Y(n2604) );
  sky130_fd_sc_hd__nor2_1 U2483 ( .A(n417), .B(n2604), .Y(n768) );
  sky130_fd_sc_hd__inv_1 U2484 ( .A(oam[556]), .Y(n2605) );
  sky130_fd_sc_hd__nor2_1 U2485 ( .A(n406), .B(n2605), .Y(n763) );
  sky130_fd_sc_hd__inv_1 U2486 ( .A(oam[555]), .Y(n2606) );
  sky130_fd_sc_hd__nor2_1 U2487 ( .A(n406), .B(n2606), .Y(n764) );
  sky130_fd_sc_hd__inv_1 U2488 ( .A(oam[554]), .Y(n2607) );
  sky130_fd_sc_hd__nor2_1 U2489 ( .A(n406), .B(n2607), .Y(n765) );
  sky130_fd_sc_hd__inv_1 U2490 ( .A(oam[588]), .Y(n2608) );
  sky130_fd_sc_hd__nor2_1 U2491 ( .A(n301), .B(n2608), .Y(n760) );
  sky130_fd_sc_hd__inv_1 U2492 ( .A(oam[587]), .Y(n2609) );
  sky130_fd_sc_hd__nor2_1 U2493 ( .A(n301), .B(n2609), .Y(n761) );
  sky130_fd_sc_hd__inv_1 U2494 ( .A(oam[586]), .Y(n2610) );
  sky130_fd_sc_hd__nor2_1 U2495 ( .A(n301), .B(n2610), .Y(n762) );
  sky130_fd_sc_hd__inv_1 U2496 ( .A(oam[620]), .Y(n2611) );
  sky130_fd_sc_hd__nor2_1 U2497 ( .A(n313), .B(n2611), .Y(n757) );
  sky130_fd_sc_hd__inv_1 U2498 ( .A(oam[619]), .Y(n2612) );
  sky130_fd_sc_hd__nor2_1 U2499 ( .A(n313), .B(n2612), .Y(n758) );
  sky130_fd_sc_hd__inv_1 U2500 ( .A(oam[618]), .Y(n2613) );
  sky130_fd_sc_hd__nor2_1 U2501 ( .A(n313), .B(n2613), .Y(n759) );
  sky130_fd_sc_hd__inv_1 U2502 ( .A(oam[652]), .Y(n2614) );
  sky130_fd_sc_hd__nor2_1 U2503 ( .A(n418), .B(n2614), .Y(n754) );
  sky130_fd_sc_hd__inv_1 U2504 ( .A(oam[651]), .Y(n2615) );
  sky130_fd_sc_hd__nor2_1 U2505 ( .A(n418), .B(n2615), .Y(n755) );
  sky130_fd_sc_hd__inv_1 U2506 ( .A(oam[650]), .Y(n2616) );
  sky130_fd_sc_hd__nor2_1 U2507 ( .A(n418), .B(n2616), .Y(n756) );
  sky130_fd_sc_hd__inv_1 U2508 ( .A(oam[684]), .Y(n2617) );
  sky130_fd_sc_hd__nor2_1 U2509 ( .A(n407), .B(n2617), .Y(n751) );
  sky130_fd_sc_hd__inv_1 U2510 ( .A(oam[683]), .Y(n2618) );
  sky130_fd_sc_hd__nor2_1 U2511 ( .A(n407), .B(n2618), .Y(n752) );
  sky130_fd_sc_hd__inv_1 U2512 ( .A(oam[682]), .Y(n2619) );
  sky130_fd_sc_hd__nor2_1 U2513 ( .A(n407), .B(n2619), .Y(n753) );
  sky130_fd_sc_hd__inv_1 U2514 ( .A(oam[716]), .Y(n2620) );
  sky130_fd_sc_hd__nor2_1 U2515 ( .A(n302), .B(n2620), .Y(n748) );
  sky130_fd_sc_hd__inv_1 U2516 ( .A(oam[715]), .Y(n2621) );
  sky130_fd_sc_hd__nor2_1 U2517 ( .A(n302), .B(n2621), .Y(n749) );
  sky130_fd_sc_hd__inv_1 U2518 ( .A(oam[714]), .Y(n2622) );
  sky130_fd_sc_hd__nor2_1 U2519 ( .A(n302), .B(n2622), .Y(n750) );
  sky130_fd_sc_hd__inv_1 U2520 ( .A(oam[748]), .Y(n2623) );
  sky130_fd_sc_hd__nor2_1 U2521 ( .A(n309), .B(n2623), .Y(n745) );
  sky130_fd_sc_hd__inv_1 U2522 ( .A(oam[747]), .Y(n2624) );
  sky130_fd_sc_hd__nor2_1 U2523 ( .A(n309), .B(n2624), .Y(n746) );
  sky130_fd_sc_hd__inv_1 U2524 ( .A(oam[746]), .Y(n2625) );
  sky130_fd_sc_hd__nor2_1 U2525 ( .A(n309), .B(n2625), .Y(n747) );
  sky130_fd_sc_hd__inv_1 U2526 ( .A(oam[780]), .Y(n2626) );
  sky130_fd_sc_hd__nor2_1 U2527 ( .A(n195), .B(n2626), .Y(n742) );
  sky130_fd_sc_hd__inv_1 U2528 ( .A(oam[779]), .Y(n2627) );
  sky130_fd_sc_hd__nor2_1 U2529 ( .A(n195), .B(n2627), .Y(n743) );
  sky130_fd_sc_hd__inv_1 U2530 ( .A(oam[778]), .Y(n2628) );
  sky130_fd_sc_hd__nor2_1 U2531 ( .A(n195), .B(n2628), .Y(n744) );
  sky130_fd_sc_hd__inv_1 U2532 ( .A(oam[812]), .Y(n2629) );
  sky130_fd_sc_hd__nor2_1 U2533 ( .A(n196), .B(n2629), .Y(n739) );
  sky130_fd_sc_hd__inv_1 U2534 ( .A(oam[811]), .Y(n2630) );
  sky130_fd_sc_hd__nor2_1 U2535 ( .A(n196), .B(n2630), .Y(n740) );
  sky130_fd_sc_hd__inv_1 U2536 ( .A(oam[810]), .Y(n2631) );
  sky130_fd_sc_hd__nor2_1 U2537 ( .A(n196), .B(n2631), .Y(n741) );
  sky130_fd_sc_hd__inv_1 U2538 ( .A(oam[844]), .Y(n2632) );
  sky130_fd_sc_hd__nor2_1 U2539 ( .A(n197), .B(n2632), .Y(n736) );
  sky130_fd_sc_hd__inv_1 U2540 ( .A(oam[843]), .Y(n2633) );
  sky130_fd_sc_hd__nor2_1 U2541 ( .A(n197), .B(n2633), .Y(n737) );
  sky130_fd_sc_hd__inv_1 U2542 ( .A(oam[842]), .Y(n2634) );
  sky130_fd_sc_hd__nor2_1 U2543 ( .A(n197), .B(n2634), .Y(n738) );
  sky130_fd_sc_hd__inv_1 U2544 ( .A(oam[876]), .Y(n2635) );
  sky130_fd_sc_hd__nor2_1 U2545 ( .A(n194), .B(n2635), .Y(n733) );
  sky130_fd_sc_hd__inv_1 U2546 ( .A(oam[875]), .Y(n2636) );
  sky130_fd_sc_hd__nor2_1 U2547 ( .A(n194), .B(n2636), .Y(n734) );
  sky130_fd_sc_hd__inv_1 U2548 ( .A(oam[874]), .Y(n2637) );
  sky130_fd_sc_hd__nor2_1 U2549 ( .A(n194), .B(n2637), .Y(n735) );
  sky130_fd_sc_hd__inv_1 U2550 ( .A(oam[908]), .Y(n2638) );
  sky130_fd_sc_hd__nor2_1 U2551 ( .A(n163), .B(n2638), .Y(n730) );
  sky130_fd_sc_hd__inv_1 U2552 ( .A(oam[907]), .Y(n2639) );
  sky130_fd_sc_hd__nor2_1 U2553 ( .A(n163), .B(n2639), .Y(n731) );
  sky130_fd_sc_hd__inv_1 U2554 ( .A(oam[906]), .Y(n2640) );
  sky130_fd_sc_hd__nor2_1 U2555 ( .A(n163), .B(n2640), .Y(n732) );
  sky130_fd_sc_hd__inv_1 U2556 ( .A(oam[940]), .Y(n2641) );
  sky130_fd_sc_hd__nor2_1 U2557 ( .A(n164), .B(n2641), .Y(n727) );
  sky130_fd_sc_hd__inv_1 U2558 ( .A(oam[939]), .Y(n2642) );
  sky130_fd_sc_hd__nor2_1 U2559 ( .A(n164), .B(n2642), .Y(n728) );
  sky130_fd_sc_hd__inv_1 U2560 ( .A(oam[938]), .Y(n2643) );
  sky130_fd_sc_hd__nor2_1 U2561 ( .A(n164), .B(n2643), .Y(n729) );
  sky130_fd_sc_hd__inv_1 U2562 ( .A(oam[972]), .Y(n2644) );
  sky130_fd_sc_hd__nor2_1 U2563 ( .A(n165), .B(n2644), .Y(n724) );
  sky130_fd_sc_hd__inv_1 U2564 ( .A(oam[971]), .Y(n2645) );
  sky130_fd_sc_hd__nor2_1 U2565 ( .A(n165), .B(n2645), .Y(n725) );
  sky130_fd_sc_hd__inv_1 U2566 ( .A(oam[970]), .Y(n2646) );
  sky130_fd_sc_hd__nor2_1 U2567 ( .A(n165), .B(n2646), .Y(n726) );
  sky130_fd_sc_hd__inv_1 U2568 ( .A(oam[1004]), .Y(n2647) );
  sky130_fd_sc_hd__nor2_1 U2569 ( .A(n162), .B(n2647), .Y(n721) );
  sky130_fd_sc_hd__inv_1 U2570 ( .A(oam[1003]), .Y(n2648) );
  sky130_fd_sc_hd__nor2_1 U2571 ( .A(n162), .B(n2648), .Y(n722) );
  sky130_fd_sc_hd__inv_1 U2572 ( .A(oam[1002]), .Y(n2649) );
  sky130_fd_sc_hd__nor2_1 U2573 ( .A(n162), .B(n2649), .Y(n723) );
  sky130_fd_sc_hd__inv_1 U2574 ( .A(oam[1036]), .Y(n2651) );
  sky130_fd_sc_hd__nor2_1 U2575 ( .A(n191), .B(n2651), .Y(n718) );
  sky130_fd_sc_hd__inv_1 U2576 ( .A(oam[1035]), .Y(n2652) );
  sky130_fd_sc_hd__nor2_1 U2577 ( .A(n191), .B(n2652), .Y(n719) );
  sky130_fd_sc_hd__inv_1 U2578 ( .A(oam[1034]), .Y(n2653) );
  sky130_fd_sc_hd__nor2_1 U2579 ( .A(n191), .B(n2653), .Y(n720) );
  sky130_fd_sc_hd__inv_1 U2580 ( .A(oam[1068]), .Y(n2654) );
  sky130_fd_sc_hd__nor2_1 U2581 ( .A(n192), .B(n2654), .Y(n715) );
  sky130_fd_sc_hd__inv_1 U2582 ( .A(oam[1067]), .Y(n2655) );
  sky130_fd_sc_hd__nor2_1 U2583 ( .A(n192), .B(n2655), .Y(n716) );
  sky130_fd_sc_hd__inv_1 U2584 ( .A(oam[1066]), .Y(n2656) );
  sky130_fd_sc_hd__nor2_1 U2585 ( .A(n192), .B(n2656), .Y(n717) );
  sky130_fd_sc_hd__inv_1 U2586 ( .A(oam[1100]), .Y(n2657) );
  sky130_fd_sc_hd__nor2_1 U2587 ( .A(n193), .B(n2657), .Y(n712) );
  sky130_fd_sc_hd__inv_1 U2588 ( .A(oam[1099]), .Y(n2658) );
  sky130_fd_sc_hd__nor2_1 U2589 ( .A(n193), .B(n2658), .Y(n713) );
  sky130_fd_sc_hd__inv_1 U2590 ( .A(oam[1098]), .Y(n2659) );
  sky130_fd_sc_hd__nor2_1 U2591 ( .A(n193), .B(n2659), .Y(n714) );
  sky130_fd_sc_hd__inv_1 U2592 ( .A(oam[1132]), .Y(n2660) );
  sky130_fd_sc_hd__nor2_1 U2593 ( .A(n190), .B(n2660), .Y(n709) );
  sky130_fd_sc_hd__inv_1 U2594 ( .A(oam[1131]), .Y(n2661) );
  sky130_fd_sc_hd__nor2_1 U2595 ( .A(n190), .B(n2661), .Y(n710) );
  sky130_fd_sc_hd__inv_1 U2596 ( .A(oam[1130]), .Y(n2662) );
  sky130_fd_sc_hd__nor2_1 U2597 ( .A(n190), .B(n2662), .Y(n711) );
  sky130_fd_sc_hd__inv_1 U2598 ( .A(oam[1164]), .Y(n2663) );
  sky130_fd_sc_hd__nor2_1 U2599 ( .A(n414), .B(n2663), .Y(n706) );
  sky130_fd_sc_hd__inv_1 U2600 ( .A(oam[1163]), .Y(n2664) );
  sky130_fd_sc_hd__nor2_1 U2601 ( .A(n414), .B(n2664), .Y(n707) );
  sky130_fd_sc_hd__inv_1 U2602 ( .A(oam[1162]), .Y(n2665) );
  sky130_fd_sc_hd__nor2_1 U2603 ( .A(n414), .B(n2665), .Y(n708) );
  sky130_fd_sc_hd__inv_1 U2604 ( .A(oam[1196]), .Y(n2666) );
  sky130_fd_sc_hd__nor2_1 U2605 ( .A(n403), .B(n2666), .Y(n703) );
  sky130_fd_sc_hd__inv_1 U2606 ( .A(oam[1195]), .Y(n2667) );
  sky130_fd_sc_hd__nor2_1 U2607 ( .A(n403), .B(n2667), .Y(n704) );
  sky130_fd_sc_hd__inv_1 U2608 ( .A(oam[1194]), .Y(n2668) );
  sky130_fd_sc_hd__nor2_1 U2609 ( .A(n403), .B(n2668), .Y(n705) );
  sky130_fd_sc_hd__inv_1 U2610 ( .A(oam[1228]), .Y(n2669) );
  sky130_fd_sc_hd__nor2_1 U2611 ( .A(n298), .B(n2669), .Y(n700) );
  sky130_fd_sc_hd__inv_1 U2612 ( .A(oam[1227]), .Y(n2670) );
  sky130_fd_sc_hd__nor2_1 U2613 ( .A(n298), .B(n2670), .Y(n701) );
  sky130_fd_sc_hd__inv_1 U2614 ( .A(oam[1226]), .Y(n2671) );
  sky130_fd_sc_hd__nor2_1 U2615 ( .A(n298), .B(n2671), .Y(n702) );
  sky130_fd_sc_hd__inv_1 U2616 ( .A(oam[1260]), .Y(n2672) );
  sky130_fd_sc_hd__nor2_1 U2617 ( .A(n310), .B(n2672), .Y(n697) );
  sky130_fd_sc_hd__inv_1 U2618 ( .A(oam[1259]), .Y(n2673) );
  sky130_fd_sc_hd__nor2_1 U2619 ( .A(n310), .B(n2673), .Y(n698) );
  sky130_fd_sc_hd__inv_1 U2620 ( .A(oam[1258]), .Y(n2674) );
  sky130_fd_sc_hd__nor2_1 U2621 ( .A(n310), .B(n2674), .Y(n699) );
  sky130_fd_sc_hd__inv_1 U2622 ( .A(oam[1292]), .Y(n2675) );
  sky130_fd_sc_hd__nor2_1 U2623 ( .A(n408), .B(n2675), .Y(n694) );
  sky130_fd_sc_hd__inv_1 U2624 ( .A(oam[1291]), .Y(n2676) );
  sky130_fd_sc_hd__nor2_1 U2625 ( .A(n408), .B(n2676), .Y(n695) );
  sky130_fd_sc_hd__inv_1 U2626 ( .A(oam[1290]), .Y(n2677) );
  sky130_fd_sc_hd__nor2_1 U2627 ( .A(n408), .B(n2677), .Y(n696) );
  sky130_fd_sc_hd__inv_1 U2628 ( .A(oam[1324]), .Y(n2678) );
  sky130_fd_sc_hd__nor2_1 U2629 ( .A(n397), .B(n2678), .Y(n691) );
  sky130_fd_sc_hd__inv_1 U2630 ( .A(oam[1323]), .Y(n2679) );
  sky130_fd_sc_hd__nor2_1 U2631 ( .A(n397), .B(n2679), .Y(n692) );
  sky130_fd_sc_hd__inv_1 U2632 ( .A(oam[1322]), .Y(n2680) );
  sky130_fd_sc_hd__nor2_1 U2633 ( .A(n397), .B(n2680), .Y(n693) );
  sky130_fd_sc_hd__inv_1 U2634 ( .A(oam[1356]), .Y(n2681) );
  sky130_fd_sc_hd__nor2_1 U2635 ( .A(n292), .B(n2681), .Y(n688) );
  sky130_fd_sc_hd__inv_1 U2636 ( .A(oam[1355]), .Y(n2682) );
  sky130_fd_sc_hd__nor2_1 U2637 ( .A(n292), .B(n2682), .Y(n689) );
  sky130_fd_sc_hd__inv_1 U2638 ( .A(oam[1354]), .Y(n2683) );
  sky130_fd_sc_hd__nor2_1 U2639 ( .A(n292), .B(n2683), .Y(n690) );
  sky130_fd_sc_hd__inv_1 U2640 ( .A(oam[1388]), .Y(n2684) );
  sky130_fd_sc_hd__nor2_1 U2641 ( .A(n303), .B(n2684), .Y(n685) );
  sky130_fd_sc_hd__inv_1 U2642 ( .A(oam[1387]), .Y(n2685) );
  sky130_fd_sc_hd__nor2_1 U2643 ( .A(n303), .B(n2685), .Y(n686) );
  sky130_fd_sc_hd__inv_1 U2644 ( .A(oam[1386]), .Y(n2686) );
  sky130_fd_sc_hd__nor2_1 U2645 ( .A(n303), .B(n2686), .Y(n687) );
  sky130_fd_sc_hd__inv_1 U2646 ( .A(oam[1420]), .Y(n2688) );
  sky130_fd_sc_hd__nor2_1 U2647 ( .A(n409), .B(n2688), .Y(n682) );
  sky130_fd_sc_hd__inv_1 U2648 ( .A(oam[1419]), .Y(n2689) );
  sky130_fd_sc_hd__nor2_1 U2649 ( .A(n409), .B(n2689), .Y(n683) );
  sky130_fd_sc_hd__inv_1 U2650 ( .A(oam[1418]), .Y(n2690) );
  sky130_fd_sc_hd__nor2_1 U2651 ( .A(n409), .B(n2690), .Y(n684) );
  sky130_fd_sc_hd__inv_1 U2652 ( .A(oam[1452]), .Y(n2691) );
  sky130_fd_sc_hd__nor2_1 U2653 ( .A(n398), .B(n2691), .Y(n679) );
  sky130_fd_sc_hd__inv_1 U2654 ( .A(oam[1451]), .Y(n2692) );
  sky130_fd_sc_hd__nor2_1 U2655 ( .A(n398), .B(n2692), .Y(n680) );
  sky130_fd_sc_hd__inv_1 U2656 ( .A(oam[1450]), .Y(n2693) );
  sky130_fd_sc_hd__nor2_1 U2657 ( .A(n398), .B(n2693), .Y(n681) );
  sky130_fd_sc_hd__inv_1 U2658 ( .A(oam[1484]), .Y(n2694) );
  sky130_fd_sc_hd__nor2_1 U2659 ( .A(n293), .B(n2694), .Y(n676) );
  sky130_fd_sc_hd__inv_1 U2660 ( .A(oam[1483]), .Y(n2695) );
  sky130_fd_sc_hd__nor2_1 U2661 ( .A(n293), .B(n2695), .Y(n677) );
  sky130_fd_sc_hd__inv_1 U2662 ( .A(oam[1482]), .Y(n2696) );
  sky130_fd_sc_hd__nor2_1 U2663 ( .A(n293), .B(n2696), .Y(n678) );
  sky130_fd_sc_hd__inv_1 U2664 ( .A(oam[1516]), .Y(n2697) );
  sky130_fd_sc_hd__nor2_1 U2665 ( .A(n304), .B(n2697), .Y(n673) );
  sky130_fd_sc_hd__inv_1 U2666 ( .A(oam[1515]), .Y(n2698) );
  sky130_fd_sc_hd__nor2_1 U2667 ( .A(n304), .B(n2698), .Y(n674) );
  sky130_fd_sc_hd__inv_1 U2668 ( .A(oam[1514]), .Y(n2699) );
  sky130_fd_sc_hd__nor2_1 U2669 ( .A(n304), .B(n2699), .Y(n675) );
  sky130_fd_sc_hd__inv_1 U2670 ( .A(oam[1548]), .Y(n2700) );
  sky130_fd_sc_hd__nor2_1 U2671 ( .A(n410), .B(n2700), .Y(n670) );
  sky130_fd_sc_hd__inv_1 U2672 ( .A(oam[1547]), .Y(n2701) );
  sky130_fd_sc_hd__nor2_1 U2673 ( .A(n410), .B(n2701), .Y(n671) );
  sky130_fd_sc_hd__inv_1 U2674 ( .A(oam[1546]), .Y(n2702) );
  sky130_fd_sc_hd__nor2_1 U2675 ( .A(n410), .B(n2702), .Y(n672) );
  sky130_fd_sc_hd__inv_1 U2676 ( .A(oam[1580]), .Y(n2703) );
  sky130_fd_sc_hd__nor2_1 U2677 ( .A(n399), .B(n2703), .Y(n667) );
  sky130_fd_sc_hd__inv_1 U2678 ( .A(oam[1579]), .Y(n2704) );
  sky130_fd_sc_hd__nor2_1 U2679 ( .A(n399), .B(n2704), .Y(n668) );
  sky130_fd_sc_hd__inv_1 U2680 ( .A(oam[1578]), .Y(n2705) );
  sky130_fd_sc_hd__nor2_1 U2681 ( .A(n399), .B(n2705), .Y(n669) );
  sky130_fd_sc_hd__inv_1 U2682 ( .A(oam[1612]), .Y(n2706) );
  sky130_fd_sc_hd__nor2_1 U2683 ( .A(n294), .B(n2706), .Y(n664) );
  sky130_fd_sc_hd__inv_1 U2684 ( .A(oam[1611]), .Y(n2707) );
  sky130_fd_sc_hd__nor2_1 U2685 ( .A(n294), .B(n2707), .Y(n665) );
  sky130_fd_sc_hd__inv_1 U2686 ( .A(oam[1610]), .Y(n2708) );
  sky130_fd_sc_hd__nor2_1 U2687 ( .A(n294), .B(n2708), .Y(n666) );
  sky130_fd_sc_hd__inv_1 U2688 ( .A(oam[1644]), .Y(n2709) );
  sky130_fd_sc_hd__nor2_1 U2689 ( .A(n305), .B(n2709), .Y(n661) );
  sky130_fd_sc_hd__inv_1 U2690 ( .A(oam[1643]), .Y(n2710) );
  sky130_fd_sc_hd__nor2_1 U2691 ( .A(n305), .B(n2710), .Y(n662) );
  sky130_fd_sc_hd__inv_1 U2692 ( .A(oam[1642]), .Y(n2711) );
  sky130_fd_sc_hd__nor2_1 U2693 ( .A(n305), .B(n2711), .Y(n663) );
  sky130_fd_sc_hd__inv_1 U2694 ( .A(oam[1676]), .Y(n2712) );
  sky130_fd_sc_hd__nor2_1 U2695 ( .A(n411), .B(n2712), .Y(n658) );
  sky130_fd_sc_hd__inv_1 U2696 ( .A(oam[1675]), .Y(n2713) );
  sky130_fd_sc_hd__nor2_1 U2697 ( .A(n411), .B(n2713), .Y(n659) );
  sky130_fd_sc_hd__inv_1 U2698 ( .A(oam[1674]), .Y(n2714) );
  sky130_fd_sc_hd__nor2_1 U2699 ( .A(n411), .B(n2714), .Y(n660) );
  sky130_fd_sc_hd__inv_1 U2700 ( .A(oam[1708]), .Y(n2715) );
  sky130_fd_sc_hd__nor2_1 U2701 ( .A(n400), .B(n2715), .Y(n655) );
  sky130_fd_sc_hd__inv_1 U2702 ( .A(oam[1707]), .Y(n2716) );
  sky130_fd_sc_hd__nor2_1 U2703 ( .A(n400), .B(n2716), .Y(n656) );
  sky130_fd_sc_hd__inv_1 U2704 ( .A(oam[1706]), .Y(n2717) );
  sky130_fd_sc_hd__nor2_1 U2705 ( .A(n400), .B(n2717), .Y(n657) );
  sky130_fd_sc_hd__inv_1 U2706 ( .A(oam[1740]), .Y(n2718) );
  sky130_fd_sc_hd__nor2_1 U2707 ( .A(n295), .B(n2718), .Y(n652) );
  sky130_fd_sc_hd__inv_1 U2708 ( .A(oam[1739]), .Y(n2719) );
  sky130_fd_sc_hd__nor2_1 U2709 ( .A(n295), .B(n2719), .Y(n653) );
  sky130_fd_sc_hd__inv_1 U2710 ( .A(oam[1738]), .Y(n2720) );
  sky130_fd_sc_hd__nor2_1 U2711 ( .A(n295), .B(n2720), .Y(n654) );
  sky130_fd_sc_hd__inv_1 U2712 ( .A(oam[1772]), .Y(n2721) );
  sky130_fd_sc_hd__nor2_1 U2713 ( .A(n306), .B(n2721), .Y(n649) );
  sky130_fd_sc_hd__inv_1 U2714 ( .A(oam[1771]), .Y(n2722) );
  sky130_fd_sc_hd__nor2_1 U2715 ( .A(n306), .B(n2722), .Y(n650) );
  sky130_fd_sc_hd__inv_1 U2716 ( .A(oam[1770]), .Y(n2723) );
  sky130_fd_sc_hd__nor2_1 U2717 ( .A(n306), .B(n2723), .Y(n651) );
  sky130_fd_sc_hd__nand2_1 U2718 ( .A(n104), .B(n2212), .Y(n2748) );
  sky130_fd_sc_hd__inv_1 U2719 ( .A(oam[1804]), .Y(n2724) );
  sky130_fd_sc_hd__nor2_1 U2720 ( .A(n328), .B(n2724), .Y(n646) );
  sky130_fd_sc_hd__inv_1 U2721 ( .A(oam[1803]), .Y(n2725) );
  sky130_fd_sc_hd__nor2_1 U2722 ( .A(n328), .B(n2725), .Y(n647) );
  sky130_fd_sc_hd__inv_1 U2723 ( .A(oam[1802]), .Y(n2726) );
  sky130_fd_sc_hd__nor2_1 U2724 ( .A(n328), .B(n2726), .Y(n648) );
  sky130_fd_sc_hd__inv_1 U2725 ( .A(oam[1836]), .Y(n2727) );
  sky130_fd_sc_hd__nor2_1 U2726 ( .A(n330), .B(n2727), .Y(n643) );
  sky130_fd_sc_hd__inv_1 U2727 ( .A(oam[1835]), .Y(n2728) );
  sky130_fd_sc_hd__nor2_1 U2728 ( .A(n330), .B(n2728), .Y(n644) );
  sky130_fd_sc_hd__inv_1 U2729 ( .A(oam[1834]), .Y(n2729) );
  sky130_fd_sc_hd__nor2_1 U2730 ( .A(n330), .B(n2729), .Y(n645) );
  sky130_fd_sc_hd__inv_1 U2731 ( .A(oam[1868]), .Y(n2730) );
  sky130_fd_sc_hd__nor2_1 U2732 ( .A(n199), .B(n2730), .Y(n640) );
  sky130_fd_sc_hd__inv_1 U2733 ( .A(oam[1867]), .Y(n2731) );
  sky130_fd_sc_hd__nor2_1 U2734 ( .A(n199), .B(n2731), .Y(n641) );
  sky130_fd_sc_hd__inv_1 U2735 ( .A(oam[1866]), .Y(n2732) );
  sky130_fd_sc_hd__nor2_1 U2736 ( .A(n199), .B(n2732), .Y(n642) );
  sky130_fd_sc_hd__inv_1 U2737 ( .A(oam[1900]), .Y(n2733) );
  sky130_fd_sc_hd__nor2_1 U2738 ( .A(n198), .B(n2733), .Y(n637) );
  sky130_fd_sc_hd__inv_1 U2739 ( .A(oam[1899]), .Y(n2734) );
  sky130_fd_sc_hd__nor2_1 U2740 ( .A(n198), .B(n2734), .Y(n638) );
  sky130_fd_sc_hd__inv_1 U2741 ( .A(oam[1898]), .Y(n2735) );
  sky130_fd_sc_hd__nor2_1 U2742 ( .A(n198), .B(n2735), .Y(n639) );
  sky130_fd_sc_hd__inv_1 U2743 ( .A(oam[1932]), .Y(n2737) );
  sky130_fd_sc_hd__nor2_1 U2744 ( .A(n329), .B(n2737), .Y(n634) );
  sky130_fd_sc_hd__inv_1 U2745 ( .A(oam[1931]), .Y(n2738) );
  sky130_fd_sc_hd__nor2_1 U2746 ( .A(n329), .B(n2738), .Y(n635) );
  sky130_fd_sc_hd__inv_1 U2747 ( .A(oam[1930]), .Y(n2739) );
  sky130_fd_sc_hd__nor2_1 U2748 ( .A(n329), .B(n2739), .Y(n636) );
  sky130_fd_sc_hd__inv_1 U2749 ( .A(oam[1964]), .Y(n2740) );
  sky130_fd_sc_hd__nor2_1 U2750 ( .A(n188), .B(n2740), .Y(n631) );
  sky130_fd_sc_hd__nor2_1 U2751 ( .A(n188), .B(n426), .Y(n632) );
  sky130_fd_sc_hd__inv_1 U2752 ( .A(oam[1962]), .Y(n2741) );
  sky130_fd_sc_hd__nor2_1 U2753 ( .A(n188), .B(n2741), .Y(n633) );
  sky130_fd_sc_hd__inv_1 U2754 ( .A(oam[1996]), .Y(n2742) );
  sky130_fd_sc_hd__nor2_1 U2755 ( .A(n189), .B(n2742), .Y(n628) );
  sky130_fd_sc_hd__inv_1 U2756 ( .A(oam[1995]), .Y(n2743) );
  sky130_fd_sc_hd__nor2_1 U2757 ( .A(n189), .B(n2743), .Y(n629) );
  sky130_fd_sc_hd__inv_1 U2758 ( .A(oam[1994]), .Y(n2744) );
  sky130_fd_sc_hd__nor2_1 U2759 ( .A(n189), .B(n2744), .Y(n630) );
  sky130_fd_sc_hd__inv_1 U2760 ( .A(oam[2028]), .Y(n2745) );
  sky130_fd_sc_hd__nor2_1 U2761 ( .A(n187), .B(n2745), .Y(n625) );
  sky130_fd_sc_hd__inv_1 U2762 ( .A(oam[2027]), .Y(n2746) );
  sky130_fd_sc_hd__nor2_1 U2763 ( .A(n187), .B(n2746), .Y(n626) );
  sky130_fd_sc_hd__inv_1 U2764 ( .A(oam[2026]), .Y(n2747) );
  sky130_fd_sc_hd__nor2_1 U2765 ( .A(n187), .B(n2747), .Y(n627) );
  sky130_fd_sc_hd__inv_1 U2766 ( .A(spr_y_coord[6]), .Y(n2756) );
  sky130_fd_sc_hd__inv_1 U2767 ( .A(spr_y_coord[5]), .Y(n2755) );
  sky130_fd_sc_hd__nor4_1 U2768 ( .A(N35), .B(n2750), .C(n2749), .D(n2748), 
        .Y(n2752) );
  sky130_fd_sc_hd__nand4_1 U2769 ( .A(n2753), .B(n2756), .C(n2755), .D(n2754), 
        .Y(n2757) );
  sky130_fd_sc_hd__inv_1 U2770 ( .A(exiting_vblank), .Y(n2761) );
  sky130_fd_sc_hd__nand4_1 U2771 ( .A(sprites_enabled), .B(n2761), .C(state[1]), .D(n2760), .Y(n2763) );
  sky130_fd_sc_hd__o21ai_1 U2772 ( .A1(n2482), .A2(n2761), .B1(spr_overflow), 
        .Y(n2762) );
  sky130_fd_sc_hd__o21ai_1 U2773 ( .A1(n2763), .A2(n2767), .B1(n2762), .Y(n820) );
endmodule


module SpriteAddressGen ( clk, ce, enabled, obj_size, obj_patt, cycle, temp, 
        vram_addr, vram_data, load, load_in );
  input [2:0] cycle;
  input [7:0] temp;
  output [12:0] vram_addr;
  input [7:0] vram_data;
  output [3:0] load;
  output [26:0] load_in;
  input clk, ce, enabled, obj_size, obj_patt;
  wire   flip_x, flip_y, \temp_tile[0] , n1, n17, n20, n22, n23, n24, n25, n2,
         n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16;
  wire   [3:0] temp_y;
  assign vram_addr[3] = cycle[1];
  assign load_in[18] = load_in[26];
  assign load_in[17] = load_in[25];
  assign load_in[16] = load_in[24];
  assign load_in[15] = load_in[23];
  assign load_in[14] = load_in[22];
  assign load_in[13] = load_in[21];
  assign load_in[12] = load_in[20];
  assign load_in[11] = load_in[19];
  assign load_in[10] = temp[7];
  assign load_in[9] = temp[6];
  assign load_in[0] = temp[5];
  assign load_in[8] = temp[5];
  assign load_in[7] = temp[4];
  assign load_in[6] = temp[3];
  assign load_in[5] = temp[2];
  assign load_in[2] = temp[1];
  assign load_in[4] = temp[1];
  assign load_in[1] = temp[0];
  assign load_in[3] = temp[0];

  sky130_fd_sc_hd__edfxtp_1 flip_y_reg ( .D(temp[7]), .DE(n2), .CLK(clk), .Q(
        flip_y) );
  sky130_fd_sc_hd__edfxtp_1 temp_y_reg_3_ ( .D(temp[3]), .DE(n4), .CLK(clk), 
        .Q(temp_y[3]) );
  sky130_fd_sc_hd__edfxtp_1 temp_y_reg_2_ ( .D(temp[2]), .DE(n4), .CLK(clk), 
        .Q(temp_y[2]) );
  sky130_fd_sc_hd__edfxtp_1 temp_y_reg_1_ ( .D(temp[1]), .DE(n4), .CLK(clk), 
        .Q(temp_y[1]) );
  sky130_fd_sc_hd__edfxtp_1 temp_y_reg_0_ ( .D(temp[0]), .DE(n4), .CLK(clk), 
        .Q(temp_y[0]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_7_ ( .D(temp[7]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[11]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_6_ ( .D(temp[6]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[10]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_5_ ( .D(temp[5]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[9]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_4_ ( .D(temp[4]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[8]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_3_ ( .D(temp[3]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[7]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_2_ ( .D(temp[2]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[6]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_1_ ( .D(temp[1]), .DE(n3), .CLK(clk), 
        .Q(vram_addr[5]) );
  sky130_fd_sc_hd__edfxtp_1 temp_tile_reg_0_ ( .D(temp[0]), .DE(n3), .CLK(clk), 
        .Q(\temp_tile[0] ) );
  sky130_fd_sc_hd__edfxtp_1 flip_x_reg ( .D(temp[6]), .DE(n2), .CLK(clk), .Q(
        flip_x) );
  sky130_fd_sc_hd__edfxbp_1 dummy_sprite_reg ( .D(temp[4]), .DE(n2), .CLK(clk), 
        .Q_N(n1) );
  sky130_fd_sc_hd__xnor2_1 U32 ( .A(temp_y[3]), .B(flip_y), .Y(n17) );
  sky130_fd_sc_hd__xor2_1 U33 ( .A(temp_y[2]), .B(flip_y), .X(vram_addr[2]) );
  sky130_fd_sc_hd__xor2_1 U34 ( .A(temp_y[1]), .B(flip_y), .X(vram_addr[1]) );
  sky130_fd_sc_hd__a22o_1 U35 ( .A1(obj_size), .A2(\temp_tile[0] ), .B1(
        obj_patt), .B2(n16), .X(vram_addr[12]) );
  sky130_fd_sc_hd__xor2_1 U36 ( .A(temp_y[0]), .B(flip_y), .X(vram_addr[0]) );
  sky130_fd_sc_hd__and3_1 U39 ( .A(n6), .B(n7), .C(ce), .X(n20) );
  sky130_fd_sc_hd__nand2_1 U41 ( .A(flip_x), .B(n1), .Y(n23) );
  sky130_fd_sc_hd__nand2b_1 U42 ( .A_N(flip_x), .B(n1), .Y(n22) );
  sky130_fd_sc_hd__nor2_4 U2 ( .A(n25), .B(n5), .Y(load[1]) );
  sky130_fd_sc_hd__nand3_1 U3 ( .A(cycle[0]), .B(enabled), .C(cycle[2]), .Y(
        n24) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(vram_data[4]), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(vram_data[3]), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(vram_data[5]), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(vram_data[2]), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(vram_data[6]), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(vram_data[1]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(vram_data[0]), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(vram_data[7]), .Y(n8) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(cycle[1]), .Y(n6) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(cycle[2]), .Y(n7) );
  sky130_fd_sc_hd__nand3_2 U14 ( .A(cycle[1]), .B(n7), .C(enabled), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(obj_size), .Y(n16) );
  sky130_fd_sc_hd__o22ai_1 U16 ( .A1(n8), .A2(n22), .B1(n23), .B2(n15), .Y(
        load_in[19]) );
  sky130_fd_sc_hd__o22ai_1 U17 ( .A1(n22), .A2(n9), .B1(n23), .B2(n14), .Y(
        load_in[20]) );
  sky130_fd_sc_hd__o22ai_1 U18 ( .A1(n22), .A2(n10), .B1(n23), .B2(n13), .Y(
        load_in[21]) );
  sky130_fd_sc_hd__o22ai_1 U19 ( .A1(n22), .A2(n11), .B1(n23), .B2(n12), .Y(
        load_in[22]) );
  sky130_fd_sc_hd__o22ai_1 U20 ( .A1(n22), .A2(n12), .B1(n23), .B2(n11), .Y(
        load_in[23]) );
  sky130_fd_sc_hd__o22ai_1 U21 ( .A1(n22), .A2(n13), .B1(n23), .B2(n10), .Y(
        load_in[24]) );
  sky130_fd_sc_hd__o22ai_1 U22 ( .A1(n22), .A2(n14), .B1(n23), .B2(n9), .Y(
        load_in[25]) );
  sky130_fd_sc_hd__o22ai_1 U23 ( .A1(n22), .A2(n15), .B1(n23), .B2(n8), .Y(
        load_in[26]) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(cycle[0]), .Y(n5) );
  sky130_fd_sc_hd__o2bb2ai_1 U25 ( .B1(n17), .B2(n16), .A1_N(n16), .A2_N(
        \temp_tile[0] ), .Y(vram_addr[4]) );
  sky130_fd_sc_hd__nor2_1 U26 ( .A(cycle[1]), .B(n24), .Y(load[3]) );
  sky130_fd_sc_hd__nor2_1 U27 ( .A(n6), .B(n24), .Y(load[2]) );
  sky130_fd_sc_hd__and2_1 U28 ( .A(ce), .B(load[0]), .X(n2) );
  sky130_fd_sc_hd__and2_1 U29 ( .A(cycle[0]), .B(n20), .X(n3) );
  sky130_fd_sc_hd__and2_1 U30 ( .A(n20), .B(n5), .X(n4) );
  sky130_fd_sc_hd__nor2_1 U31 ( .A(n25), .B(cycle[0]), .Y(load[0]) );
endmodule


module Sprite_0 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   \load_out[0] , \load_out[2] , \load_out[1] , n43, n67, n68, n69, n70,
         n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84,
         n85, n86, n87, n88, n89, n90, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
         n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n91,
         n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104,
         n105, n106, n107, n108;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n3), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n3), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n3), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n43) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_0_ ( .D(n90), .CLK(clk), .Q(load_out[3]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_1_ ( .D(n88), .CLK(clk), .Q(load_out[4]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_2_ ( .D(n87), .CLK(clk), .Q(load_out[5]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_3_ ( .D(n86), .CLK(clk), .Q(load_out[6]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_4_ ( .D(n85), .CLK(clk), .Q(load_out[7]) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_7_ ( .D(n89), .CLK(clk), .Q(
        load_out[10]) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_5_ ( .D(n84), .CLK(clk), .Q(load_out[8]) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_6_ ( .D(n83), .CLK(clk), .Q(load_out[9]) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n74), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n67), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n68), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n69), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n70), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n71), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n72), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_0_ ( .D(n73), .CLK(clk), .Q(load_out[11])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n82), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n75), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n76), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n77), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n78), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n79), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n80), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_0_ ( .D(n81), .CLK(clk), .Q(load_out[19])
         );
  sky130_fd_sc_hd__clkinv_1 U3 ( .A(n11), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n44), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n24), .Y(n29) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(n9), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n46), .Y(n38) );
  sky130_fd_sc_hd__inv_1 U8 ( .A(n106), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(ce), .Y(n7) );
  sky130_fd_sc_hd__o21ai_1 U10 ( .A1(n108), .A2(n7), .B1(n65), .Y(n63) );
  sky130_fd_sc_hd__o21ai_1 U11 ( .A1(n107), .A2(n7), .B1(n65), .Y(n104) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(n35), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n39), .Y(n34) );
  sky130_fd_sc_hd__a21o_1 U14 ( .A1(load_in[6]), .A2(n6), .B1(n26), .X(n86) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(n18), .Y(n21) );
  sky130_fd_sc_hd__nor2_1 U16 ( .A(load_out[3]), .B(n44), .Y(n15) );
  sky130_fd_sc_hd__and2_1 U17 ( .A(n63), .B(n108), .X(n1) );
  sky130_fd_sc_hd__and2_1 U18 ( .A(n104), .B(n107), .X(n2) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(load[0]), .B(ce), .X(n3) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(n63), .B(load[3]), .X(n4) );
  sky130_fd_sc_hd__and2_1 U21 ( .A(n104), .B(load[2]), .X(n5) );
  sky130_fd_sc_hd__and2_1 U22 ( .A(load[1]), .B(n31), .X(n6) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(load[3]), .Y(n108) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(load[2]), .Y(n107) );
  sky130_fd_sc_hd__a21o_2 U25 ( .A1(load_in[9]), .A2(n6), .B1(n40), .X(n83) );
  sky130_fd_sc_hd__a221o_2 U26 ( .A1(load_out[8]), .A2(n35), .B1(load_in[8]), 
        .B2(n6), .C1(n34), .X(n84) );
  sky130_fd_sc_hd__a221o_1 U27 ( .A1(load_out[10]), .A2(n46), .B1(load_in[10]), 
        .B2(n6), .C1(n45), .X(n89) );
  sky130_fd_sc_hd__a21o_2 U28 ( .A1(load_in[3]), .A2(n6), .B1(n13), .X(n90) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(load[1]), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(load_out[4]), .Y(n8) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(load_out[5]), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U32 ( .A(load_out[3]), .Y(n14) );
  sky130_fd_sc_hd__nand3_1 U33 ( .A(n8), .B(n20), .C(n14), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(load_out[7]), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U35 ( .A(load_out[6]), .Y(n10) );
  sky130_fd_sc_hd__nand3_1 U36 ( .A(n23), .B(n28), .C(n10), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U37 ( .A(load_out[9]), .Y(n42) );
  sky130_fd_sc_hd__inv_1 U38 ( .A(load_out[8]), .Y(n37) );
  sky130_fd_sc_hd__inv_1 U39 ( .A(load_out[10]), .Y(n41) );
  sky130_fd_sc_hd__nand4_1 U40 ( .A(n32), .B(n42), .C(n37), .D(n41), .Y(n106)
         );
  sky130_fd_sc_hd__o22ai_1 U41 ( .A1(n7), .A2(n12), .B1(n43), .B2(n48), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(n31), .B(n12), .Y(n44) );
  sky130_fd_sc_hd__mux2i_1 U43 ( .A0(n44), .A1(n31), .S(load_out[3]), .Y(n13)
         );
  sky130_fd_sc_hd__o21ai_1 U44 ( .A1(n44), .A2(n14), .B1(n31), .Y(n18) );
  sky130_fd_sc_hd__mux2i_1 U45 ( .A0(n15), .A1(n18), .S(load_out[4]), .Y(n17)
         );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(load_in[4]), .B(n6), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(n17), .B(n16), .Y(n88) );
  sky130_fd_sc_hd__a21oi_1 U48 ( .A1(load_out[5]), .A2(load_out[4]), .B1(n23), 
        .Y(n22) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(load_in[5]), .B(n6), .Y(n19) );
  sky130_fd_sc_hd__o221ai_1 U50 ( .A1(n22), .A2(n44), .B1(n21), .B2(n20), .C1(
        n19), .Y(n87) );
  sky130_fd_sc_hd__nand2_1 U51 ( .A(n33), .B(n23), .Y(n25) );
  sky130_fd_sc_hd__o21ai_1 U52 ( .A1(n23), .A2(n44), .B1(n31), .Y(n24) );
  sky130_fd_sc_hd__mux2i_1 U53 ( .A0(n25), .A1(n29), .S(load_out[6]), .Y(n26)
         );
  sky130_fd_sc_hd__a21oi_1 U54 ( .A1(load_out[7]), .A2(load_out[6]), .B1(n32), 
        .Y(n30) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(load_in[7]), .B(n6), .Y(n27) );
  sky130_fd_sc_hd__o221ai_1 U56 ( .A1(n30), .A2(n44), .B1(n29), .B2(n28), .C1(
        n27), .Y(n85) );
  sky130_fd_sc_hd__o21ai_1 U57 ( .A1(n32), .A2(n44), .B1(n31), .Y(n35) );
  sky130_fd_sc_hd__nand3_1 U58 ( .A(n33), .B(n32), .C(n37), .Y(n39) );
  sky130_fd_sc_hd__o21ai_1 U59 ( .A1(n44), .A2(n37), .B1(n36), .Y(n46) );
  sky130_fd_sc_hd__mux2i_1 U60 ( .A0(n39), .A1(n38), .S(load_out[9]), .Y(n40)
         );
  sky130_fd_sc_hd__nor3_1 U61 ( .A(n44), .B(n42), .C(n41), .Y(n45) );
  sky130_fd_sc_hd__inv_1 U62 ( .A(n43), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U63 ( .A(n48), .B(n47), .Y(n65) );
  sky130_fd_sc_hd__inv_1 U64 ( .A(load_out[26]), .Y(n49) );
  sky130_fd_sc_hd__o2bb2ai_1 U65 ( .B1(n63), .B2(n49), .A1_N(load_in[26]), 
        .A2_N(n4), .Y(n82) );
  sky130_fd_sc_hd__inv_1 U66 ( .A(load_out[25]), .Y(n51) );
  sky130_fd_sc_hd__a22oi_1 U67 ( .A1(load_in[25]), .A2(n4), .B1(load_out[26]), 
        .B2(n1), .Y(n50) );
  sky130_fd_sc_hd__o21ai_1 U68 ( .A1(n63), .A2(n51), .B1(n50), .Y(n75) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(load_out[24]), .Y(n53) );
  sky130_fd_sc_hd__a22oi_1 U70 ( .A1(load_in[24]), .A2(n4), .B1(load_out[25]), 
        .B2(n1), .Y(n52) );
  sky130_fd_sc_hd__o21ai_1 U71 ( .A1(n63), .A2(n53), .B1(n52), .Y(n76) );
  sky130_fd_sc_hd__inv_1 U72 ( .A(load_out[23]), .Y(n55) );
  sky130_fd_sc_hd__a22oi_1 U73 ( .A1(load_in[23]), .A2(n4), .B1(load_out[24]), 
        .B2(n1), .Y(n54) );
  sky130_fd_sc_hd__o21ai_1 U74 ( .A1(n63), .A2(n55), .B1(n54), .Y(n77) );
  sky130_fd_sc_hd__inv_1 U75 ( .A(load_out[22]), .Y(n57) );
  sky130_fd_sc_hd__a22oi_1 U76 ( .A1(load_in[22]), .A2(n4), .B1(load_out[23]), 
        .B2(n1), .Y(n56) );
  sky130_fd_sc_hd__o21ai_1 U77 ( .A1(n63), .A2(n57), .B1(n56), .Y(n78) );
  sky130_fd_sc_hd__inv_1 U78 ( .A(load_out[21]), .Y(n59) );
  sky130_fd_sc_hd__a22oi_1 U79 ( .A1(load_in[21]), .A2(n4), .B1(load_out[22]), 
        .B2(n1), .Y(n58) );
  sky130_fd_sc_hd__o21ai_1 U80 ( .A1(n63), .A2(n59), .B1(n58), .Y(n79) );
  sky130_fd_sc_hd__inv_1 U81 ( .A(load_out[20]), .Y(n61) );
  sky130_fd_sc_hd__a22oi_1 U82 ( .A1(load_in[20]), .A2(n4), .B1(load_out[21]), 
        .B2(n1), .Y(n60) );
  sky130_fd_sc_hd__o21ai_1 U83 ( .A1(n61), .A2(n63), .B1(n60), .Y(n80) );
  sky130_fd_sc_hd__inv_1 U84 ( .A(load_out[19]), .Y(n64) );
  sky130_fd_sc_hd__a22oi_1 U85 ( .A1(load_in[19]), .A2(n4), .B1(load_out[20]), 
        .B2(n1), .Y(n62) );
  sky130_fd_sc_hd__o21ai_1 U86 ( .A1(n64), .A2(n63), .B1(n62), .Y(n81) );
  sky130_fd_sc_hd__nor2_1 U87 ( .A(n106), .B(n64), .Y(bits[0]) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(load_out[18]), .Y(n66) );
  sky130_fd_sc_hd__o2bb2ai_1 U89 ( .B1(n104), .B2(n66), .A1_N(load_in[18]), 
        .A2_N(n5), .Y(n74) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(load_out[17]), .Y(n92) );
  sky130_fd_sc_hd__a22oi_1 U91 ( .A1(load_in[17]), .A2(n5), .B1(load_out[18]), 
        .B2(n2), .Y(n91) );
  sky130_fd_sc_hd__o21ai_1 U93 ( .A1(n104), .A2(n92), .B1(n91), .Y(n67) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(load_out[16]), .Y(n94) );
  sky130_fd_sc_hd__a22oi_1 U95 ( .A1(load_in[16]), .A2(n5), .B1(load_out[17]), 
        .B2(n2), .Y(n93) );
  sky130_fd_sc_hd__o21ai_1 U96 ( .A1(n104), .A2(n94), .B1(n93), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U97 ( .A(load_out[15]), .Y(n96) );
  sky130_fd_sc_hd__a22oi_1 U98 ( .A1(load_in[15]), .A2(n5), .B1(load_out[16]), 
        .B2(n2), .Y(n95) );
  sky130_fd_sc_hd__o21ai_1 U99 ( .A1(n104), .A2(n96), .B1(n95), .Y(n69) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(load_out[14]), .Y(n98) );
  sky130_fd_sc_hd__a22oi_1 U101 ( .A1(load_in[14]), .A2(n5), .B1(load_out[15]), 
        .B2(n2), .Y(n97) );
  sky130_fd_sc_hd__o21ai_1 U102 ( .A1(n104), .A2(n98), .B1(n97), .Y(n70) );
  sky130_fd_sc_hd__inv_1 U103 ( .A(load_out[13]), .Y(n100) );
  sky130_fd_sc_hd__a22oi_1 U104 ( .A1(load_in[13]), .A2(n5), .B1(load_out[14]), 
        .B2(n2), .Y(n99) );
  sky130_fd_sc_hd__o21ai_1 U105 ( .A1(n104), .A2(n100), .B1(n99), .Y(n71) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(load_out[12]), .Y(n102) );
  sky130_fd_sc_hd__a22oi_1 U107 ( .A1(load_in[12]), .A2(n5), .B1(load_out[13]), 
        .B2(n2), .Y(n101) );
  sky130_fd_sc_hd__o21ai_1 U108 ( .A1(n102), .A2(n104), .B1(n101), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(load_out[11]), .Y(n105) );
  sky130_fd_sc_hd__a22oi_1 U110 ( .A1(load_in[11]), .A2(n5), .B1(load_out[12]), 
        .B2(n2), .Y(n103) );
  sky130_fd_sc_hd__o21ai_1 U111 ( .A1(n105), .A2(n104), .B1(n103), .Y(n73) );
  sky130_fd_sc_hd__nor2_1 U112 ( .A(n106), .B(n105), .Y(bits[1]) );
endmodule


module Sprite_7 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n146, n147, n148, n149, \load_out[0] , \load_out[2] , \load_out[1] ,
         n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
         n35, n36, n37, n38, n39, n40, n41, n42, n44, n45, n46, n47, n48, n49,
         n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63,
         n64, n65, n66, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n4), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n4), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n4), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n145) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_3_ ( .D(n125), .CLK(clk), .Q(
        load_out[6]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_4_ ( .D(n126), .CLK(clk), .Q(
        load_out[7]) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_7_ ( .D(n122), .CLK(clk), .Q(n146) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_6_ ( .D(n128), .CLK(clk), .Q(n147) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_5_ ( .D(n127), .CLK(clk), .Q(n148) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_0_ ( .D(n121), .CLK(clk), .Q(n149) );
  sky130_fd_sc_hd__dfxbp_1 x_coord_reg_1_ ( .D(n123), .CLK(clk), .Q(
        load_out[4]), .Q_N(n24) );
  sky130_fd_sc_hd__dfxbp_1 x_coord_reg_2_ ( .D(n124), .CLK(clk), .Q(
        load_out[5]), .Q_N(n23) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n137), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n144), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n143), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n142), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n141), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n140), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n139), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_0_ ( .D(n138), .CLK(clk), .Q(load_out[11])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n129), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n136), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n135), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n134), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n133), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n132), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n131), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_0_ ( .D(n130), .CLK(clk), .Q(load_out[19])
         );
  sky130_fd_sc_hd__inv_1 U3 ( .A(n55), .Y(load_out[9]) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n147), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n48), .Y(n49) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(n56), .Y(n46) );
  sky130_fd_sc_hd__nor2_1 U7 ( .A(load_out[7]), .B(load_out[6]), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(ce), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U9 ( .A(load_out[6]), .Y(n39) );
  sky130_fd_sc_hd__clkinv_1 U10 ( .A(n146), .Y(n54) );
  sky130_fd_sc_hd__o21ai_1 U11 ( .A1(n22), .A2(n62), .B1(n102), .Y(n100) );
  sky130_fd_sc_hd__o21ai_1 U12 ( .A1(n22), .A2(n104), .B1(n102), .Y(n118) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n36), .Y(n42) );
  sky130_fd_sc_hd__o211ai_1 U14 ( .A1(n35), .A2(n56), .B1(n34), .C1(n33), .Y(
        n124) );
  sky130_fd_sc_hd__a21oi_1 U15 ( .A1(load_out[5]), .A2(load_out[4]), .B1(n9), 
        .Y(n35) );
  sky130_fd_sc_hd__nor2_1 U16 ( .A(load_out[3]), .B(n56), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(n52), .Y(n47) );
  sky130_fd_sc_hd__inv_1 U18 ( .A(n58), .Y(n51) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(n39), .B(n41), .X(n1) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(load[3]), .B(n100), .X(n2) );
  sky130_fd_sc_hd__and2_1 U21 ( .A(load[2]), .B(n118), .X(n3) );
  sky130_fd_sc_hd__and2_1 U22 ( .A(load[0]), .B(ce), .X(n4) );
  sky130_fd_sc_hd__and2_1 U23 ( .A(n24), .B(n23), .X(n5) );
  sky130_fd_sc_hd__and2_1 U24 ( .A(n100), .B(n62), .X(n6) );
  sky130_fd_sc_hd__and2_1 U25 ( .A(n118), .B(n104), .X(n7) );
  sky130_fd_sc_hd__and2_1 U26 ( .A(load[1]), .B(n45), .X(n8) );
  sky130_fd_sc_hd__and2_1 U27 ( .A(n5), .B(n31), .X(n9) );
  sky130_fd_sc_hd__and3_1 U28 ( .A(n9), .B(n41), .C(n39), .X(n10) );
  sky130_fd_sc_hd__nor2_1 U29 ( .A(load_out[4]), .B(n14), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(load_out[7]), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U31 ( .A(n13), .B(n16), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(n23), .B(n11), .Y(n14) );
  sky130_fd_sc_hd__nand3_1 U33 ( .A(n25), .B(n5), .C(n1), .Y(n120) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(load_out[8]), .Y(n15) );
  sky130_fd_sc_hd__and4b_1 U35 ( .B(n54), .C(n55), .D(n50), .A_N(n149), .X(n16) );
  sky130_fd_sc_hd__dlygate4sd3_1 U36 ( .A(n12), .X(n17) );
  sky130_fd_sc_hd__dlygate4sd3_1 U37 ( .A(n148), .X(load_out[8]) );
  sky130_fd_sc_hd__o21ai_0 U38 ( .A1(n56), .A2(n50), .B1(n49), .Y(n58) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(n31), .Y(load_out[3]) );
  sky130_fd_sc_hd__and4b_1 U40 ( .B(n54), .C(n55), .D(n50), .A_N(n149), .X(n25) );
  sky130_fd_sc_hd__clkinv_1 U41 ( .A(n148), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U42 ( .A(n17), .Y(n60) );
  sky130_fd_sc_hd__inv_2 U43 ( .A(n54), .Y(load_out[10]) );
  sky130_fd_sc_hd__inv_1 U44 ( .A(load[1]), .Y(n26) );
  sky130_fd_sc_hd__o22ai_1 U45 ( .A1(n22), .A2(n26), .B1(n145), .B2(n60), .Y(
        n45) );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(n45), .B(n26), .Y(n56) );
  sky130_fd_sc_hd__mux2i_1 U47 ( .A0(n56), .A1(n45), .S(load_out[3]), .Y(n27)
         );
  sky130_fd_sc_hd__a21o_1 U48 ( .A1(load_in[3]), .A2(n8), .B1(n27), .X(n121)
         );
  sky130_fd_sc_hd__inv_1 U49 ( .A(n149), .Y(n31) );
  sky130_fd_sc_hd__o21ai_1 U50 ( .A1(n56), .A2(n31), .B1(n45), .Y(n32) );
  sky130_fd_sc_hd__mux2i_1 U51 ( .A0(n28), .A1(n32), .S(load_out[4]), .Y(n30)
         );
  sky130_fd_sc_hd__nand2_1 U52 ( .A(load_in[4]), .B(n8), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U53 ( .A(n30), .B(n29), .Y(n123) );
  sky130_fd_sc_hd__nand2_1 U54 ( .A(load_out[5]), .B(n32), .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(load_in[5]), .B(n8), .Y(n33) );
  sky130_fd_sc_hd__nand2_1 U56 ( .A(n9), .B(n46), .Y(n37) );
  sky130_fd_sc_hd__o21ai_1 U57 ( .A1(n9), .A2(n56), .B1(n45), .Y(n36) );
  sky130_fd_sc_hd__mux2i_1 U58 ( .A0(n37), .A1(n42), .S(load_out[6]), .Y(n38)
         );
  sky130_fd_sc_hd__a21o_1 U59 ( .A1(load_in[6]), .A2(n8), .B1(n38), .X(n125)
         );
  sky130_fd_sc_hd__a21oi_1 U60 ( .A1(load_out[7]), .A2(load_out[6]), .B1(n10), 
        .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(load_in[7]), .B(n8), .Y(n40) );
  sky130_fd_sc_hd__o221ai_1 U62 ( .A1(n44), .A2(n56), .B1(n42), .B2(n41), .C1(
        n40), .Y(n126) );
  sky130_fd_sc_hd__o21ai_1 U63 ( .A1(n10), .A2(n56), .B1(n45), .Y(n48) );
  sky130_fd_sc_hd__nand3_1 U64 ( .A(n10), .B(n46), .C(n15), .Y(n52) );
  sky130_fd_sc_hd__a221o_1 U65 ( .A1(load_out[8]), .A2(n48), .B1(load_in[8]), 
        .B2(n8), .C1(n47), .X(n127) );
  sky130_fd_sc_hd__mux2i_1 U66 ( .A0(n52), .A1(n51), .S(load_out[9]), .Y(n53)
         );
  sky130_fd_sc_hd__a21o_1 U67 ( .A1(load_in[9]), .A2(n8), .B1(n53), .X(n128)
         );
  sky130_fd_sc_hd__nor3_1 U68 ( .A(n56), .B(n55), .C(n54), .Y(n57) );
  sky130_fd_sc_hd__a221o_1 U69 ( .A1(load_out[10]), .A2(n58), .B1(load_in[10]), 
        .B2(n8), .C1(n57), .X(n122) );
  sky130_fd_sc_hd__inv_1 U70 ( .A(load[3]), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U71 ( .A(n145), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(n60), .B(n59), .Y(n102) );
  sky130_fd_sc_hd__inv_1 U73 ( .A(load_out[26]), .Y(n61) );
  sky130_fd_sc_hd__o2bb2ai_1 U74 ( .B1(n100), .B2(n61), .A1_N(load_in[26]), 
        .A2_N(n2), .Y(n129) );
  sky130_fd_sc_hd__inv_1 U75 ( .A(load_out[25]), .Y(n64) );
  sky130_fd_sc_hd__a22oi_1 U76 ( .A1(load_in[25]), .A2(n2), .B1(load_out[26]), 
        .B2(n6), .Y(n63) );
  sky130_fd_sc_hd__o21ai_1 U77 ( .A1(n100), .A2(n64), .B1(n63), .Y(n136) );
  sky130_fd_sc_hd__inv_1 U78 ( .A(load_out[24]), .Y(n66) );
  sky130_fd_sc_hd__a22oi_1 U79 ( .A1(load_in[24]), .A2(n2), .B1(load_out[25]), 
        .B2(n6), .Y(n65) );
  sky130_fd_sc_hd__o21ai_1 U80 ( .A1(n100), .A2(n66), .B1(n65), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U81 ( .A(load_out[23]), .Y(n92) );
  sky130_fd_sc_hd__a22oi_1 U82 ( .A1(load_in[23]), .A2(n2), .B1(load_out[24]), 
        .B2(n6), .Y(n91) );
  sky130_fd_sc_hd__o21ai_1 U83 ( .A1(n100), .A2(n92), .B1(n91), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U84 ( .A(load_out[22]), .Y(n94) );
  sky130_fd_sc_hd__a22oi_1 U85 ( .A1(load_in[22]), .A2(n2), .B1(load_out[23]), 
        .B2(n6), .Y(n93) );
  sky130_fd_sc_hd__o21ai_1 U86 ( .A1(n100), .A2(n94), .B1(n93), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U87 ( .A(load_out[21]), .Y(n96) );
  sky130_fd_sc_hd__a22oi_1 U88 ( .A1(load_in[21]), .A2(n2), .B1(load_out[22]), 
        .B2(n6), .Y(n95) );
  sky130_fd_sc_hd__o21ai_1 U89 ( .A1(n100), .A2(n96), .B1(n95), .Y(n132) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(load_out[20]), .Y(n98) );
  sky130_fd_sc_hd__a22oi_1 U91 ( .A1(load_in[20]), .A2(n2), .B1(load_out[21]), 
        .B2(n6), .Y(n97) );
  sky130_fd_sc_hd__o21ai_1 U93 ( .A1(n98), .A2(n100), .B1(n97), .Y(n131) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(load_out[19]), .Y(n101) );
  sky130_fd_sc_hd__a22oi_1 U95 ( .A1(load_in[19]), .A2(n2), .B1(load_out[20]), 
        .B2(n6), .Y(n99) );
  sky130_fd_sc_hd__o21ai_1 U96 ( .A1(n101), .A2(n100), .B1(n99), .Y(n130) );
  sky130_fd_sc_hd__nor2_1 U97 ( .A(n120), .B(n101), .Y(bits[0]) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(load[2]), .Y(n104) );
  sky130_fd_sc_hd__inv_1 U99 ( .A(load_out[18]), .Y(n103) );
  sky130_fd_sc_hd__o2bb2ai_1 U100 ( .B1(n118), .B2(n103), .A1_N(load_in[18]), 
        .A2_N(n3), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(load_out[17]), .Y(n106) );
  sky130_fd_sc_hd__a22oi_1 U102 ( .A1(load_in[17]), .A2(n3), .B1(load_out[18]), 
        .B2(n7), .Y(n105) );
  sky130_fd_sc_hd__o21ai_1 U103 ( .A1(n118), .A2(n106), .B1(n105), .Y(n144) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(load_out[16]), .Y(n108) );
  sky130_fd_sc_hd__a22oi_1 U105 ( .A1(load_in[16]), .A2(n3), .B1(load_out[17]), 
        .B2(n7), .Y(n107) );
  sky130_fd_sc_hd__o21ai_1 U106 ( .A1(n118), .A2(n108), .B1(n107), .Y(n143) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(load_out[15]), .Y(n110) );
  sky130_fd_sc_hd__a22oi_1 U108 ( .A1(load_in[15]), .A2(n3), .B1(load_out[16]), 
        .B2(n7), .Y(n109) );
  sky130_fd_sc_hd__o21ai_1 U109 ( .A1(n118), .A2(n110), .B1(n109), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(load_out[14]), .Y(n112) );
  sky130_fd_sc_hd__a22oi_1 U111 ( .A1(load_in[14]), .A2(n3), .B1(load_out[15]), 
        .B2(n7), .Y(n111) );
  sky130_fd_sc_hd__o21ai_1 U112 ( .A1(n118), .A2(n112), .B1(n111), .Y(n141) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(load_out[13]), .Y(n114) );
  sky130_fd_sc_hd__a22oi_1 U114 ( .A1(load_in[13]), .A2(n3), .B1(load_out[14]), 
        .B2(n7), .Y(n113) );
  sky130_fd_sc_hd__o21ai_1 U115 ( .A1(n118), .A2(n114), .B1(n113), .Y(n140) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(load_out[12]), .Y(n116) );
  sky130_fd_sc_hd__a22oi_1 U117 ( .A1(load_in[12]), .A2(n3), .B1(load_out[13]), 
        .B2(n7), .Y(n115) );
  sky130_fd_sc_hd__o21ai_1 U118 ( .A1(n116), .A2(n118), .B1(n115), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U119 ( .A(load_out[11]), .Y(n119) );
  sky130_fd_sc_hd__a22oi_1 U120 ( .A1(load_in[11]), .A2(n3), .B1(load_out[12]), 
        .B2(n7), .Y(n117) );
  sky130_fd_sc_hd__o21ai_1 U121 ( .A1(n119), .A2(n118), .B1(n117), .Y(n138) );
  sky130_fd_sc_hd__nor2_1 U122 ( .A(n119), .B(n12), .Y(bits[1]) );
endmodule


module Sprite_6 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n145, n146, n147, \load_out[0] , \load_out[2] , \load_out[1] , n1, n2,
         n3, n4, n5, n6, n7, n8, n11, n12, n13, n14, n16, n17, n18, n19, n20,
         n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
         n35, n36, n37, n38, n39, n40, n41, n42, n44, n45, n46, n47, n48, n49,
         n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63,
         n64, n65, n66, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n3), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n3), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n3), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n144) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_1_ ( .D(n122), .CLK(clk), .Q(
        load_out[4]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_2_ ( .D(n123), .CLK(clk), .Q(
        load_out[5]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_4_ ( .D(n125), .CLK(clk), .Q(
        load_out[7]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_6_ ( .D(n127), .CLK(clk), .Q(
        load_out[9]) );
  sky130_fd_sc_hd__dfxbp_1 pix2_reg_0_ ( .D(n137), .CLK(clk), .Q(load_out[11]), 
        .Q_N(n118) );
  sky130_fd_sc_hd__dfxbp_1 pix1_reg_0_ ( .D(n129), .CLK(clk), .Q(load_out[19]), 
        .Q_N(n100) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_0_ ( .D(n120), .CLK(clk), .Q(n147) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n136), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n143), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n142), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n141), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n140), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n139), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n138), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n128), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n135), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n134), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n133), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n132), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n131), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n130), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_7_ ( .D(n121), .CLK(clk), .Q(n145) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_3_ ( .D(n124), .CLK(clk), .Q(
        load_out[6]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_5_ ( .D(n126), .CLK(clk), .Q(n146) );
  sky130_fd_sc_hd__nand3_1 U3 ( .A(n24), .B(n31), .C(n18), .Y(n119) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n17), .Y(n18) );
  sky130_fd_sc_hd__clkinv_2 U5 ( .A(n146), .Y(n50) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(n56), .Y(n46) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n58), .Y(n51) );
  sky130_fd_sc_hd__o211ai_1 U8 ( .A1(n35), .A2(n56), .B1(n34), .C1(n33), .Y(
        n123) );
  sky130_fd_sc_hd__a21oi_1 U9 ( .A1(load_out[5]), .A2(load_out[4]), .B1(n7), 
        .Y(n35) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(ce), .Y(n20) );
  sky130_fd_sc_hd__clkinv_1 U11 ( .A(load_out[9]), .Y(n55) );
  sky130_fd_sc_hd__clkinv_1 U12 ( .A(n145), .Y(n54) );
  sky130_fd_sc_hd__o21ai_1 U13 ( .A1(n20), .A2(n61), .B1(n101), .Y(n99) );
  sky130_fd_sc_hd__o21ai_1 U14 ( .A1(n20), .A2(n103), .B1(n101), .Y(n117) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(n48), .Y(n49) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(n36), .Y(n42) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(n52), .Y(n47) );
  sky130_fd_sc_hd__and2_1 U18 ( .A(load[3]), .B(n99), .X(n1) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(load[2]), .B(n117), .X(n2) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(load[0]), .B(ce), .X(n3) );
  sky130_fd_sc_hd__and2_1 U21 ( .A(n99), .B(n61), .X(n4) );
  sky130_fd_sc_hd__and2_1 U22 ( .A(n117), .B(n103), .X(n5) );
  sky130_fd_sc_hd__and2_1 U23 ( .A(load[1]), .B(n45), .X(n6) );
  sky130_fd_sc_hd__and2_1 U24 ( .A(n31), .B(n11), .X(n7) );
  sky130_fd_sc_hd__and3_1 U25 ( .A(n7), .B(n41), .C(n39), .X(n8) );
  sky130_fd_sc_hd__dlygate4sd1_1 U26 ( .A(n147), .X(load_out[3]) );
  sky130_fd_sc_hd__dlygate4sd3_1 U27 ( .A(n145), .X(load_out[10]) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(load_out[3]), .Y(n11) );
  sky130_fd_sc_hd__clkinv_1 U29 ( .A(n147), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(load_out[6]), .Y(n39) );
  sky130_fd_sc_hd__nor2_1 U31 ( .A(n13), .B(n12), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(n55), .B(n54), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n30), .B(n50), .Y(n13) );
  sky130_fd_sc_hd__and4b_2 U34 ( .B(n54), .C(n55), .D(n50), .A_N(load_out[3]), 
        .X(n16) );
  sky130_fd_sc_hd__inv_1 U35 ( .A(n146), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U36 ( .A(n14), .Y(load_out[8]) );
  sky130_fd_sc_hd__a221o_2 U37 ( .A1(load_out[8]), .A2(n48), .B1(load_in[8]), 
        .B2(n6), .C1(n47), .X(n126) );
  sky130_fd_sc_hd__o21ai_0 U38 ( .A1(n56), .A2(n50), .B1(n49), .Y(n58) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(load_out[3]), .B(n56), .Y(n27) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n41), .B(n39), .Y(n17) );
  sky130_fd_sc_hd__and4_2 U41 ( .A(n39), .B(n41), .C(n31), .D(n16), .X(n19) );
  sky130_fd_sc_hd__inv_1 U42 ( .A(n23), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U43 ( .A(load[1]), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U44 ( .A(load_out[7]), .Y(n41) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(load_out[4]), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U46 ( .A(load_out[5]), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(n22), .B(n21), .Y(n23) );
  sky130_fd_sc_hd__o22ai_1 U48 ( .A1(n20), .A2(n25), .B1(n144), .B2(n19), .Y(
        n45) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n45), .B(n25), .Y(n56) );
  sky130_fd_sc_hd__mux2i_1 U50 ( .A0(n56), .A1(n45), .S(load_out[3]), .Y(n26)
         );
  sky130_fd_sc_hd__a21o_1 U51 ( .A1(load_in[3]), .A2(n6), .B1(n26), .X(n120)
         );
  sky130_fd_sc_hd__o21ai_1 U52 ( .A1(n56), .A2(n11), .B1(n45), .Y(n32) );
  sky130_fd_sc_hd__mux2i_1 U53 ( .A0(n27), .A1(n32), .S(load_out[4]), .Y(n29)
         );
  sky130_fd_sc_hd__nand2_1 U54 ( .A(load_in[4]), .B(n6), .Y(n28) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(n29), .B(n28), .Y(n122) );
  sky130_fd_sc_hd__nand2_1 U56 ( .A(load_out[5]), .B(n32), .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U57 ( .A(load_in[5]), .B(n6), .Y(n33) );
  sky130_fd_sc_hd__nand2_1 U58 ( .A(n7), .B(n46), .Y(n37) );
  sky130_fd_sc_hd__o21ai_1 U59 ( .A1(n7), .A2(n56), .B1(n45), .Y(n36) );
  sky130_fd_sc_hd__mux2i_1 U60 ( .A0(n37), .A1(n42), .S(load_out[6]), .Y(n38)
         );
  sky130_fd_sc_hd__a21o_1 U61 ( .A1(load_in[6]), .A2(n6), .B1(n38), .X(n124)
         );
  sky130_fd_sc_hd__a21oi_1 U62 ( .A1(load_out[7]), .A2(load_out[6]), .B1(n8), 
        .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U63 ( .A(load_in[7]), .B(n6), .Y(n40) );
  sky130_fd_sc_hd__o221ai_1 U64 ( .A1(n44), .A2(n56), .B1(n42), .B2(n41), .C1(
        n40), .Y(n125) );
  sky130_fd_sc_hd__o21ai_1 U65 ( .A1(n8), .A2(n56), .B1(n45), .Y(n48) );
  sky130_fd_sc_hd__nand3_1 U66 ( .A(n8), .B(n46), .C(n50), .Y(n52) );
  sky130_fd_sc_hd__mux2i_1 U67 ( .A0(n52), .A1(n51), .S(load_out[9]), .Y(n53)
         );
  sky130_fd_sc_hd__a21o_1 U68 ( .A1(load_in[9]), .A2(n6), .B1(n53), .X(n127)
         );
  sky130_fd_sc_hd__nor3_1 U69 ( .A(n56), .B(n55), .C(n54), .Y(n57) );
  sky130_fd_sc_hd__a221o_1 U70 ( .A1(load_out[10]), .A2(n58), .B1(load_in[10]), 
        .B2(n6), .C1(n57), .X(n121) );
  sky130_fd_sc_hd__inv_1 U71 ( .A(load[3]), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U72 ( .A(n144), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(n19), .B(n59), .Y(n101) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(load_out[26]), .Y(n60) );
  sky130_fd_sc_hd__o2bb2ai_1 U75 ( .B1(n99), .B2(n60), .A1_N(load_in[26]), 
        .A2_N(n1), .Y(n128) );
  sky130_fd_sc_hd__inv_1 U76 ( .A(load_out[25]), .Y(n63) );
  sky130_fd_sc_hd__a22oi_1 U77 ( .A1(load_in[25]), .A2(n1), .B1(load_out[26]), 
        .B2(n4), .Y(n62) );
  sky130_fd_sc_hd__o21ai_1 U78 ( .A1(n99), .A2(n63), .B1(n62), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(load_out[24]), .Y(n65) );
  sky130_fd_sc_hd__a22oi_1 U80 ( .A1(load_in[24]), .A2(n1), .B1(load_out[25]), 
        .B2(n4), .Y(n64) );
  sky130_fd_sc_hd__o21ai_1 U81 ( .A1(n99), .A2(n65), .B1(n64), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(load_out[23]), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U83 ( .A1(load_in[23]), .A2(n1), .B1(load_out[24]), 
        .B2(n4), .Y(n66) );
  sky130_fd_sc_hd__o21ai_1 U84 ( .A1(n99), .A2(n91), .B1(n66), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(load_out[22]), .Y(n93) );
  sky130_fd_sc_hd__a22oi_1 U86 ( .A1(load_in[22]), .A2(n1), .B1(load_out[23]), 
        .B2(n4), .Y(n92) );
  sky130_fd_sc_hd__o21ai_1 U87 ( .A1(n99), .A2(n93), .B1(n92), .Y(n132) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(load_out[21]), .Y(n95) );
  sky130_fd_sc_hd__a22oi_1 U89 ( .A1(load_in[21]), .A2(n1), .B1(load_out[22]), 
        .B2(n4), .Y(n94) );
  sky130_fd_sc_hd__o21ai_1 U90 ( .A1(n99), .A2(n95), .B1(n94), .Y(n131) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(load_out[20]), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U93 ( .A1(load_in[20]), .A2(n1), .B1(load_out[21]), 
        .B2(n4), .Y(n96) );
  sky130_fd_sc_hd__o21ai_1 U94 ( .A1(n97), .A2(n99), .B1(n96), .Y(n130) );
  sky130_fd_sc_hd__a22oi_1 U95 ( .A1(load_in[19]), .A2(n1), .B1(load_out[20]), 
        .B2(n4), .Y(n98) );
  sky130_fd_sc_hd__o21ai_1 U96 ( .A1(n100), .A2(n99), .B1(n98), .Y(n129) );
  sky130_fd_sc_hd__nor2_1 U97 ( .A(n100), .B(n119), .Y(bits[0]) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(load[2]), .Y(n103) );
  sky130_fd_sc_hd__inv_1 U99 ( .A(load_out[18]), .Y(n102) );
  sky130_fd_sc_hd__o2bb2ai_1 U100 ( .B1(n117), .B2(n102), .A1_N(load_in[18]), 
        .A2_N(n2), .Y(n136) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(load_out[17]), .Y(n105) );
  sky130_fd_sc_hd__a22oi_1 U102 ( .A1(load_in[17]), .A2(n2), .B1(load_out[18]), 
        .B2(n5), .Y(n104) );
  sky130_fd_sc_hd__o21ai_1 U103 ( .A1(n117), .A2(n105), .B1(n104), .Y(n143) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(load_out[16]), .Y(n107) );
  sky130_fd_sc_hd__a22oi_1 U105 ( .A1(load_in[16]), .A2(n2), .B1(load_out[17]), 
        .B2(n5), .Y(n106) );
  sky130_fd_sc_hd__o21ai_1 U106 ( .A1(n117), .A2(n107), .B1(n106), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(load_out[15]), .Y(n109) );
  sky130_fd_sc_hd__a22oi_1 U108 ( .A1(load_in[15]), .A2(n2), .B1(load_out[16]), 
        .B2(n5), .Y(n108) );
  sky130_fd_sc_hd__o21ai_1 U109 ( .A1(n117), .A2(n109), .B1(n108), .Y(n141) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(load_out[14]), .Y(n111) );
  sky130_fd_sc_hd__a22oi_1 U111 ( .A1(load_in[14]), .A2(n2), .B1(load_out[15]), 
        .B2(n5), .Y(n110) );
  sky130_fd_sc_hd__o21ai_1 U112 ( .A1(n117), .A2(n111), .B1(n110), .Y(n140) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(load_out[13]), .Y(n113) );
  sky130_fd_sc_hd__a22oi_1 U114 ( .A1(load_in[13]), .A2(n2), .B1(load_out[14]), 
        .B2(n5), .Y(n112) );
  sky130_fd_sc_hd__o21ai_1 U115 ( .A1(n117), .A2(n113), .B1(n112), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(load_out[12]), .Y(n115) );
  sky130_fd_sc_hd__a22oi_1 U117 ( .A1(load_in[12]), .A2(n2), .B1(load_out[13]), 
        .B2(n5), .Y(n114) );
  sky130_fd_sc_hd__o21ai_1 U118 ( .A1(n115), .A2(n117), .B1(n114), .Y(n138) );
  sky130_fd_sc_hd__a22oi_1 U119 ( .A1(load_in[11]), .A2(n2), .B1(load_out[12]), 
        .B2(n5), .Y(n116) );
  sky130_fd_sc_hd__o21ai_1 U120 ( .A1(n118), .A2(n117), .B1(n116), .Y(n137) );
  sky130_fd_sc_hd__nor2_1 U121 ( .A(n118), .B(n119), .Y(bits[1]) );
endmodule


module Sprite_5 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n128, n129, n130, n131, n132, n133, n134, n135, \load_out[0] ,
         \load_out[2] , \load_out[1] , n81, net52140, net52166, net52167,
         net52168, net52187, net52192, net52203, net52204, net52218, net52229,
         net56117, net56151, net56164, net56168, net56177, net56182, net58986,
         net59103, net59454, net59578, net60297, net60357, net60360, net60369,
         net52230, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14,
         n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28,
         n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42,
         n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57,
         n58, n59, n60, n61, n62, n63, n64, n65, n66, n91, n92, n93, n94, n95,
         n96, n97, n98, n99, n100, n101, n102, n103, n104, n105, n106, n107,
         n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, n118,
         n119, n120, n121, n122, n123, n124, n125, n126, n127;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;
  assign load_out[5] = net56151;
  assign load_out[6] = net56164;
  assign load_out[3] = net56168;
  assign load_out[9] = net56177;
  assign load_out[7] = net58986;
  assign load_out[4] = net59103;
  assign load_out[8] = net59578;
  assign load_out[10] = net60360;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n8), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n8), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n8), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n127) );
  sky130_fd_sc_hd__dfxtp_2 pix2_reg_0_ ( .D(n120), .CLK(clk), .Q(load_out[11])
         );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_3_ ( .D(n108), .CLK(clk), .Q(n132) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_2_ ( .D(n107), .CLK(clk), .Q(n133) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_1_ ( .D(n106), .CLK(clk), .Q(n134) );
  sky130_fd_sc_hd__dfxbp_1 pix1_reg_0_ ( .D(n81), .CLK(clk), .Q(load_out[19]), 
        .Q_N(n19) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_7_ ( .D(n105), .CLK(clk), .Q(n128) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_4_ ( .D(n109), .CLK(clk), .Q(n131) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_6_ ( .D(n111), .CLK(clk), .Q(n129) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n119), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n126), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n125), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n124), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n123), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n122), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n121), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n112), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n118), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n117), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n116), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n115), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n114), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n113), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_5_ ( .D(n110), .CLK(clk), .Q(n130) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_0_ ( .D(n104), .CLK(clk), .Q(n135) );
  sky130_fd_sc_hd__and3_2 U3 ( .A(n6), .B(net60297), .C(n16), .X(n1) );
  sky130_fd_sc_hd__o21a_1 U4 ( .A1(n6), .A2(net52192), .B1(net52204), .X(n2)
         );
  sky130_fd_sc_hd__inv_1 U5 ( .A(n128), .Y(n3) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(n128), .Y(n21) );
  sky130_fd_sc_hd__a221o_1 U7 ( .A1(net59578), .A2(n39), .B1(load_in[8]), .B2(
        n7), .C1(n38), .X(n110) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(n129), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(net52192), .Y(net52203) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n39), .Y(n40) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(ce), .Y(n25) );
  sky130_fd_sc_hd__o21ai_1 U12 ( .A1(n25), .A2(n49), .B1(n62), .Y(net52167) );
  sky130_fd_sc_hd__o21ai_1 U13 ( .A1(n25), .A2(n64), .B1(n62), .Y(n102) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(n42), .Y(n38) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(net56168), .B(net52192), .Y(n28) );
  sky130_fd_sc_hd__a21oi_1 U16 ( .A1(net56151), .A2(net59103), .B1(n6), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(n46), .Y(n41) );
  sky130_fd_sc_hd__a21o_1 U18 ( .A1(load_in[3]), .A2(n7), .B1(n27), .X(n104)
         );
  sky130_fd_sc_hd__and2_1 U19 ( .A(load[3]), .B(net52167), .X(n4) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(load[2]), .B(n102), .X(n5) );
  sky130_fd_sc_hd__and3_1 U21 ( .A(net56117), .B(net60357), .C(n23), .X(n6) );
  sky130_fd_sc_hd__and2_1 U22 ( .A(load[1]), .B(net52204), .X(n7) );
  sky130_fd_sc_hd__and2_1 U23 ( .A(load[0]), .B(ce), .X(n8) );
  sky130_fd_sc_hd__and2_1 U24 ( .A(net52167), .B(n49), .X(n9) );
  sky130_fd_sc_hd__and2_1 U25 ( .A(n102), .B(n64), .X(n10) );
  sky130_fd_sc_hd__dlygate4sd3_1 U26 ( .A(n3), .X(net56182) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(net59578), .Y(n11) );
  sky130_fd_sc_hd__clkinv_1 U28 ( .A(n130), .Y(n22) );
  sky130_fd_sc_hd__a21o_2 U29 ( .A1(load_in[6]), .A2(n7), .B1(n35), .X(n108)
         );
  sky130_fd_sc_hd__nor2_2 U30 ( .A(n103), .B(net52140), .Y(bits[1]) );
  sky130_fd_sc_hd__a21o_2 U31 ( .A1(load_in[9]), .A2(n7), .B1(n44), .X(n111)
         );
  sky130_fd_sc_hd__nand3_1 U32 ( .A(net52230), .B(n12), .C(load_out[19]), .Y(
        n13) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(n24), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(n13), .Y(bits[0]) );
  sky130_fd_sc_hd__nand4_1 U35 ( .A(n16), .B(n15), .C(n17), .D(n18), .Y(n14)
         );
  sky130_fd_sc_hd__inv_1 U36 ( .A(n14), .Y(net52230) );
  sky130_fd_sc_hd__clkinv_1 U37 ( .A(n133), .Y(n18) );
  sky130_fd_sc_hd__dlygate4sd3_1 U38 ( .A(n18), .X(net60357) );
  sky130_fd_sc_hd__clkinv_1 U39 ( .A(n134), .Y(n17) );
  sky130_fd_sc_hd__clkinv_1 U40 ( .A(n131), .Y(n15) );
  sky130_fd_sc_hd__clkinv_1 U41 ( .A(n132), .Y(n16) );
  sky130_fd_sc_hd__dlygate4sd3_1 U42 ( .A(n134), .X(net59103) );
  sky130_fd_sc_hd__dlygate4sd1_1 U43 ( .A(n131), .X(net58986) );
  sky130_fd_sc_hd__dlygate4sd3_1 U44 ( .A(n132), .X(net56164) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(net52230), .B(net52229), .Y(net52140) );
  sky130_fd_sc_hd__nand4_1 U46 ( .A(n23), .B(n22), .C(n20), .D(n3), .Y(n24) );
  sky130_fd_sc_hd__nand4_1 U47 ( .A(n23), .B(n22), .C(n20), .D(n21), .Y(
        net52166) );
  sky130_fd_sc_hd__clkinv_2 U48 ( .A(n135), .Y(n23) );
  sky130_fd_sc_hd__o21ai_0 U49 ( .A1(net52192), .A2(n23), .B1(net52204), .Y(
        net52218) );
  sky130_fd_sc_hd__o21ai_1 U50 ( .A1(n19), .A2(net52167), .B1(net52168), .Y(
        n81) );
  sky130_fd_sc_hd__dlygate4sd3_1 U51 ( .A(n129), .X(net56177) );
  sky130_fd_sc_hd__dlygate4sd3_1 U52 ( .A(n130), .X(net59578) );
  sky130_fd_sc_hd__dlygate4sd3_1 U53 ( .A(n135), .X(net56168) );
  sky130_fd_sc_hd__inv_2 U54 ( .A(net56177), .Y(net60369) );
  sky130_fd_sc_hd__inv_2 U55 ( .A(net56182), .Y(net60360) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(net58986), .Y(net60297) );
  sky130_fd_sc_hd__dlygate4sd3_1 U57 ( .A(net52140), .X(net59454) );
  sky130_fd_sc_hd__o211ai_1 U58 ( .A1(n33), .A2(net52192), .B1(n32), .C1(n31), 
        .Y(n107) );
  sky130_fd_sc_hd__inv_1 U59 ( .A(net59454), .Y(net52187) );
  sky130_fd_sc_hd__o21ai_0 U60 ( .A1(net52192), .A2(n11), .B1(n40), .Y(n46) );
  sky130_fd_sc_hd__inv_2 U61 ( .A(net60357), .Y(net56151) );
  sky130_fd_sc_hd__inv_1 U62 ( .A(net59103), .Y(net56117) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(net52166), .Y(net52229) );
  sky130_fd_sc_hd__inv_1 U64 ( .A(load[1]), .Y(n26) );
  sky130_fd_sc_hd__o22ai_1 U65 ( .A1(n25), .A2(n26), .B1(n127), .B2(net52187), 
        .Y(net52204) );
  sky130_fd_sc_hd__nand2_1 U66 ( .A(net52204), .B(n26), .Y(net52192) );
  sky130_fd_sc_hd__mux2i_1 U67 ( .A0(net52192), .A1(net52204), .S(net56168), 
        .Y(n27) );
  sky130_fd_sc_hd__mux2i_1 U68 ( .A0(n28), .A1(net52218), .S(net59103), .Y(n30) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(load_in[4]), .B(n7), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U70 ( .A(n30), .B(n29), .Y(n106) );
  sky130_fd_sc_hd__nand2_1 U71 ( .A(net56151), .B(net52218), .Y(n32) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(load_in[5]), .B(n7), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(n6), .B(net52203), .Y(n34) );
  sky130_fd_sc_hd__mux2i_1 U74 ( .A0(n34), .A1(n2), .S(net56164), .Y(n35) );
  sky130_fd_sc_hd__a21oi_1 U75 ( .A1(net58986), .A2(net56164), .B1(n1), .Y(n37) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(load_in[7]), .B(n7), .Y(n36) );
  sky130_fd_sc_hd__o221ai_1 U77 ( .A1(n37), .A2(net52192), .B1(n2), .B2(
        net60297), .C1(n36), .Y(n109) );
  sky130_fd_sc_hd__o21ai_1 U78 ( .A1(n1), .A2(net52192), .B1(net52204), .Y(n39) );
  sky130_fd_sc_hd__nand3_1 U79 ( .A(n1), .B(net52203), .C(n11), .Y(n42) );
  sky130_fd_sc_hd__mux2i_1 U80 ( .A0(n42), .A1(n41), .S(net56177), .Y(n44) );
  sky130_fd_sc_hd__nor3_1 U81 ( .A(net52192), .B(net60369), .C(net56182), .Y(
        n45) );
  sky130_fd_sc_hd__a221o_1 U82 ( .A1(net60360), .A2(n46), .B1(load_in[10]), 
        .B2(n7), .C1(n45), .X(n105) );
  sky130_fd_sc_hd__inv_1 U83 ( .A(load[3]), .Y(n49) );
  sky130_fd_sc_hd__inv_1 U84 ( .A(n127), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U85 ( .A(net52187), .B(n47), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(load_out[26]), .Y(n48) );
  sky130_fd_sc_hd__o2bb2ai_1 U87 ( .B1(net52167), .B2(n48), .A1_N(load_in[26]), 
        .A2_N(n4), .Y(n112) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(load_out[25]), .Y(n51) );
  sky130_fd_sc_hd__a22oi_1 U89 ( .A1(load_in[25]), .A2(n4), .B1(load_out[26]), 
        .B2(n9), .Y(n50) );
  sky130_fd_sc_hd__o21ai_1 U90 ( .A1(net52167), .A2(n51), .B1(n50), .Y(n118)
         );
  sky130_fd_sc_hd__inv_1 U91 ( .A(load_out[24]), .Y(n53) );
  sky130_fd_sc_hd__a22oi_1 U93 ( .A1(load_in[24]), .A2(n4), .B1(load_out[25]), 
        .B2(n9), .Y(n52) );
  sky130_fd_sc_hd__o21ai_1 U94 ( .A1(net52167), .A2(n53), .B1(n52), .Y(n117)
         );
  sky130_fd_sc_hd__inv_1 U95 ( .A(load_out[23]), .Y(n55) );
  sky130_fd_sc_hd__a22oi_1 U96 ( .A1(load_in[23]), .A2(n4), .B1(load_out[24]), 
        .B2(n9), .Y(n54) );
  sky130_fd_sc_hd__o21ai_1 U97 ( .A1(net52167), .A2(n55), .B1(n54), .Y(n116)
         );
  sky130_fd_sc_hd__inv_1 U98 ( .A(load_out[22]), .Y(n57) );
  sky130_fd_sc_hd__a22oi_1 U99 ( .A1(load_in[22]), .A2(n4), .B1(load_out[23]), 
        .B2(n9), .Y(n56) );
  sky130_fd_sc_hd__o21ai_1 U100 ( .A1(net52167), .A2(n57), .B1(n56), .Y(n115)
         );
  sky130_fd_sc_hd__inv_1 U101 ( .A(load_out[21]), .Y(n59) );
  sky130_fd_sc_hd__a22oi_1 U102 ( .A1(load_in[21]), .A2(n4), .B1(load_out[22]), 
        .B2(n9), .Y(n58) );
  sky130_fd_sc_hd__o21ai_1 U103 ( .A1(net52167), .A2(n59), .B1(n58), .Y(n114)
         );
  sky130_fd_sc_hd__inv_1 U104 ( .A(load_out[20]), .Y(n61) );
  sky130_fd_sc_hd__a22oi_1 U105 ( .A1(load_in[20]), .A2(n4), .B1(load_out[21]), 
        .B2(n9), .Y(n60) );
  sky130_fd_sc_hd__o21ai_1 U106 ( .A1(n61), .A2(net52167), .B1(n60), .Y(n113)
         );
  sky130_fd_sc_hd__a22oi_1 U107 ( .A1(load_in[19]), .A2(n4), .B1(load_out[20]), 
        .B2(n9), .Y(net52168) );
  sky130_fd_sc_hd__inv_1 U108 ( .A(load[2]), .Y(n64) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(load_out[18]), .Y(n63) );
  sky130_fd_sc_hd__o2bb2ai_1 U110 ( .B1(n102), .B2(n63), .A1_N(load_in[18]), 
        .A2_N(n5), .Y(n119) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(load_out[17]), .Y(n66) );
  sky130_fd_sc_hd__a22oi_1 U112 ( .A1(load_in[17]), .A2(n5), .B1(load_out[18]), 
        .B2(n10), .Y(n65) );
  sky130_fd_sc_hd__o21ai_1 U113 ( .A1(n102), .A2(n66), .B1(n65), .Y(n126) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(load_out[16]), .Y(n92) );
  sky130_fd_sc_hd__a22oi_1 U115 ( .A1(load_in[16]), .A2(n5), .B1(load_out[17]), 
        .B2(n10), .Y(n91) );
  sky130_fd_sc_hd__o21ai_1 U116 ( .A1(n102), .A2(n92), .B1(n91), .Y(n125) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(load_out[15]), .Y(n94) );
  sky130_fd_sc_hd__a22oi_1 U118 ( .A1(load_in[15]), .A2(n5), .B1(load_out[16]), 
        .B2(n10), .Y(n93) );
  sky130_fd_sc_hd__o21ai_1 U119 ( .A1(n102), .A2(n94), .B1(n93), .Y(n124) );
  sky130_fd_sc_hd__inv_1 U120 ( .A(load_out[14]), .Y(n96) );
  sky130_fd_sc_hd__a22oi_1 U121 ( .A1(load_in[14]), .A2(n5), .B1(load_out[15]), 
        .B2(n10), .Y(n95) );
  sky130_fd_sc_hd__o21ai_1 U122 ( .A1(n102), .A2(n96), .B1(n95), .Y(n123) );
  sky130_fd_sc_hd__inv_1 U123 ( .A(load_out[13]), .Y(n98) );
  sky130_fd_sc_hd__a22oi_1 U124 ( .A1(load_in[13]), .A2(n5), .B1(load_out[14]), 
        .B2(n10), .Y(n97) );
  sky130_fd_sc_hd__o21ai_1 U125 ( .A1(n102), .A2(n98), .B1(n97), .Y(n122) );
  sky130_fd_sc_hd__inv_1 U126 ( .A(load_out[12]), .Y(n100) );
  sky130_fd_sc_hd__a22oi_1 U127 ( .A1(load_in[12]), .A2(n5), .B1(load_out[13]), 
        .B2(n10), .Y(n99) );
  sky130_fd_sc_hd__o21ai_1 U128 ( .A1(n100), .A2(n102), .B1(n99), .Y(n121) );
  sky130_fd_sc_hd__inv_1 U129 ( .A(load_out[11]), .Y(n103) );
  sky130_fd_sc_hd__a22oi_1 U130 ( .A1(load_in[11]), .A2(n5), .B1(load_out[12]), 
        .B2(n10), .Y(n101) );
  sky130_fd_sc_hd__o21ai_1 U131 ( .A1(n103), .A2(n102), .B1(n101), .Y(n120) );
endmodule


module Sprite_4 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n148, n149, n150, n151, n152, n153, \load_out[0] , \load_out[2] ,
         \load_out[1] , n3, n4, n5, n6, n7, n8, n9, n10, n11, n15, n16, n17,
         n18, n19, n20, n21, n22, n25, n26, n27, n28, n29, n30, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n44, n45, n46, n47, n48,
         n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62,
         n63, n64, n65, n66, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n6), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n6), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n6), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n147) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_7_ ( .D(n124), .CLK(clk), .Q(n148) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_6_ ( .D(n130), .CLK(clk), .Q(
        load_out[9]) );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_0_ ( .D(n132), .CLK(clk), .Q(load_out[19])
         );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_5_ ( .D(n129), .CLK(clk), .Q(n149) );
  sky130_fd_sc_hd__dfxbp_1 x_coord_reg_1_ ( .D(n125), .CLK(clk), .Q(n22), 
        .Q_N(n21) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n139), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n146), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n145), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n144), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n143), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n142), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n141), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_0_ ( .D(n140), .CLK(clk), .Q(load_out[11])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n131), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n138), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n137), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n136), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n135), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n134), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n133), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_2_ ( .D(n126), .CLK(clk), .Q(n152) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_4_ ( .D(n128), .CLK(clk), .Q(n150) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_3_ ( .D(n127), .CLK(clk), .Q(n151) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_0_ ( .D(n123), .CLK(clk), .Q(n153) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(n35), .Y(load_out[3]) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n44), .Y(load_out[6]) );
  sky130_fd_sc_hd__nor2_2 U5 ( .A(n152), .B(n22), .Y(n15) );
  sky130_fd_sc_hd__nor2_2 U6 ( .A(n148), .B(load_out[9]), .Y(n17) );
  sky130_fd_sc_hd__nor2_4 U7 ( .A(n150), .B(n151), .Y(n27) );
  sky130_fd_sc_hd__and4_2 U8 ( .A(n17), .B(n27), .C(n16), .D(n15), .X(n10) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(n60), .Y(n50) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n52), .Y(n53) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(ce), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(n32), .Y(n38) );
  sky130_fd_sc_hd__o21ai_1 U13 ( .A1(n25), .A2(n65), .B1(n104), .Y(n103) );
  sky130_fd_sc_hd__o21ai_1 U14 ( .A1(n25), .A2(n106), .B1(n104), .Y(n120) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(n40), .Y(n47) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(n56), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(n62), .Y(n55) );
  sky130_fd_sc_hd__and2_1 U18 ( .A(load[3]), .B(n103), .X(n3) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(load[2]), .B(n120), .X(n4) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(load[1]), .B(n49), .X(n5) );
  sky130_fd_sc_hd__and2_1 U21 ( .A(load[0]), .B(ce), .X(n6) );
  sky130_fd_sc_hd__and3_1 U22 ( .A(n21), .B(n37), .C(n35), .X(n7) );
  sky130_fd_sc_hd__and2_1 U23 ( .A(n103), .B(n65), .X(n8) );
  sky130_fd_sc_hd__and2_1 U24 ( .A(n120), .B(n106), .X(n9) );
  sky130_fd_sc_hd__and3_1 U25 ( .A(n7), .B(n46), .C(n44), .X(n11) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(load_out[19]), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(n54), .Y(load_out[8]) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(n58), .Y(load_out[10]) );
  sky130_fd_sc_hd__inv_2 U29 ( .A(n46), .Y(load_out[7]) );
  sky130_fd_sc_hd__nor2_1 U30 ( .A(n152), .B(n22), .Y(n26) );
  sky130_fd_sc_hd__nor2_1 U31 ( .A(load_out[8]), .B(n153), .Y(n16) );
  sky130_fd_sc_hd__nor2_1 U32 ( .A(n149), .B(n153), .Y(n18) );
  sky130_fd_sc_hd__nor2_1 U33 ( .A(n148), .B(load_out[9]), .Y(n28) );
  sky130_fd_sc_hd__a221o_2 U34 ( .A1(load_out[10]), .A2(n62), .B1(load_in[10]), 
        .B2(n5), .C1(n61), .X(n124) );
  sky130_fd_sc_hd__nor2_1 U35 ( .A(n149), .B(n153), .Y(n29) );
  sky130_fd_sc_hd__nor2_2 U36 ( .A(n19), .B(n122), .Y(bits[0]) );
  sky130_fd_sc_hd__nand4_1 U37 ( .A(n27), .B(n28), .C(n18), .D(n26), .Y(n20)
         );
  sky130_fd_sc_hd__inv_2 U38 ( .A(n21), .Y(load_out[4]) );
  sky130_fd_sc_hd__a221o_2 U39 ( .A1(load_out[8]), .A2(n52), .B1(load_in[8]), 
        .B2(n5), .C1(n51), .X(n129) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(n37), .Y(load_out[5]) );
  sky130_fd_sc_hd__inv_1 U41 ( .A(load[1]), .Y(n30) );
  sky130_fd_sc_hd__nand4_1 U42 ( .A(n27), .B(n15), .C(n17), .D(n29), .Y(n122)
         );
  sky130_fd_sc_hd__o22ai_1 U43 ( .A1(n25), .A2(n30), .B1(n147), .B2(n10), .Y(
        n49) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n49), .B(n30), .Y(n60) );
  sky130_fd_sc_hd__mux2i_1 U45 ( .A0(n60), .A1(n49), .S(load_out[3]), .Y(n31)
         );
  sky130_fd_sc_hd__a21o_1 U46 ( .A1(load_in[3]), .A2(n5), .B1(n31), .X(n123)
         );
  sky130_fd_sc_hd__inv_1 U47 ( .A(n153), .Y(n35) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(n50), .B(n35), .Y(n33) );
  sky130_fd_sc_hd__o21ai_1 U49 ( .A1(n60), .A2(n35), .B1(n49), .Y(n32) );
  sky130_fd_sc_hd__mux2i_1 U50 ( .A0(n33), .A1(n38), .S(load_out[4]), .Y(n34)
         );
  sky130_fd_sc_hd__a21o_1 U51 ( .A1(load_in[4]), .A2(n5), .B1(n34), .X(n125)
         );
  sky130_fd_sc_hd__inv_1 U52 ( .A(n152), .Y(n37) );
  sky130_fd_sc_hd__a21oi_1 U53 ( .A1(load_out[5]), .A2(load_out[4]), .B1(n7), 
        .Y(n39) );
  sky130_fd_sc_hd__nand2_1 U54 ( .A(load_in[5]), .B(n5), .Y(n36) );
  sky130_fd_sc_hd__o221ai_1 U55 ( .A1(n39), .A2(n60), .B1(n38), .B2(n37), .C1(
        n36), .Y(n126) );
  sky130_fd_sc_hd__nand2_1 U56 ( .A(n7), .B(n50), .Y(n41) );
  sky130_fd_sc_hd__o21ai_1 U57 ( .A1(n7), .A2(n60), .B1(n49), .Y(n40) );
  sky130_fd_sc_hd__mux2i_1 U58 ( .A0(n41), .A1(n47), .S(load_out[6]), .Y(n42)
         );
  sky130_fd_sc_hd__a21o_1 U59 ( .A1(load_in[6]), .A2(n5), .B1(n42), .X(n127)
         );
  sky130_fd_sc_hd__inv_1 U60 ( .A(n150), .Y(n46) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(n151), .Y(n44) );
  sky130_fd_sc_hd__a21oi_1 U62 ( .A1(load_out[7]), .A2(load_out[6]), .B1(n11), 
        .Y(n48) );
  sky130_fd_sc_hd__nand2_1 U63 ( .A(load_in[7]), .B(n5), .Y(n45) );
  sky130_fd_sc_hd__o221ai_1 U64 ( .A1(n48), .A2(n60), .B1(n47), .B2(n46), .C1(
        n45), .Y(n128) );
  sky130_fd_sc_hd__o21ai_1 U65 ( .A1(n11), .A2(n60), .B1(n49), .Y(n52) );
  sky130_fd_sc_hd__inv_1 U66 ( .A(n149), .Y(n54) );
  sky130_fd_sc_hd__nand3_1 U67 ( .A(n11), .B(n50), .C(n54), .Y(n56) );
  sky130_fd_sc_hd__o21ai_1 U68 ( .A1(n60), .A2(n54), .B1(n53), .Y(n62) );
  sky130_fd_sc_hd__mux2i_1 U69 ( .A0(n56), .A1(n55), .S(load_out[9]), .Y(n57)
         );
  sky130_fd_sc_hd__a21o_1 U70 ( .A1(load_in[9]), .A2(n5), .B1(n57), .X(n130)
         );
  sky130_fd_sc_hd__inv_1 U71 ( .A(load_out[9]), .Y(n59) );
  sky130_fd_sc_hd__inv_1 U72 ( .A(n148), .Y(n58) );
  sky130_fd_sc_hd__nor3_1 U73 ( .A(n60), .B(n59), .C(n58), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(load[3]), .Y(n65) );
  sky130_fd_sc_hd__inv_1 U75 ( .A(n147), .Y(n63) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(n10), .B(n63), .Y(n104) );
  sky130_fd_sc_hd__inv_1 U77 ( .A(load_out[26]), .Y(n64) );
  sky130_fd_sc_hd__o2bb2ai_1 U78 ( .B1(n103), .B2(n64), .A1_N(load_in[26]), 
        .A2_N(n3), .Y(n131) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(load_out[25]), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U80 ( .A1(load_in[25]), .A2(n3), .B1(load_out[26]), 
        .B2(n8), .Y(n66) );
  sky130_fd_sc_hd__o21ai_1 U81 ( .A1(n103), .A2(n91), .B1(n66), .Y(n138) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(load_out[24]), .Y(n93) );
  sky130_fd_sc_hd__a22oi_1 U83 ( .A1(load_in[24]), .A2(n3), .B1(load_out[25]), 
        .B2(n8), .Y(n92) );
  sky130_fd_sc_hd__o21ai_1 U84 ( .A1(n103), .A2(n93), .B1(n92), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(load_out[23]), .Y(n95) );
  sky130_fd_sc_hd__a22oi_1 U86 ( .A1(load_in[23]), .A2(n3), .B1(load_out[24]), 
        .B2(n8), .Y(n94) );
  sky130_fd_sc_hd__o21ai_1 U87 ( .A1(n103), .A2(n95), .B1(n94), .Y(n136) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(load_out[22]), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U89 ( .A1(load_in[22]), .A2(n3), .B1(load_out[23]), 
        .B2(n8), .Y(n96) );
  sky130_fd_sc_hd__o21ai_1 U90 ( .A1(n103), .A2(n97), .B1(n96), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(load_out[21]), .Y(n99) );
  sky130_fd_sc_hd__a22oi_1 U93 ( .A1(load_in[21]), .A2(n3), .B1(load_out[22]), 
        .B2(n8), .Y(n98) );
  sky130_fd_sc_hd__o21ai_1 U94 ( .A1(n103), .A2(n99), .B1(n98), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U95 ( .A(load_out[20]), .Y(n101) );
  sky130_fd_sc_hd__a22oi_1 U96 ( .A1(load_in[20]), .A2(n3), .B1(load_out[21]), 
        .B2(n8), .Y(n100) );
  sky130_fd_sc_hd__o21ai_1 U97 ( .A1(n101), .A2(n103), .B1(n100), .Y(n133) );
  sky130_fd_sc_hd__a22oi_1 U98 ( .A1(load_in[19]), .A2(n3), .B1(load_out[20]), 
        .B2(n8), .Y(n102) );
  sky130_fd_sc_hd__o21ai_1 U99 ( .A1(n19), .A2(n103), .B1(n102), .Y(n132) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(load[2]), .Y(n106) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(load_out[18]), .Y(n105) );
  sky130_fd_sc_hd__o2bb2ai_1 U102 ( .B1(n120), .B2(n105), .A1_N(load_in[18]), 
        .A2_N(n4), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U103 ( .A(load_out[17]), .Y(n108) );
  sky130_fd_sc_hd__a22oi_1 U104 ( .A1(load_in[17]), .A2(n4), .B1(load_out[18]), 
        .B2(n9), .Y(n107) );
  sky130_fd_sc_hd__o21ai_1 U105 ( .A1(n120), .A2(n108), .B1(n107), .Y(n146) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(load_out[16]), .Y(n110) );
  sky130_fd_sc_hd__a22oi_1 U107 ( .A1(load_in[16]), .A2(n4), .B1(load_out[17]), 
        .B2(n9), .Y(n109) );
  sky130_fd_sc_hd__o21ai_1 U108 ( .A1(n120), .A2(n110), .B1(n109), .Y(n145) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(load_out[15]), .Y(n112) );
  sky130_fd_sc_hd__a22oi_1 U110 ( .A1(load_in[15]), .A2(n4), .B1(load_out[16]), 
        .B2(n9), .Y(n111) );
  sky130_fd_sc_hd__o21ai_1 U111 ( .A1(n120), .A2(n112), .B1(n111), .Y(n144) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(load_out[14]), .Y(n114) );
  sky130_fd_sc_hd__a22oi_1 U113 ( .A1(load_in[14]), .A2(n4), .B1(load_out[15]), 
        .B2(n9), .Y(n113) );
  sky130_fd_sc_hd__o21ai_1 U114 ( .A1(n120), .A2(n114), .B1(n113), .Y(n143) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(load_out[13]), .Y(n116) );
  sky130_fd_sc_hd__a22oi_1 U116 ( .A1(load_in[13]), .A2(n4), .B1(load_out[14]), 
        .B2(n9), .Y(n115) );
  sky130_fd_sc_hd__o21ai_1 U117 ( .A1(n120), .A2(n116), .B1(n115), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U118 ( .A(load_out[12]), .Y(n118) );
  sky130_fd_sc_hd__a22oi_1 U119 ( .A1(load_in[12]), .A2(n4), .B1(load_out[13]), 
        .B2(n9), .Y(n117) );
  sky130_fd_sc_hd__o21ai_1 U120 ( .A1(n118), .A2(n120), .B1(n117), .Y(n141) );
  sky130_fd_sc_hd__inv_1 U121 ( .A(load_out[11]), .Y(n121) );
  sky130_fd_sc_hd__a22oi_1 U122 ( .A1(load_in[11]), .A2(n4), .B1(load_out[12]), 
        .B2(n9), .Y(n119) );
  sky130_fd_sc_hd__o21ai_1 U123 ( .A1(n121), .A2(n120), .B1(n119), .Y(n140) );
  sky130_fd_sc_hd__nor2_1 U124 ( .A(n20), .B(n121), .Y(bits[1]) );
endmodule


module Sprite_3 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n145, n146, n147, n148, n149, n150, \load_out[0] , \load_out[2] ,
         \load_out[1] , n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n12, n13, n19,
         n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n44, n45, n46, n47, n48,
         n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62,
         n63, n64, n65, n66, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n4), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n4), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n4), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n144) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_1_ ( .D(n122), .CLK(clk), .Q(
        load_out[4]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_6_ ( .D(n127), .CLK(clk), .Q(
        load_out[9]) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_5_ ( .D(n126), .CLK(clk), .Q(n146) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_4_ ( .D(n125), .CLK(clk), .Q(n147) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_7_ ( .D(n121), .CLK(clk), .Q(n145) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_0_ ( .D(n120), .CLK(clk), .Q(n150) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_3_ ( .D(n124), .CLK(clk), .Q(n148) );
  sky130_fd_sc_hd__dfxbp_1 pix1_reg_0_ ( .D(n129), .CLK(clk), .Q(load_out[19]), 
        .Q_N(n100) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_2_ ( .D(n123), .CLK(clk), .Q(n149) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n136), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n143), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n142), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n141), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n140), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n139), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n138), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_0_ ( .D(n137), .CLK(clk), .Q(load_out[11])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n128), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n135), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n134), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n133), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n132), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n131), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n130), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__a21o_2 U3 ( .A1(load_in[3]), .A2(n3), .B1(n25), .X(n120) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n55), .Y(n45) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n57), .Y(n50) );
  sky130_fd_sc_hd__nor2_2 U6 ( .A(n149), .B(load_out[4]), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(ce), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(n35), .Y(n41) );
  sky130_fd_sc_hd__o21ai_1 U9 ( .A1(n19), .A2(n61), .B1(n101), .Y(n99) );
  sky130_fd_sc_hd__o21ai_1 U10 ( .A1(n19), .A2(n103), .B1(n101), .Y(n117) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(n47), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(n26), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n51), .Y(n46) );
  sky130_fd_sc_hd__and2_1 U14 ( .A(load[3]), .B(n99), .X(n1) );
  sky130_fd_sc_hd__and2_1 U15 ( .A(load[2]), .B(n117), .X(n2) );
  sky130_fd_sc_hd__and2_1 U16 ( .A(load[1]), .B(n44), .X(n3) );
  sky130_fd_sc_hd__and2_1 U17 ( .A(load[0]), .B(ce), .X(n4) );
  sky130_fd_sc_hd__and2_1 U18 ( .A(n99), .B(n61), .X(n5) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(n117), .B(n103), .X(n6) );
  sky130_fd_sc_hd__and3_1 U20 ( .A(n30), .B(n32), .C(n29), .X(n7) );
  sky130_fd_sc_hd__and3_1 U21 ( .A(n7), .B(n40), .C(n38), .X(n8) );
  sky130_fd_sc_hd__nor2_1 U22 ( .A(n146), .B(n150), .Y(n9) );
  sky130_fd_sc_hd__nor2_1 U23 ( .A(n146), .B(n150), .Y(n23) );
  sky130_fd_sc_hd__dlygate4sd3_1 U24 ( .A(n13), .X(n10) );
  sky130_fd_sc_hd__dlygate4sd1_1 U25 ( .A(n149), .X(load_out[5]) );
  sky130_fd_sc_hd__nor2_1 U26 ( .A(n147), .B(n148), .Y(n12) );
  sky130_fd_sc_hd__nor2_1 U27 ( .A(n147), .B(n148), .Y(n21) );
  sky130_fd_sc_hd__a221o_2 U28 ( .A1(load_out[10]), .A2(n57), .B1(load_in[10]), 
        .B2(n3), .C1(n56), .X(n121) );
  sky130_fd_sc_hd__nand4_1 U29 ( .A(n20), .B(n22), .C(n21), .D(n9), .Y(n13) );
  sky130_fd_sc_hd__nand4_1 U30 ( .A(n20), .B(n22), .C(n12), .D(n23), .Y(n119)
         );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n10), .Y(n59) );
  sky130_fd_sc_hd__o21ai_0 U32 ( .A1(n55), .A2(n49), .B1(n48), .Y(n57) );
  sky130_fd_sc_hd__dlygate4sd3_1 U33 ( .A(n146), .X(load_out[8]) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(n38), .Y(load_out[6]) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(n29), .Y(load_out[3]) );
  sky130_fd_sc_hd__inv_2 U36 ( .A(n53), .Y(load_out[10]) );
  sky130_fd_sc_hd__inv_2 U37 ( .A(n40), .Y(load_out[7]) );
  sky130_fd_sc_hd__a221o_2 U38 ( .A1(load_out[8]), .A2(n47), .B1(load_in[8]), 
        .B2(n3), .C1(n46), .X(n126) );
  sky130_fd_sc_hd__a21o_2 U39 ( .A1(load_in[6]), .A2(n3), .B1(n37), .X(n124)
         );
  sky130_fd_sc_hd__inv_1 U40 ( .A(load[1]), .Y(n24) );
  sky130_fd_sc_hd__nor2_2 U41 ( .A(n145), .B(load_out[9]), .Y(n22) );
  sky130_fd_sc_hd__o22ai_1 U42 ( .A1(n19), .A2(n24), .B1(n144), .B2(n59), .Y(
        n44) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(n44), .B(n24), .Y(n55) );
  sky130_fd_sc_hd__mux2i_1 U44 ( .A0(n55), .A1(n44), .S(load_out[3]), .Y(n25)
         );
  sky130_fd_sc_hd__inv_1 U45 ( .A(n150), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U46 ( .A(n45), .B(n29), .Y(n27) );
  sky130_fd_sc_hd__o21ai_1 U47 ( .A1(n55), .A2(n29), .B1(n44), .Y(n26) );
  sky130_fd_sc_hd__mux2i_1 U48 ( .A0(n27), .A1(n33), .S(load_out[4]), .Y(n28)
         );
  sky130_fd_sc_hd__a21o_1 U49 ( .A1(load_in[4]), .A2(n3), .B1(n28), .X(n122)
         );
  sky130_fd_sc_hd__inv_1 U50 ( .A(load_out[4]), .Y(n30) );
  sky130_fd_sc_hd__inv_1 U51 ( .A(load_out[5]), .Y(n32) );
  sky130_fd_sc_hd__a21oi_1 U52 ( .A1(load_out[5]), .A2(load_out[4]), .B1(n7), 
        .Y(n34) );
  sky130_fd_sc_hd__nand2_1 U53 ( .A(load_in[5]), .B(n3), .Y(n31) );
  sky130_fd_sc_hd__o221ai_1 U54 ( .A1(n34), .A2(n55), .B1(n33), .B2(n32), .C1(
        n31), .Y(n123) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(n7), .B(n45), .Y(n36) );
  sky130_fd_sc_hd__o21ai_1 U56 ( .A1(n7), .A2(n55), .B1(n44), .Y(n35) );
  sky130_fd_sc_hd__mux2i_1 U57 ( .A0(n36), .A1(n41), .S(load_out[6]), .Y(n37)
         );
  sky130_fd_sc_hd__inv_1 U58 ( .A(n147), .Y(n40) );
  sky130_fd_sc_hd__inv_1 U59 ( .A(n148), .Y(n38) );
  sky130_fd_sc_hd__a21oi_1 U60 ( .A1(load_out[7]), .A2(load_out[6]), .B1(n8), 
        .Y(n42) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(load_in[7]), .B(n3), .Y(n39) );
  sky130_fd_sc_hd__o221ai_1 U62 ( .A1(n42), .A2(n55), .B1(n41), .B2(n40), .C1(
        n39), .Y(n125) );
  sky130_fd_sc_hd__o21ai_1 U63 ( .A1(n8), .A2(n55), .B1(n44), .Y(n47) );
  sky130_fd_sc_hd__inv_1 U64 ( .A(load_out[8]), .Y(n49) );
  sky130_fd_sc_hd__nand3_1 U65 ( .A(n8), .B(n45), .C(n49), .Y(n51) );
  sky130_fd_sc_hd__mux2i_1 U66 ( .A0(n51), .A1(n50), .S(load_out[9]), .Y(n52)
         );
  sky130_fd_sc_hd__a21o_1 U67 ( .A1(load_in[9]), .A2(n3), .B1(n52), .X(n127)
         );
  sky130_fd_sc_hd__inv_1 U68 ( .A(load_out[9]), .Y(n54) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(n145), .Y(n53) );
  sky130_fd_sc_hd__nor3_1 U70 ( .A(n55), .B(n54), .C(n53), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U71 ( .A(load[3]), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U72 ( .A(n144), .Y(n58) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(n59), .B(n58), .Y(n101) );
  sky130_fd_sc_hd__inv_1 U74 ( .A(load_out[26]), .Y(n60) );
  sky130_fd_sc_hd__o2bb2ai_1 U75 ( .B1(n99), .B2(n60), .A1_N(load_in[26]), 
        .A2_N(n1), .Y(n128) );
  sky130_fd_sc_hd__inv_1 U76 ( .A(load_out[25]), .Y(n63) );
  sky130_fd_sc_hd__a22oi_1 U77 ( .A1(load_in[25]), .A2(n1), .B1(load_out[26]), 
        .B2(n5), .Y(n62) );
  sky130_fd_sc_hd__o21ai_1 U78 ( .A1(n99), .A2(n63), .B1(n62), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(load_out[24]), .Y(n65) );
  sky130_fd_sc_hd__a22oi_1 U80 ( .A1(load_in[24]), .A2(n1), .B1(load_out[25]), 
        .B2(n5), .Y(n64) );
  sky130_fd_sc_hd__o21ai_1 U81 ( .A1(n99), .A2(n65), .B1(n64), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(load_out[23]), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U83 ( .A1(load_in[23]), .A2(n1), .B1(load_out[24]), 
        .B2(n5), .Y(n66) );
  sky130_fd_sc_hd__o21ai_1 U84 ( .A1(n99), .A2(n91), .B1(n66), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(load_out[22]), .Y(n93) );
  sky130_fd_sc_hd__a22oi_1 U86 ( .A1(load_in[22]), .A2(n1), .B1(load_out[23]), 
        .B2(n5), .Y(n92) );
  sky130_fd_sc_hd__o21ai_1 U87 ( .A1(n99), .A2(n93), .B1(n92), .Y(n132) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(load_out[21]), .Y(n95) );
  sky130_fd_sc_hd__a22oi_1 U89 ( .A1(load_in[21]), .A2(n1), .B1(load_out[22]), 
        .B2(n5), .Y(n94) );
  sky130_fd_sc_hd__o21ai_1 U90 ( .A1(n99), .A2(n95), .B1(n94), .Y(n131) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(load_out[20]), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U93 ( .A1(load_in[20]), .A2(n1), .B1(load_out[21]), 
        .B2(n5), .Y(n96) );
  sky130_fd_sc_hd__o21ai_1 U94 ( .A1(n97), .A2(n99), .B1(n96), .Y(n130) );
  sky130_fd_sc_hd__a22oi_1 U95 ( .A1(load_in[19]), .A2(n1), .B1(load_out[20]), 
        .B2(n5), .Y(n98) );
  sky130_fd_sc_hd__o21ai_1 U96 ( .A1(n100), .A2(n99), .B1(n98), .Y(n129) );
  sky130_fd_sc_hd__nor2_1 U97 ( .A(n119), .B(n100), .Y(bits[0]) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(load[2]), .Y(n103) );
  sky130_fd_sc_hd__inv_1 U99 ( .A(load_out[18]), .Y(n102) );
  sky130_fd_sc_hd__o2bb2ai_1 U100 ( .B1(n117), .B2(n102), .A1_N(load_in[18]), 
        .A2_N(n2), .Y(n136) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(load_out[17]), .Y(n105) );
  sky130_fd_sc_hd__a22oi_1 U102 ( .A1(load_in[17]), .A2(n2), .B1(load_out[18]), 
        .B2(n6), .Y(n104) );
  sky130_fd_sc_hd__o21ai_1 U103 ( .A1(n117), .A2(n105), .B1(n104), .Y(n143) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(load_out[16]), .Y(n107) );
  sky130_fd_sc_hd__a22oi_1 U105 ( .A1(load_in[16]), .A2(n2), .B1(load_out[17]), 
        .B2(n6), .Y(n106) );
  sky130_fd_sc_hd__o21ai_1 U106 ( .A1(n117), .A2(n107), .B1(n106), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(load_out[15]), .Y(n109) );
  sky130_fd_sc_hd__a22oi_1 U108 ( .A1(load_in[15]), .A2(n2), .B1(load_out[16]), 
        .B2(n6), .Y(n108) );
  sky130_fd_sc_hd__o21ai_1 U109 ( .A1(n117), .A2(n109), .B1(n108), .Y(n141) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(load_out[14]), .Y(n111) );
  sky130_fd_sc_hd__a22oi_1 U111 ( .A1(load_in[14]), .A2(n2), .B1(load_out[15]), 
        .B2(n6), .Y(n110) );
  sky130_fd_sc_hd__o21ai_1 U112 ( .A1(n117), .A2(n111), .B1(n110), .Y(n140) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(load_out[13]), .Y(n113) );
  sky130_fd_sc_hd__a22oi_1 U114 ( .A1(load_in[13]), .A2(n2), .B1(load_out[14]), 
        .B2(n6), .Y(n112) );
  sky130_fd_sc_hd__o21ai_1 U115 ( .A1(n117), .A2(n113), .B1(n112), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(load_out[12]), .Y(n115) );
  sky130_fd_sc_hd__a22oi_1 U117 ( .A1(load_in[12]), .A2(n2), .B1(load_out[13]), 
        .B2(n6), .Y(n114) );
  sky130_fd_sc_hd__o21ai_1 U118 ( .A1(n115), .A2(n117), .B1(n114), .Y(n138) );
  sky130_fd_sc_hd__inv_1 U119 ( .A(load_out[11]), .Y(n118) );
  sky130_fd_sc_hd__a22oi_1 U120 ( .A1(load_in[11]), .A2(n2), .B1(load_out[12]), 
        .B2(n6), .Y(n116) );
  sky130_fd_sc_hd__o21ai_1 U121 ( .A1(n118), .A2(n117), .B1(n116), .Y(n137) );
  sky130_fd_sc_hd__nor2_1 U122 ( .A(n118), .B(n13), .Y(bits[1]) );
endmodule


module Sprite_2 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n129, n131, n132, n134, n130, n133, \load_out[0] , \load_out[2] ,
         \load_out[1] , n81, net51895, net51896, net51917, net51919, net51920,
         net51924, net51925, net51927, net51928, net51929, net51948, net51949,
         net51957, net51958, net59054, net59062, net59100, net59356, net59459,
         net59592, net59597, net61579, net61586, net61932, net61926, net61902,
         net61898, net61891, net63314, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
         n12, n13, n14, n15, n16, n17, n18, n20, n21, n22, n23, n24, n25, n26,
         n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40,
         n41, n42, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55,
         n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n91, n92, n93,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;
  assign load_out[6] = net59054;
  assign load_out[9] = net59100;
  assign load_out[3] = net59459;
  assign load_out[7] = net61579;
  assign load_out[10] = net63314;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n5), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n5), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n5), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n128) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_2_ ( .D(n108), .CLK(clk), .Q(
        load_out[5]) );
  sky130_fd_sc_hd__dfxtp_2 pix1_reg_0_ ( .D(n81), .CLK(clk), .Q(load_out[19])
         );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_1_ ( .D(n107), .CLK(clk), .Q(n133) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_3_ ( .D(n109), .CLK(clk), .Q(n132) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_4_ ( .D(n110), .CLK(clk), .Q(n131) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_6_ ( .D(n112), .CLK(clk), .Q(n129) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_0_ ( .D(n105), .CLK(clk), .Q(n134) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_7_ ( .D(n106), .CLK(clk), .Q(net59597)
         );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_5_ ( .D(n111), .CLK(clk), .Q(n130) );
  sky130_fd_sc_hd__dfxbp_1 pix2_reg_0_ ( .D(n121), .CLK(clk), .Q(load_out[11]), 
        .Q_N(n104) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n120), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n127), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n126), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n125), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n124), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n123), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n122), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n113), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n119), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n118), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n117), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n116), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n115), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n114), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__o21ai_0 U3 ( .A1(net51895), .A2(net61891), .B1(net51896), 
        .Y(n81) );
  sky130_fd_sc_hd__a21o_2 U4 ( .A1(load_in[9]), .A2(n1), .B1(n47), .X(n112) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(net51928), .Y(net51927) );
  sky130_fd_sc_hd__nand3_1 U6 ( .A(n2), .B(net61898), .C(net61932), .Y(
        net51924) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(ce), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(n39), .Y(n44) );
  sky130_fd_sc_hd__o21ai_1 U9 ( .A1(n30), .A2(n50), .B1(n63), .Y(net51895) );
  sky130_fd_sc_hd__o21ai_1 U10 ( .A1(n30), .A2(n65), .B1(n63), .Y(n103) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(n33), .Y(n37) );
  sky130_fd_sc_hd__a221o_1 U12 ( .A1(load_out[8]), .A2(net51928), .B1(
        load_in[8]), .B2(n1), .C1(net51929), .X(n111) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(net51924), .Y(net51929) );
  sky130_fd_sc_hd__nor2_1 U14 ( .A(net51920), .B(n22), .Y(net51919) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(net51917), .Y(net51925) );
  sky130_fd_sc_hd__and2_1 U16 ( .A(load[1]), .B(n46), .X(n1) );
  sky130_fd_sc_hd__and3_1 U17 ( .A(n6), .B(net59062), .C(net61586), .X(n2) );
  sky130_fd_sc_hd__and2_1 U18 ( .A(load[2]), .B(n103), .X(n3) );
  sky130_fd_sc_hd__and2_1 U19 ( .A(load[3]), .B(net51895), .X(n4) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(load[0]), .B(ce), .X(n5) );
  sky130_fd_sc_hd__and2_1 U21 ( .A(net51948), .B(net51949), .X(n6) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(net51920), .Y(net61932) );
  sky130_fd_sc_hd__and3_1 U23 ( .A(net51957), .B(net51948), .C(net51958), .X(
        n7) );
  sky130_fd_sc_hd__and2_1 U24 ( .A(n103), .B(n65), .X(n8) );
  sky130_fd_sc_hd__and2_1 U25 ( .A(net51895), .B(n50), .X(n9) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(n23), .Y(net51957) );
  sky130_fd_sc_hd__nand4_1 U27 ( .A(net51958), .B(load_out[11]), .C(net51957), 
        .D(net51948), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(n10), .Y(bits[1]) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(n17), .Y(net51958) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(n26), .Y(load_out[4]) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n28), .Y(bits[0]) );
  sky130_fd_sc_hd__nor2_1 U32 ( .A(n129), .B(net61891), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U33 ( .A(load_out[19]), .Y(net61891) );
  sky130_fd_sc_hd__nand2_1 U34 ( .A(load_out[8]), .B(net61932), .Y(net61902)
         );
  sky130_fd_sc_hd__nand2_1 U35 ( .A(n14), .B(n15), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U36 ( .A(net59597), .B(n129), .Y(n15) );
  sky130_fd_sc_hd__inv_1 U37 ( .A(net59597), .Y(n16) );
  sky130_fd_sc_hd__inv_1 U38 ( .A(n16), .Y(net63314) );
  sky130_fd_sc_hd__dlygate4sd3_1 U39 ( .A(n129), .X(net59100) );
  sky130_fd_sc_hd__nor2_1 U40 ( .A(n130), .B(n134), .Y(n14) );
  sky130_fd_sc_hd__nor2_1 U41 ( .A(n134), .B(n130), .Y(n12) );
  sky130_fd_sc_hd__nand3_1 U42 ( .A(n13), .B(n16), .C(n12), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U43 ( .A(n18), .Y(net61926) );
  sky130_fd_sc_hd__clkinv_1 U44 ( .A(load_out[8]), .Y(net61898) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(n134), .Y(net51949) );
  sky130_fd_sc_hd__dlygate4sd3_1 U46 ( .A(n130), .X(load_out[8]) );
  sky130_fd_sc_hd__dlygate4sd1_1 U47 ( .A(net59356), .X(n20) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(net59356), .B(n26), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(net51927), .B(net61902), .Y(net51917) );
  sky130_fd_sc_hd__nand2_1 U50 ( .A(net63314), .B(net59100), .Y(n22) );
  sky130_fd_sc_hd__nand2_1 U51 ( .A(net61926), .B(n27), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U52 ( .A(n29), .B(n21), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n133), .Y(n26) );
  sky130_fd_sc_hd__nand2_2 U54 ( .A(net59356), .B(n26), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U55 ( .A(n132), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U56 ( .A(n24), .Y(net59054) );
  sky130_fd_sc_hd__inv_2 U57 ( .A(load_out[5]), .Y(net59356) );
  sky130_fd_sc_hd__inv_1 U58 ( .A(n20), .Y(net59592) );
  sky130_fd_sc_hd__inv_2 U59 ( .A(net51949), .Y(net59459) );
  sky130_fd_sc_hd__nand2b_1 U60 ( .A_N(n131), .B(n24), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(n131), .Y(net59062) );
  sky130_fd_sc_hd__inv_2 U62 ( .A(n25), .Y(net51948) );
  sky130_fd_sc_hd__nand2b_1 U63 ( .A_N(n131), .B(n24), .Y(n29) );
  sky130_fd_sc_hd__inv_2 U64 ( .A(net59054), .Y(net61586) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(net59062), .Y(net61579) );
  sky130_fd_sc_hd__o21ai_0 U66 ( .A1(net51920), .A2(net51949), .B1(n46), .Y(
        n33) );
  sky130_fd_sc_hd__inv_1 U67 ( .A(load[1]), .Y(n31) );
  sky130_fd_sc_hd__o22ai_1 U68 ( .A1(n30), .A2(n31), .B1(n128), .B2(n7), .Y(
        n46) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n46), .B(n31), .Y(net51920) );
  sky130_fd_sc_hd__mux2i_1 U70 ( .A0(net51920), .A1(n46), .S(net59459), .Y(n32) );
  sky130_fd_sc_hd__a21o_1 U71 ( .A1(load_in[3]), .A2(n1), .B1(n32), .X(n105)
         );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(net61932), .B(net51949), .Y(n34) );
  sky130_fd_sc_hd__mux2i_1 U73 ( .A0(n34), .A1(n37), .S(load_out[4]), .Y(n35)
         );
  sky130_fd_sc_hd__a21o_1 U74 ( .A1(load_in[4]), .A2(n1), .B1(n35), .X(n107)
         );
  sky130_fd_sc_hd__a21oi_1 U75 ( .A1(net59592), .A2(load_out[4]), .B1(n6), .Y(
        n38) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(load_in[5]), .B(n1), .Y(n36) );
  sky130_fd_sc_hd__o221ai_1 U77 ( .A1(n38), .A2(net51920), .B1(n37), .B2(n20), 
        .C1(n36), .Y(n108) );
  sky130_fd_sc_hd__nand2_1 U78 ( .A(n6), .B(net61932), .Y(n40) );
  sky130_fd_sc_hd__o21ai_1 U79 ( .A1(n6), .A2(net51920), .B1(n46), .Y(n39) );
  sky130_fd_sc_hd__mux2i_1 U80 ( .A0(n40), .A1(n44), .S(net59054), .Y(n41) );
  sky130_fd_sc_hd__a21o_1 U81 ( .A1(load_in[6]), .A2(n1), .B1(n41), .X(n109)
         );
  sky130_fd_sc_hd__a21oi_1 U82 ( .A1(net61579), .A2(net59054), .B1(n2), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(load_in[7]), .B(n1), .Y(n42) );
  sky130_fd_sc_hd__o221ai_1 U84 ( .A1(n45), .A2(net51920), .B1(n44), .B2(
        net59062), .C1(n42), .Y(n110) );
  sky130_fd_sc_hd__o21ai_1 U85 ( .A1(n2), .A2(net51920), .B1(n46), .Y(net51928) );
  sky130_fd_sc_hd__mux2i_1 U86 ( .A0(net51924), .A1(net51925), .S(net59100), 
        .Y(n47) );
  sky130_fd_sc_hd__a221o_1 U87 ( .A1(net63314), .A2(net51917), .B1(load_in[10]), .B2(n1), .C1(net51919), .X(n106) );
  sky130_fd_sc_hd__inv_1 U88 ( .A(load[3]), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U89 ( .A(n128), .Y(n48) );
  sky130_fd_sc_hd__nand2_1 U90 ( .A(n7), .B(n48), .Y(n63) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(load_out[26]), .Y(n49) );
  sky130_fd_sc_hd__o2bb2ai_1 U93 ( .B1(net51895), .B2(n49), .A1_N(load_in[26]), 
        .A2_N(n4), .Y(n113) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(load_out[25]), .Y(n52) );
  sky130_fd_sc_hd__a22oi_1 U95 ( .A1(load_in[25]), .A2(n4), .B1(load_out[26]), 
        .B2(n9), .Y(n51) );
  sky130_fd_sc_hd__o21ai_1 U96 ( .A1(net51895), .A2(n52), .B1(n51), .Y(n119)
         );
  sky130_fd_sc_hd__inv_1 U97 ( .A(load_out[24]), .Y(n54) );
  sky130_fd_sc_hd__a22oi_1 U98 ( .A1(load_in[24]), .A2(n4), .B1(load_out[25]), 
        .B2(n9), .Y(n53) );
  sky130_fd_sc_hd__o21ai_1 U99 ( .A1(net51895), .A2(n54), .B1(n53), .Y(n118)
         );
  sky130_fd_sc_hd__inv_1 U100 ( .A(load_out[23]), .Y(n56) );
  sky130_fd_sc_hd__a22oi_1 U101 ( .A1(load_in[23]), .A2(n4), .B1(load_out[24]), 
        .B2(n9), .Y(n55) );
  sky130_fd_sc_hd__o21ai_1 U102 ( .A1(net51895), .A2(n56), .B1(n55), .Y(n117)
         );
  sky130_fd_sc_hd__inv_1 U103 ( .A(load_out[22]), .Y(n58) );
  sky130_fd_sc_hd__a22oi_1 U104 ( .A1(load_in[22]), .A2(n4), .B1(load_out[23]), 
        .B2(n9), .Y(n57) );
  sky130_fd_sc_hd__o21ai_1 U105 ( .A1(net51895), .A2(n58), .B1(n57), .Y(n116)
         );
  sky130_fd_sc_hd__inv_1 U106 ( .A(load_out[21]), .Y(n60) );
  sky130_fd_sc_hd__a22oi_1 U107 ( .A1(load_in[21]), .A2(n4), .B1(load_out[22]), 
        .B2(n9), .Y(n59) );
  sky130_fd_sc_hd__o21ai_1 U108 ( .A1(net51895), .A2(n60), .B1(n59), .Y(n115)
         );
  sky130_fd_sc_hd__inv_1 U109 ( .A(load_out[20]), .Y(n62) );
  sky130_fd_sc_hd__a22oi_1 U110 ( .A1(load_in[20]), .A2(n4), .B1(load_out[21]), 
        .B2(n9), .Y(n61) );
  sky130_fd_sc_hd__o21ai_1 U111 ( .A1(n62), .A2(net51895), .B1(n61), .Y(n114)
         );
  sky130_fd_sc_hd__a22oi_1 U112 ( .A1(load_in[19]), .A2(n4), .B1(load_out[20]), 
        .B2(n9), .Y(net51896) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(load[2]), .Y(n65) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(load_out[18]), .Y(n64) );
  sky130_fd_sc_hd__o2bb2ai_1 U115 ( .B1(n103), .B2(n64), .A1_N(load_in[18]), 
        .A2_N(n3), .Y(n120) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(load_out[17]), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U117 ( .A1(load_in[17]), .A2(n3), .B1(load_out[18]), 
        .B2(n8), .Y(n66) );
  sky130_fd_sc_hd__o21ai_1 U118 ( .A1(n103), .A2(n91), .B1(n66), .Y(n127) );
  sky130_fd_sc_hd__inv_1 U119 ( .A(load_out[16]), .Y(n93) );
  sky130_fd_sc_hd__a22oi_1 U120 ( .A1(load_in[16]), .A2(n3), .B1(load_out[17]), 
        .B2(n8), .Y(n92) );
  sky130_fd_sc_hd__o21ai_1 U121 ( .A1(n103), .A2(n93), .B1(n92), .Y(n126) );
  sky130_fd_sc_hd__inv_1 U122 ( .A(load_out[15]), .Y(n95) );
  sky130_fd_sc_hd__a22oi_1 U123 ( .A1(load_in[15]), .A2(n3), .B1(load_out[16]), 
        .B2(n8), .Y(n94) );
  sky130_fd_sc_hd__o21ai_1 U124 ( .A1(n103), .A2(n95), .B1(n94), .Y(n125) );
  sky130_fd_sc_hd__inv_1 U125 ( .A(load_out[14]), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U126 ( .A1(load_in[14]), .A2(n3), .B1(load_out[15]), 
        .B2(n8), .Y(n96) );
  sky130_fd_sc_hd__o21ai_1 U127 ( .A1(n103), .A2(n97), .B1(n96), .Y(n124) );
  sky130_fd_sc_hd__inv_1 U128 ( .A(load_out[13]), .Y(n99) );
  sky130_fd_sc_hd__a22oi_1 U129 ( .A1(load_in[13]), .A2(n3), .B1(load_out[14]), 
        .B2(n8), .Y(n98) );
  sky130_fd_sc_hd__o21ai_1 U130 ( .A1(n103), .A2(n99), .B1(n98), .Y(n123) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(load_out[12]), .Y(n101) );
  sky130_fd_sc_hd__a22oi_1 U132 ( .A1(load_in[12]), .A2(n3), .B1(load_out[13]), 
        .B2(n8), .Y(n100) );
  sky130_fd_sc_hd__o21ai_1 U133 ( .A1(n101), .A2(n103), .B1(n100), .Y(n122) );
  sky130_fd_sc_hd__a22oi_1 U134 ( .A1(load_in[11]), .A2(n3), .B1(load_out[12]), 
        .B2(n8), .Y(n102) );
  sky130_fd_sc_hd__o21ai_1 U135 ( .A1(n104), .A2(n103), .B1(n102), .Y(n121) );
endmodule


module Sprite_1 ( clk, ce, enable, load, load_in, load_out, bits );
  input [3:0] load;
  input [26:0] load_in;
  output [26:0] load_out;
  output [4:0] bits;
  input clk, ce, enable;
  wire   n127, n128, \load_out[0] , \load_out[2] , \load_out[1] , n81, n85,
         n87, net51777, net51803, net51804, net51828, net51839, net51842,
         net51844, net51850, net51852, net51854, net51858, net51859, net51860,
         net56129, net56133, net56142, net56145, net56160, net59006, net59015,
         net59049, net59384, net59590, net59752, n1, n2, n3, n4, n5, n6, n7,
         n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21,
         n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35,
         n36, n37, n38, n39, n40, n41, n42, n44, n45, n46, n47, n48, n49, n50,
         n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101,
         n102, n103, n104, n105, n106, n107, n108, n109, n110, n111, n112,
         n113, n114, n115, n116, n117, n118, n119, n120, n121, n122, n123,
         n124, n125, n126;
  assign bits[4] = \load_out[0] ;
  assign load_out[0] = \load_out[0] ;
  assign bits[3] = \load_out[2] ;
  assign load_out[2] = \load_out[2] ;
  assign bits[2] = \load_out[1] ;
  assign load_out[1] = \load_out[1] ;
  assign load_out[10] = net56133;
  assign load_out[3] = net59049;
  assign load_out[8] = net59384;
  assign load_out[6] = net59590;
  assign load_out[9] = net59752;

  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_1_ ( .D(load_in[2]), .DE(n6), 
        .CLK(clk), .Q(\load_out[2] ) );
  sky130_fd_sc_hd__edfxtp_1 upper_color_reg_0_ ( .D(load_in[1]), .DE(n6), 
        .CLK(clk), .Q(\load_out[1] ) );
  sky130_fd_sc_hd__edfxtp_1 aprio_reg ( .D(load_in[0]), .DE(n6), .CLK(clk), 
        .Q(\load_out[0] ) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(enable), .B(ce), .Y(n126) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_1_ ( .D(n107), .CLK(clk), .Q(
        load_out[4]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_4_ ( .D(n85), .CLK(clk), .Q(load_out[7]) );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_5_ ( .D(n109), .CLK(clk), .Q(net59384)
         );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_0_ ( .D(n105), .CLK(clk), .Q(net59049)
         );
  sky130_fd_sc_hd__dfxtp_1 x_coord_reg_6_ ( .D(n110), .CLK(clk), .Q(net59752)
         );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_3_ ( .D(n108), .CLK(clk), .Q(n128) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_2_ ( .D(n87), .CLK(clk), .Q(load_out[5]) );
  sky130_fd_sc_hd__dfxtp_2 x_coord_reg_7_ ( .D(n106), .CLK(clk), .Q(n127) );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_7_ ( .D(n118), .CLK(clk), .Q(load_out[18])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_6_ ( .D(n125), .CLK(clk), .Q(load_out[17])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_5_ ( .D(n124), .CLK(clk), .Q(load_out[16])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_4_ ( .D(n123), .CLK(clk), .Q(load_out[15])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_3_ ( .D(n122), .CLK(clk), .Q(load_out[14])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_2_ ( .D(n121), .CLK(clk), .Q(load_out[13])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_1_ ( .D(n120), .CLK(clk), .Q(load_out[12])
         );
  sky130_fd_sc_hd__dfxtp_1 pix2_reg_0_ ( .D(n119), .CLK(clk), .Q(load_out[11])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_7_ ( .D(n111), .CLK(clk), .Q(load_out[26])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_6_ ( .D(n117), .CLK(clk), .Q(load_out[25])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_5_ ( .D(n116), .CLK(clk), .Q(load_out[24])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_4_ ( .D(n115), .CLK(clk), .Q(load_out[23])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_3_ ( .D(n114), .CLK(clk), .Q(load_out[22])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_2_ ( .D(n113), .CLK(clk), .Q(load_out[21])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_1_ ( .D(n112), .CLK(clk), .Q(load_out[20])
         );
  sky130_fd_sc_hd__dfxtp_1 pix1_reg_0_ ( .D(n81), .CLK(clk), .Q(load_out[19])
         );
  sky130_fd_sc_hd__nor2_1 U3 ( .A(net51777), .B(net59752), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n41), .Y(n42) );
  sky130_fd_sc_hd__o21ai_1 U5 ( .A1(n34), .A2(n51), .B1(n64), .Y(net51803) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(net51828), .Y(net51839) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(ce), .Y(n34) );
  sky130_fd_sc_hd__o21ai_1 U8 ( .A1(n34), .A2(n66), .B1(n64), .Y(n104) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(n48), .Y(n44) );
  sky130_fd_sc_hd__a21o_1 U10 ( .A1(load_in[3]), .A2(n2), .B1(n36), .X(n105)
         );
  sky130_fd_sc_hd__inv_2 U11 ( .A(n45), .Y(n40) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(load_out[19]), .Y(n20) );
  sky130_fd_sc_hd__o211ai_1 U13 ( .A1(net51828), .A2(n14), .B1(net51844), .C1(
        n15), .Y(n85) );
  sky130_fd_sc_hd__and2_1 U14 ( .A(n24), .B(n13), .X(n1) );
  sky130_fd_sc_hd__and2_1 U15 ( .A(load[1]), .B(n39), .X(n2) );
  sky130_fd_sc_hd__and2_1 U16 ( .A(load[2]), .B(n104), .X(n3) );
  sky130_fd_sc_hd__and2_1 U17 ( .A(load[3]), .B(net51803), .X(n4) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(net51850), .Y(net51842) );
  sky130_fd_sc_hd__o21ai_0 U19 ( .A1(n11), .A2(net51828), .B1(n39), .Y(
        net51850) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(n25), .B(n26), .X(n5) );
  sky130_fd_sc_hd__and2_1 U21 ( .A(load[0]), .B(ce), .X(n6) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(net51860), .Y(net51852) );
  sky130_fd_sc_hd__and4_1 U23 ( .A(net59006), .B(n21), .C(net59015), .D(
        net56142), .X(n7) );
  sky130_fd_sc_hd__and3_1 U24 ( .A(n5), .B(n1), .C(n7), .X(n8) );
  sky130_fd_sc_hd__and2_1 U25 ( .A(n104), .B(n66), .X(n9) );
  sky130_fd_sc_hd__and2_1 U26 ( .A(net51803), .B(n51), .X(n10) );
  sky130_fd_sc_hd__and2_1 U27 ( .A(net59006), .B(n1), .X(n11) );
  sky130_fd_sc_hd__and2_1 U28 ( .A(n11), .B(n5), .X(n12) );
  sky130_fd_sc_hd__clkbuf_1 U29 ( .A(n127), .X(net56133) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(net56133), .Y(n21) );
  sky130_fd_sc_hd__nor2_1 U31 ( .A(n127), .B(net59384), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U32 ( .A(n127), .B(net59384), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(load_out[7]), .Y(n26) );
  sky130_fd_sc_hd__nand4b_1 U34 ( .A_N(net59752), .B(n25), .C(n33), .D(
        load_out[19]), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U35 ( .A(net59049), .Y(n33) );
  sky130_fd_sc_hd__nand3_1 U36 ( .A(n31), .B(n32), .C(n13), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U37 ( .A(load_out[4]), .Y(n13) );
  sky130_fd_sc_hd__a21oi_1 U38 ( .A1(load_out[7]), .A2(net59590), .B1(n12), 
        .Y(n14) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(n22), .B(n23), .Y(bits[0]) );
  sky130_fd_sc_hd__nor2_1 U40 ( .A(n18), .B(n19), .Y(bits[1]) );
  sky130_fd_sc_hd__o211ai_1 U41 ( .A1(net51828), .A2(n16), .B1(net51854), .C1(
        n17), .Y(n87) );
  sky130_fd_sc_hd__inv_1 U42 ( .A(n128), .Y(n25) );
  sky130_fd_sc_hd__nor2_1 U43 ( .A(net59049), .B(n128), .Y(n29) );
  sky130_fd_sc_hd__o21ai_1 U44 ( .A1(net51803), .A2(n20), .B1(net51804), .Y(
        n81) );
  sky130_fd_sc_hd__mux2i_1 U45 ( .A0(net51859), .A1(net51852), .S(load_out[4]), 
        .Y(net51858) );
  sky130_fd_sc_hd__nand3b_1 U46 ( .A_N(load_out[4]), .B(n28), .C(n27), .Y(n18)
         );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(n30), .B(n29), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(load_out[5]), .B(net51860), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(load_out[7]), .B(net51850), .Y(n15) );
  sky130_fd_sc_hd__nor2_1 U50 ( .A(load_out[7]), .B(load_out[5]), .Y(n31) );
  sky130_fd_sc_hd__nor2_1 U51 ( .A(load_out[7]), .B(load_out[5]), .Y(n27) );
  sky130_fd_sc_hd__a21oi_1 U52 ( .A1(load_out[5]), .A2(load_out[4]), .B1(n11), 
        .Y(n16) );
  sky130_fd_sc_hd__inv_1 U53 ( .A(load_out[5]), .Y(n24) );
  sky130_fd_sc_hd__dlygate4sd3_1 U54 ( .A(n128), .X(net59590) );
  sky130_fd_sc_hd__inv_1 U55 ( .A(net59752), .Y(net59015) );
  sky130_fd_sc_hd__inv_1 U56 ( .A(net59049), .Y(net59006) );
  sky130_fd_sc_hd__inv_1 U57 ( .A(net59015), .Y(net56160) );
  sky130_fd_sc_hd__o21ai_0 U58 ( .A1(net51828), .A2(net56142), .B1(n42), .Y(
        n48) );
  sky130_fd_sc_hd__inv_1 U59 ( .A(net59006), .Y(net56145) );
  sky130_fd_sc_hd__inv_1 U60 ( .A(net59384), .Y(net56142) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(net56142), .Y(net56129) );
  sky130_fd_sc_hd__o21ai_0 U62 ( .A1(net51828), .A2(net59006), .B1(n39), .Y(
        net51860) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(load[1]), .Y(n35) );
  sky130_fd_sc_hd__o22ai_1 U64 ( .A1(n34), .A2(n35), .B1(n126), .B2(n8), .Y(
        n39) );
  sky130_fd_sc_hd__nand2_1 U65 ( .A(n39), .B(n35), .Y(net51828) );
  sky130_fd_sc_hd__mux2i_1 U66 ( .A0(net51828), .A1(n39), .S(net56145), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U67 ( .A(net51839), .B(net59006), .Y(net51859) );
  sky130_fd_sc_hd__a21o_1 U68 ( .A1(load_in[4]), .A2(n2), .B1(net51858), .X(
        n107) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(load_in[5]), .B(n2), .Y(net51854) );
  sky130_fd_sc_hd__nand2_1 U70 ( .A(n11), .B(net51839), .Y(n37) );
  sky130_fd_sc_hd__mux2i_1 U71 ( .A0(n37), .A1(net51842), .S(net59590), .Y(n38) );
  sky130_fd_sc_hd__a21o_1 U72 ( .A1(load_in[6]), .A2(n2), .B1(n38), .X(n108)
         );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(load_in[7]), .B(n2), .Y(net51844) );
  sky130_fd_sc_hd__o21ai_1 U74 ( .A1(n12), .A2(net51828), .B1(n39), .Y(n41) );
  sky130_fd_sc_hd__nand3_1 U75 ( .A(n12), .B(net51839), .C(net56142), .Y(n45)
         );
  sky130_fd_sc_hd__a221o_1 U76 ( .A1(net56129), .A2(n41), .B1(load_in[8]), 
        .B2(n2), .C1(n40), .X(n109) );
  sky130_fd_sc_hd__mux2i_1 U77 ( .A0(n45), .A1(n44), .S(net56160), .Y(n46) );
  sky130_fd_sc_hd__a21o_1 U78 ( .A1(load_in[9]), .A2(n2), .B1(n46), .X(n110)
         );
  sky130_fd_sc_hd__nor3_1 U79 ( .A(net51828), .B(net59015), .C(n21), .Y(n47)
         );
  sky130_fd_sc_hd__a221o_1 U80 ( .A1(net56133), .A2(n48), .B1(load_in[10]), 
        .B2(n2), .C1(n47), .X(n106) );
  sky130_fd_sc_hd__inv_1 U81 ( .A(load[3]), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(n126), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n8), .B(n49), .Y(n64) );
  sky130_fd_sc_hd__inv_1 U84 ( .A(load_out[26]), .Y(n50) );
  sky130_fd_sc_hd__o2bb2ai_1 U85 ( .B1(net51803), .B2(n50), .A1_N(load_in[26]), 
        .A2_N(n4), .Y(n111) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(load_out[25]), .Y(n53) );
  sky130_fd_sc_hd__a22oi_1 U87 ( .A1(load_in[25]), .A2(n4), .B1(load_out[26]), 
        .B2(n10), .Y(n52) );
  sky130_fd_sc_hd__o21ai_1 U88 ( .A1(net51803), .A2(n53), .B1(n52), .Y(n117)
         );
  sky130_fd_sc_hd__inv_1 U89 ( .A(load_out[24]), .Y(n55) );
  sky130_fd_sc_hd__a22oi_1 U90 ( .A1(load_in[24]), .A2(n4), .B1(load_out[25]), 
        .B2(n10), .Y(n54) );
  sky130_fd_sc_hd__o21ai_1 U91 ( .A1(net51803), .A2(n55), .B1(n54), .Y(n116)
         );
  sky130_fd_sc_hd__inv_1 U93 ( .A(load_out[23]), .Y(n57) );
  sky130_fd_sc_hd__a22oi_1 U94 ( .A1(load_in[23]), .A2(n4), .B1(load_out[24]), 
        .B2(n10), .Y(n56) );
  sky130_fd_sc_hd__o21ai_1 U95 ( .A1(net51803), .A2(n57), .B1(n56), .Y(n115)
         );
  sky130_fd_sc_hd__inv_1 U96 ( .A(load_out[22]), .Y(n59) );
  sky130_fd_sc_hd__a22oi_1 U97 ( .A1(load_in[22]), .A2(n4), .B1(load_out[23]), 
        .B2(n10), .Y(n58) );
  sky130_fd_sc_hd__o21ai_1 U98 ( .A1(net51803), .A2(n59), .B1(n58), .Y(n114)
         );
  sky130_fd_sc_hd__inv_1 U99 ( .A(load_out[21]), .Y(n61) );
  sky130_fd_sc_hd__a22oi_1 U100 ( .A1(load_in[21]), .A2(n4), .B1(load_out[22]), 
        .B2(n10), .Y(n60) );
  sky130_fd_sc_hd__o21ai_1 U101 ( .A1(net51803), .A2(n61), .B1(n60), .Y(n113)
         );
  sky130_fd_sc_hd__inv_1 U102 ( .A(load_out[20]), .Y(n63) );
  sky130_fd_sc_hd__a22oi_1 U103 ( .A1(load_in[20]), .A2(n4), .B1(load_out[21]), 
        .B2(n10), .Y(n62) );
  sky130_fd_sc_hd__o21ai_1 U104 ( .A1(n63), .A2(net51803), .B1(n62), .Y(n112)
         );
  sky130_fd_sc_hd__a22oi_1 U105 ( .A1(load_in[19]), .A2(n4), .B1(load_out[20]), 
        .B2(n10), .Y(net51804) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(load[2]), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(load_out[18]), .Y(n65) );
  sky130_fd_sc_hd__o2bb2ai_1 U108 ( .B1(n104), .B2(n65), .A1_N(load_in[18]), 
        .A2_N(n3), .Y(n118) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(load_out[17]), .Y(n92) );
  sky130_fd_sc_hd__a22oi_1 U110 ( .A1(load_in[17]), .A2(n3), .B1(load_out[18]), 
        .B2(n9), .Y(n91) );
  sky130_fd_sc_hd__o21ai_1 U111 ( .A1(n104), .A2(n92), .B1(n91), .Y(n125) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(load_out[16]), .Y(n94) );
  sky130_fd_sc_hd__a22oi_1 U113 ( .A1(load_in[16]), .A2(n3), .B1(load_out[17]), 
        .B2(n9), .Y(n93) );
  sky130_fd_sc_hd__o21ai_1 U114 ( .A1(n104), .A2(n94), .B1(n93), .Y(n124) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(load_out[15]), .Y(n96) );
  sky130_fd_sc_hd__a22oi_1 U116 ( .A1(load_in[15]), .A2(n3), .B1(load_out[16]), 
        .B2(n9), .Y(n95) );
  sky130_fd_sc_hd__o21ai_1 U117 ( .A1(n104), .A2(n96), .B1(n95), .Y(n123) );
  sky130_fd_sc_hd__inv_1 U118 ( .A(load_out[14]), .Y(n98) );
  sky130_fd_sc_hd__a22oi_1 U119 ( .A1(load_in[14]), .A2(n3), .B1(load_out[15]), 
        .B2(n9), .Y(n97) );
  sky130_fd_sc_hd__o21ai_1 U120 ( .A1(n104), .A2(n98), .B1(n97), .Y(n122) );
  sky130_fd_sc_hd__inv_1 U121 ( .A(load_out[13]), .Y(n100) );
  sky130_fd_sc_hd__a22oi_1 U122 ( .A1(load_in[13]), .A2(n3), .B1(load_out[14]), 
        .B2(n9), .Y(n99) );
  sky130_fd_sc_hd__o21ai_1 U123 ( .A1(n104), .A2(n100), .B1(n99), .Y(n121) );
  sky130_fd_sc_hd__inv_1 U124 ( .A(load_out[12]), .Y(n102) );
  sky130_fd_sc_hd__a22oi_1 U125 ( .A1(load_in[12]), .A2(n3), .B1(load_out[13]), 
        .B2(n9), .Y(n101) );
  sky130_fd_sc_hd__o21ai_1 U126 ( .A1(n102), .A2(n104), .B1(n101), .Y(n120) );
  sky130_fd_sc_hd__inv_1 U127 ( .A(load_out[11]), .Y(net51777) );
  sky130_fd_sc_hd__a22oi_1 U128 ( .A1(load_in[11]), .A2(n3), .B1(load_out[12]), 
        .B2(n9), .Y(n103) );
  sky130_fd_sc_hd__o21ai_1 U129 ( .A1(net51777), .A2(n104), .B1(n103), .Y(n119) );
endmodule


module SpriteSet ( clk, ce, enable, load, load_in, bits, is_sprite0 );
  input [3:0] load;
  input [26:0] load_in;
  output [4:0] bits;
  input clk, ce, enable;
  output is_sprite0;
  wire   net52504, net52505, net52506, net52520, net52527, net52531, net52532,
         net52539, net52541, net52542, net52551, net52557, net52571, net59414,
         net59440, net59510, net59585, net59849, net59837, net59903, net52521,
         net52508, net52570, net59508, net59057, net66669, net66647, net60308,
         net59512, net52534, net66694, net70682, net52553, net52523, net70696,
         net60274, net59898, net59416, net52554, net52544, net59765, net59520,
         net59011, net58889, net52519, net66641, net63331, net62049, net60341,
         net59974, net59584, net59572, net59081, net52569, net52568, net52556,
         net52552, net52548, net52546, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
         n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52,
         n53, n54, n55, n56, n57, n58, n59, n60;
  wire   [26:0] load_out7;
  wire   [4:0] bits7;
  wire   [26:0] load_out6;
  wire   [4:0] bits6;
  wire   [26:0] load_out5;
  wire   [4:0] bits5;
  wire   [26:0] load_out4;
  wire   [4:0] bits4;
  wire   [26:0] load_out3;
  wire   [4:0] bits3;
  wire   [26:0] load_out2;
  wire   [4:0] bits2;
  wire   [26:0] load_out1;
  wire   [4:0] bits1;
  wire   [4:0] bits0;
  assign is_sprite0 = net59414;

  Sprite_0 sprite7 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_in), .load_out(load_out7), .bits(bits7) );
  Sprite_7 sprite6 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out7), .load_out(load_out6), .bits(bits6) );
  Sprite_6 sprite5 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out6), .load_out(load_out5), .bits(bits5) );
  Sprite_5 sprite4 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out5), .load_out(load_out4), .bits(bits4) );
  Sprite_4 sprite3 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out4), .load_out(load_out3), .bits(bits3) );
  Sprite_3 sprite2 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out3), .load_out(load_out2), .bits(bits2) );
  Sprite_2 sprite1 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out2), .load_out(load_out1), .bits(bits1) );
  Sprite_1 sprite0 ( .clk(clk), .ce(ce), .enable(enable), .load(load), 
        .load_in(load_out1), .bits(bits0) );
  sky130_fd_sc_hd__o22a_1 U1 ( .A1(n1), .A2(n3), .B1(n33), .B2(n45), .X(n59)
         );
  sky130_fd_sc_hd__clkinv_16 U2 ( .A(bits2[4]), .Y(n1) );
  sky130_fd_sc_hd__dlygate4sd1_1 U3 ( .A(net52569), .X(n2) );
  sky130_fd_sc_hd__inv_1 U4 ( .A(net52557), .Y(net52521) );
  sky130_fd_sc_hd__inv_1 U5 ( .A(net52508), .Y(n3) );
  sky130_fd_sc_hd__nand2_2 U6 ( .A(net52531), .B(net52541), .Y(n35) );
  sky130_fd_sc_hd__nand2_1 U7 ( .A(n13), .B(n44), .Y(n45) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(bits6[4]), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(bits5[4]), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(bits7[4]), .Y(n33) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(net66694), .B(net59974), .Y(net66647) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(net52552), .Y(net59572) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n35), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(net66647), .B(net52553), .Y(net52523) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(bits0[1]), .Y(net59011) );
  sky130_fd_sc_hd__nand3_1 U16 ( .A(net59572), .B(n6), .C(net52548), .Y(
        net59585) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(n32), .Y(n54) );
  sky130_fd_sc_hd__inv_1 U18 ( .A(bits0[0]), .Y(net58889) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(net52520), .Y(net52506) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(bits4[1]), .Y(net59081) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U21 ( .A(net59081), .X(net59520) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(n7), .B(net60341), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(n5), .Y(n6) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(net52556), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(net59585), .Y(net52504) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(n13), .B(n42), .Y(n43) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(net52556), .Y(net52551) );
  sky130_fd_sc_hd__nand2_1 U28 ( .A(n4), .B(n36), .Y(n8) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n36), .B(n4), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(net59849), .Y(n23) );
  sky130_fd_sc_hd__dlygate4sd1_1 U31 ( .A(net52531), .X(n9) );
  sky130_fd_sc_hd__inv_1 U32 ( .A(n3), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(net52554), .Y(net52508) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(n11), .Y(n13) );
  sky130_fd_sc_hd__nand4_1 U35 ( .A(net59837), .B(n23), .C(n7), .D(net59572), 
        .Y(n11) );
  sky130_fd_sc_hd__nor2_1 U36 ( .A(net59765), .B(net59510), .Y(n12) );
  sky130_fd_sc_hd__nand4_1 U37 ( .A(n23), .B(net59572), .C(net59837), .D(n7), 
        .Y(n30) );
  sky130_fd_sc_hd__nor2_1 U38 ( .A(net59765), .B(net59510), .Y(net59837) );
  sky130_fd_sc_hd__a21oi_1 U39 ( .A1(net59081), .A2(net63331), .B1(net59765), 
        .Y(n14) );
  sky130_fd_sc_hd__a21oi_1 U40 ( .A1(net59081), .A2(net52546), .B1(net59765), 
        .Y(net62049) );
  sky130_fd_sc_hd__nand2_2 U41 ( .A(n37), .B(n39), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(net52521), .B(net60308), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U43 ( .A(net52508), .B(net59512), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n15), .B(n16), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U45 ( .A(n17), .B(net52534), .Y(n18) );
  sky130_fd_sc_hd__o221ai_1 U46 ( .A1(net66694), .A2(net52523), .B1(net59520), 
        .B2(net52519), .C1(net59011), .Y(net52534) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(net52521), .B(net60274), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(net52508), .B(net59416), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n19), .B(n20), .Y(n21) );
  sky130_fd_sc_hd__nor2_1 U50 ( .A(n21), .B(net52544), .Y(n22) );
  sky130_fd_sc_hd__o221ai_1 U51 ( .A1(net59974), .A2(net52523), .B1(net52546), 
        .B2(net59584), .C1(net59898), .Y(net52544) );
  sky130_fd_sc_hd__inv_1 U52 ( .A(bits3[0]), .Y(net52571) );
  sky130_fd_sc_hd__nand4_1 U53 ( .A(n39), .B(n37), .C(net52541), .D(net52531), 
        .Y(n24) );
  sky130_fd_sc_hd__inv_1 U54 ( .A(n24), .Y(n44) );
  sky130_fd_sc_hd__nand4_1 U55 ( .A(net62049), .B(net59572), .C(net60341), .D(
        n7), .Y(net59584) );
  sky130_fd_sc_hd__nand2_2 U56 ( .A(net52568), .B(net52569), .Y(net52556) );
  sky130_fd_sc_hd__inv_1 U57 ( .A(bits2[0]), .Y(net52569) );
  sky130_fd_sc_hd__inv_1 U58 ( .A(n2), .Y(net59416) );
  sky130_fd_sc_hd__inv_1 U59 ( .A(bits2[1]), .Y(net52568) );
  sky130_fd_sc_hd__dlygate4sd1_1 U60 ( .A(net52568), .X(net70682) );
  sky130_fd_sc_hd__nand4_1 U61 ( .A(n14), .B(net59572), .C(net60341), .D(n7), 
        .Y(net52519) );
  sky130_fd_sc_hd__nand2_1 U62 ( .A(net59974), .B(net66641), .Y(net52552) );
  sky130_fd_sc_hd__inv_2 U63 ( .A(bits1[0]), .Y(net59974) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(net66641), .B(net59974), .Y(net66669) );
  sky130_fd_sc_hd__inv_1 U65 ( .A(bits1[1]), .Y(net66641) );
  sky130_fd_sc_hd__a21oi_1 U66 ( .A1(net52546), .A2(net59520), .B1(net59765), 
        .Y(net52548) );
  sky130_fd_sc_hd__nand2_1 U67 ( .A(net63331), .B(net59081), .Y(net59849) );
  sky130_fd_sc_hd__inv_1 U68 ( .A(bits4[0]), .Y(net52546) );
  sky130_fd_sc_hd__nor2_1 U69 ( .A(bits3[1]), .B(bits3[0]), .Y(net60341) );
  sky130_fd_sc_hd__inv_1 U70 ( .A(bits1[1]), .Y(net66694) );
  sky130_fd_sc_hd__inv_1 U71 ( .A(bits4[0]), .Y(net63331) );
  sky130_fd_sc_hd__inv_1 U72 ( .A(bits3[1]), .Y(net52570) );
  sky130_fd_sc_hd__dlygate4sd1_1 U73 ( .A(bits3[0]), .X(net60274) );
  sky130_fd_sc_hd__nand2_2 U74 ( .A(net59011), .B(net58889), .Y(net59765) );
  sky130_fd_sc_hd__dlygate4sd1_1 U75 ( .A(net58889), .X(net59898) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(net59011), .B(net58889), .Y(net59508) );
  sky130_fd_sc_hd__o211ai_1 U77 ( .A1(net52541), .A2(net52527), .B1(n22), .C1(
        net52542), .Y(bits[0]) );
  sky130_fd_sc_hd__nand2_1 U78 ( .A(net59057), .B(net70696), .Y(net52554) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(net52551), .Y(net70696) );
  sky130_fd_sc_hd__inv_1 U80 ( .A(net59508), .Y(net52553) );
  sky130_fd_sc_hd__dlygate4sd1_1 U81 ( .A(net52553), .X(net59903) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(bits5[1]), .Y(net52531) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n7), .B(net59057), .Y(net52557) );
  sky130_fd_sc_hd__inv_1 U84 ( .A(n30), .Y(net59440) );
  sky130_fd_sc_hd__o211ai_1 U85 ( .A1(n9), .A2(net52527), .B1(n18), .C1(
        net52532), .Y(bits[1]) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(net70682), .Y(net59512) );
  sky130_fd_sc_hd__inv_1 U87 ( .A(net52570), .Y(net60308) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U88 ( .A(n35), .X(n25) );
  sky130_fd_sc_hd__inv_1 U89 ( .A(bits5[0]), .Y(net52541) );
  sky130_fd_sc_hd__nand2_2 U90 ( .A(net52570), .B(net52571), .Y(net59510) );
  sky130_fd_sc_hd__nor2_1 U91 ( .A(net59508), .B(net66669), .Y(net59057) );
  sky130_fd_sc_hd__nor2_1 U92 ( .A(net66647), .B(net59849), .Y(n26) );
  sky130_fd_sc_hd__a22oi_1 U93 ( .A1(bits1[4]), .A2(net52505), .B1(bits3[4]), 
        .B2(net52506), .Y(n58) );
  sky130_fd_sc_hd__nor3_1 U94 ( .A(n29), .B(n41), .C(net52539), .Y(n40) );
  sky130_fd_sc_hd__nand2_1 U95 ( .A(net52521), .B(net59510), .Y(net52520) );
  sky130_fd_sc_hd__nand2_1 U96 ( .A(n4), .B(n36), .Y(n41) );
  sky130_fd_sc_hd__inv_1 U97 ( .A(n39), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(n28), .Y(n29) );
  sky130_fd_sc_hd__nand3_1 U99 ( .A(n26), .B(n7), .C(n12), .Y(net52539) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(n8), .Y(n42) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(net52523), .Y(net52505) );
  sky130_fd_sc_hd__o22a_1 U102 ( .A1(n31), .A2(n32), .B1(n34), .B2(n43), .X(
        n60) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(net59440), .B(n25), .Y(n32) );
  sky130_fd_sc_hd__nand2_1 U104 ( .A(net59440), .B(n25), .Y(net52527) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(net59903), .Y(net59414) );
  sky130_fd_sc_hd__inv_2 U106 ( .A(n43), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U107 ( .A(n45), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U108 ( .A(bits6[1]), .Y(n39) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(bits6[0]), .Y(n37) );
  sky130_fd_sc_hd__nor3_1 U110 ( .A(n37), .B(n27), .C(net52539), .Y(n38) );
  sky130_fd_sc_hd__a31oi_1 U111 ( .A1(n13), .A2(n44), .A3(bits7[0]), .B1(n38), 
        .Y(net52542) );
  sky130_fd_sc_hd__a31oi_1 U112 ( .A1(n13), .A2(n44), .A3(bits7[1]), .B1(n40), 
        .Y(net52532) );
  sky130_fd_sc_hd__a22oi_1 U113 ( .A1(bits6[2]), .A2(n55), .B1(bits5[2]), .B2(
        n54), .Y(n49) );
  sky130_fd_sc_hd__a22oi_1 U114 ( .A1(bits7[2]), .A2(n56), .B1(bits2[2]), .B2(
        n10), .Y(n48) );
  sky130_fd_sc_hd__a22oi_1 U115 ( .A1(bits1[2]), .A2(net52505), .B1(bits3[2]), 
        .B2(net52506), .Y(n47) );
  sky130_fd_sc_hd__a22oi_1 U116 ( .A1(bits4[2]), .A2(net52504), .B1(bits0[2]), 
        .B2(net59414), .Y(n46) );
  sky130_fd_sc_hd__nand4_1 U117 ( .A(n49), .B(n48), .C(n47), .D(n46), .Y(
        bits[2]) );
  sky130_fd_sc_hd__a22oi_1 U118 ( .A1(bits6[3]), .A2(n55), .B1(bits5[3]), .B2(
        n54), .Y(n53) );
  sky130_fd_sc_hd__a22oi_1 U119 ( .A1(bits7[3]), .A2(n56), .B1(bits2[3]), .B2(
        n10), .Y(n52) );
  sky130_fd_sc_hd__a22oi_1 U120 ( .A1(bits1[3]), .A2(net52505), .B1(bits3[3]), 
        .B2(net52506), .Y(n51) );
  sky130_fd_sc_hd__a22oi_1 U121 ( .A1(bits4[3]), .A2(net52504), .B1(bits0[3]), 
        .B2(net59414), .Y(n50) );
  sky130_fd_sc_hd__nand4_1 U122 ( .A(n53), .B(n52), .C(n51), .D(n50), .Y(
        bits[3]) );
  sky130_fd_sc_hd__a22oi_1 U123 ( .A1(net52504), .A2(bits4[4]), .B1(bits0[4]), 
        .B2(net59414), .Y(n57) );
  sky130_fd_sc_hd__nand4_1 U124 ( .A(n59), .B(n58), .C(n60), .D(n57), .Y(
        bits[4]) );
endmodule


module PixelMuxer ( bg, obj, obj_prio, out, is_obj );
  input [3:0] bg;
  input [3:0] obj;
  output [3:0] out;
  input obj_prio;
  output is_obj;
  wire   net25004, net51767, net51770, net56166, net51768, net70811, net51774,
         net51773, net51771, net70814, net59331, net51775, net51772, n1, n2,
         n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17;
  assign is_obj = net25004;

  sky130_fd_sc_hd__inv_2 U1 ( .A(bg[3]), .Y(n8) );
  sky130_fd_sc_hd__inv_2 U2 ( .A(obj[1]), .Y(n13) );
  sky130_fd_sc_hd__or2_1 U3 ( .A(bg[0]), .B(bg[1]), .X(net59331) );
  sky130_fd_sc_hd__nand2_2 U4 ( .A(net51771), .B(net51772), .Y(net51770) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(n2), .B(n1), .Y(out[1]) );
  sky130_fd_sc_hd__clkinv_1 U6 ( .A(net51768), .Y(n3) );
  sky130_fd_sc_hd__clkinv_1 U7 ( .A(net56166), .Y(n4) );
  sky130_fd_sc_hd__inv_1 U8 ( .A(net70811), .Y(n5) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(net70811), .B(n3), .Y(n1) );
  sky130_fd_sc_hd__nand2_1 U10 ( .A(n4), .B(n5), .Y(n2) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(obj[0]), .Y(net51774) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(obj[0]), .Y(n6) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n14), .B(net51772), .Y(n7) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(n14), .B(net51772), .Y(net51775) );
  sky130_fd_sc_hd__o21ai_1 U15 ( .A1(net51767), .A2(n8), .B1(n15), .Y(out[3])
         );
  sky130_fd_sc_hd__nand2_2 U16 ( .A(obj_prio), .B(net59331), .Y(net51772) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U17 ( .A(n13), .X(net56166) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n9), .B(net51774), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(net51773), .B(n7), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n10), .B(n11), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U21 ( .A(net51775), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U22 ( .A(n12), .Y(out[0]) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(net51770), .Y(net51767) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n6), .B(n13), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U25 ( .A(net51774), .B(n13), .Y(net70814) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(n7), .Y(net25004) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(net51772), .B(net70814), .Y(net70811) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(bg[0]), .Y(net51773) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(bg[1]), .Y(net51768) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(n6), .B(n13), .Y(net51771) );
  sky130_fd_sc_hd__nand2_1 U31 ( .A(net51767), .B(obj[3]), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(net51770), .B(bg[2]), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(net51767), .B(obj[2]), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U34 ( .A(n16), .B(n17), .Y(out[2]) );
endmodule


module PaletteRam ( clk, ce, addr, din, dout, write );
  input [4:0] addr;
  input [5:0] din;
  output [5:0] dout;
  input clk, ce, write;
  wire   N13, N14, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
         n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136, n137, n138,
         n139, n140, n141, n142, n143, n144, n145, n146, n147, n148, n149,
         n150, n151, n152, n153, n154, n155, n156, n157, n158, n159, n160,
         n161, n162, n163, n164, n165, n166, n167, n168, n169, n170, n171,
         n172, n173, n174, n175, n176, n177, n178, n179, n180, n181, n182,
         n183, n184, n185, n186, n187, n188, n189, n190, n191, n192, n193,
         n194, n195, n196, n197, n198, n199, n200, n201, n202, net25013,
         net25014, net51532, net51543, net51554, net51563, net51565, net51571,
         net51574, net51580, net51583, net51589, net51591, net51594, net51600,
         net51601, net51619, net51625, net51627, net51633, net51635, net51641,
         net51642, net51644, net51645, net51653, net51671, net51677, net51679,
         net51685, net51687, net51693, net51696, net51702, net51713, net51723,
         net51731, net51740, net51749, net51755, net51761, net51762, net55292,
         net55506, net55576, net56187, net56186, net56192, net56191, net56197,
         net56196, net56212, net56211, \C856/net25056 , \C856/net25055 ,
         \C856/net25053 , \C856/net2133 , \C856/net2134 , \C856/net2169 ,
         \C856/net2256 , \C856/net2257 , \C856/net2258 , \C856/net2259 ,
         net58892, net58891, net58897, net58896, net58906, net58905, net58911,
         net58910, net58919, net58917, net58924, net58950, net58960, net58959,
         net58965, net58964, net58970, net58969, net59094, net59386, net59398,
         net59397, net59433, net59432, net61482, net61474, net62954, net63079,
         net63192, net63153, net63151, net63139, net63804, net61448, net64761,
         net70626, net70620, net70619, net70568, net70558, net70719, net51727,
         net70564, net51734, net51733, net51572, net64762, net61458, net59887,
         net58918, net51765, net51764, net51763, net51592, net69665, net64790,
         net64724, net63149, net63122, net61412, net59886, net51753, net51643,
         net51741, net51736, net70638, net70628, net62939, net59392, net58949,
         net51743, net51742, net51703, net51581, n1, n2, n3, n4, n5, n6, n7,
         n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21,
         n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35,
         n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49,
         n50, n51, n52, n203, n204, n205, n206, n207, n208, n209, n210, n211,
         n212, n213, n214, n215, n216, n217, n218, n219, n220, n221, n222,
         n223, n224, n225, n226, n227, n228, n229, n230, n231, n232, n233,
         n234, n235, n236, n237, n238, n239, n240, n241, n242, n243, n244,
         n245, n246, n247, n248, n249, n250, n251, n252, n253, n254, n255,
         n256, n257, n258, n259, n260, n261, n262, n263, n264, n265, n266,
         n267, n268, n269, n270, n271, n272, n273, n274, n275, n276, n277,
         n278, n279, n280, n281, n282, n283, n284, n285, n286, n287, n288,
         n289, n290, n291, n292, n293, n294, n295, n296, n297, n298, n299,
         n300, n301, n302, n303, n304, n305, n306, n307, n308, n309, n310,
         n311, n312, n313, n314, n315, n316, n317, n318, n319, n320, n321,
         n322, n323, n324, n325, n326, n327, n328, n329, n330, n331, n332,
         n333, n334, n335, n336, n337, n338, n339, n340, n341, n342, n343,
         n344, n345, n346, n347, n348, n349, n350, n351, n352, n353, n354,
         n355, n356, n357, n358, n359, n360, n361, n362, n363, n364, n365,
         n366, n367, n368, n369, n370, n371, n372, n373, n374, n375, n376,
         n377, n378, n379, n380, n381, n382, n383, n384, n385, n386, n387,
         n388, n389, n390, n391, n392, n393, n394, n395, n396, n397, n398,
         n399, n400, n401, n402, n403, n404, n405, n406, n407, n408, n409,
         n410, n411, n412, n413, n414, n415, n416, n417, n418, n419, n420,
         n421, n422, n423, n424, n425, n426, n427, n428, n429, n430, n431,
         n432, n433, n434, n435, n436, n437, n438, n439, n440, n441, n442,
         n443, n444, n445, n446, n447, n448, n449, n450, n451, n452, n453,
         n454, n455, n456, n457, n458, n459, n460, n461, n462, n463, n464,
         n465, n466, n467, n468, n469, n470, n471, n472, n473, n474, n475,
         n476, n477, n478, n479, n480, n481, n482, n483, n484, n485, n486,
         n487, n488, n489, n490, n491, n492, n493, n494, n495, n496, n497,
         n498, n499, n500, n501;
  wire   [191:0] palette;
  assign N13 = addr[0];
  assign N14 = addr[1];
  assign net59386 = addr[3];

  sky130_fd_sc_hd__dfxtp_1 palette_reg_5__4_ ( .D(n177), .CLK(clk), .Q(
        palette[160]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_5__3_ ( .D(n176), .CLK(clk), .Q(
        palette[159]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_5__2_ ( .D(n175), .CLK(clk), .Q(
        palette[158]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_5__1_ ( .D(n174), .CLK(clk), .Q(
        palette[157]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_5__0_ ( .D(n173), .CLK(clk), .Q(
        palette[156]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_6__5_ ( .D(n172), .CLK(clk), .Q(
        palette[155]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_6__4_ ( .D(n171), .CLK(clk), .Q(
        palette[154]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_6__3_ ( .D(n170), .CLK(clk), .Q(
        palette[153]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_6__2_ ( .D(n169), .CLK(clk), .Q(
        palette[152]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_6__1_ ( .D(n168), .CLK(clk), .Q(
        palette[151]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_6__0_ ( .D(n167), .CLK(clk), .Q(
        palette[150]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_7__1_ ( .D(n162), .CLK(clk), .Q(
        palette[145]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_7__0_ ( .D(n161), .CLK(clk), .Q(
        palette[144]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_5__5_ ( .D(n178), .CLK(clk), .Q(
        palette[161]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_15__5_ ( .D(n130), .CLK(clk), .Q(
        palette[101]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_15__4_ ( .D(n129), .CLK(clk), .Q(
        palette[100]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_1__0_ ( .D(n191), .CLK(clk), .Q(
        palette[180]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_31__0_ ( .D(n53), .CLK(clk), .Q(
        palette[0]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_26__0_ ( .D(n77), .CLK(clk), .Q(
        palette[30]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_25__0_ ( .D(n83), .CLK(clk), .Q(
        palette[36]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_27__0_ ( .D(n71), .CLK(clk), .Q(
        palette[24]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_0__0_ ( .D(n197), .CLK(clk), .Q(
        palette[186]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_31__5_ ( .D(n58), .CLK(clk), .Q(
        palette[5]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_31__4_ ( .D(n57), .CLK(clk), .Q(
        palette[4]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_31__3_ ( .D(n56), .CLK(clk), .Q(
        palette[3]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_31__2_ ( .D(n55), .CLK(clk), .Q(
        palette[2]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_31__1_ ( .D(n54), .CLK(clk), .Q(
        palette[1]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_15__3_ ( .D(n128), .CLK(clk), .Q(
        palette[99]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_15__2_ ( .D(n127), .CLK(clk), .Q(
        palette[98]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_15__1_ ( .D(n126), .CLK(clk), .Q(
        palette[97]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_15__0_ ( .D(n125), .CLK(clk), .Q(
        palette[96]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_14__5_ ( .D(n136), .CLK(clk), .Q(
        palette[107]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_14__4_ ( .D(n135), .CLK(clk), .Q(
        palette[106]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_14__3_ ( .D(n134), .CLK(clk), .Q(
        palette[105]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_14__2_ ( .D(n133), .CLK(clk), .Q(
        palette[104]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_14__1_ ( .D(n132), .CLK(clk), .Q(
        palette[103]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_14__0_ ( .D(n131), .CLK(clk), .Q(
        palette[102]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_13__5_ ( .D(n142), .CLK(clk), .Q(
        palette[113]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_13__4_ ( .D(n141), .CLK(clk), .Q(
        palette[112]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_13__3_ ( .D(n140), .CLK(clk), .Q(
        palette[111]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_13__2_ ( .D(n139), .CLK(clk), .Q(
        palette[110]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_13__1_ ( .D(n138), .CLK(clk), .Q(
        palette[109]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_13__0_ ( .D(n137), .CLK(clk), .Q(
        palette[108]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_11__5_ ( .D(n148), .CLK(clk), .Q(
        palette[125]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_11__4_ ( .D(n147), .CLK(clk), .Q(
        palette[124]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_11__3_ ( .D(n146), .CLK(clk), .Q(
        palette[123]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_11__2_ ( .D(n145), .CLK(clk), .Q(
        palette[122]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_11__1_ ( .D(n144), .CLK(clk), .Q(
        palette[121]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_11__0_ ( .D(n143), .CLK(clk), .Q(
        palette[120]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_10__5_ ( .D(n154), .CLK(clk), .Q(
        palette[131]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_10__4_ ( .D(n153), .CLK(clk), .Q(
        palette[130]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_10__3_ ( .D(n152), .CLK(clk), .Q(
        palette[129]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_10__2_ ( .D(n151), .CLK(clk), .Q(
        palette[128]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_10__1_ ( .D(n150), .CLK(clk), .Q(
        palette[127]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_10__0_ ( .D(n149), .CLK(clk), .Q(
        palette[126]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_9__5_ ( .D(n160), .CLK(clk), .Q(
        palette[137]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_9__4_ ( .D(n159), .CLK(clk), .Q(
        palette[136]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_9__3_ ( .D(n158), .CLK(clk), .Q(
        palette[135]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_9__2_ ( .D(n157), .CLK(clk), .Q(
        palette[134]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_9__1_ ( .D(n156), .CLK(clk), .Q(
        palette[133]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_9__0_ ( .D(n155), .CLK(clk), .Q(
        palette[132]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_0__5_ ( .D(n202), .CLK(clk), .Q(
        palette[191]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_0__4_ ( .D(n201), .CLK(clk), .Q(
        palette[190]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_0__3_ ( .D(n200), .CLK(clk), .Q(
        palette[189]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_0__2_ ( .D(n199), .CLK(clk), .Q(
        palette[188]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_0__1_ ( .D(n198), .CLK(clk), .Q(
        palette[187]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_1__5_ ( .D(n196), .CLK(clk), .Q(
        palette[185]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_1__3_ ( .D(n194), .CLK(clk), .Q(
        palette[183]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_1__1_ ( .D(n192), .CLK(clk), .Q(
        palette[181]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_22__5_ ( .D(n100), .CLK(clk), .Q(
        palette[59]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_22__4_ ( .D(n99), .CLK(clk), .Q(
        palette[58]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_22__3_ ( .D(n98), .CLK(clk), .Q(
        palette[57]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_22__2_ ( .D(n97), .CLK(clk), .Q(
        palette[56]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_22__1_ ( .D(n96), .CLK(clk), .Q(
        palette[55]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_22__0_ ( .D(n95), .CLK(clk), .Q(
        palette[54]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_21__5_ ( .D(n106), .CLK(clk), .Q(
        palette[65]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_21__4_ ( .D(n105), .CLK(clk), .Q(
        palette[64]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_21__3_ ( .D(n104), .CLK(clk), .Q(
        palette[63]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_21__2_ ( .D(n103), .CLK(clk), .Q(
        palette[62]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_21__1_ ( .D(n102), .CLK(clk), .Q(
        palette[61]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_21__0_ ( .D(n101), .CLK(clk), .Q(
        palette[60]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_19__5_ ( .D(n112), .CLK(clk), .Q(
        palette[77]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_19__4_ ( .D(n111), .CLK(clk), .Q(
        palette[76]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_19__3_ ( .D(n110), .CLK(clk), .Q(
        palette[75]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_19__2_ ( .D(n109), .CLK(clk), .Q(
        palette[74]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_19__1_ ( .D(n108), .CLK(clk), .Q(
        palette[73]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_19__0_ ( .D(n107), .CLK(clk), .Q(
        palette[72]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_18__5_ ( .D(n118), .CLK(clk), .Q(
        palette[83]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_18__4_ ( .D(n117), .CLK(clk), .Q(
        palette[82]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_18__3_ ( .D(n116), .CLK(clk), .Q(
        palette[81]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_18__2_ ( .D(n115), .CLK(clk), .Q(
        palette[80]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_18__1_ ( .D(n114), .CLK(clk), .Q(
        palette[79]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_18__0_ ( .D(n113), .CLK(clk), .Q(
        palette[78]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_17__5_ ( .D(n124), .CLK(clk), .Q(
        palette[89]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_17__4_ ( .D(n123), .CLK(clk), .Q(
        palette[88]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_17__3_ ( .D(n122), .CLK(clk), .Q(
        palette[87]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_17__2_ ( .D(n121), .CLK(clk), .Q(
        palette[86]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_17__1_ ( .D(n120), .CLK(clk), .Q(
        palette[85]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_17__0_ ( .D(n119), .CLK(clk), .Q(
        palette[84]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_30__2_ ( .D(n61), .CLK(clk), .Q(
        palette[8]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_30__1_ ( .D(n60), .CLK(clk), .Q(
        palette[7]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_30__0_ ( .D(n59), .CLK(clk), .Q(
        palette[6]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_30__5_ ( .D(n64), .CLK(clk), .Q(
        palette[11]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_30__4_ ( .D(n63), .CLK(clk), .Q(
        palette[10]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_30__3_ ( .D(n62), .CLK(clk), .Q(
        palette[9]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_26__5_ ( .D(n82), .CLK(clk), .Q(
        palette[35]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_26__4_ ( .D(n81), .CLK(clk), .Q(
        palette[34]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_26__3_ ( .D(n80), .CLK(clk), .Q(
        palette[33]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_26__2_ ( .D(n79), .CLK(clk), .Q(
        palette[32]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_26__1_ ( .D(n78), .CLK(clk), .Q(
        palette[31]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_25__5_ ( .D(n88), .CLK(clk), .Q(
        palette[41]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_25__4_ ( .D(n87), .CLK(clk), .Q(
        palette[40]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_25__3_ ( .D(n86), .CLK(clk), .Q(
        palette[39]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_25__2_ ( .D(n85), .CLK(clk), .Q(
        palette[38]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_25__1_ ( .D(n84), .CLK(clk), .Q(
        palette[37]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_2__5_ ( .D(n190), .CLK(clk), .Q(
        palette[179]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_2__4_ ( .D(n189), .CLK(clk), .Q(
        palette[178]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_2__3_ ( .D(n188), .CLK(clk), .Q(
        palette[177]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_2__2_ ( .D(n187), .CLK(clk), .Q(
        palette[176]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_2__1_ ( .D(n186), .CLK(clk), .Q(
        palette[175]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_2__0_ ( .D(n185), .CLK(clk), .Q(
        palette[174]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_3__5_ ( .D(n184), .CLK(clk), .Q(
        palette[173]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_3__4_ ( .D(n183), .CLK(clk), .Q(
        palette[172]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_3__3_ ( .D(n182), .CLK(clk), .Q(
        palette[171]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_3__2_ ( .D(n181), .CLK(clk), .Q(
        palette[170]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_3__1_ ( .D(n180), .CLK(clk), .Q(
        palette[169]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_3__0_ ( .D(n179), .CLK(clk), .Q(
        palette[168]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_1__4_ ( .D(n195), .CLK(clk), .Q(
        palette[184]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_1__2_ ( .D(n193), .CLK(clk), .Q(
        palette[182]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_27__5_ ( .D(n76), .CLK(clk), .Q(
        palette[29]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_27__4_ ( .D(n75), .CLK(clk), .Q(
        palette[28]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_29__5_ ( .D(n70), .CLK(clk), .Q(
        palette[17]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_29__4_ ( .D(n69), .CLK(clk), .Q(
        palette[16]) );
  sky130_fd_sc_hd__dfxtp_4 palette_reg_29__0_ ( .D(n65), .CLK(clk), .Q(
        palette[12]) );
  sky130_fd_sc_hd__dfxtp_4 palette_reg_23__2_ ( .D(n91), .CLK(clk), .Q(
        palette[50]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_23__5_ ( .D(n94), .CLK(clk), .Q(
        palette[53]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_23__3_ ( .D(n92), .CLK(clk), .Q(
        palette[51]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_23__4_ ( .D(n93), .CLK(clk), .Q(
        palette[52]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_23__0_ ( .D(n89), .CLK(clk), .Q(
        palette[48]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_27__3_ ( .D(n74), .CLK(clk), .Q(
        palette[27]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_27__2_ ( .D(n73), .CLK(clk), .Q(
        palette[26]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_27__1_ ( .D(n72), .CLK(clk), .Q(
        palette[25]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_16__5_ ( .D(palette[95]), .CLK(clk), 
        .Q(palette[95]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_8__5_ ( .D(palette[143]), .CLK(clk), 
        .Q(palette[143]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_24__5_ ( .D(palette[47]), .CLK(clk), 
        .Q(palette[47]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_28__5_ ( .D(palette[23]), .CLK(clk), 
        .Q(palette[23]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_16__4_ ( .D(palette[94]), .CLK(clk), 
        .Q(palette[94]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_8__4_ ( .D(palette[142]), .CLK(clk), 
        .Q(palette[142]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_24__4_ ( .D(palette[46]), .CLK(clk), 
        .Q(palette[46]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_28__4_ ( .D(palette[22]), .CLK(clk), 
        .Q(palette[22]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_20__5_ ( .D(palette[71]), .CLK(clk), 
        .Q(palette[71]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_12__5_ ( .D(palette[119]), .CLK(clk), 
        .Q(palette[119]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_4__5_ ( .D(palette[167]), .CLK(clk), 
        .Q(palette[167]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_20__4_ ( .D(palette[70]), .CLK(clk), 
        .Q(palette[70]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_12__4_ ( .D(palette[118]), .CLK(clk), 
        .Q(palette[118]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_4__4_ ( .D(palette[166]), .CLK(clk), 
        .Q(palette[166]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_24__3_ ( .D(palette[45]), .CLK(clk), 
        .Q(palette[45]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_16__3_ ( .D(palette[93]), .CLK(clk), 
        .Q(palette[93]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_8__3_ ( .D(palette[141]), .CLK(clk), 
        .Q(palette[141]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_24__2_ ( .D(palette[44]), .CLK(clk), 
        .Q(palette[44]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_16__2_ ( .D(palette[92]), .CLK(clk), 
        .Q(palette[92]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_8__2_ ( .D(palette[140]), .CLK(clk), 
        .Q(palette[140]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_8__1_ ( .D(palette[139]), .CLK(clk), 
        .Q(palette[139]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_24__1_ ( .D(palette[43]), .CLK(clk), 
        .Q(palette[43]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_16__1_ ( .D(palette[91]), .CLK(clk), 
        .Q(palette[91]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_24__0_ ( .D(palette[42]), .CLK(clk), 
        .Q(palette[42]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_16__0_ ( .D(palette[90]), .CLK(clk), 
        .Q(palette[90]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_8__0_ ( .D(palette[138]), .CLK(clk), 
        .Q(palette[138]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_28__3_ ( .D(palette[21]), .CLK(clk), 
        .Q(palette[21]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_20__3_ ( .D(palette[69]), .CLK(clk), 
        .Q(palette[69]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_12__3_ ( .D(palette[117]), .CLK(clk), 
        .Q(palette[117]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_4__3_ ( .D(palette[165]), .CLK(clk), 
        .Q(palette[165]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_28__2_ ( .D(palette[20]), .CLK(clk), 
        .Q(palette[20]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_20__2_ ( .D(palette[68]), .CLK(clk), 
        .Q(palette[68]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_12__2_ ( .D(palette[116]), .CLK(clk), 
        .Q(palette[116]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_4__2_ ( .D(palette[164]), .CLK(clk), 
        .Q(palette[164]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_12__1_ ( .D(palette[115]), .CLK(clk), 
        .Q(palette[115]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_4__1_ ( .D(palette[163]), .CLK(clk), 
        .Q(palette[163]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_28__1_ ( .D(palette[19]), .CLK(clk), 
        .Q(palette[19]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_20__1_ ( .D(palette[67]), .CLK(clk), 
        .Q(palette[67]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_28__0_ ( .D(palette[18]), .CLK(clk), 
        .Q(palette[18]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_20__0_ ( .D(palette[66]), .CLK(clk), 
        .Q(palette[66]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_12__0_ ( .D(palette[114]), .CLK(clk), 
        .Q(palette[114]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_4__0_ ( .D(palette[162]), .CLK(clk), 
        .Q(palette[162]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_7__2_ ( .D(n163), .CLK(clk), .Q(
        palette[146]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_7__3_ ( .D(n164), .CLK(clk), .Q(
        palette[147]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_7__4_ ( .D(n165), .CLK(clk), .Q(
        palette[148]) );
  sky130_fd_sc_hd__dfxtp_1 palette_reg_7__5_ ( .D(n166), .CLK(clk), .Q(
        palette[149]) );
  sky130_fd_sc_hd__dfxtp_4 palette_reg_29__3_ ( .D(n68), .CLK(clk), .Q(
        palette[15]) );
  sky130_fd_sc_hd__dfxtp_4 palette_reg_29__2_ ( .D(n67), .CLK(clk), .Q(
        palette[14]) );
  sky130_fd_sc_hd__dfxtp_4 palette_reg_29__1_ ( .D(n66), .CLK(clk), .Q(
        palette[13]) );
  sky130_fd_sc_hd__dfxtp_4 palette_reg_23__1_ ( .D(n90), .CLK(clk), .Q(
        palette[49]) );
  sky130_fd_sc_hd__inv_1 U2 ( .A(net51600), .Y(n1) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(net51600), .Y(net51594) );
  sky130_fd_sc_hd__clkinv_2 U4 ( .A(n480), .Y(n486) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n480), .Y(n37) );
  sky130_fd_sc_hd__and2_2 U6 ( .A(net51601), .B(net63153), .X(n2) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(net70628), .Y(n3) );
  sky130_fd_sc_hd__inv_1 U8 ( .A(addr[2]), .Y(net70564) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(N13), .Y(net59392) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(write), .Y(net51764) );
  sky130_fd_sc_hd__and2_1 U11 ( .A(n20), .B(\C856/net25056 ), .X(n45) );
  sky130_fd_sc_hd__and2_1 U12 ( .A(n20), .B(net25014), .X(n44) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(net70619), .Y(\C856/net2256 ) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(\C856/net25053 ), .Y(net70620) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(net51734), .Y(net51572) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(din[0]), .Y(net55576) );
  sky130_fd_sc_hd__inv_2 U17 ( .A(palette[96]), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(palette[180]), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(net51571), .Y(net51565) );
  sky130_fd_sc_hd__and2_1 U20 ( .A(net70568), .B(net63079), .X(n4) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(din[2]), .Y(n341) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(din[1]), .Y(net55506) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(din[3]), .Y(n342) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(din[4]), .Y(n343) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(din[5]), .Y(net55292) );
  sky130_fd_sc_hd__inv_2 U26 ( .A(net63151), .Y(net63153) );
  sky130_fd_sc_hd__mux2i_1 U27 ( .A0(net55576), .A1(n481), .S(n480), .Y(n65)
         );
  sky130_fd_sc_hd__nand2_1 U28 ( .A(net58917), .B(net51572), .Y(net51571) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(net51571), .Y(net58950) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(net61474), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(net63079), .Y(n6) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(net59392), .Y(net63079) );
  sky130_fd_sc_hd__nor2_2 U33 ( .A(N14), .B(N13), .Y(net64761) );
  sky130_fd_sc_hd__nand2_2 U34 ( .A(net51563), .B(n11), .Y(n480) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(net51591), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(net64790), .B(net70564), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U37 ( .A(n488), .Y(n36) );
  sky130_fd_sc_hd__inv_1 U38 ( .A(n488), .Y(n494) );
  sky130_fd_sc_hd__inv_1 U39 ( .A(n488), .Y(n35) );
  sky130_fd_sc_hd__buf_2 U40 ( .A(N14), .X(net70638) );
  sky130_fd_sc_hd__nand2b_1 U41 ( .A_N(N14), .B(net59392), .Y(net61448) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(net63149), .B(net69665), .Y(net63122) );
  sky130_fd_sc_hd__buf_2 U43 ( .A(net70638), .X(n8) );
  sky130_fd_sc_hd__inv_1 U44 ( .A(net51641), .Y(net51635) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(net70564), .Y(net70628) );
  sky130_fd_sc_hd__dlygate4sd3_1 U46 ( .A(net70558), .X(n9) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(net69665), .B(net63149), .Y(n10) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(net63149), .B(net69665), .Y(net51753) );
  sky130_fd_sc_hd__clkinv_1 U49 ( .A(net51743), .Y(net51581) );
  sky130_fd_sc_hd__inv_1 U50 ( .A(net51591), .Y(net58917) );
  sky130_fd_sc_hd__inv_1 U51 ( .A(net51763), .Y(n12) );
  sky130_fd_sc_hd__clkinv_1 U52 ( .A(net51765), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(net51763), .Y(net51703) );
  sky130_fd_sc_hd__and2_1 U54 ( .A(net61458), .B(n13), .X(net51592) );
  sky130_fd_sc_hd__nor2_1 U55 ( .A(net51764), .B(net58918), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(ce), .Y(net58918) );
  sky130_fd_sc_hd__nand2_1 U57 ( .A(net64724), .B(n10), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U58 ( .A(net64724), .B(net51753), .Y(net51643) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(net63122), .B(addr[4]), .Y(n16) );
  sky130_fd_sc_hd__inv_1 U60 ( .A(net51580), .Y(n17) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(net51580), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U62 ( .A(net51580), .Y(net51574) );
  sky130_fd_sc_hd__and2_1 U63 ( .A(net51592), .B(net59887), .X(n19) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n11), .B(net51554), .Y(n488) );
  sky130_fd_sc_hd__dlygate4sd3_1 U65 ( .A(net58924), .X(n20) );
  sky130_fd_sc_hd__clkinv_1 U66 ( .A(net51643), .Y(net58924) );
  sky130_fd_sc_hd__nand2_1 U67 ( .A(net51703), .B(net51581), .Y(net51742) );
  sky130_fd_sc_hd__inv_1 U68 ( .A(net51742), .Y(net56192) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(net51742), .Y(net56191) );
  sky130_fd_sc_hd__inv_1 U70 ( .A(net51742), .Y(net51736) );
  sky130_fd_sc_hd__nand2_1 U71 ( .A(n11), .B(net51581), .Y(net51580) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(net51653), .B(net51581), .Y(net51685) );
  sky130_fd_sc_hd__nand2_1 U73 ( .A(net51601), .B(net51581), .Y(net51633) );
  sky130_fd_sc_hd__nand3_1 U74 ( .A(net58949), .B(net70638), .C(n6), .Y(
        net51743) );
  sky130_fd_sc_hd__nand2b_1 U75 ( .A_N(N14), .B(net59392), .Y(net70558) );
  sky130_fd_sc_hd__nand2_1 U76 ( .A(net62954), .B(n6), .Y(net51713) );
  sky130_fd_sc_hd__nand3_1 U77 ( .A(net70628), .B(net63079), .C(net70638), .Y(
        net63151) );
  sky130_fd_sc_hd__inv_2 U78 ( .A(net70638), .Y(net62939) );
  sky130_fd_sc_hd__nor2_1 U79 ( .A(net62939), .B(net63079), .Y(\C856/net2259 )
         );
  sky130_fd_sc_hd__nor2_1 U80 ( .A(net62939), .B(\C856/net25053 ), .Y(
        \C856/net2258 ) );
  sky130_fd_sc_hd__nand2_1 U81 ( .A(net62954), .B(net62939), .Y(net51723) );
  sky130_fd_sc_hd__nand2b_2 U82 ( .A_N(n8), .B(net70620), .Y(net70619) );
  sky130_fd_sc_hd__nand3_1 U83 ( .A(net63079), .B(n3), .C(n8), .Y(net51734) );
  sky130_fd_sc_hd__nor2_1 U84 ( .A(net70628), .B(net70638), .Y(net70568) );
  sky130_fd_sc_hd__nand2_1 U85 ( .A(net51703), .B(n4), .Y(net70626) );
  sky130_fd_sc_hd__nand2_1 U86 ( .A(net51703), .B(net51572), .Y(net51733) );
  sky130_fd_sc_hd__nand2_1 U87 ( .A(n12), .B(net51762), .Y(net51761) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(net70558), .B(net70628), .Y(net58949) );
  sky130_fd_sc_hd__inv_1 U89 ( .A(net58949), .Y(net62954) );
  sky130_fd_sc_hd__mux2i_1 U90 ( .A0(net51741), .A1(net55576), .S(net51736), 
        .Y(n185) );
  sky130_fd_sc_hd__mux2i_1 U91 ( .A0(net51740), .A1(net55506), .S(net51736), 
        .Y(n186) );
  sky130_fd_sc_hd__inv_1 U92 ( .A(palette[174]), .Y(net51741) );
  sky130_fd_sc_hd__nand2_1 U93 ( .A(n16), .B(net51643), .Y(net59886) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(net59886), .Y(net59887) );
  sky130_fd_sc_hd__nand3_1 U95 ( .A(n5), .B(net70719), .C(n14), .Y(net51642)
         );
  sky130_fd_sc_hd__nor2_1 U96 ( .A(net61412), .B(n14), .Y(net63139) );
  sky130_fd_sc_hd__inv_1 U97 ( .A(net64790), .Y(net64724) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(net59386), .Y(net64790) );
  sky130_fd_sc_hd__nand2_1 U99 ( .A(net64790), .B(net70564), .Y(net64762) );
  sky130_fd_sc_hd__nand2_1 U100 ( .A(net63122), .B(addr[4]), .Y(net61412) );
  sky130_fd_sc_hd__nand4_1 U101 ( .A(n15), .B(net58924), .C(write), .D(n16), 
        .Y(net63192) );
  sky130_fd_sc_hd__inv_2 U102 ( .A(N13), .Y(net63149) );
  sky130_fd_sc_hd__inv_1 U103 ( .A(n10), .Y(net51762) );
  sky130_fd_sc_hd__nand2_1 U104 ( .A(addr[4]), .B(net61448), .Y(net51644) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(N14), .Y(net69665) );
  sky130_fd_sc_hd__nand2_1 U106 ( .A(net59887), .B(net51592), .Y(net51763) );
  sky130_fd_sc_hd__nand2_1 U107 ( .A(net61458), .B(ce), .Y(net51765) );
  sky130_fd_sc_hd__nor2_1 U108 ( .A(net58918), .B(net51764), .Y(net58919) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(n7), .B(net64761), .Y(net61458) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(net51733), .Y(net56197) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(net51733), .Y(net56196) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(net51733), .Y(net51727) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(net63804), .B(net51572), .Y(net51677) );
  sky130_fd_sc_hd__nand2_1 U114 ( .A(net51601), .B(net51572), .Y(net51625) );
  sky130_fd_sc_hd__mux2i_1 U115 ( .A0(n21), .A1(net55576), .S(net51727), .Y(
        n179) );
  sky130_fd_sc_hd__mux2i_1 U116 ( .A0(net51731), .A1(net55506), .S(net51727), 
        .Y(n180) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(palette[168]), .Y(n21) );
  sky130_fd_sc_hd__a22oi_1 U118 ( .A1(palette[174]), .A2(\C856/net2133 ), .B1(
        palette[168]), .B2(\C856/net2134 ), .Y(\C856/net2169 ) );
  sky130_fd_sc_hd__and2_0 U119 ( .A(n45), .B(\C856/net2259 ), .X(n326) );
  sky130_fd_sc_hd__and2_0 U120 ( .A(n45), .B(\C856/net2258 ), .X(n325) );
  sky130_fd_sc_hd__and2_0 U121 ( .A(n45), .B(\C856/net2257 ), .X(n328) );
  sky130_fd_sc_hd__and2_0 U122 ( .A(n45), .B(\C856/net2256 ), .X(n327) );
  sky130_fd_sc_hd__and2_0 U123 ( .A(\C856/net2259 ), .B(n44), .X(n322) );
  sky130_fd_sc_hd__and2_0 U124 ( .A(n44), .B(\C856/net2258 ), .X(n321) );
  sky130_fd_sc_hd__and2_0 U125 ( .A(\C856/net2257 ), .B(n44), .X(n324) );
  sky130_fd_sc_hd__and2_0 U126 ( .A(\C856/net2256 ), .B(n44), .X(n323) );
  sky130_fd_sc_hd__and2_0 U127 ( .A(n39), .B(\C856/net2259 ), .X(
        \C856/net2133 ) );
  sky130_fd_sc_hd__and2_0 U128 ( .A(n39), .B(\C856/net2258 ), .X(
        \C856/net2134 ) );
  sky130_fd_sc_hd__and2_0 U129 ( .A(n39), .B(\C856/net2257 ), .X(n316) );
  sky130_fd_sc_hd__and2_0 U130 ( .A(n39), .B(\C856/net2256 ), .X(n315) );
  sky130_fd_sc_hd__and2_0 U131 ( .A(n38), .B(\C856/net2259 ), .X(n312) );
  sky130_fd_sc_hd__and2_0 U132 ( .A(n38), .B(\C856/net2258 ), .X(n311) );
  sky130_fd_sc_hd__and2_0 U133 ( .A(n38), .B(\C856/net2257 ), .X(n314) );
  sky130_fd_sc_hd__and2_0 U134 ( .A(n38), .B(\C856/net2256 ), .X(n313) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(net51644), .Y(net70719) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(net51644), .Y(net25013) );
  sky130_fd_sc_hd__inv_1 U137 ( .A(net63079), .Y(\C856/net25053 ) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(n9), .Y(\C856/net2257 ) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(net25013), .Y(\C856/net25055 ) );
  sky130_fd_sc_hd__nand2_1 U140 ( .A(net51601), .B(n4), .Y(net51641) );
  sky130_fd_sc_hd__nand2_1 U141 ( .A(net51653), .B(n4), .Y(net51693) );
  sky130_fd_sc_hd__nand2_1 U142 ( .A(n11), .B(n4), .Y(net51589) );
  sky130_fd_sc_hd__mux2i_1 U143 ( .A0(net51749), .A1(net55506), .S(net56186), 
        .Y(n192) );
  sky130_fd_sc_hd__mux2i_1 U144 ( .A0(n22), .A1(net55576), .S(net56186), .Y(
        n191) );
  sky130_fd_sc_hd__inv_2 U145 ( .A(net70626), .Y(net56186) );
  sky130_fd_sc_hd__inv_1 U146 ( .A(net70626), .Y(net56187) );
  sky130_fd_sc_hd__nand2_1 U147 ( .A(net64762), .B(net64761), .Y(net61482) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(net51713), .Y(net51554) );
  sky130_fd_sc_hd__inv_1 U149 ( .A(net63192), .Y(net63804) );
  sky130_fd_sc_hd__inv_1 U150 ( .A(net63192), .Y(net51653) );
  sky130_fd_sc_hd__inv_1 U151 ( .A(n410), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U152 ( .A(n410), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U153 ( .A(n410), .Y(n416) );
  sky130_fd_sc_hd__nand2_1 U154 ( .A(net51653), .B(net51554), .Y(n410) );
  sky130_fd_sc_hd__nand2_1 U155 ( .A(net63139), .B(n5), .Y(net51591) );
  sky130_fd_sc_hd__nand2_1 U156 ( .A(net58917), .B(net63153), .Y(net51543) );
  sky130_fd_sc_hd__nand2_1 U157 ( .A(n19), .B(net63153), .Y(net51702) );
  sky130_fd_sc_hd__nand2_1 U158 ( .A(net51601), .B(net63153), .Y(net51600) );
  sky130_fd_sc_hd__mux2i_1 U159 ( .A0(net51645), .A1(net55292), .S(n25), .Y(
        n130) );
  sky130_fd_sc_hd__mux2i_1 U160 ( .A0(n26), .A1(net55576), .S(n25), .Y(n125)
         );
  sky130_fd_sc_hd__nand2_1 U161 ( .A(net63804), .B(net63153), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U162 ( .A(n27), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U163 ( .A(n27), .Y(net59094) );
  sky130_fd_sc_hd__inv_1 U164 ( .A(n27), .Y(n28) );
  sky130_fd_sc_hd__dlygate4sd3_1 U165 ( .A(net62954), .X(net25014) );
  sky130_fd_sc_hd__nand2_1 U166 ( .A(net61482), .B(net58919), .Y(net61474) );
  sky130_fd_sc_hd__inv_1 U167 ( .A(net51761), .Y(net59432) );
  sky130_fd_sc_hd__inv_1 U168 ( .A(net51761), .Y(net59433) );
  sky130_fd_sc_hd__inv_1 U169 ( .A(net51761), .Y(net51755) );
  sky130_fd_sc_hd__inv_1 U170 ( .A(n448), .Y(n29) );
  sky130_fd_sc_hd__inv_1 U171 ( .A(n448), .Y(n30) );
  sky130_fd_sc_hd__inv_1 U172 ( .A(n448), .Y(n454) );
  sky130_fd_sc_hd__inv_1 U173 ( .A(n440), .Y(n31) );
  sky130_fd_sc_hd__inv_1 U174 ( .A(n440), .Y(n32) );
  sky130_fd_sc_hd__inv_1 U175 ( .A(n440), .Y(n446) );
  sky130_fd_sc_hd__inv_1 U176 ( .A(net51625), .Y(net59397) );
  sky130_fd_sc_hd__inv_1 U177 ( .A(net51625), .Y(net59398) );
  sky130_fd_sc_hd__inv_1 U178 ( .A(net51625), .Y(net51619) );
  sky130_fd_sc_hd__inv_2 U179 ( .A(net51642), .Y(net51601) );
  sky130_fd_sc_hd__inv_1 U180 ( .A(net25014), .Y(\C856/net25056 ) );
  sky130_fd_sc_hd__inv_1 U181 ( .A(n402), .Y(n33) );
  sky130_fd_sc_hd__inv_1 U182 ( .A(n402), .Y(n34) );
  sky130_fd_sc_hd__inv_1 U183 ( .A(n402), .Y(n408) );
  sky130_fd_sc_hd__inv_1 U184 ( .A(net51677), .Y(net58969) );
  sky130_fd_sc_hd__inv_1 U185 ( .A(net51677), .Y(net58970) );
  sky130_fd_sc_hd__inv_1 U186 ( .A(net51677), .Y(net51671) );
  sky130_fd_sc_hd__inv_1 U187 ( .A(net51685), .Y(net58964) );
  sky130_fd_sc_hd__inv_1 U188 ( .A(net51685), .Y(net58965) );
  sky130_fd_sc_hd__inv_1 U189 ( .A(net51685), .Y(net51679) );
  sky130_fd_sc_hd__inv_1 U190 ( .A(net51693), .Y(net58959) );
  sky130_fd_sc_hd__inv_1 U191 ( .A(net51693), .Y(net58960) );
  sky130_fd_sc_hd__inv_1 U192 ( .A(net51693), .Y(net51687) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(net51723), .Y(net51563) );
  sky130_fd_sc_hd__inv_1 U194 ( .A(net51589), .Y(net58910) );
  sky130_fd_sc_hd__inv_1 U195 ( .A(net51589), .Y(net58911) );
  sky130_fd_sc_hd__inv_1 U196 ( .A(net51589), .Y(net51583) );
  sky130_fd_sc_hd__inv_1 U197 ( .A(net51543), .Y(net58905) );
  sky130_fd_sc_hd__inv_1 U198 ( .A(net51543), .Y(net58906) );
  sky130_fd_sc_hd__inv_1 U199 ( .A(net51543), .Y(net51532) );
  sky130_fd_sc_hd__inv_1 U200 ( .A(net51633), .Y(net58896) );
  sky130_fd_sc_hd__inv_1 U201 ( .A(net51633), .Y(net58897) );
  sky130_fd_sc_hd__inv_1 U202 ( .A(net51633), .Y(net51627) );
  sky130_fd_sc_hd__inv_1 U203 ( .A(net51641), .Y(net58891) );
  sky130_fd_sc_hd__inv_1 U204 ( .A(net51641), .Y(net58892) );
  sky130_fd_sc_hd__nor2_1 U205 ( .A(\C856/net25056 ), .B(n20), .Y(n38) );
  sky130_fd_sc_hd__a22oi_1 U206 ( .A1(palette[152]), .A2(n312), .B1(
        palette[146]), .B2(n311), .Y(n43) );
  sky130_fd_sc_hd__a22oi_1 U207 ( .A1(palette[164]), .A2(n314), .B1(
        palette[158]), .B2(n313), .Y(n42) );
  sky130_fd_sc_hd__nor2_1 U208 ( .A(net25014), .B(n20), .Y(n39) );
  sky130_fd_sc_hd__a22oi_1 U209 ( .A1(palette[176]), .A2(\C856/net2133 ), .B1(
        palette[170]), .B2(\C856/net2134 ), .Y(n41) );
  sky130_fd_sc_hd__a22oi_1 U210 ( .A1(palette[188]), .A2(n316), .B1(
        palette[182]), .B2(n315), .Y(n40) );
  sky130_fd_sc_hd__nand4_1 U211 ( .A(n43), .B(n42), .C(n41), .D(n40), .Y(n51)
         );
  sky130_fd_sc_hd__a22oi_1 U212 ( .A1(palette[104]), .A2(n322), .B1(
        palette[98]), .B2(n321), .Y(n49) );
  sky130_fd_sc_hd__a22oi_1 U213 ( .A1(palette[116]), .A2(n324), .B1(
        palette[110]), .B2(n323), .Y(n48) );
  sky130_fd_sc_hd__a22oi_1 U214 ( .A1(palette[128]), .A2(n326), .B1(
        palette[122]), .B2(n325), .Y(n47) );
  sky130_fd_sc_hd__a22oi_1 U215 ( .A1(palette[140]), .A2(n328), .B1(
        palette[134]), .B2(n327), .Y(n46) );
  sky130_fd_sc_hd__nand4_1 U216 ( .A(n49), .B(n48), .C(n47), .D(n46), .Y(n50)
         );
  sky130_fd_sc_hd__nor2_1 U217 ( .A(n51), .B(n50), .Y(n213) );
  sky130_fd_sc_hd__a22oi_1 U218 ( .A1(palette[56]), .A2(n312), .B1(palette[50]), .B2(n311), .Y(n205) );
  sky130_fd_sc_hd__a22oi_1 U219 ( .A1(palette[68]), .A2(n314), .B1(palette[62]), .B2(n313), .Y(n204) );
  sky130_fd_sc_hd__a22oi_1 U220 ( .A1(palette[80]), .A2(\C856/net2133 ), .B1(
        palette[74]), .B2(\C856/net2134 ), .Y(n203) );
  sky130_fd_sc_hd__a22oi_1 U221 ( .A1(palette[92]), .A2(n316), .B1(palette[86]), .B2(n315), .Y(n52) );
  sky130_fd_sc_hd__nand4_1 U222 ( .A(n205), .B(n204), .C(n203), .D(n52), .Y(
        n211) );
  sky130_fd_sc_hd__a22oi_1 U223 ( .A1(palette[8]), .A2(n322), .B1(palette[2]), 
        .B2(n321), .Y(n209) );
  sky130_fd_sc_hd__a22oi_1 U224 ( .A1(palette[20]), .A2(n324), .B1(palette[14]), .B2(n323), .Y(n208) );
  sky130_fd_sc_hd__a22oi_1 U225 ( .A1(palette[32]), .A2(n326), .B1(palette[26]), .B2(n325), .Y(n207) );
  sky130_fd_sc_hd__a22oi_1 U226 ( .A1(palette[44]), .A2(n328), .B1(palette[38]), .B2(n327), .Y(n206) );
  sky130_fd_sc_hd__nand4_1 U227 ( .A(n209), .B(n208), .C(n207), .D(n206), .Y(
        n210) );
  sky130_fd_sc_hd__nor2_1 U228 ( .A(n211), .B(n210), .Y(n212) );
  sky130_fd_sc_hd__o22ai_1 U229 ( .A1(net25013), .A2(n213), .B1(
        \C856/net25055 ), .B2(n212), .Y(dout[2]) );
  sky130_fd_sc_hd__a22oi_1 U230 ( .A1(palette[153]), .A2(n312), .B1(
        palette[147]), .B2(n311), .Y(n217) );
  sky130_fd_sc_hd__a22oi_1 U231 ( .A1(palette[165]), .A2(n314), .B1(
        palette[159]), .B2(n313), .Y(n216) );
  sky130_fd_sc_hd__a22oi_1 U232 ( .A1(palette[177]), .A2(\C856/net2133 ), .B1(
        palette[171]), .B2(\C856/net2134 ), .Y(n215) );
  sky130_fd_sc_hd__a22oi_1 U233 ( .A1(palette[189]), .A2(n316), .B1(
        palette[183]), .B2(n315), .Y(n214) );
  sky130_fd_sc_hd__nand4_1 U234 ( .A(n217), .B(n216), .C(n215), .D(n214), .Y(
        n223) );
  sky130_fd_sc_hd__a22oi_1 U235 ( .A1(palette[105]), .A2(n322), .B1(
        palette[99]), .B2(n321), .Y(n221) );
  sky130_fd_sc_hd__a22oi_1 U236 ( .A1(palette[117]), .A2(n324), .B1(
        palette[111]), .B2(n323), .Y(n220) );
  sky130_fd_sc_hd__a22oi_1 U237 ( .A1(palette[129]), .A2(n326), .B1(
        palette[123]), .B2(n325), .Y(n219) );
  sky130_fd_sc_hd__a22oi_1 U238 ( .A1(palette[141]), .A2(n328), .B1(
        palette[135]), .B2(n327), .Y(n218) );
  sky130_fd_sc_hd__nand4_1 U239 ( .A(n221), .B(n220), .C(n219), .D(n218), .Y(
        n222) );
  sky130_fd_sc_hd__nor2_1 U240 ( .A(n223), .B(n222), .Y(n235) );
  sky130_fd_sc_hd__a22oi_1 U241 ( .A1(palette[57]), .A2(n312), .B1(palette[51]), .B2(n311), .Y(n227) );
  sky130_fd_sc_hd__a22oi_1 U242 ( .A1(palette[69]), .A2(n314), .B1(palette[63]), .B2(n313), .Y(n226) );
  sky130_fd_sc_hd__a22oi_1 U243 ( .A1(palette[81]), .A2(\C856/net2133 ), .B1(
        palette[75]), .B2(\C856/net2134 ), .Y(n225) );
  sky130_fd_sc_hd__a22oi_1 U244 ( .A1(palette[93]), .A2(n316), .B1(palette[87]), .B2(n315), .Y(n224) );
  sky130_fd_sc_hd__nand4_1 U245 ( .A(n227), .B(n226), .C(n225), .D(n224), .Y(
        n233) );
  sky130_fd_sc_hd__a22oi_1 U246 ( .A1(palette[9]), .A2(n322), .B1(palette[3]), 
        .B2(n321), .Y(n231) );
  sky130_fd_sc_hd__a22oi_1 U247 ( .A1(palette[21]), .A2(n324), .B1(palette[15]), .B2(n323), .Y(n230) );
  sky130_fd_sc_hd__a22oi_1 U248 ( .A1(palette[33]), .A2(n326), .B1(palette[27]), .B2(n325), .Y(n229) );
  sky130_fd_sc_hd__a22oi_1 U249 ( .A1(palette[45]), .A2(n328), .B1(palette[39]), .B2(n327), .Y(n228) );
  sky130_fd_sc_hd__nand4_1 U250 ( .A(n231), .B(n230), .C(n229), .D(n228), .Y(
        n232) );
  sky130_fd_sc_hd__nor2_1 U251 ( .A(n233), .B(n232), .Y(n234) );
  sky130_fd_sc_hd__o22ai_1 U252 ( .A1(net25013), .A2(n235), .B1(
        \C856/net25055 ), .B2(n234), .Y(dout[3]) );
  sky130_fd_sc_hd__a22oi_1 U253 ( .A1(palette[154]), .A2(n312), .B1(
        palette[148]), .B2(n311), .Y(n239) );
  sky130_fd_sc_hd__a22oi_1 U254 ( .A1(palette[166]), .A2(n314), .B1(
        palette[160]), .B2(n313), .Y(n238) );
  sky130_fd_sc_hd__a22oi_1 U255 ( .A1(palette[178]), .A2(\C856/net2133 ), .B1(
        palette[172]), .B2(\C856/net2134 ), .Y(n237) );
  sky130_fd_sc_hd__a22oi_1 U256 ( .A1(palette[190]), .A2(n316), .B1(
        palette[184]), .B2(n315), .Y(n236) );
  sky130_fd_sc_hd__nand4_1 U257 ( .A(n239), .B(n238), .C(n237), .D(n236), .Y(
        n245) );
  sky130_fd_sc_hd__a22oi_1 U258 ( .A1(palette[106]), .A2(n322), .B1(
        palette[100]), .B2(n321), .Y(n243) );
  sky130_fd_sc_hd__a22oi_1 U259 ( .A1(palette[118]), .A2(n324), .B1(
        palette[112]), .B2(n323), .Y(n242) );
  sky130_fd_sc_hd__a22oi_1 U260 ( .A1(palette[130]), .A2(n326), .B1(
        palette[124]), .B2(n325), .Y(n241) );
  sky130_fd_sc_hd__a22oi_1 U261 ( .A1(palette[142]), .A2(n328), .B1(
        palette[136]), .B2(n327), .Y(n240) );
  sky130_fd_sc_hd__nand4_1 U262 ( .A(n243), .B(n242), .C(n241), .D(n240), .Y(
        n244) );
  sky130_fd_sc_hd__nor2_1 U263 ( .A(n245), .B(n244), .Y(n257) );
  sky130_fd_sc_hd__a22oi_1 U264 ( .A1(palette[58]), .A2(n312), .B1(palette[52]), .B2(n311), .Y(n249) );
  sky130_fd_sc_hd__a22oi_1 U265 ( .A1(palette[70]), .A2(n314), .B1(palette[64]), .B2(n313), .Y(n248) );
  sky130_fd_sc_hd__a22oi_1 U266 ( .A1(palette[82]), .A2(\C856/net2133 ), .B1(
        palette[76]), .B2(\C856/net2134 ), .Y(n247) );
  sky130_fd_sc_hd__a22oi_1 U267 ( .A1(palette[94]), .A2(n316), .B1(palette[88]), .B2(n315), .Y(n246) );
  sky130_fd_sc_hd__nand4_1 U268 ( .A(n249), .B(n248), .C(n247), .D(n246), .Y(
        n255) );
  sky130_fd_sc_hd__a22oi_1 U269 ( .A1(palette[10]), .A2(n322), .B1(palette[4]), 
        .B2(n321), .Y(n253) );
  sky130_fd_sc_hd__a22oi_1 U270 ( .A1(palette[22]), .A2(n324), .B1(palette[16]), .B2(n323), .Y(n252) );
  sky130_fd_sc_hd__a22oi_1 U271 ( .A1(palette[34]), .A2(n326), .B1(palette[28]), .B2(n325), .Y(n251) );
  sky130_fd_sc_hd__a22oi_1 U272 ( .A1(palette[46]), .A2(n328), .B1(palette[40]), .B2(n327), .Y(n250) );
  sky130_fd_sc_hd__nand4_1 U273 ( .A(n253), .B(n252), .C(n251), .D(n250), .Y(
        n254) );
  sky130_fd_sc_hd__nor2_1 U274 ( .A(n255), .B(n254), .Y(n256) );
  sky130_fd_sc_hd__o22ai_1 U275 ( .A1(net25013), .A2(n257), .B1(
        \C856/net25055 ), .B2(n256), .Y(dout[4]) );
  sky130_fd_sc_hd__a22oi_1 U276 ( .A1(palette[155]), .A2(n312), .B1(
        palette[149]), .B2(n311), .Y(n261) );
  sky130_fd_sc_hd__a22oi_1 U277 ( .A1(palette[167]), .A2(n314), .B1(
        palette[161]), .B2(n313), .Y(n260) );
  sky130_fd_sc_hd__a22oi_1 U278 ( .A1(palette[179]), .A2(\C856/net2133 ), .B1(
        palette[173]), .B2(\C856/net2134 ), .Y(n259) );
  sky130_fd_sc_hd__a22oi_1 U279 ( .A1(palette[191]), .A2(n316), .B1(
        palette[185]), .B2(n315), .Y(n258) );
  sky130_fd_sc_hd__nand4_1 U280 ( .A(n261), .B(n260), .C(n259), .D(n258), .Y(
        n267) );
  sky130_fd_sc_hd__a22oi_1 U281 ( .A1(palette[107]), .A2(n322), .B1(
        palette[101]), .B2(n321), .Y(n265) );
  sky130_fd_sc_hd__a22oi_1 U282 ( .A1(palette[119]), .A2(n324), .B1(
        palette[113]), .B2(n323), .Y(n264) );
  sky130_fd_sc_hd__a22oi_1 U283 ( .A1(palette[131]), .A2(n326), .B1(
        palette[125]), .B2(n325), .Y(n263) );
  sky130_fd_sc_hd__a22oi_1 U284 ( .A1(palette[143]), .A2(n328), .B1(
        palette[137]), .B2(n327), .Y(n262) );
  sky130_fd_sc_hd__nand4_1 U285 ( .A(n265), .B(n264), .C(n263), .D(n262), .Y(
        n266) );
  sky130_fd_sc_hd__nor2_1 U286 ( .A(n267), .B(n266), .Y(n279) );
  sky130_fd_sc_hd__a22oi_1 U287 ( .A1(palette[59]), .A2(n312), .B1(palette[53]), .B2(n311), .Y(n271) );
  sky130_fd_sc_hd__a22oi_1 U288 ( .A1(palette[71]), .A2(n314), .B1(palette[65]), .B2(n313), .Y(n270) );
  sky130_fd_sc_hd__a22oi_1 U289 ( .A1(palette[83]), .A2(\C856/net2133 ), .B1(
        palette[77]), .B2(\C856/net2134 ), .Y(n269) );
  sky130_fd_sc_hd__a22oi_1 U290 ( .A1(palette[95]), .A2(n316), .B1(palette[89]), .B2(n315), .Y(n268) );
  sky130_fd_sc_hd__nand4_1 U291 ( .A(n271), .B(n270), .C(n269), .D(n268), .Y(
        n277) );
  sky130_fd_sc_hd__a22oi_1 U292 ( .A1(palette[11]), .A2(n322), .B1(palette[5]), 
        .B2(n321), .Y(n275) );
  sky130_fd_sc_hd__a22oi_1 U293 ( .A1(palette[23]), .A2(n324), .B1(palette[17]), .B2(n323), .Y(n274) );
  sky130_fd_sc_hd__a22oi_1 U294 ( .A1(palette[35]), .A2(n326), .B1(palette[29]), .B2(n325), .Y(n273) );
  sky130_fd_sc_hd__a22oi_1 U295 ( .A1(palette[47]), .A2(n328), .B1(palette[41]), .B2(n327), .Y(n272) );
  sky130_fd_sc_hd__nand4_1 U296 ( .A(n275), .B(n274), .C(n273), .D(n272), .Y(
        n276) );
  sky130_fd_sc_hd__nor2_1 U297 ( .A(n277), .B(n276), .Y(n278) );
  sky130_fd_sc_hd__o22ai_1 U298 ( .A1(net25013), .A2(n279), .B1(
        \C856/net25055 ), .B2(n278), .Y(dout[5]) );
  sky130_fd_sc_hd__a22oi_1 U299 ( .A1(palette[150]), .A2(n312), .B1(
        palette[144]), .B2(n311), .Y(n282) );
  sky130_fd_sc_hd__a22oi_1 U300 ( .A1(palette[162]), .A2(n314), .B1(
        palette[156]), .B2(n313), .Y(n281) );
  sky130_fd_sc_hd__a22oi_1 U301 ( .A1(palette[186]), .A2(n316), .B1(
        palette[180]), .B2(n315), .Y(n280) );
  sky130_fd_sc_hd__nand4_1 U302 ( .A(n282), .B(n281), .C(\C856/net2169 ), .D(
        n280), .Y(n288) );
  sky130_fd_sc_hd__a22oi_1 U303 ( .A1(palette[102]), .A2(n322), .B1(
        palette[96]), .B2(n321), .Y(n286) );
  sky130_fd_sc_hd__a22oi_1 U304 ( .A1(palette[114]), .A2(n324), .B1(
        palette[108]), .B2(n323), .Y(n285) );
  sky130_fd_sc_hd__a22oi_1 U305 ( .A1(palette[126]), .A2(n326), .B1(
        palette[120]), .B2(n325), .Y(n284) );
  sky130_fd_sc_hd__a22oi_1 U306 ( .A1(palette[138]), .A2(n328), .B1(
        palette[132]), .B2(n327), .Y(n283) );
  sky130_fd_sc_hd__nand4_1 U307 ( .A(n286), .B(n285), .C(n284), .D(n283), .Y(
        n287) );
  sky130_fd_sc_hd__nor2_1 U308 ( .A(n288), .B(n287), .Y(n300) );
  sky130_fd_sc_hd__a22oi_1 U309 ( .A1(palette[54]), .A2(n312), .B1(palette[48]), .B2(n311), .Y(n292) );
  sky130_fd_sc_hd__a22oi_1 U310 ( .A1(palette[66]), .A2(n314), .B1(palette[60]), .B2(n313), .Y(n291) );
  sky130_fd_sc_hd__a22oi_1 U311 ( .A1(palette[78]), .A2(\C856/net2133 ), .B1(
        palette[72]), .B2(\C856/net2134 ), .Y(n290) );
  sky130_fd_sc_hd__a22oi_1 U312 ( .A1(palette[90]), .A2(n316), .B1(palette[84]), .B2(n315), .Y(n289) );
  sky130_fd_sc_hd__nand4_1 U313 ( .A(n292), .B(n291), .C(n290), .D(n289), .Y(
        n298) );
  sky130_fd_sc_hd__a22oi_1 U314 ( .A1(palette[6]), .A2(n322), .B1(palette[0]), 
        .B2(n321), .Y(n296) );
  sky130_fd_sc_hd__a22oi_1 U315 ( .A1(palette[18]), .A2(n324), .B1(palette[12]), .B2(n323), .Y(n295) );
  sky130_fd_sc_hd__a22oi_1 U316 ( .A1(palette[30]), .A2(n326), .B1(palette[24]), .B2(n325), .Y(n294) );
  sky130_fd_sc_hd__a22oi_1 U317 ( .A1(palette[42]), .A2(n328), .B1(palette[36]), .B2(n327), .Y(n293) );
  sky130_fd_sc_hd__nand4_1 U318 ( .A(n296), .B(n295), .C(n294), .D(n293), .Y(
        n297) );
  sky130_fd_sc_hd__nor2_1 U319 ( .A(n298), .B(n297), .Y(n299) );
  sky130_fd_sc_hd__o22ai_1 U320 ( .A1(net25013), .A2(n300), .B1(
        \C856/net25055 ), .B2(n299), .Y(dout[0]) );
  sky130_fd_sc_hd__a22oi_1 U321 ( .A1(palette[151]), .A2(n312), .B1(
        palette[145]), .B2(n311), .Y(n304) );
  sky130_fd_sc_hd__a22oi_1 U322 ( .A1(palette[163]), .A2(n314), .B1(
        palette[157]), .B2(n313), .Y(n303) );
  sky130_fd_sc_hd__a22oi_1 U323 ( .A1(palette[175]), .A2(\C856/net2133 ), .B1(
        palette[169]), .B2(\C856/net2134 ), .Y(n302) );
  sky130_fd_sc_hd__a22oi_1 U324 ( .A1(palette[187]), .A2(n316), .B1(
        palette[181]), .B2(n315), .Y(n301) );
  sky130_fd_sc_hd__nand4_1 U325 ( .A(n304), .B(n303), .C(n302), .D(n301), .Y(
        n310) );
  sky130_fd_sc_hd__a22oi_1 U326 ( .A1(palette[103]), .A2(n322), .B1(
        palette[97]), .B2(n321), .Y(n308) );
  sky130_fd_sc_hd__a22oi_1 U327 ( .A1(palette[115]), .A2(n324), .B1(
        palette[109]), .B2(n323), .Y(n307) );
  sky130_fd_sc_hd__a22oi_1 U328 ( .A1(palette[127]), .A2(n326), .B1(
        palette[121]), .B2(n325), .Y(n306) );
  sky130_fd_sc_hd__a22oi_1 U329 ( .A1(palette[139]), .A2(n328), .B1(
        palette[133]), .B2(n327), .Y(n305) );
  sky130_fd_sc_hd__nand4_1 U330 ( .A(n308), .B(n307), .C(n306), .D(n305), .Y(
        n309) );
  sky130_fd_sc_hd__nor2_1 U331 ( .A(n310), .B(n309), .Y(n336) );
  sky130_fd_sc_hd__a22oi_1 U332 ( .A1(palette[55]), .A2(n312), .B1(palette[49]), .B2(n311), .Y(n320) );
  sky130_fd_sc_hd__a22oi_1 U333 ( .A1(palette[67]), .A2(n314), .B1(palette[61]), .B2(n313), .Y(n319) );
  sky130_fd_sc_hd__a22oi_1 U334 ( .A1(palette[79]), .A2(\C856/net2133 ), .B1(
        palette[73]), .B2(\C856/net2134 ), .Y(n318) );
  sky130_fd_sc_hd__a22oi_1 U335 ( .A1(palette[91]), .A2(n316), .B1(palette[85]), .B2(n315), .Y(n317) );
  sky130_fd_sc_hd__nand4_1 U336 ( .A(n320), .B(n319), .C(n318), .D(n317), .Y(
        n334) );
  sky130_fd_sc_hd__a22oi_1 U337 ( .A1(palette[7]), .A2(n322), .B1(palette[1]), 
        .B2(n321), .Y(n332) );
  sky130_fd_sc_hd__a22oi_1 U338 ( .A1(palette[19]), .A2(n324), .B1(palette[13]), .B2(n323), .Y(n331) );
  sky130_fd_sc_hd__a22oi_1 U339 ( .A1(palette[31]), .A2(n326), .B1(palette[25]), .B2(n325), .Y(n330) );
  sky130_fd_sc_hd__a22oi_1 U340 ( .A1(palette[43]), .A2(n328), .B1(palette[37]), .B2(n327), .Y(n329) );
  sky130_fd_sc_hd__nand4_1 U341 ( .A(n332), .B(n331), .C(n330), .D(n329), .Y(
        n333) );
  sky130_fd_sc_hd__nor2_1 U342 ( .A(n334), .B(n333), .Y(n335) );
  sky130_fd_sc_hd__o22ai_1 U343 ( .A1(net25013), .A2(n336), .B1(n335), .B2(
        \C856/net25055 ), .Y(dout[1]) );
  sky130_fd_sc_hd__inv_1 U344 ( .A(net51702), .Y(net56211) );
  sky130_fd_sc_hd__inv_1 U345 ( .A(net51702), .Y(net56212) );
  sky130_fd_sc_hd__inv_1 U346 ( .A(net51702), .Y(net51696) );
  sky130_fd_sc_hd__inv_1 U347 ( .A(n370), .Y(n337) );
  sky130_fd_sc_hd__inv_1 U348 ( .A(n370), .Y(n338) );
  sky130_fd_sc_hd__inv_1 U349 ( .A(n370), .Y(n376) );
  sky130_fd_sc_hd__inv_1 U350 ( .A(n362), .Y(n339) );
  sky130_fd_sc_hd__inv_1 U351 ( .A(n362), .Y(n340) );
  sky130_fd_sc_hd__inv_1 U352 ( .A(n362), .Y(n368) );
  sky130_fd_sc_hd__inv_1 U353 ( .A(palette[186]), .Y(n344) );
  sky130_fd_sc_hd__mux2i_1 U354 ( .A0(n344), .A1(net55576), .S(net59432), .Y(
        n197) );
  sky130_fd_sc_hd__inv_1 U355 ( .A(palette[187]), .Y(n345) );
  sky130_fd_sc_hd__mux2i_1 U356 ( .A0(n345), .A1(net55506), .S(net59433), .Y(
        n198) );
  sky130_fd_sc_hd__inv_1 U357 ( .A(palette[188]), .Y(n346) );
  sky130_fd_sc_hd__mux2i_1 U358 ( .A0(n346), .A1(n341), .S(net51755), .Y(n199)
         );
  sky130_fd_sc_hd__inv_1 U359 ( .A(palette[189]), .Y(n347) );
  sky130_fd_sc_hd__mux2i_1 U360 ( .A0(n347), .A1(n342), .S(net59433), .Y(n200)
         );
  sky130_fd_sc_hd__inv_1 U361 ( .A(palette[190]), .Y(n348) );
  sky130_fd_sc_hd__mux2i_1 U362 ( .A0(n348), .A1(n343), .S(net51755), .Y(n201)
         );
  sky130_fd_sc_hd__inv_1 U363 ( .A(palette[191]), .Y(n349) );
  sky130_fd_sc_hd__mux2i_1 U364 ( .A0(n349), .A1(net55292), .S(net59432), .Y(
        n202) );
  sky130_fd_sc_hd__inv_1 U365 ( .A(palette[181]), .Y(net51749) );
  sky130_fd_sc_hd__inv_1 U366 ( .A(palette[182]), .Y(n350) );
  sky130_fd_sc_hd__mux2i_1 U367 ( .A0(n350), .A1(n341), .S(net56187), .Y(n193)
         );
  sky130_fd_sc_hd__inv_1 U368 ( .A(palette[183]), .Y(n351) );
  sky130_fd_sc_hd__mux2i_1 U369 ( .A0(n351), .A1(n342), .S(net56186), .Y(n194)
         );
  sky130_fd_sc_hd__inv_1 U370 ( .A(palette[184]), .Y(n352) );
  sky130_fd_sc_hd__mux2i_1 U371 ( .A0(n352), .A1(n343), .S(net56187), .Y(n195)
         );
  sky130_fd_sc_hd__inv_1 U372 ( .A(palette[185]), .Y(n353) );
  sky130_fd_sc_hd__mux2i_1 U373 ( .A0(n353), .A1(net55292), .S(net56186), .Y(
        n196) );
  sky130_fd_sc_hd__inv_1 U374 ( .A(palette[175]), .Y(net51740) );
  sky130_fd_sc_hd__inv_1 U375 ( .A(palette[176]), .Y(n354) );
  sky130_fd_sc_hd__mux2i_1 U376 ( .A0(n354), .A1(n341), .S(net56192), .Y(n187)
         );
  sky130_fd_sc_hd__inv_1 U377 ( .A(palette[177]), .Y(n355) );
  sky130_fd_sc_hd__mux2i_1 U378 ( .A0(n355), .A1(n342), .S(net56191), .Y(n188)
         );
  sky130_fd_sc_hd__inv_1 U379 ( .A(palette[178]), .Y(n356) );
  sky130_fd_sc_hd__mux2i_1 U380 ( .A0(n356), .A1(n343), .S(net56192), .Y(n189)
         );
  sky130_fd_sc_hd__inv_1 U381 ( .A(palette[179]), .Y(n357) );
  sky130_fd_sc_hd__mux2i_1 U382 ( .A0(n357), .A1(net55292), .S(net56191), .Y(
        n190) );
  sky130_fd_sc_hd__inv_1 U383 ( .A(palette[169]), .Y(net51731) );
  sky130_fd_sc_hd__inv_1 U384 ( .A(palette[170]), .Y(n358) );
  sky130_fd_sc_hd__mux2i_1 U385 ( .A0(n358), .A1(n341), .S(net56197), .Y(n181)
         );
  sky130_fd_sc_hd__inv_1 U386 ( .A(palette[171]), .Y(n359) );
  sky130_fd_sc_hd__mux2i_1 U387 ( .A0(n359), .A1(n342), .S(net56196), .Y(n182)
         );
  sky130_fd_sc_hd__inv_1 U388 ( .A(palette[172]), .Y(n360) );
  sky130_fd_sc_hd__mux2i_1 U389 ( .A0(n360), .A1(n343), .S(net56197), .Y(n183)
         );
  sky130_fd_sc_hd__inv_1 U390 ( .A(palette[173]), .Y(n361) );
  sky130_fd_sc_hd__mux2i_1 U391 ( .A0(n361), .A1(net55292), .S(net56196), .Y(
        n184) );
  sky130_fd_sc_hd__inv_1 U392 ( .A(palette[156]), .Y(n363) );
  sky130_fd_sc_hd__nand2_1 U393 ( .A(n12), .B(net51563), .Y(n362) );
  sky130_fd_sc_hd__mux2i_1 U394 ( .A0(n363), .A1(net55576), .S(n368), .Y(n173)
         );
  sky130_fd_sc_hd__inv_1 U395 ( .A(palette[157]), .Y(n364) );
  sky130_fd_sc_hd__mux2i_1 U396 ( .A0(n364), .A1(net55506), .S(n368), .Y(n174)
         );
  sky130_fd_sc_hd__inv_1 U397 ( .A(palette[158]), .Y(n365) );
  sky130_fd_sc_hd__mux2i_1 U398 ( .A0(n365), .A1(n341), .S(n340), .Y(n175) );
  sky130_fd_sc_hd__inv_1 U399 ( .A(palette[159]), .Y(n366) );
  sky130_fd_sc_hd__mux2i_1 U400 ( .A0(n366), .A1(n342), .S(n339), .Y(n176) );
  sky130_fd_sc_hd__inv_1 U401 ( .A(palette[160]), .Y(n367) );
  sky130_fd_sc_hd__mux2i_1 U402 ( .A0(n367), .A1(n343), .S(n340), .Y(n177) );
  sky130_fd_sc_hd__inv_1 U403 ( .A(palette[161]), .Y(n369) );
  sky130_fd_sc_hd__mux2i_1 U404 ( .A0(n369), .A1(net55292), .S(n339), .Y(n178)
         );
  sky130_fd_sc_hd__inv_1 U405 ( .A(palette[150]), .Y(n371) );
  sky130_fd_sc_hd__nand2_1 U406 ( .A(n19), .B(net51554), .Y(n370) );
  sky130_fd_sc_hd__mux2i_1 U407 ( .A0(n371), .A1(net55576), .S(n376), .Y(n167)
         );
  sky130_fd_sc_hd__inv_1 U408 ( .A(palette[151]), .Y(n372) );
  sky130_fd_sc_hd__mux2i_1 U409 ( .A0(n372), .A1(net55506), .S(n376), .Y(n168)
         );
  sky130_fd_sc_hd__inv_1 U410 ( .A(palette[152]), .Y(n373) );
  sky130_fd_sc_hd__mux2i_1 U411 ( .A0(n373), .A1(n341), .S(n338), .Y(n169) );
  sky130_fd_sc_hd__inv_1 U412 ( .A(palette[153]), .Y(n374) );
  sky130_fd_sc_hd__mux2i_1 U413 ( .A0(n374), .A1(n342), .S(n337), .Y(n170) );
  sky130_fd_sc_hd__inv_1 U414 ( .A(palette[154]), .Y(n375) );
  sky130_fd_sc_hd__mux2i_1 U415 ( .A0(n375), .A1(n343), .S(n338), .Y(n171) );
  sky130_fd_sc_hd__inv_1 U416 ( .A(palette[155]), .Y(n377) );
  sky130_fd_sc_hd__mux2i_1 U417 ( .A0(n377), .A1(net55292), .S(n337), .Y(n172)
         );
  sky130_fd_sc_hd__inv_1 U418 ( .A(palette[144]), .Y(n378) );
  sky130_fd_sc_hd__mux2i_1 U419 ( .A0(n378), .A1(net55576), .S(net51696), .Y(
        n161) );
  sky130_fd_sc_hd__inv_1 U420 ( .A(palette[145]), .Y(n379) );
  sky130_fd_sc_hd__mux2i_1 U421 ( .A0(n379), .A1(net55506), .S(net51696), .Y(
        n162) );
  sky130_fd_sc_hd__inv_1 U422 ( .A(palette[146]), .Y(n380) );
  sky130_fd_sc_hd__mux2i_1 U423 ( .A0(n380), .A1(n341), .S(net56212), .Y(n163)
         );
  sky130_fd_sc_hd__inv_1 U424 ( .A(palette[147]), .Y(n381) );
  sky130_fd_sc_hd__mux2i_1 U425 ( .A0(n381), .A1(n342), .S(net56211), .Y(n164)
         );
  sky130_fd_sc_hd__inv_1 U426 ( .A(palette[148]), .Y(n382) );
  sky130_fd_sc_hd__mux2i_1 U427 ( .A0(n382), .A1(n343), .S(net56212), .Y(n165)
         );
  sky130_fd_sc_hd__inv_1 U428 ( .A(palette[149]), .Y(n383) );
  sky130_fd_sc_hd__mux2i_1 U429 ( .A0(n383), .A1(net55292), .S(net56211), .Y(
        n166) );
  sky130_fd_sc_hd__inv_1 U430 ( .A(palette[132]), .Y(n384) );
  sky130_fd_sc_hd__mux2i_1 U431 ( .A0(n384), .A1(net55576), .S(net51687), .Y(
        n155) );
  sky130_fd_sc_hd__inv_1 U432 ( .A(palette[133]), .Y(n385) );
  sky130_fd_sc_hd__mux2i_1 U433 ( .A0(n385), .A1(net55506), .S(net51687), .Y(
        n156) );
  sky130_fd_sc_hd__inv_1 U434 ( .A(palette[134]), .Y(n386) );
  sky130_fd_sc_hd__mux2i_1 U435 ( .A0(n386), .A1(n341), .S(net58960), .Y(n157)
         );
  sky130_fd_sc_hd__inv_1 U436 ( .A(palette[135]), .Y(n387) );
  sky130_fd_sc_hd__mux2i_1 U437 ( .A0(n387), .A1(n342), .S(net58959), .Y(n158)
         );
  sky130_fd_sc_hd__inv_1 U438 ( .A(palette[136]), .Y(n388) );
  sky130_fd_sc_hd__mux2i_1 U439 ( .A0(n388), .A1(n343), .S(net58960), .Y(n159)
         );
  sky130_fd_sc_hd__inv_1 U440 ( .A(palette[137]), .Y(n389) );
  sky130_fd_sc_hd__mux2i_1 U441 ( .A0(n389), .A1(net55292), .S(net58959), .Y(
        n160) );
  sky130_fd_sc_hd__inv_1 U442 ( .A(palette[126]), .Y(n390) );
  sky130_fd_sc_hd__mux2i_1 U443 ( .A0(n390), .A1(net55576), .S(net51679), .Y(
        n149) );
  sky130_fd_sc_hd__inv_1 U444 ( .A(palette[127]), .Y(n391) );
  sky130_fd_sc_hd__mux2i_1 U445 ( .A0(n391), .A1(net55506), .S(net51679), .Y(
        n150) );
  sky130_fd_sc_hd__inv_1 U446 ( .A(palette[128]), .Y(n392) );
  sky130_fd_sc_hd__mux2i_1 U447 ( .A0(n392), .A1(n341), .S(net58965), .Y(n151)
         );
  sky130_fd_sc_hd__inv_1 U448 ( .A(palette[129]), .Y(n393) );
  sky130_fd_sc_hd__mux2i_1 U449 ( .A0(n393), .A1(n342), .S(net58964), .Y(n152)
         );
  sky130_fd_sc_hd__inv_1 U450 ( .A(palette[130]), .Y(n394) );
  sky130_fd_sc_hd__mux2i_1 U451 ( .A0(n394), .A1(n343), .S(net58965), .Y(n153)
         );
  sky130_fd_sc_hd__inv_1 U452 ( .A(palette[131]), .Y(n395) );
  sky130_fd_sc_hd__mux2i_1 U453 ( .A0(n395), .A1(net55292), .S(net58964), .Y(
        n154) );
  sky130_fd_sc_hd__inv_1 U454 ( .A(palette[120]), .Y(n396) );
  sky130_fd_sc_hd__mux2i_1 U455 ( .A0(n396), .A1(net55576), .S(net51671), .Y(
        n143) );
  sky130_fd_sc_hd__inv_1 U456 ( .A(palette[121]), .Y(n397) );
  sky130_fd_sc_hd__mux2i_1 U457 ( .A0(n397), .A1(net55506), .S(net51671), .Y(
        n144) );
  sky130_fd_sc_hd__inv_1 U458 ( .A(palette[122]), .Y(n398) );
  sky130_fd_sc_hd__mux2i_1 U459 ( .A0(n398), .A1(n341), .S(net58970), .Y(n145)
         );
  sky130_fd_sc_hd__inv_1 U460 ( .A(palette[123]), .Y(n399) );
  sky130_fd_sc_hd__mux2i_1 U461 ( .A0(n399), .A1(n342), .S(net58969), .Y(n146)
         );
  sky130_fd_sc_hd__inv_1 U462 ( .A(palette[124]), .Y(n400) );
  sky130_fd_sc_hd__mux2i_1 U463 ( .A0(n400), .A1(n343), .S(net58970), .Y(n147)
         );
  sky130_fd_sc_hd__inv_1 U464 ( .A(palette[125]), .Y(n401) );
  sky130_fd_sc_hd__mux2i_1 U465 ( .A0(n401), .A1(net55292), .S(net58969), .Y(
        n148) );
  sky130_fd_sc_hd__inv_1 U466 ( .A(palette[108]), .Y(n403) );
  sky130_fd_sc_hd__nand2_1 U467 ( .A(net63804), .B(net51563), .Y(n402) );
  sky130_fd_sc_hd__mux2i_1 U468 ( .A0(n403), .A1(net55576), .S(n408), .Y(n137)
         );
  sky130_fd_sc_hd__inv_1 U469 ( .A(palette[109]), .Y(n404) );
  sky130_fd_sc_hd__mux2i_1 U470 ( .A0(n404), .A1(net55506), .S(n408), .Y(n138)
         );
  sky130_fd_sc_hd__inv_1 U471 ( .A(palette[110]), .Y(n405) );
  sky130_fd_sc_hd__mux2i_1 U472 ( .A0(n405), .A1(n341), .S(n34), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U473 ( .A(palette[111]), .Y(n406) );
  sky130_fd_sc_hd__mux2i_1 U474 ( .A0(n406), .A1(n342), .S(n33), .Y(n140) );
  sky130_fd_sc_hd__inv_1 U475 ( .A(palette[112]), .Y(n407) );
  sky130_fd_sc_hd__mux2i_1 U476 ( .A0(n407), .A1(n343), .S(n34), .Y(n141) );
  sky130_fd_sc_hd__inv_1 U477 ( .A(palette[113]), .Y(n409) );
  sky130_fd_sc_hd__mux2i_1 U478 ( .A0(n409), .A1(net55292), .S(n33), .Y(n142)
         );
  sky130_fd_sc_hd__inv_1 U479 ( .A(palette[102]), .Y(n411) );
  sky130_fd_sc_hd__mux2i_1 U480 ( .A0(n411), .A1(net55576), .S(n416), .Y(n131)
         );
  sky130_fd_sc_hd__inv_1 U481 ( .A(palette[103]), .Y(n412) );
  sky130_fd_sc_hd__mux2i_1 U482 ( .A0(n412), .A1(net55506), .S(n416), .Y(n132)
         );
  sky130_fd_sc_hd__inv_1 U483 ( .A(palette[104]), .Y(n413) );
  sky130_fd_sc_hd__mux2i_1 U484 ( .A0(n413), .A1(n341), .S(n24), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U485 ( .A(palette[105]), .Y(n414) );
  sky130_fd_sc_hd__mux2i_1 U486 ( .A0(n414), .A1(n342), .S(n24), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U487 ( .A(palette[106]), .Y(n415) );
  sky130_fd_sc_hd__mux2i_1 U488 ( .A0(n415), .A1(n343), .S(n23), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U489 ( .A(palette[107]), .Y(n417) );
  sky130_fd_sc_hd__mux2i_1 U490 ( .A0(n417), .A1(net55292), .S(n23), .Y(n136)
         );
  sky130_fd_sc_hd__inv_1 U491 ( .A(palette[97]), .Y(n418) );
  sky130_fd_sc_hd__mux2i_1 U492 ( .A0(n418), .A1(net55506), .S(net59094), .Y(
        n126) );
  sky130_fd_sc_hd__inv_1 U493 ( .A(palette[98]), .Y(n419) );
  sky130_fd_sc_hd__mux2i_1 U494 ( .A0(n419), .A1(n341), .S(n28), .Y(n127) );
  sky130_fd_sc_hd__inv_1 U495 ( .A(palette[99]), .Y(n420) );
  sky130_fd_sc_hd__mux2i_1 U496 ( .A0(n420), .A1(n342), .S(n28), .Y(n128) );
  sky130_fd_sc_hd__inv_1 U497 ( .A(palette[100]), .Y(n421) );
  sky130_fd_sc_hd__mux2i_1 U498 ( .A0(n421), .A1(n343), .S(net59094), .Y(n129)
         );
  sky130_fd_sc_hd__inv_1 U499 ( .A(palette[101]), .Y(net51645) );
  sky130_fd_sc_hd__inv_1 U500 ( .A(palette[84]), .Y(n422) );
  sky130_fd_sc_hd__mux2i_1 U501 ( .A0(n422), .A1(net55576), .S(net51635), .Y(
        n119) );
  sky130_fd_sc_hd__inv_1 U502 ( .A(palette[85]), .Y(n423) );
  sky130_fd_sc_hd__mux2i_1 U503 ( .A0(n423), .A1(net55506), .S(net58892), .Y(
        n120) );
  sky130_fd_sc_hd__inv_1 U504 ( .A(palette[86]), .Y(n424) );
  sky130_fd_sc_hd__mux2i_1 U505 ( .A0(n424), .A1(n341), .S(net58891), .Y(n121)
         );
  sky130_fd_sc_hd__inv_1 U506 ( .A(palette[87]), .Y(n425) );
  sky130_fd_sc_hd__mux2i_1 U507 ( .A0(n425), .A1(n342), .S(net58892), .Y(n122)
         );
  sky130_fd_sc_hd__inv_1 U508 ( .A(palette[88]), .Y(n426) );
  sky130_fd_sc_hd__mux2i_1 U509 ( .A0(n426), .A1(n343), .S(net51635), .Y(n123)
         );
  sky130_fd_sc_hd__inv_1 U510 ( .A(palette[89]), .Y(n427) );
  sky130_fd_sc_hd__mux2i_1 U511 ( .A0(n427), .A1(net55292), .S(net58891), .Y(
        n124) );
  sky130_fd_sc_hd__inv_1 U512 ( .A(palette[78]), .Y(n428) );
  sky130_fd_sc_hd__mux2i_1 U513 ( .A0(n428), .A1(net55576), .S(net51627), .Y(
        n113) );
  sky130_fd_sc_hd__inv_1 U514 ( .A(palette[79]), .Y(n429) );
  sky130_fd_sc_hd__mux2i_1 U515 ( .A0(n429), .A1(net55506), .S(net58897), .Y(
        n114) );
  sky130_fd_sc_hd__inv_1 U516 ( .A(palette[80]), .Y(n430) );
  sky130_fd_sc_hd__mux2i_1 U517 ( .A0(n430), .A1(n341), .S(net58896), .Y(n115)
         );
  sky130_fd_sc_hd__inv_1 U518 ( .A(palette[81]), .Y(n431) );
  sky130_fd_sc_hd__mux2i_1 U519 ( .A0(n431), .A1(n342), .S(net58897), .Y(n116)
         );
  sky130_fd_sc_hd__inv_1 U520 ( .A(palette[82]), .Y(n432) );
  sky130_fd_sc_hd__mux2i_1 U521 ( .A0(n432), .A1(n343), .S(net58896), .Y(n117)
         );
  sky130_fd_sc_hd__inv_1 U522 ( .A(palette[83]), .Y(n433) );
  sky130_fd_sc_hd__mux2i_1 U523 ( .A0(n433), .A1(net55292), .S(net51627), .Y(
        n118) );
  sky130_fd_sc_hd__inv_1 U524 ( .A(palette[72]), .Y(n434) );
  sky130_fd_sc_hd__mux2i_1 U525 ( .A0(n434), .A1(net55576), .S(net51619), .Y(
        n107) );
  sky130_fd_sc_hd__inv_1 U526 ( .A(palette[73]), .Y(n435) );
  sky130_fd_sc_hd__mux2i_1 U527 ( .A0(n435), .A1(net55506), .S(net51619), .Y(
        n108) );
  sky130_fd_sc_hd__inv_1 U528 ( .A(palette[74]), .Y(n436) );
  sky130_fd_sc_hd__mux2i_1 U529 ( .A0(n436), .A1(n341), .S(net59398), .Y(n109)
         );
  sky130_fd_sc_hd__inv_1 U530 ( .A(palette[75]), .Y(n437) );
  sky130_fd_sc_hd__mux2i_1 U531 ( .A0(n437), .A1(n342), .S(net59397), .Y(n110)
         );
  sky130_fd_sc_hd__inv_1 U532 ( .A(palette[76]), .Y(n438) );
  sky130_fd_sc_hd__mux2i_1 U533 ( .A0(n438), .A1(n343), .S(net59398), .Y(n111)
         );
  sky130_fd_sc_hd__inv_1 U534 ( .A(palette[77]), .Y(n439) );
  sky130_fd_sc_hd__mux2i_1 U535 ( .A0(n439), .A1(net55292), .S(net59397), .Y(
        n112) );
  sky130_fd_sc_hd__inv_1 U536 ( .A(palette[60]), .Y(n441) );
  sky130_fd_sc_hd__nand2_1 U537 ( .A(net51601), .B(net51563), .Y(n440) );
  sky130_fd_sc_hd__mux2i_1 U538 ( .A0(n441), .A1(net55576), .S(n446), .Y(n101)
         );
  sky130_fd_sc_hd__inv_1 U539 ( .A(palette[61]), .Y(n442) );
  sky130_fd_sc_hd__mux2i_1 U540 ( .A0(n442), .A1(net55506), .S(n446), .Y(n102)
         );
  sky130_fd_sc_hd__inv_1 U541 ( .A(palette[62]), .Y(n443) );
  sky130_fd_sc_hd__mux2i_1 U542 ( .A0(n443), .A1(n341), .S(n32), .Y(n103) );
  sky130_fd_sc_hd__inv_1 U543 ( .A(palette[63]), .Y(n444) );
  sky130_fd_sc_hd__mux2i_1 U544 ( .A0(n444), .A1(n342), .S(n31), .Y(n104) );
  sky130_fd_sc_hd__inv_1 U545 ( .A(palette[64]), .Y(n445) );
  sky130_fd_sc_hd__mux2i_1 U546 ( .A0(n445), .A1(n343), .S(n32), .Y(n105) );
  sky130_fd_sc_hd__inv_1 U547 ( .A(palette[65]), .Y(n447) );
  sky130_fd_sc_hd__mux2i_1 U548 ( .A0(n447), .A1(net55292), .S(n31), .Y(n106)
         );
  sky130_fd_sc_hd__inv_1 U549 ( .A(palette[54]), .Y(n449) );
  sky130_fd_sc_hd__nand2_1 U550 ( .A(net51601), .B(net51554), .Y(n448) );
  sky130_fd_sc_hd__mux2i_1 U551 ( .A0(n449), .A1(net55576), .S(n454), .Y(n95)
         );
  sky130_fd_sc_hd__inv_1 U552 ( .A(palette[55]), .Y(n450) );
  sky130_fd_sc_hd__mux2i_1 U553 ( .A0(n450), .A1(net55506), .S(n454), .Y(n96)
         );
  sky130_fd_sc_hd__inv_1 U554 ( .A(palette[56]), .Y(n451) );
  sky130_fd_sc_hd__mux2i_1 U555 ( .A0(n451), .A1(n341), .S(n30), .Y(n97) );
  sky130_fd_sc_hd__inv_1 U556 ( .A(palette[57]), .Y(n452) );
  sky130_fd_sc_hd__mux2i_1 U557 ( .A0(n452), .A1(n342), .S(n29), .Y(n98) );
  sky130_fd_sc_hd__inv_1 U558 ( .A(palette[58]), .Y(n453) );
  sky130_fd_sc_hd__mux2i_1 U559 ( .A0(n453), .A1(n343), .S(n30), .Y(n99) );
  sky130_fd_sc_hd__inv_1 U560 ( .A(palette[59]), .Y(n455) );
  sky130_fd_sc_hd__mux2i_1 U561 ( .A0(n455), .A1(net55292), .S(n29), .Y(n100)
         );
  sky130_fd_sc_hd__inv_1 U562 ( .A(palette[48]), .Y(n456) );
  sky130_fd_sc_hd__mux2i_1 U563 ( .A0(n456), .A1(net55576), .S(net51594), .Y(
        n89) );
  sky130_fd_sc_hd__inv_1 U564 ( .A(palette[49]), .Y(n457) );
  sky130_fd_sc_hd__mux2i_1 U565 ( .A0(n457), .A1(net55506), .S(net51594), .Y(
        n90) );
  sky130_fd_sc_hd__inv_1 U566 ( .A(palette[50]), .Y(n458) );
  sky130_fd_sc_hd__mux2i_1 U567 ( .A0(n458), .A1(n341), .S(net51594), .Y(n91)
         );
  sky130_fd_sc_hd__inv_1 U568 ( .A(palette[51]), .Y(n459) );
  sky130_fd_sc_hd__mux2i_1 U569 ( .A0(n459), .A1(n342), .S(n2), .Y(n92) );
  sky130_fd_sc_hd__inv_1 U570 ( .A(palette[52]), .Y(n460) );
  sky130_fd_sc_hd__mux2i_1 U571 ( .A0(n460), .A1(n343), .S(n2), .Y(n93) );
  sky130_fd_sc_hd__inv_1 U572 ( .A(palette[53]), .Y(n461) );
  sky130_fd_sc_hd__mux2i_1 U573 ( .A0(n461), .A1(net55292), .S(n1), .Y(n94) );
  sky130_fd_sc_hd__inv_1 U574 ( .A(palette[36]), .Y(n462) );
  sky130_fd_sc_hd__mux2i_1 U575 ( .A0(n462), .A1(net55576), .S(net51583), .Y(
        n83) );
  sky130_fd_sc_hd__inv_1 U576 ( .A(palette[37]), .Y(n463) );
  sky130_fd_sc_hd__mux2i_1 U577 ( .A0(n463), .A1(net55506), .S(net58911), .Y(
        n84) );
  sky130_fd_sc_hd__inv_1 U578 ( .A(palette[38]), .Y(n464) );
  sky130_fd_sc_hd__mux2i_1 U579 ( .A0(n464), .A1(n341), .S(net58910), .Y(n85)
         );
  sky130_fd_sc_hd__inv_1 U580 ( .A(palette[39]), .Y(n465) );
  sky130_fd_sc_hd__mux2i_1 U581 ( .A0(n465), .A1(n342), .S(net58911), .Y(n86)
         );
  sky130_fd_sc_hd__inv_1 U582 ( .A(palette[40]), .Y(n466) );
  sky130_fd_sc_hd__mux2i_1 U583 ( .A0(n466), .A1(n343), .S(net58910), .Y(n87)
         );
  sky130_fd_sc_hd__inv_1 U584 ( .A(palette[41]), .Y(n467) );
  sky130_fd_sc_hd__mux2i_1 U585 ( .A0(n467), .A1(net55292), .S(net51583), .Y(
        n88) );
  sky130_fd_sc_hd__inv_1 U586 ( .A(palette[30]), .Y(n468) );
  sky130_fd_sc_hd__mux2i_1 U587 ( .A0(n468), .A1(net55576), .S(net51574), .Y(
        n77) );
  sky130_fd_sc_hd__inv_1 U588 ( .A(palette[31]), .Y(n469) );
  sky130_fd_sc_hd__mux2i_1 U589 ( .A0(n469), .A1(net55506), .S(net51574), .Y(
        n78) );
  sky130_fd_sc_hd__inv_1 U590 ( .A(palette[32]), .Y(n470) );
  sky130_fd_sc_hd__mux2i_1 U591 ( .A0(n470), .A1(n341), .S(n18), .Y(n79) );
  sky130_fd_sc_hd__inv_1 U592 ( .A(palette[33]), .Y(n471) );
  sky130_fd_sc_hd__mux2i_1 U593 ( .A0(n471), .A1(n342), .S(n17), .Y(n80) );
  sky130_fd_sc_hd__inv_1 U594 ( .A(palette[34]), .Y(n472) );
  sky130_fd_sc_hd__mux2i_1 U595 ( .A0(n472), .A1(n343), .S(n18), .Y(n81) );
  sky130_fd_sc_hd__inv_1 U596 ( .A(palette[35]), .Y(n473) );
  sky130_fd_sc_hd__mux2i_1 U597 ( .A0(n473), .A1(net55292), .S(n17), .Y(n82)
         );
  sky130_fd_sc_hd__inv_1 U598 ( .A(palette[24]), .Y(n474) );
  sky130_fd_sc_hd__mux2i_1 U599 ( .A0(n474), .A1(net55576), .S(net51565), .Y(
        n71) );
  sky130_fd_sc_hd__inv_1 U600 ( .A(palette[25]), .Y(n475) );
  sky130_fd_sc_hd__mux2i_1 U601 ( .A0(n475), .A1(net55506), .S(net51565), .Y(
        n72) );
  sky130_fd_sc_hd__inv_1 U602 ( .A(palette[26]), .Y(n476) );
  sky130_fd_sc_hd__mux2i_1 U603 ( .A0(n476), .A1(n341), .S(net51565), .Y(n73)
         );
  sky130_fd_sc_hd__inv_1 U604 ( .A(palette[27]), .Y(n477) );
  sky130_fd_sc_hd__mux2i_1 U605 ( .A0(n477), .A1(n342), .S(net51565), .Y(n74)
         );
  sky130_fd_sc_hd__inv_1 U606 ( .A(palette[28]), .Y(n478) );
  sky130_fd_sc_hd__mux2i_1 U607 ( .A0(n478), .A1(n343), .S(net58950), .Y(n75)
         );
  sky130_fd_sc_hd__inv_1 U608 ( .A(palette[29]), .Y(n479) );
  sky130_fd_sc_hd__mux2i_1 U609 ( .A0(n479), .A1(net55292), .S(net58950), .Y(
        n76) );
  sky130_fd_sc_hd__inv_1 U610 ( .A(palette[12]), .Y(n481) );
  sky130_fd_sc_hd__inv_1 U611 ( .A(palette[13]), .Y(n482) );
  sky130_fd_sc_hd__mux2i_1 U612 ( .A0(n482), .A1(net55506), .S(n486), .Y(n66)
         );
  sky130_fd_sc_hd__inv_1 U613 ( .A(palette[14]), .Y(n483) );
  sky130_fd_sc_hd__mux2i_1 U614 ( .A0(n483), .A1(n341), .S(n486), .Y(n67) );
  sky130_fd_sc_hd__inv_1 U615 ( .A(palette[15]), .Y(n484) );
  sky130_fd_sc_hd__mux2i_1 U616 ( .A0(n484), .A1(n342), .S(n486), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U617 ( .A(palette[16]), .Y(n485) );
  sky130_fd_sc_hd__mux2i_1 U618 ( .A0(n485), .A1(n343), .S(n37), .Y(n69) );
  sky130_fd_sc_hd__inv_1 U619 ( .A(palette[17]), .Y(n487) );
  sky130_fd_sc_hd__mux2i_1 U620 ( .A0(n487), .A1(net55292), .S(n37), .Y(n70)
         );
  sky130_fd_sc_hd__inv_1 U621 ( .A(palette[6]), .Y(n489) );
  sky130_fd_sc_hd__mux2i_1 U622 ( .A0(n489), .A1(net55576), .S(n494), .Y(n59)
         );
  sky130_fd_sc_hd__inv_1 U623 ( .A(palette[7]), .Y(n490) );
  sky130_fd_sc_hd__mux2i_1 U624 ( .A0(n490), .A1(net55506), .S(n494), .Y(n60)
         );
  sky130_fd_sc_hd__inv_1 U625 ( .A(palette[8]), .Y(n491) );
  sky130_fd_sc_hd__mux2i_1 U626 ( .A0(n491), .A1(n341), .S(n36), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U627 ( .A(palette[9]), .Y(n492) );
  sky130_fd_sc_hd__mux2i_1 U628 ( .A0(n492), .A1(n342), .S(n35), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U629 ( .A(palette[10]), .Y(n493) );
  sky130_fd_sc_hd__mux2i_1 U630 ( .A0(n493), .A1(n343), .S(n36), .Y(n63) );
  sky130_fd_sc_hd__inv_1 U631 ( .A(palette[11]), .Y(n495) );
  sky130_fd_sc_hd__mux2i_1 U632 ( .A0(n495), .A1(net55292), .S(n35), .Y(n64)
         );
  sky130_fd_sc_hd__inv_1 U633 ( .A(palette[0]), .Y(n496) );
  sky130_fd_sc_hd__mux2i_1 U634 ( .A0(n496), .A1(net55576), .S(net51532), .Y(
        n53) );
  sky130_fd_sc_hd__inv_1 U635 ( .A(palette[1]), .Y(n497) );
  sky130_fd_sc_hd__mux2i_1 U636 ( .A0(n497), .A1(net55506), .S(net58906), .Y(
        n54) );
  sky130_fd_sc_hd__inv_1 U637 ( .A(palette[2]), .Y(n498) );
  sky130_fd_sc_hd__mux2i_1 U638 ( .A0(n498), .A1(n341), .S(net58905), .Y(n55)
         );
  sky130_fd_sc_hd__inv_1 U639 ( .A(palette[3]), .Y(n499) );
  sky130_fd_sc_hd__mux2i_1 U640 ( .A0(n499), .A1(n342), .S(net58906), .Y(n56)
         );
  sky130_fd_sc_hd__inv_1 U641 ( .A(palette[4]), .Y(n500) );
  sky130_fd_sc_hd__mux2i_1 U642 ( .A0(n500), .A1(n343), .S(net58905), .Y(n57)
         );
  sky130_fd_sc_hd__inv_1 U643 ( .A(palette[5]), .Y(n501) );
  sky130_fd_sc_hd__mux2i_1 U644 ( .A0(n501), .A1(net55292), .S(net51532), .Y(
        n58) );
endmodule


module PPU ( clk, ce, reset, color, din, dout, ain, read, write, nmi, vram_r, 
        vram_w, vram_a, vram_din, vram_dout, scanline, cycle, mapper_ppu_flags
 );
  output [5:0] color;
  input [7:0] din;
  output [7:0] dout;
  input [2:0] ain;
  output [13:0] vram_a;
  input [7:0] vram_din;
  output [7:0] vram_dout;
  output [8:0] scanline;
  output [8:0] cycle;
  output [19:0] mapper_ppu_flags;
  input clk, ce, reset, read, write;
  output nmi, vram_r, vram_w;
  wire   enable_playfield, enable_objects, is_in_vblank, end_of_line,
         at_last_cycle_group, exiting_vblank, entering_vblank,
         is_pre_render_line, playfield_clip, \bg_pixel[1] , before_line,
         n_1_net_, n_2_net_, sprite_overflow, obj0_on_line, n_3_net_, obj_patt,
         is_obj0_pixel, object_clip, sprite0_hit_bg, pixel_is_obj, n_5_net__4_,
         n_5_net__3_, n_5_net__2_, n_5_net__1_, n_5_net__0_, n_6_net_,
         vbl_enable, nmi_occured, vram_read_delayed, n29, n30, n32, n33, n34,
         n35, n36, n37, n45, n52, n53, n63, n64, n65, n68, n74, n76, n77, n80,
         n81, n82, n84, n86, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n110, n111, net24606, net24612,
         net24614, net35814, net55016, net55027, net55030, net55037, net55048,
         net55049, net55051, net55052, net55056, net55057, net55059, net55065,
         net55066, net63736, net63728, net63711, net69646, net69627, net69588,
         net61522, net55067, net55061, net55060, net55047, n112, n113, n114,
         n115, n116, n117, n118, n119, n120, n121, n122, n123, n124, n125,
         n126, n127, n128, n129, n130, n131, n132, n133, n134, n135, n136,
         n137, n138, n139, n140, n141, n142, n143, n144, n145, n146, n147,
         n148, n149, n150, n151, n152, n153, n154, n155, n156, n157, n158,
         n159, n160, n161, n162, n163, n164, n165, n166, n167, n168, n169,
         n170, n171, n172, n173, n174, n175, n176, n177, n178, n179, n185,
         n186, n187, n188, n189, n190, n191, n192, n193, n194, n195, n196,
         n197, n198;
  wire   [14:0] loopy;
  wire   [2:0] fine_x_scroll;
  wire   [7:0] bg_name_table;
  wire   [3:0] bg_pixel_noblank;
  wire   [7:0] oam_bus;
  wire   [12:0] sprite_vram_addr;
  wire   [3:0] spriteset_load;
  wire   [26:0] spriteset_load_in;
  wire   [4:0] obj_pixel_noblank;
  wire   [1:0] obj_pixel;
  wire   [3:0] pixel;
  wire   [3:0] color2;
  wire   [7:0] vram_latch;
  assign vram_dout[7] = din[7];
  assign vram_dout[6] = din[6];
  assign vram_dout[5] = din[5];
  assign vram_dout[4] = din[4];
  assign vram_dout[3] = din[3];
  assign vram_dout[2] = din[2];
  assign vram_dout[1] = din[1];
  assign vram_dout[0] = din[0];
  assign mapper_ppu_flags[19] = scanline[8];
  assign mapper_ppu_flags[18] = scanline[7];
  assign mapper_ppu_flags[17] = scanline[6];
  assign mapper_ppu_flags[16] = scanline[5];
  assign mapper_ppu_flags[15] = scanline[4];
  assign mapper_ppu_flags[14] = scanline[3];
  assign mapper_ppu_flags[13] = scanline[2];
  assign mapper_ppu_flags[12] = scanline[1];
  assign mapper_ppu_flags[11] = scanline[0];
  assign mapper_ppu_flags[10] = cycle[8];
  assign mapper_ppu_flags[9] = cycle[7];
  assign mapper_ppu_flags[8] = cycle[6];
  assign mapper_ppu_flags[7] = cycle[5];
  assign mapper_ppu_flags[6] = cycle[4];
  assign mapper_ppu_flags[5] = cycle[3];
  assign mapper_ppu_flags[4] = cycle[2];
  assign mapper_ppu_flags[3] = cycle[1];
  assign mapper_ppu_flags[2] = cycle[0];

  sky130_fd_sc_hd__edfxbp_1 grayscale_reg ( .D(din[0]), .DE(n114), .CLK(clk), 
        .Q_N(n29) );
  sky130_fd_sc_hd__edfxtp_1 playfield_clip_reg ( .D(din[1]), .DE(n114), .CLK(
        clk), .Q(playfield_clip) );
  sky130_fd_sc_hd__edfxtp_1 object_clip_reg ( .D(din[2]), .DE(n114), .CLK(clk), 
        .Q(object_clip) );
  sky130_fd_sc_hd__edfxtp_1 enable_playfield_reg ( .D(din[3]), .DE(n114), 
        .CLK(clk), .Q(enable_playfield) );
  sky130_fd_sc_hd__edfxtp_1 enable_objects_reg ( .D(din[4]), .DE(n114), .CLK(
        clk), .Q(enable_objects) );
  sky130_fd_sc_hd__edfxtp_1 obj_patt_reg ( .D(din[3]), .DE(n113), .CLK(clk), 
        .Q(obj_patt) );
  sky130_fd_sc_hd__edfxbp_1 bg_patt_reg ( .D(din[4]), .DE(n113), .CLK(clk), 
        .Q_N(n30) );
  sky130_fd_sc_hd__edfxtp_1 obj_size_reg ( .D(din[5]), .DE(n113), .CLK(clk), 
        .Q(mapper_ppu_flags[1]) );
  sky130_fd_sc_hd__edfxtp_1 vbl_enable_reg ( .D(din[7]), .DE(n113), .CLK(clk), 
        .Q(vbl_enable) );
  sky130_fd_sc_hd__edfxtp_1 vram_read_delayed_reg ( .D(vram_r), .DE(ce), .CLK(
        clk), .Q(vram_read_delayed) );
  sky130_fd_sc_hd__edfxbp_1 vram_latch_reg_7_ ( .D(vram_din[7]), .DE(n117), 
        .CLK(clk), .Q_N(n32) );
  sky130_fd_sc_hd__edfxbp_1 vram_latch_reg_6_ ( .D(vram_din[6]), .DE(n117), 
        .CLK(clk), .Q_N(n33) );
  sky130_fd_sc_hd__edfxtp_1 vram_latch_reg_5_ ( .D(vram_din[5]), .DE(n117), 
        .CLK(clk), .Q(vram_latch[5]) );
  sky130_fd_sc_hd__edfxtp_1 vram_latch_reg_4_ ( .D(vram_din[4]), .DE(n117), 
        .CLK(clk), .Q(vram_latch[4]) );
  sky130_fd_sc_hd__edfxbp_1 vram_latch_reg_3_ ( .D(vram_din[3]), .DE(n117), 
        .CLK(clk), .Q_N(n34) );
  sky130_fd_sc_hd__edfxbp_1 vram_latch_reg_2_ ( .D(vram_din[2]), .DE(n117), 
        .CLK(clk), .Q_N(n35) );
  sky130_fd_sc_hd__edfxbp_1 vram_latch_reg_1_ ( .D(vram_din[1]), .DE(n117), 
        .CLK(clk), .Q_N(n36) );
  sky130_fd_sc_hd__edfxbp_1 vram_latch_reg_0_ ( .D(vram_din[0]), .DE(n117), 
        .CLK(clk), .Q_N(n37) );
  sky130_fd_sc_hd__nand2_1 U94 ( .A(n52), .B(n53), .Y(vram_a[6]) );
  sky130_fd_sc_hd__a221o_1 U101 ( .A1(bg_name_table[7]), .A2(n178), .B1(
        sprite_vram_addr[11]), .B2(n112), .C1(n63), .X(vram_a[11]) );
  sky130_fd_sc_hd__a221o_1 U102 ( .A1(bg_name_table[6]), .A2(n178), .B1(
        sprite_vram_addr[10]), .B2(n112), .C1(n65), .X(vram_a[10]) );
  sky130_fd_sc_hd__and2_0 U110 ( .A(vbl_enable), .B(nmi_occured), .X(nmi) );
  sky130_fd_sc_hd__nand4_1 U113 ( .A(cycle[7]), .B(cycle[6]), .C(cycle[5]), 
        .D(cycle[4]), .Y(n77) );
  sky130_fd_sc_hd__nand4_1 U114 ( .A(cycle[3]), .B(cycle[0]), .C(cycle[1]), 
        .D(cycle[2]), .Y(n76) );
  sky130_fd_sc_hd__and2_0 U121 ( .A(write), .B(n86), .X(n_2_net_) );
  sky130_fd_sc_hd__nand2_1 U124 ( .A(oam_bus[7]), .B(n86), .Y(n92) );
  sky130_fd_sc_hd__nand2_1 U125 ( .A(oam_bus[6]), .B(n86), .Y(n93) );
  sky130_fd_sc_hd__a221o_1 U126 ( .A1(color[5]), .A2(net24614), .B1(net24612), 
        .B2(vram_latch[5]), .C1(n94), .X(dout[5]) );
  sky130_fd_sc_hd__a222oi_1 U128 ( .A1(oam_bus[4]), .A2(n86), .B1(color[4]), 
        .B2(net24614), .C1(net24612), .C2(vram_latch[4]), .Y(n95) );
  sky130_fd_sc_hd__nand2_1 U129 ( .A(oam_bus[3]), .B(n86), .Y(n98) );
  sky130_fd_sc_hd__nand2_1 U130 ( .A(oam_bus[2]), .B(n86), .Y(n100) );
  sky130_fd_sc_hd__nand2_1 U131 ( .A(oam_bus[1]), .B(n86), .Y(n102) );
  sky130_fd_sc_hd__nand2_1 U132 ( .A(oam_bus[0]), .B(n86), .Y(n104) );
  sky130_fd_sc_hd__nand2_1 U136 ( .A(color2[3]), .B(n29), .Y(n97) );
  sky130_fd_sc_hd__nand2_1 U137 ( .A(color2[2]), .B(n29), .Y(n99) );
  sky130_fd_sc_hd__nand2_1 U138 ( .A(color2[1]), .B(n29), .Y(n101) );
  sky130_fd_sc_hd__nand2_1 U139 ( .A(color2[0]), .B(n29), .Y(n103) );
  ClockGen clock ( .clk(clk), .ce(ce), .reset(reset), .is_rendering(
        mapper_ppu_flags[0]), .scanline(scanline), .cycle(cycle), 
        .is_in_vblank(is_in_vblank), .end_of_line(end_of_line), 
        .at_last_cycle_group(at_last_cycle_group), .exiting_vblank(
        exiting_vblank), .entering_vblank(entering_vblank), .is_pre_render(
        is_pre_render_line) );
  LoopyGen loopy0 ( .clk(clk), .ce(ce), .is_rendering(mapper_ppu_flags[0]), 
        .ain(ain), .din(din), .read(read), .write(write), .is_pre_render(
        is_pre_render_line), .cycle(cycle), .loopy(loopy), .fine_x_scroll(
        fine_x_scroll) );
  BgPainter bg_painter ( .clk(clk), .ce(ce), .enable(n192), .cycle(cycle[2:0]), 
        .fine_x_scroll(fine_x_scroll), .loopy(loopy), .name_table(
        bg_name_table), .vram_data(vram_din), .pixel(bg_pixel_noblank) );
  SpriteRAM sprite_ram ( .clk(clk), .ce(ce), .reset_line(before_line), 
        .sprites_enabled(mapper_ppu_flags[0]), .exiting_vblank(exiting_vblank), 
        .obj_size(mapper_ppu_flags[1]), .scanline(scanline), .cycle(cycle), 
        .oam_bus(oam_bus), .oam_ptr_load(n_1_net_), .oam_load(n_2_net_), 
        .data_in(din), .spr_overflow(sprite_overflow), .sprite0(obj0_on_line)
         );
  SpriteAddressGen address_gen ( .clk(clk), .ce(ce), .enabled(n_3_net_), 
        .obj_size(mapper_ppu_flags[1]), .obj_patt(obj_patt), .cycle(cycle[2:0]), .temp(oam_bus), .vram_addr(sprite_vram_addr), .vram_data(vram_din), .load(
        spriteset_load), .load_in(spriteset_load_in) );
  SpriteSet sprite_gen ( .clk(clk), .ce(ce), .enable(n193), .load(
        spriteset_load), .load_in(spriteset_load_in), .bits(obj_pixel_noblank), 
        .is_sprite0(is_obj0_pixel) );
  PixelMuxer pixel_muxer ( .bg({bg_pixel_noblank[3:2], \bg_pixel[1] , n116}), 
        .obj({obj_pixel_noblank[3:2], obj_pixel}), .obj_prio(
        obj_pixel_noblank[4]), .out(pixel), .is_obj(pixel_is_obj) );
  PaletteRam palette_ram ( .clk(clk), .ce(ce), .addr({n_5_net__4_, n_5_net__3_, 
        n_5_net__2_, n_5_net__1_, n_5_net__0_}), .din(din[5:0]), .dout({
        color[5:4], color2}), .write(n_6_net_) );
  sky130_fd_sc_hd__dfxtp_1 nmi_occured_reg ( .D(n111), .CLK(clk), .Q(
        nmi_occured) );
  sky130_fd_sc_hd__dfxtp_1 sprite0_hit_bg_reg ( .D(n110), .CLK(clk), .Q(
        sprite0_hit_bg) );
  sky130_fd_sc_hd__nand2_1 U145 ( .A(pixel[0]), .B(mapper_ppu_flags[0]), .Y(
        n128) );
  sky130_fd_sc_hd__inv_4 U146 ( .A(net69588), .Y(mapper_ppu_flags[0]) );
  sky130_fd_sc_hd__inv_2 U147 ( .A(loopy[10]), .Y(n185) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(loopy[11]), .Y(n187) );
  sky130_fd_sc_hd__inv_2 U149 ( .A(n156), .Y(n155) );
  sky130_fd_sc_hd__nor2_1 U150 ( .A(n193), .B(cycle[6]), .Y(n_3_net_) );
  sky130_fd_sc_hd__nand2_1 U151 ( .A(n138), .B(n140), .Y(net69588) );
  sky130_fd_sc_hd__nor2_1 U152 ( .A(n132), .B(is_in_vblank), .Y(n138) );
  sky130_fd_sc_hd__nor2_1 U153 ( .A(scanline[2]), .B(scanline[1]), .Y(n136) );
  sky130_fd_sc_hd__nor3_1 U154 ( .A(n186), .B(n185), .C(n187), .Y(n106) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(is_in_vblank), .Y(net63711) );
  sky130_fd_sc_hd__inv_2 U156 ( .A(at_last_cycle_group), .Y(n192) );
  sky130_fd_sc_hd__inv_2 U157 ( .A(nmi_occured), .Y(n197) );
  sky130_fd_sc_hd__inv_1 U158 ( .A(end_of_line), .Y(n161) );
  sky130_fd_sc_hd__inv_2 U159 ( .A(n152), .Y(n142) );
  sky130_fd_sc_hd__inv_2 U160 ( .A(loopy[3]), .Y(n149) );
  sky130_fd_sc_hd__nor3_1 U161 ( .A(n84), .B(net35814), .C(n45), .Y(n_6_net_)
         );
  sky130_fd_sc_hd__inv_2 U162 ( .A(n84), .Y(n133) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(cycle[8]), .Y(n193) );
  sky130_fd_sc_hd__inv_1 U164 ( .A(net55060), .Y(net55059) );
  sky130_fd_sc_hd__nor2_1 U165 ( .A(n86), .B(n194), .Y(n105) );
  sky130_fd_sc_hd__nor2_1 U166 ( .A(ain[2]), .B(n45), .Y(n_1_net_) );
  sky130_fd_sc_hd__inv_1 U167 ( .A(n139), .Y(n132) );
  sky130_fd_sc_hd__inv_1 U168 ( .A(enable_objects), .Y(net69627) );
  sky130_fd_sc_hd__inv_2 U169 ( .A(loopy[8]), .Y(n189) );
  sky130_fd_sc_hd__inv_2 U170 ( .A(loopy[9]), .Y(n188) );
  sky130_fd_sc_hd__inv_2 U171 ( .A(n176), .Y(n178) );
  sky130_fd_sc_hd__inv_2 U172 ( .A(n168), .Y(n64) );
  sky130_fd_sc_hd__nor2_1 U173 ( .A(cycle[2]), .B(cycle[1]), .Y(n68) );
  sky130_fd_sc_hd__nand3_1 U174 ( .A(ain[1]), .B(ain[0]), .C(write), .Y(n45)
         );
  sky130_fd_sc_hd__inv_2 U175 ( .A(n82), .Y(n194) );
  sky130_fd_sc_hd__inv_2 U176 ( .A(n91), .Y(net24612) );
  sky130_fd_sc_hd__inv_2 U177 ( .A(n96), .Y(net24614) );
  sky130_fd_sc_hd__nand3_1 U178 ( .A(n195), .B(net35814), .C(ain[1]), .Y(n82)
         );
  sky130_fd_sc_hd__nor3_1 U179 ( .A(ain[0]), .B(ain[1]), .C(net35814), .Y(n86)
         );
  sky130_fd_sc_hd__nor2_1 U180 ( .A(n82), .B(n196), .Y(n80) );
  sky130_fd_sc_hd__inv_2 U181 ( .A(net55030), .Y(n143) );
  sky130_fd_sc_hd__a22oi_1 U182 ( .A1(bg_name_table[2]), .A2(n178), .B1(
        sprite_vram_addr[6]), .B2(n112), .Y(n52) );
  sky130_fd_sc_hd__nor2_1 U183 ( .A(n64), .B(n185), .Y(n65) );
  sky130_fd_sc_hd__nor2_1 U184 ( .A(n64), .B(n187), .Y(n63) );
  sky130_fd_sc_hd__nand3_1 U185 ( .A(ain[2]), .B(n162), .C(n84), .Y(n158) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(n45), .Y(n162) );
  sky130_fd_sc_hd__o221ai_1 U187 ( .A1(n96), .A2(n103), .B1(n37), .B2(n91), 
        .C1(n104), .Y(dout[0]) );
  sky130_fd_sc_hd__o221ai_1 U188 ( .A1(n96), .A2(n101), .B1(n36), .B2(n91), 
        .C1(n102), .Y(dout[1]) );
  sky130_fd_sc_hd__o221ai_1 U189 ( .A1(n96), .A2(n99), .B1(n35), .B2(n91), 
        .C1(n100), .Y(dout[2]) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(n95), .Y(dout[4]) );
  sky130_fd_sc_hd__o221ai_1 U191 ( .A1(n33), .A2(n91), .B1(n198), .B2(n82), 
        .C1(n93), .Y(dout[6]) );
  sky130_fd_sc_hd__o221ai_1 U192 ( .A1(n32), .A2(n91), .B1(n197), .B2(n82), 
        .C1(n92), .Y(dout[7]) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(n103), .Y(color[0]) );
  sky130_fd_sc_hd__inv_2 U194 ( .A(n101), .Y(color[1]) );
  sky130_fd_sc_hd__inv_2 U195 ( .A(n99), .Y(color[2]) );
  sky130_fd_sc_hd__inv_2 U196 ( .A(n97), .Y(color[3]) );
  sky130_fd_sc_hd__a21oi_1 U197 ( .A1(exiting_vblank), .A2(ce), .B1(n198), .Y(
        n74) );
  sky130_fd_sc_hd__o32ai_1 U198 ( .A1(n190), .A2(n80), .A3(n81), .B1(n191), 
        .B2(n197), .Y(n111) );
  sky130_fd_sc_hd__inv_2 U199 ( .A(entering_vblank), .Y(n190) );
  sky130_fd_sc_hd__inv_2 U200 ( .A(n81), .Y(n191) );
  sky130_fd_sc_hd__o31ai_1 U201 ( .A1(n80), .A2(exiting_vblank), .A3(
        entering_vblank), .B1(ce), .Y(n81) );
  sky130_fd_sc_hd__inv_2 U202 ( .A(cycle[0]), .Y(n163) );
  sky130_fd_sc_hd__inv_2 U203 ( .A(net55065), .Y(net69646) );
  sky130_fd_sc_hd__and3_1 U204 ( .A(n_3_net_), .B(cycle[2]), .C(n118), .X(n112) );
  sky130_fd_sc_hd__and3_1 U205 ( .A(n195), .B(n179), .C(n119), .X(n113) );
  sky130_fd_sc_hd__inv_2 U206 ( .A(n118), .Y(n151) );
  sky130_fd_sc_hd__and3_1 U207 ( .A(ain[0]), .B(n119), .C(n179), .X(n114) );
  sky130_fd_sc_hd__a22o_1 U208 ( .A1(n178), .A2(loopy[12]), .B1(
        sprite_vram_addr[0]), .B2(n112), .X(n115) );
  sky130_fd_sc_hd__inv_2 U209 ( .A(ain[0]), .Y(n195) );
  sky130_fd_sc_hd__and3_1 U210 ( .A(bg_pixel_noblank[0]), .B(enable_playfield), 
        .C(net55057), .X(n116) );
  sky130_fd_sc_hd__and2_1 U211 ( .A(vram_read_delayed), .B(ce), .X(n117) );
  sky130_fd_sc_hd__and2_1 U212 ( .A(mapper_ppu_flags[0]), .B(n165), .X(n118)
         );
  sky130_fd_sc_hd__and3_1 U213 ( .A(write), .B(ce), .C(net35814), .X(n119) );
  sky130_fd_sc_hd__a22o_1 U214 ( .A1(n178), .A2(loopy[13]), .B1(
        sprite_vram_addr[1]), .B2(n112), .X(n120) );
  sky130_fd_sc_hd__a22o_1 U215 ( .A1(loopy[14]), .A2(n178), .B1(
        sprite_vram_addr[2]), .B2(n112), .X(n121) );
  sky130_fd_sc_hd__inv_2 U216 ( .A(loopy[12]), .Y(n186) );
  sky130_fd_sc_hd__nand2_1 U217 ( .A(n118), .B(n167), .Y(net55016) );
  sky130_fd_sc_hd__inv_2 U218 ( .A(net55016), .Y(n150) );
  sky130_fd_sc_hd__inv_2 U219 ( .A(read), .Y(n196) );
  sky130_fd_sc_hd__inv_2 U220 ( .A(loopy[7]), .Y(net24606) );
  sky130_fd_sc_hd__inv_1 U221 ( .A(enable_playfield), .Y(n134) );
  sky130_fd_sc_hd__nor2_1 U222 ( .A(mapper_ppu_flags[0]), .B(n158), .Y(vram_w)
         );
  sky130_fd_sc_hd__a41o_2 U223 ( .A1(net55047), .A2(mapper_ppu_flags[0]), .A3(
        net55048), .A4(net55049), .B1(n74), .X(n110) );
  sky130_fd_sc_hd__nand3_1 U224 ( .A(n163), .B(mapper_ppu_flags[0]), .C(n161), 
        .Y(n157) );
  sky130_fd_sc_hd__nor2_1 U225 ( .A(mapper_ppu_flags[0]), .B(n142), .Y(n141)
         );
  sky130_fd_sc_hd__nand4_2 U226 ( .A(scanline[6]), .B(scanline[7]), .C(
        scanline[5]), .D(scanline[4]), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U227 ( .A(n126), .Y(obj_pixel[0]) );
  sky130_fd_sc_hd__nor2_1 U228 ( .A(n155), .B(mapper_ppu_flags[0]), .Y(n153)
         );
  sky130_fd_sc_hd__inv_1 U229 ( .A(n125), .Y(obj_pixel[1]) );
  sky130_fd_sc_hd__nand2_2 U230 ( .A(n122), .B(n123), .Y(n_5_net__1_) );
  sky130_fd_sc_hd__clkinv_1 U231 ( .A(net55066), .Y(n124) );
  sky130_fd_sc_hd__nand2_1 U232 ( .A(mapper_ppu_flags[0]), .B(pixel[1]), .Y(
        n122) );
  sky130_fd_sc_hd__nand2_1 U233 ( .A(n124), .B(net69646), .Y(n123) );
  sky130_fd_sc_hd__nand2_1 U234 ( .A(obj_pixel_noblank[1]), .B(net55047), .Y(
        n125) );
  sky130_fd_sc_hd__nand2_1 U235 ( .A(obj_pixel_noblank[0]), .B(net55047), .Y(
        n126) );
  sky130_fd_sc_hd__inv_2 U236 ( .A(net55061), .Y(net55047) );
  sky130_fd_sc_hd__nand2_1 U237 ( .A(net69646), .B(net61522), .Y(n127) );
  sky130_fd_sc_hd__nand2_2 U238 ( .A(n128), .B(n127), .Y(n_5_net__0_) );
  sky130_fd_sc_hd__inv_2 U239 ( .A(net55067), .Y(net61522) );
  sky130_fd_sc_hd__nor2_1 U240 ( .A(n153), .B(n154), .Y(n_5_net__2_) );
  sky130_fd_sc_hd__o21ai_1 U241 ( .A1(object_clip), .A2(net55060), .B1(
        enable_objects), .Y(net55061) );
  sky130_fd_sc_hd__nand3_1 U242 ( .A(n129), .B(n130), .C(n131), .Y(net55060)
         );
  sky130_fd_sc_hd__nor3_1 U243 ( .A(cycle[5]), .B(cycle[6]), .C(cycle[7]), .Y(
        n131) );
  sky130_fd_sc_hd__inv_1 U244 ( .A(cycle[3]), .Y(n130) );
  sky130_fd_sc_hd__inv_1 U245 ( .A(cycle[4]), .Y(n129) );
  sky130_fd_sc_hd__inv_1 U246 ( .A(loopy[0]), .Y(net55067) );
  sky130_fd_sc_hd__nand2_1 U247 ( .A(net69588), .B(n133), .Y(net55065) );
  sky130_fd_sc_hd__nand3b_1 U248 ( .A_N(n137), .B(n135), .C(n136), .Y(n140) );
  sky130_fd_sc_hd__nor3_2 U249 ( .A(scanline[8]), .B(scanline[3]), .C(
        scanline[0]), .Y(n135) );
  sky130_fd_sc_hd__a21oi_2 U250 ( .A1(net55051), .A2(net55052), .B1(n132), .Y(
        before_line) );
  sky130_fd_sc_hd__nand2_1 U251 ( .A(net69627), .B(n134), .Y(n139) );
  sky130_fd_sc_hd__nand3_1 U252 ( .A(bg_pixel_noblank[1]), .B(enable_playfield), .C(net55057), .Y(net55056) );
  sky130_fd_sc_hd__a22o_2 U253 ( .A1(sprite_overflow), .A2(n194), .B1(
        oam_bus[5]), .B2(n86), .X(n94) );
  sky130_fd_sc_hd__nand3b_1 U254 ( .A_N(n143), .B(n144), .C(n145), .Y(
        vram_a[3]) );
  sky130_fd_sc_hd__nand3b_1 U255 ( .A_N(n120), .B(n146), .C(n147), .Y(
        vram_a[1]) );
  sky130_fd_sc_hd__nand2_1 U256 ( .A(loopy[3]), .B(n151), .Y(n144) );
  sky130_fd_sc_hd__nand2_1 U257 ( .A(n150), .B(loopy[7]), .Y(n145) );
  sky130_fd_sc_hd__nand2_1 U258 ( .A(loopy[3]), .B(n150), .Y(n146) );
  sky130_fd_sc_hd__nand2_1 U259 ( .A(loopy[1]), .B(n151), .Y(n147) );
  sky130_fd_sc_hd__nand2b_1 U260 ( .A_N(n149), .B(net69646), .Y(n152) );
  sky130_fd_sc_hd__nor2_1 U261 ( .A(n142), .B(pixel[3]), .Y(n148) );
  sky130_fd_sc_hd__nor2_1 U262 ( .A(n141), .B(n148), .Y(n_5_net__3_) );
  sky130_fd_sc_hd__nor2_1 U263 ( .A(n155), .B(pixel[2]), .Y(n154) );
  sky130_fd_sc_hd__nand2b_1 U264 ( .A_N(net55065), .B(loopy[2]), .Y(n156) );
  sky130_fd_sc_hd__nand2_1 U265 ( .A(loopy[2]), .B(n151), .Y(net63728) );
  sky130_fd_sc_hd__nand2_1 U266 ( .A(loopy[2]), .B(n150), .Y(net63736) );
  sky130_fd_sc_hd__nand2_1 U267 ( .A(n105), .B(n84), .Y(n91) );
  sky130_fd_sc_hd__nand2_1 U268 ( .A(end_of_line), .B(net63711), .Y(net55051)
         );
  sky130_fd_sc_hd__nand2_1 U269 ( .A(net55037), .B(n157), .Y(vram_r) );
  sky130_fd_sc_hd__nand2b_1 U270 ( .A_N(n84), .B(n105), .Y(n96) );
  sky130_fd_sc_hd__nand3b_1 U271 ( .A_N(n121), .B(net63728), .C(n159), .Y(
        vram_a[2]) );
  sky130_fd_sc_hd__nand3b_1 U272 ( .A_N(n115), .B(net63736), .C(n160), .Y(
        vram_a[0]) );
  sky130_fd_sc_hd__nand2_1 U273 ( .A(loopy[4]), .B(n150), .Y(n159) );
  sky130_fd_sc_hd__nand2_1 U274 ( .A(net61522), .B(n151), .Y(n160) );
  sky130_fd_sc_hd__o221ai_1 U275 ( .A1(n96), .A2(n97), .B1(n34), .B2(n91), 
        .C1(n98), .Y(dout[3]) );
  sky130_fd_sc_hd__inv_1 U276 ( .A(net55056), .Y(\bg_pixel[1] ) );
  sky130_fd_sc_hd__a2bb2o_1 U277 ( .A1_N(net55027), .A2_N(net55065), .B1(
        pixel_is_obj), .B2(mapper_ppu_flags[0]), .X(n_5_net__4_) );
  sky130_fd_sc_hd__and3_2 U278 ( .A(obj0_on_line), .B(ce), .C(is_obj0_pixel), 
        .X(net55048) );
  sky130_fd_sc_hd__nand4_1 U279 ( .A(loopy[13]), .B(n106), .C(loopy[8]), .D(
        loopy[9]), .Y(n84) );
  sky130_fd_sc_hd__inv_1 U280 ( .A(ain[2]), .Y(net35814) );
  sky130_fd_sc_hd__inv_1 U281 ( .A(ain[1]), .Y(n179) );
  sky130_fd_sc_hd__inv_1 U282 ( .A(loopy[1]), .Y(net55066) );
  sky130_fd_sc_hd__inv_1 U283 ( .A(loopy[4]), .Y(net55027) );
  sky130_fd_sc_hd__nand2b_1 U284 ( .A_N(playfield_clip), .B(net55059), .Y(
        net55057) );
  sky130_fd_sc_hd__inv_1 U285 ( .A(exiting_vblank), .Y(net55052) );
  sky130_fd_sc_hd__o22ai_1 U286 ( .A1(n77), .A2(n76), .B1(n116), .B2(
        \bg_pixel[1] ), .Y(n164) );
  sky130_fd_sc_hd__nor4_1 U287 ( .A(cycle[8]), .B(exiting_vblank), .C(
        is_pre_render_line), .D(n164), .Y(net55049) );
  sky130_fd_sc_hd__inv_1 U288 ( .A(n68), .Y(n165) );
  sky130_fd_sc_hd__inv_1 U289 ( .A(n_3_net_), .Y(n166) );
  sky130_fd_sc_hd__nand3_1 U290 ( .A(cycle[2]), .B(n118), .C(n166), .Y(n176)
         );
  sky130_fd_sc_hd__inv_1 U291 ( .A(cycle[2]), .Y(n167) );
  sky130_fd_sc_hd__nand2_1 U292 ( .A(n118), .B(net55016), .Y(n168) );
  sky130_fd_sc_hd__o21ai_1 U293 ( .A1(loopy[6]), .A2(n150), .B1(n168), .Y(n53)
         );
  sky130_fd_sc_hd__inv_1 U294 ( .A(sprite0_hit_bg), .Y(n198) );
  sky130_fd_sc_hd__nand4_1 U295 ( .A(ain[2]), .B(ain[1]), .C(ain[0]), .D(read), 
        .Y(net55037) );
  sky130_fd_sc_hd__a22oi_1 U296 ( .A1(cycle[1]), .A2(n178), .B1(
        sprite_vram_addr[3]), .B2(n112), .Y(net55030) );
  sky130_fd_sc_hd__a22oi_1 U297 ( .A1(bg_name_table[0]), .A2(n178), .B1(
        sprite_vram_addr[4]), .B2(n112), .Y(n169) );
  sky130_fd_sc_hd__o221ai_1 U298 ( .A1(n189), .A2(net55016), .B1(n118), .B2(
        net55027), .C1(n169), .Y(vram_a[4]) );
  sky130_fd_sc_hd__inv_1 U299 ( .A(loopy[5]), .Y(n171) );
  sky130_fd_sc_hd__a22oi_1 U300 ( .A1(bg_name_table[1]), .A2(n178), .B1(
        sprite_vram_addr[5]), .B2(n112), .Y(n170) );
  sky130_fd_sc_hd__o221ai_1 U301 ( .A1(n188), .A2(net55016), .B1(n118), .B2(
        n171), .C1(n170), .Y(vram_a[5]) );
  sky130_fd_sc_hd__a22oi_1 U302 ( .A1(bg_name_table[3]), .A2(n178), .B1(
        sprite_vram_addr[7]), .B2(n112), .Y(n172) );
  sky130_fd_sc_hd__o211ai_1 U303 ( .A1(net24606), .A2(n118), .B1(net55016), 
        .C1(n172), .Y(vram_a[7]) );
  sky130_fd_sc_hd__a22oi_1 U304 ( .A1(bg_name_table[4]), .A2(n178), .B1(
        sprite_vram_addr[8]), .B2(n112), .Y(n173) );
  sky130_fd_sc_hd__o211ai_1 U305 ( .A1(n189), .A2(n118), .B1(net55016), .C1(
        n173), .Y(vram_a[8]) );
  sky130_fd_sc_hd__a22oi_1 U306 ( .A1(bg_name_table[5]), .A2(n178), .B1(
        sprite_vram_addr[9]), .B2(n112), .Y(n174) );
  sky130_fd_sc_hd__o211ai_1 U307 ( .A1(n188), .A2(n118), .B1(net55016), .C1(
        n174), .Y(vram_a[9]) );
  sky130_fd_sc_hd__nand2_1 U308 ( .A(sprite_vram_addr[12]), .B(n112), .Y(n175)
         );
  sky130_fd_sc_hd__o221ai_1 U309 ( .A1(n30), .A2(n176), .B1(n186), .B2(
        mapper_ppu_flags[0]), .C1(n175), .Y(vram_a[12]) );
  sky130_fd_sc_hd__mux2i_1 U310 ( .A0(loopy[13]), .A1(n68), .S(
        mapper_ppu_flags[0]), .Y(n177) );
  sky130_fd_sc_hd__nand2_1 U311 ( .A(net55016), .B(n177), .Y(vram_a[13]) );
endmodule

