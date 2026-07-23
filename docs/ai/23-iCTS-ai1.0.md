<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 23 · iCTS Agent 时钟树实施方案 · ai1.0

> 基线：`23-iCTS.md`。复用现有时钟拓扑/优化资产；优先解决 tree 可观察、提交闭环、common timing 和跨场景 setup/hold 风险。

## 1. Agent 能力

- 查询 clock tree 的 sink、buffer、latency、skew、load 和异常；
- 生成 topology/buffer/局部 skew target proposal；
- 在 branch 应用 clock delta；
- 强制合法化、局部布线、RC 和多场景 STA；
- 对 useful skew 动作给 setup/hold 双向证据。

## 2. API

| API | 说明 |
|---|---|
| `clock.inspect_tree` | 稳定 ID 的树、metrics、coverage |
| `clock.diagnose` | skew/latency/transition/load 根因 |
| `clock.propose_topology` | 多树候选，不 apply |
| `clock.propose_skew` | sink group target + 风险场景 |
| `clock.apply` | `ClockDelta`，branch only |
| `clock.validate` | legal/route/RC/setup/hold/DRV |

## 3. ClockDelta

包含插删/resize clock buffer、reconnect clock net、sink group/target、位置 hint、影响场景和逆操作。clock/reset 对象属于高风险，默认 F3 验证且 change budget 更小。

## 4. LLD

```text
src/operation/iCTS/agent/
  ClockTreeInspector.{hh,cc}
  ClockDiagnoser.{hh,cc}
  ClockCandidateGenerator.{hh,cc}
  UsefulSkewPlanner.{hh,cc}
  ClockDeltaAdapter.{hh,cc}
  ClockValidator.{hh,cc}
```

CTS 私有 fast timing 只可作为 F0/F1，并必须与 iSTA 对拍；终局一律 common iSTA scenario manager。

## 5. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| CTS-A0（2 周） | tree inspect/typed no-op/error | 空 sink、缺 master 响亮失败 |
| CTS-A1（3 周） | proposal/apply/rollback | tree connectivity 100% |
| CTS-A2（4 周） | legalize-route-RC-STA cascade | 任一步失败全回滚 |
| CTS-A3（4 周） | common timing + scenario | private/iSTA 分桶差异可见 |
| CTS-A4（5 周） | useful skew portfolio | setup 改善不以 hold 失败换取 |

## 6. 测试

- generated/ideal/propagated clock、多个 sink group、clock gating、dont_touch；
- buffer master 不存在、无合法位置、route 不可行；
- CPPR/latency/skew 单位与口径；
- 修改一个 branch 后其他 clock domain hash 不变；
- rollback 恢复 tree/placement/netlist/STA。

**H-CTS-A1**：common timing 重排 CTS 候选可降低“CTS 内部好、post-CTS STA 坏”的比例。若差异不降，先查 RC/clock propagation 语义，不盲调 topology cost。

