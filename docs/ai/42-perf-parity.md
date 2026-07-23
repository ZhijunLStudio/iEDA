<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 42 · 性能对标 Perf Parity · 商业对标优化方案 · rv2.1

> 文档号：42-rv2.1　　版本：rv2.1（测量纠偏）　　里程碑：**可复现剖面 → 并排比值 → 热点优化（质量优先）→ G21/G20**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`、`28-iRCX-rv2.0.md`（逐 stage 走读 + 双看板 + 诚实归因）
> 商业金标：**Innovus / Fusion Compiler（日常性能基准）**；**Calibre / PrimeTime（签核性能基准）**；门禁：**G21 / G20**（辅 G17）
> 依赖：`12-evaluation` protocol/schema；`40-platform` stage 边界计时钩子
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-EV-01、KH-X-05/08
> 覆盖：Tier 4 平台层性能对标（StageTimer 钩子、profile.jsonl schema、compare 脚本、G21/G20 门禁）
> 纪律：**质量优先于速度**（KH-X-05）；无 QoR A/B 的「加速」不合入；共享机数字不进 G21；断言带 `file:line`；未实测写「未验证」。
> 技术细则：测量协议、复杂度/数据局部性/增量/并行优化顺序见 `04-ppa-technical-review-and-optimization-rv1.md` §2.6/§5。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 采集算法摘要（~42 行） |
| rv1.0 / v2.0 | 2026-07-20 | **升体例**：补审计/FR/HLD/LLD/看板 M0–M4/测试/未验证；明确与 12 的 `run_perf_compare.sh` 共管。 |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0.md / 28-iRCX-rv2.0.md 深度与签核工具要求重写）**。核心修订五条：**(1)** rv1.0 把 perf-parity 当成「缺计时钩子和脚本」来审——**实际上头号结构症结是性能差距的不可见与不可归因**：无逐 stage 的 vs 商业工具墙钟对比数据（哪些 stage 快、哪些慢、慢在哪个子阶段）、无热点定位机制（火焰图/profiler 报告缺失）、无优化前后 A/B 对比门禁（加速 PR 可能牺牲 QoR 而无检测）——现状是**有想法无数据**；**(2)** 新增 **§1.5 性能栈逐项**（对商业工具各 stage 的性能差距清单，G21/G20 核心证据）：逐 stage（iFP/iPL/iCTS/iTO/iRT/iSTA/iRCX/iDRC/iPW）列出 iEDA vs 商业工具的墙钟基线、已有能力、差距、瓶颈——对标目标是「日常设计端到端 ≤1.5× 商业主对标方」（G21）与「大设计 ≤3× + 归因」（G20）；**(3)** 全文按**双看板**重组：G21 日常性能看板（5 套 daily e2e ≤1.5×、≥2/5 ≤1.0×、分项剖面）、G20 大设计看板（scale ≤3× + 瓶颈定位、火焰图/profiler 报告），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§4.12 模块状态一览（StageTimer、profile schema、compare 脚本成熟度/边界/复用姿势）、§10.3 对照实验（E-PERF-01～05 可杀假说）、§14 未验证/不要重走三分；**(5)** 强化**质量优先纪律**（KH-X-05）：所有加速 PR 必须附 QoR A/B 对比数据（G17 指标不回归）、禁止「关检查换速度」、禁止共享机数字进 G21——性能对标的前提是**功能正确性不受损**。**缺省配置零回归**纪律不变。 |
| **rv2.1** | **2026-07-23** | 修正测量设计：`VmPeak` 不能归因嵌套 stage，改由独立进程/cgroup 采 peak；构建身份改 SHA-256；2/5 明确指设计而非 stage；A/B 使用预构建 artifact 或独立 worktree，禁止脚本切换/清理当前工作区；重复次数改为至少 5 次并用 median/MAD。 |

---

## 1. 症结审计（逐 stage / 平台层走读）

对 iEDA 全流程（iFP/iPL/iCTS/iTO/iRT/iSTA/iRCX/iDRC/iPW）性能现状的审计。**前提**：rv2.0 不推翻 rv1.0 的核心结论（无统一计时钩、无 profile schema、无商业对比数据），但把审计深度对齐 27/28 号文档：逐 stage 给「现状能力 / 已有优化 / 差距 / 瓶颈」四列，并新增 rv1.0 没有的 **§1.5 性能栈逐项**（对商业工具各 stage 的性能差距清单，G21/G20 核心证据）。

### 1.1 功能形态——计时基础设施缺、性能数据盲

| 能力 | 现状 | 证据 | 判定 |
|---|---|---|---|
| 各工具内部 Monitor/LOG | ⚠️ 散落 | iPL/iCTS/iRT 各有自己的时间戳打印；格式不统一 | **非 G21 真源**（不可机读、不可横向对比） |
| 统一 stage 计时钩子 | ✗ | 无 `StageTimer` 公共类（`40-platform` 或 `src/utility/` 均无） | **P0 缺口（G21 前置）** |
| `profile.jsonl` schema | ✗ | 无 `benchmark/qor/profile_schema.json` | **P0 缺口（G21 分项无处安放）** |
| `run_perf_compare.sh` | ✗ | `benchmark/qor/` 无此脚本（rv1.0 判定：**文档设想，未落地**） | **P0 缺口（vs 商业工具对比不可执行）** |
| 独占机/绑核协议 | ✗ | 无 `parity_protocol.perf`（threads/pin_cores/exclusive_host） | **P0 缺口（共享机数字不可进 G21）** |
| OpenMP 并行已用 | ✓ 部分 | iPL/iSTA/iRCX/iDRC 有 `#pragma omp parallel` | **已有**（但未量化加速比、未测可扩展性） |
| 优化 A/B 门禁 | ✗ | 无 `run_qor_ab.sh`；PR 无强制 A/B 数据附带 | **P1 缺口（加速 PR 可能牺牲 QoR）** |
| 热点定位机制 | ✗ | 无火焰图（`perf` / `gprof` / `vtune`）、无 profiler 报告 | **P1 缺口（G20 瓶颈归因不可执行）** |
| 商业工具同机对比 | ✗ 未验证 | 无 Innovus / StarRC 同机跑日志对比（同 threads、同机器） | **P0 缺口（vs 商业工具基线不存在）** |
| RSS 监控 | ⚠️ 部分 | 部分工具有峰值内存打印；无统一 `/proc/self/status` 采集 | **半成品**（G21 需要 RSS 分项） |
| CI 性能门禁开关 | ✗ | 无 `g21_enable=false`（M3 前观测档） | **未落地** |

