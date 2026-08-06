#!/usr/bin/env python3
"""
运行单个设计的完整流程并生成详细报告
使用现有的 aes13_flow.py 基础设施
"""

import sys
import subprocess
import argparse
from pathlib import Path
from datetime import datetime

BENCHMARK_ROOT = Path(__file__).resolve().parents[1]
AES13_FLOW = BENCHMARK_ROOT / "flows" / "aes13_flow.py"
REPORT_GEN = BENCHMARK_ROOT / "flows" / "generate_aes11_detailed_report.py"

def run_design(design_name: str, output_dir: Path = None):
    """运行单个设计的完整流程"""

    if output_dir is None:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_dir = BENCHMARK_ROOT / "results" / f"run_{design_name}_{timestamp}"

    print(f"\n{'='*80}")
    print(f"运行设计: {design_name}")
    print(f"输出目录: {output_dir}")
    print(f"{'='*80}\n")

    # 运行物理设计流程
    cmd = [
        sys.executable,
        str(AES13_FLOW),
        "--designs", design_name,
        "--output-root", str(output_dir),
        "--skip-synthesis",  # 假设已有网表
    ]

    print("🚀 启动物理设计流程...")
    print(f"命令: {' '.join(cmd)}\n")

    try:
        result = subprocess.run(cmd, check=True)
        print(f"\n✓ 流程完成")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n✗ 流程失败: {e}")
        return False

def generate_report(designs: list[str], output_file: Path = None):
    """生成详细对比报告"""

    if output_file is None:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = BENCHMARK_ROOT / "reports" / f"comparison_{timestamp}.md"

    output_file.parent.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*80}")
    print(f"生成对比报告")
    print(f"报告文件: {output_file}")
    print(f"{'='*80}\n")

    cmd = [
        sys.executable,
        str(REPORT_GEN),
        "--output", str(output_file)
    ]

    try:
        result = subprocess.run(cmd, check=True)
        print(f"\n✓ 报告生成完成: {output_file}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n✗ 报告生成失败: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='运行完整物理设计流程并生成详细报告'
    )
    parser.add_argument(
        '--design',
        required=True,
        help='设计名称 (如 gcd_sky130_a, aes_sky130_a)'
    )
    parser.add_argument(
        '--output-dir',
        type=Path,
        help='输出目录'
    )
    parser.add_argument(
        '--report',
        type=Path,
        help='报告输出文件路径'
    )
    parser.add_argument(
        '--skip-run',
        action='store_true',
        help='跳过流程运行，仅生成报告'
    )

    args = parser.parse_args()

    # 运行流程
    if not args.skip_run:
        success = run_design(args.design, args.output_dir)
        if not success:
            print("\n流程运行失败，退出")
            return 1

    # 生成报告
    success = generate_report([args.design], args.report)
    if not success:
        print("\n报告生成失败")
        return 1

    print(f"\n{'='*80}")
    print(f"✓ 全部完成")
    print(f"{'='*80}\n")
    return 0

if __name__ == '__main__':
    sys.exit(main())
