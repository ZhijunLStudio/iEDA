# iPA/iIR Commercial Parity Validation Framework

This framework validates iEDA power (iPA) and IR drop (iIR) analysis against commercial signoff tools (PrimeTime PX and Cadence Voltus) across multiple designs, PDKs, and corners.

## Validation Goals

**iPA vs PrimeTime PX (G9/G17 gates)**:
- Power component accuracy: ±10% target for switch/internal/leakage/total
- Activity source honesty: VCD/SAIF provenance must be labeled, no silent default toggle
- Clock power attribution: Validate clock network vs sequential element bucketing
- Correlation: R² > 0.95 for signoff equivalence

**iIR vs Voltus (G10 gate)**:
- Peak IR accuracy: ±5mV or ±10% (whichever larger) target
- Top-N node correlation: Spearman ρ > 0.8, <3 top-10 rank swaps
- Convergence gate: Must report converged=true, residual <1e-6
- False clean detection: Flag cases where iIR misses Voltus violations
- Current mapping: >90% iPA→iIR instance-to-PG coverage

## Directory Structure

```
benchmarks/validation/
├── README.md                     # This file
├── run_validation.py             # Master validation runner
├── design_list.txt               # Design matrix
│
├── iPA_vs_PTPX/
│   ├── README.md                 # iPA validation details
│   ├── scripts/
│   │   ├── run_comparison.py    # Python comparison driver
│   │   └── run_iPA.tcl          # TCL analysis template
│   ├── designs/
│   │   └── <design>/
│   │       ├── iPA_report.json  # iPA output (generated)
│   │       └── ptpx_report.rpt  # PTPX reference (manual)
│   └── reports/
│       └── summary.md            # Validation summary
│
└── iIR_vs_Voltus/
    ├── README.md                 # iIR validation details
    ├── scripts/
    │   ├── run_comparison.py    # Python comparison driver
    │   └── run_iIR.tcl          # TCL analysis template
    ├── designs/
    │   └── <design>/
    │       ├── iIR_report.json  # iIR output (generated)
    │       └── voltus_report.rpt # Voltus reference (manual)
    └── reports/
        └── summary.md            # Validation summary
```

## Quick Start

### 1. Prepare Design Data

For each design in `design_list.txt`, ensure:
- Placed DEF (from iPL or post-routing)
- Liberty timing/power libraries
- SPEF parasitic netlist
- VCD/SAIF activity file (for iPA)
- PG netlist (for iIR)

### 2. Run iPA Validation

```bash
# Analyze a single design with iPA
cd benchmarks/validation/iPA_vs_PTPX
iEDA -script scripts/run_iPA.tcl \
    -var DEF_PATH=../../designs/aes_sky130_a/workspace/result/iPL_result.def \
    -var VCD_PATH=../../designs/aes_sky130_a/testbench/aes.vcd \
    -var VCD_TOP_INSTANCE=tb_aes/dut \
    -var RESULT_DIR=designs/aes_sky130_a

# This generates: designs/aes_sky130_a/iPA_report.json
```

### 3. Obtain PTPX Reference

Run PrimeTime PX with identical inputs and save the report:
```tcl
# In PrimeTime PX
read_verilog ...
read_liberty ...
read_parasitics ...
read_vcd ...
update_power
report_power > designs/aes_sky130_a/ptpx_report.rpt
```

### 4. Run Comparison

```bash
# Compare iPA vs PTPX for all designs
cd benchmarks/validation/iPA_vs_PTPX
python scripts/run_comparison.py \
    --design-list ../iPA_vs_PTPX_designs.txt \
    --output iPA_vs_PTPX_results.json

# View summary
cat reports/summary.md
```

### 5. Run iIR Validation

```bash
# Analyze a single design with iIR
cd benchmarks/validation/iIR_vs_Voltus
iEDA -script scripts/run_iIR.tcl \
    -var DEF_PATH=../../designs/aes_sky130_a/workspace/result/iPL_result.def \
    -var IPA_POWER_JSON=../iPA_vs_PTPX/designs/aes_sky130_a/iPA_report.json \
    -var PG_GENERATOR=iPDN \
    -var PG_INPUT_HASH=abc123... \
    -var RESULT_DIR=designs/aes_sky130_a

# This generates: designs/aes_sky130_a/iIR_report.json
```

### 6. Run Full Validation Campaign

