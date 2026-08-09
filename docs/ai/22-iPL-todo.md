# 22 · iPL commercial-parity TODO

事实源：`docs/ai/22-iPL.md` rv2.x。完成口径以代码、iEDA 重跑、QoR A/B、失败传播和 artifact exhibit 同时存在为准。

## 当前结论

- iPL 是全链 PPA 主战场，代码资产真实且大，但多条关键路径存在假成功/守卫失效/配置死结构。
- 宏规划主责在 iPL；iFP 只提供约束。
- DP/TDP/拥塞/宏/QP 都必须以缺省零回归和可杀实验晋级。

## P0 - 假成功与失败传播

- [ ] `runFlow` 不得丢弃 `runLG/runGP/runDP/runMP` 返回值；任一 hard fail 必须让 Tcl/Python 非零。普通/AI flow、iPL IO 和 standalone MP/GP/LG/DP 已接通真实返回值；`ipl_api_failure_injection_test` 已覆盖 MP/GP/LG/DP/PostGP/writeback 阶段阻断，Tcl `placer_run_dp` 已完成真实进程回归，Python 仅完成 adapter contract，尚待 Python 进程级失败注入回归。
- [ ] `runGP` 从 void 改为结构化结果，包含 divergence、overflow、HPWL、iteration、reason。`PLAPI::runGPResult()` 已对外返回 typed `PlacementFlowResult`，`runFlow/runAiFlow` 保留 legacy bool 适配；`ipl_run_gp_result_test` 已用 `gcd_sky130_a` 的真实 LEF/DEF 通过，并断言 GP typed status 与 stage artifact 字段；阶段失败注入、GP→LG 阻断和真实 Tcl 命令返回码已通过，仍待 synthetic divergence death test。
- [x] `PLAPI::isSTAStarted` 恢复真实查询，并增加 STA 未初始化 / 已初始化两类测试。实现查询 `ExternalAPI::isSTAStarted()`；`ipl_sta_started_test` 已覆盖未初始化、LEF/DEF 加载、`initSTA`、graph build 和已初始化状态，并在可写 `/tmp` 输出目录通过；全 flow TDP coverage gate 仍待补。
- [x] MacroPlacer 未实现或无可行解必须失败，不得 `return true`。真实 MacroPlacer 已接入，失败不写回 source DB，并恢复 movable macro 的 shape/state；route-halo 成功、不可行约束失败、fixed macro 冲突失败和 shape/state rollback 的新链接测试已通过。
- [ ] 写出 `ipl_stage_report.json`：每阶段 status、changed_count、metric_before/after、skipped reason。真实 GP/DP fixture、MacroPlacer artifact 和 Tcl DP off/on 均已产出并验证 stage JSON；DP-only artifact 还明确记录 disabled operator 的 `entered=false/reason` 和 legacy `execution_success=false`（阶段成功但完整 flow 未启动）；完整 MP→GP→LG/DP flow、只读目录失败和 schema golden 仍待补。

## P0 - macro placement 真化

- [x] `placer_run_mp` 调用真实 MacroPlacer 并校验产物：macro placed、core containment、halo/blockage legality。真实 SRAM 宏设计 `ipl_macro_placer_artifact_test` 已完成 API 路径、source DB writeback、`iPL_result.def` 序列化和 off/on artifact：off `MACRO0` 中心约 `(249952,249900)`，route-halo on 约 `(749857,249900)`，on constraint cost `0.096130`；产物目录为 `/tmp/ipl_macro_placer_artifact_test/{off,on}/pl/report/`。
- [ ] iFP 的 HALO/ROUTEHALO/channel/hint/orientation 进入 MacroPlacer legality/cost，而不是只保存在 DEF。当前通过 iDB Region 命名约定消费，focused test 覆盖 route-halo off/on/wide A/B、hint bias、channel keepout 失败回滚和 orientation 旋转；仍需 typed iFP region round-trip、flow artifact exhibit 和真实设计 A/B。
- [x] 增加 unknown macro、duplicate constraint、无可行解、fixed macro 冲突的原子失败测试。无可行解、fixed macro 冲突、unknown macro、duplicate constraint 均已通过 focused test；测试同时断言失败不提交 PlacerDB revision。
- [x] 做 constraint off/on A/B：位置或 HPWL 差异必须超过预注册阈值，证明 cost term live。已拆成 off/on/wide 三个 fixture，避免同名 route halo 冲突，测试改为检查 macro 位置差异。
- [x] 输出 macro exhibit：每个 macro 的候选、cost term、约束命中和最终拒绝原因。当前 exhibit 已输出每个 macro 的候选坐标、orientation、cost、halo/route-halo/hint/channel 计数和 reject reason；focused test 也补了 exhibit 内容断言。

## P1 - global placement QoR

- [ ] 锁定 Nesterov divergence 判定：不收敛不得继续 LG 并宣称成功。`NesterovPlaceResult` 已区分 converged/diverged/max_iter/invalid metric/overflow target miss，`runGPResult()` 已对失败回滚；仍待 synthetic divergence death test 和完整 GP→LG 阻断测试。
- [ ] 拥塞优化默认策略需做 legacy vs LUT-RUDY vs route-demand A/B，报告 HPWL、overflow、DRC、runtime。
- [ ] 恢复 timing-driven placement 的守卫路径，TDP 打开时必须有 STA coverage、endpoint coverage 和 PT/iSTA 对照。
- [ ] QP init 只能在 solver 资产和消费方 test 都齐备后接入。
- [ ] IterParam / iteration exhibit 记录 density overflow、wirelength、step length、gradient norm。`NesterovIterationRecord` 已记录这些字段；仍待稳定 JSON exhibit、重放和 QoR A/B。

## P1 - detail placement 与 legalization

- [ ] DP dead structure 清理：配置、入口、回流路径和 regression 必须一致。
- [ ] 二次 LG、PostGP、buffer insertion 的职责顺序固定，并写入 report。
- [x] NFSpread/InstanceSwap/BinOpt/RowOpt/LocalReorder 各自加目标指标与 no-op reason。NFSpread typed microcase、四个 DP 算子 artifact exhibit 和 AES DP-only off/on 已通过；InstanceSwap/LocalReorder 在 AES 上为合法稳定 no-op，BinOpt 为独立 artifact no-op，均不冒充 QoR 改善。
- [ ] Abacus 调用失败、row 不可用、site 不合法必须响亮失败。

