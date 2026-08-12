# 31 · iLVS greenfield TODO

事实源：`docs/ai/31-iLVS.md` draft/D0。`src/operation/iLVS/` 已进入 M0 skeleton；后续完成项仍必须由 microcase、输入独立性和 failure semantics 证明。

## 当前结论

- iLVS 是 greenfield；首阶段只承诺标准单元 connectivity LVS。
- M0 已落地独立 graph JSON API/CLI 和 hand-written microcases；M1 已开始 Verilog reference loader、iDB snapshot adapter 和 bounded backtracking。
- reference 与 extracted graph 必须 provenance 独立，禁止同源生成恒等式。
- unsupported / inconclusive 不能当 clean。

## P0 - skeleton and manifest

- [X] 新建 `src/operation/iLVS/` 最小 library/API/CLI，不创建空壳目录冒充进展。
- [X] 输入 manifest 记录 reference、layout、tech mapping、binary hash；ref/ext 不能共享同一构建对象。
- [X] 状态机实现：INIT -> INPUTS_VERIFIED -> EXTRACTED -> MATCHED -> CLEAN/MISMATCH/UNSUPPORTED/INCONCLUSIVE/ERROR。
- [X] 只有 CLEAN 退出 0，其余状态错误码分开。

## P0 - reference and extracted graph

- [X] ReferenceLoader 支持 gate-level Verilog canonical cell/pin/net graph。
- [ ] LayoutConnectivityExtractor 从 iDB routing/pin/via/shape 生成 extracted graph。
  - [X] 已实现 iDB adapter 入口与 routing/pin/via/shape snapshot 转换；真实标准单元设计端到端 fixture 未完成。
- [X] tech layer-purpose / via mapping 缺失必须 unsupported。
- [ ] 输出 graph counts、coverage、unmatched shape/pin/net。
  - [X] graph JSON summary 已输出 graph counts / coverage；layout extractor 已输出 unattached pin / conflicting owner stats；unmatched shape/net 细化报告未完成。

## P0 - matcher and diff reporter

- [X] 实现 color refinement / partition matching / bounded backtracking。
- [X] open、short、missing、extra、pin-swap、unsupported、inconclusive 分类输出。
- [X] 对称图 budget exhausted 必须 inconclusive，不得 clean。
- [X] 等价 pin 只能来自 Liberty/显式配置。

## P1 - tests and Calibre subset

- [X] 10 个 hand-written graph microcases：rename、open、short、swap、symmetry、budget。
- [X] iDB extraction microcases：shape overlap、via connect、pin attach、unsupported layer。
- [ ] 注入差异端到端测试：四类差异 100% 检出。
- [ ] 与 Calibre nmLVS 在支持子集并排，分类一致才扩展范围。

## P2 - hierarchy and future scope

- [ ] hierarchy/blackbox 配置，blackbox 端口必须匹配。
- [ ] analog device recognition、MOS 参数、full GDS device extraction 单独立项。
- [ ] 报告最小不匹配子图供调试。

## 下一步执行顺序

1. **P0 skeleton + manifest**。
2. **P0 graph loaders**。
3. **P0 matcher/diff**。
4. **P1 injection tests**。
5. **P1 Calibre subset**。

## 验证纪律

- iLVS 未有 microcase 前不得宣称 G12。
- unsupported、blackbox、budget exhausted 均不得映射为 clean。

## Source map

| File / module | 当前定位 | 具体待办 |
|---|---|---|
| `src/operation/iLVS/` | M0/M1 skeleton 已建 | 继续接真实 flow 调用和端到端 fixture |
| `reference loader` | Verilog canonical loader 已实现 | 继续补 bus/concat/assign policy、正式 parser 对接 |
| `layout extractor` | snapshot extractor + iDB adapter 已实现 | 继续补真实 iDB design fixture、GDS/device extraction 后续立项 |
| `matcher/diff reporter` | WL refinement + bounded backtracking + diff JSON | 继续补最小不匹配子图 |
| `microcases` | graph + extractor microcases 已覆盖 | 继续补注入端到端和 Calibre subset |
