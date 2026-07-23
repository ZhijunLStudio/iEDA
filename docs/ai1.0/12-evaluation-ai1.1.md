<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 34 · iEval 3D 指标评估编排 + iWL / iCon · 详细设计（HLD + LLD）

> 文档号：34 | 版本：v0.1 | 里程碑：**M2 起首落 → M4 冻结**
> 负责模块：`src/evaluation`（iEval 编排 + iWL + iCon）+ 各分析工具 API 适配（iSTA/iPA/iIR/iTH/iDRC）
> 上游文档：00-overview、13-solver-partition、24-iPL-3d、25-iTH、29-iRT-3d、32-iSTA-3d、33-iPA-iIR-3d、35-iDRC-3d、40-platform-flow-3d、M5-fullflow-and-review
> 下游读者：全部结构类工具（iPAR/iFP/iPL/iCTS/iRT/iTO/iECO）、flow 编排、CI 门禁、GUI/MCP
> 本文 = ① iEval 作为"指标中台"的架构 ② 每个指标从粗到细的多档梯度评估方案 ③ 两个新工具 iWL / iCon 的详细设计 ④ 逐阶段"随时可查指标"的调用契约。

---

## 0. 变更记录

| 版本 | 日期 | 修订人 | 说明 |
|---|---|---|---|
| v0.1 | 2026-Q2 | 3D core | 初版：Evaluator3D 中台 + FidelityRouter 梯度路由 + iWL/iCon 新工具 + 6 大指标 coarse-to-fine 阶梯 |

---

## 1. 需求分析

### 1.1 业务背景与定位

物理设计是一个**从粗到细逐步确定几何**的过程：网表阶段没有坐标，划分阶段有 tier 归属，布图有 die/macro，布局有单元坐标，布线才有真实线段。每个阶段能拿到的信息不同 → **同一个指标（如时序、线长）在不同阶段只能用不同精度的估算**。

但今天 iEDA-3D 的现状（见 M5 评审 §2/§3）是：**指标散落在各工具内部、口径不一、无法跨阶段对比**：
- 线长：iPL 报 HPWL、iRT 报 GCell hops、iCTS 报 clock-WL，各算各的；`src/evaluation` 有 2D `wirelength_eval` 但未接 3D。
- 拥塞：只有 iRT GR overflow 与 iDRC 违例；无独立"拥塞计算"工具，布局阶段拿不到 routability 预估。
- 时序/功耗/IR/温度：只有 signoff 末端一次（iSTA/iPA/iIR/iTH），**早期阶段无法"随时查一眼"**当前时序/温度好不好。

**iEval 的定位 = 指标中台（metric hub）**：把所有评估/验证工具（iSTA、iPA、iIR、iTH、iDRC，加两个新工具 **iWL** 线长、**iCon** 拥塞）的 API 统一接出，对上层每个流程阶段提供**一个入口、一种口径、按阶段自动选精度**的指标查询。让 iPAR/iFP/iPL/iCTS/iRT/iTO/iECO **在任意时刻**都能问："当前设计的 WNS / 线长 / 拥塞 / 功耗 / 峰温 / IR 是多少？"—— iEval 据当前阶段与可用数据，路由到合适精度的评估器，算完返回。

**关键理念：coarse-to-fine 梯度评估。** 每个指标提供一条从 T0（最粗、最快、最早可用）到 T_n（最细、最准、最晚可用）的**评估阶梯**；iEval 的 `FidelityRouter` 依据(阶段、请求精度、时间预算)在阶梯上**选一档**执行。早期用便宜代理指导优化方向，晚期用真实引擎签核。

### 1.2 完整功能清单（FR）

| ID | 功能 | 备注 |
|---|---|---|
| FR-EVAL-01 | 统一评估入口 `Evaluator3D::evaluate(MetricSpec)->MetricResult` | 指标中台 |
| FR-EVAL-02 | 支持 7 类指标：**WL / CONGESTION / TIMING / POWER / IR / TEMP / DRC** | |
| FR-EVAL-03 | 每类指标多档 fidelity（COARSE/MEDIUM/FINE/SIGNOFF），可 AUTO 按阶段选 | §5 阶梯表 |
| FR-EVAL-04 | `FidelityRouter`：(metric,stage,fidelity)→具体 estimator，一份路由真相 | |
| FR-EVAL-05 | 新工具 **iWL**（线长）：HPWL / RSMT(FLUTE) / GR / DR / 层间 via 长度 | §4.5 |
| FR-EVAL-06 | 新工具 **iCon**（拥塞）：RUDY / EGR / GR-overflow / DRC-density + per-tier + 层间 via | §4.6 |
| FR-EVAL-07 | 适配已有工具：iSTA(timing) / iPA(power) / iIR(ir) / iTH(temp) / iDRC(drc) 的 API 接出 | §4.7 |
| FR-EVAL-08 | 3D 语义：所有指标支持 **per-tier + 整栈 + 层间(inter-tier)** 三种 scope | |
| FR-EVAL-09 | 结果携带 provenance：用了哪档 estimator、输入完备度、耗时、置信度 | 可 diff/可解释 |
| FR-EVAL-10 | 指标缓存 + 增量失效：上游 stage 改动 → 失效其下游缓存 | 省重算 |
| FR-EVAL-11 | 逐阶段调用契约：每个 flow stage 可 `iEval.query(metric)` 拿当前值 | §6 |
| FR-EVAL-12 | 指标快照 + 趋势：每 stage 落 `eval_<stage>.json`，汇成 `metrics_trend.{json,csv}` | 看指标随阶段收敛 |
| FR-EVAL-13 | 时序模型可插拔：Elmore（默认）/ 高阶(2-pole/AWE) / 真实 iSTA | §5.3 |
| FR-EVAL-14 | 可借外部工具：允许把 delay/power 计算委托给真实分析引擎（iSTA/iPA） | |
| FR-EVAL-15 | 2D 回退：`is_2d()` → 退化为现有 2D `src/evaluation`（wirelength/congestion/density），零回归 | |
| FR-EVAL-16 | TCL/Python/MCP：`report_eval_3d -metric <..> [-stage ..][-fidelity ..]` | doc 41 |
| FR-EVAL-17 | gtest：每 estimator 单测 + 阶梯单调性（细档不比粗档差太多）+ e2e | |
| FR-EVAL-18 | 预算控制：每次 evaluate 有时间/内存预算，超预算降档 | |

