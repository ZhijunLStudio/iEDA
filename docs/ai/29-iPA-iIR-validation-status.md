# iPA/iIR Commercial Parity Validation - Implementation Status

**Date**: 2026-08-11
**Branch**: commercial-parity
**Reference**: `docs/ai/29-iPA-iIR-todo.md`

## Summary

Created complete commercial parity validation framework for iPA (power analysis) vs PrimeTime PX and iIR (IR drop analysis) vs Cadence Voltus. Framework enables automated validation against commercial signoff tools with full gate criteria checking per G9/G10/G17 requirements.

## Completed Work

### P1 Tasks (All Complete)
- ✅ P0 activity source schema: activity_source field mandatory, coverage tracking
- ✅ P0 hierarchical path handling: top instance path support, error semantics
- ✅ P0 iIR convergence gate: converged/residual/iterations reporting
- ✅ P1 current chain tracing: iPA→iIR mapping with unmatched tracking
- ✅ P1 static IR closed loop: convergence validation implemented

### P2 Validation Framework (Infrastructure Complete)
Created comprehensive validation infrastructure at `benchmarks/validation/`:

**iPA vs PTPX Validation**:
- ✅ Python comparison driver (`iPA_vs_PTPX/scripts/run_comparison.py`)
  - Parses iPA JSON reports (activity_source, power components, coverage)
  - Parses PTPX text reports (power breakdown)
  - Computes error metrics: total/switch/internal/leakage power deltas
  - Gates on activity source honesty (G9 requirement)
  - Gates on ±10% accuracy target (G17 requirement)
  - Outputs structured JSON results + markdown summary

- ✅ TCL analysis template (`iPA_vs_PTPX/scripts/run_iPA.tcl`)
  - Loads design DEF, libraries, SPEF
  - Reads VCD/SAIF with hierarchical path support
  - Runs power analysis with full provenance tracking
  - Generates JSON report per P0 schema (29-iPA-iIR-todo.md)

**iIR vs Voltus Validation**:
- ✅ Python comparison driver (`iIR_vs_Voltus/scripts/run_comparison.py`)
  - Parses iIR JSON reports (peak_ir, convergence, mapping_trace)
  - Parses Voltus text reports (peak IR, top-N nodes)
  - Computes error metrics: peak IR delta, top-N rank correlation
  - Gates on convergence (G10 requirement)
  - Detects false cleans (missed violations)
  - Validates current mapping coverage (>90% target)
  - Outputs structured JSON results + markdown summary

- ✅ TCL analysis template (`iIR_vs_Voltus/scripts/run_iIR.tcl`)
  - Loads design DEF with PG netlist
  - Validates PG provenance (iPDN/iPNP stamp)
  - Reads instance power from iPA or PTPX
  - Runs static IR analysis with convergence tracking
  - Generates JSON report per P0/P1 schema
  - Gates on convergence before exit

**Master Orchestration**:
- ✅ `run_validation.py`: Master driver for multi-design campaigns
- ✅ `design_list.txt`: Design matrix (5 iPA + 4 iIR designs across PDKs)
- ✅ `README.md`: Complete usage documentation with examples

## File Inventory

```
benchmarks/validation/
├── README.md                                    # Usage guide, schemas, gates
├── run_validation.py                            # Master validation driver
├── design_list.txt                              # Design matrix
├── directory_structure.txt                      # Tree structure reference
│
├── iPA_vs_PTPX/
│   ├── README.md                                # iPA validation details
│   └── scripts/
│       ├── run_comparison.py                    # iPA vs PTPX comparison (420 LOC)
│       └── run_iPA.tcl                          # iPA analysis template (45 LOC)
│
└── iIR_vs_Voltus/
    ├── README.md                                # iIR validation details
    └── scripts/
        ├── run_comparison.py                    # iIR vs Voltus comparison (550 LOC)
        └── run_iIR.tcl                          # iIR analysis template (75 LOC)
```

**Total new code**: ~1,100 LOC Python + ~120 LOC TCL + ~350 lines markdown docs

## TODO Updated

Updated `docs/ai/29-iPA-iIR-todo.md`:
- ✅ Marked P1 static IR task complete (line 37)
- ✅ Expanded P2 section with validation framework status
- ✅ Added checkboxes for framework infrastructure (completed)
- 📋 Remaining P2 work: data collection + execution (see below)

## Next Steps (Data Collection Phase)

### 1. Run iPA Analyses (5 designs)
For each design in `design_list.txt`:
```bash
cd benchmarks/designs/<design>/workspace
iEDA -script ../../../../validation/iPA_vs_PTPX/scripts/run_iPA.tcl \
    -var DEF_PATH=result/iPL_result.def \
    -var VCD_PATH=../../testbench/<design>.vcd \
    -var VCD_TOP_INSTANCE=tb_<design>/dut \
    -var RESULT_DIR=../../../../validation/iPA_vs_PTPX/designs/<design>
```

