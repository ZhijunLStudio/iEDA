"""RSI harness core: paths, designs, cost ledger, run wrappers.

Protocol: ieda/rsi/protocol/PROTOCOL-v1.0.md
Every run appends exactly one ledger record (protocol section 9).
"""
import hashlib
import json
import os
import resource
import subprocess
import time
from pathlib import Path

RSI_ROOT = Path(os.environ.get("RSI_ROOT", str(Path(__file__).resolve().parents[3])))
IEDA_ROOT = RSI_ROOT / "ieda"
FLOWS = IEDA_ROOT / "benchmarks/flows"
RSI = IEDA_ROOT / "rsi"
HARNESS = RSI / "harness"
RUNS = Path(os.environ.get("RSI_RUNS", str(RSI_ROOT / "runs")))
PROTOCOL = RSI / "protocol/PROTOCOL-v1.0.md"
PROTOCOL_SHA_FILE = RSI / "protocol/PROTOCOL-v1.0.sha256"
LEDGER = RUNS / "ledger.jsonl"
PY = "/usr/bin/python3"

VERIFIER_LEVELS = {
    "V0": "gp-internal hpwl / route_util (unlegalized, seconds)",
    "V1": "legalized DEF HPWL (tens of seconds)",
    "V2": "V1 + iRT EGR union/peak (minutes)",
    "V3": "V2 + iSTA timing (tens of minutes)",
    "V4": "V3 + full flow to GDS + iDRC (hours)",
}


def ensure_dirs():
    for d in (RUNS, RUNS / "runs", RUNS / "logs"):
        d.mkdir(parents=True, exist_ok=True)


def protocol_hash():
    return hashlib.sha256(PROTOCOL.read_bytes()).hexdigest()


def check_protocol():
    want = PROTOCOL_SHA_FILE.read_text().split()[0]
    got = protocol_hash()
    if want != got:
        raise RuntimeError("protocol hash mismatch: frozen=%s actual=%s" % (want, got))
    return got


def load_designs():
    return json.loads((HARNESS / "designs.local.json").read_text())


def code_fingerprint(paths):
    h = hashlib.sha256()
    for p in sorted(paths):
        try:
            h.update(Path(p).read_bytes())
        except OSError:
            h.update(b"missing")
    return h.hexdigest()[:16]


def stable_seed(*parts):
    """A seed that does not depend on PYTHONHASHSEED.

    Python's hash() of a tuple is salted per process, so a loop seeded with it
    proposes different candidates on every run and the trajectory cannot be
    reproduced. Any stochastic choice in the harness must be seeded from this.
    """
    h = hashlib.sha256("|".join(str(p) for p in parts).encode()).hexdigest()
    return int(h[:12], 16)


def binary_fingerprint():
    """Identity of the placement solver, so a cached measurement is only reused
    while the solver that produced it is unchanged."""
    b = IEDA_ROOT / "build/bin/iEDA"
    try:
        st = b.stat()
        return "%d-%d" % (st.st_size, int(st.st_mtime))
    except OSError:
        return "missing"


def improver_id(tag, code_paths):
    h = hashlib.sha256()
    h.update(tag.encode())
    h.update(code_fingerprint(code_paths).encode())
    return h.hexdigest()[:16]


def _cpu_children():
    r = resource.getrusage(resource.RUSAGE_CHILDREN)
    return r.ru_utime + r.ru_stime


def foundry_of(rec):
    fd = rec.get("foundry_dir")
    if fd:
        return fd
    pdk = rec.get("pdk")
    if pdk:
        cand = IEDA_ROOT / "scripts/foundry" / pdk
        if cand.exists():
            return str(cand)
    raise KeyError("no foundry_dir and no resolvable pdk for design")


def lef_of(rec):
    lf = rec.get("lef")
    if lf and Path(lf).exists():
        return lf
    fd = Path(foundry_of(rec))
    best = None
    for p in sorted(fd.rglob("*.lef")):
        if "merged" in p.name:
            return str(p)
        if best is None or p.stat().st_size > Path(best).stat().st_size:
            best = str(p)
    return best


def base_env():
    e = dict(os.environ)
    e.setdefault("IEDA_BIN", str(IEDA_ROOT / "build/bin/iEDA"))
    e.setdefault("RSI_ROOT", str(RSI_ROOT))
    return e