### 1.3 非功能需求（NFR）

| ID | 项 | 指标 |
|---|---|---|
| NFR-EVAL-01 | COARSE 档延时（bp_fe） | ≤ 50 ms（供 iPL 每 K 次迭代查一次） |
| NFR-EVAL-02 | MEDIUM 档（RSMT/EGR/coarse-IR） | ≤ 2 s |
| NFR-EVAL-03 | FINE/SIGNOFF（真实 iSTA/iPA/iIR/iTH） | 复用工具本身预算，不额外拷贝数据 |
| NFR-EVAL-04 | 内存 | 与被调工具共享 iDB/IdbStack3D，无副本（NFR-FLOW-02） |
| NFR-EVAL-05 | 可扩展 | 新增一档 estimator 只需实现 `IMetricEstimator` + 在 router 注册 |
| NFR-EVAL-06 | 可测 | gtest 80% |
| NFR-EVAL-07 | 可观测 | glog 前缀 `[iEval]` + 每次 evaluate 记 fidelity/耗时 |

### 1.4 约束

- **零回归红线**：`stack.is_2d()==true` → iEval 走现网 2D `src/evaluation`，产物逐字节不变。
- **数据共享**：与工具共用同一份 `IdbStack3D` / `IdbDesign`；iEval 不持有设计副本。
- **单例引擎约束（M5 P0-A）**：真实 `ista::TimingEngine` / `ipower::PowerEngine` 进程单例、一次 build 全程复用；iEval 的 SIGNOFF 档**复用** flow 已建引擎（`ensureSignoffTimingEngine`），不得二次 build。
- **口径单一**：同一指标同一 scope 只有一个定义（如线长单位 DBU、时序单位 ps、功耗 W、温度 °C、IR V、拥塞 = demand/capacity 无量纲）。
- **复用优先**：FLUTE(`init_flute`)、EGR(`init_egr`)、`wirelength_lut`、2D `wirelength_eval/congestion_eval/density_eval` 已在 `src/evaluation`，3D 扩展而非重写。
- 依赖：`IdbStack3D`、各工具 `xxxApi`、`nlohmann/json`、`glog`、FLUTE/EGR（vendored）。

### 1.5 用户与场景

| 用户 | 场景 |
|---|---|
| iPL nesterov | 每 K 次迭代 `iEval.query(WL,COARSE)` / `query(CONG,MEDIUM)`（EGR）指导密度/布线友好 |
| iPAR | 划分后 `query(WL,partition)` 看跨 die 净数、`query(TIMING,partition)` 看跨 die 关键路径 |
| iFP | `query(WL,fp)` 宏 HPWL、`query(CONG,fp)` 宏阻塞图 |
| iCTS | `query(TIMING,cts)` 把 clock latency 计入 TNS/WNS |
| iRT | route 前 `query(CONG,GR)` 看 overflow、route 后 `query(WL,DR)` 真实线长 |
| iTO/iECO | `query(TIMING,post-route)` 真实 RC 时序，指导修复 |
| flow / CI | 每 stage 落 `eval_<stage>.json` → `metrics_trend`，门禁比对 golden |
| GUI/MCP | 订阅指标、画 per-tier 热/拥塞/密度图 |

---

## 2. HLD 总体架构

### 2.1 上下文图

```
      iPAR   iFP   iPL(GP/LG/DP)   iCTS   iRT   iTO   iECO      ← 上层：任意阶段发起查询
        └──────┬──────┴───────┬───────┴──────┬──────┘
               ▼              ▼              ▼
        ┌───────────────────────────────────────────────┐
        │                iEval (Evaluator3D)             │  指标中台
        │  ┌──────────────┐   ┌────────────────────────┐ │
        │  │ FidelityRouter│──▶│ MetricCache (增量失效)  │ │
        │  └──────┬───────┘   └────────────────────────┘ │
        │         ▼  按 (metric,stage,fidelity) 选 estimator │
        │  ┌──────────────────────────────────────────┐  │
        │  │  estimators / backend adapters            │  │
        │  └──┬────┬─────┬─────┬─────┬─────┬─────┬──────┘  │
        └─────┼────┼─────┼─────┼─────┼─────┼─────┼─────────┘
              ▼    ▼     ▼     ▼     ▼     ▼     ▼
            iWL  iCon  iSTA  iPA   iIR   iTH   iDRC       ← 底层：评估/验证工具
          (线长)(拥塞)(时序)(功耗)(压降)(温度)(DRC)
              │    │
     (FLUTE/HPWL/GR/DR)  (RUDY/EGR/GR-ovfl/DRC)   ← 新工具内部算法
                     │
                   IdbStack3D / IdbDesign（单实例，共享）
```

### 2.2 组件架构

```
src/evaluation/
├── api/
│   ├── union_api.{h,cpp}            (现有 2D 汇总 API)
│   ├── wirelength_api.h congestion_api.h density_api.h  (现有)
│   └── evaluator3d_api.{h,cpp}      (M2 新增：Evaluator3D 中台 facade)
├── src/
│   ├── eval3d/
│   │   ├── evaluator3d.{h,cpp}      (中台主类：evaluate/query/snapshot)
│   │   ├── metric_spec.h            (MetricSpec/MetricResult/Fidelity/Stage 数据模型)
│   │   ├── fidelity_router.{h,cpp}  (梯度路由：(metric,stage,fid)->estimator)
│   │   ├── metric_cache.{h,cpp}     (缓存 + 依赖失效)
│   │   ├── i_metric_estimator.h     (估算器接口)
│   │   └── adapters/                (真实工具适配：sta/pa/ir/th/drc)
│   │       ├── timing_adapter.{h,cpp}  power_adapter.{h,cpp}
│   │       ├── ir_adapter.{h,cpp}      thermal_adapter.{h,cpp}
│   │       └── drc_adapter.{h,cpp}
│   └── module/
│       ├── wirelength/  congestion/  density/  timing/  (现有 2D)
│       ├── iwl3d/                    (M2 新增：iWL 线长工具，见 §4.5)
│       └── icon3d/                   (M2 新增：iCon 拥塞工具，见 §4.6)
├── database/  (现有 *_db.h + 新增 eval3d_summary_db.h)
└── test/
```

