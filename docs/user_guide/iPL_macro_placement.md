<!--
Copyright (c) 2023-2025 Peng Cheng Laboratory
Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
iEDA is licensed under Mulan PSL v2.
-->
# iPL Macro Placement Guide

## Overview

The iPL macro placement module provides automated placement for macro blocks (hard IPs, memory blocks, etc.) within the chip floorplan. This is a critical step that must run before global placement of standard cells.

## Implementation Status

**Phase B1.2 - Step 1 (COMPLETED)**: Basic Framework
- ✅ MacroPlacer class with basic interface
- ✅ Macro collection and identification (via `Cell::isMacro()`)
- ✅ Simple grid-based initial placement
- ✅ Legality checking (overlap detection, boundary checks)
- ✅ Macro packed fraction calculation
- ✅ Integration into PLAPI::runMP()
- ✅ Build system integration

**Next Steps**:
- Step 2: Force-directed placement algorithm
- Step 3: Simulated annealing optimization
- Step 4: Verification with macro designs

## Usage

### In Tcl Flow

The macro placement runs automatically as part of `run_placer`:

```tcl
source iEDA/scripts/design/<pdk>_<design>/run_iEDA.tcl
run_placer
```

The flow executes in this order:
1. **Macro Placement** (`runMP()`) - places macro blocks
2. **Global Placement** (`runGP()`) - places standard cells around macros
3. **Legalization** (`runLG()`) - legalizes all cells

### Standalone Macro Placement

```tcl
# Initialize placer
source iEDA/scripts/design/iEDA_config/pl_default_config.tcl
run_placer -config $config

# Macro placement runs automatically
# Check results in logs
```

## Current Algorithm

### Step 1: Macro Collection
- Scans design instance list
- Identifies macros via `Cell::isMacro()`
- Filters out fixed macros (already placed by floorplan)

### Step 2: Initial Placement
- Grid-based layout: arranges macros in √N × √N grid
- Each macro placed at grid cell center
- Simple but provides legal starting point

### Step 3: Legality Check
- **Boundary check**: All macros within core area
- **Overlap check**: No macro-macro overlaps
- **Packed fraction**: Overlap_area / Total_macro_area < 10%

## Metrics

### Macro Packed Fraction
```
packed_frac = Σ(overlap_area) / Σ(macro_area)
```
- **Target**: < 10%
- **Current**: Grid placement achieves 0% (no overlaps)

### Future Metrics (Step 2+)
- Total wirelength (macro-to-std-cell)
- Channel utilization
- Macro-aware routing congestion

## Limitations (Current)

1. **No optimization**: Grid placement ignores connectivity
2. **No channel awareness**: Does not reserve routing channels
3. **No timing consideration**: Not timing-driven
4. **Fixed grid**: No adaptive spacing

These will be addressed in Steps 2-3 with force-directed + SA algorithms.

## Files

- **Implementation**: `src/operation/iPL/source/module/macro_placer/`
  - `MacroPlacer.hh` - Interface
  - `MacroPlacer.cc` - Implementation
  - `CMakeLists.txt` - Build config

- **Integration**: `src/operation/iPL/api/PLAPI.{hh,cc}`
  - `runMP()` - Entry point

- **Test**: `src/operation/iPL/test/MacroPlacerTest.cc`

## Known Issues

- Requires designs with macros to fully test (most test designs are std-cell only)
- No configuration options yet (grid size, spacing, etc.)
- No incremental macro placement support

## References

- Design doc: `docs/ai/22-iPL.md` §7-§9
- Know-how: `docs/ai/03-commercial-knowhow-catalog.md` KH-PL-08
