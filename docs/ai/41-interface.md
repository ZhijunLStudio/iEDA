<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 41 · interface（TCL/Python/MCP）接口层 · 商业对标优化方案 · rv1.0

> 文档号：41-rv1.0　　版本：v2.0　　里程碑：**静默失败清零 → 命令=事务 → Python/MCP 对等（G14）**
> 体例：`01-ai-doc-conventions-rv1.md`　主纲：G14　Know-how：KH-IF-01、KH-X-04
> 事实：`src/interface/tcl/`（含多 `Cmd*::exec`）；`tcl_ipl.cpp`；`ipl_io.cpp:170-178` 宏假成功；`python/py_*`；`mcp-iEDA/`
> 纪律：断言带 `file:line`；清单进 repo。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.2 | 2026-07-20 | 四模式+基类 LLD；编号未对齐 01 骨架 |
| **rv1.0 / v2.0** | **2026-07-20** | **§0–§14 重排**；保留 M1 实证 `PlacerIO::runMacroPlacement`（`ipl_io.cpp:170-178`）与 M2 `CmdPlacerRunLG` 吞 bool（`tcl_ipl.cpp:284-293` 一带）。 |

---

## 1. 症结审计

### 1.1 静默失败四模式

| 模式 | 定义 | 本仓实证 | 修法 |
|---|---|---|---|
| M1 空实现假成功 | 空/注释 + `return true` | `ipl_io.cpp:170-178` | 未实现→ERROR+非成功 |
| M2 API 失败 TCL 吞 | API false 仍成功 | `tcl_ipl.cpp` LG exec | 基类查 bool |
| M3 未知键静默 | 未映射用默认 | 待普查 | 未知键 ERROR |
| M4 选项依赖缺失 | 缺前置继续 | 待普查 | 声明式依赖表 |

### 1.2 规模

约 28+ TCL 实现文件；`tcl_ipl` 多 exec；Python `py_*` 在；MCP 目录在——对等度/安全边界 **未验证**。

### 1.3–1.4

判定：G14 治本=基类事务化，非逐命令自觉。跨工具：每个 Cmd 是工具门面。

---

## 2. 需求 FR / NFR

| ID | 需求 | P |
|---|---|---|
| FR-IF-01 | ★ 静默清单进 repo | P0 |
| FR-IF-02 | ★ 基类事务化+存量迁移 | P0 |
| FR-IF-03 | ★ 选项依赖表 | P0 |
| FR-IF-04 | 覆盖矩阵 100% | P1 |
| FR-IF-05 | MCP 边界文档 | Phase C |
| NFR-IF-01 | 新命令强制基类 | G14 |

---

## 3. HLD

```text
用户 TCL/Python/MCP
  → TclCmdTransactional（三表：allowed/dep/products）
  → tool_api → 引擎
失败: rc≠0 + 无假 SUCCESS；产物缺失=失败
```

| # | 决策 | 被否 |
|---|---|---|
| D1 | 基类强制 | 逐命令修补 |
| D2 | 清单周刷新 | 一次性清零 |
| D3 | Python 复用契约层 | Python 另写 |
| D4 | 声明式三表 | 手写校验 |

---

## 4. LLD

### 4.1 普查脚本 `[新增]`

```bash
# M1: return true 空体；M2: return 1 不查 API；M3: unknown/not implement
→ docs/ai/attachments/silent-failure-inventory.md
```

### 4.2 基类 `[新增]`

```cpp
unsigned TclCmd::execTransactional() {
  if (!checkOptionDeps(...)) return 0;
  if (!checkUnknownOptions(...)) return 0;
  if (!runImpl()) return 0;
  for (p : expected_products_) if (!exists(p)) return 0;
  return 1;
}
```

### 4.3 覆盖矩阵 / MCP

矩阵：`工具|TCL|Python|产物断言|测试|状态`；MCP 只读/写分离 Phase C。

### 4.4 PR

