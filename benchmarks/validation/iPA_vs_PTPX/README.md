# iPA vs PrimeTime PX Commercial Parity Validation

## Objective

Compare iPA power analysis against PrimeTime PX (PTPX) signoff-grade power analysis across multiple designs, corners, and activity sources.

## Validation Metrics

### Primary Metrics (G9/G17 gate criteria)
- **Power component accuracy**: switch/internal/leakage/clock power delta
- **Activity coverage**: VCD/SAIF toggle coverage vs default fallback ratio
- **Clock power bucketing**: clock network vs sequential element attribution
- **Total power correlation**: R² > 0.95 target for signoff equivalence

### Secondary Metrics
- **Runtime comparison**: iPA vs PTPX wall-clock time
- **Memory footprint**: peak RSS comparison
- **Activity source handling**: VCD vs SAIF vs default toggle behavior
- **Hierarchical power**: module-level power breakdown accuracy

## Test Matrix

| Design | PDK | Corner | Activity Source | Size (cells) | Notes |
|--------|-----|--------|----------------|--------------|-------|
| aes_sky130_a | sky130 | typical | VCD | ~7k | Full AES core with VCD stimulus |
| aes_asap7_a | asap7 | ss_100C | SAIF | ~7k | Same netlist, different PDK |
| aes_nangate45_a | nangate45 | typical | VCD | ~7k | Multi-PDK validation |
| salsa20_sky130_a | sky130 | typical | VCD | ~18k | Larger crypto core |
| apb4_timer_ics55_t | ics55 | typical | default | ~2k | Fallback toggle validation |

## Validation Protocol

1. **Prepare reference data**: Run PTPX on each design with identical:
   - Liberty timing/power libraries
   - Parasitic netlist (SPEF)
   - Activity input (VCD/SAIF)
   - Voltage/temperature conditions

2. **Run iPA analysis**: Execute iPA with same inputs, collect:
   - JSON power report (with activity_source field)
   - CSV instance power breakdown
   - Runtime/memory metrics

3. **Compare results**:
   - Parse PTPX report for switch/internal/leakage/total power
   - Extract iPA JSON power components
   - Compute relative error: `(iPA - PTPX) / PTPX * 100%`
   - Flag outliers: instances with >20% power delta
   - Generate correlation plots and residual histograms

4. **Gate criteria**:
   - **PASS**: Total power within ±10%, R² > 0.95, all activity sources labeled
   - **WARN**: Total power within ±15%, any component >±20%
   - **FAIL**: Total power >±15% or false activity source (default used but not marked)

## Directory Structure
