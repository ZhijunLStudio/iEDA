<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 49 · Verification Hub 与证据证书实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。现有各工具具有部分 checker，`12` 规划 GateEngine，`43` 规划 ValidationPolicy；仓库当前没有统一 certificate hub。  
> 职责：注册、编排和验证领域 checker 的结果，签发带 coverage 的机器证书；不平行实现 STA、DRC、LVS、formal、IR 等算法。

## 1. 为什么需要独立 Hub

`bool pass` 无法表达检查对象、规则、场景、跳过项、工具版本和失效条件。Agent 提交需要的是一组可审计 claim：连接保持、冻结域未动、布局合法、setup/hold 达标、DRC 指定规则 clean 等。Hub 将领域结果标准化为 Certificate，并让 Runtime 只依据 policy + certificate commit。

职责边界：领域工具决定“怎么算”；Hub 决定“需要算什么、结果能证明什么、何时失效”；Evaluation 决定 metric/Pareto/gate；Runtime 决定事务状态。

## 2. API

| API | 语义 |
|---|---|
| `verify.register_validator` | 注册 claim、输入、coverage、invalidation 能力 |
| `verify.plan` | 从 delta/action/policy 展开必需验证 DAG |
| `verify.run` | 在目标 snapshot 上执行验证 DAG |
| `verify.issue_certificate` | 校验 provenance/coverage 后签发证书 |
| `verify.bundle` | 组装 policy 所需证书集合 |
| `verify.check_bundle` | 判断 complete/pass/current |
| `verify.invalidate` | 根据 delta/context/tool 变化失效证书 |
| `verify.explain_failure` | 返回失败 claim、证据与允许的恢复动作 |

Hub 不接受调用者上传一个裸 `pass=true`；certificate 必须来自注册 validator 的结构化 result。

## 3. Certificate Schema

```text
ValidationCertificate
  certificate_id
  claim_type
  result = PASS | FAIL | UNKNOWN | PARTIAL
  subject_snapshot
  intent/scenario/tech/policy refs
  scope + coverage
  validator_manifest/tool_binary hash
  request/result/artifact refs
  assumptions
  invalidated_by
  issued_at + optional expiry
```

`PASS` 要求 `coverage` 满足该 claim 的 policy；例如 DRC checker 只检查 spacing 时，证书 claim 只能是 `drc.spacing_clean`，不能是 `drc.clean`。

## 4. Validator Registry

首批 claim：

| Claim | Validator owner | 常见失效 delta |
|---|---|---|
| `state.integrity` | iDB | any DesignDelta/import |
| `objects.frozen` | iDB diff checker | touched scope/context |
| `netlist.connectivity` | iDB/iLVS | netlist/reconnect/buffer |
| `placement.legal` | iPL | placement/netlist/floorplan |
| `timing.setup/hold/drv` | iSTA | netlist/place/route/RC/constraint |
| `route.drc_subset` | iDRC | route/place/tech/rule |
| `functional.equivalent` | iFormal/external | netlist/intent/reference |
| `power_ir.acceptable` | iPA/iIR | activity/netlist/PDN/temp |
| `artifact.roundtrip` | iDB/file adapters | exporter/parser version |

每个 validator 声明是否支持 incremental/full、partial/cancel、证据最小集和 full oracle 周期。

## 5. Verification Plan

```text
input: base snapshot + candidate snapshot + typed delta + policy
  → expand delta invalidation rules
  → resolve validators and exact scopes/scenarios/rules
  → order cheap structural checks first
  → run independent checks in parallel where safe
  → cancel expensive checks on hard failure if policy allows
  → normalize results and coverage
  → issue certificates
  → build bundle; no implicit pass for missing claim
```

默认顺序：schema/provenance → state/frozen/connectivity → legality → domain incremental checks → full/high-fidelity checks → release bundle。

## 6. LLD 与源码落点

