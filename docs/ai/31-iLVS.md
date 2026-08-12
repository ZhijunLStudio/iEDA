<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 31 · iLVS 版图原理图对照 · greenfield 实施方案 · draft/D0

> 日期：2026-07-23；M1 状态更新：2026-08-12
> 现状：`src/operation/iLVS/` 已进入 M0/M1 skeleton；此前 `rv2.0` 正文全为 placeholder，不能视为已设计或已实现。
> 首个切片：标准单元数字设计的 connectivity LVS；暂不承诺 analog device recognition、参数化器件、复杂层次 reduction 和 full-chip signoff。
> 金标：Calibre nmLVS；门禁：G12，辅 G14/G15；技术路线见 `04 §4.9`。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| rv2.0 placeholder | 2026-07-22 | 只有章节占位符，错误地形成高成熟度外观 |
| draft/D0 | 2026-07-23 | 降级为真实成熟度；给出标准单元 connectivity LVS 的最小纵向切片、算法和验收 |
| draft/D1 | 2026-08-12 | 落地 M0/M1 skeleton、Verilog canonical loader、snapshot/iDB layout adapter、WL refinement + bounded backtracking microcases |

## 1. 症结与边界

| 项 | 现状 | 首阶段目标 | 非目标 |
|---|---|---|---|
| 代码 | M0/M1 skeleton 已建 | 新建最小 library/API/CLI | 不追求一次覆盖完整 Calibre |
| 参考输入 | 无 | 独立 gate-level Verilog/SPICE-like canonical netlist loader | 不从 layout extraction 结果反生 reference |
| 版图输入 | iDB/GDS 能力待 round-trip 门禁 | 从已检查的 iDB shapes/pins/nets 构造 extracted connectivity | 未覆盖层/器件不静默忽略 |
| 匹配 | 无 | 标准单元 instance/pin/net 的分区细化 + 局部回溯 | MOS 参数、analog subcircuit 后置 |
| 报告 | 无 | open/short/missing/extra/swap/unsupported 分类 JSON | 不用单一 clean 布尔值 |

核心不变量：reference 与 extracted graph 的 provenance 必须独立。输入 manifest 校验 URI/inode/SHA-256，且两者不能共享构建对象；违反时拒跑。

## 2. 需求

| ID | 需求 | P |
|---|---|---|
| FR-LVS-01 | ReferenceLoader：Verilog 首选，canonical cell/pin/net graph | P0 |
| FR-LVS-02 | LayoutConnectivityExtractor：从 iDB routing/pin geometry 生成 graph | P0 |
| FR-LVS-03 | Coverage manifest：recognized/skipped/unsupported layers/cells/devices | P0 |
| FR-LVS-04 | GraphMatcher：签名分区、迭代着色、歧义分区回溯 | P0 |
| FR-LVS-05 | DiffReporter：open/short/missing/extra/pin-swap | P0 |
| FR-LVS-06 | Hierarchy/blackbox：明确配置，端口必须匹配 | P1 |
| NFR-LVS-01 | 四类注入差异检出率 100%，无差异 case clean | G12 |
| NFR-LVS-02 | unsupported 非零退出；SKIP 不得算 PASS | G14 |
| NFR-LVS-03 | 同输入重复运行 canonical report hash 一致 | G15 |

## 3. HLD

```text
reference Verilog ─ ReferenceLoader ─ canonical ref graph ─┐
                                                           ├─ GraphMatcher ─ diff.json
iDB/GDS ─ coverage check ─ ConnectivityExtractor ─ ext graph┘
       │
       └─ unsupported layer/device → nonzero exit
```

首阶段的 extracted graph 以已存在的标准单元 instance/pin/net 和 routed connectivity 为主。若目标是“从纯 GDS 识别器件”，需要额外的 layer mapping、polygon connectivity、device recognition 和 reduction 项目，不能由本切片冒充。

## 4. LLD 与算法

### 4.1 数据模型

```cpp
struct LvsVertex { StableId id; VertexKind kind; std::string type; PinRole role; };
struct LvsEdge { StableId a, b; EdgeKind kind; };
struct LvsGraph { std::vector<LvsVertex> vertices; std::vector<LvsEdge> edges;
                  Provenance provenance; Coverage coverage; };
struct LvsDiff { DiffKind kind; std::vector<StableId> ref_ids, ext_ids;
                 std::string reason; };
```

名字不是主匹配键；层次重命名、网名丢失时仍应依靠类型、pin role 和邻接结构匹配。报告保留原始名字用于调试。

### 4.2 Connectivity extraction

1. 规范化 shape 到 DBU 和 layer-purpose。
2. 同层 polygon/segment 用 R-tree 候选查询 + exact intersection/overlap 合并。
3. via/cut 按 tech mapping 连接上下 routing layer；缺 mapping 为 unsupported。
4. pin shape 与导体组件相交后挂到 instance pin。
5. 每个 connected component 形成 extracted net；跨 reference net 合并候选标 short，reference net 被拆分标 open。

复杂度：空间索引后约 `O((S+I) log S + K)`，`S` 为 shape 数，`I` 为 pin/via 数，`K` 为真实邻接数；禁止全 shape 两两相交 `O(S²)`。

### 4.3 Graph matching

