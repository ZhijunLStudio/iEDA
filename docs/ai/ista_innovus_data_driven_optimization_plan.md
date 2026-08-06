# iSTA 对齐 Innovus 的数据驱动优化路线图

状态：长期路线图
修订日期：2026-07-25

## 1. 文档定位

本文是 iSTA 对齐 Innovus 的长期路线图，负责记录实测证据、工作分层、阶段依赖和最终目标，不再承载 P0 的详细实现规格。

已批准的 P0 full STA 设计规格：

```text
/home/lifengyi/lifengyi/innovus_STA/docs/superpowers/specs/2026-07-25-ista-innovus-p0-full-sta-alignment-design.md
```

早期架构方案保留为历史参考：

```text
/home/lifengyi/lifengyi/innovus_STA/docs/reference/27-iSTA.md
```

iSTA 源码目录：

```text
/home/lifengyi/lifengyi/tools/iEDA/src/operation/iSTA
```

## 2. 数据来源与证据边界

历史比较文件位于：

```text
/home/lifengyi/lifengyi/innovus_STA/docs/comparisons/ista_innovus_comparison_v2/ista_innovus_comparison_report.html
/home/lifengyi/lifengyi/innovus_STA/docs/comparisons/ista_innovus_comparison_v2/all_design_comparison.csv
```

数据包含 18 个完整设计族、每族 30 个 routed variants，共 540 条有效记录；`s35932` 为 `INCOMPLETE`，不计入统计。

这些数据适合发现问题，但不能直接作为源码修复后的验收 oracle：

- 原始 path 报告链接仍指向旧环境 `/home/yangkang/...`；
- 历史流程的完整版本、模式和输入 hash 证据不可用；
- Innovus timing DRC 是 real-term count，iSTA 是 violating-report-row count；
- 30 个 variant 属于同一设计族，样本并非彼此独立；
- power 是 Innovus 与 iPA vectorless `-toggle 0.20` 的比较，不属于 iSTA timing engine。

因此，历史数据只用于确定优先级。正式验收使用重新运行的 Innovus/iSTA paired records 和合成微型 golden。

## 3. 实测差异

### 3.1 Setup

| 指标 | 历史 baseline |
|---|---:|
| WNS delta = iSTA - Innovus 均值 | `+0.175811 ns` |
| WNS delta 中位数 | `+0.005279 ns` |
| WNS MAE / RMSE | `0.508120 / 1.569952 ns` |
| WNS 相关系数 | `0.952408` |
| iSTA 更乐观 / 更悲观 | 295 / 245 |
| pass/fail mismatch | 49，其中 false clean 44 |
| 最大乐观异常 | `aes_t_route_congestion_best`, `+24.002524 ns` |
| TNS 最大绝对差 | 约 `32.9 us` |

Setup 主体趋势相关，但少量复杂设计存在严重 outlier。TNS 差异远大于 WNS，说明 endpoint/path-group 集合和聚合语义必须先于 PBA 校准。

### 3.2 Hold

| 指标 | 历史 baseline |
|---|---:|
| WNS delta 均值/MAE | `+0.956398 ns` |
| WNS delta 中位数 | `+0.799902 ns` |
| WNS delta 范围 | `+0.242702` 到 `+3.400899 ns` |
| iSTA 更乐观 | 540/540 |
| Innovus violation、iSTA clean | 433 |

这是当前最高的 signoff 风险。不过，历史结果不能证明根因必然位于 clock relation、CPPR 或 hold 公式；也可能包含分析模式、SDC、clock propagation 或 parser 差异。P0 必须用 component-level paired records 区分这些原因。

`gcd`、`s1238`、`s1488` 没有 pass/fail mismatch，但其平均 hold delta 仍分别约为 `0.568 ns`、`0.468 ns`、`0.548 ns`。它们只能作为分类未跨零的对照，不能称为数值正常对照。

### 3.3 Timing DRC

| 指标 | 历史 baseline |
|---|---:|
| Innovus timing DRC 非零记录 | 172/540 |
| iSTA timing DRC 非零记录 | 129/540 |
| Innovus max-cap 非零记录 | 124/540 |
| iSTA max-cap 非零记录 | 0/540 |
| fanout | 两边均为 0 |

