# AES12 65% QoR 下一阶段 Agent 执行编排

日期：2026-08-05
依据：

- `docs/opt/aes12_65pct_optimization_execution_20260805.md`
- `docs/opt/aes12_65pct_module_quality_and_optimization_plan.md`

## 1. 编排目标

按 20260805 后续优化计划推进 iEDA.ai QoR 工作。当前不追求一次性 clean 12/12，而是先建立可复现实验闭环、结构化 DRC 观测、可信 quality gate，再进入 PRL/min-area/metal short 专项算法修复。

## 2. Agent 工作分派

| Agent | 工作线 | 写入边界 | 交付物 | 验收 |
|---|---|---|---|---|
| Dewey | M0 固定口径 A/B 与 experiment manifest | `benchmarks/flows/aes13_flow.py`、`benchmarks/flows/generate_aes11_detailed_report.py`、必要时 `benchmarks/qor/` 新工具 | `experiment_manifest.json` 输出、E0/E1/E2/E3 budget profile 入口、报告展示 profile/manifest | 完成；py_compile 与 prepare-only profile 自测通过 |
| Kant | iRT/iDRC 结构化 DRC 观测 | `src/operation/iRT/source/module/detailed_router/`、必要时 `src/operation/iRT/test/detailed_router/` | `iter_delta.json`、`repair_actions.json` 或 `hotspot_components.json` 最小版本 | 完成；`irt_detailed_router` 编译通过 |
| Huygens | P0 可信测量与 quality gate | `src/platform/report/quality_gate.*`、`src/platform/report/report_manager*`、必要时 gate/evidence 检查工具 | 区分 `flow_success`/`signoff_success`；SDC/SPEF/activity/IR evidence fail reason | 完成；validator 单测与 `ieda_report` 编译通过 |
| Jason | DRC 专项入口只读调研 | 只读，不改文件 | PRL/min-area/metal short 的代码入口、函数名、测试落点、第一批 TODO | 完成；已记录到第 7 节 |

## 3. 集成顺序

1. 先集成 Dewey 的 M0 manifest/profile，保证后续所有实验可比较。
2. 再集成 Kant 的 iRT 观测 JSON，保证 DRC 变化能追到 iter、rule、patch 或 hotspot。
3. 并行评审 Huygens 的 quality gate schema，但只有不影响 flow completion 时才合入默认 gate。
4. 用 Jason 的只读调研作为 PRL/min-area/short 专项实施入口，不直接跳到全量算法修改。
5. 每合入一条工作线后运行对应最小验证，再运行报告脚本检查 JSON/MD/CSV 输出。

## 4. 实验 Profile

| Profile | 用途 | 核心参数 | 晋级条件 |
|---|---|---|---|
| `E0_current` | 复现 20260805 | DR iter=1，SR iter=1，SR seconds=60，tasks/box=64，skip final min-area=1 | 作为对照组，不晋级 |
| `E1_final_minarea` | 验证 best-effort 跳过 final patch 的影响 | 同 E0，但 skip final min-area=0 | min-area 降低 >= 8%，runtime 增长 < 25%，short 增量 < 5% |
| `E2_sr_depth2` | 验证 SR 过早停止是否造成 PRL/short | SR iter=2，SR seconds=120，其他同 E1 | PRL/short 降低 >= 10%，runtime 增长 < 35% |
| `E3_dr_iter2` | 验证 DR 轮数收益 | DR iter=2，SR 同 E1 | total DRC 降低 >= 8%，runtime 增长 < 35% |

## 5. 共同验收门禁

默认 profile 晋级必须同时满足：

1. 12/12 flow completion 不回退。
2. `quality_gate.json`、per-design `summary.json`、root `summary.json` 全部存在。
3. DRC total、DRC by type、routing runtime、budget profile、binary hash、input signature 可追溯。
4. 目标 DRC 类型下降达到工作包阈值，其他 top3 DRC 类型反弹不超过 8%。
5. 默认 routing runtime 不超过 20260805 平均 runtime 的 1.5x；超过只进入 high-effort profile。
6. SPEF/activity 未 pass 前，WNS/Fmax/Power 不作为默认策略晋级依据。