> iWL / iCon 也可独立成 `src/operation/iWL` `src/operation/iCon`（工具化，含 TCL 命令）；本文采用**放在 `src/evaluation` 内、由 iEval 直接调**的轻量方案，工具化留 v0.2（decision §2.4）。

### 2.3 数据流

```
上层 stage ── MetricSpec{kind,stage,fidelity,scope} ──▶ Evaluator3D
                                                        │
                              MetricCache 命中? ── 是 ──▶ 直接返回（含 provenance: cached）
                                                        │ 否
                              FidelityRouter.route(spec) ─▶ 选定 estimator + 实际 fidelity（可降档）
                                                        │
                              estimator.eval(stack/design, spec) ─▶ 调 iWL/iCon/iSTA/... 计算
                                                        │
                              MetricResult{scalar, per_tier[], map, provenance, wall_s}
                                                        │
                              cache.put(key,result) + snapshot(eval_<stage>.json)
                                                        ▼
                                                     返回上层
```

### 2.4 关键设计决策

| 决策 | 选项 | 选择 | 理由 |
|---|---|---|---|
| iEval 形态 | ①每工具自报 ②中台统一 | ② | 口径单一 + 逐阶段可查 + 可 diff |
| 精度选择 | ①调用方指定 ②中台按阶段自动 | 混合（AUTO 默认，可强制） | 上层无需懂哪档；专家可覆盖 |
| iWL/iCon 归属 | ①独立 operation 工具 ②eval 内模块 | ②（v0.1）→ ① v0.2 | 先轻量接出可查；工具化(TCL/独立库)后置 |
| 时序早期估算 | ①自算 Elmore ②必须真 STA | 阶梯（早 Elmore/代理，晚真 iSTA） | 早期无 RC 无法真 STA；代理指方向 |
| 时序模型 | ①Elmore ②高阶 AWE ③真引擎 | 可插拔（默认 Elmore，关键网 2-pole，签核真引擎） | 精度/成本按需 |
| 拥塞早期 | ①RUDY ②EGR ③真 GR | 阶梯（RUDY→EGR→GR-overflow→DRC） | 逐阶段可用信息递增 |
| 结果 scope | ①整栈 ②per-tier ③层间 | 三者都出 | 3D 必须区分 tier + 层间 |
| 缓存失效 | ①全清 ②按依赖图 | 按 stage 依赖（改布局→失效 WL/CONG/TIMING…下游） | 省重算 |
| 单例引擎 | ①iEval 自建 ②复用 flow | ②复用（M5 P0-A） | 避免二次 build SIGSEGV |
| 2D 回退 | ①iEval 内判 ②工具判 | iEval 主判（is_2d 走现网 eval） | 零回归 |

### 2.5 依赖矩阵

| 依赖 | 类型 | 用途 |
|---|---|---|
| `IdbStack3D`/`IdbDesign` | 内部 | 数据底座 |
| iWL / iCon | 内部（本文新增） | 线长 / 拥塞 |
| `ista::TimingEngine` / `ipower::PowerEngine` | 内部 | 真实 timing/power（复用 flow 单例） |
| `iir3d::IrApi3D` / `ith::ThermalApi` / `idrc::DRC3DInterface` | 内部 | IR / 温度 / DRC |
| FLUTE(`init_flute`) / EGR(`init_egr`) / `wirelength_lut` | 现有 vendored | RSMT / 早期 GR / WL 查表 |
| 2D `wirelength_eval`/`congestion_eval`/`density_eval` | 现有 | is_2d 回退 |
| `nlohmann/json` / `glog` | 三方 | 快照 / 日志 |

---

## 3. 数据与接口

### 3.1 数据模型

```cpp
namespace ieval {

enum class Metric   { kWirelength, kCongestion, kTiming, kPower, kIR, kTemp, kDRC };
enum class Stage    { kNetlist, kPartition, kFloorplan, kPlaceGlobal, kPlaceLegal,
                      kPlaceDetail, kCTS, kGlobalRoute, kDetailRoute, kPostRoute };
enum class Fidelity { kAuto, kCoarse, kMedium, kFine, kSignoff };
enum class Scope    { kWholeStack, kPerTier, kInterTier };

struct MetricSpec {
  Metric   metric;
  Stage    stage;
  Fidelity fidelity = Fidelity::kAuto;
  Scope    scope    = Scope::kWholeStack;
  int      tier     = -1;   // Scope::kPerTier 时指定；-1=全部
  nlohmann::json opts;      // estimator 专属参数（如 timing model、grid、clock 名）
};

struct MetricResult {
  bool     ok = true;
  double   value = 0.0;                 // 主标量（WL=DBU, TNS/WNS=ps, P=W, IR=V, T=°C, CONG=overflow, DRC=count）
  std::vector<double> per_tier;         // 逐 tier 值
  double   inter_tier = 0.0;            // 层间贡献（跨 die 净长 / 层间 via 拥塞 / 层间热阻…）
  std::vector<float>  map;              // 可选：per-tier×nx×ny 空间图（拥塞/密度/温度/IR）
  int      map_nx = 0, map_ny = 0, map_tiers = 0;
  // provenance（可解释 + 可 diff）
  Fidelity used_fidelity = Fidelity::kCoarse;
  std::string estimator;                // 实际用的 estimator 名
  double   confidence = 0.0;            // 0..1 经验置信度（细档更高）
  double   wall_seconds = 0.0;
  bool     cached = false;
  std::string detail;                   // 人读补充（关键路径 / 峰值位置 / 溢出 GCell 数）
};

struct IMetricEstimator {              // §4.4 估算器接口
  virtual ~IMetricEstimator() = default;
  virtual Metric   metric() const = 0;
  virtual Fidelity fidelity() const = 0;
  virtual bool     available(Stage s) const = 0;  // 该阶段数据是否够
  virtual MetricResult eval(idb::IdbStack3D* stack, const MetricSpec& spec) = 0;
};

}  // namespace ieval
```