源码显示 `StaReportTrans`、`StaReportCap`、`StaReportFanout` 按 `_n_worst` 截断输出，而历史比较以违规报告行计数。因此，先建立 full-count contract，再讨论数值算法。

已确认的 report 层问题：`StaReport.cc:1440` 在计算 fall cap slack 前检查了 `rise_limit`。该问题应由失败测试驱动修复，但不能单独解释所有 max-cap 记录为零。

### 3.4 Power

| 指标 | 历史 baseline |
|---|---:|
| iPA/Innovus total power 平均比值 | `2.646949x` |
| internal power 平均比值 | 约 `3.035x` |
| switching power 平均比值 | 约 `2.193x` |
| leakage power 平均比值 | 约 `0.975x` |

当前流程无 VCD，使用 vectorless activity。leakage 接近而 internal/switching 偏高，优先指向 activity、负载和 power table 使用方式。该工作属于独立 iPA 规格，不进入 iSTA P0。

## 4. 修订后的判断

### 4.1 已由数据支持

- hold 存在严重、系统性的 false-clean 风险；
- setup 误差集中于部分复杂设计，而不是固定 offset；
- WNS 尚不足以解释 TNS，需要 endpoint/path-group 口径；
- timing DRC 先有报告统计口径问题，再可能有约束/load 算法问题；
- power 不是 iSTA timing 问题，应与 iPA 分离。

### 4.2 尚未证明

- hold 偏差由 `analyzeClockRelation` 单一函数导致；
- setup outlier 的首因一定是缺少 PBA；
- max-cap 全零只由 `StaReportCap` 的 fall-limit 判断导致；
- 历史 TNS 差异只由 endpoint 重复求和导致；
- 30 ps 精度在当前模型和模式下无需 PBA/SI 即可实现。

这些假设必须通过 P0 component diff 或后续独立规格验证。

## 5. 路线图分层

### P0：Full STA 可信基线

独立规格：`docs/superpowers/specs/2026-07-25-ista-innovus-p0-full-sta-alignment-design.md`

目标：

- 固定 SKY130 TT/25 C/1.8 V、单 corner OCV、setup/hold CPPR；
- 建立 input manifest、raw artifacts、normalized JSON 和 semantic validator；
- 用微型 golden 验证 clock/check、WNS/TNS 和 DRC contract；
- 消除 hold 系统偏移和 guard-band 外 false clean；
- 分离 DRC full count 与 top-N display；
- 对齐 endpoint/path-group 和基础 load/delay 语义。

不包含 PBA、incremental、power、SI 和 MCMM。

### P1-A：Setup PBA 与 Delay Model

进入条件：P0 endpoint 集合、clock/check 和基础 delay contract 已稳定。

目标：

- 对 setup outlier 做 cell/net/clock component 分类；
- 引入受控 top-N PBA，而不是修改 GBA bucket 使其人为乐观；
- 显式化 Elmore/D2M/ECM/D2MC/Arnoldi/CCS mode；
- 验证 Liberty interpolation、Ceff 和接收端模型。

PBA 单调性修正：对于同一 setup path，PBA 消除 GBA 悲观性时应验证 `slack_pba >= slack_gba`。hold 不在路线图中套用未经证明的“对称”规则，必须在独立 PBA 规格中按 min-analysis 和相同 path identity 定义。

### P1-B：SDC 与 Signoff 模型覆盖

目标：

- 完成 SDC command/support matrix；
- generated clock、exceptions、case analysis 和 uncertainty 全覆盖；
- AOCV derate source/depth 可追溯；
- CCS/advanced library model 有固定 golden；
- 为后续 POCV/LVF 建立 scenario/variation 接口。

### P2-A：Incremental/InDesignTiming

进入条件：full STA reference engine 达到 P0 contract。

目标：