```text
color0(v) = hash(kind, cell/device type, pin role, degree)
repeat:
  color_next(v) = hash(color(v), multiset(color(neighbor), edge_kind))
until partitions stable

match unique color classes
for ambiguous classes:
  choose smallest class
  backtrack candidates with degree/type/pin-role filters
  propagate local colors; prune inconsistency
```

该方法类似 Weisfeiler-Lehman 分区细化，工程上用于快速消除绝大多数唯一结构；对对称电路仍需有界回溯。搜索预算耗尽返回 `inconclusive`，不能返回 clean。标准单元 pin swap 仅在 liberty/配置声明等价时允许。

### 4.4 差异分类

| 观测 | 分类 | 证明 |
|---|---|---|
| 一个 ref net 对应多个 ext component | open | component IDs + 断点附近 shapes |
| 多个 ref net 对应一个 ext component | short | ref net 集 + bridge shapes |
| cell/type/pin 不对应 | missing/extra/swap | 最小不匹配子图 |
| 未识别 layer/device/cell | unsupported | coverage manifest；非 clean |
| 搜索预算耗尽 | inconclusive | explored states/budget |

## 5. 配置

```yaml
lvs:
  mode: stdcell_connectivity
  hierarchy: preserve
  blackbox_macros: []
  equivalent_pin_groups: {}  # 必须来自库/用户显式声明
  graph_search_budget: 100000
  fail_on_unsupported: true
```

缺省严格失败。未来器件参数 tolerance 必须按 device/property 单独配置，不能设全局百分比。

## 6. 指标

- reference/extracted vertex、edge、net、instance 数。
- unique/ambiguous partition 数，backtrack states，wall/RSS。
- open/short/missing/extra/swap/unsupported/inconclusive 数。
- coverage：layer/cell/device checked/skipped/unsupported。

LVS 是分类/等价问题，`R²`、MAE 不适用。

## 7. 状态与失败语义

```text
UNINITIALIZED → INPUTS_VERIFIED → EXTRACTED → MATCHED → CLEAN|MISMATCH
                                     └────────→ UNSUPPORTED|INCONCLUSIVE|ERROR
```

只有 `CLEAN` 可退出 0。`MISMATCH`、`UNSUPPORTED`、`INCONCLUSIVE` 和 `ERROR` 均退出非零，但 error code 分开，便于 CI 判断设计差异与工具失败。

## 8. 跨工具契约

| 来源 | 契约 |
|---|---|
| iDB | stable ID、DBU、layer-purpose、pin geometry、routing/via connectivity、input hash |
| iDRC | 只提供几何问题辅助；DRC clean 不代表 LVS clean |
| platform | 两个输入 provenance、expected report、非零 rc 传播 |
| evaluation | 消费 `lvs_summary.json`，不得只读取“clean”日志字符串 |

## 9. Know-how 映射

- KH-LVS-01：独立参考网表，manifest 与对象零共享。
- KH-LVS-02：注入差异必报。
- KH-X-04：unsupported/inconclusive 响亮失败。
- KH-X-11：覆盖和最坏分类联合报告，不做单一分数。

## 10. 对照与演进

| 阶段 | 交付 | 退出 |
|---|---|---|
| M0 | 10 个 hand-written graph microcases | open/short/swap/rename/对称图结果正确 |
| M1 | Verilog loader + iDB snapshot/adapter + bounded backtracking | 小标准单元设计与 canonical netlist 对拍 |
| M2 | matcher + JSON diff | 四类注入 100% 检出；无差异 clean |
| M3 | hierarchy/blackbox + Calibre harness | 同一支持子集差异分类一致 |
| M4 | 评估纯 GDS device extraction | 单独立项，不自动继承 G12 |

## 11. Exhibit

`lvs_summary.json` 必填：input hashes、coverage、graph counts、status、diffs、search budget、binary SHA-256。M1 已输出机器可消费 summary；人读的最小不匹配子图仍待补。

## 12. 测试

| 层 | 用例 |
|---|---|
| L0 | graph color/refinement、对称图、budget exhausted |
| L1 | shape/via/pin connectivity、DBU/layer mapping |
| L2 | 注入 open/short/missing cell/pin swap/renaming |
| L4 | vs Calibre 支持子集；差异逐项归因 |
| L5 | ref==ext provenance 注入、unsupported layer、缺报告、重复 hash |

## 13. 里程碑

1. W0：input manifest + canonical graph + microcases。
2. W1–W2：iDB connectivity extraction + coverage。
3. W3：partition refinement/backtracking + diff JSON。
4. W4：注入回归 + Calibre 小设计 harness。

这是 greenfield 粗估；只有 M0 代码/测试落地后再承诺日历。

## 14. 未验证 / 不要重走

- 未验证：iDB routing shapes 对纯 GDS LVS 是否足够；首切片明确不作此承诺。
- 未验证：标准单元 pin equivalence 元数据在当前 Liberty/iDB 中的可用性。
- 不要从 extracted graph 同源生成 reference；这会制造恒等式。
- 不要先做通用 VF2 全图暴力匹配；应先按类型/角色/邻接做分区细化。
- 不要把 unsupported、blackbox 或 budget exhausted 记为 clean。

## 附录 A · 成熟度升级条件

- D0→D1：目录/API/CLI 与 M0 microcases 合入。
- D1→D2：注入测试和失败语义通过。
- D2→D3：至少 3 个标准单元设计端到端。
- D3→D4：冻结支持子集内与 Calibre 并排通过。
