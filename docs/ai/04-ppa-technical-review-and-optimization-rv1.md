<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 04 · iEDA 商业 PPA 对标 · 技术评审与优化路线 · rv1.0

> 日期：2026-07-23
> 性质：对 `00`、`10`–`42`、`50` 的横向技术评审；本文件定义跨工具优先级、算法闭环和实验纪律，各模块 LLD 仍以对应子文档为落点。
> 目标：在限定且冻结的产品工作负载上，用可复现证据逐步接近商业实现工具的功能、PPA、容量和运行时间。
> 纪律：没有基线的收益数字都是假说；AI 只能提出候选或近似，不能绕过物理不变量、签核工具或完整性门禁。

---

## 0. 评审结论

### 0.1 总体判断

现有方案的正确主线是：苹果对苹果协议、签核相关性、实现链 QoR、性能/规模、响亮失败。主要问题不在缺少想法，而在以下五点：

| # | 问题 | 风险 | 本版处理 |
|---|---|---|---|
| R1 | 目标写成“全面商业对标”，未冻结首个产品切片 | 功能面无限扩张，任何排期都失真 | 冻结首个产品切片、支持矩阵和 D0–D4 证据等级 |
| R2 | `R²`、总电容误差、端到端墙钟等单指标被当作充分条件 | 整体偏移、关键路径漏报、局部 RC 错误可能被掩盖 | 改为覆盖率、偏差、分位数、排序、最坏值联合门禁 |
| R3 | 各工具有算法计划，但缺少统一的增量状态和事务语义 | iTO/iCTS/iRT 各自重建 STA/RC，性能和一致性都失控 | 建立 DesignState、DirtySet、MoveTxn 和统一 oracle |
| R4 | 性能方案偏重计时脚本，尚未把热点映射到数据结构和算法 | “加 OpenMP”容易受内存带宽、锁和重复计算限制 | 按复杂度、内存局部性、增量、并行四层优化 |
| R5 | AI 计划把排序精度、多模型投票和 learned correction 说得过强 | 训练泄漏、相关错误和 OOD 设计会产生高置信错误 | AI 降为候选排序/调参/归因层，确定性内核负责验收 |

### 0.2 保留、重写、后置

| 处理 | 内容 | 原因 |
|---|---|---|
| **保留并前置** | parity protocol、G14 响亮失败、iSTA/PT 与 iRCX/StarRC 归因、逐设计独立门禁 | 是所有 QoR 结论的可信基础 |
| **重写判据** | G7、G8、G17、G21；AI order accuracy；性能 A/B | 当前单指标不能证明等价 |
| **优先实现** | 统一增量 STA/RC、iPL 合法/拥塞闭环、iRT negotiated congestion、iTO 事务否决 | 对 PPA 和运行时间同时有杠杆 |
| **后置** | POCV/LVF 全量签核、动态 IR、全规则 LVS、mesh CTS、RL 直接改版图 | 首个产品切片依赖大、验证成本高 |
| **停止宣称完成** | 含 placeholder、只有标题或仅有伪代码的 `rv2.0` 文档 | 文档成熟度必须由证据产物决定 |

### 0.3 首个产品切片

第一阶段不要声称替代完整 Innovus/ICC2/PrimeTime/Calibre。建议冻结为：

```text
输入       : 门级 Verilog + LEF/DEF + Liberty NLDM + SDC + 单/双角 SPEF
设计       : 单电压域、标准单元为主、有限硬宏、无 analog/custom device
实现       : floorplan/place/CTS/route/post-route timing opt
分析       : GBA + CPPR + top-N PBA；2.5D RC；in-design DRC 子集
输出       : DEF/Verilog/SPEF/报告；GDS 仅在 round-trip 清单覆盖后承诺
不承诺     : 完整 UPF、全套 advanced-node DRC、signoff SI/POCV/LVF、full-chip LVS
```

超出切片的输入必须返回 `unsupported` 和覆盖清单，不能静默降级。

---

## 1. 计划治理：版本号不代表成熟度

