# AES设计完整阶段报告

**生成时间**: 2026-07-23 07:23:14
**设计**: aes_sky130_a

---

## 流程总览

| 阶段 | 状态 | 输出文件 |
|------|------|----------|
| Floorplan (iFP) | ✅ Completed | ✓ iFP_result.def |
| Placement (iPL) | ✅ Completed | ✓ iPL_result.def |
| Clock Tree Synthesis (iCTS) | ✅ Completed | ✓ iCTS_result.def |
| Timing Optimization - Drive (iTO) | ✅ Completed | ✓ iTO_drv_result.def |
| Timing Optimization - Hold (iTO) | ✅ Completed | ✓ iTO_hold_result.def |
| Legalization (iPL) | ✅ Completed | ✓ iPL_lg_result.def |
| Routing (iRT) | 🔄 In Progress / Completed | ✗ iRT_result.def |

---

## 各阶段详细结果

### Floorplan (iFP)

**状态**: Completed

**关键指标**:

- **Die Area Um2**: 640,000.00
- **Die Width Um**: 800.00
- **Die Height Um**: 800.00
- **Total Instances**: 29,254
- **Logic Instances**: 20,413

### Placement (iPL)

**状态**: Completed

**关键指标**:

- **Total Instances**: 29,254
- **Total Nets**: 22,342
- **Die Usage**: 0.33

### Clock Tree Synthesis (iCTS)

**状态**: Completed

**关键指标**:

- **Sink Count**: 2,987
- **Buffer Count**: 184
- **Buffer Area Um2**: 729.45
- **Total Wirelength Um**: 28,876.72
- **Max Wirelength Um**: 368.61
- **Elapsed Time S**: 8.67

### Timing Optimization - Drive (iTO)

**状态**: Completed

**关键指标**:

- **Total Instances**: 29,439

### Timing Optimization - Hold (iTO)

**状态**: Completed

**关键指标**:

- **Total Instances**: 29,439

### Legalization (iPL)

**状态**: Completed

**关键指标**:

- **Total Instances**: 29,439

### Routing (iRT)

**状态**: In Progress / Completed

**关键指标**:

- **Total Vias**: 151,008
- **Violations**: 24,171

---

*报告生成时间: 2026-07-23 07:23:14*
