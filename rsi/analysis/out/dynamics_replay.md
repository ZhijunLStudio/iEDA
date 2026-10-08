# Dynamics by replay over the frozen candidate pool

pool: 32 designs, 800 trajectories (rounds up to 16, 5 seeds)

| rung | n | cost (s) | dQ_T(final) | worse | VG(final) | r* | interior r* | NSI | accepted | of which harmful | AR (confirmed share) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| V0_internal_hpwl | 160 | 162 | -0.4821 | 93% | +1.2183 | 0 | 34% | -2.18e-03 | 5.0 | 3.0 | 0.33 |
| V0b_route_util | 160 | 154 | +0.0714 | 28% | +0.0179 | 3 | 68% | 2.13e-04 | 3.0 | 1.0 | 0.60 |
| V1u_unlegal_hpwl | 160 | 172 | -0.5000 | 90% | +1.2321 | 0 | 39% | -1.93e-03 | 5.0 | 4.0 | 0.33 |
| V1_legal_hpwl | 160 | 188 | +0.1607 | 10% | +0.0179 | 4 | 85% | 6.37e-04 | 3.0 | 1.0 | 0.67 |
| V2_ruler | 160 | 269 | +0.1429 | 10% | +0.0000 | 3 | 83% | 4.36e-04 | 3.0 | 1.0 | 0.69 |