## P2 - commercial parity

- [ ] Innovus/ICC2 place_opt 对拍：HPWL、routed WL、overflow、DRC、WNS/TNS、runtime、area。
- [ ] 按设计和 PDK 独立报告，不用总体平均掩盖失败设计。
- [ ] 至少 3 次固定 seed 重复，输出 median/MAD 和 bootstrap CI。

## 下一步执行顺序

1. **P0 rc 链**：先清假成功。
2. **P0 macro**：让 MP 真实可测。
3. **P1 GP divergence + exhibit**：防止坏布局继续往后跑。
4. **P1 DP/LG 回流**：修复布局后半段。
5. **P2 commercial A/B**：再谈默认开启。

## 验证纪律

- C++ 改动后必须重编译当前 `iEDA` 并跑 iPL focused tests。
- QoR 宣称必须有完整 flow artifact，不能只用 placement 内部 HPWL。

## Source map

| File / module | 当前定位 | 具体待办 |
|---|---|---|
| `api/PLAPI.{hh,cc}` | 主编排 | runFlow 失败传播、DP/TDP 路径、产物断言、report 汇总 |
| `api/external_api/ExternalAPI.{hh,cc}` | 外部调用桥 | iSTA/iRT/iPDN 依赖可见、异常不吞 |
| `api/report/*` | 报告层 | exhibit、A/B、stage report、JSON schema |
| `source/config/*` | 配置 | default 值台账、dead knob 清理、unknown key fail |
| `source/module/global_placer/*` | GP | congestion 默认化、divergence、QoR A/B |
| `source/module/detail_placer/*` | DP | dead structure 清理、回流、no-op reason |
| `source/module/legalizer/*` | LG | runIncrLG 接线、illegal state、row/site legality |
| `source/module/macro_placer/*` | 宏 | force+SA、约束消费、iFP halo 闭环 |
| `source/module/buffer/*` | buffer 插入 | ownership、report、与 iNO 职责边界 |
| `source/module/evaluator/*` | 估计器 | cost term 明确、A/B、signoff 分层 |
| `source/module/solver/*` | 求解器 | QP/partition 收编与外部库边界 |
| `source/test/*` | 回归 | 失败传播、A/B、artifact propagation、对拍 |

## Leaf 文件级执行台账

覆盖基线（2026-08-07 盘点，2026-08-08 复核）：`api/` + `source/` 当前共 203 个文件，其中 160 个为 `.cc/.cpp/.h/.hh` 实现或接口文件。下表把 `.cc/.hh`（或 `.cpp/.h`）视为一个可独立评审的实现单元，但会分别写明接口与实现任务；头文件-only 数据对象单列。完成一行的最低证据是：代码 diff、focused test、失败用例、产物字段或 QoR A/B 中至少与该行对应的全部项，不接受只改注释或只打印日志。

### A. API、状态与报告 leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P0 | `api/PlacementStatus.hh` | 已覆盖 MP/GP/LG/DP/PostGP/buffer/NFS/artifact 状态与 strict/compat reducer；JSON golden 仍缺 | 保持每阶段 entered/completed/changed_count、before/after HPWL、density、legality、reason；补稳定 schema/golden，禁止用 `executionSuccess()` 掩盖 strict quality failure | `PlacementStatusTest.cc` 已通过状态和未知 enum microcase；仍需 strict/compat golden JSON 和真实 artifact schema test |
| P0 | `api/PlacementResult.hh` | typed flow result 和 legacy adapter 已存在；Tcl/Python MP/GP/LG/DP wrapper 已统一适配，独立 DP 入口不再固定返回成功；进程级 Python 仍受构建开关限制 | 固定 Tcl 层真假/返回码语义，集中所有边界适配；禁止调用方各自反转 | `PlacementResultPropagationTest.cc`、`CommandBoundaryTest.cc` 已覆盖 typed/legacy adapter；Tcl `placer_run_dp` 真实进程 off/on 返回 `rc=0` 并生成 DEF，Python 仍待 BUILD_PYTHON=ON 进程回归 |
| P0 | `api/PLAPI.hh` | public stage 已从 void 改为 bool/typed GP result；no-op 语义和统一 `PlacementStageResult` 仍未完成 | 为所有生产阶段声明统一 stage result；从配置读取 strictness；暴露只读 flow status；旧 bool API 仅保留显式 legacy adapter | API 编译已覆盖部分入口；仍需所有 public stage 的 success/no-op/fail 三态测试 |
| P0 | `api/PLAPI.cc` | MP/GP/LG/DP/PostGP/NFS/buffer/writeback 已聚合返回值；GP/LG/PostGP 已接 stage transaction rollback/commit；无宏 MP 显式 skipped；DP-only 阶段成功与完整 flow reducer 已区分 | `runFlow` 按 MP→GP→buffer/NFS→LG→DP/PostGP 顺序聚合，hard fail 立即停止并落盘 summary；报告写失败进入 overall status；继续清理重复 flow 分支和 `LOG_FATAL + return` 双重语义 | `ipl_api_failure_injection_test` 已覆盖 MP/GP/LG/DP/PostGP/writeback 注入、后续阶段未进入和 revision 断言；artifact/writeback 失败为 typed failure；Tcl DP 命令级回归通过；Python 进程级和完整 flow artifact golden 仍待补 |
| P1 | `api/PLAPI.cc` 的 `runAiFlow` 分支 | AI 模型加载失败当前声称 fallback 后直接 return，实际没有执行传统 DP；与普通 flow 代码重复 | 抽取共同 stage runner；AI 初始化失败时按配置执行真实 HPWL fallback 或 hard fail，并记录 `fallback_used/model_hash`；两条 flow 的状态和产物 schema 完全一致 | ENABLE_AI on/off 两构建；坏 ONNX、坏 normalization、合法模型三用例；fallback 结果必须经过 DP legality |
| P0 | `api/external_api/ExternalAPI.hh`, `api/external_api/ExternalAPI.cc` | STA/eval/route 调用以零散 bool/void 暴露，异常、coverage、输入 hash 不可追 | 头文件定义 typed dependency result 和 timing snapshot；实现中统一检查 iSTA initialized、endpoint coverage、单位、DB revision；外部工具异常转成 stage failure，不吞掉；记录调用耗时和 input/output hash | mock iSTA 未启动、STA 失败、空 endpoint、单位不匹配；iPL summary 能追到 dependency、revision、reason |
| P1 | `api/external_api/ids.hh`, `api/ids.hh` | 两套 ID/shape DTO 容易发生 net/pin/layer 映射漂移 | 合并或明确 public/internal namespace；为 id、坐标 DBU、layer index、null sentinel 写不变量；转换函数返回错误而不是生成负索引对象 | round-trip test 覆盖 IO pin、macro pin、special net、无层对象；序列化 stable ordering |
| P0 | `api/report/PLReporter.hh`, `api/report/PLReporter.cc` | 体量大且同时承担 legality、QoR、可视化；错误多为日志，无法 gate | 在头文件拆出 report input/schema；实现输出 `place_summary.json`、stage records、metric validity、coverage、artifact hash；报告 I/O 失败向 PLAPI 返回；所有 map/list 排序后输出 | JSON schema test；只读目录/磁盘写失败；同 seed 两次 artifact hash 一致；缺字段拒绝进入 parity harness |
| P1 | `api/report/PLReport.cc` | 与 `PLReporter.cc` 有重复 legality/report 逻辑，可能产生两种口径 | 列出与 PLReporter 的功能重叠并只保留一个 canonical metric collector；旧接口成为薄 adapter；core/row/site/power/overlap 统计共享同一结果对象 | 同一 DEF 经两个 legacy 入口得到逐字段一致结果；删除重复计算后的性能无回退 |

