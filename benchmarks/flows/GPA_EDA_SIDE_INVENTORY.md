# iEDA GP EDA 侧完整工作清单

本文件只描述 EDA 侧（iEDA 内核 + Python CLI + DeepSeek Harness 插件）
已经完成和正在维护的工作。Agent 的策略不在本文件范围。

## 1. DeepSeek Harness 插件：5 个入口工具

注册在：

```text
@ieda-ai/dsh-tool-ieda-gp
benchmarks/flows/deepseek_harness/profile_plugin/lib/index.js
```

5 个入口：

```text
ieda_gp_observe
ieda_gp_propose
ieda_gp_run
ieda_gp_verify
ieda_gp_session
```

每个入口用 `kind` 分派。

## 2. iEDA C++ 内核能力

### 2.1 GP 会话

```text
start
advance
resume
restore
candidate
close
accept
```

### 2.2 scope

```text
global
hotspot
random
instances
region
longnet
```

### 2.3 局部移动模型

```text
Active  = 系数 1，正常更新
Halo    = 系数 0~1，受限更新
Context = 系数 0，冻结
```

保证：

```text
Context 坐标 bitwise 不变。
```

### 2.4 局部增强

```text
scope_halo_coeff / scope_halo_hops
scope_density_target / scope_density_ratio
scope_anneal_ratio
candidate_overflow_penalty
```

### 2.5 checkpoint

```text
- budget_reached batch 保存 checkpoint；
- candidate 保存 parent/local/global 三个 checkpoint；
- terminal(target_reached) 也保存 checkpoint；
- checkpoint 带 config_fingerprint / instance_names / coords / solver state。
```

### 2.6 恢复与失效

```text
- 不同 config 的 checkpoint 会被拒绝；
- 外部修改设计后 session invalidate；
- random_init=0 可以从 DEF 重建新 session。
```

## 3. Tcl 命令

```text
placer_run_gp
run_density_eval
run_congestion_eval
run_timing_eval
```

## 4. Python CLI

### gp_agent.py

```text
start
advance
candidate
local_run
restore
accept
verify_lg
status
compare
```

### gp_toolbox.py

```text
status
checkpoints
grid
hotspots
longnets
unstable
trajectory
propose_regions
propose_region_density
propose_freeze
propose_longnet_instances
freeze_instances
verify_delta
```

### gp_local_restart.py

```text
candidate -> accept local child -> fresh random_init=0 global GP
```

返回：

```text
raw_gp_hpwl
parent_def_hpwl
local_restart_hpwl
baseline_restart_hpwl
local_restart_overflow
local_restart_feasible
local/global child checkpoint
```

### gp_metrics_compare.py

同一 evaluator 比较任意 DEF：

```text
HPWL
density peak/mean
RUDY demand max/total
timing setup/hold WNS/TNS
```

### gp_evaluator_regression.py

```text
schema 检查
有限值检查
density >= 0
setup WNS <= 0
repeat 2 确定性检查
```

### gp_tool_contract_test.py

```text
7 设计 / 4 PDK
验证 local_restart 返回的 HPWL 与独立 def_hpwl_eval 一致。
```

### gp_export_dataset.py

```text
从 trace + state 导出训练样本
state / action / result / outcome
```

## 5. 验证工作

### 5.1 GP session 测试

```text
seg20 / seg40 / seg10x2 / observe
ckpt_save / ckpt_resume / resume_inproc
seg40_cg / ckpt_*_cg
seg40_mt / ckpt_*_mt
conv_mid / diverge / mismatch / invalidate / relinearize
local_hops / agent_scope / hotspot_random_scope
full_scope_equiv
agent_config_resume
agent_candidate / agent_auto_candidate
legacy / full / validate
```

### 5.2 同 evaluator 指标

```text
HPWL      def_hpwl_eval.py
density   run_density_eval
RUDY      run_congestion_eval
timing    eval_timing_metrics.tcl
```

### 5.3 LG 只读 oracle

```text
verify_lg
临时 workdir 跑 LG
返回 lg_hpwl / max_displacement / avg_displacement / lg_success
不修改原 session
```

## 6. 持久化文件

```text
pl/gp_session_checkpoint.json   主 checkpoint
pl/gp_checkpoints/gp_ckpt_N.json 历史 checkpoint
pl/gp_experiments.jsonl         append-only batch 历史
pl/gp_grid_report.json          bin 密度报告
gp_agent_state.json             workdir 上下文 + latest_checkpoint
gp_agent_trace.jsonl            Harness 工具调用记录
gp_agent_cache.jsonl            动作去重缓存
placement.def                   当前布局
```

## 7. 保护机制

```text
- workdir 默认 128 次 run 动作预算；
- 相同 tool+参数缓存；
- 缓存带版本号；
- local_restart 不删除 workdir；
- scope_instances 用 Tcl 花括号包裹。
```

## 8. 已知边界

```text
- apply_anchor 分数 strength 未实现；
- freeze / region density 是 batch-scoped；
- priority 只有 density；
- timing evaluator 只有 sky130；
- RUDY 输出是 demand density；
- picorv32 / aes 尚无可行局部改善动作。
```
