# 配置外部研究输入

`paired-plan.json` 是 12 设计、72 episode 的计划模板。门控默认关闭，不能直接作为已通过工程检查的正式实验。`gateway_base_url` 是占位地址，必须改为你已有 DSH headless 配置中的地址后再冻结；不在 Git 保存凭证。

`materialize_study.py` 还需要调用者提供以下文件和目录：

- `suite.json`：固定求解器、设计输入、工艺和测量辅助脚本的路径及 SHA。
- `experience.json`：每个设计的同等先验；配方来源结果也必须可核查。不得提供免费候选坐标。
- `references/<design>/{ieda,inn}/attempt-1/result.json` 及对应参考 DEF：两方都须使用同一原始网表、floorplan 和约束，并经过独立测量。
- 正式门控证据：准备好后才将正式计划设为 `formal_gate=open`，配置 `gate_evidence={path,sha256}`。不能靠手工修改结果为通过来开启门控。

`suite.json` 的必需结构与运行代码对应：

| 字段 | 内容 |
|---|---|
| `solver`, `original_solver` | `{path,sha256}`，固定当前与原始 iEDA 二进制 |
| `helpers` | 三个辅助脚本的 `{path,sha256}`；SHA 见 `../helpers/provenance.json` |
| `frozen_inputs` | 其他冻结文件描述符列表 |
| `designs.<name>` | `input_def`, `pl_config`, `sdc`, `tech_lef`, `macro_lef`, `cell_lefs[]`, `libs[]`, `inn_def`, `clock_period_ns`, `routing_layer_1st` |
| `design_order`, `holdout_designs` | 冻结设计顺序与保留集 |

输入文件、二进制、库和 LEF 均由你在 Git 外准备。所选测量辅助脚本必须与 suite 声明的 SHA 相同；装配器默认使用本包的 `helpers/`，也支持显式 `--helpers`。

工程检查中的 AES/Salsa 交换与路径守卫对照还需要原始工程夹具。通过 `IEDA_PL_FIXTURE_ROOT` 指向包含 `aes/result.json`、`salsa20_sky130_a/result.json` 的目录；结果所引用的 DEF、路径证据等资产也必须存在。这些夹具只用于技术检查，不注入控制器。其余归档收尾脚本需要原始 master 协议目录，不能用这里的模板冒充历史实验证据。

重新冻结当前代码形成一项新的实验。历史 72 次实验使用的准确源码 SHA 和结果见 `../experiments/validation-v1/`；发布整理后的代码没有替换历史源码，也没有自动启动新的物理或模型实验。
