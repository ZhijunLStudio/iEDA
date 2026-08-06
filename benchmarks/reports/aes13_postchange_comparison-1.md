# AES13 修改后指标统计与旧基线对比 · v2

生成日期：2026-07-25
旧基线：`benchmarks/reports/aes11_detailed_comparison-0.md` 及其机器可读 JSON
新结果：

- `benchmarks/results/aes13-final-20260724-rv2.3/`：采纳完整的 `aes`、`aes_sky130_a`。
- `benchmarks/results/aes11-functional-parallel-20260725-rv2.3/`：采纳其余 11 项。

## 1. 执行结论

1. **流程覆盖保持**：旧、新均为 13/13 生成 post-route/GDS 产物；新结果 13/13 `execution=success`。
2. **测量真实性明显提升**：
   - 新结果 13/13 有输入、协议、二进制、构建、硬件与产物 SHA-256。
   - 约束覆盖由旧报告大多数设计存在 5 个未约束端口，提升为 13/13 `unconstrained_endpoint_count=0`。
   - 无 VCD/SAIF 时不再把 vectorless 数字当签核功耗，13/13 明确 `G9=not_run`。
   - congestion 不再使用旧 `Average=-1`，13/13 输出 bin count、total、max、mean、top-1%、top-5% 和 nonzero-bin。
   - GDS 文件存在但 DRC 非零时，13/13 正确标记 `GDS_signoff=fail`。
3. **物理质量没有整体提升**：
   - DRC 合计由 710,701 增至 749,997，增加 **5.53%**；逐设计中 5 项改善、1 项不变、7 项退化。
   - Sky130 合计 DRC 增加 **6.81%**；Nangate45 改善 **1.61%**；ASAP7 改善 **2.14%**；ICS55 退化 **0.81%**。
   - 13 项 HPWL 中位变化为 **+0.30%**，EGR wirelength 中位变化为 **+0.33%**。主要退化集中在 Sky130，HPWL/EGR 均增加约 3%。
4. **性能不能判定“提升”**：
   - 新 iRT wall 相对旧报告观测值为 2.29–4.93 倍，但旧结果没有 host/线程/binary/repeat 证据，新结果又拆成 2 个串行与 11 个同机并发样本。
   - 所有新 profile 均为 `comparable=false`、`exclusive_host=false`、`repeat=1`。因此只能判定存在强性能风险，不能据此关闭或判失败 G21。
5. **商业 parity 未提升为通过**：新结果仍为 13/13 `quality=fail`、0/13 DRC clean、0/13 SPEF-backed STA、0/13 activity-backed power、0/13 IR-drop。

## 2. Provenance 与可比性

### 2.1 新结果共同证据

- `git_commit=1ca482dfa228bf3d11ac29680c346eecb8fe0cef`，`dirty=true`。
- `binary_sha256=1e80b4f4f39de8dacd46220fdfdeb923de44455c4a6f0ed0736713c6d034a80d`。
- `protocol_sha256=d308cd8d6ad5b53c67260811f273bded3c0f91695a1911d293d9fd82425de789`。
- `build_manifest_sha256=bbdceb6363cc95a3b5a046bc8701db86e94381ba043a8f59186af2430b8b0c71`。
- `hardware_manifest_sha256=09f1e02f169080c883ea9f032bf808f4a9045b8da422790af46e42c0674d8d79`。
- 13 份 `quality_summary.json` 均通过 freshness/哈希校验。
- 11 路并发结果有通过哈希审计的顶层 batch summary；串行结果根没有顶层 batch summary，只采纳两个完整 design summary，并排除残留的中断 `aes_sky130_b`。

### 2.2 比较等级

| 等级            | 指标                                                                                   | 本报告用法                                                      |
| --------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| A：可直接核对   | flow completion、die/core、target util、floorplan cell count、产物存在、当前 gate 状态 | 可给确定结论                                                    |
| B：方向性对比   | 同名设计 HPWL/FLUTE/EGR、原始 EGR map、iDRC engine-subset DRC                          | 可判断变化方向；旧结果无输入/deck hash，不能作 signoff 等价声明 |
| C：代理值       | 无 SPEF 的 setup/hold、CTS wirelength                                                  | 只用于发现异常和生成假说                                        |
| D：不可直接比较 | runtime、memory、旧 vectorless power、旧`Average=-1` congestion、IR-drop             | 不宣称提升/退化                                                 |

