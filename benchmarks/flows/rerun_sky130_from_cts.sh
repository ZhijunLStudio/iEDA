#!/bin/bash
# 从CTS阶段重新运行sky130设计

DESIGNS=("aes_sky130_b" "aes_sky130_t" "aes_core_sky130_a")
BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"

for design in "${DESIGNS[@]}"; do
    echo "=========================================="
    echo "重新运行: $design (从CTS开始)"
    echo "=========================================="

    WORKSPACE="$BENCHMARK_ROOT/designs/$design/workspace"
    cd "$WORKSPACE"

    # 设置环境变量
    export CONFIG_DIR="$WORKSPACE/iEDA_config"
    export RESULT_DIR="$WORKSPACE/result"
    export TCL_SCRIPT_DIR="$WORKSPACE/script"
    export FOUNDRY_DIR="/home/lxq/AiEDA/Foundary/sky130"

    # 从CTS开始运行
    echo ">>> Running iCTS..."
    $BENCHMARK_ROOT/../bin/iEDA -script script/iCTS_script/run_iCTS.tcl 2>&1 | tee -a "$RESULT_DIR/iCTS_rerun.log"

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "✓ iCTS 完成"

        # 继续运行后续阶段...
        echo ">>> Running iTO (DRV)..."
        $BENCHMARK_ROOT/../bin/iEDA -script script/iTO_script/run_iTO_drv.tcl 2>&1 | tee "$RESULT_DIR/iTO_drv_rerun.log"

        echo ">>> Running iTO (Hold)..."
        $BENCHMARK_ROOT/../bin/iEDA -script script/iTO_script/run_iTO_hold.tcl 2>&1 | tee "$RESULT_DIR/iTO_hold_rerun.log"

        echo "✓ $design 完成"
    else
        echo "✗ $design CTS失败"
    fi

    echo ""
done

echo "重新运行完成!"
