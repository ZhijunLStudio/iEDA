/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 29 19:55:57 2025
/////////////////////////////////////////////////////////////


module dffrc_20_f1010 ( clk_i, rst_n_i, dat_i, dat_o );
  input [19:0] dat_i;
  output [19:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfstp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[12]) );
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
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .SET_B(
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


module dffrc_32_ffff2022 ( clk_i, rst_n_i, dat_i, dat_o );
  input [31:0] dat_i;
  output [31:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfstp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[13]) );
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
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffrc_24_ffffff ( clk_i, rst_n_i, dat_i, dat_o );
  input [23:0] dat_i;
  output [23:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfstp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module apb4_archinfo ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, 
        apb4_psel, apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, 
        apb4_pready, apb4_prdata, apb4_pslverr );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite;
  output apb4_pready, apb4_pslverr;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n52, n53, n54, n55, n56, n57, n58, n59, n60,
         n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74,
         n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88,
         n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101,
         n102, n103, n104, n105, n106, n107, n108, n109, n110, n111, n112,
         n113;
  wire   [19:0] s_arch_sys_d;
  wire   [19:0] s_arch_sys_q;
  wire   [31:0] s_arch_idl_d;
  wire   [31:0] s_arch_idl_q;
  wire   [23:0] s_arch_idh_d;
  wire   [23:0] s_arch_idh_q;

  dffrc_20_f1010 u_arch_sys_dffrc ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_arch_sys_d), .dat_o(s_arch_sys_q) );
  dffrc_32_ffff2022 u_arch_idl_dffrc ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_arch_idl_d), .dat_o(s_arch_idl_q) );
  dffrc_24_ffffff u_arch_idh_dffrc ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_arch_idh_d), .dat_o(s_arch_idh_q) );
  sky130_fd_sc_hd__a22o_1 U154 ( .A1(apb4_pwdata[9]), .A2(n112), .B1(n80), 
        .B2(s_arch_idl_q[9]), .X(s_arch_idl_d[9]) );
  sky130_fd_sc_hd__a22o_1 U155 ( .A1(apb4_pwdata[8]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[8]), .X(s_arch_idl_d[8]) );
  sky130_fd_sc_hd__a22o_1 U156 ( .A1(apb4_pwdata[7]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[7]), .X(s_arch_idl_d[7]) );
  sky130_fd_sc_hd__a22o_1 U157 ( .A1(apb4_pwdata[6]), .A2(n112), .B1(n80), 
        .B2(s_arch_idl_q[6]), .X(s_arch_idl_d[6]) );
  sky130_fd_sc_hd__a22o_1 U158 ( .A1(apb4_pwdata[5]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[5]), .X(s_arch_idl_d[5]) );
  sky130_fd_sc_hd__a22o_1 U159 ( .A1(apb4_pwdata[4]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[4]), .X(s_arch_idl_d[4]) );
  sky130_fd_sc_hd__a22o_1 U160 ( .A1(apb4_pwdata[3]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[3]), .X(s_arch_idl_d[3]) );
  sky130_fd_sc_hd__a22o_1 U161 ( .A1(n80), .A2(s_arch_idl_q[31]), .B1(
        apb4_pwdata[31]), .B2(n113), .X(s_arch_idl_d[31]) );
  sky130_fd_sc_hd__a22o_1 U162 ( .A1(n80), .A2(s_arch_idl_q[30]), .B1(
        apb4_pwdata[30]), .B2(n112), .X(s_arch_idl_d[30]) );
  sky130_fd_sc_hd__a22o_1 U163 ( .A1(apb4_pwdata[2]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[2]), .X(s_arch_idl_d[2]) );
  sky130_fd_sc_hd__a22o_1 U164 ( .A1(n80), .A2(s_arch_idl_q[29]), .B1(
        apb4_pwdata[29]), .B2(n113), .X(s_arch_idl_d[29]) );
  sky130_fd_sc_hd__a22o_1 U165 ( .A1(n80), .A2(s_arch_idl_q[28]), .B1(
        apb4_pwdata[28]), .B2(n113), .X(s_arch_idl_d[28]) );
  sky130_fd_sc_hd__a22o_1 U166 ( .A1(n80), .A2(s_arch_idl_q[27]), .B1(
        apb4_pwdata[27]), .B2(n112), .X(s_arch_idl_d[27]) );
  sky130_fd_sc_hd__a22o_1 U167 ( .A1(n80), .A2(s_arch_idl_q[26]), .B1(
        apb4_pwdata[26]), .B2(n113), .X(s_arch_idl_d[26]) );
  sky130_fd_sc_hd__a22o_1 U168 ( .A1(n80), .A2(s_arch_idl_q[25]), .B1(
        apb4_pwdata[25]), .B2(n112), .X(s_arch_idl_d[25]) );
  sky130_fd_sc_hd__a22o_1 U169 ( .A1(n80), .A2(s_arch_idl_q[24]), .B1(
        apb4_pwdata[24]), .B2(n113), .X(s_arch_idl_d[24]) );
  sky130_fd_sc_hd__a22o_1 U170 ( .A1(apb4_pwdata[1]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[1]), .X(s_arch_idl_d[1]) );
  sky130_fd_sc_hd__a22o_1 U171 ( .A1(apb4_pwdata[19]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[19]), .X(s_arch_idl_d[19]) );
  sky130_fd_sc_hd__a22o_1 U172 ( .A1(apb4_pwdata[18]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[18]), .X(s_arch_idl_d[18]) );
  sky130_fd_sc_hd__a22o_1 U173 ( .A1(apb4_pwdata[17]), .A2(n112), .B1(n80), 
        .B2(s_arch_idl_q[17]), .X(s_arch_idl_d[17]) );
  sky130_fd_sc_hd__a22o_1 U174 ( .A1(apb4_pwdata[16]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[16]), .X(s_arch_idl_d[16]) );
  sky130_fd_sc_hd__a22o_1 U175 ( .A1(apb4_pwdata[15]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[15]), .X(s_arch_idl_d[15]) );
  sky130_fd_sc_hd__a22o_1 U176 ( .A1(apb4_pwdata[14]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[14]), .X(s_arch_idl_d[14]) );
  sky130_fd_sc_hd__a22o_1 U177 ( .A1(apb4_pwdata[13]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[13]), .X(s_arch_idl_d[13]) );
  sky130_fd_sc_hd__a22o_1 U178 ( .A1(apb4_pwdata[12]), .A2(n112), .B1(n80), 
        .B2(s_arch_idl_q[12]), .X(s_arch_idl_d[12]) );
  sky130_fd_sc_hd__a22o_1 U179 ( .A1(apb4_pwdata[11]), .A2(n112), .B1(n80), 
        .B2(s_arch_idl_q[11]), .X(s_arch_idl_d[11]) );
  sky130_fd_sc_hd__a22o_1 U180 ( .A1(apb4_pwdata[10]), .A2(n112), .B1(n80), 
        .B2(s_arch_idl_q[10]), .X(s_arch_idl_d[10]) );
  sky130_fd_sc_hd__a22o_1 U181 ( .A1(apb4_pwdata[0]), .A2(n113), .B1(n80), 
        .B2(s_arch_idl_q[0]), .X(s_arch_idl_d[0]) );
  sky130_fd_sc_hd__nand2_1 U182 ( .A(n81), .B(n79), .Y(n80) );
  sky130_fd_sc_hd__nand2_1 U183 ( .A(n83), .B(n79), .Y(n82) );
  sky130_fd_sc_hd__and4_1 U184 ( .A(apb4_pwrite), .B(apb4_psel), .C(
        apb4_penable), .D(n84), .X(n79) );
  sky130_fd_sc_hd__nand2_1 U185 ( .A(n49), .B(s_arch_idl_q[9]), .Y(n87) );
  sky130_fd_sc_hd__nand2_1 U186 ( .A(n49), .B(s_arch_idl_q[8]), .Y(n88) );
  sky130_fd_sc_hd__nand2_1 U187 ( .A(n49), .B(s_arch_idl_q[7]), .Y(n89) );
  sky130_fd_sc_hd__nand2_1 U188 ( .A(n49), .B(s_arch_idl_q[6]), .Y(n90) );
  sky130_fd_sc_hd__nand2_1 U189 ( .A(n49), .B(s_arch_idl_q[5]), .Y(n91) );
  sky130_fd_sc_hd__nand2_1 U190 ( .A(n49), .B(s_arch_idl_q[4]), .Y(n92) );
  sky130_fd_sc_hd__nand2_1 U191 ( .A(n49), .B(s_arch_idl_q[3]), .Y(n93) );
  sky130_fd_sc_hd__nor2b_1 U192 ( .B_N(s_arch_idl_q[31]), .A(n94), .Y(
        apb4_prdata[31]) );
  sky130_fd_sc_hd__nor2b_1 U193 ( .B_N(s_arch_idl_q[30]), .A(n94), .Y(
        apb4_prdata[30]) );
  sky130_fd_sc_hd__nand2_1 U194 ( .A(n49), .B(s_arch_idl_q[2]), .Y(n95) );
  sky130_fd_sc_hd__nor2b_1 U195 ( .B_N(s_arch_idl_q[29]), .A(n94), .Y(
        apb4_prdata[29]) );
  sky130_fd_sc_hd__nor2b_1 U196 ( .B_N(s_arch_idl_q[28]), .A(n94), .Y(
        apb4_prdata[28]) );
  sky130_fd_sc_hd__nor2b_1 U197 ( .B_N(s_arch_idl_q[27]), .A(n94), .Y(
        apb4_prdata[27]) );
  sky130_fd_sc_hd__nor2b_1 U198 ( .B_N(s_arch_idl_q[26]), .A(n94), .Y(
        apb4_prdata[26]) );
  sky130_fd_sc_hd__nor2b_1 U199 ( .B_N(s_arch_idl_q[25]), .A(n94), .Y(
        apb4_prdata[25]) );
  sky130_fd_sc_hd__nor2b_1 U200 ( .B_N(s_arch_idl_q[24]), .A(n94), .Y(
        apb4_prdata[24]) );
  sky130_fd_sc_hd__nand2_1 U201 ( .A(n49), .B(s_arch_idl_q[1]), .Y(n96) );
  sky130_fd_sc_hd__nand2_1 U202 ( .A(n49), .B(s_arch_idl_q[19]), .Y(n97) );
  sky130_fd_sc_hd__nand2_1 U203 ( .A(n49), .B(s_arch_idl_q[18]), .Y(n98) );
  sky130_fd_sc_hd__nand2_1 U204 ( .A(n49), .B(s_arch_idl_q[17]), .Y(n99) );
  sky130_fd_sc_hd__nand2_1 U205 ( .A(n49), .B(s_arch_idl_q[16]), .Y(n100) );
  sky130_fd_sc_hd__nand2_1 U206 ( .A(n49), .B(s_arch_idl_q[15]), .Y(n101) );
  sky130_fd_sc_hd__nand2_1 U207 ( .A(n49), .B(s_arch_idl_q[14]), .Y(n102) );
  sky130_fd_sc_hd__nand2_1 U208 ( .A(n49), .B(s_arch_idl_q[13]), .Y(n103) );
  sky130_fd_sc_hd__nand2_1 U209 ( .A(n49), .B(s_arch_idl_q[12]), .Y(n104) );
  sky130_fd_sc_hd__nand2_1 U210 ( .A(n49), .B(s_arch_idl_q[11]), .Y(n105) );
  sky130_fd_sc_hd__nand2_1 U211 ( .A(n49), .B(s_arch_idl_q[10]), .Y(n106) );
  sky130_fd_sc_hd__nand2_1 U212 ( .A(n49), .B(s_arch_idl_q[0]), .Y(n107) );
  sky130_fd_sc_hd__nor2b_1 U214 ( .B_N(apb4_paddr[2]), .A(apb4_paddr[3]), .Y(
        n81) );
  sky130_fd_sc_hd__nand2_1 U215 ( .A(n108), .B(n83), .Y(n86) );
  sky130_fd_sc_hd__nor2b_1 U216 ( .B_N(apb4_paddr[3]), .A(apb4_paddr[2]), .Y(
        n83) );
  sky130_fd_sc_hd__and4b_1 U218 ( .B(apb4_psel), .C(apb4_penable), .D(n84), 
        .A_N(apb4_pwrite), .X(n108) );
  sky130_fd_sc_hd__inv_2 U219 ( .A(s_arch_idh_q[0]), .Y(n25) );
  sky130_fd_sc_hd__inv_2 U220 ( .A(s_arch_idh_q[1]), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U221 ( .A(s_arch_idh_q[2]), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U222 ( .A(s_arch_idh_q[3]), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U223 ( .A(s_arch_idh_q[4]), .Y(n29) );
  sky130_fd_sc_hd__inv_2 U224 ( .A(s_arch_idh_q[5]), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U225 ( .A(s_arch_idh_q[6]), .Y(n31) );
  sky130_fd_sc_hd__inv_2 U226 ( .A(s_arch_idh_q[7]), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U227 ( .A(s_arch_idh_q[8]), .Y(n33) );
  sky130_fd_sc_hd__inv_2 U228 ( .A(s_arch_idh_q[9]), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U229 ( .A(s_arch_idh_q[10]), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U230 ( .A(s_arch_idh_q[11]), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U231 ( .A(s_arch_idh_q[12]), .Y(n37) );
  sky130_fd_sc_hd__inv_2 U232 ( .A(s_arch_idh_q[13]), .Y(n38) );
  sky130_fd_sc_hd__inv_2 U233 ( .A(s_arch_idh_q[14]), .Y(n39) );
  sky130_fd_sc_hd__inv_2 U234 ( .A(s_arch_idh_q[15]), .Y(n40) );
  sky130_fd_sc_hd__inv_2 U235 ( .A(s_arch_idh_q[16]), .Y(n41) );
  sky130_fd_sc_hd__inv_2 U236 ( .A(s_arch_idh_q[17]), .Y(n42) );
  sky130_fd_sc_hd__inv_2 U237 ( .A(s_arch_idh_q[18]), .Y(n43) );
  sky130_fd_sc_hd__inv_2 U238 ( .A(s_arch_idh_q[19]), .Y(n44) );
  sky130_fd_sc_hd__inv_2 U239 ( .A(s_arch_sys_q[0]), .Y(n1) );
  sky130_fd_sc_hd__inv_2 U240 ( .A(s_arch_sys_q[1]), .Y(n2) );
  sky130_fd_sc_hd__inv_2 U241 ( .A(s_arch_sys_q[2]), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U242 ( .A(s_arch_sys_q[3]), .Y(n4) );
  sky130_fd_sc_hd__inv_2 U243 ( .A(s_arch_sys_q[4]), .Y(n5) );
  sky130_fd_sc_hd__inv_2 U244 ( .A(s_arch_sys_q[5]), .Y(n6) );
  sky130_fd_sc_hd__inv_2 U245 ( .A(s_arch_sys_q[6]), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U246 ( .A(s_arch_sys_q[7]), .Y(n8) );
  sky130_fd_sc_hd__inv_2 U247 ( .A(s_arch_sys_q[8]), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U248 ( .A(s_arch_sys_q[9]), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U249 ( .A(s_arch_sys_q[10]), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U250 ( .A(s_arch_sys_q[11]), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U251 ( .A(s_arch_sys_q[12]), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U252 ( .A(s_arch_sys_q[13]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U253 ( .A(s_arch_sys_q[14]), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U254 ( .A(s_arch_sys_q[15]), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U255 ( .A(s_arch_sys_q[16]), .Y(n17) );
  sky130_fd_sc_hd__inv_2 U256 ( .A(s_arch_sys_q[17]), .Y(n18) );
  sky130_fd_sc_hd__inv_2 U257 ( .A(s_arch_sys_q[18]), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U258 ( .A(s_arch_sys_q[19]), .Y(n20) );
  sky130_fd_sc_hd__nor2_1 U259 ( .A(apb4_paddr[5]), .B(apb4_paddr[4]), .Y(n84)
         );
  sky130_fd_sc_hd__nor2_1 U260 ( .A(apb4_paddr[2]), .B(apb4_paddr[3]), .Y(n78)
         );
  sky130_fd_sc_hd__nand2_1 U261 ( .A(n108), .B(n78), .Y(n85) );
  sky130_fd_sc_hd__inv_2 U262 ( .A(n94), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U263 ( .A(n108), .B(n78), .Y(n109) );
  sky130_fd_sc_hd__nand2_1 U264 ( .A(n108), .B(n81), .Y(n94) );
  sky130_fd_sc_hd__inv_2 U265 ( .A(s_arch_idh_q[20]), .Y(n45) );
  sky130_fd_sc_hd__inv_2 U266 ( .A(s_arch_idh_q[21]), .Y(n46) );
  sky130_fd_sc_hd__inv_2 U267 ( .A(s_arch_idh_q[22]), .Y(n47) );
  sky130_fd_sc_hd__inv_2 U268 ( .A(s_arch_idh_q[23]), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U269 ( .A(s_arch_idl_q[20]), .Y(n21) );
  sky130_fd_sc_hd__inv_2 U270 ( .A(apb4_pwdata[20]), .Y(n56) );
  sky130_fd_sc_hd__inv_2 U271 ( .A(s_arch_idl_q[21]), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U272 ( .A(apb4_pwdata[21]), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U273 ( .A(s_arch_idl_q[22]), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U274 ( .A(apb4_pwdata[22]), .Y(n54) );
  sky130_fd_sc_hd__inv_2 U275 ( .A(s_arch_idl_q[23]), .Y(n24) );
  sky130_fd_sc_hd__inv_2 U276 ( .A(apb4_pwdata[23]), .Y(n53) );
  sky130_fd_sc_hd__inv_2 U277 ( .A(apb4_pwdata[0]), .Y(n76) );
  sky130_fd_sc_hd__inv_2 U278 ( .A(apb4_pwdata[1]), .Y(n75) );
  sky130_fd_sc_hd__inv_2 U279 ( .A(apb4_pwdata[2]), .Y(n74) );
  sky130_fd_sc_hd__inv_2 U280 ( .A(apb4_pwdata[3]), .Y(n73) );
  sky130_fd_sc_hd__inv_2 U281 ( .A(apb4_pwdata[4]), .Y(n72) );
  sky130_fd_sc_hd__inv_2 U282 ( .A(apb4_pwdata[5]), .Y(n71) );
  sky130_fd_sc_hd__inv_2 U283 ( .A(apb4_pwdata[6]), .Y(n70) );
  sky130_fd_sc_hd__inv_2 U284 ( .A(apb4_pwdata[7]), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U285 ( .A(apb4_pwdata[8]), .Y(n68) );
  sky130_fd_sc_hd__inv_2 U286 ( .A(apb4_pwdata[9]), .Y(n67) );
  sky130_fd_sc_hd__inv_2 U287 ( .A(apb4_pwdata[10]), .Y(n66) );
  sky130_fd_sc_hd__inv_2 U288 ( .A(apb4_pwdata[11]), .Y(n65) );
  sky130_fd_sc_hd__inv_2 U289 ( .A(apb4_pwdata[12]), .Y(n64) );
  sky130_fd_sc_hd__inv_2 U290 ( .A(apb4_pwdata[13]), .Y(n63) );
  sky130_fd_sc_hd__inv_2 U291 ( .A(apb4_pwdata[14]), .Y(n62) );
  sky130_fd_sc_hd__inv_2 U292 ( .A(apb4_pwdata[15]), .Y(n61) );
  sky130_fd_sc_hd__inv_2 U293 ( .A(apb4_pwdata[16]), .Y(n60) );
  sky130_fd_sc_hd__inv_2 U294 ( .A(apb4_pwdata[17]), .Y(n59) );
  sky130_fd_sc_hd__inv_2 U295 ( .A(apb4_pwdata[18]), .Y(n58) );
  sky130_fd_sc_hd__nand2_1 U296 ( .A(n78), .B(n79), .Y(n77) );
  sky130_fd_sc_hd__inv_2 U297 ( .A(apb4_pwdata[19]), .Y(n57) );
  sky130_fd_sc_hd__o221ai_1 U298 ( .A1(n1), .A2(n109), .B1(n25), .B2(n86), 
        .C1(n107), .Y(apb4_prdata[0]) );
  sky130_fd_sc_hd__o221ai_1 U299 ( .A1(n2), .A2(n85), .B1(n26), .B2(n86), .C1(
        n96), .Y(apb4_prdata[1]) );
  sky130_fd_sc_hd__o221ai_1 U300 ( .A1(n3), .A2(n109), .B1(n27), .B2(n86), 
        .C1(n95), .Y(apb4_prdata[2]) );
  sky130_fd_sc_hd__o221ai_1 U301 ( .A1(n4), .A2(n85), .B1(n28), .B2(n86), .C1(
        n93), .Y(apb4_prdata[3]) );
  sky130_fd_sc_hd__o221ai_1 U302 ( .A1(n5), .A2(n109), .B1(n29), .B2(n86), 
        .C1(n92), .Y(apb4_prdata[4]) );
  sky130_fd_sc_hd__o221ai_1 U303 ( .A1(n6), .A2(n85), .B1(n30), .B2(n86), .C1(
        n91), .Y(apb4_prdata[5]) );
  sky130_fd_sc_hd__o221ai_1 U304 ( .A1(n7), .A2(n109), .B1(n31), .B2(n86), 
        .C1(n90), .Y(apb4_prdata[6]) );
  sky130_fd_sc_hd__o221ai_1 U305 ( .A1(n8), .A2(n85), .B1(n32), .B2(n86), .C1(
        n89), .Y(apb4_prdata[7]) );
  sky130_fd_sc_hd__o221ai_1 U306 ( .A1(n9), .A2(n109), .B1(n33), .B2(n86), 
        .C1(n88), .Y(apb4_prdata[8]) );
  sky130_fd_sc_hd__o221ai_1 U307 ( .A1(n10), .A2(n85), .B1(n34), .B2(n86), 
        .C1(n87), .Y(apb4_prdata[9]) );
  sky130_fd_sc_hd__o221ai_1 U308 ( .A1(n11), .A2(n85), .B1(n35), .B2(n86), 
        .C1(n106), .Y(apb4_prdata[10]) );
  sky130_fd_sc_hd__o221ai_1 U309 ( .A1(n12), .A2(n109), .B1(n36), .B2(n86), 
        .C1(n105), .Y(apb4_prdata[11]) );
  sky130_fd_sc_hd__o221ai_1 U310 ( .A1(n13), .A2(n85), .B1(n37), .B2(n86), 
        .C1(n104), .Y(apb4_prdata[12]) );
  sky130_fd_sc_hd__o221ai_1 U311 ( .A1(n14), .A2(n109), .B1(n38), .B2(n86), 
        .C1(n103), .Y(apb4_prdata[13]) );
  sky130_fd_sc_hd__o221ai_1 U312 ( .A1(n15), .A2(n85), .B1(n39), .B2(n86), 
        .C1(n102), .Y(apb4_prdata[14]) );
  sky130_fd_sc_hd__o221ai_1 U313 ( .A1(n16), .A2(n109), .B1(n40), .B2(n86), 
        .C1(n101), .Y(apb4_prdata[15]) );
  sky130_fd_sc_hd__o221ai_1 U314 ( .A1(n17), .A2(n85), .B1(n41), .B2(n86), 
        .C1(n100), .Y(apb4_prdata[16]) );
  sky130_fd_sc_hd__o221ai_1 U315 ( .A1(n18), .A2(n109), .B1(n42), .B2(n86), 
        .C1(n99), .Y(apb4_prdata[17]) );
  sky130_fd_sc_hd__o221ai_1 U316 ( .A1(n19), .A2(n85), .B1(n43), .B2(n86), 
        .C1(n98), .Y(apb4_prdata[18]) );
  sky130_fd_sc_hd__o221ai_1 U317 ( .A1(n20), .A2(n109), .B1(n44), .B2(n86), 
        .C1(n97), .Y(apb4_prdata[19]) );
  sky130_fd_sc_hd__o22ai_1 U318 ( .A1(n21), .A2(n94), .B1(n45), .B2(n86), .Y(
        apb4_prdata[20]) );
  sky130_fd_sc_hd__o22ai_1 U319 ( .A1(n22), .A2(n94), .B1(n46), .B2(n86), .Y(
        apb4_prdata[21]) );
  sky130_fd_sc_hd__o22ai_1 U320 ( .A1(n23), .A2(n94), .B1(n47), .B2(n86), .Y(
        apb4_prdata[22]) );
  sky130_fd_sc_hd__o22ai_1 U321 ( .A1(n24), .A2(n94), .B1(n48), .B2(n86), .Y(
        apb4_prdata[23]) );
  sky130_fd_sc_hd__o22ai_1 U322 ( .A1(n76), .A2(n82), .B1(n110), .B2(n25), .Y(
        s_arch_idh_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U323 ( .A1(n75), .A2(n82), .B1(n110), .B2(n26), .Y(
        s_arch_idh_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U324 ( .A1(n74), .A2(n82), .B1(n110), .B2(n27), .Y(
        s_arch_idh_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U325 ( .A1(n73), .A2(n82), .B1(n111), .B2(n28), .Y(
        s_arch_idh_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U326 ( .A1(n72), .A2(n82), .B1(n110), .B2(n29), .Y(
        s_arch_idh_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U327 ( .A1(n71), .A2(n82), .B1(n111), .B2(n30), .Y(
        s_arch_idh_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U328 ( .A1(n70), .A2(n82), .B1(n110), .B2(n31), .Y(
        s_arch_idh_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U329 ( .A1(n69), .A2(n82), .B1(n111), .B2(n32), .Y(
        s_arch_idh_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U330 ( .A1(n68), .A2(n82), .B1(n110), .B2(n33), .Y(
        s_arch_idh_d[8]) );
  sky130_fd_sc_hd__o22ai_1 U331 ( .A1(n67), .A2(n82), .B1(n111), .B2(n34), .Y(
        s_arch_idh_d[9]) );
  sky130_fd_sc_hd__o22ai_1 U332 ( .A1(n66), .A2(n82), .B1(n111), .B2(n35), .Y(
        s_arch_idh_d[10]) );
  sky130_fd_sc_hd__o22ai_1 U333 ( .A1(n65), .A2(n82), .B1(n111), .B2(n36), .Y(
        s_arch_idh_d[11]) );
  sky130_fd_sc_hd__o22ai_1 U334 ( .A1(n64), .A2(n82), .B1(n111), .B2(n37), .Y(
        s_arch_idh_d[12]) );
  sky130_fd_sc_hd__o22ai_1 U335 ( .A1(n63), .A2(n82), .B1(n111), .B2(n38), .Y(
        s_arch_idh_d[13]) );
  sky130_fd_sc_hd__o22ai_1 U336 ( .A1(n62), .A2(n82), .B1(n111), .B2(n39), .Y(
        s_arch_idh_d[14]) );
  sky130_fd_sc_hd__o22ai_1 U337 ( .A1(n61), .A2(n82), .B1(n111), .B2(n40), .Y(
        s_arch_idh_d[15]) );
  sky130_fd_sc_hd__o22ai_1 U338 ( .A1(n60), .A2(n82), .B1(n111), .B2(n41), .Y(
        s_arch_idh_d[16]) );
  sky130_fd_sc_hd__o22ai_1 U339 ( .A1(n59), .A2(n82), .B1(n111), .B2(n42), .Y(
        s_arch_idh_d[17]) );
  sky130_fd_sc_hd__o22ai_1 U340 ( .A1(n58), .A2(n82), .B1(n111), .B2(n43), .Y(
        s_arch_idh_d[18]) );
  sky130_fd_sc_hd__o22ai_1 U341 ( .A1(n57), .A2(n82), .B1(n111), .B2(n44), .Y(
        s_arch_idh_d[19]) );
  sky130_fd_sc_hd__o22ai_1 U342 ( .A1(n56), .A2(n82), .B1(n110), .B2(n45), .Y(
        s_arch_idh_d[20]) );
  sky130_fd_sc_hd__o22ai_1 U343 ( .A1(n55), .A2(n82), .B1(n111), .B2(n46), .Y(
        s_arch_idh_d[21]) );
  sky130_fd_sc_hd__o22ai_1 U344 ( .A1(n54), .A2(n82), .B1(n110), .B2(n47), .Y(
        s_arch_idh_d[22]) );
  sky130_fd_sc_hd__o22ai_1 U345 ( .A1(n53), .A2(n82), .B1(n111), .B2(n48), .Y(
        s_arch_idh_d[23]) );
  sky130_fd_sc_hd__o22ai_1 U346 ( .A1(n80), .A2(n56), .B1(n113), .B2(n21), .Y(
        s_arch_idl_d[20]) );
  sky130_fd_sc_hd__o22ai_1 U347 ( .A1(n80), .A2(n55), .B1(n113), .B2(n22), .Y(
        s_arch_idl_d[21]) );
  sky130_fd_sc_hd__o22ai_1 U348 ( .A1(n80), .A2(n54), .B1(n112), .B2(n23), .Y(
        s_arch_idl_d[22]) );
  sky130_fd_sc_hd__o22ai_1 U349 ( .A1(n80), .A2(n53), .B1(n113), .B2(n24), .Y(
        s_arch_idl_d[23]) );
  sky130_fd_sc_hd__o22ai_1 U350 ( .A1(n77), .A2(n76), .B1(n52), .B2(n1), .Y(
        s_arch_sys_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U351 ( .A1(n77), .A2(n75), .B1(n52), .B2(n2), .Y(
        s_arch_sys_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U352 ( .A1(n77), .A2(n74), .B1(n52), .B2(n3), .Y(
        s_arch_sys_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U353 ( .A1(n77), .A2(n73), .B1(n52), .B2(n4), .Y(
        s_arch_sys_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U354 ( .A1(n77), .A2(n72), .B1(n52), .B2(n5), .Y(
        s_arch_sys_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U355 ( .A1(n77), .A2(n71), .B1(n52), .B2(n6), .Y(
        s_arch_sys_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U356 ( .A1(n77), .A2(n70), .B1(n52), .B2(n7), .Y(
        s_arch_sys_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U357 ( .A1(n77), .A2(n69), .B1(n52), .B2(n8), .Y(
        s_arch_sys_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U358 ( .A1(n77), .A2(n68), .B1(n52), .B2(n9), .Y(
        s_arch_sys_d[8]) );
  sky130_fd_sc_hd__o22ai_1 U359 ( .A1(n77), .A2(n67), .B1(n52), .B2(n10), .Y(
        s_arch_sys_d[9]) );
  sky130_fd_sc_hd__o22ai_1 U360 ( .A1(n77), .A2(n66), .B1(n52), .B2(n11), .Y(
        s_arch_sys_d[10]) );
  sky130_fd_sc_hd__o22ai_1 U361 ( .A1(n77), .A2(n65), .B1(n52), .B2(n12), .Y(
        s_arch_sys_d[11]) );
  sky130_fd_sc_hd__o22ai_1 U362 ( .A1(n77), .A2(n64), .B1(n52), .B2(n13), .Y(
        s_arch_sys_d[12]) );
  sky130_fd_sc_hd__o22ai_1 U363 ( .A1(n77), .A2(n63), .B1(n52), .B2(n14), .Y(
        s_arch_sys_d[13]) );
  sky130_fd_sc_hd__o22ai_1 U364 ( .A1(n77), .A2(n62), .B1(n52), .B2(n15), .Y(
        s_arch_sys_d[14]) );
  sky130_fd_sc_hd__o22ai_1 U365 ( .A1(n77), .A2(n61), .B1(n52), .B2(n16), .Y(
        s_arch_sys_d[15]) );
  sky130_fd_sc_hd__o22ai_1 U366 ( .A1(n77), .A2(n60), .B1(n52), .B2(n17), .Y(
        s_arch_sys_d[16]) );
  sky130_fd_sc_hd__o22ai_1 U367 ( .A1(n77), .A2(n59), .B1(n52), .B2(n18), .Y(
        s_arch_sys_d[17]) );
  sky130_fd_sc_hd__o22ai_1 U368 ( .A1(n77), .A2(n58), .B1(n52), .B2(n19), .Y(
        s_arch_sys_d[18]) );
  sky130_fd_sc_hd__o22ai_1 U369 ( .A1(n77), .A2(n57), .B1(n52), .B2(n20), .Y(
        s_arch_sys_d[19]) );
  sky130_fd_sc_hd__buf_1 U370 ( .A(n111), .X(n110) );
  sky130_fd_sc_hd__buf_1 U371 ( .A(n113), .X(n112) );
  sky130_fd_sc_hd__inv_2 U372 ( .A(n77), .Y(n52) );
  sky130_fd_sc_hd__inv_2 U373 ( .A(n82), .Y(n111) );
  sky130_fd_sc_hd__inv_2 U374 ( .A(n80), .Y(n113) );
  sky130_fd_sc_hd__conb_1 U375 ( .LO(apb4_pslverr), .HI(apb4_pready) );
endmodule

