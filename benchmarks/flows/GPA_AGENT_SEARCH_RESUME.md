# GP Agent Search / Innovus noPrePlaceOpt — 续跑交接（Task A/B）

本文件用于在 DeepSeek Harness 会话上下文接近上限时**无缝换新会话续跑**。
原则：新会话不要粘贴旧会话长日志，只读本文件 + 仓库实际状态。

## 0. 分支与版本管理

- repo: `/home/lizhijun/work/iEDA.ai`
- branch: `feat/parity-gp-session`
- HEAD（开始 A 时）: `6c98f2e feat: add JSON agent CLI and weighted local-candidate acceptance`
- 提交必须走: `./dev/branch_commit.sh -m "..." -- <explicit paths>`
- 只提交与本次任务相关的 `benchmarks/flows/run_gp_agent_search*` 和实际代码/结果改动；
  不要提交 build、/tmp、无关的 gcd 报告、重复 docs 等未跟踪文件。

## 1. 目标

- **A**：用 `gp_agent.py` 在 `s1238 / apb4_timer / picorv32 / aes` 四个设计上跑
  Agent 自主搜索矩阵，找到每个设计最优 GP 动作链：
  - parent ∈ `{20, 60, 100, 200, 400}`
  - scope ∈ `{global, longnet, hotspot, random, region}`（当前矩阵实现为后四种候选，global 是同源对照）
  - penalty ∈ `{0.0, 2.0, 5.0}`
  - 每个候选 budget=20，同 parent checkpoint 分支
- **B**：补 Innovus `-noPrePlaceOpt` 对照，确认 iEDA 的 GP-only HPWL 优势不是
  占了 Innovus 预放置优化的便宜。参考脚本：
  `/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/run_no_preopt.sh`
  和 `run_no_preopt_timing.sh`。需要时再做 timing 口径（目前 GP-only 主线先不做 timing）。

## 2. A 的执行方式

已有批量脚本：

```bash
cd /home/lizhijun/work/iEDA.ai
benchmarks/flows/run_gp_agent_search_all.sh
```

- 每个设计完成后写 `/tmp/gp_agent_search/<design>/search.json`
- 可安全重跑：已有 60 个 candidate 且 `ok:true` 的设计会自动 skip
- 单设计手工跑：

```bash
python3 benchmarks/flows/run_gp_agent_search.py \
  --design s1238 \
  --case-root /home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/s1238 \
  --workdir /tmp/gp_agent_search \
  --parents 20 60 100 200 400 \
  --scopes longnet hotspot random region \
  --penalties 0.0 2.0 5.0
```

结果判断：
- `search.json -> recommendation.winner_side` 才是 candidate 机制真正保留的一侧
  （`left_better` 保留 local，其余保留 global）。
- 同时把 recommendation 与 `benchmarks/results/innovus_gp_compare/<design>/result.json`
  里的 Innovus HPWL 比较。

## 3. 当前状态（2026-08-15 22:40，A/B 均已完成）

- 旧会话撞上下文前只写入了 `run_gp_agent_search.py`，未跑完整 A。
- 新会话修复并提交了这些 bug：
  1. `-scope_region` 矩形必须用 Tcl braces 包住：`{llx lly urx ury}`；
  2. recommendation 必须按 `candidate_verdict` 选 local/global；
  3. 无可行解时按 overflow 接近 target 排序，而不是只看 HPWL；
  4. `gp_agent.py advance/candidate/accept` 允许显式 `--checkpoint`，不强制已有 state 文件。
- A 的四个设计均完成 60/60 搜索矩阵，并已从 recommendation 的 winner checkpoint
  继续 `advance` 到 overflow<=0.1，得到最终动作链与 placement.def。
- B 的四个设计均完成 `-noPrePlaceOpt` 对照，结果写于
  `benchmarks/results/innovus_gp_compare_nodel/<design>/result.json`
  （该 results 目录被 `.gitignore` 忽略，不提交）。
