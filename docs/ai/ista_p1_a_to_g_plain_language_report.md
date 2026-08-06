# P1 阶段 A 到 G 工作汇报

更新时间：2026-08-03

主基准：已布线 AES 30 个变体（AES30）

工艺库：Sky130

## 先说结论

可以把 Innovus 和 iSTA 想成两把测量同一条电路路径长度的尺子。

- **好消息**：P1 已经让“拿两把尺子进行比较”这件事可靠得多。比较对象、路径边界、版本号和证据文件都被严格固定；许多过去混进来的时钟段、报告格式差异和版本混用问题已经被排除。
- **还不能说的结论**：目前还不能说 iSTA 的**整体数值**已经明显接近 Innovus。最新 AES30 的数值质量门槛仍未通过：路径集合一致，但一部分 slack 差异和 hold false-clean 仍偏大。
- **实际进展**：iSTA 正在朝 Innovus 靠近的方向推进，但当前最确定的改善是“比较和定位更准确”，不是“默认时序模型已全面对齐”。P1 试过的宽范围 Ceff2 修改被拒绝；发现并保留了一个真实的 transition 选择缺陷修复；之后的工作把剩余差异收敛到更具体、更可信的路径延迟问题。

这里的 **false-clean** 指：Innovus 认为该路径有时序违例，但 iSTA 却报“没有问题”。这是最需要避免的一类错误，因为它可能漏掉真正的风险。

## P1 在整体方案中的位置

整体工作分两层：

1. **P0 已收口**：搭建可重复的 Innovus/iSTA 对比流程，使用 AES 作为主要基准，并用部分非 AES 电路检查流程不是只会跑 AES。
2. **P1 正在进行**：不是盲目调参数，而是用真实 AES30 数据找出“iSTA 和 Innovus 到底在哪一段路径、哪一种延迟上不同”，再一次只验证一个小修改。

P1A 到 P1G 已完成的部分，主要属于“建立可靠证据、验证和排除候选原因”。下一步才是基于 P1G 的干净数据，选择**一个**可证伪的延迟机制做源码候选，并按“单个 AES -> AES30 -> 至少一种非 AES 电路”的顺序验证。只有三关都通过，才允许说某个改动具有泛化性。

## 一览表

| 阶段 | 想解决的简单问题 | 结果一句话 | 是否改变默认 iSTA 模型 |
| --- | --- | --- | --- |
| P1A | 两个工具比较的是不是同一条真实物理路径？ | 建立了严格的物理弧比较，但数值门槛仍失败 | 否 |
| P1B | 用更接近分布 RC 的 Ceff2 负载，会不会整体更准？ | hold 有改善，但 setup 安全性变差，候选被拒绝 | 否，仍默认 `total_cap` |
| P1C | 能否只改 hold 数据路径的 cell delay，避免影响 setup？ | 做成了严格受控的实验候选；单 AES 的 hold false-clean 降为 0，但总体数值门槛仍未过 | 否 |
| P1D | rise/fall 是否误用了同一份负载？ | 找到并修复真实 bug；影响存在但不足以解决主差异 | 默认公式保留修复，未升级为数值对齐方案 |
| P1E | setup 为什么普遍比 Innovus 晚到？ | 确认是跨 AES30 的真实问题，但 cell/net 作用相反，不能贸然改公式 | 否 |
| P1F | 比较时是否把 launch clock 误当 data path？ | 修正边界后，未匹配观察减少 28.4% | 否 |
| P1G | P1F 的解析规则是否存在漏判？ | 加强解析器并重跑 AES30；没有发现该漏判，P1F 结论被独立复现 | 否 |

## P1A：先让“同一条弧”真的能对上

### 要解决什么

如果 iSTA 报告一条路径时把一个 cell 拆成“输入 net + cell”两行，而 Innovus 只显示一行 cell，直接按行号相减会得出假结论。P1A 的任务是建立一个严格规则：只有能证明是同一条物理弧的数据，才允许比较延迟。