def run_cmd(cmd, cwd=None, timeout=None, env=None):
    e = base_env()
    if env:
        e.update(env)
    # Pin the OpenMP thread count. 48 of the 50 "pragma omp parallel" regions in the tree
    # do not specify num_threads, so they inherit the default, which is the number of
    # visible cores. Under taskset that changes with the core range, and the parallel
    # reductions then reorder floating-point additions, which changes the solver
    # trajectory: gcd_sky130_a measured 8185835 under a 32-core range and 8595054 under a
    # 64-core range with the same binary and the same input. Pinning makes a run depend on
    # the input and the binary only, which is what a comparison needs.
    e.setdefault("OMP_NUM_THREADS", os.environ.get("RSI_OMP_THREADS", "1"))
    cs = e.get("RSI_CPUSET", os.environ.get("RSI_CPUSET", ""))
    if cs:
        cmd = ["taskset", "-c", cs] + list(cmd)
    c0 = _cpu_children()
    t0 = time.monotonic()
    try:
        p = subprocess.run(cmd, cwd=str(cwd or FLOWS), env=e,
                           capture_output=True, text=True, timeout=timeout)
        rc, out, err = p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired as ex:
        rc, out, err = 124, (ex.stdout or b"").decode("utf8", "replace") if isinstance(ex.stdout, bytes) else (ex.stdout or ""), "TIMEOUT"
    wall = time.monotonic() - t0
    cpu = _cpu_children() - c0
    return {"rc": rc, "stdout": out, "stderr": err, "wall_s": round(wall, 3), "cpu_s": round(cpu, 3)}


def _last_json(text):
    i = text.rfind("\n{")
    if i < 0:
        i = text.find("{")
        if i < 0:
            return None
    try:
        return json.loads(text[i:])
    except Exception:
        pass
    for end in range(len(text), 0, -1):
        try:
            return json.loads(text[:end])
        except Exception:
            continue
    return None


def gp_candidate(design, rec, workdir, target_density=None, congestion_effort=None,
                 seed=1000, iterations=300, timeout=7200, extra=None, legalize=True):
    """Run one knobbed GP candidate (start includes LG+DP; single def_save)."""
    wd = Path(workdir)
    wd.mkdir(parents=True, exist_ok=True)
    cmd = [PY, "gp_agent.py", "start",
           "--workdir", str(wd),
           "--case-root", rec["case_root"],
           "--input-def", rec["input_def"],
           "--config", rec["pl_config"],
           "--foundry-dir", foundry_of(rec),
           "--seed", str(seed),
           "--iterations", str(iterations)]
    _lef = lef_of(rec)
    if _lef:
        cmd += ["--lef", _lef]
    if target_density is not None:
        cmd += ["--target-density", repr(float(target_density))]
    if congestion_effort is not None:
        cmd += ["--congestion-effort", str(int(congestion_effort))]
    if extra:
        cmd += [str(x) for x in extra]
    r = run_cmd(cmd, timeout=timeout)
    r["cmd"] = " ".join(cmd)
    r["json"] = _last_json(r["stdout"] or "")
    stages = [r]
    if legalize:
        cmd2 = [PY, "gp_agent.py", "dp", "--workdir", str(wd),
                "--case-root", rec["case_root"], "--foundry-dir", foundry_of(rec)]
        if _lef:
            cmd2 += ["--lef", _lef]
        r2 = run_cmd(cmd2, timeout=timeout)
        r2["cmd"] = " ".join(cmd2)
        r2["json"] = _last_json(r2["stdout"] or "")
        stages.append(r2)
    r["wall_s"] = round(sum(s["wall_s"] for s in stages), 3)
    r["cpu_s"] = round(sum(s["cpu_s"] for s in stages), 3)
    r["stages"] = [{"rc": s["rc"], "wall_s": s["wall_s"], "cpu_s": s["cpu_s"]} for s in stages]
    r["cost_gp"] = {"wall_s": stages[0]["wall_s"], "cpu_s": stages[0]["cpu_s"], "rc": stages[0]["rc"]}
    r["cost_lgdp"] = ({"wall_s": stages[1]["wall_s"], "cpu_s": stages[1]["cpu_s"], "rc": stages[1]["rc"]}
                      if legalize else {"wall_s": 0.0, "cpu_s": 0.0, "rc": None})
    r["dp_rc"] = stages[-1]["rc"] if legalize else None
    return r


