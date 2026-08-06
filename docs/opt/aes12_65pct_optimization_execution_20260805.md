# AES12 65% 优化实施与 QoR 验证记录

日期：2026-08-05
分支：`commercial-parity`
依据计划：`docs/opt/aes12_65pct_module_quality_and_optimization_plan.md`

## 1. 本轮目标

按 AES12 65% 模块质量计划继续改造 iEDA.ai，重点从“流程中途阻断”推进到“12 个 AES 设计可重复完成 post-route/GDS，并输出可信质量门证据”。本轮不把残余 DRC、SPEF、Power、IR 伪装成 pass；只修复执行契约、路由预算和观测顺序，使失败项能真实反映下一阶段算法优化目标。

## 2. 代码改造

### 2.1 iPL 执行契约

文件：`src/operation/iPL/api/PLAPI.cc`

- placement flow 返回值改为以 execution success 为流程成功依据。
- placement 质量不足时写 warning，不再把可继续下游验证的合法放置硬失败。
- 作用：65% AES 验证中，placement 阶段不再因质量阈值未达成直接阻断 timing/power/routing/GDS 观测。

### 2.2 iRT SpaceRouter best-effort 预算

文件：`src/operation/iRT/source/module/space_router/SpaceRouter.cpp`

- 新增环境变量预算：
  - `IEDA_RT_MAX_SR_ITERATIONS`
  - `IEDA_RT_MAX_SR_SECONDS`
  - `IEDA_RT_MAX_TASKS_PER_SR_BOX`
  - `IEDA_RT_MAX_SR_BOXES`
- `IEDA_RT_BEST_EFFORT=1` 时默认限制 SpaceRouter 深度，避免高冲突 box 在 65% 场景耗时失控。
- 保留严格模式能力：环境变量不设置时仍可走更完整搜索预算。

### 2.3 AES flow 预算、GDS 与 final quality gate

文件：`benchmarks/flows/aes13_flow.py`

- 将 SR 预算参数接入命令行与 iEDA 环境变量。
- 65% get-through 默认使用：
  - detailed router iteration：1
  - space-router iteration：1
  - space-router seconds：60
  - 每 SR box task cap：64
- 修复 `GDS_FILE` 为绝对路径，避免 Tcl 在 workspace cwd 下拼出错误相对路径。
- 新增 `custom/run_quality_gate.tcl`，在 GDS、congestion、activity、PDN evidence 全部落盘后刷新最终 `quality_gate.json`。
- 作用：最终 quality gate 中 `layout_export` 反映真实 `final.gds`，不再因 metrics 阶段早于 GDS 而误报缺失。

### 2.4 quality gate DRC evidence 路径兼容

文件：`src/platform/report/quality_gate.cpp`

- `drc_clean` gate 同时兼容：
  - `result/rt/detailed_router/iter_dr_series.json`
  - `result/report/rt/detailed_router/iter_dr_series.json`
- evidence 中输出两个候选路径。
- 作用：ICS55 等设计的 detailed-router residual DRC JSON 不再因目录差异被误判为缺失。

## 3. 构建与静态检查

已通过：

```bash
python3 -m py_compile benchmarks/flows/aes13_flow.py
git diff --check -- benchmarks/flows/aes13_flow.py src/platform/report/quality_gate.cpp src/operation/iRT/source/module/space_router/SpaceRouter.cpp src/operation/iPL/api/PLAPI.cc
cmake --build build-aes13 --target iEDA -j 8
```

二进制：

- `bin/iEDA`
- 大小：64,495,112 bytes
- 时间戳：2026-08-05 02:14:06 +0800

## 4. AES12 65% QoR 验证

结果目录：

`benchmarks/results/aes12_65pct_opt_20260805_010000`

验证设计：

