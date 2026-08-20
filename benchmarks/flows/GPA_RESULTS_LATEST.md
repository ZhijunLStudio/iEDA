# iEDA GP Agent 最新结果（同 evaluator，精确数字）

本文件记录当前最新一批验证数据。所有指标由同一 evaluator 计算：

```text
HPWL       def_hpwl_eval.py
density    iEDA run_density_eval
RUDY       iEDA run_congestion_eval（RUDY demand density）
timing     iEDA eval_timing_metrics.tcl（sky130 / nangate45 / asap7 / ihp130 均已接通）

Innovus 对比用 Cadence Innovus 20.10 在本机生成 placement DEF，再回到同一个 iEDA evaluator 计算。
```

## 1. sky130：raw / 最优 agent / Innovus（四维）

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

## 2. cross-PDK：raw / 最优 agent / Innovus 全维度

timing evaluator 已支持 nangate45 / asap7 / ihp130。
Innovus DEF 已用 `defOut -netlist -unplaced` 重新导出，因此 density / RUDY / timing 全部可比较。

### nangate45_gcd

| 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|
| HPWL | 5,850,034 | 5,813,974 | -0.616% | 3,850,158 | +51.00% |
| peak density | 0.839014 | 0.839014 | 0 | 0.478196 | +75.45% |
| RUDY max | 0.015860 | 0.016195 | +2.11% | 0.004041 | +300.8% |
| RUDY total | 4.843156 | 4.834003 | -0.189% | 3.540346 | +36.54% |
| setup WNS (ns) | -1.186381 | -1.199110 | 变差 0.0127 | -2.138775 | 变好 0.9397 |
| setup TNS (ns) | -74.507272 | -75.191470 | 变差 0.684 | -87.146053 | 变好 11.955 |
| hold WNS (ns) | +0.346368 | +0.345874 | 基本持平 | +0.344879 | 基本持平 |
| freq (MHz) | 598.31 | 593.79 | -0.756% | 381.13 | +55.80% |

### asap7_aes

| 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|
| HPWL | 58,392,975 | 57,887,305 | -0.866% | 45,224,840 | +28.00% |
| peak density | 0.468640 | 0.462444 | -1.322% | 0.236370 | +95.65% |
| RUDY max | 0.081418 | 0.080320 | -1.349% | 0.033026 | +143.2% |
| RUDY total | 6.929867 | 6.906416 | -0.338% | 12.555375 | -45.00% |
| setup WNS (ns) | invalid* | invalid* | - | invalid* | - |
| hold WNS (ns) | invalid* | invalid* | - | invalid* | - |
| freq (MHz) | invalid* | invalid* | - | invalid* | - |

### ihp130_gcd

| 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|
| HPWL | 620,662,411 | 617,771,700 | -0.466% | 502,815,015 | +22.86% |
| peak density | 0.560176 | 0.560176 | 0 | 0.520480 | +7.63% |
| RUDY max | 0.005540 | 0.005412 | -2.31% | 0.004101 | +31.96% |
| RUDY total | 8.388075 | 8.348585 | -0.471% | 6.762420 | +23.46% |
| setup WNS (ns) | +0.465344 | +0.457550 | 变差 0.0078 | -10.701524 | 变好 11.159 |
| hold WNS (ns) | +0.296344 | +0.296344 | 持平 | +0.296453 | 基本持平 |
| freq (MHz) | 220.52 | 220.15 | -0.171% | 63.69 | +245.7% |

## 3. 已不再存在的限制

```text
之前 Innovus DEF 没有 NETS / 缺少 cell 的问题已解决：
defOut -netlist -unplaced
现在 nangate45 / asap7 / ihp130 的 Innovus DEF 都是完整可评测的。
```

## 5. 当前结论

```text
1. HPWL：
   agent 在 6/7 设计好于 raw；
   sky130 上 agent 全部好于 Innovus；
   cross-PDK 上 Innovus 的 HPWL 都低于 iEDA raw/agent。

2. density：
   sky130 上接近；
   cross-PDK 上 Innovus peak density 明显更低（更松）。

3. RUDY max：
   sky130 和 cross-PDK 上 Innovus 都比 iEDA 低（更不拥塞）。

4. RUDY total：
   设计相关：
   - nangate45 / ihp130 上 Innovus 更低；
   - asap7 上 iEDA 更低；
   - sky130 上 mixed。

5. timing：
   - s1238 / aes / picorv32 / apb4 上 iEDA 更好；
   - nangate45 上 iEDA 更好；
   - ihp130 上 iEDA 是正 slack，Innovus 是负 slack；
   - asap7 三者都很差，需要核对 SDC / corner。

6. aes 上 agent 的大幅 HPWL / timing 改善
   以 peak density +20% 和 RUDY max +20.6% 为代价。
```