### 1.1 统一成熟度

每项能力按证据标注，不再用文档标题中的 `rv2.0` 推断完成度：

| 级别 | 定义 | 必需证据 |
|---|---|---|
| D0 | 想法/占位 | 只有描述、placeholder 或空目录 |
| D1 | 代码路径存在 | 可定位入口和内核，边界未测 |
| D2 | 单元可信 | 有微基准、边界用例、失败语义 |
| D3 | 流程可用 | 至少 3 个设计端到端，产物契约完整 |
| D4 | 对标可信 | 冻结协议下与商业金标并排，跨设计/PDK 通过 |

状态表必须包含 `code_ref`、`test_ref`、`artifact_ref`、`binary_sha256` 和 `measured_at`。没有这些字段时最高只能是 D1。

### 1.2 文档优先级

发生冲突时按以下顺序处理：

1. `00`：产品目标和门禁编号。
2. 本文 `04`：跨工具技术决策、算法顺序和实验口径。
3. `10`–`42`：模块 LLD、接口和工作包。
4. `51`：Agent-native Timing Closure Lab 的 snapshot/delta/transaction/tool contract 工程化展开；继承 1–3 的物理门禁。
5. `50`、benchmark AI 章节：研究轨，不能放宽 1–4 的正确性门禁。
6. 会议纪要、backup、`Untitled`：背景材料，不作为实现规范。

---

## 2. 验收协议修订

### 2.1 基准分层

| 集合 | 规模与用途 | 频率 | 规则 |
|---|---|---|---|
| smoke | 2–3 个微型设计，覆盖解析/命令/失败语义 | 每 PR | 不用于宣称 PPA parity |
| daily | 至少 5 个 S/M 设计，覆盖宏、时钟、高扇出、拥塞 | 每日 | QoR + 正确性；性能只在受控 runner |
| weekly | 10–20 个设计，跨设计族和至少 2 个 PDK | 每周 | 防参数过拟合 |
| scale | 50 万、100 万及更大实例的阶梯 | 每周/里程碑 | 报告复杂度拐点、RSS、失败原因 |
| holdout | 未参与调参的设计族或 PDK | 里程碑 | AI/经验参数能否泛化的唯一证据 |

同一个 RTL 在不同 PDK/综合策略下不是完全独立样本。汇总时必须同时报告“设计族数”和“派生实例数”。

### 2.2 Parity protocol 必填项

除 `00 §1bis` 外，协议增加：

```text
输入哈希       : netlist/sdc/lib/lef/def/spef/tech/upf 的 sha256
工具身份       : binary_sha256 + build manifest + dirty flag；不能只写 git HEAD
场景           : mode/corner/RC corner/analysis type/derate/CPPR/SI/PBA
硬件           : CPU model/microcode/NUMA/RAM/kernel/compiler/build flags
资源           : threads/affinity/memory limit/license wait policy
计时边界       : 是否含启动、解析、I/O、license wait、checkpoint
随机性         : seed、确定性模式、重复次数
覆盖清单       : SDC/Liberty/LEF58/DRC rule 的 checked/skipped/unsupported
产物身份       : 每阶段 DEF/netlist/SPEF/report 的 sha256 与生成者
```

### 2.3 G7 STA 相关性

`R² > 0.98` 只能保留为诊断项，不能单独通过 G7。建议的初始联合门禁如下，Phase 0 可基于噪声收紧：

| 维度 | 指标 | 初始门槛 |
|---|---|---|
| 覆盖 | matched endpoints / PT endpoints | ≥99%；未匹配逐项归因 |
| 约束 | clocks/exceptions/disabled arcs checked | 支持清单内 100%，unsupported 必须拒绝 |
| 绝对值 | `|ΔWNS|`、signed bias、MAE、P95 `|Δslack|` | WNS ≤10 ps；bias ≤5 ps；MAE/P95 经 Phase 0 冻结 |
| 临界安全 | PT slack ≤ guardband 的 false-negative 数 | 0 |
| 排序 | top-K precision/recall + NDCG@K 或 Kendall tau | top-K P/R ≥0.95；不能只报 overlap |
| 分解 | cell/net/clock/CPPR/constraint bucket | 每个 bucket 单独报 P50/P95/max |
| 场景 | setup/hold × rise/fall × scenario | 不允许只用总体均值遮蔽最差场景 |

