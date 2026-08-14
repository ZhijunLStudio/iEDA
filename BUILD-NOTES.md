# iEDA — Build & Run Notes

Base: OSCC-Project/iEDA. This tree integrates the additional tool sources directly
into the standard iEDA layout; there is no separate overlay to track.

## Toolchain (no sudo — userspace conda)
micromamba env `ieda-build` (at /home/lxq/AiEDA/micromamba/envs) provides gcc-10,
cmake, ninja, boost, glog, gflags, eigen, gtest, tbb, gmp, metis, libhwloc,
cairo, tk(tcl), libunwind, rust, pybind11. Eigen exposed via
`$CONDA_PREFIX/include/Eigen` symlink -> eigen3/Eigen.

## Build iEDA (shared libs — conda has no static glog/gflags)
    scripts/integration/ieda_build.sh clean   # configure + build target iEDA
Key flags: -DBUILD_STATIC_LIB=OFF, conda CC/CXX, LIBRARY_PATH=$CONDA_PREFIX/lib.
Output: bin/iEDA (run with LD_LIBRARY_PATH=$CONDA_PREFIX/lib).

## Run gcd flows (netlist -> GDS)
- sky130:    scripts/integration/run_sky130.sh   -> result/final_design.gds2
- ics55:     PDK_DIR=/home/lxq/AiEDA/ics55-pdk scripts/integration/run_ics55.sh
- nangate45: scripts/design/nangate45_gcd/run_iEDA.sh  (foundry: Foundary/nangate45)
- benchmarks flow (this machine): see "Local environment (lizhijun machine)" below.

## Metrics
- STA:     result/to/{drv,hold}/sta/gcd.rpt (slack / TNS / freq)
- Power:   iPW run_power -> result/sta/gcd.pwr
- DRC:     iRT DRC + iDRC signoff -> result/drc/detail.drc
- IR-drop: report_ir_drop needs PDN power-source (bump) geometry — see PDN config

## Status
sky130 gcd netlist->GDS + STA/power/DRC: DONE. ics55 gcd netlist->GDS: DONE (DRC 0).
TODO: ics55 power/DRC report scripts; sky130 IR-drop PDN; nangate45 gcd DRC closure.

## Local environment (lizhijun machine) — 2026-08-14
- `/home/lxq/*` paths in docs/scripts are NOT usable here (EACCES on /home/lxq). Real PDK is at
  `/home/lizhijun/work/oscc-ieda/scripts/foundry/{sky130,...}`; flow templates at
  `/home/lizhijun/work/oscc-ieda/scripts/design/{sky130_gcd,...}`. `iEDA.ai/scripts` is a symlink to
  `../oscc-ieda/scripts` (untracked, needed by benchmarks/flows template lookup).
- Build: system toolchain, `cmake --build build --target iEDA -j$(nproc)` (g++-11.4). Output lands in
  `build/bin/iEDA` — copy to `bin/iEDA` (the root bin/ is what the flow picks up). Do NOT use the
  micromamba `ieda-build` env from the upstream notes; it is unreachable here.
- Fixed in this tree (needed to compile HEAD): commit 61bf067 changed
  `ieda::getInput/OutputFileStream` to return streams by value; updated bindings in
  src/platform/flow/config/flow_config.cpp, src/platform/data_manager/config/dm_{,cts_}config.cpp,
  src/feature/parser/feature_parser{,_drc}.cpp, src/operation/iRT/test/process_guide/process_guide.cpp.
- benchmarks flow quirks: `aes13_flow.py --design` only accepts the 13 AES names; for other designs use
  `benchmarks/run_gcd_design.py` (imports the module, calls run_design directly). Must export
  IEDA_FOUNDRY_ROOT/IEDA_BIN/IEDA_BUILD_LIB/YOSYS_BIN/IEDA_AES_RTL_ROOT before running — see that script.
  Use `/usr/bin/python3` (3.10); anaconda python is 3.7 and breaks on `copytree(dirs_exist_ok=)`.
- gcd_sky130_a full flow result (results/flow_20260814_gcd, 2026-08-14): all 18 stages success
  (floorplan..gds). Timing MET (worst slack 1.067 ns @ 2.5 ns clock), power 1.51 mW (vectorless 0.02
  toggle), HPWL 6.52 mm, iRT DRC 361 violations (not signoff-clean). Report + stage PNGs:
  benchmarks/reports/gcd_flow.{md,html} + gcd_flow_assets/gcd_sky130_a/*.png.
- GP session tool (docs/ai/72-72c, M1+M2 done 2026-08-14): `placer_run_gp -mode {start|advance|resume|close}
  -iterations N -random_init 0|1 [-checkpoint <file>]` segments Nesterov GP into accepted-iteration batches;
  every budget-limited batch auto-saves `<output>/pl/gp_session_checkpoint.json` (atomic), resume works
  cross-process (validates a config fingerprint + instance-name topology fingerprint). `-mode relinearize`
  restarts a session from externally-legalized coordinates (advance after LG/DP is rejected as
  invalidated). `-seed N` controls the initial random placement (default 1000). Local-scope machinery exists but is NOT exposed: control experiments show hot-bin
  scoping ≈ random scoping and no robust win over global GP (72c §17/19). Multi-design scale
  experiments (s1238/apb4_timer/picorv32/aes from ~/work/pl_vis/cases, converted with
  src/operation/iPL/test/configs/def2placement_1000.py) confirm: freeze gives real hpwl wins at
  late stages on big designs, density screens cost +22-28% hpwl. Multi-PDK (tsmc28 asic_top 321k,
  superblue16 981k from /mnt/usb20t/PCL-155) confirms modes work on 3 PDKs; freeze helps only when
  hotspots are localized (72c §20). Legacy
  `placer_run_gp` (no args) unchanged. Equivalence tests (19 scenarios, incl. congestion-enabled and
  4-thread variants, all bitwise-identical vs continuous runs):
  `build/bin/ipl_gp_session_test --scenario {seg20|seg40|seg10x2|observe|ckpt_save|ckpt_resume|resume_inproc|
  seg40_cg|ckpt_save_cg|ckpt_resume_cg|seg40_mt|ckpt_save_mt|ckpt_resume_mt|conv_mid|diverge|mismatch|invalidate|relinearize|local_degenerate|local_context_frozen|local_control|local_ablate|local_sweep|seed_vary|legacy|full|validate}`
  (compare /tmp/ipl_gp_session_test/<scenario>/coords.txt + records.txt). Test configs live in
  src/operation/iPL/test/configs/. iPL test inputs point at
  benchmarks/results/flow_20260814_gcd/gcd_sky130_a/workspace/result/iFP_result.def
  (the benchmarks/designs/gcd_sky130_a/def/gcd_place.def fixture only exists on lxq's machine).
