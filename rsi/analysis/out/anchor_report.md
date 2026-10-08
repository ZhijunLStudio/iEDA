# External anchoring against the commercial reference

Evaluator: the same independent HPWL evaluator and trial-route congestion
model applied to the reference DEF and to our picks. Designs with a usable
reference: 32.

## Relative to the reference (ratio, lower is better)

| pick | HPWL / ref | congestion / ref |
|---|---|---|
| ruler-optimal (truth-best) | 0.935 | 1.228 |
| V0 attractor (cheap rung) | 1.089 | 2.902 |

## Paired comparison of the two pick policies

- ruler-optimal HPWL lower than the V0 attractor on 31 / 32 designs
- ruler-optimal congestion lower than the V0 attractor on 31 / 32 designs
- ruler-optimal HPWL below the reference on 20 / 32 designs

## Caveat

The reference was produced by a different tool with its own settings and
objectives, so the absolute ratio is an external anchor, not a like-for-like
signoff contest. The load-bearing statement is the paired one: on the same
external yardstick, the pick made by the cheap verifier is worse than the pick
made by the ruler, on almost every design.

## Per design

| design | pdk | ref HPWL | ruler HPWL | V0 HPWL | ref EGR | ruler EGR | V0 EGR |
|---|---|---|---|---|---|---|---|
| PPU_sky130_b | sky130 | 209530861 | 323774908 | 406113827 | 84575 | 280583 | 395783 |
| aes | sky130 | 914210691 | 844141843 | 1103706447 | 481659 | 671251 | 1153905 |
| aes_core_sky130_b | sky130 | 981774139 | 1208031366 | 1576448601 | 446235 | 920431 | 1556859 |
| aes_sky130_a | sky130 | 582987493 | 411596214 | 435847082 | 362472 | 254723 | 326997 |
| apb4_clint_sky130_b | sky130 | 27786965 | 26251330 | 31480171 | 2980 | 4746 | 13059 |
| apb4_i2c_sky130_b | sky130 | 18454376 | 16195666 | 18186937 | 3148 | 3062 | 7046 |
| apb4_ps2_sky130_b | sky130 | 11469443 | 10207623 | 11305930 | 1948 | 1471 | 4311 |
| apb4_timer | sky130 | 18566747 | 16216767 | 18913074 | 5626 | 3266 | 6749 |
| apb4_timer_sky130_b | sky130 | 23178076 | 21651200 | 23821367 | 3582 | 2753 | 6543 |
| apb4_uart_sky130_b | sky130 | 138455405 | 164595333 | 217032999 | 48449 | 122057 | 194368 |
| gcd_ics55_a | ics55 | 4333398 | 4095537 | 4159655 | 40 | 31 | 218 |
| gcd_nangate45_a | nangate45 | 7751413 | 6991541 | 7217236 | 0 | 0 | 0 |
| gcd_sky130_a | sky130 | 7250388 | 6789439 | 6824186 | 2004 | 700 | 1342 |
| picorv32 | sky130 | 308691343 | 268328741 | 431719851 | 167614 | 173405 | 445986 |
| picorv32_sky130_a | sky130 | 317149243 | 365541628 | 454330589 | 123976 | 239294 | 388836 |
| s1238 | sky130 | 8053041 | 5585815 | 7695846 | 3693 | 1882 | 4916 |
| s1238_ics55_a | ics55 | 4051577 | 3146281 | 3529133 | 177 | 146 | 639 |
| s1238_nangate45_a | nangate45 | 7845521 | 5756810 | 6416560 | 0 | 1 | 81 |
| s1238_sky130_a | sky130 | 6709138 | 6242668 | 6203487 | 2500 | 1852 | 2441 |
| s13207_sky130_b | sky130 | 84117014 | 79357438 | 88807419 | 15655 | 14003 | 30883 |
| s1488_sky130_b | sky130 | 12585977 | 8547055 | 9167077 | 4260 | 4410 | 5511 |
| s15850_sky130_b | sky130 | 94956767 | 88618740 | 105419148 | 16678 | 17734 | 44499 |
| s35932_sky130_b | sky130 | 194253790 | 255634510 | 290632559 | 41286 | 88938 | 146245 |
| s38417_sky130_b | sky130 | 194367427 | 218055815 | 296741811 | 41889 | 91198 | 202488 |
| s38584_ics55_a | ics55 | 80240724 | 86606591 | 109391775 | 3407 | 15655 | 58113 |
| s38584_nangate45_a | nangate45 | 144607962 | 169462688 | 232368924 | 6 | 3753 | 27431 |
| s38584_sky130_a | sky130 | 219933384 | 258754513 | 309374820 | 120158 | 168044 | 262135 |
| s5378_sky130_b | sky130 | 29407529 | 25698982 | 29305308 | 5553 | 5383 | 12491 |
| s9234_sky130_b | sky130 | 36946655 | 32467159 | 39468880 | 5998 | 8348 | 18973 |
| salsa20_ics55_a | ics55 | 296610508 | 305083815 | 432437262 | 54296 | 123910 | 476794 |
| salsa20_nangate45_a | nangate45 | 534430356 | 563450782 | 868218450 | 250 | 39644 | 299765 |
| salsa20_sky130_a | sky130 | 619858873 | 940716593 | 1195813399 | 361409 | 806442 | 1284280 |
