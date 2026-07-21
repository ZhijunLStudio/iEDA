<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 40 · platform / flow 平台与流程编排 · 商业对标优化方案 · rv1.0

> 文档号：40-rv1.0　　版本：v2.0　　里程碑：**脚本散装 → DAG 编排 + 引擎就绪契约 + 失败非零 + 断点续跑 + 单 session（G16）**
> 体例：`01-ai-doc-conventions-rv1.md`　主纲：G1/G1b/G14/G15/G16　Know-how：KH-PLAT-01/02、KH-X-03/04
> 事实：`flow.h:51-53` 仅 initFlow/run/runTcl；`tool_flow/` **仅 CMakeLists.txt**；`ieda_main.cpp:69` `return 0`；`tool_api/*_io` 单例群
> 纪律：断言带 `file:line`；顺序陷阱先实验再改代码。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.2 | 2026-07-20 | 空壳/契约/DAG LLD；编号未对齐 01 骨架 |
| **rv1.0 / v2.0** | **2026-07-20** | **§0–§14 重排**；坐实 `tool_flow/` 空壳与 `ieda_main` 恒 `return 0`；F2 仍待对照实验。 |

---

## 1. 症结审计

| ID | 症结 | 证据 | P |
|---|---|---|---|
| F1 | 编排层空壳 | `tool_flow/` 仅 CMakeLists.txt；`flow.h:51-53` 三入口 | P0 |
| F2 | 引擎就绪契约缺失 | tool_api 单例互访；fork eval→rcx SPEF 静默 | P0 先实验 |
| F3 | 失败可能整体 exit 0 | `ieda_main.cpp:69` `return 0`；子步骤 FATAL 与 rc 关系未审 | P0 |
| F4 | incr LG/ECO 无平台原语 | 脚本串联 | P1 |
| F5 | 断点续跑未证 | 无 checkpoint | P1 |
| F6 | 多设计单例污染 | 未审计 | P2 |

### 1.2 对标矩阵摘要

商业 session ≈ DAG×requires×on_fail；iEDA 流程活在用户 TCL——顺序在人脑。

### 1.3–1.4

边界：启动期拓扑错误允许 FATAL；运行期数据缺失应 ERROR+rc。跨工具：C1–C9 契约族（§10）。

---

## 2. 需求 FR / NFR

| ID | 需求 | 现状 | P |
|---|---|---|---|
| FR-PLAT-01 | ★ FlowScheduler DAG | ✗ F1 | P0 |
| FR-PLAT-02 | ★ 就绪契约+拓扑校验 | ✗ F2 | P0 |
| FR-PLAT-03 | ★ 失败非零+SUCCESS stamp | ❓ F3 | P0 |
| FR-PLAT-04 | 断点续跑逐位一致 | ✗ | P1 |
| FR-PLAT-05 | 增量三原语+commit 强制 | ✗ | P1 |
| FR-PLAT-06 | run_qor_baseline 共管 | ✗ | P0 |
| NFR-PLAT-01 | 违序=启动失败 | G14 | |
| NFR-PLAT-02 | 续跑逐位一致 | G16 | |

---

## 3. HLD

```text
FlowScheduler:
  idb_init → fp → place → cts → pdn → route → rcx → sta → to → drc → lvs → eval
                 ↘ incr_lg(cts,to)   ↘ route_eco
requires: sta←rcx_ready; eval←sta∧rcx; report←products
失败: abort_chain + rc≠0 + 无 SUCCESS stamp
```

决策：编排内建化；commit 闭环平台强制；续跑=逐位一致；单例+代理不大翻修。

| # | 决策 | 被否 |
|---|---|---|
| D1 | DAG 在代码 | 保持纯脚本 |
| D2 | commit 必 incr LG | 工具自觉 |
| D3 | 续跑逐位一致 | 「能跑完」 |
| D4 | 单例代理 | 重写引擎管理 |

---

## 4. LLD

### 4.0 落点

```text
src/platform/flow/tool_flow/
  FlowScheduler.* / EngineContract.hh / incr_loop.hh / Checkpoint.*
scripts/integration/run_contract_tests.sh
benchmark/qor/run_qor_baseline.sh
```

