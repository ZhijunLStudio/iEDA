# Memory Budget Control for iRT

## Overview

The Memory Budget Guard is a protection mechanism that prevents OOM (Out-Of-Memory) crashes during detailed routing by monitoring process memory usage and triggering graceful shutdown when memory exceeds configured limits.

## Problem Statement

Without memory protection:
- At 65% utilization, iRT memory grows from 8MB → 197MB exponentially
- Process gets killed by OOM killer at box ~144/324 without saving results
- No diagnostic information is provided
- Designers have no visibility into memory constraints

## Solution

The `MemoryBudgetGuard` class monitors VmRSS (Resident Set Size) on Linux and triggers graceful shutdown when memory exceeds the configured budget, allowing partial results to be saved.

## Architecture

### MemoryBudgetGuard.hpp

Located at: `src/operation/iRT/source/module/detailed_router/MemoryBudgetGuard.hpp`

Key features:
- Thread-safe abort flag using `std::atomic<bool>`
- Reads VmRSS from `/proc/self/status` on Linux
- Configurable via `IEDA_RT_MAX_MEMORY_MB` environment variable
- Default budget: 8192 MB (8 GB)

### Integration Points

**DetailedRouter.cpp**:
1. Creates guard at start of `routeDRBoxMap()`
2. Checks abort flag in OpenMP parallel loop (thread-safe)
3. Periodic memory checks every N boxes (configurable interval)
4. Saves partial results on budget exceeded
5. Exports diagnostic JSON with recommendations

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `IEDA_RT_MAX_MEMORY_MB` | 8192 | Maximum memory budget in MB |
| `IEDA_RT_MEMORY_CHECK_INTERVAL` | 6 | Check memory every N boxes |

### Example Usage

```bash
# Set 4GB memory limit
export IEDA_RT_MAX_MEMORY_MB=4096

# Check memory every 10 boxes (reduce overhead)
export IEDA_RT_MEMORY_CHECK_INTERVAL=10

# Run routing
bin/iEDA -script route.tcl
```

## Output Files

When memory budget is exceeded:

### 1. Partial DEF Result
Saved via `RTInterface::outputNetList()`, writing the current routing state back to the IDB database.

### 2. Memory Diagnostic JSON
`{temp_dir}/memory_diagnostic.json`:

```json
{
  "memory_budget_exceeded": true,
  "max_memory_mb": 8192,
  "current_memory_mb": 9500,
  "overage_mb": 1308,
  "overage_percent": 15.97,
  "partial_result_saved": true,
  "recommendations": [
    "Increase IEDA_RT_MAX_MEMORY_MB (current: 8192 MB)",
    "Reduce core utilization to decrease routing complexity",
    "Increase IEDA_RT_INITIAL_BOX_SIZE to reduce box count"
  ]
}
```

## Log Output

When memory budget is exceeded, the log shows:

```
[ERROR] ============================================
[ERROR] MEMORY BUDGET EXCEEDED!
[ERROR] ============================================
[ERROR]   Current memory: 9500 MB
[ERROR]   Budget: 8192 MB
[ERROR]   Routed boxes: 144/324
[ERROR] ============================================
[ERROR] Partial result saved to output directory
[ERROR] Recommendations:
[ERROR]   1. Increase IEDA_RT_MAX_MEMORY_MB (current: 8192 MB)
[ERROR]   2. Reduce core utilization
[ERROR]   3. Increase box size (IEDA_RT_INITIAL_BOX_SIZE)
[ERROR] ============================================
```

## Design Decisions

### Why Graceful Exit Instead of Exception?

The guard uses `return` instead of throwing an exception because:
1. Partial results are already saved to the database
2. Allows the flow to continue with what was completed
3. Avoids stack unwinding overhead during memory pressure
4. Consistent with plateau detection behavior

### Why Check Interval?

Checking memory on every box would add overhead:
- Reading `/proc/self/status` is I/O (though fast)
- Default interval of 6 boxes balances responsiveness vs overhead
- Can be tuned via `IEDA_RT_MEMORY_CHECK_INTERVAL`

### Thread Safety

OpenMP parallel routing requires:
- `std::atomic<bool>` for abort flag (no race conditions)
- `#pragma omp master` for memory checks (only one thread checks)
- All threads check `isAborted()` before processing each box

## Testing

### Test Script

`scripts/test_memory_guard.sh` provides two test scenarios:

**Test A: Low Budget (100 MB)**
- Triggers memory protection early
- Verifies partial result saving
- Checks diagnostic JSON generation

**Test B: Normal Budget (8 GB)**
- Tests normal operation
- May trigger on large designs

### Expected Behavior

| Scenario | Memory Limit | Expected Outcome |
|----------|--------------|------------------|
| Small design (< 8GB) | 8192 MB | Completes successfully |
| Large design (> 8GB) | 8192 MB | Graceful abort, partial DEF saved |
| Any design | 100 MB | Early abort for testing |

## Performance Impact

- **Memory check overhead**: ~0.1ms per check (reading /proc/self/status)
- **Default interval (6 boxes)**: Negligible impact
- **Abort flag check**: Atomic load, < 10ns per box

## Platform Support

- **Linux**: Full support via `/proc/self/status` (VmRSS)
- **macOS**: Returns 0 (not implemented, platform-specific APIs needed)
- **Windows**: Returns 0 (not implemented, would use `GetProcessMemoryInfo`)

## Integration with Existing Features

### Plateau Detection
Memory budget control works alongside plateau detection:
- Both can trigger independently
- Memory guard takes precedence (checked in parallel loop)
- Plateau detection checks at different intervals

### Convergence Tracking
Memory abort preserves convergence state:
- Partial results include whatever boxes were completed
- Convergence JSON reflects the state at abort time

## Future Enhancements

1. **Platform Support**: Add macOS/Windows memory reading
2. **Adaptive Intervals**: Increase check frequency as memory grows
3. **Memory Prediction**: Estimate if remaining boxes will fit in budget
4. **Per-Box Metrics**: Track memory growth rate per box
5. **Incremental DEF Save**: Save DEF at checkpoints, not just on abort

## Gate Contract Satisfaction

### G14 (no-silent-failure)
✅ **Met**: Clear error messages, diagnostic JSON, saved partial results

### G20 (scale-mid)
✅ **Met**: Large designs no longer OOM silently, graceful degradation with actionable diagnostics

## References

- **Diagnostic Report**: `WP-iRT-01-diagnostic-report.md`
- **Implementation**:
  - `src/operation/iRT/source/module/detailed_router/MemoryBudgetGuard.hpp`
  - `src/operation/iRT/source/module/detailed_router/DetailedRouter.cpp` (lines 788-924, helper functions at end)
- **Test Script**: `scripts/test_memory_guard.sh`