- 相关提交：
  `4bd849c` 搜索脚本/批量脚本/续跑文档；
  `8b62052` 批量脚本数组默认值修复；
  `ffd565c` infeasible 排序策略；
  `d8459f6` noPrePlaceOpt 对照脚本；
  `ed2c042` gp_agent.py 显式 checkpoint 修复。

## 4. 换新会话续跑 Harness 的正确姿势

### 为什么旧会话死了

不是“上下文太长”一个原因，而是：
`messages 793355 + 本次 completion 预算 256000 = 1049355 > 1048576`。
`reasoningEffort: max` 会让 completion 预算顶到 256000，所以历史刚到 79 万就可能越界。

### 方法 1：优先在旧 Web 会话里 `/compact` 后继续

已经启用 web profile 的 compaction 与 `/compact` 命令：

```yaml
# ~/.dsh/profiles/web/cordis.patch.yml
- id: compaction-basic
  name: '@deepseek-ai/dsh-compaction-basic'
  disabled: false
  config:
    thresholdRatio: 0.7
    retainRatio: 0.12
- id: command-compact
  name: '@deepseek-ai/dsh-command-compact'
  disabled: false
```

重启 `dsh web`，打开原来那个会话，在空闲时输入：

```text
/compact
```

它会总结较旧历史并替换，成功后继续原来的会话即可。不要发普通消息，普通消息又要进入模型上下文。

### 方法 2：开一个全新会话（最稳）

新会话只给一句短任务，让它读本文件：

```bash
cd /home/lizhijun/work/iEDA.ai
dsh --profile headless \
  "阅读 benchmarks/flows/GPA_AGENT_SEARCH_RESUME.md，按其中的目标和当前状态继续执行 A 和 B；只读实际文件状态，不复述旧会话；用 dev/branch_commit.sh 做好版本管理；每个设计或阶段完成后写回该 md 的状态表。"
```

如果 web 端可交互，同样复制上面这句作为新会话第一条消息即可。

### 方法 3：降低 completion 预算（可叠加）

在 `~/.dsh/settings.yaml` 里把 `agent-default-model.reasoningEffort` 从 `max` 降为
`medium` 或 `low`，可明显降低 256000 的 completion 保留值；代价是长任务推理强度降低。
A 的批量实验脚本本身不需要 max reasoning。

## 5. 新会话开工 3 分钟检查清单

1. `cd /home/lizhijun/work/iEDA.ai && git status --short --branch`
2. `python3 -m py_compile benchmarks/flows/run_gp_agent_search.py`
3. 看四个 `/tmp/gp_agent_search/<design>/search.json` 是否存在且 candidate=60
4. 跑 `benchmarks/flows/run_gp_agent_search_all.sh`
5. 每完成一个设计，把 recommendation 写进本文件的状态表并 commit 脚本/结果
6. 最后收口 Innovus noPrePlaceOpt，更新本文件并给用户总结

## 6. 状态表（完成后填写）

| design | search.json | 最终动作链 | agent 最终 HPWL / overflow | 旧口径 vs Innovus | noPrePlaceOpt 口径 vs Innovus |
|---|---|---|---|---|---|---|
| s1238 | 60/60 | parent400 -> longnet global -> +3 iters（总 iter 423） | 5,824,826 / 0.0995 | 25.7% 优势 | 17.1% 优势 |
| apb4_timer | 60/60 | parent400 -> longnet global -> +70 iters（总 iter 490） | 14,851,106 / 0.0992 | 15.5% 优势 | 14.2% 优势 |
| picorv32 | 60/60 | parent400 -> longnet global -> +61 iters（总 iter 481） | 230,930,871 / 0.0999 | 24.2% 优势 | 15.2% 优势（session-520-fallback, ov=0.1203） |
| aes | 60/60 | parent400 -> longnet global -> +91 iters（总 iter 511） | 639,089,254 / 0.1000 | 27.2% 优势 | 9.5% 优势 |

注：agent 最终 HPWL 是 GP 内部值；`placement.def` 用共同 evaluator 复核的 HPWL 为
s1238=5,957,257，apb4_timer=15,715,072，picorv32=234,280,119，aes=665,002,127。