### B. 配置、核心数据库与基础数据 leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P0 | `source/config/Config.hh`, `source/config/Configurator.cc` | 已增加非致命 JSON schema validator、required/type/range/unknown-key 检查、可选 `GP.global_right_padding` 兼容、effective config 与稳定 FNV-1a hash；flow policy、strictness、MP 配置仍缺 | 增加 flow policy、MP、artifact、seed、stage enable typed getter；继续禁止静默补空对象；输出 effective config 与 hash | `ipl_config_validation_test` 已覆盖 valid、missing、unknown、wrong type、range、malformed、optional key、round-trip/hash；`ipl_nesterov_place_config_test` 仍通过；默认 snapshot、每个 knob consumer、strictness 仍待补 |
| P0 | `source/config/pl_default_config.json` | 默认配置无法证明与代码默认一致，新增算法开关可能意外上线 | 补 `schema_version`、strict mode（CI 开、兼容档关）、固定 seed、MP/DP/拥塞各开关；逐字段与 Config getter 对照，删除 dead knob | schema validator + default snapshot；默认配置跑基线 QoR 零回归；每个非默认 knob 有 consumer test |
| P0 | `source/PlacerDB.hh`, `source/PlacerDB.cc` | 已新增 DB revision 与 stage transaction，rollback/commit 覆盖 instance shape/orient/state，并刷新 topo、重建 grid fixed/movable cache；`StageTransaction::changedInstanceCount()` 已可审计写回变化；wrapper writeback 已增加全量 preflight 和 mutation rollback，IO pin 与完整对象 hash 仍缺 | 继续补 null、重复对象、单位、坐标边界检查；完成 IO pin input/output 建模或明确 unsupported；把 wrapper update/read path 也纳入 typed result；禁止失败阶段污染 source DB | `ipl_placer_db_transaction_test` 已覆盖 rollback/commit/revision/cache；`ipl_write_back_source_database_test` 已覆盖真实 sky130 映射实例坐标/方向写回再读回、无 master preflight 失败、实例数和先前映射实例坐标不变；仍需完整 DEF hash、IO pin、region/blockage、空设计用例 |
| P1 | `source/data/Cell.hh`, `source/data/Instance.hh` | master 类型、fixed/placed 状态、orientation 与 shape 更新分散 | `Cell.hh` 固定 macro/std/filler/pad 分类；`Instance.hh` 让 location/orient/state 更新保持 bbox 原子一致，增加 invalid transition 拒绝；提供 stable ID，不以裸指针作为 artifact key | orientation 8 态、fixed move 拒绝、macro halo 后 bbox、zero-size master 测试 |
| P1 | `source/data/Design.hh`, `source/data/Layout.hh` | name lookup、region/blockage、core/row/site 的合法性缺统一入口 | `Design.hh` 检查 duplicate name 与悬空 pin/net；`Layout.hh` 验证 die/core、row/site pitch、unit；暴露 canonical legality context 给 MP/LG/DP 共用 | duplicate object、非矩形/越界 core、空 row、混合 row height；构造失败必须 typed error |
| P1 | `source/data/Net.hh`, `source/data/Pin.hh` | driver/load 方向、超大 fanout、悬空 pin 会影响 HPWL/梯度但未分档 | `Net.hh` 维护唯一 driver/多 driver/无 driver 状态和 ignore reason；`Pin.hh` 统一 instance/IO 坐标更新与 offset 旋转；所有消费者只读 canonical position | multi-driver、dangling、IO-only、macro rotated pin、degree cutoff 边界测试 |
| P1 | `source/data/Region.hh`, `source/data/Row.hh` | fence/guide/halo/blockage 语义可能只靠名字约定；row interval 无版本 | `Region.hh` 增加 typed region kind 与 owner ID，移除 `_HALO`/`blockage_list` 作为唯一语义；`Row.hh` 固化 site grid、orientation、blocked interval，并支持 transaction revision | iFP constraint round-trip；重名 halo、多个 boundary、fragmented row、alternating power row 测试 |
| P2 | `source/data/Point.hh`, `source/data/Rectangle.hh`, `source/data/Orient.hh` | 几何和方向是所有算法底座，溢出/半开区间约定未机器化 | 明确 DBU 整数范围、矩形 `[ll,ur)`、空矩形、touch vs overlap、orient composition；面积/距离用 64-bit；禁止 silent clamp | property test：平移/旋转/交并对称性、INT32 边界、零面积、边接触不算 overlap |