PR0 清单；PR1 已知 M1/M2 清零；PR2 基类+核心 30 命令；PR3 依赖/未知键；PR4 全量；PR5 Python/MCP。

### 4.5 模块状态

| 模块 | 状态 | 动作 |
|---|---|---|
| 各 Cmd::exec | 自觉式 | ★ 迁基类 |
| Python | 未对等审计 | 矩阵 |
| MCP | 未审 | Phase C |

---

## 5. 配置

命令注册表；CI 检查新 Cmd 是否继承事务基类。

---

## 6. 指标

清单 open 数、产物断言覆盖、未知键响亮率、Py/TCL 对等率。

---

## 7. 状态机

`parse → dep/unknown check → runImpl → product assert → rc`。

---

## 8. Cascade

失败语义上接 40 stamp；下接全工具 API bool。

---

## 9. Know-how

KH-IF-01 命令=事务；KH-X-04 响亮失败。

---

## 10. 看板 + M0–M4

| 指标 | 门槛 | G |
|---|---|---|
| 清单 open | 0 | G14 |
| 产物断言 | 100% | G14 |
| 未知选项 | 100% 响亮 | G14 |
| Py/TCL | ≥95% | — |

对照：E-IF-01..04 假成功/未知键/依赖/缺产物。

```text
M0 清单+已知点清零
M1 基类+核心迁移
M2 依赖+未知键
M3 全量→G14
M4 Python/MCP
```

---

## 11. Exhibit

`silent-failure-inventory.md`、`cmd-coverage-matrix.md`。

---

## 12. 测试

T-IF-1 四注入；T-IF-2 核心 30 产物 gtest；T-IF-3 未声明表启动失败；T-IF-4 Py/TCL 抽样一致。

---

## 13. 里程碑

P0 只产清单；迁移分批。

---

## 14. 未验证

全仓命中数；命令总数；Python 差集；MCP 写权限；各 JsonParser 未知键行为。

**不要重走**：无基类只修几个明星命令。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 基类强制 | 自觉修补 |
| E-2 | 清单周刷新 | 一次性 |
| E-3 | 声明式三表 | 手写 |
| E-4 | Python 复用层 | 另写 |


---

## 附 · 实证与普查命令

| 模式 | 实证 |
|---|---|
| M1 | `ipl_io.cpp:170-178` |
| M2 | `tcl_ipl.cpp` LG 不查返回值 |
| 规模 | `tcl_ipdn.cpp` ~750 行等大文件；多 `Cmd*::exec` |

### gen_silent_inventory.sh 草案

```bash
rg -n "return true" src/platform/tool_manager src/operation -g'*.cpp' -C3
rg -n "return 1" src/interface/tcl -g'*.cpp' -C2
rg -n "not yet|unsupported|unknown key" src/interface src/operation -i
```

产出 markdown 表：`file:line|mode|tool|status|test`。

### 核心 30 命令迁移优先序（摘）

place/cts/route/to/sta/report_qor/init_*/read_*/write_* → 先于冷门 GUI 命令。

### PR 复述

PR-IF-0..5 同 §4.4；G14 转绿条件=清单 open=0 ∧ 矩阵断言 100%。


### TCL 返回值惯例目标

| 现状常见 | 目标 |
|---|---|
| `return 1` 表示成功 | 成功=1 且 API bool 已查 |
| 忽略 API false | 禁止 |
| 缺产物仍成功 | 禁止 |

Python 绑定必须抛异常或返 False，与 TCL rc 语义对齐（抽样 T-IF-4）。

### MCP 安全边界草案（Phase C）

| 类别 | 默认 |
|---|---|
| 读报告/指标 | 允许 |
| 写 DB / 跑优化 | 需 `mcp.write=true` |
| 删文件/任意 shell | 禁止 |

### 与 22 宏假成功的联动

清单第一条应固定跟踪 `runMacroPlacement` M1，直到 22 宏真化或接口改为显式 `NOT_IMPLEMENTED` 非零失败。