13 项 die side 和 floorplan cell count 新旧完全一致；这支持同名设计的几何/WL方向性比较，但不能补回旧基线缺失的二进制、输入、线程和机器 provenance。

## 3. 当前 13 项指标

`setup/hold WNS/TNS` 均无 SPEF，只是 cell-delay proxy；WNS 来自 `quality_summary.json`，TNS 从同一 timing report 的 `Clock/TNS` 汇总行提取（当前尚未提升到 quality-summary schema）；`iRT wall/RSS` 只作观测。

Floorplan cell area 新旧一致：Sky130 68,354.307 μm²、Nangate45 13,642.608 μm²、ASAP7 1,412.758 μm²、ICS55 19,568.640 μm²。当前 final GDS 大小范围分别为 110.6–116.2、85.8–92.4、215.2–282.9、86.9–92.8 MiB。

| Design              |         PDK/u |  Die μm / cells |      HPWL / FLUTE / EGR μm | EGR union nz% / max / top1 |     DRC |                  setup WNS/TNS / hold WNS/TNS ns |  iRT wall / user s / RSS MiB |   GDS s |
| ------------------- | ------------: | ---------------: | --------------------------: | -------------------------: | ------: | -----------------------------------------------: | ---------------------------: | ------: |
| `aes`             |    sky130/30% |  628.934 / 9,434 | 347,519 / 412,410 / 413,683 |         20.29 / 68 / 47.97 | 158,333 |             -2.299 / -548.760 / -0.084 / -12.003 | 5,404.6 / 13,534.8 / 2,306.8 |     6.4 |
| `aes_sky130_a`    |    sky130/35% |  588.214 / 9,434 | 337,404 / 400,564 / 401,488 |         22.35 / 70 / 50.92 | 166,251 |             -2.299 / -548.760 / -0.084 / -12.003 | 5,515.5 / 14,108.0 / 2,317.1 |     4.6 |
| `aes_sky130_b`    |    sky130/30% |  628.934 / 9,434 | 347,519 / 412,410 / 413,683 |         20.29 / 68 / 47.97 | 158,333 |             -2.299 / -548.760 / -0.084 / -12.003 | 5,142.8 / 13,483.5 / 2,357.0 |     4.8 |
| `aes_sky130_t`    |    sky130/25% |  681.327 / 9,434 | 362,691 / 427,301 / 428,770 |         17.10 / 62 / 45.89 | 161,582 |             -2.299 / -548.760 / -0.084 / -12.003 | 5,205.6 / 13,800.8 / 2,373.9 |     5.4 |
| `aes_nangate45_a` | nangate45/35% |  267.045 / 9,961 | 152,493 / 178,229 / 177,578 |           3.86 / 38 / 8.76 |  18,033 |                 1.380 / 0.000 / -0.140 / -63.665 | 5,689.3 / 11,882.3 / 2,233.1 |    14.9 |
| `aes_nangate45_b` | nangate45/30% |  285.237 / 9,961 | 157,978 / 183,555 / 182,967 |           3.54 / 37 / 8.63 |  18,395 |                 1.380 / 0.000 / -0.140 / -63.665 | 5,783.2 / 12,141.6 / 2,241.9 |    18.6 |
| `aes_nangate45_t` | nangate45/25% |  308.644 / 9,961 | 165,501 / 190,694 / 190,141 |           3.18 / 39 / 8.88 |  21,562 |                 1.380 / 0.000 / -0.140 / -63.665 | 6,277.5 / 12,904.1 / 2,301.8 |    24.2 |
| `aes_asap7_a`     |     asap7/35% |  93.063 / 19,917 |    49,392 / 56,956 / 57,032 |                  0 / 0 / 0 |  13,423 | -1491.028 / -247016.413 / -819.877 / -108251.464 | 3,820.9 / 16,105.3 / 2,079.2 | 1,095.6 |
| `aes_asap7_b`     |     asap7/30% |  98.917 / 19,917 |    51,089 / 58,655 / 58,717 |                  0 / 0 / 0 |  13,929 | -1491.028 / -247016.413 / -819.877 / -108251.464 | 3,898.7 / 16,542.1 / 2,144.3 | 1,571.6 |
| `aes_asap7_t`     |     asap7/25% | 106.449 / 19,917 |    53,254 / 60,827 / 60,838 |                  0 / 0 / 0 |  14,312 | -1491.028 / -247016.413 / -819.877 / -108251.464 | 3,968.9 / 16,931.0 / 2,219.5 | 2,309.3 |
| `aes_ics55_a`     |     ics55/35% |  311.922 / 9,453 | 204,097 / 239,465 / 238,615 |         13.30 / 49 / 23.89 |   1,726 |                 0.845 / 0.000 / -0.105 / -42.269 |  1,432.5 / 6,026.6 / 1,416.4 |    11.5 |
| `aes_ics55_b`     |     ics55/30% |  333.709 / 9,453 | 210,604 / 245,312 / 244,375 |         11.68 / 49 / 22.52 |   1,917 |                 0.845 / 0.000 / -0.105 / -42.269 |  1,533.2 / 6,368.7 / 1,462.9 |    11.5 |
| `aes_ics55_t`     |     ics55/25% |  361.742 / 9,453 | 218,993 / 253,696 / 252,895 |          9.66 / 46 / 22.50 |   2,201 |                 0.845 / 0.000 / -0.105 / -42.269 |  1,618.3 / 6,660.5 / 1,545.0 |    12.7 |