路径匹配键优先使用 `(scenario, check_type, startpoint, endpoint, launch/capture clock, edge)`；pin 序列 Jaccard 只能作为次级匹配，不得把不同 exception 下的路径合并。

### 2.4 G8 RCX 相关性

总电容一致不能证明时延一致。G8 至少包含：

| 层 | 指标 | 归因维度 |
|---|---|---|
| 元件 | ground C、coupling C、wire R、via R | layer、width/space、length、via type、fanout |
| 拓扑 | 节点/支路覆盖、open/short、reduced model 误差 | net class、跨层数、树深 |
| 网络 | total C、effective C、driver-to-sink Elmore | P50/P90/P95/max + 绝对误差下限 |
| 时序 | 同一 STA 读取两份 SPEF 后的 slack delta | critical/noncritical 分桶 |

相对误差在接近零的小电容/电阻上会发散，schema 必须同时保存绝对误差和 `abs_floor`。校准集与 holdout PDK/几何 pattern 分离。

### 2.5 G17 PPA

PPA 采用“硬约束 + Pareto 比较”，不把 WNS、面积、功耗压成单个分数：

1. 先满足 legality、connectivity、DRC、setup/hold guardband、产物完整性。
2. 对可行解比较 `(WNS, TNS, area, power, wirelength, vias)` 的 Pareto 支配关系。
3. 每个设计独立通过；总体几何均值只用于趋势，不用于掩盖失败设计。
4. WNS/TNS 接近 0 时使用绝对 ps 门槛；禁止除以 0 或对负 slack 直接算相对百分比。
5. 功耗必须冻结 activity、clock propagation、voltage、temperature 和库模型；否则为 N/A。

### 2.6 G21 性能

性能门禁使用每个配置至少 5 次有效重复的 median，并报告 MAD/置信区间。冷启动和热缓存分开；商业工具与 iEDA 的 stage 名称先映射为共同大阶段，不能把不可比的细粒度 stage 强行相除。

峰值内存优先使用 cgroup v2 或独立子进程的 `memory.peak`。`VmPeak/VmHWM` 是进程生命周期高水位，不能直接归因给后续嵌套 stage。CPU 时间使用 `getrusage` 差值；二进制身份使用 SHA-256。

---

## 3. PPA 闭环总体架构

### 3.1 单一设计状态

```text
                    immutable InputManifest
                             │
                             ▼
  iDB objects ── DesignState(version, units, scenario, provenance)
      │                      │
      │ move                 ├── DirtySet{inst,pin,net,region,scenario}
      ▼                      ├── ArtifactIndex{DEF,SPEF,report,hash}
  MoveTxn ── commit/rollback └── Coverage{checked,skipped,unsupported}
      │
      ├── IncrementalRC(dirty nets + geometric halo)
      ├── IncrementalSTA(dirty timing cone × active scenarios)
      ├── IncrementalLegalize(changed instances + halo)
      └── IncrementalRoute(changed nets + conflict region)
```

所有优化动作必须是事务：`propose → cheap screen → apply in txn → incremental or exact evaluate → accept/rollback → emit reason`。工具不能只改自己的私有副本再让下游猜状态。

### 3.2 双精度不是双实现

同一确定性内核提供两档配置：

| 档位 | 用途 | 允许的近似 | 必须保持 |
|---|---|---|---|
| estimate | placement/route/opt 高频查询 | 简化 RC、局部场景、GBA、较小搜索预算 | 单位、约束语义、对象 ID、误差上界、可回落 |
| signoff-correlated | 阶段终局和 parity | 完整场景、SPEF、PBA/CPPR、覆盖清单 | 与金标的联合门禁 |

