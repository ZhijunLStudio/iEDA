/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 29 20:36:13 2025
/////////////////////////////////////////////////////////////


module RegRst_0x9f365fdf6c8998a ( clk, in_, out, reset );
  input [0:0] clk;
  input [1:0] in_;
  output [1:0] out;
  input [0:0] reset;
  wire   N3, N4;

  sky130_fd_sc_hd__nor2b_1 U3 ( .B_N(in_[1]), .A(reset[0]), .Y(N4) );
  sky130_fd_sc_hd__nor2b_1 U4 ( .B_N(in_[0]), .A(reset[0]), .Y(N3) );
  sky130_fd_sc_hd__dfxtp_1 out_reg_0_ ( .D(N3), .CLK(clk[0]), .Q(out[0]) );
  sky130_fd_sc_hd__dfxtp_1 out_reg_1_ ( .D(N4), .CLK(clk[0]), .Q(out[1]) );
endmodule


module GcdUnitCtrlRTL_0x4d0fc71ead8d3d9e ( a_mux_sel, a_reg_en, b_mux_sel, 
        b_reg_en, clk, is_a_lt_b, is_b_zero, req_rdy, req_val, reset, resp_rdy, 
        resp_val );
  output [1:0] a_mux_sel;
  output [0:0] a_reg_en;
  output [0:0] b_mux_sel;
  output [0:0] b_reg_en;
  input [0:0] clk;
  input [0:0] is_a_lt_b;
  input [0:0] is_b_zero;
  output [0:0] req_rdy;
  input [0:0] req_val;
  input [0:0] reset;
  input [0:0] resp_rdy;
  output [0:0] resp_val;
  wire   \b_mux_sel[0] , n3, n4, n5, n1;
  wire   [1:0] state_out;
  wire   [1:0] next_state__0;
  assign req_rdy[0] = \b_mux_sel[0] ;
  assign b_mux_sel[0] = \b_mux_sel[0] ;

  sky130_fd_sc_hd__nand2_1 U14 ( .A(state_out[0]), .B(a_reg_en[0]), .Y(n5) );
  RegRst_0x9f365fdf6c8998a state ( .clk(clk[0]), .in_(next_state__0), .out(
        state_out), .reset(reset[0]) );
  sky130_fd_sc_hd__nor2_1 U3 ( .A(n5), .B(n1), .Y(a_mux_sel[1]) );
  sky130_fd_sc_hd__nor2_1 U4 ( .A(a_reg_en[0]), .B(state_out[0]), .Y(
        resp_val[0]) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(state_out[1]), .Y(a_reg_en[0]) );
  sky130_fd_sc_hd__nor2_1 U6 ( .A(resp_val[0]), .B(state_out[0]), .Y(
        \b_mux_sel[0] ) );
  sky130_fd_sc_hd__a21oi_1 U7 ( .A1(state_out[0]), .A2(n1), .B1(state_out[1]), 
        .Y(b_reg_en[0]) );
  sky130_fd_sc_hd__a21oi_1 U8 ( .A1(resp_rdy[0]), .A2(resp_val[0]), .B1(n3), 
        .Y(next_state__0[1]) );
  sky130_fd_sc_hd__a21oi_1 U9 ( .A1(req_val[0]), .A2(a_reg_en[0]), .B1(
        state_out[0]), .Y(n4) );
  sky130_fd_sc_hd__nor2_2 U10 ( .A(n5), .B(is_a_lt_b[0]), .Y(a_mux_sel[0]) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(is_a_lt_b[0]), .Y(n1) );
  sky130_fd_sc_hd__a21oi_1 U12 ( .A1(is_b_zero[0]), .A2(a_mux_sel[0]), .B1(n4), 
        .Y(next_state__0[0]) );
  sky130_fd_sc_hd__a21oi_1 U13 ( .A1(is_b_zero[0]), .A2(a_mux_sel[0]), .B1(
        state_out[1]), .Y(n3) );
endmodule


