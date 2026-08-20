# iEDA GP Agent 最新结果（同 evaluator，精确数字）

本文件记录当前最新一批验证数据。所有指标由同一 evaluator 计算：

```text
HPWL       def_hpwl_eval.py
density    iEDA run_density_eval
RUDY       iEDA run_congestion_eval（RUDY demand density）
timing     iEDA eval_timing_metrics.tcl（sky130 / nangate45 / asap7 / ihp130 均已接通）
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

## 2. cross-PDK：raw / 最优 agent 全维度

timing evaluator 已支持 nangate45 / asap7 / ihp130。

### nangate45_gcd

| 指标 | raw | 最优 agent | delta |
|---|---|---|---|
| HPWL | 5,850,034 | 5,813,974 | -0.616% |
| peak density | 0.839014 | 0.839014 | 0 |
| RUDY max | 0.015860 | 0.016195 | +2.11% |
| RUDY total | 4.843156 | 4.834003 | -0.189% |
| setup WNS (ns) | -1.186381 | -1.199110 | 变差 0.0127 ns |
| setup TNS (ns) | -74.507272 | -75.191470 | 变差 0.684 ns |
| hold WNS (ns) | +0.346368 | +0.345874 | 基本持平 |
| freq (MHz) | 598.31 | 593.79 | -0.756% |

### asap7_aes

| 指标 | raw | 最优 agent | delta |
|---|---|---|---|
| HPWL | 58,392,975 | 57,887,305 | -0.866% |
| peak density | 0.468640 | 0.462444 | -1.322% |
| RUDY max | 0.081418 | 0.080320 | -1.349% |
| RUDY total | 6.929867 | 6.906416 | -0.338% |
| setup WNS (ns) | -2146.161 | -2145.492 | 变好 0.669 ns |
| hold WNS (ns) | -2144.575 | -2145.353 | 变差 0.778 ns |
| freq (MHz) | 0.465772 | 0.465918 | +0.031% |

### ihp130_gcd

| 指标 | raw | 最优 agent | delta |
|---|---|---|---|
| HPWL | 620,662,411 | 617,771,700 | -0.466% |
| peak density | 0.560176 | 0.560176 | 0 |
| RUDY max | 0.005540 | 0.005412 | -2.31% |
| RUDY total | 8.388075 | 8.348585 | -0.471% |
| setup WNS (ns) | +0.465344 | +0.457550 | 变差 0.0078 ns |
| hold WNS (ns) | +0.296344 | +0.296344 | 持平 |
| freq (MHz) | 220.52 | 220.15 | -0.171% |

## 3. cross-PDK Innovus

Innovus license：

```text
/home/yangkang/cadence/INNOVUS201/license/cadence.dat
```

三个设计均已跑出 placement DEF。

| design | raw HPWL | agent HPWL | Innovus HPWL |
|---|---|---|---|
| nangate45_gcd | 5,850,034 | 5,813,974 | 4,657,813 |
| asap7_aes | 58,392,975 | 57,887,305 | 58,353,906 |
| ihp130_gcd | 620,662,411 | 617,771,700 | 682,459,304 |

Innovus 的 DEF HPWL 来自 overlay 方法（Innovus defOut 不含 NETS 段）。

## 4. 当前还无法验证的部分

```text
1. Innovus cross-PDK 的 density / RUDY / timing：
   Innovus defOut 没有写 NETS，并省略部分 physical-only cell，
   overlay DEF 目前只能可靠计算 HPWL。

2. asap7_aes timing 的 WNS 绝对值非常大（约 -2145 ns）：
   需要确认 SDC 的 clock 约束和 lib corner 是否与设计预期一致。

3. accept 导出 DEF bug、config fingerprint mismatch：
   已在 GPA_PLAN_EVIDENCE.md 记录，尚未修复。
```

## 5. 当前结论

```text
1. HPWL：
   agent 在 6/7 设计好于 raw；
   sky130 上 agent 全部好于 Innovus；
   nangate45 上 Innovus 好于 iEDA raw 和 agent；
   asap7 上三者接近；
   ihp130 上 iEDA raw/agent 好于 Innovus。

2. timing：
   s1238 / aes 上 agent 好于 raw 和 Innovus；
   apb4 / nangate / ihp130 基本持平；
   asap7 的 timing 约束本身需要再核对。

3. RUDY max：
   sky130 上 Innovus 最好；
   cross-PDK 上 agent 在 asap7 / ihp130 变好，nangate 略差。

4. peak density：
   多数设计 agent 与 raw 持平；
   aes agent 变差 20%，但仍为 0.59。
```
