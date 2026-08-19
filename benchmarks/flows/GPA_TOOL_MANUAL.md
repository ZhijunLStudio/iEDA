# iEDA GP Agent 工具手册 v1

## 0. 先解释没有 EDA 基础也能理解的基础概念

### 设计由什么组成

一个数字芯片设计里有很多**可以移动的单元**，每个单元有：

```text
名字：例如 U123
类型：例如 INV_X1
位置：x 坐标、y 坐标
方向：例如 N / S / E / W
```

多个单元通过**网**连接。一个网是“这些引脚应该连在一起”的清单。

### 布局问题是什么

GP 只做一件事：

```text
给每个可移动单元找一个 x、y 位置。
```

它不增加单元，不删除单元，也不真正布线。

### 两个重要文件

#### DEF 文件

```text
一个纯文本文件。
里面一行一行写着每个单元的名字、类型、x 坐标、y 坐标、方向。
```

它就是把“当前布局”保存下来的文件。

#### checkpoint 文件

```text
一个 JSON 文件。
除了单元位置，还保存了 GP 求解器的内部数字，
例如动量、步长、迭代次数、当前惩罚系数。
```

作用：

```text
从 checkpoint 继续运行，和没有中断过一样。
```

### workdir 是什么

```text
一个普通文件夹。
里面放：
- checkpoint 文件
- DEF 文件
- GP 运行历史
- 工具调用记录
```

Agent 每次调用工具都要给一个 workdir 路径，例如：

```text
/tmp/gp_work
```

### 一次工具调用实际发生什么

Agent 发一个 JSON 参数给工具，例如：

```json
{
  "name": "ieda_gp_run",
  "kind": "start",
  "design": "s1238",
  "workdir": "/tmp/gp_work",
  "iterations": 400
}
```

工具执行后返回 JSON 文本，例如：

```json
{
  "ok": true,
  "stop_reason": "budget_reached",
  "iteration": 400,
  "checkpoint_path": "/tmp/gp_work/pl/gp_session_checkpoint.json"
}
```

Agent 读返回结果，再决定下一步调用什么。

### 关键原则

```text
工具只执行明确指定的动作，并返回事实。
哪个动作好、什么时候停、允许差多少步，都是 Agent 决定。
```

---


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

### 3.1 ieda_gp_observe：读取 EDA 事实，无副作用

| kind | 输入 | 输出 | 典型耗时 |
|---|---|---|---|
| status | workdir, checkpoint? | iteration, hpwl(internal), overflow, peak density, route_util, 单位说明 | <1s |
| checkpoints | workdir | 全部 checkpoint 列表 | <1s |
| grid | workdir, checkpoint?, top_n | 前 N 个 bin 的 bbox/density/overflow；top_n=0 全量 | <1s |
| hotspots | workdir, checkpoint?, top_n | 热点 bin 坐标、density、overflow_area | <1s |
| longnets | workdir, checkpoint?, top_n, def_path | top net 名、HPWL、pin 数 | 秒级 |
| unstable | checkpoint_a, checkpoint_b, top_n | 移动最大 cell 及位移 | 秒级 |
| trajectory | workdir, top_n | gp_experiments.jsonl 的历史记录 | 秒级 |

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

## 4b. 参数详解

### ieda_gp_observe

| 参数 | 必填 | 含义 |
|---|---|---|
| kind | 是 | status / checkpoints / grid / hotspots / longnets / unstable / trajectory |
| workdir | 是 | 读哪个文件夹 |
| checkpoint | 否 | 基于哪个 checkpoint；缺省用 latest_checkpoint |
| checkpoint_a | 否 | unstable 的比较起点 |
| checkpoint_b | 否 | unstable 的比较终点 |
| top_n | 否 | 返回前 N 条；0 表示全部 |
| def_path | 否 | longnets 需要 DEF 网表 |

### ieda_gp_propose

| 参数 | 必填 | 含义 |
|---|---|---|
| kind | 是 | regions / region_density / freeze / longnet_instances |
| workdir | 是 | 读哪个文件夹 |
| checkpoint | 否 | 基于哪个 checkpoint 提议 |
| priority | 否 | 当前只有 density 可用 |
| top_n | 否 | 返回前 N 个候选 |
| min_cell_count | 否 | region 至少包含多少 cell |
| max_cell_count | 否 | region 最多包含多少 cell |
| def_path | 否 | longnet_instances 需要 DEF 网表 |
| region | 否 | region_density / freeze 的目标矩形 |

