# Evaluation-budget policies on the frozen pool

pool: 32 designs, 5 seeds per cell, charged at measured per-stage cost.


## Unbudgeted runs (natural stopping point)

| policy | median cost (s) | median final truth rank | 25th | 75th |
|---|---|---|---|---|
| climb V0 (internal wirelength) | 105 | 0.1071 | 0.0357 | 0.1607 |
| climb V0b (route utilization) | 100 | 0.7679 | 0.6250 | 0.8750 |
| climb V1u (unlegalized wirelength) | 96 | 0.0893 | 0.0357 | 0.1607 |
| climb V1 (legalized wirelength) | 136 | 0.8571 | 0.7634 | 0.9464 |
| climb V2 (fair ruler, Pareto) | 163 | 0.8393 | 0.6786 | 0.9286 |
| screen V0 then confirm V2 | 168 | 0.5982 | 0.3884 | 0.7366 |
| screen V1u then confirm V2 | 188 | 0.6071 | 0.3929 | 0.7321 |
| screen V1 then confirm V2 | 239 | 0.9286 | 0.8036 | 0.9643 |