| PDK | Designs | Flow status |
|---|---|---|
| sky130 | `aes_sky130_a/b/t` | 3/3 success |
| nangate45 | `aes_nangate45_a/b/t` | 3/3 success |
| asap7 | `aes_asap7_a/b/t` | 3/3 success |
| ics55 | `aes_ics55_a/b/t` | 3/3 success |
| Total | 12 designs | 12/12 success |

最终产物计数：

| Artifact | Count |
|---|---:|
| root + per-design `summary.json` | 13 |
| per-design `summary.json` | 12 |
| `final.gds` | 12 |
| `quality_gate.json` | 12 |
| `congestion_summary.json` | 12 |
| `power/activity_source.json` | 12 |

最终 quality gate 证据状态：

| Gate | Count |
|---|---:|
| `layout_export=pass` | 12/12 |
| DRC residual JSON exists | 12/12 |
| `overall_status=fail` | 12/12 |

全量验证时 routing runtime 采样：

- min：342.5 s
- avg：469.0 s
- max：589.1 s

## 5. 当前质量结论

本轮把 65% AES12 验证推进到了稳定 flow completion，但还没有达到 signoff quality。最终质量门 12/12 fail，失败项一致集中在：

- `drc_clean`：残余 detailed-route DRC 非零。
- `constraints_loaded`：配置 SDC 缺失或为空。
- `spef_backed_sta`：STA 无可信 SPEF/RCX 回标。
- `activity_backed_power`：Power 使用 vectorless/default activity，不是可信 VCD/SAIF。
- `ir_drop_analyzed`：IR-drop 未完成分析，仅有 PDN-ready 或缺失 evidence。

残余 DRC 类型聚合：

| Type | Count |
|---|---:|
| parallel_run_length_spacing | 526,232 |
| minimum_area | 511,970 |
| metal_short | 237,608 |
| end_of_line_spacing | 15,426 |
| nonsufficient_metal_overlap | 547 |
| same_layer_cut_spacing | 8 |
| cut_short | 6 |

## 6. 后续优化执行计划

本轮代码已经把观测面修到可以支撑下一步专项算法优化：12/12 有 GDS、12/12 有最终 gate、12/12 能读到 residual DRC JSON。后续工作不能只继续加 routing 预算；需要把“指标可信度、DRC 主因修复、预算 Pareto、跨模块 QoR”拆开验证。

### 6.1 当前可量化基线

后续 A/B 以 `benchmarks/reports/aes12_65pct_opt_20260805_detailed_comparison.json` 为 QoR 主口径，以每个 design 的 `quality_gate.json` 作为 signoff evidence 主口径。当前 20260805 detailed comparison 聚合如下：

| PDK | 20260805 平均 DRC | 相对上一版 DRC | 平均 routing runtime | 相对上一版 runtime | 主导 DRC 类型 |
|---|---:|---:|---:|---:|---|
| sky130 | 87,867 | +54.9% | 524.7 s | -51.5% | PRL spacing 169,812；metal short 54,852；min-area 32,552 |
| nangate45 | 7,776 | -50.3% | 417.0 s | -48.5% | metal short 14,143；PRL spacing 9,144 |
| asap7 | 37,088 | -25.2% | 562.3 s | +9.0% | min-area 75,690；PRL spacing 14,722；metal short 9,343 |
| ics55 | 26,153 | -7.0% | 345.7 s | -39.9% | min-area 64,001；metal short 9,089；PRL spacing 5,307 |
| 全部 | 39,721 | sky130 回退、其余下降 | 462.4 s | 多数下降 | PRL spacing、min-area、metal short |

解释：

- sky130 是当前最大回退项，不能用全局平均掩盖。sky130 的 placement HPWL、routing HPWL、EGR WL 同时升高，说明上游 placement/routability 与 best-effort routing 都可能参与了回退。
- nangate45 与 asap7 已有显著 DRC 改善，但仍远未 clean，下一步要降低主导类型而不是只看总数。
- ics55 主要受 min-area 限制，适合作为 final min-area patch 和 min-area repair 的专项样本。