### 使用的方法

- 使用用户指定的已布线 AES 目录：`/mnt/mdisk3/PCL-167/data3/taosimin/iDATA/aes/route/`。
- 使用 Sky130 工艺库：`/home/lifengyi/lifengyi/tools/iEDA/scripts/foundry/sky130/`。
- 使用 `physical_arc_v2` 合同：cell 弧必须匹配输入 pin 到输出 pin；net 弧必须匹配驱动 pin 到负载 pin；还要匹配上升/下降沿。
- 不能一对一证明的记录保留为“未匹配观察”，但**不参与数值相减**。这叫 fail-closed，意思是宁可少比较，也不制造假的根因。

### 结果

- AES30 的 30/30 个任务都完成，路径终点集合完全一致（Jaccard = 1.0）。
- 得到 7,593,844 对可安全比较的物理弧，其中 cell 3,753,936 对、net 3,839,908 对。
- 但数值质量没有达标：slack 的中位数 / P95 / 最大绝对差分别是 86.793 ps / 1,390.653 ps / 12,175.460 ps；hold false-clean 率为 12.3565%。

### 优点和缺点

- **优点**：从此不再把“报告写法不同”错当成“计算公式错误”；证据可追溯、可复跑。
- **缺点**：严格规则会留下很多未匹配项目，暂时不能直接解释整条路径的全部差异。

## P1B：验证 Ceff2 负载模型候选

### 要解决什么

普通 `total_cap` 把 RC 网络的总电容直接用于 NLDM 查表。P1B 试验了 Ceff2：它尝试把分布式 RC 网络换算成更接近波形行为的“有效电容”，希望 cell delay/slew 更接近 Innovus。

### 使用的方法

- Ceff2 是**可选实验模式**，默认仍是原来的 `total_cap`，不会悄悄改生产行为。
- Ceff2 只改变 NLDM cell delay/slew 查表所用负载；Elmore net delay 和 net slew 不改。
- 先做单 AES，再跑 AES30；两边使用同一份冻结输入清单。
- 设定硬门槛：终点集合不能变，hold 不能退化，setup false-clean 不能超过允许上限。

### 结果

候选在 AES30 上出现了典型的“有得有失”：

| 指标 | 原 `total_cap` | Ceff2 候选 | 解读 |
| --- | ---: | ---: | --- |
| hold false-clean 率 | 12.3565% | 2.3717% | 明显改善 |
| setup false-clean 率 | 0.0592% | 0.3325% | 变差，超过安全上限 |
| P95 slack 绝对差 | 1,390.653 ps | 1,238.709 ps | 有改善 |
| 终点 Jaccard | 1.0 | 1.0 | 路径集合一致 |

因此机器判定为 **REJECT**。没有再启动更广泛的非 AES 候选测试，也没有把 Ceff2 设成默认值。

### 优点和缺点

- **优点**：证明了负载模型确实会影响结果，且对 hold 有潜在帮助；更重要的是，安全门槛阻止了“局部好看、整体漏报”的改动进入默认模型。
- **缺点**：它同时影响 delay 和 slew、同时影响 setup/hold，范围太大，难以只修复目标问题而不伤及 setup。

## P1C：把候选缩小到“只动 hold 数据路径的 cell delay”

### 要解决什么

P1B 的改动太宽。P1C 依据 V2 数据桶，把问题缩小到 `hold / async_default / rise / DATA_DELAY`：在该桶内，cell 弧的绝对延迟贡献占 83.4%，而 setup 对照桶影响很小。

### 使用的方法

- 设计并实现了一个严格 opt-in 的 min-only 候选：只在 hold（min）分析、数据路径、非时钟 NLDM delay 查表中使用 Ceff2。
- 不修改 cell slew、输出电流、时钟路径、增量时序路径和默认流程。
- 每一个 iSTA 实例单独保存开关，避免一个实验污染另一个实例。
- 先通过单元测试和单个 AES canonical，再决定能否扩展到 AES30。

