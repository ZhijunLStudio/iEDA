#!/usr/bin/env bash
# 在 iEDA.ai 目录中编译 iEDA
set -e

cd /home/lxq/AiEDA/iEDA.ai

export HOME=/home/lxq
export MAMBA_ROOT_PREFIX=/home/lxq/AiEDA/micromamba
eval "$(/home/lxq/.local/bin/micromamba shell hook -s bash)"
micromamba activate ieda-build

export CC CXX
export LIBRARY_PATH="$CONDA_PREFIX/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"

echo "CXX=$CXX"
$CXX --version | head -1

MODE="${1:-build}"

if [ "$MODE" = "clean" ]; then
    echo "=== 清理构建目录 ==="
    rm -rf build

    echo "=== 重新配置 (iEDA, shared libs / BUILD_STATIC_LIB=OFF) ==="
    cmake -S . -B build -G Ninja \
      -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" \
      -DCMAKE_PREFIX_PATH="$CONDA_PREFIX" \
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$PWD/bin" \
      -DCMAKE_BUILD_TYPE=Release -DCMD_BUILD=ON \
      -DBUILD_STATIC_LIB=OFF \
      -DCMAKE_EXE_LINKER_FLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -Wl,-rpath-link,$CONDA_PREFIX/lib" \
      -DCMAKE_SHARED_LINKER_FLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -Wl,-rpath-link,$CONDA_PREFIX/lib"
fi

echo "=== 构建 iEDA ==="
cmake --build build -j"$(nproc)" --target iEDA

BUILD_EXIT=$?
echo "BUILD_EXIT=$BUILD_EXIT"

if [ $BUILD_EXIT -eq 0 ]; then
    ls -lh bin/iEDA
    echo "✓ iEDA 构建成功"
else
    echo "✗ iEDA 构建失败"
    exit 1
fi