### 3.2 对外 API

#### 3.2.1 C++ Facade

```cpp
class Evaluator3D {
 public:
  static Evaluator3D& getInst();
  // 单点查询（AUTO 会按 stage 选档，可能降档并在 result.used_fidelity 标注）
  MetricResult evaluate(const MetricSpec& spec);
  // 便捷入口（上层最常用）
  MetricResult wirelength (Stage s, Fidelity f = Fidelity::kAuto);
  MetricResult congestion (Stage s, Fidelity f = Fidelity::kAuto);
  MetricResult timing     (Stage s, Fidelity f = Fidelity::kAuto);   // 返回 WNS/TNS in detail
  MetricResult power      (Stage s, Fidelity f = Fidelity::kAuto);
  MetricResult irDrop     (Stage s, Fidelity f = Fidelity::kAuto);
  MetricResult temperature(Stage s, Fidelity f = Fidelity::kAuto);
  MetricResult drc        (Stage s, Fidelity f = Fidelity::kAuto);
  // 一次算全部指标（供 stage 结束落快照）
  nlohmann::json snapshot(Stage s);                 // -> eval_<stage>.json
  void   invalidateFrom(Stage s);                   // 上游改动 -> 失效下游缓存
  void   bind(idb::IdbStack3D* stack, idb::IdbDesign* design);
};
```

#### 3.2.2 TCL（doc 41）

| 命令 | 参数 | 语义 |
|---|---|---|
| `report_eval_3d` | `-metric <wl\|cong\|timing\|power\|ir\|temp\|drc>` `[-stage <s>]` `[-fidelity <auto\|coarse\|medium\|fine\|signoff>]` `[-per_tier]` `[-dir <d>]` | 查一个指标 |
| `report_eval_all` | `[-stage <s>]` | 落 `eval_<stage>.json`（全指标当前值） |
| `report_metrics_trend` | `[-file <csv>]` | 汇总各 stage 快照成趋势 |
| `eval_wirelength_3d` / `eval_congestion_3d` | `[-fidelity ..]` | iWL / iCon 直连 |

#### 3.2.3 Python / MCP

`ieda3d.eval.wirelength(stack, stage="place", fidelity="medium") -> {value, per_tier, ...}`；MCP tool `eval.report_3d {metric,stage,fidelity}`（schema 自动从命令 metadata 生成，doc 41 §3.4）。

### 3.3 输入 / 输出

- **输入**：`IdbStack3D`+`IdbDesign`（共享）、`MetricSpec`、（SIGNOFF 档）复用 flow 的 STA/PA 引擎与 iRCX SPEF。
- **输出**：`MetricResult`（内存）；`eval_<stage>.json`（每 stage 快照）；`metrics_trend.{json,csv}`（趋势）；可选 `<metric>_map_<tier>.csv`（空间图，供 GUI）。

---

## 4. LLD 模块分解

### 4.1 `Evaluator3D`（中台主类）
- **职责**：唯一入口。`evaluate` = 查缓存→路由→执行→缓存→快照。持有 `FidelityRouter`/`MetricCache`/estimator 注册表；不持设计副本。
- **算法**（ALG-4.1）：
```
evaluate(spec):
  if stack.is_2d(): return legacy2D(spec)          # 零回归
  key = (spec.metric, spec.stage, spec.fidelity, spec.scope, spec.tier, hash(design_state))
  if cache.has(key): return cache.get(key).mark(cached=true)
  est = router.route(spec)                          # 可能降档
  t0=now; r = est.eval(stack, spec); r.wall=now-t0
  r.used_fidelity = est.fidelity(); r.estimator = est.name()
  cache.put(key, r); emit [iEval] log
  return r
```
- **边界**：无可用 estimator（该阶段数据不足）→ ok=false + 提示"stage 太早，先跑 X"；预算超 → 降档并标注。

### 4.2 `FidelityRouter`（梯度路由）
- **职责**：把 (metric, stage, requested_fidelity) 映射到具体 estimator。**一份路由真相**（表驱动，见 §5 各指标阶梯表）。
- **算法**：AUTO → 取"该 stage 可用的最高档且满足预算"的 estimator；显式档 → 若该档在此 stage 不可用则降到最近可用档并 `LOG(WARN)`。注册表 `map<(Metric,Fidelity), IMetricEstimator*>`。

### 4.3 `MetricCache`（缓存 + 增量失效）
- **职责**：`(key)->MetricResult`；`invalidateFrom(stage)` 依据 stage 依赖图清下游（改 place → 失效 WL/CONG/TIMING/POWER/IR/TEMP；改 route → 失效 WL(DR)/TIMING(post)/IR/DRC）。
- **算法**：LRU + 依赖邻接表；design_state hash（instance 坐标/net 结构版本号）参与 key。

### 4.4 `IMetricEstimator`（估算器接口）
- 每档一个实现类（如 `WlHpwlEstimator`/`WlRsmtEstimator`/`TimingElmoreEstimator`/`TimingStaEstimator`…）；`available(stage)` 声明数据前置；`eval()` 调对应工具。新增一档 = 实现接口 + router 注册（NFR-EVAL-05）。

### 4.5 `iWL`（线长工具，新）—— §FR-EVAL-05

**4.5.1 职责**：多档线长计算，3D 感知（per-tier 平面长 + 层间 via 长 + 跨 die 净数）。

