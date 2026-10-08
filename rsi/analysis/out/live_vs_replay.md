# Live loop versus replay

Matched scope: seed 1000, 16 rounds. Live trajectories: 128 over 32 designs;
replay trajectories on the same designs: 160.

| rung | n live | n replay | live dQ_T | replay dQ_T | live r* | replay r* | live VG | replay VG | live worse | replay worse |
|---|---|---|---|---|---|---|---|---|---|---|
| V0_internal_hpwl | 32 | 32 | -0.6986 | -0.4911 | 0 | 0 | +1.4552 | +1.2768 | 97% | 100% |
| V0b_route_util | 0 | 32 | +nan | +0.0893 | -1 | 3 | +nan | +0.0000 | nan% | 22% |
| V1u_unlegal_hpwl | 32 | 32 | -0.6436 | -0.5000 | 0 | 0 | +1.4468 | +1.2589 | 100% | 88% |
| V1_legal_hpwl | 32 | 32 | +0.1746 | +0.1429 | 4 | 2 | +0.0000 | +0.0179 | 16% | 9% |
| V2_ruler | 32 | 32 | +0.1592 | +0.1071 | 4 | 2 | +0.0000 | +0.0000 | 16% | 9% |

Rungs both runs executed: V0_internal_hpwl, V1u_unlegal_hpwl, V1_legal_hpwl, V2_ruler

Ordering by true gain, live: V1_legal_hpwl, V2_ruler, V1u_unlegal_hpwl, V0_internal_hpwl

Ordering by true gain, replay: V1_legal_hpwl, V2_ruler, V0_internal_hpwl, V1u_unlegal_hpwl

Agreement of the two-group partition (cheap rungs vs faithful rungs): identical

Spread inside the cheap group: live 0.055, replay 0.009

The cheap group contains two rungs that are both strongly negative, and their
relative order is not stable between the two implementations; the partition, the
signs, the magnitudes and the horizon are stable.

Reading: the replay is primary. This comparison exists to show whether the
conclusions depend on the pool rather than on the loop. A live run is charged a
real placement per round, so its pool is smaller and its ranks coarser.