### C. Global placement 与 evaluator leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P0 | `source/module/global_placer/electrostatic_placer/NesterovPlace.hh`, `NesterovPlace.cc` | typed outcome/result/iteration record 已统一为 hard-fail、quality-fail、success 三类；invalid 初始/迭代梯度、零面积、零基准 divergence 和空 movable 设计均显式失败；GP failure 阻断后续 LG 且 transaction 回滚 | 保持 divergence、invalid metric、overflow miss 的质量策略；随机扰动受固定 seed 控制；稳定输出 iteration exhibit，并保持 changed instance count 与 iteration count 分离 | `ipl_nesterov_contract_test` 覆盖 NaN/Inf、负 metric、单调 iter、synthetic divergence/改善窗口和 outcome reducer；`ipl_run_gp_result_test` 真实 `gcd_sky130_a` 断言 exhibit schema、严格递增 iter、finite 数值、artifact 字段；两次真实 replay 的 `ipl_stage_report.json`/`place_summary.json` hash 均为 `e9919fdf889ec8c27964b10745e24e17f91ce43071e3561bdd6bb681f58d66b4`；仍缺 2/10/100 cell 设计级 QoR 和拥塞 A/B |
| P0 | `source/module/global_placer/electrostatic_placer/config/NesterovPlaceConfig.hh` | 已有范围校验、历史配置兼容处理和 focused boundary test；effective config/hash 仍缺 | 给参数定义范围、默认和 experimental 标记；每个字段必须有消费点；输出 effective values | `ipl_nesterov_place_config_test` 已通过；仍需 default snapshot、consumer coverage 和不可能组合测试 |
| P1 | `source/module/global_placer/electrostatic_placer/database/NesterovDatabase.hh`, `NesInstance.hh`, `NesNet.hh`, `NesPin.hh` | wrapper 对象依赖裸指针；filler/real、fixed/movable、pin offset 的生命周期风险 | `NesterovDatabase.hh` 持有 stable mapping/revision；三类对象校验 owner、坐标、degree 和 active 状态；失败迭代不得写回；输出对象计数与过滤原因 | DB rebuild/reuse、删除 net、fixed macro、filler、IO pin；ASan 下无悬空引用 |
| P1 | `source/module/global_placer/electrostatic_placer/database/BinGrid.hh` | density、RUDY、blur、overflow 聚于 header，边界 bin/容量负值风险高 | 拆出可测计算单元或至少为 bin index、fixed area、available area、route demand、Gaussian blur 加不变量；容量 clamp 必须报告，不得默默把负容量变零 | 单 bin/非整除 core/全 blockage/边界 cell；density 与手算 oracle；线程数变化一致 |
| P1 | `source/module/global_placer/electrostatic_placer/database/Parameter.hh` | 算法常量与 runtime 状态混合，容易形成 dead knob | 区分 immutable effective config 与 iteration state；移除重复参数源；每个调参项写入 exhibit，禁止静态全局可变状态 | 参数 consumer coverage；两次并行 placer 实例互不污染 |
| P1 | `source/module/evaluator/density/Density.hh`, `Density.cc`, `DensityGradient.hh`, `ElectricFieldGradient.hh`, `ElectricFieldGradient.cc` | density/电场梯度是 GP 主 cost，单位和 finite 检查未形成契约 | 明确输入为 DBU/归一化面积、输出单位和 sign；统一 exact density 与 gradient 的 bin indexing；加 finite、守恒和数值梯度检查 | 小网格 finite-difference gradient；总电荷守恒；fixed area/halo/fragmented core oracle |
| P1 | `source/module/evaluator/density/dct_process/DCT.hh`, `DCT.cc`, `FFT.hh`, `FFT.cc` | DCT/FFT 数值底座体量大，缺尺寸/归一化/线程确定性门禁 | 固定 DCT-I/II/IDCT convention、padding 和 normalization；非法尺寸 fail；缓存按 shape/revision 隔离；与直接变换 oracle 对拍 | 1x1、奇偶尺寸、非 2 次幂、随机矩阵误差阈值；不同线程 bitwise 或容差一致 |
| P1 | `source/module/evaluator/wirelength/Wirelength.hh`, `WirelengthGradient.hh`, `HPWirelength.hh`, `HPWirelength.cc` | HPWL 已统一 null/ignored/single-pin 过滤并使用 64-bit 坐标差；基类单位/validity、IO/macro/high-fanout 全口径和 degree cutoff 仍缺 | 基类声明单位、ignored-net policy、validity；HPWL 对无 driver/单 pin/IO/macro/高 fanout统一处理，64-bit 防溢出 | `ipl_hpwirelength_test` 已覆盖 empty、single-pin、ignored、手算矩形、部分线长、`INT32_MIN/MAX` 和 null topology；仍需 report/GP 口径对拍、IO/macro/high-fanout 和 degree cutoff |
| P1 | `source/module/evaluator/wirelength/WAWirelengthGradient.hh`, `WAWirelengthGradient.cc` | 基础 WA 梯度和 direct congestion 分支已增加 finite/zero-util guard；指数稳定化和高 fanout边界仍风险 | 使用稳定 log-sum-exp/截断策略并暴露 gamma；检查梯度和为零、finite；net weight 更新带 revision | `ipl_wa_wirelength_gradient_test` 覆盖有限值、平移守恒、负有限差分 descent-force oracle 和零 route utilization direct path；仍缺极小 gamma、重合 pins、10k fanout 与 HPWL 趋势对拍 |
| P2 | `source/module/evaluator/wirelength/SteinerWirelength.hh`, `SteinerWirelength.cc` | FLUTE LUT/超大 degree/重复点的 fallback 和状态不透明 | 记录 exact/FLUTE/fallback 模式与失败；去重 pin；无 LUT 或 degree 超限不得假装 Steiner；输出误差抽样 | FLUTE golden、重复点、collinear、超限 net；与 HPWL 下界关系断言 |
| P1 | `source/module/evaluator/timing/TimingAnnotation.hh`, `TimingAnnotation.cc` | timing weight 注入依赖外部 STA，coverage/单位/无约束 net 不透明 | 定义 timing snapshot hash、slack unit、endpoint coverage；按 path group/criticality 生成有界 net weight；STA invalid 时 explicit disabled，不复用旧权重 | mock slack 单调性、无约束/多时钟、STA revision 漂移；off 时坐标与 legacy 一致 |

