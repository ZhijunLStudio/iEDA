#!/usr/bin/env python3
"""
使用KLayout将GDS文件转换为PNG图片
并生成包含可视化的报告
"""

import subprocess
import os
from pathlib import Path
import json

def find_gds_files(design_path):
    """查找设计中的所有GDS文件"""
    design_path = Path(design_path)
    result_dir = design_path / "workspace" / "result"

    gds_files = []

    # 查找所有GDS文件
    for gds_file in result_dir.rglob("*.gds"):
        gds_files.append(gds_file)

    return gds_files

def gds_to_png(gds_file, output_png, width=1200, height=1200):
    """使用KLayout将GDS转换为PNG"""

    # 创建KLayout脚本
    script_content = f"""
import pya

# 加载GDS
layout = pya.Layout()
layout.read("{gds_file}")

# 创建布局视图
layout_view = pya.LayoutView()
layout_view.load_layout(str("{gds_file}"), 0)

# 设置视图
layout_view.max_hier()
layout_view.zoom_fit()

# 导出PNG
layout_view.save_image("{output_png}", {width}, {height})

print("PNG exported: {output_png}")
"""

    # 写入临时脚本
    script_file = Path("/tmp/klayout_export.py")
    with open(script_file, 'w') as f:
        f.write(script_content)

    # 运行KLayout（无头模式）
    try:
        env = os.environ.copy()
        env['QT_QPA_PLATFORM'] = 'offscreen'

        result = subprocess.run(
            ["klayout", "-b", "-z", "-r", str(script_file)],
            capture_output=True,
            text=True,
            timeout=60,
            env=env
        )

        if result.returncode == 0:
            print(f"✓ 生成PNG: {output_png}")
            return True
        else:
            print(f"✗ KLayout错误: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print(f"✗ KLayout超时")
        return False
    except Exception as e:
        print(f"✗ 错误: {e}")
        return False

def generate_gds_visualization(design_path):
    """为设计生成GDS可视化"""
    design_path = Path(design_path)
    design_name = design_path.name

    print(f"处理设计: {design_name}")

    # 查找GDS文件
    gds_files = find_gds_files(design_path)

    if not gds_files:
        print(f"  ⚠️ 未找到GDS文件")
        return []

    print(f"  找到 {len(gds_files)} 个GDS文件")

    # 创建输出目录
    output_dir = design_path / "workspace" / "result" / "visualizations"
    output_dir.mkdir(exist_ok=True)

    generated_images = []

    for gds_file in gds_files:
        # 确定输出文件名
        gds_name = gds_file.stem
        output_png = output_dir / f"{gds_name}.png"

        print(f"  转换: {gds_file.name} -> {output_png.name}")

        if gds_to_png(gds_file, output_png):
            generated_images.append({
                "gds_file": str(gds_file.relative_to(design_path)),
                "png_file": str(output_png.relative_to(design_path)),
                "name": gds_name
            })

    return generated_images

def update_report_with_images(design_path, images):
    """更新报告添加图片"""
    design_path = Path(design_path)
    report_file = design_path / "workspace" / "result" / "stage_report.md"

    if not report_file.exists():
        print(f"  ⚠️ 报告文件不存在: {report_file}")
        return

    # 读取现有报告
    with open(report_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 添加可视化部分
    viz_section = "\n---\n\n## 布局可视化\n\n"

    for img in images:
        viz_section += f"### {img['name']}\n\n"
        viz_section += f"![{img['name']}]({img['png_file']})\n\n"
        viz_section += f"*GDS文件: `{img['gds_file']}`*\n\n"

    # 在报告末尾添加
    if "布局可视化" not in content:
        content = content.rstrip() + "\n" + viz_section

    # 写回报告
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"  ✓ 报告已更新")

def main():
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 generate_gds_visualization.py <design_path> [<design_path2> ...]")
        print("Example: python3 generate_gds_visualization.py /path/to/designs/aes_sky130_a")
        sys.exit(1)

    design_paths = sys.argv[1:]

    print("=" * 60)
    print("GDS可视化生成工具")
    print("=" * 60)
    print()

    for design_path in design_paths:
        images = generate_gds_visualization(design_path)

        if images:
            update_report_with_images(design_path, images)
            print(f"  ✓ 生成了 {len(images)} 张图片\n")
        else:
            print(f"  ✗ 未生成图片\n")

    print("=" * 60)
    print("完成!")
    print("=" * 60)

if __name__ == "__main__":
    main()
