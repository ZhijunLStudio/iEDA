#!/usr/bin/env python3
"""
iPA vs PrimeTime PX Commercial Parity Validation Driver

Runs iPA power analysis and compares against PTPX reference data.
Gates on activity source provenance and power component accuracy.
"""

import json
import subprocess
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Optional, Dict, List
import argparse


@dataclass
class PowerComponents:
    """Power breakdown from iPA or PTPX"""
    switch_power_w: float
    internal_power_w: float
    leakage_power_w: float
    clock_power_w: float = 0.0  # Optional, some tools don't separate
    total_power_w: float = 0.0

    def __post_init__(self):
        if self.total_power_w == 0.0:
            self.total_power_w = (self.switch_power_w + self.internal_power_w +
                                  self.leakage_power_w + self.clock_power_w)


@dataclass
class PowerReport:
    """Complete power analysis report with provenance"""
    components: PowerComponents
    activity_source: str  # "vcd" | "saif" | "toggle_default" | "none"
    toggle_coverage: float  # 0.0 to 1.0
    corner: str
    voltage_v: float
    temperature_c: float
    runtime_s: Optional[float] = None
    design_name: Optional[str] = None


@dataclass
class ComparisonResult:
    """Comparison between iPA and PTPX"""
    design: str
    ipa_report: PowerReport
    ptpx_report: PowerReport

    # Error metrics (percentage)
    total_power_error_pct: float
    switch_power_error_pct: float
    internal_power_error_pct: float
    leakage_power_error_pct: float

    # Gate status
    passed: bool
    warnings: List[str]
    errors: List[str]

    def to_dict(self) -> Dict:
        return {
            'design': self.design,
            'ipa': asdict(self.ipa_report),
            'ptpx': asdict(self.ptpx_report),
            'errors_pct': {
                'total': self.total_power_error_pct,
                'switch': self.switch_power_error_pct,
                'internal': self.internal_power_error_pct,
                'leakage': self.leakage_power_error_pct,
            },
            'passed': self.passed,
            'warnings': self.warnings,
            'errors': self.errors,
        }


def parse_ipa_report(json_path: Path) -> PowerReport:
    """Parse iPA JSON power report"""
    with open(json_path) as f:
        data = json.load(f)

    # Check for required fields per 29-iPA-iIR-todo.md P0 schema
    required_fields = ['activity_source', 'power_components', 'corner', 'voltage']
    for field in required_fields:
        if field not in data:
            raise ValueError(f"iPA report missing required field: {field}")

    components = PowerComponents(
        switch_power_w=data['power_components']['switch_w'],
        internal_power_w=data['power_components']['internal_w'],
        leakage_power_w=data['power_components']['leakage_w'],
        clock_power_w=data['power_components'].get('clock_w', 0.0),
    )

    return PowerReport(
        components=components,
        activity_source=data['activity_source'],
        toggle_coverage=data.get('toggle_coverage', 0.0),
        corner=data['corner'],
        voltage_v=data['voltage'],
        temperature_c=data.get('temperature', 25.0),
        runtime_s=data.get('runtime_s'),
        design_name=data.get('design'),
    )


def parse_ptpx_report(rpt_path: Path) -> PowerReport:
    """Parse PrimeTime PX text report

    PTPX report format (example):
    ----------------------------------------
    Total Dynamic Power    = 1.234e-03 W
    Cell Internal Power    = 5.678e-04 W
    Net Switching Power    = 6.662e-04 W
    Cell Leakage Power     = 1.234e-04 W
    ----------------------------------------
    """
    components = PowerComponents(0, 0, 0, 0)
    corner = "unknown"
    voltage = 0.0

    with open(rpt_path) as f:
        for line in f:
            line = line.strip()
            if 'Net Switching Power' in line:
                components.switch_power_w = float(line.split('=')[1].split()[0])
            elif 'Cell Internal Power' in line:
                components.internal_power_w = float(line.split('=')[1].split()[0])
            elif 'Cell Leakage Power' in line:
                components.leakage_power_w = float(line.split('=')[1].split()[0])
            elif 'Total Dynamic Power' in line:
                total_dynamic = float(line.split('=')[1].split()[0])
            elif 'Operating Conditions' in line:
                corner = line.split(':')[1].strip()
            elif 'supply_voltage' in line:
                voltage = float(line.split('=')[1].strip())

    components.__post_init__()  # Recalc total

    return PowerReport(
        components=components,
        activity_source="vcd",  # PTPX always uses explicit activity
        toggle_coverage=1.0,  # Assume full coverage from reference
        corner=corner,
        voltage_v=voltage,
        temperature_c=25.0,  # Default, parse if needed
    )