### 4.1 FlowScheduler `[新增]`

```cpp
struct Stage {
  std::string name;
  std::vector<std::string> requires;
  std::function<bool()> run;
  std::function<bool()> assert_products;
};
// validateTopo() 启动期；run() 任一 false → rc≠0
```

### 4.2 顺序陷阱实验 `[P0 第一交付]`

```text
A: rcx → sta → eval
B: eval → rcx
查 SPEF 读入/耦合弧；B 静默不读 → F2 实锤
```

### 4.3 失败传播

包装 `ieda_main`：捕获非零/异常；SUCCESS stamp 仅全绿。

### 4.4 增量原语

`IncrLegalizeAfterCommit` / `IncrRouteEco` / `IncrRetimingVeto`。

### 4.5 模块状态

| 模块 | 状态 | 动作 |
|---|---|---|
| Flow | 薄壳 | ★ Scheduler |
| tool_flow | 空 | ★ 填 |
| tool_api/*_io | 单例群 | 代理注册 |
| ieda_main | 恒 0 | ★ rc |

---

## 5. 配置

flow plan JSON/TCL 声明 stage 列表；缺省=现有脚本行为（零回归）；`strict_contract=true` 开启违序失败。

---

## 6. 指标

全流程通/不通、违序检出、续跑 diff、子步骤 rc、端到端墙钟（→42）。

---

## 7. 状态机

```text
validateTopo → for stage: check_ready → run → assert_products → stamp
fail → abort → rc≠0
checkpoint @ stage boundary（可选）
```

---

## 8. Cascade

平台强制：任何 netlist commit（iTO/iNO/iCTS/iECO）→ incr LG。就绪：eval 不得早于 rcx（KH-PLAT-01）。

---

## 9. Know-how

| KH | 落点 |
|---|---|
| KH-PLAT-01 | §4.2 顺序契约 |
| KH-PLAT-02 | 度量外生（与 12） |
| KH-X-03 | 断点续跑 |
| KH-X-04 | 失败非零 |

---

## 10. 看板 + M0–M4

| 指标 | iEDA | 商业 | 门槛 | G |
|---|---|---|---|---|
| netlist→GDS 单 session | | ✓ | ✓ | G16 |
| 违序检出 | | 启动报错 | 报错 | G14 |
| 续跑一致 | | 逐位 | 逐位 | G16 |
| 崩溃 rc | | ≠0 | ≠0 | G14 |
| 墙钟 | | | ≤1.5× | G21 |

契约测试 C1–C9：eval↔rcx、sta↔rcx、ipl↔ifp、ito↔ipl、icts↔ipl、irt↔idrc、ipa↔vcd、flow↔rc、checkpoint。

```text
M0 顺序陷阱实验 + F3 rc 审计 + 空壳台账
M1 DAG + 失败语义（G14）
M2 增量闭环 + 续跑（G16）
M3 接 G1 看板
M4 PPA 外环
```

---

## 11. Exhibit

`flow_stamps.json`、`contract_report.json`、checkpoint manifest。

---

## 12. 测试

T-A1 违序启动失败；T-B1 注入崩溃 rc≠0；T-C1 C1–C9；T-D1 续跑 diff=0；T-E1 commit→incr LG。

---

## 13. 里程碑

P0 只做实验与审计（PR-PLAT-0），不写编排代码。

---

## 14. 未验证

| # | 项 |
|---|---|
| 1 | 本仓是否存在 eval/rcx 顺序病 | §4.2 |
| 2 | 子步骤崩溃实际 rc | 注入 |
| 3 | tcl_flow 默认序列 | 读代码 |
| 4 | 多设计单例污染 | 连跑 |
| 5 | iDB 序列化（续跑前提） | 10 |

**不要重走**：无契约先「重构全部 TCL 脚本」。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 编排内建 | 纯脚本 |
| E-2 | commit 强制闭环 | 自觉 |
| E-3 | 续跑逐位一致 | 能跑完 |
| E-4 | 单例代理 | 重写 |
| E-5 | fork 契约族借鉴 | 重发明 |


---

## 附 · 代码证据与 tool_api 清单

| 断言 | 证据 |
|---|---|
| Flow 三入口 | `flow.h:51-53` initFlow/run/runTcl |
| tool_flow 空壳 | 目录仅 `CMakeLists.txt` |
| main 恒 0 | `ieda_main.cpp:69` `return 0` |
| tool_api | `icts_io idrc_io ieval_io ifp_io ino_io ipdn_io ipl_io ipnp_io ipw_io irt_io ista_io ito_io` |

### 就绪契约表（初稿，可改）

| stage | requires |
|---|---|
| place | idb_ready, fp_ready |
| cts | place_legal |
| route | cts_done 或 place_legal（flow 可配） |
| rcx | route_done |
| sta | rcx_ready |
| to | sta_ready, legal |
| eval | sta_ready, rcx_ready |
| report | products_exist |

### SUCCESS stamp 格式

```json
{"flow":"impl","stages":["place","cts","route"],"rc":0,"binary_hash":"...","ts":"..."}
```

缺 stamp → CI 不得标流程成功。

### PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| PLAT-0 | §4.2 实验+F3 审计 | F2 实锤/排除 |
| PLAT-1 | Scheduler+契约 | 违序失败 |
| PLAT-2 | rc+stamp | 注入崩溃 |
| PLAT-3 | incr 三原语 | T-E |
| PLAT-4 | checkpoint | 逐位 |
| PLAT-5 | qor baseline | G1 |


### F3 rc 审计步骤（P0）

```text
1. 人为在 iRT/iPL 注入 LOG_FATAL 或 abort
2. 观察进程 exit code 与是否写 SUCCESS stamp
3. 若 exit=0 → F3 实锤 → PR-PLAT-2 必做
```

### incr 三原语与工具文档交叉引用

| 原语 | 实现落点 | 关联文档 |
|---|---|---|
| IncrLegalizeAfterCommit | iPL runIncrLG | 22/23/25 |
| IncrRouteEco | iRT routeECO | 26 |
| IncrRetimingVeto | iSTA incr | 27 |

### 脚本编排 → DAG 迁移策略（零回归）

1. 默认仍跑用户 TCL（行为不变）；  
2. `strict_contract=true` 时启用 Scheduler；  
3. 日常 CI 先开契约测试 C1–C9，再切默认。

### 多设计批跑（F6）隔离选项

| 策略 | 说明 | 阶段 |
|---|---|---|
| 进程池 | 每设计一进程 | 推荐 M2 |
| reset 单例 | 同进程清状态 | 难，后置 |

### FlowScheduler 伪代码（完整）

```text
validateTopo(stages):
  if cycle or missing_require: FATAL startup
run(plan):
  for s in plan:
    if not ready(s.requires): ERROR; return nonzero
    if not s.run(): abort; return nonzero
    if not s.assert_products(): abort; return nonzero
    stamp(s)
  write SUCCESS
  return 0
```

### 与用户 TCL 共存例

```tcl
# 旧：纯脚本顺序
# 新：可选
flow_set_strict_contract true
flow_run_plan impl_standard
```

strict 关闭时行为与今日一致（零回归）。

## 附 B · 决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 编排内建化 | 纯脚本约定 |
| E-2 | commit 闭环平台强制 | 工具自觉 |
| E-3 | 续跑=逐位一致 | 能跑完即续跑 |
| E-4 | 单例+代理 | 重写引擎管理 |
| E-5 | fork 契约族借鉴 | 重发明 |

checklist：P0 实验完成？F3 rc 已知？tool_flow 不再空壳？SUCCESS stamp 有消费者？


### 体例合规声明

本文档已按 `01-ai-doc-conventions-rv1.md` 强制骨架组织（§0–§14），引用主纲门禁与 `03-commercial-knowhow-catalog.md` 的 KH-ID；未实测项见 §14。

主纲版本锚定：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how 目录：`03-commercial-knowhow-catalog.md`。