**§1.1 结论**：计时基础设施**缺失**（无统一钩子、无 schema、无对比脚本）、性能数据**盲**（vs 商业工具的逐 stage 墙钟基线不存在）、优化**无门禁**（A/B 对比不强制 → 加速 PR 可能牺牲 QoR）、瓶颈**不可归因**（无火焰图/profiler）。

### 1.2 已有优化点——OpenMP 已部分启用，可扩展性未测

| stage | 已有并行 | 证据 | 判定 | 缺口 |
|---|---|---|---|---|
| iPL | ✓ WL 计算、部分迭代 | `iPL/api/` OpenMP | **中等成熟度** | 可扩展性未测（1→4→8→16 threads 加速比曲线） |
| iSTA | ✓ BFS 传播按 level 并行 | `iSTA/source/module/sta/StaDataPropagationBFS.cc:164+` OpenMP | **成熟向** | 27 号文档已审计（NFR-STA-07 G21） |
| iRCX | ✓ 边级 C/R 计算 | `iRCX/source/module/calculate/` OpenMP | **可用** | 28 号文档已审计（NFR-RCX-07 G21） |
| iDRC | ✓ cluster 级并行 | `iDRC/.../RuleValidator.cpp:356` OpenMP | **可用** | 30 号文档已审计（NFR-DRC-02） |
| iRT | ⚠️ Rust 侧并行 | Rayon（Rust 并行库） | **未审计** | Rust 侧性能栈与 C++ 侧隔离、跨语言 profiling 难 |
| iCTS | ⚠️ 部分 | `iCTS/source/` 部分循环 OpenMP | **未审计** | 时钟树构建算法复杂度、并行粒度未量化 |
| iTO | ✗ 串行 | `iTO/source/` 无 OpenMP（逐 cell 优化本质串行） | **合理**（算法特性，非瓶颈） | 27 号文档 NFR-STA-10 in-design 看板（iTO 全流程 STA 占比 ≤30%） |
| iFP/iPDN/iPW | ✗ 未审计 | — | **数据盲** | 端到端占比未知（需 M0 剖面数据） |

**§1.2 结论**：OpenMP **已部分启用**（iPL/iSTA/iRCX/iDRC 有并行），但**可扩展性未测**（加速比曲线缺失）、**热点未定位**（哪些 stage 是端到端瓶颈不清楚）、**Rust 侧隔离**（iRT 性能栈与 C++ 侧脱钩）。

### 1.3 边界 / 质量优先 / 门禁纪律

- **质量优先红线**（KH-X-05）：G21 不得在 G17 红时强行转绿——加速 PR 必须附 QoR A/B 对比数据（WNS/TNS/违例数/面积/总线长 不回归）。  
- **共享机数字不进 G21**：独占机 + 绑核（`parity_protocol.perf` 强制）；CI 观测档（`g21_enable=false`，M3 前）。  
- **热点驱动优化**：按占比 × 可达加速比 × 工程成本估算 e2e 收益；阈值由 backlog 决策，不固定为 30%（禁止无数据全面并行化）。
- **禁区**：关 DRC/STA 换速度、降 effort 无 A/B、盲目 `-march=native`（COMPATIBILITY_MODE 影响可移植性）。  
- **跨工具计时钩挂点**：FlowScheduler stage（`40-platform`）或 TCL wrapper（`tcl_<tool>/tcl_register_<tool>.h` 命令层）。

### 1.4 跨工具协调——各工具独立 LOG，无统一出口

| 方向 | 现状 | 判定 |
|---|---|---|
| 各工具 → perf 数据 | 各自打印；格式不统一（有的 ms、有的 s、有的无单位） | **断**（不可机读） |
| perf → `profile.jsonl` | 无统一 schema | **断**（G21 分项无处安放） |
| perf → `12-evaluation` | 无对接（evaluation 只管 QoR，不管性能） | **半断**（需新增 `qor_perf_joint.json`） |
| perf → G21 CI | 无门禁开关 | **断**（M3 前观测） |
| 商业工具 → iEDA | 无同机对比日志 | **断**（vs 商业工具基线不存在） |
| 优化 PR → A/B 数据 | 无强制 | **断**（质量优先无保障） |

**§1.4 结论**：各工具**独立 LOG**，无统一出口（`profile.jsonl` 缺失）、无 vs 商业工具对比数据（baseline 不存在）、无优化 A/B 门禁（质量风险）。

