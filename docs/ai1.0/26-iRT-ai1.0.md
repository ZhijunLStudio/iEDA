<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 26 · iRT Agent 布线实施方案 · ai1.0

> 基线：`26-iRT.md`。复用全局/详细布线内核；Agent 化首要任务是可观察 congestion、局部 reroute、冻结域、事务恢复、timing/DRC 闭环和 anytime。

## 1. API

| API | 类型 | 输出/副作用 |
|---|---|---|
| `route.inspect` | read | layer/grid/resource/net/violation 摘要 |
| `route.hotspots` | read | overflow/conflict clusters |
| `route.propose` | proposal | topology/layer/rip-up scope candidates |
| `route.estimate` | read | F0/F1 resource/RC/DRC risk |
| `route.reroute_scope` | branch write | `RouteDelta` + partial/incumbent |
| `route.validate` | read | DRC/RC/timing/frozen nets |
| `route.resume/cancel` | control | anytime 状态 |

## 2. RouteDelta

```text
affected_nets
added/deleted segments/vias
region/layers
frozen_net_hash
conflict_region
dirty_coupling_neighbors
before_image/checkpoint
```

scope 外网络几何 hash 变化数必须为 0。若 router 为解决冲突必须扩大 scope，应返回 `scope_expansion_proposal`，不能静默 rip-up。

## 3. LLD

```text
src/operation/iRT/agent/
  RouteInspector.{hpp,cpp}
  HotspotClusterer.{hpp,cpp}
  RouteCandidateGenerator.{hpp,cpp}
  ScopeRouter.{hpp,cpp}
  RouteDeltaAdapter.{hpp,cpp}
  RouteValidator.{hpp,cpp}
  RouteProgressAdapter.{hpp,cpp}
```

现有阶段内核先作为 ScopeRouter 后端；timing 接口通过 iSTA Tool Contract 复活，不在 iRT 私有复制时序图。

## 4. 多精度

| 档 | 内容 |
|---|---|
| F0 | RUDY/resource/Steiner/layer 可行性 |
| F1 | learned hotspot/reroute ranker |
| F2 | global/early/local route + in-design DRC |
| F3 | detailed route + full iDRC/RCX/STA |

timing criticality、DRC severity、拥塞 cost 独立记录，不硬编码为不可解释单分数。

## 5. Anytime/恢复

- 每轮 negotiated congestion/rip-up 输出 overflow、DRC proxy、已完成 net 数；
- 保留当前 best routable incumbent；
- cancel 在安全迭代边界生效；
- resume 保存 region ownership、history cost、net order 和 seed；
- 未完成网和 skipped checks 明确返回；
- `partial` 不能提交为 route complete。

## 6. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| RT-A0（3 周） | inspect/hotspot/structured progress | 与现有 summary 对账 |
| RT-A1（4 周） | RouteDelta/frozen verifier/rollback | 100 局部 reroute 零越域 |
| RT-A2（5 周） | scope router + incremental DRC | 构造冲突 clean/残余诚实 |
| RT-A3（5 周） | dirty RC/common STA | critical net 方向改善可验证 |
| RT-A4（5 周） | anytime/cancel/resume | 连续/恢复结果容差一致 |
| RT-A5（后续） | DRC repair portfolio/SI/EM | F4 对拍 |

## 7. 测试

- 无路可走、窄通道、via shortage、固定/特殊/clock/PG net；
- scope expansion、cancel、OOM、worker kill；
- coupling neighbor dirty set；
- timing 开关打开必须改变明确的排序/cost 或报告 unsupported；
- iDRC skipped rule 不得 route clean；
- full reroute 与 local final DRC/STA 差异。

**H-RT-A1**：局部 reroute 可在 frozen-net 约束下解决多数 late DRC/timing 问题。若 residual 高，分类哪些违例需要全局资源重分配，并让 Runtime 升级 scope，而不是破坏冻结契约。

---

## 8. Route request/result schema

```text
RouteRequest
  snapshot/intent/tech/scenario refs
  stage = early|global|detail|repair
  scope {nets, region, layers, frozen complement}
  terminals/guides/resources/blockages/rule profile
  objectives {overflow, wirelength, via, timing, drc, disruption}
  fidelity/budget/seed/resume token

RouteResult
  status + candidate snapshot/delta refs
  routed/unrouted/skipped net sets
  added/deleted segments/vias + actual touched
  overflow/conflict/violation clusters
  progress/incumbent/resume + coverage/provenance
```

