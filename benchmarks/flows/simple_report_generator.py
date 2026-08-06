#!/usr/bin/env python3
"""
简化的报告生成器 - 从现有结果生成对比报告
"""

import json
import sys
from pathlib import Path
from datetime import datetime

def generate_simple_report(result_root: Path, output_file: Path):
    """生成简化的对比报告"""

    result_root = Path(result_root)
    output_file = Path(output_file)
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # 查找所有设计
    designs = sorted([d for d in result_root.iterdir() if d.is_dir() and not d.name.startswith('.')])

    print(f"找到 {len(designs)} 个设计")

    report_lines = []
    report_lines.append(f"# iEDA 物理设计流程对比报告")
    report_lines.append(f"")
    report_lines.append(f"生成时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report_lines.append(f"结果目录：{result_root}")
    report_lines.append(f"")
    report_lines.append(f"## 1. 执行摘要")
    report_lines.append(f"")
    report_lines.append(f"- 总设计数：{len(designs)}")
    report_lines.append(f"- 设计列表：{', '.join([d.name for d in designs])}")
    report_lines.append(f"")

    # 统计表格
    report_lines.append(f"## 2. 设计对比表")
    report_lines.append(f"")
    report_lines.append(f"| 设计名称 | 状态 | DEF文件 | GDS文件 | 报告文件 | 结果目录 |")
    report_lines.append(f"|---------|------|---------|---------|----------|----------|")

    for design_dir in designs:
        design_name = design_dir.name
        workspace = design_dir / "workspace"
        result_dir = workspace / "result"

        # 统计文件
        def_count = len(list(result_dir.glob("**/*.def"))) if result_dir.exists() else 0
        gds_count = len(list(result_dir.glob("**/*.gds"))) if result_dir.exists() else 0
        rpt_count = len(list(result_dir.glob("**/*.rpt"))) if result_dir.exists() else 0

        status = "✓ 完成" if def_count > 0 else "✗ 未完成"

        report_lines.append(
            f"| {design_name} | {status} | {def_count} | {gds_count} | {rpt_count} | `{result_dir.relative_to(result_root)}` |"
        )

    report_lines.append(f"")

    # 详细信息
    report_lines.append(f"## 3. 详细信息")
    report_lines.append(f"")

    for design_dir in designs:
        design_name = design_dir.name
        workspace = design_dir / "workspace"
        result_dir = workspace / "result"

        report_lines.append(f"### {design_name}")
        report_lines.append(f"")

        if result_dir.exists():
            # 列出关键文件
            def_files = sorted(result_dir.glob("**/*.def"))
            if def_files:
                report_lines.append(f"**DEF文件** ({len(def_files)}个):")
                for f in def_files[:10]:  # 最多显示10个
                    report_lines.append(f"- `{f.relative_to(result_dir)}`")
                if len(def_files) > 10:
                    report_lines.append(f"- ... (还有 {len(def_files) - 10} 个)")
                report_lines.append(f"")

            gds_files = sorted(result_dir.glob("**/*.gds"))
            if gds_files:
                report_lines.append(f"**GDS文件** ({len(gds_files)}个):")
                for f in gds_files:
                    report_lines.append(f"- `{f.relative_to(result_dir)}`")
                report_lines.append(f"")

            # 检查关键目录
            key_dirs = ['sta', 'power', 'drc', 'density_map', 'visualizations']
            existing_dirs = [d for d in key_dirs if (result_dir / d).exists()]
            if existing_dirs:
                report_lines.append(f"**可用目录**: {', '.join(existing_dirs)}")
                report_lines.append(f"")
        else:
            report_lines.append(f"*结果目录不存在*")
            report_lines.append(f"")

    # 写入文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(report_lines))

    print(f"✓ 报告已生成: {output_file}")
    return output_file

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("用法: python3 simple_report_generator.py <result_root> <output_file>")
        sys.exit(1)

    result_root = Path(sys.argv[1])
    output_file = Path(sys.argv[2])

    generate_simple_report(result_root, output_file)
