# pl_micro v0.5：DSH 布局微工具与验证运行时

这个独立插件让 DSH 从原始 DEF 出发，控制 GP 阶段、合法化、DP、RUDY 交换、评价和交付。它不依赖旧 `pl_micro` 或其他未提交的 `ipl_tools` 探索代码。内核、设计数据和全量实验会话在 Git 外。

历史验证结论是 **validation_incomplete**：agent 未达到预设泛化胜率门槛，且一条规则运行超出 CPU 预算。当前代码包含后端收尾修复；这些修复和本次发布整理不被冒充为已经重新跑过历史72次。详见 [结果与边界](experiments/validation-v1/README.md)。

## 工具接口

所有工具通过同一个持久布局 actor 执行；模型仅能调用这八个工具。

| 工具 | 输入与用途 | 输出 |
|---|---|---|
| `pl_observe` | 摘要；按候选/路径/端点/网络等查询，可分页 | 状态、指标、余量、预算和过滤原因；缓存查询不新增 STA |
| `pl_start` | GP 配置、请求步数 | 独立分支和不可变检查点 |
| `pl_advance` | 父检查点、步数、反馈/范围 | 可暂停的后续检查点及实际迭代数 |
| `pl_restore` | 已有检查点 | 零 GP 步恢复后的原始 DEF 字节证明 |
| `pl_legalize` | 检查点、是否 DP、立即/延迟评价 | 已测候选或待评价 proposal |
| `pl_refine` | 合法父点、DP 或 RUDY 交换 action、评价时机 | 移动证明、proposal、交换前缀；可选完整评价 |
| `pl_evaluate` | `proposal_id` | 身份、合法性、完整七轴、资格和父子差异 |
| `pl_finish` | 合格候选、类型化停止理由 | 显式最终 DEF、SHA、指标和已测动作/预算证据 |

DP 的 `max_selected_cells` 通过冻结补集落实，返回实际移动数与最大位移；`strength` 仅表示网络权重。RUDY 搜索分别限制接受交换数、内部邻居试验、守卫和评价频率，每个接受前缀都可独立评价。未完整评价或不合格的状态不能交付。路径/RC 守卫仅为部分搜索过滤器。

七轴为 HPWL、RUDY64 peak/overflow、HPWL-RC setup/hold WNS/TNS。时序来自原生 `clock_timings` 聚合，观测路径的64条上限不用于聚合。它们都是布局阶段代理，不构成真实布线或签核结论。

## 包内内容

- `lib/`、`cordis.patch.yml`：DSH 原生工具注册与条件参数契约。
- `runtime/`：布局 actor、持久 GP、事务、缓存、预算、规则、无头运行、评价和归因。
- `helpers/`：与历史验证 SHA 完全一致的三个测量辅助脚本。
- `validation/`：纯打包/契约测试及需要外部设计资产的物理回归。
- `native/`：已验证内核的最小来源补丁和 SHA；没有二进制或构建目录。
- `examples/`：默认关闭门控的计划模板与输入说明。
- `experiments/validation-v1/`：精简协议、数值表和来源 SHA；没有会话、提示、DEF、PDK 或凭证。

`legacy_backend.py` 是当前 actor 的继承依赖，不能按文件名当成废代码删除。`execute_validation.py` 和收尾脚本也保留了原研究协议的目录约定，完整重放需要外部原始归档。旧归因器的 `unqualified_measurements` 会重复计算 finish/缓存响应；分析计数使用 `audit_mechanism_usage.py`，不以该旧字段支持结论。

## 依赖和安装

已验证环境：Linux、Python3.10.12、Node24.19.0、DSH0.2.1-rc.2；Python版本固定依赖见 `runtime/requirements.txt`。原生 actor 子进程使用 `/usr/bin/python3`、`/usr/bin/node`，依赖必须对这些解释器可见。需要 Linux `/proc`、Unix socket 和 `taskset`。

```bash
/usr/bin/python3 -m pip install --user -r runtime/requirements.txt
npm install --global --prefix "$HOME/.npm-global" @deepseek-ai/dsh@0.2.1-rc.2
```