`routed=true` 只有在 declared net scope 全部连通且 coverage 完整时存在；一个 net 部分连接、使用 fallback guide 或因规则 unsupported 跳过都必须单独列出。

## 9. Hotspot、proposal 与 scope planning

Hotspot ID 由 grid/layer/region/resource-version 归一化；聚类输入包括 overflow edges、DRC conflicts、timing critical nets 和 via pressure。`RouteCandidateGenerator` 为每个 cluster 生成 topology、layer promotion/demotion、rip-up set、net order 和 region expansion 候选，不直接修改 route。

Scope planner：

1. 从目标 nets/violations 取 primary region/layers；
2. 按 spacing/via/antenna/RC coupling 等 interaction halo 扩大；
3. 加入依赖的 conflicting nets，但不自动解除 frozen；
4. 若资源不可行，输出最小 `scope_expansion_proposal`；
5. policy 批准后创建新 request 和新 frozen certificate baseline。

## 10. Negotiated routing 与 anytime

```text
initialize from branch route state
repeat round:
  select conflict nets in deterministic order
  rip up only leased scope
  search paths with resource/history/timing/via costs kept separate
  commit round candidate in private route view
  independent connectivity/resource check
  update best feasible/least-violation incumbent
  emit progress and cancellation safe point
until clean, no improvement, infeasible, budget or cancel
```

cost 分量可由显式 policy 组合用于单次搜索，但 result 必须保留原分量。`partial` incumbent 若仍有 unrouted net 不可写成 route-complete DEF。resume token 包含资源/history cost、net order、route state、seed 和 binary hash。

## 11. Validation DAG 与失效

```text
route connectivity/resource/layer legality
  -> frozen geometry hash
  -> incremental iDRC with exact declared rule coverage
  -> iRCX primary + coupling-neighbor update
  -> common iSTA setup/hold/DRV
  -> SI/EM/power optional policy
  -> periodic full DRC/RC/STA audit
```

RouteDelta 失效 route、DRC、RC、timing、SI、signal EM；若触及 PG 还失效 IR/PG connectivity。增量 validator 只可签发 scope-limited certificate，full audit 差异超过阈值时撤销该 action/rule 的 incremental qualification。

## 12. LLD 与接口迁移

| 组件 | 后端/职责 |
|---|---|
| `RouteInspector` | RTInterface + immutable route view，结构化资源/coverage |
| `HotspotClusterer` | overflow/DRC/timing spatial clusters |
| `RouteCandidateGenerator` | topology/layer/rip-up/order/scope proposals |
| `ScopeRouter` | 现有 iRT stage adapter，budget/cancel/incumbent |
| `RouteDeltaAdapter` | shapes/vias before/after/owner/inverse |
| `RouteValidator` | connectivity/frozen/DRC/RC/STA evidence refs |
| `RouteProgressAdapter` | round events、unrouted、best incumbent/resume |

Agent adapter 不能解析普通日志来判断完成；必须从 iRT 内部结构化 counters/state 或受控 report schema 获取。

## 13. 测试与 PR

`RT-T01` two-pin/Steiner 小图，`RT-T02` no-path/via shortage，`RT-T03` PG/clock/special/frozen nets，`RT-T04` narrow channel/history convergence，`RT-T05` actual touched 零越域，`RT-T06` scope expansion，`RT-T07` cancel/resume/worker kill，`RT-T08` partial DEF 不得 complete，`RT-T09` incremental/full DRC，`RT-T10` coupling dirty RC/STA，`RT-T11` seed/thread determinism，`RT-T12` full/local QoR/regret。

PR：`RT-0 inspect/progress schema` -> `RT-1 RouteDelta/frozen/inverse` -> `RT-2 hotspot/scope proposals` -> `RT-3 scoped GR/DR + anytime` -> `RT-4 iDRC/iRCX/iSTA cascade` -> `RT-5 full audit/qualification` -> `RT-6 SI/EM aware portfolio`。
