# iEDA GP 工具下一步计划（GP-only，合法化解耦）

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

### inspect：看状态

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_design_status` | design | 当前 HPWL、overflow、overflowing bin 数、RUDY 拥塞代理、timing 估计、step length |
| `gp_grid_report` | design, workdir, top_n | 前 N 个密度/RUDY 热点 bin 的坐标与指标 |
| `gp_checkpoint_list` | workdir | checkpoint 清单、iteration、HPWL、overflow、时间 |

### diagnose：找问题

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_diagnose_hotspots` | workdir, top_n | 密度热点区域 + 建议动作类型 |
| `gp_diagnose_longnets` | workdir, top_n | 高 HPWL net 及关联 cell 集合 |
| `gp_diagnose_unstable_region` | workdir, window | 最近 N 次迭代移动较大的区域 |

### propose：给候选动作

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_propose_scope` | workdir, scope, count/ratio | 将要移动的 active/halo cell 列表 + 选择理由 |
| `gp_propose_region_density` | workdir, region | 建议的 density target + 预测影响 |
| `gp_propose_freeze` | workdir, region | 建议冻结区域 + 冻结后密度变化预测 |

propose 不改变设计状态，只返回候选和理由。

### apply：执行动作

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_start` | design, workdir, iterations, seed, config | 新 GP session |
| `gp_advance` | workdir, iterations | 继续全局 GP |
| `gp_candidate` | workdir, checkpoint, scope, budget | local vs global 双分支和 verdict |
| `gp_apply_region_density` | workdir, region, target | 本次迭代的局部密度目标 |
| `gp_apply_freeze` | workdir, region | 冻结区域并继续 GP |
| `gp_apply_anchor` | workdir, cells, strength | 指定 cell 向锚点回拉 |
| `gp_restore` | workdir, checkpoint | 回退到指定 checkpoint |

所有 apply 动作必须在 branch/checkpoint 上执行，失败可回退。

### verify：验证动作

| 工具 | 输入 | 输出 |
|---|---|---|
| `gp_verify_delta` | checkpoint_a, checkpoint_b | dirty closure 内的 HPWL/密度/RUDY/timing delta |
| `gp_verify_lg` | workdir, checkpoint | 外部 LG 验证：post-LG HPWL、最大位移、合法化结果、post-LG timing |
| `gp_accept` | workdir, checkpoint | 提交 winner 并写 DEF |

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
- checkpoint 等价：同一配置 start(N) 与 start(M)+resume(N-M) 结果逐字节一致。
- candidate 双分支从同一 checkpoint 出发，verdict 判定可复现。
- 4 个设计 GP 最终结果都能通过 `gp_verify_lg`。
- 工具不返回 Innovus baseline。

P1：
- local GP 在至少一个设计上相对 global 稳定改善，且失败时可安全回退。
- 所有局部动作返回 dirty closure 和指标 delta。
- 多 seed 重复结果记录在案。

## 4. DeepSeek Harness 调用方式

插件继续使用原生 Cordis 工具形式，注册在 `~/.dsh/profiles/web`。
模型看到的是上述工具，不是“一个总工具”。

### 4.1 模型完整调用流程

```text
1. gp_design_status(design)                   看当前状态
2. gp_grid_report(...)                         看热点
3. gp_diagnose_hotspots(...)                   找问题
4. gp_propose_scope(...)                       要移动哪些 cell
5. gp_candidate(...)                           执行局部 GP 对照
6. gp_verify_delta(...)                        看增量是否值得接受
7. gp_advance(...)                             继续收敛
8. gp_verify_lg(...)                           合法化验证
9. gp_accept(...)                              提交结果
```

### 4.2 关键约束

- `design` 参数只允许一个设计名；
- 所有 apply 都返回 checkpoint 路径；
- 模型不能直接修改坐标，只能调用工具；
- 每次动作必须记录预算、scope、指标 delta 和 verdict；
- 工具输出带 `fidelity` 字段，防止模型把 GP 估计当成合法化后结果。

## 5. 不做什么

- 不在 GP 工具里实现 LG/DP；
- 不实现完整布线拥塞评估；
- 不把 move/swap/reorder 放进 GP 工具，它们属于未来的 LG/DP 微工具族；
- 不把 Innovus 作为运行时 oracle。
