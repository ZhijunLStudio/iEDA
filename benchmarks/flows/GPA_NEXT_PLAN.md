# iEDA GP 工具下一步计划（GP-only，合法化解耦）

## 0. 决策边界（不写规则）

- iEDA GP 只负责三类事实：
  1. **执行**：global/local/restore/candidate/accept 等内核能精确执行的动作；
  2. **观察**：细粒度、可归因的原始数据（逐 bin、逐 net、逐 instance、
     checkpoint delta、scope effect），不输出“应该怎么办”；
  3. **提议**：把观察到的对象翻译成 iEDA 可以执行的候选参数
     （region 矩形、instance 集合、density target），并显式标注
     `executable_action`；iEDA 不能执行的动作不伪造，返回 unsupported。
- **分析、比较、选择动作、设置参数、决定接受还是回退：全部属于 Agent**，
  iEDA 内核和 Python 包装都不内置“if density>1.05 then hotspot”之类的规则。
- 验证也采用真实 Agent 调用六入口工具完成，而不是跑一个写死策略的脚本。


本文件回答三个问题：
1. GP 工具到底要做哪些事；
2. 最后用什么指标验收；
3. 如何被 DeepSeek Harness 调用。

## 1. 边界

- 本阶段只做 **GP**：连续坐标域的全局/局部布局优化。
- **不实现 LG/DP**。LG/DP 只作为外部验证 oracle 调用，不进入 GP 内部循环。
- **不把 Innovus baseline 暴露给模型**。Innovus 只用于离线 benchmark，不在运行时工具中返回。
- 工具输入始终是 **一个 design**。
- Agent/DeepSeek 只决定策略和预算，坐标数值全部由 iEDA 内核计算。

## 2. 要做的 GP 工具（按 2.0 五分面）

Harness 实际暴露 6 个入口工具，内部用 `kind` 枚举分派；下方详细能力仍按
五分面维护：

```text
ieda_gp_inspect    kind: status | checkpoints | grid
ieda_gp_diagnose   kind: hotspots | longnets | unstable
ieda_gp_propose    kind: regions | region_density | freeze | longnet_instances
ieda_gp_run         kind: start | advance | candidate | local_run
                          | apply_freeze | apply_region_density
                          | local_restart | apply_anchor
ieda_gp_verify      kind: delta | lg
ieda_gp_session     kind: restore | accept | unfreeze | clear_density
```



命名约定：文档内用 `gp_*` 简写；DeepSeek Harness 中实际工具名统一为
`ieda_gp_*`。

状态约定：
- 所有需要读/改布局状态的工具必须带 `workdir`；
- 可选 `checkpoint`；缺省表示 workdir 最新 checkpoint；
- 返回结果必须带 `checkpoint_path` 和 `iteration`，防止 Agent 用错版本。


### inspect：看状态

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_design_status` | design, workdir, checkpoint? | 当前 HPWL、overflow、overflowing bin 数、RUDY 拥塞代理、timing 估计、step length、对应 iteration |
| `gp_grid_report` | design, workdir, checkpoint?, top_n | 前 N 个密度/RUDY 热点 bin 的坐标与指标 |
| `gp_checkpoint_list` | workdir | checkpoint 清单、iteration、HPWL、overflow、时间 |

`gp_design_status` 和 `gp_grid_report` 的 timing/RUDY 字段必须带
`timing_iter` / `rudy_iter` 和 `stale` 标记；缺省不重算，只读 checkpoint
已保存的值，避免 Agent 把旧估计当成当前值。
### diagnose：找问题

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_diagnose_hotspots` | workdir, checkpoint?, top_n | 密度热点 bin 的坐标、密度、溢出面积（只给事实，不给建议） |
| `gp_diagnose_longnets` | workdir, checkpoint?, top_n | 高 HPWL net 的 net 名、HPWL、pin 数；cell 集合由 propose 输出 |
| `gp_diagnose_unstable_region` | workdir, checkpoint?, window | 最近 N 次迭代移动较大的区域 |

