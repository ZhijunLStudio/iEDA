#!/usr/bin/env python3
"""
使用Yosys为不同PDK综合AES设计
"""

import subprocess
import os
from pathlib import Path

# Yosys路径
YOSYS = "/home/lxq/AiEDA/micromamba/envs/ieda3d/bin/yosys"

# RTL源码（使用cipher_top作为简化示例）
RTL_DIR = Path("/home/lxq/AiEDA/HS-3D_Problem/baseline/Open3DBench/OpenROAD-3D/flow/designs/src/aes")
RTL_FILES = [
    RTL_DIR / "aes_cipher_top.v",
    RTL_DIR / "aes_key_expand_128.v",
    RTL_DIR / "aes_rcon.v",
    RTL_DIR / "aes_sbox.v"
]

# PDK配置
PDK_CONFIGS = {
    "nangate45": {
        "lib": "/home/lxq/AiEDA/Foundary/nangate45/lib/NangateOpenCellLibrary_typical.lib",
        "output": "/home/lxq/AiEDA/iEDA.ai/benchmarks/synthesis/aes_nangate45.v",
        "top": "aes_cipher_top"
    },
    "asap7": {
        "lib": "/home/lxq/AiEDA/Foundary/asap7/lib/asap7sc7p5t_SIMPLE_RVT_TT_nldm_201020.lib",
        "output": "/home/lxq/AiEDA/iEDA.ai/benchmarks/synthesis/aes_asap7.v",
        "top": "aes_cipher_top"
    },
    "ics55": {
        "lib": "/home/lxq/AiEDA/Foundary/ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR/liberty/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib",
        "output": "/home/lxq/AiEDA/iEDA.ai/benchmarks/synthesis/aes_ics55.v",
        "top": "aes_cipher_top"
    }
}

def generate_yosys_script(pdk_name, config, rtl_files):
    """生成Yosys综合脚本"""

    script = []

    # 读取RTL
    for rtl in rtl_files:
        script.append(f"read_verilog {rtl}")

    # 设置层次结构
    top = config["top"]
    script.append(f"hierarchy -check -top {top}")

    # 综合
    script.append(f"synth -top {top} -flatten")

    # 映射到标准单元
    lib = config["lib"]
    script.append(f"dfflibmap -liberty {lib}")
    script.append(f"abc -liberty {lib}")

    # 清理
    script.append("setundef -zero")
    script.append("splitnets")
    script.append("opt_clean -purge")

    # 输出
    output = config["output"]
    script.append(f"write_verilog -noattr {output}")
    script.append("stat")

    return "\n".join(script)

def synthesize_pdk(pdk_name, config, rtl_files):
    """为指定PDK综合设计"""

    print(f"\n{'='*60}")
    print(f"综合 AES for {pdk_name}")
    print(f"{'='*60}")

    # 检查库文件
    lib_path = Path(config["lib"])
    if not lib_path.exists():
        print(f"✗ Liberty file not found: {lib_path}")
        return False

    # 检查RTL文件
    for rtl in rtl_files:
        if not rtl.exists():
            print(f"✗ RTL file not found: {rtl}")
            return False

    # 创建输出目录
    output_dir = Path(config["output"]).parent
    output_dir.mkdir(parents=True, exist_ok=True)

    # 生成Yosys脚本
    script_content = generate_yosys_script(pdk_name, config, rtl_files)
    script_file = output_dir / f"synth_aes_{pdk_name}.ys"

    with open(script_file, 'w') as f:
        f.write(script_content)

    print(f"  Generated script: {script_file}")

    # 运行Yosys（设置数据目录）
    try:
        env = os.environ.copy()
        env['YOSYS_DATDIR'] = '/home/lxq/AiEDA/micromamba/envs/ieda3d/share/yosys'

        result = subprocess.run(
            [YOSYS, "-s", str(script_file)],
            capture_output=True,
            text=True,
            timeout=300,
            env=env
        )

        if result.returncode == 0:
            print(f"  ✓ Synthesis successful")
            print(f"  Output: {config['output']}")

            # 显示统计信息
            if "Number of cells:" in result.stdout:
                for line in result.stdout.split('\n'):
                    if "Number of" in line or "Chip area" in line:
                        print(f"    {line.strip()}")

            return True
        else:
            print(f"  ✗ Synthesis failed")
            print(f"  Error: {result.stderr[:500]}")
            return False

    except subprocess.TimeoutExpired:
        print(f"  ✗ Synthesis timeout (>5min)")
        return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def main():
    print("="*60)
    print("AES多工艺综合工具")
    print("使用Yosys为nangate45/asap7/ics55综合AES")
    print("="*60)

    # 检查Yosys
    if not Path(YOSYS).exists():
        print(f"✗ Yosys not found: {YOSYS}")
        return

    print(f"✓ Using Yosys: {YOSYS}")

    # 综合所有PDK
    results = {}
    for pdk_name, config in PDK_CONFIGS.items():
        success = synthesize_pdk(pdk_name, config, RTL_FILES)
        results[pdk_name] = success

    # 总结
    print("\n" + "="*60)
    print("综合结果总结")
    print("="*60)

    for pdk_name, success in results.items():
        status = "✓ 成功" if success else "✗ 失败"
        print(f"  {pdk_name:15s} {status}")

    success_count = sum(1 for s in results.values() if s)
    print(f"\n成功: {success_count}/{len(results)}")
    print("="*60)

if __name__ == "__main__":
    main()
