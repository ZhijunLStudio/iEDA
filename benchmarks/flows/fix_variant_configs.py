#!/usr/bin/env python3
"""
修复所有AES设计的PDK variant配置
将配置中的variant与netlist中实际使用的variant匹配
"""

import json
import re
import os
from pathlib import Path

DESIGNS_DIR = Path("/home/lxq/AiEDA/iEDA.ai/benchmarks/designs")

# 需要修复的设计列表
DESIGNS = [
    "aes_sky130_a",
    "aes_sky130_b",
    "aes_sky130_t",
    "aes_nangate45_a",
    "aes_nangate45_b",
    "aes_nangate45_t",
    "aes_asap7_a",
    "aes_asap7_b",
    "aes_asap7_t",
    "aes_ics55_a",
    "aes_ics55_b",
    "aes_ics55_t",
    "aes_core_sky130_a"
]

def detect_variant_from_netlist(netlist_path):
    """从netlist中检测实际使用的variant"""
    try:
        with open(netlist_path, 'r') as f:
            content = f.read(10000)  # 只读前10000字节

        # 查找库variant
        # sky130: sky130_fd_sc_hd, sky130_fd_sc_hs, etc.
        # nangate45: NangateOpenCellLibrary
        # asap7: asap7sc7p5t
        # ics55: ics55

        patterns = {
            'sky130': r'sky130_fd_sc_([a-z]+)__',
            'nangate45': r'(NangateOpenCellLibrary)',
            'asap7': r'(asap7sc[^_\s]+)',
            'ics55': r'(ics55)'
        }

        for pdk, pattern in patterns.items():
            match = re.search(pattern, content)
            if match:
                return match.group(1)

        return None
    except Exception as e:
        print(f"Error reading {netlist_path}: {e}")
        return None

def fix_design_config(design_name):
    """修复单个设计的配置"""
    design_dir = DESIGNS_DIR / design_name
    config_file = design_dir / "design.json"
    netlist_file = design_dir / "netlist" / "aes.v"

    if not config_file.exists():
        print(f"❌ {design_name}: design.json not found")
        return False

    if not netlist_file.exists():
        print(f"❌ {design_name}: netlist not found")
        return False

    # 读取配置
    with open(config_file, 'r') as f:
        config = json.load(f)

    # 检测netlist中的variant
    detected_variant = detect_variant_from_netlist(netlist_file)
    if not detected_variant:
        print(f"⚠️  {design_name}: Could not detect variant from netlist")
        return False

    current_variant = config.get('variant', 'unknown')
    pdk = config.get('pdk', 'unknown')

    # 对于sky130，需要更新variant和相关路径
    if pdk == 'sky130' and detected_variant != current_variant:
        print(f"🔧 {design_name}: Fixing variant {current_variant} -> {detected_variant}")

        config['variant'] = detected_variant

        # 更新输入文件路径
        if 'inputs' in config:
            for key, path in config['inputs'].items():
                if isinstance(path, str):
                    # 替换variant
                    old_pattern = f"sky130_fd_sc_{current_variant}"
                    new_pattern = f"sky130_fd_sc_{detected_variant}"
                    config['inputs'][key] = path.replace(old_pattern, new_pattern)

        # 保存修复后的配置
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)

        print(f"✓ {design_name}: Config updated")
        return True
    elif pdk == 'sky130':
        print(f"✓ {design_name}: Already correct ({detected_variant})")
        return True
    else:
        # 其他PDK暂时跳过
        print(f"→ {design_name}: PDK {pdk}, variant {detected_variant}")
        return True

def main():
    print("="*60)
    print("修复AES设计的PDK variant配置")
    print("="*60)
    print()

    fixed_count = 0
    for design in DESIGNS:
        if fix_design_config(design):
            fixed_count += 1
        print()

    print("="*60)
    print(f"完成! 处理了 {fixed_count}/{len(DESIGNS)} 个设计")
    print("="*60)

if __name__ == "__main__":
    main()