def gp_plain(design, rec, workdir, seed=1000, timeout=14400):
    wd = Path(workdir)
    wd.mkdir(parents=True, exist_ok=True)
    cmd = [PY, "gp_agent.py", "plain", "--workdir", str(wd),
           "--case-root", rec["case_root"], "--input-def", rec["input_def"],
           "--config", rec["pl_config"], "--foundry-dir", foundry_of(rec),
           "--seed", str(seed)]
    _l = lef_of(rec)
    if _l:
        cmd += ["--lef", _l]
    r = run_cmd(cmd, timeout=timeout)
    r["cmd"] = " ".join(cmd)
    r["json"] = _last_json(r["stdout"] or "")
    return r


def egr_of(workdir, rec, def_path=None, timeout=3600):
    wd = Path(workdir)
    cmd = [PY, "gp_agent.py", "egr", "--workdir", str(wd),
           "--case-root", rec["case_root"], "--foundry-dir", foundry_of(rec)]
    if def_path:
        cmd += ["--def-path", str(def_path)]
    r = run_cmd(cmd, timeout=timeout)
    r["json"] = _last_json(r["stdout"] or "")
    return r


def read_state(workdir):
    p = Path(workdir) / "gp_agent_state.json"
    return json.loads(p.read_text()) if p.exists() else {}


def ledger_append(record):
    ensure_dirs()
    record = dict(record)
    record.setdefault("protocol_hash", protocol_hash())
    record.setdefault("ts", time.strftime("%Y-%m-%dT%H:%M:%S%z"))
    with LEDGER.open("a") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")
    return record


def ledger_rows():
    if not LEDGER.exists():
        return []
    rows = []
    for line in LEDGER.read_text().splitlines():
        line = line.strip()
        if line:
            try:
                rows.append(json.loads(line))
            except Exception:
                pass
    return rows


def believed_metrics(state, record):
    """Cheap verifier signals, straight from the run record / state."""
    out = {}
    if record:
        out["gp_internal_hpwl"] = record.get("hpwl")
        out["route_util"] = record.get("route_util")
        out["def_hpwl"] = record.get("def_hpwl")
        out["overflow"] = record.get("overflow")
        out["iterations"] = record.get("end_iteration")
    if state:
        out["best_def_hpwl"] = state.get("best_def_hpwl")
        out["best_checkpoint"] = state.get("best_checkpoint_abs") or state.get("best_checkpoint")
    return out


def truth_metrics(workdir, rec, with_egr=True):
    """The shared fair ruler: independent legalized HPWL + authoritative EGR."""
    out = {}
    st = read_state(workdir)
    out["def"] = str(Path(workdir) / "placement.def")
    out["state_best_def_hpwl"] = st.get("best_def_hpwl")
    if with_egr:
        e = egr_of(workdir, rec)
        j = e.get("json") or {}
        out["egr_ok"] = bool(j.get("ok"))
        out["egr_legalized"] = j.get("legalized")
        for k in ("egr_total_overflow_union", "egr_max_overflow_union",
                  "egr_total_overflow_horizontal", "egr_total_overflow_vertical",
                  "egr_max_overflow_horizontal", "egr_max_overflow_vertical"):
            if j.get(k) is not None:
                out[k] = j[k]
        out["egr_cost_s"] = e["wall_s"]
        if not j.get("ok"):
            out["egr_reason"] = j.get("reason")
    return out


def design_status(design, run_id, arm, round_i, verifier_level, iid, seed,
                  believed, truth, cost, status="ok", note="", extra=None):
    rec = {
        "run_id": run_id, "design": design, "arm": arm, "round": round_i,
        "verifier_level": verifier_level, "improver_id": iid, "seed": seed,
        "wall_seconds": cost.get("wall_s"), "cpu_seconds": cost.get("cpu_s"),
        "llm_calls": 0, "llm_tokens_in": 0, "llm_tokens_out": 0, "human_minutes": 0,
        "believed": believed, "true": truth, "status": status, "note": note,
    }
    if extra:
        rec.update(extra)
    return ledger_append(rec)
