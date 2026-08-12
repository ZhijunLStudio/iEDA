# 30 · iDRC commercial-parity TODO

事实源：`docs/ai/30-iDRC.md`。完成口径以规则覆盖表、运行时 checked/skipped、Calibre harness、违例 JSON 和假 clean 防御同时存在为准。

## 当前结论

- iDRC 有真实规则检查能力，但只能作为 in-design 子集，不能替代 Calibre signoff。
- 最大产品风险是 partial clean 被误当 clean。
- 线程安全和规则覆盖仍需机器证明。

## P0 - coverage manifest

- [ ] 冻结 PDK rule manifest：rule id、layer、enabled、unsupported reason、deck hash。
- [x] runtime 输出 checked/skipped/unsupported/partial，并写入 `drc_summary.json`。
- [x] coverage 缺失或 schema invalid 必须启动失败。
- [ ] deck hash 漂移、unsupported 未声明必须启动失败。
- [x] `status=partial_clean` 在平台、eval、CI 中不得 PASS。
- [ ] 每个规则类至少一个正例/反例 microcase。

## P0 - violation schema

- [x] JSON schema 与 iRT 对齐：type、layer、bbox、net、shape id、severity、source。
- [x] 违例坐标单位、layer name、net mapping 必须可被 GUI/eval/routeECO 消费。
- [x] 同一违例去重和 stable ordering 固定，便于 hash 回归。
- [x] 产物缺失或 schema invalid 必须非零。

## P1 - Calibre harness

- [ ] 同 GDS/DEF/tech/deck hash 与 Calibre 对拍。
- [ ] 输出 true positive、false positive、false negative、unsupported 分桶。
- [ ] 每个 PDK 选最小支持 deck，先闭合 MetalShort/Spacing/Width 等核心规则。
- [ ] 不能用 iDRC clean 替代 Calibre clean；只能报告支持子集一致性。

## P1 - thread safety and performance

- [ ] 审阅 OpenMP violation 容器写入临界区。
- [ ] 规则参数只读共享必须 const 或受保护。
- [ ] cluster 缓存销毁时机无 race，并加 tsan/重复运行测试。
- [ ] 输出 per-rule runtime、cluster count、thread count、peak RSS。

## P2 - route ECO feedback

- [ ] iDRC violation JSON 能被 iRT/iECO 消费，包含 repair hint 但不直接改 DB。
- [ ] 回灌编排由平台控制，防止 DRC 工具私自执行 ECO。
- [ ] DRC clean / partial / dirty 进入 QoR schema。

## 下一步执行顺序

1. **P0 coverage**：先防假 clean。
2. **P0 violation JSON**：统一消费者。
3. **P1 Calibre subset**：建立金标线。
4. **P1 thread safety**：关闭并发风险。
5. **P2 feedback**：再接 ECO。

## 快速检查 v1

- iRT 通过 `-enable_idrc_fast_check` 或 `IEDA_RT_IDRC_FAST_CHECK=1` 启用 `idrc_fast_check_v1`；AES13 flow 对应 `--rt-idrc-fast-check`。
- `run_drc -path <report>` 在报告同目录发布 `drc_summary.json`、`violations.json` 和兼容 `violation_map.json`，平台与 QoR gate 共同消费该覆盖证明。
- 快速检查零违例只允许报告 `partial_clean`；`signoff_clean` 恒为 `false`，G11 与 GDS signoff 必须失败。

## 验证纪律

- skipped 非空即不是 clean。
- Calibre 对拍必须报告 false negative，不能只报告 iDRC 找到了什么。

## Source map

