#!/usr/bin/env python3
"""Generate deterministic synthetic AES VCD/SAIF activity for iPA smoke runs."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def clean_verilog_name(name: str) -> str:
    name = name.strip().strip(",")
    if name.startswith("\\"):
        name = name[1:]
    return name.strip()


def split_signal_tokens(text: str) -> list[str]:
    return [
        clean_verilog_name(token)
        for token in re.split(r"[\s,]+", text)
        if clean_verilog_name(token)
    ]


def expand_decl_names(width: str | None, names: list[str]) -> list[str]:
    expanded: list[str] = []
    msb = lsb = None
    if width:
        match = re.match(r"\[\s*(\d+)\s*:\s*(\d+)\s*\]", width)
        if match:
            msb = int(match.group(1))
            lsb = int(match.group(2))
    for name in names:
        name = clean_verilog_name(name)
        if not name:
            continue
        if re.search(r"\[\d+\]$", name) or msb is None or lsb is None:
            expanded.append(name)
            continue
        step = 1 if lsb <= msb else -1
        expanded.extend(f"{name}[{idx}]" for idx in range(lsb, msb + step, step))
    return expanded


def extract_module_body(text: str, top: str) -> str:
    match = re.search(rf"\bmodule\s+{re.escape(top)}\b(?P<body>.*?);\s", text, flags=re.S)
    if not match:
        return text
    start = match.start()
    end_match = re.search(r"\bendmodule\b", text[match.end() :], flags=re.S)
    if not end_match:
        return text[start:]
    return text[start : match.end() + end_match.end()]


def parse_module_header_ports(module_body: str, top: str) -> list[str]:
    match = re.search(rf"\bmodule\s+{re.escape(top)}\s*\((?P<ports>.*?)\)\s*;", module_body, flags=re.S)
    if not match:
        return []
    return split_signal_tokens(match.group("ports"))


def parse_declared_signals(module_body: str, keywords: tuple[str, ...], *, limit: int | None = None) -> list[str]:
    signals: list[str] = []
    keyword_re = "|".join(re.escape(keyword) for keyword in keywords)
    decl_re = re.compile(rf"\b(?:{keyword_re})\b\s*(?P<width>\[[^\]]+\])?\s*(?P<names>.*?);", re.S)
    for match in decl_re.finditer(module_body):
        names = split_signal_tokens(match.group("names"))
        for signal in expand_decl_names(match.group("width"), names):
            if signal not in signals:
                signals.append(signal)
            if limit is not None and len(signals) >= limit:
                return signals
    return signals


def parse_netlist_signals(path: Path, *, max_internal: int) -> list[str]:
    text = path.read_text(encoding="utf-8", errors="replace")
    return parse_netlist_signals_for_top(text, top=None, max_internal=max_internal)


def parse_netlist_signals_for_top(text: str, *, top: str | None, max_internal: int) -> list[str]:
    if top:
        module_body = extract_module_body(text, top)
    else:
        module_body = text
    signals: list[str] = []
    declared_ports = parse_declared_signals(module_body, ("input", "output", "inout"))
    header_ports = parse_module_header_ports(module_body, top) if top else []
    for signal in declared_ports + header_ports:
        if signal not in signals:
            signals.append(signal)
    internals = parse_declared_signals(module_body, ("wire",), limit=max_internal)
    for name in internals:
        if name not in signals:
            signals.append(name)
        if len(signals) >= len(declared_ports) + len(header_ports) + max_internal:
            break
    if not signals:
        signals = ["clk"]
    deduped: list[str] = []
    for signal in signals:
        if signal and signal not in deduped:
            deduped.append(signal)
    return deduped


def vcd_id(index: int) -> str:
    chars = []
    base = 94
    value = index
    while True:
        chars.append(chr(33 + (value % base)))
        value //= base
        if value == 0:
            break
    return "".join(chars)


def signal_value(signal: str, cycle: int) -> str:
    if signal == "clk":
        return str(cycle & 1)
    if signal == "rst":
        return "1" if cycle < 2 else "0"
    if signal == "ld":
        return "1" if cycle in {2, 18} else "0"
    if match := re.search(r"\[(\d+)\]$", signal):
        idx = int(match.group(1))
        return str(((cycle * 17 + idx * 13 + (idx >> 2)) >> (idx % 5)) & 1)
    digits = re.findall(r"\d+", signal)
    idx = int(digits[-1]) if digits else len(signal)
    return str(((cycle * 31 + idx * 7) >> (idx % 6)) & 1)


def write_vcd(path: Path, top: str, signals: list[str], cycles: int) -> dict:
    ids = {signal: vcd_id(idx) for idx, signal in enumerate(signals)}
    toggle_count = {signal: 0 for signal in signals}
    prev = {signal: "x" for signal in signals}
    lines = [
        "$date synthetic iEDA activity $end",
        "$version benchmarks/flows/generate_synthetic_activity.py $end",
        "$timescale 1ns $end",
        f"$scope module {top} $end",
    ]
    for signal in signals:
        lines.append(f"$var wire 1 {ids[signal]} {signal} $end")
    lines.extend(["$upscope $end", "$enddefinitions $end"])
    for cycle in range(cycles):
        lines.append(f"#{cycle}")
        for signal in signals:
            value = signal_value(signal, cycle)
            if value != prev[signal]:
                if prev[signal] != "x":
                    toggle_count[signal] += 1
                lines.append(f"{value}{ids[signal]}")
                prev[signal] = value
    path.write_text("\n".join(lines) + "\n", encoding="ascii")
    return {
        "signal_count": len(signals),
        "cycles": cycles,
        "toggle_count_total": sum(toggle_count.values()),
        "signals_with_toggle": sum(1 for value in toggle_count.values() if value > 0),
    }


def write_saif(path: Path, top: str, signals: list[str], cycles: int) -> None:
    duration = max(1, cycles - 1)
    lines = [
        "(SAIFILE",
        '  (SAIFVERSION "2.0")',
        '  (DIRECTION "backward")',
        f"  (DESIGN {top})",
        "  (DATE synthetic_iEDA_activity)",
        "  (VENDOR iEDA.ai)",
        "  (PROGRAM_NAME generate_synthetic_activity.py)",
        "  (TIMESCALE 1 ns)",
        f"  (DURATION {duration})",
        f"  (INSTANCE {top}",
    ]
    for signal in signals:
        transitions = sum(signal_value(signal, cycle) != signal_value(signal, cycle - 1) for cycle in range(1, cycles))
        ones = sum(signal_value(signal, cycle) == "1" for cycle in range(cycles))
        zeros = cycles - ones
        lines.append(f"    (NET {signal} (T0 {zeros}) (T1 {ones}) (TX 0) (TC {transitions}) (IG 0))")
    lines.extend(["  )", ")"])
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--design", default="aes_nangate45_a")
    parser.add_argument("--netlist", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--top", default="aes_cipher_top")
    parser.add_argument("--cycles", type=int, default=64)
    parser.add_argument("--max-internal", type=int, default=1200)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    text = args.netlist.read_text(encoding="utf-8", errors="replace")
    signals = parse_netlist_signals_for_top(text, top=args.top, max_internal=args.max_internal)
    vcd = args.output_dir / f"{args.top}.vcd"
    saif = args.output_dir / f"{args.top}.saif"
    stats = write_vcd(vcd, args.top, signals, max(2, args.cycles))
    write_saif(saif, args.top, signals, max(2, args.cycles))
    manifest = {
        "schema": "synthetic-activity/v1",
        "trusted": False,
        "design": args.design,
        "top": args.top,
        "netlist": str(args.netlist),
        "vcd": str(vcd),
        "saif": str(saif),
        **stats,
        "note": "Synthetic deterministic toggle activity for iPA smoke only; not RTL/gate simulation signoff stimulus.",
    }
    (args.output_dir / "activity_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(vcd)
    print(saif)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