### 1.5 ★性能栈逐项——对商业工具各 stage 的性能差距清单（G21/G20 核心证据）

商业主对标方（Innovus / Fusion Compiler）的端到端墙钟来自逐 stage 累加。逐项核实 iEDA vs 商业工具的差距（✓=已有数据，⚠️=部分，✗=盲）：

| # | stage | iEDA 现状能力 | 商业工具基线（未测前空） | 差距/瓶颈 | 对 e2e 的影响 | P |
|---|---|---|---|---|---|---|
| 1 | **iFP** | FloorPlan（iDB 初始化 + 宏布局） | — | **数据盲**（e2e 占比未知） | iFP 若快 = e2e 基准好；若慢 = iDB 初始化瓶颈 | P1 |
| 2 | **iPL-GP** | 全局布局（QP/SA/分析式） | — | **数据盲**；已知 ASLR 不可复现（memory/ieda3d-ipl-aslr-nondeterminism.md） | GP 若慢 ≥2× = 二次规划求解器瓶颈 or 线网模型瓶颈 | **P0**（G21 主战场） |
| 3 | **iPL-DP** | 详细布局（Abacus/tetris） | — | **数据盲** | DP 若慢 = legalize 算法复杂度 or 数据结构（全局 vs 窗口） | P1 |
| 4 | **iCTS** | 时钟树综合 | — | **数据盲**；算法复杂度未量化（TierTree/HeteroSkew/...） | CTS 占比通常 <10% e2e（先进设计 mesh 可能 ↑） | P1 |
| 5 | **iTO** | 时序优化（fix_drv/fix_setup/fix_hold） | — | **数据盲**；27 号文档 NFR-STA-10 目标「iTO 全流程 STA 占比 ≤30%」 | iTO 若慢 = STA 调用次数 × 单次墙钟（27 §1.4：10:1 全量批处理 → 增量） | **P0**（G21 主战场） |
| 6 | **iRT-GR** | 全局布线 | — | **数据盲**；Rust 实现（rayon 并行） | GR 若慢 = Steiner 树构建 or 拥塞评估 or maze routing | P0 |
| 7 | **iRT-TR** | 轨道分配 | — | **数据盲** | TR 占比通常 <5% e2e | P1 |
| 8 | **iRT-DR** | 详细布线 | — | **数据盲**；memory/ieda3d-router-four-bugs.md 记录「hang 误判」（实际是慢） | DR 若慢 ≥3× = **G21 主瓶颈候选**（商业工具 DR 高度并行） | **P0**（G20 必审） |
| 9 | **iSTA** | 静态时序分析 | — | **数据盲**；27 号文档 NFR-STA-07「日常设计 ≤1.5× PT」 | STA 被 iTO 反复调用（§5），单次若慢 → iTO 慢 | **P0**（27 已立项） |
| 10 | **iRCX** | 寄生提取 | — | **数据盲**；28 号文档 NFR-RCX-07「≤1.5× StarRC 起步观测」 | RCX 若慢 = 拓扑构建 or 邻居查询（R-tree）or cap 查表 | P1（28 已立项） |
| 11 | **iDRC** | 设计规则检查 | — | **数据盲**；30 号文档 NFR-DRC-02「in-design 墙钟 ≪ Calibre」 | DRC 若慢 = 几何谓词 or cluster 构建 or OpenMP 效率 | P2（30 已立项；in-design 定位） |
| 12 | **iPW/iPDN** | 功耗/IR 分析 | — | **数据盲** | iPW 若慢 = 电流求解器（迭代法 vs 直接法）or CUDA IR | P2 |
| 13 | **e2e** | 端到端（上述全部） | — | **G21 目标**：日常 5 个设计均≤1.5×，且≥2/5 个设计≤1.0× | **无基线 = G21 不可证** | **P0** |
| 14 | **大设计 scale** | 同上，设计规模 ≥10× | — | **G20 目标**：≤3× + 瓶颈归因（火焰图/profiler） | 算法复杂度非线性 or 数据结构不 scale | **P0**（G20） |
| 15 | **并行效率** | cpu_time / (wall_time × threads) | — | **数据盲**；理想=1.0，实际<0.7 需归因（Amdahl 定律 or 锁竞争） | 加核不加速 = 并行瓶颈 | P1 |

**§1.5 结论**：性能差距是**全盲状态**——15 项全部「数据盲」（无 vs 商业工具的逐 stage 墙钟对比）。**G21/G20 不可证**的根源：无基线数据（哪些 stage 快/慢、慢多少、瓶颈在哪）→ 优化无靶点（盲目加速可能优化非瓶颈、浪费工程量）→ 门禁无依据（无法判定是否达标）。rv1.0 只覆盖了「无计时钩」的基础设施缺失，rv2.0 新增**性能栈全盲**的结构性症结。

### 1.6 死配置 / 死接线 / 假成功点名

1. **各工具独立时间戳打印**——无统一 `StageTimer` 类，格式不统一（ms/s/无单位）。  
2. **`run_perf_compare.sh` 未落地**——rv1.0 判定「文档设想，未落地」。  
3. **`parity_protocol.perf` 不存在**——独占机/绑核协议无配置文件。  
4. **`profile.jsonl` schema 缺失**——G21 分项数据无处安放（JSON 字段未定义）。  
5. **优化 A/B 门禁不存在**——PR 无强制 QoR 对比数据附带。  
6. **火焰图/profiler 报告零产出**——G20 瓶颈归因工具链未建立。  
7. **商业工具同机对比日志缺失**——vs Innovus / StarRC 的基线不存在。  
8. **COMPATIBILITY_MODE=ON 默认**——`-march=native` 关闭（影响性能上限，但保可移植性）。  
9. **CI 性能门禁开关缺失**——`g21_enable=false`（M3 前观测档）未实现。  
10. **iRT Rust 侧 profiling 断**——`perf` / `vtune` 跨语言 profiling 未验证。

