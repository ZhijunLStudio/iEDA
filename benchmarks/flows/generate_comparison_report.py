#!/usr/bin/env python3
"""Generate a full AES 13 run comparison report."""

from __future__ import annotations

import argparse
import json
import math
import os
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_RUN_ROOT = REPO_ROOT / "benchmarks" / "results" / "aes13"
DEFAULT_REPORT_ROOT = REPO_ROOT / "benchmarks" / "reports"
REPORT_OUTPUT = DEFAULT_REPORT_ROOT / "aes13_postchange_comparison-1.md"

DESIGNS = (
    "aes_sky130_a",
    "aes_sky130_b",
    "aes_sky130_t",
    "aes_nangate45_a",
    "aes_nangate45_b",
    "aes_nangate45_t",
    "aes_asap7_a",
    "aes_asap7_b",
    "aes_asap7_t",
    "aes_ics55_a",
    "aes_ics55_b",
    "aes_ics55_t",
    "aes",
)

STAGES = (
    ("floorplan", "iFP", "iFP_result.def"),
    ("fanout", "iNO", "iTO_fix_fanout_result.def"),
    ("placement", "iPL", "iPL_result.def"),
    ("cts", "iCTS", "iCTS_result.def"),
    ("to_drv", "iTO_drv", "iTO_drv_result.def"),
    ("to_hold", "iTO_hold", "iTO_hold_result.def"),
    ("legalization", "iPL_lg", "iPL_lg_result.def"),
    ("routing", "iRT", "iRT_result.def"),
    ("timing", "timing", None),
    ("power", "power", None),
    ("metrics", "metrics", "report/wirelength.rpt"),
    ("drc", "iRT_DRC", "report/drc/iRT_drc.rpt"),
    ("filler", "iPL_filler", "iPL_filler_result.def"),
    ("gds", "gds", "final.gds"),
)

BASELINE_GOAL_DELTA = 0.20
TARGET_UTILIZATION = 0.70


WNS_RE = re.compile(r"\bWNS[:\\s]+([+-]?(?:\\d+\\.\\d+|\\d*\\.\\d+|\\d+)(?:[eE][+-]?\\d+)?)")
TNS_RE = re.compile(r"\bTNS[:\\s]+([+-]?(?:\\d+\\.\\d+|\\d*\\.\\d+|\\d+)(?:[eE][+-]?\\d+)?)")


def number(value: Any, digits: int = 3, missing: str = "N/A") -> str:
    if value is None:
        return missing
    if isinstance(value, int):
        return f"{value}"
    try:
        if math.isfinite(float(value)):
            return f"{float(value):.{digits}f}"
    except Exception:
        return missing
    return missing


def pct(value: float | None, digits: int = 1) -> str:
    if value is None:
        return "N/A"
    return f"{100.0 * value:.{digits}f}%"


