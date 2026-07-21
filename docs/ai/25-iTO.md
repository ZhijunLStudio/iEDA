<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 25 · iTO 时序优化 · 商业对标方案 · rv2.0

> 文档号：25-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— ICC2/Innovus route_opt 收敛精度（G17：WNS δ≤5%）× in-design 调用效率（单步事务 + 快速增量）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（双对标线 + 逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**ICC2 route_opt / Innovus postroute_opt（签核收敛准确性）**；**Innovus in-design opt（优化循环效率）**；门禁：**G6 / G16 / G17**（依赖 G7 背书）
> 上游：`27-iSTA`、`28-iRCX`、`23-iCTS`　下游：`26-iRT`、`22-iPL`（`runIncrLG`）　评测：`12-evaluation`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-TO-\*
> 覆盖：`src/operation/iTO/`（fix_setup/ · fix_hold/ · fix_drv/ · timing_engine/ · module/placer/ · solver/buffer/vg/ · tcl_ito/，约 15k LOC）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | 初判：真 apply；贪心无否决；无 incr LG |
| v1.1–v1.2 | 2026-07-20 | 功能矩阵 + 简版 LLD；篇幅远薄于 24-iPL-3d，缺逐 kernel 走读 / IterParam / 状态机 / Exhibit |
| rv1.0 / v2.0 | 2026-07-20 | 大改对齐体例：对 `SetupOptimizer_gate_sizing.cpp`、`SetupOptimizer_buffers.cpp`、`SetupOptimizer_process.cpp`、`HoldOptimizer*`、`ViolationOptimizer*`、`timing_engine_inst.cpp`、`module/placer/Placer.cpp`、`iTO.cpp`、`tcl_ito.cpp` 逐文件重判。核心修订三条：(1) sizing 仍是局部贪心阈值 `eq_cell_delay < 0.5*delay`（`gate_sizing.cpp:74`），无路径级 re-time 否决——v1.2 假说坐实；(2) buffer 真 apply（`createInstance`），但 setup 主循环硬编 `perform_buf=false`（`process.cpp:60`），VG 缓冲在 AutoRun 主路径上半死；(3) buffer/resize 后无 `iPL::runIncrLG`——仅 `ito::Placer::findNearestSpace` 行内就近占位（`timing_engine_inst.cpp:47`）。另纠正：`runTO` 序为 drv→hold→setup（`iTO.cpp:37-45`），不是商业惯例的 drv→setup→hold→复扫 |
| **rv2.0** | **2026-07-21** | **大改（对照 27-iSTA-rv2.0.md 深度重写，显式拆成双对标线）**。核心修订五条：**(1)** rv1.0 三症结（T1/T2/T3）全保留，但把审计深度提升到**逐 kernel 算法 + 复杂度 + 边界**（§1.2 扩充 10→15 行，类比 27 号文档表格密度）；**(2)** 新增**商业工具核心算法对照**（§1.6）：ICC2/Innovus route_opt 的核心是「sensitivity-driven resize（灵敏度 > 阈值才 commit）+ buffering with path gain model + incremental PBA + coordinated DRV/setup/hold sequence」，iTO 缺**四项工业杠杆**：路径收益否决（re-time veto）、pass 末 incr legalize、DRV→setup→hold→setup 复扫固定序、VT-swap（廉价手柄）；**(3)** 全文按**双对标线**重组：route_opt 线 = 收敛精度栈（path veto + incr LG + 固定序 + VT → G17 WNS δ≤5%），in-design 线 = 调用效率栈（单步事务 + 快速增量 STA + 少调用次数 → 优化循环占比 ≤30%），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§4.12 模块状态一览（成熟度/复杂度/边界/复用姿势）、§5 双档配置表（effort 分级）、§8 调用方契约表、§10.3 对照实验扩充到 12 条（E-TO-01～E-TO-12）、§14 未验证/不要重走/兄弟仓库实测发现三分段；**(5)** **重新定位 iTO 的核心算法层缺口**：不是「没有 VG」（VG 真 apply 代码已在），而是「**VG/resize 的接受判据停在教科书贪心（局部延迟 < 阈值），缺商业工具的路径级增益模型（Δslack > ε 才 commit，否则 rollback）+ 固定优化序（现状 hold 在 setup 前会让 hold buffer 恶化 setup）+ 合法化闭环（现状 ito::Placer 只是行空隙搜索，不是真 LG）**」——这三项是 G17 的主杠杆。**缺省新特性关闭 → 零回归**的纪律不变。 |

---

## 1. 症结审计（深度，逐 kernel 代码走读）

对 `src/operation/iTO` 生产路径走读后的判定。**重要前提**：v1.2 摘要表方向正确，但未展开到「主循环关缓冲 / AutoRun 序颠倒 / 本地 Placer ≠ incr LG」的操作化深度；本节全部据当前主干代码重判。

### 1.1 功能形态——真 apply，但提交语义是「局部贪心 + 无事务」