```text
src/verification/
  api/VerificationService.{hh,cc}
  registry/{ValidatorManifest,ValidatorRegistry}.cc
  planning/{InvalidationGraph,VerificationPlanner}.cc
  execution/VerificationRunner.cc
  certificate/{Certificate,Issuer,Bundle}.cc
  policy/{PolicyProfile,PolicyEvaluator}.cc
  adapters/{State,Legality,Timing,Drc,Formal,PowerIr}.cc
```

`VerificationRunner` 通过 Platform 执行，不直接调用工具 singleton。证书/artifact 写 CAS，索引绑定 snapshot；私钥签名只在需要跨服务/发布时引入，首版本地可先用内容 hash + 审计 ACL。

## 7. Policy Profile

```yaml
profile: timing_eco.post_place@1
required:
  - claim: objects.frozen
    scope: complement_of_delta
    coverage: full
  - claim: netlist.connectivity
    coverage: affected_cone
  - claim: placement.legal
    coverage: affected_region_plus_halo
  - claim: timing.setup
    scenarios: signoff_required
  - claim: timing.hold
    scenarios: signoff_required
unknown_policy: reject
```

Policy 是版本化输入，不隐藏在代码 `if` 中。动作类型只能增加验证要求，不能由 proposal 自行删减要求。

## 8. 增量与 full oracle

- incremental certificate 的 claim/scope 必须写 `incremental`；
- delta dirty set 是下界输入，领域 validator可保守扩大，不得缩小漏项；
- 以固定比例或风险触发 full 验证，记录 incremental/full diff；
- 超容差后吊销相应 incremental validator 的 qualification，而非只拒绝单次候选；
- full checker 本身 unsupported/skip 时，结果仍为 UNKNOWN/PARTIAL。

## 9. 失败语义

| 情况 | Bundle 状态 | Commit |
|---|---|---:|
| 任一 required FAIL | REJECTED | 禁止 |
| required UNKNOWN/PARTIAL | INCOMPLETE | 默认禁止 |
| certificate context ref 不同 | STALE | 禁止 |
| coverage 低于 policy | INCOMPLETE | 禁止 |
| tool/result artifact 丢失 | UNVERIFIABLE | 禁止 |
| 仅 optional soft claim 缺失 | COMPLETE_WITH_RISK | 由显式 policy 决定 |

## 10. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| VH-A0（2 周） | certificate/claim/coverage schema | 缺字段和伪造 bool 全拒绝 |
| VH-A1（3 周） | registry/invalidation graph | 每类首批 delta 的失效集合 property test |
| VH-A2（3 周） | state/frozen/legality adapters | 500 branch 无漏越域 |
| VH-A3（4 周） | timing ECO policy bundle | 未过 setup/hold/DRV 无 commit 路径 |
| VH-A4（4 周） | DRC/RC/formal/power adapters | skipped/unknown 保持原语义 |
| VH-A5（持续） | external signoff bundle | tool/protocol/hash 可离线重放 |

## 11. 测试与可杀假说

- certificate 依赖图：随机 delta 序列后已失效证书不得命中；
- context：intent/scenario/tech 任一 ref 改变必须失效对应证书；
- coverage：漏一条 DRC rule、一个 scenario、一个 frozen object 均不得 full PASS；
- failure injection：worker crash、timeout、空报告、parser drift、artifact 删除；
- replay：相同 inputs/tool/policy 生成相同 claim/result hash（时间字段除外）。

**H-VH-A1**：统一证书能消除“局部工具成功但闭环不可提交”的假成功。以现有 flow 的 injected defects 对比；若仍漏过，优先补 invalidation/coverage，不扩大工具面。

## 12. 不做

- 不重新实现领域 kernel；
- 不把 metric 改善当 certificate；
- 不签发超出 checker coverage 的宽 claim；
- 不允许 Planner/tool 自己声明验证已通过；
- 不复用不同 intent/tech/scenario 的旧证书；
- 不在首版声称取代 foundry/commercial signoff。

