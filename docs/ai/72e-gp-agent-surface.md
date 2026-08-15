# 72e GP Agent 接口增强：局部 GP、参数旋钮、观测面与 checkpoint 自包含

- 日期：2026-08-15
- 分支：`feat/parity-gp-session`（承接 `72d-gp-agent-handover.md` §5 的优先级）
- 定位：把 72d 里"机制已完成但未暴露"和"Agent 缺观测"的部分做成可调用的产品面，同时修掉规模化路径里的两个已知风险点。

---

## 1. 本次完成

### 1.1 局部 GP 正式进入 `GPRunRequest`/Tcl（不再是测试 harness 私有）

`GPRunRequest` 新增：

```cpp
GPRunScopeMode scope_mode;          // kGlobal | kHotspot | kRandom | kInstances
float scope_active_ratio;           // hotspot：溢出 bin 比例
int32_t scope_active_count;         // random：Active 数量
float scope_halo_coeff;             // 一跳 halo 缩放
uint32_t scope_seed;                // random scope 复现种子
std::vector<std::string> scope_instance_names;  // instances：用户指定种子实例
```

Tcl：

```tcl
placer_run_gp -mode resume -checkpoint <ckpt> -iterations 20 \
  -scope {global|hotspot|random|instances} \
  -scope_active_ratio 0.2 -scope_active_count 100 \
  -scope_halo_coeff 0.5 -scope_seed 42 \
  -scope_instances "inst_a, inst_b, inst_c"
```

语义：

- `scope` 是**本次 batch 的动作参数**，不会写进 checkpoint；下一次调用默认回到 `global`。
- `scope_effect` 返回 `active_written / halo_written / context_written / context_moved / max_displacement`；`context_moved == 0` 是硬不变量。
- `kInstances` 是最适合 Agent 的局部入口：由诊断/用户给出种子实例，net 一跳自动补 Halo，不再要求 Agent 自己构造系数数组。
- `kHotspot`/`kRandom` 保留为对照实验动作；72d 已证明 hot≈random，因此 Agent 应把 random 当廉价 baseline，不要投资热点图算法。

### 1.2 Agent 参数旋钮（kStart 专属，checkpoint 自包含）

`GPRunRequest` 新增 start-time overrides（-1 = 使用配置值）：

```cpp
float init_density_penalty;  // 谨慎旋钮
float min_phi_coef;          // 谨慎旋钮
float max_phi_coef;          // 谨慎旋钮
```

Tcl：

```tcl
placer_run_gp -mode start -iterations 20 -seed 42 \
  -target_density 0.9 -init_density_penalty 0.0001 \
  -min_phi_coef 0.95 -max_phi_coef 1.05
```

关键修复：checkpoint 现在保存**完整有效 NesterovPlaceConfig**（`NesterovPlaceConfig::State`）。`kResume` 会先把该状态恢复到 PlacerDB 配置，再构造 solver 数据库，因此：

- start 时传过 `target_density/init_density_penalty/phi` 的 checkpoint，跨进程 resume **不需要再传一次**；
- 原 72d 中 `target_density` override 后跨进程 resume 会 fingerprint mismatch 的隐患已消除；
- 即使新进程加载了不同的 JSON 配置，checkpoint 也会恢复保存时的有效配置后再校验 fingerprint，数值路径仍可复现（测试 `mismatch` 已改为验证该语义）。

`advance/resume` 收到非默认 start 旋钮会直接拒绝，避免求解中途改配置。

### 1.3 观测面：bin 级溢出报告 + 实验账本

每个 budget batch 自动落两份只读观测：

```text
<output>/pl/gp_grid_report.json     # bin 级溢出 top-N，含坐标/面积/密度/overflow
<output>/pl/gp_experiments.jsonl    # append-only 动作账本（parent ckpt、scope、预算、指标、结果）
```

`GPRunResult` 新增：

```cpp
GPRunScopeEffect scope_effect;
GPOverflowReport grid_report;   // top-N bins + 全局汇总
std::string grid_report_path;
std::string experiment_record_path;
std::string parent_checkpoint_path;
int64_t best_hpwl;              // 会话内历史最佳
float best_overflow;
```

