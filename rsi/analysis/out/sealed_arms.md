# Arms by split, including the sealed designs

Seeds per cell: 5. Rounds: 16. True gain is measured on the fair ruler by
rank inside each design's candidate pool; cost is the measured per-stage sum.

| split | arm | n | median true gain | median cost (s) | gain per s |
|---|---|---|---|---|---|
| dev | A0 (start state, no write-back) | 65 | +0.0000 | 0 | n/a |
| dev | A1 (fixed rung, unlegalized wirelength) | 65 | -0.5000 | 207 | -2.41e-03 |
| dev | A1 (fixed rung, legalized wirelength) | 65 | +0.1786 | 245 | 7.28e-04 |
| dev | A2 (fair ruler, Pareto) | 65 | +0.1250 | 271 | 4.61e-04 |
| val | A0 (start state, no write-back) | 25 | +0.0000 | 0 | n/a |
| val | A1 (fixed rung, unlegalized wirelength) | 25 | -0.4444 | 369 | -1.21e-03 |
| val | A1 (fixed rung, legalized wirelength) | 25 | +0.1429 | 495 | 2.88e-04 |
| val | A2 (fair ruler, Pareto) | 25 | +0.2143 | 739 | 2.90e-04 |
| sealed | A0 (start state, no write-back) | 30 | +0.0000 | 0 | n/a |
| sealed | A1 (fixed rung, unlegalized wirelength) | 30 | -0.5357 | 128 | -4.18e-03 |
| sealed | A1 (fixed rung, legalized wirelength) | 30 | +0.1250 | 147 | 8.48e-04 |
| sealed | A2 (fair ruler, Pareto) | 30 | +0.1250 | 230 | 5.43e-04 |
| ood | A0 (start state, no write-back) | 40 | +0.0000 | 0 | n/a |
| ood | A1 (fixed rung, unlegalized wirelength) | 40 | -0.3750 | 86 | -4.34e-03 |
| ood | A1 (fixed rung, legalized wirelength) | 40 | +0.1964 | 75 | 2.62e-03 |
| ood | A2 (fair ruler, Pareto) | 40 | +0.2500 | 170 | 1.47e-03 |
