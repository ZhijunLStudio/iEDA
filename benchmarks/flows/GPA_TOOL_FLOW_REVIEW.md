# GP 点工具流转分析（observe→propose→run→verify→session）

日期：2026-08-21
分支：feat/parity-gp-session
依据：profile_plugin/lib/index.js + gp_toolbox.py + gp_agent.py +
      gp_local_restart.py + gp_timing_paths.py + gp_congestion_observe.py 实读。

目的：回答一个问题——agent 每次"观察→提议→执行→验证"循环里，
信息在哪里断掉、口径在哪里错位、哪些步骤因为工具设计而重复浪费预算。
本文件只讲工具流转，不讲 QoR。

---

## 1. 现状数据流

```text
designs.json 注册表
  （design → case_root / input_def / pl_config / foundry_dir / lef /
    gp_baseline_def / innovus_def）
        │
        ▼
ieda_gp_observe —— 只读事实层
  cheap（纯文件读，不起 iEDA）:
    designs / status / checkpoints / grid / hotspots / longnets /
    unstable / trajectory
  expensive（起 1 次 iEDA）:
    congestion_hotspots（RUDY 64x64 map + 溢出 region + congestion nets）
    timing_paths（iSTA HPWL evaluator + 最差路径 scope_instances）
        │
        ▼
ieda_gp_propose —— 事实→可执行候选层
  regions(density|longnet) / region_density / freeze /
  longnet_instances / gp_config
        │
        ▼
ieda_gp_run —— 执行层（唯一改状态的入口，自动 archive + trace）
  full / start / advance / candidate / local_run /
  apply_freeze / apply_region_density / local_restart / apply_anchor(unsupported)
        │
        ▼
ieda_gp_verify —— 同 evaluator 验证层
  delta（solver 内部口径，2 checkpoint 对比 + dirty closure）
  lg（LG oracle，post-LG HPWL/位移）
  metrics（DEF 级全维度：def_hpwl + density + RUDY + iSTA timing）
        │
        ▼
ieda_gp_session —— 状态管理
  restore / accept / unfreeze / clear_density
```

状态载体（全部在 workdir 内）：

```text
gp_agent_state.json          当前会话指针（case_root/input_def/config/
                             latest_checkpoint/last_* 指标）
pl/gp_session_checkpoint.json 唯一活跃 session checkpoint（C++ 维护）
placement.def                accept 后导出的 DEF
pl/gp_experiments.jsonl      append-only batch 账本（trajectory 来源）
pl/gp_grid_report.json       最近一次 run 结束时的密度 bin 报告
gp_agent_trace.jsonl         每次工具调用的 args+result（插件侧）
gp_agent_cache.jsonl         插件侧缓存（run/congestion/timing）
archive/<timestamp>/         每次 run 前的快照（placement/checkpoint/...）
candidate/ accepted/ local_restart/ baseline_restart/  local_restart 的分支目录
```

---

## 2. 口径与成本矩阵（agent 实际面对的信息矩阵）

| 指标来源 | HPWL 口径 | congestion 口径 | timing 口径 | 单次成本 |
|---|---|---|---|---|
| observe status | solver 内部 | solver 内部 rutil（congestion on 才有） | 无（is_opt_timing off 恒 null） | ~0（文件读） |
| run record | solver 内部 | solver 内部 rutil | 无 | 已含在 run 内 |
| verify delta | solver 内部 | solver 内部 rutil | 无（checkpoint 不持久化 WNS） | ~0 |
| local_restart | **DEF 级 HPWL** | solver 内部 rutil | 无 | 3~6 次 iEDA run |
| verify metrics | **DEF 级 HPWL** | **DEF 级 RUDY 64x64** | **DEF 级 iSTA** | 每 DEF 2 次 iEDA run |
| observe congestion_hotspots | 无 | **DEF 级 RUDY** | 无 | 1 次 iEDA run（DEF mtime 缓存） |
| observe timing_paths | 无 | 无 | **DEF 级 iSTA** | 1 次 iEDA run（DEF mtime 缓存） |