- **正面（必须保留）**：resize / buffer **真改 iDB + STA**，不是 fork 只 plan。
  - gate sizing：`repowerInstance` → `invalidNetRC`（`SetupOptimizer_gate_sizing.cpp:81-85`）。
  - VG buffer：`createInstance` + `attach` + `insertBuffer` + `placeInstance`（`SetupOptimizer_buffers.cpp:88-107`）。
  - hold / DRV 同款 `createInstance` 真插入（`HoldOptimizer_buffers.cpp:95` 一带；`ViolationOptimizer_buffers.cpp:97`）。
- **头号症结 T1 · 无路径 re-time 否决**：`heuristicGateSizing` 在等价单元上扫一遍，**唯一接受条件**是局部延迟：

```74:76:iEDA/src/operation/iTO/source/module/fix_setup/SetupOptimizer_gate_sizing.cpp
    if (eq_cell_delay < 0.5 * delay) {
      find_repower_size = equiv_lib_cell;
    }
```

  选中后直接 `repowerInstance`（`:81`），**不**记录旧 master、**不**算路径 Δslack、**不** rollback。循环会覆盖到最后一个满足阈值的 cell（更大驱动优先排序在 `:50-54`），仍是局部启发式。注释掉的 `prev_delay`（`:69-70`）说明前级负载项曾考虑又关掉——**加剧**「换大门拖垮前级」风险（KH-TO-05）。
- **症结 T2 · buffer 真 apply，但无路径否决、无事务**：`implementVGSolution` 递归改拓扑（`:81-151`），选解只比 `BufferedOption` 上的 required arrival（`:61-68`），**commit 后无**「路径级 WNS/TNS 变差则回滚」。
- **症结 T2b · setup 主循环把 VG 缓冲关掉**：

```59:60:iEDA/src/operation/iTO/source/module/fix_setup/SetupOptimizer_process.cpp
    while (worst_slack < toConfig->get_setup_target_slack()) {
      optimizeSetupViolation(node, true, false);
```

  `perform_gs=true, perform_buf=false` → 主路径只跑 gate sizing + `performSplitBufferingIfNecessary`（`:199`）；`performVGBuffering` 仅在 `perform_buf` 为真或独立 `performBuffering(net)` TCL 时可达。**写好却半接线**——对照 24-iPL-3d「死 kernel」同类。
- **症结 T3 · buffer 后无 incr LG**：全树 `grep runIncrLG` 在 `iTO/` **零命中**。放置走：

```39:51:iEDA/src/operation/iTO/source/timing_engine/timing_engine_inst.cpp
void ToTimingEngine::placeInstance(int x, int y, ista::Instance* place_inst)
{
  ...
  std::pair<int, int> loc = toPlacer->findNearestSpace(master_width, x, y);
  ...
  idb_adapter->placeInstance(...);
  toPlacer->updateRow(master_width, loc.first, loc.second);
}
```

  `ito::Placer`（`module/placer/Placer.cpp:75-135`）是**自建行空隙搜索**（最多扫 40 行），**不是** `PLAPI::runIncrLG`（`PLAPI.cc:540+`）。合法化与 iPL Abacus **平行且更弱**——G16 增量闭环缺口。

### 1.2 算法成熟度——教科书贪心 / 经典 VG，缺工业杠杆

| kernel | 现状算法 | 判定 | 缺口 |
|---|---|---|---|
| `heuristicGateSizing` | 等价 cell 按 driveResistance 降序；`eq_cell_delay < 0.5*delay` 取末个满足者 | **教科书贪心**；魔法 `0.5` | 路径否决；ε 可配；前级 cap 项复活 |
| `VGBuffer` + `implementVGSolution` | van Ginneken 式 option 合并 + 真拓扑实现 | **算法正确、真 apply** | setup 主路径关闭；无否决；无 LG |
| `insertBufferDivideFanout` | 按 fanout slack 半切扇出插 buf | 启发式可用 | 同无否决/LG |
| `HoldOptimizer::process` | 违例 endpoint 循环插 delay buffer 至 target slack | **真修 hold** | 与 setup 无协同序；可恶化 setup |
| `ViolationOptimizer` | slew/cap DRV：buffer + 局部 repower；可多轮 `drv_optimize_iter_number` | **真修 DRV** | 无与 setup 的固定编排契约 |
| `EstimateParasitics` | dirty net `invalidNetRC` + incr paras/timing | 增量形态在 | 否决环需扩锥 |
| `ito::Placer` | 行空隙 nearest | **弱合法化** | 应 Composition `iPL::runIncrLG` |
| VT-swap | — | **全无**（仓库无 VT/threshold 分组逻辑） | KH-TO-02 |
| useful skew / clock retime | — | **全无**（属 CTS/商业 opt；iTO 不碰时钟树） | 见 §1.5 / KH-CTS-02 |