def safe_relpath(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def read_json(path: Path) -> dict[str, Any] | None:
    if not path.is_file():
        return None
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return None


def parse_timing_from_text(text: str) -> dict[str, float | None]:
    def _parse(match: re.Pattern[str]) -> float | None:
        m = match.search(text)
        if not m:
            return None
        try:
            return float(m.group(1))
        except Exception:
            return None

    return {
        "setup_wns_ns": _parse(WNS_RE),
        "setup_tns_ns": _parse(TNS_RE),
    }


def parse_timing_from_summary(summary: dict[str, Any]) -> dict[str, float | None]:
    timing = summary.get("timing") if isinstance(summary.get("timing"), dict) else {}
    if timing:
        return {
            "setup_wns_ns": timing.get("setup_wns_ns", timing.get("wns")),
            "setup_tns_ns": timing.get("setup_tns_ns", timing.get("tns")),
        }
    return {"setup_wns_ns": None, "setup_tns_ns": None}


def parse_performance_jsonl(path: Path) -> tuple[dict[str, float], float]:
    total = 0.0
    stage_runtime: dict[str, float] = {}
    if not path.is_file():
        return stage_runtime, total
    try:
        with path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    payload = json.loads(line)
                except Exception:
                    continue
                stage = payload.get("stage") or payload.get("name")
                if not stage:
                    continue
                sec = (
                    payload.get("runtime_sec")
                    or payload.get("time")
                    or payload.get("duration_sec")
                )
                if sec is None:
                    continue
                try:
                    sec_val = float(sec)
                except Exception:
                    continue
                stage_runtime[str(stage)] = stage_runtime.get(str(stage), 0.0) + sec_val
                total += sec_val
    except Exception:
        pass
    return stage_runtime, total


def best_timing_value(*values: float | None) -> float | None:
    for value in values:
        if value is None:
            continue
        if not math.isfinite(value):
            continue
        return value
    return None


def parse_timing_from_reports(result_dir: Path) -> dict[str, float | None]:
    reports = list(result_dir.rglob("*sta*.rpt")) + list(result_dir.rglob("*sta*.rpt.txt")) + list(result_dir.rglob("*.rpt"))
    timing = {"setup_wns_ns": None, "setup_tns_ns": None}
    for report in reports:
        try:
            text = report.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        parsed = parse_timing_from_text(text)
        for key in ("setup_wns_ns", "setup_tns_ns"):
            if parsed[key] is not None:
                timing[key] = parsed[key]
        if timing["setup_wns_ns"] is not None and timing["setup_tns_ns"] is not None:
            break
    return timing


@dataclass
class DesignReport:
    design: str
    pdk: str
    strategy: str
    status: str
    output_dir: Path
    result_dir: Path
    floorplan_target: float | None
    stage_status: dict[str, str]
    timing: dict[str, float | None]
    runtime_by_stage: dict[str, float]
    runtime_total: float
    artifacts: dict[str, list[str]]
    baseline_timing: dict[str, float | None] | None = None

    @property
    def util_target_ok(self) -> bool:
        return self.floorplan_target is not None and self.floorplan_target >= TARGET_UTILIZATION - 1e-9

    @property
    def util_gap_to_target(self) -> float | None:
        if self.floorplan_target is None:
            return None
        return self.floorplan_target - TARGET_UTILIZATION

    def timing_improvement(self, key: str) -> float | None:
        if self.baseline_timing is None:
            return None
        current = self.timing.get(key)
        base = self.baseline_timing.get(key)
        if current is None or base is None:
            return None
        if not math.isfinite(current) or not math.isfinite(base):
            return None
        if base == 0.0:
            return 1.0 if current >= 0.0 else None
        if current < 0.0 and base < 0.0:
            return max(0.0, (abs(base) - abs(current)) / abs(base))
        if current >= 0 and base < 0:
            return 1.0
        if current < 0 and base >= 0:
            return 0.0
        return max(0.0, (base - current) / abs(base)) if base != 0 else None

    def timing_improvement_meets_goal(self, key: str) -> bool:
        imp = self.timing_improvement(key)
        return imp is not None and imp >= BASELINE_GOAL_DELTA


def infer_design_metadata(design: str) -> tuple[str, str]:
    parts = design.split("_")
    if len(parts) >= 2:
        pdk = parts[1]
        strategy = parts[-1] if len(parts[-1]) == 1 else "a"
        return pdk, strategy
    return "unknown", "a"


def load_baseline_mapping(path: Path | None) -> dict[str, dict[str, float | None]]:
    if not path or not path.is_file():
        return {}
    data = read_json(path)
    if not isinstance(data, dict):
        return {}

    entries = data.get("designs")
    if not isinstance(entries, list):
        return {}

    result: dict[str, dict[str, float | None]] = {}
    for item in entries:
        if not isinstance(item, dict):
            continue
        name = item.get("design")
        timing = item.get("timing") if isinstance(item.get("timing"), dict) else {}
        if not name:
            continue
        result[str(name)] = {
            "setup_wns_ns": timing.get("setup_wns_ns"),
            "setup_tns_ns": timing.get("setup_tns_ns"),
        }
    return result


def load_design_report(design: str, run_root: Path, baseline: dict[str, dict[str, float | None]]) -> DesignReport:
    pdk, strategy = infer_design_metadata(design)
    output_dir = run_root / design
    summary = read_json(output_dir / "summary.json")
    result_dir = output_dir / "workspace" / "result"

    stage_status: dict[str, str] = {}
    floorplan_target = None
    runtime_total = 0.0
    runtime_by_stage: dict[str, float] = {}
    artifacts: dict[str, list[str]] = {"def": [], "gds": [], "rpt": [], "pwr": [], "png": []}
    status = "not_run"
    timing = {"setup_wns_ns": None, "setup_tns_ns": None}

    if summary:
        status = summary.get("status", "unknown")
        fp = summary.get("floorplan")
        if isinstance(fp, dict):
            floorplan_target = fp.get("target_utilization")
        stages = summary.get("stages", {})
        if isinstance(stages, dict):
            for stage_key, _name, _artifact in STAGES:
                info = stages.get(stage_key)
                if isinstance(info, dict):
                    stage_status[stage_key] = info.get("status", "unknown")
                else:
                    stage_status[stage_key] = "missing"

        timing = parse_timing_from_summary(summary)

        runtime_by_stage, runtime_total = parse_performance_jsonl(output_dir / "performance_profile.jsonl")

        for path in result_dir.rglob("*.def"):
            artifacts["def"].append(str(path))
        for path in result_dir.rglob("*.gds*"):
            artifacts["gds"].append(str(path))
        for path in result_dir.rglob("*.rpt"):
            artifacts["rpt"].append(str(path))
        for path in result_dir.rglob("*.pwr"):
            artifacts["pwr"].append(str(path))
        for path in result_dir.rglob("*.png"):
            artifacts["png"].append(str(path))
    else:
        # Fallback from raw result directory when no per-design summary exists.
        if result_dir.is_dir():
            for stage_key, _stage_label, marker in STAGES:
                if marker is None:
                    stage_status[stage_key] = "missing"
                    continue
                path = result_dir / marker
                stage_status[stage_key] = "done" if path.exists() else "missing"
            timing = parse_timing_from_reports(result_dir)
            for path in result_dir.rglob("*.def"):
                artifacts["def"].append(str(path))
            for path in result_dir.rglob("*.gds*"):
                artifacts["gds"].append(str(path))
            for path in result_dir.rglob("*.rpt"):
                artifacts["rpt"].append(str(path))
            for path in result_dir.rglob("*.pwr"):
                artifacts["pwr"].append(str(path))
            for path in result_dir.rglob("*.png"):
                artifacts["png"].append(str(path))
            runtime_by_stage, runtime_total = parse_performance_jsonl(output_dir / "performance_profile.jsonl")
        status = "unknown" if any(v for v in stage_status.values()) else "not_run"

    return DesignReport(
        design=design,
        pdk=pdk,
        strategy=strategy,
        status=status,
        output_dir=output_dir,
        result_dir=result_dir,
        floorplan_target=floorplan_target,
        stage_status=stage_status,
        timing=timing,
        runtime_by_stage=runtime_by_stage,
        runtime_total=runtime_total,
        artifacts=artifacts,
        baseline_timing=baseline.get(design),
    )


def discover_designs(run_root: Path) -> list[str]:
    batch = read_json(run_root / "summary.json")
    if isinstance(batch, dict):
        summary_entries = batch.get("summaries")
        if isinstance(summary_entries, list):
            seen = []
            for item in summary_entries:
                if not isinstance(item, dict):
                    continue
                design = item.get("design")
                if isinstance(design, str) and design not in seen:
                    seen.append(design)
            if seen:
                return seen
    return [name for name in DESIGNS if (run_root / name).is_dir()]


def run_root_summary(design_results: list[DesignReport], run_root: Path, output: Path) -> None:
    status_count: dict[str, int] = {}
    util_ok = 0
    util_total = 0
    tns_ok = 0
    wns_ok = 0
    with_targets = 0
    total_runtime = 0.0
    for result in design_results:
        status_count[result.status] = status_count.get(result.status, 0) + 1
        if result.floorplan_target is not None:
            util_total += 1
            if result.util_target_ok:
                util_ok += 1
        with_targets += 1
        if result.timing_improvement_meets_goal("setup_tns_ns"):
            tns_ok += 1
        if result.timing_improvement_meets_goal("setup_wns_ns"):
            wns_ok += 1
        total_runtime += result.runtime_total

    pdk_groups: dict[str, dict[str, int]] = {}
    for result in design_results:
        bucket = pdk_groups.setdefault(result.pdk, {"total": 0, "success": 0, "util_ok": 0, "tns_ok": 0, "wns_ok": 0})
        bucket["total"] += 1
        if result.status == "success":
            bucket["success"] += 1
        if result.util_target_ok:
            bucket["util_ok"] += 1
        if result.timing_improvement_meets_goal("setup_tns_ns"):
            bucket["tns_ok"] += 1
        if result.timing_improvement_meets_goal("setup_wns_ns"):
            bucket["wns_ok"] += 1

    lines = [
        "# AES13 交易化后对比报告（v1）",
        "",
        f"- 生成时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"- 结果目录：{safe_relpath(run_root, REPO_ROOT)}",
        "",
        "## 1. 总体统计",
        "",
        f"- 设计总数：{len(design_results)}",
    ]
    for key in ("success", "partial", "failed", "prepared", "not_run", "error"):
        lines.append(f"- {key}: {status_count.get(key, 0)}")
    lines.extend(
        [
            f"- 利用率目标达标(≥{TARGET_UTILIZATION:.2f})：{util_ok}/{util_total}",
            f"- TNS ≥ {int(BASELINE_GOAL_DELTA * 100)}% 提升：{tns_ok}/{with_targets}",
            f"- WNS ≥ {int(BASELINE_GOAL_DELTA * 100)}% 提升：{wns_ok}/{with_targets}",
            f"- 总运行时长累计：{number(total_runtime, 1)} s",
            "",
            "## 2. PDK 汇总",
            "",
            "| PDK | 总数 | 成功 | 利用率达标 | TNS 20%+ | WNS 20%+ |",
            "|---|---:|---:|---:|---:|---:|",
        ]
    )
    for pdk in sorted(pdk_groups.keys()):
        item = pdk_groups[pdk]
        lines.append(
            f"| {pdk} | {item['total']} | {item['success']} | {item['util_ok']}/{item['total']} | "
            f"{item['tns_ok']}/{item['total']} | {item['wns_ok']}/{item['total']} |"
        )
    lines.extend(
        [
            "",
            "## 3. 按设计明细",
            "",
            "| 设计 | PDK/策略 | 状态 | 利用率目标 | 达标 | 运行时(s) | WNS(ns) | TNS(ns) | WNS提升 | TNS提升 | 阶段完成率 |",
            "|---|---|---|---|---|---:|---:|---:|---:|---:|---:|",
        ]
    )
    for result in sorted(design_results, key=lambda item: item.design):
        done = sum(1 for v in result.stage_status.values() if v in {"success", "done"})
        total_stage = len(STAGES)
        if not result.stage_status:
            done = 0
            total_stage = len(STAGES)
        wns_gap = result.timing.get("setup_wns_ns")
        tns_gap = result.timing.get("setup_tns_ns")
        lines.append(
            f"| {result.design} | {result.pdk}/{result.strategy} | {result.status} | "
            f"{number(result.floorplan_target, 2)} | {'✓' if result.util_target_ok else '✗'} | "
            f"{number(result.runtime_total, 1)} | {number(wns_gap, 3)} | {number(tns_gap, 3)} | "
            f"{pct(result.timing_improvement('setup_wns_ns'))} | {pct(result.timing_improvement('setup_tns_ns'))} | "
            f"{done}/{total_stage} |"
        )
    lines.extend(
        [
            "",
            "## 4. 目标评审（新门禁）",
            "",
            f"- 目标：每个设计 floorplan target utilization 调整到 {TARGET_UTILIZATION:.2f}",
            f"- 目标：TNS/WNS 相对基线（`--baseline`）至少提升 {int(BASELINE_GOAL_DELTA * 100)}%",
            "",
            "每个指标说明：",
            "- `提升` 按负值改进率定义，值越大越好，1.0 代表全部修复；与基线同号无法评估时标记 `N/A`。",
            "",
            f"- 结果文件：{safe_relpath(output.with_suffix('.json'), output.parent)}（若有基线则包含 baseline 字段）",
        ]
    )
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_json_report(design_results: list[DesignReport]) -> dict[str, Any]:
    return {
        "schema_version": "aes13-postchange-v1",
        "generated_at": datetime.now().astimezone().isoformat(),
        "target_utilization": TARGET_UTILIZATION,
        "target_timing_improvement": BASELINE_GOAL_DELTA,
        "designs": [
            {
                "design": result.design,
                "pdk": result.pdk,
                "strategy": result.strategy,
                "status": result.status,
                "floorplan_target_utilization": result.floorplan_target,
                "output_dir": str(result.output_dir),
                "result_dir": str(result.result_dir),
                "runtime_total_sec": result.runtime_total,
                "runtime_by_stage": result.runtime_by_stage,
                "stage_status": result.stage_status,
                "timing": {
                    "setup_wns_ns": result.timing.get("setup_wns_ns"),
                    "setup_tns_ns": result.timing.get("setup_tns_ns"),
                },
                "timing_improvement": {
                    "setup_wns_ns": result.timing_improvement("setup_wns_ns"),
                    "setup_tns_ns": result.timing_improvement("setup_tns_ns"),
                },
                "targets": {
                    "util_ok": result.util_target_ok,
                    "util_gap": result.util_gap_to_target,
                    "wns_improvement_goal_met": result.timing_improvement_meets_goal("setup_wns_ns"),
                    "tns_improvement_goal_met": result.timing_improvement_meets_goal("setup_tns_ns"),
                },
                "artifacts": result.artifacts,
            }
            for result in design_results
        ],
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate AES13 comparison report from run summaries")
    parser.add_argument(
        "--run-root",
        type=Path,
        default=DEFAULT_RUN_ROOT,
        help="Run root path generated by aes13_flow.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=REPORT_OUTPUT,
        help="Markdown report output path",
    )
    parser.add_argument(
        "--baseline",
        type=Path,
        default=None,
        help="Optional baseline JSON for TNS/WNS uplift comparison",
    )
    parser.add_argument(
        "--baseline-improvement",
        type=float,
        default=0.20,
        help="Required TNS/WNS improvement ratio against baseline (default 0.20)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    global BASELINE_GOAL_DELTA
    BASELINE_GOAL_DELTA = args.baseline_improvement
    run_root = args.run_root
    if not run_root.is_dir():
        raise SystemExit(f"Run root not found: {run_root}")

    baseline = load_baseline_mapping(args.baseline)
    designs = discover_designs(run_root)
    if not designs:
        raise SystemExit(f"No AES design summaries found under {run_root}")

    design_results = [
        load_design_report(design, run_root, baseline) for design in designs
    ]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    json_path = args.output.with_suffix(".json")
    report_json = build_json_report(design_results)
    with json_path.open("w", encoding="utf-8") as f:
        json.dump(report_json, f, indent=2, ensure_ascii=False)
    json_path.write_text(json.dumps(report_json, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    run_root_summary(design_results, run_root, args.output)
    print(f"对比报告已生成: {args.output}")
    print(f"JSON 报告已生成: {json_path}")


if __name__ == "__main__":
    main()