| File / module | 当前定位 | 具体待办 |
|---|---|---|
| `interface/DRCInterface.{hpp,cpp}` | 对外门面 | rc、coverage、schema 入口 |
| `config/rule_coverage.schema.json` | 覆盖定义 | checked/skipped/unsupported 版本冻结 |
| `source/data_manager/*` | 基础数据 | violation/status/stable ordering |
| `source/module/rule_validator/*` | 核心规则 | 每个 design rule 的正反例、并发审计 |
| `source/module/gds_plotter/*` | 可视化 | 违例定位、GDS 证据输出 |
| `source/toolkit/logger/*` | 日志 | 错误码、并发安全、fail-fast |
| `source/toolkit/monitor/*` | 监控 | runtime/peak RSS/线程数 |
| `source/toolkit/utility/*` | 工具 | 共享几何/字符串 helper 的边界 |
| `test/*` | 回归 | coverage 规则、假 clean 防御、线程安全 |

## Leaf 文件级执行台账

覆盖基线（2026-08-07）：`config/` + `interface/` + `source/` 共 115 个文件。当前 `RuleValidator::verifyRVCluster()` 会调度 26 个 rule type，但 `Enclosure.cpp`、`FloatingPatch.cpp`、`JogToJogSpacing.cpp` 的函数体为空；因此“数据库加载了规则参数”不能等价于“engine checked”。下表将每条规则的参数 DTO、几何 kernel、coverage state、microcase 和 Calibre 子集匹配绑定为一个不可拆分的完成单元。

路径缩写只省略已知父目录：`.../rv_data_manager`、`coverage`、`tests` 都位于 `source/module/rule_validator/`；`.../gp_data_manager` 位于 `source/module/gds_plotter/`。同一行未重复目录的文件继承首个完整路径；缩写不代表目录级或通配任务。