### 1.7 症结优先级表（§1 结论摘要）

| ID | 症结 | 证据 | 对标线 | P |
|---|---|---|---|---|
| **S1** | **无统一 stage 计时钩子** | 无 `StageTimer` 公共类 | 双 | **P0**（G21 前置） |
| **S2** | **无 `profile.jsonl` schema** | 无 schema 定义 | G21 | **P0**（分项无处安放） |
| **S3** | **vs 商业工具基线全盲（15/15 数据盲）** | §1.5 表；无同机对比日志 | 双 | **P0**（G21/G20 不可证） |
| **S4** | **无 `run_perf_compare.sh`** | `benchmark/qor/` 无脚本 | 双 | **P0**（对比不可执行） |
| **S5** | **无独占机/绑核协议** | 无 `parity_protocol.perf` | G21 | **P0**（共享机数字不可信） |
| **S6** | **无优化 A/B 门禁** | PR 无强制 QoR 对比 | G17 | **P0**（质量优先无保障） |
| S7 | 无火焰图/profiler | G20 瓶颈归因工具链缺 | G20 | P1 |
| S8 | 并行可扩展性未测 | 加速比曲线缺失 | 双 | P1 |
| S9 | iRT Rust 侧 profiling 断 | 跨语言工具链未验证 | G21 | P1 |
| S10 | COMPATIBILITY_MODE 性能上限 | `-march=native` 关闭 | 双 | P2（可选优化） |

**§1 最关键 6 条**：S1（无计时钩）、S2（无 schema）、S3（无基线）、S4（无对比脚本）、S5（无独占机协议）、S6（无 A/B 门禁）。

---

## 2. 需求 FR / NFR

| ID | 需求 | P |
|---|---|---|
| FR-PERF-01 | ★ 统一 stage 计时钩子（wall/cpu/rss） | P0 |
| FR-PERF-02 | ★ profile.jsonl schema + 进 12 目录 | P0 |
| FR-PERF-03 | ★ compare 脚本（ieda/commercial ratio） | P0 |
| FR-PERF-04 | ★ 独占机协议写入 parity_protocol | P0 |
| FR-PERF-05 | ★ 优化 A/B 门禁（算法不变默认；QoR 不回归） | P0 |
| FR-PERF-06 | ★ 热点定位（火焰图/profiler 报告） | P1 |
| FR-PERF-07 | ★ 并行可扩展性测试（加速比曲线） | P1 |
| FR-PERF-08 | ★ 商业工具同机对比（vs 商业工具基线） | P0 |
| NFR-PERF-01 | **G21 端到端**：daily 5 个设计 e2e 均≤1.5×，且≥2/5 个设计≤1.0× | G21 |
| NFR-PERF-02 | **G21 分项**：逐 stage 写入 profile.jsonl | G21 |
| NFR-PERF-03 | **G20 大设计**：scale ≤3× + 瓶颈定位 | G20 |
| NFR-PERF-04 | 复跑波动 ≤8% | KH-X-08 |
| NFR-PERF-05 | 优化 A/B：QoR Δ≤1% | G17 |
| NFR-PERF-06 | 并行效率 ≥0.6 | 双 |

### 2.3 红线约束

- **质量优先于速度**（KH-X-05）：G21 不得在 G17 红时强行转绿——加速 PR 必须附 QoR A/B 对比数据（WNS/TNS/违例数/面积/总线长 不回归）。
- **共享机数字不进 G21**：独占机 + 绑核（`parity_protocol.perf` 强制）；CI 观测档（`g21_enable=false`，M3 前）。
- **禁止「关检查换速度」**：降 DRC/STA effort、关 eco_route、跳过 legalization 等牺牲 QoR 的加速 **一律拒绝**。
- **热点驱动优化**：有 stage/substage 占比和 Amdahl 上限，且预计 e2e 收益覆盖工程成本；禁止盲目优化非瓶颈。
- **无基线不优化**：vs 商业工具的逐 stage 墙钟对比数据（§1.5）是优化靶点的前提；M0 前禁止提加速 PR。

---

## 3. HLD

### 3.1 数据流——双看板（G21 日常 × G20 大设计）

```text
                    独占机 + 绑核 + threads∈protocol
                                │
      ┌─────────────────────────┼─────────────────────────┐
      │ G21 日常性能线           │        G20 大设计线      │
      ▼                         ▼                         ▼
  StageTimer 包裹          StageTimer 包裹           + 火焰图/profiler
  每 stage TCL 命令        每 stage 同左             perf record / vtune
      │                         │                         │
for design in daily[5]:     for design in scale[1-3]:    │
  for stage in [fp,place,cts,pdn,route,rcx,sta,to,drc]:  │
    start_timer(stage)                                    │
    run_stage()                                           │
    stop_timer() → emit profile.jsonl                     │
      {design, stage, repeat, wall_s, user/sys_cpu_s,    │
       threads, host, binary_sha256, manifest_sha256}     │
      │                         │                         │
      ▼                         ▼                         ▼
  run_perf_compare.sh:     run_perf_compare.sh:     analyze_hotspot.sh:
  - iEDA profile.jsonl     - 同左（大设计）          - perf report top-5
  - 商业工具 log 解析      - 算法复杂度验证          - 火焰图 SVG
  - 逐 stage ratio        - memory scaling          - 瓶颈函数定位
  → perf_align.json       → scale_report.json       → hotspot_report.json
      │                         │                         │
      ▼                         ▼                         ▼
  G21 看板（§10.1）        G20 看板（§10.2）         优化 backlog（M2）
  - e2e ≤1.5×              - e2e ≤3×                 - 热点/Amdahl/ROI 驱动
  - ≥2/5 ≤1.0×             - 瓶颈归因                - A/B 对比（QoR 不回归）
  - 分项剖面               - top-5 热点函数
```

