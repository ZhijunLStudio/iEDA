# Transfer of an evaluation-budget preference across technologies

Budget per run: 140 s. Seed count: 3. Designs per technology are listed
at the end.

## Median final truth rank by technology (higher is better)

| policy | ics55 | nangate45 | sky130 |
|---|---|---|---|
| climb V0 (internal wirelength) | 0.071 | 0.107 | 0.125 |
| climb V0b (route utilization) | 0.777 | 0.746 | 0.714 |
| climb V1u (unlegalized wirelength) | 0.125 | 0.116 | 0.098 |
| climb V1 (legalized wirelength) | 0.777 | 0.826 | 0.795 |
| climb V2 (fair ruler, Pareto) | 0.759 | 0.866 | 0.804 |
| screen V0 then confirm V2 | 0.379 | 0.513 | 0.661 |
| screen V1u then confirm V2 | 0.509 | 0.491 | 0.634 |
| screen V1 then confirm V2 | 0.893 | 0.799 | 0.902 |

## Transfer metrics relative to the source technology

| target | source-best policy | source-best rank on target | target-best policy | target-best rank | TR_ratio | TR_rank (Spearman of policy orderings) |
|---|---|---|---|---|---|---|
| ics55 | screen V1 then confirm V2 | 0.893 | screen V1 then confirm V2 | 0.893 | 1.000 | 0.874 |
| nangate45 | screen V1 then confirm V2 | 0.799 | climb V2 (fair ruler, Pareto) | 0.866 | 0.923 | 0.905 |

## Designs per technology

- ics55 (4): gcd_ics55_a, s1238_ics55_a, s38584_ics55_a, salsa20_ics55_a
- nangate45 (4): gcd_nangate45_a, s1238_nangate45_a, s38584_nangate45_a, salsa20_nangate45_a
- sky130 (24): PPU_sky130_b, aes, aes_core_sky130_b, aes_sky130_a, apb4_clint_sky130_b, apb4_i2c_sky130_b, apb4_ps2_sky130_b, apb4_timer, apb4_timer_sky130_b, apb4_uart_sky130_b, gcd_sky130_a, picorv32, picorv32_sky130_a, s1238, s1238_sky130_a, s13207_sky130_b, s1488_sky130_b, s15850_sky130_b, s35932_sky130_b, s38417_sky130_b, s38584_sky130_a, s5378_sky130_b, s9234_sky130_b, salsa20_sky130_a