### A. Public interface、coverage、summary 与数据库 leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P0 | `config/rule_coverage.schema.json` | schema支持implemented/partial/missing，但还需证明deck身份、engine能力和运行选择三层一致 | 增schema version兼容策略、PDK/foundry/deck path+真实SHA-256、rule parameter hash、engine capability/version、semantic coverage、Calibre rule ID；禁止额外字段和伪hash；定义partial reason enum | JSON Schema正反 corpus；真实文件hash mismatch、duplicate foundry ID、unknown engine rule、stale parameter hash均拒绝 |
| P0 | `interface/DRCInterface.hpp` | 对外 `getViolationList` 主要返回vector，缺run status/coverage/artifact/error；调用方可能把空vector当clean | 定义 `DRCCheckResult`（status、violations、engine/foundry coverage、checked geometry count、deck hash、artifact、diagnostics）；legacy vector API仅显式adapter且invalid时不可返回“clean空集” | API compile/test；clean/dirty/partial/unsupported/error/empty-input映射固定 |
| P0 | `interface/DRCInterface.cpp` 的 init/check/getViolationList | rule coverage基于known/loaded/requested；`canRun`失败后的控制流和DB mutation需明确 | init校验config/tech/manifest/deck hash；每次check生成run ID；coverage refusal直接返回error；kernel异常/unsupported/empty stub进入partial/error；永远先构造typed result再输出；不得靠logger终止或继续 | invalid manifest、unknown rule、stub rule、iDRC未init、kernel fault；空violations仅在checked完整且geometry>0时可clean |
| P0 | `interface/DRCInterface.cpp` 的 `outputViolationJson/outputCVioJson` | legacy JSON字段不同；C-VIO的`rule_deck_hash`当前写死`unknown`，severity硬编码少数规则 | 只保留canonical C-VIO schema或提供明确版本adapter；填真实deck/parameter hash、DBU、shape IDs、stage、rule ID、required/actual、repair hint；severity来自rule metadata而非if链；stable ID/order/dedup；I/O失败回result | schema/golden、same input/thread hash、unknown type、special net/cut layer、read-only dir；iRT/GUI/eval可读 |
| P0 | `interface/DRCInterface.cpp` 的 `outputRuleCoverageJson` | 写失败只日志；summary未必与同次violation run原子对应 | summary带run/design/input/rule/deck/parameter hashes、engine/foundry四态、geometry/violation counts、per-rule runtime、signoff blockers；temp+fsync+atomic rename；publish失败使strict run error | partial write/rename fail；summary run ID与C-VIO一致；schema validator |
| P1 | `interface/DRCInterface.cpp` 的 `cmpViolation/printSummary/outputViolationFile/outputTofeature` | 多个消费/输出路径可能各自去重、层映射和type口径 | 全部消费immutable `DRCCheckResult`；comparison用canonical matcher；文本/feature只做adapter，不重算/过滤；输出失败分mandatory/debug | legacy文本/C-VIO/counts逐项一致；feature off/on不改变check result |
| P0 | `source/data_manager/advance/Config.hpp` | thread、temp、coverage table、C-VIO开关等配置缺统一schema/严格档 | 定义strict in-design/signoff-harness profile、thread范围、mandatory artifact、rule selection、manifest/deck path；unknown key/range/互斥fail；effective config/hash入summary | config正反/默认snapshot；每字段consumer coverage |
| P0 | `source/data_manager/DataManager.hpp`, `DataManager.cpp` | tech/design/shape/rule加载决定`exist_rule_set`；空kernel规则可能仍被算loaded | 分开 `parameter_loaded`、`kernel_implemented`、`microcase_qualified`、`calibre_correlated`；只有交集可checked；build input transaction化；层/rule/shape映射错误聚合；output失败传播 | 三个空kernel即使有参数也不得checked；malformed tech/shape；重复run不带旧state |
| P1 | `source/data_manager/advance/Database.hpp`, `Die.hpp` | 数据库缺显式input/revision/hash，die/core边界影响OutOfDie | 保存design/tech/rule/shape revisions与hash；Die验证ll/ur、DBU、empty；任何run绑定不可变snapshot | die边界/空设计、revision漂移；same snapshot hash稳定 |
| P1 | `source/data_manager/advance/RoutingLayer.hpp`, `CutLayer.hpp` | 26规则参数依赖layer/cut adjacency、direction、width/spacing；缺值不能默认0 | 每个rule参数保留foundry source ID/units/applicability；layer/cut index/name/adjacency唯一；未支持LEF语义标partial，不加入loaded | real/synthetic tech、missing adjacency/table；parameter manifest与DTO逐项hash |
| P1 | `source/data_manager/advance/DRCShape.hpp` | shape只有几何/net/routing信息不足以stable diff和增量归因 | 增shape ID、source object ID、owner net、layer、routing/cut、stage、revision；canonical geometry；env/result身份不靠指针 | iDB/iRT shape round-trip；duplicate/overlap/invalid layer；stable IDs |
| P0 | `source/data_manager/advance/Violation.hpp`, `ViolationType.hpp` | violation comparator/dedup与type字符串决定跨工具一致性；unknown conversion需防silent enum | 对齐C-VIO字段；type registry记录kernel/coverage/rule family/severity；string parser返回optional；dedup key含rule/layer/bbox/nets/shapes并稳定排序 | 26 type exhaustive round-trip、unknown拒绝、thread-order independent dedup |
| P1 | `source/data_manager/advance/SortStatus.hpp`, `DRCHeader.hpp` | 通用enum/header可能把“已排序”当数据valid；集中include隐藏全局依赖 | enum exhaustive；SortStatus只表示cache状态并绑定revision；DRCHeader减少可变全局和隐式using，声明单位类型 | stale sort cache、enum parser、include hygiene |
| P2 | `source/data_manager/basic/PlanarCoord.hpp`, `PlanarRect.hpp`, `LayerCoord.hpp`, `LayerRect.hpp` | 所有几何predicate依赖闭区间/半开区间、touch、溢出约定 | 统一`[ll,ur)`、open/closed overlap API、64-bit distance/area、empty/normalize、layer比较；rule kernel禁自造不同语义 | property/fuzz、INT32边界、touch/1-DBU gap、translation/mirror invariants |
| P2 | `source/data_manager/basic/GridMap.hpp`, `Segment.hpp`, `Direction.hpp`, `Orientation.hpp`, `Rotation.hpp` | cluster/grid、边界遍历和角点方向错误会系统性误报/漏报 | GridMap RAII/size/index；Segment canonical orientation；Direction/Orientation/Rotation exhaustive composition；polygon ring/hole方向oracle | zero/huge grid、CW/CCW outer/hole、degenerate edge；ASan/property |