三个关键事实：

1. **run 与 verify 口径断裂**：所有 run record 只有 solver 内部数；
   DEF 级 HPWL 只出现在 local_restart 和 verify metrics。
   agent 判断"这个局部动作有没有效"时，
   唯一同口径通道是 verify metrics——最贵的工具。
2. **verify metrics 没有缓存**（插件代码 line 319 直接 runCli）：
   同一组 DEF 重复评估，每次都重跑全部 iEDA 子进程。
   PLAN_EVIDENCE 里 ihp130 会话 28 次 verify metrics、
   nangate 26 次，其中大量是同 DEF 重复评估。
3. **便宜的同口径通道其实存在**：congestion_hotspots / timing_paths
   就是 DEF 级同 evaluator，且按 DEF mtime 缓存；
   但工具描述没有告诉 agent"这就是 cheap verify"，
   也没告诉它 status.hpwl 不可与 metrics.hpwl 直接比。

---

## 3. 六个流转断点（代码实据）

### 断点 1：observe→propose 域不闭合

observe 覆盖 3 个域的事实：
density（checkpoint grid）、congestion（RUDY run）、timing（iSTA run）。
但 propose 只有 density（+longnet）：

- propose regions priority=congestion/timing/mixed → 直接 unsupported；
- 没有任何 propose kind 输出"timing 路径可执行动作"；
- 而 congestion 的 region rect 和 timing 的 scope_instances
  其实已经在 observe 侧算好了（congestion_hotspots / timing_paths），
  只是没有经过 propose 契约翻译成 executable_action。
- GPA_NEXT_PLAN 自定契约"每个 proposal 必须带 executable_action"，
  现状连 density regions 都没带 executable_action 字段
  （只有 bbox/score/reason，agent 得自己拼 scope_region）。
- propose region_density 只给一个数（1/peak 截断到 [0.6,1.0]），
  不给 2~3 档选项、不给当前 core 级 target_density 参照。

### 断点 2：run→verify 口径断裂（成本放大器）

- start/advance/local_run 的 record：hpwl/overflow/route_util
  全部 solver 内部口径；def_save 已经写了 placement.def，
  却没有顺手跑 def_hpwl_eval（纯 python，秒级）把 DEF 级 HPWL 放进 record。
- local_run 的 delta 只有 hpwl/overflow 两项，没有 rutil delta，
  也没有受影响 net 的 hpwl delta（verify delta 有 dirty_closure，
  但要单独打一次且只对 checkpoint 对）。
- 结果：agent 每步动作后都被迫打 verify metrics 做决策，
  把"验证"从便宜步骤变成了预算黑洞。

### 断点 3：propose→run 参数要 agent 手工组装

- regions 只给 bbox，不给 scope=region 的完整参数（density target
  档位、halo 建议）；
- propose_freeze 只给 count，不给 scope_instances
  （freeze_instances 内部算了补集却只在 apply_freeze 路径使用）；
- longnet_instances 是唯一带 executable_action 的 propose（做得好）；
- gp_config 候选面太窄：congestion_effort 只给 1，不给 2/3；
  不给 timing_effort；不给 min/max_phi_coef、seed_anchor_strength；
  target_density 只 ±0.05。而历史证据（GPA_GAP_ANALYSIS）表明
  config 是最大杠杆（AES target_density 0.9 → HPWL -13.7%）。

### 断点 4：跨会话/跨分支记忆缺失

- trajectory 只是单 workdir batch 账本，没有 DEF 级指标；
- archive 是文件快照，不可查询；
- checkpoint_list 只扫 workdir 根目录 *.json，
  candidate/accepted/local_restart 子目录里的分支 checkpoint 全部不可见；
- 没有任何 observe kind 能输出"已尝试动作 → DEF 级指标"的 Pareto 表。
  agent 的跨会话记忆只能靠自己总结。

