#!/bin/bash
# 为所有25个AES设计生成完整报告汇总

DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"
OUTPUT_FILE="/home/lxq/AiEDA/iEDA.ai/docs/logs/2026-07-23-ALL-25-DESIGNS-REPORT.md"

cat > "$OUTPUT_FILE" << 'EOF'
# 所有25个AES设计完整报告

**生成时间**: 2026-07-23 08:00
**设计总数**: 25

---

## 设计列表和状态

EOF

for design in $(ls "$DESIGNS_DIR" | grep "^aes" | sort); do
    echo "处理: $design"

    RESULT_DIR="$DESIGNS_DIR/$design/workspace/result"

    # 统计DEF文件
    if [ -d "$RESULT_DIR" ]; then
        def_count=$(ls "$RESULT_DIR"/*.def 2>/dev/null | wc -l)
        gds_count=$(find "$RESULT_DIR" -name "*.gds*" 2>/dev/null | wc -l)

        # 检查各阶段
        stages=""
        [ -f "$RESULT_DIR/iFP_result.def" ] && stages="${stages}FP,"
        [ -f "$RESULT_DIR/iPL_result.def" ] && stages="${stages}PL,"
        [ -f "$RESULT_DIR/iCTS_result.def" ] && stages="${stages}CTS,"
        [ -f "$RESULT_DIR/iTO_drv_result.def" ] && stages="${stages}TO,"
        [ -f "$RESULT_DIR/iPL_lg_result.def" ] && stages="${stages}LG,"
        [ -f "$RESULT_DIR/iRT_result.def" ] && stages="${stages}RT,"

        stages=${stages%,}

        cat >> "$OUTPUT_FILE" << DESIGNEOF

### $design
- **DEF文件**: ${def_count}个
- **GDS文件**: ${gds_count}个
- **完成阶段**: ${stages:-未运行}
- **报告**: [stage_report.md](../../benchmarks/designs/$design/workspace/result/stage_report.md)

DESIGNEOF
    else
        cat >> "$OUTPUT_FILE" << DESIGNEOF

### $design
- **状态**: 未配置/未运行
- **路径**: benchmarks/designs/$design

DESIGNEOF
    fi
done

cat >> "$OUTPUT_FILE" << 'EOF'

---

## 生成时间
2026-07-23 08:00

EOF

echo "✓ 报告已生成: $OUTPUT_FILE"
