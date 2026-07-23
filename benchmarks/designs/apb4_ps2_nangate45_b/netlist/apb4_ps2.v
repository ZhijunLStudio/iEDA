/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 15:53:08 2025
/////////////////////////////////////////////////////////////


module dffr_DATA_WIDTH2 ( clk_i, rst_n_i, dat_i, dat_o );
  input [1:0] dat_i;
  output [1:0] dat_o;
  input clk_i, rst_n_i;


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


module dffr_DATA_WIDTH1_3 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module edge_det_fe_STAGE2_DATA_WIDTH1 ( clk_i, rst_n_i, dat_i, fe_o );
  input [0:0] dat_i;
  output [0:0] fe_o;
  input clk_i, rst_n_i;
  wire   \s_dat_d[0] , \s_dat_q[0] ;

  cdc_sync_STAGE2_DATA_WIDTH1 u_cdc_sync ( .clk_i(clk_i), .rst_n_i(rst_n_i), 
        .dat_i(dat_i[0]), .dat_o(\s_dat_d[0] ) );
  dffr_DATA_WIDTH1_3 u_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        \s_dat_d[0] ), .dat_o(\s_dat_q[0] ) );
  sky130_fd_sc_hd__nor2b_4 U1 ( .B_N(\s_dat_q[0] ), .A(\s_dat_d[0] ), .Y(
        fe_o[0]) );
endmodule


module dffr_DATA_WIDTH4_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [3:0] dat_i;
  output [3:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
endmodule


module dffr_DATA_WIDTH10 ( clk_i, rst_n_i, dat_i, dat_o );
  input [9:0] dat_i;
  output [9:0] dat_o;
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[9]) );
endmodule


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


module dffr_DATA_WIDTH3_1 ( clk_i, rst_n_i, dat_i, dat_o );
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


