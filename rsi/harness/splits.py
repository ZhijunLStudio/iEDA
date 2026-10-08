"""Deterministic task splits and the sealed gate.

Source domain is sky130; DEV/VAL/SEALED are disjoint thirds-by-hash of the
sky130 cases. Every other technology is the out-of-distribution transfer set.
The gate is enforced by the runner: a design that is sealed must never appear in
any prompt, knowledge file or agent context, and the gate exists so that a
campaign cannot quietly consume its own test set.
"""
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R

SPLIT_FILE = HERE / "splits.json"
SOURCE_PDK = "sky130"


def build(seed="splits-v1"):
    designs = R.load_designs()
    usable = {}
    for name, rec in designs.items():
        ok = all(Path(rec[k]).exists() for k in ("input_def", "pl_config")
                 if rec.get(k))
        if rec.get("case_root"):
            ok = ok and Path(rec["case_root"]).exists()
        if ok:
            usable[name] = rec
    src = sorted(n for n, r in usable.items() if r.get("pdk") == SOURCE_PDK)
    ood = sorted(n for n, r in usable.items() if r.get("pdk") != SOURCE_PDK)

    def key(n):
        return hashlib.sha256(("%s|%s" % (seed, n)).encode()).hexdigest()

    ordered = sorted(src, key=key)
    n_dev = max(1, int(round(len(ordered) * 0.55)))
    n_val = max(1, int(round(len(ordered) * 0.20)))
    split = {"dev": ordered[:n_dev],
             "val": ordered[n_dev:n_dev + n_val],
             "sealed": ordered[n_dev + n_val:],
             "ood": ood,
             "excluded": sorted(set(designs) - set(usable))}
    return split


def load():
    if SPLIT_FILE.exists():
        return json.loads(SPLIT_FILE.read_text())
    s = build()
    SPLIT_FILE.write_text(json.dumps(s, indent=1))
    return s


def sealed_gate(context_blob, splits=None):
    """Return the sealed names that leaked into a context blob."""
    s = splits or load()
    return sorted(n for n in s.get("sealed", []) if n in (context_blob or ""))


def assert_clean(context_blob):
    leaked = sealed_gate(context_blob)
    if leaked:
        raise RuntimeError("sealed designs present in context: %s" % leaked)
    return True


def main():
    s = load()
    for k in ("dev", "val", "sealed", "ood", "excluded"):
        print("%-9s %2d  %s" % (k, len(s.get(k, [])), ", ".join(s.get(k, []))))
    return 0


if __name__ == "__main__":
    sys.exit(main())
