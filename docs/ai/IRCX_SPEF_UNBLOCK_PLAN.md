# iRCX SPEF 生成紧急报告 - 解除 Agent A1 阻塞

**时间**：2026-07-29
**状态**：🟢 **可解除阻塞** - SPEF 基础设施完整，只需集成到流程

---

## 关键发现：SPEF 能力存在但未调用

### ✅ 好消息
- **iRCX 基础设施完整**：`SpefDumper.cc` 已实现
- **Tcl 命令已注册**：`init_rcx`, `run_rcx`, `report_rcx`
- **API 链路验证**：`RCXAPI::report()` → `Report::dumpSpef()` → `SpefDumper::dump()`

### 🔴 问题根因
- **AES13 流程未调用 iRCX**：所有设计脚本中 grep 无 `init_rcx|run_rcx`
- **缺少 RCX 配置文件**：无 `rcx_config.json`（需要 ITF/captab 文件）
- **流程缺失 RCX 阶段**：当前是 netlist→iFP→iPL→iCTS→iTO→iRT→iDRC，跳过了 iRCX

---

## 立即行动方案（24-48 小时）

### Phase 1：生成首个 SPEF（24h）

**步骤 1：定位 PDK 文件**
```bash
# 查找 sky130 的 ITF 和 captab 文件
find /home/lxq/AiEDA/Foundary/sky130 -name "*.itf" -o -name "*.captab"
```

**步骤 2：创建 RCX 配置**
创建 `benchmarks/designs/aes_sky130_a/workspace/iEDA_config/rcx_config.json`：
```json
{
  "output": "./result/rcx",
  "mapping_file": "<pdk>/layer_mapping.txt",
  "corners": [{
    "name": "typical",
    "itf_file": "<pdk>/sky130.itf",
    "captab_file": "<pdk>/sky130.captab"
  }]
}
```

**步骤 3：修改流程脚本**
在 `benchmarks/designs/aes_sky130_a/workspace/script/` 的后端流程中，**iRT 之后、iSTA 之前**插入：
```tcl
# After routing (iRT)
source script/iRCX_script/run_iRCX.tcl

# 或直接调用
init_rcx -config iEDA_config/rcx_config.json
run_rcx
report_rcx  # 生成 SPEF
```

**步骤 4：验证输出**
```bash
# 检查 SPEF 文件生成
ls -lh benchmarks/designs/aes_sky130_a/workspace/result/rcx/*.spef

# 验证 SPEF 头部（单位对齐）
head -30 <spef_file>
# 期望看到：
# *C_UNIT 1 FF
# *R_UNIT 1 OHM
# *T_UNIT 1 NS
```

### Phase 2：单位对齐验证（48h）

**验证 DEF DBU vs SPEF 单位**
```bash
# 提取 DEF database unit
grep "UNITS DISTANCE MICRONS" <post_route_def>
# sky130: 1000 DBU/µm

# 检查 SPEF 单位与 DBU 的换算关系
# 确保电阻/电容单位与物理尺度一致
```

**交付给 Agent A1**
- ✅ SPEF 文件路径
- ✅ 单位映射文档
- ⚠️ 已知限制：无 StarRC 校准（精度待定）

---

## 精度瓶颈（P1 - 不阻塞 SPEF 生成）

Agent A2 识别了 7 个精度缺口（vs StarRC）：

| 缺口 | 影响 | 优先级 |
|------|------|--------|
| 多邻居模式（3+ aggressors） | 低估密集区耦合电容 | P0 |
| Via 电容 | 先进工艺误差源 | P0 |
| 宽金属边缘电容 | 电源网偏差 | P1 |
| Field-solver 校准 | 无 pattern→EM3D 验证 | P1 |
| PBTV 厚度模型 | 代码已注释（line 111-117） | P1 |
| 屏蔽耦合模型 | 简化为接地 | P1 |
| StarRC 对齐框架 | 无 vs-gold CI | P0 |

**结论**：当前 SPEF 会有**未知系统误差**，G8 门禁需要完整校准

---

## G8 门禁要求（延后但必需）

根据 `04-ppa` §2.4 + `28-iRCX` §2，无法声称时序等效除非：
- Ground C / coupling C / wire R / via R **分量相关性**（R²>0.98, P90<10%）
- **拓扑准确性**（节点/分支覆盖，无开路/短路）
- **Elmore 延迟** vs StarRC（按层/几何/扇出分桶）
- **绝对+相对误差** 报告（P50/P90/P95/max）

---

## 给 Agent A1 的交付物（48h 内）

1. ✅ **SPEF 文件**：≥1 个 AES13 配置（sky130_a 优先）
2. ✅ **单位验证**：DEF DBU ↔ SPEF C_UNIT/R_UNIT 对齐证明
3. ⚠️ **已知问题**：无 StarRC 校准，多邻居/via C 缺口
4. 📋 **集成方案**：Tcl 命令 + 配置模板（供其他 PDK）

---

## 推荐策略

**短期（立即）**：
- ✅ 使用现有 iRCX 生成 SPEF（接受未知误差）
- ✅ 解除 Agent A1 阻塞，开始 PBA 实现
- ✅ 验证单位对齐（避免系统性偏差）

**中期（并行）**：
- ⏳ G8 StarRC 对齐作为 Phase 2
- ⏳ 修复 7 个精度缺口
- ⏳ 建立 vs-gold 回归测试

**验收标准**：
- Agent A1 能读取 SPEF，net delay 不再为 0
- iSTA 报告的 WNS 包含寄生延迟
- 单位验证通过（无系统性 10× 误差）

---

## 状态分类

- **SPEF 生成**：✅ **已解除阻塞**（基础设施就绪，需要调用）
- **单位对齐**：🟡 **需要验证**（DBU 映射审计必需）
- **精度校准**：🔴 **阻塞在 G8 门禁**（无 StarRC 金标准）
- **增量提取**：🔴 **未实现**（P2，延后）

---

**下一步**：主 agent 协调 Agent A2 与 flow 集成团队，24h 内在 1 个 AES13 配置上生成首个 SPEF，交付 Agent A1 验证。
