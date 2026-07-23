<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 49 · Verification Hub 与证据证书实施方案 · ai1.1

> 当前成熟度：`D0/DRAFT`。现有各工具具有部分 checker，`12` 规划 GateEngine，`43` 规划 ValidationPolicy；仓库当前没有统一 certificate hub。
>
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

## 13. Validator qualification 与计划算法

```text
ValidatorQualification
  validator/tool/schema/binary hashes
  claim types + exact scope/scenario/rule domain
  incremental/full/partial semantics
  gold/mutation/failure/full-diff evidence
  allowed maturity/fidelity + expiry/revocation
```

VerificationPlanner 输入 base/candidate/TypedDelta/policy，先从 delta invalidation graph 计算 required claims，再解析 qualified validators，合并 exact scopes/scenarios/rules，按便宜结构检查优先和数据依赖拓扑排序；并行只发生在工具状态/资源可安全隔离时。缺 validator 或 coverage 无法满足时计划可返回，但 bundle 为 `INCOMPLETE`。

## 14. Certificate identity、失效与签发

```text
certificate_id = hash(
  claim/result/scope/coverage,
  subject snapshot + context/policy refs,
  validator qualification + request/result/artifact hashes
)
```

Issuer 重新校验 raw result schema、qualification、artifact hash 和 coverage 后签发，不能接受调用者上传的 bool。首版本地 content hash + ACL；跨服务/发布时才加签名。Delta/context/tool/model/policy/qualification 变化沿 dependency graph 失效；stale certificate 保留历史但不进入 current bundle。

增量 certificate claim 名必须包含 scope/incremental 语义；只有 full validator 或经过 policy 明确组合证明，才可升级为 full claim。Full audit 推翻增量结果时撤销 validator qualification，而不只拒绝一个 candidate。

## 15. CI 与 PR

`VH-T01` fake bool/缺 artifact，`VH-T02` claim/scope overstatement，`VH-T03` delta invalidation property，`VH-T04` context/policy/tool drift，`VH-T05` rule/scenario/object coverage，`VH-T06` planner DAG/parallel isolation，`VH-T07` validator crash/timeout/partial，`VH-T08` incremental/full qualification revoke，`VH-T09` certificate/bundle hash/replay，`VH-T10` stale/expired/removed artifact，`VH-T11` Timing ECO mandatory claims，`VH-T12` no commit on incomplete。

PR：`VH-0 claim/certificate/qualification schema` -> `VH-1 registry/invalidation` -> `VH-2 planner/runner` -> `VH-3 state/frozen/legal adapters` -> `VH-4 timing policy bundle` -> `VH-5 DRC/RC/formal/power` -> `VH-6 F4 signing/qualification`。

## 16. Invalidation Rule DSL

失效关系不能散落在各 adapter 的 `if` 中。首版使用受限 DSL：

```text
rule timing_after_resize@1
  when delta.kind in {ResizeInst, SwapVt, InsertBuffer}
  invalidate claim timing.* on dirty_timing_cone(delta)
  invalidate claim placement.legal on affected_region(delta, halo=policy)
  require claim netlist.connectivity on affected_cone(delta)
  require claim objects.frozen on complement_of_declared_scope(delta)
  if dirty_scope_unknown then widen full_design
```

规则只能调用注册的保守 scope function；scope function 返回对象集合、计算 provenance 和是否完整。`UNKNOWN` 必须扩大到 policy 定义的 full scope 或使计划 incomplete，不能返回空集。规则集版本、输入 delta schema 和展开后的 claim set 都进入 plan hash。

对 invalidation graph 做 property test：任意 delta 序列中，full validator 所读输入发生变化时，依赖它的 current certificate 必须不可命中；顺序不同但最终 snapshot/context 相同的合法 delta 应产生相同 required claim closure。

## 17. 执行一致性、幂等与并行

VerificationPlan 生成时固定 subject snapshot 和所有 context refs。Runner 为每个 node 获取只读 snapshot lease，node 完成前若引用被撤销或 artifact 不完整，结果为 `STALE/UNVERIFIABLE`。验证过程中禁止 tool 修改 subject snapshot；需要临时文件的 validator 在独立 workspace 运行。

