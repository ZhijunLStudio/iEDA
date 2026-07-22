#!/usr/bin/env python3
"""
Import benchmarks from iDATA to iEDA.ai/benchmarks structure.
Supports multiple PDKs and synthesis strategies.
"""

import os
import json
import shutil
import gzip
import argparse
from pathlib import Path
from typing import Dict, List, Optional

# Available PDKs in Foundary/
AVAILABLE_PDKS = {
    'sky130': {
        'variants': ['fd_sc_hd', 'fd_sc_hs', 'fd_sc_hdll', 'fd_sc_ls'],
        'default_variant': 'fd_sc_hd',
        'tech_lef_template': 'lef/{variant}.tlef',
        'cells_lef_template': 'lef/{variant}_merged.lef',
        'lib_template': 'lib/{variant}__tt_025C_1v80.lib'
    },
    'nangate45': {
        'variants': ['stdcell'],
        'default_variant': 'stdcell',
        'tech_lef_template': 'lef/NangateOpenCellLibrary.tech.lef',
        'cells_lef_template': 'lef/NangateOpenCellLibrary.macro.mod.lef',
        'lib_template': 'lib/NangateOpenCellLibrary_typical.lib'
    },
    'asap7': {
        'variants': ['RVT', 'LVT', 'SLVT'],
        'default_variant': 'RVT',
        'tech_lef_template': 'lef/asap7_tech_{variant}.lef',
        'cells_lef_template': 'lef/asap7sc7p5t_{variant}.lef',
        'lib_template': 'lib/asap7sc7p5t_{variant}_TT_nldm_201020.lib'
    },
    'ics55': {
        'variants': ['stdcell'],
        'default_variant': 'stdcell',
        'tech_lef_template': 'lef/ics55_tech.lef',
        'cells_lef_template': 'lef/ics55_stdcell.lef',
        'lib_template': 'lib/ics55_stdcell_tt_1v8_25c.lib'
    }
}

# Design characteristics for floorplan estimation
DESIGN_SCALES = {
    'S': {'die_mult': 1.5, 'util': 0.55},   # Small: < 5K cells
    'M': {'die_mult': 2.0, 'util': 0.60},   # Medium: 5K-50K cells
    'L': {'die_mult': 2.5, 'util': 0.65},   # Large: 50K-200K cells
    'XL': {'die_mult': 3.0, 'util': 0.70}   # XLarge: > 200K cells
}

