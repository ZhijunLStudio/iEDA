#!/usr/bin/env bash
# Innovus -noPrePlaceOpt vs iEDA GP-only comparison, same full netlist.
#
# Reuses the existing noPrePlaceOpt Innovus DEFs produced by
#   /home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/run_no_preopt.sh
# and reruns iEDA GP from an unplaced DEF derived from that exact DEF, so both
# tools solve the same netlist (no pre-place buffer-tree deletion).
#
# Usage:
#   benchmarks/flows/run_innovus_gp_compare_nodel.sh [s1238|apb4_timer|picorv32|aes]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLV_CASES_ROOT="${PLV_CASES_ROOT:-/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases}"
RESULT_ROOT="$ROOT/benchmarks/results/innovus_gp_compare_nodel"
COMMON_EVAL="$ROOT/benchmarks/flows/def_hpwl_eval.py"
IEDa_BIN="$ROOT/build/bin/iEDA"
FOUNDRY_DIR="$ROOT/scripts/foundry/sky130"
MACRO_LEF="$FOUNDRY_DIR/lef/sky130_fd_sc_hd_merged.lef"

CASE="${1:-s1238}"
CASE_ROOT="$PLV_CASES_ROOT/$CASE"
CONFIG_DIR="$CASE_ROOT/iEDA_config"
TCL_SCRIPT_DIR="$CASE_ROOT/script"
SDC_FILE="$CASE_ROOT/$CASE.sdc"
INNOVUS_NODEL_DEF="$CASE_ROOT/innovus_placed_nodel.def"

for f in "$MACRO_LEF" "$INNOVUS_NODEL_DEF" "$CONFIG_DIR/flow_config.json"; do
  [ -f "$f" ] || { echo "MISSING INPUT: $f" >&2; exit 2; }
done

WORK="$RESULT_ROOT/$CASE"
rm -rf "$WORK"
mkdir -p "$WORK"

# ---------- common evaluator on the Innovus noPrePlaceOpt placement ----------
INNOVUS_HPWL_OUT="$WORK/innovus_nodel_hpwl.txt"
python3 "$COMMON_EVAL" "$MACRO_LEF" "$INNOVUS_NODEL_DEF" > "$INNOVUS_HPWL_OUT"
grep -q '^HPWL=' "$INNOVUS_HPWL_OUT" || { echo "HPWL eval failed for $INNOVUS_NODEL_DEF" >&2; exit 1; }

# ---------- same-netlist unplaced DEF for iEDA ----------
IEDa_IN_DEF="$WORK/ieda_in_unplaced.def"
python3 - <<PY
import re
from pathlib import Path
src = Path("$INNOVUS_NODEL_DEF").read_text()
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
    out.append(f"{m.group(0).rstrip()} + UNPLACED ;")
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
GP_MODE="legacy-full"
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
run_ieda_script() {
  local tcl=$1 log=$2
  ( cd "$ROOT" && env CONFIG_DIR="$CONFIG_DIR" RESULT_DIR="$WORK" TCL_SCRIPT_DIR="$TCL_SCRIPT_DIR" \
        FOUNDRY_DIR="$FOUNDRY_DIR" SDC_FILE="$SDC_FILE" \
        timeout 1800 "$IEDa_BIN" -script "$tcl" > "$log" 2>&1 )
}
set +e
run_ieda_script "$WORK/ieda_gp.tcl" "$IEDa_LOG"
ieda_rc=$?
set -e

# Some full-netlist designs (picorv32) trip the legacy divergence detector just
# before the overflow target. The session path can stop one batch earlier and
# commit that placement cleanly.
if [ "$ieda_rc" -ne 0 ] || [ ! -f "$WORK/ieda_gp.def" ]; then
  echo "legacy iEDA GP failed (rc=$ieda_rc); retrying with a 530-iteration session; see $IEDa_LOG" >&2
  cp "$IEDa_LOG" "$WORK/ieda_legacy_fail.log" || true
  GP_MODE="session-530-fallback"
  cat > "$WORK/ieda_gp.tcl" <<TCL
flow_init -config $CONFIG_DIR/flow_config.json
db_init -config $CONFIG_DIR/db_default_config.json -output_dir_path $WORK
source $TCL_SCRIPT_DIR/DB_script/db_path_setting.tcl
source $TCL_SCRIPT_DIR/DB_script/db_init_lef.tcl
def_init -path $IEDa_IN_DEF
init_pl -config $IEDa_CONFIG
placer_run_gp -mode start -iterations 530 -seed 1000
placer_run_gp -mode accept
def_save -path $WORK/ieda_gp.def
flow_exit
TCL
  IEDa_LOG="$WORK/ieda.log"
  set +e
  run_ieda_script "$WORK/ieda_gp.tcl" "$IEDa_LOG"
  ieda_rc=$?
  set -e
fi
if [ "$ieda_rc" -ne 0 ] || [ ! -f "$WORK/ieda_gp.def" ]; then
  echo "iEDA GP FAILED rc=$ieda_rc; see $IEDa_LOG" >&2
  exit 1
fi

# ---------- common HPWL for the iEDA GP result ----------
IEDa_HPWL_OUT="$WORK/ieda_hpwl.txt"
python3 "$COMMON_EVAL" "$MACRO_LEF" "$WORK/ieda_gp.def" > "$IEDa_HPWL_OUT"
grep -q '^HPWL=' "$IEDa_HPWL_OUT" || { echo "HPWL eval failed for iEDA DEF" >&2; exit 1; }

innovus_hpwl=$(sed -n 's/HPWL=\([0-9]*\).*/\1/p' "$INNOVUS_HPWL_OUT")
ieda_hpwl=$(sed -n 's/HPWL=\([0-9]*\).*/\1/p' "$IEDa_HPWL_OUT")

python3 - <<PY
import json, re
from pathlib import Path
work = Path("$WORK")
hpwl_i = int("$ieda_hpwl")
hpwl_n = int("$innovus_hpwl")
log = (work / "ieda.log").read_text(errors="ignore")
gp_overflow = None
gp_hpwl_log = None
m = re.search(r"Finished with Overflow:([0-9.]+) HPWL : (\d+)", log)
if m:
    gp_overflow = float(m.group(1))
    gp_hpwl_log = int(m.group(2))
else:
    m = re.search(r"iPL gp\.run \(start, (\d+) iterations\).*?hpwl=(\d+) overflow=([0-9.eE+-]+)", log)
    if m:
        gp_overflow = float(m.group(3))
        gp_hpwl_log = int(m.group(2))
result = {
    "design": "$CASE",
    "innovus": {"mode": "placeDesign -noPrePlaceOpt", "hpwl": hpwl_n,
                "def": "$INNOVUS_NODEL_DEF", "hpwl_out": "$INNOVUS_HPWL_OUT"},
    "ieda": {"mode": "$GP_MODE", "hpwl": hpwl_i, "overflow": gp_overflow,
             "gp_hpwl_log": gp_hpwl_log,
             "def": str(work / "ieda_gp.def"), "hpwl_out": "$IEDa_HPWL_OUT"},
    "ratio_ieda_over_innovus": hpwl_i / hpwl_n if hpwl_n else None,
    "improvement_pct": (1.0 - hpwl_i / hpwl_n) * 100.0 if hpwl_n else None,
}
(work / "result.json").write_text(json.dumps(result, indent=2))
print(json.dumps(result, indent=2))
PY

echo "RESULT=$WORK/result.json"