**四项缺失的工业杠杆**（对标 ICC2 `route_opt` / Innovus postroute opt）：① **路径收益否决（re-time veto）**；② **pass 末 incr legalize**；③ **DRV→setup→hold→setup 复扫固定序**；④ **VT-swap（廉价手柄）**。SI-aware 阻塞于 27/28。

### 1.3 边界 / 回退——有「变差停」，无「单步回滚」

- **setup 迭代守卫有**：`checkSlackDecrease`（`SetupOptimizer_process.cpp:97-118`）在 slack 变差超 2% 或连续变差超 `_number_iter_allowed_decreasing_slack`（默认 50，`ToConfig.h:163`）时跳出；WNS 达 target 也停。这是**整 endpoint 循环级**止损，**不是**单次 resize/buffer 的事务回滚。
- **hold**：插 0 buffer 则 break（`HoldOptimizer_process.cpp:131-133`）；面积/数量 cap（`:119-120`）。无 rollback。
- **TCL 假成功风险**：`CmdTOAutoRun::exec` 调 `autoRunTO` 后**无论成败 `return 1`**（`tcl_ito.cpp:46-50`）；打印 "successfully" 仅看 bool，但失败路径仍可能返回成功码——需对照 `tool_manager` 实测（标「未验证」细节，形态上违反 KH-X-04）。
- **结构化报告弱**：`Reporter` 文本 WNS/TNS + buffer/resize 计数；**无** `ito_pass_report.json`、无回滚率、无 per-move 轨迹（§11 补）。

### 1.4 跨工具协调——STA 通，LG/CTS skew 断

| 方向 | 现状 | 判定 |
|---|---|---|
| iSTA → iTO | `timing_engine` 包 `TimingEngine`；`incrUpdateTiming`（`process.cpp:94`） | **通**：引擎=iSTA |
| iTO → iDB | `TimingIDBAdapter::createInstance/repower/place` | **通**：真 apply |
| iTO → iPL incr LG | **零调用**；自建 `ito::Placer` | **断**：G16 |
| iCTS → iTO | 时钟网 DRV 跳过（`ViolationOptimizer.cpp:97`）；无 useful skew 预算接口 | **扁平**：skew 优化不在 iTO |
| iTO → iRT | 改网表后期望 re-route / ECO | 无显式 ECO 契约（Phase C / 32-iECO） |
| iRCX / SI | 无耦合 delta 进优化目标 | 阻塞于 27/28 |

### 1.5 与商业 route_opt / useful skew 的差距（假说，待 G6/G17 实测）

| 能力 | Innovus/ICC2 opt | iTO 现状 | 差距归因 |
|---|---|---|---|
| Resize + 路径敏感度 | 有；劣解拒收 | 局部 `0.5*delay` 即 commit | T1 / KH-TO-01 |
| Buffering + legalize | VG/类似 + LG | VG 真 apply；主路径关；无 incr LG | T2/T3 / KH-TO-04 |
| Hold / setup 协同 | 固定序 + 复扫 | `runTO`: drv→**hold→setup**（`iTO.cpp:37-45`） | KH-TO-03 未落地 |
| VT-swap | 常用廉价手柄 | 无 | KH-TO-02 |
| useful skew | clock_opt / useful skew 吃 setup/hold | **iTO 无**；CTS 侧见 `23-iCTS` / KH-CTS-02 | 勿在 iTO 重做 CTS |
| SI-aware opt | 耦合进 slack | 无 | 27/28 |
| 报告机读 | 强 | 文本为主 | G15 |

**三条症结（汇报用，必带 file:line）**：

| ID | 症结 | 证据 |
|---|---|---|
| T1 | sizing 贪心阈值、无路径 re-time 否决 | `SetupOptimizer_gate_sizing.cpp:74`（`eq_cell_delay < 0.5 * delay`）→ `:81` 直接 apply |
| T2 | buffer 真 apply 但无路径否决；setup 主循环关 VG | `SetupOptimizer_buffers.cpp:90` `createInstance`；`SetupOptimizer_process.cpp:60` `perform_buf=false` |
| T3 | buffer/resize 后无 incr LG | `timing_engine_inst.cpp:47` `toPlacer->findNearestSpace`；`iTO/` 无 `runIncrLG` |

---

## 2. 需求（FR / NFR / 约束）

### 2.1 FR（★ = 相对现状新增或大改）

