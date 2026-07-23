<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 31 · iLVS Agent 连通性与版图对照实施方案 · ai1.0

> 基线：`31-iLVS.md` 当前为 greenfield/D0。首期不从头追求全 Calibre nmLVS，而是先建设独立来源、结构化 diff 和外部 oracle adapter，再逐步实现有限产品切片。

## 1. 产品切片

首批支持标准单元数字设计：

- reference gate netlist 与 layout-extracted connectivity 独立加载；
- instance/net/pin open/short/missing/extra 对照；
- blackbox macro 端口级匹配；
- 参数/模拟器件/full custom 后置；
- 功能 ECO 提交前 connectivity/equivalence 辅助门禁。

## 2. API

```text
lvs.load_reference(netlist_artifact)
lvs.extract_connectivity(layout_snapshot, coverage)
lvs.compare(reference_id, extracted_id, options)
lvs.explain_mismatch(mismatch_id)
lvs.validate_delta(before, after, dirty_scope)
lvs.oracle_compare(calibre_result)
```

reference 与 extracted 数据结构/文件 inode 必须独立，启动时断言，防恒等式假通过。

## 3. 结果

```text
LvsResult
  status {match,mismatch,partial,unsupported,error}
  instance/net/pin coverage
  opens/shorts/missing/extra/param_mismatch
  hierarchy/blackbox decisions
  skipped_devices/rules
  evidence mappings
```

partial/unsupported 永远不是 match。

## 4. LLD

```text
src/operation/iLVS/
  CMakeLists.txt
  api/LvsService.{hh,cc}
  reference/ReferenceLoader.{hh,cc}
  extraction/ConnectivityExtractor.{hh,cc}
  match/CanonicalGraph.{hh,cc}
  match/GraphMatcher.{hh,cc}
  report/MismatchExplainer.{hh,cc}
  agent/LvsResultBuilder.{hh,cc}
```

优先复用成熟图算法/外部 netlist parser，不手写脆弱字符串匹配。

## 5. 算法路径

1. 名称/层级可用时做确定性 seed matching；
2. 以 cell type、pin role、degree、邻接签名做颜色细化；
3. 对未决子图做受限 backtracking/graph isomorphism；
4. 输出 ambiguity，不任意挑一个映射；
5. dirty-scope LVS 仍周期性 full compare。

## 6. 开发阶段

| 阶段 | 内容 | 门禁 |
|---|---|---|
| LVS-A0（3 周） | external Calibre adapter + schema | open/short 注入结构化 |
| LVS-A1（4 周） | independent reference/connectivity model | ref/ext 零共享断言 |
| LVS-A2（5 周） | flat std-cell matcher | identity + 4 类 mutation 必报 |
| LVS-A3（5 周） | hierarchy/blackbox | macro port cases |
| LVS-A4（后续） | layout device extraction/params | Calibre subset 对拍 |

## 7. 测试

- identity、rename、permutation、open、short、swap pin、missing/extra instance；
- repeated symmetric structure 的 ambiguity；
- blackbox macro、hierarchy flatten/preserve；
- ref/ext 同源防护；
- skipped device 导致 partial；
- incremental/full mismatch set 对拍。

**H-LVS-A1**：先用外部 extraction + 自研 graph compare 可快速支持 Agent ECO 门禁。若 connectivity 命名/层级差异使匹配不稳，先强化 canonical graph，不急于自研 device extraction。

---

## 8. 独立输入与 canonical graph

```text
ConnectivityGraph
  source = reference_netlist|layout_extraction
  source_artifact/tool/parser hashes
  hierarchy/flatten policy
  vertices {instance,device,net,port,pin} with stable local IDs
  edges {connects,contains,aliases}
  cell/device/function/parameter attributes
  blackbox decisions + coverage
```

ReferenceLoader 与 ConnectivityExtractor 必须运行在独立对象库/arena，禁止共享 net/pin 指针或从同一个 normalized graph clone 后比较。测试启动时校验 source artifact、builder 和 storage identity；identity 设计通过并不能证明独立性。

## 9. 匹配算法与 mismatch 证据

```text
normalize names only as optional hints
  -> seed ports/unique cell types/known blackboxes
  -> iterative color refinement by type/pin role/degree/neighborhood
  -> split independent unmatched components
  -> bounded backtracking/isomorphism for ambiguous subgraphs
  -> classify unmatched edges/vertices/parameters
  -> verify proposed mapping by independent connectivity replay
```

对称结构可能有多个正确 mapping，结果为 `MATCH_WITH_AMBIGUITY` 并保留 equivalence classes，而非任意固定一个。open/short 的 evidence 必须给 reference/extracted 两侧最小相关子图；missing/extra/port/pin swap 分开统计。

## 10. 增量与 external oracle

dirty-scope LVS 以 netlist/route delta、层级边界和连接分量扩张。任何跨 scope short/open 都可能把局部影响扩成整个 component；scope planner 必须保守扩大。局部 PASS 只能证明 declared component，周期性 full compare 作为永久 qualification gate。

首版 external Calibre adapter 经 `57` 执行：固定 deck/report point、保留 raw report、parser source span 和 rule/device coverage。iLVS normalized result 与 external result 按 mismatch class/object mapping 对拍，不只比较最终 MATCH 字符串。

## 11. 失败语义、LLD 与测试

| 状态 | 含义 |
|---|---|
| `MATCH` | requested scope/device/blackbox coverage 完整且无 mismatch |
| `MATCH_WITH_AMBIGUITY` | connectivity 等价但 mapping 非唯一 |
| `MISMATCH` | 有结构化 open/short/missing/extra/param diff |
| `PARTIAL` | skipped device/blackbox/scope/抽取 coverage 不完整 |
| `UNSUPPORTED` | device/model/hierarchy policy 超出 domain |
| `INVALID_INDEPENDENCE` | reference/extracted 同源或共享对象防护触发 |

`ReferenceLoader`、`ConnectivityExtractor`、`CanonicalGraph`、`GraphMatcher`、`MismatchExplainer`、`LvsResultBuilder` 各自拥有明确 source/result；matcher 不读取 layout geometry，extractor 不读取 reference mapping。

CI：`LVS-T01` identity 独立来源，`LVS-T02` rename/permutation，`LVS-T03` open/short/pin swap，`LVS-T04` missing/extra，`LVS-T05` symmetric ambiguity，`LVS-T06` hierarchy flatten/preserve，`LVS-T07` blackbox ports，`LVS-T08` skipped device partial，`LVS-T09` ref/ext same-source trap，`LVS-T10` dirty/full compare，`LVS-T11` external mapping，`LVS-T12` parser/report drift。

PR：`LVS-0 external adapter/schema` -> `LVS-1 independent graph stores` -> `LVS-2 flat matcher/mutations` -> `LVS-3 ambiguity/explain` -> `LVS-4 hierarchy/blackbox` -> `LVS-5 dirty/full qualification` -> `LVS-6 device extraction subset`。