### 6.2 里程碑与预期收益

| 里程碑 | 周期 | 技术重点 | 预期指标提升 | 晋级门槛 |
|---|---:|---|---|---|
| M0：固定口径 A/B | 2-3 天 | 固定 input hash、tool hash、线程数、DR/SR budget；生成 `experiment_manifest.json` | 消除不可比实验；所有 delta 可追溯 | 12/12 summary、gate、DRC by type、runtime 都可比较 |
| M1：best-effort min-area 审计 | 2-4 天 | A/B `IEDA_RT_BEST_EFFORT_SKIP_FINAL_MINAREA=1/0`；记录 patch 前后 DRC by type | ics55/asap7 min-area 降低 8%-20%；runtime 增量 < 25% | min-area 降低且 metal short 增量 < 5%，否则不进默认 |
| M2：sky130 PRL/short 回退修复 | 1-2 周 | PRL-aware cost、parallel segment shadow、same-layer spacing penalty、short hotspot split reroute | sky130 PRL 降低 15%-30%；sky130 total DRC 从 +54.9% 回退压到 +15% 以内，目标转负 | sky130 3/3 DRC 不再回退；runtime 不超过 20260805 的 1.5x |
| M3：min-area 专项修复 | 1-2 周 | final patch 候选扩展、extend/fill-style patch、patch 引发 short 的二次检查 | asap7/ics55 min-area 降低 15%-30%；total DRC 降低 8%-18% | min-area 降低不以 short 增长换取；top3 DRC 总量下降 |
| M4：metal short 专项修复 | 1-2 周 | short component clustering、via/segment rip-up、conflict graph reroute ordering | nangate45/asap7 short 降低 15%-25%；total DRC 降低 8%-15% | short 降低且 PRL/min-area 无超过 8% 反弹 |
| M5：可信 PPA 门禁 | 1-2 周 | SDC 完整化、iRCX SPEF 接入 iSTA、activity source 标注、IR 最小报告 | SPEF-backed STA 12/12；activity evidence 12/12；IR evidence 12/12 | gate 不再因缺 evidence 失败；PPA delta 可用于策略选择 |

### 6.3 技术实施细节

#### 6.3.1 固定 A/B 与实验元数据

每次优化实验必须写出 `experiment_manifest.json`，至少包含：

| 字段 | 内容 |
|---|---|
| `tool.git_commit` | 当前源码 commit 或 dirty hash |
| `binary.sha256` | `bin/iEDA` 或指定 binary 的 hash |
| `input_signature` | RTL、LEF、LIB、SDC、config hash |
| `runtime_env` | 所有 `IEDA_RT_*`、线程数、best-effort 开关 |
| `budget_profile` | DR iteration、SR iteration、box cap、task cap、seconds cap |
| `baseline_ref` | 对比用 report JSON 路径 |
| `acceptance_policy` | 本次实验的 pass/fail 阈值 |

固定预算矩阵先跑 4 组，不直接扩大到全参数 DOE：

| Profile | 目的 | 关键参数 |
|---|---|---|
| `E0_current` | 复现 20260805 | DR iter=1，SR iter=1，SR seconds=60，tasks/box=64，skip final min-area=1 |
| `E1_final_minarea` | 验证 final patch 是否被 best-effort 误伤 | 同 E0，但 `skip final min-area=0`，`final min-area tasks=32` |
| `E2_sr_depth2` | 验证 SR 过早停止是否造成 PRL/short | SR iter=2，SR seconds=120，其他同 E1 |
| `E3_dr_iter2` | 验证 DR 轮数收益 | DR iter=2，SR 同 E1 |

验证方式：

- 先跑每个 PDK 的 `a` 样本，共 4 个设计；通过后再扩到 12/12。
- 每组输出 DRC total、DRC by type、routing runtime、EGR WL、placement HPWL、congestion summary。
- 采用 Pareto 判定：若 DRC 降低不到 5% 且 runtime 增长超过 20%，该 profile 不再扩展。

