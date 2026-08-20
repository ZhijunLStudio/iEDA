# GP 点工具极致化设计（只讨论点工具，不讨论编排）

## 0. 目标

Agent 调用一个点工具时，应当满足：

```text
1. 参数合法，且 preflight 直接拒绝非法组合；
2. 执行结果可复现；
3. 任何失败都返回结构化错误和 partial artifact；
4. 所有数值带单位、evaluator 版本、staleness；
5. 所有产生 layout 变化的动作可回滚；
6. 成本可预估；
7. 工具只给事实和 executable action，不给策略。
```

## 1. 工具面

保持 5 个入口，但内部 kind 重新设计：

```text
ieda_gp_observe
ieda_gp_propose
ieda_gp_run
ieda_gp_verify
ieda_gp_session
```

## 2. 统一返回信封

每个工具返回：

```json
{
  "tool": "ieda_gp_run",
  "kind": "candidate",
  "trace_id": "...",
  "request": {...},
  "effective_request": {...},
  "result": {...},
  "artifacts": {...},
  "state": {...},
  "cost": {"elapsed_s": 23.4, "cached": false},
  "error": null
}
```

原则：

```text
- request 是 Agent 发的；
- effective_request 是 EDA 实际生效的；
- result 是所有可比较指标；
- artifacts 是所有文件路径和内容 hash；
- state 是 workdir 最新状态；
- error 永远有稳定错误码。
```

## 3. observe：一个事实，一个字段

### status

```text
返回 checkpoint 完整指标快照。
每个指标必须是 {value, unit, evaluator, staleness, available}
```

字段：

```text
iteration
hpwl_internal
hpwl_def
overflow
peak_density
rudy_demand_max / rudy_demand_total
rudy_utilization_max / rudy_overflow（若容量可用）
setup_wns / setup_tns / hold_wns / hold_tns
step_length
stop_reason
effective_config_fingerprint
```

### checkpoints

```text
不可变 checkpoint 注册表。
每个 checkpoint：
  id
  path
  parent_id
  config_fingerprint
  content_sha256
  iteration
  metrics_snapshot
```

### grid

```text
原始 bin 数组，支持全量 top_n=0。
每个 bin：
  row/col/bbox/occupied/capacity/density/overflow_area
```

### hotspots

热点诊断必须带“分量”：

```text
density
density_target_ratio
overflow_area
overflow_share_of_chip
cumulative_top_k_share
bbox
instance_count
```

### longnets

```text
net name
pins
hpwl
hpwl_share
bbox
driver/load count
```

### congestion_hotspots（新增）

```text
用 run_congestion_eval 的 RUDY 网格：
  demand_max
  demand_share
  若容量可用：utilization / overflow
  bbox
```

### timing_paths（新增）

```text
从 iSTA 报告读取：
  clock
  endpoint
  startpoint
  slack
  path_delay
  involved_instances
```

### trajectory

```text
append-only batch history，带 config_fingerprint 和 cost。
```

## 4. propose：每个候选必须可执行、可拒绝、可解释

统一 candidate 结构：

```json
{
  "proposal_id": "...",
  "hypothesis_fact": "top1 hotspot covers 21% overflow",
  "kind": "region_density",
  "scope": {...},
  "config_override": {...},
  "executable_action": {...},
  "estimated_cost": {"iterations": 20, "seconds": 30},
  "risk_facts": {
    "hpwl_increase_expectation": "unknown",
    "feasibility": "unknown"
  },
  "alternatives": [...]
}
```

### regions

```text
只从密度事实生成 bbox。
不允许无 grid 数据时硬编。
```

### region_density

```text
返回可执行 density target，同时返回该 region 的当前密度和溢出量。
```

### freeze

```text
返回会被冻结的 instance 集合，count 明确。
```

### longnet_instances

```text
top-k 累计 instance 集合，去重，并返回 pin count 和 net count。
```

### congestion_regions（新增）

```text
从 RUDY 网格生成高 demand 区域 bbox。
```

### timing_instances（新增）

```text
从 worst paths 提取 instance 集合，供 scope=instances 使用。
```

### gp_config（新增）

```text
基于当前 state 和历史 trajectory，
给出 bounded config 候选：

  target_density
  congestion_effort
  init_density_penalty
  min_phi_coef / max_phi_coef
  iterations

每个候选都是 executable start/advance 动作，
并且带原因事实，例如：
  current_overflow=0.239 > target 0.12
```

### budget（新增）

```text
基于 trajectory 的步长/HPWL/overflow 曲线，
给出几个 iteration budget 候选。
```

## 5. run：原子执行原语

### 统一 Request

