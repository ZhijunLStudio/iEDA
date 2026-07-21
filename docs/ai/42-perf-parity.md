<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 42 · 性能对标 Perf Parity · 商业对标优化方案 · rv1.0

> 文档号：42-rv1.0　　版本：v2.0　　里程碑：**可复现剖面 → 并排比值 → 热点优化（质量优先）→ G21/G20**
> 体例：`01-ai-doc-conventions-rv1.md`　主纲：G21/G20/G17　Know-how：KH-EV-01、KH-X-05/08
> 依赖：`12-evaluation` protocol/schema；`40-platform` stage 边界计时钩子
> 纪律：无 QoR A/B 的「加速」不合入；共享机数字不进 G21。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 采集算法摘要（~42 行） |
| **rv1.0 / v2.0** | **2026-07-20** | **升体例**：补审计/FR/HLD/LLD/看板 M0–M4/测试/未验证；明确与 12 的 `run_perf_compare.sh` 共管。 |

---

## 1. 症结审计

| ID | 症结 | 证据/说明 | P |
|---|---|---|---|
| P1 | 无统一 stage 计时钩子 | 各工具日志墙钟不可比 | P0 |
| P2 | 无 `profile.jsonl` schema | G21 分项无处安放 | P0 |
| P3 | 无独占机/绑核协议 | 数字不可进门禁 | P0 |
| P4 | 优化易牺牲 QoR | 缺 A/B 门禁绑定 G17 | P1 |
| P5 | 大设计瓶颈无火焰/表 | G20 放宽 3× 需归因 | P1 |

### 1.2 现状能力

| 项 | 判定 |
|---|---|
| 工具内 Monitor/LOG 时间戳 | 散落，**非** G21 真源 |
| `benchmark/qor/run_perf_compare.sh` | **文档设想，未落地**（未验证） |
| 商业侧同机同线程对比 | 未验证 |

### 1.3–1.4

边界：质量优先（KH-X-05）——G21 不得在 G17 红时强行转绿。跨工具：计时钩挂 FlowScheduler stage（40）或 TCL wrapper。

---

## 2. 需求 FR / NFR

| ID | 需求 | P |
|---|---|---|
| FR-PERF-01 | ★ stage 计时钩子（wall/cpu/rss） | P0 |
| FR-PERF-02 | ★ profile.jsonl schema + 进 12 目录 | P0 |
| FR-PERF-03 | ★ compare 脚本（ieda/commercial ratio） | P0 |
| FR-PERF-04 | ★ 独占机协议写入 parity_protocol | P0 |
| FR-PERF-05 | 热点 stage A/B（算法不变默认） | P1 |
| FR-PERF-06 | G20 瓶颈报告（火焰或表） | P1 |
| NFR-PERF-01 | daily 端到端 ≤1.5×；≥2/5 ≤1.0× | G21 |
| NFR-PERF-02 | scale ≤3× + 归因 | G20 |
| NFR-PERF-03 | 复跑波动记入 ε | KH-X-08 |

红线：共享机结果仅观测；合入须 QoR A/B 不回归。

---

## 3. HLD

```text
独占机 + 绑核 + threads∈protocol
for design in daily:
  for stage in [fp,place,cts,pdn,route,rcx,sta,to,drc]:
    record wall_s, cpu_s, peak_rss_mb
ratio = ieda / commercial
gate: e2e≤1.5× ∧ count(≤1.0×)≥2
```

决策：先采 iEDA 基线再并排；优化默认算法不变开并行/数据结构 A/B；禁止「关检查换速度」。

| # | 决策 | 被否 |
|---|---|---|
| D1 | 质量优先 | 先刷墙钟 |
| D2 | 协议绑核 | 共享机进 G21 |
| D3 | 分项剖面必留 | 只看 e2e |

---

## 4. LLD

### 4.1 计时钩子 `[新增]`

```cpp
// platform 或公共 util
struct StageTimer { void start(name); void stop(); /* rss via /proc */ };
// FlowScheduler 每 stage 包一层；TCL 长命令亦可
```

### 4.2 profile schema `[新增]`

```json
{"design":"aes","stage":"route","wall_s":...,"cpu_s":...,"peak_rss_mb":...,
 "threads":8,"host":"...","binary_hash":"..."}
```

### 4.3 compare `[新增]`

