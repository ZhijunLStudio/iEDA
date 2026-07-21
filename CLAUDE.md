# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iEDA is an open-source C++20 EDA infrastructure and tool suite covering the ASIC physical-design flow from netlist to GDS (floorplan, placement, CTS, timing optimization, routing, DRC, STA, power/IR analysis). The single `iEDA` binary is a Tcl-driven shell: each tool is invoked by running a Tcl script (`iEDA -script foo.tcl`). This tree (forked from OSCC-Project/iEDA) also integrates AiEDA Python bindings and local flow scripts. License: Mulan PSL v2.

## Build

**This machine (no sudo, conda toolchain — see BUILD-NOTES.md, which is the authoritative local doc):**

```bash
scripts/integration/ieda_build.sh clean   # configure + build, outputs bin/iEDA
```

This activates micromamba env `ieda-build` (gcc-10, cmake, ninja, boost, glog, gflags, eigen, tbb, etc. under `/home/lxq/AiEDA/micromamba/envs`), configures with `-DBUILD_STATIC_LIB=OFF` (conda has no static glog/gflags), and links with rpath into `$CONDA_PREFIX/lib`. Run the binary with `LD_LIBRARY_PATH=$CONDA_PREFIX/lib` (or use the wrapper scripts, which set it).

**Upstream/generic build** (Debian-based, needs g++-10+, cmake ≥ 3.11; `bash build.sh -i apt` installs deps):

```bash
bash build.sh          # Release, static libs, target iEDA -> bin/iEDA
bash build.sh -r       # also run scripts/hello.tcl smoke test
bash build.sh -p       # build AiEDA Python bindings (target ieda_py, BUILD_PYTHON=ON)
bash build.sh -s       # address sanitizer;  -g GUI;  -G GPU;  -D dry-run;  -d clean artifacts
```

Key CMake options: `BUILD_STATIC_LIB` (default ON; mutually exclusive with `BUILD_PYTHON`), `COMPATIBILITY_MODE` (default ON — turning it OFF enables `-march=native` + LTO and force-disables `USE_GPU`), `SANITIZER`, `ENABLE_AI`. Some components (e.g. iRT) are Rust — cargo builds are wired in via `cmake/rust.cmake`; `build.sh -d` cleans Rust `target/` dirs too.

## Test / Regression

There is no global `ctest` setup. Testing is done at two levels:

- **Unit tests**: gtest-based, per-module `test/` dirs (e.g. `src/utility/test`). Built only when a module opts in (e.g. `src/utility/CMakeLists.txt` builds `base_test` under `BASE_RUN_TESTS`); run the produced test binary directly and filter with `--gtest_filter=Suite.Case` for a single test.
- **Flow regression** (the practical verification for tool changes — runs real gcd designs netlist→GDS):

```bash
scripts/integration/regress_gcd.sh   # sky130 + ics55, checks final GDS, logs to regress_logs/
scripts/integration/run_sky130.sh    # single flow; run_ics55.sh needs PDK_DIR
```

Per-design flows live in `scripts/design/<pdk>_gcd/run_iEDA.sh`, which chains Tcl scripts per stage (iFP → iNO → iPL → iCTS → iTO → iRT → iDRC → iPW, each under `script/<Tool>_script/run_*.tcl`). To debug one stage, run `bin/iEDA -script <that .tcl>` from the design dir. Metrics land in each design's `result/` (STA: `result/to/{drv,hold}/sta/gcd.rpt`, DRC: `result/drc/detail.drc`).

## Architecture

The binary is a thin main (`src/apps/ieda_main.cpp`) over a layered stack; every physical-design tool follows the same Database → Manager → Operator → (Tcl/Python) Interface pattern.

- `src/interface/tcl/` — Tcl command layer, one `tcl_<tool>` module per tool, each with a `tcl_register_<tool>.h` registering its commands; `tcl_register.cpp` wires all modules into the interpreter. Adding a user-facing command means adding a Tcl wrapper here that calls into the tool's API. Also `src/interface/python/` (pybind11 bindings) and `src/interface/shell/`, `gui/`, `mcp-iEDA/`.
- `src/operation/i*` — the tools themselves: iFP (floorplan), iPL (placement), iCTS (clock tree), iNO/iTO (timing opt), iRT (router, Rust-accelerated), iDRC, iSTA (timing), iPW (power), iPDN/iPNP (power grid), iECO, iIR, iRCX, iTM, iLO, iPA. Each is built via `cmake/operation/*.cmake` includes from the top-level CMakeLists.
- `src/database/` — design data (DEF/LEF/netlist via `interaction/`, `manager/`), the shared in-memory design DB all tools read/write.
- `src/platform/` — flow orchestration, tool manager, data/file/report managers (`flow/flow.h` drives the Tcl flow used by `ieda_main`).
- `src/solver/` — shared algorithms (partitioning, legalization, geometry, steiner, QP) used by tools.
- `src/evaluation/`, `src/feature/`, `src/vectorization/`, `src/ai/` — AiEDA-side: design-quality evaluation APIs, feature extraction for ML, layout vectorization, AI predictors (gated by `ENABLE_AI`).
- `src/utility/` — logging (glog wrapper `log/Log.hh`), string, timing, containers; `src/third_party/` vendored deps.

**Flow model**: tools communicate through the shared design database (and DEF files on disk between stages in the script flows), not by direct calls — a Tcl stage script reads config from `scripts/design/<pdk>_gcd/iEDA_config/` and foundry data from `$FOUNDRY_ROOT` (`/home/lxq/AiEDA/Foundary` locally; PDKs: sky130, ics55, nangate45; ihp130 is a git submodule under `scripts/foundry/`).

## Conventions

- Copyright header block (Peng Cheng Laboratory / ICT / BOSC + Mulan PSL v2) on every source file — copy it when creating new files.
- `.clang-format` at repo root governs C++ style.
- iEDA requires `-DGLOG_USE_GLOG_EXPORT` (set globally) for glog 0.7.1+.
- Local environment quirks and current bring-up status (which PDK flows pass, pending TODOs) are tracked in **BUILD-NOTES.md** — update it when flow status changes.