#### 6.3.1.1 20260805 M0 smoke 结果

`aes_ics55_a` 的 E1 smoke 说明 final min-area patch 确实没有在旧结果中被有效采纳，但不能无预算直接打开：

- `E1_final_minarea` 无 task cap 时停在 `patchFinalMinArea`，没有写出 `repair_actions.json`，不适合扩大。
- `final min-area tasks=256` 仍超过 smoke 预算，停在首个 min-area box 后未形成完整 flow 结果。
- `final min-area tasks=32` 可完整跑通：`benchmarks/results/aes12_m0_smoke_e1_cap32_20260805` 生成 DEF/GDS、`quality_gate.json`、`iter_delta.json`、`repair_actions.json`。
- 报告已生成：`benchmarks/reports/aes12_m0_smoke_e1_cap32_20260805_detailed_comparison.md`。
- E1 cap32 相对上一版基线 `aes_ics55_a`：DRC `28,133 -> 25,952`，下降 `7.8%`；routing runtime `581.0s -> 470.6s`，下降 `19.0%`。
- `repair_actions.json` 显示两次 final patch 均为 `run_limited`：每次处理 32 个候选，合计 accepted patch 177 个，total DRC 分别 `-238`、`-256`。
- 规则类型收益主要来自 min-area：第一次 `minimum_area -252`，第二次 `minimum_area -274`；副作用是 PRL 分别 `+12`、`+18`，metal short 第一次 `+2`。
- `quality_gate` validator 通过，语义为 `flow_success=true`、`signoff_success=false`。SDC 证据已接入，但 `constraints_loaded` 仍 fail，原因是真实 SDC 缺少 I/O delay 与 slew/load；SPEF/IR 仍 fail。

结论：

- E1 cap32 可以进入 4-design A/B，但不能晋级默认 profile。
- M1 的重点从“是否打开 final min-area”转为“有限预算下提高 patch 质量”：候选排序、局部 spacing/short 预检查、每 box 面积增量限制。
- 若 4-design A/B 中 min-area 下降 <8% 或 PRL/short 任一反弹 >5%，E1 保持实验 profile，不进入 12/12 默认。

#### 6.3.2 iRT/iDRC 结构化 DRC 反馈

当前只看 violation 总数不够，iRT 需要把 repair 决策与 DRC 类型绑定。新增或补齐以下结构化输出：

| 输出 | 技术内容 | 用途 |
|---|---|---|
| `detailed_router/violation_features.json` | rule type、rule id、layer、bbox、net id、component id、box id、is_new_after_patch | 定位主因和二次引入违例 |
| `detailed_router/repair_actions.json` | action type、rip-up net、candidate count、accepted/rejected、cost delta、runtime | 判断算法是否实际被采纳 |
| `detailed_router/iter_delta.json` | 每轮 DRC by type、new/fixed/remaining、runtime、task count | 区分预算收益和算法收益 |
| `detailed_router/hotspot_components.json` | hotspot bbox、connected violation count、dominant rule、candidate nets | 支撑 short/PRL component reroute |

验收：

- 12/12 输出上述 JSON。
- 每个 top violation 至少能追到一个 box、layer、net/component。
- report 中展示 top10 hotspot，不再只展示全局 DRC 总数。

#### 6.3.3 PRL spacing 专项

技术动作：

- 在 detailed router cost 中加入 parallel segment overlap penalty：同层、平行、间距低于 rule threshold、投影重叠越长，cost 越高。
- 对 sky130 建立 PRL shadow map：对已布线 segment 按 PRL spacing rule 扩展 forbidden/penalty 区域，供候选路径评估。
- 对高 PRL hotspot 做 component-level rip-up：同一个 hotspot 内优先 rip-up 可替代度高、pin access 风险低、历史冲突次数高的 net。
- PRL 修复后立即做 local DRC check，避免 PRL 降低但 short 或 EOL 增加。