### propose：给候选动作

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_propose_regions` | workdir, priority, top_n, min/max_cell_count, 可选先验 | 具体 bin 区域 + active/halo cell + 事实原因 |
| `gp_propose_region_density` | workdir, region | 基于重叠 bin 密度的 density target + 重叠 bin 事实 |
| `gp_propose_freeze` | workdir, region | 区域内 cell 集合和数量（冻结事实） |
| `gp_propose_longnet_instances` | workdir, top_n | 高 HPWL net 的 instance 集合 + 可直接执行的 `executable_action` |

propose 不改变设计状态。每个 proposal 必须带 `executable_action`，
即 iEDA 现在就能执行的 tool/kind/scope 参数；不能执行的必须返回
`unsupported` 和原因，不得输出“应该冻结”“建议 spread”这类不可执行建议。

#### `gp_propose_regions` 契约

Agent 只给“重点看什么”，不给坐标；iEDA 根据当前 bin/网/拥塞/timing
状态计算出具体区域，Agent 再从返回结果中挑选。

输入：

```json
{
  "design": "s1238",
  "workdir": "/tmp/gp_work",
  "priority": "density",
  "top_n": 5,
  "min_cell_count": 20,
  "max_cell_count": 200,
  "preferred_region": "",
  "avoid_region": ""
}
```

`priority` 当前实际支持与不支持：

- `density`：密度溢出最高的 bin（已实现）；
- `congestion` / `timing` / `stability` / `mixed`：内核尚无对应
  可信输入，propose 必须返回 `unsupported`，不允许用密度结果冒充。

先验必须结构化，而不是两个零散字段：

```json
{
  "priority_order": ["density_hotspots", "longnets"],
  "preferred_region": "",
  "avoid_region": "",
  "objective_weights": {"hpwl": 0.5, "density": 0.3, "congestion": 0.2}
}
```

iEDA 必须基于实际指标生成候选，并在结果中说明候选和先验是否一致。

输出：

```json
{
  "regions": [
    {
      "id": "region-1",
      "bin_indices": [23, 55, 56, 87],
      "bbox": "56879 12325 59352 14790",
      "active_cell_count": 132,
      "halo_cell_count": 87,
      "density_overflow": 0.081,
      "rudy_route_util": 1.69,
      "score": 0.82,
      "reason": "density overflow top bin, merged 4 connected bins",
      "executable_action": {
        "tool": "ieda_gp_run",
        "kind": "candidate",
        "scope": "region",
        "scope_region": "56879 12325 59352 14790"
      },
      "prediction_status": "unavailable"
    }
  ]
}
```

区域大小规则：

1. 从最高分 bin 开始，把相邻高分 bin 合并成连通区域；
2. 合并后 cell 数小于 `min_cell_count`，向外扩一圈 halo；
3. 合并后 cell 数超过 `max_cell_count`，只保留分数最高的 bin。

这样“不大不小”由数据、上下界决定，不由 Agent 直接猜坐标。

预测规则：没有 PAE 实现时 `prediction_status` 必须为 `"unavailable"`，
不得返回伪造的 delta 范围，只返回当前实际指标；executable_action 只能
引用 iEDA 已实现的参数，不能引用“未来会实现”的动作。
### apply：执行动作

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_start` | design, workdir, iterations, seed, config | 新 GP session |
| `gp_advance` | workdir, iterations | 继续全局 GP |
| `gp_candidate` | workdir, checkpoint, scope 参数 | 从同一 checkpoint 跑 local vs global 双分支并给 verdict；global 平局/不可比时胜出 |
| `gp_local_run` | workdir, checkpoint, scope 参数 | 只执行指定局部 scope，不跑对照；失败可回退 |
| `gp_apply_region_density` | workdir, region, target | 对一个矩形区域设置 batch 密度目标 |
| `gp_clear_region_density` | workdir | 当前内核为 batch-scoped，batch 结束即清除；返回当前 checkpoint |
| `gp_apply_freeze` | workdir, region | 冻结区域内 cell，移动补集；batch-scoped |
| `gp_unfreeze` | workdir | 当前内核为 batch-scoped，batch 结束即清除；返回当前 checkpoint |
| `gp_apply_anchor` | workdir, cells, strength | 当前内核不支持分数 strength；返回 unsupported |
| `gp_local_restart` | workdir, checkpoint, scope 参数 | local candidate -> accept -> random_init=0 重新 global GP；返回 raw/restart 对比 |
| `gp_restore` | workdir, checkpoint | 回退到指定 checkpoint |

所有 apply 动作都在 checkpoint/branch 上执行，失败可回退到动作前
checkpoint；session 状态由返回的 `checkpoint_path` 标识。

