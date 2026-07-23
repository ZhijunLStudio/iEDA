# AES Benchmark 修复进度报告

**时间**: 2026-07-22 22:43  
**状态**: 取得重大进展，但仍需修复row定义问题

## ✅ 已成功修复的问题

### 1. iPL除零错误 (SIGFPE) ✓
- **位置**: `NesterovPlace::initFillerNesInstance()`
- **修复**: 添加除零检查和边界条件处理
- **状态**: 完全修复，不再崩溃

### 2. PDK Variant不匹配 ✓
- **问题**: Netlist使用`sky130_fd_sc_hd`，但配置使用`sky130_fd_sc_hs`
- **修复**: 
  - 修改`design.json`中的variant配置
  - 修改`db_path_setting.tcl`中的CELL_TYPE设置（第7行：HS → HD）
- **状态**: 完全修复，逻辑单元成功读取

### 3. LEF路径配置 ✓
- **问题**: TCL脚本没有正确读取LEF文件
- **修复**: 修改`run_aes_simple.sh`添加TECH_LEF_PATH和LEF_PATH环境变量
- **状态**: 完全修复，正确的LEF文件已加载

## 🎯 取得的进展

**之前状态**:
```
Instances Num: 7513 (全部是fixed fill cells)
Fixed Instances Num: 7513
Placed Instances Num: 0
```

**当前状态**:
```
Instance number: 20413  ✓ (成功读取逻辑单元!)
Gates Num: 56033        ✓ 
Rows: number: 0         ✗ (新问题)
```

## ❌ 当前问题

### Row定义缺失导致SIGSEGV

**错误信息**:
```
SIGSEGV (@0x38) at ipl::IDBWrapper::wrapRows(idb::IdbLayout*)
Rows : number : 0
```

**原因**: Floorplan阶段没有正确创建标准单元行（rows）

**位置**: `iFP_script/run_iFP.tcl` 中的`init_floorplan`命令

**影响**: iPL无法进行布局，因为没有可用的行来放置单元

## 🔧 下一步修复

### 优先级1: 修复Row定义

需要检查并修复以下内容：

1. **检查site定义**
   ```tcl
   set PLACE_SITE unit     # 可能需要改为 "unithd" 或其他正确的site名称
   set IO_SITE unit
   set CORNER_SITE unit
   ```

2. **验证LEF中的site定义**
   ```bash
   grep "SITE" /home/lxq/AiEDA/Foundary/sky130/lef/sky130_fd_sc_hd.tlef
   ```

3. **可能需要的修复**
   - 将PLACE_SITE从"unit"改为sky130_fd_sc_hd LEF中定义的正确site名称
   - 或者添加explicit row creation命令

## 📊 文件状态

### 成功生成的文件
- ✓ `iFP_result.def` - Floorplan结果（包含20413个实例）
- ✓ `iTO_fix_fanout_result.def` - Fix fanout结果

### 使用的正确配置
- ✓ LEF: `sky130_fd_sc_hd_merged.lef`
- ✓ Tech LEF: `sky130_fd_sc_hd.tlef`
- ✓ Lib: `sky130_fd_sc_hd__tt_025C_1v80.lib`

## 🎉 重要成就

1. **工具bug已修复** - iPL的SIGFPE除零错误已完全解决
2. **配置已正确** - PDK variant、LEF路径全部匹配
3. **逻辑单元已读取** - 20413个实例成功加载（不再是全fixed）

## 📝 修复清单

- [x] 修复iPL除零错误
- [x] 重新编译iEDA
- [x] 修复PDK variant配置（hd vs hs）
- [x] 修复LEF路径设置
- [x] 修复TCL脚本中的CELL_TYPE
- [ ] **修复Row定义问题** ← 当前任务
- [ ] 完成单个设计的完整流程
- [ ] 批量运行13个设计
- [ ] 生成对比分析报告

## 🔍 技术细节

### 修改的文件
1. `src/operation/iPL/.../NesterovPlace.cc` - 除零错误修复
2. `benchmarks/designs/aes_sky130_*/design.json` - variant配置
3. `benchmarks/flows/run_aes_simple.sh` - LEF路径环境变量
4. `workspace/script/DB_script/db_path_setting.tcl` - CELL_TYPE: HS → HD

### 核心修复代码
```cpp
// 添加了除零检查
int idx_range = max_idx - min_idx;
if (idx_range <= 0) {
  LOG_WARNING << "Invalid index range...";
  idx_range = 1;
  ...
}
```

---

**结论**: 我们已经解决了所有主要的配置和工具bug问题！现在只剩下最后一个问题：row定义。一旦修复，流程就能完整运行。