**4.5.2 类**：
```cpp
namespace iwl {
struct WlResult {
  double total = 0, hpwl = 0, rsmt = 0, routed = 0;   // DBU
  std::vector<double> per_tier;                        // 各 tier 平面线长
  double inter_tier_via_len = 0;                       // Σ |Δtier|·HBT_height
  int    cross_die_nets = 0;                           // 跨 tier 净数
  int    steiner_nets = 0; double runtime_s = 0;
};
class WirelengthApi3D {
 public:
  // fidelity: kHpwl / kRsmt / kGrLen / kDrLen（对应 §5.1 T2..T7）
  WlResult run(idb::IdbStack3D* stack, idb::IdbDesign* design, Fidelity f);
 private:
  double hpwlNet_(net);                 // 半周长 bbox（含 z? 否，平面 bbox；层间单列）
  double rsmtNet_(net);                 // FLUTE 3D-MST + Hanan Steiner（init_flute）
  double grLenNet_(net);                // 从 iRT GR 的 GCell 路径读长
  double drLenNet_(net);                // 从 IdbNet.wire 真实线段累加
  double interTierViaLen_(stack);       // HBT 高度×跨层次数
};
}
```
**4.5.3 算法**：
- **HPWL**（T2/T3）：`Σ_net (max_x−min_x)+(max_y−min_y)`，只算与该 net 同 tier 的 pin 平面 bbox；跨 tier 的 pin 贡献计入 `inter_tier_via_len`（用 HBT via 桥接，不进平面 bbox）。
- **RSMT**（T4/T6）：每 net 用 FLUTE 出矩形 Steiner 树长；跨 tier net = 各 tier 子树 Steiner 长 + 层间 via 长（在 HBT 座点断开）。
- **GR 长**（T5）：读 iRT `GlobalRouter3D` 的 GCell 路径累加（含 z-hop）。
- **DR 长**（T7）：读 `IdbNet.wire` 的 metal 段真实长 + via 计数×via 高度。
- **层间 via 长**：`Σ_via |upper_tier−lower_tier| · IdbStackTech.tier_thickness`（或 HBT 物理高度）。
**4.5.4 关键函数**

| 函数 | 输入 | 输出 | 前置 | 复杂度 |
|---|---|---|---|---|
| `run(...,kHpwl)` | design | WlResult | 有坐标 | O(pins) |
| `run(...,kRsmt)` | design | WlResult | 有坐标 | O(nets·flute) |
| `run(...,kDrLen)` | design | WlResult | 已布线(IdbNet.wire) | O(segments) |

**4.5.7 边界**：无坐标(netlist)→只出 `cross_die_nets`/fanout 代理（value=0, confidence 低）；未布线→routed=0。

### 4.6 `iCon`（拥塞工具，新）—— §FR-EVAL-06

**4.6.1 职责**：多档拥塞（routability）计算，3D 感知（per-tier 平面拥塞图 + 层间 via 拥塞）。**拥塞 = 布线需求/容量**；DRC 违例是拥塞的最细体现。

**4.6.2 类**：
```cpp
namespace icon {
struct CongestionMap {
  int num_tiers=0, nx=0, ny=0;
  std::vector<float> demand, capacity, overflow;   // per-tier×nx×ny（overflow=max(0,demand-cap)）
  double peak_overflow=0, avg_overflow=0, aco=0;   // ACE/ACO 汇总
  std::vector<std::tuple<int,int,int>> hotspots;   // (tier,x,y) 溢出点
  // 层间：HBT 座点利用率（inter-tier via 拥塞）
  double inter_tier_via_util=0; int over_cap_hbt=0;
  double runtime_s=0;
};
class CongestionApi3D {
 public:
  // fidelity: kPinRudy / kEgr / kGrOverflow / kDrcDensity（对应 §5.2 T3..T6）
  CongestionMap run(idb::IdbStack3D* stack, idb::IdbDesign* design, Fidelity f, int nx=256, int ny=256);
 private:
  void rudy_(design, CongestionMap*);       // pin/net RUDY: net bbox 面积均摊布线需求
  void egr_(design, CongestionMap*);        // 概率早期全局布线（init_egr）
  void grOverflow_(CongestionMap*);         // 读 iRT GR 的 GCell edge demand/capacity
  void drcDensity_(CongestionMap*);         // 读 iDRC 违例密度
  void interTierViaCong_(stack, CongestionMap*);  // HBT 座点需求 vs 容量
};
}
```
**4.6.3 算法**：
- **RUDY**（T3, 布局早期）：每 net 把布线需求 = `HPWL / bbox_area` 均摊到其 bbox 覆盖的 GCell；pin-RUDY 加 pin 密度项。逐 tier 独立算。O(nets·bbox_cells)。
- **EGR**（T4）：概率型早期全局布线（复用 `init_egr`），出每 GCell edge 的期望需求 → overflow。比 RUDY 准，比真 GR 快。
- **GR-overflow**（T5, 全局布线后）：直接读 `GlobalRouter3D` 的 GCell edge demand/capacity → overflow（真实）。
- **DRC-density**（T6, 详细布线后）：读 iDRC 违例，按 GCell 聚合成密度图（最细拥塞）。
- **层间 via 拥塞**：每 HBT 座点的跨层 net 需求 vs `IdbBondingConfig` 容量；over_cap 计数（供 iBond/iPAR 反馈）。
**4.6.4 关键函数**

| 函数 | 输入 | 输出 | 前置 | 复杂度 |
|---|---|---|---|---|
| `run(...,kPinRudy)` | design | CongestionMap | 有坐标 | O(nets·bbox) |
| `run(...,kEgr)` | design | CongestionMap | 有坐标 | O(EGR) |
| `run(...,kGrOverflow)` | — | CongestionMap | 已全局布线 | O(GCell edges) |

**4.6.7 边界**：无坐标→只出 per-tier cell/pin 密度代理；未布线→用 RUDY/EGR。

