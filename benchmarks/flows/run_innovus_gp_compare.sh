#!/usr/bin/env bash
# GP-only Innovus vs iEDA comparison (wirelength-only, no timing/congestion).
#
# Protocol:
#   1. Innovus placeDesign from the same verilog + floorplan DEF.
#   2. Export Innovus DEF with -netlist.
#   3. Turn every movable component UNPLACED and feed that exact DEF to iEDA GP.
#      => both tools therefore solve the same netlist, die/core/rows, and PDK.
#   4. Evaluate both placements with benchmarks/flows/def_hpwl_eval.py.
#
# Usage:
#   benchmarks/flows/run_innovus_gp_compare.sh [s1238|apb4_timer|picorv32|aes]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULT_ROOT="$ROOT/benchmarks/results/innovus_gp_compare"
COMMON_EVAL="$ROOT/benchmarks/flows/def_hpwl_eval.py"
INNOVUS_BIN="${INNOVUS_BIN:-/usr/local/bin/innovus}"
IEDa_BIN="$ROOT/build/bin/iEDA"
export LM_LICENSE_FILE="${LM_LICENSE_FILE:-/home/yangkang/cadence/INNOVUS201/license/cadence.dat}"
export CDS_LIC_FILE="${CDS_LIC_FILE:-/home/yangkang/cadence/INNOVUS201/license/cadence.dat}"

CASE="${1:-s1238}"
PLV_CASES_ROOT="${PLV_CASES_ROOT:-/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases}"
CASE_ROOT="$PLV_CASES_ROOT/$CASE"
TECH_LEF="/home/yangkang/project/Open3DBench-Harness/Harness-OpenROAD-3D/iDATA/innovus/pdk/sky130_fd_sc_hd_innovus_tech.lef"
MACRO_LEF="$ROOT/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
LIB_FILE="$ROOT/scripts/foundry/sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
FOUNDRY_DIR="$ROOT/scripts/foundry/sky130"
NETLIST="/home/yangkang/project/Open3DBench-Harness/Harness-OpenROAD-3D/iDATA/$CASE/route/${CASE}_a_route.v"
IN_DEF="$CASE_ROOT/innovus_in.def"
CONFIG_DIR="$CASE_ROOT/iEDA_config"
TCL_SCRIPT_DIR="$CASE_ROOT/script"
SDC_FILE="$CASE_ROOT/$CASE.sdc"

for f in "$TECH_LEF" "$MACRO_LEF" "$LIB_FILE" "$NETLIST" "$IN_DEF"; do
  [ -f "$f" ] || { echo "MISSING INPUT: $f" >&2; exit 2; }
done

WORK="$RESULT_ROOT/$CASE"
rm -rf "$WORK"
mkdir -p "$WORK"

# ---------- Innovus ----------
INNOVUS_OUT_DEF="$WORK/innovus_placed.def"
cp "$PLV_CASES_ROOT/innovus_place_notiming.tcl" "$WORK/innovus_run.tcl"
sed "s#defOut \$out_def#defOut -netlist \$out_def#" "$WORK/innovus_run.tcl" | \
    sed "/setPlaceMode -place_global_cong_effort low/a setPlaceMode -place_design_refine_place false" > "$WORK/innovus_run_nets.tcl"
sed "s#/home/yangkang/project/iDATA/foundry/sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib#$LIB_FILE#" \
    "$PLV_CASES_ROOT/mmmc_notiming.tcl" > "$WORK/mmmc_notiming.tcl"
: > "$WORK/empty.sdc"

INNOVUS_LOG="$WORK/innovus.log"
set +e
(
  cd "$WORK"
  env TECH_LEF="$TECH_LEF" MACRO_LEF="$MACRO_LEF" VERILOG="$NETLIST" IN_DEF="$IN_DEF" \
      OUT_DEF="$INNOVUS_OUT_DEF" TOP_CELL="$CASE" \
      timeout 1200 "$INNOVUS_BIN" -no_gui -files innovus_run_nets.tcl > "$INNOVUS_LOG" 2>&1
)
innovus_rc=$?
set -e
if [ "$innovus_rc" -ne 0 ] || ! grep -q "INNOVUS_PLACE_FINISHED" "$INNOVUS_LOG"; then
  echo "INNOVUS FAILED rc=$innovus_rc; see $INNOVUS_LOG" >&2
  exit 1
fi

# ---------- Prepare same-netlist unplaced DEF for iEDA ----------
IEDa_IN_DEF="$WORK/ieda_in_unplaced.def"
python3 - <<PY
import re
from pathlib import Path
src = Path("$INNOVUS_OUT_DEF").read_text()
start = src.find("\nCOMPONENTS")
header_end = src.find("\n", start + 1)
end = src.find("END COMPONENTS")
blocks = []
cur = None
for line in src[header_end:end].splitlines():
    if re.match(r"\s*-\s+", line):
        if cur is not None:
            blocks.append(cur)
        cur = [line]
    elif cur is not None:
        cur.append(line)