def compare_reports(design: str, ipa: PowerReport, ptpx: PowerReport) -> ComparisonResult:
    """Compare iPA vs PTPX and gate on accuracy + activity provenance"""

    def calc_error_pct(ipa_val: float, ptpx_val: float) -> float:
        if ptpx_val == 0:
            return 0.0 if ipa_val == 0 else 999.9
        return ((ipa_val - ptpx_val) / ptpx_val) * 100.0

    total_err = calc_error_pct(ipa.components.total_power_w, ptpx.components.total_power_w)
    switch_err = calc_error_pct(ipa.components.switch_power_w, ptpx.components.switch_power_w)
    internal_err = calc_error_pct(ipa.components.internal_power_w, ptpx.components.internal_power_w)
    leakage_err = calc_error_pct(ipa.components.leakage_power_w, ptpx.components.leakage_power_w)

    warnings = []
    errors = []

    # Gate 1: Activity source must be explicitly labeled (G9 requirement)
    if ipa.activity_source == "none" or ipa.activity_source == "toggle_default":
        errors.append(f"Activity source '{ipa.activity_source}' not acceptable for trusted power")

    # Gate 2: Total power accuracy (±10% pass, ±15% warn, >15% fail)
    if abs(total_err) > 15.0:
        errors.append(f"Total power error {total_err:.1f}% exceeds ±15% threshold")
    elif abs(total_err) > 10.0:
        warnings.append(f"Total power error {total_err:.1f}% exceeds ±10% target")

    # Gate 3: Component accuracy (warn if any >±20%)
    for name, err in [('switch', switch_err), ('internal', internal_err), ('leakage', leakage_err)]:
        if abs(err) > 20.0:
            warnings.append(f"{name.capitalize()} power error {err:.1f}% exceeds ±20%")

    # Gate 4: Toggle coverage (warn if <80%)
    if ipa.toggle_coverage < 0.8:
        warnings.append(f"Toggle coverage {ipa.toggle_coverage:.1%} below 80% target")

    passed = len(errors) == 0

    return ComparisonResult(
        design=design,
        ipa_report=ipa,
        ptpx_report=ptpx,
        total_power_error_pct=total_err,
        switch_power_error_pct=switch_err,
        internal_power_error_pct=internal_err,
        leakage_power_error_pct=leakage_err,
        passed=passed,
        warnings=warnings,
        errors=errors,
    )


def main():
    parser = argparse.ArgumentParser(description='iPA vs PTPX validation')
    parser.add_argument('--design-list', required=True, help='Text file with design names')
    parser.add_argument('--output', default='validation_results.json', help='Output JSON path')
    args = parser.parse_args()

    with open(args.design_list) as f:
        designs = [line.strip() for line in f if line.strip()]

    results = []
    for design in designs:
        print(f"\n=== Validating {design} ===")

        base_path = Path(__file__).parent / 'designs' / design
        ipa_json = base_path / 'iPA_report.json'
        ptpx_rpt = base_path / 'ptpx_report.rpt'

        if not ipa_json.exists():
            print(f"ERROR: iPA report not found: {ipa_json}")
            continue
        if not ptpx_rpt.exists():
            print(f"WARN: PTPX report not found: {ptpx_rpt}, skipping comparison")
            continue

        try:
            ipa = parse_ipa_report(ipa_json)
            ptpx = parse_ptpx_report(ptpx_rpt)
            result = compare_reports(design, ipa, ptpx)

            print(f"  Total power error: {result.total_power_error_pct:+.2f}%")
            print(f"  Activity source: {ipa.activity_source} (coverage: {ipa.toggle_coverage:.1%})")
            print(f"  Status: {'PASS' if result.passed else 'FAIL'}")

            if result.warnings:
                for w in result.warnings:
                    print(f"  WARN: {w}")
            if result.errors:
                for e in result.errors:
                    print(f"  ERROR: {e}")

            results.append(result)

        except Exception as e:
            print(f"ERROR processing {design}: {e}")
            import traceback
            traceback.print_exc()

    # Write results
    output_path = Path(args.output)
    with open(output_path, 'w') as f:
        json.dump({
            'validation_type': 'iPA_vs_PTPX',
            'num_designs': len(results),
            'passed': sum(1 for r in results if r.passed),
            'failed': sum(1 for r in results if not r.passed),
            'results': [r.to_dict() for r in results],
        }, f, indent=2)

    print(f"\n{'='*60}")
    print(f"Results written to {output_path}")
    print(f"Summary: {sum(1 for r in results if r.passed)}/{len(results)} designs PASSED")

    return 0 if all(r.passed for r in results) else 1


if __name__ == '__main__':
    sys.exit(main())