### 断点 5：执行粒度

- local_restart 是黑盒：candidate+accept+restart+baseline 一次做完，
  中间失败/中间 verdict 不暴露，成本 3~6 次 iEDA run；
- local 模式（advance/local_run/candidate）不能带 congestion_effort、
  不能带 timing 权重——局部修线时没法加大拥塞/时序目标；
- start 没有 timing 开关（ieda_gp_run 的 timing 参数只控制
  full 的 metrics 是否算 timing，不进入 GP 本身）；
  这就是"runtime timing_effort 未实现"在工具层的体现；
- apply_anchor unsupported；scope anneal 只有一个全局开关。

### 断点 6：口径 bug 与噪音面

- verify lg 的 HPWL 评估硬编码 sky130 LEF
  （gp_agent.py cmd_verify_lg: lef/sky130_fd_sc_hd_merged.lef），
  nangate/ihp130/asap7 的 lg_hpwl 全部是错的口径；
- status 的 overflowing_bin_count/peak_bin_density 来自
  gp_grid_report.json——它永远反映最近一次 run，
  观察旧 checkpoint 时网格数据与 checkpoint 指标不匹配
  （代码注释自认"checkpoint-specific bin report 是未来工作"）；
- 插件侧缓存 budget=128 对 run 和 observe（congestion/timing）共用，
  长会话耗尽后 observe 也会报 "gp action budget exhausted"，
  语义混淆（observe 应该是 LRU 缓存而不是预算上限）；
- ieda_gp_observe grid 与 hotspots 都来自同一份 grid report，
  功能重叠（top bins vs top bins+bbox），可合并。

---

## 4. 改造建议（按优先级）

### P0：不碰 C++，直接放大 agent 决策效率

1. **run record 统一带 DEF 级 HPWL**
   gp_agent.py 在 def_save 后跑 def_hpwl_eval（秒级），
   start/advance/local_run/candidate 的 record 增加
   `def_hpwl`/`def_hpwl_unit="def"`；
   local_run 的 delta 增加 rutil delta。
   这样"动作有没有效"在 HPWL 维度不再需要 verify metrics。
2. **verify metrics 缓存**
   插件侧按 (design, def 集合+mtime, congestion_model, timing)
   做 key 缓存（复用 cachedRun 机制），同一组 DEF 不重复评估。
3. **propose 补 executable_action + 域闭环**
   - regions 输出直接可用的 scope=region 动作（含 density target 档位）；
   - region_density 输出 2~3 档 target 选项 + core 级参照；
   - freeze 输出 freeze_instances 的 scope_instances；
   - regions priority=congestion 复用 RUDY map 的 region rect
     （congestion_hotspots 已产出，翻译即可）；
   - 新增 propose priority=timing（复用 timing_paths 的
     scope_instances + 路径 slack 事实）。