DESIGN_INFO = {
    'aes': {'scale': 'M', 'role': 'timing', 'desc': 'AES encryption core', 'clk_port': 'clk', 'clk_period': 2.5},
    'aes_core': {'scale': 'M', 'role': 'timing', 'desc': 'AES core module', 'clk_port': 'clk', 'clk_period': 2.5},
    'gcd': {'scale': 'S', 'role': 'reference', 'desc': 'Greatest common divisor', 'clk_port': 'clk', 'clk_period': 10.0},
    'picorv32': {'scale': 'L', 'role': 'cpu', 'desc': 'RISC-V CPU core', 'clk_port': 'clk', 'clk_period': 5.0},
    'PPU': {'scale': 'M', 'role': 'logic', 'desc': 'Picture processing unit', 'clk_port': 'clk', 'clk_period': 5.0},
    'salsa20': {'scale': 'M', 'role': 'crypto', 'desc': 'Salsa20 stream cipher', 'clk_port': 'clk', 'clk_period': 3.0},
    's1238': {'scale': 'S', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s1238', 'clk_port': 'CK', 'clk_period': 5.0},
    's1488': {'scale': 'S', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s1488', 'clk_port': 'CK', 'clk_period': 5.0},
    's5378': {'scale': 'S', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s5378', 'clk_port': 'CK', 'clk_period': 5.0},
    's9234': {'scale': 'M', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s9234', 'clk_port': 'CK', 'clk_period': 5.0},
    's13207': {'scale': 'M', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s13207', 'clk_port': 'CK', 'clk_period': 5.0},
    's15850': {'scale': 'M', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s15850', 'clk_port': 'CK', 'clk_period': 5.0},
    's35932': {'scale': 'L', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s35932', 'clk_port': 'CK', 'clk_period': 8.0},
    's38417': {'scale': 'L', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s38417', 'clk_port': 'CK', 'clk_period': 8.0},
    's38584': {'scale': 'L', 'role': 'iscas', 'desc': 'ISCAS89 benchmark s38584', 'clk_port': 'CK', 'clk_period': 8.0},
    'apb4_i2c': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 I2C controller', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_uart': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 UART controller', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_timer': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 timer', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_wdg': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 watchdog', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_ps2': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 PS2 controller', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_rng': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 random number generator', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_clint': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 core local interruptor', 'clk_port': 'PCLK', 'clk_period': 5.0},
    'apb4_archinfo': {'scale': 'S', 'role': 'peripheral', 'desc': 'APB4 architecture info', 'clk_port': 'PCLK', 'clk_period': 5.0},
}


def decompress_file(src: Path, dst: Path):
    """Decompress gzip file."""
    with gzip.open(src, 'rb') as f_in:
        with open(dst, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)


def generate_design_json(design_name: str, pdk: str, variant: Optional[str] = None) -> Dict:
    """Generate design.json configuration."""
    info = DESIGN_INFO.get(design_name, {
        'scale': 'M', 'role': 'unknown', 'desc': f'{design_name} design',
        'clk_port': 'clk', 'clk_period': 5.0
    })

    pdk_info = AVAILABLE_PDKS[pdk]
    if variant is None:
        variant = pdk_info['default_variant']

    # Estimate floorplan based on scale
    scale_params = DESIGN_SCALES[info['scale']]
    # Base die size (will be adjusted per design in practice)
    base_size = {'S': 500, 'M': 800, 'L': 1200, 'XL': 1800}[info['scale']]
    margin = base_size * 0.1

    config = {
        'name': design_name,
        'top': design_name,
        'scale': info['scale'],
        'role': info['role'],
        'description': info['desc'],
        'pdk': pdk,
        'variant': variant,
        'inputs': {
            'tech_lef': f"$PDK/{pdk_info['tech_lef_template'].format(variant=variant)}",
            'cells_lef': f"$PDK/{pdk_info['cells_lef_template'].format(variant=variant)}",
            'lib': f"$PDK/{pdk_info['lib_template'].format(variant=variant)}",
            'netlist': 'netlist/{}.v'.format(design_name),
            'sdc': 'sdc/{}.sdc'.format(design_name)
        },
        'floorplan': {
            'die_area': f'0.0 0.0 {base_size} {base_size}',
            'core_area': f'{margin} {margin} {base_size-margin} {base_size-margin}',
            'core_utilization': scale_params['util']
        },
        'clocks': [{
            'name': 'core_clock',
            'port': info['clk_port'],
            'period_ns': info['clk_period']
        }]
    }

    return config


def import_design(idata_root: Path, output_root: Path, design_name: str,
                  pdks: List[str], strategies: List[str] = ['a'],
                  decompress: bool = True):
    """Import a single design from iDATA."""
    src_design = idata_root / design_name
    if not src_design.exists():
        print(f"⚠️  Design {design_name} not found in iDATA, skipping...")
        return

    print(f"\n📦 Importing {design_name}...")

    for pdk in pdks:
        for strategy in strategies:
            # Create output directory structure
            out_dir = output_root / f"{design_name}_{pdk}_{strategy}"
            out_dir.mkdir(parents=True, exist_ok=True)
            (out_dir / 'netlist').mkdir(exist_ok=True)
            (out_dir / 'sdc').mkdir(exist_ok=True)
            (out_dir / 'def').mkdir(exist_ok=True)
            (out_dir / 'results').mkdir(exist_ok=True)

            # Copy synthesis netlist
            # Try .gz first, then plain .v
            src_netlist = src_design / 'syn_netlist' / f'{design_name}_{strategy}.v.gz'
            is_compressed = True

            if not src_netlist.exists():
                src_netlist = src_design / 'syn_netlist' / f'{design_name}_{strategy}.v'
                is_compressed = False

            if not src_netlist.exists():
                src_netlist = src_design / 'syn_netlist' / f'{design_name}.v.gz'
                is_compressed = True

            if not src_netlist.exists():
                src_netlist = src_design / 'syn_netlist' / f'{design_name}.v'
                is_compressed = False

            if src_netlist.exists():
                dst_netlist = out_dir / 'netlist' / f'{design_name}.v'
                if is_compressed and decompress:
                    decompress_file(src_netlist, dst_netlist)
                    print(f"  ✓ Netlist: {dst_netlist.name}")
                elif is_compressed and not decompress:
                    shutil.copy(src_netlist, dst_netlist.with_suffix('.v.gz'))
                    print(f"  ✓ Netlist: {dst_netlist.name}.gz (compressed)")
                else:
                    shutil.copy(src_netlist, dst_netlist)
                    print(f"  ✓ Netlist: {dst_netlist.name}")

            # Copy SDC
            src_sdc = src_design / 'syn_netlist' / f'{design_name}.sdc'
            if not src_sdc.exists():
                src_sdc = src_design / 'place' / f'{design_name}.sdc'

            if src_sdc.exists():
                dst_sdc = out_dir / 'sdc' / f'{design_name}.sdc'
                shutil.copy(src_sdc, dst_sdc)
                print(f"  ✓ SDC: {dst_sdc.name}")

            # Copy sample DEF from placement (congestion_best variant)
            src_def = src_design / 'place' / f'{design_name}_{strategy}_place_congestion_best.def.gz'
            if not src_def.exists():
                src_def = src_design / 'place' / f'{design_name}_{strategy}_place.def.gz'

            if src_def.exists():
                dst_def = out_dir / 'def' / f'{design_name}_place.def'
                if decompress:
                    decompress_file(src_def, dst_def)
                    print(f"  ✓ DEF: {dst_def.name}")

            # Generate design.json
            config = generate_design_json(design_name, pdk)
            config['strategy'] = strategy
            config['name'] = f"{design_name}_{pdk}_{strategy}"

            config_path = out_dir / 'design.json'
            with open(config_path, 'w') as f:
                json.dump(config, f, indent=2)
            print(f"  ✓ Config: design.json ({pdk}, strategy={strategy})")


def generate_registry(output_root: Path):
    """Generate benchmark registry index."""
    designs = []
    for design_dir in sorted(output_root.glob('*')):
        if not design_dir.is_dir() or design_dir.name.startswith('.'):
            continue

        config_file = design_dir / 'design.json'
        if config_file.exists():
            with open(config_file) as f:
                config = json.load(f)
                designs.append({
                    'name': config['name'],
                    'dir': design_dir.name,
                    'pdk': config['pdk'],
                    'scale': config['scale'],
                    'role': config['role'],
                    'description': config['description']
                })

    registry = {
        'version': '1.0',
        'total_designs': len(designs),
        'pdks': list(set(d['pdk'] for d in designs)),
        'designs': designs
    }

    registry_path = output_root / 'REGISTRY.json'
    with open(registry_path, 'w') as f:
        json.dump(registry, f, indent=2)

    print(f"\n📋 Registry created: {registry_path}")
    print(f"   Total designs: {len(designs)}")
    print(f"   PDKs: {', '.join(registry['pdks'])}")


def main():
    parser = argparse.ArgumentParser(description='Import iDATA benchmarks to iEDA.ai')
    parser.add_argument('--idata-root', type=Path,
                        default=Path('/mnt/mdisk3/PCL-167/data3/taosimin/iDATA'),
                        help='iDATA root directory')
    parser.add_argument('--output-root', type=Path,
                        default=Path('/home/lxq/AiEDA/iEDA.ai/benchmarks/designs'),
                        help='Output benchmarks directory')
    parser.add_argument('--pdks', nargs='+', default=['sky130', 'nangate45'],
                        choices=list(AVAILABLE_PDKS.keys()),
                        help='PDKs to generate configs for')
    parser.add_argument('--strategies', nargs='+', default=['a', 'b', 't'],
                        choices=['a', 'b', 'n', 'p', 't'],
                        help='Synthesis strategies (a=area, b=balance, n=no-opt, p=power, t=timing)')
    parser.add_argument('--designs', nargs='+',
                        help='Specific designs to import (default: all)')
    parser.add_argument('--no-decompress', action='store_true',
                        help='Keep files compressed (.gz)')
    parser.add_argument('--registry-only', action='store_true',
                        help='Only regenerate registry, skip import')

    args = parser.parse_args()

    if args.registry_only:
        generate_registry(args.output_root)
        return

    # Determine designs to import
    if args.designs:
        designs_to_import = args.designs
    else:
        designs_to_import = list(DESIGN_INFO.keys())

    print(f"🚀 iEDA.ai Benchmark Import")
    print(f"   Source: {args.idata_root}")
    print(f"   Output: {args.output_root}")
    print(f"   PDKs: {', '.join(args.pdks)}")
    print(f"   Strategies: {', '.join(args.strategies)}")
    print(f"   Designs: {len(designs_to_import)}")

    # Import each design
    for design in designs_to_import:
        import_design(
            args.idata_root,
            args.output_root,
            design,
            args.pdks,
            args.strategies,
            decompress=not args.no_decompress
        )

    # Generate registry
    generate_registry(args.output_root)

    print("\n✅ Import complete!")


if __name__ == '__main__':
    main()
