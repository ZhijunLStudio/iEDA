# Verification-aware scheduling (offline replay on the cached pool)

pool: 18 design-seeds, 8 policies

| policy | median cost | median final truth score | 25th pct | 75th pct |
|---|---|---|---|---|
| greedy V0 | 1535 | 0.1348 | 0.0000 | 0.2500 |
| greedy V1u | 1535 | 0.1348 | 0.0000 | 0.2500 |
| greedy V1 | 1949 | 0.9728 | 0.9167 | 1.0000 |
| greedy V2 | 2649 | 0.9728 | 0.9333 | 1.0000 |
| screen V0->V2 k8 m2 | 2174 | 0.5750 | 0.4261 | 0.7548 |
| screen V1u->V2 k8 m2 | 2186 | 0.5627 | 0.4240 | 0.7550 |
| screen V1->V2 k6 m2 | 2910 | 0.9706 | 0.9333 | 1.0000 |
| screen V1->V2 k10 m3 | 2945 | 0.9728 | 0.9333 | 1.0000 |
