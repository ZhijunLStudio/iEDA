# 72b GP CLI 调用协议草案（Claude Code 直连，Checkpoint-per-Call）

- 依据：`70-agent-native-ieda-system-design-final.md`（阶段二）、`72-gp-tool-first-stage-implementation-plan.md`（M1/M2）
- 定位：把 72 号文档的 `GPRunRequest`/`GPRunResult` 落成**无 MCP、无常驻进程**的 CLI 工具形态
- 状态：草案；字段与 72 号文档保持一致，72 变更时本文件同步

---

## 1. 关键决策

1. **不依赖 MCP**。工具边界就是 72 号文档 §3 的 mode/scope/budget/refs，传输层自由。第一版直接暴露成 CLI 子命令，Claude Code 用现成的 Bash 工具即可调用；未来若要给多 Agent 或结构化校验用，再套 MCP 壳，内核不改。
2. **无常驻 daemon，采用 Checkpoint-per-Call（B 方案）**。每次 CLI 调用是一个新进程：加载 checkpoint → advance 预算 → 保存新 checkpoint → 输出 JSON → 退出。会话状态全部落在磁盘上，调用方无需管理 socket 或进程生命周期。
3. **M2 提前为对外第一个交付物**。72 号文档里 M1（内存分段等价）降级为**内部验证工具**：证明 resume→advance→save 路径与连续运行数值等价。对外暴露的第一版就是持久化 checkpoint 形态。
4. **`advance --session` 在 B 方案下塌缩为 checkpoint 别名**（见 §3.2）。没有常驻进程时，"继续会话 A"在物理上就是"从会话 A 的最新 checkpoint 恢复"。

> 落地状态（2026-08-14，见 72c §12）：M1/M2 已实现。当前 CLI 载体是 Tcl 命令
> `placer_run_gp -mode {start|advance|resume|close} -iterations N [-checkpoint <file>]`，
> 批次边界自动保存 `<output>/pl/gp_session_checkpoint.json`（原子替换）；`-mode resume` 跨进程
> 恢复已验证与连续运行逐位等价。§5 的 sessions/ lineage 目录布局与 §3.1 的 `--seed`/`--init`
> 管线尚未落地（72c §14 剩余项）。

---

## 2. 总体调用形态

```text
ieda gp run [options] --json
```

一次调用 = 一条无状态命令，进程内流程固定为：

```text
解析参数 → 校验 mode 与 ref 组合
  → 加载 checkpoint（resume/advance）或 revision（start/relinearize）
  → 按预算执行 advanceOneAcceptedIteration() × N（自然收敛可提前停止）
  → 判定终止条件
  → 保存新 checkpoint + 发布只读 revision + 生成 PlacementDiff
  → stdout 输出 GPRunResult JSON → exit 0/1
```

约束（继承 72 号文档）：

- 暂停/退出只发生在**完整已接受迭代边界**，不会停在半次回溯中间。
- 内部回溯不计入 `--iterations` 预算。
- 输出 JSON 是唯一机器接口；日志走 stderr，不污染 stdout。
- 进程被杀/崩溃：上一个 checkpoint 仍完整，可重新 `resume`（幂等安全）。

---

## 3. 完整参数表

### 3.1 参数一览

| 参数 | 取值 | 适用 mode | 含义 |
|---|---|---|---|
| `--mode` | `start` / `advance` / `resume` / `relinearize` | 全部 | 会话运行方式 |
| `--revision` | 设计版本引用（路径或 ID） | `start`、`relinearize` | 建立/重建会话所依据的设计版本 |
| `--session` | 会话名 | `advance` | 会话句柄；B 方案下 = 该会话最新 checkpoint 的别名 |
| `--checkpoint` | checkpoint 路径 | `resume` | 从持久化求解器状态恢复 |
| `--scope` | `global` / `local` | 全部 | 全芯片更新，或 Active/Halo 更新 + Context 冻结 |
| `--scope-ref` | 范围引用 | `local` | `scope.build` 产出的对象集合 |
| `--iterations` | 正整数 | 全部 | 本次已接受迭代预算（默认 20） |
| `--seed` | 整数 | `start`（及以后） | 随机种子；仅初始化策略为 random 时影响路径 |
| `--init` | `keep` / `random` | `start` | 初始化策略：保留当前坐标 / 随机初始布局 |
| `--objective-context` | JSON/文件引用 | 全部（预留） | 目标上下文（线长/密度/时序/拥塞权重）；首版固定默认值 |
| `--json` | 开关 | 全部 | 以 JSON 输出 GPRunResult |

### 3.2 mode 与 ref 的互斥规则（72 号文档 §3.1 的 CLI 化）

