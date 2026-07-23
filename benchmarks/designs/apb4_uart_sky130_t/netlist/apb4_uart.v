/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Mon Sep 29 20:19:50 2025
/////////////////////////////////////////////////////////////


module dffr_DATA_WIDTH9 ( clk_i, rst_n_i, dat_i, dat_o );
  input [8:0] dat_i;
  output [8:0] dat_o;
  input clk_i, rst_n_i;


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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
endmodule


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


module dffr_DATA_WIDTH4 ( clk_i, rst_n_i, dat_i, dat_o );
  input [3:0] dat_i;
  output [3:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffrc_7_60 ( clk_i, rst_n_i, dat_i, dat_o );
  input [6:0] dat_i;
  output [6:0] dat_o;
  input clk_i, rst_n_i;


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
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfstp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[6]) );
endmodule


module dffr_DATA_WIDTH6_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [5:0] dat_i;
  output [5:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
endmodule


module dffr_DATA_WIDTH6_3 ( clk_i, rst_n_i, dat_i, dat_o );
  input [5:0] dat_i;
  output [5:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
endmodule


module dffr_DATA_WIDTH7_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [6:0] dat_i;
  output [6:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
endmodule


module dffr_DATA_WIDTH512 ( clk_i, rst_n_i, dat_i, dat_o );
  input [511:0] dat_i;
  output [511:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_511_ ( .D(dat_i[511]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[511]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_510_ ( .D(dat_i[510]), .CLK(clk_i), 
        .RESET_B(n10), .Q(dat_o[510]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_509_ ( .D(dat_i[509]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[509]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_508_ ( .D(dat_i[508]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[508]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_507_ ( .D(dat_i[507]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[507]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_506_ ( .D(dat_i[506]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[506]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_505_ ( .D(dat_i[505]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[505]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_504_ ( .D(dat_i[504]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[504]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_503_ ( .D(dat_i[503]), .CLK(clk_i), 
        .RESET_B(n10), .Q(dat_o[503]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_502_ ( .D(dat_i[502]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[502]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_501_ ( .D(dat_i[501]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[501]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_500_ ( .D(dat_i[500]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[500]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_499_ ( .D(dat_i[499]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[499]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_498_ ( .D(dat_i[498]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[498]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_497_ ( .D(dat_i[497]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[497]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_496_ ( .D(dat_i[496]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[496]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_495_ ( .D(dat_i[495]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[495]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_494_ ( .D(dat_i[494]), .CLK(clk_i), 
        .RESET_B(n10), .Q(dat_o[494]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_493_ ( .D(dat_i[493]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[493]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_492_ ( .D(dat_i[492]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[492]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_491_ ( .D(dat_i[491]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[491]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_490_ ( .D(dat_i[490]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[490]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_489_ ( .D(dat_i[489]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[489]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_488_ ( .D(dat_i[488]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[488]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_487_ ( .D(dat_i[487]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[487]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_486_ ( .D(dat_i[486]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[486]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_485_ ( .D(dat_i[485]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[485]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_484_ ( .D(dat_i[484]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[484]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_483_ ( .D(dat_i[483]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[483]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_482_ ( .D(dat_i[482]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[482]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_481_ ( .D(dat_i[481]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[481]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_480_ ( .D(dat_i[480]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[480]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_479_ ( .D(dat_i[479]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[479]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_478_ ( .D(dat_i[478]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[478]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_477_ ( .D(dat_i[477]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[477]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_476_ ( .D(dat_i[476]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[476]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_475_ ( .D(dat_i[475]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[475]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_474_ ( .D(dat_i[474]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[474]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_473_ ( .D(dat_i[473]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[473]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_472_ ( .D(dat_i[472]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[472]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_471_ ( .D(dat_i[471]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[471]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_470_ ( .D(dat_i[470]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[470]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_469_ ( .D(dat_i[469]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[469]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_468_ ( .D(dat_i[468]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[468]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_467_ ( .D(dat_i[467]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[467]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_466_ ( .D(dat_i[466]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[466]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_465_ ( .D(dat_i[465]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[465]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_464_ ( .D(dat_i[464]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[464]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_463_ ( .D(dat_i[463]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[463]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_462_ ( .D(dat_i[462]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[462]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_461_ ( .D(dat_i[461]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[461]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_460_ ( .D(dat_i[460]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[460]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_459_ ( .D(dat_i[459]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[459]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_458_ ( .D(dat_i[458]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[458]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_457_ ( .D(dat_i[457]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[457]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_456_ ( .D(dat_i[456]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[456]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_455_ ( .D(dat_i[455]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[455]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_454_ ( .D(dat_i[454]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[454]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_453_ ( .D(dat_i[453]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[453]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_452_ ( .D(dat_i[452]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[452]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_451_ ( .D(dat_i[451]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[451]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_450_ ( .D(dat_i[450]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[450]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_449_ ( .D(dat_i[449]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[449]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_448_ ( .D(dat_i[448]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[448]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_447_ ( .D(dat_i[447]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[447]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_446_ ( .D(dat_i[446]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[446]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_445_ ( .D(dat_i[445]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[445]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_444_ ( .D(dat_i[444]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[444]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_443_ ( .D(dat_i[443]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[443]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_442_ ( .D(dat_i[442]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[442]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_441_ ( .D(dat_i[441]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[441]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_440_ ( .D(dat_i[440]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[440]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_439_ ( .D(dat_i[439]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[439]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_438_ ( .D(dat_i[438]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[438]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_437_ ( .D(dat_i[437]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[437]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_436_ ( .D(dat_i[436]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[436]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_435_ ( .D(dat_i[435]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[435]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_434_ ( .D(dat_i[434]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[434]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_433_ ( .D(dat_i[433]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[433]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_432_ ( .D(dat_i[432]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[432]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_431_ ( .D(dat_i[431]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[431]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_430_ ( .D(dat_i[430]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[430]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_429_ ( .D(dat_i[429]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[429]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_428_ ( .D(dat_i[428]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[428]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_427_ ( .D(dat_i[427]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[427]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_426_ ( .D(dat_i[426]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[426]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_425_ ( .D(dat_i[425]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[425]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_424_ ( .D(dat_i[424]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[424]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_423_ ( .D(dat_i[423]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[423]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_422_ ( .D(dat_i[422]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[422]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_421_ ( .D(dat_i[421]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[421]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_420_ ( .D(dat_i[420]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[420]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_419_ ( .D(dat_i[419]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[419]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_418_ ( .D(dat_i[418]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[418]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_417_ ( .D(dat_i[417]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[417]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_416_ ( .D(dat_i[416]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[416]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_415_ ( .D(dat_i[415]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[415]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_414_ ( .D(dat_i[414]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[414]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_413_ ( .D(dat_i[413]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[413]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_412_ ( .D(dat_i[412]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[412]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_411_ ( .D(dat_i[411]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[411]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_410_ ( .D(dat_i[410]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[410]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_409_ ( .D(dat_i[409]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[409]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_408_ ( .D(dat_i[408]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[408]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_407_ ( .D(dat_i[407]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[407]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_406_ ( .D(dat_i[406]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[406]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_405_ ( .D(dat_i[405]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[405]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_404_ ( .D(dat_i[404]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[404]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_403_ ( .D(dat_i[403]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[403]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_402_ ( .D(dat_i[402]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[402]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_401_ ( .D(dat_i[401]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[401]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_400_ ( .D(dat_i[400]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[400]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_399_ ( .D(dat_i[399]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[399]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_398_ ( .D(dat_i[398]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[398]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_397_ ( .D(dat_i[397]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[397]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_396_ ( .D(dat_i[396]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[396]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_395_ ( .D(dat_i[395]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[395]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_394_ ( .D(dat_i[394]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[394]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_393_ ( .D(dat_i[393]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[393]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_392_ ( .D(dat_i[392]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[392]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_391_ ( .D(dat_i[391]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[391]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_390_ ( .D(dat_i[390]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[390]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_389_ ( .D(dat_i[389]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[389]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_388_ ( .D(dat_i[388]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[388]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_387_ ( .D(dat_i[387]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[387]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_386_ ( .D(dat_i[386]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[386]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_385_ ( .D(dat_i[385]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[385]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_384_ ( .D(dat_i[384]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[384]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_383_ ( .D(dat_i[383]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[383]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_382_ ( .D(dat_i[382]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[382]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_381_ ( .D(dat_i[381]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[381]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_380_ ( .D(dat_i[380]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[380]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_379_ ( .D(dat_i[379]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[379]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_378_ ( .D(dat_i[378]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[378]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_377_ ( .D(dat_i[377]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[377]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_376_ ( .D(dat_i[376]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[376]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_375_ ( .D(dat_i[375]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[375]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_374_ ( .D(dat_i[374]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[374]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_373_ ( .D(dat_i[373]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[373]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_372_ ( .D(dat_i[372]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[372]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_371_ ( .D(dat_i[371]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[371]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_370_ ( .D(dat_i[370]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[370]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_369_ ( .D(dat_i[369]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[369]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_368_ ( .D(dat_i[368]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[368]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_367_ ( .D(dat_i[367]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[367]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_366_ ( .D(dat_i[366]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[366]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_365_ ( .D(dat_i[365]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[365]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_364_ ( .D(dat_i[364]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[364]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_363_ ( .D(dat_i[363]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[363]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_362_ ( .D(dat_i[362]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[362]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_361_ ( .D(dat_i[361]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[361]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_360_ ( .D(dat_i[360]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[360]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_359_ ( .D(dat_i[359]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[359]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_358_ ( .D(dat_i[358]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[358]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_357_ ( .D(dat_i[357]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[357]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_356_ ( .D(dat_i[356]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[356]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_355_ ( .D(dat_i[355]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[355]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_354_ ( .D(dat_i[354]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[354]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_353_ ( .D(dat_i[353]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[353]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_352_ ( .D(dat_i[352]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[352]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_351_ ( .D(dat_i[351]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[351]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_350_ ( .D(dat_i[350]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[350]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_349_ ( .D(dat_i[349]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[349]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_348_ ( .D(dat_i[348]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[348]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_347_ ( .D(dat_i[347]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[347]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_346_ ( .D(dat_i[346]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[346]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_345_ ( .D(dat_i[345]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[345]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_344_ ( .D(dat_i[344]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[344]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_343_ ( .D(dat_i[343]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[343]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_342_ ( .D(dat_i[342]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[342]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_341_ ( .D(dat_i[341]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[341]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_340_ ( .D(dat_i[340]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[340]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_339_ ( .D(dat_i[339]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[339]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_338_ ( .D(dat_i[338]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[338]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_337_ ( .D(dat_i[337]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[337]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_336_ ( .D(dat_i[336]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[336]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_335_ ( .D(dat_i[335]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[335]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_334_ ( .D(dat_i[334]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[334]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_333_ ( .D(dat_i[333]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[333]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_332_ ( .D(dat_i[332]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[332]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_331_ ( .D(dat_i[331]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[331]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_330_ ( .D(dat_i[330]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[330]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_329_ ( .D(dat_i[329]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[329]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_328_ ( .D(dat_i[328]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[328]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_327_ ( .D(dat_i[327]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[327]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_326_ ( .D(dat_i[326]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[326]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_325_ ( .D(dat_i[325]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[325]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_324_ ( .D(dat_i[324]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[324]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_323_ ( .D(dat_i[323]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[323]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_322_ ( .D(dat_i[322]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[322]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_321_ ( .D(dat_i[321]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[321]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_320_ ( .D(dat_i[320]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[320]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_319_ ( .D(dat_i[319]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[319]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_318_ ( .D(dat_i[318]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[318]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_317_ ( .D(dat_i[317]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[317]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_316_ ( .D(dat_i[316]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[316]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_315_ ( .D(dat_i[315]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[315]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_314_ ( .D(dat_i[314]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[314]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_313_ ( .D(dat_i[313]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[313]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_312_ ( .D(dat_i[312]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[312]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_311_ ( .D(dat_i[311]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[311]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_310_ ( .D(dat_i[310]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[310]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_309_ ( .D(dat_i[309]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[309]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_308_ ( .D(dat_i[308]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[308]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_307_ ( .D(dat_i[307]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[307]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_306_ ( .D(dat_i[306]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[306]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_305_ ( .D(dat_i[305]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[305]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_304_ ( .D(dat_i[304]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[304]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_303_ ( .D(dat_i[303]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[303]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_302_ ( .D(dat_i[302]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[302]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_301_ ( .D(dat_i[301]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[301]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_300_ ( .D(dat_i[300]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[300]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_299_ ( .D(dat_i[299]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[299]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_298_ ( .D(dat_i[298]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[298]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_297_ ( .D(dat_i[297]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[297]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_296_ ( .D(dat_i[296]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[296]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_295_ ( .D(dat_i[295]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[295]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_294_ ( .D(dat_i[294]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[294]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_293_ ( .D(dat_i[293]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[293]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_292_ ( .D(dat_i[292]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[292]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_291_ ( .D(dat_i[291]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[291]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_290_ ( .D(dat_i[290]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[290]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_289_ ( .D(dat_i[289]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[289]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_288_ ( .D(dat_i[288]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[288]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_287_ ( .D(dat_i[287]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[287]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_286_ ( .D(dat_i[286]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[286]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_285_ ( .D(dat_i[285]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[285]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_284_ ( .D(dat_i[284]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[284]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_283_ ( .D(dat_i[283]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[283]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_282_ ( .D(dat_i[282]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[282]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_281_ ( .D(dat_i[281]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[281]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_280_ ( .D(dat_i[280]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[280]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_279_ ( .D(dat_i[279]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[279]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_278_ ( .D(dat_i[278]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[278]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_277_ ( .D(dat_i[277]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[277]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_276_ ( .D(dat_i[276]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[276]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_275_ ( .D(dat_i[275]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[275]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_274_ ( .D(dat_i[274]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[274]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_273_ ( .D(dat_i[273]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[273]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_272_ ( .D(dat_i[272]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[272]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_271_ ( .D(dat_i[271]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[271]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_270_ ( .D(dat_i[270]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[270]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_269_ ( .D(dat_i[269]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[269]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_268_ ( .D(dat_i[268]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[268]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_267_ ( .D(dat_i[267]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[267]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_266_ ( .D(dat_i[266]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[266]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_265_ ( .D(dat_i[265]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[265]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_264_ ( .D(dat_i[264]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[264]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_263_ ( .D(dat_i[263]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[263]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_262_ ( .D(dat_i[262]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[262]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_261_ ( .D(dat_i[261]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[261]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_260_ ( .D(dat_i[260]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[260]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_259_ ( .D(dat_i[259]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[259]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_258_ ( .D(dat_i[258]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[258]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_257_ ( .D(dat_i[257]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[257]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_256_ ( .D(dat_i[256]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[256]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_255_ ( .D(dat_i[255]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[255]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_254_ ( .D(dat_i[254]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[254]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_253_ ( .D(dat_i[253]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[253]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_252_ ( .D(dat_i[252]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[252]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_251_ ( .D(dat_i[251]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[251]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_250_ ( .D(dat_i[250]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[250]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_249_ ( .D(dat_i[249]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[249]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_248_ ( .D(dat_i[248]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[248]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_247_ ( .D(dat_i[247]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[247]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_246_ ( .D(dat_i[246]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[246]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_245_ ( .D(dat_i[245]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[245]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_244_ ( .D(dat_i[244]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[244]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_243_ ( .D(dat_i[243]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[243]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_242_ ( .D(dat_i[242]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[242]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_241_ ( .D(dat_i[241]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[241]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_240_ ( .D(dat_i[240]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[240]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_239_ ( .D(dat_i[239]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[239]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_238_ ( .D(dat_i[238]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[238]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_237_ ( .D(dat_i[237]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[237]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_236_ ( .D(dat_i[236]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[236]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_235_ ( .D(dat_i[235]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[235]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_234_ ( .D(dat_i[234]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[234]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_233_ ( .D(dat_i[233]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[233]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_232_ ( .D(dat_i[232]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[232]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_231_ ( .D(dat_i[231]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[231]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_230_ ( .D(dat_i[230]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[230]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_229_ ( .D(dat_i[229]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[229]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_228_ ( .D(dat_i[228]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[228]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_227_ ( .D(dat_i[227]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[227]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_226_ ( .D(dat_i[226]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[226]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_225_ ( .D(dat_i[225]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[225]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_224_ ( .D(dat_i[224]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[224]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_223_ ( .D(dat_i[223]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[223]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_222_ ( .D(dat_i[222]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[222]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_221_ ( .D(dat_i[221]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[221]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_220_ ( .D(dat_i[220]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[220]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_219_ ( .D(dat_i[219]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[219]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_218_ ( .D(dat_i[218]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[218]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_217_ ( .D(dat_i[217]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[217]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_216_ ( .D(dat_i[216]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[216]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_215_ ( .D(dat_i[215]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[215]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_214_ ( .D(dat_i[214]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[214]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_213_ ( .D(dat_i[213]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[213]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_212_ ( .D(dat_i[212]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[212]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_211_ ( .D(dat_i[211]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[211]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_210_ ( .D(dat_i[210]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[210]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_209_ ( .D(dat_i[209]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[209]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_208_ ( .D(dat_i[208]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[208]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_207_ ( .D(dat_i[207]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[207]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_206_ ( .D(dat_i[206]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[206]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_205_ ( .D(dat_i[205]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[205]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_204_ ( .D(dat_i[204]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[204]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_203_ ( .D(dat_i[203]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[203]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_202_ ( .D(dat_i[202]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[202]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_201_ ( .D(dat_i[201]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[201]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_200_ ( .D(dat_i[200]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[200]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_199_ ( .D(dat_i[199]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[199]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_198_ ( .D(dat_i[198]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[198]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_197_ ( .D(dat_i[197]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[197]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_196_ ( .D(dat_i[196]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[196]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_195_ ( .D(dat_i[195]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[195]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_194_ ( .D(dat_i[194]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[194]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_193_ ( .D(dat_i[193]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[193]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_192_ ( .D(dat_i[192]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[192]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_191_ ( .D(dat_i[191]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[191]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_190_ ( .D(dat_i[190]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[190]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_189_ ( .D(dat_i[189]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[189]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_188_ ( .D(dat_i[188]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[188]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_187_ ( .D(dat_i[187]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[187]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_186_ ( .D(dat_i[186]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[186]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_185_ ( .D(dat_i[185]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[185]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_184_ ( .D(dat_i[184]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[184]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_183_ ( .D(dat_i[183]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[183]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_182_ ( .D(dat_i[182]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[182]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_181_ ( .D(dat_i[181]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[181]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_180_ ( .D(dat_i[180]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[180]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_179_ ( .D(dat_i[179]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[179]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_178_ ( .D(dat_i[178]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[178]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_177_ ( .D(dat_i[177]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[177]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_176_ ( .D(dat_i[176]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[176]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_175_ ( .D(dat_i[175]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[175]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_174_ ( .D(dat_i[174]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[174]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_173_ ( .D(dat_i[173]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[173]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_172_ ( .D(dat_i[172]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[172]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_171_ ( .D(dat_i[171]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[171]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_170_ ( .D(dat_i[170]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[170]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_169_ ( .D(dat_i[169]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[169]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_168_ ( .D(dat_i[168]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[168]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_167_ ( .D(dat_i[167]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[167]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_166_ ( .D(dat_i[166]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[166]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_165_ ( .D(dat_i[165]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[165]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_164_ ( .D(dat_i[164]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[164]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_163_ ( .D(dat_i[163]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[163]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_162_ ( .D(dat_i[162]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[162]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_161_ ( .D(dat_i[161]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[161]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_160_ ( .D(dat_i[160]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[160]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_159_ ( .D(dat_i[159]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[159]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_158_ ( .D(dat_i[158]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[158]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_157_ ( .D(dat_i[157]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[157]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_156_ ( .D(dat_i[156]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[156]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_155_ ( .D(dat_i[155]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[155]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_154_ ( .D(dat_i[154]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[154]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_153_ ( .D(dat_i[153]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[153]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_152_ ( .D(dat_i[152]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[152]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_151_ ( .D(dat_i[151]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[151]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_150_ ( .D(dat_i[150]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[150]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_149_ ( .D(dat_i[149]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[149]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_148_ ( .D(dat_i[148]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[148]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_147_ ( .D(dat_i[147]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[147]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_146_ ( .D(dat_i[146]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[146]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_145_ ( .D(dat_i[145]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[145]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_144_ ( .D(dat_i[144]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[144]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_143_ ( .D(dat_i[143]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[143]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_142_ ( .D(dat_i[142]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[142]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_141_ ( .D(dat_i[141]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[141]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_140_ ( .D(dat_i[140]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[140]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_139_ ( .D(dat_i[139]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[139]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_138_ ( .D(dat_i[138]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[138]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_137_ ( .D(dat_i[137]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[137]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_136_ ( .D(dat_i[136]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[136]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_135_ ( .D(dat_i[135]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[135]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_134_ ( .D(dat_i[134]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[134]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_133_ ( .D(dat_i[133]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[133]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_132_ ( .D(dat_i[132]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[132]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_131_ ( .D(dat_i[131]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[131]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_130_ ( .D(dat_i[130]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[130]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_129_ ( .D(dat_i[129]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[129]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_128_ ( .D(dat_i[128]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[128]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_127_ ( .D(dat_i[127]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[127]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_126_ ( .D(dat_i[126]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[126]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_125_ ( .D(dat_i[125]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[125]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_124_ ( .D(dat_i[124]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[124]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_123_ ( .D(dat_i[123]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[123]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_122_ ( .D(dat_i[122]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[122]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_121_ ( .D(dat_i[121]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[121]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_120_ ( .D(dat_i[120]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[120]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_119_ ( .D(dat_i[119]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[119]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_118_ ( .D(dat_i[118]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[118]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_117_ ( .D(dat_i[117]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[117]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_116_ ( .D(dat_i[116]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[116]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_115_ ( .D(dat_i[115]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[115]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_114_ ( .D(dat_i[114]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[114]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_113_ ( .D(dat_i[113]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[113]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_112_ ( .D(dat_i[112]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[112]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_111_ ( .D(dat_i[111]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[111]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_110_ ( .D(dat_i[110]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[110]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_109_ ( .D(dat_i[109]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[109]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_108_ ( .D(dat_i[108]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[108]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_107_ ( .D(dat_i[107]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[107]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_106_ ( .D(dat_i[106]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[106]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_105_ ( .D(dat_i[105]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[105]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_104_ ( .D(dat_i[104]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[104]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_103_ ( .D(dat_i[103]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[103]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_102_ ( .D(dat_i[102]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[102]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_101_ ( .D(dat_i[101]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[101]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_100_ ( .D(dat_i[100]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[100]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_99_ ( .D(dat_i[99]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[99]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_98_ ( .D(dat_i[98]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[98]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_97_ ( .D(dat_i[97]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[97]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_96_ ( .D(dat_i[96]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[96]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_95_ ( .D(dat_i[95]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[95]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_94_ ( .D(dat_i[94]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[94]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_93_ ( .D(dat_i[93]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[93]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_92_ ( .D(dat_i[92]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[92]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_91_ ( .D(dat_i[91]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[91]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_90_ ( .D(dat_i[90]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[90]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_89_ ( .D(dat_i[89]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[89]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_88_ ( .D(dat_i[88]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[88]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_87_ ( .D(dat_i[87]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[87]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_86_ ( .D(dat_i[86]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[86]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_85_ ( .D(dat_i[85]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[85]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_84_ ( .D(dat_i[84]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[84]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_83_ ( .D(dat_i[83]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[83]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_82_ ( .D(dat_i[82]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[82]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_81_ ( .D(dat_i[81]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[81]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_80_ ( .D(dat_i[80]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[80]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_79_ ( .D(dat_i[79]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[79]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_78_ ( .D(dat_i[78]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[78]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_77_ ( .D(dat_i[77]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[77]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_76_ ( .D(dat_i[76]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[76]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_75_ ( .D(dat_i[75]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[75]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_74_ ( .D(dat_i[74]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[74]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_73_ ( .D(dat_i[73]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[73]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_72_ ( .D(dat_i[72]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[72]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_71_ ( .D(dat_i[71]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[71]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_70_ ( .D(dat_i[70]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[70]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_69_ ( .D(dat_i[69]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[69]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_68_ ( .D(dat_i[68]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[68]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_67_ ( .D(dat_i[67]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[67]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_66_ ( .D(dat_i[66]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[66]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_65_ ( .D(dat_i[65]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[65]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_64_ ( .D(dat_i[64]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[64]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[58]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[52]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[51]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        n47), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        n47), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n47), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n47), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n47), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n10), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n2), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n3), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[0]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(n9), .X(n47) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(n9), .X(n46) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(n9), .X(n45) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(n8), .X(n44) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(n8), .X(n43) );
  sky130_fd_sc_hd__buf_1 U8 ( .A(n8), .X(n42) );
  sky130_fd_sc_hd__buf_1 U9 ( .A(n7), .X(n41) );
  sky130_fd_sc_hd__buf_1 U10 ( .A(n7), .X(n40) );
  sky130_fd_sc_hd__buf_1 U11 ( .A(n7), .X(n39) );
  sky130_fd_sc_hd__buf_1 U12 ( .A(n6), .X(n38) );
  sky130_fd_sc_hd__buf_1 U13 ( .A(n6), .X(n37) );
  sky130_fd_sc_hd__buf_1 U14 ( .A(n6), .X(n36) );
  sky130_fd_sc_hd__buf_1 U15 ( .A(n5), .X(n35) );
  sky130_fd_sc_hd__buf_1 U16 ( .A(n5), .X(n34) );
  sky130_fd_sc_hd__buf_1 U17 ( .A(n5), .X(n33) );
  sky130_fd_sc_hd__buf_1 U18 ( .A(n4), .X(n32) );
  sky130_fd_sc_hd__buf_1 U19 ( .A(n4), .X(n31) );
  sky130_fd_sc_hd__buf_1 U20 ( .A(n4), .X(n30) );
  sky130_fd_sc_hd__buf_1 U21 ( .A(n3), .X(n29) );
  sky130_fd_sc_hd__buf_1 U22 ( .A(n3), .X(n28) );
  sky130_fd_sc_hd__buf_1 U23 ( .A(n3), .X(n27) );
  sky130_fd_sc_hd__buf_1 U24 ( .A(n2), .X(n26) );
  sky130_fd_sc_hd__buf_1 U25 ( .A(n2), .X(n25) );
  sky130_fd_sc_hd__buf_1 U26 ( .A(n2), .X(n24) );
  sky130_fd_sc_hd__buf_1 U27 ( .A(n1), .X(n23) );
  sky130_fd_sc_hd__buf_1 U28 ( .A(n1), .X(n22) );
  sky130_fd_sc_hd__buf_1 U29 ( .A(n1), .X(n21) );
  sky130_fd_sc_hd__buf_1 U30 ( .A(n3), .X(n20) );
  sky130_fd_sc_hd__buf_1 U31 ( .A(n2), .X(n19) );
  sky130_fd_sc_hd__buf_1 U32 ( .A(n1), .X(n18) );
  sky130_fd_sc_hd__buf_1 U33 ( .A(n6), .X(n17) );
  sky130_fd_sc_hd__buf_1 U34 ( .A(n5), .X(n16) );
  sky130_fd_sc_hd__buf_1 U35 ( .A(n4), .X(n15) );
  sky130_fd_sc_hd__buf_1 U36 ( .A(n9), .X(n14) );
  sky130_fd_sc_hd__buf_1 U37 ( .A(n8), .X(n13) );
  sky130_fd_sc_hd__buf_1 U38 ( .A(n7), .X(n12) );
  sky130_fd_sc_hd__buf_1 U39 ( .A(n10), .X(n11) );
  sky130_fd_sc_hd__buf_1 U40 ( .A(rst_n_i), .X(n3) );
  sky130_fd_sc_hd__buf_1 U41 ( .A(rst_n_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U42 ( .A(rst_n_i), .X(n1) );
  sky130_fd_sc_hd__buf_1 U43 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__buf_1 U44 ( .A(rst_n_i), .X(n5) );
  sky130_fd_sc_hd__buf_1 U45 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U46 ( .A(rst_n_i), .X(n9) );
  sky130_fd_sc_hd__buf_1 U47 ( .A(rst_n_i), .X(n8) );
  sky130_fd_sc_hd__buf_1 U48 ( .A(rst_n_i), .X(n7) );
  sky130_fd_sc_hd__buf_1 U49 ( .A(rst_n_i), .X(n10) );
endmodule


module fifo_DATA_WIDTH8_BUFFER_DEPTH64_DW01_inc_3 ( A, SUM );
  input [6:0] A;
  output [6:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n16;
  assign n2 = A[5];
  assign n7 = A[3];
  assign n12 = A[1];
  assign n14 = A[0];

  sky130_fd_sc_hd__xor2_1 U1 ( .A(A[6]), .B(n16), .X(SUM[6]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n3), .B(n4), .Y(SUM[5]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n4), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n6), .B(n5), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n5), .B(n6), .Y(n4) );
  sky130_fd_sc_hd__xnor2_1 U10 ( .A(n8), .B(n9), .Y(SUM[3]) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n9), .B(n7), .Y(n6) );
  sky130_fd_sc_hd__xor2_1 U14 ( .A(n11), .B(n10), .X(SUM[2]) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(n10), .B(n11), .Y(n9) );
  sky130_fd_sc_hd__xnor2_1 U17 ( .A(n14), .B(n13), .Y(SUM[1]) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n14), .B(n12), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(n1), .Y(n16) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(n12), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U27 ( .A(A[4]), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(n14), .Y(SUM[0]) );
  sky130_fd_sc_hd__clkinv_1 U29 ( .A(n2), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(A[2]), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n7), .Y(n8) );
endmodule


module fifo_DATA_WIDTH8_BUFFER_DEPTH64 ( clk_i, rst_n_i, flush_i, full_o, 
        empty_o, cnt_o, dat_i, push_i, dat_o, pop_i );
  output [6:0] cnt_o;
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i, flush_i, push_i, pop_i;
  output full_o, empty_o;
  wire   N75, N76, N77, N78, N79, N80, n1259, n1260, n1261, N85, N86, N87, N88,
         N89, N96, N97, N98, N99, N100, N108, N109, N110, N111, N112, N113,
         N114, \add_65/carry[5] , \add_65/carry[4] , \add_65/carry[3] ,
         \add_65/carry[2] , \add_50/carry[5] , \add_50/carry[4] ,
         \add_50/carry[3] , \add_50/carry[2] , net23556, net23557, net23569,
         net23570, net23582, net23583, net23595, net23596, net23608, net23609,
         net23621, net23622, net23635, net23636, net23648, net23649, net23660,
         net23661, net23672, net23673, net23685, net23697, net23708, net23709,
         net23720, net23721, net23758, net23759, net23770, net23771, net23782,
         net23794, net23806, net23818, net23856, net23868, net23880, net23892,
         net23904, net23916, net24335, net24336, net24337, net24338, net25158,
         net25176, net25185, net25188, \C1342/net25651 , \C1342/net25230 ,
         \C1342/net25231 , \C1342/net25204 , \C1342/net24842 ,
         \C1342/net24844 , \C1342/net23502 , \C1342/net23497 ,
         \C1342/net23480 , \C1342/net23479 , \C1342/net23478 ,
         \C1342/net23472 , \C1342/net23468 , \C1342/net23465 ,
         \C1342/net23215 , \C1342/net23208 , \C1342/net23207 ,
         \C1342/net23205 , \C1342/net23203 , \C1342/net23200 ,
         \C1342/net23199 , \C1342/net23171 , \C1342/net23165 ,
         \C1342/net23161 , \C1342/net23156 , \C1342/net23155 ,
         \C1342/net23121 , \C1342/net23119 , \C1342/net23118 ,
         \C1342/net23117 , \C1342/net23116 , \C1342/net23114 ,
         \C1342/net23109 , \C1342/net23108 , \C1342/net23107 ,
         \C1342/net23106 , \C1342/net23105 , \C1342/net23104 ,
         \C1342/net23103 , \C1342/net23102 , net28369, net28368, net28383,
         net28382, net28392, net28405, net28409, \C1342/net23487 ,
         \C1342/net23168 , \C1342/net23115 , net28404, net25184,
         \C1342/net23504 , \C1342/net23493 , \C1342/net23167 ,
         \C1342/net23166 , \C1342/net23159 , \C1342/net23474 ,
         \C1342/net23470 , \C1342/net23466 , \C1342/net23164 ,
         \C1342/net23163 , net31276, net31290, net31297, net31346, net31356,
         net31364, net31374, net31373, net31378, net28414, \C1342/net23170 ,
         \C1342/net23157 , \C1342/net23178 , \C1342/net23176 ,
         \C1342/net23175 , \C1342/net23169 , \C1342/net23160 ,
         \C1342/net23158 , \C1342/net23503 , \C1342/net23491 ,
         \C1342/net23490 , \C1342/net23473 , \C1342/net23438 ,
         \C1342/net23214 , \C1342/net23201 , \C1342/net23500 ,
         \C1342/net23499 , \C1342/net23494 , \C1342/net23489 ,
         \C1342/net23471 , \C1342/net23222 , \C1342/net23220 ,
         \C1342/net23219 , \C1342/net23213 , \C1342/net23496 ,
         \C1342/net23495 , \C1342/net23482 , \C1342/net23481 ,
         \C1342/net23477 , \C1342/net23476 , \C1342/net23475 ,
         \C1342/net23467 , \C1342/net23202 , n1, n2, n3, n4, n5, n6, n7, n8,
         n9, n10, n11, n12, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23,
         n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37,
         n38, n39, n40, n41, n42, n44, n45, n46, n47, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67,
         n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81,
         n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95,
         n96, n97, n98, n99, n100, n101, n102, n103, n104, n105, n106, n107,
         n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, n118,
         n119, n120, n121, n122, n123, n124, n125, n126, n127, n128, n129,
         n130, n131, n132, n133, n134, n135, n136, n137, n138, n139, n140,
         n141, n142, n143, n144, n145, n146, n147, n148, n149, n150, n151,
         n152, n153, n154, n155, n156, n157, n158, n159, n160, n161, n162,
         n163, n164, n165, n166, n167, n168, n169, n170, n171, n172, n173,
         n174, n175, n176, n177, n178, n179, n180, n181, n182, n183, n184,
         n185, n186, n187, n188, n189, n190, n191, n192, n193, n194, n195,
         n196, n197, n198, n199, n200, n201, n202, n203, n204, n205, n206,
         n207, n208, n209, n210, n211, n212, n213, n214, n215, n216, n217,
         n218, n219, n220, n221, n222, n223, n224, n225, n226, n227, n228,
         n229, n230, n231, n232, n233, n234, n235, n236, n237, n238, n239,
         n240, n241, n242, n243, n244, n245, n246, n247, n248, n249, n250,
         n251, n252, n253, n254, n255, n256, n257, n258, n259, n260, n261,
         n262, n263, n264, n265, n266, n267, n268, n269, n270, n271, n272,
         n273, n274, n275, n276, n277, n278, n279, n280, n281, n282, n283,
         n284, n285, n286, n287, n288, n289, n290, n291, n292, n293, n294,
         n295, n296, n297, n298, n299, n300, n301, n302, n303, n304, n305,
         n306, n307, n308, n309, n310, n311, n312, n313, n314, n315, n316,
         n317, n318, n319, n320, n321, n322, n323, n324, n325, n326, n327,
         n328, n329, n330, n331, n332, n333, n334, n335, n336, n337, n338,
         n339, n340, n341, n342, n343, n344, n345, n346, n347, n348, n349,
         n350, n351, n352, n353, n354, n355, n356, n357, n358, n359, n360,
         n361, n362, n363, n364, n365, n366, n367, n368, n369, n370, n371,
         n372, n373, n374, n375, n376, n377, n378, n379, n380, n381, n382,
         n383, n384, n385, n386, n387, n388, n389, n390, n391, n392, n393,
         n394, n395, n396, n397, n398, n399, n400, n401, n402, n403, n404,
         n405, n406, n407, n408, n409, n410, n411, n412, n413, n414, n415,
         n416, n417, n418, n419, n420, n421, n422, n423, n424, n425, n426,
         n427, n428, n429, n430, n431, n432, n433, n434, n435, n436, n437,
         n438, n439, n440, n441, n442, n443, n444, n445, n446, n447, n448,
         n449, n450, n451, n452, n453, n454, n455, n456, n457, n458, n459,
         n460, n461, n462, n463, n464, n465, n466, n467, n468, n469, n470,
         n471, n472, n473, n474, n475, n476, n477, n478, n479, n480, n481,
         n482, n483, n484, n485, n486, n487, n488, n489, n490, n491, n492,
         n493, n494, n495, n496, n497, n498, n499, n500, n501, n502, n503,
         n504, n505, n506, n507, n508, n509, n510, n511, n512, n513, n514,
         n515, n516, n517, n518, n519, n520, n521, n522, n523, n524, n525,
         n526, n527, n528, n529, n530, n531, n532, n533, n534, n535, n536,
         n537, n538, n539, n540, n541, n542, n543, n544, n545, n546, n547,
         n548, n549, n550, n551, n552, n553, n554, n555, n556, n557, n558,
         n559, n560, n561, n562, n563, n564, n565, n566, n567, n568, n569,
         n570, n571, n572, n573, n574, n575, n576, n577, n578, n579, n580,
         n581, n582, n583, n584, n585, n586, n587, n588, n589, n590, n591,
         n592, n593, n594, n595, n596, n597, n598, n599, n600, n601, n602,
         n603, n604, n605, n606, n607, n608, n609, n610, n611, n612, n613,
         n614, n615, n616, n617, n618, n619, n620, n621, n622, n623, n624,
         n625, n626, n627, n628, n629, n630, n631, n632, n633, n634, n635,
         n636, n637, n638, n639, n640, n641, n642, n643, n644, n645, n646,
         n647, n648, n649, n650, n651, n652, n653, n654, n655, n656, n657,
         n658, n659, n660, n661, n662, n663, n664, n665, n666, n667, n668,
         n669, n670, n671, n672, n673, n674, n675, n676, n677, n678, n679,
         n680, n681, n682, n683, n684, n685, n686, n687, n688, n689, n690,
         n691, n692, n693, n694, n695, n696, n697, n698, n699, n700, n701,
         n702, n703, n704, n705, n706, n707, n708, n709, n710, n711, n712,
         n713, n714, n715, n716, n717, n718, n719, n720, n721, n722, n723,
         n724, n725, n726, n727, n728, n729, n730, n731, n732, n733, n734,
         n735, n736, n737, n738, n739, n740, n741, n742, n743, n744, n745,
         n746, n747, n748, n749, n750, n751, n752, n753, n754, n755, n756,
         n757, n758, n759, n760, n761, n762, n763, n764, n765, n766, n767,
         n768, n769, n770, n771, n772, n773, n774, n775, n776, n777, n778,
         n779, n780, n781, n782, n783, n784, n785, n786, n787, n788, n789,
         n790, n791, n792, n793, n794, n795, n796, n797, n798, n799, n800,
         n801, n802, n803, n804, n805, n806, n807, n808, n809, n810, n811,
         n812, n813, n814, n815, n816, n817, n818, n819, n820, n821, n822,
         n823, n824, n825, n826, n827, n828, n829, n830, n831, n832, n833,
         n834, n835, n836, n837, n838, n839, n840, n841, n842, n843, n844,
         n845, n846, n847, n848, n849, n850, n851, n852, n853, n854, n855,
         n856, n857, n858, n859, n860, n861, n862, n863, n864, n865, n866,
         n867, n868, n869, n870, n871, n872, n873, n874, n875, n876, n877,
         n878, n879, n880, n881, n882, n883, n884, n885, n886, n887, n888,
         n889, n890, n891, n892, n893, n894, n895, n896, n897, n898, n899,
         n900, n901, n902, n903, n904, n905, n906, n907, n908, n909, n910,
         n911, n912, n913, n914, n915, n916, n917, n918, n919, n920, n921,
         n922, n923, n924, n925, n926, n927, n928, n929, n930, n931, n932,
         n933, n934, n935, n936, n937, n938, n939, n940, n941, n942, n943,
         n944, n945, n946, n947, n948, n949, n950, n951, n952, n953, n954,
         n955, n956, n957, n958, n959, n960, n961, n962, n963, n964, n965,
         n966, n967, n968, n969, n970, n971, n972, n973, n974, n975, n976,
         n977, n978, n979, n980, n981, n982, n983, n984, n985, n986, n987,
         n988, n989, n990, n991, n992, n993, n994, n995, n996, n997, n998,
         n999, n1000, n1001, n1002, n1003, n1004, n1005, n1006, n1007, n1008,
         n1009, n1010, n1011, n1012, n1013, n1014, n1015, n1016, n1017, n1018,
         n1019, n1020, n1021, n1022, n1023, n1024, n1025, n1026, n1027, n1028,
         n1029, n1030, n1031, n1032, n1033, n1034, n1035, n1036, n1037, n1038,
         n1039, n1040, n1041, n1042, n1043, n1044, n1045, n1046, n1047, n1048,
         n1049, n1050, n1051, n1052, n1053, n1054, n1055, n1056, n1057, n1058,
         n1059, n1060, n1061, n1062, n1063, n1064, n1065, n1066, n1067, n1068,
         n1069, n1070, n1071, n1072, n1073, n1074, n1075, n1076, n1077, n1078,
         n1079, n1080, n1081, n1082, n1083, n1084, n1085, n1086, n1087, n1088,
         n1089, n1090, n1091, n1092, n1093, n1094, n1095, n1096, n1097, n1098,
         n1099, n1100, n1101, n1102, n1103, n1104, n1105, n1106, n1107, n1108,
         n1109, n1110, n1111, n1112, n1113, n1114, n1115, n1116, n1117, n1118,
         n1119, n1120, n1121, n1122, n1123, n1124, n1125, n1126, n1127, n1128,
         n1129, n1130, n1131, n1132, n1133, n1134, n1135, n1136, n1137, n1138,
         n1139, n1140, n1141, n1142, n1143, n1144, n1145, n1146, n1147, n1148,
         n1149, n1150, n1151, n1152, n1153, n1154, n1155, n1156, n1157, n1158,
         n1159, n1160, n1161, n1162, n1163, n1164, n1165, n1166, n1167, n1168,
         n1169, n1170, n1171, n1172, n1173, n1174, n1175, n1176, n1177, n1178,
         n1179, n1180, n1181, n1182, n1183, n1184, n1185, n1186, n1187, n1188,
         n1189, n1190, n1191, n1192, n1193, n1194, n1195, n1196, n1197, n1198,
         n1199, n1200, n1201, n1202, n1203, n1204, n1205, n1206, n1207, n1208,
         n1209, n1210, n1211, n1212, n1213, n1214, n1215, n1216, n1217, n1218,
         n1219, n1220, n1221, n1222, n1223, n1224, n1225, n1226, n1227, n1228,
         n1229, n1230, n1231, n1232, n1233, n1234, n1235, n1236, n1237, n1238,
         n1239, n1240, n1241, n1242, n1243, n1244, n1245, n1246, n1247, n1248,
         n1249, n1250, n1251, n1252, n1253, n1254, n1255, n1256;
  wire   [511:0] s_mem_q;
  wire   [5:0] s_rd_ptr_d;
  wire   [5:0] s_wr_ptr_d;
  wire   [5:0] s_wr_ptr_q;
  wire   [6:0] s_cnt_d;
  wire   [511:0] s_mem_d;

  dffr_DATA_WIDTH6_0 u_rd_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_rd_ptr_d), .dat_o({N80, N79, N78, N77, N76, N75}) );
  dffr_DATA_WIDTH6_3 u_wr_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_wr_ptr_d), .dat_o(s_wr_ptr_q) );
  dffr_DATA_WIDTH7_0 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_cnt_d), .dat_o({n1259, n1260, cnt_o[4:1], n1261}) );
  dffr_DATA_WIDTH512 u_mem_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_mem_d), .dat_o(s_mem_q) );
  fifo_DATA_WIDTH8_BUFFER_DEPTH64_DW01_inc_3 add_81 ( .A({cnt_o[6:4], n53, 
        cnt_o[2:1], n1261}), .SUM({N114, N113, N112, N111, N110, N109, N108})
         );
  sky130_fd_sc_hd__ha_2 \add_50/U1_1_4  ( .A(N79), .B(\add_50/carry[4] ), 
        .COUT(\add_50/carry[5] ), .SUM(N88) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_4  ( .A(s_wr_ptr_q[4]), .B(
        \add_65/carry[4] ), .COUT(\add_65/carry[5] ), .SUM(N99) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_2  ( .A(s_wr_ptr_q[2]), .B(
        \add_65/carry[2] ), .COUT(\add_65/carry[3] ), .SUM(N97) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_1  ( .A(s_wr_ptr_q[1]), .B(s_wr_ptr_q[0]), 
        .COUT(\add_65/carry[2] ), .SUM(N96) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_3  ( .A(s_wr_ptr_q[3]), .B(
        \add_65/carry[3] ), .COUT(\add_65/carry[4] ), .SUM(N98) );
  sky130_fd_sc_hd__nor2b_4 U3 ( .B_N(n444), .A(flush_i), .Y(n416) );
  sky130_fd_sc_hd__and2_1 U4 ( .A(n422), .B(n416), .X(n419) );
  sky130_fd_sc_hd__and2_1 U5 ( .A(n416), .B(n422), .X(n420) );
  sky130_fd_sc_hd__clkbuf_2 U6 ( .A(\C1342/net23104 ), .X(\C1342/net24842 ) );
  sky130_fd_sc_hd__o21ai_1 U7 ( .A1(n7), .A2(n467), .B1(n52), .Y(n457) );
  sky130_fd_sc_hd__clkinv_1 U8 ( .A(n457), .Y(n463) );
  sky130_fd_sc_hd__o21ai_1 U9 ( .A1(n467), .A2(n450), .B1(n52), .Y(n447) );
  sky130_fd_sc_hd__clkinv_1 U10 ( .A(n447), .Y(n454) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(n421), .Y(n1246) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(net28382), .Y(net28383) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(\C1342/net23106 ), .Y(n1) );
  sky130_fd_sc_hd__inv_1 U14 ( .A(n1), .Y(n2) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(\C1342/net23499 ), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(\C1342/net23499 ), .Y(\C1342/net23121 ) );
  sky130_fd_sc_hd__nand2_1 U17 ( .A(\C1342/net23475 ), .B(N77), .Y(
        \C1342/net23474 ) );
  sky130_fd_sc_hd__a2bb2o_2 U18 ( .A1_N(n478), .A2_N(net24335), .B1(N87), .B2(
        n477), .X(s_rd_ptr_d[3]) );
  sky130_fd_sc_hd__a2bb2o_1 U19 ( .A1_N(n478), .A2_N(net24337), .B1(N85), .B2(
        n477), .X(s_rd_ptr_d[1]) );
  sky130_fd_sc_hd__clkinv_2 U20 ( .A(\C1342/net25204 ), .Y(n18) );
  sky130_fd_sc_hd__a2bb2oi_2 U21 ( .B1(s_mem_q[486]), .B2(\C1342/net25204 ), 
        .A1_N(n362), .A2_N(\C1342/net25651 ), .Y(n306) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(n881), .Y(n960) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(n782), .Y(n867) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(n684), .Y(n769) );
  sky130_fd_sc_hd__and2_2 U25 ( .A(n532), .B(n1250), .X(n5) );
  sky130_fd_sc_hd__and2_2 U26 ( .A(n532), .B(s_wr_ptr_q[2]), .X(n4) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(n480), .Y(n573) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(push_i), .Y(n12) );
  sky130_fd_sc_hd__nand2_2 U29 ( .A(n960), .B(n5), .Y(n934) );
  sky130_fd_sc_hd__nand2_2 U30 ( .A(n960), .B(n1167), .Y(n912) );
  sky130_fd_sc_hd__nand2_2 U31 ( .A(n960), .B(n4), .Y(n890) );
  sky130_fd_sc_hd__nand2_2 U32 ( .A(n867), .B(n5), .Y(n840) );
  sky130_fd_sc_hd__nand2_2 U33 ( .A(n867), .B(n1167), .Y(n816) );
  sky130_fd_sc_hd__nand2_2 U34 ( .A(n867), .B(n4), .Y(n792) );
  sky130_fd_sc_hd__nand2_2 U35 ( .A(n769), .B(n5), .Y(n742) );
  sky130_fd_sc_hd__nand2_2 U36 ( .A(n769), .B(n1167), .Y(n718) );
  sky130_fd_sc_hd__nand2_2 U37 ( .A(n769), .B(n4), .Y(n694) );
  sky130_fd_sc_hd__nand2_2 U38 ( .A(n671), .B(n5), .Y(n644) );
  sky130_fd_sc_hd__nand2_2 U39 ( .A(n671), .B(n4), .Y(n596) );
  sky130_fd_sc_hd__nand2_2 U40 ( .A(n573), .B(n5), .Y(n542) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(n465), .Y(n468) );
  sky130_fd_sc_hd__clkbuf_1 U42 ( .A(n1260), .X(cnt_o[5]) );
  sky130_fd_sc_hd__inv_1 U43 ( .A(\C1342/net23116 ), .Y(net28382) );
  sky130_fd_sc_hd__inv_2 U44 ( .A(n481), .Y(n532) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(n479), .Y(n880) );
  sky130_fd_sc_hd__a22oi_1 U46 ( .A1(s_mem_q[254]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[246]), .B2(\C1342/net23115 ), .Y(n287) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(n1226), .Y(n1244) );
  sky130_fd_sc_hd__inv_2 U48 ( .A(n1242), .Y(n1225) );
  sky130_fd_sc_hd__inv_2 U49 ( .A(n1212), .Y(n1222) );
  sky130_fd_sc_hd__inv_2 U50 ( .A(n1220), .Y(n1211) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n1201), .Y(n1209) );
  sky130_fd_sc_hd__inv_2 U52 ( .A(n1207), .Y(n1200) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n1190), .Y(n1198) );
  sky130_fd_sc_hd__inv_2 U54 ( .A(n1196), .Y(n1189) );
  sky130_fd_sc_hd__inv_2 U55 ( .A(n1180), .Y(n1188) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(n1186), .Y(n1179) );
  sky130_fd_sc_hd__inv_2 U57 ( .A(n1169), .Y(n1177) );
  sky130_fd_sc_hd__inv_2 U58 ( .A(n1175), .Y(n1168) );
  sky130_fd_sc_hd__inv_2 U59 ( .A(n1158), .Y(n1166) );
  sky130_fd_sc_hd__inv_2 U60 ( .A(n1164), .Y(n1157) );
  sky130_fd_sc_hd__inv_2 U61 ( .A(n1147), .Y(n1155) );
  sky130_fd_sc_hd__inv_2 U62 ( .A(n1153), .Y(n1146) );
  sky130_fd_sc_hd__inv_2 U63 ( .A(n1136), .Y(n1144) );
  sky130_fd_sc_hd__inv_2 U64 ( .A(n1142), .Y(n1135) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(n1125), .Y(n1133) );
  sky130_fd_sc_hd__inv_2 U66 ( .A(n1131), .Y(n1124) );
  sky130_fd_sc_hd__inv_2 U67 ( .A(n1115), .Y(n1123) );
  sky130_fd_sc_hd__inv_2 U68 ( .A(n1121), .Y(n1114) );
  sky130_fd_sc_hd__buf_2 U69 ( .A(n1227), .X(n432) );
  sky130_fd_sc_hd__inv_2 U70 ( .A(n1105), .Y(n1113) );
  sky130_fd_sc_hd__inv_2 U71 ( .A(n1111), .Y(n1104) );
  sky130_fd_sc_hd__inv_2 U72 ( .A(n1095), .Y(n1103) );
  sky130_fd_sc_hd__inv_2 U73 ( .A(n1101), .Y(n1094) );
  sky130_fd_sc_hd__inv_2 U74 ( .A(n1085), .Y(n1093) );
  sky130_fd_sc_hd__inv_2 U75 ( .A(n1091), .Y(n1084) );
  sky130_fd_sc_hd__inv_2 U76 ( .A(n1075), .Y(n1083) );
  sky130_fd_sc_hd__inv_2 U77 ( .A(n1081), .Y(n1074) );
  sky130_fd_sc_hd__inv_2 U78 ( .A(n1065), .Y(n1073) );
  sky130_fd_sc_hd__inv_2 U79 ( .A(n1071), .Y(n1064) );
  sky130_fd_sc_hd__inv_2 U80 ( .A(n1052), .Y(n1062) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n1060), .Y(n1051) );
  sky130_fd_sc_hd__inv_2 U82 ( .A(n1039), .Y(n1049) );
  sky130_fd_sc_hd__inv_2 U83 ( .A(n1047), .Y(n1038) );
  sky130_fd_sc_hd__inv_2 U84 ( .A(n1029), .Y(n1037) );
  sky130_fd_sc_hd__inv_2 U85 ( .A(n1035), .Y(n1028) );
  sky130_fd_sc_hd__inv_2 U86 ( .A(n1019), .Y(n1027) );
  sky130_fd_sc_hd__inv_2 U87 ( .A(n1025), .Y(n1018) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(n1008), .Y(n1017) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(n1015), .Y(n1007) );
  sky130_fd_sc_hd__inv_2 U90 ( .A(n997), .Y(n1006) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(n1004), .Y(n996) );
  sky130_fd_sc_hd__inv_2 U92 ( .A(n986), .Y(n995) );
  sky130_fd_sc_hd__inv_2 U93 ( .A(n993), .Y(n985) );
  sky130_fd_sc_hd__buf_2 U94 ( .A(n417), .X(n441) );
  sky130_fd_sc_hd__inv_2 U95 ( .A(n975), .Y(n984) );
  sky130_fd_sc_hd__inv_2 U96 ( .A(n982), .Y(n974) );
  sky130_fd_sc_hd__inv_2 U97 ( .A(n970), .Y(n961) );
  sky130_fd_sc_hd__inv_2 U98 ( .A(n957), .Y(n948) );
  sky130_fd_sc_hd__inv_2 U99 ( .A(n945), .Y(n937) );
  sky130_fd_sc_hd__inv_2 U100 ( .A(n934), .Y(n926) );
  sky130_fd_sc_hd__inv_2 U101 ( .A(n923), .Y(n915) );
  sky130_fd_sc_hd__inv_2 U102 ( .A(n912), .Y(n904) );
  sky130_fd_sc_hd__inv_2 U103 ( .A(n901), .Y(n893) );
  sky130_fd_sc_hd__inv_2 U104 ( .A(n890), .Y(n882) );
  sky130_fd_sc_hd__inv_2 U105 ( .A(n877), .Y(n868) );
  sky130_fd_sc_hd__inv_2 U106 ( .A(n864), .Y(n855) );
  sky130_fd_sc_hd__inv_2 U107 ( .A(n844), .Y(n854) );
  sky130_fd_sc_hd__inv_2 U108 ( .A(n852), .Y(n843) );
  sky130_fd_sc_hd__inv_2 U109 ( .A(n832), .Y(n842) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(n840), .Y(n831) );
  sky130_fd_sc_hd__inv_2 U111 ( .A(n820), .Y(n830) );
  sky130_fd_sc_hd__inv_2 U112 ( .A(n828), .Y(n819) );
  sky130_fd_sc_hd__inv_2 U113 ( .A(n808), .Y(n818) );
  sky130_fd_sc_hd__inv_2 U114 ( .A(n816), .Y(n807) );
  sky130_fd_sc_hd__inv_2 U115 ( .A(n796), .Y(n806) );
  sky130_fd_sc_hd__inv_2 U116 ( .A(n804), .Y(n795) );
  sky130_fd_sc_hd__inv_2 U117 ( .A(n784), .Y(n794) );
  sky130_fd_sc_hd__inv_2 U118 ( .A(n792), .Y(n783) );
  sky130_fd_sc_hd__inv_2 U119 ( .A(n771), .Y(n781) );
  sky130_fd_sc_hd__inv_2 U120 ( .A(n779), .Y(n770) );
  sky130_fd_sc_hd__inv_2 U121 ( .A(n758), .Y(n768) );
  sky130_fd_sc_hd__inv_2 U122 ( .A(n766), .Y(n757) );
  sky130_fd_sc_hd__inv_2 U123 ( .A(n746), .Y(n756) );
  sky130_fd_sc_hd__inv_2 U124 ( .A(n754), .Y(n745) );
  sky130_fd_sc_hd__inv_2 U125 ( .A(n734), .Y(n744) );
  sky130_fd_sc_hd__inv_2 U126 ( .A(n742), .Y(n733) );
  sky130_fd_sc_hd__inv_2 U127 ( .A(n722), .Y(n732) );
  sky130_fd_sc_hd__inv_2 U128 ( .A(n730), .Y(n721) );
  sky130_fd_sc_hd__inv_2 U129 ( .A(n718), .Y(n709) );
  sky130_fd_sc_hd__inv_2 U130 ( .A(n698), .Y(n708) );
  sky130_fd_sc_hd__inv_2 U131 ( .A(n706), .Y(n697) );
  sky130_fd_sc_hd__inv_2 U132 ( .A(n686), .Y(n696) );
  sky130_fd_sc_hd__inv_2 U133 ( .A(n694), .Y(n685) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(n673), .Y(n683) );
  sky130_fd_sc_hd__inv_2 U135 ( .A(n681), .Y(n672) );
  sky130_fd_sc_hd__inv_2 U136 ( .A(n660), .Y(n670) );
  sky130_fd_sc_hd__inv_2 U137 ( .A(n668), .Y(n659) );
  sky130_fd_sc_hd__inv_2 U138 ( .A(n648), .Y(n658) );
  sky130_fd_sc_hd__inv_2 U139 ( .A(n656), .Y(n647) );
  sky130_fd_sc_hd__inv_2 U140 ( .A(n636), .Y(n646) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(n644), .Y(n635) );
  sky130_fd_sc_hd__inv_2 U142 ( .A(n624), .Y(n634) );
  sky130_fd_sc_hd__inv_2 U143 ( .A(n632), .Y(n623) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(n620), .Y(n611) );
  sky130_fd_sc_hd__inv_2 U145 ( .A(n600), .Y(n610) );
  sky130_fd_sc_hd__inv_2 U146 ( .A(n608), .Y(n599) );
  sky130_fd_sc_hd__inv_2 U147 ( .A(n588), .Y(n598) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(n596), .Y(n587) );
  sky130_fd_sc_hd__inv_2 U149 ( .A(n575), .Y(n585) );
  sky130_fd_sc_hd__inv_2 U150 ( .A(n583), .Y(n574) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(n560), .Y(n570) );
  sky130_fd_sc_hd__inv_2 U152 ( .A(n568), .Y(n559) );
  sky130_fd_sc_hd__inv_2 U153 ( .A(n547), .Y(n557) );
  sky130_fd_sc_hd__inv_2 U154 ( .A(n555), .Y(n546) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(n534), .Y(n544) );
  sky130_fd_sc_hd__inv_2 U156 ( .A(n542), .Y(n533) );
  sky130_fd_sc_hd__inv_2 U157 ( .A(n521), .Y(n531) );
  sky130_fd_sc_hd__inv_2 U158 ( .A(n529), .Y(n520) );
  sky130_fd_sc_hd__inv_2 U159 ( .A(n509), .Y(n518) );
  sky130_fd_sc_hd__inv_2 U160 ( .A(n516), .Y(n508) );
  sky130_fd_sc_hd__buf_2 U161 ( .A(n417), .X(n438) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(n496), .Y(n506) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(n504), .Y(n495) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(n493), .Y(n482) );
  sky130_fd_sc_hd__inv_1 U165 ( .A(n416), .Y(n478) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(N76), .Y(net25184) );
  sky130_fd_sc_hd__and3_1 U167 ( .A(n450), .B(n462), .C(n460), .X(n6) );
  sky130_fd_sc_hd__clkinv_1 U168 ( .A(n364), .Y(n372) );
  sky130_fd_sc_hd__clkinv_1 U169 ( .A(n374), .Y(n382) );
  sky130_fd_sc_hd__clkinv_1 U170 ( .A(n384), .Y(n392) );
  sky130_fd_sc_hd__clkinv_1 U171 ( .A(n394), .Y(n402) );
  sky130_fd_sc_hd__clkinv_1 U172 ( .A(n404), .Y(n412) );
  sky130_fd_sc_hd__inv_1 U173 ( .A(n1259), .Y(n42) );
  sky130_fd_sc_hd__and3_1 U174 ( .A(n451), .B(n450), .C(n453), .X(n7) );
  sky130_fd_sc_hd__and2_1 U175 ( .A(N79), .B(n22), .X(n8) );
  sky130_fd_sc_hd__and2_1 U176 ( .A(N80), .B(\C1342/net23438 ), .X(n9) );
  sky130_fd_sc_hd__and2_1 U177 ( .A(N80), .B(N79), .X(n10) );
  sky130_fd_sc_hd__and2_1 U178 ( .A(\C1342/net23438 ), .B(n22), .X(n11) );
  sky130_fd_sc_hd__inv_1 U179 ( .A(n460), .Y(n53) );
  sky130_fd_sc_hd__inv_2 U180 ( .A(s_mem_q[494]), .Y(n362) );
  sky130_fd_sc_hd__o22ai_1 U181 ( .A1(n1241), .A2(n493), .B1(n492), .B2(n491), 
        .Y(s_mem_d[504]) );
  sky130_fd_sc_hd__inv_2 U182 ( .A(n483), .Y(n492) );
  sky130_fd_sc_hd__inv_2 U183 ( .A(n612), .Y(n622) );
  sky130_fd_sc_hd__buf_2 U184 ( .A(n1227), .X(n428) );
  sky130_fd_sc_hd__buf_2 U185 ( .A(n1227), .X(n429) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(n710), .Y(n720) );
  sky130_fd_sc_hd__buf_6 U187 ( .A(n418), .X(n439) );
  sky130_fd_sc_hd__buf_2 U188 ( .A(n1227), .X(n430) );
  sky130_fd_sc_hd__mux2i_1 U189 ( .A0(n463), .A1(n458), .S(n460), .Y(n459) );
  sky130_fd_sc_hd__nor2_2 U190 ( .A(n12), .B(full_o), .Y(n421) );
  sky130_fd_sc_hd__nand2_2 U191 ( .A(n445), .B(n1245), .Y(n467) );
  sky130_fd_sc_hd__nand2_1 U192 ( .A(n477), .B(n1246), .Y(n474) );
  sky130_fd_sc_hd__dlygate4sd1_1 U193 ( .A(n1261), .X(cnt_o[0]) );
  sky130_fd_sc_hd__nor2_1 U194 ( .A(n14), .B(n15), .Y(n30) );
  sky130_fd_sc_hd__inv_1 U195 ( .A(\C1342/net23116 ), .Y(n16) );
  sky130_fd_sc_hd__clkinv_1 U196 ( .A(s_mem_q[105]), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U197 ( .A(n16), .B(n17), .Y(n14) );
  sky130_fd_sc_hd__clkinv_1 U198 ( .A(s_mem_q[97]), .Y(n19) );
  sky130_fd_sc_hd__nor2_1 U199 ( .A(n18), .B(n19), .Y(n15) );
  sky130_fd_sc_hd__o21ai_1 U200 ( .A1(\C1342/net23169 ), .A2(\C1342/net23170 ), 
        .B1(n11), .Y(\C1342/net23157 ) );
  sky130_fd_sc_hd__nand4_1 U201 ( .A(\C1342/net23199 ), .B(\C1342/net23200 ), 
        .C(\C1342/net23201 ), .D(\C1342/net23202 ), .Y(dat_o[2]) );
  sky130_fd_sc_hd__o21ai_1 U202 ( .A1(\C1342/net23203 ), .A2(n20), .B1(n8), 
        .Y(\C1342/net23202 ) );
  sky130_fd_sc_hd__inv_1 U203 ( .A(N80), .Y(n22) );
  sky130_fd_sc_hd__nand4_1 U204 ( .A(n21), .B(\C1342/net23208 ), .C(
        \C1342/net23207 ), .D(\C1342/net23205 ), .Y(n20) );
  sky130_fd_sc_hd__a22oi_1 U205 ( .A1(s_mem_q[154]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[146]), .B2(\C1342/net23107 ), .Y(n21) );
  sky130_fd_sc_hd__inv_4 U206 ( .A(\C1342/net23476 ), .Y(\C1342/net23107 ) );
  sky130_fd_sc_hd__nand2_1 U207 ( .A(\C1342/net23467 ), .B(\C1342/net23477 ), 
        .Y(\C1342/net23476 ) );
  sky130_fd_sc_hd__inv_2 U208 ( .A(\C1342/net23481 ), .Y(\C1342/net23477 ) );
  sky130_fd_sc_hd__nand2_1 U209 ( .A(net28404), .B(\C1342/net23477 ), .Y(
        \C1342/net23478 ) );
  sky130_fd_sc_hd__nand2_1 U210 ( .A(\C1342/net23473 ), .B(\C1342/net23477 ), 
        .Y(\C1342/net23480 ) );
  sky130_fd_sc_hd__nand2_1 U211 ( .A(\C1342/net23471 ), .B(\C1342/net23477 ), 
        .Y(\C1342/net23479 ) );
  sky130_fd_sc_hd__nand2_2 U212 ( .A(\C1342/net23475 ), .B(\C1342/net23482 ), 
        .Y(\C1342/net23481 ) );
  sky130_fd_sc_hd__inv_2 U213 ( .A(N77), .Y(\C1342/net23482 ) );
  sky130_fd_sc_hd__nor2_2 U214 ( .A(\C1342/net23475 ), .B(\C1342/net23482 ), 
        .Y(net28414) );
  sky130_fd_sc_hd__nand2_1 U215 ( .A(\C1342/net23482 ), .B(N78), .Y(
        \C1342/net23504 ) );
  sky130_fd_sc_hd__inv_1 U216 ( .A(\C1342/net23482 ), .Y(net25176) );
  sky130_fd_sc_hd__inv_2 U217 ( .A(N78), .Y(\C1342/net23475 ) );
  sky130_fd_sc_hd__dlygate4sd1_1 U218 ( .A(\C1342/net23475 ), .X(net24335) );
  sky130_fd_sc_hd__inv_2 U219 ( .A(\C1342/net23495 ), .Y(\C1342/net23467 ) );
  sky130_fd_sc_hd__nand2_1 U220 ( .A(\C1342/net23467 ), .B(\C1342/net23466 ), 
        .Y(\C1342/net23465 ) );
  sky130_fd_sc_hd__nand2_1 U221 ( .A(\C1342/net23467 ), .B(net28414), .Y(
        \C1342/net23487 ) );
  sky130_fd_sc_hd__nand2_1 U222 ( .A(\C1342/net23494 ), .B(\C1342/net23467 ), 
        .Y(\C1342/net23493 ) );
  sky130_fd_sc_hd__nand2_1 U223 ( .A(\C1342/net23496 ), .B(N76), .Y(
        \C1342/net23495 ) );
  sky130_fd_sc_hd__inv_2 U224 ( .A(N75), .Y(\C1342/net23496 ) );
  sky130_fd_sc_hd__inv_1 U225 ( .A(\C1342/net23496 ), .Y(net25158) );
  sky130_fd_sc_hd__nand2_1 U226 ( .A(\C1342/net23496 ), .B(net25184), .Y(
        \C1342/net23500 ) );
  sky130_fd_sc_hd__nor2_2 U227 ( .A(\C1342/net23496 ), .B(net25184), .Y(
        net28404) );
  sky130_fd_sc_hd__nand4_1 U228 ( .A(\C1342/net23219 ), .B(n23), .C(
        \C1342/net23222 ), .D(\C1342/net23220 ), .Y(\C1342/net23213 ) );
  sky130_fd_sc_hd__o21ai_1 U229 ( .A1(\C1342/net23213 ), .A2(\C1342/net23214 ), 
        .B1(n11), .Y(\C1342/net23201 ) );
  sky130_fd_sc_hd__a22oi_1 U230 ( .A1(s_mem_q[90]), .A2(net28392), .B1(
        s_mem_q[82]), .B2(net31356), .Y(\C1342/net23220 ) );
  sky130_fd_sc_hd__inv_2 U231 ( .A(\C1342/net23493 ), .Y(net31356) );
  sky130_fd_sc_hd__inv_2 U232 ( .A(\C1342/net23497 ), .Y(net28392) );
  sky130_fd_sc_hd__a22oi_1 U233 ( .A1(s_mem_q[122]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[114]), .B2(\C1342/net23115 ), .Y(\C1342/net23222 ) );
  sky130_fd_sc_hd__inv_2 U234 ( .A(\C1342/net23487 ), .Y(\C1342/net23115 ) );
  sky130_fd_sc_hd__inv_4 U235 ( .A(\C1342/net23489 ), .Y(\C1342/net23114 ) );
  sky130_fd_sc_hd__nand2_2 U236 ( .A(net28414), .B(net28404), .Y(
        \C1342/net23489 ) );
  sky130_fd_sc_hd__a22oi_1 U237 ( .A1(net31276), .A2(s_mem_q[106]), .B1(
        s_mem_q[98]), .B2(\C1342/net23117 ), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U238 ( .A(\C1342/net23490 ), .Y(\C1342/net23117 ) );
  sky130_fd_sc_hd__inv_2 U239 ( .A(\C1342/net23491 ), .Y(net31276) );
  sky130_fd_sc_hd__a22oi_1 U240 ( .A1(s_mem_q[74]), .A2(net31373), .B1(
        s_mem_q[66]), .B2(\C1342/net23121 ), .Y(\C1342/net23219 ) );
  sky130_fd_sc_hd__nand2_1 U241 ( .A(\C1342/net23494 ), .B(\C1342/net23471 ), 
        .Y(\C1342/net23499 ) );
  sky130_fd_sc_hd__inv_2 U242 ( .A(\C1342/net23500 ), .Y(\C1342/net23471 ) );
  sky130_fd_sc_hd__nand2_1 U243 ( .A(\C1342/net23466 ), .B(\C1342/net23471 ), 
        .Y(\C1342/net23470 ) );
  sky130_fd_sc_hd__nand2_1 U244 ( .A(\C1342/net23471 ), .B(net28414), .Y(
        \C1342/net23490 ) );
  sky130_fd_sc_hd__nand2_1 U245 ( .A(net25184), .B(N75), .Y(\C1342/net23503 )
         );
  sky130_fd_sc_hd__inv_2 U246 ( .A(\C1342/net23504 ), .Y(\C1342/net23494 ) );
  sky130_fd_sc_hd__nand2_2 U247 ( .A(\C1342/net23494 ), .B(net28404), .Y(
        \C1342/net23497 ) );
  sky130_fd_sc_hd__inv_1 U248 ( .A(N79), .Y(\C1342/net23438 ) );
  sky130_fd_sc_hd__nand4_1 U249 ( .A(\C1342/net23215 ), .B(n26), .C(n25), .D(
        n24), .Y(\C1342/net23214 ) );
  sky130_fd_sc_hd__a22oi_1 U250 ( .A1(s_mem_q[58]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[50]), .B2(\C1342/net25231 ), .Y(n26) );
  sky130_fd_sc_hd__inv_1 U251 ( .A(\C1342/net23465 ), .Y(\C1342/net25231 ) );
  sky130_fd_sc_hd__inv_2 U252 ( .A(\C1342/net23468 ), .Y(\C1342/net23102 ) );
  sky130_fd_sc_hd__and2_0 U253 ( .A(n27), .B(n28), .X(n25) );
  sky130_fd_sc_hd__nand2_1 U254 ( .A(s_mem_q[34]), .B(\C1342/net23105 ), .Y(
        n28) );
  sky130_fd_sc_hd__inv_2 U255 ( .A(\C1342/net23470 ), .Y(\C1342/net23105 ) );
  sky130_fd_sc_hd__nand2_1 U256 ( .A(s_mem_q[42]), .B(\C1342/net23104 ), .Y(
        n27) );
  sky130_fd_sc_hd__inv_2 U257 ( .A(\C1342/net23472 ), .Y(\C1342/net23104 ) );
  sky130_fd_sc_hd__a22oi_1 U258 ( .A1(s_mem_q[26]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[18]), .B2(\C1342/net23107 ), .Y(n24) );
  sky130_fd_sc_hd__inv_1 U259 ( .A(s_mem_q[106]), .Y(net23697) );
  sky130_fd_sc_hd__inv_1 U260 ( .A(s_mem_q[98]), .Y(net23685) );
  sky130_fd_sc_hd__inv_2 U261 ( .A(\C1342/net23490 ), .Y(\C1342/net25204 ) );
  sky130_fd_sc_hd__nand2_1 U262 ( .A(\C1342/net23473 ), .B(net28414), .Y(
        \C1342/net23491 ) );
  sky130_fd_sc_hd__inv_2 U263 ( .A(\C1342/net23491 ), .Y(\C1342/net23116 ) );
  sky130_fd_sc_hd__inv_2 U264 ( .A(\C1342/net23503 ), .Y(\C1342/net23473 ) );
  sky130_fd_sc_hd__nand2_1 U265 ( .A(\C1342/net23466 ), .B(\C1342/net23473 ), 
        .Y(\C1342/net23472 ) );
  sky130_fd_sc_hd__nand2b_2 U266 ( .A_N(\C1342/net23504 ), .B(\C1342/net23473 ), .Y(\C1342/net23502 ) );
  sky130_fd_sc_hd__nand4_1 U267 ( .A(\C1342/net23155 ), .B(\C1342/net23156 ), 
        .C(\C1342/net23157 ), .D(\C1342/net23158 ), .Y(dat_o[1]) );
  sky130_fd_sc_hd__o21ai_1 U268 ( .A1(\C1342/net23159 ), .A2(\C1342/net23160 ), 
        .B1(n8), .Y(\C1342/net23158 ) );
  sky130_fd_sc_hd__nand4_1 U269 ( .A(\C1342/net23164 ), .B(n29), .C(
        \C1342/net23163 ), .D(\C1342/net23161 ), .Y(\C1342/net23160 ) );
  sky130_fd_sc_hd__a22oi_1 U270 ( .A1(s_mem_q[153]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[145]), .B2(\C1342/net23107 ), .Y(n29) );
  sky130_fd_sc_hd__nand4_1 U271 ( .A(\C1342/net23175 ), .B(n30), .C(
        \C1342/net23178 ), .D(\C1342/net23176 ), .Y(\C1342/net23169 ) );
  sky130_fd_sc_hd__a22oi_1 U272 ( .A1(s_mem_q[89]), .A2(net28392), .B1(
        s_mem_q[81]), .B2(net31356), .Y(\C1342/net23176 ) );
  sky130_fd_sc_hd__a22oi_1 U273 ( .A1(s_mem_q[121]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[113]), .B2(net31290), .Y(\C1342/net23178 ) );
  sky130_fd_sc_hd__inv_2 U274 ( .A(\C1342/net23487 ), .Y(net31290) );
  sky130_fd_sc_hd__a22oi_1 U275 ( .A1(s_mem_q[73]), .A2(net31373), .B1(
        s_mem_q[65]), .B2(n3), .Y(\C1342/net23175 ) );
  sky130_fd_sc_hd__inv_2 U276 ( .A(\C1342/net23502 ), .Y(net31373) );
  sky130_fd_sc_hd__nand4_1 U277 ( .A(\C1342/net23171 ), .B(n33), .C(n32), .D(
        n31), .Y(\C1342/net23170 ) );
  sky130_fd_sc_hd__a22oi_1 U278 ( .A1(s_mem_q[57]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[49]), .B2(\C1342/net25230 ), .Y(n33) );
  sky130_fd_sc_hd__inv_1 U279 ( .A(\C1342/net23465 ), .Y(\C1342/net25230 ) );
  sky130_fd_sc_hd__a22oi_1 U280 ( .A1(s_mem_q[41]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[33]), .B2(net31378), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U281 ( .A(\C1342/net23470 ), .Y(net31378) );
  sky130_fd_sc_hd__inv_2 U282 ( .A(\C1342/net23472 ), .Y(net28409) );
  sky130_fd_sc_hd__a22oi_1 U283 ( .A1(s_mem_q[25]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[17]), .B2(\C1342/net23107 ), .Y(n31) );
  sky130_fd_sc_hd__and4b_1 U284 ( .B(n42), .C(n453), .D(n451), .A_N(n1260), 
        .X(n442) );
  sky130_fd_sc_hd__inv_2 U285 ( .A(cnt_o[2]), .Y(n453) );
  sky130_fd_sc_hd__inv_2 U286 ( .A(cnt_o[1]), .Y(n451) );
  sky130_fd_sc_hd__inv_4 U287 ( .A(\C1342/net23479 ), .Y(\C1342/net23109 ) );
  sky130_fd_sc_hd__inv_1 U288 ( .A(n1246), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U289 ( .A(\C1342/net23502 ), .Y(net31374) );
  sky130_fd_sc_hd__inv_2 U290 ( .A(\C1342/net23478 ), .Y(net31364) );
  sky130_fd_sc_hd__inv_2 U291 ( .A(\C1342/net23478 ), .Y(\C1342/net23106 ) );
  sky130_fd_sc_hd__inv_2 U292 ( .A(\C1342/net23493 ), .Y(\C1342/net23119 ) );
  sky130_fd_sc_hd__inv_1 U293 ( .A(n18), .Y(net31346) );
  sky130_fd_sc_hd__clkinv_2 U294 ( .A(n422), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U295 ( .A(n35), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U296 ( .A(n35), .Y(n37) );
  sky130_fd_sc_hd__inv_2 U297 ( .A(n856), .Y(n866) );
  sky130_fd_sc_hd__inv_2 U298 ( .A(n869), .Y(n879) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U299 ( .A(n421), .X(n427) );
  sky130_fd_sc_hd__inv_2 U300 ( .A(n883), .Y(n892) );
  sky130_fd_sc_hd__inv_2 U301 ( .A(n894), .Y(n903) );
  sky130_fd_sc_hd__inv_2 U302 ( .A(n905), .Y(n914) );
  sky130_fd_sc_hd__inv_2 U303 ( .A(n916), .Y(n925) );
  sky130_fd_sc_hd__inv_2 U304 ( .A(n927), .Y(n936) );
  sky130_fd_sc_hd__inv_2 U305 ( .A(n938), .Y(n947) );
  sky130_fd_sc_hd__inv_2 U306 ( .A(n949), .Y(n959) );
  sky130_fd_sc_hd__inv_2 U307 ( .A(n962), .Y(n972) );
  sky130_fd_sc_hd__buf_6 U308 ( .A(n418), .X(n440) );
  sky130_fd_sc_hd__nand2_1 U309 ( .A(s_mem_q[142]), .B(\C1342/net23108 ), .Y(
        n38) );
  sky130_fd_sc_hd__nand2_1 U310 ( .A(s_mem_q[134]), .B(\C1342/net23109 ), .Y(
        n39) );
  sky130_fd_sc_hd__and2_0 U311 ( .A(n38), .B(n39), .X(n280) );
  sky130_fd_sc_hd__inv_2 U312 ( .A(\C1342/net23480 ), .Y(net31297) );
  sky130_fd_sc_hd__inv_2 U313 ( .A(\C1342/net23480 ), .Y(\C1342/net23108 ) );
  sky130_fd_sc_hd__nand2_1 U314 ( .A(s_mem_q[510]), .B(\C1342/net23114 ), .Y(
        n40) );
  sky130_fd_sc_hd__nand2_1 U315 ( .A(net31290), .B(s_mem_q[502]), .Y(n41) );
  sky130_fd_sc_hd__and2_1 U316 ( .A(n40), .B(n41), .X(n307) );
  sky130_fd_sc_hd__o2bb2ai_1 U317 ( .B1(n478), .B2(net24338), .A1_N(net24338), 
        .A2_N(n477), .Y(s_rd_ptr_d[0]) );
  sky130_fd_sc_hd__a22oi_1 U318 ( .A1(s_mem_q[185]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[177]), .B2(\C1342/net25231 ), .Y(\C1342/net23164 ) );
  sky130_fd_sc_hd__inv_2 U319 ( .A(\C1342/net23468 ), .Y(net28405) );
  sky130_fd_sc_hd__a22oi_1 U320 ( .A1(s_mem_q[169]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[161]), .B2(\C1342/net23105 ), .Y(\C1342/net23163 ) );
  sky130_fd_sc_hd__inv_2 U321 ( .A(\C1342/net23474 ), .Y(\C1342/net23466 ) );
  sky130_fd_sc_hd__nand2_1 U322 ( .A(\C1342/net23466 ), .B(net28404), .Y(
        \C1342/net23468 ) );
  sky130_fd_sc_hd__nand4_1 U323 ( .A(\C1342/net23165 ), .B(\C1342/net23167 ), 
        .C(\C1342/net23168 ), .D(\C1342/net23166 ), .Y(\C1342/net23159 ) );
  sky130_fd_sc_hd__a22oi_1 U324 ( .A1(s_mem_q[217]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[209]), .B2(net31356), .Y(\C1342/net23166 ) );
  sky130_fd_sc_hd__a22oi_1 U325 ( .A1(s_mem_q[233]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[225]), .B2(\C1342/net25204 ), .Y(\C1342/net23167 ) );
  sky130_fd_sc_hd__inv_1 U326 ( .A(net25184), .Y(net25185) );
  sky130_fd_sc_hd__a22oi_1 U327 ( .A1(s_mem_q[249]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[241]), .B2(net31290), .Y(\C1342/net23168 ) );
  sky130_fd_sc_hd__inv_1 U328 ( .A(s_mem_q[249]), .Y(net23916) );
  sky130_fd_sc_hd__inv_1 U329 ( .A(s_mem_q[241]), .Y(net23904) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U330 ( .A(n421), .X(n425) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U331 ( .A(n421), .X(n423) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U332 ( .A(n421), .X(n424) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U333 ( .A(n421), .X(n426) );
  sky130_fd_sc_hd__a22oi_1 U334 ( .A1(s_mem_q[138]), .A2(net31297), .B1(
        s_mem_q[130]), .B2(\C1342/net23109 ), .Y(\C1342/net23205 ) );
  sky130_fd_sc_hd__inv_1 U335 ( .A(n42), .Y(cnt_o[6]) );
  sky130_fd_sc_hd__clkbuf_1 U336 ( .A(\C1342/net23104 ), .X(\C1342/net24844 )
         );
  sky130_fd_sc_hd__buf_2 U337 ( .A(n1227), .X(n431) );
  sky130_fd_sc_hd__nand2_1 U338 ( .A(s_mem_q[222]), .B(\C1342/net23118 ), .Y(
        n44) );
  sky130_fd_sc_hd__nand2_1 U339 ( .A(net31356), .B(s_mem_q[214]), .Y(n45) );
  sky130_fd_sc_hd__and2_0 U340 ( .A(n44), .B(n45), .X(n285) );
  sky130_fd_sc_hd__inv_2 U341 ( .A(\C1342/net23497 ), .Y(\C1342/net23118 ) );
  sky130_fd_sc_hd__nand2_1 U342 ( .A(s_mem_q[298]), .B(net28409), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U343 ( .A(s_mem_q[290]), .B(\C1342/net23105 ), .Y(
        n47) );
  sky130_fd_sc_hd__and2_0 U344 ( .A(n46), .B(n47), .X(n136) );
  sky130_fd_sc_hd__inv_1 U345 ( .A(\C1342/net23114 ), .Y(net28368) );
  sky130_fd_sc_hd__inv_1 U346 ( .A(net28368), .Y(net28369) );
  sky130_fd_sc_hd__nand2_1 U347 ( .A(s_mem_q[174]), .B(net28409), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U348 ( .A(s_mem_q[166]), .B(net31378), .Y(n50) );
  sky130_fd_sc_hd__and2_0 U349 ( .A(n49), .B(n50), .X(n282) );
  sky130_fd_sc_hd__o22ai_1 U350 ( .A1(n416), .A2(n1251), .B1(n445), .B2(n1246), 
        .Y(n51) );
  sky130_fd_sc_hd__o22ai_1 U351 ( .A1(n1251), .A2(n416), .B1(n445), .B2(n1246), 
        .Y(n52) );
  sky130_fd_sc_hd__inv_1 U352 ( .A(n444), .Y(n445) );
  sky130_fd_sc_hd__o22ai_1 U353 ( .A1(n1251), .A2(n416), .B1(n445), .B2(n1246), 
        .Y(n466) );
  sky130_fd_sc_hd__inv_1 U354 ( .A(n1259), .Y(n473) );
  sky130_fd_sc_hd__nand2_2 U355 ( .A(dat_i[7]), .B(n422), .Y(n1227) );
  sky130_fd_sc_hd__nand2_1 U356 ( .A(n442), .B(n6), .Y(n1255) );
  sky130_fd_sc_hd__inv_2 U357 ( .A(cnt_o[4]), .Y(n462) );
  sky130_fd_sc_hd__inv_1 U358 ( .A(cnt_o[3]), .Y(n460) );
  sky130_fd_sc_hd__clkinv_1 U359 ( .A(n1255), .Y(empty_o) );
  sky130_fd_sc_hd__nand4_1 U360 ( .A(n54), .B(n55), .C(n56), .D(n57), .Y(
        dat_o[0]) );
  sky130_fd_sc_hd__o21ai_1 U361 ( .A1(n58), .A2(n59), .B1(n8), .Y(n57) );
  sky130_fd_sc_hd__nand4_1 U362 ( .A(n60), .B(n61), .C(n62), .D(n63), .Y(n59)
         );
  sky130_fd_sc_hd__a22oi_1 U363 ( .A1(s_mem_q[184]), .A2(net28405), .B1(
        s_mem_q[176]), .B2(\C1342/net23103 ), .Y(n63) );
  sky130_fd_sc_hd__a22oi_1 U364 ( .A1(s_mem_q[168]), .A2(\C1342/net24844 ), 
        .B1(s_mem_q[160]), .B2(\C1342/net23105 ), .Y(n62) );
  sky130_fd_sc_hd__a22oi_1 U365 ( .A1(s_mem_q[152]), .A2(net31364), .B1(
        s_mem_q[144]), .B2(\C1342/net23107 ), .Y(n61) );
  sky130_fd_sc_hd__a22oi_1 U366 ( .A1(s_mem_q[136]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[128]), .B2(\C1342/net23109 ), .Y(n60) );
  sky130_fd_sc_hd__nand4_1 U367 ( .A(n64), .B(n65), .C(n66), .D(n67), .Y(n58)
         );
  sky130_fd_sc_hd__a22oi_1 U368 ( .A1(s_mem_q[248]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[240]), .B2(net31290), .Y(n67) );
  sky130_fd_sc_hd__a22oi_1 U369 ( .A1(s_mem_q[232]), .A2(net28383), .B1(
        s_mem_q[224]), .B2(\C1342/net23117 ), .Y(n66) );
  sky130_fd_sc_hd__a22oi_1 U370 ( .A1(s_mem_q[216]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[208]), .B2(\C1342/net23119 ), .Y(n65) );
  sky130_fd_sc_hd__a22oi_1 U371 ( .A1(s_mem_q[200]), .A2(net31373), .B1(
        s_mem_q[192]), .B2(n3), .Y(n64) );
  sky130_fd_sc_hd__o21ai_1 U372 ( .A1(n68), .A2(n69), .B1(n11), .Y(n56) );
  sky130_fd_sc_hd__nand4_1 U373 ( .A(n70), .B(n71), .C(n72), .D(n73), .Y(n69)
         );
  sky130_fd_sc_hd__a22oi_1 U374 ( .A1(s_mem_q[56]), .A2(net28405), .B1(
        s_mem_q[48]), .B2(\C1342/net25231 ), .Y(n73) );
  sky130_fd_sc_hd__a22oi_1 U375 ( .A1(s_mem_q[40]), .A2(\C1342/net24842 ), 
        .B1(s_mem_q[32]), .B2(net31378), .Y(n72) );
  sky130_fd_sc_hd__a22oi_1 U376 ( .A1(s_mem_q[24]), .A2(net31364), .B1(
        s_mem_q[16]), .B2(\C1342/net23107 ), .Y(n71) );
  sky130_fd_sc_hd__a22oi_1 U377 ( .A1(s_mem_q[8]), .A2(\C1342/net23108 ), .B1(
        s_mem_q[0]), .B2(\C1342/net23109 ), .Y(n70) );
  sky130_fd_sc_hd__nand4_1 U378 ( .A(n74), .B(n75), .C(n76), .D(n77), .Y(n68)
         );
  sky130_fd_sc_hd__a22oi_1 U379 ( .A1(s_mem_q[120]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[112]), .B2(net31290), .Y(n77) );
  sky130_fd_sc_hd__a22oi_1 U380 ( .A1(s_mem_q[104]), .A2(net28383), .B1(
        s_mem_q[96]), .B2(net31346), .Y(n76) );
  sky130_fd_sc_hd__a22oi_1 U381 ( .A1(s_mem_q[88]), .A2(net28392), .B1(
        s_mem_q[80]), .B2(\C1342/net23119 ), .Y(n75) );
  sky130_fd_sc_hd__a22oi_1 U382 ( .A1(s_mem_q[72]), .A2(net31374), .B1(
        s_mem_q[64]), .B2(\C1342/net23121 ), .Y(n74) );
  sky130_fd_sc_hd__o21ai_1 U383 ( .A1(n78), .A2(n79), .B1(n10), .Y(n55) );
  sky130_fd_sc_hd__nand4_1 U384 ( .A(n80), .B(n81), .C(n82), .D(n83), .Y(n79)
         );
  sky130_fd_sc_hd__a22oi_1 U385 ( .A1(s_mem_q[440]), .A2(net28405), .B1(
        s_mem_q[432]), .B2(\C1342/net25230 ), .Y(n83) );
  sky130_fd_sc_hd__a22oi_1 U386 ( .A1(s_mem_q[424]), .A2(\C1342/net24844 ), 
        .B1(s_mem_q[416]), .B2(\C1342/net23105 ), .Y(n82) );
  sky130_fd_sc_hd__a22oi_1 U387 ( .A1(s_mem_q[408]), .A2(n2), .B1(s_mem_q[400]), .B2(\C1342/net23107 ), .Y(n81) );
  sky130_fd_sc_hd__a22oi_1 U388 ( .A1(s_mem_q[392]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[384]), .B2(\C1342/net23109 ), .Y(n80) );
  sky130_fd_sc_hd__nand4_1 U389 ( .A(n84), .B(n85), .C(n86), .D(n87), .Y(n78)
         );
  sky130_fd_sc_hd__a22oi_1 U390 ( .A1(s_mem_q[504]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[496]), .B2(\C1342/net23115 ), .Y(n87) );
  sky130_fd_sc_hd__a22oi_1 U391 ( .A1(s_mem_q[488]), .A2(net28383), .B1(
        s_mem_q[480]), .B2(\C1342/net23117 ), .Y(n86) );
  sky130_fd_sc_hd__a22oi_1 U392 ( .A1(s_mem_q[472]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[464]), .B2(\C1342/net23119 ), .Y(n85) );
  sky130_fd_sc_hd__a22oi_1 U393 ( .A1(s_mem_q[456]), .A2(net31373), .B1(
        s_mem_q[448]), .B2(n3), .Y(n84) );
  sky130_fd_sc_hd__o21ai_1 U394 ( .A1(n88), .A2(n89), .B1(n9), .Y(n54) );
  sky130_fd_sc_hd__nand4_1 U395 ( .A(n90), .B(n91), .C(n92), .D(n93), .Y(n89)
         );
  sky130_fd_sc_hd__a22oi_1 U396 ( .A1(s_mem_q[312]), .A2(net28405), .B1(
        s_mem_q[304]), .B2(\C1342/net23103 ), .Y(n93) );
  sky130_fd_sc_hd__a22oi_1 U397 ( .A1(s_mem_q[296]), .A2(\C1342/net24842 ), 
        .B1(s_mem_q[288]), .B2(net31378), .Y(n92) );
  sky130_fd_sc_hd__a22oi_1 U398 ( .A1(s_mem_q[280]), .A2(n2), .B1(s_mem_q[272]), .B2(\C1342/net23107 ), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U399 ( .A1(s_mem_q[264]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[256]), .B2(\C1342/net23109 ), .Y(n90) );
  sky130_fd_sc_hd__nand4_1 U400 ( .A(n94), .B(n95), .C(n96), .D(n97), .Y(n88)
         );
  sky130_fd_sc_hd__a22oi_1 U401 ( .A1(s_mem_q[376]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[368]), .B2(net31290), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U402 ( .A1(s_mem_q[360]), .A2(net31276), .B1(
        s_mem_q[352]), .B2(net31346), .Y(n96) );
  sky130_fd_sc_hd__a22oi_1 U403 ( .A1(s_mem_q[344]), .A2(net28392), .B1(
        s_mem_q[336]), .B2(\C1342/net23119 ), .Y(n95) );
  sky130_fd_sc_hd__a22oi_1 U404 ( .A1(s_mem_q[328]), .A2(net31373), .B1(
        s_mem_q[320]), .B2(\C1342/net23121 ), .Y(n94) );
  sky130_fd_sc_hd__a22oi_1 U405 ( .A1(s_mem_q[137]), .A2(net31297), .B1(
        s_mem_q[129]), .B2(\C1342/net23109 ), .Y(\C1342/net23161 ) );
  sky130_fd_sc_hd__a22oi_1 U406 ( .A1(s_mem_q[201]), .A2(net31373), .B1(
        s_mem_q[193]), .B2(n3), .Y(\C1342/net23165 ) );
  sky130_fd_sc_hd__a22oi_1 U407 ( .A1(s_mem_q[9]), .A2(net31297), .B1(
        s_mem_q[1]), .B2(\C1342/net23109 ), .Y(\C1342/net23171 ) );
  sky130_fd_sc_hd__o21ai_1 U408 ( .A1(n98), .A2(n99), .B1(n10), .Y(
        \C1342/net23156 ) );
  sky130_fd_sc_hd__nand4_1 U409 ( .A(n100), .B(n101), .C(n102), .D(n103), .Y(
        n99) );
  sky130_fd_sc_hd__a22oi_1 U410 ( .A1(s_mem_q[441]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[433]), .B2(\C1342/net25230 ), .Y(n103) );
  sky130_fd_sc_hd__a22oi_1 U411 ( .A1(s_mem_q[425]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[417]), .B2(net31378), .Y(n102) );
  sky130_fd_sc_hd__a22oi_1 U412 ( .A1(s_mem_q[409]), .A2(net31364), .B1(
        s_mem_q[401]), .B2(\C1342/net23107 ), .Y(n101) );
  sky130_fd_sc_hd__a22oi_1 U413 ( .A1(s_mem_q[393]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[385]), .B2(\C1342/net23109 ), .Y(n100) );
  sky130_fd_sc_hd__nand4_1 U414 ( .A(n106), .B(n104), .C(n105), .D(n107), .Y(
        n98) );
  sky130_fd_sc_hd__a22oi_1 U415 ( .A1(s_mem_q[505]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[497]), .B2(net31290), .Y(n107) );
  sky130_fd_sc_hd__a22oi_1 U416 ( .A1(s_mem_q[489]), .A2(net31276), .B1(
        s_mem_q[481]), .B2(\C1342/net25204 ), .Y(n106) );
  sky130_fd_sc_hd__a22oi_1 U417 ( .A1(s_mem_q[473]), .A2(net28392), .B1(
        s_mem_q[465]), .B2(net31356), .Y(n105) );
  sky130_fd_sc_hd__a22oi_1 U418 ( .A1(s_mem_q[457]), .A2(net31373), .B1(
        s_mem_q[449]), .B2(\C1342/net23121 ), .Y(n104) );
  sky130_fd_sc_hd__o21ai_1 U419 ( .A1(n108), .A2(n109), .B1(n9), .Y(
        \C1342/net23155 ) );
  sky130_fd_sc_hd__nand4_1 U420 ( .A(n110), .B(n111), .C(n112), .D(n113), .Y(
        n109) );
  sky130_fd_sc_hd__a22oi_1 U421 ( .A1(s_mem_q[313]), .A2(net28405), .B1(
        s_mem_q[305]), .B2(\C1342/net25230 ), .Y(n113) );
  sky130_fd_sc_hd__a22oi_1 U422 ( .A1(s_mem_q[297]), .A2(net28409), .B1(
        s_mem_q[289]), .B2(\C1342/net23105 ), .Y(n112) );
  sky130_fd_sc_hd__a22oi_1 U423 ( .A1(s_mem_q[281]), .A2(net31364), .B1(
        s_mem_q[273]), .B2(\C1342/net23107 ), .Y(n111) );
  sky130_fd_sc_hd__a22oi_1 U424 ( .A1(s_mem_q[265]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[257]), .B2(\C1342/net23109 ), .Y(n110) );
  sky130_fd_sc_hd__nand4_1 U425 ( .A(n114), .B(n115), .C(n116), .D(n117), .Y(
        n108) );
  sky130_fd_sc_hd__a22oi_1 U426 ( .A1(s_mem_q[377]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[369]), .B2(net31290), .Y(n117) );
  sky130_fd_sc_hd__a22oi_1 U427 ( .A1(s_mem_q[361]), .A2(net31276), .B1(
        s_mem_q[353]), .B2(\C1342/net25204 ), .Y(n116) );
  sky130_fd_sc_hd__a22oi_1 U428 ( .A1(s_mem_q[345]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[337]), .B2(\C1342/net23119 ), .Y(n115) );
  sky130_fd_sc_hd__a22oi_1 U429 ( .A1(s_mem_q[329]), .A2(net31373), .B1(
        s_mem_q[321]), .B2(\C1342/net23121 ), .Y(n114) );
  sky130_fd_sc_hd__a22oi_1 U430 ( .A1(s_mem_q[186]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[178]), .B2(\C1342/net23103 ), .Y(\C1342/net23208 ) );
  sky130_fd_sc_hd__a22oi_1 U431 ( .A1(s_mem_q[170]), .A2(net28409), .B1(
        s_mem_q[162]), .B2(net31378), .Y(\C1342/net23207 ) );
  sky130_fd_sc_hd__nand4_1 U432 ( .A(n118), .B(n120), .C(n121), .D(n119), .Y(
        \C1342/net23203 ) );
  sky130_fd_sc_hd__a22oi_1 U433 ( .A1(s_mem_q[250]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[242]), .B2(net31290), .Y(n121) );
  sky130_fd_sc_hd__a22oi_1 U434 ( .A1(s_mem_q[234]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[226]), .B2(\C1342/net25204 ), .Y(n120) );
  sky130_fd_sc_hd__a22oi_1 U435 ( .A1(s_mem_q[218]), .A2(net28392), .B1(
        s_mem_q[210]), .B2(net31356), .Y(n119) );
  sky130_fd_sc_hd__a22oi_1 U436 ( .A1(s_mem_q[202]), .A2(net31374), .B1(
        s_mem_q[194]), .B2(\C1342/net23121 ), .Y(n118) );
  sky130_fd_sc_hd__a22oi_1 U437 ( .A1(s_mem_q[10]), .A2(net31297), .B1(
        s_mem_q[2]), .B2(\C1342/net23109 ), .Y(\C1342/net23215 ) );
  sky130_fd_sc_hd__o21ai_1 U438 ( .A1(n122), .A2(n123), .B1(n10), .Y(
        \C1342/net23200 ) );
  sky130_fd_sc_hd__nand4_1 U439 ( .A(n127), .B(n124), .C(n126), .D(n125), .Y(
        n123) );
  sky130_fd_sc_hd__a22oi_1 U440 ( .A1(s_mem_q[442]), .A2(net28405), .B1(
        s_mem_q[434]), .B2(\C1342/net25231 ), .Y(n127) );
  sky130_fd_sc_hd__a22oi_1 U441 ( .A1(s_mem_q[426]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[418]), .B2(\C1342/net23105 ), .Y(n126) );
  sky130_fd_sc_hd__a22oi_1 U442 ( .A1(s_mem_q[410]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[402]), .B2(\C1342/net23107 ), .Y(n125) );
  sky130_fd_sc_hd__a22oi_1 U443 ( .A1(s_mem_q[394]), .A2(net31297), .B1(
        s_mem_q[386]), .B2(\C1342/net23109 ), .Y(n124) );
  sky130_fd_sc_hd__nand4_1 U444 ( .A(n130), .B(n128), .C(n129), .D(n131), .Y(
        n122) );
  sky130_fd_sc_hd__a22oi_1 U445 ( .A1(s_mem_q[506]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[498]), .B2(\C1342/net23115 ), .Y(n131) );
  sky130_fd_sc_hd__a22oi_1 U446 ( .A1(s_mem_q[490]), .A2(net31276), .B1(
        s_mem_q[482]), .B2(\C1342/net23117 ), .Y(n130) );
  sky130_fd_sc_hd__a22oi_1 U447 ( .A1(s_mem_q[474]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[466]), .B2(\C1342/net23119 ), .Y(n129) );
  sky130_fd_sc_hd__a22oi_1 U448 ( .A1(s_mem_q[458]), .A2(net31374), .B1(
        s_mem_q[450]), .B2(n3), .Y(n128) );
  sky130_fd_sc_hd__o21ai_1 U449 ( .A1(n132), .A2(n133), .B1(n9), .Y(
        \C1342/net23199 ) );
  sky130_fd_sc_hd__nand4_1 U450 ( .A(n134), .B(n135), .C(n136), .D(n137), .Y(
        n133) );
  sky130_fd_sc_hd__a22oi_1 U451 ( .A1(s_mem_q[314]), .A2(net28405), .B1(
        s_mem_q[306]), .B2(\C1342/net25231 ), .Y(n137) );
  sky130_fd_sc_hd__a22oi_1 U452 ( .A1(s_mem_q[282]), .A2(net31364), .B1(
        s_mem_q[274]), .B2(\C1342/net23107 ), .Y(n135) );
  sky130_fd_sc_hd__a22oi_1 U453 ( .A1(s_mem_q[266]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[258]), .B2(\C1342/net23109 ), .Y(n134) );
  sky130_fd_sc_hd__nand4_1 U454 ( .A(n138), .B(n139), .C(n140), .D(n141), .Y(
        n132) );
  sky130_fd_sc_hd__a22oi_1 U455 ( .A1(s_mem_q[378]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[370]), .B2(\C1342/net23115 ), .Y(n141) );
  sky130_fd_sc_hd__a22oi_1 U456 ( .A1(s_mem_q[362]), .A2(net31276), .B1(
        s_mem_q[354]), .B2(\C1342/net23117 ), .Y(n140) );
  sky130_fd_sc_hd__a22oi_1 U457 ( .A1(s_mem_q[346]), .A2(net28392), .B1(
        s_mem_q[338]), .B2(\C1342/net23119 ), .Y(n139) );
  sky130_fd_sc_hd__a22oi_1 U458 ( .A1(s_mem_q[330]), .A2(net31373), .B1(
        s_mem_q[322]), .B2(n3), .Y(n138) );
  sky130_fd_sc_hd__nand4_1 U459 ( .A(n142), .B(n143), .C(n145), .D(n144), .Y(
        dat_o[3]) );
  sky130_fd_sc_hd__o21ai_1 U460 ( .A1(n146), .A2(n147), .B1(n8), .Y(n145) );
  sky130_fd_sc_hd__nand4_1 U461 ( .A(n151), .B(n149), .C(n150), .D(n148), .Y(
        n147) );
  sky130_fd_sc_hd__a22oi_1 U462 ( .A1(s_mem_q[187]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[179]), .B2(\C1342/net25231 ), .Y(n151) );
  sky130_fd_sc_hd__a22oi_1 U463 ( .A1(s_mem_q[171]), .A2(net28409), .B1(
        s_mem_q[163]), .B2(net31378), .Y(n150) );
  sky130_fd_sc_hd__a22oi_1 U464 ( .A1(s_mem_q[155]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[147]), .B2(\C1342/net23107 ), .Y(n149) );
  sky130_fd_sc_hd__a22oi_1 U465 ( .A1(s_mem_q[139]), .A2(net31297), .B1(
        s_mem_q[131]), .B2(\C1342/net23109 ), .Y(n148) );
  sky130_fd_sc_hd__nand4_1 U466 ( .A(n152), .B(n155), .C(n154), .D(n153), .Y(
        n146) );
  sky130_fd_sc_hd__a22oi_1 U467 ( .A1(s_mem_q[251]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[243]), .B2(net31290), .Y(n155) );
  sky130_fd_sc_hd__a22oi_1 U468 ( .A1(s_mem_q[235]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[227]), .B2(\C1342/net25204 ), .Y(n154) );
  sky130_fd_sc_hd__a22oi_1 U469 ( .A1(s_mem_q[219]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[211]), .B2(net31356), .Y(n153) );
  sky130_fd_sc_hd__a22oi_1 U470 ( .A1(s_mem_q[203]), .A2(net31374), .B1(
        s_mem_q[195]), .B2(\C1342/net23121 ), .Y(n152) );
  sky130_fd_sc_hd__o21ai_1 U471 ( .A1(n156), .A2(n157), .B1(n11), .Y(n144) );
  sky130_fd_sc_hd__nand4_1 U472 ( .A(n161), .B(n159), .C(n160), .D(n158), .Y(
        n157) );
  sky130_fd_sc_hd__a22oi_1 U473 ( .A1(s_mem_q[59]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[51]), .B2(\C1342/net23103 ), .Y(n161) );
  sky130_fd_sc_hd__a22oi_1 U474 ( .A1(s_mem_q[43]), .A2(net28409), .B1(
        s_mem_q[35]), .B2(net31378), .Y(n160) );
  sky130_fd_sc_hd__a22oi_1 U475 ( .A1(s_mem_q[27]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[19]), .B2(\C1342/net23107 ), .Y(n159) );
  sky130_fd_sc_hd__a22oi_1 U476 ( .A1(s_mem_q[11]), .A2(net31297), .B1(
        s_mem_q[3]), .B2(\C1342/net23109 ), .Y(n158) );
  sky130_fd_sc_hd__nand4_1 U477 ( .A(n162), .B(n164), .C(n165), .D(n163), .Y(
        n156) );
  sky130_fd_sc_hd__a22oi_1 U478 ( .A1(s_mem_q[123]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[115]), .B2(net31290), .Y(n165) );
  sky130_fd_sc_hd__a22oi_1 U479 ( .A1(s_mem_q[107]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[99]), .B2(\C1342/net25204 ), .Y(n164) );
  sky130_fd_sc_hd__a22oi_1 U480 ( .A1(s_mem_q[91]), .A2(net28392), .B1(
        s_mem_q[83]), .B2(net31356), .Y(n163) );
  sky130_fd_sc_hd__a22oi_1 U481 ( .A1(s_mem_q[75]), .A2(net31373), .B1(
        s_mem_q[67]), .B2(n3), .Y(n162) );
  sky130_fd_sc_hd__o21ai_1 U482 ( .A1(n166), .A2(n167), .B1(n10), .Y(n143) );
  sky130_fd_sc_hd__nand4_1 U483 ( .A(n168), .B(n169), .C(n170), .D(n171), .Y(
        n167) );
  sky130_fd_sc_hd__a22oi_1 U484 ( .A1(s_mem_q[443]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[435]), .B2(\C1342/net25230 ), .Y(n171) );
  sky130_fd_sc_hd__a22oi_1 U485 ( .A1(s_mem_q[427]), .A2(net28409), .B1(
        s_mem_q[419]), .B2(\C1342/net23105 ), .Y(n170) );
  sky130_fd_sc_hd__a22oi_1 U486 ( .A1(s_mem_q[411]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[403]), .B2(\C1342/net23107 ), .Y(n169) );
  sky130_fd_sc_hd__a22oi_1 U487 ( .A1(s_mem_q[395]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[387]), .B2(\C1342/net23109 ), .Y(n168) );
  sky130_fd_sc_hd__nand4_1 U488 ( .A(n174), .B(n172), .C(n173), .D(n175), .Y(
        n166) );
  sky130_fd_sc_hd__a22oi_1 U489 ( .A1(s_mem_q[507]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[499]), .B2(\C1342/net23115 ), .Y(n175) );
  sky130_fd_sc_hd__a22oi_1 U490 ( .A1(s_mem_q[491]), .A2(net31276), .B1(
        s_mem_q[483]), .B2(\C1342/net23117 ), .Y(n174) );
  sky130_fd_sc_hd__a22oi_1 U491 ( .A1(s_mem_q[475]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[467]), .B2(net31356), .Y(n173) );
  sky130_fd_sc_hd__a22oi_1 U492 ( .A1(s_mem_q[459]), .A2(net31374), .B1(
        s_mem_q[451]), .B2(\C1342/net23121 ), .Y(n172) );
  sky130_fd_sc_hd__o21ai_1 U493 ( .A1(n176), .A2(n177), .B1(n9), .Y(n142) );
  sky130_fd_sc_hd__nand4_1 U494 ( .A(n178), .B(n179), .C(n180), .D(n181), .Y(
        n177) );
  sky130_fd_sc_hd__a22oi_1 U495 ( .A1(s_mem_q[315]), .A2(net28405), .B1(
        s_mem_q[307]), .B2(\C1342/net25230 ), .Y(n181) );
  sky130_fd_sc_hd__a22oi_1 U496 ( .A1(s_mem_q[299]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[291]), .B2(\C1342/net23105 ), .Y(n180) );
  sky130_fd_sc_hd__a22oi_1 U497 ( .A1(s_mem_q[283]), .A2(net31364), .B1(
        s_mem_q[275]), .B2(\C1342/net23107 ), .Y(n179) );
  sky130_fd_sc_hd__a22oi_1 U498 ( .A1(s_mem_q[267]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[259]), .B2(\C1342/net23109 ), .Y(n178) );
  sky130_fd_sc_hd__nand4_1 U499 ( .A(n182), .B(n183), .C(n184), .D(n185), .Y(
        n176) );
  sky130_fd_sc_hd__a22oi_1 U500 ( .A1(s_mem_q[379]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[371]), .B2(net31290), .Y(n185) );
  sky130_fd_sc_hd__a22oi_1 U501 ( .A1(s_mem_q[363]), .A2(net31276), .B1(
        s_mem_q[355]), .B2(\C1342/net23117 ), .Y(n184) );
  sky130_fd_sc_hd__a22oi_1 U502 ( .A1(s_mem_q[347]), .A2(net28392), .B1(
        s_mem_q[339]), .B2(\C1342/net23119 ), .Y(n183) );
  sky130_fd_sc_hd__a22oi_1 U503 ( .A1(s_mem_q[331]), .A2(net31374), .B1(
        s_mem_q[323]), .B2(\C1342/net23121 ), .Y(n182) );
  sky130_fd_sc_hd__nand4_1 U504 ( .A(n186), .B(n187), .C(n189), .D(n188), .Y(
        dat_o[4]) );
  sky130_fd_sc_hd__o21ai_1 U505 ( .A1(n190), .A2(n191), .B1(n8), .Y(n189) );
  sky130_fd_sc_hd__nand4_1 U506 ( .A(n193), .B(n195), .C(n194), .D(n192), .Y(
        n191) );
  sky130_fd_sc_hd__a22oi_1 U507 ( .A1(s_mem_q[188]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[180]), .B2(\C1342/net25230 ), .Y(n195) );
  sky130_fd_sc_hd__a22oi_1 U508 ( .A1(s_mem_q[172]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[164]), .B2(\C1342/net23105 ), .Y(n194) );
  sky130_fd_sc_hd__a22oi_1 U509 ( .A1(s_mem_q[156]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[148]), .B2(\C1342/net23107 ), .Y(n193) );
  sky130_fd_sc_hd__a22oi_1 U510 ( .A1(s_mem_q[140]), .A2(net31297), .B1(
        s_mem_q[132]), .B2(\C1342/net23109 ), .Y(n192) );
  sky130_fd_sc_hd__nand4_1 U511 ( .A(n196), .B(n198), .C(n199), .D(n197), .Y(
        n190) );
  sky130_fd_sc_hd__a22oi_1 U512 ( .A1(s_mem_q[252]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[244]), .B2(net31290), .Y(n199) );
  sky130_fd_sc_hd__a22oi_1 U513 ( .A1(s_mem_q[236]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[228]), .B2(\C1342/net25204 ), .Y(n198) );
  sky130_fd_sc_hd__a22oi_1 U514 ( .A1(s_mem_q[220]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[212]), .B2(net31356), .Y(n197) );
  sky130_fd_sc_hd__a22oi_1 U515 ( .A1(s_mem_q[204]), .A2(net31373), .B1(
        s_mem_q[196]), .B2(\C1342/net23121 ), .Y(n196) );
  sky130_fd_sc_hd__o21ai_1 U516 ( .A1(n200), .A2(n201), .B1(n11), .Y(n188) );
  sky130_fd_sc_hd__nand4_1 U517 ( .A(n205), .B(n203), .C(n204), .D(n202), .Y(
        n201) );
  sky130_fd_sc_hd__a22oi_1 U518 ( .A1(s_mem_q[60]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[52]), .B2(\C1342/net25230 ), .Y(n205) );
  sky130_fd_sc_hd__a22oi_1 U519 ( .A1(s_mem_q[44]), .A2(net28409), .B1(
        s_mem_q[36]), .B2(net31378), .Y(n204) );
  sky130_fd_sc_hd__a22oi_1 U520 ( .A1(s_mem_q[28]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[20]), .B2(\C1342/net23107 ), .Y(n203) );
  sky130_fd_sc_hd__a22oi_1 U521 ( .A1(s_mem_q[12]), .A2(net31297), .B1(
        s_mem_q[4]), .B2(\C1342/net23109 ), .Y(n202) );
  sky130_fd_sc_hd__nand4_1 U522 ( .A(n206), .B(n209), .C(n208), .D(n207), .Y(
        n200) );
  sky130_fd_sc_hd__a22oi_1 U523 ( .A1(s_mem_q[124]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[116]), .B2(\C1342/net23115 ), .Y(n209) );
  sky130_fd_sc_hd__a22oi_1 U524 ( .A1(s_mem_q[108]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[100]), .B2(\C1342/net23117 ), .Y(n208) );
  sky130_fd_sc_hd__a22oi_1 U525 ( .A1(s_mem_q[92]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[84]), .B2(net31356), .Y(n207) );
  sky130_fd_sc_hd__a22oi_1 U526 ( .A1(s_mem_q[76]), .A2(net31374), .B1(
        s_mem_q[68]), .B2(\C1342/net23121 ), .Y(n206) );
  sky130_fd_sc_hd__o21ai_1 U527 ( .A1(n210), .A2(n211), .B1(n10), .Y(n187) );
  sky130_fd_sc_hd__nand4_1 U528 ( .A(n215), .B(n213), .C(n214), .D(n212), .Y(
        n211) );
  sky130_fd_sc_hd__a22oi_1 U529 ( .A1(s_mem_q[444]), .A2(net28405), .B1(
        s_mem_q[436]), .B2(\C1342/net25231 ), .Y(n215) );
  sky130_fd_sc_hd__a22oi_1 U530 ( .A1(s_mem_q[428]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[420]), .B2(net31378), .Y(n214) );
  sky130_fd_sc_hd__a22oi_1 U531 ( .A1(s_mem_q[412]), .A2(net31364), .B1(
        s_mem_q[404]), .B2(\C1342/net23107 ), .Y(n213) );
  sky130_fd_sc_hd__a22oi_1 U532 ( .A1(s_mem_q[396]), .A2(net31297), .B1(
        s_mem_q[388]), .B2(\C1342/net23109 ), .Y(n212) );
  sky130_fd_sc_hd__nand4_1 U533 ( .A(n218), .B(n216), .C(n217), .D(n219), .Y(
        n210) );
  sky130_fd_sc_hd__a22oi_1 U534 ( .A1(s_mem_q[508]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[500]), .B2(net31290), .Y(n219) );
  sky130_fd_sc_hd__a22oi_1 U535 ( .A1(s_mem_q[492]), .A2(net31276), .B1(
        s_mem_q[484]), .B2(\C1342/net25204 ), .Y(n218) );
  sky130_fd_sc_hd__a22oi_1 U536 ( .A1(s_mem_q[476]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[468]), .B2(\C1342/net23119 ), .Y(n217) );
  sky130_fd_sc_hd__a22oi_1 U537 ( .A1(s_mem_q[460]), .A2(net31374), .B1(
        s_mem_q[452]), .B2(n3), .Y(n216) );
  sky130_fd_sc_hd__o21ai_1 U538 ( .A1(n220), .A2(n221), .B1(n9), .Y(n186) );
  sky130_fd_sc_hd__nand4_1 U539 ( .A(n222), .B(n223), .C(n224), .D(n225), .Y(
        n221) );
  sky130_fd_sc_hd__a22oi_1 U540 ( .A1(s_mem_q[316]), .A2(net28405), .B1(
        s_mem_q[308]), .B2(\C1342/net25231 ), .Y(n225) );
  sky130_fd_sc_hd__a22oi_1 U541 ( .A1(s_mem_q[300]), .A2(net28409), .B1(
        s_mem_q[292]), .B2(net31378), .Y(n224) );
  sky130_fd_sc_hd__a22oi_1 U542 ( .A1(s_mem_q[284]), .A2(net31364), .B1(
        s_mem_q[276]), .B2(\C1342/net23107 ), .Y(n223) );
  sky130_fd_sc_hd__a22oi_1 U543 ( .A1(s_mem_q[268]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[260]), .B2(\C1342/net23109 ), .Y(n222) );
  sky130_fd_sc_hd__nand4_1 U544 ( .A(n226), .B(n227), .C(n228), .D(n229), .Y(
        n220) );
  sky130_fd_sc_hd__a22oi_1 U545 ( .A1(s_mem_q[380]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[372]), .B2(\C1342/net23115 ), .Y(n229) );
  sky130_fd_sc_hd__a22oi_1 U546 ( .A1(s_mem_q[364]), .A2(net31276), .B1(
        s_mem_q[356]), .B2(\C1342/net25204 ), .Y(n228) );
  sky130_fd_sc_hd__a22oi_1 U547 ( .A1(s_mem_q[348]), .A2(net28392), .B1(
        s_mem_q[340]), .B2(\C1342/net23119 ), .Y(n227) );
  sky130_fd_sc_hd__a22oi_1 U548 ( .A1(s_mem_q[332]), .A2(net31374), .B1(
        s_mem_q[324]), .B2(n3), .Y(n226) );
  sky130_fd_sc_hd__nand4_1 U549 ( .A(n230), .B(n231), .C(n232), .D(n233), .Y(
        dat_o[5]) );
  sky130_fd_sc_hd__o21ai_1 U550 ( .A1(n234), .A2(n235), .B1(n8), .Y(n233) );
  sky130_fd_sc_hd__nand4_1 U551 ( .A(n239), .B(n237), .C(n238), .D(n236), .Y(
        n235) );
  sky130_fd_sc_hd__a22oi_1 U552 ( .A1(s_mem_q[189]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[181]), .B2(\C1342/net25231 ), .Y(n239) );
  sky130_fd_sc_hd__a22oi_1 U553 ( .A1(s_mem_q[173]), .A2(net28409), .B1(
        s_mem_q[165]), .B2(\C1342/net23105 ), .Y(n238) );
  sky130_fd_sc_hd__a22oi_1 U554 ( .A1(s_mem_q[157]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[149]), .B2(\C1342/net23107 ), .Y(n237) );
  sky130_fd_sc_hd__a22oi_1 U555 ( .A1(s_mem_q[141]), .A2(net31297), .B1(
        s_mem_q[133]), .B2(\C1342/net23109 ), .Y(n236) );
  sky130_fd_sc_hd__nand4_1 U556 ( .A(n240), .B(n242), .C(n243), .D(n241), .Y(
        n234) );
  sky130_fd_sc_hd__a22oi_1 U557 ( .A1(s_mem_q[253]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[245]), .B2(net31290), .Y(n243) );
  sky130_fd_sc_hd__a22oi_1 U558 ( .A1(s_mem_q[237]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[229]), .B2(\C1342/net23117 ), .Y(n242) );
  sky130_fd_sc_hd__a22oi_1 U559 ( .A1(s_mem_q[221]), .A2(net28392), .B1(
        s_mem_q[213]), .B2(net31356), .Y(n241) );
  sky130_fd_sc_hd__a22oi_1 U560 ( .A1(s_mem_q[205]), .A2(net31374), .B1(
        s_mem_q[197]), .B2(n3), .Y(n240) );
  sky130_fd_sc_hd__o21ai_1 U561 ( .A1(n244), .A2(n245), .B1(n11), .Y(n232) );
  sky130_fd_sc_hd__nand4_1 U562 ( .A(n246), .B(n249), .C(n248), .D(n247), .Y(
        n245) );
  sky130_fd_sc_hd__a22oi_1 U563 ( .A1(s_mem_q[61]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[53]), .B2(\C1342/net25231 ), .Y(n249) );
  sky130_fd_sc_hd__a22oi_1 U564 ( .A1(s_mem_q[45]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[37]), .B2(\C1342/net23105 ), .Y(n248) );
  sky130_fd_sc_hd__a22oi_1 U565 ( .A1(s_mem_q[29]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[21]), .B2(\C1342/net23107 ), .Y(n247) );
  sky130_fd_sc_hd__a22oi_1 U566 ( .A1(s_mem_q[13]), .A2(net31297), .B1(
        s_mem_q[5]), .B2(\C1342/net23109 ), .Y(n246) );
  sky130_fd_sc_hd__nand4_1 U567 ( .A(n250), .B(n253), .C(n252), .D(n251), .Y(
        n244) );
  sky130_fd_sc_hd__a22oi_1 U568 ( .A1(s_mem_q[125]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[117]), .B2(net31290), .Y(n253) );
  sky130_fd_sc_hd__a22oi_1 U569 ( .A1(s_mem_q[109]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[101]), .B2(\C1342/net25204 ), .Y(n252) );
  sky130_fd_sc_hd__a22oi_1 U570 ( .A1(s_mem_q[93]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[85]), .B2(net31356), .Y(n251) );
  sky130_fd_sc_hd__a22oi_1 U571 ( .A1(s_mem_q[77]), .A2(net31374), .B1(
        s_mem_q[69]), .B2(n3), .Y(n250) );
  sky130_fd_sc_hd__o21ai_1 U572 ( .A1(n254), .A2(n255), .B1(n10), .Y(n231) );
  sky130_fd_sc_hd__nand4_1 U573 ( .A(n256), .B(n257), .C(n258), .D(n259), .Y(
        n255) );
  sky130_fd_sc_hd__a22oi_1 U574 ( .A1(\C1342/net23102 ), .A2(s_mem_q[445]), 
        .B1(s_mem_q[437]), .B2(\C1342/net23103 ), .Y(n259) );
  sky130_fd_sc_hd__a22oi_1 U575 ( .A1(s_mem_q[429]), .A2(net28409), .B1(
        s_mem_q[421]), .B2(net31378), .Y(n258) );
  sky130_fd_sc_hd__a22oi_1 U576 ( .A1(s_mem_q[413]), .A2(net31364), .B1(
        s_mem_q[405]), .B2(\C1342/net23107 ), .Y(n257) );
  sky130_fd_sc_hd__a22oi_1 U577 ( .A1(s_mem_q[397]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[389]), .B2(\C1342/net23109 ), .Y(n256) );
  sky130_fd_sc_hd__nand4_1 U578 ( .A(n262), .B(n260), .C(n261), .D(n263), .Y(
        n254) );
  sky130_fd_sc_hd__a22oi_1 U579 ( .A1(s_mem_q[509]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[501]), .B2(\C1342/net23115 ), .Y(n263) );
  sky130_fd_sc_hd__a22oi_1 U580 ( .A1(s_mem_q[493]), .A2(net31276), .B1(
        s_mem_q[485]), .B2(\C1342/net23117 ), .Y(n262) );
  sky130_fd_sc_hd__a22oi_1 U581 ( .A1(s_mem_q[477]), .A2(net28392), .B1(
        s_mem_q[469]), .B2(net31356), .Y(n261) );
  sky130_fd_sc_hd__a22oi_1 U582 ( .A1(s_mem_q[461]), .A2(net31373), .B1(
        s_mem_q[453]), .B2(\C1342/net23121 ), .Y(n260) );
  sky130_fd_sc_hd__o21ai_1 U583 ( .A1(n264), .A2(n265), .B1(n9), .Y(n230) );
  sky130_fd_sc_hd__nand4_1 U584 ( .A(n266), .B(n267), .C(n268), .D(n269), .Y(
        n265) );
  sky130_fd_sc_hd__a22oi_1 U585 ( .A1(s_mem_q[317]), .A2(net28405), .B1(
        s_mem_q[309]), .B2(\C1342/net23103 ), .Y(n269) );
  sky130_fd_sc_hd__a22oi_1 U586 ( .A1(s_mem_q[301]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[293]), .B2(net31378), .Y(n268) );
  sky130_fd_sc_hd__a22oi_1 U587 ( .A1(s_mem_q[285]), .A2(net31364), .B1(
        s_mem_q[277]), .B2(\C1342/net23107 ), .Y(n267) );
  sky130_fd_sc_hd__a22oi_1 U588 ( .A1(s_mem_q[269]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[261]), .B2(\C1342/net23109 ), .Y(n266) );
  sky130_fd_sc_hd__nand4_1 U589 ( .A(n270), .B(n271), .C(n272), .D(n273), .Y(
        n264) );
  sky130_fd_sc_hd__a22oi_1 U590 ( .A1(s_mem_q[381]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[373]), .B2(net31290), .Y(n273) );
  sky130_fd_sc_hd__a22oi_1 U591 ( .A1(s_mem_q[365]), .A2(net31276), .B1(
        s_mem_q[357]), .B2(\C1342/net23117 ), .Y(n272) );
  sky130_fd_sc_hd__a22oi_1 U592 ( .A1(s_mem_q[349]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[341]), .B2(\C1342/net23119 ), .Y(n271) );
  sky130_fd_sc_hd__a22oi_1 U593 ( .A1(s_mem_q[333]), .A2(net31374), .B1(
        s_mem_q[325]), .B2(\C1342/net23121 ), .Y(n270) );
  sky130_fd_sc_hd__nand4_1 U594 ( .A(n275), .B(n274), .C(n277), .D(n276), .Y(
        dat_o[6]) );
  sky130_fd_sc_hd__o21ai_1 U595 ( .A1(n278), .A2(n279), .B1(n8), .Y(n277) );
  sky130_fd_sc_hd__nand4_1 U596 ( .A(n283), .B(n280), .C(n282), .D(n281), .Y(
        n279) );
  sky130_fd_sc_hd__a22oi_1 U597 ( .A1(s_mem_q[190]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[182]), .B2(\C1342/net25230 ), .Y(n283) );
  sky130_fd_sc_hd__a22oi_1 U598 ( .A1(s_mem_q[158]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[150]), .B2(\C1342/net23107 ), .Y(n281) );
  sky130_fd_sc_hd__nand4_1 U599 ( .A(n284), .B(n286), .C(n285), .D(n287), .Y(
        n278) );
  sky130_fd_sc_hd__a22oi_1 U600 ( .A1(s_mem_q[238]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[230]), .B2(\C1342/net25204 ), .Y(n286) );
  sky130_fd_sc_hd__a22oi_1 U601 ( .A1(s_mem_q[206]), .A2(net31374), .B1(
        s_mem_q[198]), .B2(n3), .Y(n284) );
  sky130_fd_sc_hd__o21ai_1 U602 ( .A1(n288), .A2(n289), .B1(n11), .Y(n276) );
  sky130_fd_sc_hd__nand4_1 U603 ( .A(n293), .B(n291), .C(n292), .D(n290), .Y(
        n289) );
  sky130_fd_sc_hd__a22oi_1 U604 ( .A1(s_mem_q[62]), .A2(\C1342/net23102 ), 
        .B1(s_mem_q[54]), .B2(\C1342/net23103 ), .Y(n293) );
  sky130_fd_sc_hd__a22oi_1 U605 ( .A1(s_mem_q[46]), .A2(net28409), .B1(
        s_mem_q[38]), .B2(\C1342/net23105 ), .Y(n292) );
  sky130_fd_sc_hd__a22oi_1 U606 ( .A1(s_mem_q[30]), .A2(\C1342/net23106 ), 
        .B1(s_mem_q[22]), .B2(\C1342/net23107 ), .Y(n291) );
  sky130_fd_sc_hd__a22oi_1 U607 ( .A1(s_mem_q[14]), .A2(net31297), .B1(
        s_mem_q[6]), .B2(\C1342/net23109 ), .Y(n290) );
  sky130_fd_sc_hd__nand4_1 U608 ( .A(n294), .B(n297), .C(n296), .D(n295), .Y(
        n288) );
  sky130_fd_sc_hd__a22oi_1 U609 ( .A1(s_mem_q[126]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[118]), .B2(\C1342/net23115 ), .Y(n297) );
  sky130_fd_sc_hd__a22oi_1 U610 ( .A1(s_mem_q[110]), .A2(\C1342/net23116 ), 
        .B1(s_mem_q[102]), .B2(\C1342/net23117 ), .Y(n296) );
  sky130_fd_sc_hd__a22oi_1 U611 ( .A1(s_mem_q[94]), .A2(net28392), .B1(
        s_mem_q[86]), .B2(net31356), .Y(n295) );
  sky130_fd_sc_hd__a22oi_1 U612 ( .A1(s_mem_q[78]), .A2(net31373), .B1(
        s_mem_q[70]), .B2(\C1342/net23121 ), .Y(n294) );
  sky130_fd_sc_hd__o21ai_1 U613 ( .A1(n298), .A2(n299), .B1(n10), .Y(n275) );
  sky130_fd_sc_hd__nand4_1 U614 ( .A(n300), .B(n301), .C(n302), .D(n303), .Y(
        n299) );
  sky130_fd_sc_hd__a22oi_1 U615 ( .A1(s_mem_q[446]), .A2(net28405), .B1(
        s_mem_q[438]), .B2(\C1342/net25230 ), .Y(n303) );
  sky130_fd_sc_hd__a22oi_1 U616 ( .A1(s_mem_q[430]), .A2(\C1342/net23104 ), 
        .B1(s_mem_q[422]), .B2(net31378), .Y(n302) );
  sky130_fd_sc_hd__a22oi_1 U617 ( .A1(s_mem_q[398]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[390]), .B2(\C1342/net23109 ), .Y(n300) );
  sky130_fd_sc_hd__nand4_1 U618 ( .A(n304), .B(n305), .C(n306), .D(n307), .Y(
        n298) );
  sky130_fd_sc_hd__a22oi_1 U619 ( .A1(s_mem_q[462]), .A2(net31373), .B1(
        s_mem_q[454]), .B2(n3), .Y(n304) );
  sky130_fd_sc_hd__o21ai_1 U620 ( .A1(n308), .A2(n309), .B1(n9), .Y(n274) );
  sky130_fd_sc_hd__nand4_1 U621 ( .A(n313), .B(n311), .C(n312), .D(n310), .Y(
        n309) );
  sky130_fd_sc_hd__a22oi_1 U622 ( .A1(s_mem_q[318]), .A2(net28405), .B1(
        s_mem_q[310]), .B2(\C1342/net23103 ), .Y(n313) );
  sky130_fd_sc_hd__a22oi_1 U623 ( .A1(s_mem_q[302]), .A2(net28409), .B1(
        s_mem_q[294]), .B2(\C1342/net23105 ), .Y(n312) );
  sky130_fd_sc_hd__a22oi_1 U624 ( .A1(net31364), .A2(s_mem_q[286]), .B1(
        s_mem_q[278]), .B2(\C1342/net23107 ), .Y(n311) );
  sky130_fd_sc_hd__a22oi_1 U625 ( .A1(s_mem_q[270]), .A2(net31297), .B1(
        s_mem_q[262]), .B2(\C1342/net23109 ), .Y(n310) );
  sky130_fd_sc_hd__nand4_1 U626 ( .A(n316), .B(n314), .C(n315), .D(n317), .Y(
        n308) );
  sky130_fd_sc_hd__a22oi_1 U627 ( .A1(s_mem_q[382]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[374]), .B2(\C1342/net23115 ), .Y(n317) );
  sky130_fd_sc_hd__a22oi_1 U628 ( .A1(s_mem_q[366]), .A2(net31276), .B1(
        s_mem_q[358]), .B2(\C1342/net25204 ), .Y(n316) );
  sky130_fd_sc_hd__a22oi_1 U629 ( .A1(s_mem_q[350]), .A2(net28392), .B1(
        s_mem_q[342]), .B2(\C1342/net23119 ), .Y(n315) );
  sky130_fd_sc_hd__a22oi_1 U630 ( .A1(s_mem_q[334]), .A2(net31373), .B1(
        s_mem_q[326]), .B2(n3), .Y(n314) );
  sky130_fd_sc_hd__nand4_1 U631 ( .A(n318), .B(n319), .C(n320), .D(n321), .Y(
        dat_o[7]) );
  sky130_fd_sc_hd__o21ai_1 U632 ( .A1(n322), .A2(n323), .B1(n8), .Y(n321) );
  sky130_fd_sc_hd__nand4_1 U633 ( .A(n324), .B(n325), .C(n326), .D(n327), .Y(
        n323) );
  sky130_fd_sc_hd__a22oi_1 U634 ( .A1(s_mem_q[191]), .A2(net28405), .B1(
        s_mem_q[183]), .B2(\C1342/net25231 ), .Y(n327) );
  sky130_fd_sc_hd__a22oi_1 U635 ( .A1(s_mem_q[175]), .A2(\C1342/net24842 ), 
        .B1(s_mem_q[167]), .B2(\C1342/net23105 ), .Y(n326) );
  sky130_fd_sc_hd__a22oi_1 U636 ( .A1(s_mem_q[159]), .A2(net31364), .B1(
        s_mem_q[151]), .B2(\C1342/net23107 ), .Y(n325) );
  sky130_fd_sc_hd__a22oi_1 U637 ( .A1(s_mem_q[143]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[135]), .B2(\C1342/net23109 ), .Y(n324) );
  sky130_fd_sc_hd__nand4_1 U638 ( .A(n330), .B(n329), .C(n328), .D(n331), .Y(
        n322) );
  sky130_fd_sc_hd__a22oi_1 U639 ( .A1(s_mem_q[255]), .A2(\C1342/net23114 ), 
        .B1(s_mem_q[247]), .B2(\C1342/net23115 ), .Y(n331) );
  sky130_fd_sc_hd__a22oi_1 U640 ( .A1(s_mem_q[239]), .A2(net28383), .B1(
        s_mem_q[231]), .B2(\C1342/net23117 ), .Y(n330) );
  sky130_fd_sc_hd__a22oi_1 U641 ( .A1(s_mem_q[223]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[215]), .B2(\C1342/net23119 ), .Y(n329) );
  sky130_fd_sc_hd__a22oi_1 U642 ( .A1(s_mem_q[207]), .A2(net31374), .B1(
        s_mem_q[199]), .B2(n3), .Y(n328) );
  sky130_fd_sc_hd__o21ai_1 U643 ( .A1(n332), .A2(n333), .B1(n11), .Y(n320) );
  sky130_fd_sc_hd__nand4_1 U644 ( .A(n334), .B(n335), .C(n336), .D(n337), .Y(
        n333) );
  sky130_fd_sc_hd__a22oi_1 U645 ( .A1(s_mem_q[63]), .A2(net28405), .B1(
        s_mem_q[55]), .B2(\C1342/net25230 ), .Y(n337) );
  sky130_fd_sc_hd__a22oi_1 U646 ( .A1(s_mem_q[47]), .A2(\C1342/net24844 ), 
        .B1(s_mem_q[39]), .B2(net31378), .Y(n336) );
  sky130_fd_sc_hd__a22oi_1 U647 ( .A1(s_mem_q[31]), .A2(net31364), .B1(
        s_mem_q[23]), .B2(\C1342/net23107 ), .Y(n335) );
  sky130_fd_sc_hd__a22oi_1 U648 ( .A1(s_mem_q[15]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[7]), .B2(\C1342/net23109 ), .Y(n334) );
  sky130_fd_sc_hd__nand4_1 U649 ( .A(n340), .B(n339), .C(n338), .D(n341), .Y(
        n332) );
  sky130_fd_sc_hd__a22oi_1 U650 ( .A1(s_mem_q[127]), .A2(net28369), .B1(
        s_mem_q[119]), .B2(\C1342/net23115 ), .Y(n341) );
  sky130_fd_sc_hd__a22oi_1 U651 ( .A1(s_mem_q[111]), .A2(net28383), .B1(
        s_mem_q[103]), .B2(net31346), .Y(n340) );
  sky130_fd_sc_hd__a22oi_1 U652 ( .A1(s_mem_q[95]), .A2(net28392), .B1(
        s_mem_q[87]), .B2(\C1342/net23119 ), .Y(n339) );
  sky130_fd_sc_hd__a22oi_1 U653 ( .A1(s_mem_q[79]), .A2(net31374), .B1(
        s_mem_q[71]), .B2(\C1342/net23121 ), .Y(n338) );
  sky130_fd_sc_hd__o21ai_1 U654 ( .A1(n342), .A2(n343), .B1(n10), .Y(n319) );
  sky130_fd_sc_hd__nand4_1 U655 ( .A(n344), .B(n345), .C(n346), .D(n347), .Y(
        n343) );
  sky130_fd_sc_hd__a22oi_1 U656 ( .A1(s_mem_q[447]), .A2(net28405), .B1(
        s_mem_q[439]), .B2(\C1342/net23103 ), .Y(n347) );
  sky130_fd_sc_hd__a22oi_1 U657 ( .A1(s_mem_q[431]), .A2(\C1342/net24844 ), 
        .B1(s_mem_q[423]), .B2(\C1342/net23105 ), .Y(n346) );
  sky130_fd_sc_hd__a22oi_1 U658 ( .A1(s_mem_q[415]), .A2(net31364), .B1(
        s_mem_q[407]), .B2(\C1342/net23107 ), .Y(n345) );
  sky130_fd_sc_hd__a22oi_1 U659 ( .A1(s_mem_q[399]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[391]), .B2(\C1342/net23109 ), .Y(n344) );
  sky130_fd_sc_hd__nand4_1 U660 ( .A(n348), .B(n349), .C(n350), .D(n351), .Y(
        n342) );
  sky130_fd_sc_hd__a22oi_1 U661 ( .A1(s_mem_q[511]), .A2(net28369), .B1(
        s_mem_q[503]), .B2(\C1342/net23115 ), .Y(n351) );
  sky130_fd_sc_hd__a22oi_1 U662 ( .A1(s_mem_q[495]), .A2(net28383), .B1(
        s_mem_q[487]), .B2(\C1342/net23117 ), .Y(n350) );
  sky130_fd_sc_hd__a22oi_1 U663 ( .A1(s_mem_q[479]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[471]), .B2(\C1342/net23119 ), .Y(n349) );
  sky130_fd_sc_hd__a22oi_1 U664 ( .A1(s_mem_q[463]), .A2(net31373), .B1(
        s_mem_q[455]), .B2(n3), .Y(n348) );
  sky130_fd_sc_hd__o21ai_1 U665 ( .A1(n352), .A2(n353), .B1(n9), .Y(n318) );
  sky130_fd_sc_hd__nand4_1 U666 ( .A(n354), .B(n355), .C(n356), .D(n357), .Y(
        n353) );
  sky130_fd_sc_hd__a22oi_1 U667 ( .A1(s_mem_q[319]), .A2(net28405), .B1(
        s_mem_q[311]), .B2(\C1342/net23103 ), .Y(n357) );
  sky130_fd_sc_hd__a22oi_1 U668 ( .A1(s_mem_q[303]), .A2(\C1342/net24842 ), 
        .B1(s_mem_q[295]), .B2(net31378), .Y(n356) );
  sky130_fd_sc_hd__a22oi_1 U669 ( .A1(s_mem_q[287]), .A2(net31364), .B1(
        s_mem_q[279]), .B2(\C1342/net23107 ), .Y(n355) );
  sky130_fd_sc_hd__a22oi_1 U670 ( .A1(s_mem_q[271]), .A2(\C1342/net23108 ), 
        .B1(s_mem_q[263]), .B2(\C1342/net23109 ), .Y(n354) );
  sky130_fd_sc_hd__nand4_1 U671 ( .A(n358), .B(n359), .C(n360), .D(n361), .Y(
        n352) );
  sky130_fd_sc_hd__a22oi_1 U672 ( .A1(s_mem_q[383]), .A2(net28369), .B1(
        s_mem_q[375]), .B2(\C1342/net23115 ), .Y(n361) );
  sky130_fd_sc_hd__a22oi_1 U673 ( .A1(s_mem_q[367]), .A2(net28383), .B1(
        s_mem_q[359]), .B2(net31346), .Y(n360) );
  sky130_fd_sc_hd__a22oi_1 U674 ( .A1(s_mem_q[351]), .A2(net28392), .B1(
        s_mem_q[343]), .B2(\C1342/net23119 ), .Y(n359) );
  sky130_fd_sc_hd__a22oi_1 U675 ( .A1(s_mem_q[335]), .A2(net31374), .B1(
        s_mem_q[327]), .B2(\C1342/net23121 ), .Y(n358) );
  sky130_fd_sc_hd__inv_1 U676 ( .A(\C1342/net23465 ), .Y(\C1342/net23103 ) );
  sky130_fd_sc_hd__a22oi_1 U677 ( .A1(s_mem_q[478]), .A2(\C1342/net23118 ), 
        .B1(s_mem_q[470]), .B2(\C1342/net23119 ), .Y(n305) );
  sky130_fd_sc_hd__a22oi_1 U678 ( .A1(s_mem_q[414]), .A2(net31364), .B1(
        s_mem_q[406]), .B2(\C1342/net23107 ), .Y(n301) );
  sky130_fd_sc_hd__inv_1 U679 ( .A(net31276), .Y(\C1342/net25651 ) );
  sky130_fd_sc_hd__inv_2 U680 ( .A(n1229), .Y(n363) );
  sky130_fd_sc_hd__inv_2 U681 ( .A(n1229), .Y(n364) );
  sky130_fd_sc_hd__inv_2 U682 ( .A(n363), .Y(n365) );
  sky130_fd_sc_hd__inv_2 U683 ( .A(n363), .Y(n366) );
  sky130_fd_sc_hd__inv_2 U684 ( .A(n363), .Y(n367) );
  sky130_fd_sc_hd__inv_2 U685 ( .A(n363), .Y(n368) );
  sky130_fd_sc_hd__inv_2 U686 ( .A(n364), .Y(n369) );
  sky130_fd_sc_hd__inv_2 U687 ( .A(n364), .Y(n370) );
  sky130_fd_sc_hd__inv_2 U688 ( .A(n364), .Y(n371) );
  sky130_fd_sc_hd__inv_2 U689 ( .A(n1231), .Y(n373) );
  sky130_fd_sc_hd__inv_2 U690 ( .A(n1231), .Y(n374) );
  sky130_fd_sc_hd__inv_2 U691 ( .A(n373), .Y(n375) );
  sky130_fd_sc_hd__inv_2 U692 ( .A(n373), .Y(n376) );
  sky130_fd_sc_hd__inv_2 U693 ( .A(n373), .Y(n377) );
  sky130_fd_sc_hd__inv_2 U694 ( .A(n373), .Y(n378) );
  sky130_fd_sc_hd__inv_2 U695 ( .A(n374), .Y(n379) );
  sky130_fd_sc_hd__inv_2 U696 ( .A(n374), .Y(n380) );
  sky130_fd_sc_hd__inv_2 U697 ( .A(n374), .Y(n381) );
  sky130_fd_sc_hd__inv_2 U698 ( .A(n1233), .Y(n383) );
  sky130_fd_sc_hd__inv_2 U699 ( .A(n1233), .Y(n384) );
  sky130_fd_sc_hd__inv_2 U700 ( .A(n383), .Y(n385) );
  sky130_fd_sc_hd__inv_2 U701 ( .A(n383), .Y(n386) );
  sky130_fd_sc_hd__inv_2 U702 ( .A(n383), .Y(n387) );
  sky130_fd_sc_hd__inv_2 U703 ( .A(n383), .Y(n388) );
  sky130_fd_sc_hd__inv_2 U704 ( .A(n384), .Y(n389) );
  sky130_fd_sc_hd__inv_2 U705 ( .A(n384), .Y(n390) );
  sky130_fd_sc_hd__inv_2 U706 ( .A(n384), .Y(n391) );
  sky130_fd_sc_hd__inv_2 U707 ( .A(n1235), .Y(n393) );
  sky130_fd_sc_hd__inv_2 U708 ( .A(n1235), .Y(n394) );
  sky130_fd_sc_hd__inv_2 U709 ( .A(n393), .Y(n395) );
  sky130_fd_sc_hd__inv_2 U710 ( .A(n393), .Y(n396) );
  sky130_fd_sc_hd__inv_2 U711 ( .A(n393), .Y(n397) );
  sky130_fd_sc_hd__inv_2 U712 ( .A(n393), .Y(n398) );
  sky130_fd_sc_hd__inv_2 U713 ( .A(n394), .Y(n399) );
  sky130_fd_sc_hd__inv_2 U714 ( .A(n394), .Y(n400) );
  sky130_fd_sc_hd__inv_2 U715 ( .A(n394), .Y(n401) );
  sky130_fd_sc_hd__inv_2 U716 ( .A(n1237), .Y(n403) );
  sky130_fd_sc_hd__inv_2 U717 ( .A(n1237), .Y(n404) );
  sky130_fd_sc_hd__inv_2 U718 ( .A(n403), .Y(n405) );
  sky130_fd_sc_hd__inv_2 U719 ( .A(n403), .Y(n406) );
  sky130_fd_sc_hd__inv_2 U720 ( .A(n403), .Y(n407) );
  sky130_fd_sc_hd__inv_2 U721 ( .A(n403), .Y(n408) );
  sky130_fd_sc_hd__inv_2 U722 ( .A(n404), .Y(n409) );
  sky130_fd_sc_hd__inv_2 U723 ( .A(n404), .Y(n410) );
  sky130_fd_sc_hd__inv_2 U724 ( .A(n404), .Y(n411) );
  sky130_fd_sc_hd__buf_4 U725 ( .A(n1239), .X(n433) );
  sky130_fd_sc_hd__buf_4 U726 ( .A(n1239), .X(n434) );
  sky130_fd_sc_hd__buf_4 U727 ( .A(n1239), .X(n435) );
  sky130_fd_sc_hd__buf_4 U728 ( .A(n1239), .X(n436) );
  sky130_fd_sc_hd__buf_4 U729 ( .A(n1239), .X(n437) );
  sky130_fd_sc_hd__buf_6 U730 ( .A(n421), .X(n422) );
  sky130_fd_sc_hd__inv_2 U731 ( .A(n1254), .Y(n1251) );
  sky130_fd_sc_hd__nand2_1 U732 ( .A(n477), .B(n1246), .Y(n413) );
  sky130_fd_sc_hd__inv_2 U733 ( .A(net24335), .Y(net25188) );
  sky130_fd_sc_hd__inv_1 U734 ( .A(n1251), .Y(n414) );
  sky130_fd_sc_hd__inv_2 U735 ( .A(n414), .Y(n415) );
  sky130_fd_sc_hd__ha_2 U736 ( .A(net25188), .B(\add_50/carry[3] ), .COUT(
        \add_50/carry[4] ), .SUM(N87) );
  sky130_fd_sc_hd__nand2_1 U737 ( .A(dat_i[0]), .B(n422), .Y(n417) );
  sky130_fd_sc_hd__nand2_1 U738 ( .A(dat_i[0]), .B(n422), .Y(n418) );
  sky130_fd_sc_hd__ha_1 U739 ( .A(net25185), .B(net25158), .COUT(
        \add_50/carry[2] ), .SUM(N85) );
  sky130_fd_sc_hd__ha_1 U740 ( .A(net25176), .B(\add_50/carry[2] ), .COUT(
        \add_50/carry[3] ), .SUM(N86) );
  sky130_fd_sc_hd__nor2_1 U741 ( .A(n413), .B(n465), .Y(n469) );
  sky130_fd_sc_hd__inv_2 U742 ( .A(n474), .Y(n456) );
  sky130_fd_sc_hd__inv_2 U743 ( .A(n467), .Y(n477) );
  sky130_fd_sc_hd__inv_1 U744 ( .A(n1256), .Y(full_o) );
  sky130_fd_sc_hd__nor4_2 U745 ( .A(cnt_o[3]), .B(n1260), .C(n1261), .D(n473), 
        .Y(n443) );
  sky130_fd_sc_hd__nand2_4 U746 ( .A(n573), .B(n4), .Y(n493) );
  sky130_fd_sc_hd__nand2_4 U747 ( .A(n573), .B(n1156), .Y(n504) );
  sky130_fd_sc_hd__nand2_4 U748 ( .A(n573), .B(n1167), .Y(n516) );
  sky130_fd_sc_hd__nand2_4 U749 ( .A(n573), .B(n1178), .Y(n529) );
  sky130_fd_sc_hd__nand2_4 U750 ( .A(n573), .B(n1199), .Y(n555) );
  sky130_fd_sc_hd__nand2_4 U751 ( .A(n573), .B(n1210), .Y(n568) );
  sky130_fd_sc_hd__nand2_4 U752 ( .A(n573), .B(n1224), .Y(n583) );
  sky130_fd_sc_hd__nand2_4 U753 ( .A(n671), .B(n1156), .Y(n608) );
  sky130_fd_sc_hd__nand2_4 U754 ( .A(n671), .B(n1167), .Y(n620) );
  sky130_fd_sc_hd__nand2_4 U755 ( .A(n671), .B(n1178), .Y(n632) );
  sky130_fd_sc_hd__nand2_4 U756 ( .A(n671), .B(n1199), .Y(n656) );
  sky130_fd_sc_hd__nand2_4 U757 ( .A(n671), .B(n1210), .Y(n668) );
  sky130_fd_sc_hd__nand2_4 U758 ( .A(n671), .B(n1224), .Y(n681) );
  sky130_fd_sc_hd__nand2_4 U759 ( .A(n769), .B(n1156), .Y(n706) );
  sky130_fd_sc_hd__nand2_4 U760 ( .A(n769), .B(n1178), .Y(n730) );
  sky130_fd_sc_hd__nand2_4 U761 ( .A(n769), .B(n1199), .Y(n754) );
  sky130_fd_sc_hd__nand2_4 U762 ( .A(n769), .B(n1210), .Y(n766) );
  sky130_fd_sc_hd__nand2_4 U763 ( .A(n769), .B(n1224), .Y(n779) );
  sky130_fd_sc_hd__nand2_4 U764 ( .A(n867), .B(n1156), .Y(n804) );
  sky130_fd_sc_hd__nand2_4 U765 ( .A(n867), .B(n1178), .Y(n828) );
  sky130_fd_sc_hd__nand2_4 U766 ( .A(n867), .B(n1199), .Y(n852) );
  sky130_fd_sc_hd__nand2_4 U767 ( .A(n867), .B(n1210), .Y(n864) );
  sky130_fd_sc_hd__nand2_4 U768 ( .A(n867), .B(n1224), .Y(n877) );
  sky130_fd_sc_hd__nand2_4 U769 ( .A(n960), .B(n1156), .Y(n901) );
  sky130_fd_sc_hd__nand2_4 U770 ( .A(n960), .B(n1178), .Y(n923) );
  sky130_fd_sc_hd__nand2_4 U771 ( .A(n960), .B(n1199), .Y(n945) );
  sky130_fd_sc_hd__nand2_4 U772 ( .A(n960), .B(n1210), .Y(n957) );
  sky130_fd_sc_hd__nand2_4 U773 ( .A(n960), .B(n1224), .Y(n970) );
  sky130_fd_sc_hd__nand2_4 U774 ( .A(n1050), .B(n4), .Y(n982) );
  sky130_fd_sc_hd__nand2_4 U775 ( .A(n1050), .B(n1156), .Y(n993) );
  sky130_fd_sc_hd__nand2_4 U776 ( .A(n1050), .B(n1167), .Y(n1004) );
  sky130_fd_sc_hd__nand2_4 U777 ( .A(n1050), .B(n1178), .Y(n1015) );
  sky130_fd_sc_hd__nand2_4 U778 ( .A(n1050), .B(n5), .Y(n1025) );
  sky130_fd_sc_hd__nand2_4 U779 ( .A(n1050), .B(n1199), .Y(n1035) );
  sky130_fd_sc_hd__nand2_4 U780 ( .A(n1050), .B(n1210), .Y(n1047) );
  sky130_fd_sc_hd__nand2_4 U781 ( .A(n1050), .B(n1224), .Y(n1060) );
  sky130_fd_sc_hd__nand2_4 U782 ( .A(n1134), .B(n4), .Y(n1071) );
  sky130_fd_sc_hd__nand2_4 U783 ( .A(n1134), .B(n1156), .Y(n1081) );
  sky130_fd_sc_hd__nand2_4 U784 ( .A(n1134), .B(n1167), .Y(n1091) );
  sky130_fd_sc_hd__nand2_4 U785 ( .A(n1134), .B(n1178), .Y(n1101) );
  sky130_fd_sc_hd__nand2_4 U786 ( .A(n1134), .B(n5), .Y(n1111) );
  sky130_fd_sc_hd__nand2_4 U787 ( .A(n1134), .B(n1199), .Y(n1121) );
  sky130_fd_sc_hd__nand2_4 U788 ( .A(n1134), .B(n1210), .Y(n1131) );
  sky130_fd_sc_hd__nand2_4 U789 ( .A(n1134), .B(n1224), .Y(n1142) );
  sky130_fd_sc_hd__nand2_4 U790 ( .A(n4), .B(n1223), .Y(n1153) );
  sky130_fd_sc_hd__nand2_4 U791 ( .A(n1156), .B(n1223), .Y(n1164) );
  sky130_fd_sc_hd__nand2_4 U792 ( .A(n1167), .B(n1223), .Y(n1175) );
  sky130_fd_sc_hd__nand2_4 U793 ( .A(n1178), .B(n1223), .Y(n1186) );
  sky130_fd_sc_hd__nand2_4 U794 ( .A(n5), .B(n1223), .Y(n1196) );
  sky130_fd_sc_hd__nand2_4 U795 ( .A(n1199), .B(n1223), .Y(n1207) );
  sky130_fd_sc_hd__nand2_4 U796 ( .A(n1210), .B(n1223), .Y(n1220) );
  sky130_fd_sc_hd__nand2_4 U797 ( .A(n1224), .B(n1223), .Y(n1242) );
  sky130_fd_sc_hd__inv_1 U798 ( .A(n1261), .Y(n450) );
  sky130_fd_sc_hd__nand2_1 U799 ( .A(pop_i), .B(n1255), .Y(n444) );
  sky130_fd_sc_hd__inv_1 U800 ( .A(flush_i), .Y(n1245) );
  sky130_fd_sc_hd__nand4_1 U801 ( .A(n443), .B(n453), .C(n462), .D(n451), .Y(
        n1256) );
  sky130_fd_sc_hd__nand3_1 U802 ( .A(n1256), .B(n1245), .C(push_i), .Y(n1254)
         );
  sky130_fd_sc_hd__mux2i_1 U803 ( .A0(n413), .A1(n51), .S(cnt_o[0]), .Y(n446)
         );
  sky130_fd_sc_hd__a21o_1 U804 ( .A1(N108), .A2(n420), .B1(n446), .X(
        s_cnt_d[0]) );
  sky130_fd_sc_hd__nand2_1 U805 ( .A(n456), .B(n450), .Y(n448) );
  sky130_fd_sc_hd__mux2i_1 U806 ( .A0(n448), .A1(n454), .S(cnt_o[1]), .Y(n449)
         );
  sky130_fd_sc_hd__a21o_1 U807 ( .A1(N109), .A2(n420), .B1(n449), .X(
        s_cnt_d[1]) );
  sky130_fd_sc_hd__a21oi_1 U808 ( .A1(cnt_o[2]), .A2(cnt_o[1]), .B1(n7), .Y(
        n455) );
  sky130_fd_sc_hd__nand2_1 U809 ( .A(N110), .B(n420), .Y(n452) );
  sky130_fd_sc_hd__o221ai_1 U810 ( .A1(n455), .A2(n413), .B1(n454), .B2(n453), 
        .C1(n452), .Y(s_cnt_d[2]) );
  sky130_fd_sc_hd__nand2_1 U811 ( .A(n7), .B(n456), .Y(n458) );
  sky130_fd_sc_hd__a21o_1 U812 ( .A1(N111), .A2(n420), .B1(n459), .X(
        s_cnt_d[3]) );
  sky130_fd_sc_hd__nand3_1 U813 ( .A(n7), .B(n460), .C(n462), .Y(n465) );
  sky130_fd_sc_hd__a21oi_1 U814 ( .A1(n53), .A2(cnt_o[4]), .B1(n468), .Y(n464)
         );
  sky130_fd_sc_hd__nand2_1 U815 ( .A(N112), .B(n420), .Y(n461) );
  sky130_fd_sc_hd__o221ai_1 U816 ( .A1(n464), .A2(n413), .B1(n463), .B2(n462), 
        .C1(n461), .Y(s_cnt_d[4]) );
  sky130_fd_sc_hd__o21ai_1 U817 ( .A1(n468), .A2(n467), .B1(n466), .Y(n476) );
  sky130_fd_sc_hd__mux2i_1 U818 ( .A0(n469), .A1(n476), .S(cnt_o[5]), .Y(n471)
         );
  sky130_fd_sc_hd__nand2_1 U819 ( .A(N113), .B(n420), .Y(n470) );
  sky130_fd_sc_hd__nand2_1 U820 ( .A(n471), .B(n470), .Y(s_cnt_d[5]) );
  sky130_fd_sc_hd__inv_1 U821 ( .A(cnt_o[5]), .Y(n472) );
  sky130_fd_sc_hd__nor3_1 U822 ( .A(n474), .B(n42), .C(n472), .Y(n475) );
  sky130_fd_sc_hd__a221o_1 U823 ( .A1(n476), .A2(cnt_o[6]), .B1(n419), .B2(
        N114), .C1(n475), .X(s_cnt_d[6]) );
  sky130_fd_sc_hd__inv_1 U824 ( .A(net25158), .Y(net24338) );
  sky130_fd_sc_hd__inv_1 U825 ( .A(net25185), .Y(net24337) );
  sky130_fd_sc_hd__inv_1 U826 ( .A(net25176), .Y(net24336) );
  sky130_fd_sc_hd__o2bb2ai_1 U827 ( .B1(n478), .B2(net24336), .A1_N(N86), 
        .A2_N(n477), .Y(s_rd_ptr_d[2]) );
  sky130_fd_sc_hd__o2bb2ai_1 U828 ( .B1(n478), .B2(\C1342/net23438 ), .A1_N(
        N88), .A2_N(n477), .Y(s_rd_ptr_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U829 ( .B1(n478), .B2(n22), .A1_N(N89), .A2_N(
        n477), .Y(s_rd_ptr_d[5]) );
  sky130_fd_sc_hd__nand2_1 U830 ( .A(s_wr_ptr_q[4]), .B(s_wr_ptr_q[3]), .Y(
        n479) );
  sky130_fd_sc_hd__nand2_1 U831 ( .A(n880), .B(s_wr_ptr_q[5]), .Y(n480) );
  sky130_fd_sc_hd__nand2_1 U832 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[1]), .Y(
        n481) );
  sky130_fd_sc_hd__nand2_1 U833 ( .A(n482), .B(n423), .Y(n483) );
  sky130_fd_sc_hd__inv_1 U834 ( .A(s_mem_q[511]), .Y(n484) );
  sky130_fd_sc_hd__o22ai_1 U835 ( .A1(n492), .A2(n484), .B1(n428), .B2(n493), 
        .Y(s_mem_d[511]) );
  sky130_fd_sc_hd__nand2_1 U836 ( .A(dat_i[6]), .B(n422), .Y(n1229) );
  sky130_fd_sc_hd__inv_1 U837 ( .A(s_mem_q[510]), .Y(n485) );
  sky130_fd_sc_hd__o22ai_1 U838 ( .A1(n365), .A2(n493), .B1(n492), .B2(n485), 
        .Y(s_mem_d[510]) );
  sky130_fd_sc_hd__nand2_1 U839 ( .A(dat_i[5]), .B(n422), .Y(n1231) );
  sky130_fd_sc_hd__inv_1 U840 ( .A(s_mem_q[509]), .Y(n486) );
  sky130_fd_sc_hd__o22ai_1 U841 ( .A1(n375), .A2(n493), .B1(n492), .B2(n486), 
        .Y(s_mem_d[509]) );
  sky130_fd_sc_hd__nand2_1 U842 ( .A(dat_i[4]), .B(n422), .Y(n1233) );
  sky130_fd_sc_hd__inv_1 U843 ( .A(s_mem_q[508]), .Y(n487) );
  sky130_fd_sc_hd__o22ai_1 U844 ( .A1(n385), .A2(n493), .B1(n492), .B2(n487), 
        .Y(s_mem_d[508]) );
  sky130_fd_sc_hd__nand2_1 U845 ( .A(dat_i[3]), .B(n422), .Y(n1235) );
  sky130_fd_sc_hd__inv_1 U846 ( .A(s_mem_q[507]), .Y(n488) );
  sky130_fd_sc_hd__o22ai_1 U847 ( .A1(n395), .A2(n493), .B1(n492), .B2(n488), 
        .Y(s_mem_d[507]) );
  sky130_fd_sc_hd__nand2_1 U848 ( .A(dat_i[2]), .B(n422), .Y(n1237) );
  sky130_fd_sc_hd__inv_1 U849 ( .A(s_mem_q[506]), .Y(n489) );
  sky130_fd_sc_hd__o22ai_1 U850 ( .A1(n405), .A2(n493), .B1(n492), .B2(n489), 
        .Y(s_mem_d[506]) );
  sky130_fd_sc_hd__nand2_1 U851 ( .A(dat_i[1]), .B(n422), .Y(n1239) );
  sky130_fd_sc_hd__inv_1 U852 ( .A(s_mem_q[505]), .Y(n490) );
  sky130_fd_sc_hd__o22ai_1 U853 ( .A1(n437), .A2(n493), .B1(n492), .B2(n490), 
        .Y(s_mem_d[505]) );
  sky130_fd_sc_hd__nand2_1 U854 ( .A(dat_i[0]), .B(n422), .Y(n1241) );
  sky130_fd_sc_hd__inv_1 U855 ( .A(s_mem_q[504]), .Y(n491) );
  sky130_fd_sc_hd__inv_1 U856 ( .A(s_wr_ptr_q[0]), .Y(n571) );
  sky130_fd_sc_hd__nand3_1 U857 ( .A(s_wr_ptr_q[2]), .B(s_wr_ptr_q[1]), .C(
        n571), .Y(n494) );
  sky130_fd_sc_hd__clkinv_2 U858 ( .A(n494), .Y(n1156) );
  sky130_fd_sc_hd__nand2_1 U859 ( .A(n495), .B(n425), .Y(n496) );
  sky130_fd_sc_hd__inv_1 U860 ( .A(s_mem_q[503]), .Y(n497) );
  sky130_fd_sc_hd__o22ai_1 U861 ( .A1(n506), .A2(n497), .B1(n428), .B2(n504), 
        .Y(s_mem_d[503]) );
  sky130_fd_sc_hd__inv_1 U862 ( .A(s_mem_q[502]), .Y(n498) );
  sky130_fd_sc_hd__o22ai_1 U863 ( .A1(n506), .A2(n498), .B1(n365), .B2(n504), 
        .Y(s_mem_d[502]) );
  sky130_fd_sc_hd__inv_1 U864 ( .A(s_mem_q[501]), .Y(n499) );
  sky130_fd_sc_hd__o22ai_1 U865 ( .A1(n506), .A2(n499), .B1(n375), .B2(n504), 
        .Y(s_mem_d[501]) );
  sky130_fd_sc_hd__inv_1 U866 ( .A(s_mem_q[500]), .Y(n500) );
  sky130_fd_sc_hd__o22ai_1 U867 ( .A1(n506), .A2(n500), .B1(n385), .B2(n504), 
        .Y(s_mem_d[500]) );
  sky130_fd_sc_hd__inv_1 U868 ( .A(s_mem_q[499]), .Y(n501) );
  sky130_fd_sc_hd__o22ai_1 U869 ( .A1(n506), .A2(n501), .B1(n395), .B2(n504), 
        .Y(s_mem_d[499]) );
  sky130_fd_sc_hd__inv_1 U870 ( .A(s_mem_q[498]), .Y(n502) );
  sky130_fd_sc_hd__o22ai_1 U871 ( .A1(n506), .A2(n502), .B1(n405), .B2(n504), 
        .Y(s_mem_d[498]) );
  sky130_fd_sc_hd__inv_1 U872 ( .A(s_mem_q[497]), .Y(n503) );
  sky130_fd_sc_hd__o22ai_1 U873 ( .A1(n506), .A2(n503), .B1(n433), .B2(n504), 
        .Y(s_mem_d[497]) );
  sky130_fd_sc_hd__inv_1 U874 ( .A(s_mem_q[496]), .Y(n505) );
  sky130_fd_sc_hd__o22ai_1 U875 ( .A1(n506), .A2(n505), .B1(n438), .B2(n504), 
        .Y(s_mem_d[496]) );
  sky130_fd_sc_hd__inv_1 U876 ( .A(s_wr_ptr_q[1]), .Y(n1252) );
  sky130_fd_sc_hd__nand3_1 U877 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[2]), .C(
        n1252), .Y(n507) );
  sky130_fd_sc_hd__clkinv_2 U878 ( .A(n507), .Y(n1167) );
  sky130_fd_sc_hd__nand2_1 U879 ( .A(n508), .B(n426), .Y(n509) );
  sky130_fd_sc_hd__inv_1 U880 ( .A(s_mem_q[495]), .Y(n510) );
  sky130_fd_sc_hd__o22ai_1 U881 ( .A1(n518), .A2(n510), .B1(n428), .B2(n516), 
        .Y(s_mem_d[495]) );
  sky130_fd_sc_hd__o22ai_1 U882 ( .A1(n518), .A2(n362), .B1(n368), .B2(n516), 
        .Y(s_mem_d[494]) );
  sky130_fd_sc_hd__inv_1 U883 ( .A(s_mem_q[493]), .Y(n511) );
  sky130_fd_sc_hd__o22ai_1 U884 ( .A1(n518), .A2(n511), .B1(n378), .B2(n516), 
        .Y(s_mem_d[493]) );
  sky130_fd_sc_hd__inv_1 U885 ( .A(s_mem_q[492]), .Y(n512) );
  sky130_fd_sc_hd__o22ai_1 U886 ( .A1(n518), .A2(n512), .B1(n388), .B2(n516), 
        .Y(s_mem_d[492]) );
  sky130_fd_sc_hd__inv_1 U887 ( .A(s_mem_q[491]), .Y(n513) );
  sky130_fd_sc_hd__o22ai_1 U888 ( .A1(n518), .A2(n513), .B1(n398), .B2(n516), 
        .Y(s_mem_d[491]) );
  sky130_fd_sc_hd__inv_1 U889 ( .A(s_mem_q[490]), .Y(n514) );
  sky130_fd_sc_hd__o22ai_1 U890 ( .A1(n518), .A2(n514), .B1(n408), .B2(n516), 
        .Y(s_mem_d[490]) );
  sky130_fd_sc_hd__inv_1 U891 ( .A(s_mem_q[489]), .Y(n515) );
  sky130_fd_sc_hd__o22ai_1 U892 ( .A1(n518), .A2(n515), .B1(n433), .B2(n516), 
        .Y(s_mem_d[489]) );
  sky130_fd_sc_hd__inv_1 U893 ( .A(s_mem_q[488]), .Y(n517) );
  sky130_fd_sc_hd__o22ai_1 U894 ( .A1(n518), .A2(n517), .B1(n438), .B2(n516), 
        .Y(s_mem_d[488]) );
  sky130_fd_sc_hd__nand3_1 U895 ( .A(s_wr_ptr_q[2]), .B(n1252), .C(n571), .Y(
        n519) );
  sky130_fd_sc_hd__clkinv_2 U896 ( .A(n519), .Y(n1178) );
  sky130_fd_sc_hd__nand2_1 U897 ( .A(n520), .B(n424), .Y(n521) );
  sky130_fd_sc_hd__inv_1 U898 ( .A(s_mem_q[487]), .Y(n522) );
  sky130_fd_sc_hd__o22ai_1 U899 ( .A1(n531), .A2(n522), .B1(n428), .B2(n529), 
        .Y(s_mem_d[487]) );
  sky130_fd_sc_hd__inv_1 U900 ( .A(s_mem_q[486]), .Y(n523) );
  sky130_fd_sc_hd__o22ai_1 U901 ( .A1(n531), .A2(n523), .B1(n367), .B2(n529), 
        .Y(s_mem_d[486]) );
  sky130_fd_sc_hd__inv_1 U902 ( .A(s_mem_q[485]), .Y(n524) );
  sky130_fd_sc_hd__o22ai_1 U903 ( .A1(n531), .A2(n524), .B1(n377), .B2(n529), 
        .Y(s_mem_d[485]) );
  sky130_fd_sc_hd__inv_1 U904 ( .A(s_mem_q[484]), .Y(n525) );
  sky130_fd_sc_hd__o22ai_1 U905 ( .A1(n531), .A2(n525), .B1(n387), .B2(n529), 
        .Y(s_mem_d[484]) );
  sky130_fd_sc_hd__inv_1 U906 ( .A(s_mem_q[483]), .Y(n526) );
  sky130_fd_sc_hd__o22ai_1 U907 ( .A1(n531), .A2(n526), .B1(n397), .B2(n529), 
        .Y(s_mem_d[483]) );
  sky130_fd_sc_hd__inv_1 U908 ( .A(s_mem_q[482]), .Y(n527) );
  sky130_fd_sc_hd__o22ai_1 U909 ( .A1(n531), .A2(n527), .B1(n407), .B2(n529), 
        .Y(s_mem_d[482]) );
  sky130_fd_sc_hd__inv_1 U910 ( .A(s_mem_q[481]), .Y(n528) );
  sky130_fd_sc_hd__o22ai_1 U911 ( .A1(n531), .A2(n528), .B1(n433), .B2(n529), 
        .Y(s_mem_d[481]) );
  sky130_fd_sc_hd__inv_1 U912 ( .A(s_mem_q[480]), .Y(n530) );
  sky130_fd_sc_hd__o22ai_1 U913 ( .A1(n531), .A2(n530), .B1(n438), .B2(n529), 
        .Y(s_mem_d[480]) );
  sky130_fd_sc_hd__inv_1 U914 ( .A(s_wr_ptr_q[2]), .Y(n1250) );
  sky130_fd_sc_hd__nand2_1 U915 ( .A(n533), .B(n427), .Y(n534) );
  sky130_fd_sc_hd__inv_1 U916 ( .A(s_mem_q[479]), .Y(n535) );
  sky130_fd_sc_hd__o22ai_1 U917 ( .A1(n544), .A2(n535), .B1(n428), .B2(n542), 
        .Y(s_mem_d[479]) );
  sky130_fd_sc_hd__inv_1 U918 ( .A(s_mem_q[478]), .Y(n536) );
  sky130_fd_sc_hd__o22ai_1 U919 ( .A1(n544), .A2(n536), .B1(n366), .B2(n542), 
        .Y(s_mem_d[478]) );
  sky130_fd_sc_hd__inv_1 U920 ( .A(s_mem_q[477]), .Y(n537) );
  sky130_fd_sc_hd__o22ai_1 U921 ( .A1(n544), .A2(n537), .B1(n376), .B2(n542), 
        .Y(s_mem_d[477]) );
  sky130_fd_sc_hd__inv_1 U922 ( .A(s_mem_q[476]), .Y(n538) );
  sky130_fd_sc_hd__o22ai_1 U923 ( .A1(n544), .A2(n538), .B1(n386), .B2(n542), 
        .Y(s_mem_d[476]) );
  sky130_fd_sc_hd__inv_1 U924 ( .A(s_mem_q[475]), .Y(n539) );
  sky130_fd_sc_hd__o22ai_1 U925 ( .A1(n544), .A2(n539), .B1(n396), .B2(n542), 
        .Y(s_mem_d[475]) );
  sky130_fd_sc_hd__inv_1 U926 ( .A(s_mem_q[474]), .Y(n540) );
  sky130_fd_sc_hd__o22ai_1 U927 ( .A1(n544), .A2(n540), .B1(n406), .B2(n542), 
        .Y(s_mem_d[474]) );
  sky130_fd_sc_hd__inv_1 U928 ( .A(s_mem_q[473]), .Y(n541) );
  sky130_fd_sc_hd__o22ai_1 U929 ( .A1(n544), .A2(n541), .B1(n433), .B2(n542), 
        .Y(s_mem_d[473]) );
  sky130_fd_sc_hd__inv_1 U930 ( .A(s_mem_q[472]), .Y(n543) );
  sky130_fd_sc_hd__o22ai_1 U931 ( .A1(n544), .A2(n543), .B1(n438), .B2(n542), 
        .Y(s_mem_d[472]) );
  sky130_fd_sc_hd__nand3_1 U932 ( .A(s_wr_ptr_q[1]), .B(n1250), .C(n571), .Y(
        n545) );
  sky130_fd_sc_hd__clkinv_2 U933 ( .A(n545), .Y(n1199) );
  sky130_fd_sc_hd__nand2_1 U934 ( .A(n546), .B(n425), .Y(n547) );
  sky130_fd_sc_hd__inv_1 U935 ( .A(s_mem_q[471]), .Y(n548) );
  sky130_fd_sc_hd__o22ai_1 U936 ( .A1(n557), .A2(n548), .B1(n428), .B2(n555), 
        .Y(s_mem_d[471]) );
  sky130_fd_sc_hd__inv_1 U937 ( .A(s_mem_q[470]), .Y(n549) );
  sky130_fd_sc_hd__o22ai_1 U938 ( .A1(n557), .A2(n549), .B1(n366), .B2(n555), 
        .Y(s_mem_d[470]) );
  sky130_fd_sc_hd__inv_1 U939 ( .A(s_mem_q[469]), .Y(n550) );
  sky130_fd_sc_hd__o22ai_1 U940 ( .A1(n557), .A2(n550), .B1(n376), .B2(n555), 
        .Y(s_mem_d[469]) );
  sky130_fd_sc_hd__inv_1 U941 ( .A(s_mem_q[468]), .Y(n551) );
  sky130_fd_sc_hd__o22ai_1 U942 ( .A1(n557), .A2(n551), .B1(n386), .B2(n555), 
        .Y(s_mem_d[468]) );
  sky130_fd_sc_hd__inv_1 U943 ( .A(s_mem_q[467]), .Y(n552) );
  sky130_fd_sc_hd__o22ai_1 U944 ( .A1(n557), .A2(n552), .B1(n396), .B2(n555), 
        .Y(s_mem_d[467]) );
  sky130_fd_sc_hd__inv_1 U945 ( .A(s_mem_q[466]), .Y(n553) );
  sky130_fd_sc_hd__o22ai_1 U946 ( .A1(n557), .A2(n553), .B1(n406), .B2(n555), 
        .Y(s_mem_d[466]) );
  sky130_fd_sc_hd__inv_1 U947 ( .A(s_mem_q[465]), .Y(n554) );
  sky130_fd_sc_hd__o22ai_1 U948 ( .A1(n557), .A2(n554), .B1(n433), .B2(n555), 
        .Y(s_mem_d[465]) );
  sky130_fd_sc_hd__inv_1 U949 ( .A(s_mem_q[464]), .Y(n556) );
  sky130_fd_sc_hd__o22ai_1 U950 ( .A1(n557), .A2(n556), .B1(n438), .B2(n555), 
        .Y(s_mem_d[464]) );
  sky130_fd_sc_hd__nand3_1 U951 ( .A(s_wr_ptr_q[0]), .B(n1250), .C(n1252), .Y(
        n558) );
  sky130_fd_sc_hd__clkinv_2 U952 ( .A(n558), .Y(n1210) );
  sky130_fd_sc_hd__nand2_1 U953 ( .A(n559), .B(n426), .Y(n560) );
  sky130_fd_sc_hd__inv_1 U954 ( .A(s_mem_q[463]), .Y(n561) );
  sky130_fd_sc_hd__o22ai_1 U955 ( .A1(n570), .A2(n561), .B1(n428), .B2(n568), 
        .Y(s_mem_d[463]) );
  sky130_fd_sc_hd__inv_1 U956 ( .A(s_mem_q[462]), .Y(n562) );
  sky130_fd_sc_hd__o22ai_1 U957 ( .A1(n570), .A2(n562), .B1(n365), .B2(n568), 
        .Y(s_mem_d[462]) );
  sky130_fd_sc_hd__inv_1 U958 ( .A(s_mem_q[461]), .Y(n563) );
  sky130_fd_sc_hd__o22ai_1 U959 ( .A1(n570), .A2(n563), .B1(n375), .B2(n568), 
        .Y(s_mem_d[461]) );
  sky130_fd_sc_hd__inv_1 U960 ( .A(s_mem_q[460]), .Y(n564) );
  sky130_fd_sc_hd__o22ai_1 U961 ( .A1(n570), .A2(n564), .B1(n385), .B2(n568), 
        .Y(s_mem_d[460]) );
  sky130_fd_sc_hd__inv_1 U962 ( .A(s_mem_q[459]), .Y(n565) );
  sky130_fd_sc_hd__o22ai_1 U963 ( .A1(n570), .A2(n565), .B1(n395), .B2(n568), 
        .Y(s_mem_d[459]) );
  sky130_fd_sc_hd__inv_1 U964 ( .A(s_mem_q[458]), .Y(n566) );
  sky130_fd_sc_hd__o22ai_1 U965 ( .A1(n570), .A2(n566), .B1(n405), .B2(n568), 
        .Y(s_mem_d[458]) );
  sky130_fd_sc_hd__inv_1 U966 ( .A(s_mem_q[457]), .Y(n567) );
  sky130_fd_sc_hd__o22ai_1 U967 ( .A1(n570), .A2(n567), .B1(n433), .B2(n568), 
        .Y(s_mem_d[457]) );
  sky130_fd_sc_hd__inv_1 U968 ( .A(s_mem_q[456]), .Y(n569) );
  sky130_fd_sc_hd__o22ai_1 U969 ( .A1(n570), .A2(n569), .B1(n438), .B2(n568), 
        .Y(s_mem_d[456]) );
  sky130_fd_sc_hd__nand3_1 U970 ( .A(n1252), .B(n1250), .C(n571), .Y(n572) );
  sky130_fd_sc_hd__clkinv_2 U971 ( .A(n572), .Y(n1224) );
  sky130_fd_sc_hd__nand2_1 U972 ( .A(n574), .B(n423), .Y(n575) );
  sky130_fd_sc_hd__inv_1 U973 ( .A(s_mem_q[455]), .Y(n576) );
  sky130_fd_sc_hd__o22ai_1 U974 ( .A1(n585), .A2(n576), .B1(n428), .B2(n583), 
        .Y(s_mem_d[455]) );
  sky130_fd_sc_hd__inv_1 U975 ( .A(s_mem_q[454]), .Y(n577) );
  sky130_fd_sc_hd__o22ai_1 U976 ( .A1(n585), .A2(n577), .B1(n372), .B2(n583), 
        .Y(s_mem_d[454]) );
  sky130_fd_sc_hd__inv_1 U977 ( .A(s_mem_q[453]), .Y(n578) );
  sky130_fd_sc_hd__o22ai_1 U978 ( .A1(n585), .A2(n578), .B1(n382), .B2(n583), 
        .Y(s_mem_d[453]) );
  sky130_fd_sc_hd__inv_1 U979 ( .A(s_mem_q[452]), .Y(n579) );
  sky130_fd_sc_hd__o22ai_1 U980 ( .A1(n585), .A2(n579), .B1(n392), .B2(n583), 
        .Y(s_mem_d[452]) );
  sky130_fd_sc_hd__inv_1 U981 ( .A(s_mem_q[451]), .Y(n580) );
  sky130_fd_sc_hd__o22ai_1 U982 ( .A1(n585), .A2(n580), .B1(n402), .B2(n583), 
        .Y(s_mem_d[451]) );
  sky130_fd_sc_hd__inv_1 U983 ( .A(s_mem_q[450]), .Y(n581) );
  sky130_fd_sc_hd__o22ai_1 U984 ( .A1(n585), .A2(n581), .B1(n412), .B2(n583), 
        .Y(s_mem_d[450]) );
  sky130_fd_sc_hd__inv_1 U985 ( .A(s_mem_q[449]), .Y(n582) );
  sky130_fd_sc_hd__o22ai_1 U986 ( .A1(n585), .A2(n582), .B1(n433), .B2(n583), 
        .Y(s_mem_d[449]) );
  sky130_fd_sc_hd__inv_1 U987 ( .A(s_mem_q[448]), .Y(n584) );
  sky130_fd_sc_hd__o22ai_1 U988 ( .A1(n585), .A2(n584), .B1(n438), .B2(n583), 
        .Y(s_mem_d[448]) );
  sky130_fd_sc_hd__inv_1 U989 ( .A(s_wr_ptr_q[3]), .Y(n1249) );
  sky130_fd_sc_hd__nand3_1 U990 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[4]), .C(
        n1249), .Y(n586) );
  sky130_fd_sc_hd__clkinv_2 U991 ( .A(n586), .Y(n671) );
  sky130_fd_sc_hd__nand2_1 U992 ( .A(n587), .B(n426), .Y(n588) );
  sky130_fd_sc_hd__inv_1 U993 ( .A(s_mem_q[447]), .Y(n589) );
  sky130_fd_sc_hd__o22ai_1 U994 ( .A1(n598), .A2(n589), .B1(n428), .B2(n596), 
        .Y(s_mem_d[447]) );
  sky130_fd_sc_hd__inv_1 U995 ( .A(s_mem_q[446]), .Y(n590) );
  sky130_fd_sc_hd__o22ai_1 U996 ( .A1(n598), .A2(n590), .B1(n366), .B2(n596), 
        .Y(s_mem_d[446]) );
  sky130_fd_sc_hd__inv_1 U997 ( .A(s_mem_q[445]), .Y(n591) );
  sky130_fd_sc_hd__o22ai_1 U998 ( .A1(n598), .A2(n591), .B1(n376), .B2(n596), 
        .Y(s_mem_d[445]) );
  sky130_fd_sc_hd__inv_1 U999 ( .A(s_mem_q[444]), .Y(n592) );
  sky130_fd_sc_hd__o22ai_1 U1000 ( .A1(n598), .A2(n592), .B1(n386), .B2(n596), 
        .Y(s_mem_d[444]) );
  sky130_fd_sc_hd__inv_1 U1001 ( .A(s_mem_q[443]), .Y(n593) );
  sky130_fd_sc_hd__o22ai_1 U1002 ( .A1(n598), .A2(n593), .B1(n396), .B2(n596), 
        .Y(s_mem_d[443]) );
  sky130_fd_sc_hd__inv_1 U1003 ( .A(s_mem_q[442]), .Y(n594) );
  sky130_fd_sc_hd__o22ai_1 U1004 ( .A1(n598), .A2(n594), .B1(n406), .B2(n596), 
        .Y(s_mem_d[442]) );
  sky130_fd_sc_hd__inv_1 U1005 ( .A(s_mem_q[441]), .Y(n595) );
  sky130_fd_sc_hd__o22ai_1 U1006 ( .A1(n598), .A2(n595), .B1(n433), .B2(n596), 
        .Y(s_mem_d[441]) );
  sky130_fd_sc_hd__inv_1 U1007 ( .A(s_mem_q[440]), .Y(n597) );
  sky130_fd_sc_hd__o22ai_1 U1008 ( .A1(n598), .A2(n597), .B1(n438), .B2(n596), 
        .Y(s_mem_d[440]) );
  sky130_fd_sc_hd__nand2_1 U1009 ( .A(n599), .B(n424), .Y(n600) );
  sky130_fd_sc_hd__inv_1 U1010 ( .A(s_mem_q[439]), .Y(n601) );
  sky130_fd_sc_hd__o22ai_1 U1011 ( .A1(n610), .A2(n601), .B1(n428), .B2(n608), 
        .Y(s_mem_d[439]) );
  sky130_fd_sc_hd__inv_1 U1012 ( .A(s_mem_q[438]), .Y(n602) );
  sky130_fd_sc_hd__o22ai_1 U1013 ( .A1(n610), .A2(n602), .B1(n371), .B2(n608), 
        .Y(s_mem_d[438]) );
  sky130_fd_sc_hd__inv_1 U1014 ( .A(s_mem_q[437]), .Y(n603) );
  sky130_fd_sc_hd__o22ai_1 U1015 ( .A1(n610), .A2(n603), .B1(n381), .B2(n608), 
        .Y(s_mem_d[437]) );
  sky130_fd_sc_hd__inv_1 U1016 ( .A(s_mem_q[436]), .Y(n604) );
  sky130_fd_sc_hd__o22ai_1 U1017 ( .A1(n610), .A2(n604), .B1(n391), .B2(n608), 
        .Y(s_mem_d[436]) );
  sky130_fd_sc_hd__inv_1 U1018 ( .A(s_mem_q[435]), .Y(n605) );
  sky130_fd_sc_hd__o22ai_1 U1019 ( .A1(n610), .A2(n605), .B1(n401), .B2(n608), 
        .Y(s_mem_d[435]) );
  sky130_fd_sc_hd__inv_1 U1020 ( .A(s_mem_q[434]), .Y(n606) );
  sky130_fd_sc_hd__o22ai_1 U1021 ( .A1(n610), .A2(n606), .B1(n411), .B2(n608), 
        .Y(s_mem_d[434]) );
  sky130_fd_sc_hd__inv_1 U1022 ( .A(s_mem_q[433]), .Y(n607) );
  sky130_fd_sc_hd__o22ai_1 U1023 ( .A1(n610), .A2(n607), .B1(n433), .B2(n608), 
        .Y(s_mem_d[433]) );
  sky130_fd_sc_hd__inv_1 U1024 ( .A(s_mem_q[432]), .Y(n609) );
  sky130_fd_sc_hd__o22ai_1 U1025 ( .A1(n610), .A2(n609), .B1(n438), .B2(n608), 
        .Y(s_mem_d[432]) );
  sky130_fd_sc_hd__nand2_1 U1026 ( .A(n611), .B(n423), .Y(n612) );
  sky130_fd_sc_hd__inv_1 U1027 ( .A(s_mem_q[431]), .Y(n613) );
  sky130_fd_sc_hd__o22ai_1 U1028 ( .A1(n622), .A2(n613), .B1(n428), .B2(n620), 
        .Y(s_mem_d[431]) );
  sky130_fd_sc_hd__inv_1 U1029 ( .A(s_mem_q[430]), .Y(n614) );
  sky130_fd_sc_hd__o22ai_1 U1030 ( .A1(n622), .A2(n614), .B1(n370), .B2(n620), 
        .Y(s_mem_d[430]) );
  sky130_fd_sc_hd__inv_1 U1031 ( .A(s_mem_q[429]), .Y(n615) );
  sky130_fd_sc_hd__o22ai_1 U1032 ( .A1(n622), .A2(n615), .B1(n380), .B2(n620), 
        .Y(s_mem_d[429]) );
  sky130_fd_sc_hd__inv_1 U1033 ( .A(s_mem_q[428]), .Y(n616) );
  sky130_fd_sc_hd__o22ai_1 U1034 ( .A1(n622), .A2(n616), .B1(n390), .B2(n620), 
        .Y(s_mem_d[428]) );
  sky130_fd_sc_hd__inv_1 U1035 ( .A(s_mem_q[427]), .Y(n617) );
  sky130_fd_sc_hd__o22ai_1 U1036 ( .A1(n622), .A2(n617), .B1(n400), .B2(n620), 
        .Y(s_mem_d[427]) );
  sky130_fd_sc_hd__inv_1 U1037 ( .A(s_mem_q[426]), .Y(n618) );
  sky130_fd_sc_hd__o22ai_1 U1038 ( .A1(n622), .A2(n618), .B1(n410), .B2(n620), 
        .Y(s_mem_d[426]) );
  sky130_fd_sc_hd__inv_1 U1039 ( .A(s_mem_q[425]), .Y(n619) );
  sky130_fd_sc_hd__o22ai_1 U1040 ( .A1(n622), .A2(n619), .B1(n433), .B2(n620), 
        .Y(s_mem_d[425]) );
  sky130_fd_sc_hd__inv_1 U1041 ( .A(s_mem_q[424]), .Y(n621) );
  sky130_fd_sc_hd__o22ai_1 U1042 ( .A1(n622), .A2(n621), .B1(n438), .B2(n620), 
        .Y(s_mem_d[424]) );
  sky130_fd_sc_hd__nand2_1 U1043 ( .A(n623), .B(n425), .Y(n624) );
  sky130_fd_sc_hd__inv_1 U1044 ( .A(s_mem_q[423]), .Y(n625) );
  sky130_fd_sc_hd__o22ai_1 U1045 ( .A1(n634), .A2(n625), .B1(n428), .B2(n632), 
        .Y(s_mem_d[423]) );
  sky130_fd_sc_hd__inv_1 U1046 ( .A(s_mem_q[422]), .Y(n626) );
  sky130_fd_sc_hd__o22ai_1 U1047 ( .A1(n634), .A2(n626), .B1(n368), .B2(n632), 
        .Y(s_mem_d[422]) );
  sky130_fd_sc_hd__inv_1 U1048 ( .A(s_mem_q[421]), .Y(n627) );
  sky130_fd_sc_hd__o22ai_1 U1049 ( .A1(n634), .A2(n627), .B1(n378), .B2(n632), 
        .Y(s_mem_d[421]) );
  sky130_fd_sc_hd__inv_1 U1050 ( .A(s_mem_q[420]), .Y(n628) );
  sky130_fd_sc_hd__o22ai_1 U1051 ( .A1(n634), .A2(n628), .B1(n388), .B2(n632), 
        .Y(s_mem_d[420]) );
  sky130_fd_sc_hd__inv_1 U1052 ( .A(s_mem_q[419]), .Y(n629) );
  sky130_fd_sc_hd__o22ai_1 U1053 ( .A1(n634), .A2(n629), .B1(n398), .B2(n632), 
        .Y(s_mem_d[419]) );
  sky130_fd_sc_hd__inv_1 U1054 ( .A(s_mem_q[418]), .Y(n630) );
  sky130_fd_sc_hd__o22ai_1 U1055 ( .A1(n634), .A2(n630), .B1(n408), .B2(n632), 
        .Y(s_mem_d[418]) );
  sky130_fd_sc_hd__inv_1 U1056 ( .A(s_mem_q[417]), .Y(n631) );
  sky130_fd_sc_hd__o22ai_1 U1057 ( .A1(n634), .A2(n631), .B1(n433), .B2(n632), 
        .Y(s_mem_d[417]) );
  sky130_fd_sc_hd__inv_1 U1058 ( .A(s_mem_q[416]), .Y(n633) );
  sky130_fd_sc_hd__o22ai_1 U1059 ( .A1(n634), .A2(n633), .B1(n438), .B2(n632), 
        .Y(s_mem_d[416]) );
  sky130_fd_sc_hd__nand2_1 U1060 ( .A(n635), .B(n427), .Y(n636) );
  sky130_fd_sc_hd__inv_1 U1061 ( .A(s_mem_q[415]), .Y(n637) );
  sky130_fd_sc_hd__o22ai_1 U1062 ( .A1(n646), .A2(n637), .B1(n428), .B2(n644), 
        .Y(s_mem_d[415]) );
  sky130_fd_sc_hd__inv_1 U1063 ( .A(s_mem_q[414]), .Y(n638) );
  sky130_fd_sc_hd__o22ai_1 U1064 ( .A1(n646), .A2(n638), .B1(n365), .B2(n644), 
        .Y(s_mem_d[414]) );
  sky130_fd_sc_hd__inv_1 U1065 ( .A(s_mem_q[413]), .Y(n639) );
  sky130_fd_sc_hd__o22ai_1 U1066 ( .A1(n646), .A2(n639), .B1(n375), .B2(n644), 
        .Y(s_mem_d[413]) );
  sky130_fd_sc_hd__inv_1 U1067 ( .A(s_mem_q[412]), .Y(n640) );
  sky130_fd_sc_hd__o22ai_1 U1068 ( .A1(n646), .A2(n640), .B1(n385), .B2(n644), 
        .Y(s_mem_d[412]) );
  sky130_fd_sc_hd__inv_1 U1069 ( .A(s_mem_q[411]), .Y(n641) );
  sky130_fd_sc_hd__o22ai_1 U1070 ( .A1(n646), .A2(n641), .B1(n395), .B2(n644), 
        .Y(s_mem_d[411]) );
  sky130_fd_sc_hd__inv_1 U1071 ( .A(s_mem_q[410]), .Y(n642) );
  sky130_fd_sc_hd__o22ai_1 U1072 ( .A1(n646), .A2(n642), .B1(n405), .B2(n644), 
        .Y(s_mem_d[410]) );
  sky130_fd_sc_hd__inv_1 U1073 ( .A(s_mem_q[409]), .Y(n643) );
  sky130_fd_sc_hd__o22ai_1 U1074 ( .A1(n646), .A2(n643), .B1(n433), .B2(n644), 
        .Y(s_mem_d[409]) );
  sky130_fd_sc_hd__inv_1 U1075 ( .A(s_mem_q[408]), .Y(n645) );
  sky130_fd_sc_hd__o22ai_1 U1076 ( .A1(n646), .A2(n645), .B1(n438), .B2(n644), 
        .Y(s_mem_d[408]) );
  sky130_fd_sc_hd__nand2_1 U1077 ( .A(n647), .B(n424), .Y(n648) );
  sky130_fd_sc_hd__inv_1 U1078 ( .A(s_mem_q[407]), .Y(n649) );
  sky130_fd_sc_hd__o22ai_1 U1079 ( .A1(n658), .A2(n649), .B1(n429), .B2(n656), 
        .Y(s_mem_d[407]) );
  sky130_fd_sc_hd__inv_1 U1080 ( .A(s_mem_q[406]), .Y(n650) );
  sky130_fd_sc_hd__o22ai_1 U1081 ( .A1(n658), .A2(n650), .B1(n366), .B2(n656), 
        .Y(s_mem_d[406]) );
  sky130_fd_sc_hd__inv_1 U1082 ( .A(s_mem_q[405]), .Y(n651) );
  sky130_fd_sc_hd__o22ai_1 U1083 ( .A1(n658), .A2(n651), .B1(n376), .B2(n656), 
        .Y(s_mem_d[405]) );
  sky130_fd_sc_hd__inv_1 U1084 ( .A(s_mem_q[404]), .Y(n652) );
  sky130_fd_sc_hd__o22ai_1 U1085 ( .A1(n658), .A2(n652), .B1(n386), .B2(n656), 
        .Y(s_mem_d[404]) );
  sky130_fd_sc_hd__inv_1 U1086 ( .A(s_mem_q[403]), .Y(n653) );
  sky130_fd_sc_hd__o22ai_1 U1087 ( .A1(n658), .A2(n653), .B1(n396), .B2(n656), 
        .Y(s_mem_d[403]) );
  sky130_fd_sc_hd__inv_1 U1088 ( .A(s_mem_q[402]), .Y(n654) );
  sky130_fd_sc_hd__o22ai_1 U1089 ( .A1(n658), .A2(n654), .B1(n406), .B2(n656), 
        .Y(s_mem_d[402]) );
  sky130_fd_sc_hd__inv_1 U1090 ( .A(s_mem_q[401]), .Y(n655) );
  sky130_fd_sc_hd__o22ai_1 U1091 ( .A1(n658), .A2(n655), .B1(n433), .B2(n656), 
        .Y(s_mem_d[401]) );
  sky130_fd_sc_hd__inv_1 U1092 ( .A(s_mem_q[400]), .Y(n657) );
  sky130_fd_sc_hd__o22ai_1 U1093 ( .A1(n658), .A2(n657), .B1(n438), .B2(n656), 
        .Y(s_mem_d[400]) );
  sky130_fd_sc_hd__nand2_1 U1094 ( .A(n659), .B(n426), .Y(n660) );
  sky130_fd_sc_hd__inv_1 U1095 ( .A(s_mem_q[399]), .Y(n661) );
  sky130_fd_sc_hd__o22ai_1 U1096 ( .A1(n670), .A2(n661), .B1(n429), .B2(n668), 
        .Y(s_mem_d[399]) );
  sky130_fd_sc_hd__inv_1 U1097 ( .A(s_mem_q[398]), .Y(n662) );
  sky130_fd_sc_hd__o22ai_1 U1098 ( .A1(n670), .A2(n662), .B1(n372), .B2(n668), 
        .Y(s_mem_d[398]) );
  sky130_fd_sc_hd__inv_1 U1099 ( .A(s_mem_q[397]), .Y(n663) );
  sky130_fd_sc_hd__o22ai_1 U1100 ( .A1(n670), .A2(n663), .B1(n382), .B2(n668), 
        .Y(s_mem_d[397]) );
  sky130_fd_sc_hd__inv_1 U1101 ( .A(s_mem_q[396]), .Y(n664) );
  sky130_fd_sc_hd__o22ai_1 U1102 ( .A1(n670), .A2(n664), .B1(n392), .B2(n668), 
        .Y(s_mem_d[396]) );
  sky130_fd_sc_hd__inv_1 U1103 ( .A(s_mem_q[395]), .Y(n665) );
  sky130_fd_sc_hd__o22ai_1 U1104 ( .A1(n670), .A2(n665), .B1(n402), .B2(n668), 
        .Y(s_mem_d[395]) );
  sky130_fd_sc_hd__inv_1 U1105 ( .A(s_mem_q[394]), .Y(n666) );
  sky130_fd_sc_hd__o22ai_1 U1106 ( .A1(n670), .A2(n666), .B1(n412), .B2(n668), 
        .Y(s_mem_d[394]) );
  sky130_fd_sc_hd__inv_1 U1107 ( .A(s_mem_q[393]), .Y(n667) );
  sky130_fd_sc_hd__o22ai_1 U1108 ( .A1(n670), .A2(n667), .B1(n434), .B2(n668), 
        .Y(s_mem_d[393]) );
  sky130_fd_sc_hd__inv_1 U1109 ( .A(s_mem_q[392]), .Y(n669) );
  sky130_fd_sc_hd__o22ai_1 U1110 ( .A1(n670), .A2(n669), .B1(n439), .B2(n668), 
        .Y(s_mem_d[392]) );
  sky130_fd_sc_hd__nand2_1 U1111 ( .A(n672), .B(n423), .Y(n673) );
  sky130_fd_sc_hd__inv_1 U1112 ( .A(s_mem_q[391]), .Y(n674) );
  sky130_fd_sc_hd__o22ai_1 U1113 ( .A1(n683), .A2(n674), .B1(n429), .B2(n681), 
        .Y(s_mem_d[391]) );
  sky130_fd_sc_hd__inv_1 U1114 ( .A(s_mem_q[390]), .Y(n675) );
  sky130_fd_sc_hd__o22ai_1 U1115 ( .A1(n683), .A2(n675), .B1(n371), .B2(n681), 
        .Y(s_mem_d[390]) );
  sky130_fd_sc_hd__inv_1 U1116 ( .A(s_mem_q[389]), .Y(n676) );
  sky130_fd_sc_hd__o22ai_1 U1117 ( .A1(n683), .A2(n676), .B1(n381), .B2(n681), 
        .Y(s_mem_d[389]) );
  sky130_fd_sc_hd__inv_1 U1118 ( .A(s_mem_q[388]), .Y(n677) );
  sky130_fd_sc_hd__o22ai_1 U1119 ( .A1(n683), .A2(n677), .B1(n391), .B2(n681), 
        .Y(s_mem_d[388]) );
  sky130_fd_sc_hd__inv_1 U1120 ( .A(s_mem_q[387]), .Y(n678) );
  sky130_fd_sc_hd__o22ai_1 U1121 ( .A1(n683), .A2(n678), .B1(n401), .B2(n681), 
        .Y(s_mem_d[387]) );
  sky130_fd_sc_hd__inv_1 U1122 ( .A(s_mem_q[386]), .Y(n679) );
  sky130_fd_sc_hd__o22ai_1 U1123 ( .A1(n683), .A2(n679), .B1(n411), .B2(n681), 
        .Y(s_mem_d[386]) );
  sky130_fd_sc_hd__inv_1 U1124 ( .A(s_mem_q[385]), .Y(n680) );
  sky130_fd_sc_hd__o22ai_1 U1125 ( .A1(n683), .A2(n680), .B1(n434), .B2(n681), 
        .Y(s_mem_d[385]) );
  sky130_fd_sc_hd__inv_1 U1126 ( .A(s_mem_q[384]), .Y(n682) );
  sky130_fd_sc_hd__o22ai_1 U1127 ( .A1(n683), .A2(n682), .B1(n439), .B2(n681), 
        .Y(s_mem_d[384]) );
  sky130_fd_sc_hd__inv_1 U1128 ( .A(s_wr_ptr_q[4]), .Y(n1248) );
  sky130_fd_sc_hd__nand3_1 U1129 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[3]), .C(
        n1248), .Y(n684) );
  sky130_fd_sc_hd__nand2_1 U1130 ( .A(n685), .B(n427), .Y(n686) );
  sky130_fd_sc_hd__inv_1 U1131 ( .A(s_mem_q[383]), .Y(n687) );
  sky130_fd_sc_hd__o22ai_1 U1132 ( .A1(n696), .A2(n687), .B1(n429), .B2(n694), 
        .Y(s_mem_d[383]) );
  sky130_fd_sc_hd__inv_1 U1133 ( .A(s_mem_q[382]), .Y(n688) );
  sky130_fd_sc_hd__o22ai_1 U1134 ( .A1(n696), .A2(n688), .B1(n368), .B2(n694), 
        .Y(s_mem_d[382]) );
  sky130_fd_sc_hd__inv_1 U1135 ( .A(s_mem_q[381]), .Y(n689) );
  sky130_fd_sc_hd__o22ai_1 U1136 ( .A1(n696), .A2(n689), .B1(n378), .B2(n694), 
        .Y(s_mem_d[381]) );
  sky130_fd_sc_hd__inv_1 U1137 ( .A(s_mem_q[380]), .Y(n690) );
  sky130_fd_sc_hd__o22ai_1 U1138 ( .A1(n696), .A2(n690), .B1(n388), .B2(n694), 
        .Y(s_mem_d[380]) );
  sky130_fd_sc_hd__inv_1 U1139 ( .A(s_mem_q[379]), .Y(n691) );
  sky130_fd_sc_hd__o22ai_1 U1140 ( .A1(n696), .A2(n691), .B1(n398), .B2(n694), 
        .Y(s_mem_d[379]) );
  sky130_fd_sc_hd__inv_1 U1141 ( .A(s_mem_q[378]), .Y(n692) );
  sky130_fd_sc_hd__o22ai_1 U1142 ( .A1(n696), .A2(n692), .B1(n408), .B2(n694), 
        .Y(s_mem_d[378]) );
  sky130_fd_sc_hd__inv_1 U1143 ( .A(s_mem_q[377]), .Y(n693) );
  sky130_fd_sc_hd__o22ai_1 U1144 ( .A1(n696), .A2(n693), .B1(n435), .B2(n694), 
        .Y(s_mem_d[377]) );
  sky130_fd_sc_hd__inv_1 U1145 ( .A(s_mem_q[376]), .Y(n695) );
  sky130_fd_sc_hd__o22ai_1 U1146 ( .A1(n696), .A2(n695), .B1(n440), .B2(n694), 
        .Y(s_mem_d[376]) );
  sky130_fd_sc_hd__nand2_1 U1147 ( .A(n697), .B(n37), .Y(n698) );
  sky130_fd_sc_hd__inv_1 U1148 ( .A(s_mem_q[375]), .Y(n699) );
  sky130_fd_sc_hd__o22ai_1 U1149 ( .A1(n708), .A2(n699), .B1(n429), .B2(n706), 
        .Y(s_mem_d[375]) );
  sky130_fd_sc_hd__inv_1 U1150 ( .A(s_mem_q[374]), .Y(n700) );
  sky130_fd_sc_hd__o22ai_1 U1151 ( .A1(n708), .A2(n700), .B1(n370), .B2(n706), 
        .Y(s_mem_d[374]) );
  sky130_fd_sc_hd__inv_1 U1152 ( .A(s_mem_q[373]), .Y(n701) );
  sky130_fd_sc_hd__o22ai_1 U1153 ( .A1(n708), .A2(n701), .B1(n380), .B2(n706), 
        .Y(s_mem_d[373]) );
  sky130_fd_sc_hd__inv_1 U1154 ( .A(s_mem_q[372]), .Y(n702) );
  sky130_fd_sc_hd__o22ai_1 U1155 ( .A1(n708), .A2(n702), .B1(n390), .B2(n706), 
        .Y(s_mem_d[372]) );
  sky130_fd_sc_hd__inv_1 U1156 ( .A(s_mem_q[371]), .Y(n703) );
  sky130_fd_sc_hd__o22ai_1 U1157 ( .A1(n708), .A2(n703), .B1(n400), .B2(n706), 
        .Y(s_mem_d[371]) );
  sky130_fd_sc_hd__inv_1 U1158 ( .A(s_mem_q[370]), .Y(n704) );
  sky130_fd_sc_hd__o22ai_1 U1159 ( .A1(n708), .A2(n704), .B1(n410), .B2(n706), 
        .Y(s_mem_d[370]) );
  sky130_fd_sc_hd__inv_1 U1160 ( .A(s_mem_q[369]), .Y(n705) );
  sky130_fd_sc_hd__o22ai_1 U1161 ( .A1(n708), .A2(n705), .B1(n434), .B2(n706), 
        .Y(s_mem_d[369]) );
  sky130_fd_sc_hd__inv_1 U1162 ( .A(s_mem_q[368]), .Y(n707) );
  sky130_fd_sc_hd__o22ai_1 U1163 ( .A1(n708), .A2(n707), .B1(n439), .B2(n706), 
        .Y(s_mem_d[368]) );
  sky130_fd_sc_hd__nand2_1 U1164 ( .A(n709), .B(n36), .Y(n710) );
  sky130_fd_sc_hd__inv_1 U1165 ( .A(s_mem_q[367]), .Y(n711) );
  sky130_fd_sc_hd__o22ai_1 U1166 ( .A1(n720), .A2(n711), .B1(n429), .B2(n718), 
        .Y(s_mem_d[367]) );
  sky130_fd_sc_hd__inv_1 U1167 ( .A(s_mem_q[366]), .Y(n712) );
  sky130_fd_sc_hd__o22ai_1 U1168 ( .A1(n720), .A2(n712), .B1(n371), .B2(n718), 
        .Y(s_mem_d[366]) );
  sky130_fd_sc_hd__inv_1 U1169 ( .A(s_mem_q[365]), .Y(n713) );
  sky130_fd_sc_hd__o22ai_1 U1170 ( .A1(n720), .A2(n713), .B1(n381), .B2(n718), 
        .Y(s_mem_d[365]) );
  sky130_fd_sc_hd__inv_1 U1171 ( .A(s_mem_q[364]), .Y(n714) );
  sky130_fd_sc_hd__o22ai_1 U1172 ( .A1(n720), .A2(n714), .B1(n391), .B2(n718), 
        .Y(s_mem_d[364]) );
  sky130_fd_sc_hd__inv_1 U1173 ( .A(s_mem_q[363]), .Y(n715) );
  sky130_fd_sc_hd__o22ai_1 U1174 ( .A1(n720), .A2(n715), .B1(n401), .B2(n718), 
        .Y(s_mem_d[363]) );
  sky130_fd_sc_hd__inv_1 U1175 ( .A(s_mem_q[362]), .Y(n716) );
  sky130_fd_sc_hd__o22ai_1 U1176 ( .A1(n720), .A2(n716), .B1(n411), .B2(n718), 
        .Y(s_mem_d[362]) );
  sky130_fd_sc_hd__inv_1 U1177 ( .A(s_mem_q[361]), .Y(n717) );
  sky130_fd_sc_hd__o22ai_1 U1178 ( .A1(n720), .A2(n717), .B1(n434), .B2(n718), 
        .Y(s_mem_d[361]) );
  sky130_fd_sc_hd__inv_1 U1179 ( .A(s_mem_q[360]), .Y(n719) );
  sky130_fd_sc_hd__o22ai_1 U1180 ( .A1(n720), .A2(n719), .B1(n439), .B2(n718), 
        .Y(s_mem_d[360]) );
  sky130_fd_sc_hd__nand2_1 U1181 ( .A(n721), .B(n36), .Y(n722) );
  sky130_fd_sc_hd__inv_1 U1182 ( .A(s_mem_q[359]), .Y(n723) );
  sky130_fd_sc_hd__o22ai_1 U1183 ( .A1(n732), .A2(n723), .B1(n429), .B2(n730), 
        .Y(s_mem_d[359]) );
  sky130_fd_sc_hd__inv_1 U1184 ( .A(s_mem_q[358]), .Y(n724) );
  sky130_fd_sc_hd__o22ai_1 U1185 ( .A1(n732), .A2(n724), .B1(n368), .B2(n730), 
        .Y(s_mem_d[358]) );
  sky130_fd_sc_hd__inv_1 U1186 ( .A(s_mem_q[357]), .Y(n725) );
  sky130_fd_sc_hd__o22ai_1 U1187 ( .A1(n732), .A2(n725), .B1(n378), .B2(n730), 
        .Y(s_mem_d[357]) );
  sky130_fd_sc_hd__inv_1 U1188 ( .A(s_mem_q[356]), .Y(n726) );
  sky130_fd_sc_hd__o22ai_1 U1189 ( .A1(n732), .A2(n726), .B1(n388), .B2(n730), 
        .Y(s_mem_d[356]) );
  sky130_fd_sc_hd__inv_1 U1190 ( .A(s_mem_q[355]), .Y(n727) );
  sky130_fd_sc_hd__o22ai_1 U1191 ( .A1(n732), .A2(n727), .B1(n398), .B2(n730), 
        .Y(s_mem_d[355]) );
  sky130_fd_sc_hd__inv_1 U1192 ( .A(s_mem_q[354]), .Y(n728) );
  sky130_fd_sc_hd__o22ai_1 U1193 ( .A1(n732), .A2(n728), .B1(n408), .B2(n730), 
        .Y(s_mem_d[354]) );
  sky130_fd_sc_hd__inv_1 U1194 ( .A(s_mem_q[353]), .Y(n729) );
  sky130_fd_sc_hd__o22ai_1 U1195 ( .A1(n732), .A2(n729), .B1(n434), .B2(n730), 
        .Y(s_mem_d[353]) );
  sky130_fd_sc_hd__inv_1 U1196 ( .A(s_mem_q[352]), .Y(n731) );
  sky130_fd_sc_hd__o22ai_1 U1197 ( .A1(n732), .A2(n731), .B1(n439), .B2(n730), 
        .Y(s_mem_d[352]) );
  sky130_fd_sc_hd__nand2_1 U1198 ( .A(n733), .B(n37), .Y(n734) );
  sky130_fd_sc_hd__inv_1 U1199 ( .A(s_mem_q[351]), .Y(n735) );
  sky130_fd_sc_hd__o22ai_1 U1200 ( .A1(n744), .A2(n735), .B1(n429), .B2(n742), 
        .Y(s_mem_d[351]) );
  sky130_fd_sc_hd__inv_1 U1201 ( .A(s_mem_q[350]), .Y(n736) );
  sky130_fd_sc_hd__o22ai_1 U1202 ( .A1(n744), .A2(n736), .B1(n366), .B2(n742), 
        .Y(s_mem_d[350]) );
  sky130_fd_sc_hd__inv_1 U1203 ( .A(s_mem_q[349]), .Y(n737) );
  sky130_fd_sc_hd__o22ai_1 U1204 ( .A1(n744), .A2(n737), .B1(n376), .B2(n742), 
        .Y(s_mem_d[349]) );
  sky130_fd_sc_hd__inv_1 U1205 ( .A(s_mem_q[348]), .Y(n738) );
  sky130_fd_sc_hd__o22ai_1 U1206 ( .A1(n744), .A2(n738), .B1(n386), .B2(n742), 
        .Y(s_mem_d[348]) );
  sky130_fd_sc_hd__inv_1 U1207 ( .A(s_mem_q[347]), .Y(n739) );
  sky130_fd_sc_hd__o22ai_1 U1208 ( .A1(n744), .A2(n739), .B1(n396), .B2(n742), 
        .Y(s_mem_d[347]) );
  sky130_fd_sc_hd__inv_1 U1209 ( .A(s_mem_q[346]), .Y(n740) );
  sky130_fd_sc_hd__o22ai_1 U1210 ( .A1(n744), .A2(n740), .B1(n406), .B2(n742), 
        .Y(s_mem_d[346]) );
  sky130_fd_sc_hd__inv_1 U1211 ( .A(s_mem_q[345]), .Y(n741) );
  sky130_fd_sc_hd__o22ai_1 U1212 ( .A1(n744), .A2(n741), .B1(n434), .B2(n742), 
        .Y(s_mem_d[345]) );
  sky130_fd_sc_hd__inv_1 U1213 ( .A(s_mem_q[344]), .Y(n743) );
  sky130_fd_sc_hd__o22ai_1 U1214 ( .A1(n744), .A2(n743), .B1(n439), .B2(n742), 
        .Y(s_mem_d[344]) );
  sky130_fd_sc_hd__nand2_1 U1215 ( .A(n745), .B(n36), .Y(n746) );
  sky130_fd_sc_hd__inv_1 U1216 ( .A(s_mem_q[343]), .Y(n747) );
  sky130_fd_sc_hd__o22ai_1 U1217 ( .A1(n756), .A2(n747), .B1(n429), .B2(n754), 
        .Y(s_mem_d[343]) );
  sky130_fd_sc_hd__inv_1 U1218 ( .A(s_mem_q[342]), .Y(n748) );
  sky130_fd_sc_hd__o22ai_1 U1219 ( .A1(n756), .A2(n748), .B1(n371), .B2(n754), 
        .Y(s_mem_d[342]) );
  sky130_fd_sc_hd__inv_1 U1220 ( .A(s_mem_q[341]), .Y(n749) );
  sky130_fd_sc_hd__o22ai_1 U1221 ( .A1(n756), .A2(n749), .B1(n381), .B2(n754), 
        .Y(s_mem_d[341]) );
  sky130_fd_sc_hd__inv_1 U1222 ( .A(s_mem_q[340]), .Y(n750) );
  sky130_fd_sc_hd__o22ai_1 U1223 ( .A1(n756), .A2(n750), .B1(n391), .B2(n754), 
        .Y(s_mem_d[340]) );
  sky130_fd_sc_hd__inv_1 U1224 ( .A(s_mem_q[339]), .Y(n751) );
  sky130_fd_sc_hd__o22ai_1 U1225 ( .A1(n756), .A2(n751), .B1(n401), .B2(n754), 
        .Y(s_mem_d[339]) );
  sky130_fd_sc_hd__inv_1 U1226 ( .A(s_mem_q[338]), .Y(n752) );
  sky130_fd_sc_hd__o22ai_1 U1227 ( .A1(n756), .A2(n752), .B1(n411), .B2(n754), 
        .Y(s_mem_d[338]) );
  sky130_fd_sc_hd__inv_1 U1228 ( .A(s_mem_q[337]), .Y(n753) );
  sky130_fd_sc_hd__o22ai_1 U1229 ( .A1(n756), .A2(n753), .B1(n434), .B2(n754), 
        .Y(s_mem_d[337]) );
  sky130_fd_sc_hd__inv_1 U1230 ( .A(s_mem_q[336]), .Y(n755) );
  sky130_fd_sc_hd__o22ai_1 U1231 ( .A1(n756), .A2(n755), .B1(n439), .B2(n754), 
        .Y(s_mem_d[336]) );
  sky130_fd_sc_hd__nand2_1 U1232 ( .A(n757), .B(n37), .Y(n758) );
  sky130_fd_sc_hd__inv_1 U1233 ( .A(s_mem_q[335]), .Y(n759) );
  sky130_fd_sc_hd__o22ai_1 U1234 ( .A1(n768), .A2(n759), .B1(n429), .B2(n766), 
        .Y(s_mem_d[335]) );
  sky130_fd_sc_hd__inv_1 U1235 ( .A(s_mem_q[334]), .Y(n760) );
  sky130_fd_sc_hd__o22ai_1 U1236 ( .A1(n768), .A2(n760), .B1(n369), .B2(n766), 
        .Y(s_mem_d[334]) );
  sky130_fd_sc_hd__inv_1 U1237 ( .A(s_mem_q[333]), .Y(n761) );
  sky130_fd_sc_hd__o22ai_1 U1238 ( .A1(n768), .A2(n761), .B1(n379), .B2(n766), 
        .Y(s_mem_d[333]) );
  sky130_fd_sc_hd__inv_1 U1239 ( .A(s_mem_q[332]), .Y(n762) );
  sky130_fd_sc_hd__o22ai_1 U1240 ( .A1(n768), .A2(n762), .B1(n389), .B2(n766), 
        .Y(s_mem_d[332]) );
  sky130_fd_sc_hd__inv_1 U1241 ( .A(s_mem_q[331]), .Y(n763) );
  sky130_fd_sc_hd__o22ai_1 U1242 ( .A1(n768), .A2(n763), .B1(n399), .B2(n766), 
        .Y(s_mem_d[331]) );
  sky130_fd_sc_hd__inv_1 U1243 ( .A(s_mem_q[330]), .Y(n764) );
  sky130_fd_sc_hd__o22ai_1 U1244 ( .A1(n768), .A2(n764), .B1(n409), .B2(n766), 
        .Y(s_mem_d[330]) );
  sky130_fd_sc_hd__inv_1 U1245 ( .A(s_mem_q[329]), .Y(n765) );
  sky130_fd_sc_hd__o22ai_1 U1246 ( .A1(n768), .A2(n765), .B1(n434), .B2(n766), 
        .Y(s_mem_d[329]) );
  sky130_fd_sc_hd__inv_1 U1247 ( .A(s_mem_q[328]), .Y(n767) );
  sky130_fd_sc_hd__o22ai_1 U1248 ( .A1(n768), .A2(n767), .B1(n439), .B2(n766), 
        .Y(s_mem_d[328]) );
  sky130_fd_sc_hd__nand2_1 U1249 ( .A(n770), .B(n37), .Y(n771) );
  sky130_fd_sc_hd__inv_1 U1250 ( .A(s_mem_q[327]), .Y(n772) );
  sky130_fd_sc_hd__o22ai_1 U1251 ( .A1(n781), .A2(n772), .B1(n429), .B2(n779), 
        .Y(s_mem_d[327]) );
  sky130_fd_sc_hd__inv_1 U1252 ( .A(s_mem_q[326]), .Y(n773) );
  sky130_fd_sc_hd__o22ai_1 U1253 ( .A1(n781), .A2(n773), .B1(n372), .B2(n779), 
        .Y(s_mem_d[326]) );
  sky130_fd_sc_hd__inv_1 U1254 ( .A(s_mem_q[325]), .Y(n774) );
  sky130_fd_sc_hd__o22ai_1 U1255 ( .A1(n781), .A2(n774), .B1(n382), .B2(n779), 
        .Y(s_mem_d[325]) );
  sky130_fd_sc_hd__inv_1 U1256 ( .A(s_mem_q[324]), .Y(n775) );
  sky130_fd_sc_hd__o22ai_1 U1257 ( .A1(n781), .A2(n775), .B1(n392), .B2(n779), 
        .Y(s_mem_d[324]) );
  sky130_fd_sc_hd__inv_1 U1258 ( .A(s_mem_q[323]), .Y(n776) );
  sky130_fd_sc_hd__o22ai_1 U1259 ( .A1(n781), .A2(n776), .B1(n402), .B2(n779), 
        .Y(s_mem_d[323]) );
  sky130_fd_sc_hd__inv_1 U1260 ( .A(s_mem_q[322]), .Y(n777) );
  sky130_fd_sc_hd__o22ai_1 U1261 ( .A1(n781), .A2(n777), .B1(n412), .B2(n779), 
        .Y(s_mem_d[322]) );
  sky130_fd_sc_hd__inv_1 U1262 ( .A(s_mem_q[321]), .Y(n778) );
  sky130_fd_sc_hd__o22ai_1 U1263 ( .A1(n781), .A2(n778), .B1(n434), .B2(n779), 
        .Y(s_mem_d[321]) );
  sky130_fd_sc_hd__inv_1 U1264 ( .A(s_mem_q[320]), .Y(n780) );
  sky130_fd_sc_hd__o22ai_1 U1265 ( .A1(n781), .A2(n780), .B1(n439), .B2(n779), 
        .Y(s_mem_d[320]) );
  sky130_fd_sc_hd__nand3_1 U1266 ( .A(s_wr_ptr_q[5]), .B(n1248), .C(n1249), 
        .Y(n782) );
  sky130_fd_sc_hd__nand2_1 U1267 ( .A(n783), .B(n37), .Y(n784) );
  sky130_fd_sc_hd__inv_1 U1268 ( .A(s_mem_q[319]), .Y(n785) );
  sky130_fd_sc_hd__o22ai_1 U1269 ( .A1(n794), .A2(n785), .B1(n429), .B2(n792), 
        .Y(s_mem_d[319]) );
  sky130_fd_sc_hd__inv_1 U1270 ( .A(s_mem_q[318]), .Y(n786) );
  sky130_fd_sc_hd__o22ai_1 U1271 ( .A1(n794), .A2(n786), .B1(n367), .B2(n792), 
        .Y(s_mem_d[318]) );
  sky130_fd_sc_hd__inv_1 U1272 ( .A(s_mem_q[317]), .Y(n787) );
  sky130_fd_sc_hd__o22ai_1 U1273 ( .A1(n794), .A2(n787), .B1(n377), .B2(n792), 
        .Y(s_mem_d[317]) );
  sky130_fd_sc_hd__inv_1 U1274 ( .A(s_mem_q[316]), .Y(n788) );
  sky130_fd_sc_hd__o22ai_1 U1275 ( .A1(n794), .A2(n788), .B1(n387), .B2(n792), 
        .Y(s_mem_d[316]) );
  sky130_fd_sc_hd__inv_1 U1276 ( .A(s_mem_q[315]), .Y(n789) );
  sky130_fd_sc_hd__o22ai_1 U1277 ( .A1(n794), .A2(n789), .B1(n397), .B2(n792), 
        .Y(s_mem_d[315]) );
  sky130_fd_sc_hd__inv_1 U1278 ( .A(s_mem_q[314]), .Y(n790) );
  sky130_fd_sc_hd__o22ai_1 U1279 ( .A1(n794), .A2(n790), .B1(n407), .B2(n792), 
        .Y(s_mem_d[314]) );
  sky130_fd_sc_hd__inv_1 U1280 ( .A(s_mem_q[313]), .Y(n791) );
  sky130_fd_sc_hd__o22ai_1 U1281 ( .A1(n794), .A2(n791), .B1(n434), .B2(n792), 
        .Y(s_mem_d[313]) );
  sky130_fd_sc_hd__inv_1 U1282 ( .A(s_mem_q[312]), .Y(n793) );
  sky130_fd_sc_hd__o22ai_1 U1283 ( .A1(n794), .A2(n793), .B1(n439), .B2(n792), 
        .Y(s_mem_d[312]) );
  sky130_fd_sc_hd__nand2_1 U1284 ( .A(n795), .B(n36), .Y(n796) );
  sky130_fd_sc_hd__inv_1 U1285 ( .A(s_mem_q[311]), .Y(n797) );
  sky130_fd_sc_hd__o22ai_1 U1286 ( .A1(n806), .A2(n797), .B1(n429), .B2(n804), 
        .Y(s_mem_d[311]) );
  sky130_fd_sc_hd__inv_1 U1287 ( .A(s_mem_q[310]), .Y(n798) );
  sky130_fd_sc_hd__o22ai_1 U1288 ( .A1(n806), .A2(n798), .B1(n367), .B2(n804), 
        .Y(s_mem_d[310]) );
  sky130_fd_sc_hd__inv_1 U1289 ( .A(s_mem_q[309]), .Y(n799) );
  sky130_fd_sc_hd__o22ai_1 U1290 ( .A1(n806), .A2(n799), .B1(n377), .B2(n804), 
        .Y(s_mem_d[309]) );
  sky130_fd_sc_hd__inv_1 U1291 ( .A(s_mem_q[308]), .Y(n800) );
  sky130_fd_sc_hd__o22ai_1 U1292 ( .A1(n806), .A2(n800), .B1(n387), .B2(n804), 
        .Y(s_mem_d[308]) );
  sky130_fd_sc_hd__inv_1 U1293 ( .A(s_mem_q[307]), .Y(n801) );
  sky130_fd_sc_hd__o22ai_1 U1294 ( .A1(n806), .A2(n801), .B1(n397), .B2(n804), 
        .Y(s_mem_d[307]) );
  sky130_fd_sc_hd__inv_1 U1295 ( .A(s_mem_q[306]), .Y(n802) );
  sky130_fd_sc_hd__o22ai_1 U1296 ( .A1(n806), .A2(n802), .B1(n407), .B2(n804), 
        .Y(s_mem_d[306]) );
  sky130_fd_sc_hd__inv_1 U1297 ( .A(s_mem_q[305]), .Y(n803) );
  sky130_fd_sc_hd__o22ai_1 U1298 ( .A1(n806), .A2(n803), .B1(n434), .B2(n804), 
        .Y(s_mem_d[305]) );
  sky130_fd_sc_hd__inv_1 U1299 ( .A(s_mem_q[304]), .Y(n805) );
  sky130_fd_sc_hd__o22ai_1 U1300 ( .A1(n806), .A2(n805), .B1(n439), .B2(n804), 
        .Y(s_mem_d[304]) );
  sky130_fd_sc_hd__nand2_1 U1301 ( .A(n807), .B(n37), .Y(n808) );
  sky130_fd_sc_hd__inv_1 U1302 ( .A(s_mem_q[303]), .Y(n809) );
  sky130_fd_sc_hd__o22ai_1 U1303 ( .A1(n818), .A2(n809), .B1(n430), .B2(n816), 
        .Y(s_mem_d[303]) );
  sky130_fd_sc_hd__inv_1 U1304 ( .A(s_mem_q[302]), .Y(n810) );
  sky130_fd_sc_hd__o22ai_1 U1305 ( .A1(n818), .A2(n810), .B1(n368), .B2(n816), 
        .Y(s_mem_d[302]) );
  sky130_fd_sc_hd__inv_1 U1306 ( .A(s_mem_q[301]), .Y(n811) );
  sky130_fd_sc_hd__o22ai_1 U1307 ( .A1(n818), .A2(n811), .B1(n378), .B2(n816), 
        .Y(s_mem_d[301]) );
  sky130_fd_sc_hd__inv_1 U1308 ( .A(s_mem_q[300]), .Y(n812) );
  sky130_fd_sc_hd__o22ai_1 U1309 ( .A1(n818), .A2(n812), .B1(n388), .B2(n816), 
        .Y(s_mem_d[300]) );
  sky130_fd_sc_hd__inv_1 U1310 ( .A(s_mem_q[299]), .Y(n813) );
  sky130_fd_sc_hd__o22ai_1 U1311 ( .A1(n818), .A2(n813), .B1(n398), .B2(n816), 
        .Y(s_mem_d[299]) );
  sky130_fd_sc_hd__inv_1 U1312 ( .A(s_mem_q[298]), .Y(n814) );
  sky130_fd_sc_hd__o22ai_1 U1313 ( .A1(n818), .A2(n814), .B1(n408), .B2(n816), 
        .Y(s_mem_d[298]) );
  sky130_fd_sc_hd__inv_1 U1314 ( .A(s_mem_q[297]), .Y(n815) );
  sky130_fd_sc_hd__o22ai_1 U1315 ( .A1(n818), .A2(n815), .B1(n434), .B2(n816), 
        .Y(s_mem_d[297]) );
  sky130_fd_sc_hd__inv_1 U1316 ( .A(s_mem_q[296]), .Y(n817) );
  sky130_fd_sc_hd__o22ai_1 U1317 ( .A1(n818), .A2(n817), .B1(n439), .B2(n816), 
        .Y(s_mem_d[296]) );
  sky130_fd_sc_hd__nand2_1 U1318 ( .A(n819), .B(n36), .Y(n820) );
  sky130_fd_sc_hd__inv_1 U1319 ( .A(s_mem_q[295]), .Y(n821) );
  sky130_fd_sc_hd__o22ai_1 U1320 ( .A1(n830), .A2(n821), .B1(n430), .B2(n828), 
        .Y(s_mem_d[295]) );
  sky130_fd_sc_hd__inv_1 U1321 ( .A(s_mem_q[294]), .Y(n822) );
  sky130_fd_sc_hd__o22ai_1 U1322 ( .A1(n830), .A2(n822), .B1(n367), .B2(n828), 
        .Y(s_mem_d[294]) );
  sky130_fd_sc_hd__inv_1 U1323 ( .A(s_mem_q[293]), .Y(n823) );
  sky130_fd_sc_hd__o22ai_1 U1324 ( .A1(n830), .A2(n823), .B1(n377), .B2(n828), 
        .Y(s_mem_d[293]) );
  sky130_fd_sc_hd__inv_1 U1325 ( .A(s_mem_q[292]), .Y(n824) );
  sky130_fd_sc_hd__o22ai_1 U1326 ( .A1(n830), .A2(n824), .B1(n387), .B2(n828), 
        .Y(s_mem_d[292]) );
  sky130_fd_sc_hd__inv_1 U1327 ( .A(s_mem_q[291]), .Y(n825) );
  sky130_fd_sc_hd__o22ai_1 U1328 ( .A1(n830), .A2(n825), .B1(n397), .B2(n828), 
        .Y(s_mem_d[291]) );
  sky130_fd_sc_hd__inv_1 U1329 ( .A(s_mem_q[290]), .Y(n826) );
  sky130_fd_sc_hd__o22ai_1 U1330 ( .A1(n830), .A2(n826), .B1(n407), .B2(n828), 
        .Y(s_mem_d[290]) );
  sky130_fd_sc_hd__inv_1 U1331 ( .A(s_mem_q[289]), .Y(n827) );
  sky130_fd_sc_hd__o22ai_1 U1332 ( .A1(n830), .A2(n827), .B1(n434), .B2(n828), 
        .Y(s_mem_d[289]) );
  sky130_fd_sc_hd__inv_1 U1333 ( .A(s_mem_q[288]), .Y(n829) );
  sky130_fd_sc_hd__o22ai_1 U1334 ( .A1(n830), .A2(n829), .B1(n439), .B2(n828), 
        .Y(s_mem_d[288]) );
  sky130_fd_sc_hd__nand2_1 U1335 ( .A(n831), .B(n36), .Y(n832) );
  sky130_fd_sc_hd__inv_1 U1336 ( .A(s_mem_q[287]), .Y(n833) );
  sky130_fd_sc_hd__o22ai_1 U1337 ( .A1(n842), .A2(n833), .B1(n430), .B2(n840), 
        .Y(s_mem_d[287]) );
  sky130_fd_sc_hd__inv_1 U1338 ( .A(s_mem_q[286]), .Y(n834) );
  sky130_fd_sc_hd__o22ai_1 U1339 ( .A1(n842), .A2(n834), .B1(n369), .B2(n840), 
        .Y(s_mem_d[286]) );
  sky130_fd_sc_hd__inv_1 U1340 ( .A(s_mem_q[285]), .Y(n835) );
  sky130_fd_sc_hd__o22ai_1 U1341 ( .A1(n842), .A2(n835), .B1(n379), .B2(n840), 
        .Y(s_mem_d[285]) );
  sky130_fd_sc_hd__inv_1 U1342 ( .A(s_mem_q[284]), .Y(n836) );
  sky130_fd_sc_hd__o22ai_1 U1343 ( .A1(n842), .A2(n836), .B1(n389), .B2(n840), 
        .Y(s_mem_d[284]) );
  sky130_fd_sc_hd__inv_1 U1344 ( .A(s_mem_q[283]), .Y(n837) );
  sky130_fd_sc_hd__o22ai_1 U1345 ( .A1(n842), .A2(n837), .B1(n399), .B2(n840), 
        .Y(s_mem_d[283]) );
  sky130_fd_sc_hd__inv_1 U1346 ( .A(s_mem_q[282]), .Y(n838) );
  sky130_fd_sc_hd__o22ai_1 U1347 ( .A1(n842), .A2(n838), .B1(n409), .B2(n840), 
        .Y(s_mem_d[282]) );
  sky130_fd_sc_hd__inv_1 U1348 ( .A(s_mem_q[281]), .Y(n839) );
  sky130_fd_sc_hd__o22ai_1 U1349 ( .A1(n842), .A2(n839), .B1(n435), .B2(n840), 
        .Y(s_mem_d[281]) );
  sky130_fd_sc_hd__inv_1 U1350 ( .A(s_mem_q[280]), .Y(n841) );
  sky130_fd_sc_hd__o22ai_1 U1351 ( .A1(n842), .A2(n841), .B1(n440), .B2(n840), 
        .Y(s_mem_d[280]) );
  sky130_fd_sc_hd__nand2_1 U1352 ( .A(n843), .B(n36), .Y(n844) );
  sky130_fd_sc_hd__inv_1 U1353 ( .A(s_mem_q[279]), .Y(n845) );
  sky130_fd_sc_hd__o22ai_1 U1354 ( .A1(n854), .A2(n845), .B1(n430), .B2(n852), 
        .Y(s_mem_d[279]) );
  sky130_fd_sc_hd__inv_1 U1355 ( .A(s_mem_q[278]), .Y(n846) );
  sky130_fd_sc_hd__o22ai_1 U1356 ( .A1(n854), .A2(n846), .B1(n371), .B2(n852), 
        .Y(s_mem_d[278]) );
  sky130_fd_sc_hd__inv_1 U1357 ( .A(s_mem_q[277]), .Y(n847) );
  sky130_fd_sc_hd__o22ai_1 U1358 ( .A1(n854), .A2(n847), .B1(n381), .B2(n852), 
        .Y(s_mem_d[277]) );
  sky130_fd_sc_hd__inv_1 U1359 ( .A(s_mem_q[276]), .Y(n848) );
  sky130_fd_sc_hd__o22ai_1 U1360 ( .A1(n854), .A2(n848), .B1(n391), .B2(n852), 
        .Y(s_mem_d[276]) );
  sky130_fd_sc_hd__inv_1 U1361 ( .A(s_mem_q[275]), .Y(n849) );
  sky130_fd_sc_hd__o22ai_1 U1362 ( .A1(n854), .A2(n849), .B1(n401), .B2(n852), 
        .Y(s_mem_d[275]) );
  sky130_fd_sc_hd__inv_1 U1363 ( .A(s_mem_q[274]), .Y(n850) );
  sky130_fd_sc_hd__o22ai_1 U1364 ( .A1(n854), .A2(n850), .B1(n411), .B2(n852), 
        .Y(s_mem_d[274]) );
  sky130_fd_sc_hd__inv_1 U1365 ( .A(s_mem_q[273]), .Y(n851) );
  sky130_fd_sc_hd__o22ai_1 U1366 ( .A1(n854), .A2(n851), .B1(n435), .B2(n852), 
        .Y(s_mem_d[273]) );
  sky130_fd_sc_hd__inv_1 U1367 ( .A(s_mem_q[272]), .Y(n853) );
  sky130_fd_sc_hd__o22ai_1 U1368 ( .A1(n854), .A2(n853), .B1(n440), .B2(n852), 
        .Y(s_mem_d[272]) );
  sky130_fd_sc_hd__nand2_1 U1369 ( .A(n855), .B(n427), .Y(n856) );
  sky130_fd_sc_hd__inv_1 U1370 ( .A(s_mem_q[271]), .Y(n857) );
  sky130_fd_sc_hd__o22ai_1 U1371 ( .A1(n866), .A2(n857), .B1(n430), .B2(n864), 
        .Y(s_mem_d[271]) );
  sky130_fd_sc_hd__inv_1 U1372 ( .A(s_mem_q[270]), .Y(n858) );
  sky130_fd_sc_hd__o22ai_1 U1373 ( .A1(n866), .A2(n858), .B1(n369), .B2(n864), 
        .Y(s_mem_d[270]) );
  sky130_fd_sc_hd__inv_1 U1374 ( .A(s_mem_q[269]), .Y(n859) );
  sky130_fd_sc_hd__o22ai_1 U1375 ( .A1(n866), .A2(n859), .B1(n379), .B2(n864), 
        .Y(s_mem_d[269]) );
  sky130_fd_sc_hd__inv_1 U1376 ( .A(s_mem_q[268]), .Y(n860) );
  sky130_fd_sc_hd__o22ai_1 U1377 ( .A1(n866), .A2(n860), .B1(n389), .B2(n864), 
        .Y(s_mem_d[268]) );
  sky130_fd_sc_hd__inv_1 U1378 ( .A(s_mem_q[267]), .Y(n861) );
  sky130_fd_sc_hd__o22ai_1 U1379 ( .A1(n866), .A2(n861), .B1(n399), .B2(n864), 
        .Y(s_mem_d[267]) );
  sky130_fd_sc_hd__inv_1 U1380 ( .A(s_mem_q[266]), .Y(n862) );
  sky130_fd_sc_hd__o22ai_1 U1381 ( .A1(n866), .A2(n862), .B1(n409), .B2(n864), 
        .Y(s_mem_d[266]) );
  sky130_fd_sc_hd__inv_1 U1382 ( .A(s_mem_q[265]), .Y(n863) );
  sky130_fd_sc_hd__o22ai_1 U1383 ( .A1(n866), .A2(n863), .B1(n435), .B2(n864), 
        .Y(s_mem_d[265]) );
  sky130_fd_sc_hd__inv_1 U1384 ( .A(s_mem_q[264]), .Y(n865) );
  sky130_fd_sc_hd__o22ai_1 U1385 ( .A1(n866), .A2(n865), .B1(n440), .B2(n864), 
        .Y(s_mem_d[264]) );
  sky130_fd_sc_hd__nand2_1 U1386 ( .A(n868), .B(n424), .Y(n869) );
  sky130_fd_sc_hd__inv_1 U1387 ( .A(s_mem_q[263]), .Y(n870) );
  sky130_fd_sc_hd__o22ai_1 U1388 ( .A1(n879), .A2(n870), .B1(n430), .B2(n877), 
        .Y(s_mem_d[263]) );
  sky130_fd_sc_hd__inv_1 U1389 ( .A(s_mem_q[262]), .Y(n871) );
  sky130_fd_sc_hd__o22ai_1 U1390 ( .A1(n879), .A2(n871), .B1(n368), .B2(n877), 
        .Y(s_mem_d[262]) );
  sky130_fd_sc_hd__inv_1 U1391 ( .A(s_mem_q[261]), .Y(n872) );
  sky130_fd_sc_hd__o22ai_1 U1392 ( .A1(n879), .A2(n872), .B1(n378), .B2(n877), 
        .Y(s_mem_d[261]) );
  sky130_fd_sc_hd__inv_1 U1393 ( .A(s_mem_q[260]), .Y(n873) );
  sky130_fd_sc_hd__o22ai_1 U1394 ( .A1(n879), .A2(n873), .B1(n388), .B2(n877), 
        .Y(s_mem_d[260]) );
  sky130_fd_sc_hd__inv_1 U1395 ( .A(s_mem_q[259]), .Y(n874) );
  sky130_fd_sc_hd__o22ai_1 U1396 ( .A1(n879), .A2(n874), .B1(n398), .B2(n877), 
        .Y(s_mem_d[259]) );
  sky130_fd_sc_hd__inv_1 U1397 ( .A(s_mem_q[258]), .Y(n875) );
  sky130_fd_sc_hd__o22ai_1 U1398 ( .A1(n879), .A2(n875), .B1(n408), .B2(n877), 
        .Y(s_mem_d[258]) );
  sky130_fd_sc_hd__inv_1 U1399 ( .A(s_mem_q[257]), .Y(n876) );
  sky130_fd_sc_hd__o22ai_1 U1400 ( .A1(n879), .A2(n876), .B1(n435), .B2(n877), 
        .Y(s_mem_d[257]) );
  sky130_fd_sc_hd__inv_1 U1401 ( .A(s_mem_q[256]), .Y(n878) );
  sky130_fd_sc_hd__o22ai_1 U1402 ( .A1(n879), .A2(n878), .B1(n440), .B2(n877), 
        .Y(s_mem_d[256]) );
  sky130_fd_sc_hd__inv_1 U1403 ( .A(s_wr_ptr_q[5]), .Y(n1247) );
  sky130_fd_sc_hd__nand2_1 U1404 ( .A(n880), .B(n1247), .Y(n881) );
  sky130_fd_sc_hd__nand2_1 U1405 ( .A(n882), .B(n427), .Y(n883) );
  sky130_fd_sc_hd__inv_1 U1406 ( .A(s_mem_q[255]), .Y(n884) );
  sky130_fd_sc_hd__o22ai_1 U1407 ( .A1(n892), .A2(n884), .B1(n430), .B2(n890), 
        .Y(s_mem_d[255]) );
  sky130_fd_sc_hd__inv_1 U1408 ( .A(s_mem_q[254]), .Y(n885) );
  sky130_fd_sc_hd__o22ai_1 U1409 ( .A1(n892), .A2(n885), .B1(n366), .B2(n890), 
        .Y(s_mem_d[254]) );
  sky130_fd_sc_hd__inv_1 U1410 ( .A(s_mem_q[253]), .Y(n886) );
  sky130_fd_sc_hd__o22ai_1 U1411 ( .A1(n892), .A2(n886), .B1(n376), .B2(n890), 
        .Y(s_mem_d[253]) );
  sky130_fd_sc_hd__inv_1 U1412 ( .A(s_mem_q[252]), .Y(n887) );
  sky130_fd_sc_hd__o22ai_1 U1413 ( .A1(n892), .A2(n887), .B1(n386), .B2(n890), 
        .Y(s_mem_d[252]) );
  sky130_fd_sc_hd__inv_1 U1414 ( .A(s_mem_q[251]), .Y(n888) );
  sky130_fd_sc_hd__o22ai_1 U1415 ( .A1(n892), .A2(n888), .B1(n396), .B2(n890), 
        .Y(s_mem_d[251]) );
  sky130_fd_sc_hd__inv_1 U1416 ( .A(s_mem_q[250]), .Y(n889) );
  sky130_fd_sc_hd__o22ai_1 U1417 ( .A1(n892), .A2(n889), .B1(n406), .B2(n890), 
        .Y(s_mem_d[250]) );
  sky130_fd_sc_hd__o22ai_1 U1418 ( .A1(n892), .A2(net23916), .B1(n435), .B2(
        n890), .Y(s_mem_d[249]) );
  sky130_fd_sc_hd__inv_1 U1419 ( .A(s_mem_q[248]), .Y(n891) );
  sky130_fd_sc_hd__o22ai_1 U1420 ( .A1(n892), .A2(n891), .B1(n440), .B2(n890), 
        .Y(s_mem_d[248]) );
  sky130_fd_sc_hd__nand2_1 U1421 ( .A(n893), .B(n426), .Y(n894) );
  sky130_fd_sc_hd__inv_1 U1422 ( .A(s_mem_q[247]), .Y(n895) );
  sky130_fd_sc_hd__o22ai_1 U1423 ( .A1(n903), .A2(n895), .B1(n430), .B2(n901), 
        .Y(s_mem_d[247]) );
  sky130_fd_sc_hd__inv_1 U1424 ( .A(s_mem_q[246]), .Y(n896) );
  sky130_fd_sc_hd__o22ai_1 U1425 ( .A1(n903), .A2(n896), .B1(n369), .B2(n901), 
        .Y(s_mem_d[246]) );
  sky130_fd_sc_hd__inv_1 U1426 ( .A(s_mem_q[245]), .Y(n897) );
  sky130_fd_sc_hd__o22ai_1 U1427 ( .A1(n903), .A2(n897), .B1(n379), .B2(n901), 
        .Y(s_mem_d[245]) );
  sky130_fd_sc_hd__inv_1 U1428 ( .A(s_mem_q[244]), .Y(n898) );
  sky130_fd_sc_hd__o22ai_1 U1429 ( .A1(n903), .A2(n898), .B1(n389), .B2(n901), 
        .Y(s_mem_d[244]) );
  sky130_fd_sc_hd__inv_1 U1430 ( .A(s_mem_q[243]), .Y(n899) );
  sky130_fd_sc_hd__o22ai_1 U1431 ( .A1(n903), .A2(n899), .B1(n399), .B2(n901), 
        .Y(s_mem_d[243]) );
  sky130_fd_sc_hd__inv_1 U1432 ( .A(s_mem_q[242]), .Y(n900) );
  sky130_fd_sc_hd__o22ai_1 U1433 ( .A1(n903), .A2(n900), .B1(n409), .B2(n901), 
        .Y(s_mem_d[242]) );
  sky130_fd_sc_hd__o22ai_1 U1434 ( .A1(n903), .A2(net23904), .B1(n435), .B2(
        n901), .Y(s_mem_d[241]) );
  sky130_fd_sc_hd__inv_1 U1435 ( .A(s_mem_q[240]), .Y(n902) );
  sky130_fd_sc_hd__o22ai_1 U1436 ( .A1(n903), .A2(n902), .B1(n440), .B2(n901), 
        .Y(s_mem_d[240]) );
  sky130_fd_sc_hd__nand2_1 U1437 ( .A(n904), .B(n427), .Y(n905) );
  sky130_fd_sc_hd__inv_1 U1438 ( .A(s_mem_q[239]), .Y(n906) );
  sky130_fd_sc_hd__o22ai_1 U1439 ( .A1(n914), .A2(n906), .B1(n430), .B2(n912), 
        .Y(s_mem_d[239]) );
  sky130_fd_sc_hd__inv_1 U1440 ( .A(s_mem_q[238]), .Y(n907) );
  sky130_fd_sc_hd__o22ai_1 U1441 ( .A1(n914), .A2(n907), .B1(n369), .B2(n912), 
        .Y(s_mem_d[238]) );
  sky130_fd_sc_hd__inv_1 U1442 ( .A(s_mem_q[237]), .Y(n908) );
  sky130_fd_sc_hd__o22ai_1 U1443 ( .A1(n914), .A2(n908), .B1(n379), .B2(n912), 
        .Y(s_mem_d[237]) );
  sky130_fd_sc_hd__inv_1 U1444 ( .A(s_mem_q[236]), .Y(n909) );
  sky130_fd_sc_hd__o22ai_1 U1445 ( .A1(n914), .A2(n909), .B1(n389), .B2(n912), 
        .Y(s_mem_d[236]) );
  sky130_fd_sc_hd__inv_1 U1446 ( .A(s_mem_q[235]), .Y(n910) );
  sky130_fd_sc_hd__o22ai_1 U1447 ( .A1(n914), .A2(n910), .B1(n399), .B2(n912), 
        .Y(s_mem_d[235]) );
  sky130_fd_sc_hd__inv_1 U1448 ( .A(s_mem_q[234]), .Y(n911) );
  sky130_fd_sc_hd__o22ai_1 U1449 ( .A1(n914), .A2(n911), .B1(n409), .B2(n912), 
        .Y(s_mem_d[234]) );
  sky130_fd_sc_hd__inv_1 U1450 ( .A(s_mem_q[233]), .Y(net23892) );
  sky130_fd_sc_hd__o22ai_1 U1451 ( .A1(n914), .A2(net23892), .B1(n435), .B2(
        n912), .Y(s_mem_d[233]) );
  sky130_fd_sc_hd__inv_1 U1452 ( .A(s_mem_q[232]), .Y(n913) );
  sky130_fd_sc_hd__o22ai_1 U1453 ( .A1(n914), .A2(n913), .B1(n440), .B2(n912), 
        .Y(s_mem_d[232]) );
  sky130_fd_sc_hd__nand2_1 U1454 ( .A(n915), .B(n425), .Y(n916) );
  sky130_fd_sc_hd__inv_1 U1455 ( .A(s_mem_q[231]), .Y(n917) );
  sky130_fd_sc_hd__o22ai_1 U1456 ( .A1(n925), .A2(n917), .B1(n430), .B2(n923), 
        .Y(s_mem_d[231]) );
  sky130_fd_sc_hd__inv_1 U1457 ( .A(s_mem_q[230]), .Y(n918) );
  sky130_fd_sc_hd__o22ai_1 U1458 ( .A1(n925), .A2(n918), .B1(n370), .B2(n923), 
        .Y(s_mem_d[230]) );
  sky130_fd_sc_hd__inv_1 U1459 ( .A(s_mem_q[229]), .Y(n919) );
  sky130_fd_sc_hd__o22ai_1 U1460 ( .A1(n925), .A2(n919), .B1(n380), .B2(n923), 
        .Y(s_mem_d[229]) );
  sky130_fd_sc_hd__inv_1 U1461 ( .A(s_mem_q[228]), .Y(n920) );
  sky130_fd_sc_hd__o22ai_1 U1462 ( .A1(n925), .A2(n920), .B1(n390), .B2(n923), 
        .Y(s_mem_d[228]) );
  sky130_fd_sc_hd__inv_1 U1463 ( .A(s_mem_q[227]), .Y(n921) );
  sky130_fd_sc_hd__o22ai_1 U1464 ( .A1(n925), .A2(n921), .B1(n400), .B2(n923), 
        .Y(s_mem_d[227]) );
  sky130_fd_sc_hd__inv_1 U1465 ( .A(s_mem_q[226]), .Y(n922) );
  sky130_fd_sc_hd__o22ai_1 U1466 ( .A1(n925), .A2(n922), .B1(n410), .B2(n923), 
        .Y(s_mem_d[226]) );
  sky130_fd_sc_hd__inv_1 U1467 ( .A(s_mem_q[225]), .Y(net23880) );
  sky130_fd_sc_hd__o22ai_1 U1468 ( .A1(n925), .A2(net23880), .B1(n435), .B2(
        n923), .Y(s_mem_d[225]) );
  sky130_fd_sc_hd__inv_1 U1469 ( .A(s_mem_q[224]), .Y(n924) );
  sky130_fd_sc_hd__o22ai_1 U1470 ( .A1(n925), .A2(n924), .B1(n440), .B2(n923), 
        .Y(s_mem_d[224]) );
  sky130_fd_sc_hd__nand2_1 U1471 ( .A(n926), .B(n425), .Y(n927) );
  sky130_fd_sc_hd__inv_1 U1472 ( .A(s_mem_q[223]), .Y(n928) );
  sky130_fd_sc_hd__o22ai_1 U1473 ( .A1(n936), .A2(n928), .B1(n430), .B2(n934), 
        .Y(s_mem_d[223]) );
  sky130_fd_sc_hd__inv_1 U1474 ( .A(s_mem_q[222]), .Y(n929) );
  sky130_fd_sc_hd__o22ai_1 U1475 ( .A1(n936), .A2(n929), .B1(n367), .B2(n934), 
        .Y(s_mem_d[222]) );
  sky130_fd_sc_hd__inv_1 U1476 ( .A(s_mem_q[221]), .Y(n930) );
  sky130_fd_sc_hd__o22ai_1 U1477 ( .A1(n936), .A2(n930), .B1(n377), .B2(n934), 
        .Y(s_mem_d[221]) );
  sky130_fd_sc_hd__inv_1 U1478 ( .A(s_mem_q[220]), .Y(n931) );
  sky130_fd_sc_hd__o22ai_1 U1479 ( .A1(n936), .A2(n931), .B1(n387), .B2(n934), 
        .Y(s_mem_d[220]) );
  sky130_fd_sc_hd__inv_1 U1480 ( .A(s_mem_q[219]), .Y(n932) );
  sky130_fd_sc_hd__o22ai_1 U1481 ( .A1(n936), .A2(n932), .B1(n397), .B2(n934), 
        .Y(s_mem_d[219]) );
  sky130_fd_sc_hd__inv_1 U1482 ( .A(s_mem_q[218]), .Y(n933) );
  sky130_fd_sc_hd__o22ai_1 U1483 ( .A1(n936), .A2(n933), .B1(n407), .B2(n934), 
        .Y(s_mem_d[218]) );
  sky130_fd_sc_hd__inv_1 U1484 ( .A(s_mem_q[217]), .Y(net23868) );
  sky130_fd_sc_hd__o22ai_1 U1485 ( .A1(n936), .A2(net23868), .B1(n435), .B2(
        n934), .Y(s_mem_d[217]) );
  sky130_fd_sc_hd__inv_1 U1486 ( .A(s_mem_q[216]), .Y(n935) );
  sky130_fd_sc_hd__o22ai_1 U1487 ( .A1(n936), .A2(n935), .B1(n440), .B2(n934), 
        .Y(s_mem_d[216]) );
  sky130_fd_sc_hd__nand2_1 U1488 ( .A(n937), .B(n424), .Y(n938) );
  sky130_fd_sc_hd__inv_1 U1489 ( .A(s_mem_q[215]), .Y(n939) );
  sky130_fd_sc_hd__o22ai_1 U1490 ( .A1(n947), .A2(n939), .B1(n430), .B2(n945), 
        .Y(s_mem_d[215]) );
  sky130_fd_sc_hd__inv_1 U1491 ( .A(s_mem_q[214]), .Y(n940) );
  sky130_fd_sc_hd__o22ai_1 U1492 ( .A1(n947), .A2(n940), .B1(n367), .B2(n945), 
        .Y(s_mem_d[214]) );
  sky130_fd_sc_hd__inv_1 U1493 ( .A(s_mem_q[213]), .Y(n941) );
  sky130_fd_sc_hd__o22ai_1 U1494 ( .A1(n947), .A2(n941), .B1(n377), .B2(n945), 
        .Y(s_mem_d[213]) );
  sky130_fd_sc_hd__inv_1 U1495 ( .A(s_mem_q[212]), .Y(n942) );
  sky130_fd_sc_hd__o22ai_1 U1496 ( .A1(n947), .A2(n942), .B1(n387), .B2(n945), 
        .Y(s_mem_d[212]) );
  sky130_fd_sc_hd__inv_1 U1497 ( .A(s_mem_q[211]), .Y(n943) );
  sky130_fd_sc_hd__o22ai_1 U1498 ( .A1(n947), .A2(n943), .B1(n397), .B2(n945), 
        .Y(s_mem_d[211]) );
  sky130_fd_sc_hd__inv_1 U1499 ( .A(s_mem_q[210]), .Y(n944) );
  sky130_fd_sc_hd__o22ai_1 U1500 ( .A1(n947), .A2(n944), .B1(n407), .B2(n945), 
        .Y(s_mem_d[210]) );
  sky130_fd_sc_hd__inv_1 U1501 ( .A(s_mem_q[209]), .Y(net23856) );
  sky130_fd_sc_hd__o22ai_1 U1502 ( .A1(n947), .A2(net23856), .B1(n435), .B2(
        n945), .Y(s_mem_d[209]) );
  sky130_fd_sc_hd__inv_1 U1503 ( .A(s_mem_q[208]), .Y(n946) );
  sky130_fd_sc_hd__o22ai_1 U1504 ( .A1(n947), .A2(n946), .B1(n440), .B2(n945), 
        .Y(s_mem_d[208]) );
  sky130_fd_sc_hd__nand2_1 U1505 ( .A(n948), .B(n426), .Y(n949) );
  sky130_fd_sc_hd__inv_1 U1506 ( .A(s_mem_q[207]), .Y(n950) );
  sky130_fd_sc_hd__o22ai_1 U1507 ( .A1(n959), .A2(n950), .B1(n430), .B2(n957), 
        .Y(s_mem_d[207]) );
  sky130_fd_sc_hd__inv_1 U1508 ( .A(s_mem_q[206]), .Y(n951) );
  sky130_fd_sc_hd__o22ai_1 U1509 ( .A1(n959), .A2(n951), .B1(n366), .B2(n957), 
        .Y(s_mem_d[206]) );
  sky130_fd_sc_hd__inv_1 U1510 ( .A(s_mem_q[205]), .Y(n952) );
  sky130_fd_sc_hd__o22ai_1 U1511 ( .A1(n959), .A2(n952), .B1(n376), .B2(n957), 
        .Y(s_mem_d[205]) );
  sky130_fd_sc_hd__inv_1 U1512 ( .A(s_mem_q[204]), .Y(n953) );
  sky130_fd_sc_hd__o22ai_1 U1513 ( .A1(n959), .A2(n953), .B1(n386), .B2(n957), 
        .Y(s_mem_d[204]) );
  sky130_fd_sc_hd__inv_1 U1514 ( .A(s_mem_q[203]), .Y(n954) );
  sky130_fd_sc_hd__o22ai_1 U1515 ( .A1(n959), .A2(n954), .B1(n396), .B2(n957), 
        .Y(s_mem_d[203]) );
  sky130_fd_sc_hd__inv_1 U1516 ( .A(s_mem_q[202]), .Y(n955) );
  sky130_fd_sc_hd__o22ai_1 U1517 ( .A1(n959), .A2(n955), .B1(n406), .B2(n957), 
        .Y(s_mem_d[202]) );
  sky130_fd_sc_hd__inv_1 U1518 ( .A(s_mem_q[201]), .Y(n956) );
  sky130_fd_sc_hd__o22ai_1 U1519 ( .A1(n959), .A2(n956), .B1(n435), .B2(n957), 
        .Y(s_mem_d[201]) );
  sky130_fd_sc_hd__inv_1 U1520 ( .A(s_mem_q[200]), .Y(n958) );
  sky130_fd_sc_hd__o22ai_1 U1521 ( .A1(n959), .A2(n958), .B1(n440), .B2(n957), 
        .Y(s_mem_d[200]) );
  sky130_fd_sc_hd__nand2_1 U1522 ( .A(n961), .B(n424), .Y(n962) );
  sky130_fd_sc_hd__inv_1 U1523 ( .A(s_mem_q[199]), .Y(n963) );
  sky130_fd_sc_hd__o22ai_1 U1524 ( .A1(n972), .A2(n963), .B1(n431), .B2(n970), 
        .Y(s_mem_d[199]) );
  sky130_fd_sc_hd__inv_1 U1525 ( .A(s_mem_q[198]), .Y(n964) );
  sky130_fd_sc_hd__o22ai_1 U1526 ( .A1(n972), .A2(n964), .B1(n365), .B2(n970), 
        .Y(s_mem_d[198]) );
  sky130_fd_sc_hd__inv_1 U1527 ( .A(s_mem_q[197]), .Y(n965) );
  sky130_fd_sc_hd__o22ai_1 U1528 ( .A1(n972), .A2(n965), .B1(n375), .B2(n970), 
        .Y(s_mem_d[197]) );
  sky130_fd_sc_hd__inv_1 U1529 ( .A(s_mem_q[196]), .Y(n966) );
  sky130_fd_sc_hd__o22ai_1 U1530 ( .A1(n972), .A2(n966), .B1(n385), .B2(n970), 
        .Y(s_mem_d[196]) );
  sky130_fd_sc_hd__inv_1 U1531 ( .A(s_mem_q[195]), .Y(n967) );
  sky130_fd_sc_hd__o22ai_1 U1532 ( .A1(n972), .A2(n967), .B1(n395), .B2(n970), 
        .Y(s_mem_d[195]) );
  sky130_fd_sc_hd__inv_1 U1533 ( .A(s_mem_q[194]), .Y(n968) );
  sky130_fd_sc_hd__o22ai_1 U1534 ( .A1(n972), .A2(n968), .B1(n405), .B2(n970), 
        .Y(s_mem_d[194]) );
  sky130_fd_sc_hd__inv_1 U1535 ( .A(s_mem_q[193]), .Y(n969) );
  sky130_fd_sc_hd__o22ai_1 U1536 ( .A1(n972), .A2(n969), .B1(n435), .B2(n970), 
        .Y(s_mem_d[193]) );
  sky130_fd_sc_hd__inv_1 U1537 ( .A(s_mem_q[192]), .Y(n971) );
  sky130_fd_sc_hd__o22ai_1 U1538 ( .A1(n972), .A2(n971), .B1(n440), .B2(n970), 
        .Y(s_mem_d[192]) );
  sky130_fd_sc_hd__nand3_1 U1539 ( .A(s_wr_ptr_q[4]), .B(n1247), .C(n1249), 
        .Y(n973) );
  sky130_fd_sc_hd__clkinv_2 U1540 ( .A(n973), .Y(n1050) );
  sky130_fd_sc_hd__nand2_1 U1541 ( .A(n974), .B(n426), .Y(n975) );
  sky130_fd_sc_hd__inv_1 U1542 ( .A(s_mem_q[191]), .Y(n976) );
  sky130_fd_sc_hd__o22ai_1 U1543 ( .A1(n984), .A2(n976), .B1(n431), .B2(n982), 
        .Y(s_mem_d[191]) );
  sky130_fd_sc_hd__inv_1 U1544 ( .A(s_mem_q[190]), .Y(n977) );
  sky130_fd_sc_hd__o22ai_1 U1545 ( .A1(n984), .A2(n977), .B1(n367), .B2(n982), 
        .Y(s_mem_d[190]) );
  sky130_fd_sc_hd__inv_1 U1546 ( .A(s_mem_q[189]), .Y(n978) );
  sky130_fd_sc_hd__o22ai_1 U1547 ( .A1(n984), .A2(n978), .B1(n377), .B2(n982), 
        .Y(s_mem_d[189]) );
  sky130_fd_sc_hd__inv_1 U1548 ( .A(s_mem_q[188]), .Y(n979) );
  sky130_fd_sc_hd__o22ai_1 U1549 ( .A1(n984), .A2(n979), .B1(n387), .B2(n982), 
        .Y(s_mem_d[188]) );
  sky130_fd_sc_hd__inv_1 U1550 ( .A(s_mem_q[187]), .Y(n980) );
  sky130_fd_sc_hd__o22ai_1 U1551 ( .A1(n984), .A2(n980), .B1(n397), .B2(n982), 
        .Y(s_mem_d[187]) );
  sky130_fd_sc_hd__inv_1 U1552 ( .A(s_mem_q[186]), .Y(n981) );
  sky130_fd_sc_hd__o22ai_1 U1553 ( .A1(n984), .A2(n981), .B1(n407), .B2(n982), 
        .Y(s_mem_d[186]) );
  sky130_fd_sc_hd__inv_1 U1554 ( .A(s_mem_q[185]), .Y(net23818) );
  sky130_fd_sc_hd__o22ai_1 U1555 ( .A1(n984), .A2(net23818), .B1(n436), .B2(
        n982), .Y(s_mem_d[185]) );
  sky130_fd_sc_hd__inv_1 U1556 ( .A(s_mem_q[184]), .Y(n983) );
  sky130_fd_sc_hd__o22ai_1 U1557 ( .A1(n984), .A2(n983), .B1(n441), .B2(n982), 
        .Y(s_mem_d[184]) );
  sky130_fd_sc_hd__nand2_1 U1558 ( .A(n985), .B(n34), .Y(n986) );
  sky130_fd_sc_hd__inv_1 U1559 ( .A(s_mem_q[183]), .Y(n987) );
  sky130_fd_sc_hd__o22ai_1 U1560 ( .A1(n995), .A2(n987), .B1(n431), .B2(n993), 
        .Y(s_mem_d[183]) );
  sky130_fd_sc_hd__inv_1 U1561 ( .A(s_mem_q[182]), .Y(n988) );
  sky130_fd_sc_hd__o22ai_1 U1562 ( .A1(n995), .A2(n988), .B1(n372), .B2(n993), 
        .Y(s_mem_d[182]) );
  sky130_fd_sc_hd__inv_1 U1563 ( .A(s_mem_q[181]), .Y(n989) );
  sky130_fd_sc_hd__o22ai_1 U1564 ( .A1(n995), .A2(n989), .B1(n382), .B2(n993), 
        .Y(s_mem_d[181]) );
  sky130_fd_sc_hd__inv_1 U1565 ( .A(s_mem_q[180]), .Y(n990) );
  sky130_fd_sc_hd__o22ai_1 U1566 ( .A1(n995), .A2(n990), .B1(n392), .B2(n993), 
        .Y(s_mem_d[180]) );
  sky130_fd_sc_hd__inv_1 U1567 ( .A(s_mem_q[179]), .Y(n991) );
  sky130_fd_sc_hd__o22ai_1 U1568 ( .A1(n995), .A2(n991), .B1(n402), .B2(n993), 
        .Y(s_mem_d[179]) );
  sky130_fd_sc_hd__inv_1 U1569 ( .A(s_mem_q[178]), .Y(n992) );
  sky130_fd_sc_hd__o22ai_1 U1570 ( .A1(n995), .A2(n992), .B1(n412), .B2(n993), 
        .Y(s_mem_d[178]) );
  sky130_fd_sc_hd__inv_1 U1571 ( .A(s_mem_q[177]), .Y(net23806) );
  sky130_fd_sc_hd__o22ai_1 U1572 ( .A1(n995), .A2(net23806), .B1(n436), .B2(
        n993), .Y(s_mem_d[177]) );
  sky130_fd_sc_hd__inv_1 U1573 ( .A(s_mem_q[176]), .Y(n994) );
  sky130_fd_sc_hd__o22ai_1 U1574 ( .A1(n995), .A2(n994), .B1(n441), .B2(n993), 
        .Y(s_mem_d[176]) );
  sky130_fd_sc_hd__nand2_1 U1575 ( .A(n996), .B(n427), .Y(n997) );
  sky130_fd_sc_hd__inv_1 U1576 ( .A(s_mem_q[175]), .Y(n998) );
  sky130_fd_sc_hd__o22ai_1 U1577 ( .A1(n1006), .A2(n998), .B1(n431), .B2(n1004), .Y(s_mem_d[175]) );
  sky130_fd_sc_hd__inv_1 U1578 ( .A(s_mem_q[174]), .Y(n999) );
  sky130_fd_sc_hd__o22ai_1 U1579 ( .A1(n1006), .A2(n999), .B1(n365), .B2(n1004), .Y(s_mem_d[174]) );
  sky130_fd_sc_hd__inv_1 U1580 ( .A(s_mem_q[173]), .Y(n1000) );
  sky130_fd_sc_hd__o22ai_1 U1581 ( .A1(n1006), .A2(n1000), .B1(n375), .B2(
        n1004), .Y(s_mem_d[173]) );
  sky130_fd_sc_hd__inv_1 U1582 ( .A(s_mem_q[172]), .Y(n1001) );
  sky130_fd_sc_hd__o22ai_1 U1583 ( .A1(n1006), .A2(n1001), .B1(n385), .B2(
        n1004), .Y(s_mem_d[172]) );
  sky130_fd_sc_hd__inv_1 U1584 ( .A(s_mem_q[171]), .Y(n1002) );
  sky130_fd_sc_hd__o22ai_1 U1585 ( .A1(n1006), .A2(n1002), .B1(n395), .B2(
        n1004), .Y(s_mem_d[171]) );
  sky130_fd_sc_hd__inv_1 U1586 ( .A(s_mem_q[170]), .Y(n1003) );
  sky130_fd_sc_hd__o22ai_1 U1587 ( .A1(n1006), .A2(n1003), .B1(n405), .B2(
        n1004), .Y(s_mem_d[170]) );
  sky130_fd_sc_hd__inv_1 U1588 ( .A(s_mem_q[169]), .Y(net23794) );
  sky130_fd_sc_hd__o22ai_1 U1589 ( .A1(n1006), .A2(net23794), .B1(n436), .B2(
        n1004), .Y(s_mem_d[169]) );
  sky130_fd_sc_hd__inv_1 U1590 ( .A(s_mem_q[168]), .Y(n1005) );
  sky130_fd_sc_hd__o22ai_1 U1591 ( .A1(n1006), .A2(n1005), .B1(n441), .B2(
        n1004), .Y(s_mem_d[168]) );
  sky130_fd_sc_hd__nand2_1 U1592 ( .A(n1007), .B(n426), .Y(n1008) );
  sky130_fd_sc_hd__inv_1 U1593 ( .A(s_mem_q[167]), .Y(n1009) );
  sky130_fd_sc_hd__o22ai_1 U1594 ( .A1(n1017), .A2(n1009), .B1(n431), .B2(
        n1015), .Y(s_mem_d[167]) );
  sky130_fd_sc_hd__inv_1 U1595 ( .A(s_mem_q[166]), .Y(n1010) );
  sky130_fd_sc_hd__o22ai_1 U1596 ( .A1(n1017), .A2(n1010), .B1(n365), .B2(
        n1015), .Y(s_mem_d[166]) );
  sky130_fd_sc_hd__inv_1 U1597 ( .A(s_mem_q[165]), .Y(n1011) );
  sky130_fd_sc_hd__o22ai_1 U1598 ( .A1(n1017), .A2(n1011), .B1(n375), .B2(
        n1015), .Y(s_mem_d[165]) );
  sky130_fd_sc_hd__inv_1 U1599 ( .A(s_mem_q[164]), .Y(n1012) );
  sky130_fd_sc_hd__o22ai_1 U1600 ( .A1(n1017), .A2(n1012), .B1(n385), .B2(
        n1015), .Y(s_mem_d[164]) );
  sky130_fd_sc_hd__inv_1 U1601 ( .A(s_mem_q[163]), .Y(n1013) );
  sky130_fd_sc_hd__o22ai_1 U1602 ( .A1(n1017), .A2(n1013), .B1(n395), .B2(
        n1015), .Y(s_mem_d[163]) );
  sky130_fd_sc_hd__inv_1 U1603 ( .A(s_mem_q[162]), .Y(n1014) );
  sky130_fd_sc_hd__o22ai_1 U1604 ( .A1(n1017), .A2(n1014), .B1(n405), .B2(
        n1015), .Y(s_mem_d[162]) );
  sky130_fd_sc_hd__inv_1 U1605 ( .A(s_mem_q[161]), .Y(net23782) );
  sky130_fd_sc_hd__o22ai_1 U1606 ( .A1(n1017), .A2(net23782), .B1(n436), .B2(
        n1015), .Y(s_mem_d[161]) );
  sky130_fd_sc_hd__inv_1 U1607 ( .A(s_mem_q[160]), .Y(n1016) );
  sky130_fd_sc_hd__o22ai_1 U1608 ( .A1(n1017), .A2(n1016), .B1(n441), .B2(
        n1015), .Y(s_mem_d[160]) );
  sky130_fd_sc_hd__nand2_1 U1609 ( .A(n1018), .B(n423), .Y(n1019) );
  sky130_fd_sc_hd__inv_1 U1610 ( .A(s_mem_q[159]), .Y(n1020) );
  sky130_fd_sc_hd__o22ai_1 U1611 ( .A1(n1027), .A2(n1020), .B1(n431), .B2(
        n1025), .Y(s_mem_d[159]) );
  sky130_fd_sc_hd__inv_1 U1612 ( .A(s_mem_q[158]), .Y(n1021) );
  sky130_fd_sc_hd__o22ai_1 U1613 ( .A1(n1027), .A2(n1021), .B1(n369), .B2(
        n1025), .Y(s_mem_d[158]) );
  sky130_fd_sc_hd__inv_1 U1614 ( .A(s_mem_q[157]), .Y(n1022) );
  sky130_fd_sc_hd__o22ai_1 U1615 ( .A1(n1027), .A2(n1022), .B1(n379), .B2(
        n1025), .Y(s_mem_d[157]) );
  sky130_fd_sc_hd__inv_1 U1616 ( .A(s_mem_q[156]), .Y(n1023) );
  sky130_fd_sc_hd__o22ai_1 U1617 ( .A1(n1027), .A2(n1023), .B1(n389), .B2(
        n1025), .Y(s_mem_d[156]) );
  sky130_fd_sc_hd__inv_1 U1618 ( .A(s_mem_q[155]), .Y(n1024) );
  sky130_fd_sc_hd__o22ai_1 U1619 ( .A1(n1027), .A2(n1024), .B1(n399), .B2(
        n1025), .Y(s_mem_d[155]) );
  sky130_fd_sc_hd__inv_1 U1620 ( .A(s_mem_q[154]), .Y(net23771) );
  sky130_fd_sc_hd__o22ai_1 U1621 ( .A1(n1027), .A2(net23771), .B1(n409), .B2(
        n1025), .Y(s_mem_d[154]) );
  sky130_fd_sc_hd__inv_1 U1622 ( .A(s_mem_q[153]), .Y(net23770) );
  sky130_fd_sc_hd__o22ai_1 U1623 ( .A1(n1027), .A2(net23770), .B1(n436), .B2(
        n1025), .Y(s_mem_d[153]) );
  sky130_fd_sc_hd__inv_1 U1624 ( .A(s_mem_q[152]), .Y(n1026) );
  sky130_fd_sc_hd__o22ai_1 U1625 ( .A1(n1027), .A2(n1026), .B1(n441), .B2(
        n1025), .Y(s_mem_d[152]) );
  sky130_fd_sc_hd__nand2_1 U1626 ( .A(n1028), .B(n423), .Y(n1029) );
  sky130_fd_sc_hd__inv_1 U1627 ( .A(s_mem_q[151]), .Y(n1030) );
  sky130_fd_sc_hd__o22ai_1 U1628 ( .A1(n1037), .A2(n1030), .B1(n431), .B2(
        n1035), .Y(s_mem_d[151]) );
  sky130_fd_sc_hd__inv_1 U1629 ( .A(s_mem_q[150]), .Y(n1031) );
  sky130_fd_sc_hd__o22ai_1 U1630 ( .A1(n1037), .A2(n1031), .B1(n372), .B2(
        n1035), .Y(s_mem_d[150]) );
  sky130_fd_sc_hd__inv_1 U1631 ( .A(s_mem_q[149]), .Y(n1032) );
  sky130_fd_sc_hd__o22ai_1 U1632 ( .A1(n1037), .A2(n1032), .B1(n382), .B2(
        n1035), .Y(s_mem_d[149]) );
  sky130_fd_sc_hd__inv_1 U1633 ( .A(s_mem_q[148]), .Y(n1033) );
  sky130_fd_sc_hd__o22ai_1 U1634 ( .A1(n1037), .A2(n1033), .B1(n392), .B2(
        n1035), .Y(s_mem_d[148]) );
  sky130_fd_sc_hd__inv_1 U1635 ( .A(s_mem_q[147]), .Y(n1034) );
  sky130_fd_sc_hd__o22ai_1 U1636 ( .A1(n1037), .A2(n1034), .B1(n402), .B2(
        n1035), .Y(s_mem_d[147]) );
  sky130_fd_sc_hd__inv_1 U1637 ( .A(s_mem_q[146]), .Y(net23759) );
  sky130_fd_sc_hd__o22ai_1 U1638 ( .A1(n1037), .A2(net23759), .B1(n412), .B2(
        n1035), .Y(s_mem_d[146]) );
  sky130_fd_sc_hd__inv_1 U1639 ( .A(s_mem_q[145]), .Y(net23758) );
  sky130_fd_sc_hd__o22ai_1 U1640 ( .A1(n1037), .A2(net23758), .B1(n436), .B2(
        n1035), .Y(s_mem_d[145]) );
  sky130_fd_sc_hd__inv_1 U1641 ( .A(s_mem_q[144]), .Y(n1036) );
  sky130_fd_sc_hd__o22ai_1 U1642 ( .A1(n1037), .A2(n1036), .B1(n441), .B2(
        n1035), .Y(s_mem_d[144]) );
  sky130_fd_sc_hd__nand2_1 U1643 ( .A(n1038), .B(n424), .Y(n1039) );
  sky130_fd_sc_hd__inv_1 U1644 ( .A(s_mem_q[143]), .Y(n1040) );
  sky130_fd_sc_hd__o22ai_1 U1645 ( .A1(n1049), .A2(n1040), .B1(n431), .B2(
        n1047), .Y(s_mem_d[143]) );
  sky130_fd_sc_hd__inv_1 U1646 ( .A(s_mem_q[142]), .Y(n1041) );
  sky130_fd_sc_hd__o22ai_1 U1647 ( .A1(n1049), .A2(n1041), .B1(n371), .B2(
        n1047), .Y(s_mem_d[142]) );
  sky130_fd_sc_hd__inv_1 U1648 ( .A(s_mem_q[141]), .Y(n1042) );
  sky130_fd_sc_hd__o22ai_1 U1649 ( .A1(n1049), .A2(n1042), .B1(n381), .B2(
        n1047), .Y(s_mem_d[141]) );
  sky130_fd_sc_hd__inv_1 U1650 ( .A(s_mem_q[140]), .Y(n1043) );
  sky130_fd_sc_hd__o22ai_1 U1651 ( .A1(n1049), .A2(n1043), .B1(n391), .B2(
        n1047), .Y(s_mem_d[140]) );
  sky130_fd_sc_hd__inv_1 U1652 ( .A(s_mem_q[139]), .Y(n1044) );
  sky130_fd_sc_hd__o22ai_1 U1653 ( .A1(n1049), .A2(n1044), .B1(n401), .B2(
        n1047), .Y(s_mem_d[139]) );
  sky130_fd_sc_hd__inv_1 U1654 ( .A(s_mem_q[138]), .Y(n1045) );
  sky130_fd_sc_hd__o22ai_1 U1655 ( .A1(n1049), .A2(n1045), .B1(n411), .B2(
        n1047), .Y(s_mem_d[138]) );
  sky130_fd_sc_hd__inv_1 U1656 ( .A(s_mem_q[137]), .Y(n1046) );
  sky130_fd_sc_hd__o22ai_1 U1657 ( .A1(n1049), .A2(n1046), .B1(n436), .B2(
        n1047), .Y(s_mem_d[137]) );
  sky130_fd_sc_hd__inv_1 U1658 ( .A(s_mem_q[136]), .Y(n1048) );
  sky130_fd_sc_hd__o22ai_1 U1659 ( .A1(n1049), .A2(n1048), .B1(n441), .B2(
        n1047), .Y(s_mem_d[136]) );
  sky130_fd_sc_hd__nand2_1 U1660 ( .A(n1051), .B(n425), .Y(n1052) );
  sky130_fd_sc_hd__inv_1 U1661 ( .A(s_mem_q[135]), .Y(n1053) );
  sky130_fd_sc_hd__o22ai_1 U1662 ( .A1(n1062), .A2(n1053), .B1(n431), .B2(
        n1060), .Y(s_mem_d[135]) );
  sky130_fd_sc_hd__inv_1 U1663 ( .A(s_mem_q[134]), .Y(n1054) );
  sky130_fd_sc_hd__o22ai_1 U1664 ( .A1(n1062), .A2(n1054), .B1(n370), .B2(
        n1060), .Y(s_mem_d[134]) );
  sky130_fd_sc_hd__inv_1 U1665 ( .A(s_mem_q[133]), .Y(n1055) );
  sky130_fd_sc_hd__o22ai_1 U1666 ( .A1(n1062), .A2(n1055), .B1(n380), .B2(
        n1060), .Y(s_mem_d[133]) );
  sky130_fd_sc_hd__inv_1 U1667 ( .A(s_mem_q[132]), .Y(n1056) );
  sky130_fd_sc_hd__o22ai_1 U1668 ( .A1(n1062), .A2(n1056), .B1(n390), .B2(
        n1060), .Y(s_mem_d[132]) );
  sky130_fd_sc_hd__inv_1 U1669 ( .A(s_mem_q[131]), .Y(n1057) );
  sky130_fd_sc_hd__o22ai_1 U1670 ( .A1(n1062), .A2(n1057), .B1(n400), .B2(
        n1060), .Y(s_mem_d[131]) );
  sky130_fd_sc_hd__inv_1 U1671 ( .A(s_mem_q[130]), .Y(n1058) );
  sky130_fd_sc_hd__o22ai_1 U1672 ( .A1(n1062), .A2(n1058), .B1(n410), .B2(
        n1060), .Y(s_mem_d[130]) );
  sky130_fd_sc_hd__inv_1 U1673 ( .A(s_mem_q[129]), .Y(n1059) );
  sky130_fd_sc_hd__o22ai_1 U1674 ( .A1(n1062), .A2(n1059), .B1(n436), .B2(
        n1060), .Y(s_mem_d[129]) );
  sky130_fd_sc_hd__inv_1 U1675 ( .A(s_mem_q[128]), .Y(n1061) );
  sky130_fd_sc_hd__o22ai_1 U1676 ( .A1(n1062), .A2(n1061), .B1(n441), .B2(
        n1060), .Y(s_mem_d[128]) );
  sky130_fd_sc_hd__nand3_1 U1677 ( .A(s_wr_ptr_q[3]), .B(n1247), .C(n1248), 
        .Y(n1063) );
  sky130_fd_sc_hd__clkinv_2 U1678 ( .A(n1063), .Y(n1134) );
  sky130_fd_sc_hd__nand2_1 U1679 ( .A(n1064), .B(n425), .Y(n1065) );
  sky130_fd_sc_hd__inv_1 U1680 ( .A(s_mem_q[127]), .Y(n1066) );
  sky130_fd_sc_hd__o22ai_1 U1681 ( .A1(n1073), .A2(n1066), .B1(n431), .B2(
        n1071), .Y(s_mem_d[127]) );
  sky130_fd_sc_hd__inv_1 U1682 ( .A(s_mem_q[126]), .Y(n1067) );
  sky130_fd_sc_hd__o22ai_1 U1683 ( .A1(n1073), .A2(n1067), .B1(n370), .B2(
        n1071), .Y(s_mem_d[126]) );
  sky130_fd_sc_hd__inv_1 U1684 ( .A(s_mem_q[125]), .Y(n1068) );
  sky130_fd_sc_hd__o22ai_1 U1685 ( .A1(n1073), .A2(n1068), .B1(n380), .B2(
        n1071), .Y(s_mem_d[125]) );
  sky130_fd_sc_hd__inv_1 U1686 ( .A(s_mem_q[124]), .Y(n1069) );
  sky130_fd_sc_hd__o22ai_1 U1687 ( .A1(n1073), .A2(n1069), .B1(n390), .B2(
        n1071), .Y(s_mem_d[124]) );
  sky130_fd_sc_hd__inv_1 U1688 ( .A(s_mem_q[123]), .Y(n1070) );
  sky130_fd_sc_hd__o22ai_1 U1689 ( .A1(n1073), .A2(n1070), .B1(n400), .B2(
        n1071), .Y(s_mem_d[123]) );
  sky130_fd_sc_hd__inv_1 U1690 ( .A(s_mem_q[122]), .Y(net23721) );
  sky130_fd_sc_hd__o22ai_1 U1691 ( .A1(n1073), .A2(net23721), .B1(n410), .B2(
        n1071), .Y(s_mem_d[122]) );
  sky130_fd_sc_hd__inv_1 U1692 ( .A(s_mem_q[121]), .Y(net23720) );
  sky130_fd_sc_hd__o22ai_1 U1693 ( .A1(n1073), .A2(net23720), .B1(n436), .B2(
        n1071), .Y(s_mem_d[121]) );
  sky130_fd_sc_hd__inv_1 U1694 ( .A(s_mem_q[120]), .Y(n1072) );
  sky130_fd_sc_hd__o22ai_1 U1695 ( .A1(n1073), .A2(n1072), .B1(n441), .B2(
        n1071), .Y(s_mem_d[120]) );
  sky130_fd_sc_hd__nand2_1 U1696 ( .A(n1074), .B(n427), .Y(n1075) );
  sky130_fd_sc_hd__inv_1 U1697 ( .A(s_mem_q[119]), .Y(n1076) );
  sky130_fd_sc_hd__o22ai_1 U1698 ( .A1(n1083), .A2(n1076), .B1(n431), .B2(
        n1081), .Y(s_mem_d[119]) );
  sky130_fd_sc_hd__inv_1 U1699 ( .A(s_mem_q[118]), .Y(n1077) );
  sky130_fd_sc_hd__o22ai_1 U1700 ( .A1(n1083), .A2(n1077), .B1(n369), .B2(
        n1081), .Y(s_mem_d[118]) );
  sky130_fd_sc_hd__inv_1 U1701 ( .A(s_mem_q[117]), .Y(n1078) );
  sky130_fd_sc_hd__o22ai_1 U1702 ( .A1(n1083), .A2(n1078), .B1(n379), .B2(
        n1081), .Y(s_mem_d[117]) );
  sky130_fd_sc_hd__inv_1 U1703 ( .A(s_mem_q[116]), .Y(n1079) );
  sky130_fd_sc_hd__o22ai_1 U1704 ( .A1(n1083), .A2(n1079), .B1(n389), .B2(
        n1081), .Y(s_mem_d[116]) );
  sky130_fd_sc_hd__inv_1 U1705 ( .A(s_mem_q[115]), .Y(n1080) );
  sky130_fd_sc_hd__o22ai_1 U1706 ( .A1(n1083), .A2(n1080), .B1(n399), .B2(
        n1081), .Y(s_mem_d[115]) );
  sky130_fd_sc_hd__inv_1 U1707 ( .A(s_mem_q[114]), .Y(net23709) );
  sky130_fd_sc_hd__o22ai_1 U1708 ( .A1(n1083), .A2(net23709), .B1(n409), .B2(
        n1081), .Y(s_mem_d[114]) );
  sky130_fd_sc_hd__inv_1 U1709 ( .A(s_mem_q[113]), .Y(net23708) );
  sky130_fd_sc_hd__o22ai_1 U1710 ( .A1(n1083), .A2(net23708), .B1(n436), .B2(
        n1081), .Y(s_mem_d[113]) );
  sky130_fd_sc_hd__inv_1 U1711 ( .A(s_mem_q[112]), .Y(n1082) );
  sky130_fd_sc_hd__o22ai_1 U1712 ( .A1(n1083), .A2(n1082), .B1(n441), .B2(
        n1081), .Y(s_mem_d[112]) );
  sky130_fd_sc_hd__nand2_1 U1713 ( .A(n1084), .B(n427), .Y(n1085) );
  sky130_fd_sc_hd__inv_1 U1714 ( .A(s_mem_q[111]), .Y(n1086) );
  sky130_fd_sc_hd__o22ai_1 U1715 ( .A1(n1093), .A2(n1086), .B1(n431), .B2(
        n1091), .Y(s_mem_d[111]) );
  sky130_fd_sc_hd__inv_1 U1716 ( .A(s_mem_q[110]), .Y(n1087) );
  sky130_fd_sc_hd__o22ai_1 U1717 ( .A1(n1093), .A2(n1087), .B1(n370), .B2(
        n1091), .Y(s_mem_d[110]) );
  sky130_fd_sc_hd__inv_1 U1718 ( .A(s_mem_q[109]), .Y(n1088) );
  sky130_fd_sc_hd__o22ai_1 U1719 ( .A1(n1093), .A2(n1088), .B1(n380), .B2(
        n1091), .Y(s_mem_d[109]) );
  sky130_fd_sc_hd__inv_1 U1720 ( .A(s_mem_q[108]), .Y(n1089) );
  sky130_fd_sc_hd__o22ai_1 U1721 ( .A1(n1093), .A2(n1089), .B1(n390), .B2(
        n1091), .Y(s_mem_d[108]) );
  sky130_fd_sc_hd__inv_1 U1722 ( .A(s_mem_q[107]), .Y(n1090) );
  sky130_fd_sc_hd__o22ai_1 U1723 ( .A1(n1093), .A2(n1090), .B1(n400), .B2(
        n1091), .Y(s_mem_d[107]) );
  sky130_fd_sc_hd__o22ai_1 U1724 ( .A1(n1093), .A2(net23697), .B1(n410), .B2(
        n1091), .Y(s_mem_d[106]) );
  sky130_fd_sc_hd__o22ai_1 U1725 ( .A1(n1093), .A2(n17), .B1(n436), .B2(n1091), 
        .Y(s_mem_d[105]) );
  sky130_fd_sc_hd__inv_1 U1726 ( .A(s_mem_q[104]), .Y(n1092) );
  sky130_fd_sc_hd__o22ai_1 U1727 ( .A1(n1093), .A2(n1092), .B1(n441), .B2(
        n1091), .Y(s_mem_d[104]) );
  sky130_fd_sc_hd__nand2_1 U1728 ( .A(n1094), .B(n424), .Y(n1095) );
  sky130_fd_sc_hd__inv_1 U1729 ( .A(s_mem_q[103]), .Y(n1096) );
  sky130_fd_sc_hd__o22ai_1 U1730 ( .A1(n1103), .A2(n1096), .B1(n431), .B2(
        n1101), .Y(s_mem_d[103]) );
  sky130_fd_sc_hd__inv_1 U1731 ( .A(s_mem_q[102]), .Y(n1097) );
  sky130_fd_sc_hd__o22ai_1 U1732 ( .A1(n1103), .A2(n1097), .B1(n371), .B2(
        n1101), .Y(s_mem_d[102]) );
  sky130_fd_sc_hd__inv_1 U1733 ( .A(s_mem_q[101]), .Y(n1098) );
  sky130_fd_sc_hd__o22ai_1 U1734 ( .A1(n1103), .A2(n1098), .B1(n381), .B2(
        n1101), .Y(s_mem_d[101]) );
  sky130_fd_sc_hd__inv_1 U1735 ( .A(s_mem_q[100]), .Y(n1099) );
  sky130_fd_sc_hd__o22ai_1 U1736 ( .A1(n1103), .A2(n1099), .B1(n391), .B2(
        n1101), .Y(s_mem_d[100]) );
  sky130_fd_sc_hd__inv_1 U1737 ( .A(s_mem_q[99]), .Y(n1100) );
  sky130_fd_sc_hd__o22ai_1 U1738 ( .A1(n1103), .A2(n1100), .B1(n401), .B2(
        n1101), .Y(s_mem_d[99]) );
  sky130_fd_sc_hd__o22ai_1 U1739 ( .A1(n1103), .A2(net23685), .B1(n411), .B2(
        n1101), .Y(s_mem_d[98]) );
  sky130_fd_sc_hd__o22ai_1 U1740 ( .A1(n1103), .A2(n19), .B1(n436), .B2(n1101), 
        .Y(s_mem_d[97]) );
  sky130_fd_sc_hd__inv_1 U1741 ( .A(s_mem_q[96]), .Y(n1102) );
  sky130_fd_sc_hd__o22ai_1 U1742 ( .A1(n1103), .A2(n1102), .B1(n441), .B2(
        n1101), .Y(s_mem_d[96]) );
  sky130_fd_sc_hd__nand2_1 U1743 ( .A(n1104), .B(n424), .Y(n1105) );
  sky130_fd_sc_hd__inv_1 U1744 ( .A(s_mem_q[95]), .Y(n1106) );
  sky130_fd_sc_hd__o22ai_1 U1745 ( .A1(n1113), .A2(n1106), .B1(n432), .B2(
        n1111), .Y(s_mem_d[95]) );
  sky130_fd_sc_hd__inv_1 U1746 ( .A(s_mem_q[94]), .Y(n1107) );
  sky130_fd_sc_hd__o22ai_1 U1747 ( .A1(n1113), .A2(n1107), .B1(n369), .B2(
        n1111), .Y(s_mem_d[94]) );
  sky130_fd_sc_hd__inv_1 U1748 ( .A(s_mem_q[93]), .Y(n1108) );
  sky130_fd_sc_hd__o22ai_1 U1749 ( .A1(n1113), .A2(n1108), .B1(n379), .B2(
        n1111), .Y(s_mem_d[93]) );
  sky130_fd_sc_hd__inv_1 U1750 ( .A(s_mem_q[92]), .Y(n1109) );
  sky130_fd_sc_hd__o22ai_1 U1751 ( .A1(n1113), .A2(n1109), .B1(n389), .B2(
        n1111), .Y(s_mem_d[92]) );
  sky130_fd_sc_hd__inv_1 U1752 ( .A(s_mem_q[91]), .Y(n1110) );
  sky130_fd_sc_hd__o22ai_1 U1753 ( .A1(n1113), .A2(n1110), .B1(n399), .B2(
        n1111), .Y(s_mem_d[91]) );
  sky130_fd_sc_hd__inv_1 U1754 ( .A(s_mem_q[90]), .Y(net23673) );
  sky130_fd_sc_hd__o22ai_1 U1755 ( .A1(n1113), .A2(net23673), .B1(n409), .B2(
        n1111), .Y(s_mem_d[90]) );
  sky130_fd_sc_hd__inv_1 U1756 ( .A(s_mem_q[89]), .Y(net23672) );
  sky130_fd_sc_hd__o22ai_1 U1757 ( .A1(n1113), .A2(net23672), .B1(n437), .B2(
        n1111), .Y(s_mem_d[89]) );
  sky130_fd_sc_hd__inv_1 U1758 ( .A(s_mem_q[88]), .Y(n1112) );
  sky130_fd_sc_hd__o22ai_1 U1759 ( .A1(n1113), .A2(n1112), .B1(n1241), .B2(
        n1111), .Y(s_mem_d[88]) );
  sky130_fd_sc_hd__nand2_1 U1760 ( .A(n1114), .B(n425), .Y(n1115) );
  sky130_fd_sc_hd__inv_1 U1761 ( .A(s_mem_q[87]), .Y(n1116) );
  sky130_fd_sc_hd__o22ai_1 U1762 ( .A1(n1123), .A2(n1116), .B1(n432), .B2(
        n1121), .Y(s_mem_d[87]) );
  sky130_fd_sc_hd__inv_1 U1763 ( .A(s_mem_q[86]), .Y(n1117) );
  sky130_fd_sc_hd__o22ai_1 U1764 ( .A1(n1123), .A2(n1117), .B1(n372), .B2(
        n1121), .Y(s_mem_d[86]) );
  sky130_fd_sc_hd__inv_1 U1765 ( .A(s_mem_q[85]), .Y(n1118) );
  sky130_fd_sc_hd__o22ai_1 U1766 ( .A1(n1123), .A2(n1118), .B1(n382), .B2(
        n1121), .Y(s_mem_d[85]) );
  sky130_fd_sc_hd__inv_1 U1767 ( .A(s_mem_q[84]), .Y(n1119) );
  sky130_fd_sc_hd__o22ai_1 U1768 ( .A1(n1123), .A2(n1119), .B1(n392), .B2(
        n1121), .Y(s_mem_d[84]) );
  sky130_fd_sc_hd__inv_1 U1769 ( .A(s_mem_q[83]), .Y(n1120) );
  sky130_fd_sc_hd__o22ai_1 U1770 ( .A1(n1123), .A2(n1120), .B1(n402), .B2(
        n1121), .Y(s_mem_d[83]) );
  sky130_fd_sc_hd__inv_1 U1771 ( .A(s_mem_q[82]), .Y(net23661) );
  sky130_fd_sc_hd__o22ai_1 U1772 ( .A1(n1123), .A2(net23661), .B1(n412), .B2(
        n1121), .Y(s_mem_d[82]) );
  sky130_fd_sc_hd__inv_1 U1773 ( .A(s_mem_q[81]), .Y(net23660) );
  sky130_fd_sc_hd__o22ai_1 U1774 ( .A1(n1123), .A2(net23660), .B1(n436), .B2(
        n1121), .Y(s_mem_d[81]) );
  sky130_fd_sc_hd__inv_1 U1775 ( .A(s_mem_q[80]), .Y(n1122) );
  sky130_fd_sc_hd__o22ai_1 U1776 ( .A1(n1123), .A2(n1122), .B1(n441), .B2(
        n1121), .Y(s_mem_d[80]) );
  sky130_fd_sc_hd__nand2_1 U1777 ( .A(n1124), .B(n426), .Y(n1125) );
  sky130_fd_sc_hd__inv_1 U1778 ( .A(s_mem_q[79]), .Y(n1126) );
  sky130_fd_sc_hd__o22ai_1 U1779 ( .A1(n1133), .A2(n1126), .B1(n432), .B2(
        n1131), .Y(s_mem_d[79]) );
  sky130_fd_sc_hd__inv_1 U1780 ( .A(s_mem_q[78]), .Y(n1127) );
  sky130_fd_sc_hd__o22ai_1 U1781 ( .A1(n1133), .A2(n1127), .B1(n369), .B2(
        n1131), .Y(s_mem_d[78]) );
  sky130_fd_sc_hd__inv_1 U1782 ( .A(s_mem_q[77]), .Y(n1128) );
  sky130_fd_sc_hd__o22ai_1 U1783 ( .A1(n1133), .A2(n1128), .B1(n379), .B2(
        n1131), .Y(s_mem_d[77]) );
  sky130_fd_sc_hd__inv_1 U1784 ( .A(s_mem_q[76]), .Y(n1129) );
  sky130_fd_sc_hd__o22ai_1 U1785 ( .A1(n1133), .A2(n1129), .B1(n389), .B2(
        n1131), .Y(s_mem_d[76]) );
  sky130_fd_sc_hd__inv_1 U1786 ( .A(s_mem_q[75]), .Y(n1130) );
  sky130_fd_sc_hd__o22ai_1 U1787 ( .A1(n1133), .A2(n1130), .B1(n399), .B2(
        n1131), .Y(s_mem_d[75]) );
  sky130_fd_sc_hd__inv_1 U1788 ( .A(s_mem_q[74]), .Y(net23649) );
  sky130_fd_sc_hd__o22ai_1 U1789 ( .A1(n1133), .A2(net23649), .B1(n409), .B2(
        n1131), .Y(s_mem_d[74]) );
  sky130_fd_sc_hd__inv_1 U1790 ( .A(s_mem_q[73]), .Y(net23648) );
  sky130_fd_sc_hd__o22ai_1 U1791 ( .A1(n1133), .A2(net23648), .B1(n437), .B2(
        n1131), .Y(s_mem_d[73]) );
  sky130_fd_sc_hd__inv_1 U1792 ( .A(s_mem_q[72]), .Y(n1132) );
  sky130_fd_sc_hd__o22ai_1 U1793 ( .A1(n1133), .A2(n1132), .B1(n1241), .B2(
        n1131), .Y(s_mem_d[72]) );
  sky130_fd_sc_hd__nand2_1 U1794 ( .A(n1135), .B(n34), .Y(n1136) );
  sky130_fd_sc_hd__inv_1 U1795 ( .A(s_mem_q[71]), .Y(n1137) );
  sky130_fd_sc_hd__o22ai_1 U1796 ( .A1(n1144), .A2(n1137), .B1(n432), .B2(
        n1142), .Y(s_mem_d[71]) );
  sky130_fd_sc_hd__inv_1 U1797 ( .A(s_mem_q[70]), .Y(n1138) );
  sky130_fd_sc_hd__o22ai_1 U1798 ( .A1(n1144), .A2(n1138), .B1(n368), .B2(
        n1142), .Y(s_mem_d[70]) );
  sky130_fd_sc_hd__inv_1 U1799 ( .A(s_mem_q[69]), .Y(n1139) );
  sky130_fd_sc_hd__o22ai_1 U1800 ( .A1(n1144), .A2(n1139), .B1(n378), .B2(
        n1142), .Y(s_mem_d[69]) );
  sky130_fd_sc_hd__inv_1 U1801 ( .A(s_mem_q[68]), .Y(n1140) );
  sky130_fd_sc_hd__o22ai_1 U1802 ( .A1(n1144), .A2(n1140), .B1(n388), .B2(
        n1142), .Y(s_mem_d[68]) );
  sky130_fd_sc_hd__inv_1 U1803 ( .A(s_mem_q[67]), .Y(n1141) );
  sky130_fd_sc_hd__o22ai_1 U1804 ( .A1(n1144), .A2(n1141), .B1(n398), .B2(
        n1142), .Y(s_mem_d[67]) );
  sky130_fd_sc_hd__inv_1 U1805 ( .A(s_mem_q[66]), .Y(net23636) );
  sky130_fd_sc_hd__o22ai_1 U1806 ( .A1(n1144), .A2(net23636), .B1(n408), .B2(
        n1142), .Y(s_mem_d[66]) );
  sky130_fd_sc_hd__inv_1 U1807 ( .A(s_mem_q[65]), .Y(net23635) );
  sky130_fd_sc_hd__o22ai_1 U1808 ( .A1(n1144), .A2(net23635), .B1(n437), .B2(
        n1142), .Y(s_mem_d[65]) );
  sky130_fd_sc_hd__inv_1 U1809 ( .A(s_mem_q[64]), .Y(n1143) );
  sky130_fd_sc_hd__o22ai_1 U1810 ( .A1(n1144), .A2(n1143), .B1(n1241), .B2(
        n1142), .Y(s_mem_d[64]) );
  sky130_fd_sc_hd__nand3_1 U1811 ( .A(n1248), .B(n1247), .C(n1249), .Y(n1145)
         );
  sky130_fd_sc_hd__clkinv_2 U1812 ( .A(n1145), .Y(n1223) );
  sky130_fd_sc_hd__nand2_1 U1813 ( .A(n1146), .B(n424), .Y(n1147) );
  sky130_fd_sc_hd__inv_1 U1814 ( .A(s_mem_q[63]), .Y(n1148) );
  sky130_fd_sc_hd__o22ai_1 U1815 ( .A1(n1155), .A2(n1148), .B1(n432), .B2(
        n1153), .Y(s_mem_d[63]) );
  sky130_fd_sc_hd__inv_1 U1816 ( .A(s_mem_q[62]), .Y(n1149) );
  sky130_fd_sc_hd__o22ai_1 U1817 ( .A1(n1155), .A2(n1149), .B1(n366), .B2(
        n1153), .Y(s_mem_d[62]) );
  sky130_fd_sc_hd__inv_1 U1818 ( .A(s_mem_q[61]), .Y(n1150) );
  sky130_fd_sc_hd__o22ai_1 U1819 ( .A1(n1155), .A2(n1150), .B1(n376), .B2(
        n1153), .Y(s_mem_d[61]) );
  sky130_fd_sc_hd__inv_1 U1820 ( .A(s_mem_q[60]), .Y(n1151) );
  sky130_fd_sc_hd__o22ai_1 U1821 ( .A1(n1155), .A2(n1151), .B1(n386), .B2(
        n1153), .Y(s_mem_d[60]) );
  sky130_fd_sc_hd__inv_1 U1822 ( .A(s_mem_q[59]), .Y(n1152) );
  sky130_fd_sc_hd__o22ai_1 U1823 ( .A1(n1155), .A2(n1152), .B1(n396), .B2(
        n1153), .Y(s_mem_d[59]) );
  sky130_fd_sc_hd__inv_1 U1824 ( .A(s_mem_q[58]), .Y(net23622) );
  sky130_fd_sc_hd__o22ai_1 U1825 ( .A1(n1155), .A2(net23622), .B1(n406), .B2(
        n1153), .Y(s_mem_d[58]) );
  sky130_fd_sc_hd__inv_1 U1826 ( .A(s_mem_q[57]), .Y(net23621) );
  sky130_fd_sc_hd__o22ai_1 U1827 ( .A1(n1155), .A2(net23621), .B1(n437), .B2(
        n1153), .Y(s_mem_d[57]) );
  sky130_fd_sc_hd__inv_1 U1828 ( .A(s_mem_q[56]), .Y(n1154) );
  sky130_fd_sc_hd__o22ai_1 U1829 ( .A1(n1155), .A2(n1154), .B1(n1241), .B2(
        n1153), .Y(s_mem_d[56]) );
  sky130_fd_sc_hd__nand2_1 U1830 ( .A(n1157), .B(n427), .Y(n1158) );
  sky130_fd_sc_hd__inv_1 U1831 ( .A(s_mem_q[55]), .Y(n1159) );
  sky130_fd_sc_hd__o22ai_1 U1832 ( .A1(n1166), .A2(n1159), .B1(n432), .B2(
        n1164), .Y(s_mem_d[55]) );
  sky130_fd_sc_hd__inv_1 U1833 ( .A(s_mem_q[54]), .Y(n1160) );
  sky130_fd_sc_hd__o22ai_1 U1834 ( .A1(n1166), .A2(n1160), .B1(n367), .B2(
        n1164), .Y(s_mem_d[54]) );
  sky130_fd_sc_hd__inv_1 U1835 ( .A(s_mem_q[53]), .Y(n1161) );
  sky130_fd_sc_hd__o22ai_1 U1836 ( .A1(n1166), .A2(n1161), .B1(n377), .B2(
        n1164), .Y(s_mem_d[53]) );
  sky130_fd_sc_hd__inv_1 U1837 ( .A(s_mem_q[52]), .Y(n1162) );
  sky130_fd_sc_hd__o22ai_1 U1838 ( .A1(n1166), .A2(n1162), .B1(n387), .B2(
        n1164), .Y(s_mem_d[52]) );
  sky130_fd_sc_hd__inv_1 U1839 ( .A(s_mem_q[51]), .Y(n1163) );
  sky130_fd_sc_hd__o22ai_1 U1840 ( .A1(n1166), .A2(n1163), .B1(n397), .B2(
        n1164), .Y(s_mem_d[51]) );
  sky130_fd_sc_hd__inv_1 U1841 ( .A(s_mem_q[50]), .Y(net23609) );
  sky130_fd_sc_hd__o22ai_1 U1842 ( .A1(n1166), .A2(net23609), .B1(n407), .B2(
        n1164), .Y(s_mem_d[50]) );
  sky130_fd_sc_hd__inv_1 U1843 ( .A(s_mem_q[49]), .Y(net23608) );
  sky130_fd_sc_hd__o22ai_1 U1844 ( .A1(n1166), .A2(net23608), .B1(n437), .B2(
        n1164), .Y(s_mem_d[49]) );
  sky130_fd_sc_hd__inv_1 U1845 ( .A(s_mem_q[48]), .Y(n1165) );
  sky130_fd_sc_hd__o22ai_1 U1846 ( .A1(n1166), .A2(n1165), .B1(n1241), .B2(
        n1164), .Y(s_mem_d[48]) );
  sky130_fd_sc_hd__nand2_1 U1847 ( .A(n1168), .B(n426), .Y(n1169) );
  sky130_fd_sc_hd__inv_1 U1848 ( .A(s_mem_q[47]), .Y(n1170) );
  sky130_fd_sc_hd__o22ai_1 U1849 ( .A1(n1177), .A2(n1170), .B1(n432), .B2(
        n1175), .Y(s_mem_d[47]) );
  sky130_fd_sc_hd__inv_1 U1850 ( .A(s_mem_q[46]), .Y(n1171) );
  sky130_fd_sc_hd__o22ai_1 U1851 ( .A1(n1177), .A2(n1171), .B1(n372), .B2(
        n1175), .Y(s_mem_d[46]) );
  sky130_fd_sc_hd__inv_1 U1852 ( .A(s_mem_q[45]), .Y(n1172) );
  sky130_fd_sc_hd__o22ai_1 U1853 ( .A1(n1177), .A2(n1172), .B1(n382), .B2(
        n1175), .Y(s_mem_d[45]) );
  sky130_fd_sc_hd__inv_1 U1854 ( .A(s_mem_q[44]), .Y(n1173) );
  sky130_fd_sc_hd__o22ai_1 U1855 ( .A1(n1177), .A2(n1173), .B1(n392), .B2(
        n1175), .Y(s_mem_d[44]) );
  sky130_fd_sc_hd__inv_1 U1856 ( .A(s_mem_q[43]), .Y(n1174) );
  sky130_fd_sc_hd__o22ai_1 U1857 ( .A1(n1177), .A2(n1174), .B1(n402), .B2(
        n1175), .Y(s_mem_d[43]) );
  sky130_fd_sc_hd__inv_1 U1858 ( .A(s_mem_q[42]), .Y(net23596) );
  sky130_fd_sc_hd__o22ai_1 U1859 ( .A1(n1177), .A2(net23596), .B1(n412), .B2(
        n1175), .Y(s_mem_d[42]) );
  sky130_fd_sc_hd__inv_1 U1860 ( .A(s_mem_q[41]), .Y(net23595) );
  sky130_fd_sc_hd__o22ai_1 U1861 ( .A1(n1177), .A2(net23595), .B1(n437), .B2(
        n1175), .Y(s_mem_d[41]) );
  sky130_fd_sc_hd__inv_1 U1862 ( .A(s_mem_q[40]), .Y(n1176) );
  sky130_fd_sc_hd__o22ai_1 U1863 ( .A1(n1177), .A2(n1176), .B1(n1241), .B2(
        n1175), .Y(s_mem_d[40]) );
  sky130_fd_sc_hd__nand2_1 U1864 ( .A(n1179), .B(n423), .Y(n1180) );
  sky130_fd_sc_hd__inv_1 U1865 ( .A(s_mem_q[39]), .Y(n1181) );
  sky130_fd_sc_hd__o22ai_1 U1866 ( .A1(n1188), .A2(n1181), .B1(n432), .B2(
        n1186), .Y(s_mem_d[39]) );
  sky130_fd_sc_hd__inv_1 U1867 ( .A(s_mem_q[38]), .Y(n1182) );
  sky130_fd_sc_hd__o22ai_1 U1868 ( .A1(n1188), .A2(n1182), .B1(n365), .B2(
        n1186), .Y(s_mem_d[38]) );
  sky130_fd_sc_hd__inv_1 U1869 ( .A(s_mem_q[37]), .Y(n1183) );
  sky130_fd_sc_hd__o22ai_1 U1870 ( .A1(n1188), .A2(n1183), .B1(n375), .B2(
        n1186), .Y(s_mem_d[37]) );
  sky130_fd_sc_hd__inv_1 U1871 ( .A(s_mem_q[36]), .Y(n1184) );
  sky130_fd_sc_hd__o22ai_1 U1872 ( .A1(n1188), .A2(n1184), .B1(n385), .B2(
        n1186), .Y(s_mem_d[36]) );
  sky130_fd_sc_hd__inv_1 U1873 ( .A(s_mem_q[35]), .Y(n1185) );
  sky130_fd_sc_hd__o22ai_1 U1874 ( .A1(n1188), .A2(n1185), .B1(n395), .B2(
        n1186), .Y(s_mem_d[35]) );
  sky130_fd_sc_hd__inv_1 U1875 ( .A(s_mem_q[34]), .Y(net23583) );
  sky130_fd_sc_hd__o22ai_1 U1876 ( .A1(n1188), .A2(net23583), .B1(n405), .B2(
        n1186), .Y(s_mem_d[34]) );
  sky130_fd_sc_hd__inv_1 U1877 ( .A(s_mem_q[33]), .Y(net23582) );
  sky130_fd_sc_hd__o22ai_1 U1878 ( .A1(n1188), .A2(net23582), .B1(n437), .B2(
        n1186), .Y(s_mem_d[33]) );
  sky130_fd_sc_hd__inv_1 U1879 ( .A(s_mem_q[32]), .Y(n1187) );
  sky130_fd_sc_hd__o22ai_1 U1880 ( .A1(n1188), .A2(n1187), .B1(n1241), .B2(
        n1186), .Y(s_mem_d[32]) );
  sky130_fd_sc_hd__nand2_1 U1881 ( .A(n1189), .B(n425), .Y(n1190) );
  sky130_fd_sc_hd__inv_1 U1882 ( .A(s_mem_q[31]), .Y(n1191) );
  sky130_fd_sc_hd__o22ai_1 U1883 ( .A1(n1198), .A2(n1191), .B1(n432), .B2(
        n1196), .Y(s_mem_d[31]) );
  sky130_fd_sc_hd__inv_1 U1884 ( .A(s_mem_q[30]), .Y(n1192) );
  sky130_fd_sc_hd__o22ai_1 U1885 ( .A1(n1198), .A2(n1192), .B1(n370), .B2(
        n1196), .Y(s_mem_d[30]) );
  sky130_fd_sc_hd__inv_1 U1886 ( .A(s_mem_q[29]), .Y(n1193) );
  sky130_fd_sc_hd__o22ai_1 U1887 ( .A1(n1198), .A2(n1193), .B1(n380), .B2(
        n1196), .Y(s_mem_d[29]) );
  sky130_fd_sc_hd__inv_1 U1888 ( .A(s_mem_q[28]), .Y(n1194) );
  sky130_fd_sc_hd__o22ai_1 U1889 ( .A1(n1198), .A2(n1194), .B1(n390), .B2(
        n1196), .Y(s_mem_d[28]) );
  sky130_fd_sc_hd__inv_1 U1890 ( .A(s_mem_q[27]), .Y(n1195) );
  sky130_fd_sc_hd__o22ai_1 U1891 ( .A1(n1198), .A2(n1195), .B1(n400), .B2(
        n1196), .Y(s_mem_d[27]) );
  sky130_fd_sc_hd__inv_1 U1892 ( .A(s_mem_q[26]), .Y(net23570) );
  sky130_fd_sc_hd__o22ai_1 U1893 ( .A1(n1198), .A2(net23570), .B1(n410), .B2(
        n1196), .Y(s_mem_d[26]) );
  sky130_fd_sc_hd__inv_1 U1894 ( .A(s_mem_q[25]), .Y(net23569) );
  sky130_fd_sc_hd__o22ai_1 U1895 ( .A1(n1198), .A2(net23569), .B1(n437), .B2(
        n1196), .Y(s_mem_d[25]) );
  sky130_fd_sc_hd__inv_1 U1896 ( .A(s_mem_q[24]), .Y(n1197) );
  sky130_fd_sc_hd__o22ai_1 U1897 ( .A1(n1198), .A2(n1197), .B1(n1241), .B2(
        n1196), .Y(s_mem_d[24]) );
  sky130_fd_sc_hd__nand2_1 U1898 ( .A(n1200), .B(n423), .Y(n1201) );
  sky130_fd_sc_hd__inv_1 U1899 ( .A(s_mem_q[23]), .Y(n1202) );
  sky130_fd_sc_hd__o22ai_1 U1900 ( .A1(n1209), .A2(n1202), .B1(n432), .B2(
        n1207), .Y(s_mem_d[23]) );
  sky130_fd_sc_hd__inv_1 U1901 ( .A(s_mem_q[22]), .Y(n1203) );
  sky130_fd_sc_hd__o22ai_1 U1902 ( .A1(n1209), .A2(n1203), .B1(n371), .B2(
        n1207), .Y(s_mem_d[22]) );
  sky130_fd_sc_hd__inv_1 U1903 ( .A(s_mem_q[21]), .Y(n1204) );
  sky130_fd_sc_hd__o22ai_1 U1904 ( .A1(n1209), .A2(n1204), .B1(n381), .B2(
        n1207), .Y(s_mem_d[21]) );
  sky130_fd_sc_hd__inv_1 U1905 ( .A(s_mem_q[20]), .Y(n1205) );
  sky130_fd_sc_hd__o22ai_1 U1906 ( .A1(n1209), .A2(n1205), .B1(n391), .B2(
        n1207), .Y(s_mem_d[20]) );
  sky130_fd_sc_hd__inv_1 U1907 ( .A(s_mem_q[19]), .Y(n1206) );
  sky130_fd_sc_hd__o22ai_1 U1908 ( .A1(n1209), .A2(n1206), .B1(n401), .B2(
        n1207), .Y(s_mem_d[19]) );
  sky130_fd_sc_hd__inv_1 U1909 ( .A(s_mem_q[18]), .Y(net23557) );
  sky130_fd_sc_hd__o22ai_1 U1910 ( .A1(n1209), .A2(net23557), .B1(n411), .B2(
        n1207), .Y(s_mem_d[18]) );
  sky130_fd_sc_hd__inv_1 U1911 ( .A(s_mem_q[17]), .Y(net23556) );
  sky130_fd_sc_hd__o22ai_1 U1912 ( .A1(n1209), .A2(net23556), .B1(n437), .B2(
        n1207), .Y(s_mem_d[17]) );
  sky130_fd_sc_hd__inv_1 U1913 ( .A(s_mem_q[16]), .Y(n1208) );
  sky130_fd_sc_hd__o22ai_1 U1914 ( .A1(n1209), .A2(n1208), .B1(n1241), .B2(
        n1207), .Y(s_mem_d[16]) );
  sky130_fd_sc_hd__nand2_1 U1915 ( .A(n1211), .B(n425), .Y(n1212) );
  sky130_fd_sc_hd__inv_1 U1916 ( .A(s_mem_q[15]), .Y(n1213) );
  sky130_fd_sc_hd__o22ai_1 U1917 ( .A1(n1222), .A2(n1213), .B1(n432), .B2(
        n1220), .Y(s_mem_d[15]) );
  sky130_fd_sc_hd__inv_1 U1918 ( .A(s_mem_q[14]), .Y(n1214) );
  sky130_fd_sc_hd__o22ai_1 U1919 ( .A1(n1222), .A2(n1214), .B1(n370), .B2(
        n1220), .Y(s_mem_d[14]) );
  sky130_fd_sc_hd__inv_1 U1920 ( .A(s_mem_q[13]), .Y(n1215) );
  sky130_fd_sc_hd__o22ai_1 U1921 ( .A1(n1222), .A2(n1215), .B1(n380), .B2(
        n1220), .Y(s_mem_d[13]) );
  sky130_fd_sc_hd__inv_1 U1922 ( .A(s_mem_q[12]), .Y(n1216) );
  sky130_fd_sc_hd__o22ai_1 U1923 ( .A1(n1222), .A2(n1216), .B1(n390), .B2(
        n1220), .Y(s_mem_d[12]) );
  sky130_fd_sc_hd__inv_1 U1924 ( .A(s_mem_q[11]), .Y(n1217) );
  sky130_fd_sc_hd__o22ai_1 U1925 ( .A1(n1222), .A2(n1217), .B1(n400), .B2(
        n1220), .Y(s_mem_d[11]) );
  sky130_fd_sc_hd__inv_1 U1926 ( .A(s_mem_q[10]), .Y(n1218) );
  sky130_fd_sc_hd__o22ai_1 U1927 ( .A1(n1222), .A2(n1218), .B1(n410), .B2(
        n1220), .Y(s_mem_d[10]) );
  sky130_fd_sc_hd__inv_1 U1928 ( .A(s_mem_q[9]), .Y(n1219) );
  sky130_fd_sc_hd__o22ai_1 U1929 ( .A1(n1222), .A2(n1219), .B1(n437), .B2(
        n1220), .Y(s_mem_d[9]) );
  sky130_fd_sc_hd__inv_1 U1930 ( .A(s_mem_q[8]), .Y(n1221) );
  sky130_fd_sc_hd__o22ai_1 U1931 ( .A1(n1222), .A2(n1221), .B1(n1241), .B2(
        n1220), .Y(s_mem_d[8]) );
  sky130_fd_sc_hd__nand2_1 U1932 ( .A(n34), .B(n1225), .Y(n1226) );
  sky130_fd_sc_hd__inv_1 U1933 ( .A(s_mem_q[7]), .Y(n1228) );
  sky130_fd_sc_hd__o22ai_1 U1934 ( .A1(n1244), .A2(n1228), .B1(n1242), .B2(
        n432), .Y(s_mem_d[7]) );
  sky130_fd_sc_hd__inv_1 U1935 ( .A(s_mem_q[6]), .Y(n1230) );
  sky130_fd_sc_hd__o22ai_1 U1936 ( .A1(n1244), .A2(n1230), .B1(n1242), .B2(
        n368), .Y(s_mem_d[6]) );
  sky130_fd_sc_hd__inv_1 U1937 ( .A(s_mem_q[5]), .Y(n1232) );
  sky130_fd_sc_hd__o22ai_1 U1938 ( .A1(n1244), .A2(n1232), .B1(n1242), .B2(
        n378), .Y(s_mem_d[5]) );
  sky130_fd_sc_hd__inv_1 U1939 ( .A(s_mem_q[4]), .Y(n1234) );
  sky130_fd_sc_hd__o22ai_1 U1940 ( .A1(n1244), .A2(n1234), .B1(n1242), .B2(
        n388), .Y(s_mem_d[4]) );
  sky130_fd_sc_hd__inv_1 U1941 ( .A(s_mem_q[3]), .Y(n1236) );
  sky130_fd_sc_hd__o22ai_1 U1942 ( .A1(n1244), .A2(n1236), .B1(n1242), .B2(
        n398), .Y(s_mem_d[3]) );
  sky130_fd_sc_hd__inv_1 U1943 ( .A(s_mem_q[2]), .Y(n1238) );
  sky130_fd_sc_hd__o22ai_1 U1944 ( .A1(n1244), .A2(n1238), .B1(n1242), .B2(
        n408), .Y(s_mem_d[2]) );
  sky130_fd_sc_hd__inv_1 U1945 ( .A(s_mem_q[1]), .Y(n1240) );
  sky130_fd_sc_hd__o22ai_1 U1946 ( .A1(n1244), .A2(n1240), .B1(n1242), .B2(
        n437), .Y(s_mem_d[1]) );
  sky130_fd_sc_hd__inv_1 U1947 ( .A(s_mem_q[0]), .Y(n1243) );
  sky130_fd_sc_hd__o22ai_1 U1948 ( .A1(n1244), .A2(n1243), .B1(n1242), .B2(
        n1241), .Y(s_mem_d[0]) );
  sky130_fd_sc_hd__nand2_1 U1949 ( .A(n1246), .B(n1245), .Y(n1253) );
  sky130_fd_sc_hd__o2bb2ai_1 U1950 ( .B1(n1253), .B2(n1247), .A1_N(N100), 
        .A2_N(n415), .Y(s_wr_ptr_d[5]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1951 ( .B1(n1253), .B2(n1248), .A1_N(N99), 
        .A2_N(n415), .Y(s_wr_ptr_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1952 ( .B1(n1253), .B2(n1249), .A1_N(N98), 
        .A2_N(n415), .Y(s_wr_ptr_d[3]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1953 ( .B1(n1253), .B2(n1250), .A1_N(N97), 
        .A2_N(n415), .Y(s_wr_ptr_d[2]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1954 ( .B1(n1253), .B2(n1252), .A1_N(N96), 
        .A2_N(n415), .Y(s_wr_ptr_d[1]) );
  sky130_fd_sc_hd__mux2i_1 U1955 ( .A0(n414), .A1(n1253), .S(s_wr_ptr_q[0]), 
        .Y(s_wr_ptr_d[0]) );
  sky130_fd_sc_hd__xor2_1 U1956 ( .A(\add_50/carry[5] ), .B(N80), .X(N89) );
  sky130_fd_sc_hd__xor2_1 U1957 ( .A(\add_65/carry[5] ), .B(s_wr_ptr_q[5]), 
        .X(N100) );
endmodule


module uart_tx_DW01_inc_1 ( A, SUM );
  input [15:0] A;
  output [15:0] SUM;
  wire   n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n42, n43, n44, n45,
         n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n94;
  assign n2 = A[14];
  assign n9 = A[12];
  assign n15 = A[11];
  assign n18 = A[10];
  assign n22 = A[9];
  assign n25 = A[8];
  assign n31 = A[7];
  assign n34 = A[6];
  assign n38 = A[5];
  assign n42 = A[4];
  assign n47 = A[3];
  assign n50 = A[2];
  assign n54 = A[1];
  assign n56 = A[0];

  sky130_fd_sc_hd__xor2_1 U1 ( .A(A[15]), .B(n94), .X(SUM[15]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n3), .B(n4), .Y(SUM[14]) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n8), .B(n7), .X(SUM[13]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n28), .B(n5), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n13), .B(n6), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n7), .B(n10), .Y(n6) );
  sky130_fd_sc_hd__xnor2_1 U12 ( .A(n10), .B(n11), .Y(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n11), .B(n9), .Y(n8) );
  sky130_fd_sc_hd__xor2_1 U16 ( .A(n17), .B(n16), .X(SUM[11]) );
  sky130_fd_sc_hd__nor2_1 U17 ( .A(n12), .B(n28), .Y(n11) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n14), .B(n21), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n18), .B(n15), .Y(n14) );
  sky130_fd_sc_hd__xnor2_1 U23 ( .A(n19), .B(n20), .Y(SUM[10]) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n20), .B(n18), .Y(n17) );
  sky130_fd_sc_hd__xor2_1 U27 ( .A(n24), .B(n23), .X(SUM[9]) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n21), .B(n28), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n25), .B(n22), .Y(n21) );
  sky130_fd_sc_hd__xnor2_1 U32 ( .A(n26), .B(n27), .Y(SUM[8]) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n27), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__xor2_1 U36 ( .A(n33), .B(n32), .X(SUM[7]) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n29), .B(n45), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(n30), .B(n37), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n34), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__xnor2_1 U43 ( .A(n35), .B(n36), .Y(SUM[6]) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n36), .B(n34), .Y(n33) );
  sky130_fd_sc_hd__xnor2_1 U47 ( .A(n39), .B(n40), .Y(SUM[5]) );
  sky130_fd_sc_hd__nor2_1 U48 ( .A(n37), .B(n44), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n42), .B(n38), .Y(n37) );
  sky130_fd_sc_hd__xor2_1 U52 ( .A(n44), .B(n43), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U53 ( .A(n43), .B(n44), .Y(n40) );
  sky130_fd_sc_hd__xor2_1 U57 ( .A(n49), .B(n48), .X(SUM[3]) );
  sky130_fd_sc_hd__nor2_1 U59 ( .A(n53), .B(n46), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U60 ( .A(n50), .B(n47), .Y(n46) );
  sky130_fd_sc_hd__xnor2_1 U63 ( .A(n51), .B(n52), .Y(SUM[2]) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n52), .B(n50), .Y(n49) );
  sky130_fd_sc_hd__xnor2_1 U67 ( .A(n56), .B(n55), .Y(SUM[1]) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n54), .B(n56), .Y(n53) );
  sky130_fd_sc_hd__inv_2 U76 ( .A(n28), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U77 ( .A(n45), .Y(n44) );
  sky130_fd_sc_hd__inv_2 U78 ( .A(n42), .Y(n43) );
  sky130_fd_sc_hd__inv_2 U79 ( .A(n53), .Y(n52) );
  sky130_fd_sc_hd__inv_2 U80 ( .A(A[13]), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n9), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U82 ( .A(n13), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U83 ( .A(n2), .Y(n3) );
  sky130_fd_sc_hd__inv_2 U84 ( .A(n15), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U85 ( .A(n18), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U86 ( .A(n22), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U87 ( .A(n25), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(n31), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(n34), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U90 ( .A(n38), .Y(n39) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(n47), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U92 ( .A(n50), .Y(n51) );
  sky130_fd_sc_hd__inv_2 U93 ( .A(n54), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U94 ( .A(n56), .Y(SUM[0]) );
  sky130_fd_sc_hd__and2_1 U95 ( .A(n4), .B(n2), .X(n94) );
endmodule


module uart_tx ( clk_i, rst_n_i, tx_o, busy_o, cfg_en_i, cfg_div_i, 
        cfg_parity_en_i, cfg_bits_i, cfg_stop_bits_i, tx_data_i, tx_valid_i, 
        tx_ready_o );
  input [15:0] cfg_div_i;
  input [1:0] cfg_bits_i;
  input [7:0] tx_data_i;
  input clk_i, rst_n_i, cfg_en_i, cfg_parity_en_i, cfg_stop_bits_i, tx_valid_i;
  output tx_o, busy_o, tx_ready_o;
  wire   \s_reg_data_q[7] , s_parity_bit_q, s_bit_done, N87, N88, N89, N90,
         N91, N92, N93, N94, N95, N96, N97, N98, N99, N100, N101, N102, N119,
         N120, N121, N122, N123, N124, N125, N126, N127, N128, N129, N130,
         N131, N132, N133, N134, N135, n22, n29, n43, n44, n84, n85, n86, n87,
         n88, n89, n90, n91, n93, n94, n95, n96, n97, n98, net12840, net18291,
         net23009, net23011, net23013, net23015, net23016, net23019, net23021,
         net23022, net23023, net23025, net23034, net23037, net23043, net23051,
         net23053, net23054, net23056, net23057, net23060, net23061, net23064,
         net23090, net25044, net25199, net25238, net28399, net28433, net28432,
         net28430, net28456, net31367, net23024, net28457, n74, n1, n2, n3, n4,
         n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19,
         n20, n21, n23, n24, n25, n26, n27, n28, n30, n31, n32, n33, n34, n35,
         n36, n37, n38, n39, n40, n41, n42, n45, n46, n47, n48, n49, n50, n51,
         n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65,
         n66, n67, n68, n69, n70, n71, n72, n73;
  wire   [2:0] s_fsm_q;
  wire   [2:0] s_reg_bit_cnt_q;
  wire   [15:0] baud_cnt;
  assign tx_ready_o = net12840;
  assign busy_o = net25199;

  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_0_ ( .D(N120), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[0]) );
  sky130_fd_sc_hd__dfrtp_1 s_bit_done_reg ( .D(N119), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_bit_done) );
  sky130_fd_sc_hd__dfrtp_1 s_reg_bit_cnt_q_reg_1_ ( .D(n98), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_reg_bit_cnt_q[1]) );
  sky130_fd_sc_hd__dfrtp_1 s_reg_bit_cnt_q_reg_2_ ( .D(n93), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_reg_bit_cnt_q[2]) );
  sky130_fd_sc_hd__dfrtp_1 s_reg_bit_cnt_q_reg_0_ ( .D(n94), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_reg_bit_cnt_q[0]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_2_ ( .D(n97), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[2]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_1_ ( .D(N121), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[1]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_2_ ( .D(N122), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[2]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_3_ ( .D(N123), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[3]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_4_ ( .D(N124), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[4]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_5_ ( .D(N125), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[5]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_6_ ( .D(N126), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[6]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_7_ ( .D(N127), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[7]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_8_ ( .D(N128), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[8]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_9_ ( .D(N129), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[9]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_10_ ( .D(N130), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[10]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_11_ ( .D(N131), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[11]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_12_ ( .D(N132), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[12]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_13_ ( .D(N133), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[13]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_14_ ( .D(N134), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[14]) );
  sky130_fd_sc_hd__dfrtp_1 baud_cnt_reg_15_ ( .D(N135), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(baud_cnt[15]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_0_ ( .D(n95), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[0]) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_7_ ( .D(n90), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(\s_reg_data_q[7] ), .Q_N(n22) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_0_ ( .D(n6), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n71), .Q_N(n29) );
  sky130_fd_sc_hd__dfrtp_1 s_parity_bit_q_reg ( .D(n91), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_parity_bit_q) );
  uart_tx_DW01_inc_1 add_163 ( .A(baud_cnt), .SUM({N102, N101, N100, N99, N98, 
        N97, N96, N95, N94, N93, N92, N91, N90, N89, N88, N87}) );
  sky130_fd_sc_hd__dfrtp_2 s_fsm_q_reg_1_ ( .D(n96), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[1]) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_6_ ( .D(n89), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n21) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_5_ ( .D(n88), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n19) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_4_ ( .D(n87), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n17) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_3_ ( .D(n86), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(net28432) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_1_ ( .D(n84), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(net28430) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_2_ ( .D(n85), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(net28456) );
  sky130_fd_sc_hd__o21a_1 U3 ( .A1(n4), .A2(net25199), .B1(net23057), .X(
        net23056) );
  sky130_fd_sc_hd__clkinv_1 U4 ( .A(net25238), .Y(n4) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(net25199), .Y(n11) );
  sky130_fd_sc_hd__clkinv_2 U6 ( .A(s_fsm_q[0]), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(net23015), .Y(net23011) );
  sky130_fd_sc_hd__clkinv_1 U8 ( .A(net23019), .Y(net23016) );
  sky130_fd_sc_hd__inv_1 U9 ( .A(n62), .Y(n52) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(n43), .Y(net23051) );
  sky130_fd_sc_hd__o21a_1 U11 ( .A1(s_reg_bit_cnt_q[0]), .A2(net18291), .B1(n2), .X(n1) );
  sky130_fd_sc_hd__and2_4 U12 ( .A(net23016), .B(s_fsm_q[1]), .X(n2) );
  sky130_fd_sc_hd__and2_4 U13 ( .A(n49), .B(net28399), .X(n3) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(net23043), .Y(net23013) );
  sky130_fd_sc_hd__inv_1 U15 ( .A(s_reg_bit_cnt_q[1]), .Y(n73) );
  sky130_fd_sc_hd__o211ai_1 U16 ( .A1(tx_valid_i), .A2(net25199), .B1(cfg_en_i), .C1(net23060), .Y(n55) );
  sky130_fd_sc_hd__inv_1 U17 ( .A(n63), .Y(n5) );
  sky130_fd_sc_hd__o21a_1 U18 ( .A1(n4), .A2(net23043), .B1(net23057), .X(n61)
         );
  sky130_fd_sc_hd__nand3_1 U19 ( .A(net25044), .B(n24), .C(n25), .Y(n6) );
  sky130_fd_sc_hd__inv_1 U20 ( .A(n56), .Y(n7) );
  sky130_fd_sc_hd__nor2_2 U21 ( .A(n74), .B(net23037), .Y(net12840) );
  sky130_fd_sc_hd__a221o_1 U22 ( .A1(tx_data_i[2]), .A2(net23022), .B1(
        net28432), .B2(net23021), .C1(n8), .X(n85) );
  sky130_fd_sc_hd__nor2_1 U23 ( .A(net28457), .B(net23025), .Y(n8) );
  sky130_fd_sc_hd__inv_2 U24 ( .A(net28456), .Y(net28457) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(n9), .Y(net23021) );
  sky130_fd_sc_hd__nand2_1 U26 ( .A(net23025), .B(net25199), .Y(n9) );
  sky130_fd_sc_hd__buf_6 U27 ( .A(n74), .X(net25199) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(n10), .Y(net23022) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(net23025), .B(n11), .Y(n10) );
  sky130_fd_sc_hd__nand2_2 U30 ( .A(tx_valid_i), .B(n11), .Y(n13) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(net28432), .Y(net28433) );
  sky130_fd_sc_hd__o31ai_4 U32 ( .A1(net18291), .A2(n12), .A3(net23015), .B1(
        n13), .Y(net23025) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(s_bit_done), .Y(n12) );
  sky130_fd_sc_hd__nand2_2 U34 ( .A(net23061), .B(n12), .Y(net23060) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(net23053), .Y(net18291) );
  sky130_fd_sc_hd__a221o_1 U36 ( .A1(tx_data_i[1]), .A2(net23022), .B1(
        net28456), .B2(net23021), .C1(net23024), .X(n84) );
  sky130_fd_sc_hd__nand2_2 U37 ( .A(n14), .B(n15), .Y(n74) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(s_fsm_q[1]), .Y(n15) );
  sky130_fd_sc_hd__or2_4 U39 ( .A(n15), .B(net23090), .X(net23015) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(net23090), .Y(n14) );
  sky130_fd_sc_hd__o211ai_1 U41 ( .A1(s_fsm_q[1]), .A2(n14), .B1(net23015), 
        .C1(net23043), .Y(net23061) );
  sky130_fd_sc_hd__nor2_1 U42 ( .A(n13), .B(tx_data_i[7]), .Y(net23034) );
  sky130_fd_sc_hd__nand4_1 U43 ( .A(s_bit_done), .B(net23009), .C(net23043), 
        .D(net25199), .Y(net23019) );
  sky130_fd_sc_hd__nand3_1 U44 ( .A(s_reg_bit_cnt_q[0]), .B(n2), .C(net23053), 
        .Y(n43) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n2), .B(net23053), .Y(net23054) );
  sky130_fd_sc_hd__nor2_1 U46 ( .A(n16), .B(net23025), .Y(net23024) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(net28430), .Y(n16) );
  sky130_fd_sc_hd__nand2_1 U48 ( .A(net23021), .B(net28430), .Y(net25044) );
  sky130_fd_sc_hd__o21a_2 U49 ( .A1(net18291), .A2(s_reg_bit_cnt_q[1]), .B1(n1), .X(n44) );
  sky130_fd_sc_hd__dlygate4sd3_1 U50 ( .A(s_fsm_q[2]), .X(net31367) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n17), .Y(n18) );
  sky130_fd_sc_hd__inv_2 U52 ( .A(n19), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n21), .Y(n23) );
  sky130_fd_sc_hd__dlymetal6s2s_1 U54 ( .A(net23061), .X(net28399) );
  sky130_fd_sc_hd__clkinv_2 U55 ( .A(s_fsm_q[2]), .Y(net23009) );
  sky130_fd_sc_hd__o22ai_1 U56 ( .A1(n1), .A2(n73), .B1(s_reg_bit_cnt_q[1]), 
        .B2(n43), .Y(n98) );
  sky130_fd_sc_hd__inv_1 U57 ( .A(net28399), .Y(net23064) );
  sky130_fd_sc_hd__inv_1 U58 ( .A(n57), .Y(n63) );
  sky130_fd_sc_hd__o211a_2 U59 ( .A1(tx_valid_i), .A2(net25199), .B1(cfg_en_i), 
        .C1(net23060), .X(net25238) );
  sky130_fd_sc_hd__nand2_2 U60 ( .A(net23009), .B(n56), .Y(net23090) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(tx_data_i[0]), .B(net23022), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U62 ( .A(net23023), .B(n71), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U63 ( .A(net23025), .Y(net23023) );
  sky130_fd_sc_hd__xor2_1 U64 ( .A(cfg_div_i[7]), .B(baud_cnt[7]), .X(n30) );
  sky130_fd_sc_hd__xor2_1 U65 ( .A(cfg_div_i[6]), .B(baud_cnt[6]), .X(n28) );
  sky130_fd_sc_hd__xor2_1 U66 ( .A(cfg_div_i[5]), .B(baud_cnt[5]), .X(n27) );
  sky130_fd_sc_hd__xor2_1 U67 ( .A(cfg_div_i[4]), .B(baud_cnt[4]), .X(n26) );
  sky130_fd_sc_hd__nor4_1 U68 ( .A(n30), .B(n28), .C(n27), .D(n26), .Y(n48) );
  sky130_fd_sc_hd__xor2_1 U69 ( .A(cfg_div_i[3]), .B(baud_cnt[3]), .X(n34) );
  sky130_fd_sc_hd__xor2_1 U70 ( .A(cfg_div_i[2]), .B(baud_cnt[2]), .X(n33) );
  sky130_fd_sc_hd__xor2_1 U71 ( .A(cfg_div_i[1]), .B(baud_cnt[1]), .X(n32) );
  sky130_fd_sc_hd__xor2_1 U72 ( .A(cfg_div_i[0]), .B(baud_cnt[0]), .X(n31) );
  sky130_fd_sc_hd__nor4_1 U73 ( .A(n34), .B(n33), .C(n32), .D(n31), .Y(n47) );
  sky130_fd_sc_hd__xor2_1 U74 ( .A(cfg_div_i[15]), .B(baud_cnt[15]), .X(n38)
         );
  sky130_fd_sc_hd__xor2_1 U75 ( .A(cfg_div_i[14]), .B(baud_cnt[14]), .X(n37)
         );
  sky130_fd_sc_hd__xor2_1 U76 ( .A(cfg_div_i[13]), .B(baud_cnt[13]), .X(n36)
         );
  sky130_fd_sc_hd__xor2_1 U77 ( .A(cfg_div_i[12]), .B(baud_cnt[12]), .X(n35)
         );
  sky130_fd_sc_hd__nor4_1 U78 ( .A(n38), .B(n37), .C(n36), .D(n35), .Y(n46) );
  sky130_fd_sc_hd__xor2_1 U79 ( .A(cfg_div_i[11]), .B(baud_cnt[11]), .X(n42)
         );
  sky130_fd_sc_hd__xor2_1 U80 ( .A(cfg_div_i[10]), .B(baud_cnt[10]), .X(n41)
         );
  sky130_fd_sc_hd__xor2_1 U81 ( .A(cfg_div_i[9]), .B(baud_cnt[9]), .X(n40) );
  sky130_fd_sc_hd__xor2_1 U82 ( .A(cfg_div_i[8]), .B(baud_cnt[8]), .X(n39) );
  sky130_fd_sc_hd__nor4_1 U83 ( .A(n42), .B(n41), .C(n40), .D(n39), .Y(n45) );
  sky130_fd_sc_hd__nand4_1 U84 ( .A(n48), .B(n47), .C(n46), .D(n45), .Y(n49)
         );
  sky130_fd_sc_hd__nand3_1 U85 ( .A(s_fsm_q[0]), .B(s_fsm_q[1]), .C(net23009), 
        .Y(net23043) );
  sky130_fd_sc_hd__and2_0 U86 ( .A(N102), .B(n3), .X(N135) );
  sky130_fd_sc_hd__and2_0 U87 ( .A(N101), .B(n3), .X(N134) );
  sky130_fd_sc_hd__and2_0 U88 ( .A(N100), .B(n3), .X(N133) );
  sky130_fd_sc_hd__and2_0 U89 ( .A(N99), .B(n3), .X(N132) );
  sky130_fd_sc_hd__and2_0 U90 ( .A(N98), .B(n3), .X(N131) );
  sky130_fd_sc_hd__and2_0 U91 ( .A(N97), .B(n3), .X(N130) );
  sky130_fd_sc_hd__and2_0 U92 ( .A(N96), .B(n3), .X(N129) );
  sky130_fd_sc_hd__and2_0 U93 ( .A(N95), .B(n3), .X(N128) );
  sky130_fd_sc_hd__and2_0 U94 ( .A(N94), .B(n3), .X(N127) );
  sky130_fd_sc_hd__and2_0 U95 ( .A(N93), .B(n3), .X(N126) );
  sky130_fd_sc_hd__and2_0 U96 ( .A(N91), .B(n3), .X(N124) );
  sky130_fd_sc_hd__and2_0 U97 ( .A(N90), .B(n3), .X(N123) );
  sky130_fd_sc_hd__and2_0 U98 ( .A(N89), .B(n3), .X(N122) );
  sky130_fd_sc_hd__and2_0 U99 ( .A(N88), .B(n3), .X(N121) );
  sky130_fd_sc_hd__and2_0 U100 ( .A(N87), .B(n3), .X(N120) );
  sky130_fd_sc_hd__and2_0 U101 ( .A(N92), .B(n3), .X(N125) );
  sky130_fd_sc_hd__nor2_1 U102 ( .A(net23064), .B(n49), .Y(N119) );
  sky130_fd_sc_hd__xnor2_1 U103 ( .A(s_reg_bit_cnt_q[0]), .B(cfg_bits_i[0]), 
        .Y(n51) );
  sky130_fd_sc_hd__xnor2_1 U104 ( .A(s_reg_bit_cnt_q[1]), .B(cfg_bits_i[1]), 
        .Y(n50) );
  sky130_fd_sc_hd__nand3_2 U105 ( .A(n50), .B(n51), .C(s_reg_bit_cnt_q[2]), 
        .Y(net23053) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(cfg_en_i), .Y(net23037) );
  sky130_fd_sc_hd__o32ai_1 U107 ( .A1(net18291), .A2(net23015), .A3(n55), .B1(
        net23037), .B2(net23060), .Y(n57) );
  sky130_fd_sc_hd__nand3_1 U108 ( .A(net18291), .B(net23011), .C(net25238), 
        .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U109 ( .A(cfg_parity_en_i), .B(n52), .Y(n60) );
  sky130_fd_sc_hd__nor2_1 U110 ( .A(n7), .B(s_fsm_q[1]), .Y(n53) );
  sky130_fd_sc_hd__nand4_1 U111 ( .A(cfg_stop_bits_i), .B(net31367), .C(
        net25238), .D(n53), .Y(net23057) );
  sky130_fd_sc_hd__o211ai_1 U112 ( .A1(n63), .A2(n56), .B1(n60), .C1(net23056), 
        .Y(n95) );
  sky130_fd_sc_hd__mux2i_1 U113 ( .A0(net23054), .A1(n2), .S(
        s_reg_bit_cnt_q[0]), .Y(n94) );
  sky130_fd_sc_hd__nand2_1 U114 ( .A(net23051), .B(s_reg_bit_cnt_q[1]), .Y(n54) );
  sky130_fd_sc_hd__mux2i_1 U115 ( .A0(n54), .A1(n44), .S(s_reg_bit_cnt_q[2]), 
        .Y(n93) );
  sky130_fd_sc_hd__nor3_1 U116 ( .A(net31367), .B(n56), .C(n4), .Y(n58) );
  sky130_fd_sc_hd__mux2i_1 U117 ( .A0(n58), .A1(n5), .S(s_fsm_q[1]), .Y(n59)
         );
  sky130_fd_sc_hd__nand2_1 U118 ( .A(n59), .B(n60), .Y(n96) );
  sky130_fd_sc_hd__o221ai_1 U119 ( .A1(n63), .A2(net23009), .B1(
        cfg_parity_en_i), .B2(n62), .C1(n61), .Y(n97) );
  sky130_fd_sc_hd__mux2i_1 U120 ( .A0(net23034), .A1(n22), .S(net23023), .Y(
        n90) );
  sky130_fd_sc_hd__nor2_1 U121 ( .A(n23), .B(net23025), .Y(n64) );
  sky130_fd_sc_hd__a221o_1 U122 ( .A1(tx_data_i[6]), .A2(net23022), .B1(
        \s_reg_data_q[7] ), .B2(net23021), .C1(n64), .X(n89) );
  sky130_fd_sc_hd__nor2_1 U123 ( .A(n20), .B(net23025), .Y(n65) );
  sky130_fd_sc_hd__a221o_1 U124 ( .A1(tx_data_i[5]), .A2(net23022), .B1(n21), 
        .B2(net23021), .C1(n65), .X(n88) );
  sky130_fd_sc_hd__nor2_1 U125 ( .A(n18), .B(net23025), .Y(n66) );
  sky130_fd_sc_hd__a221o_1 U126 ( .A1(tx_data_i[4]), .A2(net23022), .B1(n19), 
        .B2(net23021), .C1(n66), .X(n87) );
  sky130_fd_sc_hd__nor2_1 U127 ( .A(net28433), .B(net23025), .Y(n67) );
  sky130_fd_sc_hd__a221o_1 U128 ( .A1(tx_data_i[3]), .A2(net23022), .B1(n17), 
        .B2(net23021), .C1(n67), .X(n86) );
  sky130_fd_sc_hd__nor2_1 U129 ( .A(n29), .B(net23019), .Y(n68) );
  sky130_fd_sc_hd__mux2i_1 U130 ( .A0(n68), .A1(n29), .S(s_parity_bit_q), .Y(
        n70) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(s_parity_bit_q), .Y(n69) );
  sky130_fd_sc_hd__o22ai_1 U132 ( .A1(n70), .A2(net23015), .B1(net23016), .B2(
        n69), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U133 ( .A1(net23011), .A2(n71), .B1(s_parity_bit_q), 
        .B2(net23013), .Y(n72) );
  sky130_fd_sc_hd__nand3_1 U134 ( .A(net25199), .B(net23009), .C(n72), .Y(tx_o) );
endmodule


module dffr_DATA_WIDTH6_2 ( clk_i, rst_n_i, dat_i, dat_o );
  input [5:0] dat_i;
  output [5:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
endmodule


module dffr_DATA_WIDTH6_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [5:0] dat_i;
  output [5:0] dat_o;
  input clk_i, rst_n_i;


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


module dffr_DATA_WIDTH7_1 ( clk_i, rst_n_i, dat_i, dat_o );
  input [6:0] dat_i;
  output [6:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
endmodule


module dffr_DATA_WIDTH576 ( clk_i, rst_n_i, dat_i, dat_o );
  input [575:0] dat_i;
  output [575:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_575_ ( .D(dat_i[575]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[575]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_574_ ( .D(dat_i[574]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[574]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_573_ ( .D(dat_i[573]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[573]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_572_ ( .D(dat_i[572]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[572]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_571_ ( .D(dat_i[571]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[571]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_570_ ( .D(dat_i[570]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[570]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_569_ ( .D(dat_i[569]), .CLK(clk_i), 
        .RESET_B(n10), .Q(dat_o[569]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_568_ ( .D(dat_i[568]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[568]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_567_ ( .D(dat_i[567]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[567]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_566_ ( .D(dat_i[566]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[566]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_565_ ( .D(dat_i[565]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[565]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_564_ ( .D(dat_i[564]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[564]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_563_ ( .D(dat_i[563]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[563]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_562_ ( .D(dat_i[562]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[562]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_561_ ( .D(dat_i[561]), .CLK(clk_i), 
        .RESET_B(n5), .Q(dat_o[561]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_560_ ( .D(dat_i[560]), .CLK(clk_i), 
        .RESET_B(n4), .Q(dat_o[560]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_559_ ( .D(dat_i[559]), .CLK(clk_i), 
        .RESET_B(n2), .Q(dat_o[559]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_558_ ( .D(dat_i[558]), .CLK(clk_i), 
        .RESET_B(n1), .Q(dat_o[558]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_557_ ( .D(dat_i[557]), .CLK(clk_i), 
        .RESET_B(n10), .Q(dat_o[557]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_556_ ( .D(dat_i[556]), .CLK(clk_i), 
        .RESET_B(n6), .Q(dat_o[556]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_555_ ( .D(dat_i[555]), .CLK(clk_i), 
        .RESET_B(n7), .Q(dat_o[555]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_554_ ( .D(dat_i[554]), .CLK(clk_i), 
        .RESET_B(n8), .Q(dat_o[554]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_553_ ( .D(dat_i[553]), .CLK(clk_i), 
        .RESET_B(n10), .Q(dat_o[553]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_552_ ( .D(dat_i[552]), .CLK(clk_i), 
        .RESET_B(n9), .Q(dat_o[552]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_551_ ( .D(dat_i[551]), .CLK(clk_i), 
        .RESET_B(n11), .Q(dat_o[551]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_550_ ( .D(dat_i[550]), .CLK(clk_i), 
        .RESET_B(n3), .Q(dat_o[550]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_549_ ( .D(dat_i[549]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[549]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_548_ ( .D(dat_i[548]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[548]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_547_ ( .D(dat_i[547]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[547]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_546_ ( .D(dat_i[546]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[546]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_545_ ( .D(dat_i[545]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[545]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_544_ ( .D(dat_i[544]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[544]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_543_ ( .D(dat_i[543]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[543]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_542_ ( .D(dat_i[542]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[542]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_541_ ( .D(dat_i[541]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[541]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_540_ ( .D(dat_i[540]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[540]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_539_ ( .D(dat_i[539]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[539]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_538_ ( .D(dat_i[538]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[538]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_537_ ( .D(dat_i[537]), .CLK(clk_i), 
        .RESET_B(n12), .Q(dat_o[537]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_536_ ( .D(dat_i[536]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[536]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_535_ ( .D(dat_i[535]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[535]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_534_ ( .D(dat_i[534]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[534]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_533_ ( .D(dat_i[533]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[533]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_532_ ( .D(dat_i[532]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[532]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_531_ ( .D(dat_i[531]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[531]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_530_ ( .D(dat_i[530]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[530]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_529_ ( .D(dat_i[529]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[529]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_528_ ( .D(dat_i[528]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[528]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_527_ ( .D(dat_i[527]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[527]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_526_ ( .D(dat_i[526]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[526]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_525_ ( .D(dat_i[525]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[525]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_524_ ( .D(dat_i[524]), .CLK(clk_i), 
        .RESET_B(n13), .Q(dat_o[524]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_523_ ( .D(dat_i[523]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[523]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_522_ ( .D(dat_i[522]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[522]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_521_ ( .D(dat_i[521]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[521]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_520_ ( .D(dat_i[520]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[520]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_519_ ( .D(dat_i[519]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[519]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_518_ ( .D(dat_i[518]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[518]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_517_ ( .D(dat_i[517]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[517]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_516_ ( .D(dat_i[516]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[516]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_515_ ( .D(dat_i[515]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[515]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_514_ ( .D(dat_i[514]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[514]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_513_ ( .D(dat_i[513]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[513]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_512_ ( .D(dat_i[512]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[512]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_511_ ( .D(dat_i[511]), .CLK(clk_i), 
        .RESET_B(n14), .Q(dat_o[511]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_510_ ( .D(dat_i[510]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[510]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_509_ ( .D(dat_i[509]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[509]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_508_ ( .D(dat_i[508]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[508]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_507_ ( .D(dat_i[507]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[507]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_506_ ( .D(dat_i[506]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[506]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_505_ ( .D(dat_i[505]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[505]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_504_ ( .D(dat_i[504]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[504]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_503_ ( .D(dat_i[503]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[503]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_502_ ( .D(dat_i[502]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[502]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_501_ ( .D(dat_i[501]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[501]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_500_ ( .D(dat_i[500]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[500]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_499_ ( .D(dat_i[499]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[499]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_498_ ( .D(dat_i[498]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[498]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_497_ ( .D(dat_i[497]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[497]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_496_ ( .D(dat_i[496]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[496]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_495_ ( .D(dat_i[495]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[495]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_494_ ( .D(dat_i[494]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[494]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_493_ ( .D(dat_i[493]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[493]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_492_ ( .D(dat_i[492]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[492]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_491_ ( .D(dat_i[491]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[491]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_490_ ( .D(dat_i[490]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[490]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_489_ ( .D(dat_i[489]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[489]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_488_ ( .D(dat_i[488]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[488]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_487_ ( .D(dat_i[487]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[487]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_486_ ( .D(dat_i[486]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[486]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_485_ ( .D(dat_i[485]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[485]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_484_ ( .D(dat_i[484]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[484]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_483_ ( .D(dat_i[483]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[483]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_482_ ( .D(dat_i[482]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[482]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_481_ ( .D(dat_i[481]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[481]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_480_ ( .D(dat_i[480]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[480]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_479_ ( .D(dat_i[479]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[479]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_478_ ( .D(dat_i[478]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[478]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_477_ ( .D(dat_i[477]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[477]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_476_ ( .D(dat_i[476]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[476]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_475_ ( .D(dat_i[475]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[475]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_474_ ( .D(dat_i[474]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[474]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_473_ ( .D(dat_i[473]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[473]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_472_ ( .D(dat_i[472]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[472]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_471_ ( .D(dat_i[471]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[471]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_470_ ( .D(dat_i[470]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[470]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_469_ ( .D(dat_i[469]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[469]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_468_ ( .D(dat_i[468]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[468]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_467_ ( .D(dat_i[467]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[467]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_466_ ( .D(dat_i[466]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[466]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_465_ ( .D(dat_i[465]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[465]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_464_ ( .D(dat_i[464]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[464]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_463_ ( .D(dat_i[463]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[463]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_462_ ( .D(dat_i[462]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[462]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_461_ ( .D(dat_i[461]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[461]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_460_ ( .D(dat_i[460]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[460]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_459_ ( .D(dat_i[459]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[459]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_458_ ( .D(dat_i[458]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[458]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_457_ ( .D(dat_i[457]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[457]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_456_ ( .D(dat_i[456]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[456]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_455_ ( .D(dat_i[455]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[455]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_454_ ( .D(dat_i[454]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[454]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_453_ ( .D(dat_i[453]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[453]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_452_ ( .D(dat_i[452]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[452]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_451_ ( .D(dat_i[451]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[451]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_450_ ( .D(dat_i[450]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[450]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_449_ ( .D(dat_i[449]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[449]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_448_ ( .D(dat_i[448]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[448]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_447_ ( .D(dat_i[447]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[447]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_446_ ( .D(dat_i[446]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[446]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_445_ ( .D(dat_i[445]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[445]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_444_ ( .D(dat_i[444]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[444]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_443_ ( .D(dat_i[443]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[443]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_442_ ( .D(dat_i[442]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[442]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_441_ ( .D(dat_i[441]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[441]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_440_ ( .D(dat_i[440]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[440]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_439_ ( .D(dat_i[439]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[439]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_438_ ( .D(dat_i[438]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[438]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_437_ ( .D(dat_i[437]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[437]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_436_ ( .D(dat_i[436]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[436]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_435_ ( .D(dat_i[435]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[435]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_434_ ( .D(dat_i[434]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[434]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_433_ ( .D(dat_i[433]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[433]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_432_ ( .D(dat_i[432]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[432]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_431_ ( .D(dat_i[431]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[431]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_430_ ( .D(dat_i[430]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[430]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_429_ ( .D(dat_i[429]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[429]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_428_ ( .D(dat_i[428]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[428]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_427_ ( .D(dat_i[427]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[427]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_426_ ( .D(dat_i[426]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[426]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_425_ ( .D(dat_i[425]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[425]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_424_ ( .D(dat_i[424]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[424]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_423_ ( .D(dat_i[423]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[423]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_422_ ( .D(dat_i[422]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[422]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_421_ ( .D(dat_i[421]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[421]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_420_ ( .D(dat_i[420]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[420]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_419_ ( .D(dat_i[419]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[419]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_418_ ( .D(dat_i[418]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[418]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_417_ ( .D(dat_i[417]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[417]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_416_ ( .D(dat_i[416]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[416]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_415_ ( .D(dat_i[415]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[415]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_414_ ( .D(dat_i[414]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[414]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_413_ ( .D(dat_i[413]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[413]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_412_ ( .D(dat_i[412]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[412]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_411_ ( .D(dat_i[411]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[411]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_410_ ( .D(dat_i[410]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[410]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_409_ ( .D(dat_i[409]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[409]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_408_ ( .D(dat_i[408]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[408]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_407_ ( .D(dat_i[407]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[407]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_406_ ( .D(dat_i[406]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[406]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_405_ ( .D(dat_i[405]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[405]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_404_ ( .D(dat_i[404]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[404]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_403_ ( .D(dat_i[403]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[403]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_402_ ( .D(dat_i[402]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[402]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_401_ ( .D(dat_i[401]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[401]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_400_ ( .D(dat_i[400]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[400]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_399_ ( .D(dat_i[399]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[399]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_398_ ( .D(dat_i[398]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[398]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_397_ ( .D(dat_i[397]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[397]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_396_ ( .D(dat_i[396]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[396]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_395_ ( .D(dat_i[395]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[395]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_394_ ( .D(dat_i[394]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[394]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_393_ ( .D(dat_i[393]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[393]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_392_ ( .D(dat_i[392]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[392]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_391_ ( .D(dat_i[391]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[391]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_390_ ( .D(dat_i[390]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[390]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_389_ ( .D(dat_i[389]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[389]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_388_ ( .D(dat_i[388]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[388]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_387_ ( .D(dat_i[387]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[387]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_386_ ( .D(dat_i[386]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[386]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_385_ ( .D(dat_i[385]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[385]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_384_ ( .D(dat_i[384]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[384]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_383_ ( .D(dat_i[383]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[383]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_382_ ( .D(dat_i[382]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[382]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_381_ ( .D(dat_i[381]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[381]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_380_ ( .D(dat_i[380]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[380]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_379_ ( .D(dat_i[379]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[379]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_378_ ( .D(dat_i[378]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[378]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_377_ ( .D(dat_i[377]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[377]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_376_ ( .D(dat_i[376]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[376]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_375_ ( .D(dat_i[375]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[375]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_374_ ( .D(dat_i[374]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[374]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_373_ ( .D(dat_i[373]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[373]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_372_ ( .D(dat_i[372]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[372]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_371_ ( .D(dat_i[371]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[371]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_370_ ( .D(dat_i[370]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[370]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_369_ ( .D(dat_i[369]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[369]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_368_ ( .D(dat_i[368]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[368]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_367_ ( .D(dat_i[367]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[367]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_366_ ( .D(dat_i[366]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[366]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_365_ ( .D(dat_i[365]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[365]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_364_ ( .D(dat_i[364]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[364]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_363_ ( .D(dat_i[363]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[363]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_362_ ( .D(dat_i[362]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[362]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_361_ ( .D(dat_i[361]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[361]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_360_ ( .D(dat_i[360]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[360]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_359_ ( .D(dat_i[359]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[359]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_358_ ( .D(dat_i[358]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[358]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_357_ ( .D(dat_i[357]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[357]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_356_ ( .D(dat_i[356]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[356]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_355_ ( .D(dat_i[355]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[355]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_354_ ( .D(dat_i[354]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[354]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_353_ ( .D(dat_i[353]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[353]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_352_ ( .D(dat_i[352]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[352]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_351_ ( .D(dat_i[351]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[351]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_350_ ( .D(dat_i[350]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[350]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_349_ ( .D(dat_i[349]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[349]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_348_ ( .D(dat_i[348]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[348]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_347_ ( .D(dat_i[347]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[347]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_346_ ( .D(dat_i[346]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[346]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_345_ ( .D(dat_i[345]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[345]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_344_ ( .D(dat_i[344]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[344]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_343_ ( .D(dat_i[343]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[343]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_342_ ( .D(dat_i[342]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[342]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_341_ ( .D(dat_i[341]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[341]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_340_ ( .D(dat_i[340]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[340]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_339_ ( .D(dat_i[339]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[339]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_338_ ( .D(dat_i[338]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[338]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_337_ ( .D(dat_i[337]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[337]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_336_ ( .D(dat_i[336]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[336]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_335_ ( .D(dat_i[335]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[335]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_334_ ( .D(dat_i[334]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[334]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_333_ ( .D(dat_i[333]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[333]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_332_ ( .D(dat_i[332]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[332]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_331_ ( .D(dat_i[331]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[331]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_330_ ( .D(dat_i[330]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[330]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_329_ ( .D(dat_i[329]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[329]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_328_ ( .D(dat_i[328]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[328]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_327_ ( .D(dat_i[327]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[327]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_326_ ( .D(dat_i[326]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[326]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_325_ ( .D(dat_i[325]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[325]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_324_ ( .D(dat_i[324]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[324]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_323_ ( .D(dat_i[323]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[323]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_322_ ( .D(dat_i[322]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[322]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_321_ ( .D(dat_i[321]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[321]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_320_ ( .D(dat_i[320]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[320]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_319_ ( .D(dat_i[319]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[319]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_318_ ( .D(dat_i[318]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[318]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_317_ ( .D(dat_i[317]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[317]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_316_ ( .D(dat_i[316]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[316]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_315_ ( .D(dat_i[315]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[315]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_314_ ( .D(dat_i[314]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[314]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_313_ ( .D(dat_i[313]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[313]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_312_ ( .D(dat_i[312]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[312]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_311_ ( .D(dat_i[311]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[311]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_310_ ( .D(dat_i[310]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[310]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_309_ ( .D(dat_i[309]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[309]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_308_ ( .D(dat_i[308]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[308]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_307_ ( .D(dat_i[307]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[307]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_306_ ( .D(dat_i[306]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[306]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_305_ ( .D(dat_i[305]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[305]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_304_ ( .D(dat_i[304]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[304]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_303_ ( .D(dat_i[303]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[303]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_302_ ( .D(dat_i[302]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[302]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_301_ ( .D(dat_i[301]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[301]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_300_ ( .D(dat_i[300]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[300]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_299_ ( .D(dat_i[299]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[299]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_298_ ( .D(dat_i[298]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[298]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_297_ ( .D(dat_i[297]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[297]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_296_ ( .D(dat_i[296]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[296]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_295_ ( .D(dat_i[295]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[295]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_294_ ( .D(dat_i[294]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[294]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_293_ ( .D(dat_i[293]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[293]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_292_ ( .D(dat_i[292]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[292]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_291_ ( .D(dat_i[291]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[291]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_290_ ( .D(dat_i[290]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[290]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_289_ ( .D(dat_i[289]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[289]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_288_ ( .D(dat_i[288]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[288]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_287_ ( .D(dat_i[287]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[287]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_286_ ( .D(dat_i[286]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[286]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_285_ ( .D(dat_i[285]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[285]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_284_ ( .D(dat_i[284]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[284]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_283_ ( .D(dat_i[283]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[283]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_282_ ( .D(dat_i[282]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[282]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_281_ ( .D(dat_i[281]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[281]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_280_ ( .D(dat_i[280]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[280]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_279_ ( .D(dat_i[279]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[279]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_278_ ( .D(dat_i[278]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[278]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_277_ ( .D(dat_i[277]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[277]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_276_ ( .D(dat_i[276]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[276]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_275_ ( .D(dat_i[275]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[275]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_274_ ( .D(dat_i[274]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[274]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_273_ ( .D(dat_i[273]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[273]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_272_ ( .D(dat_i[272]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[272]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_271_ ( .D(dat_i[271]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[271]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_270_ ( .D(dat_i[270]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[270]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_269_ ( .D(dat_i[269]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[269]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_268_ ( .D(dat_i[268]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[268]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_267_ ( .D(dat_i[267]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[267]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_266_ ( .D(dat_i[266]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[266]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_265_ ( .D(dat_i[265]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[265]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_264_ ( .D(dat_i[264]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[264]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_263_ ( .D(dat_i[263]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[263]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_262_ ( .D(dat_i[262]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[262]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_261_ ( .D(dat_i[261]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[261]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_260_ ( .D(dat_i[260]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[260]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_259_ ( .D(dat_i[259]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[259]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_258_ ( .D(dat_i[258]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[258]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_257_ ( .D(dat_i[257]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[257]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_256_ ( .D(dat_i[256]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[256]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_255_ ( .D(dat_i[255]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[255]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_254_ ( .D(dat_i[254]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[254]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_253_ ( .D(dat_i[253]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[253]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_252_ ( .D(dat_i[252]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[252]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_251_ ( .D(dat_i[251]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[251]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_250_ ( .D(dat_i[250]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[250]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_249_ ( .D(dat_i[249]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[249]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_248_ ( .D(dat_i[248]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[248]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_247_ ( .D(dat_i[247]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[247]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_246_ ( .D(dat_i[246]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[246]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_245_ ( .D(dat_i[245]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[245]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_244_ ( .D(dat_i[244]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[244]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_243_ ( .D(dat_i[243]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[243]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_242_ ( .D(dat_i[242]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[242]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_241_ ( .D(dat_i[241]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[241]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_240_ ( .D(dat_i[240]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[240]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_239_ ( .D(dat_i[239]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[239]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_238_ ( .D(dat_i[238]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[238]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_237_ ( .D(dat_i[237]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[237]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_236_ ( .D(dat_i[236]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[236]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_235_ ( .D(dat_i[235]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[235]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_234_ ( .D(dat_i[234]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[234]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_233_ ( .D(dat_i[233]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[233]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_232_ ( .D(dat_i[232]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[232]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_231_ ( .D(dat_i[231]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[231]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_230_ ( .D(dat_i[230]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[230]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_229_ ( .D(dat_i[229]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[229]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_228_ ( .D(dat_i[228]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[228]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_227_ ( .D(dat_i[227]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[227]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_226_ ( .D(dat_i[226]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[226]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_225_ ( .D(dat_i[225]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[225]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_224_ ( .D(dat_i[224]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[224]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_223_ ( .D(dat_i[223]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[223]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_222_ ( .D(dat_i[222]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[222]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_221_ ( .D(dat_i[221]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[221]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_220_ ( .D(dat_i[220]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[220]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_219_ ( .D(dat_i[219]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[219]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_218_ ( .D(dat_i[218]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[218]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_217_ ( .D(dat_i[217]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[217]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_216_ ( .D(dat_i[216]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[216]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_215_ ( .D(dat_i[215]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[215]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_214_ ( .D(dat_i[214]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[214]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_213_ ( .D(dat_i[213]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[213]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_212_ ( .D(dat_i[212]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[212]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_211_ ( .D(dat_i[211]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[211]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_210_ ( .D(dat_i[210]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[210]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_209_ ( .D(dat_i[209]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[209]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_208_ ( .D(dat_i[208]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[208]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_207_ ( .D(dat_i[207]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[207]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_206_ ( .D(dat_i[206]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[206]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_205_ ( .D(dat_i[205]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[205]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_204_ ( .D(dat_i[204]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[204]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_203_ ( .D(dat_i[203]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[203]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_202_ ( .D(dat_i[202]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[202]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_201_ ( .D(dat_i[201]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[201]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_200_ ( .D(dat_i[200]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[200]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_199_ ( .D(dat_i[199]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[199]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_198_ ( .D(dat_i[198]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[198]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_197_ ( .D(dat_i[197]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[197]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_196_ ( .D(dat_i[196]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[196]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_195_ ( .D(dat_i[195]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[195]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_194_ ( .D(dat_i[194]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[194]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_193_ ( .D(dat_i[193]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[193]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_192_ ( .D(dat_i[192]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[192]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_191_ ( .D(dat_i[191]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[191]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_190_ ( .D(dat_i[190]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[190]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_189_ ( .D(dat_i[189]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[189]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_188_ ( .D(dat_i[188]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[188]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_187_ ( .D(dat_i[187]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[187]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_186_ ( .D(dat_i[186]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[186]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_185_ ( .D(dat_i[185]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[185]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_184_ ( .D(dat_i[184]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[184]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_183_ ( .D(dat_i[183]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[183]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_182_ ( .D(dat_i[182]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[182]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_181_ ( .D(dat_i[181]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[181]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_180_ ( .D(dat_i[180]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[180]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_179_ ( .D(dat_i[179]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[179]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_178_ ( .D(dat_i[178]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[178]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_177_ ( .D(dat_i[177]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[177]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_176_ ( .D(dat_i[176]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[176]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_175_ ( .D(dat_i[175]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[175]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_174_ ( .D(dat_i[174]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[174]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_173_ ( .D(dat_i[173]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[173]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_172_ ( .D(dat_i[172]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[172]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_171_ ( .D(dat_i[171]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[171]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_170_ ( .D(dat_i[170]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[170]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_169_ ( .D(dat_i[169]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[169]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_168_ ( .D(dat_i[168]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[168]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_167_ ( .D(dat_i[167]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[167]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_166_ ( .D(dat_i[166]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[166]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_165_ ( .D(dat_i[165]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[165]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_164_ ( .D(dat_i[164]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[164]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_163_ ( .D(dat_i[163]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[163]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_162_ ( .D(dat_i[162]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[162]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_161_ ( .D(dat_i[161]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[161]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_160_ ( .D(dat_i[160]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[160]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_159_ ( .D(dat_i[159]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[159]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_158_ ( .D(dat_i[158]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[158]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_157_ ( .D(dat_i[157]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[157]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_156_ ( .D(dat_i[156]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[156]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_155_ ( .D(dat_i[155]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[155]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_154_ ( .D(dat_i[154]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[154]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_153_ ( .D(dat_i[153]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[153]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_152_ ( .D(dat_i[152]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[152]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_151_ ( .D(dat_i[151]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[151]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_150_ ( .D(dat_i[150]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[150]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_149_ ( .D(dat_i[149]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[149]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_148_ ( .D(dat_i[148]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[148]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_147_ ( .D(dat_i[147]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[147]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_146_ ( .D(dat_i[146]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[146]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_145_ ( .D(dat_i[145]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[145]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_144_ ( .D(dat_i[144]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[144]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_143_ ( .D(dat_i[143]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[143]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_142_ ( .D(dat_i[142]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[142]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_141_ ( .D(dat_i[141]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[141]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_140_ ( .D(dat_i[140]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[140]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_139_ ( .D(dat_i[139]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[139]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_138_ ( .D(dat_i[138]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[138]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_137_ ( .D(dat_i[137]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[137]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_136_ ( .D(dat_i[136]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[136]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_135_ ( .D(dat_i[135]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[135]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_134_ ( .D(dat_i[134]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[134]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_133_ ( .D(dat_i[133]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[133]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_132_ ( .D(dat_i[132]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[132]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_131_ ( .D(dat_i[131]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[131]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_130_ ( .D(dat_i[130]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[130]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_129_ ( .D(dat_i[129]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[129]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_128_ ( .D(dat_i[128]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[128]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_127_ ( .D(dat_i[127]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[127]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_126_ ( .D(dat_i[126]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[126]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_125_ ( .D(dat_i[125]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[125]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_124_ ( .D(dat_i[124]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[124]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_123_ ( .D(dat_i[123]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[123]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_122_ ( .D(dat_i[122]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[122]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_121_ ( .D(dat_i[121]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[121]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_120_ ( .D(dat_i[120]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[120]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_119_ ( .D(dat_i[119]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[119]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_118_ ( .D(dat_i[118]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[118]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_117_ ( .D(dat_i[117]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[117]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_116_ ( .D(dat_i[116]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[116]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_115_ ( .D(dat_i[115]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[115]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_114_ ( .D(dat_i[114]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[114]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_113_ ( .D(dat_i[113]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[113]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_112_ ( .D(dat_i[112]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[112]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_111_ ( .D(dat_i[111]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[111]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_110_ ( .D(dat_i[110]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[110]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_109_ ( .D(dat_i[109]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[109]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_108_ ( .D(dat_i[108]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[108]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_107_ ( .D(dat_i[107]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[107]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_106_ ( .D(dat_i[106]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[106]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_105_ ( .D(dat_i[105]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[105]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_104_ ( .D(dat_i[104]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[104]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_103_ ( .D(dat_i[103]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[103]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_102_ ( .D(dat_i[102]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[102]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_101_ ( .D(dat_i[101]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[101]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_100_ ( .D(dat_i[100]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[100]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_99_ ( .D(dat_i[99]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[99]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_98_ ( .D(dat_i[98]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[98]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_97_ ( .D(dat_i[97]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[97]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_96_ ( .D(dat_i[96]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[96]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_95_ ( .D(dat_i[95]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[95]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_94_ ( .D(dat_i[94]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[94]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_93_ ( .D(dat_i[93]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[93]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_92_ ( .D(dat_i[92]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[92]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_91_ ( .D(dat_i[91]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[91]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_90_ ( .D(dat_i[90]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[90]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_89_ ( .D(dat_i[89]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[89]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_88_ ( .D(dat_i[88]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[88]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_87_ ( .D(dat_i[87]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[87]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_86_ ( .D(dat_i[86]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[86]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_85_ ( .D(dat_i[85]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[85]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_84_ ( .D(dat_i[84]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[84]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_83_ ( .D(dat_i[83]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[83]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_82_ ( .D(dat_i[82]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[82]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_81_ ( .D(dat_i[81]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[81]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_80_ ( .D(dat_i[80]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[80]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_79_ ( .D(dat_i[79]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[79]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_78_ ( .D(dat_i[78]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[78]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_77_ ( .D(dat_i[77]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[77]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_76_ ( .D(dat_i[76]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[76]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_75_ ( .D(dat_i[75]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[75]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_74_ ( .D(dat_i[74]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[74]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_73_ ( .D(dat_i[73]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[73]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_72_ ( .D(dat_i[72]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[72]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_71_ ( .D(dat_i[71]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[71]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_70_ ( .D(dat_i[70]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[70]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_69_ ( .D(dat_i[69]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[69]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_68_ ( .D(dat_i[68]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[68]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_67_ ( .D(dat_i[67]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[67]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_66_ ( .D(dat_i[66]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[66]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_65_ ( .D(dat_i[65]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[65]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_64_ ( .D(dat_i[64]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[64]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[58]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[52]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[51]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n4), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n2), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n1), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        n11), .Q(dat_o[0]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(n11), .X(n53) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(n11), .X(n52) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(n10), .X(n51) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(n10), .X(n50) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(n10), .X(n49) );
  sky130_fd_sc_hd__buf_1 U8 ( .A(n9), .X(n48) );
  sky130_fd_sc_hd__buf_1 U9 ( .A(n9), .X(n47) );
  sky130_fd_sc_hd__buf_1 U10 ( .A(n9), .X(n46) );
  sky130_fd_sc_hd__buf_1 U11 ( .A(n8), .X(n45) );
  sky130_fd_sc_hd__buf_1 U12 ( .A(n8), .X(n44) );
  sky130_fd_sc_hd__buf_1 U13 ( .A(n8), .X(n43) );
  sky130_fd_sc_hd__buf_1 U14 ( .A(n7), .X(n42) );
  sky130_fd_sc_hd__buf_1 U15 ( .A(n7), .X(n41) );
  sky130_fd_sc_hd__buf_1 U16 ( .A(n7), .X(n40) );
  sky130_fd_sc_hd__buf_1 U17 ( .A(n6), .X(n39) );
  sky130_fd_sc_hd__buf_1 U18 ( .A(n6), .X(n38) );
  sky130_fd_sc_hd__buf_1 U19 ( .A(n6), .X(n37) );
  sky130_fd_sc_hd__buf_1 U20 ( .A(n5), .X(n36) );
  sky130_fd_sc_hd__buf_1 U21 ( .A(n5), .X(n35) );
  sky130_fd_sc_hd__buf_1 U22 ( .A(n5), .X(n34) );
  sky130_fd_sc_hd__buf_1 U23 ( .A(n4), .X(n33) );
  sky130_fd_sc_hd__buf_1 U24 ( .A(n4), .X(n32) );
  sky130_fd_sc_hd__buf_1 U25 ( .A(n4), .X(n31) );
  sky130_fd_sc_hd__buf_1 U26 ( .A(n3), .X(n30) );
  sky130_fd_sc_hd__buf_1 U27 ( .A(n3), .X(n29) );
  sky130_fd_sc_hd__buf_1 U28 ( .A(n3), .X(n28) );
  sky130_fd_sc_hd__buf_1 U29 ( .A(n2), .X(n27) );
  sky130_fd_sc_hd__buf_1 U30 ( .A(n2), .X(n26) );
  sky130_fd_sc_hd__buf_1 U31 ( .A(n2), .X(n25) );
  sky130_fd_sc_hd__buf_1 U32 ( .A(n1), .X(n24) );
  sky130_fd_sc_hd__buf_1 U33 ( .A(n1), .X(n23) );
  sky130_fd_sc_hd__buf_1 U34 ( .A(n1), .X(n22) );
  sky130_fd_sc_hd__buf_1 U35 ( .A(n2), .X(n21) );
  sky130_fd_sc_hd__buf_1 U36 ( .A(n1), .X(n20) );
  sky130_fd_sc_hd__buf_1 U37 ( .A(n3), .X(n19) );
  sky130_fd_sc_hd__buf_1 U38 ( .A(n5), .X(n18) );
  sky130_fd_sc_hd__buf_1 U39 ( .A(n4), .X(n17) );
  sky130_fd_sc_hd__buf_1 U40 ( .A(n3), .X(n16) );
  sky130_fd_sc_hd__buf_1 U41 ( .A(n8), .X(n15) );
  sky130_fd_sc_hd__buf_1 U42 ( .A(n7), .X(n14) );
  sky130_fd_sc_hd__buf_1 U43 ( .A(n6), .X(n13) );
  sky130_fd_sc_hd__buf_1 U44 ( .A(n11), .X(n12) );
  sky130_fd_sc_hd__buf_1 U45 ( .A(rst_n_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U46 ( .A(rst_n_i), .X(n1) );
  sky130_fd_sc_hd__buf_1 U47 ( .A(rst_n_i), .X(n5) );
  sky130_fd_sc_hd__buf_1 U48 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U49 ( .A(rst_n_i), .X(n3) );
  sky130_fd_sc_hd__buf_1 U50 ( .A(rst_n_i), .X(n8) );
  sky130_fd_sc_hd__buf_1 U51 ( .A(rst_n_i), .X(n7) );
  sky130_fd_sc_hd__buf_1 U52 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__buf_1 U53 ( .A(rst_n_i), .X(n11) );
  sky130_fd_sc_hd__buf_1 U54 ( .A(rst_n_i), .X(n10) );
  sky130_fd_sc_hd__buf_1 U55 ( .A(rst_n_i), .X(n9) );
endmodule


module fifo_DATA_WIDTH9_BUFFER_DEPTH64_DW01_inc_3 ( A, SUM );
  input [6:0] A;
  output [6:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n16;
  assign n2 = A[5];
  assign n7 = A[3];
  assign n12 = A[1];
  assign n14 = A[0];

  sky130_fd_sc_hd__xor2_1 U1 ( .A(A[6]), .B(n16), .X(SUM[6]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n3), .B(n4), .Y(SUM[5]) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n6), .B(n5), .X(SUM[4]) );
  sky130_fd_sc_hd__xnor2_1 U10 ( .A(n8), .B(n9), .Y(SUM[3]) );
  sky130_fd_sc_hd__xor2_1 U14 ( .A(n11), .B(n10), .X(SUM[2]) );
  sky130_fd_sc_hd__xnor2_1 U17 ( .A(n14), .B(n13), .Y(SUM[1]) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n12), .B(n14), .Y(n11) );
  sky130_fd_sc_hd__nand2_1 U25 ( .A(n4), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__inv_1 U26 ( .A(n1), .Y(n16) );
  sky130_fd_sc_hd__inv_2 U27 ( .A(n2), .Y(n3) );
  sky130_fd_sc_hd__nand2_2 U28 ( .A(n9), .B(n7), .Y(n6) );
  sky130_fd_sc_hd__nor2_2 U29 ( .A(n10), .B(n11), .Y(n9) );
  sky130_fd_sc_hd__nor2_2 U30 ( .A(n5), .B(n6), .Y(n4) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(A[4]), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U32 ( .A(n12), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(A[2]), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(n14), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U35 ( .A(n7), .Y(n8) );
endmodule


module fifo_DATA_WIDTH9_BUFFER_DEPTH64 ( clk_i, rst_n_i, flush_i, full_o, 
        empty_o, cnt_o, dat_i, push_i, dat_o, pop_i );
  output [6:0] cnt_o;
  input [8:0] dat_i;
  output [8:0] dat_o;
  input clk_i, rst_n_i, flush_i, push_i, pop_i;
  output full_o, empty_o;
  wire   N75, N76, N77, N78, N79, N80, n1438, n1439, n1440, n1441, n1442,
         n1443, N85, N86, N87, N88, N89, N96, N97, N98, N99, N100, N108, N109,
         N110, N111, N112, N113, N114, \add_65/carry[5] , \add_65/carry[4] ,
         \add_65/carry[3] , \add_65/carry[2] , \add_50/carry[5] ,
         \add_50/carry[4] , \add_50/carry[3] , \add_50/carry[2] , n1, n3, n4,
         n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19,
         n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47,
         n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61,
         n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75,
         n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102,
         n103, n106, n107, n108, n109, n110, n111, n112, n113, n114, n115,
         n116, n117, n118, n119, n120, n121, n122, n123, n124, n125, n126,
         n127, n128, n129, n130, n131, n132, n133, n134, n135, n136, n137,
         n138, n139, n140, n141, n142, n143, n144, n145, n146, n147, n148,
         n149, n150, n151, n152, n153, n154, n155, n156, n157, n158, n159,
         n160, n161, n162, n163, n164, n165, n166, n167, n168, n169, n170,
         n171, n172, n173, n174, n175, n176, n177, n178, n179, n180, n181,
         n182, n183, n184, n185, n186, n187, n188, n189, n190, n191, n192,
         n193, n194, n195, n196, n197, n198, n199, n200, n201, n202, n203,
         n204, n205, n206, n207, n208, n209, n210, n211, n212, n213, n214,
         n215, n216, n217, n218, n219, n220, n221, n222, n223, n224, n225,
         n226, n227, n228, n229, n230, n231, n232, n233, n234, n235, n236,
         n237, n238, n239, n240, n241, n242, n243, n244, n245, n246, n247,
         n248, n249, n250, n251, n252, n253, n254, n255, n256, n257, n258,
         n259, n260, n261, n262, n263, n264, n265, n266, n267, n268, n269,
         n270, n271, n272, n273, n274, n275, n276, n277, n278, n279, n280,
         n281, n282, n283, n284, n285, n286, n287, n288, n289, n290, n291,
         n292, n293, n294, n295, n296, n297, n298, n299, n300, n301, n302,
         n303, n304, n305, n306, n307, n308, n309, n310, n311, n312, n313,
         n314, n315, n316, n317, n318, n319, n320, n321, n322, n323, n324,
         n325, n326, n327, n328, n329, n330, n331, n332, n333, n334, n335,
         n336, n337, n338, n339, n340, n341, n342, n343, n344, n345, n346,
         n347, n348, n349, n350, n351, n352, n353, n354, n355, n356, n357,
         n358, n359, n360, n361, n362, n363, n364, n365, n366, n367, n368,
         n369, n370, n371, n372, n373, n374, n375, n376, n377, n378, n379,
         n380, n381, n382, n383, n384, n385, n386, n387, n388, n389, n390,
         n391, n392, n393, n394, n395, n396, n397, n398, n399, n400, n401,
         n402, n403, n404, n405, n406, n407, n408, n409, n410, n411, n412,
         n413, n414, n415, n416, n417, n418, n419, n420, n421, n422, n423,
         n424, n425, n426, n427, n428, n429, n430, n431, n432, n433, n434,
         n435, n436, n437, n438, n439, n440, n441, n442, n443, n444, n445,
         n446, n447, n448, n449, n450, n451, n452, n453, n454, n455, n456,
         n457, n458, n459, n460, n461, n462, n463, n464, n465, n466, n467,
         n468, n469, n470, n471, n472, n473, n474, n475, n476, n477, n478,
         n479, n480, n481, n482, n483, n484, n485, n486, n487, n488, n489,
         n490, n491, n492, n493, n494, n495, n496, n497, n498, n499, n500,
         n501, n502, n503, n504, n505, n506, n507, n508, n509, n510, n511,
         n512, n513, n514, n515, n516, n517, n518, n519, n520, n521, n522,
         n523, n524, n525, n526, n527, n528, n529, n530, n531, n532, n533,
         n534, n535, n536, n537, n538, n539, n540, n541, n542, n543, n544,
         n545, n546, n547, n548, n549, n550, n551, n552, n553, n554, n555,
         n556, n557, n558, n559, n560, n561, n562, n563, n564, n565, n567,
         n568, n569, n570, n573, n575, n576, n577, n578, n579, n580, n581,
         n582, n583, n584, n585, n586, n587, n588, n589, n590, n591, n592,
         n593, n594, n595, n596, n597, n598, n599, n600, n601, n602, n603,
         n604, n605, n606, n607, n608, n609, n610, n611, n612, n613, n614,
         n615, n616, n617, n618, n619, n620, n621, n622, n623, n624, n625,
         n626, n627, n628, n629, n630, n631, n632, n633, n634, n635, n636,
         n637, n638, n639, n640, n641, n642, n643, n644, n645, n646, n647,
         n648, n649, n650, n651, n652, n653, n654, n655, n656, n657, n658,
         n659, n660, n661, n662, n663, n664, n665, n666, n667, n668, n669,
         n670, n671, n672, n673, n674, n675, n676, n677, n678, n679, n680,
         n681, n682, n683, n684, n685, n686, n687, n688, n689, n690, n691,
         n692, n693, n694, n695, n696, n697, n698, n699, n700, n701, n702,
         n703, n704, n705, n706, n707, n708, n709, n710, n711, n712, n713,
         n714, n715, n716, n717, n718, n719, n720, n721, n722, n723, n724,
         n725, n726, n727, n728, n729, n730, n731, n732, n733, n734, n735,
         n736, n737, n738, n739, n740, n741, n742, n743, n744, n745, n746,
         n747, n748, n749, n750, n751, n752, n753, n754, n755, n756, n757,
         n758, n759, n760, n761, n762, n763, n764, n765, n766, n767, n768,
         n769, n770, n771, n772, n773, n774, n775, n776, n777, n778, n779,
         n780, n781, n782, n783, n784, n785, n786, n787, n788, n789, n790,
         n791, n792, n793, n794, n795, n796, n797, n798, n799, n800, n801,
         n802, n803, n804, n805, n806, n807, n808, n809, n810, n811, n812,
         n813, n814, n815, n816, n817, n818, n819, n820, n821, n822, n823,
         n824, n825, n826, n827, n828, n829, n830, n831, n832, n833, n834,
         n835, n836, n837, n838, n839, n840, n841, n842, n843, n844, n845,
         n846, n847, n848, n849, n850, n851, n852, n853, n854, n855, n856,
         n857, n858, n859, n860, n861, n862, n863, n864, n865, n866, n867,
         n868, n869, n870, n871, n872, n873, n874, n875, n876, n877, n878,
         n879, n880, n881, n882, n883, n884, n885, n886, n887, n888, n889,
         n890, n891, n892, n893, n894, n895, n896, n897, n898, n899, n900,
         n901, n902, n903, n904, n905, n906, n907, n908, n909, n910, n911,
         n912, n913, n914, n915, n916, n917, n918, n919, n920, n921, n922,
         n923, n924, n925, n926, n927, n928, n929, n930, n931, n932, n933,
         n934, n935, n936, n937, n938, n939, n940, n941, n942, n943, n944,
         n945, n946, n947, n948, n949, n950, n951, n952, n953, n954, n955,
         n956, n957, n958, n959, n960, n961, n962, n963, n964, n965, n966,
         n967, n968, n969, n970, n971, n972, n973, n974, n975, n976, n977,
         n978, n979, n980, n981, n982, n983, n984, n985, n986, n987, n988,
         n989, n990, n991, n992, n993, n994, n995, n996, n997, n998, n999,
         n1000, n1001, n1002, n1003, n1004, n1005, n1006, n1007, n1008, n1009,
         n1010, n1011, n1012, n1013, n1014, n1015, n1016, n1017, n1018, n1019,
         n1020, n1021, n1022, n1023, n1024, n1025, n1026, n1027, n1028, n1029,
         n1030, n1031, n1032, n1033, n1034, n1035, n1036, n1037, n1038, n1039,
         n1040, n1041, n1042, n1043, n1044, n1045, n1046, n1047, n1048, n1049,
         n1050, n1051, n1052, n1053, n1054, n1055, n1056, n1057, n1058, n1059,
         n1060, n1061, n1062, n1063, n1064, n1065, n1066, n1067, n1068, n1069,
         n1070, n1071, n1072, n1073, n1074, n1075, n1076, n1077, n1078, n1079,
         n1080, n1081, n1082, n1083, n1084, n1085, n1086, n1087, n1088, n1089,
         n1090, n1091, n1092, n1093, n1094, n1095, n1096, n1097, n1098, n1099,
         n1100, n1101, n1102, n1103, n1104, n1105, n1106, n1107, n1108, n1109,
         n1110, n1111, n1112, n1113, n1114, n1115, n1116, n1117, n1118, n1119,
         n1120, n1121, n1122, n1123, n1124, n1125, n1126, n1127, n1128, n1129,
         n1130, n1131, n1132, n1133, n1134, n1135, n1136, n1137, n1138, n1139,
         n1140, n1141, n1142, n1143, n1144, n1145, n1146, n1147, n1148, n1149,
         n1150, n1151, n1152, n1153, n1154, n1155, n1156, n1157, n1158, n1159,
         n1160, n1161, n1162, n1163, n1164, n1165, n1166, n1167, n1168, n1169,
         n1170, n1171, n1172, n1173, n1174, n1175, n1176, n1177, n1178, n1179,
         n1180, n1181, n1182, n1183, n1184, n1185, n1186, n1187, n1188, n1189,
         n1190, n1191, n1192, n1193, n1194, n1195, n1196, n1197, n1198, n1199,
         n1200, n1201, n1202, n1203, n1204, n1205, n1206, n1207, n1208, n1209,
         n1210, n1211, n1212, n1213, n1214, n1215, n1216, n1217, n1218, n1219,
         n1220, n1221, n1222, n1223, n1224, n1225, n1226, n1227, n1228, n1229,
         n1230, n1231, n1232, n1233, n1234, n1235, n1236, n1237, n1238, n1239,
         n1240, n1241, n1242, n1243, n1244, n1245, n1246, n1247, n1248, n1249,
         n1250, n1251, n1252, n1253, n1254, n1255, n1256, n1257, n1258, n1259,
         n1260, n1261, n1262, n1263, n1264, n1265, n1266, n1267, n1268, n1269,
         n1270, n1271, n1272, n1273, n1274, n1275, n1276, n1277, n1278, n1279,
         n1280, n1281, n1282, n1283, n1284, n1285, n1286, n1287, n1288, n1289,
         n1290, n1291, n1292, n1293, n1294, n1295, n1296, n1297, n1298, n1299,
         n1300, n1301, n1302, n1303, n1304, n1305, n1306, n1307, n1308, n1309,
         n1310, n1311, n1312, n1313, n1314, n1315, n1316, n1317, n1318, n1319,
         n1320, n1321, n1322, n1323, n1324, n1325, n1326, n1327, n1328, n1329,
         n1330, n1331, n1332, n1333, n1334, n1335, n1336, n1337, n1338, n1339,
         n1340, n1341, n1342, n1343, n1344, n1345, n1346, n1347, n1348, n1349,
         n1350, n1351, n1352, n1353, n1354, n1355, n1356, n1357, n1358, n1359,
         n1360, n1361, n1362, n1363, n1364, n1365, n1366, n1367, n1368, n1369,
         n1370, n1371, n1372, n1373, n1374, n1375, n1376, n1377, n1378, n1379,
         n1380, n1381, n1382, n1383, n1384, n1385, n1386, n1387, n1388, n1389,
         n1390, n1391, n1392, n1393, n1394, n1395, n1396, n1397, n1398, n1399,
         n1400, n1401, n1402, n1403, n1404, n1405, n1406, n1407, n1408, n1409,
         n1410, n1411, n1412, n1413, n1414, n1415, n1416, n1417, n1418, n1419,
         n1420, n1421, n1422, n1423, n1424, n1425, n1426, n1427, n1428, n1429,
         n1430, n1431, n1432, n1433, n1434, n1435, n1436;
  wire   [575:0] s_mem_q;
  wire   [5:0] s_rd_ptr_d;
  wire   [5:0] s_wr_ptr_d;
  wire   [5:0] s_wr_ptr_q;
  wire   [6:0] s_cnt_d;
  wire   [575:0] s_mem_d;

  dffr_DATA_WIDTH6_2 u_rd_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_rd_ptr_d), .dat_o({N80, N79, N78, N77, N76, N75}) );
  dffr_DATA_WIDTH6_1 u_wr_ptr_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_wr_ptr_d), .dat_o(s_wr_ptr_q) );
  dffr_DATA_WIDTH7_1 u_cnt_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_cnt_d), .dat_o({n1438, n1439, n1440, n1441, n1442, cnt_o[1], n1443})
         );
  dffr_DATA_WIDTH576 u_mem_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_mem_d), .dat_o(s_mem_q) );
  fifo_DATA_WIDTH9_BUFFER_DEPTH64_DW01_inc_3 add_81 ( .A({cnt_o[6:3], n106, 
        n103, cnt_o[0]}), .SUM({N114, N113, N112, N111, N110, N109, N108}) );
  sky130_fd_sc_hd__ha_2 \add_50/U1_1_1  ( .A(N76), .B(N75), .COUT(
        \add_50/carry[2] ), .SUM(N85) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_4  ( .A(s_wr_ptr_q[4]), .B(
        \add_65/carry[4] ), .COUT(\add_65/carry[5] ), .SUM(N99) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_3  ( .A(s_wr_ptr_q[3]), .B(
        \add_65/carry[3] ), .COUT(\add_65/carry[4] ), .SUM(N98) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_2  ( .A(s_wr_ptr_q[2]), .B(
        \add_65/carry[2] ), .COUT(\add_65/carry[3] ), .SUM(N97) );
  sky130_fd_sc_hd__ha_1 \add_65/U1_1_1  ( .A(s_wr_ptr_q[1]), .B(s_wr_ptr_q[0]), 
        .COUT(\add_65/carry[2] ), .SUM(N96) );
  sky130_fd_sc_hd__ha_2 \add_50/U1_1_4  ( .A(N79), .B(\add_50/carry[4] ), 
        .COUT(\add_50/carry[5] ), .SUM(N88) );
  sky130_fd_sc_hd__ha_1 \add_50/U1_1_3  ( .A(N78), .B(\add_50/carry[3] ), 
        .COUT(\add_50/carry[4] ), .SUM(N87) );
  sky130_fd_sc_hd__ha_1 \add_50/U1_1_2  ( .A(N77), .B(\add_50/carry[2] ), 
        .COUT(\add_50/carry[3] ), .SUM(N86) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(n1442), .Y(n1) );
  sky130_fd_sc_hd__inv_1 U4 ( .A(n1), .Y(cnt_o[2]) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n1314), .Y(n1398) );
  sky130_fd_sc_hd__clkinv_2 U6 ( .A(n1118), .Y(n1200) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n1020), .Y(n1106) );
  sky130_fd_sc_hd__clkinv_2 U8 ( .A(n922), .Y(n1006) );
  sky130_fd_sc_hd__clkinv_2 U9 ( .A(n734), .Y(n818) );
  sky130_fd_sc_hd__clkinv_2 U10 ( .A(n719), .Y(n1399) );
  sky130_fd_sc_hd__clkinv_2 U11 ( .A(n706), .Y(n1386) );
  sky130_fd_sc_hd__clkinv_2 U12 ( .A(n692), .Y(n1374) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n669), .Y(n1351) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(n645), .Y(n1327) );
  sky130_fd_sc_hd__inv_2 U15 ( .A(n632), .Y(n1315) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(n631), .Y(n720) );
  sky130_fd_sc_hd__nor2_1 U17 ( .A(N79), .B(N80), .Y(n524) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(n565), .Y(cnt_o[6]) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(n1436), .Y(n622) );
  sky130_fd_sc_hd__a22o_1 U20 ( .A1(n1433), .A2(n1430), .B1(n591), .B2(n1401), 
        .X(n621) );
  sky130_fd_sc_hd__inv_2 U21 ( .A(n590), .Y(n629) );
  sky130_fd_sc_hd__nand2_2 U22 ( .A(n1106), .B(n20), .Y(n1077) );
  sky130_fd_sc_hd__nand2_2 U23 ( .A(n1106), .B(n1315), .Y(n1031) );
  sky130_fd_sc_hd__nand2_2 U24 ( .A(n1006), .B(n20), .Y(n977) );
  sky130_fd_sc_hd__nand2_2 U25 ( .A(n1006), .B(n1315), .Y(n932) );
  sky130_fd_sc_hd__nand2_2 U26 ( .A(n818), .B(n1315), .Y(n744) );
  sky130_fd_sc_hd__nand2_2 U27 ( .A(n720), .B(n20), .Y(n690) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n534), .B(N80), .Y(n497) );
  sky130_fd_sc_hd__nor2_1 U29 ( .A(n535), .B(N79), .Y(n486) );
  sky130_fd_sc_hd__nor2_1 U30 ( .A(n535), .B(n534), .Y(n475) );
  sky130_fd_sc_hd__nor2_1 U31 ( .A(n533), .B(N78), .Y(n107) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(pop_i), .B(n1434), .Y(n591) );
  sky130_fd_sc_hd__clkbuf_1 U33 ( .A(n1441), .X(cnt_o[3]) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(N77), .Y(n533) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(n1419), .Y(n1400) );
  sky130_fd_sc_hd__inv_2 U36 ( .A(n1396), .Y(n1387) );
  sky130_fd_sc_hd__inv_2 U37 ( .A(n1384), .Y(n1375) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(n1372), .Y(n1363) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(n1361), .Y(n1352) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(n1349), .Y(n1340) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(n1337), .Y(n1328) );
  sky130_fd_sc_hd__inv_2 U42 ( .A(n1325), .Y(n1316) );
  sky130_fd_sc_hd__inv_2 U43 ( .A(n1302), .Y(n1313) );
  sky130_fd_sc_hd__inv_2 U44 ( .A(n1311), .Y(n1301) );
  sky130_fd_sc_hd__inv_2 U45 ( .A(n1288), .Y(n1299) );
  sky130_fd_sc_hd__inv_2 U46 ( .A(n1297), .Y(n1287) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(n1275), .Y(n1286) );
  sky130_fd_sc_hd__inv_2 U48 ( .A(n1284), .Y(n1274) );
  sky130_fd_sc_hd__inv_2 U49 ( .A(n1262), .Y(n1273) );
  sky130_fd_sc_hd__inv_2 U50 ( .A(n1271), .Y(n1261) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n1259), .Y(n1250) );
  sky130_fd_sc_hd__inv_2 U52 ( .A(n1248), .Y(n1239) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n1237), .Y(n1228) );
  sky130_fd_sc_hd__inv_2 U54 ( .A(n1216), .Y(n1227) );
  sky130_fd_sc_hd__inv_2 U55 ( .A(n1225), .Y(n1215) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(n1202), .Y(n1213) );
  sky130_fd_sc_hd__clkinv_1 U57 ( .A(n1211), .Y(n1201) );
  sky130_fd_sc_hd__clkinv_1 U58 ( .A(n1198), .Y(n1189) );
  sky130_fd_sc_hd__clkinv_1 U59 ( .A(n1187), .Y(n1178) );
  sky130_fd_sc_hd__inv_2 U60 ( .A(n1166), .Y(n1177) );
  sky130_fd_sc_hd__inv_2 U61 ( .A(n1175), .Y(n1165) );
  sky130_fd_sc_hd__inv_2 U62 ( .A(n1163), .Y(n1154) );
  sky130_fd_sc_hd__inv_2 U63 ( .A(n1152), .Y(n1143) );
  sky130_fd_sc_hd__inv_2 U64 ( .A(n1141), .Y(n1132) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(n1120), .Y(n1131) );
  sky130_fd_sc_hd__inv_2 U66 ( .A(n1129), .Y(n1119) );
  sky130_fd_sc_hd__inv_2 U67 ( .A(n1116), .Y(n1107) );
  sky130_fd_sc_hd__inv_2 U68 ( .A(n1094), .Y(n1105) );
  sky130_fd_sc_hd__clkinv_1 U69 ( .A(n1103), .Y(n1093) );
  sky130_fd_sc_hd__inv_2 U70 ( .A(n1081), .Y(n1092) );
  sky130_fd_sc_hd__clkinv_1 U71 ( .A(n1090), .Y(n1080) );
  sky130_fd_sc_hd__inv_2 U72 ( .A(n1068), .Y(n1079) );
  sky130_fd_sc_hd__inv_2 U73 ( .A(n1077), .Y(n1067) );
  sky130_fd_sc_hd__inv_2 U74 ( .A(n1065), .Y(n1056) );
  sky130_fd_sc_hd__inv_2 U75 ( .A(n1054), .Y(n1045) );
  sky130_fd_sc_hd__inv_2 U76 ( .A(n1043), .Y(n1034) );
  sky130_fd_sc_hd__inv_2 U77 ( .A(n1022), .Y(n1033) );
  sky130_fd_sc_hd__inv_2 U78 ( .A(n1031), .Y(n1021) );
  sky130_fd_sc_hd__inv_2 U79 ( .A(n1008), .Y(n1019) );
  sky130_fd_sc_hd__clkinv_1 U80 ( .A(n1017), .Y(n1007) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n994), .Y(n1005) );
  sky130_fd_sc_hd__clkinv_1 U82 ( .A(n1003), .Y(n993) );
  sky130_fd_sc_hd__inv_2 U83 ( .A(n981), .Y(n992) );
  sky130_fd_sc_hd__clkinv_1 U84 ( .A(n990), .Y(n980) );
  sky130_fd_sc_hd__inv_2 U85 ( .A(n968), .Y(n979) );
  sky130_fd_sc_hd__inv_2 U86 ( .A(n977), .Y(n967) );
  sky130_fd_sc_hd__inv_2 U87 ( .A(n965), .Y(n956) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(n954), .Y(n945) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(n943), .Y(n934) );
  sky130_fd_sc_hd__inv_2 U90 ( .A(n932), .Y(n923) );
  sky130_fd_sc_hd__inv_2 U91 ( .A(n920), .Y(n911) );
  sky130_fd_sc_hd__inv_2 U92 ( .A(n908), .Y(n899) );
  sky130_fd_sc_hd__inv_2 U93 ( .A(n897), .Y(n888) );
  sky130_fd_sc_hd__inv_2 U94 ( .A(n886), .Y(n877) );
  sky130_fd_sc_hd__inv_2 U95 ( .A(n875), .Y(n866) );
  sky130_fd_sc_hd__inv_2 U96 ( .A(n864), .Y(n855) );
  sky130_fd_sc_hd__inv_2 U97 ( .A(n853), .Y(n844) );
  sky130_fd_sc_hd__inv_2 U98 ( .A(n832), .Y(n843) );
  sky130_fd_sc_hd__inv_2 U99 ( .A(n841), .Y(n831) );
  sky130_fd_sc_hd__inv_2 U100 ( .A(n828), .Y(n819) );
  sky130_fd_sc_hd__buf_2 U101 ( .A(n1416), .X(n582) );
  sky130_fd_sc_hd__inv_2 U102 ( .A(n806), .Y(n817) );
  sky130_fd_sc_hd__clkinv_1 U103 ( .A(n815), .Y(n805) );
  sky130_fd_sc_hd__inv_2 U104 ( .A(n793), .Y(n804) );
  sky130_fd_sc_hd__clkinv_1 U105 ( .A(n802), .Y(n792) );
  sky130_fd_sc_hd__buf_2 U106 ( .A(n1402), .X(n578) );
  sky130_fd_sc_hd__inv_2 U107 ( .A(n780), .Y(n791) );
  sky130_fd_sc_hd__clkinv_1 U108 ( .A(n789), .Y(n779) );
  sky130_fd_sc_hd__inv_2 U109 ( .A(n777), .Y(n768) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(n766), .Y(n757) );
  sky130_fd_sc_hd__inv_2 U111 ( .A(n755), .Y(n746) );
  sky130_fd_sc_hd__inv_2 U112 ( .A(n744), .Y(n735) );
  sky130_fd_sc_hd__inv_2 U113 ( .A(n722), .Y(n733) );
  sky130_fd_sc_hd__clkinv_1 U114 ( .A(n731), .Y(n721) );
  sky130_fd_sc_hd__clkinv_1 U115 ( .A(n716), .Y(n707) );
  sky130_fd_sc_hd__inv_2 U116 ( .A(n694), .Y(n705) );
  sky130_fd_sc_hd__clkinv_1 U117 ( .A(n703), .Y(n693) );
  sky130_fd_sc_hd__inv_2 U118 ( .A(n690), .Y(n681) );
  sky130_fd_sc_hd__inv_2 U119 ( .A(n679), .Y(n670) );
  sky130_fd_sc_hd__inv_2 U120 ( .A(n667), .Y(n658) );
  sky130_fd_sc_hd__inv_2 U121 ( .A(n655), .Y(n646) );
  sky130_fd_sc_hd__inv_2 U122 ( .A(n644), .Y(n633) );
  sky130_fd_sc_hd__inv_2 U123 ( .A(n48), .Y(n52) );
  sky130_fd_sc_hd__and2_4 U124 ( .A(n768), .B(n575), .X(n3) );
  sky130_fd_sc_hd__and2_4 U125 ( .A(n658), .B(n576), .X(n4) );
  sky130_fd_sc_hd__and2_4 U126 ( .A(n1328), .B(n575), .X(n5) );
  sky130_fd_sc_hd__and2_4 U127 ( .A(n1352), .B(n575), .X(n6) );
  sky130_fd_sc_hd__inv_1 U128 ( .A(n55), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U129 ( .A(n55), .Y(n60) );
  sky130_fd_sc_hd__inv_1 U130 ( .A(n63), .Y(n69) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(n63), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U132 ( .A(n71), .Y(n77) );
  sky130_fd_sc_hd__inv_1 U133 ( .A(n71), .Y(n76) );
  sky130_fd_sc_hd__inv_1 U134 ( .A(n79), .Y(n85) );
  sky130_fd_sc_hd__inv_1 U135 ( .A(n79), .Y(n84) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(n87), .Y(n93) );
  sky130_fd_sc_hd__inv_1 U137 ( .A(n87), .Y(n92) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(n95), .Y(n101) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(n95), .Y(n100) );
  sky130_fd_sc_hd__inv_2 U140 ( .A(n48), .Y(n53) );
  sky130_fd_sc_hd__and2_4 U141 ( .A(n646), .B(n575), .X(n7) );
  sky130_fd_sc_hd__and2_4 U142 ( .A(n866), .B(n575), .X(n8) );
  sky130_fd_sc_hd__and2_4 U143 ( .A(n934), .B(n54), .X(n9) );
  sky130_fd_sc_hd__and2_4 U144 ( .A(n1034), .B(n54), .X(n10) );
  sky130_fd_sc_hd__and2_4 U145 ( .A(n575), .B(n1400), .X(n11) );
  sky130_fd_sc_hd__and2_4 U146 ( .A(n945), .B(n575), .X(n12) );
  sky130_fd_sc_hd__and2_4 U147 ( .A(n1340), .B(n576), .X(n13) );
  sky130_fd_sc_hd__and2_4 U148 ( .A(n1363), .B(n575), .X(n14) );
  sky130_fd_sc_hd__and2_4 U149 ( .A(n1387), .B(n575), .X(n15) );
  sky130_fd_sc_hd__and2_4 U150 ( .A(n1316), .B(n575), .X(n16) );
  sky130_fd_sc_hd__and2_4 U151 ( .A(n1375), .B(n54), .X(n17) );
  sky130_fd_sc_hd__and2_4 U152 ( .A(n877), .B(n54), .X(n18) );
  sky130_fd_sc_hd__and2_4 U153 ( .A(n911), .B(n54), .X(n19) );
  sky130_fd_sc_hd__inv_2 U154 ( .A(n55), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U155 ( .A(n55), .Y(n58) );
  sky130_fd_sc_hd__inv_2 U156 ( .A(n63), .Y(n64) );
  sky130_fd_sc_hd__inv_1 U157 ( .A(n63), .Y(n66) );
  sky130_fd_sc_hd__inv_2 U158 ( .A(n71), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U159 ( .A(n71), .Y(n74) );
  sky130_fd_sc_hd__inv_2 U160 ( .A(n79), .Y(n80) );
  sky130_fd_sc_hd__inv_1 U161 ( .A(n79), .Y(n82) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(n87), .Y(n88) );
  sky130_fd_sc_hd__inv_1 U163 ( .A(n87), .Y(n90) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(n95), .Y(n96) );
  sky130_fd_sc_hd__inv_1 U165 ( .A(n95), .Y(n98) );
  sky130_fd_sc_hd__and2_4 U166 ( .A(n45), .B(n1426), .X(n20) );
  sky130_fd_sc_hd__and2_4 U167 ( .A(n844), .B(n575), .X(n21) );
  sky130_fd_sc_hd__and2_4 U168 ( .A(n1228), .B(n576), .X(n22) );
  sky130_fd_sc_hd__and2_4 U169 ( .A(n746), .B(n575), .X(n23) );
  sky130_fd_sc_hd__and2_4 U170 ( .A(n1132), .B(n575), .X(n24) );
  sky130_fd_sc_hd__and2_4 U171 ( .A(n1250), .B(n575), .X(n25) );
  sky130_fd_sc_hd__and2_4 U172 ( .A(n1056), .B(n576), .X(n26) );
  sky130_fd_sc_hd__and2_4 U173 ( .A(n670), .B(n575), .X(n27) );
  sky130_fd_sc_hd__and2_4 U174 ( .A(n956), .B(n575), .X(n28) );
  sky130_fd_sc_hd__and2_4 U175 ( .A(n1154), .B(n575), .X(n29) );
  sky130_fd_sc_hd__and2_4 U176 ( .A(n855), .B(n575), .X(n30) );
  sky130_fd_sc_hd__and2_4 U177 ( .A(n1239), .B(n575), .X(n31) );
  sky130_fd_sc_hd__and2_4 U178 ( .A(n1045), .B(n575), .X(n32) );
  sky130_fd_sc_hd__and2_4 U179 ( .A(n757), .B(n576), .X(n33) );
  sky130_fd_sc_hd__and2_4 U180 ( .A(n1143), .B(n575), .X(n34) );
  sky130_fd_sc_hd__and2_4 U181 ( .A(n888), .B(n575), .X(n35) );
  sky130_fd_sc_hd__and2_4 U182 ( .A(n899), .B(n575), .X(n36) );
  sky130_fd_sc_hd__buf_2 U183 ( .A(n1402), .X(n580) );
  sky130_fd_sc_hd__buf_2 U184 ( .A(n1402), .X(n577) );
  sky130_fd_sc_hd__buf_2 U185 ( .A(n1402), .X(n579) );
  sky130_fd_sc_hd__and2_4 U186 ( .A(n819), .B(n576), .X(n37) );
  sky130_fd_sc_hd__and2_4 U187 ( .A(n1178), .B(n576), .X(n38) );
  sky130_fd_sc_hd__and2_4 U188 ( .A(n1189), .B(n576), .X(n39) );
  sky130_fd_sc_hd__and2_4 U189 ( .A(n707), .B(n576), .X(n40) );
  sky130_fd_sc_hd__and2_4 U190 ( .A(n923), .B(n576), .X(n41) );
  sky130_fd_sc_hd__and2_4 U191 ( .A(n1107), .B(n576), .X(n42) );
  sky130_fd_sc_hd__and2_1 U192 ( .A(n118), .B(n114), .X(n517) );
  sky130_fd_sc_hd__buf_1 U193 ( .A(n517), .X(n558) );
  sky130_fd_sc_hd__buf_1 U194 ( .A(n517), .X(n559) );
  sky130_fd_sc_hd__and2_4 U195 ( .A(n681), .B(n54), .X(n43) );
  sky130_fd_sc_hd__and2_4 U196 ( .A(n735), .B(n54), .X(n44) );
  sky130_fd_sc_hd__and2_1 U197 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[1]), .X(n45)
         );
  sky130_fd_sc_hd__and2_1 U198 ( .A(s_wr_ptr_q[4]), .B(s_wr_ptr_q[3]), .X(n46)
         );
  sky130_fd_sc_hd__inv_2 U199 ( .A(N79), .Y(n534) );
  sky130_fd_sc_hd__clkinv_1 U200 ( .A(N80), .Y(n535) );
  sky130_fd_sc_hd__and2_1 U201 ( .A(n107), .B(n114), .X(n501) );
  sky130_fd_sc_hd__clkbuf_1 U202 ( .A(n501), .X(n537) );
  sky130_fd_sc_hd__clkbuf_1 U203 ( .A(n503), .X(n540) );
  sky130_fd_sc_hd__and2_1 U204 ( .A(n108), .B(n114), .X(n505) );
  sky130_fd_sc_hd__clkbuf_1 U205 ( .A(n505), .X(n543) );
  sky130_fd_sc_hd__clkbuf_1 U206 ( .A(n507), .X(n547) );
  sky130_fd_sc_hd__and2_1 U207 ( .A(n114), .B(n113), .X(n513) );
  sky130_fd_sc_hd__clkbuf_1 U208 ( .A(n513), .X(n550) );
  sky130_fd_sc_hd__clkbuf_1 U209 ( .A(n515), .X(n554) );
  sky130_fd_sc_hd__clkbuf_1 U210 ( .A(n519), .X(n562) );
  sky130_fd_sc_hd__and2_1 U211 ( .A(n107), .B(n115), .X(n500) );
  sky130_fd_sc_hd__clkbuf_1 U212 ( .A(n500), .X(n536) );
  sky130_fd_sc_hd__and2_1 U213 ( .A(n107), .B(n117), .X(n502) );
  sky130_fd_sc_hd__clkbuf_1 U214 ( .A(n502), .X(n539) );
  sky130_fd_sc_hd__and2_1 U215 ( .A(n108), .B(n115), .X(n504) );
  sky130_fd_sc_hd__buf_1 U216 ( .A(n504), .X(n541) );
  sky130_fd_sc_hd__and2_1 U217 ( .A(n108), .B(n117), .X(n506) );
  sky130_fd_sc_hd__clkbuf_1 U218 ( .A(n506), .X(n545) );
  sky130_fd_sc_hd__and2_1 U219 ( .A(n113), .B(n115), .X(n512) );
  sky130_fd_sc_hd__clkbuf_1 U220 ( .A(n512), .X(n548) );
  sky130_fd_sc_hd__and2_1 U221 ( .A(n117), .B(n113), .X(n514) );
  sky130_fd_sc_hd__clkbuf_1 U222 ( .A(n514), .X(n552) );
  sky130_fd_sc_hd__and2_1 U223 ( .A(n118), .B(n115), .X(n516) );
  sky130_fd_sc_hd__clkbuf_1 U224 ( .A(n516), .X(n556) );
  sky130_fd_sc_hd__and2_1 U225 ( .A(n118), .B(n117), .X(n518) );
  sky130_fd_sc_hd__clkbuf_1 U226 ( .A(n518), .X(n560) );
  sky130_fd_sc_hd__nand2_2 U227 ( .A(n818), .B(n20), .Y(n789) );
  sky130_fd_sc_hd__nand2_4 U228 ( .A(n1432), .B(n47), .Y(n627) );
  sky130_fd_sc_hd__inv_2 U229 ( .A(n1401), .Y(n47) );
  sky130_fd_sc_hd__and2_4 U230 ( .A(N78), .B(n533), .X(n118) );
  sky130_fd_sc_hd__buf_6 U231 ( .A(n501), .X(n538) );
  sky130_fd_sc_hd__clkinv_1 U232 ( .A(N75), .Y(n531) );
  sky130_fd_sc_hd__buf_6 U233 ( .A(n506), .X(n546) );
  sky130_fd_sc_hd__o2bb2ai_1 U234 ( .B1(n564), .B2(n535), .A1_N(N89), .A2_N(
        n1432), .Y(s_rd_ptr_d[5]) );
  sky130_fd_sc_hd__nand3_1 U235 ( .A(n599), .B(n1421), .C(push_i), .Y(n1430)
         );
  sky130_fd_sc_hd__inv_2 U236 ( .A(n1422), .Y(n1401) );
  sky130_fd_sc_hd__buf_6 U237 ( .A(n512), .X(n549) );
  sky130_fd_sc_hd__inv_2 U238 ( .A(n1418), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U239 ( .A(n48), .Y(n49) );
  sky130_fd_sc_hd__inv_2 U240 ( .A(n48), .Y(n50) );
  sky130_fd_sc_hd__inv_2 U241 ( .A(n48), .Y(n51) );
  sky130_fd_sc_hd__nand2_1 U242 ( .A(dat_i[0]), .B(n569), .Y(n1418) );
  sky130_fd_sc_hd__buf_6 U243 ( .A(n516), .X(n557) );
  sky130_fd_sc_hd__buf_6 U244 ( .A(n505), .X(n544) );
  sky130_fd_sc_hd__buf_6 U245 ( .A(n504), .X(n542) );
  sky130_fd_sc_hd__clkinv_1 U246 ( .A(N76), .Y(n532) );
  sky130_fd_sc_hd__clkinv_2 U247 ( .A(n1440), .Y(n617) );
  sky130_fd_sc_hd__and2_1 U248 ( .A(n107), .B(n116), .X(n503) );
  sky130_fd_sc_hd__and2_1 U249 ( .A(n108), .B(n116), .X(n507) );
  sky130_fd_sc_hd__and2_1 U250 ( .A(n113), .B(n116), .X(n515) );
  sky130_fd_sc_hd__and2_1 U251 ( .A(n118), .B(n116), .X(n519) );
  sky130_fd_sc_hd__inv_2 U252 ( .A(n47), .Y(n54) );
  sky130_fd_sc_hd__inv_2 U253 ( .A(n1422), .Y(n569) );
  sky130_fd_sc_hd__o2bb2ai_1 U254 ( .B1(n577), .B2(n644), .A1_N(n634), .A2_N(
        s_mem_q[575]), .Y(s_mem_d[575]) );
  sky130_fd_sc_hd__inv_2 U255 ( .A(n634), .Y(n643) );
  sky130_fd_sc_hd__inv_2 U256 ( .A(n1404), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U257 ( .A(n55), .Y(n57) );
  sky130_fd_sc_hd__clkinv_1 U258 ( .A(n55), .Y(n59) );
  sky130_fd_sc_hd__clkinv_1 U259 ( .A(n55), .Y(n62) );
  sky130_fd_sc_hd__inv_2 U260 ( .A(n1406), .Y(n63) );
  sky130_fd_sc_hd__inv_2 U261 ( .A(n63), .Y(n65) );
  sky130_fd_sc_hd__clkinv_1 U262 ( .A(n63), .Y(n67) );
  sky130_fd_sc_hd__clkinv_1 U263 ( .A(n63), .Y(n70) );
  sky130_fd_sc_hd__inv_2 U264 ( .A(n1408), .Y(n71) );
  sky130_fd_sc_hd__inv_2 U265 ( .A(n71), .Y(n73) );
  sky130_fd_sc_hd__clkinv_1 U266 ( .A(n71), .Y(n75) );
  sky130_fd_sc_hd__clkinv_1 U267 ( .A(n71), .Y(n78) );
  sky130_fd_sc_hd__inv_2 U268 ( .A(n1410), .Y(n79) );
  sky130_fd_sc_hd__inv_2 U269 ( .A(n79), .Y(n81) );
  sky130_fd_sc_hd__clkinv_1 U270 ( .A(n79), .Y(n83) );
  sky130_fd_sc_hd__clkinv_1 U271 ( .A(n79), .Y(n86) );
  sky130_fd_sc_hd__inv_2 U272 ( .A(n1412), .Y(n87) );
  sky130_fd_sc_hd__inv_2 U273 ( .A(n87), .Y(n89) );
  sky130_fd_sc_hd__clkinv_1 U274 ( .A(n87), .Y(n91) );
  sky130_fd_sc_hd__clkinv_1 U275 ( .A(n87), .Y(n94) );
  sky130_fd_sc_hd__inv_2 U276 ( .A(n1414), .Y(n95) );
  sky130_fd_sc_hd__inv_2 U277 ( .A(n95), .Y(n97) );
  sky130_fd_sc_hd__clkinv_1 U278 ( .A(n95), .Y(n99) );
  sky130_fd_sc_hd__clkinv_1 U279 ( .A(n95), .Y(n102) );
  sky130_fd_sc_hd__o21ai_1 U280 ( .A1(n477), .A2(n476), .B1(n475), .Y(n530) );
  sky130_fd_sc_hd__clkinv_1 U281 ( .A(n594), .Y(n595) );
  sky130_fd_sc_hd__buf_4 U282 ( .A(n1416), .X(n584) );
  sky130_fd_sc_hd__buf_4 U283 ( .A(n1416), .X(n583) );
  sky130_fd_sc_hd__buf_4 U284 ( .A(n1416), .X(n581) );
  sky130_fd_sc_hd__nand2_2 U285 ( .A(cnt_o[6]), .B(n617), .Y(n594) );
  sky130_fd_sc_hd__clkinv_1 U286 ( .A(n596), .Y(n103) );
  sky130_fd_sc_hd__inv_2 U287 ( .A(n603), .Y(cnt_o[0]) );
  sky130_fd_sc_hd__inv_2 U288 ( .A(n1443), .Y(n603) );
  sky130_fd_sc_hd__inv_1 U289 ( .A(n612), .Y(n618) );
  sky130_fd_sc_hd__inv_2 U290 ( .A(n630), .Y(n623) );
  sky130_fd_sc_hd__inv_2 U291 ( .A(n592), .Y(n1432) );
  sky130_fd_sc_hd__o21ai_1 U292 ( .A1(n488), .A2(n487), .B1(n486), .Y(n529) );
  sky130_fd_sc_hd__buf_6 U293 ( .A(n513), .X(n551) );
  sky130_fd_sc_hd__inv_1 U294 ( .A(n604), .Y(n609) );
  sky130_fd_sc_hd__inv_1 U295 ( .A(n608), .Y(n106) );
  sky130_fd_sc_hd__inv_2 U296 ( .A(n1442), .Y(n608) );
  sky130_fd_sc_hd__o21ai_1 U297 ( .A1(n499), .A2(n498), .B1(n497), .Y(n528) );
  sky130_fd_sc_hd__buf_6 U298 ( .A(n515), .X(n555) );
  sky130_fd_sc_hd__buf_6 U299 ( .A(n514), .X(n553) );
  sky130_fd_sc_hd__nand2_2 U300 ( .A(n603), .B(n626), .Y(n593) );
  sky130_fd_sc_hd__inv_2 U301 ( .A(n1430), .Y(n1427) );
  sky130_fd_sc_hd__nor2_1 U302 ( .A(n532), .B(N75), .Y(n114) );
  sky130_fd_sc_hd__nor2_1 U303 ( .A(n532), .B(n531), .Y(n115) );
  sky130_fd_sc_hd__a22oi_1 U304 ( .A1(s_mem_q[486]), .A2(n537), .B1(
        s_mem_q[495]), .B2(n536), .Y(n112) );
  sky130_fd_sc_hd__nor2_1 U305 ( .A(N75), .B(N76), .Y(n116) );
  sky130_fd_sc_hd__nor2_1 U306 ( .A(n531), .B(N76), .Y(n117) );
  sky130_fd_sc_hd__a22oi_1 U307 ( .A1(s_mem_q[468]), .A2(n540), .B1(
        s_mem_q[477]), .B2(n539), .Y(n111) );
  sky130_fd_sc_hd__nor2_1 U308 ( .A(N77), .B(N78), .Y(n108) );
  sky130_fd_sc_hd__a22oi_1 U309 ( .A1(s_mem_q[450]), .A2(n543), .B1(
        s_mem_q[459]), .B2(n541), .Y(n110) );
  sky130_fd_sc_hd__a22oi_1 U310 ( .A1(s_mem_q[432]), .A2(n547), .B1(
        s_mem_q[441]), .B2(n545), .Y(n109) );
  sky130_fd_sc_hd__nand4_1 U311 ( .A(n112), .B(n111), .C(n110), .D(n109), .Y(
        n124) );
  sky130_fd_sc_hd__and2_0 U312 ( .A(N78), .B(N77), .X(n113) );
  sky130_fd_sc_hd__a22oi_1 U313 ( .A1(s_mem_q[558]), .A2(n550), .B1(
        s_mem_q[567]), .B2(n548), .Y(n122) );
  sky130_fd_sc_hd__a22oi_1 U314 ( .A1(s_mem_q[540]), .A2(n554), .B1(
        s_mem_q[549]), .B2(n552), .Y(n121) );
  sky130_fd_sc_hd__a22oi_1 U315 ( .A1(s_mem_q[522]), .A2(n558), .B1(
        s_mem_q[531]), .B2(n556), .Y(n120) );
  sky130_fd_sc_hd__a22oi_1 U316 ( .A1(s_mem_q[504]), .A2(n562), .B1(
        s_mem_q[513]), .B2(n560), .Y(n119) );
  sky130_fd_sc_hd__nand4_1 U317 ( .A(n122), .B(n121), .C(n120), .D(n119), .Y(
        n123) );
  sky130_fd_sc_hd__o21ai_0 U318 ( .A1(n124), .A2(n123), .B1(n475), .Y(n158) );
  sky130_fd_sc_hd__a22oi_1 U319 ( .A1(s_mem_q[342]), .A2(n537), .B1(
        s_mem_q[351]), .B2(n536), .Y(n128) );
  sky130_fd_sc_hd__a22oi_1 U320 ( .A1(s_mem_q[324]), .A2(n540), .B1(
        s_mem_q[333]), .B2(n539), .Y(n127) );
  sky130_fd_sc_hd__a22oi_1 U321 ( .A1(s_mem_q[306]), .A2(n543), .B1(
        s_mem_q[315]), .B2(n541), .Y(n126) );
  sky130_fd_sc_hd__a22oi_1 U322 ( .A1(s_mem_q[288]), .A2(n547), .B1(
        s_mem_q[297]), .B2(n545), .Y(n125) );
  sky130_fd_sc_hd__nand4_1 U323 ( .A(n128), .B(n127), .C(n126), .D(n125), .Y(
        n134) );
  sky130_fd_sc_hd__a22oi_1 U324 ( .A1(s_mem_q[414]), .A2(n550), .B1(
        s_mem_q[423]), .B2(n548), .Y(n132) );
  sky130_fd_sc_hd__a22oi_1 U325 ( .A1(s_mem_q[396]), .A2(n554), .B1(
        s_mem_q[405]), .B2(n552), .Y(n131) );
  sky130_fd_sc_hd__a22oi_1 U326 ( .A1(s_mem_q[378]), .A2(n558), .B1(
        s_mem_q[387]), .B2(n556), .Y(n130) );
  sky130_fd_sc_hd__a22oi_1 U327 ( .A1(s_mem_q[360]), .A2(n562), .B1(
        s_mem_q[369]), .B2(n560), .Y(n129) );
  sky130_fd_sc_hd__nand4_1 U328 ( .A(n132), .B(n131), .C(n130), .D(n129), .Y(
        n133) );
  sky130_fd_sc_hd__o21ai_0 U329 ( .A1(n134), .A2(n133), .B1(n486), .Y(n157) );
  sky130_fd_sc_hd__a22oi_1 U330 ( .A1(s_mem_q[198]), .A2(n537), .B1(
        s_mem_q[207]), .B2(n536), .Y(n138) );
  sky130_fd_sc_hd__a22oi_1 U331 ( .A1(s_mem_q[180]), .A2(n540), .B1(
        s_mem_q[189]), .B2(n539), .Y(n137) );
  sky130_fd_sc_hd__a22oi_1 U332 ( .A1(s_mem_q[162]), .A2(n543), .B1(
        s_mem_q[171]), .B2(n541), .Y(n136) );
  sky130_fd_sc_hd__a22oi_1 U333 ( .A1(s_mem_q[144]), .A2(n547), .B1(
        s_mem_q[153]), .B2(n545), .Y(n135) );
  sky130_fd_sc_hd__nand4_1 U334 ( .A(n138), .B(n137), .C(n136), .D(n135), .Y(
        n144) );
  sky130_fd_sc_hd__a22oi_1 U335 ( .A1(s_mem_q[270]), .A2(n550), .B1(
        s_mem_q[279]), .B2(n548), .Y(n142) );
  sky130_fd_sc_hd__a22oi_1 U336 ( .A1(s_mem_q[252]), .A2(n554), .B1(
        s_mem_q[261]), .B2(n552), .Y(n141) );
  sky130_fd_sc_hd__a22oi_1 U337 ( .A1(s_mem_q[234]), .A2(n558), .B1(
        s_mem_q[243]), .B2(n556), .Y(n140) );
  sky130_fd_sc_hd__a22oi_1 U338 ( .A1(s_mem_q[216]), .A2(n562), .B1(
        s_mem_q[225]), .B2(n560), .Y(n139) );
  sky130_fd_sc_hd__nand4_1 U339 ( .A(n142), .B(n141), .C(n140), .D(n139), .Y(
        n143) );
  sky130_fd_sc_hd__o21ai_0 U340 ( .A1(n144), .A2(n143), .B1(n497), .Y(n156) );
  sky130_fd_sc_hd__a22oi_1 U341 ( .A1(s_mem_q[54]), .A2(n537), .B1(s_mem_q[63]), .B2(n536), .Y(n148) );
  sky130_fd_sc_hd__a22oi_1 U342 ( .A1(s_mem_q[36]), .A2(n540), .B1(s_mem_q[45]), .B2(n539), .Y(n147) );
  sky130_fd_sc_hd__a22oi_1 U343 ( .A1(s_mem_q[18]), .A2(n543), .B1(s_mem_q[27]), .B2(n541), .Y(n146) );
  sky130_fd_sc_hd__a22oi_1 U344 ( .A1(s_mem_q[0]), .A2(n547), .B1(s_mem_q[9]), 
        .B2(n545), .Y(n145) );
  sky130_fd_sc_hd__nand4_1 U345 ( .A(n148), .B(n147), .C(n146), .D(n145), .Y(
        n154) );
  sky130_fd_sc_hd__a22oi_1 U346 ( .A1(s_mem_q[126]), .A2(n550), .B1(
        s_mem_q[135]), .B2(n548), .Y(n152) );
  sky130_fd_sc_hd__a22oi_1 U347 ( .A1(s_mem_q[108]), .A2(n554), .B1(
        s_mem_q[117]), .B2(n552), .Y(n151) );
  sky130_fd_sc_hd__a22oi_1 U348 ( .A1(s_mem_q[90]), .A2(n558), .B1(s_mem_q[99]), .B2(n556), .Y(n150) );
  sky130_fd_sc_hd__a22oi_1 U349 ( .A1(s_mem_q[72]), .A2(n562), .B1(s_mem_q[81]), .B2(n560), .Y(n149) );
  sky130_fd_sc_hd__nand4_1 U350 ( .A(n152), .B(n151), .C(n150), .D(n149), .Y(
        n153) );
  sky130_fd_sc_hd__o21ai_0 U351 ( .A1(n154), .A2(n153), .B1(n524), .Y(n155) );
  sky130_fd_sc_hd__nand4_1 U352 ( .A(n158), .B(n157), .C(n156), .D(n155), .Y(
        dat_o[0]) );
  sky130_fd_sc_hd__a22oi_1 U353 ( .A1(s_mem_q[487]), .A2(n537), .B1(
        s_mem_q[496]), .B2(n536), .Y(n162) );
  sky130_fd_sc_hd__a22oi_1 U354 ( .A1(s_mem_q[469]), .A2(n540), .B1(
        s_mem_q[478]), .B2(n539), .Y(n161) );
  sky130_fd_sc_hd__a22oi_1 U355 ( .A1(s_mem_q[451]), .A2(n543), .B1(
        s_mem_q[460]), .B2(n541), .Y(n160) );
  sky130_fd_sc_hd__a22oi_1 U356 ( .A1(s_mem_q[433]), .A2(n547), .B1(
        s_mem_q[442]), .B2(n545), .Y(n159) );
  sky130_fd_sc_hd__nand4_1 U357 ( .A(n162), .B(n161), .C(n160), .D(n159), .Y(
        n168) );
  sky130_fd_sc_hd__a22oi_1 U358 ( .A1(s_mem_q[559]), .A2(n550), .B1(
        s_mem_q[568]), .B2(n548), .Y(n166) );
  sky130_fd_sc_hd__a22oi_1 U359 ( .A1(s_mem_q[541]), .A2(n554), .B1(
        s_mem_q[550]), .B2(n552), .Y(n165) );
  sky130_fd_sc_hd__a22oi_1 U360 ( .A1(s_mem_q[523]), .A2(n558), .B1(
        s_mem_q[532]), .B2(n556), .Y(n164) );
  sky130_fd_sc_hd__a22oi_1 U361 ( .A1(s_mem_q[505]), .A2(n562), .B1(
        s_mem_q[514]), .B2(n560), .Y(n163) );
  sky130_fd_sc_hd__nand4_1 U362 ( .A(n166), .B(n165), .C(n164), .D(n163), .Y(
        n167) );
  sky130_fd_sc_hd__o21ai_0 U363 ( .A1(n168), .A2(n167), .B1(n475), .Y(n202) );
  sky130_fd_sc_hd__a22oi_1 U364 ( .A1(s_mem_q[343]), .A2(n537), .B1(
        s_mem_q[352]), .B2(n536), .Y(n172) );
  sky130_fd_sc_hd__a22oi_1 U365 ( .A1(s_mem_q[325]), .A2(n540), .B1(
        s_mem_q[334]), .B2(n539), .Y(n171) );
  sky130_fd_sc_hd__a22oi_1 U366 ( .A1(s_mem_q[307]), .A2(n543), .B1(
        s_mem_q[316]), .B2(n541), .Y(n170) );
  sky130_fd_sc_hd__a22oi_1 U367 ( .A1(s_mem_q[289]), .A2(n547), .B1(
        s_mem_q[298]), .B2(n545), .Y(n169) );
  sky130_fd_sc_hd__nand4_1 U368 ( .A(n172), .B(n171), .C(n170), .D(n169), .Y(
        n178) );
  sky130_fd_sc_hd__a22oi_1 U369 ( .A1(s_mem_q[415]), .A2(n550), .B1(
        s_mem_q[424]), .B2(n548), .Y(n176) );
  sky130_fd_sc_hd__a22oi_1 U370 ( .A1(s_mem_q[397]), .A2(n554), .B1(
        s_mem_q[406]), .B2(n552), .Y(n175) );
  sky130_fd_sc_hd__a22oi_1 U371 ( .A1(s_mem_q[379]), .A2(n558), .B1(
        s_mem_q[388]), .B2(n556), .Y(n174) );
  sky130_fd_sc_hd__a22oi_1 U372 ( .A1(s_mem_q[361]), .A2(n562), .B1(
        s_mem_q[370]), .B2(n560), .Y(n173) );
  sky130_fd_sc_hd__nand4_1 U373 ( .A(n176), .B(n175), .C(n174), .D(n173), .Y(
        n177) );
  sky130_fd_sc_hd__o21ai_0 U374 ( .A1(n178), .A2(n177), .B1(n486), .Y(n201) );
  sky130_fd_sc_hd__a22oi_1 U375 ( .A1(s_mem_q[199]), .A2(n537), .B1(
        s_mem_q[208]), .B2(n536), .Y(n182) );
  sky130_fd_sc_hd__a22oi_1 U376 ( .A1(s_mem_q[181]), .A2(n540), .B1(
        s_mem_q[190]), .B2(n539), .Y(n181) );
  sky130_fd_sc_hd__a22oi_1 U377 ( .A1(s_mem_q[163]), .A2(n543), .B1(
        s_mem_q[172]), .B2(n541), .Y(n180) );
  sky130_fd_sc_hd__a22oi_1 U378 ( .A1(s_mem_q[145]), .A2(n547), .B1(
        s_mem_q[154]), .B2(n545), .Y(n179) );
  sky130_fd_sc_hd__nand4_1 U379 ( .A(n182), .B(n181), .C(n180), .D(n179), .Y(
        n188) );
  sky130_fd_sc_hd__a22oi_1 U380 ( .A1(s_mem_q[271]), .A2(n550), .B1(
        s_mem_q[280]), .B2(n548), .Y(n186) );
  sky130_fd_sc_hd__a22oi_1 U381 ( .A1(s_mem_q[253]), .A2(n554), .B1(
        s_mem_q[262]), .B2(n552), .Y(n185) );
  sky130_fd_sc_hd__a22oi_1 U382 ( .A1(s_mem_q[235]), .A2(n558), .B1(
        s_mem_q[244]), .B2(n556), .Y(n184) );
  sky130_fd_sc_hd__a22oi_1 U383 ( .A1(s_mem_q[217]), .A2(n562), .B1(
        s_mem_q[226]), .B2(n560), .Y(n183) );
  sky130_fd_sc_hd__nand4_1 U384 ( .A(n186), .B(n185), .C(n184), .D(n183), .Y(
        n187) );
  sky130_fd_sc_hd__o21ai_0 U385 ( .A1(n188), .A2(n187), .B1(n497), .Y(n200) );
  sky130_fd_sc_hd__a22oi_1 U386 ( .A1(s_mem_q[55]), .A2(n537), .B1(s_mem_q[64]), .B2(n536), .Y(n192) );
  sky130_fd_sc_hd__a22oi_1 U387 ( .A1(s_mem_q[37]), .A2(n540), .B1(s_mem_q[46]), .B2(n539), .Y(n191) );
  sky130_fd_sc_hd__a22oi_1 U388 ( .A1(s_mem_q[19]), .A2(n543), .B1(s_mem_q[28]), .B2(n541), .Y(n190) );
  sky130_fd_sc_hd__a22oi_1 U389 ( .A1(s_mem_q[1]), .A2(n547), .B1(s_mem_q[10]), 
        .B2(n545), .Y(n189) );
  sky130_fd_sc_hd__nand4_1 U390 ( .A(n192), .B(n191), .C(n190), .D(n189), .Y(
        n198) );
  sky130_fd_sc_hd__a22oi_1 U391 ( .A1(s_mem_q[127]), .A2(n550), .B1(
        s_mem_q[136]), .B2(n548), .Y(n196) );
  sky130_fd_sc_hd__a22oi_1 U392 ( .A1(s_mem_q[109]), .A2(n554), .B1(
        s_mem_q[118]), .B2(n552), .Y(n195) );
  sky130_fd_sc_hd__a22oi_1 U393 ( .A1(s_mem_q[91]), .A2(n558), .B1(
        s_mem_q[100]), .B2(n556), .Y(n194) );
  sky130_fd_sc_hd__a22oi_1 U394 ( .A1(s_mem_q[73]), .A2(n562), .B1(s_mem_q[82]), .B2(n560), .Y(n193) );
  sky130_fd_sc_hd__nand4_1 U395 ( .A(n196), .B(n195), .C(n194), .D(n193), .Y(
        n197) );
  sky130_fd_sc_hd__o21ai_0 U396 ( .A1(n198), .A2(n197), .B1(n524), .Y(n199) );
  sky130_fd_sc_hd__nand4_1 U397 ( .A(n202), .B(n201), .C(n200), .D(n199), .Y(
        dat_o[1]) );
  sky130_fd_sc_hd__a22oi_1 U398 ( .A1(s_mem_q[488]), .A2(n537), .B1(
        s_mem_q[497]), .B2(n536), .Y(n206) );
  sky130_fd_sc_hd__a22oi_1 U399 ( .A1(s_mem_q[470]), .A2(n540), .B1(
        s_mem_q[479]), .B2(n539), .Y(n205) );
  sky130_fd_sc_hd__a22oi_1 U400 ( .A1(s_mem_q[452]), .A2(n543), .B1(
        s_mem_q[461]), .B2(n541), .Y(n204) );
  sky130_fd_sc_hd__a22oi_1 U401 ( .A1(s_mem_q[434]), .A2(n547), .B1(
        s_mem_q[443]), .B2(n545), .Y(n203) );
  sky130_fd_sc_hd__nand4_1 U402 ( .A(n206), .B(n205), .C(n204), .D(n203), .Y(
        n212) );
  sky130_fd_sc_hd__a22oi_1 U403 ( .A1(s_mem_q[560]), .A2(n550), .B1(
        s_mem_q[569]), .B2(n548), .Y(n210) );
  sky130_fd_sc_hd__a22oi_1 U404 ( .A1(s_mem_q[542]), .A2(n554), .B1(
        s_mem_q[551]), .B2(n552), .Y(n209) );
  sky130_fd_sc_hd__a22oi_1 U405 ( .A1(s_mem_q[524]), .A2(n558), .B1(
        s_mem_q[533]), .B2(n556), .Y(n208) );
  sky130_fd_sc_hd__a22oi_1 U406 ( .A1(s_mem_q[506]), .A2(n562), .B1(
        s_mem_q[515]), .B2(n560), .Y(n207) );
  sky130_fd_sc_hd__nand4_1 U407 ( .A(n210), .B(n209), .C(n208), .D(n207), .Y(
        n211) );
  sky130_fd_sc_hd__o21ai_0 U408 ( .A1(n212), .A2(n211), .B1(n475), .Y(n246) );
  sky130_fd_sc_hd__a22oi_1 U409 ( .A1(s_mem_q[344]), .A2(n537), .B1(
        s_mem_q[353]), .B2(n536), .Y(n216) );
  sky130_fd_sc_hd__a22oi_1 U410 ( .A1(s_mem_q[326]), .A2(n540), .B1(
        s_mem_q[335]), .B2(n539), .Y(n215) );
  sky130_fd_sc_hd__a22oi_1 U411 ( .A1(s_mem_q[308]), .A2(n543), .B1(
        s_mem_q[317]), .B2(n541), .Y(n214) );
  sky130_fd_sc_hd__a22oi_1 U412 ( .A1(s_mem_q[290]), .A2(n547), .B1(
        s_mem_q[299]), .B2(n545), .Y(n213) );
  sky130_fd_sc_hd__nand4_1 U413 ( .A(n216), .B(n215), .C(n214), .D(n213), .Y(
        n222) );
  sky130_fd_sc_hd__a22oi_1 U414 ( .A1(s_mem_q[416]), .A2(n550), .B1(
        s_mem_q[425]), .B2(n548), .Y(n220) );
  sky130_fd_sc_hd__a22oi_1 U415 ( .A1(s_mem_q[398]), .A2(n554), .B1(
        s_mem_q[407]), .B2(n552), .Y(n219) );
  sky130_fd_sc_hd__a22oi_1 U416 ( .A1(s_mem_q[380]), .A2(n558), .B1(
        s_mem_q[389]), .B2(n556), .Y(n218) );
  sky130_fd_sc_hd__a22oi_1 U417 ( .A1(s_mem_q[362]), .A2(n562), .B1(
        s_mem_q[371]), .B2(n560), .Y(n217) );
  sky130_fd_sc_hd__nand4_1 U418 ( .A(n220), .B(n219), .C(n218), .D(n217), .Y(
        n221) );
  sky130_fd_sc_hd__o21ai_0 U419 ( .A1(n222), .A2(n221), .B1(n486), .Y(n245) );
  sky130_fd_sc_hd__a22oi_1 U420 ( .A1(s_mem_q[200]), .A2(n537), .B1(
        s_mem_q[209]), .B2(n536), .Y(n226) );
  sky130_fd_sc_hd__a22oi_1 U421 ( .A1(s_mem_q[182]), .A2(n540), .B1(
        s_mem_q[191]), .B2(n539), .Y(n225) );
  sky130_fd_sc_hd__a22oi_1 U422 ( .A1(s_mem_q[164]), .A2(n543), .B1(
        s_mem_q[173]), .B2(n541), .Y(n224) );
  sky130_fd_sc_hd__a22oi_1 U423 ( .A1(s_mem_q[146]), .A2(n547), .B1(
        s_mem_q[155]), .B2(n545), .Y(n223) );
  sky130_fd_sc_hd__nand4_1 U424 ( .A(n226), .B(n225), .C(n224), .D(n223), .Y(
        n232) );
  sky130_fd_sc_hd__a22oi_1 U425 ( .A1(s_mem_q[272]), .A2(n550), .B1(
        s_mem_q[281]), .B2(n548), .Y(n230) );
  sky130_fd_sc_hd__a22oi_1 U426 ( .A1(s_mem_q[254]), .A2(n554), .B1(
        s_mem_q[263]), .B2(n552), .Y(n229) );
  sky130_fd_sc_hd__a22oi_1 U427 ( .A1(s_mem_q[236]), .A2(n559), .B1(
        s_mem_q[245]), .B2(n556), .Y(n228) );
  sky130_fd_sc_hd__a22oi_1 U428 ( .A1(s_mem_q[218]), .A2(n562), .B1(
        s_mem_q[227]), .B2(n560), .Y(n227) );
  sky130_fd_sc_hd__nand4_1 U429 ( .A(n230), .B(n229), .C(n228), .D(n227), .Y(
        n231) );
  sky130_fd_sc_hd__o21ai_0 U430 ( .A1(n232), .A2(n231), .B1(n497), .Y(n244) );
  sky130_fd_sc_hd__a22oi_1 U431 ( .A1(s_mem_q[56]), .A2(n537), .B1(s_mem_q[65]), .B2(n536), .Y(n236) );
  sky130_fd_sc_hd__a22oi_1 U432 ( .A1(s_mem_q[38]), .A2(n540), .B1(s_mem_q[47]), .B2(n539), .Y(n235) );
  sky130_fd_sc_hd__a22oi_1 U433 ( .A1(s_mem_q[20]), .A2(n543), .B1(s_mem_q[29]), .B2(n541), .Y(n234) );
  sky130_fd_sc_hd__a22oi_1 U434 ( .A1(s_mem_q[2]), .A2(n547), .B1(s_mem_q[11]), 
        .B2(n545), .Y(n233) );
  sky130_fd_sc_hd__nand4_1 U435 ( .A(n236), .B(n235), .C(n234), .D(n233), .Y(
        n242) );
  sky130_fd_sc_hd__a22oi_1 U436 ( .A1(s_mem_q[128]), .A2(n550), .B1(
        s_mem_q[137]), .B2(n548), .Y(n240) );
  sky130_fd_sc_hd__a22oi_1 U437 ( .A1(s_mem_q[110]), .A2(n554), .B1(
        s_mem_q[119]), .B2(n552), .Y(n239) );
  sky130_fd_sc_hd__a22oi_1 U438 ( .A1(s_mem_q[92]), .A2(n559), .B1(
        s_mem_q[101]), .B2(n556), .Y(n238) );
  sky130_fd_sc_hd__a22oi_1 U439 ( .A1(s_mem_q[74]), .A2(n562), .B1(s_mem_q[83]), .B2(n560), .Y(n237) );
  sky130_fd_sc_hd__nand4_1 U440 ( .A(n240), .B(n239), .C(n238), .D(n237), .Y(
        n241) );
  sky130_fd_sc_hd__o21ai_0 U441 ( .A1(n242), .A2(n241), .B1(n524), .Y(n243) );
  sky130_fd_sc_hd__nand4_1 U442 ( .A(n246), .B(n245), .C(n244), .D(n243), .Y(
        dat_o[2]) );
  sky130_fd_sc_hd__a22oi_1 U443 ( .A1(s_mem_q[489]), .A2(n537), .B1(
        s_mem_q[498]), .B2(n536), .Y(n250) );
  sky130_fd_sc_hd__a22oi_1 U444 ( .A1(s_mem_q[471]), .A2(n540), .B1(
        s_mem_q[480]), .B2(n539), .Y(n249) );
  sky130_fd_sc_hd__a22oi_1 U445 ( .A1(s_mem_q[453]), .A2(n543), .B1(
        s_mem_q[462]), .B2(n541), .Y(n248) );
  sky130_fd_sc_hd__a22oi_1 U446 ( .A1(s_mem_q[435]), .A2(n547), .B1(
        s_mem_q[444]), .B2(n545), .Y(n247) );
  sky130_fd_sc_hd__nand4_1 U447 ( .A(n250), .B(n249), .C(n248), .D(n247), .Y(
        n256) );
  sky130_fd_sc_hd__a22oi_1 U448 ( .A1(s_mem_q[561]), .A2(n550), .B1(
        s_mem_q[570]), .B2(n548), .Y(n254) );
  sky130_fd_sc_hd__a22oi_1 U449 ( .A1(s_mem_q[543]), .A2(n554), .B1(
        s_mem_q[552]), .B2(n552), .Y(n253) );
  sky130_fd_sc_hd__a22oi_1 U450 ( .A1(s_mem_q[525]), .A2(n559), .B1(
        s_mem_q[534]), .B2(n556), .Y(n252) );
  sky130_fd_sc_hd__a22oi_1 U451 ( .A1(s_mem_q[507]), .A2(n562), .B1(
        s_mem_q[516]), .B2(n560), .Y(n251) );
  sky130_fd_sc_hd__nand4_1 U452 ( .A(n254), .B(n253), .C(n252), .D(n251), .Y(
        n255) );
  sky130_fd_sc_hd__o21ai_0 U453 ( .A1(n256), .A2(n255), .B1(n475), .Y(n290) );
  sky130_fd_sc_hd__a22oi_1 U454 ( .A1(s_mem_q[345]), .A2(n537), .B1(
        s_mem_q[354]), .B2(n536), .Y(n260) );
  sky130_fd_sc_hd__a22oi_1 U455 ( .A1(s_mem_q[327]), .A2(n540), .B1(
        s_mem_q[336]), .B2(n539), .Y(n259) );
  sky130_fd_sc_hd__a22oi_1 U456 ( .A1(s_mem_q[309]), .A2(n543), .B1(
        s_mem_q[318]), .B2(n541), .Y(n258) );
  sky130_fd_sc_hd__a22oi_1 U457 ( .A1(s_mem_q[291]), .A2(n547), .B1(
        s_mem_q[300]), .B2(n545), .Y(n257) );
  sky130_fd_sc_hd__nand4_1 U458 ( .A(n260), .B(n259), .C(n258), .D(n257), .Y(
        n266) );
  sky130_fd_sc_hd__a22oi_1 U459 ( .A1(s_mem_q[417]), .A2(n550), .B1(
        s_mem_q[426]), .B2(n548), .Y(n264) );
  sky130_fd_sc_hd__a22oi_1 U460 ( .A1(s_mem_q[399]), .A2(n554), .B1(
        s_mem_q[408]), .B2(n552), .Y(n263) );
  sky130_fd_sc_hd__a22oi_1 U461 ( .A1(s_mem_q[381]), .A2(n559), .B1(
        s_mem_q[390]), .B2(n556), .Y(n262) );
  sky130_fd_sc_hd__a22oi_1 U462 ( .A1(s_mem_q[363]), .A2(n562), .B1(
        s_mem_q[372]), .B2(n560), .Y(n261) );
  sky130_fd_sc_hd__nand4_1 U463 ( .A(n264), .B(n263), .C(n262), .D(n261), .Y(
        n265) );
  sky130_fd_sc_hd__o21ai_0 U464 ( .A1(n266), .A2(n265), .B1(n486), .Y(n289) );
  sky130_fd_sc_hd__a22oi_1 U465 ( .A1(s_mem_q[201]), .A2(n537), .B1(
        s_mem_q[210]), .B2(n536), .Y(n270) );
  sky130_fd_sc_hd__a22oi_1 U466 ( .A1(s_mem_q[183]), .A2(n540), .B1(
        s_mem_q[192]), .B2(n539), .Y(n269) );
  sky130_fd_sc_hd__a22oi_1 U467 ( .A1(s_mem_q[165]), .A2(n543), .B1(
        s_mem_q[174]), .B2(n541), .Y(n268) );
  sky130_fd_sc_hd__a22oi_1 U468 ( .A1(s_mem_q[147]), .A2(n547), .B1(
        s_mem_q[156]), .B2(n545), .Y(n267) );
  sky130_fd_sc_hd__nand4_1 U469 ( .A(n270), .B(n269), .C(n268), .D(n267), .Y(
        n276) );
  sky130_fd_sc_hd__a22oi_1 U470 ( .A1(s_mem_q[273]), .A2(n550), .B1(
        s_mem_q[282]), .B2(n548), .Y(n274) );
  sky130_fd_sc_hd__a22oi_1 U471 ( .A1(s_mem_q[255]), .A2(n554), .B1(
        s_mem_q[264]), .B2(n552), .Y(n273) );
  sky130_fd_sc_hd__a22oi_1 U472 ( .A1(s_mem_q[237]), .A2(n559), .B1(
        s_mem_q[246]), .B2(n556), .Y(n272) );
  sky130_fd_sc_hd__a22oi_1 U473 ( .A1(s_mem_q[219]), .A2(n562), .B1(
        s_mem_q[228]), .B2(n560), .Y(n271) );
  sky130_fd_sc_hd__nand4_1 U474 ( .A(n274), .B(n273), .C(n272), .D(n271), .Y(
        n275) );
  sky130_fd_sc_hd__o21ai_0 U475 ( .A1(n276), .A2(n275), .B1(n497), .Y(n288) );
  sky130_fd_sc_hd__a22oi_1 U476 ( .A1(s_mem_q[57]), .A2(n537), .B1(s_mem_q[66]), .B2(n536), .Y(n280) );
  sky130_fd_sc_hd__a22oi_1 U477 ( .A1(s_mem_q[39]), .A2(n540), .B1(s_mem_q[48]), .B2(n539), .Y(n279) );
  sky130_fd_sc_hd__a22oi_1 U478 ( .A1(s_mem_q[21]), .A2(n543), .B1(s_mem_q[30]), .B2(n541), .Y(n278) );
  sky130_fd_sc_hd__a22oi_1 U479 ( .A1(s_mem_q[3]), .A2(n547), .B1(s_mem_q[12]), 
        .B2(n545), .Y(n277) );
  sky130_fd_sc_hd__nand4_1 U480 ( .A(n280), .B(n279), .C(n278), .D(n277), .Y(
        n286) );
  sky130_fd_sc_hd__a22oi_1 U481 ( .A1(s_mem_q[129]), .A2(n550), .B1(
        s_mem_q[138]), .B2(n548), .Y(n284) );
  sky130_fd_sc_hd__a22oi_1 U482 ( .A1(s_mem_q[111]), .A2(n554), .B1(
        s_mem_q[120]), .B2(n552), .Y(n283) );
  sky130_fd_sc_hd__a22oi_1 U483 ( .A1(s_mem_q[93]), .A2(n559), .B1(
        s_mem_q[102]), .B2(n556), .Y(n282) );
  sky130_fd_sc_hd__a22oi_1 U484 ( .A1(s_mem_q[75]), .A2(n562), .B1(s_mem_q[84]), .B2(n560), .Y(n281) );
  sky130_fd_sc_hd__nand4_1 U485 ( .A(n284), .B(n283), .C(n282), .D(n281), .Y(
        n285) );
  sky130_fd_sc_hd__o21ai_0 U486 ( .A1(n286), .A2(n285), .B1(n524), .Y(n287) );
  sky130_fd_sc_hd__nand4_1 U487 ( .A(n290), .B(n289), .C(n288), .D(n287), .Y(
        dat_o[3]) );
  sky130_fd_sc_hd__a22oi_1 U488 ( .A1(s_mem_q[490]), .A2(n537), .B1(
        s_mem_q[499]), .B2(n536), .Y(n294) );
  sky130_fd_sc_hd__a22oi_1 U489 ( .A1(s_mem_q[472]), .A2(n540), .B1(
        s_mem_q[481]), .B2(n539), .Y(n293) );
  sky130_fd_sc_hd__a22oi_1 U490 ( .A1(s_mem_q[454]), .A2(n543), .B1(
        s_mem_q[463]), .B2(n541), .Y(n292) );
  sky130_fd_sc_hd__a22oi_1 U491 ( .A1(s_mem_q[436]), .A2(n547), .B1(
        s_mem_q[445]), .B2(n545), .Y(n291) );
  sky130_fd_sc_hd__nand4_1 U492 ( .A(n294), .B(n293), .C(n292), .D(n291), .Y(
        n300) );
  sky130_fd_sc_hd__a22oi_1 U493 ( .A1(s_mem_q[562]), .A2(n550), .B1(
        s_mem_q[571]), .B2(n548), .Y(n298) );
  sky130_fd_sc_hd__a22oi_1 U494 ( .A1(s_mem_q[544]), .A2(n554), .B1(
        s_mem_q[553]), .B2(n552), .Y(n297) );
  sky130_fd_sc_hd__a22oi_1 U495 ( .A1(s_mem_q[526]), .A2(n559), .B1(
        s_mem_q[535]), .B2(n556), .Y(n296) );
  sky130_fd_sc_hd__a22oi_1 U496 ( .A1(s_mem_q[508]), .A2(n562), .B1(
        s_mem_q[517]), .B2(n560), .Y(n295) );
  sky130_fd_sc_hd__nand4_1 U497 ( .A(n298), .B(n297), .C(n296), .D(n295), .Y(
        n299) );
  sky130_fd_sc_hd__o21ai_0 U498 ( .A1(n300), .A2(n299), .B1(n475), .Y(n334) );
  sky130_fd_sc_hd__a22oi_1 U499 ( .A1(s_mem_q[346]), .A2(n537), .B1(
        s_mem_q[355]), .B2(n536), .Y(n304) );
  sky130_fd_sc_hd__a22oi_1 U500 ( .A1(s_mem_q[328]), .A2(n540), .B1(
        s_mem_q[337]), .B2(n539), .Y(n303) );
  sky130_fd_sc_hd__a22oi_1 U501 ( .A1(s_mem_q[310]), .A2(n543), .B1(
        s_mem_q[319]), .B2(n541), .Y(n302) );
  sky130_fd_sc_hd__a22oi_1 U502 ( .A1(s_mem_q[292]), .A2(n547), .B1(
        s_mem_q[301]), .B2(n545), .Y(n301) );
  sky130_fd_sc_hd__nand4_1 U503 ( .A(n304), .B(n303), .C(n302), .D(n301), .Y(
        n310) );
  sky130_fd_sc_hd__a22oi_1 U504 ( .A1(s_mem_q[418]), .A2(n550), .B1(
        s_mem_q[427]), .B2(n548), .Y(n308) );
  sky130_fd_sc_hd__a22oi_1 U505 ( .A1(s_mem_q[400]), .A2(n554), .B1(
        s_mem_q[409]), .B2(n552), .Y(n307) );
  sky130_fd_sc_hd__a22oi_1 U506 ( .A1(s_mem_q[382]), .A2(n559), .B1(
        s_mem_q[391]), .B2(n556), .Y(n306) );
  sky130_fd_sc_hd__a22oi_1 U507 ( .A1(s_mem_q[364]), .A2(n562), .B1(
        s_mem_q[373]), .B2(n560), .Y(n305) );
  sky130_fd_sc_hd__nand4_1 U508 ( .A(n308), .B(n307), .C(n306), .D(n305), .Y(
        n309) );
  sky130_fd_sc_hd__o21ai_0 U509 ( .A1(n310), .A2(n309), .B1(n486), .Y(n333) );
  sky130_fd_sc_hd__a22oi_1 U510 ( .A1(s_mem_q[202]), .A2(n537), .B1(
        s_mem_q[211]), .B2(n536), .Y(n314) );
  sky130_fd_sc_hd__a22oi_1 U511 ( .A1(s_mem_q[184]), .A2(n540), .B1(
        s_mem_q[193]), .B2(n539), .Y(n313) );
  sky130_fd_sc_hd__a22oi_1 U512 ( .A1(s_mem_q[166]), .A2(n543), .B1(
        s_mem_q[175]), .B2(n541), .Y(n312) );
  sky130_fd_sc_hd__a22oi_1 U513 ( .A1(s_mem_q[148]), .A2(n547), .B1(
        s_mem_q[157]), .B2(n545), .Y(n311) );
  sky130_fd_sc_hd__nand4_1 U514 ( .A(n314), .B(n313), .C(n312), .D(n311), .Y(
        n320) );
  sky130_fd_sc_hd__a22oi_1 U515 ( .A1(s_mem_q[274]), .A2(n550), .B1(
        s_mem_q[283]), .B2(n548), .Y(n318) );
  sky130_fd_sc_hd__a22oi_1 U516 ( .A1(s_mem_q[256]), .A2(n554), .B1(
        s_mem_q[265]), .B2(n552), .Y(n317) );
  sky130_fd_sc_hd__a22oi_1 U517 ( .A1(s_mem_q[238]), .A2(n559), .B1(
        s_mem_q[247]), .B2(n556), .Y(n316) );
  sky130_fd_sc_hd__a22oi_1 U518 ( .A1(s_mem_q[220]), .A2(n562), .B1(
        s_mem_q[229]), .B2(n560), .Y(n315) );
  sky130_fd_sc_hd__nand4_1 U519 ( .A(n318), .B(n317), .C(n316), .D(n315), .Y(
        n319) );
  sky130_fd_sc_hd__o21ai_0 U520 ( .A1(n320), .A2(n319), .B1(n497), .Y(n332) );
  sky130_fd_sc_hd__a22oi_1 U521 ( .A1(s_mem_q[58]), .A2(n537), .B1(s_mem_q[67]), .B2(n536), .Y(n324) );
  sky130_fd_sc_hd__a22oi_1 U522 ( .A1(s_mem_q[40]), .A2(n540), .B1(s_mem_q[49]), .B2(n539), .Y(n323) );
  sky130_fd_sc_hd__a22oi_1 U523 ( .A1(s_mem_q[22]), .A2(n543), .B1(s_mem_q[31]), .B2(n541), .Y(n322) );
  sky130_fd_sc_hd__a22oi_1 U524 ( .A1(s_mem_q[4]), .A2(n547), .B1(s_mem_q[13]), 
        .B2(n545), .Y(n321) );
  sky130_fd_sc_hd__nand4_1 U525 ( .A(n324), .B(n323), .C(n322), .D(n321), .Y(
        n330) );
  sky130_fd_sc_hd__a22oi_1 U526 ( .A1(s_mem_q[130]), .A2(n550), .B1(
        s_mem_q[139]), .B2(n548), .Y(n328) );
  sky130_fd_sc_hd__a22oi_1 U527 ( .A1(s_mem_q[112]), .A2(n554), .B1(
        s_mem_q[121]), .B2(n552), .Y(n327) );
  sky130_fd_sc_hd__a22oi_1 U528 ( .A1(s_mem_q[94]), .A2(n559), .B1(
        s_mem_q[103]), .B2(n556), .Y(n326) );
  sky130_fd_sc_hd__a22oi_1 U529 ( .A1(s_mem_q[76]), .A2(n562), .B1(s_mem_q[85]), .B2(n560), .Y(n325) );
  sky130_fd_sc_hd__nand4_1 U530 ( .A(n328), .B(n327), .C(n326), .D(n325), .Y(
        n329) );
  sky130_fd_sc_hd__o21ai_0 U531 ( .A1(n330), .A2(n329), .B1(n524), .Y(n331) );
  sky130_fd_sc_hd__nand4_1 U532 ( .A(n334), .B(n333), .C(n332), .D(n331), .Y(
        dat_o[4]) );
  sky130_fd_sc_hd__a22oi_1 U533 ( .A1(s_mem_q[491]), .A2(n537), .B1(
        s_mem_q[500]), .B2(n536), .Y(n338) );
  sky130_fd_sc_hd__a22oi_1 U534 ( .A1(s_mem_q[473]), .A2(n540), .B1(
        s_mem_q[482]), .B2(n539), .Y(n337) );
  sky130_fd_sc_hd__a22oi_1 U535 ( .A1(s_mem_q[455]), .A2(n543), .B1(
        s_mem_q[464]), .B2(n541), .Y(n336) );
  sky130_fd_sc_hd__a22oi_1 U536 ( .A1(s_mem_q[437]), .A2(n547), .B1(
        s_mem_q[446]), .B2(n545), .Y(n335) );
  sky130_fd_sc_hd__nand4_1 U537 ( .A(n338), .B(n337), .C(n336), .D(n335), .Y(
        n344) );
  sky130_fd_sc_hd__a22oi_1 U538 ( .A1(s_mem_q[563]), .A2(n550), .B1(
        s_mem_q[572]), .B2(n548), .Y(n342) );
  sky130_fd_sc_hd__a22oi_1 U539 ( .A1(s_mem_q[545]), .A2(n554), .B1(
        s_mem_q[554]), .B2(n552), .Y(n341) );
  sky130_fd_sc_hd__a22oi_1 U540 ( .A1(s_mem_q[527]), .A2(n559), .B1(
        s_mem_q[536]), .B2(n556), .Y(n340) );
  sky130_fd_sc_hd__a22oi_1 U541 ( .A1(s_mem_q[509]), .A2(n562), .B1(
        s_mem_q[518]), .B2(n560), .Y(n339) );
  sky130_fd_sc_hd__nand4_1 U542 ( .A(n342), .B(n341), .C(n340), .D(n339), .Y(
        n343) );
  sky130_fd_sc_hd__o21ai_0 U543 ( .A1(n344), .A2(n343), .B1(n475), .Y(n378) );
  sky130_fd_sc_hd__a22oi_1 U544 ( .A1(s_mem_q[347]), .A2(n537), .B1(
        s_mem_q[356]), .B2(n536), .Y(n348) );
  sky130_fd_sc_hd__a22oi_1 U545 ( .A1(s_mem_q[329]), .A2(n540), .B1(
        s_mem_q[338]), .B2(n539), .Y(n347) );
  sky130_fd_sc_hd__a22oi_1 U546 ( .A1(s_mem_q[311]), .A2(n543), .B1(
        s_mem_q[320]), .B2(n541), .Y(n346) );
  sky130_fd_sc_hd__a22oi_1 U547 ( .A1(s_mem_q[293]), .A2(n547), .B1(
        s_mem_q[302]), .B2(n545), .Y(n345) );
  sky130_fd_sc_hd__nand4_1 U548 ( .A(n348), .B(n347), .C(n346), .D(n345), .Y(
        n354) );
  sky130_fd_sc_hd__a22oi_1 U549 ( .A1(s_mem_q[419]), .A2(n550), .B1(
        s_mem_q[428]), .B2(n548), .Y(n352) );
  sky130_fd_sc_hd__a22oi_1 U550 ( .A1(s_mem_q[401]), .A2(n554), .B1(
        s_mem_q[410]), .B2(n552), .Y(n351) );
  sky130_fd_sc_hd__a22oi_1 U551 ( .A1(s_mem_q[383]), .A2(n559), .B1(
        s_mem_q[392]), .B2(n556), .Y(n350) );
  sky130_fd_sc_hd__a22oi_1 U552 ( .A1(s_mem_q[365]), .A2(n562), .B1(
        s_mem_q[374]), .B2(n560), .Y(n349) );
  sky130_fd_sc_hd__nand4_1 U553 ( .A(n352), .B(n351), .C(n350), .D(n349), .Y(
        n353) );
  sky130_fd_sc_hd__o21ai_0 U554 ( .A1(n354), .A2(n353), .B1(n486), .Y(n377) );
  sky130_fd_sc_hd__a22oi_1 U555 ( .A1(s_mem_q[203]), .A2(n537), .B1(
        s_mem_q[212]), .B2(n536), .Y(n358) );
  sky130_fd_sc_hd__a22oi_1 U556 ( .A1(s_mem_q[185]), .A2(n540), .B1(
        s_mem_q[194]), .B2(n539), .Y(n357) );
  sky130_fd_sc_hd__a22oi_1 U557 ( .A1(s_mem_q[167]), .A2(n543), .B1(
        s_mem_q[176]), .B2(n541), .Y(n356) );
  sky130_fd_sc_hd__a22oi_1 U558 ( .A1(s_mem_q[149]), .A2(n547), .B1(
        s_mem_q[158]), .B2(n545), .Y(n355) );
  sky130_fd_sc_hd__nand4_1 U559 ( .A(n358), .B(n357), .C(n356), .D(n355), .Y(
        n364) );
  sky130_fd_sc_hd__a22oi_1 U560 ( .A1(s_mem_q[275]), .A2(n550), .B1(
        s_mem_q[284]), .B2(n548), .Y(n362) );
  sky130_fd_sc_hd__a22oi_1 U561 ( .A1(s_mem_q[257]), .A2(n554), .B1(
        s_mem_q[266]), .B2(n552), .Y(n361) );
  sky130_fd_sc_hd__a22oi_1 U562 ( .A1(s_mem_q[239]), .A2(n559), .B1(
        s_mem_q[248]), .B2(n556), .Y(n360) );
  sky130_fd_sc_hd__a22oi_1 U563 ( .A1(s_mem_q[221]), .A2(n562), .B1(
        s_mem_q[230]), .B2(n560), .Y(n359) );
  sky130_fd_sc_hd__nand4_1 U564 ( .A(n362), .B(n361), .C(n360), .D(n359), .Y(
        n363) );
  sky130_fd_sc_hd__o21ai_0 U565 ( .A1(n364), .A2(n363), .B1(n497), .Y(n376) );
  sky130_fd_sc_hd__a22oi_1 U566 ( .A1(s_mem_q[59]), .A2(n538), .B1(s_mem_q[68]), .B2(n536), .Y(n368) );
  sky130_fd_sc_hd__a22oi_1 U567 ( .A1(s_mem_q[41]), .A2(n540), .B1(s_mem_q[50]), .B2(n539), .Y(n367) );
  sky130_fd_sc_hd__a22oi_1 U568 ( .A1(s_mem_q[23]), .A2(n544), .B1(s_mem_q[32]), .B2(n542), .Y(n366) );
  sky130_fd_sc_hd__a22oi_1 U569 ( .A1(s_mem_q[5]), .A2(n547), .B1(s_mem_q[14]), 
        .B2(n546), .Y(n365) );
  sky130_fd_sc_hd__nand4_1 U570 ( .A(n368), .B(n367), .C(n366), .D(n365), .Y(
        n374) );
  sky130_fd_sc_hd__a22oi_1 U571 ( .A1(s_mem_q[131]), .A2(n551), .B1(
        s_mem_q[140]), .B2(n549), .Y(n372) );
  sky130_fd_sc_hd__a22oi_1 U572 ( .A1(s_mem_q[113]), .A2(n555), .B1(
        s_mem_q[122]), .B2(n553), .Y(n371) );
  sky130_fd_sc_hd__a22oi_1 U573 ( .A1(s_mem_q[95]), .A2(n558), .B1(
        s_mem_q[104]), .B2(n557), .Y(n370) );
  sky130_fd_sc_hd__a22oi_1 U574 ( .A1(s_mem_q[77]), .A2(n563), .B1(s_mem_q[86]), .B2(n561), .Y(n369) );
  sky130_fd_sc_hd__nand4_1 U575 ( .A(n372), .B(n371), .C(n370), .D(n369), .Y(
        n373) );
  sky130_fd_sc_hd__o21ai_0 U576 ( .A1(n374), .A2(n373), .B1(n524), .Y(n375) );
  sky130_fd_sc_hd__nand4_1 U577 ( .A(n378), .B(n377), .C(n376), .D(n375), .Y(
        dat_o[5]) );
  sky130_fd_sc_hd__a22oi_1 U578 ( .A1(s_mem_q[492]), .A2(n538), .B1(
        s_mem_q[501]), .B2(n536), .Y(n382) );
  sky130_fd_sc_hd__a22oi_1 U579 ( .A1(s_mem_q[474]), .A2(n540), .B1(
        s_mem_q[483]), .B2(n539), .Y(n381) );
  sky130_fd_sc_hd__a22oi_1 U580 ( .A1(s_mem_q[456]), .A2(n544), .B1(
        s_mem_q[465]), .B2(n542), .Y(n380) );
  sky130_fd_sc_hd__a22oi_1 U581 ( .A1(s_mem_q[438]), .A2(n547), .B1(
        s_mem_q[447]), .B2(n546), .Y(n379) );
  sky130_fd_sc_hd__nand4_1 U582 ( .A(n382), .B(n381), .C(n380), .D(n379), .Y(
        n388) );
  sky130_fd_sc_hd__a22oi_1 U583 ( .A1(s_mem_q[564]), .A2(n551), .B1(
        s_mem_q[573]), .B2(n549), .Y(n386) );
  sky130_fd_sc_hd__a22oi_1 U584 ( .A1(s_mem_q[546]), .A2(n555), .B1(
        s_mem_q[555]), .B2(n553), .Y(n385) );
  sky130_fd_sc_hd__a22oi_1 U585 ( .A1(s_mem_q[528]), .A2(n558), .B1(
        s_mem_q[537]), .B2(n557), .Y(n384) );
  sky130_fd_sc_hd__a22oi_1 U586 ( .A1(s_mem_q[510]), .A2(n563), .B1(
        s_mem_q[519]), .B2(n561), .Y(n383) );
  sky130_fd_sc_hd__nand4_1 U587 ( .A(n386), .B(n385), .C(n384), .D(n383), .Y(
        n387) );
  sky130_fd_sc_hd__o21ai_0 U588 ( .A1(n388), .A2(n387), .B1(n475), .Y(n422) );
  sky130_fd_sc_hd__a22oi_1 U589 ( .A1(s_mem_q[348]), .A2(n538), .B1(
        s_mem_q[357]), .B2(n536), .Y(n392) );
  sky130_fd_sc_hd__a22oi_1 U590 ( .A1(s_mem_q[330]), .A2(n540), .B1(
        s_mem_q[339]), .B2(n539), .Y(n391) );
  sky130_fd_sc_hd__a22oi_1 U591 ( .A1(s_mem_q[312]), .A2(n544), .B1(
        s_mem_q[321]), .B2(n542), .Y(n390) );
  sky130_fd_sc_hd__a22oi_1 U592 ( .A1(s_mem_q[294]), .A2(n547), .B1(
        s_mem_q[303]), .B2(n546), .Y(n389) );
  sky130_fd_sc_hd__nand4_1 U593 ( .A(n392), .B(n391), .C(n390), .D(n389), .Y(
        n398) );
  sky130_fd_sc_hd__a22oi_1 U594 ( .A1(s_mem_q[420]), .A2(n551), .B1(
        s_mem_q[429]), .B2(n549), .Y(n396) );
  sky130_fd_sc_hd__a22oi_1 U595 ( .A1(s_mem_q[402]), .A2(n555), .B1(
        s_mem_q[411]), .B2(n553), .Y(n395) );
  sky130_fd_sc_hd__a22oi_1 U596 ( .A1(s_mem_q[384]), .A2(n558), .B1(
        s_mem_q[393]), .B2(n557), .Y(n394) );
  sky130_fd_sc_hd__a22oi_1 U597 ( .A1(s_mem_q[366]), .A2(n563), .B1(
        s_mem_q[375]), .B2(n561), .Y(n393) );
  sky130_fd_sc_hd__nand4_1 U598 ( .A(n396), .B(n395), .C(n394), .D(n393), .Y(
        n397) );
  sky130_fd_sc_hd__o21ai_0 U599 ( .A1(n398), .A2(n397), .B1(n486), .Y(n421) );
  sky130_fd_sc_hd__a22oi_1 U600 ( .A1(s_mem_q[204]), .A2(n538), .B1(
        s_mem_q[213]), .B2(n536), .Y(n402) );
  sky130_fd_sc_hd__a22oi_1 U601 ( .A1(s_mem_q[186]), .A2(n540), .B1(
        s_mem_q[195]), .B2(n539), .Y(n401) );
  sky130_fd_sc_hd__a22oi_1 U602 ( .A1(s_mem_q[168]), .A2(n544), .B1(
        s_mem_q[177]), .B2(n542), .Y(n400) );
  sky130_fd_sc_hd__a22oi_1 U603 ( .A1(s_mem_q[150]), .A2(n547), .B1(
        s_mem_q[159]), .B2(n546), .Y(n399) );
  sky130_fd_sc_hd__nand4_1 U604 ( .A(n402), .B(n401), .C(n400), .D(n399), .Y(
        n408) );
  sky130_fd_sc_hd__a22oi_1 U605 ( .A1(s_mem_q[276]), .A2(n551), .B1(
        s_mem_q[285]), .B2(n549), .Y(n406) );
  sky130_fd_sc_hd__a22oi_1 U606 ( .A1(s_mem_q[258]), .A2(n555), .B1(
        s_mem_q[267]), .B2(n553), .Y(n405) );
  sky130_fd_sc_hd__a22oi_1 U607 ( .A1(s_mem_q[240]), .A2(n558), .B1(
        s_mem_q[249]), .B2(n557), .Y(n404) );
  sky130_fd_sc_hd__a22oi_1 U608 ( .A1(s_mem_q[222]), .A2(n563), .B1(
        s_mem_q[231]), .B2(n561), .Y(n403) );
  sky130_fd_sc_hd__nand4_1 U609 ( .A(n406), .B(n405), .C(n404), .D(n403), .Y(
        n407) );
  sky130_fd_sc_hd__o21ai_0 U610 ( .A1(n408), .A2(n407), .B1(n497), .Y(n420) );
  sky130_fd_sc_hd__a22oi_1 U611 ( .A1(s_mem_q[60]), .A2(n538), .B1(s_mem_q[69]), .B2(n536), .Y(n412) );
  sky130_fd_sc_hd__a22oi_1 U612 ( .A1(s_mem_q[42]), .A2(n540), .B1(s_mem_q[51]), .B2(n539), .Y(n411) );
  sky130_fd_sc_hd__a22oi_1 U613 ( .A1(s_mem_q[24]), .A2(n544), .B1(s_mem_q[33]), .B2(n542), .Y(n410) );
  sky130_fd_sc_hd__a22oi_1 U614 ( .A1(s_mem_q[6]), .A2(n547), .B1(s_mem_q[15]), 
        .B2(n546), .Y(n409) );
  sky130_fd_sc_hd__nand4_1 U615 ( .A(n412), .B(n411), .C(n410), .D(n409), .Y(
        n418) );
  sky130_fd_sc_hd__a22oi_1 U616 ( .A1(s_mem_q[132]), .A2(n551), .B1(
        s_mem_q[141]), .B2(n549), .Y(n416) );
  sky130_fd_sc_hd__a22oi_1 U617 ( .A1(s_mem_q[114]), .A2(n555), .B1(
        s_mem_q[123]), .B2(n553), .Y(n415) );
  sky130_fd_sc_hd__a22oi_1 U618 ( .A1(s_mem_q[96]), .A2(n559), .B1(
        s_mem_q[105]), .B2(n557), .Y(n414) );
  sky130_fd_sc_hd__a22oi_1 U619 ( .A1(s_mem_q[78]), .A2(n563), .B1(s_mem_q[87]), .B2(n561), .Y(n413) );
  sky130_fd_sc_hd__nand4_1 U620 ( .A(n416), .B(n415), .C(n414), .D(n413), .Y(
        n417) );
  sky130_fd_sc_hd__o21ai_0 U621 ( .A1(n418), .A2(n417), .B1(n524), .Y(n419) );
  sky130_fd_sc_hd__nand4_1 U622 ( .A(n422), .B(n421), .C(n420), .D(n419), .Y(
        dat_o[6]) );
  sky130_fd_sc_hd__a22oi_1 U623 ( .A1(s_mem_q[493]), .A2(n538), .B1(
        s_mem_q[502]), .B2(n536), .Y(n426) );
  sky130_fd_sc_hd__a22oi_1 U624 ( .A1(s_mem_q[475]), .A2(n540), .B1(
        s_mem_q[484]), .B2(n539), .Y(n425) );
  sky130_fd_sc_hd__a22oi_1 U625 ( .A1(s_mem_q[457]), .A2(n544), .B1(
        s_mem_q[466]), .B2(n542), .Y(n424) );
  sky130_fd_sc_hd__a22oi_1 U626 ( .A1(s_mem_q[439]), .A2(n547), .B1(
        s_mem_q[448]), .B2(n546), .Y(n423) );
  sky130_fd_sc_hd__nand4_1 U627 ( .A(n426), .B(n425), .C(n424), .D(n423), .Y(
        n432) );
  sky130_fd_sc_hd__a22oi_1 U628 ( .A1(s_mem_q[565]), .A2(n551), .B1(
        s_mem_q[574]), .B2(n549), .Y(n430) );
  sky130_fd_sc_hd__a22oi_1 U629 ( .A1(s_mem_q[547]), .A2(n555), .B1(
        s_mem_q[556]), .B2(n553), .Y(n429) );
  sky130_fd_sc_hd__a22oi_1 U630 ( .A1(s_mem_q[529]), .A2(n558), .B1(
        s_mem_q[538]), .B2(n557), .Y(n428) );
  sky130_fd_sc_hd__a22oi_1 U631 ( .A1(s_mem_q[511]), .A2(n563), .B1(
        s_mem_q[520]), .B2(n561), .Y(n427) );
  sky130_fd_sc_hd__nand4_1 U632 ( .A(n430), .B(n429), .C(n428), .D(n427), .Y(
        n431) );
  sky130_fd_sc_hd__o21ai_0 U633 ( .A1(n432), .A2(n431), .B1(n475), .Y(n466) );
  sky130_fd_sc_hd__a22oi_1 U634 ( .A1(s_mem_q[349]), .A2(n538), .B1(
        s_mem_q[358]), .B2(n536), .Y(n436) );
  sky130_fd_sc_hd__a22oi_1 U635 ( .A1(s_mem_q[331]), .A2(n540), .B1(
        s_mem_q[340]), .B2(n539), .Y(n435) );
  sky130_fd_sc_hd__a22oi_1 U636 ( .A1(s_mem_q[313]), .A2(n544), .B1(
        s_mem_q[322]), .B2(n542), .Y(n434) );
  sky130_fd_sc_hd__a22oi_1 U637 ( .A1(s_mem_q[295]), .A2(n547), .B1(
        s_mem_q[304]), .B2(n546), .Y(n433) );
  sky130_fd_sc_hd__nand4_1 U638 ( .A(n436), .B(n435), .C(n434), .D(n433), .Y(
        n442) );
  sky130_fd_sc_hd__a22oi_1 U639 ( .A1(s_mem_q[421]), .A2(n551), .B1(
        s_mem_q[430]), .B2(n549), .Y(n440) );
  sky130_fd_sc_hd__a22oi_1 U640 ( .A1(s_mem_q[403]), .A2(n555), .B1(
        s_mem_q[412]), .B2(n553), .Y(n439) );
  sky130_fd_sc_hd__a22oi_1 U641 ( .A1(s_mem_q[385]), .A2(n559), .B1(
        s_mem_q[394]), .B2(n557), .Y(n438) );
  sky130_fd_sc_hd__a22oi_1 U642 ( .A1(s_mem_q[367]), .A2(n563), .B1(
        s_mem_q[376]), .B2(n561), .Y(n437) );
  sky130_fd_sc_hd__nand4_1 U643 ( .A(n440), .B(n439), .C(n438), .D(n437), .Y(
        n441) );
  sky130_fd_sc_hd__o21ai_0 U644 ( .A1(n442), .A2(n441), .B1(n486), .Y(n465) );
  sky130_fd_sc_hd__a22oi_1 U645 ( .A1(s_mem_q[205]), .A2(n538), .B1(
        s_mem_q[214]), .B2(n536), .Y(n446) );
  sky130_fd_sc_hd__a22oi_1 U646 ( .A1(s_mem_q[187]), .A2(n540), .B1(
        s_mem_q[196]), .B2(n539), .Y(n445) );
  sky130_fd_sc_hd__a22oi_1 U647 ( .A1(s_mem_q[169]), .A2(n544), .B1(
        s_mem_q[178]), .B2(n542), .Y(n444) );
  sky130_fd_sc_hd__a22oi_1 U648 ( .A1(s_mem_q[151]), .A2(n547), .B1(
        s_mem_q[160]), .B2(n546), .Y(n443) );
  sky130_fd_sc_hd__nand4_1 U649 ( .A(n446), .B(n445), .C(n444), .D(n443), .Y(
        n452) );
  sky130_fd_sc_hd__a22oi_1 U650 ( .A1(s_mem_q[277]), .A2(n551), .B1(
        s_mem_q[286]), .B2(n549), .Y(n450) );
  sky130_fd_sc_hd__a22oi_1 U651 ( .A1(s_mem_q[259]), .A2(n555), .B1(
        s_mem_q[268]), .B2(n553), .Y(n449) );
  sky130_fd_sc_hd__a22oi_1 U652 ( .A1(s_mem_q[241]), .A2(n558), .B1(
        s_mem_q[250]), .B2(n557), .Y(n448) );
  sky130_fd_sc_hd__a22oi_1 U653 ( .A1(s_mem_q[223]), .A2(n563), .B1(
        s_mem_q[232]), .B2(n561), .Y(n447) );
  sky130_fd_sc_hd__nand4_1 U654 ( .A(n450), .B(n449), .C(n448), .D(n447), .Y(
        n451) );
  sky130_fd_sc_hd__o21ai_0 U655 ( .A1(n452), .A2(n451), .B1(n497), .Y(n464) );
  sky130_fd_sc_hd__a22oi_1 U656 ( .A1(s_mem_q[61]), .A2(n538), .B1(s_mem_q[70]), .B2(n536), .Y(n456) );
  sky130_fd_sc_hd__a22oi_1 U657 ( .A1(s_mem_q[43]), .A2(n540), .B1(s_mem_q[52]), .B2(n539), .Y(n455) );
  sky130_fd_sc_hd__a22oi_1 U658 ( .A1(s_mem_q[25]), .A2(n544), .B1(s_mem_q[34]), .B2(n542), .Y(n454) );
  sky130_fd_sc_hd__a22oi_1 U659 ( .A1(s_mem_q[7]), .A2(n547), .B1(s_mem_q[16]), 
        .B2(n546), .Y(n453) );
  sky130_fd_sc_hd__nand4_1 U660 ( .A(n456), .B(n455), .C(n454), .D(n453), .Y(
        n462) );
  sky130_fd_sc_hd__a22oi_1 U661 ( .A1(s_mem_q[133]), .A2(n551), .B1(
        s_mem_q[142]), .B2(n549), .Y(n460) );
  sky130_fd_sc_hd__a22oi_1 U662 ( .A1(s_mem_q[115]), .A2(n555), .B1(
        s_mem_q[124]), .B2(n553), .Y(n459) );
  sky130_fd_sc_hd__a22oi_1 U663 ( .A1(s_mem_q[97]), .A2(n559), .B1(
        s_mem_q[106]), .B2(n557), .Y(n458) );
  sky130_fd_sc_hd__a22oi_1 U664 ( .A1(s_mem_q[79]), .A2(n563), .B1(s_mem_q[88]), .B2(n561), .Y(n457) );
  sky130_fd_sc_hd__nand4_1 U665 ( .A(n460), .B(n459), .C(n458), .D(n457), .Y(
        n461) );
  sky130_fd_sc_hd__o21ai_0 U666 ( .A1(n462), .A2(n461), .B1(n524), .Y(n463) );
  sky130_fd_sc_hd__nand4_1 U667 ( .A(n466), .B(n465), .C(n464), .D(n463), .Y(
        dat_o[7]) );
  sky130_fd_sc_hd__a22oi_1 U668 ( .A1(s_mem_q[494]), .A2(n538), .B1(
        s_mem_q[503]), .B2(n500), .Y(n470) );
  sky130_fd_sc_hd__a22oi_1 U669 ( .A1(s_mem_q[476]), .A2(n503), .B1(
        s_mem_q[485]), .B2(n502), .Y(n469) );
  sky130_fd_sc_hd__a22oi_1 U670 ( .A1(s_mem_q[458]), .A2(n544), .B1(
        s_mem_q[467]), .B2(n542), .Y(n468) );
  sky130_fd_sc_hd__a22oi_1 U671 ( .A1(s_mem_q[440]), .A2(n507), .B1(
        s_mem_q[449]), .B2(n546), .Y(n467) );
  sky130_fd_sc_hd__nand4_1 U672 ( .A(n470), .B(n469), .C(n468), .D(n467), .Y(
        n477) );
  sky130_fd_sc_hd__a22oi_1 U673 ( .A1(s_mem_q[566]), .A2(n551), .B1(
        s_mem_q[575]), .B2(n549), .Y(n474) );
  sky130_fd_sc_hd__a22oi_1 U674 ( .A1(s_mem_q[548]), .A2(n555), .B1(
        s_mem_q[557]), .B2(n553), .Y(n473) );
  sky130_fd_sc_hd__a22oi_1 U675 ( .A1(s_mem_q[530]), .A2(n517), .B1(
        s_mem_q[539]), .B2(n557), .Y(n472) );
  sky130_fd_sc_hd__a22oi_1 U676 ( .A1(s_mem_q[512]), .A2(n563), .B1(
        s_mem_q[521]), .B2(n561), .Y(n471) );
  sky130_fd_sc_hd__nand4_1 U677 ( .A(n474), .B(n473), .C(n472), .D(n471), .Y(
        n476) );
  sky130_fd_sc_hd__a22oi_1 U678 ( .A1(s_mem_q[350]), .A2(n538), .B1(
        s_mem_q[359]), .B2(n500), .Y(n481) );
  sky130_fd_sc_hd__a22oi_1 U679 ( .A1(s_mem_q[332]), .A2(n503), .B1(
        s_mem_q[341]), .B2(n502), .Y(n480) );
  sky130_fd_sc_hd__a22oi_1 U680 ( .A1(s_mem_q[314]), .A2(n544), .B1(
        s_mem_q[323]), .B2(n542), .Y(n479) );
  sky130_fd_sc_hd__a22oi_1 U681 ( .A1(s_mem_q[296]), .A2(n507), .B1(
        s_mem_q[305]), .B2(n546), .Y(n478) );
  sky130_fd_sc_hd__nand4_1 U682 ( .A(n481), .B(n480), .C(n479), .D(n478), .Y(
        n488) );
  sky130_fd_sc_hd__a22oi_1 U683 ( .A1(s_mem_q[422]), .A2(n551), .B1(
        s_mem_q[431]), .B2(n549), .Y(n485) );
  sky130_fd_sc_hd__a22oi_1 U684 ( .A1(s_mem_q[404]), .A2(n555), .B1(
        s_mem_q[413]), .B2(n553), .Y(n484) );
  sky130_fd_sc_hd__a22oi_1 U685 ( .A1(s_mem_q[386]), .A2(n517), .B1(
        s_mem_q[395]), .B2(n557), .Y(n483) );
  sky130_fd_sc_hd__a22oi_1 U686 ( .A1(s_mem_q[368]), .A2(n563), .B1(
        s_mem_q[377]), .B2(n561), .Y(n482) );
  sky130_fd_sc_hd__nand4_1 U687 ( .A(n485), .B(n484), .C(n483), .D(n482), .Y(
        n487) );
  sky130_fd_sc_hd__a22oi_1 U688 ( .A1(s_mem_q[206]), .A2(n538), .B1(
        s_mem_q[215]), .B2(n500), .Y(n492) );
  sky130_fd_sc_hd__a22oi_1 U689 ( .A1(s_mem_q[188]), .A2(n503), .B1(
        s_mem_q[197]), .B2(n502), .Y(n491) );
  sky130_fd_sc_hd__a22oi_1 U690 ( .A1(s_mem_q[170]), .A2(n544), .B1(
        s_mem_q[179]), .B2(n542), .Y(n490) );
  sky130_fd_sc_hd__a22oi_1 U691 ( .A1(s_mem_q[152]), .A2(n507), .B1(
        s_mem_q[161]), .B2(n546), .Y(n489) );
  sky130_fd_sc_hd__nand4_1 U692 ( .A(n492), .B(n491), .C(n490), .D(n489), .Y(
        n499) );
  sky130_fd_sc_hd__a22oi_1 U693 ( .A1(s_mem_q[278]), .A2(n551), .B1(
        s_mem_q[287]), .B2(n549), .Y(n496) );
  sky130_fd_sc_hd__a22oi_1 U694 ( .A1(s_mem_q[260]), .A2(n555), .B1(
        s_mem_q[269]), .B2(n553), .Y(n495) );
  sky130_fd_sc_hd__a22oi_1 U695 ( .A1(s_mem_q[242]), .A2(n517), .B1(
        s_mem_q[251]), .B2(n557), .Y(n494) );
  sky130_fd_sc_hd__a22oi_1 U696 ( .A1(s_mem_q[224]), .A2(n563), .B1(
        s_mem_q[233]), .B2(n561), .Y(n493) );
  sky130_fd_sc_hd__nand4_1 U697 ( .A(n496), .B(n495), .C(n494), .D(n493), .Y(
        n498) );
  sky130_fd_sc_hd__a22oi_1 U698 ( .A1(s_mem_q[62]), .A2(n538), .B1(s_mem_q[71]), .B2(n500), .Y(n511) );
  sky130_fd_sc_hd__a22oi_1 U699 ( .A1(s_mem_q[44]), .A2(n503), .B1(s_mem_q[53]), .B2(n502), .Y(n510) );
  sky130_fd_sc_hd__a22oi_1 U700 ( .A1(s_mem_q[26]), .A2(n544), .B1(s_mem_q[35]), .B2(n542), .Y(n509) );
  sky130_fd_sc_hd__a22oi_1 U701 ( .A1(s_mem_q[8]), .A2(n507), .B1(s_mem_q[17]), 
        .B2(n546), .Y(n508) );
  sky130_fd_sc_hd__nand4_1 U702 ( .A(n511), .B(n510), .C(n509), .D(n508), .Y(
        n526) );
  sky130_fd_sc_hd__a22oi_1 U703 ( .A1(s_mem_q[134]), .A2(n551), .B1(
        s_mem_q[143]), .B2(n549), .Y(n523) );
  sky130_fd_sc_hd__a22oi_1 U704 ( .A1(s_mem_q[116]), .A2(n555), .B1(
        s_mem_q[125]), .B2(n553), .Y(n522) );
  sky130_fd_sc_hd__a22oi_1 U705 ( .A1(s_mem_q[98]), .A2(n517), .B1(
        s_mem_q[107]), .B2(n557), .Y(n521) );
  sky130_fd_sc_hd__a22oi_1 U706 ( .A1(s_mem_q[80]), .A2(n563), .B1(s_mem_q[89]), .B2(n561), .Y(n520) );
  sky130_fd_sc_hd__nand4_1 U707 ( .A(n523), .B(n522), .C(n521), .D(n520), .Y(
        n525) );
  sky130_fd_sc_hd__nand4_1 U708 ( .A(n530), .B(n529), .C(n528), .D(n527), .Y(
        dat_o[8]) );
  sky130_fd_sc_hd__buf_6 U709 ( .A(n518), .X(n561) );
  sky130_fd_sc_hd__buf_6 U710 ( .A(n519), .X(n563) );
  sky130_fd_sc_hd__o21ai_1 U711 ( .A1(n526), .A2(n525), .B1(n524), .Y(n527) );
  sky130_fd_sc_hd__inv_1 U712 ( .A(n601), .Y(n564) );
  sky130_fd_sc_hd__nand2_1 U713 ( .A(n591), .B(n1421), .Y(n1433) );
  sky130_fd_sc_hd__inv_2 U714 ( .A(n1433), .Y(n601) );
  sky130_fd_sc_hd__a2bb2o_1 U715 ( .A1_N(n1433), .A2_N(n533), .B1(N86), .B2(
        n1432), .X(s_rd_ptr_d[2]) );
  sky130_fd_sc_hd__a2bb2o_1 U716 ( .A1_N(n564), .A2_N(n531), .B1(n531), .B2(
        n1432), .X(s_rd_ptr_d[0]) );
  sky130_fd_sc_hd__a2bb2o_1 U717 ( .A1_N(n564), .A2_N(n532), .B1(N85), .B2(
        n1432), .X(s_rd_ptr_d[1]) );
  sky130_fd_sc_hd__a2bb2o_1 U718 ( .A1_N(n564), .A2_N(n1431), .B1(N87), .B2(
        n1432), .X(s_rd_ptr_d[3]) );
  sky130_fd_sc_hd__inv_1 U719 ( .A(n591), .Y(n600) );
  sky130_fd_sc_hd__inv_1 U720 ( .A(n1438), .Y(n565) );
  sky130_fd_sc_hd__inv_1 U721 ( .A(n611), .Y(n567) );
  sky130_fd_sc_hd__inv_2 U722 ( .A(n567), .Y(n568) );
  sky130_fd_sc_hd__inv_2 U723 ( .A(n627), .Y(n620) );
  sky130_fd_sc_hd__buf_6 U724 ( .A(n1401), .X(n575) );
  sky130_fd_sc_hd__buf_2 U725 ( .A(n1401), .X(n576) );
  sky130_fd_sc_hd__dlygate4sd3_1 U726 ( .A(n603), .X(n570) );
  sky130_fd_sc_hd__inv_1 U727 ( .A(n593), .Y(n597) );
  sky130_fd_sc_hd__nand3_2 U728 ( .A(n587), .B(n608), .C(n585), .Y(n586) );
  sky130_fd_sc_hd__inv_2 U729 ( .A(n1441), .Y(n585) );
  sky130_fd_sc_hd__and4_1 U730 ( .A(n617), .B(n585), .C(n1435), .D(n573), .X(
        n589) );
  sky130_fd_sc_hd__and2_2 U731 ( .A(n568), .B(n589), .X(empty_o) );
  sky130_fd_sc_hd__inv_1 U732 ( .A(n588), .Y(n611) );
  sky130_fd_sc_hd__inv_1 U733 ( .A(n617), .Y(cnt_o[4]) );
  sky130_fd_sc_hd__inv_1 U734 ( .A(n1439), .Y(n573) );
  sky130_fd_sc_hd__inv_2 U735 ( .A(n573), .Y(cnt_o[5]) );
  sky130_fd_sc_hd__nor2_1 U736 ( .A(cnt_o[2]), .B(n1441), .Y(n598) );
  sky130_fd_sc_hd__inv_1 U737 ( .A(cnt_o[1]), .Y(n596) );
  sky130_fd_sc_hd__o21ai_0 U738 ( .A1(n568), .A2(n627), .B1(n621), .Y(n612) );
  sky130_fd_sc_hd__o21ai_0 U739 ( .A1(n627), .A2(n570), .B1(n621), .Y(n604) );
  sky130_fd_sc_hd__o31ai_4 U740 ( .A1(n594), .A2(n593), .A3(n586), .B1(push_i), 
        .Y(n1422) );
  sky130_fd_sc_hd__nand2_4 U741 ( .A(n720), .B(n1315), .Y(n644) );
  sky130_fd_sc_hd__nand2_4 U742 ( .A(n720), .B(n1327), .Y(n655) );
  sky130_fd_sc_hd__nand2_4 U743 ( .A(n720), .B(n1339), .Y(n667) );
  sky130_fd_sc_hd__nand2_4 U744 ( .A(n720), .B(n1351), .Y(n679) );
  sky130_fd_sc_hd__nand2_4 U745 ( .A(n720), .B(n1374), .Y(n703) );
  sky130_fd_sc_hd__nand2_4 U746 ( .A(n720), .B(n1386), .Y(n716) );
  sky130_fd_sc_hd__nand2_4 U747 ( .A(n720), .B(n1399), .Y(n731) );
  sky130_fd_sc_hd__nand2_4 U748 ( .A(n818), .B(n1327), .Y(n755) );
  sky130_fd_sc_hd__nand2_4 U749 ( .A(n818), .B(n1339), .Y(n766) );
  sky130_fd_sc_hd__nand2_4 U750 ( .A(n818), .B(n1351), .Y(n777) );
  sky130_fd_sc_hd__nand2_4 U751 ( .A(n818), .B(n1374), .Y(n802) );
  sky130_fd_sc_hd__nand2_4 U752 ( .A(n818), .B(n1386), .Y(n815) );
  sky130_fd_sc_hd__nand2_4 U753 ( .A(n818), .B(n1399), .Y(n828) );
  sky130_fd_sc_hd__nand2_4 U754 ( .A(n910), .B(n1315), .Y(n841) );
  sky130_fd_sc_hd__nand2_4 U755 ( .A(n910), .B(n1327), .Y(n853) );
  sky130_fd_sc_hd__nand2_4 U756 ( .A(n910), .B(n1339), .Y(n864) );
  sky130_fd_sc_hd__nand2_4 U757 ( .A(n910), .B(n1351), .Y(n875) );
  sky130_fd_sc_hd__nand2_4 U758 ( .A(n910), .B(n20), .Y(n886) );
  sky130_fd_sc_hd__nand2_4 U759 ( .A(n910), .B(n1374), .Y(n897) );
  sky130_fd_sc_hd__nand2_4 U760 ( .A(n910), .B(n1386), .Y(n908) );
  sky130_fd_sc_hd__nand2_4 U761 ( .A(n910), .B(n1399), .Y(n920) );
  sky130_fd_sc_hd__nand2_4 U762 ( .A(n1006), .B(n1327), .Y(n943) );
  sky130_fd_sc_hd__nand2_4 U763 ( .A(n1006), .B(n1339), .Y(n954) );
  sky130_fd_sc_hd__nand2_4 U764 ( .A(n1006), .B(n1351), .Y(n965) );
  sky130_fd_sc_hd__nand2_4 U765 ( .A(n1006), .B(n1374), .Y(n990) );
  sky130_fd_sc_hd__nand2_4 U766 ( .A(n1006), .B(n1386), .Y(n1003) );
  sky130_fd_sc_hd__nand2_4 U767 ( .A(n1006), .B(n1399), .Y(n1017) );
  sky130_fd_sc_hd__nand2_4 U768 ( .A(n1106), .B(n1327), .Y(n1043) );
  sky130_fd_sc_hd__nand2_4 U769 ( .A(n1106), .B(n1339), .Y(n1054) );
  sky130_fd_sc_hd__nand2_4 U770 ( .A(n1106), .B(n1351), .Y(n1065) );
  sky130_fd_sc_hd__nand2_4 U771 ( .A(n1106), .B(n1374), .Y(n1090) );
  sky130_fd_sc_hd__nand2_4 U772 ( .A(n1106), .B(n1386), .Y(n1103) );
  sky130_fd_sc_hd__nand2_4 U773 ( .A(n1106), .B(n1399), .Y(n1116) );
  sky130_fd_sc_hd__nand2_4 U774 ( .A(n1200), .B(n1315), .Y(n1129) );
  sky130_fd_sc_hd__nand2_4 U775 ( .A(n1200), .B(n1327), .Y(n1141) );
  sky130_fd_sc_hd__nand2_4 U776 ( .A(n1200), .B(n1339), .Y(n1152) );
  sky130_fd_sc_hd__nand2_4 U777 ( .A(n1200), .B(n1351), .Y(n1163) );
  sky130_fd_sc_hd__nand2_4 U778 ( .A(n1200), .B(n20), .Y(n1175) );
  sky130_fd_sc_hd__nand2_4 U779 ( .A(n1200), .B(n1374), .Y(n1187) );
  sky130_fd_sc_hd__nand2_4 U780 ( .A(n1200), .B(n1386), .Y(n1198) );
  sky130_fd_sc_hd__nand2_4 U781 ( .A(n1200), .B(n1399), .Y(n1211) );
  sky130_fd_sc_hd__nand2_4 U782 ( .A(n1300), .B(n1315), .Y(n1225) );
  sky130_fd_sc_hd__nand2_4 U783 ( .A(n1300), .B(n1327), .Y(n1237) );
  sky130_fd_sc_hd__nand2_4 U784 ( .A(n1300), .B(n1339), .Y(n1248) );
  sky130_fd_sc_hd__nand2_4 U785 ( .A(n1300), .B(n1351), .Y(n1259) );
  sky130_fd_sc_hd__nand2_4 U786 ( .A(n1300), .B(n20), .Y(n1271) );
  sky130_fd_sc_hd__nand2_4 U787 ( .A(n1300), .B(n1374), .Y(n1284) );
  sky130_fd_sc_hd__nand2_4 U788 ( .A(n1300), .B(n1386), .Y(n1297) );
  sky130_fd_sc_hd__nand2_4 U789 ( .A(n1300), .B(n1399), .Y(n1311) );
  sky130_fd_sc_hd__nand2_4 U790 ( .A(n1315), .B(n1398), .Y(n1325) );
  sky130_fd_sc_hd__nand2_4 U791 ( .A(n1327), .B(n1398), .Y(n1337) );
  sky130_fd_sc_hd__nand2_4 U792 ( .A(n1339), .B(n1398), .Y(n1349) );
  sky130_fd_sc_hd__nand2_4 U793 ( .A(n1351), .B(n1398), .Y(n1361) );
  sky130_fd_sc_hd__nand2_4 U794 ( .A(n20), .B(n1398), .Y(n1372) );
  sky130_fd_sc_hd__nand2_4 U795 ( .A(n1374), .B(n1398), .Y(n1384) );
  sky130_fd_sc_hd__nand2_4 U796 ( .A(n1386), .B(n1398), .Y(n1396) );
  sky130_fd_sc_hd__nand2_4 U797 ( .A(n1399), .B(n1398), .Y(n1419) );
  sky130_fd_sc_hd__inv_1 U798 ( .A(cnt_o[1]), .Y(n587) );
  sky130_fd_sc_hd__inv_1 U799 ( .A(n1439), .Y(n626) );
  sky130_fd_sc_hd__nand3_1 U800 ( .A(n603), .B(n587), .C(n608), .Y(n588) );
  sky130_fd_sc_hd__nand2_1 U801 ( .A(n611), .B(n589), .Y(n1434) );
  sky130_fd_sc_hd__inv_1 U802 ( .A(flush_i), .Y(n1421) );
  sky130_fd_sc_hd__nand2_1 U803 ( .A(n569), .B(n601), .Y(n590) );
  sky130_fd_sc_hd__nand2_1 U804 ( .A(n600), .B(n1421), .Y(n592) );
  sky130_fd_sc_hd__nand4_1 U805 ( .A(n598), .B(n597), .C(n596), .D(n595), .Y(
        n599) );
  sky130_fd_sc_hd__mux2i_1 U806 ( .A0(n627), .A1(n621), .S(cnt_o[0]), .Y(n602)
         );
  sky130_fd_sc_hd__a21o_1 U807 ( .A1(N108), .A2(n629), .B1(n602), .X(
        s_cnt_d[0]) );
  sky130_fd_sc_hd__nand2_1 U808 ( .A(n620), .B(n570), .Y(n605) );
  sky130_fd_sc_hd__mux2i_1 U809 ( .A0(n605), .A1(n609), .S(n103), .Y(n606) );
  sky130_fd_sc_hd__a21o_1 U810 ( .A1(N109), .A2(n629), .B1(n606), .X(
        s_cnt_d[1]) );
  sky130_fd_sc_hd__a21oi_1 U811 ( .A1(n106), .A2(n103), .B1(n568), .Y(n610) );
  sky130_fd_sc_hd__nand2_1 U812 ( .A(N110), .B(n629), .Y(n607) );
  sky130_fd_sc_hd__o221ai_1 U813 ( .A1(n610), .A2(n627), .B1(n608), .B2(n609), 
        .C1(n607), .Y(s_cnt_d[2]) );
  sky130_fd_sc_hd__nand2_1 U814 ( .A(n620), .B(n568), .Y(n613) );
  sky130_fd_sc_hd__mux2i_1 U815 ( .A0(n613), .A1(n618), .S(cnt_o[3]), .Y(n614)
         );
  sky130_fd_sc_hd__a21o_1 U816 ( .A1(N111), .A2(n629), .B1(n614), .X(
        s_cnt_d[3]) );
  sky130_fd_sc_hd__nor4_1 U817 ( .A(n1442), .B(n1443), .C(n1441), .D(cnt_o[1]), 
        .Y(n615) );
  sky130_fd_sc_hd__nand2_1 U818 ( .A(n615), .B(n617), .Y(n1436) );
  sky130_fd_sc_hd__a21oi_1 U819 ( .A1(cnt_o[4]), .A2(cnt_o[3]), .B1(n622), .Y(
        n619) );
  sky130_fd_sc_hd__nand2_1 U820 ( .A(N112), .B(n629), .Y(n616) );
  sky130_fd_sc_hd__o221ai_1 U821 ( .A1(n619), .A2(n627), .B1(n618), .B2(n617), 
        .C1(n616), .Y(s_cnt_d[4]) );
  sky130_fd_sc_hd__nand2_1 U822 ( .A(n620), .B(n622), .Y(n624) );
  sky130_fd_sc_hd__o21ai_1 U823 ( .A1(n622), .A2(n627), .B1(n621), .Y(n630) );
  sky130_fd_sc_hd__mux2i_1 U824 ( .A0(n624), .A1(n623), .S(cnt_o[5]), .Y(n625)
         );
  sky130_fd_sc_hd__a21o_1 U825 ( .A1(N113), .A2(n629), .B1(n625), .X(
        s_cnt_d[5]) );
  sky130_fd_sc_hd__inv_1 U826 ( .A(n1438), .Y(n1435) );
  sky130_fd_sc_hd__nor3_1 U827 ( .A(n627), .B(n1435), .C(n626), .Y(n628) );
  sky130_fd_sc_hd__a221o_1 U828 ( .A1(n630), .A2(cnt_o[6]), .B1(N114), .B2(
        n629), .C1(n628), .X(s_cnt_d[6]) );
  sky130_fd_sc_hd__nand2_1 U829 ( .A(n46), .B(s_wr_ptr_q[5]), .Y(n631) );
  sky130_fd_sc_hd__nand2_1 U830 ( .A(n45), .B(s_wr_ptr_q[2]), .Y(n632) );
  sky130_fd_sc_hd__nand2_1 U831 ( .A(n633), .B(n576), .Y(n634) );
  sky130_fd_sc_hd__nand2_1 U832 ( .A(dat_i[8]), .B(n569), .Y(n1402) );
  sky130_fd_sc_hd__nand2_1 U833 ( .A(dat_i[7]), .B(n569), .Y(n1404) );
  sky130_fd_sc_hd__inv_1 U834 ( .A(s_mem_q[574]), .Y(n635) );
  sky130_fd_sc_hd__o22ai_1 U835 ( .A1(n56), .A2(n644), .B1(n643), .B2(n635), 
        .Y(s_mem_d[574]) );
  sky130_fd_sc_hd__nand2_1 U836 ( .A(dat_i[6]), .B(n569), .Y(n1406) );
  sky130_fd_sc_hd__inv_1 U837 ( .A(s_mem_q[573]), .Y(n636) );
  sky130_fd_sc_hd__o22ai_1 U838 ( .A1(n64), .A2(n644), .B1(n643), .B2(n636), 
        .Y(s_mem_d[573]) );
  sky130_fd_sc_hd__nand2_1 U839 ( .A(dat_i[5]), .B(n569), .Y(n1408) );
  sky130_fd_sc_hd__inv_1 U840 ( .A(s_mem_q[572]), .Y(n637) );
  sky130_fd_sc_hd__o22ai_1 U841 ( .A1(n72), .A2(n644), .B1(n643), .B2(n637), 
        .Y(s_mem_d[572]) );
  sky130_fd_sc_hd__nand2_1 U842 ( .A(dat_i[4]), .B(n569), .Y(n1410) );
  sky130_fd_sc_hd__inv_1 U843 ( .A(s_mem_q[571]), .Y(n638) );
  sky130_fd_sc_hd__o22ai_1 U844 ( .A1(n80), .A2(n644), .B1(n643), .B2(n638), 
        .Y(s_mem_d[571]) );
  sky130_fd_sc_hd__nand2_1 U845 ( .A(dat_i[3]), .B(n569), .Y(n1412) );
  sky130_fd_sc_hd__inv_1 U846 ( .A(s_mem_q[570]), .Y(n639) );
  sky130_fd_sc_hd__o22ai_1 U847 ( .A1(n88), .A2(n644), .B1(n643), .B2(n639), 
        .Y(s_mem_d[570]) );
  sky130_fd_sc_hd__nand2_1 U848 ( .A(dat_i[2]), .B(n569), .Y(n1414) );
  sky130_fd_sc_hd__inv_1 U849 ( .A(s_mem_q[569]), .Y(n640) );
  sky130_fd_sc_hd__o22ai_1 U850 ( .A1(n96), .A2(n644), .B1(n643), .B2(n640), 
        .Y(s_mem_d[569]) );
  sky130_fd_sc_hd__nand2_1 U851 ( .A(dat_i[1]), .B(n569), .Y(n1416) );
  sky130_fd_sc_hd__inv_1 U852 ( .A(s_mem_q[568]), .Y(n641) );
  sky130_fd_sc_hd__o22ai_1 U853 ( .A1(n584), .A2(n644), .B1(n643), .B2(n641), 
        .Y(s_mem_d[568]) );
  sky130_fd_sc_hd__inv_1 U854 ( .A(s_mem_q[567]), .Y(n642) );
  sky130_fd_sc_hd__o22ai_1 U855 ( .A1(n51), .A2(n644), .B1(n643), .B2(n642), 
        .Y(s_mem_d[567]) );
  sky130_fd_sc_hd__inv_1 U856 ( .A(s_wr_ptr_q[0]), .Y(n718) );
  sky130_fd_sc_hd__nand3_1 U857 ( .A(s_wr_ptr_q[2]), .B(s_wr_ptr_q[1]), .C(
        n718), .Y(n645) );
  sky130_fd_sc_hd__inv_1 U858 ( .A(s_mem_q[566]), .Y(n647) );
  sky130_fd_sc_hd__o22ai_1 U859 ( .A1(n7), .A2(n647), .B1(n577), .B2(n655), 
        .Y(s_mem_d[566]) );
  sky130_fd_sc_hd__inv_1 U860 ( .A(s_mem_q[565]), .Y(n648) );
  sky130_fd_sc_hd__o22ai_1 U861 ( .A1(n7), .A2(n648), .B1(n58), .B2(n655), .Y(
        s_mem_d[565]) );
  sky130_fd_sc_hd__inv_1 U862 ( .A(s_mem_q[564]), .Y(n649) );
  sky130_fd_sc_hd__o22ai_1 U863 ( .A1(n7), .A2(n649), .B1(n66), .B2(n655), .Y(
        s_mem_d[564]) );
  sky130_fd_sc_hd__inv_1 U864 ( .A(s_mem_q[563]), .Y(n650) );
  sky130_fd_sc_hd__o22ai_1 U865 ( .A1(n7), .A2(n650), .B1(n74), .B2(n655), .Y(
        s_mem_d[563]) );
  sky130_fd_sc_hd__inv_1 U866 ( .A(s_mem_q[562]), .Y(n651) );
  sky130_fd_sc_hd__o22ai_1 U867 ( .A1(n7), .A2(n651), .B1(n82), .B2(n655), .Y(
        s_mem_d[562]) );
  sky130_fd_sc_hd__inv_1 U868 ( .A(s_mem_q[561]), .Y(n652) );
  sky130_fd_sc_hd__o22ai_1 U869 ( .A1(n7), .A2(n652), .B1(n90), .B2(n655), .Y(
        s_mem_d[561]) );
  sky130_fd_sc_hd__inv_1 U870 ( .A(s_mem_q[560]), .Y(n653) );
  sky130_fd_sc_hd__o22ai_1 U871 ( .A1(n7), .A2(n653), .B1(n98), .B2(n655), .Y(
        s_mem_d[560]) );
  sky130_fd_sc_hd__inv_1 U872 ( .A(s_mem_q[559]), .Y(n654) );
  sky130_fd_sc_hd__o22ai_1 U873 ( .A1(n7), .A2(n654), .B1(n581), .B2(n655), 
        .Y(s_mem_d[559]) );
  sky130_fd_sc_hd__inv_1 U874 ( .A(s_mem_q[558]), .Y(n656) );
  sky130_fd_sc_hd__o22ai_1 U875 ( .A1(n7), .A2(n656), .B1(n50), .B2(n655), .Y(
        s_mem_d[558]) );
  sky130_fd_sc_hd__inv_1 U876 ( .A(s_wr_ptr_q[1]), .Y(n1428) );
  sky130_fd_sc_hd__nand3_1 U877 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[2]), .C(
        n1428), .Y(n657) );
  sky130_fd_sc_hd__clkinv_2 U878 ( .A(n657), .Y(n1339) );
  sky130_fd_sc_hd__inv_1 U879 ( .A(s_mem_q[557]), .Y(n659) );
  sky130_fd_sc_hd__o22ai_1 U880 ( .A1(n4), .A2(n659), .B1(n577), .B2(n667), 
        .Y(s_mem_d[557]) );
  sky130_fd_sc_hd__inv_1 U881 ( .A(s_mem_q[556]), .Y(n660) );
  sky130_fd_sc_hd__o22ai_1 U882 ( .A1(n4), .A2(n660), .B1(n56), .B2(n667), .Y(
        s_mem_d[556]) );
  sky130_fd_sc_hd__inv_1 U883 ( .A(s_mem_q[555]), .Y(n661) );
  sky130_fd_sc_hd__o22ai_1 U884 ( .A1(n4), .A2(n661), .B1(n64), .B2(n667), .Y(
        s_mem_d[555]) );
  sky130_fd_sc_hd__inv_1 U885 ( .A(s_mem_q[554]), .Y(n662) );
  sky130_fd_sc_hd__o22ai_1 U886 ( .A1(n4), .A2(n662), .B1(n72), .B2(n667), .Y(
        s_mem_d[554]) );
  sky130_fd_sc_hd__inv_1 U887 ( .A(s_mem_q[553]), .Y(n663) );
  sky130_fd_sc_hd__o22ai_1 U888 ( .A1(n4), .A2(n663), .B1(n80), .B2(n667), .Y(
        s_mem_d[553]) );
  sky130_fd_sc_hd__inv_1 U889 ( .A(s_mem_q[552]), .Y(n664) );
  sky130_fd_sc_hd__o22ai_1 U890 ( .A1(n4), .A2(n664), .B1(n88), .B2(n667), .Y(
        s_mem_d[552]) );
  sky130_fd_sc_hd__inv_1 U891 ( .A(s_mem_q[551]), .Y(n665) );
  sky130_fd_sc_hd__o22ai_1 U892 ( .A1(n4), .A2(n665), .B1(n96), .B2(n667), .Y(
        s_mem_d[551]) );
  sky130_fd_sc_hd__inv_1 U893 ( .A(s_mem_q[550]), .Y(n666) );
  sky130_fd_sc_hd__o22ai_1 U894 ( .A1(n4), .A2(n666), .B1(n581), .B2(n667), 
        .Y(s_mem_d[550]) );
  sky130_fd_sc_hd__inv_1 U895 ( .A(s_mem_q[549]), .Y(n668) );
  sky130_fd_sc_hd__o22ai_1 U896 ( .A1(n4), .A2(n668), .B1(n51), .B2(n667), .Y(
        s_mem_d[549]) );
  sky130_fd_sc_hd__nand3_1 U897 ( .A(s_wr_ptr_q[2]), .B(n1428), .C(n718), .Y(
        n669) );
  sky130_fd_sc_hd__inv_1 U898 ( .A(s_mem_q[548]), .Y(n671) );
  sky130_fd_sc_hd__o22ai_1 U899 ( .A1(n27), .A2(n671), .B1(n577), .B2(n679), 
        .Y(s_mem_d[548]) );
  sky130_fd_sc_hd__inv_1 U900 ( .A(s_mem_q[547]), .Y(n672) );
  sky130_fd_sc_hd__o22ai_1 U901 ( .A1(n27), .A2(n672), .B1(n58), .B2(n679), 
        .Y(s_mem_d[547]) );
  sky130_fd_sc_hd__inv_1 U902 ( .A(s_mem_q[546]), .Y(n673) );
  sky130_fd_sc_hd__o22ai_1 U903 ( .A1(n27), .A2(n673), .B1(n66), .B2(n679), 
        .Y(s_mem_d[546]) );
  sky130_fd_sc_hd__inv_1 U904 ( .A(s_mem_q[545]), .Y(n674) );
  sky130_fd_sc_hd__o22ai_1 U905 ( .A1(n27), .A2(n674), .B1(n74), .B2(n679), 
        .Y(s_mem_d[545]) );
  sky130_fd_sc_hd__inv_1 U906 ( .A(s_mem_q[544]), .Y(n675) );
  sky130_fd_sc_hd__o22ai_1 U907 ( .A1(n27), .A2(n675), .B1(n82), .B2(n679), 
        .Y(s_mem_d[544]) );
  sky130_fd_sc_hd__inv_1 U908 ( .A(s_mem_q[543]), .Y(n676) );
  sky130_fd_sc_hd__o22ai_1 U909 ( .A1(n27), .A2(n676), .B1(n90), .B2(n679), 
        .Y(s_mem_d[543]) );
  sky130_fd_sc_hd__inv_1 U910 ( .A(s_mem_q[542]), .Y(n677) );
  sky130_fd_sc_hd__o22ai_1 U911 ( .A1(n27), .A2(n677), .B1(n98), .B2(n679), 
        .Y(s_mem_d[542]) );
  sky130_fd_sc_hd__inv_1 U912 ( .A(s_mem_q[541]), .Y(n678) );
  sky130_fd_sc_hd__o22ai_1 U913 ( .A1(n27), .A2(n678), .B1(n581), .B2(n679), 
        .Y(s_mem_d[541]) );
  sky130_fd_sc_hd__inv_1 U914 ( .A(s_mem_q[540]), .Y(n680) );
  sky130_fd_sc_hd__o22ai_1 U915 ( .A1(n27), .A2(n680), .B1(n50), .B2(n679), 
        .Y(s_mem_d[540]) );
  sky130_fd_sc_hd__inv_1 U916 ( .A(s_wr_ptr_q[2]), .Y(n1426) );
  sky130_fd_sc_hd__inv_1 U917 ( .A(s_mem_q[539]), .Y(n682) );
  sky130_fd_sc_hd__o22ai_1 U918 ( .A1(n43), .A2(n682), .B1(n577), .B2(n690), 
        .Y(s_mem_d[539]) );
  sky130_fd_sc_hd__inv_1 U919 ( .A(s_mem_q[538]), .Y(n683) );
  sky130_fd_sc_hd__o22ai_1 U920 ( .A1(n43), .A2(n683), .B1(n57), .B2(n690), 
        .Y(s_mem_d[538]) );
  sky130_fd_sc_hd__inv_1 U921 ( .A(s_mem_q[537]), .Y(n684) );
  sky130_fd_sc_hd__o22ai_1 U922 ( .A1(n43), .A2(n684), .B1(n65), .B2(n690), 
        .Y(s_mem_d[537]) );
  sky130_fd_sc_hd__inv_1 U923 ( .A(s_mem_q[536]), .Y(n685) );
  sky130_fd_sc_hd__o22ai_1 U924 ( .A1(n43), .A2(n685), .B1(n73), .B2(n690), 
        .Y(s_mem_d[536]) );
  sky130_fd_sc_hd__inv_1 U925 ( .A(s_mem_q[535]), .Y(n686) );
  sky130_fd_sc_hd__o22ai_1 U926 ( .A1(n43), .A2(n686), .B1(n81), .B2(n690), 
        .Y(s_mem_d[535]) );
  sky130_fd_sc_hd__inv_1 U927 ( .A(s_mem_q[534]), .Y(n687) );
  sky130_fd_sc_hd__o22ai_1 U928 ( .A1(n43), .A2(n687), .B1(n89), .B2(n690), 
        .Y(s_mem_d[534]) );
  sky130_fd_sc_hd__inv_1 U929 ( .A(s_mem_q[533]), .Y(n688) );
  sky130_fd_sc_hd__o22ai_1 U930 ( .A1(n43), .A2(n688), .B1(n97), .B2(n690), 
        .Y(s_mem_d[533]) );
  sky130_fd_sc_hd__inv_1 U931 ( .A(s_mem_q[532]), .Y(n689) );
  sky130_fd_sc_hd__o22ai_1 U932 ( .A1(n43), .A2(n689), .B1(n581), .B2(n690), 
        .Y(s_mem_d[532]) );
  sky130_fd_sc_hd__inv_1 U933 ( .A(s_mem_q[531]), .Y(n691) );
  sky130_fd_sc_hd__o22ai_1 U934 ( .A1(n43), .A2(n691), .B1(n49), .B2(n690), 
        .Y(s_mem_d[531]) );
  sky130_fd_sc_hd__nand3_1 U935 ( .A(s_wr_ptr_q[1]), .B(n1426), .C(n718), .Y(
        n692) );
  sky130_fd_sc_hd__nand2_1 U936 ( .A(n693), .B(n575), .Y(n694) );
  sky130_fd_sc_hd__inv_1 U937 ( .A(s_mem_q[530]), .Y(n695) );
  sky130_fd_sc_hd__o22ai_1 U938 ( .A1(n705), .A2(n695), .B1(n577), .B2(n703), 
        .Y(s_mem_d[530]) );
  sky130_fd_sc_hd__inv_1 U939 ( .A(s_mem_q[529]), .Y(n696) );
  sky130_fd_sc_hd__o22ai_1 U940 ( .A1(n705), .A2(n696), .B1(n57), .B2(n703), 
        .Y(s_mem_d[529]) );
  sky130_fd_sc_hd__inv_1 U941 ( .A(s_mem_q[528]), .Y(n697) );
  sky130_fd_sc_hd__o22ai_1 U942 ( .A1(n705), .A2(n697), .B1(n65), .B2(n703), 
        .Y(s_mem_d[528]) );
  sky130_fd_sc_hd__inv_1 U943 ( .A(s_mem_q[527]), .Y(n698) );
  sky130_fd_sc_hd__o22ai_1 U944 ( .A1(n705), .A2(n698), .B1(n73), .B2(n703), 
        .Y(s_mem_d[527]) );
  sky130_fd_sc_hd__inv_1 U945 ( .A(s_mem_q[526]), .Y(n699) );
  sky130_fd_sc_hd__o22ai_1 U946 ( .A1(n705), .A2(n699), .B1(n81), .B2(n703), 
        .Y(s_mem_d[526]) );
  sky130_fd_sc_hd__inv_1 U947 ( .A(s_mem_q[525]), .Y(n700) );
  sky130_fd_sc_hd__o22ai_1 U948 ( .A1(n705), .A2(n700), .B1(n89), .B2(n703), 
        .Y(s_mem_d[525]) );
  sky130_fd_sc_hd__inv_1 U949 ( .A(s_mem_q[524]), .Y(n701) );
  sky130_fd_sc_hd__o22ai_1 U950 ( .A1(n705), .A2(n701), .B1(n97), .B2(n703), 
        .Y(s_mem_d[524]) );
  sky130_fd_sc_hd__inv_1 U951 ( .A(s_mem_q[523]), .Y(n702) );
  sky130_fd_sc_hd__o22ai_1 U952 ( .A1(n705), .A2(n702), .B1(n581), .B2(n703), 
        .Y(s_mem_d[523]) );
  sky130_fd_sc_hd__inv_1 U953 ( .A(s_mem_q[522]), .Y(n704) );
  sky130_fd_sc_hd__o22ai_1 U954 ( .A1(n705), .A2(n704), .B1(n49), .B2(n703), 
        .Y(s_mem_d[522]) );
  sky130_fd_sc_hd__nand3_1 U955 ( .A(s_wr_ptr_q[0]), .B(n1426), .C(n1428), .Y(
        n706) );
  sky130_fd_sc_hd__inv_1 U956 ( .A(s_mem_q[521]), .Y(n708) );
  sky130_fd_sc_hd__o22ai_1 U957 ( .A1(n40), .A2(n708), .B1(n577), .B2(n716), 
        .Y(s_mem_d[521]) );
  sky130_fd_sc_hd__inv_1 U958 ( .A(s_mem_q[520]), .Y(n709) );
  sky130_fd_sc_hd__o22ai_1 U959 ( .A1(n40), .A2(n709), .B1(n56), .B2(n716), 
        .Y(s_mem_d[520]) );
  sky130_fd_sc_hd__inv_1 U960 ( .A(s_mem_q[519]), .Y(n710) );
  sky130_fd_sc_hd__o22ai_1 U961 ( .A1(n40), .A2(n710), .B1(n64), .B2(n716), 
        .Y(s_mem_d[519]) );
  sky130_fd_sc_hd__inv_1 U962 ( .A(s_mem_q[518]), .Y(n711) );
  sky130_fd_sc_hd__o22ai_1 U963 ( .A1(n40), .A2(n711), .B1(n72), .B2(n716), 
        .Y(s_mem_d[518]) );
  sky130_fd_sc_hd__inv_1 U964 ( .A(s_mem_q[517]), .Y(n712) );
  sky130_fd_sc_hd__o22ai_1 U965 ( .A1(n40), .A2(n712), .B1(n80), .B2(n716), 
        .Y(s_mem_d[517]) );
  sky130_fd_sc_hd__inv_1 U966 ( .A(s_mem_q[516]), .Y(n713) );
  sky130_fd_sc_hd__o22ai_1 U967 ( .A1(n40), .A2(n713), .B1(n88), .B2(n716), 
        .Y(s_mem_d[516]) );
  sky130_fd_sc_hd__inv_1 U968 ( .A(s_mem_q[515]), .Y(n714) );
  sky130_fd_sc_hd__o22ai_1 U969 ( .A1(n40), .A2(n714), .B1(n96), .B2(n716), 
        .Y(s_mem_d[515]) );
  sky130_fd_sc_hd__inv_1 U970 ( .A(s_mem_q[514]), .Y(n715) );
  sky130_fd_sc_hd__o22ai_1 U971 ( .A1(n40), .A2(n715), .B1(n581), .B2(n716), 
        .Y(s_mem_d[514]) );
  sky130_fd_sc_hd__inv_1 U972 ( .A(s_mem_q[513]), .Y(n717) );
  sky130_fd_sc_hd__o22ai_1 U973 ( .A1(n40), .A2(n717), .B1(n51), .B2(n716), 
        .Y(s_mem_d[513]) );
  sky130_fd_sc_hd__nand3_1 U974 ( .A(n1428), .B(n1426), .C(n718), .Y(n719) );
  sky130_fd_sc_hd__nand2_1 U975 ( .A(n721), .B(n575), .Y(n722) );
  sky130_fd_sc_hd__inv_1 U976 ( .A(s_mem_q[512]), .Y(n723) );
  sky130_fd_sc_hd__o22ai_1 U977 ( .A1(n733), .A2(n723), .B1(n577), .B2(n731), 
        .Y(s_mem_d[512]) );
  sky130_fd_sc_hd__inv_1 U978 ( .A(s_mem_q[511]), .Y(n724) );
  sky130_fd_sc_hd__o22ai_1 U979 ( .A1(n733), .A2(n724), .B1(n62), .B2(n731), 
        .Y(s_mem_d[511]) );
  sky130_fd_sc_hd__inv_1 U980 ( .A(s_mem_q[510]), .Y(n725) );
  sky130_fd_sc_hd__o22ai_1 U981 ( .A1(n733), .A2(n725), .B1(n70), .B2(n731), 
        .Y(s_mem_d[510]) );
  sky130_fd_sc_hd__inv_1 U982 ( .A(s_mem_q[509]), .Y(n726) );
  sky130_fd_sc_hd__o22ai_1 U983 ( .A1(n733), .A2(n726), .B1(n78), .B2(n731), 
        .Y(s_mem_d[509]) );
  sky130_fd_sc_hd__inv_1 U984 ( .A(s_mem_q[508]), .Y(n727) );
  sky130_fd_sc_hd__o22ai_1 U985 ( .A1(n733), .A2(n727), .B1(n86), .B2(n731), 
        .Y(s_mem_d[508]) );
  sky130_fd_sc_hd__inv_1 U986 ( .A(s_mem_q[507]), .Y(n728) );
  sky130_fd_sc_hd__o22ai_1 U987 ( .A1(n733), .A2(n728), .B1(n94), .B2(n731), 
        .Y(s_mem_d[507]) );
  sky130_fd_sc_hd__inv_1 U988 ( .A(s_mem_q[506]), .Y(n729) );
  sky130_fd_sc_hd__o22ai_1 U989 ( .A1(n733), .A2(n729), .B1(n102), .B2(n731), 
        .Y(s_mem_d[506]) );
  sky130_fd_sc_hd__inv_1 U990 ( .A(s_mem_q[505]), .Y(n730) );
  sky130_fd_sc_hd__o22ai_1 U991 ( .A1(n733), .A2(n730), .B1(n581), .B2(n731), 
        .Y(s_mem_d[505]) );
  sky130_fd_sc_hd__inv_1 U992 ( .A(s_mem_q[504]), .Y(n732) );
  sky130_fd_sc_hd__o22ai_1 U993 ( .A1(n733), .A2(n732), .B1(n53), .B2(n731), 
        .Y(s_mem_d[504]) );
  sky130_fd_sc_hd__inv_1 U994 ( .A(s_wr_ptr_q[3]), .Y(n1425) );
  sky130_fd_sc_hd__nand3_1 U995 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[4]), .C(
        n1425), .Y(n734) );
  sky130_fd_sc_hd__inv_1 U996 ( .A(s_mem_q[503]), .Y(n736) );
  sky130_fd_sc_hd__o22ai_1 U997 ( .A1(n44), .A2(n736), .B1(n577), .B2(n744), 
        .Y(s_mem_d[503]) );
  sky130_fd_sc_hd__inv_1 U998 ( .A(s_mem_q[502]), .Y(n737) );
  sky130_fd_sc_hd__o22ai_1 U999 ( .A1(n44), .A2(n737), .B1(n57), .B2(n744), 
        .Y(s_mem_d[502]) );
  sky130_fd_sc_hd__inv_1 U1000 ( .A(s_mem_q[501]), .Y(n738) );
  sky130_fd_sc_hd__o22ai_1 U1001 ( .A1(n44), .A2(n738), .B1(n65), .B2(n744), 
        .Y(s_mem_d[501]) );
  sky130_fd_sc_hd__inv_1 U1002 ( .A(s_mem_q[500]), .Y(n739) );
  sky130_fd_sc_hd__o22ai_1 U1003 ( .A1(n44), .A2(n739), .B1(n73), .B2(n744), 
        .Y(s_mem_d[500]) );
  sky130_fd_sc_hd__inv_1 U1004 ( .A(s_mem_q[499]), .Y(n740) );
  sky130_fd_sc_hd__o22ai_1 U1005 ( .A1(n44), .A2(n740), .B1(n81), .B2(n744), 
        .Y(s_mem_d[499]) );
  sky130_fd_sc_hd__inv_1 U1006 ( .A(s_mem_q[498]), .Y(n741) );
  sky130_fd_sc_hd__o22ai_1 U1007 ( .A1(n44), .A2(n741), .B1(n89), .B2(n744), 
        .Y(s_mem_d[498]) );
  sky130_fd_sc_hd__inv_1 U1008 ( .A(s_mem_q[497]), .Y(n742) );
  sky130_fd_sc_hd__o22ai_1 U1009 ( .A1(n44), .A2(n742), .B1(n97), .B2(n744), 
        .Y(s_mem_d[497]) );
  sky130_fd_sc_hd__inv_1 U1010 ( .A(s_mem_q[496]), .Y(n743) );
  sky130_fd_sc_hd__o22ai_1 U1011 ( .A1(n44), .A2(n743), .B1(n581), .B2(n744), 
        .Y(s_mem_d[496]) );
  sky130_fd_sc_hd__inv_1 U1012 ( .A(s_mem_q[495]), .Y(n745) );
  sky130_fd_sc_hd__o22ai_1 U1013 ( .A1(n44), .A2(n745), .B1(n49), .B2(n744), 
        .Y(s_mem_d[495]) );
  sky130_fd_sc_hd__inv_1 U1014 ( .A(s_mem_q[494]), .Y(n747) );
  sky130_fd_sc_hd__o22ai_1 U1015 ( .A1(n23), .A2(n747), .B1(n577), .B2(n755), 
        .Y(s_mem_d[494]) );
  sky130_fd_sc_hd__inv_1 U1016 ( .A(s_mem_q[493]), .Y(n748) );
  sky130_fd_sc_hd__o22ai_1 U1017 ( .A1(n23), .A2(n748), .B1(n61), .B2(n755), 
        .Y(s_mem_d[493]) );
  sky130_fd_sc_hd__inv_1 U1018 ( .A(s_mem_q[492]), .Y(n749) );
  sky130_fd_sc_hd__o22ai_1 U1019 ( .A1(n23), .A2(n749), .B1(n69), .B2(n755), 
        .Y(s_mem_d[492]) );
  sky130_fd_sc_hd__inv_1 U1020 ( .A(s_mem_q[491]), .Y(n750) );
  sky130_fd_sc_hd__o22ai_1 U1021 ( .A1(n23), .A2(n750), .B1(n77), .B2(n755), 
        .Y(s_mem_d[491]) );
  sky130_fd_sc_hd__inv_1 U1022 ( .A(s_mem_q[490]), .Y(n751) );
  sky130_fd_sc_hd__o22ai_1 U1023 ( .A1(n23), .A2(n751), .B1(n85), .B2(n755), 
        .Y(s_mem_d[490]) );
  sky130_fd_sc_hd__inv_1 U1024 ( .A(s_mem_q[489]), .Y(n752) );
  sky130_fd_sc_hd__o22ai_1 U1025 ( .A1(n23), .A2(n752), .B1(n93), .B2(n755), 
        .Y(s_mem_d[489]) );
  sky130_fd_sc_hd__inv_1 U1026 ( .A(s_mem_q[488]), .Y(n753) );
  sky130_fd_sc_hd__o22ai_1 U1027 ( .A1(n23), .A2(n753), .B1(n101), .B2(n755), 
        .Y(s_mem_d[488]) );
  sky130_fd_sc_hd__inv_1 U1028 ( .A(s_mem_q[487]), .Y(n754) );
  sky130_fd_sc_hd__o22ai_1 U1029 ( .A1(n23), .A2(n754), .B1(n581), .B2(n755), 
        .Y(s_mem_d[487]) );
  sky130_fd_sc_hd__inv_1 U1030 ( .A(s_mem_q[486]), .Y(n756) );
  sky130_fd_sc_hd__o22ai_1 U1031 ( .A1(n23), .A2(n756), .B1(n51), .B2(n755), 
        .Y(s_mem_d[486]) );
  sky130_fd_sc_hd__inv_1 U1032 ( .A(s_mem_q[485]), .Y(n758) );
  sky130_fd_sc_hd__o22ai_1 U1033 ( .A1(n33), .A2(n758), .B1(n577), .B2(n766), 
        .Y(s_mem_d[485]) );
  sky130_fd_sc_hd__inv_1 U1034 ( .A(s_mem_q[484]), .Y(n759) );
  sky130_fd_sc_hd__o22ai_1 U1035 ( .A1(n33), .A2(n759), .B1(n60), .B2(n766), 
        .Y(s_mem_d[484]) );
  sky130_fd_sc_hd__inv_1 U1036 ( .A(s_mem_q[483]), .Y(n760) );
  sky130_fd_sc_hd__o22ai_1 U1037 ( .A1(n33), .A2(n760), .B1(n68), .B2(n766), 
        .Y(s_mem_d[483]) );
  sky130_fd_sc_hd__inv_1 U1038 ( .A(s_mem_q[482]), .Y(n761) );
  sky130_fd_sc_hd__o22ai_1 U1039 ( .A1(n33), .A2(n761), .B1(n76), .B2(n766), 
        .Y(s_mem_d[482]) );
  sky130_fd_sc_hd__inv_1 U1040 ( .A(s_mem_q[481]), .Y(n762) );
  sky130_fd_sc_hd__o22ai_1 U1041 ( .A1(n33), .A2(n762), .B1(n84), .B2(n766), 
        .Y(s_mem_d[481]) );
  sky130_fd_sc_hd__inv_1 U1042 ( .A(s_mem_q[480]), .Y(n763) );
  sky130_fd_sc_hd__o22ai_1 U1043 ( .A1(n33), .A2(n763), .B1(n92), .B2(n766), 
        .Y(s_mem_d[480]) );
  sky130_fd_sc_hd__inv_1 U1044 ( .A(s_mem_q[479]), .Y(n764) );
  sky130_fd_sc_hd__o22ai_1 U1045 ( .A1(n33), .A2(n764), .B1(n100), .B2(n766), 
        .Y(s_mem_d[479]) );
  sky130_fd_sc_hd__inv_1 U1046 ( .A(s_mem_q[478]), .Y(n765) );
  sky130_fd_sc_hd__o22ai_1 U1047 ( .A1(n33), .A2(n765), .B1(n581), .B2(n766), 
        .Y(s_mem_d[478]) );
  sky130_fd_sc_hd__inv_1 U1048 ( .A(s_mem_q[477]), .Y(n767) );
  sky130_fd_sc_hd__o22ai_1 U1049 ( .A1(n33), .A2(n767), .B1(n53), .B2(n766), 
        .Y(s_mem_d[477]) );
  sky130_fd_sc_hd__inv_1 U1050 ( .A(s_mem_q[476]), .Y(n769) );
  sky130_fd_sc_hd__o22ai_1 U1051 ( .A1(n3), .A2(n769), .B1(n577), .B2(n777), 
        .Y(s_mem_d[476]) );
  sky130_fd_sc_hd__inv_1 U1052 ( .A(s_mem_q[475]), .Y(n770) );
  sky130_fd_sc_hd__o22ai_1 U1053 ( .A1(n3), .A2(n770), .B1(n57), .B2(n777), 
        .Y(s_mem_d[475]) );
  sky130_fd_sc_hd__inv_1 U1054 ( .A(s_mem_q[474]), .Y(n771) );
  sky130_fd_sc_hd__o22ai_1 U1055 ( .A1(n3), .A2(n771), .B1(n65), .B2(n777), 
        .Y(s_mem_d[474]) );
  sky130_fd_sc_hd__inv_1 U1056 ( .A(s_mem_q[473]), .Y(n772) );
  sky130_fd_sc_hd__o22ai_1 U1057 ( .A1(n3), .A2(n772), .B1(n73), .B2(n777), 
        .Y(s_mem_d[473]) );
  sky130_fd_sc_hd__inv_1 U1058 ( .A(s_mem_q[472]), .Y(n773) );
  sky130_fd_sc_hd__o22ai_1 U1059 ( .A1(n3), .A2(n773), .B1(n81), .B2(n777), 
        .Y(s_mem_d[472]) );
  sky130_fd_sc_hd__inv_1 U1060 ( .A(s_mem_q[471]), .Y(n774) );
  sky130_fd_sc_hd__o22ai_1 U1061 ( .A1(n3), .A2(n774), .B1(n89), .B2(n777), 
        .Y(s_mem_d[471]) );
  sky130_fd_sc_hd__inv_1 U1062 ( .A(s_mem_q[470]), .Y(n775) );
  sky130_fd_sc_hd__o22ai_1 U1063 ( .A1(n3), .A2(n775), .B1(n97), .B2(n777), 
        .Y(s_mem_d[470]) );
  sky130_fd_sc_hd__inv_1 U1064 ( .A(s_mem_q[469]), .Y(n776) );
  sky130_fd_sc_hd__o22ai_1 U1065 ( .A1(n3), .A2(n776), .B1(n581), .B2(n777), 
        .Y(s_mem_d[469]) );
  sky130_fd_sc_hd__inv_1 U1066 ( .A(s_mem_q[468]), .Y(n778) );
  sky130_fd_sc_hd__o22ai_1 U1067 ( .A1(n3), .A2(n778), .B1(n51), .B2(n777), 
        .Y(s_mem_d[468]) );
  sky130_fd_sc_hd__nand2_1 U1068 ( .A(n779), .B(n575), .Y(n780) );
  sky130_fd_sc_hd__inv_1 U1069 ( .A(s_mem_q[467]), .Y(n781) );
  sky130_fd_sc_hd__o22ai_1 U1070 ( .A1(n791), .A2(n781), .B1(n577), .B2(n789), 
        .Y(s_mem_d[467]) );
  sky130_fd_sc_hd__inv_1 U1071 ( .A(s_mem_q[466]), .Y(n782) );
  sky130_fd_sc_hd__o22ai_1 U1072 ( .A1(n791), .A2(n782), .B1(n56), .B2(n789), 
        .Y(s_mem_d[466]) );
  sky130_fd_sc_hd__inv_1 U1073 ( .A(s_mem_q[465]), .Y(n783) );
  sky130_fd_sc_hd__o22ai_1 U1074 ( .A1(n791), .A2(n783), .B1(n64), .B2(n789), 
        .Y(s_mem_d[465]) );
  sky130_fd_sc_hd__inv_1 U1075 ( .A(s_mem_q[464]), .Y(n784) );
  sky130_fd_sc_hd__o22ai_1 U1076 ( .A1(n791), .A2(n784), .B1(n72), .B2(n789), 
        .Y(s_mem_d[464]) );
  sky130_fd_sc_hd__inv_1 U1077 ( .A(s_mem_q[463]), .Y(n785) );
  sky130_fd_sc_hd__o22ai_1 U1078 ( .A1(n791), .A2(n785), .B1(n80), .B2(n789), 
        .Y(s_mem_d[463]) );
  sky130_fd_sc_hd__inv_1 U1079 ( .A(s_mem_q[462]), .Y(n786) );
  sky130_fd_sc_hd__o22ai_1 U1080 ( .A1(n791), .A2(n786), .B1(n88), .B2(n789), 
        .Y(s_mem_d[462]) );
  sky130_fd_sc_hd__inv_1 U1081 ( .A(s_mem_q[461]), .Y(n787) );
  sky130_fd_sc_hd__o22ai_1 U1082 ( .A1(n791), .A2(n787), .B1(n96), .B2(n789), 
        .Y(s_mem_d[461]) );
  sky130_fd_sc_hd__inv_1 U1083 ( .A(s_mem_q[460]), .Y(n788) );
  sky130_fd_sc_hd__o22ai_1 U1084 ( .A1(n791), .A2(n788), .B1(n581), .B2(n789), 
        .Y(s_mem_d[460]) );
  sky130_fd_sc_hd__inv_1 U1085 ( .A(s_mem_q[459]), .Y(n790) );
  sky130_fd_sc_hd__o22ai_1 U1086 ( .A1(n791), .A2(n790), .B1(n50), .B2(n789), 
        .Y(s_mem_d[459]) );
  sky130_fd_sc_hd__nand2_1 U1087 ( .A(n792), .B(n575), .Y(n793) );
  sky130_fd_sc_hd__inv_1 U1088 ( .A(s_mem_q[458]), .Y(n794) );
  sky130_fd_sc_hd__o22ai_1 U1089 ( .A1(n804), .A2(n794), .B1(n578), .B2(n802), 
        .Y(s_mem_d[458]) );
  sky130_fd_sc_hd__inv_1 U1090 ( .A(s_mem_q[457]), .Y(n795) );
  sky130_fd_sc_hd__o22ai_1 U1091 ( .A1(n804), .A2(n795), .B1(n57), .B2(n802), 
        .Y(s_mem_d[457]) );
  sky130_fd_sc_hd__inv_1 U1092 ( .A(s_mem_q[456]), .Y(n796) );
  sky130_fd_sc_hd__o22ai_1 U1093 ( .A1(n804), .A2(n796), .B1(n65), .B2(n802), 
        .Y(s_mem_d[456]) );
  sky130_fd_sc_hd__inv_1 U1094 ( .A(s_mem_q[455]), .Y(n797) );
  sky130_fd_sc_hd__o22ai_1 U1095 ( .A1(n804), .A2(n797), .B1(n73), .B2(n802), 
        .Y(s_mem_d[455]) );
  sky130_fd_sc_hd__inv_1 U1096 ( .A(s_mem_q[454]), .Y(n798) );
  sky130_fd_sc_hd__o22ai_1 U1097 ( .A1(n804), .A2(n798), .B1(n81), .B2(n802), 
        .Y(s_mem_d[454]) );
  sky130_fd_sc_hd__inv_1 U1098 ( .A(s_mem_q[453]), .Y(n799) );
  sky130_fd_sc_hd__o22ai_1 U1099 ( .A1(n804), .A2(n799), .B1(n89), .B2(n802), 
        .Y(s_mem_d[453]) );
  sky130_fd_sc_hd__inv_1 U1100 ( .A(s_mem_q[452]), .Y(n800) );
  sky130_fd_sc_hd__o22ai_1 U1101 ( .A1(n804), .A2(n800), .B1(n97), .B2(n802), 
        .Y(s_mem_d[452]) );
  sky130_fd_sc_hd__inv_1 U1102 ( .A(s_mem_q[451]), .Y(n801) );
  sky130_fd_sc_hd__o22ai_1 U1103 ( .A1(n804), .A2(n801), .B1(n581), .B2(n802), 
        .Y(s_mem_d[451]) );
  sky130_fd_sc_hd__inv_1 U1104 ( .A(s_mem_q[450]), .Y(n803) );
  sky130_fd_sc_hd__o22ai_1 U1105 ( .A1(n804), .A2(n803), .B1(n49), .B2(n802), 
        .Y(s_mem_d[450]) );
  sky130_fd_sc_hd__nand2_1 U1106 ( .A(n805), .B(n575), .Y(n806) );
  sky130_fd_sc_hd__inv_1 U1107 ( .A(s_mem_q[449]), .Y(n807) );
  sky130_fd_sc_hd__o22ai_1 U1108 ( .A1(n817), .A2(n807), .B1(n578), .B2(n815), 
        .Y(s_mem_d[449]) );
  sky130_fd_sc_hd__inv_1 U1109 ( .A(s_mem_q[448]), .Y(n808) );
  sky130_fd_sc_hd__o22ai_1 U1110 ( .A1(n817), .A2(n808), .B1(n62), .B2(n815), 
        .Y(s_mem_d[448]) );
  sky130_fd_sc_hd__inv_1 U1111 ( .A(s_mem_q[447]), .Y(n809) );
  sky130_fd_sc_hd__o22ai_1 U1112 ( .A1(n817), .A2(n809), .B1(n70), .B2(n815), 
        .Y(s_mem_d[447]) );
  sky130_fd_sc_hd__inv_1 U1113 ( .A(s_mem_q[446]), .Y(n810) );
  sky130_fd_sc_hd__o22ai_1 U1114 ( .A1(n817), .A2(n810), .B1(n78), .B2(n815), 
        .Y(s_mem_d[446]) );
  sky130_fd_sc_hd__inv_1 U1115 ( .A(s_mem_q[445]), .Y(n811) );
  sky130_fd_sc_hd__o22ai_1 U1116 ( .A1(n817), .A2(n811), .B1(n86), .B2(n815), 
        .Y(s_mem_d[445]) );
  sky130_fd_sc_hd__inv_1 U1117 ( .A(s_mem_q[444]), .Y(n812) );
  sky130_fd_sc_hd__o22ai_1 U1118 ( .A1(n817), .A2(n812), .B1(n94), .B2(n815), 
        .Y(s_mem_d[444]) );
  sky130_fd_sc_hd__inv_1 U1119 ( .A(s_mem_q[443]), .Y(n813) );
  sky130_fd_sc_hd__o22ai_1 U1120 ( .A1(n817), .A2(n813), .B1(n102), .B2(n815), 
        .Y(s_mem_d[443]) );
  sky130_fd_sc_hd__inv_1 U1121 ( .A(s_mem_q[442]), .Y(n814) );
  sky130_fd_sc_hd__o22ai_1 U1122 ( .A1(n817), .A2(n814), .B1(n582), .B2(n815), 
        .Y(s_mem_d[442]) );
  sky130_fd_sc_hd__inv_1 U1123 ( .A(s_mem_q[441]), .Y(n816) );
  sky130_fd_sc_hd__o22ai_1 U1124 ( .A1(n817), .A2(n816), .B1(n52), .B2(n815), 
        .Y(s_mem_d[441]) );
  sky130_fd_sc_hd__inv_1 U1125 ( .A(s_mem_q[440]), .Y(n820) );
  sky130_fd_sc_hd__o22ai_1 U1126 ( .A1(n37), .A2(n820), .B1(n578), .B2(n828), 
        .Y(s_mem_d[440]) );
  sky130_fd_sc_hd__inv_1 U1127 ( .A(s_mem_q[439]), .Y(n821) );
  sky130_fd_sc_hd__o22ai_1 U1128 ( .A1(n37), .A2(n821), .B1(n61), .B2(n828), 
        .Y(s_mem_d[439]) );
  sky130_fd_sc_hd__inv_1 U1129 ( .A(s_mem_q[438]), .Y(n822) );
  sky130_fd_sc_hd__o22ai_1 U1130 ( .A1(n37), .A2(n822), .B1(n69), .B2(n828), 
        .Y(s_mem_d[438]) );
  sky130_fd_sc_hd__inv_1 U1131 ( .A(s_mem_q[437]), .Y(n823) );
  sky130_fd_sc_hd__o22ai_1 U1132 ( .A1(n37), .A2(n823), .B1(n77), .B2(n828), 
        .Y(s_mem_d[437]) );
  sky130_fd_sc_hd__inv_1 U1133 ( .A(s_mem_q[436]), .Y(n824) );
  sky130_fd_sc_hd__o22ai_1 U1134 ( .A1(n37), .A2(n824), .B1(n85), .B2(n828), 
        .Y(s_mem_d[436]) );
  sky130_fd_sc_hd__inv_1 U1135 ( .A(s_mem_q[435]), .Y(n825) );
  sky130_fd_sc_hd__o22ai_1 U1136 ( .A1(n37), .A2(n825), .B1(n93), .B2(n828), 
        .Y(s_mem_d[435]) );
  sky130_fd_sc_hd__inv_1 U1137 ( .A(s_mem_q[434]), .Y(n826) );
  sky130_fd_sc_hd__o22ai_1 U1138 ( .A1(n37), .A2(n826), .B1(n101), .B2(n828), 
        .Y(s_mem_d[434]) );
  sky130_fd_sc_hd__inv_1 U1139 ( .A(s_mem_q[433]), .Y(n827) );
  sky130_fd_sc_hd__o22ai_1 U1140 ( .A1(n37), .A2(n827), .B1(n582), .B2(n828), 
        .Y(s_mem_d[433]) );
  sky130_fd_sc_hd__inv_1 U1141 ( .A(s_mem_q[432]), .Y(n829) );
  sky130_fd_sc_hd__o22ai_1 U1142 ( .A1(n37), .A2(n829), .B1(n51), .B2(n828), 
        .Y(s_mem_d[432]) );
  sky130_fd_sc_hd__inv_1 U1143 ( .A(s_wr_ptr_q[4]), .Y(n1424) );
  sky130_fd_sc_hd__nand3_1 U1144 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[3]), .C(
        n1424), .Y(n830) );
  sky130_fd_sc_hd__clkinv_2 U1145 ( .A(n830), .Y(n910) );
  sky130_fd_sc_hd__nand2_1 U1146 ( .A(n831), .B(n575), .Y(n832) );
  sky130_fd_sc_hd__inv_1 U1147 ( .A(s_mem_q[431]), .Y(n833) );
  sky130_fd_sc_hd__o22ai_1 U1148 ( .A1(n843), .A2(n833), .B1(n578), .B2(n841), 
        .Y(s_mem_d[431]) );
  sky130_fd_sc_hd__inv_1 U1149 ( .A(s_mem_q[430]), .Y(n834) );
  sky130_fd_sc_hd__o22ai_1 U1150 ( .A1(n843), .A2(n834), .B1(n57), .B2(n841), 
        .Y(s_mem_d[430]) );
  sky130_fd_sc_hd__inv_1 U1151 ( .A(s_mem_q[429]), .Y(n835) );
  sky130_fd_sc_hd__o22ai_1 U1152 ( .A1(n843), .A2(n835), .B1(n65), .B2(n841), 
        .Y(s_mem_d[429]) );
  sky130_fd_sc_hd__inv_1 U1153 ( .A(s_mem_q[428]), .Y(n836) );
  sky130_fd_sc_hd__o22ai_1 U1154 ( .A1(n843), .A2(n836), .B1(n73), .B2(n841), 
        .Y(s_mem_d[428]) );
  sky130_fd_sc_hd__inv_1 U1155 ( .A(s_mem_q[427]), .Y(n837) );
  sky130_fd_sc_hd__o22ai_1 U1156 ( .A1(n843), .A2(n837), .B1(n81), .B2(n841), 
        .Y(s_mem_d[427]) );
  sky130_fd_sc_hd__inv_1 U1157 ( .A(s_mem_q[426]), .Y(n838) );
  sky130_fd_sc_hd__o22ai_1 U1158 ( .A1(n843), .A2(n838), .B1(n89), .B2(n841), 
        .Y(s_mem_d[426]) );
  sky130_fd_sc_hd__inv_1 U1159 ( .A(s_mem_q[425]), .Y(n839) );
  sky130_fd_sc_hd__o22ai_1 U1160 ( .A1(n843), .A2(n839), .B1(n97), .B2(n841), 
        .Y(s_mem_d[425]) );
  sky130_fd_sc_hd__inv_1 U1161 ( .A(s_mem_q[424]), .Y(n840) );
  sky130_fd_sc_hd__o22ai_1 U1162 ( .A1(n843), .A2(n840), .B1(n583), .B2(n841), 
        .Y(s_mem_d[424]) );
  sky130_fd_sc_hd__inv_1 U1163 ( .A(s_mem_q[423]), .Y(n842) );
  sky130_fd_sc_hd__o22ai_1 U1164 ( .A1(n843), .A2(n842), .B1(n51), .B2(n841), 
        .Y(s_mem_d[423]) );
  sky130_fd_sc_hd__inv_1 U1165 ( .A(s_mem_q[422]), .Y(n845) );
  sky130_fd_sc_hd__o22ai_1 U1166 ( .A1(n21), .A2(n845), .B1(n578), .B2(n853), 
        .Y(s_mem_d[422]) );
  sky130_fd_sc_hd__inv_1 U1167 ( .A(s_mem_q[421]), .Y(n846) );
  sky130_fd_sc_hd__o22ai_1 U1168 ( .A1(n21), .A2(n846), .B1(n60), .B2(n853), 
        .Y(s_mem_d[421]) );
  sky130_fd_sc_hd__inv_1 U1169 ( .A(s_mem_q[420]), .Y(n847) );
  sky130_fd_sc_hd__o22ai_1 U1170 ( .A1(n21), .A2(n847), .B1(n68), .B2(n853), 
        .Y(s_mem_d[420]) );
  sky130_fd_sc_hd__inv_1 U1171 ( .A(s_mem_q[419]), .Y(n848) );
  sky130_fd_sc_hd__o22ai_1 U1172 ( .A1(n21), .A2(n848), .B1(n76), .B2(n853), 
        .Y(s_mem_d[419]) );
  sky130_fd_sc_hd__inv_1 U1173 ( .A(s_mem_q[418]), .Y(n849) );
  sky130_fd_sc_hd__o22ai_1 U1174 ( .A1(n21), .A2(n849), .B1(n84), .B2(n853), 
        .Y(s_mem_d[418]) );
  sky130_fd_sc_hd__inv_1 U1175 ( .A(s_mem_q[417]), .Y(n850) );
  sky130_fd_sc_hd__o22ai_1 U1176 ( .A1(n21), .A2(n850), .B1(n92), .B2(n853), 
        .Y(s_mem_d[417]) );
  sky130_fd_sc_hd__inv_1 U1177 ( .A(s_mem_q[416]), .Y(n851) );
  sky130_fd_sc_hd__o22ai_1 U1178 ( .A1(n21), .A2(n851), .B1(n100), .B2(n853), 
        .Y(s_mem_d[416]) );
  sky130_fd_sc_hd__inv_1 U1179 ( .A(s_mem_q[415]), .Y(n852) );
  sky130_fd_sc_hd__o22ai_1 U1180 ( .A1(n21), .A2(n852), .B1(n582), .B2(n853), 
        .Y(s_mem_d[415]) );
  sky130_fd_sc_hd__inv_1 U1181 ( .A(s_mem_q[414]), .Y(n854) );
  sky130_fd_sc_hd__o22ai_1 U1182 ( .A1(n21), .A2(n854), .B1(n53), .B2(n853), 
        .Y(s_mem_d[414]) );
  sky130_fd_sc_hd__inv_1 U1183 ( .A(s_mem_q[413]), .Y(n856) );
  sky130_fd_sc_hd__o22ai_1 U1184 ( .A1(n30), .A2(n856), .B1(n578), .B2(n864), 
        .Y(s_mem_d[413]) );
  sky130_fd_sc_hd__inv_1 U1185 ( .A(s_mem_q[412]), .Y(n857) );
  sky130_fd_sc_hd__o22ai_1 U1186 ( .A1(n30), .A2(n857), .B1(n61), .B2(n864), 
        .Y(s_mem_d[412]) );
  sky130_fd_sc_hd__inv_1 U1187 ( .A(s_mem_q[411]), .Y(n858) );
  sky130_fd_sc_hd__o22ai_1 U1188 ( .A1(n30), .A2(n858), .B1(n69), .B2(n864), 
        .Y(s_mem_d[411]) );
  sky130_fd_sc_hd__inv_1 U1189 ( .A(s_mem_q[410]), .Y(n859) );
  sky130_fd_sc_hd__o22ai_1 U1190 ( .A1(n30), .A2(n859), .B1(n77), .B2(n864), 
        .Y(s_mem_d[410]) );
  sky130_fd_sc_hd__inv_1 U1191 ( .A(s_mem_q[409]), .Y(n860) );
  sky130_fd_sc_hd__o22ai_1 U1192 ( .A1(n30), .A2(n860), .B1(n85), .B2(n864), 
        .Y(s_mem_d[409]) );
  sky130_fd_sc_hd__inv_1 U1193 ( .A(s_mem_q[408]), .Y(n861) );
  sky130_fd_sc_hd__o22ai_1 U1194 ( .A1(n30), .A2(n861), .B1(n93), .B2(n864), 
        .Y(s_mem_d[408]) );
  sky130_fd_sc_hd__inv_1 U1195 ( .A(s_mem_q[407]), .Y(n862) );
  sky130_fd_sc_hd__o22ai_1 U1196 ( .A1(n30), .A2(n862), .B1(n101), .B2(n864), 
        .Y(s_mem_d[407]) );
  sky130_fd_sc_hd__inv_1 U1197 ( .A(s_mem_q[406]), .Y(n863) );
  sky130_fd_sc_hd__o22ai_1 U1198 ( .A1(n30), .A2(n863), .B1(n582), .B2(n864), 
        .Y(s_mem_d[406]) );
  sky130_fd_sc_hd__inv_1 U1199 ( .A(s_mem_q[405]), .Y(n865) );
  sky130_fd_sc_hd__o22ai_1 U1200 ( .A1(n30), .A2(n865), .B1(n52), .B2(n864), 
        .Y(s_mem_d[405]) );
  sky130_fd_sc_hd__inv_1 U1201 ( .A(s_mem_q[404]), .Y(n867) );
  sky130_fd_sc_hd__o22ai_1 U1202 ( .A1(n8), .A2(n867), .B1(n578), .B2(n875), 
        .Y(s_mem_d[404]) );
  sky130_fd_sc_hd__inv_1 U1203 ( .A(s_mem_q[403]), .Y(n868) );
  sky130_fd_sc_hd__o22ai_1 U1204 ( .A1(n8), .A2(n868), .B1(n58), .B2(n875), 
        .Y(s_mem_d[403]) );
  sky130_fd_sc_hd__inv_1 U1205 ( .A(s_mem_q[402]), .Y(n869) );
  sky130_fd_sc_hd__o22ai_1 U1206 ( .A1(n8), .A2(n869), .B1(n66), .B2(n875), 
        .Y(s_mem_d[402]) );
  sky130_fd_sc_hd__inv_1 U1207 ( .A(s_mem_q[401]), .Y(n870) );
  sky130_fd_sc_hd__o22ai_1 U1208 ( .A1(n8), .A2(n870), .B1(n74), .B2(n875), 
        .Y(s_mem_d[401]) );
  sky130_fd_sc_hd__inv_1 U1209 ( .A(s_mem_q[400]), .Y(n871) );
  sky130_fd_sc_hd__o22ai_1 U1210 ( .A1(n8), .A2(n871), .B1(n82), .B2(n875), 
        .Y(s_mem_d[400]) );
  sky130_fd_sc_hd__inv_1 U1211 ( .A(s_mem_q[399]), .Y(n872) );
  sky130_fd_sc_hd__o22ai_1 U1212 ( .A1(n8), .A2(n872), .B1(n90), .B2(n875), 
        .Y(s_mem_d[399]) );
  sky130_fd_sc_hd__inv_1 U1213 ( .A(s_mem_q[398]), .Y(n873) );
  sky130_fd_sc_hd__o22ai_1 U1214 ( .A1(n8), .A2(n873), .B1(n98), .B2(n875), 
        .Y(s_mem_d[398]) );
  sky130_fd_sc_hd__inv_1 U1215 ( .A(s_mem_q[397]), .Y(n874) );
  sky130_fd_sc_hd__o22ai_1 U1216 ( .A1(n8), .A2(n874), .B1(n582), .B2(n875), 
        .Y(s_mem_d[397]) );
  sky130_fd_sc_hd__inv_1 U1217 ( .A(s_mem_q[396]), .Y(n876) );
  sky130_fd_sc_hd__o22ai_1 U1218 ( .A1(n8), .A2(n876), .B1(n49), .B2(n875), 
        .Y(s_mem_d[396]) );
  sky130_fd_sc_hd__inv_1 U1219 ( .A(s_mem_q[395]), .Y(n878) );
  sky130_fd_sc_hd__o22ai_1 U1220 ( .A1(n18), .A2(n878), .B1(n578), .B2(n886), 
        .Y(s_mem_d[395]) );
  sky130_fd_sc_hd__inv_1 U1221 ( .A(s_mem_q[394]), .Y(n879) );
  sky130_fd_sc_hd__o22ai_1 U1222 ( .A1(n18), .A2(n879), .B1(n57), .B2(n886), 
        .Y(s_mem_d[394]) );
  sky130_fd_sc_hd__inv_1 U1223 ( .A(s_mem_q[393]), .Y(n880) );
  sky130_fd_sc_hd__o22ai_1 U1224 ( .A1(n18), .A2(n880), .B1(n65), .B2(n886), 
        .Y(s_mem_d[393]) );
  sky130_fd_sc_hd__inv_1 U1225 ( .A(s_mem_q[392]), .Y(n881) );
  sky130_fd_sc_hd__o22ai_1 U1226 ( .A1(n18), .A2(n881), .B1(n73), .B2(n886), 
        .Y(s_mem_d[392]) );
  sky130_fd_sc_hd__inv_1 U1227 ( .A(s_mem_q[391]), .Y(n882) );
  sky130_fd_sc_hd__o22ai_1 U1228 ( .A1(n18), .A2(n882), .B1(n81), .B2(n886), 
        .Y(s_mem_d[391]) );
  sky130_fd_sc_hd__inv_1 U1229 ( .A(s_mem_q[390]), .Y(n883) );
  sky130_fd_sc_hd__o22ai_1 U1230 ( .A1(n18), .A2(n883), .B1(n89), .B2(n886), 
        .Y(s_mem_d[390]) );
  sky130_fd_sc_hd__inv_1 U1231 ( .A(s_mem_q[389]), .Y(n884) );
  sky130_fd_sc_hd__o22ai_1 U1232 ( .A1(n18), .A2(n884), .B1(n97), .B2(n886), 
        .Y(s_mem_d[389]) );
  sky130_fd_sc_hd__inv_1 U1233 ( .A(s_mem_q[388]), .Y(n885) );
  sky130_fd_sc_hd__o22ai_1 U1234 ( .A1(n18), .A2(n885), .B1(n582), .B2(n886), 
        .Y(s_mem_d[388]) );
  sky130_fd_sc_hd__inv_1 U1235 ( .A(s_mem_q[387]), .Y(n887) );
  sky130_fd_sc_hd__o22ai_1 U1236 ( .A1(n18), .A2(n887), .B1(n49), .B2(n886), 
        .Y(s_mem_d[387]) );
  sky130_fd_sc_hd__inv_1 U1237 ( .A(s_mem_q[386]), .Y(n889) );
  sky130_fd_sc_hd__o22ai_1 U1238 ( .A1(n35), .A2(n889), .B1(n578), .B2(n897), 
        .Y(s_mem_d[386]) );
  sky130_fd_sc_hd__inv_1 U1239 ( .A(s_mem_q[385]), .Y(n890) );
  sky130_fd_sc_hd__o22ai_1 U1240 ( .A1(n35), .A2(n890), .B1(n61), .B2(n897), 
        .Y(s_mem_d[385]) );
  sky130_fd_sc_hd__inv_1 U1241 ( .A(s_mem_q[384]), .Y(n891) );
  sky130_fd_sc_hd__o22ai_1 U1242 ( .A1(n35), .A2(n891), .B1(n69), .B2(n897), 
        .Y(s_mem_d[384]) );
  sky130_fd_sc_hd__inv_1 U1243 ( .A(s_mem_q[383]), .Y(n892) );
  sky130_fd_sc_hd__o22ai_1 U1244 ( .A1(n35), .A2(n892), .B1(n77), .B2(n897), 
        .Y(s_mem_d[383]) );
  sky130_fd_sc_hd__inv_1 U1245 ( .A(s_mem_q[382]), .Y(n893) );
  sky130_fd_sc_hd__o22ai_1 U1246 ( .A1(n35), .A2(n893), .B1(n85), .B2(n897), 
        .Y(s_mem_d[382]) );
  sky130_fd_sc_hd__inv_1 U1247 ( .A(s_mem_q[381]), .Y(n894) );
  sky130_fd_sc_hd__o22ai_1 U1248 ( .A1(n35), .A2(n894), .B1(n93), .B2(n897), 
        .Y(s_mem_d[381]) );
  sky130_fd_sc_hd__inv_1 U1249 ( .A(s_mem_q[380]), .Y(n895) );
  sky130_fd_sc_hd__o22ai_1 U1250 ( .A1(n35), .A2(n895), .B1(n101), .B2(n897), 
        .Y(s_mem_d[380]) );
  sky130_fd_sc_hd__inv_1 U1251 ( .A(s_mem_q[379]), .Y(n896) );
  sky130_fd_sc_hd__o22ai_1 U1252 ( .A1(n35), .A2(n896), .B1(n582), .B2(n897), 
        .Y(s_mem_d[379]) );
  sky130_fd_sc_hd__inv_1 U1253 ( .A(s_mem_q[378]), .Y(n898) );
  sky130_fd_sc_hd__o22ai_1 U1254 ( .A1(n35), .A2(n898), .B1(n49), .B2(n897), 
        .Y(s_mem_d[378]) );
  sky130_fd_sc_hd__inv_1 U1255 ( .A(s_mem_q[377]), .Y(n900) );
  sky130_fd_sc_hd__o22ai_1 U1256 ( .A1(n36), .A2(n900), .B1(n578), .B2(n908), 
        .Y(s_mem_d[377]) );
  sky130_fd_sc_hd__inv_1 U1257 ( .A(s_mem_q[376]), .Y(n901) );
  sky130_fd_sc_hd__o22ai_1 U1258 ( .A1(n36), .A2(n901), .B1(n59), .B2(n908), 
        .Y(s_mem_d[376]) );
  sky130_fd_sc_hd__inv_1 U1259 ( .A(s_mem_q[375]), .Y(n902) );
  sky130_fd_sc_hd__o22ai_1 U1260 ( .A1(n36), .A2(n902), .B1(n67), .B2(n908), 
        .Y(s_mem_d[375]) );
  sky130_fd_sc_hd__inv_1 U1261 ( .A(s_mem_q[374]), .Y(n903) );
  sky130_fd_sc_hd__o22ai_1 U1262 ( .A1(n36), .A2(n903), .B1(n75), .B2(n908), 
        .Y(s_mem_d[374]) );
  sky130_fd_sc_hd__inv_1 U1263 ( .A(s_mem_q[373]), .Y(n904) );
  sky130_fd_sc_hd__o22ai_1 U1264 ( .A1(n36), .A2(n904), .B1(n83), .B2(n908), 
        .Y(s_mem_d[373]) );
  sky130_fd_sc_hd__inv_1 U1265 ( .A(s_mem_q[372]), .Y(n905) );
  sky130_fd_sc_hd__o22ai_1 U1266 ( .A1(n36), .A2(n905), .B1(n91), .B2(n908), 
        .Y(s_mem_d[372]) );
  sky130_fd_sc_hd__inv_1 U1267 ( .A(s_mem_q[371]), .Y(n906) );
  sky130_fd_sc_hd__o22ai_1 U1268 ( .A1(n36), .A2(n906), .B1(n99), .B2(n908), 
        .Y(s_mem_d[371]) );
  sky130_fd_sc_hd__inv_1 U1269 ( .A(s_mem_q[370]), .Y(n907) );
  sky130_fd_sc_hd__o22ai_1 U1270 ( .A1(n36), .A2(n907), .B1(n582), .B2(n908), 
        .Y(s_mem_d[370]) );
  sky130_fd_sc_hd__inv_1 U1271 ( .A(s_mem_q[369]), .Y(n909) );
  sky130_fd_sc_hd__o22ai_1 U1272 ( .A1(n36), .A2(n909), .B1(n52), .B2(n908), 
        .Y(s_mem_d[369]) );
  sky130_fd_sc_hd__inv_1 U1273 ( .A(s_mem_q[368]), .Y(n912) );
  sky130_fd_sc_hd__o22ai_1 U1274 ( .A1(n19), .A2(n912), .B1(n578), .B2(n920), 
        .Y(s_mem_d[368]) );
  sky130_fd_sc_hd__inv_1 U1275 ( .A(s_mem_q[367]), .Y(n913) );
  sky130_fd_sc_hd__o22ai_1 U1276 ( .A1(n19), .A2(n913), .B1(n60), .B2(n920), 
        .Y(s_mem_d[367]) );
  sky130_fd_sc_hd__inv_1 U1277 ( .A(s_mem_q[366]), .Y(n914) );
  sky130_fd_sc_hd__o22ai_1 U1278 ( .A1(n19), .A2(n914), .B1(n68), .B2(n920), 
        .Y(s_mem_d[366]) );
  sky130_fd_sc_hd__inv_1 U1279 ( .A(s_mem_q[365]), .Y(n915) );
  sky130_fd_sc_hd__o22ai_1 U1280 ( .A1(n19), .A2(n915), .B1(n76), .B2(n920), 
        .Y(s_mem_d[365]) );
  sky130_fd_sc_hd__inv_1 U1281 ( .A(s_mem_q[364]), .Y(n916) );
  sky130_fd_sc_hd__o22ai_1 U1282 ( .A1(n19), .A2(n916), .B1(n84), .B2(n920), 
        .Y(s_mem_d[364]) );
  sky130_fd_sc_hd__inv_1 U1283 ( .A(s_mem_q[363]), .Y(n917) );
  sky130_fd_sc_hd__o22ai_1 U1284 ( .A1(n19), .A2(n917), .B1(n92), .B2(n920), 
        .Y(s_mem_d[363]) );
  sky130_fd_sc_hd__inv_1 U1285 ( .A(s_mem_q[362]), .Y(n918) );
  sky130_fd_sc_hd__o22ai_1 U1286 ( .A1(n19), .A2(n918), .B1(n100), .B2(n920), 
        .Y(s_mem_d[362]) );
  sky130_fd_sc_hd__inv_1 U1287 ( .A(s_mem_q[361]), .Y(n919) );
  sky130_fd_sc_hd__o22ai_1 U1288 ( .A1(n19), .A2(n919), .B1(n582), .B2(n920), 
        .Y(s_mem_d[361]) );
  sky130_fd_sc_hd__inv_1 U1289 ( .A(s_mem_q[360]), .Y(n921) );
  sky130_fd_sc_hd__o22ai_1 U1290 ( .A1(n19), .A2(n921), .B1(n53), .B2(n920), 
        .Y(s_mem_d[360]) );
  sky130_fd_sc_hd__nand3_1 U1291 ( .A(s_wr_ptr_q[5]), .B(n1424), .C(n1425), 
        .Y(n922) );
  sky130_fd_sc_hd__inv_1 U1292 ( .A(s_mem_q[359]), .Y(n924) );
  sky130_fd_sc_hd__o22ai_1 U1293 ( .A1(n41), .A2(n924), .B1(n578), .B2(n932), 
        .Y(s_mem_d[359]) );
  sky130_fd_sc_hd__inv_1 U1294 ( .A(s_mem_q[358]), .Y(n925) );
  sky130_fd_sc_hd__o22ai_1 U1295 ( .A1(n41), .A2(n925), .B1(n56), .B2(n932), 
        .Y(s_mem_d[358]) );
  sky130_fd_sc_hd__inv_1 U1296 ( .A(s_mem_q[357]), .Y(n926) );
  sky130_fd_sc_hd__o22ai_1 U1297 ( .A1(n41), .A2(n926), .B1(n64), .B2(n932), 
        .Y(s_mem_d[357]) );
  sky130_fd_sc_hd__inv_1 U1298 ( .A(s_mem_q[356]), .Y(n927) );
  sky130_fd_sc_hd__o22ai_1 U1299 ( .A1(n41), .A2(n927), .B1(n72), .B2(n932), 
        .Y(s_mem_d[356]) );
  sky130_fd_sc_hd__inv_1 U1300 ( .A(s_mem_q[355]), .Y(n928) );
  sky130_fd_sc_hd__o22ai_1 U1301 ( .A1(n41), .A2(n928), .B1(n80), .B2(n932), 
        .Y(s_mem_d[355]) );
  sky130_fd_sc_hd__inv_1 U1302 ( .A(s_mem_q[354]), .Y(n929) );
  sky130_fd_sc_hd__o22ai_1 U1303 ( .A1(n41), .A2(n929), .B1(n88), .B2(n932), 
        .Y(s_mem_d[354]) );
  sky130_fd_sc_hd__inv_1 U1304 ( .A(s_mem_q[353]), .Y(n930) );
  sky130_fd_sc_hd__o22ai_1 U1305 ( .A1(n41), .A2(n930), .B1(n96), .B2(n932), 
        .Y(s_mem_d[353]) );
  sky130_fd_sc_hd__inv_1 U1306 ( .A(s_mem_q[352]), .Y(n931) );
  sky130_fd_sc_hd__o22ai_1 U1307 ( .A1(n41), .A2(n931), .B1(n582), .B2(n932), 
        .Y(s_mem_d[352]) );
  sky130_fd_sc_hd__inv_1 U1308 ( .A(s_mem_q[351]), .Y(n933) );
  sky130_fd_sc_hd__o22ai_1 U1309 ( .A1(n41), .A2(n933), .B1(n50), .B2(n932), 
        .Y(s_mem_d[351]) );
  sky130_fd_sc_hd__inv_1 U1310 ( .A(s_mem_q[350]), .Y(n935) );
  sky130_fd_sc_hd__o22ai_1 U1311 ( .A1(n9), .A2(n935), .B1(n578), .B2(n943), 
        .Y(s_mem_d[350]) );
  sky130_fd_sc_hd__inv_1 U1312 ( .A(s_mem_q[349]), .Y(n936) );
  sky130_fd_sc_hd__o22ai_1 U1313 ( .A1(n9), .A2(n936), .B1(n58), .B2(n943), 
        .Y(s_mem_d[349]) );
  sky130_fd_sc_hd__inv_1 U1314 ( .A(s_mem_q[348]), .Y(n937) );
  sky130_fd_sc_hd__o22ai_1 U1315 ( .A1(n9), .A2(n937), .B1(n66), .B2(n943), 
        .Y(s_mem_d[348]) );
  sky130_fd_sc_hd__inv_1 U1316 ( .A(s_mem_q[347]), .Y(n938) );
  sky130_fd_sc_hd__o22ai_1 U1317 ( .A1(n9), .A2(n938), .B1(n74), .B2(n943), 
        .Y(s_mem_d[347]) );
  sky130_fd_sc_hd__inv_1 U1318 ( .A(s_mem_q[346]), .Y(n939) );
  sky130_fd_sc_hd__o22ai_1 U1319 ( .A1(n9), .A2(n939), .B1(n82), .B2(n943), 
        .Y(s_mem_d[346]) );
  sky130_fd_sc_hd__inv_1 U1320 ( .A(s_mem_q[345]), .Y(n940) );
  sky130_fd_sc_hd__o22ai_1 U1321 ( .A1(n9), .A2(n940), .B1(n90), .B2(n943), 
        .Y(s_mem_d[345]) );
  sky130_fd_sc_hd__inv_1 U1322 ( .A(s_mem_q[344]), .Y(n941) );
  sky130_fd_sc_hd__o22ai_1 U1323 ( .A1(n9), .A2(n941), .B1(n98), .B2(n943), 
        .Y(s_mem_d[344]) );
  sky130_fd_sc_hd__inv_1 U1324 ( .A(s_mem_q[343]), .Y(n942) );
  sky130_fd_sc_hd__o22ai_1 U1325 ( .A1(n9), .A2(n942), .B1(n582), .B2(n943), 
        .Y(s_mem_d[343]) );
  sky130_fd_sc_hd__inv_1 U1326 ( .A(s_mem_q[342]), .Y(n944) );
  sky130_fd_sc_hd__o22ai_1 U1327 ( .A1(n9), .A2(n944), .B1(n51), .B2(n943), 
        .Y(s_mem_d[342]) );
  sky130_fd_sc_hd__inv_1 U1328 ( .A(s_mem_q[341]), .Y(n946) );
  sky130_fd_sc_hd__o22ai_1 U1329 ( .A1(n12), .A2(n946), .B1(n579), .B2(n954), 
        .Y(s_mem_d[341]) );
  sky130_fd_sc_hd__inv_1 U1330 ( .A(s_mem_q[340]), .Y(n947) );
  sky130_fd_sc_hd__o22ai_1 U1331 ( .A1(n12), .A2(n947), .B1(n57), .B2(n954), 
        .Y(s_mem_d[340]) );
  sky130_fd_sc_hd__inv_1 U1332 ( .A(s_mem_q[339]), .Y(n948) );
  sky130_fd_sc_hd__o22ai_1 U1333 ( .A1(n12), .A2(n948), .B1(n65), .B2(n954), 
        .Y(s_mem_d[339]) );
  sky130_fd_sc_hd__inv_1 U1334 ( .A(s_mem_q[338]), .Y(n949) );
  sky130_fd_sc_hd__o22ai_1 U1335 ( .A1(n12), .A2(n949), .B1(n73), .B2(n954), 
        .Y(s_mem_d[338]) );
  sky130_fd_sc_hd__inv_1 U1336 ( .A(s_mem_q[337]), .Y(n950) );
  sky130_fd_sc_hd__o22ai_1 U1337 ( .A1(n12), .A2(n950), .B1(n81), .B2(n954), 
        .Y(s_mem_d[337]) );
  sky130_fd_sc_hd__inv_1 U1338 ( .A(s_mem_q[336]), .Y(n951) );
  sky130_fd_sc_hd__o22ai_1 U1339 ( .A1(n12), .A2(n951), .B1(n89), .B2(n954), 
        .Y(s_mem_d[336]) );
  sky130_fd_sc_hd__inv_1 U1340 ( .A(s_mem_q[335]), .Y(n952) );
  sky130_fd_sc_hd__o22ai_1 U1341 ( .A1(n12), .A2(n952), .B1(n97), .B2(n954), 
        .Y(s_mem_d[335]) );
  sky130_fd_sc_hd__inv_1 U1342 ( .A(s_mem_q[334]), .Y(n953) );
  sky130_fd_sc_hd__o22ai_1 U1343 ( .A1(n12), .A2(n953), .B1(n582), .B2(n954), 
        .Y(s_mem_d[334]) );
  sky130_fd_sc_hd__inv_1 U1344 ( .A(s_mem_q[333]), .Y(n955) );
  sky130_fd_sc_hd__o22ai_1 U1345 ( .A1(n12), .A2(n955), .B1(n51), .B2(n954), 
        .Y(s_mem_d[333]) );
  sky130_fd_sc_hd__inv_1 U1346 ( .A(s_mem_q[332]), .Y(n957) );
  sky130_fd_sc_hd__o22ai_1 U1347 ( .A1(n28), .A2(n957), .B1(n579), .B2(n965), 
        .Y(s_mem_d[332]) );
  sky130_fd_sc_hd__inv_1 U1348 ( .A(s_mem_q[331]), .Y(n958) );
  sky130_fd_sc_hd__o22ai_1 U1349 ( .A1(n28), .A2(n958), .B1(n56), .B2(n965), 
        .Y(s_mem_d[331]) );
  sky130_fd_sc_hd__inv_1 U1350 ( .A(s_mem_q[330]), .Y(n959) );
  sky130_fd_sc_hd__o22ai_1 U1351 ( .A1(n28), .A2(n959), .B1(n64), .B2(n965), 
        .Y(s_mem_d[330]) );
  sky130_fd_sc_hd__inv_1 U1352 ( .A(s_mem_q[329]), .Y(n960) );
  sky130_fd_sc_hd__o22ai_1 U1353 ( .A1(n28), .A2(n960), .B1(n72), .B2(n965), 
        .Y(s_mem_d[329]) );
  sky130_fd_sc_hd__inv_1 U1354 ( .A(s_mem_q[328]), .Y(n961) );
  sky130_fd_sc_hd__o22ai_1 U1355 ( .A1(n28), .A2(n961), .B1(n80), .B2(n965), 
        .Y(s_mem_d[328]) );
  sky130_fd_sc_hd__inv_1 U1356 ( .A(s_mem_q[327]), .Y(n962) );
  sky130_fd_sc_hd__o22ai_1 U1357 ( .A1(n28), .A2(n962), .B1(n88), .B2(n965), 
        .Y(s_mem_d[327]) );
  sky130_fd_sc_hd__inv_1 U1358 ( .A(s_mem_q[326]), .Y(n963) );
  sky130_fd_sc_hd__o22ai_1 U1359 ( .A1(n28), .A2(n963), .B1(n96), .B2(n965), 
        .Y(s_mem_d[326]) );
  sky130_fd_sc_hd__inv_1 U1360 ( .A(s_mem_q[325]), .Y(n964) );
  sky130_fd_sc_hd__o22ai_1 U1361 ( .A1(n28), .A2(n964), .B1(n582), .B2(n965), 
        .Y(s_mem_d[325]) );
  sky130_fd_sc_hd__inv_1 U1362 ( .A(s_mem_q[324]), .Y(n966) );
  sky130_fd_sc_hd__o22ai_1 U1363 ( .A1(n28), .A2(n966), .B1(n50), .B2(n965), 
        .Y(s_mem_d[324]) );
  sky130_fd_sc_hd__nand2_1 U1364 ( .A(n967), .B(n575), .Y(n968) );
  sky130_fd_sc_hd__inv_1 U1365 ( .A(s_mem_q[323]), .Y(n969) );
  sky130_fd_sc_hd__o22ai_1 U1366 ( .A1(n979), .A2(n969), .B1(n579), .B2(n977), 
        .Y(s_mem_d[323]) );
  sky130_fd_sc_hd__inv_1 U1367 ( .A(s_mem_q[322]), .Y(n970) );
  sky130_fd_sc_hd__o22ai_1 U1368 ( .A1(n979), .A2(n970), .B1(n58), .B2(n977), 
        .Y(s_mem_d[322]) );
  sky130_fd_sc_hd__inv_1 U1369 ( .A(s_mem_q[321]), .Y(n971) );
  sky130_fd_sc_hd__o22ai_1 U1370 ( .A1(n979), .A2(n971), .B1(n66), .B2(n977), 
        .Y(s_mem_d[321]) );
  sky130_fd_sc_hd__inv_1 U1371 ( .A(s_mem_q[320]), .Y(n972) );
  sky130_fd_sc_hd__o22ai_1 U1372 ( .A1(n979), .A2(n972), .B1(n74), .B2(n977), 
        .Y(s_mem_d[320]) );
  sky130_fd_sc_hd__inv_1 U1373 ( .A(s_mem_q[319]), .Y(n973) );
  sky130_fd_sc_hd__o22ai_1 U1374 ( .A1(n979), .A2(n973), .B1(n82), .B2(n977), 
        .Y(s_mem_d[319]) );
  sky130_fd_sc_hd__inv_1 U1375 ( .A(s_mem_q[318]), .Y(n974) );
  sky130_fd_sc_hd__o22ai_1 U1376 ( .A1(n979), .A2(n974), .B1(n90), .B2(n977), 
        .Y(s_mem_d[318]) );
  sky130_fd_sc_hd__inv_1 U1377 ( .A(s_mem_q[317]), .Y(n975) );
  sky130_fd_sc_hd__o22ai_1 U1378 ( .A1(n979), .A2(n975), .B1(n98), .B2(n977), 
        .Y(s_mem_d[317]) );
  sky130_fd_sc_hd__inv_1 U1379 ( .A(s_mem_q[316]), .Y(n976) );
  sky130_fd_sc_hd__o22ai_1 U1380 ( .A1(n979), .A2(n976), .B1(n583), .B2(n977), 
        .Y(s_mem_d[316]) );
  sky130_fd_sc_hd__inv_1 U1381 ( .A(s_mem_q[315]), .Y(n978) );
  sky130_fd_sc_hd__o22ai_1 U1382 ( .A1(n979), .A2(n978), .B1(n53), .B2(n977), 
        .Y(s_mem_d[315]) );
  sky130_fd_sc_hd__nand2_1 U1383 ( .A(n980), .B(n575), .Y(n981) );
  sky130_fd_sc_hd__inv_1 U1384 ( .A(s_mem_q[314]), .Y(n982) );
  sky130_fd_sc_hd__o22ai_1 U1385 ( .A1(n992), .A2(n982), .B1(n579), .B2(n990), 
        .Y(s_mem_d[314]) );
  sky130_fd_sc_hd__inv_1 U1386 ( .A(s_mem_q[313]), .Y(n983) );
  sky130_fd_sc_hd__o22ai_1 U1387 ( .A1(n992), .A2(n983), .B1(n56), .B2(n990), 
        .Y(s_mem_d[313]) );
  sky130_fd_sc_hd__inv_1 U1388 ( .A(s_mem_q[312]), .Y(n984) );
  sky130_fd_sc_hd__o22ai_1 U1389 ( .A1(n992), .A2(n984), .B1(n64), .B2(n990), 
        .Y(s_mem_d[312]) );
  sky130_fd_sc_hd__inv_1 U1390 ( .A(s_mem_q[311]), .Y(n985) );
  sky130_fd_sc_hd__o22ai_1 U1391 ( .A1(n992), .A2(n985), .B1(n72), .B2(n990), 
        .Y(s_mem_d[311]) );
  sky130_fd_sc_hd__inv_1 U1392 ( .A(s_mem_q[310]), .Y(n986) );
  sky130_fd_sc_hd__o22ai_1 U1393 ( .A1(n992), .A2(n986), .B1(n80), .B2(n990), 
        .Y(s_mem_d[310]) );
  sky130_fd_sc_hd__inv_1 U1394 ( .A(s_mem_q[309]), .Y(n987) );
  sky130_fd_sc_hd__o22ai_1 U1395 ( .A1(n992), .A2(n987), .B1(n88), .B2(n990), 
        .Y(s_mem_d[309]) );
  sky130_fd_sc_hd__inv_1 U1396 ( .A(s_mem_q[308]), .Y(n988) );
  sky130_fd_sc_hd__o22ai_1 U1397 ( .A1(n992), .A2(n988), .B1(n96), .B2(n990), 
        .Y(s_mem_d[308]) );
  sky130_fd_sc_hd__inv_1 U1398 ( .A(s_mem_q[307]), .Y(n989) );
  sky130_fd_sc_hd__o22ai_1 U1399 ( .A1(n992), .A2(n989), .B1(n583), .B2(n990), 
        .Y(s_mem_d[307]) );
  sky130_fd_sc_hd__inv_1 U1400 ( .A(s_mem_q[306]), .Y(n991) );
  sky130_fd_sc_hd__o22ai_1 U1401 ( .A1(n992), .A2(n991), .B1(n53), .B2(n990), 
        .Y(s_mem_d[306]) );
  sky130_fd_sc_hd__nand2_1 U1402 ( .A(n993), .B(n575), .Y(n994) );
  sky130_fd_sc_hd__inv_1 U1403 ( .A(s_mem_q[305]), .Y(n995) );
  sky130_fd_sc_hd__o22ai_1 U1404 ( .A1(n1005), .A2(n995), .B1(n579), .B2(n1003), .Y(s_mem_d[305]) );
  sky130_fd_sc_hd__inv_1 U1405 ( .A(s_mem_q[304]), .Y(n996) );
  sky130_fd_sc_hd__o22ai_1 U1406 ( .A1(n1005), .A2(n996), .B1(n58), .B2(n1003), 
        .Y(s_mem_d[304]) );
  sky130_fd_sc_hd__inv_1 U1407 ( .A(s_mem_q[303]), .Y(n997) );
  sky130_fd_sc_hd__o22ai_1 U1408 ( .A1(n1005), .A2(n997), .B1(n66), .B2(n1003), 
        .Y(s_mem_d[303]) );
  sky130_fd_sc_hd__inv_1 U1409 ( .A(s_mem_q[302]), .Y(n998) );
  sky130_fd_sc_hd__o22ai_1 U1410 ( .A1(n1005), .A2(n998), .B1(n74), .B2(n1003), 
        .Y(s_mem_d[302]) );
  sky130_fd_sc_hd__inv_1 U1411 ( .A(s_mem_q[301]), .Y(n999) );
  sky130_fd_sc_hd__o22ai_1 U1412 ( .A1(n1005), .A2(n999), .B1(n82), .B2(n1003), 
        .Y(s_mem_d[301]) );
  sky130_fd_sc_hd__inv_1 U1413 ( .A(s_mem_q[300]), .Y(n1000) );
  sky130_fd_sc_hd__o22ai_1 U1414 ( .A1(n1005), .A2(n1000), .B1(n90), .B2(n1003), .Y(s_mem_d[300]) );
  sky130_fd_sc_hd__inv_1 U1415 ( .A(s_mem_q[299]), .Y(n1001) );
  sky130_fd_sc_hd__o22ai_1 U1416 ( .A1(n1005), .A2(n1001), .B1(n98), .B2(n1003), .Y(s_mem_d[299]) );
  sky130_fd_sc_hd__inv_1 U1417 ( .A(s_mem_q[298]), .Y(n1002) );
  sky130_fd_sc_hd__o22ai_1 U1418 ( .A1(n1005), .A2(n1002), .B1(n583), .B2(
        n1003), .Y(s_mem_d[298]) );
  sky130_fd_sc_hd__inv_1 U1419 ( .A(s_mem_q[297]), .Y(n1004) );
  sky130_fd_sc_hd__o22ai_1 U1420 ( .A1(n1005), .A2(n1004), .B1(n49), .B2(n1003), .Y(s_mem_d[297]) );
  sky130_fd_sc_hd__nand2_1 U1421 ( .A(n1007), .B(n575), .Y(n1008) );
  sky130_fd_sc_hd__inv_1 U1422 ( .A(s_mem_q[296]), .Y(n1009) );
  sky130_fd_sc_hd__o22ai_1 U1423 ( .A1(n1019), .A2(n1009), .B1(n579), .B2(
        n1017), .Y(s_mem_d[296]) );
  sky130_fd_sc_hd__inv_1 U1424 ( .A(s_mem_q[295]), .Y(n1010) );
  sky130_fd_sc_hd__o22ai_1 U1425 ( .A1(n1019), .A2(n1010), .B1(n56), .B2(n1017), .Y(s_mem_d[295]) );
  sky130_fd_sc_hd__inv_1 U1426 ( .A(s_mem_q[294]), .Y(n1011) );
  sky130_fd_sc_hd__o22ai_1 U1427 ( .A1(n1019), .A2(n1011), .B1(n64), .B2(n1017), .Y(s_mem_d[294]) );
  sky130_fd_sc_hd__inv_1 U1428 ( .A(s_mem_q[293]), .Y(n1012) );
  sky130_fd_sc_hd__o22ai_1 U1429 ( .A1(n1019), .A2(n1012), .B1(n72), .B2(n1017), .Y(s_mem_d[293]) );
  sky130_fd_sc_hd__inv_1 U1430 ( .A(s_mem_q[292]), .Y(n1013) );
  sky130_fd_sc_hd__o22ai_1 U1431 ( .A1(n1019), .A2(n1013), .B1(n80), .B2(n1017), .Y(s_mem_d[292]) );
  sky130_fd_sc_hd__inv_1 U1432 ( .A(s_mem_q[291]), .Y(n1014) );
  sky130_fd_sc_hd__o22ai_1 U1433 ( .A1(n1019), .A2(n1014), .B1(n88), .B2(n1017), .Y(s_mem_d[291]) );
  sky130_fd_sc_hd__inv_1 U1434 ( .A(s_mem_q[290]), .Y(n1015) );
  sky130_fd_sc_hd__o22ai_1 U1435 ( .A1(n1019), .A2(n1015), .B1(n96), .B2(n1017), .Y(s_mem_d[290]) );
  sky130_fd_sc_hd__inv_1 U1436 ( .A(s_mem_q[289]), .Y(n1016) );
  sky130_fd_sc_hd__o22ai_1 U1437 ( .A1(n1019), .A2(n1016), .B1(n583), .B2(
        n1017), .Y(s_mem_d[289]) );
  sky130_fd_sc_hd__inv_1 U1438 ( .A(s_mem_q[288]), .Y(n1018) );
  sky130_fd_sc_hd__o22ai_1 U1439 ( .A1(n1019), .A2(n1018), .B1(n51), .B2(n1017), .Y(s_mem_d[288]) );
  sky130_fd_sc_hd__inv_1 U1440 ( .A(s_wr_ptr_q[5]), .Y(n1423) );
  sky130_fd_sc_hd__nand2_1 U1441 ( .A(n46), .B(n1423), .Y(n1020) );
  sky130_fd_sc_hd__nand2_1 U1442 ( .A(n1021), .B(n575), .Y(n1022) );
  sky130_fd_sc_hd__inv_1 U1443 ( .A(s_mem_q[287]), .Y(n1023) );
  sky130_fd_sc_hd__o22ai_1 U1444 ( .A1(n1033), .A2(n1023), .B1(n579), .B2(
        n1031), .Y(s_mem_d[287]) );
  sky130_fd_sc_hd__inv_1 U1445 ( .A(s_mem_q[286]), .Y(n1024) );
  sky130_fd_sc_hd__o22ai_1 U1446 ( .A1(n1033), .A2(n1024), .B1(n58), .B2(n1031), .Y(s_mem_d[286]) );
  sky130_fd_sc_hd__inv_1 U1447 ( .A(s_mem_q[285]), .Y(n1025) );
  sky130_fd_sc_hd__o22ai_1 U1448 ( .A1(n1033), .A2(n1025), .B1(n66), .B2(n1031), .Y(s_mem_d[285]) );
  sky130_fd_sc_hd__inv_1 U1449 ( .A(s_mem_q[284]), .Y(n1026) );
  sky130_fd_sc_hd__o22ai_1 U1450 ( .A1(n1033), .A2(n1026), .B1(n74), .B2(n1031), .Y(s_mem_d[284]) );
  sky130_fd_sc_hd__inv_1 U1451 ( .A(s_mem_q[283]), .Y(n1027) );
  sky130_fd_sc_hd__o22ai_1 U1452 ( .A1(n1033), .A2(n1027), .B1(n82), .B2(n1031), .Y(s_mem_d[283]) );
  sky130_fd_sc_hd__inv_1 U1453 ( .A(s_mem_q[282]), .Y(n1028) );
  sky130_fd_sc_hd__o22ai_1 U1454 ( .A1(n1033), .A2(n1028), .B1(n90), .B2(n1031), .Y(s_mem_d[282]) );
  sky130_fd_sc_hd__inv_1 U1455 ( .A(s_mem_q[281]), .Y(n1029) );
  sky130_fd_sc_hd__o22ai_1 U1456 ( .A1(n1033), .A2(n1029), .B1(n98), .B2(n1031), .Y(s_mem_d[281]) );
  sky130_fd_sc_hd__inv_1 U1457 ( .A(s_mem_q[280]), .Y(n1030) );
  sky130_fd_sc_hd__o22ai_1 U1458 ( .A1(n1033), .A2(n1030), .B1(n583), .B2(
        n1031), .Y(s_mem_d[280]) );
  sky130_fd_sc_hd__inv_1 U1459 ( .A(s_mem_q[279]), .Y(n1032) );
  sky130_fd_sc_hd__o22ai_1 U1460 ( .A1(n1033), .A2(n1032), .B1(n50), .B2(n1031), .Y(s_mem_d[279]) );
  sky130_fd_sc_hd__inv_1 U1461 ( .A(s_mem_q[278]), .Y(n1035) );
  sky130_fd_sc_hd__o22ai_1 U1462 ( .A1(n10), .A2(n1035), .B1(n579), .B2(n1043), 
        .Y(s_mem_d[278]) );
  sky130_fd_sc_hd__inv_1 U1463 ( .A(s_mem_q[277]), .Y(n1036) );
  sky130_fd_sc_hd__o22ai_1 U1464 ( .A1(n10), .A2(n1036), .B1(n59), .B2(n1043), 
        .Y(s_mem_d[277]) );
  sky130_fd_sc_hd__inv_1 U1465 ( .A(s_mem_q[276]), .Y(n1037) );
  sky130_fd_sc_hd__o22ai_1 U1466 ( .A1(n10), .A2(n1037), .B1(n67), .B2(n1043), 
        .Y(s_mem_d[276]) );
  sky130_fd_sc_hd__inv_1 U1467 ( .A(s_mem_q[275]), .Y(n1038) );
  sky130_fd_sc_hd__o22ai_1 U1468 ( .A1(n10), .A2(n1038), .B1(n75), .B2(n1043), 
        .Y(s_mem_d[275]) );
  sky130_fd_sc_hd__inv_1 U1469 ( .A(s_mem_q[274]), .Y(n1039) );
  sky130_fd_sc_hd__o22ai_1 U1470 ( .A1(n10), .A2(n1039), .B1(n83), .B2(n1043), 
        .Y(s_mem_d[274]) );
  sky130_fd_sc_hd__inv_1 U1471 ( .A(s_mem_q[273]), .Y(n1040) );
  sky130_fd_sc_hd__o22ai_1 U1472 ( .A1(n10), .A2(n1040), .B1(n91), .B2(n1043), 
        .Y(s_mem_d[273]) );
  sky130_fd_sc_hd__inv_1 U1473 ( .A(s_mem_q[272]), .Y(n1041) );
  sky130_fd_sc_hd__o22ai_1 U1474 ( .A1(n10), .A2(n1041), .B1(n99), .B2(n1043), 
        .Y(s_mem_d[272]) );
  sky130_fd_sc_hd__inv_1 U1475 ( .A(s_mem_q[271]), .Y(n1042) );
  sky130_fd_sc_hd__o22ai_1 U1476 ( .A1(n10), .A2(n1042), .B1(n583), .B2(n1043), 
        .Y(s_mem_d[271]) );
  sky130_fd_sc_hd__inv_1 U1477 ( .A(s_mem_q[270]), .Y(n1044) );
  sky130_fd_sc_hd__o22ai_1 U1478 ( .A1(n10), .A2(n1044), .B1(n52), .B2(n1043), 
        .Y(s_mem_d[270]) );
  sky130_fd_sc_hd__inv_1 U1479 ( .A(s_mem_q[269]), .Y(n1046) );
  sky130_fd_sc_hd__o22ai_1 U1480 ( .A1(n32), .A2(n1046), .B1(n579), .B2(n1054), 
        .Y(s_mem_d[269]) );
  sky130_fd_sc_hd__inv_1 U1481 ( .A(s_mem_q[268]), .Y(n1047) );
  sky130_fd_sc_hd__o22ai_1 U1482 ( .A1(n32), .A2(n1047), .B1(n59), .B2(n1054), 
        .Y(s_mem_d[268]) );
  sky130_fd_sc_hd__inv_1 U1483 ( .A(s_mem_q[267]), .Y(n1048) );
  sky130_fd_sc_hd__o22ai_1 U1484 ( .A1(n32), .A2(n1048), .B1(n67), .B2(n1054), 
        .Y(s_mem_d[267]) );
  sky130_fd_sc_hd__inv_1 U1485 ( .A(s_mem_q[266]), .Y(n1049) );
  sky130_fd_sc_hd__o22ai_1 U1486 ( .A1(n32), .A2(n1049), .B1(n75), .B2(n1054), 
        .Y(s_mem_d[266]) );
  sky130_fd_sc_hd__inv_1 U1487 ( .A(s_mem_q[265]), .Y(n1050) );
  sky130_fd_sc_hd__o22ai_1 U1488 ( .A1(n32), .A2(n1050), .B1(n83), .B2(n1054), 
        .Y(s_mem_d[265]) );
  sky130_fd_sc_hd__inv_1 U1489 ( .A(s_mem_q[264]), .Y(n1051) );
  sky130_fd_sc_hd__o22ai_1 U1490 ( .A1(n32), .A2(n1051), .B1(n91), .B2(n1054), 
        .Y(s_mem_d[264]) );
  sky130_fd_sc_hd__inv_1 U1491 ( .A(s_mem_q[263]), .Y(n1052) );
  sky130_fd_sc_hd__o22ai_1 U1492 ( .A1(n32), .A2(n1052), .B1(n99), .B2(n1054), 
        .Y(s_mem_d[263]) );
  sky130_fd_sc_hd__inv_1 U1493 ( .A(s_mem_q[262]), .Y(n1053) );
  sky130_fd_sc_hd__o22ai_1 U1494 ( .A1(n32), .A2(n1053), .B1(n583), .B2(n1054), 
        .Y(s_mem_d[262]) );
  sky130_fd_sc_hd__inv_1 U1495 ( .A(s_mem_q[261]), .Y(n1055) );
  sky130_fd_sc_hd__o22ai_1 U1496 ( .A1(n32), .A2(n1055), .B1(n52), .B2(n1054), 
        .Y(s_mem_d[261]) );
  sky130_fd_sc_hd__inv_1 U1497 ( .A(s_mem_q[260]), .Y(n1057) );
  sky130_fd_sc_hd__o22ai_1 U1498 ( .A1(n26), .A2(n1057), .B1(n579), .B2(n1065), 
        .Y(s_mem_d[260]) );
  sky130_fd_sc_hd__inv_1 U1499 ( .A(s_mem_q[259]), .Y(n1058) );
  sky130_fd_sc_hd__o22ai_1 U1500 ( .A1(n26), .A2(n1058), .B1(n62), .B2(n1065), 
        .Y(s_mem_d[259]) );
  sky130_fd_sc_hd__inv_1 U1501 ( .A(s_mem_q[258]), .Y(n1059) );
  sky130_fd_sc_hd__o22ai_1 U1502 ( .A1(n26), .A2(n1059), .B1(n70), .B2(n1065), 
        .Y(s_mem_d[258]) );
  sky130_fd_sc_hd__inv_1 U1503 ( .A(s_mem_q[257]), .Y(n1060) );
  sky130_fd_sc_hd__o22ai_1 U1504 ( .A1(n26), .A2(n1060), .B1(n78), .B2(n1065), 
        .Y(s_mem_d[257]) );
  sky130_fd_sc_hd__inv_1 U1505 ( .A(s_mem_q[256]), .Y(n1061) );
  sky130_fd_sc_hd__o22ai_1 U1506 ( .A1(n26), .A2(n1061), .B1(n86), .B2(n1065), 
        .Y(s_mem_d[256]) );
  sky130_fd_sc_hd__inv_1 U1507 ( .A(s_mem_q[255]), .Y(n1062) );
  sky130_fd_sc_hd__o22ai_1 U1508 ( .A1(n26), .A2(n1062), .B1(n94), .B2(n1065), 
        .Y(s_mem_d[255]) );
  sky130_fd_sc_hd__inv_1 U1509 ( .A(s_mem_q[254]), .Y(n1063) );
  sky130_fd_sc_hd__o22ai_1 U1510 ( .A1(n26), .A2(n1063), .B1(n102), .B2(n1065), 
        .Y(s_mem_d[254]) );
  sky130_fd_sc_hd__inv_1 U1511 ( .A(s_mem_q[253]), .Y(n1064) );
  sky130_fd_sc_hd__o22ai_1 U1512 ( .A1(n26), .A2(n1064), .B1(n583), .B2(n1065), 
        .Y(s_mem_d[253]) );
  sky130_fd_sc_hd__inv_1 U1513 ( .A(s_mem_q[252]), .Y(n1066) );
  sky130_fd_sc_hd__o22ai_1 U1514 ( .A1(n26), .A2(n1066), .B1(n52), .B2(n1065), 
        .Y(s_mem_d[252]) );
  sky130_fd_sc_hd__nand2_1 U1515 ( .A(n1067), .B(n575), .Y(n1068) );
  sky130_fd_sc_hd__inv_1 U1516 ( .A(s_mem_q[251]), .Y(n1069) );
  sky130_fd_sc_hd__o22ai_1 U1517 ( .A1(n1079), .A2(n1069), .B1(n579), .B2(
        n1077), .Y(s_mem_d[251]) );
  sky130_fd_sc_hd__inv_1 U1518 ( .A(s_mem_q[250]), .Y(n1070) );
  sky130_fd_sc_hd__o22ai_1 U1519 ( .A1(n1079), .A2(n1070), .B1(n56), .B2(n1077), .Y(s_mem_d[250]) );
  sky130_fd_sc_hd__inv_1 U1520 ( .A(s_mem_q[249]), .Y(n1071) );
  sky130_fd_sc_hd__o22ai_1 U1521 ( .A1(n1079), .A2(n1071), .B1(n64), .B2(n1077), .Y(s_mem_d[249]) );
  sky130_fd_sc_hd__inv_1 U1522 ( .A(s_mem_q[248]), .Y(n1072) );
  sky130_fd_sc_hd__o22ai_1 U1523 ( .A1(n1079), .A2(n1072), .B1(n72), .B2(n1077), .Y(s_mem_d[248]) );
  sky130_fd_sc_hd__inv_1 U1524 ( .A(s_mem_q[247]), .Y(n1073) );
  sky130_fd_sc_hd__o22ai_1 U1525 ( .A1(n1079), .A2(n1073), .B1(n80), .B2(n1077), .Y(s_mem_d[247]) );
  sky130_fd_sc_hd__inv_1 U1526 ( .A(s_mem_q[246]), .Y(n1074) );
  sky130_fd_sc_hd__o22ai_1 U1527 ( .A1(n1079), .A2(n1074), .B1(n88), .B2(n1077), .Y(s_mem_d[246]) );
  sky130_fd_sc_hd__inv_1 U1528 ( .A(s_mem_q[245]), .Y(n1075) );
  sky130_fd_sc_hd__o22ai_1 U1529 ( .A1(n1079), .A2(n1075), .B1(n96), .B2(n1077), .Y(s_mem_d[245]) );
  sky130_fd_sc_hd__inv_1 U1530 ( .A(s_mem_q[244]), .Y(n1076) );
  sky130_fd_sc_hd__o22ai_1 U1531 ( .A1(n1079), .A2(n1076), .B1(n583), .B2(
        n1077), .Y(s_mem_d[244]) );
  sky130_fd_sc_hd__inv_1 U1532 ( .A(s_mem_q[243]), .Y(n1078) );
  sky130_fd_sc_hd__o22ai_1 U1533 ( .A1(n1079), .A2(n1078), .B1(n50), .B2(n1077), .Y(s_mem_d[243]) );
  sky130_fd_sc_hd__nand2_1 U1534 ( .A(n1080), .B(n575), .Y(n1081) );
  sky130_fd_sc_hd__inv_1 U1535 ( .A(s_mem_q[242]), .Y(n1082) );
  sky130_fd_sc_hd__o22ai_1 U1536 ( .A1(n1092), .A2(n1082), .B1(n579), .B2(
        n1090), .Y(s_mem_d[242]) );
  sky130_fd_sc_hd__inv_1 U1537 ( .A(s_mem_q[241]), .Y(n1083) );
  sky130_fd_sc_hd__o22ai_1 U1538 ( .A1(n1092), .A2(n1083), .B1(n57), .B2(n1090), .Y(s_mem_d[241]) );
  sky130_fd_sc_hd__inv_1 U1539 ( .A(s_mem_q[240]), .Y(n1084) );
  sky130_fd_sc_hd__o22ai_1 U1540 ( .A1(n1092), .A2(n1084), .B1(n65), .B2(n1090), .Y(s_mem_d[240]) );
  sky130_fd_sc_hd__inv_1 U1541 ( .A(s_mem_q[239]), .Y(n1085) );
  sky130_fd_sc_hd__o22ai_1 U1542 ( .A1(n1092), .A2(n1085), .B1(n73), .B2(n1090), .Y(s_mem_d[239]) );
  sky130_fd_sc_hd__inv_1 U1543 ( .A(s_mem_q[238]), .Y(n1086) );
  sky130_fd_sc_hd__o22ai_1 U1544 ( .A1(n1092), .A2(n1086), .B1(n81), .B2(n1090), .Y(s_mem_d[238]) );
  sky130_fd_sc_hd__inv_1 U1545 ( .A(s_mem_q[237]), .Y(n1087) );
  sky130_fd_sc_hd__o22ai_1 U1546 ( .A1(n1092), .A2(n1087), .B1(n89), .B2(n1090), .Y(s_mem_d[237]) );
  sky130_fd_sc_hd__inv_1 U1547 ( .A(s_mem_q[236]), .Y(n1088) );
  sky130_fd_sc_hd__o22ai_1 U1548 ( .A1(n1092), .A2(n1088), .B1(n97), .B2(n1090), .Y(s_mem_d[236]) );
  sky130_fd_sc_hd__inv_1 U1549 ( .A(s_mem_q[235]), .Y(n1089) );
  sky130_fd_sc_hd__o22ai_1 U1550 ( .A1(n1092), .A2(n1089), .B1(n583), .B2(
        n1090), .Y(s_mem_d[235]) );
  sky130_fd_sc_hd__inv_1 U1551 ( .A(s_mem_q[234]), .Y(n1091) );
  sky130_fd_sc_hd__o22ai_1 U1552 ( .A1(n1092), .A2(n1091), .B1(n50), .B2(n1090), .Y(s_mem_d[234]) );
  sky130_fd_sc_hd__nand2_1 U1553 ( .A(n1093), .B(n575), .Y(n1094) );
  sky130_fd_sc_hd__inv_1 U1554 ( .A(s_mem_q[233]), .Y(n1095) );
  sky130_fd_sc_hd__o22ai_1 U1555 ( .A1(n1105), .A2(n1095), .B1(n579), .B2(
        n1103), .Y(s_mem_d[233]) );
  sky130_fd_sc_hd__inv_1 U1556 ( .A(s_mem_q[232]), .Y(n1096) );
  sky130_fd_sc_hd__o22ai_1 U1557 ( .A1(n1105), .A2(n1096), .B1(n57), .B2(n1103), .Y(s_mem_d[232]) );
  sky130_fd_sc_hd__inv_1 U1558 ( .A(s_mem_q[231]), .Y(n1097) );
  sky130_fd_sc_hd__o22ai_1 U1559 ( .A1(n1105), .A2(n1097), .B1(n65), .B2(n1103), .Y(s_mem_d[231]) );
  sky130_fd_sc_hd__inv_1 U1560 ( .A(s_mem_q[230]), .Y(n1098) );
  sky130_fd_sc_hd__o22ai_1 U1561 ( .A1(n1105), .A2(n1098), .B1(n73), .B2(n1103), .Y(s_mem_d[230]) );
  sky130_fd_sc_hd__inv_1 U1562 ( .A(s_mem_q[229]), .Y(n1099) );
  sky130_fd_sc_hd__o22ai_1 U1563 ( .A1(n1105), .A2(n1099), .B1(n81), .B2(n1103), .Y(s_mem_d[229]) );
  sky130_fd_sc_hd__inv_1 U1564 ( .A(s_mem_q[228]), .Y(n1100) );
  sky130_fd_sc_hd__o22ai_1 U1565 ( .A1(n1105), .A2(n1100), .B1(n89), .B2(n1103), .Y(s_mem_d[228]) );
  sky130_fd_sc_hd__inv_1 U1566 ( .A(s_mem_q[227]), .Y(n1101) );
  sky130_fd_sc_hd__o22ai_1 U1567 ( .A1(n1105), .A2(n1101), .B1(n97), .B2(n1103), .Y(s_mem_d[227]) );
  sky130_fd_sc_hd__inv_1 U1568 ( .A(s_mem_q[226]), .Y(n1102) );
  sky130_fd_sc_hd__o22ai_1 U1569 ( .A1(n1105), .A2(n1102), .B1(n583), .B2(
        n1103), .Y(s_mem_d[226]) );
  sky130_fd_sc_hd__inv_1 U1570 ( .A(s_mem_q[225]), .Y(n1104) );
  sky130_fd_sc_hd__o22ai_1 U1571 ( .A1(n1105), .A2(n1104), .B1(n49), .B2(n1103), .Y(s_mem_d[225]) );
  sky130_fd_sc_hd__inv_1 U1572 ( .A(s_mem_q[224]), .Y(n1108) );
  sky130_fd_sc_hd__o22ai_1 U1573 ( .A1(n42), .A2(n1108), .B1(n580), .B2(n1116), 
        .Y(s_mem_d[224]) );
  sky130_fd_sc_hd__inv_1 U1574 ( .A(s_mem_q[223]), .Y(n1109) );
  sky130_fd_sc_hd__o22ai_1 U1575 ( .A1(n42), .A2(n1109), .B1(n56), .B2(n1116), 
        .Y(s_mem_d[223]) );
  sky130_fd_sc_hd__inv_1 U1576 ( .A(s_mem_q[222]), .Y(n1110) );
  sky130_fd_sc_hd__o22ai_1 U1577 ( .A1(n42), .A2(n1110), .B1(n64), .B2(n1116), 
        .Y(s_mem_d[222]) );
  sky130_fd_sc_hd__inv_1 U1578 ( .A(s_mem_q[221]), .Y(n1111) );
  sky130_fd_sc_hd__o22ai_1 U1579 ( .A1(n42), .A2(n1111), .B1(n72), .B2(n1116), 
        .Y(s_mem_d[221]) );
  sky130_fd_sc_hd__inv_1 U1580 ( .A(s_mem_q[220]), .Y(n1112) );
  sky130_fd_sc_hd__o22ai_1 U1581 ( .A1(n42), .A2(n1112), .B1(n80), .B2(n1116), 
        .Y(s_mem_d[220]) );
  sky130_fd_sc_hd__inv_1 U1582 ( .A(s_mem_q[219]), .Y(n1113) );
  sky130_fd_sc_hd__o22ai_1 U1583 ( .A1(n42), .A2(n1113), .B1(n88), .B2(n1116), 
        .Y(s_mem_d[219]) );
  sky130_fd_sc_hd__inv_1 U1584 ( .A(s_mem_q[218]), .Y(n1114) );
  sky130_fd_sc_hd__o22ai_1 U1585 ( .A1(n42), .A2(n1114), .B1(n96), .B2(n1116), 
        .Y(s_mem_d[218]) );
  sky130_fd_sc_hd__inv_1 U1586 ( .A(s_mem_q[217]), .Y(n1115) );
  sky130_fd_sc_hd__o22ai_1 U1587 ( .A1(n42), .A2(n1115), .B1(n583), .B2(n1116), 
        .Y(s_mem_d[217]) );
  sky130_fd_sc_hd__inv_1 U1588 ( .A(s_mem_q[216]), .Y(n1117) );
  sky130_fd_sc_hd__o22ai_1 U1589 ( .A1(n42), .A2(n1117), .B1(n50), .B2(n1116), 
        .Y(s_mem_d[216]) );
  sky130_fd_sc_hd__nand3_1 U1590 ( .A(s_wr_ptr_q[4]), .B(n1423), .C(n1425), 
        .Y(n1118) );
  sky130_fd_sc_hd__nand2_1 U1591 ( .A(n1119), .B(n575), .Y(n1120) );
  sky130_fd_sc_hd__inv_1 U1592 ( .A(s_mem_q[215]), .Y(n1121) );
  sky130_fd_sc_hd__o22ai_1 U1593 ( .A1(n1131), .A2(n1121), .B1(n580), .B2(
        n1129), .Y(s_mem_d[215]) );
  sky130_fd_sc_hd__inv_1 U1594 ( .A(s_mem_q[214]), .Y(n1122) );
  sky130_fd_sc_hd__o22ai_1 U1595 ( .A1(n1131), .A2(n1122), .B1(n57), .B2(n1129), .Y(s_mem_d[214]) );
  sky130_fd_sc_hd__inv_1 U1596 ( .A(s_mem_q[213]), .Y(n1123) );
  sky130_fd_sc_hd__o22ai_1 U1597 ( .A1(n1131), .A2(n1123), .B1(n65), .B2(n1129), .Y(s_mem_d[213]) );
  sky130_fd_sc_hd__inv_1 U1598 ( .A(s_mem_q[212]), .Y(n1124) );
  sky130_fd_sc_hd__o22ai_1 U1599 ( .A1(n1131), .A2(n1124), .B1(n73), .B2(n1129), .Y(s_mem_d[212]) );
  sky130_fd_sc_hd__inv_1 U1600 ( .A(s_mem_q[211]), .Y(n1125) );
  sky130_fd_sc_hd__o22ai_1 U1601 ( .A1(n1131), .A2(n1125), .B1(n81), .B2(n1129), .Y(s_mem_d[211]) );
  sky130_fd_sc_hd__inv_1 U1602 ( .A(s_mem_q[210]), .Y(n1126) );
  sky130_fd_sc_hd__o22ai_1 U1603 ( .A1(n1131), .A2(n1126), .B1(n89), .B2(n1129), .Y(s_mem_d[210]) );
  sky130_fd_sc_hd__inv_1 U1604 ( .A(s_mem_q[209]), .Y(n1127) );
  sky130_fd_sc_hd__o22ai_1 U1605 ( .A1(n1131), .A2(n1127), .B1(n97), .B2(n1129), .Y(s_mem_d[209]) );
  sky130_fd_sc_hd__inv_1 U1606 ( .A(s_mem_q[208]), .Y(n1128) );
  sky130_fd_sc_hd__o22ai_1 U1607 ( .A1(n1131), .A2(n1128), .B1(n583), .B2(
        n1129), .Y(s_mem_d[208]) );
  sky130_fd_sc_hd__inv_1 U1608 ( .A(s_mem_q[207]), .Y(n1130) );
  sky130_fd_sc_hd__o22ai_1 U1609 ( .A1(n1131), .A2(n1130), .B1(n50), .B2(n1129), .Y(s_mem_d[207]) );
  sky130_fd_sc_hd__inv_1 U1610 ( .A(s_mem_q[206]), .Y(n1133) );
  sky130_fd_sc_hd__o22ai_1 U1611 ( .A1(n24), .A2(n1133), .B1(n580), .B2(n1141), 
        .Y(s_mem_d[206]) );
  sky130_fd_sc_hd__inv_1 U1612 ( .A(s_mem_q[205]), .Y(n1134) );
  sky130_fd_sc_hd__o22ai_1 U1613 ( .A1(n24), .A2(n1134), .B1(n62), .B2(n1141), 
        .Y(s_mem_d[205]) );
  sky130_fd_sc_hd__inv_1 U1614 ( .A(s_mem_q[204]), .Y(n1135) );
  sky130_fd_sc_hd__o22ai_1 U1615 ( .A1(n24), .A2(n1135), .B1(n70), .B2(n1141), 
        .Y(s_mem_d[204]) );
  sky130_fd_sc_hd__inv_1 U1616 ( .A(s_mem_q[203]), .Y(n1136) );
  sky130_fd_sc_hd__o22ai_1 U1617 ( .A1(n24), .A2(n1136), .B1(n78), .B2(n1141), 
        .Y(s_mem_d[203]) );
  sky130_fd_sc_hd__inv_1 U1618 ( .A(s_mem_q[202]), .Y(n1137) );
  sky130_fd_sc_hd__o22ai_1 U1619 ( .A1(n24), .A2(n1137), .B1(n86), .B2(n1141), 
        .Y(s_mem_d[202]) );
  sky130_fd_sc_hd__inv_1 U1620 ( .A(s_mem_q[201]), .Y(n1138) );
  sky130_fd_sc_hd__o22ai_1 U1621 ( .A1(n24), .A2(n1138), .B1(n94), .B2(n1141), 
        .Y(s_mem_d[201]) );
  sky130_fd_sc_hd__inv_1 U1622 ( .A(s_mem_q[200]), .Y(n1139) );
  sky130_fd_sc_hd__o22ai_1 U1623 ( .A1(n24), .A2(n1139), .B1(n102), .B2(n1141), 
        .Y(s_mem_d[200]) );
  sky130_fd_sc_hd__inv_1 U1624 ( .A(s_mem_q[199]), .Y(n1140) );
  sky130_fd_sc_hd__o22ai_1 U1625 ( .A1(n24), .A2(n1140), .B1(n584), .B2(n1141), 
        .Y(s_mem_d[199]) );
  sky130_fd_sc_hd__inv_1 U1626 ( .A(s_mem_q[198]), .Y(n1142) );
  sky130_fd_sc_hd__o22ai_1 U1627 ( .A1(n24), .A2(n1142), .B1(n52), .B2(n1141), 
        .Y(s_mem_d[198]) );
  sky130_fd_sc_hd__inv_1 U1628 ( .A(s_mem_q[197]), .Y(n1144) );
  sky130_fd_sc_hd__o22ai_1 U1629 ( .A1(n34), .A2(n1144), .B1(n580), .B2(n1152), 
        .Y(s_mem_d[197]) );
  sky130_fd_sc_hd__inv_1 U1630 ( .A(s_mem_q[196]), .Y(n1145) );
  sky130_fd_sc_hd__o22ai_1 U1631 ( .A1(n34), .A2(n1145), .B1(n56), .B2(n1152), 
        .Y(s_mem_d[196]) );
  sky130_fd_sc_hd__inv_1 U1632 ( .A(s_mem_q[195]), .Y(n1146) );
  sky130_fd_sc_hd__o22ai_1 U1633 ( .A1(n34), .A2(n1146), .B1(n64), .B2(n1152), 
        .Y(s_mem_d[195]) );
  sky130_fd_sc_hd__inv_1 U1634 ( .A(s_mem_q[194]), .Y(n1147) );
  sky130_fd_sc_hd__o22ai_1 U1635 ( .A1(n34), .A2(n1147), .B1(n72), .B2(n1152), 
        .Y(s_mem_d[194]) );
  sky130_fd_sc_hd__inv_1 U1636 ( .A(s_mem_q[193]), .Y(n1148) );
  sky130_fd_sc_hd__o22ai_1 U1637 ( .A1(n34), .A2(n1148), .B1(n80), .B2(n1152), 
        .Y(s_mem_d[193]) );
  sky130_fd_sc_hd__inv_1 U1638 ( .A(s_mem_q[192]), .Y(n1149) );
  sky130_fd_sc_hd__o22ai_1 U1639 ( .A1(n34), .A2(n1149), .B1(n88), .B2(n1152), 
        .Y(s_mem_d[192]) );
  sky130_fd_sc_hd__inv_1 U1640 ( .A(s_mem_q[191]), .Y(n1150) );
  sky130_fd_sc_hd__o22ai_1 U1641 ( .A1(n34), .A2(n1150), .B1(n96), .B2(n1152), 
        .Y(s_mem_d[191]) );
  sky130_fd_sc_hd__inv_1 U1642 ( .A(s_mem_q[190]), .Y(n1151) );
  sky130_fd_sc_hd__o22ai_1 U1643 ( .A1(n34), .A2(n1151), .B1(n581), .B2(n1152), 
        .Y(s_mem_d[190]) );
  sky130_fd_sc_hd__inv_1 U1644 ( .A(s_mem_q[189]), .Y(n1153) );
  sky130_fd_sc_hd__o22ai_1 U1645 ( .A1(n34), .A2(n1153), .B1(n50), .B2(n1152), 
        .Y(s_mem_d[189]) );
  sky130_fd_sc_hd__inv_1 U1646 ( .A(s_mem_q[188]), .Y(n1155) );
  sky130_fd_sc_hd__o22ai_1 U1647 ( .A1(n29), .A2(n1155), .B1(n580), .B2(n1163), 
        .Y(s_mem_d[188]) );
  sky130_fd_sc_hd__inv_1 U1648 ( .A(s_mem_q[187]), .Y(n1156) );
  sky130_fd_sc_hd__o22ai_1 U1649 ( .A1(n29), .A2(n1156), .B1(n56), .B2(n1163), 
        .Y(s_mem_d[187]) );
  sky130_fd_sc_hd__inv_1 U1650 ( .A(s_mem_q[186]), .Y(n1157) );
  sky130_fd_sc_hd__o22ai_1 U1651 ( .A1(n29), .A2(n1157), .B1(n64), .B2(n1163), 
        .Y(s_mem_d[186]) );
  sky130_fd_sc_hd__inv_1 U1652 ( .A(s_mem_q[185]), .Y(n1158) );
  sky130_fd_sc_hd__o22ai_1 U1653 ( .A1(n29), .A2(n1158), .B1(n72), .B2(n1163), 
        .Y(s_mem_d[185]) );
  sky130_fd_sc_hd__inv_1 U1654 ( .A(s_mem_q[184]), .Y(n1159) );
  sky130_fd_sc_hd__o22ai_1 U1655 ( .A1(n29), .A2(n1159), .B1(n80), .B2(n1163), 
        .Y(s_mem_d[184]) );
  sky130_fd_sc_hd__inv_1 U1656 ( .A(s_mem_q[183]), .Y(n1160) );
  sky130_fd_sc_hd__o22ai_1 U1657 ( .A1(n29), .A2(n1160), .B1(n88), .B2(n1163), 
        .Y(s_mem_d[183]) );
  sky130_fd_sc_hd__inv_1 U1658 ( .A(s_mem_q[182]), .Y(n1161) );
  sky130_fd_sc_hd__o22ai_1 U1659 ( .A1(n29), .A2(n1161), .B1(n96), .B2(n1163), 
        .Y(s_mem_d[182]) );
  sky130_fd_sc_hd__inv_1 U1660 ( .A(s_mem_q[181]), .Y(n1162) );
  sky130_fd_sc_hd__o22ai_1 U1661 ( .A1(n29), .A2(n1162), .B1(n581), .B2(n1163), 
        .Y(s_mem_d[181]) );
  sky130_fd_sc_hd__inv_1 U1662 ( .A(s_mem_q[180]), .Y(n1164) );
  sky130_fd_sc_hd__o22ai_1 U1663 ( .A1(n29), .A2(n1164), .B1(n49), .B2(n1163), 
        .Y(s_mem_d[180]) );
  sky130_fd_sc_hd__nand2_1 U1664 ( .A(n1165), .B(n575), .Y(n1166) );
  sky130_fd_sc_hd__inv_1 U1665 ( .A(s_mem_q[179]), .Y(n1167) );
  sky130_fd_sc_hd__o22ai_1 U1666 ( .A1(n1177), .A2(n1167), .B1(n580), .B2(
        n1175), .Y(s_mem_d[179]) );
  sky130_fd_sc_hd__inv_1 U1667 ( .A(s_mem_q[178]), .Y(n1168) );
  sky130_fd_sc_hd__o22ai_1 U1668 ( .A1(n1177), .A2(n1168), .B1(n59), .B2(n1175), .Y(s_mem_d[178]) );
  sky130_fd_sc_hd__inv_1 U1669 ( .A(s_mem_q[177]), .Y(n1169) );
  sky130_fd_sc_hd__o22ai_1 U1670 ( .A1(n1177), .A2(n1169), .B1(n67), .B2(n1175), .Y(s_mem_d[177]) );
  sky130_fd_sc_hd__inv_1 U1671 ( .A(s_mem_q[176]), .Y(n1170) );
  sky130_fd_sc_hd__o22ai_1 U1672 ( .A1(n1177), .A2(n1170), .B1(n75), .B2(n1175), .Y(s_mem_d[176]) );
  sky130_fd_sc_hd__inv_1 U1673 ( .A(s_mem_q[175]), .Y(n1171) );
  sky130_fd_sc_hd__o22ai_1 U1674 ( .A1(n1177), .A2(n1171), .B1(n83), .B2(n1175), .Y(s_mem_d[175]) );
  sky130_fd_sc_hd__inv_1 U1675 ( .A(s_mem_q[174]), .Y(n1172) );
  sky130_fd_sc_hd__o22ai_1 U1676 ( .A1(n1177), .A2(n1172), .B1(n91), .B2(n1175), .Y(s_mem_d[174]) );
  sky130_fd_sc_hd__inv_1 U1677 ( .A(s_mem_q[173]), .Y(n1173) );
  sky130_fd_sc_hd__o22ai_1 U1678 ( .A1(n1177), .A2(n1173), .B1(n99), .B2(n1175), .Y(s_mem_d[173]) );
  sky130_fd_sc_hd__inv_1 U1679 ( .A(s_mem_q[172]), .Y(n1174) );
  sky130_fd_sc_hd__o22ai_1 U1680 ( .A1(n1177), .A2(n1174), .B1(n584), .B2(
        n1175), .Y(s_mem_d[172]) );
  sky130_fd_sc_hd__inv_1 U1681 ( .A(s_mem_q[171]), .Y(n1176) );
  sky130_fd_sc_hd__o22ai_1 U1682 ( .A1(n1177), .A2(n1176), .B1(n52), .B2(n1175), .Y(s_mem_d[171]) );
  sky130_fd_sc_hd__inv_1 U1683 ( .A(s_mem_q[170]), .Y(n1179) );
  sky130_fd_sc_hd__o22ai_1 U1684 ( .A1(n38), .A2(n1179), .B1(n580), .B2(n1187), 
        .Y(s_mem_d[170]) );
  sky130_fd_sc_hd__inv_1 U1685 ( .A(s_mem_q[169]), .Y(n1180) );
  sky130_fd_sc_hd__o22ai_1 U1686 ( .A1(n38), .A2(n1180), .B1(n62), .B2(n1187), 
        .Y(s_mem_d[169]) );
  sky130_fd_sc_hd__inv_1 U1687 ( .A(s_mem_q[168]), .Y(n1181) );
  sky130_fd_sc_hd__o22ai_1 U1688 ( .A1(n38), .A2(n1181), .B1(n70), .B2(n1187), 
        .Y(s_mem_d[168]) );
  sky130_fd_sc_hd__inv_1 U1689 ( .A(s_mem_q[167]), .Y(n1182) );
  sky130_fd_sc_hd__o22ai_1 U1690 ( .A1(n38), .A2(n1182), .B1(n78), .B2(n1187), 
        .Y(s_mem_d[167]) );
  sky130_fd_sc_hd__inv_1 U1691 ( .A(s_mem_q[166]), .Y(n1183) );
  sky130_fd_sc_hd__o22ai_1 U1692 ( .A1(n38), .A2(n1183), .B1(n86), .B2(n1187), 
        .Y(s_mem_d[166]) );
  sky130_fd_sc_hd__inv_1 U1693 ( .A(s_mem_q[165]), .Y(n1184) );
  sky130_fd_sc_hd__o22ai_1 U1694 ( .A1(n38), .A2(n1184), .B1(n94), .B2(n1187), 
        .Y(s_mem_d[165]) );
  sky130_fd_sc_hd__inv_1 U1695 ( .A(s_mem_q[164]), .Y(n1185) );
  sky130_fd_sc_hd__o22ai_1 U1696 ( .A1(n38), .A2(n1185), .B1(n102), .B2(n1187), 
        .Y(s_mem_d[164]) );
  sky130_fd_sc_hd__inv_1 U1697 ( .A(s_mem_q[163]), .Y(n1186) );
  sky130_fd_sc_hd__o22ai_1 U1698 ( .A1(n38), .A2(n1186), .B1(n584), .B2(n1187), 
        .Y(s_mem_d[163]) );
  sky130_fd_sc_hd__inv_1 U1699 ( .A(s_mem_q[162]), .Y(n1188) );
  sky130_fd_sc_hd__o22ai_1 U1700 ( .A1(n38), .A2(n1188), .B1(n53), .B2(n1187), 
        .Y(s_mem_d[162]) );
  sky130_fd_sc_hd__inv_1 U1701 ( .A(s_mem_q[161]), .Y(n1190) );
  sky130_fd_sc_hd__o22ai_1 U1702 ( .A1(n39), .A2(n1190), .B1(n580), .B2(n1198), 
        .Y(s_mem_d[161]) );
  sky130_fd_sc_hd__inv_1 U1703 ( .A(s_mem_q[160]), .Y(n1191) );
  sky130_fd_sc_hd__o22ai_1 U1704 ( .A1(n39), .A2(n1191), .B1(n61), .B2(n1198), 
        .Y(s_mem_d[160]) );
  sky130_fd_sc_hd__inv_1 U1705 ( .A(s_mem_q[159]), .Y(n1192) );
  sky130_fd_sc_hd__o22ai_1 U1706 ( .A1(n39), .A2(n1192), .B1(n69), .B2(n1198), 
        .Y(s_mem_d[159]) );
  sky130_fd_sc_hd__inv_1 U1707 ( .A(s_mem_q[158]), .Y(n1193) );
  sky130_fd_sc_hd__o22ai_1 U1708 ( .A1(n39), .A2(n1193), .B1(n77), .B2(n1198), 
        .Y(s_mem_d[158]) );
  sky130_fd_sc_hd__inv_1 U1709 ( .A(s_mem_q[157]), .Y(n1194) );
  sky130_fd_sc_hd__o22ai_1 U1710 ( .A1(n39), .A2(n1194), .B1(n85), .B2(n1198), 
        .Y(s_mem_d[157]) );
  sky130_fd_sc_hd__inv_1 U1711 ( .A(s_mem_q[156]), .Y(n1195) );
  sky130_fd_sc_hd__o22ai_1 U1712 ( .A1(n39), .A2(n1195), .B1(n93), .B2(n1198), 
        .Y(s_mem_d[156]) );
  sky130_fd_sc_hd__inv_1 U1713 ( .A(s_mem_q[155]), .Y(n1196) );
  sky130_fd_sc_hd__o22ai_1 U1714 ( .A1(n39), .A2(n1196), .B1(n101), .B2(n1198), 
        .Y(s_mem_d[155]) );
  sky130_fd_sc_hd__inv_1 U1715 ( .A(s_mem_q[154]), .Y(n1197) );
  sky130_fd_sc_hd__o22ai_1 U1716 ( .A1(n39), .A2(n1197), .B1(n581), .B2(n1198), 
        .Y(s_mem_d[154]) );
  sky130_fd_sc_hd__inv_1 U1717 ( .A(s_mem_q[153]), .Y(n1199) );
  sky130_fd_sc_hd__o22ai_1 U1718 ( .A1(n39), .A2(n1199), .B1(n49), .B2(n1198), 
        .Y(s_mem_d[153]) );
  sky130_fd_sc_hd__nand2_1 U1719 ( .A(n1201), .B(n575), .Y(n1202) );
  sky130_fd_sc_hd__inv_1 U1720 ( .A(s_mem_q[152]), .Y(n1203) );
  sky130_fd_sc_hd__o22ai_1 U1721 ( .A1(n1213), .A2(n1203), .B1(n580), .B2(
        n1211), .Y(s_mem_d[152]) );
  sky130_fd_sc_hd__inv_1 U1722 ( .A(s_mem_q[151]), .Y(n1204) );
  sky130_fd_sc_hd__o22ai_1 U1723 ( .A1(n1213), .A2(n1204), .B1(n60), .B2(n1211), .Y(s_mem_d[151]) );
  sky130_fd_sc_hd__inv_1 U1724 ( .A(s_mem_q[150]), .Y(n1205) );
  sky130_fd_sc_hd__o22ai_1 U1725 ( .A1(n1213), .A2(n1205), .B1(n68), .B2(n1211), .Y(s_mem_d[150]) );
  sky130_fd_sc_hd__inv_1 U1726 ( .A(s_mem_q[149]), .Y(n1206) );
  sky130_fd_sc_hd__o22ai_1 U1727 ( .A1(n1213), .A2(n1206), .B1(n76), .B2(n1211), .Y(s_mem_d[149]) );
  sky130_fd_sc_hd__inv_1 U1728 ( .A(s_mem_q[148]), .Y(n1207) );
  sky130_fd_sc_hd__o22ai_1 U1729 ( .A1(n1213), .A2(n1207), .B1(n84), .B2(n1211), .Y(s_mem_d[148]) );
  sky130_fd_sc_hd__inv_1 U1730 ( .A(s_mem_q[147]), .Y(n1208) );
  sky130_fd_sc_hd__o22ai_1 U1731 ( .A1(n1213), .A2(n1208), .B1(n92), .B2(n1211), .Y(s_mem_d[147]) );
  sky130_fd_sc_hd__inv_1 U1732 ( .A(s_mem_q[146]), .Y(n1209) );
  sky130_fd_sc_hd__o22ai_1 U1733 ( .A1(n1213), .A2(n1209), .B1(n100), .B2(
        n1211), .Y(s_mem_d[146]) );
  sky130_fd_sc_hd__inv_1 U1734 ( .A(s_mem_q[145]), .Y(n1210) );
  sky130_fd_sc_hd__o22ai_1 U1735 ( .A1(n1213), .A2(n1210), .B1(n581), .B2(
        n1211), .Y(s_mem_d[145]) );
  sky130_fd_sc_hd__inv_1 U1736 ( .A(s_mem_q[144]), .Y(n1212) );
  sky130_fd_sc_hd__o22ai_1 U1737 ( .A1(n1213), .A2(n1212), .B1(n53), .B2(n1211), .Y(s_mem_d[144]) );
  sky130_fd_sc_hd__nand3_1 U1738 ( .A(s_wr_ptr_q[3]), .B(n1423), .C(n1424), 
        .Y(n1214) );
  sky130_fd_sc_hd__clkinv_2 U1739 ( .A(n1214), .Y(n1300) );
  sky130_fd_sc_hd__nand2_1 U1740 ( .A(n1215), .B(n576), .Y(n1216) );
  sky130_fd_sc_hd__inv_1 U1741 ( .A(s_mem_q[143]), .Y(n1217) );
  sky130_fd_sc_hd__o22ai_1 U1742 ( .A1(n1227), .A2(n1217), .B1(n580), .B2(
        n1225), .Y(s_mem_d[143]) );
  sky130_fd_sc_hd__inv_1 U1743 ( .A(s_mem_q[142]), .Y(n1218) );
  sky130_fd_sc_hd__o22ai_1 U1744 ( .A1(n1227), .A2(n1218), .B1(n60), .B2(n1225), .Y(s_mem_d[142]) );
  sky130_fd_sc_hd__inv_1 U1745 ( .A(s_mem_q[141]), .Y(n1219) );
  sky130_fd_sc_hd__o22ai_1 U1746 ( .A1(n1227), .A2(n1219), .B1(n68), .B2(n1225), .Y(s_mem_d[141]) );
  sky130_fd_sc_hd__inv_1 U1747 ( .A(s_mem_q[140]), .Y(n1220) );
  sky130_fd_sc_hd__o22ai_1 U1748 ( .A1(n1227), .A2(n1220), .B1(n76), .B2(n1225), .Y(s_mem_d[140]) );
  sky130_fd_sc_hd__inv_1 U1749 ( .A(s_mem_q[139]), .Y(n1221) );
  sky130_fd_sc_hd__o22ai_1 U1750 ( .A1(n1227), .A2(n1221), .B1(n84), .B2(n1225), .Y(s_mem_d[139]) );
  sky130_fd_sc_hd__inv_1 U1751 ( .A(s_mem_q[138]), .Y(n1222) );
  sky130_fd_sc_hd__o22ai_1 U1752 ( .A1(n1227), .A2(n1222), .B1(n92), .B2(n1225), .Y(s_mem_d[138]) );
  sky130_fd_sc_hd__inv_1 U1753 ( .A(s_mem_q[137]), .Y(n1223) );
  sky130_fd_sc_hd__o22ai_1 U1754 ( .A1(n1227), .A2(n1223), .B1(n100), .B2(
        n1225), .Y(s_mem_d[137]) );
  sky130_fd_sc_hd__inv_1 U1755 ( .A(s_mem_q[136]), .Y(n1224) );
  sky130_fd_sc_hd__o22ai_1 U1756 ( .A1(n1227), .A2(n1224), .B1(n583), .B2(
        n1225), .Y(s_mem_d[136]) );
  sky130_fd_sc_hd__inv_1 U1757 ( .A(s_mem_q[135]), .Y(n1226) );
  sky130_fd_sc_hd__o22ai_1 U1758 ( .A1(n1227), .A2(n1226), .B1(n53), .B2(n1225), .Y(s_mem_d[135]) );
  sky130_fd_sc_hd__inv_1 U1759 ( .A(s_mem_q[134]), .Y(n1229) );
  sky130_fd_sc_hd__o22ai_1 U1760 ( .A1(n22), .A2(n1229), .B1(n580), .B2(n1237), 
        .Y(s_mem_d[134]) );
  sky130_fd_sc_hd__inv_1 U1761 ( .A(s_mem_q[133]), .Y(n1230) );
  sky130_fd_sc_hd__o22ai_1 U1762 ( .A1(n22), .A2(n1230), .B1(n59), .B2(n1237), 
        .Y(s_mem_d[133]) );
  sky130_fd_sc_hd__inv_1 U1763 ( .A(s_mem_q[132]), .Y(n1231) );
  sky130_fd_sc_hd__o22ai_1 U1764 ( .A1(n22), .A2(n1231), .B1(n67), .B2(n1237), 
        .Y(s_mem_d[132]) );
  sky130_fd_sc_hd__inv_1 U1765 ( .A(s_mem_q[131]), .Y(n1232) );
  sky130_fd_sc_hd__o22ai_1 U1766 ( .A1(n22), .A2(n1232), .B1(n75), .B2(n1237), 
        .Y(s_mem_d[131]) );
  sky130_fd_sc_hd__inv_1 U1767 ( .A(s_mem_q[130]), .Y(n1233) );
  sky130_fd_sc_hd__o22ai_1 U1768 ( .A1(n22), .A2(n1233), .B1(n83), .B2(n1237), 
        .Y(s_mem_d[130]) );
  sky130_fd_sc_hd__inv_1 U1769 ( .A(s_mem_q[129]), .Y(n1234) );
  sky130_fd_sc_hd__o22ai_1 U1770 ( .A1(n22), .A2(n1234), .B1(n91), .B2(n1237), 
        .Y(s_mem_d[129]) );
  sky130_fd_sc_hd__inv_1 U1771 ( .A(s_mem_q[128]), .Y(n1235) );
  sky130_fd_sc_hd__o22ai_1 U1772 ( .A1(n22), .A2(n1235), .B1(n99), .B2(n1237), 
        .Y(s_mem_d[128]) );
  sky130_fd_sc_hd__inv_1 U1773 ( .A(s_mem_q[127]), .Y(n1236) );
  sky130_fd_sc_hd__o22ai_1 U1774 ( .A1(n22), .A2(n1236), .B1(n584), .B2(n1237), 
        .Y(s_mem_d[127]) );
  sky130_fd_sc_hd__inv_1 U1775 ( .A(s_mem_q[126]), .Y(n1238) );
  sky130_fd_sc_hd__o22ai_1 U1776 ( .A1(n22), .A2(n1238), .B1(n52), .B2(n1237), 
        .Y(s_mem_d[126]) );
  sky130_fd_sc_hd__inv_1 U1777 ( .A(s_mem_q[125]), .Y(n1240) );
  sky130_fd_sc_hd__o22ai_1 U1778 ( .A1(n31), .A2(n1240), .B1(n580), .B2(n1248), 
        .Y(s_mem_d[125]) );
  sky130_fd_sc_hd__inv_1 U1779 ( .A(s_mem_q[124]), .Y(n1241) );
  sky130_fd_sc_hd__o22ai_1 U1780 ( .A1(n31), .A2(n1241), .B1(n60), .B2(n1248), 
        .Y(s_mem_d[124]) );
  sky130_fd_sc_hd__inv_1 U1781 ( .A(s_mem_q[123]), .Y(n1242) );
  sky130_fd_sc_hd__o22ai_1 U1782 ( .A1(n31), .A2(n1242), .B1(n68), .B2(n1248), 
        .Y(s_mem_d[123]) );
  sky130_fd_sc_hd__inv_1 U1783 ( .A(s_mem_q[122]), .Y(n1243) );
  sky130_fd_sc_hd__o22ai_1 U1784 ( .A1(n31), .A2(n1243), .B1(n76), .B2(n1248), 
        .Y(s_mem_d[122]) );
  sky130_fd_sc_hd__inv_1 U1785 ( .A(s_mem_q[121]), .Y(n1244) );
  sky130_fd_sc_hd__o22ai_1 U1786 ( .A1(n31), .A2(n1244), .B1(n84), .B2(n1248), 
        .Y(s_mem_d[121]) );
  sky130_fd_sc_hd__inv_1 U1787 ( .A(s_mem_q[120]), .Y(n1245) );
  sky130_fd_sc_hd__o22ai_1 U1788 ( .A1(n31), .A2(n1245), .B1(n92), .B2(n1248), 
        .Y(s_mem_d[120]) );
  sky130_fd_sc_hd__inv_1 U1789 ( .A(s_mem_q[119]), .Y(n1246) );
  sky130_fd_sc_hd__o22ai_1 U1790 ( .A1(n31), .A2(n1246), .B1(n100), .B2(n1248), 
        .Y(s_mem_d[119]) );
  sky130_fd_sc_hd__inv_1 U1791 ( .A(s_mem_q[118]), .Y(n1247) );
  sky130_fd_sc_hd__o22ai_1 U1792 ( .A1(n31), .A2(n1247), .B1(n583), .B2(n1248), 
        .Y(s_mem_d[118]) );
  sky130_fd_sc_hd__inv_1 U1793 ( .A(s_mem_q[117]), .Y(n1249) );
  sky130_fd_sc_hd__o22ai_1 U1794 ( .A1(n31), .A2(n1249), .B1(n53), .B2(n1248), 
        .Y(s_mem_d[117]) );
  sky130_fd_sc_hd__inv_1 U1795 ( .A(s_mem_q[116]), .Y(n1251) );
  sky130_fd_sc_hd__o22ai_1 U1796 ( .A1(n25), .A2(n1251), .B1(n580), .B2(n1259), 
        .Y(s_mem_d[116]) );
  sky130_fd_sc_hd__inv_1 U1797 ( .A(s_mem_q[115]), .Y(n1252) );
  sky130_fd_sc_hd__o22ai_1 U1798 ( .A1(n25), .A2(n1252), .B1(n61), .B2(n1259), 
        .Y(s_mem_d[115]) );
  sky130_fd_sc_hd__inv_1 U1799 ( .A(s_mem_q[114]), .Y(n1253) );
  sky130_fd_sc_hd__o22ai_1 U1800 ( .A1(n25), .A2(n1253), .B1(n69), .B2(n1259), 
        .Y(s_mem_d[114]) );
  sky130_fd_sc_hd__inv_1 U1801 ( .A(s_mem_q[113]), .Y(n1254) );
  sky130_fd_sc_hd__o22ai_1 U1802 ( .A1(n25), .A2(n1254), .B1(n77), .B2(n1259), 
        .Y(s_mem_d[113]) );
  sky130_fd_sc_hd__inv_1 U1803 ( .A(s_mem_q[112]), .Y(n1255) );
  sky130_fd_sc_hd__o22ai_1 U1804 ( .A1(n25), .A2(n1255), .B1(n85), .B2(n1259), 
        .Y(s_mem_d[112]) );
  sky130_fd_sc_hd__inv_1 U1805 ( .A(s_mem_q[111]), .Y(n1256) );
  sky130_fd_sc_hd__o22ai_1 U1806 ( .A1(n25), .A2(n1256), .B1(n93), .B2(n1259), 
        .Y(s_mem_d[111]) );
  sky130_fd_sc_hd__inv_1 U1807 ( .A(s_mem_q[110]), .Y(n1257) );
  sky130_fd_sc_hd__o22ai_1 U1808 ( .A1(n25), .A2(n1257), .B1(n101), .B2(n1259), 
        .Y(s_mem_d[110]) );
  sky130_fd_sc_hd__inv_1 U1809 ( .A(s_mem_q[109]), .Y(n1258) );
  sky130_fd_sc_hd__o22ai_1 U1810 ( .A1(n25), .A2(n1258), .B1(n583), .B2(n1259), 
        .Y(s_mem_d[109]) );
  sky130_fd_sc_hd__inv_1 U1811 ( .A(s_mem_q[108]), .Y(n1260) );
  sky130_fd_sc_hd__o22ai_1 U1812 ( .A1(n25), .A2(n1260), .B1(n53), .B2(n1259), 
        .Y(s_mem_d[108]) );
  sky130_fd_sc_hd__nand2_1 U1813 ( .A(n1261), .B(n576), .Y(n1262) );
  sky130_fd_sc_hd__inv_1 U1814 ( .A(s_mem_q[107]), .Y(n1263) );
  sky130_fd_sc_hd__o22ai_1 U1815 ( .A1(n1273), .A2(n1263), .B1(n579), .B2(
        n1271), .Y(s_mem_d[107]) );
  sky130_fd_sc_hd__inv_1 U1816 ( .A(s_mem_q[106]), .Y(n1264) );
  sky130_fd_sc_hd__o22ai_1 U1817 ( .A1(n1273), .A2(n1264), .B1(n58), .B2(n1271), .Y(s_mem_d[106]) );
  sky130_fd_sc_hd__inv_1 U1818 ( .A(s_mem_q[105]), .Y(n1265) );
  sky130_fd_sc_hd__o22ai_1 U1819 ( .A1(n1273), .A2(n1265), .B1(n66), .B2(n1271), .Y(s_mem_d[105]) );
  sky130_fd_sc_hd__inv_1 U1820 ( .A(s_mem_q[104]), .Y(n1266) );
  sky130_fd_sc_hd__o22ai_1 U1821 ( .A1(n1273), .A2(n1266), .B1(n74), .B2(n1271), .Y(s_mem_d[104]) );
  sky130_fd_sc_hd__inv_1 U1822 ( .A(s_mem_q[103]), .Y(n1267) );
  sky130_fd_sc_hd__o22ai_1 U1823 ( .A1(n1273), .A2(n1267), .B1(n82), .B2(n1271), .Y(s_mem_d[103]) );
  sky130_fd_sc_hd__inv_1 U1824 ( .A(s_mem_q[102]), .Y(n1268) );
  sky130_fd_sc_hd__o22ai_1 U1825 ( .A1(n1273), .A2(n1268), .B1(n90), .B2(n1271), .Y(s_mem_d[102]) );
  sky130_fd_sc_hd__inv_1 U1826 ( .A(s_mem_q[101]), .Y(n1269) );
  sky130_fd_sc_hd__o22ai_1 U1827 ( .A1(n1273), .A2(n1269), .B1(n98), .B2(n1271), .Y(s_mem_d[101]) );
  sky130_fd_sc_hd__inv_1 U1828 ( .A(s_mem_q[100]), .Y(n1270) );
  sky130_fd_sc_hd__o22ai_1 U1829 ( .A1(n1273), .A2(n1270), .B1(n584), .B2(
        n1271), .Y(s_mem_d[100]) );
  sky130_fd_sc_hd__inv_1 U1830 ( .A(s_mem_q[99]), .Y(n1272) );
  sky130_fd_sc_hd__o22ai_1 U1831 ( .A1(n1273), .A2(n1272), .B1(n51), .B2(n1271), .Y(s_mem_d[99]) );
  sky130_fd_sc_hd__nand2_1 U1832 ( .A(n1274), .B(n576), .Y(n1275) );
  sky130_fd_sc_hd__inv_1 U1833 ( .A(s_mem_q[98]), .Y(n1276) );
  sky130_fd_sc_hd__o22ai_1 U1834 ( .A1(n1286), .A2(n1276), .B1(n578), .B2(
        n1284), .Y(s_mem_d[98]) );
  sky130_fd_sc_hd__inv_1 U1835 ( .A(s_mem_q[97]), .Y(n1277) );
  sky130_fd_sc_hd__o22ai_1 U1836 ( .A1(n1286), .A2(n1277), .B1(n62), .B2(n1284), .Y(s_mem_d[97]) );
  sky130_fd_sc_hd__inv_1 U1837 ( .A(s_mem_q[96]), .Y(n1278) );
  sky130_fd_sc_hd__o22ai_1 U1838 ( .A1(n1286), .A2(n1278), .B1(n70), .B2(n1284), .Y(s_mem_d[96]) );
  sky130_fd_sc_hd__inv_1 U1839 ( .A(s_mem_q[95]), .Y(n1279) );
  sky130_fd_sc_hd__o22ai_1 U1840 ( .A1(n1286), .A2(n1279), .B1(n78), .B2(n1284), .Y(s_mem_d[95]) );
  sky130_fd_sc_hd__inv_1 U1841 ( .A(s_mem_q[94]), .Y(n1280) );
  sky130_fd_sc_hd__o22ai_1 U1842 ( .A1(n1286), .A2(n1280), .B1(n86), .B2(n1284), .Y(s_mem_d[94]) );
  sky130_fd_sc_hd__inv_1 U1843 ( .A(s_mem_q[93]), .Y(n1281) );
  sky130_fd_sc_hd__o22ai_1 U1844 ( .A1(n1286), .A2(n1281), .B1(n94), .B2(n1284), .Y(s_mem_d[93]) );
  sky130_fd_sc_hd__inv_1 U1845 ( .A(s_mem_q[92]), .Y(n1282) );
  sky130_fd_sc_hd__o22ai_1 U1846 ( .A1(n1286), .A2(n1282), .B1(n102), .B2(
        n1284), .Y(s_mem_d[92]) );
  sky130_fd_sc_hd__inv_1 U1847 ( .A(s_mem_q[91]), .Y(n1283) );
  sky130_fd_sc_hd__o22ai_1 U1848 ( .A1(n1286), .A2(n1283), .B1(n584), .B2(
        n1284), .Y(s_mem_d[91]) );
  sky130_fd_sc_hd__inv_1 U1849 ( .A(s_mem_q[90]), .Y(n1285) );
  sky130_fd_sc_hd__o22ai_1 U1850 ( .A1(n1286), .A2(n1285), .B1(n52), .B2(n1284), .Y(s_mem_d[90]) );
  sky130_fd_sc_hd__nand2_1 U1851 ( .A(n1287), .B(n575), .Y(n1288) );
  sky130_fd_sc_hd__inv_1 U1852 ( .A(s_mem_q[89]), .Y(n1289) );
  sky130_fd_sc_hd__o22ai_1 U1853 ( .A1(n1299), .A2(n1289), .B1(n577), .B2(
        n1297), .Y(s_mem_d[89]) );
  sky130_fd_sc_hd__inv_1 U1854 ( .A(s_mem_q[88]), .Y(n1290) );
  sky130_fd_sc_hd__o22ai_1 U1855 ( .A1(n1299), .A2(n1290), .B1(n59), .B2(n1297), .Y(s_mem_d[88]) );
  sky130_fd_sc_hd__inv_1 U1856 ( .A(s_mem_q[87]), .Y(n1291) );
  sky130_fd_sc_hd__o22ai_1 U1857 ( .A1(n1299), .A2(n1291), .B1(n67), .B2(n1297), .Y(s_mem_d[87]) );
  sky130_fd_sc_hd__inv_1 U1858 ( .A(s_mem_q[86]), .Y(n1292) );
  sky130_fd_sc_hd__o22ai_1 U1859 ( .A1(n1299), .A2(n1292), .B1(n75), .B2(n1297), .Y(s_mem_d[86]) );
  sky130_fd_sc_hd__inv_1 U1860 ( .A(s_mem_q[85]), .Y(n1293) );
  sky130_fd_sc_hd__o22ai_1 U1861 ( .A1(n1299), .A2(n1293), .B1(n83), .B2(n1297), .Y(s_mem_d[85]) );
  sky130_fd_sc_hd__inv_1 U1862 ( .A(s_mem_q[84]), .Y(n1294) );
  sky130_fd_sc_hd__o22ai_1 U1863 ( .A1(n1299), .A2(n1294), .B1(n91), .B2(n1297), .Y(s_mem_d[84]) );
  sky130_fd_sc_hd__inv_1 U1864 ( .A(s_mem_q[83]), .Y(n1295) );
  sky130_fd_sc_hd__o22ai_1 U1865 ( .A1(n1299), .A2(n1295), .B1(n99), .B2(n1297), .Y(s_mem_d[83]) );
  sky130_fd_sc_hd__inv_1 U1866 ( .A(s_mem_q[82]), .Y(n1296) );
  sky130_fd_sc_hd__o22ai_1 U1867 ( .A1(n1299), .A2(n1296), .B1(n584), .B2(
        n1297), .Y(s_mem_d[82]) );
  sky130_fd_sc_hd__inv_1 U1868 ( .A(s_mem_q[81]), .Y(n1298) );
  sky130_fd_sc_hd__o22ai_1 U1869 ( .A1(n1299), .A2(n1298), .B1(n52), .B2(n1297), .Y(s_mem_d[81]) );
  sky130_fd_sc_hd__nand2_1 U1870 ( .A(n1301), .B(n575), .Y(n1302) );
  sky130_fd_sc_hd__inv_1 U1871 ( .A(s_mem_q[80]), .Y(n1303) );
  sky130_fd_sc_hd__o22ai_1 U1872 ( .A1(n1313), .A2(n1303), .B1(n579), .B2(
        n1311), .Y(s_mem_d[80]) );
  sky130_fd_sc_hd__inv_1 U1873 ( .A(s_mem_q[79]), .Y(n1304) );
  sky130_fd_sc_hd__o22ai_1 U1874 ( .A1(n1313), .A2(n1304), .B1(n57), .B2(n1311), .Y(s_mem_d[79]) );
  sky130_fd_sc_hd__inv_1 U1875 ( .A(s_mem_q[78]), .Y(n1305) );
  sky130_fd_sc_hd__o22ai_1 U1876 ( .A1(n1313), .A2(n1305), .B1(n65), .B2(n1311), .Y(s_mem_d[78]) );
  sky130_fd_sc_hd__inv_1 U1877 ( .A(s_mem_q[77]), .Y(n1306) );
  sky130_fd_sc_hd__o22ai_1 U1878 ( .A1(n1313), .A2(n1306), .B1(n73), .B2(n1311), .Y(s_mem_d[77]) );
  sky130_fd_sc_hd__inv_1 U1879 ( .A(s_mem_q[76]), .Y(n1307) );
  sky130_fd_sc_hd__o22ai_1 U1880 ( .A1(n1313), .A2(n1307), .B1(n81), .B2(n1311), .Y(s_mem_d[76]) );
  sky130_fd_sc_hd__inv_1 U1881 ( .A(s_mem_q[75]), .Y(n1308) );
  sky130_fd_sc_hd__o22ai_1 U1882 ( .A1(n1313), .A2(n1308), .B1(n89), .B2(n1311), .Y(s_mem_d[75]) );
  sky130_fd_sc_hd__inv_1 U1883 ( .A(s_mem_q[74]), .Y(n1309) );
  sky130_fd_sc_hd__o22ai_1 U1884 ( .A1(n1313), .A2(n1309), .B1(n97), .B2(n1311), .Y(s_mem_d[74]) );
  sky130_fd_sc_hd__inv_1 U1885 ( .A(s_mem_q[73]), .Y(n1310) );
  sky130_fd_sc_hd__o22ai_1 U1886 ( .A1(n1313), .A2(n1310), .B1(n584), .B2(
        n1311), .Y(s_mem_d[73]) );
  sky130_fd_sc_hd__inv_1 U1887 ( .A(s_mem_q[72]), .Y(n1312) );
  sky130_fd_sc_hd__o22ai_1 U1888 ( .A1(n1313), .A2(n1312), .B1(n51), .B2(n1311), .Y(s_mem_d[72]) );
  sky130_fd_sc_hd__nand3_1 U1889 ( .A(n1424), .B(n1423), .C(n1425), .Y(n1314)
         );
  sky130_fd_sc_hd__inv_1 U1890 ( .A(s_mem_q[71]), .Y(n1317) );
  sky130_fd_sc_hd__o22ai_1 U1891 ( .A1(n16), .A2(n1317), .B1(n578), .B2(n1325), 
        .Y(s_mem_d[71]) );
  sky130_fd_sc_hd__inv_1 U1892 ( .A(s_mem_q[70]), .Y(n1318) );
  sky130_fd_sc_hd__o22ai_1 U1893 ( .A1(n16), .A2(n1318), .B1(n57), .B2(n1325), 
        .Y(s_mem_d[70]) );
  sky130_fd_sc_hd__inv_1 U1894 ( .A(s_mem_q[69]), .Y(n1319) );
  sky130_fd_sc_hd__o22ai_1 U1895 ( .A1(n16), .A2(n1319), .B1(n65), .B2(n1325), 
        .Y(s_mem_d[69]) );
  sky130_fd_sc_hd__inv_1 U1896 ( .A(s_mem_q[68]), .Y(n1320) );
  sky130_fd_sc_hd__o22ai_1 U1897 ( .A1(n16), .A2(n1320), .B1(n73), .B2(n1325), 
        .Y(s_mem_d[68]) );
  sky130_fd_sc_hd__inv_1 U1898 ( .A(s_mem_q[67]), .Y(n1321) );
  sky130_fd_sc_hd__o22ai_1 U1899 ( .A1(n16), .A2(n1321), .B1(n81), .B2(n1325), 
        .Y(s_mem_d[67]) );
  sky130_fd_sc_hd__inv_1 U1900 ( .A(s_mem_q[66]), .Y(n1322) );
  sky130_fd_sc_hd__o22ai_1 U1901 ( .A1(n16), .A2(n1322), .B1(n89), .B2(n1325), 
        .Y(s_mem_d[66]) );
  sky130_fd_sc_hd__inv_1 U1902 ( .A(s_mem_q[65]), .Y(n1323) );
  sky130_fd_sc_hd__o22ai_1 U1903 ( .A1(n16), .A2(n1323), .B1(n97), .B2(n1325), 
        .Y(s_mem_d[65]) );
  sky130_fd_sc_hd__inv_1 U1904 ( .A(s_mem_q[64]), .Y(n1324) );
  sky130_fd_sc_hd__o22ai_1 U1905 ( .A1(n16), .A2(n1324), .B1(n584), .B2(n1325), 
        .Y(s_mem_d[64]) );
  sky130_fd_sc_hd__inv_1 U1906 ( .A(s_mem_q[63]), .Y(n1326) );
  sky130_fd_sc_hd__o22ai_1 U1907 ( .A1(n16), .A2(n1326), .B1(n49), .B2(n1325), 
        .Y(s_mem_d[63]) );
  sky130_fd_sc_hd__inv_1 U1908 ( .A(s_mem_q[62]), .Y(n1329) );
  sky130_fd_sc_hd__o22ai_1 U1909 ( .A1(n5), .A2(n1329), .B1(n580), .B2(n1337), 
        .Y(s_mem_d[62]) );
  sky130_fd_sc_hd__inv_1 U1910 ( .A(s_mem_q[61]), .Y(n1330) );
  sky130_fd_sc_hd__o22ai_1 U1911 ( .A1(n5), .A2(n1330), .B1(n56), .B2(n1337), 
        .Y(s_mem_d[61]) );
  sky130_fd_sc_hd__inv_1 U1912 ( .A(s_mem_q[60]), .Y(n1331) );
  sky130_fd_sc_hd__o22ai_1 U1913 ( .A1(n5), .A2(n1331), .B1(n64), .B2(n1337), 
        .Y(s_mem_d[60]) );
  sky130_fd_sc_hd__inv_1 U1914 ( .A(s_mem_q[59]), .Y(n1332) );
  sky130_fd_sc_hd__o22ai_1 U1915 ( .A1(n5), .A2(n1332), .B1(n72), .B2(n1337), 
        .Y(s_mem_d[59]) );
  sky130_fd_sc_hd__inv_1 U1916 ( .A(s_mem_q[58]), .Y(n1333) );
  sky130_fd_sc_hd__o22ai_1 U1917 ( .A1(n5), .A2(n1333), .B1(n80), .B2(n1337), 
        .Y(s_mem_d[58]) );
  sky130_fd_sc_hd__inv_1 U1918 ( .A(s_mem_q[57]), .Y(n1334) );
  sky130_fd_sc_hd__o22ai_1 U1919 ( .A1(n5), .A2(n1334), .B1(n88), .B2(n1337), 
        .Y(s_mem_d[57]) );
  sky130_fd_sc_hd__inv_1 U1920 ( .A(s_mem_q[56]), .Y(n1335) );
  sky130_fd_sc_hd__o22ai_1 U1921 ( .A1(n5), .A2(n1335), .B1(n96), .B2(n1337), 
        .Y(s_mem_d[56]) );
  sky130_fd_sc_hd__inv_1 U1922 ( .A(s_mem_q[55]), .Y(n1336) );
  sky130_fd_sc_hd__o22ai_1 U1923 ( .A1(n5), .A2(n1336), .B1(n584), .B2(n1337), 
        .Y(s_mem_d[55]) );
  sky130_fd_sc_hd__inv_1 U1924 ( .A(s_mem_q[54]), .Y(n1338) );
  sky130_fd_sc_hd__o22ai_1 U1925 ( .A1(n5), .A2(n1338), .B1(n50), .B2(n1337), 
        .Y(s_mem_d[54]) );
  sky130_fd_sc_hd__inv_1 U1926 ( .A(s_mem_q[53]), .Y(n1341) );
  sky130_fd_sc_hd__o22ai_1 U1927 ( .A1(n13), .A2(n1341), .B1(n580), .B2(n1349), 
        .Y(s_mem_d[53]) );
  sky130_fd_sc_hd__inv_1 U1928 ( .A(s_mem_q[52]), .Y(n1342) );
  sky130_fd_sc_hd__o22ai_1 U1929 ( .A1(n13), .A2(n1342), .B1(n62), .B2(n1349), 
        .Y(s_mem_d[52]) );
  sky130_fd_sc_hd__inv_1 U1930 ( .A(s_mem_q[51]), .Y(n1343) );
  sky130_fd_sc_hd__o22ai_1 U1931 ( .A1(n13), .A2(n1343), .B1(n70), .B2(n1349), 
        .Y(s_mem_d[51]) );
  sky130_fd_sc_hd__inv_1 U1932 ( .A(s_mem_q[50]), .Y(n1344) );
  sky130_fd_sc_hd__o22ai_1 U1933 ( .A1(n13), .A2(n1344), .B1(n78), .B2(n1349), 
        .Y(s_mem_d[50]) );
  sky130_fd_sc_hd__inv_1 U1934 ( .A(s_mem_q[49]), .Y(n1345) );
  sky130_fd_sc_hd__o22ai_1 U1935 ( .A1(n13), .A2(n1345), .B1(n86), .B2(n1349), 
        .Y(s_mem_d[49]) );
  sky130_fd_sc_hd__inv_1 U1936 ( .A(s_mem_q[48]), .Y(n1346) );
  sky130_fd_sc_hd__o22ai_1 U1937 ( .A1(n13), .A2(n1346), .B1(n94), .B2(n1349), 
        .Y(s_mem_d[48]) );
  sky130_fd_sc_hd__inv_1 U1938 ( .A(s_mem_q[47]), .Y(n1347) );
  sky130_fd_sc_hd__o22ai_1 U1939 ( .A1(n13), .A2(n1347), .B1(n102), .B2(n1349), 
        .Y(s_mem_d[47]) );
  sky130_fd_sc_hd__inv_1 U1940 ( .A(s_mem_q[46]), .Y(n1348) );
  sky130_fd_sc_hd__o22ai_1 U1941 ( .A1(n13), .A2(n1348), .B1(n584), .B2(n1349), 
        .Y(s_mem_d[46]) );
  sky130_fd_sc_hd__inv_1 U1942 ( .A(s_mem_q[45]), .Y(n1350) );
  sky130_fd_sc_hd__o22ai_1 U1943 ( .A1(n13), .A2(n1350), .B1(n53), .B2(n1349), 
        .Y(s_mem_d[45]) );
  sky130_fd_sc_hd__inv_1 U1944 ( .A(s_mem_q[44]), .Y(n1353) );
  sky130_fd_sc_hd__o22ai_1 U1945 ( .A1(n6), .A2(n1353), .B1(n577), .B2(n1361), 
        .Y(s_mem_d[44]) );
  sky130_fd_sc_hd__inv_1 U1946 ( .A(s_mem_q[43]), .Y(n1354) );
  sky130_fd_sc_hd__o22ai_1 U1947 ( .A1(n6), .A2(n1354), .B1(n56), .B2(n1361), 
        .Y(s_mem_d[43]) );
  sky130_fd_sc_hd__inv_1 U1948 ( .A(s_mem_q[42]), .Y(n1355) );
  sky130_fd_sc_hd__o22ai_1 U1949 ( .A1(n6), .A2(n1355), .B1(n64), .B2(n1361), 
        .Y(s_mem_d[42]) );
  sky130_fd_sc_hd__inv_1 U1950 ( .A(s_mem_q[41]), .Y(n1356) );
  sky130_fd_sc_hd__o22ai_1 U1951 ( .A1(n6), .A2(n1356), .B1(n72), .B2(n1361), 
        .Y(s_mem_d[41]) );
  sky130_fd_sc_hd__inv_1 U1952 ( .A(s_mem_q[40]), .Y(n1357) );
  sky130_fd_sc_hd__o22ai_1 U1953 ( .A1(n6), .A2(n1357), .B1(n80), .B2(n1361), 
        .Y(s_mem_d[40]) );
  sky130_fd_sc_hd__inv_1 U1954 ( .A(s_mem_q[39]), .Y(n1358) );
  sky130_fd_sc_hd__o22ai_1 U1955 ( .A1(n6), .A2(n1358), .B1(n88), .B2(n1361), 
        .Y(s_mem_d[39]) );
  sky130_fd_sc_hd__inv_1 U1956 ( .A(s_mem_q[38]), .Y(n1359) );
  sky130_fd_sc_hd__o22ai_1 U1957 ( .A1(n6), .A2(n1359), .B1(n96), .B2(n1361), 
        .Y(s_mem_d[38]) );
  sky130_fd_sc_hd__inv_1 U1958 ( .A(s_mem_q[37]), .Y(n1360) );
  sky130_fd_sc_hd__o22ai_1 U1959 ( .A1(n6), .A2(n1360), .B1(n584), .B2(n1361), 
        .Y(s_mem_d[37]) );
  sky130_fd_sc_hd__inv_1 U1960 ( .A(s_mem_q[36]), .Y(n1362) );
  sky130_fd_sc_hd__o22ai_1 U1961 ( .A1(n6), .A2(n1362), .B1(n49), .B2(n1361), 
        .Y(s_mem_d[36]) );
  sky130_fd_sc_hd__inv_1 U1962 ( .A(s_mem_q[35]), .Y(n1364) );
  sky130_fd_sc_hd__o22ai_1 U1963 ( .A1(n14), .A2(n1364), .B1(n579), .B2(n1372), 
        .Y(s_mem_d[35]) );
  sky130_fd_sc_hd__inv_1 U1964 ( .A(s_mem_q[34]), .Y(n1365) );
  sky130_fd_sc_hd__o22ai_1 U1965 ( .A1(n14), .A2(n1365), .B1(n60), .B2(n1372), 
        .Y(s_mem_d[34]) );
  sky130_fd_sc_hd__inv_1 U1966 ( .A(s_mem_q[33]), .Y(n1366) );
  sky130_fd_sc_hd__o22ai_1 U1967 ( .A1(n14), .A2(n1366), .B1(n68), .B2(n1372), 
        .Y(s_mem_d[33]) );
  sky130_fd_sc_hd__inv_1 U1968 ( .A(s_mem_q[32]), .Y(n1367) );
  sky130_fd_sc_hd__o22ai_1 U1969 ( .A1(n14), .A2(n1367), .B1(n76), .B2(n1372), 
        .Y(s_mem_d[32]) );
  sky130_fd_sc_hd__inv_1 U1970 ( .A(s_mem_q[31]), .Y(n1368) );
  sky130_fd_sc_hd__o22ai_1 U1971 ( .A1(n14), .A2(n1368), .B1(n84), .B2(n1372), 
        .Y(s_mem_d[31]) );
  sky130_fd_sc_hd__inv_1 U1972 ( .A(s_mem_q[30]), .Y(n1369) );
  sky130_fd_sc_hd__o22ai_1 U1973 ( .A1(n14), .A2(n1369), .B1(n92), .B2(n1372), 
        .Y(s_mem_d[30]) );
  sky130_fd_sc_hd__inv_1 U1974 ( .A(s_mem_q[29]), .Y(n1370) );
  sky130_fd_sc_hd__o22ai_1 U1975 ( .A1(n14), .A2(n1370), .B1(n100), .B2(n1372), 
        .Y(s_mem_d[29]) );
  sky130_fd_sc_hd__inv_1 U1976 ( .A(s_mem_q[28]), .Y(n1371) );
  sky130_fd_sc_hd__o22ai_1 U1977 ( .A1(n14), .A2(n1371), .B1(n584), .B2(n1372), 
        .Y(s_mem_d[28]) );
  sky130_fd_sc_hd__inv_1 U1978 ( .A(s_mem_q[27]), .Y(n1373) );
  sky130_fd_sc_hd__o22ai_1 U1979 ( .A1(n14), .A2(n1373), .B1(n53), .B2(n1372), 
        .Y(s_mem_d[27]) );
  sky130_fd_sc_hd__inv_1 U1980 ( .A(s_mem_q[26]), .Y(n1376) );
  sky130_fd_sc_hd__o22ai_1 U1981 ( .A1(n17), .A2(n1376), .B1(n577), .B2(n1384), 
        .Y(s_mem_d[26]) );
  sky130_fd_sc_hd__inv_1 U1982 ( .A(s_mem_q[25]), .Y(n1377) );
  sky130_fd_sc_hd__o22ai_1 U1983 ( .A1(n17), .A2(n1377), .B1(n61), .B2(n1384), 
        .Y(s_mem_d[25]) );
  sky130_fd_sc_hd__inv_1 U1984 ( .A(s_mem_q[24]), .Y(n1378) );
  sky130_fd_sc_hd__o22ai_1 U1985 ( .A1(n17), .A2(n1378), .B1(n69), .B2(n1384), 
        .Y(s_mem_d[24]) );
  sky130_fd_sc_hd__inv_1 U1986 ( .A(s_mem_q[23]), .Y(n1379) );
  sky130_fd_sc_hd__o22ai_1 U1987 ( .A1(n17), .A2(n1379), .B1(n77), .B2(n1384), 
        .Y(s_mem_d[23]) );
  sky130_fd_sc_hd__inv_1 U1988 ( .A(s_mem_q[22]), .Y(n1380) );
  sky130_fd_sc_hd__o22ai_1 U1989 ( .A1(n17), .A2(n1380), .B1(n85), .B2(n1384), 
        .Y(s_mem_d[22]) );
  sky130_fd_sc_hd__inv_1 U1990 ( .A(s_mem_q[21]), .Y(n1381) );
  sky130_fd_sc_hd__o22ai_1 U1991 ( .A1(n17), .A2(n1381), .B1(n93), .B2(n1384), 
        .Y(s_mem_d[21]) );
  sky130_fd_sc_hd__inv_1 U1992 ( .A(s_mem_q[20]), .Y(n1382) );
  sky130_fd_sc_hd__o22ai_1 U1993 ( .A1(n17), .A2(n1382), .B1(n101), .B2(n1384), 
        .Y(s_mem_d[20]) );
  sky130_fd_sc_hd__inv_1 U1994 ( .A(s_mem_q[19]), .Y(n1383) );
  sky130_fd_sc_hd__o22ai_1 U1995 ( .A1(n17), .A2(n1383), .B1(n584), .B2(n1384), 
        .Y(s_mem_d[19]) );
  sky130_fd_sc_hd__inv_1 U1996 ( .A(s_mem_q[18]), .Y(n1385) );
  sky130_fd_sc_hd__o22ai_1 U1997 ( .A1(n17), .A2(n1385), .B1(n52), .B2(n1384), 
        .Y(s_mem_d[18]) );
  sky130_fd_sc_hd__inv_1 U1998 ( .A(s_mem_q[17]), .Y(n1388) );
  sky130_fd_sc_hd__o22ai_1 U1999 ( .A1(n15), .A2(n1388), .B1(n578), .B2(n1396), 
        .Y(s_mem_d[17]) );
  sky130_fd_sc_hd__inv_1 U2000 ( .A(s_mem_q[16]), .Y(n1389) );
  sky130_fd_sc_hd__o22ai_1 U2001 ( .A1(n15), .A2(n1389), .B1(n59), .B2(n1396), 
        .Y(s_mem_d[16]) );
  sky130_fd_sc_hd__inv_1 U2002 ( .A(s_mem_q[15]), .Y(n1390) );
  sky130_fd_sc_hd__o22ai_1 U2003 ( .A1(n15), .A2(n1390), .B1(n67), .B2(n1396), 
        .Y(s_mem_d[15]) );
  sky130_fd_sc_hd__inv_1 U2004 ( .A(s_mem_q[14]), .Y(n1391) );
  sky130_fd_sc_hd__o22ai_1 U2005 ( .A1(n15), .A2(n1391), .B1(n75), .B2(n1396), 
        .Y(s_mem_d[14]) );
  sky130_fd_sc_hd__inv_1 U2006 ( .A(s_mem_q[13]), .Y(n1392) );
  sky130_fd_sc_hd__o22ai_1 U2007 ( .A1(n15), .A2(n1392), .B1(n83), .B2(n1396), 
        .Y(s_mem_d[13]) );
  sky130_fd_sc_hd__inv_1 U2008 ( .A(s_mem_q[12]), .Y(n1393) );
  sky130_fd_sc_hd__o22ai_1 U2009 ( .A1(n15), .A2(n1393), .B1(n91), .B2(n1396), 
        .Y(s_mem_d[12]) );
  sky130_fd_sc_hd__inv_1 U2010 ( .A(s_mem_q[11]), .Y(n1394) );
  sky130_fd_sc_hd__o22ai_1 U2011 ( .A1(n15), .A2(n1394), .B1(n99), .B2(n1396), 
        .Y(s_mem_d[11]) );
  sky130_fd_sc_hd__inv_1 U2012 ( .A(s_mem_q[10]), .Y(n1395) );
  sky130_fd_sc_hd__o22ai_1 U2013 ( .A1(n15), .A2(n1395), .B1(n584), .B2(n1396), 
        .Y(s_mem_d[10]) );
  sky130_fd_sc_hd__inv_1 U2014 ( .A(s_mem_q[9]), .Y(n1397) );
  sky130_fd_sc_hd__o22ai_1 U2015 ( .A1(n15), .A2(n1397), .B1(n52), .B2(n1396), 
        .Y(s_mem_d[9]) );
  sky130_fd_sc_hd__inv_1 U2016 ( .A(s_mem_q[8]), .Y(n1403) );
  sky130_fd_sc_hd__o22ai_1 U2017 ( .A1(n11), .A2(n1403), .B1(n1419), .B2(n580), 
        .Y(s_mem_d[8]) );
  sky130_fd_sc_hd__inv_1 U2018 ( .A(s_mem_q[7]), .Y(n1405) );
  sky130_fd_sc_hd__o22ai_1 U2019 ( .A1(n11), .A2(n1405), .B1(n1419), .B2(n57), 
        .Y(s_mem_d[7]) );
  sky130_fd_sc_hd__inv_1 U2020 ( .A(s_mem_q[6]), .Y(n1407) );
  sky130_fd_sc_hd__o22ai_1 U2021 ( .A1(n11), .A2(n1407), .B1(n1419), .B2(n65), 
        .Y(s_mem_d[6]) );
  sky130_fd_sc_hd__inv_1 U2022 ( .A(s_mem_q[5]), .Y(n1409) );
  sky130_fd_sc_hd__o22ai_1 U2023 ( .A1(n11), .A2(n1409), .B1(n1419), .B2(n73), 
        .Y(s_mem_d[5]) );
  sky130_fd_sc_hd__inv_1 U2024 ( .A(s_mem_q[4]), .Y(n1411) );
  sky130_fd_sc_hd__o22ai_1 U2025 ( .A1(n11), .A2(n1411), .B1(n1419), .B2(n81), 
        .Y(s_mem_d[4]) );
  sky130_fd_sc_hd__inv_1 U2026 ( .A(s_mem_q[3]), .Y(n1413) );
  sky130_fd_sc_hd__o22ai_1 U2027 ( .A1(n11), .A2(n1413), .B1(n1419), .B2(n89), 
        .Y(s_mem_d[3]) );
  sky130_fd_sc_hd__inv_1 U2028 ( .A(s_mem_q[2]), .Y(n1415) );
  sky130_fd_sc_hd__o22ai_1 U2029 ( .A1(n11), .A2(n1415), .B1(n1419), .B2(n97), 
        .Y(s_mem_d[2]) );
  sky130_fd_sc_hd__inv_1 U2030 ( .A(s_mem_q[1]), .Y(n1417) );
  sky130_fd_sc_hd__o22ai_1 U2031 ( .A1(n11), .A2(n1417), .B1(n1419), .B2(n584), 
        .Y(s_mem_d[1]) );
  sky130_fd_sc_hd__inv_1 U2032 ( .A(s_mem_q[0]), .Y(n1420) );
  sky130_fd_sc_hd__o22ai_1 U2033 ( .A1(n11), .A2(n1420), .B1(n1419), .B2(n51), 
        .Y(s_mem_d[0]) );
  sky130_fd_sc_hd__nand2_1 U2034 ( .A(n47), .B(n1421), .Y(n1429) );
  sky130_fd_sc_hd__o2bb2ai_1 U2035 ( .B1(n1429), .B2(n1423), .A1_N(N100), 
        .A2_N(n1427), .Y(s_wr_ptr_d[5]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2036 ( .B1(n1429), .B2(n1424), .A1_N(N99), 
        .A2_N(n1427), .Y(s_wr_ptr_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2037 ( .B1(n1429), .B2(n1425), .A1_N(N98), 
        .A2_N(n1427), .Y(s_wr_ptr_d[3]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2038 ( .B1(n1429), .B2(n1426), .A1_N(N97), 
        .A2_N(n1427), .Y(s_wr_ptr_d[2]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2039 ( .B1(n1429), .B2(n1428), .A1_N(N96), 
        .A2_N(n1427), .Y(s_wr_ptr_d[1]) );
  sky130_fd_sc_hd__mux2i_1 U2040 ( .A0(n1430), .A1(n1429), .S(s_wr_ptr_q[0]), 
        .Y(s_wr_ptr_d[0]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2041 ( .B1(n564), .B2(n534), .A1_N(N88), .A2_N(
        n1432), .Y(s_rd_ptr_d[4]) );
  sky130_fd_sc_hd__inv_1 U2042 ( .A(N78), .Y(n1431) );
  sky130_fd_sc_hd__nor3_1 U2043 ( .A(cnt_o[5]), .B(n1436), .C(n1435), .Y(
        full_o) );
  sky130_fd_sc_hd__xor2_1 U2044 ( .A(\add_50/carry[5] ), .B(N80), .X(N89) );
  sky130_fd_sc_hd__xor2_1 U2045 ( .A(\add_65/carry[5] ), .B(s_wr_ptr_q[5]), 
        .X(N100) );
endmodule


module uart_rx_DW01_inc_1 ( A, SUM );
  input [15:0] A;
  output [15:0] SUM;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n42, n43, n44, n45,
         n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n58;
  assign n2 = A[14];
  assign n9 = A[12];
  assign n15 = A[11];
  assign n18 = A[10];
  assign n22 = A[9];
  assign n25 = A[8];
  assign n31 = A[7];
  assign n34 = A[6];
  assign n38 = A[5];
  assign n42 = A[4];
  assign n47 = A[3];
  assign n50 = A[2];
  assign n54 = A[1];
  assign n56 = A[0];

  sky130_fd_sc_hd__xor2_1 U1 ( .A(A[15]), .B(n58), .X(SUM[15]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n3), .B(n4), .Y(SUM[14]) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n4), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n8), .B(n7), .X(SUM[13]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n28), .B(n5), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n13), .B(n6), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n7), .B(n10), .Y(n6) );
  sky130_fd_sc_hd__xnor2_1 U12 ( .A(n10), .B(n11), .Y(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n11), .B(n9), .Y(n8) );
  sky130_fd_sc_hd__xor2_1 U16 ( .A(n17), .B(n16), .X(SUM[11]) );
  sky130_fd_sc_hd__nor2_1 U17 ( .A(n12), .B(n28), .Y(n11) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n14), .B(n21), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n18), .B(n15), .Y(n14) );
  sky130_fd_sc_hd__xnor2_1 U23 ( .A(n19), .B(n20), .Y(SUM[10]) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n20), .B(n18), .Y(n17) );
  sky130_fd_sc_hd__xor2_1 U27 ( .A(n24), .B(n23), .X(SUM[9]) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n21), .B(n28), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n25), .B(n22), .Y(n21) );
  sky130_fd_sc_hd__xnor2_1 U32 ( .A(n26), .B(n27), .Y(SUM[8]) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n27), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__xor2_1 U36 ( .A(n33), .B(n32), .X(SUM[7]) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n29), .B(n45), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(n30), .B(n37), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n34), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__xnor2_1 U43 ( .A(n35), .B(n36), .Y(SUM[6]) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n36), .B(n34), .Y(n33) );
  sky130_fd_sc_hd__xnor2_1 U47 ( .A(n39), .B(n40), .Y(SUM[5]) );
  sky130_fd_sc_hd__nor2_1 U48 ( .A(n37), .B(n44), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n42), .B(n38), .Y(n37) );
  sky130_fd_sc_hd__xor2_1 U52 ( .A(n44), .B(n43), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U53 ( .A(n43), .B(n44), .Y(n40) );
  sky130_fd_sc_hd__xor2_1 U57 ( .A(n49), .B(n48), .X(SUM[3]) );
  sky130_fd_sc_hd__nor2_1 U59 ( .A(n53), .B(n46), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U60 ( .A(n50), .B(n47), .Y(n46) );
  sky130_fd_sc_hd__xnor2_1 U63 ( .A(n51), .B(n52), .Y(SUM[2]) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n52), .B(n50), .Y(n49) );
  sky130_fd_sc_hd__xnor2_1 U67 ( .A(n56), .B(n55), .Y(SUM[1]) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n54), .B(n56), .Y(n53) );
  sky130_fd_sc_hd__inv_1 U76 ( .A(n28), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U77 ( .A(n45), .Y(n44) );
  sky130_fd_sc_hd__inv_1 U78 ( .A(n53), .Y(n52) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(n42), .Y(n43) );
  sky130_fd_sc_hd__inv_2 U80 ( .A(n1), .Y(n58) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n15), .Y(n16) );
  sky130_fd_sc_hd__inv_1 U82 ( .A(n22), .Y(n23) );
  sky130_fd_sc_hd__inv_2 U83 ( .A(n31), .Y(n32) );
  sky130_fd_sc_hd__inv_2 U84 ( .A(n47), .Y(n48) );
  sky130_fd_sc_hd__inv_2 U85 ( .A(n54), .Y(n55) );
  sky130_fd_sc_hd__inv_1 U86 ( .A(A[13]), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U87 ( .A(n9), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(n13), .Y(n12) );
  sky130_fd_sc_hd__inv_1 U89 ( .A(n2), .Y(n3) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(n18), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U91 ( .A(n25), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U92 ( .A(n34), .Y(n35) );
  sky130_fd_sc_hd__inv_1 U93 ( .A(n38), .Y(n39) );
  sky130_fd_sc_hd__inv_2 U94 ( .A(n50), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U95 ( .A(n56), .Y(SUM[0]) );
endmodule


module uart_rx ( clk_i, rst_n_i, rx_i, busy_o, cfg_en_i, cfg_div_i, 
        cfg_parity_en_i, cfg_bits_i, err_o, err_clr_i, rx_data_o, rx_valid_o, 
        rx_ready_i );
  input [15:0] cfg_div_i;
  input [1:0] cfg_bits_i;
  output [7:0] rx_data_o;
  input clk_i, rst_n_i, rx_i, cfg_en_i, cfg_parity_en_i, err_clr_i, rx_ready_i;
  output busy_o, err_o, rx_valid_o;
  wire   s_parity_bit_q, s_bit_done, N78, N79, N80, N90, N91, N92, N93, N94,
         N95, N96, N97, N98, N99, N100, N101, N102, N103, N104, N105, N123,
         N124, N125, N126, N127, N128, N129, N130, N131, N132, N133, N134,
         N135, N136, N137, N138, N139, n23, n24, n35, n36, n37, n46, n47, n49,
         n51, n66, n67, n115, n116, n117, n118, n119, n120, n121, n122, n123,
         n124, n125, n126, n127, n128, n129, n130, n1, n2, n3, n4, n5, n6, n7,
         n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21,
         n22, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n38, n39, n40,
         n41, n42, n43, n44, n45, n48, n50, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n68, n69, n70, n71, n72, n73, n74,
         n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88,
         n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101,
         n102, n103, n104, n105, n106, n107, n108, n109, n110, n111, n112,
         n113, n114, n132, n133, n134;
  wire   [2:0] s_fsm_q;
  wire   [2:0] s_reg_bit_cnt_q;
  wire   [2:0] reg_rx_sync;
  wire   [15:0] s_baud_cnt;

  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_0_ ( .D(N124), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[0]) );
  sky130_fd_sc_hd__dfrtp_1 s_bit_done_reg ( .D(N123), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_bit_done) );
  sky130_fd_sc_hd__dfrtp_1 s_reg_bit_cnt_q_reg_1_ ( .D(n130), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_reg_bit_cnt_q[1]) );
  sky130_fd_sc_hd__dfrtp_1 s_reg_bit_cnt_q_reg_2_ ( .D(n116), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_reg_bit_cnt_q[2]) );
  sky130_fd_sc_hd__dfrtp_1 s_reg_bit_cnt_q_reg_0_ ( .D(n117), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_reg_bit_cnt_q[0]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_0_ ( .D(n127), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[0]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_2_ ( .D(n129), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[2]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_1_ ( .D(n128), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[1]) );
  sky130_fd_sc_hd__dfrtp_1 s_parity_bit_q_reg ( .D(n118), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_parity_bit_q) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_7_ ( .D(n120), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[7]), .Q_N(n23) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_1_ ( .D(N125), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[1]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_2_ ( .D(N126), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[2]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_3_ ( .D(N127), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[3]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_4_ ( .D(N128), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[4]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_5_ ( .D(N129), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[5]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_6_ ( .D(N130), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[6]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_7_ ( .D(N131), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[7]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_8_ ( .D(N132), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[8]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_9_ ( .D(N133), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[9]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_10_ ( .D(N134), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[10]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_11_ ( .D(N135), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[11]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_12_ ( .D(N136), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[12]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_13_ ( .D(N137), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[13]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_14_ ( .D(N138), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[14]) );
  sky130_fd_sc_hd__dfrtp_1 s_baud_cnt_reg_15_ ( .D(N139), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_baud_cnt[15]) );
  sky130_fd_sc_hd__dfrtp_1 err_o_reg ( .D(n115), .CLK(clk_i), .RESET_B(rst_n_i), .Q(err_o) );
  sky130_fd_sc_hd__o21ai_1 U9 ( .A1(n111), .A2(n132), .B1(n47), .Y(n121) );
  sky130_fd_sc_hd__o21ai_1 U14 ( .A1(n111), .A2(n24), .B1(n51), .Y(n126) );
  sky130_fd_sc_hd__a22o_1 U63 ( .A1(n111), .A2(rx_data_o[1]), .B1(rx_data_o[0]), .B2(n112), .X(n119) );
  sky130_fd_sc_hd__a22o_1 U65 ( .A1(n111), .A2(rx_data_o[2]), .B1(n112), .B2(
        rx_data_o[1]), .X(n122) );
  sky130_fd_sc_hd__a22o_1 U66 ( .A1(n111), .A2(rx_data_o[3]), .B1(n112), .B2(
        rx_data_o[2]), .X(n123) );
  sky130_fd_sc_hd__a22o_1 U67 ( .A1(n111), .A2(rx_data_o[4]), .B1(n112), .B2(
        rx_data_o[3]), .X(n124) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(cfg_bits_i[1]), .B(cfg_bits_i[0]), .Y(n46)
         );
  sky130_fd_sc_hd__xor2_1 U75 ( .A(n113), .B(cfg_bits_i[1]), .X(n67) );
  sky130_fd_sc_hd__xor2_1 U76 ( .A(n110), .B(cfg_bits_i[0]), .X(n66) );
  sky130_fd_sc_hd__nand2b_1 U79 ( .A_N(rx_i), .B(cfg_en_i), .Y(N78) );
  sky130_fd_sc_hd__dfstp_2 reg_rx_sync_reg_0_ ( .D(N78), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(reg_rx_sync[0]) );
  sky130_fd_sc_hd__dfstp_2 s_reg_data_q_reg_4_ ( .D(n125), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[4]) );
  sky130_fd_sc_hd__dfstp_2 s_reg_data_q_reg_3_ ( .D(n124), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[3]) );
  sky130_fd_sc_hd__dfstp_2 s_reg_data_q_reg_2_ ( .D(n123), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[2]) );
  sky130_fd_sc_hd__dfstp_2 s_reg_data_q_reg_1_ ( .D(n122), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[1]) );
  sky130_fd_sc_hd__dfstp_2 s_reg_data_q_reg_0_ ( .D(n119), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[0]) );
  uart_rx_DW01_inc_1 add_175 ( .A(s_baud_cnt), .SUM({N105, N104, N103, N102, 
        N101, N100, N99, N98, N97, N96, N95, N94, N93, N92, N91, N90}) );
  sky130_fd_sc_hd__dfsbp_1 reg_rx_sync_reg_1_ ( .D(N79), .CLK(clk_i), .SET_B(
        rst_n_i), .Q_N(n20) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_5_ ( .D(n121), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[5]) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_6_ ( .D(n126), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[6]), .Q_N(n24) );
  sky130_fd_sc_hd__dfsbp_1 reg_rx_sync_reg_2_ ( .D(N80), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(reg_rx_sync[2]), .Q_N(n105) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(n74), .Y(n75) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n77), .B(n76), .Y(n74) );
  sky130_fd_sc_hd__o311ai_1 U5 ( .A1(n11), .A2(rx_valid_o), .A3(n16), .B1(
        cfg_en_i), .C1(n15), .Y(n82) );
  sky130_fd_sc_hd__nand3_1 U6 ( .A(n14), .B(n13), .C(rx_ready_i), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n101), .Y(n90) );
  sky130_fd_sc_hd__inv_2 U8 ( .A(cfg_bits_i[1]), .Y(n133) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(n86), .Y(n102) );
  sky130_fd_sc_hd__clkinv_1 U11 ( .A(s_fsm_q[0]), .Y(n83) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(busy_o), .Y(n79) );
  sky130_fd_sc_hd__nand3_1 U13 ( .A(n66), .B(s_reg_bit_cnt_q[2]), .C(n67), .Y(
        n37) );
  sky130_fd_sc_hd__nor4_1 U15 ( .A(n65), .B(n64), .C(n63), .D(n62), .Y(n70) );
  sky130_fd_sc_hd__a21boi_2 U16 ( .A1(n72), .A2(n18), .B1_N(n107), .Y(n11) );
  sky130_fd_sc_hd__clkinv_1 U17 ( .A(n87), .Y(rx_valid_o) );
  sky130_fd_sc_hd__inv_2 U18 ( .A(n91), .Y(n94) );
  sky130_fd_sc_hd__inv_2 U19 ( .A(s_reg_bit_cnt_q[1]), .Y(n113) );
  sky130_fd_sc_hd__inv_1 U20 ( .A(n98), .Y(n96) );
  sky130_fd_sc_hd__o2bb2ai_1 U21 ( .B1(n49), .B2(n112), .A1_N(n112), .A2_N(
        rx_data_o[4]), .Y(n125) );
  sky130_fd_sc_hd__o2bb2ai_1 U22 ( .B1(err_clr_i), .B2(n3), .A1_N(err_o), 
        .A2_N(n3), .Y(n115) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(n108), .Y(n80) );
  sky130_fd_sc_hd__o32ai_1 U24 ( .A1(n35), .A2(s_reg_bit_cnt_q[2]), .A3(n113), 
        .B1(n36), .B2(n114), .Y(n116) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(s_reg_bit_cnt_q[2]), .Y(n114) );
  sky130_fd_sc_hd__a21boi_1 U26 ( .A1(n37), .A2(n113), .B1_N(n1), .Y(n36) );
  sky130_fd_sc_hd__o22ai_1 U27 ( .A1(n1), .A2(n113), .B1(s_reg_bit_cnt_q[1]), 
        .B2(n35), .Y(n130) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(n76), .Y(n78) );
  sky130_fd_sc_hd__o21a_1 U29 ( .A1(s_reg_bit_cnt_q[0]), .A2(n93), .B1(n94), 
        .X(n1) );
  sky130_fd_sc_hd__and2_1 U30 ( .A(n87), .B(n108), .X(n2) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(cfg_bits_i[0]), .Y(n134) );
  sky130_fd_sc_hd__o31a_1 U32 ( .A1(n109), .A2(n108), .A3(n107), .B1(n106), 
        .X(n3) );
  sky130_fd_sc_hd__and4_1 U33 ( .A(n4), .B(n5), .C(n6), .D(n7), .X(n71) );
  sky130_fd_sc_hd__and4_1 U34 ( .A(n26), .B(n25), .C(n22), .D(n21), .X(n4) );
  sky130_fd_sc_hd__and4_1 U35 ( .A(n30), .B(n29), .C(n28), .D(n27), .X(n5) );
  sky130_fd_sc_hd__and4_1 U36 ( .A(n34), .B(n33), .C(n32), .D(n31), .X(n6) );
  sky130_fd_sc_hd__and4_1 U37 ( .A(n41), .B(n40), .C(n39), .D(n38), .X(n7) );
  sky130_fd_sc_hd__dlygate4sd1_1 U38 ( .A(n77), .X(n8) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(n69), .Y(n73) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(cfg_en_i), .B(n82), .Y(n84) );
  sky130_fd_sc_hd__inv_1 U41 ( .A(n82), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U42 ( .A(n9), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U43 ( .A(n14), .Y(n16) );
  sky130_fd_sc_hd__clkinv_1 U44 ( .A(n11), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(n12), .Y(n18) );
  sky130_fd_sc_hd__nand3_2 U46 ( .A(s_fsm_q[1]), .B(n88), .C(n83), .Y(n86) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(s_fsm_q[2]), .Y(n88) );
  sky130_fd_sc_hd__inv_2 U48 ( .A(n72), .Y(n19) );
  sky130_fd_sc_hd__nand2_4 U49 ( .A(n102), .B(n90), .Y(n112) );
  sky130_fd_sc_hd__inv_4 U50 ( .A(n112), .Y(n111) );
  sky130_fd_sc_hd__inv_1 U51 ( .A(s_fsm_q[1]), .Y(n17) );
  sky130_fd_sc_hd__nand3_1 U52 ( .A(s_fsm_q[0]), .B(n17), .C(n88), .Y(n89) );
  sky130_fd_sc_hd__nand2_1 U53 ( .A(n89), .B(n86), .Y(n12) );
  sky130_fd_sc_hd__nand2_1 U54 ( .A(s_fsm_q[2]), .B(n17), .Y(n72) );
  sky130_fd_sc_hd__inv_1 U55 ( .A(s_bit_done), .Y(n107) );
  sky130_fd_sc_hd__nand3_1 U56 ( .A(s_fsm_q[0]), .B(s_fsm_q[1]), .C(n88), .Y(
        n87) );
  sky130_fd_sc_hd__nand2_1 U57 ( .A(n20), .B(reg_rx_sync[2]), .Y(n68) );
  sky130_fd_sc_hd__nand3_1 U58 ( .A(n17), .B(n88), .C(n83), .Y(busy_o) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n68), .B(n79), .Y(n14) );
  sky130_fd_sc_hd__o22ai_1 U60 ( .A1(n18), .A2(n84), .B1(n17), .B2(n10), .Y(
        n128) );
  sky130_fd_sc_hd__nand2_1 U61 ( .A(n19), .B(n83), .Y(n108) );
  sky130_fd_sc_hd__o22ai_1 U62 ( .A1(n2), .A2(n84), .B1(n88), .B2(n10), .Y(
        n129) );
  sky130_fd_sc_hd__nand2b_1 U64 ( .A_N(reg_rx_sync[0]), .B(cfg_en_i), .Y(N79)
         );
  sky130_fd_sc_hd__nand2_1 U68 ( .A(n20), .B(cfg_en_i), .Y(N80) );
  sky130_fd_sc_hd__xnor2_1 U70 ( .A(cfg_div_i[10]), .B(s_baud_cnt[9]), .Y(n26)
         );
  sky130_fd_sc_hd__xnor2_1 U71 ( .A(cfg_div_i[1]), .B(s_baud_cnt[0]), .Y(n25)
         );
  sky130_fd_sc_hd__xnor2_1 U72 ( .A(s_baud_cnt[1]), .B(cfg_div_i[2]), .Y(n22)
         );
  sky130_fd_sc_hd__inv_1 U73 ( .A(s_baud_cnt[15]), .Y(n21) );
  sky130_fd_sc_hd__xnor2_1 U74 ( .A(cfg_div_i[3]), .B(s_baud_cnt[2]), .Y(n30)
         );
  sky130_fd_sc_hd__xnor2_1 U77 ( .A(cfg_div_i[6]), .B(s_baud_cnt[5]), .Y(n29)
         );
  sky130_fd_sc_hd__xnor2_1 U78 ( .A(s_baud_cnt[4]), .B(cfg_div_i[5]), .Y(n28)
         );
  sky130_fd_sc_hd__xnor2_1 U80 ( .A(s_baud_cnt[7]), .B(cfg_div_i[8]), .Y(n27)
         );
  sky130_fd_sc_hd__xnor2_1 U81 ( .A(s_baud_cnt[8]), .B(cfg_div_i[9]), .Y(n34)
         );
  sky130_fd_sc_hd__xnor2_1 U82 ( .A(cfg_div_i[7]), .B(s_baud_cnt[6]), .Y(n33)
         );
  sky130_fd_sc_hd__xnor2_1 U83 ( .A(s_baud_cnt[10]), .B(cfg_div_i[11]), .Y(n32) );
  sky130_fd_sc_hd__xnor2_1 U84 ( .A(s_baud_cnt[11]), .B(cfg_div_i[12]), .Y(n31) );
  sky130_fd_sc_hd__xnor2_1 U85 ( .A(s_baud_cnt[3]), .B(cfg_div_i[4]), .Y(n41)
         );
  sky130_fd_sc_hd__xnor2_1 U86 ( .A(cfg_div_i[14]), .B(s_baud_cnt[13]), .Y(n40) );
  sky130_fd_sc_hd__xnor2_1 U87 ( .A(s_baud_cnt[14]), .B(cfg_div_i[15]), .Y(n39) );
  sky130_fd_sc_hd__xnor2_1 U88 ( .A(s_baud_cnt[12]), .B(cfg_div_i[13]), .Y(n38) );
  sky130_fd_sc_hd__xnor2_1 U89 ( .A(s_baud_cnt[12]), .B(cfg_div_i[12]), .Y(n45) );
  sky130_fd_sc_hd__xnor2_1 U90 ( .A(s_baud_cnt[13]), .B(cfg_div_i[13]), .Y(n44) );
  sky130_fd_sc_hd__xnor2_1 U91 ( .A(s_baud_cnt[4]), .B(cfg_div_i[4]), .Y(n43)
         );
  sky130_fd_sc_hd__xnor2_1 U92 ( .A(s_baud_cnt[5]), .B(cfg_div_i[5]), .Y(n42)
         );
  sky130_fd_sc_hd__nand4_1 U93 ( .A(n45), .B(n44), .C(n43), .D(n42), .Y(n65)
         );
  sky130_fd_sc_hd__xnor2_1 U94 ( .A(s_baud_cnt[8]), .B(cfg_div_i[8]), .Y(n53)
         );
  sky130_fd_sc_hd__xnor2_1 U95 ( .A(s_baud_cnt[9]), .B(cfg_div_i[9]), .Y(n52)
         );
  sky130_fd_sc_hd__xnor2_1 U96 ( .A(s_baud_cnt[15]), .B(cfg_div_i[15]), .Y(n50) );
  sky130_fd_sc_hd__xnor2_1 U97 ( .A(s_baud_cnt[14]), .B(cfg_div_i[14]), .Y(n48) );
  sky130_fd_sc_hd__nand4_1 U98 ( .A(n53), .B(n52), .C(n50), .D(n48), .Y(n64)
         );
  sky130_fd_sc_hd__xnor2_1 U99 ( .A(s_baud_cnt[7]), .B(cfg_div_i[7]), .Y(n57)
         );
  sky130_fd_sc_hd__xnor2_1 U100 ( .A(s_baud_cnt[6]), .B(cfg_div_i[6]), .Y(n56)
         );
  sky130_fd_sc_hd__xnor2_1 U101 ( .A(s_baud_cnt[11]), .B(cfg_div_i[11]), .Y(
        n55) );
  sky130_fd_sc_hd__xnor2_1 U102 ( .A(s_baud_cnt[10]), .B(cfg_div_i[10]), .Y(
        n54) );
  sky130_fd_sc_hd__nand4_1 U103 ( .A(n57), .B(n56), .C(n55), .D(n54), .Y(n63)
         );
  sky130_fd_sc_hd__xnor2_1 U104 ( .A(s_baud_cnt[1]), .B(cfg_div_i[1]), .Y(n61)
         );
  sky130_fd_sc_hd__xnor2_1 U105 ( .A(s_baud_cnt[0]), .B(cfg_div_i[0]), .Y(n60)
         );
  sky130_fd_sc_hd__xnor2_1 U106 ( .A(s_baud_cnt[3]), .B(cfg_div_i[3]), .Y(n59)
         );
  sky130_fd_sc_hd__xnor2_1 U107 ( .A(s_baud_cnt[2]), .B(cfg_div_i[2]), .Y(n58)
         );
  sky130_fd_sc_hd__nand4_1 U108 ( .A(n61), .B(n60), .C(n59), .D(n58), .Y(n62)
         );
  sky130_fd_sc_hd__o21ai_1 U109 ( .A1(busy_o), .A2(n68), .B1(n89), .Y(n69) );
  sky130_fd_sc_hd__mux2i_1 U110 ( .A0(n71), .A1(n70), .S(n73), .Y(n77) );
  sky130_fd_sc_hd__nand4_1 U111 ( .A(n73), .B(n2), .C(n86), .D(n72), .Y(n76)
         );
  sky130_fd_sc_hd__and2_0 U112 ( .A(N105), .B(n75), .X(N139) );
  sky130_fd_sc_hd__and2_0 U113 ( .A(N104), .B(n75), .X(N138) );
  sky130_fd_sc_hd__and2_0 U114 ( .A(N103), .B(n75), .X(N137) );
  sky130_fd_sc_hd__and2_0 U115 ( .A(N102), .B(n75), .X(N136) );
  sky130_fd_sc_hd__and2_0 U116 ( .A(N101), .B(n75), .X(N135) );
  sky130_fd_sc_hd__and2_0 U117 ( .A(N100), .B(n75), .X(N134) );
  sky130_fd_sc_hd__and2_0 U118 ( .A(N99), .B(n75), .X(N133) );
  sky130_fd_sc_hd__and2_0 U119 ( .A(N98), .B(n75), .X(N132) );
  sky130_fd_sc_hd__and2_0 U120 ( .A(N97), .B(n75), .X(N131) );
  sky130_fd_sc_hd__and2_0 U121 ( .A(N96), .B(n75), .X(N130) );
  sky130_fd_sc_hd__and2_0 U122 ( .A(N95), .B(n75), .X(N129) );
  sky130_fd_sc_hd__and2_0 U123 ( .A(N94), .B(n75), .X(N128) );
  sky130_fd_sc_hd__and2_0 U124 ( .A(N93), .B(n75), .X(N127) );
  sky130_fd_sc_hd__and2_0 U125 ( .A(N92), .B(n75), .X(N126) );
  sky130_fd_sc_hd__and2_0 U126 ( .A(N90), .B(n75), .X(N124) );
  sky130_fd_sc_hd__and2_0 U127 ( .A(N91), .B(n75), .X(N125) );
  sky130_fd_sc_hd__nor2_1 U128 ( .A(n78), .B(n8), .Y(N123) );
  sky130_fd_sc_hd__o22ai_1 U129 ( .A1(cfg_parity_en_i), .A2(n87), .B1(n37), 
        .B2(n86), .Y(n81) );
  sky130_fd_sc_hd__nor3_1 U130 ( .A(n81), .B(n80), .C(n79), .Y(n85) );
  sky130_fd_sc_hd__o22ai_1 U131 ( .A1(n85), .A2(n84), .B1(n83), .B2(n10), .Y(
        n127) );
  sky130_fd_sc_hd__nand4_1 U132 ( .A(s_bit_done), .B(n88), .C(n87), .D(busy_o), 
        .Y(n101) );
  sky130_fd_sc_hd__nand2_1 U133 ( .A(reg_rx_sync[2]), .B(n111), .Y(n98) );
  sky130_fd_sc_hd__o22ai_1 U134 ( .A1(n46), .A2(n98), .B1(n23), .B2(n111), .Y(
        n120) );
  sky130_fd_sc_hd__nand2_1 U135 ( .A(n90), .B(n89), .Y(n91) );
  sky130_fd_sc_hd__nand2_1 U136 ( .A(n37), .B(n94), .Y(n92) );
  sky130_fd_sc_hd__mux2i_1 U137 ( .A0(n92), .A1(n94), .S(s_reg_bit_cnt_q[0]), 
        .Y(n117) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(s_reg_bit_cnt_q[0]), .Y(n110) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(n37), .Y(n93) );
  sky130_fd_sc_hd__nand3_1 U140 ( .A(n37), .B(s_reg_bit_cnt_q[0]), .C(n94), 
        .Y(n35) );
  sky130_fd_sc_hd__nor3_1 U141 ( .A(n23), .B(n46), .C(n112), .Y(n95) );
  sky130_fd_sc_hd__a31oi_1 U142 ( .A1(n134), .A2(cfg_bits_i[1]), .A3(n96), 
        .B1(n95), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(rx_data_o[5]), .Y(n132) );
  sky130_fd_sc_hd__o22ai_1 U144 ( .A1(cfg_bits_i[0]), .A2(n105), .B1(n134), 
        .B2(n132), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U145 ( .A1(n133), .A2(n97), .B1(cfg_bits_i[1]), 
        .B2(rx_data_o[5]), .Y(n49) );
  sky130_fd_sc_hd__nor2_1 U146 ( .A(n24), .B(n112), .Y(n100) );
  sky130_fd_sc_hd__nor2_1 U147 ( .A(n98), .B(n134), .Y(n99) );
  sky130_fd_sc_hd__mux2i_1 U148 ( .A0(n100), .A1(n99), .S(n133), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U149 ( .A(n111), .B(reg_rx_sync[2]), .Y(n104) );
  sky130_fd_sc_hd__a21oi_1 U150 ( .A1(n105), .A2(n102), .B1(n101), .Y(n103) );
  sky130_fd_sc_hd__mux2i_1 U151 ( .A0(n104), .A1(n103), .S(s_parity_bit_q), 
        .Y(n118) );
  sky130_fd_sc_hd__xor2_1 U152 ( .A(n105), .B(s_parity_bit_q), .X(n109) );
  sky130_fd_sc_hd__inv_1 U153 ( .A(err_clr_i), .Y(n106) );
endmodule


module dffr_DATA_WIDTH3 ( clk_i, rst_n_i, dat_i, dat_o );
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


module uart_irq_FIFO_DEPTH64 ( clk_i, rst_n_i, clr_int_i, irq_en_i, thre_i, 
        cti_i, pe_i, rx_elem_i, tx_elem_i, trg_level_i, ip_o, irq_o );
  input [2:0] irq_en_i;
  input [6:0] rx_elem_i;
  input [6:0] tx_elem_i;
  input [1:0] trg_level_i;
  output [2:0] ip_o;
  input clk_i, rst_n_i, clr_int_i, thre_i, cti_i, pe_i;
  output irq_o;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28;
  wire   [2:0] s_ip_d;

  dffr_DATA_WIDTH3 u_ip_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(s_ip_d), .dat_o(ip_o) );
  sky130_fd_sc_hd__nand3_1 U3 ( .A(n28), .B(n27), .C(n26), .Y(irq_o) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n22), .Y(n24) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n23), .Y(n18) );
  sky130_fd_sc_hd__nand2_1 U6 ( .A(pe_i), .B(irq_en_i[2]), .Y(n20) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(clr_int_i), .Y(n1) );
  sky130_fd_sc_hd__nand2_1 U8 ( .A(n20), .B(n1), .Y(n23) );
  sky130_fd_sc_hd__nor4b_1 U9 ( .D_N(irq_en_i[1]), .A(tx_elem_i[2]), .B(
        tx_elem_i[1]), .C(tx_elem_i[0]), .Y(n3) );
  sky130_fd_sc_hd__nor4_1 U10 ( .A(tx_elem_i[6]), .B(tx_elem_i[5]), .C(
        tx_elem_i[4]), .D(tx_elem_i[3]), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n3), .B(n2), .Y(n22) );
  sky130_fd_sc_hd__inv_1 U12 ( .A(rx_elem_i[1]), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(trg_level_i[0]), .Y(n4) );
  sky130_fd_sc_hd__nor2_1 U14 ( .A(n9), .B(n4), .Y(n6) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(trg_level_i[0]), .B(rx_elem_i[1]), .Y(n5)
         );
  sky130_fd_sc_hd__mux2i_1 U16 ( .A0(n6), .A1(n5), .S(rx_elem_i[0]), .Y(n7) );
  sky130_fd_sc_hd__nor3_1 U17 ( .A(n7), .B(rx_elem_i[3]), .C(rx_elem_i[2]), 
        .Y(n15) );
  sky130_fd_sc_hd__nor2_1 U18 ( .A(rx_elem_i[1]), .B(rx_elem_i[2]), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U19 ( .A(rx_elem_i[2]), .Y(n8) );
  sky130_fd_sc_hd__nor2_1 U20 ( .A(n9), .B(n8), .Y(n10) );
  sky130_fd_sc_hd__mux2i_1 U21 ( .A0(n11), .A1(n10), .S(trg_level_i[0]), .Y(
        n13) );
  sky130_fd_sc_hd__inv_1 U22 ( .A(rx_elem_i[3]), .Y(n12) );
  sky130_fd_sc_hd__nor3_1 U23 ( .A(n13), .B(rx_elem_i[0]), .C(n12), .Y(n14) );
  sky130_fd_sc_hd__mux2i_1 U24 ( .A0(n15), .A1(n14), .S(trg_level_i[1]), .Y(
        n16) );
  sky130_fd_sc_hd__nor4_1 U25 ( .A(rx_elem_i[6]), .B(rx_elem_i[5]), .C(
        rx_elem_i[4]), .D(n16), .Y(n17) );
  sky130_fd_sc_hd__o31ai_1 U26 ( .A1(cti_i), .A2(thre_i), .A3(n17), .B1(
        irq_en_i[0]), .Y(n25) );
  sky130_fd_sc_hd__nand4_1 U27 ( .A(n18), .B(ip_o[2]), .C(n22), .D(n25), .Y(
        n19) );
  sky130_fd_sc_hd__o21ai_1 U28 ( .A1(clr_int_i), .A2(n20), .B1(n19), .Y(
        s_ip_d[2]) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n25), .B(ip_o[1]), .Y(n21) );
  sky130_fd_sc_hd__a21oi_1 U30 ( .A1(n21), .A2(n22), .B1(n23), .Y(s_ip_d[1])
         );
  sky130_fd_sc_hd__inv_1 U31 ( .A(ip_o[0]), .Y(n26) );
  sky130_fd_sc_hd__a211oi_1 U32 ( .A1(n25), .A2(n26), .B1(n24), .C1(n23), .Y(
        s_ip_d[0]) );
  sky130_fd_sc_hd__inv_1 U33 ( .A(ip_o[1]), .Y(n28) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(ip_o[2]), .Y(n27) );
endmodule


module apb4_uart ( apb4_pclk, apb4_presetn, apb4_paddr, apb4_pprot, apb4_psel, 
        apb4_penable, apb4_pwrite, apb4_pwdata, apb4_pstrb, apb4_pready, 
        apb4_prdata, apb4_pslverr, uart_uart_rx_i, uart_uart_tx_o, uart_irq_o
 );
  input [31:0] apb4_paddr;
  input [2:0] apb4_pprot;
  input [31:0] apb4_pwdata;
  input [3:0] apb4_pstrb;
  output [31:0] apb4_prdata;
  input apb4_pclk, apb4_presetn, apb4_psel, apb4_penable, apb4_pwrite,
         uart_uart_rx_i;
  output apb4_pready, apb4_pslverr, uart_uart_tx_o, uart_irq_o;
  wire   N19, s_rx_pop_valid, s_tx_pop_ready, s_rx_pop_ready, s_clr_int,
         s_tx_pop_valid, s_rx_push_valid, s_rx_push_ready, s_parity_err, n35,
         n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49,
         n50, n51, n52, n53, n54, apb4_pslverr, n56, n57, n58, n59, n60, n61,
         n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75,
         n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92;
  wire   [8:0] s_uart_lcr_d;
  wire   [8:0] s_uart_lcr_q;
  wire   [15:0] s_uart_div_d;
  wire   [15:0] s_uart_div_q;
  wire   [7:0] s_tx_push_data;
  wire   [3:0] s_uart_fcr_d;
  wire   [3:0] s_uart_fcr_q;
  wire   [6:0] s_uart_lsr_d;
  wire   [7:0] s_rx_pop_data;
  wire   [6:0] s_tx_elem;
  wire   [6:0] s_uart_lsr_q;
  wire   [7:0] s_tx_pop_data;
  wire   [6:0] s_rx_elem;
  wire   [7:0] s_rx_push_data;
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

  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_7_ ( .GATE(N19), .D(
        apb4_pwdata[7]), .Q(s_tx_push_data[7]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_6_ ( .GATE(N19), .D(
        apb4_pwdata[6]), .Q(s_tx_push_data[6]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_5_ ( .GATE(N19), .D(
        apb4_pwdata[5]), .Q(s_tx_push_data[5]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_4_ ( .GATE(N19), .D(
        apb4_pwdata[4]), .Q(s_tx_push_data[4]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_3_ ( .GATE(N19), .D(
        apb4_pwdata[3]), .Q(s_tx_push_data[3]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_2_ ( .GATE(N19), .D(
        apb4_pwdata[2]), .Q(s_tx_push_data[2]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_1_ ( .GATE(N19), .D(
        apb4_pwdata[1]), .Q(s_tx_push_data[1]) );
  sky130_fd_sc_hd__dlxtp_1 s_tx_push_data_reg_0_ ( .GATE(N19), .D(
        apb4_pwdata[0]), .Q(s_tx_push_data[0]) );
  sky130_fd_sc_hd__nand4b_1 U75 ( .A_N(apb4_paddr[4]), .B(apb4_paddr[3]), .C(
        apb4_paddr[2]), .D(n37), .Y(n38) );
  sky130_fd_sc_hd__a22o_1 U76 ( .A1(n39), .A2(s_uart_div_q[9]), .B1(
        apb4_pwdata[9]), .B2(n80), .X(s_uart_div_d[9]) );
  sky130_fd_sc_hd__a22o_1 U77 ( .A1(n39), .A2(s_uart_div_q[15]), .B1(
        apb4_pwdata[15]), .B2(n80), .X(s_uart_div_d[15]) );
  sky130_fd_sc_hd__a22o_1 U78 ( .A1(n39), .A2(s_uart_div_q[14]), .B1(
        apb4_pwdata[14]), .B2(n80), .X(s_uart_div_d[14]) );
  sky130_fd_sc_hd__a22o_1 U79 ( .A1(n39), .A2(s_uart_div_q[13]), .B1(
        apb4_pwdata[13]), .B2(n80), .X(s_uart_div_d[13]) );
  sky130_fd_sc_hd__a22o_1 U80 ( .A1(n39), .A2(s_uart_div_q[12]), .B1(
        apb4_pwdata[12]), .B2(n80), .X(s_uart_div_d[12]) );
  sky130_fd_sc_hd__a22o_1 U81 ( .A1(n39), .A2(s_uart_div_q[11]), .B1(
        apb4_pwdata[11]), .B2(n80), .X(s_uart_div_d[11]) );
  sky130_fd_sc_hd__a22o_1 U82 ( .A1(n39), .A2(s_uart_div_q[10]), .B1(
        apb4_pwdata[10]), .B2(n80), .X(s_uart_div_d[10]) );
  sky130_fd_sc_hd__nor2b_1 U85 ( .B_N(s_uart_div_q[9]), .A(n42), .Y(
        apb4_prdata[9]) );
  sky130_fd_sc_hd__nand2_1 U86 ( .A(s_rx_pop_data[7]), .B(s_rx_pop_ready), .Y(
        n44) );
  sky130_fd_sc_hd__a221o_1 U87 ( .A1(s_uart_lsr_q[6]), .A2(s_clr_int), .B1(
        s_rx_pop_data[6]), .B2(s_rx_pop_ready), .C1(n45), .X(apb4_prdata[6])
         );
  sky130_fd_sc_hd__a221o_1 U88 ( .A1(s_uart_lsr_q[5]), .A2(s_clr_int), .B1(
        s_rx_pop_data[5]), .B2(s_rx_pop_ready), .C1(n46), .X(apb4_prdata[5])
         );
  sky130_fd_sc_hd__a221o_1 U89 ( .A1(s_uart_lsr_q[4]), .A2(s_clr_int), .B1(
        s_rx_pop_data[4]), .B2(s_rx_pop_ready), .C1(n47), .X(apb4_prdata[4])
         );
  sky130_fd_sc_hd__a221o_1 U90 ( .A1(s_uart_lsr_q[3]), .A2(s_clr_int), .B1(
        s_rx_pop_data[3]), .B2(s_rx_pop_ready), .C1(n48), .X(apb4_prdata[3])
         );
  sky130_fd_sc_hd__a221o_1 U91 ( .A1(s_uart_lsr_q[2]), .A2(s_clr_int), .B1(
        s_rx_pop_data[2]), .B2(s_rx_pop_ready), .C1(n49), .X(apb4_prdata[2])
         );
  sky130_fd_sc_hd__a221o_1 U92 ( .A1(s_uart_lsr_q[1]), .A2(s_clr_int), .B1(
        s_rx_pop_data[1]), .B2(s_rx_pop_ready), .C1(n50), .X(apb4_prdata[1])
         );
  sky130_fd_sc_hd__nor2b_1 U93 ( .B_N(s_uart_div_q[15]), .A(n42), .Y(
        apb4_prdata[15]) );
  sky130_fd_sc_hd__nor2b_1 U94 ( .B_N(s_uart_div_q[14]), .A(n42), .Y(
        apb4_prdata[14]) );
  sky130_fd_sc_hd__nor2b_1 U95 ( .B_N(s_uart_div_q[13]), .A(n42), .Y(
        apb4_prdata[13]) );
  sky130_fd_sc_hd__nor2b_1 U96 ( .B_N(s_uart_div_q[12]), .A(n42), .Y(
        apb4_prdata[12]) );
  sky130_fd_sc_hd__nor2b_1 U97 ( .B_N(s_uart_div_q[11]), .A(n42), .Y(
        apb4_prdata[11]) );
  sky130_fd_sc_hd__nor2b_1 U98 ( .B_N(s_uart_div_q[10]), .A(n42), .Y(
        apb4_prdata[10]) );
  sky130_fd_sc_hd__a221o_1 U99 ( .A1(s_uart_lsr_q[0]), .A2(s_clr_int), .B1(
        s_rx_pop_data[0]), .B2(s_rx_pop_ready), .C1(n51), .X(apb4_prdata[0])
         );
  sky130_fd_sc_hd__and4_1 U103 ( .A(apb4_paddr[4]), .B(n52), .C(n83), .D(n82), 
        .X(s_clr_int) );
  sky130_fd_sc_hd__and4b_1 U105 ( .B(apb4_pwrite), .C(apb4_psel), .D(
        apb4_penable), .A_N(apb4_paddr[5]), .X(n37) );
  dffr_DATA_WIDTH9 u_uart_lcr_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_uart_lcr_d), .dat_o(s_uart_lcr_q) );
  dffrc_16_0002 u_uart_div_dffrc ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_uart_div_d), .dat_o(s_uart_div_q) );
  dffr_DATA_WIDTH4 u_uart_fcr_dffr ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i(s_uart_fcr_d), .dat_o(s_uart_fcr_q) );
  dffrc_7_60 u_uart_lsr_dffrc ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .dat_i({s_uart_lsr_d[6], n54, s_uart_lsr_d[4], n59, s_uart_lsr_d[2:0]}), .dat_o(s_uart_lsr_q) );
  fifo_DATA_WIDTH8_BUFFER_DEPTH64 u_tx_fifo ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .flush_i(s_uart_fcr_q[1]), .empty_o(s_tx_pop_valid), 
        .cnt_o(s_tx_elem), .dat_i(s_tx_push_data), .push_i(N19), .dat_o(
        s_tx_pop_data), .pop_i(s_tx_pop_ready) );
  uart_tx u_uart_tx ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .tx_o(
        uart_uart_tx_o), .cfg_en_i(apb4_pready), .cfg_div_i(s_uart_div_q), 
        .cfg_parity_en_i(s_uart_lcr_q[6]), .cfg_bits_i(s_uart_lcr_q[4:3]), 
        .cfg_stop_bits_i(s_uart_lcr_q[5]), .tx_data_i(s_tx_pop_data), 
        .tx_valid_i(n61), .tx_ready_o(s_tx_pop_ready) );
  fifo_DATA_WIDTH9_BUFFER_DEPTH64 u_rx_fifo ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .flush_i(s_uart_fcr_q[0]), .full_o(s_rx_push_ready), 
        .empty_o(s_rx_pop_valid), .cnt_o(s_rx_elem), .dat_i({s_parity_err, 
        s_rx_push_data}), .push_i(s_rx_push_valid), .dat_o({s_uart_lsr_d[4], 
        s_rx_pop_data}), .pop_i(s_rx_pop_ready) );
  uart_rx u_uart_rx ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .rx_i(
        uart_uart_rx_i), .cfg_en_i(apb4_pready), .cfg_div_i(s_uart_div_q), 
        .cfg_parity_en_i(s_uart_lcr_q[6]), .cfg_bits_i({n58, n56}), .err_o(
        s_parity_err), .err_clr_i(apb4_pready), .rx_data_o(s_rx_push_data), 
        .rx_valid_o(s_rx_push_valid), .rx_ready_i(n60) );
  uart_irq_FIFO_DEPTH64 u_uart_irq ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .clr_int_i(s_clr_int), .irq_en_i(s_uart_lcr_q[2:0]), .thre_i(
        s_uart_lsr_q[5]), .cti_i(apb4_pslverr), .pe_i(s_uart_lsr_q[4]), 
        .rx_elem_i(s_rx_elem), .tx_elem_i(s_tx_elem), .trg_level_i(
        s_uart_fcr_q[3:2]), .ip_o(s_uart_lsr_d[2:0]), .irq_o(uart_irq_o) );
  sky130_fd_sc_hd__and2_2 U106 ( .A(s_tx_pop_ready), .B(n54), .X(
        s_uart_lsr_d[6]) );
  sky130_fd_sc_hd__inv_1 U107 ( .A(s_uart_div_q[1]), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U108 ( .A(s_uart_div_q[0]), .Y(n70) );
  sky130_fd_sc_hd__inv_2 U109 ( .A(s_uart_div_q[2]), .Y(n68) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(s_uart_div_q[3]), .Y(n67) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(s_uart_div_q[4]), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U112 ( .A(s_uart_div_q[5]), .Y(n65) );
  sky130_fd_sc_hd__inv_2 U113 ( .A(s_uart_div_q[6]), .Y(n64) );
  sky130_fd_sc_hd__inv_2 U114 ( .A(s_uart_div_q[7]), .Y(n63) );
  sky130_fd_sc_hd__inv_2 U115 ( .A(s_uart_lcr_q[0]), .Y(n79) );
  sky130_fd_sc_hd__inv_2 U116 ( .A(s_uart_lcr_q[1]), .Y(n78) );
  sky130_fd_sc_hd__inv_2 U117 ( .A(s_uart_lcr_q[2]), .Y(n77) );
  sky130_fd_sc_hd__inv_2 U118 ( .A(n58), .Y(n75) );
  sky130_fd_sc_hd__inv_2 U119 ( .A(s_uart_lcr_q[5]), .Y(n74) );
  sky130_fd_sc_hd__inv_2 U120 ( .A(s_uart_lcr_q[6]), .Y(n73) );
  sky130_fd_sc_hd__inv_2 U121 ( .A(s_uart_lcr_q[7]), .Y(n72) );
  sky130_fd_sc_hd__inv_2 U122 ( .A(apb4_paddr[2]), .Y(n83) );
  sky130_fd_sc_hd__nor4bb_1 U123 ( .C_N(apb4_psel), .D_N(apb4_penable), .A(
        apb4_paddr[5]), .B(apb4_pwrite), .Y(n52) );
  sky130_fd_sc_hd__nor3_1 U124 ( .A(apb4_paddr[3]), .B(apb4_paddr[4]), .C(n83), 
        .Y(n40) );
  sky130_fd_sc_hd__nor3_1 U125 ( .A(apb4_paddr[3]), .B(apb4_paddr[4]), .C(
        apb4_paddr[2]), .Y(n36) );
  sky130_fd_sc_hd__inv_2 U126 ( .A(apb4_paddr[3]), .Y(n82) );
  sky130_fd_sc_hd__and2_1 U127 ( .A(n52), .B(n53), .X(s_rx_pop_ready) );
  sky130_fd_sc_hd__nand2_1 U128 ( .A(n52), .B(n36), .Y(n43) );
  sky130_fd_sc_hd__nand2_1 U129 ( .A(n52), .B(n40), .Y(n42) );
  sky130_fd_sc_hd__inv_2 U130 ( .A(s_uart_div_q[8]), .Y(n62) );
  sky130_fd_sc_hd__nand2_1 U131 ( .A(n40), .B(n37), .Y(n39) );
  sky130_fd_sc_hd__inv_2 U132 ( .A(n39), .Y(n80) );
  sky130_fd_sc_hd__inv_2 U133 ( .A(apb4_pwdata[3]), .Y(n89) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(apb4_pwdata[0]), .Y(n92) );
  sky130_fd_sc_hd__inv_2 U135 ( .A(apb4_pwdata[1]), .Y(n91) );
  sky130_fd_sc_hd__inv_2 U136 ( .A(apb4_pwdata[2]), .Y(n90) );
  sky130_fd_sc_hd__inv_2 U137 ( .A(apb4_pwdata[4]), .Y(n88) );
  sky130_fd_sc_hd__inv_2 U138 ( .A(apb4_pwdata[5]), .Y(n87) );
  sky130_fd_sc_hd__inv_2 U139 ( .A(apb4_pwdata[6]), .Y(n86) );
  sky130_fd_sc_hd__inv_2 U140 ( .A(apb4_pwdata[7]), .Y(n85) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(s_uart_lcr_q[8]), .Y(n71) );
  sky130_fd_sc_hd__nand2_1 U142 ( .A(n36), .B(n37), .Y(n35) );
  sky130_fd_sc_hd__inv_2 U143 ( .A(n35), .Y(n81) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(apb4_pwdata[8]), .Y(n84) );
  sky130_fd_sc_hd__nor3_1 U145 ( .A(apb4_paddr[2]), .B(apb4_paddr[4]), .C(n82), 
        .Y(n53) );
  sky130_fd_sc_hd__o22ai_1 U146 ( .A1(n70), .A2(n42), .B1(n79), .B2(n43), .Y(
        n51) );
  sky130_fd_sc_hd__o22ai_1 U147 ( .A1(n69), .A2(n42), .B1(n78), .B2(n43), .Y(
        n50) );
  sky130_fd_sc_hd__o22ai_1 U148 ( .A1(n68), .A2(n42), .B1(n77), .B2(n43), .Y(
        n49) );
  sky130_fd_sc_hd__o22ai_1 U149 ( .A1(n67), .A2(n42), .B1(n76), .B2(n43), .Y(
        n48) );
  sky130_fd_sc_hd__o22ai_1 U150 ( .A1(n66), .A2(n42), .B1(n75), .B2(n43), .Y(
        n47) );
  sky130_fd_sc_hd__o22ai_1 U151 ( .A1(n65), .A2(n42), .B1(n74), .B2(n43), .Y(
        n46) );
  sky130_fd_sc_hd__o22ai_1 U152 ( .A1(n64), .A2(n42), .B1(n73), .B2(n43), .Y(
        n45) );
  sky130_fd_sc_hd__o221ai_1 U153 ( .A1(n72), .A2(n43), .B1(n63), .B2(n42), 
        .C1(n44), .Y(apb4_prdata[7]) );
  sky130_fd_sc_hd__o22ai_1 U154 ( .A1(n62), .A2(n42), .B1(n71), .B2(n43), .Y(
        apb4_prdata[8]) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(s_rx_pop_valid), .Y(n59) );
  sky130_fd_sc_hd__o2bb2ai_1 U156 ( .B1(n92), .B2(n38), .A1_N(s_uart_fcr_q[0]), 
        .A2_N(n38), .Y(s_uart_fcr_d[0]) );
  sky130_fd_sc_hd__o2bb2ai_1 U157 ( .B1(n91), .B2(n38), .A1_N(s_uart_fcr_q[1]), 
        .A2_N(n38), .Y(s_uart_fcr_d[1]) );
  sky130_fd_sc_hd__o2bb2ai_1 U158 ( .B1(n90), .B2(n38), .A1_N(s_uart_fcr_q[2]), 
        .A2_N(n38), .Y(s_uart_fcr_d[2]) );
  sky130_fd_sc_hd__o2bb2ai_1 U159 ( .B1(n89), .B2(n38), .A1_N(s_uart_fcr_q[3]), 
        .A2_N(n38), .Y(s_uart_fcr_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U160 ( .A1(n91), .A2(n39), .B1(n80), .B2(n69), .Y(
        s_uart_div_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U161 ( .A1(n92), .A2(n39), .B1(n80), .B2(n70), .Y(
        s_uart_div_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U162 ( .A1(n90), .A2(n39), .B1(n80), .B2(n68), .Y(
        s_uart_div_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U163 ( .A1(n89), .A2(n39), .B1(n80), .B2(n67), .Y(
        s_uart_div_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U164 ( .A1(n88), .A2(n39), .B1(n80), .B2(n66), .Y(
        s_uart_div_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U165 ( .A1(n87), .A2(n39), .B1(n80), .B2(n65), .Y(
        s_uart_div_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U166 ( .A1(n86), .A2(n39), .B1(n80), .B2(n64), .Y(
        s_uart_div_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U167 ( .A1(n85), .A2(n39), .B1(n80), .B2(n63), .Y(
        s_uart_div_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U168 ( .A1(n84), .A2(n39), .B1(n80), .B2(n62), .Y(
        s_uart_div_d[8]) );
  sky130_fd_sc_hd__o22ai_1 U169 ( .A1(n35), .A2(n92), .B1(n81), .B2(n79), .Y(
        s_uart_lcr_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U170 ( .A1(n35), .A2(n91), .B1(n81), .B2(n78), .Y(
        s_uart_lcr_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U171 ( .A1(n35), .A2(n90), .B1(n81), .B2(n77), .Y(
        s_uart_lcr_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U172 ( .A1(n35), .A2(n88), .B1(n81), .B2(n75), .Y(
        s_uart_lcr_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U173 ( .A1(n35), .A2(n87), .B1(n81), .B2(n74), .Y(
        s_uart_lcr_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U174 ( .A1(n35), .A2(n86), .B1(n81), .B2(n73), .Y(
        s_uart_lcr_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U175 ( .A1(n35), .A2(n85), .B1(n81), .B2(n72), .Y(
        s_uart_lcr_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U176 ( .A1(n35), .A2(n84), .B1(n81), .B2(n71), .Y(
        s_uart_lcr_d[8]) );
  sky130_fd_sc_hd__and2_1 U177 ( .A(n53), .B(n37), .X(N19) );
  sky130_fd_sc_hd__inv_1 U178 ( .A(s_rx_push_ready), .Y(n60) );
  sky130_fd_sc_hd__or4_1 U179 ( .A(s_tx_elem[4]), .B(s_tx_elem[3]), .C(
        s_tx_elem[6]), .D(s_tx_elem[5]), .X(n41) );
  sky130_fd_sc_hd__inv_2 U180 ( .A(n76), .Y(n56) );
  sky130_fd_sc_hd__inv_1 U181 ( .A(s_uart_lcr_q[3]), .Y(n76) );
  sky130_fd_sc_hd__conb_1 U182 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__o22ai_1 U183 ( .A1(n35), .A2(n89), .B1(n81), .B2(n76), .Y(
        s_uart_lcr_d[3]) );
  sky130_fd_sc_hd__inv_2 U184 ( .A(s_tx_pop_valid), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U185 ( .A(s_uart_lcr_q[4]), .Y(n57) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(n57), .Y(n58) );
  sky130_fd_sc_hd__nor4_1 U187 ( .A(s_tx_elem[2]), .B(s_tx_elem[1]), .C(
        s_tx_elem[0]), .D(n41), .Y(n54) );
endmodule

