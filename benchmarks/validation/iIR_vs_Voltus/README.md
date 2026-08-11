# iIR vs Voltus Commercial Parity Validation

## Objective

Compare iIR static IR drop analysis against Cadence Voltus signoff-grade IR analysis across multiple designs, PDKs, PG topologies, and corners.

## Validation Metrics

### Primary Metrics (G10 gate criteria)
- **Peak IR accuracy**: Maximum IR drop delta (mV)
- **Top-N node correlation**: Rank correlation of worst IR drop instances
- **Residual convergence**: Relative/absolute residual validation
- **False clean detection**: Cases where iIR reports clean but Voltus flags violations

### Secondary Metrics
- **Runtime comparison**: iIR vs Voltus wall-clock time
- **Memory footprint**: Peak RSS comparison
- **Current source mapping**: iPA→iIR instance-to-PG coverage
- **PG topology handling**: Mesh vs stripe vs mixed topologies

## Test Matrix

| Design | PDK | PG Topology | Current Source | IR Budget | Notes |
|--------|-----|-------------|----------------|-----------|-------|
| aes_sky130_a | sky130 | stripe + mesh | iPA VCD | 50mV | Full PG with iPA integration |
| aes_asap7_a | asap7 | stripe only | PTPX | 100mV | High-density 7nm stress case |
| salsa20_sky130_a | sky130 | mesh only | iPA VCD | 50mV | Uniform distribution |
| aes_nangate45_a | nangate45 | mixed | iPA default | 75mV | Fallback current validation |

## Validation Protocol

1. **Prepare reference data**: Run Voltus on each design with:
   - PG netlist (extracted or synthesized)
   - Instance power from PTPX
   - Bump/VDD node locations
   - Temperature/voltage conditions

2. **Run iIR analysis**: Execute iIR with same inputs, collect:
   - JSON IR report (peak_ir_mv, residual, converged, current_source)
   - Top-N node report with locations and IR values
   - Runtime/memory metrics

3. **Compare results**:
   - Parse Voltus report for peak IR, top-N nodes, residuals
   - Extract iIR JSON IR components
   - Compute absolute error: `|iIR_peak - Voltus_peak|` (mV)
   - Rank correlation: Spearman ρ for top-50 nodes
   - Flag false cleans: Voltus violations missed by iIR

4. **Gate criteria**:
   - **PASS**: Peak IR within ±5mV or ±10% (whichever larger), converged=true, residual <1e-6
   - **WARN**: Peak IR within ±10mV or ±15%, any top-10 node rank swap
   - **FAIL**: Peak IR >±10mV or ±15%, false clean (missed violation), or non-convergence

## Directory Structure

```
validation/iIR_vs_Voltus/
├── README.md                 # This file
├── run_comparison.py         # Main validation driver
├── designs/
│   ├── aes_sky130_a/
│   │   ├── iIR_report.json
│   │   ├── voltus_report.rpt
│   │   └── comparison.json
│   └── ...
├── scripts/
│   ├── run_iIR.tcl           # iIR analysis template
│   ├── run_voltus.tcl        # Voltus analysis template
│   └── parse_reports.py     # Report parser utilities
└── reports/
    ├── summary.md            # High-level summary
    ├── correlation.png       # iIR vs Voltus scatter (peak IR + top-N)
    └── convergence.png       # Residual vs iteration curves
```

## Known Limitations

- **Dynamic IR**: Current scope is static IR only (average power), dynamic IR requires time-windowed current input (P1 follow-on)
- **EM validation**: Voltus EM rules not yet validated in iIR
- **Multi-VDD domains**: Single-domain validation first, multi-VDD in next phase
