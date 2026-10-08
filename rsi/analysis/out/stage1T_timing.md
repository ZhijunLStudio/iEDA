# Stage 1T - is the fair ruler itself a proxy?

joined candidates: 695 over 24 designs

## Spearman rho of each signal against timing (median over designs)

| signal | vs setup TNS | vs setup WNS | vs hold WNS |
|---|---|---|---|
| V0 | +0.219 [+0.025,+0.426] | +0.112 [+0.010,+0.340] | -0.043 [-0.259,+0.083] |
| V0b | -0.213 [-0.363,+0.062] | -0.132 [-0.287,+0.054] | -0.066 [-0.147,+0.170] |
| V1u | +0.216 [+0.024,+0.425] | +0.122 [+0.011,+0.340] | -0.065 [-0.263,+0.079] |
| V1 | -0.471 [-0.574,-0.202] | -0.261 [-0.393,-0.069] | -0.002 [-0.125,+0.217] |
| fair_ruler | -0.247 [-0.502,-0.092] | -0.227 [-0.361,-0.008] | +0.025 [-0.121,+0.235] |

## Selection disagreement

- designs where the geometry-best candidate is also the timing-best: 7 / 24
- picking on geometry, timing TNS loss relative to the timing-best: median -0.067 (n=18)
- picking on timing, legalized HPWL penalty relative to the geometry-best: median +1.96% (n=24)

## Per design

| design | n | geometry-best | timing-best | same |
|---|---|---|---|---|
| PPU_sky130_b | 29 | td055_ce0_s1000 | td055_ce0_s1000 | yes |
| aes | 29 | td055_ce0_s1000 | td075_ce7_s1000 | no |
| aes_core_sky130_b | 29 | td055_ce0_s1000 | td075_ce0_s1000 | no |
| aes_sky130_a | 29 | td055_ce0_s1000 | td075_ce0_s1000 | no |
| apb4_clint_sky130_b | 29 | td055_ce0_s1000 | td055_ce0_s1000 | yes |
| apb4_i2c_sky130_b | 29 | td055_ce0_s1000 | td055_ce0_s1000 | yes |
| apb4_ps2_sky130_b | 29 | td055_ce3_s1000 | td055_ce0_s1000 | no |
| apb4_timer | 29 | td080_ce3_s1002 | td080_ce3_s1002 | yes |
| apb4_timer_sky130_b | 29 | td055_ce0_s1000 | td055_ce0_s1000 | yes |
| apb4_uart_sky130_b | 29 | td055_ce0_s1000 | td055_ce0_s1000 | yes |
| gcd_sky130_a | 29 | td065_ce7_s1000 | td085_ce3_s1000 | no |
| picorv32 | 29 | td055_ce0_s1000 | td070_ce0_s1000 | no |
| picorv32_sky130_a | 29 | td055_ce0_s1000 | td055_ce3_s1000 | no |
| s1238 | 29 | td060_ce7_s1000 | td060_ce0_s1000 | no |
| s1238_sky130_a | 29 | td080_ce7_s1000 | td085_ce0_s1000 | no |
| s13207_sky130_b | 29 | td060_ce3_s1000 | td070_ce7_s1000 | no |
| s1488_sky130_b | 29 | td060_ce7_s1000 | td090_ce7_s1000 | no |
| s15850_sky130_b | 29 | td055_ce0_s1000 | td060_ce0_s1000 | no |
| s35932_sky130_b | 29 | td055_ce7_s1000 | td060_ce0_s1000 | no |
| s38417_sky130_b | 29 | td055_ce3_s1000 | td065_ce7_s1000 | no |
| s38584_sky130_a | 29 | td055_ce0_s1000 | td080_ce3_s1001 | no |
| s5378_sky130_b | 29 | td055_ce3_s1000 | td075_ce0_s1000 | no |
| s9234_sky130_b | 29 | td055_ce0_s1000 | td055_ce0_s1000 | yes |
| salsa20_sky130_a | 28 | td080_ce7_s1000 | td080_ce3_s1000 | no |