### 3.1 当前 stage 资源统计

下表把串行 2 项与并发 11 项合并后只做观测统计，不用于性能排名。

| Stage      |         wall min / median / max s | user CPU median s |  RSS min / median / max MiB |
| ---------- | --------------------------------: | ----------------: | --------------------------: |
| iFP        |             0.252 / 0.302 / 0.434 |             0.214 |       115.5 / 131.2 / 150.0 |
| iNO        |            3.889 / 5.880 / 15.779 |             6.601 |       254.7 / 293.7 / 897.4 |
| iPL-GP     |          13.592 / 24.368 / 52.657 |            58.815 |       275.2 / 306.7 / 370.5 |
| iCTS       |            5.039 / 6.956 / 16.662 |             6.860 |       206.9 / 310.8 / 826.9 |
| iPL-DP     |            5.502 / 6.363 / 16.290 |             6.309 |       239.4 / 267.0 / 323.4 |
| iRT        | 1,432.547 / 5,142.800 / 6,277.513 |        13,483.486 | 1,416.4 / 2,233.1 / 2,373.9 |
| iSTA       |             3.507 / 4.910 / 7.315 |             5.645 |       290.7 / 344.5 / 868.0 |
| Evaluation |          19.078 / 21.436 / 30.853 |            38.695 | 1,059.0 / 1,186.6 / 2,194.9 |
| iDRC       |             2.856 / 4.810 / 7.214 |            10.335 |       288.0 / 384.0 / 656.0 |
| Filler     |            4.212 / 4.961 / 10.120 |             4.816 |     299.9 / 336.0 / 1,122.1 |
| GDS        |        4.609 / 12.673 / 2,309.322 |            12.874 |     256.0 / 340.0 / 1,036.0 |
| E2E        | 1,538.125 / 5,502.254 / 6,435.949 |        13,633.879 | 1,416.4 / 2,233.1 / 2,373.9 |

## 4. 与旧报告逐设计对比

正数表示数值增加。对 HPWL/EGR/DRC 而言通常是退化；Route ratio 仅为不可比的风险信号。

| Design              | HPWL Δ | FLUTE Δ | EGR Δ |     DRC old → new |  DRC Δ | Route new/old |
| ------------------- | ------: | -------: | -----: | -----------------: | ------: | ------------: |
| `aes`             |  +2.73% |   +2.70% | +2.83% | 153,282 → 158,333 |  +3.30% |        3.83× |
| `aes_sky130_a`    |  +3.59% |   +2.81% | +2.99% | 153,418 → 166,251 |  +8.36% |        3.84× |
| `aes_sky130_b`    |  +2.73% |   +2.70% | +2.83% | 153,282 → 158,333 |  +3.30% |        3.57× |
| `aes_sky130_t`    |  +3.85% |   +3.45% | +3.40% | 143,411 → 161,582 | +12.67% |        4.14× |
| `aes_nangate45_a` |  +0.00% |   +0.00% | +0.00% |   18,297 → 18,033 |  -1.44% |        3.24× |
| `aes_nangate45_b` |  +0.06% |   +0.02% | +0.12% |   19,155 → 18,395 |  -3.97% |        3.07× |
| `aes_nangate45_t` |  +0.18% |   +0.00% | +0.06% |   21,485 → 21,562 |  +0.36% |        3.08× |
| `aes_asap7_a`     |  -0.02% |   +0.01% | -0.06% |   13,478 → 13,423 |  -0.41% |        2.65× |
| `aes_asap7_b`     |   0.00% |    0.00% |  0.00% |   13,929 → 13,929 |   0.00% |        2.68× |
| `aes_asap7_t`     |  -0.22% |   -0.08% | -0.14% |   15,167 → 14,312 |  -5.64% |        2.29× |
| `aes_ics55_a`     |  +0.30% |   +0.58% | +0.60% |     1,871 → 1,726 |  -7.75% |        4.29× |
| `aes_ics55_b`     |  +0.35% |   +0.36% | +0.33% |     1,886 → 1,917 |  +1.64% |        4.62× |
| `aes_ics55_t`     |  +0.41% |   +0.54% | +0.56% |     2,040 → 2,201 |  +7.89% |        4.93× |