module dffr_DATA_WIDTH4_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [3:0] dat_i;
  output [3:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
endmodule


module dffr_DATA_WIDTH64 ( clk_i, rst_n_i, dat_i, dat_o );
  input [63:0] dat_i;
  output [63:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3, n4, n5;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[58]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[52]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[51]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(rst_n_i), .X(n3) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(rst_n_i), .X(n1) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(rst_n_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(rst_n_i), .X(n5) );
endmodule


module fifo_DATA_WIDTH8_BUFFER_DEPTH8 ( clk_i, rst_n_i, flush_i, full_o, 
        empty_o, cnt_o, dat_i, push_i, dat_o, pop_i );
  output [3:0] cnt_o;
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i, flush_i, push_i, pop_i;
  output full_o, empty_o;
  wire   N23, N24, N25, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13,
         n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27,
         n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41,
         n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55,
         n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69,
         n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97,
         n98, n99, n100, n101, n102, n103, n104, n105, n106, n107, n108, n109,
         n110, n111, n112, n113, n114, n115, n116, n117, n118, n119, n120,
         n121, n122, n123, n124, n125, n126, n127, n128, n129, n130, n131,
         n132, n133, n134, n135, n136, n137, n138, n139, n140, n141, n142,
         n143, n144, n145, n146, n147, n148, n149, n150, n151, n152, n153,
         n154, n155, n156, n157, n158, n159, n160, n161, n162, n163, n164,
         n165, n166, n167, n168, n169, n170, n171, n172, n173, n174, n175,
         n176, n177, n178, n179, n180, n181, n182, n183, n184, n185, n186,
         n187, n188, n189, n190, n191, n192, n193, n194, n195, n196, n197,
         n198, n199, n200, n201, n202, n203, n204, n205, n206, n207, n208,
         n209, n210, n211, n212, n213, n214, n215, n216, n217, n218, n219,
         n220, n221, n222, n225;
  wire   [63:0] s_mem_q;
  wire   [2:0] s_rd_ptr_d;
  wire   [2:0] s_wr_ptr_d;
  wire   [2:0] s_wr_ptr_q;
  wire   [3:0] s_cnt_d;
  wire   [63:0] s_mem_d;

  dffr_DATA_WIDTH3_0 u_rd_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_rd_ptr_d), .dat_o({N25, N24, N23}) );
  dffr_DATA_WIDTH3_1 u_wr_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_wr_ptr_d), .dat_o(s_wr_ptr_q) );
  dffr_DATA_WIDTH4_1 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_cnt_d), .dat_o(cnt_o) );
  dffr_DATA_WIDTH64 u_mem_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_mem_d), .dat_o(s_mem_q) );
  sky130_fd_sc_hd__mux2i_1 U3 ( .A0(n74), .A1(n75), .S(n78), .Y(s_cnt_d[0]) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(cnt_o[0]), .Y(n78) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n204), .Y(n70) );
  sky130_fd_sc_hd__mux2i_1 U6 ( .A0(n96), .A1(n97), .S(n102), .Y(s_cnt_d[2])
         );
  sky130_fd_sc_hd__clkinv_1 U7 ( .A(cnt_o[2]), .Y(n102) );
  sky130_fd_sc_hd__clkinv_1 U8 ( .A(n175), .Y(n1) );
  sky130_fd_sc_hd__clkinv_1 U9 ( .A(n175), .Y(n60) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(n70), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n7), .B(n16), .Y(n3) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n7), .B(n16), .Y(n163) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n111), .B(s_wr_ptr_q[0]), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U14 ( .A(n111), .B(s_wr_ptr_q[0]), .Y(n112) );
  sky130_fd_sc_hd__clkinv_2 U15 ( .A(n58), .Y(n200) );
  sky130_fd_sc_hd__nand2_2 U16 ( .A(n221), .B(n210), .Y(n220) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(n214), .Y(n208) );
  sky130_fd_sc_hd__a211oi_1 U18 ( .A1(n106), .A2(n107), .B1(n95), .C1(n94), 
        .Y(n96) );
  sky130_fd_sc_hd__and2_4 U19 ( .A(n65), .B(n15), .X(n13) );
  sky130_fd_sc_hd__nand2_2 U20 ( .A(n70), .B(n73), .Y(n106) );
  sky130_fd_sc_hd__o31ai_2 U21 ( .A1(n88), .A2(flush_i), .A3(full_o), .B1(n218), .Y(n107) );
  sky130_fd_sc_hd__inv_1 U22 ( .A(n143), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(n12), .Y(n6) );
  sky130_fd_sc_hd__and2_4 U24 ( .A(n65), .B(n18), .X(n10) );
  sky130_fd_sc_hd__and2_4 U25 ( .A(n65), .B(n18), .X(n55) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(n122), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(n122), .Y(n184) );
  sky130_fd_sc_hd__nand2_1 U28 ( .A(n184), .B(n18), .Y(n8) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n184), .B(n18), .Y(n123) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(n121), .B(n209), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U31 ( .A(n121), .B(n209), .Y(n122) );
  sky130_fd_sc_hd__clkinv_1 U32 ( .A(n89), .Y(n80) );
  sky130_fd_sc_hd__clkinv_2 U33 ( .A(n3), .Y(n63) );
  sky130_fd_sc_hd__clkinv_2 U34 ( .A(n163), .Y(n171) );
  sky130_fd_sc_hd__clkinv_2 U35 ( .A(n12), .Y(n151) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(n9), .Y(n11) );
  sky130_fd_sc_hd__clkinv_2 U37 ( .A(n123), .Y(n131) );
  sky130_fd_sc_hd__inv_1 U38 ( .A(n185), .Y(n57) );
  sky130_fd_sc_hd__nand2_1 U39 ( .A(n11), .B(n17), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n11), .B(n17), .Y(n143) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(n4), .Y(n65) );
  sky130_fd_sc_hd__o21ai_0 U42 ( .A1(n92), .A2(n208), .B1(n106), .Y(n74) );
  sky130_fd_sc_hd__a21boi_1 U43 ( .A1(n210), .A2(n209), .B1_N(n213), .Y(n211)
         );
  sky130_fd_sc_hd__inv_2 U44 ( .A(n218), .Y(n92) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n65), .B(n15), .Y(n175) );
  sky130_fd_sc_hd__inv_2 U46 ( .A(n220), .Y(n90) );
  sky130_fd_sc_hd__inv_1 U47 ( .A(n93), .Y(n94) );
  sky130_fd_sc_hd__inv_1 U48 ( .A(n99), .Y(n100) );
  sky130_fd_sc_hd__inv_1 U49 ( .A(n222), .Y(empty_o) );
  sky130_fd_sc_hd__inv_1 U50 ( .A(n68), .Y(n69) );
  sky130_fd_sc_hd__o21a_1 U51 ( .A1(n220), .A2(N23), .B1(n218), .X(n14) );
  sky130_fd_sc_hd__and2_0 U52 ( .A(n173), .B(n206), .X(n15) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n84), .Y(n98) );
  sky130_fd_sc_hd__nor2_1 U54 ( .A(n225), .B(n215), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U55 ( .A(n87), .Y(full_o) );
  sky130_fd_sc_hd__a21oi_1 U56 ( .A1(n86), .A2(n92), .B1(n85), .Y(n97) );
  sky130_fd_sc_hd__nor2_1 U57 ( .A(n89), .B(n220), .Y(n85) );
  sky130_fd_sc_hd__inv_1 U58 ( .A(n76), .Y(n71) );
  sky130_fd_sc_hd__inv_2 U59 ( .A(N25), .Y(n225) );
  sky130_fd_sc_hd__and2_0 U60 ( .A(s_wr_ptr_q[1]), .B(n206), .X(n16) );
  sky130_fd_sc_hd__and2_0 U61 ( .A(s_wr_ptr_q[2]), .B(n173), .X(n17) );
  sky130_fd_sc_hd__and2_0 U62 ( .A(s_wr_ptr_q[1]), .B(s_wr_ptr_q[2]), .X(n18)
         );
  sky130_fd_sc_hd__nor2_1 U63 ( .A(n215), .B(N25), .Y(n49) );
  sky130_fd_sc_hd__nor2_1 U64 ( .A(N24), .B(N25), .Y(n48) );
  sky130_fd_sc_hd__nor2_1 U65 ( .A(n225), .B(N24), .Y(n52) );
  sky130_fd_sc_hd__a22o_1 U66 ( .A1(s_mem_q[24]), .A2(n49), .B1(s_mem_q[8]), 
        .B2(n48), .X(n19) );
  sky130_fd_sc_hd__a221oi_1 U67 ( .A1(s_mem_q[40]), .A2(n52), .B1(s_mem_q[56]), 
        .B2(n51), .C1(n19), .Y(n22) );
  sky130_fd_sc_hd__a22o_1 U68 ( .A1(s_mem_q[16]), .A2(n49), .B1(s_mem_q[0]), 
        .B2(n48), .X(n20) );
  sky130_fd_sc_hd__a221oi_1 U69 ( .A1(s_mem_q[32]), .A2(n52), .B1(s_mem_q[48]), 
        .B2(n51), .C1(n20), .Y(n21) );
  sky130_fd_sc_hd__o22ai_1 U70 ( .A1(n216), .A2(n22), .B1(N23), .B2(n21), .Y(
        dat_o[0]) );
  sky130_fd_sc_hd__a22o_1 U71 ( .A1(s_mem_q[25]), .A2(n49), .B1(s_mem_q[9]), 
        .B2(n48), .X(n23) );
  sky130_fd_sc_hd__a221oi_1 U72 ( .A1(s_mem_q[41]), .A2(n52), .B1(s_mem_q[57]), 
        .B2(n51), .C1(n23), .Y(n26) );
  sky130_fd_sc_hd__a22o_1 U73 ( .A1(s_mem_q[17]), .A2(n49), .B1(s_mem_q[1]), 
        .B2(n48), .X(n24) );
  sky130_fd_sc_hd__a221oi_1 U74 ( .A1(s_mem_q[33]), .A2(n52), .B1(s_mem_q[49]), 
        .B2(n51), .C1(n24), .Y(n25) );
  sky130_fd_sc_hd__o22ai_1 U75 ( .A1(n216), .A2(n26), .B1(N23), .B2(n25), .Y(
        dat_o[1]) );
  sky130_fd_sc_hd__a22o_1 U76 ( .A1(s_mem_q[26]), .A2(n49), .B1(s_mem_q[10]), 
        .B2(n48), .X(n27) );
  sky130_fd_sc_hd__a221oi_1 U77 ( .A1(s_mem_q[42]), .A2(n52), .B1(s_mem_q[58]), 
        .B2(n51), .C1(n27), .Y(n30) );
  sky130_fd_sc_hd__a22o_1 U78 ( .A1(s_mem_q[18]), .A2(n49), .B1(s_mem_q[2]), 
        .B2(n48), .X(n28) );
  sky130_fd_sc_hd__a221oi_1 U79 ( .A1(s_mem_q[34]), .A2(n52), .B1(s_mem_q[50]), 
        .B2(n51), .C1(n28), .Y(n29) );
  sky130_fd_sc_hd__o22ai_1 U80 ( .A1(n216), .A2(n30), .B1(N23), .B2(n29), .Y(
        dat_o[2]) );
  sky130_fd_sc_hd__a22o_1 U81 ( .A1(s_mem_q[27]), .A2(n49), .B1(s_mem_q[11]), 
        .B2(n48), .X(n31) );
  sky130_fd_sc_hd__a221oi_1 U82 ( .A1(s_mem_q[43]), .A2(n52), .B1(s_mem_q[59]), 
        .B2(n51), .C1(n31), .Y(n34) );
  sky130_fd_sc_hd__a22o_1 U83 ( .A1(s_mem_q[19]), .A2(n49), .B1(s_mem_q[3]), 
        .B2(n48), .X(n32) );
  sky130_fd_sc_hd__a221oi_1 U84 ( .A1(s_mem_q[35]), .A2(n52), .B1(s_mem_q[51]), 
        .B2(n51), .C1(n32), .Y(n33) );
  sky130_fd_sc_hd__o22ai_1 U85 ( .A1(n216), .A2(n34), .B1(N23), .B2(n33), .Y(
        dat_o[3]) );
  sky130_fd_sc_hd__a22o_1 U86 ( .A1(s_mem_q[28]), .A2(n49), .B1(s_mem_q[12]), 
        .B2(n48), .X(n35) );
  sky130_fd_sc_hd__a221oi_1 U87 ( .A1(s_mem_q[44]), .A2(n52), .B1(s_mem_q[60]), 
        .B2(n51), .C1(n35), .Y(n38) );
  sky130_fd_sc_hd__a22o_1 U88 ( .A1(s_mem_q[20]), .A2(n49), .B1(s_mem_q[4]), 
        .B2(n48), .X(n36) );
  sky130_fd_sc_hd__a221oi_1 U89 ( .A1(s_mem_q[36]), .A2(n52), .B1(s_mem_q[52]), 
        .B2(n51), .C1(n36), .Y(n37) );
  sky130_fd_sc_hd__o22ai_1 U90 ( .A1(n216), .A2(n38), .B1(N23), .B2(n37), .Y(
        dat_o[4]) );
  sky130_fd_sc_hd__a22o_1 U91 ( .A1(s_mem_q[29]), .A2(n49), .B1(s_mem_q[13]), 
        .B2(n48), .X(n39) );
  sky130_fd_sc_hd__a221oi_1 U92 ( .A1(s_mem_q[45]), .A2(n52), .B1(s_mem_q[61]), 
        .B2(n51), .C1(n39), .Y(n42) );
  sky130_fd_sc_hd__a22o_1 U93 ( .A1(s_mem_q[21]), .A2(n49), .B1(s_mem_q[5]), 
        .B2(n48), .X(n40) );
  sky130_fd_sc_hd__a221oi_1 U94 ( .A1(s_mem_q[37]), .A2(n52), .B1(s_mem_q[53]), 
        .B2(n51), .C1(n40), .Y(n41) );
  sky130_fd_sc_hd__o22ai_1 U95 ( .A1(n216), .A2(n42), .B1(N23), .B2(n41), .Y(
        dat_o[5]) );
  sky130_fd_sc_hd__a22o_1 U96 ( .A1(s_mem_q[30]), .A2(n49), .B1(s_mem_q[14]), 
        .B2(n48), .X(n43) );
  sky130_fd_sc_hd__a221oi_1 U97 ( .A1(s_mem_q[46]), .A2(n52), .B1(s_mem_q[62]), 
        .B2(n51), .C1(n43), .Y(n46) );
  sky130_fd_sc_hd__a22o_1 U98 ( .A1(s_mem_q[22]), .A2(n49), .B1(s_mem_q[6]), 
        .B2(n48), .X(n44) );
  sky130_fd_sc_hd__a221oi_1 U99 ( .A1(s_mem_q[38]), .A2(n52), .B1(s_mem_q[54]), 
        .B2(n51), .C1(n44), .Y(n45) );
  sky130_fd_sc_hd__o22ai_1 U100 ( .A1(n216), .A2(n46), .B1(N23), .B2(n45), .Y(
        dat_o[6]) );
  sky130_fd_sc_hd__a22o_1 U101 ( .A1(s_mem_q[31]), .A2(n49), .B1(s_mem_q[15]), 
        .B2(n48), .X(n47) );
  sky130_fd_sc_hd__a221oi_1 U102 ( .A1(s_mem_q[47]), .A2(n52), .B1(s_mem_q[63]), .B2(n51), .C1(n47), .Y(n54) );
  sky130_fd_sc_hd__a22o_1 U103 ( .A1(s_mem_q[23]), .A2(n49), .B1(s_mem_q[7]), 
        .B2(n48), .X(n50) );
  sky130_fd_sc_hd__a221oi_1 U104 ( .A1(s_mem_q[39]), .A2(n52), .B1(s_mem_q[55]), .B2(n51), .C1(n50), .Y(n53) );
  sky130_fd_sc_hd__o22ai_1 U105 ( .A1(n54), .A2(n216), .B1(N23), .B2(n53), .Y(
        dat_o[7]) );
  sky130_fd_sc_hd__clkinv_1 U106 ( .A(n185), .Y(n64) );
  sky130_fd_sc_hd__mux2i_1 U107 ( .A0(n188), .A1(n189), .S(n59), .Y(s_mem_d[6]) );
  sky130_fd_sc_hd__inv_1 U108 ( .A(n104), .Y(n79) );
  sky130_fd_sc_hd__clkinv_2 U109 ( .A(n8), .Y(n56) );
  sky130_fd_sc_hd__nand2_1 U110 ( .A(n61), .B(n15), .Y(n58) );
  sky130_fd_sc_hd__nand2_1 U111 ( .A(n61), .B(n15), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(n61), .B(n15), .Y(n185) );
  sky130_fd_sc_hd__clkinv_1 U113 ( .A(n112), .Y(n174) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(n72), .Y(n111) );
  sky130_fd_sc_hd__mux2i_1 U115 ( .A0(n192), .A1(n193), .S(n59), .Y(s_mem_d[4]) );
  sky130_fd_sc_hd__inv_1 U116 ( .A(n9), .Y(n61) );
  sky130_fd_sc_hd__clkinv_2 U117 ( .A(n143), .Y(n62) );
  sky130_fd_sc_hd__nor2_1 U118 ( .A(n84), .B(n2), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U119 ( .A(n90), .B(n204), .Y(n104) );
  sky130_fd_sc_hd__nand2_1 U120 ( .A(push_i), .B(n87), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U121 ( .A(n72), .Y(n121) );
  sky130_fd_sc_hd__nand2_2 U122 ( .A(n78), .B(n91), .Y(n89) );
  sky130_fd_sc_hd__inv_2 U123 ( .A(cnt_o[1]), .Y(n91) );
  sky130_fd_sc_hd__inv_2 U124 ( .A(n73), .Y(n221) );
  sky130_fd_sc_hd__inv_2 U125 ( .A(n133), .Y(n66) );
  sky130_fd_sc_hd__inv_2 U126 ( .A(n133), .Y(n141) );
  sky130_fd_sc_hd__inv_2 U127 ( .A(n153), .Y(n67) );
  sky130_fd_sc_hd__inv_2 U128 ( .A(n153), .Y(n161) );
  sky130_fd_sc_hd__nand2_1 U129 ( .A(n80), .B(n102), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U130 ( .A(cnt_o[3]), .Y(n103) );
  sky130_fd_sc_hd__nand2_1 U131 ( .A(n69), .B(n103), .Y(n222) );
  sky130_fd_sc_hd__nand2_1 U132 ( .A(pop_i), .B(n222), .Y(n73) );
  sky130_fd_sc_hd__inv_1 U133 ( .A(flush_i), .Y(n210) );
  sky130_fd_sc_hd__nand2_1 U134 ( .A(cnt_o[3]), .B(n69), .Y(n87) );
  sky130_fd_sc_hd__nand2_1 U135 ( .A(push_i), .B(n87), .Y(n204) );
  sky130_fd_sc_hd__nand2_1 U136 ( .A(n73), .B(n210), .Y(n218) );
  sky130_fd_sc_hd__nand2_1 U137 ( .A(n70), .B(n92), .Y(n76) );
  sky130_fd_sc_hd__nor2_1 U138 ( .A(n79), .B(n71), .Y(n75) );
  sky130_fd_sc_hd__nand2_1 U139 ( .A(n121), .B(n210), .Y(n214) );
  sky130_fd_sc_hd__nor3_1 U140 ( .A(n76), .B(cnt_o[1]), .C(n78), .Y(n77) );
  sky130_fd_sc_hd__a31oi_1 U141 ( .A1(cnt_o[1]), .A2(n221), .A3(n208), .B1(n77), .Y(n83) );
  sky130_fd_sc_hd__nand2_1 U142 ( .A(n92), .B(n78), .Y(n93) );
  sky130_fd_sc_hd__a32oi_1 U143 ( .A1(n106), .A2(cnt_o[1]), .A3(n92), .B1(n94), 
        .B2(cnt_o[1]), .Y(n82) );
  sky130_fd_sc_hd__nand2_1 U144 ( .A(cnt_o[1]), .B(cnt_o[0]), .Y(n84) );
  sky130_fd_sc_hd__o21ai_1 U145 ( .A1(n80), .A2(n98), .B1(n79), .Y(n81) );
  sky130_fd_sc_hd__nand3_1 U146 ( .A(n83), .B(n82), .C(n81), .Y(s_cnt_d[1]) );
  sky130_fd_sc_hd__inv_1 U147 ( .A(push_i), .Y(n88) );
  sky130_fd_sc_hd__nand2_1 U148 ( .A(n90), .B(n89), .Y(n101) );
  sky130_fd_sc_hd__nand2_1 U149 ( .A(n92), .B(n91), .Y(n99) );
  sky130_fd_sc_hd__nand2_1 U150 ( .A(n101), .B(n99), .Y(n95) );
  sky130_fd_sc_hd__a32oi_1 U151 ( .A1(cnt_o[2]), .A2(n103), .A3(n98), .B1(
        cnt_o[3]), .B2(n102), .Y(n110) );
  sky130_fd_sc_hd__o21ai_1 U152 ( .A1(n94), .A2(n100), .B1(cnt_o[3]), .Y(n109)
         );
  sky130_fd_sc_hd__o32ai_1 U153 ( .A1(n102), .A2(n103), .A3(n104), .B1(n103), 
        .B2(n101), .Y(n105) );
  sky130_fd_sc_hd__a31oi_1 U154 ( .A1(cnt_o[3]), .A2(n107), .A3(n106), .B1(
        n105), .Y(n108) );
  sky130_fd_sc_hd__o311ai_1 U155 ( .A1(n214), .A2(n221), .A3(n110), .B1(n109), 
        .C1(n108), .Y(s_cnt_d[3]) );
  sky130_fd_sc_hd__inv_1 U156 ( .A(s_mem_q[63]), .Y(n113) );
  sky130_fd_sc_hd__inv_1 U157 ( .A(dat_i[7]), .Y(n186) );
  sky130_fd_sc_hd__mux2i_1 U158 ( .A0(n113), .A1(n186), .S(n10), .Y(
        s_mem_d[63]) );
  sky130_fd_sc_hd__inv_1 U159 ( .A(s_mem_q[62]), .Y(n114) );
  sky130_fd_sc_hd__inv_1 U160 ( .A(dat_i[6]), .Y(n188) );
  sky130_fd_sc_hd__mux2i_1 U161 ( .A0(n114), .A1(n188), .S(n10), .Y(
        s_mem_d[62]) );
  sky130_fd_sc_hd__inv_1 U162 ( .A(s_mem_q[61]), .Y(n115) );
  sky130_fd_sc_hd__inv_1 U163 ( .A(dat_i[5]), .Y(n190) );
  sky130_fd_sc_hd__mux2i_1 U164 ( .A0(n115), .A1(n190), .S(n55), .Y(
        s_mem_d[61]) );
  sky130_fd_sc_hd__inv_1 U165 ( .A(s_mem_q[60]), .Y(n116) );
  sky130_fd_sc_hd__inv_1 U166 ( .A(dat_i[4]), .Y(n192) );
  sky130_fd_sc_hd__mux2i_1 U167 ( .A0(n116), .A1(n192), .S(n10), .Y(
        s_mem_d[60]) );
  sky130_fd_sc_hd__inv_1 U168 ( .A(s_mem_q[59]), .Y(n117) );
  sky130_fd_sc_hd__inv_1 U169 ( .A(dat_i[3]), .Y(n194) );
  sky130_fd_sc_hd__mux2i_1 U170 ( .A0(n117), .A1(n194), .S(n55), .Y(
        s_mem_d[59]) );
  sky130_fd_sc_hd__inv_1 U171 ( .A(s_mem_q[58]), .Y(n118) );
  sky130_fd_sc_hd__inv_1 U172 ( .A(dat_i[2]), .Y(n196) );
  sky130_fd_sc_hd__mux2i_1 U173 ( .A0(n118), .A1(n196), .S(n55), .Y(
        s_mem_d[58]) );
  sky130_fd_sc_hd__inv_1 U174 ( .A(s_mem_q[57]), .Y(n119) );
  sky130_fd_sc_hd__inv_1 U175 ( .A(dat_i[1]), .Y(n198) );
  sky130_fd_sc_hd__mux2i_1 U176 ( .A0(n119), .A1(n198), .S(n10), .Y(
        s_mem_d[57]) );
  sky130_fd_sc_hd__inv_1 U177 ( .A(s_mem_q[56]), .Y(n120) );
  sky130_fd_sc_hd__inv_1 U178 ( .A(dat_i[0]), .Y(n201) );
  sky130_fd_sc_hd__mux2i_1 U179 ( .A0(n120), .A1(n201), .S(n55), .Y(
        s_mem_d[56]) );
  sky130_fd_sc_hd__inv_1 U180 ( .A(s_mem_q[55]), .Y(n124) );
  sky130_fd_sc_hd__inv_1 U181 ( .A(s_wr_ptr_q[0]), .Y(n209) );
  sky130_fd_sc_hd__mux2i_1 U182 ( .A0(n124), .A1(n186), .S(n56), .Y(
        s_mem_d[55]) );
  sky130_fd_sc_hd__inv_1 U183 ( .A(s_mem_q[54]), .Y(n125) );
  sky130_fd_sc_hd__mux2i_1 U184 ( .A0(n125), .A1(n188), .S(n131), .Y(
        s_mem_d[54]) );
  sky130_fd_sc_hd__inv_1 U185 ( .A(s_mem_q[53]), .Y(n126) );
  sky130_fd_sc_hd__mux2i_1 U186 ( .A0(n126), .A1(n190), .S(n131), .Y(
        s_mem_d[53]) );
  sky130_fd_sc_hd__inv_1 U187 ( .A(s_mem_q[52]), .Y(n127) );
  sky130_fd_sc_hd__mux2i_1 U188 ( .A0(n127), .A1(n192), .S(n56), .Y(
        s_mem_d[52]) );
  sky130_fd_sc_hd__inv_1 U189 ( .A(s_mem_q[51]), .Y(n128) );
  sky130_fd_sc_hd__mux2i_1 U190 ( .A0(n128), .A1(n194), .S(n131), .Y(
        s_mem_d[51]) );
  sky130_fd_sc_hd__inv_1 U191 ( .A(s_mem_q[50]), .Y(n129) );
  sky130_fd_sc_hd__mux2i_1 U192 ( .A0(n129), .A1(n196), .S(n131), .Y(
        s_mem_d[50]) );
  sky130_fd_sc_hd__inv_1 U193 ( .A(s_mem_q[49]), .Y(n130) );
  sky130_fd_sc_hd__mux2i_1 U194 ( .A0(n130), .A1(n198), .S(n56), .Y(
        s_mem_d[49]) );
  sky130_fd_sc_hd__inv_1 U195 ( .A(s_mem_q[48]), .Y(n132) );
  sky130_fd_sc_hd__mux2i_1 U196 ( .A0(n132), .A1(n201), .S(n56), .Y(
        s_mem_d[48]) );
  sky130_fd_sc_hd__inv_1 U197 ( .A(s_mem_q[47]), .Y(n134) );
  sky130_fd_sc_hd__inv_1 U198 ( .A(s_wr_ptr_q[1]), .Y(n173) );
  sky130_fd_sc_hd__nand2_1 U199 ( .A(n174), .B(n17), .Y(n133) );
  sky130_fd_sc_hd__mux2i_1 U200 ( .A0(n134), .A1(n186), .S(n66), .Y(
        s_mem_d[47]) );
  sky130_fd_sc_hd__inv_1 U201 ( .A(s_mem_q[46]), .Y(n135) );
  sky130_fd_sc_hd__mux2i_1 U202 ( .A0(n135), .A1(n188), .S(n141), .Y(
        s_mem_d[46]) );
  sky130_fd_sc_hd__inv_1 U203 ( .A(s_mem_q[45]), .Y(n136) );
  sky130_fd_sc_hd__mux2i_1 U204 ( .A0(n136), .A1(n190), .S(n141), .Y(
        s_mem_d[45]) );
  sky130_fd_sc_hd__inv_1 U205 ( .A(s_mem_q[44]), .Y(n137) );
  sky130_fd_sc_hd__mux2i_1 U206 ( .A0(n137), .A1(n192), .S(n141), .Y(
        s_mem_d[44]) );
  sky130_fd_sc_hd__inv_1 U207 ( .A(s_mem_q[43]), .Y(n138) );
  sky130_fd_sc_hd__mux2i_1 U208 ( .A0(n138), .A1(n194), .S(n66), .Y(
        s_mem_d[43]) );
  sky130_fd_sc_hd__inv_1 U209 ( .A(s_mem_q[42]), .Y(n139) );
  sky130_fd_sc_hd__mux2i_1 U210 ( .A0(n139), .A1(n196), .S(n141), .Y(
        s_mem_d[42]) );
  sky130_fd_sc_hd__inv_1 U211 ( .A(s_mem_q[41]), .Y(n140) );
  sky130_fd_sc_hd__mux2i_1 U212 ( .A0(n140), .A1(n198), .S(n66), .Y(
        s_mem_d[41]) );
  sky130_fd_sc_hd__inv_1 U213 ( .A(s_mem_q[40]), .Y(n142) );
  sky130_fd_sc_hd__mux2i_1 U214 ( .A0(n142), .A1(n201), .S(n66), .Y(
        s_mem_d[40]) );
  sky130_fd_sc_hd__inv_1 U215 ( .A(s_mem_q[39]), .Y(n144) );
  sky130_fd_sc_hd__mux2i_1 U216 ( .A0(n144), .A1(n186), .S(n62), .Y(
        s_mem_d[39]) );
  sky130_fd_sc_hd__inv_1 U217 ( .A(s_mem_q[38]), .Y(n145) );
  sky130_fd_sc_hd__mux2i_1 U218 ( .A0(n145), .A1(n188), .S(n151), .Y(
        s_mem_d[38]) );
  sky130_fd_sc_hd__inv_1 U219 ( .A(s_mem_q[37]), .Y(n146) );
  sky130_fd_sc_hd__mux2i_1 U220 ( .A0(n146), .A1(n190), .S(n6), .Y(s_mem_d[37]) );
  sky130_fd_sc_hd__inv_1 U221 ( .A(s_mem_q[36]), .Y(n147) );
  sky130_fd_sc_hd__mux2i_1 U222 ( .A0(n147), .A1(n192), .S(n151), .Y(
        s_mem_d[36]) );
  sky130_fd_sc_hd__inv_1 U223 ( .A(s_mem_q[35]), .Y(n148) );
  sky130_fd_sc_hd__mux2i_1 U224 ( .A0(n148), .A1(n194), .S(n151), .Y(
        s_mem_d[35]) );
  sky130_fd_sc_hd__inv_1 U225 ( .A(s_mem_q[34]), .Y(n149) );
  sky130_fd_sc_hd__mux2i_1 U226 ( .A0(n149), .A1(n196), .S(n5), .Y(s_mem_d[34]) );
  sky130_fd_sc_hd__inv_1 U227 ( .A(s_mem_q[33]), .Y(n150) );
  sky130_fd_sc_hd__mux2i_1 U228 ( .A0(n150), .A1(n198), .S(n62), .Y(
        s_mem_d[33]) );
  sky130_fd_sc_hd__inv_1 U229 ( .A(s_mem_q[32]), .Y(n152) );
  sky130_fd_sc_hd__mux2i_1 U230 ( .A0(n152), .A1(n201), .S(n62), .Y(
        s_mem_d[32]) );
  sky130_fd_sc_hd__inv_1 U231 ( .A(s_mem_q[31]), .Y(n154) );
  sky130_fd_sc_hd__inv_1 U232 ( .A(s_wr_ptr_q[2]), .Y(n206) );
  sky130_fd_sc_hd__nand2_1 U233 ( .A(n174), .B(n16), .Y(n153) );
  sky130_fd_sc_hd__mux2i_1 U234 ( .A0(n154), .A1(n186), .S(n67), .Y(
        s_mem_d[31]) );
  sky130_fd_sc_hd__inv_1 U235 ( .A(s_mem_q[30]), .Y(n155) );
  sky130_fd_sc_hd__mux2i_1 U236 ( .A0(n155), .A1(n188), .S(n161), .Y(
        s_mem_d[30]) );
  sky130_fd_sc_hd__inv_1 U237 ( .A(s_mem_q[29]), .Y(n156) );
  sky130_fd_sc_hd__mux2i_1 U238 ( .A0(n156), .A1(n190), .S(n161), .Y(
        s_mem_d[29]) );
  sky130_fd_sc_hd__inv_1 U239 ( .A(s_mem_q[28]), .Y(n157) );
  sky130_fd_sc_hd__mux2i_1 U240 ( .A0(n157), .A1(n192), .S(n161), .Y(
        s_mem_d[28]) );
  sky130_fd_sc_hd__inv_1 U241 ( .A(s_mem_q[27]), .Y(n158) );
  sky130_fd_sc_hd__mux2i_1 U242 ( .A0(n158), .A1(n194), .S(n161), .Y(
        s_mem_d[27]) );
  sky130_fd_sc_hd__inv_1 U243 ( .A(s_mem_q[26]), .Y(n159) );
  sky130_fd_sc_hd__mux2i_1 U244 ( .A0(n159), .A1(n196), .S(n67), .Y(
        s_mem_d[26]) );
  sky130_fd_sc_hd__inv_1 U245 ( .A(s_mem_q[25]), .Y(n160) );
  sky130_fd_sc_hd__mux2i_1 U246 ( .A0(n160), .A1(n198), .S(n67), .Y(
        s_mem_d[25]) );
  sky130_fd_sc_hd__inv_1 U247 ( .A(s_mem_q[24]), .Y(n162) );
  sky130_fd_sc_hd__mux2i_1 U248 ( .A0(n162), .A1(n201), .S(n67), .Y(
        s_mem_d[24]) );
  sky130_fd_sc_hd__inv_1 U249 ( .A(s_mem_q[23]), .Y(n164) );
  sky130_fd_sc_hd__mux2i_1 U250 ( .A0(n164), .A1(n186), .S(n63), .Y(
        s_mem_d[23]) );
  sky130_fd_sc_hd__inv_1 U251 ( .A(s_mem_q[22]), .Y(n165) );
  sky130_fd_sc_hd__mux2i_1 U252 ( .A0(n165), .A1(n188), .S(n171), .Y(
        s_mem_d[22]) );
  sky130_fd_sc_hd__inv_1 U253 ( .A(s_mem_q[21]), .Y(n166) );
  sky130_fd_sc_hd__mux2i_1 U254 ( .A0(n166), .A1(n190), .S(n171), .Y(
        s_mem_d[21]) );
  sky130_fd_sc_hd__inv_1 U255 ( .A(s_mem_q[20]), .Y(n167) );
  sky130_fd_sc_hd__mux2i_1 U256 ( .A0(n167), .A1(n192), .S(n171), .Y(
        s_mem_d[20]) );
  sky130_fd_sc_hd__inv_1 U257 ( .A(s_mem_q[19]), .Y(n168) );
  sky130_fd_sc_hd__mux2i_1 U258 ( .A0(n168), .A1(n194), .S(n171), .Y(
        s_mem_d[19]) );
  sky130_fd_sc_hd__inv_1 U259 ( .A(s_mem_q[18]), .Y(n169) );
  sky130_fd_sc_hd__mux2i_1 U260 ( .A0(n169), .A1(n196), .S(n63), .Y(
        s_mem_d[18]) );
  sky130_fd_sc_hd__inv_1 U261 ( .A(s_mem_q[17]), .Y(n170) );
  sky130_fd_sc_hd__mux2i_1 U262 ( .A0(n170), .A1(n198), .S(n63), .Y(
        s_mem_d[17]) );
  sky130_fd_sc_hd__inv_1 U263 ( .A(s_mem_q[16]), .Y(n172) );
  sky130_fd_sc_hd__mux2i_1 U264 ( .A0(n172), .A1(n201), .S(n63), .Y(
        s_mem_d[16]) );
  sky130_fd_sc_hd__inv_1 U265 ( .A(s_mem_q[15]), .Y(n176) );
  sky130_fd_sc_hd__mux2i_1 U266 ( .A0(n176), .A1(n186), .S(n13), .Y(
        s_mem_d[15]) );
  sky130_fd_sc_hd__inv_1 U267 ( .A(s_mem_q[14]), .Y(n177) );
  sky130_fd_sc_hd__mux2i_1 U268 ( .A0(n177), .A1(n188), .S(n13), .Y(
        s_mem_d[14]) );
  sky130_fd_sc_hd__inv_1 U269 ( .A(s_mem_q[13]), .Y(n178) );
  sky130_fd_sc_hd__mux2i_1 U270 ( .A0(n178), .A1(n190), .S(n13), .Y(
        s_mem_d[13]) );
  sky130_fd_sc_hd__inv_1 U271 ( .A(s_mem_q[12]), .Y(n179) );
  sky130_fd_sc_hd__mux2i_1 U272 ( .A0(n179), .A1(n192), .S(n1), .Y(s_mem_d[12]) );
  sky130_fd_sc_hd__inv_1 U273 ( .A(s_mem_q[11]), .Y(n180) );
  sky130_fd_sc_hd__mux2i_1 U274 ( .A0(n180), .A1(n194), .S(n13), .Y(
        s_mem_d[11]) );
  sky130_fd_sc_hd__inv_1 U275 ( .A(s_mem_q[10]), .Y(n181) );
  sky130_fd_sc_hd__mux2i_1 U276 ( .A0(n181), .A1(n196), .S(n60), .Y(
        s_mem_d[10]) );
  sky130_fd_sc_hd__inv_1 U277 ( .A(s_mem_q[9]), .Y(n182) );
  sky130_fd_sc_hd__mux2i_1 U278 ( .A0(n182), .A1(n198), .S(n1), .Y(s_mem_d[9])
         );
  sky130_fd_sc_hd__inv_1 U279 ( .A(s_mem_q[8]), .Y(n183) );
  sky130_fd_sc_hd__mux2i_1 U280 ( .A0(n183), .A1(n201), .S(n60), .Y(s_mem_d[8]) );
  sky130_fd_sc_hd__inv_1 U281 ( .A(s_mem_q[7]), .Y(n187) );
  sky130_fd_sc_hd__mux2i_1 U282 ( .A0(n187), .A1(n186), .S(n64), .Y(s_mem_d[7]) );
  sky130_fd_sc_hd__inv_1 U283 ( .A(s_mem_q[6]), .Y(n189) );
  sky130_fd_sc_hd__inv_1 U284 ( .A(s_mem_q[5]), .Y(n191) );
  sky130_fd_sc_hd__mux2i_1 U285 ( .A0(n191), .A1(n190), .S(n200), .Y(
        s_mem_d[5]) );
  sky130_fd_sc_hd__inv_1 U286 ( .A(s_mem_q[4]), .Y(n193) );
  sky130_fd_sc_hd__inv_1 U287 ( .A(s_mem_q[3]), .Y(n195) );
  sky130_fd_sc_hd__mux2i_1 U288 ( .A0(n195), .A1(n194), .S(n200), .Y(
        s_mem_d[3]) );
  sky130_fd_sc_hd__inv_1 U289 ( .A(s_mem_q[2]), .Y(n197) );
  sky130_fd_sc_hd__mux2i_1 U290 ( .A0(n197), .A1(n196), .S(n200), .Y(
        s_mem_d[2]) );
  sky130_fd_sc_hd__inv_1 U291 ( .A(s_mem_q[1]), .Y(n199) );
  sky130_fd_sc_hd__mux2i_1 U292 ( .A0(n199), .A1(n198), .S(n57), .Y(s_mem_d[1]) );
  sky130_fd_sc_hd__inv_1 U293 ( .A(s_mem_q[0]), .Y(n202) );
  sky130_fd_sc_hd__mux2i_1 U294 ( .A0(n202), .A1(n201), .S(n64), .Y(s_mem_d[0]) );
  sky130_fd_sc_hd__nor2_1 U295 ( .A(s_wr_ptr_q[2]), .B(n209), .Y(n203) );
  sky130_fd_sc_hd__mux2i_1 U296 ( .A0(s_wr_ptr_q[2]), .A1(n203), .S(
        s_wr_ptr_q[1]), .Y(n207) );
  sky130_fd_sc_hd__nand2_1 U297 ( .A(n204), .B(n210), .Y(n213) );
  sky130_fd_sc_hd__nand3_1 U298 ( .A(s_wr_ptr_q[2]), .B(n210), .C(n209), .Y(
        n205) );
  sky130_fd_sc_hd__o221ai_1 U299 ( .A1(n207), .A2(n214), .B1(n213), .B2(n206), 
        .C1(n205), .Y(s_wr_ptr_d[2]) );
  sky130_fd_sc_hd__nand2_1 U300 ( .A(s_wr_ptr_q[0]), .B(n208), .Y(n212) );
  sky130_fd_sc_hd__mux2i_1 U301 ( .A0(n212), .A1(n211), .S(s_wr_ptr_q[1]), .Y(
        s_wr_ptr_d[1]) );
  sky130_fd_sc_hd__mux2i_1 U302 ( .A0(n214), .A1(n213), .S(s_wr_ptr_q[0]), .Y(
        s_wr_ptr_d[0]) );
  sky130_fd_sc_hd__inv_1 U303 ( .A(N23), .Y(n216) );
  sky130_fd_sc_hd__inv_1 U304 ( .A(N24), .Y(n215) );
  sky130_fd_sc_hd__nor2_1 U305 ( .A(n216), .B(n215), .Y(n217) );
  sky130_fd_sc_hd__mux2i_1 U306 ( .A0(n215), .A1(n217), .S(n225), .Y(n219) );
  sky130_fd_sc_hd__o22ai_1 U307 ( .A1(n219), .A2(n220), .B1(n225), .B2(n14), 
        .Y(s_rd_ptr_d[2]) );
  sky130_fd_sc_hd__o32ai_1 U308 ( .A1(N24), .A2(n216), .A3(n220), .B1(n215), 
        .B2(n14), .Y(s_rd_ptr_d[1]) );
  sky130_fd_sc_hd__o32ai_1 U309 ( .A1(flush_i), .A2(n216), .A3(n221), .B1(N23), 
        .B2(n220), .Y(s_rd_ptr_d[0]) );
endmodule


module dffr_DATA_WIDTH1_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module apb4_ps2 ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr, ps2_ps2_clk_i, ps2_ps2_dat_i, ps2_irq_o );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite,
         ps2_ps2_clk_i, ps2_ps2_dat_i;
  output apb4_pready, apb4_pslverr, ps2_irq_o;
  wire   s_falledge, s_fifo_push_valid, s_fifo_empty, n_1_net_,
         \s_ps2_stat_d[0] , n16, n17, n19, n20, n21, n32, n33, n35, n36, n37,
         n38, n39, n41, n43, n44, n46, n47, n50, n56, n57, apb4_pslverr, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73,
         n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87,
         n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107;
  wire   [1:0] s_ps2_ctrl_q;
  wire   [1:0] s_ps2_ctrl_d;
  wire   [3:0] s_cnt_d;
  wire   [3:0] s_cnt_q;
  wire   [9:0] s_dat_d;
  wire   [9:0] s_dat_q;
  wire   [7:0] s_fifo_rd_dat;
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
  assign apb4_prdata[15] = apb4_pslverr;
  assign apb4_prdata[14] = apb4_pslverr;
  assign apb4_prdata[13] = apb4_pslverr;
  assign apb4_prdata[12] = apb4_pslverr;
  assign apb4_prdata[11] = apb4_pslverr;
  assign apb4_prdata[10] = apb4_pslverr;
  assign apb4_prdata[9] = apb4_pslverr;
  assign apb4_prdata[8] = apb4_pslverr;

  sky130_fd_sc_hd__a22o_1 U43 ( .A1(n19), .A2(s_ps2_ctrl_q[1]), .B1(
        apb4_pwdata[1]), .B2(n104), .X(s_ps2_ctrl_d[1]) );
  sky130_fd_sc_hd__a22o_1 U44 ( .A1(n19), .A2(s_ps2_ctrl_q[0]), .B1(
        apb4_pwdata[0]), .B2(n104), .X(s_ps2_ctrl_d[0]) );
  sky130_fd_sc_hd__nand4_1 U45 ( .A(n20), .B(apb4_psel), .C(apb4_pwrite), .D(
        n21), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(s_cnt_q[0]), .B(n33), .Y(n32) );
  sky130_fd_sc_hd__and3_1 U57 ( .A(s_falledge), .B(s_cnt_q[3]), .C(n35), .X(
        n33) );
  sky130_fd_sc_hd__or2_0 U58 ( .A(n37), .B(n38), .X(n36) );
  sky130_fd_sc_hd__nand2_1 U65 ( .A(n44), .B(n35), .Y(n50) );
  sky130_fd_sc_hd__nand2_1 U66 ( .A(s_falledge), .B(n103), .Y(n37) );
  sky130_fd_sc_hd__nand2_1 U68 ( .A(s_cnt_q[0]), .B(s_cnt_q[1]), .Y(n47) );
  sky130_fd_sc_hd__and2_0 U71 ( .A(s_fifo_rd_dat[7]), .B(n59), .X(
        apb4_prdata[7]) );
  sky130_fd_sc_hd__and2_0 U72 ( .A(s_fifo_rd_dat[6]), .B(n59), .X(
        apb4_prdata[6]) );
  sky130_fd_sc_hd__and2_0 U73 ( .A(s_fifo_rd_dat[5]), .B(n59), .X(
        apb4_prdata[5]) );
  sky130_fd_sc_hd__and2_0 U74 ( .A(s_fifo_rd_dat[4]), .B(n59), .X(
        apb4_prdata[4]) );
  sky130_fd_sc_hd__and2_0 U75 ( .A(s_fifo_rd_dat[3]), .B(n59), .X(
        apb4_prdata[3]) );
  sky130_fd_sc_hd__and2_0 U76 ( .A(s_fifo_rd_dat[2]), .B(n59), .X(
        apb4_prdata[2]) );
  sky130_fd_sc_hd__a32o_1 U77 ( .A1(n16), .A2(n105), .A3(s_ps2_ctrl_q[1]), 
        .B1(s_fifo_rd_dat[1]), .B2(n59), .X(apb4_prdata[1]) );
  sky130_fd_sc_hd__a22o_1 U78 ( .A1(s_fifo_rd_dat[0]), .A2(n59), .B1(n16), 
        .B2(n56), .X(apb4_prdata[0]) );
  sky130_fd_sc_hd__a22o_1 U79 ( .A1(n105), .A2(s_ps2_ctrl_q[0]), .B1(
        apb4_paddr[3]), .B2(ps2_irq_o), .X(n56) );
  sky130_fd_sc_hd__and3b_1 U80 ( .B(n57), .C(n20), .A_N(apb4_paddr[2]), .X(n16) );
  sky130_fd_sc_hd__and4_1 U82 ( .A(apb4_paddr[2]), .B(n20), .C(n57), .D(n105), 
        .X(n_1_net_) );
  dffr_DATA_WIDTH2 u_ps2_ctrl_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_ps2_ctrl_d), .dat_o(s_ps2_ctrl_q) );
  edge_det_fe_STAGE2_DATA_WIDTH1 u_ps2_clk_edge_det_fe ( .clk_i(apb4_pclk), 
        .rst_n_i(apb4_presetn), .dat_i(ps2_ps2_clk_i), .fe_o(s_falledge) );
  dffr_DATA_WIDTH4_0 u_cnt_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_cnt_d), .dat_o(s_cnt_q) );
  dffr_DATA_WIDTH10 u_dat_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_dat_d), .dat_o(s_dat_q) );
  fifo_DATA_WIDTH8_BUFFER_DEPTH8 u_ps2_fifo ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .flush_i(apb4_pslverr), .empty_o(s_fifo_empty), .dat_i(
        {n61, s_dat_q[7:1]}), .push_i(s_fifo_push_valid), .dat_o(s_fifo_rd_dat), .pop_i(n_1_net_) );
  dffr_DATA_WIDTH1_0 u_ps2_stat_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(\s_ps2_stat_d[0] ), .dat_o(ps2_irq_o) );
  sky130_fd_sc_hd__a2bb2o_1 U83 ( .A1_N(n107), .A2_N(n32), .B1(s_dat_q[9]), 
        .B2(n32), .X(s_dat_d[9]) );
  sky130_fd_sc_hd__nor2_2 U84 ( .A(n67), .B(n77), .Y(s_fifo_push_valid) );
  sky130_fd_sc_hd__clkinv_1 U85 ( .A(s_dat_q[0]), .Y(n68) );
  sky130_fd_sc_hd__nand2b_1 U86 ( .A_N(n90), .B(n91), .Y(n93) );
  sky130_fd_sc_hd__inv_2 U87 ( .A(n97), .Y(n91) );
  sky130_fd_sc_hd__buf_2 U88 ( .A(n62), .X(n60) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(n19), .Y(n104) );
  sky130_fd_sc_hd__o2bb2ai_1 U90 ( .B1(n107), .B2(n39), .A1_N(n39), .A2_N(
        s_dat_q[6]), .Y(s_dat_d[6]) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(n100), .Y(n101) );
  sky130_fd_sc_hd__o2bb2ai_1 U92 ( .B1(n107), .B2(n43), .A1_N(n43), .A2_N(
        s_dat_q[4]), .Y(s_dat_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U93 ( .B1(n107), .B2(n41), .A1_N(n41), .A2_N(
        s_dat_q[5]), .Y(s_dat_d[5]) );
  sky130_fd_sc_hd__inv_2 U94 ( .A(n98), .Y(n99) );
  sky130_fd_sc_hd__o2bb2ai_1 U95 ( .B1(n107), .B2(n36), .A1_N(n36), .A2_N(
        s_dat_q[7]), .Y(s_dat_d[7]) );
  sky130_fd_sc_hd__nand2b_1 U96 ( .A_N(n47), .B(s_cnt_q[2]), .Y(n38) );
  sky130_fd_sc_hd__o2bb2ai_1 U97 ( .B1(n107), .B2(n50), .A1_N(n50), .A2_N(
        s_dat_q[0]), .Y(s_dat_d[0]) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(s_cnt_q[3]), .Y(n103) );
  sky130_fd_sc_hd__a41oi_1 U99 ( .A1(s_ps2_ctrl_q[1]), .A2(ps2_irq_o), .A3(
        apb4_paddr[3]), .A4(n16), .B1(n17), .Y(\s_ps2_stat_d[0] ) );
  sky130_fd_sc_hd__nor3_1 U100 ( .A(n106), .B(apb4_paddr[3]), .C(apb4_paddr[2]), .Y(n21) );
  sky130_fd_sc_hd__nor3b_1 U101 ( .C_N(apb4_psel), .A(n106), .B(apb4_pwrite), 
        .Y(n57) );
  sky130_fd_sc_hd__nor2_1 U102 ( .A(apb4_paddr[5]), .B(apb4_paddr[4]), .Y(n20)
         );
  sky130_fd_sc_hd__and3_1 U103 ( .A(n_1_net_), .B(s_ps2_ctrl_q[1]), .C(n102), 
        .X(n59) );
  sky130_fd_sc_hd__inv_2 U104 ( .A(apb4_penable), .Y(n106) );
  sky130_fd_sc_hd__inv_2 U105 ( .A(apb4_paddr[3]), .Y(n105) );
  sky130_fd_sc_hd__conb_1 U106 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__o21ai_0 U107 ( .A1(s_cnt_q[2]), .A2(n100), .B1(s_dat_q[2]), 
        .Y(n84) );
  sky130_fd_sc_hd__o21ai_0 U108 ( .A1(s_cnt_q[2]), .A2(n98), .B1(s_dat_q[1]), 
        .Y(n83) );
  sky130_fd_sc_hd__o31ai_1 U109 ( .A1(n37), .A2(s_cnt_q[2]), .A3(n47), .B1(
        s_dat_q[3]), .Y(n46) );
  sky130_fd_sc_hd__clkinv_2 U110 ( .A(s_cnt_q[0]), .Y(n89) );
  sky130_fd_sc_hd__nand4_4 U111 ( .A(s_cnt_q[3]), .B(s_cnt_q[1]), .C(n89), .D(
        n82), .Y(n95) );
  sky130_fd_sc_hd__nor2_1 U112 ( .A(n37), .B(s_cnt_q[0]), .Y(n44) );
  sky130_fd_sc_hd__inv_1 U113 ( .A(n60), .Y(n61) );
  sky130_fd_sc_hd__clkinv_2 U114 ( .A(s_cnt_q[2]), .Y(n82) );
  sky130_fd_sc_hd__clkinv_1 U115 ( .A(n95), .Y(n69) );
  sky130_fd_sc_hd__nor2_1 U116 ( .A(s_cnt_q[2]), .B(s_cnt_q[1]), .Y(n35) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(s_dat_q[8]), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U118 ( .A(s_dat_q[8]), .B(s_dat_q[9]), .Y(n64) );
  sky130_fd_sc_hd__nand2_1 U119 ( .A(n62), .B(n63), .Y(n65) );
  sky130_fd_sc_hd__nand2_1 U120 ( .A(n65), .B(n64), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U121 ( .A(s_dat_q[9]), .Y(n63) );
  sky130_fd_sc_hd__nor2_1 U122 ( .A(n79), .B(n78), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U123 ( .A(n66), .Y(n67) );
  sky130_fd_sc_hd__nand3_1 U124 ( .A(ps2_ps2_dat_i), .B(s_falledge), .C(
        s_ps2_ctrl_q[1]), .Y(n78) );
  sky130_fd_sc_hd__nand2_1 U125 ( .A(n69), .B(n68), .Y(n79) );
  sky130_fd_sc_hd__xnor2_1 U126 ( .A(s_dat_q[4]), .B(s_dat_q[5]), .Y(n71) );
  sky130_fd_sc_hd__xor2_1 U127 ( .A(s_dat_q[3]), .B(s_dat_q[2]), .X(n70) );
  sky130_fd_sc_hd__xnor2_1 U128 ( .A(n71), .B(n70), .Y(n76) );
  sky130_fd_sc_hd__xnor2_1 U129 ( .A(s_dat_q[6]), .B(s_dat_q[7]), .Y(n74) );
  sky130_fd_sc_hd__xnor2_1 U130 ( .A(s_dat_q[1]), .B(n72), .Y(n73) );
  sky130_fd_sc_hd__xnor2_1 U131 ( .A(n73), .B(n74), .Y(n75) );
  sky130_fd_sc_hd__xnor2_1 U132 ( .A(n76), .B(n75), .Y(n77) );
  sky130_fd_sc_hd__inv_1 U133 ( .A(s_cnt_q[1]), .Y(n81) );
  sky130_fd_sc_hd__inv_1 U134 ( .A(n37), .Y(n80) );
  sky130_fd_sc_hd__nand3_1 U135 ( .A(s_cnt_q[0]), .B(n81), .C(n80), .Y(n98) );
  sky130_fd_sc_hd__nand2_1 U136 ( .A(ps2_ps2_dat_i), .B(n82), .Y(n85) );
  sky130_fd_sc_hd__o21ai_1 U137 ( .A1(n98), .A2(n85), .B1(n83), .Y(s_dat_d[1])
         );
  sky130_fd_sc_hd__nand2_1 U138 ( .A(n44), .B(s_cnt_q[1]), .Y(n100) );
  sky130_fd_sc_hd__o21ai_1 U139 ( .A1(n100), .A2(n85), .B1(n84), .Y(s_dat_d[2]) );
  sky130_fd_sc_hd__nand2_1 U140 ( .A(s_cnt_q[0]), .B(s_cnt_q[1]), .Y(n90) );
  sky130_fd_sc_hd__o31ai_1 U141 ( .A1(n90), .A2(n37), .A3(n85), .B1(n46), .Y(
        s_dat_d[3]) );
  sky130_fd_sc_hd__inv_1 U142 ( .A(ps2_ps2_dat_i), .Y(n107) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(n33), .Y(n86) );
  sky130_fd_sc_hd__nor2_1 U144 ( .A(s_cnt_q[0]), .B(n86), .Y(n87) );
  sky130_fd_sc_hd__mux2i_1 U145 ( .A0(n60), .A1(n107), .S(n87), .Y(s_dat_d[8])
         );
  sky130_fd_sc_hd__nand2_1 U146 ( .A(s_falledge), .B(n95), .Y(n97) );
  sky130_fd_sc_hd__mux2i_1 U147 ( .A0(n97), .A1(s_falledge), .S(s_cnt_q[0]), 
        .Y(s_cnt_d[0]) );
  sky130_fd_sc_hd__inv_1 U148 ( .A(s_falledge), .Y(n94) );
  sky130_fd_sc_hd__a21oi_1 U149 ( .A1(n95), .A2(n89), .B1(n94), .Y(n88) );
  sky130_fd_sc_hd__o32ai_1 U150 ( .A1(s_cnt_q[1]), .A2(n89), .A3(n97), .B1(n81), .B2(n88), .Y(s_cnt_d[1]) );
  sky130_fd_sc_hd__nor2_1 U151 ( .A(n47), .B(n94), .Y(n92) );
  sky130_fd_sc_hd__mux2i_1 U152 ( .A0(n93), .A1(n92), .S(s_cnt_q[2]), .Y(
        s_cnt_d[2]) );
  sky130_fd_sc_hd__a21oi_1 U153 ( .A1(n38), .A2(n95), .B1(n94), .Y(n96) );
  sky130_fd_sc_hd__o32ai_1 U154 ( .A1(n38), .A2(s_cnt_q[3]), .A3(n97), .B1(
        n103), .B2(n96), .Y(s_cnt_d[3]) );
  sky130_fd_sc_hd__inv_1 U155 ( .A(s_fifo_empty), .Y(n102) );
  sky130_fd_sc_hd__nand3_1 U156 ( .A(n81), .B(n44), .C(s_cnt_q[2]), .Y(n43) );
  sky130_fd_sc_hd__nand2_1 U157 ( .A(s_cnt_q[2]), .B(n99), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U158 ( .A(s_cnt_q[2]), .B(n101), .Y(n39) );
  sky130_fd_sc_hd__a31oi_1 U159 ( .A1(s_ps2_ctrl_q[0]), .A2(s_ps2_ctrl_q[1]), 
        .A3(n102), .B1(ps2_irq_o), .Y(n17) );
endmodule

