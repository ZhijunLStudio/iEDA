/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Sun Sep 14 23:16:46 2025
/////////////////////////////////////////////////////////////


module gcd ( clk, req_msg, req_rdy, req_val, reset, resp_msg, resp_rdy, 
        resp_val );
  input [31:0] req_msg;
  output [15:0] resp_msg;
  input clk, req_val, reset, resp_rdy;
  output req_rdy, resp_val;
  wire   \ctrl/state/N4 , \ctrl/state/N3 , n109, n110, n111, n112, n113, n114,
         n115, n116, n117, n118, n119, n120, n121, n122, n123, n124, n126,
         n127, n128, n129, n130, n131, n132, n133, n134, n135, n136, n137,
         n138, n139, n140, n143, n144, n145, n146, n147, n148, n149, n150,
         n151, n152, n153, n154, n155, n156, n157, n158, n159, n160, n161,
         n162, n163, n164, n165, n166, n167, n168, n169, n170, n171, n172,
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
         n305, n306, n307, n308, n309, n310, n311, n312;
  wire   [1:0] \ctrl/state_out ;
  wire   [15:0] \dpath/b_reg_out ;
  wire   [15:0] \dpath/a_reg_out ;

  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_15_  ( .D(n124), .CLK(clk), 
        .Q(\dpath/b_reg_out [15]) );
  sky130_fd_sc_hd__dfxtp_1 \ctrl/state/out_reg_1_  ( .D(\ctrl/state/N4 ), 
        .CLK(clk), .Q(\ctrl/state_out [1]) );
  sky130_fd_sc_hd__dfxtp_1 \ctrl/state/out_reg_0_  ( .D(\ctrl/state/N3 ), 
        .CLK(clk), .Q(\ctrl/state_out [0]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_14_  ( .D(n123), .CLK(clk), 
        .Q(\dpath/b_reg_out [14]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_4_  ( .D(n119), .CLK(clk), .Q(
        \dpath/b_reg_out [4]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_8_  ( .D(n115), .CLK(clk), .Q(
        \dpath/b_reg_out [8]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_10_  ( .D(n113), .CLK(clk), 
        .Q(\dpath/b_reg_out [10]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_11_  ( .D(n112), .CLK(clk), 
        .Q(\dpath/b_reg_out [11]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_12_  ( .D(n111), .CLK(clk), 
        .Q(\dpath/b_reg_out [12]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_13_  ( .D(n110), .CLK(clk), 
        .Q(\dpath/b_reg_out [13]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_14_  ( .D(n126), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [14]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_1_  ( .D(n139), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [1]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_2_  ( .D(n138), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [2]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_3_  ( .D(n137), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [3]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_4_  ( .D(n136), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [4]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_5_  ( .D(n135), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [5]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_6_  ( .D(n134), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [6]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_7_  ( .D(n133), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [7]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_8_  ( .D(n132), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [8]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_9_  ( .D(n131), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [9]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_10_  ( .D(n130), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [10]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_11_  ( .D(n129), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [11]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_12_  ( .D(n128), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [12]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_13_  ( .D(n127), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [13]) );
  sky130_fd_sc_hd__edfxtp_1 \dpath/a_reg/out_reg_0_  ( .D(n140), .DE(n312), 
        .CLK(clk), .Q(\dpath/a_reg_out [0]) );
  sky130_fd_sc_hd__dfxtp_2 \dpath/b_reg/out_reg_3_  ( .D(n120), .CLK(clk), .Q(
        \dpath/b_reg_out [3]) );
  sky130_fd_sc_hd__edfxbp_1 \dpath/a_reg/out_reg_15_  ( .D(n311), .DE(n312), 
        .CLK(clk), .Q_N(\dpath/a_reg_out [15]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_9_  ( .D(n114), .CLK(clk), .Q(
        \dpath/b_reg_out [9]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_1_  ( .D(n122), .CLK(clk), .Q(
        \dpath/b_reg_out [1]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_7_  ( .D(n116), .CLK(clk), .Q(
        \dpath/b_reg_out [7]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_6_  ( .D(n117), .CLK(clk), .Q(
        \dpath/b_reg_out [6]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_2_  ( .D(n121), .CLK(clk), .Q(
        \dpath/b_reg_out [2]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_5_  ( .D(n118), .CLK(clk), .Q(
        \dpath/b_reg_out [5]) );
  sky130_fd_sc_hd__dfxtp_1 \dpath/b_reg/out_reg_0_  ( .D(n109), .CLK(clk), .Q(
        \dpath/b_reg_out [0]) );
  sky130_fd_sc_hd__clkinv_1 U146 ( .A(\dpath/b_reg_out [9]), .Y(n270) );
  sky130_fd_sc_hd__clkinv_1 U147 ( .A(\dpath/b_reg_out [5]), .Y(n282) );
  sky130_fd_sc_hd__clkinv_1 U148 ( .A(\dpath/b_reg_out [10]), .Y(n267) );
  sky130_fd_sc_hd__clkinv_1 U149 ( .A(\ctrl/state_out [1]), .Y(n312) );
  sky130_fd_sc_hd__clkinv_1 U150 ( .A(n238), .Y(n240) );
  sky130_fd_sc_hd__or2_0 U151 ( .A(n267), .B(\dpath/a_reg_out [10]), .X(n170)
         );
  sky130_fd_sc_hd__clkinv_1 U152 ( .A(n174), .Y(n204) );
  sky130_fd_sc_hd__a21oi_1 U153 ( .A1(n174), .A2(n173), .B1(n172), .Y(n209) );
  sky130_fd_sc_hd__clkinv_1 U154 ( .A(n166), .Y(n183) );
  sky130_fd_sc_hd__clkinv_1 U155 ( .A(n159), .Y(n155) );
  sky130_fd_sc_hd__clkinv_1 U156 ( .A(n193), .Y(n171) );
  sky130_fd_sc_hd__clkinv_1 U157 ( .A(n219), .Y(n225) );
  sky130_fd_sc_hd__clkinv_1 U158 ( .A(n194), .Y(n197) );
  sky130_fd_sc_hd__clkinv_1 U159 ( .A(n195), .Y(n196) );
  sky130_fd_sc_hd__clkinv_1 U160 ( .A(n151), .Y(n242) );
  sky130_fd_sc_hd__clkinv_1 U161 ( .A(n186), .Y(n188) );
  sky130_fd_sc_hd__clkinv_1 U162 ( .A(n190), .Y(n168) );
  sky130_fd_sc_hd__clkinv_1 U163 ( .A(n228), .Y(n230) );
  sky130_fd_sc_hd__clkinv_1 U164 ( .A(n200), .Y(n202) );
  sky130_fd_sc_hd__clkinv_1 U165 ( .A(n210), .Y(n175) );
  sky130_fd_sc_hd__clkinv_1 U166 ( .A(n162), .Y(n154) );
  sky130_fd_sc_hd__clkinv_1 U167 ( .A(n212), .Y(n213) );
  sky130_fd_sc_hd__clkinv_1 U168 ( .A(n146), .Y(n143) );
  sky130_fd_sc_hd__clkinv_1 U169 ( .A(n161), .Y(n156) );
  sky130_fd_sc_hd__clkinv_1 U170 ( .A(n233), .Y(n235) );
  sky130_fd_sc_hd__clkinv_1 U171 ( .A(n243), .Y(n148) );
  sky130_fd_sc_hd__clkinv_1 U172 ( .A(n178), .Y(n180) );
  sky130_fd_sc_hd__or2_1 U173 ( .A(n261), .B(\dpath/a_reg_out [13]), .X(n214)
         );
  sky130_fd_sc_hd__clkinv_1 U174 ( .A(\dpath/b_reg_out [15]), .Y(n256) );
  sky130_fd_sc_hd__clkinv_1 U175 ( .A(\dpath/b_reg_out [11]), .Y(n264) );
  sky130_fd_sc_hd__clkinv_1 U176 ( .A(\dpath/b_reg_out [13]), .Y(n261) );
  sky130_fd_sc_hd__clkbuf_1 U177 ( .A(\dpath/a_reg_out [0]), .X(n302) );
  sky130_fd_sc_hd__clkinv_1 U178 ( .A(\dpath/b_reg_out [12]), .Y(n301) );
  sky130_fd_sc_hd__clkinv_1 U179 ( .A(\dpath/b_reg_out [14]), .Y(n258) );
  sky130_fd_sc_hd__inv_1 U180 ( .A(n259), .Y(n126) );
  sky130_fd_sc_hd__inv_1 U181 ( .A(n288), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U182 ( .A(n279), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U183 ( .A(n223), .Y(n127) );
  sky130_fd_sc_hd__clkinv_1 U184 ( .A(\dpath/b_reg_out [6]), .Y(n278) );
  sky130_fd_sc_hd__clkinv_1 U185 ( .A(\dpath/b_reg_out [7]), .Y(n276) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(n222), .Y(n298) );
  sky130_fd_sc_hd__inv_2 U187 ( .A(\dpath/b_reg_out [8]), .Y(n273) );
  sky130_fd_sc_hd__o21ai_1 U188 ( .A1(n210), .A2(n209), .B1(n208), .Y(n215) );
  sky130_fd_sc_hd__inv_2 U189 ( .A(n303), .Y(n300) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(\dpath/b_reg_out [4]), .Y(n285) );
  sky130_fd_sc_hd__clkinv_1 U191 ( .A(\dpath/a_reg_out [14]), .Y(n216) );
  sky130_fd_sc_hd__inv_2 U192 ( .A(n232), .Y(n218) );
  sky130_fd_sc_hd__clkinv_1 U193 ( .A(\ctrl/state_out [0]), .Y(n307) );
  sky130_fd_sc_hd__clkinv_1 U194 ( .A(req_rdy), .Y(n253) );
  sky130_fd_sc_hd__clkinv_1 U195 ( .A(\dpath/b_reg_out [3]), .Y(n287) );
  sky130_fd_sc_hd__clkbuf_1 U196 ( .A(n209), .X(n177) );
  sky130_fd_sc_hd__nor2_1 U197 ( .A(\ctrl/state_out [1]), .B(
        \ctrl/state_out [0]), .Y(req_rdy) );
  sky130_fd_sc_hd__inv_2 U198 ( .A(\dpath/b_reg_out [0]), .Y(n306) );
  sky130_fd_sc_hd__xnor2_1 U199 ( .A(n306), .B(n302), .Y(resp_msg[0]) );
  sky130_fd_sc_hd__inv_2 U200 ( .A(\dpath/b_reg_out [1]), .Y(n294) );
  sky130_fd_sc_hd__nor2_1 U201 ( .A(n294), .B(\dpath/a_reg_out [1]), .Y(n146)
         );
  sky130_fd_sc_hd__nand2_1 U202 ( .A(n294), .B(\dpath/a_reg_out [1]), .Y(n145)
         );
  sky130_fd_sc_hd__nand2_1 U203 ( .A(n143), .B(n145), .Y(n144) );
  sky130_fd_sc_hd__nor2_1 U204 ( .A(n306), .B(\dpath/a_reg_out [0]), .Y(n147)
         );
  sky130_fd_sc_hd__xor2_1 U205 ( .A(n144), .B(n147), .X(resp_msg[1]) );
  sky130_fd_sc_hd__o21ai_1 U206 ( .A1(n147), .A2(n146), .B1(n145), .Y(n151) );
  sky130_fd_sc_hd__inv_2 U207 ( .A(\dpath/b_reg_out [2]), .Y(n291) );
  sky130_fd_sc_hd__nor2_1 U208 ( .A(n291), .B(\dpath/a_reg_out [2]), .Y(n243)
         );
  sky130_fd_sc_hd__nand2_1 U209 ( .A(n291), .B(\dpath/a_reg_out [2]), .Y(n241)
         );
  sky130_fd_sc_hd__nand2_1 U210 ( .A(n148), .B(n241), .Y(n149) );
  sky130_fd_sc_hd__xor2_1 U211 ( .A(n242), .B(n149), .X(resp_msg[2]) );
  sky130_fd_sc_hd__nor2_1 U212 ( .A(n285), .B(\dpath/a_reg_out [4]), .Y(n159)
         );
  sky130_fd_sc_hd__nand2_1 U213 ( .A(\dpath/a_reg_out [4]), .B(n285), .Y(n162)
         );
  sky130_fd_sc_hd__nand2_1 U214 ( .A(n155), .B(n162), .Y(n153) );
  sky130_fd_sc_hd__nor2_1 U215 ( .A(n287), .B(\dpath/a_reg_out [3]), .Y(n238)
         );
  sky130_fd_sc_hd__nor2_1 U216 ( .A(n238), .B(n243), .Y(n152) );
  sky130_fd_sc_hd__nand2_1 U217 ( .A(\dpath/a_reg_out [3]), .B(n287), .Y(n239)
         );
  sky130_fd_sc_hd__o21ai_1 U218 ( .A1(n241), .A2(n238), .B1(n239), .Y(n150) );
  sky130_fd_sc_hd__a21oi_1 U219 ( .A1(n152), .A2(n151), .B1(n150), .Y(n166) );
  sky130_fd_sc_hd__xnor2_1 U220 ( .A(n153), .B(n183), .Y(resp_msg[4]) );
  sky130_fd_sc_hd__a21oi_1 U221 ( .A1(n183), .A2(n155), .B1(n154), .Y(n158) );
  sky130_fd_sc_hd__nor2_1 U222 ( .A(n282), .B(\dpath/a_reg_out [5]), .Y(n161)
         );
  sky130_fd_sc_hd__nand2_1 U223 ( .A(\dpath/a_reg_out [5]), .B(n282), .Y(n160)
         );
  sky130_fd_sc_hd__nand2_1 U224 ( .A(n156), .B(n160), .Y(n157) );
  sky130_fd_sc_hd__xor2_1 U225 ( .A(n158), .B(n157), .X(resp_msg[5]) );
  sky130_fd_sc_hd__nor2_1 U226 ( .A(n161), .B(n159), .Y(n182) );
  sky130_fd_sc_hd__nor2_1 U227 ( .A(n276), .B(\dpath/a_reg_out [7]), .Y(n178)
         );
  sky130_fd_sc_hd__nor2_1 U228 ( .A(n278), .B(\dpath/a_reg_out [6]), .Y(n233)
         );
  sky130_fd_sc_hd__nor2_1 U229 ( .A(n178), .B(n233), .Y(n164) );
  sky130_fd_sc_hd__nand2_1 U230 ( .A(n182), .B(n164), .Y(n167) );
  sky130_fd_sc_hd__o21ai_1 U231 ( .A1(n162), .A2(n161), .B1(n160), .Y(n181) );
  sky130_fd_sc_hd__nand2_1 U232 ( .A(n278), .B(\dpath/a_reg_out [6]), .Y(n234)
         );
  sky130_fd_sc_hd__nand2_1 U233 ( .A(\dpath/a_reg_out [7]), .B(n276), .Y(n179)
         );
  sky130_fd_sc_hd__o21ai_1 U234 ( .A1(n234), .A2(n178), .B1(n179), .Y(n163) );
  sky130_fd_sc_hd__a21oi_1 U235 ( .A1(n164), .A2(n181), .B1(n163), .Y(n165) );
  sky130_fd_sc_hd__o21ai_1 U236 ( .A1(n167), .A2(n166), .B1(n165), .Y(n174) );
  sky130_fd_sc_hd__nor2_1 U237 ( .A(n273), .B(\dpath/a_reg_out [8]), .Y(n190)
         );
  sky130_fd_sc_hd__nand2_1 U238 ( .A(\dpath/a_reg_out [8]), .B(n273), .Y(n189)
         );
  sky130_fd_sc_hd__nand2_1 U239 ( .A(n168), .B(n189), .Y(n169) );
  sky130_fd_sc_hd__xor2_1 U240 ( .A(n204), .B(n169), .X(resp_msg[8]) );
  sky130_fd_sc_hd__nor2_1 U241 ( .A(n264), .B(\dpath/a_reg_out [11]), .Y(n200)
         );
  sky130_fd_sc_hd__nor2_1 U242 ( .A(n270), .B(\dpath/a_reg_out [9]), .Y(n186)
         );
  sky130_fd_sc_hd__nor2_1 U243 ( .A(n186), .B(n190), .Y(n194) );
  sky130_fd_sc_hd__nand2_1 U244 ( .A(n194), .B(n170), .Y(n205) );
  sky130_fd_sc_hd__nor2_1 U245 ( .A(n200), .B(n205), .Y(n173) );
  sky130_fd_sc_hd__nand2_1 U246 ( .A(\dpath/a_reg_out [9]), .B(n270), .Y(n187)
         );
  sky130_fd_sc_hd__o21ai_1 U247 ( .A1(n189), .A2(n186), .B1(n187), .Y(n195) );
  sky130_fd_sc_hd__nand2_1 U248 ( .A(\dpath/a_reg_out [10]), .B(n267), .Y(n193) );
  sky130_fd_sc_hd__a21oi_1 U249 ( .A1(n195), .A2(n170), .B1(n171), .Y(n203) );
  sky130_fd_sc_hd__nand2_1 U250 ( .A(\dpath/a_reg_out [11]), .B(n264), .Y(n201) );
  sky130_fd_sc_hd__o21ai_1 U251 ( .A1(n200), .A2(n203), .B1(n201), .Y(n172) );
  sky130_fd_sc_hd__nor2_1 U252 ( .A(n301), .B(\dpath/a_reg_out [12]), .Y(n210)
         );
  sky130_fd_sc_hd__nand2_1 U253 ( .A(\dpath/a_reg_out [12]), .B(n301), .Y(n208) );
  sky130_fd_sc_hd__nand2_1 U254 ( .A(n175), .B(n208), .Y(n176) );
  sky130_fd_sc_hd__xor2_1 U255 ( .A(n177), .B(n176), .X(resp_msg[12]) );
  sky130_fd_sc_hd__nand2_1 U256 ( .A(n180), .B(n179), .Y(n185) );
  sky130_fd_sc_hd__a21oi_1 U257 ( .A1(n183), .A2(n182), .B1(n181), .Y(n237) );
  sky130_fd_sc_hd__o21ai_1 U258 ( .A1(n233), .A2(n237), .B1(n234), .Y(n184) );
  sky130_fd_sc_hd__xnor2_1 U259 ( .A(n185), .B(n184), .Y(resp_msg[7]) );
  sky130_fd_sc_hd__nand2_1 U260 ( .A(n188), .B(n187), .Y(n192) );
  sky130_fd_sc_hd__o21ai_1 U261 ( .A1(n190), .A2(n204), .B1(n189), .Y(n191) );
  sky130_fd_sc_hd__xnor2_1 U262 ( .A(n192), .B(n191), .Y(resp_msg[9]) );
  sky130_fd_sc_hd__nand2_1 U263 ( .A(n170), .B(n193), .Y(n199) );
  sky130_fd_sc_hd__o21ai_1 U264 ( .A1(n197), .A2(n204), .B1(n196), .Y(n198) );
  sky130_fd_sc_hd__xnor2_1 U265 ( .A(n199), .B(n198), .Y(resp_msg[10]) );
  sky130_fd_sc_hd__nand2_1 U266 ( .A(n202), .B(n201), .Y(n207) );
  sky130_fd_sc_hd__o21ai_1 U267 ( .A1(n205), .A2(n204), .B1(n203), .Y(n206) );
  sky130_fd_sc_hd__xnor2_1 U268 ( .A(n207), .B(n206), .Y(resp_msg[11]) );
  sky130_fd_sc_hd__nand2_1 U269 ( .A(\dpath/a_reg_out [13]), .B(n261), .Y(n212) );
  sky130_fd_sc_hd__nand2_1 U270 ( .A(n214), .B(n212), .Y(n211) );
  sky130_fd_sc_hd__xnor2_1 U271 ( .A(n211), .B(n215), .Y(resp_msg[13]) );
  sky130_fd_sc_hd__nor2_1 U272 ( .A(\ctrl/state_out [1]), .B(n307), .Y(n222)
         );
  sky130_fd_sc_hd__a21oi_2 U273 ( .A1(n215), .A2(n214), .B1(n213), .Y(n232) );
  sky130_fd_sc_hd__nor2_1 U274 ( .A(\dpath/a_reg_out [15]), .B(n256), .Y(n219)
         );
  sky130_fd_sc_hd__a21oi_1 U275 ( .A1(\dpath/b_reg_out [14]), .A2(n216), .B1(
        n219), .Y(n217) );
  sky130_fd_sc_hd__nand2_1 U276 ( .A(n218), .B(n217), .Y(n221) );
  sky130_fd_sc_hd__nand3_1 U277 ( .A(n225), .B(\dpath/a_reg_out [14]), .C(n258), .Y(n220) );
  sky130_fd_sc_hd__nand2_1 U278 ( .A(n256), .B(\dpath/a_reg_out [15]), .Y(n224) );
  sky130_fd_sc_hd__nand3_2 U279 ( .A(n221), .B(n220), .C(n224), .Y(n254) );
  sky130_fd_sc_hd__nand2_1 U280 ( .A(n254), .B(n222), .Y(n250) );
  sky130_fd_sc_hd__inv_2 U281 ( .A(n250), .Y(n297) );
  sky130_fd_sc_hd__nor2_4 U282 ( .A(n298), .B(n254), .Y(n303) );
  sky130_fd_sc_hd__a222oi_1 U283 ( .A1(n298), .A2(req_msg[29]), .B1(n297), 
        .B2(resp_msg[13]), .C1(n303), .C2(\dpath/b_reg_out [13]), .Y(n223) );
  sky130_fd_sc_hd__nand2_1 U284 ( .A(n225), .B(n224), .Y(n227) );
  sky130_fd_sc_hd__nor2_1 U285 ( .A(n258), .B(\dpath/a_reg_out [14]), .Y(n228)
         );
  sky130_fd_sc_hd__nand2_1 U286 ( .A(\dpath/a_reg_out [14]), .B(n258), .Y(n229) );
  sky130_fd_sc_hd__o21ai_1 U287 ( .A1(n228), .A2(n232), .B1(n229), .Y(n226) );
  sky130_fd_sc_hd__xnor2_1 U288 ( .A(n227), .B(n226), .Y(resp_msg[15]) );
  sky130_fd_sc_hd__nand2_1 U289 ( .A(n230), .B(n229), .Y(n231) );
  sky130_fd_sc_hd__xor2_1 U290 ( .A(n232), .B(n231), .X(resp_msg[14]) );
  sky130_fd_sc_hd__nand2_1 U291 ( .A(n235), .B(n234), .Y(n236) );
  sky130_fd_sc_hd__xor2_1 U292 ( .A(n237), .B(n236), .X(resp_msg[6]) );
  sky130_fd_sc_hd__nand2_1 U293 ( .A(n240), .B(n239), .Y(n245) );
  sky130_fd_sc_hd__o21ai_1 U294 ( .A1(n243), .A2(n242), .B1(n241), .Y(n244) );
  sky130_fd_sc_hd__xnor2_1 U295 ( .A(n245), .B(n244), .Y(resp_msg[3]) );
  sky130_fd_sc_hd__a21oi_1 U296 ( .A1(n312), .A2(req_val), .B1(
        \ctrl/state_out [0]), .Y(n252) );
  sky130_fd_sc_hd__nor4_1 U297 ( .A(\dpath/b_reg_out [6]), .B(
        \dpath/b_reg_out [5]), .C(\dpath/b_reg_out [15]), .D(
        \dpath/b_reg_out [14]), .Y(n249) );
  sky130_fd_sc_hd__nor4_1 U298 ( .A(\dpath/b_reg_out [1]), .B(
        \dpath/b_reg_out [2]), .C(\dpath/b_reg_out [7]), .D(
        \dpath/b_reg_out [13]), .Y(n248) );
  sky130_fd_sc_hd__nor4_1 U299 ( .A(\dpath/b_reg_out [11]), .B(
        \dpath/b_reg_out [0]), .C(\dpath/b_reg_out [9]), .D(
        \dpath/b_reg_out [10]), .Y(n247) );
  sky130_fd_sc_hd__nor4_1 U300 ( .A(\dpath/b_reg_out [3]), .B(
        \dpath/b_reg_out [4]), .C(\dpath/b_reg_out [8]), .D(
        \dpath/b_reg_out [12]), .Y(n246) );
  sky130_fd_sc_hd__nand4_1 U301 ( .A(n249), .B(n248), .C(n247), .D(n246), .Y(
        n251) );
  sky130_fd_sc_hd__nor2_1 U302 ( .A(n251), .B(n250), .Y(n308) );
  sky130_fd_sc_hd__nor3_1 U303 ( .A(reset), .B(n252), .C(n308), .Y(
        \ctrl/state/N3 ) );
  sky130_fd_sc_hd__o21ai_2 U304 ( .A1(\ctrl/state_out [1]), .A2(n254), .B1(
        n253), .Y(n305) );
  sky130_fd_sc_hd__a22oi_1 U305 ( .A1(req_rdy), .A2(req_msg[15]), .B1(n303), 
        .B2(\dpath/a_reg_out [15]), .Y(n255) );
  sky130_fd_sc_hd__o21ai_1 U306 ( .A1(n256), .A2(n305), .B1(n255), .Y(n124) );
  sky130_fd_sc_hd__a222oi_1 U307 ( .A1(n298), .A2(req_msg[31]), .B1(
        \dpath/b_reg_out [15]), .B2(n303), .C1(resp_msg[15]), .C2(n297), .Y(
        n311) );
  sky130_fd_sc_hd__a22oi_1 U308 ( .A1(req_rdy), .A2(req_msg[14]), .B1(n303), 
        .B2(\dpath/a_reg_out [14]), .Y(n257) );
  sky130_fd_sc_hd__o21ai_1 U309 ( .A1(n258), .A2(n305), .B1(n257), .Y(n123) );
  sky130_fd_sc_hd__a222oi_1 U310 ( .A1(n298), .A2(req_msg[30]), .B1(n297), 
        .B2(resp_msg[14]), .C1(n303), .C2(\dpath/b_reg_out [14]), .Y(n259) );
  sky130_fd_sc_hd__a22oi_1 U311 ( .A1(req_rdy), .A2(req_msg[13]), .B1(n303), 
        .B2(\dpath/a_reg_out [13]), .Y(n260) );
  sky130_fd_sc_hd__o21ai_1 U312 ( .A1(n261), .A2(n305), .B1(n260), .Y(n110) );
  sky130_fd_sc_hd__a22oi_1 U313 ( .A1(req_rdy), .A2(req_msg[11]), .B1(n303), 
        .B2(\dpath/a_reg_out [11]), .Y(n262) );
  sky130_fd_sc_hd__o21ai_1 U314 ( .A1(n264), .A2(n305), .B1(n262), .Y(n112) );
  sky130_fd_sc_hd__a22oi_1 U315 ( .A1(req_msg[27]), .A2(n298), .B1(
        resp_msg[11]), .B2(n297), .Y(n263) );
  sky130_fd_sc_hd__o21ai_1 U316 ( .A1(n264), .A2(n300), .B1(n263), .Y(n129) );
  sky130_fd_sc_hd__a22oi_1 U317 ( .A1(req_rdy), .A2(req_msg[10]), .B1(n303), 
        .B2(\dpath/a_reg_out [10]), .Y(n265) );
  sky130_fd_sc_hd__o21ai_1 U318 ( .A1(n267), .A2(n305), .B1(n265), .Y(n113) );
  sky130_fd_sc_hd__a22oi_1 U319 ( .A1(req_msg[26]), .A2(n298), .B1(
        resp_msg[10]), .B2(n297), .Y(n266) );
  sky130_fd_sc_hd__o21ai_1 U320 ( .A1(n267), .A2(n300), .B1(n266), .Y(n130) );
  sky130_fd_sc_hd__a22oi_1 U321 ( .A1(req_rdy), .A2(req_msg[9]), .B1(n303), 
        .B2(\dpath/a_reg_out [9]), .Y(n268) );
  sky130_fd_sc_hd__o21ai_1 U322 ( .A1(n270), .A2(n305), .B1(n268), .Y(n114) );
  sky130_fd_sc_hd__a22oi_1 U323 ( .A1(req_msg[25]), .A2(n298), .B1(resp_msg[9]), .B2(n297), .Y(n269) );
  sky130_fd_sc_hd__o21ai_1 U324 ( .A1(n270), .A2(n300), .B1(n269), .Y(n131) );
  sky130_fd_sc_hd__a22oi_1 U325 ( .A1(req_rdy), .A2(req_msg[8]), .B1(n303), 
        .B2(\dpath/a_reg_out [8]), .Y(n271) );
  sky130_fd_sc_hd__o21ai_1 U326 ( .A1(n273), .A2(n305), .B1(n271), .Y(n115) );
  sky130_fd_sc_hd__a22oi_1 U327 ( .A1(req_msg[24]), .A2(n298), .B1(n297), .B2(
        resp_msg[8]), .Y(n272) );
  sky130_fd_sc_hd__o21ai_1 U328 ( .A1(n273), .A2(n300), .B1(n272), .Y(n132) );
  sky130_fd_sc_hd__a22oi_1 U329 ( .A1(req_rdy), .A2(req_msg[7]), .B1(n303), 
        .B2(\dpath/a_reg_out [7]), .Y(n274) );
  sky130_fd_sc_hd__o21ai_1 U330 ( .A1(n276), .A2(n305), .B1(n274), .Y(n116) );
  sky130_fd_sc_hd__a22oi_1 U331 ( .A1(req_msg[23]), .A2(n298), .B1(resp_msg[7]), .B2(n297), .Y(n275) );
  sky130_fd_sc_hd__o21ai_1 U332 ( .A1(n276), .A2(n300), .B1(n275), .Y(n133) );
  sky130_fd_sc_hd__a22oi_1 U333 ( .A1(req_rdy), .A2(req_msg[6]), .B1(n303), 
        .B2(\dpath/a_reg_out [6]), .Y(n277) );
  sky130_fd_sc_hd__o21ai_1 U334 ( .A1(n278), .A2(n305), .B1(n277), .Y(n117) );
  sky130_fd_sc_hd__a222oi_1 U335 ( .A1(n298), .A2(req_msg[22]), .B1(n297), 
        .B2(resp_msg[6]), .C1(n303), .C2(\dpath/b_reg_out [6]), .Y(n279) );
  sky130_fd_sc_hd__a22oi_1 U336 ( .A1(req_rdy), .A2(req_msg[5]), .B1(n303), 
        .B2(\dpath/a_reg_out [5]), .Y(n280) );
  sky130_fd_sc_hd__o21ai_1 U337 ( .A1(n282), .A2(n305), .B1(n280), .Y(n118) );
  sky130_fd_sc_hd__a22oi_1 U338 ( .A1(req_msg[21]), .A2(n298), .B1(n297), .B2(
        resp_msg[5]), .Y(n281) );
  sky130_fd_sc_hd__o21ai_1 U339 ( .A1(n282), .A2(n300), .B1(n281), .Y(n135) );
  sky130_fd_sc_hd__a22oi_1 U340 ( .A1(req_rdy), .A2(req_msg[4]), .B1(n303), 
        .B2(\dpath/a_reg_out [4]), .Y(n283) );
  sky130_fd_sc_hd__o21ai_1 U341 ( .A1(n285), .A2(n305), .B1(n283), .Y(n119) );
  sky130_fd_sc_hd__a22oi_1 U342 ( .A1(req_msg[20]), .A2(n298), .B1(n297), .B2(
        resp_msg[4]), .Y(n284) );
  sky130_fd_sc_hd__o21ai_1 U343 ( .A1(n285), .A2(n300), .B1(n284), .Y(n136) );
  sky130_fd_sc_hd__a22oi_1 U344 ( .A1(req_rdy), .A2(req_msg[3]), .B1(n303), 
        .B2(\dpath/a_reg_out [3]), .Y(n286) );
  sky130_fd_sc_hd__o21ai_1 U345 ( .A1(n287), .A2(n305), .B1(n286), .Y(n120) );
  sky130_fd_sc_hd__a222oi_1 U346 ( .A1(n298), .A2(req_msg[19]), .B1(n297), 
        .B2(resp_msg[3]), .C1(n303), .C2(\dpath/b_reg_out [3]), .Y(n288) );
  sky130_fd_sc_hd__a22oi_1 U347 ( .A1(req_rdy), .A2(req_msg[2]), .B1(n303), 
        .B2(\dpath/a_reg_out [2]), .Y(n289) );
  sky130_fd_sc_hd__o21ai_1 U348 ( .A1(n291), .A2(n305), .B1(n289), .Y(n121) );
  sky130_fd_sc_hd__a22oi_1 U349 ( .A1(req_msg[18]), .A2(n298), .B1(n297), .B2(
        resp_msg[2]), .Y(n290) );
  sky130_fd_sc_hd__o21ai_1 U350 ( .A1(n291), .A2(n300), .B1(n290), .Y(n138) );
  sky130_fd_sc_hd__a22oi_1 U351 ( .A1(req_rdy), .A2(req_msg[1]), .B1(n303), 
        .B2(\dpath/a_reg_out [1]), .Y(n292) );
  sky130_fd_sc_hd__o21ai_1 U352 ( .A1(n294), .A2(n305), .B1(n292), .Y(n122) );
  sky130_fd_sc_hd__a22oi_1 U353 ( .A1(req_msg[17]), .A2(n298), .B1(n297), .B2(
        resp_msg[1]), .Y(n293) );
  sky130_fd_sc_hd__o21ai_1 U354 ( .A1(n294), .A2(n300), .B1(n293), .Y(n139) );
  sky130_fd_sc_hd__a22oi_1 U355 ( .A1(req_msg[16]), .A2(n298), .B1(n297), .B2(
        resp_msg[0]), .Y(n295) );
  sky130_fd_sc_hd__o21ai_1 U356 ( .A1(n306), .A2(n300), .B1(n295), .Y(n140) );
  sky130_fd_sc_hd__a22oi_1 U357 ( .A1(req_rdy), .A2(req_msg[12]), .B1(n303), 
        .B2(\dpath/a_reg_out [12]), .Y(n296) );
  sky130_fd_sc_hd__o21ai_1 U358 ( .A1(n301), .A2(n305), .B1(n296), .Y(n111) );
  sky130_fd_sc_hd__a22oi_1 U359 ( .A1(req_msg[28]), .A2(n298), .B1(
        resp_msg[12]), .B2(n297), .Y(n299) );
  sky130_fd_sc_hd__o21ai_1 U360 ( .A1(n301), .A2(n300), .B1(n299), .Y(n128) );
  sky130_fd_sc_hd__a22oi_1 U361 ( .A1(req_rdy), .A2(req_msg[0]), .B1(n303), 
        .B2(n302), .Y(n304) );
  sky130_fd_sc_hd__o21ai_1 U362 ( .A1(n306), .A2(n305), .B1(n304), .Y(n109) );
  sky130_fd_sc_hd__a21oi_1 U363 ( .A1(n307), .A2(resp_rdy), .B1(n312), .Y(n309) );
  sky130_fd_sc_hd__nor2_1 U364 ( .A(n309), .B(n308), .Y(n310) );
  sky130_fd_sc_hd__nor2_1 U365 ( .A(reset), .B(n310), .Y(\ctrl/state/N4 ) );
  sky130_fd_sc_hd__nor2_1 U366 ( .A(\ctrl/state_out [0]), .B(n312), .Y(
        resp_val) );
endmodule