禁止维护第二套图、第二套单位或第二套 SDC 语义。estimate 档应是同一 API 的策略配置和只读视图。

### 3.3 闭环顺序

```text
legal/connectivity
  → DRV(max cap/slew/fanout)
  → setup
  → hold
  → route/DRC repair
  → full RC + full STA rescore
  → area/power recovery
  → final route/DRC/STA
```

每一轮设置 change budget、墙钟 budget、无改善窗口和 rollback budget。任何一项硬约束变坏都触发回滚或进入明确的 repair 状态。

---

## 4. 底层技术与算法优化

### 4.1 iDB / platform：性能地基

| 主题 | 建议实现 | 复杂度/收益来源 | 验证 |
|---|---|---|---|
| 对象身份 | 64-bit stable ID + generation；名字只作索引 | 增量更新不因指针失效全量重建 | 删除/回滚/序列化后 ID 一致 |
| 热数据布局 | pin/net/arc 坐标、容量、状态用 SoA；冷属性旁路 | 连续扫描、SIMD、减少 cache miss | cache-miss/byte-per-object A/B |
| 分配 | arena/slab + string interning + small-vector | 降低碎片和 allocator 锁 | RSS、alloc count、wall A/B |
| 空间索引 | 分层 R-tree/interval tree；批量 rebuild + 增量 delta index | 查询 `O(log N + k)` | 与暴力几何结果逐位对拍 |
| 状态 | versioned snapshot + DirtySet + ArtifactIndex | 避免落盘重读和全量初始化 | 同 session 与 fresh run 终局一致 |
| 并发 | 读多写少快照；提交点串行；线程本地缓冲后 merge | 避免对象级细锁 | TSAN + 确定性 hash |

先做对象大小、分配热点和遍历剖面，再决定 AoS→SoA；禁止全库一次性重写。

### 4.2 iSTA：确定性真值和高频增量

**传播内核**：图构建后做 SCC/loop 检查和 levelization；按 level 并行，vertex 的 rise/fall、early/late、scenario 数据连续存放。高扇入归约用线程本地候选，避免对 arrival 原子更新。

**增量失效**：

```text
on commit(changed_cells, changed_nets, changed_constraints):
  invalidate RC of changed_nets and coupled-neighbor halo
  seed forward cone from changed output arcs and parasitic roots
  seed backward cone when required time/constraint/load changes
  propagate until value/version unchanged within exact epsilon
  recompute affected endpoints and path groups
  periodically compare with full updateTiming
```

复杂度目标从全图 `O(S·(V+E))` 降为 `O(S_dirty·(V_dirty+E_dirty))`；最坏仍是全图。锥外不变是测试不变量，不能用浮点“几乎一致”掩盖漏失效。

**PBA**：GBA 先筛 top endpoints；对候选做回溯 beam/k-shortest 搜索，状态键包含 vertex、transition、scenario 和 path exception。使用可证明的上界剪枝；输出 `pba_exhausted` 和搜索预算，超预算不能假装精确。

**MCMM**：共享 immutable graph/lib topology，scenario 只保存差异化 delay/constraint 数据；先串行正确，再按 scenario 并行。不能通过反复 reset/read 全库实现“多角支持”并称为高性能。

### 4.3 iRCX：pattern 快速层 + 金标校准层

1. 线段按 layer/track tile，R-tree 找固定 halo 内的平行邻居。
2. 几何归一化为 `(layer,width,space,thickness,density,neighbor_count,via_stack)` pattern key。
3. pattern table 插值得到 ground/coupling C 和 R；超出表域返回 `out_of_domain`，不能无界外推。
4. dirty net 更新时包含相邻耦合网和 via stack；维护 coupling pair 的唯一所有权，防双计数。
5. 用 field solver/StarRC 样本做 residual 校准，按 pattern split 训练/验证；校准器必须单调、带误差区间并可关闭。

性能重点是 tile 邻居查询、pattern cache 命中和 SPEF 流式输出，而不是先上 GPU。只有 profile 证明算术密集、batch 足够且 PCIe/序列化占比低时才立 GPU 工作包。