```text
verification_run_id = hash(plan + subject/context refs + validator qualifications)
node_attempt_id      = verification_run_id + node_id + attempt_no
```

重复请求优先返回内容相同且 current 的证书；worker crash 后只重试 manifest 声明幂等的 node。外部 license/timeout 与物理 FAIL 分离。hard FAIL 可以取消未开始的高成本 node，但已产生的失败证据仍持久化；若 policy 要求完整 failure characterization，则不得 early cancel。

并行调度必须同时满足：validator 无共享可变 singleton、workspace 隔离、资源/license reservation 成功、依赖 artifact ready。无法证明隔离的 legacy validator 串行执行，性能需求不能改变 correctness 边界。

## 18. Claim lattice 与 bundle 判定

Claim 之间使用注册的蕴含关系而不是字符串前缀。例如 `drc.full_clean(rule_set=X)` 可以覆盖相同 snapshot/context 下的 `drc.subset_clean(Y)`，前提是 `Y subset X` 且 scope/scenario 相容；反向不成立。incremental、sampled、estimated claim 默认不蕴含 full claim。

BundleEvaluator 按以下顺序判定：identity/current -> issuer/qualification -> assumptions -> scope/scenario/rule coverage -> claim implication -> result。任一 required claim 有多个冲突证书时返回 `CONFLICTED`，不以最新或多数投票覆盖。证书组合产生新的 BundleRecord，保留实际采用和拒绝的 certificate IDs。

## 19. Evidence storage 与信任边界

原始 result、normalized result、certificate 和 bundle 分开存储：

```text
raw artifact -> validator result -> issuer validation -> certificate -> policy bundle
```

Issuer 只信注册 validator qualification 和 CAS hash，不信调用者身份带来的 bool。artifact 加密/外部保存时至少保留可验证 locator、hash、retention 和访问状态；证据过期或被删除后 certificate 仍可审计其历史，但 current 状态变为 `UNVERIFIABLE`。

跨服务签名采用可轮换 issuer key，证书身份仍由内容字段决定；key rotation 不应改变 claim，key compromise 则按签发时间/issuer 范围撤销。首版单进程部署可不引入 PKI，但必须保留相同 issuer interface 和审计语义。

## 20. Timing ECO 首个可提交切片

`timing_eco.post_place@1` 固定支持 `ResizeInst`、`SwapVt`、`InsertBuffer` 三类 delta。最小 required closure：

| Delta | 必需 claim | 首版 scope |
|---|---|---|
| Resize/SwapVt | state integrity、frozen、connectivity、legal、setup、hold、DRV | touched inst + timing cone + legal halo |
| InsertBuffer | 上述全部 + netlist change + local RC | affected nets/cones/region |
| 任一 intent/tech drift | intent audit、tech valid、所有 timing claim 重新验证 | policy signoff scenarios |

端到端完成定义：500 个随机合法/非法 branch 中零 invalid commit；每种 delta mutation 都触发预期 claim；缺一个 scenario、object、rule 或 artifact 时 bundle 不 complete；incremental/full 抽检超阈值会撤销对应 qualification；同一 evidence pack 可离线重建 bundle 判定。

## 21. 运维指标与事故处理

首批指标：required-claim planning miss、stale certificate hit、incremental/full disagreement、unknown/partial rate、validator failure rate、p50/p95 latency、取消节省成本、replay success。correctness 指标必须按 claim/validator/policy 分桶，不能被总成功率稀释。

发现 invalid commit 时立即冻结相关 policy profile 和 validator qualification，保留 subject/evidence，回溯相同 qualification 签发的 current bundles，并通知 Runtime 阻断后续 commit。修复后以最小反例加入 CI，再由 owner 显式恢复资格；不能只修单个设计数据。

## 22. 版本历史

- ai1.1（2026-07-23）：补充 invalidation DSL、执行一致性与并行条件、claim lattice、证据信任链、Timing ECO 最小 bundle 和事故处理。
- ai1.0（2026-07-23）：定义 Validator Registry、Certificate、Policy、增量/full 语义和基础里程碑。