### 4.1 WNS/TNS 前后变化

旧基线取 `aes11_detailed_comparison.json`，新值取各设计同一 `aes_cipher_top.rpt` 的 WNS/TNS 汇总；同一 PDK 的三个 utilization/strategy 结果时序值相同。负 slack 的“提升”按违例绝对值下降计算：`(|old|-|new|)/|old|`；旧值为非负时要求新值至少不变，TNS 从 0 变为负数视为回归，不宣称有百分比提升。

| PDK（3 项/项） |                setup WNS old → new |                      setup TNS old → new |            hold WNS old → new |                    hold TNS old → new | 结论                              |
| -------------- | ----------------------------------: | ----------------------------------------: | -----------------------------: | -------------------------------------: | --------------------------------- |
| sky130         | -6.562 → -2.299 (**+65.0%**) | -1,635.299 → -548.760 (**+66.4%**) |       +0.431 → -0.084（回归） |               0.000 → -12.003（回归） | setup proxy 改善；hold/TNS 不达标 |
| nangate45      |              +1.380 → +1.380（0%） |                    0.000 → 0.000（不变） |       +0.086 → -0.140（回归） |               0.000 → -63.665（回归） | hold/TNS 回归                     |
| asap7          |      -1,491.028 → -1,491.028（0%） |        -247,016.413 → -247,016.413（0%） | -819.752 → -819.877（-0.02%） | -104,847.342 → -108,251.464（-3.25%） | setup 不变，hold/TNS 退化         |
| ics55          |           +0.813 → +0.845（+3.9%） |                    0.000 → 0.000（不变） |       +0.130 → -0.105（回归） |               0.000 → -42.269（回归） | setup 小幅改善；hold/TNS 回归     |

因此，13/13 当前结果**没有形成 setup/hold WNS 与 TNS 同时改善**；仅 Sky130 setup proxy 的负值幅度下降，不能作为 SPEF signoff 结论。当前 `quality_summary.json` 尚未独立记录 TNS，后续 runner 必须把 setup/hold WNS/TNS、source、coverage 和 corner 一起结构化，避免只从文本汇总行回读。

### 4.2 PDK 聚合

| PDK            |           DRC old |           DRC new |               Δ |     HPWL 中位 Δ |      EGR 中位 Δ | 判断                            |
| -------------- | ----------------: | ----------------: | ---------------: | ---------------: | ---------------: | ------------------------------- |
| sky130         |           603,393 |           644,499 |           +6.81% |           +3.16% |           +2.91% | 明确退化，需优先归因            |
| nangate45      |            58,937 |            57,990 |           -1.61% |           +0.06% |           +0.06% | 小幅 DRC 改善，WL 基本不变      |
| asap7          |            42,574 |            41,664 |           -2.14% |           -0.02% |           -0.06% | 小幅改善，但 STA/GDS 仍严重异常 |
| ics55          |             5,797 |             5,844 |           +0.81% |           +0.35% |           +0.56% | 基本持平、略退化                |
| **全部** | **710,701** | **749,997** | **+5.53%** | **+0.30%** | **+0.33%** | **没有整体物理质量提升**  |

## 5. 变化归因

### 5.1 Sky130：fanout 从旧基线的空变化变成真实动作

旧结果中 Sky130 floorplan→fanout 实例数不变；新结果识别 116 个 fanout violation，并插入约 140 个 buffer：

