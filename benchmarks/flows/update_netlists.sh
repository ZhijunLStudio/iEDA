#!/bin/bash
# 更新nangate45和ics55设计使用新的netlist

SYNTHESIS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/synthesis"
DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"

echo "=========================================="
echo "更新nangate45和ics55设计的netlist"
echo "=========================================="
echo ""

# 更新nangate45设计
for design in aes_nangate45_a aes_nangate45_b aes_nangate45_t; do
    echo "更新 $design..."

    # 备份原始netlist
    if [ -f "$DESIGNS_DIR/$design/netlist/aes.v" ]; then
        cp "$DESIGNS_DIR/$design/netlist/aes.v" "$DESIGNS_DIR/$design/netlist/aes.v.bak"
    fi

    # 复制新的netlist
    cp "$SYNTHESIS_DIR/aes_nangate45.v" "$DESIGNS_DIR/$design/netlist/aes_cipher_top.v"

    # 更新design.json中的top模块
    cd "$DESIGNS_DIR/$design"
    if [ -f "design.json" ]; then
        # 备份
        cp design.json design.json.bak

        # 更新top模块名和netlist路径
        python3 << 'EOF'
import json
with open("design.json", "r") as f:
    config = json.load(f)
config["top"] = "aes_cipher_top"
config["inputs"]["netlist"] = "netlist/aes_cipher_top.v"
with open("design.json", "w") as f:
    json.dump(config, f, indent=2)
EOF
        echo "  ✓ Updated $design/design.json"
    fi
done

echo ""

# 更新ics55设计
for design in aes_ics55_a aes_ics55_b aes_ics55_t; do
    echo "更新 $design..."

    # 备份原始netlist
    if [ -f "$DESIGNS_DIR/$design/netlist/aes.v" ]; then
        cp "$DESIGNS_DIR/$design/netlist/aes.v" "$DESIGNS_DIR/$design/netlist/aes.v.bak"
    fi

    # 复制新的netlist
    cp "$SYNTHESIS_DIR/aes_ics55.v" "$DESIGNS_DIR/$design/netlist/aes_cipher_top.v"

    # 更新design.json中的top模块
    cd "$DESIGNS_DIR/$design"
    if [ -f "design.json" ]; then
        # 备份
        cp design.json design.json.bak

        # 更新top模块名和netlist路径
        python3 << 'EOF'
import json
with open("design.json", "r") as f:
    config = json.load(f)
config["top"] = "aes_cipher_top"
config["inputs"]["netlist"] = "netlist/aes_cipher_top.v"
with open("design.json", "w") as f:
    json.dump(config, f, indent=2)
EOF
        echo "  ✓ Updated $design/design.json"
    fi
done

echo ""
echo "=========================================="
echo "Netlist更新完成！"
echo "=========================================="
