/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 29 20:09:26 2025
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
  wire   \s_dat_d[0] , \s_dat_q[0] , n1;

  cdc_sync_STAGE2_DATA_WIDTH1 u_cdc_sync ( .clk_i(clk_i), .rst_n_i(rst_n_i), 
        .dat_i(dat_i[0]), .dat_o(\s_dat_d[0] ) );
  dffr_DATA_WIDTH1_3 u_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        \s_dat_d[0] ), .dat_o(\s_dat_q[0] ) );
  sky130_fd_sc_hd__inv_1 U1 ( .A(\s_dat_d[0] ), .Y(n1) );
  sky130_fd_sc_hd__and2_0 U2 ( .A(\s_dat_q[0] ), .B(n1), .X(fe_o[0]) );
endmodule


module dffr_DATA_WIDTH4_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [3:0] dat_i;
  output [3:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH10 ( clk_i, rst_n_i, dat_i, dat_o );
  input [9:0] dat_i;
  output [9:0] dat_o;
  input clk_i, rst_n_i;


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


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
endmodule


module dffr_DATA_WIDTH64 ( clk_i, rst_n_i, dat_i, dat_o );
  input [63:0] dat_i;
  output [63:0] dat_o;
  input clk_i, rst_n_i;
  wire   n6, n7, n8, n9;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[58]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n6), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[51]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfrbp_1 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[52]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(rst_n_i), .X(n9) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(rst_n_i), .X(n8) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(rst_n_i), .X(n7) );
endmodule