- `aes` / `sky130_b`：post-route 实例相对旧结果 +138。
- `sky130_a`：+142。
- `sky130_t`：+140。

这解释了 Sky130 特有的约 3% WL 增量及部分 DRC 增量。无 SPEF 的 setup proxy 从 -6.562 ns 变为 -2.299 ns，但 hold 从 +0.431 ns 变为 -0.084 ns；由于约束语义也变化，不能把 setup 数字解释为签核改善。

结论是：**fanout 功能从疑似 no-op 变为真实执行，这是功能提升；buffer 的物理放置、DRV 复检、hold 和 DRC 代价尚未闭环。**

### 5.2 DRC：整体增量由 Sky130 cut/spacing 主导

13 项按规则类型合计：

| 规则                   |     Old |     New |      Δ |
| ---------------------- | ------: | ------: | ------: |
| metal short            | 442,843 | 447,778 |  +1.11% |
| PRL spacing            | 206,026 | 232,454 | +12.83% |
| cut short              |  13,873 |  18,823 | +35.68% |
| same-layer cut spacing |  10,467 |  13,679 | +30.69% |
| off-grid/wrong-way     |  19,518 |  19,518 |   0.00% |

Sky130 单独看，PRL 增加 16.18%、cut short 增加 42.29%、same-layer cut spacing 增加 139.57%；并出现 24 个旧基线没有的 out-of-die。Nangate45 和 ASAP7 的 short/PRL 有 1%–3% 改善，但离 clean 仍有数量级差距。

### 5.3 Congestion：报告接口改善，空间质量没有统一改善

- 新结果 13/13 的 congestion summary 已可用，这是可观测性提升。
- Sky130 union nonzero-bin 增加 0.27–1.60 个百分点；max 从 72/74 降至 68/70 的同时，mean 增加 3.15%–8.16%。热点峰值略平，但热点范围扩大。
- Nangate45、ICS55 的 mean 多数在 ±6% 内；部分 max 上升，不能判定统一改善。
- ASAP7 union map 仍全零，但 post-route DRC 超过 13k；必须验证 layer/supply/map 生成语义，不能解释为“无拥塞”。

### 5.4 CTS：Sky130 clock wirelength 降低，但电气门禁缺失

- Sky130 clock routed WL 变化为 -22.9%、-9.2%、-22.9%、-1.3%。
- Nangate45/ASAP7 基本持平；ICS55 增加 1.6%–4.2%。
- 当前没有 SPEF-backed post-CTS skew/transition/cap/fanout 联合门禁，因此 CTS WL 只能记为候选改善，不能单独晋级。

### 5.5 ASAP7 GDS：filler 实例数量是首要热点

| Design          | Route 后实例 | Filler 后实例 | GDS MiB | GDS wall s |
| --------------- | -----------: | ------------: | ------: | ---------: |
| `aes_asap7_a` |       23,070 |       283,274 |   215.2 |    1,095.6 |
| `aes_asap7_b` |       23,299 |       344,445 |   243.4 |    1,571.6 |
| `aes_asap7_t` |       23,752 |       429,826 |   282.9 |    2,309.3 |

13 项 filler 后实例数与 GDS wall 的 Pearson 相关系数为 0.990。相关性不等于单一根因，但已足以把 filler 表示、DEF 解析和 GDS writer 作为 P0 profiling 对象。

### 5.6 iRT runtime：强风险来自安全串行化和 DR 热点

当前代码为了避免共享 RTDM GCell pointer 的并发写入，将 PinAccessor 和 DetailedRouter 的部分 box loop 串行化；同时 DetailedRouter 的 violation set 重建和 violation×task 调度存在候选热点。该安全修复避免数据竞争，但很可能解释当前并行利用率不足和 wall 风险。

不能直接拿旧 1,257–2,040 s 与新值作正式回归判定；下一步应实现“box 本地计算 → delta 收集 → 确定性提交”的两阶段并行，并在同一受控 runner 下 A/B。

## 6. Gate 新旧状态

