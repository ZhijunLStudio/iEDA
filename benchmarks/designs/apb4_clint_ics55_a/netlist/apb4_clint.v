/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 13:14:01 2025
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


module edge_det_STAGE2_DATA_WIDTH1 ( clk_i, rst_n_i, dat_i, dat_o, re_o, fe_o
 );
  input [0:0] dat_i;
  output [0:0] dat_o;
  output [0:0] re_o;
  output [0:0] fe_o;
  input clk_i, rst_n_i;
  wire   \s_dat_d[0] ;

  sky130_fd_sc_hd__nor2b_1 U2 ( .B_N(dat_o[0]), .A(\s_dat_d[0] ), .Y(fe_o[0])
         );
  cdc_sync_STAGE2_DATA_WIDTH1 u_cdc_sync ( .clk_i(clk_i), .rst_n_i(rst_n_i), 
        .dat_i(dat_i[0]), .dat_o(\s_dat_d[0] ) );
  dffr_DATA_WIDTH1_3 u_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        \s_dat_d[0] ), .dat_o(dat_o[0]) );
  sky130_fd_sc_hd__nor2b_2 U1 ( .B_N(\s_dat_d[0] ), .A(dat_o[0]), .Y(re_o[0])
         );
endmodule


module dffr_DATA_WIDTH1_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [0:0] dat_i;
  output [0:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH64 ( clk_i, rst_n_i, dat_i, dat_o );
  input [63:0] dat_i;
  output [63:0] dat_o;
  input clk_i, rst_n_i;
  wire   n4, n5, n6, n7, n8;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[52]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[51]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_4 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfrtp_4 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[58]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(rst_n_i), .X(n7) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(rst_n_i), .X(n5) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(rst_n_i), .X(n8) );
endmodule