DSH 提供 `@deepseek-ai/dsh-tools`。每个 episode 的装配器会建立独立 profile 和运行时 node_modules 链接，不将它们写入 Git。

先在自己的 DSH `headless` profile 配置网关和凭证引用。计划必须显式声明 `gateway_base_url`，与 `~/.dsh/profiles/headless/cordis.patch.yml` 中 `llm-deepseek.config.baseURL` 一致；支持 HTTP(S) `/v1` 地址，禁止在 URL 中嵌入凭证。凭证仅从对应环境变量或本机 DSH 凭证存储读取，不写入源码或计划。实验始终固定 `deepseek-flash / max / native`，没有备用模型。

## 装配和运行

先按 [输入说明](examples/README.md) 准备真实输入、参考、先验和工程门控，再创建不存在的新目录：

```bash
/usr/bin/python3 materialize_study.py \
  --output /path/to/new-study \
  --suite /path/to/suite.json \
  --plan /path/to/paired-plan.json \
  --experience /path/to/experience.json \
  --references /path/to/references
```

装配器核对输入及所选 helper 的 SHA，复制运行时并生成 `study-lock.json`，拒绝覆盖已有目录。正式门控关闭或证据不一致时，运行会拒绝启动。默认采用包内 `helpers/`；可通过 `--helpers` 指定同 SHA 的外部目录。

```bash
/usr/bin/python3 /path/to/new-study/run_policy_study.py --workers 4
/usr/bin/python3 /path/to/new-study/analyze_policy_study.py \
  --output /path/to/new-study/analysis-v1
```

每个 ID 只尝试一次。已有失败不能静默重开，续跑只恢复同 session/actor/deadline，不重置预算。每个 episode 独立缓存；指纹覆盖网表/DEF、库、LEF、SDC/负载、角、内核、代码、配置和加载环境。搜索、失败、no-op 与缓存命中仍记录真实费用。单个原生进程限制在一个逻辑 CPU；计量含 actor 与原生子进程 CPU，API/墙钟与独立审计费用分列。

主结果是一份实际 `pl_finish` 交付。三次 agent 的中位数按冻结最差 Inn 正差距、差距总和选取一次真实运行，不能逐轴拼接或汇总最优候选。已测最优曲线仅用于诊断。规则追赶必须核对实际计算量，预算上限提高不代表费用已追平。

## 检查

以下命令从临时干净副本执行：Python/JSON 语法、八项配置与冻结依赖测试、队列、所属进程清理，以及十个历史错误参数的 DSH 前端回放。不会运行 EDA、读取凭证或访问模型。

```bash
/usr/bin/python3 validation/check_package.py
```

`--dsh-install` 可指定已安装的 DSH0.2.1-rc.2 根目录。完整物理回归另需 [外部夹具与原归档](examples/README.md)，不能用纯打包检查代替这些回归。

## 固定内核和已知边界

本轮验证的内核 SHA 为 `f3f62b12432225494c0506bd4be934ff9da7d5b27d07d3c45e82175568885ec4`，要求 `live_instance_materialization_v2` 检查点语义，只开放 GP 反馈0/3/4。`native/validated-kernel.json` 的路径是历史归档位置，不是新机器的安装默认值；执行时由 suite 显式提供路径和 SHA。最小补丁针对指定源版本，不能宣称适用于任意 iEDA checkout，也不改变当前工作区的其他原生源码。

历史 AES 粗规则实际CPU3615.508秒，超过3600秒。工作副本已将大 DEF 发布改为线性拼接并检查预算；33338处发布与39621处冻结均验证字节等价。另修复了原生预算截断原因丢失的问题。独立110CPU回归九项通过，实际100.465秒、2次新STA、无所属进程残留。历史失败不因此被替换。

发布整理仅增加显式网关配置、冻结选中 helper/参数夹具、可携带测量脚本和无模型检查。未改动布局算法、放宽七轴资格或修改原始实验结果；没有自动启动新的72次运行。