## 6. 主线程职责

主线程负责协调和集成，不与 agent 抢同一文件：

- 维护本编排文档和最终执行摘要。
- 等待 agent 返回后审查 diff、处理冲突、运行最小验证。
- 对每条工作线给出 merge/hold/rework 结论。
- 生成最终 QoR follow-up 报告，说明哪些 profile 可进入下一轮 AES A/B。

## 7. DRC 专项入口调研结果

Jason 已完成只读调研，建议按以下入口推进第一批算法专项。

### 7.1 PRL Spacing

| 入口 | 用途 |
|---|---|
| `DetailedRouter::getNodeCost` | A* cost 消费 PRL overlap penalty |
| `DetailedRouter::updateRoutingNetShapeToGraph` | 建立 PRL-aware shadow/forbidden 区 |
| `DetailedRouter::getRoutingShadowShapeList` | 复用 `DRShadow` 记录固定/已布线矩形与 violation |
| `DetailedRouter::addRouteViolationToGraph` | 将 `kParallelRunLengthSpacing` severity 投到 graph |
| `DetailedRouter::updateTaskSchedule` | 消费 PRL hotspot/component ordering |
| `DRRuleAwareCost.hpp` | 抽出可单测的 `prlOverlapPenalty` helper |

首批 TODO：

1. 在 `DRRuleAwareCost.hpp` 或新 `DRPRLShadowCost.hpp` 增加 header-only PRL overlap penalty helper。
2. 增加 `DRPRLShadowCostTest.cpp`，验证平行投影重叠越长 penalty 越高，非平行/不同层/无重叠为 0。
3. 再把 helper 接入 shadow graph 和 node cost。

### 7.2 Minimum Area

| 入口 | 用途 |
|---|---|
| `DetailedRouter::patchFinalMinArea` | final min-area patch 总入口 |
| `DetailedRouter::buildFinalPatchBox` | 从 residual min-area violation 构造 final patch task |
| `DetailedRouter::patchDRTask` | box 内 patch 与 final patch 共用循环 |
| `DetailedRouter::getPatchViolationList` | candidate 局部 DRC 预检查 |
| `DetailedRouter::getCandidatePatchList` | 扩展 `extend`、`jog_extend`、`local_fill` candidate |
| `DetailedRouter::patchSingleViolation` | 记录 candidate accept/reject 与二次 DRC |

首批 TODO：

1. 扩展 `DRPatch` metadata，记录 patch type、metal area delta、risk score。
2. 增加 `DRMinAreaPatchCandidateTest.cpp`，先锁定 candidate 排序和 reject 逻辑。
3. 在 `patchSingleViolation` 增加 short/PRL/min-area 局部预检查和 action 记录。

### 7.3 Metal Short

| 入口 | 用途 |
|---|---|
| `DRConflictEscalate.hpp` | 复用 conflict component 聚类 |
| `DetailedRouter::applyComponentEscalateOnPlateau` | 按 component severity 选择 hotspot |
| `DetailedRouter::updateTaskSchedule` | 按 severity 调整 reroute ordering |
| `DetailedRouter::routeDRBox` | 验证 schedule 是否影响实际 routing 闭环 |

首批 TODO：

1. 扩展 component severity：`short_count * layer_weight + prl_count + history_penalty`。
2. 区分 same-net overlap、different-net short、via-related short。
3. 增加 `DRShortComponentOrderingTest.cpp`，复用现有 `DRConflictEscalateTest.cpp` 模式。

## 8. 已完成工作线记录

### 8.1 P0 Quality Gate

Huygens 已完成 P0 evidence/gate 加固：

