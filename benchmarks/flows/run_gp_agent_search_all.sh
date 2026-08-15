#!/usr/bin/env bash
# Run the A-matrix agent search on all four GP-compare designs.
# Safe to rerun: completed designs with a valid 60-candidate search.json are skipped.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CASE_ROOT="${CASE_ROOT:-/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases}"
WORKDIR="${WORKDIR:-/tmp/gp_agent_search}"
if [[ -z "${DESIGNS[@]:-}" ]]; then DESIGNS=(s1238 apb4_timer picorv32 aes); fi
if [[ -z "${PARENTS[@]:-}" ]]; then PARENTS=(20 60 100 200 400); fi
if [[ -z "${SCOPES[@]:-}" ]]; then SCOPES=(longnet hotspot random region); fi
if [[ -z "${PENALTIES[@]:-}" ]]; then PENALTIES=(0.0 2.0 5.0); fi
TIMEOUT="${TIMEOUT:-5400}"

cd "$ROOT"
for design in "${DESIGNS[@]}"; do
  out="$WORKDIR/$design/search.json"
  if [[ -f "$out" ]]; then
    if python3 - "$out" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
try:
    d = json.loads(p.read_text())
except Exception:
    sys.exit(1)
expected = 60
sys.exit(0 if d.get("ok") and len(d.get("candidates", [])) == expected else 1)
PY
    then
      echo "[skip] $design already has a complete search.json: $out"
      continue
    fi
    echo "[rerun] $design has an incomplete search.json; removing $WORKDIR/$design"
    rm -rf "$WORKDIR/$design"
  fi

  echo "[start] $design -> $WORKDIR/$design"
  mkdir -p "$WORKDIR"
  timeout "$TIMEOUT" python3 benchmarks/flows/run_gp_agent_search.py \
    --design "$design" \
    --case-root "$CASE_ROOT/$design" \
    --workdir "$WORKDIR" \
    --parents "${PARENTS[@]}" \
    --scopes "${SCOPES[@]}" \
    --penalties "${PENALTIES[@]}" \
    > "$WORKDIR/${design}.out" 2> "$WORKDIR/${design}.err"
  echo "[done] $design"
  tail -n 12 "$WORKDIR/${design}.out"
done
echo "[all-done]"
