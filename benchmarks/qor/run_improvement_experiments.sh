#!/bin/bash
# ***************************************************************************************
# Copyright (c) 2023-2025 Peng Cheng Laboratory
# Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
# Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
#
# iEDA is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
# http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
#
# See the Mulan PSL v2 for more details.
# ***************************************************************************************
#
# iRT 改进效果对比实验自动化脚本
#
# 运行多组 iRT 改进实验并生成对比报告
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_BASE="$REPO_ROOT/benchmarks/results/improvement_experiments"

DESIGN="aes_sky130_a"
DESIGN_DIR="$REPO_ROOT/benchmarks/designs/$DESIGN"

# 确保输出目录存在
mkdir -p "$OUTPUT_BASE"

# 日志文件
LOG_FILE="$OUTPUT_BASE/experiment_log.txt"
echo "=== iRT Improvement Experiments ===" | tee "$LOG_FILE"
echo "Start time: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 检查设计目录是否存在
if [ ! -d "$DESIGN_DIR" ]; then
    echo "Error: Design directory not found: $DESIGN_DIR" | tee -a "$LOG_FILE"
    exit 1
fi

# 函数：运行单个实验
run_experiment() {
    local exp_id="$1"
    local exp_name="$2"
    shift 2
    local env_vars=("$@")

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Running $exp_id: $exp_name" | tee -a "$LOG_FILE"
    echo "Environment variables:" | tee -a "$LOG_FILE"
    for var in "${env_vars[@]}"; do
        echo "  $var" | tee -a "$LOG_FILE"
    done
    echo "========================================" | tee -a "$LOG_FILE"

    # 设置环境变量
    for var in "${env_vars[@]}"; do
        export "$var"
    done

    # 创建输出目录
    local exp_output="$OUTPUT_BASE/$exp_id"
    mkdir -p "$exp_output"

    # 进入设计工作目录
    cd "$DESIGN_DIR/workspace"

    # 清理之前的结果
    if [ -d "result" ]; then
        rm -rf result.backup 2>/dev/null || true
        mv result result.backup
    fi

    # 运行 iEDA flow
    local start_time=$(date +%s)

    # 注意：这里需要根据实际的运行脚本调整
    # 如果有 run_iEDA.sh，直接调用
    if [ -f "$DESIGN_DIR/run_iEDA.sh" ]; then
        bash "$DESIGN_DIR/run_iEDA.sh" 2>&1 | tee "$exp_output/run.log"
    else
        echo "Warning: run_iEDA.sh not found, trying alternative method" | tee -a "$LOG_FILE"
        # 尝试使用 scripts/design 下的通用脚本
        if [ -f "$REPO_ROOT/scripts/design/sky130_gcd/run_iEDA.sh" ]; then
            bash "$REPO_ROOT/scripts/design/sky130_gcd/run_iEDA.sh" 2>&1 | tee "$exp_output/run.log"
        else
            echo "Error: Cannot find run script for design" | tee -a "$LOG_FILE"
            return 1
        fi
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # 复制结果
    if [ -d "result" ]; then
        cp -r result "$exp_output/workspace/"
    else
        echo "Warning: No result directory generated" | tee -a "$LOG_FILE"
    fi

    # 记录运行时间
    echo "$exp_id completed in ${duration}s" | tee -a "$LOG_FILE"
    echo "$duration" > "$exp_output/wall_time.txt"

    # 清理环境变量
    for var in "${env_vars[@]}"; do
        unset "${var%%=*}"
    done

    echo "" | tee -a "$LOG_FILE"
}

# Baseline (无改进)
run_experiment "baseline" "Baseline (no improvements)" \
    "IEDA_RT_PLACEHOLDER=1"

# E-01: Plateau Detection
run_experiment "E-01" "Plateau Detection" \
    "IEDA_RT_PLATEAU_CHECK_INTERVAL=36" \
    "IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5"

# E-02: Memory Guard
run_experiment "E-02" "Memory Guard" \
    "IEDA_RT_MAX_MEMORY_MB=8192"

# E-03: Box Size 24 (Fixed)
run_experiment "E-03" "Box Size 24 (Fixed)" \
    "IEDA_RT_INITIAL_BOX_SIZE=24" \
    "IEDA_RT_ENABLE_ESCALATION=0"

# E-04: Box Size 48 (Fixed)
run_experiment "E-04" "Box Size 48 (Fixed)" \
    "IEDA_RT_INITIAL_BOX_SIZE=48" \
    "IEDA_RT_ENABLE_ESCALATION=0"

# E-05: Adaptive Size (Auto-detect from utilization)
run_experiment "E-05" "Adaptive Size (Auto)" \
    "IEDA_RT_DESIGN_UTILIZATION=0.65"

# E-06: Escalation 12→24→48
run_experiment "E-06" "Escalation 12→24→48" \
    "IEDA_RT_INITIAL_BOX_SIZE=12" \
    "IEDA_RT_ENABLE_ESCALATION=1"

# E-07: Combined (Plateau + Memory + Adaptive)
run_experiment "E-07" "Combined (01+02+05)" \
    "IEDA_RT_PLATEAU_CHECK_INTERVAL=36" \
    "IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5" \
    "IEDA_RT_MAX_MEMORY_MB=8192" \
    "IEDA_RT_DESIGN_UTILIZATION=0.65"

# 生成对比报告
echo "========================================" | tee -a "$LOG_FILE"
echo "Generating comparison report..." | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

cd "$REPO_ROOT"

python3 benchmarks/qor/compare_improvements.py \
    --experiments "$OUTPUT_BASE" \
    --output "$OUTPUT_BASE/full_comparison_report.md" 2>&1 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "All experiments completed!" | tee -a "$LOG_FILE"
echo "End time: $(date)" | tee -a "$LOG_FILE"
echo "Results: $OUTPUT_BASE" | tee -a "$LOG_FILE"
echo "Report: $OUTPUT_BASE/full_comparison_report.md" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