预期：

- sky130 PRL spacing 降低 15%-30%。
- sky130 total DRC 先从当前 +54.9% 回退压到 +15% 以内，下一阶段目标转为相对 baseline 下降 5%-10%。
- routing runtime 增量控制在 1.5x 以内；超过则只作为 high-effort profile，不进入默认 65% get-through。

验证：

- 单测：构造两条长平行 M 层 segment，验证 cost 会避开 PRL forbidden 区。
- AES A/B：`aes_sky130_a` 先跑 E1/E2，对比 PRL、short、runtime；通过后扩 `b/t`。
- 回退规则：如果 PRL 降低但 short 增长超过 10%，该策略回退到实验开关，不进入默认。

#### 6.3.4 minimum area 专项

技术动作：

- best-effort 下允许 final min-area patch 作为独立 profile 开关，不和 SR/DR 深度绑定。
- patch candidate 从单一延长扩展为 `extend`、`jog_extend`、`local_fill` 三类；每个 candidate 先做局部 short/spacing 预检查。
- 为 asap7/ics55 增加 min-area priority：当 min-area 是 dominant rule 时，提高 candidate patch budget，但限制每个 box 的最大新增 metal 面积。
- 输出 patch 前后 `minimum_area fixed/new/remaining`，确认不是把 min-area 转换成 short。

预期：

- ics55 min-area 降低 20%-35%，total DRC 降低 10%-18%。
- asap7 min-area 降低 15%-25%，total DRC 降低 8%-15%。
- runtime 增量 E1 相对 E0 小于 25%；若超过 40%，只对 ics55/asap7 high-effort profile 启用。

验证：

- 单测：短线段/小 patch testcase 修复后 clean。
- AES A/B：`E0_current` vs `E1_final_minarea`，先跑 `aes_ics55_a`、`aes_asap7_a`。
- 质量门：min-area 降低必须伴随 `metal_short` 增量 < 5%、`parallel_run_length_spacing` 增量 < 5%。

#### 6.3.5 metal short 专项

技术动作：

- 按 connected component 聚类 short violation，区分 same-net overlap、different-net short、via-related short。
- 对 different-net short，优先 rip-up 较低 criticality、较低 fanout、较短替代路径的 net。
- 对 via-related short，增加 via candidate keepout 与 cut-layer spacing penalty。
- reroute ordering 从按 box 顺序改为按 hotspot severity 排序：`short_count * layer_weight + prl_count + history_penalty`。

预期：

- nangate45 metal short 降低 15%-25%，total DRC 降低 8%-15%。
- asap7 metal short 降低 15%-25%，同时不让 min-area 增长超过 8%。
- runtime 增量小于 35%。

验证：

- 单测：两个 net crossing/via overlap testcase，修复后 no short。
- AES A/B：先跑 `aes_nangate45_a`、`aes_asap7_a`，通过后扩到 12/12。
- 回退规则：short 降低小于 8% 或引入 PRL/min-area 超过 8%，不得晋级默认 profile。

### 6.4 P0 可信测量闭环

当前 WNS/Fmax/Power 不能作为优化决策依据，必须并行修复。P0 的目标不是改善 PPA 数字，而是让数字可信。

| 工作包 | 技术动作 | 预期结果 | 验证机制 |
|---|---|---|---|
| SDC 完整化 | 为每个 PDK 生成 clock、input/output delay、input transition、load 模板；flow 检查空 SDC | `constraints_loaded=pass` 12/12；unconstrained ports=0 或 waiver | `report_constraints` 解析并写入 gate |
| SPEF-backed STA | routing 后调用 iRCX 输出 SPEF；iSTA `read_spef` 后 report timing；标记 SPEF source | `spef_backed_sta=pass` 12/12；关键路径 net delay 非零 | timing report 中抽样 top paths，`net delay > 0` |
| Activity-backed Power | 支持 SAIF/VCD 输入；无真实波形时写明确 `vectorless_proxy`，不能 pass | 有真实 activity 时 `activity_backed_power=pass`；否则 fail with evidence | `activity_source.json` 包含 source、coverage、switching ratio |
| IR 最小闭环 | 固定 PDN 模板、电流模型、iIR report；先不做优化 | `ir_drop_analyzed=pass` 12/12；输出 worst/avg drop | `ir_drop.json`、热图、阈值面积 |
| Gate 统一 | 区分 flow success 与 signoff success | GDS 存在可 flow pass，DRC/STA/Power/IR 不可信则 signoff fail | `quality_gate.json` 成为唯一门禁入口 |

