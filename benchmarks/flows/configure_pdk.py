#!/usr/bin/env python3
"""
为不同工艺库生成正确的flow配置
每个工艺需要不同的site定义、LEF文件和lib文件
"""

import json
from pathlib import Path

# 工艺库配置映射
PDK_CONFIGS = {
    "sky130": {
        "variants": {
            "fd_sc_hd": {
                "site": "unithd",
                "io_site": "unithd",
                "corner_site": "unithddbl",
                "tech_lef": "lef/sky130_fd_sc_hd.tlef",
                "cells_lef": "lef/sky130_fd_sc_hd_merged.lef",
                "lib": "lib/sky130_fd_sc_hd__tt_025C_1v80.lib",
                "tapcell": "sky130_fd_sc_hd__tap_1",
                "endcap": "sky130_fd_sc_hd__fill_1"
            },
            "fd_sc_hs": {
                "site": "unit",
                "io_site": "unit",
                "corner_site": "unit",
                "tech_lef": "lef/sky130_fd_sc_hs.tlef",
                "cells_lef": "lef/sky130_fd_sc_hs_merged.lef",
                "lib": "lib/sky130_fd_sc_hs__tt_025C_1v80.lib",
                "tapcell": "sky130_fd_sc_hs__tap_1",
                "endcap": "sky130_fd_sc_hs__fill_1"
            }
        }
    },
    "nangate45": {
        "variants": {
            "default": {
                "site": "FreePDK45_38x28_10R_NP_162NW_34O",
                "io_site": "FreePDK45_38x28_10R_NP_162NW_34O",
                "corner_site": "FreePDK45_38x28_10R_NP_162NW_34O",
                "tech_lef": "lef/NangateOpenCellLibrary.tech.lef",
                "cells_lef": "lef/NangateOpenCellLibrary.macro.lef",
                "lib": "lib/NangateOpenCellLibrary_typical.lib",
                "tapcell": "FILLCELL_X1",
                "endcap": "FILLCELL_X1"
            }
        }
    },
    "asap7": {
        "variants": {
            "default": {
                "site": "asap7sc7p5t",
                "io_site": "asap7sc7p5t",
                "corner_site": "asap7sc7p5t",
                "tech_lef": "lef/asap7_tech_1x_201209.lef",
                "cells_lef": "lef/asap7sc7p5t_27_R_1x_201211.lef",
                "lib": "lib/asap7sc7p5t_SIMPLE_RVT_TT_nldm_201020.lib",
                "tapcell": "TAPCELL_ASAP7_75t_R",
                "endcap": "FILLER_ASAP7_75t_R"
            }
        }
    },
    "ics55": {
        "variants": {
            "default": {
                "site": "CoreSite",
                "io_site": "CoreSite",
                "corner_site": "CoreSite",
                "tech_lef": "prtech/techLEF/N551P6M_ieda.lef",
                "cells_lef": "prtech/signalStormCellLib/signalStorm55_lef.lef",
                "lib": "prtech/signalStormCellLib/signalStorm55_tt.lib",
                "tapcell": "FILL1",
                "endcap": "FILL1"
            }
        }
    }
}

def get_pdk_config(pdk, variant=None):
    """获取指定工艺的配置"""
    if pdk not in PDK_CONFIGS:
        return None

    pdk_data = PDK_CONFIGS[pdk]

    if "variants" in pdk_data:
        if variant and variant in pdk_data["variants"]:
            return pdk_data["variants"][variant]
        elif "default" in pdk_data["variants"]:
            return pdk_data["variants"]["default"]
        else:
            # 返回第一个variant
            return list(pdk_data["variants"].values())[0]

    return pdk_data

def generate_tcl_config(design_name, pdk, variant=None):
    """为指定设计生成TCL配置脚本"""
    config = get_pdk_config(pdk, variant)
    if not config:
        print(f"Error: No configuration for PDK {pdk}")
        return None

    tcl_content = f"""#===========================================================
##   PDK Configuration for {pdk}
##   Auto-generated for design: {design_name}
#===========================================================

set PLACE_SITE {config['site']}
set IO_SITE {config['io_site']}
set CORNER_SITE {config['corner_site']}

set TAPCELL_NAME {config['tapcell']}
set ENDCAP_NAME {config['endcap']}
"""

    return tcl_content

