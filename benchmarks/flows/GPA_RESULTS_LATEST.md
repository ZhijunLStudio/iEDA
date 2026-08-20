# iEDA GP Agent 最新结果（同 evaluator，精确数字）

本文件记录当前最新一批验证数据。所有指标由同一 evaluator 计算：

```text
HPWL       def_hpwl_eval.py
density    iEDA run_density_eval
RUDY       iEDA run_congestion_eval（RUDY demand density）
timing     iEDA eval_timing_metrics.tcl（仅 sky130）
```

## 1. sky130：raw / 最优 agent / Innovus

### s1238

| 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|
| HPWL | 5,957,257 | 5,939,909 | -0.291% | 8,053,041 | -26.24% |
| peak density | 0.458522 | 0.458522 | 0 | 0.457168 | +0.30% |
| RUDY max | 0.004824 | 0.004640 | -3.81% | 0.003627 | +27.93% |
| RUDY total | 3.778444 | 3.778684 | +0.006% | 5.257225 | -28.12% |
| setup WNS (ns) | -0.04922 | -0.03062 | +0.0186 | -0.13295 | +0.1023 |
| freq (MHz) | 645.49 | 653.33 | +1.22% | 612.39 | +6.69% |

### apb4_timer

| 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|
| HPWL | 15,715,072 | 15,591,351 | -0.787% | 18,566,747 | -16.02% |
| peak density | 0.366530 | 0.366530 | 0 | 0.366077 | +0.124% |
| RUDY max | 0.003046 | 0.003190 | +4.73% | 0.002559 | +24.66% |
| RUDY total | 2.337015 | 2.328226 | -0.376% | 2.918314 | -20.22% |
| setup WNS (ns) | -0.56163 | -0.56474 | -0.0031 | -0.67645 | +0.1117 |
| freq (MHz) | 485.05 | 484.32 | -0.151% | 459.46 | +5.41% |

### picorv32

当前没有找到比 raw 更好的 feasible agent 结果，所以 agent = raw。

| 指标 | raw = agent | Innovus | agent vs Innovus |
|---|---|---|---|
| HPWL | 234,280,119 | 308,691,343 | -24.10% |
| peak density | 0.340668 | 0.340663 | +0.0015% |
| RUDY max | 0.003854 | 0.003650 | +5.59% |
| RUDY total | 3.399836 | 4.552387 | -25.32% |
| setup WNS (ns) | -15.9233 | -21.3663 | +5.443 |
| freq (MHz) | 54.28 | 41.90 | +29.55% |

### aes

| 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|
| HPWL | 665,002,127 | 573,846,319 | -13.71% | 914,210,691 | -37.23% |
| peak density | 0.491452 | 0.589755 | +20.00% | 0.410401 | +43.70% |
| RUDY max | 0.004218 | 0.005085 | +20.56% | 0.003348 | +51.88% |
| RUDY total | 3.733800 | 3.210842 | -14.01% | 5.379015 | -40.31% |
| setup WNS (ns) | -75.812 | -51.449 | +24.36 | -94.454 | +43.00 |
| freq (MHz) | 12.77 | 18.54 | +45.16% | 10.31 | +79.74% |

## 2. cross-PDK：raw / 最优 agent

没有 Innovus placement DEF，没有 timing evaluator。

| 设计 | 指标 | raw | 最优 agent | delta |
|---|---|---|---|---|
| nangate45_gcd | HPWL | 5,850,034 | 5,813,974 | -0.616% |
| nangate45_gcd | peak density | 0.839014 | 0.839014 | 0 |
| nangate45_gcd | RUDY max | 0.015860 | 0.016195 | +2.11% |
| nangate45_gcd | RUDY total | 4.843156 | 4.834003 | -0.189% |
| asap7_aes | HPWL | 58,392,975 | 57,887,305 | -0.866% |
| asap7_aes | peak density | 0.468640 | 0.462444 | -1.322% |
| asap7_aes | RUDY max | 0.081418 | 0.080320 | -1.349% |
| asap7_aes | RUDY total | 6.929867 | 6.906416 | -0.338% |
| ihp130_gcd | HPWL | 620,662,411 | 617,771,700 | -0.466% |
| ihp130_gcd | peak density | 0.560176 | 0.560176 | 0 |
| ihp130_gcd | RUDY max | 0.005540 | 0.005412 | -2.31% |
| ihp130_gcd | RUDY total | 8.388075 | 8.348585 | -0.471% |

## 3. 结论

```text
1. HPWL：agent 在 6/7 设计好于 raw；
   在 4 个 sky130 设计上全部远好于 Innovus。

2. timing：agent 在 s1238 / aes 上明显好于 raw 和 Innovus；
   apb4 基本持平。

3. RUDY max：agent 相对 raw 有小幅波动；
   sky130 上 Innovus 的 RUDY max 仍然最好。

4. peak density：多数设计 agent 与 raw 持平；
   aes agent 变差 20%，但仍为 0.59。

5. 最明显 tradeoff 是 aes：
   HPWL / timing 大幅改善，
   RUDY max / peak density 变差。

6. 尚未解决：
   - picorv32 找不到 feasible 改善；
   - cross-PDK 缺 Innovus DEF 和 timing evaluator；
   - accept 导出 DEF bug、config fingerprint mismatch。
```


## 4. cross-PDK timing（同一 timing evaluator，本次补齐）

### nangate45_gcd

| 版本 | HPWL | setup WNS | setup TNS | hold WNS | freq |
|---|---|---|---|---|---|
| raw | 5,850,034 | -1.186 ns | -74.507 ns | +0.346 ns | 598.31 MHz |
| agent | 5,813,974 | -1.199 ns | -75.191 ns | +0.346 ns | 593.79 MHz |

### asap7_aes

| 版本 | HPWL | setup WNS | hold WNS | freq |
|---|---|---|---|---|
| raw | 58,392,975 | -2146.16 ns | -2144.58 ns | 0.466 MHz |
| agent | 57,887,305 | -2145.49 ns | -2145.35 ns | 0.466 MHz |

### ihp130_gcd

| 版本 | HPWL | setup WNS | hold WNS | freq |
|---|---|---|---|---|
| raw | 620,662,411 | +0.465 ns | +0.296 ns | 220.52 MHz |
| agent | 617,771,700 | +0.458 ns | +0.296 ns | 220.15 MHz |

## 5. cross-PDK Innovus（本机 license 已找到并跑完）

Innovus license 来自 `/home/yangkang/cadence/INNOVUS201/license/cadence.dat`。

| design | raw HPWL | agent HPWL | Innovus HPWL | 说明 |
|---|---|---|---|---|
| nangate45_gcd | 5,850,034 | 5,813,974 | 4,657,813 | Innovus DEF 无 NETS，用 input DEF 网表 overlay |
| asap7_aes | 58,392,975 | 57,887,305 | 58,353,906 | 同上 |
| ihp130_gcd | 620,662,411 | 617,771,700 | 682,459,304 | 同上 |

注意：Innovus defOut 没有写 NETS，且会省略部分 physical-only cell，
所以 Innovus 的 density/RUDY/timing 仍不能直接用 overlay DEF 跑；
上表 Innovus 只有 HPWL，是当前可验证范围。