| Gate                     |                      旧基线 |                         当前 | 判断                                 |
| ------------------------ | --------------------------: | ---------------------------: | ------------------------------------ |
| Flow completion          |                       13/13 |                        13/13 | 保持                                 |
| Fully constrained        |     多数设计 5 个未约束端口 |                   13/13 pass | **提升**                       |
| Valid congestion summary |                0/13，`-1` |                   13/13 pass | **提升**                       |
| Activity truthfulness    | 13 个低可信 vectorless 数字 |     13/13 not_run 并说明原因 | **真实性提升**                 |
| DRC clean                |                        0/13 |                         0/13 | 未提升                               |
| SPEF-backed STA          |                        0/13 |                         0/13 | 未提升                               |
| Activity-backed power    |                        0/13 |                         0/13 | 未提升                               |
| IR-drop                  |                        0/13 |                         0/13 | 未提升                               |
| GDS signoff              |            旧报告只确认文件 |              0/13，显式 fail | **真实性提升，签核能力未提升** |
| G21 performance          |                  无可比证据 | observational/non-comparable | 尚未建立基线                         |

## 7. 下一步优化方向与量化目标

### P0-A：先建立可比较 runner

| 项       | 当前                             | 下一目标                                                  |
| -------- | -------------------------------- | --------------------------------------------------------- |
| 构建状态 | binary hash 固定但`dirty=true` | clean build，或 manifest 纳入完整 dirty patch hash        |
| 并发     | 串行 2 + 并发 11                 | 正确性批次与性能批次分离；性能统一`jobs=1`              |
| 重复     | 1                                | 独占机 cold/warm 各 ≥5 次，CV≤5%，报告 median/MAD/P95   |
| 汇总     | 两个结果根                       | 单一 13-design batch summary；失败/中断不得被目录存在掩盖 |

只有完成本项，后续 runtime 才能判断提升或退化。

### P0-B：iRT 安全并行与热点治理

1. 把 PA/DR box 处理拆成线程本地只读计算、delta 收集和确定性串行/分区提交；恢复安全并行。
2. 用 anchored counter 或增量计数替代反复扫描全 GCell 并重建 `std::set`。
3. 为 `updateTaskSchedule` 建 net/violation→task 索引，避免 violation×task 全扫。
4. 对 box wall、候选数、violation 数、调度时间单独 profile。

验收目标：

- 同一当前基线、同一 placement、同一线程/机器上，iRT median wall **至少 2× speedup**。
- 3 次重复的 DRC by-type、EGR WL、via count 与 routed net count 一致；不得用 QoR 换速度。
- RSS ≤2.5 GiB，P95 wall ≤1.2× median。
- 工程 stretch 目标：Sky130 ≤2,100 s、Nangate45 ≤3,000 s、ASAP7 ≤2,600 s、ICS55 ≤500 s；这些目标需在 P0-A 后重新校准，不是当前 G21 结论。

### P0-C：DRC 分阶段归因和首轮降幅

1. 对 `iFP/iNO/iPL/iCTS/iRT` 每阶段 DEF 跑同口径 geometry/DRC 差分，定位新增 violation 的第一个生产阶段。
2. Sky130 对 `fanout off/on`、buffer 合法化、PRL/cut cost 和 via candidate 做单因素 A/B。
3. 每 PDK 固定 placement 扫 DR iteration 1/3/5；只有 DRC 严格下降且 WL 增量≤2%才允许增加迭代。
4. 接入真实 foundry coverage manifest 与 deck 内容 hash；对 Calibre 可比规则建立映射。

首轮目标：

| PDK       |   当前范围 |                                 M1 目标 |                      随后目标 |
| --------- | ---------: | --------------------------------------: | ----------------------------: |
| sky130    | 158k–166k | 每项 ≤100k；short/cut/PRL 明确单调下降 | 至少 1 项 engine-subset clean |
| nangate45 |   18k–22k |                              每项 ≤12k |               至少 1 项 clean |
| asap7     |   13k–14k |                               每项 ≤9k |               至少 1 项 clean |
| ics55     | 1.7k–2.2k |                               每项 ≤1k |               至少 1 项 clean |

跨 PDK共同硬门禁：out-of-die=0、off-grid/wrong-way=0、metal/cut short 优先清零。完成 engine-subset clean 后，再以 Calibre-mapped subset 一致性定义 G11。

### P0-D：fanout 物理闭环

当前 Sky130 的 140 个 buffer 是功能变真的证据，但尚无修复后 DRV 复检：

