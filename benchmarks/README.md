# iEDA.ai Benchmark Suite

A comprehensive benchmark collection for EDA physical design evaluation, supporting multiple PDKs and synthesis strategies.

## 📊 Statistics

- **Total Designs**: 279 configurations
- **Base Designs**: 23 unique designs
- **PDKs**: 4 (sky130, nangate45, asap7, ics55)
- **Strategies**: 3 (area, balance, timing)
- **Total Size**: ~636 MB
- **Source**: iDATA dataset

## 🏗️ Structure

```
designs/
├── REGISTRY.json                    # Index of all designs
├── import_benchmarks.py             # Import script from iDATA
│
├── <design>_<pdk>_<strategy>/       # Example: aes_sky130_a
│   ├── design.json                  # Configuration
│   ├── netlist/                     # Synthesized netlist
│   │   └── <design>.v
│   ├── sdc/                         # Timing constraints
│   │   └── <design>.sdc
│   ├── def/                         # Sample placement DEF
│   │   └── <design>_place.def
│   └── results/                     # Output directory for flow runs
│
└── [Legacy single-PDK designs]      # aes/, gcd/, picorv32/
```

## 🎯 Design Categories

### Crypto & Security
- **aes** (M): AES-128 encryption core
- **aes_core** (M): AES core module
- **salsa20** (M): Salsa20 stream cipher

### Processors & Cores
- **picorv32** (L): RISC-V CPU core (~17K lines)
- **PPU** (M): Picture processing unit

### Peripherals (APB4 Bus)
- **apb4_uart** (S): UART controller
- **apb4_i2c** (S): I2C controller
- **apb4_timer** (S): Timer
- **apb4_wdg** (S): Watchdog
- **apb4_ps2** (S): PS/2 controller
- **apb4_rng** (S): Random number generator
- **apb4_clint** (S): Core local interruptor
- **apb4_archinfo** (S): Architecture info

### ISCAS89 Benchmarks
- **s44, s1238, s1488** (S): Small circuits
- **s5378, s9234, s13207, s15850** (M): Medium circuits
- **s35932, s38417, s38584** (L): Large circuits

### Reference
- **gcd** (S): Greatest common divisor (smoke test)

## 🔧 PDK Support

### sky130 (SkyWater 130nm)
- Variants: `fd_sc_hd`, `fd_sc_hs`, `fd_sc_hdll`, `fd_sc_ls`
- Default: `fd_sc_hd`
- Tech: 130nm open-source PDK

### nangate45 (FreePDK45)
- Variant: `stdcell`
- Tech: 45nm educational/research PDK

### asap7 (ASAP7)
- Variants: `RVT`, `LVT`, `SLVT`
- Default: `RVT`
- Tech: 7nm predictive PDK

### ics55 (ICS55)
- Variant: `stdcell`
- Tech: 55nm process

## ⚙️ Synthesis Strategies

Each design is available with multiple synthesis strategies:

- **a** (area): Optimized for minimum area
- **b** (balance): Balanced PPA (power-performance-area)
- **t** (timing): Optimized for maximum performance
- **n** (no-opt): Baseline without optimization *(not imported by default)*
- **p** (power): Optimized for minimum power *(not imported by default)*

## 📖 Usage

### Query Available Designs

```bash
# View all designs
cat designs/REGISTRY.json | jq '.designs[] | {name, pdk, scale, role}'

# Filter by PDK
cat designs/REGISTRY.json | jq '.designs[] | select(.pdk == "sky130")'

# Filter by scale
cat designs/REGISTRY.json | jq '.designs[] | select(.scale == "L")'
```

### Access Design Configuration

```python
import json

# Load registry
with open('designs/REGISTRY.json') as f:
    registry = json.load(f)

# Find specific design
design = next(d for d in registry['designs'] if d['name'] == 'aes_sky130_a')

# Load configuration
with open(f"designs/{design['dir']}/design.json") as f:
    config = json.load(f)

print(f"Top module: {config['top']}")
print(f"Clock period: {config['clocks'][0]['period_ns']} ns")
print(f"Netlist: {config['inputs']['netlist']}")
```

## 🔄 Import from iDATA

To refresh or add more designs from the iDATA source:

```bash
cd benchmarks/

# Import specific designs
python3 import_benchmarks.py \
  --designs aes gcd picorv32 \
  --pdks sky130 nangate45 \
  --strategies a b t

# Import all designs with all PDKs
python3 import_benchmarks.py \
  --pdks sky130 nangate45 asap7 ics55 \
  --strategies a b t

# Keep files compressed (save disk space)
python3 import_benchmarks.py --no-decompress

# Only regenerate REGISTRY.json
python3 import_benchmarks.py --registry-only
```

### Import Script Options

- `--idata-root`: Source iDATA directory (default: `/mnt/mdisk3/PCL-167/data3/taosimin/iDATA`)
- `--output-root`: Output directory (default: `./designs`)
- `--pdks`: PDKs to generate configs for
- `--strategies`: Synthesis strategies to import
- `--designs`: Specific designs (default: all)
- `--no-decompress`: Keep `.gz` files compressed
- `--registry-only`: Only regenerate registry

## 📝 Design Configuration Schema

Each `design.json` follows this structure:

```json
{
  "name": "aes_sky130_a",
  "top": "aes",
  "scale": "M",
  "role": "timing",
  "description": "AES encryption core",
  "pdk": "sky130",
  "variant": "fd_sc_hd",
  "inputs": {
    "tech_lef": "$PDK/lef/sky130_fd_sc_hd.tlef",
    "cells_lef": "$PDK/lef/sky130_fd_sc_hd_merged.lef",
    "lib": "$PDK/lib/sky130_fd_sc_hd__tt_025C_1v80.lib",
    "netlist": "netlist/aes.v",
    "sdc": "sdc/aes.sdc"
  },
  "floorplan": {
    "die_area": "0.0 0.0 800 800",
    "core_area": "80.0 80.0 720.0 720.0",
    "core_utilization": 0.6
  },
  "clocks": [
    {
      "name": "core_clock",
      "port": "clk",
      "period_ns": 2.5
    }
  ],
  "strategy": "a"
}
```

### Scale Classification

- **S** (Small): < 5K cells, util=0.55
- **M** (Medium): 5K-50K cells, util=0.60
- **L** (Large): 50K-200K cells, util=0.65
- **XL** (XLarge): > 200K cells, util=0.70

### Role Types

- `timing`: Timing-critical designs
- `cpu`: Processor cores
- `crypto`: Cryptographic accelerators
- `peripheral`: I/O controllers
- `iscas`: Standard benchmarks
- `logic`: General logic
- `reference`: Smoke tests

## 🎓 Citation

If you use these benchmarks in your research, please cite:

```bibtex
@misc{idata2025,
  title={iDATA: AI + EDA Dataset},
  author={PCL EDA Team},
  year={2025},
  url={https://gitee.com/oscc-project/iDATA}
}
```

## 📄 License

- Benchmarks: GPL (inherited from iDATA)
- Import scripts: Mulan PSL v2 (consistent with iEDA)

## 🔗 Related

- iEDA: https://gitee.com/oscc-project/iEDA
- iDATA: https://gitee.com/oscc-project/iDATA
- AiEDA: https://gitee.com/oscc-project/AiEDA
- PDKs: `/home/lxq/AiEDA/Foundary/`
