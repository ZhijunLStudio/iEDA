<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 33 · iLO / iTM 逻辑优化与工艺映射 · greenfield 实施方案 · draft/D0

> 日期：2026-07-23
> 现状证据：`src/operation/iLO/CMakeLists.txt` 与 `src/operation/iTM/CMakeLists.txt` 均为 0 字节，无可执行内核。此前 `rv2.0` 只有修订说明，不能视为方案已完成。
> 建议：首阶段集成成熟开源综合后端，iEDA 负责输入/约束/物理反馈/结果导入/商业对拍；有明确差异化需求后再自建局部 kernel。
> 门禁：G18，辅 G7/G14/G15/G21；技术路线见 `04 §4.9`。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| rv2.0 header | 2026-07-22 | 仅标题和修订说明，无正文实现设计 |
| draft/D0 | 2026-07-23 | 纠正成熟度；补外部后端集成、物理反馈闭环和后续自建算法切片 |

## 1. 产品边界

首个切片接收 synthesizable Verilog、Liberty NLDM 和基础时钟/IO 约束，输出 mapped gate-level netlist、面积/逻辑深度/时序/运行时报告和 provenance。暂不承诺 SystemVerilog 全语义、UPF、DFT、memory compiler、retiming、复杂 generated clock 或完整 DC/Genus 命令兼容。

| 能力 | 当前 | 首阶段 | 后续 |
|---|---|---|---|
| frontend/elaboration | 无 | 评估复用 Yosys frontend | 仅补业务必须的语义 |
| tech-independent opt | 无 | 复用 ABC/Yosys passes | 自建差异化 rewrite 可选 |
| technology mapping | 无 | ABC cut mapping + Liberty 适配 | 多角/多 VT/物理感知 mapping |
| timing | iSTA 在其他模块 | mapped netlist 导入 iSTA/PT 对拍 | 增量 required-time feedback |
| physical feedback | 无 | placement/RC proxy manifest | iPL/iSTA 迭代闭环 |
| equivalence | 无 | 每个 pass 前后 formal/cec | ECO/复杂 sequential 后置 |

外部后端选型必须先核对版本、license、可嵌入方式、Liberty/SDC 支持和确定性。本文不把 Yosys/ABC 写成已集成事实。

## 2. 需求

| ID | 需求 | P |
|---|---|---|
| FR-SYN-01 | BackendAdapter：版本化命令/配置，不拼接不受控 shell 文本 | P0 |
| FR-SYN-02 | InputManifest：RTL/top/defines/lib/constraint/hash | P0 |
| FR-SYN-03 | MappedNetlistImporter：名称/总线/常量/blackbox 语义往返 | P0 |
| FR-SYN-04 | EquivalenceGate：每个优化阶段前后 cec/formal | P0 |
| FR-SYN-05 | SynthesisReport：cell area、buffer/inverter、depth、unmapped、runtime/RSS | P0 |
| FR-SYN-06 | Timing harness：同 mapped netlist 由 PT 与 iSTA 读取 | P0 |
| FR-SYN-07 | PhysicalContext：die/core、粗坐标、net RC/congestion proxy | P1 |
| FR-SYN-08 | 多 VT/corner candidate mapping + Pareto report | P2 |
| NFR-SYN-01 | unmapped cell=0；unsupported RTL/constraint 非零退出 | G14 |
| NFR-SYN-02 | formal equivalence 通过才可交付 | G15/G18 |
| NFR-SYN-03 | G18 每设计独立比较面积/关键延迟/功耗；不用 `R²` 代替 QoR | G18 |

## 3. HLD

```text
RTL + defines + top + Liberty + constraint manifest
                     │
                     ▼
            BackendAdapter (versioned)
          elaborate → generic opt → map
             │          │          │
             └─ equivalence gate ──┘
                     │
                     ▼
 mapped Verilog + name map + synthesis_report.json
          │                         │
          ├─ iDB/iPL physical seed  └─ PT/iSTA/evaluation
          └─ PhysicalContext ─────────→ optional remap loop
```

Backend 运行在隔离输出目录，命令、环境、版本、输入和输出全部进入 manifest。失败、unmapped、latch/blackbox 异常和 formal inconclusive 均非零退出。

## 4. 实现细节

### 4.1 BackendAdapter

用结构化配置生成固定 pass pipeline：`read/elaborate → normalize → generic optimize → map → cleanup → write`。允许的 pass 和参数必须白名单化，日志解析只作辅助，真正完成条件是产物存在、schema 通过和 equivalence PASS。

两个后端/effort A/B 使用 immutable artifact 和独立输出目录，不在用户工作区切分支或覆盖 netlist。

### 4.2 名称与约束映射

综合会复制、删除和重命名对象。必须输出 `name_map.json`：原 RTL hierarchy/bit → mapped instance/net/pin；一对多和删除带 reason。SDC 的对象命中率在综合前后分别报告，0 命中不是 warning 后继续。

首阶段只支持明确清单内的 clock/IO delay/dont_touch/max fanout 等约束；false/multicycle path 不由 LLM 自动生成。

### 4.3 Technology mapping 内核（后续自建时）

若外部后端无法满足差异化需求，自建顺序为：

