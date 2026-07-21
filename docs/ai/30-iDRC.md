<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 30 · iDRC 设计规则检查 · 商业对标优化方案 · rv1.0

> 文档号：30-rv1.0　　版本：v2.0　　里程碑：**规则引擎实 → 覆盖表透明（G11）→ vs Calibre 子集一致 → 违例回灌 iRT**
> 体例：`01-ai-doc-conventions-rv1.md`　主纲：G11/G5/G15　Know-how：KH-DRC-01/02、KH-X-04
> 对标：**Calibre**（签核）/ **Innovus verify**（in-design）
> 覆盖：`RuleValidator.{hpp,cpp}`、`rv_design_rule/`×26、`DRCInterface.cpp`、`design_rule/*.hpp`
> 纪律：断言带 `file:line`；SKIP≠PASS。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | 有规则无覆盖表；未 vs Calibre |
| v1.1 | 2026-07-20 | 引擎摘要 |
| **rv1.0 / v2.0** | **2026-07-20** | **大改**：坐实 `verifyRVModel` OpenMP（`RuleValidator.cpp:356`）；`verifyRVCluster`（`:608+`）调度 **26** 类 `ViolationType`；`DRCInterface.cpp:153` 消费 `DRCRV.verify`。核心修订：引擎**非空壳**，缺口是 **覆盖表/假 clean/Calibre 对齐/回灌**，不是「没有 DRC」。 |

---

## 1. 症结审计

### 1.1 功能形态

| 项 | 证据 | 判定 |
|---|---|---|
| 入口 | `DRCInterface.cpp:79` init；`:153` `verify(...)` | 生产接线 |
| 并行 | `RuleValidator.cpp:356` `#pragma omp parallel for` | 真并行 |
| 规则调度 | `verifyRVCluster` `:608-680` 逐 `ViolationType` + `needVerifying` | 可跳过单类 |
| 实现文件 | `rv_design_rule/*.cpp` **26** 个 | **规则覆盖有代码** |
| 规则数据 | `data_manager/design_rule/*.hpp` 多类 | 参数化 |
| 覆盖表 | repo 无 PDK↔ieda 映射表 | **G11 缺口** |
| vs Calibre | 无 harness | **G11 缺口** |
| → iRT | 统一 JSON schema | **未验证** |

### 1.2 算法表

| kernel | 现状 | 判定 | 缺口 |
|---|---|---|---|
| Cluster 构建 | `buildRVClusterList` `:268+` | 工程化 | 大设计剖分 G13 |
| 几何谓词族 | spacing/enclosure/short/area/… | **in-design 成熟度中高** | 天线/密度等 missing 台账 |
| needVerifying | 按类型过滤 | 正确 | **skipped 必须进报告** |
| OpenMP 写违例 | parallel for | 待审线程安全 | §14 |

### 1.3 边界

- `needVerifying` 跳过 ≠ 规则不存在于 PDK——**若不打印 skipped → 假 clean（G15）**。  
- 检查对象是否最终 DEF/GDS 几何——**未验证**（D4）。  
- 0 违例 + skipped 非空 → **禁止**标 signoff clean（KH-DRC-01）。

### 1.4 跨工具

| 方向 | 现状 | 判定 |
|---|---|---|
| iRT → iDRC | 布线后形状 | 半通 |
| iDRC → iRT | 热点回灌 | 缺统一 schema |
| vs Calibre | 无 | G11 |
| platform C6 | 违例数一致 | 待测 |

### 1.5 已实现 ViolationType（代码枚举走读）

依据 `verifyRVCluster` 调用链（非完整 PDK deck）：  
AdjacentCutSpacing、CornerFillSpacing、CornerSpacing、CutEOLSpacing、CutShort、DifferentLayerCutSpacing、Enclosure、EnclosureEdge、EnclosureParallel、EndOfLineSpacing、FloatingPatch、JogToJogSpacing、MaximumWidth、MaxViaStack、MetalShort、MinHole、MinimumArea、MinimumCut、MinimumWidth、MinStep、NonsufficientMetalOverlap、NotchSpacing、OffGridOrWrongWay、OutOfDie、ParallelRunLengthSpacing、SameLayerCutSpacing（及头文件族）。  
**→ 这是 iEDA 实现集，不是 Calibre 全 deck。**

---

## 2. 需求 FR / NFR