### 4.7 backend adapters（真实工具接出）
- **TimingAdapter** → `ista::TimingEngine`（复用 flow 单例）；SIGNOFF 档：读 iRCX 3D SPEF → `updateTiming` → WNS/TNS/关键路径。MEDIUM/FINE 档：Elmore/AWE（§5.3），不建引擎。
- **PowerAdapter** → `ipower::PowerEngine`（复用单例）；早期档：liberty 内部功耗 + 活动率代理 + 线容(来自 iWL)。
- **IrAdapter** → `iir3d::IrApi3D`（G·V=I）；MEDIUM：coarse grid；SIGNOFF：真实 PDN 网格。
- **ThermalAdapter** → `ith::ThermalApi`（FDM/AMGCL）；输入功耗来自 PowerAdapter（统一功耗源，修 M5 P1）。
- **DrcAdapter** → `idrc::DRC3DInterface`（违例数/密度，兼作 iCon T6 输入）。
- 适配器**只转数据 + 选档**，不复制引擎；单例复用见约束 §1.4。

---

## 5. 逐指标 coarse-to-fine 梯度评估方案

> 记号：Tk = 第 k 档；"可用起点" = 该档最早能算的 stage。每档给 (方法 / 输入 / 精度 / 成本)。

### 5.1 线长 Wirelength（iWL）

| 档 | 可用起点 | 方法 | 输入 | 精度 | 成本 |
|---|---|---|---|---|---|
| T0 | 网表 | fanout/pin-count 代理（Σfanout·单位长） | 网表 | 极粗（无坐标） | 极低 |
| T1 | 划分 | 跨 die net 数 × 平均 span 估计 | tier_id | 粗（3D 关键量） | 低 |
| T2 | 布图 | **macro HPWL**（宏 pin bbox 半周长） | 宏坐标 | 中(宏级) | 低 |
| T3 | 布局 | **全网 HPWL** | 全单元坐标 | 中 | 低(O(pins)) |
| T4 | 布局 | **RSMT 斯坦纳**(FLUTE) + 层间 via 长 | 坐标 | 较高 | 中(O(nets·flute)) |
| T5 | 全局布线 | **GR GCell 路径长**（含 z-hop 跨层斯坦纳） | GR 结果 | 高 | 中 |
| T6 | 详细布线 | **DR 真实线段长**（IdbNet.wire）+ via×高度 | 布线几何 | 精确 | 中(O(segs)) |

### 5.2 拥塞 Congestion（iCon）—— 亦即 DRC-routability

| 档 | 可用起点 | 方法 | 输入 | 精度 | 成本 |
|---|---|---|---|---|---|
| T0 | 网表 | 无 / fanout 密度代理 | 网表 | 极粗 | 极低 |
| T1 | 划分 | per-tier cell/pin 密度 | tier_id | 粗 | 低 |
| T2 | 布图 | 宏阻塞密度图 | 宏 | 粗 | 低 |
| T3 | 布局 | **RUDY / pin-RUDY**（net bbox 布线需求均摊） | 坐标 | 中 | 低 |
| T4 | 布局 | **EGR 概率早期全局布线** overflow | 坐标 | 较高 | 中(init_egr) |
| T5 | 全局布线 | **GCell edge overflow**（真实 demand/cap） | GR | 高 | 中 |
| T6 | 详细布线 | **DRC 违例密度**（iDRC，最细） | 布线+规则 | 精确 | 中 |
| 3D | 全程 | **层间 HBT 座点利用率**（跨层 net 需求 vs 容量） | inter-via | — | 低 |

### 5.3 时序 Timing（iSTA + iEval 时序阶梯）—— 用户给的 9 档

| 档 | 可用起点 | 方法 | 模型 | 精度 |
|---|---|---|---|---|
| T0 | 网表 | **fanout + logic depth** → delay=depth·(gate+fanout·load) | 单位延迟 | 极粗 |
| T1 | 划分 | + **跨 die net 数**（每跨层 +HBT delay） | +HBT | 粗 |
| T2 | 布图 | macro **HPWL** → 宏网线延迟 | Elmore(lumped) | 中(宏级) |
| T3 | 布局 | **全网 HPWL** → 线延迟 | Elmore | 中 |
| T4 | 布局 | **斯坦纳(RSMT)** 长 → 更准线延迟 | Elmore(distributed) | 较高 |
| T5 | CTS | + **时钟延迟/skew** → 真 **TNS/WNS** | Elmore + clock | 高(时序完整) |
| T6 | 全局布线 | **跨层斯坦纳**长（含 z-via） → delay | Elmore/2-pole | 高 |
| T7 | 详细布线 | **精确线长** → delay | 2-pole/AWE | 很高 |
| T8 | 布线后 | **RC 提取(iRCX SPEF)** → **真实 iSTA** | 真引擎(MCMM/异构角) | 签核 |

**5.3.1 时序模型（FR-EVAL-13）**：
- **Elmore**（默认，T2–T6）：`τ = Σ R_i·C_downstream(i)`；线网用 π 模型；跨层 via 用 `IdbInterTierVia.rc()`。lumped（早）/ distributed（RSMT 后）。
- **高阶**（T6–T7 关键网）：2-pole / AWE（moment matching），对长互连/时钟网更准。
- **真实引擎**（T8）：`ista::TimingEngine` 读 3D SPEF（iRCX 已出真实 cell-pin SPEF，M5 P0-C 已解），异构 corner + 热 derate（挂 iSTA MCMM 钩子）。
- **可借外部**（FR-EVAL-14）：任意档可把 delay 计算委托真实 iSTA 增量（`reportDelay(net)`），iEval 只做口径归一。

### 5.4 功耗 Power（iPA + 阶梯）

