/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09-SP3a
// Date      : Tue Sep 30 13:34:26 2025
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
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfstp_2 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(dat_o[5]) );
endmodule


module dffr_DATA_WIDTH6_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [5:0] dat_i;
  output [5:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
endmodule


module dffr_DATA_WIDTH6_3 ( clk_i, rst_n_i, dat_i, dat_o );
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


module dffr_DATA_WIDTH7_0 ( clk_i, rst_n_i, dat_i, dat_o );
  input [6:0] dat_i;
  output [6:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
endmodule


module dffr_DATA_WIDTH512 ( clk_i, rst_n_i, dat_i, dat_o );
  input [511:0] dat_i;
  output [511:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54;

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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_502_ ( .D(dat_i[502]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[502]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_501_ ( .D(dat_i[501]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[501]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_500_ ( .D(dat_i[500]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[500]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_499_ ( .D(dat_i[499]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[499]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_498_ ( .D(dat_i[498]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[498]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_497_ ( .D(dat_i[497]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[497]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_496_ ( .D(dat_i[496]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[496]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_486_ ( .D(dat_i[486]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[486]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_485_ ( .D(dat_i[485]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[485]) );
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
        .RESET_B(n18), .Q(dat_o[472]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_462_ ( .D(dat_i[462]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[462]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_461_ ( .D(dat_i[461]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[461]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_460_ ( .D(dat_i[460]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[460]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_459_ ( .D(dat_i[459]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[459]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_458_ ( .D(dat_i[458]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[458]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_457_ ( .D(dat_i[457]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[457]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_456_ ( .D(dat_i[456]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[456]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_446_ ( .D(dat_i[446]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[446]) );
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
        .RESET_B(n21), .Q(dat_o[433]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_432_ ( .D(dat_i[432]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[432]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_422_ ( .D(dat_i[422]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[422]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_421_ ( .D(dat_i[421]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[421]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_420_ ( .D(dat_i[420]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[420]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_419_ ( .D(dat_i[419]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[419]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_418_ ( .D(dat_i[418]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[418]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_417_ ( .D(dat_i[417]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[417]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_416_ ( .D(dat_i[416]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[416]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_398_ ( .D(dat_i[398]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[398]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_397_ ( .D(dat_i[397]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[397]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_396_ ( .D(dat_i[396]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[396]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_395_ ( .D(dat_i[395]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[395]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_394_ ( .D(dat_i[394]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[394]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_393_ ( .D(dat_i[393]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[393]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_392_ ( .D(dat_i[392]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[392]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_382_ ( .D(dat_i[382]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[382]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_381_ ( .D(dat_i[381]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[381]) );
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
        .RESET_B(n26), .Q(dat_o[368]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_358_ ( .D(dat_i[358]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[358]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_357_ ( .D(dat_i[357]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[357]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_356_ ( .D(dat_i[356]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[356]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_355_ ( .D(dat_i[355]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[355]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_354_ ( .D(dat_i[354]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[354]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_353_ ( .D(dat_i[353]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[353]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_352_ ( .D(dat_i[352]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[352]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_342_ ( .D(dat_i[342]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[342]) );
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
        .RESET_B(n29), .Q(dat_o[329]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_328_ ( .D(dat_i[328]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[328]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_318_ ( .D(dat_i[318]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[318]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_317_ ( .D(dat_i[317]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[317]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_316_ ( .D(dat_i[316]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[316]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_315_ ( .D(dat_i[315]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[315]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_314_ ( .D(dat_i[314]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[314]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_313_ ( .D(dat_i[313]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[313]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_312_ ( .D(dat_i[312]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[312]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_294_ ( .D(dat_i[294]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[294]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_293_ ( .D(dat_i[293]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[293]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_292_ ( .D(dat_i[292]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[292]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_291_ ( .D(dat_i[291]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[291]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_290_ ( .D(dat_i[290]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[290]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_289_ ( .D(dat_i[289]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[289]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_288_ ( .D(dat_i[288]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[288]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_278_ ( .D(dat_i[278]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[278]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_277_ ( .D(dat_i[277]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[277]) );
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
        .RESET_B(n34), .Q(dat_o[264]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_254_ ( .D(dat_i[254]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[254]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_253_ ( .D(dat_i[253]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[253]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_252_ ( .D(dat_i[252]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[252]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_251_ ( .D(dat_i[251]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[251]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_250_ ( .D(dat_i[250]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[250]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_249_ ( .D(dat_i[249]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[249]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_248_ ( .D(dat_i[248]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[248]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_238_ ( .D(dat_i[238]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[238]) );
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
        .RESET_B(n37), .Q(dat_o[225]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_224_ ( .D(dat_i[224]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[224]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_214_ ( .D(dat_i[214]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[214]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_213_ ( .D(dat_i[213]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[213]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_212_ ( .D(dat_i[212]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[212]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_211_ ( .D(dat_i[211]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[211]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_210_ ( .D(dat_i[210]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[210]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_209_ ( .D(dat_i[209]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[209]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_208_ ( .D(dat_i[208]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[208]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_190_ ( .D(dat_i[190]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[190]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_189_ ( .D(dat_i[189]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[189]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_188_ ( .D(dat_i[188]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[188]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_187_ ( .D(dat_i[187]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[187]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_186_ ( .D(dat_i[186]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[186]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_185_ ( .D(dat_i[185]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[185]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_184_ ( .D(dat_i[184]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[184]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_174_ ( .D(dat_i[174]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[174]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_173_ ( .D(dat_i[173]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[173]) );
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
        .RESET_B(n42), .Q(dat_o[160]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_150_ ( .D(dat_i[150]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[150]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_149_ ( .D(dat_i[149]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[149]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_148_ ( .D(dat_i[148]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[148]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_147_ ( .D(dat_i[147]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[147]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_146_ ( .D(dat_i[146]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[146]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_145_ ( .D(dat_i[145]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[145]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_144_ ( .D(dat_i[144]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[144]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_134_ ( .D(dat_i[134]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[134]) );
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
        .RESET_B(n45), .Q(dat_o[121]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_120_ ( .D(dat_i[120]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[120]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_110_ ( .D(dat_i[110]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[110]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_109_ ( .D(dat_i[109]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[109]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_108_ ( .D(dat_i[108]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[108]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_107_ ( .D(dat_i[107]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[107]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_106_ ( .D(dat_i[106]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[106]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_105_ ( .D(dat_i[105]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[105]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_104_ ( .D(dat_i[104]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[104]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_86_ ( .D(dat_i[86]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[86]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_85_ ( .D(dat_i[85]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[85]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_84_ ( .D(dat_i[84]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[84]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_83_ ( .D(dat_i[83]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[83]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_82_ ( .D(dat_i[82]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[82]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_81_ ( .D(dat_i[81]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[81]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_80_ ( .D(dat_i[80]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[80]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_70_ ( .D(dat_i[70]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[70]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_69_ ( .D(dat_i[69]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[69]) );
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
        .RESET_B(n50), .Q(dat_o[56]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[40]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[30]) );
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
        .RESET_B(n53), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[16]) );
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
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n54), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n54), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n54), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n54), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        n54), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n53), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_95_ ( .D(dat_i[95]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[95]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_87_ ( .D(dat_i[87]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[87]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_79_ ( .D(dat_i[79]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[79]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_71_ ( .D(dat_i[71]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[71]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_479_ ( .D(dat_i[479]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[479]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_415_ ( .D(dat_i[415]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[415]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_351_ ( .D(dat_i[351]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[351]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_287_ ( .D(dat_i[287]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[287]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_223_ ( .D(dat_i[223]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[223]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_159_ ( .D(dat_i[159]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[159]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_447_ ( .D(dat_i[447]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[447]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_383_ ( .D(dat_i[383]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[383]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_319_ ( .D(dat_i[319]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[319]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_255_ ( .D(dat_i[255]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[255]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_191_ ( .D(dat_i[191]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[191]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_127_ ( .D(dat_i[127]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[127]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_487_ ( .D(dat_i[487]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[487]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_423_ ( .D(dat_i[423]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[423]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_359_ ( .D(dat_i[359]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[359]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_295_ ( .D(dat_i[295]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[295]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_231_ ( .D(dat_i[231]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[231]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_167_ ( .D(dat_i[167]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[167]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_103_ ( .D(dat_i[103]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[103]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_471_ ( .D(dat_i[471]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[471]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_463_ ( .D(dat_i[463]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[463]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_455_ ( .D(dat_i[455]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[455]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_407_ ( .D(dat_i[407]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[407]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_399_ ( .D(dat_i[399]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[399]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_391_ ( .D(dat_i[391]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[391]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_343_ ( .D(dat_i[343]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[343]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_335_ ( .D(dat_i[335]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[335]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_327_ ( .D(dat_i[327]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[327]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_279_ ( .D(dat_i[279]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[279]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_271_ ( .D(dat_i[271]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[271]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_263_ ( .D(dat_i[263]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[263]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_215_ ( .D(dat_i[215]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[215]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_207_ ( .D(dat_i[207]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[207]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_199_ ( .D(dat_i[199]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[199]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_151_ ( .D(dat_i[151]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[151]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_143_ ( .D(dat_i[143]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[143]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_135_ ( .D(dat_i[135]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[135]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_503_ ( .D(dat_i[503]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[503]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_439_ ( .D(dat_i[439]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[439]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_375_ ( .D(dat_i[375]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[375]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_311_ ( .D(dat_i[311]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[311]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_247_ ( .D(dat_i[247]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[247]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_183_ ( .D(dat_i[183]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[183]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_119_ ( .D(dat_i[119]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[119]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_495_ ( .D(dat_i[495]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[495]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_431_ ( .D(dat_i[431]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[431]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_367_ ( .D(dat_i[367]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[367]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_303_ ( .D(dat_i[303]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[303]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_239_ ( .D(dat_i[239]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[239]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_175_ ( .D(dat_i[175]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[175]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_111_ ( .D(dat_i[111]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[111]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_511_ ( .D(dat_i[511]), .CLK(clk_i), 
        .RESET_B(n15), .Q(dat_o[511]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(n13), .X(n53) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(n13), .X(n52) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(n13), .X(n51) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(n12), .X(n50) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(n12), .X(n49) );
  sky130_fd_sc_hd__buf_1 U8 ( .A(n12), .X(n48) );
  sky130_fd_sc_hd__buf_1 U9 ( .A(n11), .X(n47) );
  sky130_fd_sc_hd__buf_1 U10 ( .A(n11), .X(n46) );
  sky130_fd_sc_hd__buf_1 U11 ( .A(n11), .X(n45) );
  sky130_fd_sc_hd__buf_1 U12 ( .A(n10), .X(n44) );
  sky130_fd_sc_hd__buf_1 U13 ( .A(n10), .X(n43) );
  sky130_fd_sc_hd__buf_1 U14 ( .A(n10), .X(n42) );
  sky130_fd_sc_hd__buf_1 U15 ( .A(n9), .X(n41) );
  sky130_fd_sc_hd__buf_1 U16 ( .A(n9), .X(n40) );
  sky130_fd_sc_hd__buf_1 U17 ( .A(n9), .X(n39) );
  sky130_fd_sc_hd__buf_1 U18 ( .A(n8), .X(n38) );
  sky130_fd_sc_hd__buf_1 U19 ( .A(n8), .X(n37) );
  sky130_fd_sc_hd__buf_1 U20 ( .A(n8), .X(n36) );
  sky130_fd_sc_hd__buf_1 U21 ( .A(n7), .X(n35) );
  sky130_fd_sc_hd__buf_1 U22 ( .A(n7), .X(n34) );
  sky130_fd_sc_hd__buf_1 U23 ( .A(n7), .X(n33) );
  sky130_fd_sc_hd__buf_1 U24 ( .A(n6), .X(n32) );
  sky130_fd_sc_hd__buf_1 U25 ( .A(n6), .X(n31) );
  sky130_fd_sc_hd__buf_1 U26 ( .A(n6), .X(n30) );
  sky130_fd_sc_hd__buf_1 U27 ( .A(n5), .X(n29) );
  sky130_fd_sc_hd__buf_1 U28 ( .A(n5), .X(n28) );
  sky130_fd_sc_hd__buf_1 U29 ( .A(n5), .X(n27) );
  sky130_fd_sc_hd__buf_1 U30 ( .A(n4), .X(n26) );
  sky130_fd_sc_hd__buf_1 U31 ( .A(n4), .X(n25) );
  sky130_fd_sc_hd__buf_1 U32 ( .A(n4), .X(n24) );
  sky130_fd_sc_hd__buf_1 U33 ( .A(n3), .X(n23) );
  sky130_fd_sc_hd__buf_1 U34 ( .A(n3), .X(n22) );
  sky130_fd_sc_hd__buf_1 U35 ( .A(n3), .X(n21) );
  sky130_fd_sc_hd__buf_1 U36 ( .A(n2), .X(n20) );
  sky130_fd_sc_hd__buf_1 U37 ( .A(n2), .X(n19) );
  sky130_fd_sc_hd__buf_1 U38 ( .A(n2), .X(n18) );
  sky130_fd_sc_hd__buf_1 U39 ( .A(n1), .X(n17) );
  sky130_fd_sc_hd__buf_1 U40 ( .A(n1), .X(n16) );
  sky130_fd_sc_hd__buf_1 U41 ( .A(n1), .X(n15) );
  sky130_fd_sc_hd__buf_1 U42 ( .A(n14), .X(n54) );
  sky130_fd_sc_hd__buf_1 U43 ( .A(rst_n_i), .X(n14) );
  sky130_fd_sc_hd__buf_1 U44 ( .A(rst_n_i), .X(n13) );
  sky130_fd_sc_hd__buf_1 U45 ( .A(rst_n_i), .X(n12) );
  sky130_fd_sc_hd__buf_1 U46 ( .A(rst_n_i), .X(n11) );
  sky130_fd_sc_hd__buf_1 U47 ( .A(rst_n_i), .X(n10) );
  sky130_fd_sc_hd__buf_1 U48 ( .A(rst_n_i), .X(n9) );
  sky130_fd_sc_hd__buf_1 U49 ( .A(rst_n_i), .X(n8) );
  sky130_fd_sc_hd__buf_1 U50 ( .A(rst_n_i), .X(n7) );
  sky130_fd_sc_hd__buf_1 U51 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__buf_1 U52 ( .A(rst_n_i), .X(n5) );
  sky130_fd_sc_hd__buf_1 U53 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U54 ( .A(rst_n_i), .X(n3) );
  sky130_fd_sc_hd__buf_1 U55 ( .A(rst_n_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U56 ( .A(rst_n_i), .X(n1) );
endmodule


module fifo_DATA_WIDTH8_BUFFER_DEPTH64_DW01_inc_3 ( A, SUM );
  input [6:0] A;
  output [6:0] SUM;
  wire   n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n14, n34;
  assign n2 = A[5];
  assign n7 = A[3];
  assign n12 = A[1];
  assign n14 = A[0];

  sky130_fd_sc_hd__xor2_1 U1 ( .A(A[6]), .B(n34), .X(SUM[6]) );
  sky130_fd_sc_hd__xnor2_1 U3 ( .A(n3), .B(n4), .Y(SUM[5]) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n6), .B(n5), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n5), .B(n6), .Y(n4) );
  sky130_fd_sc_hd__xnor2_1 U10 ( .A(n8), .B(n9), .Y(SUM[3]) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n9), .B(n7), .Y(n6) );
  sky130_fd_sc_hd__xor2_1 U14 ( .A(n11), .B(n10), .X(SUM[2]) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(n10), .B(n11), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n14), .B(n12), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U25 ( .A(A[2]), .Y(n10) );
  sky130_fd_sc_hd__and2_1 U26 ( .A(n4), .B(n2), .X(n34) );
  sky130_fd_sc_hd__xor2_1 U27 ( .A(n14), .B(n12), .X(SUM[1]) );
  sky130_fd_sc_hd__inv_1 U28 ( .A(n14), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(A[4]), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(n2), .Y(n3) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n7), .Y(n8) );
endmodule


module fifo_DATA_WIDTH8_BUFFER_DEPTH64 ( clk_i, rst_n_i, flush_i, full_o, 
        empty_o, cnt_o, dat_i, push_i, dat_o, pop_i );
  output [6:0] cnt_o;
  input [7:0] dat_i;
  output [7:0] dat_o;
  input clk_i, rst_n_i, flush_i, push_i, pop_i;
  output full_o, empty_o;
  wire   N75, N76, N77, N78, N79, N80, n1390, N85, N86, N87, N88, N89, N96,
         N97, N98, N99, N100, N108, N109, N110, N111, N112, N113, N114,
         \add_65/carry[5] , \add_65/carry[4] , \add_65/carry[3] ,
         \add_65/carry[2] , \add_50/carry[5] , \add_50/carry[4] ,
         \add_50/carry[3] , \add_50/carry[2] , n1, n2, n3, n4, n5, n6, n7, n8,
         n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22,
         n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50,
         n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79,
         n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136, n137, n138,
         n139, n140, n141, n142, n143, n144, n145, n146, n147, n148, n149,
         n150, n151, n152, n153, n154, n155, n156, n157, n158, n159, n160,
         n161, n162, n163, n164, n165, n166, n167, n168, n169, n170, n171,
         n172, n173, n174, n175, n176, n177, n178, n179, n180, n181, n182,
         n183, n184, n185, n186, n187, n188, n189, n190, n191, n192, n193,
         n194, n195, n196, n197, n198, n199, n200, n201, n202, n203, n204,
         n205, n206, n207, n208, n209, n210, n211, n212, n213, n214, n215,
         n216, n217, n218, n219, n220, n221, n222, n223, n224, n225, n226,
         n227, n228, n229, n230, n231, n232, n233, n234, n235, n236, n237,
         n238, n239, n240, n241, n242, n243, n244, n245, n246, n247, n248,
         n249, n250, n251, n252, n253, n254, n255, n256, n257, n258, n259,
         n260, n261, n262, n263, n264, n265, n266, n267, n268, n269, n270,
         n271, n272, n273, n274, n275, n276, n277, n278, n279, n280, n281,
         n282, n283, n284, n285, n286, n287, n288, n289, n290, n291, n292,
         n293, n294, n295, n296, n297, n298, n299, n300, n301, n302, n303,
         n304, n305, n306, n307, n308, n309, n310, n311, n312, n313, n314,
         n315, n316, n317, n318, n319, n320, n321, n322, n323, n324, n325,
         n326, n327, n328, n329, n330, n331, n332, n333, n334, n335, n336,
         n337, n338, n339, n340, n341, n342, n343, n344, n345, n346, n347,
         n348, n349, n350, n351, n352, n353, n354, n355, n356, n357, n358,
         n359, n360, n361, n362, n363, n364, n365, n366, n367, n368, n369,
         n370, n371, n372, n373, n374, n375, n376, n377, n378, n379, n380,
         n381, n382, n383, n384, n385, n386, n387, n388, n389, n390, n391,
         n392, n393, n394, n395, n396, n397, n398, n399, n400, n401, n402,
         n403, n404, n405, n406, n407, n408, n409, n410, n411, n412, n413,
         n414, n415, n416, n417, n418, n419, n420, n421, n422, n423, n424,
         n425, n426, n427, n428, n429, n430, n431, n432, n433, n434, n435,
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
         n623, n624, n625, n626, n627, n628, n629, n630, n631, n632, n633,
         n634, n635, n636, n637, n638, n639, n640, n641, n642, n643, n644,
         n645, n646, n647, n648, n649, n650, n651, n652, n653, n654, n655,
         n656, n657, n658, n659, n660, n661, n662, n663, n664, n665, n666,
         n667, n668, n669, n670, n671, n672, n673, n674, n675, n676, n677,
         n678, n679, n680, n681, n682, n683, n684, n685, n686, n687, n688,
         n689, n690, n691, n692, n693, n694, n695, n696, n697, n698, n699,
         n700, n701, n702, n703, n704, n705, n706, n707, n708, n709, n710,
         n711, n712, n713, n714, n715, n716, n717, n718, n719, n720, n721,
         n722, n723, n724, n725, n726, n727, n728, n729, n730, n731, n732,
         n733, n734, n735, n736, n737, n738, n739, n740, n741, n742, n743,
         n744, n745, n746, n747, n748, n749, n750, n751, n752, n753, n754,
         n755, n756, n757, n758, n759, n760, n761, n762, n763, n764, n765,
         n766, n767, n768, n769, n770, n771, n772, n773, n774, n775, n776,
         n777, n778, n779, n780, n781, n782, n783, n784, n785, n786, n787,
         n788, n789, n790, n791, n792, n793, n794, n795, n796, n797, n798,
         n799, n800, n801, n802, n803, n804, n805, n806, n807, n808, n809,
         n810, n811, n812, n813, n814, n815, n816, n817, n818, n819, n820,
         n821, n822, n823, n824, n825, n826, n827, n828, n829, n830, n831,
         n832, n833, n834, n835, n836, n837, n838, n839, n840, n841, n842,
         n843, n844, n845, n846, n847, n848, n849, n850, n851, n852, n853,
         n854, n855, n856, n857, n858, n859, n860, n861, n862, n863, n864,
         n865, n866, n867, n868, n869, n870, n871, n872, n873, n874, n875,
         n876, n877, n878, n879, n880, n881, n882, n883, n884, n885, n886,
         n887, n888, n889, n890, n891, n892, n893, n894, n895, n896, n897,
         n898, n899, n900, n901, n902, n903, n904, n905, n906, n907, n908,
         n909, n910, n911, n912, n913, n914, n915, n916, n917, n918, n919,
         n920, n921, n922, n923, n924, n925, n926, n927, n928, n929, n930,
         n931, n932, n933, n934, n935, n936, n937, n938, n939, n940, n941,
         n942, n943, n944, n945, n946, n947, n948, n949, n950, n951, n952,
         n953, n954, n955, n956, n957, n958, n959, n960, n961, n962, n963,
         n964, n965, n966, n967, n968, n969, n970, n971, n972, n973, n974,
         n975, n976, n977, n978, n979, n980, n981, n982, n983, n984, n985,
         n986, n987, n988, n989, n990, n991, n992, n993, n994, n995, n996,
         n997, n998, n999, n1000, n1001, n1002, n1003, n1004, n1005, n1006,
         n1007, n1008, n1009, n1010, n1011, n1012, n1013, n1014, n1015, n1016,
         n1017, n1018, n1019, n1020, n1021, n1022, n1023, n1024, n1025, n1026,
         n1027, n1028, n1029, n1030, n1031, n1032, n1033, n1034, n1035, n1036,
         n1037, n1038, n1039, n1040, n1041, n1042, n1043, n1044, n1045, n1046,
         n1047, n1048, n1049, n1050, n1051, n1052, n1053, n1054, n1055, n1056,
         n1057, n1058, n1059, n1060, n1061, n1062, n1063, n1064, n1065, n1066,
         n1067, n1068, n1069, n1070, n1071, n1072, n1073, n1074, n1075, n1076,
         n1077, n1078, n1079, n1080, n1081, n1082, n1083, n1084, n1085, n1086,
         n1087, n1088, n1089, n1090, n1091, n1092, n1093, n1094, n1095, n1096,
         n1097, n1098, n1099, n1100, n1101, n1102, n1103, n1104, n1105, n1106,
         n1107, n1108, n1109, n1110, n1111, n1112, n1113, n1114, n1115, n1116,
         n1117, n1118, n1119, n1120, n1121, n1122, n1123, n1124, n1125, n1126,
         n1127, n1128, n1129, n1130, n1131, n1132, n1133, n1134, n1135, n1136,
         n1137, n1138, n1139, n1140, n1141, n1142, n1143, n1144, n1145, n1146,
         n1147, n1148, n1149, n1150, n1151, n1152, n1153, n1154, n1155, n1156,
         n1157, n1158, n1159, n1160, n1161, n1162, n1163, n1164, n1165, n1166,
         n1167, n1168, n1169, n1170, n1171, n1172, n1173, n1174, n1175, n1176,
         n1177, n1178, n1179, n1180, n1181, n1182, n1183, n1184, n1185, n1186,
         n1187, n1188, n1189, n1190, n1191, n1192, n1193, n1194, n1195, n1196,
         n1197, n1198, n1199, n1200, n1201, n1202, n1203, n1204, n1205, n1206,
         n1207, n1208, n1209, n1210, n1211, n1212, n1213, n1214, n1215, n1216,
         n1217, n1218, n1219, n1220, n1221, n1222, n1223, n1224, n1225, n1226,
         n1227, n1228, n1229, n1230, n1231, n1232, n1233, n1234, n1235, n1236,
         n1237, n1238, n1239, n1240, n1241, n1242, n1243, n1244, n1245, n1246,
         n1247, n1248, n1249, n1250, n1251, n1252, n1253, n1254, n1255, n1256,
         n1257, n1258, n1259, n1260, n1261, n1262, n1263, n1264, n1265, n1266,
         n1267, n1268, n1269, n1270, n1271, n1272, n1273, n1274, n1275, n1276,
         n1277, n1278, n1279, n1280, n1281, n1282, n1283, n1284, n1285, n1286,
         n1287, n1288, n1289, n1290, n1291, n1292, n1293, n1294, n1295, n1296,
         n1297, n1298, n1299, n1300, n1301, n1302, n1303, n1304, n1305, n1306,
         n1307, n1308, n1309, n1310, n1311, n1312, n1313, n1314, n1315, n1316,
         n1317, n1318, n1319, n1320, n1321, n1322, n1323, n1324, n1325, n1326,
         n1327, n1328, n1329, n1330, n1331, n1332, n1333, n1334, n1335, n1336,
         n1337, n1338, n1339, n1340, n1341, n1342, n1343, n1344, n1345, n1346,
         n1347, n1348, n1349, n1350, n1351, n1352, n1353, n1354, n1355, n1356,
         n1357, n1358, n1359, n1360, n1361, n1362, n1363, n1364, n1365, n1366,
         n1367, n1368, n1369, n1370, n1371, n1372, n1373, n1374, n1375, n1376,
         n1377, n1378, n1379, n1380, n1381, n1382, n1383, n1384, n1385, n1386,
         n1387;
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
        s_cnt_d), .dat_o({cnt_o[6:4], n1390, cnt_o[2:0]}) );
  dffr_DATA_WIDTH512 u_mem_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_mem_d), .dat_o(s_mem_q) );
  fifo_DATA_WIDTH8_BUFFER_DEPTH64_DW01_inc_3 add_81 ( .A(cnt_o), .SUM({N114, 
        N113, N112, N111, N110, N109, N108}) );
  sky130_fd_sc_hd__inv_4 U3 ( .A(n1362), .Y(n576) );
  sky130_fd_sc_hd__nand2_4 U4 ( .A(dat_i[6]), .B(n644), .Y(n1362) );
  sky130_fd_sc_hd__clkinv_4 U5 ( .A(n576), .Y(n581) );
  sky130_fd_sc_hd__buf_6 U6 ( .A(n3), .X(n644) );
  sky130_fd_sc_hd__and2_4 U7 ( .A(n637), .B(n644), .X(n642) );
  sky130_fd_sc_hd__nand2_4 U8 ( .A(dat_i[0]), .B(n644), .Y(n99) );
  sky130_fd_sc_hd__and2_4 U9 ( .A(n819), .B(n644), .X(n151) );
  sky130_fd_sc_hd__and2_4 U10 ( .A(n809), .B(n644), .X(n152) );
  sky130_fd_sc_hd__and2_4 U11 ( .A(n799), .B(n644), .X(n153) );
  sky130_fd_sc_hd__and2_4 U12 ( .A(n871), .B(n644), .X(n146) );
  sky130_fd_sc_hd__and2_4 U13 ( .A(n789), .B(n644), .X(n154) );
  sky130_fd_sc_hd__clkbuf_1 U14 ( .A(n670), .X(n1) );
  sky130_fd_sc_hd__a2bb2o_1 U15 ( .A1_N(n697), .A2_N(n694), .B1(N86), .B2(n696), .X(s_rd_ptr_d[2]) );
  sky130_fd_sc_hd__clkinv_2 U16 ( .A(n97), .Y(n6) );
  sky130_fd_sc_hd__clkinv_2 U17 ( .A(n97), .Y(n9) );
  sky130_fd_sc_hd__nand2_2 U18 ( .A(n534), .B(n540), .Y(n539) );
  sky130_fd_sc_hd__inv_4 U19 ( .A(n539), .Y(n181) );
  sky130_fd_sc_hd__inv_4 U20 ( .A(n546), .Y(n186) );
  sky130_fd_sc_hd__nor2_2 U21 ( .A(n16), .B(full_o), .Y(n643) );
  sky130_fd_sc_hd__inv_2 U22 ( .A(n1193), .Y(n1260) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(n1111), .Y(n1182) );
  sky130_fd_sc_hd__clkbuf_1 U24 ( .A(n648), .X(n67) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(n1331), .Y(n1323) );
  sky130_fd_sc_hd__clkinv_1 U26 ( .A(n1281), .Y(n1273) );
  sky130_fd_sc_hd__clkinv_1 U27 ( .A(n1269), .Y(n1261) );
  sky130_fd_sc_hd__clkinv_1 U28 ( .A(n1258), .Y(n1250) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(n1248), .Y(n1240) );
  sky130_fd_sc_hd__inv_2 U30 ( .A(n1238), .Y(n1234) );
  sky130_fd_sc_hd__inv_2 U31 ( .A(n1232), .Y(n1224) );
  sky130_fd_sc_hd__inv_2 U32 ( .A(n1222), .Y(n1214) );
  sky130_fd_sc_hd__inv_2 U33 ( .A(n1212), .Y(n1204) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(n1202), .Y(n1194) );
  sky130_fd_sc_hd__clkinv_1 U35 ( .A(n1191), .Y(n1183) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(n1180), .Y(n1172) );
  sky130_fd_sc_hd__inv_1 U37 ( .A(n1170), .Y(n1162) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(n1160), .Y(n1152) );
  sky130_fd_sc_hd__inv_2 U39 ( .A(n1150), .Y(n1142) );
  sky130_fd_sc_hd__inv_2 U40 ( .A(n1140), .Y(n1132) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(n1130), .Y(n1122) );
  sky130_fd_sc_hd__inv_2 U42 ( .A(n1120), .Y(n1112) );
  sky130_fd_sc_hd__clkinv_1 U43 ( .A(n1109), .Y(n1101) );
  sky130_fd_sc_hd__inv_1 U44 ( .A(n1098), .Y(n1090) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(n1088), .Y(n1080) );
  sky130_fd_sc_hd__inv_2 U46 ( .A(n1078), .Y(n1074) );
  sky130_fd_sc_hd__inv_2 U47 ( .A(n1072), .Y(n1064) );
  sky130_fd_sc_hd__inv_2 U48 ( .A(n1062), .Y(n1054) );
  sky130_fd_sc_hd__inv_2 U49 ( .A(n1052), .Y(n1044) );
  sky130_fd_sc_hd__and2_1 U50 ( .A(n1035), .B(n646), .X(n112) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n1042), .Y(n1035) );
  sky130_fd_sc_hd__clkinv_1 U52 ( .A(n1032), .Y(n1024) );
  sky130_fd_sc_hd__inv_1 U53 ( .A(n1021), .Y(n1013) );
  sky130_fd_sc_hd__inv_1 U54 ( .A(n1011), .Y(n1003) );
  sky130_fd_sc_hd__inv_2 U55 ( .A(n1001), .Y(n993) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(n991), .Y(n983) );
  sky130_fd_sc_hd__inv_2 U57 ( .A(n981), .Y(n973) );
  sky130_fd_sc_hd__inv_2 U58 ( .A(n971), .Y(n963) );
  sky130_fd_sc_hd__inv_2 U59 ( .A(n961), .Y(n953) );
  sky130_fd_sc_hd__clkinv_1 U60 ( .A(n950), .Y(n942) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(n939), .Y(n931) );
  sky130_fd_sc_hd__inv_1 U62 ( .A(n929), .Y(n921) );
  sky130_fd_sc_hd__inv_2 U63 ( .A(n919), .Y(n911) );
  sky130_fd_sc_hd__inv_2 U64 ( .A(n909), .Y(n901) );
  sky130_fd_sc_hd__inv_2 U65 ( .A(n899), .Y(n891) );
  sky130_fd_sc_hd__inv_2 U66 ( .A(n889), .Y(n881) );
  sky130_fd_sc_hd__inv_2 U67 ( .A(n879), .Y(n871) );
  sky130_fd_sc_hd__clkinv_1 U68 ( .A(n868), .Y(n860) );
  sky130_fd_sc_hd__inv_1 U69 ( .A(n857), .Y(n849) );
  sky130_fd_sc_hd__inv_1 U70 ( .A(n847), .Y(n839) );
  sky130_fd_sc_hd__inv_2 U71 ( .A(n837), .Y(n829) );
  sky130_fd_sc_hd__inv_2 U72 ( .A(n827), .Y(n819) );
  sky130_fd_sc_hd__inv_2 U73 ( .A(n817), .Y(n809) );
  sky130_fd_sc_hd__inv_2 U74 ( .A(n807), .Y(n799) );
  sky130_fd_sc_hd__inv_2 U75 ( .A(n797), .Y(n789) );
  sky130_fd_sc_hd__clkinv_1 U76 ( .A(n786), .Y(n778) );
  sky130_fd_sc_hd__inv_1 U77 ( .A(n774), .Y(n766) );
  sky130_fd_sc_hd__inv_1 U78 ( .A(n763), .Y(n755) );
  sky130_fd_sc_hd__inv_2 U79 ( .A(n752), .Y(n744) );
  sky130_fd_sc_hd__inv_2 U80 ( .A(n741), .Y(n733) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n730), .Y(n722) );
  sky130_fd_sc_hd__inv_2 U82 ( .A(n719), .Y(n711) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n777), .B(n1272), .Y(n709) );
  sky130_fd_sc_hd__inv_2 U84 ( .A(n65), .Y(cnt_o[3]) );
  sky130_fd_sc_hd__inv_2 U85 ( .A(n32), .Y(n43) );
  sky130_fd_sc_hd__clkinv_1 U86 ( .A(n53), .Y(n57) );
  sky130_fd_sc_hd__clkinv_1 U87 ( .A(n53), .Y(n58) );
  sky130_fd_sc_hd__inv_2 U88 ( .A(N75), .Y(n4) );
  sky130_fd_sc_hd__inv_2 U89 ( .A(N76), .Y(n632) );
  sky130_fd_sc_hd__inv_1 U90 ( .A(n1372), .Y(n52) );
  sky130_fd_sc_hd__clkinv_1 U91 ( .A(n52), .Y(n56) );
  sky130_fd_sc_hd__clkinv_1 U92 ( .A(n52), .Y(n55) );
  sky130_fd_sc_hd__inv_2 U93 ( .A(n1390), .Y(n65) );
  sky130_fd_sc_hd__inv_2 U94 ( .A(N79), .Y(n508) );
  sky130_fd_sc_hd__buf_6 U95 ( .A(n639), .X(n657) );
  sky130_fd_sc_hd__nand2_2 U96 ( .A(dat_i[0]), .B(n646), .Y(n639) );
  sky130_fd_sc_hd__clkbuf_1 U97 ( .A(n181), .X(n567) );
  sky130_fd_sc_hd__buf_6 U98 ( .A(n181), .X(n568) );
  sky130_fd_sc_hd__inv_1 U99 ( .A(n634), .Y(n2) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(n1385), .Y(n1382) );
  sky130_fd_sc_hd__mux2i_1 U101 ( .A0(n678), .A1(n674), .S(n65), .Y(n675) );
  sky130_fd_sc_hd__nor2_1 U102 ( .A(n16), .B(full_o), .Y(n3) );
  sky130_fd_sc_hd__nand2_2 U103 ( .A(n696), .B(n1377), .Y(n631) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(n689), .Y(n672) );
  sky130_fd_sc_hd__a2bb2o_2 U105 ( .A1_N(n697), .A2_N(n692), .B1(n692), .B2(
        n696), .X(s_rd_ptr_d[0]) );
  sky130_fd_sc_hd__a2bb2o_2 U106 ( .A1_N(n697), .A2_N(n693), .B1(N85), .B2(
        n696), .X(s_rd_ptr_d[1]) );
  sky130_fd_sc_hd__ha_2 U107 ( .A(N79), .B(\add_50/carry[4] ), .COUT(
        \add_50/carry[5] ), .SUM(N88) );
  sky130_fd_sc_hd__nor2_2 U108 ( .A(n4), .B(n632), .Y(n164) );
  sky130_fd_sc_hd__o2bb2ai_1 U109 ( .B1(n5), .B2(n6), .A1_N(n194), .A2_N(
        s_mem_q[84]), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U110 ( .A(s_mem_q[92]), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U111 ( .A(n7), .Y(n380) );
  sky130_fd_sc_hd__o2bb2ai_1 U112 ( .B1(n8), .B2(n9), .A1_N(n30), .A2_N(
        s_mem_q[82]), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U113 ( .A(s_mem_q[90]), .Y(n8) );
  sky130_fd_sc_hd__inv_1 U114 ( .A(n10), .Y(n292) );
  sky130_fd_sc_hd__o2bb2ai_1 U115 ( .B1(n11), .B2(n6), .A1_N(n30), .A2_N(
        s_mem_q[83]), .Y(n12) );
  sky130_fd_sc_hd__inv_2 U116 ( .A(s_mem_q[91]), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U117 ( .A(n12), .Y(n336) );
  sky130_fd_sc_hd__o2bb2ai_1 U118 ( .B1(n13), .B2(n9), .A1_N(n194), .A2_N(
        s_mem_q[81]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U119 ( .A(s_mem_q[89]), .Y(n13) );
  sky130_fd_sc_hd__inv_1 U120 ( .A(n14), .Y(n248) );
  sky130_fd_sc_hd__a22oi_1 U121 ( .A1(n100), .A2(s_mem_q[124]), .B1(n191), 
        .B2(s_mem_q[116]), .Y(n382) );
  sky130_fd_sc_hd__a22oi_1 U122 ( .A1(n100), .A2(s_mem_q[123]), .B1(n191), 
        .B2(s_mem_q[115]), .Y(n338) );
  sky130_fd_sc_hd__nand2_1 U123 ( .A(n164), .B(n555), .Y(n15) );
  sky130_fd_sc_hd__inv_2 U124 ( .A(n15), .Y(n100) );
  sky130_fd_sc_hd__a22oi_1 U125 ( .A1(n183), .A2(s_mem_q[409]), .B1(n570), 
        .B2(s_mem_q[401]), .Y(n254) );
  sky130_fd_sc_hd__inv_2 U126 ( .A(push_i), .Y(n16) );
  sky130_fd_sc_hd__and2_4 U127 ( .A(n164), .B(n555), .X(n160) );
  sky130_fd_sc_hd__o2bb2ai_1 U128 ( .B1(n17), .B2(n18), .A1_N(n191), .A2_N(
        s_mem_q[244]), .Y(n19) );
  sky130_fd_sc_hd__inv_2 U129 ( .A(s_mem_q[252]), .Y(n17) );
  sky130_fd_sc_hd__inv_1 U130 ( .A(n100), .Y(n18) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(n19), .Y(n372) );
  sky130_fd_sc_hd__nand2_1 U132 ( .A(n555), .B(n535), .Y(n20) );
  sky130_fd_sc_hd__inv_2 U133 ( .A(n20), .Y(n571) );
  sky130_fd_sc_hd__o2bb2ai_1 U134 ( .B1(n21), .B2(n9), .A1_N(n194), .A2_N(
        s_mem_q[212]), .Y(n22) );
  sky130_fd_sc_hd__inv_2 U135 ( .A(s_mem_q[220]), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(n22), .Y(n370) );
  sky130_fd_sc_hd__o2bb2ai_1 U137 ( .B1(n23), .B2(n6), .A1_N(n30), .A2_N(
        s_mem_q[209]), .Y(n24) );
  sky130_fd_sc_hd__inv_2 U138 ( .A(s_mem_q[217]), .Y(n23) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(n24), .Y(n238) );
  sky130_fd_sc_hd__o2bb2ai_1 U140 ( .B1(n25), .B2(n6), .A1_N(n194), .A2_N(
        s_mem_q[210]), .Y(n26) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(s_mem_q[218]), .Y(n25) );
  sky130_fd_sc_hd__inv_1 U142 ( .A(n26), .Y(n282) );
  sky130_fd_sc_hd__o2bb2ai_1 U143 ( .B1(n27), .B2(n9), .A1_N(n30), .A2_N(
        s_mem_q[211]), .Y(n28) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(s_mem_q[219]), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U145 ( .A(n28), .Y(n326) );
  sky130_fd_sc_hd__a22oi_1 U146 ( .A1(n195), .A2(s_mem_q[460]), .B1(n196), 
        .B2(s_mem_q[452]), .Y(n389) );
  sky130_fd_sc_hd__inv_1 U147 ( .A(n564), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U148 ( .A(n561), .Y(n29) );
  sky130_fd_sc_hd__inv_1 U149 ( .A(n561), .Y(n535) );
  sky130_fd_sc_hd__mux2i_1 U150 ( .A0(n670), .A1(n664), .S(n667), .Y(n665) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(cnt_o[1]), .Y(n667) );
  sky130_fd_sc_hd__and2_4 U152 ( .A(n1112), .B(n646), .X(n130) );
  sky130_fd_sc_hd__buf_4 U153 ( .A(n3), .X(n646) );
  sky130_fd_sc_hd__inv_2 U154 ( .A(n559), .Y(n30) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(n559), .Y(n194) );
  sky130_fd_sc_hd__nand2_1 U156 ( .A(dat_i[1]), .B(n647), .Y(n31) );
  sky130_fd_sc_hd__nand2_1 U157 ( .A(dat_i[1]), .B(n647), .Y(n32) );
  sky130_fd_sc_hd__inv_1 U158 ( .A(n31), .Y(n33) );
  sky130_fd_sc_hd__inv_1 U159 ( .A(n31), .Y(n34) );
  sky130_fd_sc_hd__inv_1 U160 ( .A(n33), .Y(n35) );
  sky130_fd_sc_hd__inv_1 U161 ( .A(n33), .Y(n36) );
  sky130_fd_sc_hd__inv_1 U162 ( .A(n33), .Y(n37) );
  sky130_fd_sc_hd__inv_1 U163 ( .A(n33), .Y(n38) );
  sky130_fd_sc_hd__inv_1 U164 ( .A(n34), .Y(n39) );
  sky130_fd_sc_hd__inv_1 U165 ( .A(n34), .Y(n40) );
  sky130_fd_sc_hd__inv_1 U166 ( .A(n34), .Y(n41) );
  sky130_fd_sc_hd__inv_1 U167 ( .A(n34), .Y(n42) );
  sky130_fd_sc_hd__inv_1 U168 ( .A(n43), .Y(n44) );
  sky130_fd_sc_hd__inv_1 U169 ( .A(n43), .Y(n45) );
  sky130_fd_sc_hd__inv_1 U170 ( .A(n43), .Y(n46) );
  sky130_fd_sc_hd__inv_1 U171 ( .A(n43), .Y(n47) );
  sky130_fd_sc_hd__inv_1 U172 ( .A(n43), .Y(n48) );
  sky130_fd_sc_hd__inv_1 U173 ( .A(n43), .Y(n49) );
  sky130_fd_sc_hd__inv_1 U174 ( .A(n43), .Y(n50) );
  sky130_fd_sc_hd__inv_1 U175 ( .A(n53), .Y(n51) );
  sky130_fd_sc_hd__inv_1 U176 ( .A(n1372), .Y(n53) );
  sky130_fd_sc_hd__inv_1 U177 ( .A(n52), .Y(n54) );
  sky130_fd_sc_hd__nand2_2 U178 ( .A(n555), .B(n535), .Y(n554) );
  sky130_fd_sc_hd__nand2_1 U179 ( .A(s_mem_q[137]), .B(n185), .Y(n59) );
  sky130_fd_sc_hd__nand2_1 U180 ( .A(s_mem_q[129]), .B(n186), .Y(n60) );
  sky130_fd_sc_hd__and2_1 U181 ( .A(n59), .B(n60), .X(n233) );
  sky130_fd_sc_hd__inv_2 U182 ( .A(n547), .Y(n61) );
  sky130_fd_sc_hd__inv_2 U183 ( .A(n547), .Y(n185) );
  sky130_fd_sc_hd__nand2_1 U184 ( .A(dat_i[5]), .B(n646), .Y(n62) );
  sky130_fd_sc_hd__inv_2 U185 ( .A(n543), .Y(n184) );
  sky130_fd_sc_hd__inv_1 U186 ( .A(n644), .Y(n63) );
  sky130_fd_sc_hd__inv_1 U187 ( .A(n542), .Y(n64) );
  sky130_fd_sc_hd__o22ai_1 U188 ( .A1(n1382), .A2(n637), .B1(n661), .B2(n1377), 
        .Y(n96) );
  sky130_fd_sc_hd__o2bb2ai_1 U189 ( .B1(n156), .B2(n705), .A1_N(n609), .A2_N(
        n700), .Y(s_mem_d[507]) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(n709), .Y(n700) );
  sky130_fd_sc_hd__inv_2 U191 ( .A(n564), .Y(n195) );
  sky130_fd_sc_hd__inv_1 U192 ( .A(n183), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(n69), .Y(n70) );
  sky130_fd_sc_hd__inv_2 U194 ( .A(n545), .Y(n183) );
  sky130_fd_sc_hd__dlygate4sd1_1 U195 ( .A(N77), .X(n636) );
  sky130_fd_sc_hd__nand2_1 U196 ( .A(n164), .B(n544), .Y(n545) );
  sky130_fd_sc_hd__nand2_1 U197 ( .A(s_mem_q[105]), .B(n73), .Y(n71) );
  sky130_fd_sc_hd__nand2_1 U198 ( .A(s_mem_q[97]), .B(n572), .Y(n72) );
  sky130_fd_sc_hd__and2_0 U199 ( .A(n71), .B(n72), .X(n249) );
  sky130_fd_sc_hd__inv_2 U200 ( .A(n557), .Y(n73) );
  sky130_fd_sc_hd__inv_2 U201 ( .A(n557), .Y(n192) );
  sky130_fd_sc_hd__nand2_2 U202 ( .A(n540), .B(n555), .Y(n557) );
  sky130_fd_sc_hd__clkinv_1 U203 ( .A(n1386), .Y(empty_o) );
  sky130_fd_sc_hd__inv_2 U204 ( .A(n554), .Y(n191) );
  sky130_fd_sc_hd__nand2_1 U205 ( .A(s_mem_q[234]), .B(n73), .Y(n74) );
  sky130_fd_sc_hd__nand2_1 U206 ( .A(s_mem_q[226]), .B(n572), .Y(n75) );
  sky130_fd_sc_hd__and2_0 U207 ( .A(n74), .B(n75), .X(n283) );
  sky130_fd_sc_hd__nand2_1 U208 ( .A(n677), .B(n669), .Y(n76) );
  sky130_fd_sc_hd__nand3_1 U209 ( .A(n659), .B(n667), .C(n77), .Y(n1387) );
  sky130_fd_sc_hd__inv_1 U210 ( .A(n76), .Y(n77) );
  sky130_fd_sc_hd__inv_2 U211 ( .A(cnt_o[4]), .Y(n677) );
  sky130_fd_sc_hd__nand2_1 U212 ( .A(s_mem_q[236]), .B(n73), .Y(n78) );
  sky130_fd_sc_hd__nand2_1 U213 ( .A(s_mem_q[228]), .B(n193), .Y(n79) );
  sky130_fd_sc_hd__and2_0 U214 ( .A(n78), .B(n79), .X(n371) );
  sky130_fd_sc_hd__nand2_1 U215 ( .A(s_mem_q[235]), .B(n192), .Y(n80) );
  sky130_fd_sc_hd__nand2_1 U216 ( .A(s_mem_q[227]), .B(n572), .Y(n81) );
  sky130_fd_sc_hd__and2_0 U217 ( .A(n80), .B(n81), .X(n327) );
  sky130_fd_sc_hd__nand2_1 U218 ( .A(s_mem_q[233]), .B(n73), .Y(n82) );
  sky130_fd_sc_hd__nand2_1 U219 ( .A(s_mem_q[225]), .B(n193), .Y(n83) );
  sky130_fd_sc_hd__and2_0 U220 ( .A(n82), .B(n83), .X(n239) );
  sky130_fd_sc_hd__nand2_1 U221 ( .A(s_mem_q[237]), .B(n192), .Y(n84) );
  sky130_fd_sc_hd__nand2_1 U222 ( .A(s_mem_q[229]), .B(n193), .Y(n85) );
  sky130_fd_sc_hd__and2_0 U223 ( .A(n84), .B(n85), .X(n415) );
  sky130_fd_sc_hd__nand2_1 U224 ( .A(s_mem_q[238]), .B(n73), .Y(n86) );
  sky130_fd_sc_hd__nand2_1 U225 ( .A(s_mem_q[230]), .B(n193), .Y(n87) );
  sky130_fd_sc_hd__and2_0 U226 ( .A(n86), .B(n87), .X(n459) );
  sky130_fd_sc_hd__buf_4 U227 ( .A(n639), .X(n654) );
  sky130_fd_sc_hd__buf_4 U228 ( .A(n640), .X(n655) );
  sky130_fd_sc_hd__buf_2 U229 ( .A(n640), .X(n656) );
  sky130_fd_sc_hd__and2_1 U230 ( .A(n89), .B(n90), .X(n454) );
  sky130_fd_sc_hd__inv_1 U231 ( .A(n545), .Y(n88) );
  sky130_fd_sc_hd__nand2_1 U232 ( .A(s_mem_q[158]), .B(n88), .Y(n89) );
  sky130_fd_sc_hd__nand2_1 U233 ( .A(s_mem_q[150]), .B(n570), .Y(n90) );
  sky130_fd_sc_hd__nand2_2 U234 ( .A(n661), .B(n1376), .Y(n682) );
  sky130_fd_sc_hd__and2_1 U235 ( .A(n93), .B(n94), .X(n456) );
  sky130_fd_sc_hd__nand2_1 U236 ( .A(n661), .B(n1376), .Y(n91) );
  sky130_fd_sc_hd__inv_2 U237 ( .A(n660), .Y(n661) );
  sky130_fd_sc_hd__inv_2 U238 ( .A(n536), .Y(n92) );
  sky130_fd_sc_hd__inv_2 U239 ( .A(n536), .Y(n180) );
  sky130_fd_sc_hd__nand2_2 U240 ( .A(n534), .B(n164), .Y(n536) );
  sky130_fd_sc_hd__nand2_1 U241 ( .A(s_mem_q[190]), .B(n92), .Y(n93) );
  sky130_fd_sc_hd__nand2_1 U242 ( .A(s_mem_q[182]), .B(n574), .Y(n94) );
  sky130_fd_sc_hd__inv_2 U243 ( .A(n533), .Y(n574) );
  sky130_fd_sc_hd__nor4_2 U244 ( .A(cnt_o[2]), .B(cnt_o[6]), .C(cnt_o[1]), .D(
        cnt_o[5]), .Y(n658) );
  sky130_fd_sc_hd__o22ai_1 U245 ( .A1(n637), .A2(n2), .B1(n661), .B2(n63), .Y(
        n95) );
  sky130_fd_sc_hd__o22ai_1 U246 ( .A1(n1382), .A2(n637), .B1(n661), .B2(n1377), 
        .Y(n681) );
  sky130_fd_sc_hd__inv_2 U247 ( .A(n1271), .Y(n1359) );
  sky130_fd_sc_hd__buf_6 U248 ( .A(n184), .X(n570) );
  sky130_fd_sc_hd__and3_4 U249 ( .A(n1383), .B(n1381), .C(n776), .X(n161) );
  sky130_fd_sc_hd__and2_4 U250 ( .A(n560), .B(n164), .X(n97) );
  sky130_fd_sc_hd__and2_4 U251 ( .A(n560), .B(n164), .X(n98) );
  sky130_fd_sc_hd__and2_1 U252 ( .A(n1101), .B(n646), .X(n101) );
  sky130_fd_sc_hd__buf_6 U253 ( .A(n184), .X(n569) );
  sky130_fd_sc_hd__and2_1 U254 ( .A(n1003), .B(n645), .X(n133) );
  sky130_fd_sc_hd__and2_1 U255 ( .A(n983), .B(n645), .X(n135) );
  sky130_fd_sc_hd__and2_1 U256 ( .A(n973), .B(n645), .X(n136) );
  sky130_fd_sc_hd__and2_1 U257 ( .A(n963), .B(n645), .X(n137) );
  sky130_fd_sc_hd__and2_1 U258 ( .A(n931), .B(n645), .X(n140) );
  sky130_fd_sc_hd__and2_1 U259 ( .A(n921), .B(n645), .X(n141) );
  sky130_fd_sc_hd__and2_1 U260 ( .A(n901), .B(n645), .X(n143) );
  sky130_fd_sc_hd__and2_1 U261 ( .A(n891), .B(n645), .X(n144) );
  sky130_fd_sc_hd__and2_1 U262 ( .A(n881), .B(n645), .X(n145) );
  sky130_fd_sc_hd__buf_2 U263 ( .A(n643), .X(n648) );
  sky130_fd_sc_hd__and2_1 U264 ( .A(n1214), .B(n647), .X(n105) );
  sky130_fd_sc_hd__and2_1 U265 ( .A(n778), .B(n644), .X(n113) );
  sky130_fd_sc_hd__and2_1 U266 ( .A(n953), .B(n645), .X(n138) );
  sky130_fd_sc_hd__inv_2 U267 ( .A(n743), .Y(n1322) );
  sky130_fd_sc_hd__inv_2 U268 ( .A(n765), .Y(n1346) );
  sky130_fd_sc_hd__inv_2 U269 ( .A(n754), .Y(n1333) );
  sky130_fd_sc_hd__inv_2 U270 ( .A(n710), .Y(n1283) );
  sky130_fd_sc_hd__inv_2 U271 ( .A(n732), .Y(n1309) );
  sky130_fd_sc_hd__inv_2 U272 ( .A(n721), .Y(n1296) );
  sky130_fd_sc_hd__inv_2 U273 ( .A(n788), .Y(n859) );
  sky130_fd_sc_hd__inv_2 U274 ( .A(n952), .Y(n1023) );
  sky130_fd_sc_hd__inv_2 U275 ( .A(n870), .Y(n941) );
  sky130_fd_sc_hd__nor2b_2 U276 ( .B_N(n648), .A(n1374), .Y(n104) );
  sky130_fd_sc_hd__and2_4 U277 ( .A(n1323), .B(n648), .X(n103) );
  sky130_fd_sc_hd__and2_1 U278 ( .A(n1074), .B(n646), .X(n102) );
  sky130_fd_sc_hd__and2_1 U279 ( .A(n744), .B(n644), .X(n116) );
  sky130_fd_sc_hd__and2_1 U280 ( .A(n849), .B(n644), .X(n148) );
  sky130_fd_sc_hd__and2_1 U281 ( .A(n839), .B(n644), .X(n149) );
  sky130_fd_sc_hd__and2_1 U282 ( .A(n766), .B(n644), .X(n114) );
  sky130_fd_sc_hd__and2_1 U283 ( .A(n755), .B(n646), .X(n115) );
  sky130_fd_sc_hd__buf_2 U284 ( .A(n643), .X(n645) );
  sky130_fd_sc_hd__and2_1 U285 ( .A(n993), .B(n645), .X(n134) );
  sky130_fd_sc_hd__and2_1 U286 ( .A(n942), .B(n645), .X(n139) );
  sky130_fd_sc_hd__and2_1 U287 ( .A(n911), .B(n645), .X(n142) );
  sky130_fd_sc_hd__and2_1 U288 ( .A(n860), .B(n644), .X(n147) );
  sky130_fd_sc_hd__and2_1 U289 ( .A(n829), .B(n644), .X(n150) );
  sky130_fd_sc_hd__and2_1 U290 ( .A(n1273), .B(n648), .X(n155) );
  sky130_fd_sc_hd__and2_1 U291 ( .A(n1132), .B(n646), .X(n106) );
  sky130_fd_sc_hd__and2_1 U292 ( .A(n1090), .B(n646), .X(n107) );
  sky130_fd_sc_hd__and2_1 U293 ( .A(n1080), .B(n646), .X(n108) );
  sky130_fd_sc_hd__and2_1 U294 ( .A(n1064), .B(n646), .X(n109) );
  sky130_fd_sc_hd__and2_1 U295 ( .A(n1054), .B(n646), .X(n110) );
  sky130_fd_sc_hd__and2_1 U296 ( .A(n1044), .B(n646), .X(n111) );
  sky130_fd_sc_hd__and2_1 U297 ( .A(n1250), .B(n647), .X(n118) );
  sky130_fd_sc_hd__and2_1 U298 ( .A(n1240), .B(n647), .X(n119) );
  sky130_fd_sc_hd__and2_1 U299 ( .A(n1224), .B(n647), .X(n121) );
  sky130_fd_sc_hd__and2_1 U300 ( .A(n1204), .B(n647), .X(n122) );
  sky130_fd_sc_hd__and2_1 U301 ( .A(n1194), .B(n647), .X(n123) );
  sky130_fd_sc_hd__and2_1 U302 ( .A(n1172), .B(n647), .X(n125) );
  sky130_fd_sc_hd__and2_1 U303 ( .A(n1162), .B(n647), .X(n126) );
  sky130_fd_sc_hd__and2_1 U304 ( .A(n1142), .B(n647), .X(n128) );
  sky130_fd_sc_hd__and2_1 U305 ( .A(n1122), .B(n646), .X(n129) );
  sky130_fd_sc_hd__and2_1 U306 ( .A(n1013), .B(n646), .X(n132) );
  sky130_fd_sc_hd__and2_1 U307 ( .A(n1261), .B(n647), .X(n117) );
  sky130_fd_sc_hd__and2_1 U308 ( .A(n1234), .B(n647), .X(n120) );
  sky130_fd_sc_hd__and2_1 U309 ( .A(n1183), .B(n647), .X(n124) );
  sky130_fd_sc_hd__and2_1 U310 ( .A(n1152), .B(n647), .X(n127) );
  sky130_fd_sc_hd__and2_1 U311 ( .A(n1024), .B(n646), .X(n131) );
  sky130_fd_sc_hd__and2_1 U312 ( .A(n700), .B(n645), .X(n156) );
  sky130_fd_sc_hd__and2_1 U313 ( .A(n711), .B(n645), .X(n157) );
  sky130_fd_sc_hd__and2_1 U314 ( .A(n733), .B(n646), .X(n158) );
  sky130_fd_sc_hd__and2_1 U315 ( .A(n722), .B(n648), .X(n159) );
  sky130_fd_sc_hd__nand2_1 U316 ( .A(n1260), .B(n161), .Y(n1269) );
  sky130_fd_sc_hd__nand2_1 U317 ( .A(n1182), .B(n161), .Y(n1191) );
  sky130_fd_sc_hd__nand2_1 U318 ( .A(n1023), .B(n161), .Y(n1032) );
  sky130_fd_sc_hd__nand2_1 U319 ( .A(n941), .B(n161), .Y(n950) );
  sky130_fd_sc_hd__nand2_1 U320 ( .A(n859), .B(n161), .Y(n868) );
  sky130_fd_sc_hd__buf_2 U321 ( .A(n1360), .X(n649) );
  sky130_fd_sc_hd__nand2_1 U322 ( .A(n1272), .B(n1359), .Y(n1281) );
  sky130_fd_sc_hd__nand2_1 U323 ( .A(n1260), .B(n1322), .Y(n1238) );
  sky130_fd_sc_hd__nand2_1 U324 ( .A(n1182), .B(n1322), .Y(n1160) );
  sky130_fd_sc_hd__nand2_1 U325 ( .A(n1023), .B(n1322), .Y(n1001) );
  sky130_fd_sc_hd__nand2_1 U326 ( .A(n941), .B(n1322), .Y(n919) );
  sky130_fd_sc_hd__nand2_1 U327 ( .A(n859), .B(n1322), .Y(n837) );
  sky130_fd_sc_hd__nand2_1 U328 ( .A(n1309), .B(n1359), .Y(n1319) );
  sky130_fd_sc_hd__nand2_1 U329 ( .A(n1296), .B(n1359), .Y(n1306) );
  sky130_fd_sc_hd__nand2_1 U330 ( .A(n1283), .B(n1359), .Y(n1293) );
  sky130_fd_sc_hd__inv_2 U331 ( .A(n558), .Y(n555) );
  sky130_fd_sc_hd__and2_1 U332 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[1]), .X(n165) );
  sky130_fd_sc_hd__and2_1 U333 ( .A(s_wr_ptr_q[4]), .B(s_wr_ptr_q[3]), .X(n166) );
  sky130_fd_sc_hd__buf_2 U334 ( .A(n643), .X(n647) );
  sky130_fd_sc_hd__inv_2 U335 ( .A(n1348), .Y(n1358) );
  sky130_fd_sc_hd__inv_2 U336 ( .A(n1356), .Y(n1347) );
  sky130_fd_sc_hd__inv_2 U337 ( .A(n1335), .Y(n1345) );
  sky130_fd_sc_hd__inv_2 U338 ( .A(n1343), .Y(n1334) );
  sky130_fd_sc_hd__inv_2 U339 ( .A(n1311), .Y(n1321) );
  sky130_fd_sc_hd__inv_2 U340 ( .A(n1319), .Y(n1310) );
  sky130_fd_sc_hd__inv_2 U341 ( .A(n1298), .Y(n1308) );
  sky130_fd_sc_hd__inv_2 U342 ( .A(n1306), .Y(n1297) );
  sky130_fd_sc_hd__inv_2 U343 ( .A(n1285), .Y(n1295) );
  sky130_fd_sc_hd__inv_2 U344 ( .A(n1293), .Y(n1284) );
  sky130_fd_sc_hd__nand2_1 U345 ( .A(n1100), .B(n161), .Y(n1109) );
  sky130_fd_sc_hd__nand2_1 U346 ( .A(n1100), .B(n1322), .Y(n1078) );
  sky130_fd_sc_hd__nand2_1 U347 ( .A(n161), .B(n1359), .Y(n1374) );
  sky130_fd_sc_hd__nand2_1 U348 ( .A(n1322), .B(n1359), .Y(n1331) );
  sky130_fd_sc_hd__inv_1 U349 ( .A(n637), .Y(n697) );
  sky130_fd_sc_hd__inv_2 U350 ( .A(n680), .Y(n683) );
  sky130_fd_sc_hd__buf_2 U351 ( .A(n1360), .X(n651) );
  sky130_fd_sc_hd__buf_2 U352 ( .A(n1360), .X(n650) );
  sky130_fd_sc_hd__buf_2 U353 ( .A(n1360), .X(n652) );
  sky130_fd_sc_hd__buf_2 U354 ( .A(n1360), .X(n653) );
  sky130_fd_sc_hd__inv_1 U355 ( .A(n663), .Y(n670) );
  sky130_fd_sc_hd__ha_1 U356 ( .A(n64), .B(\add_50/carry[3] ), .COUT(
        \add_50/carry[4] ), .SUM(N87) );
  sky130_fd_sc_hd__nand2_1 U357 ( .A(n1100), .B(n1346), .Y(n1098) );
  sky130_fd_sc_hd__nand2_1 U358 ( .A(n1100), .B(n1333), .Y(n1088) );
  sky130_fd_sc_hd__nand2_1 U359 ( .A(n777), .B(n161), .Y(n786) );
  sky130_fd_sc_hd__nand2_1 U360 ( .A(n777), .B(n1346), .Y(n774) );
  sky130_fd_sc_hd__nand2_1 U361 ( .A(n777), .B(n1333), .Y(n763) );
  sky130_fd_sc_hd__nand2_1 U362 ( .A(n1260), .B(n1346), .Y(n1258) );
  sky130_fd_sc_hd__nand2_1 U363 ( .A(n1260), .B(n1333), .Y(n1248) );
  sky130_fd_sc_hd__nand2_1 U364 ( .A(n1182), .B(n1346), .Y(n1180) );
  sky130_fd_sc_hd__nand2_1 U365 ( .A(n1182), .B(n1333), .Y(n1170) );
  sky130_fd_sc_hd__nand2_1 U366 ( .A(n1023), .B(n1346), .Y(n1021) );
  sky130_fd_sc_hd__nand2_1 U367 ( .A(n1023), .B(n1333), .Y(n1011) );
  sky130_fd_sc_hd__nand2_1 U368 ( .A(n941), .B(n1346), .Y(n939) );
  sky130_fd_sc_hd__nand2_1 U369 ( .A(n941), .B(n1333), .Y(n929) );
  sky130_fd_sc_hd__nand2_1 U370 ( .A(n859), .B(n1346), .Y(n857) );
  sky130_fd_sc_hd__nand2_1 U371 ( .A(n859), .B(n1333), .Y(n847) );
  sky130_fd_sc_hd__nand2_1 U372 ( .A(n1100), .B(n1272), .Y(n1042) );
  sky130_fd_sc_hd__nand2_1 U373 ( .A(n1260), .B(n1272), .Y(n1202) );
  sky130_fd_sc_hd__nand2_1 U374 ( .A(n1182), .B(n1272), .Y(n1120) );
  sky130_fd_sc_hd__nand2_1 U375 ( .A(n1023), .B(n1272), .Y(n961) );
  sky130_fd_sc_hd__nand2_1 U376 ( .A(n941), .B(n1272), .Y(n879) );
  sky130_fd_sc_hd__nand2_1 U377 ( .A(n859), .B(n1272), .Y(n797) );
  sky130_fd_sc_hd__nand2_1 U378 ( .A(n777), .B(n1322), .Y(n752) );
  sky130_fd_sc_hd__nand2_1 U379 ( .A(n1100), .B(n1283), .Y(n1052) );
  sky130_fd_sc_hd__nand2_1 U380 ( .A(n1260), .B(n1283), .Y(n1212) );
  sky130_fd_sc_hd__nand2_1 U381 ( .A(n1023), .B(n1283), .Y(n971) );
  sky130_fd_sc_hd__nand2_1 U382 ( .A(n941), .B(n1283), .Y(n889) );
  sky130_fd_sc_hd__nand2_1 U383 ( .A(n1182), .B(n1283), .Y(n1130) );
  sky130_fd_sc_hd__nand2_1 U384 ( .A(n859), .B(n1283), .Y(n807) );
  sky130_fd_sc_hd__nand2_1 U385 ( .A(n777), .B(n1283), .Y(n719) );
  sky130_fd_sc_hd__nand2_1 U386 ( .A(n1100), .B(n1309), .Y(n1072) );
  sky130_fd_sc_hd__nand2_1 U387 ( .A(n1260), .B(n1309), .Y(n1232) );
  sky130_fd_sc_hd__nand2_1 U388 ( .A(n1182), .B(n1309), .Y(n1150) );
  sky130_fd_sc_hd__nand2_1 U389 ( .A(n1023), .B(n1309), .Y(n991) );
  sky130_fd_sc_hd__nand2_1 U390 ( .A(n941), .B(n1309), .Y(n909) );
  sky130_fd_sc_hd__nand2_1 U391 ( .A(n859), .B(n1309), .Y(n827) );
  sky130_fd_sc_hd__nand2_1 U392 ( .A(n777), .B(n1309), .Y(n741) );
  sky130_fd_sc_hd__nand2_1 U393 ( .A(n1346), .B(n1359), .Y(n1356) );
  sky130_fd_sc_hd__nand2_1 U394 ( .A(n1333), .B(n1359), .Y(n1343) );
  sky130_fd_sc_hd__nand2_1 U395 ( .A(n1260), .B(n1296), .Y(n1222) );
  sky130_fd_sc_hd__nand2_1 U396 ( .A(n1182), .B(n1296), .Y(n1140) );
  sky130_fd_sc_hd__nand2_1 U397 ( .A(n1100), .B(n1296), .Y(n1062) );
  sky130_fd_sc_hd__nand2_1 U398 ( .A(n1023), .B(n1296), .Y(n981) );
  sky130_fd_sc_hd__nand2_1 U399 ( .A(n941), .B(n1296), .Y(n899) );
  sky130_fd_sc_hd__nand2_1 U400 ( .A(n859), .B(n1296), .Y(n817) );
  sky130_fd_sc_hd__nand2_1 U401 ( .A(n777), .B(n1296), .Y(n730) );
  sky130_fd_sc_hd__inv_2 U402 ( .A(n1034), .Y(n1100) );
  sky130_fd_sc_hd__and3_1 U403 ( .A(n667), .B(n666), .C(n669), .X(n162) );
  sky130_fd_sc_hd__and2_0 U404 ( .A(n508), .B(n497), .X(n163) );
  sky130_fd_sc_hd__and2_1 U405 ( .A(n637), .B(n3), .X(n641) );
  sky130_fd_sc_hd__a22oi_1 U406 ( .A1(s_mem_q[486]), .A2(n572), .B1(
        s_mem_q[494]), .B2(n192), .Y(n479) );
  sky130_fd_sc_hd__a22oi_1 U407 ( .A1(s_mem_q[138]), .A2(n61), .B1(
        s_mem_q[130]), .B2(n186), .Y(n277) );
  sky130_fd_sc_hd__inv_2 U408 ( .A(n699), .Y(n1272) );
  sky130_fd_sc_hd__inv_2 U409 ( .A(n698), .Y(n777) );
  sky130_fd_sc_hd__ha_1 U410 ( .A(s_wr_ptr_q[1]), .B(s_wr_ptr_q[0]), .COUT(
        \add_65/carry[2] ), .SUM(N96) );
  sky130_fd_sc_hd__ha_1 U411 ( .A(s_wr_ptr_q[2]), .B(\add_65/carry[2] ), 
        .COUT(\add_65/carry[3] ), .SUM(N97) );
  sky130_fd_sc_hd__ha_1 U412 ( .A(s_wr_ptr_q[3]), .B(\add_65/carry[3] ), 
        .COUT(\add_65/carry[4] ), .SUM(N98) );
  sky130_fd_sc_hd__ha_1 U413 ( .A(s_wr_ptr_q[4]), .B(\add_65/carry[4] ), 
        .COUT(\add_65/carry[5] ), .SUM(N99) );
  sky130_fd_sc_hd__and2_0 U414 ( .A(N80), .B(n508), .X(n167) );
  sky130_fd_sc_hd__and2_0 U415 ( .A(N79), .B(n497), .X(n168) );
  sky130_fd_sc_hd__and2_0 U416 ( .A(N80), .B(N79), .X(n169) );
  sky130_fd_sc_hd__nand4_1 U417 ( .A(n170), .B(n171), .C(n172), .D(n173), .Y(
        dat_o[0]) );
  sky130_fd_sc_hd__o21ai_1 U418 ( .A1(n174), .A2(n175), .B1(n168), .Y(n173) );
  sky130_fd_sc_hd__nand4_1 U419 ( .A(n176), .B(n177), .C(n178), .D(n179), .Y(
        n175) );
  sky130_fd_sc_hd__a22oi_1 U420 ( .A1(s_mem_q[184]), .A2(n92), .B1(
        s_mem_q[176]), .B2(n574), .Y(n179) );
  sky130_fd_sc_hd__a22oi_1 U421 ( .A1(s_mem_q[168]), .A2(n568), .B1(
        s_mem_q[160]), .B2(n182), .Y(n178) );
  sky130_fd_sc_hd__a22oi_1 U422 ( .A1(s_mem_q[152]), .A2(n88), .B1(
        s_mem_q[144]), .B2(n570), .Y(n177) );
  sky130_fd_sc_hd__a22oi_1 U423 ( .A1(s_mem_q[136]), .A2(n185), .B1(
        s_mem_q[128]), .B2(n186), .Y(n176) );
  sky130_fd_sc_hd__nand4_1 U424 ( .A(n187), .B(n188), .C(n189), .D(n190), .Y(
        n174) );
  sky130_fd_sc_hd__a22oi_1 U425 ( .A1(s_mem_q[248]), .A2(n160), .B1(
        s_mem_q[240]), .B2(n571), .Y(n190) );
  sky130_fd_sc_hd__a22oi_1 U426 ( .A1(s_mem_q[232]), .A2(n192), .B1(
        s_mem_q[224]), .B2(n572), .Y(n189) );
  sky130_fd_sc_hd__a22oi_1 U427 ( .A1(s_mem_q[216]), .A2(n98), .B1(
        s_mem_q[208]), .B2(n30), .Y(n188) );
  sky130_fd_sc_hd__a22oi_1 U428 ( .A1(s_mem_q[200]), .A2(n68), .B1(
        s_mem_q[192]), .B2(n196), .Y(n187) );
  sky130_fd_sc_hd__o21ai_1 U429 ( .A1(n197), .A2(n198), .B1(n163), .Y(n172) );
  sky130_fd_sc_hd__nand4_1 U430 ( .A(n199), .B(n200), .C(n201), .D(n202), .Y(
        n198) );
  sky130_fd_sc_hd__a22oi_1 U431 ( .A1(s_mem_q[56]), .A2(n92), .B1(s_mem_q[48]), 
        .B2(n573), .Y(n202) );
  sky130_fd_sc_hd__a22oi_1 U432 ( .A1(s_mem_q[40]), .A2(n567), .B1(s_mem_q[32]), .B2(n182), .Y(n201) );
  sky130_fd_sc_hd__a22oi_1 U433 ( .A1(s_mem_q[24]), .A2(n88), .B1(s_mem_q[16]), 
        .B2(n570), .Y(n200) );
  sky130_fd_sc_hd__a22oi_1 U434 ( .A1(s_mem_q[8]), .A2(n61), .B1(s_mem_q[0]), 
        .B2(n186), .Y(n199) );
  sky130_fd_sc_hd__nand4_1 U435 ( .A(n203), .B(n204), .C(n205), .D(n206), .Y(
        n197) );
  sky130_fd_sc_hd__a22oi_1 U436 ( .A1(s_mem_q[120]), .A2(n160), .B1(
        s_mem_q[112]), .B2(n571), .Y(n206) );
  sky130_fd_sc_hd__a22oi_1 U437 ( .A1(s_mem_q[104]), .A2(n73), .B1(s_mem_q[96]), .B2(n572), .Y(n205) );
  sky130_fd_sc_hd__a22oi_1 U438 ( .A1(s_mem_q[88]), .A2(n98), .B1(s_mem_q[80]), 
        .B2(n194), .Y(n204) );
  sky130_fd_sc_hd__a22oi_1 U439 ( .A1(s_mem_q[72]), .A2(n68), .B1(s_mem_q[64]), 
        .B2(n196), .Y(n203) );
  sky130_fd_sc_hd__o21ai_1 U440 ( .A1(n207), .A2(n208), .B1(n169), .Y(n171) );
  sky130_fd_sc_hd__nand4_1 U441 ( .A(n209), .B(n210), .C(n211), .D(n212), .Y(
        n208) );
  sky130_fd_sc_hd__a22oi_1 U442 ( .A1(s_mem_q[440]), .A2(n92), .B1(
        s_mem_q[432]), .B2(n574), .Y(n212) );
  sky130_fd_sc_hd__a22oi_1 U443 ( .A1(s_mem_q[424]), .A2(n568), .B1(
        s_mem_q[416]), .B2(n182), .Y(n211) );
  sky130_fd_sc_hd__a22oi_1 U444 ( .A1(s_mem_q[408]), .A2(n88), .B1(
        s_mem_q[400]), .B2(n570), .Y(n210) );
  sky130_fd_sc_hd__a22oi_1 U445 ( .A1(s_mem_q[392]), .A2(n61), .B1(
        s_mem_q[384]), .B2(n186), .Y(n209) );
  sky130_fd_sc_hd__nand4_1 U446 ( .A(n213), .B(n214), .C(n215), .D(n216), .Y(
        n207) );
  sky130_fd_sc_hd__a22oi_1 U447 ( .A1(s_mem_q[504]), .A2(n160), .B1(
        s_mem_q[496]), .B2(n571), .Y(n216) );
  sky130_fd_sc_hd__a22oi_1 U448 ( .A1(s_mem_q[488]), .A2(n192), .B1(
        s_mem_q[480]), .B2(n572), .Y(n215) );
  sky130_fd_sc_hd__a22oi_1 U449 ( .A1(s_mem_q[472]), .A2(n98), .B1(
        s_mem_q[464]), .B2(n30), .Y(n214) );
  sky130_fd_sc_hd__a22oi_1 U450 ( .A1(s_mem_q[456]), .A2(n68), .B1(
        s_mem_q[448]), .B2(n196), .Y(n213) );
  sky130_fd_sc_hd__o21ai_1 U451 ( .A1(n217), .A2(n218), .B1(n167), .Y(n170) );
  sky130_fd_sc_hd__nand4_1 U452 ( .A(n219), .B(n220), .C(n221), .D(n222), .Y(
        n218) );
  sky130_fd_sc_hd__a22oi_1 U453 ( .A1(s_mem_q[312]), .A2(n180), .B1(
        s_mem_q[304]), .B2(n574), .Y(n222) );
  sky130_fd_sc_hd__a22oi_1 U454 ( .A1(s_mem_q[296]), .A2(n567), .B1(
        s_mem_q[288]), .B2(n182), .Y(n221) );
  sky130_fd_sc_hd__a22oi_1 U455 ( .A1(s_mem_q[280]), .A2(n88), .B1(
        s_mem_q[272]), .B2(n570), .Y(n220) );
  sky130_fd_sc_hd__a22oi_1 U456 ( .A1(s_mem_q[264]), .A2(n61), .B1(
        s_mem_q[256]), .B2(n186), .Y(n219) );
  sky130_fd_sc_hd__nand4_1 U457 ( .A(n223), .B(n224), .C(n225), .D(n226), .Y(
        n217) );
  sky130_fd_sc_hd__a22oi_1 U458 ( .A1(s_mem_q[376]), .A2(n160), .B1(
        s_mem_q[368]), .B2(n571), .Y(n226) );
  sky130_fd_sc_hd__a22oi_1 U459 ( .A1(s_mem_q[360]), .A2(n192), .B1(
        s_mem_q[352]), .B2(n193), .Y(n225) );
  sky130_fd_sc_hd__a22oi_1 U460 ( .A1(s_mem_q[344]), .A2(n98), .B1(
        s_mem_q[336]), .B2(n194), .Y(n224) );
  sky130_fd_sc_hd__a22oi_1 U461 ( .A1(s_mem_q[328]), .A2(n68), .B1(
        s_mem_q[320]), .B2(n196), .Y(n223) );
  sky130_fd_sc_hd__nand4_1 U462 ( .A(n227), .B(n228), .C(n229), .D(n230), .Y(
        dat_o[1]) );
  sky130_fd_sc_hd__o21ai_1 U463 ( .A1(n231), .A2(n232), .B1(n168), .Y(n230) );
  sky130_fd_sc_hd__nand4_1 U464 ( .A(n233), .B(n234), .C(n235), .D(n236), .Y(
        n232) );
  sky130_fd_sc_hd__a22oi_1 U465 ( .A1(s_mem_q[185]), .A2(n180), .B1(
        s_mem_q[177]), .B2(n573), .Y(n236) );
  sky130_fd_sc_hd__a22oi_1 U466 ( .A1(s_mem_q[169]), .A2(n181), .B1(
        s_mem_q[161]), .B2(n182), .Y(n235) );
  sky130_fd_sc_hd__a22oi_1 U467 ( .A1(s_mem_q[153]), .A2(n183), .B1(
        s_mem_q[145]), .B2(n569), .Y(n234) );
  sky130_fd_sc_hd__nand4_1 U468 ( .A(n237), .B(n238), .C(n239), .D(n240), .Y(
        n231) );
  sky130_fd_sc_hd__a22oi_1 U469 ( .A1(s_mem_q[249]), .A2(n100), .B1(
        s_mem_q[241]), .B2(n571), .Y(n240) );
  sky130_fd_sc_hd__a22oi_1 U470 ( .A1(s_mem_q[201]), .A2(n195), .B1(
        s_mem_q[193]), .B2(n196), .Y(n237) );
  sky130_fd_sc_hd__o21ai_1 U471 ( .A1(n241), .A2(n242), .B1(n163), .Y(n229) );
  sky130_fd_sc_hd__nand4_1 U472 ( .A(n243), .B(n244), .C(n245), .D(n246), .Y(
        n242) );
  sky130_fd_sc_hd__a22oi_1 U473 ( .A1(s_mem_q[57]), .A2(n180), .B1(s_mem_q[49]), .B2(n574), .Y(n246) );
  sky130_fd_sc_hd__a22oi_1 U474 ( .A1(s_mem_q[41]), .A2(n181), .B1(s_mem_q[33]), .B2(n182), .Y(n245) );
  sky130_fd_sc_hd__a22oi_1 U475 ( .A1(s_mem_q[25]), .A2(n183), .B1(s_mem_q[17]), .B2(n569), .Y(n244) );
  sky130_fd_sc_hd__a22oi_1 U476 ( .A1(s_mem_q[9]), .A2(n185), .B1(s_mem_q[1]), 
        .B2(n186), .Y(n243) );
  sky130_fd_sc_hd__nand4_1 U477 ( .A(n247), .B(n248), .C(n249), .D(n250), .Y(
        n241) );
  sky130_fd_sc_hd__a22oi_1 U478 ( .A1(s_mem_q[121]), .A2(n100), .B1(
        s_mem_q[113]), .B2(n571), .Y(n250) );
  sky130_fd_sc_hd__a22oi_1 U479 ( .A1(s_mem_q[73]), .A2(n195), .B1(s_mem_q[65]), .B2(n196), .Y(n247) );
  sky130_fd_sc_hd__o21ai_1 U480 ( .A1(n251), .A2(n252), .B1(n169), .Y(n228) );
  sky130_fd_sc_hd__nand4_1 U481 ( .A(n253), .B(n254), .C(n255), .D(n256), .Y(
        n252) );
  sky130_fd_sc_hd__a22oi_1 U482 ( .A1(s_mem_q[441]), .A2(n92), .B1(
        s_mem_q[433]), .B2(n574), .Y(n256) );
  sky130_fd_sc_hd__a22oi_1 U483 ( .A1(s_mem_q[425]), .A2(n181), .B1(
        s_mem_q[417]), .B2(n182), .Y(n255) );
  sky130_fd_sc_hd__a22oi_1 U484 ( .A1(s_mem_q[393]), .A2(n61), .B1(
        s_mem_q[385]), .B2(n186), .Y(n253) );
  sky130_fd_sc_hd__nand4_1 U485 ( .A(n257), .B(n258), .C(n259), .D(n260), .Y(
        n251) );
  sky130_fd_sc_hd__a22oi_1 U486 ( .A1(s_mem_q[505]), .A2(n100), .B1(
        s_mem_q[497]), .B2(n571), .Y(n260) );
  sky130_fd_sc_hd__a22oi_1 U487 ( .A1(s_mem_q[489]), .A2(n73), .B1(
        s_mem_q[481]), .B2(n193), .Y(n259) );
  sky130_fd_sc_hd__a22oi_1 U488 ( .A1(s_mem_q[473]), .A2(n97), .B1(
        s_mem_q[465]), .B2(n194), .Y(n258) );
  sky130_fd_sc_hd__a22oi_1 U489 ( .A1(s_mem_q[457]), .A2(n195), .B1(
        s_mem_q[449]), .B2(n196), .Y(n257) );
  sky130_fd_sc_hd__o21ai_1 U490 ( .A1(n261), .A2(n262), .B1(n167), .Y(n227) );
  sky130_fd_sc_hd__nand4_1 U491 ( .A(n263), .B(n264), .C(n265), .D(n266), .Y(
        n262) );
  sky130_fd_sc_hd__a22oi_1 U492 ( .A1(s_mem_q[313]), .A2(n92), .B1(
        s_mem_q[305]), .B2(n574), .Y(n266) );
  sky130_fd_sc_hd__a22oi_1 U493 ( .A1(s_mem_q[297]), .A2(n181), .B1(
        s_mem_q[289]), .B2(n182), .Y(n265) );
  sky130_fd_sc_hd__a22oi_1 U494 ( .A1(s_mem_q[281]), .A2(n183), .B1(
        s_mem_q[273]), .B2(n570), .Y(n264) );
  sky130_fd_sc_hd__a22oi_1 U495 ( .A1(s_mem_q[265]), .A2(n61), .B1(
        s_mem_q[257]), .B2(n186), .Y(n263) );
  sky130_fd_sc_hd__nand4_1 U496 ( .A(n267), .B(n268), .C(n269), .D(n270), .Y(
        n261) );
  sky130_fd_sc_hd__a22oi_1 U497 ( .A1(s_mem_q[377]), .A2(n160), .B1(
        s_mem_q[369]), .B2(n571), .Y(n270) );
  sky130_fd_sc_hd__a22oi_1 U498 ( .A1(s_mem_q[361]), .A2(n73), .B1(
        s_mem_q[353]), .B2(n193), .Y(n269) );
  sky130_fd_sc_hd__a22oi_1 U499 ( .A1(s_mem_q[345]), .A2(n98), .B1(
        s_mem_q[337]), .B2(n194), .Y(n268) );
  sky130_fd_sc_hd__a22oi_1 U500 ( .A1(s_mem_q[329]), .A2(n195), .B1(
        s_mem_q[321]), .B2(n196), .Y(n267) );
  sky130_fd_sc_hd__nand4_1 U501 ( .A(n271), .B(n272), .C(n273), .D(n274), .Y(
        dat_o[2]) );
  sky130_fd_sc_hd__o21ai_1 U502 ( .A1(n275), .A2(n276), .B1(n168), .Y(n274) );
  sky130_fd_sc_hd__nand4_1 U503 ( .A(n277), .B(n278), .C(n279), .D(n280), .Y(
        n276) );
  sky130_fd_sc_hd__a22oi_1 U504 ( .A1(s_mem_q[186]), .A2(n180), .B1(
        s_mem_q[178]), .B2(n574), .Y(n280) );
  sky130_fd_sc_hd__a22oi_1 U505 ( .A1(s_mem_q[170]), .A2(n181), .B1(
        s_mem_q[162]), .B2(n182), .Y(n279) );
  sky130_fd_sc_hd__a22oi_1 U506 ( .A1(s_mem_q[154]), .A2(n183), .B1(
        s_mem_q[146]), .B2(n569), .Y(n278) );
  sky130_fd_sc_hd__nand4_1 U507 ( .A(n281), .B(n282), .C(n283), .D(n284), .Y(
        n275) );
  sky130_fd_sc_hd__a22oi_1 U508 ( .A1(s_mem_q[250]), .A2(n100), .B1(
        s_mem_q[242]), .B2(n571), .Y(n284) );
  sky130_fd_sc_hd__a22oi_1 U509 ( .A1(s_mem_q[202]), .A2(n195), .B1(
        s_mem_q[194]), .B2(n196), .Y(n281) );
  sky130_fd_sc_hd__o21ai_1 U510 ( .A1(n285), .A2(n286), .B1(n163), .Y(n273) );
  sky130_fd_sc_hd__nand4_1 U511 ( .A(n287), .B(n288), .C(n289), .D(n290), .Y(
        n286) );
  sky130_fd_sc_hd__a22oi_1 U512 ( .A1(s_mem_q[58]), .A2(n180), .B1(s_mem_q[50]), .B2(n573), .Y(n290) );
  sky130_fd_sc_hd__a22oi_1 U513 ( .A1(s_mem_q[42]), .A2(n181), .B1(s_mem_q[34]), .B2(n182), .Y(n289) );
  sky130_fd_sc_hd__a22oi_1 U514 ( .A1(s_mem_q[26]), .A2(n183), .B1(s_mem_q[18]), .B2(n569), .Y(n288) );
  sky130_fd_sc_hd__a22oi_1 U515 ( .A1(s_mem_q[10]), .A2(n61), .B1(s_mem_q[2]), 
        .B2(n186), .Y(n287) );
  sky130_fd_sc_hd__nand4_1 U516 ( .A(n291), .B(n292), .C(n293), .D(n294), .Y(
        n285) );
  sky130_fd_sc_hd__a22oi_1 U517 ( .A1(s_mem_q[122]), .A2(n100), .B1(
        s_mem_q[114]), .B2(n571), .Y(n294) );
  sky130_fd_sc_hd__a22oi_1 U518 ( .A1(s_mem_q[106]), .A2(n73), .B1(s_mem_q[98]), .B2(n572), .Y(n293) );
  sky130_fd_sc_hd__a22oi_1 U519 ( .A1(s_mem_q[74]), .A2(n195), .B1(s_mem_q[66]), .B2(n196), .Y(n291) );
  sky130_fd_sc_hd__o21ai_1 U520 ( .A1(n295), .A2(n296), .B1(n169), .Y(n272) );
  sky130_fd_sc_hd__nand4_1 U521 ( .A(n297), .B(n298), .C(n299), .D(n300), .Y(
        n296) );
  sky130_fd_sc_hd__a22oi_1 U522 ( .A1(s_mem_q[442]), .A2(n92), .B1(
        s_mem_q[434]), .B2(n573), .Y(n300) );
  sky130_fd_sc_hd__a22oi_1 U523 ( .A1(s_mem_q[426]), .A2(n181), .B1(
        s_mem_q[418]), .B2(n182), .Y(n299) );
  sky130_fd_sc_hd__a22oi_1 U524 ( .A1(s_mem_q[410]), .A2(n183), .B1(
        s_mem_q[402]), .B2(n569), .Y(n298) );
  sky130_fd_sc_hd__a22oi_1 U525 ( .A1(s_mem_q[394]), .A2(n185), .B1(
        s_mem_q[386]), .B2(n186), .Y(n297) );
  sky130_fd_sc_hd__nand4_1 U526 ( .A(n301), .B(n302), .C(n303), .D(n304), .Y(
        n295) );
  sky130_fd_sc_hd__a22oi_1 U527 ( .A1(s_mem_q[506]), .A2(n100), .B1(
        s_mem_q[498]), .B2(n571), .Y(n304) );
  sky130_fd_sc_hd__a22oi_1 U528 ( .A1(s_mem_q[490]), .A2(n73), .B1(
        s_mem_q[482]), .B2(n193), .Y(n303) );
  sky130_fd_sc_hd__a22oi_1 U529 ( .A1(s_mem_q[474]), .A2(n97), .B1(
        s_mem_q[466]), .B2(n30), .Y(n302) );
  sky130_fd_sc_hd__a22oi_1 U530 ( .A1(s_mem_q[458]), .A2(n195), .B1(
        s_mem_q[450]), .B2(n196), .Y(n301) );
  sky130_fd_sc_hd__o21ai_1 U531 ( .A1(n305), .A2(n306), .B1(n167), .Y(n271) );
  sky130_fd_sc_hd__nand4_1 U532 ( .A(n307), .B(n308), .C(n309), .D(n310), .Y(
        n306) );
  sky130_fd_sc_hd__a22oi_1 U533 ( .A1(s_mem_q[314]), .A2(n92), .B1(
        s_mem_q[306]), .B2(n573), .Y(n310) );
  sky130_fd_sc_hd__a22oi_1 U534 ( .A1(s_mem_q[298]), .A2(n181), .B1(
        s_mem_q[290]), .B2(n182), .Y(n309) );
  sky130_fd_sc_hd__a22oi_1 U535 ( .A1(s_mem_q[282]), .A2(n183), .B1(
        s_mem_q[274]), .B2(n570), .Y(n308) );
  sky130_fd_sc_hd__a22oi_1 U536 ( .A1(s_mem_q[266]), .A2(n185), .B1(
        s_mem_q[258]), .B2(n186), .Y(n307) );
  sky130_fd_sc_hd__nand4_1 U537 ( .A(n311), .B(n312), .C(n313), .D(n314), .Y(
        n305) );
  sky130_fd_sc_hd__a22oi_1 U538 ( .A1(s_mem_q[378]), .A2(n100), .B1(
        s_mem_q[370]), .B2(n571), .Y(n314) );
  sky130_fd_sc_hd__a22oi_1 U539 ( .A1(s_mem_q[362]), .A2(n192), .B1(
        s_mem_q[354]), .B2(n572), .Y(n313) );
  sky130_fd_sc_hd__a22oi_1 U540 ( .A1(s_mem_q[346]), .A2(n98), .B1(
        s_mem_q[338]), .B2(n30), .Y(n312) );
  sky130_fd_sc_hd__a22oi_1 U541 ( .A1(s_mem_q[330]), .A2(n195), .B1(
        s_mem_q[322]), .B2(n196), .Y(n311) );
  sky130_fd_sc_hd__nand4_1 U542 ( .A(n315), .B(n316), .C(n317), .D(n318), .Y(
        dat_o[3]) );
  sky130_fd_sc_hd__o21ai_1 U543 ( .A1(n319), .A2(n320), .B1(n168), .Y(n318) );
  sky130_fd_sc_hd__nand4_1 U544 ( .A(n321), .B(n322), .C(n323), .D(n324), .Y(
        n320) );
  sky130_fd_sc_hd__a22oi_1 U545 ( .A1(s_mem_q[187]), .A2(n180), .B1(
        s_mem_q[179]), .B2(n573), .Y(n324) );
  sky130_fd_sc_hd__a22oi_1 U546 ( .A1(s_mem_q[171]), .A2(n181), .B1(
        s_mem_q[163]), .B2(n182), .Y(n323) );
  sky130_fd_sc_hd__a22oi_1 U547 ( .A1(s_mem_q[155]), .A2(n183), .B1(
        s_mem_q[147]), .B2(n569), .Y(n322) );
  sky130_fd_sc_hd__a22oi_1 U548 ( .A1(s_mem_q[139]), .A2(n185), .B1(
        s_mem_q[131]), .B2(n186), .Y(n321) );
  sky130_fd_sc_hd__nand4_1 U549 ( .A(n325), .B(n326), .C(n327), .D(n328), .Y(
        n319) );
  sky130_fd_sc_hd__a22oi_1 U550 ( .A1(s_mem_q[251]), .A2(n100), .B1(
        s_mem_q[243]), .B2(n571), .Y(n328) );
  sky130_fd_sc_hd__a22oi_1 U551 ( .A1(s_mem_q[203]), .A2(n195), .B1(
        s_mem_q[195]), .B2(n196), .Y(n325) );
  sky130_fd_sc_hd__o21ai_1 U552 ( .A1(n329), .A2(n330), .B1(n163), .Y(n317) );
  sky130_fd_sc_hd__nand4_1 U553 ( .A(n331), .B(n332), .C(n333), .D(n334), .Y(
        n330) );
  sky130_fd_sc_hd__a22oi_1 U554 ( .A1(s_mem_q[59]), .A2(n180), .B1(s_mem_q[51]), .B2(n574), .Y(n334) );
  sky130_fd_sc_hd__a22oi_1 U555 ( .A1(s_mem_q[43]), .A2(n181), .B1(s_mem_q[35]), .B2(n182), .Y(n333) );
  sky130_fd_sc_hd__a22oi_1 U556 ( .A1(s_mem_q[27]), .A2(n183), .B1(s_mem_q[19]), .B2(n569), .Y(n332) );
  sky130_fd_sc_hd__a22oi_1 U557 ( .A1(s_mem_q[11]), .A2(n185), .B1(s_mem_q[3]), 
        .B2(n186), .Y(n331) );
  sky130_fd_sc_hd__nand4_1 U558 ( .A(n335), .B(n336), .C(n337), .D(n338), .Y(
        n329) );
  sky130_fd_sc_hd__a22oi_1 U559 ( .A1(s_mem_q[107]), .A2(n73), .B1(s_mem_q[99]), .B2(n193), .Y(n337) );
  sky130_fd_sc_hd__a22oi_1 U560 ( .A1(s_mem_q[75]), .A2(n195), .B1(s_mem_q[67]), .B2(n196), .Y(n335) );
  sky130_fd_sc_hd__o21ai_1 U561 ( .A1(n339), .A2(n340), .B1(n169), .Y(n316) );
  sky130_fd_sc_hd__nand4_1 U562 ( .A(n341), .B(n342), .C(n343), .D(n344), .Y(
        n340) );
  sky130_fd_sc_hd__a22oi_1 U563 ( .A1(s_mem_q[443]), .A2(n92), .B1(
        s_mem_q[435]), .B2(n574), .Y(n344) );
  sky130_fd_sc_hd__a22oi_1 U564 ( .A1(s_mem_q[427]), .A2(n181), .B1(
        s_mem_q[419]), .B2(n182), .Y(n343) );
  sky130_fd_sc_hd__a22oi_1 U565 ( .A1(s_mem_q[411]), .A2(n183), .B1(
        s_mem_q[403]), .B2(n569), .Y(n342) );
  sky130_fd_sc_hd__a22oi_1 U566 ( .A1(s_mem_q[395]), .A2(n185), .B1(
        s_mem_q[387]), .B2(n186), .Y(n341) );
  sky130_fd_sc_hd__nand4_1 U567 ( .A(n345), .B(n346), .C(n347), .D(n348), .Y(
        n339) );
  sky130_fd_sc_hd__a22oi_1 U568 ( .A1(s_mem_q[507]), .A2(n100), .B1(
        s_mem_q[499]), .B2(n191), .Y(n348) );
  sky130_fd_sc_hd__a22oi_1 U569 ( .A1(s_mem_q[491]), .A2(n192), .B1(
        s_mem_q[483]), .B2(n572), .Y(n347) );
  sky130_fd_sc_hd__a22oi_1 U570 ( .A1(s_mem_q[475]), .A2(n97), .B1(
        s_mem_q[467]), .B2(n30), .Y(n346) );
  sky130_fd_sc_hd__a22oi_1 U571 ( .A1(s_mem_q[459]), .A2(n195), .B1(
        s_mem_q[451]), .B2(n196), .Y(n345) );
  sky130_fd_sc_hd__o21ai_1 U572 ( .A1(n349), .A2(n350), .B1(n167), .Y(n315) );
  sky130_fd_sc_hd__nand4_1 U573 ( .A(n351), .B(n352), .C(n353), .D(n354), .Y(
        n350) );
  sky130_fd_sc_hd__a22oi_1 U574 ( .A1(s_mem_q[315]), .A2(n92), .B1(
        s_mem_q[307]), .B2(n574), .Y(n354) );
  sky130_fd_sc_hd__a22oi_1 U575 ( .A1(s_mem_q[299]), .A2(n181), .B1(
        s_mem_q[291]), .B2(n182), .Y(n353) );
  sky130_fd_sc_hd__a22oi_1 U576 ( .A1(s_mem_q[283]), .A2(n183), .B1(
        s_mem_q[275]), .B2(n570), .Y(n352) );
  sky130_fd_sc_hd__a22oi_1 U577 ( .A1(s_mem_q[267]), .A2(n185), .B1(
        s_mem_q[259]), .B2(n186), .Y(n351) );
  sky130_fd_sc_hd__nand4_1 U578 ( .A(n355), .B(n356), .C(n357), .D(n358), .Y(
        n349) );
  sky130_fd_sc_hd__a22oi_1 U579 ( .A1(s_mem_q[379]), .A2(n160), .B1(
        s_mem_q[371]), .B2(n191), .Y(n358) );
  sky130_fd_sc_hd__a22oi_1 U580 ( .A1(s_mem_q[363]), .A2(n192), .B1(
        s_mem_q[355]), .B2(n193), .Y(n357) );
  sky130_fd_sc_hd__a22oi_1 U581 ( .A1(s_mem_q[347]), .A2(n98), .B1(
        s_mem_q[339]), .B2(n30), .Y(n356) );
  sky130_fd_sc_hd__a22oi_1 U582 ( .A1(s_mem_q[331]), .A2(n195), .B1(
        s_mem_q[323]), .B2(n196), .Y(n355) );
  sky130_fd_sc_hd__nand4_1 U583 ( .A(n359), .B(n362), .C(n361), .D(n360), .Y(
        dat_o[4]) );
  sky130_fd_sc_hd__o21ai_1 U584 ( .A1(n363), .A2(n364), .B1(n168), .Y(n362) );
  sky130_fd_sc_hd__nand4_1 U585 ( .A(n365), .B(n366), .C(n367), .D(n368), .Y(
        n364) );
  sky130_fd_sc_hd__a22oi_1 U586 ( .A1(s_mem_q[188]), .A2(n180), .B1(
        s_mem_q[180]), .B2(n574), .Y(n368) );
  sky130_fd_sc_hd__a22oi_1 U587 ( .A1(s_mem_q[172]), .A2(n181), .B1(
        s_mem_q[164]), .B2(n182), .Y(n367) );
  sky130_fd_sc_hd__a22oi_1 U588 ( .A1(s_mem_q[156]), .A2(n183), .B1(
        s_mem_q[148]), .B2(n569), .Y(n366) );
  sky130_fd_sc_hd__a22oi_1 U589 ( .A1(s_mem_q[140]), .A2(n61), .B1(
        s_mem_q[132]), .B2(n186), .Y(n365) );
  sky130_fd_sc_hd__nand4_1 U590 ( .A(n369), .B(n370), .C(n371), .D(n372), .Y(
        n363) );
  sky130_fd_sc_hd__a22oi_1 U591 ( .A1(s_mem_q[204]), .A2(n195), .B1(
        s_mem_q[196]), .B2(n196), .Y(n369) );
  sky130_fd_sc_hd__o21ai_1 U592 ( .A1(n373), .A2(n374), .B1(n163), .Y(n361) );
  sky130_fd_sc_hd__nand4_1 U593 ( .A(n375), .B(n376), .C(n377), .D(n378), .Y(
        n374) );
  sky130_fd_sc_hd__a22oi_1 U594 ( .A1(s_mem_q[60]), .A2(n180), .B1(s_mem_q[52]), .B2(n574), .Y(n378) );
  sky130_fd_sc_hd__a22oi_1 U595 ( .A1(s_mem_q[44]), .A2(n181), .B1(s_mem_q[36]), .B2(n182), .Y(n377) );
  sky130_fd_sc_hd__a22oi_1 U596 ( .A1(s_mem_q[28]), .A2(n183), .B1(s_mem_q[20]), .B2(n569), .Y(n376) );
  sky130_fd_sc_hd__a22oi_1 U597 ( .A1(s_mem_q[12]), .A2(n61), .B1(s_mem_q[4]), 
        .B2(n186), .Y(n375) );
  sky130_fd_sc_hd__nand4_1 U598 ( .A(n379), .B(n380), .C(n381), .D(n382), .Y(
        n373) );
  sky130_fd_sc_hd__a22oi_1 U599 ( .A1(s_mem_q[108]), .A2(n192), .B1(
        s_mem_q[100]), .B2(n193), .Y(n381) );
  sky130_fd_sc_hd__a22oi_1 U600 ( .A1(s_mem_q[76]), .A2(n195), .B1(s_mem_q[68]), .B2(n196), .Y(n379) );
  sky130_fd_sc_hd__o21ai_1 U601 ( .A1(n383), .A2(n384), .B1(n169), .Y(n360) );
  sky130_fd_sc_hd__nand4_1 U602 ( .A(n385), .B(n386), .C(n387), .D(n388), .Y(
        n384) );
  sky130_fd_sc_hd__a22oi_1 U603 ( .A1(s_mem_q[444]), .A2(n180), .B1(
        s_mem_q[436]), .B2(n573), .Y(n388) );
  sky130_fd_sc_hd__a22oi_1 U604 ( .A1(s_mem_q[428]), .A2(n181), .B1(
        s_mem_q[420]), .B2(n182), .Y(n387) );
  sky130_fd_sc_hd__a22oi_1 U605 ( .A1(s_mem_q[412]), .A2(n183), .B1(
        s_mem_q[404]), .B2(n569), .Y(n386) );
  sky130_fd_sc_hd__a22oi_1 U606 ( .A1(s_mem_q[396]), .A2(n61), .B1(
        s_mem_q[388]), .B2(n186), .Y(n385) );
  sky130_fd_sc_hd__nand4_1 U607 ( .A(n390), .B(n389), .C(n391), .D(n392), .Y(
        n383) );
  sky130_fd_sc_hd__a22oi_1 U608 ( .A1(s_mem_q[508]), .A2(n100), .B1(
        s_mem_q[500]), .B2(n191), .Y(n392) );
  sky130_fd_sc_hd__a22oi_1 U609 ( .A1(s_mem_q[492]), .A2(n192), .B1(
        s_mem_q[484]), .B2(n572), .Y(n391) );
  sky130_fd_sc_hd__a22oi_1 U610 ( .A1(s_mem_q[476]), .A2(n98), .B1(
        s_mem_q[468]), .B2(n194), .Y(n390) );
  sky130_fd_sc_hd__o21ai_1 U611 ( .A1(n393), .A2(n394), .B1(n167), .Y(n359) );
  sky130_fd_sc_hd__nand4_1 U612 ( .A(n395), .B(n396), .C(n397), .D(n398), .Y(
        n394) );
  sky130_fd_sc_hd__a22oi_1 U613 ( .A1(s_mem_q[316]), .A2(n180), .B1(
        s_mem_q[308]), .B2(n573), .Y(n398) );
  sky130_fd_sc_hd__a22oi_1 U614 ( .A1(s_mem_q[300]), .A2(n181), .B1(
        s_mem_q[292]), .B2(n182), .Y(n397) );
  sky130_fd_sc_hd__a22oi_1 U615 ( .A1(s_mem_q[284]), .A2(n183), .B1(
        s_mem_q[276]), .B2(n570), .Y(n396) );
  sky130_fd_sc_hd__a22oi_1 U616 ( .A1(s_mem_q[268]), .A2(n61), .B1(
        s_mem_q[260]), .B2(n186), .Y(n395) );
  sky130_fd_sc_hd__nand4_1 U617 ( .A(n399), .B(n400), .C(n401), .D(n402), .Y(
        n393) );
  sky130_fd_sc_hd__a22oi_1 U618 ( .A1(s_mem_q[380]), .A2(n160), .B1(
        s_mem_q[372]), .B2(n191), .Y(n402) );
  sky130_fd_sc_hd__a22oi_1 U619 ( .A1(s_mem_q[364]), .A2(n192), .B1(
        s_mem_q[356]), .B2(n572), .Y(n401) );
  sky130_fd_sc_hd__a22oi_1 U620 ( .A1(s_mem_q[348]), .A2(n98), .B1(
        s_mem_q[340]), .B2(n194), .Y(n400) );
  sky130_fd_sc_hd__a22oi_1 U621 ( .A1(s_mem_q[332]), .A2(n195), .B1(
        s_mem_q[324]), .B2(n196), .Y(n399) );
  sky130_fd_sc_hd__nand4_1 U622 ( .A(n403), .B(n404), .C(n405), .D(n406), .Y(
        dat_o[5]) );
  sky130_fd_sc_hd__o21ai_1 U623 ( .A1(n407), .A2(n408), .B1(n168), .Y(n406) );
  sky130_fd_sc_hd__nand4_1 U624 ( .A(n409), .B(n410), .C(n411), .D(n412), .Y(
        n408) );
  sky130_fd_sc_hd__a22oi_1 U625 ( .A1(s_mem_q[189]), .A2(n180), .B1(
        s_mem_q[181]), .B2(n573), .Y(n412) );
  sky130_fd_sc_hd__a22oi_1 U626 ( .A1(s_mem_q[173]), .A2(n568), .B1(
        s_mem_q[165]), .B2(n182), .Y(n411) );
  sky130_fd_sc_hd__a22oi_1 U627 ( .A1(s_mem_q[157]), .A2(n88), .B1(
        s_mem_q[149]), .B2(n570), .Y(n410) );
  sky130_fd_sc_hd__a22oi_1 U628 ( .A1(s_mem_q[141]), .A2(n185), .B1(
        s_mem_q[133]), .B2(n186), .Y(n409) );
  sky130_fd_sc_hd__nand4_1 U629 ( .A(n413), .B(n414), .C(n415), .D(n416), .Y(
        n407) );
  sky130_fd_sc_hd__a22oi_1 U630 ( .A1(s_mem_q[253]), .A2(n160), .B1(
        s_mem_q[245]), .B2(n191), .Y(n416) );
  sky130_fd_sc_hd__a22oi_1 U631 ( .A1(s_mem_q[221]), .A2(n97), .B1(
        s_mem_q[213]), .B2(n194), .Y(n414) );
  sky130_fd_sc_hd__a22oi_1 U632 ( .A1(s_mem_q[205]), .A2(n68), .B1(
        s_mem_q[197]), .B2(n196), .Y(n413) );
  sky130_fd_sc_hd__o21ai_1 U633 ( .A1(n417), .A2(n418), .B1(n163), .Y(n405) );
  sky130_fd_sc_hd__nand4_1 U634 ( .A(n419), .B(n420), .C(n421), .D(n422), .Y(
        n418) );
  sky130_fd_sc_hd__a22oi_1 U635 ( .A1(s_mem_q[61]), .A2(n180), .B1(s_mem_q[53]), .B2(n573), .Y(n422) );
  sky130_fd_sc_hd__a22oi_1 U636 ( .A1(s_mem_q[45]), .A2(n567), .B1(s_mem_q[37]), .B2(n182), .Y(n421) );
  sky130_fd_sc_hd__a22oi_1 U637 ( .A1(s_mem_q[29]), .A2(n70), .B1(s_mem_q[21]), 
        .B2(n570), .Y(n420) );
  sky130_fd_sc_hd__a22oi_1 U638 ( .A1(s_mem_q[13]), .A2(n185), .B1(s_mem_q[5]), 
        .B2(n186), .Y(n419) );
  sky130_fd_sc_hd__nand4_1 U639 ( .A(n423), .B(n424), .C(n425), .D(n426), .Y(
        n417) );
  sky130_fd_sc_hd__a22oi_1 U640 ( .A1(s_mem_q[125]), .A2(n160), .B1(
        s_mem_q[117]), .B2(n191), .Y(n426) );
  sky130_fd_sc_hd__a22oi_1 U641 ( .A1(s_mem_q[109]), .A2(n192), .B1(
        s_mem_q[101]), .B2(n193), .Y(n425) );
  sky130_fd_sc_hd__a22oi_1 U642 ( .A1(s_mem_q[93]), .A2(n97), .B1(s_mem_q[85]), 
        .B2(n194), .Y(n424) );
  sky130_fd_sc_hd__a22oi_1 U643 ( .A1(s_mem_q[77]), .A2(n68), .B1(s_mem_q[69]), 
        .B2(n196), .Y(n423) );
  sky130_fd_sc_hd__o21ai_1 U644 ( .A1(n427), .A2(n428), .B1(n169), .Y(n404) );
  sky130_fd_sc_hd__nand4_1 U645 ( .A(n429), .B(n430), .C(n431), .D(n432), .Y(
        n428) );
  sky130_fd_sc_hd__a22oi_1 U646 ( .A1(s_mem_q[445]), .A2(n92), .B1(
        s_mem_q[437]), .B2(n574), .Y(n432) );
  sky130_fd_sc_hd__a22oi_1 U647 ( .A1(s_mem_q[429]), .A2(n568), .B1(
        s_mem_q[421]), .B2(n182), .Y(n431) );
  sky130_fd_sc_hd__a22oi_1 U648 ( .A1(s_mem_q[413]), .A2(n70), .B1(
        s_mem_q[405]), .B2(n570), .Y(n430) );
  sky130_fd_sc_hd__a22oi_1 U649 ( .A1(s_mem_q[397]), .A2(n185), .B1(
        s_mem_q[389]), .B2(n186), .Y(n429) );
  sky130_fd_sc_hd__nand4_1 U650 ( .A(n433), .B(n434), .C(n435), .D(n436), .Y(
        n427) );
  sky130_fd_sc_hd__a22oi_1 U651 ( .A1(s_mem_q[509]), .A2(n160), .B1(
        s_mem_q[501]), .B2(n191), .Y(n436) );
  sky130_fd_sc_hd__a22oi_1 U652 ( .A1(s_mem_q[493]), .A2(n73), .B1(
        s_mem_q[485]), .B2(n193), .Y(n435) );
  sky130_fd_sc_hd__a22oi_1 U653 ( .A1(s_mem_q[477]), .A2(n98), .B1(
        s_mem_q[469]), .B2(n194), .Y(n434) );
  sky130_fd_sc_hd__a22oi_1 U654 ( .A1(s_mem_q[461]), .A2(n68), .B1(
        s_mem_q[453]), .B2(n196), .Y(n433) );
  sky130_fd_sc_hd__o21ai_1 U655 ( .A1(n437), .A2(n438), .B1(n167), .Y(n403) );
  sky130_fd_sc_hd__nand4_1 U656 ( .A(n439), .B(n440), .C(n441), .D(n442), .Y(
        n438) );
  sky130_fd_sc_hd__a22oi_1 U657 ( .A1(s_mem_q[317]), .A2(n92), .B1(
        s_mem_q[309]), .B2(n574), .Y(n442) );
  sky130_fd_sc_hd__a22oi_1 U658 ( .A1(s_mem_q[301]), .A2(n568), .B1(
        s_mem_q[293]), .B2(n182), .Y(n441) );
  sky130_fd_sc_hd__a22oi_1 U659 ( .A1(s_mem_q[285]), .A2(n70), .B1(
        s_mem_q[277]), .B2(n569), .Y(n440) );
  sky130_fd_sc_hd__a22oi_1 U660 ( .A1(s_mem_q[269]), .A2(n185), .B1(
        s_mem_q[261]), .B2(n186), .Y(n439) );
  sky130_fd_sc_hd__nand4_1 U661 ( .A(n443), .B(n444), .C(n445), .D(n446), .Y(
        n437) );
  sky130_fd_sc_hd__a22oi_1 U662 ( .A1(s_mem_q[381]), .A2(n100), .B1(
        s_mem_q[373]), .B2(n191), .Y(n446) );
  sky130_fd_sc_hd__a22oi_1 U663 ( .A1(s_mem_q[365]), .A2(n73), .B1(
        s_mem_q[357]), .B2(n193), .Y(n445) );
  sky130_fd_sc_hd__a22oi_1 U664 ( .A1(s_mem_q[349]), .A2(n98), .B1(
        s_mem_q[341]), .B2(n30), .Y(n444) );
  sky130_fd_sc_hd__a22oi_1 U665 ( .A1(s_mem_q[333]), .A2(n68), .B1(
        s_mem_q[325]), .B2(n196), .Y(n443) );
  sky130_fd_sc_hd__nand4_1 U666 ( .A(n447), .B(n448), .C(n449), .D(n450), .Y(
        dat_o[6]) );
  sky130_fd_sc_hd__o21ai_1 U667 ( .A1(n451), .A2(n452), .B1(n168), .Y(n450) );
  sky130_fd_sc_hd__nand4_1 U668 ( .A(n453), .B(n454), .C(n455), .D(n456), .Y(
        n452) );
  sky130_fd_sc_hd__a22oi_1 U669 ( .A1(s_mem_q[174]), .A2(n568), .B1(
        s_mem_q[166]), .B2(n182), .Y(n455) );
  sky130_fd_sc_hd__a22oi_1 U670 ( .A1(s_mem_q[142]), .A2(n61), .B1(
        s_mem_q[134]), .B2(n186), .Y(n453) );
  sky130_fd_sc_hd__nand4_1 U671 ( .A(n457), .B(n458), .C(n459), .D(n460), .Y(
        n451) );
  sky130_fd_sc_hd__a22oi_1 U672 ( .A1(s_mem_q[254]), .A2(n160), .B1(
        s_mem_q[246]), .B2(n191), .Y(n460) );
  sky130_fd_sc_hd__a22oi_1 U673 ( .A1(s_mem_q[222]), .A2(n97), .B1(
        s_mem_q[214]), .B2(n30), .Y(n458) );
  sky130_fd_sc_hd__a22oi_1 U674 ( .A1(s_mem_q[206]), .A2(n68), .B1(
        s_mem_q[198]), .B2(n196), .Y(n457) );
  sky130_fd_sc_hd__o21ai_1 U675 ( .A1(n461), .A2(n462), .B1(n163), .Y(n449) );
  sky130_fd_sc_hd__nand4_1 U676 ( .A(n463), .B(n464), .C(n465), .D(n466), .Y(
        n462) );
  sky130_fd_sc_hd__a22oi_1 U677 ( .A1(s_mem_q[62]), .A2(n180), .B1(s_mem_q[54]), .B2(n574), .Y(n466) );
  sky130_fd_sc_hd__a22oi_1 U678 ( .A1(s_mem_q[46]), .A2(n568), .B1(s_mem_q[38]), .B2(n182), .Y(n465) );
  sky130_fd_sc_hd__a22oi_1 U679 ( .A1(s_mem_q[30]), .A2(n70), .B1(s_mem_q[22]), 
        .B2(n570), .Y(n464) );
  sky130_fd_sc_hd__a22oi_1 U680 ( .A1(s_mem_q[14]), .A2(n61), .B1(s_mem_q[6]), 
        .B2(n186), .Y(n463) );
  sky130_fd_sc_hd__nand4_1 U681 ( .A(n467), .B(n468), .C(n469), .D(n470), .Y(
        n461) );
  sky130_fd_sc_hd__a22oi_1 U682 ( .A1(s_mem_q[126]), .A2(n160), .B1(
        s_mem_q[118]), .B2(n191), .Y(n470) );
  sky130_fd_sc_hd__a22oi_1 U683 ( .A1(s_mem_q[110]), .A2(n73), .B1(
        s_mem_q[102]), .B2(n572), .Y(n469) );
  sky130_fd_sc_hd__a22oi_1 U684 ( .A1(s_mem_q[94]), .A2(n97), .B1(s_mem_q[86]), 
        .B2(n30), .Y(n468) );
  sky130_fd_sc_hd__a22oi_1 U685 ( .A1(s_mem_q[78]), .A2(n68), .B1(s_mem_q[70]), 
        .B2(n196), .Y(n467) );
  sky130_fd_sc_hd__o21ai_1 U686 ( .A1(n471), .A2(n472), .B1(n169), .Y(n448) );
  sky130_fd_sc_hd__nand4_1 U687 ( .A(n475), .B(n474), .C(n473), .D(n476), .Y(
        n472) );
  sky130_fd_sc_hd__a22oi_1 U688 ( .A1(s_mem_q[446]), .A2(n92), .B1(
        s_mem_q[438]), .B2(n574), .Y(n476) );
  sky130_fd_sc_hd__a22oi_1 U689 ( .A1(s_mem_q[430]), .A2(n568), .B1(
        s_mem_q[422]), .B2(n182), .Y(n475) );
  sky130_fd_sc_hd__a22oi_1 U690 ( .A1(s_mem_q[398]), .A2(n185), .B1(
        s_mem_q[390]), .B2(n186), .Y(n473) );
  sky130_fd_sc_hd__nand4_1 U691 ( .A(n477), .B(n478), .C(n479), .D(n480), .Y(
        n471) );
  sky130_fd_sc_hd__a22oi_1 U692 ( .A1(s_mem_q[510]), .A2(n160), .B1(
        s_mem_q[502]), .B2(n191), .Y(n480) );
  sky130_fd_sc_hd__a22oi_1 U693 ( .A1(s_mem_q[462]), .A2(n68), .B1(
        s_mem_q[454]), .B2(n196), .Y(n477) );
  sky130_fd_sc_hd__o21ai_1 U694 ( .A1(n481), .A2(n482), .B1(n167), .Y(n447) );
  sky130_fd_sc_hd__nand4_1 U695 ( .A(n483), .B(n484), .C(n485), .D(n486), .Y(
        n482) );
  sky130_fd_sc_hd__a22oi_1 U696 ( .A1(s_mem_q[318]), .A2(n92), .B1(
        s_mem_q[310]), .B2(n574), .Y(n486) );
  sky130_fd_sc_hd__a22oi_1 U697 ( .A1(s_mem_q[302]), .A2(n568), .B1(
        s_mem_q[294]), .B2(n182), .Y(n485) );
  sky130_fd_sc_hd__a22oi_1 U698 ( .A1(s_mem_q[286]), .A2(n70), .B1(
        s_mem_q[278]), .B2(n570), .Y(n484) );
  sky130_fd_sc_hd__a22oi_1 U699 ( .A1(s_mem_q[270]), .A2(n61), .B1(
        s_mem_q[262]), .B2(n186), .Y(n483) );
  sky130_fd_sc_hd__nand4_1 U700 ( .A(n487), .B(n488), .C(n489), .D(n490), .Y(
        n481) );
  sky130_fd_sc_hd__a22oi_1 U701 ( .A1(s_mem_q[382]), .A2(n100), .B1(
        s_mem_q[374]), .B2(n571), .Y(n490) );
  sky130_fd_sc_hd__a22oi_1 U702 ( .A1(s_mem_q[366]), .A2(n192), .B1(
        s_mem_q[358]), .B2(n572), .Y(n489) );
  sky130_fd_sc_hd__a22oi_1 U703 ( .A1(s_mem_q[350]), .A2(n98), .B1(
        s_mem_q[342]), .B2(n194), .Y(n488) );
  sky130_fd_sc_hd__a22oi_1 U704 ( .A1(s_mem_q[334]), .A2(n68), .B1(
        s_mem_q[326]), .B2(n196), .Y(n487) );
  sky130_fd_sc_hd__nand4_1 U705 ( .A(n491), .B(n492), .C(n493), .D(n494), .Y(
        dat_o[7]) );
  sky130_fd_sc_hd__o21ai_1 U706 ( .A1(n495), .A2(n496), .B1(n168), .Y(n494) );
  sky130_fd_sc_hd__nand4_1 U707 ( .A(n498), .B(n499), .C(n500), .D(n501), .Y(
        n496) );
  sky130_fd_sc_hd__a22oi_1 U708 ( .A1(s_mem_q[191]), .A2(n92), .B1(
        s_mem_q[183]), .B2(n573), .Y(n501) );
  sky130_fd_sc_hd__a22oi_1 U709 ( .A1(s_mem_q[175]), .A2(n181), .B1(
        s_mem_q[167]), .B2(n182), .Y(n500) );
  sky130_fd_sc_hd__a22oi_1 U710 ( .A1(s_mem_q[159]), .A2(n88), .B1(
        s_mem_q[151]), .B2(n570), .Y(n499) );
  sky130_fd_sc_hd__a22oi_1 U711 ( .A1(s_mem_q[143]), .A2(n185), .B1(
        s_mem_q[135]), .B2(n186), .Y(n498) );
  sky130_fd_sc_hd__nand4_1 U712 ( .A(n502), .B(n503), .C(n504), .D(n505), .Y(
        n495) );
  sky130_fd_sc_hd__a22oi_1 U713 ( .A1(s_mem_q[255]), .A2(n160), .B1(
        s_mem_q[247]), .B2(n191), .Y(n505) );
  sky130_fd_sc_hd__a22oi_1 U714 ( .A1(s_mem_q[239]), .A2(n192), .B1(
        s_mem_q[231]), .B2(n193), .Y(n504) );
  sky130_fd_sc_hd__a22oi_1 U715 ( .A1(s_mem_q[223]), .A2(n98), .B1(
        s_mem_q[215]), .B2(n30), .Y(n503) );
  sky130_fd_sc_hd__a22oi_1 U716 ( .A1(s_mem_q[207]), .A2(n195), .B1(
        s_mem_q[199]), .B2(n196), .Y(n502) );
  sky130_fd_sc_hd__o21ai_1 U717 ( .A1(n506), .A2(n507), .B1(n163), .Y(n493) );
  sky130_fd_sc_hd__inv_1 U718 ( .A(N80), .Y(n497) );
  sky130_fd_sc_hd__nand4_1 U719 ( .A(n509), .B(n510), .C(n511), .D(n512), .Y(
        n507) );
  sky130_fd_sc_hd__a22oi_1 U720 ( .A1(s_mem_q[63]), .A2(n92), .B1(s_mem_q[55]), 
        .B2(n574), .Y(n512) );
  sky130_fd_sc_hd__a22oi_1 U721 ( .A1(s_mem_q[47]), .A2(n181), .B1(s_mem_q[39]), .B2(n182), .Y(n511) );
  sky130_fd_sc_hd__a22oi_1 U722 ( .A1(s_mem_q[31]), .A2(n88), .B1(s_mem_q[23]), 
        .B2(n570), .Y(n510) );
  sky130_fd_sc_hd__a22oi_1 U723 ( .A1(s_mem_q[15]), .A2(n61), .B1(s_mem_q[7]), 
        .B2(n186), .Y(n509) );
  sky130_fd_sc_hd__nand4_1 U724 ( .A(n513), .B(n514), .C(n515), .D(n516), .Y(
        n506) );
  sky130_fd_sc_hd__a22oi_1 U725 ( .A1(s_mem_q[127]), .A2(n160), .B1(
        s_mem_q[119]), .B2(n571), .Y(n516) );
  sky130_fd_sc_hd__a22oi_1 U726 ( .A1(s_mem_q[111]), .A2(n192), .B1(
        s_mem_q[103]), .B2(n572), .Y(n515) );
  sky130_fd_sc_hd__a22oi_1 U727 ( .A1(s_mem_q[95]), .A2(n98), .B1(s_mem_q[87]), 
        .B2(n194), .Y(n514) );
  sky130_fd_sc_hd__a22oi_1 U728 ( .A1(s_mem_q[79]), .A2(n195), .B1(s_mem_q[71]), .B2(n196), .Y(n513) );
  sky130_fd_sc_hd__o21ai_1 U729 ( .A1(n517), .A2(n518), .B1(n169), .Y(n492) );
  sky130_fd_sc_hd__nand4_1 U730 ( .A(n519), .B(n520), .C(n521), .D(n522), .Y(
        n518) );
  sky130_fd_sc_hd__a22oi_1 U731 ( .A1(s_mem_q[447]), .A2(n92), .B1(
        s_mem_q[439]), .B2(n574), .Y(n522) );
  sky130_fd_sc_hd__a22oi_1 U732 ( .A1(s_mem_q[431]), .A2(n181), .B1(
        s_mem_q[423]), .B2(n182), .Y(n521) );
  sky130_fd_sc_hd__a22oi_1 U733 ( .A1(s_mem_q[415]), .A2(n88), .B1(
        s_mem_q[407]), .B2(n570), .Y(n520) );
  sky130_fd_sc_hd__a22oi_1 U734 ( .A1(s_mem_q[399]), .A2(n185), .B1(
        s_mem_q[391]), .B2(n186), .Y(n519) );
  sky130_fd_sc_hd__nand4_1 U735 ( .A(n523), .B(n524), .C(n525), .D(n526), .Y(
        n517) );
  sky130_fd_sc_hd__a22oi_1 U736 ( .A1(s_mem_q[511]), .A2(n160), .B1(
        s_mem_q[503]), .B2(n191), .Y(n526) );
  sky130_fd_sc_hd__a22oi_1 U737 ( .A1(s_mem_q[495]), .A2(n73), .B1(
        s_mem_q[487]), .B2(n572), .Y(n525) );
  sky130_fd_sc_hd__a22oi_1 U738 ( .A1(s_mem_q[479]), .A2(n98), .B1(
        s_mem_q[471]), .B2(n30), .Y(n524) );
  sky130_fd_sc_hd__a22oi_1 U739 ( .A1(s_mem_q[463]), .A2(n68), .B1(
        s_mem_q[455]), .B2(n196), .Y(n523) );
  sky130_fd_sc_hd__o21ai_1 U740 ( .A1(n527), .A2(n528), .B1(n167), .Y(n491) );
  sky130_fd_sc_hd__nand4_1 U741 ( .A(n529), .B(n530), .C(n531), .D(n532), .Y(
        n528) );
  sky130_fd_sc_hd__a22oi_1 U742 ( .A1(s_mem_q[319]), .A2(n180), .B1(
        s_mem_q[311]), .B2(n574), .Y(n532) );
  sky130_fd_sc_hd__nand2_1 U743 ( .A(n534), .B(n29), .Y(n533) );
  sky130_fd_sc_hd__a22oi_1 U744 ( .A1(s_mem_q[303]), .A2(n567), .B1(
        s_mem_q[295]), .B2(n182), .Y(n531) );
  sky130_fd_sc_hd__nand2_1 U745 ( .A(n534), .B(n538), .Y(n537) );
  sky130_fd_sc_hd__a22oi_1 U746 ( .A1(s_mem_q[287]), .A2(n88), .B1(
        s_mem_q[279]), .B2(n570), .Y(n530) );
  sky130_fd_sc_hd__nand2_1 U747 ( .A(n29), .B(n544), .Y(n543) );
  sky130_fd_sc_hd__a22oi_1 U748 ( .A1(s_mem_q[271]), .A2(n61), .B1(
        s_mem_q[263]), .B2(n186), .Y(n529) );
  sky130_fd_sc_hd__nand2_1 U749 ( .A(n538), .B(n544), .Y(n546) );
  sky130_fd_sc_hd__nand2_1 U750 ( .A(n540), .B(n544), .Y(n547) );
  sky130_fd_sc_hd__nand4_1 U751 ( .A(n550), .B(n551), .C(n552), .D(n553), .Y(
        n527) );
  sky130_fd_sc_hd__a22oi_1 U752 ( .A1(s_mem_q[383]), .A2(n160), .B1(
        s_mem_q[375]), .B2(n571), .Y(n553) );
  sky130_fd_sc_hd__a22oi_1 U753 ( .A1(s_mem_q[367]), .A2(n73), .B1(
        s_mem_q[359]), .B2(n193), .Y(n552) );
  sky130_fd_sc_hd__nand2_1 U754 ( .A(n555), .B(n538), .Y(n556) );
  sky130_fd_sc_hd__nand2_1 U755 ( .A(N77), .B(N78), .Y(n558) );
  sky130_fd_sc_hd__a22oi_1 U756 ( .A1(s_mem_q[351]), .A2(n98), .B1(
        s_mem_q[343]), .B2(n194), .Y(n551) );
  sky130_fd_sc_hd__nand2_1 U757 ( .A(n560), .B(n29), .Y(n559) );
  sky130_fd_sc_hd__nand2_1 U758 ( .A(n4), .B(N76), .Y(n561) );
  sky130_fd_sc_hd__a22oi_1 U759 ( .A1(s_mem_q[335]), .A2(n68), .B1(
        s_mem_q[327]), .B2(n196), .Y(n550) );
  sky130_fd_sc_hd__nand2_1 U760 ( .A(n560), .B(n538), .Y(n562) );
  sky130_fd_sc_hd__nand2_1 U761 ( .A(n632), .B(n4), .Y(n563) );
  sky130_fd_sc_hd__nand2_1 U762 ( .A(n560), .B(n540), .Y(n564) );
  sky130_fd_sc_hd__nand2_1 U763 ( .A(n632), .B(N75), .Y(n565) );
  sky130_fd_sc_hd__nand2_1 U764 ( .A(N78), .B(n549), .Y(n566) );
  sky130_fd_sc_hd__inv_1 U765 ( .A(N77), .Y(n549) );
  sky130_fd_sc_hd__inv_2 U766 ( .A(n565), .Y(n540) );
  sky130_fd_sc_hd__nand2_1 U767 ( .A(N77), .B(n542), .Y(n541) );
  sky130_fd_sc_hd__inv_2 U768 ( .A(n563), .Y(n538) );
  sky130_fd_sc_hd__inv_2 U769 ( .A(n541), .Y(n534) );
  sky130_fd_sc_hd__a22oi_1 U770 ( .A1(s_mem_q[478]), .A2(n98), .B1(
        s_mem_q[470]), .B2(n30), .Y(n478) );
  sky130_fd_sc_hd__inv_2 U771 ( .A(n566), .Y(n560) );
  sky130_fd_sc_hd__a22oi_1 U772 ( .A1(s_mem_q[414]), .A2(n70), .B1(
        s_mem_q[406]), .B2(n570), .Y(n474) );
  sky130_fd_sc_hd__inv_2 U773 ( .A(n548), .Y(n544) );
  sky130_fd_sc_hd__nand2_1 U774 ( .A(n549), .B(n542), .Y(n548) );
  sky130_fd_sc_hd__inv_1 U775 ( .A(N78), .Y(n542) );
  sky130_fd_sc_hd__inv_2 U776 ( .A(n556), .Y(n193) );
  sky130_fd_sc_hd__inv_2 U777 ( .A(n556), .Y(n572) );
  sky130_fd_sc_hd__inv_4 U778 ( .A(n562), .Y(n196) );
  sky130_fd_sc_hd__inv_4 U779 ( .A(n537), .Y(n182) );
  sky130_fd_sc_hd__inv_1 U780 ( .A(n533), .Y(n573) );
  sky130_fd_sc_hd__o21ai_0 U781 ( .A1(n91), .A2(n666), .B1(n96), .Y(n663) );
  sky130_fd_sc_hd__inv_2 U782 ( .A(n1362), .Y(n575) );
  sky130_fd_sc_hd__inv_2 U783 ( .A(n575), .Y(n577) );
  sky130_fd_sc_hd__inv_2 U784 ( .A(n575), .Y(n578) );
  sky130_fd_sc_hd__inv_2 U785 ( .A(n575), .Y(n579) );
  sky130_fd_sc_hd__inv_2 U786 ( .A(n575), .Y(n580) );
  sky130_fd_sc_hd__inv_2 U787 ( .A(n576), .Y(n582) );
  sky130_fd_sc_hd__inv_2 U788 ( .A(n576), .Y(n583) );
  sky130_fd_sc_hd__inv_2 U789 ( .A(n576), .Y(n584) );
  sky130_fd_sc_hd__inv_2 U790 ( .A(n576), .Y(n585) );
  sky130_fd_sc_hd__inv_2 U791 ( .A(n1364), .Y(n586) );
  sky130_fd_sc_hd__inv_2 U792 ( .A(n62), .Y(n587) );
  sky130_fd_sc_hd__inv_2 U793 ( .A(n586), .Y(n588) );
  sky130_fd_sc_hd__inv_2 U794 ( .A(n586), .Y(n589) );
  sky130_fd_sc_hd__inv_2 U795 ( .A(n586), .Y(n590) );
  sky130_fd_sc_hd__inv_2 U796 ( .A(n586), .Y(n591) );
  sky130_fd_sc_hd__inv_2 U797 ( .A(n587), .Y(n592) );
  sky130_fd_sc_hd__inv_2 U798 ( .A(n587), .Y(n593) );
  sky130_fd_sc_hd__inv_2 U799 ( .A(n587), .Y(n594) );
  sky130_fd_sc_hd__inv_2 U800 ( .A(n587), .Y(n595) );
  sky130_fd_sc_hd__inv_2 U801 ( .A(n587), .Y(n596) );
  sky130_fd_sc_hd__inv_2 U802 ( .A(n1366), .Y(n597) );
  sky130_fd_sc_hd__inv_2 U803 ( .A(n1366), .Y(n598) );
  sky130_fd_sc_hd__inv_2 U804 ( .A(n597), .Y(n599) );
  sky130_fd_sc_hd__inv_2 U805 ( .A(n597), .Y(n600) );
  sky130_fd_sc_hd__inv_2 U806 ( .A(n597), .Y(n601) );
  sky130_fd_sc_hd__inv_2 U807 ( .A(n597), .Y(n602) );
  sky130_fd_sc_hd__inv_2 U808 ( .A(n598), .Y(n603) );
  sky130_fd_sc_hd__inv_2 U809 ( .A(n598), .Y(n604) );
  sky130_fd_sc_hd__inv_2 U810 ( .A(n598), .Y(n605) );
  sky130_fd_sc_hd__inv_2 U811 ( .A(n598), .Y(n606) );
  sky130_fd_sc_hd__inv_2 U812 ( .A(n598), .Y(n607) );
  sky130_fd_sc_hd__inv_2 U813 ( .A(n1368), .Y(n608) );
  sky130_fd_sc_hd__inv_2 U814 ( .A(n1368), .Y(n609) );
  sky130_fd_sc_hd__inv_2 U815 ( .A(n608), .Y(n610) );
  sky130_fd_sc_hd__inv_2 U816 ( .A(n608), .Y(n611) );
  sky130_fd_sc_hd__inv_2 U817 ( .A(n608), .Y(n612) );
  sky130_fd_sc_hd__inv_2 U818 ( .A(n608), .Y(n613) );
  sky130_fd_sc_hd__inv_2 U819 ( .A(n608), .Y(n614) );
  sky130_fd_sc_hd__inv_2 U820 ( .A(n609), .Y(n615) );
  sky130_fd_sc_hd__inv_2 U821 ( .A(n609), .Y(n616) );
  sky130_fd_sc_hd__inv_2 U822 ( .A(n609), .Y(n617) );
  sky130_fd_sc_hd__inv_2 U823 ( .A(n609), .Y(n618) );
  sky130_fd_sc_hd__inv_2 U824 ( .A(n609), .Y(n619) );
  sky130_fd_sc_hd__inv_2 U825 ( .A(n1370), .Y(n620) );
  sky130_fd_sc_hd__inv_2 U826 ( .A(n1370), .Y(n621) );
  sky130_fd_sc_hd__inv_2 U827 ( .A(n620), .Y(n622) );
  sky130_fd_sc_hd__inv_2 U828 ( .A(n620), .Y(n623) );
  sky130_fd_sc_hd__inv_2 U829 ( .A(n620), .Y(n624) );
  sky130_fd_sc_hd__inv_2 U830 ( .A(n620), .Y(n625) );
  sky130_fd_sc_hd__inv_2 U831 ( .A(n621), .Y(n626) );
  sky130_fd_sc_hd__inv_2 U832 ( .A(n621), .Y(n627) );
  sky130_fd_sc_hd__inv_2 U833 ( .A(n621), .Y(n628) );
  sky130_fd_sc_hd__inv_2 U834 ( .A(n621), .Y(n629) );
  sky130_fd_sc_hd__inv_2 U835 ( .A(n621), .Y(n630) );
  sky130_fd_sc_hd__inv_1 U836 ( .A(n632), .Y(n633) );
  sky130_fd_sc_hd__inv_1 U837 ( .A(n1382), .Y(n634) );
  sky130_fd_sc_hd__inv_2 U838 ( .A(n634), .Y(n635) );
  sky130_fd_sc_hd__and2_4 U839 ( .A(n660), .B(n1376), .X(n637) );
  sky130_fd_sc_hd__inv_1 U840 ( .A(n4), .Y(n638) );
  sky130_fd_sc_hd__nand2_1 U841 ( .A(dat_i[0]), .B(n648), .Y(n640) );
  sky130_fd_sc_hd__ha_1 U842 ( .A(n633), .B(n638), .COUT(\add_50/carry[2] ), 
        .SUM(N85) );
  sky130_fd_sc_hd__inv_1 U843 ( .A(n643), .Y(n1377) );
  sky130_fd_sc_hd__clkinv_1 U844 ( .A(cnt_o[6]), .Y(n688) );
  sky130_fd_sc_hd__inv_1 U845 ( .A(n673), .Y(n678) );
  sky130_fd_sc_hd__ha_1 U846 ( .A(n636), .B(\add_50/carry[2] ), .COUT(
        \add_50/carry[3] ), .SUM(N86) );
  sky130_fd_sc_hd__nor2_1 U847 ( .A(n631), .B(n680), .Y(n684) );
  sky130_fd_sc_hd__o21ai_0 U848 ( .A1(n162), .A2(n91), .B1(n96), .Y(n673) );
  sky130_fd_sc_hd__inv_2 U849 ( .A(n682), .Y(n696) );
  sky130_fd_sc_hd__inv_1 U850 ( .A(n1387), .Y(full_o) );
  sky130_fd_sc_hd__nor4_2 U851 ( .A(n1390), .B(cnt_o[5]), .C(cnt_o[0]), .D(
        n688), .Y(n659) );
  sky130_fd_sc_hd__inv_1 U852 ( .A(cnt_o[0]), .Y(n666) );
  sky130_fd_sc_hd__nand4_1 U853 ( .A(n658), .B(n65), .C(n666), .D(n677), .Y(
        n1386) );
  sky130_fd_sc_hd__nand2_1 U854 ( .A(pop_i), .B(n1386), .Y(n660) );
  sky130_fd_sc_hd__inv_1 U855 ( .A(flush_i), .Y(n1376) );
  sky130_fd_sc_hd__inv_1 U856 ( .A(cnt_o[2]), .Y(n669) );
  sky130_fd_sc_hd__nand2_1 U857 ( .A(n696), .B(n1377), .Y(n689) );
  sky130_fd_sc_hd__nand3_1 U858 ( .A(n1387), .B(n1376), .C(push_i), .Y(n1385)
         );
  sky130_fd_sc_hd__mux2i_1 U859 ( .A0(n631), .A1(n95), .S(cnt_o[0]), .Y(n662)
         );
  sky130_fd_sc_hd__a21o_1 U860 ( .A1(N108), .A2(n642), .B1(n662), .X(
        s_cnt_d[0]) );
  sky130_fd_sc_hd__nand2_1 U861 ( .A(n672), .B(n666), .Y(n664) );
  sky130_fd_sc_hd__a21o_1 U862 ( .A1(N109), .A2(n642), .B1(n665), .X(
        s_cnt_d[1]) );
  sky130_fd_sc_hd__a21oi_1 U863 ( .A1(cnt_o[2]), .A2(cnt_o[1]), .B1(n162), .Y(
        n671) );
  sky130_fd_sc_hd__nand2_1 U864 ( .A(N110), .B(n642), .Y(n668) );
  sky130_fd_sc_hd__o221ai_1 U865 ( .A1(n671), .A2(n631), .B1(n669), .B2(n1), 
        .C1(n668), .Y(s_cnt_d[2]) );
  sky130_fd_sc_hd__nand2_1 U866 ( .A(n162), .B(n672), .Y(n674) );
  sky130_fd_sc_hd__a21o_1 U867 ( .A1(N111), .A2(n642), .B1(n675), .X(
        s_cnt_d[3]) );
  sky130_fd_sc_hd__nand3_1 U868 ( .A(n162), .B(n65), .C(n677), .Y(n680) );
  sky130_fd_sc_hd__a21oi_1 U869 ( .A1(cnt_o[3]), .A2(cnt_o[4]), .B1(n683), .Y(
        n679) );
  sky130_fd_sc_hd__nand2_1 U870 ( .A(N112), .B(n642), .Y(n676) );
  sky130_fd_sc_hd__o221ai_1 U871 ( .A1(n679), .A2(n631), .B1(n678), .B2(n677), 
        .C1(n676), .Y(s_cnt_d[4]) );
  sky130_fd_sc_hd__o21ai_1 U872 ( .A1(n683), .A2(n91), .B1(n681), .Y(n691) );
  sky130_fd_sc_hd__mux2i_1 U873 ( .A0(n684), .A1(n691), .S(cnt_o[5]), .Y(n686)
         );
  sky130_fd_sc_hd__nand2_1 U874 ( .A(N113), .B(n642), .Y(n685) );
  sky130_fd_sc_hd__nand2_1 U875 ( .A(n686), .B(n685), .Y(s_cnt_d[5]) );
  sky130_fd_sc_hd__inv_1 U876 ( .A(cnt_o[5]), .Y(n687) );
  sky130_fd_sc_hd__nor3_1 U877 ( .A(n689), .B(n688), .C(n687), .Y(n690) );
  sky130_fd_sc_hd__a221o_1 U878 ( .A1(n691), .A2(cnt_o[6]), .B1(N114), .B2(
        n641), .C1(n690), .X(s_cnt_d[6]) );
  sky130_fd_sc_hd__inv_1 U879 ( .A(n638), .Y(n692) );
  sky130_fd_sc_hd__inv_1 U880 ( .A(n633), .Y(n693) );
  sky130_fd_sc_hd__inv_1 U881 ( .A(n636), .Y(n694) );
  sky130_fd_sc_hd__inv_1 U882 ( .A(n64), .Y(n695) );
  sky130_fd_sc_hd__o2bb2ai_1 U883 ( .B1(n697), .B2(n695), .A1_N(N87), .A2_N(
        n696), .Y(s_rd_ptr_d[3]) );
  sky130_fd_sc_hd__o2bb2ai_1 U884 ( .B1(n697), .B2(n508), .A1_N(N88), .A2_N(
        n696), .Y(s_rd_ptr_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U885 ( .B1(n697), .B2(n497), .A1_N(N89), .A2_N(
        n696), .Y(s_rd_ptr_d[5]) );
  sky130_fd_sc_hd__nand2_1 U886 ( .A(n166), .B(s_wr_ptr_q[5]), .Y(n698) );
  sky130_fd_sc_hd__nand2_1 U887 ( .A(n165), .B(s_wr_ptr_q[2]), .Y(n699) );
  sky130_fd_sc_hd__inv_1 U888 ( .A(s_mem_q[511]), .Y(n701) );
  sky130_fd_sc_hd__nand2_1 U889 ( .A(dat_i[7]), .B(n3), .Y(n1360) );
  sky130_fd_sc_hd__o22ai_1 U890 ( .A1(n156), .A2(n701), .B1(n649), .B2(n709), 
        .Y(s_mem_d[511]) );
  sky130_fd_sc_hd__inv_1 U891 ( .A(s_mem_q[510]), .Y(n702) );
  sky130_fd_sc_hd__o22ai_1 U892 ( .A1(n577), .A2(n709), .B1(n156), .B2(n702), 
        .Y(s_mem_d[510]) );
  sky130_fd_sc_hd__nand2_1 U893 ( .A(dat_i[5]), .B(n646), .Y(n1364) );
  sky130_fd_sc_hd__inv_1 U894 ( .A(s_mem_q[509]), .Y(n703) );
  sky130_fd_sc_hd__o22ai_1 U895 ( .A1(n588), .A2(n709), .B1(n156), .B2(n703), 
        .Y(s_mem_d[509]) );
  sky130_fd_sc_hd__nand2_1 U896 ( .A(dat_i[4]), .B(n648), .Y(n1366) );
  sky130_fd_sc_hd__inv_1 U897 ( .A(s_mem_q[508]), .Y(n704) );
  sky130_fd_sc_hd__o22ai_1 U898 ( .A1(n599), .A2(n709), .B1(n156), .B2(n704), 
        .Y(s_mem_d[508]) );
  sky130_fd_sc_hd__nand2_1 U899 ( .A(dat_i[3]), .B(n645), .Y(n1368) );
  sky130_fd_sc_hd__inv_1 U900 ( .A(s_mem_q[507]), .Y(n705) );
  sky130_fd_sc_hd__nand2_1 U901 ( .A(dat_i[2]), .B(n648), .Y(n1370) );
  sky130_fd_sc_hd__inv_1 U902 ( .A(s_mem_q[506]), .Y(n706) );
  sky130_fd_sc_hd__o22ai_1 U903 ( .A1(n622), .A2(n709), .B1(n156), .B2(n706), 
        .Y(s_mem_d[506]) );
  sky130_fd_sc_hd__nand2_1 U904 ( .A(dat_i[1]), .B(n647), .Y(n1372) );
  sky130_fd_sc_hd__inv_1 U905 ( .A(s_mem_q[505]), .Y(n707) );
  sky130_fd_sc_hd__o22ai_1 U906 ( .A1(n54), .A2(n709), .B1(n156), .B2(n707), 
        .Y(s_mem_d[505]) );
  sky130_fd_sc_hd__inv_1 U907 ( .A(s_mem_q[504]), .Y(n708) );
  sky130_fd_sc_hd__o22ai_1 U908 ( .A1(n99), .A2(n709), .B1(n156), .B2(n708), 
        .Y(s_mem_d[504]) );
  sky130_fd_sc_hd__inv_1 U909 ( .A(s_wr_ptr_q[0]), .Y(n776) );
  sky130_fd_sc_hd__nand3_1 U910 ( .A(s_wr_ptr_q[2]), .B(s_wr_ptr_q[1]), .C(
        n776), .Y(n710) );
  sky130_fd_sc_hd__inv_1 U911 ( .A(s_mem_q[503]), .Y(n712) );
  sky130_fd_sc_hd__o22ai_1 U912 ( .A1(n157), .A2(n712), .B1(n649), .B2(n719), 
        .Y(s_mem_d[503]) );
  sky130_fd_sc_hd__inv_1 U913 ( .A(s_mem_q[502]), .Y(n713) );
  sky130_fd_sc_hd__o22ai_1 U914 ( .A1(n157), .A2(n713), .B1(n580), .B2(n719), 
        .Y(s_mem_d[502]) );
  sky130_fd_sc_hd__inv_1 U915 ( .A(s_mem_q[501]), .Y(n714) );
  sky130_fd_sc_hd__o22ai_1 U916 ( .A1(n157), .A2(n714), .B1(n591), .B2(n719), 
        .Y(s_mem_d[501]) );
  sky130_fd_sc_hd__inv_1 U917 ( .A(s_mem_q[500]), .Y(n715) );
  sky130_fd_sc_hd__o22ai_1 U918 ( .A1(n157), .A2(n715), .B1(n602), .B2(n719), 
        .Y(s_mem_d[500]) );
  sky130_fd_sc_hd__inv_1 U919 ( .A(s_mem_q[499]), .Y(n716) );
  sky130_fd_sc_hd__o22ai_1 U920 ( .A1(n157), .A2(n716), .B1(n614), .B2(n719), 
        .Y(s_mem_d[499]) );
  sky130_fd_sc_hd__inv_1 U921 ( .A(s_mem_q[498]), .Y(n717) );
  sky130_fd_sc_hd__o22ai_1 U922 ( .A1(n157), .A2(n717), .B1(n625), .B2(n719), 
        .Y(s_mem_d[498]) );
  sky130_fd_sc_hd__inv_1 U923 ( .A(s_mem_q[497]), .Y(n718) );
  sky130_fd_sc_hd__o22ai_1 U924 ( .A1(n157), .A2(n718), .B1(n41), .B2(n719), 
        .Y(s_mem_d[497]) );
  sky130_fd_sc_hd__inv_1 U925 ( .A(s_mem_q[496]), .Y(n720) );
  sky130_fd_sc_hd__o22ai_1 U926 ( .A1(n157), .A2(n720), .B1(n654), .B2(n719), 
        .Y(s_mem_d[496]) );
  sky130_fd_sc_hd__inv_1 U927 ( .A(s_wr_ptr_q[1]), .Y(n1383) );
  sky130_fd_sc_hd__nand3_1 U928 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[2]), .C(
        n1383), .Y(n721) );
  sky130_fd_sc_hd__inv_1 U929 ( .A(s_mem_q[495]), .Y(n723) );
  sky130_fd_sc_hd__o22ai_1 U930 ( .A1(n159), .A2(n723), .B1(n649), .B2(n730), 
        .Y(s_mem_d[495]) );
  sky130_fd_sc_hd__inv_1 U931 ( .A(s_mem_q[494]), .Y(n724) );
  sky130_fd_sc_hd__o22ai_1 U932 ( .A1(n159), .A2(n724), .B1(n580), .B2(n730), 
        .Y(s_mem_d[494]) );
  sky130_fd_sc_hd__inv_1 U933 ( .A(s_mem_q[493]), .Y(n725) );
  sky130_fd_sc_hd__o22ai_1 U934 ( .A1(n159), .A2(n725), .B1(n590), .B2(n730), 
        .Y(s_mem_d[493]) );
  sky130_fd_sc_hd__inv_1 U935 ( .A(s_mem_q[492]), .Y(n726) );
  sky130_fd_sc_hd__o22ai_1 U936 ( .A1(n159), .A2(n726), .B1(n602), .B2(n730), 
        .Y(s_mem_d[492]) );
  sky130_fd_sc_hd__inv_1 U937 ( .A(s_mem_q[491]), .Y(n727) );
  sky130_fd_sc_hd__o22ai_1 U938 ( .A1(n159), .A2(n727), .B1(n613), .B2(n730), 
        .Y(s_mem_d[491]) );
  sky130_fd_sc_hd__inv_1 U939 ( .A(s_mem_q[490]), .Y(n728) );
  sky130_fd_sc_hd__o22ai_1 U940 ( .A1(n159), .A2(n728), .B1(n625), .B2(n730), 
        .Y(s_mem_d[490]) );
  sky130_fd_sc_hd__inv_1 U941 ( .A(s_mem_q[489]), .Y(n729) );
  sky130_fd_sc_hd__o22ai_1 U942 ( .A1(n159), .A2(n729), .B1(n40), .B2(n730), 
        .Y(s_mem_d[489]) );
  sky130_fd_sc_hd__inv_1 U943 ( .A(s_mem_q[488]), .Y(n731) );
  sky130_fd_sc_hd__o22ai_1 U944 ( .A1(n159), .A2(n731), .B1(n654), .B2(n730), 
        .Y(s_mem_d[488]) );
  sky130_fd_sc_hd__nand3_1 U945 ( .A(s_wr_ptr_q[2]), .B(n1383), .C(n776), .Y(
        n732) );
  sky130_fd_sc_hd__inv_1 U946 ( .A(s_mem_q[487]), .Y(n734) );
  sky130_fd_sc_hd__o22ai_1 U947 ( .A1(n158), .A2(n734), .B1(n649), .B2(n741), 
        .Y(s_mem_d[487]) );
  sky130_fd_sc_hd__inv_1 U948 ( .A(s_mem_q[486]), .Y(n735) );
  sky130_fd_sc_hd__o22ai_1 U949 ( .A1(n158), .A2(n735), .B1(n579), .B2(n741), 
        .Y(s_mem_d[486]) );
  sky130_fd_sc_hd__inv_1 U950 ( .A(s_mem_q[485]), .Y(n736) );
  sky130_fd_sc_hd__o22ai_1 U951 ( .A1(n158), .A2(n736), .B1(n589), .B2(n741), 
        .Y(s_mem_d[485]) );
  sky130_fd_sc_hd__inv_1 U952 ( .A(s_mem_q[484]), .Y(n737) );
  sky130_fd_sc_hd__o22ai_1 U953 ( .A1(n158), .A2(n737), .B1(n601), .B2(n741), 
        .Y(s_mem_d[484]) );
  sky130_fd_sc_hd__inv_1 U954 ( .A(s_mem_q[483]), .Y(n738) );
  sky130_fd_sc_hd__o22ai_1 U955 ( .A1(n158), .A2(n738), .B1(n612), .B2(n741), 
        .Y(s_mem_d[483]) );
  sky130_fd_sc_hd__inv_1 U956 ( .A(s_mem_q[482]), .Y(n739) );
  sky130_fd_sc_hd__o22ai_1 U957 ( .A1(n158), .A2(n739), .B1(n624), .B2(n741), 
        .Y(s_mem_d[482]) );
  sky130_fd_sc_hd__inv_1 U958 ( .A(s_mem_q[481]), .Y(n740) );
  sky130_fd_sc_hd__o22ai_1 U959 ( .A1(n158), .A2(n740), .B1(n39), .B2(n741), 
        .Y(s_mem_d[481]) );
  sky130_fd_sc_hd__inv_1 U960 ( .A(s_mem_q[480]), .Y(n742) );
  sky130_fd_sc_hd__o22ai_1 U961 ( .A1(n158), .A2(n742), .B1(n654), .B2(n741), 
        .Y(s_mem_d[480]) );
  sky130_fd_sc_hd__inv_1 U962 ( .A(s_wr_ptr_q[2]), .Y(n1381) );
  sky130_fd_sc_hd__nand2_1 U963 ( .A(n165), .B(n1381), .Y(n743) );
  sky130_fd_sc_hd__inv_1 U964 ( .A(s_mem_q[479]), .Y(n745) );
  sky130_fd_sc_hd__o22ai_1 U965 ( .A1(n116), .A2(n745), .B1(n649), .B2(n752), 
        .Y(s_mem_d[479]) );
  sky130_fd_sc_hd__inv_1 U966 ( .A(s_mem_q[478]), .Y(n746) );
  sky130_fd_sc_hd__o22ai_1 U967 ( .A1(n116), .A2(n746), .B1(n578), .B2(n752), 
        .Y(s_mem_d[478]) );
  sky130_fd_sc_hd__inv_1 U968 ( .A(s_mem_q[477]), .Y(n747) );
  sky130_fd_sc_hd__o22ai_1 U969 ( .A1(n116), .A2(n747), .B1(n589), .B2(n752), 
        .Y(s_mem_d[477]) );
  sky130_fd_sc_hd__inv_1 U970 ( .A(s_mem_q[476]), .Y(n748) );
  sky130_fd_sc_hd__o22ai_1 U971 ( .A1(n116), .A2(n748), .B1(n600), .B2(n752), 
        .Y(s_mem_d[476]) );
  sky130_fd_sc_hd__inv_1 U972 ( .A(s_mem_q[475]), .Y(n749) );
  sky130_fd_sc_hd__o22ai_1 U973 ( .A1(n116), .A2(n749), .B1(n611), .B2(n752), 
        .Y(s_mem_d[475]) );
  sky130_fd_sc_hd__inv_1 U974 ( .A(s_mem_q[474]), .Y(n750) );
  sky130_fd_sc_hd__o22ai_1 U975 ( .A1(n116), .A2(n750), .B1(n623), .B2(n752), 
        .Y(s_mem_d[474]) );
  sky130_fd_sc_hd__inv_1 U976 ( .A(s_mem_q[473]), .Y(n751) );
  sky130_fd_sc_hd__o22ai_1 U977 ( .A1(n116), .A2(n751), .B1(n55), .B2(n752), 
        .Y(s_mem_d[473]) );
  sky130_fd_sc_hd__inv_1 U978 ( .A(s_mem_q[472]), .Y(n753) );
  sky130_fd_sc_hd__o22ai_1 U979 ( .A1(n116), .A2(n753), .B1(n654), .B2(n752), 
        .Y(s_mem_d[472]) );
  sky130_fd_sc_hd__nand3_1 U980 ( .A(s_wr_ptr_q[1]), .B(n1381), .C(n776), .Y(
        n754) );
  sky130_fd_sc_hd__inv_1 U981 ( .A(s_mem_q[471]), .Y(n756) );
  sky130_fd_sc_hd__o22ai_1 U982 ( .A1(n115), .A2(n756), .B1(n649), .B2(n763), 
        .Y(s_mem_d[471]) );
  sky130_fd_sc_hd__inv_1 U983 ( .A(s_mem_q[470]), .Y(n757) );
  sky130_fd_sc_hd__o22ai_1 U984 ( .A1(n115), .A2(n757), .B1(n578), .B2(n763), 
        .Y(s_mem_d[470]) );
  sky130_fd_sc_hd__inv_1 U985 ( .A(s_mem_q[469]), .Y(n758) );
  sky130_fd_sc_hd__o22ai_1 U986 ( .A1(n115), .A2(n758), .B1(n589), .B2(n763), 
        .Y(s_mem_d[469]) );
  sky130_fd_sc_hd__inv_1 U987 ( .A(s_mem_q[468]), .Y(n759) );
  sky130_fd_sc_hd__o22ai_1 U988 ( .A1(n115), .A2(n759), .B1(n600), .B2(n763), 
        .Y(s_mem_d[468]) );
  sky130_fd_sc_hd__inv_1 U989 ( .A(s_mem_q[467]), .Y(n760) );
  sky130_fd_sc_hd__o22ai_1 U990 ( .A1(n115), .A2(n760), .B1(n611), .B2(n763), 
        .Y(s_mem_d[467]) );
  sky130_fd_sc_hd__inv_1 U991 ( .A(s_mem_q[466]), .Y(n761) );
  sky130_fd_sc_hd__o22ai_1 U992 ( .A1(n115), .A2(n761), .B1(n623), .B2(n763), 
        .Y(s_mem_d[466]) );
  sky130_fd_sc_hd__inv_1 U993 ( .A(s_mem_q[465]), .Y(n762) );
  sky130_fd_sc_hd__o22ai_1 U994 ( .A1(n115), .A2(n762), .B1(n38), .B2(n763), 
        .Y(s_mem_d[465]) );
  sky130_fd_sc_hd__inv_1 U995 ( .A(s_mem_q[464]), .Y(n764) );
  sky130_fd_sc_hd__o22ai_1 U996 ( .A1(n115), .A2(n764), .B1(n654), .B2(n763), 
        .Y(s_mem_d[464]) );
  sky130_fd_sc_hd__nand3_1 U997 ( .A(s_wr_ptr_q[0]), .B(n1381), .C(n1383), .Y(
        n765) );
  sky130_fd_sc_hd__inv_1 U998 ( .A(s_mem_q[463]), .Y(n767) );
  sky130_fd_sc_hd__o22ai_1 U999 ( .A1(n114), .A2(n767), .B1(n649), .B2(n774), 
        .Y(s_mem_d[463]) );
  sky130_fd_sc_hd__inv_1 U1000 ( .A(s_mem_q[462]), .Y(n768) );
  sky130_fd_sc_hd__o22ai_1 U1001 ( .A1(n114), .A2(n768), .B1(n577), .B2(n774), 
        .Y(s_mem_d[462]) );
  sky130_fd_sc_hd__inv_1 U1002 ( .A(s_mem_q[461]), .Y(n769) );
  sky130_fd_sc_hd__o22ai_1 U1003 ( .A1(n114), .A2(n769), .B1(n588), .B2(n774), 
        .Y(s_mem_d[461]) );
  sky130_fd_sc_hd__inv_1 U1004 ( .A(s_mem_q[460]), .Y(n770) );
  sky130_fd_sc_hd__o22ai_1 U1005 ( .A1(n114), .A2(n770), .B1(n599), .B2(n774), 
        .Y(s_mem_d[460]) );
  sky130_fd_sc_hd__inv_1 U1006 ( .A(s_mem_q[459]), .Y(n771) );
  sky130_fd_sc_hd__o22ai_1 U1007 ( .A1(n114), .A2(n771), .B1(n610), .B2(n774), 
        .Y(s_mem_d[459]) );
  sky130_fd_sc_hd__inv_1 U1008 ( .A(s_mem_q[458]), .Y(n772) );
  sky130_fd_sc_hd__o22ai_1 U1009 ( .A1(n114), .A2(n772), .B1(n622), .B2(n774), 
        .Y(s_mem_d[458]) );
  sky130_fd_sc_hd__inv_1 U1010 ( .A(s_mem_q[457]), .Y(n773) );
  sky130_fd_sc_hd__o22ai_1 U1011 ( .A1(n114), .A2(n773), .B1(n37), .B2(n774), 
        .Y(s_mem_d[457]) );
  sky130_fd_sc_hd__inv_1 U1012 ( .A(s_mem_q[456]), .Y(n775) );
  sky130_fd_sc_hd__o22ai_1 U1013 ( .A1(n114), .A2(n775), .B1(n654), .B2(n774), 
        .Y(s_mem_d[456]) );
  sky130_fd_sc_hd__inv_1 U1014 ( .A(s_mem_q[455]), .Y(n779) );
  sky130_fd_sc_hd__o22ai_1 U1015 ( .A1(n113), .A2(n779), .B1(n649), .B2(n786), 
        .Y(s_mem_d[455]) );
  sky130_fd_sc_hd__inv_1 U1016 ( .A(s_mem_q[454]), .Y(n780) );
  sky130_fd_sc_hd__o22ai_1 U1017 ( .A1(n113), .A2(n780), .B1(n585), .B2(n786), 
        .Y(s_mem_d[454]) );
  sky130_fd_sc_hd__inv_1 U1018 ( .A(s_mem_q[453]), .Y(n781) );
  sky130_fd_sc_hd__o22ai_1 U1019 ( .A1(n113), .A2(n781), .B1(n596), .B2(n786), 
        .Y(s_mem_d[453]) );
  sky130_fd_sc_hd__inv_1 U1020 ( .A(s_mem_q[452]), .Y(n782) );
  sky130_fd_sc_hd__o22ai_1 U1021 ( .A1(n113), .A2(n782), .B1(n607), .B2(n786), 
        .Y(s_mem_d[452]) );
  sky130_fd_sc_hd__inv_1 U1022 ( .A(s_mem_q[451]), .Y(n783) );
  sky130_fd_sc_hd__o22ai_1 U1023 ( .A1(n113), .A2(n783), .B1(n619), .B2(n786), 
        .Y(s_mem_d[451]) );
  sky130_fd_sc_hd__inv_1 U1024 ( .A(s_mem_q[450]), .Y(n784) );
  sky130_fd_sc_hd__o22ai_1 U1025 ( .A1(n113), .A2(n784), .B1(n630), .B2(n786), 
        .Y(s_mem_d[450]) );
  sky130_fd_sc_hd__inv_1 U1026 ( .A(s_mem_q[449]), .Y(n785) );
  sky130_fd_sc_hd__o22ai_1 U1027 ( .A1(n113), .A2(n785), .B1(n36), .B2(n786), 
        .Y(s_mem_d[449]) );
  sky130_fd_sc_hd__inv_1 U1028 ( .A(s_mem_q[448]), .Y(n787) );
  sky130_fd_sc_hd__o22ai_1 U1029 ( .A1(n113), .A2(n787), .B1(n654), .B2(n786), 
        .Y(s_mem_d[448]) );
  sky130_fd_sc_hd__inv_1 U1030 ( .A(s_wr_ptr_q[3]), .Y(n1380) );
  sky130_fd_sc_hd__nand3_1 U1031 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[4]), .C(
        n1380), .Y(n788) );
  sky130_fd_sc_hd__inv_1 U1032 ( .A(s_mem_q[447]), .Y(n790) );
  sky130_fd_sc_hd__o22ai_1 U1033 ( .A1(n154), .A2(n790), .B1(n649), .B2(n797), 
        .Y(s_mem_d[447]) );
  sky130_fd_sc_hd__inv_1 U1034 ( .A(s_mem_q[446]), .Y(n791) );
  sky130_fd_sc_hd__o22ai_1 U1035 ( .A1(n154), .A2(n791), .B1(n578), .B2(n797), 
        .Y(s_mem_d[446]) );
  sky130_fd_sc_hd__inv_1 U1036 ( .A(s_mem_q[445]), .Y(n792) );
  sky130_fd_sc_hd__o22ai_1 U1037 ( .A1(n154), .A2(n792), .B1(n589), .B2(n797), 
        .Y(s_mem_d[445]) );
  sky130_fd_sc_hd__inv_1 U1038 ( .A(s_mem_q[444]), .Y(n793) );
  sky130_fd_sc_hd__o22ai_1 U1039 ( .A1(n154), .A2(n793), .B1(n600), .B2(n797), 
        .Y(s_mem_d[444]) );
  sky130_fd_sc_hd__inv_1 U1040 ( .A(s_mem_q[443]), .Y(n794) );
  sky130_fd_sc_hd__o22ai_1 U1041 ( .A1(n154), .A2(n794), .B1(n611), .B2(n797), 
        .Y(s_mem_d[443]) );
  sky130_fd_sc_hd__inv_1 U1042 ( .A(s_mem_q[442]), .Y(n795) );
  sky130_fd_sc_hd__o22ai_1 U1043 ( .A1(n154), .A2(n795), .B1(n623), .B2(n797), 
        .Y(s_mem_d[442]) );
  sky130_fd_sc_hd__inv_1 U1044 ( .A(s_mem_q[441]), .Y(n796) );
  sky130_fd_sc_hd__o22ai_1 U1045 ( .A1(n154), .A2(n796), .B1(n35), .B2(n797), 
        .Y(s_mem_d[441]) );
  sky130_fd_sc_hd__inv_1 U1046 ( .A(s_mem_q[440]), .Y(n798) );
  sky130_fd_sc_hd__o22ai_1 U1047 ( .A1(n154), .A2(n798), .B1(n654), .B2(n797), 
        .Y(s_mem_d[440]) );
  sky130_fd_sc_hd__inv_1 U1048 ( .A(s_mem_q[439]), .Y(n800) );
  sky130_fd_sc_hd__o22ai_1 U1049 ( .A1(n153), .A2(n800), .B1(n649), .B2(n807), 
        .Y(s_mem_d[439]) );
  sky130_fd_sc_hd__inv_1 U1050 ( .A(s_mem_q[438]), .Y(n801) );
  sky130_fd_sc_hd__o22ai_1 U1051 ( .A1(n153), .A2(n801), .B1(n584), .B2(n807), 
        .Y(s_mem_d[438]) );
  sky130_fd_sc_hd__inv_1 U1052 ( .A(s_mem_q[437]), .Y(n802) );
  sky130_fd_sc_hd__o22ai_1 U1053 ( .A1(n153), .A2(n802), .B1(n595), .B2(n807), 
        .Y(s_mem_d[437]) );
  sky130_fd_sc_hd__inv_1 U1054 ( .A(s_mem_q[436]), .Y(n803) );
  sky130_fd_sc_hd__o22ai_1 U1055 ( .A1(n153), .A2(n803), .B1(n606), .B2(n807), 
        .Y(s_mem_d[436]) );
  sky130_fd_sc_hd__inv_1 U1056 ( .A(s_mem_q[435]), .Y(n804) );
  sky130_fd_sc_hd__o22ai_1 U1057 ( .A1(n153), .A2(n804), .B1(n618), .B2(n807), 
        .Y(s_mem_d[435]) );
  sky130_fd_sc_hd__inv_1 U1058 ( .A(s_mem_q[434]), .Y(n805) );
  sky130_fd_sc_hd__o22ai_1 U1059 ( .A1(n153), .A2(n805), .B1(n629), .B2(n807), 
        .Y(s_mem_d[434]) );
  sky130_fd_sc_hd__inv_1 U1060 ( .A(s_mem_q[433]), .Y(n806) );
  sky130_fd_sc_hd__o22ai_1 U1061 ( .A1(n153), .A2(n806), .B1(n58), .B2(n807), 
        .Y(s_mem_d[433]) );
  sky130_fd_sc_hd__inv_1 U1062 ( .A(s_mem_q[432]), .Y(n808) );
  sky130_fd_sc_hd__o22ai_1 U1063 ( .A1(n153), .A2(n808), .B1(n654), .B2(n807), 
        .Y(s_mem_d[432]) );
  sky130_fd_sc_hd__inv_1 U1064 ( .A(s_mem_q[431]), .Y(n810) );
  sky130_fd_sc_hd__o22ai_1 U1065 ( .A1(n152), .A2(n810), .B1(n649), .B2(n817), 
        .Y(s_mem_d[431]) );
  sky130_fd_sc_hd__inv_1 U1066 ( .A(s_mem_q[430]), .Y(n811) );
  sky130_fd_sc_hd__o22ai_1 U1067 ( .A1(n152), .A2(n811), .B1(n583), .B2(n817), 
        .Y(s_mem_d[430]) );
  sky130_fd_sc_hd__inv_1 U1068 ( .A(s_mem_q[429]), .Y(n812) );
  sky130_fd_sc_hd__o22ai_1 U1069 ( .A1(n152), .A2(n812), .B1(n594), .B2(n817), 
        .Y(s_mem_d[429]) );
  sky130_fd_sc_hd__inv_1 U1070 ( .A(s_mem_q[428]), .Y(n813) );
  sky130_fd_sc_hd__o22ai_1 U1071 ( .A1(n152), .A2(n813), .B1(n605), .B2(n817), 
        .Y(s_mem_d[428]) );
  sky130_fd_sc_hd__inv_1 U1072 ( .A(s_mem_q[427]), .Y(n814) );
  sky130_fd_sc_hd__o22ai_1 U1073 ( .A1(n152), .A2(n814), .B1(n617), .B2(n817), 
        .Y(s_mem_d[427]) );
  sky130_fd_sc_hd__inv_1 U1074 ( .A(s_mem_q[426]), .Y(n815) );
  sky130_fd_sc_hd__o22ai_1 U1075 ( .A1(n152), .A2(n815), .B1(n628), .B2(n817), 
        .Y(s_mem_d[426]) );
  sky130_fd_sc_hd__inv_1 U1076 ( .A(s_mem_q[425]), .Y(n816) );
  sky130_fd_sc_hd__o22ai_1 U1077 ( .A1(n152), .A2(n816), .B1(n57), .B2(n817), 
        .Y(s_mem_d[425]) );
  sky130_fd_sc_hd__inv_1 U1078 ( .A(s_mem_q[424]), .Y(n818) );
  sky130_fd_sc_hd__o22ai_1 U1079 ( .A1(n152), .A2(n818), .B1(n654), .B2(n817), 
        .Y(s_mem_d[424]) );
  sky130_fd_sc_hd__inv_1 U1080 ( .A(s_mem_q[423]), .Y(n820) );
  sky130_fd_sc_hd__o22ai_1 U1081 ( .A1(n151), .A2(n820), .B1(n649), .B2(n827), 
        .Y(s_mem_d[423]) );
  sky130_fd_sc_hd__inv_1 U1082 ( .A(s_mem_q[422]), .Y(n821) );
  sky130_fd_sc_hd__o22ai_1 U1083 ( .A1(n151), .A2(n821), .B1(n581), .B2(n827), 
        .Y(s_mem_d[422]) );
  sky130_fd_sc_hd__inv_1 U1084 ( .A(s_mem_q[421]), .Y(n822) );
  sky130_fd_sc_hd__o22ai_1 U1085 ( .A1(n151), .A2(n822), .B1(n590), .B2(n827), 
        .Y(s_mem_d[421]) );
  sky130_fd_sc_hd__inv_1 U1086 ( .A(s_mem_q[420]), .Y(n823) );
  sky130_fd_sc_hd__o22ai_1 U1087 ( .A1(n151), .A2(n823), .B1(n603), .B2(n827), 
        .Y(s_mem_d[420]) );
  sky130_fd_sc_hd__inv_1 U1088 ( .A(s_mem_q[419]), .Y(n824) );
  sky130_fd_sc_hd__o22ai_1 U1089 ( .A1(n151), .A2(n824), .B1(n613), .B2(n827), 
        .Y(s_mem_d[419]) );
  sky130_fd_sc_hd__inv_1 U1090 ( .A(s_mem_q[418]), .Y(n825) );
  sky130_fd_sc_hd__o22ai_1 U1091 ( .A1(n151), .A2(n825), .B1(n626), .B2(n827), 
        .Y(s_mem_d[418]) );
  sky130_fd_sc_hd__inv_1 U1092 ( .A(s_mem_q[417]), .Y(n826) );
  sky130_fd_sc_hd__o22ai_1 U1093 ( .A1(n151), .A2(n826), .B1(n58), .B2(n827), 
        .Y(s_mem_d[417]) );
  sky130_fd_sc_hd__inv_1 U1094 ( .A(s_mem_q[416]), .Y(n828) );
  sky130_fd_sc_hd__o22ai_1 U1095 ( .A1(n151), .A2(n828), .B1(n654), .B2(n827), 
        .Y(s_mem_d[416]) );
  sky130_fd_sc_hd__inv_1 U1096 ( .A(s_mem_q[415]), .Y(n830) );
  sky130_fd_sc_hd__o22ai_1 U1097 ( .A1(n150), .A2(n830), .B1(n649), .B2(n837), 
        .Y(s_mem_d[415]) );
  sky130_fd_sc_hd__inv_1 U1098 ( .A(s_mem_q[414]), .Y(n831) );
  sky130_fd_sc_hd__o22ai_1 U1099 ( .A1(n150), .A2(n831), .B1(n577), .B2(n837), 
        .Y(s_mem_d[414]) );
  sky130_fd_sc_hd__inv_1 U1100 ( .A(s_mem_q[413]), .Y(n832) );
  sky130_fd_sc_hd__o22ai_1 U1101 ( .A1(n150), .A2(n832), .B1(n588), .B2(n837), 
        .Y(s_mem_d[413]) );
  sky130_fd_sc_hd__inv_1 U1102 ( .A(s_mem_q[412]), .Y(n833) );
  sky130_fd_sc_hd__o22ai_1 U1103 ( .A1(n150), .A2(n833), .B1(n599), .B2(n837), 
        .Y(s_mem_d[412]) );
  sky130_fd_sc_hd__inv_1 U1104 ( .A(s_mem_q[411]), .Y(n834) );
  sky130_fd_sc_hd__o22ai_1 U1105 ( .A1(n150), .A2(n834), .B1(n610), .B2(n837), 
        .Y(s_mem_d[411]) );
  sky130_fd_sc_hd__inv_1 U1106 ( .A(s_mem_q[410]), .Y(n835) );
  sky130_fd_sc_hd__o22ai_1 U1107 ( .A1(n150), .A2(n835), .B1(n622), .B2(n837), 
        .Y(s_mem_d[410]) );
  sky130_fd_sc_hd__inv_1 U1108 ( .A(s_mem_q[409]), .Y(n836) );
  sky130_fd_sc_hd__o22ai_1 U1109 ( .A1(n150), .A2(n836), .B1(n56), .B2(n837), 
        .Y(s_mem_d[409]) );
  sky130_fd_sc_hd__inv_1 U1110 ( .A(s_mem_q[408]), .Y(n838) );
  sky130_fd_sc_hd__o22ai_1 U1111 ( .A1(n150), .A2(n838), .B1(n654), .B2(n837), 
        .Y(s_mem_d[408]) );
  sky130_fd_sc_hd__inv_1 U1112 ( .A(s_mem_q[407]), .Y(n840) );
  sky130_fd_sc_hd__o22ai_1 U1113 ( .A1(n149), .A2(n840), .B1(n650), .B2(n847), 
        .Y(s_mem_d[407]) );
  sky130_fd_sc_hd__inv_1 U1114 ( .A(s_mem_q[406]), .Y(n841) );
  sky130_fd_sc_hd__o22ai_1 U1115 ( .A1(n149), .A2(n841), .B1(n578), .B2(n847), 
        .Y(s_mem_d[406]) );
  sky130_fd_sc_hd__inv_1 U1116 ( .A(s_mem_q[405]), .Y(n842) );
  sky130_fd_sc_hd__o22ai_1 U1117 ( .A1(n149), .A2(n842), .B1(n589), .B2(n847), 
        .Y(s_mem_d[405]) );
  sky130_fd_sc_hd__inv_1 U1118 ( .A(s_mem_q[404]), .Y(n843) );
  sky130_fd_sc_hd__o22ai_1 U1119 ( .A1(n149), .A2(n843), .B1(n600), .B2(n847), 
        .Y(s_mem_d[404]) );
  sky130_fd_sc_hd__inv_1 U1120 ( .A(s_mem_q[403]), .Y(n844) );
  sky130_fd_sc_hd__o22ai_1 U1121 ( .A1(n149), .A2(n844), .B1(n611), .B2(n847), 
        .Y(s_mem_d[403]) );
  sky130_fd_sc_hd__inv_1 U1122 ( .A(s_mem_q[402]), .Y(n845) );
  sky130_fd_sc_hd__o22ai_1 U1123 ( .A1(n149), .A2(n845), .B1(n623), .B2(n847), 
        .Y(s_mem_d[402]) );
  sky130_fd_sc_hd__inv_1 U1124 ( .A(s_mem_q[401]), .Y(n846) );
  sky130_fd_sc_hd__o22ai_1 U1125 ( .A1(n149), .A2(n846), .B1(n57), .B2(n847), 
        .Y(s_mem_d[401]) );
  sky130_fd_sc_hd__inv_1 U1126 ( .A(s_mem_q[400]), .Y(n848) );
  sky130_fd_sc_hd__o22ai_1 U1127 ( .A1(n149), .A2(n848), .B1(n654), .B2(n847), 
        .Y(s_mem_d[400]) );
  sky130_fd_sc_hd__inv_1 U1128 ( .A(s_mem_q[399]), .Y(n850) );
  sky130_fd_sc_hd__o22ai_1 U1129 ( .A1(n148), .A2(n850), .B1(n650), .B2(n857), 
        .Y(s_mem_d[399]) );
  sky130_fd_sc_hd__inv_1 U1130 ( .A(s_mem_q[398]), .Y(n851) );
  sky130_fd_sc_hd__o22ai_1 U1131 ( .A1(n148), .A2(n851), .B1(n585), .B2(n857), 
        .Y(s_mem_d[398]) );
  sky130_fd_sc_hd__inv_1 U1132 ( .A(s_mem_q[397]), .Y(n852) );
  sky130_fd_sc_hd__o22ai_1 U1133 ( .A1(n148), .A2(n852), .B1(n596), .B2(n857), 
        .Y(s_mem_d[397]) );
  sky130_fd_sc_hd__inv_1 U1134 ( .A(s_mem_q[396]), .Y(n853) );
  sky130_fd_sc_hd__o22ai_1 U1135 ( .A1(n148), .A2(n853), .B1(n607), .B2(n857), 
        .Y(s_mem_d[396]) );
  sky130_fd_sc_hd__inv_1 U1136 ( .A(s_mem_q[395]), .Y(n854) );
  sky130_fd_sc_hd__o22ai_1 U1137 ( .A1(n148), .A2(n854), .B1(n619), .B2(n857), 
        .Y(s_mem_d[395]) );
  sky130_fd_sc_hd__inv_1 U1138 ( .A(s_mem_q[394]), .Y(n855) );
  sky130_fd_sc_hd__o22ai_1 U1139 ( .A1(n148), .A2(n855), .B1(n630), .B2(n857), 
        .Y(s_mem_d[394]) );
  sky130_fd_sc_hd__inv_1 U1140 ( .A(s_mem_q[393]), .Y(n856) );
  sky130_fd_sc_hd__o22ai_1 U1141 ( .A1(n148), .A2(n856), .B1(n45), .B2(n857), 
        .Y(s_mem_d[393]) );
  sky130_fd_sc_hd__inv_1 U1142 ( .A(s_mem_q[392]), .Y(n858) );
  sky130_fd_sc_hd__o22ai_1 U1143 ( .A1(n148), .A2(n858), .B1(n655), .B2(n857), 
        .Y(s_mem_d[392]) );
  sky130_fd_sc_hd__inv_1 U1144 ( .A(s_mem_q[391]), .Y(n861) );
  sky130_fd_sc_hd__o22ai_1 U1145 ( .A1(n147), .A2(n861), .B1(n650), .B2(n868), 
        .Y(s_mem_d[391]) );
  sky130_fd_sc_hd__inv_1 U1146 ( .A(s_mem_q[390]), .Y(n862) );
  sky130_fd_sc_hd__o22ai_1 U1147 ( .A1(n147), .A2(n862), .B1(n584), .B2(n868), 
        .Y(s_mem_d[390]) );
  sky130_fd_sc_hd__inv_1 U1148 ( .A(s_mem_q[389]), .Y(n863) );
  sky130_fd_sc_hd__o22ai_1 U1149 ( .A1(n147), .A2(n863), .B1(n595), .B2(n868), 
        .Y(s_mem_d[389]) );
  sky130_fd_sc_hd__inv_1 U1150 ( .A(s_mem_q[388]), .Y(n864) );
  sky130_fd_sc_hd__o22ai_1 U1151 ( .A1(n147), .A2(n864), .B1(n606), .B2(n868), 
        .Y(s_mem_d[388]) );
  sky130_fd_sc_hd__inv_1 U1152 ( .A(s_mem_q[387]), .Y(n865) );
  sky130_fd_sc_hd__o22ai_1 U1153 ( .A1(n147), .A2(n865), .B1(n618), .B2(n868), 
        .Y(s_mem_d[387]) );
  sky130_fd_sc_hd__inv_1 U1154 ( .A(s_mem_q[386]), .Y(n866) );
  sky130_fd_sc_hd__o22ai_1 U1155 ( .A1(n147), .A2(n866), .B1(n629), .B2(n868), 
        .Y(s_mem_d[386]) );
  sky130_fd_sc_hd__inv_1 U1156 ( .A(s_mem_q[385]), .Y(n867) );
  sky130_fd_sc_hd__o22ai_1 U1157 ( .A1(n147), .A2(n867), .B1(n44), .B2(n868), 
        .Y(s_mem_d[385]) );
  sky130_fd_sc_hd__inv_1 U1158 ( .A(s_mem_q[384]), .Y(n869) );
  sky130_fd_sc_hd__o22ai_1 U1159 ( .A1(n147), .A2(n869), .B1(n655), .B2(n868), 
        .Y(s_mem_d[384]) );
  sky130_fd_sc_hd__inv_1 U1160 ( .A(s_wr_ptr_q[4]), .Y(n1379) );
  sky130_fd_sc_hd__nand3_1 U1161 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[3]), .C(
        n1379), .Y(n870) );
  sky130_fd_sc_hd__inv_1 U1162 ( .A(s_mem_q[383]), .Y(n872) );
  sky130_fd_sc_hd__o22ai_1 U1163 ( .A1(n146), .A2(n872), .B1(n650), .B2(n879), 
        .Y(s_mem_d[383]) );
  sky130_fd_sc_hd__inv_1 U1164 ( .A(s_mem_q[382]), .Y(n873) );
  sky130_fd_sc_hd__o22ai_1 U1165 ( .A1(n146), .A2(n873), .B1(n580), .B2(n879), 
        .Y(s_mem_d[382]) );
  sky130_fd_sc_hd__inv_1 U1166 ( .A(s_mem_q[381]), .Y(n874) );
  sky130_fd_sc_hd__o22ai_1 U1167 ( .A1(n146), .A2(n874), .B1(n590), .B2(n879), 
        .Y(s_mem_d[381]) );
  sky130_fd_sc_hd__inv_1 U1168 ( .A(s_mem_q[380]), .Y(n875) );
  sky130_fd_sc_hd__o22ai_1 U1169 ( .A1(n146), .A2(n875), .B1(n602), .B2(n879), 
        .Y(s_mem_d[380]) );
  sky130_fd_sc_hd__inv_1 U1170 ( .A(s_mem_q[379]), .Y(n876) );
  sky130_fd_sc_hd__o22ai_1 U1171 ( .A1(n146), .A2(n876), .B1(n613), .B2(n879), 
        .Y(s_mem_d[379]) );
  sky130_fd_sc_hd__inv_1 U1172 ( .A(s_mem_q[378]), .Y(n877) );
  sky130_fd_sc_hd__o22ai_1 U1173 ( .A1(n146), .A2(n877), .B1(n625), .B2(n879), 
        .Y(s_mem_d[378]) );
  sky130_fd_sc_hd__inv_1 U1174 ( .A(s_mem_q[377]), .Y(n878) );
  sky130_fd_sc_hd__o22ai_1 U1175 ( .A1(n146), .A2(n878), .B1(n54), .B2(n879), 
        .Y(s_mem_d[377]) );
  sky130_fd_sc_hd__inv_1 U1176 ( .A(s_mem_q[376]), .Y(n880) );
  sky130_fd_sc_hd__o22ai_1 U1177 ( .A1(n146), .A2(n880), .B1(n656), .B2(n879), 
        .Y(s_mem_d[376]) );
  sky130_fd_sc_hd__inv_1 U1178 ( .A(s_mem_q[375]), .Y(n882) );
  sky130_fd_sc_hd__o22ai_1 U1179 ( .A1(n145), .A2(n882), .B1(n650), .B2(n889), 
        .Y(s_mem_d[375]) );
  sky130_fd_sc_hd__inv_1 U1180 ( .A(s_mem_q[374]), .Y(n883) );
  sky130_fd_sc_hd__o22ai_1 U1181 ( .A1(n145), .A2(n883), .B1(n583), .B2(n889), 
        .Y(s_mem_d[374]) );
  sky130_fd_sc_hd__inv_1 U1182 ( .A(s_mem_q[373]), .Y(n884) );
  sky130_fd_sc_hd__o22ai_1 U1183 ( .A1(n145), .A2(n884), .B1(n594), .B2(n889), 
        .Y(s_mem_d[373]) );
  sky130_fd_sc_hd__inv_1 U1184 ( .A(s_mem_q[372]), .Y(n885) );
  sky130_fd_sc_hd__o22ai_1 U1185 ( .A1(n145), .A2(n885), .B1(n605), .B2(n889), 
        .Y(s_mem_d[372]) );
  sky130_fd_sc_hd__inv_1 U1186 ( .A(s_mem_q[371]), .Y(n886) );
  sky130_fd_sc_hd__o22ai_1 U1187 ( .A1(n145), .A2(n886), .B1(n617), .B2(n889), 
        .Y(s_mem_d[371]) );
  sky130_fd_sc_hd__inv_1 U1188 ( .A(s_mem_q[370]), .Y(n887) );
  sky130_fd_sc_hd__o22ai_1 U1189 ( .A1(n145), .A2(n887), .B1(n628), .B2(n889), 
        .Y(s_mem_d[370]) );
  sky130_fd_sc_hd__inv_1 U1190 ( .A(s_mem_q[369]), .Y(n888) );
  sky130_fd_sc_hd__o22ai_1 U1191 ( .A1(n145), .A2(n888), .B1(n39), .B2(n889), 
        .Y(s_mem_d[369]) );
  sky130_fd_sc_hd__inv_1 U1192 ( .A(s_mem_q[368]), .Y(n890) );
  sky130_fd_sc_hd__o22ai_1 U1193 ( .A1(n145), .A2(n890), .B1(n655), .B2(n889), 
        .Y(s_mem_d[368]) );
  sky130_fd_sc_hd__inv_1 U1194 ( .A(s_mem_q[367]), .Y(n892) );
  sky130_fd_sc_hd__o22ai_1 U1195 ( .A1(n144), .A2(n892), .B1(n650), .B2(n899), 
        .Y(s_mem_d[367]) );
  sky130_fd_sc_hd__inv_1 U1196 ( .A(s_mem_q[366]), .Y(n893) );
  sky130_fd_sc_hd__o22ai_1 U1197 ( .A1(n144), .A2(n893), .B1(n581), .B2(n899), 
        .Y(s_mem_d[366]) );
  sky130_fd_sc_hd__inv_1 U1198 ( .A(s_mem_q[365]), .Y(n894) );
  sky130_fd_sc_hd__o22ai_1 U1199 ( .A1(n144), .A2(n894), .B1(n592), .B2(n899), 
        .Y(s_mem_d[365]) );
  sky130_fd_sc_hd__inv_1 U1200 ( .A(s_mem_q[364]), .Y(n895) );
  sky130_fd_sc_hd__o22ai_1 U1201 ( .A1(n144), .A2(n895), .B1(n603), .B2(n899), 
        .Y(s_mem_d[364]) );
  sky130_fd_sc_hd__inv_1 U1202 ( .A(s_mem_q[363]), .Y(n896) );
  sky130_fd_sc_hd__o22ai_1 U1203 ( .A1(n144), .A2(n896), .B1(n615), .B2(n899), 
        .Y(s_mem_d[363]) );
  sky130_fd_sc_hd__inv_1 U1204 ( .A(s_mem_q[362]), .Y(n897) );
  sky130_fd_sc_hd__o22ai_1 U1205 ( .A1(n144), .A2(n897), .B1(n626), .B2(n899), 
        .Y(s_mem_d[362]) );
  sky130_fd_sc_hd__inv_1 U1206 ( .A(s_mem_q[361]), .Y(n898) );
  sky130_fd_sc_hd__o22ai_1 U1207 ( .A1(n144), .A2(n898), .B1(n42), .B2(n899), 
        .Y(s_mem_d[361]) );
  sky130_fd_sc_hd__inv_1 U1208 ( .A(s_mem_q[360]), .Y(n900) );
  sky130_fd_sc_hd__o22ai_1 U1209 ( .A1(n144), .A2(n900), .B1(n655), .B2(n899), 
        .Y(s_mem_d[360]) );
  sky130_fd_sc_hd__inv_1 U1210 ( .A(s_mem_q[359]), .Y(n902) );
  sky130_fd_sc_hd__o22ai_1 U1211 ( .A1(n143), .A2(n902), .B1(n650), .B2(n909), 
        .Y(s_mem_d[359]) );
  sky130_fd_sc_hd__inv_1 U1212 ( .A(s_mem_q[358]), .Y(n903) );
  sky130_fd_sc_hd__o22ai_1 U1213 ( .A1(n143), .A2(n903), .B1(n580), .B2(n909), 
        .Y(s_mem_d[358]) );
  sky130_fd_sc_hd__inv_1 U1214 ( .A(s_mem_q[357]), .Y(n904) );
  sky130_fd_sc_hd__o22ai_1 U1215 ( .A1(n143), .A2(n904), .B1(n591), .B2(n909), 
        .Y(s_mem_d[357]) );
  sky130_fd_sc_hd__inv_1 U1216 ( .A(s_mem_q[356]), .Y(n905) );
  sky130_fd_sc_hd__o22ai_1 U1217 ( .A1(n143), .A2(n905), .B1(n602), .B2(n909), 
        .Y(s_mem_d[356]) );
  sky130_fd_sc_hd__inv_1 U1218 ( .A(s_mem_q[355]), .Y(n906) );
  sky130_fd_sc_hd__o22ai_1 U1219 ( .A1(n143), .A2(n906), .B1(n614), .B2(n909), 
        .Y(s_mem_d[355]) );
  sky130_fd_sc_hd__inv_1 U1220 ( .A(s_mem_q[354]), .Y(n907) );
  sky130_fd_sc_hd__o22ai_1 U1221 ( .A1(n143), .A2(n907), .B1(n625), .B2(n909), 
        .Y(s_mem_d[354]) );
  sky130_fd_sc_hd__inv_1 U1222 ( .A(s_mem_q[353]), .Y(n908) );
  sky130_fd_sc_hd__o22ai_1 U1223 ( .A1(n143), .A2(n908), .B1(n41), .B2(n909), 
        .Y(s_mem_d[353]) );
  sky130_fd_sc_hd__inv_1 U1224 ( .A(s_mem_q[352]), .Y(n910) );
  sky130_fd_sc_hd__o22ai_1 U1225 ( .A1(n143), .A2(n910), .B1(n655), .B2(n909), 
        .Y(s_mem_d[352]) );
  sky130_fd_sc_hd__inv_1 U1226 ( .A(s_mem_q[351]), .Y(n912) );
  sky130_fd_sc_hd__o22ai_1 U1227 ( .A1(n142), .A2(n912), .B1(n650), .B2(n919), 
        .Y(s_mem_d[351]) );
  sky130_fd_sc_hd__inv_1 U1228 ( .A(s_mem_q[350]), .Y(n913) );
  sky130_fd_sc_hd__o22ai_1 U1229 ( .A1(n142), .A2(n913), .B1(n578), .B2(n919), 
        .Y(s_mem_d[350]) );
  sky130_fd_sc_hd__inv_1 U1230 ( .A(s_mem_q[349]), .Y(n914) );
  sky130_fd_sc_hd__o22ai_1 U1231 ( .A1(n142), .A2(n914), .B1(n589), .B2(n919), 
        .Y(s_mem_d[349]) );
  sky130_fd_sc_hd__inv_1 U1232 ( .A(s_mem_q[348]), .Y(n915) );
  sky130_fd_sc_hd__o22ai_1 U1233 ( .A1(n142), .A2(n915), .B1(n600), .B2(n919), 
        .Y(s_mem_d[348]) );
  sky130_fd_sc_hd__inv_1 U1234 ( .A(s_mem_q[347]), .Y(n916) );
  sky130_fd_sc_hd__o22ai_1 U1235 ( .A1(n142), .A2(n916), .B1(n611), .B2(n919), 
        .Y(s_mem_d[347]) );
  sky130_fd_sc_hd__inv_1 U1236 ( .A(s_mem_q[346]), .Y(n917) );
  sky130_fd_sc_hd__o22ai_1 U1237 ( .A1(n142), .A2(n917), .B1(n623), .B2(n919), 
        .Y(s_mem_d[346]) );
  sky130_fd_sc_hd__inv_1 U1238 ( .A(s_mem_q[345]), .Y(n918) );
  sky130_fd_sc_hd__o22ai_1 U1239 ( .A1(n142), .A2(n918), .B1(n40), .B2(n919), 
        .Y(s_mem_d[345]) );
  sky130_fd_sc_hd__inv_1 U1240 ( .A(s_mem_q[344]), .Y(n920) );
  sky130_fd_sc_hd__o22ai_1 U1241 ( .A1(n142), .A2(n920), .B1(n655), .B2(n919), 
        .Y(s_mem_d[344]) );
  sky130_fd_sc_hd__inv_1 U1242 ( .A(s_mem_q[343]), .Y(n922) );
  sky130_fd_sc_hd__o22ai_1 U1243 ( .A1(n141), .A2(n922), .B1(n650), .B2(n929), 
        .Y(s_mem_d[343]) );
  sky130_fd_sc_hd__inv_1 U1244 ( .A(s_mem_q[342]), .Y(n923) );
  sky130_fd_sc_hd__o22ai_1 U1245 ( .A1(n141), .A2(n923), .B1(n584), .B2(n929), 
        .Y(s_mem_d[342]) );
  sky130_fd_sc_hd__inv_1 U1246 ( .A(s_mem_q[341]), .Y(n924) );
  sky130_fd_sc_hd__o22ai_1 U1247 ( .A1(n141), .A2(n924), .B1(n595), .B2(n929), 
        .Y(s_mem_d[341]) );
  sky130_fd_sc_hd__inv_1 U1248 ( .A(s_mem_q[340]), .Y(n925) );
  sky130_fd_sc_hd__o22ai_1 U1249 ( .A1(n141), .A2(n925), .B1(n606), .B2(n929), 
        .Y(s_mem_d[340]) );
  sky130_fd_sc_hd__inv_1 U1250 ( .A(s_mem_q[339]), .Y(n926) );
  sky130_fd_sc_hd__o22ai_1 U1251 ( .A1(n141), .A2(n926), .B1(n618), .B2(n929), 
        .Y(s_mem_d[339]) );
  sky130_fd_sc_hd__inv_1 U1252 ( .A(s_mem_q[338]), .Y(n927) );
  sky130_fd_sc_hd__o22ai_1 U1253 ( .A1(n141), .A2(n927), .B1(n629), .B2(n929), 
        .Y(s_mem_d[338]) );
  sky130_fd_sc_hd__inv_1 U1254 ( .A(s_mem_q[337]), .Y(n928) );
  sky130_fd_sc_hd__o22ai_1 U1255 ( .A1(n141), .A2(n928), .B1(n39), .B2(n929), 
        .Y(s_mem_d[337]) );
  sky130_fd_sc_hd__inv_1 U1256 ( .A(s_mem_q[336]), .Y(n930) );
  sky130_fd_sc_hd__o22ai_1 U1257 ( .A1(n141), .A2(n930), .B1(n655), .B2(n929), 
        .Y(s_mem_d[336]) );
  sky130_fd_sc_hd__inv_1 U1258 ( .A(s_mem_q[335]), .Y(n932) );
  sky130_fd_sc_hd__o22ai_1 U1259 ( .A1(n140), .A2(n932), .B1(n650), .B2(n939), 
        .Y(s_mem_d[335]) );
  sky130_fd_sc_hd__inv_1 U1260 ( .A(s_mem_q[334]), .Y(n933) );
  sky130_fd_sc_hd__o22ai_1 U1261 ( .A1(n140), .A2(n933), .B1(n582), .B2(n939), 
        .Y(s_mem_d[334]) );
  sky130_fd_sc_hd__inv_1 U1262 ( .A(s_mem_q[333]), .Y(n934) );
  sky130_fd_sc_hd__o22ai_1 U1263 ( .A1(n140), .A2(n934), .B1(n593), .B2(n939), 
        .Y(s_mem_d[333]) );
  sky130_fd_sc_hd__inv_1 U1264 ( .A(s_mem_q[332]), .Y(n935) );
  sky130_fd_sc_hd__o22ai_1 U1265 ( .A1(n140), .A2(n935), .B1(n604), .B2(n939), 
        .Y(s_mem_d[332]) );
  sky130_fd_sc_hd__inv_1 U1266 ( .A(s_mem_q[331]), .Y(n936) );
  sky130_fd_sc_hd__o22ai_1 U1267 ( .A1(n140), .A2(n936), .B1(n616), .B2(n939), 
        .Y(s_mem_d[331]) );
  sky130_fd_sc_hd__inv_1 U1268 ( .A(s_mem_q[330]), .Y(n937) );
  sky130_fd_sc_hd__o22ai_1 U1269 ( .A1(n140), .A2(n937), .B1(n627), .B2(n939), 
        .Y(s_mem_d[330]) );
  sky130_fd_sc_hd__inv_1 U1270 ( .A(s_mem_q[329]), .Y(n938) );
  sky130_fd_sc_hd__o22ai_1 U1271 ( .A1(n140), .A2(n938), .B1(n38), .B2(n939), 
        .Y(s_mem_d[329]) );
  sky130_fd_sc_hd__inv_1 U1272 ( .A(s_mem_q[328]), .Y(n940) );
  sky130_fd_sc_hd__o22ai_1 U1273 ( .A1(n140), .A2(n940), .B1(n655), .B2(n939), 
        .Y(s_mem_d[328]) );
  sky130_fd_sc_hd__inv_1 U1274 ( .A(s_mem_q[327]), .Y(n943) );
  sky130_fd_sc_hd__o22ai_1 U1275 ( .A1(n139), .A2(n943), .B1(n650), .B2(n950), 
        .Y(s_mem_d[327]) );
  sky130_fd_sc_hd__inv_1 U1276 ( .A(s_mem_q[326]), .Y(n944) );
  sky130_fd_sc_hd__o22ai_1 U1277 ( .A1(n139), .A2(n944), .B1(n581), .B2(n950), 
        .Y(s_mem_d[326]) );
  sky130_fd_sc_hd__inv_1 U1278 ( .A(s_mem_q[325]), .Y(n945) );
  sky130_fd_sc_hd__o22ai_1 U1279 ( .A1(n139), .A2(n945), .B1(n592), .B2(n950), 
        .Y(s_mem_d[325]) );
  sky130_fd_sc_hd__inv_1 U1280 ( .A(s_mem_q[324]), .Y(n946) );
  sky130_fd_sc_hd__o22ai_1 U1281 ( .A1(n139), .A2(n946), .B1(n603), .B2(n950), 
        .Y(s_mem_d[324]) );
  sky130_fd_sc_hd__inv_1 U1282 ( .A(s_mem_q[323]), .Y(n947) );
  sky130_fd_sc_hd__o22ai_1 U1283 ( .A1(n139), .A2(n947), .B1(n615), .B2(n950), 
        .Y(s_mem_d[323]) );
  sky130_fd_sc_hd__inv_1 U1284 ( .A(s_mem_q[322]), .Y(n948) );
  sky130_fd_sc_hd__o22ai_1 U1285 ( .A1(n139), .A2(n948), .B1(n626), .B2(n950), 
        .Y(s_mem_d[322]) );
  sky130_fd_sc_hd__inv_1 U1286 ( .A(s_mem_q[321]), .Y(n949) );
  sky130_fd_sc_hd__o22ai_1 U1287 ( .A1(n139), .A2(n949), .B1(n37), .B2(n950), 
        .Y(s_mem_d[321]) );
  sky130_fd_sc_hd__inv_1 U1288 ( .A(s_mem_q[320]), .Y(n951) );
  sky130_fd_sc_hd__o22ai_1 U1289 ( .A1(n139), .A2(n951), .B1(n655), .B2(n950), 
        .Y(s_mem_d[320]) );
  sky130_fd_sc_hd__nand3_1 U1290 ( .A(s_wr_ptr_q[5]), .B(n1379), .C(n1380), 
        .Y(n952) );
  sky130_fd_sc_hd__inv_1 U1291 ( .A(s_mem_q[319]), .Y(n954) );
  sky130_fd_sc_hd__o22ai_1 U1292 ( .A1(n138), .A2(n954), .B1(n650), .B2(n961), 
        .Y(s_mem_d[319]) );
  sky130_fd_sc_hd__inv_1 U1293 ( .A(s_mem_q[318]), .Y(n955) );
  sky130_fd_sc_hd__o22ai_1 U1294 ( .A1(n138), .A2(n955), .B1(n579), .B2(n961), 
        .Y(s_mem_d[318]) );
  sky130_fd_sc_hd__inv_1 U1295 ( .A(s_mem_q[317]), .Y(n956) );
  sky130_fd_sc_hd__o22ai_1 U1296 ( .A1(n138), .A2(n956), .B1(n593), .B2(n961), 
        .Y(s_mem_d[317]) );
  sky130_fd_sc_hd__inv_1 U1297 ( .A(s_mem_q[316]), .Y(n957) );
  sky130_fd_sc_hd__o22ai_1 U1298 ( .A1(n138), .A2(n957), .B1(n601), .B2(n961), 
        .Y(s_mem_d[316]) );
  sky130_fd_sc_hd__inv_1 U1299 ( .A(s_mem_q[315]), .Y(n958) );
  sky130_fd_sc_hd__o22ai_1 U1300 ( .A1(n138), .A2(n958), .B1(n612), .B2(n961), 
        .Y(s_mem_d[315]) );
  sky130_fd_sc_hd__inv_1 U1301 ( .A(s_mem_q[314]), .Y(n959) );
  sky130_fd_sc_hd__o22ai_1 U1302 ( .A1(n138), .A2(n959), .B1(n624), .B2(n961), 
        .Y(s_mem_d[314]) );
  sky130_fd_sc_hd__inv_1 U1303 ( .A(s_mem_q[313]), .Y(n960) );
  sky130_fd_sc_hd__o22ai_1 U1304 ( .A1(n138), .A2(n960), .B1(n36), .B2(n961), 
        .Y(s_mem_d[313]) );
  sky130_fd_sc_hd__inv_1 U1305 ( .A(s_mem_q[312]), .Y(n962) );
  sky130_fd_sc_hd__o22ai_1 U1306 ( .A1(n138), .A2(n962), .B1(n655), .B2(n961), 
        .Y(s_mem_d[312]) );
  sky130_fd_sc_hd__inv_1 U1307 ( .A(s_mem_q[311]), .Y(n964) );
  sky130_fd_sc_hd__o22ai_1 U1308 ( .A1(n137), .A2(n964), .B1(n650), .B2(n971), 
        .Y(s_mem_d[311]) );
  sky130_fd_sc_hd__inv_1 U1309 ( .A(s_mem_q[310]), .Y(n965) );
  sky130_fd_sc_hd__o22ai_1 U1310 ( .A1(n137), .A2(n965), .B1(n580), .B2(n971), 
        .Y(s_mem_d[310]) );
  sky130_fd_sc_hd__inv_1 U1311 ( .A(s_mem_q[309]), .Y(n966) );
  sky130_fd_sc_hd__o22ai_1 U1312 ( .A1(n137), .A2(n966), .B1(n591), .B2(n971), 
        .Y(s_mem_d[309]) );
  sky130_fd_sc_hd__inv_1 U1313 ( .A(s_mem_q[308]), .Y(n967) );
  sky130_fd_sc_hd__o22ai_1 U1314 ( .A1(n137), .A2(n967), .B1(n602), .B2(n971), 
        .Y(s_mem_d[308]) );
  sky130_fd_sc_hd__inv_1 U1315 ( .A(s_mem_q[307]), .Y(n968) );
  sky130_fd_sc_hd__o22ai_1 U1316 ( .A1(n137), .A2(n968), .B1(n614), .B2(n971), 
        .Y(s_mem_d[307]) );
  sky130_fd_sc_hd__inv_1 U1317 ( .A(s_mem_q[306]), .Y(n969) );
  sky130_fd_sc_hd__o22ai_1 U1318 ( .A1(n137), .A2(n969), .B1(n625), .B2(n971), 
        .Y(s_mem_d[306]) );
  sky130_fd_sc_hd__inv_1 U1319 ( .A(s_mem_q[305]), .Y(n970) );
  sky130_fd_sc_hd__o22ai_1 U1320 ( .A1(n137), .A2(n970), .B1(n35), .B2(n971), 
        .Y(s_mem_d[305]) );
  sky130_fd_sc_hd__inv_1 U1321 ( .A(s_mem_q[304]), .Y(n972) );
  sky130_fd_sc_hd__o22ai_1 U1322 ( .A1(n137), .A2(n972), .B1(n655), .B2(n971), 
        .Y(s_mem_d[304]) );
  sky130_fd_sc_hd__inv_1 U1323 ( .A(s_mem_q[303]), .Y(n974) );
  sky130_fd_sc_hd__o22ai_1 U1324 ( .A1(n136), .A2(n974), .B1(n651), .B2(n981), 
        .Y(s_mem_d[303]) );
  sky130_fd_sc_hd__inv_1 U1325 ( .A(s_mem_q[302]), .Y(n975) );
  sky130_fd_sc_hd__o22ai_1 U1326 ( .A1(n136), .A2(n975), .B1(n582), .B2(n981), 
        .Y(s_mem_d[302]) );
  sky130_fd_sc_hd__inv_1 U1327 ( .A(s_mem_q[301]), .Y(n976) );
  sky130_fd_sc_hd__o22ai_1 U1328 ( .A1(n136), .A2(n976), .B1(n590), .B2(n981), 
        .Y(s_mem_d[301]) );
  sky130_fd_sc_hd__inv_1 U1329 ( .A(s_mem_q[300]), .Y(n977) );
  sky130_fd_sc_hd__o22ai_1 U1330 ( .A1(n136), .A2(n977), .B1(n604), .B2(n981), 
        .Y(s_mem_d[300]) );
  sky130_fd_sc_hd__inv_1 U1331 ( .A(s_mem_q[299]), .Y(n978) );
  sky130_fd_sc_hd__o22ai_1 U1332 ( .A1(n136), .A2(n978), .B1(n613), .B2(n981), 
        .Y(s_mem_d[299]) );
  sky130_fd_sc_hd__inv_1 U1333 ( .A(s_mem_q[298]), .Y(n979) );
  sky130_fd_sc_hd__o22ai_1 U1334 ( .A1(n136), .A2(n979), .B1(n627), .B2(n981), 
        .Y(s_mem_d[298]) );
  sky130_fd_sc_hd__inv_1 U1335 ( .A(s_mem_q[297]), .Y(n980) );
  sky130_fd_sc_hd__o22ai_1 U1336 ( .A1(n136), .A2(n980), .B1(n37), .B2(n981), 
        .Y(s_mem_d[297]) );
  sky130_fd_sc_hd__inv_1 U1337 ( .A(s_mem_q[296]), .Y(n982) );
  sky130_fd_sc_hd__o22ai_1 U1338 ( .A1(n136), .A2(n982), .B1(n655), .B2(n981), 
        .Y(s_mem_d[296]) );
  sky130_fd_sc_hd__inv_1 U1339 ( .A(s_mem_q[295]), .Y(n984) );
  sky130_fd_sc_hd__o22ai_1 U1340 ( .A1(n135), .A2(n984), .B1(n651), .B2(n991), 
        .Y(s_mem_d[295]) );
  sky130_fd_sc_hd__inv_1 U1341 ( .A(s_mem_q[294]), .Y(n985) );
  sky130_fd_sc_hd__o22ai_1 U1342 ( .A1(n135), .A2(n985), .B1(n579), .B2(n991), 
        .Y(s_mem_d[294]) );
  sky130_fd_sc_hd__inv_1 U1343 ( .A(s_mem_q[293]), .Y(n986) );
  sky130_fd_sc_hd__o22ai_1 U1344 ( .A1(n135), .A2(n986), .B1(n590), .B2(n991), 
        .Y(s_mem_d[293]) );
  sky130_fd_sc_hd__inv_1 U1345 ( .A(s_mem_q[292]), .Y(n987) );
  sky130_fd_sc_hd__o22ai_1 U1346 ( .A1(n135), .A2(n987), .B1(n601), .B2(n991), 
        .Y(s_mem_d[292]) );
  sky130_fd_sc_hd__inv_1 U1347 ( .A(s_mem_q[291]), .Y(n988) );
  sky130_fd_sc_hd__o22ai_1 U1348 ( .A1(n135), .A2(n988), .B1(n612), .B2(n991), 
        .Y(s_mem_d[291]) );
  sky130_fd_sc_hd__inv_1 U1349 ( .A(s_mem_q[290]), .Y(n989) );
  sky130_fd_sc_hd__o22ai_1 U1350 ( .A1(n135), .A2(n989), .B1(n624), .B2(n991), 
        .Y(s_mem_d[290]) );
  sky130_fd_sc_hd__inv_1 U1351 ( .A(s_mem_q[289]), .Y(n990) );
  sky130_fd_sc_hd__o22ai_1 U1352 ( .A1(n135), .A2(n990), .B1(n42), .B2(n991), 
        .Y(s_mem_d[289]) );
  sky130_fd_sc_hd__inv_1 U1353 ( .A(s_mem_q[288]), .Y(n992) );
  sky130_fd_sc_hd__o22ai_1 U1354 ( .A1(n135), .A2(n992), .B1(n655), .B2(n991), 
        .Y(s_mem_d[288]) );
  sky130_fd_sc_hd__inv_1 U1355 ( .A(s_mem_q[287]), .Y(n994) );
  sky130_fd_sc_hd__o22ai_1 U1356 ( .A1(n134), .A2(n994), .B1(n651), .B2(n1001), 
        .Y(s_mem_d[287]) );
  sky130_fd_sc_hd__inv_1 U1357 ( .A(s_mem_q[286]), .Y(n995) );
  sky130_fd_sc_hd__o22ai_1 U1358 ( .A1(n134), .A2(n995), .B1(n581), .B2(n1001), 
        .Y(s_mem_d[286]) );
  sky130_fd_sc_hd__inv_1 U1359 ( .A(s_mem_q[285]), .Y(n996) );
  sky130_fd_sc_hd__o22ai_1 U1360 ( .A1(n134), .A2(n996), .B1(n592), .B2(n1001), 
        .Y(s_mem_d[285]) );
  sky130_fd_sc_hd__inv_1 U1361 ( .A(s_mem_q[284]), .Y(n997) );
  sky130_fd_sc_hd__o22ai_1 U1362 ( .A1(n134), .A2(n997), .B1(n603), .B2(n1001), 
        .Y(s_mem_d[284]) );
  sky130_fd_sc_hd__inv_1 U1363 ( .A(s_mem_q[283]), .Y(n998) );
  sky130_fd_sc_hd__o22ai_1 U1364 ( .A1(n134), .A2(n998), .B1(n615), .B2(n1001), 
        .Y(s_mem_d[283]) );
  sky130_fd_sc_hd__inv_1 U1365 ( .A(s_mem_q[282]), .Y(n999) );
  sky130_fd_sc_hd__o22ai_1 U1366 ( .A1(n134), .A2(n999), .B1(n626), .B2(n1001), 
        .Y(s_mem_d[282]) );
  sky130_fd_sc_hd__inv_1 U1367 ( .A(s_mem_q[281]), .Y(n1000) );
  sky130_fd_sc_hd__o22ai_1 U1368 ( .A1(n134), .A2(n1000), .B1(n36), .B2(n1001), 
        .Y(s_mem_d[281]) );
  sky130_fd_sc_hd__inv_1 U1369 ( .A(s_mem_q[280]), .Y(n1002) );
  sky130_fd_sc_hd__o22ai_1 U1370 ( .A1(n134), .A2(n1002), .B1(n656), .B2(n1001), .Y(s_mem_d[280]) );
  sky130_fd_sc_hd__inv_1 U1371 ( .A(s_mem_q[279]), .Y(n1004) );
  sky130_fd_sc_hd__o22ai_1 U1372 ( .A1(n133), .A2(n1004), .B1(n651), .B2(n1011), .Y(s_mem_d[279]) );
  sky130_fd_sc_hd__inv_1 U1373 ( .A(s_mem_q[278]), .Y(n1005) );
  sky130_fd_sc_hd__o22ai_1 U1374 ( .A1(n133), .A2(n1005), .B1(n581), .B2(n1011), .Y(s_mem_d[278]) );
  sky130_fd_sc_hd__inv_1 U1375 ( .A(s_mem_q[277]), .Y(n1006) );
  sky130_fd_sc_hd__o22ai_1 U1376 ( .A1(n133), .A2(n1006), .B1(n592), .B2(n1011), .Y(s_mem_d[277]) );
  sky130_fd_sc_hd__inv_1 U1377 ( .A(s_mem_q[276]), .Y(n1007) );
  sky130_fd_sc_hd__o22ai_1 U1378 ( .A1(n133), .A2(n1007), .B1(n603), .B2(n1011), .Y(s_mem_d[276]) );
  sky130_fd_sc_hd__inv_1 U1379 ( .A(s_mem_q[275]), .Y(n1008) );
  sky130_fd_sc_hd__o22ai_1 U1380 ( .A1(n133), .A2(n1008), .B1(n615), .B2(n1011), .Y(s_mem_d[275]) );
  sky130_fd_sc_hd__inv_1 U1381 ( .A(s_mem_q[274]), .Y(n1009) );
  sky130_fd_sc_hd__o22ai_1 U1382 ( .A1(n133), .A2(n1009), .B1(n626), .B2(n1011), .Y(s_mem_d[274]) );
  sky130_fd_sc_hd__inv_1 U1383 ( .A(s_mem_q[273]), .Y(n1010) );
  sky130_fd_sc_hd__o22ai_1 U1384 ( .A1(n133), .A2(n1010), .B1(n57), .B2(n1011), 
        .Y(s_mem_d[273]) );
  sky130_fd_sc_hd__inv_1 U1385 ( .A(s_mem_q[272]), .Y(n1012) );
  sky130_fd_sc_hd__o22ai_1 U1386 ( .A1(n133), .A2(n1012), .B1(n656), .B2(n1011), .Y(s_mem_d[272]) );
  sky130_fd_sc_hd__inv_1 U1387 ( .A(s_mem_q[271]), .Y(n1014) );
  sky130_fd_sc_hd__o22ai_1 U1388 ( .A1(n132), .A2(n1014), .B1(n651), .B2(n1021), .Y(s_mem_d[271]) );
  sky130_fd_sc_hd__inv_1 U1389 ( .A(s_mem_q[270]), .Y(n1015) );
  sky130_fd_sc_hd__o22ai_1 U1390 ( .A1(n132), .A2(n1015), .B1(n580), .B2(n1021), .Y(s_mem_d[270]) );
  sky130_fd_sc_hd__inv_1 U1391 ( .A(s_mem_q[269]), .Y(n1016) );
  sky130_fd_sc_hd__o22ai_1 U1392 ( .A1(n132), .A2(n1016), .B1(n591), .B2(n1021), .Y(s_mem_d[269]) );
  sky130_fd_sc_hd__inv_1 U1393 ( .A(s_mem_q[268]), .Y(n1017) );
  sky130_fd_sc_hd__o22ai_1 U1394 ( .A1(n132), .A2(n1017), .B1(n602), .B2(n1021), .Y(s_mem_d[268]) );
  sky130_fd_sc_hd__inv_1 U1395 ( .A(s_mem_q[267]), .Y(n1018) );
  sky130_fd_sc_hd__o22ai_1 U1396 ( .A1(n132), .A2(n1018), .B1(n614), .B2(n1021), .Y(s_mem_d[267]) );
  sky130_fd_sc_hd__inv_1 U1397 ( .A(s_mem_q[266]), .Y(n1019) );
  sky130_fd_sc_hd__o22ai_1 U1398 ( .A1(n132), .A2(n1019), .B1(n625), .B2(n1021), .Y(s_mem_d[266]) );
  sky130_fd_sc_hd__inv_1 U1399 ( .A(s_mem_q[265]), .Y(n1020) );
  sky130_fd_sc_hd__o22ai_1 U1400 ( .A1(n132), .A2(n1020), .B1(n56), .B2(n1021), 
        .Y(s_mem_d[265]) );
  sky130_fd_sc_hd__inv_1 U1401 ( .A(s_mem_q[264]), .Y(n1022) );
  sky130_fd_sc_hd__o22ai_1 U1402 ( .A1(n132), .A2(n1022), .B1(n656), .B2(n1021), .Y(s_mem_d[264]) );
  sky130_fd_sc_hd__inv_1 U1403 ( .A(s_mem_q[263]), .Y(n1025) );
  sky130_fd_sc_hd__o22ai_1 U1404 ( .A1(n131), .A2(n1025), .B1(n651), .B2(n1032), .Y(s_mem_d[263]) );
  sky130_fd_sc_hd__inv_1 U1405 ( .A(s_mem_q[262]), .Y(n1026) );
  sky130_fd_sc_hd__o22ai_1 U1406 ( .A1(n131), .A2(n1026), .B1(n578), .B2(n1032), .Y(s_mem_d[262]) );
  sky130_fd_sc_hd__inv_1 U1407 ( .A(s_mem_q[261]), .Y(n1027) );
  sky130_fd_sc_hd__o22ai_1 U1408 ( .A1(n131), .A2(n1027), .B1(n590), .B2(n1032), .Y(s_mem_d[261]) );
  sky130_fd_sc_hd__inv_1 U1409 ( .A(s_mem_q[260]), .Y(n1028) );
  sky130_fd_sc_hd__o22ai_1 U1410 ( .A1(n131), .A2(n1028), .B1(n600), .B2(n1032), .Y(s_mem_d[260]) );
  sky130_fd_sc_hd__inv_1 U1411 ( .A(s_mem_q[259]), .Y(n1029) );
  sky130_fd_sc_hd__o22ai_1 U1412 ( .A1(n131), .A2(n1029), .B1(n613), .B2(n1032), .Y(s_mem_d[259]) );
  sky130_fd_sc_hd__inv_1 U1413 ( .A(s_mem_q[258]), .Y(n1030) );
  sky130_fd_sc_hd__o22ai_1 U1414 ( .A1(n131), .A2(n1030), .B1(n623), .B2(n1032), .Y(s_mem_d[258]) );
  sky130_fd_sc_hd__inv_1 U1415 ( .A(s_mem_q[257]), .Y(n1031) );
  sky130_fd_sc_hd__o22ai_1 U1416 ( .A1(n131), .A2(n1031), .B1(n55), .B2(n1032), 
        .Y(s_mem_d[257]) );
  sky130_fd_sc_hd__inv_1 U1417 ( .A(s_mem_q[256]), .Y(n1033) );
  sky130_fd_sc_hd__o22ai_1 U1418 ( .A1(n131), .A2(n1033), .B1(n656), .B2(n1032), .Y(s_mem_d[256]) );
  sky130_fd_sc_hd__inv_1 U1419 ( .A(s_wr_ptr_q[5]), .Y(n1378) );
  sky130_fd_sc_hd__nand2_1 U1420 ( .A(n166), .B(n1378), .Y(n1034) );
  sky130_fd_sc_hd__inv_1 U1421 ( .A(s_mem_q[255]), .Y(n1036) );
  sky130_fd_sc_hd__o22ai_1 U1422 ( .A1(n112), .A2(n1036), .B1(n651), .B2(n1042), .Y(s_mem_d[255]) );
  sky130_fd_sc_hd__inv_1 U1423 ( .A(s_mem_q[254]), .Y(n1037) );
  sky130_fd_sc_hd__o22ai_1 U1424 ( .A1(n112), .A2(n1037), .B1(n580), .B2(n1042), .Y(s_mem_d[254]) );
  sky130_fd_sc_hd__inv_1 U1425 ( .A(s_mem_q[253]), .Y(n1038) );
  sky130_fd_sc_hd__o22ai_1 U1426 ( .A1(n112), .A2(n1038), .B1(n591), .B2(n1042), .Y(s_mem_d[253]) );
  sky130_fd_sc_hd__o22ai_1 U1427 ( .A1(n112), .A2(n17), .B1(n602), .B2(n1042), 
        .Y(s_mem_d[252]) );
  sky130_fd_sc_hd__inv_1 U1428 ( .A(s_mem_q[251]), .Y(n1039) );
  sky130_fd_sc_hd__o22ai_1 U1429 ( .A1(n112), .A2(n1039), .B1(n614), .B2(n1042), .Y(s_mem_d[251]) );
  sky130_fd_sc_hd__inv_1 U1430 ( .A(s_mem_q[250]), .Y(n1040) );
  sky130_fd_sc_hd__o22ai_1 U1431 ( .A1(n112), .A2(n1040), .B1(n625), .B2(n1042), .Y(s_mem_d[250]) );
  sky130_fd_sc_hd__inv_1 U1432 ( .A(s_mem_q[249]), .Y(n1041) );
  sky130_fd_sc_hd__o22ai_1 U1433 ( .A1(n112), .A2(n1041), .B1(n55), .B2(n1042), 
        .Y(s_mem_d[249]) );
  sky130_fd_sc_hd__inv_1 U1434 ( .A(s_mem_q[248]), .Y(n1043) );
  sky130_fd_sc_hd__o22ai_1 U1435 ( .A1(n112), .A2(n1043), .B1(n656), .B2(n1042), .Y(s_mem_d[248]) );
  sky130_fd_sc_hd__inv_1 U1436 ( .A(s_mem_q[247]), .Y(n1045) );
  sky130_fd_sc_hd__o22ai_1 U1437 ( .A1(n111), .A2(n1045), .B1(n651), .B2(n1052), .Y(s_mem_d[247]) );
  sky130_fd_sc_hd__inv_1 U1438 ( .A(s_mem_q[246]), .Y(n1046) );
  sky130_fd_sc_hd__o22ai_1 U1439 ( .A1(n111), .A2(n1046), .B1(n582), .B2(n1052), .Y(s_mem_d[246]) );
  sky130_fd_sc_hd__inv_1 U1440 ( .A(s_mem_q[245]), .Y(n1047) );
  sky130_fd_sc_hd__o22ai_1 U1441 ( .A1(n111), .A2(n1047), .B1(n593), .B2(n1052), .Y(s_mem_d[245]) );
  sky130_fd_sc_hd__inv_1 U1442 ( .A(s_mem_q[244]), .Y(n1048) );
  sky130_fd_sc_hd__o22ai_1 U1443 ( .A1(n111), .A2(n1048), .B1(n604), .B2(n1052), .Y(s_mem_d[244]) );
  sky130_fd_sc_hd__inv_1 U1444 ( .A(s_mem_q[243]), .Y(n1049) );
  sky130_fd_sc_hd__o22ai_1 U1445 ( .A1(n111), .A2(n1049), .B1(n616), .B2(n1052), .Y(s_mem_d[243]) );
  sky130_fd_sc_hd__inv_1 U1446 ( .A(s_mem_q[242]), .Y(n1050) );
  sky130_fd_sc_hd__o22ai_1 U1447 ( .A1(n111), .A2(n1050), .B1(n627), .B2(n1052), .Y(s_mem_d[242]) );
  sky130_fd_sc_hd__inv_1 U1448 ( .A(s_mem_q[241]), .Y(n1051) );
  sky130_fd_sc_hd__o22ai_1 U1449 ( .A1(n111), .A2(n1051), .B1(n51), .B2(n1052), 
        .Y(s_mem_d[241]) );
  sky130_fd_sc_hd__inv_1 U1450 ( .A(s_mem_q[240]), .Y(n1053) );
  sky130_fd_sc_hd__o22ai_1 U1451 ( .A1(n111), .A2(n1053), .B1(n656), .B2(n1052), .Y(s_mem_d[240]) );
  sky130_fd_sc_hd__inv_1 U1452 ( .A(s_mem_q[239]), .Y(n1055) );
  sky130_fd_sc_hd__o22ai_1 U1453 ( .A1(n110), .A2(n1055), .B1(n651), .B2(n1062), .Y(s_mem_d[239]) );
  sky130_fd_sc_hd__inv_1 U1454 ( .A(s_mem_q[238]), .Y(n1056) );
  sky130_fd_sc_hd__o22ai_1 U1455 ( .A1(n110), .A2(n1056), .B1(n582), .B2(n1062), .Y(s_mem_d[238]) );
  sky130_fd_sc_hd__inv_1 U1456 ( .A(s_mem_q[237]), .Y(n1057) );
  sky130_fd_sc_hd__o22ai_1 U1457 ( .A1(n110), .A2(n1057), .B1(n593), .B2(n1062), .Y(s_mem_d[237]) );
  sky130_fd_sc_hd__inv_1 U1458 ( .A(s_mem_q[236]), .Y(n1058) );
  sky130_fd_sc_hd__o22ai_1 U1459 ( .A1(n110), .A2(n1058), .B1(n604), .B2(n1062), .Y(s_mem_d[236]) );
  sky130_fd_sc_hd__inv_1 U1460 ( .A(s_mem_q[235]), .Y(n1059) );
  sky130_fd_sc_hd__o22ai_1 U1461 ( .A1(n110), .A2(n1059), .B1(n616), .B2(n1062), .Y(s_mem_d[235]) );
  sky130_fd_sc_hd__inv_1 U1462 ( .A(s_mem_q[234]), .Y(n1060) );
  sky130_fd_sc_hd__o22ai_1 U1463 ( .A1(n110), .A2(n1060), .B1(n627), .B2(n1062), .Y(s_mem_d[234]) );
  sky130_fd_sc_hd__inv_1 U1464 ( .A(s_mem_q[233]), .Y(n1061) );
  sky130_fd_sc_hd__o22ai_1 U1465 ( .A1(n110), .A2(n1061), .B1(n50), .B2(n1062), 
        .Y(s_mem_d[233]) );
  sky130_fd_sc_hd__inv_1 U1466 ( .A(s_mem_q[232]), .Y(n1063) );
  sky130_fd_sc_hd__o22ai_1 U1467 ( .A1(n110), .A2(n1063), .B1(n656), .B2(n1062), .Y(s_mem_d[232]) );
  sky130_fd_sc_hd__inv_1 U1468 ( .A(s_mem_q[231]), .Y(n1065) );
  sky130_fd_sc_hd__o22ai_1 U1469 ( .A1(n109), .A2(n1065), .B1(n651), .B2(n1072), .Y(s_mem_d[231]) );
  sky130_fd_sc_hd__inv_1 U1470 ( .A(s_mem_q[230]), .Y(n1066) );
  sky130_fd_sc_hd__o22ai_1 U1471 ( .A1(n109), .A2(n1066), .B1(n581), .B2(n1072), .Y(s_mem_d[230]) );
  sky130_fd_sc_hd__inv_1 U1472 ( .A(s_mem_q[229]), .Y(n1067) );
  sky130_fd_sc_hd__o22ai_1 U1473 ( .A1(n109), .A2(n1067), .B1(n592), .B2(n1072), .Y(s_mem_d[229]) );
  sky130_fd_sc_hd__inv_1 U1474 ( .A(s_mem_q[228]), .Y(n1068) );
  sky130_fd_sc_hd__o22ai_1 U1475 ( .A1(n109), .A2(n1068), .B1(n603), .B2(n1072), .Y(s_mem_d[228]) );
  sky130_fd_sc_hd__inv_1 U1476 ( .A(s_mem_q[227]), .Y(n1069) );
  sky130_fd_sc_hd__o22ai_1 U1477 ( .A1(n109), .A2(n1069), .B1(n615), .B2(n1072), .Y(s_mem_d[227]) );
  sky130_fd_sc_hd__inv_1 U1478 ( .A(s_mem_q[226]), .Y(n1070) );
  sky130_fd_sc_hd__o22ai_1 U1479 ( .A1(n109), .A2(n1070), .B1(n626), .B2(n1072), .Y(s_mem_d[226]) );
  sky130_fd_sc_hd__inv_1 U1480 ( .A(s_mem_q[225]), .Y(n1071) );
  sky130_fd_sc_hd__o22ai_1 U1481 ( .A1(n109), .A2(n1071), .B1(n49), .B2(n1072), 
        .Y(s_mem_d[225]) );
  sky130_fd_sc_hd__inv_1 U1482 ( .A(s_mem_q[224]), .Y(n1073) );
  sky130_fd_sc_hd__o22ai_1 U1483 ( .A1(n109), .A2(n1073), .B1(n656), .B2(n1072), .Y(s_mem_d[224]) );
  sky130_fd_sc_hd__inv_1 U1484 ( .A(s_mem_q[223]), .Y(n1075) );
  sky130_fd_sc_hd__o22ai_1 U1485 ( .A1(n102), .A2(n1075), .B1(n651), .B2(n1078), .Y(s_mem_d[223]) );
  sky130_fd_sc_hd__inv_1 U1486 ( .A(s_mem_q[222]), .Y(n1076) );
  sky130_fd_sc_hd__o22ai_1 U1487 ( .A1(n102), .A2(n1076), .B1(n579), .B2(n1078), .Y(s_mem_d[222]) );
  sky130_fd_sc_hd__inv_1 U1488 ( .A(s_mem_q[221]), .Y(n1077) );
  sky130_fd_sc_hd__o22ai_1 U1489 ( .A1(n102), .A2(n1077), .B1(n591), .B2(n1078), .Y(s_mem_d[221]) );
  sky130_fd_sc_hd__o22ai_1 U1490 ( .A1(n102), .A2(n21), .B1(n601), .B2(n1078), 
        .Y(s_mem_d[220]) );
  sky130_fd_sc_hd__o22ai_1 U1491 ( .A1(n102), .A2(n27), .B1(n612), .B2(n1078), 
        .Y(s_mem_d[219]) );
  sky130_fd_sc_hd__o22ai_1 U1492 ( .A1(n102), .A2(n25), .B1(n624), .B2(n1078), 
        .Y(s_mem_d[218]) );
  sky130_fd_sc_hd__o22ai_1 U1493 ( .A1(n102), .A2(n23), .B1(n56), .B2(n1078), 
        .Y(s_mem_d[217]) );
  sky130_fd_sc_hd__inv_1 U1494 ( .A(s_mem_q[216]), .Y(n1079) );
  sky130_fd_sc_hd__o22ai_1 U1495 ( .A1(n102), .A2(n1079), .B1(n656), .B2(n1078), .Y(s_mem_d[216]) );
  sky130_fd_sc_hd__inv_1 U1496 ( .A(s_mem_q[215]), .Y(n1081) );
  sky130_fd_sc_hd__o22ai_1 U1497 ( .A1(n108), .A2(n1081), .B1(n651), .B2(n1088), .Y(s_mem_d[215]) );
  sky130_fd_sc_hd__inv_1 U1498 ( .A(s_mem_q[214]), .Y(n1082) );
  sky130_fd_sc_hd__o22ai_1 U1499 ( .A1(n108), .A2(n1082), .B1(n579), .B2(n1088), .Y(s_mem_d[214]) );
  sky130_fd_sc_hd__inv_1 U1500 ( .A(s_mem_q[213]), .Y(n1083) );
  sky130_fd_sc_hd__o22ai_1 U1501 ( .A1(n108), .A2(n1083), .B1(n592), .B2(n1088), .Y(s_mem_d[213]) );
  sky130_fd_sc_hd__inv_1 U1502 ( .A(s_mem_q[212]), .Y(n1084) );
  sky130_fd_sc_hd__o22ai_1 U1503 ( .A1(n108), .A2(n1084), .B1(n601), .B2(n1088), .Y(s_mem_d[212]) );
  sky130_fd_sc_hd__inv_1 U1504 ( .A(s_mem_q[211]), .Y(n1085) );
  sky130_fd_sc_hd__o22ai_1 U1505 ( .A1(n108), .A2(n1085), .B1(n612), .B2(n1088), .Y(s_mem_d[211]) );
  sky130_fd_sc_hd__inv_1 U1506 ( .A(s_mem_q[210]), .Y(n1086) );
  sky130_fd_sc_hd__o22ai_1 U1507 ( .A1(n108), .A2(n1086), .B1(n624), .B2(n1088), .Y(s_mem_d[210]) );
  sky130_fd_sc_hd__inv_1 U1508 ( .A(s_mem_q[209]), .Y(n1087) );
  sky130_fd_sc_hd__o22ai_1 U1509 ( .A1(n108), .A2(n1087), .B1(n48), .B2(n1088), 
        .Y(s_mem_d[209]) );
  sky130_fd_sc_hd__inv_1 U1510 ( .A(s_mem_q[208]), .Y(n1089) );
  sky130_fd_sc_hd__o22ai_1 U1511 ( .A1(n108), .A2(n1089), .B1(n656), .B2(n1088), .Y(s_mem_d[208]) );
  sky130_fd_sc_hd__inv_1 U1512 ( .A(s_mem_q[207]), .Y(n1091) );
  sky130_fd_sc_hd__o22ai_1 U1513 ( .A1(n107), .A2(n1091), .B1(n651), .B2(n1098), .Y(s_mem_d[207]) );
  sky130_fd_sc_hd__inv_1 U1514 ( .A(s_mem_q[206]), .Y(n1092) );
  sky130_fd_sc_hd__o22ai_1 U1515 ( .A1(n107), .A2(n1092), .B1(n578), .B2(n1098), .Y(s_mem_d[206]) );
  sky130_fd_sc_hd__inv_1 U1516 ( .A(s_mem_q[205]), .Y(n1093) );
  sky130_fd_sc_hd__o22ai_1 U1517 ( .A1(n107), .A2(n1093), .B1(n589), .B2(n1098), .Y(s_mem_d[205]) );
  sky130_fd_sc_hd__inv_1 U1518 ( .A(s_mem_q[204]), .Y(n1094) );
  sky130_fd_sc_hd__o22ai_1 U1519 ( .A1(n107), .A2(n1094), .B1(n600), .B2(n1098), .Y(s_mem_d[204]) );
  sky130_fd_sc_hd__inv_1 U1520 ( .A(s_mem_q[203]), .Y(n1095) );
  sky130_fd_sc_hd__o22ai_1 U1521 ( .A1(n107), .A2(n1095), .B1(n611), .B2(n1098), .Y(s_mem_d[203]) );
  sky130_fd_sc_hd__inv_1 U1522 ( .A(s_mem_q[202]), .Y(n1096) );
  sky130_fd_sc_hd__o22ai_1 U1523 ( .A1(n107), .A2(n1096), .B1(n623), .B2(n1098), .Y(s_mem_d[202]) );
  sky130_fd_sc_hd__inv_1 U1524 ( .A(s_mem_q[201]), .Y(n1097) );
  sky130_fd_sc_hd__o22ai_1 U1525 ( .A1(n107), .A2(n1097), .B1(n47), .B2(n1098), 
        .Y(s_mem_d[201]) );
  sky130_fd_sc_hd__inv_1 U1526 ( .A(s_mem_q[200]), .Y(n1099) );
  sky130_fd_sc_hd__o22ai_1 U1527 ( .A1(n107), .A2(n1099), .B1(n656), .B2(n1098), .Y(s_mem_d[200]) );
  sky130_fd_sc_hd__inv_1 U1528 ( .A(s_mem_q[199]), .Y(n1102) );
  sky130_fd_sc_hd__o22ai_1 U1529 ( .A1(n101), .A2(n1102), .B1(n652), .B2(n1109), .Y(s_mem_d[199]) );
  sky130_fd_sc_hd__inv_1 U1530 ( .A(s_mem_q[198]), .Y(n1103) );
  sky130_fd_sc_hd__o22ai_1 U1531 ( .A1(n101), .A2(n1103), .B1(n577), .B2(n1109), .Y(s_mem_d[198]) );
  sky130_fd_sc_hd__inv_1 U1532 ( .A(s_mem_q[197]), .Y(n1104) );
  sky130_fd_sc_hd__o22ai_1 U1533 ( .A1(n101), .A2(n1104), .B1(n588), .B2(n1109), .Y(s_mem_d[197]) );
  sky130_fd_sc_hd__inv_1 U1534 ( .A(s_mem_q[196]), .Y(n1105) );
  sky130_fd_sc_hd__o22ai_1 U1535 ( .A1(n101), .A2(n1105), .B1(n599), .B2(n1109), .Y(s_mem_d[196]) );
  sky130_fd_sc_hd__inv_1 U1536 ( .A(s_mem_q[195]), .Y(n1106) );
  sky130_fd_sc_hd__o22ai_1 U1537 ( .A1(n101), .A2(n1106), .B1(n610), .B2(n1109), .Y(s_mem_d[195]) );
  sky130_fd_sc_hd__inv_1 U1538 ( .A(s_mem_q[194]), .Y(n1107) );
  sky130_fd_sc_hd__o22ai_1 U1539 ( .A1(n101), .A2(n1107), .B1(n622), .B2(n1109), .Y(s_mem_d[194]) );
  sky130_fd_sc_hd__inv_1 U1540 ( .A(s_mem_q[193]), .Y(n1108) );
  sky130_fd_sc_hd__o22ai_1 U1541 ( .A1(n101), .A2(n1108), .B1(n46), .B2(n1109), 
        .Y(s_mem_d[193]) );
  sky130_fd_sc_hd__inv_1 U1542 ( .A(s_mem_q[192]), .Y(n1110) );
  sky130_fd_sc_hd__o22ai_1 U1543 ( .A1(n101), .A2(n1110), .B1(n656), .B2(n1109), .Y(s_mem_d[192]) );
  sky130_fd_sc_hd__nand3_1 U1544 ( .A(s_wr_ptr_q[4]), .B(n1378), .C(n1380), 
        .Y(n1111) );
  sky130_fd_sc_hd__inv_1 U1545 ( .A(s_mem_q[191]), .Y(n1113) );
  sky130_fd_sc_hd__o22ai_1 U1546 ( .A1(n130), .A2(n1113), .B1(n652), .B2(n1120), .Y(s_mem_d[191]) );
  sky130_fd_sc_hd__inv_1 U1547 ( .A(s_mem_q[190]), .Y(n1114) );
  sky130_fd_sc_hd__o22ai_1 U1548 ( .A1(n130), .A2(n1114), .B1(n579), .B2(n1120), .Y(s_mem_d[190]) );
  sky130_fd_sc_hd__inv_1 U1549 ( .A(s_mem_q[189]), .Y(n1115) );
  sky130_fd_sc_hd__o22ai_1 U1550 ( .A1(n130), .A2(n1115), .B1(n591), .B2(n1120), .Y(s_mem_d[189]) );
  sky130_fd_sc_hd__inv_1 U1551 ( .A(s_mem_q[188]), .Y(n1116) );
  sky130_fd_sc_hd__o22ai_1 U1552 ( .A1(n130), .A2(n1116), .B1(n601), .B2(n1120), .Y(s_mem_d[188]) );
  sky130_fd_sc_hd__inv_1 U1553 ( .A(s_mem_q[187]), .Y(n1117) );
  sky130_fd_sc_hd__o22ai_1 U1554 ( .A1(n130), .A2(n1117), .B1(n612), .B2(n1120), .Y(s_mem_d[187]) );
  sky130_fd_sc_hd__inv_1 U1555 ( .A(s_mem_q[186]), .Y(n1118) );
  sky130_fd_sc_hd__o22ai_1 U1556 ( .A1(n130), .A2(n1118), .B1(n624), .B2(n1120), .Y(s_mem_d[186]) );
  sky130_fd_sc_hd__inv_1 U1557 ( .A(s_mem_q[185]), .Y(n1119) );
  sky130_fd_sc_hd__o22ai_1 U1558 ( .A1(n130), .A2(n1119), .B1(n35), .B2(n1120), 
        .Y(s_mem_d[185]) );
  sky130_fd_sc_hd__inv_1 U1559 ( .A(s_mem_q[184]), .Y(n1121) );
  sky130_fd_sc_hd__o22ai_1 U1560 ( .A1(n130), .A2(n1121), .B1(n657), .B2(n1120), .Y(s_mem_d[184]) );
  sky130_fd_sc_hd__inv_1 U1561 ( .A(s_mem_q[183]), .Y(n1123) );
  sky130_fd_sc_hd__o22ai_1 U1562 ( .A1(n129), .A2(n1123), .B1(n652), .B2(n1130), .Y(s_mem_d[183]) );
  sky130_fd_sc_hd__inv_1 U1563 ( .A(s_mem_q[182]), .Y(n1124) );
  sky130_fd_sc_hd__o22ai_1 U1564 ( .A1(n129), .A2(n1124), .B1(n585), .B2(n1130), .Y(s_mem_d[182]) );
  sky130_fd_sc_hd__inv_1 U1565 ( .A(s_mem_q[181]), .Y(n1125) );
  sky130_fd_sc_hd__o22ai_1 U1566 ( .A1(n129), .A2(n1125), .B1(n596), .B2(n1130), .Y(s_mem_d[181]) );
  sky130_fd_sc_hd__inv_1 U1567 ( .A(s_mem_q[180]), .Y(n1126) );
  sky130_fd_sc_hd__o22ai_1 U1568 ( .A1(n129), .A2(n1126), .B1(n607), .B2(n1130), .Y(s_mem_d[180]) );
  sky130_fd_sc_hd__inv_1 U1569 ( .A(s_mem_q[179]), .Y(n1127) );
  sky130_fd_sc_hd__o22ai_1 U1570 ( .A1(n129), .A2(n1127), .B1(n619), .B2(n1130), .Y(s_mem_d[179]) );
  sky130_fd_sc_hd__inv_1 U1571 ( .A(s_mem_q[178]), .Y(n1128) );
  sky130_fd_sc_hd__o22ai_1 U1572 ( .A1(n129), .A2(n1128), .B1(n630), .B2(n1130), .Y(s_mem_d[178]) );
  sky130_fd_sc_hd__inv_1 U1573 ( .A(s_mem_q[177]), .Y(n1129) );
  sky130_fd_sc_hd__o22ai_1 U1574 ( .A1(n129), .A2(n1129), .B1(n58), .B2(n1130), 
        .Y(s_mem_d[177]) );
  sky130_fd_sc_hd__inv_1 U1575 ( .A(s_mem_q[176]), .Y(n1131) );
  sky130_fd_sc_hd__o22ai_1 U1576 ( .A1(n129), .A2(n1131), .B1(n657), .B2(n1130), .Y(s_mem_d[176]) );
  sky130_fd_sc_hd__inv_1 U1577 ( .A(s_mem_q[175]), .Y(n1133) );
  sky130_fd_sc_hd__o22ai_1 U1578 ( .A1(n106), .A2(n1133), .B1(n652), .B2(n1140), .Y(s_mem_d[175]) );
  sky130_fd_sc_hd__inv_1 U1579 ( .A(s_mem_q[174]), .Y(n1134) );
  sky130_fd_sc_hd__o22ai_1 U1580 ( .A1(n106), .A2(n1134), .B1(n577), .B2(n1140), .Y(s_mem_d[174]) );
  sky130_fd_sc_hd__inv_1 U1581 ( .A(s_mem_q[173]), .Y(n1135) );
  sky130_fd_sc_hd__o22ai_1 U1582 ( .A1(n106), .A2(n1135), .B1(n588), .B2(n1140), .Y(s_mem_d[173]) );
  sky130_fd_sc_hd__inv_1 U1583 ( .A(s_mem_q[172]), .Y(n1136) );
  sky130_fd_sc_hd__o22ai_1 U1584 ( .A1(n106), .A2(n1136), .B1(n599), .B2(n1140), .Y(s_mem_d[172]) );
  sky130_fd_sc_hd__inv_1 U1585 ( .A(s_mem_q[171]), .Y(n1137) );
  sky130_fd_sc_hd__o22ai_1 U1586 ( .A1(n106), .A2(n1137), .B1(n610), .B2(n1140), .Y(s_mem_d[171]) );
  sky130_fd_sc_hd__inv_1 U1587 ( .A(s_mem_q[170]), .Y(n1138) );
  sky130_fd_sc_hd__o22ai_1 U1588 ( .A1(n106), .A2(n1138), .B1(n622), .B2(n1140), .Y(s_mem_d[170]) );
  sky130_fd_sc_hd__inv_1 U1589 ( .A(s_mem_q[169]), .Y(n1139) );
  sky130_fd_sc_hd__o22ai_1 U1590 ( .A1(n106), .A2(n1139), .B1(n58), .B2(n1140), 
        .Y(s_mem_d[169]) );
  sky130_fd_sc_hd__inv_1 U1591 ( .A(s_mem_q[168]), .Y(n1141) );
  sky130_fd_sc_hd__o22ai_1 U1592 ( .A1(n106), .A2(n1141), .B1(n657), .B2(n1140), .Y(s_mem_d[168]) );
  sky130_fd_sc_hd__inv_1 U1593 ( .A(s_mem_q[167]), .Y(n1143) );
  sky130_fd_sc_hd__o22ai_1 U1594 ( .A1(n128), .A2(n1143), .B1(n652), .B2(n1150), .Y(s_mem_d[167]) );
  sky130_fd_sc_hd__inv_1 U1595 ( .A(s_mem_q[166]), .Y(n1144) );
  sky130_fd_sc_hd__o22ai_1 U1596 ( .A1(n128), .A2(n1144), .B1(n577), .B2(n1150), .Y(s_mem_d[166]) );
  sky130_fd_sc_hd__inv_1 U1597 ( .A(s_mem_q[165]), .Y(n1145) );
  sky130_fd_sc_hd__o22ai_1 U1598 ( .A1(n128), .A2(n1145), .B1(n588), .B2(n1150), .Y(s_mem_d[165]) );
  sky130_fd_sc_hd__inv_1 U1599 ( .A(s_mem_q[164]), .Y(n1146) );
  sky130_fd_sc_hd__o22ai_1 U1600 ( .A1(n128), .A2(n1146), .B1(n599), .B2(n1150), .Y(s_mem_d[164]) );
  sky130_fd_sc_hd__inv_1 U1601 ( .A(s_mem_q[163]), .Y(n1147) );
  sky130_fd_sc_hd__o22ai_1 U1602 ( .A1(n128), .A2(n1147), .B1(n610), .B2(n1150), .Y(s_mem_d[163]) );
  sky130_fd_sc_hd__inv_1 U1603 ( .A(s_mem_q[162]), .Y(n1148) );
  sky130_fd_sc_hd__o22ai_1 U1604 ( .A1(n128), .A2(n1148), .B1(n622), .B2(n1150), .Y(s_mem_d[162]) );
  sky130_fd_sc_hd__inv_1 U1605 ( .A(s_mem_q[161]), .Y(n1149) );
  sky130_fd_sc_hd__o22ai_1 U1606 ( .A1(n128), .A2(n1149), .B1(n57), .B2(n1150), 
        .Y(s_mem_d[161]) );
  sky130_fd_sc_hd__inv_1 U1607 ( .A(s_mem_q[160]), .Y(n1151) );
  sky130_fd_sc_hd__o22ai_1 U1608 ( .A1(n128), .A2(n1151), .B1(n657), .B2(n1150), .Y(s_mem_d[160]) );
  sky130_fd_sc_hd__inv_1 U1609 ( .A(s_mem_q[159]), .Y(n1153) );
  sky130_fd_sc_hd__o22ai_1 U1610 ( .A1(n127), .A2(n1153), .B1(n652), .B2(n1160), .Y(s_mem_d[159]) );
  sky130_fd_sc_hd__inv_1 U1611 ( .A(s_mem_q[158]), .Y(n1154) );
  sky130_fd_sc_hd__o22ai_1 U1612 ( .A1(n127), .A2(n1154), .B1(n582), .B2(n1160), .Y(s_mem_d[158]) );
  sky130_fd_sc_hd__inv_1 U1613 ( .A(s_mem_q[157]), .Y(n1155) );
  sky130_fd_sc_hd__o22ai_1 U1614 ( .A1(n127), .A2(n1155), .B1(n593), .B2(n1160), .Y(s_mem_d[157]) );
  sky130_fd_sc_hd__inv_1 U1615 ( .A(s_mem_q[156]), .Y(n1156) );
  sky130_fd_sc_hd__o22ai_1 U1616 ( .A1(n127), .A2(n1156), .B1(n604), .B2(n1160), .Y(s_mem_d[156]) );
  sky130_fd_sc_hd__inv_1 U1617 ( .A(s_mem_q[155]), .Y(n1157) );
  sky130_fd_sc_hd__o22ai_1 U1618 ( .A1(n127), .A2(n1157), .B1(n616), .B2(n1160), .Y(s_mem_d[155]) );
  sky130_fd_sc_hd__inv_1 U1619 ( .A(s_mem_q[154]), .Y(n1158) );
  sky130_fd_sc_hd__o22ai_1 U1620 ( .A1(n127), .A2(n1158), .B1(n627), .B2(n1160), .Y(s_mem_d[154]) );
  sky130_fd_sc_hd__inv_1 U1621 ( .A(s_mem_q[153]), .Y(n1159) );
  sky130_fd_sc_hd__o22ai_1 U1622 ( .A1(n127), .A2(n1159), .B1(n38), .B2(n1160), 
        .Y(s_mem_d[153]) );
  sky130_fd_sc_hd__inv_1 U1623 ( .A(s_mem_q[152]), .Y(n1161) );
  sky130_fd_sc_hd__o22ai_1 U1624 ( .A1(n127), .A2(n1161), .B1(n657), .B2(n1160), .Y(s_mem_d[152]) );
  sky130_fd_sc_hd__inv_1 U1625 ( .A(s_mem_q[151]), .Y(n1163) );
  sky130_fd_sc_hd__o22ai_1 U1626 ( .A1(n126), .A2(n1163), .B1(n652), .B2(n1170), .Y(s_mem_d[151]) );
  sky130_fd_sc_hd__inv_1 U1627 ( .A(s_mem_q[150]), .Y(n1164) );
  sky130_fd_sc_hd__o22ai_1 U1628 ( .A1(n126), .A2(n1164), .B1(n585), .B2(n1170), .Y(s_mem_d[150]) );
  sky130_fd_sc_hd__inv_1 U1629 ( .A(s_mem_q[149]), .Y(n1165) );
  sky130_fd_sc_hd__o22ai_1 U1630 ( .A1(n126), .A2(n1165), .B1(n596), .B2(n1170), .Y(s_mem_d[149]) );
  sky130_fd_sc_hd__inv_1 U1631 ( .A(s_mem_q[148]), .Y(n1166) );
  sky130_fd_sc_hd__o22ai_1 U1632 ( .A1(n126), .A2(n1166), .B1(n607), .B2(n1170), .Y(s_mem_d[148]) );
  sky130_fd_sc_hd__inv_1 U1633 ( .A(s_mem_q[147]), .Y(n1167) );
  sky130_fd_sc_hd__o22ai_1 U1634 ( .A1(n126), .A2(n1167), .B1(n619), .B2(n1170), .Y(s_mem_d[147]) );
  sky130_fd_sc_hd__inv_1 U1635 ( .A(s_mem_q[146]), .Y(n1168) );
  sky130_fd_sc_hd__o22ai_1 U1636 ( .A1(n126), .A2(n1168), .B1(n630), .B2(n1170), .Y(s_mem_d[146]) );
  sky130_fd_sc_hd__inv_1 U1637 ( .A(s_mem_q[145]), .Y(n1169) );
  sky130_fd_sc_hd__o22ai_1 U1638 ( .A1(n126), .A2(n1169), .B1(n51), .B2(n1170), 
        .Y(s_mem_d[145]) );
  sky130_fd_sc_hd__inv_1 U1639 ( .A(s_mem_q[144]), .Y(n1171) );
  sky130_fd_sc_hd__o22ai_1 U1640 ( .A1(n126), .A2(n1171), .B1(n657), .B2(n1170), .Y(s_mem_d[144]) );
  sky130_fd_sc_hd__inv_1 U1641 ( .A(s_mem_q[143]), .Y(n1173) );
  sky130_fd_sc_hd__o22ai_1 U1642 ( .A1(n125), .A2(n1173), .B1(n652), .B2(n1180), .Y(s_mem_d[143]) );
  sky130_fd_sc_hd__inv_1 U1643 ( .A(s_mem_q[142]), .Y(n1174) );
  sky130_fd_sc_hd__o22ai_1 U1644 ( .A1(n125), .A2(n1174), .B1(n584), .B2(n1180), .Y(s_mem_d[142]) );
  sky130_fd_sc_hd__inv_1 U1645 ( .A(s_mem_q[141]), .Y(n1175) );
  sky130_fd_sc_hd__o22ai_1 U1646 ( .A1(n125), .A2(n1175), .B1(n595), .B2(n1180), .Y(s_mem_d[141]) );
  sky130_fd_sc_hd__inv_1 U1647 ( .A(s_mem_q[140]), .Y(n1176) );
  sky130_fd_sc_hd__o22ai_1 U1648 ( .A1(n125), .A2(n1176), .B1(n606), .B2(n1180), .Y(s_mem_d[140]) );
  sky130_fd_sc_hd__inv_1 U1649 ( .A(s_mem_q[139]), .Y(n1177) );
  sky130_fd_sc_hd__o22ai_1 U1650 ( .A1(n125), .A2(n1177), .B1(n618), .B2(n1180), .Y(s_mem_d[139]) );
  sky130_fd_sc_hd__inv_1 U1651 ( .A(s_mem_q[138]), .Y(n1178) );
  sky130_fd_sc_hd__o22ai_1 U1652 ( .A1(n125), .A2(n1178), .B1(n629), .B2(n1180), .Y(s_mem_d[138]) );
  sky130_fd_sc_hd__inv_1 U1653 ( .A(s_mem_q[137]), .Y(n1179) );
  sky130_fd_sc_hd__o22ai_1 U1654 ( .A1(n125), .A2(n1179), .B1(n50), .B2(n1180), 
        .Y(s_mem_d[137]) );
  sky130_fd_sc_hd__inv_1 U1655 ( .A(s_mem_q[136]), .Y(n1181) );
  sky130_fd_sc_hd__o22ai_1 U1656 ( .A1(n125), .A2(n1181), .B1(n657), .B2(n1180), .Y(s_mem_d[136]) );
  sky130_fd_sc_hd__inv_1 U1657 ( .A(s_mem_q[135]), .Y(n1184) );
  sky130_fd_sc_hd__o22ai_1 U1658 ( .A1(n124), .A2(n1184), .B1(n652), .B2(n1191), .Y(s_mem_d[135]) );
  sky130_fd_sc_hd__inv_1 U1659 ( .A(s_mem_q[134]), .Y(n1185) );
  sky130_fd_sc_hd__o22ai_1 U1660 ( .A1(n124), .A2(n1185), .B1(n583), .B2(n1191), .Y(s_mem_d[134]) );
  sky130_fd_sc_hd__inv_1 U1661 ( .A(s_mem_q[133]), .Y(n1186) );
  sky130_fd_sc_hd__o22ai_1 U1662 ( .A1(n124), .A2(n1186), .B1(n594), .B2(n1191), .Y(s_mem_d[133]) );
  sky130_fd_sc_hd__inv_1 U1663 ( .A(s_mem_q[132]), .Y(n1187) );
  sky130_fd_sc_hd__o22ai_1 U1664 ( .A1(n124), .A2(n1187), .B1(n605), .B2(n1191), .Y(s_mem_d[132]) );
  sky130_fd_sc_hd__inv_1 U1665 ( .A(s_mem_q[131]), .Y(n1188) );
  sky130_fd_sc_hd__o22ai_1 U1666 ( .A1(n124), .A2(n1188), .B1(n617), .B2(n1191), .Y(s_mem_d[131]) );
  sky130_fd_sc_hd__inv_1 U1667 ( .A(s_mem_q[130]), .Y(n1189) );
  sky130_fd_sc_hd__o22ai_1 U1668 ( .A1(n124), .A2(n1189), .B1(n628), .B2(n1191), .Y(s_mem_d[130]) );
  sky130_fd_sc_hd__inv_1 U1669 ( .A(s_mem_q[129]), .Y(n1190) );
  sky130_fd_sc_hd__o22ai_1 U1670 ( .A1(n124), .A2(n1190), .B1(n49), .B2(n1191), 
        .Y(s_mem_d[129]) );
  sky130_fd_sc_hd__inv_1 U1671 ( .A(s_mem_q[128]), .Y(n1192) );
  sky130_fd_sc_hd__o22ai_1 U1672 ( .A1(n124), .A2(n1192), .B1(n657), .B2(n1191), .Y(s_mem_d[128]) );
  sky130_fd_sc_hd__nand3_1 U1673 ( .A(s_wr_ptr_q[3]), .B(n1378), .C(n1379), 
        .Y(n1193) );
  sky130_fd_sc_hd__inv_1 U1674 ( .A(s_mem_q[127]), .Y(n1195) );
  sky130_fd_sc_hd__o22ai_1 U1675 ( .A1(n123), .A2(n1195), .B1(n652), .B2(n1202), .Y(s_mem_d[127]) );
  sky130_fd_sc_hd__inv_1 U1676 ( .A(s_mem_q[126]), .Y(n1196) );
  sky130_fd_sc_hd__o22ai_1 U1677 ( .A1(n123), .A2(n1196), .B1(n583), .B2(n1202), .Y(s_mem_d[126]) );
  sky130_fd_sc_hd__inv_1 U1678 ( .A(s_mem_q[125]), .Y(n1197) );
  sky130_fd_sc_hd__o22ai_1 U1679 ( .A1(n123), .A2(n1197), .B1(n594), .B2(n1202), .Y(s_mem_d[125]) );
  sky130_fd_sc_hd__inv_1 U1680 ( .A(s_mem_q[124]), .Y(n1198) );
  sky130_fd_sc_hd__o22ai_1 U1681 ( .A1(n123), .A2(n1198), .B1(n605), .B2(n1202), .Y(s_mem_d[124]) );
  sky130_fd_sc_hd__inv_1 U1682 ( .A(s_mem_q[123]), .Y(n1199) );
  sky130_fd_sc_hd__o22ai_1 U1683 ( .A1(n123), .A2(n1199), .B1(n617), .B2(n1202), .Y(s_mem_d[123]) );
  sky130_fd_sc_hd__inv_1 U1684 ( .A(s_mem_q[122]), .Y(n1200) );
  sky130_fd_sc_hd__o22ai_1 U1685 ( .A1(n123), .A2(n1200), .B1(n628), .B2(n1202), .Y(s_mem_d[122]) );
  sky130_fd_sc_hd__inv_1 U1686 ( .A(s_mem_q[121]), .Y(n1201) );
  sky130_fd_sc_hd__o22ai_1 U1687 ( .A1(n123), .A2(n1201), .B1(n47), .B2(n1202), 
        .Y(s_mem_d[121]) );
  sky130_fd_sc_hd__inv_1 U1688 ( .A(s_mem_q[120]), .Y(n1203) );
  sky130_fd_sc_hd__o22ai_1 U1689 ( .A1(n123), .A2(n1203), .B1(n657), .B2(n1202), .Y(s_mem_d[120]) );
  sky130_fd_sc_hd__inv_1 U1690 ( .A(s_mem_q[119]), .Y(n1205) );
  sky130_fd_sc_hd__o22ai_1 U1691 ( .A1(n122), .A2(n1205), .B1(n652), .B2(n1212), .Y(s_mem_d[119]) );
  sky130_fd_sc_hd__inv_1 U1692 ( .A(s_mem_q[118]), .Y(n1206) );
  sky130_fd_sc_hd__o22ai_1 U1693 ( .A1(n122), .A2(n1206), .B1(n582), .B2(n1212), .Y(s_mem_d[118]) );
  sky130_fd_sc_hd__inv_1 U1694 ( .A(s_mem_q[117]), .Y(n1207) );
  sky130_fd_sc_hd__o22ai_1 U1695 ( .A1(n122), .A2(n1207), .B1(n593), .B2(n1212), .Y(s_mem_d[117]) );
  sky130_fd_sc_hd__inv_1 U1696 ( .A(s_mem_q[116]), .Y(n1208) );
  sky130_fd_sc_hd__o22ai_1 U1697 ( .A1(n122), .A2(n1208), .B1(n604), .B2(n1212), .Y(s_mem_d[116]) );
  sky130_fd_sc_hd__inv_1 U1698 ( .A(s_mem_q[115]), .Y(n1209) );
  sky130_fd_sc_hd__o22ai_1 U1699 ( .A1(n122), .A2(n1209), .B1(n616), .B2(n1212), .Y(s_mem_d[115]) );
  sky130_fd_sc_hd__inv_1 U1700 ( .A(s_mem_q[114]), .Y(n1210) );
  sky130_fd_sc_hd__o22ai_1 U1701 ( .A1(n122), .A2(n1210), .B1(n627), .B2(n1212), .Y(s_mem_d[114]) );
  sky130_fd_sc_hd__inv_1 U1702 ( .A(s_mem_q[113]), .Y(n1211) );
  sky130_fd_sc_hd__o22ai_1 U1703 ( .A1(n122), .A2(n1211), .B1(n48), .B2(n1212), 
        .Y(s_mem_d[113]) );
  sky130_fd_sc_hd__inv_1 U1704 ( .A(s_mem_q[112]), .Y(n1213) );
  sky130_fd_sc_hd__o22ai_1 U1705 ( .A1(n122), .A2(n1213), .B1(n657), .B2(n1212), .Y(s_mem_d[112]) );
  sky130_fd_sc_hd__inv_1 U1706 ( .A(s_mem_q[111]), .Y(n1215) );
  sky130_fd_sc_hd__o22ai_1 U1707 ( .A1(n105), .A2(n1215), .B1(n652), .B2(n1222), .Y(s_mem_d[111]) );
  sky130_fd_sc_hd__inv_1 U1708 ( .A(s_mem_q[110]), .Y(n1216) );
  sky130_fd_sc_hd__o22ai_1 U1709 ( .A1(n105), .A2(n1216), .B1(n583), .B2(n1222), .Y(s_mem_d[110]) );
  sky130_fd_sc_hd__inv_1 U1710 ( .A(s_mem_q[109]), .Y(n1217) );
  sky130_fd_sc_hd__o22ai_1 U1711 ( .A1(n105), .A2(n1217), .B1(n594), .B2(n1222), .Y(s_mem_d[109]) );
  sky130_fd_sc_hd__inv_1 U1712 ( .A(s_mem_q[108]), .Y(n1218) );
  sky130_fd_sc_hd__o22ai_1 U1713 ( .A1(n105), .A2(n1218), .B1(n605), .B2(n1222), .Y(s_mem_d[108]) );
  sky130_fd_sc_hd__inv_1 U1714 ( .A(s_mem_q[107]), .Y(n1219) );
  sky130_fd_sc_hd__o22ai_1 U1715 ( .A1(n105), .A2(n1219), .B1(n617), .B2(n1222), .Y(s_mem_d[107]) );
  sky130_fd_sc_hd__inv_1 U1716 ( .A(s_mem_q[106]), .Y(n1220) );
  sky130_fd_sc_hd__o22ai_1 U1717 ( .A1(n105), .A2(n1220), .B1(n628), .B2(n1222), .Y(s_mem_d[106]) );
  sky130_fd_sc_hd__inv_1 U1718 ( .A(s_mem_q[105]), .Y(n1221) );
  sky130_fd_sc_hd__o22ai_1 U1719 ( .A1(n105), .A2(n1221), .B1(n45), .B2(n1222), 
        .Y(s_mem_d[105]) );
  sky130_fd_sc_hd__inv_1 U1720 ( .A(s_mem_q[104]), .Y(n1223) );
  sky130_fd_sc_hd__o22ai_1 U1721 ( .A1(n105), .A2(n1223), .B1(n657), .B2(n1222), .Y(s_mem_d[104]) );
  sky130_fd_sc_hd__inv_1 U1722 ( .A(s_mem_q[103]), .Y(n1225) );
  sky130_fd_sc_hd__o22ai_1 U1723 ( .A1(n121), .A2(n1225), .B1(n652), .B2(n1232), .Y(s_mem_d[103]) );
  sky130_fd_sc_hd__inv_1 U1724 ( .A(s_mem_q[102]), .Y(n1226) );
  sky130_fd_sc_hd__o22ai_1 U1725 ( .A1(n121), .A2(n1226), .B1(n584), .B2(n1232), .Y(s_mem_d[102]) );
  sky130_fd_sc_hd__inv_1 U1726 ( .A(s_mem_q[101]), .Y(n1227) );
  sky130_fd_sc_hd__o22ai_1 U1727 ( .A1(n121), .A2(n1227), .B1(n595), .B2(n1232), .Y(s_mem_d[101]) );
  sky130_fd_sc_hd__inv_1 U1728 ( .A(s_mem_q[100]), .Y(n1228) );
  sky130_fd_sc_hd__o22ai_1 U1729 ( .A1(n121), .A2(n1228), .B1(n606), .B2(n1232), .Y(s_mem_d[100]) );
  sky130_fd_sc_hd__inv_1 U1730 ( .A(s_mem_q[99]), .Y(n1229) );
  sky130_fd_sc_hd__o22ai_1 U1731 ( .A1(n121), .A2(n1229), .B1(n618), .B2(n1232), .Y(s_mem_d[99]) );
  sky130_fd_sc_hd__inv_1 U1732 ( .A(s_mem_q[98]), .Y(n1230) );
  sky130_fd_sc_hd__o22ai_1 U1733 ( .A1(n121), .A2(n1230), .B1(n629), .B2(n1232), .Y(s_mem_d[98]) );
  sky130_fd_sc_hd__inv_1 U1734 ( .A(s_mem_q[97]), .Y(n1231) );
  sky130_fd_sc_hd__o22ai_1 U1735 ( .A1(n121), .A2(n1231), .B1(n46), .B2(n1232), 
        .Y(s_mem_d[97]) );
  sky130_fd_sc_hd__inv_1 U1736 ( .A(s_mem_q[96]), .Y(n1233) );
  sky130_fd_sc_hd__o22ai_1 U1737 ( .A1(n121), .A2(n1233), .B1(n657), .B2(n1232), .Y(s_mem_d[96]) );
  sky130_fd_sc_hd__inv_1 U1738 ( .A(s_mem_q[95]), .Y(n1235) );
  sky130_fd_sc_hd__o22ai_1 U1739 ( .A1(n120), .A2(n1235), .B1(n653), .B2(n1238), .Y(s_mem_d[95]) );
  sky130_fd_sc_hd__inv_1 U1740 ( .A(s_mem_q[94]), .Y(n1236) );
  sky130_fd_sc_hd__o22ai_1 U1741 ( .A1(n120), .A2(n1236), .B1(n580), .B2(n1238), .Y(s_mem_d[94]) );
  sky130_fd_sc_hd__inv_1 U1742 ( .A(s_mem_q[93]), .Y(n1237) );
  sky130_fd_sc_hd__o22ai_1 U1743 ( .A1(n120), .A2(n1237), .B1(n591), .B2(n1238), .Y(s_mem_d[93]) );
  sky130_fd_sc_hd__o22ai_1 U1744 ( .A1(n120), .A2(n5), .B1(n602), .B2(n1238), 
        .Y(s_mem_d[92]) );
  sky130_fd_sc_hd__o22ai_1 U1745 ( .A1(n120), .A2(n11), .B1(n614), .B2(n1238), 
        .Y(s_mem_d[91]) );
  sky130_fd_sc_hd__o22ai_1 U1746 ( .A1(n120), .A2(n8), .B1(n625), .B2(n1238), 
        .Y(s_mem_d[90]) );
  sky130_fd_sc_hd__o22ai_1 U1747 ( .A1(n120), .A2(n13), .B1(n40), .B2(n1238), 
        .Y(s_mem_d[89]) );
  sky130_fd_sc_hd__inv_1 U1748 ( .A(s_mem_q[88]), .Y(n1239) );
  sky130_fd_sc_hd__o22ai_1 U1749 ( .A1(n120), .A2(n1239), .B1(n99), .B2(n1238), 
        .Y(s_mem_d[88]) );
  sky130_fd_sc_hd__inv_1 U1750 ( .A(s_mem_q[87]), .Y(n1241) );
  sky130_fd_sc_hd__o22ai_1 U1751 ( .A1(n119), .A2(n1241), .B1(n653), .B2(n1248), .Y(s_mem_d[87]) );
  sky130_fd_sc_hd__inv_1 U1752 ( .A(s_mem_q[86]), .Y(n1242) );
  sky130_fd_sc_hd__o22ai_1 U1753 ( .A1(n119), .A2(n1242), .B1(n585), .B2(n1248), .Y(s_mem_d[86]) );
  sky130_fd_sc_hd__inv_1 U1754 ( .A(s_mem_q[85]), .Y(n1243) );
  sky130_fd_sc_hd__o22ai_1 U1755 ( .A1(n119), .A2(n1243), .B1(n596), .B2(n1248), .Y(s_mem_d[85]) );
  sky130_fd_sc_hd__inv_1 U1756 ( .A(s_mem_q[84]), .Y(n1244) );
  sky130_fd_sc_hd__o22ai_1 U1757 ( .A1(n119), .A2(n1244), .B1(n607), .B2(n1248), .Y(s_mem_d[84]) );
  sky130_fd_sc_hd__inv_1 U1758 ( .A(s_mem_q[83]), .Y(n1245) );
  sky130_fd_sc_hd__o22ai_1 U1759 ( .A1(n119), .A2(n1245), .B1(n619), .B2(n1248), .Y(s_mem_d[83]) );
  sky130_fd_sc_hd__inv_1 U1760 ( .A(s_mem_q[82]), .Y(n1246) );
  sky130_fd_sc_hd__o22ai_1 U1761 ( .A1(n119), .A2(n1246), .B1(n630), .B2(n1248), .Y(s_mem_d[82]) );
  sky130_fd_sc_hd__inv_1 U1762 ( .A(s_mem_q[81]), .Y(n1247) );
  sky130_fd_sc_hd__o22ai_1 U1763 ( .A1(n119), .A2(n1247), .B1(n44), .B2(n1248), 
        .Y(s_mem_d[81]) );
  sky130_fd_sc_hd__inv_1 U1764 ( .A(s_mem_q[80]), .Y(n1249) );
  sky130_fd_sc_hd__o22ai_1 U1765 ( .A1(n119), .A2(n1249), .B1(n657), .B2(n1248), .Y(s_mem_d[80]) );
  sky130_fd_sc_hd__inv_1 U1766 ( .A(s_mem_q[79]), .Y(n1251) );
  sky130_fd_sc_hd__o22ai_1 U1767 ( .A1(n118), .A2(n1251), .B1(n653), .B2(n1258), .Y(s_mem_d[79]) );
  sky130_fd_sc_hd__inv_1 U1768 ( .A(s_mem_q[78]), .Y(n1252) );
  sky130_fd_sc_hd__o22ai_1 U1769 ( .A1(n118), .A2(n1252), .B1(n582), .B2(n1258), .Y(s_mem_d[78]) );
  sky130_fd_sc_hd__inv_1 U1770 ( .A(s_mem_q[77]), .Y(n1253) );
  sky130_fd_sc_hd__o22ai_1 U1771 ( .A1(n118), .A2(n1253), .B1(n593), .B2(n1258), .Y(s_mem_d[77]) );
  sky130_fd_sc_hd__inv_1 U1772 ( .A(s_mem_q[76]), .Y(n1254) );
  sky130_fd_sc_hd__o22ai_1 U1773 ( .A1(n118), .A2(n1254), .B1(n604), .B2(n1258), .Y(s_mem_d[76]) );
  sky130_fd_sc_hd__inv_1 U1774 ( .A(s_mem_q[75]), .Y(n1255) );
  sky130_fd_sc_hd__o22ai_1 U1775 ( .A1(n118), .A2(n1255), .B1(n616), .B2(n1258), .Y(s_mem_d[75]) );
  sky130_fd_sc_hd__inv_1 U1776 ( .A(s_mem_q[74]), .Y(n1256) );
  sky130_fd_sc_hd__o22ai_1 U1777 ( .A1(n118), .A2(n1256), .B1(n627), .B2(n1258), .Y(s_mem_d[74]) );
  sky130_fd_sc_hd__inv_1 U1778 ( .A(s_mem_q[73]), .Y(n1257) );
  sky130_fd_sc_hd__o22ai_1 U1779 ( .A1(n118), .A2(n1257), .B1(n44), .B2(n1258), 
        .Y(s_mem_d[73]) );
  sky130_fd_sc_hd__inv_1 U1780 ( .A(s_mem_q[72]), .Y(n1259) );
  sky130_fd_sc_hd__o22ai_1 U1781 ( .A1(n118), .A2(n1259), .B1(n99), .B2(n1258), 
        .Y(s_mem_d[72]) );
  sky130_fd_sc_hd__inv_1 U1782 ( .A(s_mem_q[71]), .Y(n1262) );
  sky130_fd_sc_hd__o22ai_1 U1783 ( .A1(n117), .A2(n1262), .B1(n653), .B2(n1269), .Y(s_mem_d[71]) );
  sky130_fd_sc_hd__inv_1 U1784 ( .A(s_mem_q[70]), .Y(n1263) );
  sky130_fd_sc_hd__o22ai_1 U1785 ( .A1(n117), .A2(n1263), .B1(n579), .B2(n1269), .Y(s_mem_d[70]) );
  sky130_fd_sc_hd__inv_1 U1786 ( .A(s_mem_q[69]), .Y(n1264) );
  sky130_fd_sc_hd__o22ai_1 U1787 ( .A1(n117), .A2(n1264), .B1(n590), .B2(n1269), .Y(s_mem_d[69]) );
  sky130_fd_sc_hd__inv_1 U1788 ( .A(s_mem_q[68]), .Y(n1265) );
  sky130_fd_sc_hd__o22ai_1 U1789 ( .A1(n117), .A2(n1265), .B1(n601), .B2(n1269), .Y(s_mem_d[68]) );
  sky130_fd_sc_hd__inv_1 U1790 ( .A(s_mem_q[67]), .Y(n1266) );
  sky130_fd_sc_hd__o22ai_1 U1791 ( .A1(n117), .A2(n1266), .B1(n613), .B2(n1269), .Y(s_mem_d[67]) );
  sky130_fd_sc_hd__inv_1 U1792 ( .A(s_mem_q[66]), .Y(n1267) );
  sky130_fd_sc_hd__o22ai_1 U1793 ( .A1(n117), .A2(n1267), .B1(n624), .B2(n1269), .Y(s_mem_d[66]) );
  sky130_fd_sc_hd__inv_1 U1794 ( .A(s_mem_q[65]), .Y(n1268) );
  sky130_fd_sc_hd__o22ai_1 U1795 ( .A1(n117), .A2(n1268), .B1(n45), .B2(n1269), 
        .Y(s_mem_d[65]) );
  sky130_fd_sc_hd__inv_1 U1796 ( .A(s_mem_q[64]), .Y(n1270) );
  sky130_fd_sc_hd__o22ai_1 U1797 ( .A1(n117), .A2(n1270), .B1(n99), .B2(n1269), 
        .Y(s_mem_d[64]) );
  sky130_fd_sc_hd__nand3_1 U1798 ( .A(n1379), .B(n1378), .C(n1380), .Y(n1271)
         );
  sky130_fd_sc_hd__inv_1 U1799 ( .A(s_mem_q[63]), .Y(n1274) );
  sky130_fd_sc_hd__o22ai_1 U1800 ( .A1(n155), .A2(n1274), .B1(n653), .B2(n1281), .Y(s_mem_d[63]) );
  sky130_fd_sc_hd__inv_1 U1801 ( .A(s_mem_q[62]), .Y(n1275) );
  sky130_fd_sc_hd__o22ai_1 U1802 ( .A1(n155), .A2(n1275), .B1(n578), .B2(n1281), .Y(s_mem_d[62]) );
  sky130_fd_sc_hd__inv_1 U1803 ( .A(s_mem_q[61]), .Y(n1276) );
  sky130_fd_sc_hd__o22ai_1 U1804 ( .A1(n155), .A2(n1276), .B1(n589), .B2(n1281), .Y(s_mem_d[61]) );
  sky130_fd_sc_hd__inv_1 U1805 ( .A(s_mem_q[60]), .Y(n1277) );
  sky130_fd_sc_hd__o22ai_1 U1806 ( .A1(n155), .A2(n1277), .B1(n600), .B2(n1281), .Y(s_mem_d[60]) );
  sky130_fd_sc_hd__inv_1 U1807 ( .A(s_mem_q[59]), .Y(n1278) );
  sky130_fd_sc_hd__o22ai_1 U1808 ( .A1(n155), .A2(n1278), .B1(n611), .B2(n1281), .Y(s_mem_d[59]) );
  sky130_fd_sc_hd__inv_1 U1809 ( .A(s_mem_q[58]), .Y(n1279) );
  sky130_fd_sc_hd__o22ai_1 U1810 ( .A1(n155), .A2(n1279), .B1(n623), .B2(n1281), .Y(s_mem_d[58]) );
  sky130_fd_sc_hd__inv_1 U1811 ( .A(s_mem_q[57]), .Y(n1280) );
  sky130_fd_sc_hd__o22ai_1 U1812 ( .A1(n155), .A2(n1280), .B1(n42), .B2(n1281), 
        .Y(s_mem_d[57]) );
  sky130_fd_sc_hd__inv_1 U1813 ( .A(s_mem_q[56]), .Y(n1282) );
  sky130_fd_sc_hd__o22ai_1 U1814 ( .A1(n155), .A2(n1282), .B1(n99), .B2(n1281), 
        .Y(s_mem_d[56]) );
  sky130_fd_sc_hd__nand2_1 U1815 ( .A(n1284), .B(n67), .Y(n1285) );
  sky130_fd_sc_hd__inv_1 U1816 ( .A(s_mem_q[55]), .Y(n1286) );
  sky130_fd_sc_hd__o22ai_1 U1817 ( .A1(n1295), .A2(n1286), .B1(n653), .B2(
        n1293), .Y(s_mem_d[55]) );
  sky130_fd_sc_hd__inv_1 U1818 ( .A(s_mem_q[54]), .Y(n1287) );
  sky130_fd_sc_hd__o22ai_1 U1819 ( .A1(n1295), .A2(n1287), .B1(n579), .B2(
        n1293), .Y(s_mem_d[54]) );
  sky130_fd_sc_hd__inv_1 U1820 ( .A(s_mem_q[53]), .Y(n1288) );
  sky130_fd_sc_hd__o22ai_1 U1821 ( .A1(n1295), .A2(n1288), .B1(n596), .B2(
        n1293), .Y(s_mem_d[53]) );
  sky130_fd_sc_hd__inv_1 U1822 ( .A(s_mem_q[52]), .Y(n1289) );
  sky130_fd_sc_hd__o22ai_1 U1823 ( .A1(n1295), .A2(n1289), .B1(n601), .B2(
        n1293), .Y(s_mem_d[52]) );
  sky130_fd_sc_hd__inv_1 U1824 ( .A(s_mem_q[51]), .Y(n1290) );
  sky130_fd_sc_hd__o22ai_1 U1825 ( .A1(n1295), .A2(n1290), .B1(n612), .B2(
        n1293), .Y(s_mem_d[51]) );
  sky130_fd_sc_hd__inv_1 U1826 ( .A(s_mem_q[50]), .Y(n1291) );
  sky130_fd_sc_hd__o22ai_1 U1827 ( .A1(n1295), .A2(n1291), .B1(n624), .B2(
        n1293), .Y(s_mem_d[50]) );
  sky130_fd_sc_hd__inv_1 U1828 ( .A(s_mem_q[49]), .Y(n1292) );
  sky130_fd_sc_hd__o22ai_1 U1829 ( .A1(n1295), .A2(n1292), .B1(n50), .B2(n1293), .Y(s_mem_d[49]) );
  sky130_fd_sc_hd__inv_1 U1830 ( .A(s_mem_q[48]), .Y(n1294) );
  sky130_fd_sc_hd__o22ai_1 U1831 ( .A1(n1295), .A2(n1294), .B1(n99), .B2(n1293), .Y(s_mem_d[48]) );
  sky130_fd_sc_hd__nand2_1 U1832 ( .A(n1297), .B(n67), .Y(n1298) );
  sky130_fd_sc_hd__inv_1 U1833 ( .A(s_mem_q[47]), .Y(n1299) );
  sky130_fd_sc_hd__o22ai_1 U1834 ( .A1(n1308), .A2(n1299), .B1(n653), .B2(
        n1306), .Y(s_mem_d[47]) );
  sky130_fd_sc_hd__inv_1 U1835 ( .A(s_mem_q[46]), .Y(n1300) );
  sky130_fd_sc_hd__o22ai_1 U1836 ( .A1(n1308), .A2(n1300), .B1(n585), .B2(
        n1306), .Y(s_mem_d[46]) );
  sky130_fd_sc_hd__inv_1 U1837 ( .A(s_mem_q[45]), .Y(n1301) );
  sky130_fd_sc_hd__o22ai_1 U1838 ( .A1(n1308), .A2(n1301), .B1(n596), .B2(
        n1306), .Y(s_mem_d[45]) );
  sky130_fd_sc_hd__inv_1 U1839 ( .A(s_mem_q[44]), .Y(n1302) );
  sky130_fd_sc_hd__o22ai_1 U1840 ( .A1(n1308), .A2(n1302), .B1(n607), .B2(
        n1306), .Y(s_mem_d[44]) );
  sky130_fd_sc_hd__inv_1 U1841 ( .A(s_mem_q[43]), .Y(n1303) );
  sky130_fd_sc_hd__o22ai_1 U1842 ( .A1(n1308), .A2(n1303), .B1(n619), .B2(
        n1306), .Y(s_mem_d[43]) );
  sky130_fd_sc_hd__inv_1 U1843 ( .A(s_mem_q[42]), .Y(n1304) );
  sky130_fd_sc_hd__o22ai_1 U1844 ( .A1(n1308), .A2(n1304), .B1(n630), .B2(
        n1306), .Y(s_mem_d[42]) );
  sky130_fd_sc_hd__inv_1 U1845 ( .A(s_mem_q[41]), .Y(n1305) );
  sky130_fd_sc_hd__o22ai_1 U1846 ( .A1(n1308), .A2(n1305), .B1(n48), .B2(n1306), .Y(s_mem_d[41]) );
  sky130_fd_sc_hd__inv_1 U1847 ( .A(s_mem_q[40]), .Y(n1307) );
  sky130_fd_sc_hd__o22ai_1 U1848 ( .A1(n1308), .A2(n1307), .B1(n99), .B2(n1306), .Y(s_mem_d[40]) );
  sky130_fd_sc_hd__nand2_1 U1849 ( .A(n1310), .B(n67), .Y(n1311) );
  sky130_fd_sc_hd__inv_1 U1850 ( .A(s_mem_q[39]), .Y(n1312) );
  sky130_fd_sc_hd__o22ai_1 U1851 ( .A1(n1321), .A2(n1312), .B1(n653), .B2(
        n1319), .Y(s_mem_d[39]) );
  sky130_fd_sc_hd__inv_1 U1852 ( .A(s_mem_q[38]), .Y(n1313) );
  sky130_fd_sc_hd__o22ai_1 U1853 ( .A1(n1321), .A2(n1313), .B1(n577), .B2(
        n1319), .Y(s_mem_d[38]) );
  sky130_fd_sc_hd__inv_1 U1854 ( .A(s_mem_q[37]), .Y(n1314) );
  sky130_fd_sc_hd__o22ai_1 U1855 ( .A1(n1321), .A2(n1314), .B1(n588), .B2(
        n1319), .Y(s_mem_d[37]) );
  sky130_fd_sc_hd__inv_1 U1856 ( .A(s_mem_q[36]), .Y(n1315) );
  sky130_fd_sc_hd__o22ai_1 U1857 ( .A1(n1321), .A2(n1315), .B1(n599), .B2(
        n1319), .Y(s_mem_d[36]) );
  sky130_fd_sc_hd__inv_1 U1858 ( .A(s_mem_q[35]), .Y(n1316) );
  sky130_fd_sc_hd__o22ai_1 U1859 ( .A1(n1321), .A2(n1316), .B1(n610), .B2(
        n1319), .Y(s_mem_d[35]) );
  sky130_fd_sc_hd__inv_1 U1860 ( .A(s_mem_q[34]), .Y(n1317) );
  sky130_fd_sc_hd__o22ai_1 U1861 ( .A1(n1321), .A2(n1317), .B1(n622), .B2(
        n1319), .Y(s_mem_d[34]) );
  sky130_fd_sc_hd__inv_1 U1862 ( .A(s_mem_q[33]), .Y(n1318) );
  sky130_fd_sc_hd__o22ai_1 U1863 ( .A1(n1321), .A2(n1318), .B1(n49), .B2(n1319), .Y(s_mem_d[33]) );
  sky130_fd_sc_hd__inv_1 U1864 ( .A(s_mem_q[32]), .Y(n1320) );
  sky130_fd_sc_hd__o22ai_1 U1865 ( .A1(n1321), .A2(n1320), .B1(n99), .B2(n1319), .Y(s_mem_d[32]) );
  sky130_fd_sc_hd__inv_1 U1866 ( .A(s_mem_q[31]), .Y(n1324) );
  sky130_fd_sc_hd__o22ai_1 U1867 ( .A1(n103), .A2(n1324), .B1(n653), .B2(n1331), .Y(s_mem_d[31]) );
  sky130_fd_sc_hd__inv_1 U1868 ( .A(s_mem_q[30]), .Y(n1325) );
  sky130_fd_sc_hd__o22ai_1 U1869 ( .A1(n103), .A2(n1325), .B1(n583), .B2(n1331), .Y(s_mem_d[30]) );
  sky130_fd_sc_hd__inv_1 U1870 ( .A(s_mem_q[29]), .Y(n1326) );
  sky130_fd_sc_hd__o22ai_1 U1871 ( .A1(n103), .A2(n1326), .B1(n594), .B2(n1331), .Y(s_mem_d[29]) );
  sky130_fd_sc_hd__inv_1 U1872 ( .A(s_mem_q[28]), .Y(n1327) );
  sky130_fd_sc_hd__o22ai_1 U1873 ( .A1(n103), .A2(n1327), .B1(n605), .B2(n1331), .Y(s_mem_d[28]) );
  sky130_fd_sc_hd__inv_1 U1874 ( .A(s_mem_q[27]), .Y(n1328) );
  sky130_fd_sc_hd__o22ai_1 U1875 ( .A1(n103), .A2(n1328), .B1(n617), .B2(n1331), .Y(s_mem_d[27]) );
  sky130_fd_sc_hd__inv_1 U1876 ( .A(s_mem_q[26]), .Y(n1329) );
  sky130_fd_sc_hd__o22ai_1 U1877 ( .A1(n103), .A2(n1329), .B1(n628), .B2(n1331), .Y(s_mem_d[26]) );
  sky130_fd_sc_hd__inv_1 U1878 ( .A(s_mem_q[25]), .Y(n1330) );
  sky130_fd_sc_hd__o22ai_1 U1879 ( .A1(n103), .A2(n1330), .B1(n41), .B2(n1331), 
        .Y(s_mem_d[25]) );
  sky130_fd_sc_hd__inv_1 U1880 ( .A(s_mem_q[24]), .Y(n1332) );
  sky130_fd_sc_hd__o22ai_1 U1881 ( .A1(n103), .A2(n1332), .B1(n99), .B2(n1331), 
        .Y(s_mem_d[24]) );
  sky130_fd_sc_hd__nand2_1 U1882 ( .A(n1334), .B(n67), .Y(n1335) );
  sky130_fd_sc_hd__inv_1 U1883 ( .A(s_mem_q[23]), .Y(n1336) );
  sky130_fd_sc_hd__o22ai_1 U1884 ( .A1(n1345), .A2(n1336), .B1(n653), .B2(
        n1343), .Y(s_mem_d[23]) );
  sky130_fd_sc_hd__inv_1 U1885 ( .A(s_mem_q[22]), .Y(n1337) );
  sky130_fd_sc_hd__o22ai_1 U1886 ( .A1(n1345), .A2(n1337), .B1(n584), .B2(
        n1343), .Y(s_mem_d[22]) );
  sky130_fd_sc_hd__inv_1 U1887 ( .A(s_mem_q[21]), .Y(n1338) );
  sky130_fd_sc_hd__o22ai_1 U1888 ( .A1(n1345), .A2(n1338), .B1(n595), .B2(
        n1343), .Y(s_mem_d[21]) );
  sky130_fd_sc_hd__inv_1 U1889 ( .A(s_mem_q[20]), .Y(n1339) );
  sky130_fd_sc_hd__o22ai_1 U1890 ( .A1(n1345), .A2(n1339), .B1(n606), .B2(
        n1343), .Y(s_mem_d[20]) );
  sky130_fd_sc_hd__inv_1 U1891 ( .A(s_mem_q[19]), .Y(n1340) );
  sky130_fd_sc_hd__o22ai_1 U1892 ( .A1(n1345), .A2(n1340), .B1(n618), .B2(
        n1343), .Y(s_mem_d[19]) );
  sky130_fd_sc_hd__inv_1 U1893 ( .A(s_mem_q[18]), .Y(n1341) );
  sky130_fd_sc_hd__o22ai_1 U1894 ( .A1(n1345), .A2(n1341), .B1(n629), .B2(
        n1343), .Y(s_mem_d[18]) );
  sky130_fd_sc_hd__inv_1 U1895 ( .A(s_mem_q[17]), .Y(n1342) );
  sky130_fd_sc_hd__o22ai_1 U1896 ( .A1(n1345), .A2(n1342), .B1(n47), .B2(n1343), .Y(s_mem_d[17]) );
  sky130_fd_sc_hd__inv_1 U1897 ( .A(s_mem_q[16]), .Y(n1344) );
  sky130_fd_sc_hd__o22ai_1 U1898 ( .A1(n1345), .A2(n1344), .B1(n99), .B2(n1343), .Y(s_mem_d[16]) );
  sky130_fd_sc_hd__nand2_1 U1899 ( .A(n1347), .B(n67), .Y(n1348) );
  sky130_fd_sc_hd__inv_1 U1900 ( .A(s_mem_q[15]), .Y(n1349) );
  sky130_fd_sc_hd__o22ai_1 U1901 ( .A1(n1358), .A2(n1349), .B1(n653), .B2(
        n1356), .Y(s_mem_d[15]) );
  sky130_fd_sc_hd__inv_1 U1902 ( .A(s_mem_q[14]), .Y(n1350) );
  sky130_fd_sc_hd__o22ai_1 U1903 ( .A1(n1358), .A2(n1350), .B1(n581), .B2(
        n1356), .Y(s_mem_d[14]) );
  sky130_fd_sc_hd__inv_1 U1904 ( .A(s_mem_q[13]), .Y(n1351) );
  sky130_fd_sc_hd__o22ai_1 U1905 ( .A1(n1358), .A2(n1351), .B1(n592), .B2(
        n1356), .Y(s_mem_d[13]) );
  sky130_fd_sc_hd__inv_1 U1906 ( .A(s_mem_q[12]), .Y(n1352) );
  sky130_fd_sc_hd__o22ai_1 U1907 ( .A1(n1358), .A2(n1352), .B1(n603), .B2(
        n1356), .Y(s_mem_d[12]) );
  sky130_fd_sc_hd__inv_1 U1908 ( .A(s_mem_q[11]), .Y(n1353) );
  sky130_fd_sc_hd__o22ai_1 U1909 ( .A1(n1358), .A2(n1353), .B1(n615), .B2(
        n1356), .Y(s_mem_d[11]) );
  sky130_fd_sc_hd__inv_1 U1910 ( .A(s_mem_q[10]), .Y(n1354) );
  sky130_fd_sc_hd__o22ai_1 U1911 ( .A1(n1358), .A2(n1354), .B1(n626), .B2(
        n1356), .Y(s_mem_d[10]) );
  sky130_fd_sc_hd__inv_1 U1912 ( .A(s_mem_q[9]), .Y(n1355) );
  sky130_fd_sc_hd__o22ai_1 U1913 ( .A1(n1358), .A2(n1355), .B1(n46), .B2(n1356), .Y(s_mem_d[9]) );
  sky130_fd_sc_hd__inv_1 U1914 ( .A(s_mem_q[8]), .Y(n1357) );
  sky130_fd_sc_hd__o22ai_1 U1915 ( .A1(n1358), .A2(n1357), .B1(n99), .B2(n1356), .Y(s_mem_d[8]) );
  sky130_fd_sc_hd__inv_1 U1916 ( .A(s_mem_q[7]), .Y(n1361) );
  sky130_fd_sc_hd__o22ai_1 U1917 ( .A1(n104), .A2(n1361), .B1(n1374), .B2(n653), .Y(s_mem_d[7]) );
  sky130_fd_sc_hd__inv_1 U1918 ( .A(s_mem_q[6]), .Y(n1363) );
  sky130_fd_sc_hd__o22ai_1 U1919 ( .A1(n104), .A2(n1363), .B1(n1374), .B2(n585), .Y(s_mem_d[6]) );
  sky130_fd_sc_hd__inv_1 U1920 ( .A(s_mem_q[5]), .Y(n1365) );
  sky130_fd_sc_hd__o22ai_1 U1921 ( .A1(n104), .A2(n1365), .B1(n1374), .B2(n590), .Y(s_mem_d[5]) );
  sky130_fd_sc_hd__inv_1 U1922 ( .A(s_mem_q[4]), .Y(n1367) );
  sky130_fd_sc_hd__o22ai_1 U1923 ( .A1(n104), .A2(n1367), .B1(n1374), .B2(n607), .Y(s_mem_d[4]) );
  sky130_fd_sc_hd__inv_1 U1924 ( .A(s_mem_q[3]), .Y(n1369) );
  sky130_fd_sc_hd__o22ai_1 U1925 ( .A1(n104), .A2(n1369), .B1(n1374), .B2(n613), .Y(s_mem_d[3]) );
  sky130_fd_sc_hd__inv_1 U1926 ( .A(s_mem_q[2]), .Y(n1371) );
  sky130_fd_sc_hd__o22ai_1 U1927 ( .A1(n104), .A2(n1371), .B1(n1374), .B2(n630), .Y(s_mem_d[2]) );
  sky130_fd_sc_hd__inv_1 U1928 ( .A(s_mem_q[1]), .Y(n1373) );
  sky130_fd_sc_hd__o22ai_1 U1929 ( .A1(n104), .A2(n1373), .B1(n1374), .B2(n51), 
        .Y(s_mem_d[1]) );
  sky130_fd_sc_hd__inv_1 U1930 ( .A(s_mem_q[0]), .Y(n1375) );
  sky130_fd_sc_hd__o22ai_1 U1931 ( .A1(n104), .A2(n1375), .B1(n1374), .B2(n99), 
        .Y(s_mem_d[0]) );
  sky130_fd_sc_hd__nand2_1 U1932 ( .A(n63), .B(n1376), .Y(n1384) );
  sky130_fd_sc_hd__o2bb2ai_1 U1933 ( .B1(n1384), .B2(n1378), .A1_N(N100), 
        .A2_N(n635), .Y(s_wr_ptr_d[5]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1934 ( .B1(n1384), .B2(n1379), .A1_N(N99), 
        .A2_N(n635), .Y(s_wr_ptr_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1935 ( .B1(n1384), .B2(n1380), .A1_N(N98), 
        .A2_N(n635), .Y(s_wr_ptr_d[3]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1936 ( .B1(n1384), .B2(n1381), .A1_N(N97), 
        .A2_N(n635), .Y(s_wr_ptr_d[2]) );
  sky130_fd_sc_hd__o2bb2ai_1 U1937 ( .B1(n1384), .B2(n1383), .A1_N(N96), 
        .A2_N(n635), .Y(s_wr_ptr_d[1]) );
  sky130_fd_sc_hd__mux2i_1 U1938 ( .A0(n1385), .A1(n1384), .S(s_wr_ptr_q[0]), 
        .Y(s_wr_ptr_d[0]) );
  sky130_fd_sc_hd__xor2_1 U1939 ( .A(\add_50/carry[5] ), .B(N80), .X(N89) );
  sky130_fd_sc_hd__xor2_1 U1940 ( .A(\add_65/carry[5] ), .B(s_wr_ptr_q[5]), 
        .X(N100) );
endmodule


module uart_tx_DW01_inc_1 ( A, SUM );
  input [15:0] A;
  output [15:0] SUM;
  wire   n1, n2, n4, n5, n6, n7, n8, n9, n10, n11, n13, n14, n15, n17, n18,
         n20, n21, n22, n24, n25, n27, n28, n29, n30, n31, n33, n34, n36, n37,
         n38, n40, n42, n43, n44, n45, n46, n47, n49, n50, n52, n53, n54, n56;
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

  sky130_fd_sc_hd__nand2_1 U4 ( .A(n4), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n8), .B(n7), .X(SUM[13]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n28), .B(n5), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n13), .B(n6), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n7), .B(n10), .Y(n6) );
  sky130_fd_sc_hd__xnor2_1 U12 ( .A(n10), .B(n11), .Y(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n11), .B(n9), .Y(n8) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n14), .B(n21), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n18), .B(n15), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n20), .B(n18), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n21), .B(n28), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n25), .B(n22), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n27), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n29), .B(n45), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(n30), .B(n37), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n34), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n36), .B(n34), .Y(n33) );
  sky130_fd_sc_hd__nor2_1 U48 ( .A(n37), .B(n44), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n42), .B(n38), .Y(n37) );
  sky130_fd_sc_hd__xor2_1 U52 ( .A(n44), .B(n43), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U53 ( .A(n43), .B(n44), .Y(n40) );
  sky130_fd_sc_hd__nor2_1 U59 ( .A(n53), .B(n46), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U60 ( .A(n50), .B(n47), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n52), .B(n50), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n54), .B(n56), .Y(n53) );
  sky130_fd_sc_hd__inv_1 U76 ( .A(n56), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U77 ( .A(A[13]), .Y(n7) );
  sky130_fd_sc_hd__nor2b_1 U78 ( .B_N(n13), .A(n28), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U79 ( .A(n45), .Y(n44) );
  sky130_fd_sc_hd__inv_2 U80 ( .A(n28), .Y(n27) );
  sky130_fd_sc_hd__inv_2 U81 ( .A(n53), .Y(n52) );
  sky130_fd_sc_hd__xor2_1 U82 ( .A(n2), .B(n4), .X(SUM[14]) );
  sky130_fd_sc_hd__xor2_1 U83 ( .A(n18), .B(n20), .X(SUM[10]) );
  sky130_fd_sc_hd__xor2_1 U84 ( .A(n25), .B(n27), .X(SUM[8]) );
  sky130_fd_sc_hd__xor2_1 U85 ( .A(n34), .B(n36), .X(SUM[6]) );
  sky130_fd_sc_hd__xor2_1 U86 ( .A(n38), .B(n40), .X(SUM[5]) );
  sky130_fd_sc_hd__xor2_1 U87 ( .A(n50), .B(n52), .X(SUM[2]) );
  sky130_fd_sc_hd__xor2_1 U88 ( .A(n56), .B(n54), .X(SUM[1]) );
  sky130_fd_sc_hd__xnor2_1 U89 ( .A(A[15]), .B(n1), .Y(SUM[15]) );
  sky130_fd_sc_hd__xnor2_1 U90 ( .A(n17), .B(n15), .Y(SUM[11]) );
  sky130_fd_sc_hd__xnor2_1 U91 ( .A(n24), .B(n22), .Y(SUM[9]) );
  sky130_fd_sc_hd__xnor2_1 U92 ( .A(n33), .B(n31), .Y(SUM[7]) );
  sky130_fd_sc_hd__xnor2_1 U93 ( .A(n49), .B(n47), .Y(SUM[3]) );
  sky130_fd_sc_hd__inv_2 U94 ( .A(n9), .Y(n10) );
  sky130_fd_sc_hd__inv_2 U95 ( .A(n42), .Y(n43) );
endmodule


module uart_tx ( clk_i, rst_n_i, tx_o, busy_o, cfg_en_i, cfg_div_i, 
        cfg_parity_en_i, cfg_bits_i, cfg_stop_bits_i, tx_data_i, tx_valid_i, 
        tx_ready_o );
  input [15:0] cfg_div_i;
  input [1:0] cfg_bits_i;
  input [7:0] tx_data_i;
  input clk_i, rst_n_i, cfg_en_i, cfg_parity_en_i, cfg_stop_bits_i, tx_valid_i;
  output tx_o, busy_o, tx_ready_o;
  wire   s_parity_bit_q, s_bit_done, N87, N88, N89, N90, N91, N92, N93, N94,
         N95, N96, N97, N98, N99, N100, N101, N102, N119, N120, N121, N122,
         N123, N124, N125, N126, N127, N128, N129, N130, N131, N132, N133,
         N134, N135, n128, n22, n23, n24, n29, n43, n44, n84, n85, n86, n87,
         n88, n89, n90, n91, n93, n94, n95, n96, n97, n98, n1, n2, n3, n4, n5,
         n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20,
         n21, n25, n26, n27, n28, n31, n32, n33, n34, n35, n36, n37, n38, n39,
         n40, n41, n42, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55,
         n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69,
         n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n92, n99, n100, n101, n102, n103, n104, n105, n106, n107, n108, n109,
         n110, n111, n112, n113, n114, n115, n116, n117, n118, n119, n120,
         n121, n122, n123, n124, n125, n126;
  wire   [2:0] s_fsm_q;
  wire   [2:0] s_reg_bit_cnt_q;
  wire   [7:0] s_reg_data_q;
  wire   [15:0] baud_cnt;

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
        rst_n_i), .Q(s_reg_data_q[7]), .Q_N(n22) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_0_ ( .D(n26), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n121), .Q_N(n29) );
  sky130_fd_sc_hd__dfrtp_1 s_parity_bit_q_reg ( .D(n91), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_parity_bit_q) );
  sky130_fd_sc_hd__o21a_1 U67 ( .A1(n125), .A2(s_reg_bit_cnt_q[1]), .B1(n27), 
        .X(n44) );
  uart_tx_DW01_inc_1 add_163 ( .A(baud_cnt), .SUM({N102, N101, N100, N99, N98, 
        N97, N96, N95, N94, N93, N92, N91, N90, N89, N88, N87}) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_5_ ( .D(n88), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(s_reg_data_q[5]), .Q_N(n24) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_6_ ( .D(n89), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(s_reg_data_q[6]), .Q_N(n23) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_3_ ( .D(n86), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n12) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_2_ ( .D(n85), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n10) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_4_ ( .D(n87), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n8) );
  sky130_fd_sc_hd__dfstp_1 s_reg_data_q_reg_1_ ( .D(n84), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(n6) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_1_ ( .D(n96), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[1]) );
  sky130_fd_sc_hd__inv_1 U3 ( .A(n75), .Y(n1) );
  sky130_fd_sc_hd__clkinv_1 U4 ( .A(n1), .Y(n2) );
  sky130_fd_sc_hd__nand3_1 U5 ( .A(n71), .B(s_bit_done), .C(n20), .Y(n21) );
  sky130_fd_sc_hd__nand3_1 U6 ( .A(n62), .B(n61), .C(s_reg_bit_cnt_q[2]), .Y(
        n71) );
  sky130_fd_sc_hd__or2_1 U7 ( .A(n24), .B(n14), .X(n3) );
  sky130_fd_sc_hd__or2_1 U8 ( .A(n23), .B(n14), .X(n4) );
  sky130_fd_sc_hd__nand3_2 U9 ( .A(n125), .B(n20), .C(n28), .Y(n83) );
  sky130_fd_sc_hd__dlygate4sd3_1 U10 ( .A(s_fsm_q[2]), .X(n5) );
  sky130_fd_sc_hd__inv_2 U11 ( .A(n6), .Y(n7) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(n8), .Y(n9) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n10), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U14 ( .A(n12), .Y(n13) );
  sky130_fd_sc_hd__o211a_1 U15 ( .A1(busy_o), .A2(tx_valid_i), .B1(cfg_en_i), 
        .C1(n64), .X(n28) );
  sky130_fd_sc_hd__inv_2 U16 ( .A(s_fsm_q[0]), .Y(n76) );
  sky130_fd_sc_hd__nand2_2 U17 ( .A(n21), .B(n100), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n21), .B(n100), .Y(n109) );
  sky130_fd_sc_hd__nand2_1 U19 ( .A(tx_data_i[5]), .B(n112), .Y(n15) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(s_reg_data_q[6]), .B(n113), .Y(n16) );
  sky130_fd_sc_hd__nand3_1 U21 ( .A(n15), .B(n16), .C(n3), .Y(n88) );
  sky130_fd_sc_hd__inv_1 U22 ( .A(n105), .Y(n113) );
  sky130_fd_sc_hd__nand2_1 U23 ( .A(tx_data_i[6]), .B(n112), .Y(n17) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(s_reg_data_q[7]), .B(n113), .Y(n18) );
  sky130_fd_sc_hd__nand3_1 U25 ( .A(n17), .B(n18), .C(n4), .Y(n89) );
  sky130_fd_sc_hd__clkinv_1 U26 ( .A(n114), .Y(n117) );
  sky130_fd_sc_hd__a21boi_0 U27 ( .A1(n28), .A2(n103), .B1_N(n67), .Y(n68) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(n69), .Y(n124) );
  sky130_fd_sc_hd__o21a_1 U29 ( .A1(n76), .A2(n92), .B1(n80), .X(n19) );
  sky130_fd_sc_hd__nand2_1 U30 ( .A(n19), .B(n68), .Y(n95) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n118), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U32 ( .A(tx_valid_i), .B(n103), .Y(n100) );
  sky130_fd_sc_hd__clkinv_1 U33 ( .A(n14), .Y(n111) );
  sky130_fd_sc_hd__buf_2 U34 ( .A(n128), .X(busy_o) );
  sky130_fd_sc_hd__and2_1 U35 ( .A(n60), .B(n63), .X(n25) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n63), .B(n101), .Y(n64) );
  sky130_fd_sc_hd__inv_2 U37 ( .A(n71), .Y(n125) );
  sky130_fd_sc_hd__nor2_2 U38 ( .A(n128), .B(n99), .Y(tx_ready_o) );
  sky130_fd_sc_hd__inv_1 U39 ( .A(n43), .Y(n73) );
  sky130_fd_sc_hd__nor2b_1 U40 ( .B_N(n63), .A(n60), .Y(N119) );
  sky130_fd_sc_hd__inv_1 U41 ( .A(n81), .Y(n120) );
  sky130_fd_sc_hd__o21a_1 U42 ( .A1(n2), .A2(n31), .B1(n67), .X(n82) );
  sky130_fd_sc_hd__inv_2 U43 ( .A(n120), .Y(n31) );
  sky130_fd_sc_hd__nand3_1 U44 ( .A(n32), .B(n33), .C(n34), .Y(n26) );
  sky130_fd_sc_hd__inv_1 U45 ( .A(n83), .Y(n65) );
  sky130_fd_sc_hd__o21a_1 U46 ( .A1(s_reg_bit_cnt_q[0]), .A2(n125), .B1(n124), 
        .X(n27) );
  sky130_fd_sc_hd__o211ai_1 U47 ( .A1(busy_o), .A2(tx_valid_i), .B1(cfg_en_i), 
        .C1(n64), .Y(n75) );
  sky130_fd_sc_hd__o22ai_1 U48 ( .A1(n27), .A2(n126), .B1(s_reg_bit_cnt_q[1]), 
        .B2(n43), .Y(n98) );
  sky130_fd_sc_hd__inv_1 U49 ( .A(s_reg_bit_cnt_q[1]), .Y(n126) );
  sky130_fd_sc_hd__inv_1 U50 ( .A(n77), .Y(n92) );
  sky130_fd_sc_hd__inv_1 U51 ( .A(busy_o), .Y(n103) );
  sky130_fd_sc_hd__nand2_2 U52 ( .A(n59), .B(n36), .Y(n128) );
  sky130_fd_sc_hd__inv_2 U53 ( .A(n104), .Y(n112) );
  sky130_fd_sc_hd__or2_4 U54 ( .A(n36), .B(n35), .X(n118) );
  sky130_fd_sc_hd__inv_2 U55 ( .A(s_fsm_q[1]), .Y(n36) );
  sky130_fd_sc_hd__nand2_2 U56 ( .A(n123), .B(n76), .Y(n35) );
  sky130_fd_sc_hd__nand2_1 U57 ( .A(n6), .B(n113), .Y(n32) );
  sky130_fd_sc_hd__nand2_1 U58 ( .A(tx_data_i[0]), .B(n112), .Y(n33) );
  sky130_fd_sc_hd__nand2_1 U59 ( .A(n111), .B(n121), .Y(n34) );
  sky130_fd_sc_hd__inv_2 U60 ( .A(s_fsm_q[2]), .Y(n123) );
  sky130_fd_sc_hd__inv_2 U61 ( .A(n35), .Y(n59) );
  sky130_fd_sc_hd__xor2_1 U62 ( .A(cfg_div_i[7]), .B(baud_cnt[7]), .X(n40) );
  sky130_fd_sc_hd__xor2_1 U63 ( .A(cfg_div_i[6]), .B(baud_cnt[6]), .X(n39) );
  sky130_fd_sc_hd__xor2_1 U64 ( .A(cfg_div_i[5]), .B(baud_cnt[5]), .X(n38) );
  sky130_fd_sc_hd__xor2_1 U65 ( .A(cfg_div_i[4]), .B(baud_cnt[4]), .X(n37) );
  sky130_fd_sc_hd__nor4_1 U66 ( .A(n40), .B(n39), .C(n38), .D(n37), .Y(n58) );
  sky130_fd_sc_hd__xor2_1 U68 ( .A(cfg_div_i[3]), .B(baud_cnt[3]), .X(n46) );
  sky130_fd_sc_hd__xor2_1 U69 ( .A(cfg_div_i[2]), .B(baud_cnt[2]), .X(n45) );
  sky130_fd_sc_hd__xor2_1 U70 ( .A(cfg_div_i[1]), .B(baud_cnt[1]), .X(n42) );
  sky130_fd_sc_hd__xor2_1 U71 ( .A(cfg_div_i[0]), .B(baud_cnt[0]), .X(n41) );
  sky130_fd_sc_hd__nor4_1 U72 ( .A(n46), .B(n45), .C(n42), .D(n41), .Y(n57) );
  sky130_fd_sc_hd__xor2_1 U73 ( .A(cfg_div_i[15]), .B(baud_cnt[15]), .X(n50)
         );
  sky130_fd_sc_hd__xor2_1 U74 ( .A(cfg_div_i[14]), .B(baud_cnt[14]), .X(n49)
         );
  sky130_fd_sc_hd__xor2_1 U75 ( .A(cfg_div_i[13]), .B(baud_cnt[13]), .X(n48)
         );
  sky130_fd_sc_hd__xor2_1 U76 ( .A(cfg_div_i[12]), .B(baud_cnt[12]), .X(n47)
         );
  sky130_fd_sc_hd__nor4_1 U77 ( .A(n50), .B(n49), .C(n48), .D(n47), .Y(n56) );
  sky130_fd_sc_hd__xor2_1 U78 ( .A(cfg_div_i[11]), .B(baud_cnt[11]), .X(n54)
         );
  sky130_fd_sc_hd__xor2_1 U79 ( .A(cfg_div_i[10]), .B(baud_cnt[10]), .X(n53)
         );
  sky130_fd_sc_hd__xor2_1 U80 ( .A(cfg_div_i[9]), .B(baud_cnt[9]), .X(n52) );
  sky130_fd_sc_hd__xor2_1 U81 ( .A(cfg_div_i[8]), .B(baud_cnt[8]), .X(n51) );
  sky130_fd_sc_hd__nor4_1 U82 ( .A(n54), .B(n53), .C(n52), .D(n51), .Y(n55) );
  sky130_fd_sc_hd__nand4_1 U83 ( .A(n58), .B(n57), .C(n56), .D(n55), .Y(n60)
         );
  sky130_fd_sc_hd__nand3_1 U84 ( .A(s_fsm_q[0]), .B(s_fsm_q[1]), .C(n123), .Y(
        n81) );
  sky130_fd_sc_hd__o211ai_1 U85 ( .A1(s_fsm_q[1]), .A2(n59), .B1(n118), .C1(
        n81), .Y(n63) );
  sky130_fd_sc_hd__and2_0 U86 ( .A(N102), .B(n25), .X(N135) );
  sky130_fd_sc_hd__and2_0 U87 ( .A(N101), .B(n25), .X(N134) );
  sky130_fd_sc_hd__and2_0 U88 ( .A(N100), .B(n25), .X(N133) );
  sky130_fd_sc_hd__and2_0 U89 ( .A(N99), .B(n25), .X(N132) );
  sky130_fd_sc_hd__and2_0 U90 ( .A(N98), .B(n25), .X(N131) );
  sky130_fd_sc_hd__and2_0 U91 ( .A(N97), .B(n25), .X(N130) );
  sky130_fd_sc_hd__and2_0 U92 ( .A(N96), .B(n25), .X(N129) );
  sky130_fd_sc_hd__and2_0 U93 ( .A(N95), .B(n25), .X(N128) );
  sky130_fd_sc_hd__and2_0 U94 ( .A(N94), .B(n25), .X(N127) );
  sky130_fd_sc_hd__and2_0 U95 ( .A(N93), .B(n25), .X(N126) );
  sky130_fd_sc_hd__and2_0 U96 ( .A(N91), .B(n25), .X(N124) );
  sky130_fd_sc_hd__and2_0 U97 ( .A(N90), .B(n25), .X(N123) );
  sky130_fd_sc_hd__and2_0 U98 ( .A(N89), .B(n25), .X(N122) );
  sky130_fd_sc_hd__and2_0 U99 ( .A(N88), .B(n25), .X(N121) );
  sky130_fd_sc_hd__and2_0 U100 ( .A(N87), .B(n25), .X(N120) );
  sky130_fd_sc_hd__and2_0 U101 ( .A(N92), .B(n25), .X(N125) );
  sky130_fd_sc_hd__xnor2_1 U102 ( .A(s_reg_bit_cnt_q[0]), .B(cfg_bits_i[0]), 
        .Y(n62) );
  sky130_fd_sc_hd__xnor2_1 U103 ( .A(s_reg_bit_cnt_q[1]), .B(cfg_bits_i[1]), 
        .Y(n61) );
  sky130_fd_sc_hd__inv_1 U104 ( .A(s_bit_done), .Y(n101) );
  sky130_fd_sc_hd__inv_1 U105 ( .A(cfg_en_i), .Y(n99) );
  sky130_fd_sc_hd__o32ai_1 U106 ( .A1(n125), .A2(n118), .A3(n75), .B1(n99), 
        .B2(n64), .Y(n77) );
  sky130_fd_sc_hd__nand2_1 U107 ( .A(cfg_parity_en_i), .B(n65), .Y(n80) );
  sky130_fd_sc_hd__nor2_1 U108 ( .A(s_fsm_q[0]), .B(s_fsm_q[1]), .Y(n66) );
  sky130_fd_sc_hd__nand4_1 U109 ( .A(cfg_stop_bits_i), .B(n5), .C(n28), .D(n66), .Y(n67) );
  sky130_fd_sc_hd__nand4_1 U110 ( .A(s_bit_done), .B(n123), .C(n81), .D(busy_o), .Y(n114) );
  sky130_fd_sc_hd__nand2_1 U111 ( .A(n117), .B(s_fsm_q[1]), .Y(n69) );
  sky130_fd_sc_hd__nand2_1 U112 ( .A(n124), .B(n71), .Y(n70) );
  sky130_fd_sc_hd__mux2i_1 U113 ( .A0(n70), .A1(n124), .S(s_reg_bit_cnt_q[0]), 
        .Y(n94) );
  sky130_fd_sc_hd__nand3_1 U114 ( .A(s_reg_bit_cnt_q[0]), .B(n124), .C(n71), 
        .Y(n43) );
  sky130_fd_sc_hd__inv_1 U115 ( .A(n126), .Y(n72) );
  sky130_fd_sc_hd__nand2_1 U116 ( .A(n73), .B(n72), .Y(n74) );
  sky130_fd_sc_hd__mux2i_1 U117 ( .A0(n74), .A1(n44), .S(s_reg_bit_cnt_q[2]), 
        .Y(n93) );
  sky130_fd_sc_hd__nor3_1 U118 ( .A(n2), .B(n76), .C(n5), .Y(n78) );
  sky130_fd_sc_hd__mux2i_1 U119 ( .A0(n78), .A1(n77), .S(s_fsm_q[1]), .Y(n79)
         );
  sky130_fd_sc_hd__nand2_1 U120 ( .A(n80), .B(n79), .Y(n96) );
  sky130_fd_sc_hd__o221ai_1 U121 ( .A1(n92), .A2(n123), .B1(cfg_parity_en_i), 
        .B2(n83), .C1(n82), .Y(n97) );
  sky130_fd_sc_hd__nor2_1 U122 ( .A(tx_data_i[7]), .B(n100), .Y(n102) );
  sky130_fd_sc_hd__mux2i_1 U123 ( .A0(n102), .A1(n22), .S(n111), .Y(n90) );
  sky130_fd_sc_hd__nand2_1 U124 ( .A(n109), .B(n103), .Y(n104) );
  sky130_fd_sc_hd__nand2_1 U125 ( .A(n109), .B(busy_o), .Y(n105) );
  sky130_fd_sc_hd__nor2_1 U126 ( .A(n9), .B(n14), .Y(n106) );
  sky130_fd_sc_hd__a221o_1 U127 ( .A1(tx_data_i[4]), .A2(n112), .B1(
        s_reg_data_q[5]), .B2(n113), .C1(n106), .X(n87) );
  sky130_fd_sc_hd__nor2_1 U128 ( .A(n13), .B(n14), .Y(n107) );
  sky130_fd_sc_hd__a221o_1 U129 ( .A1(tx_data_i[3]), .A2(n112), .B1(n8), .B2(
        n113), .C1(n107), .X(n86) );
  sky130_fd_sc_hd__nor2_1 U130 ( .A(n11), .B(n14), .Y(n108) );
  sky130_fd_sc_hd__a221o_1 U131 ( .A1(tx_data_i[2]), .A2(n112), .B1(n12), .B2(
        n113), .C1(n108), .X(n85) );
  sky130_fd_sc_hd__nor2_1 U132 ( .A(n7), .B(n14), .Y(n110) );
  sky130_fd_sc_hd__a221o_1 U133 ( .A1(tx_data_i[1]), .A2(n112), .B1(n10), .B2(
        n113), .C1(n110), .X(n84) );
  sky130_fd_sc_hd__nor2_1 U134 ( .A(n29), .B(n114), .Y(n115) );
  sky130_fd_sc_hd__mux2i_1 U135 ( .A0(n115), .A1(n29), .S(s_parity_bit_q), .Y(
        n119) );
  sky130_fd_sc_hd__inv_1 U136 ( .A(s_parity_bit_q), .Y(n116) );
  sky130_fd_sc_hd__o22ai_1 U137 ( .A1(n119), .A2(n118), .B1(n117), .B2(n116), 
        .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U138 ( .A1(n20), .A2(n121), .B1(s_parity_bit_q), 
        .B2(n120), .Y(n122) );
  sky130_fd_sc_hd__nand3_1 U139 ( .A(busy_o), .B(n123), .C(n122), .Y(tx_o) );
endmodule


module dffr_DATA_WIDTH6_2 ( clk_i, rst_n_i, dat_i, dat_o );
  input [5:0] dat_i;
  output [5:0] dat_o;
  input clk_i, rst_n_i;


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
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


  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_2 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(dat_o[2]) );
endmodule


module dffr_DATA_WIDTH576 ( clk_i, rst_n_i, dat_i, dat_o );
  input [575:0] dat_i;
  output [575:0] dat_o;
  input clk_i, rst_n_i;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60;

  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_567_ ( .D(dat_i[567]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[567]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_558_ ( .D(dat_i[558]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[558]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_549_ ( .D(dat_i[549]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[549]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_540_ ( .D(dat_i[540]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[540]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_531_ ( .D(dat_i[531]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[531]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_522_ ( .D(dat_i[522]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[522]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_513_ ( .D(dat_i[513]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[513]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_504_ ( .D(dat_i[504]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[504]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_495_ ( .D(dat_i[495]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[495]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_486_ ( .D(dat_i[486]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[486]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_477_ ( .D(dat_i[477]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[477]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_468_ ( .D(dat_i[468]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[468]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_459_ ( .D(dat_i[459]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[459]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_450_ ( .D(dat_i[450]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[450]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_441_ ( .D(dat_i[441]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[441]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_432_ ( .D(dat_i[432]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[432]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_423_ ( .D(dat_i[423]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[423]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_414_ ( .D(dat_i[414]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[414]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_405_ ( .D(dat_i[405]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[405]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_396_ ( .D(dat_i[396]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[396]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_387_ ( .D(dat_i[387]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[387]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_378_ ( .D(dat_i[378]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[378]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_369_ ( .D(dat_i[369]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[369]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_360_ ( .D(dat_i[360]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[360]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_351_ ( .D(dat_i[351]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[351]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_342_ ( .D(dat_i[342]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[342]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_333_ ( .D(dat_i[333]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[333]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_324_ ( .D(dat_i[324]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[324]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_315_ ( .D(dat_i[315]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[315]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_306_ ( .D(dat_i[306]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[306]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_297_ ( .D(dat_i[297]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[297]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_288_ ( .D(dat_i[288]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[288]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_279_ ( .D(dat_i[279]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[279]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_270_ ( .D(dat_i[270]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[270]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_261_ ( .D(dat_i[261]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[261]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_252_ ( .D(dat_i[252]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[252]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_243_ ( .D(dat_i[243]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[243]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_234_ ( .D(dat_i[234]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[234]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_225_ ( .D(dat_i[225]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[225]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_216_ ( .D(dat_i[216]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[216]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_207_ ( .D(dat_i[207]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[207]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_198_ ( .D(dat_i[198]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[198]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_189_ ( .D(dat_i[189]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[189]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_180_ ( .D(dat_i[180]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[180]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_171_ ( .D(dat_i[171]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[171]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_162_ ( .D(dat_i[162]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[162]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_153_ ( .D(dat_i[153]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[153]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_144_ ( .D(dat_i[144]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[144]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_135_ ( .D(dat_i[135]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[135]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_126_ ( .D(dat_i[126]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[126]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_117_ ( .D(dat_i[117]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[117]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_108_ ( .D(dat_i[108]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[108]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_99_ ( .D(dat_i[99]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[99]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_90_ ( .D(dat_i[90]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[90]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_81_ ( .D(dat_i[81]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[81]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_72_ ( .D(dat_i[72]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[72]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_63_ ( .D(dat_i[63]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[63]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_54_ ( .D(dat_i[54]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[54]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_45_ ( .D(dat_i[45]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[45]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_36_ ( .D(dat_i[36]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[36]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_27_ ( .D(dat_i[27]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[27]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_18_ ( .D(dat_i[18]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[18]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_9_ ( .D(dat_i[9]), .CLK(clk_i), .RESET_B(
        n59), .Q(dat_o[9]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_0_ ( .D(dat_i[0]), .CLK(clk_i), .RESET_B(
        n60), .Q(dat_o[0]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_7_ ( .D(dat_i[7]), .CLK(clk_i), .RESET_B(
        n59), .Q(dat_o[7]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_6_ ( .D(dat_i[6]), .CLK(clk_i), .RESET_B(
        n59), .Q(dat_o[6]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_5_ ( .D(dat_i[5]), .CLK(clk_i), .RESET_B(
        n59), .Q(dat_o[5]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_4_ ( .D(dat_i[4]), .CLK(clk_i), .RESET_B(
        n59), .Q(dat_o[4]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_3_ ( .D(dat_i[3]), .CLK(clk_i), .RESET_B(
        n60), .Q(dat_o[3]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_2_ ( .D(dat_i[2]), .CLK(clk_i), .RESET_B(
        n60), .Q(dat_o[2]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_1_ ( .D(dat_i[1]), .CLK(clk_i), .RESET_B(
        n60), .Q(dat_o[1]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_8_ ( .D(dat_i[8]), .CLK(clk_i), .RESET_B(
        n59), .Q(dat_o[8]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_106_ ( .D(dat_i[106]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[106]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_105_ ( .D(dat_i[105]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[105]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_104_ ( .D(dat_i[104]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[104]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_103_ ( .D(dat_i[103]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[103]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_102_ ( .D(dat_i[102]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[102]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_101_ ( .D(dat_i[101]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[101]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_100_ ( .D(dat_i[100]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[100]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_88_ ( .D(dat_i[88]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[88]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_87_ ( .D(dat_i[87]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[87]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_86_ ( .D(dat_i[86]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[86]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_85_ ( .D(dat_i[85]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[85]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_84_ ( .D(dat_i[84]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[84]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_83_ ( .D(dat_i[83]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[83]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_82_ ( .D(dat_i[82]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[82]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_79_ ( .D(dat_i[79]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[79]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_78_ ( .D(dat_i[78]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[78]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_77_ ( .D(dat_i[77]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[77]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_76_ ( .D(dat_i[76]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[76]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_75_ ( .D(dat_i[75]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[75]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_74_ ( .D(dat_i[74]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[74]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_73_ ( .D(dat_i[73]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[73]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_70_ ( .D(dat_i[70]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[70]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_69_ ( .D(dat_i[69]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[69]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_68_ ( .D(dat_i[68]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[68]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_67_ ( .D(dat_i[67]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[67]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_66_ ( .D(dat_i[66]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[66]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_65_ ( .D(dat_i[65]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[65]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_64_ ( .D(dat_i[64]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[64]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_61_ ( .D(dat_i[61]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[61]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_60_ ( .D(dat_i[60]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[60]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_59_ ( .D(dat_i[59]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[59]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_58_ ( .D(dat_i[58]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[58]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_57_ ( .D(dat_i[57]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[57]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_56_ ( .D(dat_i[56]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[56]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_55_ ( .D(dat_i[55]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[55]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_52_ ( .D(dat_i[52]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[52]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_51_ ( .D(dat_i[51]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[51]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_50_ ( .D(dat_i[50]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[50]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_49_ ( .D(dat_i[49]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[49]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_48_ ( .D(dat_i[48]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[48]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_47_ ( .D(dat_i[47]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[47]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_46_ ( .D(dat_i[46]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[46]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_43_ ( .D(dat_i[43]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[43]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_42_ ( .D(dat_i[42]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[42]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_41_ ( .D(dat_i[41]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[41]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_40_ ( .D(dat_i[40]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[40]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_39_ ( .D(dat_i[39]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[39]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_38_ ( .D(dat_i[38]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[38]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_37_ ( .D(dat_i[37]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[37]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_34_ ( .D(dat_i[34]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[34]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_33_ ( .D(dat_i[33]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[33]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_32_ ( .D(dat_i[32]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[32]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_31_ ( .D(dat_i[31]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[31]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_30_ ( .D(dat_i[30]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[30]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_29_ ( .D(dat_i[29]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[29]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_28_ ( .D(dat_i[28]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[28]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_25_ ( .D(dat_i[25]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[25]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_24_ ( .D(dat_i[24]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[24]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_23_ ( .D(dat_i[23]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[23]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_22_ ( .D(dat_i[22]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[22]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_21_ ( .D(dat_i[21]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[21]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_20_ ( .D(dat_i[20]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[20]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_19_ ( .D(dat_i[19]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[19]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_16_ ( .D(dat_i[16]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[16]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_15_ ( .D(dat_i[15]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[15]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_14_ ( .D(dat_i[14]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[14]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_13_ ( .D(dat_i[13]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[13]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_12_ ( .D(dat_i[12]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[12]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_11_ ( .D(dat_i[11]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[11]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_10_ ( .D(dat_i[10]), .CLK(clk_i), 
        .RESET_B(n59), .Q(dat_o[10]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_107_ ( .D(dat_i[107]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[107]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_98_ ( .D(dat_i[98]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[98]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_89_ ( .D(dat_i[89]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[89]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_80_ ( .D(dat_i[80]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[80]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_71_ ( .D(dat_i[71]), .CLK(clk_i), 
        .RESET_B(n54), .Q(dat_o[71]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_62_ ( .D(dat_i[62]), .CLK(clk_i), 
        .RESET_B(n55), .Q(dat_o[62]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_53_ ( .D(dat_i[53]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[53]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_44_ ( .D(dat_i[44]), .CLK(clk_i), 
        .RESET_B(n56), .Q(dat_o[44]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_35_ ( .D(dat_i[35]), .CLK(clk_i), 
        .RESET_B(n57), .Q(dat_o[35]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_26_ ( .D(dat_i[26]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[26]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_17_ ( .D(dat_i[17]), .CLK(clk_i), 
        .RESET_B(n58), .Q(dat_o[17]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_539_ ( .D(dat_i[539]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[539]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_538_ ( .D(dat_i[538]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[538]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_537_ ( .D(dat_i[537]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[537]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_536_ ( .D(dat_i[536]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[536]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_535_ ( .D(dat_i[535]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[535]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_534_ ( .D(dat_i[534]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[534]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_533_ ( .D(dat_i[533]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[533]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_532_ ( .D(dat_i[532]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[532]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_467_ ( .D(dat_i[467]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[467]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_466_ ( .D(dat_i[466]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[466]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_465_ ( .D(dat_i[465]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[465]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_464_ ( .D(dat_i[464]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[464]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_463_ ( .D(dat_i[463]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[463]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_462_ ( .D(dat_i[462]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[462]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_461_ ( .D(dat_i[461]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[461]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_460_ ( .D(dat_i[460]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[460]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_395_ ( .D(dat_i[395]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[395]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_394_ ( .D(dat_i[394]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[394]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_393_ ( .D(dat_i[393]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[393]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_392_ ( .D(dat_i[392]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[392]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_391_ ( .D(dat_i[391]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[391]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_390_ ( .D(dat_i[390]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[390]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_389_ ( .D(dat_i[389]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[389]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_388_ ( .D(dat_i[388]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[388]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_323_ ( .D(dat_i[323]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[323]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_322_ ( .D(dat_i[322]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[322]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_321_ ( .D(dat_i[321]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[321]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_320_ ( .D(dat_i[320]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[320]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_319_ ( .D(dat_i[319]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[319]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_318_ ( .D(dat_i[318]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[318]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_317_ ( .D(dat_i[317]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[317]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_316_ ( .D(dat_i[316]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[316]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_251_ ( .D(dat_i[251]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[251]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_250_ ( .D(dat_i[250]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[250]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_249_ ( .D(dat_i[249]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[249]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_248_ ( .D(dat_i[248]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[248]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_247_ ( .D(dat_i[247]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[247]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_246_ ( .D(dat_i[246]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[246]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_245_ ( .D(dat_i[245]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[245]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_244_ ( .D(dat_i[244]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[244]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_179_ ( .D(dat_i[179]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[179]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_178_ ( .D(dat_i[178]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[178]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_177_ ( .D(dat_i[177]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[177]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_176_ ( .D(dat_i[176]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[176]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_175_ ( .D(dat_i[175]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[175]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_174_ ( .D(dat_i[174]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[174]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_173_ ( .D(dat_i[173]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[173]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_172_ ( .D(dat_i[172]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[172]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_503_ ( .D(dat_i[503]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[503]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_502_ ( .D(dat_i[502]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[502]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_501_ ( .D(dat_i[501]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[501]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_500_ ( .D(dat_i[500]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[500]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_499_ ( .D(dat_i[499]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[499]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_498_ ( .D(dat_i[498]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[498]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_497_ ( .D(dat_i[497]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[497]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_496_ ( .D(dat_i[496]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[496]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_431_ ( .D(dat_i[431]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[431]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_430_ ( .D(dat_i[430]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[430]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_429_ ( .D(dat_i[429]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[429]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_428_ ( .D(dat_i[428]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[428]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_427_ ( .D(dat_i[427]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[427]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_426_ ( .D(dat_i[426]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[426]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_425_ ( .D(dat_i[425]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[425]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_424_ ( .D(dat_i[424]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[424]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_359_ ( .D(dat_i[359]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[359]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_358_ ( .D(dat_i[358]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[358]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_357_ ( .D(dat_i[357]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[357]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_356_ ( .D(dat_i[356]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[356]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_355_ ( .D(dat_i[355]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[355]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_354_ ( .D(dat_i[354]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[354]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_353_ ( .D(dat_i[353]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[353]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_352_ ( .D(dat_i[352]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[352]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_287_ ( .D(dat_i[287]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[287]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_286_ ( .D(dat_i[286]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[286]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_285_ ( .D(dat_i[285]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[285]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_284_ ( .D(dat_i[284]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[284]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_283_ ( .D(dat_i[283]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[283]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_282_ ( .D(dat_i[282]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[282]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_281_ ( .D(dat_i[281]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[281]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_280_ ( .D(dat_i[280]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[280]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_215_ ( .D(dat_i[215]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[215]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_214_ ( .D(dat_i[214]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[214]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_213_ ( .D(dat_i[213]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[213]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_212_ ( .D(dat_i[212]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[212]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_211_ ( .D(dat_i[211]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[211]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_210_ ( .D(dat_i[210]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[210]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_209_ ( .D(dat_i[209]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[209]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_208_ ( .D(dat_i[208]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[208]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_143_ ( .D(dat_i[143]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[143]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_142_ ( .D(dat_i[142]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[142]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_141_ ( .D(dat_i[141]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[141]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_140_ ( .D(dat_i[140]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[140]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_139_ ( .D(dat_i[139]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[139]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_138_ ( .D(dat_i[138]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[138]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_137_ ( .D(dat_i[137]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[137]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_136_ ( .D(dat_i[136]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[136]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_548_ ( .D(dat_i[548]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[548]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_547_ ( .D(dat_i[547]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[547]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_546_ ( .D(dat_i[546]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[546]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_545_ ( .D(dat_i[545]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[545]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_544_ ( .D(dat_i[544]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[544]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_543_ ( .D(dat_i[543]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[543]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_542_ ( .D(dat_i[542]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[542]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_541_ ( .D(dat_i[541]), .CLK(clk_i), 
        .RESET_B(n18), .Q(dat_o[541]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_476_ ( .D(dat_i[476]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[476]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_475_ ( .D(dat_i[475]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[475]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_474_ ( .D(dat_i[474]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[474]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_473_ ( .D(dat_i[473]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[473]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_472_ ( .D(dat_i[472]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[472]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_471_ ( .D(dat_i[471]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[471]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_470_ ( .D(dat_i[470]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[470]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_469_ ( .D(dat_i[469]), .CLK(clk_i), 
        .RESET_B(n24), .Q(dat_o[469]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_404_ ( .D(dat_i[404]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[404]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_403_ ( .D(dat_i[403]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[403]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_402_ ( .D(dat_i[402]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[402]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_401_ ( .D(dat_i[401]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[401]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_400_ ( .D(dat_i[400]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[400]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_399_ ( .D(dat_i[399]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[399]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_398_ ( .D(dat_i[398]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[398]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_397_ ( .D(dat_i[397]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[397]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_332_ ( .D(dat_i[332]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[332]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_331_ ( .D(dat_i[331]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[331]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_330_ ( .D(dat_i[330]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[330]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_329_ ( .D(dat_i[329]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[329]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_328_ ( .D(dat_i[328]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[328]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_327_ ( .D(dat_i[327]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[327]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_326_ ( .D(dat_i[326]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[326]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_325_ ( .D(dat_i[325]), .CLK(clk_i), 
        .RESET_B(n35), .Q(dat_o[325]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_260_ ( .D(dat_i[260]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[260]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_259_ ( .D(dat_i[259]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[259]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_258_ ( .D(dat_i[258]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[258]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_257_ ( .D(dat_i[257]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[257]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_256_ ( .D(dat_i[256]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[256]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_255_ ( .D(dat_i[255]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[255]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_254_ ( .D(dat_i[254]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[254]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_253_ ( .D(dat_i[253]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[253]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_188_ ( .D(dat_i[188]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[188]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_187_ ( .D(dat_i[187]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[187]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_186_ ( .D(dat_i[186]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[186]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_185_ ( .D(dat_i[185]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[185]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_184_ ( .D(dat_i[184]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[184]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_183_ ( .D(dat_i[183]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[183]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_182_ ( .D(dat_i[182]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[182]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_181_ ( .D(dat_i[181]), .CLK(clk_i), 
        .RESET_B(n46), .Q(dat_o[181]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_116_ ( .D(dat_i[116]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[116]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_115_ ( .D(dat_i[115]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[115]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_114_ ( .D(dat_i[114]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[114]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_113_ ( .D(dat_i[113]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[113]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_112_ ( .D(dat_i[112]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[112]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_111_ ( .D(dat_i[111]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[111]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_110_ ( .D(dat_i[110]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[110]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_109_ ( .D(dat_i[109]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[109]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_530_ ( .D(dat_i[530]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[530]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_529_ ( .D(dat_i[529]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[529]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_528_ ( .D(dat_i[528]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[528]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_527_ ( .D(dat_i[527]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[527]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_526_ ( .D(dat_i[526]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[526]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_525_ ( .D(dat_i[525]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[525]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_524_ ( .D(dat_i[524]), .CLK(clk_i), 
        .RESET_B(n19), .Q(dat_o[524]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_523_ ( .D(dat_i[523]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[523]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_521_ ( .D(dat_i[521]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[521]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_520_ ( .D(dat_i[520]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[520]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_519_ ( .D(dat_i[519]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[519]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_518_ ( .D(dat_i[518]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[518]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_517_ ( .D(dat_i[517]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[517]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_516_ ( .D(dat_i[516]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[516]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_515_ ( .D(dat_i[515]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[515]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_514_ ( .D(dat_i[514]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[514]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_512_ ( .D(dat_i[512]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[512]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_511_ ( .D(dat_i[511]), .CLK(clk_i), 
        .RESET_B(n20), .Q(dat_o[511]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_510_ ( .D(dat_i[510]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[510]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_509_ ( .D(dat_i[509]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[509]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_508_ ( .D(dat_i[508]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[508]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_507_ ( .D(dat_i[507]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[507]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_506_ ( .D(dat_i[506]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[506]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_505_ ( .D(dat_i[505]), .CLK(clk_i), 
        .RESET_B(n21), .Q(dat_o[505]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_458_ ( .D(dat_i[458]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[458]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_457_ ( .D(dat_i[457]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[457]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_456_ ( .D(dat_i[456]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[456]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_455_ ( .D(dat_i[455]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[455]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_454_ ( .D(dat_i[454]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[454]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_453_ ( .D(dat_i[453]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[453]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_452_ ( .D(dat_i[452]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[452]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_451_ ( .D(dat_i[451]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[451]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_449_ ( .D(dat_i[449]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[449]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_448_ ( .D(dat_i[448]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[448]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_447_ ( .D(dat_i[447]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[447]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_446_ ( .D(dat_i[446]), .CLK(clk_i), 
        .RESET_B(n25), .Q(dat_o[446]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_445_ ( .D(dat_i[445]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[445]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_444_ ( .D(dat_i[444]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[444]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_443_ ( .D(dat_i[443]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[443]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_442_ ( .D(dat_i[442]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[442]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_440_ ( .D(dat_i[440]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[440]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_439_ ( .D(dat_i[439]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[439]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_438_ ( .D(dat_i[438]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[438]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_437_ ( .D(dat_i[437]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[437]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_436_ ( .D(dat_i[436]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[436]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_435_ ( .D(dat_i[435]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[435]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_434_ ( .D(dat_i[434]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[434]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_433_ ( .D(dat_i[433]), .CLK(clk_i), 
        .RESET_B(n26), .Q(dat_o[433]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_386_ ( .D(dat_i[386]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[386]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_385_ ( .D(dat_i[385]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[385]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_384_ ( .D(dat_i[384]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[384]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_383_ ( .D(dat_i[383]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[383]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_382_ ( .D(dat_i[382]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[382]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_381_ ( .D(dat_i[381]), .CLK(clk_i), 
        .RESET_B(n30), .Q(dat_o[381]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_380_ ( .D(dat_i[380]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[380]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_379_ ( .D(dat_i[379]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[379]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_377_ ( .D(dat_i[377]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[377]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_376_ ( .D(dat_i[376]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[376]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_375_ ( .D(dat_i[375]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[375]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_374_ ( .D(dat_i[374]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[374]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_373_ ( .D(dat_i[373]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[373]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_372_ ( .D(dat_i[372]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[372]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_371_ ( .D(dat_i[371]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[371]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_370_ ( .D(dat_i[370]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[370]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_368_ ( .D(dat_i[368]), .CLK(clk_i), 
        .RESET_B(n31), .Q(dat_o[368]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_367_ ( .D(dat_i[367]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[367]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_366_ ( .D(dat_i[366]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[366]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_365_ ( .D(dat_i[365]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[365]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_364_ ( .D(dat_i[364]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[364]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_363_ ( .D(dat_i[363]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[363]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_362_ ( .D(dat_i[362]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[362]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_361_ ( .D(dat_i[361]), .CLK(clk_i), 
        .RESET_B(n32), .Q(dat_o[361]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_314_ ( .D(dat_i[314]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[314]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_313_ ( .D(dat_i[313]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[313]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_312_ ( .D(dat_i[312]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[312]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_311_ ( .D(dat_i[311]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[311]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_310_ ( .D(dat_i[310]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[310]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_309_ ( .D(dat_i[309]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[309]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_308_ ( .D(dat_i[308]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[308]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_307_ ( .D(dat_i[307]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[307]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_305_ ( .D(dat_i[305]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[305]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_304_ ( .D(dat_i[304]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[304]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_303_ ( .D(dat_i[303]), .CLK(clk_i), 
        .RESET_B(n36), .Q(dat_o[303]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_302_ ( .D(dat_i[302]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[302]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_301_ ( .D(dat_i[301]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[301]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_300_ ( .D(dat_i[300]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[300]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_299_ ( .D(dat_i[299]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[299]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_298_ ( .D(dat_i[298]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[298]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_296_ ( .D(dat_i[296]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[296]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_295_ ( .D(dat_i[295]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[295]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_294_ ( .D(dat_i[294]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[294]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_293_ ( .D(dat_i[293]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[293]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_292_ ( .D(dat_i[292]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[292]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_291_ ( .D(dat_i[291]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[291]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_290_ ( .D(dat_i[290]), .CLK(clk_i), 
        .RESET_B(n37), .Q(dat_o[290]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_289_ ( .D(dat_i[289]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[289]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_242_ ( .D(dat_i[242]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[242]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_241_ ( .D(dat_i[241]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[241]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_240_ ( .D(dat_i[240]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[240]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_239_ ( .D(dat_i[239]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[239]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_238_ ( .D(dat_i[238]), .CLK(clk_i), 
        .RESET_B(n41), .Q(dat_o[238]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_237_ ( .D(dat_i[237]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[237]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_236_ ( .D(dat_i[236]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[236]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_235_ ( .D(dat_i[235]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[235]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_233_ ( .D(dat_i[233]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[233]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_232_ ( .D(dat_i[232]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[232]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_231_ ( .D(dat_i[231]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[231]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_230_ ( .D(dat_i[230]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[230]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_229_ ( .D(dat_i[229]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[229]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_228_ ( .D(dat_i[228]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[228]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_227_ ( .D(dat_i[227]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[227]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_226_ ( .D(dat_i[226]), .CLK(clk_i), 
        .RESET_B(n42), .Q(dat_o[226]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_224_ ( .D(dat_i[224]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[224]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_223_ ( .D(dat_i[223]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[223]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_222_ ( .D(dat_i[222]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[222]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_221_ ( .D(dat_i[221]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[221]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_220_ ( .D(dat_i[220]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[220]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_219_ ( .D(dat_i[219]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[219]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_218_ ( .D(dat_i[218]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[218]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_217_ ( .D(dat_i[217]), .CLK(clk_i), 
        .RESET_B(n43), .Q(dat_o[217]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_170_ ( .D(dat_i[170]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[170]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_169_ ( .D(dat_i[169]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[169]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_168_ ( .D(dat_i[168]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[168]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_167_ ( .D(dat_i[167]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[167]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_166_ ( .D(dat_i[166]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[166]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_165_ ( .D(dat_i[165]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[165]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_164_ ( .D(dat_i[164]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[164]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_163_ ( .D(dat_i[163]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[163]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_161_ ( .D(dat_i[161]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[161]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_160_ ( .D(dat_i[160]), .CLK(clk_i), 
        .RESET_B(n47), .Q(dat_o[160]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_159_ ( .D(dat_i[159]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[159]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_158_ ( .D(dat_i[158]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[158]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_157_ ( .D(dat_i[157]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[157]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_156_ ( .D(dat_i[156]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[156]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_155_ ( .D(dat_i[155]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[155]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_154_ ( .D(dat_i[154]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[154]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_152_ ( .D(dat_i[152]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[152]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_151_ ( .D(dat_i[151]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[151]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_150_ ( .D(dat_i[150]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[150]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_149_ ( .D(dat_i[149]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[149]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_148_ ( .D(dat_i[148]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[148]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_147_ ( .D(dat_i[147]), .CLK(clk_i), 
        .RESET_B(n48), .Q(dat_o[147]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_146_ ( .D(dat_i[146]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[146]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_145_ ( .D(dat_i[145]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[145]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_97_ ( .D(dat_i[97]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[97]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_96_ ( .D(dat_i[96]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[96]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_95_ ( .D(dat_i[95]), .CLK(clk_i), 
        .RESET_B(n52), .Q(dat_o[95]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_94_ ( .D(dat_i[94]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[94]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_93_ ( .D(dat_i[93]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[93]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_92_ ( .D(dat_i[92]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[92]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_91_ ( .D(dat_i[91]), .CLK(clk_i), 
        .RESET_B(n53), .Q(dat_o[91]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_566_ ( .D(dat_i[566]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[566]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_565_ ( .D(dat_i[565]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[565]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_564_ ( .D(dat_i[564]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[564]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_563_ ( .D(dat_i[563]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[563]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_562_ ( .D(dat_i[562]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[562]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_561_ ( .D(dat_i[561]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[561]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_560_ ( .D(dat_i[560]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[560]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_559_ ( .D(dat_i[559]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[559]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_494_ ( .D(dat_i[494]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[494]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_493_ ( .D(dat_i[493]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[493]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_492_ ( .D(dat_i[492]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[492]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_491_ ( .D(dat_i[491]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[491]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_490_ ( .D(dat_i[490]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[490]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_489_ ( .D(dat_i[489]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[489]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_488_ ( .D(dat_i[488]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[488]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_487_ ( .D(dat_i[487]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[487]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_422_ ( .D(dat_i[422]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[422]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_421_ ( .D(dat_i[421]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[421]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_420_ ( .D(dat_i[420]), .CLK(clk_i), 
        .RESET_B(n27), .Q(dat_o[420]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_419_ ( .D(dat_i[419]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[419]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_418_ ( .D(dat_i[418]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[418]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_417_ ( .D(dat_i[417]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[417]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_416_ ( .D(dat_i[416]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[416]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_415_ ( .D(dat_i[415]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[415]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_350_ ( .D(dat_i[350]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[350]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_349_ ( .D(dat_i[349]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[349]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_348_ ( .D(dat_i[348]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[348]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_347_ ( .D(dat_i[347]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[347]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_346_ ( .D(dat_i[346]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[346]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_345_ ( .D(dat_i[345]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[345]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_344_ ( .D(dat_i[344]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[344]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_343_ ( .D(dat_i[343]), .CLK(clk_i), 
        .RESET_B(n33), .Q(dat_o[343]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_278_ ( .D(dat_i[278]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[278]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_277_ ( .D(dat_i[277]), .CLK(clk_i), 
        .RESET_B(n38), .Q(dat_o[277]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_276_ ( .D(dat_i[276]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[276]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_275_ ( .D(dat_i[275]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[275]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_274_ ( .D(dat_i[274]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[274]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_273_ ( .D(dat_i[273]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[273]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_272_ ( .D(dat_i[272]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[272]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_271_ ( .D(dat_i[271]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[271]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_206_ ( .D(dat_i[206]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[206]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_205_ ( .D(dat_i[205]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[205]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_204_ ( .D(dat_i[204]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[204]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_203_ ( .D(dat_i[203]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[203]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_202_ ( .D(dat_i[202]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[202]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_201_ ( .D(dat_i[201]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[201]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_200_ ( .D(dat_i[200]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[200]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_199_ ( .D(dat_i[199]), .CLK(clk_i), 
        .RESET_B(n44), .Q(dat_o[199]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_134_ ( .D(dat_i[134]), .CLK(clk_i), 
        .RESET_B(n49), .Q(dat_o[134]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_133_ ( .D(dat_i[133]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[133]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_132_ ( .D(dat_i[132]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[132]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_131_ ( .D(dat_i[131]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[131]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_130_ ( .D(dat_i[130]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[130]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_129_ ( .D(dat_i[129]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[129]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_128_ ( .D(dat_i[128]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[128]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_127_ ( .D(dat_i[127]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[127]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_557_ ( .D(dat_i[557]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[557]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_556_ ( .D(dat_i[556]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[556]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_555_ ( .D(dat_i[555]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[555]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_554_ ( .D(dat_i[554]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[554]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_553_ ( .D(dat_i[553]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[553]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_552_ ( .D(dat_i[552]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[552]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_551_ ( .D(dat_i[551]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[551]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_550_ ( .D(dat_i[550]), .CLK(clk_i), 
        .RESET_B(n17), .Q(dat_o[550]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_485_ ( .D(dat_i[485]), .CLK(clk_i), 
        .RESET_B(n22), .Q(dat_o[485]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_484_ ( .D(dat_i[484]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[484]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_483_ ( .D(dat_i[483]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[483]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_482_ ( .D(dat_i[482]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[482]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_481_ ( .D(dat_i[481]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[481]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_480_ ( .D(dat_i[480]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[480]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_479_ ( .D(dat_i[479]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[479]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_478_ ( .D(dat_i[478]), .CLK(clk_i), 
        .RESET_B(n23), .Q(dat_o[478]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_413_ ( .D(dat_i[413]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[413]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_412_ ( .D(dat_i[412]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[412]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_411_ ( .D(dat_i[411]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[411]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_410_ ( .D(dat_i[410]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[410]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_409_ ( .D(dat_i[409]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[409]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_408_ ( .D(dat_i[408]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[408]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_407_ ( .D(dat_i[407]), .CLK(clk_i), 
        .RESET_B(n28), .Q(dat_o[407]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_406_ ( .D(dat_i[406]), .CLK(clk_i), 
        .RESET_B(n29), .Q(dat_o[406]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_341_ ( .D(dat_i[341]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[341]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_340_ ( .D(dat_i[340]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[340]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_339_ ( .D(dat_i[339]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[339]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_338_ ( .D(dat_i[338]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[338]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_337_ ( .D(dat_i[337]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[337]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_336_ ( .D(dat_i[336]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[336]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_335_ ( .D(dat_i[335]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[335]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_334_ ( .D(dat_i[334]), .CLK(clk_i), 
        .RESET_B(n34), .Q(dat_o[334]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_269_ ( .D(dat_i[269]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[269]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_268_ ( .D(dat_i[268]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[268]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_267_ ( .D(dat_i[267]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[267]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_266_ ( .D(dat_i[266]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[266]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_265_ ( .D(dat_i[265]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[265]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_264_ ( .D(dat_i[264]), .CLK(clk_i), 
        .RESET_B(n39), .Q(dat_o[264]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_263_ ( .D(dat_i[263]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[263]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_262_ ( .D(dat_i[262]), .CLK(clk_i), 
        .RESET_B(n40), .Q(dat_o[262]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_197_ ( .D(dat_i[197]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[197]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_196_ ( .D(dat_i[196]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[196]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_195_ ( .D(dat_i[195]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[195]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_194_ ( .D(dat_i[194]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[194]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_193_ ( .D(dat_i[193]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[193]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_192_ ( .D(dat_i[192]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[192]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_191_ ( .D(dat_i[191]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[191]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_190_ ( .D(dat_i[190]), .CLK(clk_i), 
        .RESET_B(n45), .Q(dat_o[190]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_125_ ( .D(dat_i[125]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[125]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_124_ ( .D(dat_i[124]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[124]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_123_ ( .D(dat_i[123]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[123]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_122_ ( .D(dat_i[122]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[122]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_121_ ( .D(dat_i[121]), .CLK(clk_i), 
        .RESET_B(n50), .Q(dat_o[121]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_120_ ( .D(dat_i[120]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[120]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_119_ ( .D(dat_i[119]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[119]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_118_ ( .D(dat_i[118]), .CLK(clk_i), 
        .RESET_B(n51), .Q(dat_o[118]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_575_ ( .D(dat_i[575]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[575]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_574_ ( .D(dat_i[574]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[574]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_573_ ( .D(dat_i[573]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[573]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_572_ ( .D(dat_i[572]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[572]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_571_ ( .D(dat_i[571]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[571]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_570_ ( .D(dat_i[570]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[570]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_569_ ( .D(dat_i[569]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[569]) );
  sky130_fd_sc_hd__dfrtp_1 dat_o_reg_568_ ( .D(dat_i[568]), .CLK(clk_i), 
        .RESET_B(n16), .Q(dat_o[568]) );
  sky130_fd_sc_hd__buf_1 U3 ( .A(n15), .X(n59) );
  sky130_fd_sc_hd__buf_1 U4 ( .A(n15), .X(n58) );
  sky130_fd_sc_hd__buf_1 U5 ( .A(n14), .X(n57) );
  sky130_fd_sc_hd__buf_1 U6 ( .A(n14), .X(n56) );
  sky130_fd_sc_hd__buf_1 U7 ( .A(n14), .X(n55) );
  sky130_fd_sc_hd__buf_1 U8 ( .A(n13), .X(n54) );
  sky130_fd_sc_hd__buf_1 U9 ( .A(n13), .X(n53) );
  sky130_fd_sc_hd__buf_1 U10 ( .A(n13), .X(n52) );
  sky130_fd_sc_hd__buf_1 U11 ( .A(n12), .X(n51) );
  sky130_fd_sc_hd__buf_1 U12 ( .A(n12), .X(n50) );
  sky130_fd_sc_hd__buf_1 U13 ( .A(n12), .X(n49) );
  sky130_fd_sc_hd__buf_1 U14 ( .A(n11), .X(n48) );
  sky130_fd_sc_hd__buf_1 U15 ( .A(n11), .X(n47) );
  sky130_fd_sc_hd__buf_1 U16 ( .A(n11), .X(n46) );
  sky130_fd_sc_hd__buf_1 U17 ( .A(n10), .X(n45) );
  sky130_fd_sc_hd__buf_1 U18 ( .A(n10), .X(n44) );
  sky130_fd_sc_hd__buf_1 U19 ( .A(n10), .X(n43) );
  sky130_fd_sc_hd__buf_1 U20 ( .A(n9), .X(n42) );
  sky130_fd_sc_hd__buf_1 U21 ( .A(n9), .X(n41) );
  sky130_fd_sc_hd__buf_1 U22 ( .A(n9), .X(n40) );
  sky130_fd_sc_hd__buf_1 U23 ( .A(n8), .X(n39) );
  sky130_fd_sc_hd__buf_1 U24 ( .A(n8), .X(n38) );
  sky130_fd_sc_hd__buf_1 U25 ( .A(n8), .X(n37) );
  sky130_fd_sc_hd__buf_1 U26 ( .A(n7), .X(n36) );
  sky130_fd_sc_hd__buf_1 U27 ( .A(n7), .X(n35) );
  sky130_fd_sc_hd__buf_1 U28 ( .A(n7), .X(n34) );
  sky130_fd_sc_hd__buf_1 U29 ( .A(n6), .X(n33) );
  sky130_fd_sc_hd__buf_1 U30 ( .A(n6), .X(n32) );
  sky130_fd_sc_hd__buf_1 U31 ( .A(n6), .X(n31) );
  sky130_fd_sc_hd__buf_1 U32 ( .A(n5), .X(n30) );
  sky130_fd_sc_hd__buf_1 U33 ( .A(n5), .X(n29) );
  sky130_fd_sc_hd__buf_1 U34 ( .A(n5), .X(n28) );
  sky130_fd_sc_hd__buf_1 U35 ( .A(n4), .X(n27) );
  sky130_fd_sc_hd__buf_1 U36 ( .A(n4), .X(n26) );
  sky130_fd_sc_hd__buf_1 U37 ( .A(n4), .X(n25) );
  sky130_fd_sc_hd__buf_1 U38 ( .A(n3), .X(n24) );
  sky130_fd_sc_hd__buf_1 U39 ( .A(n3), .X(n23) );
  sky130_fd_sc_hd__buf_1 U40 ( .A(n3), .X(n22) );
  sky130_fd_sc_hd__buf_1 U41 ( .A(n2), .X(n21) );
  sky130_fd_sc_hd__buf_1 U42 ( .A(n2), .X(n20) );
  sky130_fd_sc_hd__buf_1 U43 ( .A(n2), .X(n19) );
  sky130_fd_sc_hd__buf_1 U44 ( .A(n1), .X(n18) );
  sky130_fd_sc_hd__buf_1 U45 ( .A(n1), .X(n17) );
  sky130_fd_sc_hd__buf_1 U46 ( .A(n1), .X(n16) );
  sky130_fd_sc_hd__buf_1 U47 ( .A(n15), .X(n60) );
  sky130_fd_sc_hd__buf_1 U48 ( .A(rst_n_i), .X(n15) );
  sky130_fd_sc_hd__buf_1 U49 ( .A(rst_n_i), .X(n14) );
  sky130_fd_sc_hd__buf_1 U50 ( .A(rst_n_i), .X(n13) );
  sky130_fd_sc_hd__buf_1 U51 ( .A(rst_n_i), .X(n12) );
  sky130_fd_sc_hd__buf_1 U52 ( .A(rst_n_i), .X(n11) );
  sky130_fd_sc_hd__buf_1 U53 ( .A(rst_n_i), .X(n10) );
  sky130_fd_sc_hd__buf_1 U54 ( .A(rst_n_i), .X(n9) );
  sky130_fd_sc_hd__buf_1 U55 ( .A(rst_n_i), .X(n8) );
  sky130_fd_sc_hd__buf_1 U56 ( .A(rst_n_i), .X(n7) );
  sky130_fd_sc_hd__buf_1 U57 ( .A(rst_n_i), .X(n6) );
  sky130_fd_sc_hd__buf_1 U58 ( .A(rst_n_i), .X(n5) );
  sky130_fd_sc_hd__buf_1 U59 ( .A(rst_n_i), .X(n4) );
  sky130_fd_sc_hd__buf_1 U60 ( .A(rst_n_i), .X(n3) );
  sky130_fd_sc_hd__buf_1 U61 ( .A(rst_n_i), .X(n2) );
  sky130_fd_sc_hd__buf_1 U62 ( .A(rst_n_i), .X(n1) );
endmodule


module fifo_DATA_WIDTH9_BUFFER_DEPTH64_DW01_inc_3 ( A, SUM );
  input [6:0] A;
  output [6:0] SUM;
  wire   n1, n2, n4, n5, n6, n7, n9, n10, n11, n12, n14;
  assign n2 = A[5];
  assign n7 = A[3];
  assign n12 = A[1];
  assign n14 = A[0];

  sky130_fd_sc_hd__nand2_1 U4 ( .A(n4), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n6), .B(n5), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n5), .B(n6), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U11 ( .A(n9), .B(n7), .Y(n6) );
  sky130_fd_sc_hd__xor2_1 U14 ( .A(n11), .B(n10), .X(SUM[2]) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(n10), .B(n11), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U18 ( .A(n12), .B(n14), .Y(n11) );
  sky130_fd_sc_hd__xor2_1 U25 ( .A(n2), .B(n4), .X(SUM[5]) );
  sky130_fd_sc_hd__xnor2_1 U26 ( .A(A[6]), .B(n1), .Y(SUM[6]) );
  sky130_fd_sc_hd__xor2_1 U27 ( .A(n14), .B(n12), .X(SUM[1]) );
  sky130_fd_sc_hd__xor2_1 U28 ( .A(n7), .B(n9), .X(SUM[3]) );
  sky130_fd_sc_hd__inv_1 U29 ( .A(A[4]), .Y(n5) );
  sky130_fd_sc_hd__inv_1 U30 ( .A(A[2]), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n14), .Y(SUM[0]) );
endmodule


module fifo_DATA_WIDTH9_BUFFER_DEPTH64 ( clk_i, rst_n_i, flush_i, full_o, 
        empty_o, cnt_o, dat_i, push_i, dat_o, pop_i );
  output [6:0] cnt_o;
  input [8:0] dat_i;
  output [8:0] dat_o;
  input clk_i, rst_n_i, flush_i, push_i, pop_i;
  output full_o, empty_o;
  wire   N75, N76, N77, N78, N79, N80, n1459, n1460, n1461, N85, N86, N87, N88,
         N89, N96, N97, N98, N99, N100, N108, N109, N110, N111, N112, N113,
         N114, \add_65/carry[5] , \add_65/carry[4] , \add_65/carry[3] ,
         \add_65/carry[2] , \add_50/carry[5] , \add_50/carry[4] ,
         \add_50/carry[3] , \add_50/carry[2] , n1, n2, n3, n4, n5, n6, n7, n8,
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
         n150, n151, n152, n153, n154, n155, n156, n157, n158, n159, n160,
         n161, n162, n163, n164, n165, n166, n167, n168, n169, n170, n171,
         n172, n173, n174, n175, n176, n177, n178, n179, n180, n181, n182,
         n183, n184, n185, n186, n187, n188, n189, n190, n191, n192, n193,
         n194, n195, n196, n197, n198, n199, n200, n201, n202, n203, n204,
         n205, n206, n207, n208, n209, n210, n211, n212, n213, n214, n215,
         n216, n217, n218, n219, n220, n221, n222, n223, n224, n225, n226,
         n227, n228, n229, n230, n231, n232, n233, n234, n235, n236, n237,
         n238, n239, n240, n241, n242, n243, n244, n245, n246, n247, n248,
         n249, n250, n251, n252, n253, n254, n255, n256, n257, n258, n259,
         n260, n261, n262, n263, n264, n265, n266, n267, n268, n269, n270,
         n271, n272, n273, n274, n275, n276, n277, n278, n279, n280, n281,
         n282, n283, n284, n285, n286, n287, n288, n289, n290, n291, n292,
         n293, n294, n295, n296, n297, n298, n299, n300, n301, n302, n303,
         n304, n305, n306, n307, n308, n309, n310, n311, n312, n313, n314,
         n315, n316, n317, n318, n319, n320, n321, n322, n323, n324, n325,
         n326, n327, n328, n329, n330, n331, n332, n333, n334, n335, n336,
         n337, n338, n339, n340, n341, n342, n343, n344, n345, n346, n347,
         n348, n349, n350, n351, n352, n353, n354, n355, n356, n357, n358,
         n359, n360, n361, n362, n363, n364, n365, n366, n367, n368, n369,
         n370, n371, n372, n373, n374, n375, n376, n377, n378, n379, n380,
         n381, n382, n383, n384, n385, n386, n387, n388, n389, n390, n391,
         n392, n393, n394, n395, n396, n397, n398, n399, n400, n401, n402,
         n403, n404, n405, n406, n407, n408, n409, n410, n411, n412, n413,
         n414, n415, n416, n417, n418, n419, n420, n421, n422, n423, n424,
         n425, n426, n427, n428, n429, n430, n431, n432, n433, n434, n435,
         n436, n437, n438, n439, n440, n441, n442, n443, n444, n445, n446,
         n447, n448, n449, n450, n451, n452, n453, n454, n455, n456, n457,
         n458, n459, n460, n461, n462, n463, n464, n465, n466, n467, n468,
         n469, n470, n471, n472, n473, n474, n475, n476, n477, n478, n479,
         n480, n481, n482, n483, n484, n485, n486, n487, n488, n489, n490,
         n491, n492, n493, n494, n495, n496, n497, n498, n499, n500, n502,
         n503, n504, n505, n508, n510, n511, n512, n513, n514, n515, n516,
         n517, n518, n519, n520, n521, n522, n523, n524, n525, n526, n527,
         n528, n529, n530, n531, n532, n533, n534, n535, n536, n537, n538,
         n539, n540, n541, n542, n543, n544, n545, n546, n547, n548, n549,
         n550, n551, n552, n553, n554, n555, n556, n557, n558, n559, n560,
         n561, n562, n563, n564, n565, n566, n567, n568, n569, n570, n571,
         n572, n573, n574, n575, n576, n577, n578, n579, n580, n581, n582,
         n583, n584, n585, n586, n587, n588, n589, n590, n591, n592, n593,
         n594, n595, n596, n597, n598, n599, n600, n601, n602, n603, n604,
         n605, n606, n607, n608, n609, n610, n611, n612, n613, n614, n615,
         n616, n617, n618, n619, n620, n621, n622, n623, n624, n625, n626,
         n627, n628, n629, n630, n631, n632, n633, n634, n635, n636, n637,
         n638, n639, n640, n641, n642, n643, n644, n645, n646, n647, n648,
         n649, n650, n651, n652, n653, n654, n655, n656, n657, n658, n659,
         n660, n661, n662, n663, n664, n665, n666, n667, n668, n669, n670,
         n671, n672, n673, n674, n675, n676, n677, n678, n679, n680, n681,
         n682, n683, n684, n685, n686, n687, n688, n689, n690, n691, n692,
         n693, n694, n695, n696, n697, n698, n699, n700, n701, n702, n703,
         n704, n705, n706, n707, n708, n709, n710, n711, n712, n713, n714,
         n715, n716, n717, n718, n719, n720, n721, n722, n723, n724, n725,
         n726, n727, n728, n729, n730, n731, n732, n733, n734, n735, n736,
         n737, n738, n739, n740, n741, n742, n743, n744, n745, n746, n747,
         n748, n749, n750, n751, n752, n753, n754, n755, n756, n757, n758,
         n759, n760, n761, n762, n763, n764, n765, n766, n767, n768, n769,
         n770, n771, n772, n773, n774, n775, n776, n777, n778, n779, n780,
         n781, n782, n783, n784, n785, n786, n787, n788, n789, n790, n791,
         n792, n793, n794, n795, n796, n797, n798, n799, n800, n801, n802,
         n803, n804, n805, n806, n807, n808, n809, n810, n811, n812, n813,
         n814, n815, n816, n817, n818, n819, n820, n821, n822, n823, n824,
         n825, n826, n827, n828, n829, n830, n831, n832, n833, n834, n835,
         n836, n837, n838, n839, n840, n841, n842, n843, n844, n845, n846,
         n847, n848, n849, n850, n851, n852, n853, n854, n855, n856, n857,
         n858, n859, n860, n861, n862, n863, n864, n865, n866, n867, n868,
         n869, n870, n871, n872, n873, n874, n875, n876, n877, n878, n879,
         n880, n881, n882, n883, n884, n885, n886, n887, n888, n889, n890,
         n891, n892, n893, n894, n895, n896, n897, n898, n899, n900, n901,
         n902, n903, n904, n905, n906, n907, n908, n909, n910, n911, n912,
         n913, n914, n915, n916, n917, n918, n919, n920, n921, n922, n923,
         n924, n925, n926, n927, n928, n929, n930, n931, n932, n933, n934,
         n935, n936, n937, n938, n939, n940, n941, n942, n943, n944, n945,
         n946, n947, n948, n949, n950, n951, n952, n953, n954, n955, n956,
         n957, n958, n959, n960, n961, n962, n963, n964, n965, n966, n967,
         n968, n969, n970, n971, n972, n973, n974, n975, n976, n977, n978,
         n979, n980, n981, n982, n983, n984, n985, n986, n987, n988, n989,
         n990, n991, n992, n993, n994, n995, n996, n997, n998, n999, n1000,
         n1001, n1002, n1003, n1004, n1005, n1006, n1007, n1008, n1009, n1010,
         n1011, n1012, n1013, n1014, n1015, n1016, n1017, n1018, n1019, n1020,
         n1021, n1022, n1023, n1024, n1025, n1026, n1027, n1028, n1029, n1030,
         n1031, n1032, n1033, n1034, n1035, n1036, n1037, n1038, n1039, n1040,
         n1041, n1042, n1043, n1044, n1045, n1046, n1047, n1048, n1049, n1050,
         n1051, n1052, n1053, n1054, n1055, n1056, n1057, n1058, n1059, n1060,
         n1061, n1062, n1063, n1064, n1065, n1066, n1067, n1068, n1069, n1070,
         n1071, n1072, n1073, n1074, n1075, n1076, n1077, n1078, n1079, n1080,
         n1081, n1082, n1083, n1084, n1085, n1086, n1087, n1088, n1089, n1090,
         n1091, n1092, n1093, n1094, n1095, n1096, n1097, n1098, n1099, n1100,
         n1101, n1102, n1103, n1104, n1105, n1106, n1107, n1108, n1109, n1110,
         n1111, n1112, n1113, n1114, n1115, n1116, n1117, n1118, n1119, n1120,
         n1121, n1122, n1123, n1124, n1125, n1126, n1127, n1128, n1129, n1130,
         n1131, n1132, n1133, n1134, n1135, n1136, n1137, n1138, n1139, n1140,
         n1141, n1142, n1143, n1144, n1145, n1146, n1147, n1148, n1149, n1150,
         n1151, n1152, n1153, n1154, n1155, n1156, n1157, n1158, n1159, n1160,
         n1161, n1162, n1163, n1164, n1165, n1166, n1167, n1168, n1169, n1170,
         n1171, n1172, n1173, n1174, n1175, n1176, n1177, n1178, n1179, n1180,
         n1181, n1182, n1183, n1184, n1185, n1186, n1187, n1188, n1189, n1190,
         n1191, n1192, n1193, n1194, n1195, n1196, n1197, n1198, n1199, n1200,
         n1201, n1202, n1203, n1204, n1205, n1206, n1207, n1208, n1209, n1210,
         n1211, n1212, n1213, n1214, n1215, n1216, n1217, n1218, n1219, n1220,
         n1221, n1222, n1223, n1224, n1225, n1226, n1227, n1228, n1229, n1230,
         n1231, n1232, n1233, n1234, n1235, n1236, n1237, n1238, n1239, n1240,
         n1241, n1242, n1243, n1244, n1245, n1246, n1247, n1248, n1249, n1250,
         n1251, n1252, n1253, n1254, n1255, n1256, n1257, n1258, n1259, n1260,
         n1261, n1262, n1263, n1264, n1265, n1266, n1267, n1268, n1269, n1270,
         n1271, n1272, n1273, n1274, n1275, n1276, n1277, n1278, n1279, n1280,
         n1281, n1282, n1283, n1284, n1285, n1286, n1287, n1288, n1289, n1290,
         n1291, n1292, n1293, n1294, n1295, n1296, n1297, n1298, n1299, n1300,
         n1301, n1302, n1303, n1304, n1305, n1306, n1307, n1308, n1309, n1310,
         n1311, n1312, n1313, n1314, n1315, n1316, n1317, n1318, n1319, n1320,
         n1321, n1322, n1323, n1324, n1325, n1326, n1327, n1328, n1329, n1330,
         n1331, n1332, n1333, n1334, n1335, n1336, n1337, n1338, n1339, n1340,
         n1341, n1342, n1343, n1344, n1345, n1346, n1347, n1348, n1349, n1350,
         n1351, n1352, n1353, n1354, n1355, n1356, n1357, n1358, n1359, n1360,
         n1361, n1362, n1363, n1364, n1365, n1366, n1367, n1368, n1369, n1370,
         n1371, n1372, n1373, n1374, n1375, n1376, n1377, n1378, n1379, n1380,
         n1381, n1382, n1383, n1384, n1385, n1386, n1387, n1388, n1389, n1390,
         n1391, n1392, n1393, n1394, n1395, n1396, n1397, n1398, n1399, n1400,
         n1401, n1402, n1403, n1404, n1405, n1406, n1407, n1408, n1409, n1410,
         n1411, n1412, n1413, n1414, n1415, n1416, n1417, n1418, n1419, n1420,
         n1421, n1422, n1423, n1424, n1425, n1426, n1427, n1428, n1429, n1430,
         n1431, n1432, n1433, n1434, n1435, n1436, n1437, n1438, n1439, n1440,
         n1441, n1442, n1443, n1444, n1445, n1446, n1447, n1448, n1449, n1450,
         n1451, n1452, n1453, n1454, n1455, n1456, n1457;
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
        s_cnt_d), .dat_o({n1459, n1460, n1461, cnt_o[3:0]}) );
  dffr_DATA_WIDTH576 u_mem_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(
        s_mem_d), .dat_o(s_mem_q) );
  fifo_DATA_WIDTH9_BUFFER_DEPTH64_DW01_inc_3 add_81 ( .A(cnt_o), .SUM({N114, 
        N113, N112, N111, N110, N109, N108}) );
  sky130_fd_sc_hd__inv_2 U3 ( .A(n609), .Y(n1342) );
  sky130_fd_sc_hd__nand2_1 U4 ( .A(n1453), .B(n1443), .Y(n6) );
  sky130_fd_sc_hd__nand2_1 U5 ( .A(n1453), .B(n1443), .Y(n590) );
  sky130_fd_sc_hd__inv_2 U6 ( .A(n500), .Y(cnt_o[6]) );
  sky130_fd_sc_hd__inv_2 U7 ( .A(n559), .Y(n1453) );
  sky130_fd_sc_hd__nand2_1 U8 ( .A(n565), .B(n1442), .Y(n559) );
  sky130_fd_sc_hd__inv_2 U9 ( .A(n1370), .Y(n1380) );
  sky130_fd_sc_hd__inv_2 U10 ( .A(n1344), .Y(n1354) );
  sky130_fd_sc_hd__inv_1 U11 ( .A(n1404), .Y(n1395) );
  sky130_fd_sc_hd__clkinv_1 U12 ( .A(n1038), .Y(n1029) );
  sky130_fd_sc_hd__clkinv_1 U13 ( .A(n934), .Y(n925) );
  sky130_fd_sc_hd__clkinv_1 U14 ( .A(n909), .Y(n900) );
  sky130_fd_sc_hd__clkinv_1 U15 ( .A(n871), .Y(n862) );
  sky130_fd_sc_hd__clkinv_1 U16 ( .A(n715), .Y(n706) );
  sky130_fd_sc_hd__clkinv_1 U17 ( .A(n661), .Y(n652) );
  sky130_fd_sc_hd__and3_2 U18 ( .A(s_wr_ptr_q[3]), .B(n1444), .C(n1445), .X(n1) );
  sky130_fd_sc_hd__and3_2 U19 ( .A(s_wr_ptr_q[4]), .B(n1444), .C(n1446), .X(n2) );
  sky130_fd_sc_hd__inv_2 U20 ( .A(n1460), .Y(n508) );
  sky130_fd_sc_hd__and3_2 U21 ( .A(s_wr_ptr_q[0]), .B(n1447), .C(n1449), .X(n3) );
  sky130_fd_sc_hd__inv_1 U22 ( .A(N77), .Y(n448) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(N80), .Y(n450) );
  sky130_fd_sc_hd__buf_6 U24 ( .A(n432), .X(n492) );
  sky130_fd_sc_hd__and2_4 U25 ( .A(n33), .B(n29), .X(n432) );
  sky130_fd_sc_hd__buf_6 U26 ( .A(n431), .X(n489) );
  sky130_fd_sc_hd__buf_6 U27 ( .A(n430), .X(n486) );
  sky130_fd_sc_hd__and2_1 U28 ( .A(n31), .B(n28), .X(n430) );
  sky130_fd_sc_hd__buf_6 U29 ( .A(n429), .X(n483) );
  sky130_fd_sc_hd__buf_6 U30 ( .A(n434), .X(n498) );
  sky130_fd_sc_hd__and2_1 U31 ( .A(n33), .B(n31), .X(n434) );
  sky130_fd_sc_hd__buf_6 U32 ( .A(n433), .X(n495) );
  sky130_fd_sc_hd__a2bb2o_1 U33 ( .A1_N(n1454), .A2_N(n448), .B1(N86), .B2(
        n1453), .X(s_rd_ptr_d[2]) );
  sky130_fd_sc_hd__inv_1 U34 ( .A(cnt_o[1]), .Y(n554) );
  sky130_fd_sc_hd__inv_2 U35 ( .A(cnt_o[3]), .Y(n552) );
  sky130_fd_sc_hd__nand2_1 U36 ( .A(n1453), .B(n1443), .Y(n5) );
  sky130_fd_sc_hd__and4_1 U37 ( .A(n581), .B(n552), .C(n1456), .D(n508), .X(n4) );
  sky130_fd_sc_hd__and4_2 U38 ( .A(n581), .B(n552), .C(n1456), .D(n508), .X(
        n556) );
  sky130_fd_sc_hd__o2bb2ai_1 U39 ( .B1(n565), .B2(n1443), .A1_N(n1454), .A2_N(
        n1451), .Y(n585) );
  sky130_fd_sc_hd__inv_4 U40 ( .A(n1443), .Y(n504) );
  sky130_fd_sc_hd__inv_2 U41 ( .A(n1383), .Y(n1393) );
  sky130_fd_sc_hd__inv_2 U42 ( .A(n1407), .Y(n1417) );
  sky130_fd_sc_hd__o2bb2ai_1 U43 ( .B1(n1438), .B2(n1353), .A1_N(n1344), 
        .A2_N(s_mem_q[54]), .Y(s_mem_d[54]) );
  sky130_fd_sc_hd__o2bb2ai_1 U44 ( .B1(n1438), .B2(n1366), .A1_N(n1357), 
        .A2_N(s_mem_q[45]), .Y(s_mem_d[45]) );
  sky130_fd_sc_hd__o2bb2ai_1 U45 ( .B1(n1438), .B2(n1379), .A1_N(n1370), 
        .A2_N(s_mem_q[36]), .Y(s_mem_d[36]) );
  sky130_fd_sc_hd__o2bb2ai_1 U46 ( .B1(n1438), .B2(n1392), .A1_N(n1383), 
        .A2_N(s_mem_q[27]), .Y(s_mem_d[27]) );
  sky130_fd_sc_hd__o2bb2ai_1 U47 ( .B1(n1438), .B2(n1416), .A1_N(n1407), 
        .A2_N(s_mem_q[9]), .Y(s_mem_d[9]) );
  sky130_fd_sc_hd__nand2_8 U48 ( .A(dat_i[0]), .B(n504), .Y(n1438) );
  sky130_fd_sc_hd__and2_4 U49 ( .A(n900), .B(n504), .X(n11) );
  sky130_fd_sc_hd__clkinv_2 U50 ( .A(n1327), .Y(n1418) );
  sky130_fd_sc_hd__inv_2 U51 ( .A(n651), .Y(n1381) );
  sky130_fd_sc_hd__inv_2 U52 ( .A(n1015), .Y(n1105) );
  sky130_fd_sc_hd__nand2_1 U53 ( .A(n899), .B(n18), .Y(n909) );
  sky130_fd_sc_hd__nand2_1 U54 ( .A(n691), .B(n1381), .Y(n661) );
  sky130_fd_sc_hd__clkinv_2 U55 ( .A(n663), .Y(n1394) );
  sky130_fd_sc_hd__inv_2 U56 ( .A(n595), .Y(n1328) );
  sky130_fd_sc_hd__nand3_2 U57 ( .A(n7), .B(n8), .C(n9), .Y(n10) );
  sky130_fd_sc_hd__nand2_4 U58 ( .A(n10), .B(push_i), .Y(n1443) );
  sky130_fd_sc_hd__inv_1 U59 ( .A(n561), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U60 ( .A(n560), .Y(n8) );
  sky130_fd_sc_hd__inv_1 U61 ( .A(n553), .Y(n9) );
  sky130_fd_sc_hd__nand2_1 U62 ( .A(n567), .B(n508), .Y(n560) );
  sky130_fd_sc_hd__nand3_1 U63 ( .A(n554), .B(n572), .C(n552), .Y(n553) );
  sky130_fd_sc_hd__clkinv_1 U64 ( .A(n1439), .Y(n1419) );
  sky130_fd_sc_hd__clkinv_1 U65 ( .A(n1116), .Y(n1106) );
  sky130_fd_sc_hd__and2_1 U66 ( .A(n652), .B(n504), .X(n13) );
  sky130_fd_sc_hd__and2_1 U67 ( .A(n1395), .B(n504), .X(n17) );
  sky130_fd_sc_hd__and2_1 U68 ( .A(n706), .B(n504), .X(n12) );
  sky130_fd_sc_hd__and2_1 U69 ( .A(n1029), .B(n504), .X(n15) );
  sky130_fd_sc_hd__and2_1 U70 ( .A(n925), .B(n504), .X(n16) );
  sky130_fd_sc_hd__and2_1 U71 ( .A(n862), .B(n504), .X(n14) );
  sky130_fd_sc_hd__buf_2 U72 ( .A(n1422), .X(n512) );
  sky130_fd_sc_hd__buf_2 U73 ( .A(n1436), .X(n551) );
  sky130_fd_sc_hd__buf_2 U74 ( .A(n1434), .X(n546) );
  sky130_fd_sc_hd__buf_2 U75 ( .A(n1432), .X(n541) );
  sky130_fd_sc_hd__buf_2 U76 ( .A(n1430), .X(n536) );
  sky130_fd_sc_hd__buf_2 U77 ( .A(n1428), .X(n531) );
  sky130_fd_sc_hd__buf_2 U78 ( .A(n1426), .X(n526) );
  sky130_fd_sc_hd__buf_2 U79 ( .A(n1424), .X(n521) );
  sky130_fd_sc_hd__nand2_1 U80 ( .A(n899), .B(n1381), .Y(n871) );
  sky130_fd_sc_hd__nand2_1 U81 ( .A(n691), .B(n18), .Y(n702) );
  sky130_fd_sc_hd__nand2_1 U82 ( .A(n2), .B(n18), .Y(n1220) );
  sky130_fd_sc_hd__nand2_1 U83 ( .A(n1001), .B(n18), .Y(n1012) );
  sky130_fd_sc_hd__nand2_1 U84 ( .A(n795), .B(n18), .Y(n806) );
  sky130_fd_sc_hd__nand2_1 U85 ( .A(n1), .B(n18), .Y(n1324) );
  sky130_fd_sc_hd__nand2_1 U86 ( .A(n1368), .B(n1418), .Y(n1379) );
  sky130_fd_sc_hd__nand2_1 U87 ( .A(n1342), .B(n1418), .Y(n1353) );
  sky130_fd_sc_hd__nand2_1 U88 ( .A(n2), .B(n1381), .Y(n1181) );
  sky130_fd_sc_hd__nand2_1 U89 ( .A(n1001), .B(n1381), .Y(n972) );
  sky130_fd_sc_hd__nand2_1 U90 ( .A(n795), .B(n1381), .Y(n766) );
  sky130_fd_sc_hd__nand2_1 U91 ( .A(n1355), .B(n1418), .Y(n1366) );
  sky130_fd_sc_hd__nand2_1 U92 ( .A(n1), .B(n1381), .Y(n1285) );
  sky130_fd_sc_hd__and2_1 U93 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[1]), .X(n19)
         );
  sky130_fd_sc_hd__clkinv_2 U94 ( .A(n911), .Y(n1001) );
  sky130_fd_sc_hd__clkinv_2 U95 ( .A(n705), .Y(n795) );
  sky130_fd_sc_hd__clkinv_2 U96 ( .A(n809), .Y(n899) );
  sky130_fd_sc_hd__and2_1 U97 ( .A(s_wr_ptr_q[4]), .B(s_wr_ptr_q[3]), .X(n21)
         );
  sky130_fd_sc_hd__clkinv_1 U98 ( .A(N75), .Y(n446) );
  sky130_fd_sc_hd__inv_2 U99 ( .A(n557), .Y(n592) );
  sky130_fd_sc_hd__inv_1 U100 ( .A(n576), .Y(n582) );
  sky130_fd_sc_hd__inv_1 U101 ( .A(n593), .Y(n587) );
  sky130_fd_sc_hd__inv_2 U102 ( .A(n1392), .Y(n1382) );
  sky130_fd_sc_hd__inv_2 U103 ( .A(n1067), .Y(n1078) );
  sky130_fd_sc_hd__inv_2 U104 ( .A(n1076), .Y(n1066) );
  sky130_fd_sc_hd__inv_2 U105 ( .A(n1107), .Y(n1118) );
  sky130_fd_sc_hd__inv_2 U106 ( .A(n1421), .Y(n1441) );
  sky130_fd_sc_hd__nand2_1 U107 ( .A(pop_i), .B(n1455), .Y(n558) );
  sky130_fd_sc_hd__buf_2 U108 ( .A(n428), .X(n480) );
  sky130_fd_sc_hd__inv_1 U109 ( .A(n568), .Y(n573) );
  sky130_fd_sc_hd__buf_2 U110 ( .A(n422), .X(n474) );
  sky130_fd_sc_hd__buf_2 U111 ( .A(n418), .X(n462) );
  sky130_fd_sc_hd__buf_2 U112 ( .A(n420), .X(n468) );
  sky130_fd_sc_hd__buf_2 U113 ( .A(n421), .X(n471) );
  sky130_fd_sc_hd__buf_2 U114 ( .A(n417), .X(n459) );
  sky130_fd_sc_hd__buf_2 U115 ( .A(n416), .X(n456) );
  sky130_fd_sc_hd__buf_2 U116 ( .A(n427), .X(n477) );
  sky130_fd_sc_hd__buf_2 U117 ( .A(n419), .X(n465) );
  sky130_fd_sc_hd__inv_2 U118 ( .A(n597), .Y(n607) );
  sky130_fd_sc_hd__inv_2 U119 ( .A(n608), .Y(n596) );
  sky130_fd_sc_hd__inv_2 U120 ( .A(n1330), .Y(n1341) );
  sky130_fd_sc_hd__inv_2 U121 ( .A(n1339), .Y(n1329) );
  sky130_fd_sc_hd__inv_2 U122 ( .A(n1416), .Y(n1406) );
  sky130_fd_sc_hd__inv_2 U123 ( .A(n1379), .Y(n1369) );
  sky130_fd_sc_hd__inv_2 U124 ( .A(n1353), .Y(n1343) );
  sky130_fd_sc_hd__inv_2 U125 ( .A(n1093), .Y(n1104) );
  sky130_fd_sc_hd__inv_2 U126 ( .A(n1102), .Y(n1092) );
  sky130_fd_sc_hd__inv_2 U127 ( .A(n1080), .Y(n1091) );
  sky130_fd_sc_hd__inv_2 U128 ( .A(n1089), .Y(n1079) );
  sky130_fd_sc_hd__inv_2 U129 ( .A(n1041), .Y(n1052) );
  sky130_fd_sc_hd__inv_2 U130 ( .A(n1050), .Y(n1040) );
  sky130_fd_sc_hd__inv_2 U131 ( .A(n1017), .Y(n1028) );
  sky130_fd_sc_hd__inv_2 U132 ( .A(n1026), .Y(n1016) );
  sky130_fd_sc_hd__inv_2 U133 ( .A(n693), .Y(n704) );
  sky130_fd_sc_hd__inv_2 U134 ( .A(n702), .Y(n692) );
  sky130_fd_sc_hd__inv_2 U135 ( .A(n665), .Y(n676) );
  sky130_fd_sc_hd__inv_2 U136 ( .A(n674), .Y(n664) );
  sky130_fd_sc_hd__inv_2 U137 ( .A(n639), .Y(n650) );
  sky130_fd_sc_hd__inv_2 U138 ( .A(n648), .Y(n638) );
  sky130_fd_sc_hd__inv_2 U139 ( .A(n611), .Y(n622) );
  sky130_fd_sc_hd__inv_2 U140 ( .A(n620), .Y(n610) );
  sky130_fd_sc_hd__inv_2 U141 ( .A(n1315), .Y(n1326) );
  sky130_fd_sc_hd__inv_2 U142 ( .A(n1324), .Y(n1314) );
  sky130_fd_sc_hd__inv_2 U143 ( .A(n1302), .Y(n1313) );
  sky130_fd_sc_hd__inv_2 U144 ( .A(n1311), .Y(n1301) );
  sky130_fd_sc_hd__inv_2 U145 ( .A(n1263), .Y(n1274) );
  sky130_fd_sc_hd__inv_2 U146 ( .A(n1272), .Y(n1262) );
  sky130_fd_sc_hd__inv_2 U147 ( .A(n1250), .Y(n1261) );
  sky130_fd_sc_hd__inv_2 U148 ( .A(n1259), .Y(n1249) );
  sky130_fd_sc_hd__inv_2 U149 ( .A(n1211), .Y(n1222) );
  sky130_fd_sc_hd__inv_2 U150 ( .A(n1220), .Y(n1210) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(n1172), .Y(n1183) );
  sky130_fd_sc_hd__inv_2 U152 ( .A(n1181), .Y(n1171) );
  sky130_fd_sc_hd__inv_2 U153 ( .A(n1159), .Y(n1170) );
  sky130_fd_sc_hd__inv_2 U154 ( .A(n1168), .Y(n1158) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(n1146), .Y(n1157) );
  sky130_fd_sc_hd__inv_2 U156 ( .A(n1155), .Y(n1145) );
  sky130_fd_sc_hd__inv_2 U157 ( .A(n1133), .Y(n1144) );
  sky130_fd_sc_hd__inv_2 U158 ( .A(n1142), .Y(n1132) );
  sky130_fd_sc_hd__inv_2 U159 ( .A(n1120), .Y(n1131) );
  sky130_fd_sc_hd__inv_2 U160 ( .A(n1129), .Y(n1119) );
  sky130_fd_sc_hd__inv_2 U161 ( .A(n1003), .Y(n1014) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(n1012), .Y(n1002) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(n989), .Y(n1000) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(n998), .Y(n988) );
  sky130_fd_sc_hd__inv_2 U165 ( .A(n976), .Y(n987) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(n985), .Y(n975) );
  sky130_fd_sc_hd__inv_2 U167 ( .A(n963), .Y(n974) );
  sky130_fd_sc_hd__inv_2 U168 ( .A(n972), .Y(n962) );
  sky130_fd_sc_hd__inv_2 U169 ( .A(n950), .Y(n961) );
  sky130_fd_sc_hd__inv_2 U170 ( .A(n959), .Y(n949) );
  sky130_fd_sc_hd__inv_2 U171 ( .A(n937), .Y(n948) );
  sky130_fd_sc_hd__inv_2 U172 ( .A(n946), .Y(n936) );
  sky130_fd_sc_hd__inv_2 U173 ( .A(n887), .Y(n898) );
  sky130_fd_sc_hd__inv_2 U174 ( .A(n896), .Y(n886) );
  sky130_fd_sc_hd__inv_2 U175 ( .A(n874), .Y(n885) );
  sky130_fd_sc_hd__inv_2 U176 ( .A(n883), .Y(n873) );
  sky130_fd_sc_hd__inv_2 U177 ( .A(n850), .Y(n861) );
  sky130_fd_sc_hd__inv_2 U178 ( .A(n859), .Y(n849) );
  sky130_fd_sc_hd__inv_2 U179 ( .A(n837), .Y(n848) );
  sky130_fd_sc_hd__inv_2 U180 ( .A(n846), .Y(n836) );
  sky130_fd_sc_hd__inv_2 U181 ( .A(n824), .Y(n835) );
  sky130_fd_sc_hd__inv_2 U182 ( .A(n833), .Y(n823) );
  sky130_fd_sc_hd__inv_2 U183 ( .A(n811), .Y(n822) );
  sky130_fd_sc_hd__inv_2 U184 ( .A(n820), .Y(n810) );
  sky130_fd_sc_hd__inv_2 U185 ( .A(n783), .Y(n794) );
  sky130_fd_sc_hd__inv_2 U186 ( .A(n792), .Y(n782) );
  sky130_fd_sc_hd__inv_2 U187 ( .A(n770), .Y(n781) );
  sky130_fd_sc_hd__inv_2 U188 ( .A(n779), .Y(n769) );
  sky130_fd_sc_hd__inv_2 U189 ( .A(n757), .Y(n768) );
  sky130_fd_sc_hd__inv_2 U190 ( .A(n766), .Y(n756) );
  sky130_fd_sc_hd__inv_2 U191 ( .A(n744), .Y(n755) );
  sky130_fd_sc_hd__inv_2 U192 ( .A(n753), .Y(n743) );
  sky130_fd_sc_hd__inv_2 U193 ( .A(n718), .Y(n729) );
  sky130_fd_sc_hd__inv_2 U194 ( .A(n727), .Y(n717) );
  sky130_fd_sc_hd__inv_2 U195 ( .A(n1357), .Y(n1367) );
  sky130_fd_sc_hd__inv_2 U196 ( .A(n1366), .Y(n1356) );
  sky130_fd_sc_hd__inv_2 U197 ( .A(n1054), .Y(n1065) );
  sky130_fd_sc_hd__inv_2 U198 ( .A(n1063), .Y(n1053) );
  sky130_fd_sc_hd__inv_2 U199 ( .A(n678), .Y(n689) );
  sky130_fd_sc_hd__inv_2 U200 ( .A(n687), .Y(n677) );
  sky130_fd_sc_hd__inv_2 U201 ( .A(n625), .Y(n636) );
  sky130_fd_sc_hd__inv_2 U202 ( .A(n634), .Y(n624) );
  sky130_fd_sc_hd__inv_2 U203 ( .A(n1289), .Y(n1300) );
  sky130_fd_sc_hd__inv_2 U204 ( .A(n1298), .Y(n1288) );
  sky130_fd_sc_hd__inv_2 U205 ( .A(n1276), .Y(n1287) );
  sky130_fd_sc_hd__inv_2 U206 ( .A(n1285), .Y(n1275) );
  sky130_fd_sc_hd__inv_2 U207 ( .A(n1237), .Y(n1248) );
  sky130_fd_sc_hd__inv_2 U208 ( .A(n1246), .Y(n1236) );
  sky130_fd_sc_hd__inv_2 U209 ( .A(n1224), .Y(n1235) );
  sky130_fd_sc_hd__inv_2 U210 ( .A(n1233), .Y(n1223) );
  sky130_fd_sc_hd__inv_2 U211 ( .A(n1198), .Y(n1209) );
  sky130_fd_sc_hd__inv_2 U212 ( .A(n1207), .Y(n1197) );
  sky130_fd_sc_hd__inv_2 U213 ( .A(n1185), .Y(n1196) );
  sky130_fd_sc_hd__inv_2 U214 ( .A(n1194), .Y(n1184) );
  sky130_fd_sc_hd__inv_2 U215 ( .A(n913), .Y(n924) );
  sky130_fd_sc_hd__inv_2 U216 ( .A(n922), .Y(n912) );
  sky130_fd_sc_hd__inv_2 U217 ( .A(n797), .Y(n808) );
  sky130_fd_sc_hd__inv_2 U218 ( .A(n806), .Y(n796) );
  sky130_fd_sc_hd__inv_2 U219 ( .A(n731), .Y(n742) );
  sky130_fd_sc_hd__inv_2 U220 ( .A(n740), .Y(n730) );
  sky130_fd_sc_hd__buf_2 U221 ( .A(n415), .X(n453) );
  sky130_fd_sc_hd__nand2_1 U222 ( .A(n1105), .B(n18), .Y(n1116) );
  sky130_fd_sc_hd__nand2_1 U223 ( .A(n1105), .B(n1381), .Y(n1076) );
  sky130_fd_sc_hd__nand2_1 U224 ( .A(n18), .B(n1418), .Y(n1439) );
  sky130_fd_sc_hd__nand2_1 U225 ( .A(n1381), .B(n1418), .Y(n1392) );
  sky130_fd_sc_hd__and2_1 U226 ( .A(n503), .B(n556), .X(empty_o) );
  sky130_fd_sc_hd__clkbuf_1 U227 ( .A(n418), .X(n461) );
  sky130_fd_sc_hd__clkbuf_1 U228 ( .A(n420), .X(n467) );
  sky130_fd_sc_hd__clkbuf_1 U229 ( .A(n422), .X(n473) );
  sky130_fd_sc_hd__clkbuf_1 U230 ( .A(n416), .X(n455) );
  sky130_fd_sc_hd__clkbuf_1 U231 ( .A(n430), .X(n485) );
  sky130_fd_sc_hd__clkbuf_1 U232 ( .A(n432), .X(n491) );
  sky130_fd_sc_hd__clkbuf_1 U233 ( .A(n434), .X(n497) );
  sky130_fd_sc_hd__clkbuf_1 U234 ( .A(n428), .X(n479) );
  sky130_fd_sc_hd__clkbuf_1 U235 ( .A(n417), .X(n458) );
  sky130_fd_sc_hd__clkbuf_1 U236 ( .A(n419), .X(n464) );
  sky130_fd_sc_hd__clkbuf_1 U237 ( .A(n421), .X(n470) );
  sky130_fd_sc_hd__clkbuf_1 U238 ( .A(n415), .X(n452) );
  sky130_fd_sc_hd__clkbuf_1 U239 ( .A(n429), .X(n482) );
  sky130_fd_sc_hd__clkbuf_1 U240 ( .A(n431), .X(n488) );
  sky130_fd_sc_hd__clkbuf_1 U241 ( .A(n433), .X(n494) );
  sky130_fd_sc_hd__clkbuf_1 U242 ( .A(n427), .X(n476) );
  sky130_fd_sc_hd__clkbuf_1 U243 ( .A(n418), .X(n460) );
  sky130_fd_sc_hd__clkbuf_1 U244 ( .A(n420), .X(n466) );
  sky130_fd_sc_hd__clkbuf_1 U245 ( .A(n422), .X(n472) );
  sky130_fd_sc_hd__clkbuf_1 U246 ( .A(n416), .X(n454) );
  sky130_fd_sc_hd__clkbuf_1 U247 ( .A(n430), .X(n484) );
  sky130_fd_sc_hd__clkbuf_1 U248 ( .A(n432), .X(n490) );
  sky130_fd_sc_hd__clkbuf_1 U249 ( .A(n434), .X(n496) );
  sky130_fd_sc_hd__clkbuf_1 U250 ( .A(n428), .X(n478) );
  sky130_fd_sc_hd__clkbuf_1 U251 ( .A(n417), .X(n457) );
  sky130_fd_sc_hd__clkbuf_1 U252 ( .A(n419), .X(n463) );
  sky130_fd_sc_hd__clkbuf_1 U253 ( .A(n421), .X(n469) );
  sky130_fd_sc_hd__clkbuf_1 U254 ( .A(n415), .X(n451) );
  sky130_fd_sc_hd__clkbuf_1 U255 ( .A(n429), .X(n481) );
  sky130_fd_sc_hd__clkbuf_1 U256 ( .A(n431), .X(n487) );
  sky130_fd_sc_hd__clkbuf_1 U257 ( .A(n433), .X(n493) );
  sky130_fd_sc_hd__clkbuf_1 U258 ( .A(n427), .X(n475) );
  sky130_fd_sc_hd__inv_2 U259 ( .A(n1451), .Y(n1448) );
  sky130_fd_sc_hd__buf_2 U260 ( .A(n1436), .X(n550) );
  sky130_fd_sc_hd__buf_2 U261 ( .A(n1434), .X(n545) );
  sky130_fd_sc_hd__buf_2 U262 ( .A(n1432), .X(n540) );
  sky130_fd_sc_hd__buf_2 U263 ( .A(n1430), .X(n535) );
  sky130_fd_sc_hd__buf_2 U264 ( .A(n1428), .X(n530) );
  sky130_fd_sc_hd__buf_2 U265 ( .A(n1426), .X(n525) );
  sky130_fd_sc_hd__buf_2 U266 ( .A(n1424), .X(n520) );
  sky130_fd_sc_hd__buf_2 U267 ( .A(n1422), .X(n515) );
  sky130_fd_sc_hd__buf_2 U268 ( .A(n1436), .X(n549) );
  sky130_fd_sc_hd__buf_2 U269 ( .A(n1434), .X(n544) );
  sky130_fd_sc_hd__buf_2 U270 ( .A(n1432), .X(n539) );
  sky130_fd_sc_hd__buf_2 U271 ( .A(n1430), .X(n534) );
  sky130_fd_sc_hd__buf_2 U272 ( .A(n1428), .X(n529) );
  sky130_fd_sc_hd__buf_2 U273 ( .A(n1426), .X(n524) );
  sky130_fd_sc_hd__buf_2 U274 ( .A(n1424), .X(n519) );
  sky130_fd_sc_hd__buf_2 U275 ( .A(n1422), .X(n514) );
  sky130_fd_sc_hd__buf_2 U276 ( .A(n1436), .X(n548) );
  sky130_fd_sc_hd__buf_2 U277 ( .A(n1434), .X(n543) );
  sky130_fd_sc_hd__buf_2 U278 ( .A(n1432), .X(n538) );
  sky130_fd_sc_hd__buf_2 U279 ( .A(n1430), .X(n533) );
  sky130_fd_sc_hd__buf_2 U280 ( .A(n1428), .X(n528) );
  sky130_fd_sc_hd__buf_2 U281 ( .A(n1426), .X(n523) );
  sky130_fd_sc_hd__buf_2 U282 ( .A(n1424), .X(n518) );
  sky130_fd_sc_hd__buf_2 U283 ( .A(n1422), .X(n513) );
  sky130_fd_sc_hd__buf_2 U284 ( .A(n1436), .X(n547) );
  sky130_fd_sc_hd__buf_2 U285 ( .A(n1434), .X(n542) );
  sky130_fd_sc_hd__buf_2 U286 ( .A(n1432), .X(n537) );
  sky130_fd_sc_hd__buf_2 U287 ( .A(n1430), .X(n532) );
  sky130_fd_sc_hd__buf_2 U288 ( .A(n1428), .X(n527) );
  sky130_fd_sc_hd__buf_2 U289 ( .A(n1426), .X(n522) );
  sky130_fd_sc_hd__buf_2 U290 ( .A(n1424), .X(n517) );
  sky130_fd_sc_hd__buf_2 U291 ( .A(n1422), .X(n516) );
  sky130_fd_sc_hd__buf_2 U292 ( .A(n567), .X(n505) );
  sky130_fd_sc_hd__nand2_1 U293 ( .A(n691), .B(n1328), .Y(n608) );
  sky130_fd_sc_hd__and3_1 U294 ( .A(n1449), .B(n1447), .C(n690), .X(n18) );
  sky130_fd_sc_hd__nand2_1 U295 ( .A(n1105), .B(n3), .Y(n1102) );
  sky130_fd_sc_hd__nand2_1 U296 ( .A(n1105), .B(n1394), .Y(n1089) );
  sky130_fd_sc_hd__nand2_1 U297 ( .A(n691), .B(n1394), .Y(n674) );
  sky130_fd_sc_hd__nand2_1 U298 ( .A(n1), .B(n3), .Y(n1311) );
  sky130_fd_sc_hd__nand2_1 U299 ( .A(n1001), .B(n3), .Y(n998) );
  sky130_fd_sc_hd__nand2_1 U300 ( .A(n1001), .B(n1394), .Y(n985) );
  sky130_fd_sc_hd__nand2_1 U301 ( .A(n899), .B(n3), .Y(n896) );
  sky130_fd_sc_hd__nand2_1 U302 ( .A(n899), .B(n1394), .Y(n883) );
  sky130_fd_sc_hd__nand2_1 U303 ( .A(n795), .B(n3), .Y(n792) );
  sky130_fd_sc_hd__nand2_1 U304 ( .A(n795), .B(n1394), .Y(n779) );
  sky130_fd_sc_hd__nand2_1 U305 ( .A(n691), .B(n3), .Y(n687) );
  sky130_fd_sc_hd__nand2_1 U306 ( .A(n1), .B(n1394), .Y(n1298) );
  sky130_fd_sc_hd__nand2_1 U307 ( .A(n2), .B(n3), .Y(n1207) );
  sky130_fd_sc_hd__nand2_1 U308 ( .A(n2), .B(n1394), .Y(n1194) );
  sky130_fd_sc_hd__nand2_1 U309 ( .A(n795), .B(n1328), .Y(n715) );
  sky130_fd_sc_hd__nand2_1 U310 ( .A(n1105), .B(n1328), .Y(n1026) );
  sky130_fd_sc_hd__nand2_1 U311 ( .A(n2), .B(n1328), .Y(n1129) );
  sky130_fd_sc_hd__nand2_1 U312 ( .A(n899), .B(n1328), .Y(n820) );
  sky130_fd_sc_hd__nand2_1 U313 ( .A(n1), .B(n1328), .Y(n1233) );
  sky130_fd_sc_hd__nand2_1 U314 ( .A(n1001), .B(n1328), .Y(n922) );
  sky130_fd_sc_hd__nand2_1 U315 ( .A(n1105), .B(n1342), .Y(n1038) );
  sky130_fd_sc_hd__nand2_1 U316 ( .A(n1001), .B(n1342), .Y(n934) );
  sky130_fd_sc_hd__nand2_1 U317 ( .A(n691), .B(n1342), .Y(n620) );
  sky130_fd_sc_hd__nand2_1 U318 ( .A(n2), .B(n1342), .Y(n1142) );
  sky130_fd_sc_hd__nand2_1 U319 ( .A(n899), .B(n1342), .Y(n833) );
  sky130_fd_sc_hd__nand2_1 U320 ( .A(n795), .B(n1342), .Y(n727) );
  sky130_fd_sc_hd__nand2_1 U321 ( .A(n1), .B(n1342), .Y(n1246) );
  sky130_fd_sc_hd__nand2_1 U322 ( .A(n691), .B(n1368), .Y(n648) );
  sky130_fd_sc_hd__nand2_1 U323 ( .A(n1), .B(n1368), .Y(n1272) );
  sky130_fd_sc_hd__nand2_1 U324 ( .A(n2), .B(n1368), .Y(n1168) );
  sky130_fd_sc_hd__nand2_1 U325 ( .A(n1001), .B(n1368), .Y(n959) );
  sky130_fd_sc_hd__nand2_1 U326 ( .A(n899), .B(n1368), .Y(n859) );
  sky130_fd_sc_hd__nand2_1 U327 ( .A(n795), .B(n1368), .Y(n753) );
  sky130_fd_sc_hd__nand2_1 U328 ( .A(n1105), .B(n1368), .Y(n1063) );
  sky130_fd_sc_hd__nand2_1 U329 ( .A(n1394), .B(n1418), .Y(n1404) );
  sky130_fd_sc_hd__nand2_1 U330 ( .A(n3), .B(n1418), .Y(n1416) );
  sky130_fd_sc_hd__nand2_1 U331 ( .A(n1328), .B(n1418), .Y(n1339) );
  sky130_fd_sc_hd__nand2_1 U332 ( .A(n1105), .B(n1355), .Y(n1050) );
  sky130_fd_sc_hd__nand2_1 U333 ( .A(n1), .B(n1355), .Y(n1259) );
  sky130_fd_sc_hd__nand2_1 U334 ( .A(n2), .B(n1355), .Y(n1155) );
  sky130_fd_sc_hd__nand2_1 U335 ( .A(n1001), .B(n1355), .Y(n946) );
  sky130_fd_sc_hd__nand2_1 U336 ( .A(n899), .B(n1355), .Y(n846) );
  sky130_fd_sc_hd__nand2_1 U337 ( .A(n691), .B(n1355), .Y(n634) );
  sky130_fd_sc_hd__nand2_1 U338 ( .A(n795), .B(n1355), .Y(n740) );
  sky130_fd_sc_hd__inv_1 U339 ( .A(n1457), .Y(n586) );
  sky130_fd_sc_hd__nor2_1 U340 ( .A(n450), .B(n449), .Y(n390) );
  sky130_fd_sc_hd__nand3_1 U341 ( .A(n564), .B(n1442), .C(push_i), .Y(n1451)
         );
  sky130_fd_sc_hd__clkinv_1 U342 ( .A(N76), .Y(n447) );
  sky130_fd_sc_hd__o2bb2ai_1 U343 ( .B1(n499), .B2(n450), .A1_N(N89), .A2_N(
        n1453), .Y(s_rd_ptr_d[5]) );
  sky130_fd_sc_hd__ha_1 U344 ( .A(N76), .B(N75), .COUT(\add_50/carry[2] ), 
        .SUM(N85) );
  sky130_fd_sc_hd__ha_1 U345 ( .A(N78), .B(\add_50/carry[3] ), .COUT(
        \add_50/carry[4] ), .SUM(N87) );
  sky130_fd_sc_hd__ha_1 U346 ( .A(N77), .B(\add_50/carry[2] ), .COUT(
        \add_50/carry[3] ), .SUM(N86) );
  sky130_fd_sc_hd__ha_1 U347 ( .A(N79), .B(\add_50/carry[4] ), .COUT(
        \add_50/carry[5] ), .SUM(N88) );
  sky130_fd_sc_hd__inv_2 U348 ( .A(n637), .Y(n1368) );
  sky130_fd_sc_hd__inv_2 U349 ( .A(n623), .Y(n1355) );
  sky130_fd_sc_hd__a21bo_1 U350 ( .A1(N108), .A2(n592), .B1_N(n20), .X(
        s_cnt_d[0]) );
  sky130_fd_sc_hd__mux2_2 U351 ( .A0(n590), .A1(n585), .S(cnt_o[0]), .X(n20)
         );
  sky130_fd_sc_hd__inv_2 U352 ( .A(n594), .Y(n691) );
  sky130_fd_sc_hd__ha_1 U353 ( .A(s_wr_ptr_q[1]), .B(s_wr_ptr_q[0]), .COUT(
        \add_65/carry[2] ), .SUM(N96) );
  sky130_fd_sc_hd__ha_1 U354 ( .A(s_wr_ptr_q[2]), .B(\add_65/carry[2] ), 
        .COUT(\add_65/carry[3] ), .SUM(N97) );
  sky130_fd_sc_hd__ha_1 U355 ( .A(s_wr_ptr_q[3]), .B(\add_65/carry[3] ), 
        .COUT(\add_65/carry[4] ), .SUM(N98) );
  sky130_fd_sc_hd__ha_1 U356 ( .A(s_wr_ptr_q[4]), .B(\add_65/carry[4] ), 
        .COUT(\add_65/carry[5] ), .SUM(N99) );
  sky130_fd_sc_hd__o2bb2ai_1 U357 ( .B1(n499), .B2(n446), .A1_N(n446), .A2_N(
        n1453), .Y(s_rd_ptr_d[0]) );
  sky130_fd_sc_hd__o2bb2ai_1 U358 ( .B1(n499), .B2(n447), .A1_N(N85), .A2_N(
        n1453), .Y(s_rd_ptr_d[1]) );
  sky130_fd_sc_hd__o2bb2ai_1 U359 ( .B1(n499), .B2(n1452), .A1_N(N87), .A2_N(
        n1453), .Y(s_rd_ptr_d[3]) );
  sky130_fd_sc_hd__nor2_1 U360 ( .A(n449), .B(N80), .Y(n412) );
  sky130_fd_sc_hd__inv_2 U361 ( .A(N79), .Y(n449) );
  sky130_fd_sc_hd__nor2_1 U362 ( .A(n450), .B(N79), .Y(n401) );
  sky130_fd_sc_hd__nor2_1 U363 ( .A(N79), .B(N80), .Y(n439) );
  sky130_fd_sc_hd__nor2_1 U364 ( .A(n448), .B(N78), .Y(n22) );
  sky130_fd_sc_hd__nor2_1 U365 ( .A(n447), .B(N75), .Y(n29) );
  sky130_fd_sc_hd__and2_0 U366 ( .A(n22), .B(n29), .X(n416) );
  sky130_fd_sc_hd__nor2_1 U367 ( .A(n447), .B(n446), .Y(n30) );
  sky130_fd_sc_hd__and2_0 U368 ( .A(n22), .B(n30), .X(n415) );
  sky130_fd_sc_hd__a22oi_1 U369 ( .A1(s_mem_q[486]), .A2(n454), .B1(
        s_mem_q[495]), .B2(n451), .Y(n27) );
  sky130_fd_sc_hd__nor2_1 U370 ( .A(N75), .B(N76), .Y(n31) );
  sky130_fd_sc_hd__and2_0 U371 ( .A(n22), .B(n31), .X(n418) );
  sky130_fd_sc_hd__nor2_1 U372 ( .A(n446), .B(N76), .Y(n32) );
  sky130_fd_sc_hd__and2_0 U373 ( .A(n22), .B(n32), .X(n417) );
  sky130_fd_sc_hd__a22oi_1 U374 ( .A1(s_mem_q[468]), .A2(n460), .B1(
        s_mem_q[477]), .B2(n457), .Y(n26) );
  sky130_fd_sc_hd__nor2_1 U375 ( .A(N77), .B(N78), .Y(n23) );
  sky130_fd_sc_hd__and2_0 U376 ( .A(n23), .B(n29), .X(n420) );
  sky130_fd_sc_hd__and2_0 U377 ( .A(n23), .B(n30), .X(n419) );
  sky130_fd_sc_hd__a22oi_1 U378 ( .A1(s_mem_q[450]), .A2(n466), .B1(
        s_mem_q[459]), .B2(n463), .Y(n25) );
  sky130_fd_sc_hd__and2_0 U379 ( .A(n23), .B(n31), .X(n422) );
  sky130_fd_sc_hd__and2_0 U380 ( .A(n23), .B(n32), .X(n421) );
  sky130_fd_sc_hd__a22oi_1 U381 ( .A1(s_mem_q[432]), .A2(n472), .B1(
        s_mem_q[441]), .B2(n469), .Y(n24) );
  sky130_fd_sc_hd__nand4_1 U382 ( .A(n27), .B(n26), .C(n25), .D(n24), .Y(n39)
         );
  sky130_fd_sc_hd__and2_0 U383 ( .A(N78), .B(N77), .X(n28) );
  sky130_fd_sc_hd__and2_0 U384 ( .A(n29), .B(n28), .X(n428) );
  sky130_fd_sc_hd__and2_0 U385 ( .A(n28), .B(n30), .X(n427) );
  sky130_fd_sc_hd__a22oi_1 U386 ( .A1(s_mem_q[558]), .A2(n478), .B1(
        s_mem_q[567]), .B2(n475), .Y(n37) );
  sky130_fd_sc_hd__and2_0 U387 ( .A(n32), .B(n28), .X(n429) );
  sky130_fd_sc_hd__a22oi_1 U388 ( .A1(s_mem_q[540]), .A2(n484), .B1(
        s_mem_q[549]), .B2(n481), .Y(n36) );
  sky130_fd_sc_hd__and2_0 U389 ( .A(N78), .B(n448), .X(n33) );
  sky130_fd_sc_hd__and2_0 U390 ( .A(n33), .B(n30), .X(n431) );
  sky130_fd_sc_hd__a22oi_1 U391 ( .A1(s_mem_q[522]), .A2(n490), .B1(
        s_mem_q[531]), .B2(n487), .Y(n35) );
  sky130_fd_sc_hd__and2_0 U392 ( .A(n33), .B(n32), .X(n433) );
  sky130_fd_sc_hd__a22oi_1 U393 ( .A1(s_mem_q[504]), .A2(n496), .B1(
        s_mem_q[513]), .B2(n493), .Y(n34) );
  sky130_fd_sc_hd__nand4_1 U394 ( .A(n37), .B(n36), .C(n35), .D(n34), .Y(n38)
         );
  sky130_fd_sc_hd__o21ai_0 U395 ( .A1(n39), .A2(n38), .B1(n390), .Y(n73) );
  sky130_fd_sc_hd__a22oi_1 U396 ( .A1(s_mem_q[342]), .A2(n454), .B1(
        s_mem_q[351]), .B2(n451), .Y(n43) );
  sky130_fd_sc_hd__a22oi_1 U397 ( .A1(s_mem_q[324]), .A2(n460), .B1(
        s_mem_q[333]), .B2(n457), .Y(n42) );
  sky130_fd_sc_hd__a22oi_1 U398 ( .A1(s_mem_q[306]), .A2(n466), .B1(
        s_mem_q[315]), .B2(n463), .Y(n41) );
  sky130_fd_sc_hd__a22oi_1 U399 ( .A1(s_mem_q[288]), .A2(n472), .B1(
        s_mem_q[297]), .B2(n469), .Y(n40) );
  sky130_fd_sc_hd__nand4_1 U400 ( .A(n43), .B(n42), .C(n41), .D(n40), .Y(n49)
         );
  sky130_fd_sc_hd__a22oi_1 U401 ( .A1(s_mem_q[414]), .A2(n478), .B1(
        s_mem_q[423]), .B2(n475), .Y(n47) );
  sky130_fd_sc_hd__a22oi_1 U402 ( .A1(s_mem_q[396]), .A2(n484), .B1(
        s_mem_q[405]), .B2(n481), .Y(n46) );
  sky130_fd_sc_hd__a22oi_1 U403 ( .A1(s_mem_q[378]), .A2(n490), .B1(
        s_mem_q[387]), .B2(n487), .Y(n45) );
  sky130_fd_sc_hd__a22oi_1 U404 ( .A1(s_mem_q[360]), .A2(n496), .B1(
        s_mem_q[369]), .B2(n493), .Y(n44) );
  sky130_fd_sc_hd__nand4_1 U405 ( .A(n47), .B(n46), .C(n45), .D(n44), .Y(n48)
         );
  sky130_fd_sc_hd__o21ai_0 U406 ( .A1(n49), .A2(n48), .B1(n401), .Y(n72) );
  sky130_fd_sc_hd__a22oi_1 U407 ( .A1(s_mem_q[198]), .A2(n454), .B1(
        s_mem_q[207]), .B2(n451), .Y(n53) );
  sky130_fd_sc_hd__a22oi_1 U408 ( .A1(s_mem_q[180]), .A2(n460), .B1(
        s_mem_q[189]), .B2(n457), .Y(n52) );
  sky130_fd_sc_hd__a22oi_1 U409 ( .A1(s_mem_q[162]), .A2(n466), .B1(
        s_mem_q[171]), .B2(n463), .Y(n51) );
  sky130_fd_sc_hd__a22oi_1 U410 ( .A1(s_mem_q[144]), .A2(n472), .B1(
        s_mem_q[153]), .B2(n469), .Y(n50) );
  sky130_fd_sc_hd__nand4_1 U411 ( .A(n53), .B(n52), .C(n51), .D(n50), .Y(n59)
         );
  sky130_fd_sc_hd__a22oi_1 U412 ( .A1(s_mem_q[270]), .A2(n478), .B1(
        s_mem_q[279]), .B2(n475), .Y(n57) );
  sky130_fd_sc_hd__a22oi_1 U413 ( .A1(s_mem_q[252]), .A2(n484), .B1(
        s_mem_q[261]), .B2(n481), .Y(n56) );
  sky130_fd_sc_hd__a22oi_1 U414 ( .A1(s_mem_q[234]), .A2(n490), .B1(
        s_mem_q[243]), .B2(n487), .Y(n55) );
  sky130_fd_sc_hd__a22oi_1 U415 ( .A1(s_mem_q[216]), .A2(n496), .B1(
        s_mem_q[225]), .B2(n493), .Y(n54) );
  sky130_fd_sc_hd__nand4_1 U416 ( .A(n57), .B(n56), .C(n55), .D(n54), .Y(n58)
         );
  sky130_fd_sc_hd__o21ai_0 U417 ( .A1(n59), .A2(n58), .B1(n412), .Y(n71) );
  sky130_fd_sc_hd__a22oi_1 U418 ( .A1(s_mem_q[54]), .A2(n454), .B1(s_mem_q[63]), .B2(n451), .Y(n63) );
  sky130_fd_sc_hd__a22oi_1 U419 ( .A1(s_mem_q[36]), .A2(n460), .B1(s_mem_q[45]), .B2(n457), .Y(n62) );
  sky130_fd_sc_hd__a22oi_1 U420 ( .A1(s_mem_q[18]), .A2(n466), .B1(s_mem_q[27]), .B2(n463), .Y(n61) );
  sky130_fd_sc_hd__a22oi_1 U421 ( .A1(s_mem_q[0]), .A2(n472), .B1(s_mem_q[9]), 
        .B2(n469), .Y(n60) );
  sky130_fd_sc_hd__nand4_1 U422 ( .A(n63), .B(n62), .C(n61), .D(n60), .Y(n69)
         );
  sky130_fd_sc_hd__a22oi_1 U423 ( .A1(s_mem_q[126]), .A2(n478), .B1(
        s_mem_q[135]), .B2(n475), .Y(n67) );
  sky130_fd_sc_hd__a22oi_1 U424 ( .A1(s_mem_q[108]), .A2(n484), .B1(
        s_mem_q[117]), .B2(n481), .Y(n66) );
  sky130_fd_sc_hd__a22oi_1 U425 ( .A1(s_mem_q[90]), .A2(n490), .B1(s_mem_q[99]), .B2(n487), .Y(n65) );
  sky130_fd_sc_hd__a22oi_1 U426 ( .A1(s_mem_q[72]), .A2(n496), .B1(s_mem_q[81]), .B2(n493), .Y(n64) );
  sky130_fd_sc_hd__nand4_1 U427 ( .A(n67), .B(n66), .C(n65), .D(n64), .Y(n68)
         );
  sky130_fd_sc_hd__o21ai_0 U428 ( .A1(n69), .A2(n68), .B1(n439), .Y(n70) );
  sky130_fd_sc_hd__nand4_1 U429 ( .A(n73), .B(n72), .C(n71), .D(n70), .Y(
        dat_o[0]) );
  sky130_fd_sc_hd__a22oi_1 U430 ( .A1(s_mem_q[487]), .A2(n454), .B1(
        s_mem_q[496]), .B2(n451), .Y(n77) );
  sky130_fd_sc_hd__a22oi_1 U431 ( .A1(s_mem_q[469]), .A2(n460), .B1(
        s_mem_q[478]), .B2(n457), .Y(n76) );
  sky130_fd_sc_hd__a22oi_1 U432 ( .A1(s_mem_q[451]), .A2(n466), .B1(
        s_mem_q[460]), .B2(n463), .Y(n75) );
  sky130_fd_sc_hd__a22oi_1 U433 ( .A1(s_mem_q[433]), .A2(n472), .B1(
        s_mem_q[442]), .B2(n469), .Y(n74) );
  sky130_fd_sc_hd__nand4_1 U434 ( .A(n77), .B(n76), .C(n75), .D(n74), .Y(n83)
         );
  sky130_fd_sc_hd__a22oi_1 U435 ( .A1(s_mem_q[559]), .A2(n478), .B1(
        s_mem_q[568]), .B2(n475), .Y(n81) );
  sky130_fd_sc_hd__a22oi_1 U436 ( .A1(s_mem_q[541]), .A2(n484), .B1(
        s_mem_q[550]), .B2(n481), .Y(n80) );
  sky130_fd_sc_hd__a22oi_1 U437 ( .A1(s_mem_q[523]), .A2(n490), .B1(
        s_mem_q[532]), .B2(n487), .Y(n79) );
  sky130_fd_sc_hd__a22oi_1 U438 ( .A1(s_mem_q[505]), .A2(n496), .B1(
        s_mem_q[514]), .B2(n493), .Y(n78) );
  sky130_fd_sc_hd__nand4_1 U439 ( .A(n81), .B(n80), .C(n79), .D(n78), .Y(n82)
         );
  sky130_fd_sc_hd__o21ai_0 U440 ( .A1(n83), .A2(n82), .B1(n390), .Y(n117) );
  sky130_fd_sc_hd__a22oi_1 U441 ( .A1(s_mem_q[343]), .A2(n454), .B1(
        s_mem_q[352]), .B2(n451), .Y(n87) );
  sky130_fd_sc_hd__a22oi_1 U442 ( .A1(s_mem_q[325]), .A2(n460), .B1(
        s_mem_q[334]), .B2(n457), .Y(n86) );
  sky130_fd_sc_hd__a22oi_1 U443 ( .A1(s_mem_q[307]), .A2(n466), .B1(
        s_mem_q[316]), .B2(n463), .Y(n85) );
  sky130_fd_sc_hd__a22oi_1 U444 ( .A1(s_mem_q[289]), .A2(n472), .B1(
        s_mem_q[298]), .B2(n469), .Y(n84) );
  sky130_fd_sc_hd__nand4_1 U445 ( .A(n87), .B(n86), .C(n85), .D(n84), .Y(n93)
         );
  sky130_fd_sc_hd__a22oi_1 U446 ( .A1(s_mem_q[415]), .A2(n478), .B1(
        s_mem_q[424]), .B2(n475), .Y(n91) );
  sky130_fd_sc_hd__a22oi_1 U447 ( .A1(s_mem_q[397]), .A2(n484), .B1(
        s_mem_q[406]), .B2(n481), .Y(n90) );
  sky130_fd_sc_hd__a22oi_1 U448 ( .A1(s_mem_q[379]), .A2(n490), .B1(
        s_mem_q[388]), .B2(n487), .Y(n89) );
  sky130_fd_sc_hd__a22oi_1 U449 ( .A1(s_mem_q[361]), .A2(n496), .B1(
        s_mem_q[370]), .B2(n493), .Y(n88) );
  sky130_fd_sc_hd__nand4_1 U450 ( .A(n91), .B(n90), .C(n89), .D(n88), .Y(n92)
         );
  sky130_fd_sc_hd__o21ai_0 U451 ( .A1(n93), .A2(n92), .B1(n401), .Y(n116) );
  sky130_fd_sc_hd__a22oi_1 U452 ( .A1(s_mem_q[199]), .A2(n454), .B1(
        s_mem_q[208]), .B2(n451), .Y(n97) );
  sky130_fd_sc_hd__a22oi_1 U453 ( .A1(s_mem_q[181]), .A2(n460), .B1(
        s_mem_q[190]), .B2(n457), .Y(n96) );
  sky130_fd_sc_hd__a22oi_1 U454 ( .A1(s_mem_q[163]), .A2(n466), .B1(
        s_mem_q[172]), .B2(n463), .Y(n95) );
  sky130_fd_sc_hd__a22oi_1 U455 ( .A1(s_mem_q[145]), .A2(n472), .B1(
        s_mem_q[154]), .B2(n469), .Y(n94) );
  sky130_fd_sc_hd__nand4_1 U456 ( .A(n97), .B(n96), .C(n95), .D(n94), .Y(n103)
         );
  sky130_fd_sc_hd__a22oi_1 U457 ( .A1(s_mem_q[271]), .A2(n478), .B1(
        s_mem_q[280]), .B2(n475), .Y(n101) );
  sky130_fd_sc_hd__a22oi_1 U458 ( .A1(s_mem_q[253]), .A2(n484), .B1(
        s_mem_q[262]), .B2(n481), .Y(n100) );
  sky130_fd_sc_hd__a22oi_1 U459 ( .A1(s_mem_q[235]), .A2(n490), .B1(
        s_mem_q[244]), .B2(n487), .Y(n99) );
  sky130_fd_sc_hd__a22oi_1 U460 ( .A1(s_mem_q[217]), .A2(n496), .B1(
        s_mem_q[226]), .B2(n493), .Y(n98) );
  sky130_fd_sc_hd__nand4_1 U461 ( .A(n101), .B(n100), .C(n99), .D(n98), .Y(
        n102) );
  sky130_fd_sc_hd__o21ai_0 U462 ( .A1(n103), .A2(n102), .B1(n412), .Y(n115) );
  sky130_fd_sc_hd__a22oi_1 U463 ( .A1(s_mem_q[55]), .A2(n454), .B1(s_mem_q[64]), .B2(n451), .Y(n107) );
  sky130_fd_sc_hd__a22oi_1 U464 ( .A1(s_mem_q[37]), .A2(n460), .B1(s_mem_q[46]), .B2(n457), .Y(n106) );
  sky130_fd_sc_hd__a22oi_1 U465 ( .A1(s_mem_q[19]), .A2(n466), .B1(s_mem_q[28]), .B2(n463), .Y(n105) );
  sky130_fd_sc_hd__a22oi_1 U466 ( .A1(s_mem_q[1]), .A2(n472), .B1(s_mem_q[10]), 
        .B2(n469), .Y(n104) );
  sky130_fd_sc_hd__nand4_1 U467 ( .A(n107), .B(n106), .C(n105), .D(n104), .Y(
        n113) );
  sky130_fd_sc_hd__a22oi_1 U468 ( .A1(s_mem_q[127]), .A2(n478), .B1(
        s_mem_q[136]), .B2(n475), .Y(n111) );
  sky130_fd_sc_hd__a22oi_1 U469 ( .A1(s_mem_q[109]), .A2(n484), .B1(
        s_mem_q[118]), .B2(n481), .Y(n110) );
  sky130_fd_sc_hd__a22oi_1 U470 ( .A1(s_mem_q[91]), .A2(n490), .B1(
        s_mem_q[100]), .B2(n487), .Y(n109) );
  sky130_fd_sc_hd__a22oi_1 U471 ( .A1(s_mem_q[73]), .A2(n496), .B1(s_mem_q[82]), .B2(n493), .Y(n108) );
  sky130_fd_sc_hd__nand4_1 U472 ( .A(n111), .B(n110), .C(n109), .D(n108), .Y(
        n112) );
  sky130_fd_sc_hd__o21ai_0 U473 ( .A1(n113), .A2(n112), .B1(n439), .Y(n114) );
  sky130_fd_sc_hd__nand4_1 U474 ( .A(n117), .B(n116), .C(n115), .D(n114), .Y(
        dat_o[1]) );
  sky130_fd_sc_hd__a22oi_1 U475 ( .A1(s_mem_q[488]), .A2(n454), .B1(
        s_mem_q[497]), .B2(n451), .Y(n121) );
  sky130_fd_sc_hd__a22oi_1 U476 ( .A1(s_mem_q[470]), .A2(n460), .B1(
        s_mem_q[479]), .B2(n457), .Y(n120) );
  sky130_fd_sc_hd__a22oi_1 U477 ( .A1(s_mem_q[452]), .A2(n466), .B1(
        s_mem_q[461]), .B2(n463), .Y(n119) );
  sky130_fd_sc_hd__a22oi_1 U478 ( .A1(s_mem_q[434]), .A2(n472), .B1(
        s_mem_q[443]), .B2(n469), .Y(n118) );
  sky130_fd_sc_hd__nand4_1 U479 ( .A(n121), .B(n120), .C(n119), .D(n118), .Y(
        n127) );
  sky130_fd_sc_hd__a22oi_1 U480 ( .A1(s_mem_q[560]), .A2(n478), .B1(
        s_mem_q[569]), .B2(n475), .Y(n125) );
  sky130_fd_sc_hd__a22oi_1 U481 ( .A1(s_mem_q[542]), .A2(n484), .B1(
        s_mem_q[551]), .B2(n481), .Y(n124) );
  sky130_fd_sc_hd__a22oi_1 U482 ( .A1(s_mem_q[524]), .A2(n490), .B1(
        s_mem_q[533]), .B2(n487), .Y(n123) );
  sky130_fd_sc_hd__a22oi_1 U483 ( .A1(s_mem_q[506]), .A2(n496), .B1(
        s_mem_q[515]), .B2(n493), .Y(n122) );
  sky130_fd_sc_hd__nand4_1 U484 ( .A(n125), .B(n124), .C(n123), .D(n122), .Y(
        n126) );
  sky130_fd_sc_hd__o21ai_0 U485 ( .A1(n127), .A2(n126), .B1(n390), .Y(n161) );
  sky130_fd_sc_hd__a22oi_1 U486 ( .A1(s_mem_q[344]), .A2(n454), .B1(
        s_mem_q[353]), .B2(n451), .Y(n131) );
  sky130_fd_sc_hd__a22oi_1 U487 ( .A1(s_mem_q[326]), .A2(n460), .B1(
        s_mem_q[335]), .B2(n457), .Y(n130) );
  sky130_fd_sc_hd__a22oi_1 U488 ( .A1(s_mem_q[308]), .A2(n466), .B1(
        s_mem_q[317]), .B2(n463), .Y(n129) );
  sky130_fd_sc_hd__a22oi_1 U489 ( .A1(s_mem_q[290]), .A2(n472), .B1(
        s_mem_q[299]), .B2(n469), .Y(n128) );
  sky130_fd_sc_hd__nand4_1 U490 ( .A(n131), .B(n130), .C(n129), .D(n128), .Y(
        n137) );
  sky130_fd_sc_hd__a22oi_1 U491 ( .A1(s_mem_q[416]), .A2(n478), .B1(
        s_mem_q[425]), .B2(n475), .Y(n135) );
  sky130_fd_sc_hd__a22oi_1 U492 ( .A1(s_mem_q[398]), .A2(n484), .B1(
        s_mem_q[407]), .B2(n481), .Y(n134) );
  sky130_fd_sc_hd__a22oi_1 U493 ( .A1(s_mem_q[380]), .A2(n490), .B1(
        s_mem_q[389]), .B2(n487), .Y(n133) );
  sky130_fd_sc_hd__a22oi_1 U494 ( .A1(s_mem_q[362]), .A2(n496), .B1(
        s_mem_q[371]), .B2(n493), .Y(n132) );
  sky130_fd_sc_hd__nand4_1 U495 ( .A(n135), .B(n134), .C(n133), .D(n132), .Y(
        n136) );
  sky130_fd_sc_hd__o21ai_0 U496 ( .A1(n137), .A2(n136), .B1(n401), .Y(n160) );
  sky130_fd_sc_hd__a22oi_1 U497 ( .A1(s_mem_q[200]), .A2(n455), .B1(
        s_mem_q[209]), .B2(n452), .Y(n141) );
  sky130_fd_sc_hd__a22oi_1 U498 ( .A1(s_mem_q[182]), .A2(n461), .B1(
        s_mem_q[191]), .B2(n458), .Y(n140) );
  sky130_fd_sc_hd__a22oi_1 U499 ( .A1(s_mem_q[164]), .A2(n467), .B1(
        s_mem_q[173]), .B2(n464), .Y(n139) );
  sky130_fd_sc_hd__a22oi_1 U500 ( .A1(s_mem_q[146]), .A2(n473), .B1(
        s_mem_q[155]), .B2(n470), .Y(n138) );
  sky130_fd_sc_hd__nand4_1 U501 ( .A(n141), .B(n140), .C(n139), .D(n138), .Y(
        n147) );
  sky130_fd_sc_hd__a22oi_1 U502 ( .A1(s_mem_q[272]), .A2(n479), .B1(
        s_mem_q[281]), .B2(n476), .Y(n145) );
  sky130_fd_sc_hd__a22oi_1 U503 ( .A1(s_mem_q[254]), .A2(n485), .B1(
        s_mem_q[263]), .B2(n482), .Y(n144) );
  sky130_fd_sc_hd__a22oi_1 U504 ( .A1(s_mem_q[236]), .A2(n491), .B1(
        s_mem_q[245]), .B2(n488), .Y(n143) );
  sky130_fd_sc_hd__a22oi_1 U505 ( .A1(s_mem_q[218]), .A2(n497), .B1(
        s_mem_q[227]), .B2(n494), .Y(n142) );
  sky130_fd_sc_hd__nand4_1 U506 ( .A(n145), .B(n144), .C(n143), .D(n142), .Y(
        n146) );
  sky130_fd_sc_hd__o21ai_0 U507 ( .A1(n147), .A2(n146), .B1(n412), .Y(n159) );
  sky130_fd_sc_hd__a22oi_1 U508 ( .A1(s_mem_q[56]), .A2(n455), .B1(s_mem_q[65]), .B2(n452), .Y(n151) );
  sky130_fd_sc_hd__a22oi_1 U509 ( .A1(s_mem_q[38]), .A2(n461), .B1(s_mem_q[47]), .B2(n458), .Y(n150) );
  sky130_fd_sc_hd__a22oi_1 U510 ( .A1(s_mem_q[20]), .A2(n467), .B1(s_mem_q[29]), .B2(n464), .Y(n149) );
  sky130_fd_sc_hd__a22oi_1 U511 ( .A1(s_mem_q[2]), .A2(n473), .B1(s_mem_q[11]), 
        .B2(n470), .Y(n148) );
  sky130_fd_sc_hd__nand4_1 U512 ( .A(n151), .B(n150), .C(n149), .D(n148), .Y(
        n157) );
  sky130_fd_sc_hd__a22oi_1 U513 ( .A1(s_mem_q[128]), .A2(n479), .B1(
        s_mem_q[137]), .B2(n476), .Y(n155) );
  sky130_fd_sc_hd__a22oi_1 U514 ( .A1(s_mem_q[110]), .A2(n485), .B1(
        s_mem_q[119]), .B2(n482), .Y(n154) );
  sky130_fd_sc_hd__a22oi_1 U515 ( .A1(s_mem_q[92]), .A2(n491), .B1(
        s_mem_q[101]), .B2(n488), .Y(n153) );
  sky130_fd_sc_hd__a22oi_1 U516 ( .A1(s_mem_q[74]), .A2(n497), .B1(s_mem_q[83]), .B2(n494), .Y(n152) );
  sky130_fd_sc_hd__nand4_1 U517 ( .A(n155), .B(n154), .C(n153), .D(n152), .Y(
        n156) );
  sky130_fd_sc_hd__o21ai_0 U518 ( .A1(n157), .A2(n156), .B1(n439), .Y(n158) );
  sky130_fd_sc_hd__nand4_1 U519 ( .A(n161), .B(n160), .C(n159), .D(n158), .Y(
        dat_o[2]) );
  sky130_fd_sc_hd__a22oi_1 U520 ( .A1(s_mem_q[489]), .A2(n455), .B1(
        s_mem_q[498]), .B2(n452), .Y(n165) );
  sky130_fd_sc_hd__a22oi_1 U521 ( .A1(s_mem_q[471]), .A2(n461), .B1(
        s_mem_q[480]), .B2(n458), .Y(n164) );
  sky130_fd_sc_hd__a22oi_1 U522 ( .A1(s_mem_q[453]), .A2(n467), .B1(
        s_mem_q[462]), .B2(n464), .Y(n163) );
  sky130_fd_sc_hd__a22oi_1 U523 ( .A1(s_mem_q[435]), .A2(n473), .B1(
        s_mem_q[444]), .B2(n470), .Y(n162) );
  sky130_fd_sc_hd__nand4_1 U524 ( .A(n165), .B(n164), .C(n163), .D(n162), .Y(
        n171) );
  sky130_fd_sc_hd__a22oi_1 U525 ( .A1(s_mem_q[561]), .A2(n479), .B1(
        s_mem_q[570]), .B2(n476), .Y(n169) );
  sky130_fd_sc_hd__a22oi_1 U526 ( .A1(s_mem_q[543]), .A2(n485), .B1(
        s_mem_q[552]), .B2(n482), .Y(n168) );
  sky130_fd_sc_hd__a22oi_1 U527 ( .A1(s_mem_q[525]), .A2(n491), .B1(
        s_mem_q[534]), .B2(n488), .Y(n167) );
  sky130_fd_sc_hd__a22oi_1 U528 ( .A1(s_mem_q[507]), .A2(n497), .B1(
        s_mem_q[516]), .B2(n494), .Y(n166) );
  sky130_fd_sc_hd__nand4_1 U529 ( .A(n169), .B(n168), .C(n167), .D(n166), .Y(
        n170) );
  sky130_fd_sc_hd__o21ai_0 U530 ( .A1(n171), .A2(n170), .B1(n390), .Y(n205) );
  sky130_fd_sc_hd__a22oi_1 U531 ( .A1(s_mem_q[345]), .A2(n455), .B1(
        s_mem_q[354]), .B2(n452), .Y(n175) );
  sky130_fd_sc_hd__a22oi_1 U532 ( .A1(s_mem_q[327]), .A2(n461), .B1(
        s_mem_q[336]), .B2(n458), .Y(n174) );
  sky130_fd_sc_hd__a22oi_1 U533 ( .A1(s_mem_q[309]), .A2(n467), .B1(
        s_mem_q[318]), .B2(n464), .Y(n173) );
  sky130_fd_sc_hd__a22oi_1 U534 ( .A1(s_mem_q[291]), .A2(n473), .B1(
        s_mem_q[300]), .B2(n470), .Y(n172) );
  sky130_fd_sc_hd__nand4_1 U535 ( .A(n175), .B(n174), .C(n173), .D(n172), .Y(
        n181) );
  sky130_fd_sc_hd__a22oi_1 U536 ( .A1(s_mem_q[417]), .A2(n479), .B1(
        s_mem_q[426]), .B2(n476), .Y(n179) );
  sky130_fd_sc_hd__a22oi_1 U537 ( .A1(s_mem_q[399]), .A2(n485), .B1(
        s_mem_q[408]), .B2(n482), .Y(n178) );
  sky130_fd_sc_hd__a22oi_1 U538 ( .A1(s_mem_q[381]), .A2(n491), .B1(
        s_mem_q[390]), .B2(n488), .Y(n177) );
  sky130_fd_sc_hd__a22oi_1 U539 ( .A1(s_mem_q[363]), .A2(n497), .B1(
        s_mem_q[372]), .B2(n494), .Y(n176) );
  sky130_fd_sc_hd__nand4_1 U540 ( .A(n179), .B(n178), .C(n177), .D(n176), .Y(
        n180) );
  sky130_fd_sc_hd__o21ai_0 U541 ( .A1(n181), .A2(n180), .B1(n401), .Y(n204) );
  sky130_fd_sc_hd__a22oi_1 U542 ( .A1(s_mem_q[201]), .A2(n455), .B1(
        s_mem_q[210]), .B2(n452), .Y(n185) );
  sky130_fd_sc_hd__a22oi_1 U543 ( .A1(s_mem_q[183]), .A2(n461), .B1(
        s_mem_q[192]), .B2(n458), .Y(n184) );
  sky130_fd_sc_hd__a22oi_1 U544 ( .A1(s_mem_q[165]), .A2(n467), .B1(
        s_mem_q[174]), .B2(n464), .Y(n183) );
  sky130_fd_sc_hd__a22oi_1 U545 ( .A1(s_mem_q[147]), .A2(n473), .B1(
        s_mem_q[156]), .B2(n470), .Y(n182) );
  sky130_fd_sc_hd__nand4_1 U546 ( .A(n185), .B(n184), .C(n183), .D(n182), .Y(
        n191) );
  sky130_fd_sc_hd__a22oi_1 U547 ( .A1(s_mem_q[273]), .A2(n479), .B1(
        s_mem_q[282]), .B2(n476), .Y(n189) );
  sky130_fd_sc_hd__a22oi_1 U548 ( .A1(s_mem_q[255]), .A2(n485), .B1(
        s_mem_q[264]), .B2(n482), .Y(n188) );
  sky130_fd_sc_hd__a22oi_1 U549 ( .A1(s_mem_q[237]), .A2(n491), .B1(
        s_mem_q[246]), .B2(n488), .Y(n187) );
  sky130_fd_sc_hd__a22oi_1 U550 ( .A1(s_mem_q[219]), .A2(n497), .B1(
        s_mem_q[228]), .B2(n494), .Y(n186) );
  sky130_fd_sc_hd__nand4_1 U551 ( .A(n189), .B(n188), .C(n187), .D(n186), .Y(
        n190) );
  sky130_fd_sc_hd__o21ai_0 U552 ( .A1(n191), .A2(n190), .B1(n412), .Y(n203) );
  sky130_fd_sc_hd__a22oi_1 U553 ( .A1(s_mem_q[57]), .A2(n455), .B1(s_mem_q[66]), .B2(n452), .Y(n195) );
  sky130_fd_sc_hd__a22oi_1 U554 ( .A1(s_mem_q[39]), .A2(n461), .B1(s_mem_q[48]), .B2(n458), .Y(n194) );
  sky130_fd_sc_hd__a22oi_1 U555 ( .A1(s_mem_q[21]), .A2(n467), .B1(s_mem_q[30]), .B2(n464), .Y(n193) );
  sky130_fd_sc_hd__a22oi_1 U556 ( .A1(s_mem_q[3]), .A2(n473), .B1(s_mem_q[12]), 
        .B2(n470), .Y(n192) );
  sky130_fd_sc_hd__nand4_1 U557 ( .A(n195), .B(n194), .C(n193), .D(n192), .Y(
        n201) );
  sky130_fd_sc_hd__a22oi_1 U558 ( .A1(s_mem_q[129]), .A2(n479), .B1(
        s_mem_q[138]), .B2(n476), .Y(n199) );
  sky130_fd_sc_hd__a22oi_1 U559 ( .A1(s_mem_q[111]), .A2(n485), .B1(
        s_mem_q[120]), .B2(n482), .Y(n198) );
  sky130_fd_sc_hd__a22oi_1 U560 ( .A1(s_mem_q[93]), .A2(n491), .B1(
        s_mem_q[102]), .B2(n488), .Y(n197) );
  sky130_fd_sc_hd__a22oi_1 U561 ( .A1(s_mem_q[75]), .A2(n497), .B1(s_mem_q[84]), .B2(n494), .Y(n196) );
  sky130_fd_sc_hd__nand4_1 U562 ( .A(n199), .B(n198), .C(n197), .D(n196), .Y(
        n200) );
  sky130_fd_sc_hd__o21ai_0 U563 ( .A1(n201), .A2(n200), .B1(n439), .Y(n202) );
  sky130_fd_sc_hd__nand4_1 U564 ( .A(n205), .B(n204), .C(n203), .D(n202), .Y(
        dat_o[3]) );
  sky130_fd_sc_hd__a22oi_1 U565 ( .A1(s_mem_q[490]), .A2(n455), .B1(
        s_mem_q[499]), .B2(n452), .Y(n209) );
  sky130_fd_sc_hd__a22oi_1 U566 ( .A1(s_mem_q[472]), .A2(n461), .B1(
        s_mem_q[481]), .B2(n458), .Y(n208) );
  sky130_fd_sc_hd__a22oi_1 U567 ( .A1(s_mem_q[454]), .A2(n467), .B1(
        s_mem_q[463]), .B2(n464), .Y(n207) );
  sky130_fd_sc_hd__a22oi_1 U568 ( .A1(s_mem_q[436]), .A2(n473), .B1(
        s_mem_q[445]), .B2(n470), .Y(n206) );
  sky130_fd_sc_hd__nand4_1 U569 ( .A(n209), .B(n208), .C(n207), .D(n206), .Y(
        n215) );
  sky130_fd_sc_hd__a22oi_1 U570 ( .A1(s_mem_q[562]), .A2(n479), .B1(
        s_mem_q[571]), .B2(n476), .Y(n213) );
  sky130_fd_sc_hd__a22oi_1 U571 ( .A1(s_mem_q[544]), .A2(n485), .B1(
        s_mem_q[553]), .B2(n482), .Y(n212) );
  sky130_fd_sc_hd__a22oi_1 U572 ( .A1(s_mem_q[526]), .A2(n491), .B1(
        s_mem_q[535]), .B2(n488), .Y(n211) );
  sky130_fd_sc_hd__a22oi_1 U573 ( .A1(s_mem_q[508]), .A2(n497), .B1(
        s_mem_q[517]), .B2(n494), .Y(n210) );
  sky130_fd_sc_hd__nand4_1 U574 ( .A(n213), .B(n212), .C(n211), .D(n210), .Y(
        n214) );
  sky130_fd_sc_hd__o21ai_0 U575 ( .A1(n215), .A2(n214), .B1(n390), .Y(n249) );
  sky130_fd_sc_hd__a22oi_1 U576 ( .A1(s_mem_q[346]), .A2(n455), .B1(
        s_mem_q[355]), .B2(n452), .Y(n219) );
  sky130_fd_sc_hd__a22oi_1 U577 ( .A1(s_mem_q[328]), .A2(n461), .B1(
        s_mem_q[337]), .B2(n458), .Y(n218) );
  sky130_fd_sc_hd__a22oi_1 U578 ( .A1(s_mem_q[310]), .A2(n467), .B1(
        s_mem_q[319]), .B2(n464), .Y(n217) );
  sky130_fd_sc_hd__a22oi_1 U579 ( .A1(s_mem_q[292]), .A2(n473), .B1(
        s_mem_q[301]), .B2(n470), .Y(n216) );
  sky130_fd_sc_hd__nand4_1 U580 ( .A(n219), .B(n218), .C(n217), .D(n216), .Y(
        n225) );
  sky130_fd_sc_hd__a22oi_1 U581 ( .A1(s_mem_q[418]), .A2(n479), .B1(
        s_mem_q[427]), .B2(n476), .Y(n223) );
  sky130_fd_sc_hd__a22oi_1 U582 ( .A1(s_mem_q[400]), .A2(n485), .B1(
        s_mem_q[409]), .B2(n482), .Y(n222) );
  sky130_fd_sc_hd__a22oi_1 U583 ( .A1(s_mem_q[382]), .A2(n491), .B1(
        s_mem_q[391]), .B2(n488), .Y(n221) );
  sky130_fd_sc_hd__a22oi_1 U584 ( .A1(s_mem_q[364]), .A2(n497), .B1(
        s_mem_q[373]), .B2(n494), .Y(n220) );
  sky130_fd_sc_hd__nand4_1 U585 ( .A(n223), .B(n222), .C(n221), .D(n220), .Y(
        n224) );
  sky130_fd_sc_hd__o21ai_0 U586 ( .A1(n225), .A2(n224), .B1(n401), .Y(n248) );
  sky130_fd_sc_hd__a22oi_1 U587 ( .A1(s_mem_q[202]), .A2(n455), .B1(
        s_mem_q[211]), .B2(n452), .Y(n229) );
  sky130_fd_sc_hd__a22oi_1 U588 ( .A1(s_mem_q[184]), .A2(n461), .B1(
        s_mem_q[193]), .B2(n458), .Y(n228) );
  sky130_fd_sc_hd__a22oi_1 U589 ( .A1(s_mem_q[166]), .A2(n467), .B1(
        s_mem_q[175]), .B2(n464), .Y(n227) );
  sky130_fd_sc_hd__a22oi_1 U590 ( .A1(s_mem_q[148]), .A2(n473), .B1(
        s_mem_q[157]), .B2(n470), .Y(n226) );
  sky130_fd_sc_hd__nand4_1 U591 ( .A(n229), .B(n228), .C(n227), .D(n226), .Y(
        n235) );
  sky130_fd_sc_hd__a22oi_1 U592 ( .A1(s_mem_q[274]), .A2(n479), .B1(
        s_mem_q[283]), .B2(n476), .Y(n233) );
  sky130_fd_sc_hd__a22oi_1 U593 ( .A1(s_mem_q[256]), .A2(n485), .B1(
        s_mem_q[265]), .B2(n482), .Y(n232) );
  sky130_fd_sc_hd__a22oi_1 U594 ( .A1(s_mem_q[238]), .A2(n491), .B1(
        s_mem_q[247]), .B2(n488), .Y(n231) );
  sky130_fd_sc_hd__a22oi_1 U595 ( .A1(s_mem_q[220]), .A2(n497), .B1(
        s_mem_q[229]), .B2(n494), .Y(n230) );
  sky130_fd_sc_hd__nand4_1 U596 ( .A(n233), .B(n232), .C(n231), .D(n230), .Y(
        n234) );
  sky130_fd_sc_hd__o21ai_0 U597 ( .A1(n235), .A2(n234), .B1(n412), .Y(n247) );
  sky130_fd_sc_hd__a22oi_1 U598 ( .A1(s_mem_q[58]), .A2(n455), .B1(s_mem_q[67]), .B2(n452), .Y(n239) );
  sky130_fd_sc_hd__a22oi_1 U599 ( .A1(s_mem_q[40]), .A2(n461), .B1(s_mem_q[49]), .B2(n458), .Y(n238) );
  sky130_fd_sc_hd__a22oi_1 U600 ( .A1(s_mem_q[22]), .A2(n467), .B1(s_mem_q[31]), .B2(n464), .Y(n237) );
  sky130_fd_sc_hd__a22oi_1 U601 ( .A1(s_mem_q[4]), .A2(n473), .B1(s_mem_q[13]), 
        .B2(n470), .Y(n236) );
  sky130_fd_sc_hd__nand4_1 U602 ( .A(n239), .B(n238), .C(n237), .D(n236), .Y(
        n245) );
  sky130_fd_sc_hd__a22oi_1 U603 ( .A1(s_mem_q[130]), .A2(n479), .B1(
        s_mem_q[139]), .B2(n476), .Y(n243) );
  sky130_fd_sc_hd__a22oi_1 U604 ( .A1(s_mem_q[112]), .A2(n485), .B1(
        s_mem_q[121]), .B2(n482), .Y(n242) );
  sky130_fd_sc_hd__a22oi_1 U605 ( .A1(s_mem_q[94]), .A2(n491), .B1(
        s_mem_q[103]), .B2(n488), .Y(n241) );
  sky130_fd_sc_hd__a22oi_1 U606 ( .A1(s_mem_q[76]), .A2(n497), .B1(s_mem_q[85]), .B2(n494), .Y(n240) );
  sky130_fd_sc_hd__nand4_1 U607 ( .A(n243), .B(n242), .C(n241), .D(n240), .Y(
        n244) );
  sky130_fd_sc_hd__o21ai_0 U608 ( .A1(n245), .A2(n244), .B1(n439), .Y(n246) );
  sky130_fd_sc_hd__nand4_1 U609 ( .A(n249), .B(n248), .C(n247), .D(n246), .Y(
        dat_o[4]) );
  sky130_fd_sc_hd__a22oi_1 U610 ( .A1(s_mem_q[491]), .A2(n455), .B1(
        s_mem_q[500]), .B2(n452), .Y(n253) );
  sky130_fd_sc_hd__a22oi_1 U611 ( .A1(s_mem_q[473]), .A2(n461), .B1(
        s_mem_q[482]), .B2(n458), .Y(n252) );
  sky130_fd_sc_hd__a22oi_1 U612 ( .A1(s_mem_q[455]), .A2(n467), .B1(
        s_mem_q[464]), .B2(n464), .Y(n251) );
  sky130_fd_sc_hd__a22oi_1 U613 ( .A1(s_mem_q[437]), .A2(n473), .B1(
        s_mem_q[446]), .B2(n470), .Y(n250) );
  sky130_fd_sc_hd__nand4_1 U614 ( .A(n253), .B(n252), .C(n251), .D(n250), .Y(
        n259) );
  sky130_fd_sc_hd__a22oi_1 U615 ( .A1(s_mem_q[563]), .A2(n479), .B1(
        s_mem_q[572]), .B2(n476), .Y(n257) );
  sky130_fd_sc_hd__a22oi_1 U616 ( .A1(s_mem_q[545]), .A2(n485), .B1(
        s_mem_q[554]), .B2(n482), .Y(n256) );
  sky130_fd_sc_hd__a22oi_1 U617 ( .A1(s_mem_q[527]), .A2(n491), .B1(
        s_mem_q[536]), .B2(n488), .Y(n255) );
  sky130_fd_sc_hd__a22oi_1 U618 ( .A1(s_mem_q[509]), .A2(n497), .B1(
        s_mem_q[518]), .B2(n494), .Y(n254) );
  sky130_fd_sc_hd__nand4_1 U619 ( .A(n257), .B(n256), .C(n255), .D(n254), .Y(
        n258) );
  sky130_fd_sc_hd__o21ai_0 U620 ( .A1(n259), .A2(n258), .B1(n390), .Y(n293) );
  sky130_fd_sc_hd__a22oi_1 U621 ( .A1(s_mem_q[347]), .A2(n455), .B1(
        s_mem_q[356]), .B2(n452), .Y(n263) );
  sky130_fd_sc_hd__a22oi_1 U622 ( .A1(s_mem_q[329]), .A2(n461), .B1(
        s_mem_q[338]), .B2(n458), .Y(n262) );
  sky130_fd_sc_hd__a22oi_1 U623 ( .A1(s_mem_q[311]), .A2(n467), .B1(
        s_mem_q[320]), .B2(n464), .Y(n261) );
  sky130_fd_sc_hd__a22oi_1 U624 ( .A1(s_mem_q[293]), .A2(n473), .B1(
        s_mem_q[302]), .B2(n470), .Y(n260) );
  sky130_fd_sc_hd__nand4_1 U625 ( .A(n263), .B(n262), .C(n261), .D(n260), .Y(
        n269) );
  sky130_fd_sc_hd__a22oi_1 U626 ( .A1(s_mem_q[419]), .A2(n479), .B1(
        s_mem_q[428]), .B2(n476), .Y(n267) );
  sky130_fd_sc_hd__a22oi_1 U627 ( .A1(s_mem_q[401]), .A2(n485), .B1(
        s_mem_q[410]), .B2(n482), .Y(n266) );
  sky130_fd_sc_hd__a22oi_1 U628 ( .A1(s_mem_q[383]), .A2(n491), .B1(
        s_mem_q[392]), .B2(n488), .Y(n265) );
  sky130_fd_sc_hd__a22oi_1 U629 ( .A1(s_mem_q[365]), .A2(n497), .B1(
        s_mem_q[374]), .B2(n494), .Y(n264) );
  sky130_fd_sc_hd__nand4_1 U630 ( .A(n267), .B(n266), .C(n265), .D(n264), .Y(
        n268) );
  sky130_fd_sc_hd__o21ai_0 U631 ( .A1(n269), .A2(n268), .B1(n401), .Y(n292) );
  sky130_fd_sc_hd__a22oi_1 U632 ( .A1(s_mem_q[203]), .A2(n455), .B1(
        s_mem_q[212]), .B2(n452), .Y(n273) );
  sky130_fd_sc_hd__a22oi_1 U633 ( .A1(s_mem_q[185]), .A2(n461), .B1(
        s_mem_q[194]), .B2(n458), .Y(n272) );
  sky130_fd_sc_hd__a22oi_1 U634 ( .A1(s_mem_q[167]), .A2(n467), .B1(
        s_mem_q[176]), .B2(n464), .Y(n271) );
  sky130_fd_sc_hd__a22oi_1 U635 ( .A1(s_mem_q[149]), .A2(n473), .B1(
        s_mem_q[158]), .B2(n470), .Y(n270) );
  sky130_fd_sc_hd__nand4_1 U636 ( .A(n273), .B(n272), .C(n271), .D(n270), .Y(
        n279) );
  sky130_fd_sc_hd__a22oi_1 U637 ( .A1(s_mem_q[275]), .A2(n479), .B1(
        s_mem_q[284]), .B2(n476), .Y(n277) );
  sky130_fd_sc_hd__a22oi_1 U638 ( .A1(s_mem_q[257]), .A2(n485), .B1(
        s_mem_q[266]), .B2(n482), .Y(n276) );
  sky130_fd_sc_hd__a22oi_1 U639 ( .A1(s_mem_q[239]), .A2(n491), .B1(
        s_mem_q[248]), .B2(n488), .Y(n275) );
  sky130_fd_sc_hd__a22oi_1 U640 ( .A1(s_mem_q[221]), .A2(n497), .B1(
        s_mem_q[230]), .B2(n494), .Y(n274) );
  sky130_fd_sc_hd__nand4_1 U641 ( .A(n277), .B(n276), .C(n275), .D(n274), .Y(
        n278) );
  sky130_fd_sc_hd__o21ai_0 U642 ( .A1(n279), .A2(n278), .B1(n412), .Y(n291) );
  sky130_fd_sc_hd__a22oi_1 U643 ( .A1(s_mem_q[59]), .A2(n456), .B1(s_mem_q[68]), .B2(n453), .Y(n283) );
  sky130_fd_sc_hd__a22oi_1 U644 ( .A1(s_mem_q[41]), .A2(n462), .B1(s_mem_q[50]), .B2(n459), .Y(n282) );
  sky130_fd_sc_hd__a22oi_1 U645 ( .A1(s_mem_q[23]), .A2(n468), .B1(s_mem_q[32]), .B2(n465), .Y(n281) );
  sky130_fd_sc_hd__a22oi_1 U646 ( .A1(s_mem_q[5]), .A2(n474), .B1(s_mem_q[14]), 
        .B2(n471), .Y(n280) );
  sky130_fd_sc_hd__nand4_1 U647 ( .A(n283), .B(n282), .C(n281), .D(n280), .Y(
        n289) );
  sky130_fd_sc_hd__a22oi_1 U648 ( .A1(s_mem_q[131]), .A2(n480), .B1(
        s_mem_q[140]), .B2(n477), .Y(n287) );
  sky130_fd_sc_hd__a22oi_1 U649 ( .A1(s_mem_q[113]), .A2(n486), .B1(
        s_mem_q[122]), .B2(n483), .Y(n286) );
  sky130_fd_sc_hd__a22oi_1 U650 ( .A1(s_mem_q[95]), .A2(n492), .B1(
        s_mem_q[104]), .B2(n489), .Y(n285) );
  sky130_fd_sc_hd__a22oi_1 U651 ( .A1(s_mem_q[77]), .A2(n498), .B1(s_mem_q[86]), .B2(n495), .Y(n284) );
  sky130_fd_sc_hd__nand4_1 U652 ( .A(n287), .B(n286), .C(n285), .D(n284), .Y(
        n288) );
  sky130_fd_sc_hd__o21ai_0 U653 ( .A1(n289), .A2(n288), .B1(n439), .Y(n290) );
  sky130_fd_sc_hd__nand4_1 U654 ( .A(n293), .B(n292), .C(n291), .D(n290), .Y(
        dat_o[5]) );
  sky130_fd_sc_hd__a22oi_1 U655 ( .A1(s_mem_q[492]), .A2(n456), .B1(
        s_mem_q[501]), .B2(n453), .Y(n297) );
  sky130_fd_sc_hd__a22oi_1 U656 ( .A1(s_mem_q[474]), .A2(n462), .B1(
        s_mem_q[483]), .B2(n459), .Y(n296) );
  sky130_fd_sc_hd__a22oi_1 U657 ( .A1(s_mem_q[456]), .A2(n468), .B1(
        s_mem_q[465]), .B2(n465), .Y(n295) );
  sky130_fd_sc_hd__a22oi_1 U658 ( .A1(s_mem_q[438]), .A2(n474), .B1(
        s_mem_q[447]), .B2(n471), .Y(n294) );
  sky130_fd_sc_hd__nand4_1 U659 ( .A(n297), .B(n296), .C(n295), .D(n294), .Y(
        n303) );
  sky130_fd_sc_hd__a22oi_1 U660 ( .A1(s_mem_q[564]), .A2(n480), .B1(
        s_mem_q[573]), .B2(n477), .Y(n301) );
  sky130_fd_sc_hd__a22oi_1 U661 ( .A1(s_mem_q[546]), .A2(n486), .B1(
        s_mem_q[555]), .B2(n483), .Y(n300) );
  sky130_fd_sc_hd__a22oi_1 U662 ( .A1(s_mem_q[528]), .A2(n492), .B1(
        s_mem_q[537]), .B2(n489), .Y(n299) );
  sky130_fd_sc_hd__a22oi_1 U663 ( .A1(s_mem_q[510]), .A2(n498), .B1(
        s_mem_q[519]), .B2(n495), .Y(n298) );
  sky130_fd_sc_hd__nand4_1 U664 ( .A(n301), .B(n300), .C(n299), .D(n298), .Y(
        n302) );
  sky130_fd_sc_hd__o21ai_0 U665 ( .A1(n303), .A2(n302), .B1(n390), .Y(n337) );
  sky130_fd_sc_hd__a22oi_1 U666 ( .A1(s_mem_q[348]), .A2(n456), .B1(
        s_mem_q[357]), .B2(n453), .Y(n307) );
  sky130_fd_sc_hd__a22oi_1 U667 ( .A1(s_mem_q[330]), .A2(n462), .B1(
        s_mem_q[339]), .B2(n459), .Y(n306) );
  sky130_fd_sc_hd__a22oi_1 U668 ( .A1(s_mem_q[312]), .A2(n468), .B1(
        s_mem_q[321]), .B2(n465), .Y(n305) );
  sky130_fd_sc_hd__a22oi_1 U669 ( .A1(s_mem_q[294]), .A2(n474), .B1(
        s_mem_q[303]), .B2(n471), .Y(n304) );
  sky130_fd_sc_hd__nand4_1 U670 ( .A(n307), .B(n306), .C(n305), .D(n304), .Y(
        n313) );
  sky130_fd_sc_hd__a22oi_1 U671 ( .A1(s_mem_q[420]), .A2(n480), .B1(
        s_mem_q[429]), .B2(n477), .Y(n311) );
  sky130_fd_sc_hd__a22oi_1 U672 ( .A1(s_mem_q[402]), .A2(n486), .B1(
        s_mem_q[411]), .B2(n483), .Y(n310) );
  sky130_fd_sc_hd__a22oi_1 U673 ( .A1(s_mem_q[384]), .A2(n492), .B1(
        s_mem_q[393]), .B2(n489), .Y(n309) );
  sky130_fd_sc_hd__a22oi_1 U674 ( .A1(s_mem_q[366]), .A2(n498), .B1(
        s_mem_q[375]), .B2(n495), .Y(n308) );
  sky130_fd_sc_hd__nand4_1 U675 ( .A(n311), .B(n310), .C(n309), .D(n308), .Y(
        n312) );
  sky130_fd_sc_hd__o21ai_0 U676 ( .A1(n313), .A2(n312), .B1(n401), .Y(n336) );
  sky130_fd_sc_hd__a22oi_1 U677 ( .A1(s_mem_q[204]), .A2(n456), .B1(
        s_mem_q[213]), .B2(n453), .Y(n317) );
  sky130_fd_sc_hd__a22oi_1 U678 ( .A1(s_mem_q[186]), .A2(n462), .B1(
        s_mem_q[195]), .B2(n459), .Y(n316) );
  sky130_fd_sc_hd__a22oi_1 U679 ( .A1(s_mem_q[168]), .A2(n468), .B1(
        s_mem_q[177]), .B2(n465), .Y(n315) );
  sky130_fd_sc_hd__a22oi_1 U680 ( .A1(s_mem_q[150]), .A2(n474), .B1(
        s_mem_q[159]), .B2(n471), .Y(n314) );
  sky130_fd_sc_hd__nand4_1 U681 ( .A(n317), .B(n316), .C(n315), .D(n314), .Y(
        n323) );
  sky130_fd_sc_hd__a22oi_1 U682 ( .A1(s_mem_q[276]), .A2(n480), .B1(
        s_mem_q[285]), .B2(n477), .Y(n321) );
  sky130_fd_sc_hd__a22oi_1 U683 ( .A1(s_mem_q[258]), .A2(n486), .B1(
        s_mem_q[267]), .B2(n483), .Y(n320) );
  sky130_fd_sc_hd__a22oi_1 U684 ( .A1(s_mem_q[240]), .A2(n492), .B1(
        s_mem_q[249]), .B2(n489), .Y(n319) );
  sky130_fd_sc_hd__a22oi_1 U685 ( .A1(s_mem_q[222]), .A2(n498), .B1(
        s_mem_q[231]), .B2(n495), .Y(n318) );
  sky130_fd_sc_hd__nand4_1 U686 ( .A(n321), .B(n320), .C(n319), .D(n318), .Y(
        n322) );
  sky130_fd_sc_hd__o21ai_0 U687 ( .A1(n323), .A2(n322), .B1(n412), .Y(n335) );
  sky130_fd_sc_hd__a22oi_1 U688 ( .A1(s_mem_q[60]), .A2(n456), .B1(s_mem_q[69]), .B2(n453), .Y(n327) );
  sky130_fd_sc_hd__a22oi_1 U689 ( .A1(s_mem_q[42]), .A2(n462), .B1(s_mem_q[51]), .B2(n459), .Y(n326) );
  sky130_fd_sc_hd__a22oi_1 U690 ( .A1(s_mem_q[24]), .A2(n468), .B1(s_mem_q[33]), .B2(n465), .Y(n325) );
  sky130_fd_sc_hd__a22oi_1 U691 ( .A1(s_mem_q[6]), .A2(n474), .B1(s_mem_q[15]), 
        .B2(n471), .Y(n324) );
  sky130_fd_sc_hd__nand4_1 U692 ( .A(n327), .B(n326), .C(n325), .D(n324), .Y(
        n333) );
  sky130_fd_sc_hd__a22oi_1 U693 ( .A1(s_mem_q[132]), .A2(n480), .B1(
        s_mem_q[141]), .B2(n477), .Y(n331) );
  sky130_fd_sc_hd__a22oi_1 U694 ( .A1(s_mem_q[114]), .A2(n486), .B1(
        s_mem_q[123]), .B2(n483), .Y(n330) );
  sky130_fd_sc_hd__a22oi_1 U695 ( .A1(s_mem_q[96]), .A2(n492), .B1(
        s_mem_q[105]), .B2(n489), .Y(n329) );
  sky130_fd_sc_hd__a22oi_1 U696 ( .A1(s_mem_q[78]), .A2(n498), .B1(s_mem_q[87]), .B2(n495), .Y(n328) );
  sky130_fd_sc_hd__nand4_1 U697 ( .A(n331), .B(n330), .C(n329), .D(n328), .Y(
        n332) );
  sky130_fd_sc_hd__o21ai_0 U698 ( .A1(n333), .A2(n332), .B1(n439), .Y(n334) );
  sky130_fd_sc_hd__nand4_1 U699 ( .A(n337), .B(n336), .C(n335), .D(n334), .Y(
        dat_o[6]) );
  sky130_fd_sc_hd__a22oi_1 U700 ( .A1(s_mem_q[493]), .A2(n456), .B1(
        s_mem_q[502]), .B2(n453), .Y(n341) );
  sky130_fd_sc_hd__a22oi_1 U701 ( .A1(s_mem_q[475]), .A2(n462), .B1(
        s_mem_q[484]), .B2(n459), .Y(n340) );
  sky130_fd_sc_hd__a22oi_1 U702 ( .A1(s_mem_q[457]), .A2(n468), .B1(
        s_mem_q[466]), .B2(n465), .Y(n339) );
  sky130_fd_sc_hd__a22oi_1 U703 ( .A1(s_mem_q[439]), .A2(n474), .B1(
        s_mem_q[448]), .B2(n471), .Y(n338) );
  sky130_fd_sc_hd__nand4_1 U704 ( .A(n341), .B(n340), .C(n339), .D(n338), .Y(
        n347) );
  sky130_fd_sc_hd__a22oi_1 U705 ( .A1(s_mem_q[565]), .A2(n480), .B1(
        s_mem_q[574]), .B2(n477), .Y(n345) );
  sky130_fd_sc_hd__a22oi_1 U706 ( .A1(s_mem_q[547]), .A2(n486), .B1(
        s_mem_q[556]), .B2(n483), .Y(n344) );
  sky130_fd_sc_hd__a22oi_1 U707 ( .A1(s_mem_q[529]), .A2(n492), .B1(
        s_mem_q[538]), .B2(n489), .Y(n343) );
  sky130_fd_sc_hd__a22oi_1 U708 ( .A1(s_mem_q[511]), .A2(n498), .B1(
        s_mem_q[520]), .B2(n495), .Y(n342) );
  sky130_fd_sc_hd__nand4_1 U709 ( .A(n345), .B(n344), .C(n343), .D(n342), .Y(
        n346) );
  sky130_fd_sc_hd__o21ai_0 U710 ( .A1(n347), .A2(n346), .B1(n390), .Y(n381) );
  sky130_fd_sc_hd__a22oi_1 U711 ( .A1(s_mem_q[349]), .A2(n456), .B1(
        s_mem_q[358]), .B2(n453), .Y(n351) );
  sky130_fd_sc_hd__a22oi_1 U712 ( .A1(s_mem_q[331]), .A2(n462), .B1(
        s_mem_q[340]), .B2(n459), .Y(n350) );
  sky130_fd_sc_hd__a22oi_1 U713 ( .A1(s_mem_q[313]), .A2(n468), .B1(
        s_mem_q[322]), .B2(n465), .Y(n349) );
  sky130_fd_sc_hd__a22oi_1 U714 ( .A1(s_mem_q[295]), .A2(n474), .B1(
        s_mem_q[304]), .B2(n471), .Y(n348) );
  sky130_fd_sc_hd__nand4_1 U715 ( .A(n351), .B(n350), .C(n349), .D(n348), .Y(
        n357) );
  sky130_fd_sc_hd__a22oi_1 U716 ( .A1(s_mem_q[421]), .A2(n480), .B1(
        s_mem_q[430]), .B2(n477), .Y(n355) );
  sky130_fd_sc_hd__a22oi_1 U717 ( .A1(s_mem_q[403]), .A2(n486), .B1(
        s_mem_q[412]), .B2(n483), .Y(n354) );
  sky130_fd_sc_hd__a22oi_1 U718 ( .A1(s_mem_q[385]), .A2(n492), .B1(
        s_mem_q[394]), .B2(n489), .Y(n353) );
  sky130_fd_sc_hd__a22oi_1 U719 ( .A1(s_mem_q[367]), .A2(n498), .B1(
        s_mem_q[376]), .B2(n495), .Y(n352) );
  sky130_fd_sc_hd__nand4_1 U720 ( .A(n355), .B(n354), .C(n353), .D(n352), .Y(
        n356) );
  sky130_fd_sc_hd__o21ai_0 U721 ( .A1(n357), .A2(n356), .B1(n401), .Y(n380) );
  sky130_fd_sc_hd__a22oi_1 U722 ( .A1(s_mem_q[205]), .A2(n456), .B1(
        s_mem_q[214]), .B2(n453), .Y(n361) );
  sky130_fd_sc_hd__a22oi_1 U723 ( .A1(s_mem_q[187]), .A2(n462), .B1(
        s_mem_q[196]), .B2(n459), .Y(n360) );
  sky130_fd_sc_hd__a22oi_1 U724 ( .A1(s_mem_q[169]), .A2(n468), .B1(
        s_mem_q[178]), .B2(n465), .Y(n359) );
  sky130_fd_sc_hd__a22oi_1 U725 ( .A1(s_mem_q[151]), .A2(n474), .B1(
        s_mem_q[160]), .B2(n471), .Y(n358) );
  sky130_fd_sc_hd__nand4_1 U726 ( .A(n361), .B(n360), .C(n359), .D(n358), .Y(
        n367) );
  sky130_fd_sc_hd__a22oi_1 U727 ( .A1(s_mem_q[277]), .A2(n480), .B1(
        s_mem_q[286]), .B2(n477), .Y(n365) );
  sky130_fd_sc_hd__a22oi_1 U728 ( .A1(s_mem_q[259]), .A2(n486), .B1(
        s_mem_q[268]), .B2(n483), .Y(n364) );
  sky130_fd_sc_hd__a22oi_1 U729 ( .A1(s_mem_q[241]), .A2(n492), .B1(
        s_mem_q[250]), .B2(n489), .Y(n363) );
  sky130_fd_sc_hd__a22oi_1 U730 ( .A1(s_mem_q[223]), .A2(n498), .B1(
        s_mem_q[232]), .B2(n495), .Y(n362) );
  sky130_fd_sc_hd__nand4_1 U731 ( .A(n365), .B(n364), .C(n363), .D(n362), .Y(
        n366) );
  sky130_fd_sc_hd__o21ai_0 U732 ( .A1(n367), .A2(n366), .B1(n412), .Y(n379) );
  sky130_fd_sc_hd__a22oi_1 U733 ( .A1(s_mem_q[61]), .A2(n456), .B1(s_mem_q[70]), .B2(n453), .Y(n371) );
  sky130_fd_sc_hd__a22oi_1 U734 ( .A1(s_mem_q[43]), .A2(n462), .B1(s_mem_q[52]), .B2(n459), .Y(n370) );
  sky130_fd_sc_hd__a22oi_1 U735 ( .A1(s_mem_q[25]), .A2(n468), .B1(s_mem_q[34]), .B2(n465), .Y(n369) );
  sky130_fd_sc_hd__a22oi_1 U736 ( .A1(s_mem_q[7]), .A2(n474), .B1(s_mem_q[16]), 
        .B2(n471), .Y(n368) );
  sky130_fd_sc_hd__nand4_1 U737 ( .A(n371), .B(n370), .C(n369), .D(n368), .Y(
        n377) );
  sky130_fd_sc_hd__a22oi_1 U738 ( .A1(s_mem_q[133]), .A2(n480), .B1(
        s_mem_q[142]), .B2(n477), .Y(n375) );
  sky130_fd_sc_hd__a22oi_1 U739 ( .A1(s_mem_q[115]), .A2(n486), .B1(
        s_mem_q[124]), .B2(n483), .Y(n374) );
  sky130_fd_sc_hd__a22oi_1 U740 ( .A1(s_mem_q[97]), .A2(n492), .B1(
        s_mem_q[106]), .B2(n489), .Y(n373) );
  sky130_fd_sc_hd__a22oi_1 U741 ( .A1(s_mem_q[79]), .A2(n498), .B1(s_mem_q[88]), .B2(n495), .Y(n372) );
  sky130_fd_sc_hd__nand4_1 U742 ( .A(n375), .B(n374), .C(n373), .D(n372), .Y(
        n376) );
  sky130_fd_sc_hd__o21ai_0 U743 ( .A1(n377), .A2(n376), .B1(n439), .Y(n378) );
  sky130_fd_sc_hd__nand4_1 U744 ( .A(n381), .B(n380), .C(n379), .D(n378), .Y(
        dat_o[7]) );
  sky130_fd_sc_hd__a22oi_1 U745 ( .A1(s_mem_q[494]), .A2(n456), .B1(
        s_mem_q[503]), .B2(n453), .Y(n385) );
  sky130_fd_sc_hd__a22oi_1 U746 ( .A1(s_mem_q[476]), .A2(n462), .B1(
        s_mem_q[485]), .B2(n459), .Y(n384) );
  sky130_fd_sc_hd__a22oi_1 U747 ( .A1(s_mem_q[458]), .A2(n468), .B1(
        s_mem_q[467]), .B2(n465), .Y(n383) );
  sky130_fd_sc_hd__a22oi_1 U748 ( .A1(s_mem_q[440]), .A2(n474), .B1(
        s_mem_q[449]), .B2(n471), .Y(n382) );
  sky130_fd_sc_hd__nand4_1 U749 ( .A(n385), .B(n384), .C(n383), .D(n382), .Y(
        n392) );
  sky130_fd_sc_hd__a22oi_1 U750 ( .A1(s_mem_q[566]), .A2(n480), .B1(
        s_mem_q[575]), .B2(n477), .Y(n389) );
  sky130_fd_sc_hd__a22oi_1 U751 ( .A1(s_mem_q[548]), .A2(n486), .B1(
        s_mem_q[557]), .B2(n483), .Y(n388) );
  sky130_fd_sc_hd__a22oi_1 U752 ( .A1(s_mem_q[530]), .A2(n492), .B1(
        s_mem_q[539]), .B2(n489), .Y(n387) );
  sky130_fd_sc_hd__a22oi_1 U753 ( .A1(s_mem_q[512]), .A2(n498), .B1(
        s_mem_q[521]), .B2(n495), .Y(n386) );
  sky130_fd_sc_hd__nand4_1 U754 ( .A(n389), .B(n388), .C(n387), .D(n386), .Y(
        n391) );
  sky130_fd_sc_hd__o21ai_0 U755 ( .A1(n392), .A2(n391), .B1(n390), .Y(n445) );
  sky130_fd_sc_hd__a22oi_1 U756 ( .A1(s_mem_q[350]), .A2(n456), .B1(
        s_mem_q[359]), .B2(n453), .Y(n396) );
  sky130_fd_sc_hd__a22oi_1 U757 ( .A1(s_mem_q[332]), .A2(n462), .B1(
        s_mem_q[341]), .B2(n459), .Y(n395) );
  sky130_fd_sc_hd__a22oi_1 U758 ( .A1(s_mem_q[314]), .A2(n468), .B1(
        s_mem_q[323]), .B2(n465), .Y(n394) );
  sky130_fd_sc_hd__a22oi_1 U759 ( .A1(s_mem_q[296]), .A2(n474), .B1(
        s_mem_q[305]), .B2(n471), .Y(n393) );
  sky130_fd_sc_hd__nand4_1 U760 ( .A(n396), .B(n395), .C(n394), .D(n393), .Y(
        n403) );
  sky130_fd_sc_hd__a22oi_1 U761 ( .A1(s_mem_q[422]), .A2(n480), .B1(
        s_mem_q[431]), .B2(n477), .Y(n400) );
  sky130_fd_sc_hd__a22oi_1 U762 ( .A1(s_mem_q[404]), .A2(n486), .B1(
        s_mem_q[413]), .B2(n483), .Y(n399) );
  sky130_fd_sc_hd__a22oi_1 U763 ( .A1(s_mem_q[386]), .A2(n492), .B1(
        s_mem_q[395]), .B2(n489), .Y(n398) );
  sky130_fd_sc_hd__a22oi_1 U764 ( .A1(s_mem_q[368]), .A2(n498), .B1(
        s_mem_q[377]), .B2(n495), .Y(n397) );
  sky130_fd_sc_hd__nand4_1 U765 ( .A(n400), .B(n399), .C(n398), .D(n397), .Y(
        n402) );
  sky130_fd_sc_hd__o21ai_0 U766 ( .A1(n403), .A2(n402), .B1(n401), .Y(n444) );
  sky130_fd_sc_hd__a22oi_1 U767 ( .A1(s_mem_q[206]), .A2(n456), .B1(
        s_mem_q[215]), .B2(n453), .Y(n407) );
  sky130_fd_sc_hd__a22oi_1 U768 ( .A1(s_mem_q[188]), .A2(n462), .B1(
        s_mem_q[197]), .B2(n459), .Y(n406) );
  sky130_fd_sc_hd__a22oi_1 U769 ( .A1(s_mem_q[170]), .A2(n468), .B1(
        s_mem_q[179]), .B2(n465), .Y(n405) );
  sky130_fd_sc_hd__a22oi_1 U770 ( .A1(s_mem_q[152]), .A2(n474), .B1(
        s_mem_q[161]), .B2(n471), .Y(n404) );
  sky130_fd_sc_hd__nand4_1 U771 ( .A(n407), .B(n406), .C(n405), .D(n404), .Y(
        n414) );
  sky130_fd_sc_hd__a22oi_1 U772 ( .A1(s_mem_q[278]), .A2(n480), .B1(
        s_mem_q[287]), .B2(n477), .Y(n411) );
  sky130_fd_sc_hd__a22oi_1 U773 ( .A1(s_mem_q[260]), .A2(n486), .B1(
        s_mem_q[269]), .B2(n483), .Y(n410) );
  sky130_fd_sc_hd__a22oi_1 U774 ( .A1(s_mem_q[242]), .A2(n492), .B1(
        s_mem_q[251]), .B2(n489), .Y(n409) );
  sky130_fd_sc_hd__a22oi_1 U775 ( .A1(s_mem_q[224]), .A2(n498), .B1(
        s_mem_q[233]), .B2(n495), .Y(n408) );
  sky130_fd_sc_hd__nand4_1 U776 ( .A(n411), .B(n410), .C(n409), .D(n408), .Y(
        n413) );
  sky130_fd_sc_hd__o21ai_0 U777 ( .A1(n414), .A2(n413), .B1(n412), .Y(n443) );
  sky130_fd_sc_hd__a22oi_1 U778 ( .A1(s_mem_q[62]), .A2(n456), .B1(s_mem_q[71]), .B2(n453), .Y(n426) );
  sky130_fd_sc_hd__a22oi_1 U779 ( .A1(s_mem_q[44]), .A2(n462), .B1(s_mem_q[53]), .B2(n459), .Y(n425) );
  sky130_fd_sc_hd__a22oi_1 U780 ( .A1(s_mem_q[26]), .A2(n468), .B1(s_mem_q[35]), .B2(n465), .Y(n424) );
  sky130_fd_sc_hd__a22oi_1 U781 ( .A1(s_mem_q[8]), .A2(n474), .B1(s_mem_q[17]), 
        .B2(n471), .Y(n423) );
  sky130_fd_sc_hd__nand4_1 U782 ( .A(n426), .B(n425), .C(n424), .D(n423), .Y(
        n441) );
  sky130_fd_sc_hd__a22oi_1 U783 ( .A1(s_mem_q[134]), .A2(n480), .B1(
        s_mem_q[143]), .B2(n477), .Y(n438) );
  sky130_fd_sc_hd__a22oi_1 U784 ( .A1(s_mem_q[116]), .A2(n486), .B1(
        s_mem_q[125]), .B2(n483), .Y(n437) );
  sky130_fd_sc_hd__a22oi_1 U785 ( .A1(s_mem_q[98]), .A2(n492), .B1(
        s_mem_q[107]), .B2(n489), .Y(n436) );
  sky130_fd_sc_hd__a22oi_1 U786 ( .A1(s_mem_q[80]), .A2(n498), .B1(s_mem_q[89]), .B2(n495), .Y(n435) );
  sky130_fd_sc_hd__nand4_1 U787 ( .A(n438), .B(n437), .C(n436), .D(n435), .Y(
        n440) );
  sky130_fd_sc_hd__nand4_1 U788 ( .A(n445), .B(n444), .C(n443), .D(n442), .Y(
        dat_o[8]) );
  sky130_fd_sc_hd__o21ai_1 U789 ( .A1(n441), .A2(n440), .B1(n439), .Y(n442) );
  sky130_fd_sc_hd__inv_1 U790 ( .A(n566), .Y(n499) );
  sky130_fd_sc_hd__nand2_1 U791 ( .A(n558), .B(n1442), .Y(n1454) );
  sky130_fd_sc_hd__inv_1 U792 ( .A(n1443), .Y(n1420) );
  sky130_fd_sc_hd__inv_2 U793 ( .A(n1454), .Y(n566) );
  sky130_fd_sc_hd__inv_1 U794 ( .A(n558), .Y(n565) );
  sky130_fd_sc_hd__inv_1 U795 ( .A(n1459), .Y(n500) );
  sky130_fd_sc_hd__inv_1 U796 ( .A(n575), .Y(n502) );
  sky130_fd_sc_hd__inv_2 U797 ( .A(n502), .Y(n503) );
  sky130_fd_sc_hd__inv_2 U798 ( .A(n6), .Y(n584) );
  sky130_fd_sc_hd__buf_6 U799 ( .A(n1420), .X(n510) );
  sky130_fd_sc_hd__buf_2 U800 ( .A(n1420), .X(n511) );
  sky130_fd_sc_hd__inv_1 U801 ( .A(n560), .Y(n562) );
  sky130_fd_sc_hd__clkinv_1 U802 ( .A(cnt_o[2]), .Y(n572) );
  sky130_fd_sc_hd__inv_1 U803 ( .A(n555), .Y(n575) );
  sky130_fd_sc_hd__inv_1 U804 ( .A(n581), .Y(cnt_o[4]) );
  sky130_fd_sc_hd__inv_2 U805 ( .A(n508), .Y(cnt_o[5]) );
  sky130_fd_sc_hd__clkinv_1 U806 ( .A(n1461), .Y(n581) );
  sky130_fd_sc_hd__clkinv_2 U807 ( .A(cnt_o[0]), .Y(n567) );
  sky130_fd_sc_hd__nor2_1 U808 ( .A(cnt_o[2]), .B(cnt_o[3]), .Y(n563) );
  sky130_fd_sc_hd__o21ai_0 U809 ( .A1(n503), .A2(n6), .B1(n585), .Y(n576) );
  sky130_fd_sc_hd__o21ai_0 U810 ( .A1(n590), .A2(n505), .B1(n585), .Y(n568) );
  sky130_fd_sc_hd__nand2_1 U811 ( .A(cnt_o[6]), .B(n581), .Y(n561) );
  sky130_fd_sc_hd__nand3_1 U812 ( .A(n567), .B(n554), .C(n572), .Y(n555) );
  sky130_fd_sc_hd__nand2_1 U813 ( .A(n4), .B(n575), .Y(n1455) );
  sky130_fd_sc_hd__inv_1 U814 ( .A(flush_i), .Y(n1442) );
  sky130_fd_sc_hd__nand2_1 U815 ( .A(n504), .B(n566), .Y(n557) );
  sky130_fd_sc_hd__nand4_1 U816 ( .A(n563), .B(n562), .C(n554), .D(n7), .Y(
        n564) );
  sky130_fd_sc_hd__nand2_1 U817 ( .A(n584), .B(n505), .Y(n569) );
  sky130_fd_sc_hd__mux2i_1 U818 ( .A0(n569), .A1(n573), .S(cnt_o[1]), .Y(n570)
         );
  sky130_fd_sc_hd__a21o_1 U819 ( .A1(N109), .A2(n592), .B1(n570), .X(
        s_cnt_d[1]) );
  sky130_fd_sc_hd__a21oi_1 U820 ( .A1(cnt_o[2]), .A2(cnt_o[1]), .B1(n503), .Y(
        n574) );
  sky130_fd_sc_hd__nand2_1 U821 ( .A(N110), .B(n592), .Y(n571) );
  sky130_fd_sc_hd__o221ai_1 U822 ( .A1(n574), .A2(n590), .B1(n573), .B2(n572), 
        .C1(n571), .Y(s_cnt_d[2]) );
  sky130_fd_sc_hd__nand2_1 U823 ( .A(n584), .B(n503), .Y(n577) );
  sky130_fd_sc_hd__mux2i_1 U824 ( .A0(n577), .A1(n582), .S(cnt_o[3]), .Y(n578)
         );
  sky130_fd_sc_hd__a21o_1 U825 ( .A1(N111), .A2(n592), .B1(n578), .X(
        s_cnt_d[3]) );
  sky130_fd_sc_hd__nor4_1 U826 ( .A(cnt_o[2]), .B(cnt_o[0]), .C(cnt_o[3]), .D(
        cnt_o[1]), .Y(n579) );
  sky130_fd_sc_hd__nand2_1 U827 ( .A(n579), .B(n581), .Y(n1457) );
  sky130_fd_sc_hd__a21oi_1 U828 ( .A1(cnt_o[4]), .A2(cnt_o[3]), .B1(n586), .Y(
        n583) );
  sky130_fd_sc_hd__nand2_1 U829 ( .A(N112), .B(n592), .Y(n580) );
  sky130_fd_sc_hd__o221ai_1 U830 ( .A1(n583), .A2(n5), .B1(n582), .B2(n581), 
        .C1(n580), .Y(s_cnt_d[4]) );
  sky130_fd_sc_hd__nand2_1 U831 ( .A(n584), .B(n586), .Y(n588) );
  sky130_fd_sc_hd__o21ai_1 U832 ( .A1(n586), .A2(n5), .B1(n585), .Y(n593) );
  sky130_fd_sc_hd__mux2i_1 U833 ( .A0(n588), .A1(n587), .S(cnt_o[5]), .Y(n589)
         );
  sky130_fd_sc_hd__a21o_1 U834 ( .A1(N113), .A2(n592), .B1(n589), .X(
        s_cnt_d[5]) );
  sky130_fd_sc_hd__inv_1 U835 ( .A(n1459), .Y(n1456) );
  sky130_fd_sc_hd__nor3_1 U836 ( .A(n5), .B(n1456), .C(n508), .Y(n591) );
  sky130_fd_sc_hd__a221o_1 U837 ( .A1(n593), .A2(cnt_o[6]), .B1(N114), .B2(
        n592), .C1(n591), .X(s_cnt_d[6]) );
  sky130_fd_sc_hd__nand2_1 U838 ( .A(n21), .B(s_wr_ptr_q[5]), .Y(n594) );
  sky130_fd_sc_hd__nand2_1 U839 ( .A(n19), .B(s_wr_ptr_q[2]), .Y(n595) );
  sky130_fd_sc_hd__nand2_1 U840 ( .A(n596), .B(n511), .Y(n597) );
  sky130_fd_sc_hd__inv_1 U841 ( .A(s_mem_q[575]), .Y(n598) );
  sky130_fd_sc_hd__nand2_1 U842 ( .A(dat_i[8]), .B(n504), .Y(n1422) );
  sky130_fd_sc_hd__o22ai_1 U843 ( .A1(n607), .A2(n598), .B1(n512), .B2(n608), 
        .Y(s_mem_d[575]) );
  sky130_fd_sc_hd__nand2_1 U844 ( .A(dat_i[7]), .B(n504), .Y(n1424) );
  sky130_fd_sc_hd__inv_1 U845 ( .A(s_mem_q[574]), .Y(n599) );
  sky130_fd_sc_hd__o22ai_1 U846 ( .A1(n521), .A2(n608), .B1(n607), .B2(n599), 
        .Y(s_mem_d[574]) );
  sky130_fd_sc_hd__nand2_1 U847 ( .A(dat_i[6]), .B(n504), .Y(n1426) );
  sky130_fd_sc_hd__inv_1 U848 ( .A(s_mem_q[573]), .Y(n600) );
  sky130_fd_sc_hd__o22ai_1 U849 ( .A1(n526), .A2(n608), .B1(n607), .B2(n600), 
        .Y(s_mem_d[573]) );
  sky130_fd_sc_hd__nand2_1 U850 ( .A(dat_i[5]), .B(n504), .Y(n1428) );
  sky130_fd_sc_hd__inv_1 U851 ( .A(s_mem_q[572]), .Y(n601) );
  sky130_fd_sc_hd__o22ai_1 U852 ( .A1(n531), .A2(n608), .B1(n607), .B2(n601), 
        .Y(s_mem_d[572]) );
  sky130_fd_sc_hd__nand2_1 U853 ( .A(dat_i[4]), .B(n504), .Y(n1430) );
  sky130_fd_sc_hd__inv_1 U854 ( .A(s_mem_q[571]), .Y(n602) );
  sky130_fd_sc_hd__o22ai_1 U855 ( .A1(n536), .A2(n608), .B1(n607), .B2(n602), 
        .Y(s_mem_d[571]) );
  sky130_fd_sc_hd__nand2_1 U856 ( .A(dat_i[3]), .B(n504), .Y(n1432) );
  sky130_fd_sc_hd__inv_1 U857 ( .A(s_mem_q[570]), .Y(n603) );
  sky130_fd_sc_hd__o22ai_1 U858 ( .A1(n541), .A2(n608), .B1(n607), .B2(n603), 
        .Y(s_mem_d[570]) );
  sky130_fd_sc_hd__nand2_1 U859 ( .A(dat_i[2]), .B(n504), .Y(n1434) );
  sky130_fd_sc_hd__inv_1 U860 ( .A(s_mem_q[569]), .Y(n604) );
  sky130_fd_sc_hd__o22ai_1 U861 ( .A1(n546), .A2(n608), .B1(n607), .B2(n604), 
        .Y(s_mem_d[569]) );
  sky130_fd_sc_hd__nand2_1 U862 ( .A(dat_i[1]), .B(n504), .Y(n1436) );
  sky130_fd_sc_hd__inv_1 U863 ( .A(s_mem_q[568]), .Y(n605) );
  sky130_fd_sc_hd__o22ai_1 U864 ( .A1(n551), .A2(n608), .B1(n607), .B2(n605), 
        .Y(s_mem_d[568]) );
  sky130_fd_sc_hd__inv_1 U865 ( .A(s_mem_q[567]), .Y(n606) );
  sky130_fd_sc_hd__o22ai_1 U866 ( .A1(n1438), .A2(n608), .B1(n607), .B2(n606), 
        .Y(s_mem_d[567]) );
  sky130_fd_sc_hd__inv_1 U867 ( .A(s_wr_ptr_q[0]), .Y(n690) );
  sky130_fd_sc_hd__nand3_1 U868 ( .A(s_wr_ptr_q[2]), .B(s_wr_ptr_q[1]), .C(
        n690), .Y(n609) );
  sky130_fd_sc_hd__nand2_1 U869 ( .A(n610), .B(n510), .Y(n611) );
  sky130_fd_sc_hd__inv_1 U870 ( .A(s_mem_q[566]), .Y(n612) );
  sky130_fd_sc_hd__o22ai_1 U871 ( .A1(n622), .A2(n612), .B1(n512), .B2(n620), 
        .Y(s_mem_d[566]) );
  sky130_fd_sc_hd__inv_1 U872 ( .A(s_mem_q[565]), .Y(n613) );
  sky130_fd_sc_hd__o22ai_1 U873 ( .A1(n622), .A2(n613), .B1(n517), .B2(n620), 
        .Y(s_mem_d[565]) );
  sky130_fd_sc_hd__inv_1 U874 ( .A(s_mem_q[564]), .Y(n614) );
  sky130_fd_sc_hd__o22ai_1 U875 ( .A1(n622), .A2(n614), .B1(n522), .B2(n620), 
        .Y(s_mem_d[564]) );
  sky130_fd_sc_hd__inv_1 U876 ( .A(s_mem_q[563]), .Y(n615) );
  sky130_fd_sc_hd__o22ai_1 U877 ( .A1(n622), .A2(n615), .B1(n527), .B2(n620), 
        .Y(s_mem_d[563]) );
  sky130_fd_sc_hd__inv_1 U878 ( .A(s_mem_q[562]), .Y(n616) );
  sky130_fd_sc_hd__o22ai_1 U879 ( .A1(n622), .A2(n616), .B1(n532), .B2(n620), 
        .Y(s_mem_d[562]) );
  sky130_fd_sc_hd__inv_1 U880 ( .A(s_mem_q[561]), .Y(n617) );
  sky130_fd_sc_hd__o22ai_1 U881 ( .A1(n622), .A2(n617), .B1(n537), .B2(n620), 
        .Y(s_mem_d[561]) );
  sky130_fd_sc_hd__inv_1 U882 ( .A(s_mem_q[560]), .Y(n618) );
  sky130_fd_sc_hd__o22ai_1 U883 ( .A1(n622), .A2(n618), .B1(n542), .B2(n620), 
        .Y(s_mem_d[560]) );
  sky130_fd_sc_hd__inv_1 U884 ( .A(s_mem_q[559]), .Y(n619) );
  sky130_fd_sc_hd__o22ai_1 U885 ( .A1(n622), .A2(n619), .B1(n547), .B2(n620), 
        .Y(s_mem_d[559]) );
  sky130_fd_sc_hd__inv_1 U886 ( .A(s_mem_q[558]), .Y(n621) );
  sky130_fd_sc_hd__o22ai_1 U887 ( .A1(n622), .A2(n621), .B1(n1438), .B2(n620), 
        .Y(s_mem_d[558]) );
  sky130_fd_sc_hd__inv_1 U888 ( .A(s_wr_ptr_q[1]), .Y(n1449) );
  sky130_fd_sc_hd__nand3_1 U889 ( .A(s_wr_ptr_q[0]), .B(s_wr_ptr_q[2]), .C(
        n1449), .Y(n623) );
  sky130_fd_sc_hd__nand2_1 U890 ( .A(n624), .B(n511), .Y(n625) );
  sky130_fd_sc_hd__inv_1 U891 ( .A(s_mem_q[557]), .Y(n626) );
  sky130_fd_sc_hd__o22ai_1 U892 ( .A1(n636), .A2(n626), .B1(n512), .B2(n634), 
        .Y(s_mem_d[557]) );
  sky130_fd_sc_hd__inv_1 U893 ( .A(s_mem_q[556]), .Y(n627) );
  sky130_fd_sc_hd__o22ai_1 U894 ( .A1(n636), .A2(n627), .B1(n517), .B2(n634), 
        .Y(s_mem_d[556]) );
  sky130_fd_sc_hd__inv_1 U895 ( .A(s_mem_q[555]), .Y(n628) );
  sky130_fd_sc_hd__o22ai_1 U896 ( .A1(n636), .A2(n628), .B1(n522), .B2(n634), 
        .Y(s_mem_d[555]) );
  sky130_fd_sc_hd__inv_1 U897 ( .A(s_mem_q[554]), .Y(n629) );
  sky130_fd_sc_hd__o22ai_1 U898 ( .A1(n636), .A2(n629), .B1(n527), .B2(n634), 
        .Y(s_mem_d[554]) );
  sky130_fd_sc_hd__inv_1 U899 ( .A(s_mem_q[553]), .Y(n630) );
  sky130_fd_sc_hd__o22ai_1 U900 ( .A1(n636), .A2(n630), .B1(n532), .B2(n634), 
        .Y(s_mem_d[553]) );
  sky130_fd_sc_hd__inv_1 U901 ( .A(s_mem_q[552]), .Y(n631) );
  sky130_fd_sc_hd__o22ai_1 U902 ( .A1(n636), .A2(n631), .B1(n537), .B2(n634), 
        .Y(s_mem_d[552]) );
  sky130_fd_sc_hd__inv_1 U903 ( .A(s_mem_q[551]), .Y(n632) );
  sky130_fd_sc_hd__o22ai_1 U904 ( .A1(n636), .A2(n632), .B1(n542), .B2(n634), 
        .Y(s_mem_d[551]) );
  sky130_fd_sc_hd__inv_1 U905 ( .A(s_mem_q[550]), .Y(n633) );
  sky130_fd_sc_hd__o22ai_1 U906 ( .A1(n636), .A2(n633), .B1(n547), .B2(n634), 
        .Y(s_mem_d[550]) );
  sky130_fd_sc_hd__inv_1 U907 ( .A(s_mem_q[549]), .Y(n635) );
  sky130_fd_sc_hd__o22ai_1 U908 ( .A1(n636), .A2(n635), .B1(n1438), .B2(n634), 
        .Y(s_mem_d[549]) );
  sky130_fd_sc_hd__nand3_1 U909 ( .A(s_wr_ptr_q[2]), .B(n1449), .C(n690), .Y(
        n637) );
  sky130_fd_sc_hd__nand2_1 U910 ( .A(n638), .B(n510), .Y(n639) );
  sky130_fd_sc_hd__inv_1 U911 ( .A(s_mem_q[548]), .Y(n640) );
  sky130_fd_sc_hd__o22ai_1 U912 ( .A1(n650), .A2(n640), .B1(n512), .B2(n648), 
        .Y(s_mem_d[548]) );
  sky130_fd_sc_hd__inv_1 U913 ( .A(s_mem_q[547]), .Y(n641) );
  sky130_fd_sc_hd__o22ai_1 U914 ( .A1(n650), .A2(n641), .B1(n517), .B2(n648), 
        .Y(s_mem_d[547]) );
  sky130_fd_sc_hd__inv_1 U915 ( .A(s_mem_q[546]), .Y(n642) );
  sky130_fd_sc_hd__o22ai_1 U916 ( .A1(n650), .A2(n642), .B1(n522), .B2(n648), 
        .Y(s_mem_d[546]) );
  sky130_fd_sc_hd__inv_1 U917 ( .A(s_mem_q[545]), .Y(n643) );
  sky130_fd_sc_hd__o22ai_1 U918 ( .A1(n650), .A2(n643), .B1(n527), .B2(n648), 
        .Y(s_mem_d[545]) );
  sky130_fd_sc_hd__inv_1 U919 ( .A(s_mem_q[544]), .Y(n644) );
  sky130_fd_sc_hd__o22ai_1 U920 ( .A1(n650), .A2(n644), .B1(n532), .B2(n648), 
        .Y(s_mem_d[544]) );
  sky130_fd_sc_hd__inv_1 U921 ( .A(s_mem_q[543]), .Y(n645) );
  sky130_fd_sc_hd__o22ai_1 U922 ( .A1(n650), .A2(n645), .B1(n537), .B2(n648), 
        .Y(s_mem_d[543]) );
  sky130_fd_sc_hd__inv_1 U923 ( .A(s_mem_q[542]), .Y(n646) );
  sky130_fd_sc_hd__o22ai_1 U924 ( .A1(n650), .A2(n646), .B1(n542), .B2(n648), 
        .Y(s_mem_d[542]) );
  sky130_fd_sc_hd__inv_1 U925 ( .A(s_mem_q[541]), .Y(n647) );
  sky130_fd_sc_hd__o22ai_1 U926 ( .A1(n650), .A2(n647), .B1(n547), .B2(n648), 
        .Y(s_mem_d[541]) );
  sky130_fd_sc_hd__inv_1 U927 ( .A(s_mem_q[540]), .Y(n649) );
  sky130_fd_sc_hd__o22ai_1 U928 ( .A1(n650), .A2(n649), .B1(n1438), .B2(n648), 
        .Y(s_mem_d[540]) );
  sky130_fd_sc_hd__inv_1 U929 ( .A(s_wr_ptr_q[2]), .Y(n1447) );
  sky130_fd_sc_hd__nand2_1 U930 ( .A(n19), .B(n1447), .Y(n651) );
  sky130_fd_sc_hd__inv_1 U931 ( .A(s_mem_q[539]), .Y(n653) );
  sky130_fd_sc_hd__o22ai_1 U932 ( .A1(n13), .A2(n653), .B1(n512), .B2(n661), 
        .Y(s_mem_d[539]) );
  sky130_fd_sc_hd__inv_1 U933 ( .A(s_mem_q[538]), .Y(n654) );
  sky130_fd_sc_hd__o22ai_1 U934 ( .A1(n13), .A2(n654), .B1(n517), .B2(n661), 
        .Y(s_mem_d[538]) );
  sky130_fd_sc_hd__inv_1 U935 ( .A(s_mem_q[537]), .Y(n655) );
  sky130_fd_sc_hd__o22ai_1 U936 ( .A1(n13), .A2(n655), .B1(n522), .B2(n661), 
        .Y(s_mem_d[537]) );
  sky130_fd_sc_hd__inv_1 U937 ( .A(s_mem_q[536]), .Y(n656) );
  sky130_fd_sc_hd__o22ai_1 U938 ( .A1(n13), .A2(n656), .B1(n527), .B2(n661), 
        .Y(s_mem_d[536]) );
  sky130_fd_sc_hd__inv_1 U939 ( .A(s_mem_q[535]), .Y(n657) );
  sky130_fd_sc_hd__o22ai_1 U940 ( .A1(n13), .A2(n657), .B1(n532), .B2(n661), 
        .Y(s_mem_d[535]) );
  sky130_fd_sc_hd__inv_1 U941 ( .A(s_mem_q[534]), .Y(n658) );
  sky130_fd_sc_hd__o22ai_1 U942 ( .A1(n13), .A2(n658), .B1(n537), .B2(n661), 
        .Y(s_mem_d[534]) );
  sky130_fd_sc_hd__inv_1 U943 ( .A(s_mem_q[533]), .Y(n659) );
  sky130_fd_sc_hd__o22ai_1 U944 ( .A1(n13), .A2(n659), .B1(n542), .B2(n661), 
        .Y(s_mem_d[533]) );
  sky130_fd_sc_hd__inv_1 U945 ( .A(s_mem_q[532]), .Y(n660) );
  sky130_fd_sc_hd__o22ai_1 U946 ( .A1(n13), .A2(n660), .B1(n547), .B2(n661), 
        .Y(s_mem_d[532]) );
  sky130_fd_sc_hd__inv_1 U947 ( .A(s_mem_q[531]), .Y(n662) );
  sky130_fd_sc_hd__o22ai_1 U948 ( .A1(n13), .A2(n662), .B1(n1438), .B2(n661), 
        .Y(s_mem_d[531]) );
  sky130_fd_sc_hd__nand3_1 U949 ( .A(s_wr_ptr_q[1]), .B(n1447), .C(n690), .Y(
        n663) );
  sky130_fd_sc_hd__nand2_1 U950 ( .A(n664), .B(n510), .Y(n665) );
  sky130_fd_sc_hd__inv_1 U951 ( .A(s_mem_q[530]), .Y(n666) );
  sky130_fd_sc_hd__o22ai_1 U952 ( .A1(n676), .A2(n666), .B1(n512), .B2(n674), 
        .Y(s_mem_d[530]) );
  sky130_fd_sc_hd__inv_1 U953 ( .A(s_mem_q[529]), .Y(n667) );
  sky130_fd_sc_hd__o22ai_1 U954 ( .A1(n676), .A2(n667), .B1(n517), .B2(n674), 
        .Y(s_mem_d[529]) );
  sky130_fd_sc_hd__inv_1 U955 ( .A(s_mem_q[528]), .Y(n668) );
  sky130_fd_sc_hd__o22ai_1 U956 ( .A1(n676), .A2(n668), .B1(n522), .B2(n674), 
        .Y(s_mem_d[528]) );
  sky130_fd_sc_hd__inv_1 U957 ( .A(s_mem_q[527]), .Y(n669) );
  sky130_fd_sc_hd__o22ai_1 U958 ( .A1(n676), .A2(n669), .B1(n527), .B2(n674), 
        .Y(s_mem_d[527]) );
  sky130_fd_sc_hd__inv_1 U959 ( .A(s_mem_q[526]), .Y(n670) );
  sky130_fd_sc_hd__o22ai_1 U960 ( .A1(n676), .A2(n670), .B1(n532), .B2(n674), 
        .Y(s_mem_d[526]) );
  sky130_fd_sc_hd__inv_1 U961 ( .A(s_mem_q[525]), .Y(n671) );
  sky130_fd_sc_hd__o22ai_1 U962 ( .A1(n676), .A2(n671), .B1(n537), .B2(n674), 
        .Y(s_mem_d[525]) );
  sky130_fd_sc_hd__inv_1 U963 ( .A(s_mem_q[524]), .Y(n672) );
  sky130_fd_sc_hd__o22ai_1 U964 ( .A1(n676), .A2(n672), .B1(n542), .B2(n674), 
        .Y(s_mem_d[524]) );
  sky130_fd_sc_hd__inv_1 U965 ( .A(s_mem_q[523]), .Y(n673) );
  sky130_fd_sc_hd__o22ai_1 U966 ( .A1(n676), .A2(n673), .B1(n547), .B2(n674), 
        .Y(s_mem_d[523]) );
  sky130_fd_sc_hd__inv_1 U967 ( .A(s_mem_q[522]), .Y(n675) );
  sky130_fd_sc_hd__o22ai_1 U968 ( .A1(n676), .A2(n675), .B1(n1438), .B2(n674), 
        .Y(s_mem_d[522]) );
  sky130_fd_sc_hd__nand2_1 U969 ( .A(n677), .B(n511), .Y(n678) );
  sky130_fd_sc_hd__inv_1 U970 ( .A(s_mem_q[521]), .Y(n679) );
  sky130_fd_sc_hd__o22ai_1 U971 ( .A1(n689), .A2(n679), .B1(n512), .B2(n687), 
        .Y(s_mem_d[521]) );
  sky130_fd_sc_hd__inv_1 U972 ( .A(s_mem_q[520]), .Y(n680) );
  sky130_fd_sc_hd__o22ai_1 U973 ( .A1(n689), .A2(n680), .B1(n517), .B2(n687), 
        .Y(s_mem_d[520]) );
  sky130_fd_sc_hd__inv_1 U974 ( .A(s_mem_q[519]), .Y(n681) );
  sky130_fd_sc_hd__o22ai_1 U975 ( .A1(n689), .A2(n681), .B1(n522), .B2(n687), 
        .Y(s_mem_d[519]) );
  sky130_fd_sc_hd__inv_1 U976 ( .A(s_mem_q[518]), .Y(n682) );
  sky130_fd_sc_hd__o22ai_1 U977 ( .A1(n689), .A2(n682), .B1(n527), .B2(n687), 
        .Y(s_mem_d[518]) );
  sky130_fd_sc_hd__inv_1 U978 ( .A(s_mem_q[517]), .Y(n683) );
  sky130_fd_sc_hd__o22ai_1 U979 ( .A1(n689), .A2(n683), .B1(n532), .B2(n687), 
        .Y(s_mem_d[517]) );
  sky130_fd_sc_hd__inv_1 U980 ( .A(s_mem_q[516]), .Y(n684) );
  sky130_fd_sc_hd__o22ai_1 U981 ( .A1(n689), .A2(n684), .B1(n537), .B2(n687), 
        .Y(s_mem_d[516]) );
  sky130_fd_sc_hd__inv_1 U982 ( .A(s_mem_q[515]), .Y(n685) );
  sky130_fd_sc_hd__o22ai_1 U983 ( .A1(n689), .A2(n685), .B1(n542), .B2(n687), 
        .Y(s_mem_d[515]) );
  sky130_fd_sc_hd__inv_1 U984 ( .A(s_mem_q[514]), .Y(n686) );
  sky130_fd_sc_hd__o22ai_1 U985 ( .A1(n689), .A2(n686), .B1(n547), .B2(n687), 
        .Y(s_mem_d[514]) );
  sky130_fd_sc_hd__inv_1 U986 ( .A(s_mem_q[513]), .Y(n688) );
  sky130_fd_sc_hd__o22ai_1 U987 ( .A1(n689), .A2(n688), .B1(n1438), .B2(n687), 
        .Y(s_mem_d[513]) );
  sky130_fd_sc_hd__nand2_1 U988 ( .A(n692), .B(n510), .Y(n693) );
  sky130_fd_sc_hd__inv_1 U989 ( .A(s_mem_q[512]), .Y(n694) );
  sky130_fd_sc_hd__o22ai_1 U990 ( .A1(n704), .A2(n694), .B1(n512), .B2(n702), 
        .Y(s_mem_d[512]) );
  sky130_fd_sc_hd__inv_1 U991 ( .A(s_mem_q[511]), .Y(n695) );
  sky130_fd_sc_hd__o22ai_1 U992 ( .A1(n704), .A2(n695), .B1(n517), .B2(n702), 
        .Y(s_mem_d[511]) );
  sky130_fd_sc_hd__inv_1 U993 ( .A(s_mem_q[510]), .Y(n696) );
  sky130_fd_sc_hd__o22ai_1 U994 ( .A1(n704), .A2(n696), .B1(n522), .B2(n702), 
        .Y(s_mem_d[510]) );
  sky130_fd_sc_hd__inv_1 U995 ( .A(s_mem_q[509]), .Y(n697) );
  sky130_fd_sc_hd__o22ai_1 U996 ( .A1(n704), .A2(n697), .B1(n527), .B2(n702), 
        .Y(s_mem_d[509]) );
  sky130_fd_sc_hd__inv_1 U997 ( .A(s_mem_q[508]), .Y(n698) );
  sky130_fd_sc_hd__o22ai_1 U998 ( .A1(n704), .A2(n698), .B1(n532), .B2(n702), 
        .Y(s_mem_d[508]) );
  sky130_fd_sc_hd__inv_1 U999 ( .A(s_mem_q[507]), .Y(n699) );
  sky130_fd_sc_hd__o22ai_1 U1000 ( .A1(n704), .A2(n699), .B1(n537), .B2(n702), 
        .Y(s_mem_d[507]) );
  sky130_fd_sc_hd__inv_1 U1001 ( .A(s_mem_q[506]), .Y(n700) );
  sky130_fd_sc_hd__o22ai_1 U1002 ( .A1(n704), .A2(n700), .B1(n542), .B2(n702), 
        .Y(s_mem_d[506]) );
  sky130_fd_sc_hd__inv_1 U1003 ( .A(s_mem_q[505]), .Y(n701) );
  sky130_fd_sc_hd__o22ai_1 U1004 ( .A1(n704), .A2(n701), .B1(n547), .B2(n702), 
        .Y(s_mem_d[505]) );
  sky130_fd_sc_hd__inv_1 U1005 ( .A(s_mem_q[504]), .Y(n703) );
  sky130_fd_sc_hd__o22ai_1 U1006 ( .A1(n704), .A2(n703), .B1(n1438), .B2(n702), 
        .Y(s_mem_d[504]) );
  sky130_fd_sc_hd__inv_1 U1007 ( .A(s_wr_ptr_q[3]), .Y(n1446) );
  sky130_fd_sc_hd__nand3_1 U1008 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[4]), .C(
        n1446), .Y(n705) );
  sky130_fd_sc_hd__inv_1 U1009 ( .A(s_mem_q[503]), .Y(n707) );
  sky130_fd_sc_hd__o22ai_1 U1010 ( .A1(n12), .A2(n707), .B1(n512), .B2(n715), 
        .Y(s_mem_d[503]) );
  sky130_fd_sc_hd__inv_1 U1011 ( .A(s_mem_q[502]), .Y(n708) );
  sky130_fd_sc_hd__o22ai_1 U1012 ( .A1(n12), .A2(n708), .B1(n517), .B2(n715), 
        .Y(s_mem_d[502]) );
  sky130_fd_sc_hd__inv_1 U1013 ( .A(s_mem_q[501]), .Y(n709) );
  sky130_fd_sc_hd__o22ai_1 U1014 ( .A1(n12), .A2(n709), .B1(n522), .B2(n715), 
        .Y(s_mem_d[501]) );
  sky130_fd_sc_hd__inv_1 U1015 ( .A(s_mem_q[500]), .Y(n710) );
  sky130_fd_sc_hd__o22ai_1 U1016 ( .A1(n12), .A2(n710), .B1(n527), .B2(n715), 
        .Y(s_mem_d[500]) );
  sky130_fd_sc_hd__inv_1 U1017 ( .A(s_mem_q[499]), .Y(n711) );
  sky130_fd_sc_hd__o22ai_1 U1018 ( .A1(n12), .A2(n711), .B1(n532), .B2(n715), 
        .Y(s_mem_d[499]) );
  sky130_fd_sc_hd__inv_1 U1019 ( .A(s_mem_q[498]), .Y(n712) );
  sky130_fd_sc_hd__o22ai_1 U1020 ( .A1(n12), .A2(n712), .B1(n537), .B2(n715), 
        .Y(s_mem_d[498]) );
  sky130_fd_sc_hd__inv_1 U1021 ( .A(s_mem_q[497]), .Y(n713) );
  sky130_fd_sc_hd__o22ai_1 U1022 ( .A1(n12), .A2(n713), .B1(n542), .B2(n715), 
        .Y(s_mem_d[497]) );
  sky130_fd_sc_hd__inv_1 U1023 ( .A(s_mem_q[496]), .Y(n714) );
  sky130_fd_sc_hd__o22ai_1 U1024 ( .A1(n12), .A2(n714), .B1(n547), .B2(n715), 
        .Y(s_mem_d[496]) );
  sky130_fd_sc_hd__inv_1 U1025 ( .A(s_mem_q[495]), .Y(n716) );
  sky130_fd_sc_hd__o22ai_1 U1026 ( .A1(n12), .A2(n716), .B1(n1438), .B2(n715), 
        .Y(s_mem_d[495]) );
  sky130_fd_sc_hd__nand2_1 U1027 ( .A(n717), .B(n510), .Y(n718) );
  sky130_fd_sc_hd__inv_1 U1028 ( .A(s_mem_q[494]), .Y(n719) );
  sky130_fd_sc_hd__o22ai_1 U1029 ( .A1(n729), .A2(n719), .B1(n512), .B2(n727), 
        .Y(s_mem_d[494]) );
  sky130_fd_sc_hd__inv_1 U1030 ( .A(s_mem_q[493]), .Y(n720) );
  sky130_fd_sc_hd__o22ai_1 U1031 ( .A1(n729), .A2(n720), .B1(n517), .B2(n727), 
        .Y(s_mem_d[493]) );
  sky130_fd_sc_hd__inv_1 U1032 ( .A(s_mem_q[492]), .Y(n721) );
  sky130_fd_sc_hd__o22ai_1 U1033 ( .A1(n729), .A2(n721), .B1(n522), .B2(n727), 
        .Y(s_mem_d[492]) );
  sky130_fd_sc_hd__inv_1 U1034 ( .A(s_mem_q[491]), .Y(n722) );
  sky130_fd_sc_hd__o22ai_1 U1035 ( .A1(n729), .A2(n722), .B1(n527), .B2(n727), 
        .Y(s_mem_d[491]) );
  sky130_fd_sc_hd__inv_1 U1036 ( .A(s_mem_q[490]), .Y(n723) );
  sky130_fd_sc_hd__o22ai_1 U1037 ( .A1(n729), .A2(n723), .B1(n532), .B2(n727), 
        .Y(s_mem_d[490]) );
  sky130_fd_sc_hd__inv_1 U1038 ( .A(s_mem_q[489]), .Y(n724) );
  sky130_fd_sc_hd__o22ai_1 U1039 ( .A1(n729), .A2(n724), .B1(n537), .B2(n727), 
        .Y(s_mem_d[489]) );
  sky130_fd_sc_hd__inv_1 U1040 ( .A(s_mem_q[488]), .Y(n725) );
  sky130_fd_sc_hd__o22ai_1 U1041 ( .A1(n729), .A2(n725), .B1(n542), .B2(n727), 
        .Y(s_mem_d[488]) );
  sky130_fd_sc_hd__inv_1 U1042 ( .A(s_mem_q[487]), .Y(n726) );
  sky130_fd_sc_hd__o22ai_1 U1043 ( .A1(n729), .A2(n726), .B1(n547), .B2(n727), 
        .Y(s_mem_d[487]) );
  sky130_fd_sc_hd__inv_1 U1044 ( .A(s_mem_q[486]), .Y(n728) );
  sky130_fd_sc_hd__o22ai_1 U1045 ( .A1(n729), .A2(n728), .B1(n1438), .B2(n727), 
        .Y(s_mem_d[486]) );
  sky130_fd_sc_hd__nand2_1 U1046 ( .A(n730), .B(n511), .Y(n731) );
  sky130_fd_sc_hd__inv_1 U1047 ( .A(s_mem_q[485]), .Y(n732) );
  sky130_fd_sc_hd__o22ai_1 U1048 ( .A1(n742), .A2(n732), .B1(n512), .B2(n740), 
        .Y(s_mem_d[485]) );
  sky130_fd_sc_hd__inv_1 U1049 ( .A(s_mem_q[484]), .Y(n733) );
  sky130_fd_sc_hd__o22ai_1 U1050 ( .A1(n742), .A2(n733), .B1(n517), .B2(n740), 
        .Y(s_mem_d[484]) );
  sky130_fd_sc_hd__inv_1 U1051 ( .A(s_mem_q[483]), .Y(n734) );
  sky130_fd_sc_hd__o22ai_1 U1052 ( .A1(n742), .A2(n734), .B1(n522), .B2(n740), 
        .Y(s_mem_d[483]) );
  sky130_fd_sc_hd__inv_1 U1053 ( .A(s_mem_q[482]), .Y(n735) );
  sky130_fd_sc_hd__o22ai_1 U1054 ( .A1(n742), .A2(n735), .B1(n527), .B2(n740), 
        .Y(s_mem_d[482]) );
  sky130_fd_sc_hd__inv_1 U1055 ( .A(s_mem_q[481]), .Y(n736) );
  sky130_fd_sc_hd__o22ai_1 U1056 ( .A1(n742), .A2(n736), .B1(n532), .B2(n740), 
        .Y(s_mem_d[481]) );
  sky130_fd_sc_hd__inv_1 U1057 ( .A(s_mem_q[480]), .Y(n737) );
  sky130_fd_sc_hd__o22ai_1 U1058 ( .A1(n742), .A2(n737), .B1(n537), .B2(n740), 
        .Y(s_mem_d[480]) );
  sky130_fd_sc_hd__inv_1 U1059 ( .A(s_mem_q[479]), .Y(n738) );
  sky130_fd_sc_hd__o22ai_1 U1060 ( .A1(n742), .A2(n738), .B1(n542), .B2(n740), 
        .Y(s_mem_d[479]) );
  sky130_fd_sc_hd__inv_1 U1061 ( .A(s_mem_q[478]), .Y(n739) );
  sky130_fd_sc_hd__o22ai_1 U1062 ( .A1(n742), .A2(n739), .B1(n547), .B2(n740), 
        .Y(s_mem_d[478]) );
  sky130_fd_sc_hd__inv_1 U1063 ( .A(s_mem_q[477]), .Y(n741) );
  sky130_fd_sc_hd__o22ai_1 U1064 ( .A1(n742), .A2(n741), .B1(n1438), .B2(n740), 
        .Y(s_mem_d[477]) );
  sky130_fd_sc_hd__nand2_1 U1065 ( .A(n743), .B(n510), .Y(n744) );
  sky130_fd_sc_hd__inv_1 U1066 ( .A(s_mem_q[476]), .Y(n745) );
  sky130_fd_sc_hd__o22ai_1 U1067 ( .A1(n755), .A2(n745), .B1(n512), .B2(n753), 
        .Y(s_mem_d[476]) );
  sky130_fd_sc_hd__inv_1 U1068 ( .A(s_mem_q[475]), .Y(n746) );
  sky130_fd_sc_hd__o22ai_1 U1069 ( .A1(n755), .A2(n746), .B1(n517), .B2(n753), 
        .Y(s_mem_d[475]) );
  sky130_fd_sc_hd__inv_1 U1070 ( .A(s_mem_q[474]), .Y(n747) );
  sky130_fd_sc_hd__o22ai_1 U1071 ( .A1(n755), .A2(n747), .B1(n522), .B2(n753), 
        .Y(s_mem_d[474]) );
  sky130_fd_sc_hd__inv_1 U1072 ( .A(s_mem_q[473]), .Y(n748) );
  sky130_fd_sc_hd__o22ai_1 U1073 ( .A1(n755), .A2(n748), .B1(n527), .B2(n753), 
        .Y(s_mem_d[473]) );
  sky130_fd_sc_hd__inv_1 U1074 ( .A(s_mem_q[472]), .Y(n749) );
  sky130_fd_sc_hd__o22ai_1 U1075 ( .A1(n755), .A2(n749), .B1(n532), .B2(n753), 
        .Y(s_mem_d[472]) );
  sky130_fd_sc_hd__inv_1 U1076 ( .A(s_mem_q[471]), .Y(n750) );
  sky130_fd_sc_hd__o22ai_1 U1077 ( .A1(n755), .A2(n750), .B1(n537), .B2(n753), 
        .Y(s_mem_d[471]) );
  sky130_fd_sc_hd__inv_1 U1078 ( .A(s_mem_q[470]), .Y(n751) );
  sky130_fd_sc_hd__o22ai_1 U1079 ( .A1(n755), .A2(n751), .B1(n542), .B2(n753), 
        .Y(s_mem_d[470]) );
  sky130_fd_sc_hd__inv_1 U1080 ( .A(s_mem_q[469]), .Y(n752) );
  sky130_fd_sc_hd__o22ai_1 U1081 ( .A1(n755), .A2(n752), .B1(n547), .B2(n753), 
        .Y(s_mem_d[469]) );
  sky130_fd_sc_hd__inv_1 U1082 ( .A(s_mem_q[468]), .Y(n754) );
  sky130_fd_sc_hd__o22ai_1 U1083 ( .A1(n755), .A2(n754), .B1(n1438), .B2(n753), 
        .Y(s_mem_d[468]) );
  sky130_fd_sc_hd__nand2_1 U1084 ( .A(n756), .B(n510), .Y(n757) );
  sky130_fd_sc_hd__inv_1 U1085 ( .A(s_mem_q[467]), .Y(n758) );
  sky130_fd_sc_hd__o22ai_1 U1086 ( .A1(n768), .A2(n758), .B1(n512), .B2(n766), 
        .Y(s_mem_d[467]) );
  sky130_fd_sc_hd__inv_1 U1087 ( .A(s_mem_q[466]), .Y(n759) );
  sky130_fd_sc_hd__o22ai_1 U1088 ( .A1(n768), .A2(n759), .B1(n517), .B2(n766), 
        .Y(s_mem_d[466]) );
  sky130_fd_sc_hd__inv_1 U1089 ( .A(s_mem_q[465]), .Y(n760) );
  sky130_fd_sc_hd__o22ai_1 U1090 ( .A1(n768), .A2(n760), .B1(n522), .B2(n766), 
        .Y(s_mem_d[465]) );
  sky130_fd_sc_hd__inv_1 U1091 ( .A(s_mem_q[464]), .Y(n761) );
  sky130_fd_sc_hd__o22ai_1 U1092 ( .A1(n768), .A2(n761), .B1(n527), .B2(n766), 
        .Y(s_mem_d[464]) );
  sky130_fd_sc_hd__inv_1 U1093 ( .A(s_mem_q[463]), .Y(n762) );
  sky130_fd_sc_hd__o22ai_1 U1094 ( .A1(n768), .A2(n762), .B1(n532), .B2(n766), 
        .Y(s_mem_d[463]) );
  sky130_fd_sc_hd__inv_1 U1095 ( .A(s_mem_q[462]), .Y(n763) );
  sky130_fd_sc_hd__o22ai_1 U1096 ( .A1(n768), .A2(n763), .B1(n537), .B2(n766), 
        .Y(s_mem_d[462]) );
  sky130_fd_sc_hd__inv_1 U1097 ( .A(s_mem_q[461]), .Y(n764) );
  sky130_fd_sc_hd__o22ai_1 U1098 ( .A1(n768), .A2(n764), .B1(n542), .B2(n766), 
        .Y(s_mem_d[461]) );
  sky130_fd_sc_hd__inv_1 U1099 ( .A(s_mem_q[460]), .Y(n765) );
  sky130_fd_sc_hd__o22ai_1 U1100 ( .A1(n768), .A2(n765), .B1(n547), .B2(n766), 
        .Y(s_mem_d[460]) );
  sky130_fd_sc_hd__inv_1 U1101 ( .A(s_mem_q[459]), .Y(n767) );
  sky130_fd_sc_hd__o22ai_1 U1102 ( .A1(n768), .A2(n767), .B1(n1438), .B2(n766), 
        .Y(s_mem_d[459]) );
  sky130_fd_sc_hd__nand2_1 U1103 ( .A(n769), .B(n510), .Y(n770) );
  sky130_fd_sc_hd__inv_1 U1104 ( .A(s_mem_q[458]), .Y(n771) );
  sky130_fd_sc_hd__o22ai_1 U1105 ( .A1(n781), .A2(n771), .B1(n513), .B2(n779), 
        .Y(s_mem_d[458]) );
  sky130_fd_sc_hd__inv_1 U1106 ( .A(s_mem_q[457]), .Y(n772) );
  sky130_fd_sc_hd__o22ai_1 U1107 ( .A1(n781), .A2(n772), .B1(n517), .B2(n779), 
        .Y(s_mem_d[457]) );
  sky130_fd_sc_hd__inv_1 U1108 ( .A(s_mem_q[456]), .Y(n773) );
  sky130_fd_sc_hd__o22ai_1 U1109 ( .A1(n781), .A2(n773), .B1(n522), .B2(n779), 
        .Y(s_mem_d[456]) );
  sky130_fd_sc_hd__inv_1 U1110 ( .A(s_mem_q[455]), .Y(n774) );
  sky130_fd_sc_hd__o22ai_1 U1111 ( .A1(n781), .A2(n774), .B1(n527), .B2(n779), 
        .Y(s_mem_d[455]) );
  sky130_fd_sc_hd__inv_1 U1112 ( .A(s_mem_q[454]), .Y(n775) );
  sky130_fd_sc_hd__o22ai_1 U1113 ( .A1(n781), .A2(n775), .B1(n532), .B2(n779), 
        .Y(s_mem_d[454]) );
  sky130_fd_sc_hd__inv_1 U1114 ( .A(s_mem_q[453]), .Y(n776) );
  sky130_fd_sc_hd__o22ai_1 U1115 ( .A1(n781), .A2(n776), .B1(n537), .B2(n779), 
        .Y(s_mem_d[453]) );
  sky130_fd_sc_hd__inv_1 U1116 ( .A(s_mem_q[452]), .Y(n777) );
  sky130_fd_sc_hd__o22ai_1 U1117 ( .A1(n781), .A2(n777), .B1(n542), .B2(n779), 
        .Y(s_mem_d[452]) );
  sky130_fd_sc_hd__inv_1 U1118 ( .A(s_mem_q[451]), .Y(n778) );
  sky130_fd_sc_hd__o22ai_1 U1119 ( .A1(n781), .A2(n778), .B1(n547), .B2(n779), 
        .Y(s_mem_d[451]) );
  sky130_fd_sc_hd__inv_1 U1120 ( .A(s_mem_q[450]), .Y(n780) );
  sky130_fd_sc_hd__o22ai_1 U1121 ( .A1(n781), .A2(n780), .B1(n1438), .B2(n779), 
        .Y(s_mem_d[450]) );
  sky130_fd_sc_hd__nand2_1 U1122 ( .A(n782), .B(n510), .Y(n783) );
  sky130_fd_sc_hd__inv_1 U1123 ( .A(s_mem_q[449]), .Y(n784) );
  sky130_fd_sc_hd__o22ai_1 U1124 ( .A1(n794), .A2(n784), .B1(n513), .B2(n792), 
        .Y(s_mem_d[449]) );
  sky130_fd_sc_hd__inv_1 U1125 ( .A(s_mem_q[448]), .Y(n785) );
  sky130_fd_sc_hd__o22ai_1 U1126 ( .A1(n794), .A2(n785), .B1(n518), .B2(n792), 
        .Y(s_mem_d[448]) );
  sky130_fd_sc_hd__inv_1 U1127 ( .A(s_mem_q[447]), .Y(n786) );
  sky130_fd_sc_hd__o22ai_1 U1128 ( .A1(n794), .A2(n786), .B1(n523), .B2(n792), 
        .Y(s_mem_d[447]) );
  sky130_fd_sc_hd__inv_1 U1129 ( .A(s_mem_q[446]), .Y(n787) );
  sky130_fd_sc_hd__o22ai_1 U1130 ( .A1(n794), .A2(n787), .B1(n528), .B2(n792), 
        .Y(s_mem_d[446]) );
  sky130_fd_sc_hd__inv_1 U1131 ( .A(s_mem_q[445]), .Y(n788) );
  sky130_fd_sc_hd__o22ai_1 U1132 ( .A1(n794), .A2(n788), .B1(n533), .B2(n792), 
        .Y(s_mem_d[445]) );
  sky130_fd_sc_hd__inv_1 U1133 ( .A(s_mem_q[444]), .Y(n789) );
  sky130_fd_sc_hd__o22ai_1 U1134 ( .A1(n794), .A2(n789), .B1(n538), .B2(n792), 
        .Y(s_mem_d[444]) );
  sky130_fd_sc_hd__inv_1 U1135 ( .A(s_mem_q[443]), .Y(n790) );
  sky130_fd_sc_hd__o22ai_1 U1136 ( .A1(n794), .A2(n790), .B1(n543), .B2(n792), 
        .Y(s_mem_d[443]) );
  sky130_fd_sc_hd__inv_1 U1137 ( .A(s_mem_q[442]), .Y(n791) );
  sky130_fd_sc_hd__o22ai_1 U1138 ( .A1(n794), .A2(n791), .B1(n548), .B2(n792), 
        .Y(s_mem_d[442]) );
  sky130_fd_sc_hd__inv_1 U1139 ( .A(s_mem_q[441]), .Y(n793) );
  sky130_fd_sc_hd__o22ai_1 U1140 ( .A1(n794), .A2(n793), .B1(n1438), .B2(n792), 
        .Y(s_mem_d[441]) );
  sky130_fd_sc_hd__nand2_1 U1141 ( .A(n796), .B(n511), .Y(n797) );
  sky130_fd_sc_hd__inv_1 U1142 ( .A(s_mem_q[440]), .Y(n798) );
  sky130_fd_sc_hd__o22ai_1 U1143 ( .A1(n808), .A2(n798), .B1(n513), .B2(n806), 
        .Y(s_mem_d[440]) );
  sky130_fd_sc_hd__inv_1 U1144 ( .A(s_mem_q[439]), .Y(n799) );
  sky130_fd_sc_hd__o22ai_1 U1145 ( .A1(n808), .A2(n799), .B1(n518), .B2(n806), 
        .Y(s_mem_d[439]) );
  sky130_fd_sc_hd__inv_1 U1146 ( .A(s_mem_q[438]), .Y(n800) );
  sky130_fd_sc_hd__o22ai_1 U1147 ( .A1(n808), .A2(n800), .B1(n523), .B2(n806), 
        .Y(s_mem_d[438]) );
  sky130_fd_sc_hd__inv_1 U1148 ( .A(s_mem_q[437]), .Y(n801) );
  sky130_fd_sc_hd__o22ai_1 U1149 ( .A1(n808), .A2(n801), .B1(n528), .B2(n806), 
        .Y(s_mem_d[437]) );
  sky130_fd_sc_hd__inv_1 U1150 ( .A(s_mem_q[436]), .Y(n802) );
  sky130_fd_sc_hd__o22ai_1 U1151 ( .A1(n808), .A2(n802), .B1(n533), .B2(n806), 
        .Y(s_mem_d[436]) );
  sky130_fd_sc_hd__inv_1 U1152 ( .A(s_mem_q[435]), .Y(n803) );
  sky130_fd_sc_hd__o22ai_1 U1153 ( .A1(n808), .A2(n803), .B1(n538), .B2(n806), 
        .Y(s_mem_d[435]) );
  sky130_fd_sc_hd__inv_1 U1154 ( .A(s_mem_q[434]), .Y(n804) );
  sky130_fd_sc_hd__o22ai_1 U1155 ( .A1(n808), .A2(n804), .B1(n543), .B2(n806), 
        .Y(s_mem_d[434]) );
  sky130_fd_sc_hd__inv_1 U1156 ( .A(s_mem_q[433]), .Y(n805) );
  sky130_fd_sc_hd__o22ai_1 U1157 ( .A1(n808), .A2(n805), .B1(n548), .B2(n806), 
        .Y(s_mem_d[433]) );
  sky130_fd_sc_hd__inv_1 U1158 ( .A(s_mem_q[432]), .Y(n807) );
  sky130_fd_sc_hd__o22ai_1 U1159 ( .A1(n808), .A2(n807), .B1(n1438), .B2(n806), 
        .Y(s_mem_d[432]) );
  sky130_fd_sc_hd__inv_1 U1160 ( .A(s_wr_ptr_q[4]), .Y(n1445) );
  sky130_fd_sc_hd__nand3_1 U1161 ( .A(s_wr_ptr_q[5]), .B(s_wr_ptr_q[3]), .C(
        n1445), .Y(n809) );
  sky130_fd_sc_hd__nand2_1 U1162 ( .A(n810), .B(n510), .Y(n811) );
  sky130_fd_sc_hd__inv_1 U1163 ( .A(s_mem_q[431]), .Y(n812) );
  sky130_fd_sc_hd__o22ai_1 U1164 ( .A1(n822), .A2(n812), .B1(n513), .B2(n820), 
        .Y(s_mem_d[431]) );
  sky130_fd_sc_hd__inv_1 U1165 ( .A(s_mem_q[430]), .Y(n813) );
  sky130_fd_sc_hd__o22ai_1 U1166 ( .A1(n822), .A2(n813), .B1(n519), .B2(n820), 
        .Y(s_mem_d[430]) );
  sky130_fd_sc_hd__inv_1 U1167 ( .A(s_mem_q[429]), .Y(n814) );
  sky130_fd_sc_hd__o22ai_1 U1168 ( .A1(n822), .A2(n814), .B1(n524), .B2(n820), 
        .Y(s_mem_d[429]) );
  sky130_fd_sc_hd__inv_1 U1169 ( .A(s_mem_q[428]), .Y(n815) );
  sky130_fd_sc_hd__o22ai_1 U1170 ( .A1(n822), .A2(n815), .B1(n529), .B2(n820), 
        .Y(s_mem_d[428]) );
  sky130_fd_sc_hd__inv_1 U1171 ( .A(s_mem_q[427]), .Y(n816) );
  sky130_fd_sc_hd__o22ai_1 U1172 ( .A1(n822), .A2(n816), .B1(n534), .B2(n820), 
        .Y(s_mem_d[427]) );
  sky130_fd_sc_hd__inv_1 U1173 ( .A(s_mem_q[426]), .Y(n817) );
  sky130_fd_sc_hd__o22ai_1 U1174 ( .A1(n822), .A2(n817), .B1(n539), .B2(n820), 
        .Y(s_mem_d[426]) );
  sky130_fd_sc_hd__inv_1 U1175 ( .A(s_mem_q[425]), .Y(n818) );
  sky130_fd_sc_hd__o22ai_1 U1176 ( .A1(n822), .A2(n818), .B1(n544), .B2(n820), 
        .Y(s_mem_d[425]) );
  sky130_fd_sc_hd__inv_1 U1177 ( .A(s_mem_q[424]), .Y(n819) );
  sky130_fd_sc_hd__o22ai_1 U1178 ( .A1(n822), .A2(n819), .B1(n549), .B2(n820), 
        .Y(s_mem_d[424]) );
  sky130_fd_sc_hd__inv_1 U1179 ( .A(s_mem_q[423]), .Y(n821) );
  sky130_fd_sc_hd__o22ai_1 U1180 ( .A1(n822), .A2(n821), .B1(n1438), .B2(n820), 
        .Y(s_mem_d[423]) );
  sky130_fd_sc_hd__nand2_1 U1181 ( .A(n823), .B(n510), .Y(n824) );
  sky130_fd_sc_hd__inv_1 U1182 ( .A(s_mem_q[422]), .Y(n825) );
  sky130_fd_sc_hd__o22ai_1 U1183 ( .A1(n835), .A2(n825), .B1(n513), .B2(n833), 
        .Y(s_mem_d[422]) );
  sky130_fd_sc_hd__inv_1 U1184 ( .A(s_mem_q[421]), .Y(n826) );
  sky130_fd_sc_hd__o22ai_1 U1185 ( .A1(n835), .A2(n826), .B1(n518), .B2(n833), 
        .Y(s_mem_d[421]) );
  sky130_fd_sc_hd__inv_1 U1186 ( .A(s_mem_q[420]), .Y(n827) );
  sky130_fd_sc_hd__o22ai_1 U1187 ( .A1(n835), .A2(n827), .B1(n523), .B2(n833), 
        .Y(s_mem_d[420]) );
  sky130_fd_sc_hd__inv_1 U1188 ( .A(s_mem_q[419]), .Y(n828) );
  sky130_fd_sc_hd__o22ai_1 U1189 ( .A1(n835), .A2(n828), .B1(n528), .B2(n833), 
        .Y(s_mem_d[419]) );
  sky130_fd_sc_hd__inv_1 U1190 ( .A(s_mem_q[418]), .Y(n829) );
  sky130_fd_sc_hd__o22ai_1 U1191 ( .A1(n835), .A2(n829), .B1(n533), .B2(n833), 
        .Y(s_mem_d[418]) );
  sky130_fd_sc_hd__inv_1 U1192 ( .A(s_mem_q[417]), .Y(n830) );
  sky130_fd_sc_hd__o22ai_1 U1193 ( .A1(n835), .A2(n830), .B1(n538), .B2(n833), 
        .Y(s_mem_d[417]) );
  sky130_fd_sc_hd__inv_1 U1194 ( .A(s_mem_q[416]), .Y(n831) );
  sky130_fd_sc_hd__o22ai_1 U1195 ( .A1(n835), .A2(n831), .B1(n543), .B2(n833), 
        .Y(s_mem_d[416]) );
  sky130_fd_sc_hd__inv_1 U1196 ( .A(s_mem_q[415]), .Y(n832) );
  sky130_fd_sc_hd__o22ai_1 U1197 ( .A1(n835), .A2(n832), .B1(n548), .B2(n833), 
        .Y(s_mem_d[415]) );
  sky130_fd_sc_hd__inv_1 U1198 ( .A(s_mem_q[414]), .Y(n834) );
  sky130_fd_sc_hd__o22ai_1 U1199 ( .A1(n835), .A2(n834), .B1(n1438), .B2(n833), 
        .Y(s_mem_d[414]) );
  sky130_fd_sc_hd__nand2_1 U1200 ( .A(n836), .B(n510), .Y(n837) );
  sky130_fd_sc_hd__inv_1 U1201 ( .A(s_mem_q[413]), .Y(n838) );
  sky130_fd_sc_hd__o22ai_1 U1202 ( .A1(n848), .A2(n838), .B1(n513), .B2(n846), 
        .Y(s_mem_d[413]) );
  sky130_fd_sc_hd__inv_1 U1203 ( .A(s_mem_q[412]), .Y(n839) );
  sky130_fd_sc_hd__o22ai_1 U1204 ( .A1(n848), .A2(n839), .B1(n518), .B2(n846), 
        .Y(s_mem_d[412]) );
  sky130_fd_sc_hd__inv_1 U1205 ( .A(s_mem_q[411]), .Y(n840) );
  sky130_fd_sc_hd__o22ai_1 U1206 ( .A1(n848), .A2(n840), .B1(n523), .B2(n846), 
        .Y(s_mem_d[411]) );
  sky130_fd_sc_hd__inv_1 U1207 ( .A(s_mem_q[410]), .Y(n841) );
  sky130_fd_sc_hd__o22ai_1 U1208 ( .A1(n848), .A2(n841), .B1(n528), .B2(n846), 
        .Y(s_mem_d[410]) );
  sky130_fd_sc_hd__inv_1 U1209 ( .A(s_mem_q[409]), .Y(n842) );
  sky130_fd_sc_hd__o22ai_1 U1210 ( .A1(n848), .A2(n842), .B1(n533), .B2(n846), 
        .Y(s_mem_d[409]) );
  sky130_fd_sc_hd__inv_1 U1211 ( .A(s_mem_q[408]), .Y(n843) );
  sky130_fd_sc_hd__o22ai_1 U1212 ( .A1(n848), .A2(n843), .B1(n538), .B2(n846), 
        .Y(s_mem_d[408]) );
  sky130_fd_sc_hd__inv_1 U1213 ( .A(s_mem_q[407]), .Y(n844) );
  sky130_fd_sc_hd__o22ai_1 U1214 ( .A1(n848), .A2(n844), .B1(n543), .B2(n846), 
        .Y(s_mem_d[407]) );
  sky130_fd_sc_hd__inv_1 U1215 ( .A(s_mem_q[406]), .Y(n845) );
  sky130_fd_sc_hd__o22ai_1 U1216 ( .A1(n848), .A2(n845), .B1(n548), .B2(n846), 
        .Y(s_mem_d[406]) );
  sky130_fd_sc_hd__inv_1 U1217 ( .A(s_mem_q[405]), .Y(n847) );
  sky130_fd_sc_hd__o22ai_1 U1218 ( .A1(n848), .A2(n847), .B1(n1438), .B2(n846), 
        .Y(s_mem_d[405]) );
  sky130_fd_sc_hd__nand2_1 U1219 ( .A(n849), .B(n510), .Y(n850) );
  sky130_fd_sc_hd__inv_1 U1220 ( .A(s_mem_q[404]), .Y(n851) );
  sky130_fd_sc_hd__o22ai_1 U1221 ( .A1(n861), .A2(n851), .B1(n513), .B2(n859), 
        .Y(s_mem_d[404]) );
  sky130_fd_sc_hd__inv_1 U1222 ( .A(s_mem_q[403]), .Y(n852) );
  sky130_fd_sc_hd__o22ai_1 U1223 ( .A1(n861), .A2(n852), .B1(n518), .B2(n859), 
        .Y(s_mem_d[403]) );
  sky130_fd_sc_hd__inv_1 U1224 ( .A(s_mem_q[402]), .Y(n853) );
  sky130_fd_sc_hd__o22ai_1 U1225 ( .A1(n861), .A2(n853), .B1(n523), .B2(n859), 
        .Y(s_mem_d[402]) );
  sky130_fd_sc_hd__inv_1 U1226 ( .A(s_mem_q[401]), .Y(n854) );
  sky130_fd_sc_hd__o22ai_1 U1227 ( .A1(n861), .A2(n854), .B1(n528), .B2(n859), 
        .Y(s_mem_d[401]) );
  sky130_fd_sc_hd__inv_1 U1228 ( .A(s_mem_q[400]), .Y(n855) );
  sky130_fd_sc_hd__o22ai_1 U1229 ( .A1(n861), .A2(n855), .B1(n533), .B2(n859), 
        .Y(s_mem_d[400]) );
  sky130_fd_sc_hd__inv_1 U1230 ( .A(s_mem_q[399]), .Y(n856) );
  sky130_fd_sc_hd__o22ai_1 U1231 ( .A1(n861), .A2(n856), .B1(n538), .B2(n859), 
        .Y(s_mem_d[399]) );
  sky130_fd_sc_hd__inv_1 U1232 ( .A(s_mem_q[398]), .Y(n857) );
  sky130_fd_sc_hd__o22ai_1 U1233 ( .A1(n861), .A2(n857), .B1(n543), .B2(n859), 
        .Y(s_mem_d[398]) );
  sky130_fd_sc_hd__inv_1 U1234 ( .A(s_mem_q[397]), .Y(n858) );
  sky130_fd_sc_hd__o22ai_1 U1235 ( .A1(n861), .A2(n858), .B1(n548), .B2(n859), 
        .Y(s_mem_d[397]) );
  sky130_fd_sc_hd__inv_1 U1236 ( .A(s_mem_q[396]), .Y(n860) );
  sky130_fd_sc_hd__o22ai_1 U1237 ( .A1(n861), .A2(n860), .B1(n1438), .B2(n859), 
        .Y(s_mem_d[396]) );
  sky130_fd_sc_hd__inv_1 U1238 ( .A(s_mem_q[395]), .Y(n863) );
  sky130_fd_sc_hd__o22ai_1 U1239 ( .A1(n14), .A2(n863), .B1(n513), .B2(n871), 
        .Y(s_mem_d[395]) );
  sky130_fd_sc_hd__inv_1 U1240 ( .A(s_mem_q[394]), .Y(n864) );
  sky130_fd_sc_hd__o22ai_1 U1241 ( .A1(n14), .A2(n864), .B1(n518), .B2(n871), 
        .Y(s_mem_d[394]) );
  sky130_fd_sc_hd__inv_1 U1242 ( .A(s_mem_q[393]), .Y(n865) );
  sky130_fd_sc_hd__o22ai_1 U1243 ( .A1(n14), .A2(n865), .B1(n523), .B2(n871), 
        .Y(s_mem_d[393]) );
  sky130_fd_sc_hd__inv_1 U1244 ( .A(s_mem_q[392]), .Y(n866) );
  sky130_fd_sc_hd__o22ai_1 U1245 ( .A1(n14), .A2(n866), .B1(n528), .B2(n871), 
        .Y(s_mem_d[392]) );
  sky130_fd_sc_hd__inv_1 U1246 ( .A(s_mem_q[391]), .Y(n867) );
  sky130_fd_sc_hd__o22ai_1 U1247 ( .A1(n14), .A2(n867), .B1(n533), .B2(n871), 
        .Y(s_mem_d[391]) );
  sky130_fd_sc_hd__inv_1 U1248 ( .A(s_mem_q[390]), .Y(n868) );
  sky130_fd_sc_hd__o22ai_1 U1249 ( .A1(n14), .A2(n868), .B1(n538), .B2(n871), 
        .Y(s_mem_d[390]) );
  sky130_fd_sc_hd__inv_1 U1250 ( .A(s_mem_q[389]), .Y(n869) );
  sky130_fd_sc_hd__o22ai_1 U1251 ( .A1(n14), .A2(n869), .B1(n543), .B2(n871), 
        .Y(s_mem_d[389]) );
  sky130_fd_sc_hd__inv_1 U1252 ( .A(s_mem_q[388]), .Y(n870) );
  sky130_fd_sc_hd__o22ai_1 U1253 ( .A1(n14), .A2(n870), .B1(n548), .B2(n871), 
        .Y(s_mem_d[388]) );
  sky130_fd_sc_hd__inv_1 U1254 ( .A(s_mem_q[387]), .Y(n872) );
  sky130_fd_sc_hd__o22ai_1 U1255 ( .A1(n14), .A2(n872), .B1(n1438), .B2(n871), 
        .Y(s_mem_d[387]) );
  sky130_fd_sc_hd__nand2_1 U1256 ( .A(n873), .B(n510), .Y(n874) );
  sky130_fd_sc_hd__inv_1 U1257 ( .A(s_mem_q[386]), .Y(n875) );
  sky130_fd_sc_hd__o22ai_1 U1258 ( .A1(n885), .A2(n875), .B1(n513), .B2(n883), 
        .Y(s_mem_d[386]) );
  sky130_fd_sc_hd__inv_1 U1259 ( .A(s_mem_q[385]), .Y(n876) );
  sky130_fd_sc_hd__o22ai_1 U1260 ( .A1(n885), .A2(n876), .B1(n518), .B2(n883), 
        .Y(s_mem_d[385]) );
  sky130_fd_sc_hd__inv_1 U1261 ( .A(s_mem_q[384]), .Y(n877) );
  sky130_fd_sc_hd__o22ai_1 U1262 ( .A1(n885), .A2(n877), .B1(n523), .B2(n883), 
        .Y(s_mem_d[384]) );
  sky130_fd_sc_hd__inv_1 U1263 ( .A(s_mem_q[383]), .Y(n878) );
  sky130_fd_sc_hd__o22ai_1 U1264 ( .A1(n885), .A2(n878), .B1(n528), .B2(n883), 
        .Y(s_mem_d[383]) );
  sky130_fd_sc_hd__inv_1 U1265 ( .A(s_mem_q[382]), .Y(n879) );
  sky130_fd_sc_hd__o22ai_1 U1266 ( .A1(n885), .A2(n879), .B1(n533), .B2(n883), 
        .Y(s_mem_d[382]) );
  sky130_fd_sc_hd__inv_1 U1267 ( .A(s_mem_q[381]), .Y(n880) );
  sky130_fd_sc_hd__o22ai_1 U1268 ( .A1(n885), .A2(n880), .B1(n538), .B2(n883), 
        .Y(s_mem_d[381]) );
  sky130_fd_sc_hd__inv_1 U1269 ( .A(s_mem_q[380]), .Y(n881) );
  sky130_fd_sc_hd__o22ai_1 U1270 ( .A1(n885), .A2(n881), .B1(n543), .B2(n883), 
        .Y(s_mem_d[380]) );
  sky130_fd_sc_hd__inv_1 U1271 ( .A(s_mem_q[379]), .Y(n882) );
  sky130_fd_sc_hd__o22ai_1 U1272 ( .A1(n885), .A2(n882), .B1(n548), .B2(n883), 
        .Y(s_mem_d[379]) );
  sky130_fd_sc_hd__inv_1 U1273 ( .A(s_mem_q[378]), .Y(n884) );
  sky130_fd_sc_hd__o22ai_1 U1274 ( .A1(n885), .A2(n884), .B1(n1438), .B2(n883), 
        .Y(s_mem_d[378]) );
  sky130_fd_sc_hd__nand2_1 U1275 ( .A(n886), .B(n510), .Y(n887) );
  sky130_fd_sc_hd__inv_1 U1276 ( .A(s_mem_q[377]), .Y(n888) );
  sky130_fd_sc_hd__o22ai_1 U1277 ( .A1(n898), .A2(n888), .B1(n513), .B2(n896), 
        .Y(s_mem_d[377]) );
  sky130_fd_sc_hd__inv_1 U1278 ( .A(s_mem_q[376]), .Y(n889) );
  sky130_fd_sc_hd__o22ai_1 U1279 ( .A1(n898), .A2(n889), .B1(n518), .B2(n896), 
        .Y(s_mem_d[376]) );
  sky130_fd_sc_hd__inv_1 U1280 ( .A(s_mem_q[375]), .Y(n890) );
  sky130_fd_sc_hd__o22ai_1 U1281 ( .A1(n898), .A2(n890), .B1(n523), .B2(n896), 
        .Y(s_mem_d[375]) );
  sky130_fd_sc_hd__inv_1 U1282 ( .A(s_mem_q[374]), .Y(n891) );
  sky130_fd_sc_hd__o22ai_1 U1283 ( .A1(n898), .A2(n891), .B1(n528), .B2(n896), 
        .Y(s_mem_d[374]) );
  sky130_fd_sc_hd__inv_1 U1284 ( .A(s_mem_q[373]), .Y(n892) );
  sky130_fd_sc_hd__o22ai_1 U1285 ( .A1(n898), .A2(n892), .B1(n533), .B2(n896), 
        .Y(s_mem_d[373]) );
  sky130_fd_sc_hd__inv_1 U1286 ( .A(s_mem_q[372]), .Y(n893) );
  sky130_fd_sc_hd__o22ai_1 U1287 ( .A1(n898), .A2(n893), .B1(n538), .B2(n896), 
        .Y(s_mem_d[372]) );
  sky130_fd_sc_hd__inv_1 U1288 ( .A(s_mem_q[371]), .Y(n894) );
  sky130_fd_sc_hd__o22ai_1 U1289 ( .A1(n898), .A2(n894), .B1(n543), .B2(n896), 
        .Y(s_mem_d[371]) );
  sky130_fd_sc_hd__inv_1 U1290 ( .A(s_mem_q[370]), .Y(n895) );
  sky130_fd_sc_hd__o22ai_1 U1291 ( .A1(n898), .A2(n895), .B1(n548), .B2(n896), 
        .Y(s_mem_d[370]) );
  sky130_fd_sc_hd__inv_1 U1292 ( .A(s_mem_q[369]), .Y(n897) );
  sky130_fd_sc_hd__o22ai_1 U1293 ( .A1(n898), .A2(n897), .B1(n1438), .B2(n896), 
        .Y(s_mem_d[369]) );
  sky130_fd_sc_hd__inv_1 U1294 ( .A(s_mem_q[368]), .Y(n901) );
  sky130_fd_sc_hd__o22ai_1 U1295 ( .A1(n11), .A2(n901), .B1(n513), .B2(n909), 
        .Y(s_mem_d[368]) );
  sky130_fd_sc_hd__inv_1 U1296 ( .A(s_mem_q[367]), .Y(n902) );
  sky130_fd_sc_hd__o22ai_1 U1297 ( .A1(n11), .A2(n902), .B1(n518), .B2(n909), 
        .Y(s_mem_d[367]) );
  sky130_fd_sc_hd__inv_1 U1298 ( .A(s_mem_q[366]), .Y(n903) );
  sky130_fd_sc_hd__o22ai_1 U1299 ( .A1(n11), .A2(n903), .B1(n523), .B2(n909), 
        .Y(s_mem_d[366]) );
  sky130_fd_sc_hd__inv_1 U1300 ( .A(s_mem_q[365]), .Y(n904) );
  sky130_fd_sc_hd__o22ai_1 U1301 ( .A1(n11), .A2(n904), .B1(n528), .B2(n909), 
        .Y(s_mem_d[365]) );
  sky130_fd_sc_hd__inv_1 U1302 ( .A(s_mem_q[364]), .Y(n905) );
  sky130_fd_sc_hd__o22ai_1 U1303 ( .A1(n11), .A2(n905), .B1(n533), .B2(n909), 
        .Y(s_mem_d[364]) );
  sky130_fd_sc_hd__inv_1 U1304 ( .A(s_mem_q[363]), .Y(n906) );
  sky130_fd_sc_hd__o22ai_1 U1305 ( .A1(n11), .A2(n906), .B1(n538), .B2(n909), 
        .Y(s_mem_d[363]) );
  sky130_fd_sc_hd__inv_1 U1306 ( .A(s_mem_q[362]), .Y(n907) );
  sky130_fd_sc_hd__o22ai_1 U1307 ( .A1(n11), .A2(n907), .B1(n543), .B2(n909), 
        .Y(s_mem_d[362]) );
  sky130_fd_sc_hd__inv_1 U1308 ( .A(s_mem_q[361]), .Y(n908) );
  sky130_fd_sc_hd__o22ai_1 U1309 ( .A1(n11), .A2(n908), .B1(n548), .B2(n909), 
        .Y(s_mem_d[361]) );
  sky130_fd_sc_hd__inv_1 U1310 ( .A(s_mem_q[360]), .Y(n910) );
  sky130_fd_sc_hd__o22ai_1 U1311 ( .A1(n11), .A2(n910), .B1(n1438), .B2(n909), 
        .Y(s_mem_d[360]) );
  sky130_fd_sc_hd__nand3_1 U1312 ( .A(s_wr_ptr_q[5]), .B(n1445), .C(n1446), 
        .Y(n911) );
  sky130_fd_sc_hd__nand2_1 U1313 ( .A(n912), .B(n511), .Y(n913) );
  sky130_fd_sc_hd__inv_1 U1314 ( .A(s_mem_q[359]), .Y(n914) );
  sky130_fd_sc_hd__o22ai_1 U1315 ( .A1(n924), .A2(n914), .B1(n513), .B2(n922), 
        .Y(s_mem_d[359]) );
  sky130_fd_sc_hd__inv_1 U1316 ( .A(s_mem_q[358]), .Y(n915) );
  sky130_fd_sc_hd__o22ai_1 U1317 ( .A1(n924), .A2(n915), .B1(n518), .B2(n922), 
        .Y(s_mem_d[358]) );
  sky130_fd_sc_hd__inv_1 U1318 ( .A(s_mem_q[357]), .Y(n916) );
  sky130_fd_sc_hd__o22ai_1 U1319 ( .A1(n924), .A2(n916), .B1(n523), .B2(n922), 
        .Y(s_mem_d[357]) );
  sky130_fd_sc_hd__inv_1 U1320 ( .A(s_mem_q[356]), .Y(n917) );
  sky130_fd_sc_hd__o22ai_1 U1321 ( .A1(n924), .A2(n917), .B1(n528), .B2(n922), 
        .Y(s_mem_d[356]) );
  sky130_fd_sc_hd__inv_1 U1322 ( .A(s_mem_q[355]), .Y(n918) );
  sky130_fd_sc_hd__o22ai_1 U1323 ( .A1(n924), .A2(n918), .B1(n533), .B2(n922), 
        .Y(s_mem_d[355]) );
  sky130_fd_sc_hd__inv_1 U1324 ( .A(s_mem_q[354]), .Y(n919) );
  sky130_fd_sc_hd__o22ai_1 U1325 ( .A1(n924), .A2(n919), .B1(n538), .B2(n922), 
        .Y(s_mem_d[354]) );
  sky130_fd_sc_hd__inv_1 U1326 ( .A(s_mem_q[353]), .Y(n920) );
  sky130_fd_sc_hd__o22ai_1 U1327 ( .A1(n924), .A2(n920), .B1(n543), .B2(n922), 
        .Y(s_mem_d[353]) );
  sky130_fd_sc_hd__inv_1 U1328 ( .A(s_mem_q[352]), .Y(n921) );
  sky130_fd_sc_hd__o22ai_1 U1329 ( .A1(n924), .A2(n921), .B1(n548), .B2(n922), 
        .Y(s_mem_d[352]) );
  sky130_fd_sc_hd__inv_1 U1330 ( .A(s_mem_q[351]), .Y(n923) );
  sky130_fd_sc_hd__o22ai_1 U1331 ( .A1(n924), .A2(n923), .B1(n1438), .B2(n922), 
        .Y(s_mem_d[351]) );
  sky130_fd_sc_hd__inv_1 U1332 ( .A(s_mem_q[350]), .Y(n926) );
  sky130_fd_sc_hd__o22ai_1 U1333 ( .A1(n16), .A2(n926), .B1(n513), .B2(n934), 
        .Y(s_mem_d[350]) );
  sky130_fd_sc_hd__inv_1 U1334 ( .A(s_mem_q[349]), .Y(n927) );
  sky130_fd_sc_hd__o22ai_1 U1335 ( .A1(n16), .A2(n927), .B1(n518), .B2(n934), 
        .Y(s_mem_d[349]) );
  sky130_fd_sc_hd__inv_1 U1336 ( .A(s_mem_q[348]), .Y(n928) );
  sky130_fd_sc_hd__o22ai_1 U1337 ( .A1(n16), .A2(n928), .B1(n523), .B2(n934), 
        .Y(s_mem_d[348]) );
  sky130_fd_sc_hd__inv_1 U1338 ( .A(s_mem_q[347]), .Y(n929) );
  sky130_fd_sc_hd__o22ai_1 U1339 ( .A1(n16), .A2(n929), .B1(n528), .B2(n934), 
        .Y(s_mem_d[347]) );
  sky130_fd_sc_hd__inv_1 U1340 ( .A(s_mem_q[346]), .Y(n930) );
  sky130_fd_sc_hd__o22ai_1 U1341 ( .A1(n16), .A2(n930), .B1(n533), .B2(n934), 
        .Y(s_mem_d[346]) );
  sky130_fd_sc_hd__inv_1 U1342 ( .A(s_mem_q[345]), .Y(n931) );
  sky130_fd_sc_hd__o22ai_1 U1343 ( .A1(n16), .A2(n931), .B1(n538), .B2(n934), 
        .Y(s_mem_d[345]) );
  sky130_fd_sc_hd__inv_1 U1344 ( .A(s_mem_q[344]), .Y(n932) );
  sky130_fd_sc_hd__o22ai_1 U1345 ( .A1(n16), .A2(n932), .B1(n543), .B2(n934), 
        .Y(s_mem_d[344]) );
  sky130_fd_sc_hd__inv_1 U1346 ( .A(s_mem_q[343]), .Y(n933) );
  sky130_fd_sc_hd__o22ai_1 U1347 ( .A1(n16), .A2(n933), .B1(n548), .B2(n934), 
        .Y(s_mem_d[343]) );
  sky130_fd_sc_hd__inv_1 U1348 ( .A(s_mem_q[342]), .Y(n935) );
  sky130_fd_sc_hd__o22ai_1 U1349 ( .A1(n16), .A2(n935), .B1(n1438), .B2(n934), 
        .Y(s_mem_d[342]) );
  sky130_fd_sc_hd__nand2_1 U1350 ( .A(n936), .B(n510), .Y(n937) );
  sky130_fd_sc_hd__inv_1 U1351 ( .A(s_mem_q[341]), .Y(n938) );
  sky130_fd_sc_hd__o22ai_1 U1352 ( .A1(n948), .A2(n938), .B1(n514), .B2(n946), 
        .Y(s_mem_d[341]) );
  sky130_fd_sc_hd__inv_1 U1353 ( .A(s_mem_q[340]), .Y(n939) );
  sky130_fd_sc_hd__o22ai_1 U1354 ( .A1(n948), .A2(n939), .B1(n518), .B2(n946), 
        .Y(s_mem_d[340]) );
  sky130_fd_sc_hd__inv_1 U1355 ( .A(s_mem_q[339]), .Y(n940) );
  sky130_fd_sc_hd__o22ai_1 U1356 ( .A1(n948), .A2(n940), .B1(n523), .B2(n946), 
        .Y(s_mem_d[339]) );
  sky130_fd_sc_hd__inv_1 U1357 ( .A(s_mem_q[338]), .Y(n941) );
  sky130_fd_sc_hd__o22ai_1 U1358 ( .A1(n948), .A2(n941), .B1(n528), .B2(n946), 
        .Y(s_mem_d[338]) );
  sky130_fd_sc_hd__inv_1 U1359 ( .A(s_mem_q[337]), .Y(n942) );
  sky130_fd_sc_hd__o22ai_1 U1360 ( .A1(n948), .A2(n942), .B1(n533), .B2(n946), 
        .Y(s_mem_d[337]) );
  sky130_fd_sc_hd__inv_1 U1361 ( .A(s_mem_q[336]), .Y(n943) );
  sky130_fd_sc_hd__o22ai_1 U1362 ( .A1(n948), .A2(n943), .B1(n538), .B2(n946), 
        .Y(s_mem_d[336]) );
  sky130_fd_sc_hd__inv_1 U1363 ( .A(s_mem_q[335]), .Y(n944) );
  sky130_fd_sc_hd__o22ai_1 U1364 ( .A1(n948), .A2(n944), .B1(n543), .B2(n946), 
        .Y(s_mem_d[335]) );
  sky130_fd_sc_hd__inv_1 U1365 ( .A(s_mem_q[334]), .Y(n945) );
  sky130_fd_sc_hd__o22ai_1 U1366 ( .A1(n948), .A2(n945), .B1(n548), .B2(n946), 
        .Y(s_mem_d[334]) );
  sky130_fd_sc_hd__inv_1 U1367 ( .A(s_mem_q[333]), .Y(n947) );
  sky130_fd_sc_hd__o22ai_1 U1368 ( .A1(n948), .A2(n947), .B1(n1438), .B2(n946), 
        .Y(s_mem_d[333]) );
  sky130_fd_sc_hd__nand2_1 U1369 ( .A(n949), .B(n510), .Y(n950) );
  sky130_fd_sc_hd__inv_1 U1370 ( .A(s_mem_q[332]), .Y(n951) );
  sky130_fd_sc_hd__o22ai_1 U1371 ( .A1(n961), .A2(n951), .B1(n514), .B2(n959), 
        .Y(s_mem_d[332]) );
  sky130_fd_sc_hd__inv_1 U1372 ( .A(s_mem_q[331]), .Y(n952) );
  sky130_fd_sc_hd__o22ai_1 U1373 ( .A1(n961), .A2(n952), .B1(n518), .B2(n959), 
        .Y(s_mem_d[331]) );
  sky130_fd_sc_hd__inv_1 U1374 ( .A(s_mem_q[330]), .Y(n953) );
  sky130_fd_sc_hd__o22ai_1 U1375 ( .A1(n961), .A2(n953), .B1(n523), .B2(n959), 
        .Y(s_mem_d[330]) );
  sky130_fd_sc_hd__inv_1 U1376 ( .A(s_mem_q[329]), .Y(n954) );
  sky130_fd_sc_hd__o22ai_1 U1377 ( .A1(n961), .A2(n954), .B1(n528), .B2(n959), 
        .Y(s_mem_d[329]) );
  sky130_fd_sc_hd__inv_1 U1378 ( .A(s_mem_q[328]), .Y(n955) );
  sky130_fd_sc_hd__o22ai_1 U1379 ( .A1(n961), .A2(n955), .B1(n533), .B2(n959), 
        .Y(s_mem_d[328]) );
  sky130_fd_sc_hd__inv_1 U1380 ( .A(s_mem_q[327]), .Y(n956) );
  sky130_fd_sc_hd__o22ai_1 U1381 ( .A1(n961), .A2(n956), .B1(n538), .B2(n959), 
        .Y(s_mem_d[327]) );
  sky130_fd_sc_hd__inv_1 U1382 ( .A(s_mem_q[326]), .Y(n957) );
  sky130_fd_sc_hd__o22ai_1 U1383 ( .A1(n961), .A2(n957), .B1(n543), .B2(n959), 
        .Y(s_mem_d[326]) );
  sky130_fd_sc_hd__inv_1 U1384 ( .A(s_mem_q[325]), .Y(n958) );
  sky130_fd_sc_hd__o22ai_1 U1385 ( .A1(n961), .A2(n958), .B1(n548), .B2(n959), 
        .Y(s_mem_d[325]) );
  sky130_fd_sc_hd__inv_1 U1386 ( .A(s_mem_q[324]), .Y(n960) );
  sky130_fd_sc_hd__o22ai_1 U1387 ( .A1(n961), .A2(n960), .B1(n1438), .B2(n959), 
        .Y(s_mem_d[324]) );
  sky130_fd_sc_hd__nand2_1 U1388 ( .A(n962), .B(n510), .Y(n963) );
  sky130_fd_sc_hd__inv_1 U1389 ( .A(s_mem_q[323]), .Y(n964) );
  sky130_fd_sc_hd__o22ai_1 U1390 ( .A1(n974), .A2(n964), .B1(n514), .B2(n972), 
        .Y(s_mem_d[323]) );
  sky130_fd_sc_hd__inv_1 U1391 ( .A(s_mem_q[322]), .Y(n965) );
  sky130_fd_sc_hd__o22ai_1 U1392 ( .A1(n974), .A2(n965), .B1(n519), .B2(n972), 
        .Y(s_mem_d[322]) );
  sky130_fd_sc_hd__inv_1 U1393 ( .A(s_mem_q[321]), .Y(n966) );
  sky130_fd_sc_hd__o22ai_1 U1394 ( .A1(n974), .A2(n966), .B1(n524), .B2(n972), 
        .Y(s_mem_d[321]) );
  sky130_fd_sc_hd__inv_1 U1395 ( .A(s_mem_q[320]), .Y(n967) );
  sky130_fd_sc_hd__o22ai_1 U1396 ( .A1(n974), .A2(n967), .B1(n529), .B2(n972), 
        .Y(s_mem_d[320]) );
  sky130_fd_sc_hd__inv_1 U1397 ( .A(s_mem_q[319]), .Y(n968) );
  sky130_fd_sc_hd__o22ai_1 U1398 ( .A1(n974), .A2(n968), .B1(n534), .B2(n972), 
        .Y(s_mem_d[319]) );
  sky130_fd_sc_hd__inv_1 U1399 ( .A(s_mem_q[318]), .Y(n969) );
  sky130_fd_sc_hd__o22ai_1 U1400 ( .A1(n974), .A2(n969), .B1(n539), .B2(n972), 
        .Y(s_mem_d[318]) );
  sky130_fd_sc_hd__inv_1 U1401 ( .A(s_mem_q[317]), .Y(n970) );
  sky130_fd_sc_hd__o22ai_1 U1402 ( .A1(n974), .A2(n970), .B1(n544), .B2(n972), 
        .Y(s_mem_d[317]) );
  sky130_fd_sc_hd__inv_1 U1403 ( .A(s_mem_q[316]), .Y(n971) );
  sky130_fd_sc_hd__o22ai_1 U1404 ( .A1(n974), .A2(n971), .B1(n549), .B2(n972), 
        .Y(s_mem_d[316]) );
  sky130_fd_sc_hd__inv_1 U1405 ( .A(s_mem_q[315]), .Y(n973) );
  sky130_fd_sc_hd__o22ai_1 U1406 ( .A1(n974), .A2(n973), .B1(n1438), .B2(n972), 
        .Y(s_mem_d[315]) );
  sky130_fd_sc_hd__nand2_1 U1407 ( .A(n975), .B(n510), .Y(n976) );
  sky130_fd_sc_hd__inv_1 U1408 ( .A(s_mem_q[314]), .Y(n977) );
  sky130_fd_sc_hd__o22ai_1 U1409 ( .A1(n987), .A2(n977), .B1(n514), .B2(n985), 
        .Y(s_mem_d[314]) );
  sky130_fd_sc_hd__inv_1 U1410 ( .A(s_mem_q[313]), .Y(n978) );
  sky130_fd_sc_hd__o22ai_1 U1411 ( .A1(n987), .A2(n978), .B1(n519), .B2(n985), 
        .Y(s_mem_d[313]) );
  sky130_fd_sc_hd__inv_1 U1412 ( .A(s_mem_q[312]), .Y(n979) );
  sky130_fd_sc_hd__o22ai_1 U1413 ( .A1(n987), .A2(n979), .B1(n524), .B2(n985), 
        .Y(s_mem_d[312]) );
  sky130_fd_sc_hd__inv_1 U1414 ( .A(s_mem_q[311]), .Y(n980) );
  sky130_fd_sc_hd__o22ai_1 U1415 ( .A1(n987), .A2(n980), .B1(n529), .B2(n985), 
        .Y(s_mem_d[311]) );
  sky130_fd_sc_hd__inv_1 U1416 ( .A(s_mem_q[310]), .Y(n981) );
  sky130_fd_sc_hd__o22ai_1 U1417 ( .A1(n987), .A2(n981), .B1(n534), .B2(n985), 
        .Y(s_mem_d[310]) );
  sky130_fd_sc_hd__inv_1 U1418 ( .A(s_mem_q[309]), .Y(n982) );
  sky130_fd_sc_hd__o22ai_1 U1419 ( .A1(n987), .A2(n982), .B1(n539), .B2(n985), 
        .Y(s_mem_d[309]) );
  sky130_fd_sc_hd__inv_1 U1420 ( .A(s_mem_q[308]), .Y(n983) );
  sky130_fd_sc_hd__o22ai_1 U1421 ( .A1(n987), .A2(n983), .B1(n544), .B2(n985), 
        .Y(s_mem_d[308]) );
  sky130_fd_sc_hd__inv_1 U1422 ( .A(s_mem_q[307]), .Y(n984) );
  sky130_fd_sc_hd__o22ai_1 U1423 ( .A1(n987), .A2(n984), .B1(n549), .B2(n985), 
        .Y(s_mem_d[307]) );
  sky130_fd_sc_hd__inv_1 U1424 ( .A(s_mem_q[306]), .Y(n986) );
  sky130_fd_sc_hd__o22ai_1 U1425 ( .A1(n987), .A2(n986), .B1(n1438), .B2(n985), 
        .Y(s_mem_d[306]) );
  sky130_fd_sc_hd__nand2_1 U1426 ( .A(n988), .B(n510), .Y(n989) );
  sky130_fd_sc_hd__inv_1 U1427 ( .A(s_mem_q[305]), .Y(n990) );
  sky130_fd_sc_hd__o22ai_1 U1428 ( .A1(n1000), .A2(n990), .B1(n514), .B2(n998), 
        .Y(s_mem_d[305]) );
  sky130_fd_sc_hd__inv_1 U1429 ( .A(s_mem_q[304]), .Y(n991) );
  sky130_fd_sc_hd__o22ai_1 U1430 ( .A1(n1000), .A2(n991), .B1(n519), .B2(n998), 
        .Y(s_mem_d[304]) );
  sky130_fd_sc_hd__inv_1 U1431 ( .A(s_mem_q[303]), .Y(n992) );
  sky130_fd_sc_hd__o22ai_1 U1432 ( .A1(n1000), .A2(n992), .B1(n524), .B2(n998), 
        .Y(s_mem_d[303]) );
  sky130_fd_sc_hd__inv_1 U1433 ( .A(s_mem_q[302]), .Y(n993) );
  sky130_fd_sc_hd__o22ai_1 U1434 ( .A1(n1000), .A2(n993), .B1(n529), .B2(n998), 
        .Y(s_mem_d[302]) );
  sky130_fd_sc_hd__inv_1 U1435 ( .A(s_mem_q[301]), .Y(n994) );
  sky130_fd_sc_hd__o22ai_1 U1436 ( .A1(n1000), .A2(n994), .B1(n534), .B2(n998), 
        .Y(s_mem_d[301]) );
  sky130_fd_sc_hd__inv_1 U1437 ( .A(s_mem_q[300]), .Y(n995) );
  sky130_fd_sc_hd__o22ai_1 U1438 ( .A1(n1000), .A2(n995), .B1(n539), .B2(n998), 
        .Y(s_mem_d[300]) );
  sky130_fd_sc_hd__inv_1 U1439 ( .A(s_mem_q[299]), .Y(n996) );
  sky130_fd_sc_hd__o22ai_1 U1440 ( .A1(n1000), .A2(n996), .B1(n544), .B2(n998), 
        .Y(s_mem_d[299]) );
  sky130_fd_sc_hd__inv_1 U1441 ( .A(s_mem_q[298]), .Y(n997) );
  sky130_fd_sc_hd__o22ai_1 U1442 ( .A1(n1000), .A2(n997), .B1(n549), .B2(n998), 
        .Y(s_mem_d[298]) );
  sky130_fd_sc_hd__inv_1 U1443 ( .A(s_mem_q[297]), .Y(n999) );
  sky130_fd_sc_hd__o22ai_1 U1444 ( .A1(n1000), .A2(n999), .B1(n1438), .B2(n998), .Y(s_mem_d[297]) );
  sky130_fd_sc_hd__nand2_1 U1445 ( .A(n1002), .B(n510), .Y(n1003) );
  sky130_fd_sc_hd__inv_1 U1446 ( .A(s_mem_q[296]), .Y(n1004) );
  sky130_fd_sc_hd__o22ai_1 U1447 ( .A1(n1014), .A2(n1004), .B1(n514), .B2(
        n1012), .Y(s_mem_d[296]) );
  sky130_fd_sc_hd__inv_1 U1448 ( .A(s_mem_q[295]), .Y(n1005) );
  sky130_fd_sc_hd__o22ai_1 U1449 ( .A1(n1014), .A2(n1005), .B1(n519), .B2(
        n1012), .Y(s_mem_d[295]) );
  sky130_fd_sc_hd__inv_1 U1450 ( .A(s_mem_q[294]), .Y(n1006) );
  sky130_fd_sc_hd__o22ai_1 U1451 ( .A1(n1014), .A2(n1006), .B1(n524), .B2(
        n1012), .Y(s_mem_d[294]) );
  sky130_fd_sc_hd__inv_1 U1452 ( .A(s_mem_q[293]), .Y(n1007) );
  sky130_fd_sc_hd__o22ai_1 U1453 ( .A1(n1014), .A2(n1007), .B1(n529), .B2(
        n1012), .Y(s_mem_d[293]) );
  sky130_fd_sc_hd__inv_1 U1454 ( .A(s_mem_q[292]), .Y(n1008) );
  sky130_fd_sc_hd__o22ai_1 U1455 ( .A1(n1014), .A2(n1008), .B1(n534), .B2(
        n1012), .Y(s_mem_d[292]) );
  sky130_fd_sc_hd__inv_1 U1456 ( .A(s_mem_q[291]), .Y(n1009) );
  sky130_fd_sc_hd__o22ai_1 U1457 ( .A1(n1014), .A2(n1009), .B1(n539), .B2(
        n1012), .Y(s_mem_d[291]) );
  sky130_fd_sc_hd__inv_1 U1458 ( .A(s_mem_q[290]), .Y(n1010) );
  sky130_fd_sc_hd__o22ai_1 U1459 ( .A1(n1014), .A2(n1010), .B1(n544), .B2(
        n1012), .Y(s_mem_d[290]) );
  sky130_fd_sc_hd__inv_1 U1460 ( .A(s_mem_q[289]), .Y(n1011) );
  sky130_fd_sc_hd__o22ai_1 U1461 ( .A1(n1014), .A2(n1011), .B1(n549), .B2(
        n1012), .Y(s_mem_d[289]) );
  sky130_fd_sc_hd__inv_1 U1462 ( .A(s_mem_q[288]), .Y(n1013) );
  sky130_fd_sc_hd__o22ai_1 U1463 ( .A1(n1014), .A2(n1013), .B1(n1438), .B2(
        n1012), .Y(s_mem_d[288]) );
  sky130_fd_sc_hd__inv_1 U1464 ( .A(s_wr_ptr_q[5]), .Y(n1444) );
  sky130_fd_sc_hd__nand2_1 U1465 ( .A(n21), .B(n1444), .Y(n1015) );
  sky130_fd_sc_hd__nand2_1 U1466 ( .A(n1016), .B(n510), .Y(n1017) );
  sky130_fd_sc_hd__inv_1 U1467 ( .A(s_mem_q[287]), .Y(n1018) );
  sky130_fd_sc_hd__o22ai_1 U1468 ( .A1(n1028), .A2(n1018), .B1(n514), .B2(
        n1026), .Y(s_mem_d[287]) );
  sky130_fd_sc_hd__inv_1 U1469 ( .A(s_mem_q[286]), .Y(n1019) );
  sky130_fd_sc_hd__o22ai_1 U1470 ( .A1(n1028), .A2(n1019), .B1(n519), .B2(
        n1026), .Y(s_mem_d[286]) );
  sky130_fd_sc_hd__inv_1 U1471 ( .A(s_mem_q[285]), .Y(n1020) );
  sky130_fd_sc_hd__o22ai_1 U1472 ( .A1(n1028), .A2(n1020), .B1(n524), .B2(
        n1026), .Y(s_mem_d[285]) );
  sky130_fd_sc_hd__inv_1 U1473 ( .A(s_mem_q[284]), .Y(n1021) );
  sky130_fd_sc_hd__o22ai_1 U1474 ( .A1(n1028), .A2(n1021), .B1(n529), .B2(
        n1026), .Y(s_mem_d[284]) );
  sky130_fd_sc_hd__inv_1 U1475 ( .A(s_mem_q[283]), .Y(n1022) );
  sky130_fd_sc_hd__o22ai_1 U1476 ( .A1(n1028), .A2(n1022), .B1(n534), .B2(
        n1026), .Y(s_mem_d[283]) );
  sky130_fd_sc_hd__inv_1 U1477 ( .A(s_mem_q[282]), .Y(n1023) );
  sky130_fd_sc_hd__o22ai_1 U1478 ( .A1(n1028), .A2(n1023), .B1(n539), .B2(
        n1026), .Y(s_mem_d[282]) );
  sky130_fd_sc_hd__inv_1 U1479 ( .A(s_mem_q[281]), .Y(n1024) );
  sky130_fd_sc_hd__o22ai_1 U1480 ( .A1(n1028), .A2(n1024), .B1(n544), .B2(
        n1026), .Y(s_mem_d[281]) );
  sky130_fd_sc_hd__inv_1 U1481 ( .A(s_mem_q[280]), .Y(n1025) );
  sky130_fd_sc_hd__o22ai_1 U1482 ( .A1(n1028), .A2(n1025), .B1(n549), .B2(
        n1026), .Y(s_mem_d[280]) );
  sky130_fd_sc_hd__inv_1 U1483 ( .A(s_mem_q[279]), .Y(n1027) );
  sky130_fd_sc_hd__o22ai_1 U1484 ( .A1(n1028), .A2(n1027), .B1(n1438), .B2(
        n1026), .Y(s_mem_d[279]) );
  sky130_fd_sc_hd__inv_1 U1485 ( .A(s_mem_q[278]), .Y(n1030) );
  sky130_fd_sc_hd__o22ai_1 U1486 ( .A1(n15), .A2(n1030), .B1(n514), .B2(n1038), 
        .Y(s_mem_d[278]) );
  sky130_fd_sc_hd__inv_1 U1487 ( .A(s_mem_q[277]), .Y(n1031) );
  sky130_fd_sc_hd__o22ai_1 U1488 ( .A1(n15), .A2(n1031), .B1(n519), .B2(n1038), 
        .Y(s_mem_d[277]) );
  sky130_fd_sc_hd__inv_1 U1489 ( .A(s_mem_q[276]), .Y(n1032) );
  sky130_fd_sc_hd__o22ai_1 U1490 ( .A1(n15), .A2(n1032), .B1(n524), .B2(n1038), 
        .Y(s_mem_d[276]) );
  sky130_fd_sc_hd__inv_1 U1491 ( .A(s_mem_q[275]), .Y(n1033) );
  sky130_fd_sc_hd__o22ai_1 U1492 ( .A1(n15), .A2(n1033), .B1(n529), .B2(n1038), 
        .Y(s_mem_d[275]) );
  sky130_fd_sc_hd__inv_1 U1493 ( .A(s_mem_q[274]), .Y(n1034) );
  sky130_fd_sc_hd__o22ai_1 U1494 ( .A1(n15), .A2(n1034), .B1(n534), .B2(n1038), 
        .Y(s_mem_d[274]) );
  sky130_fd_sc_hd__inv_1 U1495 ( .A(s_mem_q[273]), .Y(n1035) );
  sky130_fd_sc_hd__o22ai_1 U1496 ( .A1(n15), .A2(n1035), .B1(n539), .B2(n1038), 
        .Y(s_mem_d[273]) );
  sky130_fd_sc_hd__inv_1 U1497 ( .A(s_mem_q[272]), .Y(n1036) );
  sky130_fd_sc_hd__o22ai_1 U1498 ( .A1(n15), .A2(n1036), .B1(n544), .B2(n1038), 
        .Y(s_mem_d[272]) );
  sky130_fd_sc_hd__inv_1 U1499 ( .A(s_mem_q[271]), .Y(n1037) );
  sky130_fd_sc_hd__o22ai_1 U1500 ( .A1(n15), .A2(n1037), .B1(n549), .B2(n1038), 
        .Y(s_mem_d[271]) );
  sky130_fd_sc_hd__inv_1 U1501 ( .A(s_mem_q[270]), .Y(n1039) );
  sky130_fd_sc_hd__o22ai_1 U1502 ( .A1(n15), .A2(n1039), .B1(n1438), .B2(n1038), .Y(s_mem_d[270]) );
  sky130_fd_sc_hd__nand2_1 U1503 ( .A(n1040), .B(n510), .Y(n1041) );
  sky130_fd_sc_hd__inv_1 U1504 ( .A(s_mem_q[269]), .Y(n1042) );
  sky130_fd_sc_hd__o22ai_1 U1505 ( .A1(n1052), .A2(n1042), .B1(n514), .B2(
        n1050), .Y(s_mem_d[269]) );
  sky130_fd_sc_hd__inv_1 U1506 ( .A(s_mem_q[268]), .Y(n1043) );
  sky130_fd_sc_hd__o22ai_1 U1507 ( .A1(n1052), .A2(n1043), .B1(n519), .B2(
        n1050), .Y(s_mem_d[268]) );
  sky130_fd_sc_hd__inv_1 U1508 ( .A(s_mem_q[267]), .Y(n1044) );
  sky130_fd_sc_hd__o22ai_1 U1509 ( .A1(n1052), .A2(n1044), .B1(n524), .B2(
        n1050), .Y(s_mem_d[267]) );
  sky130_fd_sc_hd__inv_1 U1510 ( .A(s_mem_q[266]), .Y(n1045) );
  sky130_fd_sc_hd__o22ai_1 U1511 ( .A1(n1052), .A2(n1045), .B1(n529), .B2(
        n1050), .Y(s_mem_d[266]) );
  sky130_fd_sc_hd__inv_1 U1512 ( .A(s_mem_q[265]), .Y(n1046) );
  sky130_fd_sc_hd__o22ai_1 U1513 ( .A1(n1052), .A2(n1046), .B1(n534), .B2(
        n1050), .Y(s_mem_d[265]) );
  sky130_fd_sc_hd__inv_1 U1514 ( .A(s_mem_q[264]), .Y(n1047) );
  sky130_fd_sc_hd__o22ai_1 U1515 ( .A1(n1052), .A2(n1047), .B1(n539), .B2(
        n1050), .Y(s_mem_d[264]) );
  sky130_fd_sc_hd__inv_1 U1516 ( .A(s_mem_q[263]), .Y(n1048) );
  sky130_fd_sc_hd__o22ai_1 U1517 ( .A1(n1052), .A2(n1048), .B1(n544), .B2(
        n1050), .Y(s_mem_d[263]) );
  sky130_fd_sc_hd__inv_1 U1518 ( .A(s_mem_q[262]), .Y(n1049) );
  sky130_fd_sc_hd__o22ai_1 U1519 ( .A1(n1052), .A2(n1049), .B1(n549), .B2(
        n1050), .Y(s_mem_d[262]) );
  sky130_fd_sc_hd__inv_1 U1520 ( .A(s_mem_q[261]), .Y(n1051) );
  sky130_fd_sc_hd__o22ai_1 U1521 ( .A1(n1052), .A2(n1051), .B1(n1438), .B2(
        n1050), .Y(s_mem_d[261]) );
  sky130_fd_sc_hd__nand2_1 U1522 ( .A(n1053), .B(n511), .Y(n1054) );
  sky130_fd_sc_hd__inv_1 U1523 ( .A(s_mem_q[260]), .Y(n1055) );
  sky130_fd_sc_hd__o22ai_1 U1524 ( .A1(n1065), .A2(n1055), .B1(n514), .B2(
        n1063), .Y(s_mem_d[260]) );
  sky130_fd_sc_hd__inv_1 U1525 ( .A(s_mem_q[259]), .Y(n1056) );
  sky130_fd_sc_hd__o22ai_1 U1526 ( .A1(n1065), .A2(n1056), .B1(n519), .B2(
        n1063), .Y(s_mem_d[259]) );
  sky130_fd_sc_hd__inv_1 U1527 ( .A(s_mem_q[258]), .Y(n1057) );
  sky130_fd_sc_hd__o22ai_1 U1528 ( .A1(n1065), .A2(n1057), .B1(n524), .B2(
        n1063), .Y(s_mem_d[258]) );
  sky130_fd_sc_hd__inv_1 U1529 ( .A(s_mem_q[257]), .Y(n1058) );
  sky130_fd_sc_hd__o22ai_1 U1530 ( .A1(n1065), .A2(n1058), .B1(n529), .B2(
        n1063), .Y(s_mem_d[257]) );
  sky130_fd_sc_hd__inv_1 U1531 ( .A(s_mem_q[256]), .Y(n1059) );
  sky130_fd_sc_hd__o22ai_1 U1532 ( .A1(n1065), .A2(n1059), .B1(n534), .B2(
        n1063), .Y(s_mem_d[256]) );
  sky130_fd_sc_hd__inv_1 U1533 ( .A(s_mem_q[255]), .Y(n1060) );
  sky130_fd_sc_hd__o22ai_1 U1534 ( .A1(n1065), .A2(n1060), .B1(n539), .B2(
        n1063), .Y(s_mem_d[255]) );
  sky130_fd_sc_hd__inv_1 U1535 ( .A(s_mem_q[254]), .Y(n1061) );
  sky130_fd_sc_hd__o22ai_1 U1536 ( .A1(n1065), .A2(n1061), .B1(n544), .B2(
        n1063), .Y(s_mem_d[254]) );
  sky130_fd_sc_hd__inv_1 U1537 ( .A(s_mem_q[253]), .Y(n1062) );
  sky130_fd_sc_hd__o22ai_1 U1538 ( .A1(n1065), .A2(n1062), .B1(n549), .B2(
        n1063), .Y(s_mem_d[253]) );
  sky130_fd_sc_hd__inv_1 U1539 ( .A(s_mem_q[252]), .Y(n1064) );
  sky130_fd_sc_hd__o22ai_1 U1540 ( .A1(n1065), .A2(n1064), .B1(n1438), .B2(
        n1063), .Y(s_mem_d[252]) );
  sky130_fd_sc_hd__nand2_1 U1541 ( .A(n1066), .B(n510), .Y(n1067) );
  sky130_fd_sc_hd__inv_1 U1542 ( .A(s_mem_q[251]), .Y(n1068) );
  sky130_fd_sc_hd__o22ai_1 U1543 ( .A1(n1078), .A2(n1068), .B1(n514), .B2(
        n1076), .Y(s_mem_d[251]) );
  sky130_fd_sc_hd__inv_1 U1544 ( .A(s_mem_q[250]), .Y(n1069) );
  sky130_fd_sc_hd__o22ai_1 U1545 ( .A1(n1078), .A2(n1069), .B1(n519), .B2(
        n1076), .Y(s_mem_d[250]) );
  sky130_fd_sc_hd__inv_1 U1546 ( .A(s_mem_q[249]), .Y(n1070) );
  sky130_fd_sc_hd__o22ai_1 U1547 ( .A1(n1078), .A2(n1070), .B1(n524), .B2(
        n1076), .Y(s_mem_d[249]) );
  sky130_fd_sc_hd__inv_1 U1548 ( .A(s_mem_q[248]), .Y(n1071) );
  sky130_fd_sc_hd__o22ai_1 U1549 ( .A1(n1078), .A2(n1071), .B1(n529), .B2(
        n1076), .Y(s_mem_d[248]) );
  sky130_fd_sc_hd__inv_1 U1550 ( .A(s_mem_q[247]), .Y(n1072) );
  sky130_fd_sc_hd__o22ai_1 U1551 ( .A1(n1078), .A2(n1072), .B1(n534), .B2(
        n1076), .Y(s_mem_d[247]) );
  sky130_fd_sc_hd__inv_1 U1552 ( .A(s_mem_q[246]), .Y(n1073) );
  sky130_fd_sc_hd__o22ai_1 U1553 ( .A1(n1078), .A2(n1073), .B1(n539), .B2(
        n1076), .Y(s_mem_d[246]) );
  sky130_fd_sc_hd__inv_1 U1554 ( .A(s_mem_q[245]), .Y(n1074) );
  sky130_fd_sc_hd__o22ai_1 U1555 ( .A1(n1078), .A2(n1074), .B1(n544), .B2(
        n1076), .Y(s_mem_d[245]) );
  sky130_fd_sc_hd__inv_1 U1556 ( .A(s_mem_q[244]), .Y(n1075) );
  sky130_fd_sc_hd__o22ai_1 U1557 ( .A1(n1078), .A2(n1075), .B1(n549), .B2(
        n1076), .Y(s_mem_d[244]) );
  sky130_fd_sc_hd__inv_1 U1558 ( .A(s_mem_q[243]), .Y(n1077) );
  sky130_fd_sc_hd__o22ai_1 U1559 ( .A1(n1078), .A2(n1077), .B1(n1438), .B2(
        n1076), .Y(s_mem_d[243]) );
  sky130_fd_sc_hd__nand2_1 U1560 ( .A(n1079), .B(n510), .Y(n1080) );
  sky130_fd_sc_hd__inv_1 U1561 ( .A(s_mem_q[242]), .Y(n1081) );
  sky130_fd_sc_hd__o22ai_1 U1562 ( .A1(n1091), .A2(n1081), .B1(n514), .B2(
        n1089), .Y(s_mem_d[242]) );
  sky130_fd_sc_hd__inv_1 U1563 ( .A(s_mem_q[241]), .Y(n1082) );
  sky130_fd_sc_hd__o22ai_1 U1564 ( .A1(n1091), .A2(n1082), .B1(n519), .B2(
        n1089), .Y(s_mem_d[241]) );
  sky130_fd_sc_hd__inv_1 U1565 ( .A(s_mem_q[240]), .Y(n1083) );
  sky130_fd_sc_hd__o22ai_1 U1566 ( .A1(n1091), .A2(n1083), .B1(n524), .B2(
        n1089), .Y(s_mem_d[240]) );
  sky130_fd_sc_hd__inv_1 U1567 ( .A(s_mem_q[239]), .Y(n1084) );
  sky130_fd_sc_hd__o22ai_1 U1568 ( .A1(n1091), .A2(n1084), .B1(n529), .B2(
        n1089), .Y(s_mem_d[239]) );
  sky130_fd_sc_hd__inv_1 U1569 ( .A(s_mem_q[238]), .Y(n1085) );
  sky130_fd_sc_hd__o22ai_1 U1570 ( .A1(n1091), .A2(n1085), .B1(n534), .B2(
        n1089), .Y(s_mem_d[238]) );
  sky130_fd_sc_hd__inv_1 U1571 ( .A(s_mem_q[237]), .Y(n1086) );
  sky130_fd_sc_hd__o22ai_1 U1572 ( .A1(n1091), .A2(n1086), .B1(n539), .B2(
        n1089), .Y(s_mem_d[237]) );
  sky130_fd_sc_hd__inv_1 U1573 ( .A(s_mem_q[236]), .Y(n1087) );
  sky130_fd_sc_hd__o22ai_1 U1574 ( .A1(n1091), .A2(n1087), .B1(n544), .B2(
        n1089), .Y(s_mem_d[236]) );
  sky130_fd_sc_hd__inv_1 U1575 ( .A(s_mem_q[235]), .Y(n1088) );
  sky130_fd_sc_hd__o22ai_1 U1576 ( .A1(n1091), .A2(n1088), .B1(n549), .B2(
        n1089), .Y(s_mem_d[235]) );
  sky130_fd_sc_hd__inv_1 U1577 ( .A(s_mem_q[234]), .Y(n1090) );
  sky130_fd_sc_hd__o22ai_1 U1578 ( .A1(n1091), .A2(n1090), .B1(n1438), .B2(
        n1089), .Y(s_mem_d[234]) );
  sky130_fd_sc_hd__nand2_1 U1579 ( .A(n1092), .B(n510), .Y(n1093) );
  sky130_fd_sc_hd__inv_1 U1580 ( .A(s_mem_q[233]), .Y(n1094) );
  sky130_fd_sc_hd__o22ai_1 U1581 ( .A1(n1104), .A2(n1094), .B1(n514), .B2(
        n1102), .Y(s_mem_d[233]) );
  sky130_fd_sc_hd__inv_1 U1582 ( .A(s_mem_q[232]), .Y(n1095) );
  sky130_fd_sc_hd__o22ai_1 U1583 ( .A1(n1104), .A2(n1095), .B1(n519), .B2(
        n1102), .Y(s_mem_d[232]) );
  sky130_fd_sc_hd__inv_1 U1584 ( .A(s_mem_q[231]), .Y(n1096) );
  sky130_fd_sc_hd__o22ai_1 U1585 ( .A1(n1104), .A2(n1096), .B1(n524), .B2(
        n1102), .Y(s_mem_d[231]) );
  sky130_fd_sc_hd__inv_1 U1586 ( .A(s_mem_q[230]), .Y(n1097) );
  sky130_fd_sc_hd__o22ai_1 U1587 ( .A1(n1104), .A2(n1097), .B1(n529), .B2(
        n1102), .Y(s_mem_d[230]) );
  sky130_fd_sc_hd__inv_1 U1588 ( .A(s_mem_q[229]), .Y(n1098) );
  sky130_fd_sc_hd__o22ai_1 U1589 ( .A1(n1104), .A2(n1098), .B1(n534), .B2(
        n1102), .Y(s_mem_d[229]) );
  sky130_fd_sc_hd__inv_1 U1590 ( .A(s_mem_q[228]), .Y(n1099) );
  sky130_fd_sc_hd__o22ai_1 U1591 ( .A1(n1104), .A2(n1099), .B1(n539), .B2(
        n1102), .Y(s_mem_d[228]) );
  sky130_fd_sc_hd__inv_1 U1592 ( .A(s_mem_q[227]), .Y(n1100) );
  sky130_fd_sc_hd__o22ai_1 U1593 ( .A1(n1104), .A2(n1100), .B1(n544), .B2(
        n1102), .Y(s_mem_d[227]) );
  sky130_fd_sc_hd__inv_1 U1594 ( .A(s_mem_q[226]), .Y(n1101) );
  sky130_fd_sc_hd__o22ai_1 U1595 ( .A1(n1104), .A2(n1101), .B1(n549), .B2(
        n1102), .Y(s_mem_d[226]) );
  sky130_fd_sc_hd__inv_1 U1596 ( .A(s_mem_q[225]), .Y(n1103) );
  sky130_fd_sc_hd__o22ai_1 U1597 ( .A1(n1104), .A2(n1103), .B1(n1438), .B2(
        n1102), .Y(s_mem_d[225]) );
  sky130_fd_sc_hd__nand2_1 U1598 ( .A(n1106), .B(n511), .Y(n1107) );
  sky130_fd_sc_hd__inv_1 U1599 ( .A(s_mem_q[224]), .Y(n1108) );
  sky130_fd_sc_hd__o22ai_1 U1600 ( .A1(n1118), .A2(n1108), .B1(n515), .B2(
        n1116), .Y(s_mem_d[224]) );
  sky130_fd_sc_hd__inv_1 U1601 ( .A(s_mem_q[223]), .Y(n1109) );
  sky130_fd_sc_hd__o22ai_1 U1602 ( .A1(n1118), .A2(n1109), .B1(n519), .B2(
        n1116), .Y(s_mem_d[223]) );
  sky130_fd_sc_hd__inv_1 U1603 ( .A(s_mem_q[222]), .Y(n1110) );
  sky130_fd_sc_hd__o22ai_1 U1604 ( .A1(n1118), .A2(n1110), .B1(n524), .B2(
        n1116), .Y(s_mem_d[222]) );
  sky130_fd_sc_hd__inv_1 U1605 ( .A(s_mem_q[221]), .Y(n1111) );
  sky130_fd_sc_hd__o22ai_1 U1606 ( .A1(n1118), .A2(n1111), .B1(n529), .B2(
        n1116), .Y(s_mem_d[221]) );
  sky130_fd_sc_hd__inv_1 U1607 ( .A(s_mem_q[220]), .Y(n1112) );
  sky130_fd_sc_hd__o22ai_1 U1608 ( .A1(n1118), .A2(n1112), .B1(n534), .B2(
        n1116), .Y(s_mem_d[220]) );
  sky130_fd_sc_hd__inv_1 U1609 ( .A(s_mem_q[219]), .Y(n1113) );
  sky130_fd_sc_hd__o22ai_1 U1610 ( .A1(n1118), .A2(n1113), .B1(n539), .B2(
        n1116), .Y(s_mem_d[219]) );
  sky130_fd_sc_hd__inv_1 U1611 ( .A(s_mem_q[218]), .Y(n1114) );
  sky130_fd_sc_hd__o22ai_1 U1612 ( .A1(n1118), .A2(n1114), .B1(n544), .B2(
        n1116), .Y(s_mem_d[218]) );
  sky130_fd_sc_hd__inv_1 U1613 ( .A(s_mem_q[217]), .Y(n1115) );
  sky130_fd_sc_hd__o22ai_1 U1614 ( .A1(n1118), .A2(n1115), .B1(n549), .B2(
        n1116), .Y(s_mem_d[217]) );
  sky130_fd_sc_hd__inv_1 U1615 ( .A(s_mem_q[216]), .Y(n1117) );
  sky130_fd_sc_hd__o22ai_1 U1616 ( .A1(n1118), .A2(n1117), .B1(n1438), .B2(
        n1116), .Y(s_mem_d[216]) );
  sky130_fd_sc_hd__nand2_1 U1617 ( .A(n1119), .B(n510), .Y(n1120) );
  sky130_fd_sc_hd__inv_1 U1618 ( .A(s_mem_q[215]), .Y(n1121) );
  sky130_fd_sc_hd__o22ai_1 U1619 ( .A1(n1131), .A2(n1121), .B1(n515), .B2(
        n1129), .Y(s_mem_d[215]) );
  sky130_fd_sc_hd__inv_1 U1620 ( .A(s_mem_q[214]), .Y(n1122) );
  sky130_fd_sc_hd__o22ai_1 U1621 ( .A1(n1131), .A2(n1122), .B1(n520), .B2(
        n1129), .Y(s_mem_d[214]) );
  sky130_fd_sc_hd__inv_1 U1622 ( .A(s_mem_q[213]), .Y(n1123) );
  sky130_fd_sc_hd__o22ai_1 U1623 ( .A1(n1131), .A2(n1123), .B1(n525), .B2(
        n1129), .Y(s_mem_d[213]) );
  sky130_fd_sc_hd__inv_1 U1624 ( .A(s_mem_q[212]), .Y(n1124) );
  sky130_fd_sc_hd__o22ai_1 U1625 ( .A1(n1131), .A2(n1124), .B1(n530), .B2(
        n1129), .Y(s_mem_d[212]) );
  sky130_fd_sc_hd__inv_1 U1626 ( .A(s_mem_q[211]), .Y(n1125) );
  sky130_fd_sc_hd__o22ai_1 U1627 ( .A1(n1131), .A2(n1125), .B1(n535), .B2(
        n1129), .Y(s_mem_d[211]) );
  sky130_fd_sc_hd__inv_1 U1628 ( .A(s_mem_q[210]), .Y(n1126) );
  sky130_fd_sc_hd__o22ai_1 U1629 ( .A1(n1131), .A2(n1126), .B1(n540), .B2(
        n1129), .Y(s_mem_d[210]) );
  sky130_fd_sc_hd__inv_1 U1630 ( .A(s_mem_q[209]), .Y(n1127) );
  sky130_fd_sc_hd__o22ai_1 U1631 ( .A1(n1131), .A2(n1127), .B1(n545), .B2(
        n1129), .Y(s_mem_d[209]) );
  sky130_fd_sc_hd__inv_1 U1632 ( .A(s_mem_q[208]), .Y(n1128) );
  sky130_fd_sc_hd__o22ai_1 U1633 ( .A1(n1131), .A2(n1128), .B1(n550), .B2(
        n1129), .Y(s_mem_d[208]) );
  sky130_fd_sc_hd__inv_1 U1634 ( .A(s_mem_q[207]), .Y(n1130) );
  sky130_fd_sc_hd__o22ai_1 U1635 ( .A1(n1131), .A2(n1130), .B1(n1438), .B2(
        n1129), .Y(s_mem_d[207]) );
  sky130_fd_sc_hd__nand2_1 U1636 ( .A(n1132), .B(n510), .Y(n1133) );
  sky130_fd_sc_hd__inv_1 U1637 ( .A(s_mem_q[206]), .Y(n1134) );
  sky130_fd_sc_hd__o22ai_1 U1638 ( .A1(n1144), .A2(n1134), .B1(n515), .B2(
        n1142), .Y(s_mem_d[206]) );
  sky130_fd_sc_hd__inv_1 U1639 ( .A(s_mem_q[205]), .Y(n1135) );
  sky130_fd_sc_hd__o22ai_1 U1640 ( .A1(n1144), .A2(n1135), .B1(n520), .B2(
        n1142), .Y(s_mem_d[205]) );
  sky130_fd_sc_hd__inv_1 U1641 ( .A(s_mem_q[204]), .Y(n1136) );
  sky130_fd_sc_hd__o22ai_1 U1642 ( .A1(n1144), .A2(n1136), .B1(n525), .B2(
        n1142), .Y(s_mem_d[204]) );
  sky130_fd_sc_hd__inv_1 U1643 ( .A(s_mem_q[203]), .Y(n1137) );
  sky130_fd_sc_hd__o22ai_1 U1644 ( .A1(n1144), .A2(n1137), .B1(n530), .B2(
        n1142), .Y(s_mem_d[203]) );
  sky130_fd_sc_hd__inv_1 U1645 ( .A(s_mem_q[202]), .Y(n1138) );
  sky130_fd_sc_hd__o22ai_1 U1646 ( .A1(n1144), .A2(n1138), .B1(n535), .B2(
        n1142), .Y(s_mem_d[202]) );
  sky130_fd_sc_hd__inv_1 U1647 ( .A(s_mem_q[201]), .Y(n1139) );
  sky130_fd_sc_hd__o22ai_1 U1648 ( .A1(n1144), .A2(n1139), .B1(n540), .B2(
        n1142), .Y(s_mem_d[201]) );
  sky130_fd_sc_hd__inv_1 U1649 ( .A(s_mem_q[200]), .Y(n1140) );
  sky130_fd_sc_hd__o22ai_1 U1650 ( .A1(n1144), .A2(n1140), .B1(n545), .B2(
        n1142), .Y(s_mem_d[200]) );
  sky130_fd_sc_hd__inv_1 U1651 ( .A(s_mem_q[199]), .Y(n1141) );
  sky130_fd_sc_hd__o22ai_1 U1652 ( .A1(n1144), .A2(n1141), .B1(n550), .B2(
        n1142), .Y(s_mem_d[199]) );
  sky130_fd_sc_hd__inv_1 U1653 ( .A(s_mem_q[198]), .Y(n1143) );
  sky130_fd_sc_hd__o22ai_1 U1654 ( .A1(n1144), .A2(n1143), .B1(n1438), .B2(
        n1142), .Y(s_mem_d[198]) );
  sky130_fd_sc_hd__nand2_1 U1655 ( .A(n1145), .B(n510), .Y(n1146) );
  sky130_fd_sc_hd__inv_1 U1656 ( .A(s_mem_q[197]), .Y(n1147) );
  sky130_fd_sc_hd__o22ai_1 U1657 ( .A1(n1157), .A2(n1147), .B1(n515), .B2(
        n1155), .Y(s_mem_d[197]) );
  sky130_fd_sc_hd__inv_1 U1658 ( .A(s_mem_q[196]), .Y(n1148) );
  sky130_fd_sc_hd__o22ai_1 U1659 ( .A1(n1157), .A2(n1148), .B1(n520), .B2(
        n1155), .Y(s_mem_d[196]) );
  sky130_fd_sc_hd__inv_1 U1660 ( .A(s_mem_q[195]), .Y(n1149) );
  sky130_fd_sc_hd__o22ai_1 U1661 ( .A1(n1157), .A2(n1149), .B1(n525), .B2(
        n1155), .Y(s_mem_d[195]) );
  sky130_fd_sc_hd__inv_1 U1662 ( .A(s_mem_q[194]), .Y(n1150) );
  sky130_fd_sc_hd__o22ai_1 U1663 ( .A1(n1157), .A2(n1150), .B1(n530), .B2(
        n1155), .Y(s_mem_d[194]) );
  sky130_fd_sc_hd__inv_1 U1664 ( .A(s_mem_q[193]), .Y(n1151) );
  sky130_fd_sc_hd__o22ai_1 U1665 ( .A1(n1157), .A2(n1151), .B1(n535), .B2(
        n1155), .Y(s_mem_d[193]) );
  sky130_fd_sc_hd__inv_1 U1666 ( .A(s_mem_q[192]), .Y(n1152) );
  sky130_fd_sc_hd__o22ai_1 U1667 ( .A1(n1157), .A2(n1152), .B1(n540), .B2(
        n1155), .Y(s_mem_d[192]) );
  sky130_fd_sc_hd__inv_1 U1668 ( .A(s_mem_q[191]), .Y(n1153) );
  sky130_fd_sc_hd__o22ai_1 U1669 ( .A1(n1157), .A2(n1153), .B1(n545), .B2(
        n1155), .Y(s_mem_d[191]) );
  sky130_fd_sc_hd__inv_1 U1670 ( .A(s_mem_q[190]), .Y(n1154) );
  sky130_fd_sc_hd__o22ai_1 U1671 ( .A1(n1157), .A2(n1154), .B1(n550), .B2(
        n1155), .Y(s_mem_d[190]) );
  sky130_fd_sc_hd__inv_1 U1672 ( .A(s_mem_q[189]), .Y(n1156) );
  sky130_fd_sc_hd__o22ai_1 U1673 ( .A1(n1157), .A2(n1156), .B1(n1438), .B2(
        n1155), .Y(s_mem_d[189]) );
  sky130_fd_sc_hd__nand2_1 U1674 ( .A(n1158), .B(n510), .Y(n1159) );
  sky130_fd_sc_hd__inv_1 U1675 ( .A(s_mem_q[188]), .Y(n1160) );
  sky130_fd_sc_hd__o22ai_1 U1676 ( .A1(n1170), .A2(n1160), .B1(n515), .B2(
        n1168), .Y(s_mem_d[188]) );
  sky130_fd_sc_hd__inv_1 U1677 ( .A(s_mem_q[187]), .Y(n1161) );
  sky130_fd_sc_hd__o22ai_1 U1678 ( .A1(n1170), .A2(n1161), .B1(n520), .B2(
        n1168), .Y(s_mem_d[187]) );
  sky130_fd_sc_hd__inv_1 U1679 ( .A(s_mem_q[186]), .Y(n1162) );
  sky130_fd_sc_hd__o22ai_1 U1680 ( .A1(n1170), .A2(n1162), .B1(n525), .B2(
        n1168), .Y(s_mem_d[186]) );
  sky130_fd_sc_hd__inv_1 U1681 ( .A(s_mem_q[185]), .Y(n1163) );
  sky130_fd_sc_hd__o22ai_1 U1682 ( .A1(n1170), .A2(n1163), .B1(n530), .B2(
        n1168), .Y(s_mem_d[185]) );
  sky130_fd_sc_hd__inv_1 U1683 ( .A(s_mem_q[184]), .Y(n1164) );
  sky130_fd_sc_hd__o22ai_1 U1684 ( .A1(n1170), .A2(n1164), .B1(n535), .B2(
        n1168), .Y(s_mem_d[184]) );
  sky130_fd_sc_hd__inv_1 U1685 ( .A(s_mem_q[183]), .Y(n1165) );
  sky130_fd_sc_hd__o22ai_1 U1686 ( .A1(n1170), .A2(n1165), .B1(n540), .B2(
        n1168), .Y(s_mem_d[183]) );
  sky130_fd_sc_hd__inv_1 U1687 ( .A(s_mem_q[182]), .Y(n1166) );
  sky130_fd_sc_hd__o22ai_1 U1688 ( .A1(n1170), .A2(n1166), .B1(n545), .B2(
        n1168), .Y(s_mem_d[182]) );
  sky130_fd_sc_hd__inv_1 U1689 ( .A(s_mem_q[181]), .Y(n1167) );
  sky130_fd_sc_hd__o22ai_1 U1690 ( .A1(n1170), .A2(n1167), .B1(n550), .B2(
        n1168), .Y(s_mem_d[181]) );
  sky130_fd_sc_hd__inv_1 U1691 ( .A(s_mem_q[180]), .Y(n1169) );
  sky130_fd_sc_hd__o22ai_1 U1692 ( .A1(n1170), .A2(n1169), .B1(n1438), .B2(
        n1168), .Y(s_mem_d[180]) );
  sky130_fd_sc_hd__nand2_1 U1693 ( .A(n1171), .B(n510), .Y(n1172) );
  sky130_fd_sc_hd__inv_1 U1694 ( .A(s_mem_q[179]), .Y(n1173) );
  sky130_fd_sc_hd__o22ai_1 U1695 ( .A1(n1183), .A2(n1173), .B1(n515), .B2(
        n1181), .Y(s_mem_d[179]) );
  sky130_fd_sc_hd__inv_1 U1696 ( .A(s_mem_q[178]), .Y(n1174) );
  sky130_fd_sc_hd__o22ai_1 U1697 ( .A1(n1183), .A2(n1174), .B1(n520), .B2(
        n1181), .Y(s_mem_d[178]) );
  sky130_fd_sc_hd__inv_1 U1698 ( .A(s_mem_q[177]), .Y(n1175) );
  sky130_fd_sc_hd__o22ai_1 U1699 ( .A1(n1183), .A2(n1175), .B1(n525), .B2(
        n1181), .Y(s_mem_d[177]) );
  sky130_fd_sc_hd__inv_1 U1700 ( .A(s_mem_q[176]), .Y(n1176) );
  sky130_fd_sc_hd__o22ai_1 U1701 ( .A1(n1183), .A2(n1176), .B1(n530), .B2(
        n1181), .Y(s_mem_d[176]) );
  sky130_fd_sc_hd__inv_1 U1702 ( .A(s_mem_q[175]), .Y(n1177) );
  sky130_fd_sc_hd__o22ai_1 U1703 ( .A1(n1183), .A2(n1177), .B1(n535), .B2(
        n1181), .Y(s_mem_d[175]) );
  sky130_fd_sc_hd__inv_1 U1704 ( .A(s_mem_q[174]), .Y(n1178) );
  sky130_fd_sc_hd__o22ai_1 U1705 ( .A1(n1183), .A2(n1178), .B1(n540), .B2(
        n1181), .Y(s_mem_d[174]) );
  sky130_fd_sc_hd__inv_1 U1706 ( .A(s_mem_q[173]), .Y(n1179) );
  sky130_fd_sc_hd__o22ai_1 U1707 ( .A1(n1183), .A2(n1179), .B1(n545), .B2(
        n1181), .Y(s_mem_d[173]) );
  sky130_fd_sc_hd__inv_1 U1708 ( .A(s_mem_q[172]), .Y(n1180) );
  sky130_fd_sc_hd__o22ai_1 U1709 ( .A1(n1183), .A2(n1180), .B1(n550), .B2(
        n1181), .Y(s_mem_d[172]) );
  sky130_fd_sc_hd__inv_1 U1710 ( .A(s_mem_q[171]), .Y(n1182) );
  sky130_fd_sc_hd__o22ai_1 U1711 ( .A1(n1183), .A2(n1182), .B1(n1438), .B2(
        n1181), .Y(s_mem_d[171]) );
  sky130_fd_sc_hd__nand2_1 U1712 ( .A(n1184), .B(n511), .Y(n1185) );
  sky130_fd_sc_hd__inv_1 U1713 ( .A(s_mem_q[170]), .Y(n1186) );
  sky130_fd_sc_hd__o22ai_1 U1714 ( .A1(n1196), .A2(n1186), .B1(n515), .B2(
        n1194), .Y(s_mem_d[170]) );
  sky130_fd_sc_hd__inv_1 U1715 ( .A(s_mem_q[169]), .Y(n1187) );
  sky130_fd_sc_hd__o22ai_1 U1716 ( .A1(n1196), .A2(n1187), .B1(n520), .B2(
        n1194), .Y(s_mem_d[169]) );
  sky130_fd_sc_hd__inv_1 U1717 ( .A(s_mem_q[168]), .Y(n1188) );
  sky130_fd_sc_hd__o22ai_1 U1718 ( .A1(n1196), .A2(n1188), .B1(n525), .B2(
        n1194), .Y(s_mem_d[168]) );
  sky130_fd_sc_hd__inv_1 U1719 ( .A(s_mem_q[167]), .Y(n1189) );
  sky130_fd_sc_hd__o22ai_1 U1720 ( .A1(n1196), .A2(n1189), .B1(n530), .B2(
        n1194), .Y(s_mem_d[167]) );
  sky130_fd_sc_hd__inv_1 U1721 ( .A(s_mem_q[166]), .Y(n1190) );
  sky130_fd_sc_hd__o22ai_1 U1722 ( .A1(n1196), .A2(n1190), .B1(n535), .B2(
        n1194), .Y(s_mem_d[166]) );
  sky130_fd_sc_hd__inv_1 U1723 ( .A(s_mem_q[165]), .Y(n1191) );
  sky130_fd_sc_hd__o22ai_1 U1724 ( .A1(n1196), .A2(n1191), .B1(n540), .B2(
        n1194), .Y(s_mem_d[165]) );
  sky130_fd_sc_hd__inv_1 U1725 ( .A(s_mem_q[164]), .Y(n1192) );
  sky130_fd_sc_hd__o22ai_1 U1726 ( .A1(n1196), .A2(n1192), .B1(n545), .B2(
        n1194), .Y(s_mem_d[164]) );
  sky130_fd_sc_hd__inv_1 U1727 ( .A(s_mem_q[163]), .Y(n1193) );
  sky130_fd_sc_hd__o22ai_1 U1728 ( .A1(n1196), .A2(n1193), .B1(n550), .B2(
        n1194), .Y(s_mem_d[163]) );
  sky130_fd_sc_hd__inv_1 U1729 ( .A(s_mem_q[162]), .Y(n1195) );
  sky130_fd_sc_hd__o22ai_1 U1730 ( .A1(n1196), .A2(n1195), .B1(n1438), .B2(
        n1194), .Y(s_mem_d[162]) );
  sky130_fd_sc_hd__nand2_1 U1731 ( .A(n1197), .B(n511), .Y(n1198) );
  sky130_fd_sc_hd__inv_1 U1732 ( .A(s_mem_q[161]), .Y(n1199) );
  sky130_fd_sc_hd__o22ai_1 U1733 ( .A1(n1209), .A2(n1199), .B1(n515), .B2(
        n1207), .Y(s_mem_d[161]) );
  sky130_fd_sc_hd__inv_1 U1734 ( .A(s_mem_q[160]), .Y(n1200) );
  sky130_fd_sc_hd__o22ai_1 U1735 ( .A1(n1209), .A2(n1200), .B1(n520), .B2(
        n1207), .Y(s_mem_d[160]) );
  sky130_fd_sc_hd__inv_1 U1736 ( .A(s_mem_q[159]), .Y(n1201) );
  sky130_fd_sc_hd__o22ai_1 U1737 ( .A1(n1209), .A2(n1201), .B1(n525), .B2(
        n1207), .Y(s_mem_d[159]) );
  sky130_fd_sc_hd__inv_1 U1738 ( .A(s_mem_q[158]), .Y(n1202) );
  sky130_fd_sc_hd__o22ai_1 U1739 ( .A1(n1209), .A2(n1202), .B1(n530), .B2(
        n1207), .Y(s_mem_d[158]) );
  sky130_fd_sc_hd__inv_1 U1740 ( .A(s_mem_q[157]), .Y(n1203) );
  sky130_fd_sc_hd__o22ai_1 U1741 ( .A1(n1209), .A2(n1203), .B1(n535), .B2(
        n1207), .Y(s_mem_d[157]) );
  sky130_fd_sc_hd__inv_1 U1742 ( .A(s_mem_q[156]), .Y(n1204) );
  sky130_fd_sc_hd__o22ai_1 U1743 ( .A1(n1209), .A2(n1204), .B1(n540), .B2(
        n1207), .Y(s_mem_d[156]) );
  sky130_fd_sc_hd__inv_1 U1744 ( .A(s_mem_q[155]), .Y(n1205) );
  sky130_fd_sc_hd__o22ai_1 U1745 ( .A1(n1209), .A2(n1205), .B1(n545), .B2(
        n1207), .Y(s_mem_d[155]) );
  sky130_fd_sc_hd__inv_1 U1746 ( .A(s_mem_q[154]), .Y(n1206) );
  sky130_fd_sc_hd__o22ai_1 U1747 ( .A1(n1209), .A2(n1206), .B1(n550), .B2(
        n1207), .Y(s_mem_d[154]) );
  sky130_fd_sc_hd__inv_1 U1748 ( .A(s_mem_q[153]), .Y(n1208) );
  sky130_fd_sc_hd__o22ai_1 U1749 ( .A1(n1209), .A2(n1208), .B1(n1438), .B2(
        n1207), .Y(s_mem_d[153]) );
  sky130_fd_sc_hd__nand2_1 U1750 ( .A(n1210), .B(n510), .Y(n1211) );
  sky130_fd_sc_hd__inv_1 U1751 ( .A(s_mem_q[152]), .Y(n1212) );
  sky130_fd_sc_hd__o22ai_1 U1752 ( .A1(n1222), .A2(n1212), .B1(n515), .B2(
        n1220), .Y(s_mem_d[152]) );
  sky130_fd_sc_hd__inv_1 U1753 ( .A(s_mem_q[151]), .Y(n1213) );
  sky130_fd_sc_hd__o22ai_1 U1754 ( .A1(n1222), .A2(n1213), .B1(n520), .B2(
        n1220), .Y(s_mem_d[151]) );
  sky130_fd_sc_hd__inv_1 U1755 ( .A(s_mem_q[150]), .Y(n1214) );
  sky130_fd_sc_hd__o22ai_1 U1756 ( .A1(n1222), .A2(n1214), .B1(n525), .B2(
        n1220), .Y(s_mem_d[150]) );
  sky130_fd_sc_hd__inv_1 U1757 ( .A(s_mem_q[149]), .Y(n1215) );
  sky130_fd_sc_hd__o22ai_1 U1758 ( .A1(n1222), .A2(n1215), .B1(n530), .B2(
        n1220), .Y(s_mem_d[149]) );
  sky130_fd_sc_hd__inv_1 U1759 ( .A(s_mem_q[148]), .Y(n1216) );
  sky130_fd_sc_hd__o22ai_1 U1760 ( .A1(n1222), .A2(n1216), .B1(n535), .B2(
        n1220), .Y(s_mem_d[148]) );
  sky130_fd_sc_hd__inv_1 U1761 ( .A(s_mem_q[147]), .Y(n1217) );
  sky130_fd_sc_hd__o22ai_1 U1762 ( .A1(n1222), .A2(n1217), .B1(n540), .B2(
        n1220), .Y(s_mem_d[147]) );
  sky130_fd_sc_hd__inv_1 U1763 ( .A(s_mem_q[146]), .Y(n1218) );
  sky130_fd_sc_hd__o22ai_1 U1764 ( .A1(n1222), .A2(n1218), .B1(n545), .B2(
        n1220), .Y(s_mem_d[146]) );
  sky130_fd_sc_hd__inv_1 U1765 ( .A(s_mem_q[145]), .Y(n1219) );
  sky130_fd_sc_hd__o22ai_1 U1766 ( .A1(n1222), .A2(n1219), .B1(n550), .B2(
        n1220), .Y(s_mem_d[145]) );
  sky130_fd_sc_hd__inv_1 U1767 ( .A(s_mem_q[144]), .Y(n1221) );
  sky130_fd_sc_hd__o22ai_1 U1768 ( .A1(n1222), .A2(n1221), .B1(n1438), .B2(
        n1220), .Y(s_mem_d[144]) );
  sky130_fd_sc_hd__nand2_1 U1769 ( .A(n1223), .B(n511), .Y(n1224) );
  sky130_fd_sc_hd__inv_1 U1770 ( .A(s_mem_q[143]), .Y(n1225) );
  sky130_fd_sc_hd__o22ai_1 U1771 ( .A1(n1235), .A2(n1225), .B1(n515), .B2(
        n1233), .Y(s_mem_d[143]) );
  sky130_fd_sc_hd__inv_1 U1772 ( .A(s_mem_q[142]), .Y(n1226) );
  sky130_fd_sc_hd__o22ai_1 U1773 ( .A1(n1235), .A2(n1226), .B1(n520), .B2(
        n1233), .Y(s_mem_d[142]) );
  sky130_fd_sc_hd__inv_1 U1774 ( .A(s_mem_q[141]), .Y(n1227) );
  sky130_fd_sc_hd__o22ai_1 U1775 ( .A1(n1235), .A2(n1227), .B1(n525), .B2(
        n1233), .Y(s_mem_d[141]) );
  sky130_fd_sc_hd__inv_1 U1776 ( .A(s_mem_q[140]), .Y(n1228) );
  sky130_fd_sc_hd__o22ai_1 U1777 ( .A1(n1235), .A2(n1228), .B1(n530), .B2(
        n1233), .Y(s_mem_d[140]) );
  sky130_fd_sc_hd__inv_1 U1778 ( .A(s_mem_q[139]), .Y(n1229) );
  sky130_fd_sc_hd__o22ai_1 U1779 ( .A1(n1235), .A2(n1229), .B1(n535), .B2(
        n1233), .Y(s_mem_d[139]) );
  sky130_fd_sc_hd__inv_1 U1780 ( .A(s_mem_q[138]), .Y(n1230) );
  sky130_fd_sc_hd__o22ai_1 U1781 ( .A1(n1235), .A2(n1230), .B1(n540), .B2(
        n1233), .Y(s_mem_d[138]) );
  sky130_fd_sc_hd__inv_1 U1782 ( .A(s_mem_q[137]), .Y(n1231) );
  sky130_fd_sc_hd__o22ai_1 U1783 ( .A1(n1235), .A2(n1231), .B1(n545), .B2(
        n1233), .Y(s_mem_d[137]) );
  sky130_fd_sc_hd__inv_1 U1784 ( .A(s_mem_q[136]), .Y(n1232) );
  sky130_fd_sc_hd__o22ai_1 U1785 ( .A1(n1235), .A2(n1232), .B1(n550), .B2(
        n1233), .Y(s_mem_d[136]) );
  sky130_fd_sc_hd__inv_1 U1786 ( .A(s_mem_q[135]), .Y(n1234) );
  sky130_fd_sc_hd__o22ai_1 U1787 ( .A1(n1235), .A2(n1234), .B1(n1438), .B2(
        n1233), .Y(s_mem_d[135]) );
  sky130_fd_sc_hd__nand2_1 U1788 ( .A(n1236), .B(n511), .Y(n1237) );
  sky130_fd_sc_hd__inv_1 U1789 ( .A(s_mem_q[134]), .Y(n1238) );
  sky130_fd_sc_hd__o22ai_1 U1790 ( .A1(n1248), .A2(n1238), .B1(n515), .B2(
        n1246), .Y(s_mem_d[134]) );
  sky130_fd_sc_hd__inv_1 U1791 ( .A(s_mem_q[133]), .Y(n1239) );
  sky130_fd_sc_hd__o22ai_1 U1792 ( .A1(n1248), .A2(n1239), .B1(n520), .B2(
        n1246), .Y(s_mem_d[133]) );
  sky130_fd_sc_hd__inv_1 U1793 ( .A(s_mem_q[132]), .Y(n1240) );
  sky130_fd_sc_hd__o22ai_1 U1794 ( .A1(n1248), .A2(n1240), .B1(n525), .B2(
        n1246), .Y(s_mem_d[132]) );
  sky130_fd_sc_hd__inv_1 U1795 ( .A(s_mem_q[131]), .Y(n1241) );
  sky130_fd_sc_hd__o22ai_1 U1796 ( .A1(n1248), .A2(n1241), .B1(n530), .B2(
        n1246), .Y(s_mem_d[131]) );
  sky130_fd_sc_hd__inv_1 U1797 ( .A(s_mem_q[130]), .Y(n1242) );
  sky130_fd_sc_hd__o22ai_1 U1798 ( .A1(n1248), .A2(n1242), .B1(n535), .B2(
        n1246), .Y(s_mem_d[130]) );
  sky130_fd_sc_hd__inv_1 U1799 ( .A(s_mem_q[129]), .Y(n1243) );
  sky130_fd_sc_hd__o22ai_1 U1800 ( .A1(n1248), .A2(n1243), .B1(n540), .B2(
        n1246), .Y(s_mem_d[129]) );
  sky130_fd_sc_hd__inv_1 U1801 ( .A(s_mem_q[128]), .Y(n1244) );
  sky130_fd_sc_hd__o22ai_1 U1802 ( .A1(n1248), .A2(n1244), .B1(n545), .B2(
        n1246), .Y(s_mem_d[128]) );
  sky130_fd_sc_hd__inv_1 U1803 ( .A(s_mem_q[127]), .Y(n1245) );
  sky130_fd_sc_hd__o22ai_1 U1804 ( .A1(n1248), .A2(n1245), .B1(n550), .B2(
        n1246), .Y(s_mem_d[127]) );
  sky130_fd_sc_hd__inv_1 U1805 ( .A(s_mem_q[126]), .Y(n1247) );
  sky130_fd_sc_hd__o22ai_1 U1806 ( .A1(n1248), .A2(n1247), .B1(n1438), .B2(
        n1246), .Y(s_mem_d[126]) );
  sky130_fd_sc_hd__nand2_1 U1807 ( .A(n1249), .B(n510), .Y(n1250) );
  sky130_fd_sc_hd__inv_1 U1808 ( .A(s_mem_q[125]), .Y(n1251) );
  sky130_fd_sc_hd__o22ai_1 U1809 ( .A1(n1261), .A2(n1251), .B1(n515), .B2(
        n1259), .Y(s_mem_d[125]) );
  sky130_fd_sc_hd__inv_1 U1810 ( .A(s_mem_q[124]), .Y(n1252) );
  sky130_fd_sc_hd__o22ai_1 U1811 ( .A1(n1261), .A2(n1252), .B1(n520), .B2(
        n1259), .Y(s_mem_d[124]) );
  sky130_fd_sc_hd__inv_1 U1812 ( .A(s_mem_q[123]), .Y(n1253) );
  sky130_fd_sc_hd__o22ai_1 U1813 ( .A1(n1261), .A2(n1253), .B1(n525), .B2(
        n1259), .Y(s_mem_d[123]) );
  sky130_fd_sc_hd__inv_1 U1814 ( .A(s_mem_q[122]), .Y(n1254) );
  sky130_fd_sc_hd__o22ai_1 U1815 ( .A1(n1261), .A2(n1254), .B1(n530), .B2(
        n1259), .Y(s_mem_d[122]) );
  sky130_fd_sc_hd__inv_1 U1816 ( .A(s_mem_q[121]), .Y(n1255) );
  sky130_fd_sc_hd__o22ai_1 U1817 ( .A1(n1261), .A2(n1255), .B1(n535), .B2(
        n1259), .Y(s_mem_d[121]) );
  sky130_fd_sc_hd__inv_1 U1818 ( .A(s_mem_q[120]), .Y(n1256) );
  sky130_fd_sc_hd__o22ai_1 U1819 ( .A1(n1261), .A2(n1256), .B1(n540), .B2(
        n1259), .Y(s_mem_d[120]) );
  sky130_fd_sc_hd__inv_1 U1820 ( .A(s_mem_q[119]), .Y(n1257) );
  sky130_fd_sc_hd__o22ai_1 U1821 ( .A1(n1261), .A2(n1257), .B1(n545), .B2(
        n1259), .Y(s_mem_d[119]) );
  sky130_fd_sc_hd__inv_1 U1822 ( .A(s_mem_q[118]), .Y(n1258) );
  sky130_fd_sc_hd__o22ai_1 U1823 ( .A1(n1261), .A2(n1258), .B1(n550), .B2(
        n1259), .Y(s_mem_d[118]) );
  sky130_fd_sc_hd__inv_1 U1824 ( .A(s_mem_q[117]), .Y(n1260) );
  sky130_fd_sc_hd__o22ai_1 U1825 ( .A1(n1261), .A2(n1260), .B1(n1438), .B2(
        n1259), .Y(s_mem_d[117]) );
  sky130_fd_sc_hd__nand2_1 U1826 ( .A(n1262), .B(n510), .Y(n1263) );
  sky130_fd_sc_hd__inv_1 U1827 ( .A(s_mem_q[116]), .Y(n1264) );
  sky130_fd_sc_hd__o22ai_1 U1828 ( .A1(n1274), .A2(n1264), .B1(n515), .B2(
        n1272), .Y(s_mem_d[116]) );
  sky130_fd_sc_hd__inv_1 U1829 ( .A(s_mem_q[115]), .Y(n1265) );
  sky130_fd_sc_hd__o22ai_1 U1830 ( .A1(n1274), .A2(n1265), .B1(n520), .B2(
        n1272), .Y(s_mem_d[115]) );
  sky130_fd_sc_hd__inv_1 U1831 ( .A(s_mem_q[114]), .Y(n1266) );
  sky130_fd_sc_hd__o22ai_1 U1832 ( .A1(n1274), .A2(n1266), .B1(n525), .B2(
        n1272), .Y(s_mem_d[114]) );
  sky130_fd_sc_hd__inv_1 U1833 ( .A(s_mem_q[113]), .Y(n1267) );
  sky130_fd_sc_hd__o22ai_1 U1834 ( .A1(n1274), .A2(n1267), .B1(n530), .B2(
        n1272), .Y(s_mem_d[113]) );
  sky130_fd_sc_hd__inv_1 U1835 ( .A(s_mem_q[112]), .Y(n1268) );
  sky130_fd_sc_hd__o22ai_1 U1836 ( .A1(n1274), .A2(n1268), .B1(n535), .B2(
        n1272), .Y(s_mem_d[112]) );
  sky130_fd_sc_hd__inv_1 U1837 ( .A(s_mem_q[111]), .Y(n1269) );
  sky130_fd_sc_hd__o22ai_1 U1838 ( .A1(n1274), .A2(n1269), .B1(n540), .B2(
        n1272), .Y(s_mem_d[111]) );
  sky130_fd_sc_hd__inv_1 U1839 ( .A(s_mem_q[110]), .Y(n1270) );
  sky130_fd_sc_hd__o22ai_1 U1840 ( .A1(n1274), .A2(n1270), .B1(n545), .B2(
        n1272), .Y(s_mem_d[110]) );
  sky130_fd_sc_hd__inv_1 U1841 ( .A(s_mem_q[109]), .Y(n1271) );
  sky130_fd_sc_hd__o22ai_1 U1842 ( .A1(n1274), .A2(n1271), .B1(n550), .B2(
        n1272), .Y(s_mem_d[109]) );
  sky130_fd_sc_hd__inv_1 U1843 ( .A(s_mem_q[108]), .Y(n1273) );
  sky130_fd_sc_hd__o22ai_1 U1844 ( .A1(n1274), .A2(n1273), .B1(n1438), .B2(
        n1272), .Y(s_mem_d[108]) );
  sky130_fd_sc_hd__nand2_1 U1845 ( .A(n1275), .B(n511), .Y(n1276) );
  sky130_fd_sc_hd__inv_1 U1846 ( .A(s_mem_q[107]), .Y(n1277) );
  sky130_fd_sc_hd__o22ai_1 U1847 ( .A1(n1287), .A2(n1277), .B1(n516), .B2(
        n1285), .Y(s_mem_d[107]) );
  sky130_fd_sc_hd__inv_1 U1848 ( .A(s_mem_q[106]), .Y(n1278) );
  sky130_fd_sc_hd__o22ai_1 U1849 ( .A1(n1287), .A2(n1278), .B1(n521), .B2(
        n1285), .Y(s_mem_d[106]) );
  sky130_fd_sc_hd__inv_1 U1850 ( .A(s_mem_q[105]), .Y(n1279) );
  sky130_fd_sc_hd__o22ai_1 U1851 ( .A1(n1287), .A2(n1279), .B1(n526), .B2(
        n1285), .Y(s_mem_d[105]) );
  sky130_fd_sc_hd__inv_1 U1852 ( .A(s_mem_q[104]), .Y(n1280) );
  sky130_fd_sc_hd__o22ai_1 U1853 ( .A1(n1287), .A2(n1280), .B1(n531), .B2(
        n1285), .Y(s_mem_d[104]) );
  sky130_fd_sc_hd__inv_1 U1854 ( .A(s_mem_q[103]), .Y(n1281) );
  sky130_fd_sc_hd__o22ai_1 U1855 ( .A1(n1287), .A2(n1281), .B1(n536), .B2(
        n1285), .Y(s_mem_d[103]) );
  sky130_fd_sc_hd__inv_1 U1856 ( .A(s_mem_q[102]), .Y(n1282) );
  sky130_fd_sc_hd__o22ai_1 U1857 ( .A1(n1287), .A2(n1282), .B1(n541), .B2(
        n1285), .Y(s_mem_d[102]) );
  sky130_fd_sc_hd__inv_1 U1858 ( .A(s_mem_q[101]), .Y(n1283) );
  sky130_fd_sc_hd__o22ai_1 U1859 ( .A1(n1287), .A2(n1283), .B1(n546), .B2(
        n1285), .Y(s_mem_d[101]) );
  sky130_fd_sc_hd__inv_1 U1860 ( .A(s_mem_q[100]), .Y(n1284) );
  sky130_fd_sc_hd__o22ai_1 U1861 ( .A1(n1287), .A2(n1284), .B1(n551), .B2(
        n1285), .Y(s_mem_d[100]) );
  sky130_fd_sc_hd__inv_1 U1862 ( .A(s_mem_q[99]), .Y(n1286) );
  sky130_fd_sc_hd__o22ai_1 U1863 ( .A1(n1287), .A2(n1286), .B1(n1438), .B2(
        n1285), .Y(s_mem_d[99]) );
  sky130_fd_sc_hd__nand2_1 U1864 ( .A(n1288), .B(n511), .Y(n1289) );
  sky130_fd_sc_hd__inv_1 U1865 ( .A(s_mem_q[98]), .Y(n1290) );
  sky130_fd_sc_hd__o22ai_1 U1866 ( .A1(n1300), .A2(n1290), .B1(n516), .B2(
        n1298), .Y(s_mem_d[98]) );
  sky130_fd_sc_hd__inv_1 U1867 ( .A(s_mem_q[97]), .Y(n1291) );
  sky130_fd_sc_hd__o22ai_1 U1868 ( .A1(n1300), .A2(n1291), .B1(n520), .B2(
        n1298), .Y(s_mem_d[97]) );
  sky130_fd_sc_hd__inv_1 U1869 ( .A(s_mem_q[96]), .Y(n1292) );
  sky130_fd_sc_hd__o22ai_1 U1870 ( .A1(n1300), .A2(n1292), .B1(n525), .B2(
        n1298), .Y(s_mem_d[96]) );
  sky130_fd_sc_hd__inv_1 U1871 ( .A(s_mem_q[95]), .Y(n1293) );
  sky130_fd_sc_hd__o22ai_1 U1872 ( .A1(n1300), .A2(n1293), .B1(n530), .B2(
        n1298), .Y(s_mem_d[95]) );
  sky130_fd_sc_hd__inv_1 U1873 ( .A(s_mem_q[94]), .Y(n1294) );
  sky130_fd_sc_hd__o22ai_1 U1874 ( .A1(n1300), .A2(n1294), .B1(n535), .B2(
        n1298), .Y(s_mem_d[94]) );
  sky130_fd_sc_hd__inv_1 U1875 ( .A(s_mem_q[93]), .Y(n1295) );
  sky130_fd_sc_hd__o22ai_1 U1876 ( .A1(n1300), .A2(n1295), .B1(n540), .B2(
        n1298), .Y(s_mem_d[93]) );
  sky130_fd_sc_hd__inv_1 U1877 ( .A(s_mem_q[92]), .Y(n1296) );
  sky130_fd_sc_hd__o22ai_1 U1878 ( .A1(n1300), .A2(n1296), .B1(n545), .B2(
        n1298), .Y(s_mem_d[92]) );
  sky130_fd_sc_hd__inv_1 U1879 ( .A(s_mem_q[91]), .Y(n1297) );
  sky130_fd_sc_hd__o22ai_1 U1880 ( .A1(n1300), .A2(n1297), .B1(n550), .B2(
        n1298), .Y(s_mem_d[91]) );
  sky130_fd_sc_hd__inv_1 U1881 ( .A(s_mem_q[90]), .Y(n1299) );
  sky130_fd_sc_hd__o22ai_1 U1882 ( .A1(n1300), .A2(n1299), .B1(n1438), .B2(
        n1298), .Y(s_mem_d[90]) );
  sky130_fd_sc_hd__nand2_1 U1883 ( .A(n1301), .B(n510), .Y(n1302) );
  sky130_fd_sc_hd__inv_1 U1884 ( .A(s_mem_q[89]), .Y(n1303) );
  sky130_fd_sc_hd__o22ai_1 U1885 ( .A1(n1313), .A2(n1303), .B1(n516), .B2(
        n1311), .Y(s_mem_d[89]) );
  sky130_fd_sc_hd__inv_1 U1886 ( .A(s_mem_q[88]), .Y(n1304) );
  sky130_fd_sc_hd__o22ai_1 U1887 ( .A1(n1313), .A2(n1304), .B1(n521), .B2(
        n1311), .Y(s_mem_d[88]) );
  sky130_fd_sc_hd__inv_1 U1888 ( .A(s_mem_q[87]), .Y(n1305) );
  sky130_fd_sc_hd__o22ai_1 U1889 ( .A1(n1313), .A2(n1305), .B1(n526), .B2(
        n1311), .Y(s_mem_d[87]) );
  sky130_fd_sc_hd__inv_1 U1890 ( .A(s_mem_q[86]), .Y(n1306) );
  sky130_fd_sc_hd__o22ai_1 U1891 ( .A1(n1313), .A2(n1306), .B1(n531), .B2(
        n1311), .Y(s_mem_d[86]) );
  sky130_fd_sc_hd__inv_1 U1892 ( .A(s_mem_q[85]), .Y(n1307) );
  sky130_fd_sc_hd__o22ai_1 U1893 ( .A1(n1313), .A2(n1307), .B1(n536), .B2(
        n1311), .Y(s_mem_d[85]) );
  sky130_fd_sc_hd__inv_1 U1894 ( .A(s_mem_q[84]), .Y(n1308) );
  sky130_fd_sc_hd__o22ai_1 U1895 ( .A1(n1313), .A2(n1308), .B1(n541), .B2(
        n1311), .Y(s_mem_d[84]) );
  sky130_fd_sc_hd__inv_1 U1896 ( .A(s_mem_q[83]), .Y(n1309) );
  sky130_fd_sc_hd__o22ai_1 U1897 ( .A1(n1313), .A2(n1309), .B1(n546), .B2(
        n1311), .Y(s_mem_d[83]) );
  sky130_fd_sc_hd__inv_1 U1898 ( .A(s_mem_q[82]), .Y(n1310) );
  sky130_fd_sc_hd__o22ai_1 U1899 ( .A1(n1313), .A2(n1310), .B1(n551), .B2(
        n1311), .Y(s_mem_d[82]) );
  sky130_fd_sc_hd__inv_1 U1900 ( .A(s_mem_q[81]), .Y(n1312) );
  sky130_fd_sc_hd__o22ai_1 U1901 ( .A1(n1313), .A2(n1312), .B1(n1438), .B2(
        n1311), .Y(s_mem_d[81]) );
  sky130_fd_sc_hd__nand2_1 U1902 ( .A(n1314), .B(n510), .Y(n1315) );
  sky130_fd_sc_hd__inv_1 U1903 ( .A(s_mem_q[80]), .Y(n1316) );
  sky130_fd_sc_hd__o22ai_1 U1904 ( .A1(n1326), .A2(n1316), .B1(n516), .B2(
        n1324), .Y(s_mem_d[80]) );
  sky130_fd_sc_hd__inv_1 U1905 ( .A(s_mem_q[79]), .Y(n1317) );
  sky130_fd_sc_hd__o22ai_1 U1906 ( .A1(n1326), .A2(n1317), .B1(n521), .B2(
        n1324), .Y(s_mem_d[79]) );
  sky130_fd_sc_hd__inv_1 U1907 ( .A(s_mem_q[78]), .Y(n1318) );
  sky130_fd_sc_hd__o22ai_1 U1908 ( .A1(n1326), .A2(n1318), .B1(n526), .B2(
        n1324), .Y(s_mem_d[78]) );
  sky130_fd_sc_hd__inv_1 U1909 ( .A(s_mem_q[77]), .Y(n1319) );
  sky130_fd_sc_hd__o22ai_1 U1910 ( .A1(n1326), .A2(n1319), .B1(n531), .B2(
        n1324), .Y(s_mem_d[77]) );
  sky130_fd_sc_hd__inv_1 U1911 ( .A(s_mem_q[76]), .Y(n1320) );
  sky130_fd_sc_hd__o22ai_1 U1912 ( .A1(n1326), .A2(n1320), .B1(n536), .B2(
        n1324), .Y(s_mem_d[76]) );
  sky130_fd_sc_hd__inv_1 U1913 ( .A(s_mem_q[75]), .Y(n1321) );
  sky130_fd_sc_hd__o22ai_1 U1914 ( .A1(n1326), .A2(n1321), .B1(n541), .B2(
        n1324), .Y(s_mem_d[75]) );
  sky130_fd_sc_hd__inv_1 U1915 ( .A(s_mem_q[74]), .Y(n1322) );
  sky130_fd_sc_hd__o22ai_1 U1916 ( .A1(n1326), .A2(n1322), .B1(n546), .B2(
        n1324), .Y(s_mem_d[74]) );
  sky130_fd_sc_hd__inv_1 U1917 ( .A(s_mem_q[73]), .Y(n1323) );
  sky130_fd_sc_hd__o22ai_1 U1918 ( .A1(n1326), .A2(n1323), .B1(n551), .B2(
        n1324), .Y(s_mem_d[73]) );
  sky130_fd_sc_hd__inv_1 U1919 ( .A(s_mem_q[72]), .Y(n1325) );
  sky130_fd_sc_hd__o22ai_1 U1920 ( .A1(n1326), .A2(n1325), .B1(n1438), .B2(
        n1324), .Y(s_mem_d[72]) );
  sky130_fd_sc_hd__nand3_1 U1921 ( .A(n1445), .B(n1444), .C(n1446), .Y(n1327)
         );
  sky130_fd_sc_hd__nand2_1 U1922 ( .A(n1329), .B(n510), .Y(n1330) );
  sky130_fd_sc_hd__inv_1 U1923 ( .A(s_mem_q[71]), .Y(n1331) );
  sky130_fd_sc_hd__o22ai_1 U1924 ( .A1(n1341), .A2(n1331), .B1(n516), .B2(
        n1339), .Y(s_mem_d[71]) );
  sky130_fd_sc_hd__inv_1 U1925 ( .A(s_mem_q[70]), .Y(n1332) );
  sky130_fd_sc_hd__o22ai_1 U1926 ( .A1(n1341), .A2(n1332), .B1(n521), .B2(
        n1339), .Y(s_mem_d[70]) );
  sky130_fd_sc_hd__inv_1 U1927 ( .A(s_mem_q[69]), .Y(n1333) );
  sky130_fd_sc_hd__o22ai_1 U1928 ( .A1(n1341), .A2(n1333), .B1(n526), .B2(
        n1339), .Y(s_mem_d[69]) );
  sky130_fd_sc_hd__inv_1 U1929 ( .A(s_mem_q[68]), .Y(n1334) );
  sky130_fd_sc_hd__o22ai_1 U1930 ( .A1(n1341), .A2(n1334), .B1(n531), .B2(
        n1339), .Y(s_mem_d[68]) );
  sky130_fd_sc_hd__inv_1 U1931 ( .A(s_mem_q[67]), .Y(n1335) );
  sky130_fd_sc_hd__o22ai_1 U1932 ( .A1(n1341), .A2(n1335), .B1(n536), .B2(
        n1339), .Y(s_mem_d[67]) );
  sky130_fd_sc_hd__inv_1 U1933 ( .A(s_mem_q[66]), .Y(n1336) );
  sky130_fd_sc_hd__o22ai_1 U1934 ( .A1(n1341), .A2(n1336), .B1(n541), .B2(
        n1339), .Y(s_mem_d[66]) );
  sky130_fd_sc_hd__inv_1 U1935 ( .A(s_mem_q[65]), .Y(n1337) );
  sky130_fd_sc_hd__o22ai_1 U1936 ( .A1(n1341), .A2(n1337), .B1(n546), .B2(
        n1339), .Y(s_mem_d[65]) );
  sky130_fd_sc_hd__inv_1 U1937 ( .A(s_mem_q[64]), .Y(n1338) );
  sky130_fd_sc_hd__o22ai_1 U1938 ( .A1(n1341), .A2(n1338), .B1(n551), .B2(
        n1339), .Y(s_mem_d[64]) );
  sky130_fd_sc_hd__inv_1 U1939 ( .A(s_mem_q[63]), .Y(n1340) );
  sky130_fd_sc_hd__o22ai_1 U1940 ( .A1(n1341), .A2(n1340), .B1(n1438), .B2(
        n1339), .Y(s_mem_d[63]) );
  sky130_fd_sc_hd__nand2_1 U1941 ( .A(n1343), .B(n510), .Y(n1344) );
  sky130_fd_sc_hd__inv_1 U1942 ( .A(s_mem_q[62]), .Y(n1345) );
  sky130_fd_sc_hd__o22ai_1 U1943 ( .A1(n1354), .A2(n1345), .B1(n516), .B2(
        n1353), .Y(s_mem_d[62]) );
  sky130_fd_sc_hd__inv_1 U1944 ( .A(s_mem_q[61]), .Y(n1346) );
  sky130_fd_sc_hd__o22ai_1 U1945 ( .A1(n1354), .A2(n1346), .B1(n521), .B2(
        n1353), .Y(s_mem_d[61]) );
  sky130_fd_sc_hd__inv_1 U1946 ( .A(s_mem_q[60]), .Y(n1347) );
  sky130_fd_sc_hd__o22ai_1 U1947 ( .A1(n1354), .A2(n1347), .B1(n526), .B2(
        n1353), .Y(s_mem_d[60]) );
  sky130_fd_sc_hd__inv_1 U1948 ( .A(s_mem_q[59]), .Y(n1348) );
  sky130_fd_sc_hd__o22ai_1 U1949 ( .A1(n1354), .A2(n1348), .B1(n531), .B2(
        n1353), .Y(s_mem_d[59]) );
  sky130_fd_sc_hd__inv_1 U1950 ( .A(s_mem_q[58]), .Y(n1349) );
  sky130_fd_sc_hd__o22ai_1 U1951 ( .A1(n1354), .A2(n1349), .B1(n536), .B2(
        n1353), .Y(s_mem_d[58]) );
  sky130_fd_sc_hd__inv_1 U1952 ( .A(s_mem_q[57]), .Y(n1350) );
  sky130_fd_sc_hd__o22ai_1 U1953 ( .A1(n1354), .A2(n1350), .B1(n541), .B2(
        n1353), .Y(s_mem_d[57]) );
  sky130_fd_sc_hd__inv_1 U1954 ( .A(s_mem_q[56]), .Y(n1351) );
  sky130_fd_sc_hd__o22ai_1 U1955 ( .A1(n1354), .A2(n1351), .B1(n546), .B2(
        n1353), .Y(s_mem_d[56]) );
  sky130_fd_sc_hd__inv_1 U1956 ( .A(s_mem_q[55]), .Y(n1352) );
  sky130_fd_sc_hd__o22ai_1 U1957 ( .A1(n1354), .A2(n1352), .B1(n551), .B2(
        n1353), .Y(s_mem_d[55]) );
  sky130_fd_sc_hd__nand2_1 U1958 ( .A(n1356), .B(n511), .Y(n1357) );
  sky130_fd_sc_hd__inv_1 U1959 ( .A(s_mem_q[53]), .Y(n1358) );
  sky130_fd_sc_hd__o22ai_1 U1960 ( .A1(n1367), .A2(n1358), .B1(n516), .B2(
        n1366), .Y(s_mem_d[53]) );
  sky130_fd_sc_hd__inv_1 U1961 ( .A(s_mem_q[52]), .Y(n1359) );
  sky130_fd_sc_hd__o22ai_1 U1962 ( .A1(n1367), .A2(n1359), .B1(n521), .B2(
        n1366), .Y(s_mem_d[52]) );
  sky130_fd_sc_hd__inv_1 U1963 ( .A(s_mem_q[51]), .Y(n1360) );
  sky130_fd_sc_hd__o22ai_1 U1964 ( .A1(n1367), .A2(n1360), .B1(n526), .B2(
        n1366), .Y(s_mem_d[51]) );
  sky130_fd_sc_hd__inv_1 U1965 ( .A(s_mem_q[50]), .Y(n1361) );
  sky130_fd_sc_hd__o22ai_1 U1966 ( .A1(n1367), .A2(n1361), .B1(n531), .B2(
        n1366), .Y(s_mem_d[50]) );
  sky130_fd_sc_hd__inv_1 U1967 ( .A(s_mem_q[49]), .Y(n1362) );
  sky130_fd_sc_hd__o22ai_1 U1968 ( .A1(n1367), .A2(n1362), .B1(n536), .B2(
        n1366), .Y(s_mem_d[49]) );
  sky130_fd_sc_hd__inv_1 U1969 ( .A(s_mem_q[48]), .Y(n1363) );
  sky130_fd_sc_hd__o22ai_1 U1970 ( .A1(n1367), .A2(n1363), .B1(n541), .B2(
        n1366), .Y(s_mem_d[48]) );
  sky130_fd_sc_hd__inv_1 U1971 ( .A(s_mem_q[47]), .Y(n1364) );
  sky130_fd_sc_hd__o22ai_1 U1972 ( .A1(n1367), .A2(n1364), .B1(n546), .B2(
        n1366), .Y(s_mem_d[47]) );
  sky130_fd_sc_hd__inv_1 U1973 ( .A(s_mem_q[46]), .Y(n1365) );
  sky130_fd_sc_hd__o22ai_1 U1974 ( .A1(n1367), .A2(n1365), .B1(n551), .B2(
        n1366), .Y(s_mem_d[46]) );
  sky130_fd_sc_hd__nand2_1 U1975 ( .A(n1369), .B(n510), .Y(n1370) );
  sky130_fd_sc_hd__inv_1 U1976 ( .A(s_mem_q[44]), .Y(n1371) );
  sky130_fd_sc_hd__o22ai_1 U1977 ( .A1(n1380), .A2(n1371), .B1(n516), .B2(
        n1379), .Y(s_mem_d[44]) );
  sky130_fd_sc_hd__inv_1 U1978 ( .A(s_mem_q[43]), .Y(n1372) );
  sky130_fd_sc_hd__o22ai_1 U1979 ( .A1(n1380), .A2(n1372), .B1(n521), .B2(
        n1379), .Y(s_mem_d[43]) );
  sky130_fd_sc_hd__inv_1 U1980 ( .A(s_mem_q[42]), .Y(n1373) );
  sky130_fd_sc_hd__o22ai_1 U1981 ( .A1(n1380), .A2(n1373), .B1(n526), .B2(
        n1379), .Y(s_mem_d[42]) );
  sky130_fd_sc_hd__inv_1 U1982 ( .A(s_mem_q[41]), .Y(n1374) );
  sky130_fd_sc_hd__o22ai_1 U1983 ( .A1(n1380), .A2(n1374), .B1(n531), .B2(
        n1379), .Y(s_mem_d[41]) );
  sky130_fd_sc_hd__inv_1 U1984 ( .A(s_mem_q[40]), .Y(n1375) );
  sky130_fd_sc_hd__o22ai_1 U1985 ( .A1(n1380), .A2(n1375), .B1(n536), .B2(
        n1379), .Y(s_mem_d[40]) );
  sky130_fd_sc_hd__inv_1 U1986 ( .A(s_mem_q[39]), .Y(n1376) );
  sky130_fd_sc_hd__o22ai_1 U1987 ( .A1(n1380), .A2(n1376), .B1(n541), .B2(
        n1379), .Y(s_mem_d[39]) );
  sky130_fd_sc_hd__inv_1 U1988 ( .A(s_mem_q[38]), .Y(n1377) );
  sky130_fd_sc_hd__o22ai_1 U1989 ( .A1(n1380), .A2(n1377), .B1(n546), .B2(
        n1379), .Y(s_mem_d[38]) );
  sky130_fd_sc_hd__inv_1 U1990 ( .A(s_mem_q[37]), .Y(n1378) );
  sky130_fd_sc_hd__o22ai_1 U1991 ( .A1(n1380), .A2(n1378), .B1(n551), .B2(
        n1379), .Y(s_mem_d[37]) );
  sky130_fd_sc_hd__nand2_1 U1992 ( .A(n1382), .B(n510), .Y(n1383) );
  sky130_fd_sc_hd__inv_1 U1993 ( .A(s_mem_q[35]), .Y(n1384) );
  sky130_fd_sc_hd__o22ai_1 U1994 ( .A1(n1393), .A2(n1384), .B1(n516), .B2(
        n1392), .Y(s_mem_d[35]) );
  sky130_fd_sc_hd__inv_1 U1995 ( .A(s_mem_q[34]), .Y(n1385) );
  sky130_fd_sc_hd__o22ai_1 U1996 ( .A1(n1393), .A2(n1385), .B1(n521), .B2(
        n1392), .Y(s_mem_d[34]) );
  sky130_fd_sc_hd__inv_1 U1997 ( .A(s_mem_q[33]), .Y(n1386) );
  sky130_fd_sc_hd__o22ai_1 U1998 ( .A1(n1393), .A2(n1386), .B1(n526), .B2(
        n1392), .Y(s_mem_d[33]) );
  sky130_fd_sc_hd__inv_1 U1999 ( .A(s_mem_q[32]), .Y(n1387) );
  sky130_fd_sc_hd__o22ai_1 U2000 ( .A1(n1393), .A2(n1387), .B1(n531), .B2(
        n1392), .Y(s_mem_d[32]) );
  sky130_fd_sc_hd__inv_1 U2001 ( .A(s_mem_q[31]), .Y(n1388) );
  sky130_fd_sc_hd__o22ai_1 U2002 ( .A1(n1393), .A2(n1388), .B1(n536), .B2(
        n1392), .Y(s_mem_d[31]) );
  sky130_fd_sc_hd__inv_1 U2003 ( .A(s_mem_q[30]), .Y(n1389) );
  sky130_fd_sc_hd__o22ai_1 U2004 ( .A1(n1393), .A2(n1389), .B1(n541), .B2(
        n1392), .Y(s_mem_d[30]) );
  sky130_fd_sc_hd__inv_1 U2005 ( .A(s_mem_q[29]), .Y(n1390) );
  sky130_fd_sc_hd__o22ai_1 U2006 ( .A1(n1393), .A2(n1390), .B1(n546), .B2(
        n1392), .Y(s_mem_d[29]) );
  sky130_fd_sc_hd__inv_1 U2007 ( .A(s_mem_q[28]), .Y(n1391) );
  sky130_fd_sc_hd__o22ai_1 U2008 ( .A1(n1393), .A2(n1391), .B1(n551), .B2(
        n1392), .Y(s_mem_d[28]) );
  sky130_fd_sc_hd__inv_1 U2009 ( .A(s_mem_q[26]), .Y(n1396) );
  sky130_fd_sc_hd__o22ai_1 U2010 ( .A1(n17), .A2(n1396), .B1(n516), .B2(n1404), 
        .Y(s_mem_d[26]) );
  sky130_fd_sc_hd__inv_1 U2011 ( .A(s_mem_q[25]), .Y(n1397) );
  sky130_fd_sc_hd__o22ai_1 U2012 ( .A1(n17), .A2(n1397), .B1(n521), .B2(n1404), 
        .Y(s_mem_d[25]) );
  sky130_fd_sc_hd__inv_1 U2013 ( .A(s_mem_q[24]), .Y(n1398) );
  sky130_fd_sc_hd__o22ai_1 U2014 ( .A1(n17), .A2(n1398), .B1(n526), .B2(n1404), 
        .Y(s_mem_d[24]) );
  sky130_fd_sc_hd__inv_1 U2015 ( .A(s_mem_q[23]), .Y(n1399) );
  sky130_fd_sc_hd__o22ai_1 U2016 ( .A1(n17), .A2(n1399), .B1(n531), .B2(n1404), 
        .Y(s_mem_d[23]) );
  sky130_fd_sc_hd__inv_1 U2017 ( .A(s_mem_q[22]), .Y(n1400) );
  sky130_fd_sc_hd__o22ai_1 U2018 ( .A1(n17), .A2(n1400), .B1(n536), .B2(n1404), 
        .Y(s_mem_d[22]) );
  sky130_fd_sc_hd__inv_1 U2019 ( .A(s_mem_q[21]), .Y(n1401) );
  sky130_fd_sc_hd__o22ai_1 U2020 ( .A1(n17), .A2(n1401), .B1(n541), .B2(n1404), 
        .Y(s_mem_d[21]) );
  sky130_fd_sc_hd__inv_1 U2021 ( .A(s_mem_q[20]), .Y(n1402) );
  sky130_fd_sc_hd__o22ai_1 U2022 ( .A1(n17), .A2(n1402), .B1(n546), .B2(n1404), 
        .Y(s_mem_d[20]) );
  sky130_fd_sc_hd__inv_1 U2023 ( .A(s_mem_q[19]), .Y(n1403) );
  sky130_fd_sc_hd__o22ai_1 U2024 ( .A1(n17), .A2(n1403), .B1(n551), .B2(n1404), 
        .Y(s_mem_d[19]) );
  sky130_fd_sc_hd__inv_1 U2025 ( .A(s_mem_q[18]), .Y(n1405) );
  sky130_fd_sc_hd__o22ai_1 U2026 ( .A1(n17), .A2(n1405), .B1(n1438), .B2(n1404), .Y(s_mem_d[18]) );
  sky130_fd_sc_hd__nand2_1 U2027 ( .A(n1406), .B(n510), .Y(n1407) );
  sky130_fd_sc_hd__inv_1 U2028 ( .A(s_mem_q[17]), .Y(n1408) );
  sky130_fd_sc_hd__o22ai_1 U2029 ( .A1(n1417), .A2(n1408), .B1(n516), .B2(
        n1416), .Y(s_mem_d[17]) );
  sky130_fd_sc_hd__inv_1 U2030 ( .A(s_mem_q[16]), .Y(n1409) );
  sky130_fd_sc_hd__o22ai_1 U2031 ( .A1(n1417), .A2(n1409), .B1(n521), .B2(
        n1416), .Y(s_mem_d[16]) );
  sky130_fd_sc_hd__inv_1 U2032 ( .A(s_mem_q[15]), .Y(n1410) );
  sky130_fd_sc_hd__o22ai_1 U2033 ( .A1(n1417), .A2(n1410), .B1(n526), .B2(
        n1416), .Y(s_mem_d[15]) );
  sky130_fd_sc_hd__inv_1 U2034 ( .A(s_mem_q[14]), .Y(n1411) );
  sky130_fd_sc_hd__o22ai_1 U2035 ( .A1(n1417), .A2(n1411), .B1(n531), .B2(
        n1416), .Y(s_mem_d[14]) );
  sky130_fd_sc_hd__inv_1 U2036 ( .A(s_mem_q[13]), .Y(n1412) );
  sky130_fd_sc_hd__o22ai_1 U2037 ( .A1(n1417), .A2(n1412), .B1(n536), .B2(
        n1416), .Y(s_mem_d[13]) );
  sky130_fd_sc_hd__inv_1 U2038 ( .A(s_mem_q[12]), .Y(n1413) );
  sky130_fd_sc_hd__o22ai_1 U2039 ( .A1(n1417), .A2(n1413), .B1(n541), .B2(
        n1416), .Y(s_mem_d[12]) );
  sky130_fd_sc_hd__inv_1 U2040 ( .A(s_mem_q[11]), .Y(n1414) );
  sky130_fd_sc_hd__o22ai_1 U2041 ( .A1(n1417), .A2(n1414), .B1(n546), .B2(
        n1416), .Y(s_mem_d[11]) );
  sky130_fd_sc_hd__inv_1 U2042 ( .A(s_mem_q[10]), .Y(n1415) );
  sky130_fd_sc_hd__o22ai_1 U2043 ( .A1(n1417), .A2(n1415), .B1(n551), .B2(
        n1416), .Y(s_mem_d[10]) );
  sky130_fd_sc_hd__nand2_1 U2044 ( .A(n510), .B(n1419), .Y(n1421) );
  sky130_fd_sc_hd__inv_1 U2045 ( .A(s_mem_q[8]), .Y(n1423) );
  sky130_fd_sc_hd__o22ai_1 U2046 ( .A1(n1441), .A2(n1423), .B1(n1439), .B2(
        n516), .Y(s_mem_d[8]) );
  sky130_fd_sc_hd__inv_1 U2047 ( .A(s_mem_q[7]), .Y(n1425) );
  sky130_fd_sc_hd__o22ai_1 U2048 ( .A1(n1441), .A2(n1425), .B1(n1439), .B2(
        n521), .Y(s_mem_d[7]) );
  sky130_fd_sc_hd__inv_1 U2049 ( .A(s_mem_q[6]), .Y(n1427) );
  sky130_fd_sc_hd__o22ai_1 U2050 ( .A1(n1441), .A2(n1427), .B1(n1439), .B2(
        n526), .Y(s_mem_d[6]) );
  sky130_fd_sc_hd__inv_1 U2051 ( .A(s_mem_q[5]), .Y(n1429) );
  sky130_fd_sc_hd__o22ai_1 U2052 ( .A1(n1441), .A2(n1429), .B1(n1439), .B2(
        n531), .Y(s_mem_d[5]) );
  sky130_fd_sc_hd__inv_1 U2053 ( .A(s_mem_q[4]), .Y(n1431) );
  sky130_fd_sc_hd__o22ai_1 U2054 ( .A1(n1441), .A2(n1431), .B1(n1439), .B2(
        n536), .Y(s_mem_d[4]) );
  sky130_fd_sc_hd__inv_1 U2055 ( .A(s_mem_q[3]), .Y(n1433) );
  sky130_fd_sc_hd__o22ai_1 U2056 ( .A1(n1441), .A2(n1433), .B1(n1439), .B2(
        n541), .Y(s_mem_d[3]) );
  sky130_fd_sc_hd__inv_1 U2057 ( .A(s_mem_q[2]), .Y(n1435) );
  sky130_fd_sc_hd__o22ai_1 U2058 ( .A1(n1441), .A2(n1435), .B1(n1439), .B2(
        n546), .Y(s_mem_d[2]) );
  sky130_fd_sc_hd__inv_1 U2059 ( .A(s_mem_q[1]), .Y(n1437) );
  sky130_fd_sc_hd__o22ai_1 U2060 ( .A1(n1441), .A2(n1437), .B1(n1439), .B2(
        n551), .Y(s_mem_d[1]) );
  sky130_fd_sc_hd__inv_1 U2061 ( .A(s_mem_q[0]), .Y(n1440) );
  sky130_fd_sc_hd__o22ai_1 U2062 ( .A1(n1441), .A2(n1440), .B1(n1439), .B2(
        n1438), .Y(s_mem_d[0]) );
  sky130_fd_sc_hd__nand2_1 U2063 ( .A(n1443), .B(n1442), .Y(n1450) );
  sky130_fd_sc_hd__o2bb2ai_1 U2064 ( .B1(n1450), .B2(n1444), .A1_N(N100), 
        .A2_N(n1448), .Y(s_wr_ptr_d[5]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2065 ( .B1(n1450), .B2(n1445), .A1_N(N99), 
        .A2_N(n1448), .Y(s_wr_ptr_d[4]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2066 ( .B1(n1450), .B2(n1446), .A1_N(N98), 
        .A2_N(n1448), .Y(s_wr_ptr_d[3]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2067 ( .B1(n1450), .B2(n1447), .A1_N(N97), 
        .A2_N(n1448), .Y(s_wr_ptr_d[2]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2068 ( .B1(n1450), .B2(n1449), .A1_N(N96), 
        .A2_N(n1448), .Y(s_wr_ptr_d[1]) );
  sky130_fd_sc_hd__mux2i_1 U2069 ( .A0(n1451), .A1(n1450), .S(s_wr_ptr_q[0]), 
        .Y(s_wr_ptr_d[0]) );
  sky130_fd_sc_hd__o2bb2ai_1 U2070 ( .B1(n499), .B2(n449), .A1_N(N88), .A2_N(
        n1453), .Y(s_rd_ptr_d[4]) );
  sky130_fd_sc_hd__inv_1 U2071 ( .A(N78), .Y(n1452) );
  sky130_fd_sc_hd__nor3_1 U2072 ( .A(cnt_o[5]), .B(n1457), .C(n1456), .Y(
        full_o) );
  sky130_fd_sc_hd__xor2_1 U2073 ( .A(\add_50/carry[5] ), .B(N80), .X(N89) );
  sky130_fd_sc_hd__xor2_1 U2074 ( .A(\add_65/carry[5] ), .B(s_wr_ptr_q[5]), 
        .X(N100) );
endmodule


module uart_rx_DW01_inc_1 ( A, SUM );
  input [15:0] A;
  output [15:0] SUM;
  wire   n1, n2, n4, n5, n6, n7, n8, n9, n10, n11, n13, n14, n15, n17, n18,
         n20, n21, n22, n24, n25, n27, n28, n29, n30, n31, n33, n34, n36, n37,
         n38, n40, n42, n43, n44, n45, n46, n47, n49, n50, n52, n53, n54, n56;
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

  sky130_fd_sc_hd__nand2_1 U4 ( .A(n4), .B(n2), .Y(n1) );
  sky130_fd_sc_hd__xor2_1 U7 ( .A(n8), .B(n7), .X(SUM[13]) );
  sky130_fd_sc_hd__nor2_1 U8 ( .A(n28), .B(n5), .Y(n4) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n13), .B(n6), .Y(n5) );
  sky130_fd_sc_hd__nor2_1 U10 ( .A(n7), .B(n10), .Y(n6) );
  sky130_fd_sc_hd__xnor2_1 U12 ( .A(n10), .B(n11), .Y(SUM[12]) );
  sky130_fd_sc_hd__nand2_1 U13 ( .A(n11), .B(n9), .Y(n8) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(n14), .B(n21), .Y(n13) );
  sky130_fd_sc_hd__nand2_1 U20 ( .A(n18), .B(n15), .Y(n14) );
  sky130_fd_sc_hd__nand2_1 U24 ( .A(n20), .B(n18), .Y(n17) );
  sky130_fd_sc_hd__nor2_1 U28 ( .A(n21), .B(n28), .Y(n20) );
  sky130_fd_sc_hd__nand2_1 U29 ( .A(n25), .B(n22), .Y(n21) );
  sky130_fd_sc_hd__nand2_1 U33 ( .A(n27), .B(n25), .Y(n24) );
  sky130_fd_sc_hd__nand2_1 U38 ( .A(n29), .B(n45), .Y(n28) );
  sky130_fd_sc_hd__nor2_1 U39 ( .A(n30), .B(n37), .Y(n29) );
  sky130_fd_sc_hd__nand2_1 U40 ( .A(n34), .B(n31), .Y(n30) );
  sky130_fd_sc_hd__nand2_1 U44 ( .A(n36), .B(n34), .Y(n33) );
  sky130_fd_sc_hd__nor2_1 U48 ( .A(n37), .B(n44), .Y(n36) );
  sky130_fd_sc_hd__nand2_1 U49 ( .A(n42), .B(n38), .Y(n37) );
  sky130_fd_sc_hd__xor2_1 U52 ( .A(n44), .B(n43), .X(SUM[4]) );
  sky130_fd_sc_hd__nor2_1 U53 ( .A(n43), .B(n44), .Y(n40) );
  sky130_fd_sc_hd__nor2_1 U59 ( .A(n53), .B(n46), .Y(n45) );
  sky130_fd_sc_hd__nand2_1 U60 ( .A(n50), .B(n47), .Y(n46) );
  sky130_fd_sc_hd__nand2_1 U64 ( .A(n52), .B(n50), .Y(n49) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(n54), .B(n56), .Y(n53) );
  sky130_fd_sc_hd__nor2b_1 U76 ( .B_N(n13), .A(n28), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U77 ( .A(n45), .Y(n44) );
  sky130_fd_sc_hd__inv_1 U78 ( .A(n28), .Y(n27) );
  sky130_fd_sc_hd__inv_1 U79 ( .A(n53), .Y(n52) );
  sky130_fd_sc_hd__xor2_1 U80 ( .A(n2), .B(n4), .X(SUM[14]) );
  sky130_fd_sc_hd__xor2_1 U81 ( .A(n18), .B(n20), .X(SUM[10]) );
  sky130_fd_sc_hd__xor2_1 U82 ( .A(n25), .B(n27), .X(SUM[8]) );
  sky130_fd_sc_hd__xor2_1 U83 ( .A(n34), .B(n36), .X(SUM[6]) );
  sky130_fd_sc_hd__xor2_1 U84 ( .A(n38), .B(n40), .X(SUM[5]) );
  sky130_fd_sc_hd__xor2_1 U85 ( .A(n50), .B(n52), .X(SUM[2]) );
  sky130_fd_sc_hd__xor2_1 U86 ( .A(n56), .B(n54), .X(SUM[1]) );
  sky130_fd_sc_hd__xnor2_1 U87 ( .A(A[15]), .B(n1), .Y(SUM[15]) );
  sky130_fd_sc_hd__xnor2_1 U88 ( .A(n17), .B(n15), .Y(SUM[11]) );
  sky130_fd_sc_hd__xnor2_1 U89 ( .A(n24), .B(n22), .Y(SUM[9]) );
  sky130_fd_sc_hd__xnor2_1 U90 ( .A(n33), .B(n31), .Y(SUM[7]) );
  sky130_fd_sc_hd__xnor2_1 U91 ( .A(n49), .B(n47), .Y(SUM[3]) );
  sky130_fd_sc_hd__inv_1 U92 ( .A(n56), .Y(SUM[0]) );
  sky130_fd_sc_hd__inv_1 U93 ( .A(n9), .Y(n10) );
  sky130_fd_sc_hd__inv_1 U94 ( .A(A[13]), .Y(n7) );
  sky130_fd_sc_hd__inv_1 U95 ( .A(n42), .Y(n43) );
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
         n102, n103, n104, n105, n106, n108, n109, n110;
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
  sky130_fd_sc_hd__dfrtp_1 s_parity_bit_q_reg ( .D(n118), .CLK(clk_i), 
        .RESET_B(rst_n_i), .Q(s_parity_bit_q) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_7_ ( .D(n120), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[7]), .Q_N(n23) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_6_ ( .D(n126), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[6]), .Q_N(n24) );
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
  sky130_fd_sc_hd__o21ai_1 U9 ( .A1(n103), .A2(n108), .B1(n47), .Y(n121) );
  sky130_fd_sc_hd__o21ai_1 U14 ( .A1(n103), .A2(n24), .B1(n51), .Y(n126) );
  sky130_fd_sc_hd__a22o_1 U63 ( .A1(n103), .A2(rx_data_o[1]), .B1(rx_data_o[0]), .B2(n104), .X(n119) );
  sky130_fd_sc_hd__a22o_1 U65 ( .A1(n103), .A2(rx_data_o[2]), .B1(n104), .B2(
        rx_data_o[1]), .X(n122) );
  sky130_fd_sc_hd__a22o_1 U66 ( .A1(n103), .A2(rx_data_o[3]), .B1(n104), .B2(
        rx_data_o[2]), .X(n123) );
  sky130_fd_sc_hd__a22o_1 U67 ( .A1(n103), .A2(rx_data_o[4]), .B1(n104), .B2(
        rx_data_o[3]), .X(n124) );
  sky130_fd_sc_hd__nand2_1 U69 ( .A(cfg_bits_i[1]), .B(cfg_bits_i[0]), .Y(n46)
         );
  sky130_fd_sc_hd__xor2_1 U75 ( .A(n105), .B(cfg_bits_i[1]), .X(n67) );
  sky130_fd_sc_hd__xor2_1 U76 ( .A(n102), .B(cfg_bits_i[0]), .X(n66) );
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
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_2_ ( .D(n129), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[2]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_1_ ( .D(n128), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[1]) );
  sky130_fd_sc_hd__dfrtp_1 s_fsm_q_reg_0_ ( .D(n127), .CLK(clk_i), .RESET_B(
        rst_n_i), .Q(s_fsm_q[0]) );
  sky130_fd_sc_hd__dfsbp_1 reg_rx_sync_reg_1_ ( .D(N79), .CLK(clk_i), .SET_B(
        rst_n_i), .Q_N(n13) );
  sky130_fd_sc_hd__dfsbp_1 s_reg_data_q_reg_5_ ( .D(n121), .CLK(clk_i), 
        .SET_B(rst_n_i), .Q(rx_data_o[5]), .Q_N(n108) );
  sky130_fd_sc_hd__dfsbp_1 reg_rx_sync_reg_2_ ( .D(N80), .CLK(clk_i), .SET_B(
        rst_n_i), .Q(reg_rx_sync[2]), .Q_N(n97) );
  sky130_fd_sc_hd__o31a_1 U3 ( .A1(n101), .A2(n100), .A3(n99), .B1(n98), .X(n1) );
  sky130_fd_sc_hd__inv_1 U4 ( .A(n7), .Y(n8) );
  sky130_fd_sc_hd__inv_2 U5 ( .A(n81), .Y(rx_valid_o) );
  sky130_fd_sc_hd__and2_1 U6 ( .A(n83), .B(n80), .X(n2) );
  sky130_fd_sc_hd__inv_1 U7 ( .A(n93), .Y(n84) );
  sky130_fd_sc_hd__and2_1 U8 ( .A(n84), .B(n83), .X(n3) );
  sky130_fd_sc_hd__inv_1 U10 ( .A(n80), .Y(n94) );
  sky130_fd_sc_hd__and2_1 U11 ( .A(n81), .B(n100), .X(n5) );
  sky130_fd_sc_hd__inv_2 U12 ( .A(n104), .Y(n103) );
  sky130_fd_sc_hd__inv_2 U13 ( .A(n69), .Y(n70) );
  sky130_fd_sc_hd__nand2_1 U15 ( .A(n94), .B(n84), .Y(n104) );
  sky130_fd_sc_hd__inv_1 U16 ( .A(busy_o), .Y(n73) );
  sky130_fd_sc_hd__nor2b_1 U17 ( .B_N(n71), .A(n72), .Y(N123) );
  sky130_fd_sc_hd__a21boi_1 U18 ( .A1(n68), .A2(n2), .B1_N(n99), .Y(n7) );
  sky130_fd_sc_hd__nor4_1 U19 ( .A(n62), .B(n61), .C(n60), .D(n59), .Y(n64) );
  sky130_fd_sc_hd__nor4_1 U20 ( .A(n38), .B(n34), .C(n33), .D(n32), .Y(n65) );
  sky130_fd_sc_hd__o21a_1 U21 ( .A1(busy_o), .A2(n63), .B1(n83), .X(n4) );
  sky130_fd_sc_hd__nand2b_1 U22 ( .A_N(n68), .B(n77), .Y(n100) );
  sky130_fd_sc_hd__inv_2 U23 ( .A(cfg_bits_i[1]), .Y(n109) );
  sky130_fd_sc_hd__inv_1 U24 ( .A(n9), .Y(n11) );
  sky130_fd_sc_hd__inv_2 U25 ( .A(n100), .Y(n74) );
  sky130_fd_sc_hd__nand3_1 U26 ( .A(s_fsm_q[1]), .B(n82), .C(n77), .Y(n80) );
  sky130_fd_sc_hd__o32ai_1 U27 ( .A1(n35), .A2(s_reg_bit_cnt_q[2]), .A3(n105), 
        .B1(n36), .B2(n106), .Y(n116) );
  sky130_fd_sc_hd__inv_2 U28 ( .A(s_reg_bit_cnt_q[2]), .Y(n106) );
  sky130_fd_sc_hd__a21boi_1 U29 ( .A1(n37), .A2(n105), .B1_N(n6), .Y(n36) );
  sky130_fd_sc_hd__o21a_1 U30 ( .A1(s_reg_bit_cnt_q[0]), .A2(n86), .B1(n3), 
        .X(n6) );
  sky130_fd_sc_hd__inv_1 U31 ( .A(n90), .Y(n88) );
  sky130_fd_sc_hd__o22ai_1 U32 ( .A1(n6), .A2(n105), .B1(s_reg_bit_cnt_q[1]), 
        .B2(n35), .Y(n130) );
  sky130_fd_sc_hd__nand3_1 U33 ( .A(n66), .B(s_reg_bit_cnt_q[2]), .C(n67), .Y(
        n37) );
  sky130_fd_sc_hd__inv_2 U34 ( .A(s_reg_bit_cnt_q[1]), .Y(n105) );
  sky130_fd_sc_hd__o2bb2ai_1 U35 ( .B1(n49), .B2(n104), .A1_N(n104), .A2_N(
        rx_data_o[4]), .Y(n125) );
  sky130_fd_sc_hd__inv_1 U36 ( .A(cfg_bits_i[0]), .Y(n110) );
  sky130_fd_sc_hd__o2bb2ai_1 U37 ( .B1(err_clr_i), .B2(n1), .A1_N(err_o), 
        .A2_N(n1), .Y(n115) );
  sky130_fd_sc_hd__inv_2 U38 ( .A(s_fsm_q[2]), .Y(n82) );
  sky130_fd_sc_hd__inv_1 U39 ( .A(s_fsm_q[1]), .Y(n12) );
  sky130_fd_sc_hd__nand3_1 U40 ( .A(s_fsm_q[0]), .B(n12), .C(n82), .Y(n83) );
  sky130_fd_sc_hd__inv_1 U41 ( .A(s_fsm_q[0]), .Y(n77) );
  sky130_fd_sc_hd__nand2_1 U42 ( .A(s_fsm_q[2]), .B(n12), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U43 ( .A(s_bit_done), .Y(n99) );
  sky130_fd_sc_hd__nand3_1 U44 ( .A(s_fsm_q[0]), .B(s_fsm_q[1]), .C(n82), .Y(
        n81) );
  sky130_fd_sc_hd__nand2_1 U45 ( .A(n13), .B(reg_rx_sync[2]), .Y(n63) );
  sky130_fd_sc_hd__nand3_1 U46 ( .A(n12), .B(n82), .C(n77), .Y(busy_o) );
  sky130_fd_sc_hd__nand2_1 U47 ( .A(n63), .B(n73), .Y(n9) );
  sky130_fd_sc_hd__nand3_1 U48 ( .A(n9), .B(n8), .C(rx_ready_i), .Y(n10) );
  sky130_fd_sc_hd__o311ai_1 U49 ( .A1(n7), .A2(rx_valid_o), .A3(n11), .B1(
        cfg_en_i), .C1(n10), .Y(n76) );
  sky130_fd_sc_hd__nand2_1 U50 ( .A(cfg_en_i), .B(n76), .Y(n78) );
  sky130_fd_sc_hd__o22ai_1 U51 ( .A1(n2), .A2(n78), .B1(n12), .B2(n76), .Y(
        n128) );
  sky130_fd_sc_hd__o22ai_1 U52 ( .A1(n5), .A2(n78), .B1(n82), .B2(n76), .Y(
        n129) );
  sky130_fd_sc_hd__nand2b_1 U53 ( .A_N(reg_rx_sync[0]), .B(cfg_en_i), .Y(N79)
         );
  sky130_fd_sc_hd__nand2_1 U54 ( .A(n13), .B(cfg_en_i), .Y(N80) );
  sky130_fd_sc_hd__xnor2_1 U55 ( .A(cfg_div_i[10]), .B(s_baud_cnt[9]), .Y(n17)
         );
  sky130_fd_sc_hd__xnor2_1 U56 ( .A(cfg_div_i[1]), .B(s_baud_cnt[0]), .Y(n16)
         );
  sky130_fd_sc_hd__xnor2_1 U57 ( .A(s_baud_cnt[1]), .B(cfg_div_i[2]), .Y(n15)
         );
  sky130_fd_sc_hd__inv_1 U58 ( .A(s_baud_cnt[15]), .Y(n14) );
  sky130_fd_sc_hd__nand4_1 U59 ( .A(n17), .B(n16), .C(n15), .D(n14), .Y(n38)
         );
  sky130_fd_sc_hd__xnor2_1 U60 ( .A(cfg_div_i[3]), .B(s_baud_cnt[2]), .Y(n21)
         );
  sky130_fd_sc_hd__xnor2_1 U61 ( .A(cfg_div_i[6]), .B(s_baud_cnt[5]), .Y(n20)
         );
  sky130_fd_sc_hd__xnor2_1 U62 ( .A(s_baud_cnt[4]), .B(cfg_div_i[5]), .Y(n19)
         );
  sky130_fd_sc_hd__xnor2_1 U64 ( .A(s_baud_cnt[7]), .B(cfg_div_i[8]), .Y(n18)
         );
  sky130_fd_sc_hd__nand4_1 U68 ( .A(n21), .B(n20), .C(n19), .D(n18), .Y(n34)
         );
  sky130_fd_sc_hd__xnor2_1 U70 ( .A(s_baud_cnt[8]), .B(cfg_div_i[9]), .Y(n27)
         );
  sky130_fd_sc_hd__xnor2_1 U71 ( .A(cfg_div_i[7]), .B(s_baud_cnt[6]), .Y(n26)
         );
  sky130_fd_sc_hd__xnor2_1 U72 ( .A(s_baud_cnt[10]), .B(cfg_div_i[11]), .Y(n25) );
  sky130_fd_sc_hd__xnor2_1 U73 ( .A(s_baud_cnt[11]), .B(cfg_div_i[12]), .Y(n22) );
  sky130_fd_sc_hd__nand4_1 U74 ( .A(n27), .B(n26), .C(n25), .D(n22), .Y(n33)
         );
  sky130_fd_sc_hd__xnor2_1 U77 ( .A(s_baud_cnt[3]), .B(cfg_div_i[4]), .Y(n31)
         );
  sky130_fd_sc_hd__xnor2_1 U78 ( .A(cfg_div_i[14]), .B(s_baud_cnt[13]), .Y(n30) );
  sky130_fd_sc_hd__xnor2_1 U80 ( .A(s_baud_cnt[14]), .B(cfg_div_i[15]), .Y(n29) );
  sky130_fd_sc_hd__xnor2_1 U81 ( .A(s_baud_cnt[12]), .B(cfg_div_i[13]), .Y(n28) );
  sky130_fd_sc_hd__nand4_1 U82 ( .A(n31), .B(n30), .C(n29), .D(n28), .Y(n32)
         );
  sky130_fd_sc_hd__xnor2_1 U83 ( .A(s_baud_cnt[12]), .B(cfg_div_i[12]), .Y(n42) );
  sky130_fd_sc_hd__xnor2_1 U84 ( .A(s_baud_cnt[13]), .B(cfg_div_i[13]), .Y(n41) );
  sky130_fd_sc_hd__xnor2_1 U85 ( .A(s_baud_cnt[4]), .B(cfg_div_i[4]), .Y(n40)
         );
  sky130_fd_sc_hd__xnor2_1 U86 ( .A(s_baud_cnt[5]), .B(cfg_div_i[5]), .Y(n39)
         );
  sky130_fd_sc_hd__nand4_1 U87 ( .A(n42), .B(n41), .C(n40), .D(n39), .Y(n62)
         );
  sky130_fd_sc_hd__xnor2_1 U88 ( .A(s_baud_cnt[8]), .B(cfg_div_i[8]), .Y(n48)
         );
  sky130_fd_sc_hd__xnor2_1 U89 ( .A(s_baud_cnt[9]), .B(cfg_div_i[9]), .Y(n45)
         );
  sky130_fd_sc_hd__xnor2_1 U90 ( .A(s_baud_cnt[15]), .B(cfg_div_i[15]), .Y(n44) );
  sky130_fd_sc_hd__xnor2_1 U91 ( .A(s_baud_cnt[14]), .B(cfg_div_i[14]), .Y(n43) );
  sky130_fd_sc_hd__nand4_1 U92 ( .A(n48), .B(n45), .C(n44), .D(n43), .Y(n61)
         );
  sky130_fd_sc_hd__xnor2_1 U93 ( .A(s_baud_cnt[7]), .B(cfg_div_i[7]), .Y(n54)
         );
  sky130_fd_sc_hd__xnor2_1 U94 ( .A(s_baud_cnt[6]), .B(cfg_div_i[6]), .Y(n53)
         );
  sky130_fd_sc_hd__xnor2_1 U95 ( .A(s_baud_cnt[11]), .B(cfg_div_i[11]), .Y(n52) );
  sky130_fd_sc_hd__xnor2_1 U96 ( .A(s_baud_cnt[10]), .B(cfg_div_i[10]), .Y(n50) );
  sky130_fd_sc_hd__nand4_1 U97 ( .A(n54), .B(n53), .C(n52), .D(n50), .Y(n60)
         );
  sky130_fd_sc_hd__xnor2_1 U98 ( .A(s_baud_cnt[1]), .B(cfg_div_i[1]), .Y(n58)
         );
  sky130_fd_sc_hd__xnor2_1 U99 ( .A(s_baud_cnt[0]), .B(cfg_div_i[0]), .Y(n57)
         );
  sky130_fd_sc_hd__xnor2_1 U100 ( .A(s_baud_cnt[3]), .B(cfg_div_i[3]), .Y(n56)
         );
  sky130_fd_sc_hd__xnor2_1 U101 ( .A(s_baud_cnt[2]), .B(cfg_div_i[2]), .Y(n55)
         );
  sky130_fd_sc_hd__nand4_1 U102 ( .A(n58), .B(n57), .C(n56), .D(n55), .Y(n59)
         );
  sky130_fd_sc_hd__mux2i_1 U103 ( .A0(n65), .A1(n64), .S(n4), .Y(n72) );
  sky130_fd_sc_hd__nand4_1 U104 ( .A(n4), .B(n5), .C(n80), .D(n68), .Y(n71) );
  sky130_fd_sc_hd__nand2_1 U105 ( .A(n72), .B(n71), .Y(n69) );
  sky130_fd_sc_hd__and2_0 U106 ( .A(N105), .B(n70), .X(N139) );
  sky130_fd_sc_hd__and2_0 U107 ( .A(N104), .B(n70), .X(N138) );
  sky130_fd_sc_hd__and2_0 U108 ( .A(N103), .B(n70), .X(N137) );
  sky130_fd_sc_hd__and2_0 U109 ( .A(N102), .B(n70), .X(N136) );
  sky130_fd_sc_hd__and2_0 U110 ( .A(N101), .B(n70), .X(N135) );
  sky130_fd_sc_hd__and2_0 U111 ( .A(N100), .B(n70), .X(N134) );
  sky130_fd_sc_hd__and2_0 U112 ( .A(N99), .B(n70), .X(N133) );
  sky130_fd_sc_hd__and2_0 U113 ( .A(N98), .B(n70), .X(N132) );
  sky130_fd_sc_hd__and2_0 U114 ( .A(N97), .B(n70), .X(N131) );
  sky130_fd_sc_hd__and2_0 U115 ( .A(N96), .B(n70), .X(N130) );
  sky130_fd_sc_hd__and2_0 U116 ( .A(N95), .B(n70), .X(N129) );
  sky130_fd_sc_hd__and2_0 U117 ( .A(N94), .B(n70), .X(N128) );
  sky130_fd_sc_hd__and2_0 U118 ( .A(N93), .B(n70), .X(N127) );
  sky130_fd_sc_hd__and2_0 U119 ( .A(N92), .B(n70), .X(N126) );
  sky130_fd_sc_hd__and2_0 U120 ( .A(N90), .B(n70), .X(N124) );
  sky130_fd_sc_hd__and2_0 U121 ( .A(N91), .B(n70), .X(N125) );
  sky130_fd_sc_hd__o22ai_1 U122 ( .A1(cfg_parity_en_i), .A2(n81), .B1(n37), 
        .B2(n80), .Y(n75) );
  sky130_fd_sc_hd__nor3_1 U123 ( .A(n75), .B(n74), .C(n73), .Y(n79) );
  sky130_fd_sc_hd__o22ai_1 U124 ( .A1(n79), .A2(n78), .B1(n77), .B2(n76), .Y(
        n127) );
  sky130_fd_sc_hd__nand4_1 U125 ( .A(s_bit_done), .B(n82), .C(n81), .D(busy_o), 
        .Y(n93) );
  sky130_fd_sc_hd__nand2_1 U126 ( .A(reg_rx_sync[2]), .B(n103), .Y(n90) );
  sky130_fd_sc_hd__o22ai_1 U127 ( .A1(n46), .A2(n90), .B1(n23), .B2(n103), .Y(
        n120) );
  sky130_fd_sc_hd__nand2_1 U128 ( .A(n37), .B(n3), .Y(n85) );
  sky130_fd_sc_hd__mux2i_1 U129 ( .A0(n85), .A1(n3), .S(s_reg_bit_cnt_q[0]), 
        .Y(n117) );
  sky130_fd_sc_hd__inv_1 U130 ( .A(s_reg_bit_cnt_q[0]), .Y(n102) );
  sky130_fd_sc_hd__inv_1 U131 ( .A(n37), .Y(n86) );
  sky130_fd_sc_hd__nand3_1 U132 ( .A(n37), .B(s_reg_bit_cnt_q[0]), .C(n3), .Y(
        n35) );
  sky130_fd_sc_hd__nor3_1 U133 ( .A(n23), .B(n46), .C(n104), .Y(n87) );
  sky130_fd_sc_hd__a31oi_1 U134 ( .A1(n110), .A2(cfg_bits_i[1]), .A3(n88), 
        .B1(n87), .Y(n51) );
  sky130_fd_sc_hd__o22ai_1 U135 ( .A1(cfg_bits_i[0]), .A2(n97), .B1(n110), 
        .B2(n108), .Y(n89) );
  sky130_fd_sc_hd__a22oi_1 U136 ( .A1(n109), .A2(n89), .B1(cfg_bits_i[1]), 
        .B2(rx_data_o[5]), .Y(n49) );
  sky130_fd_sc_hd__nor2_1 U137 ( .A(n24), .B(n104), .Y(n92) );
  sky130_fd_sc_hd__nor2_1 U138 ( .A(n90), .B(n110), .Y(n91) );
  sky130_fd_sc_hd__mux2i_1 U139 ( .A0(n92), .A1(n91), .S(n109), .Y(n47) );
  sky130_fd_sc_hd__nand2_1 U140 ( .A(n103), .B(reg_rx_sync[2]), .Y(n96) );
  sky130_fd_sc_hd__a21oi_1 U141 ( .A1(n97), .A2(n94), .B1(n93), .Y(n95) );
  sky130_fd_sc_hd__mux2i_1 U142 ( .A0(n96), .A1(n95), .S(s_parity_bit_q), .Y(
        n118) );
  sky130_fd_sc_hd__xor2_1 U143 ( .A(n97), .B(s_parity_bit_q), .X(n101) );
  sky130_fd_sc_hd__inv_1 U144 ( .A(err_clr_i), .Y(n98) );
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
         n17, n18, n19, n20, n21, n22, n23, n24, n25;
  wire   [2:0] s_ip_d;

  dffr_DATA_WIDTH3 u_ip_dffr ( .clk_i(clk_i), .rst_n_i(rst_n_i), .dat_i(s_ip_d), .dat_o(ip_o) );
  sky130_fd_sc_hd__nor3_1 U3 ( .A(n12), .B(n13), .C(rx_elem_i[0]), .Y(n14) );
  sky130_fd_sc_hd__inv_2 U4 ( .A(n21), .Y(n23) );
  sky130_fd_sc_hd__nand4b_1 U5 ( .A_N(n22), .B(n24), .C(n21), .D(ip_o[2]), .Y(
        n18) );
  sky130_fd_sc_hd__or3b_1 U6 ( .A(ip_o[1]), .B(ip_o[2]), .C_N(n25), .X(irq_o)
         );
  sky130_fd_sc_hd__nand2_1 U7 ( .A(pe_i), .B(irq_en_i[2]), .Y(n19) );
  sky130_fd_sc_hd__inv_1 U8 ( .A(clr_int_i), .Y(n1) );
  sky130_fd_sc_hd__nand2_1 U9 ( .A(n19), .B(n1), .Y(n22) );
  sky130_fd_sc_hd__nor4b_1 U10 ( .D_N(irq_en_i[1]), .A(tx_elem_i[2]), .B(
        tx_elem_i[1]), .C(tx_elem_i[0]), .Y(n3) );
  sky130_fd_sc_hd__nor4_1 U11 ( .A(tx_elem_i[6]), .B(tx_elem_i[5]), .C(
        tx_elem_i[4]), .D(tx_elem_i[3]), .Y(n2) );
  sky130_fd_sc_hd__nand2_1 U12 ( .A(n3), .B(n2), .Y(n21) );
  sky130_fd_sc_hd__inv_1 U13 ( .A(rx_elem_i[1]), .Y(n9) );
  sky130_fd_sc_hd__inv_1 U14 ( .A(trg_level_i[0]), .Y(n4) );
  sky130_fd_sc_hd__nor2_1 U15 ( .A(n9), .B(n4), .Y(n6) );
  sky130_fd_sc_hd__nor2_1 U16 ( .A(trg_level_i[0]), .B(rx_elem_i[1]), .Y(n5)
         );
  sky130_fd_sc_hd__mux2i_1 U17 ( .A0(n6), .A1(n5), .S(rx_elem_i[0]), .Y(n7) );
  sky130_fd_sc_hd__nor3_1 U18 ( .A(rx_elem_i[2]), .B(rx_elem_i[3]), .C(n7), 
        .Y(n15) );
  sky130_fd_sc_hd__nor2_1 U19 ( .A(rx_elem_i[1]), .B(rx_elem_i[2]), .Y(n11) );
  sky130_fd_sc_hd__inv_1 U20 ( .A(rx_elem_i[2]), .Y(n8) );
  sky130_fd_sc_hd__nor2_1 U21 ( .A(n9), .B(n8), .Y(n10) );
  sky130_fd_sc_hd__mux2i_1 U22 ( .A0(n11), .A1(n10), .S(trg_level_i[0]), .Y(
        n13) );
  sky130_fd_sc_hd__inv_1 U23 ( .A(rx_elem_i[3]), .Y(n12) );
  sky130_fd_sc_hd__mux2i_1 U24 ( .A0(n15), .A1(n14), .S(trg_level_i[1]), .Y(
        n16) );
  sky130_fd_sc_hd__nor4_1 U25 ( .A(n16), .B(rx_elem_i[5]), .C(rx_elem_i[4]), 
        .D(rx_elem_i[6]), .Y(n17) );
  sky130_fd_sc_hd__o31ai_1 U26 ( .A1(cti_i), .A2(thre_i), .A3(n17), .B1(
        irq_en_i[0]), .Y(n24) );
  sky130_fd_sc_hd__o21ai_1 U27 ( .A1(clr_int_i), .A2(n19), .B1(n18), .Y(
        s_ip_d[2]) );
  sky130_fd_sc_hd__nand2_1 U28 ( .A(n24), .B(ip_o[1]), .Y(n20) );
  sky130_fd_sc_hd__a21oi_1 U29 ( .A1(n20), .A2(n21), .B1(n22), .Y(s_ip_d[1])
         );
  sky130_fd_sc_hd__inv_1 U30 ( .A(ip_o[0]), .Y(n25) );
  sky130_fd_sc_hd__a211oi_1 U31 ( .A1(n24), .A2(n25), .B1(n23), .C1(n22), .Y(
        s_ip_d[0]) );
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
         n90;
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
  sky130_fd_sc_hd__and2_0 U73 ( .A(s_tx_pop_ready), .B(n54), .X(
        s_uart_lsr_d[6]) );
  sky130_fd_sc_hd__nand4b_1 U75 ( .A_N(apb4_paddr[4]), .B(apb4_paddr[3]), .C(
        apb4_paddr[2]), .D(n37), .Y(n38) );
  sky130_fd_sc_hd__a22o_1 U76 ( .A1(n39), .A2(s_uart_div_q[9]), .B1(
        apb4_pwdata[9]), .B2(n78), .X(s_uart_div_d[9]) );
  sky130_fd_sc_hd__a22o_1 U77 ( .A1(n39), .A2(s_uart_div_q[15]), .B1(
        apb4_pwdata[15]), .B2(n78), .X(s_uart_div_d[15]) );
  sky130_fd_sc_hd__a22o_1 U78 ( .A1(n39), .A2(s_uart_div_q[14]), .B1(
        apb4_pwdata[14]), .B2(n78), .X(s_uart_div_d[14]) );
  sky130_fd_sc_hd__a22o_1 U79 ( .A1(n39), .A2(s_uart_div_q[13]), .B1(
        apb4_pwdata[13]), .B2(n78), .X(s_uart_div_d[13]) );
  sky130_fd_sc_hd__a22o_1 U80 ( .A1(n39), .A2(s_uart_div_q[12]), .B1(
        apb4_pwdata[12]), .B2(n78), .X(s_uart_div_d[12]) );
  sky130_fd_sc_hd__a22o_1 U81 ( .A1(n39), .A2(s_uart_div_q[11]), .B1(
        apb4_pwdata[11]), .B2(n78), .X(s_uart_div_d[11]) );
  sky130_fd_sc_hd__a22o_1 U82 ( .A1(n39), .A2(s_uart_div_q[10]), .B1(
        apb4_pwdata[10]), .B2(n78), .X(s_uart_div_d[10]) );
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
  sky130_fd_sc_hd__and4_1 U103 ( .A(apb4_paddr[4]), .B(n52), .C(n81), .D(n80), 
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
        .dat_i({s_uart_lsr_d[6], n54, s_uart_lsr_d[4], n58, s_uart_lsr_d[2:0]}), .dat_o(s_uart_lsr_q) );
  fifo_DATA_WIDTH8_BUFFER_DEPTH64 u_tx_fifo ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .flush_i(s_uart_fcr_q[1]), .empty_o(s_tx_pop_valid), 
        .cnt_o(s_tx_elem), .dat_i(s_tx_push_data), .push_i(N19), .dat_o(
        s_tx_pop_data), .pop_i(s_tx_pop_ready) );
  uart_tx u_uart_tx ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .tx_o(
        uart_uart_tx_o), .cfg_en_i(apb4_pready), .cfg_div_i(s_uart_div_q), 
        .cfg_parity_en_i(s_uart_lcr_q[6]), .cfg_bits_i(s_uart_lcr_q[4:3]), 
        .cfg_stop_bits_i(s_uart_lcr_q[5]), .tx_data_i(s_tx_pop_data), 
        .tx_valid_i(n60), .tx_ready_o(s_tx_pop_ready) );
  fifo_DATA_WIDTH9_BUFFER_DEPTH64 u_rx_fifo ( .clk_i(apb4_pclk), .rst_n_i(
        apb4_presetn), .flush_i(s_uart_fcr_q[0]), .full_o(s_rx_push_ready), 
        .empty_o(s_rx_pop_valid), .cnt_o(s_rx_elem), .dat_i({s_parity_err, 
        s_rx_push_data}), .push_i(s_rx_push_valid), .dat_o({s_uart_lsr_d[4], 
        s_rx_pop_data}), .pop_i(s_rx_pop_ready) );
  uart_rx u_uart_rx ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), .rx_i(
        uart_uart_rx_i), .cfg_en_i(apb4_pready), .cfg_div_i(s_uart_div_q), 
        .cfg_parity_en_i(s_uart_lcr_q[6]), .cfg_bits_i({n57, s_uart_lcr_q[3]}), 
        .err_o(s_parity_err), .err_clr_i(apb4_pready), .rx_data_o(
        s_rx_push_data), .rx_valid_o(s_rx_push_valid), .rx_ready_i(n59) );
  uart_irq_FIFO_DEPTH64 u_uart_irq ( .clk_i(apb4_pclk), .rst_n_i(apb4_presetn), 
        .clr_int_i(s_clr_int), .irq_en_i(s_uart_lcr_q[2:0]), .thre_i(
        s_uart_lsr_q[5]), .cti_i(apb4_pslverr), .pe_i(s_uart_lsr_q[4]), 
        .rx_elem_i(s_rx_elem), .tx_elem_i(s_tx_elem), .trg_level_i(
        s_uart_fcr_q[3:2]), .ip_o(s_uart_lsr_d[2:0]), .irq_o(uart_irq_o) );
  sky130_fd_sc_hd__inv_1 U106 ( .A(s_uart_div_q[0]), .Y(n69) );
  sky130_fd_sc_hd__inv_2 U107 ( .A(s_rx_pop_valid), .Y(n58) );
  sky130_fd_sc_hd__inv_2 U108 ( .A(n39), .Y(n78) );
  sky130_fd_sc_hd__inv_2 U109 ( .A(n35), .Y(n79) );
  sky130_fd_sc_hd__inv_1 U110 ( .A(s_rx_push_ready), .Y(n59) );
  sky130_fd_sc_hd__o22ai_1 U111 ( .A1(n89), .A2(n39), .B1(n78), .B2(n68), .Y(
        s_uart_div_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U112 ( .A1(n35), .A2(n86), .B1(n79), .B2(n56), .Y(
        s_uart_lcr_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U113 ( .A1(n83), .A2(n39), .B1(n78), .B2(n62), .Y(
        s_uart_div_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U114 ( .A1(n88), .A2(n39), .B1(n78), .B2(n67), .Y(
        s_uart_div_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U115 ( .A1(n86), .A2(n39), .B1(n78), .B2(n65), .Y(
        s_uart_div_d[4]) );
  sky130_fd_sc_hd__o22ai_1 U116 ( .A1(n85), .A2(n39), .B1(n78), .B2(n64), .Y(
        s_uart_div_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U117 ( .A1(n82), .A2(n39), .B1(n78), .B2(n61), .Y(
        s_uart_div_d[8]) );
  sky130_fd_sc_hd__o22ai_1 U118 ( .A1(n87), .A2(n39), .B1(n78), .B2(n66), .Y(
        s_uart_div_d[3]) );
  sky130_fd_sc_hd__o22ai_1 U119 ( .A1(n84), .A2(n39), .B1(n78), .B2(n63), .Y(
        s_uart_div_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U120 ( .A1(n90), .A2(n39), .B1(n78), .B2(n69), .Y(
        s_uart_div_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U121 ( .A1(n35), .A2(n84), .B1(n79), .B2(n72), .Y(
        s_uart_lcr_d[6]) );
  sky130_fd_sc_hd__o22ai_1 U122 ( .A1(n35), .A2(n85), .B1(n79), .B2(n73), .Y(
        s_uart_lcr_d[5]) );
  sky130_fd_sc_hd__o22ai_1 U123 ( .A1(n35), .A2(n90), .B1(n79), .B2(n77), .Y(
        s_uart_lcr_d[0]) );
  sky130_fd_sc_hd__o22ai_1 U124 ( .A1(n35), .A2(n88), .B1(n79), .B2(n75), .Y(
        s_uart_lcr_d[2]) );
  sky130_fd_sc_hd__o22ai_1 U125 ( .A1(n35), .A2(n89), .B1(n79), .B2(n76), .Y(
        s_uart_lcr_d[1]) );
  sky130_fd_sc_hd__o22ai_1 U126 ( .A1(n35), .A2(n83), .B1(n79), .B2(n71), .Y(
        s_uart_lcr_d[7]) );
  sky130_fd_sc_hd__o22ai_1 U127 ( .A1(n35), .A2(n82), .B1(n79), .B2(n70), .Y(
        s_uart_lcr_d[8]) );
  sky130_fd_sc_hd__nand2_1 U128 ( .A(n40), .B(n37), .Y(n39) );
  sky130_fd_sc_hd__nand2_1 U129 ( .A(n52), .B(n40), .Y(n42) );
  sky130_fd_sc_hd__nand2_1 U130 ( .A(n36), .B(n37), .Y(n35) );
  sky130_fd_sc_hd__nand2_1 U131 ( .A(n52), .B(n36), .Y(n43) );
  sky130_fd_sc_hd__o221ai_1 U132 ( .A1(n71), .A2(n43), .B1(n62), .B2(n42), 
        .C1(n44), .Y(apb4_prdata[7]) );
  sky130_fd_sc_hd__and2_1 U133 ( .A(n52), .B(n53), .X(s_rx_pop_ready) );
  sky130_fd_sc_hd__o22ai_1 U134 ( .A1(n61), .A2(n42), .B1(n70), .B2(n43), .Y(
        apb4_prdata[8]) );
  sky130_fd_sc_hd__and2_1 U135 ( .A(n53), .B(n37), .X(N19) );
  sky130_fd_sc_hd__or4_1 U136 ( .A(s_tx_elem[4]), .B(s_tx_elem[3]), .C(
        s_tx_elem[6]), .D(s_tx_elem[5]), .X(n41) );
  sky130_fd_sc_hd__inv_1 U137 ( .A(s_uart_div_q[1]), .Y(n68) );
  sky130_fd_sc_hd__inv_1 U138 ( .A(s_uart_lcr_q[3]), .Y(n74) );
  sky130_fd_sc_hd__inv_1 U139 ( .A(s_uart_div_q[7]), .Y(n62) );
  sky130_fd_sc_hd__inv_1 U140 ( .A(s_uart_div_q[2]), .Y(n67) );
  sky130_fd_sc_hd__inv_1 U141 ( .A(s_uart_div_q[4]), .Y(n65) );
  sky130_fd_sc_hd__inv_1 U142 ( .A(s_uart_div_q[5]), .Y(n64) );
  sky130_fd_sc_hd__inv_1 U143 ( .A(s_uart_div_q[8]), .Y(n61) );
  sky130_fd_sc_hd__inv_1 U144 ( .A(s_uart_div_q[3]), .Y(n66) );
  sky130_fd_sc_hd__inv_1 U145 ( .A(s_uart_div_q[6]), .Y(n63) );
  sky130_fd_sc_hd__o2bb2ai_1 U146 ( .B1(n88), .B2(n38), .A1_N(s_uart_fcr_q[2]), 
        .A2_N(n38), .Y(s_uart_fcr_d[2]) );
  sky130_fd_sc_hd__inv_2 U147 ( .A(s_uart_lcr_q[6]), .Y(n72) );
  sky130_fd_sc_hd__o2bb2ai_1 U148 ( .B1(n87), .B2(n38), .A1_N(s_uart_fcr_q[3]), 
        .A2_N(n38), .Y(s_uart_fcr_d[3]) );
  sky130_fd_sc_hd__o2bb2ai_1 U149 ( .B1(n90), .B2(n38), .A1_N(s_uart_fcr_q[0]), 
        .A2_N(n38), .Y(s_uart_fcr_d[0]) );
  sky130_fd_sc_hd__o2bb2ai_1 U150 ( .B1(n89), .B2(n38), .A1_N(s_uart_fcr_q[1]), 
        .A2_N(n38), .Y(s_uart_fcr_d[1]) );
  sky130_fd_sc_hd__inv_2 U151 ( .A(s_uart_lcr_q[5]), .Y(n73) );
  sky130_fd_sc_hd__inv_2 U152 ( .A(s_uart_lcr_q[0]), .Y(n77) );
  sky130_fd_sc_hd__inv_2 U153 ( .A(s_uart_lcr_q[2]), .Y(n75) );
  sky130_fd_sc_hd__inv_2 U154 ( .A(s_uart_lcr_q[1]), .Y(n76) );
  sky130_fd_sc_hd__inv_2 U155 ( .A(s_uart_lcr_q[7]), .Y(n71) );
  sky130_fd_sc_hd__inv_2 U156 ( .A(s_uart_lcr_q[8]), .Y(n70) );
  sky130_fd_sc_hd__nor3_1 U157 ( .A(apb4_paddr[3]), .B(apb4_paddr[4]), .C(n81), 
        .Y(n40) );
  sky130_fd_sc_hd__nor3_1 U158 ( .A(apb4_paddr[3]), .B(apb4_paddr[4]), .C(
        apb4_paddr[2]), .Y(n36) );
  sky130_fd_sc_hd__nor4bb_1 U159 ( .C_N(apb4_psel), .D_N(apb4_penable), .A(
        apb4_paddr[5]), .B(apb4_pwrite), .Y(n52) );
  sky130_fd_sc_hd__nor3_1 U160 ( .A(apb4_paddr[2]), .B(apb4_paddr[4]), .C(n80), 
        .Y(n53) );
  sky130_fd_sc_hd__inv_2 U161 ( .A(apb4_pwdata[0]), .Y(n90) );
  sky130_fd_sc_hd__inv_2 U162 ( .A(apb4_pwdata[1]), .Y(n89) );
  sky130_fd_sc_hd__inv_2 U163 ( .A(apb4_pwdata[2]), .Y(n88) );
  sky130_fd_sc_hd__inv_2 U164 ( .A(apb4_pwdata[3]), .Y(n87) );
  sky130_fd_sc_hd__inv_2 U165 ( .A(apb4_pwdata[4]), .Y(n86) );
  sky130_fd_sc_hd__inv_2 U166 ( .A(apb4_pwdata[5]), .Y(n85) );
  sky130_fd_sc_hd__inv_2 U167 ( .A(apb4_pwdata[6]), .Y(n84) );
  sky130_fd_sc_hd__inv_2 U168 ( .A(apb4_pwdata[7]), .Y(n83) );
  sky130_fd_sc_hd__inv_2 U169 ( .A(apb4_pwdata[8]), .Y(n82) );
  sky130_fd_sc_hd__o22ai_1 U170 ( .A1(n69), .A2(n42), .B1(n77), .B2(n43), .Y(
        n51) );
  sky130_fd_sc_hd__o22ai_1 U171 ( .A1(n68), .A2(n42), .B1(n76), .B2(n43), .Y(
        n50) );
  sky130_fd_sc_hd__o22ai_1 U172 ( .A1(n67), .A2(n42), .B1(n75), .B2(n43), .Y(
        n49) );
  sky130_fd_sc_hd__o22ai_1 U173 ( .A1(n66), .A2(n42), .B1(n74), .B2(n43), .Y(
        n48) );
  sky130_fd_sc_hd__o22ai_1 U174 ( .A1(n65), .A2(n42), .B1(n56), .B2(n43), .Y(
        n47) );
  sky130_fd_sc_hd__o22ai_1 U175 ( .A1(n64), .A2(n42), .B1(n73), .B2(n43), .Y(
        n46) );
  sky130_fd_sc_hd__o22ai_1 U176 ( .A1(n63), .A2(n42), .B1(n72), .B2(n43), .Y(
        n45) );
  sky130_fd_sc_hd__inv_2 U177 ( .A(apb4_paddr[3]), .Y(n80) );
  sky130_fd_sc_hd__inv_2 U178 ( .A(apb4_paddr[2]), .Y(n81) );
  sky130_fd_sc_hd__conb_1 U179 ( .LO(apb4_pslverr), .HI(apb4_pready) );
  sky130_fd_sc_hd__o22ai_1 U180 ( .A1(n35), .A2(n87), .B1(n79), .B2(n74), .Y(
        s_uart_lcr_d[3]) );
  sky130_fd_sc_hd__inv_2 U181 ( .A(s_tx_pop_valid), .Y(n60) );
  sky130_fd_sc_hd__inv_1 U182 ( .A(s_uart_lcr_q[4]), .Y(n56) );
  sky130_fd_sc_hd__inv_2 U183 ( .A(n56), .Y(n57) );
  sky130_fd_sc_hd__nor4_1 U184 ( .A(s_tx_elem[2]), .B(s_tx_elem[1]), .C(
        s_tx_elem[0]), .D(n41), .Y(n54) );
endmodule