预期指标：

- `layout_export=pass` 保持 12/12。
- `constraints_loaded` 从当前 0/12 提升到 12/12。
- `spef_backed_sta` 从 0/12 提升到 12/12。
- `activity_backed_power` 在无真实 VCD/SAIF 时仍应 fail，但必须有明确 evidence；有活动文件时目标 12/12 pass。
- `ir_drop_analyzed` 从 0/12 提升到 12/12。

### 6.5 P2 跨模块 QoR 优化

DRC 专项稳定后，再做 iFP/iPL/iCTS/iRT 联合优化。避免在 STA/Power 不可信时用 WNS/Power 驱动默认策略。

| 方向 | 技术动作 | 预期指标提升 | 验证 |
|---|---|---|---|
| Routability-driven placement | iPL 读取 EGR overflow、pin density、early-router overflow；增加 congestion weight/padding sweep | sky130 EGR WL 降低 8%-15%；PRL/short 间接降低 5%-12% | placement HPWL 不能增长超过 10%；DRC 必须下降 |
| utilization/padding DOE | 每 PDK 只扫 3 个 util/padding 点，例如 62/65/68 或 cell padding 0/1/2 | 找到每 PDK Pareto 点；DRC 降低 5%-15% | report 输出 DRC-runtime-area Pareto front |
| CTS/routing 联合 | CTS buffer/cluster/fanout sweep，post-CTS congestion 与 post-route DRC 联合评分 | clock WL/skew 可控，routing DRC 不恶化 | SPEF-backed STA 后才允许以 WNS 晋级 |
| PDN/routing resource 协调 | PDN stripe/blockage 写入 routability map，避免 routing 后才暴露 IR/DRC 冲突 | IR evidence pass，局部 routing overflow 降低 | IR-drop 与 DRC 同时进 gate |

### 6.6 验收与回退规则

默认 profile 晋级必须同时满足：

1. 12/12 flow completion 保持。
2. 任一 PDK 专项优化不能让该 PDK total DRC 平均恶化超过 3%。
3. 目标 DRC 类型下降达到工作包阈值，且其他 top3 DRC 类型反弹不超过 8%。
4. routing runtime 默认 profile 不超过 20260805 平均的 1.5x；超过则只作为 high-effort profile。
5. `quality_gate.json` 必须完整输出所有 evidence；缺 evidence 视为 fail，不允许用缺失数据计算改善。
6. 每次报告必须包含 baseline JSON、experiment manifest、per-design summary、CSV/HTML/MD 四类产物。

回退规则：

- DRC 下降不足 5% 且 runtime 增长超过 20%，回退。
- 单 PDK 改善但其他 PDK 平均 DRC 恶化超过 5%，改为 PDK-specific profile。
- WNS/Fmax/Power 在 SPEF/activity 未 pass 前不得作为晋级依据。
- 任何策略导致 GDS、quality gate、DRC residual JSON 缺失，直接回退。

### 6.7 推荐执行顺序