| mode | 必填 ref | 禁用 ref | 行为 |
|---|---|---|---|
| `start` | `--revision` | `--session`、`--checkpoint` | 新建会话；`--init` 决定保留坐标还是随机初始布局 |
| `advance` | `--session`（或 `--checkpoint`） | `--revision` | 继续现存会话；**不许重新随机布局、不许重置动量** |
| `resume` | `--checkpoint` | `--revision`、`--session` | 从 checkpoint 恢复后继续 |
| `relinearize` | `--revision` | `--session`、`--checkpoint` | 保留新坐标，重建密度网格/梯度/步长，**清空动量与历史**，开新会话 |

> B 方案简化：`--session sess_A` 解析为 `<sessions>/sess_A/checkpoint/latest.json`。CLI 校验后统一走 resume 路径，`--session` 仅是目录组织别名。

### 3.3 校验错误（exit 非 0，JSON 里 `ok=false`）

- mode 与 ref 组合不合法；
- `--iterations` ≤ 0；
- checkpoint 依赖的 revision 不存在（checkpoint 文件里记录 `base_revision` 引用，加载时校验）；
- `--scope local` 未带 `--scope-ref`；
- 网表拓扑与 checkpoint 记录的拓扑指纹不一致（→ 提示 `start`，禁止盲目 resume）。

---

## 4. 五个典型场景

### 4.1 首次启动（start，两档初始化）

```bash
# 档 1：保留当前坐标，数值状态从头建（动量/历史清空）
ieda gp run --mode start --revision R0 --init keep --iterations 20 --seed 42 --json

# 档 2：随机初始布局（真正"从头开始"）
ieda gp run --mode start --revision R0 --init random --iterations 20 --seed 43 --json
```

返回（成功，预算用完）：

```json
{
  "schema_version": "ieda.gp.run_result.v1",
  "ok": true,
  "session": "sess_20260814_a",
  "produced_revision": "R20",
  "checkpoint": "sessions/sess_20260814_a/checkpoint/ckpt_20.json",
  "placement_diff": "diffs/R0_R20.diff",
  "state": "Ready",
  "stop_reason": "budget_reached",
  "start_iteration": 1,
  "end_iteration": 20,
  "requested_iterations": 20,
  "executed_iterations": 20,
  "metrics": {
    "hpwl": 8.42e6,
    "overflow": 12846,
    "step_length": 0.02,
    "density_penalty": 1.1,
    "backtrack_count": 3,
    "best_hpwl": 8.41e6,
    "best_overflow": 12500,
    "best_iteration": 18
  },
  "scope_effect": {"moved_instances": 273, "max_displacement": 12.4, "in_scope": true},
  "runtime_cost": {"wall_sec": 2.3, "peak_mem_mb": 2140}
}
```

### 4.2 继续 / 恢复（advance / resume）

```bash
# 继续会话（别名，实际指向 latest checkpoint）
ieda gp run --mode advance --session sess_20260814_a --iterations 20 --json

# 等价显式形式（进程死过/重启后）
ieda gp run --mode resume --checkpoint sessions/sess_20260814_a/checkpoint/ckpt_20.json --iterations 20 --json
```

两条命令在 B 方案下**数值等价**，都产出 `R40` 与 `ckpt_40.json`。返回结构同上，`start_iteration=21`、`end_iteration=40`。

### 4.3 外部改过坐标后重建（relinearize）

```bash
# GP → LG/DP 之后坐标变了，动量/梯度已失效
ieda gp run --mode relinearize --revision R_post_lgdp --iterations 20 --json
```

返回里 `start_iteration=1`（新会话从 1 计），`produced_revision` 为新 lineage 的版本；`metrics.best_hpwl` 等历史已清空重建。

### 4.4 局部运行（local）

```bash
# 先 scope.build 产出 S_C9（对象集合）
ieda gp run --mode resume --checkpoint sessions/sess_20260814_a/checkpoint/ckpt_60.json \
    --scope local --scope-ref S_C9 --iterations 20 --json
```

返回里 `scope_effect` 必须写明三集合实际写入数：

```json
"scope_effect": {
  "active_written": 1200, "halo_written": 400, "context_written": 0,
  "max_displacement": 1.8, "in_scope": true
}
```

`in_scope=false` 时调用方必须停手（写入越界 = 实现 bug，不是可忽略警告）。

### 4.5 提前收敛 / 发散

```json
// 请求 20 次，第 13 次自然收敛
{
  "ok": true, "state": "Completed", "stop_reason": "target_reached",
  "requested_iterations": 20, "executed_iterations": 13,
  "start_iteration": 61, "end_iteration": 73
}
```

```json
// 发散：进程不崩，结构化返回
{
  "ok": false, "rc": 2, "reason": "diverged",
  "state": "Failed", "stop_reason": "diverged",
  "last_valid_revision": "R78"
}
```

`rc` 约定：`0` = 成功；`1` = 参数/引用校验失败（没碰求解状态）；`2` = 求解失败（发散等，有 `last_valid_revision` 可回退）。