### 4.4 iFP / iPL：从可放置到可布线

**宏布局**：小规模宏优先采用 sequence-pair/B*-tree + simulated annealing；连续力导向只作初值。代价向量独立保存：

```text
hard: overlap, boundary, keepout, fence, orientation
soft: weighted HPWL, macro-channel congestion, pin access,
      timing criticality, notch/dead-space, thermal/PDN reserved area
```

SA move 包含 swap/order/rotate/shift；每次只增量计算受影响 net 和局部拥塞。固定温度表先做基线，之后再用接受率反馈调温。没有合法可行解时返回 infeasible 及冲突约束集。

**全局布局**：保留 WA/LSE 平滑线长 + electrostatic density + Nesterov。补强顺序：

1. 用 B2B/QP 或多层 coarsening 产生稳定初值；不要把随机布局作为生产默认。
2. density bin 的 FFT/泊松解复用计划，检查边界条件、padding 和单位。
3. 拥塞先用 RUDY/pin density 作廉价反馈，再以快速 GR 校准热点；局部 cell inflation 设置上限和回退。
4. timing weight 使用 slack/criticality 的平滑函数并限制单网最大权重，避免少数网支配梯度。
5. 以 overflow、HPWL、梯度范数和无改善窗口联合停止；发散回退到 best snapshot。

**合法化/详细布局**：Abacus row segment DP 处理初始合法化；局部窗口用 swap/reorder/shift、空白迁移和 min-cost flow 修复。目标顺序是零重叠/零丢失 → 位移 → HPWL → timing/congestion。每次 iTO/iCTS 插入后只 legalize changed halo，并定期全局复查。

### 4.5 iCTS：拓扑、缓冲和 useful skew 分层

| 阶段 | 算法 | 关键约束 |
|---|---|---|
| sink clustering | bounded-diameter/k-means 变体，按位置+负载+时序组 | max fanout/cap、macro blockage、clock gate |
| topology | DME/BST 或 FLUTE 引导的 buffered tree DP | slew/cap、buffer sites、RC、NDR |
| buffer DP | 每子树维护 `(cap,delay,power,area)` Pareto 状态 | dominated state 剪枝，库/角点合法 |
| useful skew | 在确定拓扑上做 LP/差分约束预算 | 同时约束 setup/hold 和 skew range |
| commit | MoveTxn + incr LG + incr RC/STA | 任一步失败整批回滚 |

先完成 tree CTS 和多时钟域隔离，再评估 mesh/hybrid。mesh 会改变 PDN、route、power 和 signoff 需求，不应作为首阶段功能 checkbox。

### 4.6 iRT / iDRC：协商拥塞和冲突隔离

**全局布线**：pin access → FLUTE/Steiner 初始树 → pattern route → multi-source A*/maze。采用 PathFinder 风格协商拥塞：

```text
cost(edge, net) = base_rc
                + present_penalty(congestion/capacity)
                + history_penalty(overused_count)
                + timing_weight(net) * delay_cost
                + via/bend/layer/drc_risk
```

每轮 rip-up overused/hotspot nets，history penalty 单调增加；保留 best feasible snapshot。plateau 判断不只看 violation count，还要看加权严重度、热点集合变化和 routed completeness。扩大 box 只对冲突连通分量生效，避免全图预算爆炸。

**详细布线并行**：先构建 box conflict graph，对无共享 halo 的颜色批次并行；box 内保持确定性。线程本地生成 shape/violation delta，在 barrier 统一提交。直接并行相邻 box 会产生非确定短路和锁争用。

**DRC**：规则编译为按层查询计划；宽度/间距用 sweep-line + interval/R-tree，enclosure/cut spacing 用邻域查询。层次单元以 `(cell_hash, orientation, rule_deck_hash)` 缓存，顶层只重算交界 halo。报告必须区分 checked/skipped/unsupported。

### 4.7 iTO / iECO：候选生成和精确否决

