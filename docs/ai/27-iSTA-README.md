# iSTA 商业对标与 AI 研究 - 文档导航

> 更新：2026-07-23
> 规则：本文只作导航。规范性门禁依次来自 `00`、`04`、`27-iSTA.md`；benchmark 的 AI/ML 章节和 HTML 看板是研究草图，未实测数字不得当作现状或承诺。

## 1. 文档结构

### 核心技术方案

- [`27-iSTA.md`](27-iSTA.md)：rv2.1，iSTA 代码审计、确定性 STA/PBA/MCMM/增量 LLD、PT 联合相关性门禁和 Innovus in-design 调用路线。
- [`04-ppa-technical-review-and-optimization-rv1.md`](04-ppa-technical-review-and-optimization-rv1.md)：跨工具 DesignState/DirtySet/MoveTxn、G7 联合指标、性能和 AI 保护边界。

### Benchmark 计划

- [`27-iSTA-benchmark-plan.md`](27-iSTA-benchmark-plan.md)：输入/设计/PDK 分层、RC/cell/net/path 对拍和回归脚本草图。
- §1/§2/§4/§5 是 benchmark 工作计划；§3 是研究 backlog，不是 G7 的实现路线。

### 可视化草图

- [`27-iSTA-visualization.html`](27-iSTA-visualization.html)：历史可视化页面。
- 页面中 AI 加速比、模型精度和里程碑数字未有 artifact 证明时均为假说；最终看板应从 schema 化 JSON 生成，不能手填状态。

## 2. G7 联合门禁

`R² > 0.98` 保留为诊断项，但不能单独通过 G7。每个 scenario/check type 至少同时报告：

| 维度 | 指标 | 初始规则 |
|---|---|---|
| 输入/约束 | input hash、constraint coverage、unsupported | 支持清单内 100%；unsupported 拒绝 |
| endpoint | matched coverage | ≥99%，未匹配逐项归因 |
| 绝对误差 | `|ΔWNS|`、signed bias、MAE/P95/max | WNS ≤10 ps、bias ≤5 ps；其余 Phase 0 冻结 |
| 临界安全 | PT slack≤guardband 的 false-negative | 0 |
| 排序 | top-K precision/recall、NDCG@K | P/R ≥0.95；K 由协议冻结 |
| 分解 | cell/net/clock/CPPR/constraint bucket | P50/P95/max 独立报告 |

路径匹配主键包含 scenario、setup/hold、rise/fall、startpoint/endpoint、launch/capture clock 和 edge。pin Jaccard 只能作次级匹配。

## 3. In-design 指标

| 指标 | 目标用途 |
|---|---|
| ECO dirty cone / full graph | 证明增量范围有效 |
| incremental / full wall time | 证明高频调用收益 |
| 锥外 slack 漂移 | 漏失效检测 |
| iTO 中 STA 墙钟占比 | 端到端热点归因 |
| 每 N 批 full rescore 差异 | 增量 oracle |
| 1/2/4/8/16 threads | 可扩展性和 Amdahl 归因 |

estimate/in-design/correlated 三档共享同一 DesignState、单位、SDC 语义和确定性 graph。禁止新增平行的第五套 timing stack。

## 4. AI/ML 边界

允许：候选路径/优化动作排序、参数策略、误差 bucket 推荐、早期 surrogate。

强制保护：

- 按 design family + PDK 切 holdout，禁止同设计 path 随机泄漏。
- 输出 uncertainty/calibration/OOD，分歧或 guardband 内回落确定性 STA。
- AI 不自动增加 false/multicycle path，不修改签核约束，不替代 full rescore。
- NN 必须比较包含数据准备、拷贝和启动开销的端到端延迟；不能预设比 Liberty LUT 快。
- learned correction 先排除单位/SDC/RC/拓扑错误，只能作有界、可关闭的 residual。

以下旧结论已撤销：`Cell Delay 40x`、`GNN 20x`、`SDC 12x`、`50ps→5ps`。在受控 runner 和 holdout artifact 出现前，它们都不是事实。

## 5. 实施顺序

```text
M0 input/build/artifact manifest + PT path alignment v2
 → M1 单位/约束/RC/cell/net/clock/CPPR 分桶归因
 → M2 dirty-cone incremental + full oracle
 → M3 top-N PBA + MCMM scenario manager
 → M4 accuracy-latency curve + in-design 接入
 → M5 可选 AI ranking/surrogate，受 uncertainty 和 exact fallback 保护
```

每一阶段必须输出当前 binary SHA-256、输入/产物 hash、运行配置、覆盖清单和机器可判定结果。

## 6. 当前状态

- 代码能力与缺口以 `27-iSTA.md §1/§4` 为准。
- 商业并排基线、联合门禁 schema 和 AI 性能收益尚未在本导航中验证。
- benchmark runner 尚未落地的命令必须继续标“待开发”，不能用文档代码块冒充可运行脚本。