module dffrh_DATA_WIDTH64 ( clk_i, rst_n_i, dat_i, dat_o );
  input [63:0] dat_i;
  output [63:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3, n4, n5;

  sky130_fd_sc_hd__dfstp_2 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[58]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[52]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), .SET_B(
        n1), .Q(dat_o[51]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), .SET_B(
        n2), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), .SET_B(
        n3), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), .SET_B(
        n4), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), .SET_B(
        n5), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), .SET_B(
        n5), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .SET_B(n5), .Q(dat_o[0]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(rst_n_i), .X(n3) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(rst_n_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(rst_n_i), .X(n1) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(rst_n_i), .X(n5) );
endmodule


module apb4_clint_DW_cmp_0 ( A, B, TC, GE_LT, GE_GT_EQ, GE_LT_GT_LE, EQ_NE );
  input [63:0] A;
  input [63:0] B;
  input TC, GE_LT, GE_GT_EQ;
  output GE_LT_GT_LE, EQ_NE;
  wire   n450, n451, n452, n453, n454, n455, n456, n457, n458, n459, n460,
         n461, n462, n463, n464, n465, n466, n467, n468, n469, n470, n471,
         n472, n473, n474, n475, n476, n477, n478, n479, n480, n481, n482,
         n483, n484, n485, n486, n487, n488, n489, n490, n491, n492, n493,
         n494, n495, n496, n497, n498, n499, n500, n501, n502, n503, n504,
         n505, n506, n507, n508, n509, n510, n511, n512, n513, n514, n515,
         n516, n517, n518, n519, n520, n521, n522, n523, n524, n525, n526,
         n527, n528, n529, n530, n531, n532, n533, n534, n535, n536, n537,
         n538, n539, n540, n541, n542, n543, n544, n545, n546, n547, n548,
         n549, n550, n551, n552, n553, n554, n555, n556, n557, n558, n559,
         n560, n561, n562, n563, n564, n565, n566, n567, n568, n569, n570,
         n571, n572, n573, n574, n575, n576, n577, n578, n579, n580, n581,
         n582, n583, n584, n585, n586, n587, n588, n589, n590, n591, n592,
         n593, n594, n595, n596, n597, n598, n599, n600, n601, n602, n603,
         n604, n605, n606, n607, n608, n609, n610, n611, n612, n613, n614,
         n615, n616, n617, n618, n619, n620, n621, n622, n623, n624, n625,
         n626, n627, n628, n629, n630, n631, n632, n633, n634, n635, n636,
         n637, n638, n639, n640, n641, n642, n643, n644, n645, n646, n647,
         n648, n649, n650, n651;

  sky130_fd_sc_hd__nor2b_1 U316 ( .B_N(A[31]), .A(B[31]), .Y(n583) );
  sky130_fd_sc_hd__nor2b_1 U317 ( .B_N(A[11]), .A(B[11]), .Y(n559) );
  sky130_fd_sc_hd__nor2b_1 U318 ( .B_N(A[27]), .A(B[27]), .Y(n586) );
  sky130_fd_sc_hd__nor2b_2 U319 ( .B_N(A[21]), .A(B[21]), .Y(n590) );
  sky130_fd_sc_hd__inv_1 U320 ( .A(A[9]), .Y(n524) );
  sky130_fd_sc_hd__inv_1 U321 ( .A(A[40]), .Y(n515) );
  sky130_fd_sc_hd__inv_2 U322 ( .A(n536), .Y(n480) );
  sky130_fd_sc_hd__inv_2 U323 ( .A(n633), .Y(n481) );
  sky130_fd_sc_hd__inv_2 U324 ( .A(n579), .Y(n488) );
  sky130_fd_sc_hd__inv_2 U325 ( .A(n587), .Y(n495) );
  sky130_fd_sc_hd__inv_2 U326 ( .A(n534), .Y(n472) );
  sky130_fd_sc_hd__inv_2 U327 ( .A(n612), .Y(n461) );
  sky130_fd_sc_hd__inv_2 U328 ( .A(n629), .Y(n471) );
  sky130_fd_sc_hd__inv_2 U329 ( .A(n621), .Y(n456) );
  sky130_fd_sc_hd__inv_2 U330 ( .A(n643), .Y(n473) );
  sky130_fd_sc_hd__inv_2 U331 ( .A(n602), .Y(n462) );
  sky130_fd_sc_hd__inv_2 U332 ( .A(B[11]), .Y(n505) );
  sky130_fd_sc_hd__inv_2 U333 ( .A(B[27]), .Y(n492) );
  sky130_fd_sc_hd__inv_2 U334 ( .A(B[15]), .Y(n500) );
  sky130_fd_sc_hd__inv_2 U335 ( .A(B[7]), .Y(n507) );
  sky130_fd_sc_hd__inv_2 U336 ( .A(B[31]), .Y(n487) );
  sky130_fd_sc_hd__inv_2 U337 ( .A(n552), .Y(n501) );
  sky130_fd_sc_hd__inv_2 U338 ( .A(B[13]), .Y(n503) );
  sky130_fd_sc_hd__inv_2 U339 ( .A(B[29]), .Y(n490) );
  sky130_fd_sc_hd__inv_2 U340 ( .A(n539), .Y(n499) );
  sky130_fd_sc_hd__inv_2 U341 ( .A(B[21]), .Y(n497) );
  sky130_fd_sc_hd__inv_2 U342 ( .A(B[43]), .Y(n477) );
  sky130_fd_sc_hd__inv_2 U343 ( .A(B[35]), .Y(n485) );
  sky130_fd_sc_hd__inv_2 U344 ( .A(B[57]), .Y(n458) );
  sky130_fd_sc_hd__inv_2 U345 ( .A(B[51]), .Y(n466) );
  sky130_fd_sc_hd__inv_2 U346 ( .A(B[45]), .Y(n475) );
  sky130_fd_sc_hd__inv_2 U347 ( .A(B[37]), .Y(n483) );
  sky130_fd_sc_hd__inv_2 U348 ( .A(B[53]), .Y(n464) );
  sky130_fd_sc_hd__inv_2 U349 ( .A(B[61]), .Y(n453) );
  sky130_fd_sc_hd__inv_2 U350 ( .A(B[1]), .Y(n513) );
  sky130_fd_sc_hd__inv_2 U351 ( .A(n616), .Y(n451) );
  sky130_fd_sc_hd__inv_1 U352 ( .A(A[41]), .Y(n514) );
  sky130_fd_sc_hd__inv_2 U353 ( .A(B[12]), .Y(n504) );
  sky130_fd_sc_hd__inv_2 U354 ( .A(B[44]), .Y(n476) );
  sky130_fd_sc_hd__inv_2 U355 ( .A(B[36]), .Y(n484) );
  sky130_fd_sc_hd__inv_2 U356 ( .A(B[52]), .Y(n465) );
  sky130_fd_sc_hd__inv_2 U357 ( .A(B[28]), .Y(n491) );
  sky130_fd_sc_hd__inv_2 U358 ( .A(B[20]), .Y(n498) );
  sky130_fd_sc_hd__inv_2 U359 ( .A(B[60]), .Y(n454) );
  sky130_fd_sc_hd__inv_1 U360 ( .A(A[33]), .Y(n516) );
  sky130_fd_sc_hd__inv_2 U361 ( .A(B[14]), .Y(n502) );
  sky130_fd_sc_hd__inv_2 U362 ( .A(B[10]), .Y(n506) );
  sky130_fd_sc_hd__inv_2 U363 ( .A(B[6]), .Y(n508) );
  sky130_fd_sc_hd__inv_2 U364 ( .A(B[42]), .Y(n478) );
  sky130_fd_sc_hd__inv_2 U365 ( .A(B[46]), .Y(n474) );
  sky130_fd_sc_hd__inv_2 U366 ( .A(B[34]), .Y(n486) );
  sky130_fd_sc_hd__inv_2 U367 ( .A(B[38]), .Y(n482) );
  sky130_fd_sc_hd__inv_2 U368 ( .A(B[58]), .Y(n457) );
  sky130_fd_sc_hd__inv_2 U369 ( .A(B[62]), .Y(n452) );
  sky130_fd_sc_hd__inv_2 U370 ( .A(B[50]), .Y(n467) );
  sky130_fd_sc_hd__inv_2 U371 ( .A(B[54]), .Y(n463) );
  sky130_fd_sc_hd__inv_2 U372 ( .A(B[30]), .Y(n489) );
  sky130_fd_sc_hd__inv_2 U373 ( .A(B[26]), .Y(n493) );
  sky130_fd_sc_hd__inv_2 U374 ( .A(B[22]), .Y(n496) );
  sky130_fd_sc_hd__inv_2 U375 ( .A(B[2]), .Y(n512) );
  sky130_fd_sc_hd__inv_2 U376 ( .A(B[4]), .Y(n510) );
  sky130_fd_sc_hd__inv_2 U377 ( .A(B[48]), .Y(n469) );
  sky130_fd_sc_hd__inv_2 U378 ( .A(B[56]), .Y(n459) );
  sky130_fd_sc_hd__inv_2 U379 ( .A(B[49]), .Y(n468) );
  sky130_fd_sc_hd__inv_2 U380 ( .A(B[3]), .Y(n511) );
  sky130_fd_sc_hd__inv_2 U381 ( .A(B[5]), .Y(n509) );
  sky130_fd_sc_hd__inv_2 U382 ( .A(B[47]), .Y(n470) );
  sky130_fd_sc_hd__inv_2 U383 ( .A(B[39]), .Y(n479) );
  sky130_fd_sc_hd__inv_2 U384 ( .A(B[59]), .Y(n455) );
  sky130_fd_sc_hd__inv_2 U385 ( .A(B[63]), .Y(n450) );
  sky130_fd_sc_hd__inv_2 U386 ( .A(B[55]), .Y(n460) );
  sky130_fd_sc_hd__inv_2 U387 ( .A(B[23]), .Y(n494) );
  sky130_fd_sc_hd__inv_1 U388 ( .A(A[24]), .Y(n519) );
  sky130_fd_sc_hd__inv_1 U389 ( .A(A[1]), .Y(n526) );
  sky130_fd_sc_hd__inv_1 U390 ( .A(A[32]), .Y(n517) );
  sky130_fd_sc_hd__inv_1 U391 ( .A(A[18]), .Y(n521) );
  sky130_fd_sc_hd__and2_1 U392 ( .A(A[5]), .B(n509), .X(n563) );
  sky130_fd_sc_hd__inv_1 U393 ( .A(A[17]), .Y(n522) );
  sky130_fd_sc_hd__and2_1 U394 ( .A(A[3]), .B(n511), .X(n570) );
  sky130_fd_sc_hd__inv_1 U395 ( .A(A[16]), .Y(n523) );
  sky130_fd_sc_hd__inv_1 U396 ( .A(A[19]), .Y(n520) );
  sky130_fd_sc_hd__inv_2 U397 ( .A(A[25]), .Y(n518) );
  sky130_fd_sc_hd__inv_1 U398 ( .A(A[8]), .Y(n525) );
  sky130_fd_sc_hd__o32ai_1 U399 ( .A1(n527), .A2(n528), .A3(n529), .B1(n530), 
        .B2(n527), .Y(GE_LT_GT_LE) );
  sky130_fd_sc_hd__nor4b_1 U400 ( .D_N(n531), .A(n532), .B(n533), .C(n534), 
        .Y(n530) );
  sky130_fd_sc_hd__o211ai_1 U401 ( .A1(B[32]), .A2(n517), .B1(n535), .C1(n536), 
        .Y(n532) );
  sky130_fd_sc_hd__nor4b_1 U402 ( .D_N(n537), .A(n538), .B(n539), .C(n540), 
        .Y(n529) );
  sky130_fd_sc_hd__o211ai_1 U403 ( .A1(B[16]), .A2(n523), .B1(n541), .C1(n542), 
        .Y(n538) );
  sky130_fd_sc_hd__a32oi_1 U404 ( .A1(n543), .A2(n544), .A3(n545), .B1(n545), 
        .B2(n546), .Y(n542) );
  sky130_fd_sc_hd__o2111ai_1 U405 ( .A1(B[8]), .A2(n525), .B1(n547), .C1(n548), 
        .D1(n549), .Y(n546) );
  sky130_fd_sc_hd__a21boi_0 U406 ( .A1(n548), .A2(n550), .B1_N(n551), .Y(n545)
         );
  sky130_fd_sc_hd__o22ai_1 U407 ( .A1(n552), .A2(n553), .B1(n553), .B2(n554), 
        .Y(n551) );
  sky130_fd_sc_hd__o32ai_1 U408 ( .A1(n504), .A2(A[12]), .A3(n555), .B1(A[13]), 
        .B2(n503), .Y(n554) );
  sky130_fd_sc_hd__o32ai_1 U409 ( .A1(n502), .A2(A[14]), .A3(n556), .B1(A[15]), 
        .B2(n500), .Y(n553) );
  sky130_fd_sc_hd__o22a_1 U410 ( .A1(n547), .A2(n557), .B1(n557), .B2(n558), 
        .X(n550) );
  sky130_fd_sc_hd__a32o_1 U411 ( .A1(B[8]), .A2(n525), .A3(n549), .B1(n524), 
        .B2(B[9]), .X(n558) );
  sky130_fd_sc_hd__or2_0 U412 ( .A(B[9]), .B(n524), .X(n549) );
  sky130_fd_sc_hd__o32ai_1 U413 ( .A1(n506), .A2(A[10]), .A3(n559), .B1(A[11]), 
        .B2(n505), .Y(n557) );
  sky130_fd_sc_hd__a21oi_1 U414 ( .A1(n506), .A2(A[10]), .B1(n559), .Y(n547)
         );
  sky130_fd_sc_hd__a211oi_1 U415 ( .A1(n504), .A2(A[12]), .B1(n555), .C1(n501), 
        .Y(n548) );
  sky130_fd_sc_hd__a21oi_1 U416 ( .A1(n502), .A2(A[14]), .B1(n556), .Y(n552)
         );
  sky130_fd_sc_hd__nor2b_1 U417 ( .B_N(A[15]), .A(B[15]), .Y(n556) );
  sky130_fd_sc_hd__nor2b_1 U418 ( .B_N(A[13]), .A(B[13]), .Y(n555) );
  sky130_fd_sc_hd__o22ai_1 U419 ( .A1(n560), .A2(n561), .B1(n561), .B2(n562), 
        .Y(n544) );
  sky130_fd_sc_hd__o32ai_1 U420 ( .A1(n510), .A2(A[4]), .A3(n563), .B1(A[5]), 
        .B2(n509), .Y(n562) );
  sky130_fd_sc_hd__o32ai_1 U421 ( .A1(n508), .A2(A[6]), .A3(n564), .B1(A[7]), 
        .B2(n507), .Y(n561) );
  sky130_fd_sc_hd__o2111ai_1 U422 ( .A1(n565), .A2(n566), .B1(n567), .C1(n568), 
        .D1(n560), .Y(n543) );
  sky130_fd_sc_hd__a21oi_1 U423 ( .A1(n508), .A2(A[6]), .B1(n564), .Y(n560) );
  sky130_fd_sc_hd__nor2b_1 U424 ( .B_N(A[7]), .A(B[7]), .Y(n564) );
  sky130_fd_sc_hd__a221o_1 U425 ( .A1(B[1]), .A2(n526), .B1(n569), .B2(B[0]), 
        .C1(n566), .X(n568) );
  sky130_fd_sc_hd__a21oi_1 U426 ( .A1(A[1]), .A2(n513), .B1(A[0]), .Y(n569) );
  sky130_fd_sc_hd__a21oi_1 U427 ( .A1(A[4]), .A2(n510), .B1(n563), .Y(n567) );
  sky130_fd_sc_hd__o32ai_1 U428 ( .A1(n512), .A2(A[2]), .A3(n570), .B1(A[3]), 
        .B2(n511), .Y(n566) );
  sky130_fd_sc_hd__a21oi_1 U429 ( .A1(A[2]), .A2(n512), .B1(n570), .Y(n565) );
  sky130_fd_sc_hd__a32oi_1 U430 ( .A1(n571), .A2(n572), .A3(n573), .B1(n573), 
        .B2(n540), .Y(n528) );
  sky130_fd_sc_hd__o2111ai_1 U431 ( .A1(B[24]), .A2(n519), .B1(n574), .C1(n575), .D1(n576), .Y(n540) );
  sky130_fd_sc_hd__a21boi_0 U432 ( .A1(n575), .A2(n577), .B1_N(n578), .Y(n573)
         );
  sky130_fd_sc_hd__o22ai_1 U433 ( .A1(n579), .A2(n580), .B1(n580), .B2(n581), 
        .Y(n578) );
  sky130_fd_sc_hd__o32ai_1 U434 ( .A1(n491), .A2(A[28]), .A3(n582), .B1(A[29]), 
        .B2(n490), .Y(n581) );
  sky130_fd_sc_hd__o32ai_1 U435 ( .A1(n489), .A2(A[30]), .A3(n583), .B1(A[31]), 
        .B2(n487), .Y(n580) );
  sky130_fd_sc_hd__o22a_1 U436 ( .A1(n574), .A2(n584), .B1(n584), .B2(n585), 
        .X(n577) );
  sky130_fd_sc_hd__a32o_1 U437 ( .A1(B[24]), .A2(n519), .A3(n576), .B1(n518), 
        .B2(B[25]), .X(n585) );
  sky130_fd_sc_hd__or2_0 U438 ( .A(B[25]), .B(n518), .X(n576) );
  sky130_fd_sc_hd__o32ai_1 U439 ( .A1(n493), .A2(A[26]), .A3(n586), .B1(A[27]), 
        .B2(n492), .Y(n584) );
  sky130_fd_sc_hd__a21oi_1 U440 ( .A1(n493), .A2(A[26]), .B1(n586), .Y(n574)
         );
  sky130_fd_sc_hd__a211oi_1 U441 ( .A1(n491), .A2(A[28]), .B1(n582), .C1(n488), 
        .Y(n575) );
  sky130_fd_sc_hd__a21oi_1 U442 ( .A1(n489), .A2(A[30]), .B1(n583), .Y(n579)
         );
  sky130_fd_sc_hd__nor2b_1 U443 ( .B_N(A[29]), .A(B[29]), .Y(n582) );
  sky130_fd_sc_hd__o22ai_1 U444 ( .A1(n587), .A2(n588), .B1(n588), .B2(n589), 
        .Y(n572) );
  sky130_fd_sc_hd__o32ai_1 U445 ( .A1(n498), .A2(A[20]), .A3(n590), .B1(A[21]), 
        .B2(n497), .Y(n589) );
  sky130_fd_sc_hd__o32ai_1 U446 ( .A1(n496), .A2(A[22]), .A3(n591), .B1(A[23]), 
        .B2(n494), .Y(n588) );
  sky130_fd_sc_hd__o221ai_1 U447 ( .A1(n592), .A2(n593), .B1(n499), .B2(n592), 
        .C1(n537), .Y(n571) );
  sky130_fd_sc_hd__a211oi_1 U448 ( .A1(n498), .A2(A[20]), .B1(n590), .C1(n495), 
        .Y(n537) );
  sky130_fd_sc_hd__a21oi_1 U449 ( .A1(n496), .A2(A[22]), .B1(n591), .Y(n587)
         );
  sky130_fd_sc_hd__nor2b_1 U450 ( .B_N(A[23]), .A(B[23]), .Y(n591) );
  sky130_fd_sc_hd__o21ai_0 U451 ( .A1(B[18]), .A2(n521), .B1(n594), .Y(n539)
         );
  sky130_fd_sc_hd__a32o_1 U452 ( .A1(B[16]), .A2(n523), .A3(n541), .B1(n522), 
        .B2(B[17]), .X(n593) );
  sky130_fd_sc_hd__or2_0 U453 ( .A(B[17]), .B(n522), .X(n541) );
  sky130_fd_sc_hd__a32o_1 U454 ( .A1(B[18]), .A2(n521), .A3(n594), .B1(n520), 
        .B2(B[19]), .X(n592) );
  sky130_fd_sc_hd__or2_0 U455 ( .A(B[19]), .B(n520), .X(n594) );
  sky130_fd_sc_hd__o21ai_0 U456 ( .A1(n533), .A2(n595), .B1(n596), .Y(n527) );
  sky130_fd_sc_hd__o22ai_1 U457 ( .A1(n597), .A2(n598), .B1(n599), .B2(n597), 
        .Y(n596) );
  sky130_fd_sc_hd__o21ai_0 U458 ( .A1(n461), .A2(n600), .B1(n601), .Y(n598) );
  sky130_fd_sc_hd__o22ai_1 U459 ( .A1(n602), .A2(n603), .B1(n603), .B2(n604), 
        .Y(n601) );
  sky130_fd_sc_hd__o32ai_1 U460 ( .A1(n465), .A2(A[52]), .A3(n605), .B1(A[53]), 
        .B2(n464), .Y(n604) );
  sky130_fd_sc_hd__o32ai_1 U461 ( .A1(n463), .A2(A[54]), .A3(n606), .B1(A[55]), 
        .B2(n460), .Y(n603) );
  sky130_fd_sc_hd__o22ai_1 U462 ( .A1(n607), .A2(n608), .B1(n608), .B2(n609), 
        .Y(n600) );
  sky130_fd_sc_hd__o32ai_1 U463 ( .A1(n469), .A2(A[48]), .A3(n610), .B1(A[49]), 
        .B2(n468), .Y(n609) );
  sky130_fd_sc_hd__o32ai_1 U464 ( .A1(n467), .A2(A[50]), .A3(n611), .B1(A[51]), 
        .B2(n466), .Y(n608) );
  sky130_fd_sc_hd__o21ai_0 U465 ( .A1(n613), .A2(n614), .B1(n615), .Y(n597) );
  sky130_fd_sc_hd__o22ai_1 U466 ( .A1(n616), .A2(n617), .B1(n617), .B2(n618), 
        .Y(n615) );
  sky130_fd_sc_hd__o32ai_1 U467 ( .A1(n454), .A2(A[60]), .A3(n619), .B1(A[61]), 
        .B2(n453), .Y(n618) );
  sky130_fd_sc_hd__o32ai_1 U468 ( .A1(n452), .A2(A[62]), .A3(n620), .B1(A[63]), 
        .B2(n450), .Y(n617) );
  sky130_fd_sc_hd__o22ai_1 U469 ( .A1(n621), .A2(n622), .B1(n622), .B2(n623), 
        .Y(n614) );
  sky130_fd_sc_hd__o32ai_1 U470 ( .A1(n459), .A2(A[56]), .A3(n624), .B1(A[57]), 
        .B2(n458), .Y(n623) );
  sky130_fd_sc_hd__o32ai_1 U471 ( .A1(n457), .A2(A[58]), .A3(n625), .B1(A[59]), 
        .B2(n455), .Y(n622) );
  sky130_fd_sc_hd__o22ai_1 U472 ( .A1(n626), .A2(n627), .B1(n472), .B2(n626), 
        .Y(n595) );
  sky130_fd_sc_hd__o2111ai_1 U473 ( .A1(B[40]), .A2(n515), .B1(n628), .C1(n629), .D1(n630), .Y(n534) );
  sky130_fd_sc_hd__o21ai_0 U474 ( .A1(n480), .A2(n631), .B1(n632), .Y(n627) );
  sky130_fd_sc_hd__o22ai_1 U475 ( .A1(n633), .A2(n634), .B1(n634), .B2(n635), 
        .Y(n632) );
  sky130_fd_sc_hd__o32ai_1 U476 ( .A1(n484), .A2(A[36]), .A3(n636), .B1(A[37]), 
        .B2(n483), .Y(n635) );
  sky130_fd_sc_hd__o32ai_1 U477 ( .A1(n482), .A2(A[38]), .A3(n637), .B1(A[39]), 
        .B2(n479), .Y(n634) );
  sky130_fd_sc_hd__o22ai_1 U478 ( .A1(n531), .A2(n638), .B1(n638), .B2(n639), 
        .Y(n631) );
  sky130_fd_sc_hd__a32o_1 U479 ( .A1(B[32]), .A2(n517), .A3(n535), .B1(n516), 
        .B2(B[33]), .X(n639) );
  sky130_fd_sc_hd__or2_0 U480 ( .A(B[33]), .B(n516), .X(n535) );
  sky130_fd_sc_hd__o32ai_1 U481 ( .A1(n486), .A2(A[34]), .A3(n640), .B1(A[35]), 
        .B2(n485), .Y(n638) );
  sky130_fd_sc_hd__a21oi_1 U482 ( .A1(n486), .A2(A[34]), .B1(n640), .Y(n531)
         );
  sky130_fd_sc_hd__nor2b_1 U483 ( .B_N(A[35]), .A(B[35]), .Y(n640) );
  sky130_fd_sc_hd__a211oi_1 U484 ( .A1(n484), .A2(A[36]), .B1(n636), .C1(n481), 
        .Y(n536) );
  sky130_fd_sc_hd__a21oi_1 U485 ( .A1(n482), .A2(A[38]), .B1(n637), .Y(n633)
         );
  sky130_fd_sc_hd__nor2b_1 U486 ( .B_N(A[39]), .A(B[39]), .Y(n637) );
  sky130_fd_sc_hd__nor2b_1 U487 ( .B_N(A[37]), .A(B[37]), .Y(n636) );
  sky130_fd_sc_hd__o21ai_0 U488 ( .A1(n471), .A2(n641), .B1(n642), .Y(n626) );
  sky130_fd_sc_hd__o22ai_1 U489 ( .A1(n643), .A2(n644), .B1(n644), .B2(n645), 
        .Y(n642) );
  sky130_fd_sc_hd__o32ai_1 U490 ( .A1(n476), .A2(A[44]), .A3(n646), .B1(A[45]), 
        .B2(n475), .Y(n645) );
  sky130_fd_sc_hd__o32ai_1 U491 ( .A1(n474), .A2(A[46]), .A3(n647), .B1(A[47]), 
        .B2(n470), .Y(n644) );
  sky130_fd_sc_hd__o22ai_1 U492 ( .A1(n628), .A2(n648), .B1(n648), .B2(n649), 
        .Y(n641) );
  sky130_fd_sc_hd__a32o_1 U493 ( .A1(B[40]), .A2(n515), .A3(n630), .B1(n514), 
        .B2(B[41]), .X(n649) );
  sky130_fd_sc_hd__or2_0 U494 ( .A(B[41]), .B(n514), .X(n630) );
  sky130_fd_sc_hd__o32ai_1 U495 ( .A1(n478), .A2(A[42]), .A3(n650), .B1(A[43]), 
        .B2(n477), .Y(n648) );
  sky130_fd_sc_hd__a21oi_1 U496 ( .A1(n478), .A2(A[42]), .B1(n650), .Y(n628)
         );
  sky130_fd_sc_hd__nor2b_1 U497 ( .B_N(A[43]), .A(B[43]), .Y(n650) );
  sky130_fd_sc_hd__a211oi_1 U498 ( .A1(n476), .A2(A[44]), .B1(n646), .C1(n473), 
        .Y(n629) );
  sky130_fd_sc_hd__a21oi_1 U499 ( .A1(n474), .A2(A[46]), .B1(n647), .Y(n643)
         );
  sky130_fd_sc_hd__nor2b_1 U500 ( .B_N(A[47]), .A(B[47]), .Y(n647) );
  sky130_fd_sc_hd__nor2b_1 U501 ( .B_N(A[45]), .A(B[45]), .Y(n646) );
  sky130_fd_sc_hd__nand4_1 U502 ( .A(n607), .B(n599), .C(n651), .D(n612), .Y(
        n533) );
  sky130_fd_sc_hd__a211oi_1 U503 ( .A1(n465), .A2(A[52]), .B1(n605), .C1(n462), 
        .Y(n612) );
  sky130_fd_sc_hd__a21oi_1 U504 ( .A1(n463), .A2(A[54]), .B1(n606), .Y(n602)
         );
  sky130_fd_sc_hd__nor2b_1 U505 ( .B_N(A[55]), .A(B[55]), .Y(n606) );
  sky130_fd_sc_hd__nor2b_1 U506 ( .B_N(A[53]), .A(B[53]), .Y(n605) );
  sky130_fd_sc_hd__a21oi_1 U507 ( .A1(A[48]), .A2(n469), .B1(n610), .Y(n651)
         );
  sky130_fd_sc_hd__and2_0 U508 ( .A(A[49]), .B(n468), .X(n610) );
  sky130_fd_sc_hd__a2111oi_0 U509 ( .A1(n459), .A2(A[56]), .B1(n456), .C1(n613), .D1(n624), .Y(n599) );
  sky130_fd_sc_hd__nor2b_1 U510 ( .B_N(A[57]), .A(B[57]), .Y(n624) );
  sky130_fd_sc_hd__a211o_1 U511 ( .A1(n454), .A2(A[60]), .B1(n619), .C1(n451), 
        .X(n613) );
  sky130_fd_sc_hd__a21oi_1 U512 ( .A1(n452), .A2(A[62]), .B1(n620), .Y(n616)
         );
  sky130_fd_sc_hd__nor2b_1 U513 ( .B_N(A[63]), .A(B[63]), .Y(n620) );
  sky130_fd_sc_hd__nor2b_1 U514 ( .B_N(A[61]), .A(B[61]), .Y(n619) );
  sky130_fd_sc_hd__a21oi_1 U515 ( .A1(n457), .A2(A[58]), .B1(n625), .Y(n621)
         );
  sky130_fd_sc_hd__nor2b_1 U516 ( .B_N(A[59]), .A(B[59]), .Y(n625) );
  sky130_fd_sc_hd__a21oi_1 U517 ( .A1(n467), .A2(A[50]), .B1(n611), .Y(n607)
         );
  sky130_fd_sc_hd__nor2b_1 U518 ( .B_N(A[51]), .A(B[51]), .Y(n611) );
endmodule


module apb4_clint_DW01_inc_1 ( A, SUM );
  input [63:0] A;
  output [63:0] SUM;
  wire   n2, n5, n7, n8, n9, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20,
         n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
         n35, n36, n38, n39, n40, n41, n42, n44, n45, n46, n47, n50, n51, n52,
         n53, n54, n56, n57, n58, n59, n60, n62, n63, n64, n66, n67, n68, n69,
         n70, n72, n73, n74, n75, n78, n80, n81, n82, n84, n85, n86, n87, n88,
         n89, n91, n92, n93, n94, n95, n96, n98, n99, n100, n101, n102, n103,
         n106, n108, n109, n110, n112, n115, n116, n117, n118, n120, n121,
         n122, n123, n124, n126, n127, n128, n129, n132, n134, n135, n136,
         n138, n139, n140, n141, n142, n143, n145, n146, n148, n149, n150,
         n152, n153, n154, n155, n156, n157, n160, n162, n163, n164, n166,
         n167, n168, n170, n171, n172, n174, n175, n176, n178, n179, n180,
         n181, n182, n184, n185, n186, n188, n190, n193, n194, n196, n197,
         n198, n200, n201, n204, n206, n208, n209, n211, n212, n213, n214,
         n215, n216, n217, n218, n219, n220, n221, n222, n223, n224, n225,
         n226, n229, n231, n232, n233, n235, n236, n237, n238, n239, n240,
         n242, n243, n245, n246, n247, n249, n250, n251, n252, n253, n254,
         n257, n259, n260, n261, n262, n263, n264, n265, n267, n268, n269,
         n271, n272, n273, n275, n276, n277, n278, n279, n281, n282, n283,
         n285, n287, n288, n290, n291, n293, n294, n295, n297, n298, n301,
         n303, n305, n306, n308, n309, n310, n311, n312, n314, n315, n316,
         n317, n319, n320, n321, n324, n326, n327, n329, n330, n331, n332,
         n333, n335, n336, n338, n339, n341, n342, n343, n344, n345, n348,
         n350, n351, n353, n354, n355, n356, n357, n359, n360, n361, n363,
         n364, n367, n369, n371, n372, n374, n375, n376, n378, n379, n381,
         n382, n383, n385, n518, n519, n520, n521, n522, n523, n524, n525,
         n526, n527, n528, n529, n530, n531, n532, n533, n534, n535, n536,
         n537, n538, n539, n540, n541, n542, n543, n544, n545, n546, n547,
         n548, n549, n550, n551, n552, n553, n554, n555;
  assign n23 = A[61];
  assign n29 = A[60];
  assign n36 = A[59];
  assign n42 = A[58];
  assign n50 = A[57];
  assign n56 = A[56];
  assign n64 = A[55];
  assign n70 = A[54];
  assign n78 = A[53];
  assign n84 = A[52];
  assign n92 = A[51];
  assign n98 = A[50];
  assign n106 = A[49];
  assign n110 = A[48];
  assign n118 = A[47];
  assign n124 = A[46];
  assign n132 = A[45];
  assign n138 = A[44];
  assign n146 = A[43];
  assign n152 = A[42];
  assign n160 = A[41];
  assign n164 = A[40];
  assign n172 = A[39];
  assign n176 = A[38];
  assign n182 = A[37];
  assign n186 = A[36];
  assign n194 = A[35];
  assign n198 = A[34];
  assign n204 = A[33];
  assign n208 = A[32];
  assign n215 = A[31];
  assign n221 = A[30];
  assign n229 = A[29];
  assign n235 = A[28];
  assign n243 = A[27];
  assign n249 = A[26];
  assign n257 = A[25];
  assign n261 = A[24];
  assign n269 = A[23];
  assign n273 = A[22];
  assign n279 = A[21];
  assign n283 = A[20];
  assign n291 = A[19];
  assign n295 = A[18];
  assign n301 = A[17];
  assign n305 = A[16];
  assign n312 = A[15];
  assign n317 = A[14];
  assign n324 = A[13];
  assign n329 = A[12];
  assign n336 = A[11];
  assign n341 = A[10];
  assign n348 = A[9];
  assign n351 = A[8];
  assign n357 = A[7];
  assign n361 = A[6];
  assign n367 = A[5];
  assign n371 = A[4];
  assign n376 = A[3];
  assign n379 = A[2];
  assign n383 = A[1];
  assign n385 = A[0];

  sky130_fd_sc_hd__xnor2_1 U11 ( .A(n16), .B(n17), .Y(SUM[62]) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n533), .B(n13), .Y(n12) );
  sky130_fd_sc_hd__nor2_1 U14 ( .A(n14), .B(n8), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(n9), .B(n15), .Y(n14) );
  sky130_fd_sc_hd__nor2_1 U16 ( .A(n16), .B(n22), .Y(n15) );
  sky130_fd_sc_hd__xnor2_1 U18 ( .A(n24), .B(n25), .Y(SUM[61]) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n539), .B(n18), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n534), .B(n19), .Y(n18) );
  sky130_fd_sc_hd__nor2_1 U21 ( .A(n20), .B(n8), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U22 ( .A(n9), .B(n21), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n29), .B(n23), .Y(n22) );
  sky130_fd_sc_hd__xnor2_1 U27 ( .A(n30), .B(n31), .Y(SUM[60]) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n539), .B(n26), .Y(n25) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n532), .B(n27), .Y(n26) );
  sky130_fd_sc_hd__nor2_1 U30 ( .A(n28), .B(n8), .Y(n27) );
  sky130_fd_sc_hd__nand2_1 U31 ( .A(n9), .B(n29), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U35 ( .A(n539), .B(n32), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n531), .B(n33), .Y(n32) );
  sky130_fd_sc_hd__nor2_1 U37 ( .A(n34), .B(n8), .Y(n33) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(n35), .B(n47), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n42), .B(n36), .Y(n35) );
  sky130_fd_sc_hd__nor2_1 U44 ( .A(n518), .B(n39), .Y(n38) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n553), .B(n40), .Y(n39) );
  sky130_fd_sc_hd__nor2_1 U46 ( .A(n41), .B(n8), .Y(n40) );
  sky130_fd_sc_hd__xnor2_1 U50 ( .A(n51), .B(n52), .Y(SUM[57]) );
  sky130_fd_sc_hd__nor2_1 U51 ( .A(n5), .B(n45), .Y(n44) );
  sky130_fd_sc_hd__nand2_1 U52 ( .A(n553), .B(n46), .Y(n45) );
  sky130_fd_sc_hd__nor2_1 U53 ( .A(n47), .B(n8), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U56 ( .A(n56), .B(n50), .Y(n47) );
  sky130_fd_sc_hd__xnor2_1 U59 ( .A(n57), .B(n58), .Y(SUM[56]) );
  sky130_fd_sc_hd__nor2_1 U60 ( .A(n539), .B(n53), .Y(n52) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n532), .B(n54), .Y(n53) );
  sky130_fd_sc_hd__nor2_1 U62 ( .A(n57), .B(n8), .Y(n54) );
  sky130_fd_sc_hd__nor2_1 U67 ( .A(n539), .B(n59), .Y(n58) );
  sky130_fd_sc_hd__nand2_1 U68 ( .A(n533), .B(n60), .Y(n59) );
  sky130_fd_sc_hd__nor2_1 U71 ( .A(n63), .B(n75), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U72 ( .A(n70), .B(n64), .Y(n63) );
  sky130_fd_sc_hd__nor2_1 U76 ( .A(n5), .B(n67), .Y(n66) );
  sky130_fd_sc_hd__nand2_1 U77 ( .A(n7), .B(n68), .Y(n67) );
  sky130_fd_sc_hd__nor2_1 U78 ( .A(n69), .B(n89), .Y(n68) );
  sky130_fd_sc_hd__nor2_1 U83 ( .A(n5), .B(n73), .Y(n72) );
  sky130_fd_sc_hd__nand2_1 U84 ( .A(n554), .B(n74), .Y(n73) );
  sky130_fd_sc_hd__nor2_1 U85 ( .A(n75), .B(n89), .Y(n74) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(n84), .B(n78), .Y(n75) );
  sky130_fd_sc_hd__xnor2_1 U91 ( .A(n85), .B(n86), .Y(SUM[52]) );
  sky130_fd_sc_hd__nor2_1 U92 ( .A(n5), .B(n81), .Y(n80) );
  sky130_fd_sc_hd__nand2_1 U93 ( .A(n554), .B(n82), .Y(n81) );
  sky130_fd_sc_hd__nor2_1 U94 ( .A(n85), .B(n89), .Y(n82) );
  sky130_fd_sc_hd__xnor2_1 U98 ( .A(n93), .B(n94), .Y(SUM[51]) );
  sky130_fd_sc_hd__nor2_1 U99 ( .A(n518), .B(n87), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U100 ( .A(n531), .B(n88), .Y(n87) );
  sky130_fd_sc_hd__nand2_1 U104 ( .A(n98), .B(n92), .Y(n91) );
  sky130_fd_sc_hd__xnor2_1 U107 ( .A(n99), .B(n100), .Y(SUM[50]) );
  sky130_fd_sc_hd__nor2_1 U108 ( .A(n518), .B(n95), .Y(n94) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(n7), .B(n96), .Y(n95) );
  sky130_fd_sc_hd__nor2_1 U110 ( .A(n99), .B(n103), .Y(n96) );
  sky130_fd_sc_hd__nor2_1 U115 ( .A(n518), .B(n101), .Y(n100) );
  sky130_fd_sc_hd__nand2_1 U116 ( .A(n534), .B(n102), .Y(n101) );
  sky130_fd_sc_hd__nor2_1 U124 ( .A(n109), .B(n529), .Y(n108) );
  sky130_fd_sc_hd__nand2_1 U134 ( .A(n124), .B(n118), .Y(n117) );
  sky130_fd_sc_hd__nor2_1 U138 ( .A(n121), .B(n529), .Y(n120) );
  sky130_fd_sc_hd__nand2_1 U139 ( .A(n122), .B(n168), .Y(n121) );
  sky130_fd_sc_hd__nor2_1 U140 ( .A(n123), .B(n143), .Y(n122) );
  sky130_fd_sc_hd__nor2_1 U145 ( .A(n127), .B(n555), .Y(n126) );
  sky130_fd_sc_hd__nand2_1 U146 ( .A(n128), .B(n168), .Y(n127) );
  sky130_fd_sc_hd__nor2_1 U147 ( .A(n129), .B(n143), .Y(n128) );
  sky130_fd_sc_hd__xnor2_1 U153 ( .A(n139), .B(n140), .Y(SUM[44]) );
  sky130_fd_sc_hd__nor2_1 U154 ( .A(n135), .B(n555), .Y(n134) );
  sky130_fd_sc_hd__nand2_1 U155 ( .A(n136), .B(n168), .Y(n135) );
  sky130_fd_sc_hd__nor2_1 U156 ( .A(n139), .B(n143), .Y(n136) );
  sky130_fd_sc_hd__nor2_1 U161 ( .A(n141), .B(n529), .Y(n140) );
  sky130_fd_sc_hd__nand2_1 U162 ( .A(n168), .B(n537), .Y(n141) );
  sky130_fd_sc_hd__xnor2_1 U169 ( .A(n153), .B(n154), .Y(SUM[42]) );
  sky130_fd_sc_hd__nor2_1 U170 ( .A(n149), .B(n529), .Y(n148) );
  sky130_fd_sc_hd__nand2_1 U171 ( .A(n168), .B(n150), .Y(n149) );
  sky130_fd_sc_hd__nor2_1 U172 ( .A(n153), .B(n157), .Y(n150) );
  sky130_fd_sc_hd__nor2_1 U177 ( .A(n155), .B(n529), .Y(n154) );
  sky130_fd_sc_hd__nand2_1 U178 ( .A(n168), .B(n156), .Y(n155) );
  sky130_fd_sc_hd__nor2_1 U186 ( .A(n163), .B(n539), .Y(n162) );
  sky130_fd_sc_hd__nand2_1 U187 ( .A(n168), .B(n164), .Y(n163) );
  sky130_fd_sc_hd__nor2_1 U191 ( .A(n536), .B(n539), .Y(n166) );
  sky130_fd_sc_hd__nor2_1 U200 ( .A(n175), .B(n529), .Y(n174) );
  sky130_fd_sc_hd__nand2_1 U201 ( .A(n519), .B(n176), .Y(n175) );
  sky130_fd_sc_hd__nor2_1 U205 ( .A(n179), .B(n555), .Y(n178) );
  sky130_fd_sc_hd__nor2_1 U212 ( .A(n185), .B(n529), .Y(n184) );
  sky130_fd_sc_hd__nand2_1 U213 ( .A(n545), .B(n186), .Y(n185) );
  sky130_fd_sc_hd__nor2_1 U217 ( .A(n544), .B(n529), .Y(n188) );
  sky130_fd_sc_hd__nor2_1 U226 ( .A(n197), .B(n529), .Y(n196) );
  sky130_fd_sc_hd__nor2_1 U231 ( .A(n201), .B(n555), .Y(n200) );
  sky130_fd_sc_hd__xor2_1 U237 ( .A(n209), .B(n539), .X(SUM[32]) );
  sky130_fd_sc_hd__nor2_1 U238 ( .A(n209), .B(n555), .Y(n206) );
  sky130_fd_sc_hd__xnor2_1 U242 ( .A(n216), .B(n217), .Y(SUM[31]) );
  sky130_fd_sc_hd__nand2_1 U247 ( .A(n221), .B(n215), .Y(n214) );
  sky130_fd_sc_hd__xnor2_1 U250 ( .A(n222), .B(n223), .Y(SUM[30]) );
  sky130_fd_sc_hd__nand2_1 U252 ( .A(n219), .B(n265), .Y(n218) );
  sky130_fd_sc_hd__nor2_1 U253 ( .A(n220), .B(n240), .Y(n219) );
  sky130_fd_sc_hd__nor2_1 U258 ( .A(n224), .B(n2), .Y(n223) );
  sky130_fd_sc_hd__nand2_1 U259 ( .A(n225), .B(n265), .Y(n224) );
  sky130_fd_sc_hd__nor2_1 U260 ( .A(n226), .B(n240), .Y(n225) );
  sky130_fd_sc_hd__xnor2_1 U266 ( .A(n236), .B(n237), .Y(SUM[28]) );
  sky130_fd_sc_hd__nor2_1 U267 ( .A(n232), .B(n2), .Y(n231) );
  sky130_fd_sc_hd__nand2_1 U268 ( .A(n233), .B(n265), .Y(n232) );
  sky130_fd_sc_hd__nor2_1 U269 ( .A(n236), .B(n240), .Y(n233) );
  sky130_fd_sc_hd__nor2_1 U274 ( .A(n238), .B(n2), .Y(n237) );
  sky130_fd_sc_hd__nand2_1 U275 ( .A(n265), .B(n551), .Y(n238) );
  sky130_fd_sc_hd__xnor2_1 U282 ( .A(n250), .B(n251), .Y(SUM[26]) );
  sky130_fd_sc_hd__nor2_1 U283 ( .A(n246), .B(n2), .Y(n245) );
  sky130_fd_sc_hd__nand2_1 U284 ( .A(n265), .B(n247), .Y(n246) );
  sky130_fd_sc_hd__nor2_1 U285 ( .A(n250), .B(n548), .Y(n247) );
  sky130_fd_sc_hd__nor2_1 U290 ( .A(n252), .B(n2), .Y(n251) );
  sky130_fd_sc_hd__nand2_1 U291 ( .A(n265), .B(n253), .Y(n252) );
  sky130_fd_sc_hd__xnor2_1 U298 ( .A(n262), .B(n263), .Y(SUM[24]) );
  sky130_fd_sc_hd__nor2_1 U299 ( .A(n260), .B(n2), .Y(n259) );
  sky130_fd_sc_hd__nand2_1 U300 ( .A(n265), .B(n261), .Y(n260) );
  sky130_fd_sc_hd__nor2_1 U304 ( .A(n524), .B(n2), .Y(n263) );
  sky130_fd_sc_hd__nand2_1 U309 ( .A(n273), .B(n269), .Y(n268) );
  sky130_fd_sc_hd__nor2_1 U313 ( .A(n272), .B(n2), .Y(n271) );
  sky130_fd_sc_hd__nand2_1 U314 ( .A(n277), .B(n273), .Y(n272) );
  sky130_fd_sc_hd__nor2_1 U318 ( .A(n276), .B(n2), .Y(n275) );
  sky130_fd_sc_hd__nor2_1 U320 ( .A(n278), .B(n288), .Y(n277) );
  sky130_fd_sc_hd__nor2_1 U325 ( .A(n282), .B(n2), .Y(n281) );
  sky130_fd_sc_hd__nor2_1 U330 ( .A(n288), .B(n2), .Y(n285) );
  sky130_fd_sc_hd__nor2_1 U339 ( .A(n294), .B(n2), .Y(n293) );
  sky130_fd_sc_hd__nor2_1 U344 ( .A(n298), .B(n2), .Y(n297) );
  sky130_fd_sc_hd__xor2_1 U350 ( .A(n306), .B(n2), .X(SUM[16]) );
  sky130_fd_sc_hd__nor2_1 U351 ( .A(n306), .B(n2), .Y(n303) );
  sky130_fd_sc_hd__nand2_1 U360 ( .A(n317), .B(n312), .Y(n311) );
  sky130_fd_sc_hd__nand2_1 U364 ( .A(n315), .B(n353), .Y(n314) );
  sky130_fd_sc_hd__nor2_1 U365 ( .A(n316), .B(n333), .Y(n315) );
  sky130_fd_sc_hd__nand2_1 U370 ( .A(n320), .B(n353), .Y(n319) );
  sky130_fd_sc_hd__nor2_1 U371 ( .A(n321), .B(n333), .Y(n320) );
  sky130_fd_sc_hd__xor2_1 U377 ( .A(n331), .B(n330), .X(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U378 ( .A(n327), .B(n353), .Y(n326) );
  sky130_fd_sc_hd__nor2_1 U379 ( .A(n330), .B(n333), .Y(n327) );
  sky130_fd_sc_hd__nand2_1 U384 ( .A(n353), .B(n552), .Y(n331) );
  sky130_fd_sc_hd__xor2_1 U391 ( .A(n343), .B(n342), .X(SUM[10]) );
  sky130_fd_sc_hd__nand2_1 U392 ( .A(n353), .B(n339), .Y(n338) );
  sky130_fd_sc_hd__nor2_1 U393 ( .A(n342), .B(n549), .Y(n339) );
  sky130_fd_sc_hd__nand2_1 U398 ( .A(n353), .B(n344), .Y(n343) );
  sky130_fd_sc_hd__nand2_1 U406 ( .A(n353), .B(n351), .Y(n350) );
  sky130_fd_sc_hd__nor2_1 U417 ( .A(n360), .B(n550), .Y(n359) );
  sky130_fd_sc_hd__nand2_1 U418 ( .A(n546), .B(n361), .Y(n360) );
  sky130_fd_sc_hd__nor2_1 U422 ( .A(n364), .B(n550), .Y(n363) );
  sky130_fd_sc_hd__xor2_1 U428 ( .A(n550), .B(n372), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U429 ( .A(n372), .B(n550), .Y(n369) );
  sky130_fd_sc_hd__nand2_1 U440 ( .A(n381), .B(n379), .Y(n378) );
  sky130_fd_sc_hd__nor2_2 U452 ( .A(n555), .B(n12), .Y(n11) );
  sky130_fd_sc_hd__and2_2 U453 ( .A(n371), .B(n367), .X(n546) );
  sky130_fd_sc_hd__nor2b_2 U454 ( .B_N(n7), .A(n555), .Y(n112) );
  sky130_fd_sc_hd__nand2_1 U455 ( .A(n530), .B(n527), .Y(n518) );
  sky130_fd_sc_hd__nand2_1 U456 ( .A(n530), .B(n527), .Y(n5) );
  sky130_fd_sc_hd__nand2b_1 U457 ( .A_N(n321), .B(n317), .Y(n316) );
  sky130_fd_sc_hd__nor2_2 U458 ( .A(n214), .B(n226), .Y(n213) );
  sky130_fd_sc_hd__nor2_4 U459 ( .A(n171), .B(n181), .Y(n170) );
  sky130_fd_sc_hd__nand2_4 U460 ( .A(n176), .B(n172), .Y(n171) );
  sky130_fd_sc_hd__nand2_2 U461 ( .A(n249), .B(n243), .Y(n242) );
  sky130_fd_sc_hd__nor2_2 U462 ( .A(n311), .B(n321), .Y(n310) );
  sky130_fd_sc_hd__inv_1 U463 ( .A(n249), .Y(n250) );
  sky130_fd_sc_hd__nand2_2 U464 ( .A(n283), .B(n279), .Y(n278) );
  sky130_fd_sc_hd__inv_1 U465 ( .A(n329), .Y(n330) );
  sky130_fd_sc_hd__nor2_1 U466 ( .A(n254), .B(n242), .Y(n239) );
  sky130_fd_sc_hd__nor2_1 U467 ( .A(n268), .B(n278), .Y(n267) );
  sky130_fd_sc_hd__nand2_1 U468 ( .A(n295), .B(n291), .Y(n290) );
  sky130_fd_sc_hd__nor2_1 U469 ( .A(n218), .B(n2), .Y(n217) );
  sky130_fd_sc_hd__nand2b_1 U470 ( .A_N(n201), .B(n198), .Y(n197) );
  sky130_fd_sc_hd__nor2_1 U471 ( .A(n181), .B(n544), .Y(n519) );
  sky130_fd_sc_hd__nor2_1 U472 ( .A(n181), .B(n544), .Y(n180) );
  sky130_fd_sc_hd__or2_2 U473 ( .A(n382), .B(n375), .X(n550) );
  sky130_fd_sc_hd__inv_1 U474 ( .A(n235), .Y(n236) );
  sky130_fd_sc_hd__nand2_2 U475 ( .A(n341), .B(n336), .Y(n335) );
  sky130_fd_sc_hd__nand2_1 U476 ( .A(n239), .B(n213), .Y(n520) );
  sky130_fd_sc_hd__nand2b_1 U477 ( .A_N(n298), .B(n295), .Y(n294) );
  sky130_fd_sc_hd__nand2_1 U478 ( .A(n116), .B(n142), .Y(n521) );
  sky130_fd_sc_hd__nand2_1 U479 ( .A(n116), .B(n142), .Y(n522) );
  sky130_fd_sc_hd__nand2_1 U480 ( .A(n116), .B(n142), .Y(n115) );
  sky130_fd_sc_hd__nor2_4 U481 ( .A(n157), .B(n145), .Y(n142) );
  sky130_fd_sc_hd__nand2_1 U482 ( .A(n355), .B(n374), .Y(n523) );
  sky130_fd_sc_hd__nand2_1 U483 ( .A(n355), .B(n374), .Y(n354) );
  sky130_fd_sc_hd__nand2_1 U484 ( .A(n267), .B(n287), .Y(n524) );
  sky130_fd_sc_hd__nand2_1 U485 ( .A(n267), .B(n287), .Y(n264) );
  sky130_fd_sc_hd__nand2_2 U486 ( .A(n186), .B(n182), .Y(n181) );
  sky130_fd_sc_hd__nor2_2 U487 ( .A(n117), .B(n129), .Y(n116) );
  sky130_fd_sc_hd__nor2_4 U488 ( .A(n201), .B(n193), .Y(n190) );
  sky130_fd_sc_hd__nor2_1 U489 ( .A(n523), .B(n528), .Y(n525) );
  sky130_fd_sc_hd__nor2_1 U490 ( .A(n354), .B(n528), .Y(n541) );
  sky130_fd_sc_hd__nor2_1 U491 ( .A(n520), .B(n264), .Y(n526) );
  sky130_fd_sc_hd__nor2_1 U492 ( .A(n212), .B(n264), .Y(n538) );
  sky130_fd_sc_hd__nor2_1 U493 ( .A(n309), .B(n354), .Y(n527) );
  sky130_fd_sc_hd__nor2_1 U494 ( .A(n354), .B(n309), .Y(n540) );
  sky130_fd_sc_hd__inv_1 U495 ( .A(n215), .Y(n216) );
  sky130_fd_sc_hd__nand2_2 U496 ( .A(n110), .B(n106), .Y(n103) );
  sky130_fd_sc_hd__nand2_1 U497 ( .A(n332), .B(n310), .Y(n528) );
  sky130_fd_sc_hd__nor2_2 U498 ( .A(n345), .B(n335), .Y(n332) );
  sky130_fd_sc_hd__inv_1 U499 ( .A(n341), .Y(n342) );
  sky130_fd_sc_hd__nand2_2 U500 ( .A(n526), .B(n525), .Y(n529) );
  sky130_fd_sc_hd__nand2_2 U501 ( .A(n211), .B(n308), .Y(n555) );
  sky130_fd_sc_hd__nor2_1 U502 ( .A(n212), .B(n264), .Y(n530) );
  sky130_fd_sc_hd__nor2_1 U503 ( .A(n520), .B(n524), .Y(n211) );
  sky130_fd_sc_hd__nand2_2 U504 ( .A(n371), .B(n367), .Y(n364) );
  sky130_fd_sc_hd__nor2_1 U505 ( .A(n522), .B(n536), .Y(n531) );
  sky130_fd_sc_hd__nor2_1 U506 ( .A(n521), .B(n536), .Y(n532) );
  sky130_fd_sc_hd__nor2_1 U507 ( .A(n522), .B(n536), .Y(n553) );
  sky130_fd_sc_hd__nand2_2 U508 ( .A(n170), .B(n190), .Y(n536) );
  sky130_fd_sc_hd__nor2_1 U509 ( .A(n521), .B(n167), .Y(n533) );
  sky130_fd_sc_hd__nor2_1 U510 ( .A(n522), .B(n167), .Y(n534) );
  sky130_fd_sc_hd__nor2_1 U511 ( .A(n115), .B(n167), .Y(n554) );
  sky130_fd_sc_hd__nand2_1 U512 ( .A(n170), .B(n190), .Y(n535) );
  sky130_fd_sc_hd__nand2_1 U513 ( .A(n170), .B(n190), .Y(n167) );
  sky130_fd_sc_hd__inv_2 U514 ( .A(n143), .Y(n537) );
  sky130_fd_sc_hd__nor2_2 U515 ( .A(n115), .B(n535), .Y(n7) );
  sky130_fd_sc_hd__nand2b_1 U516 ( .A_N(n521), .B(n543), .Y(n109) );
  sky130_fd_sc_hd__nand2_2 U517 ( .A(n538), .B(n540), .Y(n539) );
  sky130_fd_sc_hd__inv_1 U518 ( .A(n180), .Y(n179) );
  sky130_fd_sc_hd__or2_1 U519 ( .A(n201), .B(n193), .X(n544) );
  sky130_fd_sc_hd__inv_1 U520 ( .A(n88), .Y(n89) );
  sky130_fd_sc_hd__inv_1 U521 ( .A(n157), .Y(n156) );
  sky130_fd_sc_hd__nor2_1 U522 ( .A(n523), .B(n528), .Y(n308) );
  sky130_fd_sc_hd__inv_1 U523 ( .A(n110), .Y(n542) );
  sky130_fd_sc_hd__nor2_1 U524 ( .A(n536), .B(n542), .Y(n543) );
  sky130_fd_sc_hd__inv_2 U525 ( .A(n277), .Y(n276) );
  sky130_fd_sc_hd__inv_2 U526 ( .A(n22), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U527 ( .A(n9), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U528 ( .A(n535), .Y(n168) );
  sky130_fd_sc_hd__inv_1 U529 ( .A(n8), .Y(n60) );
  sky130_fd_sc_hd__inv_1 U530 ( .A(n524), .Y(n265) );
  sky130_fd_sc_hd__inv_2 U531 ( .A(n548), .Y(n253) );
  sky130_fd_sc_hd__inv_2 U532 ( .A(n23), .Y(n24) );
  sky130_fd_sc_hd__xor2_1 U533 ( .A(A[63]), .B(n11), .X(SUM[63]) );
  sky130_fd_sc_hd__inv_1 U534 ( .A(n92), .Y(n93) );
  sky130_fd_sc_hd__inv_1 U535 ( .A(n50), .Y(n51) );
  sky130_fd_sc_hd__inv_2 U536 ( .A(n29), .Y(n30) );
  sky130_fd_sc_hd__xor2_1 U537 ( .A(n78), .B(n80), .X(SUM[53]) );
  sky130_fd_sc_hd__xor2_1 U538 ( .A(n70), .B(n72), .X(SUM[54]) );
  sky130_fd_sc_hd__xor2_1 U539 ( .A(n64), .B(n66), .X(SUM[55]) );
  sky130_fd_sc_hd__xor2_1 U540 ( .A(n42), .B(n44), .X(SUM[58]) );
  sky130_fd_sc_hd__xor2_1 U541 ( .A(n36), .B(n38), .X(SUM[59]) );
  sky130_fd_sc_hd__nand2_1 U542 ( .A(n152), .B(n146), .Y(n145) );
  sky130_fd_sc_hd__nand2_2 U543 ( .A(n164), .B(n160), .Y(n157) );
  sky130_fd_sc_hd__nand2b_1 U544 ( .A_N(n47), .B(n42), .Y(n41) );
  sky130_fd_sc_hd__nand2_2 U545 ( .A(n208), .B(n204), .Y(n201) );
  sky130_fd_sc_hd__xor2_1 U546 ( .A(n106), .B(n108), .X(SUM[49]) );
  sky130_fd_sc_hd__xor2_1 U547 ( .A(n301), .B(n303), .X(SUM[17]) );
  sky130_fd_sc_hd__xor2_1 U548 ( .A(n295), .B(n297), .X(SUM[18]) );
  sky130_fd_sc_hd__xor2_1 U549 ( .A(n269), .B(n271), .X(SUM[23]) );
  sky130_fd_sc_hd__xor2_1 U550 ( .A(n229), .B(n231), .X(SUM[29]) );
  sky130_fd_sc_hd__xor2_1 U551 ( .A(n279), .B(n281), .X(SUM[21]) );
  sky130_fd_sc_hd__xor2_1 U552 ( .A(n291), .B(n293), .X(SUM[19]) );
  sky130_fd_sc_hd__xor2_1 U553 ( .A(n283), .B(n285), .X(SUM[20]) );
  sky130_fd_sc_hd__xor2_1 U554 ( .A(n273), .B(n275), .X(SUM[22]) );
  sky130_fd_sc_hd__xor2_1 U555 ( .A(n257), .B(n259), .X(SUM[25]) );
  sky130_fd_sc_hd__xor2_1 U556 ( .A(n243), .B(n245), .X(SUM[27]) );
  sky130_fd_sc_hd__nor2_2 U557 ( .A(n91), .B(n103), .Y(n88) );
  sky130_fd_sc_hd__xor2_1 U558 ( .A(n164), .B(n166), .X(SUM[40]) );
  sky130_fd_sc_hd__xor2_1 U559 ( .A(n160), .B(n162), .X(SUM[41]) );
  sky130_fd_sc_hd__nand2b_1 U560 ( .A_N(n129), .B(n124), .Y(n123) );
  sky130_fd_sc_hd__xor2_1 U561 ( .A(n132), .B(n134), .X(SUM[45]) );
  sky130_fd_sc_hd__xor2_1 U562 ( .A(n124), .B(n126), .X(SUM[46]) );
  sky130_fd_sc_hd__xor2_1 U563 ( .A(n118), .B(n120), .X(SUM[47]) );
  sky130_fd_sc_hd__xor2_1 U564 ( .A(n204), .B(n206), .X(SUM[33]) );
  sky130_fd_sc_hd__xor2_1 U565 ( .A(n198), .B(n200), .X(SUM[34]) );
  sky130_fd_sc_hd__xor2_1 U566 ( .A(n194), .B(n196), .X(SUM[35]) );
  sky130_fd_sc_hd__xor2_1 U567 ( .A(n186), .B(n188), .X(SUM[36]) );
  sky130_fd_sc_hd__xor2_1 U568 ( .A(n182), .B(n184), .X(SUM[37]) );
  sky130_fd_sc_hd__xor2_1 U569 ( .A(n176), .B(n178), .X(SUM[38]) );
  sky130_fd_sc_hd__xor2_1 U570 ( .A(n172), .B(n174), .X(SUM[39]) );
  sky130_fd_sc_hd__xor2_1 U571 ( .A(n146), .B(n148), .X(SUM[43]) );
  sky130_fd_sc_hd__xor2_1 U572 ( .A(n110), .B(n112), .X(SUM[48]) );
  sky130_fd_sc_hd__nand2_1 U573 ( .A(n235), .B(n229), .Y(n226) );
  sky130_fd_sc_hd__nand2b_1 U574 ( .A_N(n75), .B(n70), .Y(n69) );
  sky130_fd_sc_hd__xor2_1 U575 ( .A(n547), .B(n383), .X(SUM[1]) );
  sky130_fd_sc_hd__clkbuf_1 U576 ( .A(n385), .X(n547) );
  sky130_fd_sc_hd__nand2b_1 U577 ( .A_N(n226), .B(n221), .Y(n220) );
  sky130_fd_sc_hd__xnor2_1 U578 ( .A(n350), .B(n348), .Y(SUM[9]) );
  sky130_fd_sc_hd__xnor2_1 U579 ( .A(n319), .B(n317), .Y(SUM[14]) );
  sky130_fd_sc_hd__xnor2_1 U580 ( .A(n326), .B(n324), .Y(SUM[13]) );
  sky130_fd_sc_hd__xnor2_1 U581 ( .A(n338), .B(n336), .Y(SUM[11]) );
  sky130_fd_sc_hd__xnor2_1 U582 ( .A(n314), .B(n312), .Y(SUM[15]) );
  sky130_fd_sc_hd__xor2_1 U583 ( .A(n351), .B(n353), .X(SUM[8]) );
  sky130_fd_sc_hd__inv_2 U584 ( .A(A[62]), .Y(n16) );
  sky130_fd_sc_hd__xor2_1 U585 ( .A(n357), .B(n359), .X(SUM[7]) );
  sky130_fd_sc_hd__xnor2_1 U586 ( .A(n378), .B(n376), .Y(SUM[3]) );
  sky130_fd_sc_hd__xor2_1 U587 ( .A(n379), .B(n381), .X(SUM[2]) );
  sky130_fd_sc_hd__xor2_1 U588 ( .A(n361), .B(n363), .X(SUM[6]) );
  sky130_fd_sc_hd__xor2_1 U589 ( .A(n367), .B(n369), .X(SUM[5]) );
  sky130_fd_sc_hd__nand2b_1 U590 ( .A_N(n288), .B(n283), .Y(n282) );
  sky130_fd_sc_hd__inv_1 U591 ( .A(n84), .Y(n85) );
  sky130_fd_sc_hd__inv_1 U592 ( .A(n98), .Y(n99) );
  sky130_fd_sc_hd__inv_1 U593 ( .A(n56), .Y(n57) );
  sky130_fd_sc_hd__nor2_1 U594 ( .A(n201), .B(n193), .Y(n545) );
  sky130_fd_sc_hd__inv_1 U595 ( .A(n103), .Y(n102) );
  sky130_fd_sc_hd__nand2_2 U596 ( .A(n198), .B(n194), .Y(n193) );
  sky130_fd_sc_hd__inv_1 U597 ( .A(n261), .Y(n262) );
  sky130_fd_sc_hd__nand2_1 U598 ( .A(n261), .B(n257), .Y(n254) );
  sky130_fd_sc_hd__clkinv_1 U599 ( .A(n382), .Y(n381) );
  sky130_fd_sc_hd__nand2_2 U600 ( .A(n361), .B(n357), .Y(n356) );
  sky130_fd_sc_hd__inv_1 U601 ( .A(n287), .Y(n288) );
  sky130_fd_sc_hd__nor2_2 U602 ( .A(n290), .B(n298), .Y(n287) );
  sky130_fd_sc_hd__nand2_1 U603 ( .A(n332), .B(n310), .Y(n309) );
  sky130_fd_sc_hd__inv_1 U604 ( .A(n142), .Y(n143) );
  sky130_fd_sc_hd__nand2_2 U605 ( .A(n379), .B(n376), .Y(n375) );
  sky130_fd_sc_hd__inv_2 U606 ( .A(n138), .Y(n139) );
  sky130_fd_sc_hd__nand2_2 U607 ( .A(n138), .B(n132), .Y(n129) );
  sky130_fd_sc_hd__inv_1 U608 ( .A(n152), .Y(n153) );
  sky130_fd_sc_hd__inv_1 U609 ( .A(n221), .Y(n222) );
  sky130_fd_sc_hd__inv_1 U610 ( .A(n547), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U611 ( .A(n208), .Y(n209) );
  sky130_fd_sc_hd__clkinv_1 U612 ( .A(n523), .Y(n353) );
  sky130_fd_sc_hd__nand2_1 U613 ( .A(n261), .B(n257), .Y(n548) );
  sky130_fd_sc_hd__inv_2 U614 ( .A(n344), .Y(n549) );
  sky130_fd_sc_hd__inv_1 U615 ( .A(n345), .Y(n344) );
  sky130_fd_sc_hd__nand2_1 U616 ( .A(n239), .B(n213), .Y(n212) );
  sky130_fd_sc_hd__nand2_2 U617 ( .A(n351), .B(n348), .Y(n345) );
  sky130_fd_sc_hd__inv_1 U618 ( .A(n305), .Y(n306) );
  sky130_fd_sc_hd__nor2_2 U619 ( .A(n364), .B(n356), .Y(n355) );
  sky130_fd_sc_hd__nor2_1 U620 ( .A(n548), .B(n242), .Y(n551) );
  sky130_fd_sc_hd__nand2_2 U621 ( .A(n329), .B(n324), .Y(n321) );
  sky130_fd_sc_hd__nor2_1 U622 ( .A(n345), .B(n335), .Y(n552) );
  sky130_fd_sc_hd__nand2_2 U623 ( .A(n305), .B(n301), .Y(n298) );
  sky130_fd_sc_hd__nor2_2 U624 ( .A(n382), .B(n375), .Y(n374) );
  sky130_fd_sc_hd__nand2_2 U625 ( .A(n88), .B(n62), .Y(n8) );
  sky130_fd_sc_hd__nand2_2 U626 ( .A(n383), .B(n385), .Y(n382) );
  sky130_fd_sc_hd__inv_1 U627 ( .A(n371), .Y(n372) );
  sky130_fd_sc_hd__inv_1 U628 ( .A(n552), .Y(n333) );
  sky130_fd_sc_hd__inv_1 U629 ( .A(n551), .Y(n240) );
  sky130_fd_sc_hd__inv_2 U630 ( .A(n541), .Y(n2) );
endmodule


module apb4_clint ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr, clint_rtc_clk_i, clint_tmr_irq_o, 
        clint_sfr_irq_o );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite,
         clint_rtc_clk_i;
  output apb4_pready, apb4_pslverr, clint_tmr_irq_o, clint_sfr_irq_o;
  wire   n6, n5, s_rtc_rise_edge, \s_msip_d[0] , N18, N19, N20, N21, N22, N23,
         N24, N25, N26, N27, N28, N29, N30, N31, N32, N33, N34, N35, N36, N37,
         N38, N39, N40, N41, N42, N43, N44, N45, N46, N47, N48, N49, N50, N51,
         N52, N53, N54, N55, N56, N57, N58, N59, N60, N61, N62, N63, N64, N65,
         N66, N67, N68, N69, N70, N71, N72, N73, N74, N75, N76, N77, N78, N79,
         N80, N81, n172, n175, n176, n177, n178, n181, n184, n185, n186, n187,
         n188, n189, n190, n191, n192, n193, n194, n195, n196, n197, n198,
         n199, n200, n201, n202, n203, n204, n205, n206, n207, n208, n209,
         n210, n211, n212, n213, n214, n215, n216, n217, n218, n219, n220,
         n221, n222, n223, n224, n225, n226, n227, n228, n229, n230, n231,
         n232, n233, n234, n235, n236, n237, n238, n239, n240, n241, n242,
         n243, n244, n245, n246, n247, n248, n249, n250, n251, n252, n253,
         n254, n255, n256, n257, n258, n259, n260, n261, n262, n263, n264,
         n265, n266, n267, n268, n269, n270, n271, n272, n273, n274, n275,
         n276, n277, n278, n279, n280, n281, n282, n283, n284, n285, n286,
         n287, n288, n289, n290, n291, n292, n293, n294, n295, n296, n297,
         n298, n299, n300, n301, n302, n303, n304, n305, n306, n307, n308,
         n309, n310, n311, n312, n313, n314, n315, n316, n317, n318, n319,
         n320, n321, n322, n323, n324, n325, n326, n327, n328, n329, n330,
         n331, n332, n333, n334, n335, n336, n337, n338, n339, n340, n341,
         n342, n343, n344, n345, n346, n347, n348, n349, n350, n351, n352,
         n353, n354, n355, n356, n357, n358, n359, n360, n361, n362, n363,
         n364, n365, n366, n367, n368, n369, n370, n371, n372, n373, n374,
         n375, n376, n377, n378, n379, n380, n381, n382, n383, n384, n385,
         n386, n387, n388, n389, n390, n391, n392, n393, n394, n395, n396,
         n397, n398, n399, n400, n401, n402, n403, n404, n405, n406, n407,
         n408, n409, n410, n411, n412, n413, n414, n415, n416, n417, n418,
         n419, n420, n421, n422, n423, n424, n425, n426, n427, n428, n429,
         n430, n431, n432, n433, n434, n435, n436, n437, n438, n439, n440;
  wire   [63:0] s_mtime_q;
  wire   [63:0] s_mtime_d;
  wire   [63:0] s_mtimecmp_d;
  wire   [63:0] s_mtimecmp_q;
  assign apb4_pready = n6;
  assign apb4_pslverr = n5;

  sky130_fd_sc_hd__o21a_1 U371 ( .A1(n177), .A2(n175), .B1(n176), .X(n172) );
  sky130_fd_sc_hd__nand4_1 U372 ( .A(n176), .B(n408), .C(n407), .D(n406), .Y(
        n178) );
  sky130_fd_sc_hd__and4_1 U373 ( .A(apb4_pwrite), .B(apb4_psel), .C(
        apb4_penable), .D(n405), .X(n176) );
  sky130_fd_sc_hd__nand4b_1 U378 ( .A_N(apb4_pwrite), .B(apb4_psel), .C(
        apb4_penable), .D(n405), .Y(n217) );
  edge_det_STAGE2_DATA_WIDTH1 u_edge_det ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(clint_rtc_clk_i), .re_o(s_rtc_rise_edge) );
  dffr_DATA_WIDTH1_0 u_msip_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(\s_msip_d[0] ), .dat_o(clint_sfr_irq_o) );
  dffr_DATA_WIDTH64 u_mtime_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_mtime_d), .dat_o(s_mtime_q) );
  dffrh_DATA_WIDTH64 u_mtimecmp_dffrh ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(s_mtimecmp_d), .dat_o(s_mtimecmp_q) );
  apb4_clint_DW_cmp_0 gte_73 ( .A({s_mtime_q[63:49], n218, s_mtime_q[47:39], 
        n219, s_mtime_q[37], n257, s_mtime_q[35:31], n240, n247, n256, 
        s_mtime_q[27:26], n246, s_mtime_q[24], n255, n251, s_mtime_q[21], n252, 
        n245, n250, n249, n259, s_mtime_q[15], n248, s_mtime_q[13:10], n241, 
        n243, s_mtime_q[7:6], n276, n275, s_mtime_q[3], n220, n274, n258}), 
        .B(s_mtimecmp_q), .TC(n5), .GE_LT(n6), .GE_GT_EQ(n6), .GE_LT_GT_LE(
        clint_tmr_irq_o) );
  apb4_clint_DW01_inc_1 add_47 ( .A({s_mtime_q[63:49], n218, s_mtime_q[47:39], 
        n219, s_mtime_q[37:0]}), .SUM({N81, N80, N79, N78, N77, N76, N75, N74, 
        N73, N72, N71, N70, N69, N68, N67, N66, N65, N64, N63, N62, N61, N60, 
        N59, N58, N57, N56, N55, N54, N53, N52, N51, N50, N49, N48, N47, N46, 
        N45, N44, N43, N42, N41, N40, N39, N38, N37, N36, N35, N34, N33, N32, 
        N31, N30, N29, N28, N27, N26, N25, N24, N23, N22, N21, N20, N19, N18})
         );
  sky130_fd_sc_hd__buf_2 U379 ( .A(s_mtime_q[18]), .X(n242) );
  sky130_fd_sc_hd__buf_2 U380 ( .A(s_rtc_rise_edge), .X(n272) );
  sky130_fd_sc_hd__buf_2 U381 ( .A(s_rtc_rise_edge), .X(n270) );
  sky130_fd_sc_hd__mux2_2 U382 ( .A0(n275), .A1(N22), .S(n269), .X(
        s_mtime_d[4]) );
  sky130_fd_sc_hd__mux2_2 U383 ( .A0(n241), .A1(N27), .S(n269), .X(
        s_mtime_d[9]) );
  sky130_fd_sc_hd__mux2_2 U384 ( .A0(s_mtime_q[2]), .A1(N20), .S(n269), .X(
        s_mtime_d[2]) );
  sky130_fd_sc_hd__mux2_2 U385 ( .A0(s_mtime_q[11]), .A1(N29), .S(n269), .X(
        s_mtime_d[11]) );
  sky130_fd_sc_hd__mux2_2 U386 ( .A0(s_mtime_q[12]), .A1(N30), .S(n269), .X(
        s_mtime_d[12]) );
  sky130_fd_sc_hd__buf_4 U387 ( .A(s_mtime_q[48]), .X(n218) );
  sky130_fd_sc_hd__mux2_2 U388 ( .A0(n274), .A1(N19), .S(n269), .X(
        s_mtime_d[1]) );
  sky130_fd_sc_hd__buf_4 U389 ( .A(s_mtime_q[38]), .X(n219) );
  sky130_fd_sc_hd__buf_1 U390 ( .A(s_mtime_q[17]), .X(n249) );
  sky130_fd_sc_hd__buf_1 U391 ( .A(s_rtc_rise_edge), .X(n269) );
  sky130_fd_sc_hd__inv_2 U392 ( .A(n401), .Y(n220) );
  sky130_fd_sc_hd__nand2_1 U393 ( .A(s_mtime_q[60]), .B(n221), .Y(n222) );
  sky130_fd_sc_hd__nand2_1 U394 ( .A(N78), .B(n273), .Y(n223) );
  sky130_fd_sc_hd__nand2_1 U395 ( .A(n222), .B(n223), .Y(s_mtime_d[60]) );
  sky130_fd_sc_hd__inv_2 U396 ( .A(n273), .Y(n221) );
  sky130_fd_sc_hd__nand2_1 U397 ( .A(s_mtime_q[62]), .B(n224), .Y(n225) );
  sky130_fd_sc_hd__nand2_1 U398 ( .A(N80), .B(n273), .Y(n226) );
  sky130_fd_sc_hd__nand2_1 U399 ( .A(n225), .B(n226), .Y(s_mtime_d[62]) );
  sky130_fd_sc_hd__inv_2 U400 ( .A(n273), .Y(n224) );
  sky130_fd_sc_hd__nand2_1 U401 ( .A(s_mtime_q[61]), .B(n227), .Y(n228) );
  sky130_fd_sc_hd__nand2_1 U402 ( .A(N79), .B(n273), .Y(n229) );
  sky130_fd_sc_hd__nand2_1 U403 ( .A(n228), .B(n229), .Y(s_mtime_d[61]) );
  sky130_fd_sc_hd__inv_2 U404 ( .A(n273), .Y(n227) );
  sky130_fd_sc_hd__nand2_1 U405 ( .A(s_mtime_q[57]), .B(n230), .Y(n231) );
  sky130_fd_sc_hd__nand2_1 U406 ( .A(N75), .B(n273), .Y(n232) );
  sky130_fd_sc_hd__nand2_1 U407 ( .A(n231), .B(n232), .Y(s_mtime_d[57]) );
  sky130_fd_sc_hd__inv_1 U408 ( .A(n273), .Y(n230) );
  sky130_fd_sc_hd__buf_2 U409 ( .A(s_rtc_rise_edge), .X(n273) );
  sky130_fd_sc_hd__nand2_1 U410 ( .A(s_mtime_q[56]), .B(n233), .Y(n234) );
  sky130_fd_sc_hd__nand2_1 U411 ( .A(N74), .B(n273), .Y(n235) );
  sky130_fd_sc_hd__nand2_1 U412 ( .A(n234), .B(n235), .Y(s_mtime_d[56]) );
  sky130_fd_sc_hd__inv_2 U413 ( .A(n273), .Y(n233) );
  sky130_fd_sc_hd__nand2_1 U414 ( .A(n176), .B(n177), .Y(n236) );
  sky130_fd_sc_hd__nand2_1 U415 ( .A(n175), .B(n176), .Y(n237) );
  sky130_fd_sc_hd__nand4_1 U416 ( .A(n404), .B(apb4_paddr[2]), .C(n407), .D(
        n406), .Y(n238) );
  sky130_fd_sc_hd__and4_1 U417 ( .A(n404), .B(apb4_paddr[3]), .C(n408), .D(
        n406), .X(n239) );
  sky130_fd_sc_hd__inv_1 U418 ( .A(s_mtime_q[3]), .Y(n400) );
  sky130_fd_sc_hd__mux2_1 U419 ( .A0(s_mtime_q[32]), .A1(N50), .S(n271), .X(
        s_mtime_d[32]) );
  sky130_fd_sc_hd__inv_2 U420 ( .A(n374), .Y(n240) );
  sky130_fd_sc_hd__buf_1 U421 ( .A(s_mtime_q[9]), .X(n241) );
  sky130_fd_sc_hd__inv_2 U422 ( .A(n395), .Y(n243) );
  sky130_fd_sc_hd__inv_1 U423 ( .A(s_mtime_q[19]), .Y(n244) );
  sky130_fd_sc_hd__inv_2 U424 ( .A(n244), .Y(n245) );
  sky130_fd_sc_hd__buf_1 U425 ( .A(s_mtime_q[25]), .X(n246) );
  sky130_fd_sc_hd__inv_2 U426 ( .A(n375), .Y(n247) );
  sky130_fd_sc_hd__inv_2 U427 ( .A(n389), .Y(n248) );
  sky130_fd_sc_hd__buf_1 U428 ( .A(n242), .X(n250) );
  sky130_fd_sc_hd__inv_2 U429 ( .A(n382), .Y(n251) );
  sky130_fd_sc_hd__inv_2 U430 ( .A(n384), .Y(n252) );
  sky130_fd_sc_hd__inv_2 U431 ( .A(n261), .Y(n260) );
  sky130_fd_sc_hd__buf_1 U432 ( .A(n254), .X(n261) );
  sky130_fd_sc_hd__buf_1 U433 ( .A(n172), .X(n264) );
  sky130_fd_sc_hd__buf_1 U434 ( .A(n172), .X(n265) );
  sky130_fd_sc_hd__buf_1 U435 ( .A(n172), .X(n266) );
  sky130_fd_sc_hd__buf_1 U436 ( .A(n172), .X(n267) );
  sky130_fd_sc_hd__buf_1 U437 ( .A(n172), .X(n268) );
  sky130_fd_sc_hd__inv_2 U438 ( .A(n253), .Y(n262) );
  sky130_fd_sc_hd__buf_2 U439 ( .A(s_rtc_rise_edge), .X(n271) );
  sky130_fd_sc_hd__nand2_1 U440 ( .A(n175), .B(n404), .Y(n253) );
  sky130_fd_sc_hd__nand2_1 U441 ( .A(n177), .B(n404), .Y(n254) );
  sky130_fd_sc_hd__inv_2 U442 ( .A(n217), .Y(n404) );
  sky130_fd_sc_hd__nand3_1 U443 ( .A(n407), .B(n406), .C(n408), .Y(n216) );
  sky130_fd_sc_hd__inv_2 U444 ( .A(n239), .Y(n263) );
  sky130_fd_sc_hd__clkbuf_1 U445 ( .A(s_mtime_q[0]), .X(n258) );
  sky130_fd_sc_hd__o22ai_1 U446 ( .A1(n268), .A2(n333), .B1(n236), .B2(n433), 
        .Y(s_mtimecmp_d[7]) );
  sky130_fd_sc_hd__inv_2 U447 ( .A(s_mtimecmp_q[7]), .Y(n333) );
  sky130_fd_sc_hd__o22ai_1 U448 ( .A1(n268), .A2(n283), .B1(n237), .B2(n415), 
        .Y(s_mtimecmp_d[57]) );
  sky130_fd_sc_hd__inv_2 U449 ( .A(s_mtimecmp_q[57]), .Y(n283) );
  sky130_fd_sc_hd__o22ai_1 U450 ( .A1(n268), .A2(n281), .B1(n237), .B2(n413), 
        .Y(s_mtimecmp_d[59]) );
  sky130_fd_sc_hd__inv_2 U451 ( .A(s_mtimecmp_q[59]), .Y(n281) );
  sky130_fd_sc_hd__o22ai_1 U452 ( .A1(n268), .A2(n279), .B1(n237), .B2(n411), 
        .Y(s_mtimecmp_d[61]) );
  sky130_fd_sc_hd__inv_2 U453 ( .A(s_mtimecmp_q[61]), .Y(n279) );
  sky130_fd_sc_hd__o22ai_1 U454 ( .A1(n268), .A2(n277), .B1(n237), .B2(n409), 
        .Y(s_mtimecmp_d[63]) );
  sky130_fd_sc_hd__inv_2 U455 ( .A(s_mtimecmp_q[63]), .Y(n277) );
  sky130_fd_sc_hd__o22ai_1 U456 ( .A1(n264), .A2(n329), .B1(n236), .B2(n429), 
        .Y(s_mtimecmp_d[11]) );
  sky130_fd_sc_hd__inv_2 U457 ( .A(s_mtimecmp_q[11]), .Y(n329) );
  sky130_fd_sc_hd__o22ai_1 U458 ( .A1(n264), .A2(n327), .B1(n236), .B2(n427), 
        .Y(s_mtimecmp_d[13]) );
  sky130_fd_sc_hd__inv_2 U459 ( .A(s_mtimecmp_q[13]), .Y(n327) );
  sky130_fd_sc_hd__o22ai_1 U460 ( .A1(n264), .A2(n325), .B1(n236), .B2(n425), 
        .Y(s_mtimecmp_d[15]) );
  sky130_fd_sc_hd__inv_2 U461 ( .A(s_mtimecmp_q[15]), .Y(n325) );
  sky130_fd_sc_hd__o22ai_1 U462 ( .A1(n265), .A2(n319), .B1(n236), .B2(n419), 
        .Y(s_mtimecmp_d[21]) );
  sky130_fd_sc_hd__inv_2 U463 ( .A(s_mtimecmp_q[21]), .Y(n319) );
  sky130_fd_sc_hd__o22ai_1 U464 ( .A1(n265), .A2(n317), .B1(n236), .B2(n417), 
        .Y(s_mtimecmp_d[23]) );
  sky130_fd_sc_hd__inv_2 U465 ( .A(s_mtimecmp_q[23]), .Y(n317) );
  sky130_fd_sc_hd__o22ai_1 U466 ( .A1(n265), .A2(n313), .B1(n236), .B2(n413), 
        .Y(s_mtimecmp_d[27]) );
  sky130_fd_sc_hd__inv_2 U467 ( .A(s_mtimecmp_q[27]), .Y(n313) );
  sky130_fd_sc_hd__o22ai_1 U468 ( .A1(n265), .A2(n311), .B1(n236), .B2(n411), 
        .Y(s_mtimecmp_d[29]) );
  sky130_fd_sc_hd__inv_2 U469 ( .A(s_mtimecmp_q[29]), .Y(n311) );
  sky130_fd_sc_hd__o22ai_1 U470 ( .A1(n265), .A2(n309), .B1(n236), .B2(n409), 
        .Y(s_mtimecmp_d[31]) );
  sky130_fd_sc_hd__inv_2 U471 ( .A(s_mtimecmp_q[31]), .Y(n309) );
  sky130_fd_sc_hd__o22ai_1 U472 ( .A1(n266), .A2(n305), .B1(n237), .B2(n437), 
        .Y(s_mtimecmp_d[35]) );
  sky130_fd_sc_hd__inv_2 U473 ( .A(s_mtimecmp_q[35]), .Y(n305) );
  sky130_fd_sc_hd__o22ai_1 U474 ( .A1(n266), .A2(n303), .B1(n237), .B2(n435), 
        .Y(s_mtimecmp_d[37]) );
  sky130_fd_sc_hd__inv_2 U475 ( .A(s_mtimecmp_q[37]), .Y(n303) );
  sky130_fd_sc_hd__o22ai_1 U476 ( .A1(n266), .A2(n301), .B1(n433), .B2(n237), 
        .Y(s_mtimecmp_d[39]) );
  sky130_fd_sc_hd__inv_2 U477 ( .A(s_mtimecmp_q[39]), .Y(n301) );
  sky130_fd_sc_hd__o22ai_1 U478 ( .A1(n266), .A2(n297), .B1(n237), .B2(n429), 
        .Y(s_mtimecmp_d[43]) );
  sky130_fd_sc_hd__inv_2 U479 ( .A(s_mtimecmp_q[43]), .Y(n297) );
  sky130_fd_sc_hd__o22ai_1 U480 ( .A1(n267), .A2(n295), .B1(n237), .B2(n427), 
        .Y(s_mtimecmp_d[45]) );
  sky130_fd_sc_hd__inv_2 U481 ( .A(s_mtimecmp_q[45]), .Y(n295) );
  sky130_fd_sc_hd__o22ai_1 U482 ( .A1(n267), .A2(n293), .B1(n237), .B2(n425), 
        .Y(s_mtimecmp_d[47]) );
  sky130_fd_sc_hd__inv_2 U483 ( .A(s_mtimecmp_q[47]), .Y(n293) );
  sky130_fd_sc_hd__o22ai_1 U484 ( .A1(n267), .A2(n289), .B1(n237), .B2(n421), 
        .Y(s_mtimecmp_d[51]) );
  sky130_fd_sc_hd__inv_2 U485 ( .A(s_mtimecmp_q[51]), .Y(n289) );
  sky130_fd_sc_hd__o22ai_1 U486 ( .A1(n267), .A2(n287), .B1(n237), .B2(n419), 
        .Y(s_mtimecmp_d[53]) );
  sky130_fd_sc_hd__inv_2 U487 ( .A(s_mtimecmp_q[53]), .Y(n287) );
  sky130_fd_sc_hd__o22ai_1 U488 ( .A1(n267), .A2(n285), .B1(n237), .B2(n417), 
        .Y(s_mtimecmp_d[55]) );
  sky130_fd_sc_hd__inv_2 U489 ( .A(s_mtimecmp_q[55]), .Y(n285) );
  sky130_fd_sc_hd__o22ai_1 U490 ( .A1(n264), .A2(n339), .B1(n236), .B2(n439), 
        .Y(s_mtimecmp_d[1]) );
  sky130_fd_sc_hd__inv_2 U491 ( .A(s_mtimecmp_q[1]), .Y(n339) );
  sky130_fd_sc_hd__o22ai_1 U492 ( .A1(n265), .A2(n308), .B1(n237), .B2(n440), 
        .Y(s_mtimecmp_d[32]) );
  sky130_fd_sc_hd__inv_2 U493 ( .A(s_mtimecmp_q[32]), .Y(n308) );
  sky130_fd_sc_hd__o22ai_1 U494 ( .A1(n266), .A2(n306), .B1(n237), .B2(n438), 
        .Y(s_mtimecmp_d[34]) );
  sky130_fd_sc_hd__inv_2 U495 ( .A(s_mtimecmp_q[34]), .Y(n306) );
  sky130_fd_sc_hd__o22ai_1 U496 ( .A1(n266), .A2(n304), .B1(n237), .B2(n436), 
        .Y(s_mtimecmp_d[36]) );
  sky130_fd_sc_hd__inv_2 U497 ( .A(s_mtimecmp_q[36]), .Y(n304) );
  sky130_fd_sc_hd__o22ai_1 U498 ( .A1(n266), .A2(n302), .B1(n434), .B2(n237), 
        .Y(s_mtimecmp_d[38]) );
  sky130_fd_sc_hd__inv_2 U499 ( .A(s_mtimecmp_q[38]), .Y(n302) );
  sky130_fd_sc_hd__o22ai_1 U500 ( .A1(n266), .A2(n298), .B1(n237), .B2(n430), 
        .Y(s_mtimecmp_d[42]) );
  sky130_fd_sc_hd__inv_2 U501 ( .A(s_mtimecmp_q[42]), .Y(n298) );
  sky130_fd_sc_hd__o22ai_1 U502 ( .A1(n266), .A2(n296), .B1(n237), .B2(n428), 
        .Y(s_mtimecmp_d[44]) );
  sky130_fd_sc_hd__inv_2 U503 ( .A(s_mtimecmp_q[44]), .Y(n296) );
  sky130_fd_sc_hd__o22ai_1 U504 ( .A1(n267), .A2(n294), .B1(n237), .B2(n426), 
        .Y(s_mtimecmp_d[46]) );
  sky130_fd_sc_hd__inv_2 U505 ( .A(s_mtimecmp_q[46]), .Y(n294) );
  sky130_fd_sc_hd__o22ai_1 U506 ( .A1(n267), .A2(n292), .B1(n237), .B2(n424), 
        .Y(s_mtimecmp_d[48]) );
  sky130_fd_sc_hd__inv_2 U507 ( .A(s_mtimecmp_q[48]), .Y(n292) );
  sky130_fd_sc_hd__o22ai_1 U508 ( .A1(n267), .A2(n291), .B1(n237), .B2(n423), 
        .Y(s_mtimecmp_d[49]) );
  sky130_fd_sc_hd__inv_2 U509 ( .A(s_mtimecmp_q[49]), .Y(n291) );
  sky130_fd_sc_hd__o22ai_1 U510 ( .A1(n267), .A2(n290), .B1(n237), .B2(n422), 
        .Y(s_mtimecmp_d[50]) );
  sky130_fd_sc_hd__inv_2 U511 ( .A(s_mtimecmp_q[50]), .Y(n290) );
  sky130_fd_sc_hd__o22ai_1 U512 ( .A1(n267), .A2(n288), .B1(n237), .B2(n420), 
        .Y(s_mtimecmp_d[52]) );
  sky130_fd_sc_hd__inv_2 U513 ( .A(s_mtimecmp_q[52]), .Y(n288) );
  sky130_fd_sc_hd__o22ai_1 U514 ( .A1(n267), .A2(n286), .B1(n237), .B2(n418), 
        .Y(s_mtimecmp_d[54]) );
  sky130_fd_sc_hd__inv_2 U515 ( .A(s_mtimecmp_q[54]), .Y(n286) );
  sky130_fd_sc_hd__o22ai_1 U516 ( .A1(n267), .A2(n284), .B1(n237), .B2(n416), 
        .Y(s_mtimecmp_d[56]) );
  sky130_fd_sc_hd__inv_2 U517 ( .A(s_mtimecmp_q[56]), .Y(n284) );
  sky130_fd_sc_hd__o22ai_1 U518 ( .A1(n268), .A2(n282), .B1(n237), .B2(n414), 
        .Y(s_mtimecmp_d[58]) );
  sky130_fd_sc_hd__inv_2 U519 ( .A(s_mtimecmp_q[58]), .Y(n282) );
  sky130_fd_sc_hd__o22ai_1 U520 ( .A1(n268), .A2(n280), .B1(n237), .B2(n412), 
        .Y(s_mtimecmp_d[60]) );
  sky130_fd_sc_hd__inv_2 U521 ( .A(s_mtimecmp_q[60]), .Y(n280) );
  sky130_fd_sc_hd__o22ai_1 U522 ( .A1(n268), .A2(n278), .B1(n237), .B2(n410), 
        .Y(s_mtimecmp_d[62]) );
  sky130_fd_sc_hd__inv_2 U523 ( .A(s_mtimecmp_q[62]), .Y(n278) );
  sky130_fd_sc_hd__o22ai_1 U524 ( .A1(n265), .A2(n338), .B1(n236), .B2(n438), 
        .Y(s_mtimecmp_d[2]) );
  sky130_fd_sc_hd__inv_2 U525 ( .A(s_mtimecmp_q[2]), .Y(n338) );
  sky130_fd_sc_hd__o22ai_1 U526 ( .A1(n266), .A2(n337), .B1(n236), .B2(n437), 
        .Y(s_mtimecmp_d[3]) );
  sky130_fd_sc_hd__inv_2 U527 ( .A(s_mtimecmp_q[3]), .Y(n337) );
  sky130_fd_sc_hd__o22ai_1 U528 ( .A1(n267), .A2(n336), .B1(n236), .B2(n436), 
        .Y(s_mtimecmp_d[4]) );
  sky130_fd_sc_hd__inv_2 U529 ( .A(s_mtimecmp_q[4]), .Y(n336) );
  sky130_fd_sc_hd__o22ai_1 U530 ( .A1(n268), .A2(n335), .B1(n236), .B2(n435), 
        .Y(s_mtimecmp_d[5]) );
  sky130_fd_sc_hd__inv_2 U531 ( .A(s_mtimecmp_q[5]), .Y(n335) );
  sky130_fd_sc_hd__o22ai_1 U532 ( .A1(n268), .A2(n334), .B1(n236), .B2(n434), 
        .Y(s_mtimecmp_d[6]) );
  sky130_fd_sc_hd__inv_2 U533 ( .A(s_mtimecmp_q[6]), .Y(n334) );
  sky130_fd_sc_hd__o22ai_1 U534 ( .A1(n264), .A2(n330), .B1(n236), .B2(n430), 
        .Y(s_mtimecmp_d[10]) );
  sky130_fd_sc_hd__inv_2 U535 ( .A(s_mtimecmp_q[10]), .Y(n330) );
  sky130_fd_sc_hd__o22ai_1 U536 ( .A1(n264), .A2(n328), .B1(n236), .B2(n428), 
        .Y(s_mtimecmp_d[12]) );
  sky130_fd_sc_hd__inv_2 U537 ( .A(s_mtimecmp_q[12]), .Y(n328) );
  sky130_fd_sc_hd__o22ai_1 U538 ( .A1(n264), .A2(n326), .B1(n236), .B2(n426), 
        .Y(s_mtimecmp_d[14]) );
  sky130_fd_sc_hd__inv_2 U539 ( .A(s_mtimecmp_q[14]), .Y(n326) );
  sky130_fd_sc_hd__o22ai_1 U540 ( .A1(n264), .A2(n320), .B1(n236), .B2(n420), 
        .Y(s_mtimecmp_d[20]) );
  sky130_fd_sc_hd__inv_2 U541 ( .A(s_mtimecmp_q[20]), .Y(n320) );
  sky130_fd_sc_hd__o22ai_1 U542 ( .A1(n265), .A2(n318), .B1(n236), .B2(n418), 
        .Y(s_mtimecmp_d[22]) );
  sky130_fd_sc_hd__inv_2 U543 ( .A(s_mtimecmp_q[22]), .Y(n318) );
  sky130_fd_sc_hd__o22ai_1 U544 ( .A1(n265), .A2(n314), .B1(n236), .B2(n414), 
        .Y(s_mtimecmp_d[26]) );
  sky130_fd_sc_hd__inv_2 U545 ( .A(s_mtimecmp_q[26]), .Y(n314) );
  sky130_fd_sc_hd__o22ai_1 U546 ( .A1(n265), .A2(n312), .B1(n236), .B2(n412), 
        .Y(s_mtimecmp_d[28]) );
  sky130_fd_sc_hd__inv_2 U547 ( .A(s_mtimecmp_q[28]), .Y(n312) );
  sky130_fd_sc_hd__o22ai_1 U548 ( .A1(n265), .A2(n310), .B1(n236), .B2(n410), 
        .Y(s_mtimecmp_d[30]) );
  sky130_fd_sc_hd__inv_2 U549 ( .A(s_mtimecmp_q[30]), .Y(n310) );
  sky130_fd_sc_hd__o22ai_1 U550 ( .A1(n264), .A2(n324), .B1(n236), .B2(n424), 
        .Y(s_mtimecmp_d[16]) );
  sky130_fd_sc_hd__inv_2 U551 ( .A(s_mtimecmp_q[16]), .Y(n324) );
  sky130_fd_sc_hd__o22ai_1 U552 ( .A1(n268), .A2(n332), .B1(n236), .B2(n432), 
        .Y(s_mtimecmp_d[8]) );
  sky130_fd_sc_hd__inv_2 U553 ( .A(s_mtimecmp_q[8]), .Y(n332) );
  sky130_fd_sc_hd__o22ai_1 U554 ( .A1(n265), .A2(n316), .B1(n236), .B2(n416), 
        .Y(s_mtimecmp_d[24]) );
  sky130_fd_sc_hd__inv_2 U555 ( .A(s_mtimecmp_q[24]), .Y(n316) );
  sky130_fd_sc_hd__o22ai_1 U556 ( .A1(n266), .A2(n300), .B1(n432), .B2(n237), 
        .Y(s_mtimecmp_d[40]) );
  sky130_fd_sc_hd__inv_2 U557 ( .A(s_mtimecmp_q[40]), .Y(n300) );
  sky130_fd_sc_hd__o22ai_1 U558 ( .A1(n264), .A2(n322), .B1(n236), .B2(n422), 
        .Y(s_mtimecmp_d[18]) );
  sky130_fd_sc_hd__inv_2 U559 ( .A(s_mtimecmp_q[18]), .Y(n322) );
  sky130_fd_sc_hd__o22ai_1 U560 ( .A1(n268), .A2(n331), .B1(n236), .B2(n431), 
        .Y(s_mtimecmp_d[9]) );
  sky130_fd_sc_hd__inv_2 U561 ( .A(s_mtimecmp_q[9]), .Y(n331) );
  sky130_fd_sc_hd__o22ai_1 U562 ( .A1(n264), .A2(n323), .B1(n236), .B2(n423), 
        .Y(s_mtimecmp_d[17]) );
  sky130_fd_sc_hd__inv_2 U563 ( .A(s_mtimecmp_q[17]), .Y(n323) );
  sky130_fd_sc_hd__o22ai_1 U564 ( .A1(n264), .A2(n321), .B1(n236), .B2(n421), 
        .Y(s_mtimecmp_d[19]) );
  sky130_fd_sc_hd__inv_2 U565 ( .A(s_mtimecmp_q[19]), .Y(n321) );
  sky130_fd_sc_hd__o22ai_1 U566 ( .A1(n265), .A2(n315), .B1(n236), .B2(n415), 
        .Y(s_mtimecmp_d[25]) );
  sky130_fd_sc_hd__inv_2 U567 ( .A(s_mtimecmp_q[25]), .Y(n315) );
  sky130_fd_sc_hd__o22ai_1 U568 ( .A1(n266), .A2(n307), .B1(n237), .B2(n439), 
        .Y(s_mtimecmp_d[33]) );
  sky130_fd_sc_hd__inv_2 U569 ( .A(s_mtimecmp_q[33]), .Y(n307) );
  sky130_fd_sc_hd__o22ai_1 U570 ( .A1(n266), .A2(n299), .B1(n431), .B2(n237), 
        .Y(s_mtimecmp_d[41]) );
  sky130_fd_sc_hd__inv_2 U571 ( .A(s_mtimecmp_q[41]), .Y(n299) );
  sky130_fd_sc_hd__o22ai_1 U572 ( .A1(n264), .A2(n340), .B1(n236), .B2(n440), 
        .Y(s_mtimecmp_d[0]) );
  sky130_fd_sc_hd__inv_2 U573 ( .A(s_mtimecmp_q[0]), .Y(n340) );
  sky130_fd_sc_hd__o2bb2ai_1 U574 ( .B1(n440), .B2(n178), .A1_N(n178), .A2_N(
        clint_sfr_irq_o), .Y(\s_msip_d[0] ) );
  sky130_fd_sc_hd__nor3_1 U575 ( .A(apb4_paddr[2]), .B(apb4_paddr[3]), .C(n406), .Y(n175) );
  sky130_fd_sc_hd__nor3_1 U576 ( .A(n408), .B(apb4_paddr[4]), .C(n407), .Y(
        n177) );
  sky130_fd_sc_hd__a221oi_1 U577 ( .A1(n260), .A2(s_mtimecmp_q[0]), .B1(n262), 
        .B2(s_mtimecmp_q[32]), .C1(n215), .Y(n214) );
  sky130_fd_sc_hd__nor3b_1 U578 ( .C_N(clint_sfr_irq_o), .A(n216), .B(n217), 
        .Y(n215) );
  sky130_fd_sc_hd__a22oi_1 U579 ( .A1(n262), .A2(s_mtimecmp_q[33]), .B1(n260), 
        .B2(s_mtimecmp_q[1]), .Y(n203) );
  sky130_fd_sc_hd__a22oi_1 U580 ( .A1(n262), .A2(s_mtimecmp_q[36]), .B1(n260), 
        .B2(s_mtimecmp_q[4]), .Y(n188) );
  sky130_fd_sc_hd__a22oi_1 U581 ( .A1(n262), .A2(s_mtimecmp_q[40]), .B1(n260), 
        .B2(s_mtimecmp_q[8]), .Y(n184) );
  sky130_fd_sc_hd__a22oi_1 U582 ( .A1(n262), .A2(s_mtimecmp_q[57]), .B1(n260), 
        .B2(s_mtimecmp_q[25]), .Y(n197) );
  sky130_fd_sc_hd__o221ai_1 U583 ( .A1(n369), .A2(n263), .B1(n400), .B2(n238), 
        .C1(n189), .Y(apb4_prdata[3]) );
  sky130_fd_sc_hd__a22oi_1 U584 ( .A1(n262), .A2(s_mtimecmp_q[35]), .B1(n260), 
        .B2(s_mtimecmp_q[3]), .Y(n189) );
  sky130_fd_sc_hd__o221ai_1 U585 ( .A1(n356), .A2(n263), .B1(n387), .B2(n238), 
        .C1(n207), .Y(apb4_prdata[16]) );
  sky130_fd_sc_hd__a22oi_1 U586 ( .A1(n262), .A2(s_mtimecmp_q[48]), .B1(n260), 
        .B2(s_mtimecmp_q[16]), .Y(n207) );
  sky130_fd_sc_hd__o221ai_1 U587 ( .A1(n353), .A2(n263), .B1(n244), .B2(n238), 
        .C1(n204), .Y(apb4_prdata[19]) );
  sky130_fd_sc_hd__a22oi_1 U588 ( .A1(n262), .A2(s_mtimecmp_q[51]), .B1(n260), 
        .B2(s_mtimecmp_q[19]), .Y(n204) );
  sky130_fd_sc_hd__o221ai_1 U589 ( .A1(n352), .A2(n263), .B1(n384), .B2(n238), 
        .C1(n202), .Y(apb4_prdata[20]) );
  sky130_fd_sc_hd__a22oi_1 U590 ( .A1(n262), .A2(s_mtimecmp_q[52]), .B1(n260), 
        .B2(s_mtimecmp_q[20]), .Y(n202) );
  sky130_fd_sc_hd__o221ai_1 U591 ( .A1(n350), .A2(n263), .B1(n382), .B2(n238), 
        .C1(n200), .Y(apb4_prdata[22]) );
  sky130_fd_sc_hd__a22oi_1 U592 ( .A1(n262), .A2(s_mtimecmp_q[54]), .B1(n260), 
        .B2(s_mtimecmp_q[22]), .Y(n200) );
  sky130_fd_sc_hd__o221ai_1 U593 ( .A1(n349), .A2(n263), .B1(n381), .B2(n238), 
        .C1(n199), .Y(apb4_prdata[23]) );
  sky130_fd_sc_hd__a22oi_1 U594 ( .A1(n262), .A2(s_mtimecmp_q[55]), .B1(n260), 
        .B2(s_mtimecmp_q[23]), .Y(n199) );
  sky130_fd_sc_hd__o221ai_1 U595 ( .A1(n344), .A2(n263), .B1(n376), .B2(n238), 
        .C1(n194), .Y(apb4_prdata[28]) );
  sky130_fd_sc_hd__a22oi_1 U596 ( .A1(n262), .A2(s_mtimecmp_q[60]), .B1(n260), 
        .B2(s_mtimecmp_q[28]), .Y(n194) );
  sky130_fd_sc_hd__o221ai_1 U597 ( .A1(n343), .A2(n263), .B1(n375), .B2(n238), 
        .C1(n193), .Y(apb4_prdata[29]) );
  sky130_fd_sc_hd__a22oi_1 U598 ( .A1(n262), .A2(s_mtimecmp_q[61]), .B1(n260), 
        .B2(s_mtimecmp_q[29]), .Y(n193) );
  sky130_fd_sc_hd__o221ai_1 U599 ( .A1(n342), .A2(n263), .B1(n374), .B2(n238), 
        .C1(n191), .Y(apb4_prdata[30]) );
  sky130_fd_sc_hd__a22oi_1 U600 ( .A1(n262), .A2(s_mtimecmp_q[62]), .B1(n260), 
        .B2(s_mtimecmp_q[30]), .Y(n191) );
  sky130_fd_sc_hd__o221ai_1 U601 ( .A1(n370), .A2(n263), .B1(n401), .B2(n238), 
        .C1(n192), .Y(apb4_prdata[2]) );
  sky130_fd_sc_hd__a22oi_1 U602 ( .A1(n262), .A2(s_mtimecmp_q[34]), .B1(n260), 
        .B2(s_mtimecmp_q[2]), .Y(n192) );
  sky130_fd_sc_hd__o221ai_1 U603 ( .A1(n367), .A2(n263), .B1(n398), .B2(n238), 
        .C1(n187), .Y(apb4_prdata[5]) );
  sky130_fd_sc_hd__a22oi_1 U604 ( .A1(n262), .A2(s_mtimecmp_q[37]), .B1(n260), 
        .B2(s_mtimecmp_q[5]), .Y(n187) );
  sky130_fd_sc_hd__o221ai_1 U605 ( .A1(n366), .A2(n263), .B1(n397), .B2(n238), 
        .C1(n186), .Y(apb4_prdata[6]) );
  sky130_fd_sc_hd__a22oi_1 U606 ( .A1(n262), .A2(s_mtimecmp_q[38]), .B1(n260), 
        .B2(s_mtimecmp_q[6]), .Y(n186) );
  sky130_fd_sc_hd__o221ai_1 U607 ( .A1(n365), .A2(n263), .B1(n396), .B2(n238), 
        .C1(n185), .Y(apb4_prdata[7]) );
  sky130_fd_sc_hd__a22oi_1 U608 ( .A1(n262), .A2(s_mtimecmp_q[39]), .B1(n260), 
        .B2(s_mtimecmp_q[7]), .Y(n185) );
  sky130_fd_sc_hd__o221ai_1 U609 ( .A1(n363), .A2(n263), .B1(n394), .B2(n238), 
        .C1(n181), .Y(apb4_prdata[9]) );
  sky130_fd_sc_hd__a22oi_1 U610 ( .A1(n262), .A2(s_mtimecmp_q[41]), .B1(n260), 
        .B2(s_mtimecmp_q[9]), .Y(n181) );
  sky130_fd_sc_hd__o221ai_1 U611 ( .A1(n362), .A2(n263), .B1(n393), .B2(n238), 
        .C1(n213), .Y(apb4_prdata[10]) );
  sky130_fd_sc_hd__a22oi_1 U612 ( .A1(n262), .A2(s_mtimecmp_q[42]), .B1(n260), 
        .B2(s_mtimecmp_q[10]), .Y(n213) );
  sky130_fd_sc_hd__o221ai_1 U613 ( .A1(n361), .A2(n263), .B1(n392), .B2(n238), 
        .C1(n212), .Y(apb4_prdata[11]) );
  sky130_fd_sc_hd__a22oi_1 U614 ( .A1(n262), .A2(s_mtimecmp_q[43]), .B1(n260), 
        .B2(s_mtimecmp_q[11]), .Y(n212) );
  sky130_fd_sc_hd__o221ai_1 U615 ( .A1(n360), .A2(n263), .B1(n391), .B2(n238), 
        .C1(n211), .Y(apb4_prdata[12]) );
  sky130_fd_sc_hd__a22oi_1 U616 ( .A1(n262), .A2(s_mtimecmp_q[44]), .B1(n260), 
        .B2(s_mtimecmp_q[12]), .Y(n211) );
  sky130_fd_sc_hd__o221ai_1 U617 ( .A1(n359), .A2(n263), .B1(n390), .B2(n238), 
        .C1(n210), .Y(apb4_prdata[13]) );
  sky130_fd_sc_hd__a22oi_1 U618 ( .A1(n262), .A2(s_mtimecmp_q[45]), .B1(n260), 
        .B2(s_mtimecmp_q[13]), .Y(n210) );
  sky130_fd_sc_hd__o221ai_1 U619 ( .A1(n358), .A2(n263), .B1(n389), .B2(n238), 
        .C1(n209), .Y(apb4_prdata[14]) );
  sky130_fd_sc_hd__a22oi_1 U620 ( .A1(n262), .A2(s_mtimecmp_q[46]), .B1(n260), 
        .B2(s_mtimecmp_q[14]), .Y(n209) );
  sky130_fd_sc_hd__o221ai_1 U621 ( .A1(n357), .A2(n263), .B1(n388), .B2(n238), 
        .C1(n208), .Y(apb4_prdata[15]) );
  sky130_fd_sc_hd__a22oi_1 U622 ( .A1(n262), .A2(s_mtimecmp_q[47]), .B1(n260), 
        .B2(s_mtimecmp_q[15]), .Y(n208) );
  sky130_fd_sc_hd__o221ai_1 U623 ( .A1(n355), .A2(n263), .B1(n386), .B2(n238), 
        .C1(n206), .Y(apb4_prdata[17]) );
  sky130_fd_sc_hd__a22oi_1 U624 ( .A1(n262), .A2(s_mtimecmp_q[49]), .B1(n260), 
        .B2(s_mtimecmp_q[17]), .Y(n206) );
  sky130_fd_sc_hd__o221ai_1 U625 ( .A1(n354), .A2(n263), .B1(n385), .B2(n238), 
        .C1(n205), .Y(apb4_prdata[18]) );
  sky130_fd_sc_hd__a22oi_1 U626 ( .A1(n262), .A2(s_mtimecmp_q[50]), .B1(n260), 
        .B2(s_mtimecmp_q[18]), .Y(n205) );
  sky130_fd_sc_hd__o221ai_1 U627 ( .A1(n351), .A2(n263), .B1(n383), .B2(n238), 
        .C1(n201), .Y(apb4_prdata[21]) );
  sky130_fd_sc_hd__a22oi_1 U628 ( .A1(n262), .A2(s_mtimecmp_q[53]), .B1(n260), 
        .B2(s_mtimecmp_q[21]), .Y(n201) );
  sky130_fd_sc_hd__o221ai_1 U629 ( .A1(n348), .A2(n263), .B1(n380), .B2(n238), 
        .C1(n198), .Y(apb4_prdata[24]) );
  sky130_fd_sc_hd__a22oi_1 U630 ( .A1(n262), .A2(s_mtimecmp_q[56]), .B1(n260), 
        .B2(s_mtimecmp_q[24]), .Y(n198) );
  sky130_fd_sc_hd__o221ai_1 U631 ( .A1(n346), .A2(n263), .B1(n378), .B2(n238), 
        .C1(n196), .Y(apb4_prdata[26]) );
  sky130_fd_sc_hd__a22oi_1 U632 ( .A1(n262), .A2(s_mtimecmp_q[58]), .B1(n260), 
        .B2(s_mtimecmp_q[26]), .Y(n196) );
  sky130_fd_sc_hd__o221ai_1 U633 ( .A1(n345), .A2(n263), .B1(n377), .B2(n238), 
        .C1(n195), .Y(apb4_prdata[27]) );
  sky130_fd_sc_hd__a22oi_1 U634 ( .A1(n262), .A2(s_mtimecmp_q[59]), .B1(n260), 
        .B2(s_mtimecmp_q[27]), .Y(n195) );
  sky130_fd_sc_hd__o221ai_1 U635 ( .A1(n341), .A2(n263), .B1(n373), .B2(n238), 
        .C1(n190), .Y(apb4_prdata[31]) );
  sky130_fd_sc_hd__a22oi_1 U636 ( .A1(n262), .A2(s_mtimecmp_q[63]), .B1(n260), 
        .B2(s_mtimecmp_q[31]), .Y(n190) );
  sky130_fd_sc_hd__inv_2 U637 ( .A(apb4_paddr[4]), .Y(n406) );
  sky130_fd_sc_hd__inv_2 U638 ( .A(apb4_paddr[2]), .Y(n408) );
  sky130_fd_sc_hd__inv_2 U639 ( .A(apb4_paddr[3]), .Y(n407) );
  sky130_fd_sc_hd__inv_2 U640 ( .A(apb4_pwdata[0]), .Y(n440) );
  sky130_fd_sc_hd__inv_2 U641 ( .A(apb4_pwdata[1]), .Y(n439) );
  sky130_fd_sc_hd__inv_2 U642 ( .A(apb4_pwdata[2]), .Y(n438) );
  sky130_fd_sc_hd__inv_2 U643 ( .A(apb4_pwdata[3]), .Y(n437) );
  sky130_fd_sc_hd__inv_2 U644 ( .A(apb4_pwdata[4]), .Y(n436) );
  sky130_fd_sc_hd__inv_2 U645 ( .A(apb4_pwdata[5]), .Y(n435) );
  sky130_fd_sc_hd__inv_2 U646 ( .A(apb4_pwdata[10]), .Y(n430) );
  sky130_fd_sc_hd__inv_2 U647 ( .A(apb4_pwdata[11]), .Y(n429) );
  sky130_fd_sc_hd__inv_2 U648 ( .A(apb4_pwdata[12]), .Y(n428) );
  sky130_fd_sc_hd__inv_2 U649 ( .A(apb4_pwdata[13]), .Y(n427) );
  sky130_fd_sc_hd__inv_2 U650 ( .A(apb4_pwdata[14]), .Y(n426) );
  sky130_fd_sc_hd__inv_2 U651 ( .A(apb4_pwdata[15]), .Y(n425) );
  sky130_fd_sc_hd__inv_2 U652 ( .A(apb4_pwdata[16]), .Y(n424) );
  sky130_fd_sc_hd__inv_2 U653 ( .A(apb4_pwdata[17]), .Y(n423) );
  sky130_fd_sc_hd__inv_2 U654 ( .A(apb4_pwdata[18]), .Y(n422) );
  sky130_fd_sc_hd__inv_2 U655 ( .A(apb4_pwdata[19]), .Y(n421) );
  sky130_fd_sc_hd__inv_2 U656 ( .A(apb4_pwdata[20]), .Y(n420) );
  sky130_fd_sc_hd__inv_2 U657 ( .A(apb4_pwdata[21]), .Y(n419) );
  sky130_fd_sc_hd__inv_2 U658 ( .A(apb4_pwdata[22]), .Y(n418) );
  sky130_fd_sc_hd__inv_2 U659 ( .A(apb4_pwdata[23]), .Y(n417) );
  sky130_fd_sc_hd__inv_2 U660 ( .A(apb4_pwdata[24]), .Y(n416) );
  sky130_fd_sc_hd__inv_2 U661 ( .A(apb4_pwdata[25]), .Y(n415) );
  sky130_fd_sc_hd__inv_2 U662 ( .A(apb4_pwdata[26]), .Y(n414) );
  sky130_fd_sc_hd__inv_2 U663 ( .A(apb4_pwdata[27]), .Y(n413) );
  sky130_fd_sc_hd__inv_2 U664 ( .A(apb4_pwdata[28]), .Y(n412) );
  sky130_fd_sc_hd__inv_2 U665 ( .A(apb4_pwdata[29]), .Y(n411) );
  sky130_fd_sc_hd__inv_2 U666 ( .A(apb4_pwdata[30]), .Y(n410) );
  sky130_fd_sc_hd__inv_2 U667 ( .A(apb4_pwdata[31]), .Y(n409) );
  sky130_fd_sc_hd__inv_2 U668 ( .A(apb4_pwdata[6]), .Y(n434) );
  sky130_fd_sc_hd__inv_2 U669 ( .A(apb4_pwdata[7]), .Y(n433) );
  sky130_fd_sc_hd__inv_2 U670 ( .A(apb4_pwdata[8]), .Y(n432) );
  sky130_fd_sc_hd__inv_2 U671 ( .A(apb4_pwdata[9]), .Y(n431) );
  sky130_fd_sc_hd__inv_2 U672 ( .A(apb4_paddr[5]), .Y(n405) );
  sky130_fd_sc_hd__conb_1 U673 ( .LO(n5), .HI(n6) );
  sky130_fd_sc_hd__inv_2 U674 ( .A(n381), .Y(n255) );
  sky130_fd_sc_hd__inv_2 U675 ( .A(n376), .Y(n256) );
  sky130_fd_sc_hd__mux2_2 U676 ( .A0(n258), .A1(N18), .S(n269), .X(
        s_mtime_d[0]) );
  sky130_fd_sc_hd__o221ai_1 U677 ( .A1(n372), .A2(n263), .B1(n403), .B2(n238), 
        .C1(n214), .Y(apb4_prdata[0]) );
  sky130_fd_sc_hd__o221ai_1 U678 ( .A1(n368), .A2(n263), .B1(n399), .B2(n238), 
        .C1(n188), .Y(apb4_prdata[4]) );
  sky130_fd_sc_hd__o221ai_1 U679 ( .A1(n371), .A2(n263), .B1(n402), .B2(n238), 
        .C1(n203), .Y(apb4_prdata[1]) );
  sky130_fd_sc_hd__inv_2 U680 ( .A(n368), .Y(n257) );
  sky130_fd_sc_hd__inv_1 U681 ( .A(s_mtime_q[4]), .Y(n399) );
  sky130_fd_sc_hd__inv_1 U682 ( .A(s_mtime_q[5]), .Y(n398) );
  sky130_fd_sc_hd__inv_2 U683 ( .A(n387), .Y(n259) );
  sky130_fd_sc_hd__mux2_2 U684 ( .A0(n218), .A1(N66), .S(n272), .X(
        s_mtime_d[48]) );
  sky130_fd_sc_hd__mux2_2 U685 ( .A0(s_mtime_q[47]), .A1(N65), .S(n272), .X(
        s_mtime_d[47]) );
  sky130_fd_sc_hd__mux2_2 U686 ( .A0(n219), .A1(N56), .S(n271), .X(
        s_mtime_d[38]) );
  sky130_fd_sc_hd__mux2_2 U687 ( .A0(s_mtime_q[46]), .A1(N64), .S(n272), .X(
        s_mtime_d[46]) );
  sky130_fd_sc_hd__mux2_2 U688 ( .A0(s_mtime_q[37]), .A1(N55), .S(n271), .X(
        s_mtime_d[37]) );
  sky130_fd_sc_hd__mux2_2 U689 ( .A0(s_mtime_q[45]), .A1(N63), .S(n272), .X(
        s_mtime_d[45]) );
  sky130_fd_sc_hd__mux2_2 U690 ( .A0(s_mtime_q[36]), .A1(N54), .S(n271), .X(
        s_mtime_d[36]) );
  sky130_fd_sc_hd__mux2_2 U691 ( .A0(s_mtime_q[44]), .A1(N62), .S(n272), .X(
        s_mtime_d[44]) );
  sky130_fd_sc_hd__mux2_2 U692 ( .A0(s_mtime_q[35]), .A1(N53), .S(n271), .X(
        s_mtime_d[35]) );
  sky130_fd_sc_hd__mux2_2 U693 ( .A0(s_mtime_q[43]), .A1(N61), .S(n272), .X(
        s_mtime_d[43]) );
  sky130_fd_sc_hd__mux2_2 U694 ( .A0(s_mtime_q[34]), .A1(N52), .S(n271), .X(
        s_mtime_d[34]) );
  sky130_fd_sc_hd__mux2_2 U695 ( .A0(s_mtime_q[42]), .A1(N60), .S(n272), .X(
        s_mtime_d[42]) );
  sky130_fd_sc_hd__mux2_2 U696 ( .A0(s_mtime_q[33]), .A1(N51), .S(n271), .X(
        s_mtime_d[33]) );
  sky130_fd_sc_hd__mux2_2 U697 ( .A0(s_mtime_q[39]), .A1(N57), .S(n272), .X(
        s_mtime_d[39]) );
  sky130_fd_sc_hd__inv_1 U698 ( .A(s_mtime_q[2]), .Y(n401) );
  sky130_fd_sc_hd__o221ai_1 U699 ( .A1(n347), .A2(n263), .B1(n379), .B2(n238), 
        .C1(n197), .Y(apb4_prdata[25]) );
  sky130_fd_sc_hd__mux2_2 U700 ( .A0(s_mtime_q[63]), .A1(N81), .S(n273), .X(
        s_mtime_d[63]) );
  sky130_fd_sc_hd__mux2_2 U701 ( .A0(n251), .A1(N40), .S(n270), .X(
        s_mtime_d[22]) );
  sky130_fd_sc_hd__mux2_2 U702 ( .A0(s_mtime_q[21]), .A1(N39), .S(n270), .X(
        s_mtime_d[21]) );
  sky130_fd_sc_hd__mux2_2 U703 ( .A0(n252), .A1(N38), .S(n270), .X(
        s_mtime_d[20]) );
  sky130_fd_sc_hd__mux2_2 U704 ( .A0(s_mtime_q[24]), .A1(N42), .S(n270), .X(
        s_mtime_d[24]) );
  sky130_fd_sc_hd__mux2_2 U705 ( .A0(s_mtime_q[28]), .A1(N46), .S(n271), .X(
        s_mtime_d[28]) );
  sky130_fd_sc_hd__mux2_2 U706 ( .A0(s_mtime_q[27]), .A1(N45), .S(n271), .X(
        s_mtime_d[27]) );
  sky130_fd_sc_hd__mux2_2 U707 ( .A0(s_mtime_q[26]), .A1(N44), .S(n271), .X(
        s_mtime_d[26]) );
  sky130_fd_sc_hd__mux2_2 U708 ( .A0(n250), .A1(N36), .S(n270), .X(
        s_mtime_d[18]) );
  sky130_fd_sc_hd__mux2_2 U709 ( .A0(s_mtime_q[59]), .A1(N77), .S(n273), .X(
        s_mtime_d[59]) );
  sky130_fd_sc_hd__mux2_2 U710 ( .A0(s_mtime_q[58]), .A1(N76), .S(n273), .X(
        s_mtime_d[58]) );
  sky130_fd_sc_hd__mux2_2 U711 ( .A0(s_mtime_q[55]), .A1(N73), .S(n273), .X(
        s_mtime_d[55]) );
  sky130_fd_sc_hd__mux2_2 U712 ( .A0(s_mtime_q[54]), .A1(N72), .S(n273), .X(
        s_mtime_d[54]) );
  sky130_fd_sc_hd__mux2_2 U713 ( .A0(s_mtime_q[53]), .A1(N71), .S(n273), .X(
        s_mtime_d[53]) );
  sky130_fd_sc_hd__mux2_2 U714 ( .A0(s_mtime_q[52]), .A1(N70), .S(n273), .X(
        s_mtime_d[52]) );
  sky130_fd_sc_hd__mux2_2 U715 ( .A0(s_mtime_q[51]), .A1(N69), .S(n272), .X(
        s_mtime_d[51]) );
  sky130_fd_sc_hd__mux2_2 U716 ( .A0(s_mtime_q[50]), .A1(N68), .S(n272), .X(
        s_mtime_d[50]) );
  sky130_fd_sc_hd__mux2_2 U717 ( .A0(s_mtime_q[49]), .A1(N67), .S(n272), .X(
        s_mtime_d[49]) );
  sky130_fd_sc_hd__mux2_2 U718 ( .A0(s_mtime_q[41]), .A1(N59), .S(n272), .X(
        s_mtime_d[41]) );
  sky130_fd_sc_hd__mux2_2 U719 ( .A0(s_mtime_q[23]), .A1(N41), .S(n270), .X(
        s_mtime_d[23]) );
  sky130_fd_sc_hd__o221ai_1 U720 ( .A1(n364), .A2(n263), .B1(n395), .B2(n238), 
        .C1(n184), .Y(apb4_prdata[8]) );
  sky130_fd_sc_hd__mux2_2 U721 ( .A0(s_mtime_q[31]), .A1(N49), .S(n271), .X(
        s_mtime_d[31]) );
  sky130_fd_sc_hd__mux2_2 U722 ( .A0(n240), .A1(N48), .S(n271), .X(
        s_mtime_d[30]) );
  sky130_fd_sc_hd__mux2_2 U723 ( .A0(n247), .A1(N47), .S(n271), .X(
        s_mtime_d[29]) );
  sky130_fd_sc_hd__mux2_2 U724 ( .A0(s_mtime_q[16]), .A1(N34), .S(n270), .X(
        s_mtime_d[16]) );
  sky130_fd_sc_hd__mux2_2 U725 ( .A0(n246), .A1(N43), .S(n270), .X(
        s_mtime_d[25]) );
  sky130_fd_sc_hd__mux2_2 U726 ( .A0(n245), .A1(N37), .S(n270), .X(
        s_mtime_d[19]) );
  sky130_fd_sc_hd__mux2_2 U727 ( .A0(n249), .A1(N35), .S(n270), .X(
        s_mtime_d[17]) );
  sky130_fd_sc_hd__inv_1 U728 ( .A(n258), .Y(n403) );
  sky130_fd_sc_hd__inv_1 U729 ( .A(s_mtime_q[1]), .Y(n402) );
  sky130_fd_sc_hd__mux2_2 U730 ( .A0(s_mtime_q[40]), .A1(N58), .S(n272), .X(
        s_mtime_d[40]) );
  sky130_fd_sc_hd__inv_1 U731 ( .A(n402), .Y(n274) );
  sky130_fd_sc_hd__mux2_1 U732 ( .A0(s_mtime_q[3]), .A1(N21), .S(n269), .X(
        s_mtime_d[3]) );
  sky130_fd_sc_hd__inv_1 U733 ( .A(n399), .Y(n275) );
  sky130_fd_sc_hd__inv_1 U734 ( .A(n398), .Y(n276) );
  sky130_fd_sc_hd__mux2_1 U735 ( .A0(n276), .A1(N23), .S(n269), .X(
        s_mtime_d[5]) );
  sky130_fd_sc_hd__mux2_1 U736 ( .A0(s_mtime_q[6]), .A1(N24), .S(n269), .X(
        s_mtime_d[6]) );
  sky130_fd_sc_hd__mux2_1 U737 ( .A0(s_mtime_q[7]), .A1(N25), .S(n269), .X(
        s_mtime_d[7]) );
  sky130_fd_sc_hd__mux2_1 U738 ( .A0(s_mtime_q[8]), .A1(N26), .S(n269), .X(
        s_mtime_d[8]) );
  sky130_fd_sc_hd__mux2_1 U739 ( .A0(s_mtime_q[10]), .A1(N28), .S(n269), .X(
        s_mtime_d[10]) );
  sky130_fd_sc_hd__mux2_1 U740 ( .A0(s_mtime_q[13]), .A1(N31), .S(n270), .X(
        s_mtime_d[13]) );
  sky130_fd_sc_hd__mux2_1 U741 ( .A0(s_mtime_q[14]), .A1(N32), .S(n270), .X(
        s_mtime_d[14]) );
  sky130_fd_sc_hd__mux2_1 U742 ( .A0(s_mtime_q[15]), .A1(N33), .S(n270), .X(
        s_mtime_d[15]) );
  sky130_fd_sc_hd__inv_1 U743 ( .A(s_mtime_q[32]), .Y(n372) );
  sky130_fd_sc_hd__inv_1 U744 ( .A(s_mtime_q[42]), .Y(n362) );
  sky130_fd_sc_hd__inv_1 U745 ( .A(s_mtime_q[10]), .Y(n393) );
  sky130_fd_sc_hd__inv_1 U746 ( .A(s_mtime_q[43]), .Y(n361) );
  sky130_fd_sc_hd__inv_1 U747 ( .A(s_mtime_q[11]), .Y(n392) );
  sky130_fd_sc_hd__inv_1 U748 ( .A(s_mtime_q[44]), .Y(n360) );
  sky130_fd_sc_hd__inv_1 U749 ( .A(s_mtime_q[12]), .Y(n391) );
  sky130_fd_sc_hd__inv_1 U750 ( .A(s_mtime_q[45]), .Y(n359) );
  sky130_fd_sc_hd__inv_1 U751 ( .A(s_mtime_q[13]), .Y(n390) );
  sky130_fd_sc_hd__inv_1 U752 ( .A(s_mtime_q[46]), .Y(n358) );
  sky130_fd_sc_hd__inv_1 U753 ( .A(s_mtime_q[14]), .Y(n389) );
  sky130_fd_sc_hd__inv_1 U754 ( .A(s_mtime_q[47]), .Y(n357) );
  sky130_fd_sc_hd__inv_1 U755 ( .A(s_mtime_q[15]), .Y(n388) );
  sky130_fd_sc_hd__inv_1 U756 ( .A(n218), .Y(n356) );
  sky130_fd_sc_hd__inv_1 U757 ( .A(s_mtime_q[16]), .Y(n387) );
  sky130_fd_sc_hd__inv_1 U758 ( .A(s_mtime_q[49]), .Y(n355) );
  sky130_fd_sc_hd__inv_1 U759 ( .A(n249), .Y(n386) );
  sky130_fd_sc_hd__inv_1 U760 ( .A(s_mtime_q[50]), .Y(n354) );
  sky130_fd_sc_hd__inv_1 U761 ( .A(n250), .Y(n385) );
  sky130_fd_sc_hd__inv_1 U762 ( .A(s_mtime_q[51]), .Y(n353) );
  sky130_fd_sc_hd__inv_1 U763 ( .A(s_mtime_q[33]), .Y(n371) );
  sky130_fd_sc_hd__inv_1 U764 ( .A(s_mtime_q[52]), .Y(n352) );
  sky130_fd_sc_hd__inv_1 U765 ( .A(s_mtime_q[20]), .Y(n384) );
  sky130_fd_sc_hd__inv_1 U766 ( .A(s_mtime_q[53]), .Y(n351) );
  sky130_fd_sc_hd__inv_1 U767 ( .A(s_mtime_q[21]), .Y(n383) );
  sky130_fd_sc_hd__inv_1 U768 ( .A(s_mtime_q[54]), .Y(n350) );
  sky130_fd_sc_hd__inv_1 U769 ( .A(s_mtime_q[22]), .Y(n382) );
  sky130_fd_sc_hd__inv_1 U770 ( .A(s_mtime_q[55]), .Y(n349) );
  sky130_fd_sc_hd__inv_1 U771 ( .A(s_mtime_q[23]), .Y(n381) );
  sky130_fd_sc_hd__inv_1 U772 ( .A(s_mtime_q[56]), .Y(n348) );
  sky130_fd_sc_hd__inv_1 U773 ( .A(s_mtime_q[24]), .Y(n380) );
  sky130_fd_sc_hd__inv_1 U774 ( .A(s_mtime_q[57]), .Y(n347) );
  sky130_fd_sc_hd__inv_1 U775 ( .A(n246), .Y(n379) );
  sky130_fd_sc_hd__inv_1 U776 ( .A(s_mtime_q[58]), .Y(n346) );
  sky130_fd_sc_hd__inv_1 U777 ( .A(s_mtime_q[26]), .Y(n378) );
  sky130_fd_sc_hd__inv_1 U778 ( .A(s_mtime_q[59]), .Y(n345) );
  sky130_fd_sc_hd__inv_1 U779 ( .A(s_mtime_q[27]), .Y(n377) );
  sky130_fd_sc_hd__inv_1 U780 ( .A(s_mtime_q[60]), .Y(n344) );
  sky130_fd_sc_hd__inv_1 U781 ( .A(s_mtime_q[28]), .Y(n376) );
  sky130_fd_sc_hd__inv_1 U782 ( .A(s_mtime_q[61]), .Y(n343) );
  sky130_fd_sc_hd__inv_1 U783 ( .A(s_mtime_q[29]), .Y(n375) );
  sky130_fd_sc_hd__inv_1 U784 ( .A(s_mtime_q[34]), .Y(n370) );
  sky130_fd_sc_hd__inv_1 U785 ( .A(s_mtime_q[62]), .Y(n342) );
  sky130_fd_sc_hd__inv_1 U786 ( .A(s_mtime_q[30]), .Y(n374) );
  sky130_fd_sc_hd__inv_1 U787 ( .A(s_mtime_q[63]), .Y(n341) );
  sky130_fd_sc_hd__inv_1 U788 ( .A(s_mtime_q[31]), .Y(n373) );
  sky130_fd_sc_hd__inv_1 U789 ( .A(s_mtime_q[35]), .Y(n369) );
  sky130_fd_sc_hd__inv_1 U790 ( .A(s_mtime_q[36]), .Y(n368) );
  sky130_fd_sc_hd__inv_1 U791 ( .A(s_mtime_q[37]), .Y(n367) );
  sky130_fd_sc_hd__inv_1 U792 ( .A(n219), .Y(n366) );
  sky130_fd_sc_hd__inv_1 U793 ( .A(s_mtime_q[6]), .Y(n397) );
  sky130_fd_sc_hd__inv_1 U794 ( .A(s_mtime_q[39]), .Y(n365) );
  sky130_fd_sc_hd__inv_1 U795 ( .A(s_mtime_q[7]), .Y(n396) );
  sky130_fd_sc_hd__inv_1 U796 ( .A(s_mtime_q[40]), .Y(n364) );
  sky130_fd_sc_hd__inv_1 U797 ( .A(s_mtime_q[8]), .Y(n395) );
  sky130_fd_sc_hd__inv_1 U798 ( .A(s_mtime_q[41]), .Y(n363) );
  sky130_fd_sc_hd__inv_1 U799 ( .A(n241), .Y(n394) );
endmodule