def update_design_workspace(design_path):
    """更新设计workspace中的配置"""
    design_path = Path(design_path)
    design_json = design_path / "design.json"

    if not design_json.exists():
        print(f"Error: {design_json} not found")
        return False

    # 读取design.json
    with open(design_json, 'r') as f:
        design_config = json.load(f)

    pdk = design_config.get("pdk")
    variant = design_config.get("variant", "default")

    pdk_config = get_pdk_config(pdk, variant)
    if not pdk_config:
        print(f"Error: No config for {pdk}/{variant}")
        return False

    # 更新workspace中的TCL脚本
    workspace = design_path / "workspace"
    if not workspace.exists():
        print(f"Warning: {workspace} does not exist")
        return False

    # 生成site配置脚本
    site_config_file = workspace / "script" / "iFP_script" / "pdk_site_config.tcl"
    site_config_file.parent.mkdir(parents=True, exist_ok=True)

    tcl_config = generate_tcl_config(design_config["name"], pdk, variant)
    with open(site_config_file, 'w') as f:
        f.write(tcl_config)

    print(f"✓ Generated {site_config_file}")

    # 更新db_path_setting.tcl中的CELL_TYPE
    db_path_setting = workspace / "script" / "DB_script" / "db_path_setting.tcl"
    if db_path_setting.exists() and pdk == "sky130":
        with open(db_path_setting, 'r') as f:
            content = f.read()

        # 根据variant设置CELL_TYPE
        if variant == "fd_sc_hd":
            content = content.replace('set CELL_TYPE "HS"', 'set CELL_TYPE "HD"')
        elif variant == "fd_sc_hs":
            content = content.replace('set CELL_TYPE "HD"', 'set CELL_TYPE "HS"')

        with open(db_path_setting, 'w') as f:
            f.write(content)

        print(f"✓ Updated {db_path_setting}")

    # 更新CTS配置文件中的buffer类型
    cts_config = workspace / "iEDA_config" / "cts_default_config.json"
    if cts_config.exists() and pdk == "sky130":
        import json as json_module
        with open(cts_config, 'r') as f:
            cts_data = json_module.load(f)

        # 更新buffer类型
        if variant == "fd_sc_hd":
            cts_data["buffer_type"] = [
                "sky130_fd_sc_hd__buf_1",
                "sky130_fd_sc_hd__buf_2",
                "sky130_fd_sc_hd__buf_4"
            ]
        elif variant == "fd_sc_hs":
            cts_data["buffer_type"] = [
                "sky130_fd_sc_hs__buf_1",
                "sky130_fd_sc_hs__buf_2",
                "sky130_fd_sc_hs__buf_4"
            ]

        with open(cts_config, 'w') as f:
            json_module.dump(cts_data, f, indent=4)

        print(f"✓ Updated {cts_config}")

    # 更新run_iFP.tcl使用正确的site
    run_ifp = workspace / "script" / "iFP_script" / "run_iFP.tcl"
    if run_ifp.exists():
        with open(run_ifp, 'r') as f:
            content = f.read()

        # 查找并替换site定义
        import re
        content = re.sub(r'set PLACE_SITE\s+\w+', f'set PLACE_SITE {pdk_config["site"]}', content)
        content = re.sub(r'set IO_SITE\s+\w+', f'set IO_SITE {pdk_config["io_site"]}', content)
        content = re.sub(r'set CORNER_SITE\s+\w+', f'set CORNER_SITE {pdk_config["corner_site"]}', content)

        # 更新tapcell配置
        tapcell_pattern = r'tapcell\s+\\\s*-tapcell\s+\S+'
        tapcell_replacement = f'tapcell \\\n   -tapcell {pdk_config["tapcell"]}'
        content = re.sub(tapcell_pattern, tapcell_replacement, content)

        endcap_pattern = r'-endcap\s+\S+'
        endcap_replacement = f'-endcap {pdk_config["endcap"]}'
        content = re.sub(endcap_pattern, endcap_replacement, content)

        with open(run_ifp, 'w') as f:
            f.write(content)

        print(f"✓ Updated {run_ifp}")

    return True

def main():
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 configure_pdk.py <design_path>")
        print("Example: python3 configure_pdk.py /path/to/benchmarks/designs/aes_sky130_a")
        sys.exit(1)

    design_path = sys.argv[1]

    print(f"Configuring PDK-specific settings for: {design_path}")
    print("=" * 60)

    if update_design_workspace(design_path):
        print("=" * 60)
        print("✓ Configuration completed successfully!")
    else:
        print("=" * 60)
        print("✗ Configuration failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