**核心架构判断**：G21 日常性能线与 G20 大设计线**共用同一套 StageTimer、同一份 profile.jsonl schema**——差别只在「设计规模（daily 5 套 vs scale 大设计）」和「额外工具（G20 加火焰图/profiler）」。性能对标的前提是**功能正确性不受损**（质量优先，KH-X-05）。

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| **D1** | **质量优先于速度**（KH-X-05） | 先刷墙钟，QoR 后验 | **红线**：G21 不得在 G17 红时强行转绿；加速 PR 必须附 QoR A/B。commercial/iEDA 的 effort 各自冻结并作为不同 Pareto 点，不能把降 effort 得到的速度当作同质量加速。 |
| **D2** | **受控 runner + 绑核协议强制**（`parity_protocol.perf`） | 共享机单次数字进 G21 | 共享负载、NUMA、turbo、温度和缓存会污染墙钟；用资源隔离、≥5 次 median/MAD 和硬件 manifest 判断是否可用。8% 只是初始噪声上限，需由 runner 实测冻结。 |
| **D3** | **分项剖面必留**（逐 stage 写入 `profile.jsonl`） | 只看 e2e 总墙钟 | **热点定位前提**：只看 e2e = 盲目优化（不知道哪个 stage 慢）；分项剖面 = 有靶点（优化瓶颈 stage）；对照：商业工具 log 均有逐 stage 墙钟（Innovus `.log` 每步时间戳）；**被否原因**：只看 e2e = 优化无头绪（可能优化非瓶颈、浪费工程量）。 |
| **D4** | **先 M0 基线 → M1 商业对比 → M2 热点优化**（有序演进） | M0 直接开始优化 | **无基线不优化**：vs 商业工具的逐 stage 墙钟对比数据（§1.5）是优化靶点的前提；M0 量自己（iEDA 各 stage 墙钟基线）→ M1 量差距（vs 商业工具）→ M2 优化瓶颈（热点驱动）；**被否原因**：M0 直接优化 = 盲人摸象（不知道哪快哪慢、优化无依据）。 |
| **D5** | **热点 + Amdahl + ROI 驱动优化** | 全面并行化（所有 stage 加 OpenMP） | 用 profile、理论复杂度、可达 speedup 和工程成本选择工作包；即使占比低于 30%，若跨工具复用或收益便宜也可做，反之大热点若不可加速也不盲投。 |
| **D6** | **优化 A/B 门禁强制**（PR 必须附 QoR 对比数据） | 优化 PR 无门禁 | **质量保障**：无门禁 = 加速 PR 可能牺牲 QoR（降 effort、关检查）；A/B 门禁 = QoR 不回归（G17 指标 Δ≤1%）；对照：商业工具每个版本都有 QoR regression 测试（Innovus release notes 明确列出性能提升 + QoR 不回归）；**被否原因**：无门禁 = 技术债累积（加速换质量，后期难修）。 |

---

## 4. LLD · 模块分解

### 4.0 落点

```text
src/platform/tool_manager/         ← ★ StageTimer（新增）
src/utility/time/                  ← ★ StageTimer 备选位置
benchmark/qor/
  profile_schema.json              ← ★ 新增
  parity_protocol.perf             ← ★ 新增
  run_perf_compare.sh              ← ★ 新增
  perf_align.json / scale_report.json / hotspot_report.json  ← ★ 产物
scripts/design/<pdk>_gcd/
  run_iEDA_perf.sh                 ← ★ 包裹 StageTimer
scripts/integration/
  run_qor_ab.sh                    ← ★ 优化 A/B 门禁
  analyze_hotspot.sh               ← ★ 火焰图/profiler 工具链
```

### 4.1 ALG · StageTimer 钩子（FR-PERF-01，P0 前置）

```cpp
// src/platform/tool_manager/StageTimer.hh（★ 新增）
class StageTimer {
 public:
  explicit StageTimer(std::string stage_name);
  ~StageTimer();  // 自动 stop + emit
  
  void start();
  void stop();
  
  struct Metrics {
    double wall_s = 0.0;
    double user_cpu_s = 0.0;  // getrusage 差值
    double sys_cpu_s = 0.0;
    int threads = 0;
    std::string host;
    std::string binary_sha256;
    std::string build_manifest_sha256;
  };
  
  Metrics getMetrics() const;
  void emit(const std::string& jsonl_path);  // append to profile.jsonl
  
 private:
  std::string stage_name_;
  std::chrono::steady_clock::time_point t0_;
  rusage usage_t0_;
};

// 使用示例（TCL 命令包裹）
// tcl_ipl/tcl_register_ipl.cpp:
StageTimer timer("iPL-GP");
timer.start();
run_global_place();  // 原有逻辑
timer.stop();
timer.emit("benchmark/qor/profile.jsonl");
```