### 结果

- 单个 AES canonical 的 hold false-clean 从基线的 75 降到 0；setup false-clean 为 1。
- 但是数值差门槛 G2 仍未通过：中位数 47.593 ps、P95 475.125 ps、最大 1,354.925 ps，均高于要求。
- 所以 P1C 没有进入 AES30，也没有成为默认模型。它说明“缩小作用范围”是有价值的，但仍未给出可推广的对齐改动。

### 优点和缺点

- **优点**：改动范围非常受控，能更清楚地观察一个假设是否有效，减少影响 setup 的风险。
- **缺点**：单 AES 的改善不足以证明泛化；整体数值差仍大，不能据此发布为正式模型。

## P1D：修复 rise/fall 负载选择的真实 bug

### 要解决什么

代码检查发现：在收集 rise/fall 两个 transition 的 load 时，循环中错误地总是使用输出 transition。这样本来应该不同的 rise 和 fall 负载，可能被填成同一个值。

### 使用的方法

- 修复两个 load-propagation 路径，使它们按当前循环的 rise/fall 分别取 load。
- 增加测试：rise 0.011 pF 与 fall 0.029 pF 必须保持不同。
- 用同一份 AES 输入做 canonical 对照，而不是直接上 AES30。

### 结果

- 这是一个被单元测试证明的真实源码 bug，修复被保留。
- 6,568 个端点的数值发生变化，说明修复确实生效。
- 中位 slack 绝对差从 46.5885 ps 降到 46.021 ps，只改善 0.5675 ps；P95、最大差和 false-clean 都没有改善到门槛内。
- 因此不跑 AES30 推广，也不把它称为数值对齐方案。它主要是**正确性修复**，不是主根因修复。

### 优点和缺点

- **优点**：消除了一个确定的实现错误，避免后续诊断建立在错误 transition 数据上。
- **缺点**：它只影响一部分 transition 选择，无法解释约 0.7 ns 级别的 core-clock setup data-arrival 主差异。

## P1E：定位 core-clock setup 的大差异

### 要解决什么

P1D 之后仍有较大的 setup 差异。P1E 要回答：这个差异主要来自 cell delay、net delay，还是时钟/数据边界混淆？

### 使用的方法

- 只读分析已经保存的 AES30 证据，不重新运行 EDA。
- 只选择 setup + core_clock + data cell/net 弧。
- 只对严格一对一、顺序一致的物理弧求数值；未匹配项不猜测、不补齐。

### 结果

- 179,220 条选中记录中，iSTA 的 setup data arrival 在 30 个 AES 场景里都比 Innovus 晚。
- 平均差为 +746.115 ps（正号表示 iSTA 比 Innovus 晚）。
- cell 弧的绝对差更大，但有负的有符号差；net 弧有正的有符号差。两类会相互抵消，不能简单说“只改 cell”或“只改 net”。
- 仍有超过 600 万条 directed-arc 观察无法一对一匹配，所以无法得到一条完整路径的因果分解。

### 优点和缺点

- **优点**：确认 setup 差异不是偶然样本，也不是终点集合不一致，而是跨 AES30 的真实现象。
- **缺点**：当前数据还不能唯一归因到一个公式。若这时改全局模型，风险很高。

## P1F：修正 launch clock 和 data path 的边界

### 要解决什么

之前的分析可能把 launch clock 的一部分当成 data path 来匹配，这会让“数据延迟根因”掺入时钟内容。

### 使用的方法

- 对有时钟路径：从起始时钟段一直标为 `launch_clock`，直到严格识别到 launch cell 的 `CLK -> Q`，之后才是 `data`。
- 对无时钟的 primary-input 路径：开始部分可作为 data。
- 无法证明边界的时钟路径直接拒绝，而不是猜测。
- launch clock 单独审计；data path 的数值比较只使用 `component_kind=data`。

### 结果

