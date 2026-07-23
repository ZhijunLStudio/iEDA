/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 16:34:56 2025
/////////////////////////////////////////////////////////////


module dff_0 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_1 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_2 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_3 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_4 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_5 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_6 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_4 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_7 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_8 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_9 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_10 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_11 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_12 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_13 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_14 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_15 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_16 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module dff_17 ( CK, Q, D );
  input CK, D;
  output Q;


  sky130_fd_sc_hd__dfxtp_1 Q_reg ( .D(D), .CLK(CK), .Q(Q) );
endmodule


module s1238 ( CK, G0, G1, G10, G11, G12, G13, G2, G3, G4, G45, G5, G530, G532, 
        G535, G537, G539, G542, G546, G547, G548, G549, G550, G551, G552, G6, 
        G7, G8, G9 );
  input CK, G0, G1, G10, G11, G12, G13, G2, G3, G4, G5, G6, G7, G8, G9;
  output G45, G530, G532, G535, G537, G539, G542, G546, G547, G548, G549, G550,
         G551, G552;
  wire   G29, G502, G30, G31, G32, G33, G506, G34, G507, G35, G36, G509, G37,
         G38, G511, G39, G40, G513, G41, G514, G42, G515, G43, G516, G44, G517,
         G46, G519, n1, n2, n3, n5, n9, n11, n17, n18, n19, n20, n21, n23, n24,
         n25, n27, n28, n31, n32, n33, n34, n35, n36, n37, n38, n39, n41, n42,
         n43, n44, n45, n49, n53, n57, n58, n59, n62, n63, n65, n66, n67, n68,
         n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n86,
         n87, n89, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101,
         n103, n104, n106, n107, n110, n112, n117, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n129, n130, n131, n132, n133, n134,
         n135, n136, n137, n138, n139, n140, n141, n142, n143, n144, n145,
         n146, n147, n149, n150, n151, n152, n153, n154, n155, n156, n157,
         n158, n159, n160, n161, n162, n163, n164, n165, n166, n167, n168,
         n169, n170, n171, n172, n173, n174, n175, n176, n177, n178, n179,
         n180, n181, n183, n184, n185, n186, n187, n188, n189, n190, n191,
         n192, n193, n194, n195, n196, n197, n198, n199, n200, n201, n202,
         n204, n212, n213, n214, n215, n216, n218, n219, n227, n228, n230,
         n231, n232, n233, n234, n235, n236, n237, n238, n239, n240, n241,
         n242, n243, n244, n245, n246, n247, n248, n249, n250, n251, n252,
         n253, n254, n255, n256, n257, n258, n259, n260, n261, n262, n263,
         n264, n265, n266, n267, n268, n269, n270, n271, n272, n273, n274,
         n275, n276, n277, n278, n279, n280, n281, n282, n283, n284, n285,
         n286, n287, n288, n289, n290, n291, n292, n293, n294, n295, n296,
         n297, n298, n299, n300, n301, n302, n303, n304, n305, n306, n307,
         n308, n309, n310, n311, n312;

  dff_0 DFF_0 ( .CK(CK), .Q(G29), .D(G502) );
  dff_17 DFF_1 ( .CK(CK), .Q(G30), .D(n232) );
  dff_16 DFF_2 ( .CK(CK), .Q(G31), .D(n233) );
  dff_15 DFF_3 ( .CK(CK), .Q(G32), .D(n234) );
  dff_14 DFF_4 ( .CK(CK), .Q(G33), .D(G506) );
  dff_13 DFF_5 ( .CK(CK), .Q(G34), .D(G507) );
  dff_12 DFF_6 ( .CK(CK), .Q(G35), .D(n231) );
  dff_11 DFF_7 ( .CK(CK), .Q(G36), .D(G509) );
  dff_10 DFF_8 ( .CK(CK), .Q(G37), .D(n236) );
  dff_9 DFF_9 ( .CK(CK), .Q(G38), .D(G511) );
  dff_8 DFF_10 ( .CK(CK), .Q(G39), .D(n235) );
  dff_7 DFF_11 ( .CK(CK), .Q(G40), .D(G513) );
  dff_6 DFF_12 ( .CK(CK), .Q(G41), .D(G514) );
  dff_5 DFF_13 ( .CK(CK), .Q(G42), .D(G515) );
  dff_4 DFF_14 ( .CK(CK), .Q(G43), .D(G516) );
  dff_3 DFF_15 ( .CK(CK), .Q(G44), .D(G517) );
  dff_2 DFF_16 ( .CK(CK), .Q(G45), .D(n230) );
  dff_1 DFF_17 ( .CK(CK), .Q(G46), .D(G519) );
  sky130_fd_sc_hd__o21ai_1 U51 ( .A1(n162), .A2(n169), .B1(n161), .Y(n168) );
  sky130_fd_sc_hd__o21ai_1 U61 ( .A1(n177), .A2(n9), .B1(n31), .Y(n123) );
  sky130_fd_sc_hd__o21ai_1 U67 ( .A1(n19), .A2(n49), .B1(n24), .Y(n183) );
  sky130_fd_sc_hd__o21ai_1 U77 ( .A1(n158), .A2(n306), .B1(G0), .Y(n191) );
  sky130_fd_sc_hd__o21ai_1 U102 ( .A1(G5), .A2(n21), .B1(n134), .Y(G509) );
  sky130_fd_sc_hd__o21ai_1 U111 ( .A1(G1), .A2(n43), .B1(n95), .Y(n216) );
  sky130_fd_sc_hd__nand2_1 U194 ( .A(n303), .B(n28), .Y(n232) );
  sky130_fd_sc_hd__xnor2_1 U195 ( .A(G2), .B(n38), .Y(n235) );
  sky130_fd_sc_hd__xnor2_1 U196 ( .A(n312), .B(G6), .Y(n236) );
  sky130_fd_sc_hd__nand2_1 U197 ( .A(n71), .B(n72), .Y(n70) );
  sky130_fd_sc_hd__a31oi_1 U200 ( .A1(n97), .A2(n33), .A3(n71), .B1(n98), .Y(
        n96) );
  sky130_fd_sc_hd__xnor2_1 U201 ( .A(n89), .B(G5), .Y(n99) );
  sky130_fd_sc_hd__o21a_1 U204 ( .A1(n38), .A2(G4), .B1(n68), .X(n107) );
  sky130_fd_sc_hd__or3_1 U205 ( .A(G33), .B(G13), .C(n306), .X(n100) );
  sky130_fd_sc_hd__nand2_1 U206 ( .A(G7), .B(n20), .Y(n112) );
  sky130_fd_sc_hd__a31oi_1 U210 ( .A1(n62), .A2(n120), .A3(n238), .B1(n121), 
        .Y(n119) );
  sky130_fd_sc_hd__nand2_1 U211 ( .A(n124), .B(n125), .Y(G537) );
  sky130_fd_sc_hd__and4_1 U212 ( .A(n312), .B(G6), .C(n240), .D(G38), .X(n129)
         );
  sky130_fd_sc_hd__a222oi_1 U213 ( .A1(n5), .A2(n130), .B1(n131), .B2(n39), 
        .C1(n132), .C2(n133), .Y(n124) );
  sky130_fd_sc_hd__a31oi_1 U214 ( .A1(n240), .A2(G37), .A3(G38), .B1(n139), 
        .Y(n138) );
  sky130_fd_sc_hd__o21a_1 U215 ( .A1(n237), .A2(n141), .B1(n136), .X(n140) );
  sky130_fd_sc_hd__nor2b_1 U217 ( .B_N(n142), .A(n18), .Y(n63) );
  sky130_fd_sc_hd__a31oi_1 U218 ( .A1(G511), .A2(n127), .A3(G37), .B1(n145), 
        .Y(n143) );
  sky130_fd_sc_hd__nand4_1 U219 ( .A(n295), .B(n306), .C(n308), .D(n312), .Y(
        n146) );
  sky130_fd_sc_hd__nand2b_1 U221 ( .A_N(n158), .B(n159), .Y(n155) );
  sky130_fd_sc_hd__nand2_1 U222 ( .A(n126), .B(n160), .Y(n137) );
  sky130_fd_sc_hd__a32oi_1 U223 ( .A1(n161), .A2(n162), .A3(n126), .B1(n163), 
        .B2(n164), .Y(n150) );
  sky130_fd_sc_hd__nand2_1 U224 ( .A(n165), .B(n305), .Y(n136) );
  sky130_fd_sc_hd__and2_0 U225 ( .A(n166), .B(n305), .X(n126) );
  sky130_fd_sc_hd__o21bai_1 U226 ( .A1(n11), .A2(n123), .B1_N(n165), .Y(n166)
         );
  sky130_fd_sc_hd__nand2_1 U227 ( .A(n67), .B(n66), .Y(n172) );
  sky130_fd_sc_hd__a31oi_1 U228 ( .A1(n81), .A2(n162), .A3(n67), .B1(n180), 
        .Y(n179) );
  sky130_fd_sc_hd__nand2b_1 U229 ( .A_N(n144), .B(G35), .Y(n181) );
  sky130_fd_sc_hd__nand2_1 U230 ( .A(G2), .B(G11), .Y(n144) );
  sky130_fd_sc_hd__and2_0 U231 ( .A(n241), .B(n301), .X(n162) );
  sky130_fd_sc_hd__a31oi_1 U232 ( .A1(G11), .A2(n183), .A3(n39), .B1(n184), 
        .Y(n178) );
  sky130_fd_sc_hd__nand2_1 U233 ( .A(n67), .B(n308), .Y(n141) );
  sky130_fd_sc_hd__or2_0 U234 ( .A(n86), .B(n18), .X(n159) );
  sky130_fd_sc_hd__nand2_1 U235 ( .A(G5), .B(n306), .Y(n86) );
  sky130_fd_sc_hd__a221o_1 U236 ( .A1(n308), .A2(n156), .B1(n307), .B2(n97), 
        .C1(n188), .X(n186) );
  sky130_fd_sc_hd__nand2_1 U237 ( .A(n192), .B(n95), .Y(n188) );
  sky130_fd_sc_hd__and2_0 U238 ( .A(n59), .B(n310), .X(n164) );
  sky130_fd_sc_hd__nand4_1 U239 ( .A(n89), .B(G2), .C(G3), .D(n309), .Y(n199)
         );
  sky130_fd_sc_hd__a222oi_1 U240 ( .A1(n201), .A2(n285), .B1(n202), .B2(n302), 
        .C1(G7), .C2(n204), .Y(G515) );
  sky130_fd_sc_hd__and3_1 U244 ( .A(G7), .B(n303), .C(n242), .X(G511) );
  sky130_fd_sc_hd__nand2b_1 U245 ( .A_N(n71), .B(n2), .Y(G507) );
  sky130_fd_sc_hd__nor2b_1 U246 ( .B_N(n62), .A(n120), .Y(n104) );
  sky130_fd_sc_hd__nand2b_1 U247 ( .A_N(n177), .B(n212), .Y(n120) );
  sky130_fd_sc_hd__a31oi_1 U248 ( .A1(n74), .A2(n37), .A3(n192), .B1(n309), 
        .Y(n215) );
  sky130_fd_sc_hd__nand2_1 U249 ( .A(G4), .B(n38), .Y(n192) );
  sky130_fd_sc_hd__nand2_1 U250 ( .A(G2), .B(n306), .Y(n74) );
  sky130_fd_sc_hd__nand2_1 U251 ( .A(n76), .B(n309), .Y(n106) );
  sky130_fd_sc_hd__nand2_1 U252 ( .A(G2), .B(n216), .Y(n198) );
  sky130_fd_sc_hd__nand2_1 U254 ( .A(G8), .B(n66), .Y(n219) );
  sky130_fd_sc_hd__nand2_1 U257 ( .A(G3), .B(n18), .Y(n228) );
  sky130_fd_sc_hd__nand2_1 U258 ( .A(G5), .B(n18), .Y(n95) );
  sky130_fd_sc_hd__clkinv_2 U259 ( .A(n286), .Y(n275) );
  sky130_fd_sc_hd__nand4_2 U260 ( .A(n257), .B(G12), .C(n243), .D(n31), .Y(
        n286) );
  sky130_fd_sc_hd__or3_1 U261 ( .A(n11), .B(G12), .C(n123), .X(n237) );
  sky130_fd_sc_hd__o32a_1 U262 ( .A1(n36), .A2(G5), .A3(n167), .B1(n18), .B2(
        n168), .X(n238) );
  sky130_fd_sc_hd__inv_2 U263 ( .A(n275), .Y(n239) );
  sky130_fd_sc_hd__inv_2 U264 ( .A(n104), .Y(n2) );
  sky130_fd_sc_hd__inv_2 U265 ( .A(n78), .Y(n45) );
  sky130_fd_sc_hd__inv_2 U266 ( .A(n97), .Y(n38) );
  sky130_fd_sc_hd__inv_2 U267 ( .A(n169), .Y(n21) );
  sky130_fd_sc_hd__inv_2 U268 ( .A(n66), .Y(n27) );
  sky130_fd_sc_hd__a21oi_1 U269 ( .A1(n136), .A2(n237), .B1(n141), .Y(n163) );
  sky130_fd_sc_hd__a21oi_1 U270 ( .A1(n136), .A2(n237), .B1(n24), .Y(n131) );
  sky130_fd_sc_hd__inv_2 U271 ( .A(n91), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U272 ( .A(n161), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U273 ( .A(n130), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U274 ( .A(n81), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U275 ( .A(n147), .Y(n246) );
  sky130_fd_sc_hd__inv_2 U276 ( .A(n137), .Y(n5) );
  sky130_fd_sc_hd__inv_2 U277 ( .A(n141), .Y(n39) );
  sky130_fd_sc_hd__inv_2 U278 ( .A(n122), .Y(n11) );
  sky130_fd_sc_hd__nor2_1 U279 ( .A(n309), .B(n307), .Y(n78) );
  sky130_fd_sc_hd__nor3_1 U280 ( .A(n285), .B(n311), .C(n27), .Y(n169) );
  sky130_fd_sc_hd__nor2_1 U281 ( .A(n18), .B(n306), .Y(n156) );
  sky130_fd_sc_hd__o31ai_1 U282 ( .A1(n303), .A2(n312), .A3(n147), .B1(n25), 
        .Y(n152) );
  sky130_fd_sc_hd__nor3_1 U283 ( .A(n45), .B(n36), .C(n38), .Y(n161) );
  sky130_fd_sc_hd__nor2_1 U284 ( .A(n18), .B(n307), .Y(n89) );
  sky130_fd_sc_hd__nor2_1 U285 ( .A(n304), .B(n312), .Y(n66) );
  sky130_fd_sc_hd__nor2_1 U286 ( .A(n45), .B(n306), .Y(n67) );
  sky130_fd_sc_hd__a22oi_1 U287 ( .A1(n18), .A2(n67), .B1(n156), .B2(n160), 
        .Y(n174) );
  sky130_fd_sc_hd__nor2_1 U288 ( .A(n308), .B(n306), .Y(n97) );
  sky130_fd_sc_hd__nor2_1 U289 ( .A(n65), .B(n311), .Y(n130) );
  sky130_fd_sc_hd__nor2_1 U290 ( .A(n308), .B(n36), .Y(n81) );
  sky130_fd_sc_hd__nor2_1 U291 ( .A(n44), .B(n36), .Y(n77) );
  sky130_fd_sc_hd__nor2_1 U292 ( .A(n74), .B(n43), .Y(n80) );
  sky130_fd_sc_hd__nor2_1 U293 ( .A(n36), .B(n307), .Y(n91) );
  sky130_fd_sc_hd__nor2_1 U294 ( .A(n38), .B(n311), .Y(n127) );
  sky130_fd_sc_hd__o221ai_1 U295 ( .A1(n21), .A2(n44), .B1(n41), .B2(n134), 
        .C1(n135), .Y(n133) );
  sky130_fd_sc_hd__o221ai_1 U296 ( .A1(n67), .A2(n35), .B1(n43), .B2(n37), 
        .C1(n68), .Y(n234) );
  sky130_fd_sc_hd__o22ai_1 U297 ( .A1(n33), .A2(n95), .B1(n37), .B2(n260), .Y(
        n93) );
  sky130_fd_sc_hd__inv_2 U298 ( .A(n75), .Y(n37) );
  sky130_fd_sc_hd__inv_2 U299 ( .A(n160), .Y(n43) );
  sky130_fd_sc_hd__nand3_1 U300 ( .A(n303), .B(n308), .C(n241), .Y(n134) );
  sky130_fd_sc_hd__nor2_1 U301 ( .A(n27), .B(n309), .Y(n201) );
  sky130_fd_sc_hd__o211ai_1 U302 ( .A1(n149), .A2(n3), .B1(n150), .C1(n151), 
        .Y(G532) );
  sky130_fd_sc_hd__a21oi_1 U303 ( .A1(n5), .A2(n152), .B1(n153), .Y(n151) );
  sky130_fd_sc_hd__a21oi_1 U304 ( .A1(n130), .A2(n78), .B1(n175), .Y(n149) );
  sky130_fd_sc_hd__nor2_1 U305 ( .A(n31), .B(n238), .Y(n165) );
  sky130_fd_sc_hd__nor2_1 U306 ( .A(n38), .B(n307), .Y(n158) );
  sky130_fd_sc_hd__inv_2 U307 ( .A(n49), .Y(n300) );
  sky130_fd_sc_hd__inv_2 U308 ( .A(n57), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U309 ( .A(n19), .Y(n301) );
  sky130_fd_sc_hd__inv_2 U310 ( .A(n175), .Y(n41) );
  sky130_fd_sc_hd__inv_2 U311 ( .A(n44), .Y(n94) );
  sky130_fd_sc_hd__inv_2 U312 ( .A(n285), .Y(n299) );
  sky130_fd_sc_hd__inv_2 U313 ( .A(n20), .Y(n302) );
  sky130_fd_sc_hd__inv_2 U314 ( .A(n132), .Y(n3) );
  sky130_fd_sc_hd__and3b_1 U315 ( .B(n127), .C(n63), .A_N(n283), .X(n240) );
  sky130_fd_sc_hd__and2_0 U316 ( .A(n246), .B(n304), .X(n241) );
  sky130_fd_sc_hd__inv_2 U317 ( .A(n289), .Y(n298) );
  sky130_fd_sc_hd__and2_0 U318 ( .A(n307), .B(n295), .X(n242) );
  sky130_fd_sc_hd__nor2_1 U319 ( .A(n256), .B(n255), .Y(n257) );
  sky130_fd_sc_hd__a21oi_1 U320 ( .A1(n250), .A2(n249), .B1(n304), .Y(n256) );
  sky130_fd_sc_hd__nand3_1 U321 ( .A(n248), .B(n247), .C(n290), .Y(n249) );
  sky130_fd_sc_hd__nor2_1 U322 ( .A(G11), .B(G10), .Y(n251) );
  sky130_fd_sc_hd__o221ai_1 U323 ( .A1(G2), .A2(n178), .B1(n34), .B2(n21), 
        .C1(n179), .Y(n122) );
  sky130_fd_sc_hd__nor4_1 U324 ( .A(n181), .B(n306), .C(G5), .D(G4), .Y(n180)
         );
  sky130_fd_sc_hd__o311ai_1 U325 ( .A1(n260), .A2(G6), .A3(n36), .B1(n198), 
        .C1(n213), .Y(n212) );
  sky130_fd_sc_hd__o31ai_1 U326 ( .A1(n214), .A2(n42), .A3(n215), .B1(G1), .Y(
        n213) );
  sky130_fd_sc_hd__inv_2 U327 ( .A(n106), .Y(n42) );
  sky130_fd_sc_hd__o41ai_1 U328 ( .A1(n24), .A2(n304), .A3(n45), .A4(n86), 
        .B1(n185), .Y(n184) );
  sky130_fd_sc_hd__nand3_1 U329 ( .A(n306), .B(n309), .C(G36), .Y(n185) );
  sky130_fd_sc_hd__nor4_1 U330 ( .A(n9), .B(n177), .C(G12), .D(G13), .Y(n71)
         );
  sky130_fd_sc_hd__nor4b_1 U331 ( .D_N(n77), .A(G12), .B(n177), .C(n9), .Y(
        n218) );
  sky130_fd_sc_hd__inv_2 U332 ( .A(n294), .Y(n297) );
  sky130_fd_sc_hd__o21a_1 U333 ( .A1(n94), .A2(n245), .B1(G46), .X(n243) );
  sky130_fd_sc_hd__inv_2 U334 ( .A(G32), .Y(n9) );
  sky130_fd_sc_hd__o32ai_1 U335 ( .A1(n295), .A2(n34), .A3(n21), .B1(n143), 
        .B2(n144), .Y(n142) );
  sky130_fd_sc_hd__nor4_1 U336 ( .A(n146), .B(n43), .C(n147), .D(n303), .Y(
        n145) );
  sky130_fd_sc_hd__a311oi_1 U337 ( .A1(n1), .A2(n309), .A3(n303), .B1(n189), 
        .C1(n190), .Y(G519) );
  sky130_fd_sc_hd__o22ai_1 U338 ( .A1(G6), .A2(G7), .B1(G1), .B2(n193), .Y(
        n189) );
  sky130_fd_sc_hd__a211oi_1 U339 ( .A1(G1), .A2(n191), .B1(n188), .C1(n36), 
        .Y(n190) );
  sky130_fd_sc_hd__nor2_1 U340 ( .A(n306), .B(G2), .Y(n75) );
  sky130_fd_sc_hd__a221oi_1 U341 ( .A1(n155), .A2(n36), .B1(n156), .B2(n307), 
        .C1(n157), .Y(n154) );
  sky130_fd_sc_hd__o22ai_1 U342 ( .A1(G3), .A2(n44), .B1(n156), .B2(n33), .Y(
        n157) );
  sky130_fd_sc_hd__a221oi_1 U343 ( .A1(n164), .A2(n17), .B1(G11), .B2(n170), 
        .C1(n171), .Y(n167) );
  sky130_fd_sc_hd__inv_2 U344 ( .A(n174), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U345 ( .A(n309), .B(n28), .Y(n202) );
  sky130_fd_sc_hd__o32ai_1 U346 ( .A1(n304), .A2(G6), .A3(n301), .B1(G8), .B2(
        n28), .Y(n204) );
  sky130_fd_sc_hd__nor4_1 U347 ( .A(n172), .B(n49), .C(G10), .D(G1), .Y(n171)
         );
  sky130_fd_sc_hd__o32ai_1 U348 ( .A1(n173), .A2(n65), .A3(n41), .B1(n174), 
        .B2(n25), .Y(n170) );
  sky130_fd_sc_hd__nand3_1 U349 ( .A(n18), .B(n311), .C(G3), .Y(n173) );
  sky130_fd_sc_hd__a221oi_1 U350 ( .A1(n75), .A2(n44), .B1(n76), .B2(G2), .C1(
        n77), .Y(n73) );
  sky130_fd_sc_hd__a221oi_1 U351 ( .A1(n94), .A2(n75), .B1(n194), .B2(n44), 
        .C1(n295), .Y(n193) );
  sky130_fd_sc_hd__nor2_1 U352 ( .A(G3), .B(G2), .Y(n194) );
  sky130_fd_sc_hd__nor2_1 U353 ( .A(G4), .B(G6), .Y(n175) );
  sky130_fd_sc_hd__nor3_1 U354 ( .A(n303), .B(G8), .C(n27), .Y(n59) );
  sky130_fd_sc_hd__a311oi_1 U355 ( .A1(G1), .A2(G6), .A3(n75), .B1(n196), .C1(
        n197), .Y(G516) );
  sky130_fd_sc_hd__o211ai_1 U356 ( .A1(n306), .A2(n198), .B1(n199), .C1(n200), 
        .Y(n196) );
  sky130_fd_sc_hd__nor3_1 U357 ( .A(n18), .B(n78), .C(n38), .Y(n197) );
  sky130_fd_sc_hd__nand3_1 U358 ( .A(n156), .B(G6), .C(n94), .Y(n200) );
  sky130_fd_sc_hd__a311oi_1 U359 ( .A1(n169), .A2(n308), .A3(n175), .B1(n23), 
        .C1(n195), .Y(G517) );
  sky130_fd_sc_hd__inv_2 U360 ( .A(n135), .Y(n23) );
  sky130_fd_sc_hd__nor3_1 U361 ( .A(n134), .B(G9), .C(G6), .Y(n195) );
  sky130_fd_sc_hd__o32ai_1 U362 ( .A1(n65), .A2(G8), .A3(G6), .B1(n24), .B2(
        n309), .Y(n231) );
  sky130_fd_sc_hd__nor2_1 U363 ( .A(n309), .B(G4), .Y(n160) );
  sky130_fd_sc_hd__nor2_1 U364 ( .A(n304), .B(G9), .Y(n57) );
  sky130_fd_sc_hd__a21oi_1 U365 ( .A1(G0), .A2(n186), .B1(n187), .Y(n176) );
  sky130_fd_sc_hd__nand2_1 U366 ( .A(G4), .B(n308), .Y(n44) );
  sky130_fd_sc_hd__o2111ai_1 U367 ( .A1(n45), .A2(n86), .B1(n106), .C1(n32), 
        .D1(n107), .Y(n103) );
  sky130_fd_sc_hd__inv_2 U368 ( .A(n80), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U369 ( .A(n266), .Y(n259) );
  sky130_fd_sc_hd__o22ai_1 U370 ( .A1(G1), .A2(n309), .B1(n38), .B2(n43), .Y(
        n79) );
  sky130_fd_sc_hd__o22ai_1 U371 ( .A1(G3), .A2(n44), .B1(n78), .B2(n38), .Y(
        n214) );
  sky130_fd_sc_hd__a21oi_1 U372 ( .A1(G5), .A2(n75), .B1(n77), .Y(n68) );
  sky130_fd_sc_hd__nor2_1 U373 ( .A(n237), .B(G3), .Y(n132) );
  sky130_fd_sc_hd__nand3_1 U374 ( .A(G5), .B(n78), .C(n164), .Y(n135) );
  sky130_fd_sc_hd__a211oi_1 U375 ( .A1(n78), .A2(n35), .B1(n79), .C1(n80), .Y(
        n69) );
  sky130_fd_sc_hd__o22ai_1 U376 ( .A1(n73), .A2(n309), .B1(n45), .B2(n74), .Y(
        n72) );
  sky130_fd_sc_hd__nor2_1 U377 ( .A(n308), .B(G4), .Y(n76) );
  sky130_fd_sc_hd__o221ai_1 U378 ( .A1(G44), .A2(n3), .B1(n24), .B2(n137), 
        .C1(n138), .Y(G535) );
  sky130_fd_sc_hd__a21oi_1 U379 ( .A1(n25), .A2(n49), .B1(n140), .Y(n139) );
  sky130_fd_sc_hd__nor2_1 U380 ( .A(n31), .B(G12), .Y(n62) );
  sky130_fd_sc_hd__a21oi_1 U381 ( .A1(n260), .A2(n159), .B1(G0), .Y(n187) );
  sky130_fd_sc_hd__o22ai_1 U382 ( .A1(G7), .A2(n304), .B1(n66), .B2(n303), .Y(
        n233) );
  sky130_fd_sc_hd__nand3_1 U383 ( .A(n303), .B(n312), .C(G7), .Y(n65) );
  sky130_fd_sc_hd__a211oi_1 U384 ( .A1(n57), .A2(n311), .B1(n58), .C1(n59), 
        .Y(n53) );
  sky130_fd_sc_hd__o22ai_1 U385 ( .A1(n298), .A2(n20), .B1(G9), .B2(n303), .Y(
        n58) );
  sky130_fd_sc_hd__o22ai_1 U386 ( .A1(n312), .A2(n303), .B1(G10), .B2(n304), 
        .Y(n117) );
  sky130_fd_sc_hd__o32ai_1 U387 ( .A1(n304), .A2(n301), .A3(n49), .B1(n27), 
        .B2(n112), .Y(n110) );
  sky130_fd_sc_hd__a21oi_1 U388 ( .A1(n91), .A2(G0), .B1(n92), .Y(n87) );
  sky130_fd_sc_hd__a21oi_1 U389 ( .A1(G0), .A2(G2), .B1(n18), .Y(n92) );
  sky130_fd_sc_hd__a21oi_1 U390 ( .A1(n75), .A2(n44), .B1(n227), .Y(G502) );
  sky130_fd_sc_hd__o32ai_1 U391 ( .A1(n95), .A2(G4), .A3(n36), .B1(n33), .B2(
        n228), .Y(n227) );
  sky130_fd_sc_hd__o31ai_1 U392 ( .A1(n2), .A2(n99), .A3(n36), .B1(n100), .Y(
        n98) );
  sky130_fd_sc_hd__inv_2 U393 ( .A(G6), .Y(n309) );
  sky130_fd_sc_hd__inv_2 U394 ( .A(G3), .Y(n306) );
  sky130_fd_sc_hd__inv_2 U395 ( .A(G2), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U396 ( .A(G10), .Y(n303) );
  sky130_fd_sc_hd__nor3_1 U397 ( .A(n122), .B(G12), .C(n123), .Y(n121) );
  sky130_fd_sc_hd__inv_2 U398 ( .A(G13), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U399 ( .A(G11), .Y(n304) );
  sky130_fd_sc_hd__inv_2 U400 ( .A(G5), .Y(n308) );
  sky130_fd_sc_hd__inv_2 U401 ( .A(G1), .Y(n18) );
  sky130_fd_sc_hd__inv_2 U402 ( .A(G9), .Y(n312) );
  sky130_fd_sc_hd__inv_2 U403 ( .A(G4), .Y(n307) );
  sky130_fd_sc_hd__inv_2 U404 ( .A(G8), .Y(n311) );
  sky130_fd_sc_hd__a221oi_1 U405 ( .A1(n126), .A2(n127), .B1(n240), .B2(G0), 
        .C1(n129), .Y(n125) );
  sky130_fd_sc_hd__o211ai_1 U406 ( .A1(n307), .A2(n306), .B1(n81), .C1(n71), 
        .Y(n101) );
  sky130_fd_sc_hd__and2_0 U407 ( .A(G7), .B(n301), .X(n244) );
  sky130_fd_sc_hd__inv_2 U408 ( .A(G41), .Y(G546) );
  sky130_fd_sc_hd__o21ai_0 U409 ( .A1(n265), .A2(n239), .B1(n96), .Y(G550) );
  sky130_fd_sc_hd__inv_2 U410 ( .A(G30), .Y(n1) );
  sky130_fd_sc_hd__a221oi_1 U411 ( .A1(n219), .A2(n299), .B1(G30), .B2(n300), 
        .C1(n244), .Y(n177) );
  sky130_fd_sc_hd__a2bb2oi_1 U412 ( .B1(n246), .B2(n312), .A1_N(G30), .A2_N(G6), .Y(n250) );
  sky130_fd_sc_hd__o211ai_1 U413 ( .A1(n311), .A2(n252), .B1(n290), .C1(n251), 
        .Y(n254) );
  sky130_fd_sc_hd__nor2_1 U414 ( .A(G31), .B(n311), .Y(n248) );
  sky130_fd_sc_hd__nand3_2 U415 ( .A(G7), .B(n309), .C(G30), .Y(n290) );
  sky130_fd_sc_hd__inv_1 U416 ( .A(n284), .Y(n288) );
  sky130_fd_sc_hd__inv_1 U417 ( .A(G0), .Y(n295) );
  sky130_fd_sc_hd__nand2_1 U418 ( .A(G10), .B(G8), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U419 ( .A(G7), .Y(n310) );
  sky130_fd_sc_hd__nand2_1 U420 ( .A(n311), .B(n310), .Y(n147) );
  sky130_fd_sc_hd__nand2_1 U421 ( .A(G9), .B(n303), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U422 ( .A(G12), .Y(n305) );
  sky130_fd_sc_hd__nand2_1 U423 ( .A(G8), .B(n310), .Y(n49) );
  sky130_fd_sc_hd__mux2i_1 U424 ( .A0(n308), .A1(n242), .S(G3), .Y(n245) );
  sky130_fd_sc_hd__nand2_1 U425 ( .A(n20), .B(G9), .Y(n247) );
  sky130_fd_sc_hd__inv_1 U426 ( .A(G31), .Y(n252) );
  sky130_fd_sc_hd__a32oi_1 U427 ( .A1(n304), .A2(n252), .A3(n300), .B1(n241), 
        .B2(G10), .Y(n253) );
  sky130_fd_sc_hd__mux2i_1 U428 ( .A0(n254), .A1(n253), .S(G9), .Y(n255) );
  sky130_fd_sc_hd__nand2_1 U429 ( .A(n243), .B(n257), .Y(n294) );
  sky130_fd_sc_hd__nand3_1 U430 ( .A(n31), .B(G12), .C(n294), .Y(n283) );
  sky130_fd_sc_hd__nand2_1 U431 ( .A(G7), .B(G10), .Y(n285) );
  sky130_fd_sc_hd__inv_1 U432 ( .A(n152), .Y(n24) );
  sky130_fd_sc_hd__o32ai_1 U433 ( .A1(n154), .A2(n295), .A3(n239), .B1(G43), 
        .B2(n2), .Y(n153) );
  sky130_fd_sc_hd__nand2_1 U434 ( .A(G7), .B(G9), .Y(n289) );
  sky130_fd_sc_hd__o221ai_1 U435 ( .A1(G40), .A2(n239), .B1(n69), .B2(n2), 
        .C1(n70), .Y(G552) );
  sky130_fd_sc_hd__o21ai_1 U436 ( .A1(G5), .A2(n37), .B1(n44), .Y(n258) );
  sky130_fd_sc_hd__nor3_1 U437 ( .A(n258), .B(n78), .C(n93), .Y(n264) );
  sky130_fd_sc_hd__inv_1 U438 ( .A(n89), .Y(n260) );
  sky130_fd_sc_hd__nand2_1 U439 ( .A(n295), .B(n89), .Y(n266) );
  sky130_fd_sc_hd__a32oi_1 U440 ( .A1(G0), .A2(n97), .A3(n260), .B1(n259), 
        .B2(G5), .Y(n261) );
  sky130_fd_sc_hd__o21ai_1 U441 ( .A1(n87), .A2(n86), .B1(n261), .Y(n262) );
  sky130_fd_sc_hd__a32oi_1 U442 ( .A1(G39), .A2(G4), .A3(n71), .B1(n275), .B2(
        n262), .Y(n263) );
  sky130_fd_sc_hd__o21ai_1 U443 ( .A1(n2), .A2(n264), .B1(n263), .Y(G551) );
  sky130_fd_sc_hd__o22a_1 U444 ( .A1(n306), .A2(n266), .B1(G29), .B2(n295), 
        .X(n265) );
  sky130_fd_sc_hd__o21ai_1 U445 ( .A1(n260), .A2(G3), .B1(n266), .Y(n267) );
  sky130_fd_sc_hd__a32oi_1 U446 ( .A1(n103), .A2(G1), .A3(n104), .B1(n275), 
        .B2(n267), .Y(n268) );
  sky130_fd_sc_hd__nand3_1 U447 ( .A(n100), .B(n101), .C(n268), .Y(G549) );
  sky130_fd_sc_hd__a21oi_1 U448 ( .A1(n57), .A2(n299), .B1(n110), .Y(n269) );
  sky130_fd_sc_hd__inv_1 U449 ( .A(G34), .Y(n276) );
  sky130_fd_sc_hd__o22ai_1 U450 ( .A1(n269), .A2(n276), .B1(G42), .B2(n239), 
        .Y(G548) );
  sky130_fd_sc_hd__xor2_1 U451 ( .A(n20), .B(G7), .X(n274) );
  sky130_fd_sc_hd__nor2_1 U452 ( .A(n312), .B(n285), .Y(n272) );
  sky130_fd_sc_hd__mux2i_1 U453 ( .A0(n301), .A1(n117), .S(n300), .Y(n270) );
  sky130_fd_sc_hd__o21ai_1 U454 ( .A1(G8), .A2(n27), .B1(n270), .Y(n271) );
  sky130_fd_sc_hd__mux2i_1 U455 ( .A0(n272), .A1(n271), .S(G6), .Y(n273) );
  sky130_fd_sc_hd__o32ai_1 U456 ( .A1(n274), .A2(n312), .A3(n276), .B1(n273), 
        .B2(n286), .Y(G547) );
  sky130_fd_sc_hd__nand2_1 U457 ( .A(n275), .B(G6), .Y(n279) );
  sky130_fd_sc_hd__o211ai_1 U458 ( .A1(n311), .A2(n312), .B1(n299), .C1(G34), 
        .Y(n278) );
  sky130_fd_sc_hd__o21ai_1 U459 ( .A1(n311), .A2(n276), .B1(n279), .Y(n277) );
  sky130_fd_sc_hd__nand2_1 U460 ( .A(n244), .B(n277), .Y(n284) );
  sky130_fd_sc_hd__o211ai_1 U461 ( .A1(n53), .A2(n279), .B1(n278), .C1(n284), 
        .Y(G542) );
  sky130_fd_sc_hd__o21ai_1 U462 ( .A1(n63), .A2(n283), .B1(n119), .Y(G539) );
  sky130_fd_sc_hd__inv_1 U463 ( .A(n184), .Y(n280) );
  sky130_fd_sc_hd__o32ai_1 U464 ( .A1(n176), .A2(n36), .A3(n239), .B1(n237), 
        .B2(n280), .Y(G530) );
  sky130_fd_sc_hd__inv_1 U465 ( .A(n63), .Y(n282) );
  sky130_fd_sc_hd__inv_1 U466 ( .A(n62), .Y(n281) );
  sky130_fd_sc_hd__o221ai_1 U467 ( .A1(n283), .A2(n282), .B1(n238), .B2(n281), 
        .C1(n237), .Y(n230) );
  sky130_fd_sc_hd__a211oi_1 U468 ( .A1(G9), .A2(G6), .B1(n286), .C1(n285), .Y(
        n287) );
  sky130_fd_sc_hd__a311oi_1 U469 ( .A1(G34), .A2(n302), .A3(n289), .B1(n288), 
        .C1(n287), .Y(G514) );
  sky130_fd_sc_hd__a21oi_1 U470 ( .A1(n298), .A2(n304), .B1(G31), .Y(n292) );
  sky130_fd_sc_hd__inv_1 U471 ( .A(n201), .Y(n291) );
  sky130_fd_sc_hd__o221ai_1 U472 ( .A1(n309), .A2(n292), .B1(G10), .B2(n291), 
        .C1(n290), .Y(n293) );
  sky130_fd_sc_hd__nand2_1 U473 ( .A(G8), .B(n293), .Y(G513) );
  sky130_fd_sc_hd__nor3_1 U474 ( .A(n305), .B(n295), .C(n18), .Y(n296) );
  sky130_fd_sc_hd__a31oi_1 U475 ( .A1(n297), .A2(n307), .A3(n296), .B1(n218), 
        .Y(G506) );
endmodule