| ID | 功能 | 现状 | rv1.0 |
|---|---|---|---|
| FR-TO-01 | Gate sizing 真 apply | ✓ `repowerInstance` | 保留 |
| FR-TO-02 | ★ 路径级 re-time 否决环（resize/buffer） | ✗ 局部 0.5 | ★核心（§4.A） |
| FR-TO-03 | VG / split buffering 真 apply | ✓ 代码在；主路径关 VG | ★ 主路径可配打开 + 否决 |
| FR-TO-04 | ★ pass 末 `iPL::runIncrLG` | ✗ 本地 Placer | ★（§4.B） |
| FR-TO-05 | Hold fix | ✓ | ★ 纳入固定序 |
| FR-TO-06 | DRV fix | ✓ | ★ 固定序最前 |
| FR-TO-07 | ★ AutoRun 序：drv→setup→hold→setup 复扫 | ✗ 现 drv→hold→setup | ★（KH-TO-03） |
| FR-TO-08 | ★ VT-swap（多 VT 库） | ✗ | P2；走同一否决环 |
| FR-TO-09 | ★ `ito_pass_report.json` | ✗ 文本 | ★ G15 |
| FR-TO-10 | SI-aware opt | ✗ | 依赖 27/28；后期 |
| FR-TO-11 | ★ vs route_opt 苹果对苹果 | 无 harness | ★ G17（§10） |
| FR-TO-12 | useful skew | ✗（正确：不在 iTO） | 接口消费 CTS 预算即可；**禁止** iTO 内平行 skew 引擎 |

### 2.2 NFR

| ID | 项 | 指标 |
|---|---|---|
| NFR-TO-01 | 否决环单步 | apply→incr STA→判据→rollback 路径可测；构造「局部优全局劣」必 rollback |
| NFR-TO-02 | 回归 | 开否决后：同设计 TNS 不恶化、hold 违例不增（相对关否决基线） |
| NFR-TO-03 | legality | buffer 批后 `runIncrLG` 成功；重叠=0 |
| NFR-TO-04 | G6 | post-route WNS ≥ −50 ps **或** 成因定位报告（主纲原文） |
| NFR-TO-05 | G17 | 双方 PT 读；WNS/TNS δ≤5% 或 ≤10 ps（取松）；hold/DRV 独立列 |
| NFR-TO-06 | 墙钟 | opt 段进 G21 分项；否决开启后回滚率告警阈值可配（默认 50%） |
| NFR-TO-07 | 零回归 | 新杠杆缺省 **关**；旧 `0.5` 可作可选预筛 hint |

### 2.3 约束（红线）

- **无否决不加新手段**（VT / SI / 更激进 buffer）——先止损再抬 QoR。
- **G7 未背书不得关闭 G17 时序行**（KH-X-01）；G6 归因优先 PT 或协议冻结引擎。
- **incr LG Composition 复用 iPL**，禁止第三套 legalizer。
- **useful skew 归属 CTS**（KH-CTS-02）；iTO 只消费 budget，不重写时钟树。
- 魔法字面量 `0.5`：**删除为硬门槛**；可降为 `local_delay_ratio_hint` 预筛，预筛通过仍必须路径否决。

---

## 3. HLD 总体架构

### 3.1 数据流

```
  iSTA (slack/path)     iRCX/SPEF (寄生)      iPL (runIncrLG)      iCTS (optional skew budget)
         │                    │                     ▲                      │
         └────────────────────┼─────────────────────┼──────────────────────┘
                              ▼                     │
        ┌─────────────────────────────────────────────────────────────┐
        │  iTO / ToApi / tcl_ito                                        │
        │                                                               │
        │  ★ AutoRun 固定序（缺省开新序，旧序可配回退）:                │
        │    optimize_drv → optimize_setup → optimize_hold → setup×2    │
        │                                                               │
        │  每 move:                                                     │
        │    MoveTxn.begin → apply(resize|buffer|vt)                    │
        │      → invalidNetRC(锥) → iSTA incrUpdateTiming               │
        │      → ★ Veto(ΔWNS/ΔTNS/path) → commit | rollback             │
        │  每 pass 末: ★ iPL.runIncrLG(changed) 失败则 rollbackPass     │
        │  Exhibit: ito_pass_report.json + CSV                          │
        └─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                         iRT / iECO（脏网 ECO）
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否方案 |
|---|---|---|
| D1 | 否决环先于 VT/SI | 无否决先堆 VT-swap（放大有害 commit） |
| D2 | incr LG 复用 `PLAPI::runIncrLG` | 继续加强 `ito::Placer` 成第二套 LG |
| D3 | AutoRun 内建 drv→setup→hold→复扫 | 继续靠用户脚本拼序（现 hold 在 setup 前） |
| D4 | `0.5` 降级为可选预筛 | 保留为唯一 accept 条件 |
| D5 | useful skew 不进 iTO 内核 | 在 iTO 内做 clock retime（与 CTS 打架） |
| D6 | 新杠杆缺省关 → 零回归 | 默认全开赌 QoR |

---

## 4. LLD · 模块分解

### 4.0 目录落点

```text
src/operation/iTO/
  source/module/
    fix_setup/
      SetupOptimizer_gate_sizing.cpp   ← 替换 :74 贪心为预筛+否决
      SetupOptimizer_buffers.cpp       ← commit 挂 MoveTxn
      SetupOptimizer_process.cpp       ← perform_buf 可配；pass 末 incr LG
    fix_hold/ ...
    fix_drv/ ...
    transaction/                       ← 【新建】MoveTxn / VetoDecision
    placer/Placer.*                    ← 降级：仅 LG 未就绪时的 fallback
  source/timing_engine/                ← incr 锥封装
  source/config/ToConfig.* + ToIterParam.*  ← ★