### D. Macro、initial、legalization 与 detail placement leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P0 | `source/module/macro_placer/MacroPlacer.hh`, `MacroPlacer.cc` | 已接入 PlacerDB stage transaction，HALO/ROUTEHALO/channel/hint/orientation cost、core containment、fixed macro 冲突、unknown/duplicate constraint、blockage legality 和失败 rollback 已有 focused 覆盖；无宏设计显式 `skipped`；真实 SRAM 宏 artifact 已补齐 | 头文件继续补 typed constraints、candidate/cost/result；实现从 iFP typed region 读取 halo/blockage/fence/guide，生成 seed 可重复候选，采用已有 SA solver 或明确 infeasible；fixed macro、halo、channel、orientation、core containment 全量检查；失败不得移动原 DB | `MacroPlacerTest.cc`/`MacroPlacerArtifactTest.cc` 已覆盖约束、失败 rollback、真实宏 artifact 和 off/on A/B；SRAM LEF 使用 `sky130_sram_1rw1r_44x64_8.lef`，off/on 宏中心分别约 `(249952,249900)`、`(749857,249900)`，source DB/DEF writeback 通过；typed iFP region round-trip、SA 搜索仍待补 |
| P1 | `source/module/initial_placer/center_placer/CenterPlace.hh`, `CenterPlace.cc` | center 方案未成为显式策略 | 返回 placement result，跳过 fixed/macro，按 region/core 合法 clamp；仅作为 deterministic baseline，不隐式生产启用 | 0/1/N cell、region、fixed；同输入 deterministic；结果标 baseline |
| P1 | `source/module/initial_placer/random_placer/RandomPlace.hh`, `RandomPlace.cc` | 当前为生产默认，随机 seed 与区域/宏障碍消费需核实 | 注入 seed；只放 movable std cell；尊重 region/blockage/macro halo；无合法采样点返回 infeasible；输出 seed 与 rejected samples | 同 seed hash 一致、不同 seed 可变；高 blockage 不死循环；非法 region hard fail |
| P0 | `source/module/legalizer/Legalizer.hh`, `Legalizer.cc` | bool 无失败原因；全量和增量共享单例状态，更新顺序不透明 | 定义 `LegalizationResult`（unplaced/overflow/displacement/illegal reason）；每次 init 清理或核验 revision；Abacus/row assignment 失败上抛；增量 LG 只移动允许集合并保留 fixed/untouched hash | no-row、窄 row、多高度、fence、fixed overlap；全量/增量 legality；失败 rollback |
| P1 | `source/module/legalizer/config/LegalizerConfig.hh` | displacement、线程、增量窗口缺有效范围与报告 | 增加 max displacement、row policy、strict legality；默认值与 config schema 同步；每项有消费点 | bad range fail；effective config 写入 stage record |
| P1 | `source/module/legalizer/database/LGDatabase.hh`, `LGDatabase.cc`, `LGLayout.hh`, `LGLayout.cc` | DB/layout 转换决定 row/interval 正确性 | 建立 source revision 和 stable ID 映射；layout 构建时验证 row height/site pitch/core；失败返回错误列表，不留半构建对象 | fragmented rows、mixed height、空 site、重复 interval；round-trip test |
| P1 | `source/module/legalizer/database/LGCell.hh`, `LGCell.cc`, `LGInstance.hh`, `LGInstance.cc` | cell width/orient/power rail 和 instance 状态是 legality 根源 | cell 记录 site width/height class/power compatibility；instance 记录 origin、target、allowed rows、fixed/region；位置更新原子化 | multi-height、odd/even rail、orientation、fixed move、max displacement |
| P1 | `source/module/legalizer/database/LGInterval.hh`, `LGInterval.cc`, `LGRegion.hh`, `LGRegion.cc`, `LGRow.hh`, `LGRow.cc` | interval/region/row 切割若有 off-by-one 会生成假合法 | 统一半开 site index；blockage/fence 切割去重排序；region-row membership 可审计；row capacity 与实际占用守恒 | 边界 touch、1-site gap、重叠 blockage、嵌套 region；手算 capacity oracle |
| P0 | `source/module/detail_placer/DetailPlacer.hh`, `DetailPlacer.cc` | `DetailPlacementResult` 已进入；RowOpt、global swap、vertical swap、LocalReorder、BinOpt 均有独立 transaction wrapper，失败恢复 source DB 与 DP 内部坐标；BinOpt 保持生产默认关闭；AES DP-only off/on 已形成可复核 stage artifact | 继续为五算子补统一 acceptance/预算和设计级收益；BinOpt 保持显式 dead path/default off，除非未来证据满足接入门槛 | 四个 DP focused test、LocalReorder 多窗口/预算测试和 strict AES DP-only artifact 已通过：off HPWL `879757224`；RowOpt `879757224→870301676→868127791→867476895`；InstanceSwap `0` accepted；LocalReorder `window_count=0/search_count=0/search_budget=2000/max_window=3/budget_exhausted=false`；BinOpt `candidate_count=32512/changed_count=0`；均 legal，Tcl off/on DEF hash 已验证不同；仍缺 accepted swap oracle、LocalReorder AES QoR 改善和 BinOpt 生产接入证据 |
| P0 | `source/module/detail_placer/DPOperator.hh`, `DPOperator.cc` | 所有算子共享移动/窗口/HPWL操作，错误会扩散全 DP | 提供 transaction proposal/commit/rollback；边界、row/site、region、overlap 检查集中化；增量更新 topology/grid 后校验 revision | move/swap/cluster proposal property test；失败后坐标、HPWL、grid hash 不变 |
| P1 | `source/module/detail_placer/config/DetailPlacerConfig.hh` | 算子 enable/次数/窗口可能与代码死路径不一致 | 为 RowOpt/Swap/Reorder/BinOpt/NFSpread 分别定义 budget、acceptance epsilon、seed；unknown/dead 字段 fail | config-consumer test；默认算子序列 snapshot |
| P1 | `source/module/detail_placer/database/DPDatabase.hh`, `DPDatabase.cc`, `DPDesign.hh`, `DPDesign.cc`, `DPLayout.hh`, `DPLayout.cc` | DP 有独立数据库，source/DP 双状态同步风险高 | 加 source revision、build error、commit boundary；设计/布局只读部分 immutable；DP 完成一次性写回并校验对象计数 | rebuild、rollback、对象增删、row/core mismatch；source/DP hash 对照 |
| P1 | `source/module/detail_placer/database/DPCell.hh`, `DPCell.cc`, `DPInstance.hh`, `DPInstance.cc`, `DPNode.hh`, `DPNode.cc` | 尺寸/状态/链表节点关系影响局部移动正确性 | 约束 owner 与生命周期；实例 origin/current/candidate 分离；node 前后关系检查无环；多高度/固定实例不可进入非法算子 | ASan + 链表不变量；move/swap 后 owner、坐标、占用一致 |
| P1 | `source/module/detail_placer/database/DPNet.hh`, `DPNet.cc`, `DPPin.hh`, `DPPin.cc` | 局部 HPWL delta 依赖 pin cache，旋转/移动后易 stale | pin 坐标按 instance revision lazy/update；net bbox cache 有 dirty 标志；delta HPWL 与全量 HPWL 对拍 | 随机 1000 次 move/swap，每次 local delta==full oracle；IO/macro pin |
| P1 | `source/module/detail_placer/database/DPBin.hh`, `DPBin.cc`, `DPCluster.hh`, `DPCluster.cc`, `DPSegment.hh`, `DPSegment.cc` | bin/cluster/segment 容量、排序、拆分决定可行空间 | 明确 site-index 半开区间、capacity/used 守恒；cluster merge/split 保序；segment 不跨 blockage/region | 1-site gap、零容量、重叠 segment、cluster 边界；随机布局 invariant |
| P1 | `source/module/detail_placer/database/DPInterval.hh`, `DPInterval.cc`, `DPRegion.hh`, `DPRegion.cc`, `DPRow.hh`, `DPRow.cc` | row/region interval 与 LG 可能形成两套 legality | 抽取或逐项对齐 LG 的 row/site/region convention；输出转换差异；禁止 DP 接受 LG 拒绝的坐标 | 同一 testcase 经 LG/DP checker 结论一致；多 region/multi-height |
| P1 | `source/module/detail_placer/operation/RowOpt.hh`, `RowOpt.cc`, `RowOptResult.hh` | 已返回 completed/no-op/invalid/illegal、changed count、HPWL before/after、legality 和 reason；独立 wrapper 提供 source+DP rollback；AES RowOpt 已有真实 off/on QoR | proposal 继续补局部 HPWL+displacement 排序和非退化 acceptance；记录 visited/accepted/rejected reason，并将结果写入 stage artifact | `ipl_row_opt_test` 和 strict AES artifact 已通过；RowOpt `879757224→870301676`，最终 DP `867476895`，合法且 DEF 写回后 hash 改变；仍需 accepted/rejected 计数、拥挤 row 和多 seed 稳定性 |
| P1 | `source/module/detail_placer/operation/InstanceSwap.hh`, `InstanceSwap.cc`, `InstanceSwapResult.hh` | global/vertical 已返回 candidate/accepted/changed、HPWL、legality 和 no-op reason；独立 wrapper 对有变化路径提交、no-op 不递增 revision，失败恢复 source+DP；AES 结果为合法 no-op | 限制候选窗口与兼容 height/region；delta cost 用全量抽样校验；每次 accepted swap 继续收敛到 proposal transaction | `ipl_instance_swap_test` 和 strict AES artifact 已通过：global/vertical candidate/accepted/changed 均为 0，HPWL 不变；不能宣称 AES QoR 改善；仍需 accepted swap oracle、region/height/delta 随机对拍 |
| P1 | `source/module/detail_placer/operation/LocalReorder.hh`, `LocalReorder.cc`, `LocalReorderResult.hh` | 已返回 completed/no-op/invalid/illegal、candidate/accepted/changed、HPWL、legality 和 reason；支持多实例窗口与搜索预算；AES 上为稳定合法 no-op | 固定最大窗口、候选去重、branch bound；保持 row/site/power；输出 search/accept count；继续补真实设计上有益窗口和 runtime 上界 | `ipl_local_reorder_test` 已覆盖单实例、多实例窗口、budget=2、确定性和 rollback；strict AES artifact 为 `window_count=0/search_count=0/search_budget=2000/max_window=3/budget_exhausted=false`，HPWL 不变；仍需 AES QoR 改善或明确 no-op 门槛、timeout 失败注入 |
| P1 | `source/module/detail_placer/operation/BinOpt.hh`, `BinOpt.cc`, `BinOptResult.hh` | 已返回 completed/no-op/invalid/illegal、candidate/changed、HPWL、legality 和 reason；独立 wrapper 提供 source+DP rollback；生产开关默认 `0` | 先保持独立 artifact 路径；若收益达门槛再接 config，否则继续保留生产 dead path/default off；不得用无 QoR artifact 的单次日志证明收益 | `ipl_bin_opt_test` 和 strict AES artifact 已通过：`candidate_count=32512`、`changed_count=0`、HPWL 不变、legal；默认配置 `enable_bin_opt=0`，当前不接入生产流程 |
| P1 | `source/module/detail_placer/operation/NFSpread.hh`, `NFSpread.cc` | 1117 LOC 网络流铺展在 LG 前运行，失败/no-progress 不可见 | 返回 flow feasibility、moved count、overflow before/after；容量网络构造检查守恒；no path/infeasible 不得继续假成功 | typed result microcase 已覆盖 no-op、no-path、overflow improvement 和“有移动但 overflow 不下降”；NetworkFlowTest 仍待覆盖容量不足、region、blockage、多高度及随后 LG 可行 |

