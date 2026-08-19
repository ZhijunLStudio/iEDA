# iEDA GP Agent 工具手册 v1

本手册只定义工具契约和状态模型。**不定义“第几步必须评测”、
“允许差几步”等策略**，这些由 Agent 决定。

## 1. 状态模型

### workdir

```text
每个 workdir 是一组 GP 会话文件 + checkpoint + trace 的根目录。
```

一个 workdir 同时只允许一个活跃 GP session。

### checkpoint

```text
checkpoint 是不可变快照，包含：
- 当前迭代号
- 当前坐标 / SLP 坐标 / 动量 / 步长 / 惩罚
- config fingerprint
- instance_names / coords
```

checkpoint 路径必须显式传给工具；缺省使用：

```text
<workdir>/gp_agent_state.json 里的 latest_checkpoint
```

如果文件不存在，工具返回结构化错误，不猜路径。

### placement.def

```text
checkpoint 被 accept 后写出的 DEF。
```

是最终可验证布局。不是所有 checkpoint 都会自动写 DEF。

## 2. 通用返回字段

所有工具成功时带：

```json
{
  "ok": true,
  "checkpoint_path": "...",
  "iteration": 400
}
```

所有 HPWL 字段必须带单位：

```text
status.hpwl              -> gp_internal
raw_gp_hpwl              -> def
parent_def_hpwl          -> def
local_restart_hpwl       -> def
lg_hpwl                  -> post-LG DEF
```

Agent 不得跨单位比较。

## 3. 工具清单

### 3.1 ieda_gp_inspect：读取状态，无副作用

| kind | 输入 | 输出 | 典型耗时 |
|---|---|---|---|
| status | workdir, checkpoint? | iteration, hpwl(internal), overflow, peak density, route_util, 单位说明 | <1s |
| checkpoints | workdir | 全部 checkpoint 列表 | <1s |
| grid | workdir, checkpoint?, top_n | 前 N 个 bin 的 bbox/density/overflow；top_n=0 全量 | <1s |

### 3.2 ieda_gp_diagnose：只给事实，不给建议

| kind | 输入 | 输出 |
|---|---|---|
| hotspots | workdir, checkpoint?, top_n | 热点 bin 坐标、density、overflow_area |
| longnets | workdir, checkpoint?, top_n, def_path | top net 名、HPWL、pin 数 |
| unstable | checkpoint_a, checkpoint_b, top_n | 移动最大 cell 及位移 |
| trajectory | workdir, top_n | gp_experiments.jsonl 的历史记录 |

耗时：秒级。

### 3.3 ieda_gp_propose：只输出可执行候选

| kind | 输入 | 输出 |
|---|---|---|
| regions | workdir, priority=density, top_n, min/max_cell_count | region bbox + executable_action |
| region_density | workdir, region | suggested density target |
| freeze | workdir, region | 区域内 cell 集合 |
| longnet_instances | workdir, top_n, def_path | top-k 累计 instance 集合 + executable_action |

要求：

```text
- 每个 proposal 必须带 executable_action；
- 不可执行的 proposal 返回 unsupported；
- 没有预测模型时 prediction_status 必须是 unavailable。
```

耗时：秒级到十秒级。

### 3.4 ieda_gp_run：唯一会修改布局的入口

| kind | 作用 | 中间结果 | 典型耗时 |
|---|---|---|---|
| start | 新建 session | checkpoint_path, stop_reason | 分钟级 |
| advance | 恢复后继续 | checkpoint, 指标 | 分钟级 |
| candidate | 同 parent 的 local/global 双分支 | local/global child checkpoint + metrics + verdict | 分钟级 |
| local_run | 只跑 local，无对照 | before/delta/after + checkpoint | 分钟级 |
| local_restart | local candidate -> accept -> fresh global restart | raw/parent/local/baseline DEF HPWL + overflow + feasibility + child checkpoints | 长，数分钟到数十分钟 |
| apply_freeze | 冻结 region，移动补集 | batch scoped | 分钟级 |
| apply_region_density | region 密度目标 | batch scoped | 分钟级 |
| apply_anchor | 当前不支持分数 strength | unsupported | 立即 |