| 档 | 可用起点 | 方法 | 输入 | 精度 |
|---|---|---|---|---|
| T0 | 网表 | gate 数 × 平均功耗 / 活动率代理 | 网表+liberty | 粗 |
| T1 | 划分 | **per-tier gate 功耗** | tier_id | 粗(分层) |
| T2 | 布局 | + 线容(来自 iWL HPWL) → switching | 坐标 | 中 |
| T3 | 布局 | liberty internal + leakage + 活动率 | liberty | 中 |
| T4 | CTS后 | + **时钟网功耗**（clock cap·f） | 时钟树 | 较高 |
| T5 | 布线后 | 真实线容(RC) → 精确 switching；**真实 iPA PowerEngine** | SPEF+SAIF | 签核 |
| 3D | — | **per-tier 功耗图**（PowerMapBuilder）供 iTH | — | — |

### 5.5 电压降 IR-drop（iIR + 阶梯）

| 档 | 可用起点 | 方法 | 输入 | 精度 |
|---|---|---|---|---|
| T0–T2 | ≤布局 | 无 PDN → 均匀电流密度代理 | 功耗代理 | 粗 |
| T3 | PDN 规划 | **I·R 闭式 IR 包络**（iPDN budget-level） | 电流+R_stack | 中 |
| T4 | PDN 布线 | coarse **G·V=I** on 粗网格 | mesh R+功耗图 | 较高 |
| T5 | 布线后/签核 | **full G·V=I**（iir3d IrApi3D，真实 PDN 网格 + 层间 via R） | 真 PDN+真功耗 | 签核 |
| 3D | — | **堆叠 G 矩阵 + per-tier 电压图**（tier 离封装越远压降越大） | inter-via R | — |

### 5.6 温度 Temperature（iTH + 阶梯）

| 档 | 可用起点 | 方法 | 输入 | 精度 |
|---|---|---|---|---|
| T0–T2 | ≤布局 | 环境温 / 均匀代理（总功耗×lumped Rth） | 功耗代理 | 粗 |
| T3 | 布局后 | **coarse FDM** 粗网格 + 功耗图 | 功耗图 | 中 |
| T4 | 功耗后 | **FDM(手写 CG)** on 标准网格 | per-tier 功耗图 | 较高 |
| T5 | 签核 | **FDM/AMGCL + Picard P↔T 自洽**（iTH runCoupled） | 真功耗+栈热参 | 签核 |
| 3D | — | **per-tier + 层间 via 热导 + heatsink 边界**；反馈 iPL loadHeatField | 栈热 | — |

### 5.7 DRC（iDRC）
| 档 | 可用起点 | 方法 |
|---|---|---|
| 粗 | 布局 | 密度/pin 拥塞代理（=iCon T3） |
| 中 | 全局布线 | GCell overflow → 预期违例（=iCon T5） |
| 细 | 详细布线 | **真实 iDRC**（inter-tier via 规则 + per-tier 金属 spacing/width/short） |

> 统一：iCon 的最细档 = iDRC 违例密度；iEval 让"拥塞"与"DRC"共用一条数据管线，早期估、晚期验。

### 5.8 阶段 × 指标 × 精度 路由矩阵（AUTO 默认选中的档）

| stage \ metric | WL | CONG | TIMING | POWER | IR | TEMP | DRC |
|---|---|---|---|---|---|---|---|
| 网表 | T0 | T0 | T0 | T0 | — | — | — |
| 划分 iPAR | T1 | T1 | T1 | T1 | — | — | — |
| 布图 iFP | T2 | T2 | T2 | T2 | — | 粗 | — |
| 布局 GP/LG/DP | T3/T4 | T3/T4(EGR) | T3/T4 | T2/T3 | T3 | T3 | 粗 |
| 时钟树 iCTS | T4 | T4 | **T5(TNS/WNS)** | T4 | T3 | T3 | 粗 |
| 全局布线 iRT-GR | T5 | **T5(overflow)** | T6 | T4 | T4 | T4 | 中 |
| 详细布线 iRT-DR | **T6** | **T6(DRC)** | T7 | T4 | T4 | T4 | **细** |
| 布线后/签核 | T6 | T6 | **T8(真 iSTA)** | **T5(真 iPA)** | **T5(真 iIR)** | **T5(真 iTH)** | 细 |

---

## 6. 关键流程时序

### 6.1 逐阶段"随时查指标"

```
每个 flow stage 收尾：
  Evaluator3D.snapshot(stage)                      # 一次算齐该 stage 可得的全部指标（AUTO 档）
    -> eval_<stage>.json  { wl, cong, timing{wns,tns}, power, ir, temp, drc, provenance }
  push 到 metrics_trend                             # 看指标随阶段收敛/劣化

优化循环内（如 iPL nesterov 第 k 步）：
  r = Evaluator3D.wirelength(kPlaceGlobal, kCoarse) # ≤50ms
  r2= Evaluator3D.congestion(kPlaceGlobal, kMedium) # EGR，每 N 步一次
  用 r/r2 调密度惩罚 / 布线友好项
```

### 6.2 与反馈回环协同（doc-40）
- iPL↔iTH：iEval.temperature(place, T3) 给 iPL 热钩子（统一功耗源）。
- iPA↔iIR↔iTH：三者 Picard 自洽在 iEval 内以 SIGNOFF 档串起（复用单例引擎，M5 P0-A）。
- iTO↔iSTA：iTO 每次修复后 `iEval.timing(post, T8)` 增量真 STA。

### 6.3 缓存失效
```
iPL 改坐标 -> Evaluator3D.invalidateFrom(kPlaceGlobal)
  失效 WL(T3+)/CONG(T3+)/TIMING(T3+)/POWER(T2+)/IR/TEMP  下游缓存
  未动的（如 partition 的 cross_die_nets）保留
```

---

## 7. 目录 / 文件组织