1. 先跑 `E0_current` 与 `E1_final_minarea` 的 4-design A/B，确认 best-effort 跳过 final min-area 对 ics55/asap7/sky130 的影响。
2. 同步补 `experiment_manifest.json` 与 `iter_delta.json`，保证后续实验可追溯。
3. 若 `E1` 对 min-area 有正收益，扩到 12/12；否则保持开关但不进默认。
4. 开始 sky130 PRL/short 专项，先用 `aes_sky130_a` 做单样本闭环，再扩 `b/t`。
5. 对 nangate45/asap7 做 metal short 专项，对 ics55/asap7 做 min-area 专项。
6. P0 测量闭环并行推进；SPEF/SDC/Power/IR 未 pass 前，不使用 WNS/Fmax/Power 做默认策略决策。
7. 每完成一个专项，生成新的 detailed comparison report，并在报告中列出 PDK-specific profile 是否晋级默认。

## 7. P0 synthetic RCX/activity 资产回接记录

### 7.1 本轮交付

为了解锁 iRCX/iSTA/iPA 的 smoke 验证入口，本轮生成并接回了 synthetic P0 资产。所有资产均标记为 `trusted=false`，只能用于流程贯通和工具健壮性验证，不能作为 foundry RC、真实仿真活动或 signoff 证据。

新增/更新的资产与脚本：

| 类型 | 路径 | 状态 |
|---|---|---|
| 资产总清单 | `benchmarks/flows/synthetic_p0_assets_manifest.json` | 12/12 activity，4/4 PDK synthetic RCX |
| activity 生成器 | `benchmarks/flows/generate_synthetic_activity.py` | VCD/SAIF，支持物理 gate netlist `aes_cipher_top` |
| RCX 生成器 | `benchmarks/flows/generate_synthetic_rcx.py` | 从 tech LEF + layer mapping 生成 `.itf/.captab` |
| 批量准备脚本 | `benchmarks/flows/prepare_synthetic_p0_assets.py` | AES12 一键生成 activity/RCX/inventory |
| RCX inventory | `benchmarks/flows/rcx/rcx_resource_inventory.json` | 4/4 `synthetic_ircx_ready=true`，0/4 `trusted_ircx_ready=true` |
| PDK RCX 资产 | `benchmarks/flows/rcx/{sky130,nangate45,asap7,ics55}/` | 每个 PDK 有 `.itf/.captab/*_synthetic_rcx_manifest.json` |
| activity 资产 | `benchmarks/activity/<design>/` | 每个 AES12 design 有 `aes_cipher_top.vcd/.saif/activity_manifest.json` |

### 7.2 代码回接

本轮同步做了三类工具回接：

- `benchmarks/flows/aes13_flow.py`：打开 `asap7`、`ics55` 的 RCX PDK 配置，统一记录 synthetic/trusted provenance。
- `benchmarks/flows/rcx/sky130/layer_mapping.txt`：补齐 `li1/mcon`，修复 sky130 iRCX `design_layer_id=7` mapping 缺失。
- `src/operation/iPA/source/module/core/PwrGraph.cc`：VCD annotation 遇到 STA netlist 缺 net 或无 driver 时返回 `nullptr` 并跳过，避免 `ipower::AnnotateToggleSP` 段错误。
- `src/operation/iPA/source/module/ops/calc_power/PwrCalcInternalPower.cc`：internal power 遇到缺失 STA/power vertex、缺失 source STA arc、非有限 toggle/SP/table power 时跳过或归零当前 pin/arc，避免 `-nan` 传播到 cell/total power。
- `src/platform/report/quality_gate.cpp`：power observation 增加 `has_nonfinite_power_value` 和 `finite_total_power`，把 `-nan` 功耗显式结构化。

### 7.3 验证命令

脚本与构建验证：

```bash
python3 -m py_compile benchmarks/flows/aes13_flow.py \
  benchmarks/flows/prepare_synthetic_p0_assets.py \
  benchmarks/flows/generate_synthetic_activity.py \
  benchmarks/flows/generate_synthetic_rcx.py \
  benchmarks/flows/inventory_rcx_resources.py

cmake --build build-aes13 --target iEDA -j 8
```

资产生成：