### B. RuleValidator orchestration、cluster 与 coverage leaf

| Pri | Leaf 文件 | 文件级任务 | DoD / focused test |
|---|---|---|---|
| P0 | `source/module/rule_validator/RuleValidator.hpp` | 每个kernel返回 `RuleCheckResult`（checked geometry、violations、unsupported/partial/error、runtime）；registry绑定type→kernel capability；`verify`返回run result，不用空vector表达失败 | compile-time registry覆盖26 enum；空函数或未注册使测试/启动失败 |
| P0 | `source/module/rule_validator/RuleValidator.cpp` | build clusters保证shape/task覆盖；每cluster局部结果，无共享vector race；按cluster ID归并；dispatch聚合每rule状态；kernel exception捕获；cache RAII清理；stable dedup | 1/N threads结果hash一致、TSan；Nth cluster fault；shape/task counts守恒；empty kernel partial |
| P1 | `.../rv_data_manager/RVModel.hpp`, `RVSummary.hpp` | Model绑定immutable input/tech/rule hash；Summary按rule记录selected/checked/skipped/unsupported/error、geometry、violations、runtime；overall reducer只由summary产生 | multi-rule one partial/one fail；summary与C-VIO/coverage counts一致 |
| P1 | `.../rv_data_manager/RVCluster.hpp`, `RVComParam.hpp` | Cluster stable ID、halo、owned shapes、requested rules、result；每result shape至少被一个core region检查；ComParam immutable thread/tile/halo policy | 边界shape跨2/4 clusters不漏不重复；thread count不改结果 |
| P1 | `.../rv_data_manager/RVLayerData.hpp` | polygon/max-rect/boundary/cut pool元素加stable ID/owner/isEnv；验证outer/hole ring、prev/next、convex/orientation；R-tree绑定revision；prepare后完整性检查 | rectangle/L/U/donut/多polygon/env覆盖；pool counts、ring连通、R-tree query oracle |
| P0 | `.../coverage/RuleCoverage.hpp`, `RuleCoverage.cpp` | 加engine capability registry和qualification evidence；manifest SHA验证真实文件；status reducer纳入kernel runtime结果；foundry implemented只有parameter+kernel+microcase齐全才checked；Calibre evidence另列 | 扩展coverage test：stub、hash mismatch、runtime fail、partial semantic、selection skip；`signoff_clean`在外部signoff前恒false |
| P0 | `.../tests/RuleCoverageTest.cpp` | 加临时deck真实SHA、capability矩阵、26 registry完整性、runtime merge、stable JSON；mutation空实现/改hash必须失败 | 独立CTest、无外部PDK；所有状态分支有assert |

### C. 26 条规则 leaf：参数、kernel、microcase 与 Calibre 对齐

每行的 `*Rule.hpp` 必须保存实际支持的参数子集、单位、foundry rule ID、applicability和semantic coverage；对应 `.cpp` 必须返回rule result而非直接向共享vector写入。完成标准不是“能编译”，而是正例0报、单违例反例恰当报、边界值、旋转/平移不变、cluster边界、1/N线程一致，以及同deck Calibre子集匹配。以下路径前缀分别为 `source/data_manager/design_rule/` 和 `source/module/rule_validator/rv_design_rule/`。

