# Stage 1 - verifier fidelity

improver_id: 8992e76f8b4349de
designs: 32  candidates: 927

## Spearman rho (median over designs, bootstrap 95%% CI)

| rung | truth | rho |
|---|---|---|
| V0_gp_internal_hpwl | egr_max | -0.644 [-0.659,-0.480] |
| V0_gp_internal_hpwl | egr_union | -0.918 [-0.896,-0.788] |
| V0_gp_internal_hpwl | legal_hpwl | -0.892 [-0.841,-0.596] |
| V0b_route_util | egr_max | +0.571 [+0.404,+0.589] |
| V0b_route_util | egr_union | +0.737 [+0.570,+0.737] |
| V0b_route_util | legal_hpwl | +0.682 [+0.532,+0.723] |
| V1_legal_hpwl | egr_max | +0.715 [+0.461,+0.692] |
| V1_legal_hpwl | egr_union | +0.970 [+0.699,+0.932] |
| V1_legal_hpwl | legal_hpwl | +1.000 [+1.000,+1.000] |
| V1u_unlegal_hpwl | egr_max | -0.640 [-0.660,-0.485] |
| V1u_unlegal_hpwl | egr_union | -0.922 [-0.895,-0.784] |
| V1u_unlegal_hpwl | legal_hpwl | -0.891 [-0.839,-0.589] |
| V1x_state_best_hpwl | egr_max | -0.640 [-0.660,-0.485] |
| V1x_state_best_hpwl | egr_union | -0.922 [-0.895,-0.784] |
| V1x_state_best_hpwl | legal_hpwl | -0.891 [-0.839,-0.589] |
| V2_fair_ruler | egr_max | +0.733 [+0.597,+0.718] |
| V2_fair_ruler | egr_union | +0.999 [+0.965,+0.997] |
| V2_fair_ruler | legal_hpwl | +0.976 [+0.791,+0.926] |

## Selection regret of the rung-selected best candidate

(relative to the truth-selected best of the same pool; 0 = no cost)

| rung | HPWL regret | EGR regret | composite regret |
|---|---|---|---|
| V0_gp_internal_hpwl | +0.197 [+0.188,+0.327] | +1.247 [+1.286,+7.006] | +0.726 [+0.774,+3.645] |
| V0b_route_util | +0.006 [+0.007,+0.019] | +0.007 [-0.036,+0.122] | +0.006 [+0.021,+0.072] |
| V1u_unlegal_hpwl | +0.197 [+0.190,+0.338] | +1.255 [+1.317,+7.150] | +0.726 [+0.795,+3.720] |
| V1x_state_best_hpwl | +0.197 [+0.190,+0.338] | +1.255 [+1.317,+7.150] | +0.726 [+0.795,+3.720] |
| V1_legal_hpwl | +0.000 [+0.000,+0.000] | +0.000 [+0.042,+0.476] | +0.001 [+0.027,+0.256] |
| V2_fair_ruler | +0.000 [+0.003,+0.008] | +0.000 [-0.078,+0.000] | +0.000 [+0.000,+0.000] |
| V2_fair_ruler | +0.000 [+0.003,+0.008] | +0.000 [-0.078,+0.000] | +0.000 [+0.000,+0.000] |

## Per-design detail

| design | n | truth-best candidate | rho(V1_legal_hpwl,egr_union) | rho(V1u,legal_hpwl) |
|---|---|---|---|
| PPU_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.988 | -0.918 |
| aes | 29 | candidate=td055_ce0_s1000 cached=1 | 0.986 | -0.918 |
| aes_core_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.996 | -0.936 |
| aes_sky130_a | 29 | candidate=td055_ce0_s1000 cached=1 | 0.954 | -0.164 |
| apb4_clint_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.986 | -0.691 |
| apb4_i2c_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.871 | -0.933 |
| apb4_ps2_sky130_b | 29 | candidate=td055_ce3_s1000 cached=1 | 0.504 | -0.444 |
| apb4_timer | 29 | candidate=td080_ce3_s1002 cached=1 | 0.954 | -0.939 |
| apb4_timer_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.899 | -0.735 |
| apb4_uart_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.997 | -0.952 |
| gcd_ics55_a | 29 | candidate=td080_ce7_s1000 cached=1 | 0.682 | -0.678 |
| gcd_nangate45_a | 29 | candidate=td065_ce0_s1000 cached=1 | 0.012 | -0.631 |
| gcd_sky130_a | 29 | candidate=td065_ce7_s1000 cached=1 | -0.261 | 0.634 |
| picorv32 | 29 | candidate=td055_ce0_s1000 cached=1 | 0.98 | -0.58 |
| picorv32_sky130_a | 29 | candidate=td055_ce0_s1000 cached=1 | 0.996 | -0.944 |
| s1238 | 29 | candidate=td060_ce7_s1000 cached=1 | 0.901 | -0.852 |
| s1238_ics55_a | 29 | candidate=td055_ce0_s1000 cached=1 | 0.929 | -0.958 |
| s1238_nangate45_a | 29 | candidate=td055_ce0_s1000 cached=1 | 0.835 | -0.945 |
| s1238_sky130_a | 29 | candidate=td080_ce7_s1000 cached=1 | -0.213 | 0.394 |
| s13207_sky130_b | 29 | candidate=td060_ce3_s1000 cached=1 | 0.993 | -0.918 |
| s1488_sky130_b | 29 | candidate=td060_ce7_s1000 cached=1 | 0.79 | -0.723 |
| s15850_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.983 | -0.958 |
| s35932_sky130_b | 29 | candidate=td055_ce7_s1000 cached=1 | 0.966 | -0.643 |
| s38417_sky130_b | 29 | candidate=td055_ce3_s1000 cached=1 | 0.999 | -0.993 |
| s38584_ics55_a | 29 | candidate=td055_ce0_s1000 cached=1 | 0.993 | -0.857 |
| s38584_nangate45_a | 29 | candidate=td055_ce7_s1000 cached=1 | 0.973 | -0.906 |
| s38584_sky130_a | 29 | candidate=td055_ce0_s1000 cached=1 | 0.987 | -0.901 |
| s5378_sky130_b | 29 | candidate=td055_ce3_s1000 cached=1 | 0.956 | -0.965 |
| s9234_sky130_b | 29 | candidate=td055_ce0_s1000 cached=1 | 0.991 | -0.949 |
| salsa20_ics55_a | 29 | candidate=td080_ce7_s1000 | 0.999 | -0.882 |
| salsa20_nangate45_a | 29 | candidate=td080_ce7_s1000 cached=1 | 0.979 | -0.785 |
| salsa20_sky130_a | 28 | candidate=td080_ce7_s1000 | 0.946 | -0.66 |