- `quality_gate.json` schema 升级为 `c-quality-gate/v2`。
- 新增顶层 `flow_success`、`signoff_success`、`flow_status`、`signoff_status`。
- gate 增加 `domain`，区分 `flow`、`signoff`、`evidence`。
- `constraints_loaded`、`spef_backed_sta`、`activity_backed_power`、`ir_drop_analyzed` 均要求明确 evidence 和失败原因。
- 新增 `benchmarks/qor/validate_quality_gate.py` 和 validator 单测。

验证记录：

```bash
python3 -m py_compile benchmarks/qor/validate_quality_gate.py benchmarks/qor/tests/test_quality_gate_validator.py
python3 -m unittest benchmarks.qor.tests.test_quality_gate_validator
git diff --check -- src/platform/report/quality_gate.cpp benchmarks/qor/validate_quality_gate.py benchmarks/qor/tests/test_quality_gate_validator.py
cmake --build build-aes13 --target ieda_report -j 8
```

风险：历史 20260805 结果仍是 v1 gate，需要重新跑 `report_quality_gate` 或后续 AES profile 才会产生 v2 gate。

### 8.2 iRT Structured Observability

Kant 已完成 detailed-router 结构化观测最小闭环：

- `DRModel` 增加运行期观测缓存。
- `DetailedRouter` 增加观测记录/导出接口。
- 新增 `iter_delta.json`，记录每轮 DRC total/by type、runtime、task/routed net/wire/via 等信息。
- 新增 `repair_actions.json`，记录 final min-area patch 是否运行、skip reason、patch 前后 DRC、candidate/accepted 数量。
- 输出目录跟随现有 `RTDM.getConfig().dr_temp_directory_path`，与 `iter_dr_series.json` 同目录。

验证记录：

```bash
git diff --check -- src/operation/iRT/source/module/detailed_router/DetailedRouter.cpp src/operation/iRT/source/module/detailed_router/DetailedRouter.hpp src/operation/iRT/source/module/detailed_router/dr_data_manager/DRModel.hpp
cmake --build build-aes13 --target irt_detailed_router -j 8
```

风险：尚未跑 AES 实例确认 JSON 落盘内容；`candidate_count` 目前是 final min-area patch task 数，不是完整候选枚举/拒绝原因统计。

### 8.3 M0 Experiment Manifest

Dewey 已完成 M0 固定口径 A/B 元数据闭环：

- `aes13_flow.py` 增加 `--budget-profile`，支持 `E0_current`、`E1_final_minarea`、`E2_sr_depth2`、`E3_dr_iter2`。
- 每次运行在 result root 输出 `experiment_manifest.json`，包含 git 状态、dirty 标记、flow diff hash、binary sha256、runtime env、budget profile、input signature、baseline ref、acceptance policy。
- 单设计和 batch summary 记录 `budget_profile` 与 manifest 路径。
- `generate_aes11_detailed_report.py` 读取 manifest，并在 JSON/Markdown/HTML 中展示 M0 实验元数据。

验证记录：

```bash
python3 -m py_compile benchmarks/flows/aes13_flow.py benchmarks/flows/generate_aes11_detailed_report.py
git diff --check -- benchmarks/flows/aes13_flow.py benchmarks/flows/generate_aes11_detailed_report.py
python3 benchmarks/flows/aes13_flow.py --design aes_ics55_a --prepare-only --no-synthesis --budget-profile E3_dr_iter2 --result-root /tmp/ieda_m0_manifest_smoke ...
```

Profile 映射：

| Profile | DR iter | SR iter | SR seconds | skip final min-area |
|---|---:|---:|---:|---:|
| `E0_current` | 1 | 1 | 60 | 1 |
| `E1_final_minarea` | 1 | 1 | 60 | 0 |
| `E2_sr_depth2` | 1 | 2 | 120 | 0 |
| `E3_dr_iter2` | 2 | 1 | 60 | 0 |

风险：正式 A/B 应尽量在更干净的 worktree 上跑；当前 manifest 会如实记录 dirty 状态和 dirty path 数量。