| 指标 | P1E | P1F | 变化 |
| --- | ---: | ---: | ---: |
| 选中的 setup/core-clock 记录 | 179,220 | 179,220 | 不变 |
| 可安全匹配的数据弧对 | 5,579,953 | 5,557,454 | 基本不变 |
| 未匹配观察 | 6,289,427 | 4,502,245 | 减少 28.4% |
| 未匹配记录 | 0 | 0 | 不变 |

这说明比较边界更干净了，但剩余的 4,502,245 条 data 未匹配观察仍然很多，尚不能支持一个 iSTA 延迟计算修改。P1F 不改 iSTA 的 C++ 时序计算。

### 优点和缺点

- **优点**：排除了一个重要混淆因素，减少了 28.4% 的未匹配观察，同时没有损失记录覆盖。
- **缺点**：P1F 改善的是证据质量，不会自动让 slack 数字变好；主数值差仍需要新的单一候选来解决。

## P1G：加固解析器，并用同提交重跑验证

### 要解决什么

P1F 的审查发现一个边界情况：若起点是实例 pin，却出现空的 `Clock:` 字段，旧规则可能把它误认为无时钟 primary input。

### 使用的方法

- 加固解析器：只有明确的顶层 primary input 才允许空 `Clock:` 走无时钟 data 规则；实例 pin 的空 `Clock:` 直接拒绝。
- 比较脚本强制要求指定 iSTA 精确提交号，防止“拿新解析器去解释旧证据”。
- 在新提交 `3904289...` 上先跑 canonical，再完整重跑 AES30。
- 采用 delta 式保留：验证完 150 个内容寻址对象且 0 个无效后，释放可重建的原始运行目录，避免再次占满磁盘。

### 结果

- AES30 30/30 完成，150 个保留对象全部验证通过，0 个无效对象。
- 与 P1F 完全一致：179,220 条匹配 setup/core-clock 记录、5,557,454 对安全 data 弧、4,502,245 条 data 未匹配观察。
- 这说明该 AES30 证据中没有出现这类空 `Clock:` 漏判路径。P1G 的结论仍是 `MEASUREMENT_ONLY`，不是数值模型改善。

### 优点和缺点

- **优点**：防止未来遇到类似格式时产生静默误判；同时保证 P1F 的历史数据和 P1G 的新数据不会混用。
- **缺点**：当前 AES30 没有触发该边界情况，因此数值结果没有变化；它提高的是可靠性，不是精度。

## 现在 iSTA 是否正在逐渐接近 Innovus？

答案要分两层说。

### 1. 比较可靠性：明显在接近

这部分已经有明确进步：

- 终点和 transition 的集合能严格一致；
- 物理弧只能在一对一证明后才数值比较；
- launch clock 与 data path 已明确分开；
- 版本、输入清单、哈希、保留证据都被绑定；
- P1F/P1G 使用 delta 保留，既能审计也不会重复保存数百 GB 原始文件。

也就是说，我们越来越能确定“差异是真的”，并越来越能指出它属于哪一类路径，而不是被报告格式或运行版本干扰。

### 2. 默认时序数值：还没有足够证据证明整体接近

最新 `total_cap` AES30 物理弧基线仍然是：

- 30/30 语义任务通过；
- endpoint Jaccard = 1.0；
- 但 G2（slack 差分布）失败，G4（false-clean）失败；
- P1F/P1G 只是清理诊断边界，不会自动降低这些数值差。

因此，正确表述是：**iSTA 的对齐工程正在稳步前进，且已避免多次不安全的候选；但默认模型还没有达到“与 Innovus 整体数值接近”的验收标准。**

这不是停滞。P1 已经排除了“宽范围 Ceff2 一把梭”和“transition 负载选择 bug 就是主因”两条不充分路线，并把下一次源码改动的范围压缩得更小、更可验证。

## 当前优点、限制与下一步

### 当前优点