module RegEn_0x68db79c4ec1d6e5b_0 ( clk, en, in_, out, reset );
  input [0:0] clk;
  input [0:0] en;
  input [15:0] in_;
  output [15:0] out;
  input [0:0] reset;


  sky130_fd_sc_hd__edfxtp_1 out_reg_15_ ( .D(in_[15]), .DE(en[0]), .CLK(clk[0]), .Q(out[15]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_14_ ( .D(in_[14]), .DE(en[0]), .CLK(clk[0]), .Q(out[14]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_13_ ( .D(in_[13]), .DE(en[0]), .CLK(clk[0]), .Q(out[13]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_12_ ( .D(in_[12]), .DE(en[0]), .CLK(clk[0]), .Q(out[12]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_11_ ( .D(in_[11]), .DE(en[0]), .CLK(clk[0]), .Q(out[11]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_10_ ( .D(in_[10]), .DE(en[0]), .CLK(clk[0]), .Q(out[10]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_9_ ( .D(in_[9]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[9]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_8_ ( .D(in_[8]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[8]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_7_ ( .D(in_[7]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[7]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_6_ ( .D(in_[6]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[6]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_5_ ( .D(in_[5]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[5]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_4_ ( .D(in_[4]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[4]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_3_ ( .D(in_[3]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[3]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_2_ ( .D(in_[2]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[2]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_1_ ( .D(in_[1]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[1]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_0_ ( .D(in_[0]), .DE(en[0]), .CLK(clk[0]), 
        .Q(out[0]) );
endmodule


module LtComparator_0x422b1f52edd46a85 ( clk, in0, in1, out, reset );
  input [0:0] clk;
  input [15:0] in0;
  input [15:0] in1;
  output [0:0] out;
  input [0:0] reset;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46;

  sky130_fd_sc_hd__inv_2 U1 ( .A(in0[2]), .Y(n32) );
  sky130_fd_sc_hd__and2_1 U2 ( .A(in1[15]), .B(n41), .X(n4) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(in0[14]), .Y(n40) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(in1[12]), .Y(n45) );
  sky130_fd_sc_hd__a21oi_2 U5 ( .A1(n40), .A2(in1[14]), .B1(n4), .Y(n8) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(in0[0]), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(in0[3]), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(in0[7]), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(in0[6]), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(in1[4]), .Y(n42) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(in0[10]), .Y(n38) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(in1[13]), .Y(n46) );
  sky130_fd_sc_hd__o211ai_1 U13 ( .A1(in0[12]), .A2(n45), .B1(n5), .C1(n8), 
        .Y(n26) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(in0[8]), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(in0[1]), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(in1[5]), .Y(n43) );
  sky130_fd_sc_hd__o21ai_0 U17 ( .A1(n26), .A2(n10), .B1(n9), .Y(n29) );
  sky130_fd_sc_hd__a2111oi_2 U18 ( .A1(in1[8]), .A2(n36), .B1(n26), .C1(n44), 
        .D1(n25), .Y(n27) );
  sky130_fd_sc_hd__o21ai_1 U19 ( .A1(n23), .A2(n22), .B1(n21), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(in0[11]), .Y(n39) );
  sky130_fd_sc_hd__o32ai_2 U21 ( .A1(n38), .A2(in1[10]), .A3(n1), .B1(in1[11]), 
        .B2(n39), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(n24), .Y(n44) );
  sky130_fd_sc_hd__and2_4 U23 ( .A(in1[11]), .B(n39), .X(n1) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(in0[15]), .Y(n41) );
  sky130_fd_sc_hd__o22ai_1 U25 ( .A1(n29), .A2(n28), .B1(n29), .B2(n27), .Y(
        out[0]) );
  sky130_fd_sc_hd__nand2b_1 U26 ( .A_N(in0[13]), .B(in1[13]), .Y(n5) );
  sky130_fd_sc_hd__a21oi_1 U27 ( .A1(n38), .A2(in1[10]), .B1(n1), .Y(n24) );
  sky130_fd_sc_hd__nor2b_1 U28 ( .B_N(in1[9]), .A(in0[9]), .Y(n25) );
  sky130_fd_sc_hd__o32ai_1 U29 ( .A1(n36), .A2(in1[8]), .A3(n25), .B1(in1[9]), 
        .B2(n37), .Y(n2) );
  sky130_fd_sc_hd__o22ai_1 U30 ( .A1(n24), .A2(n3), .B1(n3), .B2(n2), .Y(n10)
         );
  sky130_fd_sc_hd__o32ai_1 U31 ( .A1(n40), .A2(in1[14]), .A3(n4), .B1(in1[15]), 
        .B2(n41), .Y(n7) );
  sky130_fd_sc_hd__a32o_1 U32 ( .A1(in0[12]), .A2(n45), .A3(n5), .B1(n46), 
        .B2(in0[13]), .X(n6) );
  sky130_fd_sc_hd__o22ai_1 U33 ( .A1(n8), .A2(n7), .B1(n7), .B2(n6), .Y(n9) );
  sky130_fd_sc_hd__nor2b_1 U34 ( .B_N(in1[3]), .A(in0[3]), .Y(n11) );
  sky130_fd_sc_hd__a21oi_1 U35 ( .A1(in1[2]), .A2(n32), .B1(n11), .Y(n12) );
  sky130_fd_sc_hd__o32ai_1 U36 ( .A1(n32), .A2(in1[2]), .A3(n11), .B1(in1[3]), 
        .B2(n33), .Y(n15) );
  sky130_fd_sc_hd__nand2b_1 U37 ( .A_N(in0[5]), .B(in1[5]), .Y(n17) );
  sky130_fd_sc_hd__o221ai_1 U38 ( .A1(in0[4]), .A2(n42), .B1(n12), .B2(n15), 
        .C1(n17), .Y(n23) );
  sky130_fd_sc_hd__a22o_1 U39 ( .A1(n30), .A2(in1[0]), .B1(n31), .B2(in1[1]), 
        .X(n13) );
  sky130_fd_sc_hd__o21ai_0 U40 ( .A1(in1[1]), .A2(n31), .B1(n13), .Y(n14) );
  sky130_fd_sc_hd__and2_0 U41 ( .A(in1[7]), .B(n35), .X(n16) );
  sky130_fd_sc_hd__a21oi_1 U42 ( .A1(n34), .A2(in1[6]), .B1(n16), .Y(n20) );
  sky130_fd_sc_hd__o21ai_0 U43 ( .A1(n15), .A2(n14), .B1(n20), .Y(n22) );
  sky130_fd_sc_hd__o32ai_1 U44 ( .A1(n34), .A2(in1[6]), .A3(n16), .B1(in1[7]), 
        .B2(n35), .Y(n19) );
  sky130_fd_sc_hd__a32o_1 U45 ( .A1(in0[4]), .A2(n42), .A3(n17), .B1(n43), 
        .B2(in0[5]), .X(n18) );
  sky130_fd_sc_hd__o22ai_1 U46 ( .A1(n20), .A2(n19), .B1(n19), .B2(n18), .Y(
        n21) );
  sky130_fd_sc_hd__clkinv_2 U47 ( .A(in0[9]), .Y(n37) );
endmodule


module ZeroComparator_0x422b1f52edd46a85 ( clk, in_, out, reset );
  input [0:0] clk;
  input [15:0] in_;
  output [0:0] out;
  input [0:0] reset;
  wire   n1, n2, n3, n4;

  sky130_fd_sc_hd__and4_1 U5 ( .A(n1), .B(n2), .C(n3), .D(n4), .X(out[0]) );
  sky130_fd_sc_hd__nor4_1 U1 ( .A(in_[5]), .B(in_[4]), .C(in_[3]), .D(in_[2]), 
        .Y(n3) );
  sky130_fd_sc_hd__nor4_1 U2 ( .A(in_[9]), .B(in_[8]), .C(in_[7]), .D(in_[6]), 
        .Y(n4) );
  sky130_fd_sc_hd__nor4_1 U3 ( .A(in_[12]), .B(in_[11]), .C(in_[10]), .D(
        in_[0]), .Y(n1) );
  sky130_fd_sc_hd__nor4_1 U4 ( .A(in_[1]), .B(in_[15]), .C(in_[14]), .D(
        in_[13]), .Y(n2) );
endmodule


module Mux_0x683fa1a418b072c9 ( clk, in__000, in__001, in__002, out, reset, 
        sel );
  input [0:0] clk;
  input [15:0] in__000;
  input [15:0] in__001;
  input [15:0] in__002;
  output [15:0] out;
  input [0:0] reset;
  input [1:0] sel;
  wire   n21, n22, n23, n24, n25, n26, n33, n1, n2, n3, n4, n5, n6, n7, n8, n9,
         n10, n11, n12, n13, n14, n15;

  sky130_fd_sc_hd__a222oi_1 U21 ( .A1(in__002[6]), .A2(n2), .B1(in__000[6]), 
        .B2(n15), .C1(in__001[6]), .C2(n1), .Y(n21) );
  sky130_fd_sc_hd__a222oi_1 U22 ( .A1(in__002[5]), .A2(n2), .B1(in__000[5]), 
        .B2(n15), .C1(in__001[5]), .C2(n1), .Y(n22) );
  sky130_fd_sc_hd__a222oi_1 U23 ( .A1(in__002[4]), .A2(n2), .B1(in__000[4]), 
        .B2(n15), .C1(in__001[4]), .C2(n1), .Y(n23) );
  sky130_fd_sc_hd__a222oi_1 U24 ( .A1(in__002[3]), .A2(n2), .B1(in__000[3]), 
        .B2(n15), .C1(in__001[3]), .C2(n1), .Y(n24) );
  sky130_fd_sc_hd__a222oi_1 U25 ( .A1(in__002[2]), .A2(n2), .B1(in__000[2]), 
        .B2(n15), .C1(in__001[2]), .C2(n1), .Y(n25) );
  sky130_fd_sc_hd__a222oi_1 U26 ( .A1(in__002[1]), .A2(n2), .B1(in__000[1]), 
        .B2(n15), .C1(in__001[1]), .C2(n1), .Y(n26) );
  sky130_fd_sc_hd__a222oi_1 U33 ( .A1(in__002[0]), .A2(n2), .B1(in__000[0]), 
        .B2(n15), .C1(in__001[0]), .C2(n1), .Y(n33) );
  sky130_fd_sc_hd__inv_1 U1 ( .A(n21), .Y(out[6]) );
  sky130_fd_sc_hd__inv_1 U2 ( .A(n22), .Y(out[5]) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(n23), .Y(out[4]) );
  sky130_fd_sc_hd__inv_1 U4 ( .A(n24), .Y(out[3]) );
  sky130_fd_sc_hd__inv_1 U5 ( .A(n25), .Y(out[2]) );
  sky130_fd_sc_hd__inv_1 U6 ( .A(n26), .Y(out[1]) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(n33), .Y(out[0]) );
  sky130_fd_sc_hd__nand2_1 U8 ( .A(n4), .B(n3), .Y(n5) );
  sky130_fd_sc_hd__buf_1 U9 ( .A(sel[1]), .X(n2) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(sel[1]), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(n1), .Y(n4) );
  sky130_fd_sc_hd__buf_6 U12 ( .A(sel[0]), .X(n1) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n5), .Y(n15) );
  sky130_fd_sc_hd__a222oi_1 U14 ( .A1(in__002[7]), .A2(n2), .B1(in__000[7]), 
        .B2(n15), .C1(in__001[7]), .C2(n1), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(n6), .Y(out[7]) );
  sky130_fd_sc_hd__a222oi_1 U16 ( .A1(in__002[8]), .A2(n2), .B1(in__000[8]), 
        .B2(n15), .C1(in__001[8]), .C2(n1), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(n7), .Y(out[8]) );
  sky130_fd_sc_hd__a222oi_1 U18 ( .A1(in__002[9]), .A2(n2), .B1(in__000[9]), 
        .B2(n15), .C1(in__001[9]), .C2(n1), .Y(n8) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(n8), .Y(out[9]) );
  sky130_fd_sc_hd__a222oi_1 U20 ( .A1(in__002[10]), .A2(n2), .B1(in__000[10]), 
        .B2(n15), .C1(in__001[10]), .C2(n1), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(n9), .Y(out[10]) );
  sky130_fd_sc_hd__a222oi_1 U28 ( .A1(in__002[11]), .A2(n2), .B1(in__000[11]), 
        .B2(n15), .C1(in__001[11]), .C2(n1), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(n10), .Y(out[11]) );
  sky130_fd_sc_hd__a222oi_1 U30 ( .A1(in__002[12]), .A2(n2), .B1(in__000[12]), 
        .B2(n15), .C1(in__001[12]), .C2(n1), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n11), .Y(out[12]) );
  sky130_fd_sc_hd__a222oi_1 U32 ( .A1(in__002[13]), .A2(n2), .B1(in__000[13]), 
        .B2(n15), .C1(in__001[13]), .C2(n1), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(n12), .Y(out[13]) );
  sky130_fd_sc_hd__a222oi_1 U35 ( .A1(in__002[14]), .A2(n2), .B1(in__000[14]), 
        .B2(n15), .C1(in__001[14]), .C2(n1), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(n13), .Y(out[14]) );
  sky130_fd_sc_hd__a222oi_1 U37 ( .A1(in__002[15]), .A2(n2), .B1(in__000[15]), 
        .B2(n15), .C1(in__001[15]), .C2(n1), .Y(n14) );
  sky130_fd_sc_hd__inv_1 U38 ( .A(n14), .Y(out[15]) );
endmodule


module Mux_0xdd6473406d1a99a ( clk, in__000, in__001, out, reset, sel );
  input [0:0] clk;
  input [15:0] in__000;
  input [15:0] in__001;
  output [15:0] out;
  input [0:0] reset;
  input [0:0] sel;
  wire   n1, n2;

  sky130_fd_sc_hd__a22o_1 U2 ( .A1(n1), .A2(in__001[9]), .B1(in__000[9]), .B2(
        n2), .X(out[9]) );
  sky130_fd_sc_hd__a22o_1 U3 ( .A1(in__001[8]), .A2(n1), .B1(in__000[8]), .B2(
        n2), .X(out[8]) );
  sky130_fd_sc_hd__a22o_1 U4 ( .A1(in__001[7]), .A2(n1), .B1(in__000[7]), .B2(
        n2), .X(out[7]) );
  sky130_fd_sc_hd__a22o_1 U5 ( .A1(in__001[6]), .A2(n1), .B1(in__000[6]), .B2(
        n2), .X(out[6]) );
  sky130_fd_sc_hd__a22o_1 U6 ( .A1(in__001[5]), .A2(n1), .B1(in__000[5]), .B2(
        n2), .X(out[5]) );
  sky130_fd_sc_hd__a22o_1 U7 ( .A1(in__001[4]), .A2(n1), .B1(in__000[4]), .B2(
        n2), .X(out[4]) );
  sky130_fd_sc_hd__a22o_1 U8 ( .A1(in__001[3]), .A2(n1), .B1(in__000[3]), .B2(
        n2), .X(out[3]) );
  sky130_fd_sc_hd__a22o_1 U9 ( .A1(in__001[2]), .A2(n1), .B1(in__000[2]), .B2(
        n2), .X(out[2]) );
  sky130_fd_sc_hd__a22o_1 U10 ( .A1(in__001[1]), .A2(n1), .B1(in__000[1]), 
        .B2(n2), .X(out[1]) );
  sky130_fd_sc_hd__a22o_1 U11 ( .A1(in__001[15]), .A2(n1), .B1(in__000[15]), 
        .B2(n2), .X(out[15]) );
  sky130_fd_sc_hd__a22o_1 U12 ( .A1(in__001[14]), .A2(n1), .B1(in__000[14]), 
        .B2(n2), .X(out[14]) );
  sky130_fd_sc_hd__a22o_1 U13 ( .A1(in__001[13]), .A2(n1), .B1(in__000[13]), 
        .B2(n2), .X(out[13]) );
  sky130_fd_sc_hd__a22o_1 U14 ( .A1(in__001[12]), .A2(n1), .B1(in__000[12]), 
        .B2(n2), .X(out[12]) );
  sky130_fd_sc_hd__a22o_1 U15 ( .A1(in__001[11]), .A2(n1), .B1(in__000[11]), 
        .B2(n2), .X(out[11]) );
  sky130_fd_sc_hd__a22o_1 U16 ( .A1(in__001[10]), .A2(n1), .B1(in__000[10]), 
        .B2(n2), .X(out[10]) );
  sky130_fd_sc_hd__a22o_1 U17 ( .A1(in__001[0]), .A2(n1), .B1(in__000[0]), 
        .B2(n2), .X(out[0]) );
  sky130_fd_sc_hd__buf_1 U1 ( .A(sel[0]), .X(n1) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(n1), .Y(n2) );
endmodule


module Subtractor_0x422b1f52edd46a85_DW01_sub_1 ( A, B, CI, DIFF, CO );
  input [15:0] A;
  input [15:0] B;
  output [15:0] DIFF;
  input CI;
  output CO;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n17,
         n18, n20, n22, n23, n24, n25, n26, n28, n30, n31, n32, n33, n34, n35,
         n36, n37, n38, n39, n40, n41, n43, n45, n46, n47, n48, n50, n53, n54,
         n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68,
         n69, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n84, n85, n86, n87, n90, n92, n93, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n174, n175, n176, n177;

  sky130_fd_sc_hd__xor2_1 U1 ( .A(n18), .B(n1), .X(DIFF[15]) );
  sky130_fd_sc_hd__nand2_1 U2 ( .A(n177), .B(n17), .Y(n1) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(n103), .B(A[15]), .Y(n17) );
  sky130_fd_sc_hd__xnor2_1 U6 ( .A(n2), .B(n23), .Y(DIFF[14]) );
  sky130_fd_sc_hd__a21oi_1 U7 ( .A1(n23), .A2(n176), .B1(n20), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U10 ( .A(n176), .B(n22), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n104), .B(A[14]), .Y(n22) );
  sky130_fd_sc_hd__xor2_1 U14 ( .A(n26), .B(n3), .X(DIFF[13]) );
  sky130_fd_sc_hd__nand2_1 U16 ( .A(n90), .B(n25), .Y(n3) );
  sky130_fd_sc_hd__nor2_1 U18 ( .A(A[13]), .B(n105), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(n105), .B(A[13]), .Y(n25) );
  sky130_fd_sc_hd__xnor2_1 U20 ( .A(n4), .B(n31), .Y(DIFF[12]) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n175), .B(n30), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U27 ( .A(n106), .B(A[12]), .Y(n30) );
  sky130_fd_sc_hd__xor2_1 U28 ( .A(n34), .B(n5), .X(DIFF[11]) );
  sky130_fd_sc_hd__o21ai_1 U29 ( .A1(n32), .A2(n34), .B1(n33), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(n92), .B(n33), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U32 ( .A(A[11]), .B(n107), .Y(n32) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n107), .B(A[11]), .Y(n33) );
  sky130_fd_sc_hd__xnor2_1 U34 ( .A(n6), .B(n39), .Y(DIFF[10]) );
  sky130_fd_sc_hd__a21oi_1 U35 ( .A1(n54), .A2(n35), .B1(n36), .Y(n34) );
  sky130_fd_sc_hd__nor2_1 U36 ( .A(n37), .B(n40), .Y(n35) );
  sky130_fd_sc_hd__o21ai_1 U37 ( .A1(n37), .A2(n41), .B1(n38), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n93), .B(n38), .Y(n6) );
  sky130_fd_sc_hd__nor2_1 U40 ( .A(A[10]), .B(n108), .Y(n37) );
  sky130_fd_sc_hd__nand2_1 U41 ( .A(n108), .B(A[10]), .Y(n38) );
  sky130_fd_sc_hd__xnor2_1 U42 ( .A(n7), .B(n46), .Y(DIFF[9]) );
  sky130_fd_sc_hd__o21ai_1 U43 ( .A1(n40), .A2(n53), .B1(n41), .Y(n39) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n95), .B(n174), .Y(n40) );
  sky130_fd_sc_hd__a21oi_1 U45 ( .A1(n174), .A2(n50), .B1(n43), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(n174), .B(n45), .Y(n7) );
  sky130_fd_sc_hd__nand2_1 U51 ( .A(n109), .B(A[9]), .Y(n45) );
  sky130_fd_sc_hd__xor2_1 U52 ( .A(n53), .B(n8), .X(DIFF[8]) );
  sky130_fd_sc_hd__o21ai_1 U53 ( .A1(n47), .A2(n53), .B1(n48), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U58 ( .A(n95), .B(n48), .Y(n8) );
  sky130_fd_sc_hd__nor2_1 U60 ( .A(A[8]), .B(n110), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n110), .B(A[8]), .Y(n48) );
  sky130_fd_sc_hd__xnor2_1 U62 ( .A(n9), .B(n61), .Y(DIFF[7]) );
  sky130_fd_sc_hd__o21ai_1 U64 ( .A1(n55), .A2(n75), .B1(n56), .Y(n54) );
  sky130_fd_sc_hd__nand2_1 U65 ( .A(n57), .B(n65), .Y(n55) );
  sky130_fd_sc_hd__a21oi_1 U66 ( .A1(n57), .A2(n66), .B1(n58), .Y(n56) );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(n59), .B(n62), .Y(n57) );
  sky130_fd_sc_hd__o21ai_1 U68 ( .A1(n63), .A2(n59), .B1(n60), .Y(n58) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n96), .B(n60), .Y(n9) );
  sky130_fd_sc_hd__nor2_1 U71 ( .A(A[7]), .B(n111), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(n111), .B(A[7]), .Y(n60) );
  sky130_fd_sc_hd__xor2_1 U73 ( .A(n64), .B(n10), .X(DIFF[6]) );
  sky130_fd_sc_hd__o21ai_1 U74 ( .A1(n62), .A2(n64), .B1(n63), .Y(n61) );
  sky130_fd_sc_hd__nand2_1 U75 ( .A(n97), .B(n63), .Y(n10) );
  sky130_fd_sc_hd__nor2_1 U77 ( .A(A[6]), .B(n112), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U78 ( .A(n112), .B(A[6]), .Y(n63) );
  sky130_fd_sc_hd__xor2_1 U79 ( .A(n69), .B(n11), .X(DIFF[5]) );
  sky130_fd_sc_hd__a21oi_1 U80 ( .A1(n74), .A2(n65), .B1(n66), .Y(n64) );
  sky130_fd_sc_hd__nor2_1 U81 ( .A(n72), .B(n67), .Y(n65) );
  sky130_fd_sc_hd__o21ai_1 U82 ( .A1(n73), .A2(n67), .B1(n68), .Y(n66) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n98), .B(n68), .Y(n11) );
  sky130_fd_sc_hd__nor2_1 U85 ( .A(A[5]), .B(n113), .Y(n67) );
  sky130_fd_sc_hd__nand2_1 U86 ( .A(n113), .B(A[5]), .Y(n68) );
  sky130_fd_sc_hd__xnor2_1 U87 ( .A(n12), .B(n74), .Y(DIFF[4]) );
  sky130_fd_sc_hd__a21oi_1 U88 ( .A1(n74), .A2(n99), .B1(n71), .Y(n69) );
  sky130_fd_sc_hd__nand2_1 U91 ( .A(n99), .B(n73), .Y(n12) );
  sky130_fd_sc_hd__nor2_1 U93 ( .A(A[4]), .B(n114), .Y(n72) );
  sky130_fd_sc_hd__nand2_1 U94 ( .A(n114), .B(A[4]), .Y(n73) );
  sky130_fd_sc_hd__xnor2_1 U95 ( .A(n13), .B(n80), .Y(DIFF[3]) );
  sky130_fd_sc_hd__a21oi_1 U97 ( .A1(n76), .A2(n84), .B1(n77), .Y(n75) );
  sky130_fd_sc_hd__nor2_1 U98 ( .A(n78), .B(n81), .Y(n76) );
  sky130_fd_sc_hd__o21ai_1 U99 ( .A1(n82), .A2(n78), .B1(n79), .Y(n77) );
  sky130_fd_sc_hd__nand2_1 U100 ( .A(n100), .B(n79), .Y(n13) );
  sky130_fd_sc_hd__nor2_1 U102 ( .A(A[3]), .B(n115), .Y(n78) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n115), .B(A[3]), .Y(n79) );
  sky130_fd_sc_hd__xor2_1 U104 ( .A(n83), .B(n14), .X(DIFF[2]) );
  sky130_fd_sc_hd__o21ai_1 U105 ( .A1(n81), .A2(n83), .B1(n82), .Y(n80) );
  sky130_fd_sc_hd__nand2_1 U106 ( .A(n101), .B(n82), .Y(n14) );
  sky130_fd_sc_hd__nor2_1 U108 ( .A(A[2]), .B(n116), .Y(n81) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(n116), .B(A[2]), .Y(n82) );
  sky130_fd_sc_hd__xor2_1 U110 ( .A(n15), .B(n87), .X(DIFF[1]) );
  sky130_fd_sc_hd__o21ai_1 U112 ( .A1(n87), .A2(n85), .B1(n86), .Y(n84) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(n102), .B(n86), .Y(n15) );
  sky130_fd_sc_hd__nor2_1 U115 ( .A(A[1]), .B(n117), .Y(n85) );
  sky130_fd_sc_hd__nand2_1 U116 ( .A(n117), .B(A[1]), .Y(n86) );
  sky130_fd_sc_hd__xnor2_1 U117 ( .A(A[0]), .B(n118), .Y(DIFF[0]) );
  sky130_fd_sc_hd__nor2_1 U118 ( .A(A[0]), .B(n118), .Y(n87) );
  sky130_fd_sc_hd__inv_2 U138 ( .A(B[1]), .Y(n117) );
  sky130_fd_sc_hd__inv_2 U139 ( .A(B[2]), .Y(n116) );
  sky130_fd_sc_hd__inv_2 U140 ( .A(B[3]), .Y(n115) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(B[5]), .Y(n113) );
  sky130_fd_sc_hd__inv_2 U142 ( .A(B[6]), .Y(n112) );
  sky130_fd_sc_hd__inv_2 U143 ( .A(B[7]), .Y(n111) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(B[10]), .Y(n108) );
  sky130_fd_sc_hd__inv_2 U145 ( .A(B[13]), .Y(n105) );
  sky130_fd_sc_hd__clkinv_1 U146 ( .A(B[0]), .Y(n118) );
  sky130_fd_sc_hd__inv_2 U147 ( .A(n84), .Y(n83) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(n72), .Y(n99) );
  sky130_fd_sc_hd__inv_2 U149 ( .A(n73), .Y(n71) );
  sky130_fd_sc_hd__inv_2 U150 ( .A(n47), .Y(n95) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(n45), .Y(n43) );
  sky130_fd_sc_hd__inv_2 U152 ( .A(n48), .Y(n50) );
  sky130_fd_sc_hd__inv_2 U153 ( .A(n54), .Y(n53) );
  sky130_fd_sc_hd__inv_2 U154 ( .A(n30), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(B[4]), .Y(n114) );
  sky130_fd_sc_hd__inv_2 U156 ( .A(B[9]), .Y(n109) );
  sky130_fd_sc_hd__inv_2 U157 ( .A(B[8]), .Y(n110) );
  sky130_fd_sc_hd__inv_2 U158 ( .A(B[12]), .Y(n106) );
  sky130_fd_sc_hd__inv_2 U159 ( .A(B[14]), .Y(n104) );
  sky130_fd_sc_hd__inv_2 U160 ( .A(n22), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U161 ( .A(n85), .Y(n102) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(n81), .Y(n101) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(n78), .Y(n100) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(n67), .Y(n98) );
  sky130_fd_sc_hd__inv_2 U165 ( .A(n62), .Y(n97) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(n59), .Y(n96) );
  sky130_fd_sc_hd__inv_2 U167 ( .A(n37), .Y(n93) );
  sky130_fd_sc_hd__inv_2 U168 ( .A(n32), .Y(n92) );
  sky130_fd_sc_hd__inv_2 U169 ( .A(n24), .Y(n90) );
  sky130_fd_sc_hd__inv_1 U170 ( .A(B[15]), .Y(n103) );
  sky130_fd_sc_hd__or2_2 U171 ( .A(A[9]), .B(n109), .X(n174) );
  sky130_fd_sc_hd__or2_2 U172 ( .A(A[12]), .B(n106), .X(n175) );
  sky130_fd_sc_hd__or2_2 U173 ( .A(A[14]), .B(n104), .X(n176) );
  sky130_fd_sc_hd__or2_2 U174 ( .A(A[15]), .B(n103), .X(n177) );
  sky130_fd_sc_hd__inv_2 U175 ( .A(n75), .Y(n74) );
  sky130_fd_sc_hd__a21oi_2 U176 ( .A1(n31), .A2(n175), .B1(n28), .Y(n26) );
  sky130_fd_sc_hd__o21ai_2 U177 ( .A1(n24), .A2(n26), .B1(n25), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U178 ( .A(B[11]), .Y(n107) );
endmodule


module Subtractor_0x422b1f52edd46a85 ( clk, in0, in1, out, reset );
  input [0:0] clk;
  input [15:0] in0;
  input [15:0] in1;
  output [15:0] out;
  input [0:0] reset;
  wire   n1;

  Subtractor_0x422b1f52edd46a85_DW01_sub_1 sub_752 ( .A(in0), .B(in1), .CI(n1), 
        .DIFF(out) );
  sky130_fd_sc_hd__conb_1 U1 ( .LO(n1) );
endmodule


module RegEn_0x68db79c4ec1d6e5b_1 ( clk, en, in_, out, reset );
  input [0:0] clk;
  input [0:0] en;
  input [15:0] in_;
  output [15:0] out;
  input [0:0] reset;
  wire   n1;

  sky130_fd_sc_hd__edfxtp_1 out_reg_15_ ( .D(in_[15]), .DE(n1), .CLK(clk[0]), 
        .Q(out[15]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_14_ ( .D(in_[14]), .DE(n1), .CLK(clk[0]), 
        .Q(out[14]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_13_ ( .D(in_[13]), .DE(n1), .CLK(clk[0]), 
        .Q(out[13]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_12_ ( .D(in_[12]), .DE(n1), .CLK(clk[0]), 
        .Q(out[12]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_11_ ( .D(in_[11]), .DE(n1), .CLK(clk[0]), 
        .Q(out[11]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_10_ ( .D(in_[10]), .DE(n1), .CLK(clk[0]), 
        .Q(out[10]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_9_ ( .D(in_[9]), .DE(n1), .CLK(clk[0]), 
        .Q(out[9]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_8_ ( .D(in_[8]), .DE(n1), .CLK(clk[0]), 
        .Q(out[8]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_7_ ( .D(in_[7]), .DE(n1), .CLK(clk[0]), 
        .Q(out[7]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_6_ ( .D(in_[6]), .DE(n1), .CLK(clk[0]), 
        .Q(out[6]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_5_ ( .D(in_[5]), .DE(n1), .CLK(clk[0]), 
        .Q(out[5]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_4_ ( .D(in_[4]), .DE(n1), .CLK(clk[0]), 
        .Q(out[4]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_3_ ( .D(in_[3]), .DE(n1), .CLK(clk[0]), 
        .Q(out[3]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_2_ ( .D(in_[2]), .DE(n1), .CLK(clk[0]), 
        .Q(out[2]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_1_ ( .D(in_[1]), .DE(n1), .CLK(clk[0]), 
        .Q(out[1]) );
  sky130_fd_sc_hd__edfxtp_1 out_reg_0_ ( .D(in_[0]), .DE(n1), .CLK(clk[0]), 
        .Q(out[0]) );
  sky130_fd_sc_hd__buf_1 U2 ( .A(en[0]), .X(n1) );
endmodule


module GcdUnitDpathRTL_0x4d0fc71ead8d3d9e ( a_mux_sel, a_reg_en, b_mux_sel, 
        b_reg_en, clk, is_a_lt_b, is_b_zero, req_msg_a, req_msg_b, reset, 
        resp_msg );
  input [1:0] a_mux_sel;
  input [0:0] a_reg_en;
  input [0:0] b_mux_sel;
  input [0:0] b_reg_en;
  input [0:0] clk;
  output [0:0] is_a_lt_b;
  output [0:0] is_b_zero;
  input [15:0] req_msg_a;
  input [15:0] req_msg_b;
  input [0:0] reset;
  output [15:0] resp_msg;

  wire   [15:0] a_reg_out;
  wire   [15:0] a_mux_out;
  wire   [15:0] b_mux_out;
  wire   [15:0] b_reg_out;

  RegEn_0x68db79c4ec1d6e5b_0 a_reg ( .clk(clk[0]), .en(a_reg_en[0]), .in_(
        a_mux_out), .out(a_reg_out), .reset(reset[0]) );
  LtComparator_0x422b1f52edd46a85 a_lt_b ( .clk(clk[0]), .in0(a_reg_out), 
        .in1(b_reg_out), .out(is_a_lt_b[0]), .reset(reset[0]) );
  ZeroComparator_0x422b1f52edd46a85 b_zero ( .clk(clk[0]), .in_(b_reg_out), 
        .out(is_b_zero[0]), .reset(reset[0]) );
  Mux_0x683fa1a418b072c9 a_mux ( .clk(clk[0]), .in__000(req_msg_a), .in__001(
        resp_msg), .in__002(b_reg_out), .out(a_mux_out), .reset(reset[0]), 
        .sel(a_mux_sel) );
  Mux_0xdd6473406d1a99a b_mux ( .clk(clk[0]), .in__000(a_reg_out), .in__001(
        req_msg_b), .out(b_mux_out), .reset(reset[0]), .sel(b_mux_sel[0]) );
  Subtractor_0x422b1f52edd46a85 sub ( .clk(clk[0]), .in0(a_reg_out), .in1(
        b_reg_out), .out(resp_msg), .reset(reset[0]) );
  RegEn_0x68db79c4ec1d6e5b_1 b_reg ( .clk(clk[0]), .en(b_reg_en[0]), .in_(
        b_mux_out), .out(b_reg_out), .reset(reset[0]) );
endmodule


module gcd ( clk, req_msg, req_rdy, req_val, reset, resp_msg, resp_rdy, 
        resp_val );
  input [31:0] req_msg;
  output [15:0] resp_msg;
  input clk, req_val, reset, resp_rdy;
  output req_rdy, resp_val;
  wire   \ctrl_b_mux_sel[0] , \ctrl_b_reg_en[0] , \ctrl_a_reg_en[0] ,
         \dpath_is_b_zero[0] , \dpath_is_a_lt_b[0] ;
  wire   [1:0] ctrl_a_mux_sel;

  GcdUnitCtrlRTL_0x4d0fc71ead8d3d9e ctrl ( .a_mux_sel(ctrl_a_mux_sel), 
        .a_reg_en(\ctrl_a_reg_en[0] ), .b_mux_sel(\ctrl_b_mux_sel[0] ), 
        .b_reg_en(\ctrl_b_reg_en[0] ), .clk(clk), .is_a_lt_b(
        \dpath_is_a_lt_b[0] ), .is_b_zero(\dpath_is_b_zero[0] ), .req_rdy(
        req_rdy), .req_val(req_val), .reset(reset), .resp_rdy(resp_rdy), 
        .resp_val(resp_val) );
  GcdUnitDpathRTL_0x4d0fc71ead8d3d9e dpath ( .a_mux_sel(ctrl_a_mux_sel), 
        .a_reg_en(\ctrl_a_reg_en[0] ), .b_mux_sel(\ctrl_b_mux_sel[0] ), 
        .b_reg_en(\ctrl_b_reg_en[0] ), .clk(clk), .is_a_lt_b(
        \dpath_is_a_lt_b[0] ), .is_b_zero(\dpath_is_b_zero[0] ), .req_msg_a(
        req_msg[31:16]), .req_msg_b(req_msg[15:0]), .reset(reset), .resp_msg(
        resp_msg) );
endmodule