- 输出 fanout/cap/slew before/after，终态 violation=0。
- 插入 buffer 后立即增量合法化；overlap/off-row/off-grid=0。
- 在固定后续 flow 下，HPWL/EGR 增量各≤1%，post-route DRC 不高于 fanout-off 对照。
- 记录 buffer 的触发 net、cell、位置、负载和接受/回滚原因；去除无收益 buffer。

### P0-E：SPEF/STA、功耗与 IR 真值链

- 13/13 生成并读取 SPEF；routed signal-net 覆盖≥99.9%，unmatched net/instance/pin=0。
- `nonzero_net_delay_paths == reported_paths > 0`，并保持 unconstrained endpoint=0。
- 与 PrimeTime 固定路径首轮做 signed bias/MAE/P95；未建立金标前不以 WNS 优化 iPL/iCTS/iTO。
- 13/13 接入有来源标签的 VCD/SAIF，`switch_power>0`；随后接真实 PDN/current model，13/13 输出 worst/avg IR 与 map。

### P0-F：ASAP7 filler/GDS

1. profile filler 选择、DEF 读写、cell expansion、polygon/stream 写出各阶段。
2. filler 使用最大合法 cell 优先和区间打包，减少 1× filler 数；不得引入空洞、overlap 或密度违规。
3. GDS writer 改为流式/批量写出，避免对 28–43 万实例重复查表和分配。

目标：ASAP7 GDS wall 从 1,096–2,309 s 降至 **≤300 s/项**；GDS round-trip 后实例/层/bbox/special-net 一致，DRC 不增加。

### P1：实现链 QoR

- iPL：Sky130 union top-1% mean 从 45.9–50.9 降至 ≤40，nonzero-bin 相对下降≥15%，HPWL 增量≤2%，固定 iRT 下 DRC下降≥20%。
- iCTS：clock transition/cap/fanout violation=0；首轮 skew≤100 ps；clock WL 不高于当前5%；SPEF-backed post-CTS setup/hold 不退化超过20 ps。
- iTO：接入真实 setup/hold 修复；终态 WNS≥0、TNS=0，added area≤3%，HPWL增量≤5%，DRC不增加。
- **新增目标——floorplan 利用率提至 0.7 附近**：将当前约 0.25–0.35 的基线策略提升到 `CORE_UTIL≈0.70`（可通过 `--target-utilization` 控制）；完成后监控每工艺 `die/core` 收敛、失败率、post-route DRC 与 HPWL/EGR，不允许出现吞吐回退。
- post-route repair：按 short、PRL、cut spacing、min-area 分 kernel；每次修复必须有局部 DRC oracle 和全局回归。
- **新增第 8 项目标——TNS/WNS 提升 ≥10%**：在同一 netlist/SDC/PDK/corner、同一 SPEF-backed STA 和完整 endpoint coverage 下，对 setup 与 hold 的 WNS、TNS 分别相对冻结基线提升至少 10%；负 slack 按违例绝对值下降计算，旧值为 0 的 TNS 必须保持为 0，任一指标不得回归。验收要求 13/13 输出结构化 `setup_wns_ns/setup_tns_ns/hold_wns_ns/hold_tns_ns` 及 source/coverage，并通过 G7 SPEF-backed STA；当前本轮 proxy 数值不计入达标。
- **新增第 9 项目标——TNS/WNS 提升 ≥20%**：在同一冻结基线下，要求同前条同时成立并达到 20%，即 setup/hold WNS 与 TNS 均提升≥20%；任一指标退化即为不达标。

### P2：商业对标

1. 固定相同 netlist、SDC、LEF/lib、RC corner、die/core、route layer 和 effort。
2. iRCX↔StarRC、iSTA↔PrimeTime、iDRC↔Calibre 先完成相关性，再比较实现链 PPA。
3. 独占机双方各≥5次；G21 按 median/MAD/P95 判定，目标为日常设计≤1.5×商业，且至少2/5≤1.0×。
4. 每个 PPA/性能指标独立转绿，不用面积或速度优势掩盖 DRC、STA、power 或 IR 失败。

## 8. 最终判断

本轮修改的主要收益是**失败语义、约束覆盖、性能观测和签核真实性**；这是继续优化所需的地基。物理实现质量方面没有整体提升：Sky130 因 fanout 真执行暴露出 WL/DRC 代价，其余 PDK 只有小幅、混合变化。下一轮应先完成受控性能基线、iRT 安全并行、分阶段 DRC 归因和 SPEF 真值链，再进入 PPA 参数寻优。
