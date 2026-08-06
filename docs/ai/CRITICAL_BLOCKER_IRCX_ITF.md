# 🔴 关键阻塞：iRCX SPEF 生成不可行

**发现时间**：2026-07-29
**Agent**：A2 (iRCX-StarRC 对齐)
**状态**：P0 阻塞 - 需要立即决策

---

## 问题根因

**iRCX 无法生成 SPEF，因为缺少必需的 ITF 和 captab 文件**

### 代码验证
```cpp
// src/operation/iRCX/source/config/RCXConfig.cc:103-124
// ITF 文件是必需的
if (!corner_json.contains("itf_file")) {
  LOG_ERROR << "missing required corner field: itf_file";
  return false;
}

// captab 文件是必需的
if (!corner_json.contains("captab_file")) {
  LOG_ERROR << "missing required corner field: captab_file";
  return false;
}
```

### 搜索结果
在以下位置**零匹配**：
- ❌ `/home/lxq/AiEDA/iEDA.ai/` (整个仓库)
- ❌ `/home/lxq/AiEDA/Foundary/sky130/`
- ❌ `/home/lxq/AiEDA/Foundary/nangate45/`
- ❌ `/home/lxq/AiEDA/Foundary/asap7/`
- ❌ `/home/lxq/AiEDA/Foundary/ics55/`

---

## 什么是 ITF/Captab 文件？

### ITF (Interconnect Technology Format)
工艺技术文件，描述：
- 金属层（导体规格：宽度、厚度、电阻率）
- 介电层（εr、厚度）
- Via 结构
- 工艺角（温度、电压）

### Captab (Capacitance Table)
预计算的 2D 查找表：
- 耦合电容 vs (宽度, 间距)
- 边缘电容 vs 几何
- 由场求解器生成（Raphael, Fastcap）

### 来源
这些是**晶圆厂专有 PDK 文件**（TSMC/Samsung/GlobalFoundries）或需要商业工具（StarRC）生成。

---

## 现有资源（不兼容）

✅ **存在但不可用**：
- `rcx_patterns.rules`（OpenRCX 格式）- iRCX 不能用
- `Foundary/sky130/spef/gcd.spef` - 由 **Cadence Innovus**（商业工具）生成，不是 iRCX

❌ **关键发现**：当前 AES13 流程中 iSTA **完全没有 SPEF**
- 解释了 Agent A1 发现的 net_delay=0

---

## 对 Agent A1 的影响

1. ❌ 无法生成 iRCX SPEF → A1 无法测试 SPEF 读取
2. ⚠️ 现有 Foundary SPEF（来自 Innovus）来源不明：
   - 可能与当前 DEF 不匹配（不同设计/布线）
   - 单位是 PF/OHM（需要验证 vs AES13 DEF DBU）
   - 设计更改后无法重新生成
3. ❌ 当前 AES13 流程：iSTA 运行时**没有任何 SPEF**

---

## 缓解方案

### 方案 1：使用现有 Innovus SPEF（临时解除阻塞）⭐ 推荐短期

**行动**：
```bash
# 复制现有 SPEF 到 AES13
cp /home/lxq/AiEDA/Foundary/sky130/spef/gcd.spef \
   /home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/workspace/result/

# 修改 iSTA 脚本加载它
echo "read_spef result/gcd.spef" >> \
   benchmarks/designs/aes_sky130_a/workspace/script/iSTA_script/run_iSTA.tcl
```

**优点**：
- ✅ 立即解除阻塞（1 小时）
- ✅ 证明 iSTA SPEF 读取功能正常
- ✅ 验证单位对齐

**缺点**：
- ⚠️ 错误的设计（gcd ≠ aes_cipher_top）
- ⚠️ 错误的布线（pre-iRT）
- ⚠️ 单位不匹配风险（PF vs FF）
- ⚠️ **不是真正的解决方案**

**适用于**：Phase 1 - 紧急解除 A1 阻塞，验证 SPEF 解析

---

### 方案 2：生成最小 ITF/Captab（需要专家）

**行动**：基于公开 sky130 PDK 数据手动创建简化版

**工作量**：3-5 天（需要 RC 提取专业知识）

**风险**：
- ⚠️ 精度未知（无 StarRC 验证）
- ⚠️ 可能违反 sky130 许可条款
- ⚠️ 仍无法满足 G8 门禁（需要 StarRC 金标准）

---

### 方案 3：获取商业 ITF/Captab 文件