1. canonical AIG/MIG + structural hashing。
2. 4–6 input cut enumeration，按 truth table/NPN class 匹配 library supergate。
3. DAG dynamic programming 保存 `(arrival, area, leakage, cap)` Pareto states。
4. required-time 反向传播，关键 cut 优先 delay，非关键区 area recovery。
5. load/slew 由 iSTA/Liberty 重算；高扇出调用 iNO/buffer tree，不用 unit-load 常数冒充。
6. 每个 rewrite/map pass 做 equivalence；失败回退前一 checkpoint。

cut enumeration 复杂度受 `K` 和每节点 cut cap 限制；不设 cap 会组合爆炸。多角多 VT 状态按 Pareto dominance 剪枝，并保留 worst scenario。

### 4.4 物理感知闭环

```text
map R0 → coarse place/RC estimate → annotate net delay/congestion
      → remap critical cones + buffer high fanout
      → incr place/STA → accept/rollback → full PT rescore
```

只重映射 critical/overloaded cones，设置 changed-cell/area/runtime budget。accept 条件先 formal、DRV、setup/hold 硬约束，再比较 area/power；任何物理回馈缺失时明确回落 wireload/estimate 档并标 provenance。

## 5. 配置

```yaml
synthesis:
  backend: yosys_abc       # 候选，需选型工作包确认
  effort: baseline
  fail_on_unmapped: true
  require_equivalence: true
  supported_constraints: [clock, input_delay, output_delay, dont_touch, max_fanout]
  physical_feedback: false
  seed: 1
```

参数包版本化，不能在不同设计上手工改完后仍声称同 effort parity。

## 6. 指标

硬门禁：elaboration errors、unmapped、formal status、constraint object coverage、combinational loops、multi-driver。

QoR 独立报告：PT WNS/TNS/critical delay、library cell area、leakage/dynamic power（活动源固定）、cell count、buffer/inverter count、logic depth。性能报告 wall/cpu/RSS 和各 pass 占比。

`R²` 只可用于大量 endpoint delay 的诊断，不能证明映射面积/关键延迟已达到 G18。

## 7. 状态机

```text
INIT → ELABORATED → GENERIC_OPT → MAPPED → EQUIV_PASS → ANALYZED → DELIVERED
          └──────────── any error/unmapped/inconclusive ───────────→ FAILED
```

只有 `DELIVERED` 返回 0。formal timeout 为 `INCONCLUSIVE`，不能当 PASS。

## 8. 跨工具契约

| 工具 | 契约 |
|---|---|
| iDB | mapped Verilog/name map/Liberty master 完整导入 |
| iSTA/PT | 同 netlist/lib/SDC；endpoint/constraint coverage |
| iNO | 高扇出 repair 的 changed objects + formal recheck |
| iPL | coarse coordinates/congestion/RC estimate + stable IDs |
| evaluation | synthesis_report + manifest + commercial side report |

## 9. 对照实验

| ID | 实验 | 杀死条件 |
|---|---|---|
| E-SYN-01 | 常量、总线、generate、blackbox 微例 | 导入后语义或名称映射错误 |
| E-SYN-02 | 每 pass mutation + equivalence | 非等价仍交付 |
| E-SYN-03 | generic/map effort sweep | 参数变化无可复现单调/权衡关系 |
| E-SYN-04 | physical feedback off/on | PT QoR 无改善或 area/DRV 代价失控 |
| E-SYN-05 | DC/Genus 同输入同约束 | 任一设计硬门禁失败或指标被总体均值掩盖 |
| E-SYN-06 | 1/2/4/8 threads、pass profile | 声称加速但 e2e/peak RSS 无收益 |

## 10. 演进与工作包

| 阶段 | 交付 | 退出 |
|---|---|---|
| M0 | backend 选型 spike + license/功能矩阵 | 3 个微设计可重复映射 |
| M1 | Adapter/manifest/import/report/equivalence | 3 个设计 D2；错误响亮失败 |
| M2 | PT/iSTA/DC/Genus harness | 每设计独立面积/延迟 baseline |
| M3 | PhysicalContext + critical-cone remap | holdout 上 PT PPA A/B 有效 |
| M4 | 决定是否自建 cut mapper/multi-VT | 有明确外部后端缺口和 ROI 才立项 |

首批 PR：SYN-0 选型报告 → SYN-1 adapter/manifest → SYN-2 importer/name map → SYN-3 equivalence/report → SYN-4 commercial harness。禁止在 SYN-0 前创建投机性 AIG/QP 目录冒充进展。

## 11. 未验证 / 风险

- Yosys/ABC 在目标部署、license 和所需 Liberty/SDC 能力下是否适合作为后端，尚未验证。
- 当前 benchmark 的 RTL family、PDK 派生样本独立性和 commercial synthesis 输入等价性尚未冻结。
- 物理感知 synthesis 的首个收益瓶颈可能在 STA/RC/placement 契约，而非 mapping kernel。
- 不要把 iNO fanout repair 宣称为完整综合。
- 不要先训练 NN/RL 选择 pass；先建立确定性 pipeline、formal gate 和商业 baseline。

## 附录 A · 成熟度升级

- D0→D1：BackendAdapter 和 3 个 microcases 合入。
- D1→D2：equivalence/unsupported/constraint coverage 测试通过。
- D2→D3：至少 3 个真实设计 mapped netlist 可进入 iPL。
- D3→D4：冻结 protocol 下 G18 跨 design family/PDK 通过。