候选不只看局部 cell delay。推荐用 sensitivity 产生候选，再用增量真值否决：

```text
score(move) = estimated ΔTNS
            - λa·Δarea - λp·Δpower - λc·congestion_risk
            - λh·hold_risk - λd·DRV_risk

repeat until budget/no-improve:
  candidates = resize + VT-swap + buffer + pin-swap
  rank by score; keep conflict-free batch
  apply batch in MoveTxn
  incr legalize → incr RC → incr STA(setup+hold) → local DRC
  accept iff hard constraints hold and lexicographic objective improves
  otherwise rollback; update tabu/candidate model
```

buffer tree 可用 van Ginneken DP 生成 `(required time, cap, area)` Pareto 解；高扇出先做 clustering。批量提交要建立 move conflict graph，避免两个候选同时改同一 net/row/timing cone。每 N 批做 full RC/STA 校验，增量结果漂移即禁用该路径。

setup 和 hold 不可使用同一简单 reward。固定顺序为 DRV → setup → hold → setup recovery；最终以 full scenario rescore 判定。

### 4.8 iPDN / iPA / iIR

**功耗**：活动源优先级为 VCD/FSDB → SAIF → 明确标注的 vectorless。vectorless 需传播信号概率和 toggle correlation，报告 clock/internal/switching/leakage 分量及覆盖率；无活动源不得冒充实测功耗。

**PDN/IR**：从 netlist/版图提取 conductance matrix `Gv=i`。静态 IR 以 PCG 为基线；Jacobi、incomplete Cholesky、AMG 是按迭代数/内存/profile 选择的预条件器候选，不预设唯一答案。每次报告 relative/absolute residual、迭代数和条件数代理；拓扑不变时复用预条件器并热启动，定期 full oracle。浮空节点在求解前连通性检查中报错。条带/via 优化依据 current density、voltage drop sensitivity 和 routing blockage，不能只用全芯片平均功耗反推统一宽度。

动态 IR 后置为窗口化电流波形 + sparse transient solve；在静态 PG 网络、活动覆盖和 DC 相关性未绿前不立项。

### 4.9 iLO / iTM / iLVS

综合链当前是 greenfield。不要从零手写完整逻辑综合器作为首阶段主线：先评估把 Yosys/ABC 作为可替换后端，iEDA 负责 Liberty/SDC/physical feedback 契约、结果导入和 commercial harness。只有出现明确的差异化内核需求，再实现 AIG rewrite、cut enumeration/technology mapping、timing-driven sizing。

LVS 的最小纵向切片是：独立 reference netlist loader → layout connectivity extraction → MOS/standard-cell recognition 的有限支持集 → partition refinement/graph matching → open/short/swap/parameter difference 注入测试。参考网表与提取网表必须有不同 provenance；`R²` 不适用于 LVS，结果是 exact match、容差 match 或 mismatch 分类。

---

## 5. 性能工程路线

### 5.1 从 profile 到改动

| 证据 | 优先动作 | 禁止直接跳到 |
|---|---|---|
| 算法次数/规模超预期 | 去重复、增量、降低复杂度 | 加线程掩盖 `O(N²)` |
| cache miss / RSS 高 | SoA、压缩 ID、arena、分块 | GPU |
| 锁/调度占比高 | 增大任务粒度、线程本地结果、冲突着色 | 更多细锁 |
| I/O/解析高 | 二进制 checkpoint、mmap/stream、一次解析多消费者 | 关掉产物 |
| 算术密集且 batch 大 | SIMD、向量库、GPU prototype | 未对拍的近似模型 |

每个热点工作包记录：调用次数、输入规模、理论复杂度、top functions、IPC/cache miss、分配次数、1/2/4/8/16 线程曲线、QoR hash。只有 hotspot 占比足够且 Amdahl 上限有价值时才实现。

### 5.2 并行设计原则