---

## 5. 磁盘布局与 lineage 约定

```text
sessions/
  sess_20260814_a/                      # 一个 lineage（一次 start 为根）
    meta.json                           # seed、init、objective_context、拓扑指纹
    checkpoint/
      ckpt_20.json
      ckpt_40.json
      latest.json -> ckpt_40.json       # --session 别名解析目标
    revisions/
      R20.snapshot/                     # 只读设计版本（DEF/坐标/网表）
      R40.snapshot/
  sess_20260814_b/                      # 换 seed/配置重来 = 新 lineage
    ...
diffs/
  R0_R20.diff
scopes/
  S_C9.json
```

约定：

1. **`start` 永远写新 lineage，不覆盖旧 checkpoint 与 revision**（70 号文档 §8.2：父版本不原地覆盖）。重来失败时仍可回到旧路线。
2. **同一 lineage 内 checkpoint 只追加**；`latest.json` 原子更新（先写临时文件再 rename），保证进程随时被杀都不会破坏会话。
3. checkpoint 文件头部记录 `base_revision` 引用与拓扑指纹，resume 时校验（见 §3.3）。
4. 换 seed、换 `--init`、换 `--objective-context` 中影响数值的项 → 必须新 lineage，禁止写进旧 lineage 造成路径混合。
5. checkpoint 内容按 72 号文档 §4.1：坐标（普通 + SLP）、梯度、步长、Nesterov 参数、惩罚系数、HPWL/溢出历史、最佳位置、收敛/停滞/发散历史变量、动态网络权重、随迭代变化的配置参数。密度网格等可确定性重建的缓存不落盘，恢复后重建，等价测试兜底。

---

## 6. "梯度不行，要不要从头开始"的决策

`GPRunResult.metrics` 自带证据，先判断病因再选动作：

| 病因 | 症状（看 metrics） | 正确动作 |
|---|---|---|
| 求解状态失配/损坏 | 外部动过坐标还 advance；或跨进程恢复不等价 | `relinearize`（坐标被外部改过）或 `start --init keep` |
| 布局掉进坏区域 | 步长正常但 overflow/HPWL 长期停滞，`best_hpwl` 与当前 hpwl 差距大 | `start --init random` + **换 seed**（新 lineage） |
| 配置/目标不对（密度惩罚、目标密度、权重） | 从头重跑仍走同一条坏路径 | 换 `--objective-context` 再 start；从头来本身没用 |

两个坑：

1. **同 seed 确定性重跑 = 一模一样地再来一次**，没有信息量。确定性路径下"从头来"必须换 seed 或换配置，否则不如不重来。
2. **重来必须新 lineage**（§5 约定 1/4），否则回退能力被覆盖，"从头来失败"就真的没退路了。

更系统的做法（70 号文档的闭环）：把"继续当前路径"与"从头开始"做成**同 checkpoint 分叉的两个候选**，各跑 20 次，用 `candidate.compare` 的 metrics 决定，而不是拍脑袋。

---

## 7. 与 72 号文档里程碑的关系

| 72 号文档 | 本草案中的角色 |
|---|---|
| M1（内存分段等价） | **内部验证工具**：单线程下 `40 ≡ 20+20`、观察无干扰、不重复随机初始化 |
| M2（Checkpoint 跨进程恢复） | **对外第一个交付物**：本草案的全部 CLI 行为 |
| M3（relinearize） | `--mode relinearize`，验收同 72 号文档 |
| M4（局部 GP） | `--scope local --scope-ref`，验收同 72 号文档（全芯片 scope 系数全 1 ≡ 全局） |
| M5（Agent 调度） | Claude Code 拿到本 CLI 后即可做粗调度；完整闭环等 70 号文档阶段三~五 |

跨进程等价验收（新增，72 号文档 M2 的 CLI 化表达）：

```text
单进程连续 100 次
  ≡ 40 次 + 退出进程 + resume 60 次
  ≡ 20 次 × 5 个独立进程（每进程 resume latest → advance 20 → save → exit）
```

比较内容：坐标、步长、惩罚系数、迭代编号、最终指标——**按数值路径等价判定，不接受"最终 HPWL 接近"**。单线程严格等价；固定生产线程数做容差回归（Agent 决策相关的等价性验证必须在确定性模式下完成）。

---

## 8. 首版明确不做

- 不做常驻 daemon、不做 MCP 壳（内核不变，未来可加）。
- 不暴露单次梯度、回溯、步长控制给 CLI（72 号文档 §2.1：一次完整已接受迭代是原子边界）。
- 不在 CLI 里内置"20 次一定最好"的策略；`--iterations` 只是预算，策略由调用方（Agent/脚本）决定。
- 不在首版实现 `--objective-context` 的自由编辑（预留参数，默认固定）。
- 不训练代理模型，不在此协议里定义模型接口。