| ID | 需求 | 现状 | P |
|---|---|---|---|
| FR-DRC-01 | 保持 26 规则引擎 | ✓ | — |
| FR-DRC-02 | ★ PDK 覆盖表进 repo | ✗ | P0 |
| FR-DRC-03 | ★ 运行时 `checked[]/skipped[]` | ✗ | P0 |
| FR-DRC-04 | ★ vs Calibre 子集 harness | ✗ | P0 |
| FR-DRC-05 | ★ 违例 JSON ≡ iRT schema | ❓ | P1 |
| FR-DRC-06 | ★ route→drc→routeECO 闭环 | ✗ | P1 |
| FR-DRC-07 | 台账驱动补规则 | — | P2 |
| NFR-DRC-01 | SKIP≠PASS | G11/G15 | |
| NFR-DRC-02 | in-design 墙钟 ≪ Calibre | 记录 | G21 |

红线：不追求 100% deck；追求**边界诚实**（KH-DRC-02）。

---

## 3. HLD

```text
iDB/DEF/GDS 形状
  → DRCInterface
  → RuleValidator.verify
       build clusters → OpenMP verifyRVCluster
       → Violation list
  → ★ coverage attach (checked/skipped)
  → ★ JSON(layer, type, bbox) → report / iRT ECO
签核真值：Calibre（可比子集对齐）
```

决策：覆盖表先于对照；in-design 定位；统一违例 JSON；不平行重写几何核。

| # | 决策 | 被否 |
|---|---|---|
| D1 | 覆盖表 P0 | 先盲追 Calibre 全绿 |
| D2 | in-design ≠ signoff | 宣称替代 Calibre |
| D3 | 与 iRT 共 schema | 各写各的 |

---

## 4. LLD（压缩）

### 4.1 覆盖表 `[新增]`

```json
{
  "pdk": "sky130",
  "rules": [
    {"foundry_id": "METAL1.SPACING", "ieda": "ParallelRunLengthSpacing",
     "state": "implemented|partial|missing", "note": ""}
  ]
}
```

每次 `run_drc` 附带 runtime 集合；CI 检查表存在（G11 起步）。

### 4.2 Calibre 对齐算法 `[新增]`

```text
S = implemented ∩ mapped_calibre_rules
同版图双方跑 → 键 (layer, rule_type, bbox_hash)
桶: geometry_bug | measure_def | mapping_error | calibre_only
```

### 4.3 回灌 `[新增]`

`iDRC JSON == 26-iRT violation_summary`；platform：`route → drc → if vios: routeECO(hot) → drc`。

### 4.4 模块状态

| 模块 | 状态 | 动作 |
|---|---|---|
| RuleValidator | 成熟 | 保；审线程安全 |
| rv_design_rule×26 | 成熟 | 台账补缺 |
| coverage | 无 | ★ |
| Calibre harness | 无 | ★ |
| iRT JSON | 未验证 | ★ |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `drc.check_types` | all implemented | |
| `drc.coverage_table` | path | 必填进 CI |
| `drc.fail_on_skipped_as_clean` | true | G15 |
| `drc.omp_threads` | env | |

---

## 6. 指标分解

| 维 | 含义 |
|---|---|
| vio_total | 总违例 |
| vio_by_type/layer | 分桶 |
| skipped_rules | **独立列** |
| wall_s | in-design |
| vs_calibre_delta | 子集差 |

---

## 7. 状态机

```text
init → load_shapes → verify → attach_coverage → emit_json → (optional) feed_irt
0 vio + skipped≠∅ → 状态 = PARTIAL_CLEAN（非 SIGN_OFF_CLEAN）
```

---

## 8. Cascade

| 边 | 信号 |
|---|---|
| iRT → iDRC | wires/vias |
| iDRC → iRT | hot bbox |
| iDRC → eval | drc_total + skipped |
| Calibre ↔ iDRC | 子集对齐 |

---

## 9. Know-how

| KH | 落点 |
|---|---|
| KH-DRC-01 | §4.1/§7 覆盖透明 |
| KH-DRC-02 | §3 in-design vs signoff |
| KH-X-04 | 假 clean 禁止 |

---

## 10. 看板 + M0–M4

| 指标 | iDRC | Calibre | 门槛 | G |
|---|---|---|---|---|
| 可比子集违例 | | | 一致或逐条解释 | G11 |
| skipped 数 | | — | 显式 | G15 |
| 假 clean | 禁 | — | 0 | G15 |
| 墙钟 | | | ≪ signoff | G21 |

对照：注入短路必报；覆盖表 CI；Calibre diff 台账；skipped 非空不得 PASS signoff。

```text
M0 覆盖表生成+进 repo
M1 运行时 checked/skipped
M2 Calibre 子集对齐
M3 回灌 iRT（G5 闭环）
M4 按台账补规则 + 大规模并行
```

