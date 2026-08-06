#!/usr/bin/env python3
"""Analyze progressive utilization test results and compare with baseline."""

import json
import sys
from pathlib import Path
from typing import Dict, List, Optional


def load_summary(result_dir: Path) -> Optional[Dict]:
    """Load summary.json from a result directory."""
    summary_path = result_dir / "summary.json"
    if not summary_path.exists():
        return None
    with summary_path.open() as f:
        return json.load(f)


def extract_qor_metrics(design_dir: Path) -> Dict:
    """Extract QoR metrics from design workspace."""
    metrics = {
        "drc_violations": None,
        "setup_wns": None,
        "hold_wns": None,
        "setup_tns": None,
        "hold_tns": None,
        "wirelength": None,
        "power_total": None,
    }

    # DRC violations
    drc_report = design_dir / "workspace/result/report/drc/iRT_drc.rpt"
    if drc_report.exists():
        content = drc_report.read_text()
        # Parse DRC format: usually has "Total violations: N"
        for line in content.split("\n"):
            if "violation" in line.lower():
                metrics["drc_violations"] = line.strip()
                break

    # Timing reports (iRT final timing)
    timing_report = design_dir / "workspace/result/timing/aes_cipher_top.rpt"
    if not timing_report.exists():
        # Try alternate names
        timing_report = design_dir / "workspace/result/timing/aes.rpt"

    if timing_report.exists():
        content = timing_report.read_text()
        for line in content.split("\n"):
            if "wns" in line.lower() and "setup" in line.lower():
                metrics["setup_wns"] = line.strip()
            elif "wns" in line.lower() and "hold" in line.lower():
                metrics["hold_wns"] = line.strip()
            elif "tns" in line.lower() and "setup" in line.lower():
                metrics["setup_tns"] = line.strip()
            elif "tns" in line.lower() and "hold" in line.lower():
                metrics["hold_tns"] = line.strip()

    # Wirelength
    wl_report = design_dir / "workspace/result/report/wirelength.rpt"
    if wl_report.exists():
        content = wl_report.read_text()
        for line in content.split("\n"):
            if "total" in line.lower():
                metrics["wirelength"] = line.strip()
                break

    # Power
    power_report = design_dir / "workspace/result/power/aes_cipher_top.pwr"
    if not power_report.exists():
        power_report = design_dir / "workspace/result/power/aes.pwr"
    if power_report.exists():
        content = power_report.read_text()
        for line in content.split("\n"):
            if "total" in line.lower() and "power" in line.lower():
                metrics["power_total"] = line.strip()
                break

    return metrics


def compare_results(test_summary: Dict, baseline_summary: Dict) -> Dict:
    """Compare test results against baseline."""
    comparison = {
        "test_utilization": test_summary["summaries"][0]["floorplan"]["target_utilization"],
        "baseline_utilization": baseline_summary["summaries"][0]["floorplan"]["target_utilization"],
        "designs": []
    }

    # Build baseline lookup
    baseline_by_design = {
        s["design"]: s for s in baseline_summary["summaries"]
    }

    for test_design in test_summary["summaries"]:
        design_name = test_design["design"]
        baseline_design = baseline_by_design.get(design_name)

        design_comparison = {
            "design": design_name,
            "pdk": test_design["pdk"],
            "test_status": test_design["status"],
            "baseline_status": baseline_design["status"] if baseline_design else "N/A",
            "test_stages": {},
            "baseline_stages": {},
        }

        # Stage-by-stage comparison
        for stage_name, stage_data in test_design.get("stages", {}).items():
            design_comparison["test_stages"][stage_name] = stage_data.get("status", "unknown")

        if baseline_design:
            for stage_name, stage_data in baseline_design.get("stages", {}).items():
                design_comparison["baseline_stages"][stage_name] = stage_data.get("status", "unknown")

        comparison["designs"].append(design_comparison)

    return comparison


def generate_report(test_dir: Path, baseline_dir: Path, output_file: Path):
    """Generate comparison report."""
    test_summary = load_summary(test_dir)
    baseline_summary = load_summary(baseline_dir)

    if not test_summary:
        print(f"ERROR: No summary.json found in {test_dir}")
        return 1

    if not baseline_summary:
        print(f"WARNING: No baseline summary found in {baseline_dir}")
        baseline_summary = {"summaries": []}

    comparison = compare_results(test_summary, baseline_summary)

    # Generate markdown report
    lines = [
        f"# Progressive Utilization Test Report",
        f"",
        f"**Test Run**: {test_summary.get('timestamp', 'unknown')}",
        f"**Test Utilization**: {comparison['test_utilization']:.0%}",
        f"**Baseline Utilization**: {comparison['baseline_utilization']:.0%}",
        f"",
        f"## Summary",
        f"",
    ]

    success_count = sum(1 for d in comparison["designs"] if d["test_status"] == "success")
    fail_count = sum(1 for d in comparison["designs"] if d["test_status"] == "failed")

    lines.extend([
        f"- Designs tested: {len(comparison['designs'])}",
        f"- Success: {success_count}",
        f"- Failed: {fail_count}",
        f"",
        f"## Design Status",
        f"",
        f"| Design | PDK | Test Status | Baseline Status | First Failure Stage |",
        f"|--------|-----|-------------|-----------------|---------------------|",
    ])

    for design in comparison["designs"]:
        first_fail = "N/A"
        if design["test_status"] == "failed":
            for stage, status in design["test_stages"].items():
                if status == "failed":
                    first_fail = stage
                    break

        lines.append(
            f"| {design['design']} | {design['pdk']} | "
            f"{design['test_status']} | {design['baseline_status']} | {first_fail} |"
        )

    lines.extend([
        f"",
        f"## Stage-by-Stage Breakdown",
        f"",
    ])

    for design in comparison["designs"]:
        lines.extend([
            f"### {design['design']}",
            f"",
            f"| Stage | Test | Baseline |",
            f"|-------|------|----------|",
        ])

        all_stages = set(design["test_stages"].keys()) | set(design["baseline_stages"].keys())
        for stage in sorted(all_stages):
            test_status = design["test_stages"].get(stage, "N/A")
            baseline_status = design["baseline_stages"].get(stage, "N/A")
            lines.append(f"| {stage} | {test_status} | {baseline_status} |")

        lines.append("")

    # Write report
    report_text = "\n".join(lines)
    output_file.write_text(report_text)
    print(f"Report written to: {output_file}")
    print(report_text)

    return 0


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: analyze_progressive_test.py <test_result_dir> <baseline_result_dir> [output.md]")
        sys.exit(1)

    test_dir = Path(sys.argv[1])
    baseline_dir = Path(sys.argv[2])
    output_file = Path(sys.argv[3]) if len(sys.argv) > 3 else test_dir / "comparison_report.md"

    sys.exit(generate_report(test_dir, baseline_dir, output_file))