src/interface/tcl/tcl_ito/             ← rc 上抛
benchmark/qor/ito/                     ← ★ parity harness
```

### 4.A 移动事务 + re-time 否决（FR-TO-02）· KH-TO-01/05

**真实现状**：无 `MoveTxn`；sizing 见 `gate_sizing.cpp:74-85`；buffer 见 `buffers.cpp:88-107`。

```cpp
struct MoveRecord {
  enum Kind { kResize, kBuffer, kVtSwap } kind;
  std::string inst_name;
  std::string old_cell_master;
  std::vector<std::string> created_insts;   // buffer
  std::vector<std::string> nets_invalidated;
};

class MoveTxn {
 public:
  void begin();
  void record(const MoveRecord&);
  void commit();
  void rollback();  // 恢复 iDB master/拓扑 + RC dirty
};

struct VetoDecision {
  bool accept = false;
  double delta_wns = 0, delta_tns = 0;
  std::string reason;
};
VetoDecision evaluateAfterMove(/* 受影响锥 */);
```

```
ALG-4.A-1  每次 resize/buffer [★]
  1  txn.record(旧 cell / 拓扑快照)
  2  [已有] apply: repowerInstance / createInstance+attach
  3  invalidNetRC 扩到劈网两侧+扇出锥（加强现 :85 / :106-107）
  4  Sta::incrUpdateTiming(dirty)   // 复用 27 增量契约
  5  路径收益：优先 worst path through 移动点；备选 ΔWNS/ΔTNS
  6  accept iff (ΔTNS > eps_tns) AND (ΔWNS >= -eps_wns_guard)
  7  else txn.rollback()；rolled_back++
  8  [可选预筛] eq_cell_delay < ratio_hint * delay  （默认 ratio_hint=0.5，可关）
```

复杂度：每 move O(增量锥 STA)；边界：锥空 → 拒收；STA 未 init → 响亮失败（G14）。复用：iSTA incr；**禁止**平行第二套时序引擎。

### 4.B 增量 legalize（FR-TO-04）· KH-TO-04 · G16

**真实现状**：`ToTimingEngine::placeInstance` → `ito::Placer::findNearestSpace`（`timing_engine_inst.cpp:47`）。

```
ALG-4.B-1  pass 末 [★]
  changed ← txn.changedInsts()
  if changed.empty(): return
  ok ← ipl_api.runIncrLG(changed)   // PLAPI.cc:540
  if !ok: txn.rollbackPass(); LOG_ERROR; pass_status=FAIL
```

| 边界 | 行为 |
|---|---|
| iPL 未初始化 | 响亮失败，禁止静默跳过 |
| LG 失败 | 整 pass 回滚，不算优化成功 |
| fallback | 仅 `allow_local_placer_fallback=true` 时用旧 `ito::Placer`（默认 false） |

### 4.C Pass 编排与 setup 主路径缓冲（FR-TO-03/07）· KH-TO-03

**真实现状**：`iTO::runTO` = drv → hold → setup（`iTO.cpp:37-45`）；setup 内 `optimizeSetupViolation(..., true, false)`（`process.cpp:60`）。

```
ALG-4.C-1  CmdTOAutoRun / runTO [★可配]
  if legacy_order: drv → hold → setup          // 零回归缺省可选
  else:            drv → setup → hold → setup  // 目标默认（配置开关）
  每 pass: 否决环 + 末尾 incr LG
  emit ito_pass_report.json
```

```
ALG-4.C-2  setup 内缓冲开关 [★]
  optimizeSetupViolation(node, enable_gs, cfg.enable_vg_in_setup)
  // 缺省 enable_vg_in_setup=false → 与现状字节级行为接近
```

### 4.D VT-swap（FR-TO-08）· KH-TO-02 · P2

按 threshold 分组等价单元；setup 关键 → LVT；非关键 → HVT 回收漏电；**必须走 ALG-4.A 否决环**。无多 VT 库 → 功能 N/A，报告标明。

### 4.E DRV / Hold 模块（已有深化）

| 模块 | 现状签名 | rv1.0 |
|---|---|---|
| `ViolationOptimizer::fixViolations` | init→checkAndRepair→iter | 纳入固定序最前；计数进 JSON |
| `HoldOptimizer::optimizeHold` | process 循环插 buf | 固定序在 setup 后；监控 setup WNS 回退 |
| `SetupOptimizer::optimizeSetup` | init→find→process→report | 挂否决+LG+可配 VG |

### 4.F TCL / ToolManager（G14）

**真实现状**：`CmdTOAutoRun::exec` 成功打印后 `return 1`（`tcl_ito.cpp:46-50`）。

```
ALG-4.F-1  [★]
  ok = tm.autoRunTO(cfg)
  if !ok: return 0 / CMD_ERROR   // 禁止无条件成功
  报告 dirty / rolled_back / lg_fail 码