```bash
python3 benchmarks/flows/prepare_synthetic_p0_assets.py \
  --output benchmarks/flows/synthetic_p0_assets_manifest.json
```

4-PDK `a` 样本 RCX smoke：

```bash
python3 benchmarks/flows/aes13_flow.py --design <design> --resume --no-synthesis \
  --target-utilization 0.65 \
  --result-root benchmarks/results/aes12_65pct_opt_20260805_010000 \
  --stop-after rcx --timeout 900
```

4-PDK `a` 样本 VCD power smoke：

```bash
python3 benchmarks/flows/aes13_flow.py --design <design> --resume --no-synthesis \
  --target-utilization 0.65 \
  --result-root benchmarks/results/aes12_65pct_opt_20260805_010000 \
  --stop-after metrics \
  --activity-vcd benchmarks/activity/<design>/aes_cipher_top.vcd \
  --activity-top aes_cipher_top \
  --timeout 900
```

### 7.4 回接结果

RCX smoke 已在 4 个 PDK 的 `a` 样本上通过，均生成当前 routed DEF 对应的 SPEF：

| Design | SPEF | Size |
|---|---|---:|
| `aes_sky130_a` | `result/rcx/aes_cipher_top_typical_25C.spef` | 49,554,429 bytes |
| `aes_nangate45_a` | `result/rcx/aes_cipher_top_typical_25C.spef` | 42,512,966 bytes |
| `aes_asap7_a` | `result/rcx/aes_cipher_top_typical_25C.spef` | 51,150,358 bytes |
| `aes_ics55_a` | `result/rcx/aes_cipher_top_typical_25C.spef` | 38,096,886 bytes |

Power smoke 已在 4 个 PDK 的 `a` 样本上通过 iPA stage，`activity_source.json` 均为 `activity_source=vcd`、`synthetic=true`、`trusted=false`：

| Design | VCD coverage | Power stage | finite total power | Total power |
|---|---:|---|---|---:|
| `aes_sky130_a` | 5.141% | success | true | `3.459e-02 W` |
| `aes_nangate45_a` | 5.005% | success | true | `5.474e-03 W` |
| `aes_asap7_a` | 3.267% | success | true | `2.715e-02 W` |
| `aes_ics55_a` | 4.988% | success | true | `7.995e-03 W` |

解释：

- 4 个 PDK 的 `a` 样本均已形成 synthetic SPEF + synthetic VCD 的完整 smoke 样本，可用于后续 iRCX/iSTA/iPA 回归。
- `sky130/asap7/ics55` 之前的 `-nan` total power 已由 iPA internal power 防护修复；`grep -Rin "nan" .../aes_*_a/workspace/result/power/*.pwr` 当前无命中。
- 4 个样本的 `quality_gate.json` 均记录 `finite_total_power=true`、`has_nonfinite_power_value=false`。
- 4 个样本的 `quality_gate.json` 仍保持 `overall_status=fail`、`signoff_success=false`，这是正确结果：RCX/activity 均为 synthetic/untrusted，且 DRC 非 clean、IR-drop 未完成。

### 7.5 剩余 P0 blocker

当前 synthetic 资产解决的是 smoke 入口，不解决签核可信度。P0 仍需继续处理：

1. 真实 foundry 或校准过的 `.itf/.captab`/RC tech 文件，替换 synthetic RCX，并让 `trusted_ircx_ready=true`。
2. 真实 RTL/gate 仿真 VCD/SAIF，替换 synthetic VCD，并提高 measured coverage。
3. iPA 当前已能在 synthetic VCD 下输出有限功耗，但该数值仍是 smoke 数据；必须用真实仿真 VCD/SAIF 复验后才能进入 PPA/签核比较。
4. IR-drop 最小闭环：PG SPEF/current model、worst/avg drop、map、阈值面积。
5. DRC clean 或可审计 waiver；当前 residual DRC 非零仍是 signoff hard fail。
