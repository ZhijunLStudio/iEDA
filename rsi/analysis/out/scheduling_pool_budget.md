# Evaluation-budget policies on the frozen pool

pool: 32 designs, 5 seeds per cell, charged at measured per-stage cost.

## Equal-budget comparison (final truth rank; higher is better)

| policy | 100s | 140s | 200s | 280s |
|---|---|---|---|---|
| climb V0 (internal wirelength) | 0.143 | 0.125 | 0.107 | 0.109 |
| climb V0b (route utilization) | 0.732 | 0.741 | 0.759 | 0.768 |
| climb V1u (unlegalized wirelength) | 0.143 | 0.125 | 0.125 | 0.109 |
| climb V1 (legalized wirelength) | 0.804 | 0.804 | 0.839 | 0.839 |
| climb V2 (fair ruler, Pareto) | 0.737 | 0.804 | 0.804 | 0.804 |
| screen V0 then confirm V2 | 0.598 | 0.607 | 0.607 | 0.598 |
| screen V1u then confirm V2 | 0.607 | 0.625 | 0.625 | 0.616 |
| screen V1 then confirm V2 | 0.893 | 0.893 | 0.911 | 0.920 |

## Unbudgeted runs (natural stopping point)

| policy | median cost (s) | median final truth rank | 25th | 75th |
|---|---|---|---|---|