**复杂度**：O(1) per stage。进程峰值内存由 runner 读取 cgroup v2 `memory.peak`，或把待测 stage 放入独立子进程采集。`VmPeak/VmHWM` 是整个进程生命周期高水位，不能归因给后续嵌套 stage。
**边界**：嵌套 timer 可计 wall/cpu，但不能各自声称 peak memory；失败时 emit 标记 `"status":"failed"`。
**复用姿势**：RAII 自动析构 emit；或显式 start/stop（TCL 层包裹）。

### 4.2 ALG · profile schema + 校验（FR-PERF-02，P0）

```json
// benchmark/qor/profile_schema.json（★ 新增）
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["design", "stage", "run_id", "repeat", "wall_s", "user_cpu_s", "sys_cpu_s", "threads", "host", "binary_sha256", "input_manifest_sha256"],
  "properties": {
    "design": {"type": "string"},
    "run_id": {"type": "string"},
    "repeat": {"type": "integer", "minimum": 0},
    "stage": {"enum": ["iFP", "iPL-GP", "iPL-DP", "iCTS", "iTO", "iRT-GR", "iRT-TR", "iRT-DR", "iSTA", "iRCX", "iDRC", "iPW", "e2e"]},
    "wall_s": {"type": "number", "minimum": 0},
    "user_cpu_s": {"type": "number", "minimum": 0},
    "sys_cpu_s": {"type": "number", "minimum": 0},
    "process_peak_mb": {"type": "integer", "minimum": 0},
    "threads": {"type": "integer", "minimum": 1},
    "host": {"type": "string"},
    "binary_sha256": {"type": "string", "pattern": "^[0-9a-f]{64}$"},
    "input_manifest_sha256": {"type": "string", "pattern": "^[0-9a-f]{64}$"},
    "status": {"enum": ["success", "failed"], "default": "success"}
  }
}
```

**校验器**：`python3 scripts/integration/validate_profile.py profile.jsonl` → 返回 0（通过）或非 0（失败 + 错误行号）。

### 4.3 ALG · run_perf_compare.sh（FR-PERF-03，P0）

```bash
#!/bin/bash
# benchmark/qor/run_perf_compare.sh（★ 新增）

# 输入：profile.jsonl（iEDA）、commercial_log/（商业工具日志）
# 输出：perf_align.json（逐 stage ratio）

designs=("gcd" "aes" "jpeg" "...)
stages=("iFP" "iPL-GP" "iPL-DP" "iCTS" "iTO" "iRT-GR" "iRT-TR" "iRT-DR" "iSTA" "iRCX" "iDRC" "iPW")

for design in "${designs[@]}"; do
  for stage in "${stages[@]}"; do
    # 从 profile.jsonl 解析 iEDA 墙钟
    ieda_wall=$(jq -r "select(.design==\"$design\" and .stage==\"$stage\") | .wall_s" profile.jsonl)
    
    # 从商业工具日志解析墙钟（Innovus .log / StarRC .log）
    commercial_wall=$(parse_commercial_log.py "$design" "$stage" commercial_log/)
    
    # 计算 ratio
    if [ -n "$ieda_wall" ] && [ -n "$commercial_wall" ]; then
      ratio=$(echo "scale=3; $ieda_wall / $commercial_wall" | bc)
      echo "{\"design\":\"$design\",\"stage\":\"$stage\",\"ieda_s\":$ieda_wall,\"commercial_s\":$commercial_wall,\"ratio\":$ratio}" >> perf_align.json
    fi
  done
done

# 计算 e2e
# ...（同上逻辑，stage="e2e"）

# 判定 G21
python3 scripts/integration/check_g21.py perf_align.json
# → exit 0（5 个 daily 设计 e2e 均≤1.5×，且其中至少 2 个≤1.0×）or exit 1
```

**复杂度**：O(designs × stages)；商业日志解析 O(log_lines)。  
**边界**：商业日志格式差异（Innovus vs Fusion vs StarRC）→ `parse_commercial_log.py` 多分支。

### 4.4 ALG · 优化 A/B 门禁（FR-PERF-05，P0 质量保障）

```bash
#!/bin/bash
# scripts/integration/run_qor_ab.sh（★ 新增）

# 输入：两个已构建且不可变的 artifact 目录；每个目录含 binary SHA-256/build manifest
# 输出：qor_ab_report.json（QoR 对比 + 判定）

designs=("gcd" "aes" "jpeg" "...")
metrics=("WNS" "TNS" "DRC_violations" "area" "total_wirelength")

for design in "${designs[@]}"; do
  run_one_artifact "$BASELINE_ARTIFACT" "$design" "result/baseline/$design"
  run_one_artifact "$CANDIDATE_ARTIFACT" "$design" "result/candidate/$design"
  compare_qor_joint.py \
    "result/baseline/$design" "result/candidate/$design" \
    --protocol parity_protocol.json --append qor_ab_report.json
done
```

**门禁契约**：优化 PR 必须跑此脚本并附 `qor_ab_report.json`；CI 强制检查。脚本禁止在用户当前工作区执行 `git checkout`、`git clean` 或复用同一输出目录；本地需要源码 A/B 时使用两个独立 worktree/build 目录。WNS/TNS 接近零或为负时按绝对 ps + 符号语义比较，不能直接除 baseline。

### 4.5 ALG · 热点定位（FR-PERF-06，P1 G20 瓶颈归因）