### E. PostGP、buffer、filler、checker 与共享管理 leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P1 | `source/module/post_global_placer/PostGP.hh`, `PostGP.cc` | 内部多处 bool helper，但 public `runPostGP` 丢结果；时序路径与 DP 二选一 | 头文件暴露 typed result；实现聚合每轮 timing move、accepted/rejected、STA revision；任何 illegal/STA failure rollback；明确 PostGP 后是否仍需 DP/LG | mock STA + top-N critical nets；off/on WNS/HPWL/displacement；失败 rollback |
| P1 | `source/module/post_global_placer/config/PostGPConfig.hh`, `source/module/post_global_placer/database/PostGPDatabase.hh` | config/DB 生命周期和 dirty set 未进入公共契约 | 配置限制迭代/窗口/权重；DB 记录 changed inst/net/pin 和 source revision，供 iSTA 增量更新；禁止裸全量 update | dirty-set 与实际坐标 diff 相等；增量/全量 STA oracle |
| P1 | `source/module/buffer/BufferInserter.hh`, `BufferInserter.cc`, `config/BufferInserterConfig.hh` | iPL 内 buffer 与 iNO/iTO ownership 重叠；runFlow 不检查结果 | 明确只处理 max-wirelength 或迁出；返回 inserted/failed nets、area、legalization need；创建对象走 DB transaction；配置验证 master/pin/length | 无合法 master、multi-driver、max length 边界；插入后 connectivity、LG、STA 一致 |
| P1 | `source/module/filler/src/MapFiller.h`, `MapFiller.cpp`, `config/FillerConfig.h` | filler 插入在布局末端，row gap、region、power rail 和重复运行风险 | idempotent 插入；按 row/site/orient/region 选择 filler chain；无法填满输出 residual gap，不生成 overlap；写回 typed result | 两次运行无新增；1..N site gap、无组合解、alternating row；最终 checker clean |
| P0 | `source/module/checker/layout_checker/LayoutChecker.hh`, `LayoutChecker.cc` | legality 已统一为 typed violation list，PLAPI/DP/reporter 共用结果路径；索引性能和 reporter 逐项一致性仍缺 | 输出 violation type、inst、row/site、bbox、required/actual；统一几何 convention；大设计使用索引、稳定排序 | `ipl_layout_checker_test` 已覆盖四类 violation 和 deterministic clique；仍需 PLReporter 统计一致、线程 hash 和大设计性能 |
| P1 | `source/module/grid_manager/GridManager.hh`, `GridManager.cc` | density/overlap/bin 查询被多个阶段增量更新，stale cache 风险 | 加 revision、bulk rebuild 与 incremental update oracle；容量、fixed/movable area、route demand 分字段；越界对象 fail | 随机移动后 incremental==rebuild；边界 bin、全 blockage、空 core |
| P1 | `source/module/topology_manager/TopologyManager.hh`, `TopologyManager.cc` | node/network/group/arc 由裸指针和手工 topo ID 管理 | stable ownership、duplicate edge 检查、DAG/cycle 状态；排序 comparator 全序；变更 net 后局部 rebuild 与全量一致 | duplicate/cycle/dangling arc；随机 graph incremental==rebuild；ASan |