4. **experiments 聚合观察**
   observe kind=experiments：扫 archive/*/gp_metrics_compare.json
   与子目录 checkpoint，输出"动作→DEF 级指标"Pareto 表；
   跨会话传不同 workdir 即可查询。补上断点 4。
5. **缓存语义拆分**：observe 的 congestion/timing 缓存改 LRU 不封顶，
   run 的 128 上限保留但报错文案区分。

### P1：少量 C++/配置配合，把最短板变成 agent 可自循环的问题

6. **start/full 暴露 timing_effort**
   start 增加 timing 开关：写 config is_timing_effort=1 +
   opt_overflow_list=[0.15,0.20,0.25,0.30]（sky130 验证过的阈值），
   并在 record 里返回 timing 更新触发次数。
   注意：ihp130 上次"timing 无效"的疑似根因正是阈值
   （[0.05,0.08,0.1] 低于终止 overflow≈0.099，触发≤1 次），
   这个开关落地即把 ihp130 timing 追赶变成 agent 循环问题。
7. **propose_config 扩展为小网格**
   congestion_effort {1,2,3} × target_density {±0.05,±0.1} ×
   timing_effort {on,off} × init_density_penalty {×2,÷2}，
   每个候选带 hypothesis_fact + 预估成本（迭代数/iEDA run 数）。
8. **local 模式带拥塞/时序权重**
   advance/local_run/candidate 的 scope 参数面增加
   congestion_effort 与 timing 权重开关（需 C++ 把这两项目标
   纳入 advance 的参数面）。

### P2：口径修复与黑盒拆解

9. 修 verify lg 的 LEF 硬编码（从 design registry 取 lef）。
10. local_restart 返回分阶段结果（candidate verdict / accepted
    branch / restart 前后指标），或拆成 candidate+restart 两个原语，
    让 agent 能在中间调整预算与 scope。
11. 工具描述下沉"标准循环协议"：
    observe→propose→run→cheap verify（congestion_hotspots /
    timing_paths / def_hpwl）→metrics 定稿，
    并把口径/成本表写进描述，替换现在靠提示词里的运气。

---

## 6. 实现进度（2026-08-21 晚，commit 8c7538d / 6782bd3 / ec5b5bf）

已完成并验证：

- [x] P0.1 run record 带 def_hpwl：start/advance/local_run 的 record 均有
      DEF 级 HPWL（def_hpwl_eval，秒级）；local_run delta 增加 rutil。
- [x] P0.2 verify metrics 缓存：按 (design, DEF 集合+mtime, model, timing)
      缓存，同组 DEF 第二次调用直接返回 cached:true（实测 5s → 0s）。
- [x] P0.3 propose 补 executable_action：regions（density/congestion）/
      region_density / freeze 都带可直接执行的 action 与 target 档位；
      新增 propose kind=timing（读缓存的 iSTA 报告，输出路径实例集合 +
      slack 事实）。
- [x] P0.4 observe kind=experiments：聚合 trace 里的动作记录（含 def_hpwl）
      + archive 里的 metrics JSON，输出 recent_actions / pareto_actions /
      archive_metrics。
- [x] P0.5 缓存预算按 source 拆分：run 128 上限（报错文案区分），
      observe/verify 缓存 4000。
- [x] P1.6 start/full 的 timing=1：写 pl_timing_override.json
      （is_timing_effort=1 + opt_overflow_list=[0.15,0.20,0.25,0.30]），
      record 返回 timing_weight_updates 次数；workdir 状态记住生效 config，
      advance/local_run 复用。
- [x] P1.7 propose_config 网格：congestion_effort 1→2→3 升级、timing_effort_on、
      phi coef、seed_anchor_strength 候选，全部带 executable_action。
- [x] P2.9 verify lg 的 LEF 硬编码修复（按 design registry lef）。
- [x] status 增加 DEF 级 def_hpwl（与 verify metrics 同口径）。

待办：

- [ ] P1.8 local 模式（advance/local_run/candidate）带 congestion/timing 权重
      （需 C++ 参数面）。
- [ ] P2.10 local_restart 分阶段结果透传（当前已返回 verdict/branch/HPWL，
      可进一步暴露中间指标）。
- [ ] P2.11 工具描述已更新（observe/propose/run/verify），会话实践中继续
      迭代措辞。

---

## 5. 与既有结论的关系

- GPA_GAP_ANALYSIS "B 点工具太粗糙 / 方向信息不足"与本文件断点 1/3/5
  对应；"D Agent 编排问题"的调用浪费与本文件断点 2（metrics 无缓存、
  run 记录口径断裂）直接对应。
- GPA_POINT_TOOL_REVIEW 的 15 个 bug 全部在"错误面"层，
  已闭环；本文件说的是错误面之上的一层——信息面与流转面。
- 本文件不改"工具只给事实、策略归 agent"的边界：
  所有建议都只提供更多事实、更细控制、更一致口径，
  不内置任何"if density>1.05 then hotspot"规则。
```
