# 批量运行状态报告

**时间**: 2026-07-23 00:15
**状态**: 🔄 批量运行进行中

---

## 当前进度

### 已完成
- ✅ **aes_sky130_a** - 6/7阶段完成（routing可能仍在进行）

### 进行中
- 🔄 **aes_sky130_b** - 1/7阶段（Floorplan完成）
- 🔄 **aes_sky130_t** - 1/7阶段（Floorplan完成）
- 🔄 **aes_core_sky130_a** - 1/7阶段（Floorplan完成）

### 等待运行
- ⏳ aes_nangate45_a/b/t (3个)
- ⏳ aes_asap7_a/b/t (3个)
- ⏳ aes_ics55_a/b/t (3个)

---

## 已完成的工作

### 1. 工具修复 ✅
- iPL除零错误（SIGFPE）已修复
- 重新编译iEDA

### 2. 配置修复 ✅
所有13个设计已完成PDK配置：
- Site定义自动配置
- Buffer类型自动配置
- LEF/LIB路径自动配置

### 3. 工具创建 ✅
- `configure_pdk.py` - PDK配置工具
- `generate_stage_report.py` - 阶段报告生成工具
- `monitor_batch.sh` - 进度监控脚本
- `run_all_aes_with_config.sh` - 批量运行脚本

### 4. 单个设计验证 ✅
**aes_sky130_a** 成功完成7个阶段：
1. ✅ Floorplan - 29,254实例，640,000 um²
2. ✅ Placement - 33%利用率
3. ✅ Clock Tree - 2,987 sinks, 184 buffers
4. ✅ Timing Opt (DRV)
5. ✅ Timing Opt (Hold)
6. ✅ Legalization
7. 🔄 Routing - 151,008通孔（可能仍在进行）

---

## 预计完成时间

- **单个设计**: ~10-15分钟
- **13个设计顺序运行**: ~2-3小时
- **当前已运行**: ~1分钟
- **预计剩余**: ~2.5小时

---

## 监控命令

实时监控进度：
```bash
watch -n 30 'bash /home/lxq/AiEDA/iEDA.ai/benchmarks/flows/monitor_batch.sh'
```

查看详细日志：
```bash
tail -f /tmp/batch_all_aes.log
```

---

## 完成后自动生成

批量运行完成后将自动生成：
1. 每个设计的阶段报告（`stage_report.md`）
2. 所有设计的对比分析报告（待生成）
3. JSON格式数据（`stage_report.json`）

---

**状态**: 批量运行正在后台进行，无需人工干预
**日志**: `/tmp/batch_all_aes.log`
