#!/usr/bin/env bash
# Congestion-driven GP sweep: Innovus low/high congestion vs iEDA wirelength
# and iEDA congestion-effort GP. All placements are GP-only (no refinePlace,
# no LG/DP). Congestion metrics are tool-native:
#   - Innovus: early-global-route overflow % from placeDesign log
#   - iEDA:    max(H,V) RUDY route utilization from session result
# HPWL uses the common LEF-pin evaluator.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CASE="${1:-s1238}"
PLV_CASES_ROOT="${PLV_CASES_ROOT:-/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases}"
CASE_ROOT="$PLV_CASES_ROOT/$CASE"
WORK="$ROOT/benchmarks/results/innovus_gp_congestion_sweep/$CASE"
COMMON_EVAL="$ROOT/benchmarks/flows/def_hpwl_eval.py"
INNOVUS_BIN="${INNOVUS_BIN:-/usr/local/bin/innovus}"
IEDa_BIN="$ROOT/build/bin/iEDA"
export LM_LICENSE_FILE="${LM_LICENSE_FILE:-/home/yangkang/cadence/INNOVUS201/license/cadence.dat}"
export CDS_LIC_FILE="${CDS_LIC_FILE:-/home/yangkang/cadence/INNOVUS201/license/cadence.dat}"
TECH_LEF="/home/yangkang/project/Open3DBench-Harness/Harness-OpenROAD-3D/iDATA/innovus/pdk/sky130_fd_sc_hd_innovus_tech.lef"
MACRO_LEF="$ROOT/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
LIB_FILE="$ROOT/scripts/foundry/sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
NETLIST="/home/yangkang/project/Open3DBench-Harness/Harness-OpenROAD-3D/iDATA/$CASE/route/${CASE}_a_route.v"
IN_DEF="$CASE_ROOT/innovus_in.def"
CONFIG_DIR="$CASE_ROOT/iEDA_config"
TCL_SCRIPT_DIR="$CASE_ROOT/script"
FOUNDRY_DIR="$ROOT/scripts/foundry/sky130"
SDC_FILE="$CASE_ROOT/$CASE.sdc"
MAX_ITER=$(python3 - <<PY
import json
cfg=json.load(open("$CONFIG_DIR/pl_default_config.json"))
print(cfg["PL"]["GP"]["Nesterov"]["max_iter"])
PY
)
rm -rf "$WORK"; mkdir -p "$WORK"

# ---- common MMMC ----
sed "s#/home/yangkang/project/iDATA/foundry/sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib#$LIB_FILE#" \
  "$PLV_CASES_ROOT/mmmc_notiming.tcl" > "$WORK/mmmc_notiming.tcl"
: > "$WORK/empty.sdc"

run_innovus() {
  local effort="$1" tag="$2"
  local out_def="$WORK/innovus_${tag}.def" log="$WORK/innovus_${tag}.log" tcl="$WORK/innovus_${tag}.tcl"
  cat > "$tcl" <<TCL
set init_lef_file [list $TECH_LEF $MACRO_LEF]
set init_verilog $NETLIST
set init_design_netlisttype Verilog
set init_top_cell $CASE
set init_pwr_net VDD
set init_gnd_net VSS
set init_mmmc_file [list $WORK/mmmc_notiming.tcl]
init_design
catch {globalNetConnect VDD -type pgpin -pin VPWR -all}
catch {globalNetConnect VSS -type pgpin -pin VGND -all}
catch {globalNetConnect VSS -type pgpin -pin VNB -all}
catch {globalNetConnect VDD -type pgpin -pin VPB -all}
defIn $IN_DEF
setPlaceMode -place_global_cong_effort $effort -place_detail_wire_length_opt_effort none
setPlaceMode -place_design_refine_place false
placeDesign
defOut -netlist $out_def
exit
TCL
  (cd "$WORK" && timeout 1200 "$INNOVUS_BIN" -no_gui -files "$(basename "$tcl")" > "$log" 2>&1) || { echo "Innovus $tag failed" >&2; exit 1; }
  python3 "$COMMON_EVAL" "$MACRO_LEF" "$out_def" > "$WORK/innovus_${tag}_hpwl.txt"
}

run_innovus low low
run_innovus high high

# ---- iEDA input from low Innovus DEF (same netlist/floorplan) ----
python3 - <<PY
import re
from pathlib import Path
src=Path("$WORK/innovus_low.def").read_text()
start=src.find("\nCOMPONENTS"); he=src.find("\n", start+1); end=src.find("END COMPONENTS")
blocks=[]; cur=None
for line in src[he:end].splitlines():
    if re.match(r"\s*-\s+", line):
        if cur is not None: blocks.append(cur)
        cur=[line]
    elif cur is not None: cur.append(line)