### ieda_gp_run

通用执行参数：

| 参数 | 含义 |
|---|---|
| kind | start / advance / candidate / local_run / local_restart / apply_freeze / apply_region_density / apply_anchor |
| design | 用哪个设计 |
| workdir | 在哪个文件夹运行 |
| input_def | 指定输入 DEF；start(random_init=0) 可用来接上一轮布局 |
| foundry_dir | PDK 目录；sky130 可省 |
| checkpoint | 从哪个 checkpoint 开始 |
| iterations | 本批跑多少完整迭代 |
| seed | 随机初始化种子 |
| random_init | 1 随机初始布局，0 保留当前 DEF 坐标 |
| target_density | 每个 bin 的密度目标，-1 用配置值 |
| init_density_penalty | 初始密度惩罚 |
| min_phi_coef | 密度惩罚最小缩放 |
| max_phi_coef | 密度惩罚最大缩放 |
| congestion_effort | 0 关，1 开 |
| seed_anchor_strength | 0~1，朝初始坐标回拉的强度 |
| report_route_util | 1 表示 batch 结束算 RUDY |
| candidate_iterations | local_restart 中 candidate 的迭代数 |
| restart_iterations | local_restart 中重新 global GP 的迭代数 |

scope 参数：

| 参数 | 含义 |
|---|---|
| scope | global / hotspot / random / instances / region / longnet |
| scope_active_ratio | hotspot 里取多少比例热点 bin |
| scope_active_count | random / longnet 的 active cell 数 |
| scope_seed | random scope 的随机种子 |
| scope_instances | 逗号分隔的 instance 名单 |
| scope_region | llx lly urx ury |
| halo_coeff | halo 邻居移动比例 0~1 |
| halo_hops | halo 扩散几跳 |
| overflow_penalty | candidate 接受 HPWL/overflow tradeoff 的权重 |
| scope_density_target | 局部密度目标，1 表示不额外限制 |
| scope_density_ratio | hotspot 里应用密度目标的比例 |
| scope_anneal_ratio | 前多少比例迭代用局部 mask，剩余全局修复 |
| force_local | local_restart 是否强制接受 local child |
| region | apply_freeze / apply_region_density 的矩形 |
| strength | apply_anchor 的回拉强度，当前不支持 |

### ieda_gp_verify

| 参数 | 含义 |
|---|---|
| kind | delta / lg / metrics |
| workdir | 输出/输入目录 |
| checkpoint | lg 的输入 checkpoint |
| checkpoint_a / checkpoint_b | delta 的两个 checkpoint |
| def_path | delta 计算 affected nets 时用 |
| raw_def | metrics 的 raw DEF |
| candidate_def | metrics 的 candidate DEF |
| timing | 1 跑 timing，0 跳过 |

### ieda_gp_session

| 参数 | 含义 |
|---|---|
| kind | restore / accept / unfreeze / clear_density |
| workdir | 目标文件夹 |
| checkpoint | restore / accept 的目标 |

## 4c. 假设-验证工作方式

Agent 使用工具的推荐形态是：

```text
1. 观察
   用 inspect / diagnose 读取事实。

2. 提出可证伪假设
   例如：
   "parent_400 的 5 号 bin 密度 1.66，
    如果只移动该 bin 及邻居的单元，并设 density_target=0.9，
    density_overflow 会下降，且 HPWL 增加不超过 X。"

3. 选一个可执行动作
   从 propose 的 executable_action 中选择，
   或自己组合 scope / density_target / anneal / iterations。

4. 受控执行
   candidate：同时得到 local 和 global 两个结果；
   local_run：只得到 local；
   local_restart：局部扰动后重新全局恢复。

5. 验证
   - 便宜：inspect status / delta / trajectory；
   - 贵：verify metrics / lg。
   由 Agent 根据不确定性决定验证强度。

6. 接受或拒绝
   - 接受：把 winner checkpoint 加入 frontier；
   - 拒绝：保留原 checkpoint，记录失败原因。

7. 更新 frontier
   保留所有可行 checkpoint；
   按观察指标修剪；
   可以回退，也可以从更差的可行解继续探索。
```

没有固定规则说“必须第 N 步验证”或“只允许差一步”。

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