```bash
#!/bin/bash
# scripts/integration/analyze_hotspot.sh（★ 新增）

# 输入：stage（如 "iRT-DR"）
# 输出：hotspot_report.json + flamegraph.svg

design="large_design"  # G20 大设计
stage=$1

# perf record（需 sudo 或 CAP_PERFMON）
perf record -F 99 -g --call-graph dwarf -o perf.data \
  bin/iEDA -script scripts/design/<pdk>_$design/run_$stage.tcl

# perf report（top-5 热点函数）
perf report -i perf.data --stdio | head -50 > perf_report.txt
python3 scripts/integration/parse_perf.py perf_report.txt > hotspot_report.json
# → {"top5": [{"func": "maze_route", "pct": 35.2}, ...]}

# 火焰图（可选）
perf script -i perf.data | stackcollapse-perf.pl | flamegraph.pl > flamegraph.svg
```

**前置**：`build.sh -DCMAKE_BUILD_TYPE=RelWithDebInfo`（保留符号表）；iRT Rust 侧 `cargo build --release` + `RUSTFLAGS=-g`。

### 4.6 ALG · 并行可扩展性测试（FR-PERF-07，P1）

```bash
#!/bin/bash
# scripts/integration/test_scalability.sh（★ 新增）

design="aes"
threads_list=(1 4 8 16)

for threads in "${threads_list[@]}"; do
  export OMP_NUM_THREADS=$threads
  StageTimer timer("iPL-GP-threads$threads")
  bin/iEDA -script scripts/design/<pdk>_$design/run_ipl.tcl
  # → emit profile.jsonl（含 threads 字段）
done

# 计算加速比
python3 scripts/integration/calc_speedup.py profile.jsonl > scalability.json
# → {"stage": "iPL-GP", "baseline_s": 120, "speedup": [1.0, 3.2, 5.8, 9.1]}
# → 并行效率 = speedup[i] / threads_list[i]（理想=1.0）
```

### 4.7 模块状态一览（成熟度 / 复杂度 / 边界 / 复用姿势）

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| `StageTimer` | ✗ 不存在 | O(1)/stage；RSS 读 `/proc` | 嵌套 timer（子 stage）支持 | ★ 新建（RAII 或显式 start/stop） |
| `profile.jsonl` schema | ✗ 不存在 | O(lines) 校验 | stage 枚举完整性（新 stage 需加） | ★ 新建 + JSON schema 校验器 |
| `run_perf_compare.sh` | ✗ 不存在 | O(designs×stages) | 商业日志格式差异（多分支解析） | ★ 新建（Composition `parse_commercial_log.py`） |
| `parity_protocol.perf` | ✗ 不存在 | O(1) 读配置 | 独占机验证（`ps` / `top` 检查其他任务） | ★ 新建（YAML/JSON 配置文件） |
| `run_qor_ab.sh` | ✗ 不存在 | O(designs×2) 双跑 | 两个 immutable artifact/独立输出目录 | ★ 新建（CI 强制调用） |
| `analyze_hotspot.sh` | ✗ 不存在 | O(samples) perf 采样 | `perf` 权限（CAP_PERFMON or sudo） | ★ 新建（G20 手动触发） |
| 各工具 Monitor/LOG | ⚠️ 散落 | — | 格式不统一（ms/s/无单位） | 保留但不作 G21 真源（改用 StageTimer） |
| OpenMP 并行（iPL/iSTA/...） | ✓ 部分在 | — | 可扩展性未测 | 保留 + 新增 scalability 测试 |
| iRT Rust 侧 profiling | ✗ 未验证 | — | 跨语言符号表（`RUSTFLAGS=-g`） | ★ 验证 `perf` + Rust 符号 |

---

## 5. 配置

`parity_protocol.perf`（YAML 或 JSON）：

```yaml
# benchmark/qor/parity_protocol.perf（★ 新增）
performance:
  threads: 8                    # OMP_NUM_THREADS 固定
  pin_cores: [0-7]              # taskset -c 0-7（可选）
  exclusive_host_required: true # 由受控 runner/cgroup 判定，不解析易漂移的 ps 文本
  repeats: 5                    # 至少 5 次有效重复；按 median 判定
  cache_mode: [cold, warm]      # 分开报告，不混合平均
  memory_source: cgroup_v2      # memory.peak；不可用时用独立子进程
  g21_enable: false             # M3 前观测（false）；M3 后门禁（true）
  
designs_daily:                  # G21 日常 5 套
  - gcd
  - aes
  - jpeg
  - usb
  - spi

designs_scale:                  # G20 大设计 1-3 套
  - large_design_1
  - large_design_2

stages:                         # 必须覆盖的 stage
  - iFP
  - iPL-GP
  - iPL-DP
  - iCTS
  - iTO
  - iRT-GR
  - iRT-TR
  - iRT-DR
  - iSTA
  - iRCX
  - iDRC
  - iPW
  - e2e

thresholds:
  g21_e2e_ratio_max: 1.5        # 端到端 ≤1.5×
  g21_design_le1_count_min: 2   # ≥2/5 个 daily 设计 e2e ≤1.0×
  g20_e2e_ratio_max: 3.0        # 大设计 ≤3×
  rerun_variance_max: 0.08      # 复跑波动 ≤8%
  qor_ab_delta_max: 0.01        # 优化 A/B QoR Δ≤1%
  parallel_efficiency_min: 0.6  # 并行效率 ≥0.6
```

---

## 6. Cost / 指标分解

禁止单一标量掩盖。每次 `run_perf_compare.sh` 独立记录：