关键状态保证：

```text
- 所有 apply 可回退到输入 checkpoint；
- candidate 平局/不可比时 winner 为 global；
- local_restart 不删除 workdir，只清理自己的子目录；
- target_reached 也会保存 checkpoint，可继续。
```

### 3.5 ieda_gp_verify：只读验证

| kind | 输入 | 输出 | 耗时 |
|---|---|---|---|
| delta | checkpoint_a, checkpoint_b | HPWL/overflow/RUDY delta + moved cells + affected nets | 秒级 |
| lg | checkpoint 或 placement.def | post-LG HPWL、最大/平均位移、lg_success | 分钟级 |
| metrics | raw_def, candidate_def, timing=0/1 | 同 evaluator HPWL/density/RUDY/timing | 长，数分钟到数十分钟 |

`metrics` 是完整评测，由 Agent 决定何时调用；不是每步必跑。

### 3.6 ieda_gp_session：管理快照

| kind | 作用 |
|---|---|
| restore | 把 workdir 指向某 checkpoint |
| accept | 提交 winner 并写 placement.def |
| unfreeze / clear_density | 当前 batch-scoped，已自动清除，返回当前 checkpoint |

耗时：秒级。

## 4. 度量定义

| 字段 | 含义 | 越小越好 |
|---|---|---|
| hpwl | 总线长 | 是 |
| density_overflow | 超目标密度的面积 / 总 instance 面积 | 是 |
| peak_density | 最大 bin 占用率 | 是 |
| rudy_demand_max | RUDY demand density 最大 | 是，但只是 demand |
| setup_wns | 建立时间最差余量 | 越接近 0 或越正越好 |
| lg_max_displacement | LG 最大位移 | 是 |

feasible 当前定义：

```text
overflow <= 0.12
```

## 5. 成本模型（给 Agent 的参考，不是强制策略）

```text
inspect / diagnose        : 秒级
propose                   : 秒级到十秒级
session restore/accept    : 秒级
local_run / candidate     : 分钟级
start / advance           : 分钟级
local_restart             : 分钟级到数十分钟
verify delta              : 秒级
verify lg                 : 分钟级
verify metrics            : 分钟级到数十分钟
```

Agent 应自行根据当前预算和不确定性选择评测频率。

## 6. 长程搜索原语

以下能力是通用原语，Agent 可任意组合：

```text
1. 快照
   restore(checkpoint)

2. 分支
   candidate(parent, scope)
   -> local_child_checkpoint
   -> global_child_checkpoint

3. 回退
   restore(any checkpoint)

4. 提交
   accept(checkpoint)

5. 局部动作
   local_run / local_restart / apply_freeze / apply_region_density

6. 观察
   inspect / diagnose / trajectory / grid

7. 验证
   delta / lg / metrics
```

**不限制允许差多少步。** Agent 可以：

```text
best = raw
frontier = [parent]
loop:
  take a checkpoint from frontier
  try one or more executable proposals
  keep all feasible children as frontier
  if child better than best -> update best
  prune frontier by observed metrics and budget
```

是否暂时接受更差解、接受多少步、何时评测，均由 Agent 决定。

## 7. 执行保护

```text
- 每个 workdir 默认 128 次 run 动作预算；
- 相同 tool+参数命中缓存，直接返回 cached:true；
- 缓存带版本号，工具语义变化后旧缓存失效；
- local_restart 只清理自己的子目录，不删除 workdir。
```

## 8. 已知边界

```text
- priority 只有 density 已实现；congestion/timing/stability 返回 unsupported；
- apply_anchor 分数 strength 未实现；
- freeze/region density 是 batch-scoped；
- timing evaluator 只有 sky130；
- RUDY evaluator 输出是 demand density，不是 utilization/overflow；
- picorv32 / aes 当前密度约束下尚无可行改善动作。
```
