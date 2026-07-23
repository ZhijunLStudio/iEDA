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

