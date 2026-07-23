<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 12 · Evaluation Agent 决策与门禁实施方案 · ai1.0

> 基线：`12-evaluation.md`。L1 拥塞/密度/线长/时序评估资产存在；统一 L2 QoR、决策质量和证据门禁需建设。

## 1. 职责边界

Evaluation 只做测量、比较、门禁和校准，不替 Agent 选择隐含权重，不修改设计。分为：

- L1 Sensor：高频近似指标；
- L2 Metric：阶段/终局统一 QoR；
- L3 Decision Evaluation：Recall@K、regret、calibration；
- L4 Gate：硬不变量和发布策略。

## 2. API

| API | 输出 |
|---|---|
| `eval.measure` | snapshot 上的 metric vector + source/unit/coverage |
| `eval.compare` | before/after delta、Pareto 关系、显著性 |
| `eval.rank_quality` | candidate prediction vs oracle 的 Recall@K/regret |
| `eval.calibration` | reliability bins、ECE/Brier、coverage-risk |
| `eval.gate` | pass/fail/unsupported + 每项证据 |
| `eval.emit_evidence` | 可审计 evidence pack |

## 3. Schema

```json
{
  "metric": "timing.wns",
  "value": -83.0,
  "unit": "ps",
  "snapshot_id": "sha256:...",
  "scenario": "func_ss",
  "source": "iSTA@hash",
  "fidelity": "F3",
  "coverage": {"checked": 1000, "skipped": 0, "unsupported": 0},
  "confidence": null
}
```

所有 metric 禁止裸 double；`source/unit/scenario/snapshot` 缺一即 schema fail。

## 4. LLD

```text
src/evaluation/qor/
  MetricRecord.hh
  QoRVector.{hh,cc}
  MetricCollector.{hh,cc}
  ParetoComparator.{hh,cc}
  GateEngine.{hh,cc}
  CoverageValidator.{hh,cc}

benchmarks/evaluation/
  schemas/
  protocols/
  compare/
  calibration/
```

现有 `src/evaluation/src/module` 保持 L1，adapter 将其输出转成 MetricRecord；不在第一阶段改动 iPL 已消费的 L1 数值。

## 5. Gate 顺序

```text
schema/units/provenance
  → connectivity/legality/coverage
  → setup/hold/DRV/DRC/IR hard gates
  → PPA Pareto comparison
  → cost/risk comparison
  → publish decision
```

任何 hard gate 不可被面积或功耗改善抵消。constraint snapshot 变化时，默认禁止与旧 baseline 直接比较。

## 6. 开发路径

| 阶段 | 内容 | 验收 |
|---|---|---|
| EV-A0（2 周） | MetricRecord/schema validator | 所有工具示例可校验；缺字段必失败 |
| EV-A1（3 周） | QoRVector/Pareto/GateEngine | 无单一总分；硬门禁顺序固定 |
| EV-A2（3 周） | 现有 L1 adapter | iPL 数值零回归 |
| EV-A3（4 周） | rank/regret/calibration | held-out family 报告自动生成 |
| EV-A4（4 周） | evidence pack + CI | 一次 Agent commit 可全链复核 |

## 7. 测试

- WNS 接近 0、负数相对比例、N/A、unsupported、单位混用；
- Pareto 非支配集合已知例；
- false-negative 注入必须拦截；
- skipped DRC rule 不能等价 clean；
- activity coverage 不足时 power gate 为 N/A/风险态；
- 相同候选在不同 constraint snapshot 下禁止静默比较。

**H-EV-A1**：L1 排序能降低 F3 调用至少 5 倍且 selection regret 可控。若 held-out regret 超预算，先缩小 L1 适用域，不允许调松门禁。