1. 优先 scenario、design、independent region、conflict-color batch 等粗粒度并行。
2. 共享只读 graph/tech/lib，线程本地累积，阶段末确定性 merge。
3. 禁止在热循环访问名字 map、虚函数链和全局 allocator。
4. NUMA 下 first-touch 分配，线程和内存绑到同 socket；跨 socket 单独测。
5. 结果确定性以 canonical report hash 验证；允许浮点非位级一致时冻结数值容差和排序 tie-break。

---

## 6. AI/ML 使用边界

### 6.1 可用位置

| 场景 | AI 输出 | 确定性保护 |
|---|---|---|
| candidate ranking | resize/buffer/rip-up/placement 候选顺序 | MoveTxn + exact incremental evaluate |
| parameter policy | effort、窗口、权重、迭代预算 | 有界参数域 + baseline fallback |
| hotspot/偏差归因 | 推荐错误 bucket 和下一实验 | 证据字段和规则校验 |
| surrogate | 早期 timing/congestion/power 排序 | uncertainty + abstain + periodic exact rescore |
| SDC assistant | 缺失约束提示、语法/覆盖解释 | 不自动添加 false/multicycle path |

### 6.2 多模型纠偏

“至少一个模型正确”的概率 `1-(1-p)^N` 不是投票正确率。5 个独立、同准确率 0.7 的模型做多数投票，其正确率为：

```text
Σ(k=3..5) C(5,k) 0.7^k 0.3^(5-k) = 0.83692
```

现实模型共享数据和特征，错误相关性会进一步降低收益。必须在 holdout 上测 ensemble，而不是用公式宣称 99%。融合应使用校准概率、误差相关矩阵和 abstention；模型分歧大或 OOD 时回落确定性引擎。

### 6.3 数据纪律

- split 按 design family + PDK，不按 path 随机切分，防同设计泄漏。
- teacher 数据记录工具版本、license 配置、scenario 和输入哈希。
- learned residual 不得把 unsupported SDC/RC 错误“拟合掉”。先修单位、约束、模型和拓扑，再做有界残差校准。
- 指标同时报 top-K precision/recall、critical false negatives、absolute slack error、ECE/coverage 和 OOD 拒答率。

---

## 7. 分阶段实施

### M0：证据地基

**交付**：冻结首个产品切片；Input/Build/Artifact manifest；daily/weekly/holdout 划分；G7/G8/G17/G21 schema；命令失败与覆盖清单。

**退出**：至少 3 个设计能由同一 runner 生成 iEDA/商业并排报告；任何缺输入、unsupported 或坏产物都非零退出。此阶段不允许宣称 parity。

### M1：确定性真值与增量契约

**交付**：DesignState/DirtySet/MoveTxn 最小接口；iSTA 单位/约束/增量；iRCX 分量对拍；iPL/iCTS/iTO 共用增量合法化接口。

**退出**：增量 vs full 在随机 ECO 注入集上结果一致；G7/G8 每个误差 bucket 可归因；rollback 后 canonical hash 一致。

### M2：可布线实现链

**交付**：iPL 初值+密度+拥塞；tree CTS + buffer DP；iRT negotiated congestion + DRC conflict isolation；iTO candidate+veto。

**退出**：daily 集 legality/connectivity/DRC/STA 硬约束通过，所有终局指标由外部金标读取；失败设计有机器可读原因。

### M3：QoR Pareto 爬坡

**交付**：逐设计差距归因和参数包；timing/congestion/power 多目标；holdout 回归。

**退出**：G17 按设计、指标、场景独立转绿；参数在 holdout 上无显著退化。只有此时才把 AI ranking 放进生产实验。

### M4：性能与规模

**交付**：热点驱动的数据结构/增量/并行优化；容量阶梯；受控商业性能对比。

**退出**：G21/G20；QoR 联合门禁不回归；报告复杂度和 RSS 拐点，不只报最终墙钟。

---

## 8. 首批工作包

