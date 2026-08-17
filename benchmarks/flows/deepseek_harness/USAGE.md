# 在 DeepSeek Harness 里使用 iEDA GP 插件

插件包 `@ieda-ai/dsh-tool-ieda-gp` 是一个 bundle，注册后模型会看到
**8 个工具**，不是一个“传参数的大工具”。每个工具都是独立函数，参数由
Harness 的 `defineTool` 做 schema 校验。

## 工具清单

| 工具 | 作用 | 关键参数 |
|---|---|---|
| `ieda_gp_baselines` | 列出 4 个设计/PDK、Innovus baseline、iEDA 当前最优 | 无 |
| `ieda_gp_start` | 新开一个 GP session | design, workdir, iterations, seed, random_init, target_density, congestion_effort, seed_anchor_strength |
| `ieda_gp_candidate` | 同 checkpoint 跑 local-vs-global 双分支并给安全 verdict | design, workdir, checkpoint, iterations, scope, halo_*, overflow_penalty, scope_density_* |
| `ieda_gp_advance` | 把 session 继续推到 overflow target | design, workdir, iterations, checkpoint |
| `ieda_gp_accept` | 把 winner checkpoint 提交并写 `placement.def` | design, workdir, checkpoint |
| `ieda_gp_report` | 看 session state、ledger、checkpoint | workdir |
| `ieda_gp_eval_def` | 对 DEF 跑统一 HPWL 脚本并与 Innovus 比较 | design, def_path |
| `ieda_gp_full_compare` | 一键跑 GP→LG→DP 全流程并比较 Innovus | design, result_root, timing |

## 在 Web UI 怎么用

直接自然语言说即可，模型会自己选工具。例如：

> 先调用 `ieda_gp_baselines`，告诉我哪个设计相对 Innovus 提升最大。

模型实际会调用 `ieda_gp_baselines`。

要拿一个可交付 placement：

> 对 s1238 做完整搜索：
> 1. 用 `/tmp/gp_demo` 作为 workdir 调用 `ieda_gp_start`，iterations=60，seed=42；
> 2. 调用 `ieda_gp_candidate`，iterations=20，scope=longnet，active_count=100；
> 3. 如果 verdict 是 left_better 就用 local checkpoint，否则用 global checkpoint 继续；
> 4. 调用 `ieda_gp_advance`，iterations=200；
> 5. 调用 `ieda_gp_accept`；
> 6. 对 workdir 下生成的 placement.def 调用 `ieda_gp_eval_def`。

## 在命令行 headless 怎么用

```sh
export PATH="$HOME/.npm-global/bin:$PATH"

dsh --profile headless \
  "Call ieda_gp_baselines and report the design with the largest improvement."
```

注意 headless profile 也要注册过插件。本机已经注册。

## 一键完整对比（最稳）

如果只是想验证 iEDA 比 Innovus 好：

> Call `ieda_gp_full_compare` with design=s1238, result_root=/tmp/gp_compare, timing=true.

模型调用工具后会得到：

```json
{
  "design": "s1238",
  "ieda_full_hpwl": 5745273,
  "innovus_nodel_hpwl": 7417394,
  "improvement_pct": 22.543
}
```

## 输出位置

- GP session 状态/账本：`<workdir>/gp_agent_state.json`、`<workdir>/pl/gp_experiments.jsonl`
- candidate 双分支：`<workdir>/pl/gp_candidate_local.json`、`gp_candidate_global.json`
- 提交后的 placement：`<workdir>/placement.def`
- 全流程结果：`<result_root>/<design>/result.json`
- timing 评估：`<result_root>/<design>/timing_eval/timing_result.json`

## 参数注意

- `workdir` 必须是绝对路径；每次独立搜索用新目录。
- `scope` 可选 `global/hotspot/random/instances/region/longnet`。
- `scope_region` 是字符串 `"llx lly urx ury"`，例如 `"56879 12325 59352 14790"`。
- candidate 的 `checkpoint` 不填时使用 workdir 最新 checkpoint；填了就从指定
  checkpoint 分叉。
- 搜索完成后必须 `ieda_gp_accept` 才能得到 DEF；checkpoint 只是会话快照。