**行动**：
1. 联系 sky130 PDK 维护者获取 StarRC 兼容的 ITF/captab
2. 或者许可 StarRC 并从 sky130 LEF/tech 文件生成

**工作量**：数天到数周（采购/许可）

**优点**：
- ✅ 启用 G8 门禁验证路径
- ✅ 商业级精度

**缺点**：
- ⚠️ 许可成本
- ⚠️ 时间不确定

---

### 方案 4：切换到开源 RC 提取器（OpenRCX）

**行动**：使用 OpenRCX（已有所有 PDK 的 `rcx_patterns.rules`）

**优点**：
- ✅ 文件已存在（sky130/nangate45/asap7）
- ✅ 可立即生成 SPEF
- ✅ 开源，无许可问题

**缺点**：
- ❌ **放弃 iRCX**（agent 任务失败）
- ⚠️ 不同工具 → 不同精度 → 需要单独的 G8 门禁
- ⚠️ 与 iEDA 架构不一致

---

## 推荐路径

### Phase 1（24h）：紧急解除阻塞 ⭐

**使用"错误的 SPEF"临时方案**：
```bash
# 1. 复制 Innovus SPEF
cp /home/lxq/AiEDA/Foundary/sky130/spef/gcd.spef \
   benchmarks/designs/aes_sky130_a/workspace/result/aes_cipher_top.spef

# 2. 修改 iSTA 脚本
cat >> benchmarks/designs/aes_sky130_a/workspace/script/iSTA_script/run_iSTA.tcl <<EOF
# Load SPEF (temporary - wrong design)
read_spef result/aes_cipher_top.spef
EOF

# 3. 重新运行 iSTA
cd benchmarks/designs/aes_sky130_a/workspace
../../../../bin/iEDA -script script/iSTA_script/run_iSTA.tcl
```

**验证**：
- ✅ iSTA 能读取 SPEF（无解析错误）
- ✅ 单位对齐（PF → FF 转换正确）
- ✅ net_delay 不再为 0（即使值不准）

**交付给 Agent A1**：
- "临时 SPEF"路径
- 单位验证报告
- 明确标注：**设计不匹配，仅用于解析测试**

---

### Phase 2（并行）：上报 ITF/Captab 获取

**关键问题（需要用户回答）**：

1. **是否有 StarRC 许可/访问权限？**
   - 如果有 → 可以生成 ITF/captab

2. **是否有 iEDA 联系人持有 sky130 的 ITF/captab？**
   - 可能在 OSCC-Project/iEDA 上游

3. **是否应该短期切换到 OpenRCX？**
   - 立即生成 SPEF，但放弃 iRCX 任务

4. **是否接受"错误的 SPEF"用于 Phase 1？**
   - 仅解除 iSTA 测试阻塞，不用于 QoR

---

### Phase 3（取决于决策）

**如果获取到 ITF/captab**：
1. 集成 iRCX 到 AES13 流程
2. 生成真实 SPEF（post-route DEF）
3. 启动 G8 StarRC 对齐

**如果切换到 OpenRCX**：
1. 修改流程使用 OpenRCX
2. 生成 SPEF
3. 建立 OpenRCX vs StarRC 对齐（新任务）

---

## 给 Agent A1 的状态更新

**阻塞状态**：无法为 AES13 生成 iRCX SPEF（仓库中没有 ITF/captab）

**临时方案可用**：使用现有 `gcd.spef`（来自 Innovus）
- ⚠️ 错误的设计
- ✅ 但可证明 iSTA 能读取 SPEF 并检查单位

**等待主 agent 决策**：ITF/captab 获取策略

---

## 决策矩阵

| 方案 | 时间 | 成本 | 风险 | G8 门禁 | 推荐 |
|------|------|------|------|---------|------|
| **1. 临时 SPEF** | 1h | 低 | 低 | ❌ | ⭐ Phase 1 |
| **2. 手动 ITF/captab** | 3-5天 | 中 | 高 | ⚠️ | ⚠️ 不推荐 |
| **3. 商业 ITF/captab** | 数周 | 高 | 低 | ✅ | ✅ 长期 |
| **4. OpenRCX** | 1天 | 低 | 中 | ⚠️ | ✅ 备选 |

---

## 立即行动

**主 agent 需要决策**：
1. 批准 Phase 1 临时方案（1h）
2. 确认是否有 StarRC 访问权限
3. 决定长期方案（方案 3 或 4）

**Agent A2 当前状态**：等待决策，准备执行 Phase 1

**Agent A1 当前状态**：阻塞，等待任何形式的 SPEF