| 顺序 | 工作包 | 交付/实验 | 依赖 |
|---|---|---|---|
| 1 | WP-EV-01 manifest + schema | 输入/构建/产物 hash；坏输入注入 | 无 |
| 2 | WP-STA-01 path alignment v2 | coverage/bias/P95/top-K/critical FN | 1 |
| 3 | WP-RCX-01 component diff | R/Cc/Cg/via/Elmore 分桶 | 1 |
| 4 | WP-PLAT-01 MoveTxn/DirtySet 契约 | rollback hash；随机 ECO | 1 |
| 5 | WP-STA-02 incr cone | incr vs full；锥外不变；墙钟 | 2/4 |
| 6 | WP-PL-01 deterministic baseline | seed、best snapshot、合法化失败上抛 | 1 |
| 7 | WP-PL-02 congestion feedback | RUDY off/on + fast-GR correlation | 6 |
| 8 | WP-RT-01 iteration telemetry | completeness/severity/hotspot-set 序列 | 1 |
| 9 | WP-RT-02 negotiated congestion | history cost A/B；DRC/QoR | 8 |
| 10 | WP-TO-01 transaction veto | harmful-move 注入、rollback、incr STA | 4/5 |
| 11 | WP-PERF-01 controlled runner | cgroup memory、median/MAD、build hash | 1 |
| 12 | WP-PERF-02 first hotspot | complexity + cache/alloc/thread A/B | 11 + M2 |

每个工作包只允许一个主假说；算法收益不成立时关闭或删除，不用扩大参数搜索掩盖失败。

---

## 9. 文档整改清单

| 文档 | 必改项 | 状态要求 |
|---|---|---|
| `00` | G7/G8/G21 改联合门禁；增加首个产品切片 | 以本文为细则 |
| `01` | 增加成熟度证据、复杂度和性能工作包要求 | 规范性 |
| `27-iSTA` | MAE/P95 从记录项升门禁；增加 critical FN 与约束覆盖 | M0 |
| `27-iSTA-benchmark-plan` | AI 章节降为研究轨；删除无实测的 ns/query/ps 收益 | 非规范性 |
| `42` | 修正 peak RSS、binary hash、2/5 语义和 A/B 工作区方案 | M0 |
| `50` | 修正 ensemble 数学、corner 筛选、order-only 风险 | 研究轨 |
| `31-iLVS` | placeholder 不得标 `rv2.0` 完成；补最小纵向切片后再升版 | D0 |
| `33-iLO-iTM` | 空壳优先外部后端集成，不先写完整综合器 | D0 |

---

## 10. 决策记录

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| DR-04-01 | 首阶段冻结产品切片 | 一次覆盖全部商业功能 | 可验收、可排期 |
| DR-04-02 | 联合门禁替代单 `R²` | 只看相关系数 | 防整体偏移和关键漏报 |
| DR-04-03 | 同一确定性内核双档 | 快/准两套平行实现 | 防语义和单位漂移 |
| DR-04-04 | MoveTxn + DirtySet 为实现链公共契约 | 各工具私有增量逻辑 | 一致性和性能共同需要 |
| DR-04-05 | 算法/数据结构先于盲目并行 | 全面 OpenMP/GPU | Amdahl、内存和确定性约束 |
| DR-04-06 | AI 负责排序/策略，精确内核负责验收 | learned correction 直接作签核 | OOD 和相关错误不可控 |
| DR-04-07 | 复用成熟综合后端起步 | greenfield 手写全综合链 | 缩短首个可用闭环 |

## 11. 未验证

1. 本文中的初始数值门槛尚需 Phase 0 的商业工具复跑噪声校准；只能收紧，放宽需决策记录和新协议版本。
2. 当前工作区存在 iPL/iRT/iCTS 与 benchmark 的在途修改；任何代码行号和基线都必须以最终 `binary_sha256` 对应的 artifact 为准。
3. 商业 stage 与 iEDA stage 的可比映射、license wait 排除方法、同机 NUMA 策略仍需实测。
4. advanced-node LEF58/DRC、CCS/LVF、SI、完整 UPF 和 full-chip LVS 不在首个产品切片内，不能从现有文档标题推断支持。