if cur is not None: blocks.append(cur)
out=[]
for block in blocks:
    m=re.match(r"\s*-\s+(\S+)\s+(\S+)", " ".join(block))
    out.append(f"{m.group(0).rstrip()} + UNPLACED ;" if m else " ".join(block))
merged=src[:start]+"\n"+src[start+1:he]+"\n"+"\n".join(out)+"\n"+src[end:]
Path("$WORK/ieda_in_unplaced.def").write_text(merged)
PY

make_ieda_config() {
  local mode="$1" path="$2"
  python3 - <<PY
import json
cfg=json.load(open("$CONFIG_DIR/pl_default_config.json"))
cfg["PL"]["is_congestion_effort"]=1 if "$mode"=="cong" else 0
json.dump({"PL":cfg["PL"]}, open("$path","w"), indent=2)
PY
}
make_ieda_config wl "$WORK/pl_wl.json"
make_ieda_config cong "$WORK/pl_cong.json"

run_ieda() {
  local mode="$1" cfg="$2" tag="$3"
  local out_def="$WORK/ieda_${tag}.def" log="$WORK/ieda_${tag}.log" tcl="$WORK/ieda_${tag}.tcl"
  cat > "$tcl" <<TCL
flow_init -config $CONFIG_DIR/flow_config.json
db_init -config $CONFIG_DIR/db_default_config.json -output_dir_path $WORK
source $TCL_SCRIPT_DIR/DB_script/db_path_setting.tcl
source $TCL_SCRIPT_DIR/DB_script/db_init_lef.tcl
def_init -path $WORK/ieda_in_unplaced.def
init_pl -config $cfg
placer_run_gp -mode start -iterations $MAX_ITER -seed 1000
catch {placer_run_gp -mode accept}
def_save -path $out_def
flow_exit
TCL
  (cd "$ROOT" && env CONFIG_DIR="$CONFIG_DIR" RESULT_DIR="$WORK" TCL_SCRIPT_DIR="$TCL_SCRIPT_DIR" \
      FOUNDRY_DIR="$FOUNDRY_DIR" SDC_FILE="$SDC_FILE" timeout 1800 "$IEDa_BIN" -script "$tcl" > "$log" 2>&1) || { echo "iEDA $tag failed" >&2; exit 1; }
  python3 "$COMMON_EVAL" "$MACRO_LEF" "$out_def" > "$WORK/ieda_${tag}_hpwl.txt"
}

run_ieda wl "$WORK/pl_wl.json" wl
run_ieda cong "$WORK/pl_cong.json" cong

# ---- aggregate ----
python3 - <<PY
import json, re
from pathlib import Path
work=Path("$WORK")
def hpwl(f):
    return int(re.search(r'HPWL=(\d+)', (work/f).read_text()).group(1))
def parse_ieda_line(log, tag):
    text=(work/log).read_text(errors='ignore')
    m=re.search(r'iPL gp\.run.*?stop_reason=(\S+).*?iterations=(\d+)-(\d+) hpwl=(\d+) overflow=([0-9.]+) step_length=([0-9.e+-]+) density_penalty=([0-9.e+-]+) route_util=([0-9.e+-]+)', text)
    return m.groups() if m else None
def parse_innovus_overflow(log):
    text=(work/log).read_text(errors='ignore')
    lines=[l for l in text.splitlines() if 'Overflow after Early Global Route' in l and 'GR compatible' not in l]
    if not lines: return None
    m=re.search(r'([0-9.]+)% H \+ ([0-9.]+)% V', lines[-1])
    return (float(m.group(1)), float(m.group(2))) if m else None
result={
 "design":"$CASE",
 "innovus_low":{"hpwl":hpwl("innovus_low_hpwl.txt"),"egr_overflow_h_v_pct":parse_innovus_overflow("innovus_low.log")},
 "innovus_high":{"hpwl":hpwl("innovus_high_hpwl.txt"),"egr_overflow_h_v_pct":parse_innovus_overflow("innovus_high.log")},
 "ieda_wl":{"hpwl":hpwl("ieda_wl_hpwl.txt"),"session":parse_ieda_line("ieda_wl.log","wl")},
 "ieda_cong":{"hpwl":hpwl("ieda_cong_hpwl.txt"),"session":parse_ieda_line("ieda_cong.log","cong")},
}
(work/'result.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
PY
echo "RESULT=$WORK/result.json"