```

### 4.G 模块状态一览

| 模块 | 现状 | rv1.0 动作 | 复用姿势 |
|---|---|---|---|
| gate_sizing | 贪心 0.5 | ★否决环替换硬门槛 | 自建深化 |
| VGBuffer | 成熟真 apply | ★主路径可配 + 否决 | 已有 |
| split buffer | 启发式 | ★挂否决 | 已有 |
| HoldOptimizer | 真修 | ★固定序 | 已有 |
| ViolationOptimizer | 真修 | ★固定序最前 | 已有 |
| ito::Placer | 弱 LG | ★降级 fallback | 禁止平行加强 |
| iPL runIncrLG | API 在 | ★ Composition | iPL |
| MoveTxn | 无 | ★新建 | 自建 |
| VT-swap | 无 | ★ P2 | 自建 |
| TCL rc | 弱 | ★上抛 | 已有 |
| Exhibit | 文本 | ★ JSON/CSV | 新增 |

---

## 5. 配置 / IterParam / 多轮渐进

| 项 | 缺省（零回归） | 目标生产 | 说明 |
|---|---|---|---|
| `enable_path_veto` | false | true | FR-TO-02 |
| `local_delay_ratio_hint` | 0.5 | 0.5 或 off | 仅预筛 |
| `eps_tns` / `eps_wns_guard` | — | 可配 | 否决判据 |
| `enable_vg_in_setup` | false | true（effort 中以上） | 打开 `process.cpp:60` 第二参 |
| `autorun_order` | `legacy` (drv-hold-setup) | `kh` (drv-setup-hold-setup) | FR-TO-07 |
| `enable_incr_lg` | false | true | FR-TO-04 |
| `allow_local_placer_fallback` | true（现状行为） | false | G16 |
| `enable_vt_swap` | false | false→P2 true | FR-TO-08 |
| `optimize_endpoints_percent` | 1.0（`ToConfig.h:166`） | 扫描 | KH-X-06 |
| `setup/hold_target_slack` | 0.0 | 设计相关 | 已有 |
| `drv_optimize_iter_number` | 1 | ≥2 可选 | 已有 |
| `rollback_rate_warn` | 0.5 | 0.5 | 报告告警 |

**多轮 effort（示意）**：

| 轮 | veto | vg_in_setup | incr_lg | vt | 意图 |
|---|---|---|---|---|---|
| R0 | off | off | off | off | ≈现状基线 |
| R1 | on | off | on | off | 止损 + 合法 |
| R2 | on | on | on | off | QoR |
| R3 | on | on | on | on | 打平爬坡 |

---

## 6. Cost / 指标分解

| 维 | 符号 | 记录点 | 用途 |
|---|---|---|---|
| Setup WNS/TNS | W_s / T_s | pass 前/后 | G6/G17 |
| Hold WNS / #vio | W_h / H | pass 前/后 | G6 |
| DRV #slew/#cap | D | DRV pass | G6 |
| Accepted / Rolled_back | A / R | 每 move | 否决健康度 |
| Area Δ / #buffer / #resize | ΔA / B / S | pass | 面积代价 |
| LG ok / unplaced | L | pass 末 | G16 |
| Opt wall time | t | phase | G21 |
| 回滚率 | R/(A+R) | pass | 告警 |

**禁止**用「插入了多少 buffer」单一标量宣称成功而掩盖 WNS 恶化或 LG 失败。

---

## 7. 状态机 / 命令语义

```
init(config) → [optimize_drv] → [optimize_setup] → [optimize_hold] → [optimize_setup?]
             → emit report → (optional) write def