**Designs**: aes_sky130_a, aes_asap7_a, aes_nangate45_a, salsa20_sky130_a, apb4_timer_ics55_t

**Expected output**: `validation/iPA_vs_PTPX/designs/<design>/iPA_report.json`

### 2. Obtain PTPX Reference Data
Run PrimeTime PX with identical inputs (netlist, SPEF, VCD, corner):
```tcl
# In PrimeTime PX session
read_verilog <netlist>
link_design <top>
read_liberty <lib>
read_parasitics -format spef <spef>
read_vcd <vcd> -strip_path tb_<design>/dut
update_power
report_power > validation/iPA_vs_PTPX/designs/<design>/ptpx_report.rpt
```

**Note**: PTPX is commercial tool, requires license. If unavailable, use subset of designs with PTPX data.

### 3. Run iIR Analyses (4 designs)
For each design:
```bash
cd benchmarks/designs/<design>/workspace
iEDA -script ../../../../validation/iIR_vs_Voltus/scripts/run_iIR.tcl \
    -var DEF_PATH=result/iPL_pdn_result.def \
    -var IPA_POWER_JSON=../../../../validation/iPA_vs_PTPX/designs/<design>/iPA_report.json \
    -var PG_GENERATOR=iPDN \
    -var PG_INPUT_HASH=<hash_from_ipdn> \
    -var RESULT_DIR=../../../../validation/iIR_vs_Voltus/designs/<design>
```

**Designs**: aes_sky130_a, aes_asap7_a, salsa20_sky130_a, aes_nangate45_a

**Expected output**: `validation/iIR_vs_Voltus/designs/<design>/iIR_report.json`

### 4. Obtain Voltus Reference Data
Run Cadence Voltus with identical PG netlist and power:
```tcl
# In Voltus session
read_design ...
read_power_grid_library ...
set_power_pads ...
set_instance_power -file <ptpx_power.csv>
analyze_rail -type static
report_rail > validation/iIR_vs_Voltus/designs/<design>/voltus_report.rpt
```

**Note**: Voltus is commercial tool, requires license.

### 5. Execute Validation
Once all iPA/iIR reports and PTPX/Voltus references are collected:

```bash
cd benchmarks/validation

# Run iPA comparison
cd iPA_vs_PTPX
python scripts/run_comparison.py \
    --design-list ../iPA_vs_PTPX_designs.txt \
    --output iPA_vs_PTPX_results.json

# Run iIR comparison
cd ../iIR_vs_Voltus
python scripts/run_comparison.py \
    --design-list ../iIR_vs_Voltus_designs.txt \
    --output iIR_vs_Voltus_results.json

# Generate overall summary
cd ..
python run_validation.py \
    --design-list design_list.txt \
    --output-dir .
```

**Expected output**:
- `iPA_vs_PTPX_results.json`: Per-design power comparison
- `iIR_vs_Voltus_results.json`: Per-design IR comparison
- `validation_summary.md`: Overall PASS/FAIL status for G9/G10/G17

### 6. Root Cause Analysis
For designs that FAIL gates:
- Extract instance-level power/IR deltas
- Check for input mismatches (SPEF, VCD timestamps, corner settings)
- Review iPA/iIR logs for warnings
- Compare unmatched instance lists (iIR mapping trace)

### 7. Calibration (If Needed)
If systematic bias found (e.g., iPA consistently 5% high):
- Check toggle propagation defaults
- Verify Liberty power model interpolation
- Compare cap extraction (iRCX vs StarRC)
- Consider calibration factors with justification

## Integration with CI/CD

Once validation passes, add to regression:

```yaml
# .github/workflows/power_ir_validation.yml
name: Power/IR Commercial Parity
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build iEDA
        run: scripts/integration/ieda_build.sh clean
      - name: Run iPA validation
        run: |
          cd benchmarks/validation
          python run_validation.py \
            --design-list design_list_ci.txt \
            --output-dir ci_results
      - name: Check gates
        run: |
          # Parse validation_summary.md for FAIL
          # Exit 1 if any gate failed
```

**Note**: CI needs PTPX/Voltus reference data pre-computed and checked in.

## Success Criteria

**P2 Complete** when:
- ✅ All 5 iPA designs pass G9/G17 gates (±10% power, labeled activity source)
- ✅ All 4 iIR designs pass G10 gate (±5mV IR, converged, >90% mapping)
- ✅ Reports generated for ≥3 PDKs (sky130, asap7, nangate45 confirmed)
- ✅ Validation summary markdown shows "ALL GATES PASSED"

## References

- `docs/ai/29-iPA-iIR.md`: Technical deep-dive (rv2.1)
- `docs/ai/29-iPA-iIR-todo.md`: Task tracking (updated 2026-08-11)
- `benchmarks/validation/README.md`: Validation framework usage
- `src/operation/iPA/api/Power.hh`: iPA API with P0 schema
- `src/operation/iIR/api/iIR.hh`: iIR API with convergence gate