- 修复 `StaIncremental::applyBwdQueue` 使用 `_fwd_queue` 的明确问题；
- 建立 dirty-cone、失效传播和 full-vs-incremental diff；
- 提供 `estimate/incremental/full` 三档 API；
- 逐步统一 iTO/iPL/iCTS 的 timing 使用边界。

该问题明确存在，但与 standalone full STA 数值对齐无直接依赖，因此不进入 P0。

### P2-B：SI、MCMM 与高级变异

目标：

- 为被注释的 crosstalk propagation 建立 aggressor/victim fixture；
- 引入显式 ScenarioManager；
- 组合 mode、corner、SDC、RC 和 variation；
- 分阶段接入 SI、MCMM、POCV/LVF。

### 独立路线：iPA Power

目标：

- 两边固定 voltage、frequency、Liberty 和 activity window；
- 使用相同 VCD/SAIF；
- 分解 leakage/internal/switching；
- 对 cell activity、load 和 power table index 做 paired comparison。

该路线不作为 iSTA timing 验收 gate。

## 6. 阶段验收原则

| 阶段 | 主要验收 |
|---|---|
| P0 | semantic validation、synthetic `<=1 ps`、endpoint Jaccard、`+-50 ps` guard-band false clean、DRC precision/recall |
| P1-A | setup outlier component closure、PBA path identity/单调性、delay-mode golden |
| P1-B | SDC support matrix、variation source 可追溯、unsupported command 为 0 或显式阻断 |
| P2-A | incremental/full endpoint slack 一致性、dirty-cone 外不变、runtime |
| P2-B | scenario 完整性、SI/MCMM/variation 分量可追溯 |
| iPA | matched activity 下的 cell/component power error |

真实设计统计必须按 family 分层，同时报告 micro/macro 指标。pass/fail 使用 guard band，false clean 单独作为安全指标。无法匹配 endpoint 或分析语义的记录标记为 `NOT_COMPARABLE`，不得填零或混入平均值。

## 7. 关键源码区域

| 方向 | 源码区域 |
|---|---|
| clock/check | `StaAnalyze.cc`, `StaPathData.cc`, `StaCppr.cc` |
| WNS/TNS | `Sta.cc`, `StaPathData.hh/.cc`, `StaVertex.cc` |
| timing DRC | `StaApplySdc.cc`, `SdcTimingDRC.hh`, `StaReport.cc` |
| GBA/PBA | `StaData.cc`，后续独立 `StaPathBased` |
| delay/slew | `StaDelayPropagation.cc`, `StaDataSlewDelayPropagation.cc`, `StaBuildRCTree.*` |
| incremental | `StaIncremental.*`, `TimingEngine.cc/.hh` |
| SI/MCMM | `StaCrossTalkPropagation.*`, `Sta.hh` scenario/lib 管理 |
| power | `src/operation/iPA`，不属于 iSTA timing source |

## 8. 执行纪律

1. 先证明输入和语义可比，再比较数值。
2. 先写能够复现差异的失败测试，再修改源码。
3. 一次变更只处理一个根因假设。
4. 不用经验补偿常数拟合 Innovus。
5. 不用 top-N 行数冒充完整 DRC count。
6. endpoint 集合不一致时不调 TNS 求和公式。
7. 不用 PBA 掩盖 hold clock/check 问题。
8. 不把 iPA power 偏差写成 iSTA timing 缺陷。
9. 历史 540 条用于发现问题；新 paired baseline 用于验收。
10. 每个阶段完成后再创建下一阶段的独立设计规格和实施计划。

## 9. 当前优先级

```text
P0 manifest / normalized schema / semantic validation
 -> P0 synthetic golden
 -> P0 clock/check 与 hold false-clean
 -> P0 endpoint/WNS/TNS 与 full DRC contract
 -> P0 base load/delay
 -> P1 setup PBA/delay model
 -> P1 SDC/signoff model
 -> P2 incremental/InDesignTiming
 -> P2 SI/MCMM/POCV

iPA power 作为独立并行路线，在 matched activity 后收敛
```

这一路线优先解决“结果是否可比较”和“iSTA 是否错误报 clean”，再处理商业工具的高级精度与 in-design 性能能力。