### F. Wrapper、solver、utility 与 build/test leaf

| Pri | Leaf 文件 | 当前证据 / 风险 | 文件级任务 | DoD / focused test |
|---|---|---|---|---|
| P0 | `source/module/wrapper/DBWrapper.hh`, `IDBWrapper.hh`, `IDBWrapper.cc`, `database/IDBWDatabase.hh` | writeback 已有 `IDBWriteBackResult`、全量 preflight、update/create snapshot 和 rollback；真实 mapped instance 坐标/方向 round-trip 通过；standalone Tcl `def_save` 已确认写回 DEF hash 差异 | 把 update/read path 改为 expected/result；实现 layer/master/inst/net/pin/region/row 完整错误聚合和 stable source ID/revision；补 create/update 中途失败注入 | `ipl_write_back_source_database_test` 已覆盖成功 round-trip、typed preflight failure、无部分 mutation；Tcl DP off/on `def_save` 输出 SHA-256 分别为 `e7ceb7...0610`、`85d34b...31c38`；仍需 malformed iDB 聚合和中途 update/create failure rollback |
| P1 | `source/solver/nesterov/Nesterov.hh`, `Nesterov.cc` | 通用 solver 与 GP 内 Nesterov 命名重叠，收敛/finite 契约不清 | 定义 solver status、iteration callback、line-search fail；明确消费方或删除孤立 target；用 convex quadratic oracle 验证 | converged/max_iter/diverged/NaN；consumer link test |
| P1 | `source/solver/partition/Hmetis.hh`, `Hmetis.cc`, `Metis.hh`, `Metis.cc` | 外部 partition 失败、seed、空图/超大权重边界不透明 | 统一 adapter result、固定 seed、输入权重范围、external error；输出 cut/balance/runtime；无库构建 explicit unsupported | tiny graph golden、空/断连/overflow weight；同 seed deterministic |
| P1 | `source/solver/simulate_anneal/SimulateAnneal.hh`, `SimulateAnneal.cc`, `SAParam.hh`, `Solution.hh`, `Evaluation.hh` | 可用于 MP，但模板契约、seed、acceptance trace 未生产化 | 分别固化参数范围、solution clone/rollback、cost components；实现温度/终止/seed/acceptance trace；接 MP 前用 toy oracle 和性能预算 | toy TSP/packing、同 seed、invalid cost、timeout；MP consumer test |
| P2 | `source/solver/conjugate/readme.md`, `source/solver/subgradient/readme.md` | 只有 readme 的 solver 目录易被误判为可用资产 | 标为 unavailable 并从 feature/config 清单移除，或补真实 target+API+test；不得保留“未来可用”假能力 | build capability manifest 与实际 target 一致 |
| P1 | `source/utility/Geometry.hh`, `Geometry.cc`, `Utility.hh` | 多模块几何/字符串/集合 helper 的边界约定可能与 data/checker 重复 | 收敛 canonical overlap/distance/snap/clip；所有索引和转换检查范围；删除与 Rectangle 重复且语义不同的 helper | property/fuzz test；iPL 所有 checker 调用同一 overlap primitive |
| P2 | `source/module/logger/Log.hh` | logger header 是所有 placement leaf 的公共依赖，日志级别/宏可能掩盖 stage failure | 固定 structured field、fatal/error/warning 语义和线程上下文；禁止业务失败只依赖 `LOG_*`；与 `PlacementStageResult` 关联 run/stage/reason | logger contract test；业务错误即使日志关闭仍保留非零 result |
| P2 | `source/utility/Image.hh`, `Image.cc`, `MultiTree.hh`, `StreamStateSaver.hh` | debug 可视化和容器可能影响生产错误语义/生命周期 | Image 写失败回传；MultiTree 明确 ownership/cycle；StreamStateSaver 覆盖异常恢复；debug feature 不改变算法结果 | 只读目录、cycle、exception；debug on/off placement hash 一致 |
| P0 | 各级 `CMakeLists.txt`：`api/`、`api/external_api/`、`api/report/`、`source/`、`source/config/`、`source/module/**`、`source/solver/**`、`source/utility/` | 已注册 status/result/config/NFS/macro/layout/transaction/writeback/STA/GP focused targets；本轮修正 `ipl_run_gp_result_test` 的 iCTS public dependency，避免静态库链接闭包缺失 | 保持 runtime 直接依赖；MP/AI/solver feature 用明确 option；为所有 gate 注册 focused CTest；禁止 glob 吞入实验源 | `/tmp/ieda-ipl-focused` clean configure、1397-target iPL build、10 项 iPL focused CTest 均通过；ENABLE_AI on/off、全仓 clean build 和完整 flow 仍待补 |
| P0 | `test/PlacementStatusTest.cc`, `PlacementResultPropagationTest.cc`, `MacroPlacerTest.cc`, `PlacerDBTransactionTest.cc` | 状态、结果传播、route-halo/rollback、PlacerDB transaction、unknown/duplicate constraint、channel/hint/orientation microcase 已增强；完整 flow 注入仍不足 | 扩为状态组合、调用传播、MP transaction/约束 microcases；每个已知假成功点有 death/failure test | `ipl_placement_status_test`、`ipl_placement_result_propagation_test`、`ipl_placer_db_transaction_test`、`ipl_macro_placer_constraint_test` 均通过；10 项 iPL focused gate 全部通过；mutation/APITest、真实设计 A/B 仍待补 |
| P0 | `test/APITest.cc`, `APIFailureInjectionTest.cc`, `CommandBoundaryTest.cc`, `ComputationCheck.cc`, `GridManagerTest.cc`, `DCTTest.cc`, `NetworkFlowTest.cc` | APITest 已有阶段失败注入和 wrapper 边界断言；NFS typed microcase 已独立补齐；Python 进程级构建回归尚未完成 | 覆盖 flow 注入失败、数值 finite/gradient、增量 grid oracle、DCT normalization、NFS infeasible；固定 seed/tolerance | `ipl_api_failure_injection_test`、`ipl_command_boundary_test` 及本轮 12 项 focused gate 全部通过；Tcl `placer_run_dp` 进程级 off/on `rc=0` 和 DEF writeback 已通过；仍待 Python BUILD_PYTHON=ON 命令级回归、ASan/UBSan、junit/artifact |
| P2 | `test/CongEvalAPITest.cc`, `ReportCongTest.cc`, `GlogTest.cc`, `ploygonclip.cc` | 命名/职责老化，可能不是 assertive regression | 将 congestion/report 测试转成 schema+oracle；Glog 仅保留 logger contract；修正 `ploygonclip` 命名并加入几何断言，无法形成 gate 的 demo 移出 test target | 每个 executable 至少一个可失败断言；CTest 注册名与职责一致 |