if cur is not None:
    blocks.append(cur)
out = []
for block in blocks:
    joined = " ".join(block)
    m = re.match(r"\s*-\s+(\S+)\s+(\S+)", joined)
    if not m:
        out.append(joined)
        continue
    line = f"{m.group(0).rstrip()} + UNPLACED ;"
    out.append(line)
merged = src[:start] + "\n" + src[start + 1 : header_end] + "\n" + "\n".join(out) + "\n" + src[end:]
Path("$IEDa_IN_DEF").write_text(merged)
PY

# ---------- iEDA legacy full GP ----------
IEDa_CONFIG="$WORK/pl_clean_config.json"
python3 - <<PY
import json
from pathlib import Path
cfg = json.load(open("$CONFIG_DIR/pl_default_config.json"))
json.dump({"PL": cfg["PL"]}, open("$IEDa_CONFIG", "w"), indent=2)
PY
cat > "$WORK/ieda_gp.tcl" <<TCL
flow_init -config $CONFIG_DIR/flow_config.json
db_init -config $CONFIG_DIR/db_default_config.json -output_dir_path $WORK
source $TCL_SCRIPT_DIR/DB_script/db_path_setting.tcl
source $TCL_SCRIPT_DIR/DB_script/db_init_lef.tcl
def_init -path $IEDa_IN_DEF
init_pl -config $IEDa_CONFIG
placer_run_gp
def_save -path $WORK/ieda_gp.def
flow_exit
TCL

IEDa_LOG="$WORK/ieda.log"
set +e
(
  cd "$ROOT"
  env CONFIG_DIR="$CONFIG_DIR" RESULT_DIR="$WORK" TCL_SCRIPT_DIR="$TCL_SCRIPT_DIR" \
      FOUNDRY_DIR="$FOUNDRY_DIR" SDC_FILE="$SDC_FILE" \
      timeout 1200 "$IEDa_BIN" -script "$WORK/ieda_gp.tcl" > "$IEDa_LOG" 2>&1
)
ieda_rc=$?
set -e
if [ "$ieda_rc" -ne 0 ] || [ ! -f "$WORK/ieda_gp.def" ]; then
  echo "iEDA GP FAILED rc=$ieda_rc; see $IEDa_LOG" >&2
  exit 1
fi

# ---------- Common HPWL ----------
INNOVUS_HPWL_OUT="$WORK/innovus_hpwl.txt"
IEDa_HPWL_OUT="$WORK/ieda_hpwl.txt"
python3 "$COMMON_EVAL" "$MACRO_LEF" "$INNOVUS_OUT_DEF" > "$INNOVUS_HPWL_OUT"
python3 "$COMMON_EVAL" "$MACRO_LEF" "$WORK/ieda_gp.def" > "$IEDa_HPWL_OUT"

innovus_hpwl=$(sed -n 's/HPWL=\([0-9]*\).*/\1/p' "$INNOVUS_HPWL_OUT")
ieda_hpwl=$(sed -n 's/HPWL=\([0-9]*\).*/\1/p' "$IEDa_HPWL_OUT")
ieda_overflow=$(grep -o 'Finished with Overflow:[0-9.]* HPWL : [0-9]*' "$IEDa_LOG" | tail -1 | sed 's/Finished with Overflow:\([0-9.]*\).*/\1/')
innovus_bbox=$(grep 'Total net bbox =' "$INNOVUS_LOG" | tail -1 | sed -E 's/.*Total net bbox = ([0-9.e+]+).*/\1/' || true)

python3 - <<PY
import json, re
from pathlib import Path
work = Path("$WORK")
hpwl_i = int("$ieda_hpwl")
hpwl_n = int("$innovus_hpwl")
log = (work / "ieda.log").read_text(errors="ignore")
m = re.search(r"Finished with Overflow:([0-9.]+) HPWL : (\d+)", log)
result = {
    "design": "$CASE",
    "innovus": {
        "hpwl": hpwl_n,
        "final_bbox_log_um": "$innovus_bbox",
        "def": str(work / "innovus_placed.def"),
    },
    "ieda": {
        "hpwl": hpwl_i,
        "overflow": float(m.group(1)) if m else None,
        "gp_hpwl_log": int(m.group(2)) if m else None,
        "def": str(work / "ieda_gp.def"),
    },
    "ratio_ieda_over_innovus": hpwl_i / hpwl_n if hpwl_n else None,
    "improvement_pct": (1.0 - hpwl_i / hpwl_n) * 100.0 if hpwl_n else None,
}
(work / "result.json").write_text(json.dumps(result, indent=2))
print(json.dumps(result, indent=2))
PY

echo "RESULT=$WORK/result.json"