```

| 命令 | 成功 | 失败 rc |
|---|---|---|
| `run_to_drv` | DRV 收敛或达 iter 上限且报告诚实 | STA 未就绪 / LG fail（若启用） |
| `run_to_setup` | 达 target 或达 endpoint 上限；否决统计写出 | 否决基础设施失败；LG fail |
| `run_to_hold` | hold≥target 或可解释残留 | 面积 cap 触发须标明 |
| `run_to_buffering` | 单网 VG 成功 | net 不存在 |
| `run_to` / AutoRun | 全 pass 按序成功 | 任一 pass FAIL → 非零；**禁止**恒 `return 1` |

脏状态：rollback 后 iDB 应与 move 前一致（T-A2）；失败 pass 须 `dirty=1` 进 JSON。

---

## 8. 跨工具 Cascade

| 信号 | 方向 | 契约 |
|---|---|---|
| slack / path / incr timing | iSTA ↔ iTO | 增量锥；单位 ns 一致 |
| dirty nets / SPEF | iRCX → iTO | 缺寄生则 G6 归因「缺寄生」 |
| `inst_name_list` | iTO → iPL | `runIncrLG`；失败上抛 |
| skew budget（可选） | iCTS → iTO | 只读；不改时钟树 |
| 改后网表 | iTO → iRT/iECO | ECO route 入口（32/26） |
| `ito_pass_report.json` | iTO → eval | `12-evaluation` G15 |

---

## 9. 商业 Know-how 映射

| KH-ID | 要点 | 本工具 § |
|---|---|---|
| KH-TO-01 | 路径收益否决 | §4.A / FR-TO-02 |
| KH-TO-02 | VT-swap 廉价手柄 | §4.D |
| KH-TO-03 | DRV→setup→hold→复扫 | §4.C / FR-TO-07 |
| KH-TO-04 | 缓冲树 + 合法化 | §4.B + VG |
| KH-TO-05 | sizing↔负载闭环 | §4.A（前级锥） |
| KH-CTS-02 | useful skew | **不**在 iTO 实现；§2.3 / §1.5 |
| KH-X-01 | 签核真值先于打平 | G7→G17 |
| KH-X-04 | 响亮失败 | §4.F TCL rc |
| KH-X-05 | 多目标分层 | DRV/合法 → WNS → 面积 → 墙钟 |
| KH-X-06 | 只修 worst endpoints % | `optimize_endpoints_percent` |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板（vs ICC2 `route_opt` / Innovus postroute opt）

| 指标 | iTO 后 | 商业 opt 后 | Δ | 门槛 |
|---|---|---|---|---|
| WNS（**双方 PT**） | | | ps/% | G6 ≥−50ps 或归因；G17 ≤5% 或 ≤10ps |
| TNS | | | % | ≤5% |
| hold 违例 | | | 数 | 0 或可解释 |
| DRV | | | 数 | 0 |
| 面积增量 | | | % | 记录（独立列） |
| buffer / resize 数 | | | — | 记录 |
| 回滚率 | | — | — | 告警 |
| opt 墙钟 | | | × | G21 分项 |
| legality（重叠） | | 0 | — | G16 |

### 10.2 对照实验（能杀死假说）

| ID | 假说 | 方法 | 杀死条件 |
|---|---|---|---|
| E-TO-01 | 贪心有害 | veto off vs on | 开否决后 WNS **不优于**关否决且无止损价值 |
| E-TO-02 | 局部优全局劣 | 构造换大门拖垮前级 | 必须 rollback；若 accept 则否决坏 |
| E-TO-03 | incr LG 必要 | buffer 后仅本地 Placer vs runIncrLG | LG 路径 legality FAIL 或布线 DRC 显著差 |
| E-TO-04 | 回滚一致性 | 状态逐位恢复 | iDB/RC/slack 不一致 |
| E-TO-05 | 固定序优于 legacy | kh 序 vs drv-hold-setup | hold 修完 setup 崩且无复扫收益 |
| E-TO-06 | parity | 同输入 vs 商业 route_opt | 看板；强项不掩弱项 |
| E-TO-07 | useful skew 归因 | CTS 开/关 skew 预算 | 若 iTO 内做 skew 才「赢」→ 归因错误，应退回 CTS |

### 10.3 演进

| 阶段 | 目标 | 退出门禁 |
|---|---|---|
| **M0 先量** | aes 等基线 WNS/TNS/hold/DRV JSON；商业同脚本点 | 可复现基线 |
| **M1 可信** | MoveTxn + 路径否决；TCL rc；零回归开关 | 不恶化（NFR-TO-02）；G14 |
| **M2 主算法** | incr LG + 固定序 + VG 主路径可配 | **G6** 路径；**G16** 增量 |
| **M3 打平** | VT-swap；QoR 爬坡 | G6 抬升 |
| **M4 纵深** | SI-aware（依赖 27/28）+ vs route_opt δ | **G17** |

```text
基线（真 apply + 贪心 0.5）
 → 否决环（止损，G6 前提）
 → incr LG（可布线交付，G16）
 → 固定序 + VG 打开（QoR）
 → VT（廉价）
 → SI + 商业 δ≤5%（G17）
