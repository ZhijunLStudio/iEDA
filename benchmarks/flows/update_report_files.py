#!/usr/bin/env python3
"""
更新报告添加GDS文件链接（无需KLayout可视化）
"""

from pathlib import Path
import json

def find_gds_and_def_files(design_path):
    """查找设计中的GDS和DEF文件"""
    design_path = Path(design_path)
    result_dir = design_path / "workspace" / "result"

    files = {
        "gds": [],
        "def": []
    }

    # 查找GDS文件
    for gds_file in result_dir.rglob("*.gds"):
        rel_path = gds_file.relative_to(design_path)
        files["gds"].append({
            "path": str(rel_path),
            "name": gds_file.name,
            "size_mb": gds_file.stat().st_size / (1024 * 1024),
            "stage": "CTS" if "cts" in str(gds_file) else "Unknown"
        })

    # 查找DEF文件
    for def_file in result_dir.glob("*.def"):
        rel_path = def_file.relative_to(design_path)
        stage_name = def_file.stem.replace("_result", "").replace("i", "")
        files["def"].append({
            "path": str(rel_path),
            "name": def_file.name,
            "size_mb": def_file.stat().st_size / (1024 * 1024),
            "stage": stage_name.upper()
        })

    return files

def update_report_with_files(design_path):
    """更新报告添加文件信息"""
    design_path = Path(design_path)
    report_file = design_path / "workspace" / "result" / "stage_report.md"

    if not report_file.exists():
        print(f"  ⚠️ 报告文件不存在")
        return False

    files = find_gds_and_def_files(design_path)

    # 读取现有报告
    with open(report_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 添加文件信息部分
    files_section = "\n---\n\n## 生成的文件\n\n"

    # DEF文件
    if files["def"]:
        files_section += "### DEF文件（布局定义）\n\n"
        files_section += "| 阶段 | 文件名 | 大小 | 路径 |\n"
        files_section += "|------|--------|------|------|\n"

        for def_file in sorted(files["def"], key=lambda x: x["name"]):
            files_section += f"| {def_file['stage']} | `{def_file['name']}` | {def_file['size_mb']:.2f} MB | `{def_file['path']}` |\n"

        files_section += "\n"

    # GDS文件
    if files["gds"]:
        files_section += "### GDS文件（版图数据）\n\n"
        files_section += "| 阶段 | 文件名 | 大小 | 路径 |\n"
        files_section += "|------|--------|------|------|\n"

        for gds_file in files["gds"]:
            files_section += f"| {gds_file['stage']} | `{gds_file['name']}` | {gds_file['size_mb']:.2f} MB | `{gds_file['path']}` |\n"

        files_section += "\n**注意**: GDS文件可使用KLayout、Magic等工具查看\n\n"

    # 查看命令
    files_section += "### 查看命令\n\n"
    files_section += "```bash\n"
    files_section += "# 使用KLayout查看GDS（需要显示环境）\n"
    if files["gds"]:
        files_section += f"klayout {files['gds'][0]['path']}\n\n"
    files_section += "# 使用iEDA查看DEF\n"
    if files["def"]:
        files_section += f"./iEDA -gui {files['def'][-1]['path']}\n"
    files_section += "```\n\n"

    # 在报告末尾添加（如果还没有）
    if "生成的文件" not in content:
        content = content.rstrip() + "\n" + files_section

    # 写回报告
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"  ✓ 已添加 {len(files['def'])} 个DEF文件和 {len(files['gds'])} 个GDS文件信息")
    return True

def main():
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 update_report_files.py <design_path> [<design_path2> ...]")
        sys.exit(1)

    design_paths = sys.argv[1:]

    print("=" * 60)
    print("更新报告 - 添加文件信息")
    print("=" * 60)
    print()

    for design_path in design_paths:
        design_name = Path(design_path).name
        print(f"处理: {design_name}")
        update_report_with_files(design_path)
        print()

    print("=" * 60)
    print("完成!")
    print("=" * 60)

if __name__ == "__main__":
    main()
