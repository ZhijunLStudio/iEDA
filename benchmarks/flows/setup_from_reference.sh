#!/bin/bash
# 基于参考 gcd 脚本设置 AES 运行环境

set -e

DESIGN=$1
if [ -z "$DESIGN" ]; then
    echo "用法: $0 <design_name>"
    exit 1
fi

BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"
DESIGN_DIR="$BENCHMARK_ROOT/designs/$DESIGN"
WORKSPACE="$DESIGN_DIR/workspace"
REFERENCE="/home/lxq/AiEDA/iEDA.ai/scripts/design/sky130_gcd"

if [ ! -d "$DESIGN_DIR" ]; then
    echo "错误: 设计目录不存在: $DESIGN_DIR"
    exit 1
fi

echo "设置设计: $DESIGN"
echo "工作空间: $WORKSPACE"

# 创建工作空间
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# 复制参考脚本
echo "  复制参考脚本..."
cp -r "$REFERENCE/script" .
cp -r "$REFERENCE/iEDA_config" .

# 复制 iEDA 二进制到工作空间
ln -sf /home/lxq/AiEDA/iEDA.ai/bin/iEDA ./iEDA

# 创建结果目录
mkdir -p result

echo "✓ 设置完成"
echo ""
echo "下一步:"
echo "  cd $WORKSPACE"
echo "  export DESIGN_TOP=<top_module>"
echo "  export NETLIST_FILE=<netlist_path>"
echo "  ./iEDA -script script/iFP_script/run_iFP.tcl"