```

---

## 11. Exhibit

| 档 | 产物 | 内容 |
|---|---|---|
| CSV | `ito_moves.csv` | move_id,kind,accept,delta_wns,delta_tns,reason,t_ms |
| JSON | `ito_pass_report.json` | 见下 schema |
| TXT | `ito_report.txt` | 现有 Reporter 人读 |
| Plot | 可选 | WNS/TNS 随 pass；回滚率 |

```json
{
  "design": "aes",
  "autorun_order": "kh",
  "passes": [
    {
      "name": "setup",
      "accepted": 12,
      "rolled_back": 5,
      "wns_before": -0.20,
      "wns_after": -0.08,
      "tns_before": -5.0,
      "tns_after": -1.2,
      "hold_vios_after": 0,
      "drv_after": 0,
      "area_delta": 120.0,
      "buffer_inserted": 3,
      "lg_ok": true
    }
  ],
  "status": "OK|VETO_INFRA_FAIL|LG_FAIL|DRV_RESIDUAL|HOLD_RESIDUAL"
}
```

回滚率 > `rollback_rate_warn` → `LOG_WARNING`（增益模型失真）。

---

## 12. 测试计划

| 级 | 内容 |
|---|---|
| L0 gtest | MoveTxn rollback 一致性；veto 判据边界；`0.5` 预筛可关；mock STA Δslack |
| L1 集成 | TCL AutoRun legacy/kh 两序；enable_incr_lg 开时 LG fail→非零 rc；VG 开关 |
| L4 基准 | 冻结设计套件：iTO 前后 WNS/TNS/hold/DRV；与商业 route_opt 同报告点 |
| L5 红线 | 无否决时禁止默认开 VT；假成功（TCL 恒 1）回归；零回归（全新杠杆 off ≈ 旧行为） |

专项：T-A1 路径否决；T-A2 回滚；T-B1 incr LG；T-C1 VT；T-D1 固定序；E-TO-*（§10.2）。

---

## 13. 里程碑（按周，示意）

| 周 | 交付 | 验收 |
|---|---|---|
| W1 | M0 harness + 基线 JSON；确认 T1/T2/T3 file:line | 基线可复现 |
| W2 | MoveTxn + rollback（尚未改 accept 策略） | T-A2 |
| W3 | 路径否决替换硬门槛；hint 可配 | T-A1；NFR-TO-02 |
| W4 | pass 末 `runIncrLG`；TCL rc | T-B1；G16 路径 |
| W5 | AutoRun kh 序 + 报告 JSON；VG 主路径开关 | T-D1；G15 |
| W6 | G6 达标或归因报告 | **G6** |
| W7+ | VT-swap；parity vs route_opt | G17 爬坡 |

对齐主纲 **Phase B3**（否决环 + iPL incr LG 之后）。

---

## 14. 未验证 / 负面结论 / 不要重走

**未验证**：
- 贪心 `0.5` 在 aes 等设计上是否**实锤**有害（E-TO-01 待跑）。
- `ito::Placer` 与 post-route DRC 的相关强度（E-TO-03）。
- TCL/`tool_manager` 失败时是否总能非零（需实测）。
- 主流程脚本是否默认调用 iTO；JSON 未知键容忍度。
- hold 修在 setup 前是否系统性恶化 setup（E-TO-05）。

**负面 / 不要重走**：
- **不要**无否决先上 VT-swap 或更激进 buffer。
- **不要**把 `ito::Placer` 扩成第二套 Abacus。
- **不要**在 iTO 内实现 useful skew / clock retime（应 CTS；E-TO-07）。
- **不要**用 iSTA 自评关闭 G17 时序行（须 PT 读双方或 G7 协议）。
- **不要**用「插入 buffer 数」代替 WNS/TNS 门禁。
- **不要**恢复「文档写 kh 序、代码仍 hold→setup」的长期漂移——序必须以配置+测试锁死。

---

## 附录 A · 术语

| 术语 | 含义 |
|---|---|
| re-time 否决 / path veto | apply 后按路径/WNS/TNS 收益决定 commit 或 rollback |
| VG | van Ginneken 缓冲树求解（`VGBuffer`） |
| incr LG | `iPL::runIncrLG` 增量合法化 |
| route_opt / postroute opt | ICC2 / Innovus 时序优化商业对标 |
| useful skew | 用时钟偏斜搬 setup/hold 预算（CTS，非 iTO） |
| legacy_order | 现状 AutoRun：drv→hold→setup |

## 附录 B · 决策记录

| ID | 决策 | 被否 | 依据 |
|---|---|---|---|
| E-1 | 否决先于新手段 | 先 VT/SI | KH-TO-01；§3 D1 |
| E-2 | LG Composition iPL | 加强 ito::Placer | KH-TO-04；G16 |
| E-3 | 固定序可配，目标 kh | 永久脚本拼序 | KH-TO-03 |
| E-4 | useful skew 归 CTS | iTO 内 skew | KH-CTS-02 |
| E-5 | 新杠杆缺省关 | 默认全开 | 零回归 |
| E-6 | G17 双方 PT | iSTA 自评打平 | 主纲 §1bis |

## 附录 C · Checklist（PR 合并前）

- [ ] §1 三条症结仍与代码 file:line 一致（或已关闭并改审计）
- [ ] 否决 / LG / 序开关缺省不破坏旧设计数值路径
- [ ] `ito_pass_report.json` 写出；回滚率可见
- [ ] TCL 失败非零 rc
- [ ] L0/L1 相关单测绿；E-TO-02 构造用例在
- [ ] 未声称 G17 除非协议文件 + PT 数字齐全