module fifo_DATA_WIDTH8_BUFFER_DEPTH8 ( clk_i, rst_n_i, flush_i, full_o, 
        empty_o, cnt_o, dat_i, push_i, dat_o, pop_i );
  output [3:0] cnt_o;
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i, flush_i, push_i, pop_i;
  output full_o, empty_o;
  wire   N23, N24, N25, net1459, net1463, net2995, net2997, net3006, net3007,
         net3009, net3010, net3012, net3013, net3014, net3017, net3018,
         net3026, net3027, net3029, net3030, net3031, net3033, net3049,
         net3057, net3059, net3064, net3072, net3079, net3081, net3086,
         net3094, net3100, net3102, net3119, net3120, net3122, net3127,
         net3128, net3129, net3131, net3135, net3136, net3137, net3143,
         net3144, net3145, net3149, net3150, net3153, net3155, net3165,
         net3239, net3244, net3269, net3273, net3281, net3280, \C245/net962 ,
         \C245/net963 , \C245/net965 , \C245/net966 , \C245/net973 ,
         \C245/net974 , \C245/net981 , \C245/net982 , net3056, net3016,
         net3163, net3146, net3061, net3058, net3053, net3015, net3078,
         net3108, net3107, net3083, net3080, net3075, net3051, net3038, n1, n2,
         n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17,
         n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31,
         n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
         n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73,
         n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87,
         n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153;
  wire   [63:0] s_mem_q;
  wire   [2:0] s_rd_ptr_d;
  wire   [2:0] s_wr_ptr_d;
  wire   [2:0] s_wr_ptr_q;
  wire   [3:0] s_cnt_d;
  wire   [63:0] s_mem_d;
  assign full_o = net1459;
  assign empty_o = net1463;

  dffr_DATA_WIDTH3_0 u_rd_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_rd_ptr_d), .dat_o({N25, N24, N23}) );
  dffr_DATA_WIDTH3_1 u_wr_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_wr_ptr_d), .dat_o(s_wr_ptr_q) );
  dffr_DATA_WIDTH4_1 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_cnt_d), .dat_o(cnt_o) );
  dffr_DATA_WIDTH64 u_mem_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_mem_d), .dat_o(s_mem_q) );
  sky130_fd_sc_hd__mux2i_1 U3 ( .A0(net3137), .A1(net3136), .S(n18), .Y(
        s_cnt_d[2]) );
  sky130_fd_sc_hd__clkinv_1 U4 ( .A(cnt_o[2]), .Y(n18) );
  sky130_fd_sc_hd__mux2i_1 U5 ( .A0(n63), .A1(n64), .S(n67), .Y(s_cnt_d[0]) );
  sky130_fd_sc_hd__clkinv_1 U6 ( .A(cnt_o[0]), .Y(n67) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(n122), .Y(n130) );
  sky130_fd_sc_hd__clkinv_2 U8 ( .A(n90), .Y(n96) );
  sky130_fd_sc_hd__clkinv_2 U9 ( .A(n22), .Y(n60) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n122), .Y(n59) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(net3146), .Y(net1459) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(n149), .Y(n151) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(net2995), .Y(net1463) );
  sky130_fd_sc_hd__inv_1 U14 ( .A(n21), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(N25), .Y(n52) );
  sky130_fd_sc_hd__nor2_1 U16 ( .A(n145), .B(N25), .Y(\C245/net965 ) );
  sky130_fd_sc_hd__nor2_1 U17 ( .A(N24), .B(N25), .Y(\C245/net966 ) );
  sky130_fd_sc_hd__nor2_1 U18 ( .A(n52), .B(n145), .Y(\C245/net963 ) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n52), .B(N24), .Y(\C245/net962 ) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(net3144), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U21 ( .A(n75), .Y(n76) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(net3150), .Y(net3135) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(dat_i[0]), .Y(n142) );
  sky130_fd_sc_hd__inv_1 U24 ( .A(dat_i[1]), .Y(n139) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(dat_i[2]), .Y(n137) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(dat_i[3]), .Y(net3027) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(dat_i[4]), .Y(net3029) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(dat_i[5]), .Y(net3031) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(dat_i[6]), .Y(net3033) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(dat_i[7]), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(net3007), .Y(net3012) );
  sky130_fd_sc_hd__inv_1 U32 ( .A(n65), .Y(n61) );
  sky130_fd_sc_hd__a21oi_1 U33 ( .A1(n70), .A2(n72), .B1(net3149), .Y(net3136)
         );
  sky130_fd_sc_hd__nor2_1 U34 ( .A(net3144), .B(net2997), .Y(net3149) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(N25), .Y(n153) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(net3006), .Y(net3013) );
  sky130_fd_sc_hd__inv_2 U37 ( .A(n73), .Y(n77) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(n148), .Y(n72) );
  sky130_fd_sc_hd__and2_1 U39 ( .A(s_wr_ptr_q[1]), .B(net3015), .X(n1) );
  sky130_fd_sc_hd__and2_1 U40 ( .A(s_wr_ptr_q[2]), .B(net3051), .X(n2) );
  sky130_fd_sc_hd__and2_1 U41 ( .A(net3051), .B(net3015), .X(n3) );
  sky130_fd_sc_hd__and2_1 U42 ( .A(s_wr_ptr_q[1]), .B(s_wr_ptr_q[2]), .X(n4)
         );
  sky130_fd_sc_hd__inv_2 U43 ( .A(net3017), .Y(net3165) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(net3165), .B(n62), .Y(n5) );
  sky130_fd_sc_hd__nand2_2 U45 ( .A(pop_i), .B(net2995), .Y(n62) );
  sky130_fd_sc_hd__nand2_2 U46 ( .A(n20), .B(net3129), .Y(net2995) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(net3107), .Y(net3038) );
  sky130_fd_sc_hd__clkinv_2 U48 ( .A(n132), .Y(n56) );
  sky130_fd_sc_hd__clkinv_1 U49 ( .A(n23), .Y(n6) );
  sky130_fd_sc_hd__clkinv_1 U50 ( .A(n23), .Y(n55) );
  sky130_fd_sc_hd__clkinv_1 U51 ( .A(n12), .Y(n7) );
  sky130_fd_sc_hd__clkinv_1 U52 ( .A(n12), .Y(net3075) );
  sky130_fd_sc_hd__clkinv_1 U53 ( .A(net3083), .Y(n8) );
  sky130_fd_sc_hd__clkinv_1 U54 ( .A(net3083), .Y(net3273) );
  sky130_fd_sc_hd__clkinv_1 U55 ( .A(n15), .Y(n9) );
  sky130_fd_sc_hd__clkinv_1 U56 ( .A(n15), .Y(net3053) );
  sky130_fd_sc_hd__clkinv_1 U57 ( .A(net3061), .Y(n10) );
  sky130_fd_sc_hd__clkinv_1 U58 ( .A(net3061), .Y(net3269) );
  sky130_fd_sc_hd__nand2_2 U59 ( .A(net3281), .B(n3), .Y(n132) );
  sky130_fd_sc_hd__o31ai_1 U60 ( .A1(net3145), .A2(flush_i), .A3(net1459), 
        .B1(n148), .Y(n11) );
  sky130_fd_sc_hd__nand2_2 U61 ( .A(n62), .B(net3010), .Y(n148) );
  sky130_fd_sc_hd__mux2i_1 U62 ( .A0(net3031), .A1(net3030), .S(n57), .Y(
        s_mem_d[5]) );
  sky130_fd_sc_hd__clkinv_1 U63 ( .A(n132), .Y(n141) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(net3038), .B(n2), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U65 ( .A(net3038), .B(n2), .Y(net3083) );
  sky130_fd_sc_hd__nand2_1 U66 ( .A(net3143), .B(n14), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U67 ( .A(net3165), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U68 ( .A(net3038), .B(n1), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(net3038), .B(n1), .Y(net3061) );
  sky130_fd_sc_hd__nand2_1 U70 ( .A(net3108), .B(n17), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U71 ( .A(net3108), .B(n17), .Y(net3107) );
  sky130_fd_sc_hd__o21ai_0 U72 ( .A1(n72), .A2(net3013), .B1(n5), .Y(n63) );
  sky130_fd_sc_hd__mux2i_1 U73 ( .A0(net3080), .A1(net3031), .S(n7), .Y(
        s_mem_d[37]) );
  sky130_fd_sc_hd__mux2i_1 U74 ( .A0(net3081), .A1(net3033), .S(net3075), .Y(
        s_mem_d[38]) );
  sky130_fd_sc_hd__mux2i_1 U75 ( .A0(net3079), .A1(net3029), .S(net3075), .Y(
        s_mem_d[36]) );
  sky130_fd_sc_hd__mux2i_1 U76 ( .A0(net3078), .A1(net3027), .S(n7), .Y(
        s_mem_d[35]) );
  sky130_fd_sc_hd__inv_1 U77 ( .A(s_mem_q[37]), .Y(net3080) );
  sky130_fd_sc_hd__nand2_1 U78 ( .A(net3049), .B(n2), .Y(net3094) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(s_wr_ptr_q[1]), .Y(net3051) );
  sky130_fd_sc_hd__a221oi_1 U80 ( .A1(s_mem_q[37]), .A2(\C245/net962 ), .B1(
        s_mem_q[53]), .B2(\C245/net963 ), .C1(\C245/net974 ), .Y(\C245/net973 ) );
  sky130_fd_sc_hd__inv_1 U81 ( .A(n16), .Y(net3280) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(n16), .Y(net3281) );
  sky130_fd_sc_hd__inv_1 U83 ( .A(s_wr_ptr_q[0]), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U84 ( .A(s_wr_ptr_q[2]), .B(n17), .Y(net3018) );
  sky130_fd_sc_hd__nand3_1 U85 ( .A(s_wr_ptr_q[2]), .B(net3010), .C(n17), .Y(
        net3016) );
  sky130_fd_sc_hd__a21oi_1 U86 ( .A1(net3010), .A2(n17), .B1(net3012), .Y(
        net3009) );
  sky130_fd_sc_hd__inv_1 U87 ( .A(net3163), .Y(net3108) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(net3108), .B(net3010), .Y(net3006) );
  sky130_fd_sc_hd__inv_1 U89 ( .A(net3163), .Y(net3120) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(s_mem_q[35]), .Y(net3078) );
  sky130_fd_sc_hd__a221oi_1 U91 ( .A1(s_mem_q[35]), .A2(\C245/net962 ), .B1(
        s_mem_q[51]), .B2(\C245/net963 ), .C1(\C245/net982 ), .Y(\C245/net981 ) );
  sky130_fd_sc_hd__mux2i_1 U92 ( .A0(net3058), .A1(net3031), .S(n9), .Y(
        s_mem_d[21]) );
  sky130_fd_sc_hd__mux2i_1 U93 ( .A0(net3059), .A1(net3033), .S(net3053), .Y(
        s_mem_d[22]) );
  sky130_fd_sc_hd__mux2i_1 U94 ( .A0(net3057), .A1(net3029), .S(net3053), .Y(
        s_mem_d[20]) );
  sky130_fd_sc_hd__mux2i_1 U95 ( .A0(net3056), .A1(net3027), .S(n9), .Y(
        s_mem_d[19]) );
  sky130_fd_sc_hd__inv_1 U96 ( .A(s_mem_q[21]), .Y(net3058) );
  sky130_fd_sc_hd__nand2_1 U97 ( .A(net3049), .B(n1), .Y(net3072) );
  sky130_fd_sc_hd__inv_1 U98 ( .A(s_wr_ptr_q[2]), .Y(net3015) );
  sky130_fd_sc_hd__o221ai_1 U99 ( .A1(net3014), .A2(net3006), .B1(net3007), 
        .B2(net3015), .C1(net3016), .Y(s_wr_ptr_d[2]) );
  sky130_fd_sc_hd__a22o_1 U100 ( .A1(s_mem_q[21]), .A2(\C245/net965 ), .B1(
        s_mem_q[5]), .B2(\C245/net966 ), .X(\C245/net974 ) );
  sky130_fd_sc_hd__nand2_1 U101 ( .A(push_i), .B(net3146), .Y(net3163) );
  sky130_fd_sc_hd__inv_1 U102 ( .A(push_i), .Y(net3145) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(push_i), .B(net3146), .Y(net3017) );
  sky130_fd_sc_hd__nand2_1 U104 ( .A(cnt_o[3]), .B(n20), .Y(net3146) );
  sky130_fd_sc_hd__nand2_1 U105 ( .A(n19), .B(n18), .Y(n21) );
  sky130_fd_sc_hd__o32ai_1 U106 ( .A1(n18), .A2(net3129), .A3(net3128), .B1(
        net3129), .B2(net3131), .Y(net3127) );
  sky130_fd_sc_hd__a32oi_1 U107 ( .A1(cnt_o[2]), .A2(net3129), .A3(net3135), 
        .B1(cnt_o[3]), .B2(n18), .Y(net3122) );
  sky130_fd_sc_hd__o21ai_1 U108 ( .A1(n19), .A2(net3135), .B1(net3155), .Y(
        net3153) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(net3143), .B(net3144), .Y(net3131) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(s_mem_q[19]), .Y(net3056) );
  sky130_fd_sc_hd__a22o_1 U111 ( .A1(s_mem_q[19]), .A2(\C245/net965 ), .B1(
        s_mem_q[3]), .B2(\C245/net966 ), .X(\C245/net982 ) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(net3120), .B(s_wr_ptr_q[0]), .Y(n22) );
  sky130_fd_sc_hd__nand2_1 U113 ( .A(net3120), .B(s_wr_ptr_q[0]), .Y(net3119)
         );
  sky130_fd_sc_hd__nand2_1 U114 ( .A(net3280), .B(n4), .Y(n23) );
  sky130_fd_sc_hd__nand2_1 U115 ( .A(net3280), .B(n4), .Y(n90) );
  sky130_fd_sc_hd__a22o_1 U116 ( .A1(s_mem_q[24]), .A2(\C245/net965 ), .B1(
        s_mem_q[8]), .B2(\C245/net966 ), .X(n24) );
  sky130_fd_sc_hd__a221oi_1 U117 ( .A1(s_mem_q[40]), .A2(\C245/net962 ), .B1(
        s_mem_q[56]), .B2(\C245/net963 ), .C1(n24), .Y(n27) );
  sky130_fd_sc_hd__a22o_1 U118 ( .A1(s_mem_q[16]), .A2(\C245/net965 ), .B1(
        s_mem_q[0]), .B2(\C245/net966 ), .X(n25) );
  sky130_fd_sc_hd__a221oi_1 U119 ( .A1(s_mem_q[32]), .A2(\C245/net962 ), .B1(
        s_mem_q[48]), .B2(\C245/net963 ), .C1(n25), .Y(n26) );
  sky130_fd_sc_hd__o22ai_1 U120 ( .A1(n146), .A2(n27), .B1(N23), .B2(n26), .Y(
        dat_o[0]) );
  sky130_fd_sc_hd__a22o_1 U121 ( .A1(s_mem_q[25]), .A2(\C245/net965 ), .B1(
        s_mem_q[9]), .B2(\C245/net966 ), .X(n28) );
  sky130_fd_sc_hd__a221oi_1 U122 ( .A1(s_mem_q[41]), .A2(\C245/net962 ), .B1(
        s_mem_q[57]), .B2(\C245/net963 ), .C1(n28), .Y(n31) );
  sky130_fd_sc_hd__a22o_1 U123 ( .A1(s_mem_q[17]), .A2(\C245/net965 ), .B1(
        s_mem_q[1]), .B2(\C245/net966 ), .X(n29) );
  sky130_fd_sc_hd__a221oi_1 U124 ( .A1(s_mem_q[33]), .A2(\C245/net962 ), .B1(
        s_mem_q[49]), .B2(\C245/net963 ), .C1(n29), .Y(n30) );
  sky130_fd_sc_hd__o22ai_1 U125 ( .A1(n146), .A2(n31), .B1(N23), .B2(n30), .Y(
        dat_o[1]) );
  sky130_fd_sc_hd__a22o_1 U126 ( .A1(s_mem_q[26]), .A2(\C245/net965 ), .B1(
        s_mem_q[10]), .B2(\C245/net966 ), .X(n32) );
  sky130_fd_sc_hd__a221oi_1 U127 ( .A1(s_mem_q[42]), .A2(\C245/net962 ), .B1(
        s_mem_q[58]), .B2(\C245/net963 ), .C1(n32), .Y(n35) );
  sky130_fd_sc_hd__a22o_1 U128 ( .A1(s_mem_q[18]), .A2(\C245/net965 ), .B1(
        s_mem_q[2]), .B2(\C245/net966 ), .X(n33) );
  sky130_fd_sc_hd__a221oi_1 U129 ( .A1(s_mem_q[34]), .A2(\C245/net962 ), .B1(
        s_mem_q[50]), .B2(\C245/net963 ), .C1(n33), .Y(n34) );
  sky130_fd_sc_hd__o22ai_1 U130 ( .A1(n146), .A2(n35), .B1(N23), .B2(n34), .Y(
        dat_o[2]) );
  sky130_fd_sc_hd__a22o_1 U131 ( .A1(s_mem_q[27]), .A2(\C245/net965 ), .B1(
        s_mem_q[11]), .B2(\C245/net966 ), .X(n36) );
  sky130_fd_sc_hd__a221oi_1 U132 ( .A1(s_mem_q[43]), .A2(\C245/net962 ), .B1(
        s_mem_q[59]), .B2(\C245/net963 ), .C1(n36), .Y(n37) );
  sky130_fd_sc_hd__o22ai_1 U133 ( .A1(n146), .A2(n37), .B1(N23), .B2(
        \C245/net981 ), .Y(dat_o[3]) );
  sky130_fd_sc_hd__a22o_1 U134 ( .A1(s_mem_q[28]), .A2(\C245/net965 ), .B1(
        s_mem_q[12]), .B2(\C245/net966 ), .X(n38) );
  sky130_fd_sc_hd__a221oi_1 U135 ( .A1(s_mem_q[44]), .A2(\C245/net962 ), .B1(
        s_mem_q[60]), .B2(\C245/net963 ), .C1(n38), .Y(n41) );
  sky130_fd_sc_hd__a22o_1 U136 ( .A1(s_mem_q[20]), .A2(\C245/net965 ), .B1(
        s_mem_q[4]), .B2(\C245/net966 ), .X(n39) );
  sky130_fd_sc_hd__a221oi_1 U137 ( .A1(s_mem_q[36]), .A2(\C245/net962 ), .B1(
        s_mem_q[52]), .B2(\C245/net963 ), .C1(n39), .Y(n40) );
  sky130_fd_sc_hd__o22ai_1 U138 ( .A1(n146), .A2(n41), .B1(N23), .B2(n40), .Y(
        dat_o[4]) );
  sky130_fd_sc_hd__a22o_1 U139 ( .A1(s_mem_q[29]), .A2(\C245/net965 ), .B1(
        s_mem_q[13]), .B2(\C245/net966 ), .X(n42) );
  sky130_fd_sc_hd__a221oi_1 U140 ( .A1(s_mem_q[45]), .A2(\C245/net962 ), .B1(
        s_mem_q[61]), .B2(\C245/net963 ), .C1(n42), .Y(n43) );
  sky130_fd_sc_hd__o22ai_1 U141 ( .A1(n146), .A2(n43), .B1(N23), .B2(
        \C245/net973 ), .Y(dat_o[5]) );
  sky130_fd_sc_hd__a22o_1 U142 ( .A1(s_mem_q[30]), .A2(\C245/net965 ), .B1(
        s_mem_q[14]), .B2(\C245/net966 ), .X(n44) );
  sky130_fd_sc_hd__a221oi_1 U143 ( .A1(s_mem_q[46]), .A2(\C245/net962 ), .B1(
        s_mem_q[62]), .B2(\C245/net963 ), .C1(n44), .Y(n47) );
  sky130_fd_sc_hd__a22o_1 U144 ( .A1(s_mem_q[22]), .A2(\C245/net965 ), .B1(
        s_mem_q[6]), .B2(\C245/net966 ), .X(n45) );
  sky130_fd_sc_hd__a221oi_1 U145 ( .A1(s_mem_q[38]), .A2(\C245/net962 ), .B1(
        s_mem_q[54]), .B2(\C245/net963 ), .C1(n45), .Y(n46) );
  sky130_fd_sc_hd__o22ai_1 U146 ( .A1(n146), .A2(n47), .B1(N23), .B2(n46), .Y(
        dat_o[6]) );
  sky130_fd_sc_hd__a22o_1 U147 ( .A1(s_mem_q[31]), .A2(\C245/net965 ), .B1(
        s_mem_q[15]), .B2(\C245/net966 ), .X(n48) );
  sky130_fd_sc_hd__a221oi_1 U148 ( .A1(s_mem_q[47]), .A2(\C245/net962 ), .B1(
        s_mem_q[63]), .B2(\C245/net963 ), .C1(n48), .Y(n51) );
  sky130_fd_sc_hd__a22o_1 U149 ( .A1(s_mem_q[23]), .A2(\C245/net965 ), .B1(
        s_mem_q[7]), .B2(\C245/net966 ), .X(n49) );
  sky130_fd_sc_hd__a221oi_1 U150 ( .A1(s_mem_q[39]), .A2(\C245/net962 ), .B1(
        s_mem_q[55]), .B2(\C245/net963 ), .C1(n49), .Y(n50) );
  sky130_fd_sc_hd__o22ai_1 U151 ( .A1(n51), .A2(n146), .B1(N23), .B2(n50), .Y(
        dat_o[7]) );
  sky130_fd_sc_hd__mux2i_1 U152 ( .A0(net3033), .A1(n135), .S(n57), .Y(
        s_mem_d[6]) );
  sky130_fd_sc_hd__and2_4 U153 ( .A(n60), .B(n4), .X(n53) );
  sky130_fd_sc_hd__and2_4 U154 ( .A(n60), .B(n4), .X(n54) );
  sky130_fd_sc_hd__inv_1 U155 ( .A(n13), .Y(net3155) );
  sky130_fd_sc_hd__nand2_1 U156 ( .A(net3281), .B(n3), .Y(n57) );
  sky130_fd_sc_hd__clkinv_1 U157 ( .A(net3119), .Y(net3049) );
  sky130_fd_sc_hd__inv_2 U158 ( .A(n122), .Y(n58) );
  sky130_fd_sc_hd__mux2i_1 U159 ( .A0(net3029), .A1(n136), .S(n57), .Y(
        s_mem_d[4]) );
  sky130_fd_sc_hd__nor2_1 U160 ( .A(n14), .B(net3150), .Y(n70) );
  sky130_fd_sc_hd__nand2_1 U161 ( .A(net3017), .B(net3143), .Y(net3128) );
  sky130_fd_sc_hd__nand2_2 U162 ( .A(n67), .B(n71), .Y(net3144) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(cnt_o[1]), .Y(n71) );
  sky130_fd_sc_hd__nand2_4 U164 ( .A(n152), .B(net3010), .Y(net2997) );
  sky130_fd_sc_hd__inv_2 U165 ( .A(n62), .Y(n152) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(net3094), .Y(net3244) );
  sky130_fd_sc_hd__inv_2 U167 ( .A(net3094), .Y(net3086) );
  sky130_fd_sc_hd__inv_2 U168 ( .A(net3072), .Y(net3239) );
  sky130_fd_sc_hd__inv_2 U169 ( .A(net3072), .Y(net3064) );
  sky130_fd_sc_hd__nand2_2 U170 ( .A(n60), .B(n3), .Y(n122) );
  sky130_fd_sc_hd__inv_1 U171 ( .A(cnt_o[3]), .Y(net3129) );
  sky130_fd_sc_hd__inv_1 U172 ( .A(flush_i), .Y(net3010) );
  sky130_fd_sc_hd__clkinv_2 U173 ( .A(net2997), .Y(net3143) );
  sky130_fd_sc_hd__nand2_1 U174 ( .A(net3165), .B(n72), .Y(n65) );
  sky130_fd_sc_hd__nor2_1 U175 ( .A(net3155), .B(n61), .Y(n64) );
  sky130_fd_sc_hd__nand2_1 U176 ( .A(net3165), .B(n62), .Y(n78) );
  sky130_fd_sc_hd__nor3_1 U177 ( .A(n65), .B(cnt_o[1]), .C(n67), .Y(n66) );
  sky130_fd_sc_hd__a31oi_1 U178 ( .A1(cnt_o[1]), .A2(n152), .A3(net3013), .B1(
        n66), .Y(n69) );
  sky130_fd_sc_hd__nand2_1 U179 ( .A(n72), .B(n67), .Y(n73) );
  sky130_fd_sc_hd__a32oi_1 U180 ( .A1(n72), .A2(cnt_o[1]), .A3(n78), .B1(n77), 
        .B2(cnt_o[1]), .Y(n68) );
  sky130_fd_sc_hd__nand2_1 U181 ( .A(cnt_o[1]), .B(cnt_o[0]), .Y(net3150) );
  sky130_fd_sc_hd__nand3_1 U182 ( .A(n69), .B(n68), .C(net3153), .Y(s_cnt_d[1]) );
  sky130_fd_sc_hd__o31ai_1 U183 ( .A1(net3145), .A2(flush_i), .A3(net1459), 
        .B1(n148), .Y(n79) );
  sky130_fd_sc_hd__nand2_1 U184 ( .A(n72), .B(n71), .Y(n75) );
  sky130_fd_sc_hd__nand2_1 U185 ( .A(net3131), .B(n75), .Y(n74) );
  sky130_fd_sc_hd__a211oi_2 U186 ( .A1(n5), .A2(n79), .B1(n74), .C1(n77), .Y(
        net3137) );
  sky130_fd_sc_hd__o21ai_1 U187 ( .A1(n77), .A2(n76), .B1(cnt_o[3]), .Y(n81)
         );
  sky130_fd_sc_hd__a31oi_1 U188 ( .A1(cnt_o[3]), .A2(n11), .A3(n78), .B1(
        net3127), .Y(n80) );
  sky130_fd_sc_hd__o311ai_1 U189 ( .A1(net3006), .A2(n152), .A3(net3122), .B1(
        n81), .C1(n80), .Y(s_cnt_d[3]) );
  sky130_fd_sc_hd__inv_1 U190 ( .A(s_mem_q[63]), .Y(n82) );
  sky130_fd_sc_hd__mux2i_1 U191 ( .A0(n82), .A1(n133), .S(n54), .Y(s_mem_d[63]) );
  sky130_fd_sc_hd__inv_1 U192 ( .A(s_mem_q[62]), .Y(n83) );
  sky130_fd_sc_hd__mux2i_1 U193 ( .A0(n83), .A1(net3033), .S(n54), .Y(
        s_mem_d[62]) );
  sky130_fd_sc_hd__inv_1 U194 ( .A(s_mem_q[61]), .Y(n84) );
  sky130_fd_sc_hd__mux2i_1 U195 ( .A0(n84), .A1(net3031), .S(n53), .Y(
        s_mem_d[61]) );
  sky130_fd_sc_hd__inv_1 U196 ( .A(s_mem_q[60]), .Y(n85) );
  sky130_fd_sc_hd__mux2i_1 U197 ( .A0(n85), .A1(net3029), .S(n54), .Y(
        s_mem_d[60]) );
  sky130_fd_sc_hd__inv_1 U198 ( .A(s_mem_q[59]), .Y(n86) );
  sky130_fd_sc_hd__mux2i_1 U199 ( .A0(n86), .A1(net3027), .S(n53), .Y(
        s_mem_d[59]) );
  sky130_fd_sc_hd__inv_1 U200 ( .A(s_mem_q[58]), .Y(n87) );
  sky130_fd_sc_hd__mux2i_1 U201 ( .A0(n87), .A1(n137), .S(n53), .Y(s_mem_d[58]) );
  sky130_fd_sc_hd__inv_1 U202 ( .A(s_mem_q[57]), .Y(n88) );
  sky130_fd_sc_hd__mux2i_1 U203 ( .A0(n88), .A1(n139), .S(n54), .Y(s_mem_d[57]) );
  sky130_fd_sc_hd__inv_1 U204 ( .A(s_mem_q[56]), .Y(n89) );
  sky130_fd_sc_hd__mux2i_1 U205 ( .A0(n89), .A1(n142), .S(n53), .Y(s_mem_d[56]) );
  sky130_fd_sc_hd__inv_1 U206 ( .A(s_mem_q[55]), .Y(n91) );
  sky130_fd_sc_hd__mux2i_1 U207 ( .A0(n91), .A1(n133), .S(n6), .Y(s_mem_d[55])
         );
  sky130_fd_sc_hd__inv_1 U208 ( .A(s_mem_q[54]), .Y(n92) );
  sky130_fd_sc_hd__mux2i_1 U209 ( .A0(n92), .A1(net3033), .S(n96), .Y(
        s_mem_d[54]) );
  sky130_fd_sc_hd__inv_1 U210 ( .A(s_mem_q[53]), .Y(net3102) );
  sky130_fd_sc_hd__mux2i_1 U211 ( .A0(net3102), .A1(net3031), .S(n96), .Y(
        s_mem_d[53]) );
  sky130_fd_sc_hd__inv_1 U212 ( .A(s_mem_q[52]), .Y(n93) );
  sky130_fd_sc_hd__mux2i_1 U213 ( .A0(n93), .A1(net3029), .S(n55), .Y(
        s_mem_d[52]) );
  sky130_fd_sc_hd__inv_1 U214 ( .A(s_mem_q[51]), .Y(net3100) );
  sky130_fd_sc_hd__mux2i_1 U215 ( .A0(net3100), .A1(net3027), .S(n96), .Y(
        s_mem_d[51]) );
  sky130_fd_sc_hd__inv_1 U216 ( .A(s_mem_q[50]), .Y(n94) );
  sky130_fd_sc_hd__mux2i_1 U217 ( .A0(n94), .A1(n137), .S(n96), .Y(s_mem_d[50]) );
  sky130_fd_sc_hd__inv_1 U218 ( .A(s_mem_q[49]), .Y(n95) );
  sky130_fd_sc_hd__mux2i_1 U219 ( .A0(n95), .A1(n139), .S(n6), .Y(s_mem_d[49])
         );
  sky130_fd_sc_hd__inv_1 U220 ( .A(s_mem_q[48]), .Y(n97) );
  sky130_fd_sc_hd__mux2i_1 U221 ( .A0(n97), .A1(n142), .S(n55), .Y(s_mem_d[48]) );
  sky130_fd_sc_hd__inv_1 U222 ( .A(s_mem_q[47]), .Y(n98) );
  sky130_fd_sc_hd__mux2i_1 U223 ( .A0(n98), .A1(n133), .S(net3244), .Y(
        s_mem_d[47]) );
  sky130_fd_sc_hd__inv_1 U224 ( .A(s_mem_q[46]), .Y(n99) );
  sky130_fd_sc_hd__mux2i_1 U225 ( .A0(n99), .A1(net3033), .S(net3086), .Y(
        s_mem_d[46]) );
  sky130_fd_sc_hd__inv_1 U226 ( .A(s_mem_q[45]), .Y(n100) );
  sky130_fd_sc_hd__mux2i_1 U227 ( .A0(n100), .A1(net3031), .S(net3086), .Y(
        s_mem_d[45]) );
  sky130_fd_sc_hd__inv_1 U228 ( .A(s_mem_q[44]), .Y(n101) );
  sky130_fd_sc_hd__mux2i_1 U229 ( .A0(n101), .A1(net3029), .S(net3086), .Y(
        s_mem_d[44]) );
  sky130_fd_sc_hd__inv_1 U230 ( .A(s_mem_q[43]), .Y(n102) );
  sky130_fd_sc_hd__mux2i_1 U231 ( .A0(n102), .A1(net3027), .S(net3244), .Y(
        s_mem_d[43]) );
  sky130_fd_sc_hd__inv_1 U232 ( .A(s_mem_q[42]), .Y(n103) );
  sky130_fd_sc_hd__mux2i_1 U233 ( .A0(n103), .A1(n137), .S(net3086), .Y(
        s_mem_d[42]) );
  sky130_fd_sc_hd__inv_1 U234 ( .A(s_mem_q[41]), .Y(n104) );
  sky130_fd_sc_hd__mux2i_1 U235 ( .A0(n104), .A1(n139), .S(net3244), .Y(
        s_mem_d[41]) );
  sky130_fd_sc_hd__inv_1 U236 ( .A(s_mem_q[40]), .Y(n105) );
  sky130_fd_sc_hd__mux2i_1 U237 ( .A0(n105), .A1(n142), .S(net3244), .Y(
        s_mem_d[40]) );
  sky130_fd_sc_hd__inv_1 U238 ( .A(s_mem_q[39]), .Y(n106) );
  sky130_fd_sc_hd__mux2i_1 U239 ( .A0(n106), .A1(n133), .S(n8), .Y(s_mem_d[39]) );
  sky130_fd_sc_hd__inv_1 U240 ( .A(s_mem_q[38]), .Y(net3081) );
  sky130_fd_sc_hd__inv_1 U241 ( .A(s_mem_q[36]), .Y(net3079) );
  sky130_fd_sc_hd__inv_1 U242 ( .A(s_mem_q[34]), .Y(n107) );
  sky130_fd_sc_hd__mux2i_1 U243 ( .A0(n107), .A1(n137), .S(n8), .Y(s_mem_d[34]) );
  sky130_fd_sc_hd__inv_1 U244 ( .A(s_mem_q[33]), .Y(n108) );
  sky130_fd_sc_hd__mux2i_1 U245 ( .A0(n108), .A1(n139), .S(net3273), .Y(
        s_mem_d[33]) );
  sky130_fd_sc_hd__inv_1 U246 ( .A(s_mem_q[32]), .Y(n109) );
  sky130_fd_sc_hd__mux2i_1 U247 ( .A0(n109), .A1(n142), .S(net3273), .Y(
        s_mem_d[32]) );
  sky130_fd_sc_hd__inv_1 U248 ( .A(s_mem_q[31]), .Y(n110) );
  sky130_fd_sc_hd__mux2i_1 U249 ( .A0(n110), .A1(n133), .S(net3239), .Y(
        s_mem_d[31]) );
  sky130_fd_sc_hd__inv_1 U250 ( .A(s_mem_q[30]), .Y(n111) );
  sky130_fd_sc_hd__mux2i_1 U251 ( .A0(n111), .A1(net3033), .S(net3064), .Y(
        s_mem_d[30]) );
  sky130_fd_sc_hd__inv_1 U252 ( .A(s_mem_q[29]), .Y(n112) );
  sky130_fd_sc_hd__mux2i_1 U253 ( .A0(n112), .A1(net3031), .S(net3064), .Y(
        s_mem_d[29]) );
  sky130_fd_sc_hd__inv_1 U254 ( .A(s_mem_q[28]), .Y(n113) );
  sky130_fd_sc_hd__mux2i_1 U255 ( .A0(n113), .A1(net3029), .S(net3064), .Y(
        s_mem_d[28]) );
  sky130_fd_sc_hd__inv_1 U256 ( .A(s_mem_q[27]), .Y(n114) );
  sky130_fd_sc_hd__mux2i_1 U257 ( .A0(n114), .A1(net3027), .S(net3064), .Y(
        s_mem_d[27]) );
  sky130_fd_sc_hd__inv_1 U258 ( .A(s_mem_q[26]), .Y(n115) );
  sky130_fd_sc_hd__mux2i_1 U259 ( .A0(n115), .A1(n137), .S(net3239), .Y(
        s_mem_d[26]) );
  sky130_fd_sc_hd__inv_1 U260 ( .A(s_mem_q[25]), .Y(n116) );
  sky130_fd_sc_hd__mux2i_1 U261 ( .A0(n116), .A1(n139), .S(net3239), .Y(
        s_mem_d[25]) );
  sky130_fd_sc_hd__inv_1 U262 ( .A(s_mem_q[24]), .Y(n117) );
  sky130_fd_sc_hd__mux2i_1 U263 ( .A0(n117), .A1(n142), .S(net3239), .Y(
        s_mem_d[24]) );
  sky130_fd_sc_hd__inv_1 U264 ( .A(s_mem_q[23]), .Y(n118) );
  sky130_fd_sc_hd__mux2i_1 U265 ( .A0(n118), .A1(n133), .S(n10), .Y(
        s_mem_d[23]) );
  sky130_fd_sc_hd__inv_1 U266 ( .A(s_mem_q[22]), .Y(net3059) );
  sky130_fd_sc_hd__inv_1 U267 ( .A(s_mem_q[20]), .Y(net3057) );
  sky130_fd_sc_hd__inv_1 U268 ( .A(s_mem_q[18]), .Y(n119) );
  sky130_fd_sc_hd__mux2i_1 U269 ( .A0(n119), .A1(n137), .S(n10), .Y(
        s_mem_d[18]) );
  sky130_fd_sc_hd__inv_1 U270 ( .A(s_mem_q[17]), .Y(n120) );
  sky130_fd_sc_hd__mux2i_1 U271 ( .A0(n120), .A1(n139), .S(net3269), .Y(
        s_mem_d[17]) );
  sky130_fd_sc_hd__inv_1 U272 ( .A(s_mem_q[16]), .Y(n121) );
  sky130_fd_sc_hd__mux2i_1 U273 ( .A0(n121), .A1(n142), .S(net3269), .Y(
        s_mem_d[16]) );
  sky130_fd_sc_hd__inv_1 U274 ( .A(s_mem_q[15]), .Y(n123) );
  sky130_fd_sc_hd__mux2i_1 U275 ( .A0(n123), .A1(n133), .S(n59), .Y(
        s_mem_d[15]) );
  sky130_fd_sc_hd__inv_1 U276 ( .A(s_mem_q[14]), .Y(n124) );
  sky130_fd_sc_hd__mux2i_1 U277 ( .A0(n124), .A1(net3033), .S(n58), .Y(
        s_mem_d[14]) );
  sky130_fd_sc_hd__inv_1 U278 ( .A(s_mem_q[13]), .Y(n125) );
  sky130_fd_sc_hd__mux2i_1 U279 ( .A0(n125), .A1(net3031), .S(n59), .Y(
        s_mem_d[13]) );
  sky130_fd_sc_hd__inv_1 U280 ( .A(s_mem_q[12]), .Y(n126) );
  sky130_fd_sc_hd__mux2i_1 U281 ( .A0(n126), .A1(net3029), .S(n130), .Y(
        s_mem_d[12]) );
  sky130_fd_sc_hd__inv_1 U282 ( .A(s_mem_q[11]), .Y(n127) );
  sky130_fd_sc_hd__mux2i_1 U283 ( .A0(n127), .A1(net3027), .S(n58), .Y(
        s_mem_d[11]) );
  sky130_fd_sc_hd__inv_1 U284 ( .A(s_mem_q[10]), .Y(n128) );
  sky130_fd_sc_hd__mux2i_1 U285 ( .A0(n128), .A1(n137), .S(n59), .Y(
        s_mem_d[10]) );
  sky130_fd_sc_hd__inv_1 U286 ( .A(s_mem_q[9]), .Y(n129) );
  sky130_fd_sc_hd__mux2i_1 U287 ( .A0(n129), .A1(n139), .S(n130), .Y(
        s_mem_d[9]) );
  sky130_fd_sc_hd__inv_1 U288 ( .A(s_mem_q[8]), .Y(n131) );
  sky130_fd_sc_hd__mux2i_1 U289 ( .A0(n131), .A1(n142), .S(n58), .Y(s_mem_d[8]) );
  sky130_fd_sc_hd__inv_1 U290 ( .A(s_mem_q[7]), .Y(n134) );
  sky130_fd_sc_hd__mux2i_1 U291 ( .A0(n134), .A1(n133), .S(n56), .Y(s_mem_d[7]) );
  sky130_fd_sc_hd__inv_1 U292 ( .A(s_mem_q[6]), .Y(n135) );
  sky130_fd_sc_hd__inv_1 U293 ( .A(s_mem_q[5]), .Y(net3030) );
  sky130_fd_sc_hd__inv_1 U294 ( .A(s_mem_q[4]), .Y(n136) );
  sky130_fd_sc_hd__inv_1 U295 ( .A(s_mem_q[3]), .Y(net3026) );
  sky130_fd_sc_hd__mux2i_1 U296 ( .A0(net3026), .A1(net3027), .S(n56), .Y(
        s_mem_d[3]) );
  sky130_fd_sc_hd__inv_1 U297 ( .A(s_mem_q[2]), .Y(n138) );
  sky130_fd_sc_hd__mux2i_1 U298 ( .A0(n138), .A1(n137), .S(n141), .Y(
        s_mem_d[2]) );
  sky130_fd_sc_hd__inv_1 U299 ( .A(s_mem_q[1]), .Y(n140) );
  sky130_fd_sc_hd__mux2i_1 U300 ( .A0(n140), .A1(n139), .S(n56), .Y(s_mem_d[1]) );
  sky130_fd_sc_hd__inv_1 U301 ( .A(s_mem_q[0]), .Y(n143) );
  sky130_fd_sc_hd__mux2i_1 U302 ( .A0(n143), .A1(n142), .S(n141), .Y(
        s_mem_d[0]) );
  sky130_fd_sc_hd__mux2i_1 U303 ( .A0(s_wr_ptr_q[2]), .A1(net3018), .S(
        s_wr_ptr_q[1]), .Y(net3014) );
  sky130_fd_sc_hd__nand2_1 U304 ( .A(net3017), .B(net3010), .Y(net3007) );
  sky130_fd_sc_hd__nand2_1 U305 ( .A(s_wr_ptr_q[0]), .B(net3013), .Y(n144) );
  sky130_fd_sc_hd__mux2i_1 U306 ( .A0(n144), .A1(net3009), .S(s_wr_ptr_q[1]), 
        .Y(s_wr_ptr_d[1]) );
  sky130_fd_sc_hd__mux2i_1 U307 ( .A0(net3006), .A1(net3007), .S(s_wr_ptr_q[0]), .Y(s_wr_ptr_d[0]) );
  sky130_fd_sc_hd__inv_1 U308 ( .A(N23), .Y(n146) );
  sky130_fd_sc_hd__inv_1 U309 ( .A(N24), .Y(n145) );
  sky130_fd_sc_hd__nor2_1 U310 ( .A(n146), .B(n145), .Y(n147) );
  sky130_fd_sc_hd__mux2i_1 U311 ( .A0(n145), .A1(n147), .S(n153), .Y(n150) );
  sky130_fd_sc_hd__o21ai_1 U312 ( .A1(net2997), .A2(N23), .B1(n148), .Y(n149)
         );
  sky130_fd_sc_hd__o22ai_1 U313 ( .A1(n150), .A2(net2997), .B1(n153), .B2(n151), .Y(s_rd_ptr_d[2]) );
  sky130_fd_sc_hd__o32ai_1 U314 ( .A1(N24), .A2(n146), .A3(net2997), .B1(n145), 
        .B2(n151), .Y(s_rd_ptr_d[1]) );
  sky130_fd_sc_hd__o32ai_1 U315 ( .A1(flush_i), .A2(n146), .A3(n152), .B1(N23), 
        .B2(net2997), .Y(s_rd_ptr_d[0]) );
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
         n38, n39, n41, n43, n44, n46, n47, n50, n56, n57, net1433, net3170,
         net3171, net3172, net3173, net3177, net3178, net3189, net3190,
         net3191, net3192, net3194, net3248, net3296, net3226, net3225,
         net3201, net3200, net3199, net3198, net3197, net3202, apb4_pslverr,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86;
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
        apb4_pwdata[1]), .B2(n84), .X(s_ps2_ctrl_d[1]) );
  sky130_fd_sc_hd__a22o_1 U44 ( .A1(n19), .A2(s_ps2_ctrl_q[0]), .B1(
        apb4_pwdata[0]), .B2(n84), .X(s_ps2_ctrl_d[0]) );
  sky130_fd_sc_hd__nand4_1 U45 ( .A(n20), .B(apb4_psel), .C(apb4_pwrite), .D(
        n21), .Y(n19) );
  sky130_fd_sc_hd__nand2_1 U55 ( .A(s_cnt_q[0]), .B(n33), .Y(n32) );
  sky130_fd_sc_hd__and3_1 U57 ( .A(s_falledge), .B(s_cnt_q[3]), .C(n35), .X(
        n33) );
  sky130_fd_sc_hd__or2_0 U58 ( .A(n37), .B(n38), .X(n36) );
  sky130_fd_sc_hd__nand2_1 U65 ( .A(n44), .B(n35), .Y(n50) );
  sky130_fd_sc_hd__nand2_1 U66 ( .A(s_falledge), .B(n83), .Y(n37) );
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
  sky130_fd_sc_hd__a32o_1 U77 ( .A1(n16), .A2(n85), .A3(s_ps2_ctrl_q[1]), .B1(
        s_fifo_rd_dat[1]), .B2(n59), .X(apb4_prdata[1]) );
  sky130_fd_sc_hd__a22o_1 U78 ( .A1(s_fifo_rd_dat[0]), .A2(n59), .B1(n16), 
        .B2(n56), .X(apb4_prdata[0]) );
  sky130_fd_sc_hd__a22o_1 U79 ( .A1(n85), .A2(s_ps2_ctrl_q[0]), .B1(
        apb4_paddr[3]), .B2(ps2_irq_o), .X(n56) );
  sky130_fd_sc_hd__and3b_1 U80 ( .B(n57), .C(n20), .A_N(apb4_paddr[2]), .X(n16) );
  sky130_fd_sc_hd__and4_1 U82 ( .A(apb4_paddr[2]), .B(n20), .C(n57), .D(n85), 
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
        {net3248, s_dat_q[7:1]}), .push_i(s_fifo_push_valid), .dat_o(
        s_fifo_rd_dat), .pop_i(n_1_net_) );
  dffr_DATA_WIDTH1_0 u_ps2_stat_dffr ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .dat_i(\s_ps2_stat_d[0] ), .dat_o(ps2_irq_o) );
  sky130_fd_sc_hd__inv_2 U83 ( .A(s_dat_q[0]), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U84 ( .A(n81), .Y(n76) );
  sky130_fd_sc_hd__inv_1 U85 ( .A(s_cnt_q[3]), .Y(n83) );
  sky130_fd_sc_hd__nor3b_1 U86 ( .C_N(apb4_psel), .A(n86), .B(apb4_pwrite), 
        .Y(n57) );
  sky130_fd_sc_hd__inv_2 U87 ( .A(apb4_penable), .Y(n86) );
  sky130_fd_sc_hd__nor2_1 U88 ( .A(apb4_paddr[5]), .B(apb4_paddr[4]), .Y(n20)
         );
  sky130_fd_sc_hd__inv_2 U89 ( .A(apb4_paddr[3]), .Y(n85) );
  sky130_fd_sc_hd__nor3_1 U90 ( .A(n86), .B(apb4_paddr[3]), .C(apb4_paddr[2]), 
        .Y(n21) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(n19), .Y(n84) );
  sky130_fd_sc_hd__a41oi_1 U92 ( .A1(s_ps2_ctrl_q[1]), .A2(ps2_irq_o), .A3(
        apb4_paddr[3]), .A4(n16), .B1(n17), .Y(\s_ps2_stat_d[0] ) );
  sky130_fd_sc_hd__o2bb2ai_1 U93 ( .B1(net1433), .B2(n50), .A1_N(n50), .A2_N(
        s_dat_q[0]), .Y(s_dat_d[0]) );
  sky130_fd_sc_hd__o2bb2ai_1 U94 ( .B1(net1433), .B2(n43), .A1_N(n43), .A2_N(
        s_dat_q[4]), .Y(s_dat_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U95 ( .B1(net1433), .B2(n41), .A1_N(n41), .A2_N(
        s_dat_q[5]), .Y(s_dat_d[5]) );
  sky130_fd_sc_hd__inv_2 U96 ( .A(net3173), .Y(net3172) );
  sky130_fd_sc_hd__o2bb2ai_1 U97 ( .B1(net1433), .B2(n39), .A1_N(n39), .A2_N(
        s_dat_q[6]), .Y(s_dat_d[6]) );
  sky130_fd_sc_hd__inv_2 U98 ( .A(net3171), .Y(net3170) );
  sky130_fd_sc_hd__o2bb2ai_1 U99 ( .B1(net1433), .B2(n36), .A1_N(n36), .A2_N(
        s_dat_q[7]), .Y(s_dat_d[7]) );
  sky130_fd_sc_hd__inv_2 U100 ( .A(n75), .Y(n77) );
  sky130_fd_sc_hd__and3_1 U101 ( .A(n_1_net_), .B(s_ps2_ctrl_q[1]), .C(n82), 
        .X(n59) );
  sky130_fd_sc_hd__nand2_1 U102 ( .A(n60), .B(n61), .Y(n63) );
  sky130_fd_sc_hd__nand2_1 U103 ( .A(n63), .B(n62), .Y(net3202) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(s_dat_q[9]), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(s_dat_q[8]), .Y(n60) );
  sky130_fd_sc_hd__dlygate4sd3_1 U106 ( .A(n60), .X(net3296) );
  sky130_fd_sc_hd__a2bb2o_1 U107 ( .A1_N(net1433), .A2_N(n32), .B1(s_dat_q[9]), 
        .B2(n32), .X(s_dat_d[9]) );
  sky130_fd_sc_hd__nand2_1 U108 ( .A(s_dat_q[8]), .B(s_dat_q[9]), .Y(n62) );
  sky130_fd_sc_hd__xnor2_1 U109 ( .A(s_dat_q[1]), .B(net3202), .Y(net3201) );
  sky130_fd_sc_hd__nor2_2 U110 ( .A(net3226), .B(net3197), .Y(
        s_fifo_push_valid) );
  sky130_fd_sc_hd__xnor2_1 U111 ( .A(net3198), .B(net3199), .Y(net3197) );
  sky130_fd_sc_hd__xnor2_1 U112 ( .A(net3201), .B(net3200), .Y(net3199) );
  sky130_fd_sc_hd__xnor2_1 U113 ( .A(s_dat_q[6]), .B(s_dat_q[7]), .Y(net3200)
         );
  sky130_fd_sc_hd__xnor2_1 U114 ( .A(n66), .B(n67), .Y(net3198) );
  sky130_fd_sc_hd__xor2_1 U115 ( .A(s_dat_q[3]), .B(s_dat_q[2]), .X(n67) );
  sky130_fd_sc_hd__xnor2_1 U116 ( .A(s_dat_q[4]), .B(s_dat_q[5]), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(net3225), .Y(net3226) );
  sky130_fd_sc_hd__nor2_1 U118 ( .A(n64), .B(n65), .Y(net3225) );
  sky130_fd_sc_hd__nand3_1 U119 ( .A(ps2_ps2_dat_i), .B(s_falledge), .C(
        s_ps2_ctrl_q[1]), .Y(n65) );
  sky130_fd_sc_hd__nand2_1 U120 ( .A(n68), .B(n69), .Y(n64) );
  sky130_fd_sc_hd__clkinv_1 U121 ( .A(net3177), .Y(n68) );
  sky130_fd_sc_hd__o21ai_0 U122 ( .A1(s_cnt_q[2]), .A2(net3173), .B1(
        s_dat_q[1]), .Y(net3191) );
  sky130_fd_sc_hd__o31ai_1 U123 ( .A1(n37), .A2(s_cnt_q[2]), .A3(n47), .B1(
        s_dat_q[3]), .Y(n46) );
  sky130_fd_sc_hd__o21ai_0 U124 ( .A1(s_cnt_q[2]), .A2(net3171), .B1(
        s_dat_q[2]), .Y(net3190) );
  sky130_fd_sc_hd__nand2_1 U125 ( .A(ps2_ps2_dat_i), .B(net3192), .Y(net3189)
         );
  sky130_fd_sc_hd__inv_1 U126 ( .A(ps2_ps2_dat_i), .Y(net1433) );
  sky130_fd_sc_hd__conb_1 U127 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__clkinv_2 U128 ( .A(s_cnt_q[0]), .Y(n74) );
  sky130_fd_sc_hd__nand4_4 U129 ( .A(s_cnt_q[3]), .B(s_cnt_q[1]), .C(n74), .D(
        net3192), .Y(net3177) );
  sky130_fd_sc_hd__nor2_1 U130 ( .A(n37), .B(s_cnt_q[0]), .Y(n44) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(net3296), .Y(net3248) );
  sky130_fd_sc_hd__clkinv_2 U132 ( .A(s_cnt_q[2]), .Y(net3192) );
  sky130_fd_sc_hd__nor2_1 U133 ( .A(s_cnt_q[2]), .B(s_cnt_q[1]), .Y(n35) );
  sky130_fd_sc_hd__or2b_1 U134 ( .A(n47), .B_N(s_cnt_q[2]), .X(n38) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(s_cnt_q[1]), .Y(n70) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(n37), .Y(net3194) );
  sky130_fd_sc_hd__nand3_1 U137 ( .A(s_cnt_q[0]), .B(n70), .C(net3194), .Y(
        net3173) );
  sky130_fd_sc_hd__o21ai_1 U138 ( .A1(net3173), .A2(net3189), .B1(net3191), 
        .Y(s_dat_d[1]) );
  sky130_fd_sc_hd__nand2_1 U139 ( .A(n44), .B(s_cnt_q[1]), .Y(net3171) );
  sky130_fd_sc_hd__o21ai_1 U140 ( .A1(net3171), .A2(net3189), .B1(net3190), 
        .Y(s_dat_d[2]) );
  sky130_fd_sc_hd__nand2_1 U141 ( .A(s_cnt_q[0]), .B(s_cnt_q[1]), .Y(n75) );
  sky130_fd_sc_hd__o31ai_1 U142 ( .A1(n75), .A2(n37), .A3(net3189), .B1(n46), 
        .Y(s_dat_d[3]) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(n33), .Y(n71) );
  sky130_fd_sc_hd__nor2_1 U144 ( .A(s_cnt_q[0]), .B(n71), .Y(n72) );
  sky130_fd_sc_hd__mux2i_1 U145 ( .A0(net3296), .A1(net1433), .S(n72), .Y(
        s_dat_d[8]) );
  sky130_fd_sc_hd__nand2_1 U146 ( .A(s_falledge), .B(net3177), .Y(n81) );
  sky130_fd_sc_hd__mux2i_1 U147 ( .A0(n81), .A1(s_falledge), .S(s_cnt_q[0]), 
        .Y(s_cnt_d[0]) );
  sky130_fd_sc_hd__inv_1 U148 ( .A(s_falledge), .Y(net3178) );
  sky130_fd_sc_hd__a21oi_1 U149 ( .A1(net3177), .A2(n74), .B1(net3178), .Y(n73) );
  sky130_fd_sc_hd__o32ai_1 U150 ( .A1(s_cnt_q[1]), .A2(n74), .A3(n81), .B1(n70), .B2(n73), .Y(s_cnt_d[1]) );
  sky130_fd_sc_hd__nand2_1 U151 ( .A(n77), .B(n76), .Y(n79) );
  sky130_fd_sc_hd__nor2_1 U152 ( .A(n47), .B(net3178), .Y(n78) );
  sky130_fd_sc_hd__mux2i_1 U153 ( .A0(n79), .A1(n78), .S(s_cnt_q[2]), .Y(
        s_cnt_d[2]) );
  sky130_fd_sc_hd__a21oi_1 U154 ( .A1(n38), .A2(net3177), .B1(net3178), .Y(n80) );
  sky130_fd_sc_hd__o32ai_1 U155 ( .A1(n38), .A2(s_cnt_q[3]), .A3(n81), .B1(n83), .B2(n80), .Y(s_cnt_d[3]) );
  sky130_fd_sc_hd__inv_1 U156 ( .A(s_fifo_empty), .Y(n82) );
  sky130_fd_sc_hd__nand3_1 U157 ( .A(n70), .B(n44), .C(s_cnt_q[2]), .Y(n43) );
  sky130_fd_sc_hd__nand2_1 U158 ( .A(s_cnt_q[2]), .B(net3172), .Y(n41) );
  sky130_fd_sc_hd__nand2_1 U159 ( .A(s_cnt_q[2]), .B(net3170), .Y(n39) );
  sky130_fd_sc_hd__a31oi_1 U160 ( .A1(s_ps2_ctrl_q[0]), .A2(s_ps2_ctrl_q[1]), 
        .A3(n82), .B1(ps2_irq_o), .Y(n17) );
endmodule