- 使用真实已布线 AES 和真实 Sky130 库，而不是只靠小玩具例子。
- 每次修改都先做窄范围验证，失败不会进入默认模型。
- 测试顺序明确：单 AES -> AES30 -> 非 AES；避免只为 AES 特化。
- 证据有 commit、SHA-256、输入清单和保留闭包，可追溯。

### 当前限制

- AES30 仍是主基准，非 AES 的新候选泛化测试尚未启动，因为没有候选通过 AES30 门槛。
- 很多物理弧无法一对一匹配，导致不能把整条路径差异完全分解。
- 现有大差异同时涉及 cell 和 net，不能从“哪个总和更大”直接推导一个安全的代码修改。

### 下一步

1. 基于 P1G 的干净数据，选择一个明确的 residual bucket，例如 hold/async_default/rise/DATA_DELAY，或路径完整度更高的子集。
2. 先证明该子集的一种单一机制（例如某类 cell delay 或某类 net delay）在物理身份上可一对一解释。
3. 只实现一个 opt-in 源码候选，先跑单 AES。
4. 只有单 AES 通过数值和安全门槛，才跑 AES30；只有 AES30 通过，才跑至少一种非 AES 电路。
5. 若任一关失败，保留诊断结论但不改默认 iSTA 模型。

## 主要证据位置

| 内容 | 位置 |
| --- | --- |
| P1A AES30 物理弧基线报告 | [ista_p1_physical_arc_aes30_evidence.md](/home/lifengyi/lifengyi/innovus_STA/docs/ista_p1_physical_arc_aes30_evidence.md) |
| P1B 数值候选执行报告 | [ista_p1_numeric_alignment_execution.md](/home/lifengyi/lifengyi/innovus_STA/docs/ista_p1_numeric_alignment_execution.md) |
| P1C 设计规格 | [2026-08-02-ista-p1c-cell-delay-hold-candidate-design.md](/home/lifengyi/lifengyi/innovus_STA/docs/superpowers/specs/2026-08-02-ista-p1c-cell-delay-hold-candidate-design.md) |
| P1C canonical 结果 | `/home/lifengyi/lifengyi/innovus_STA/results/ista_innovus_p1/955f00914cc8b4cc0c05653829d9c1448d6eb3f7/p1c_cell_delay_candidate/canonical/` |
| P1D transition-load 修复报告 | [ista_p1d_transition_load_fix_execution.md](/home/lifengyi/lifengyi/innovus_STA/docs/ista_p1d_transition_load_fix_execution.md) |
| P1E setup data-arrival 诊断 | [ista_p1e_core_clock_setup_diagnosis.md](/home/lifengyi/lifengyi/innovus_STA/docs/ista_p1e_core_clock_setup_diagnosis.md) |
| P1F data-path 边界报告 | [ista_p1f_data_path_boundary_execution.md](/home/lifengyi/lifengyi/innovus_STA/docs/ista_p1f_data_path_boundary_execution.md) |
| P1G 解析器加固重测报告 | [ista_p1g_parser_hardening_execution.md](/home/lifengyi/lifengyi/innovus_STA/docs/ista_p1g_parser_hardening_execution.md) |
| P1G 最终 dossier | `/home/lifengyi/lifengyi/innovus_STA/results/ista_innovus_p1/39042891285418daa6ea774083a8a8de493422f4/p1g_parser_hardening/dossier.json` |

## 术语小抄

- **setup**：数据必须在时钟到来前提前准备好。
- **hold**：时钟到来后，数据还要保持一小段时间不能太早变化。
- **slack**：时间余量；负数通常表示违例。
- **Ceff2**：把复杂 RC 网络换算为“有效电容”的一种近似方法。
- **canonical**：先用一个固定 AES 设计做小范围验证。
- **AES30**：30 个已经布局布线的 AES 变体，是当前优化的主基准。
- **G2/G3/G4**：G2 检查数值差是否足够小；G3 检查比较对象是否完整一致；G4 检查 false-clean 是否安全。
- **MEASUREMENT_ONLY**：只说明测量和定位工作有效，不能据此修改默认时序模型。
