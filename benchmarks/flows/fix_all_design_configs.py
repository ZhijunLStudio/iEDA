#!/usr/bin/env python3
"""
批量修正所有设计配置文件的 PDK 路径
"""

import json
from pathlib import Path

def fix_design_config(design_dir: Path):
    """修正单个设计配置"""
    config_file = design_dir / "design.json"
    if not config_file.exists():
        return False
    
    with open(config_file) as f:
        config = json.load(f)
    
    pdk = config.get('pdk', '')
    variant = config.get('variant', '')
    
    # 根据不同 PDK 修正路径
    if pdk == 'sky130':
        prefix = 'sky130_'
        config['inputs']['tech_lef'] = f"$PDK/lef/{prefix}{variant}.tlef"
        config['inputs']['cells_lef'] = f"$PDK/lef/{prefix}{variant}_merged.lef"
        config['inputs']['lib'] = f"$PDK/lib/{prefix}{variant}__tt_025C_1v80.lib"
    elif pdk == 'nangate45':
        config['inputs']['tech_lef'] = "$PDK/lef/NangateOpenCellLibrary.tech.lef"
        config['inputs']['cells_lef'] = "$PDK/lef/NangateOpenCellLibrary.macro.lef"
        config['inputs']['lib'] = "$PDK/lib/NangateOpenCellLibrary_typical.lib"
    elif pdk == 'asap7':
        config['inputs']['tech_lef'] = "$PDK/lef/asap7_tech_1x_201209.lef"
        config['inputs']['cells_lef'] = "$PDK/lef/asap7sc7p5t_27_R_1x_201211.lef"
        config['inputs']['lib'] = "$PDK/lib/asap7sc7p5t_SIMPLE_RVT_TT_nldm_201020.lib"
    elif pdk == 'ics55':
        config['inputs']['tech_lef'] = "$PDK/lef/ics55_tech.lef"
        config['inputs']['cells_lef'] = "$PDK/lef/ics55_cells.lef"
        config['inputs']['lib'] = "$PDK/lib/ics55_typical.lib"
    else:
        print(f"  未知 PDK: {pdk}")
        return False
    
    # 写回
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    return True

def main():
    designs_dir = Path("/home/lxq/AiEDA/iEDA.ai/benchmarks/designs")
    
    aes_designs = [d for d in designs_dir.iterdir() 
                   if d.is_dir() and d.name.startswith("aes")]
    
    print(f"找到 {len(aes_designs)} 个 AES 设计\n")
    
    fixed = 0
    for design_dir in sorted(aes_designs):
        print(f"处理: {design_dir.name}...", end=" ")
        if fix_design_config(design_dir):
            print("✓")
            fixed += 1
        else:
            print("✗")
    
    print(f"\n完成: {fixed}/{len(aes_designs)} 个设计已修正")

if __name__ == "__main__":
    main()