| Pri | Leaf 文件 | 规则级具体任务 | 必做 microcase / 对齐判据 |
|---|---|---|---|
| P1 | `MetalShortRule.hpp` + `MetalShort.cpp` | 参数头标同层异net/同net豁免和touch语义；kernel用polygon交叠判断short，返回涉及nets/shapes与实际overlap，不把same-net接触报错 | same/different net overlap、edge touch、1 DBU overlap、env/result；关键short Calibre FN=0 |
| P1 | `ParallelRunLengthSpacingRule.hpp` + `ParallelRunLengthSpacing.cpp` | 完整表达width×PRL spacing table、same/diff net和EOL排除；lookup与LEF阶梯语义一致；报告required/actual/parallel run | PRL/width表格四象限、正交、短并行、notch；bbox tolerance≤1 DBU |
| P1 | `MinimumWidthRule.hpp` + `MinimumWidth.cpp` | 参数含min width和wrong-way适用性；kernel按最大矩形/边界测局部宽度，处理L形/neck，不只bbox | 刚好/少1 DBU、窄neck、L/U形、旋转；FN=0、重复报告归一化 |
| P1 | `MaximumWidthRule.hpp` + `MaximumWidth.cpp` | 参数含max width及slotting/例外支持状态；kernel测局部最大宽度，unsupported slotting标partial | 刚好/多1 DBU、大矩形、L形；unsupported例外不算checked |
| P1 | `MinimumAreaRule.hpp` + `MinimumArea.cpp` | 参数含min area和已支持例外；kernel按连通polygon净面积（扣holes），正确标env delta | 矩形边界、L形、donut hole、同net相连patch；面积/violation归一化 |
| P1 | `MinHoleRule.hpp` + `MinHole.cpp` | 参数含min hole area/width支持范围；kernel只检查polygon holes并正确处理ring方向 | 无hole、边界/少1 DBU hole、多个holes、donut旋转；hole bbox/area对齐 |
| P1 | `MinStepRule.hpp` + `MinStep.cpp` | 表达min step、max edges、inside/outside corner及例外支持位；沿boundary prev/next测step，报告edge IDs | 短边、连续短边、inside/outside、hole、边界；unsupported option partial |
| P1 | `NotchSpacingRule.hpp` + `NotchSpacing.cpp` | 参数含notch spacing/length/concave ends；kernel区分同polygon凹槽与两polygon spacing，避免与PRL重复 | U形notch、窄/浅、two-shape spacing、hole；rule分类与Calibre一致 |
| P1 | `CornerSpacingRule.hpp` + `CornerSpacing.cpp` | 表达convex/concave、corner type、within和例外支持；按角点方向/邻边测距，稳定合并同一corner violation | convex/concave、L/U/donut、旋转镜像、边界；corner count/bbox匹配 |
| P1 | `CornerFillSpacingRule.hpp` + `CornerFillSpacing.cpp` | 明确corner-fill pattern定义与spacing；kernel识别fill而非普通rect，输出参与边界 | 真/假corner fill、边界距离、旋转；不误分到PRL/EOL |
| P1 | `EndOfLineSpacingRule.hpp` + `EndOfLineSpacing.cpp` | 718 LOC：将EOL width/within/parallel edge/two edges/cut等支持矩阵写入参数；拆predicate并记录命中clause | 每clause正反、边界、parallel/orthogonal、同/异net、hole；按clause分桶precision/recall |
| P1 | `CutEOLSpacingRule.hpp` + `CutEOLSpacing.cpp` | 表达cut class、EOL width/within、extension、同/异net；校验cut-layer adjacency和边界方向 | cut near/far EOL、wrong adjacent layer、边界、multiple cuts；FN=0核心子集 |
| P1 | `CutShortRule.hpp` + `CutShort.cpp` | 明确same cut layer异net重叠/touch；kernel返回两个shape/net IDs并canonical去重pair | overlap/touch/same-net/different-layer、duplicate cuts；pair匹配Calibre |
| P1 | `AdjacentCutSpacingRule.hpp` + `AdjacentCutSpacing.cpp` | 参数含cut count、within、spacing、cut class；kernel统计邻域且避免自身/重复计数 | N-1/N/N+1 cuts、边界距离、同/异net、cluster边界；count/required匹配 |
| P1 | `SameLayerCutSpacingRule.hpp` + `SameLayerCutSpacing.cpp` | 表达center-to-center/edge、same-net、cut class、parallel overlap支持位；kernel选正确距离metric | horizontal/diagonal/overlap、same/diff net、class组合；bbox+tolerance匹配 |
| P1 | `DifferentLayerCutSpacingRule.hpp` + `DifferentLayerCutSpacing.cpp` | 参数映射layer pair、stack/overlap/spacing；kernel只检查配置pair并canonicalize上下层 | adjacent/nonadjacent pair、stacked/offset、missing mapping；无跨pair误报 |
| P0 | `EnclosureRule.hpp` + `Enclosure.cpp` | **kernel当前空函数**。实现cut被routing metal的上下/左右enclosure，支持above/below与方向；实现+microcase前capability=`missing`，不得checked | exact/少1 DBU、top/bottom metal、edge/corner缺口、多cut；核心enclosure Calibre FN=0 |
| P1 | `EnclosureEdgeRule.hpp` + `EnclosureEdge.cpp` | 539 LOC：写明edge length/overhang/例外/adjacent支持；拆predicate并避免env polygon误扣；报告cut/metal edge IDs | edge/corner、长/短边、hole、env delta；clause分桶对齐 |
| P1 | `EnclosureParallelRule.hpp` + `EnclosureParallel.cpp` | 参数含parallel length、within、overhang方向；kernel正确选择parallel edges与cut projection | vertical/horizontal、parallel threshold、边界/少1 DBU；required/actual对齐 |
| P1 | `NonsufficientMetalOverlapRule.hpp` + `NonsufficientMetalOverlap.cpp` | 定义via上下金属overlap/enclosure有效面积；区分缺上/下metal与部分覆盖，固定与enclosure的去重语义 | full/partial/no overlap、top/bottom、array via；rule mapping/去重固定 |
| P1 | `MinimumCutRule.hpp` + `MinimumCut.cpp` | 参数含width threshold、required cut count、within、length；kernel按连通metal和cut集合计数 | N-1/N cuts、宽度阈值、多个via groups、cluster边界；count一致 |
| P1 | `MaxViaStackRule.hpp` + `MaxViaStack.cpp` | 参数含最大连续stack和豁免层；沿同坐标/重叠cut建立层图并求最长连续链 | max/max+1、断层、offset、parallel vias；stack length/层列表对齐 |
| P0 | `FloatingPatchRule.hpp` + `FloatingPatch.cpp` | **kernel当前空函数**。定义floating patch为未连接pin/via/main polygon；若连通性输入不足标unsupported，不能仅靠几何猜 | connected by edge/via/pin、true island、env连接、同net多polygon；实现前不得checked |
| P0 | `JogToJogSpacingRule.hpp` + `JogToJogSpacing.cpp` | **kernel当前空函数**。表达jog width/length/within/parallel run支持子集；实现boundary pattern识别或标missing | true/false jog pair、边界、旋转、与notch/EOL区分；实现前不得checked |
| P1 | `OffGridOrWrongWayRule.hpp` + `OffGridOrWrongWay.cpp` | 将off-grid与wrong-way拆成可独立coverage语义；参数含manufacturing grid、preferred direction及例外 | on/off grid 1 DBU、preferred/nonpreferred、via/patch、原点偏移；两子规则独立分桶 |
| P1 | `OutOfDieRule.hpp` + `OutOfDie.cpp` | 明确die/core检查边界；kernel处理shape越界、跨界、空/退化，不把touch边界报错 | inside/touch/cross/outside、negative coord、cut/routing；bbox精确 |