scope 通用参数：`scope`、`scope_active_ratio`、`scope_active_count`、
`scope_instances`、`scope_region`、`halo_coeff`、`halo_hops`、
`scope_density_target`、`scope_density_ratio`、`scope_anneal_ratio`、
`overflow_penalty`。这些都是通用原语，不包含任何“if 条件则选什么”的规则。

proposal 与 apply 的连接：propose 返回的 `executable_action` 是当前
workdir/checkpoint 下可直接填给 `gp_candidate` 或 `gp_local_run` 的参数。
内核当前不持久化 proposal_id；因此 Agent 执行 proposal 时必须原样携带
该 executable_action，不能只传一个 id。
### verify：验证动作

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_verify_delta` | workdir, checkpoint_a, checkpoint_b | dirty closure 内的 HPWL/密度/RUDY/timing delta |
| `gp_verify_lg` | workdir, checkpoint | 外部 LG 验证：post-LG HPWL、最大/平均位移、合法化结果；timing 当前返回 `available:false`，不伪造 |
| `gp_accept` | design, workdir, checkpoint | 提交 winner 并写 DEF |

`gp_verify_delta` 必须校验两个 checkpoint 的 config fingerprint 和
instance 集合一致；不一致返回 `incomparable`，不计算 delta。

`gp_verify_lg` 是只读验证器：在临时 workdir 上执行 LG，不修改当前
GP session，不写回数据库；timing 在接入 iSTA 前返回 unavailable。
## 3. 验收指标

### 3.1 GP 内部快速指标（不需要 LG）

| 指标 | 含义 |
|---|---|
| `hpwl` | 半周长总线长，越小越好 |
| `density_overflow` | 密度溢出面积 / 总实例面积，越小越好 |
| `overflowing_bin_count` | 仍有溢出的 bin 数量 |
| `peak_bin_density` | 最大 bin 密度 |
| `rudy_route_util_max` | RUDY 最大布线利用率，拥塞代理 |
| `setup_wns` / `setup_tns` | GP 内 iSTA timing 估计 |
| `hold_wns` / `hold_tns` | GP 内 iSTA timing 估计 |
| `step_length` | Nesterov 步长，用于判断是否收敛 |

这些指标只标为 `fidelity: gp`。

每个指标还要带可用性信息，而不是假设始终存在：

```json
{
  "hpwl": {"value": 5745273, "available": true},
  "setup_wns": {"value": null, "available": false, "reason": "timing_effort=0"}
}
```

RUDY 在 `congestion_effort=0` 时不可用；timing 在 `is_timing_effort=0`
时不可用。缺失就用 `available: false`，不编默认值。
### 3.2 外部验证指标（必须经过 LG）

| 指标 | 含义 |
|---|---|
| `lg_hpwl` | LG 后的 HPWL |
| `lg_max_displacement` | LG 最大位移，越小说明 GP 越接近合法解 |
| `lg_avg_displacement` | LG 平均位移 |
| `lg_success` | 是否合法化成功 |
| `lg_setup_wns/tns` | LG 后 timing，标为 `fidelity: lg` |
| `lg_hold_wns/tns` | LG 后 hold |

真实拥塞需要 GR/DR，不在 GP 验收必选项里；本阶段只要求 RUDY 代理。

### 3.3 验收标准

P0：
- 工具不返回 Innovus baseline。
- 4 个设计 GP 最终结果都能通过 `gp_verify_lg`。
- LG 最大位移不超过设计 site 高度的 4 倍；LG 后 HPWL 不大于 GP 前
  unplaced 初始 HPWL。
- checkpoint 等价：num_threads=1 下，start(N) 与 start(M)+resume(N-M)
  结果逐字节一致。
- candidate 双分支从同一 checkpoint 出发，verdict 判定可复现。
- 所有 apply 动作失败后能回退到动作前 checkpoint，session 不被破坏。

P1：
- local GP 在至少一个设计上相对 global 稳定改善；其余设计失败时
  verdict 必须安全回退 global。
- 所有局部动作返回 dirty closure 和指标 delta；dirty closure 必须
  保守覆盖跨出区域的 net 和 timing path。
- 多 seed 重复结果记录在案。
- 如果局部 GP 在所有目标设计上都不能改善，必须产出明确的
  negative result 记录，而不是继续调参到“偶然成功”。
- 决策边界验收：仓库中不得存在按设计名或按阈值分支选择 scope 的
  规则脚本；改善必须来自真实 Agent 对 inspect/diagnose/propose 输出
  的分析与选择。
- proposal 验收：每个 proposal 必须有可执行参数；不可执行的返回
  unsupported；不存在“建议做 X”但无法执行的 proposal。
## 4. DeepSeek Harness 调用方式

插件继续使用原生 Cordis 工具形式，注册在 `~/.dsh/profiles/web`。
模型看到的是上述工具，不是“一个总工具”。

### 4.1 模型完整调用流程

冷启动（示例；具体动作和参数由 Agent 根据观察决定，不是固定流程）：

```text
1. ieda_gp_run kind=start                       创建 session
2. ieda_gp_inspect kind=status                  读指标
3. ieda_gp_inspect kind=grid                    读逐 bin 密度
4. ieda_gp_diagnose kind=hotspots / longnets    读事实
5. ieda_gp_propose kind=regions / longnet_instances
                                                iEDA 给出可执行候选
