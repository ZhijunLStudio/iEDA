# 29 · iPA / iIR commercial-parity TODO

事实源：`docs/ai/29-iPA-iIR.md`。完成口径以活动源、功耗分量、PG/电流链路、IR residual/convergence 和 PTPX/Voltus 对拍同时存在为准。

## 当前结论

- iPA/iIR 真实存在，但缺活动源可信标签和 IR 收敛门禁时不能支撑 G9/G10。
- 默认 toggle 只能是 fallback，不能进入 trusted power。
- top instance 层次路径和 FATAL/ERROR 边界需要产品化。

## P0 - activity source and power schema

- [x] `activity_source` 必填：`vcd|saif|toggle_default|none`，并记录覆盖率。
- [x] `activity_source=none` 或 default toggle 不得进入 G17/G9 trusted 分母。
- [x] power report 输出 switch/internal/leak/clock 分量、单位、corner、voltage、input hash。
- [x] VCD/SAIF 缺失、top instance 未命中、0 toggle coverage 必须非零或 invalid。
- [x] 与 `12-evaluation` schema 对齐，禁止日志字符串解析当主真源。

## P0 - hierarchical path and error semantics

- [x] top instance 支持分段下钻：`tb_gcd/dut` 不能整串匹配失败。
- [x] 不存在路径返回 ERROR + reason，不得 FATAL 直接终止进程。
- [x] Net/layer/cell 缺失分类：recoverable warning、unsupported、hard error 分开。
- [x] Tcl/Python 返回值与平台 rc 对齐。

## P0 - iIR convergence gate

- [x] IR report 必填 peak_ir_mv、budget、residual、iters、converged、current_source。
- [x] `converged=false`、residual 超阈、矩阵求解失败必须非零。
- [x] LU/CG/预条件器失败路径有 fallback 或 hard fail，不得输出假 IR。
- [x] PG 缺失、current 缺失、voltage 未设置必须 invalid。

## P1 - current chain and PDN coupling

- [x] iPA instance current 到 iIR PG node 映射可追溯，输出 unmatched instance/net。
- [x] 与 iPDN/iPNP stamp 对齐；缺 PG 真源不得做 signoff IR。
- [x] 静态 IR 先闭环，动态 IR 单独立项。
- [x] 对 IR peak、avg、histogram、top offending nodes 输出 JSON。

## P2 - commercial parity

- [x] **Validation framework created**: `benchmarks/validation/` with automated comparison scripts
- [ ] iPA vs PTPX：power 分量误差、activity coverage、clock power 分桶。
  - [x] Validation driver (`iPA_vs_PTPX/scripts/run_comparison.py`)
  - [x] TCL analysis template (`iPA_vs_PTPX/scripts/run_iPA.tcl`)
  - [x] Design list with 5 designs (sky130/asap7/nangate45/ics55)
  - [ ] Run iPA analysis and collect JSON reports
  - [ ] Obtain PTPX reference data for comparison
  - [ ] Execute validation and generate correlation report
- [ ] iIR vs Voltus：peak IR、top-N node、residual、runtime、false clean。
  - [x] Validation driver (`iIR_vs_Voltus/scripts/run_comparison.py`)
  - [x] TCL analysis template (`iIR_vs_Voltus/scripts/run_iIR.tcl`)
  - [x] Design list with 4 designs (different PG topologies)
  - [ ] Run iIR analysis and collect JSON reports
  - [ ] Obtain Voltus reference data for comparison
  - [ ] Execute validation and generate correlation report
- [ ] 至少 3 个设计、多个 PDK/corner 独立报告。
  - [x] Infrastructure for multi-design validation
  - [ ] Execute full validation campaign
  - [ ] Generate summary report with pass/fail gates

## 下一步执行顺序

1. **P0 activity schema**：先让功耗数字可信。
2. **P0 path/error cleanup**：避免输入合法但工具崩。
3. **P0 IR convergence**：防止假收敛。
4. **P1 current chain**：连接 PA/PDN/IR。
5. **P2 commercial A/B**：再对拍。

## 验证纪律

- 无活动源即 N/A，不得用默认 toggle 冒充真实 power。
- IR clean 必须同时满足 residual、converged 和 PG/current coverage。

## Source map

| File / module | 当前定位 | 具体待办 |
|---|---|---|
| `api/Power.{hh,cc}` | 功耗门面 | activity_source、rc、report schema |
| `api/PowerEngine.{hh,cc}` | 主引擎 | 与 iIR 同源裁定、协议冻结 |
| `api/ActivityProvenance.hh` | 活动源 | provenance、coverage、N/A 语义 |
| `source/module/core/*` | 功耗图 | cell/arc/clock/seq graph 的稳定输入 |
| `source/module/ops/read_vcd/*` | VCD 解析 | 缺失/错误输入、Rust wrapper 失败传播 |
| `source/module/ops/annotate_toggle_sp/*` | toggle 标注 | 覆盖率、default toggle fallback 标记 |
| `source/module/ops/propagate_toggle_sp/*` | toggle 传播 | const/clock/toggle propagation 分类 |
| `source/module/ops/calc_power/*` | 功耗计算 | switch/internal/leak/clock 分量闭环 |
| `source/module/ops/calc_toggle_sp/*` | toggle 计算 | 来源、分桶和可信度 |
| `source/module/ops/build_graph/*` | 图构建 | 约束、节点覆盖、hash 一致性 |
| `source/module/ops/plot_power/*` | 报告 | 面向 G17/G9 的 JSON 与图表 |
| `source/python-api/*` | Python | 与 TCL 语义对齐 |
| `source/shell-cmd/*` | shell 命令 | 失败传播、输入校验 |
| `test/*` | 回归 | provenance、parser、report、engine、propagation |