| 维 | 指标 | 来源 | 对标线 |
|---|---|---|---|
| **e2e 墙钟** | iEDA_e2e_s / commercial_e2e_s | `profile.jsonl` + 商业日志 | **G21**（≤1.5×） |
| **分项墙钟** | 共同大阶段 median ratio（iEDA/commercial） | `perf_align.json` | 归因项；不可比 stage 标 N/A |
| **峰值内存** | cgroup/独立进程 `process_peak_mb` | runner | 记录（G20 线性度验证） |
| **并行效率** | `(user+sys)_cpu_s / (wall_s × threads)` | `profile.jsonl` | 诊断项；结合 speedup/锁/带宽解释 |
| **复跑波动** | median + MAD/置信区间（≥5 次） | `profile.jsonl` | 超协议噪声则本配置不判定 |
| **热点函数** | top-5 func + pct（perf report） | `hotspot_report.json` | G20（瓶颈归因） |
| **QoR A/B** | Δ(WNS/TNS/违例/面积/线长) | `qor_ab_report.json` | ≤1%（质量优先） |

---

## 7. 状态机 / 命令语义

```text
              init_parity_protocol()
                      │
      ┌───────────────┼───────────────┐
      │ G21 模式      │     G20 模式   │
      ▼               ▼                ▼
  check_exclusive_host()  同左    + check_design_scale()
      │                              │
  for design in daily[5]:        for design in scale:
    StageTimer.start(stage)          同左
    run_stage()                      │
    StageTimer.stop()                + perf record（火焰图）
    emit profile.jsonl               │
      │                              │
      ▼                              ▼
  run_perf_compare.sh          run_perf_compare.sh（大设计）
  → perf_align.json            + analyze_hotspot.sh
      │                        → hotspot_report.json
      ▼                              │
  if g21_enable:                     ▼
    assert daily 全部 e2e≤1.5×          assert e2e≤3× ∧ 有热点归因
           ∧ 至少 2 个设计≤1.0×
  else:
    emit warning（观测模式）
```

| 命令/API | 成功 | 失败 rc（目标） |
|---|---|---|
| `StageTimer::start` | 记录 t0 + cpu_t0 + rss_baseline | — |
| `StageTimer::stop` | 计算 wall/cpu/rss → emit | — |
| `run_perf_compare.sh` | 产出 `perf_align.json` | 商业日志缺失 → 非 0 + LOG_ERROR |
| `check_g21.py` | daily 全部 e2e≤1.5× 且至少 2 个设计≤1.0× | exit 1（门禁失败；观测模式仅 warning） |
| `run_qor_ab.sh` | QoR Δ≤1% | exit 1（优化 PR 拒绝合入） |

---

## 8. 跨工具 Cascade——★调用方契约表（rv2.0 新增）

| 调用方 | 现状 | 目标契约 | 单位/口径 |
|---|---|---|---|
| **40-platform FlowScheduler** | 无统一计时 | ★ 每 stage 自动包裹 `StageTimer`（或 TCL wrapper） | wall_s、user/sys_cpu_s；peak memory 由 runner/cgroup 采集 |
| **各工具 TCL 命令** | 散落时间戳 | ★ 保留原有 LOG，但不作 G21 真源；真源=`StageTimer` | — |
| **12-evaluation** | 只管 QoR | ★ 新增 `qor_perf_joint.json`（QoR + 性能联合报告） | G17 + G21 |
| **perf → G21 CI** | 无门禁 | ★ `g21_enable=false`（M3 前观测）；M3 后 true（门禁） | exit 0/1 |
| **优化 PR → A/B** | 无强制 | ★ CI 强制检查 `qor_ab_report.json` 存在 + PASS | QoR Δ≤1% |
| **商业工具 → iEDA** | 无同机对比 | ★ 同机同 threads 跑商业工具（Innovus/StarRC）+ 日志采集 | vs 商业工具基线 |

**闭环触发**：优化 PR 提交 → CI 自动跑 `run_qor_ab.sh` → QoR 回归 → PR 拒绝合入；M3 开启 G21 门禁 → daily CI 跑 `run_perf_compare.sh` → e2e>1.5× → 门禁失败。

---

## 9. 商业 Know-how 映射（引用 `03`）

| KH-ID | 含义 | 本工具落点 |
|---|---|---|
| KH-EV-01 | 并排金参考墙钟 | §4.3 `run_perf_compare.sh`；vs 商业工具同机同 threads |
| **KH-X-05** | **质量优先于速度** | §2.3 红线；§4.4 优化 A/B 门禁；G21 不得在 G17 红时强行转绿 |
| KH-X-08 | 不确定度带（复跑波动记入 ε） | §6 复跑波动 ≤8%；独占机 + 绑核（`parity_protocol.perf`） |
| KH-X-01 | 同一真值源闭环 | G21 与 G17 联动（QoR 稳定 → 性能提升） |
| KH-X-04 | 响亮失败 | `check_g21.py` exit 1（门禁失败）；`run_qor_ab.sh` exit 1（QoR 回归） |

---

## 10. 看板 + M0–M4

| 档 | 规则 | G |
|---|---|---|
| daily e2e | 5 个设计均≤1.5×；其中≥2/5 个设计≤1.0× | G21 |
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

主纲 G21：五个日常设计端到端墙钟均 **≤1.5×** 商业主对标方，且至少 **2/5 个设计 ≤1.0×**；关键步骤分项剖面进 JSON；大设计（G20）放宽 **≤3×** 且附瓶颈定位。

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

1. 有稳定的 stage/substage 占比、调用次数和输入规模，并估算 Amdahl 上限；
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