6. Agent 比较候选，决定 scope 和预算
7. ieda_gp_run kind=candidate / local_run / local_restart
8. ieda_gp_verify kind=delta / lg               验证
9. ieda_gp_session kind=accept / restore        接受或回退
```

热启动：从 `gp_checkpoint_list` 选择 checkpoint，直接进入第 2 步，
使用该 checkpoint 作为后续 propose/apply/verify 的输入。

### 4.2 关键约束

- `design` 参数只允许一个设计名；
- 所有 apply 都返回 checkpoint 路径；
- 模型不能直接修改坐标，只能调用工具；
- 每次动作必须记录预算、scope、指标 delta 和 verdict；
- 工具输出带 `fidelity` 字段，防止模型把 GP 估计当成合法化后结果；
- 一个 workdir 同时只允许一个活跃 GP session；candidate 分支完成后
  必须 restore/close 到唯一活跃状态；
- 工具 manifest 必须声明预算上限和耗时量级，Agent 不能无限调用；
- iEDA 工具名统一为 `ieda_gp_*`，本文 `gp_*` 是简写。

## 4b. 实施状态（随轮次更新）

- [x] inspect：status / checkpoint_list / grid_report（`gp_toolbox.py`）
- [x] diagnose：hotspots / longnets / unstable
- [x] propose：regions / region_density / freeze / longnet_instances
- [x] apply：start / advance / candidate / local_run / local_restart / accept / restore
- [x] apply：freeze（batch-scoped，移动补集）/ region_density（local_run）
- [x] apply：unfreeze 和 clear_region_density（batch-scoped 语义，返回当前 checkpoint）
- [x] apply：per-cell anchor 分数强度（kernel 不支持，按 G-08 返回 unsupported）
- [x] verify：verify_delta（checkpoint-global delta）
- [x] verify：dirty-closure 增量评估（moved cells + affected nets）
- [x] verify：verify_lg 只读 LG oracle（HPWL + max/avg displacement）
- [x] Harness 原生工具已注册并实测（deepseek-v4-pro 真实调用 status/propose/checkpoint）
- [x] P0 四设计回归与 checkpoint 等价复验（见 GPA_PLAN_EVIDENCE.md）
- [x] P1 local GP 改善/negative result 记录（旧规则链证据保留在 GPA_PLAN_EVIDENCE.md）
- [x] P1 重验：真实 Agent 自主选择动作，s1238/apb4/aes 改善，picorv32 正确回退 raw
- [x] 长程验证：7 设计 / 4 PDK 跑 parent->local_restart->新 parent 循环
- [x] 长程暴露的 Harness 参数转发/顺序 bug 全部修复
- [x] 移除 MCP 插件中仍暴露的 Innovus 对照工具
- [x] 删除规则策略脚本，观察输出只保留事实，propose 只给可执行动作
- [x] 同 evaluator HPWL/density/RUDY/timing 四列比较（gp_metrics_compare.py）
- [x] evaluator 跨设计回归 + 重复运行确定性检查（gp_evaluator_regression.py）
- [x] 修复 density evaluator int32 网格面积溢出

## 5. 不做什么

- 不在 GP 工具里实现 LG/DP；
- 不实现完整布线拥塞评估；
- 不把 move/swap/reorder 放进 GP 工具，它们属于未来的 LG/DP 微工具族；
- 不把 Innovus 作为运行时 oracle。