```
src/evaluation/
├── api/evaluator3d_api.{h,cpp}              (~200)
├── src/eval3d/
│   ├── evaluator3d.{h,cpp}                  (~350 中台)
│   ├── metric_spec.h                        (~120 数据模型)
│   ├── fidelity_router.{h,cpp}              (~260 路由表)
│   ├── metric_cache.{h,cpp}                 (~200)
│   ├── i_metric_estimator.h                 (~60)
│   └── adapters/{timing,power,ir,thermal,drc}_adapter.{h,cpp}   (各 ~120)
├── src/module/iwl3d/{wirelength_api3d,hpwl,rsmt_flute,gr_len,dr_len,inter_tier_via}.{h,cpp}  (~700)
├── src/module/icon3d/{congestion_api3d,rudy,egr3d,gr_overflow,drc_density,inter_tier_via_cong}.{h,cpp}  (~800)
├── database/eval3d_summary_db.h
└── test/  (每 estimator + 阶梯单调性 + e2e)
```
每文件 ≤ 800 行；每函数 ≤ 50 行。

---

## 8. 测试设计（L0 → L5）

### 8.1 L0 单元
| 编号 | 覆盖 | 期望 |
|---|---|---|
| TC-EVAL-L0-01 | FidelityRouter AUTO 选档 | 各 stage 选到矩阵 §5.8 的档 |
| TC-EVAL-L0-02 | 显式档不可用→降档 | WARN + used_fidelity 标注 |
| TC-EVAL-L0-03 | iWL HPWL vs 手算 | 3-pin net bbox 半周长精确 |
| TC-EVAL-L0-04 | iWL RSMT(FLUTE) ≤ HPWL·1.x | Steiner 不超 bound |
| TC-EVAL-L0-05 | iWL 层间 via 长 | Σ|Δtier|·thickness 精确 |
| TC-EVAL-L0-06 | iCon RUDY 溢出定位 | 造密集 net → 该 GCell overflow>0 |
| TC-EVAL-L0-07 | iCon 层间 via 拥塞 | 超容 HBT 座点计数正确 |
| TC-EVAL-L0-08 | Timing Elmore | 单 π 段 τ=RC 精确 |
| TC-EVAL-L0-09 | Timing 阶梯单调 | T8(真)≈基线，T3..T7 误差随档递减 |
| TC-EVAL-L0-10 | 缓存失效 | invalidateFrom(place) 清 WL/TIMING 下游 |
| TC-EVAL-L0-11 | is_2d 回退 | 单 tier → 走 2D eval，产物不变 |
| TC-EVAL-L0-12 | snapshot json schema | 全键存在 + provenance |

### 8.2–8.6
- **L1**：MetricResult 序列化往返；trend csv round-trip。
- **L2**：bp_fe 布局阶段 iEval.wirelength(T3/T4) 与 iPL 自报 HPWL 一致（±1%）。
- **L3**：bp_fe 全流程每 stage snapshot → metrics_trend 单调收敛（WNS 改善、overflow 下降）。
- **L4**：ariane 各档性能达 NFR（COARSE≤50ms/MEDIUM≤2s）。
- **L5**：sky130_gcd 2D → iEval 走现网 eval，逐字节一致。

### 8.7 golden：`docs/3d/golden/eval/bp_fe.metrics_trend.json`。

---

## 9. 性能 / 内存 / 并发
| 档 | bp_fe | ariane | 备注 |
|---|---|---|---|
| WL HPWL / RUDY | ≤30ms | ≤300ms | O(pins/nets) |
| RSMT(FLUTE) | ≤300ms | ≤3s | 可缓存 per-net |
| EGR | ≤1s | ≤8s | 概率 GR |
| 真 iSTA/iPA/iIR/iTH | 复用工具预算 | — | 不额外拷贝 |

并发：estimator 内部可并行（per-net/per-GCell/per-tier）；中台单线程调度。内存与工具共享 iDB，无副本（NFR-EVAL-04）。

---

## 10. 部署与回归
- **CMake**：`src/evaluation/CMakeLists.txt` 加 `eval3d` + `iwl3d` + `icon3d` 子目录；target `eval3d`；链接 idb、FLUTE、EGR、各工具 api。
- **TCL**：`src/interface/tcl/tcl_i3d` 加 `report_eval_3d`/`report_eval_all`/`report_metrics_trend`（doc 41）；MCP schema 自动生成。
- **CI**：`ctest -R "eval_"` 常绿；bp_fe metrics_trend 与 golden 比对（阈内）；`run_2d_regression.sh` 零回归。
- **接入 flow**（doc-40）：`FlowGraph3D` 每 stage 结束调 `Evaluator3D.snapshot(stage)`，聚合进 `signoff.json`。

---

## 11. 开放问题
- **OI-EVAL-01**：跨 tier net 的 Steiner 拆分策略（在哪个 HBT 座点断开影响长度估计）需与 iBond 协同。
- **OI-EVAL-02**：时序高阶模型(AWE) 的稳定性与 corner/热 derate 的耦合。
- **OI-EVAL-03**：iCon EGR 的 3D 化（层间 via 容量如何进 GCell edge 容量模型）。
- **OI-EVAL-04**：统一功耗源（proxy vs 真实 iPA）以让温度/IR 各档可比（承 M5 P1）。
- **OI-EVAL-05**：iWL/iCon 工具化（独立 operation 库 + 独立 TCL）v0.2 时机。
- **OI-EVAL-06**：置信度 confidence 的标定（用 bp_fe 各档 vs 真值回归拟合）。

## 附录 A. 术语
- **HPWL** 半周长线长 · **RSMT** 矩形斯坦纳最小树 · **RUDY** Rectangular Uniform wire DensitY · **EGR** Early Global Routing · **Elmore/AWE** 一阶/高阶延迟模型 · **ACE/ACO** 平均拥塞边/溢出 · **provenance** 结果来源(用了哪档) · **fidelity** 精度档。

## 附录 B. 参考
- 复用：`src/evaluation`（2D wirelength/congestion/density + union_api + init_flute/init_egr/wirelength_lut）；iSTA/iPA/iIR/iTH/iDRC 各 api。
- FLUTE（rectilinear Steiner，BSD）；RUDY(Spindler DATE'07)；Elmore delay；AWE(Pillage-Rohrer)。
- 上游：M5-fullflow-and-review（指标现状与口径问题）、doc-40（flow 每 stage snapshot）、doc-41（TCL/MCP）。