`run_perf_compare.sh` → `perf_align.json`：逐 stage ratio + e2e。

### 4.4 PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| PR0 | 钩子 | 五套有 profile |
| PR1 | schema | 校验器 |
| PR2 | compare | 比值表 |
| PR3 | CI 观测档 | 非门禁→门禁开关 |

### 4.5 模块状态

| 模块 | 状态 | 动作 |
|---|---|---|
| StageTimer | 无 | ★ |
| profile 目录 | 无 | ★ |
| 优化 backlog | 无 | M2 热点驱动 |

---

## 5. 配置

`parity_protocol.perf`: `threads`、`pin_cores`、`exclusive_host_required=true`、`g21_enable=false`（M3 前观测）。

---

## 6. 指标分解

e2e wall；分项 place/cts/route/sta/…；peak RSS；并行效率（cpu/wall）。禁止单一标量掩盖 route 爆。

---

## 7. 状态机

```text
check_exclusive_host → run_with_timers → emit profile.jsonl
  → compare → (if g21_enable) assert ratios
```

---

## 8. Cascade

40 提供 stage 边界；12 提供目录与 protocol；各工具禁止自写互斥计时格式。

---

## 9. Know-how

| KH | 落点 |
|---|---|
| KH-EV-01 | 并排金参考墙钟 |
| KH-X-05 | 先质量后速度 |
| KH-X-08 | ε |

---

## 10. 看板 + M0–M4

| 档 | 规则 | G |
|---|---|---|
| daily e2e | ≤1.5×；≥2/5 ≤1.0× | G21 |
| 分项 | 写入 profile | G21 |
| scale | ≤3× + 瓶颈 | G20 |

对照：同机复跑波动；关 OpenMP 看可扩展性；优化前后 QoR 必须并列。

```text
M0 只采 iEDA 基线
M1 并排比值观测
M2 热点优化（A/B）
M3 G21 门禁
M4 大设计瓶颈报告
```

---

## 11. Exhibit

`profile.jsonl`、`perf_align.json`、可选火焰图 SVG。

---

## 12. 测试

| # | 测试 |
|---|---|
| T1 | 钩子漏 stage → 校验 FAIL |
| T2 | 共享机 + exclusive 旗 → 拒跑 G21 |
| T3 | 优化 PR 无 QoR A/B → 拒合入 |
| T4 | 五套 profile 齐 |

---

## 13. 里程碑

随 12 M0–M1；G21 开关在 QoR 基线稳定后。

---

## 14. 未验证

| # | 项 |
|---|---|
| 1 | 现有工具 Monitor 能否复用 |
| 2 | 商业侧批跑墙钟采集方式 |
| 3 | NUMA/绑核对本机影响量级 |
| 4 | CUDA IR 等对 RSS 尖峰 |

**不要重走**：无剖面先「全面并行化」；无 A/B 降 effort 刷速度。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 质量优先 | 速度优先合入 |
| E-2 | 独占机协议 | 共享机进门禁 |
| E-3 | 分项必留 | 只看总分 |


---

## 附 · 与 G21 原文对齐

主纲 G21：五套日常基准端到端墙钟 **≤1.5×** 商业主对标方，且至少 **2/5 ≤1.0×**；关键步骤分项剖面进 JSON；大设计（G20）放宽 **≤3×** 且附瓶颈定位。

### 采集伪代码（落地版）

```text
assert protocol.perf.exclusive_host_required
pin_cores(protocol.perf.pin_cores)
set_threads(protocol.perf.threads)
for design in protocol.designs_daily:
  for stage in STAGES:
    t0, rss0 = now()
    run_stage(stage)
    emit profile.jsonl {design,stage,wall,cpu,rss,threads,hash}
compare with commercial profiles → perf_align.json
if protocol.perf.g21_enable: assert_ratios(ratios)
```

### 热点优化准入清单

1. 剖面显示该 stage ≥30% e2e；  
2. 有 QoR A/B（同 design，G17 指标不回归）；  
3. 算法默认不变则优先并行/容器/IO；  
4. 禁止关 DRC/STA 换速度。

### PR 与 12/40 交界

| 产物 | 所有者 |
|---|---|
| StageTimer 钩子 | 40 或公共 util |
| profile 目录 | 12 `benchmark/qor/` |
| compare 脚本 | 42 主笔，12 共管 |
| G21 CI 开关 | protocol |
