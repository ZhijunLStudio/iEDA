<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 42 · Agent 场景性能与容量实施方案 · ai1.0

> 基线：`42-perf-parity.md`。Agent 场景新增短调用延迟、增量复用、取消/恢复和分支并发指标，不能只看完整 flow 墙钟。

## 1. 性能目标分层

| 层 | 指标 |
|---|---|
| 单调用 | queue、init、compute、serialize、artifact 分项 p50/p95 |
| 增量 | dirty/full 比例、cache hit、增量/全量 speedup、一致性 |
| 闭环 | time-to-first-feasible、每次 accepted action 成本 |
| 并发 | branch throughput、尾延迟、RSS amplification |
| 可控性 | cancel latency、checkpoint cost、resume overhead |
| 容量 | 实例/net/shape/scenario 扩展曲线与失败模式 |

### 1.1 Trace API

```text
perf.begin_span(request_id, tool, stage)
perf.annotate(span_id, dirty_size, cache, fidelity)
perf.end_span(span_id, status, artifacts)
perf.query(request_or_workflow_id)
perf.compare(run_a, run_b, protocol)
perf.assert_budget(run_id, budget_profile)
```

工具内 API 通过 RAII 封装，Agent 只消费 query/compare/assert 的结构化结果。

## 2. Trace Schema

```text
request_id / workflow_id / snapshot_id / tool_version
queue_ns / load_ns / init_ns / compute_ns / validation_ns / serialize_ns
cpu_ns / peak_rss / io_bytes / cache_hit / dirty_size / full_size
threads / numa / seed / status / cancel_latency / artifact_bytes
```

计时必须在受控 runner 上重复至少 5 次，冷/热 cache 分开，报告 median+MAD。

## 3. 实现落点

```text
src/utility/perf/
  TraceSpan.hh
  PerfEventSink.{hh,cc}
  ResourceSampler.{hh,cc}

benchmarks/perf-agent/
  micro/
  incremental/
  workflow/
  scale/
  compare.py
```

所有工具通过 RAII span 打点；禁止各工具发明不兼容的 JSON。

## 4. 优化顺序

1. 消除重复解析/全量重建；
2. 缩小 dirty domain；
3. 改善数据布局、分配和 cache；
4. 批量化 API、降低序列化；
5. 线程并行/NUMA；
6. profile 证明后再 GPU。

Agent 高频小调用中，启动与序列化可能比算法更贵，必须单列。

## 5. 里程碑

| 阶段 | 交付 | 门禁 |
|---|---|---|
| PERF-A0（2 周） | trace schema + runner | 单次请求分项和 hash 完整 |
| PERF-A1（3 周） | Timing Lab micro/incremental suite | full/incr 可同协议比较 |
| PERF-A2（4 周） | worker pool/cache/zero-copy A/B | 每项优化有可复现实验 |
| PERF-A3（4 周） | 10/50/100 万实例 scale | 拐点与 OOM 原因可归因 |
| PERF-A4（持续） | 每 PR 回归 + weekly scale | p95 回退超预算自动拦截 |

## 6. 红线

- 不以异步返回 request ID 冒充任务完成变快；
- 不删除验证步骤换性能；
- 不比较不同输入/场景/coverage；
- 不只报最佳一次；
- 不用全进程 VmPeak 归因单 stage；
- 不在 profile 前把“加 GPU/加 OpenMP”列为完成方案。

**H-PERF-A1**：Timing Lab 的主要收益来自增量复用而非单轮 kernel 加速。若 trace 显示 compute 已低于总墙钟 30%，优先接口/状态/worker 优化。
