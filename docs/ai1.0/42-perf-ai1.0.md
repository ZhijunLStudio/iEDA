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

## 3. LLD 与实现落点

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

---

## 7. Benchmark Protocol 与 budget profile

```text
PerfProtocol
  protocol/version/input/build/artifact hashes
  machine {cpu,numa,memory,storage,os,compiler}
  workload {design,stage,action,scope,scenario,fidelity}
  cache = cold|warm|declared
  repeats/warmups/randomization/timeout
  concurrency/worker/license configuration
  required coverage/correctness assertions

BudgetProfile
  capability/domain/scale bucket
  p50/p95 latency, peak RSS, cpu, io, artifact bounds
  cancel/checkpoint/resume bounds
  baseline/ref + allowed regression policy
```

Budget profile 只有在 protocol 冻结和 baseline 稳定后启用；不同 coverage/fidelity/status 的 run 不比较性能。timeout/OOM 样本保留在容量曲线，不能从统计中删除。

## 8. Trace 传播与归因

Trace span tree 固定 `gateway -> queue -> worker_load -> tool_init -> compute -> validation -> serialization -> artifact_publish`。跨 process 传播 trace_id/span parent；采样可以减少细粒度 events，但 workflow/stage 总 span 和资源采样永久开启。

RSS 归因使用 worker cgroup/process tree 的 peak/area-under-curve，避免拿全主进程 VmPeak。cache hit 必须给 cache key/class 和 saved work estimate；命中陈旧 cache 虽快但 correctness fail，不进入性能收益。

## 9. 容量与并发实验

- micro：固定输入测 API/serialization/adapter overhead；
- incremental：dirty size 从 1 到 full 的 speedup/correctness 曲线；
- workflow：time-to-first-feasible、time-to-verified、accepted-action cost；
- concurrency：1/2/4/... branches 的 throughput、p95、RSS amplification、公平性；
- scale：实例/net/shape/scenario 各维独立扩展并标拐点；
- soak：长时间 worker/cache/artifact/handle 泄漏。

## 10. CI 测试与 PR

`PERF-T01` span nesting/clock monotonic，`PERF-T02` resource sampler gold，`PERF-T03` failed/timeout samples retained，`PERF-T04` cold/warm separation，`PERF-T05` correctness/coverage mismatch reject compare，`PERF-T06` cancel latency，`PERF-T07` checkpoint/resume cost，`PERF-T08` branch fairness/license，`PERF-T09` worker leak soak，`PERF-T10` p95 regression detection。

PR：`PERF-0 schema/RAII span` -> `PERF-1 controlled runner` -> `PERF-2 Timing Lab suites` -> `PERF-3 resource/cgroup/concurrency` -> `PERF-4 budget profiles/CI` -> `PERF-5 scale/soak dashboards`。

## 11. 统计方法与回归判定

同一 protocol 至少 1 次冷启动、2 次 warmup、5 次有效重复；高抖动任务增加重复直到置信区间满足 protocol 或标 `UNSTABLE`。报告 median、MAD、p95、min/max、失败率和 censoring，不只报平均值。

```text
relative_delta = (candidate_median - baseline_median) / baseline_median
noise_band = max(protocol_floor, k * pooled_MAD / baseline_median)
regression if relative_delta > allowed_budget + noise_band
```

对 timeout/OOM 使用成功率和 time/resource-to-failure，不将其排除。多指标 gate：correctness/coverage 必须先等价，然后分别判断 latency、RSS、CPU、IO 和 artifact；禁止用总分抵消内存爆炸。Baseline 绑定 binary/build/machine/protocol hash，过期 baseline 只生成报告不阻断 CI。

## 12. 插桩位置与低开销约束

| Span | Owner | 必填 annotations |
|---|---|---|
| gateway | 41 | schema/auth/quota/payload bytes |
| workflow queue | 40 | priority/resource wait/tenant |
| worker load/init | 40/57 | image/binary/cache/session state |
| state materialize | 10 | snapshot/delta/checkpoint bytes |
| compute | domain tool | scope/fidelity/iterations/dirty size |
| validation | 49 | claims/rules/scenarios/coverage |
| serialization | producer | schema/items/inline/artifact bytes |
| artifact publish | 40 | hash/read/write/dedup/retention |

RAII span 在异常/cancel 时也闭合。计时用 monotonic clock；CPU/RSS/IO 从 worker process tree/cgroup 采集。Trace overhead 通过空 span 和高频 loop microbenchmark 测量：超过任务成本预算时批量 event/降低采样，但不能关闭 request/stage 总 span。

## 13. Benchmark 套件矩阵

| Suite | Workload | 变量 | Correctness oracle |
|---|---|---|---|
| API micro | summarize/query/top-path/page | payload/items/cache | schema/result hash |
| state | snapshot/apply/diff/rollback | delta size/chain length | fresh reload/state diff |
| timing incr | resize/buffer/move/RC | dirty endpoints/scenarios | full iSTA |
| route incr | local reroute/DRC/RC | nets/region/layers | full DRC/RC |
| candidate loop | F0/F1/F2/F3 portfolio | N/Top-K/gate distance | all-F3 selection |
| platform | DAG/worker/checkpoint | nodes/concurrency/failures | workflow result replay |
| scale | whole design | instance/net/shape/scenario | domain-specific |
| soak | repeated experiments | hours/operations/cache | leak/state isolation |

每个 suite 在 `benchmarks/perf-agent/<suite>/protocol.yaml` 固定输入、命令、期望 coverage、机器 class 和结果 schema。Raw traces进入 CAS，summary 可重建。

## 14. 性能归因与优化决策树

```text
regression detected
  -> confirm protocol/build/machine/correctness equivalence
  -> split queue/load/init/compute/validate/serialize/publish
  -> compare CPU vs wall vs IO vs RSS
  -> classify cold-start/cache/dirty expansion/kernel/lock/contention
  -> reproduce with smallest representative benchmark
  -> A/B one change; retain trace and QoR evidence
```

若 dirty/full ratio 突增，先查 invalidation/actual touched；若 init 主导，考虑 worker reuse 但先做状态隔离；若 serialize 主导，批量/Arrow；若 compute 主导，profile kernel 后再并行/GPU。优化 PR 必须声明没有删 validator、降低 coverage 或改变 fidelity。

## 15. Capacity 与 SLO 发布

容量结果输出“支持域”，不是单一最大规模：`<design scale, scenarios, concurrency, fidelity> -> success rate/p95/RSS`。在 OOM 前设置 admission guard 和 graceful `RESOURCE_EXHAUSTED`；不能让 Linux OOM killer 决定产品边界。

SLO 分为交互 read、candidate F0/F1、incremental F2、full F3、workflow 五类，按 scale bucket 发布。SLO 只在满足相同 result/coverage 时生效；F3 本身无固定秒数时也要给 progress/timeout/cancel SLA。

## 16. 完成定义

- 一次 Agent 请求可从 Gateway 追踪到 worker/tool/validator/artifact；
- cold/warm、成功/失败、incremental/full 分开统计；
- Timing Lab 有 time-to-first-feasible、time-to-verified、per-accepted-action 成本；
- CI 可检测稳定 p95/RSS 回归并给 span 归因；
- scale/soak 能发现 OOM、泄漏、cache/handle 增长；
- 所有性能改进附 correctness/coverage equivalence 证据。