### D. GDS、toolkit、build 与验证 leaf

| Pri | Leaf 文件 | 文件级任务 | DoD / focused test |
|---|---|---|---|
| P2 | `source/module/gds_plotter/GDSPlotter.hpp`, `GDSPlotter.cpp` | debug plot只读`DRCCheckResult`，layer/datatype与routing/cut/type稳定映射；原子写；错误不改变检查结果 | on/off violation hash一致、bad path/layer、GDS parser round-trip |
| P2 | `.../gp_data_manager/GPBoundary.hpp`, `GPDataType.hpp`, `GPGDS.hpp`, `GPLYPLayer.hpp`, `GPPath.hpp`, `GPStruct.hpp`, `GPText.hpp`, `GPTextPresentation.hpp` | 每DTO校验layer/datatype/坐标/path width/text escape/presentation；stable struct order；超GDS范围失败 | DTO golden、空/长名/越界/特殊字符；round-trip |
| P0 | `source/toolkit/logger/ErrorExit.hpp`, `LogLevel.hpp`, `Logger.hpp`, `Logger.cpp` | 可恢复错误不exit；fatal只用于程序不变量；结构化run/rule/cluster/shape IDs；并发sequence稳定；quiet不隐藏summary | 扩`LoggerExitTest.cpp`覆盖错误分类、quiet、parallel；业务错误result非零 |
| P1 | `source/toolkit/monitor/Monitor.hpp`, `Monitor.cpp` | 结构化wall/cpu/RSS/peak、nested scopes、thread count；可注入clock/memory；结果进入RVSummary | monotonic/nested/parallel；per-rule runtime和total守恒 |
| P1 | `source/toolkit/utility/Utility.hpp`, `Utility.cpp` | 集中canonical geometry predicate并写contract；file输出原子；lookup/conversion返回result；rule kernel不得复制不同overlap/distance | property/fuzz、bad file/config、cross-rule geometry一致；ASan/UBSan |
| P0 | 所有 `CMakeLists.txt`（`interface/`、`source/data_manager/`、`source/module/{rule_validator,gds_plotter}`、`source/toolkit/**`） | 生成rule registry/source manifest；每rule capability由metadata+test证据，不由链接推断；为26规则注册参数化microcase；Calibre harness独立label | 0 orphan/duplicate；三空kernelcapability missing；`ctest -N`每rule至少一正一反case |
| P0 | 新增 `test/rules/<RuleName>Test.cpp` 或等价参数化fixture | 每条规则至少clean、single violation、exact boundary、rotation/translation、cluster edge、thread determinism；输入和expected C-VIO入repo | 26×最小矩阵；mutation清空kernel/改比较符被对应test杀死 |
| P0 | 新增 Calibre subset matcher/harness（iDRC侧提供canonical artifact） | 在rule+layer内做bbox/shape匹配，输出TP/FP/FN/precision/recall/F1和unmatched归因；核心short/spacing/width/enclosure FN=0；unsupported不进分母但单列 | 同GDS/deck/hash；故意平移bbox和漏一条violation时harness必失败 |

### iDRC leaf 完成顺序

1. `RuleValidator.hpp/.cpp` + `RuleCoverage.hpp/.cpp` 先把“parameter loaded、kernel implemented、microcase qualified”三态分开，三个空kernel立即从checked移出。
2. `DRCInterface` + `Violation/ViolationType` + coverage schema 统一typed result和C-VIO，填真实deck/parameter hash，I/O失败进入rc。
3. 先闭合 MetalShort、PRLSpacing、MinimumWidth、MinimumArea、Enclosure 五个核心子集，再按26规则表逐条完成microcase。
4. 通过1/N线程、TSan和stable hash后接Calibre matcher；未有真实deck+Calibre证据前，`signoff_clean`继续恒false。
5. 最后再做iRT/iECO repair hint回灌，编排与DB mutation归平台所有。
