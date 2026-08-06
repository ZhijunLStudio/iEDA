#!/usr/bin/env python3
"""
快速创建不同利用率的 workspace（从 65% 复制）
"""

from pathlib import Path
import shutil
import sys

REPO_ROOT = Path("/home/lxq/AiEDA/iEDA.ai")

def setup_workspace(design_name: str, util_pct: int):
    """从 65% workspace 复制到目标利用率目录"""
    src_base = REPO_ROOT / f"benchmarks/results/aes13_65pct/{design_name}/workspace"
    dst_base = REPO_ROOT / f"benchmarks/results/aes13_{util_pct}pct/{design_name}/workspace"

    if not src_base.exists():
        print(f"✗ Source workspace not found: {src_base}")
        return False

    if dst_base.exists():
        print(f"  [workspace] already exists: {dst_base.relative_to(REPO_ROOT)}")
        return True

    print(f"  [workspace] copying from 65% to {util_pct}%", flush=True)

    # 复制 script 和 iEDA_config
    dst_base.mkdir(parents=True, exist_ok=True)

    shutil.copytree(src_base / "script", dst_base / "script", dirs_exist_ok=True)
    shutil.copytree(src_base / "iEDA_config", dst_base / "iEDA_config", dirs_exist_ok=True)

    # 创建 result 目录
    result_dir = dst_base / "result"
    for subdir in ("logs", "report/drc", "drc", "timing", "power", "visualizations"):
        (result_dir / subdir).mkdir(parents=True, exist_ok=True)

    print(f"  [workspace] ✓ created: {dst_base.relative_to(REPO_ROOT)}")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: setup_util_workspace.py <util_pct> <design1> [design2 ...]")
        sys.exit(1)

    util_pct = int(sys.argv[1])
    designs = sys.argv[2:]

    print(f"\nSetting up workspaces for {util_pct}% utilization...")
    success = 0
    for design in designs:
        if setup_workspace(design, util_pct):
            success += 1

    print(f"\n✓ {success}/{len(designs)} workspaces ready\n")