```json
{
  "kind": "...",
  "workdir": "...",
  "checkpoint": "...",
  "config": {...},
  "scope": {...},
  "budget": {"iterations": 20},
  "seed": 1000,
  "force_local": false,
  "report": {"route_util": true, "timing": false}
}
```

### kind 集合

```text
start
advance
candidate
local_run
apply_freeze
apply_region_density
local_restart
```

#### start

```text
输入：
  input_def 或 checkpoint
  config
  budget
  seed / random_init
输出：
  effective config
  checkpoint
  trajectory batch
  stop_reason
  metrics snapshot
```

要求：

```text
- target_reached 也必须写 checkpoint；
- random_init=0 时明确使用 DEF 坐标；
- 返回 effective_target_density 和 fingerprint。
```

#### advance

```text
从 checkpoint 继续，不接受任何 config drift。
config fingerprint 不同 -> 结构化拒绝。
```

#### candidate

```text
输入 parent checkpoint + scope + budget。
输出：
  local_child_checkpoint + metrics
  global_child_checkpoint + metrics
  verdict + verdict_reason
  feasibility of both
```

失败时：

```text
仍返回已产生的 checkpoint 和 metrics。
```

#### local_run

```text
只跑 local 分支，无对照。
返回 before / delta / after。
```

#### apply_freeze

```text
返回 frozen set、active set、移动前后指标。
batch 级，并在 state 里标记 scope 生命周期。
```

#### apply_region_density

```text
返回 region、目标密度、实际密度变化。
```

#### local_restart

```text
拆成明确阶段，并逐阶段返回：

  stage1 parent_accept
  stage2 candidate
  stage3 promote
  stage4 fresh_global
  stage5 baseline_restart
  stage6 evaluate

每个 stage 失败时：
  error.stage 标明失败阶段；
  已完成的 artifacts 仍保留。
```

## 6. verify：同一 evaluator + 单位一致性

### metrics

```text
输入任意 DEF 列表。
每个 evaluator 独立运行：

  def_hpwl_eval
  run_density_eval
  run_congestion_eval
  eval_timing_metrics

输出：
  value + unit + evaluator_version + elapsed + ok
```

### delta

```text
两个 checkpoint 或 DEF：
  hpwl / overflow / rudy delta
  moved_cells
  affected_nets
```

### lg

```text
只读 LG oracle：
  lg_success
  max/avg displacement
  post-LG HPWL
```

### egr（新增，未来）

```text
对 DEF 跑同一 early global router，
返回 demand / capacity / utilization / overflow。
```

## 7. session：不可变快照 + 精确恢复

```text
restore(checkpoint_id)
accept(checkpoint_id)
list_checkpoints()
```

要求：

```text
- restore 必须 bitwise 等价；
- accept 写 DEF 后记录 provenance；
- checkpoint 注册表带 parent_id 和 content hash；
- 恢复失败返回 fingerprint mismatch / missing / corrupt。
```

## 8. EDA 内核必须补的能力

点工具要做到极致，底层还需要：

```text
1. GP 目标参数：
   wirelength_weight
   density_weight
   congestion_weight
   timing_effort
   并且 effective config 明确返回。

2. congestion evaluation：
   - RUDY demand + capacity -> utilization/overflow；
   - 或 EGR utilization/overflow。

3. timing evaluation：
   - 修复 iSTA ps 单位 bug；
   - 能输出 worst paths + involved instances。

4. checkpoint：
   - content hash；
   - parent link；
   - 每个 candidate child 的 metrics snapshot。

5. execution：
   - preflight 验证参数组合；
   - partial result 安全；
   - rollback 事务。
```

## 9. 点工具的验收标准

```text
1. 非法参数组合：preflight 拒绝，不启动 iEDA；
2. 相同 request：结果可复现，且缓存命中；
3. 任意失败：有 stage / code / partial artifacts；
4. 所有 HPWL 字段：同一 evaluator、同一单位；
5. 所有 overflow 字段：明确 density / congestion / utilization；
6. checkpoint restore：bitwise 等价；
7. 每个 run 动作：返回 cost；
8. propose 每个候选：有 executable_action；
9. 所有 apply 动作：可 rollback；
10. target_reached / budget_reached：都写 checkpoint。
```

## 10. 分阶段落地

```text
P0 正确性：
   accept DEF / fingerprint / iSTA ps / terminal checkpoint

P1 契约：
   统一返回信封 / 错误码 / artifact hash / cost

P2 观察与提议：
   congestion_hotspots / timing_paths / gp_config / budget

P3 执行原语：
   local_restart staged / candidate partial / preflight

P4 evaluator：
   RUDY utilization/overflow / EGR

P5 验收测试：
   全 PDK / 全设计自动契约测试
```
