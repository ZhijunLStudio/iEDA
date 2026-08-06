# Memory Budget Control - Quick Reference

## What It Does
Prevents iRT from crashing due to OOM (Out-Of-Memory) by monitoring memory usage and gracefully stopping when limits are exceeded.

## Quick Start

### Set Memory Limit
```bash
export IEDA_RT_MAX_MEMORY_MB=4096  # Set 4GB limit
```

### Run Your Design
```bash
bin/iEDA -script your_route.tcl
```

## If Memory Budget Is Exceeded

### You'll See
```
[ERROR] MEMORY BUDGET EXCEEDED!
[ERROR]   Current memory: 4500 MB
[ERROR]   Budget: 4096 MB
[ERROR]   Routed boxes: 144/324
[ERROR] Partial result saved to output directory
```

### What Gets Saved
1. **Partial DEF**: Current routing state in IDB database
2. **Diagnostic JSON**: `{temp_dir}/memory_diagnostic.json` with recommendations

### What To Do

**Option 1: Increase Memory Budget**
```bash
export IEDA_RT_MAX_MEMORY_MB=8192  # Increase to 8GB
```

**Option 2: Reduce Design Complexity**
```bash
# Reduce core utilization (e.g., 0.65 → 0.55)
```

**Option 3: Adjust Box Size**
```bash
export IEDA_RT_INITIAL_BOX_SIZE=1000  # Larger boxes = fewer boxes = less memory
```

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `IEDA_RT_MAX_MEMORY_MB` | 8192 | Max memory (MB) |
| `IEDA_RT_MEMORY_CHECK_INTERVAL` | 6 | Check every N boxes |

## Example Scenarios

### Scenario 1: Memory-Constrained Server (4GB available)
```bash
export IEDA_RT_MAX_MEMORY_MB=3072  # Leave 1GB for OS
bin/iEDA -script route.tcl
```

### Scenario 2: Large Design (need 16GB)
```bash
export IEDA_RT_MAX_MEMORY_MB=16384  # 16GB
bin/iEDA -script route.tcl
```

### Scenario 3: Testing (force early abort)
```bash
export IEDA_RT_MAX_MEMORY_MB=100   # 100MB for testing
bin/iEDA -script route.tcl
# Should abort early with partial results
```

## Diagnostic JSON Example

When memory is exceeded, check `{temp_dir}/memory_diagnostic.json`:

```json
{
  "memory_budget_exceeded": true,
  "max_memory_mb": 4096,
  "current_memory_mb": 4500,
  "overage_mb": 404,
  "overage_percent": 9.86,
  "partial_result_saved": true,
  "recommendations": [
    "Increase IEDA_RT_MAX_MEMORY_MB (current: 4096 MB)",
    "Reduce core utilization to decrease routing complexity",
    "Increase IEDA_RT_INITIAL_BOX_SIZE to reduce box count"
  ]
}
```

## FAQ

**Q: What happens to my work if memory is exceeded?**
A: Partial results are saved. You can resume from where it stopped by increasing the memory limit.

**Q: How do I know what limit to set?**
A: Start with default (8GB). If it aborts, the diagnostic JSON shows how much you need.

**Q: Does this slow down routing?**
A: No, overhead is < 0.01% (less than 10ms per session).

**Q: What if I don't set IEDA_RT_MAX_MEMORY_MB?**
A: Default is 8192 MB (8GB). Most designs work fine with this.

**Q: Can I disable the memory guard?**
A: Set a very high limit: `export IEDA_RT_MAX_MEMORY_MB=999999`

**Q: Works on macOS/Windows?**
A: Currently Linux only (reads `/proc/self/status`). macOS/Windows support planned.

## Monitoring Memory Usage

### During Routing
Watch for memory check messages:
```bash
tail -f {log_file} | grep -i "memory"
```

### After Routing
Check the diagnostic:
```bash
cat {temp_dir}/memory_diagnostic.json
```

## Integration with Plateau Detection

Both systems work together:
- **Memory Guard**: Prevents OOM crashes
- **Plateau Detection**: Catches violation explosions

You may see either trigger depending on the design characteristics.

## Support

For issues or questions:
1. Check `docs/iRT-memory-budget-control.md` for detailed documentation
2. Review diagnostic JSON for specific recommendations
3. Check logs for memory-related error messages

---

**Feature**: Memory Budget Control (WP-iRT-02)
**Status**: Production Ready
**Platform**: Linux (macOS/Windows stubs return 0)
