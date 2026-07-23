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