---

## 11. Exhibit

`drc_summary.json`、`drc_violations.csv`、`coverage_runtime.json`、可选 bbox plot。

---

## 12. 测试

| 层 | 用例 |
|---|---|
| L0 | MetalShort 注入必报 |
| L0 | skipped 字段存在 |
| L1 | 小设计全规则跑通 |
| L4 | Calibre 子集 diff |
| L5 | PARTIAL_CLEAN 不得当 G11 PASS |

---

## 13. 里程碑

W0 表；W1 runtime 诚实；W2 harness；W3 回灌；持续补规则。

---

## 14. 未验证

| # | 项 |
|---|---|
| 1 | OpenMP 写 Violation 容器线程安全 |
| 2 | 最终态数据源（DEF vs 内部 shape） |
| 3 | 天线/密度规则缺失完整清单 |
| 4 | SameLayerCutSpacing 等与 LEF 参数绑定正确性 |

**不要重走**：无覆盖表前宣称「DRC clean=可流片」。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 覆盖表先于对照 | 盲对齐 |
| E-2 | in-design 定位 | 替代 Calibre |
| E-3 | 统一违例 JSON | 双 schema |


---

## 附 · 规则文件清单（rv_design_rule/）

AdjacentCutSpacing、CornerFillSpacing、CornerSpacing、CutEOLSpacing、CutShort、DifferentLayerCutSpacing、Enclosure、EnclosureEdge、EnclosureParallel、EndOfLineSpacing、FloatingPatch、JogToJogSpacing、MaximumWidth、MaxViaStack、MetalShort、MinHole、MinimumArea、MinimumCut、MinimumWidth、MinStep、NonsufficientMetalOverlap、NotchSpacing、OffGridOrWrongWay、OutOfDie、ParallelRunLengthSpacing、SameLayerCutSpacing（计 26）。

调度入口：`RuleValidator.cpp:608+` `verifyRVCluster`；并行：`:356` OpenMP；接口：`DRCInterface.cpp:153`。

### 覆盖表生成流程（M0）

```text
1. 枚举 ViolationType / rv_design_rule 文件名 → ieda_rules[]
2. 读 PDK rule deck（人工/脚本）→ foundry_rules[]
3. 映射表 YAML/JSON 进 repo；未映射 = missing
4. CI: 表存在 ∧ run_drc 输出 skipped ⊆ 表
```

### 与 Calibre 差异归因模板

| 桶 | 含义 | 动作 |
|---|---|---|
| geometry_bug | iEDA 几何谓词错 | 修规则代码 |
| measure_def | 测量定义不同（EOL 等） | 文档+可选对齐 |
| mapping_error | 覆盖表映错 | 改表 |
| calibre_only | 未实现 | missing 台账 |

### 违例 JSON schema（与 26 对齐草案）

```json
{
  "violations": [
    {"type": "MetalShort", "layer": "M1", "bbox": [x0,y0,x1,y1], "net": "..."}
  ],
  "checked": ["MetalShort", "..."],
  "skipped": ["Antenna", "..."],
  "status": "clean|partial_clean|dirty"
}
```

`status=partial_clean` **不得**映射为门禁 PASS。

### PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| DRC-0 | 覆盖表+生成脚本 | G11 起步 |
| DRC-1 | runtime checked/skipped | G15 |
| DRC-2 | Calibre harness | 台账 |
| DRC-3 | JSON= iRT schema | 共读 |
| DRC-4 | 回灌编排 | G5 |


### in-design vs signoff 使用策略（KH-DRC-02）

| 场景 | 工具 | 期望 |
|---|---|---|
| 迭代中快速查 short/spacing | iDRC | 秒～分钟级；允许 skipped |
| 流片前签核 | Calibre | 全 deck；iDRC 子集须可解释 |
| CI 日常 | iDRC + 覆盖表 | partial_clean 显式 |

迭代期可用 iDRC 指导 routeECO；**不得**用 iDRC clean 替代 Calibre signoff 声明。

### 线程安全审阅清单（未验证→M1 任务）

1. `Violation` 容器在 OpenMP 循环中是否有临界区；  
2. `needVerifying` 只读共享规则参数是否 const；  
3. cluster 缓存销毁时机（`RuleValidator.cpp:427` 注释）是否 race。

### 假 clean 防御测试用例

| 用例 | 期望 status |
|---|---|
| 全规则跑、0 vio、skipped 空 | clean |
| 0 vio、skipped 非空 | partial_clean |
| 有 MetalShort | dirty |
| 覆盖表缺失 | 启动 FAIL（CI） |