### iPL leaf 完成顺序

1. 先完成 `PlacementStatus.hh` → `PLAPI.hh/.cc` → `PlacementResult.hh`，把 MP/DP/PostGP 的失败真正送到 Tcl/Python。
2. 再完成 `LayoutChecker` + `PlacerDB` transaction + wrapper，建立可复用的 legality 与 rollback。当前三者 focused 路径均已建立：wrapper writeback 已覆盖 preflight、成功 round-trip、失败无部分写入和 standalone Tcl DEF hash 差异；typed read/update 与完整对象 hash 仍待推进。
3. 然后处理 `MacroPlacer` 和 DP 五算子；每接一个算子先交 microcase，再交 AES/宏设计 A/B。
4. 最后处理 Nesterov/evaluator 数值精度和 solver 默认化；没有 off/on artifact 的开关保持关闭。

## 本轮验证记录

- 盘点命令：`find src/operation/iPL/api src/operation/iPL/source -type f`；2026-08-09 盘点为 207 个文件，其中 164 个为 `.cc/.cpp/.h/.hh` 实现或接口文件。
- 独立配置：`cmake -S . -B /tmp/ieda-ipl-focused -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC_LIB=OFF -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF -DUSE_GPU=OFF -DENABLE_AI=OFF -DCOMPATIBILITY_MODE=ON`。
- 已通过：本轮最终 21 项 iPL focused CTest 全部通过，包含状态/结果传播、失败注入、真实 GP/MacroPlacer artifact、配置、Nesterov contract、WA gradient、HPWL、NFS、LayoutChecker、PlacerDB transaction、writeback、STA 和四个 DP 算子。
- 真实 GP artifact：`/tmp/ipl_run_gp_result_test/pl/report/ipl_stage_report.json` 与 `place_summary.json` 均包含 GP `status=OK`、`changed_count=273`、`exhibit_count=434`、`metric_before/after=5204457`、`overflow=0.0998383984`；`changed_count` 为 transaction 变化实例数，`exhibit_count` 为 Nesterov 迭代数。测试还断言 exhibit schema、iter 单调递增、numeric finite、artifact 文件存在和字段齐全。
- 当前源码 AES 设计级 flow：`/tmp/ipl-aes-sky130-a-current/pl/report/ipl_stage_report.json`、`place_summary.json`、`iPL_result.def`；`macro_count=0`，MP 为 `skipped/no macros in design`，GP 为 `status=OK`、`changed_count=20436`、`overflow=0.0996258631`，DP 为 `status=OK`、`changed_count=20436`、HPWL `879464080→853320273`；summary legality 为 core/row-site/power/overlap 全 0，设计宏数为 0，因此该 run 不构成 MacroPlacer A/B。
- 完整 iPL build：`cmake --build /tmp/ieda-ipl-focused --target ipl-configurator ipl-api ipl-source -j2` 已完成并成功链接；新增配置/HPWL/GP 测试目标和后续增量重编译也通过。
- 本轮 GP 数值契约：新增 `NesterovPlaceContract.hh`，生产路径对初始/迭代 gradient、step、density penalty、route utilization、overflow 做 finite/non-negative 检查；`WAWirelengthGradient` direct congestion 路径对 null grid 和 zero utilization 显式保护；默认 `is_timing_effort=0`、`is_congestion_effort=0`，没有完整 off/on artifact 的策略保持关闭。
- 本轮真实 replay：最终 `iEDA` 连续运行两次 `ipl_run_gp_result_test`，两次 `ipl_stage_report.json` 和 `place_summary.json` SHA-256 均为 `e9919fdf889ec8c27964b10745e24e17f91ce43071e3561bdd6bb681f58d66b4`，GP 记录 `status=OK`、`changed_count=273`、`exhibit_count=434`、HPWL `5204457`、overflow `0.0998383984`；这是 GP deterministic replay 证据，不构成完整 flow 或 PT/iSTA 对拍。
- 已知环境问题：原 `build-aes13` 的 Ninja 在进入编译前段错误；不使用该构建树作为本轮证据，禁止提交其生成产物。
- 下一批必须补：Python BUILD_PYTHON=ON 命令级回归；APITest 进程级失败注入与全阶段 artifact schema golden；InstanceSwap accepted move/delta oracle；LocalReorder AES 上有益窗口或明确 no-op 门槛；wrapper malformed iDB 与中途 update/create rollback；Nesterov 2/10/100 cell 设计级 QoR；density/FFT 数值 oracle；legacy vs LUT-RUDY vs route-demand congestion A/B；TDP STA/endpoint/PT-iSTA coverage；QP solver asset 和 consumer test。
