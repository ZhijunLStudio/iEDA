# AES12 @65% live status

Updated: 2026-07-30T16:48:33+08:00
Result root: `/home/lxq/AiEDA/iEDA.ai/benchmarks/results/aes13_65pct_pass_20260730_1551`

| Design | FP | FO | PL | CTS | TO | LG | RT | GDS |
|--------|----|----|----|-----|----|----|----|-----|
| aes_sky130_a | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_sky130_b | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_sky130_t | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_nangate45_a | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_nangate45_b | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_nangate45_t | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_asap7_a | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| aes_asap7_b | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| aes_asap7_t | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| aes_ics55_a | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_ics55_b | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| aes_ics55_t | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |

## Recent routing lines
### aes_nangate45_t
727:[RT 20260730 16:45:29 SRLHjtNA SpaceRouter.cpp:61 Info route] Completed (elapsed = 00:03:23, cpu = 00:04:34, mem = 4.10MB)
766:[RT 20260730 16:45:33 SRLHjtNA TrackAssigner.cpp:242 Info assignTAPanelMap] Completed (elapsed = 00:00:03, cpu = 00:00:14, mem = 0.00MB)
783:[RT 20260730 16:45:33 SRLHjtNA TrackAssigner.cpp:72 Info assign] Completed (elapsed = 00:00:03, cpu = 00:00:15, mem = 0.00MB)
786:[RT 20260730 16:45:33 SRLHjtNA DetailedRouter.cpp:139 Info initDRModel] Completed (elapsed = 00:00:00, cpu = 00:00:00, mem = 0.00MB)
804:[RT 20260730 16:45:33 SRLHjtNA DetailedRouter.cpp:361 Info initDRBoxMap] Completed (elapsed = 00:00:00, cpu = 00:00:00, mem = 0.00MB)
806:[RT 20260730 16:45:33 SRLHjtNA DetailedRouter.cpp:393 Info buildBoxSchedule] Completed (elapsed = 00:00:00, cpu = 00:00:00, mem = 0.00MB)
808:[RT 20260730 16:45:34 SRLHjtNA DetailedRouter.cpp:485 Info splitNetResult] Completed (elapsed = 00:00:01, cpu = 00:00:01, mem = 0.00MB)
810:[RT 20260730 16:45:34 SRLHjtNA DetailedRouter.cpp:502 Info routeDRBoxMap] 65pct guards: best_effort=1, plateau_interval=36, explosion_threshold=2, max_boxes=4, max_memory_mb=32768

### aes_sky130_a
946:[RT 20260730 16:47:32 QcZAhoTD DetailedRouter.cpp:2494 Info uploadViolation] Completed (elapsed = 00:00:01, cpu = 00:00:05, mem = 0.00MB)
947:[RT 20260730 16:47:32 QcZAhoTD DetailedRouter.cpp:242 Warn routeDRModel] IEDA_RT_BEST_EFFORT=1: skip patchFinalMinArea to finish early with partial routes
949:[RT 20260730 16:47:34 QcZAhoTD DetailedRouter.cpp:2494 Info uploadViolation] Completed (elapsed = 00:00:02, cpu = 00:00:05, mem = 0.00MB)
951:[RT 20260730 16:47:34 QcZAhoTD DetailedRouter.cpp:2585 Info updateBestResult] Completed (elapsed = 00:00:01, cpu = 00:00:01, mem = 0.00MB)
979:[RT 20260730 16:47:36 QcZAhoTD DetailedRouter.cpp:2747 Info uploadBestResult] Completed (elapsed = 00:00:01, cpu = 00:00:01, mem = 0.00MB)
981:[RT 20260730 16:47:38 QcZAhoTD DetailedRouter.cpp:2494 Info uploadViolation] Completed (elapsed = 00:00:02, cpu = 00:00:06, mem = 0.00MB)
984:[RT 20260730 16:47:38 QcZAhoTD DetailedRouter.cpp:361 Info initDRBoxMap] Completed (elapsed = 00:00:00, cpu = 00:00:00, mem = 0.00MB)
986:[RT 20260730 16:47:38 QcZAhoTD DetailedRouter.cpp:393 Info buildBoxSchedule] Completed (elapsed = 00:00:00, cpu = 00:00:00, mem = 0.00MB)