```bash
# Run both iPA and iIR validation on all designs
cd benchmarks/validation
python run_validation.py \
    --design-list design_list.txt \
    --output-dir .

# View overall summary
cat validation_summary.md
```

## Expected JSON Report Schemas

### iPA Report (`iPA_report.json`)

Per `docs/ai/29-iPA-iIR-todo.md` P0 schema:

```json
{
  "design": "aes_sky130_a",
  "activity_source": "vcd",
  "toggle_coverage": 0.87,
  "corner": "typical",
  "voltage": 1.0,
  "temperature": 25.0,
  "power_components": {
    "switch_w": 0.00123,
    "internal_w": 0.00056,
    "leakage_w": 0.00012,
    "clock_w": 0.00034,
    "total_w": 0.00225
  },
  "runtime_s": 45.2,
  "input_hash": "sha256:..."
}
```

### iIR Report (`iIR_report.json`)

Per `docs/ai/29-iPA-iIR-todo.md` P0/P1 schema:

```json
{
  "design": "aes_sky130_a",
  "peak_ir_mv": 45.2,
  "nominal_voltage_mv": 1000.0,
  "budget_mv": 50.0,
  "converged": true,
  "iterations": 87,
  "absolute_residual": 1.23e-8,
  "relative_residual": 5.67e-7,
  "current_source": "iPA_vcd",
  "solver_method": "conjugate_gradient",
  "top_nodes": [
    {
      "name": "VDD_inst123",
      "x": 100.5,
      "y": 200.3,
      "layer": "met5",
      "ir_drop_mv": 45.2,
      "voltage_v": 1.0548
    }
  ],
  "mapping_trace": {
    "total_power_instances": 7000,
    "mapped_instances": 6850,
    "unmatched_instances": 150,
    "mapped_power_w": 0.0123,
    "unmatched_power_w": 0.0002
  },
  "runtime_s": 12.3
}
```

## Gate Criteria

### iPA Gates (G9/G17)

✓ **PASS**:
- Total power within ±10% of PTPX
- All power components within ±20%
- Activity source explicitly labeled (not "none" or "toggle_default" without VCD)
- Toggle coverage >80% when VCD available

⚠ **WARN**:
- Total power within ±15% of PTPX
- Any component >±20%
- Toggle coverage 60-80%

✗ **FAIL**:
- Total power >±15% of PTPX
- Activity source mislabeled (silent default toggle use)

### iIR Gates (G10)

✓ **PASS**:
- Peak IR within ±5mV or ±10% of Voltus (whichever larger)
- Converged=true, residual <1e-6
- Current mapping coverage >90%
- Top-N Spearman ρ >0.8, <3 top-10 swaps
- No false cleans

⚠ **WARN**:
- Peak IR within ±10mV or ±15%
- Current mapping coverage 80-90%
- Top-N Spearman ρ 0.6-0.8

✗ **FAIL**:
- Peak IR >±10mV or ±15%
- Did not converge
- False clean (iIR clean but Voltus has violations)
- Current source = "none"

## Troubleshooting

**iPA analysis fails with "VCD not found"**:
- Check `VCD_PATH` environment variable
- Verify VCD file exists and is readable
- Check `VCD_TOP_INSTANCE` matches hierarchy

**iIR analysis fails with "PG provenance required"**:
- Must set `PG_GENERATOR` and `PG_INPUT_HASH` from iPDN/iPNP
- Cannot run signoff IR without validated PG netlist

**Comparison fails with "missing required field"**:
- Ensure iPA/iIR reports include all P0 schema fields
- Check tool version supports new report format

**Large power/IR deltas**:
- Verify identical input files (netlist, SPEF, VCD)
- Check corner/voltage/temperature settings match
- Review unmatched instance warnings

## Next Steps

After validation framework is operational:

1. **Data collection phase**: Run iPA/iIR + PTPX/Voltus on all designs
2. **Baseline establishment**: Identify systematic biases (e.g., iPA consistently 5% high)
3. **Root cause analysis**: For designs with >15% error, debug via instance-level comparison
4. **Calibration**: Adjust iPA/iIR algorithms if correctable systematic error found
5. **Regression**: Add validation to CI to catch future regressions

## References

- `docs/ai/29-iPA-iIR.md`: Full technical deep-dive on iPA/iIR internals
- `docs/ai/29-iPA-iIR-todo.md`: Current TODO list and P0/P1/P2 tracking
- `src/operation/iPA/`: iPA source code
- `src/operation/iIR/`: iIR source code