Tcl 每次调用直接打印 `stop_reason / iterations / hpwl / overflow / step_length / density_penalty`，以及 `scope_effect`、checkpoint、parent_checkpoint、grid_report、experiment_record 路径。

### 1.4 候选回退点（parent checkpoint lineage）

每次 `advance` 前，当前 checkpoint 被保留到：

```text
<output>/pl/gp_checkpoints/gp_ckpt_<iter>.json
```

优先 hard-link（大设计零数据拷贝），失败退回 copy。这样 Agent 的"同 checkpoint 分叉候选 → 失败丢弃"有了磁盘级回退点，不会因为 `gp_session_checkpoint.json` 被覆盖而丢父状态。

### 1.5 规模化修复（72d §3.2 前两条）

- `applyNetHaloClosure` 从 `std::map<int32_t, vector<int32_t>>` 改为排序 `(net_id, inst_idx)` pair + `equal_range`，单次分配、大设计不再产生 GB 级 map 节点。
- `buildHotOverflowScope` / `buildHotOverflowDensityTargets` 从"全部溢出 bin 排序"改为 `nth_element` top-k + 只排序 k 个。
- `Grid` 所有 POD 成员补齐 in-class 默认值，move 构造/赋值全量拷贝（72d §4 陷阱 2 的后续）。
- `Grid::obtainAvailableArea/obtainGridOverflowArea/obtainGridDensity` 改为 const，观测路径不触碰网格状态。

### 1.6 timing/max-wirelength 的 `opt_overflow_list` 可配置

`$.PL.GP.Nesterov.opt_overflow_list` 现在是合法 JSON 配置项：

```json
"opt_overflow_list": [0.15, 0.20, 0.25, 0.30]
```

校验：数字数组、每个值 (0,1)、**严格递增**（求解器从末尾最大值开始逐级触发）。JSON 未提供时保持历史行为：timing/max-length 开启后自动 append `[0.15,0.20,0.25,0.30]`；显式提供（包括空数组）则原样使用。

## 2. 典型 Agent 用法

```tcl
init_pl -config <pl_default_config.json>

# 基线：全局 20 次，保存 checkpoint
placer_run_gp -mode start -iterations 20 -seed 42

# 候选：从父 checkpoint 分叉局部 GP（种子实例 + halo）
placer_run_gp -mode resume -checkpoint <output>/pl/gp_session_checkpoint.json \
  -iterations 20 -scope instances -scope_instances "inst_a, inst_b"

# 对照：同预算全局 advance
placer_run_gp -mode resume -checkpoint <parent_ckpt> -iterations 20

# 比较两份结果（hpwl/overflow 同起点同预算）；只 accept 严格更优者，
# 否则用 parent_ckpt 重新 resume。
```

验收硬规则不变：同 checkpoint、同预算、全芯片指标；`context_moved` 必须为 0。

## 3. 验证

```bash
cmake --build build --target ipl_gp_session_test ipl_run_gp_result_test iEDA -j$(nproc)

# 新增场景
build/bin/ipl_gp_session_test --scenario agent_scope           # 实例 scope + scope_effect + 观测文件
build/bin/ipl_gp_session_test --scenario agent_config_resume   # start override 跨进程语义（进程内模拟重置配置）
build/bin/ipl_gp_session_test --scenario mismatch              # 不同 base config 下 checkpoint 自恢复有效配置
build/bin/ipl_config_validation_test                            # opt_overflow_list schema
```

全量 37 项 GP 相关回归（31 场景 + legacy 1276 + config/contract）当前全部 PASS。

## 4. 仍未做（下一优先）

- checkpoint JSON 二进制化 / float 数组直存（72d P0；当前 parent checkpoint 用 hard-link 缓解复制成本，但 dump/parse 仍慢）。
- 生产级 `candidate.accept/reject` API（现在靠 parent checkpoint + close/resume 组合，语义已够但不够顺）。
- `scope.build` 的图诊断与密度屏默认仍是实验工具；密度屏继续不作为默认局部策略。
- `BinGrid::_bin_inst_list` 陈旧映射清理（当前无调用者，保留只增加困惑）。
- 1M+ 设计上的 hot-vs-random 消融与多线程容差回归。
